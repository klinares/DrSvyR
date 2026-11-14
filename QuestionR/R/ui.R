# ui.R for QuestionR
# Everything the analyst sees: the shared helpers, Start here and Methodology, the blocks a result is
#   made of (drawn once as HTML for the page and for Word, and once as text, so the two can never say
#   different things), and the two task pages. No flow logic: the pages call the engine in
#   R/review.R and draw what it returns. Function definitions and constants only.


# ==== the tabs, Start here and Methodology =======================================================

QUESTIONR_TABS <- c("Start here", "Evaluate questions", "Write questions", "Methodology")


# ---- shared helpers ----------------------------------------------------------

# A note to read, and a warning. Theme variables, with fallbacks, keep both legible in dark mode.
advice_box <- function(...)
  shiny::tags$div(style = paste("background: var(--bs-tertiary-bg); border-left: 3px solid var(--bs-primary);",
                                "color: var(--bs-body-color); padding: 8px 12px; margin: 12px 0;"), ...)

warn_box <- function(...)
  shiny::tags$div(style = paste("background: var(--bs-warning-bg-subtle, #fdf6ec); border-left: 3px solid var(--bs-warning, #d9a441);",
                                "color: var(--bs-warning-text-emphasis, var(--bs-body-color)); padding: 8px 12px; margin: 12px 0;",
                                "font-size: 90%;"), ...)

# The office logo named in app.R, from www/logo/; a dashed box until it exists.
office_logo <- function(file, office = "") {
  logo = if (file.exists(file.path("www", "logo", file)))
    tags$img(src = file.path("logo", file), alt = "Office logo", style = "height:48px;")
  else
    tags$div(style = paste("height:48px; width:160px; border:2px dashed #adb5bd;",
                           "border-radius:4px; color:#6c757d; font-size:12px;",
                           "display:flex; align-items:center; justify-content:center;"),
             "Office logo")
  tags$div(style = "display:flex; align-items:center; gap:12px;",
           logo,
           if (nzchar(office)) tags$span(style = "font-weight:600;", office))
}


# ---- Start here --------------------------------------------------------------

# The model as the page names it: the id, the API style in words and where it is called.
#   Never the key.
model_label <- function(m)
  tagList(tags$code(m$id), tags$br(),
          tags$span(class = "text-muted small",
                    paste0(switch(m$api %||% "", anthropic = "Anthropic API", openai = "OpenAI-style API",
                                  paste0("API '", m$api, "'")),
                           " at ", m$base_url, "; key pasted below")))

# A profile that still holds <placeholders> (the work profile before it is filled in) says which
#   entries to fill in, and nothing else about it fails.
placeholder_notice <- function(ms = app_models()) {
  bad = unlist(purrr::imap(ms, function(m, role) if (length(llm_placeholders(m))) paste0(role, " ", paste(llm_placeholders(m), collapse = ", "))))
  if (!length(bad)) return(NULL)
  warn_box(
    tags$strong(paste0("The ", APP_PROFILE, " profile still has placeholders to fill in. ")),
    "Open app.R, section 1, and replace each <placeholder> (README.md, Setting up at work). Still to fill in: ",
    paste(bad, collapse = "; "), ".")
}

# Start here: www/start.md; then the key box; then, closed, the settings in force and the connection check. The panel opens by itself when the
#   profile still holds placeholders, since that is the first thing to deal with.
start_ui <- function() {
  row = function(label, value) tags$tr(tags$th(scope = "row", label), tags$td(value))
  placeholders = placeholder_notice()
  tagList(
    md_page(START_FILE),
    mod_key_ui("key"),
    tags$details(
      class = "mt-3", open = if (!is.null(placeholders)) NA,
      tags$summary(tags$strong("Settings and connection")),
      placeholders,
      tags$table(class = "table table-sm", tags$tbody(
        row("Profile", APP_PROFILE),
        purrr::imap(app_models(), function(m, role) row(role, m$id)),
        row("Classification banner", APP_CLASSIFICATION),
        row("Pasted questionnaire limit", paste(format(APP_MAX_PASTE_CHARS, big.mark = ","), "characters")))),
      mod_connect_ui("connect")))
}

# The Methodology page: www/methodology.md, then the table of the reflexes, read from the reflex
#   files (file, what each checks, and its Source line as written), so it cannot drift from them.
methodology_ui <- function() {
  t = tryCatch(reflexes_table(), error = function(e) NULL)
  tagList(md_page(METHODOLOGY_FILE),
          if (is.null(t)) warn_box("The reflex files could not be read.")
          else tags$table(class = "table table-sm small",
                          tags$thead(tags$tr(tags$th("Reflex file"), tags$th("What it is for"), tags$th("Source"))),
                          tags$tbody(purrr::pmap(t, function(file, label, source)
                            tags$tr(tags$td(file), tags$td(label), tags$td(source))))))
}

# The model, and whether it has a key; and a button that makes one very small call to it. Never
#   shows a key. With no key it is not called: it says what is missing. ping is the function that
#   calls the model, so a test can stand in for the network.
mod_connect_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$hr(),
    tags$h4("Models"),
    uiOutput(ns("models")),
    actionButton(ns("check"), "Check the connection"),
    tags$p(class = "text-muted small mt-2",
           "Makes one very small call to each model, and shows whether it answered ",
           "or what the endpoint said. Nothing you have entered is sent."),
    uiOutput(ns("result")))
}

mod_connect_server <- function(id, state, ping = llm_ping) {
  moduleServer(id, function(input, output, session) {
    results <- reactiveVal(NULL)

    output$models <- renderUI({
      state$key_version   # a key pasted or forgotten changes whether it is ready
      purrr::imap(app_models(), function(m, role)
        tags$p(tags$strong(role), tags$br(), model_label(m), tags$br(),
               if (length(llm_placeholders(m))) tags$span(class = "text-warning", "Waits for the settings in app.R.")
               else if (llm_key_ready(m)) tags$span(class = "text-success", "Ready.")
               else tags$span(class = "text-warning", paste("Waits for a key.", KEY_HINT))))
    })

    observeEvent(input$check, {
      withProgress(message = "Checking the connection", value = 0.5,
                   results(purrr::map(unname(app_models()), function(m)
                     c(list(model = m$id), if (llm_key_ready(m)) ping(m) else llm_ping(m)))))
    })

    output$result <- renderUI({
      out <- results()
      if (is.null(out)) return(NULL)
      tags$table(
        class = "table table-sm",
        tags$thead(tags$tr(tags$th("Model"), tags$th("Result"), tags$th("Seconds"))),
        tags$tbody(purrr::map(out, function(r)
          tags$tr(tags$td(tags$code(r$model)),
                  tags$td(tags$span(class = if (isTRUE(r$ok)) "text-success" else "text-danger",
                                    if (isTRUE(r$ok)) "Ready" else r$message)),
                  tags$td(if (is.na(r$seconds)) "" else sprintf("%.1f", r$seconds))))))
    })
  })
}


# ==== what a result is made of =====================================================================

# ---- the pages that are markdown files ---------------------------------------------------

METHODOLOGY_FILE <- file.path("www", "methodology.md")
START_FILE <- file.path("www", "start.md")

# A markdown file drawn as written (commonmark with GitHub tables). A file that cannot be read is
#   said in words, not a crash.
md_html <- function(txt)
  tagList(tags$style(paste(".qr-note table { border-collapse: collapse; margin: 1rem 0; }",
                           ".qr-note th, .qr-note td { border: 1px solid var(--bs-border-color); padding: 6px 10px; vertical-align: top; }",
                           ".qr-note blockquote { border-left: 3px solid var(--bs-border-color); padding-left: 0.75rem; }")),
          tags$div(class = "qr-note", HTML(shiny::markdown(txt))))

md_page <- function(path)
  tryCatch(md_html(paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")),
           error = function(e) warn_box(tags$strong(paste0("The page ", basename(path), " could not be shown. ")),
                                        substr(conditionMessage(e), 1, 400)))


# ---- a document as blocks, drawn twice ------------------------------------------------------

# Each block has a `type`: "h" (text, level), "p" (text; marks: words to highlight; em; strong), "list"
#   (items; tags: a small tag before each item) or "table" (head, rows).
blk_h <- function(text, level = 2L) list(type = "h", text = text, level = level)
blk_p <- function(text, em = FALSE, marks = character(0), indent = FALSE, strong = FALSE)
  list(type = "p", text = text, em = em, marks = marks, indent = indent, strong = strong)
blk_list <- function(items, tags = NULL, indent = FALSE) list(type = "list", items = as.character(items), tags = tags, indent = indent)
blk_table <- function(head, rows) list(type = "table", head = head, rows = rows)

# A text with each of the marked words wrapped in <mark>, the rest escaped. A mark is found
#   whatever its case and spacing; one that is not in the text marks nothing.
marked_html <- function(text, marks) {
  marks = marks[nzchar(trimws(marks))]
  if (!length(marks)) return(htmltools::htmlEscape(text))
  escaped = gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", trimws(marks))
  pat = paste0("(", paste(gsub("\\s+", "\\\\s+", escaped), collapse = "|"), ")")
  pieces = regmatches(text, gregexpr(pat, text, ignore.case = TRUE, perl = TRUE), invert = NA)[[1]]
  paste0(purrr::imap_chr(pieces, function(x, i)
    if (i %% 2L == 0L) paste0("<mark>", htmltools::htmlEscape(x), "</mark>") else htmltools::htmlEscape(x)), collapse = "")
}

# The blocks as plain HTML: headings, paragraphs, lists and tables, which is what Word keeps when
#   it is pasted.
doc_html <- function(blocks)
  tagList(purrr::map(blocks, function(b) switch(b$type,
    h = if (b$level <= 2L) tags$h4(b$text) else tags$h5(b$text),
    p = tags$p(style = paste0("white-space: pre-line;", if (isTRUE(b$indent)) " margin-left: 2em;"),
               HTML(sprintf(if (isTRUE(b$strong)) "<strong>%s</strong>" else if (b$em) "<em>%s</em>" else "%s",
                            marked_html(b$text, b$marks)))),
    list = tags$ul(style = if (isTRUE(b$indent)) "margin-left: 2em;", purrr::imap(b$items, function(x, i)
      tags$li(if (length(b$tags)) tags$span(class = "badge text-bg-light border me-1", b$tags[[i]]), x))),
    table = tags$table(class = "table table-sm", tags$thead(tags$tr(purrr::map(b$head, tags$th))),
                       tags$tbody(purrr::map(b$rows, function(r) tags$tr(purrr::map(r, tags$td))))))))

# The same blocks as plain text.
doc_text <- function(blocks)
  paste(purrr::map_chr(blocks, function(b) switch(b$type,
    h = paste0(b$text, "\n", strrep(if (b$level <= 2L) "=" else "-", nchar(b$text))),
    p = paste0(if (isTRUE(b$indent)) "    ", b$text),
    list = paste0(if (isTRUE(b$indent)) "    ", "- ", if (length(b$tags)) paste0("[", b$tags, "] "), b$items, collapse = "\n"),
    table = paste(purrr::map_chr(c(list(b$head), b$rows), function(r) paste(r, collapse = " | ")), collapse = "\n"))),
    collapse = "\n\n")


# ---- a review, as blocks ------------------------------------------------------------------

# One question's card: the question as pasted with the quoted words highlighted, one line per flag
#   (its why, with its stage as a tag, and "consider" or "not found" where they apply), and the
#   rewrite. levels says which flags it shows.
card_blocks <- function(q, levels = LEVELS) {
  fl = purrr::keep(q$flags, function(x) x$level %in% levels)
  tag = function(x) paste(c(x$stage, if (x$level == "consider" && length(levels) > 1L) "consider",
                            if (!isTRUE(x$found)) "quote not found in your text"), collapse = ", ")
  c(list(blk_h(paste("Question", q$id), 3L), blk_p(q$text, marks = purrr::map_chr(fl, "quote"))),
    if (!q$reviewed) list(blk_p("Not reviewed: its part did not come back.", em = TRUE))
    else if (!length(fl)) list(blk_p("None found by this review.", em = TRUE))
    else list(blk_list(purrr::map_chr(fl, "why"), tags = purrr::map_chr(fl, tag))),
    if (!is.null(q$rewrite) && "fix" %in% levels) c(list(blk_p("Suggested wording", em = TRUE)), question_blocks(q$rewrite)))
}

# The questions to fix first: those with a fix-level flag, by number of fix flags and then in the
#   order pasted, at most n.
fix_first <- function(sh, n = 5L) {
  qs = purrr::keep(sh$questions, function(q) n_level(q, "fix") > 0L)
  utils::head(qs[order(-purrr::map_int(qs, n_level, level = "fix"), seq_along(qs))], n)
}

# The first words of a question, for the table.
first_words <- function(text, n = 8L) {
  w = strsplit(trimws(gsub("\\s+", " ", sub(QUESTION_LABEL, "", text, perl = TRUE))), " ", fixed = TRUE)[[1]]
  paste0(paste(utils::head(w, n), collapse = " "), if (length(w) > n) "..." else "")
}

# The review as the analyst reads it and copies it to Word: the bottom line; what to fix first (at
#   most five cards, fix-level flags only); and the table of all questions.
review_blocks <- function(sh)
  c(list(blk_h("Bottom line", 2L)), purrr::map(bottom_line(sh), blk_p),
    if (length(fix_first(sh))) c(list(blk_h("What to fix first", 2L)),
                                 unlist(purrr::map(fix_first(sh), card_blocks, levels = "fix"), recursive = FALSE)),
    list(blk_h("All questions", 2L),
         blk_table(c("Question", "Starts", "Fix", "Consider"),
                   purrr::map(sh$questions, function(q)
                     c(q$id, first_words(q$text), if (q$reviewed) c(n_level(q, "fix"), n_level(q, "consider")) else c("-", "-"))))))

# "How this was produced": date, model, reflex files and versions, number of calls, seconds.
produced_lines <- function(files, calls, m = APP_MODEL, time = Sys.time(), dir = REFLEXES_DIR) {
  versions = purrr::map_chr(files, function(x) paste0(x, " ", read_reflex_file(x, dir)$version))
  secs = sum(purrr::map_dbl(calls, function(x) as.numeric(x$seconds %||% 0)), na.rm = TRUE)
  c(paste0("Date: ", format(time, "%Y-%m-%d %H:%M")), paste0("Model: ", m$id, " (", llm_host(m), ")"),
    paste0("Reflex files and versions: ", paste(versions, collapse = "; ")),
    paste0("Calls: ", length(calls)), paste0("Seconds: ", round(secs)))
}


# ---- the drafted items, as the analyst has them -------------------------------------------

# state$items is the draft's items, each with every field (full_item()) and a uid, its place in the
#   draft, in the order shown; state$edits holds only what the analyst changed, by uid.
draft_items <- function(reply)
  purrr::imap(unname(reply$items %||% list()), function(it, i) c(full_item(it), list(uid = as.character(i))))

item_remove <- function(items, uid) purrr::discard(items, function(it) identical(it$uid, uid))

option_text <- function(o) paste(unlist(o), collapse = " ")

# An item with the analyst's changes put on it: `intro`, `stem`, options and rows (new texts by
#   number). An option or a row whose text is cleared is taken out.
apply_edits <- function(it, ed) {
  if (is.null(ed)) return(it)
  get = function(k, old) ed[[k]] %||% old
  texts = function(xs, k) {
    now = purrr::imap_chr(purrr::map_chr(xs %||% list(), option_text), function(o, j) get(paste0(k, j), o))
    as.list(now[nzchar(trimws(now))])
  }
  it$intro = get("intro", it$intro)
  it$stem = get("stem", it$stem)
  it$options = texts(it$options, "o")
  it$rows = texts(it$rows, "r")
  it$parts = purrr::imap(it$parts, function(p, j) {
    k = paste0("p", j, "_")
    p$when = get(paste0(k, "when"), p$when %||% "")
    p$stem = get(paste0(k, "stem"), p$stem %||% "")
    p$options = texts(p$options, paste0(k, "o"))
    p
  })
  it
}

# Every text of an item the analyst can edit, by its box name: intro, stem, o1.., r1.. (rows), and for
#   part j pj_when, pj_stem, pj_o1..
item_fields <- function(it) {
  o = function(xs, k) purrr::set_names(purrr::map_chr(xs %||% list(), option_text), paste0(k, seq_along(xs %||% list())))
  c(intro = it$intro, stem = it$stem, o(it$options, "o"), o(it$rows, "r"),
    unlist(purrr::imap(it$parts, function(p, j) {
      k = paste0("p", j, "_")
      c(purrr::set_names(c(p$when %||% "", p$stem %||% ""), paste0(k, c("when", "stem"))), o(p$options, paste0(k, "o")))
    })))
}

# The box ids on the page, and what the analyst changed in them: get(id) gives what is in a box. An
#   item's edits are its changed fields, by box name.
edit_input_id <- function(uid, ...) paste(c("ed", uid, ...), collapse = "_")

edits_from_inputs <- function(items, get)
  purrr::compact(purrr::set_names(purrr::map(items, function(it) {
    now = purrr::imap(item_fields(it), function(old, k) { v = get(edit_input_id(it$uid, k)); if (!is.null(v) && !identical(v, old)) v })
    now = purrr::compact(now)
    if (length(now)) now
  }), purrr::map_chr(items, "uid")))

final_items <- function(items, edits)
  purrr::map(items, function(it) c(apply_edits(it, edits[[it$uid]]), list(edited = !is.null(edits[[it$uid]]))))

WRITE_NOTICE <- "Drafted by one AI model and edited by a second against written criteria. Not a pretest."

# What an open question collects, in plain words; a part's lead ("If Yes:").
answer_line <- function(open_format) paste("Answer:", open_format)
part_lead <- function(when) {
  w = trimws(when %||% "")
  if (!nzchar(w)) return("")
  w = paste0(toupper(substr(w, 1, 1)), substring(w, 2))
  if (grepl("[:.]$", w)) w else paste0(w, ":")
}

# A filter part, asked before the item: its `when` says "before the item".
is_before <- function(p) grepl("^\\s*before the item", p$when %||% "", ignore.case = TRUE)

# One part as blocks, indented: its lead and stem, then its options or answer format.
part_blocks <- function(p) {
  opts = purrr::map_chr(p$options %||% list(), option_text)
  c(list(blk_p(trimws(paste(part_lead(p$when), p$stem)), indent = TRUE)),
    if (length(opts)) list(blk_list(opts, indent = TRUE))
    else if (nzchar(p$open_format %||% "")) list(blk_p(answer_line(p$open_format), indent = TRUE)))
}

# One question laid out the way it is asked, for both tabs: any filter asked before it (indented), the
#   intro, the stem in bold, the options one per line, the rows one per line under a small "Items"
#   lead, what an open question collects, then the other parts, indented. The programming text is not
#   on it.
question_blocks <- function(q) {
  texts = function(x) purrr::map_chr(x %||% list(), option_text)
  opts = texts(q$options)
  rows = texts(q$rows)
  before = purrr::map_lgl(q$parts %||% list(), is_before)
  c(unlist(purrr::map(q$parts[before], part_blocks), recursive = FALSE),
    if (nzchar(q$intro %||% "")) list(blk_p(q$intro)),
    list(blk_p(q$stem, strong = TRUE)),
    if (length(opts)) list(blk_list(opts)),
    if (length(rows)) list(blk_p("Items", em = TRUE), blk_list(rows)),
    if (!length(opts) && nzchar(q$open_format %||% "")) list(blk_p(answer_line(q$open_format))),
    unlist(purrr::map(q$parts[!before], part_blocks), recursive = FALSE))
}

# The final questions as blocks, under the one sentence: each with its domain and its card; then
#   "Before you field these" when the editor left anything for the analyst.
draft_blocks <- function(chosen, needs = list())
  c(list(blk_p(WRITE_NOTICE, em = TRUE)),
    unlist(purrr::imap(chosen, function(it, i)
      c(list(blk_h(paste("Question", i), 3L)), if (nzchar(it$domain)) list(blk_p(it$domain, em = TRUE)), question_blocks(it))),
      recursive = FALSE),
    if (length(needs)) list(blk_h("Before you field these", 2L), blk_list(purrr::map_chr(needs, option_text))))


# ---- the run log and keys ------------------------------------------------------------------

# The key this session could have used, for scrub_secrets(). Nothing is ever written with it.
known_keys <- function() {
  k = llm_session_key() %||% ""
  k[nzchar(k)]
}

# Every occurrence of a key taken out of a text. A key shorter than eight characters is not a key and
#   would damage ordinary words, so it is left.
scrub_secrets <- function(text, secrets) {
  secrets = secrets[nchar(secrets) >= 8L]
  purrr::reduce(secrets, function(t, s) gsub(s, "[key removed]", t, fixed = TRUE), .init = text)
}

QUESTIONR_VERSION <- "0.10"

# The run log as JSON: every run as flow_round() made it, with the prompts and their hashes, the raw
#   and parsed replies, and the analyst's edits. Keys scrubbed.
run_log_json <- function(rounds, profile = APP_PROFILE, time = Sys.time(), secrets = character(0))
  scrub_secrets(as.character(flow_log_json(list(
    app = "QuestionR", version = QUESTIONR_VERSION, written = format(time, "%Y-%m-%dT%H:%M:%S%z"),
    profile = profile, rounds = unname(rounds)))), secrets)


# ==== the task pages ===============================================================================

# ---- the one state object ---------------------------------------------------------

# What a task page holds: the cleaned form, the message as assembled and as sent, what the last run
#   returned, the drafted items as the analyst has them and what they changed, and every run.
STATE_DEFAULTS <- list(form = NULL, prompt = NULL, round = 0L, draft = NULL, refine = NULL, review = NULL,
                       items = list(), edits = list(), rounds = list())


# ---- shared pieces -------------------------------------------------------------------

# A message for the page, never a stack trace. Long endpoint messages are cut.
plain_message <- function(e) substr(conditionMessage(e), 1, 600)

safe_ui <- function(expr)
  tryCatch(expr, error = function(e) warn_box(tags$strong("This part could not be drawn. "), plain_message(e)))

# What the engine last said it was about to do, for progress_ask() to put on the page.
PROGRESS_NOTE <- new.env()

# What a run hands the engine as `ask` and `ask_all`: they say on the page what is going out, then
#   call llm_json() or llm_json_all(). Must run inside withProgress().
progress_ask <- function(total) {
  n = 0L
  function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    n <<- n + 1L
    setProgress(value = (n - 1L) / total, message = paste0("Call ", n, " of ", total),
                detail = paste0("Asking ", m$id, ". This can take a minute."))
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens, validate = validate)
  }
}

progress_ask_all <- function(total) {
  function(requests) {
    note = PROGRESS_NOTE$msg %||% ""
    PROGRESS_NOTE$msg <- NULL
    setProgress(value = 0, message = if (nzchar(note)) note else paste("Sending", length(requests), "calls together"),
                detail = "They run side by side; this can take a minute or two.")
    llm_json_all(requests)
  }
}



# ---- the form's widgets, one per field -------------------------------------------------

FIELD_SPECS <- list(
  research_question = list(label = "Research question (required)", type = "area", rows = 2),
  construct = list(label = "Construct", type = "text", help = "In a sentence, and its domains if it has several."),
  population = list(label = "Target population", type = "text"),
  country = list(label = "Country (optional)", type = "text"),
  modes = list(label = "Survey mode", type = "choices", choices = MODE_LABELS),
  n_items = list(label = "Number of items (1 to 10)", type = "number", value = 3),
  reference_period = list(label = "Reference period", type = "text", help = "For example: the past 7 days."),
  kinds = list(label = "Kinds of question in the questionnaire", type = "choices",
               choices = purrr::set_names(KINDS, KINDS), selected = KINDS),
  questionnaire = list(label = "Questions with their response options", type = "area", rows = 12,
                       help = "Leave a blank line between questions, or start each with its label (Q1., 1., 1), A1)."))

# The drafting tasks, as the Write questions page offers them.
DRAFT_TASKS <- names(purrr::keep(TASKS, function(t) t$kind == "draft"))

field_widget <- function(field, ns) {
  s = FIELD_SPECS[[field]]
  tagList(
    switch(s$type,
      text = textInput(ns(field), s$label, width = "100%"),
      area = textAreaInput(ns(field), s$label, rows = s$rows, width = "100%", resize = "vertical"),
      number = numericInput(ns(field), s$label, value = s$value, min = 1, max = MAX_ITEMS_PER_RUN, step = 1),
      choices = checkboxGroupInput(ns(field), s$label, inline = TRUE, selected = s$selected,
                                   choices = purrr::set_names(names(s$choices), unname(s$choices)))),
    if (!is.null(s$help)) tags$p(class = "text-muted small mt-n2", s$help))
}


# ---- drawing a result -------------------------------------------------------------------------

# A button that sets one input of a module to a value when it is pressed.
set_button <- function(label, input, value, ns, class = "btn btn-sm btn-outline-secondary")
  tags$button(type = "button", class = class, label,
              onclick = sprintf("Shiny.setInputValue('%s', '%s', {priority: 'event'})", ns(input), value))

# A card drawn from its blocks, so the page and the Word copy are the same words.
card_ui <- function(blocks) tags$div(class = "card mb-2", tags$div(class = "card-body py-2", doc_html(blocks)))

# The review page, top to bottom: the bottom line, what to fix first, all questions (a row opens to
#   the card with every flag), and, closed, how it was produced. A part that did not come back is
#   said, with a button to run it again.
review_page <- function(rv, ns, prompt_files = character(0)) {
  sh = shape_review(rv)
  failed = which(!purrr::map_lgl(rv$batches, function(b) identical(b$status, "ok")))
  tagList(
    if (length(failed)) warn_box(
      tags$strong("Part of the review did not come back. "), "Its questions are marked as not reviewed, not as clear.",
      tags$ul(class = "mb-0", purrr::map(failed, function(i) tags$li(
        rv$batches[[i]]$error, " ", set_button("Run this part again", "rerun", i, ns, "btn btn-sm btn-primary"))))),
    tags$h4("Bottom line"), purrr::map(bottom_line(sh), tags$p),
    if (length(fix_first(sh))) tagList(tags$h4("What to fix first"),
                                       purrr::map(fix_first(sh), function(q) card_ui(card_blocks(q, "fix")))),
    tags$h4("All questions"),
    tags$div(class = "qr-rows", purrr::map(sh$questions, function(q)
      tags$details(class = "border-bottom py-1",
                   tags$summary(tags$span(class = "fw-semibold me-2", q$id), first_words(q$text),
                                tags$span(class = "float-end small text-muted",
                                          if (q$reviewed) paste0("fix ", n_level(q, "fix"), ", consider ", n_level(q, "consider"))
                                          else "not reviewed")),
                   card_ui(card_blocks(q))))))
}

produced_panel <- function(files, calls)
  tags$details(class = "mt-3", tags$summary("How this was produced"),
               tags$ul(class = "small", purrr::map(produced_lines(files, calls), tags$li)))

# Copy for Word and the run log, at the bottom of a result. What is copied is the blocks drawn black
#   on white in a box off the screen, because a browser copies the colours it shows.
copy_and_log <- function(blocks, ns, secrets = character(0))
  tagList(
    tags$div(id = ns("word"), class = "qr-word", style = "position:absolute; left:-10000px; top:0; width:700px;",
             HTML(scrub_secrets(paste(as.character(doc_html(blocks)), collapse = "\n"), secrets))),
    tags$p(class = "mt-4",
           tags$button(type = "button", class = "btn btn-sm btn-primary me-2", "Copy for Word",
                       onclick = sprintf(paste0(
                         "var el=document.getElementById('%s'); var ok=false; try{var r=document.createRange(); ",
                         "r.selectNodeContents(el); var s=window.getSelection(); s.removeAllRanges(); s.addRange(r); ",
                         "ok=document.execCommand('copy'); s.removeAllRanges();}catch(e){} ",
                         "this.nextElementSibling.textContent= ok ? ' Copied.' : ' Not copied: your browser blocked it.';"), ns("word"))),
           tags$span(class = "small me-3"),
           downloadButton(ns("get_log"), "Download the run log", class = "btn-sm btn-outline-secondary")))

# One final question, numbered i: its domain, then the card of question_blocks() in boxes that can be
#   edited (the stem's in bold); then, closed, its Details; and the button that takes it out. ed is
#   what was changed before.
item_card <- function(it, i, ns, ed = NULL) {
  id = function(k) ns(edit_input_id(it$uid, k))
  area = function(k, value, style = NULL)
    tagAppendAttributes(textAreaInput(id(k), NULL, value = ed[[k]] %||% value, width = "100%", resize = "vertical",
                                      rows = max(1L, ceiling(nchar(value) / 90))), style = style, .cssSelector = "textarea")
  boxes = function(xs, k) purrr::imap(purrr::map_chr(xs %||% list(), option_text), function(o, j)
    textInput(id(paste0(k, j)), NULL, value = ed[[paste0(k, j)]] %||% o, width = "100%"))
  answer_ui = function(q, k)
    tagList(boxes(q$options, paste0(k, "o")),
            if (length(q$rows)) tagList(tags$p(class = "small text-muted mb-1", tags$em("Items")), boxes(q$rows, "r")),
            if (!length(q$options) && nzchar(q$open_format %||% "")) tags$p(class = "mb-1", answer_line(q$open_format)))
  part_ui = function(p, j) {
    k = paste0("p", j, "_")
    tags$div(style = "margin-left: 2em;",
             textInput(id(paste0(k, "when")), NULL, value = ed[[paste0(k, "when")]] %||% (p$when %||% ""), width = "100%"),
             area(paste0(k, "stem"), p$stem %||% ""), answer_ui(p, k))
  }
  before = purrr::map_lgl(it$parts, is_before)
  tags$div(class = "card mb-2", tags$div(
    class = "card-body py-2",
    tags$h6(class = "mb-0", paste("Question", i)),
    if (nzchar(it$domain)) tags$p(class = "small text-muted mb-1", tags$em(it$domain)),
    purrr::map(which(before), function(j) part_ui(it$parts[[j]], j)),
    if (nzchar(it$intro)) area("intro", it$intro),
    area("stem", it$stem, style = "font-weight: 600;"),
    answer_ui(it, ""),
    purrr::map(which(!before), function(j) part_ui(it$parts[[j]], j)),
    item_details(it),
    set_button("Remove", "remove", it$uid, ns)))
}

# An item's Details, closed: its programming line.
item_details <- function(it)
  if (nzchar(it$programming))
    tags$details(class = "mb-2", tags$summary(class = "small", "Details"),
                 tags$p(class = "small text-muted mb-1", paste("Programming:", it$programming)))

# "How these were written", closed: the two models, what the editor changed in each item, what the
#   items leave out, and the checks the editor applied.
written_panel <- function(w, items) {
  r = w$refine
  edited = identical(r$status, "ok")
  reply = final_reply(w)
  tags$details(class = "mt-3", tags$summary("How these were written"),
    tags$ul(class = "small",
      tags$li(paste0("Drafted by ", w$draft$model, if (edited) paste0("; edited by ", r$model) else "; not edited", ".")),
      if (edited) purrr::imap(items, function(it, i)
        tags$li(paste0("Question ", i, ": ", if (nzchar(it$changes)) it$changes else "no change by the editor"))),
      if (length(reply$not_covered)) tags$li(paste("Not covered:", paste(unlist(reply$not_covered), collapse = "; "))),
      if (edited && length(r$checks)) tags$li(paste("Checks applied:", paste(unique(unname(check_label(r$checks))), collapse = "; ")))))
}


# ---- a task page -------------------------------------------------------------------------------

# kind is "review" (Evaluate questions) or "draft" (Write questions).
mod_task_ui <- function(id, kind) {
  ns <- NS(id)
  review = kind == "review"
  tagList(
    tags$h3(if (review) "Evaluate questions" else "Write questions"),
    if (!review) radioButtons(ns("task"), "Kind of item", inline = TRUE,
                              choices = purrr::set_names(DRAFT_TASKS, purrr::map_chr(TASKS[DRAFT_TASKS], "label"))),
    purrr::map(TASKS[[if (review) "evaluate" else "attitudinal"]]$fields, function(f) field_widget(f, ns)),
    if (!review) conditionalPanel("input.task == 'behavioral'", ns = ns, field_widget("reference_period", ns)),
    actionButton(ns("prepare"), if (review) "Review these questions" else "Write the items", class = "btn-primary"),
    uiOutput(ns("message")),
    uiOutput(ns("box")),
    uiOutput(ns("results")), uiOutput(ns("items_ui")), uiOutput(ns("bottom")))
}

# app is the app's shared state (key_version). make_ask and make_ask_all build what the engine calls
#   the model through; a test hands in fakes.
mod_task_server <- function(id, kind, app, make_ask = progress_ask, make_ask_all = NULL) {
  moduleServer(id, function(input, output, session) {
    state <- do.call(reactiveValues, STATE_DEFAULTS)
    problem <- reactiveVal(NULL)
    message <- reactiveVal(NULL)
    say_progress <- function(msg) PROGRESS_NOTE$msg <- msg

    # The form as typed: the fields of the task chosen and nothing else.
    observeEvent(input$prepare, {
      message(NULL)
      task = if (kind == "review") "evaluate" else input$task %||% DRAFT_TASKS[1]
      typed = purrr::map(purrr::set_names(TASKS[[task]]$fields), function(k) input[[k]])
      f = tryCatch({
        f = clean_form(c(list(task = task), typed))
        if (kind == "review") review_plan(f$questionnaire)
        f
      }, error = function(e) { message(plain_message(e)); NULL })
      state$form <- f
      state$prompt <- NULL
    })

    # The short box: what the model is told, as the analyst may edit it, and the Run button. For a
    #   review it says how many questions were found, so the analyst can go back if that is wrong.
    output$box <- renderUI(safe_ui({
      req(state$form)
      n = if (kind == "review") length(split_questions(state$form$questionnaire))
      tagList(
        if (!is.null(n)) advice_box(paste0("Found ", n, if (n == 1L) " question." else " questions."),
                                    " If that is wrong, put a blank line between questions and press the button again."),
        textAreaInput(session$ns("user"), "What the model is told (you can edit it)", value = assemble_message(state$form),
                      rows = 10, width = "100%", resize = "vertical"),
        actionButton(session$ns("run"), "Run", class = "btn-primary"))
    }))

    observeEvent(input$run, {
      problem(NULL)
      f = state$form
      req(f)
      msg = gsub("\r\n?", "\n", input$user %||% "")
      if (!nzchar(trimws(msg))) return(problem("The box is empty: there is nothing to send."))
      state$prompt <- list(assembled = assemble_message(f), sent = msg)
      m = APP_MODEL
      out = tryCatch(
        if (kind == "review") withProgress(message = "Reviewing the questionnaire", value = 0, {
          calls = length(review_plan(f$questionnaire))
          ask = make_ask(calls)
          list(review = run_review(f, m, ask = ask, message = msg, progress = say_progress,
                                   ask_all = if (is.null(make_ask_all)) ask_all_for(ask) else make_ask_all(calls)))
        })
        else withProgress(message = "Drafting the items, then editing them", value = 0,
                          run_write(f, m, ask = make_ask(2L), message = msg)),
        error = function(e) { problem(paste0("The run stopped: ", plain_message(e))); NULL })
      if (is.null(out)) return()
      state$round <- (state$round %||% 0L) + 1L
      state$draft <- out$draft
      state$refine <- out$refine
      state$review <- out$review
      state$items <- if (identical(out$draft$status, "ok")) draft_items(final_reply(out)) else list()
      state$edits <- list()
      state$rounds <- c(state$rounds, list(flow_round(f, m, draft = out$draft, review = out$review, refine = out$refine,
                                                      prompt = state$prompt)))
    })

    observeEvent(input$rerun, {
      req(state$review, state$form)
      out = tryCatch(withProgress(message = "Running the part again", value = 0,
                                  rerun_review_part(state$form, APP_MODEL, state$review, as.integer(input$rerun),
                                                    ask = make_ask(1L), message = state$prompt$sent)),
                     error = function(e) { problem(paste0("The part could not be run again: ", plain_message(e))); NULL })
      if (is.null(out)) return()
      state$review <- out
      n = length(state$rounds)
      if (n) state$rounds[[n]] <- flow_round(state$form, APP_MODEL, review = out, prompt = state$prompt)
    })

    observe({
      req(length(state$items) > 0L)
      state$edits <- edits_from_inputs(state$items, function(id) input[[id]])
    })
    observeEvent(input$remove, state$items <- item_remove(state$items, input$remove))

    files = reactive(names(reflexes_in_force(state$form, "items")))

    output$message <- renderUI(if (!is.null(message())) warn_box(message()))

    output$results <- renderUI(safe_ui({
      if (!is.null(problem())) return(warn_box(problem()))
      req(state$round >= 1L)
      if (kind == "review") {
        rv = state$review
        if (identical(rv$status, "failed") && !length(rv$batches)) return(warn_box(rv$error))
        app$key_version
        return(HTML(scrub_secrets(as.character(review_page(rv, session$ns)), known_keys())))
      }
      d = state$draft
      if (!identical(d$status, "ok")) return(warn_box(tags$strong("The draft did not come back. "), d$error))
      tagList(tags$p(tags$em(WRITE_NOTICE)),
              if (!identical(state$refine$status, "ok"))
                warn_box(tags$strong("These questions were not edited. "), "The editing call did not come back, so ",
                         "these are the draft as written. ", state$refine$error))
    }))

    # Drawn on their own, so a removal redraws them and nothing else; what the analyst typed is put
    #   back from state$edits, which they do not read.
    output$items_ui <- renderUI(safe_ui({
      req(state$round >= 1L, kind == "draft", identical(state$draft$status, "ok"))
      w = list(draft = state$draft, refine = state$refine)
      needs = final_reply(w)$needs_from_analyst %||% list()
      tagList(
        purrr::imap(state$items, function(it, i) item_card(it, i, session$ns, isolate(state$edits)[[it$uid]])),
        if (length(needs)) tagList(tags$h5("Before you field these"), tags$ul(purrr::map(needs, function(x) tags$li(option_text(x))))),
        written_panel(w, state$items))
    }))

    blocks <- reactive({
      if (kind == "review") review_blocks(shape_review(state$review))
      else draft_blocks(final_items(state$items, state$edits),
                        final_reply(list(draft = state$draft, refine = state$refine))$needs_from_analyst %||% list())
    })

    output$bottom <- renderUI(safe_ui({
      req(state$round >= 1L)
      app$key_version
      tagList(copy_and_log(blocks(), session$ns, known_keys()),
              if (kind == "review") produced_panel(files(), run_calls(review = state$review)))
    }))

    output$get_log <- downloadHandler(
      filename = function() paste0("questionr-run-log-", format(Sys.time(), "%Y%m%d-%H%M"), ".json"),
      content = function(file) {
        rounds = state$rounds
        n = length(rounds)
        if (n && !is.null(state$draft))
          rounds[[n]]$analyst <- list(edits = state$edits, final = final_items(state$items, state$edits))
        writeLines(run_log_json(rounds, secrets = known_keys()), file, useBytes = TRUE)
      })
  })
}
