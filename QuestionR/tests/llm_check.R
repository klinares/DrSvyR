# llm_check.R -- LIVE check of QuestionR's model layer. Home only; deleted at work
#   with the rest of tests/. It makes real calls and spends real money, so it does
#   nothing until it is told to: run it with the word "go" after the script name.
#
# From PowerShell, inside QuestionR/ (from Git Bash the keys look unset):
#   & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/llm_check.R go
#
# Keys come from .Renviron: OPENROUTER_API_KEY serves the three workers through
#   the app's own rule (key_source "server"); ANTHROPIC_API_KEY is handed to the
#   project manager's calls here directly, the way the key box would, because the
#   app itself never reads the environment for a pasted-key model.
#
# What it calls, in order (Phase 2; the brief check and the appraisal have no
#   prompt until Phase 3, which adds them here):
#   1. the connection check's call, once per model (four very small calls);
#   2. one drafting call per worker, the same real prompt from build_prompt(),
#      two items, shape-checked (three calls);
#   3. one small review by the project manager, a real Evaluate prompt on a
#      two-question questionnaire, shape-checked (one call).
#   Each call may be repeated up to twice by llm_json() when a reply fails.
#
# Writes tests/llm_check.out: per call, the model, the seconds, the attempts,
#   why the reply stopped, the tokens, whether the reply validated, and the first
#   300 characters of what came back. No key is written to it.

args <- commandArgs(trailingOnly = TRUE)
stopifnot("Run from inside QuestionR/" = file.exists("DESIGN.md"))

if (!"go" %in% args) {
  cat("tests/llm_check.R makes live calls and spends money. Nothing was called.\n",
      "It will make: 4 connection pings, 3 drafting calls (one per worker, 2 items),\n",
      "and 1 small review by the project manager. Run it again with the word go.\n", sep = "")
  quit(status = 0)
}

# Load the app the way Connect does, so R/ and its settings are in place.
app <- shiny::shinyAppDir(".")
invisible(app$serverFuncSource())
stopifnot("llm_check.R is for the home profile" = identical(APP_PROFILE, "home"))

pm_key <- Sys.getenv("ANTHROPIC_API_KEY")
models <- llm_models()


# ---- the two prompts, from the same function the app uses -----------------------

draft_form <- list(
  task = "attitudinal",
  research_question = "How much do adults trust the national electoral commission?",
  construct = "Trust in the national electoral commission",
  population = "Adults aged 18 and over", modes = "web", n_items = 2L)
review_form <- list(
  task = "evaluate",
  research_question = "Satisfaction with local services",
  population = "Adults aged 18 and over", modes = "paper",
  questionnaire = paste(
    "Q1. How satisfied or dissatisfied are you with the recycling services and street cleaning provided by your local council? Very satisfied / Fairly satisfied / Neither / Fairly dissatisfied / Very dissatisfied",
    "Q2. Taking all things together, how happy would you say you are? 0 Extremely unhappy ... 10 Extremely happy",
    sep = "\n"))
draft_prompt <- build_prompt(draft_form)
review_prompt <- build_prompt(review_form)


# ---- what "validated" means here --------------------------------------------------

# The shape DESIGN section 7 asks of a drafting reply, in the least that is
#   needed: the number of items asked for, each with a stem and either options or
#   an open format. R/checks.R brings the full validators in Phase 3.
draft_ok <- function(o) {
  items = o$items
  if (!is.list(items) || length(items) != draft_form$n_items)
    stop("expected exactly ", draft_form$n_items, " items, got ", length(items))
  bad = purrr::discard(items, function(it)
    nzchar(trimws(it$stem %||% "")) &&
      (length(it$options) > 0L || nzchar(trimws(it$open_format %||% ""))))
  if (length(bad)) stop(length(bad), " item(s) have no stem, or no options and no open_format")
  invisible(o)
}

# The fields evaluate.md's Output format names, and one entry per question.
review_ok <- function(o) {
  gone = setdiff(c("items", "instrument", "trapd", "test_first", "not_assessed"), names(o))
  if (length(gone)) stop("missing field(s): ", paste(gone, collapse = ", "))
  if (length(o$items) != 2L) stop("expected 2 items, got ", length(o$items))
  invisible(o)
}

# What the review's findings cited as their check, against the CHECKLIST sent.
# Informational, not a failure: it shows whether a model fills `check` with ids.
review_note <- function(o) {
  cited = unlist(purrr::map(o$items, function(it)
    purrr::map_chr(it$findings, function(f) as.character(f$check %||% ""))))
  sent = names(build_checklist(review_form))
  paste0("findings: ", length(cited), "; check ids not in the CHECKLIST sent: ",
         length(setdiff(cited, sent)))
}


# ---- one timed call, as a row ------------------------------------------------------

# run returns list(finish, tokens, text, note) or stops. Everything about the
#   call goes into one row, success or not.
timed <- function(role, step, m, run) {
  before = .llm_state$calls
  started = Sys.time()
  out = tryCatch(run(), error = function(e) e)
  failed = inherits(out, "error")
  list(role = role, model = m$id, step = step, ok = !failed,
       seconds = as.numeric(difftime(Sys.time(), started, units = "secs")),
       calls = .llm_state$calls - before,
       finish = if (failed) NA_character_ else out$finish %||% NA_character_,
       tokens = if (failed) NULL else out$tokens,
       note = if (failed) "" else out$note %||% "",
       text = if (failed)
         paste0("FAILED: ", conditionMessage(out),
                if (!is.null(out$raw)) paste0(" | reply: ", out$raw))
       else out$text)
}

not_run <- function(role, step, m, why)
  list(role = role, model = m$id, step = step, ok = FALSE, seconds = NA_real_,
       calls = 0L, finish = NA_character_, tokens = NULL, note = "",
       text = paste0("NOT RUN: ", why))

ping_run <- function(m, key) function() {
  r = llm_ping(m, key = key)
  if (!isTRUE(r$ok)) stop(r$message, call. = FALSE)
  list(text = r$reply)
}

json_run <- function(prompt, m, key, max_tokens, validate, note = NULL) function() {
  r = llm_json(prompt$user, m, system_prompt = prompt$system, max_tokens = max_tokens,
               validate = validate, key = key)
  list(finish = r$finish, tokens = r$tokens, text = r$raw,
       note = if (is.null(note)) "" else note(r$obj))
}

key_of <- function(x) if (identical(x$m$key_source, "analyst")) pm_key else llm_key_for(x$m)

rows <- c(
  purrr::map(models, function(x) {
    k = key_of(x)
    if (is.null(k) || !nzchar(k))
      not_run(x$role, "connection check", x$m, llm_key_hint(x$m))
    else timed(x$role, "connection check", x$m, ping_run(x$m, k))
  }),
  purrr::map(models[-1], function(x) {
    k = key_of(x)
    if (is.null(k) || !nzchar(k)) return(not_run(x$role, "draft, 2 items", x$m, llm_key_hint(x$m)))
    timed(x$role, "draft, 2 items", x$m,
          json_run(draft_prompt, x$m, k, LLM_MAX_TOKENS[["draft"]], draft_ok))
  }),
  list(if (!nzchar(pm_key))
    not_run(models[[1]]$role, "small review", models[[1]]$m, "ANTHROPIC_API_KEY is not set in .Renviron")
  else timed(models[[1]]$role, "small review", models[[1]]$m,
             json_run(review_prompt, models[[1]]$m, pm_key, LLM_MAX_TOKENS[["evaluate"]],
                      review_ok, review_note))))


# ---- the report --------------------------------------------------------------------

describe <- function(r) {
  tk = r$tokens
  c(sprintf("[%s] %s | %s | %s | %s | %s | finish: %s%s",
            if (r$ok) " OK " else "FAIL", r$role, r$model, r$step,
            if (is.na(r$seconds)) "not run" else sprintf("%.1f s", r$seconds),
            sprintf("%d call%s", r$calls, if (r$calls == 1L) "" else "s"),
            if (is.null(r$finish) || is.na(r$finish)) "-" else r$finish,
            if (is.null(tk)) "" else sprintf(" | tokens in %s out %s", tk[["input"]], tk[["output"]])),
    if (nzchar(r$note)) paste0("      ", r$note),
    paste0("      reply (first 300): ", substr(gsub("\\s+", " ", r$text), 1, 300)))
}

green <- all(purrr::map_lgl(rows, "ok"))
report <- c(
  "QuestionR live check (tests/llm_check.R)",
  paste0("Run: ", format(Sys.time(), "%Y-%m-%d %H:%M"), " | profile: ", APP_PROFILE,
         " | ellmer ", as.character(utils::packageVersion("ellmer"))),
  paste0("Draft prompt hash:  ", draft_prompt$hash),
  paste0("Review prompt hash: ", review_prompt$hash),
  "", unlist(purrr::map(rows, describe)), "",
  paste0("ALL GREEN: ", green, "  (", sum(purrr::map_lgl(rows, "ok")), " of ", length(rows), " calls)"))

# A key must never reach the file, even inside an error message from an endpoint.
secrets <- purrr::keep(c(pm_key, Sys.getenv("OPENROUTER_API_KEY")), nzchar)
report <- purrr::reduce(secrets, function(txt, s) gsub(s, "[key]", txt, fixed = TRUE), .init = report)

writeLines(report, file.path("tests", "llm_check.out"), useBytes = TRUE)
cat(report, sep = "\n")
quit(status = if (green) 0L else 1L)
