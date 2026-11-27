# Mutation runs for the night task 02 checks (tests/smoke.R, the part between `>>> night02 begin` and `<<< night02 end`: N2-1 to N2-3).
#   No model call. Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_night02.R                 every mutation
#     Rscript --no-init-file tests/mutate_night02.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_night02.R NONE            the baseline only
# What it does: as tests/mutate_13.R, for the night02 block: the baseline on the real code, then each mutation (a changed copy of R/data.R or R/ui.R
#   sourced into the global environment) must make at least one check fail. Nothing on disk is changed. At least one mutation for each check: 98 and
#   97 no longer usual codes, the column's note on codes gone, the weight's note gone, any column called weight taken as a survey weight (N2-1); the read
#   message without its two sentences (N2-2); a model's headline checked again with its names written out (N2-3).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- FALSE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> night02 begin", smoke):grep("^# <<< night02 end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(data.R = read_file("data.R"), ui.R = read_file("ui.R"))

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
  mut("M01", "98 and 97 are not usual codes (all nines only)", "data.R", "NUMERIC_CODE_FORM <- \"^9{2,}$|^9+[78]$\"", "NUMERIC_CODE_FORM <- \"^9{2,}$\""),
  mut("M02", "the dictionary does not note a column's codes", "data.R", "            if (length(codes)) codes_note(codes),", "            if (FALSE) codes_note(codes),"),
  mut("M03", "the dictionary does not note a survey weight", "data.R", "if (weight) WEIGHT_NOTE", "if (FALSE) WEIGHT_NOTE"),
  mut("M04", "any column called weight is a survey weight", "data.R", "(grepl(SURVEY_WEIGHT_PLAIN, low) & (length(design) > 0L | near_one))", "grepl(SURVEY_WEIGHT_PLAIN, low)"),
  mut("M05", "the read message says neither sentence", "ui.R", "            md_text(read_cautions(data)),\n", "            NULL,\n"),
  mut("M06", "a model's headline is checked again with its names written out", "ui.R",
      "  passed = if (!is.null(now) && (had || !is.na(stale))) as_written(now) else", "  passed = if (FALSE) NULL else"))
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
