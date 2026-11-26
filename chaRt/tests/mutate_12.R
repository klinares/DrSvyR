# Mutation runs for the Phase 12 checks (tests/smoke.R, the part between `>>> 12 begin` and `<<< 12 end`: 12A-1 and 12C-1 to 12C-5). No model call.
#   Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_12.R                 every mutation
#     Rscript --no-init-file tests/mutate_12.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_12.R NONE            the baseline only
# What it does: loads the app as Connect does, runs the 12 block once on the real code (the baseline: every check must pass), then, for each mutation,
#   sources a changed copy of one file of R/ (one or more pieces of its text replaced) into the global environment, runs the block again and says which checks
#   failed; each mutation must make at least one fail. The changed copy is also handed to the new R process of 12A-1 (`p12_override`), which sources it after
#   the app. The original file is sourced again after each. Nothing on disk is changed. One mutation for each check, at least: the app needing av (12A-1),
#   frames not packed and the frame rate changed (12C-1), a last frame that is not the static chart (12C-2), scales that move (12C-3), bands only on the last
#   frame (12C-4), and the player stopping early, not playing on view, Replay not playing, reduced motion ignored, print not protected and a request made (12C-5).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- TRUE   # 12C-5 (Chrome) is in the heavy run of the smoke test; here every check of the block runs
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> 12 begin", smoke):grep("^# <<< 12 end", smoke)], keep.source = FALSE)
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
  mut("M01", "motion needs the av package", "spec.R", "video_available <- function() chart_device_kind() %in% c(\"ragg\", \"cairo\")",
      "video_available <- function() requireNamespace(\"av\", quietly = TRUE) && chart_device_kind() %in% c(\"ragg\", \"cairo\")"),
  mut("M02", "identical neighbouring frames are each kept", "spec.R", "  runs = rle(keys)", "  runs = rle(seq_along(keys))"),
  mut("M03", "24 frames a second again", "spec.R", "SPEC_VIDEO_FPS <- 12L", "SPEC_VIDEO_FPS <- 24L"),
  mut("M04", "the last frame is not the finished chart", "spec.R", "  purrr::iwalk(seq(0, 1, length.out = n), function(p, i) {\n    video_draw(", "  purrr::iwalk(seq(0, 0.97, length.out = n), function(p, i) {\n    video_draw("),
  mut("M05", "each frame is built anew, so its scales follow its data", "spec.R", "  b = ctx$built\n  b$data = purrr::map(seq_along(ctx$roles)",
      "  b = ggplot2::ggplot_build(ctx$plot + ggplot2::expand_limits(y = progress * 2e6))\n  b$data = purrr::map(seq_along(ctx$roles)"),
  mut("M06", "the bands are drawn on the last frame only", "spec.R", "canvas[[\"height\"]], dpi, marking = marking)\n    if (is.function(on_frame)) on_frame(i, n)",
      "canvas[[\"height\"]], dpi, marking = if (p >= 1) marking)\n    if (is.function(on_frame)) on_frame(i, n)"),
  mut("M07", "the player stops five frames before the last", "ui.R", "if (i >= d.frames.length) {", "if (i >= d.frames.length - 5) {"),
  mut("M08", "the player does not start when the card comes into view", "ui.R", "if (inView(box)) { box._seen = true; play(box); }", "if (inView(box)) { box._seen = true; }"),
  mut("M09", "Replay does not play", "ui.R", "btn.addEventListener('click', function () { box._seen = true; box.removeAttribute('data-failed'); release(box); play(box); });", "btn.addEventListener('click', function () { box._seen = true; box.removeAttribute('data-failed'); release(box); });"),
  mut("M10", "reduced motion is not asked about", "ui.R", "var reduced = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };", "var reduced = function () { return false; };"),
  mut("M11", "print shows the canvas mid-play (no print rules, no stop before print)", "ui.R",
      c("  \"@media print{.motion canvas.motion-canvas,.motion .motion-replay{display:none !important;}.motion img.motion-still{visibility:visible !important;}}\\n\")",
        ".motion canvas.motion-canvas,.motion .motion-replay{display:none !important;}.motion img.motion-still{visibility:visible !important;max-width:100%;}",
        "  window.addEventListener('beforeprint', function () { boxes.forEach(function (box) { if (box._images) { box._seen = true; rest(box); } }); });\n"),
      c("  \"\")", "", "")),
  mut("M12", "the player asks the network for something", "ui.R", "    boxes.push(box);\n", "    boxes.push(box);\n    var probe = new Image(); probe.src = 'codebook.html';\n"))
wanted <- commandArgs(trailingOnly = TRUE)
if (length(wanted)) mutations <- purrr::keep(mutations, function(m) m$id %in% wanted)

p12_override <- NULL
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
  p12_override <<- f
  t0 <- Sys.time()
  r <- run_block()
  p12_override <<- NULL
  orig <- tempfile(fileext = ".R"); writeLines(txt, orig, useBytes = TRUE); source_file(orig)
  cat(sprintf("%s  %-72s %3d failed: %s%s  (%.0f s)\n", m$id, m$what, length(r$failed), paste(r$failed, collapse = " "),
              if (!is.null(r$aborted)) paste0("  [block stopped: ", substr(r$aborted, 1, 60), "]") else "", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  list(id = m$id, what = m$what, applied = TRUE, failed = r$failed, aborted = r$aborted)
})
bad_apply <- purrr::keep(results, function(r) !r$applied)
caught <- purrr::map_lgl(results, function(r) length(r$failed) > 0L || !is.null(r$aborted))
cat("\n", sum(caught), " of ", length(results), " mutations made at least one check fail", if (length(bad_apply)) paste0("; did not apply: ", paste(purrr::map_chr(bad_apply, "id"), collapse = ", ")), "\n", sep = "")
if (!all(caught) || length(bad_apply) || length(base$failed)) quit(status = 1)
