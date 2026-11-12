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

#
# Phase 3 adds a second run, `go generate`, which runs the Generate engine live
#   instead: a brief check, a 3-item attitudinal draft by every worker, and the
#   appraisal, through run_brief(), run_drafts() and run_appraisal() exactly as
#   the screens call them (5 requests; each may be repeated up to twice by
#   llm_json() when a reply fails). It writes tests/run_generate.json, the run
#   log: the summary of every call first (seconds, tokens, why it stopped), then
#   the form, the prompts, the raw and parsed replies and R's checks. No key is
#   written to it.
#     & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/llm_check.R go generate

args <- commandArgs(trailingOnly = TRUE)
stopifnot("Run from inside QuestionR/" = file.exists("DESIGN.md"))

if (!"go" %in% args) {
  cat("tests/llm_check.R makes live calls and spends money. Nothing was called.\n",
      "  go            4 connection pings, 3 drafting calls (one per worker, 2 items),\n",
      "                and 1 small review by the project manager.\n",
      "  go generate   the Generate engine: 1 brief check, 3 drafting calls (3 items),\n",
      "                and 1 appraisal; writes tests/run_generate.json.\n",
      "  go review15   one review of the 15-question test questionnaire, to measure its\n",
      "                tokens; writes tests/review_tokens.md and tests/review15_run.json.\n",
      "  go review30   one review of the 30-question test questionnaire (tests/review_long_questionnaire.txt),\n",
      "                in parts: one call for each part and one for the instrument as a whole; writes\n",
      "                tests/review_long.md and tests/review_long.json. Nothing is raised for it.\n",
      "Run it again with the word go, and generate, review15 or review30 if you want one of those.\n", sep = "")
  quit(status = 0)
}

# Load the app the way Connect does, so R/ and its settings are in place.
app <- shiny::shinyAppDir(".")
invisible(app$serverFuncSource())
stopifnot("llm_check.R is for the home profile" = identical(APP_PROFILE, "home"))

pm_key <- Sys.getenv("ANTHROPIC_API_KEY")
models <- llm_models()


# ---- go review15: how many tokens a 15-question review takes (Phase 4d) -------------

if ("review15" %in% args) {
  if (!nzchar(pm_key)) {
    cat("No call was made. ANTHROPIC_API_KEY is not set in .Renviron.\n")
    quit(status = 1)
  }
  questionnaire <- paste(readLines(file.path("tests", "review_questionnaire.txt"), warn = FALSE), collapse = "\n")
  n_questions <- length(grep("^Q[0-9]+\\.", strsplit(questionnaire, "\n", fixed = TRUE)[[1]]))
  form <- list(task = "evaluate", research_question = "Satisfaction with and use of local council services",
               construct = "", population = "Adults aged 18 and over living in the council area",
               country = "", modes = "web", output_language = "English", source_language = "English",
               n_items = NA_integer_, reference_period = "", keep_items = "", other = "",
               questionnaire = questionnaire, revision = "")

  # The measurement is made with a ceiling well above what the review is expected
  #   to need, so that it is not cut off and the tokens it really takes are seen.
  #   This changes the ceiling in this process only; the app's is set from the result.
  measuring_ceiling <- 24000L
  LLM_MAX_TOKENS[["evaluate"]] <- measuring_ceiling
  ask_live <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens,
             validate = validate, key = pm_key)
  rv <- run_review(form, APP_MODELS$pm, ask = ask_live)
  cl <- attr(rv, "call")
  flags <- if (identical(rv$status, "ok")) check_review(rv$reply, form)
  tk_in <- cl$tokens$input %||% NA_real_
  tk_out <- cl$tokens$output %||% NA_real_

  secrets <- purrr::keep(c(pm_key, Sys.getenv("OPENROUTER_API_KEY")), nzchar)
  scrub <- function(txt) purrr::reduce(secrets, function(t, s) gsub(s, "[key]", t, fixed = TRUE), .init = txt)
  writeLines(scrub(as.character(flow_log_json(flow_round(form, APP_MODELS$pm, review = rv)))),
             file.path("tests", "review15_run.json"), useBytes = TRUE)

  ceiling_for_app <- if (is.na(tk_out)) NA_integer_ else as.integer(ceiling(2 * tk_out / 1000) * 1000)
  cap_for_app <- as.integer(ceiling(2 * nchar(questionnaire) / 1000) * 1000)
  md <- c(
    "# Token measurement: one 15-question review (tests/llm_check.R go review15)", "",
    paste0("Run: ", format(Sys.time(), "%Y-%m-%d %H:%M"), " | profile: ", APP_PROFILE),
    paste0("Model: ", APP_MODELS$pm$id, " | prompt hash ", rv$hash %||% "-"),
    paste0("Questionnaire: tests/review_questionnaire.txt, written for this test: ", n_questions,
           " questions, ", nchar(questionnaire), " characters."),
    paste0("Form: research question \"", form$research_question, "\", population \"", form$population,
           "\", mode web, no country, English."),
    paste0("Ceiling used for this measurement: ", measuring_ceiling, " tokens (the app's was 8000 until this run)."), "",
    "| Seconds | Tokens in | Tokens out | Finish | Attempts | Status |", "|---|---|---|---|---|---|",
    paste0("| ", sprintf("%.1f", cl$seconds %||% NA_real_), " | ", tk_in, " | ", tk_out, " | ", cl$finish %||% "-",
           " | ", cl$attempts %||% "-", " | ", rv$status, " |"), "",
    if (!identical(rv$status, "ok")) paste0("The review failed: ", rv$error)
    else c(paste0("Findings: ", nrow(flags), " in all, ", sum(flags$shown), " rated 5 or above; ",
                  sum(flags$scope == "instrument"), " about the instrument. R's checks: ",
                  sum(!flags$evidence_found, na.rm = TRUE), " quotes not found, ", sum(!flags$check_known),
                  " checks not sent.")),
    "",
    "## Settings this implies",
    "",
    paste0("About twice what it used: an evaluation ceiling of ", ceiling_for_app, " tokens. ",
           "The paste cap to match, about twice the characters of this questionnaire: ", cap_for_app, " characters."),
    "")
  writeLines(scrub(md), file.path("tests", "review_tokens.md"), useBytes = TRUE)
  cat(scrub(md), sep = "\n")
  quit(status = if (identical(rv$status, "ok")) 0L else 1L)
}



# ---- go review30: one live long review, in parts (Phase 5e) --------------------------------

if ("review30" %in% args) {
  if (!nzchar(pm_key)) {
    cat("No call was made. ANTHROPIC_API_KEY is not set in .Renviron.\n")
    quit(status = 1)
  }
  questionnaire <- paste(readLines(file.path("tests", "review_long_questionnaire.txt"), warn = FALSE), collapse = "\n")
  form <- list(task = "evaluate", research_question = "Household energy use, travel and quality of life",
               construct = "", population = "Adults aged 18 and over living in England",
               country = "", modes = "web", output_language = "English", source_language = "English",
               n_items = NA_integer_, reference_period = "", keep_items = "", other = "",
               questionnaire = questionnaire, revision = "")
  f <- clean_form(form)
  plan <- review_plan(f$questionnaire, APP_BATCH_CHARS)
  n_questions <- length(grep("^Q[0-9]+\\.", strsplit(questionnaire, "\n", fixed = TRUE)[[1]]))

  ask_live <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens,
             validate = validate, key = pm_key)
  say <- function(msg) cat(format(Sys.time(), "%H:%M:%S"), msg, "\n")
  # The app's own ceiling and batch size: nothing is raised for this run.
  rv <- run_review(form, APP_MODELS$pm, ask = ask_live, progress = say)
  flags <- if (!is.null(rv$reply)) check_review(rv$reply, f)

  secrets <- purrr::keep(c(pm_key, Sys.getenv("OPENROUTER_API_KEY")), nzchar)
  scrub <- function(txt) purrr::reduce(secrets, function(t, s) gsub(s, "[key]", t, fixed = TRUE), .init = txt)
  writeLines(scrub(as.character(flow_log_json(flow_round(f, APP_MODELS$pm, review = rv)))),
             file.path("tests", "review_long.json"), useBytes = TRUE)

  num <- function(x) if (is.null(x) || is.na(x)) "-" else format(round(x), big.mark = ",")
  rows <- purrr::map_chr(rv$batches, function(b)
    paste0("| ", if (identical(b$kind, "instrument")) "instrument" else paste0("part ", b$part, " of ", b$n_parts),
           " | ", if (identical(b$kind, "instrument")) nchar(questionnaire) else b$chars,
           " | ", sprintf("%.1f", b$seconds %||% NA_real_), " | ", num(b$tokens$input), " | ", num(b$tokens$output),
           " | ", b$finish %||% "-", " | ", b$attempts %||% "-", " | ", b$status, " |"))
  failed <- purrr::keep(rv$batches, function(b) !identical(b$status, "ok"))
  q <- if (!is.null(flags)) flags[flags$scope == "question", ]
  bands <- if (!is.null(flags)) table(factor(severity_band(flags$severity), levels = names(SEVERITY_BANDS)))
  ids_back <- purrr::map_chr(rv$reply$items %||% list(), function(it) paste(unlist(it$id), collapse = " "))
  expect_ids <- regmatches(questionnaire, gregexpr("(?m)^Q[0-9]+(?=\\. )", questionnaire, perl = TRUE))[[1]]
  item_calls <- purrr::keep(rv$batches, function(b) identical(b$kind, "items") && !is.null(b$reply))
  strays <- purrr::map_int(item_calls, function(b)
    length(b$reply$instrument) + length(b$reply$test_first) +
      sum(nzchar(trimws(unlist(b$reply$trapd)))) + nzchar(trimws(paste(unlist(b$reply$not_assessed), collapse = ""))))
  inst_call <- purrr::detect(rv$batches, function(b) identical(b$kind, "instrument") && !is.null(b$reply))
  inst_items <- if (!is.null(inst_call)) length(inst_call$reply$items) else NA_integer_
  total_s <- sum(purrr::map_dbl(rv$batches, function(b) b$seconds %||% 0))
  tot_in <- sum(purrr::map_dbl(rv$batches, function(b) as.numeric(b$tokens$input %||% 0)))
  tot_out <- sum(purrr::map_dbl(rv$batches, function(b) as.numeric(b$tokens$output %||% 0)))

  md <- c(
    "# One live long review, in parts (tests/llm_check.R go review30)", "",
    paste0("Run: ", format(Sys.time(), "%Y-%m-%d %H:%M"), " | profile: ", APP_PROFILE),
    paste0("Model: ", APP_MODELS$pm$id, " | evaluation ceiling ", LLM_MAX_TOKENS[["evaluate"]],
           " tokens a call, batch size ", APP_BATCH_CHARS, " characters, paste cap ", APP_MAX_PASTE_CHARS, "; none was changed for this run."),
    paste0("Questionnaire: tests/review_long_questionnaire.txt, written for this test: ", n_questions,
           " questions in ", length(strsplit(questionnaire, "\n\n", fixed = TRUE)[[1]]), " blocks, ", nchar(questionnaire), " characters."),
    paste0("Form: research question \"", form$research_question, "\", population \"", form$population, "\", mode web, no country, English."),
    paste0("Parts: ", length(plan) - 1L, " (first blocks ", paste(purrr::map_int(plan[seq_len(length(plan) - 1L)], "first_block"), collapse = ", "),
           "), so ", length(plan), " calls: one for each part and one for the instrument as a whole."), "",
    "| Call | Characters | Seconds | Tokens in | Tokens out | Finish | Attempts | Status |", "|---|---|---|---|---|---|---|---|",
    rows, "",
    paste0("Total: ", sprintf("%.0f", total_s), " seconds (", sprintf("%.1f", total_s / 60), " minutes), ",
           format(tot_in, big.mark = ","), " tokens in, ", format(tot_out, big.mark = ","), " tokens out. Result status: ", rv$status, "."),
    "",
    if (!length(failed)) "Failed parts: none."
    else c("Failed parts:", purrr::map_chr(failed, function(b) paste0("- ", if (identical(b$kind, "instrument")) "the instrument call" else paste0("part ", b$part),
                                                                     ": ", b$error))),
    "",
    if (!is.null(flags)) c(
      paste0("Findings: ", nrow(flags), " in all: ", nrow(q), " about questions and ", sum(flags$scope == "instrument"), " about the instrument."),
      paste0("By band: Fix before fielding ", bands[["fix"]], ", Needs your judgment ", bands[["judgment"]], ", Minor ", bands[["minor"]], "."),
      paste0("**Share of question findings whose evidence was found in the pasted text: ", sum(q$evidence_found, na.rm = TRUE), " of ", nrow(q), " (",
             sprintf("%.1f", 100 * mean(q$evidence_found, na.rm = TRUE)), "%).** Phase 4's gold run found 55 of 100 (45 had evidence that was a description)."),
      if (any(!q$evidence_found)) c("Evidence not found in the text:", paste0("- ", q$item[!q$evidence_found], ", ", q$check[!q$evidence_found], ": ", q$evidence[!q$evidence_found])),
      paste0("Checks not in the checklist that was sent: ", sum(!flags$check_known), "."),
      paste0("Questions back: ", length(ids_back), " of ", n_questions, "; ids ", if (identical(ids_back, expect_ids)) "exactly as pasted, in order" else
               paste0("differ from the pasted ones. Missing: ", paste(setdiff(expect_ids, ids_back), collapse = ", "),
                      "; extra or repeated: ", paste(ids_back[!ids_back %in% expect_ids | duplicated(ids_back)], collapse = ", ")), "."),
      paste0("Item calls that filled fields they were told to leave empty (instrument, test_first, trapd, not_assessed): ",
             sum(strays > 0L), " of ", length(item_calls), if (length(strays)) paste0(" (", paste(strays, collapse = ", "), " entries)") else "", "."),
      paste0("The instrument call returned ", inst_items, " question entries (it was told to leave items empty).")),
    "")
  writeLines(scrub(md), file.path("tests", "review_long.md"), useBytes = TRUE)
  cat(scrub(md), sep = "\n")
  quit(status = if (identical(rv$status, "ok")) 0L else 1L)
}


# ---- go generate: the Generate engine, live ---------------------------------------

if ("generate" %in% args) {
  gen_form <- list(
    task = "attitudinal",
    research_question = "How much do adults trust the national electoral commission?",
    construct = "Trust in the national electoral commission",
    population = "Adults aged 18 and over", country = "", modes = "web",
    output_language = "English", source_language = "English", n_items = 3L,
    reference_period = "", keep_items = "", other = "", questionnaire = "", revision = "")

  # The key box's key for the project manager; the environment variable named in
  #   key_var for a worker. Both are handed to llm_json() here, outside the engine,
  #   which never looks up a key.
  key_for_model <- function(m)
    if (identical(m$key_source, "analyst")) pm_key else llm_key_for(m)
  missing_keys <- purrr::keep(models, function(x) !nzchar(key_for_model(x$m) %||% ""))
  if (length(missing_keys)) {
    cat("No call was made. No key for: ",
        paste(purrr::map_chr(missing_keys, function(x) x$m$id), collapse = ", "), "\n", sep = "")
    quit(status = 1)
  }
  ask_live <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens,
             validate = validate, key = key_for_model(m))

  seed <- 20261111L
  brief <- run_brief(gen_form, APP_MODELS$pm, ask = ask_live)
  drafts <- run_drafts(gen_form, APP_MODELS$workers, ask = ask_live)
  appraisal <- run_appraisal(gen_form, drafts, APP_MODELS$pm, ask = ask_live, seed = seed)

  cands <- candidates_of(drafts, seed)
  checklist <- build_checklist(gen_form)
  chk <- if (identical(appraisal$status, "ok")) check_appraisal(appraisal$reply, cands, checklist)
  coded <- purrr::imap(cands, function(reply, letter)
    purrr::map(unname(reply$items), function(it)
      c(list(id = it$id %||% ""), code_defaults(it, gen_form$output_language))))

  round <- flow_round(gen_form, APP_MODELS$pm, brief = brief, drafts = drafts,
                      appraisal = appraisal, seed = seed)
  round$profile <- APP_PROFILE
  round$labels <- as.list(labels_of(drafts, seed))
  round$r_checks <- list(
    appraisal = if (!is.null(chk)) list(unknown_checks = as.list(chk$unknown_checks),
                                         not_appraised = as.list(chk$not_appraised),
                                         unknown_items = as.list(chk$unknown_items),
                                         merged_problems = as.list(chk$merged_problems),
                                         fails_reported = length(chk$fails)),
    coded_defaults = coded)

  # A key must never reach the file, even inside an error message from an endpoint.
  secrets <- purrr::keep(c(pm_key, Sys.getenv("OPENROUTER_API_KEY")), nzchar)
  log_txt <- purrr::reduce(secrets, function(txt, s) gsub(s, "[key]", txt, fixed = TRUE),
                           .init = as.character(flow_log_json(round)))
  writeLines(log_txt, file.path("tests", "run_generate.json"), useBytes = TRUE)

  rows <- flow_summary(brief, drafts, appraisal, APP_MODELS$pm)
  cat("QuestionR live run of the Generate engine (tests/llm_check.R go generate)\n",
      "Run: ", format(Sys.time(), "%Y-%m-%d %H:%M"), " | profile: ", APP_PROFILE, " | seed ", seed, "\n",
      "Brief prompt hash:     ", brief$hash %||% "-", "\n",
      "Work prompt hash:      ", attr(drafts, "prompt")$hash, "\n",
      "Appraisal prompt hash: ", appraisal$hash %||% "-", "\n\n", sep = "")
  cat(purrr::map_chr(rows, function(r)
    sprintf("[%s] %-12s %-34s %6.1f s  in %s out %s  finish %s  attempts %s%s",
            if (identical(r$status, "ok")) " OK " else "FAIL", r$step, r$model,
            r$seconds %||% NA_real_, r$tokens_in %||% "-", r$tokens_out %||% "-",
            r$finish %||% "-", r$attempts %||% "-",
            if (!identical(r$status, "ok")) paste0("\n      ", r$error) else "")), sep = "\n")
  if (!is.null(chk))
    cat("\nR's checks on the appraisal: ", length(chk$fails), " fails reported; ",
        length(chk$unknown_checks), " unknown check ids; ", length(chk$not_appraised),
        " items not appraised; ", length(chk$unknown_items), " entries for no item; ",
        length(chk$merged_problems), " merged-option problems.\n", sep = "")
  statuses <- c(brief$status, purrr::map_chr(unname(as.list(drafts)), "status"), appraisal$status)
  cat("\nALL OK: ", all(statuses == "ok"), "  (", sum(statuses == "ok"), " of ", length(statuses),
      " steps)\nLog written to tests/run_generate.json\n", sep = "")
  quit(status = if (all(statuses == "ok")) 0L else 1L)
}


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
