# llm_check.R -- LIVE runs of QuestionR's model layer. Home only; deleted at work with
#   the rest of tests/. Each makes real calls and spends real money, so it does
#   nothing until it is told what to run, by a word after the script name.
#
# From PowerShell, inside QuestionR/ (from Git Bash the keys look unset):
#   & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/llm_check.R generate
#
# Keys come from .Renviron: OPENROUTER_API_KEY serves the three workers through the
#   app's own rule (key_source "server"); ANTHROPIC_API_KEY is handed to the project
#   manager's calls here directly, the way the key box would, because the app itself
#   never reads the environment for a pasted-key model. No key is written to a file.
#
#   generate  the Generate engine: a brief check, a 3-item attitudinal draft by every
#             worker and the appraisal (5 requests, each repeated up to twice when a
#             reply fails); writes tests/run_generate.json.
#   review30  one review of tests/review_long_questionnaire.txt (30 questions), in
#             parts: one call for each part and one for the instrument as a whole;
#             writes tests/review_long.md and tests/review_long.json.
#   gold      the gold test of tests/gold_items.csv: each of its 27 items reviewed alone,
#             the model shown the question and its options and nothing else (asserted
#             before every call); raw replies in tests/gold_runs/, one file an item,
#             and an item that has a file is skipped. Matching the findings to the
#             known problems is done by hand afterwards.

args <- commandArgs(trailingOnly = TRUE)
stopifnot("Run from inside QuestionR/" = file.exists("DESIGN.md"))

if (!any(c("generate", "review30", "gold") %in% args)) {
  cat("tests/llm_check.R makes live calls and spends money. Nothing was called.\n",
      "Name what to run: generate (5 calls), review30 (3 calls) or gold (27 calls).\n", sep = "")
  quit(status = 0)
}


# Load the app the way Connect does, so R/ and its settings are in place.
app <- shiny::shinyAppDir(".")
invisible(app$serverFuncSource())
stopifnot("llm_check.R is for the home profile" = identical(APP_PROFILE, "home"))

pm_key <- Sys.getenv("ANTHROPIC_API_KEY")
models <- llm_models()

# A key must never reach a file, even inside an error message from an endpoint.
secrets <- purrr::keep(c(pm_key, Sys.getenv("OPENROUTER_API_KEY")), nzchar)
scrub <- function(txt) purrr::reduce(secrets, function(t, s) gsub(s, "[key]", t, fixed = TRUE), .init = txt)


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

  writeLines(scrub(as.character(flow_log_json(round))), file.path("tests", "run_generate.json"), useBytes = TRUE)

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



# ---- go gold: the gold test, one review for each of the 27 items (Phase 4e) -----------

if ("gold" %in% args) {
  if (!nzchar(pm_key)) {
    cat("No call was made. ANTHROPIC_API_KEY is not set in .Renviron.\n")
    quit(status = 1)
  }
  gdir <- file.path("tests", "gold_runs")
  dir.create(gdir, showWarnings = FALSE)

  gold <- readr::read_csv(file.path("tests", "gold_items.csv"), comment = "#",
                          col_types = readr::cols(.default = readr::col_character()), na = character())
  items <- dplyr::distinct(gold, id, set, topic, question, scale, scale_complete)
  stopifnot("27 items expected" = nrow(items) == 27L)

  gold_form <- list(task = "evaluate", research_question = "Evaluate this survey question",
                    construct = "", population = "Adults in the general population",
                    country = "", modes = "web", output_language = "English", source_language = "English",
                    n_items = NA_integer_, reference_period = "", keep_items = "", other = "",
                    questionnaire = "", revision = "")

  # The options line: the scale as printed, or only its two ends when the paper gives
  #   only those (always exactly one " to " in that case; checked when the file was read).
  options_line <- function(scale, complete) {
    if (identical(complete, "TRUE")) return(paste0("Response options: ", scale))
    ends <- strsplit(scale, " to ", fixed = TRUE)[[1]]
    stopifnot("an incomplete scale needs exactly two ends" = length(ends) == 2L)
    paste0("Response options: a scale running from ", ends[[1]], " to ", ends[[2]],
           " (the options in between are not shown in this test)")
  }
  shown_text <- function(question, scale, complete)
    paste0("Q1. ", question, "\n", options_line(scale, complete))


  ask_live <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens,
             validate = validate, key = pm_key)

  # Nothing of the key may reach the model: take away the question and the options
  #   line, and what is left of the prompt must hold no id, set, topic, problem id
  #   or problem text of this item. (The problem types are words of the checklist
  #   every review is sent, so they cannot be probed for.)
  assert_blind <- function(user, row, shown) {
    rest <- gsub(shown, "", user, fixed = TRUE)
    fixed_probes <- purrr::keep(c(row$topic, gold$problem_id[gold$id == row$id],
                                  gold$problem[gold$id == row$id], paste0(row$set, " item")), nzchar)
    hit <- c(purrr::keep(fixed_probes, function(p) grepl(tolower(p), tolower(rest), fixed = TRUE)),
             if (grepl(paste0("\\b", row$id, "\\b"), rest)) row$id)
    if (length(hit)) stop("The prompt for ", row$id, " holds key material: ", paste(hit, collapse = "; "))
    invisible(TRUE)
  }

  run_one <- function(row) {
    out <- file.path(gdir, paste0(row$id, ".json"))
    if (file.exists(out)) {
      cat(row$id, "already saved, skipped\n")
      return(invisible(NULL))
    }
    shown <- shown_text(row$question, row$scale, row$scale_complete)
    form <- modifyList(gold_form, list(questionnaire = shown))
    p <- build_step_prompt(form, "work")
    assert_blind(p$user, row, shown)
    cat(row$id, "calling ... ")
    rv <- run_review(form, APP_MODELS$pm, ask = ask_live)
    cl <- attr(rv, "call")
    cat(rv$status, sprintf("%.0f s", cl$seconds %||% NA_real_), "\n")
    writeLines(scrub(as.character(flow_log_json(flow_round(form, APP_MODELS$pm, review = rv)))),
               out, useBytes = TRUE)
    invisible(NULL)
  }

  purrr::walk(split(items, seq_len(nrow(items))), run_one)

  # The working tables, from the saved files only (so a resumed run is complete).
  saved <- purrr::map(items$id, function(id)
    jsonlite::fromJSON(file.path(gdir, paste0(id, ".json")), simplifyVector = FALSE))
  names(saved) <- items$id

  calls <- purrr::imap_dfr(saved, function(r, id) {
    rv <- r$review
    cl <- rv$call
    tibble::tibble(id = id, set = items$set[items$id == id], status = rv$status,
                   seconds = cl$seconds %||% NA_real_, tokens_in = cl$tokens$input %||% NA_real_,
                   tokens_out = cl$tokens$output %||% NA_real_, finish = cl$finish %||% NA_character_,
                   attempts = cl$attempts %||% NA_integer_,
                   cut_off = grepl("reached the token limit", rv$error %||% "", fixed = TRUE),
                   error = rv$error %||% NA_character_)
  })
  readr::write_csv(calls, file.path(gdir, "_calls.csv"))

  findings <- purrr::imap_dfr(saved, function(r, id) {
    rv <- r$review
    if (!identical(rv$status, "ok")) return(NULL)
    df <- check_review(rv$reply, r$form)
    this_set <- items$set[items$id == id]
    dplyr::mutate(tibble::as_tibble(df[, c("scope", "check", "severity", "evidence", "evidence_found",
                                           "check_known", "stage", "problem", "rewrite", "probe", "shown")]),
                  id = id, set = this_set, .before = 1)
  })
  readr::write_csv(findings, file.path(gdir, "_findings.csv"))

  cat("\n", nrow(calls), " items saved; ", sum(calls$status == "ok"), " ok, ", sum(calls$cut_off),
      " cut off, ", sum(calls$status != "ok" & !calls$cut_off), " other failures. ",
      nrow(findings), " findings, ", sum(findings$severity >= 5, na.rm = TRUE), " rated 5 or above.\n", sep = "")
  cat("Seconds ", round(sum(calls$seconds, na.rm = TRUE)), ", tokens out ", sum(calls$tokens_out, na.rm = TRUE),
      ", tokens in ", sum(calls$tokens_in, na.rm = TRUE), ".\n", sep = "")
}
