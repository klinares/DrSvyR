# Mutation runs for the Phase 11 Part C checks (tests/smoke.R, the part between `>>> 11C begin` and `<<< 11C end`). No model call.
#   Run from inside chaRt/, one R process at a time:
#     Rscript --no-init-file tests/mutate_11C.R                 every mutation
#     Rscript --no-init-file tests/mutate_11C.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_11C.R NONE            the baseline only
# What it does: loads the app as Connect does, runs the 11C block once on the real code (the baseline: every check must pass), then, for each mutation,
#   sources a changed copy of one file of R/ (one piece of its text replaced) into the global environment, runs the block again and says which checks
#   failed; each mutation must make at least one fail (a block that stops is counted: the check it stopped in did not pass). The original file is sourced
#   again after each. Nothing on disk is changed. The safeguards mutated: the motion's direction (draw and wipe from the left, rise from the bottom and, for
#   sideways bars, from the left), fade by opacity, the text waiting for the marks and then coming in, the last frame being the finished picture itself, the frame
#   having no marks in it, which layer is text and which an annotation, the layers being transparent, theme-free and without the bands, the check that the
#   three drawings add up to the finished picture, the patchwork fallback, the card's proportions with the bands, and the export using the design for a
#   designed video.

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- TRUE   # 11C-7 and 11C-8 (the exports) are in the heavy run of the smoke test; here every check of the block runs
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> 11C begin", smoke):grep("^# <<< 11C end", smoke)], keep.source = FALSE)
read_file <- function(f) paste(readLines(file.path("R", f), encoding = "UTF-8"), collapse = "\n")
texts <- list(spec.R = read_file("spec.R"), ui.R = read_file("ui.R"), theme.R = read_file("theme.R"))

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
  mut("M01", "draw and wipe come in from the right", "spec.R", "else if (along_x) design_run_rel(hw[[2]], ink$cols[[1]], ink$cols[[2]])", "else if (along_x) rev(design_run_rel(hw[[2]], ink$cols[[1]], ink$cols[[2]]))"),
  mut("M02", "rise comes in from the top", "spec.R", "else rev(design_run_rel(hw[[1]], ink$rows[[1]], ink$rows[[2]]))", "else design_run_rel(hw[[1]], ink$rows[[1]], ink$rows[[2]])"),
  mut("M03", "sideways bars rise from the bottom, not from the left", "spec.R", "(identical(motion, \"rise\") && horizontal)", "(identical(motion, \"rise\") && FALSE)"),
  mut("M04", "fade shows the marks at once (no opacity ramp)", "spec.R", "if (is.null(rel)) return(ab * e)", "if (is.null(rel)) return(ab)"),
  mut("M05", "the text does not wait for the marks (it is on from the first frame)", "spec.R", "      k = video_ease(ph$labels)\n", "      k = 1\n"),
  mut("M06", "the text never comes in", "spec.R", "      if (k > 0) design_over(img, layers$text$rgb, ac * k) else img", "      img"),
  mut("M07", "the last frame is the composed layers, not the finished picture", "spec.R", "if (p >= 1) file.copy(full_file, files[[i]], overwrite = TRUE) else design_write_png(compose(p), files[[i]])", "design_write_png(compose(p), files[[i]])"),
  mut("M08", "the frame drawing keeps the data and text layers", "spec.R", "f_frame = draw(\"frame\", all, FALSE, TRUE, NULL)", "f_frame = draw(\"frame\", integer(0), FALSE, TRUE, NULL)"),
  mut("M09", "a text geom is a data layer", "spec.R", "if (inherits(layer$geom, DESIGN_TEXT_GEOMS) || grepl(\"^Geom(Text|Label|Richtext|Textbox)\", class(layer$geom)[1], ignore.case = TRUE)) return(\"text\")", "if (FALSE) return(\"text\")"),
  mut("M10", "an annotate() or rule layer is a data layer", "spec.R", "  if (fixed) \"annotation\" else \"data\"", "  \"data\""),
  mut("M11", "the frame drawing leaves out the classification bands", "spec.R", "f_frame = draw(\"frame\", all, FALSE, TRUE, NULL)", "f_frame = draw(\"frame\", all, FALSE, FALSE, NULL)"),
  mut("M12", "the three drawings are not compared with the finished picture", "spec.R", "          else if (check$share > DESIGN_VIDEO_SHARE)", "          else if (FALSE)"),
  mut("M13", "a patchwork is drawn in layers", "spec.R", "if (length(design_parts(plot)) > 1L) return(", "if (FALSE) return("),
  mut("M14", "the video is as high as the design without its bands", "spec.R", "h_px = 2L * as.integer(round((inp$size[[\"height\"]] + 2 * band) * dpi / 2))", "h_px = 2L * as.integer(round(inp$size[[\"height\"]] * dpi / 2))"),
  mut("M15", "the export makes a designed card's video from the standard drawing", "ui.R", "    if (isTRUE(m$designed)) {\n      v = tryCatch(dash_design_video(", "    if (FALSE) {\n      v = tryCatch(dash_design_video("),
  mut("M16", "chart_device() ignores a transparent background", "theme.R", "ragg::agg_png(file, width = w, height = h, units = \"px\", res = dpi, background = bg)", "ragg::agg_png(file, width = w, height = h, units = \"px\", res = dpi)"),
  mut("M17", "the theme of the data and text layers is not made invisible", "spec.R", "  if (clear) b$plot$theme = b$plot$theme + design_clear_theme(plot)", "  if (FALSE) b$plot$theme = b$plot$theme + design_clear_theme(plot)"))
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
