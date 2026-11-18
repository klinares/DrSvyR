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
  score = round(stats::rnorm(n), 2)
  score[c(3, 30, 60)] = -99                # a missing-value code, planted in a number column
  df = data.frame(a = sample(1:9, n, replace = TRUE), score = score,
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


# ---- Phase 1b: values that mean missing --------------------------------------------

if (course_present) {
  fh_path <- file.path(COURSE_DIR, "FH_disaggregated.csv")
  fh <- read_data(fh_path, "FH_disaggregated.csv", missing = "..")
  fh_types <- purrr::map_chr(profile_data(fh$data), "type")
  check(paste0("FH read with missing = '..': ", sum(fh_types %in% c("integer", "number")),
               " of 25 columns are integer or number (at least 20), and no 'mostly numbers' sentence remains"),
        sum(fh_types %in% c("integer", "number")) >= 20L && !any(grepl("mostly numbers", fh$problems, fixed = TRUE)))
} else cat("skip  FH with missing = '..': the course files are not there\n")

messy_path <- files[["messy.csv"]]
score_of <- function(missing) {
  p = profile_data(read_data(messy_path, "messy.csv", missing = missing)$data)
  p[[which(purrr::map_chr(p, "name") == "score")]]
}
plain <- score_of(character())
coded <- score_of("-99")
check("messy: read plainly, -99 is the score column's minimum; read with missing = '-99' it is not, and more is missing",
      identical(plain$min, -99) && !identical(coded$min, -99) && coded$min > -99 && coded$missing > plain$missing)

nines_path <- file.path(work_dir, "nines.csv")
writeLines(c("x", "9", "99", "19", "9", "90", "1", " 9 "), nines_path)
nines <- read_data(nines_path, "nines.csv", missing = "9")$data$x
check("a missing value given as 9 does not turn 99 or 19 into missing (whole cells only, spaces trimmed)",
      sum(is.na(nines)) == 3L && all(c(99, 19, 90, 1) %in% nines))

coded_cb <- new_codebook(profile_data(read_data(messy_path, "messy.csv", missing = c("-99", ".."))$data), "messy.csv",
                         120L, c("-99", ".."))
coded_cb_path <- file.path(work_dir, "coded.yaml")
write_codebook(coded_cb, coded_cb_path)
check("a codebook with missing_codes survives a write and a read unchanged",
      identical(read_codebook(coded_cb_path), coded_cb) && identical(missing_codes(coded_cb), c("-99", "..")))


# ---- Phase 1b: whole numbers, roles, orders, Read again -------------------------------

set.seed(1752)
made <- tibble::tibble(population = sample(100000:9000000, 200), row = 1:200, order_id = sample(1000:999999, 200),
                       word = paste0("w", sample(100000:999999, 200)))
made_p <- stats::setNames(profile_data(made), names(made))
check("200 distinct large whole numbers named population: integer, with the 'may be an identifier' note",
      identical(made_p$population$type, "integer") && identical(made_p$population$note, DISTINCT_NOTE))
check("a run 1 to 200 named row is id", identical(made_p$row$type, "id"))
check("200 distinct whole numbers named order_id is id", identical(made_p$order_id$type, "id"))
check("200 distinct words is id", identical(made_p$word$type, "id"))

role_table <- list(number = c("measure", "ignore"), integer = c("measure", "time", "ignore"),
                   category = c("group", "ignore"), ordered = c("group", "ignore"), flag = c("group", "ignore"),
                   date = c("time", "ignore"), id = c("id", "ignore"), text = c("text", "ignore"))
check("role_choices() for each type is the table in the Phase 1b prompt",
      all(purrr::imap_lgl(role_table, function(roles, type) identical(role_choices(list(type = type)), roles))))

if (!inherits(messy, "error")) {
  text_measure <- messy$codebook
  text_measure$columns[[7]]$role <- "measure"
  why_role <- check_codebook(text_measure, messy$profile)
  check("a codebook giving the text column comment the role measure is refused, naming the column",
        any(grepl("comment", why_role, fixed = TRUE) & grepl("measure", why_role, fixed = TRUE)))
}

comma_entry <- codebook_entry(profile_column(c("Low, very", "Medium", "High", "Medium", "High", "Low, very"), "level"))
comma_entry <- edit_entry(comma_entry, type = "ordered")
wanted <- c("Low, very", "Medium", "High")
from_lines <- edit_entry(comma_entry, order = parse_lines("Low, very\nMedium\r\nHigh\n"))
refused <- edit_entry(comma_entry, order = parse_lines("Low\nvery\nMedium\nHigh"))
check("an ordered column with a comma inside a level accepts its order from lines, and refuses lines that are not its levels",
      identical(from_lines$order, wanted) && identical(refused$order, comma_entry$order))

if (course_present) {
  first <- reread_data(fh_path, "FH_disaggregated.csv", character())
  edited_cb <- first$codebook
  edited_cb$row_is <- "one country"
  edited_cb$columns[[1]] <- edit_entry(edited_cb$columns[[1]], label = "Country name")
  edited_cb$columns[[13]] <- edit_entry(edited_cb$columns[[13]], label = "Political rights, 2014", role = "time")
  again <- reread_data(fh_path, "FH_disaggregated.csv", "..", old = edited_cb)
  check("after Read again (reread_data), the edited labels, their source and the row sentence are still there",
        identical(again$codebook$columns[[1]]$label, "Country name") &&
          identical(again$codebook$columns[[1]]$label_source, "user") &&
          identical(again$codebook$columns[[13]]$label, "Political rights, 2014") &&
          identical(again$codebook$row_is, "one country") && identical(missing_codes(again$codebook), ".."))
  check("after Read again, a role the analyst chose is kept, and types R itself chose are re-chosen without a note",
        identical(again$codebook$columns[[13]]$role, "time") && identical(again$codebook$columns[[2]]$type, "integer") &&
          identical(again$codebook$columns[[2]]$role, "measure") && !length(again$notes))
} else cat("skip  Read again on FH: the course files are not there\n")


# ---- Phase 2: the gold specs -------------------------------------------------------

source(file.path("tests", "gallery.R"))
gold <- purrr::compact(purrr::map(gold_entries(), function(en) {
  g = gold_load(en, work_dir)
  if (is.null(g)) { cat("skip  gold spec '", en$name, "': its file is not there\n", sep = ""); return(NULL) }
  list(entry = en, g = g)
}))
gold_tables <- purrr::map(gold, function(x) tryCatch(spec_table(x$entry$spec, x$g$data, x$g$cb), error = function(e) e))
check(paste0("every gold spec (", length(gold), ") passes spec_check()"),
      length(gold) > 0L && all(purrr::map_lgl(gold, function(x) !length(spec_check(x$entry$spec, x$g$cb)))))
check("every gold spec's spec_table() has rows",
      all(purrr::map_lgl(gold_tables, function(t) !inherits(t, "error") && nrow(t) > 0L)))

# A ggplot built, with every warning and message it raised (ggplot_build() included).
build_quietly <- function(expr) {
  said = character(0)
  out = withCallingHandlers(tryCatch(expr, error = function(e) e),
                            warning = function(w) { said <<- c(said, conditionMessage(w)); invokeRestart("muffleWarning") },
                            message = function(m) { said <<- c(said, conditionMessage(m)); invokeRestart("muffleMessage") })
  list(value = out, said = unique(said))
}
gold_plots <- purrr::map(gold, function(x) {
  p = build_quietly(spec_plot(x$entry$spec, x$g$data, x$g$cb))
  b = if (inherits(p$value, "error")) p else build_quietly(ggplot2::ggplot_build(p$value))
  list(name = x$entry$name, plot = p$value, error = if (inherits(b$value, "error")) conditionMessage(b$value),
       said = c(p$said, b$said))
})
purrr::walk(purrr::keep(gold_plots, function(r) length(r$said) || !is.null(r$error)), function(r)
  cat("      ", r$name, ": ", paste(c(r$error, r$said), collapse = " | "), "\n", sep = ""))
check("every gold spec: spec_plot() builds, and ggplot_build() runs with no error, warning or message",
      all(purrr::map_lgl(gold_plots, function(r) is.null(r$error) && !length(r$said) && inherits(r$plot, "ggplot"))))


# ---- Phase 2: the plotly version of each gold chart -------------------------------------

gold_widgets <- purrr::map(gold_plots, function(r) if (inherits(r$plot, "ggplot")) tryCatch(spec_widget(r$plot), error = function(e) e))
widget_warnings <- unlist(purrr::map2(gold_widgets, gold_plots, function(w, r)
  if (inherits(w, "htmlwidget") && length(attr(w, "warnings"))) paste0(r$name, ": ", attr(w, "warnings"))))
cat("      ggplotly() warnings: ", if (length(widget_warnings)) "" else "none", "\n", sep = "")
purrr::walk(widget_warnings, function(x) cat("        ", x, "\n", sep = ""))
check("every gold spec: spec_widget() returns an htmlwidget (its warnings, if any, are printed above)",
      all(purrr::map_lgl(gold_widgets, function(w) inherits(w, "htmlwidget"))))
check("the widget's mode bar is the download button only",
      all(purrr::map_lgl(gold_widgets, function(w) identical(w$x$config$modeBarButtons, list(list("toImage"))))))
check("spec_size(): 7 by 4.5 by default, taller for many sideways bars and for rows of panels",
      identical(spec_size(list(family = "bar"), data.frame()), c(width = 7, height = 4.5)) &&
        spec_size(list(family = "bar", x = "a", .flip = TRUE), data.frame(a = letters))[["height"]] > 4.5 &&
        spec_size(list(family = "line", facet = "a"), data.frame(a = 1:9))[["height"]] > 4.5)


# ---- Phase 2: the code each gold chart comes with ----------------------------------------

gold_codes <- purrr::map2(gold, gold_plots, function(x, r)
  if (inherits(r$plot, "ggplot")) tryCatch(spec_code(attr(r$plot, "spec"), x$g$cb, x$g$path), error = function(e) e))
code_ok <- purrr::map_lgl(gold_codes, is.character)
check("every gold spec: spec_code() returns code", all(code_ok))
parsed <- purrr::map(gold_codes[code_ok], function(code) tryCatch(parse(text = code, keep.source = TRUE), error = function(e) e))
check("every gold spec: the code parses", all(purrr::map_lgl(parsed, function(p) !inherits(p, "error"))))
app_functions <- setdiff(unlist(purrr::map(r_files, function(f)
  purrr::map_chr(purrr::keep(top_level(f), function(e) is_assignment(e) && is.call(e[[3]]) && identical(e[[3]][[1]], as.name("function"))),
                 function(e) as.character(e[[2]])))), "chart_theme")
code_tokens <- purrr::map(parsed, function(p) if (!inherits(p, "error")) utils::getParseData(p))
check("every gold spec: the code has no for, while or repeat",
      all(purrr::map_lgl(code_tokens, function(pd) !is.null(pd) && !any(pd$token %in% c("FOR", "WHILE", "REPEAT")))))
check("every gold spec: the code calls no function of this app except chart_theme()",
      all(purrr::map_lgl(code_tokens, function(pd) !is.null(pd) &&
                           !length(intersect(pd$text[pd$token == "SYMBOL_FUNCTION_CALL"], app_functions)))))

# Each code run in a fresh R process that has chart_theme() and nothing else from the app.
code_dir <- file.path(work_dir, "codes")
dir.create(code_dir)
# The code names the file only, so each runs from the folder that holds its file.
purrr::iwalk(which(code_ok), function(k, i) {
  writeLines(gold_codes[[k]], file.path(code_dir, sprintf("code_%02d.R", i)), useBytes = TRUE)
  writeLines(normalizePath(dirname(gold[[k]]$g$path), winslash = "/"), file.path(code_dir, sprintf("code_%02d.dir", i)))
})
runner <- file.path(work_dir, "run_codes.R")
writeLines(c(
  "args <- commandArgs(TRUE)",
  "theme <- new.env(); sys.source(args[2], envir = theme); assign('chart_theme', theme$chart_theme, envir = globalenv())",
  "files <- sort(list.files(args[1], pattern = '^code_.*[.]R$', full.names = TRUE))",
  "out <- lapply(files, function(f) tryCatch({",
  "  env <- new.env(parent = globalenv())",
  "  old <- setwd(readLines(sub('[.]R$', '.dir', f))); on.exit(setwd(old))",
  "  p <- suppressMessages(eval(parse(f, encoding = 'UTF-8'), env))",
  "  ggplot2::ggplot_build(p)",
  "  list(table = env$chart_table, built = TRUE)",
  "}, error = function(e) list(error = conditionMessage(e))))",
  "saveRDS(out, file.path(args[1], 'results.rds'))"), runner)
system2(file.path(R.home("bin"), "Rscript"), c("--no-init-file", shQuote(runner), shQuote(code_dir), shQuote(file.path("R", "theme.R"))),
        stdout = FALSE, stderr = FALSE)
code_runs <- if (file.exists(file.path(code_dir, "results.rds"))) readRDS(file.path(code_dir, "results.rds")) else list()
plain <- function(t) { t = as.data.frame(t); attributes(t) = attributes(t)[c("names", "class", "row.names")]; t }
code_match <- purrr::map2_lgl(code_runs, gold_plots[code_ok], function(run, r)
  isTRUE(run$built) && isTRUE(all.equal(plain(run$table), plain(attr(r$plot, "table")))))
purrr::walk2(code_runs, gold_plots[code_ok], function(run, r) if (!is.null(run$error)) cat("      ", r$name, ": ", run$error, "\n", sep = ""))
check(paste0("every gold spec: the code runs in a fresh R process with only chart_theme(), draws, and builds a table equal to spec_table() (",
             sum(code_match), " of ", sum(code_ok), ")"),
      length(code_runs) == sum(code_ok) && all(code_match))


# ---- Phase 2b: fixes after the gallery review ----------------------------------------------

gold_named <- function(pattern) {
  k = purrr::detect_index(gold, function(x) grepl(pattern, x$entry$name, fixed = TRUE))
  if (k) list(x = gold[[k]], plot = gold_plots[[k]]$plot, code = gold_codes[[k]], widget = gold_widgets[[k]])
}
layer_data_with <- function(p, column) purrr::detect(ggplot2::ggplot_build(p)$data, function(d) column %in% names(d))
code_has <- function(code, text) is.character(code) && grepl(text, code, fixed = TRUE)
ball_g <- purrr::detect(gold, function(x) identical(x$entry$file, "footballdata-1.csv"))$g
fh_bar <- gold_named("FH, top 10 political rights")
nat_bar <- gold_named("ten most common nationalities")
lines8 <- gold_named("revenue by year and region (line, 8 lines)")
lines3 <- gold_named("three regions far apart")
fh_hl <- gold_named("FH, political rights against civil liberties")
faceted <- gold_named("revenue by region (line, faceted)")
box_g <- gold_named("panel, price by region (box)")
heat8 <- gold_named("football, position by foot (heatmap)")
heat80 <- gold_named("panel, mean price by region and year (heatmap)")
hw <- gold_named("height against weight by foot")
lat <- gold_named("latin1")

if (!is.null(fh_bar) && !is.null(nat_bar)) {
  check("2b-1: ties across the top_n cut get 'm values tie at the cut...', and equal values 'Every value shown is the same'; untied ones neither",
        "11 values tie at the cut; the 10 shown are the first alphabetically." %in% attr(fh_bar$plot, "notes") &&
          "Every value shown is the same." %in% attr(fh_bar$plot, "notes") &&
          !any(grepl("tie at the cut|is the same", attr(nat_bar$plot, "notes"))))
}
if (!is.null(lines8) && !is.null(lines3)) {
  s8 = attr(lines8$plot, "spec"); s3 = attr(lines3$plot, "spec")
  ends8 = attr(lines8$plot, "table") |> dplyr::filter(year == max(year)) |> dplyr::arrange(dplyr::desc(revenue))
  check("2b-2: 8 lines ending close together get no end labels and a legend on the right, in the order of the end values",
        identical(s8$.labels, FALSE) && identical(s8$.legend_order, as.character(ends8$region)) &&
          !code_has(lines8$code, "geom_text") && code_has(lines8$code, "legend = \"right\""))
  check("2b-2: 3 lines ending far apart keep their end labels and show no legend",
        isTRUE(s3$.labels) && code_has(lines3$code, "geom_text") && code_has(lines3$code, "guides(colour = \"none\")"))
  check("2b-2: no gold chart uses check_overlap", !any(purrr::map_lgl(gold_codes, function(cd) code_has(cd, "check_overlap"))))
}
if (!is.null(fh_hl)) {
  labs_d = layer_data_with(fh_hl$plot, "label")
  us = labs_d[labs_d$label == "United States of America", ]
  cn = labs_d[labs_d$label == "China", ]
  check("2b-3: a highlight label sits left of a point in the right half of the x range, right of one in the left half",
        nrow(us) == 1L && us$hjust > 1 && nrow(cn) == 1L && cn$hjust < 0)
}
if (!is.null(faceted)) {
  check("2b-4: facet and colour on the same column: one colour, no end labels, no legend",
        !code_has(faceted$code, "geom_text") && !code_has(faceted$code, "scale_colour_manual") && !code_has(faceted$code, "colour = region"))
}
check("2b-5: yellow is the eighth Okabe-Ito colour, used only with eight groups",
      !"#F0E442" %in% chart_palette(7) && identical(chart_palette(8)[8], "#F0E442"))
if (!is.null(box_g) && !is.null(ball_g)) {
  t = attr(box_g$plot, "table")
  meds = sort(tapply(t$price, as.character(t$region), median), decreasing = TRUE)
  ordered_box = ball_g
  pos = which(purrr::map_chr(ordered_box$cb$columns, "name") == "Position")
  ordered_box$cb$columns[[pos]] = edit_entry(ordered_box$cb$columns[[pos]], type = "ordered")
  t_ord = spec_table(list(family = "box", x = "Position", "y" = "Height"), ordered_box$data, ordered_box$cb)
  t_alpha = spec_table(list(family = "box", x = "Position", "y" = "Height", sort = "alphabetical"), ball_g$data, ball_g$cb)
  check("2b-6: boxes are sorted by median, highest first; an ordered x keeps its order; a given sort is kept",
        identical(levels(t$region), names(meds)) && identical(levels(t_ord$Position), ordered_box$cb$columns[[pos]]$order) &&
          identical(levels(t_alpha$Position), sort(unique(as.character(ball_g$data$Position)))))
}
if (!is.null(heat8) && !is.null(heat80)) {
  t80 = attr(heat80$plot, "table")
  cells = layer_data_with(heat8$plot, "label")
  t8 = attr(heat8$plot, "table")
  dark = cells$colour[cells$label == "23"]
  light = cells$colour[cells$label == "514"]
  check("2b-7: heatmap rows read top to bottom in level order (alphabetical here)",
        identical(levels(t80$region), sort(unique(as.character(t80$region)))) && code_has(heat80$code, "scale_y_discrete(limits = rev)"))
  check("2b-7: a heatmap of at most 40 cells prints each value, white on a dark cell and black on a light one; 80 cells print none",
        nrow(cells) == nrow(t8) && identical(dark, "white") && identical(light, "black") && !code_has(heat80$code, "geom_text"))
}
if (!is.null(hw)) {
  check("2b-8: points mostly on shared positions are drawn one per position, sized by count, with the note",
        isTRUE(attr(hw$plot, "spec")$.counted) && code_has(hw$code, "geom_count") &&
          "Points are sized by how many rows share the position." %in% attr(hw$plot, "notes"))
}
if (!is.null(fh_bar) && !is.null(nat_bar)) {
  check("2b-10: a sideways bar drops the title of its name axis unless the spec gives one (x_label)",
        code_has(fh_bar$code, "y = NULL") && code_has(nat_bar$code, "y = \"Nationality\""))
  check("2b-11: ten bars at 40 get no room below zero (it comes from the table drawn, not the codebook)",
        code_has(fh_bar$code, "expansion(mult = c(0, 0.05))") && !isTRUE(attr(fh_bar$plot, "spec")$.negative))
  check("2b-12: top_n is arrange(desc(value), name) |> slice_head(); no tapply(), sort() or head() in any gold code",
        code_has(fh_bar$code, "arrange(desc(pr_2014), Country)") && code_has(fh_bar$code, "slice_head(n = 10)") &&
          !any(purrr::map_lgl(gold_codes, function(cd) grepl("tapply\\(|[^_]sort\\(|head\\(names", cd))))
}
long_lines <- unlist(purrr::map(purrr::keep(gold_codes, is.character), function(cd) {
  ln = strsplit(cd, "\n", fixed = TRUE)[[1]]
  ln[nchar(ln) > SPEC_CODE_WIDTH & !grepl("\"[^\"]{40,}\"", ln) & !grepl("^#", ln)]
}))
check(paste0("2b-12: no line of gold code passes ", SPEC_CODE_WIDTH, " characters (unless it holds a long string)",
             if (length(long_lines)) paste0(" (", length(long_lines), " do)")), !length(long_lines))
check("2b-13: every gold code reads its file by name only: no folder, no temporary path",
      all(purrr::map_lgl(purrr::keep(gold_codes, is.character), function(cd) {
        read = regmatches(cd, regexpr("read_delim\\(\"[^\"]*\"", cd))
        length(read) == 1L && !grepl("[/\\\\]", read) && !grepl(tempdir(), cd, fixed = TRUE) && !grepl("Rtmp", cd, fixed = TRUE)
      })))
if (!is.null(hw)) check("2b-14: repaired column names are restored with rename(), not names(x)[i] <-",
                        code_has(hw$code, "rename(column_1 = ...1)") && !any(purrr::map_lgl(gold_codes, function(cd) code_has(cd, "names(chart_data)"))))
latin_path <- make_latin1(file.path(work_dir, "latin1_check.csv"))
latin <- read_data(latin_path, "latin1_check.csv")
check("2b-15: a Latin-1 file reads to valid UTF-8 with its accents, and the problems say how it was read",
      all(validUTF8(latin$data$country)) && all(c("Côte d'Ivoire", "São Tomé") %in% latin$data$country) &&
        any(startsWith(latin$problems, "The file was read as windows-1252.")) && identical(latin$encoding, "windows-1252"))
if (!is.null(lat)) check("2b-15: the Latin-1 gold bar draws with those names, and its code passes the encoding",
                         all(c("Côte d'Ivoire", "São Tomé") %in% as.character(attr(lat$plot, "table")$country)) &&
                           code_has(lat$code, "locale = locale(encoding = \"windows-1252\")"))
if (!is.null(fh_bar) && !is.null(ball_g)) {
  cap = spec_widget(spec_plot(list(family = "bar", x = "Position", title = "A title", subtitle = "A subtitle", caption = "A caption"),
                              ball_g$data, ball_g$cb))
  check("2b-16: the widget shows the title and the subtitle, and the caption below the chart",
        grepl("Top 10 of 195", fh_bar$widget$x$layout$title$text, fixed = TRUE) &&
          grepl("A title", cap$x$layout$title$text, fixed = TRUE) && grepl("A subtitle", cap$x$layout$title$text, fixed = TRUE) &&
          any(purrr::map_lgl(cap$x$layout$annotations, function(a) identical(a$text, "A caption"))))
}
if (!is.null(lines8)) {
  modes = unlist(purrr::map(lines8$widget$x$data, "mode"))
  check("2b-18: the widget has no direct labels, and shows the legend",
        !any(grepl("text", modes)) && any(unlist(purrr::map(lines8$widget$x$data, "showlegend"))) &&
          !any(unlist(purrr::map(lines3$widget$x$data, "mode")) == "text"))
}


# ---- Phase 2c: palettes ---------------------------------------------------------------------

hex_ok <- function(x) is.character(x) && length(x) > 0L && all(grepl("^#[0-9A-F]{6}$", x))
available <- names(CHART_PALETTES)[purrr::map_lgl(names(CHART_PALETTES), palette_available)]
unavailable <- setdiff(names(CHART_PALETTES), available)
cat("      palettes not available here: ", if (length(unavailable)) paste(unavailable, collapse = ", ") else "none",
    if (length(unavailable)) " (their source package is not installed)" else "", "\n", sep = "")
check(paste0("2c: every available palette (", length(available), " of ", length(CHART_PALETTES),
             ") gives valid hex; a qualitative one gives exactly max distinct colours at its limit and refuses one more"),
      all(purrr::map_lgl(available, function(k) {
        e = CHART_PALETTES[[k]]
        if (!identical(e$kind, "qualitative")) return(hex_ok(if (identical(e$kind, "sequential")) chart_sequential(k) else chart_diverging(k)))
        cols = chart_palette(e$max, k)
        hex_ok(cols) && length(unique(cols)) == e$max && inherits(tryCatch(chart_palette(e$max + 1L, k), error = function(err) err), "error")
      })))

# Without paletteer (its check stubbed): only the built-in and `colours` entries, and the gold
#   specs still draw.
real_paletteer_installed <- paletteer_installed
assign("paletteer_installed", function() FALSE, envir = globalenv())
offered_without <- unlist(purrr::map(c("qualitative", "sequential", "diverging"), function(k) names(chart_palettes(k))))
default_without <- chart_palette_default()
drawn_without <- purrr::map_lgl(gold, function(x) inherits(tryCatch(spec_plot(x$entry$spec, x$g$data, x$g$cb), error = function(e) e), "ggplot"))
assign("paletteer_installed", real_paletteer_installed, envir = globalenv())
check("2c: without paletteer, only the built-in and colours entries are offered, and every gold spec still draws",
      setequal(offered_without, names(purrr::keep(CHART_PALETTES, function(e) !is.null(e$colours)))) &&
        identical(default_without$diverging, "blue_red") && all(drawn_without))

if (!is.null(pan_g <- purrr::detect(gold, function(x) identical(x$entry$file, "panel.csv"))$g) && !is.null(ball_g)) {
  heat_mid <- list(family = "heatmap", x = "year", "y" = "region", color = "price", fn = "mean", midpoint = 25, title = "t")
  p_mid <- spec_plot(heat_mid, pan_g$data, pan_g$cb)
  fill_scale <- ggplot2::ggplot_build(p_mid)$plot$scales$get_scales("fill")
  div <- chart_diverging()
  code_mid <- spec_code(attr(p_mid, "spec"), pan_g$cb, pan_g$path)
  check("2c: a heatmap with a midpoint fills with the diverging colours, centred on it; midpoint on a bar is refused",
        identical(toupper(substr(fill_scale$map(25), 1, 7)), div[(length(div) + 1L) / 2L]) &&
          all(purrr::map_lgl(div, function(h) grepl(h, code_mid, fixed = TRUE))) &&
          grepl("rescale_mid(x, ..., mid = 25)", code_mid, fixed = TRUE) &&
          any(grepl("midpoint: only a heatmap", spec_check(list(family = "bar", x = "Position", midpoint = 3), ball_g$cb), fixed = TRUE)))
}
if (!is.null(hw) && palette_available("tol_bright")) {
  bright <- list(qualitative = "tol_bright", sequential = "viridis", diverging = chart_palette_default()$diverging)
  p_b <- spec_plot(hw$x$entry$spec, hw$x$g$data, hw$x$g$cb, palette = bright)
  code_b <- spec_code(attr(p_b, "spec"), hw$x$g$cb, hw$x$g$path, palette = bright)
  env_b <- new.env(parent = globalenv())
  old_wd <- setwd(dirname(hw$x$g$path))
  run_b <- tryCatch({ suppressMessages(eval(parse(text = code_b), env_b)); TRUE }, error = function(e) FALSE)
  setwd(old_wd)
  check("2c: the code for a chart drawn with a non-default palette writes that palette's colours and reproduces the table",
        all(purrr::map_lgl(chart_palette(2, "tol_bright"), function(h) grepl(h, code_b, fixed = TRUE))) &&
          !grepl("E69F00", code_b, fixed = TRUE) && run_b && isTRUE(all.equal(plain(env_b$chart_table), plain(attr(p_b, "table")))))
}

# Printed, not judged: how far apart each qualitative palette's colours stay, and whether each
#   sequential palette's lightness runs one way.
if (length(find.package("colorspace", quiet = TRUE))) {
  lab_of <- function(cols) methods::as(colorspace::hex2RGB(cols), "LAB")@coords
  min_gap <- function(cols) round(min(stats::dist(lab_of(cols))), 1)
  cat("\n  Colour distances (smallest CIELAB distance between two colours of the palette at its max):\n")
  cat(sprintf("    %-20s %4s %7s %7s %7s %7s\n", "palette", "max", "normal", "deutan", "protan", "tritan"))
  purrr::walk(purrr::keep(available, function(k) identical(CHART_PALETTES[[k]]$kind, "qualitative")), function(k) {
    cols = chart_palette(CHART_PALETTES[[k]]$max, k)
    cat(sprintf("    %-20s %4d %7.1f %7.1f %7.1f %7.1f\n", CHART_PALETTES[[k]]$label, length(cols), min_gap(cols),
                min_gap(colorspace::deutan(cols)), min_gap(colorspace::protan(cols)), min_gap(colorspace::tritan(cols))))
  })
  cat("  Sequential palettes, lightness (CIELAB L) from end to end:\n")
  purrr::walk(purrr::keep(available, function(k) identical(CHART_PALETTES[[k]]$kind, "sequential")), function(k) {
    l = lab_of(chart_sequential(k))[, "L"]
    cat(sprintf("    %-20s %s  (L %s)\n", CHART_PALETTES[[k]]$label,
                if (all(diff(l) > 0) || all(diff(l) < 0)) "one direction" else "NOT one direction", paste(round(l), collapse = " ")))
  })
  cat("\n")
} else cat("      the colorspace package is not installed: the colour-distance table is skipped\n")


# ---- Phase 2: the lint, one check per rule ----------------------------------------------

lint_of <- function(spec, g) {
  s = spec_defaults(spec)
  spec_lint(s, g$cb, spec_table(s, g$data, g$cb))
}
gold_g <- function(file) purrr::detect(gold, function(x) identical(x$entry$file, file))$g
fh_g <- gold_g("FH_disaggregated.csv")
ball_g <- gold_g("footballdata-1.csv")
pan_g <- gold_g("panel.csv")
made_g <- function(n, seed) {
  set.seed(seed)
  d = tibble::tibble(a = stats::rnorm(n), b = stats::rnorm(n))
  list(data = d, cb = new_codebook(profile_data(d), "made.csv", n))
}
if (!is.null(ball_g)) {
  l = lint_of(list(family = "bar", x = "Position", log_y = TRUE, title = "t"), ball_g)
  check("lint: a bar's log scale is removed, with a note", identical(l$spec$log_y, FALSE) && any(grepl("log scale", l$notes)))
  ordered_g = ball_g
  pos = which(purrr::map_chr(ordered_g$cb$columns, "name") == "Position")
  ordered_g$cb$columns[[pos]] = edit_entry(ordered_g$cb$columns[[pos]], type = "ordered")
  check("lint: an unordered x is sorted value_desc, an ordered x level_order, when the spec gives no sort",
        identical(lint_of(list(family = "bar", x = "Position", title = "t"), ball_g)$spec$sort, "value_desc") &&
          identical(lint_of(list(family = "dot", x = "Position", title = "t"), ordered_g)$spec$sort, "level_order") &&
          identical(lint_of(list(family = "bar", x = "Position", sort = "alphabetical", title = "t"), ball_g)$spec$sort, "alphabetical"))
  check("lint: more than 8 bars, or a label longer than 12 characters, is drawn sideways; 4 short ones are not",
        isTRUE(lint_of(list(family = "bar", x = "Nationality", top_n = 10, title = "t"), ball_g)$spec$.flip) &&
          isTRUE(lint_of(list(family = "box", x = "Position", "y" = "Height", title = "t"),
                         { g = ball_g; g$data$Position = paste(g$data$Position, "players"); g })$spec$.flip) &&
          is.null(lint_of(list(family = "bar", x = "Position", title = "t"), ball_g)$spec$.flip))
  check("lint: a missing title gets a note", any(grepl("no title", lint_of(list(family = "bar", x = "Position"), ball_g)$notes)))
  l = lint_of(list(family = "histogram", x = "Age", title = "t"), ball_g)
  check("lint: rows left out for missing values get the note 'k of n rows left out: missing values'",
        any(l$notes == "37 of 1,851 rows left out: missing values."))
  p_fixed = spec_plot(list(family = "histogram", x = "Age", facet = "League", title = "t"), ball_g$data, ball_g$cb)
  p_free = spec_plot(list(family = "histogram", x = "Age", facet = "League", free_y = TRUE, title = "t"), ball_g$data, ball_g$cb)
  check("lint: small multiples share one y scale unless free_y asks for one per panel",
        length(ggplot2::ggplot_build(p_fixed)$layout$panel_scales_y) == 1L &&
          length(ggplot2::ggplot_build(p_free)$layout$panel_scales_y) == 4L)
}
if (!is.null(pan_g)) {
  l = lint_of(list(family = "line", x = "year", "y" = "revenue", color = "region", fn = "sum", title = "t"), pan_g)
  check("lint: 8 colours get the 'highlight or facet' note", any(grepl("8 colours", l$notes)))
  lh = lint_of(list(family = "line", x = "year", "y" = "revenue", color = "region", fn = "sum", title = "t",
                    highlight = list(column = "region", values = "Coast")), pan_g)
  check("lint: 8 lines with no highlight or facet get the 'small multiples or a highlight' note; with a highlight they do not",
        any(grepl("8 lines overlap", l$notes)) && !any(grepl("lines overlap", lh$notes)))
}
big <- made_g(3000L, 1)
huge <- made_g(25000L, 2)
widget_n <- made_g(6000L, 3)
l_big <- lint_of(list(family = "scatter", x = "a", "y" = "b", title = "t"), big)
l_huge <- lint_of(list(family = "scatter", x = "a", "y" = "b", title = "t"), huge)
check("lint: over 2,000 points are drawn transparent, with a note; over 20,000 they are binned, with a note",
      identical(l_big$spec$.alpha, SPEC_ALPHA) && is.null(l_big$spec$.binned) && any(grepl("see-through", l_big$notes)) &&
        isTRUE(l_huge$spec$.binned) && any(grepl("grid", l_huge$notes)))
l_w <- lint_of(list(family = "scatter", x = "a", "y" = "b", interactive = TRUE, title = "t"), widget_n)
check("lint: interactive with more than 5,000 marks is turned off, with a note",
      identical(l_w$spec$interactive, FALSE) && any(grepl("interactive", l_w$notes)))


# ---- Phase 2: bad specs ---------------------------------------------------------------

# What chaRt says about a spec: spec_check()'s sentences, or the one spec_table() raises.
refusal <- function(spec, g) {
  why = spec_check(spec, g$cb)
  if (length(why)) return(why)
  t = tryCatch(spec_table(spec, g$data, g$cb), spec_error = function(e) conditionMessage(e))
  if (is.character(t)) t else character(0)
}
ball <- purrr::detect(gold, function(x) identical(x$entry$file, "footballdata-1.csv"))$g
panel_g <- purrr::detect(gold, function(x) identical(x$entry$file, "panel.csv"))$g
bad_specs <- list(
  list("an unknown field", ball, list(family = "bar", x = "Position", colour = "League"), "colour"),
  list("an unknown family", ball, list(family = "pie", x = "Position"), "pie"),
  list("a column not in the codebook", ball, list(family = "bar", x = "Pozition"), "Pozition"),
  list("a column with role ignore", if (!is.null(ball)) { g = ball; g$cb$columns[[6]]$role = "ignore"; g },
       list(family = "bar", x = "Position"), "ignore"),
  list("a text column on a bar with no top_n", ball, list(family = "bar", x = "Nationality"), "top_n"),
  list("a measure as the x of a bar", ball, list(family = "bar", x = "Height"), "Height"),
  list("fn none where groups repeat", ball, list(family = "bar", x = "Position", "y" = "Height", fn = "none"), "fn"),
  list("fn mean on a scatter", ball, list(family = "scatter", x = "Height", "y" = "Weight", fn = "mean"), "fn"),
  list("a slope whose x has three values", panel_g,
       list(family = "slope", x = "year", "y" = "revenue", color = "region", fn = "sum",
            filter = list(list(column = "year", op = "in", value = c(2015, 2020, 2024)))), "three|3"),
  list("a bubble with no size", ball, list(family = "bubble", x = "Attack", "y" = "Defence"), "size"),
  list("a filter comparing a number column with a word", ball,
       list(family = "bar", x = "Position", filter = list(list(column = "Height", op = ">", value = "tall"))), "Height"),
  list("a facet with more panels than the limit", ball, list(family = "histogram", x = "Height", facet = "Age"), "facet"),
  list("a highlight value not in the column", ball,
       list(family = "bar", x = "Position", highlight = list(column = "Position", values = "Striker")), "Striker"),
  list("top_n of 0", ball, list(family = "bar", x = "Nationality", top_n = 0), "top_n"),
  list("top_n of 31", ball, list(family = "bar", x = "Nationality", top_n = 31), "top_n"))
bad_specs <- purrr::keep(bad_specs, function(b) !is.null(b[[2]]))
cat("\n  What the bad specs produced:\n")
purrr::walk(bad_specs, function(b) {
  why = refusal(b[[3]], b[[2]])
  cat("    [", b[[1]], "] ", paste(why, collapse = " | "), "\n", sep = "")
  check(paste0("bad spec refused, naming the fault: ", b[[1]]), length(why) > 0L && any(grepl(b[[4]], why)))
})
cat("\n")

# The messy file: an id column as a name-like x with top_n draws, and no refusal of a bad spec
#   on that file names the planted value.
if (!inherits(messy, "error")) {
  mg <- list(data = messy$read$data, cb = messy$codebook)
  id_bar <- list(family = "bar", x = "record_id", top_n = 5, title = "Five records")
  check("messy: a bar with the id column as a name-like x and top_n has a table",
        !length(spec_check(id_bar, mg$cb)) && nrow(spec_table(id_bar, mg$data, mg$cb)) == 5L)
  messy_bad <- list(list(family = "bar", x = "record_id"), list(family = "bar", x = "comment"), list(family = "bar", x = "city"),
                    list(family = "line", x = "record_id", "y" = "score"), list(family = "scatter", x = "city", "y" = "comment"),
                    list(family = "heatmap", x = "comment", "y" = "record_id"), list(family = "box", x = "city", "y" = "score"))
  messy_msgs <- unlist(purrr::map(messy_bad, function(sp) refusal(sp, mg)))
  check(paste0("messy: ", SECRET, " appears in none of the ", length(messy_msgs), " sentences refusing bad specs on that file"),
        length(messy_msgs) >= length(messy_bad) && !any(grepl(SECRET, messy_msgs, fixed = TRUE)))
}


# ---- the count -------------------------------------------------------------------

cat("\n", sum(results$all), " of ", length(results$all), " checks passed.\n", sep = "")
if (!all(results$all)) quit(status = 1)
