# Mutation runs for the Phase 12c checks (tests/smoke.R, the part between `>>> 12c begin` and `<<< 12c end`: 12c-1 to 12c-3, Chrome with real time driven by
#   Node, headed, the CPU slowed four times). No model call. Run from inside chaRt/, one R process at a time (about two minutes for each mutation):
#     Rscript --no-init-file tests/mutate_12c.R                 every mutation
#     Rscript --no-init-file tests/mutate_12c.R M01 M05         only these
#     Rscript --no-init-file tests/mutate_12c.R NONE            the baseline only
# What it does: as tests/mutate_12b.R, for the 12c block: the baseline on the real code, then each mutation (a changed copy of R/ui.R sourced into the global
#   environment; the block builds its page anew) must make at least one check fail. Nothing on disk is changed. At least one mutation for each check: the
#   frame-0 picture not shown, or not in the page (12c-1); the Replay button's room not kept, the frames back in the box (12c-2); a card's picture kept to 700
#   pixels, the two columns back, no phone drawing on a phone (12c-3); the page's frames with bands, the page's top band gone, a charts/ PNG without its bands (12c-4).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
suppressMessages(app <- shiny::shinyAppDir("."))
run_fast <- TRUE
run_heavy <- TRUE
smoke <- readLines(file.path("tests", "smoke.R"), encoding = "UTF-8")
block <- parse(text = smoke[grep("^# >>> 12c begin", smoke):grep("^# <<< 12c end", smoke)], keep.source = FALSE)
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
  mut("M01", "the frame-0 picture is never shown", "ui.R",
      "html.motion-js .motion:not([data-still]) img.motion-first{display:block;", "html.motion-js .motion:not([data-still]) img.motion-first{display:none;"),
  mut("M02", "no frame-0 picture in the page", "ui.R", "if (!is.null(first)) tags$img(class = \"motion-first\"", "if (FALSE) tags$img(class = \"motion-first\""),
  mut("M03", "the Replay button's room is not kept", "ui.R", "html.motion-js .motion .motion-replay[hidden]{display:inline-block;visibility:hidden;}", "html.motion-js .motion .motion-replay[hidden]{}"),
  mut("M04", "the frames back inside each box (before the rest of the card)", "ui.R",
      "motion_frames_id <- function(it) if (!is.null(it$id)) paste0(\"motion-frames-\", it$id)", "motion_frames_id <- function(it) NULL"),
  mut("M05", "a picture in a card with its row kept to 700 pixels again", "ui.R", ".card.full img,.card.full .widget{max-width:none;}", ".card.full .widget{max-width:none;}"),
  mut("M06", "the two columns of Phase 10b back", "ui.R", ".card.full{grid-column:1/-1;}",
      ".card.full{grid-column:1/-1;}.card.full:not(.table-card){display:grid;grid-template-columns:minmax(0,62fr) minmax(0,38fr);column-gap:1.5rem;}.card.full:not(.table-card)>h2{grid-column:1/-1;}.card.full:not(.table-card)>.slot{grid-column:1;grid-row:2/8;}"),
  mut("M07", "no phone drawing on a phone", "ui.R", "@media screen and (max-width:599px){.motion-wrap", "@media screen and (max-width:1px){.motion-wrap"),
  mut("M08", "the page's frames carry the marking's bands again", "ui.R", "bare = TRUE, web = dash_web(size)), size)", "bare = TRUE, web = dash_web(size), marking = APP_CLASSIFICATION), size)"),
  mut("M09", "the page loses its own top band", "ui.R", "dash_band(mark, \"top\"), tags$div(class = \"page\",
    tags$header(class = \"masthead\", tags$h1(dash_heading_text(", "NULL, tags$div(class = \"page\",
    tags$header(class = \"masthead\", tags$h1(dash_heading_text("),
  mut("M10", "a chart's PNG in charts/ without its bands", "ui.R",
      "spec_png(p, file.path(stage, pic_file), dpi = DASH_DPI, kind = kind, marking = marking))", "spec_png(p, file.path(stage, pic_file), dpi = DASH_DPI, kind = kind))"))
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
