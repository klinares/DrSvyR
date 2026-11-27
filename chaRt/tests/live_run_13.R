# Phase 13 Part C 3: the live look. The eight charts of Phase 11 Part F (tests/live_replies_11.rds, phase11_chat$canvas), R's headline beside the model's.
#   Makes real model calls (Sonnet only), at most LIVE13_MAX: the summary call of summary.md for the eight charts (one call, and one repair call for the
#   charts whose text failed its checks). Run from inside chaRt/, in PowerShell:   Rscript --no-init-file tests/live_run_13.R
# The key comes from the environment (ANTHROPIC_API_KEY, in .Renviron): a test script may read it, the app never does. It is passed to the model call and never
#   printed; every line written is scrubbed of it as well. Without a key no call is made and only R's column is written.
# Writes tests/live_run_13.out (the run) and tests/live_headlines_13.md (the two-column table): each chart's description, R's headline, the model's headline,
#   whether the model's passed the number and word checks, and which the card shows (headline_shown()). The replies go to tests/live_replies_13.rds.
stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
invisible(shiny::shinyAppDir("."))
LIVE13_MAX <- 10L
key <- Sys.getenv("ANTHROPIC_API_KEY")
out_file <- file.path("tests", "live_run_13.out")
if (file.exists(out_file)) file.remove(out_file)
say <- function(...) {
  txt = paste0(c(...), collapse = "")
  if (nzchar(key)) txt = gsub(key, "[key]", txt, fixed = TRUE)
  cat(txt, "\n", sep = "")
  cat(txt, "\n", sep = "", file = out_file, append = TRUE)
}
home <- APP_PROFILES$home
if (grepl("opus", home$id, ignore.case = TRUE) || !grepl("sonnet", home$id, ignore.case = TRUE)) stop("Live tests call Sonnet models only; '", home$id, "' is not one.", call. = FALSE)
saved <- readRDS(file.path("tests", "live_replies_11.rds"))$phase11_chat
r <- read_data(file.path("tests", "data", saved$file), saved$file, saved$missing)
data <- r$data
cb <- saved$cb
charts <- purrr::map(saved$canvas, function(ch) { x <- new_chart(ch$id, ch$spec, ch$notes); x$exploratory <- isTRUE(ch$exploratory); x })
say("chaRt Phase 13 Part C: R's headline beside the model's, on ", saved$file, ", ", format(Sys.time(), "%Y-%m-%d %H:%M"), "; model ", home$id, "; limit ", LIVE13_MAX, " calls",
    if (!nzchar(key)) " (no key: no call is made)")
rh <- purrr::map(charts, function(ch) r_headline(ch, cb, data))
asker <- new.env()
asker$n <- 0L
asker$ask <- function(user, m, system_prompt = NULL, max_tokens, validate = NULL, images = NULL) {
  if (asker$n >= LIVE13_MAX) stop("The limit of ", LIVE13_MAX, " calls is reached, so no further call is made.", call. = FALSE)
  asker$n <- asker$n + 1L
  llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens, validate = validate, key = key)
}
out <- if (nzchar(key)) tryCatch(summarize_charts(charts, cb, data, ask = asker$ask, m = home), error = function(e) { say("The summary call stopped: ", conditionMessage(e)); NULL })
by_id <- if (!is.null(out)) stats::setNames(out$charts, purrr::map_chr(out$charts, "id")) else list()
rows <- purrr::map2(charts, rh, function(ch, h) {
  m <- by_id[[ch$id]]
  st <- if (!is.null(m) && !is.null(m$headline)) list(headline = m$headline, summary = m$summary, facts = m$facts, spec = m$spec, problems = m$problems, headline_by = "model")
  shown <- headline_shown(st, h)
  model_ok <- if (!is.null(st)) summary_ok(summary_problems(st$headline, NULL, st$facts, st$spec)) else NA
  list(id = ch$id, description = ch$spec$title %||% "", r = h$text, r_source = h$source, model = if (!is.null(st)) st$headline else NA_character_, model_ok = model_ok,
       problems = if (!is.null(st)) paste(problem_sentences(summary_problems(st$headline, NULL, st$facts, st$spec)), collapse = "; ") else "", shown = shown$by)
})
purrr::walk(rows, function(x) say("\n", x$id, " (", x$description, ")\n  R:     ", x$r, " [", x$r_source, ", ", hl_words(x$r), " words]\n  model: ", x$model %||% "(none)",
                                    if (isTRUE(x$model_ok)) " [passed]" else if (identical(x$model_ok, FALSE)) paste0(" [failed: ", x$problems, "]") else "", "\n  the card shows: ", x$shown))
esc <- function(x) gsub("|", "\\|", x, fixed = TRUE)
md <- c("| Chart | Description (the line under) | R's headline | The model's headline | Model's checks | Card shows |", "|---|---|---|---|---|---|",
        purrr::map_chr(rows, function(x) sprintf("| %s | %s | %s | %s | %s | %s |", x$id, esc(x$description), esc(x$r), esc(x$model %||% "(none)"),
                                                if (isTRUE(x$model_ok)) "passed" else if (identical(x$model_ok, FALSE)) paste0("failed: ", esc(x$problems)) else "no call", x$shown)))
writeLines(md, file.path("tests", "live_headlines_13.md"), useBytes = TRUE)
if (!is.null(out)) saveRDS(list(phase13 = list(model = home$id, when = format(Sys.time(), "%Y-%m-%d %H:%M"), charts = out$charts, calls = out$calls, rows = rows)),
                          file.path("tests", "live_replies_13.rds"))
say("\nDone. Calls made: ", asker$n, " of ", LIVE13_MAX, " allowed.")
