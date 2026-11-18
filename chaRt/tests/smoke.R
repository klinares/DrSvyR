# Smoke test for chaRt. No model calls. Not deployed (tests/ is in .rscignore).
# Run from inside chaRt/, without the user profile so it is closer to Connect:
#   Rscript --no-init-file tests/smoke.R
# Prints one line per check, "ok" or "FAIL", then the count; exits with status 1 if any failed.

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))

results <- new.env()
results$all <- logical(0)
check <- function(what, cond) {
  pass = isTRUE(tryCatch(cond, error = function(e) FALSE))
  results$all <- c(results$all, pass)
  cat(if (pass) "ok    " else "FAIL  ", what, "\n", sep = "")
}

r_files <- sort(list.files("R", pattern = "[.]R$", full.names = TRUE))
code_files <- c("app.R", r_files)


# ---- the app loads ---------------------------------------------------------------

# Loaded the way Connect loads it. source("app.R") would hide an object that R/ cannot see.
app <- tryCatch(shiny::shinyAppDir("."), error = function(e) e)
check("the app loads through shiny::shinyAppDir(\".\")",
      inherits(app, "shiny.appobj") && is.function(app$serverFuncSource()))


# ---- what R/ may hold ------------------------------------------------------------

# Every top-level expression in R/ is an assignment (a function or a constant), never a call.
top_level <- function(f) as.list(parse(f, keep.source = FALSE))
is_assignment <- function(e) is.call(e) && as.character(e[[1]]) %in% c("<-", "=")
calls_found <- unlist(purrr::map(r_files, function(f)
  purrr::compact(purrr::map(top_level(f), function(e)
    if (!is_assignment(e)) paste0(basename(f), ": ", substr(paste(deparse(e), collapse = " "), 1, 60))))))
library_found <- unlist(purrr::map(r_files, function(f) {
  pd = utils::getParseData(parse(f, keep.source = TRUE))
  hits = pd$text[pd$token == "SYMBOL_FUNCTION_CALL" & pd$text %in% c("library", "require", "requireNamespace", "source")]
  if (length(hits)) paste0(basename(f), ": ", unique(hits))
}))
check(paste0("no file in R/ has a top-level call or a library()",
             if (length(c(calls_found, library_found))) paste0(" (", paste(c(calls_found, library_found), collapse = "; "), ")")),
      !length(calls_found) && !length(library_found))

# The names each file assigns at top level; alphabetical sourcing would silently pick a winner.
defined <- do.call(rbind, purrr::map(r_files, function(f) {
  nm = unlist(purrr::map(top_level(f), function(e) if (is_assignment(e) && is.symbol(e[[2]])) as.character(e[[2]])))
  if (length(nm)) data.frame(file = basename(f), name = nm) else NULL
}))
twice <- unique(defined$name[duplicated(defined$name)])
check(paste0("no name is defined in two files of R/", if (length(twice)) paste0(" (", paste(twice, collapse = ", "), ")")),
      !length(twice))

# for, while and repeat as R keywords, read from the parse data so a comment ("repeat attempts")
#   does not count.
loops_found <- unlist(purrr::map(code_files, function(f) {
  pd = utils::getParseData(parse(f, keep.source = TRUE))
  hits = pd[pd$token %in% c("FOR", "WHILE", "REPEAT"), ]
  if (nrow(hits)) paste0(f, ":", hits$line1, " ", hits$text)
}))
check(paste0("no for, while or repeat in app.R or R/", if (length(loops_found)) paste0(" (", paste(loops_found, collapse = "; "), ")")),
      !length(loops_found))


# ---- the key ---------------------------------------------------------------------

# With no pasted key, nothing is ready, even with ANTHROPIC_API_KEY set in the environment.
old_env <- Sys.getenv("ANTHROPIC_API_KEY", unset = NA)
Sys.setenv(ANTHROPIC_API_KEY = "env-key-should-be-ignored")
ready <- tryCatch(llm_key_ready(), error = function(e) NA)
ping <- tryCatch(llm_ping(APP_MODEL), error = function(e) list(ok = NA, message = conditionMessage(e)))
if (is.na(old_env)) Sys.unsetenv("ANTHROPIC_API_KEY") else Sys.setenv(ANTHROPIC_API_KEY = old_env)
check("with no key, llm_key_ready() is FALSE", identical(ready, FALSE))
check("with no key, llm_ping() returns the \"Waits for a key\" message and makes no call",
      identical(ping$ok, FALSE) && startsWith(ping$message, "Waits for a key.") && identical(.llm_state$calls, 0L))

# The app never reads the key from the environment: the name appears only in a comment saying so.
env_lines <- unlist(purrr::map(code_files, function(f) {
  txt = readLines(f, warn = FALSE, encoding = "UTF-8")
  at = grep("ANTHROPIC_API_KEY", txt, fixed = TRUE)
  ok_line = grepl("^\\s*#", txt[at]) & grepl("ignored", txt[at], fixed = TRUE)
  if (any(!ok_line)) paste0(f, ":", at[!ok_line])
}))
check(paste0("ANTHROPIC_API_KEY appears in app.R and R/ only in a comment saying it is ignored",
             if (length(env_lines)) paste0(" (", paste(env_lines, collapse = "; "), ")")),
      !length(env_lines))


# ---- data files: read, profile, codebook ------------------------------------------

COURSE_DIR <- "D:/repos/UMD_JPSM_coursework/Data_visualization_SURV752/assignments"
COURSE_FILES <- c("datasaurus-1.csv", "FH_disaggregated.csv", "footballdata-1.csv")
SECRET <- "SECRET_VALUE_123"
work_dir <- tempfile("chart_smoke_")
dir.create(work_dir)

# A wide file: 300 rows, 200 columns cycling through numbers, whole numbers, a 5-level category,
#   dates, free text, a two-value column and a code 1 to 5.
make_wide <- function(path) {
  set.seed(752)
  n = 300L
  maker = list(
    number = function() round(stats::rnorm(n, 50, 10), 3),
    integer = function() sample(0:5000, n, replace = TRUE),
    category = function() sample(c("north", "south", "east", "west", "centre"), n, replace = TRUE),
    date = function() format(as.Date("2020-01-01") + sample(0:1500, n, replace = TRUE)),
    text = function() paste("note", sample(1:250, n, replace = TRUE), sample(letters, n, replace = TRUE)),
    flag = function() sample(c("yes", "no"), n, replace = TRUE),
    coded = function() sample(1:5, n, replace = TRUE))
  cols = purrr::map(seq_len(200), function(i) maker[[(i - 1L) %% length(maker) + 1L]]())
  names(cols) = paste0("v", seq_len(200), "_", rep(names(maker), length.out = 200))
  readr::write_csv(tibble::as_tibble(cols), path)
  path
}

# A messy file: a blank header, a duplicated header, numbers with words, an all-missing column,
#   dates, free text, an id, a 45-level category and a code 1 to 5. The free text, the id and the
#   category each hold SECRET once.
make_messy <- function(path) {
  set.seed(727)
  n = 120L
  comments = paste("comment about item", sample(1:90, n, replace = TRUE))
  comments[7] = paste("please call me,", SECRET)
  ids = sprintf("R%04d", seq_len(n))
  ids[11] = SECRET
  cities = paste0("city_", sprintf("%02d", c(1:45, sample(1:45, n - 45L, replace = TRUE))))
  cities[cities == "city_13"] = SECRET
  amount = as.character(round(stats::runif(n, 1, 900), 1))
  amount[c(5, 50, 90)] = c("unknown", "about 40", "unknown")
  df = data.frame(a = sample(1:9, n, replace = TRUE), score = round(stats::rnorm(n), 2),
                  score2 = round(stats::rnorm(n), 2), amount = amount, empty = NA_character_,
                  visit_date = format(as.Date("2024-03-01") + seq_len(n) - 1L), comment = comments,
                  record_id = ids, city = cities, rating = sample(1:5, n, replace = TRUE))
  lines = readr::format_csv(df, na = "")
  lines = sub("^[^\n]*\n", "", lines)
  writeLines(c(",score,score,amount,empty,visit_date,comment,record_id,city,rating", sub("\n$", "", lines)), path)
  path
}

course_present <- dir.exists(COURSE_DIR) && all(file.exists(file.path(COURSE_DIR, COURSE_FILES)))
if (!course_present) cat("skip  the three course files: ", COURSE_DIR, " is not there\n", sep = "")
files <- c(if (course_present) stats::setNames(file.path(COURSE_DIR, COURSE_FILES), COURSE_FILES),
           wide.csv = make_wide(file.path(work_dir, "wide.csv")),
           messy.csv = make_messy(file.path(work_dir, "messy.csv")))

# Each file read, profiled and put through a codebook, or the error it met.
runs <- purrr::imap(files, function(path, name) tryCatch({
  r = read_data(path, name)
  p = profile_data(r$data)
  list(read = r, profile = p, codebook = new_codebook(p, name, nrow(r$data)))
}, error = function(e) e))

purrr::iwalk(runs, function(run, name) {
  check(paste0(name, ": it reads", if (inherits(run, "error")) paste0(" (", conditionMessage(run), ")")),
        !inherits(run, "error"))
  if (inherits(run, "error")) return()
  types = purrr::map_chr(run$profile, "type")
  check(paste0(name, ": one profile entry per column (", length(types), "), each of a known type"),
        length(types) == ncol(run$read$data) && all(types %in% CODEBOOK_TYPES))
  path = file.path(work_dir, paste0(name, ".yaml"))
  write_codebook(run$codebook, path)
  check(paste0(name, ": the codebook is identical after a write and a read"), identical(read_codebook(path), run$codebook))
  ready_after = run$codebook
  ready_after$row_is = "one row"
  check(paste0(name, ": codebook_ready() is FALSE until row_is is set, then TRUE"),
        identical(codebook_ready(run$codebook), FALSE) && identical(codebook_ready(ready_after), TRUE))
})

# ---- the messy file in detail ------------------------------------------------------

messy <- runs[["messy.csv"]]
if (!inherits(messy, "error")) {
  cb <- messy$codebook
  by_name <- stats::setNames(messy$profile, purrr::map_chr(messy$profile, "name"))
  probs <- messy$read$problems
  check("messy: the blank header and the duplicated header are reported as renames",
        sum(grepl("had no name", probs)) == 1L && sum(grepl("same name as an earlier column", probs)) == 1L)
  check("messy: the all-missing column is reported", any(grepl("Column empty is entirely missing", probs, fixed = TRUE)))
  check("messy: the column of numbers with words in it is reported", any(grepl("Column amount is mostly numbers", probs, fixed = TRUE)))
  check("messy: the 45-level column is text", identical(by_name$city$type, "text"))
  check("messy: the 1 to 5 column is integer with the note", identical(by_name$rating$type, "integer") &&
          identical(by_name$rating$note, CODED_NOTE))
  check("messy: the date column is a date, the id column an id, the free text text",
        identical(by_name$visit_date$type, "date") && identical(by_name$record_id$type, "id") &&
          identical(by_name$comment$type, "text"))
  all_cols <- purrr::map_chr(cb$columns, "name")
  chunks <- split(all_cols, ceiling(seq_along(all_cols) / CODEBOOK_MAX_DETAIL))
  sent <- c(codebook_index(cb), unlist(purrr::map(chunks, function(cols) codebook_detail(cb, cols))))
  check(paste0("messy: ", SECRET, " appears nowhere in codebook_index() or codebook_detail()"),
        length(sent) > 0L && !any(grepl(SECRET, sent, fixed = TRUE)))
  check(paste0("messy: ", SECRET, " appears nowhere in the saved codebook.yaml either"),
        !any(grepl(SECRET, readLines(file.path(work_dir, "messy.csv.yaml"), warn = FALSE), fixed = TRUE)))
  too_many <- tryCatch({ codebook_detail(cb, rep(all_cols, length.out = 13L)); NULL }, error = function(e) e)
  check("messy: asking codebook_detail() for 13 columns is an error", inherits(too_many, "error"))
  renamed <- cb
  renamed$columns[[6]]$name <- "visit_day"
  why <- check_codebook(renamed, messy$profile)
  check("messy: a codebook with one column renamed is refused, with a sentence naming the column",
        length(why) > 0L && any(grepl("visit_day", why, fixed = TRUE)) && any(grepl("visit_date", why, fixed = TRUE)))
  wrong_type <- cb
  wrong_type$columns[[9]]$type <- "date"
  check("messy: a codebook typing a column of words as date is refused, naming the column",
        any(grepl("types city as date", check_codebook(wrong_type, messy$profile), fixed = TRUE)))
  edited <- cb
  edited$row_is <- "one visit"
  edited$columns[[10]] <- edit_entry(edited$columns[[10]], label = "Rating, 1 to 5", type = "ordered")
  applied <- apply_codebook(edited, messy$profile, "messy.csv", nrow(messy$read$data))
  check("messy: an applied codebook keeps the label, its source, the type, the order and row_is; the facts come from the file",
        identical(applied, edited) && identical(applied$columns[[10]]$label_source, "user") &&
          identical(applied$columns[[10]]$order, c("1", "2", "3", "4", "5")))
}


# ---- the count -------------------------------------------------------------------

cat("\n", sum(results$all), " of ", length(results$all), " checks passed.\n", sep = "")
if (!all(results$all)) quit(status = 1)
