# The Phase 3 live run and its page. Helpers sourced by tests/llm_check.R, which makes the calls;
#   run as a script, this file only rebuilds the page from the saved run, with no call:
#     Rscript --no-init-file tests/live_gallery.R
#   live_run() labels three files and asks the suggest call twelve questions (Sonnet only, through
#   llm_json(), the key passed in and never printed), printing what each call cost and returned,
#   and saves everything, the raw replies included, to tests/live_replies.rds (git-ignored).
#   Given `labelled` (the codebooks of an earlier run, live_labelled()), it makes no label call;
#   LIVE_FILES_3B is the short run of Phase 3b, five suggest calls.
#   live_page() writes tests/live_gallery.html (git-ignored) from that file: per question, the
#   question, cannot, and each chart with its notes, say, rule label and spec as YAML.

source(file.path("tests", "gallery.R"))   # gold_path(): the course files and panel.csv

LIVE_RDS <- file.path("tests", "live_replies.rds")
LIVE_OUT <- file.path("tests", "live_gallery.html")
LIVE_DPI <- 96

# The files, how each is read, what a row is, and the questions (NA: no question).
LIVE_FILES <- list(
  list(file = "FH_disaggregated.csv", missing = "..", row_is = "one country",
       questions = c("Which countries had the highest political rights scores in 2014?",
                     "How do political rights and civil liberties go together in 2014?",
                     "How have political rights changed since 2003?", NA)),
  list(file = "footballdata-1.csv", missing = character(0), row_is = "one player",
       questions = c("Are goalkeepers taller than other players?", "Which nationalities are most common?",
                     "How does height relate to weight, and does it differ by foot?", NA)),
  list(file = "panel.csv", missing = character(0), row_is = "one region in one year",
       questions = c("How has revenue changed in each region?", "Which regions grew most between 2015 and 2024?",
                     "Do regions that sell more units charge less?", NA)))

# Phase 3b's short run: five questions, on the codebooks labelled in the Phase 3 run.
LIVE_FILES_3B <- list(
  list(file = "FH_disaggregated.csv", missing = "..", row_is = "one country",
       questions = "Which countries had the highest political rights scores in 2014?"),
  list(file = "footballdata-1.csv", missing = character(0), row_is = "one player",
       questions = c(NA, "How does attacking skill relate to defending skill?")),
  list(file = "panel.csv", missing = character(0), row_is = "one region in one year",
       questions = c("Which regions grew most between 2015 and 2024?", NA)))

# The labelled codebook and row guess of each file in a saved run, by file name.
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

# llm_json() with the key, keeping every raw reply (and every failure) in order.
live_asker <- function(key) {
  env = new.env()
  env$log = list()
  env$ask = function(user, m, system_prompt = NULL, max_tokens, validate = NULL) {
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

# How the first reply of a suggest call did before any repair: charts returned, and how many passed.
first_counts <- function(res, cb, data) {
  raw = res$replies$first
  if (is.null(raw)) return(c(returned = 0L, valid_first = 0L))
  obj = tryCatch(parse_json_block(clean_model_reply(raw)), error = function(e) NULL)
  if (is.null(obj)) return(c(returned = NA_integer_, valid_first = NA_integer_))
  checked = check_reply(obj, cb, data, chart_palette_default(), suggest_rule_ids())
  c(returned = length(checked), valid_first = sum(purrr::map_lgl(checked, "ok")))
}

fmt_calls <- function(calls) purrr::pmap_chr(calls, function(call, hash, chars, tokens_in, tokens_cached, tokens_out, seconds, repair, ok)
  sprintf("    %-8s%s %6.1f s, %6s chars, tokens in: fresh %6s, cached %6s; out %5s%s", call, if (repair) " (repair)" else "", seconds,
          format_num(chars), format_num(tokens_in), format_num(tokens_cached), format_num(tokens_out), if (!ok) ", FAILED" else ""))

# The run. say() prints a line (llm_check.R's, which scrubs the key). Returns and saves the run.
live_run <- function(m, key, say = function(...) cat(..., "\n", sep = ""), rds = LIVE_RDS, files = LIVE_FILES, labelled = NULL) {
  work = tempfile("live_")
  dir.create(work)
  asker = live_asker(key)
  files = purrr::map(files, function(lf) {
    g = live_load(lf, work)
    if (is.null(g)) { say("\n---- ", lf$file, ": not found, skipped"); return(NULL) }
    say("\n---- ", lf$file, " (", format_num(nrow(g$data)), " rows, ", length(g$cb$columns), " columns; row_is '", lf$row_is, "')")
    before = labelled[[lf$file]]
    lab = if (!is.null(before)) list(codebook = before$codebook, row_is_guess = before$row_is_guess, error = NULL, calls = tibble::tibble())
          else label_columns(g$cb, ask = asker$ask, m = m)
    say("  label_columns(): ", if (!is.null(before)) "not called; the labels of the earlier run are used" else paste(nrow(lab$calls), "call(s)"))
    purrr::walk(fmt_calls(lab$calls), say)
    if (!is.null(lab$error)) say("  FAILED: ", lab$error, "\n  ", substr(lab$detail %||% "", 1, 600))
    cols = purrr::map(lab$codebook$columns, function(e) list(name = e$name, label = e$label, source = e$label_source, sure = e$sure))
    purrr::walk(cols, function(e) say(sprintf("    %-22s %-45s %s", e$name, e$label,
                                              if (identical(e$source, "ai_guess")) paste("sure:", tolower(e$sure)) else paste0("(", e$source, ")"))))
    say("  row_is_guess: ", lab$row_is_guess %||% "(none)")
    cb = lab$codebook
    runs = purrr::map(lf$questions, function(q) {
      q = if (is.na(q)) NULL else q
      say("\n  Q: ", q %||% "(no question)")
      res = suggest_charts(cb, g$data, q, ask = asker$ask, m = m)
      fc = first_counts(res, cb, g$data)
      purrr::walk(fmt_calls(res$calls), say)
      say("    charts returned ", fc[["returned"]], "; valid first time ", fc[["valid_first"]],
          "; valid after repair ", if (isTRUE(res$repaired)) length(res$charts) else "(no repair)",
          "; drawn ", length(res$charts), "; failed ", length(res$failed))
      if (!is.null(res$error)) say("    ERROR: ", res$error, "\n    ", substr(res$detail %||% "", 1, 600))
      purrr::walk(res$cannot, function(x) say("    cannot: ", x))
      purrr::walk(res$failed, function(f) say("    failed chart ", f$number, ": ", paste(f$sentences, collapse = " ")))
      purrr::walk(res$charts, function(ch) say("    drew: ", ch$spec$family, " - ", ch$spec$title %||% "(no title)",
                                               if (!is.null(ch$spec$rule)) paste0(" [", ch$spec$rule, "]") else ""))
      list(question = q, result = res, counts = fc)
    })
    list(file = lf$file, row_is = lf$row_is, path_name = basename(g$path), label = lab, columns = cols, runs = runs)
  })
  files = purrr::compact(files)
  runs = unlist(purrr::map(files, "runs"), recursive = FALSE)
  calls = dplyr::bind_rows(c(purrr::map(files, function(f) f$label$calls), purrr::map(runs, function(r) r$result$calls)))
  counts = purrr::map(runs, "counts")
  say("\n---- Totals")
  say("  calls ", nrow(calls), " (", paste(names(table(calls$call)), table(calls$call), sep = " ", collapse = ", "), "; repairs ",
      sum(calls$repair), "; failed ", sum(!calls$ok), ")")
  say("  seconds ", sprintf("%.0f", sum(calls$seconds, na.rm = TRUE)), "; characters sent ", format_num(sum(calls$chars)),
      "; tokens in: fresh ", format_num(sum(calls$tokens_in, na.rm = TRUE)), ", cached ", format_num(sum(calls$tokens_cached, na.rm = TRUE)),
      "; out ", format_num(sum(calls$tokens_out, na.rm = TRUE)))
  say("  charts returned ", sum(purrr::map_int(counts, "returned"), na.rm = TRUE), "; valid first time ",
      sum(purrr::map_int(counts, "valid_first"), na.rm = TRUE), "; drawn in the end ",
      sum(purrr::map_int(runs, function(r) length(r$result$charts))), "; failed in the end ",
      sum(purrr::map_int(runs, function(r) length(r$result$failed))), "; cannot sentences ",
      sum(purrr::map_int(runs, function(r) length(r$result$cannot))))
  run = list(model = m$id, when = format(Sys.time(), "%Y-%m-%d %H:%M"), system_suggest = assemble_system("suggest"),
             files = files, calls = calls, log = asker$log)
  saveRDS(run, rds)
  say("  saved ", rds, " (", length(asker$log), " raw replies)")
  invisible(run)
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

live_chart_html <- function(ch, g, labels) {
  p = tryCatch(spec_plot(ch$spec, g$data, g$cb), error = function(e) e)
  rule = ch$spec$rule
  paste0("<div class=\"card\">",
         if (inherits(p, "error")) paste0("<p class=\"bad\">Could not draw again: ", esc(conditionMessage(p)), "</p>") else png_of(p),
         if (length(ch$notes)) paste0("<ul class=\"notes\">", paste0("<li>", purrr::map_chr(ch$notes, esc), "</li>", collapse = ""), "</ul>"),
         if (!is.null(ch$spec$say)) paste0("<p><b>say:</b> ", esc(ch$spec$say), "</p>"),
         "<p class=\"muted\">", if (!is.null(rule)) paste0("Rule: ", esc(labels[[rule]] %||% rule), " (", esc(rule), ")") else "No rule",
         if (isTRUE(ch$exploratory)) " &middot; Exploratory", "</p>",
         "<details><summary>Spec</summary><pre>", esc(yaml::as.yaml(ch$spec)), "</pre></details></div>")
}

live_page <- function(rds = LIVE_RDS, out = LIVE_OUT) {
  run = readRDS(rds)
  work = tempfile("live_page_")
  dir.create(work)
  labels = as.list(reflex_labels())
  body = purrr::map_chr(run$files, function(f) {
    lf = purrr::detect(c(LIVE_FILES, LIVE_FILES_3B), function(x) identical(x$file, f$file))
    g = live_load(lf, work)
    g$cb = f$label$codebook
    cols = paste0("<tr><td><code>", purrr::map_chr(f$columns, function(e) esc(e$name)), "</code></td><td>",
                  purrr::map_chr(f$columns, function(e) esc(e$label)), "</td><td>",
                  purrr::map_chr(f$columns, function(e) if (identical(e$source, "ai_guess")) tolower(as.character(e$sure)) else esc(e$source)),
                  "</td></tr>", collapse = "")
    qs = purrr::map_chr(f$runs, function(r) {
      res = r$result
      paste0("<h3>", esc(r$question %||% "(no question: suggest charts)"), "</h3>",
             "<p class=\"muted\">", nrow(res$calls), " call(s), ", sprintf("%.0f", sum(res$calls$seconds, na.rm = TRUE)), " s; ",
             "returned ", r$counts[["returned"]], ", valid first time ", r$counts[["valid_first"]],
             if (isTRUE(res$repaired)) ", repaired", "</p>",
             if (!is.null(res$error)) paste0("<p class=\"bad\">", esc(res$error), "</p>"),
             if (length(res$cannot)) paste0("<div class=\"cannot\"><b>cannot</b><ul>", paste0("<li>", purrr::map_chr(res$cannot, esc), "</li>", collapse = ""), "</ul></div>"),
             "<div class=\"grid\">", paste(purrr::map_chr(res$charts, live_chart_html, g = g, labels = labels), collapse = ""), "</div>",
             if (length(res$failed)) paste0("<h4>Could not be drawn</h4><ul>", paste0("<li>Chart ", purrr::map_chr(res$failed, function(x) as.character(x$number)), ": ",
                                                                                   purrr::map_chr(res$failed, function(x) esc(x$sentences)), "</li>", collapse = ""), "</ul>"))
    })
    paste0("<h2>", esc(f$file), "</h2><p>One row is: ", esc(f$row_is), "; the model guessed: ", esc(f$label$row_is_guess %||% "(none)"), "</p>",
           "<details><summary>Labels proposed</summary><table><tr><th>Column</th><th>Label</th><th>Sure</th></tr>", cols, "</table></details>",
           paste(qs, collapse = ""))
  })
  css = paste("body{font-family:system-ui,sans-serif;max-width:1500px;margin:1rem auto;padding:0 1rem;color:#222}",
              ".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(640px,1fr));gap:1rem}",
              ".card{border:1px solid #ccc;border-radius:6px;padding:.75rem}.muted{color:#666;font-size:.9em}",
              ".notes{font-size:.9em}.cannot{background:#f4f4f4;padding:.5rem 1rem;border-radius:6px}.bad{color:#b00}",
              "td,th{padding:2px 8px;text-align:left;border-bottom:1px solid #eee}pre{white-space:pre-wrap}")
  html = paste0("<!doctype html><html><head><meta charset=\"utf-8\"><title>chaRt live run</title><style>", css, "</style></head><body>",
                "<h1>chaRt Phase 3 live run</h1><p class=\"muted\">", esc(run$model), ", ", esc(run$when), "; ", nrow(run$calls), " calls.</p>",
                paste(body, collapse = ""), "</body></html>")
  writeLines(html, out, useBytes = TRUE)
  cat("Wrote ", out, " (", round(file.size(out) / 1e6, 1), " MB).\n", sep = "")
  invisible(out)
}

if (sys.nframe() == 0L) {
  invisible(shiny::shinyAppDir("."))
  live_page()
}
