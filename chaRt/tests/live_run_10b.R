# Phase 10b item 10: the live check that closes the phase. Makes real model calls (Sonnet only), at most 6, and costs a little.
# Run from inside chaRt/, in PowerShell or the RStudio terminal (not Git Bash):   Rscript --no-init-file tests/live_run_10b.R
# The key comes from the environment (ANTHROPIC_API_KEY, in .Renviron): a test script may read it, the app never does. It is
#   passed to the model call and never printed; every line written is scrubbed of it as well. Without a key no call is made.
#
# On tests/data/orders.csv (3,000 synthetic orders; -99 and N/A mean missing; a row is one order), through the same code the app
#   runs (live_chat() in tests/live_gallery.R). The column dictionary saved by the Phase 10 live run (tests/live_replies_10.rds) is
#   reused, so the label call is not made. Three turns, one chat_turn() each:
#   1 "which categories grew fastest?"                                    expect indexed lines in one panel (index: first, no facet)
#   2 "is unit price related to units?"                                   expect a scatter, density auto (3,000 rows)
#   3 "how has revenue changed month by month? show the trend"            expect a line of revenue by month with smooth set
#   then a headline and summary for every chart (summarize_charts(), one call per 8 charts); then every chart on the canvas is
#   exported through build_dashboard() in the Briefing style marked "UNCLASSIFIED//FOR TEST", the trend as a video and the rest
#   pictures, unpacked into tests/dashboard_final/ (git-ignored) to be opened and looked at.
# The turns are sent as written; a turn that makes a form other than the expected one is reported, not worked around.
# At most LIVE10_MAX_CALLS calls are made (counted; the call after the limit is refused and the run says so): 3 turns +
#   1 summary call = 4 planned, 2 left for repairs.
# What is written: tests/live_run_10b.out (committed text): the labels, each turn's reply and specs, the form each turn chose against
#   the form expected, each headline and summary with its check, the calls and the dashboard's files. No key, no row of the file.
# CHART_LIVE_DRY=1 makes no call and needs no key: it takes four gold specs of the forms (tests/gold_specs.yaml) with stand-in
#   headlines to run the export step, and writes tests/live_run_10b_dry.out (git-ignored).

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
invisible(shiny::shinyAppDir("."))
if (!exists("live_chat")) source(file.path("tests", "live_gallery.R"))

LIVE10_MAX_CALLS <- 6L
LIVE10_TURNS <- list(
  list(message = "which categories grew fastest?", select = "none"),
  list(message = "is unit price related to units?", select = "none"),
  list(message = "how has revenue changed month by month? show the trend", select = "none"))
LIVE10_EXPECT <- c("indexed lines in ONE panel (line, index: first, no facet)", "a scatter, density auto or absent", "a line of revenue by month with smooth set")
LIVE10_STYLE <- "briefing"
LIVE10_MARKING <- "UNCLASSIFIED//FOR TEST"
LIVE10_DIR <- file.path("tests", "dashboard_final")

dry <- identical(Sys.getenv("CHART_LIVE_DRY"), "1")
key <- Sys.getenv("ANTHROPIC_API_KEY")
out_file <- file.path("tests", if (dry) "live_run_10b_dry.out" else "live_run_10b.out")
if (file.exists(out_file)) file.remove(out_file)

say <- function(...) {
  txt = paste0(c(...), collapse = "")
  if (nzchar(key)) txt = gsub(key, "[key]", txt, fixed = TRUE)
  cat(txt, "\n", sep = "")
  cat(txt, "\n", sep = "", file = out_file, append = TRUE)
}

say("chaRt Phase 10 Part E: live run on tests/data/orders.csv, ", format(Sys.time(), "%Y-%m-%d %H:%M"), if (dry) " (DRY: no call, gold specs and stand-in headlines)")
home <- APP_PROFILES$home
if (grepl("opus", home$id, ignore.case = TRUE)) stop("Live tests call Sonnet models only; '", home$id, "' is an Opus model.", call. = FALSE)
say("Model: ", home$id, " at ", home$base_url, "; limit ", LIVE10_MAX_CALLS, " calls; the dashboard in the ", LIVE10_STYLE, " style, marked '", LIVE10_MARKING, "'")

# The saved dictionary stands in for label_columns() (no call): the Phase 10 live run's labels, with the zero-row calls table.
saved <- if (file.exists(file.path("tests", "live_replies_10.rds"))) readRDS(file.path("tests", "live_replies_10.rds"))$phase10 else NULL
if (!dry && !is.null(saved)) {
  label_columns <- function(codebook, ask, m) list(codebook = saved$cb, calls = saved$calls[0, ], error = NULL, row_is_guess = saved$row_is_guess)
  say("The column dictionary of the Phase 10 live run is reused (", sum(purrr::map_lgl(saved$cb$columns, function(e) identical(e$label_source, "ai_guess"))), " labels): no label call.")
}
run <- NULL
if (dry) {
  read = reread_data(LIVE_ORDERS, basename(LIVE_ORDERS), LIVE_ORDERS_MISSING)
  cb = read$codebook
  cb$row_is = LIVE_ORDERS_ROW
  gold = yaml::read_yaml(file.path("tests", "gold_specs.yaml"))
  pick = function(pat) purrr::detect(gold, function(g) grepl(pat, g$name, fixed = TRUE))$spec
  specs = list(pick("revenue by region in 2022 and 2024 (dumbbell)"), pick("3,000 points (density auto"), pick("unit price by channel (violin with its box)"),
               pick("monthly revenue with a 6-month moving average"))
  canvas = purrr::imap(specs, function(s, i) new_chart(paste0("c", i), s))
  stories = purrr::imap(canvas, function(ch, i) list(id = ch$id, headline = paste("Stand-in headline for chart", i), summary = paste0("A stand-in summary for chart ", i, "."), checked = TRUE,
                                                   problems = character(0), repaired = FALSE, facts = ""))
  run = list(cb = cb, canvas = canvas, stories = stories, turns = list(), calls = tibble::tibble())
} else if (!nzchar(key)) {
  say("Result: no call was made; ANTHROPIC_API_KEY is not set.")
  quit(status = 0)
} else {
  run = live_chat(home, key, say, rds = file.path("tests", "live_replies_10b.rds"), max_calls = LIVE10_MAX_CALLS, plan = LIVE10_TURNS, phase = "phase10b")
  if (is.null(run)) { say("The run stopped before any chart was made (see above); there is nothing to export."); quit(status = 0) }
}
read <- reread_data(LIVE_ORDERS, basename(LIVE_ORDERS), LIVE_ORDERS_MISSING)
data <- read$read$data
cb <- run$cb

# ---- the form each turn chose, against the form expected ----------------------------------------------------------------------
say("\n---- The form each turn chose, against the form expected")
by_id <- function(xs, id) purrr::detect(xs, function(x) identical(x$id, id))
describe <- function(sp) {
  f = c(sp$family, if (!is.null(sp$index) && !identical(sp$index, "none")) paste0("index: ", sp$index), if (!is.null(sp$smooth) && !identical(sp$smooth, "none")) paste0("smooth: ", sp$smooth),
        if (!is.null(sp$shape) && !identical(sp$shape, "box")) paste0("shape: ", sp$shape), if (!is.null(sp$density)) paste0("density: ", sp$density),
        if (!is.null(sp$x)) paste0("x: ", paste(sp$x, collapse = "+")), if (!is.null(sp$y)) paste0("y: ", paste(sp$y, collapse = "+")), if (!is.null(sp$color)) paste0("color: ", sp$color))
  paste(f, collapse = ", ")
}
if (!dry) purrr::walk(run$turns, function(t) {
  ids = unlist(t$added)
  now = if (length(ids)) paste(purrr::map_chr(ids, function(id) paste0(id, " = ", describe(by_id(run$canvas, id)$spec))), collapse = " | ")
        else if (!is.null(t$selected)) paste0("changed ", t$selected, " in place; now ", describe(by_id(run$canvas, t$selected)$spec)) else "no chart"
  say("  turn ", t$n, " \"", t$message, "\": kind ", t$kind, "; expected ", LIVE10_EXPECT[[t$n]], "; chose ", now)
})
say("  the canvas at the end: ", paste(purrr::map_chr(run$canvas, function(ch) paste0(ch$id, " (", describe(ch$spec), ")")), collapse = "; "))

# ---- the export ---------------------------------------------------------------------------------------------------------------
say("\n---- Export: every chart on the canvas, ", LIVE10_STYLE, " style, marked '", LIVE10_MARKING, "'")
canvas_ids <- purrr::map_chr(run$canvas, "id")
fam <- purrr::map_chr(run$canvas, function(ch) ch$spec$family %||% "")
sm <- purrr::map_lgl(run$canvas, function(ch) !is.null(ch$spec$smooth) && !identical(ch$spec$smooth, "none"))
tl <- which(fam == "line" & purrr::map_lgl(run$canvas, function(ch) identical(ch$spec$x, "order_month")))
i_vid <- if (any(sm)) which(sm)[1] else if (length(tl)) tl[1] else length(canvas_ids)
modes <- rep("picture", length(canvas_ids)); modes[i_vid] <- "video"
say("  modes: ", paste(canvas_ids, modes, sep = "=", collapse = ", "))
palette <- utils::modifyList(chart_palette_default(), list(style = LIVE10_STYLE))
items <- purrr::map2(canvas_ids, modes, function(id, mode) {
  ch <- by_id(run$canvas, id)
  s <- by_id(run$stories, id)
  story <- if (!is.null(s) && is_text1(s$headline)) list(headline = s$headline, summary = s$summary, hash = spec_hash(ch$spec), data = "d", facts = s$facts %||% "", spec = ch$spec,
                                                         problems = s$problems %||% character(0))
  list(id = id, chart = ch, story = story, mode = mode, stale = NA_character_)
})
settings <- list(marking = LIVE10_MARKING, title = "Orders: growth, prices and the trend", subtitle = "Three questions about 3,000 synthetic orders", author = "chaRt live run",
                 date = Sys.Date(),
                 intro = paste0("This page was made by chaRt from tests/data/orders.csv. The headlines were written by ", home$id, " and every number in them was checked against the numbers R computed for the chart.\n\n",
                                "The revenue trend is a video; the rest are pictures."),
                 boxes = c("rows", "columns", "third"), keys = character(0))
zip_file <- file.path(tempfile("live10b_"), "dashboard_final.zip")
dir.create(dirname(zip_file))
built <- tryCatch(build_dashboard(items, data, cb, palette, settings, LIVE_ORDERS, zip_file, model = home$id), error = function(e) e)
if (inherits(built, "error")) {
  say("The export failed: ", conditionMessage(built))
} else {
  if (dir.exists(LIVE10_DIR)) unlink(LIVE10_DIR, recursive = TRUE)
  dir.create(LIVE10_DIR, recursive = TRUE)
  zip::unzip(built$zip, exdir = LIVE10_DIR)
  say("  built in ", sprintf("%.1f", built$seconds), " s: ", basename(built$zip), ", ", format(round(built$bytes / 1e6, 2), nsmall = 2), " MB; modes: ", paste(built$modes, collapse = ", "),
      "; device ", built$device, "; rows to themselves: ", paste(built$full, collapse = ", "))
  fb = built$fallbacks[!is.na(built$fallbacks)]
  if (length(fb)) say("  FELL BACK to a picture: ", paste(names(fb), fb, sep = " - ", collapse = "; "))
  say("  unpacked into ", LIVE10_DIR, "/ (git-ignored):")
  purrr::walk(names(built$files), function(f) say(sprintf("    %-52s %10s bytes", f, format(built$files[[f]], big.mark = ","))))
}
say("\nDone. Calls made: ", if (dry) 0L else nrow(run$calls), " of ", LIVE10_MAX_CALLS, " allowed.")
