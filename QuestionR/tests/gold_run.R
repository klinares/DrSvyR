# gold_run.R -- LIVE gold test of the Evaluate review (DESIGN.md section 13, step
#   4e). Home only; deleted at work with the rest of tests/. It makes real calls
#   and spends real money, so it does nothing until it is told to.
#
# From PowerShell, inside QuestionR/ (from Git Bash the keys look unset):
#   & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/gold_run.R go
#
# What it does: reads tests/gold_items.csv (27 items: 20 flawed, 7 control; the
#   Claude project's transcription of Appendix B of Sturgis, Roberts and Robinson
#   2026, Survey Futures Working Paper 15) and reviews each item ALONE, as a
#   one-question questionnaire, through run_review() with the app's own ceiling:
#       Q1. <question>
#       Response options: <scale>
#   When scale_complete is FALSE the second line is
#       Response options: a scale running from <first> to <last> (the options in
#       between are not shown in this test)
#   The form is fixed: research question "Evaluate this survey question", population
#   "Adults in the general population", web, no country, English. The model sees the
#   questionnaire and the form and nothing else of the file: not the id (beyond "Q1"),
#   the topic, the set, nor any known problem. That is asserted before every call.
#
# What it keeps, in tests/gold_runs/: one file per item (<id>.json, the run log of
#   that review: prompt, raw reply, parsed reply, seconds, tokens; no API key and no
#   answer key in it), and two working tables for the builder's matching:
#   _calls.csv (one row per call) and _findings.csv (one row per finding).
#   An item that already has a file is skipped, so a run can be stopped and resumed;
#   a call cut off at its ceiling is recorded as it is and is not rerun (delete its
#   file by hand to try it again). Nothing here changes a skill, prompt or ceiling.

args <- commandArgs(trailingOnly = TRUE)
stopifnot("Run from inside QuestionR/" = file.exists("DESIGN.md"))

if (!"go" %in% args) {
  cat("tests/gold_run.R makes live calls and spends money. Nothing was called.\n",
      "  go   reviews the 27 gold items one at a time (27 calls to the project manager,\n",
      "       each may be repeated up to twice by llm_json() when a reply fails) and writes\n",
      "       tests/gold_runs/. Items already saved are skipped.\n", sep = "")
  quit(status = 0)
}

app <- shiny::shinyAppDir(".")
invisible(app$serverFuncSource())
stopifnot("gold_run.R is for the home profile" = identical(APP_PROFILE, "home"))

pm_key <- Sys.getenv("ANTHROPIC_API_KEY")
if (!nzchar(pm_key)) {
  cat("No call was made. ANTHROPIC_API_KEY is not set in .Renviron.\n")
  quit(status = 1)
}

dir <- file.path("tests", "gold_runs")
dir.create(dir, showWarnings = FALSE)

gold <- readr::read_csv(file.path("tests", "gold_items.csv"), comment = "#",
                        col_types = readr::cols(.default = readr::col_character()), na = character())
items <- dplyr::distinct(gold, id, set, topic, question, scale, scale_complete)
stopifnot("27 items expected" = nrow(items) == 27L)

GOLD_FORM <- list(task = "evaluate", research_question = "Evaluate this survey question",
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

secrets <- purrr::keep(c(pm_key, Sys.getenv("OPENROUTER_API_KEY")), nzchar)
scrub <- function(txt) purrr::reduce(secrets, function(t, s) gsub(s, "[key]", t, fixed = TRUE), .init = txt)

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
  out <- file.path(dir, paste0(row$id, ".json"))
  if (file.exists(out)) {
    cat(row$id, "already saved, skipped\n")
    return(invisible(NULL))
  }
  shown <- shown_text(row$question, row$scale, row$scale_complete)
  form <- modifyList(GOLD_FORM, list(questionnaire = shown))
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
  jsonlite::fromJSON(file.path(dir, paste0(id, ".json")), simplifyVector = FALSE))
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
readr::write_csv(calls, file.path(dir, "_calls.csv"))

findings <- purrr::imap_dfr(saved, function(r, id) {
  rv <- r$review
  if (!identical(rv$status, "ok")) return(NULL)
  df <- check_review(rv$reply, r$form)
  this_set <- items$set[items$id == id]
  dplyr::mutate(tibble::as_tibble(df[, c("scope", "check", "severity", "evidence", "evidence_found",
                                         "check_known", "stage", "problem", "rewrite", "probe", "shown")]),
                id = id, set = this_set, .before = 1)
})
readr::write_csv(findings, file.path(dir, "_findings.csv"))

cat("\n", nrow(calls), " items saved; ", sum(calls$status == "ok"), " ok, ", sum(calls$cut_off),
    " cut off, ", sum(calls$status != "ok" & !calls$cut_off), " other failures. ",
    nrow(findings), " findings, ", sum(findings$severity >= 5, na.rm = TRUE), " rated 5 or above.\n", sep = "")
cat("Seconds ", round(sum(calls$seconds, na.rm = TRUE)), ", tokens out ", sum(calls$tokens_out, na.rm = TRUE),
    ", tokens in ", sum(calls$tokens_in, na.rm = TRUE), ".\n", sep = "")
