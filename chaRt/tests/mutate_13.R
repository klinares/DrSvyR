# Mutation runs for the Phase 13 checks (tests/smoke.R, the part between `>>> 13 begin` and `<<< 13 end`: 13A-1 to 13A-4, 13B-1 to 13B-4, 13C-1 and 13C-2).
#   No model call. Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_13.R                 every mutation
#     Rscript --no-init-file tests/mutate_13.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_13.R NONE            the baseline only
# What it does: as tests/mutate_12b.R, for the 13 block (both its fast and its heavy part): the baseline on the real code, then each mutation (a changed copy
#   of R/spec.R or R/ui.R sourced into the global environment) must make at least one check fail. Nothing on disk is changed. At least one mutation for each
#   check: the two thresholds moved (13A-2); a failing headline shown (13A-3); a fact the headline needs left out (13A-1, 13A-4); the description kept as
#   the drawn title (13B-1); the title not broken into lines (13B-2); the app card's picture with its title block (13B-3); a picture in charts/ with no
#   headline (13B-4); a model's failing headline shown (13C-1); the About block without the writers (13C-2); the manager's rulings: the skewness threshold
#   back at 0.5 and the rows rule gone (13A-5), no check again when the chart changes (13C-3), no limit on numbers or on words (13C-4).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- TRUE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> 13 begin", smoke):grep("^# <<< 13 end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(spec.R = read_file("spec.R"), ui.R = read_file("ui.R"), reflexes.R = read_file("reflexes.R"))

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
  mut("M01", "groups are never 'similar' (the threshold at 1)", "spec.R", "HEADLINE_SIMILAR <- 1.1 ", "HEADLINE_SIMILAR <- 1 "),
  mut("M02", "'no clear relation' up to 0.25", "spec.R", "HEADLINE_NO_RELATION <- 0.2 ", "HEADLINE_NO_RELATION <- 0.25 "),
  mut("M03", "a headline that fails its checks is shown", "spec.R", "  if (!summary_ok(p)) return(fallback(", "  if (FALSE) return(fallback("),
  mut("M04", "FACTS does not say which line ends highest", "spec.R",
      "      if (length(one) > 1L) paste0(\"Highest at the end: \", one[[which.max(ends)]]$name, \" (\", fmt(max(ends)), \")\"),
", ""),
  mut("M05", "the description stays the drawn title", "spec.R", "    ls$.headline = head
", "    ls$.headline = s$title
"),
  mut("M06", "the title is not broken into lines", "spec.R", "      if (fits(last, element)) c(utils::head(acc, -1L), last) else c(acc, w)", "      c(utils::head(acc, -1L), last)"),
  mut("M07", "the app card's picture keeps its title block", "ui.R", "        spec$.untitled = TRUE
        spec_plot(spec, state$data", "        spec_plot(spec, state$data"),
  mut("M08", "a picture in charts/ is drawn without its headline", "ui.R", "  chart$spec$.headline = shown$text
", "  chart$spec$.untitled = TRUE
"),
  mut("M09", "a model's headline that fails is shown", "ui.R", "  if (passed) return(list(text = trimws(st$headline), by = \"model\", note = NULL))", "  if (TRUE) return(list(text = trimws(st$headline), by = \"model\", note = NULL))"),
  mut("M10", "the About block does not say who wrote each headline", "ui.R", "      if (length(charts)) entry(\"The headlines\",", "      if (FALSE) entry(\"The headlines\","),
  mut("M11", "a tail is named past a skewness of 0.5 again", "spec.R", "SPEC_FACTS_SKEW <- 1 ", "SPEC_FACTS_SKEW <- 0.5 "),
  mut("M12", "a headline names a tail whatever the rows", "spec.R", "      if (!isTRUE(hl_num(hl_fact(lines, \"Rows used\")) >= HEADLINE_TAIL_MIN_ROWS)) tail = NULL", "      if (FALSE) tail = NULL"),
  mut("M13", "a model's headline is not checked again when the chart changes", "ui.R", "  if (passed && !is.na(stale)) {", "  if (FALSE) {"),
  mut("M14", "no limit on numbers", "reflexes.R", "HEADLINE_MAX_NUMBERS <- 2L", "HEADLINE_MAX_NUMBERS <- 99L"),
  mut("M15", "no limit on words in the headline checks", "reflexes.R", "  c(if (w > HEADLINE_MAX_WORDS) paste0(", "  c(if (FALSE) paste0("))
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
