# flow.R for QuestionR
# The flow engine (DESIGN.md section 12): what happens in each step, with no
#   Shiny in it. A screen calls these and draws what they return, so every flow
#   runs in a test without a browser, and a new step is a new function here.
#   Function definitions and constants only.

# Two rules hold for every function in this file.
#   1. A model is reached only through `ask`, called as
#        ask(user = , m = , system_prompt = , max_tokens = , validate = )
#      It returns the parsed reply, or what llm_json() returns (a list holding
#      the parsed reply as `obj`), or signals an error. Tests hand in a fake.
#   2. A key is never looked up here. llm_json() finds it, for the model it is
#      given, inside `ask`.
# Every result is a plain list, so the run log is these lists (flow_round()).


# ---- one call, as a record ------------------------------------------------------

# llm_json() returns a list with the parsed reply as `obj`; a fake ask returns the
#   reply itself. The reply is the same either way.
is_llm_result <- function(x) is.list(x) && all(c("obj", "raw") %in% names(x))
as_reply <- function(x) if (is_llm_result(x)) x$obj else x

# What the log keeps about one call besides the reply: how long it took, why the
#   model stopped, the tokens, the attempts, and the reply as the model sent it.
call_record <- function(x, seconds) {
  full = is_llm_result(x)
  list(seconds = seconds,
       finish = if (full) x$finish %||% NA_character_ else NA_character_,
       tokens = if (full && !is.null(x$tokens)) tryCatch(as.list(x$tokens), error = function(e) NULL),
       attempts = if (full) x$attempts %||% NA_integer_ else NA_integer_,
       raw = if (full) x$raw else NA_character_)
}

# What one call came to, as a record: ok with its reply and call record, or failed with the reason
#   (and the model's last reply when there was one). A reply cut off at the ceiling says what to
#   do about it, for this step.
call_result <- function(out, seconds, step) {
  if (inherits(out, "error")) {
    why = if (inherits(out, "llm_truncated"))
      paste(conditionMessage(out), LLM_CUTOFF_ADVICE[[step]])
    else conditionMessage(out)
    return(list(status = "failed", error = why, reply = NULL,
                call = list(seconds = seconds, raw = out$raw %||% NA_character_)))
  }
  list(status = "ok", error = NA_character_, reply = as_reply(out),
       call = call_record(out, seconds))
}

# One model call, caught: nothing it does stops the caller. A failure is recorded
#   with its reason, and with the model's last reply when there was one.
call_model <- function(ask, user, m, system_prompt, max_tokens, validate, step) {
  started = Sys.time()
  out = tryCatch(ask(user = user, m = m, system_prompt = system_prompt,
                     max_tokens = max_tokens, validate = validate),
                 error = function(e) e)
  call_result(out, as.numeric(difftime(Sys.time(), started, units = "secs")), step)
}

# Several calls sent together, each caught (DESIGN.md section 16). ask_all takes the list of
#   requests, each the arguments `ask` takes, and returns a list in the same order, each the
#   reply or an error, so one failure does not lose the rest. A call's seconds are its own when
#   the reply says them, and the whole batch's when it does not.
call_all <- function(ask_all, requests, step) {
  started = Sys.time()
  outs = tryCatch(ask_all(requests), error = function(e) rep(list(e), length(requests)))
  batch = as.numeric(difftime(Sys.time(), started, units = "secs"))
  purrr::map(outs, function(out)
    call_result(out, if (is_llm_result(out) && is.numeric(out$seconds)) out$seconds else batch, step))
}

# The `ask_all` of a flow function that was given only `ask`: the real llm_json() sends requests
#   together (llm_json_all); any other ask (a test's fake, a script's own) answers them one after
#   the other, each caught.
ask_all_for <- function(ask) {
  if (identical(ask, llm_json)) return(llm_json_all)
  function(requests) purrr::map(requests, function(r) tryCatch(do.call(ask, r), error = function(e) e))
}

# A result keeps its call record as an attribute, so the fields a result is
#   specified to have stay exactly those.
with_call <- function(x, call) {
  attr(x, "call") <- call
  x
}

# A prompt that could not be built (a form with no research question, say) is
#   reported like any other failure, not raised.
step_prompt <- function(form, step, part = NULL)
  tryCatch(build_step_prompt(form, step, part), error = function(e) e)


# ---- the review --------------------------------------------------------------------

# The Evaluate task: the model reviews the pasted questionnaire with the
#   CHECKLIST of the files in force. Fields:
#   status, error, system, user, hash, reply (the parsed review), and batches.
#
#   A questionnaire that fits one call (APP_BATCH_CHARS) is reviewed in one call, with
#   the prompt build_prompt() gives for a review, and `batches` holds that one call. A longer one is split on blank lines into
#   parts (DESIGN.md section 14): one call for the questions of each part, then one
#   call for the instrument as a whole. `batches` has one entry per call, in order:
#   kind ("all", "items" or "instrument"), part (k), n_parts, first_block, status,
#   error, hash, user, reply, and the call record (seconds, finish, tokens, attempts,
#   raw). `reply` has the usual shape, the questions in the order pasted. `status` is
#   "ok" when every call succeeded, "partial" when some did and some did not, and
#   "failed" when none did. A part that failed can be run again, rerun_review_part().
#   `user` and `hash` are the first call's. R's checks on the reply (a quote not in
#   the pasted text, a check that was not sent) are check_review().
#
#   The parts are sent together, at most REVIEW_AT_ONCE at a time (ask_all); the instrument
#   call, which needs no part's answer but is one call, goes by `ask` after them. progress(msg)
#   is called before each call or batch, so a screen can say "parts 1 to 4 of 6 together" and
#   this file stays free of Shiny. An edited prompt (the Prompt tab) can only be
#   sent in a one-call review; it is kept as the result's attribute "prompt".
REVIEW_AT_ONCE <- 4L

run_review <- function(form, m, ask = llm_json, prompt = NULL, progress = function(msg) NULL,
                       ask_all = ask_all_for(ask)) {
  p = step_prompt(form, "work")
  failed = function(why)
    list(status = "failed", error = why, system = NA_character_, user = NA_character_,
         hash = NA_character_, reply = NULL, batches = list())
  if (inherits(p, "error")) return(failed(conditionMessage(p)))
  f = clean_form(form)
  if (TASKS[[f$task]]$kind != "review")
    return(failed("Only a review task is reviewed by the model."))
  plan = tryCatch(review_plan(f$questionnaire, APP_BATCH_CHARS), error = function(e) e)
  if (inherits(plan, "error")) return(failed(conditionMessage(plan)))
  if (!is.null(prompt) && (!is.list(prompt) || !is.character(prompt$system) || !is.character(prompt$user)))
    stop("prompt must be a list with a system and a user string.", call. = FALSE)

  if (length(plan) == 1L) {
    # The prompt the analyst approved, which is the assembled one unless they edited
    #   it, as in run_draft().
    if (!is.null(prompt)) {
      p = prompt
      p$hash = p$hash %||% prompt_hash(p$system, p$user)
    }
    batch = review_call(ask, m, p, plan[[1]], progress)
    out = review_result(p$system, list(batch), p)
    if (!is.null(prompt)) attr(out, "prompt") <- prompt
    return(out)
  }
  if (isTRUE(prompt$edited))
    stop("An edited prompt can be sent only when the questionnaire is reviewed in one call; ",
         "this one is reviewed in ", length(plan) - 1L, " parts.", call. = FALSE)
  parts = plan[-length(plan)]
  together = unlist(purrr::map(unname(split(parts, ceiling(seq_along(parts) / REVIEW_AT_ONCE))),
                               function(chunk) review_together(ask_all, m, f, chunk, progress)), recursive = FALSE)
  spec = plan[[length(plan)]]
  instrument = review_call(ask, m, step_prompt(f, "instrument", part = spec), spec, progress)
  review_result(p$system, c(together, list(instrument)))
}

# The same review with one call run again, for a part that failed: index is the
#   place of that call in rv$batches. The other calls are kept as they were.
rerun_review_part <- function(form, m, rv, index, ask = llm_json, progress = function(msg) NULL) {
  f = clean_form(form)
  plan = review_plan(f$questionnaire, APP_BATCH_CHARS)
  if (length(plan) < 2L || length(plan) != length(rv$batches) || index < 1L || index > length(plan))
    stop("There is no part ", index, " to run again.", call. = FALSE)
  spec = plan[[index]]
  batch = review_call(ask, m, step_prompt(f, spec$kind, part = spec), spec, progress)
  batch$rerun = TRUE
  review_result(rv$system, replace(rv$batches, index, list(batch)))
}

# One call of a review as a record: the part, how it came out, its prompt's hash and text, its
#   reply and its call record. p is the prompt (or the error that building it gave), r a call_result().
review_record <- function(spec, p, r) {
  bad = inherits(p, "error")
  list(kind = spec$kind, part = spec$k, n_parts = spec$n, first_block = spec$first_block,
       chars = nchar(spec$text), status = if (bad) "failed" else r$status,
       error = if (bad) conditionMessage(p) else r$error,
       hash = if (bad) NA_character_ else p$hash, user = if (bad) NA_character_ else p$user,
       reply = if (bad) NULL else r$reply, seconds = if (bad) 0 else r$call$seconds,
       finish = if (bad) NA_character_ else r$call$finish %||% NA_character_,
       tokens = if (bad) NULL else r$call$tokens,
       attempts = if (bad) NA_integer_ else r$call$attempts %||% NA_integer_,
       raw = if (bad) NA_character_ else r$call$raw %||% NA_character_)
}

# One call of a review, by `ask`. p is the prompt (or the error that building it gave).
review_call <- function(ask, m, p, spec, progress) {
  if (inherits(p, "error")) return(review_record(spec, p, NULL))
  progress(switch(spec$kind,
                  all = "Reviewing the questionnaire",
                  items = paste0("Reviewing part ", spec$k, " of ", spec$n),
                  instrument = "Reviewing the questionnaire as a whole"))
  review_record(spec, p, call_model(ask, p$user, m, p$system, LLM_MAX_TOKENS[["evaluate"]],
                                    reply_validator("review"), "evaluate"))
}

# Some parts of a review sent together, by `ask_all`; a part whose prompt cannot be built is a
#   failed record and is not sent. Returns the records in the parts' order.
review_together <- function(ask_all, m, f, chunk, progress) {
  prompts = purrr::map(chunk, function(spec) step_prompt(f, "items", part = spec))
  sendable = !purrr::map_lgl(prompts, function(p) inherits(p, "error"))
  progress(if (length(chunk) == 1L) paste0("Reviewing part ", chunk[[1]]$k, " of ", chunk[[1]]$n)
           else paste0("Reviewing parts ", chunk[[1]]$k, " to ", chunk[[length(chunk)]]$k, " of ", chunk[[1]]$n, " together"))
  results = rep(list(NULL), length(chunk))
  results[sendable] = call_all(ask_all, purrr::map(prompts[sendable], function(p)
    list(user = p$user, m = m, system_prompt = p$system, max_tokens = LLM_MAX_TOKENS[["evaluate"]],
         validate = reply_validator("review"))), "evaluate")
  purrr::pmap(list(chunk, prompts, results), review_record)
}

# A review's result from its calls. One call: the fields of a one-call review (and its
#   call record as the attribute "call"). Several: the questions of the parts that
#   came back, in order, and everything about the instrument from the instrument
#   call; what an item call says about the instrument, or the instrument call about
#   a question, is not read.
review_result <- function(system, batches, p = NULL) {
  ok = purrr::map_lgl(batches, function(b) identical(b$status, "ok"))
  if (length(batches) == 1L) {
    b = batches[[1]]
    return(with_call(list(status = b$status, error = b$error, system = system, user = b$user,
                          hash = b$hash, reply = b$reply, batches = batches),
                     list(seconds = b$seconds, finish = b$finish, tokens = b$tokens,
                          attempts = b$attempts, raw = b$raw)))
  }
  kinds = purrr::map_chr(batches, "kind")
  inst = purrr::detect(batches[ok & kinds == "instrument"], function(b) TRUE)
  reply = if (any(ok)) list(
    items = unlist(purrr::map(batches[ok & kinds == "items"], function(b) unname(b$reply$items)), recursive = FALSE) %||% list(),
    instrument = inst$reply$instrument %||% list())
  why = purrr::map_chr(batches[!ok], function(b)
    paste0(if (identical(b$kind, "instrument")) "The instrument as a whole" else paste0("Part ", b$part, " of ", b$n_parts),
           " did not come back: ", b$error))
  num = function(f) sum(purrr::map_dbl(batches, function(b) as.numeric(b$tokens[[f]] %||% 0)))
  with_call(list(status = if (all(ok)) "ok" else if (any(ok)) "partial" else "failed",
                 error = if (all(ok)) NA_character_ else paste(why, collapse = " "),
                 system = system, user = batches[[1]]$user, hash = batches[[1]]$hash, reply = reply,
                 batches = batches),
            list(seconds = sum(purrr::map_dbl(batches, function(b) b$seconds %||% 0)), finish = NA_character_,
                 tokens = list(input = num("input"), output = num("output")),
                 attempts = sum(purrr::map_int(batches, function(b) as.integer(b$attempts %||% 0L)), na.rm = TRUE),
                 raw = NA_character_))
}


# ---- the draft -------------------------------------------------------------------

# The model drafts the items with the approved prompt (the assembled one unless the
#   analyst edited it). Fields: status, error, reply (the parsed draft); the call record
#   is the attribute "call" and the prompt the attribute "prompt". A reply with the wrong
#   shape or the wrong number of items is retried by llm_json() and then recorded as failed.
run_draft <- function(form, m, ask = llm_json, prompt = build_prompt(form)) {
  if (!is.list(prompt) || !is.character(prompt$system) || !is.character(prompt$user))
    stop("prompt must be a list with a system and a user string.", call. = FALSE)
  f = clean_form(form)
  if (TASKS[[f$task]]$kind != "draft")
    stop("Only a drafting task is drafted.", call. = FALSE)
  r = call_model(ask, prompt$user, m, prompt$system, LLM_MAX_TOKENS[["draft"]],
                 reply_validator("draft", n_items = f$n_items), "draft")
  structure(with_call(list(status = r$status, error = r$error, reply = r$reply), r$call),
            prompt = prompt)
}


# ---- the run log -------------------------------------------------------------------------------

# One row per model call of a round: what ran, how it ended, how long, and what it
#   cost in tokens. First in the log, so it can be read without scrolling.
flow_summary <- function(m, draft = NULL, review = NULL) {
  row = function(step, x, cl = attr(x, "call") %||% x)
    list(step = step, model = m$id %||% NA_character_, status = x$status,
         seconds = cl$seconds %||% NA_real_, finish = cl$finish %||% NA_character_,
         attempts = cl$attempts %||% NA_integer_, tokens_in = cl$tokens$input %||% NA_real_,
         tokens_out = cl$tokens$output %||% NA_real_, error = x$error %||% NA_character_)
  c(if (!is.null(draft)) list(row("draft", draft)),
    if (!is.null(review) && length(review$batches) <= 1L) list(row("review", review)),
    if (!is.null(review) && length(review$batches) > 1L)
      purrr::map(review$batches, function(b)
        row(if (identical(b$kind, "instrument")) "review instrument"
            else paste0("review part ", b$part, " of ", b$n_parts), b, b)))
}

# A result's call record, from its attribute into a field, so it reaches the log.
with_call_field <- function(x) {
  if (!is.null(x)) x$call <- attr(x, "call")
  x
}

# A round, for the log: schema 2, the time, the form, the prompt as sent, then what the
#   call or calls returned. The key is never in these lists, and neither is a header: a
#   call record holds no request. analyst is what the analyst did with the result.
flow_round <- function(form, m = APP_MODEL, draft = NULL, review = NULL, analyst = NULL,
                       time = Sys.time()) {
  list(schema = 2L, time = format(time, "%Y-%m-%dT%H:%M:%S%z"),
       summary = flow_summary(m, draft, review), form = form,
       prompt = attr(draft, "prompt") %||% attr(review, "prompt"),
       draft = with_call_field(draft), review = with_call_field(review), analyst = analyst)
}

# The log as JSON text. Nothing is written to disk here.
flow_log_json <- function(round)
  jsonlite::toJSON(round, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null",
                   force = TRUE)
