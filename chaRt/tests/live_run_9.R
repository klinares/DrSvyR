# Phase 9 Part C: the live run that ends the phase. Makes real model calls (Sonnet only), at most 10, and costs a little.
# Run from inside chaRt/, in PowerShell or the RStudio terminal (not Git Bash):   Rscript --no-init-file tests/live_run_9.R
# The key comes from the environment (ANTHROPIC_API_KEY, in .Renviron): a test script may read it, the app never does. It is
#   passed to the model call and never printed; every line written is scrubbed of it as well. Without a key no call is made.
#
# On tests/data/orders.csv (3,000 synthetic orders; -99 and N/A mean missing; a row is one order), through the same code the app
#   runs (live_chat() in tests/live_gallery.R, which calls label_columns(), chat_turn() and summarize_charts()):
#   (a) label the columns (one call);
#   (b) "How has revenue changed by region?", (c) "which product categories bring in the most revenue?",
#   (d) "is satisfaction lower when shipping takes longer?" (each one chat_turn(), one call, plus any repair, counted);
#   (e) a headline and summary for every chart on the canvas (summarize_charts(): one call for up to 8 charts, plus any repair);
#   (f) the first chart of each of the three questions is exported as a dashboard in the Magazine style through build_dashboard():
#       the first as a picture, the second as an interactive chart, the third as a video, unpacked into tests/dashboard_live/
#       (git-ignored) to be opened and looked at.
# A column that the wording does not match is not worked around: the question is sent as written and the printout says what the
#   app did. At most LIVE9_MAX_CALLS calls are made (counted, the call after the limit is refused and the run says so).
# What is written: tests/live_run_9.out (committed text): the model's labels, each question's reply, its specs as YAML, each headline
#   and summary with its check, the calls, the dashboard's files and sizes. The chats' text and specs only; no key, and no row of the
#   file beyond what a chart or a fact of the app shows.
# CHART_LIVE_DRY=1 makes no call and needs no key: it uses three hand-written stand-in charts with stand-in headlines to run the
#   export step (f), and writes tests/live_run_9_dry.out instead (git-ignored). It is how the export step is tried before a live run.

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
invisible(shiny::shinyAppDir("."))
if (!exists("live_chat")) source(file.path("tests", "live_gallery.R"))

LIVE9_MAX_CALLS <- 10L
LIVE9_TURNS <- list(
  list(message = "How has revenue changed by region?", select = "none"),
  list(message = "which product categories bring in the most revenue?", select = "none"),
  list(message = "is satisfaction lower when shipping takes longer?", select = "none"))
LIVE9_MODES <- c("picture", "interactive", "video")   # how the first chart of each question goes into the dashboard
LIVE9_STYLE <- "magazine"
LIVE9_DIR <- file.path("tests", "dashboard_live")

dry <- identical(Sys.getenv("CHART_LIVE_DRY"), "1")
key <- Sys.getenv("ANTHROPIC_API_KEY")
out_file <- file.path("tests", if (dry) "live_run_9_dry.out" else "live_run_9.out")
if (file.exists(out_file)) file.remove(out_file)

# Every line goes to the console and to the file, with the key (if any) taken out.
say <- function(...) {
  txt = paste0(c(...), collapse = "")
  if (nzchar(key)) txt = gsub(key, "[key]", txt, fixed = TRUE)
  cat(txt, "\n", sep = "")
  cat(txt, "\n", sep = "", file = out_file, append = TRUE)
}

say("chaRt Phase 9 Part C: live run on tests/data/orders.csv, ", format(Sys.time(), "%Y-%m-%d %H:%M"), if (dry) " (DRY: no call, stand-in charts and headlines)")
home <- APP_PROFILES$home
if (grepl("opus", home$id, ignore.case = TRUE)) stop("Live tests call Sonnet models only; '", home$id, "' is an Opus model.", call. = FALSE)
say("Model: ", home$id, " at ", home$base_url, "; limit ", LIVE9_MAX_CALLS, " calls; the dashboard in the ", LIVE9_STYLE, " style")

# ---- (a) to (e): the calls ------------------------------------------------------------------------------------------------

run <- NULL
if (dry) {
  # three stand-in charts and headlines of about the length a model writes, drawn from the real file
  read = reread_data(LIVE_ORDERS, basename(LIVE_ORDERS), LIVE_ORDERS_MISSING)
  cb = read$codebook
  cb$row_is = LIVE_ORDERS_ROW
  specs = list(
    list(family = "line", x = "order_month", y = "revenue", fn = "sum", color = "region", title = "Revenue by month and region"),
    list(family = "bar", x = "product_category", y = "revenue", fn = "sum", sort = "value_desc", title = "Revenue by product category"),
    list(family = "scatter", x = "shipping_days", y = "satisfaction", title = "Satisfaction against shipping days", fit = "loess"))
  heads = c("West leads every month and the gap has widened since 2022", "Hardware brings in more revenue than any other category", "Satisfaction falls as shipping takes longer")
  canvas = purrr::imap(specs, function(s, i) new_chart(paste0("c", i), s))
  stories = purrr::imap(canvas, function(ch, i) list(id = ch$id, headline = heads[[i]], summary = paste0("A stand-in summary for chart ", i, "."), checked = TRUE, problems = character(0),
                                                   repaired = FALSE, facts = ""))
  run = list(cb = cb, canvas = canvas, stories = stories, turns = purrr::imap(canvas, function(ch, i) list(n = i, added = ch$id, kind = "charts")))
} else if (!nzchar(key)) {
  say("Result: no call was made; ANTHROPIC_API_KEY is not set.")
  quit(status = 0)
} else {
  run = live_chat(home, key, say, rds = file.path("tests", "live_replies_9.rds"), max_calls = LIVE9_MAX_CALLS, plan = LIVE9_TURNS, phase = "phase9")
  if (is.null(run)) { say("The run stopped before any chart was made (see above); there is nothing to export."); quit(status = 0) }
}
read <- reread_data(LIVE_ORDERS, basename(LIVE_ORDERS), LIVE_ORDERS_MISSING)
data <- read$read$data
cb <- run$cb

# ---- (f): the export --------------------------------------------------------------------------------------------------------

# The first chart each question added, in the order of the questions (a question that added no chart is said and skipped)
first_ids <- purrr::map(run$turns, function(t) if (length(t$added)) t$added[[1]])
say("\n---- Export: the first chart of each question")
purrr::walk2(seq_along(first_ids), first_ids, function(i, id) say("  question ", i, ": ", if (is.null(id)) "added no chart, so nothing to export from it" else paste0("chart ", id)))
ids <- unlist(purrr::compact(first_ids))
modes <- LIVE9_MODES[seq_along(first_ids)][!purrr::map_lgl(first_ids, is.null)]
if (!length(ids)) { say("No chart to export."); quit(status = 0) }
by_id <- function(xs, id) purrr::detect(xs, function(x) identical(x$id, id))
palette <- utils::modifyList(chart_palette_default(), list(style = LIVE9_STYLE))
items <- purrr::map2(ids, modes, function(id, mode) {
  ch <- by_id(run$canvas, id)
  s <- by_id(run$stories, id)
  story <- if (!is.null(s) && is_text1(s$headline)) list(headline = s$headline, summary = s$summary, hash = spec_hash(ch$spec), data = "d", facts = s$facts %||% "", spec = ch$spec,
                                                         problems = s$problems %||% character(0))
  list(id = id, chart = ch, story = story, mode = mode, stale = NA_character_)
})
settings <- list(title = "Orders: revenue, products and shipping", subtitle = "Three questions about 3,000 synthetic orders", author = "chaRt live run", date = Sys.Date(),
                 intro = paste0("This page was made by chaRt from tests/data/orders.csv. The headlines were written by ", home$id, " and every number in them was checked against the numbers R computed for the chart.\n\n",
                                "The first chart is a picture, the second is interactive and the third is a video."),
                 boxes = c("rows", "columns", "third"), keys = character(0))
zip_file <- file.path(tempfile("live9_"), "dashboard_live.zip")
dir.create(dirname(zip_file))
built <- tryCatch(build_dashboard(items, data, cb, palette, settings, LIVE_ORDERS, zip_file, model = home$id), error = function(e) e)
if (inherits(built, "error")) {
  say("The export failed: ", conditionMessage(built))
} else {
  if (dir.exists(LIVE9_DIR)) unlink(LIVE9_DIR, recursive = TRUE)
  dir.create(LIVE9_DIR, recursive = TRUE)
  zip::unzip(built$zip, exdir = LIVE9_DIR)
  say("  built in ", sprintf("%.1f", built$seconds), " s: ", basename(built$zip), ", ", format(round(built$bytes / 1e6, 2), nsmall = 2), " MB; modes: ", paste(built$modes, collapse = ", "),
      "; device ", built$device, "; rows to themselves: ", paste(built$full, collapse = ", "))
  fb = built$fallbacks[!is.na(built$fallbacks)]
  if (length(fb)) say("  FELL BACK to a picture: ", paste(names(fb), fb, sep = " - ", collapse = "; "))
  say("  unpacked into ", LIVE9_DIR, "/ (git-ignored):")
  purrr::walk(names(built$files), function(f) say(sprintf("    %-52s %10s bytes", f, format(built$files[[f]], big.mark = ","))))
}
say("\nDone. Calls made: ", if (dry) 0L else nrow(run$calls), " of ", LIVE9_MAX_CALLS, " allowed.")
