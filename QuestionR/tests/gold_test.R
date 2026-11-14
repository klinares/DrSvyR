# gold_test.R: the 20-question test of the Evaluate reviewer, at home or at work.
#
# What it does: reviews 27 test questions (20 with 48 planted faults, 7 well-tested ones) one at a
#   time, the way the Evaluate tab does (27 calls); asks the main model, in a separate chat, which
#   flag describes which planted fault (20 calls); counts what was found; and writes
#   www/gold_summary.md (the paragraph on the Methodology page) and a summary.md in the run folder.
#
# Run it from inside QuestionR/, in R or from a shell:
#   Rscript --no-init-file tests/gold_test.R
# The key comes from the environment variable QUESTIONR_KEY; when it is not set, the script asks
#   for it at the console. It is held in memory and never written anywhere.
#
# To correct the matching by hand: open matches.csv in the run folder, change `match` where the
#   model was wrong ("exact", "approximate" or "none"; for a new match also fill in flag_check,
#   flag_level and flag_why from flags.csv), put your name in `checked_by` on every row you
#   checked, set both switches below to FALSE and run the script again. It rebuilds the two
#   summaries from the files, with no calls.

PROFILE      <- "home"   # the profile in app.R to test ("work" at work)
RUN_REVIEWS  <- TRUE     # FALSE: reuse the flags of the latest run folder
RUN_MATCHING <- TRUE     # FALSE: reuse matches.csv as it stands (after a person has corrected it)


# 1. Load the app's functions with the chosen profile, and read the test questions. The questions
#    and their planted faults are from Sturgis, Roberts and Robinson (2026), Appendix B.
stopifnot("Run this from inside QuestionR/" = file.exists("app.R") && dir.exists("tests"))
Sys.setenv(QUESTIONR_PROFILE = PROFILE)
app <- shiny::shinyAppDir(".")
invisible(app$serverFuncSource())
m <- APP_MODEL
lines <- readLines(file.path("tests", "gold_items.csv"), encoding = "UTF-8", warn = FALSE)
gold <- utils::read.csv(text = lines[!startsWith(lines, "#")], colClasses = "character")
faults <- gold |> dplyr::filter(set == "flawed")
stopifnot("48 planted faults expected" = nrow(faults) == 48L)

# Each question as the reviewer sees it: the question and its options. Where the paper prints only
#   the two ends of a scale, the reviewer is told that the options in between are not shown.
items <- gold |>
  dplyr::distinct(id, set, question, scale, scale_complete) |>
  dplyr::mutate(shown = ifelse(scale_complete == "TRUE",
                               paste0("Q1. ", question, "\nResponse options: ", scale),
                               paste0("Q1. ", question, "\nResponse options: a scale running from ", sub(" to .*$", "", scale),
                                      " to ", sub("^.* to ", "", scale), " (the options in between are not shown in this test)")))
stopifnot("27 questions expected" = nrow(items) == 27L, "7 well-tested questions expected" = sum(items$set == "control") == 7L)

# The key, only when a call will be made.
key <- Sys.getenv("QUESTIONR_KEY")
if (!nzchar(key) && (RUN_REVIEWS || RUN_MATCHING))
  key <- if (requireNamespace("askpass", quietly = TRUE)) askpass::askpass("QuestionR key: ") else readline("QuestionR key: ")
say <- function(msg) cat(format(Sys.time(), "%H:%M:%S"), msg, "\n")
ask_all <- function(requests) llm_json_all(purrr::map(requests, function(r) c(r, list(key = key))))


# 2. Review each question alone, four at a time, through send_parts(), which the Evaluate tab uses
#    for every review. What comes back is saved to reviews.json at once, before anything is done
#    with it, so an error further down never costs the 27 calls a second time.
if (RUN_REVIEWS) {
  run <- file.path("tests", "gold_runs", paste0(format(Sys.time(), "%Y-%m-%d-%H%M%S"), "_", gsub("[^A-Za-z0-9.-]", "-", m$id)))
  dir.create(run, recursive = TRUE, showWarnings = FALSE)
  forms <- purrr::map(items$shown, function(txt)
    clean_form(list(task = "evaluate", research_question = "Evaluate this survey question",
                    population = "Adults in the general population", modes = "web", questionnaire = txt)))
  parts <- purrr::map(forms, function(f) c(review_plan(f$questionnaire)[[1]], list(form = f)))
  batches <- send_parts(ask_all, m, forms[[1]], parts, message = NULL, progress = say)
  kept <- c("reply", "status", "seconds", "attempts", "refused", "error")   # the reply and its call record; no prompt, no key
  jsonlite::write_json(purrr::map(batches, function(b) b[intersect(names(b), kept)]),
                       file.path(run, "reviews.json"), auto_unbox = TRUE, null = "null", na = "null")
} else {
  # The latest run folder that holds a review (an empty folder left by a stopped run is skipped).
  runs <- sort(list.dirs(file.path("tests", "gold_runs"), recursive = FALSE))
  run <- utils::tail(runs[file.exists(file.path(runs, "flags.csv")) | file.exists(file.path(runs, "reviews.json"))], 1L)
  stopifnot("No run folder with a review in it; set RUN_REVIEWS to TRUE" = length(run) == 1L)
}

# Every flag goes to flags.csv and every call to calls.csv. Built from reviews.json, so this step
#   can be run again with RUN_REVIEWS <- FALSE if it ever stops.
if (!file.exists(file.path(run, "flags.csv"))) {
  batches <- jsonlite::read_json(file.path(run, "reviews.json"), simplifyVector = FALSE)
  text_of <- function(fl, field) purrr::map_chr(fl, function(x) as.character(x[[field]] %||% ""))
  flags <- purrr::map2(batches, seq_len(nrow(items)), function(b, i) {
    fl = if (length(b$reply$items)) b$reply$items[[1]]$flags %||% list() else list()
    tibble::tibble(item = rep(items$id[i], length(fl)), set = rep(items$set[i], length(fl)),
                   check = text_of(fl, "check"), label = as.character(unname(check_label(text_of(fl, "check")))),
                   level = text_of(fl, "level"), quote = text_of(fl, "quote"),
                   quote_found = purrr::map_lgl(fl, function(x) isTRUE(quote_found(x$quote, items$shown[i]))),
                   why = text_of(fl, "why"))
  }) |> dplyr::bind_rows()
  calls <- tibble::tibble(step = "review", item = items$id,
                          status = purrr::map_chr(batches, function(b) as.character(b$status %||% "failed")),
                          seconds = purrr::map_dbl(batches, function(b) as.numeric(b$seconds %||% NA_real_)),
                          attempts = purrr::map_int(batches, function(b) as.integer(b$attempts %||% NA_integer_)),
                          refused = purrr::map_chr(batches, function(b) paste(c(unlist(b$refused), if (!identical(b$status, "ok")) unlist(b$error)), collapse = " || ")))
  utils::write.csv(flags, file.path(run, "flags.csv"), row.names = FALSE)
  utils::write.csv(calls, file.path(run, "calls.csv"), row.names = FALSE)
  if (any(calls$status != "ok")) say(paste("Not reviewed:", paste(calls$item[calls$status != "ok"], collapse = ", ")))
}
say(paste("Run folder:", run))
flags <- utils::read.csv(file.path(run, "flags.csv"), colClasses = c(quote_found = "logical"))
calls <- utils::read.csv(file.path(run, "calls.csv"))
model_id <- sub("^[^_]*_", "", basename(run))


# 3. Match the flags to the planted faults. One call per flawed question, to the main model, in a
#    fresh chat that is not the review's. It sees the question, its planted faults and its flags,
#    and says which flag (if any) describes each fault. R refuses a reply that uses a flag twice
#    or leaves a fault out; a refused reply is tried again, as in the app.
MATCH_INSTRUCTIONS <- paste(
  "You compare an expert review of one survey question with the faults that were planted in it.",
  "For each planted fault, give the number of the one flag that describes it, or null.",
  "A flag matches a fault when it names the same problem in the same part of the question.",
  "One flag matches at most one fault. Do not match on topic alone. When unsure, give null and \"none\".",
  "Say \"exact\" when the flag names the fault as stated, \"approximate\" when it names the same problem less precisely,",
  "and \"none\" when no flag describes it.",
  "Reply with one JSON object and nothing else:",
  "{\"matches\": [{\"problem_id\": \"F1-P1\", \"flag\": 2, \"match\": \"exact\"}, {\"problem_id\": \"F1-P2\", \"flag\": null, \"match\": \"none\"}]}")
if (RUN_MATCHING) {
  flawed <- items |> dplyr::filter(set == "flawed")
  requests <- purrr::map(flawed$id, function(i) {
    fs = faults |> dplyr::filter(id == i)
    fl = flags |> dplyr::filter(item == i)
    user = paste0("THE QUESTION\n", flawed$shown[flawed$id == i], "\n\nPLANTED FAULTS\n",
                  paste0(fs$problem_id, ": ", fs$problem, collapse = "\n"), "\n\nFLAGS\n",
                  if (nrow(fl)) paste0(seq_len(nrow(fl)), ". ", fl$label, " (", fl$level, "): \"", fl$quote, "\". ", fl$why, collapse = "\n")
                  else "(none)")
    validate = function(obj) {
      ms = obj$matches
      ids = purrr::map_chr(ms, function(x) as.character(x$problem_id %||% ""))
      used = unlist(purrr::map(ms, "flag"))
      kinds = purrr::map_chr(ms, function(x) as.character(x$match %||% ""))
      problems = c(if (!setequal(ids, fs$problem_id) || anyDuplicated(ids)) "give each planted fault exactly once",
                   if (anyDuplicated(used)) "a flag is used for two faults",
                   if (any(!used %in% seq_len(nrow(fl)))) "a flag number is not in the list",
                   if (!all(kinds %in% c("exact", "approximate", "none"))) "match must be exact, approximate or none",
                   if (any(purrr::map_lgl(ms, function(x) is.null(x$flag) != identical(x$match, "none")))) "a null flag goes with none, and only then")
      if (length(problems)) stop(paste(problems, collapse = "; "), call. = FALSE)
    }
    list(user = user, m = m, system_prompt = MATCH_INSTRUCTIONS, max_tokens = 8000L, validate = validate)
  })
  replies <- unlist(purrr::map(unname(split(seq_along(requests), ceiling(seq_along(requests) / 4))), function(at) {
    say(paste("Matching", paste(flawed$id[at], collapse = ", ")))
    ask_all(requests[at])
  }), recursive = FALSE)
  failed <- flawed$id[purrr::map_lgl(replies, function(r) inherits(r, "error"))]
  if (length(failed)) stop("The matching did not come back for ", paste(failed, collapse = ", "), ". Run it again.", call. = FALSE)
  matches <- purrr::map2(replies, flawed$id, function(r, i) {
    fl = flags |> dplyr::filter(item == i)
    ms = r$obj$matches
    n = purrr::map_int(ms, function(x) if (is.null(x$flag)) NA_integer_ else as.integer(x$flag))
    tibble::tibble(problem_id = purrr::map_chr(ms, "problem_id"), match = purrr::map_chr(ms, "match"),
                   flag_check = fl$check[n], flag_level = fl$level[n], flag_why = fl$why[n], checked_by = "")
  }) |> dplyr::bind_rows() |>
    dplyr::inner_join(faults |> dplyr::select(problem_id, type = problem_type, problem), by = "problem_id") |>
    dplyr::select(problem_id, type, problem, match, flag_check, flag_level, flag_why, checked_by) |>
    dplyr::arrange(match(problem_id, faults$problem_id))
  calls <- calls |> dplyr::filter(step != "match") |>
    dplyr::bind_rows(tibble::tibble(step = "match", item = flawed$id, status = "ok",
                                    seconds = purrr::map_dbl(replies, "seconds"), attempts = purrr::map_int(replies, "attempts"),
                                    refused = purrr::map_chr(replies, function(r) paste(unlist(r$refused), collapse = " || "))))
  utils::write.csv(matches, file.path(run, "matches.csv"), row.names = FALSE, na = "")
  utils::write.csv(calls, file.path(run, "calls.csv"), row.names = FALSE)
}
stopifnot("No matches.csv in the run folder: set RUN_MATCHING to TRUE" = file.exists(file.path(run, "matches.csv")))
matches <- utils::read.csv(file.path(run, "matches.csv"), colClasses = "character", na.strings = character(0))


# 4. Count. A fault is found when its match is "exact" or "approximate", at the level of the flag
#    it was matched to.
found <- matches |> dplyr::mutate(found = match != "none")
n_found <- sum(found$found)
n_fix <- sum(found$found & found$flag_level == "fix")
by_type <- found |> dplyr::group_by(type) |> dplyr::summarise(found = sum(found), known = dplyr::n()) |> dplyr::arrange(dplyr::desc(known), type)
controls <- flags |> dplyr::filter(set == "control")
n_control_fix <- sum(controls$level == "fix")
q_control_fix <- dplyr::n_distinct(controls$item[controls$level == "fix"])
q_control_consider <- dplyr::n_distinct(controls$item[controls$level == "consider"])
n_checked <- sum(found$found & nzchar(trimws(found$checked_by)))


# 5. Write the paragraph for the Methodology page, and the run's summary.
paragraph <- paste0(
  "In the latest run (", substr(basename(run), 1, 10), ", model ", model_id, ") the reviewer flagged ", n_found,
  " of the 48 planted faults (", round(100 * n_found / 48), " percent): ", n_fix, " as \"fix\" and ", n_found - n_fix,
  " as \"consider\". By kind of fault it found ", paste0(by_type$type, ": ", by_type$found, " of ", by_type$known, collapse = ", "),
  ". On the 7 well-tested questions it raised ", n_control_fix, " \"fix\" flags, on ", q_control_fix, " of them, and \"consider\" flags on ",
  q_control_consider, ". The flags were matched to the planted faults by the AI model in a separate step; a person has checked ",
  n_checked, " of the ", n_found, " matches.")
writeLines(paragraph, file.path("www", "gold_summary.md"), useBytes = TRUE)
missed <- found |> dplyr::filter(!found)
writeLines(c(
  paste("# Gold run", basename(run)), "", paragraph, "",
  paste0("Quotes found in the question: ", sum(flags$quote_found), " of ", nrow(flags), " (", round(100 * mean(flags$quote_found)), " percent)."), "",
  "## By kind of fault", "", "| Kind | Found | Planted |", "|---|---|---|",
  paste0("| ", by_type$type, " | ", by_type$found, " | ", by_type$known, " |"), "",
  "## Planted faults not found", "", if (nrow(missed)) paste0("- ", missed$problem_id, " (", missed$type, "): ", missed$problem) else "None.", "",
  "## Calls", "", "| Step | Item | Status | Seconds | Attempts | Refused |", "|---|---|---|---|---|---|",
  paste0("| ", calls$step, " | ", calls$item, " | ", calls$status, " | ", round(calls$seconds), " | ", calls$attempts, " | ",
         ifelse(is.na(calls$refused), "", calls$refused), " |")),
  file.path(run, "summary.md"), useBytes = TRUE)
cat(paragraph, "\n")
