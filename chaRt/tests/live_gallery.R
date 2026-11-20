# The live runs of chaRt and their page. Helpers sourced by tests/llm_check.R, which makes the calls;
#   run as a script, this file only rebuilds the page from the saved runs, with no call:
#     Rscript --no-init-file tests/live_gallery.R
#   live_summary() is Phase 5's ten headlines and summaries (LIVE_SUMMARY), saved as `phase5`; live_chat() is Phase 6's
#   twelve chat turns on tests/data/orders.csv (LIVE_TURNS) and then a headline and summary for every chart on the canvas,
#   saved as `phase6`. Both go through llm_json() with the key (Sonnet only, the key passed in and never printed), print what
#   each call cost and returned, and save everything, the raw replies included, to tests/live_replies.rds (git-ignored).
#   live_page() writes tests/live_gallery.html (git-ignored) from that file, one section for each run it holds: Phase 5 (each
#   chart with its headline above it, its summary and checks, its facts) and Phase 6 (the canvas as it ended).
#   The Phase 3 and Phase 4 runs (live_run(), live_refine()) went with the suggest and refine calls they tested.

source(file.path("tests", "gallery.R"))   # gold_path(): the course files and panel.csv

LIVE_RDS <- file.path("tests", "live_replies.rds")
LIVE_OUT <- file.path("tests", "live_gallery.html")
LIVE_DPI <- 96

# The labelled codebook and row guess of each file in a saved run, by file name (the Phase 3 run, which Phase 5 still uses).
live_labelled <- function(rds = LIVE_RDS) {
  if (!file.exists(rds)) return(NULL)
  run = readRDS(rds)
  purrr::set_names(purrr::map(run$files, function(f) list(codebook = f$label$codebook, row_is_guess = f$label$row_is_guess)),
                   purrr::map_chr(run$files, "file"))
}

# A file read and put through a codebook as the app would, with row_is given.
live_load <- function(lf, work_dir) {
  path = gold_path(list(file = lf$file), work_dir)
  if (is.null(path)) return(NULL)
  r = read_data(path, lf$file, lf$missing)
  cb = new_codebook(profile_data(r$data), lf$file, nrow(r$data), lf$missing, r$encoding)
  cb$row_is = lf$row_is
  list(path = path, data = r$data, cb = cb)
}

# llm_json() with the key, keeping every raw reply (and every failure) in order, and counting the calls. With max_calls, the
#   call after the last one allowed is not made: it fails with a sentence and `stopped` is set, so a runner can stop.
live_asker <- function(key, max_calls = Inf) {
  env = new.env()
  env$log = list()
  env$n = 0L
  env$stopped = FALSE
  env$refused = 0L
  env$ask = function(user, m, system_prompt = NULL, max_tokens, validate = NULL) {
    if (env$n >= max_calls) {
      env$stopped = TRUE
      env$refused = env$refused + 1L
      stop("The limit of ", max_calls, " calls is reached, so no further call is made.", call. = FALSE)
    }
    env$n = env$n + 1L
    r = tryCatch(llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens, validate = validate, key = key),
                 error = function(e) e)
    failed = inherits(r, "error")
    env$log[[length(env$log) + 1L]] = list(system = system_prompt, user = user, raw = if (failed) r$raw %||% NA_character_ else r$raw,
                                          error = if (failed) conditionMessage(r))
    if (failed) stop(r)
    r
  }
  env
}

fmt_calls <- function(calls) purrr::pmap_chr(calls, function(call, hash, chars, tokens_in, tokens_cached, tokens_out, seconds, repair, ok)
  sprintf("    %-8s%s %6.1f s, %6s chars, tokens in: fresh %6s, cached %6s; out %5s%s", call, if (repair) " (repair)" else "", seconds,
          format_num(chars), format_num(tokens_in), format_num(tokens_cached), format_num(tokens_out), if (!ok) ", FAILED" else ""))

# The calls of a run, as the totals line says them.
fmt_totals <- function(calls, say) {
  say("  tokens in: fresh ", format_num(sum(calls$tokens_in, na.rm = TRUE)), ", cached ", format_num(sum(calls$tokens_cached, na.rm = TRUE)),
      "; out ", format_num(sum(calls$tokens_out, na.rm = TRUE)))
}


# ---- Phase 5: headlines and summaries on hand-written charts --------------------------------------

# Ten charts from hand-written specs (no other call), across three files; the last is exploratory.
LIVE_SUMMARY <- list(
  list(file = "FH_disaggregated.csv", missing = "..", row_is = "one country", charts = list(
    list(id = "fh_bar", spec = list(family = "bar", x = "Country", y = "pr_2014", fn = "none", top_n = 10,
                                    title = "Countries with the highest political rights scores, 2014")),
    list(id = "fh_scatter", spec = list(family = "scatter", x = "cl_2014", y = "pr_2014", fit = "loess",
                                        highlight = list(column = "Country", values = list("Norway", "Cuba")),
                                        title = "Political rights against civil liberties, 2014")),
    list(id = "fh_hist", spec = list(family = "histogram", x = "pr_2014", title = "Political rights scores, 2014")))),
  list(file = "footballdata-1.csv", missing = character(0), row_is = "one player", charts = list(
    list(id = "fb_box", spec = list(family = "box", x = "Position", y = "Height", title = "Height by position")),
    list(id = "fb_nat", spec = list(family = "bar", x = "Nationality", fn = "count", top_n = 15, title = "The 15 most common nationalities")),
    list(id = "fb_heat", spec = list(family = "heatmap", x = "Position", y = "League", color = "Age", fn = "mean",
                                     title = "Mean age by league and position")),
    list(id = "fb_scatter", spec = list(family = "scatter", x = "Defence", y = "Attack", color = "Position",
                                        title = "Attack against defence, by position")))),
  list(file = "panel.csv", missing = character(0), row_is = "one region in one year", charts = list(
    list(id = "pn_slope", spec = list(family = "slope", x = "year", y = "revenue", color = "region", fn = "sum",
                                      filter = list(list(column = "year", op = "in", value = list(2015, 2024))),
                                      title = "Revenue by region, 2015 and 2024")),
    list(id = "pn_line", spec = list(family = "line", x = "year", y = "revenue", color = "region", facet = "region", fn = "sum",
                                     title = "Revenue by year, one panel per region")),
    list(id = "pn_bar", exploratory = TRUE, spec = list(family = "bar", x = "region", y = "revenue", fn = "sum", title = "Total revenue by region")))))

# The summaries, through summarize_inputs() and llm_json() with the key, on the codebooks labelled
#   in the saved run when it has them. Prints each call, each chart's facts, headline, summary and
#   checks, and the totals; adds the run to the saved file as `phase5`. Returns the results.
live_summary <- function(m, key, say = function(...) cat(..., "\n", sep = ""), rds = LIVE_RDS, labelled = live_labelled(rds)) {
  work = tempfile("live5_")
  dir.create(work)
  asker = live_asker(key)
  files = purrr::compact(purrr::map(LIVE_SUMMARY, function(ls) {
    g = live_load(ls, work)
    if (is.null(g)) { say("\n---- ", ls$file, ": not found, skipped"); return(NULL) }
    g$cb = labelled[[ls$file]]$codebook %||% g$cb
    g$cb$row_is = ls$row_is
    list(ls = ls, g = g)
  }))
  inputs = unlist(purrr::map(files, function(f) purrr::map(f$ls$charts, function(ch) {
    chart = new_chart(ch$id, ch$spec)
    chart$exploratory = isTRUE(ch$exploratory)
    c(summary_input(chart, f$g$cb, f$g$data), list(file = f$ls$file, exploratory = chart$exploratory))
  })), recursive = FALSE)
  res = summarize_inputs(inputs, ask = asker$ask, m = m)
  say("\n---- Calls")
  purrr::walk(fmt_calls(res$calls), say)
  charts = purrr::map(inputs, function(x) {
    r = res$charts[[x$id]]
    say("\n---- ", x$id, " (", x$file, "): ", x$spec$title, if (isTRUE(x$exploratory)) " [exploratory]")
    if (!is.null(x$error)) { say("  ", x$error); return(list(id = x$id, file = x$file, spec = x$spec, error = x$error)) }
    say("  FACTS")
    purrr::walk(strsplit(x$facts$text, "\n", fixed = TRUE)[[1]], function(l) say("    ", l))
    if (length(x$facts$names)) say("    (names: ", paste(names(x$facts$names), x$facts$names, sep = " = ", collapse = "; "), ")")
    if (is.null(r$headline)) say("  NO TEXT: ", r$text)
    else say("  HEADLINE: ", r$headline, "\n  SUMMARY:  ", r$summary)
    say("  CHECK:    ", if (isTRUE(r$checked)) "every number is in the facts; no forbidden word" else paste(r$problems, collapse = "; "),
        if (isTRUE(r$repaired)) " (after a repair)" else "")
    list(id = x$id, file = x$file, spec = x$spec, exploratory = x$exploratory, facts = x$facts$text, names = x$facts$names,
         headline = r$headline, summary = r$summary, checked = r$checked, problems = r$problems, text = r$text, repaired = r$repaired)
  })
  calls = res$calls
  ok = purrr::map_lgl(charts, function(ch) isTRUE(ch$checked))
  say("\n---- Totals")
  say("  charts ", length(charts), " (checked ", sum(ok), ", not checked ", length(charts) - sum(ok), ", repaired ",
      sum(purrr::map_lgl(charts, function(ch) isTRUE(ch$repaired))), "); calls ", nrow(calls), "; repairs ", sum(calls$repair),
      "; seconds ", sprintf("%.0f", sum(calls$seconds, na.rm = TRUE)))
  fmt_totals(calls, say)
  run = if (file.exists(rds)) readRDS(rds) else list()
  run$phase5 = list(model = m$id, when = format(Sys.time(), "%Y-%m-%d %H:%M"), charts = charts, calls = calls, log = asker$log,
                    codebooks = purrr::set_names(purrr::map(files, function(f) f$g$cb), purrr::map_chr(files, function(f) f$ls$file)))
  saveRDS(run, rds)
  say("  saved ", rds, " (phase5: ", length(asker$log), " raw replies)")
  invisible(charts)
}

# The Phase 5 section of the page: each chart with its headline above it, its summary and the
#   checks under it, then its facts.
live_phase5_html <- function(p5, work) {
  if (is.null(p5)) return("")
  body = purrr::map_chr(p5$charts, function(ch) {
    lf = purrr::detect(LIVE_SUMMARY, function(x) identical(x$file, ch$file))
    g = live_load(lf, work)
    cb = p5$codebooks[[ch$file]] %||% g$cb
    p = tryCatch(spec_plot(ch$spec, g$data, cb), error = function(e) e)
    paste0("<div class=\"card\"><p class=\"muted\">", esc(ch$id), " &middot; ", esc(ch$file), if (isTRUE(ch$exploratory)) " &middot; Exploratory", "</p>",
           "<h3>", esc(ch$headline %||% "(no headline)"), "</h3>",
           if (inherits(p, "error")) paste0("<p class=\"bad\">Could not draw: ", esc(conditionMessage(p)), "</p>") else png_of(p),
           "<p>", esc(ch$summary %||% ch$text %||% ch$error), "</p>",
           "<p class=\"", if (isTRUE(ch$checked)) "muted" else "bad", "\">",
           if (isTRUE(ch$checked)) "Every number matches the chart's data." else esc(paste(ch$problems, collapse = "; ")),
           if (isTRUE(ch$repaired)) " (after a repair)", "</p>",
           "<details><summary>Facts</summary><pre>", esc(ch$facts %||% ""), "</pre>",
           if (length(ch$names)) paste0("<p class=\"muted\">", esc(paste(names(ch$names), ch$names, sep = " = ", collapse = "; ")), "</p>"),
           "</details></div>")
  })
  paste0("<h1>Phase 5</h1><p class=\"muted\">", esc(p5$model), ", ", esc(p5$when), "; ", nrow(p5$calls), " calls.</p>",
         "<div class=\"grid\">", paste(body, collapse = ""), "</div>")
}


# ---- Phase 6: twelve chat turns on orders.csv, then a headline and summary for every chart ---------------

LIVE_ORDERS <- file.path("tests", "data", "orders.csv")
LIVE_ORDERS_MISSING <- c("-99", "N/A")      # the file's own codes for missing
LIVE_ORDERS_ROW <- "one order"
LIVE_MAX_CALLS <- 20L                       # planned: 1 label, 12 turns, their repairs, and 1 summary call per 8 charts

# The twelve turns, in order: what the analyst sends, and what is selected when it is sent. select is "keep" (as the turn before
#   left it), "none" (nothing selected), or a turn number k: the first chart (in reply order) that turn k added; if it added none,
#   nothing is selected and the run says so. A spec reply changes the selected chart in place, as the app does.
LIVE_TURNS <- list(
  list(message = "How has revenue changed by region?", select = "none"),
  list(message = "highlight West", select = 1L),
  list(message = "only 2024", select = "keep"),
  list(message = "which products sell the most units?", select = "keep"),
  list(message = "make it a bar chart", select = "none"),
  list(message = "how many orders were returned?", select = "none"),
  list(message = "what is in this file?", select = "none"),
  list(message = "do cheaper items sell in larger quantities?", select = "none"),
  list(message = "colour by channel", select = 8L),
  list(message = SUGGEST_MESSAGE, select = "keep"),
  list(message = "is satisfaction lower when shipping takes longer?", select = "none"),
  list(message = "make it a pie chart", select = 11L))

# What a reply says, as plain text: a charts reply gives each chart's say and the cannot sentences; the others their text.
live_reply_text <- function(r) {
  if (!identical(r$kind, "charts")) return(paste(r$text, collapse = " "))
  says = purrr::keep(purrr::map_chr(r$charts, function(ch) if (is_text1(ch$spec$say)) ch$spec$say else NA_character_), Negate(is.na))
  paste(c(says, r$cannot), collapse = " | ")
}

live_yaml <- function(spec, indent = "      ") paste0(indent, strsplit(yaml::as.yaml(spec), "\n", fixed = TRUE)[[1]], collapse = "\n")

# One turn: select as the turn says, send it through chat_turn(), and keep the canvas, the history and the last exchange as the
#   app does (newest first; a spec reply replaces the selected chart). Returns the state for the next turn, with this turn's record.
live_turn <- function(st, i, cb, data, m, asker, say) {
  turn = LIVE_TURNS[[i]]
  if (isTRUE(asker$stopped)) return(c(st[setdiff(names(st), "skipped")], list(skipped = c(st$skipped, i))))
  selected = if (identical(turn$select, "keep")) st$selected else if (identical(turn$select, "none")) NULL else st$first_added[[as.character(turn$select)]]
  note = if (is.numeric(turn$select) && is.null(selected)) paste0("turn ", turn$select, " added no chart, so nothing is selected")
  say("\n---- Turn ", i, ": ", turn$message)
  say("  selected: ", if (is.null(selected)) "nothing" else paste0(selected, " (", chart_title(purrr::detect(st$canvas, function(ch) identical(ch$id, selected)), selected), ")"),
      if (!is.null(note)) paste0("  [", note, "]"))
  r = chat_turn(turn$message, st$canvas, selected, cb, data, last = st$last, ask = asker$ask, palette = chart_palette_default(), m = m)
  calls = r$calls
  say("  seconds ", sprintf("%.1f", sum(calls$seconds, na.rm = TRUE)), "; tokens in: fresh ", format_num(sum(calls$tokens_in, na.rm = TRUE)), ", cached ",
      format_num(sum(calls$tokens_cached, na.rm = TRUE)), "; out ", format_num(sum(calls$tokens_out, na.rm = TRUE)), "; calls ", nrow(calls), "; repairs ", sum(calls$repair))
  if (isTRUE(asker$stopped)) say("  STOPPED: the call limit was reached in this turn; a call that was refused is listed below as failed, and was not made.")
  say("  came back: ", r$kind, if (isTRUE(r$repaired)) " (after a repair)")
  say("  text: ", live_reply_text(r))
  say("  next: ", if (length(r$`next`)) paste(r$`next`, collapse = " | ") else "(none)")
  if (length(r$problems)) say("  numbers not in DATA: ", paste(r$problems, collapse = ", "))
  if (!is.null(r$detail)) say("  detail: ", substr(r$detail, 1, 400))
  added = if (identical(r$kind, "charts")) purrr::imap(r$charts, function(ch, j) {
    x = new_chart(paste0("c", st$n + j), ch$spec, ch$notes)
    x$exploratory = isTRUE(ch$exploratory)
    x
  }) else list()
  canvas = if (identical(r$kind, "spec") && !is.null(r$chart)) purrr::map(st$canvas, function(ch) if (identical(ch$id, r$chart$id)) r$chart else ch) else st$canvas
  canvas = c(added, canvas)
  purrr::walk(added, function(ch) say("  added ", ch$id, if (isTRUE(ch$exploratory)) " [exploratory]", ":\n", live_yaml(ch$spec)))
  if (identical(r$kind, "spec") && !is.null(r$chart)) say("  changed ", r$chart$id, ":\n", live_yaml(r$chart$spec))
  purrr::walk(r$failed, function(f) say("  not drawn: chart ", f$number, if (is_text1(f$spec$title)) paste0(" (", f$spec$title, ")"), ": ", paste(f$sentences, collapse = " ")))
  purrr::walk(fmt_calls(calls), say)
  record = list(n = i, message = turn$message, selected = selected, note = note, kind = r$kind, text = live_reply_text(r), `next` = r$`next`, repaired = r$repaired,
                repairs = sum(calls$repair), seconds = sum(calls$seconds, na.rm = TRUE), added = purrr::map_chr(added, "id"),
                added_specs = purrr::map(added, "spec"), changed = if (identical(r$kind, "spec")) r$chart, failed = r$failed, cannot = r$cannot,
                problems = r$problems, detail = r$detail, replies = r$replies, calls = calls)
  list(canvas = canvas, selected = selected, last = r$last, n = st$n + length(added),
       first_added = c(st$first_added, stats::setNames(list(if (length(added)) added[[1]]$id), as.character(i))),
       turns = c(st$turns, list(record)), skipped = st$skipped)
}

# The run: the file read with its codes for missing, labelled (one label call), one order a row; the twelve turns; then a headline
#   and summary for every chart on the canvas. Calls are counted as they go: the call after max_calls is not made, the run stops
#   there and prints what was done. Prints each turn, each text with its check, and the totals; adds the run to the saved file as
#   `phase6`. Sonnet only (the id is checked again here). Returns the run.
live_chat <- function(m, key, say = function(...) cat(..., "\n", sep = ""), rds = LIVE_RDS, max_calls = LIVE_MAX_CALLS, path = LIVE_ORDERS) {
  if (grepl("opus", m$id, ignore.case = TRUE)) stop("Live tests call Sonnet models only; '", m$id, "' is an Opus model.", call. = FALSE)
  if (!file.exists(path)) return(say("Result: no call was made; ", path, " is not there."))
  started = Sys.time()
  asker = live_asker(key, max_calls)
  read = reread_data(path, basename(path), LIVE_ORDERS_MISSING)
  data = read$read$data
  say("\n---- ", basename(path), " (", format_num(nrow(data)), " rows, ", length(read$codebook$columns), " columns; missing: ", paste(LIVE_ORDERS_MISSING, collapse = ", "),
      "; call limit ", max_calls, ")")
  lab = label_columns(read$codebook, ask = asker$ask, m = m)
  say("  label_columns(): ", nrow(lab$calls), " call(s)")
  purrr::walk(fmt_calls(lab$calls), say)
  if (!is.null(lab$error)) {
    say("  FAILED: ", lab$error, "\n  ", substr(lab$detail %||% "", 1, 600), "\n  The run stops here: nothing can be asked without labels.")
    return(invisible(NULL))
  }
  cb = lab$codebook
  cb$row_is = LIVE_ORDERS_ROW
  say("  labels proposed: ", sum(purrr::map_lgl(cb$columns, function(e) identical(e$label_source, "ai_guess"))), "; row_is_guess: ", lab$row_is_guess %||% "(none)",
      "; row_is set to '", LIVE_ORDERS_ROW, "'")

  st = purrr::reduce(seq_along(LIVE_TURNS), function(st, i) live_turn(st, i, cb, data, m, asker, say),
                     .init = list(canvas = list(), selected = NULL, last = NULL, n = 0L, first_added = list(), turns = list(), skipped = integer(0)))
  canvas = st$canvas
  turns = st$turns
  if (length(st$skipped)) say("\n---- STOPPED: the limit of ", max_calls, " calls was reached; turns ", paste(st$skipped, collapse = ", "), " were not run.")

  # a headline and summary for every chart on the canvas, in batches of SUMMARY_BATCH charts, one call each (a repair adds one)
  batches = ceiling(length(canvas) / SUMMARY_BATCH)
  stories = list()
  summary_calls = tibble::tibble()
  if (!length(canvas)) say("\n---- No chart on the canvas, so no summary call.")
  else if (isTRUE(asker$stopped) || asker$n + batches > max_calls) {
    asker$stopped = TRUE
    say("\n---- STOPPED before the summary call: ", length(canvas), " charts need ", batches, " call(s) and ", asker$n, " of ", max_calls, " calls are used.")
  } else {
    say("\n---- Headlines and summaries for ", length(canvas), " charts (", batches, " call(s) planned)")
    out = summarize_charts(canvas, cb, data, ask = asker$ask, palette = chart_palette_default(), m = m)
    summary_calls = out$calls
    purrr::walk(fmt_calls(out$calls), say)
    stories = purrr::map(canvas, function(ch) {
      s = out$charts[[ch$id]]
      say("\n  ", ch$id, if (isTRUE(ch$exploratory)) " [exploratory]", ": ", chart_title(ch, "(no title)"))
      if (is.null(s$headline)) say("    NO TEXT: ", s$text) else say("    HEADLINE: ", s$headline, "\n    SUMMARY:  ", s$summary)
      say("    CHECK:    ", if (isTRUE(s$checked)) "every number is in the facts; no forbidden word" else paste(s$problems, collapse = "; "),
          if (isTRUE(s$repaired)) " (after a repair)" else "")
      list(id = ch$id, headline = s$headline, summary = s$summary, checked = s$checked, problems = s$problems, repaired = s$repaired, text = s$text)
    })
  }

  calls = dplyr::bind_rows(lab$calls, purrr::map(turns, "calls"), summary_calls)
  kinds = table(factor(purrr::map_chr(turns, "kind"), levels = c("charts", "spec", "ask", "cannot", "tell", "failed")))
  secs = sum(calls$seconds, na.rm = TRUE)
  say("\n---- Totals")
  say("  calls made ", asker$n, " of ", max_calls, " allowed (records: ", paste(names(table(calls$call)), table(calls$call), sep = " ", collapse = ", "), "); repairs ", sum(calls$repair),
      "; failed ", sum(!calls$ok), if (asker$refused) paste0(" (", asker$refused, " of them refused at the limit and not made)"))
  say("  turns run ", length(turns), " of ", length(LIVE_TURNS), " (", paste(names(kinds), kinds, collapse = ", "), ")")
  fmt_totals(calls, say)
  say("  seconds in calls ", sprintf("%.0f", secs), "; wall time ", sprintf("%.0f", as.numeric(difftime(Sys.time(), started, units = "secs"))))
  say("  headlines and summaries: ", length(stories), " (checked ", sum(purrr::map_lgl(stories, function(s) isTRUE(s$checked))), ", not checked ",
      length(stories) - sum(purrr::map_lgl(stories, function(s) isTRUE(s$checked))), ")")
  run = if (file.exists(rds)) readRDS(rds) else list()
  run$phase6 = list(model = m$id, when = format(Sys.time(), "%Y-%m-%d %H:%M"), file = basename(path), missing = LIVE_ORDERS_MISSING, cb = cb,
                    row_is_guess = lab$row_is_guess, turns = turns, canvas = canvas, stories = stories, calls = calls, log = asker$log,
                    stopped = isTRUE(asker$stopped), skipped = st$skipped, max_calls = max_calls)
  saveRDS(run, rds)
  say("  saved ", rds, " (phase6: ", length(asker$log), " raw replies)")
  invisible(run$phase6)
}

# The Phase 6 section of the page: the turns in a table, then the canvas as it ended, newest first: the three value boxes as
#   text, and each card with its headline above the chart, its summary and notes under it, its rule and "Exploratory".
live_phase6_html <- function(p6) {
  if (is.null(p6)) return("")
  data = reread_data(LIVE_ORDERS, p6$file, p6$missing)$read$data
  cb = p6$cb
  labels = as.list(reflex_labels())
  time = purrr::detect(cb$columns, function(e) identical(e$role, "time"))
  period = if (!is.null(time) && time$name %in% names(data)) {
    rng = range(data[[time$name]], na.rm = TRUE)
    paste(if (inherits(rng, c("Date", "POSIXt"))) date_text(rng) else format(rng, big.mark = "", scientific = FALSE, trim = TRUE), collapse = " to ")
  }
  boxes = paste0("<p><b>Rows</b> ", format_num(nrow(data)), " &middot; <b>Columns</b> ", format_num(ncol(data)), " &middot; <b>", if (!is.null(period)) "Period" else "File",
                 "</b> ", esc(period %||% p6$file), "</p>")
  turns = paste0("<table><tr><th>Turn</th><th>Selected</th><th>Message</th><th>Reply</th><th>Repairs</th><th>Seconds</th><th>Text</th></tr>",
                 paste0(purrr::map_chr(p6$turns, function(t)
                   paste0("<tr><td>", t$n, "</td><td>", esc(t$selected %||% "none"), "</td><td>", esc(t$message), "</td><td>", esc(t$kind), if (length(t$added)) paste0(" (+", length(t$added), ")"),
                          "</td><td>", t$repairs, "</td><td>", sprintf("%.1f", t$seconds), "</td><td>", esc(t$text),
                          if (length(t$failed)) paste0("<br><span class=\"bad\">not drawn: ", esc(paste(purrr::map_chr(t$failed, function(f) paste(f$sentences, collapse = " ")), collapse = " | ")), "</span>"),
                          if (length(t$`next`)) paste0("<br><span class=\"muted\">next: ", esc(paste(t$`next`, collapse = " | ")), "</span>"), "</td></tr>")), collapse = ""), "</table>")
  cards = purrr::map_chr(p6$canvas, function(ch) {
    s = purrr::detect(p6$stories, function(x) identical(x$id, ch$id))
    p = tryCatch(spec_plot(ch$spec, data, cb), error = function(e) e)
    rule = ch$spec$rule
    paste0("<div class=\"card\"><h3>", esc(s$headline %||% chart_title(ch, "Untitled chart")), "</h3>",
           if (!is.null(s$headline)) paste0("<p class=\"muted\">", esc(chart_title(ch, "")), "</p>"),
           if (inherits(p, "error")) paste0("<p class=\"bad\">Could not draw: ", esc(conditionMessage(p)), "</p>") else png_of(p),
           if (!is.null(s)) paste0("<p>", esc(s$summary %||% s$text), "</p>"),
           if (!is.null(s)) paste0("<p class=\"", if (isTRUE(s$checked)) "muted" else "bad", "\">", if (isTRUE(s$checked)) "Every number matches the chart's data." else esc(paste(s$problems, collapse = "; ")),
                                   if (isTRUE(s$repaired)) " (after a repair)", "</p>"),
           if (length(ch$notes)) paste0("<ul class=\"notes\">", paste0("<li>", purrr::map_chr(ch$notes, esc), "</li>", collapse = ""), "</ul>"),
           "<p class=\"muted\">", esc(ch$id), " &middot; ", if (!is.null(rule)) paste0("Rule: ", esc(labels[[rule]] %||% rule), " (", esc(rule), ")") else "No rule",
           if (isTRUE(ch$exploratory)) " &middot; Exploratory", "</p>",
           "<details><summary>Spec</summary><pre>", esc(yaml::as.yaml(ch$spec)), "</pre></details></div>")
  })
  paste0("<h1>Phase 6</h1><p class=\"muted\">", esc(p6$model), ", ", esc(p6$when), "; ", nrow(p6$calls), " calls (limit ", p6$max_calls, ")",
         if (isTRUE(p6$stopped)) "; STOPPED at the call limit", ".</p>", turns, "<h2>The canvas as it ended</h2>", boxes,
         "<div class=\"grid\">", paste(cards, collapse = ""), "</div>")
}


# ---- the page ---------------------------------------------------------------------------------------

esc <- function(x) htmltools::htmlEscape(paste(x, collapse = " "))

# The static chart drawn at SPEC_DPI (spec_png(), as the app does) and shown at its size in inches.
png_of <- function(p) {
  f = tempfile(fileext = ".png")
  sz = spec_png(p, f)
  paste0("<img src=\"data:image/png;base64,", jsonlite::base64_enc(readBin(f, "raw", file.size(f))), "\" width=\"",
         round(sz[["width"]] * LIVE_DPI), "\" style=\"max-width:100%; height:auto\">")
}

live_page <- function(rds = LIVE_RDS, out = LIVE_OUT) {
  run = readRDS(rds)
  work = tempfile("live_page_")
  dir.create(work)
  css = paste("body{font-family:system-ui,sans-serif;max-width:1500px;margin:1rem auto;padding:0 1rem;color:#222}",
              ".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(640px,1fr));gap:1rem}",
              ".card{border:1px solid #ccc;border-radius:6px;padding:.75rem}.muted{color:#666;font-size:.9em}",
              ".notes{font-size:.9em}.cannot{background:#f4f4f4;padding:.5rem 1rem;border-radius:6px}.bad{color:#b00}",
              "td,th{padding:2px 8px;text-align:left;border-bottom:1px solid #eee;vertical-align:top}pre{white-space:pre-wrap}")
  html = paste0("<!doctype html><html><head><meta charset=\"utf-8\"><title>chaRt live runs</title><style>", css, "</style></head><body>",
                "<h1>chaRt live runs</h1>", live_phase5_html(run$phase5, work), live_phase6_html(run$phase6), "</body></html>")
  writeLines(html, out, useBytes = TRUE)
  cat("Wrote ", out, " (", round(file.size(out) / 1e6, 1), " MB).\n", sep = "")
  invisible(out)
}

if (sys.nframe() == 0L) {
  invisible(shiny::shinyAppDir("."))
  live_page()
}
