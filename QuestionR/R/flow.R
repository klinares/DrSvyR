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

# One model call, caught: nothing it does stops the caller. A failure is recorded
#   with its reason, and with the model's last reply when there was one.
call_model <- function(ask, user, m, system_prompt, max_tokens, validate, step) {
  started = Sys.time()
  out = tryCatch(ask(user = user, m = m, system_prompt = system_prompt,
                     max_tokens = max_tokens, validate = validate),
                 error = function(e) e)
  seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))
  if (inherits(out, "error")) {
    # A reply cut off at the ceiling says what to do about it, for this step.
    why = if (inherits(out, "llm_truncated"))
      paste(conditionMessage(out), LLM_CUTOFF_ADVICE[[step]])
    else conditionMessage(out)
    return(list(status = "failed", error = why, reply = NULL,
                call = list(seconds = seconds, raw = out$raw %||% NA_character_)))
  }
  list(status = "ok", error = NA_character_, reply = as_reply(out),
       call = call_record(out, seconds))
}

# A result keeps its call record as an attribute, so the fields a result is
#   specified to have stay exactly those.
with_call <- function(x, call) {
  attr(x, "call") <- call
  x
}

# A prompt that could not be built (a form with no research question, say) is
#   reported like any other failure, not raised.
step_prompt <- function(form, step, candidates = NULL)
  tryCatch(build_step_prompt(form, step, candidates), error = function(e) e)


# ---- the brief check -------------------------------------------------------------

# The project manager reads the form and says what is missing. Fields: status
#   ("ok" or "failed"), error, system, user, hash, reply (the parsed brief check).
run_brief <- function(form, pm, ask = llm_json) {
  p = step_prompt(form, "brief")
  if (inherits(p, "error"))
    return(list(status = "failed", error = conditionMessage(p), system = NA_character_,
                user = NA_character_, hash = NA_character_, reply = NULL))
  r = call_model(ask, p$user, pm, p$system, LLM_MAX_TOKENS[["brief"]],
                 reply_validator("brief"), "brief")
  with_call(list(status = r$status, error = r$error, system = p$system, user = p$user,
                 hash = p$hash, reply = r$reply), r$call)
}


# ---- the review --------------------------------------------------------------------

# The Evaluate task: the project manager reviews the pasted questionnaire, once,
#   with the CHECKLIST of the files in force. No worker is called. Same shape as
#   run_brief: status, error, system, user, hash, reply (the parsed review). The
#   prompt is the one build_prompt() gives for a review. R's checks on the reply
#   (a quote not in the text, a check that was not sent) are check_review().
run_review <- function(form, pm, ask = llm_json) {
  p = step_prompt(form, "work")
  failed = function(why)
    list(status = "failed", error = why, system = NA_character_, user = NA_character_,
         hash = NA_character_, reply = NULL)
  if (inherits(p, "error")) return(failed(conditionMessage(p)))
  if (TASKS[[clean_form(form)$task]]$kind != "review")
    return(failed("Only a review task is reviewed by the project manager."))
  r = call_model(ask, p$user, pm, p$system, LLM_MAX_TOKENS[["evaluate"]],
                 reply_validator("review"), "evaluate")
  with_call(list(status = r$status, error = r$error, system = p$system, user = p$user,
                 hash = p$hash, reply = r$reply), r$call)
}


# ---- the workers -------------------------------------------------------------------

# Each worker gets the same prompt, one after another. prompt is the approved
#   prompt, which is the assembled one unless the analyst edited it. Returns an
#   unnamed list with exactly one entry per worker, in the workers' order, each
#   model (the id), status, error, reply (the parsed draft) and seconds. A
#   worker that errors, or whose reply has the wrong shape or the wrong number of
#   items, is recorded as failed and the run goes on. The prompt used is the
#   list's attribute "prompt".
run_drafts <- function(form, workers, ask = llm_json, prompt = build_prompt(form)) {
  if (!is.list(prompt) || !is.character(prompt$system) || !is.character(prompt$user))
    stop("prompt must be a list with a system and a user string.", call. = FALSE)
  f = clean_form(form)
  if (TASKS[[f$task]]$kind != "draft")
    stop("Only a drafting task is run by the workers.", call. = FALSE)
  validate = reply_validator("draft", n_items = f$n_items)
  drafts = purrr::map(unname(workers), function(m) {
    r = call_model(ask, prompt$user, m, prompt$system, LLM_MAX_TOKENS[["draft"]], validate, "draft")
    with_call(list(model = m$id, status = r$status, error = r$error, reply = r$reply,
                   seconds = r$call$seconds), r$call)
  })
  structure(drafts, prompt = prompt)
}


# ---- blind labels ------------------------------------------------------------------------

# The order the successful drafts take once shuffled by the seed. A hash of the
#   seed and the position decides it: the same seed always gives the same order, on
#   any machine and any R version, and the generator's own seed is not touched.
shuffle_order <- function(n, models, seed) {
  keys = purrr::map_chr(seq_len(n), function(i)
    digest::digest(paste(seed, i, models[i], sep = "|"), algo = "sha256", serialize = FALSE))
  order(keys, method = "radix")
}

# The drafts that arrived, in the order the seed gives them, and the letters they
#   are known by: letter -> parsed draft. Only drafts with status "ok".
candidates_of <- function(drafts, seed) {
  drafts = purrr::keep(unname(as.list(drafts)), function(d) identical(d$status, "ok"))
  ord = shuffle_order(length(drafts), purrr::map_chr(drafts, "model"), seed)
  purrr::set_names(purrr::map(drafts[ord], "reply"), LETTERS[seq_along(ord)])
}

# Candidate letter -> model id, in the same order. This is what the analyst sees;
#   the appraiser never does.
labels_of <- function(drafts, seed) {
  drafts = purrr::keep(unname(as.list(drafts)), function(d) identical(d$status, "ok"))
  ord = shuffle_order(length(drafts), purrr::map_chr(drafts, "model"), seed)
  purrr::set_names(purrr::map_chr(drafts[ord], "model"), LETTERS[seq_along(ord)])
}

# A model's id, and the part after its vendor's slash, found in a prompt. The
#   appraisal must be blind, so one that would not be is not sent.
model_names_in <- function(text, ids) {
  candidates = unique(c(ids, sub("^.*/", "", ids)))
  candidates = candidates[nchar(candidates) >= 4L]
  candidates[purrr::map_lgl(candidates, function(n) grepl(tolower(n), tolower(text), fixed = TRUE))]
}


# ---- the appraisal --------------------------------------------------------------------------

# The project manager appraises the drafts that arrived, relabelled A, B, C in an
#   order the seed gives, so it does not know which model wrote which. Fields:
#   status, error, labels (letter -> model id, only for drafts with status "ok"),
#   system, user, hash, reply. seed is stored in the log, with the labels.
run_appraisal <- function(form, drafts, pm, ask = llm_json, seed) {
  if (missing(seed) || length(seed) != 1L || is.na(seed))
    stop("run_appraisal needs a seed, one number, so the labels can be reproduced.", call. = FALSE)
  labels = labels_of(drafts, seed)
  failed = function(why, p = NULL)
    list(status = "failed", error = why, labels = labels,
         system = p$system %||% NA_character_, user = p$user %||% NA_character_,
         hash = p$hash %||% NA_character_, reply = NULL)

  if (!length(labels)) return(failed("No draft arrived, so there is nothing to appraise."))
  p = step_prompt(form, "appraise", candidates_of(drafts, seed))
  if (inherits(p, "error")) return(failed(conditionMessage(p)))

  ids = c(pm$id, purrr::map_chr(unname(as.list(drafts)), "model"))
  leaked = model_names_in(paste(p$system, p$user), ids)
  if (length(leaked))
    return(failed(paste0("A model's name (", paste(leaked, collapse = ", "), ") is in the ",
                         "appraisal prompt, so it was not sent: the appraisal must not ",
                         "know who wrote which candidate."), p))

  r = call_model(ask, p$user, pm, p$system, LLM_MAX_TOKENS[["appraisal"]],
                 reply_validator("appraisal"), "appraisal")
  with_call(list(status = r$status, error = r$error, labels = labels, system = p$system,
                 user = p$user, hash = p$hash, reply = r$reply), r$call)
}


# ---- the run log -------------------------------------------------------------------------------

# One row per model call of a round: what ran, how it ended, how long, and what it
#   cost in tokens. First in the log, so it can be read without scrolling.
flow_summary <- function(brief = NULL, drafts = NULL, appraisal = NULL, pm = NULL, review = NULL) {
  row = function(step, model, x) {
    cl = attr(x, "call")
    list(step = step, model = model, status = x$status, seconds = cl$seconds %||% NA_real_,
         finish = cl$finish %||% NA_character_, attempts = cl$attempts %||% NA_integer_,
         tokens_in = cl$tokens$input %||% NA_real_, tokens_out = cl$tokens$output %||% NA_real_,
         error = x$error %||% NA_character_)
  }
  c(if (!is.null(brief)) list(row("brief check", pm$id %||% NA_character_, brief)),
    purrr::map(unname(as.list(drafts)), function(d) row("draft", d$model, d)),
    if (!is.null(appraisal)) list(row("appraisal", pm$id %||% NA_character_, appraisal)),
    if (!is.null(review)) list(row("review", pm$id %||% NA_character_, review)))
}

# A result's call record, from its attribute into a field, so it reaches the log.
with_call_field <- function(x) {
  if (!is.null(x)) x$call <- attr(x, "call")
  x
}

# A round, for the log: schema 1, the time, the form, then what each step returned.
#   The project manager's key and every worker's key are never in these lists, and
#   neither is a header: a call record holds no request. seed and the labels are
#   in it, so the shuffle can be reproduced.
flow_round <- function(form, pm = NULL, brief = NULL, drafts = NULL, appraisal = NULL,
                       seed = NA_integer_, kept = NULL, time = Sys.time(), review = NULL) {
  # JSON drops the names of a character vector, and the letters are the point of
  #   labels: letter -> model id, as a named list, keeps them.
  if (!is.null(appraisal)) appraisal$labels = as.list(appraisal$labels)
  brief = with_call_field(brief)
  appraisal = with_call_field(appraisal)
  review = with_call_field(review)
  list(schema = 1L, time = format(time, "%Y-%m-%dT%H:%M:%S%z"),
       summary = flow_summary(brief, drafts, appraisal, pm, review),
       form = form, seed = seed, brief = brief, review = review,
       prompt = attr(drafts, "prompt"),
       drafts = if (!is.null(drafts)) purrr::map(unname(as.list(drafts)), function(d) {
         d$call = attr(d, "call")
         d
       }),
       appraisal = appraisal, kept = kept)
}

# The log as JSON text. Nothing is written to disk here.
flow_log_json <- function(round)
  jsonlite::toJSON(round, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null",
                   force = TRUE)
