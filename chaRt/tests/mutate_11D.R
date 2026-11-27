# Mutation runs for the Phase 11 Part D checks (tests/smoke.R, the part between `>>> 11D begin` and `<<< 11D end`). No model call.
#   Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_11D.R                 every mutation
#     Rscript --no-init-file tests/mutate_11D.R M01 M05         only these
# What it does: loads the app as Connect does, runs the 11D block once on the real code (the baseline: every check must pass), then, for each
#   mutation, sources a changed copy of one file of R/ (one piece of its text replaced) into the global environment, runs the block again and says
#   which checks failed; each mutation must make at least one fail. The original file is sourced again after each. Nothing on disk is changed
#   (the block makes its workbooks in tempdir()).
# Not covered by a mutation: "nothing is written to the workbook" (11D-14): the code never opens the file for writing, so there is no one-piece
#   change that makes it do so which the checksum could meet in a way that means anything.

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> 11D begin", smoke):grep("^# <<< 11D end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(data.R = read_file("data.R"), spec.R = read_file("spec.R"), ui.R = read_file("ui.R"))

hits <- new.env()
check <- function(what, cond) {
  pass <- isTRUE(tryCatch(cond, error = function(e) FALSE))
  hits$all <- c(hits$all, stats::setNames(pass, sub(":.*$", "", what)))
  invisible(pass)
}
run_block <- function() {
  hits$all <- logical(0)
  err <- tryCatch({ eval(block, globalenv()); NULL }, error = function(e) conditionMessage(e))
  setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
  list(failed = names(hits$all)[!hits$all], total = length(hits$all), aborted = err)
}
source_text <- function(txt) {
  f <- tempfile(fileext = ".R")
  writeLines(txt, f, useBytes = TRUE)
  on.exit(unlink(f))
  sys.source(f, envir = globalenv(), keep.source = FALSE)
}
mut <- function(id, what, file, from, to) list(id = id, what = what, file = file, from = from, to = to)
mutations <- list(
  mut("M01", "the header is the table's first row, not the first row with text in most columns", "data.R", "else if (length(most)) tb$r1 + most[1] - 1L else tb$r1", "else tb$r1"),
  mut("M02", "no sheet is ever hidden", "data.R", "hidden = !is.na(state) & state %in% c(\"hidden\", \"veryHidden\"),", "hidden = FALSE,"),
  mut("M03", "two tables on a sheet: the first is read without asking", "data.R", "if (nrow(tables) > 1L && is.null(opts$table)) {", "if (FALSE) {"),
  mut("M04", "dates are left as the date-times readxl gives", "data.R", "purrr::map(cols, excel_dates)", "cols"),
  mut("M05", "numbers stored as text are not offered", "data.R", "offered = text_number_columns(data)", "offered = character(0)"),
  mut("M06", "merged header cells are not joined to the row below", "data.R", "joined = merged && any(nzchar(below))", "joined = FALSE"),
  mut("M07", "the first sheet is read even when it is hidden", "data.R", "visible = wb$sheet[!(wb$hidden %in% TRUE)]", "visible = wb$sheet"),
  mut("M08", "the source line does not name the sheet", "spec.R", "paste0(cb$file %||% \"the data file\", if (is_text1(cb$sheet)) paste0(\", sheet \", cb$sheet))", "cb$file %||% \"the data file\""),
  mut("M09", "blank leading rows are part of the table", "data.R", "    rows = true_runs(rowSums(!part) > 0)", "    rows = data.frame(start = 1L, end = nrow(part))"),
  mut("M10", "a column asked for as numbers is left as text", "data.R", "  data[wanted] = purrr::map(as.list(data)[wanted], number_from_text)", "  data = data"),
  mut("M11", "a code with a leading zero counts as a number stored as text", "data.R", "&& !any(grepl(\"^[-+]?0[0-9]\", v))", "&& TRUE"),
  mut("M12", "the header row the analyst gives is ignored", "data.R", "hrow = if (!is.null(asked)) as.integer(asked) else", "hrow = if (FALSE) 0L else"),
  mut("M13", "an & in a sheet's name is not decoded (the hidden flag is lost)", "data.R", "  gsub(\"&amp;\", \"&\", x, fixed = TRUE)\n}", "  x\n}"),
  mut("M14", "the chat does not offer the text numbers", "ui.R", "      numbers_offer(cols)\n", "      numbers_offer(character(0))\n"),
  mut("M15", "the chat's reread forgets the sheet's choices (numbers asked for)", "ui.R", "      excel = isolate(state$excel)$opts\n", "      excel = NULL\n"),
  mut("M16", "the code of a chart reads the sheet as a delimited file", "spec.R", "  excel = is_text1(cb$sheet)   #", "  excel = FALSE   #"))
wanted <- commandArgs(trailingOnly = TRUE)
if (length(wanted)) mutations <- purrr::keep(mutations, function(m) m$id %in% wanted)

base <- run_block()
cat("\nbaseline: ", base$total - length(base$failed), " of ", base$total, " checks pass", if (length(base$failed)) paste0(" (FAIL: ", paste(base$failed, collapse = ", "), ")"),
    if (!is.null(base$aborted)) paste0(" (ABORTED: ", base$aborted, ")"), "\n", sep = "")
results <- purrr::map(mutations, function(m) {
  txt <- texts[[m$file]]
  n <- lengths(regmatches(txt, gregexpr(m$from, txt, fixed = TRUE)))
  if (n != 1L) return(list(id = m$id, what = m$what, applied = n, failed = NA_character_, aborted = NULL))
  source_text(sub(m$from, m$to, txt, fixed = TRUE))
  t0 <- Sys.time()
  r <- run_block()
  source_text(txt)
  cat(sprintf("%s  %-72s %3d failed: %s%s  (%.0f s)\n", m$id, m$what, length(r$failed), paste(r$failed, collapse = " "),
              if (!is.null(r$aborted)) paste0("  [block stopped: ", substr(r$aborted, 1, 60), "]") else "", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  list(id = m$id, what = m$what, applied = n, failed = r$failed, aborted = r$aborted)
})
bad_apply <- purrr::keep(results, function(r) r$applied != 1L)
caught <- purrr::map_lgl(results, function(r) length(r$failed) > 0L || !is.null(r$aborted))
cat("\n", sum(caught), " of ", length(results), " mutations made at least one check fail", if (length(bad_apply)) paste0("; did not apply: ", paste(purrr::map_chr(bad_apply, "id"), collapse = ", ")), "\n", sep = "")
if (!all(caught) || length(bad_apply) || length(base$failed)) quit(status = 1)
