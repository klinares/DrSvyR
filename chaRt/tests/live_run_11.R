# Phase 11 Part F: is it better? The live comparison of eight charts, standard against designed. Makes real model calls (Sonnet only), at most 45.
# Run from inside chaRt/, in PowerShell (not Git Bash):   Rscript --no-init-file tests/live_run_11.R
# The key comes from the environment (ANTHROPIC_API_KEY, in .Renviron): a test script may read it, the app never does. It is passed to the model call
#   and never printed; every line written is scrubbed of it as well. Without a key no call is made.
#
# On tests/data/orders.csv (3,000 synthetic orders; -99 and N/A mean missing; a row is one order), through the code the app runs:
#   1. eight chart turns through chat_turn() (live_chat() in tests/live_gallery.R; the Phase 10 dictionary is reused, so no label call), then one
#      headline-and-summary call for the eight;
#   2. each chart designed with the Editorial skill through design_chart(), in the Briefing style's tokens, with the review by looking
#      (APP_DESIGN_IMAGES "all"); if the endpoint refuses the picture on the first design, the rest are designed with the picture off and the run says so;
#   3. tests/designed.html: each chart's standard drawing and designed drawing side by side at card size, the design's say, the rounds, the refusals with
#      their sentences, the calls and seconds, and the design code;
#   4. a dashboard of the designed charts in the Briefing style (pictures; Part C's design videos are not built), unpacked into tests/dashboard_designed/.
# Calls are counted: the chat part may use LIVE11_CHAT_MAX, the designs what is left of LIVE11_MAX; a design is started only while at least
#   LIVE11_DESIGN_MIN calls are left. The call after the limit is refused and the run says so.
# What is written: tests/live_run_11.out (text: each turn, each design, the calls), tests/live_replies_11.rds (the replies), tests/designed.html,
#   tests/dashboard_designed/. No key, no row of the file.
# LIVE11_REDESIGN=1, the second attempt after the design fixes: no chat call; the canvas, the stories and the dictionary come from the first attempt
#   (tests/live_replies_11.rds, phase11_chat). A chart whose design was accepted then has that same code checked again under the new rules by a stand-in
#   that hands it back (no call, no review); each chart that fell back is designed again, live, with what is left of LIVE11_MAX after the first
#   attempt's calls. One review round at most, given only while two calls are left for every chart still to design after it. Writes tests/live_run_11b.out,
#   phase11_design2 in tests/live_replies_11.rds, and the same tests/designed.html and tests/dashboard_designed/ as the first attempt.
# CHART_LIVE_DRY=1 makes no call and needs no key: eight gold specs and a stand-in designer that writes one plain code, to try the plumbing; it writes
#   tests/live_run_11_dry.out and tests/designed_dry.html and tests/dashboard_designed_dry/.

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
invisible(shiny::shinyAppDir("."))
if (!exists("live_chat")) source(file.path("tests", "live_gallery.R"))

LIVE11_MAX <- 45L
LIVE11_CHAT_MAX <- 13L          # 8 turns + 1 summary call + 4 repairs
LIVE11_DESIGN_MIN <- 2L
LIVE11_STYLE <- "briefing"
LIVE11_SKILL <- "editorial"
LIVE11_TURNS <- list(
  list(message = "rank the regions by total revenue", select = "none"),
  list(message = "show monthly revenue by channel as lines", select = "none"),
  list(message = "is unit price related to units? show every order", select = "none"),
  list(message = "compare revenue by region in 2022 and 2024 as a dumbbell", select = "none"),
  list(message = "which product categories grew fastest? index them to their first month", select = "none"),
  list(message = "show the spread of unit price by channel as a box plot", select = "none"),
  list(message = "show the number of orders by region and product category as a heatmap", select = "none"),
  list(message = "show the distribution of order revenue as a histogram", select = "none"))
LIVE11_EXPECT <- c("a ranked bar", "a line with several series", "a scatter of 3,000 points", "a dumbbell", "an indexed line", "a box by group", "a heatmap", "a histogram")

dry <- identical(Sys.getenv("CHART_LIVE_DRY"), "1")
redo <- !dry && identical(Sys.getenv("LIVE11_REDESIGN"), "1")
key <- Sys.getenv("ANTHROPIC_API_KEY")
sfx <- if (dry) "_dry" else ""
out_file <- file.path("tests", paste0("live_run_11", sfx, if (redo) "b", ".out"))
html_file <- file.path("tests", paste0("designed", sfx, ".html"))
dash_dir <- file.path("tests", paste0("dashboard_designed", sfx))
if (file.exists(out_file)) file.remove(out_file)

say <- function(...) {
  txt = paste0(c(...), collapse = "")
  if (nzchar(key)) txt = gsub(key, "[key]", txt, fixed = TRUE)
  cat(txt, "\n", sep = "")
  cat(txt, "\n", sep = "", file = out_file, append = TRUE)
}

say("chaRt Phase 11 Part F: live comparison on tests/data/orders.csv, ", format(Sys.time(), "%Y-%m-%d %H:%M"), if (dry) " (DRY: no call, gold specs and a stand-in designer)",
    if (redo) " (SECOND ATTEMPT: the first attempt's canvas; the charts that fell back are designed again)")
home <- APP_PROFILES$home
if (grepl("opus", home$id, ignore.case = TRUE)) stop("Live tests call Sonnet models only; '", home$id, "' is an Opus model.", call. = FALSE)
say("Model: ", home$id, " at ", home$base_url, "; limit ", LIVE11_MAX, " calls (chat ", LIVE11_CHAT_MAX, "); skill ", LIVE11_SKILL, "; tokens of the ", LIVE11_STYLE, " style")
palette <- utils::modifyList(chart_palette_default(), list(style = LIVE11_STYLE))

saved <- if (file.exists(file.path("tests", "live_replies_10.rds"))) readRDS(file.path("tests", "live_replies_10.rds"))$phase10 else NULL
if (!dry && !is.null(saved)) {
  label_columns <- function(codebook, ask, m) list(codebook = saved$cb, calls = saved$calls[0, ], error = NULL, row_is_guess = saved$row_is_guess)
  say("The column dictionary of the Phase 10 live run is reused: no label call.")
}

if (dry) {
  read0 = reread_data(LIVE_ORDERS, basename(LIVE_ORDERS), LIVE_ORDERS_MISSING)
  cb0 = read0$codebook
  cb0$row_is = LIVE_ORDERS_ROW
  gold = yaml::read_yaml(file.path("tests", "gold_specs.yaml"))
  fams = c("bar", "line", "scatter", "dumbbell", "line", "box", "heatmap", "histogram")
  draws = function(s) !inherits(tryCatch(spec_plot(s, read0$read$data, cb0, chart_palette_default()), error = function(e) e), "error")
  specs = purrr::compact(purrr::map(unique(fams), function(f) purrr::detect(gold, function(g) identical(g$spec$family, f) && draws(g$spec))$spec))
  canvas = purrr::imap(specs, function(s, i) new_chart(paste0("c", i), s))
  stories = purrr::imap(canvas, function(ch, i) list(id = ch$id, headline = paste("Stand-in headline for chart", i), summary = paste0("A stand-in summary for chart ", i, "."), checked = TRUE,
                                                   problems = character(0), repaired = FALSE, facts = ""))
  run = list(cb = cb0, canvas = canvas, stories = stories, turns = list(), calls = tibble::tibble())
} else if (!nzchar(key)) {
  say("Result: no call was made; ANTHROPIC_API_KEY is not set.")
  quit(status = 0)
} else if (redo) {
  first <- readRDS(file.path("tests", "live_replies_11.rds"))
  run = first$phase11_chat
  prev = first$phase11_design
  say("The canvas of the first attempt (", run$when, ") is reused: ", length(run$canvas), " charts; that attempt made ", nrow(run$calls), " chat calls and ", length(prev$log), " design calls.")
} else {
  run = live_chat(home, key, say, rds = file.path("tests", "live_replies_11.rds"), max_calls = LIVE11_CHAT_MAX, plan = LIVE11_TURNS, phase = "phase11_chat")
  if (is.null(run)) { say("The run stopped before any chart was made (see above); there is nothing to design."); quit(status = 0) }
}
read <- reread_data(LIVE_ORDERS, basename(LIVE_ORDERS), LIVE_ORDERS_MISSING)
data <- read$read$data
cb <- run$cb
chat_used <- if (dry) 0L else nrow(run$calls)
prior_designs <- if (redo) length(prev$log) else 0L
say("\n---- The chat part used ", chat_used, " calls; ", length(run$canvas), " charts on the canvas")
if (!dry && !redo) purrr::walk(run$turns, function(t) say("  turn ", t$n, " \"", t$message, "\": expected ", LIVE11_EXPECT[[t$n]], "; came back ", t$kind,
                                                 if (length(t$added)) paste0(" (", paste(t$added, collapse = ", "), ")")))

# ---- the designs ---------------------------------------------------------------------------------------------------------------------------
design_asker <- function(key, max_calls) {
  env = new.env()
  env$log = list()
  env$n = 0L
  env$refused = 0L
  env$ask = function(user, m, system_prompt = NULL, max_tokens, validate = NULL, images = NULL) {
    if (env$n >= max_calls) {
      env$refused = env$refused + 1L
      stop("The limit of ", max_calls, " calls is reached, so no further call is made.", call. = FALSE)
    }
    env$n = env$n + 1L
    r = tryCatch(llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens, validate = validate, key = key, images = images), error = function(e) e)
    failed = inherits(r, "error")
    env$log[[length(env$log) + 1L]] = list(user = user, images = length(images), raw = if (failed) r$raw %||% NA_character_ else r$raw, error = if (failed) conditionMessage(r))
    if (failed) stop(r)
    r
  }
  env
}
# The dry stand-in: one plain code for any chart (the first two columns of d as points), and "ok" to every review.
dry_asker <- function() {
  env = new.env()
  env$n = 0L
  env$refused = 0L
  env$log = list()
  env$ask = function(user, m, system_prompt = NULL, max_tokens, validate = NULL, images = NULL) {
    env$n = env$n + 1L
    obj = if (length(images)) list(ok = TRUE, say = "Nothing to change.") else
      list(code = paste0("ggplot(d, aes(x = .data[[names(d)[1]]], y = .data[[names(d)[length(names(d))]]])) + geom_point(colour = tok$accent) + ",
                         "labs(title = txt$title, x = NULL, y = NULL) + theme_minimal(base_family = tok$body_family) + ",
                         "theme(plot.background = element_rect(fill = tok$ground, colour = NA), plot.title = element_text(colour = tok$text), axis.text = element_text(colour = tok$muted))"),
           motion = "fade", say = "A plain stand-in design.")
    if (!is.null(validate)) validate(obj)
    list(obj = obj, raw = as.character(jsonlite::toJSON(obj, auto_unbox = TRUE)), finish = "success", tokens = c(0, 0, 0), user_sent = user, model = "stand-in", attempts = 1L, seconds = 0, refused = list())
  }
  env
}

skills <- skills_load()
skill <- skills_ok(skills)[[LIVE11_SKILL]]
if (is.null(skill)) { say("The ", LIVE11_SKILL, " skill is not there; nothing is designed."); quit(status = 0) }
budget <- LIVE11_MAX - chat_used - prior_designs
asker <- if (dry) dry_asker() else design_asker(key, budget)
# the second attempt: the first attempt's accepted code, handed back by a stand-in (no call), so that it is checked again under the new rules
replay_asker <- function(code, say_txt) {
  env = new.env()
  env$n = 0L
  env$ask = function(user, m, system_prompt = NULL, max_tokens, validate = NULL, images = NULL) {
    env$n = env$n + 1L
    obj = list(code = code, motion = "none", say = say_txt %||% "")
    if (!is.null(validate)) validate(obj)
    list(obj = obj, raw = as.character(jsonlite::toJSON(obj, auto_unbox = TRUE)), finish = "success", tokens = c(0, 0, 0), user_sent = user, model = "replay of the first attempt",
         attempts = 1L, seconds = 0, refused = list())
  }
  env
}
prev_of <- function(id) if (redo) purrr::detect(prev$designs, function(x) identical(x$id, id))
to_redo <- if (redo) purrr::map_chr(purrr::keep(run$canvas, function(ch) !isTRUE(prev_of(ch$id)$ok)), "id") else character(0)
say("\n---- Designs: skill ", skill$title, " (version ", skill$version, "); ", budget, " calls left for them")
images <- "all"
designs <- purrr::reduce(run$canvas, function(acc, ch) {
  if (!dry && budget - asker$n < LIVE11_DESIGN_MIN) {
    say("\n  ", ch$id, ": NOT DESIGNED: ", budget - asker$n, " calls left, fewer than ", LIVE11_DESIGN_MIN)
    return(c(acc, list(list(id = ch$id, res = NULL, skipped = TRUE))))
  }
  t0 = Sys.time()
  n0 = asker$n
  old = prev_of(ch$id)
  replay = redo && isTRUE(old$ok)
  # a review round only while two calls are left for each chart still to be designed after this one
  after = length(to_redo) - match(ch$id, to_redo, nomatch = length(to_redo))
  rounds = if (redo && !replay && (budget - asker$n) - 2L * after < 3L) 0L else if (redo) 1L else DESIGN_REVIEW_ROUNDS
  if (redo && !replay && rounds == 0L) say("    [", ch$id, "] no review round: ", budget - asker$n, " calls left and ", after, " more charts to design")
  res = tryCatch(design_chart(ch, skill, data, cb, palette, ask = if (replay) replay_asker(old$code, old$say)$ask else asker$ask, m = home,
                              images = if (replay || rounds == 0L) "none" else images, rounds = rounds,
                              stage = function(s) say("    [", ch$id, "] ", s)),
                 error = function(e) list(ok = FALSE, reason = conditionMessage(e), calls = NULL, refusals = character(0)))
  if (replay && isTRUE(res$ok)) res$design$review = paste0("The first attempt's accepted code, checked again under the new rules (no new call). Then: ", old$review)
  if (replay) say("    [", ch$id, "] the first attempt's accepted code, checked again: ", if (isTRUE(res$ok)) "passes" else paste0("REFUSED: ", res$reason))
  secs = as.numeric(difftime(Sys.time(), t0, units = "secs"))
  calls = res$calls
  say("\n  ", ch$id, " (", chart_title(ch, "(no title)"), ", ", ch$spec$family, "): ", if (isTRUE(res$ok)) "DESIGNED" else paste0("FELL BACK: ", res$reason),
      "; calls ", asker$n - n0, "; ", sprintf("%.0f", secs), " s")
  if (length(res$refusals)) purrr::walk(res$refusals, function(r) say("    refused: ", r))
  if (isTRUE(res$ok)) say("    review: ", res$design$review, "\n    say: ", res$design$say %||% "(none)", "\n    motion: ", res$design$motion)
  if (!is.null(calls) && nrow(calls)) purrr::walk(fmt_calls(calls), say)
  # a picture the endpoint refuses on the first look: the rest are designed without the review, and the run says so
  if (!dry && !replay && identical(images, "all") && !is.null(calls) && any(calls$call == "review" & !calls$ok)) {
    last = asker$log[[length(asker$log)]]
    if (!is.null(last$error) && last$images > 0) {
      say("    THE REVIEW CALL FAILED: ", substr(last$error, 1, 300), "\n    The remaining charts are designed with the picture off (APP_DESIGN_IMAGES \"none\").")
      images <<- "none"
    }
  }
  c(acc, list(list(id = ch$id, res = res, seconds = secs, calls_n = asker$n - n0, skipped = FALSE)))
}, .init = list())
ok_n <- sum(purrr::map_lgl(designs, function(x) isTRUE(x$res$ok)))
say("\n---- ", ok_n, " of ", length(designs), " designs accepted; design calls ", asker$n, " of ", budget, if (asker$refused) paste0(" (", asker$refused, " refused at the limit)"))
if (!dry) {
  rds = file.path("tests", "live_replies_11.rds")
  all = if (file.exists(rds)) readRDS(rds) else list()
  all[[if (redo) "phase11_design2" else "phase11_design"]] = list(model = home$id, when = format(Sys.time(), "%Y-%m-%d %H:%M"), skill = list(id = skill$id, title = skill$title, version = skill$version),
                            designs = purrr::map(designs, function(x) list(id = x$id, ok = isTRUE(x$res$ok), reason = x$res$reason, refusals = x$res$refusals,
                                                                            code = x$res$design$code, say = x$res$design$say, review = x$res$design$review,
                                                                            rounds = x$res$design$rounds, changed = x$res$design$changed, calls = x$res$calls, seconds = x$seconds)),
                            log = asker$log)
  saveRDS(all, rds)
}

# ---- tests/designed.html ---------------------------------------------------------------------------------------------------------------------
esc <- function(x) htmltools::htmlEscape(paste(x, collapse = " "))
img64 <- function(f) if (!is.null(f) && file.exists(f)) paste0("data:image/png;base64,", jsonlite::base64_enc(readBin(f, "raw", file.info(f)$size))) else NULL
std_png <- function(ch) {
  p = spec_plot(ch$spec, data, cb, palette)
  sz = spec_size(attr(p, "spec"), attr(p, "table"))
  dpi = min(DESIGN_IMAGE_DPI, floor(DESIGN_IMAGE_PX / sz[["width"]]))
  f = tempfile("std_", fileext = chart_device_ext())
  chart_device(f, sz[["width"]], sz[["height"]], dpi)
  dev = grDevices::dev.cur()
  tryCatch(print(p), finally = grDevices::dev.off(dev))
  f
}
by_id <- function(xs, id) purrr::detect(xs, function(x) identical(x$id, id))
cards <- purrr::map_chr(designs, function(x) {
  ch = by_id(run$canvas, x$id)
  sf = tryCatch(std_png(ch), error = function(e) NULL)
  s64 = img64(sf)
  if (!is.null(sf)) unlink(sf)
  res = x$res
  d64 = if (isTRUE(res$ok)) img64(res$design$file)
  calls = res$calls
  paste0("<section><h2>", esc(x$id), ": ", esc(chart_title(ch, "(no title)")), " <small>(", esc(ch$spec$family), ")</small></h2>",
         "<div class='pair'><figure><figcaption>Standard drawing</figcaption>", if (!is.null(s64)) paste0("<img src='", s64, "' alt='standard drawing'>") else "<p>not drawn</p>", "</figure>",
         "<figure><figcaption>Designed with ", esc(skill$title), "</figcaption>", if (!is.null(d64)) paste0("<img src='", d64, "' alt='designed drawing'>")
         else paste0("<p class='fell'>", if (isTRUE(x$skipped)) "Not designed: the call budget ran out." else paste0("Fell back: ", esc(res$reason)), "</p>"), "</figure></div>",
         "<dl><dt>Say</dt><dd>", esc(if (isTRUE(res$ok)) res$design$say %||% "(none)" else "-"), "</dd>",
         "<dt>Review</dt><dd>", esc(if (isTRUE(res$ok)) res$design$review else "-"), "</dd>",
         "<dt>Rounds of review</dt><dd>", esc(if (isTRUE(res$ok)) res$design$rounds else "-"), "</dd>",
         "<dt>Refusals</dt><dd>", if (length(res$refusals)) paste0("<ol>", paste0("<li>", purrr::map_chr(res$refusals, esc), "</li>", collapse = ""), "</ol>") else "none", "</dd>",
         "<dt>Calls and seconds</dt><dd>", esc(x$calls_n %||% 0L), " calls, ", esc(sprintf("%.0f", x$seconds %||% 0)), " s",
         if (!is.null(calls) && nrow(calls)) paste0(" (", esc(paste0(calls$call, ifelse(calls$repair, " repair", ""), ifelse(calls$ok, "", " FAILED"), collapse = ", ")), ")"), "</dd></dl>",
         if (isTRUE(res$ok)) paste0("<details><summary>Design code</summary><pre>", esc(res$design$code), "</pre></details>"), "</section>")
})
html <- paste0("<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Designed charts</title><style>",
               ":root{--bg:#fff;--fg:#1d2433;--muted:#5b6475;--line:#d9dde4}@media (prefers-color-scheme:dark){:root{--bg:#14171c;--fg:#e8eaee;--muted:#a3abb8;--line:#2c323b}}",
               "body{background:var(--bg);color:var(--fg);font:15px/1.5 system-ui,sans-serif;margin:0 auto;max-width:1400px;padding:16px}h1{font-size:1.5rem}h2{font-size:1.1rem;margin-top:2rem;border-top:1px solid var(--line);padding-top:1rem}",
               "small,.muted,figcaption{color:var(--muted)}.pair{display:grid;grid-template-columns:1fr 1fr;gap:16px}@media (max-width:800px){.pair{grid-template-columns:1fr}}",
               "figure{margin:0}img{width:100%;height:auto;border:1px solid var(--line)}dl{display:grid;grid-template-columns:max-content 1fr;gap:4px 12px}dt{color:var(--muted)}dd{margin:0}",
               "pre{white-space:pre-wrap;font-size:12px;background:rgba(127,127,127,.08);padding:8px}.fell{color:#b3261e}</style></head><body>",
               "<h1>Designed charts", if (dry) " (dry run: stand-in designer)", "</h1><p class='muted'>", esc(home$id), ", ", esc(format(Sys.time(), "%Y-%m-%d %H:%M")), "; skill ", esc(skill$title),
               " in the ", esc(LIVE11_STYLE), " style's tokens; ", ok_n, " of ", length(designs), " designs accepted; calls: chat ", chat_used, ", designs ", prior_designs + asker$n, if (redo) paste0(" (", asker$n, " in the second attempt; the designs the first attempt accepted keep their code, checked again)"), " (limit ", LIVE11_MAX, ").</p>",
               paste(cards, collapse = "\n"), "</body></html>")
writeLines(html, html_file, useBytes = TRUE)
say("\n  wrote ", html_file, " (", format(round(file.info(html_file)$size / 1e6, 2), nsmall = 2), " MB)")

# ---- the designed dashboard --------------------------------------------------------------------------------------------------------------
say("\n---- Export: the designed charts, ", LIVE11_STYLE, " style (pictures; no design videos: Part C is not done)")
items <- purrr::map(designs, function(x) {
  ch = by_id(run$canvas, x$id)
  s = by_id(run$stories, x$id)
  story = if (!is.null(s) && is_text1(s$headline)) list(headline = s$headline, summary = s$summary, hash = spec_hash(ch$spec), data = "d", facts = s$facts %||% "", spec = ch$spec,
                                                        problems = s$problems %||% character(0))
  list(id = x$id, chart = ch, story = story, mode = "picture", design = if (isTRUE(x$res$ok)) x$res$design, stale = NA_character_)
})
settings <- list(marking = "UNCLASSIFIED//FOR TEST", title = "Orders, designed", subtitle = "Eight charts of 3,000 synthetic orders, designed with the Editorial skill", author = "chaRt live run",
                 date = Sys.Date(),
                 intro = paste0("This page was made by chaRt from tests/data/orders.csv. The charts were designed by ", home$id, " with the Editorial skill; R checked every design before it was used, ",
                                "and a chart whose design was refused keeps its standard drawing."),
                 boxes = c("rows", "columns", "third"), keys = character(0))
zip_file <- file.path(tempfile("live11_"), "dashboard_designed.zip")
dir.create(dirname(zip_file))
built <- tryCatch(build_dashboard(items, data, cb, palette, settings, LIVE_ORDERS, zip_file, model = home$id), error = function(e) e)
if (inherits(built, "error")) {
  say("The export failed: ", conditionMessage(built))
} else {
  if (dir.exists(dash_dir)) unlink(dash_dir, recursive = TRUE)
  dir.create(dash_dir, recursive = TRUE)
  zip::unzip(built$zip, exdir = dash_dir)
  say("  built in ", sprintf("%.1f", built$seconds), " s: ", format(round(built$bytes / 1e6, 2), nsmall = 2), " MB; modes: ", paste(built$modes, collapse = ", "), "; device ", built$device)
  fb = built$fallbacks[!is.na(built$fallbacks)]
  if (length(fb)) say("  FELL BACK: ", paste(names(fb), fb, sep = " - ", collapse = "; "))
  say("  unpacked into ", dash_dir, "/")
}
purrr::walk(designs, function(x) if (isTRUE(x$res$ok) && !is.null(x$res$design$file)) unlink(x$res$design$file))
say("\nDone. Calls made: ", chat_used + prior_designs + asker$n, " of ", LIVE11_MAX, " allowed (chat ", chat_used, ", designs ", prior_designs + asker$n,
    if (redo) paste0(": ", prior_designs, " in the first attempt, ", asker$n, " in this one"), ").")
