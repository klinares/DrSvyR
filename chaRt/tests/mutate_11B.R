# Mutation runs for the Phase 11 Part B checks (tests/smoke.R, the part between `>>> 11B begin` and `<<< 11B end`). No model call.
#   Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_11B.R                 every mutation
#     Rscript --no-init-file tests/mutate_11B.R M01 M07         only these
# What it does: loads the app as Connect does, runs the 11B block once on the real code (the baseline: every check must pass), then, for each mutation,
#   sources a changed copy of one file of R/ (one piece of its text replaced) into the global environment, runs the block again and says which checks
#   failed; each mutation must make at least one fail (a block that stops is counted: the check it stopped in did not pass). The original file is sourced
#   again after each. Nothing on disk is changed. The safeguards mutated: the rows of the analyst's file are never in the message, nor the values of identifier
#   and text columns; APP_DESIGN_IMAGES is honoured; at most one repair; at most two reviews; an office skill's text is kept nowhere; the chart keeps its
#   rule-drawn picture when a design fails and when a review breaks a good design; the picture goes to the transport; the skill reaches the message;
#   the export's marking; the chat phrases are R's own.

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
exprs <- parse(text = smoke, keep.source = FALSE)
# the two helpers the block takes from the smoke test's top level: the planted value, and the messy file's maker
purrr::walk(purrr::keep(as.list(exprs), function(e) is.call(e) && identical(as.character(e[[1]]), "<-") && is.symbol(e[[2]]) && as.character(e[[2]]) %in% c("SECRET", "make_messy")),
            eval, envir = globalenv())
block <- parse(text = smoke[grep("^# >>> 11B begin", smoke):grep("^# <<< 11B end", smoke)], keep.source = FALSE)

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
file_text <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(reflexes.R = file_text("reflexes.R"), ui.R = file_text("ui.R"), llm.R = file_text("llm.R"))
mut <- function(id, what, file, from, to) list(id = id, what = what, file = file, from = from, to = to)
mutations <- list(
  mut("M01", "the rows of a table of the file's own rows are sent when it is small", "reflexes.R",
      "if (!aggregated) return(\"Rows: not sent (this chart's marks are rows of the file).\")", "if (FALSE) return(\"Rows: not sent (this chart's marks are rows of the file).\")"),
  mut("M02", "the values of identifier and text columns are sent, not placeholders", "reflexes.R",
      "design_name_column <- function(x, e) (is.character(x) || is.factor(x)) &&", "design_name_column <- function(x, e) FALSE &&"),
  mut("M03", "APP_DESIGN_IMAGES is ignored: every picture may be sent", "reflexes.R",
      "design_image_ok <- function(setting, spec) switch(setting, all = TRUE, aggregated = !chart_from_rows(spec), FALSE)", "design_image_ok <- function(setting, spec) TRUE"),
  mut("M04", "a second repair call is made when the first repair is refused too", "reflexes.R",
      "    say_stage(\"drawing the repaired design and checking it\")\n    cur = attempt(code)\n",
      "    say_stage(\"drawing the repaired design and checking it\")\n    cur = attempt(code)\n    if (!cur$ok) { third = call(\"design\", repair_user, validate_design, repair = TRUE); code = design_reply_code(third$res$obj); cur = attempt(code) }\n"),
  mut("M05", "five reviews, not two", "reflexes.R", "DESIGN_REVIEW_ROUNDS <- 2L ", "DESIGN_REVIEW_ROUNDS <- 5L "),
  mut("M06", "the skill's text is kept in the design's record", "reflexes.R",
      "skill = list(id = skill$id, title = skill$title, version = skill$version, office = isTRUE(skill$office)), code = st$code,",
      "skill = list(id = skill$id, title = skill$title, version = skill$version, office = isTRUE(skill$office), text = skill$text), code = st$code,"),
  mut("M07", "a failed design is reported as a success (the chart does not keep its rule-drawn picture)", "reflexes.R",
      "failed = function(why) finish(FALSE, design_line(why, 240L))", "failed = function(why) finish(TRUE, design_line(why, 240L))"),
  mut("M08", "the model's change at a review is not run through the guard and the checks", "reflexes.R",
      "    a = attempt(new)\n", "    a = list(ok = TRUE, run = st$run)\n"),
  mut("M09", "the picture is drawn at 300 dpi, however wide that is", "reflexes.R",
      "dpi = min(DESIGN_IMAGE_DPI, floor(DESIGN_IMAGE_PX / inp$size[[\"width\"]]))", "dpi = 300"),
  mut("M10", "the skill is not in the message", "reflexes.R", "design_block(\"SKILL\", design_safe(skill$text))", "design_block(\"SKILL\", \"\")"),
  mut("M11", "the CSV beside a designed chart has no marking line", "ui.R", "  marking_prepend(file.path(stage, csv_file), marking_comment(marking))\n", ""),
  mut("M12", "\"design this\" and its kin are not recognised by R, so they go to the chat", "ui.R", "design_request <- function(msg) {\n", "design_request <- function(msg) {\n  return(FALSE)\n"),
  mut("M13", "llm_json() does not hand the pictures to the transport", "llm.R",
      "if (length(images)) complete(m, system_prompt, ask, max_tokens, key, images = images) else", "if (FALSE) NULL else"),
  mut("M14", "an aggregated table is taken for rows and the other way about (which pictures may leave)", "reflexes.R", "aggregated = !chart_from_rows(chart$spec), cb = cb", "aggregated = chart_from_rows(chart$spec), cb = cb"),
  mut("M15", "the export carries the design even when the card shows the standard drawing", "ui.R",
      "design_shown = function(chart_id) if (isTRUE(isolate(made$showd[[chart_id]]()))) design_current(chart_id)", "design_shown = function(chart_id) design_current(chart_id)"),
  mut("M16", "a review that says ok is not taken as the end of the reviewing (it asks again)", "reflexes.R",
      "    if (is.null(new) || identical(trimws(new), trimws(st$code))) {\n      st$done = TRUE\n", "    if (is.null(new) || identical(trimws(new), trimws(st$code))) {\n      st$done = FALSE\n"))
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
  cat(sprintf("%s  %-80s %2d failed: %s%s  (%.0f s)\n", m$id, m$what, length(r$failed), paste(r$failed, collapse = " "),
              if (!is.null(r$aborted)) paste0("  [block stopped: ", substr(r$aborted, 1, 60), "]") else "", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  list(id = m$id, what = m$what, applied = n, failed = r$failed, aborted = r$aborted)
})
bad_apply <- purrr::keep(results, function(r) r$applied != 1L)
caught <- purrr::map_lgl(results, function(r) length(r$failed) > 0L || !is.null(r$aborted))
cat("\n", sum(caught), " of ", length(results), " mutations made at least one check fail", if (length(bad_apply)) paste0("; did not apply: ", paste(purrr::map_chr(bad_apply, "id"), collapse = ", ")), "\n", sep = "")
if (!all(caught) || length(bad_apply) || length(base$failed)) quit(status = 1)
