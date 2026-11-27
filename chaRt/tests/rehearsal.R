# Night task 02, Part B: a rehearsal on three files the app has never seen (tests/make_rehearsal.R makes them), live, through the app's own functions:
#   read_data()/reread_data() (the Excel file through the sheet picker's read_excel_data()), label_columns() (the dictionary's call), chat_turn() for each
#   question (by live_turn(), tests/live_gallery.R, as the Phase 6 and 11 runs do), r_headline() and summarize_charts() for every chart drawn,
#   summary_table() for one table, and build_dashboard() for the export (Clean, marking UNCLASSIFIED).
#   Run from inside chaRt/:   Rscript --no-init-file tests/rehearsal.R
# Calls: at most REHEARSAL_MAX for the run and REHEARSAL_FILE_MAX for a file, Sonnet only (the model's id is checked), counted; the key is read
#   from .Renviron and never printed. Every reply is kept in tests/rehearsal_replies.rds (git-ignored); REHEARSAL_REPLAY=1 makes no call: the
#   saved replies are handed back in order, checked again, and the pages built again (written to tests/rehearsal_replay.out, the live record kept).
# Writes tests/rehearsal.out (each file: the read, the dictionary, each question and what came back, each chart's two headlines, the table, the
#   export, the search of the messages for row values) and the pages under tests/rehearsal_survey/, tests/rehearsal_wide/, tests/rehearsal_tickets/
#   (git-ignored).
stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
invisible(shiny::shinyAppDir("."))
if (!exists("live_turn")) source(file.path("tests", "live_gallery.R"))

REHEARSAL_MAX <- 35L
REHEARSAL_FILE_MAX <- 12L
RDS <- file.path("tests", "rehearsal_replies.rds")
replay <- identical(Sys.getenv("REHEARSAL_REPLAY"), "1")
OUT <- file.path("tests", if (replay) "rehearsal_replay.out" else "rehearsal.out")   # a replay keeps the live run's record
dry <- identical(Sys.getenv("REHEARSAL_DRY"), "1")   # no call and no key: the dictionary as R makes it, one hand-written chart a file, no model text (the plumbing)
key <- Sys.getenv("ANTHROPIC_API_KEY")
home <- APP_PROFILES$home
if (grepl("opus", home$id, ignore.case = TRUE)) stop("Live tests call Sonnet models only; '", home$id, "' is an Opus model.", call. = FALSE)
if (!replay && !dry && !nzchar(key)) stop("No ANTHROPIC_API_KEY: no call is made.", call. = FALSE)
if (file.exists(OUT)) file.remove(OUT)
say <- function(...) {
  txt = paste0(c(...), collapse = "")
  if (nzchar(key)) txt = gsub(key, "[key]", txt, fixed = TRUE)
  cat(txt, "\n", sep = "")
  cat(txt, "\n", sep = "", file = OUT, append = TRUE)
}

ask_turns <- function(...) purrr::map(c(...), function(m) list(message = m, select = "none"))
FILES <- list(
  list(id = "survey", path = file.path("tests", "data", "survey.csv"), row = "one respondent", dir = file.path("tests", "rehearsal_survey"),
       dry = list(family = "bar", x = "region", fn = "count", title = "Respondents by region"),
       title = "Survey rehearsal", sub = "1,200 invented respondents",
       table = list(title = "Attitude items by age group", measures = c("q12_trust_police", "q13_trust_media", "q14_satisfied_life", "weight"), by = "age_group"),
       turns = ask_turns("compare satisfaction with life across age groups",
                         "how did trust in government change over the weeks of interviewing?",
                         "is trust in the courts related to trust in the police?",
                         "show the distribution of trust in the media",
                         "what share of the whole population trusts the police, using the survey weights?",
                         "what's interesting here?")),
  list(id = "wide", path = file.path("tests", "data", "indicators_wide.xlsx"), row = "one country", dir = file.path("tests", "rehearsal_wide"),
       dry = list(family = "histogram", x = "2024", title = "Internet use in 2024"),
       title = "Wide file rehearsal", sub = "40 invented countries, one column a year",
       table = list(title = "Internet use in 2015 and 2024 by region", measures = c("2015", "2024"), by = "Region"),
       turns = ask_turns("compare the regions on internet use in 2024",
                         "how has internet use changed from 2015 to 2024?",
                         "is internet use in 2015 related to internet use in 2024?",
                         "show the distribution of internet use in 2024 across countries",
                         "forecast internet use in 2030 for every country",
                         "what's interesting here?")),
  list(id = "tickets", path = file.path("tests", "data", "tickets.csv"), row = "one support ticket", dir = file.path("tests", "rehearsal_tickets"),
       dry = list(family = "bar", x = "team", fn = "count", title = "Tickets by team"),
       title = "Tickets rehearsal", sub = "8,000 invented support tickets",
       table = list(title = "Satisfaction by priority", measures = c("satisfaction", "cost"), by = "priority"),
       turns = ask_turns("compare satisfaction across teams",
                         "how many tickets were opened each month?",
                         "is the cost of a ticket related to its satisfaction score?",
                         "how long do tickets take to close?",
                         "which customers complain the most? list their customer ids",
                         "what's interesting here?")))

saved <- if (replay) readRDS(RDS) else list()
# a stand-in for llm_json() that hands back the saved replies of a file in order (REHEARSAL_REPLAY=1): no call
replay_asker <- function(log) {
  env = new.env()
  env$log = list(); env$n = 0L; env$stopped = FALSE; env$refused = 0L
  env$ask = function(user, m, system_prompt = NULL, max_tokens, validate = NULL, images = NULL) {
    env$n = env$n + 1L
    if (env$n > length(log)) { env$stopped = TRUE; stop("The replay has no saved reply for this call.", call. = FALSE) }
    l = log[[env$n]]
    env$log[[env$n]] = l
    if (!is.null(l$error)) stop(l$error, call. = FALSE)
    obj = parse_json_block(l$raw)
    if (!is.null(validate)) validate(obj)
    list(obj = obj, raw = l$raw, finish = "success", tokens = c(0, 0, 0), seconds = 0)
  }
  env
}

# The row values that must never reach a model: the ids, the subject lines, the dates of interview, the countries' names (counted apart: a
#   name of a group is DATA's, a row value only on a file of one row a country)
leak_values <- function(f, data) {
  pick = function(cols) unique(stats::na.omit(as.character(unlist(data[intersect(cols, names(data))]))))
  list(ids = pick(c("respondent_id", "ticket_id", "customer_id")), subjects = pick("subject"), countries = pick("Country"))
}
leak_count <- function(texts, values) {
  values = values[nchar(values) >= 4L]
  if (!length(values)) return(list(n = 0L, hits = character(0)))
  hit = purrr::keep(values, function(v) any(grepl(v, texts, fixed = TRUE)))
  list(n = length(hit), hits = utils::head(hit, 5L))
}

used <- 0L
results <- purrr::map(FILES, function(f) {
  say("\n==== ", f$id, ": ", f$path)
  if (!file.exists(f$path)) { say("  not there: run tests/make_rehearsal.R first"); return(NULL) }
  budget = min(REHEARSAL_FILE_MAX, REHEARSAL_MAX - used)
  asker = if (replay) replay_asker(saved[[f$id]]$log) else if (dry) replay_asker(list()) else live_asker(key, budget)
  # 1. the read, as the app reads a file when it is chosen: no codes for missing given (the analyst has not said any)
  rd = tryCatch(reread_data(f$path, basename(f$path), character(0)), error = function(e) e)
  if (inherits(rd, "error")) { say("  READ FAILED: ", conditionMessage(rd)); return(list(id = f$id, error = conditionMessage(rd))) }
  data = rd$read$data
  ex = rd$read$excel
  if (!is.null(ex)) say("  Excel: sheets ", paste(names(excel_sheet_choices(ex$sheets)), collapse = "; "), "; sheet read ", ex$sheet, "; tables ", nrow(ex$tables),
                        if (nrow(ex$tables)) paste0(" (", paste(names(excel_table_choices(ex$tables)), collapse = "; "), ")"), "; asks: ", ex$ask %||% "nothing")
  say("  read: ", format_num(nrow(data)), " rows, ", ncol(data), " columns")
  purrr::walk(rd$read$problems, function(p) say("  problem: ", p))
  # what the chat says when the file is read (the server's read message): the values it offers to treat as missing, and its cautions
  say("  the chat offers as missing: ", if (length(missing_candidates(data))) paste(missing_candidates(data), collapse = ", ") else "(nothing)")
  purrr::walk(read_cautions(data), function(p) say("  the chat says: ", p))
  say("  profile: ", paste(purrr::map_chr(rd$profile %||% profile_data(data), function(p) paste0(p$name, " (", p$type, ")")), collapse = ", "))
  # 2. the dictionary: the label call
  lab = if (dry) list(codebook = rd$codebook, calls = tibble::tibble(), error = NULL, row_is_guess = NULL) else label_columns(rd$codebook, ask = asker$ask, m = home)
  purrr::walk(fmt_calls(lab$calls), say)
  if (!is.null(lab$error)) { say("  DICTIONARY FAILED: ", lab$error); return(list(id = f$id, error = lab$error, log = asker$log, n = asker$n)) }
  cb = lab$codebook
  cb$row_is = f$row
  say("  row_is guess: ", lab$row_is_guess %||% "(none)", "; set to '", f$row, "'")
  say("  codes for missing in the dictionary: ", if (length(unlist(cb$missing_codes))) paste(unlist(cb$missing_codes), collapse = ", ") else "(none)")
  purrr::walk(cb$columns, function(e) say("    ", e$name, ": ", e$label %||% "", " [", e$type %||% "", ", ", e$role %||% "", if (length(e$order)) paste0("; order ", paste(unlist(e$order), collapse = " < ")), "]",
                                         if (!is.null(e$min)) paste0(" range ", e$min, " to ", e$max %||% "")))
  # 3. the six questions, each with nothing selected
  st = if (dry) list(canvas = list(new_chart("c1", f$dry)), turns = list()) else purrr::reduce(seq_along(f$turns), function(st, i) live_turn(st, i, cb, data, home, asker, say, f$turns),
                     .init = list(canvas = list(), selected = NULL, last = NULL, n = 0L, first_added = list(), turns = list(), skipped = integer(0)))
  canvas = rev(st$canvas)
  # 4. every chart: R's headline, then the model's headline and summary (one summary call for the file)
  out = if (!dry && length(canvas) && !isTRUE(asker$stopped)) tryCatch(summarize_charts(canvas, cb, data, ask = asker$ask, palette = chart_palette_default(), m = home), error = function(e) e)
  if (inherits(out, "error")) { say("  SUMMARY FAILED: ", conditionMessage(out)); out = NULL }
  if (!is.null(out)) purrr::walk(fmt_calls(out$calls), say)
  charts = purrr::map(canvas, function(ch) {
    rh = tryCatch(r_headline(ch, cb, data), error = function(e) list(text = paste("ERROR:", conditionMessage(e)), source = "error", problems = character(0)))
    s = out$charts[[ch$id]]
    story = if (!is.null(s) && is_text1(s$headline)) list(headline = s$headline, summary = s$summary, hash = spec_hash(ch$spec), data = "d", facts = s$facts %||% "", spec = ch$spec,
                                                         problems = s$problems %||% character(0), headline_by = "model")
    shown = headline_shown(story, rh)
    say("\n  ", ch$id, " ", ch$spec$family, ": ", chart_title(ch, "(no title)"),
        "\n    R's headline:    ", rh$text, " [", rh$source, if (length(rh$problems)) paste0(": ", paste(rh$problems, collapse = "; ")), "]",
        "\n    model headline:  ", s$headline %||% "(none)", " [", if (isTRUE(s$checked)) "passed" else paste(s$problems %||% s$text %||% "", collapse = "; "), if (isTRUE(s$repaired)) ", after a repair", "]",
        "\n    model summary:   ", s$summary %||% "(none)",
        "\n    card shows:      ", shown$text, " (", shown$by, ")",
        if (length(ch$notes)) paste0("\n    notes: ", paste(ch$notes, collapse = " | ")))
    list(chart = ch, r = rh, story = story, shown = shown)
  })
  # 5. one summary-statistics table
  tbl = tryCatch(summary_table(data, cb, intersect(f$table$measures, names(data)), if (f$table$by %in% names(data)) f$table$by), error = function(e) e)
  if (inherits(tbl, "error")) say("\n  TABLE FAILED: ", conditionMessage(tbl)) else {
    say("\n  table: ", f$table$title, " (", nrow(tbl), " rows)")
    utils::capture.output(print(as.data.frame(tbl)[, intersect(c("column", "kind", "group", "n", "missing", "mean", "median", "min", "max", "small"), names(tbl)), drop = FALSE], row.names = FALSE)) |>
      purrr::walk(function(l) say("    ", l))
  }
  # 6. the export: Clean, UNCLASSIFIED
  items = c(purrr::map(charts, function(x) list(id = x$chart$id, chart = x$chart, story = x$story, mode = "picture", design = NULL, stale = NA_character_)),
            if (!inherits(tbl, "error")) list(list(id = "t1", table = list(title = f$table$title, measures = intersect(f$table$measures, names(data)), by = if (f$table$by %in% names(data)) f$table$by, ci = TRUE), mode = "table")))
  settings = list(marking = "UNCLASSIFIED", title = f$title, subtitle = f$sub, author = "chaRt rehearsal", date = Sys.Date(),
                  intro = paste0("Made by chaRt from ", basename(f$path), ", a file of invented data, to rehearse the app on a new shape of file."),
                  boxes = c("rows", "columns", "third"), keys = character(0))
  zip_file = file.path(tempfile("rehearsal_"), paste0(f$id, ".zip"))
  dir.create(dirname(zip_file))
  built = tryCatch(build_dashboard(items, data, cb, chart_palette_default(), settings, f$path, zip_file, model = home$id), error = function(e) e)
  if (inherits(built, "error")) say("\n  EXPORT FAILED: ", conditionMessage(built)) else {
    if (dir.exists(f$dir)) unlink(f$dir, recursive = TRUE)
    dir.create(f$dir, recursive = TRUE)
    zip::unzip(built$zip, exdir = f$dir)
    say("\n  export: ", f$dir, "/ (", format(round(built$bytes / 1e6, 2), nsmall = 2), " MB, ", length(items), " cards)")
  }
  # 7. what reached the model: every system and user message of the file, searched for the row values
  texts = unlist(purrr::map(asker$log, function(l) c(l$system, l$user)))
  lv = leak_values(f, data)
  leaks = purrr::map(lv, function(v) leak_count(texts, v))
  say("\n  messages searched: ", length(asker$log), " calls; ", paste(names(leaks), purrr::map_int(leaks, "n"), sep = " found ", collapse = "; "),
      " (of ", paste(purrr::map_int(lv, length), collapse = ", "), " values)", unlist(purrr::imap(leaks, function(l, k) if (l$n) paste0("\n    ", k, ": ", paste(l$hits, collapse = " | ")))))
  say("  calls for this file: ", asker$n, if (asker$refused) paste0(" (", asker$refused, " refused at the limit)"))
  used <<- used + if (replay) 0L else asker$n
  list(id = f$id, cb = cb, turns = st$turns, charts = purrr::map(charts, function(x) x[c("r", "story", "shown")]), canvas = canvas, log = asker$log, n = asker$n, leaks = leaks)
})
if (!replay && !dry) saveRDS(stats::setNames(results, purrr::map_chr(FILES, "id")), RDS)
say("\nDone. Calls made: ", used, " of ", REHEARSAL_MAX, if (replay) " (replay: none)")
