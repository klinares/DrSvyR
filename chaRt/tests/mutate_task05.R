# Mutation runs for the task 05 checks (tests/smoke.R, the part between `>>> night05 begin` and `<<< night05 end`: N5-1 to N5-4, the designed picture and its title block).
#   No model call. Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_task05.R                 every mutation
#     Rscript --no-init-file tests/mutate_task05.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_task05.R NONE            the baseline only
# What it does: as tests/mutate_night03.R, for the night05 block: the baseline on the real code, then each mutation (a changed copy of R/spec.R, R/reflexes.R or
#   R/ui.R sourced into the global environment) must make at least one check fail. Nothing on disk is changed. The mutations: a card given the whole txt again (1);
#   the headline's lines not broken (2); no style look for the description (3); the title block not put over the designed picture (4, 7); no description in it (5);
#   the title left at the panel's edge (6).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- FALSE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> night05 begin", smoke):grep("^# <<< night05 end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(spec.R = read_file("spec.R"), reflexes.R = read_file("reflexes.R"), ui.R = read_file("ui.R"))

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
  mut("M01", "a card is given the whole txt again (headline change throws a design away)", "reflexes.R",
      "design_card_txt <- function(txt) txt[setdiff(names(txt), c(\"title\", \"subtitle\", \"caption\"))]", "design_card_txt <- function(txt) txt"),
  mut("M02", "the headline's lines are not broken to fit", "spec.R", "    paste(lines, collapse = ", "    paste(text, collapse = "),
  mut("M03", "a design that styles no subtitle gets no look for the description", "reflexes.R", "  if (grepl(\"plot.subtitle\", code %||% \"\", fixed = TRUE)) return(NULL)", "  return(NULL)"),
  mut("M04", "the title block is not put over the designed picture", "reflexes.R", "  plot + design_heads_theme(inp, code) + ggplot2::labs(title = h$title, subtitle = h$subtitle)", "  plot"),
  mut("M05", "the description is left out of the title block", "spec.R", "list(if (!is.null(s$.headline)) s$.description, s$subtitle)", "list(s$subtitle)"),
  mut("M06", "the title stays at the panel's edge", "reflexes.R", "  ggplot2::theme(plot.title.position = \"plot\") + if", "  ggplot2::theme() + if"),
  mut("M07", "the export does not use the title block", "ui.R", "r$plot = design_with_heads(inp, r$plot, dz$code)", "r$plot = r$plot"))
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
