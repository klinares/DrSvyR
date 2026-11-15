# ui.R: what the tabs share (boxes, the office logo, the source card) and the Start here tab.
#   Function definitions and constants only.

APP_TABS <- c("Start here", "Ask", "Formulas", "Report reader")

APP_CSS <- paste(
  ".survai-code { background: var(--bs-tertiary-bg); padding: 8px 10px; border-radius: 4px; font-size: 88%; overflow-x: auto; }",
  ".card-body pre { overflow-x: auto; max-width: 100%; }",
  ".tok-com { color: #6a737d; font-style: italic; } .tok-str { color: #22863a; } .tok-fn { color: #005cc5; }",
  ".tok-kw { color: #d73a49; font-weight: 600; } .survai-formula { margin: 0.6em 0; overflow-x: auto; }",
  ".survai-sources li { margin-bottom: 2px; } .survai-live { white-space: normal; opacity: 0.85; }",
  ".survai-flags { font-size: 90%; color: var(--bs-warning-text-emphasis, #8a6d3b); }")

# The stream and the progress note are written straight into the page while a question runs.
APP_JS <- paste(
  "Shiny.addCustomMessageHandler('survai-html', function(m) {",
  "  var el = document.getElementById(m.id); if (el) el.innerHTML = m.html; });")

advice_box <- function(...)
  tags$div(style = paste("background: var(--bs-tertiary-bg); border-left: 3px solid var(--bs-primary);",
                         "color: var(--bs-body-color); padding: 8px 12px; margin: 12px 0;"), ...)

warn_box <- function(...)
  tags$div(style = paste("background: var(--bs-warning-bg-subtle, #fdf6ec); border-left: 3px solid var(--bs-warning, #d9a441);",
                         "padding: 8px 12px; margin: 12px 0; font-size: 90%;"), ...)

classification_banner <- function(text)
  tags$div(style = paste("background:#b40404; color:#fff; text-align:center; font-weight:700;",
                         "letter-spacing:0.06em; padding:5px 0; font-size:13px;"), text)

# The office logo named in app.R, from www/logo/; a dashed box until it exists.
office_logo <- function(file, office = "") {
  logo = if (file.exists(file.path("www", "logo", file))) tags$img(src = file.path("logo", file), alt = "Office logo", style = "height:48px;")
  else tags$div(style = paste("height:48px; width:160px; border:2px dashed #adb5bd; border-radius:4px; color:#6c757d;",
                              "font-size:12px; display:flex; align-items:center; justify-content:center;"), "Office logo")
  tags$div(style = "display:flex; align-items:center; gap:12px;", logo, if (nzchar(office)) tags$span(style = "font-weight:600;", office))
}

# ---- Start here ---------------------------------------------------------------------------------------------

START_LINES <- c(
  "SurvAI Expert answers survey methodology questions from a store of course materials: lecture notes, slides, assignments, exams, a sampling and weighting textbook, and R code.",
  "Each answer cites the passages it uses. Click a source to read the passage itself, with its formulas and code.",
  "Formulas are shown exactly as stored in the course materials, never retyped by the model.",
  "The Formulas page searches the stored formulas directly, with no model calls.",
  "The Report reader turns a survey's technical report into a checklist an analyst can use.")

store_counts <- function(con) dbGetQuery(con, paste(
  "SELECT d.source AS Source, count(DISTINCT d.id) AS Documents,",
  "(SELECT count(*) FROM passages p WHERE p.source = d.source) AS Passages,",
  "(SELECT count(*) FROM formulas f WHERE f.source = d.source) AS Formulas,",
  "(SELECT count(*) FROM code c WHERE c.source = d.source AND NOT c.is_output) AS \"Code blocks\"",
  "FROM docs d GROUP BY d.source ORDER BY d.source"))

start_ui <- function(id) {
  ns = NS(id)
  tagList(
    tags$h3("What this tool does"), tags$ul(map(START_LINES, tags$li)),
    tags$h4("What is in the store"), tableOutput(ns("store")),
    tags$h4("How to ask"),
    tags$p("Ask one question at a time, in plain words: \"How do I compute a design effect for a cluster sample in R?\" or ",
           "\"When is raking better than poststratification?\". Fill in My data to get R code with your own variable names. ",
           "A follow-up question keeps the previous question and answer in mind; press New topic to start fresh."),
    mod_key_ui(ns("key")),
    tags$p(textOutput(ns("calls"), inline = TRUE)))
}

start_server <- function(id, state, con) {
  moduleServer(id, function(input, output, session) {
    mod_key_server("key", state)
    output$store = renderTable(store_counts(con), digits = 0)
    output$calls = renderText({
      state$calls
      paste0("Each question uses 2 model calls (a plan and an answer). Calls made this session: ", calls_made(session$token),
             if (!is.na(CALLS_PER_WINDOW)) sprintf(" (limit %d per %d minutes).", CALLS_PER_WINDOW, CALL_WINDOW_MINUTES) else ".")
    })
  })
}

# ---- the source card ------------------------------------------------------------------------------------------

# Where a markdown file opens: APP_SOURCE_URL with {path} and {line} filled in.
source_url <- function(markdown, line) {
  enc = paste(map_chr(str_split_1(markdown, "/"), function(s) utils::URLencode(s, reserved = TRUE)), collapse = "/")
  str_replace_all(APP_SOURCE_URL, c("\\{path\\}" = enc, "\\{line\\}" = as.character(line %||% 1L)))
}

card_ui <- function(id)
  tags$div(style = "position: sticky; top: 8px;",
           bslib::card(full_screen = TRUE, max_height = "88vh", bslib::card_header(textOutput(NS(id, "head"), inline = TRUE)),
                       bslib::card_body(uiOutput(NS(id, "body")))))

# passage_id: a reactive holding the passage to show (or NULL).
card_server <- function(id, con, passage_id, empty = "Click a source to read the passage here.") {
  moduleServer(id, function(input, output, session) {
    card = reactive({ p = passage_id(); if (is.null(p)) NULL else source_card(con, p) })
    output$head = renderText({ c = card(); if (is.null(c)) "Source" else paste(discard(c(c$title, c$pages), function(x) !nzchar(x %||% "")), collapse = ", ") })
    output$body = renderUI({
      c = card()
      if (is.null(c)) return(tags$p(class = "text-muted small", empty))
      tagList(if (nzchar(c$heading_path)) tags$p(tags$strong(c$heading_path)), tags$p(tags$em(c$description)),
              HTML(render_md(c$text)), tags$hr(),
              tags$p(class = "small", "Text file: ", tags$code(c$markdown), " ",
                     tags$a("Open the file", href = source_url(c$markdown, c$line_from), target = "_blank", rel = "noopener")))
    })
  })
}
