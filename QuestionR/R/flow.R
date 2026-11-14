# flow.R for QuestionR
# What happens in each task, with no Shiny in it. A screen calls these and draws what they
#   return, so every flow runs in a test without a browser. Function definitions and constants
#   only.

# A model is reached only through ask(user, m, system_prompt, max_tokens, validate), which returns
#   the parsed reply or llm_json()'s result, or ask_all(requests), a list of those with an error in
#   place of a failed one; tests hand in fakes. A key is never looked up here.


# ---- one call, as a record ------------------------------------------------------------

is_llm_result <- function(x) is.list(x) && all(c("obj", "raw") %in% names(x))
as_reply <- function(x) if (is_llm_result(x)) x$obj else x

# What one call came to: ok with its reply, or failed with the reason (a reply cut off at the
#   ceiling says what to do about it); and what the log keeps: seconds, finish, tokens, attempts
#   and the reply as the model sent it.
call_result <- function(out, seconds, step) {
  full = is_llm_result(out)
  failed = inherits(out, "error")
  list(status = if (failed) "failed" else "ok",
       error = if (!failed) NA_character_ else if (inherits(out, "llm_truncated"))
         paste(conditionMessage(out), LLM_CUTOFF_ADVICE[[step]]) else conditionMessage(out),
       reply = if (!failed) as_reply(out),
       seconds = if (full && is.numeric(out$seconds)) out$seconds else seconds,
       finish = if (full) out$finish %||% NA_character_ else NA_character_,
       tokens = if (full && !is.null(out$tokens)) tryCatch(as.list(out$tokens), error = function(e) NULL),
       attempts = if (full) out$attempts %||% NA_integer_ else NA_integer_,
       raw = if (full) out$raw else out$raw %||% NA_character_)
}

# The `ask_all` for a given `ask`: the real llm_json() sends requests together (llm_json_all);
#   any other ask answers them one after the other, each caught.
ask_all_for <- function(ask) {
  if (identical(ask, llm_json)) return(llm_json_all)
  function(requests) purrr::map(requests, function(r) tryCatch(do.call(ask, r), error = function(e) e))
}

# Several calls sent together, each caught, so one failure does not lose the rest.
call_all <- function(ask_all, requests, step) {
  started = Sys.time()
  outs = tryCatch(ask_all(requests), error = function(e) rep(list(e), length(requests)))
  batch = as.numeric(difftime(Sys.time(), started, units = "secs"))
  purrr::map(outs, call_result, seconds = batch, step = step)
}


# ---- a review -----------------------------------------------------------------------------

# How many calls of a review go out together.
REVIEW_AT_ONCE <- 4L

# The prompt of one call of a review. message is the analyst's text, the same for every call.
review_prompt <- function(f, part, message = NULL)
  tryCatch(build_step_prompt(f, part$kind, part = part, message = message), error = function(e) e)

# One call of a review as a record: its part, and how it came out.
review_record <- function(part, p, r = NULL) {
  bad = inherits(p, "error")
  c(part[c("kind", "k", "n", "first", "ids", "questions")],
    if (bad) list(status = "failed", error = conditionMessage(p), hash = NA_character_, user = NA_character_, reply = NULL)
    else c(list(hash = p$hash, user = p$user, checks = p$checks), r))
}

# The calls of a review, sent REVIEW_AT_ONCE at a time; a call whose prompt cannot be built is a
#   failed record and is not sent. progress(msg) is told before each group, so a screen can say so.
send_parts <- function(ask_all, m, f, parts, message, progress = function(msg) NULL) {
  prompts = purrr::map(parts, function(part) review_prompt(f, part, message))
  groups = split(seq_along(parts), ceiling(seq_along(parts) / REVIEW_AT_ONCE))
  results = unlist(purrr::map(unname(groups), function(at) {
    progress(paste0("Sending ", if (length(at) == 1L) "call " else "calls ", min(at),
                    if (length(at) > 1L) paste0(" to ", max(at)), " of ", length(parts)))
    ok = at[!purrr::map_lgl(prompts[at], function(p) inherits(p, "error"))]
    out = rep(list(NULL), length(at))
    out[at %in% ok] = call_all(ask_all, purrr::map(ok, function(i) {
      kind = parts[[i]]$kind
      list(user = prompts[[i]]$user, m = m, system_prompt = prompts[[i]]$system, max_tokens = LLM_MAX_TOKENS[[kind]],
           validate = reply_validator(kind, checks = prompts[[i]]$checks, n_questions = length(parts[[i]]$questions)))
    }), "evaluate")
    out
  }), recursive = FALSE)
  purrr::pmap(list(parts, prompts, results), review_record)
}

# A review: one items call per part of review_plan() and, with more than one question, one call on
#   the whole, four at a time. Every call sends the analyst's message, then its own tail. Fields:
#   status ("ok", "partial", "failed"), error, and batches, one record per call in order.
run_review <- function(form, m, ask = llm_json, message = NULL, progress = function(msg) NULL,
                       ask_all = ask_all_for(ask)) {
  f = tryCatch(clean_form(form), error = function(e) e)
  if (inherits(f, "error")) return(list(status = "failed", error = conditionMessage(f), batches = list()))
  plan = tryCatch(review_plan(f$questionnaire), error = function(e) e)
  if (inherits(plan, "error")) return(list(status = "failed", error = conditionMessage(plan), batches = list()))
  review_result(send_parts(ask_all, m, f, plan, message, progress))
}

# The same review with one call run again, for a call that failed: index is its place in
#   rv$batches. The other calls are kept as they were.
rerun_review_part <- function(form, m, rv, index, ask = llm_json, message = NULL) {
  f = clean_form(form)
  plan = review_plan(f$questionnaire)
  if (length(plan) != length(rv$batches) || index < 1L || index > length(plan))
    stop("There is no part ", index, " to run again.", call. = FALSE)
  again = send_parts(ask_all_for(ask), m, f, plan[index], message)[[1]]
  review_result(replace(rv$batches, index, list(again)))
}

review_result <- function(batches) {
  ok = purrr::map_lgl(batches, function(b) identical(b$status, "ok"))
  why = purrr::map_chr(batches[!ok], function(b)
    paste0(if (identical(b$kind, "instrument")) "The questionnaire as a whole" else paste0("Part ", b$k, " of ", b$n),
           " did not come back: ", b$error))
  list(status = if (all(ok)) "ok" else if (any(ok)) "partial" else "failed",
       error = if (all(ok)) NA_character_ else paste(why, collapse = " "), batches = batches)
}


# ---- Write questions: a draft, then an edit by a second model -------------------------------

# One call of Write questions, by `ask`, as a record with its model, prompt hash and user text.
#   step is "draft" (message is the analyst's) or "refine" (draft is the parsed draft).
write_call <- function(form, step, m, ask, message = NULL, draft = NULL) {
  p = tryCatch(build_step_prompt(form, step, message = message, draft = draft), error = function(e) e)
  if (inherits(p, "error")) return(list(status = "failed", error = conditionMessage(p), model = m$id))
  started = Sys.time()
  out = tryCatch(ask(user = p$user, m = m, system_prompt = p$system, max_tokens = LLM_MAX_TOKENS[[step]],
                     validate = reply_validator(step, n_items = clean_form(form)$n_items)),
                 error = function(e) e)
  c(call_result(out, as.numeric(difftime(Sys.time(), started, units = "secs")), "draft"),
    list(model = m$id, hash = p$hash, user = p$user, checks = p$checks))
}

# The drafter writes one draft with the analyst's message; the main model, in a fresh chat, edits it
#   into the final questions against the CHECKLIST. Two calls, whatever the number of items. Returns
#   the draft and the refine (NULL when there was no draft to edit).
run_write <- function(form, m, drafter = m$drafter %||% m, ask = llm_json, message = NULL) {
  d = write_call(form, "draft", drafter, ask, message = message)
  if (!identical(d$status, "ok")) return(list(draft = d, refine = NULL))
  list(draft = d, refine = write_call(form, "refine", m, ask, draft = d$reply))
}

# What the page shows: the edited items, or the draft's when the edit did not come back.
final_reply <- function(w) if (identical(w$refine$status, "ok")) w$refine$reply else w$draft$reply


# ---- the run log --------------------------------------------------------------------------

# One row per model call: what ran, how it ended, how long, and what it cost in tokens.
call_rows <- function(m, calls)
  purrr::map(calls, function(x)
    list(call = x$label, model = x$model %||% m$id, status = x$status, seconds = x$seconds %||% NA_real_,
         finish = x$finish %||% NA_character_, attempts = x$attempts %||% NA_integer_,
         tokens_in = x$tokens$input %||% NA_real_, tokens_out = x$tokens$output %||% NA_real_,
         tokens_cached = x$tokens$cached_input %||% NA_real_, error = x$error %||% NA_character_))

# The calls of a run, each with a label, in order.
run_calls <- function(draft = NULL, review = NULL, refine = NULL)
  c(if (!is.null(draft)) list(c(draft, list(label = "draft"))),
    if (!is.null(refine)) list(c(refine, list(label = "refine"))),
    purrr::map(review$batches, function(b)
      c(b, list(label = if (identical(b$kind, "instrument")) "whole questionnaire" else paste0("part ", b$k, " of ", b$n)))))

# A run, for the log: the time, the form, the message as assembled and as sent, the call summary,
#   then every call in full. The key is never in these lists: a call record holds no request.
flow_round <- function(form, m = APP_MODEL, draft = NULL, review = NULL, refine = NULL, prompt = NULL,
                       analyst = NULL, time = Sys.time())
  list(time = format(time, "%Y-%m-%dT%H:%M:%S%z"), model = m$id, form = form,
       message_assembled = prompt$assembled, message_sent = prompt$sent, edited = !identical(prompt$assembled, prompt$sent),
       summary = call_rows(m, run_calls(draft, review, refine)), draft = draft, refine = refine, review = review,
       analyst = analyst)

flow_log_json <- function(x)
  jsonlite::toJSON(x, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null", force = TRUE)
