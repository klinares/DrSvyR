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
#   gold      each of the 27 items of tests/gold_items.csv reviewed alone (1 call each), shown the
#             question and its options and nothing else (asserted before every call). Writes the
#             flags to a new folder in tests/gold_runs/ (named by date, time and model) and does not match them to the known
#             problems; that is done in the Claude project. An item already saved is skipped.
#   A model id after the mode measures another main model on the same questions:
#               tests/llm_check.R gold <model id>

args <- commandArgs(trailingOnly = TRUE)
stopifnot("Run from inside QuestionR/" = file.exists("app.R") && dir.exists("tests"))
mode <- intersect(args, c("review30", "gold"))
if (length(mode) != 1L) {
  cat("tests/llm_check.R makes live calls and spends money. Nothing was called.\n",
      "Name one of: review30 (5 calls) or gold (27 calls), then optionally a model id.\n", sep = "")
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
          paste0("Calls that needed a repeat attempt: ", sum(purrr::map_int(rv$batches, function(b) as.integer(b$attempts %||% 1L)) > 1L), "."),
          unlist(purrr::imap(rv$batches, function(b, i) if (length(b$refused)) paste0("- call ", i, " refused: ", unlist(b$refused)))),
          paste0("Deliberate faults flagged at either level: ", sum(faults), " of ", length(faults), ": ",
                 paste0(names(faults), " ", ifelse(faults, "yes", "no"), collapse = "; "), "."), "",
          "Bottom line:", paste0("> ", bottom_line(sh)), "",
          if (!identical(rv$status, "ok")) c("Errors:", rv$error))
  writeLines(scrub(md), file.path("tests", "review30.md"), useBytes = TRUE)
  cat(scrub(md), sep = "\n")
  quit(status = if (identical(rv$status, "ok")) 0L else 1L)
}


# ---- gold: the 27 items, each alone --------------------------------------------------------

if (mode == "gold") {
  lines <- readLines(file.path("tests", "gold_items.csv"), encoding = "UTF-8", warn = FALSE)
  gold <- utils::read.csv(text = lines[!startsWith(lines, "#")], colClasses = "character", na.strings = character(0))
  items <- unique(gold[, c("id", "set", "topic", "question", "scale", "scale_complete")])
  stopifnot("27 items expected" = nrow(items) == 27L)
  gdir <- file.path("tests", "gold_runs", paste0(format(Sys.time(), "%Y-%m-%d-%H%M"), "_", gsub("[^A-Za-z0-9.-]", "-", m$id)))
  dir.create(gdir, showWarnings = FALSE, recursive = TRUE)

  # The options line: the scale as printed, or only its two ends when the paper gives only those.
  shown_text <- function(r) {
    if (identical(r$scale_complete, "TRUE")) return(paste0("Q1. ", r$question, "\nResponse options: ", r$scale))
    ends <- strsplit(r$scale, " to ", fixed = TRUE)[[1]]
    stopifnot("an incomplete scale needs exactly two ends" = length(ends) == 2L)
    paste0("Q1. ", r$question, "\nResponse options: a scale running from ", ends[[1]], " to ", ends[[2]],
           " (the options in between are not shown in this test)")
  }
  # Nothing of the key may reach the model: without the question and its options, the prompt must
  #   hold no id, topic, problem id or problem text of this item.
  assert_blind <- function(user, r, shown) {
    rest <- gsub(shown, "", user, fixed = TRUE)
    probes <- purrr::keep(c(r$topic, gold$problem_id[gold$id == r$id], gold$problem[gold$id == r$id]), nzchar)
    hit <- c(purrr::keep(probes, function(p) grepl(tolower(p), tolower(rest), fixed = TRUE)),
             if (grepl(paste0("\\b", r$id, "\\b"), rest)) r$id)
    if (length(hit)) stop("The prompt for ", r$id, " holds key material: ", paste(hit, collapse = "; "))
  }
  rows <- purrr::map(split(items, seq_len(nrow(items))), function(r) {
    out <- file.path(gdir, paste0(r$id, ".json"))
    if (!file.exists(out)) {
      form <- list(task = "evaluate", research_question = "Evaluate this survey question",
                   population = "Adults in the general population", modes = "web", questionnaire = shown_text(r))
      assert_blind(build_step_prompt(form, "items", part = review_plan(form$questionnaire)[[1]])$user, r, shown_text(r))
      rv <- review(form)
      say(paste(r$id, rv$status))
      writeLines(scrub(as.character(flow_log_json(flow_round(form, m, review = rv)))), out, useBytes = TRUE)
    }
    rec <- jsonlite::fromJSON(out, simplifyVector = FALSE)
    b <- rec$review$batches[[1]]
    fl <- b$reply$items[[1]]$flags %||% list()
    list(call = data.frame(id = r$id, set = r$set, status = b$status, seconds = b$seconds %||% NA, tokens_in = b$tokens$input %||% NA,
                           tokens_out = b$tokens$output %||% NA, attempts = b$attempts %||% NA,
                           refused = paste(unlist(b$refused), collapse = " || "),
                           n_fix = sum(purrr::map_chr(fl, "level") == "fix"), n_consider = sum(purrr::map_chr(fl, "level") == "consider")),
         flags = if (length(fl)) data.frame(id = r$id, set = r$set, check = purrr::map_chr(fl, "check"), stage = purrr::map_chr(fl, "stage"),
                                            level = purrr::map_chr(fl, "level"), quote = purrr::map_chr(fl, "quote"),
                                            found = purrr::map_lgl(fl, function(x) quote_found(x$quote, shown_text(r))),
                                            why = purrr::map_chr(fl, "why"), rewrite = local({ rw = b$reply$items[[1]]$rewrite; if (is.list(rw)) doc_text(question_blocks(full_item(rw))) else "" })))
  })
  calls <- do.call(rbind, purrr::map(rows, "call"))
  flags <- do.call(rbind, purrr::compact(purrr::map(rows, "flags")))
  utils::write.csv(calls, file.path(gdir, "_calls.csv"), row.names = FALSE)
  utils::write.csv(flags, file.path(gdir, "_flags.csv"), row.names = FALSE)
  cat("\n", nrow(calls), " items, ", sum(calls$status == "ok"), " ok. Seconds per item ", sprintf("%.1f", mean(calls$seconds, na.rm = TRUE)),
      ", tokens in ", num(mean(calls$tokens_in, na.rm = TRUE)), " and out ", num(mean(calls$tokens_out, na.rm = TRUE)), " per item.\n",
      "Fix flags per flawed item ", sprintf("%.2f", mean(calls$n_fix[calls$set == "flawed"])),
      ", per control item ", sprintf("%.2f", mean(calls$n_fix[calls$set == "control"])), ".\n",
      "Flags written to ", gdir, "\n", sep = "")
}
