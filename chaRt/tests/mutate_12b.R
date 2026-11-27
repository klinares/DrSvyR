# Mutation runs for the Phase 12b checks (tests/smoke.R, the part between `>>> 12b begin` and `<<< 12b end`: 12b-1 to 12b-4, Chrome with real time driven by
#   Node). No model call. Run from inside chaRt/, one R process at a time (about two minutes for each mutation):
#     Rscript --no-init-file tests/mutate_12b.R                 every mutation
#     Rscript --no-init-file tests/mutate_12b.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_12b.R NONE            the baseline only
# What it does: loads the app as Connect does, runs the 12b block once on the real code (the baseline: every check must pass), then, for each mutation, sources a
#   changed copy of R/ui.R (one or more pieces of its text replaced) into the global environment, runs the block again (it builds its page anew, so the page
#   carries the changed player) and says which checks failed; each mutation must make at least one fail. The original file is sourced again after each.
#   Nothing on disk is changed. At least one mutation for each check: the player starting before the frames are decoded (as in Phase 12), the finished picture not hidden
#   before the first play, no mark in <head> (12b-1); the print rule for the picture taken away (12b-2); no fallback when a frame cannot be read (12b-3); the
#   images not let go, made for every card at load, and the canvas drawn by the graphics card (12b-4); and (Phase 12c) the frame-0 picture shown in print (12b-2).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- TRUE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> 12b begin", smoke):grep("^# <<< 12b end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(ui.R = read_file("ui.R"))

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
  mut("M01", "the player starts before the frames are decoded, frame 0 not drawn first (the Phase 12 player, with no frame-0 picture in the page)", "ui.R",
      c("if (!box._ready) { box._want = true; prepare(box); return; }", "      draw(box, 0);\n      return Promise.all", "if (!is.null(first)) tags$img(class = \"motion-first\""),
      c("if (!box._ready) { prepare(box); }", "      return Promise.all", "if (FALSE) tags$img(class = \"motion-first\"")),
  mut("M02", "the finished picture is not hidden before the first play", "ui.R",
      "\"html.motion-js .motion:not([data-still]) img.motion-still,.motion[data-playing] img.motion-still{visibility:hidden;}\\n\",",
      "\".motion[data-playing] img.motion-still{visibility:hidden;}\\n\","),
  mut("M03", "no mark in <head>: the page is marked only when the player runs, at the end of the body", "ui.R",
      "                   if (any(purrr::map_chr(items, \"mode\") == \"video\")) tags$script(HTML(MOTION_HEAD_JS)),\n", ""),
  mut("M04", "print does not show the finished picture of a card that has not played (both print rules)", "ui.R",
      c("\"@media print{.motion canvas.motion-canvas,.motion .motion-replay,.motion img.motion-first{display:none !important;}.motion img.motion-still{visibility:visible !important;}}\\n\"",
        ".motion canvas.motion-canvas,.motion .motion-replay{display:none !important;}.motion img.motion-still{visibility:visible !important;max-width:100%;}"),
      c("\"@media print{.motion canvas.motion-canvas,.motion .motion-replay,.motion img.motion-first{display:none !important;}}\\n\"",
        ".motion canvas.motion-canvas,.motion .motion-replay{display:none !important;}.motion img.motion-still{max-width:100%;}")),
  mut("M05", "a card whose frames cannot be read is not put back on its finished chart", "ui.R",
      "var fail = function () { if (box._token !== token) return; rest(box); box._seen = true;", "var fail = function () { if (box._token !== token) return; box._seen = true;"),
  mut("M06", "the images are not let go when the motion stops", "ui.R",
      "box._images = null; box._frames = null; box._ready = false;", "box._frames = box._frames;"),
  mut("M07", "every card's images are made at load", "ui.R",
      "      else if (near(box)) prepare(box);\n      else if (box._images) release(box);", "      else prepare(box);"),
  mut("M08", "the canvas is drawn by the graphics card", "ui.R", "c.getContext('2d', { willReadFrequently: true })", "c.getContext('2d')"),
  mut("M09", "print shows the frame-0 picture over the finished one (Phase 12c)", "ui.R",
      "\"@media print{.motion canvas.motion-canvas,.motion .motion-replay,.motion img.motion-first{display:none !important;}",
      "\"@media print{.motion canvas.motion-canvas,.motion .motion-replay{display:none !important;}.motion img.motion-first{display:block !important;}"))
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
