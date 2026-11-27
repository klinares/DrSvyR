# Mutation runs for the night task 03 checks (tests/smoke.R, the part between `>>> night03 begin` and `<<< night03 end`: N3-1 to N3-8, R's headline rules).
#   No model call. Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_night03.R                 every mutation
#     Rscript --no-init-file tests/mutate_night03.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_night03.R NONE            the baseline only
# What it does: as tests/mutate_13.R, for the night03 block: the baseline on the real code, then each mutation (a changed copy of R/spec.R or R/ui.R sourced
#   into the global environment) must make at least one check fail. Nothing on disk is changed. At least one mutation for each rule: means and medians
#   back on the ratio (1); every value the same said as "similar" (2); "no clear relation" again (3); a log-scale correlation not said (4); names split
#   into words, and a sentence begun with a lower-case name (5); short and numeric group names bare (6); several lines as one, all alike not said, an
#   index not a multiple, one series without its start (7); the full stop kept (8); and the page's faces not loaded at once, or swapped in late (N3-9).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- FALSE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> night03 begin", smoke):grep("^# <<< night03 end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(spec.R = read_file("spec.R"), ui.R = read_file("ui.R"))

hits <- new.env()
check <- function(what, cond) {
  pass <- isTRUE(tryCatch(cond, error = function(e) FALSE))
  hits$all <- c(hits$all, stats::setNames(pass, sub(":.*$", "", what)))
  invisible(pass)
}
run_block <- function() {
  hits$all <- logical(0)
  err <- tryCatch({ eval(block, globalenv()); NULL }, error = function(e) conditionMessage(e))
  list(failed = names(hits$all)[!hits$all], total = length(hits$all), aborted = err)
}
source_file <- function(f) sys.source(f, envir = globalenv(), keep.source = FALSE)
# A mutation: `from` and `to` are pieces of text, in pairs; each `from` must be found exactly once.
mut <- function(id, what, file, from, to) list(id = id, what = what, file = file, from = from, to = to)
mutations <- list(
  mut("M01", "a mean is similar by the ratio again", "spec.R", "    if (identical(fn, \"mean\")) isTRUE(gap < HEADLINE_SMALL_DIFF * hl_num(fact(FACTS_POOLED_SD)))", "    if (FALSE) NULL"),
  mut("M02", "a median is similar by the ratio again", "spec.R", "    else if (identical(fn, \"median\")) isTRUE(gap < HEADLINE_SMALL_DIFF * hl_num(fact(FACTS_SPREAD)))", "    else if (FALSE) NULL"),
  mut("M03", "every value the same is said as similar", "spec.R", "      if (!is.null(every)) {", "      if (FALSE) {"),
  mut("M04", "'no clear relation' again", "spec.R", "c(paste0(\"No straight-line relation between \"", "c(paste0(\"No clear relation between \""),
  mut("M05", "a log-scale correlation is not said", "spec.R", "if (is.null(plain)) \"log-scale correlation \" else \"correlation \"", "\"correlation \""),
  mut("M06", "a column's name is split into words", "spec.R", "  if (identical(l, col)) return(col)\n", "  if (identical(l, col)) return(gsub(\"_\", \" \", col))\n"),
  mut("M07", "a sentence may begin with a lower-case name", "spec.R", "  low = grepl(\"^[a-z]\", y0)", "  low = FALSE"),
  mut("M08", "a short or numeric group name stands bare", "spec.R", "    if (grepl(\"^[-+]?[0-9][0-9.,]*$\", v) || nchar(v) < 3L) paste(hl_label(cb, col), p) else p", "    p"),
  mut("M09", "several lines are written as one", "spec.R", "      if (!is.null(hl_fact(lines, \"Highest at the end\"))) {", "      if (FALSE) {"),
  mut("M10", "all lines alike is not said", "spec.R", "        if (one_way && !is.null(small)", "        if (FALSE && one_way && !is.null(small)"),
  mut("M11", "an index is not written as a multiple", "spec.R", "      if (index_first(s)) {\n        top = ", "      if (FALSE) {\n        top = "),
  mut("M12", "one series without its start", "spec.R",
      "      c(paste0(measure_start, \" \", dir, \" from \", first, \" in \", t1, \" to \", last, \" in \", t2), paste0(measure_start, \" \", dir, \" from \", first, \" to \", last, \" in \", t2),\n", "      c("),
  mut("M13", "the full stop is kept", "spec.R", "hl_strip <- function(x) sub(\"(?<![A-Z])[.]\\\\s*$\", \"\", trimws(x), perl = TRUE)", "hl_strip <- function(x) trimws(x)"),
  mut("M14", "a page with animated cards does not load its faces at once", "ui.R", "MOTION_HEAD_JS <- paste0(DASH_FONTS_JS, \" (function () { if", "MOTION_HEAD_JS <- paste0(\"(function () { if"),
  mut("M15", "a page with animated cards keeps the default font display", "ui.R", "dash_font_css(style, if (moving) \"optional\")", "dash_font_css(style)"))
wanted <- commandArgs(trailingOnly = TRUE)
if (length(wanted)) mutations <- purrr::keep(mutations, function(m) m$id %in% wanted)

base <- run_block()
cat("\nbaseline: ", base$total - length(base$failed), " of ", base$total, " checks pass", if (length(base$failed)) paste0(" (FAIL: ", paste(base$failed, collapse = ", "), ")"),
    if (!is.null(base$aborted)) paste0(" (ABORTED: ", base$aborted, ")"), "\n", sep = "")
results <- purrr::map(mutations, function(m) {
  txt <- texts[[m$file]]
  n <- purrr::map_int(m$from, function(x) lengths(regmatches(txt, gregexpr(x, txt, fixed = TRUE))))
  if (!all(n == 1L)) return(list(id = m$id, what = m$what, applied = FALSE, failed = NA_character_, aborted = NULL))
  changed <- purrr::reduce2(m$from, m$to, function(t, a, b) sub(a, b, t, fixed = TRUE), .init = txt)
  f <- tempfile(fileext = ".R")
  writeLines(changed, f, useBytes = TRUE)
  source_file(f)
  t0 <- Sys.time()
  r <- run_block()
  orig <- tempfile(fileext = ".R"); writeLines(txt, orig, useBytes = TRUE); source_file(orig)
  cat(sprintf("%s  %-72s %3d failed: %s%s  (%.0f s)\n", m$id, m$what, length(r$failed), paste(r$failed, collapse = " "),
              if (!is.null(r$aborted)) paste0("  [block stopped: ", substr(r$aborted, 1, 60), "]") else "", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  list(id = m$id, what = m$what, applied = TRUE, failed = r$failed, aborted = r$aborted)
})
bad_apply <- purrr::keep(results, function(r) !r$applied)
caught <- purrr::map_lgl(results, function(r) length(r$failed) > 0L || !is.null(r$aborted))
cat("\n", sum(caught), " of ", length(results), " mutations made at least one check fail", if (length(bad_apply)) paste0("; did not apply: ", paste(purrr::map_chr(bad_apply, "id"), collapse = ", ")), "\n", sep = "")
if (!all(caught) || length(bad_apply) || length(base$failed)) quit(status = 1)
