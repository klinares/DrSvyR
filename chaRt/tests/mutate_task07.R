# Mutation runs for the task 07 checks (tests/smoke.R, the part between `>>> task07 begin` and `<<< task07 end`: T7-A1 to T7-C3, the survey fixes).
#   No model call. Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_task07.R                 every mutation
#     Rscript --no-init-file tests/mutate_task07.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_task07.R NONE            the baseline only
# What it does: as tests/mutate_night05.R, for the task07 block: the baseline on the real code, then each mutation (a changed copy of R/data.R, R/spec.R,
#   R/reflexes.R or R/ui.R sourced into the global environment) must make at least one check fail. Nothing on disk is changed. At least one mutation for
#   each rule: the weights sentence (A); the codes' note on the card, in FACTS, under a summary table (B1); a settled code still noted, the analyst's
#   "real values" lost on a new read, a link of the card missing (B2); no opening, the codes counted against the headline's numbers, the model's check
#   off, the repair not told (B3); an interval for a small group (B5); no FACTS line for small groups, or one for a count (C1); a small group crowned,
#   the card's note gone (C2); no count on the axis label (C3).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- FALSE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> task07 begin", smoke):grep("^# <<< task07 end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(data.R = read_file("data.R"), spec.R = read_file("spec.R"), reflexes.R = read_file("reflexes.R"), ui.R = read_file("ui.R"))

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
  mut("M01", "the weights message lacks the manager's sentence", "data.R",
      "WEIGHTS_SOFTWARE <- \"For estimates of a population, use survey software with the weights and the design.\"", "WEIGHTS_SOFTWARE <- \"\""),
  mut("M02", "the card and the exported page carry no note of the codes", "spec.R", "  attr(p, \"notes\") = c(codes_sentences(codes), ", "  attr(p, \"notes\") = c("),
  mut("M03", "FACTS has no line of the codes", "spec.R", "if (length(codes)) paste0(CODES_FACTS, \": \", codes))", "NULL)"),
  mut("M04", "a summary table carries no note of the codes", "data.R", "    codes_sentences(info$codes %||% list()))   # task 07 Part B", "    NULL)"),
  mut("M05", "codes the analyst kept as values are still noted", "data.R",
      "setdiff(numeric_code_words(data[[col]]), as.character(unlist(cb_entry(cb, col)$codes_real %||% list())))", "numeric_code_words(data[[col]])"),
  mut("M06", "a new read of the file forgets the values kept", "data.R", "    out$codes_real = o$codes_real   # task 07 Part B: values the analyst said are real stay so\n", ""),
  mut("M07", "a summary table's card has no 'real values' link", "ui.R", "actionLink(ns(cid(table_id, \"codes_real\")), CODES_REAL_BUTTON)", "actionLink(ns(cid(table_id, \"codes_kept\")), CODES_REAL_BUTTON)"),
  mut("M08", "R's headline does not open with the codes", "spec.R", "  if (!length(codes) || !length(heads)) return(heads)", "  return(heads)"),
  mut("M09", "the codes count against the headline's numbers", "reflexes.R", " && !(n$value %in% codes) &&", " &&"),
  mut("M10", "a model's text without the codes passes", "reflexes.R", "codes = check_codes(headline, summary, facts_text))", "codes = character(0))"),
  mut("M11", "the repair call is not told of the codes", "reflexes.R", "    if (length(p$codes)) paste(p$codes, collapse = \"; \")), collapse = \"; \"), \".\")", "    NULL), collapse = \"; \"), \".\")"),
  mut("M12", "a small group keeps its interval", "data.R", "if (small) list(mean_ci_low = NA_real_", "if (FALSE) list(mean_ci_low = NA_real_"),
  mut("M13", "FACTS does not name the small groups", "spec.R", "if (length(attr(table, \"small_groups\"))) paste0(FACTS_SMALL, \": \",", "if (FALSE) paste0(FACTS_SMALL, \": \","),
  mut("M14", "a count of rows has small groups too", "spec.R", "  if (!identical(s$family, \"box\") && !(s$fn %||% \"none\") %in% c(\"mean\", \"median\", \"share\")) return(NULL)\n", ""),
  mut("M15", "R's headline may crown a small group", "spec.R", "  small_out = !faceted && any(startsWith(lines, FACTS_BIG))", "  small_out = FALSE"),
  mut("M16", "the card does not say a small group is left out", "spec.R", "purrr::map_chr(small_crowned(ls, table, small), function(g) small_left_out(g, small[[g]])),", "character(0),"),
  mut("M17", "a small group's axis label has no count", "spec.R", "  calls = small_axis_calls(calls, s)\n", ""))
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
