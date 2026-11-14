# llm_check.R: LIVE runs of QuestionR's model layer. Home only; tests/ is not deployed. Each makes
#   real calls and spends real money, so it does nothing until it is told what to run.
#
# From PowerShell, inside QuestionR/ (from Git Bash the keys look unset):
#   & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/llm_check.R review30
#
# The key comes from .Renviron (QUESTIONR_KEY, else ANTHROPIC_API_KEY) and is handed to llm_json()
#   here, the way the key box would; the app itself never reads the environment for it. No key is
#   written to a file.
#
#   review30  one review of tests/review_long_questionnaire.txt (30 questions): 4 part calls and
#             1 call on the whole. Writes tests/review30.json and tests/review30.md.
#   A model id after the mode measures another main model on the same questions:
#               tests/llm_check.R review30 <model id>
#   The 20-question test is tests/gold_test.R.

args <- commandArgs(trailingOnly = TRUE)
stopifnot("Run from inside QuestionR/" = file.exists("app.R") && dir.exists("tests"))
mode <- intersect(args, "review30")
if (length(mode) != 1L) {
  cat("tests/llm_check.R makes live calls and spends money. Nothing was called.\n",
      "Name review30 (5 calls), then optionally a model id.\n", sep = "")
  quit(status = 0)
}

app <- shiny::shinyAppDir(".")
invisible(app$serverFuncSource())
stopifnot("llm_check.R is for the home profile" = identical(APP_PROFILE, "home"))
key <- Sys.getenv("QUESTIONR_KEY", Sys.getenv("ANTHROPIC_API_KEY"))
if (!nzchar(key)) {
  cat("No call was made: neither QUESTIONR_KEY nor ANTHROPIC_API_KEY is set in .Renviron.\n")
  quit(status = 1)
}
m <- if (length(args) > match(mode, args)) utils::modifyList(APP_MODEL, list(id = args[[match(mode, args) + 1L]])) else APP_MODEL
scrub <- function(txt) gsub(key, "[key]", txt, fixed = TRUE)
ask_live <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
  llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens, validate = validate, key = key)
ask_all_live <- function(requests) llm_json_all(purrr::map(requests, function(r) c(r, list(key = key))))
say <- function(msg) cat(format(Sys.time(), "%H:%M:%S"), msg, "\n")
num <- function(x) if (is.null(x) || !length(x) || is.na(x)) "-" else format(round(as.numeric(x)), big.mark = ",")
review <- function(form) {
  started = Sys.time()
  rv = run_review(form, m, ask = ask_live, progress = say, ask_all = ask_all_live)
  c(rv, list(wall = as.numeric(difftime(Sys.time(), started, units = "secs"))))
}
call_lines <- function(rv)
  purrr::map_chr(rv$batches, function(b)
    paste0("| ", if (identical(b$kind, "instrument")) "whole" else paste0("part ", b$k), " | ", sprintf("%.0f", b$seconds %||% NA),
           " | ", num(b$tokens$input), " | ", num(b$tokens$cached_input), " | ", num(b$tokens$output),
           " | ", b$finish %||% "-", " | ", b$attempts %||% "-", " | ", b$status, " |"))


# ---- review30: the 30-question file ------------------------------------------------------

if (mode == "review30") {
  questionnaire <- paste(readLines(file.path("tests", "review_long_questionnaire.txt"), warn = FALSE), collapse = "\n")
  form <- list(task = "evaluate", research_question = "Household energy use, travel and quality of life",
               population = "Adults aged 18 and over living in England", modes = "web", questionnaire = questionnaire)
  rv <- review(form)
  writeLines(scrub(as.character(flow_log_json(c(flow_round(form, m, review = rv), list(wall = rv$wall))))),
             file.path("tests", "review30.json"), useBytes = TRUE)
  sh <- shape_review(rv)
  qs <- purrr::keep(sh$questions, function(q) q$reviewed)
  per <- function(level) purrr::map_int(qs, n_level, level = level)
  flags <- unlist(purrr::map(qs, "flags"), recursive = FALSE)
  flagged <- function(id) any(purrr::map_lgl(sh$questions, function(q) identical(q$id, id) && length(q$flags) > 0L))
  # Q5 and Q17 are in different parts, so only the call on the whole can see that their scales run
  #   in opposite directions.
  reversal <- any(purrr::map_lgl(sh$instrument, function(fl) all(c("Q5", "Q17") %in% fl$questions)))
  faults <- c(Q11 = flagged("Q11"), Q12 = flagged("Q12"), Q17 = flagged("Q17"), Q14 = flagged("Q14"), Q15 = flagged("Q15"),
              Q16 = flagged("Q16"), Q13 = flagged("Q13"), `Q5/Q17 scale reversal` = reversal)
  md <- c("# review30 (tests/llm_check.R review30)", "",
          paste0("Run ", format(Sys.time(), "%Y-%m-%d %H:%M"), ", model ", m$id, ", ", length(rv$batches), " calls, ",
                 sprintf("%.0f", rv$wall), " seconds by the clock. Status: ", rv$status, "."), "",
          "| Call | Seconds | Tokens in | Cached in | Tokens out | Finish | Attempts | Status |", "|---|---|---|---|---|---|---|---|",
          call_lines(rv), "",
          paste0("Flags per question: fix mean ", sprintf("%.2f", mean(per("fix"))), " (max ", max(per("fix")), "), consider mean ",
                 sprintf("%.2f", mean(per("consider"))), " (max ", max(per("consider")), ")."),
          paste0("Quotes found in the text: ", sum(purrr::map_lgl(flags, "found")), " of ", length(flags), "."),
          paste0("Calls that needed a repeat attempt: ", sum(purrr::map_lgl(rv$batches, function(b) isTRUE(b$attempts > 1L))), "."),
          unlist(purrr::imap(rv$batches, function(b, i) if (length(b$refused)) paste0("- call ", i, " refused: ", unlist(b$refused)))),
          paste0("Deliberate faults flagged at either level: ", sum(faults), " of ", length(faults), ": ",
                 paste0(names(faults), " ", ifelse(faults, "yes", "no"), collapse = "; "), "."), "",
          "Bottom line:", paste0("> ", bottom_line(sh)), "",
          if (!identical(rv$status, "ok")) c("Errors:", rv$error))
  writeLines(scrub(md), file.path("tests", "review30.md"), useBytes = TRUE)
  cat(scrub(md), sep = "\n")
  quit(status = if (identical(rv$status, "ok")) 0L else 1L)
}
