# ui.R: the app's pages. What the tabs share (boxes, the office logo, the source card), the session
#   key and call count, and the five tabs: Start here, Ask, Formulas, Report reader, Methodology. Function
#   definitions and constants only.

APP_TABS <- c("Start here", "Ask", "Formulas", "Report reader", "Methodology")

APP_CSS <- paste(
  ".survai-code { background: var(--bs-tertiary-bg); padding: 8px 10px; border-radius: 4px; font-size: 88%; overflow-x: auto; }",
  ".card-body pre { overflow-x: auto; max-width: 100%; }",
  ".tok-com { color: #6a737d; font-style: italic; } .tok-str { color: #22863a; } .tok-fn { color: #005cc5; }",
  ".tok-kw { color: #d73a49; font-weight: 600; } .survai-formula { margin: 0.6em 0; overflow-x: auto; }",
  ".survai-sources li { margin-bottom: 2px; } .survai-live { white-space: normal; opacity: 0.85; }",
  ".survai-flags { font-size: 90%; color: var(--bs-warning-text-emphasis, #8a6d3b); }",
  ".survai-uncited { text-decoration: underline dotted; text-decoration-color: var(--bs-secondary-color); text-underline-offset: 3px; }")

# The stream and the progress note are written straight into the page while a question runs.
APP_JS <- paste(
  "Shiny.addCustomMessageHandler('survai-html', function(m) {",
  "  var el = document.getElementById(m.id); if (el) el.innerHTML = m.html; });",
  "function survaiCopy(b) { var c = b.parentElement.querySelector('code'); if (!c) return;",
  "  navigator.clipboard.writeText(c.innerText).then(function() { b.textContent = 'Copied'; });",
  "  setTimeout(function() { b.textContent = 'Copy'; }, 1500); }")

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

# The page text is www/start_here.md, edited without touching code; read for each session. A line
#   holding only a marker below is replaced by that figure from www/, with its own <title> as alt text.
START_MD <- "www/start_here.md"
START_FIGURES <- c("[TSE figure]" = "fw_tse.svg", "[What it does figure]" = "what_it_does.svg")

read_md <- function(file) paste(readLines(file, warn = FALSE, encoding = "UTF-8"), collapse = "
")
md_page <- function(text) HTML(str_replace_all(render_md(text), "<table>", "<table class='table table-sm'>"))

svg_title <- function(file) {
  t = str_match(read_md(file.path("www", file)), "<title[^>]*>([^<]*)</title>")[, 2]
  if (is.na(t)) "" else t
}

figure_tag <- function(file)
  as.character(tags$img(src = file, alt = svg_title(file), style = "width: 100%; max-width: 900px; display: block; margin: 1em 0;"))

with_figures <- function(text, figures = START_FIGURES)
  reduce2(names(figures), unname(figures), function(txt, marker, file)
    str_replace_all(txt, paste0("(?m)^[ \\t]*", str_replace_all(marker, "([\\[\\]])", "\\\\\\1"), "[ \\t]*$"), figure_tag(file)),
    .init = text)

start_ui <- function(id) {
  ns = NS(id)
  tagList(
    uiOutput(ns("text")),
    tags$hr(),
    mod_key_ui(ns("key")),
    tags$p(textOutput(ns("calls"), inline = TRUE)))
}

start_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    mod_key_server("key", state)
    output$text = renderUI(md_page(with_figures(read_md(START_MD))))
    output$calls = renderText({
      state$calls
      paste0("Each question uses 2 model calls (a plan and an answer). ",
             sprintf("This session has used %d calls in the last %s hours.", calls_in_window(session$token), CALLS_WINDOW_HOURS),
             if (!is.na(CALLS_PER_WINDOW)) sprintf(" The limit of %d is per person, so your other sessions count too.", CALLS_PER_WINDOW))
    })
  })
}

# ---- Methodology ------------------------------------------------------------------------------------------------

# The page text is www/methodology.md; {{LIBRARY_TABLE}} in it becomes the counts table below.
METHODOLOGY_MD <- "www/methodology.md"

# The library's sources in plain words, in the order shown; a source not listed shows its own name.
SOURCE_LABELS <- c(jpsm = "Graduate coursework in survey methodology", practools = "Textbook on sample design and weighting",
                   tidysurvey = "Open books on survey analysis and sampling", sampling = "Open books on survey analysis and sampling",
                   training = "Training material")

store_counts <- function(con) dbGetQuery(con, paste(
  "SELECT d.source, count(DISTINCT d.id) AS Documents,",
  "(SELECT count(*) FROM passages p WHERE p.source = d.source) AS Passages,",
  "(SELECT count(*) FROM formulas f WHERE f.source = d.source) AS Formulas,",
  "(SELECT count(*) FROM code c WHERE c.source = d.source AND NOT c.is_output) AS \"Code examples\"",
  "FROM docs d GROUP BY d.source")) |>
  mutate(` ` = coalesce(unname(SOURCE_LABELS[source]), source)) |>
  group_by(` `) |> summarise(across(c(Documents, Passages, Formulas, `Code examples`), sum)) |>
  arrange(match(` `, unique(SOURCE_LABELS)))

# A data frame as a markdown table, numbers with thousands separators.
md_table_of <- function(d) {
  cells = map(d, function(x) if (is.numeric(x)) format(x, big.mark = ",", trim = TRUE) else as.character(x))
  rows = pmap_chr(cells, function(...) paste0("| ", paste(c(...), collapse = " | "), " |"))
  paste(c(paste0("| ", paste(names(d), collapse = " | "), " |"), paste0("|", strrep("---|", ncol(d))), rows), collapse = "
")
}

methodology_ui <- function(id) uiOutput(NS(id, "text"))

methodology_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    output$text = renderUI(md_page(str_replace(read_md(METHODOLOGY_MD), fixed("{{LIBRARY_TABLE}}"), md_table_of(store_counts(con)))))
  })
}

# ---- the source card ------------------------------------------------------------------------------------------

# Where a markdown file opens: APP_SOURCE_URL followed by its path under SurvAI_Expert/; NULL for a
#   source whose files are not in the repository (SOURCES_NOT_IN_REPO).
source_url <- function(markdown) {
  if (str_match(markdown, "^data/markdown/([^/]+)/")[, 2] %in% SOURCES_NOT_IN_REPO) return(NULL)
  paste0(APP_SOURCE_URL, paste(map_chr(str_split_1(markdown, "/"), function(s) utils::URLencode(s, reserved = TRUE)), collapse = "/"))
}

card_ui <- function(id)
  tags$div(style = "position: sticky; top: 8px;",
           bslib::card(full_screen = TRUE, max_height = "88vh", bslib::card_header(textOutput(NS(id, "head"), inline = TRUE)),
                       bslib::card_body(uiOutput(NS(id, "body")))))

# What a source card shows: c is a source_card() row.
card_head <- function(c) paste(discard(c(c$title, c$pages), function(x) !nzchar(x %||% "")), collapse = ", ")
card_content <- function(c)
  tagList(if (nzchar(c$heading_path)) tags$p(tags$strong(c$heading_path)), tags$p(tags$em(c$description)),
          HTML(render_md(c$text)), tags$hr(),
          tags$p(class = "small", "Text file: ", tags$code(c$markdown), " ",
                 if (is.null(source_url(c$markdown))) tags$em("Text file not in the repository")
                 else tags$a("Open the file", href = source_url(c$markdown), target = "_blank", rel = "noopener")))

# passage_id: a reactive holding the passage to show (or NULL).
card_server <- function(id, con, passage_id, empty = "Click a source to read the passage here.") {
  moduleServer(id, function(input, output, session) {
    card = reactive({ p = passage_id(); if (is.null(p)) NULL else source_card(con, p) })
    output$head = renderText({ c = card(); if (is.null(c)) "Source" else card_head(c) })
    output$body = renderUI({
      c = card()
      if (is.null(c)) tags$p(class = "text-muted small", empty) else card_content(c)
    })
  })
}

# A passage in a window over the page, with a button that fills the screen with it.
MAXIMIZE_JS <- paste("var d = this.closest('.modal-dialog'); d.classList.toggle('modal-fullscreen');",
                     "this.textContent = d.classList.contains('modal-fullscreen') ? 'Restore' : 'Maximize';")
source_modal <- function(c, number = NULL)
  modalDialog(card_content(c), title = paste0(if (!is.null(number)) paste0(number, ". "), card_head(c)),
              size = "l", easyClose = TRUE,
              footer = tagList(tags$button(type = "button", class = "btn btn-outline-secondary", onclick = MAXIMIZE_JS, "Maximize"),
                               modalButton("Close")))


# ==== the session key and call count ====
# The key and the call count of each Shiny session. The key is pasted on Start here and held here
#   for the session only: never on disk, in a log, or in the environment. Calls are counted over the
#   last CALLS_WINDOW_HOURS (app.R).

.sessions <- new.env(parent = emptyenv())
.sessions$keys <- list()
.sessions$calls <- list()

session_token <- function(session = shiny::getDefaultReactiveDomain()) if (is.null(session)) "console" else session$token

session_key <- function(token = session_token()) {
  k = .sessions$keys[[token]]
  if (is.null(k) || !nzchar(k)) NULL else k
}
set_session_key <- function(key, token = session_token()) .sessions$keys[[token]] <- key
forget_session <- function(token) { .sessions$keys[[token]] <- NULL; .sessions$calls[[token]] <- NULL }

# Calls are recorded with their time; the count shown is for the whole session.
add_calls <- function(n, token = session_token()) .sessions$calls[[token]] <- c(.sessions$calls[[token]], rep(Sys.time(), n))
calls_made <- function(token = session_token()) length(.sessions$calls[[token]])
calls_in_window <- function(token = session_token())
  sum(.sessions$calls[[token]] > Sys.time() - CALLS_WINDOW_HOURS * 3600)

# NULL when n more calls are allowed, else the message to show.
call_limit_note <- function(n, token = session_token(), limit = CALLS_PER_WINDOW) {
  if (is.na(limit) || calls_in_window(token) + n <= limit) return(NULL)
  sprintf("This session has used %d calls in the last %s hours, and the limit is %d per person. Wait a while and try again.",
          calls_in_window(token), CALLS_WINDOW_HOURS, limit)
}

KEY_INSTRUCTIONS <- c(
  "Ask the person who manages the AI service for your office for a key.",
  "Use a key issued to you, not one shared by a team, so that use can be traced to the person who made it.",
  "If a request is refused for quota or cost, stop and ask the person who issued the key.")

mod_key_ui <- function(id) {
  ns = NS(id)
  tagList(
    tags$h4("Your API key"), uiOutput(ns("status")),
    passwordInput(ns("key"), NULL, width = "100%", placeholder = "Paste your key here"),
    actionButton(ns("save"), "Use this key", class = "btn-primary"), actionButton(ns("clear"), "Forget it"),
    advice_box(tags$p(tags$strong("Where to get one")), map(KEY_INSTRUCTIONS, tags$p),
               tags$p(tags$em("The key is kept for this session only. It is not saved anywhere, and closing the tab discards it."))))
}

mod_key_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    token = session$token
    changed = function(note) {
      updateTextInput(session, "key", value = "")
      state$key_version = state$key_version + 1L
      showNotification(note, type = "message")
    }
    observeEvent(input$save, {
      k = trimws(input$key %||% "")
      if (!nzchar(k)) return(showNotification("Nothing pasted.", type = "warning"))
      set_session_key(k, token)
      changed("Key accepted for this session.")
    })
    observeEvent(input$clear, { .sessions$keys[[token]] <- NULL; changed("Key forgotten.") })
    session$onSessionEnded(function() forget_session(token))
    output$status = renderUI({
      state$key_version
      if (!is.null(session_key(token))) tags$p(class = "text-success", "A key you supplied is in use for this session.")
      else warn_box("No key has been pasted. Questions and the report reader need one; the Formulas page does not.")
    })
  })
}


# ==== Ask ====
# A question runs as an ExtendedTask (plan, search, answer); the answer streams into the page and
#   is replaced, when complete, by the rendered answer with formulas from the library and its cited
#   sources renumbered 1, 2, 3 in the order the answer cites them.

STREAM_EVERY_S <- 0.3   # how often the streaming answer is redrawn

MY_DATA_HELP <- paste(
  "Optional. Tell the tool what the columns in your data file are called, and its example code will use your names,",
  "so you can copy it with fewer changes. Fill in only what you have. Nothing here is uploaded: these are only names.",
  "Weight: the column that says how many people each row stands for. Strata: the groups the sample was drawn within.",
  "Cluster: the unit that was sampled first, such as a school or an area. Population size: only if you know how many",
  "units exist in each group. Outcome: the column you want to estimate.")

ask_ui <- function(id) {
  ns = NS(id)
  field = function(name, label, eg) textInput(ns(name), label, placeholder = eg)
  my_data = bslib::accordion(open = FALSE, bslib::accordion_panel(
    "My data (optional)",
    tags$p(class = "small text-muted", MY_DATA_HELP),
    bslib::layout_columns(col_widths = c(4, 4, 4),
      field("weight", "Weight", "e.g. finalwt"), field("strata", "Strata", "e.g. stratum"), field("cluster", "Cluster", "e.g. school_id"),
      field("fpc", "Population size", "e.g. n_schools"), field("outcomes", "Outcome", "e.g. smokes"),
      field("replicates", "Replicate weights", "e.g. repwt1 to repwt80")),
    textInput(ns("design"), "About the design", width = "100%",
              placeholder = "e.g. two-stage sample of schools then students, 40 strata")))
  tags$div(style = "max-width: 900px;",
    textAreaInput(ns("question"), "Your question", width = "100%", rows = 3),
    my_data,
    tags$div(style = "margin: 8px 0;", bslib::input_task_button(ns("ask"), "Ask", label_busy = "Working..."),
             actionButton(ns("new_topic"), "New topic"), textOutput(ns("topic"), inline = TRUE)),
    tags$div(id = ns("progress"), class = "text-muted small"),
    tags$div(id = ns("live"), class = "survai-live"),
    uiOutput(ns("answer")))
}

# Plain notes for whatever check_answer() flagged. Sentences with no citation are shown by the
#   dotted underline, not counted here.
flag_notes <- function(ck) {
  n = function(k, one, many) if (k == 1) one else sprintf(many, k)
  c(if (length(ck$bad_cites)) "The answer points to a source that was not among those found.",
    if (length(ck$bad_tokens)) "The answer refers to a formula that was not among those found.",
    if (ck$display_math) "The answer typed a formula itself instead of using one from the library; check it against the sources.",
    if (!ck$code_parses) "The R code does not run as written.",
    if (length(ck$unverified)) paste0(n(length(ck$unverified), "1 function in the code is", "%d functions in the code are"),
                                       " not in the library's examples or in R itself: ", paste(ck$unverified, collapse = ", ")))
}

# The cited sources, one line each: number, description, document. Collapsed until opened.
source_lines <- function(cited, open_input)
  tags$details(class = "small", style = "margin-top: 1em;",
    tags$summary(sprintf("Sources (%d)", nrow(cited))),
    tags$ol(class = "survai-sources", style = "list-style: none; padding-left: 0; margin-top: 0.5em;",
      pmap(list(cited$label, cited$description, cited$title, cited$pages), function(l, d, ti, pg) {
        doc = paste(discard(c(ti, pg), function(x) !nzchar(x %||% "")), collapse = ", ")
        tags$li(HTML(open_link(open_input, l, paste0("<strong>", str_remove(l, "^S"), ".</strong> ", htmltools::htmlEscape(d)))),
                tags$span(class = "text-muted", paste0(" (", doc, ")")))
      })))

ask_server <- function(id, state, con, asker = ask_async) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    context = reactiveVal(NULL)
    result = reactiveVal(NULL)
    shown = reactiveVal(NULL)
    send = function(el, html) session$sendCustomMessage("survai-html", list(id = ns(el), html = as.character(html)))
    task = ExtendedTask$new(function(question, key, ctx, my_data) {
      last = new.env()
      last$t = Sys.time() - 10
      asker(question, MODEL_PROFILE, key, con, ctx, my_data, open_input = ns("open"),
            on_stage = function(s) send("progress", c(plan = "Planning the search...", search = "Searching the library...",
                                                      answer = "Writing the answer...")[[s]]),
            on_text = function(txt) if (as.numeric(difftime(Sys.time(), last$t, units = "secs")) > STREAM_EVERY_S) {
              last$t = Sys.time()
              send("live", render_md(txt, math = FALSE))
            })
    }) |> bslib::bind_task_button("ask")

    observe(state$my_data <- map(set_names(names(DATA_FIELDS)), function(f) input[[f]] %||% ""))

    observeEvent(input$ask, {
      q = str_squish(input$question %||% "")
      key = session_key(session$token)
      if (!nzchar(q)) return(showNotification("Type a question first.", type = "warning"))
      if (is.null(key)) return(showNotification("Paste your API key on Start here first.", type = "warning"))
      note = call_limit_note(2L, session$token)
      if (!is.null(note)) return(showNotification(note, type = "error", duration = NULL))
      add_calls(2L, session$token)
      state$calls = state$calls + 1L
      result(NULL)
      send("live", "")
      task$invoke(q, key, context(), map(set_names(names(DATA_FIELDS)), function(f) input[[f]] %||% ""))
    })

    observeEvent(task$status(), {
      if (task$status() == "success") {
        r = task$result()
        result(r)
        context(list(question = r$question, answer = r$answer))
        send("live", "")
        send("progress", sprintf("Planned in %.0f s, searched in %.1f s, answered in %.0f s.", r$sec[["plan"]], r$sec[["search"]], r$sec[["answer"]]))
      } else if (task$status() == "error") {
        send("live", "")
        send("progress", "")
        result(list(error = conditionMessage(tryCatch(task$result(), error = function(e) e))))
      }
    })

    observeEvent(input$new_topic, { context(NULL); result(NULL); shown(NULL); send("progress", ""); updateTextAreaInput(session, "question", value = "") })
    output$topic = renderText(if (is.null(context())) "" else "Follow-up: the last question and answer are kept.")

    output$answer = renderUI({
      r = result()
      if (is.null(r)) return(NULL)
      if (!is.null(r$error)) return(warn_box(tags$strong("The question could not be answered. "), r$error))
      notes = flag_notes(r$checks)
      tagList(HTML(r$html), if (length(notes)) tags$div(class = "survai-flags", map(notes, tags$div)),
              if (SHOW_SOURCES && nrow(r$cited)) source_lines(r$cited, ns("open")))
    })

    # a source in the list, or a citation in the answer, opens its passage in a window
    observeEvent(input$open, {
      s = result()$cited
      if (is.null(s) || !input$open %in% s$label) return()
      c = source_card(con, s$passage_id[s$label == input$open][1])
      shown(input$open)
      if (!is.null(c)) showModal(source_modal(c, str_remove(input$open, "^S")))
    })
  })
}


# ==== Formulas ====
# Searches the stored formulas; no model calls, except "Show me how in R" (2 calls, the key needed).

FORMULA_RESULTS <- 40L
FORMULA_EXAMPLES <- 3L

formulas_ui <- function(id) {
  ns = NS(id)
  v = read_vocab()
  pick = function(name, label, choices) selectizeInput(ns(name), label, choices = choices, multiple = TRUE, width = "100%")
  search = tagList(
    textInput(ns("query"), "Search formulas", width = "100%", placeholder = "e.g. variance of the ratio estimator"),
    if (SHOW_SOURCES) bslib::layout_columns(col_widths = c(3, 3, 3, 3),
      pick("role", "Role", v$value[v$facet == "role"]), pick("design", "Design", v$value[v$facet == "design"]),
      pick("topic", "Topic", v$value[v$facet == "topic"]), pick("course", "Course", character()))   # courses: from the server
    else bslib::layout_columns(col_widths = c(4, 4, 4),
      pick("role", "Role", v$value[v$facet == "role"]), pick("design", "Design", v$value[v$facet == "design"]),
      pick("topic", "Topic", v$value[v$facet == "topic"])),
    checkboxInput(ns("general"), "General formulas only", value = TRUE),
    uiOutput(ns("results")), uiOutput(ns("detail")),
    tags$div(id = ns("how_progress"), class = "text-muted small"), uiOutput(ns("how")))
  if (SHOW_SOURCES) bslib::layout_columns(col_widths = c(7, 5), search, card_ui(ns("card")))
  else tags$div(style = "max-width: 900px;", search)
}

symbol_table <- function(symbols) {
  s = str_trim(unlist(str_split(symbols %||% "", ";")))
  s = s[nzchar(s)]
  if (!length(s)) return(tags$p(class = "text-muted small", "No symbols are defined in the text around it."))
  tags$table(class = "table table-sm small", tags$tbody(map(s, function(x) tags$tr(
    tags$td(HTML(kx(str_trim(str_extract(x, "^[^=]+")), FALSE) %|NA% htmltools::htmlEscape(str_extract(x, "^[^=]+")))),
    tags$td(str_trim(str_remove(x, "^[^=]+=\\s*")))))))
}

`%|NA%` <- function(a, b) if (is.na(a)) b else a

# R code, highlighted, with a button that copies it.
code_box <- function(code)
  tags$div(style = "position: relative;",
           tags$button(type = "button", class = "btn btn-sm btn-outline-secondary", style = "position: absolute; top: 4px; right: 4px;",
                       onclick = "survaiCopy(this)", "Copy"),
           HTML(highlight_r(code)))

examples_box <- function(ex)
  tagList(tags$h6("R examples from the library", style = "margin-top: 1em;"),
          if (!nrow(ex)) tags$p(class = "text-muted small", "No example in the library for this formula.")
          else map2(ex$task, ex$code, function(t, cd) tagList(if (nzchar(t %||% "")) tags$p(class = "small", tags$em(t)), code_box(cd))))

formula_question <- function(name) sprintf("How do I compute %s in R?", name)

formulas_server <- function(id, state, con, asker = ask_async) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    send = function(el, html) session$sendCustomMessage("survai-html", list(id = ns(el), html = as.character(html)))
    if (SHOW_SOURCES) updateSelectizeInput(session, "course", choices = dbGetQuery(con, "SELECT DISTINCT course FROM docs WHERE course <> '' ORDER BY course")$course)
    found = reactive(find_formulas(con, input$query %||% "", role = input$role, design = input$design,
                                   general = if (isTRUE(input$general)) TRUE else NULL, k = FORMULA_RESULTS,
                                   topic = input$topic, course = if (SHOW_SOURCES) input$course)) |> debounce(400)
    picked = reactiveVal(NULL)
    shown = reactiveVal(NULL)
    how = reactiveVal(NULL)
    output$results = renderUI({
      f = found()
      if (!nrow(f)) return(tags$p(class = "text-muted", "No formula matches."))
      tags$div(style = "max-height: 320px; overflow-y: auto;", tags$ol(class = "small", map(seq_len(nrow(f)), function(i)
        tags$li(HTML(open_link(ns("pick"), f$group_id[i], htmltools::htmlEscape(f$name[i]))),
                if (SHOW_SOURCES) tags$span(class = "text-muted", paste0(" (", f$course[i], ", ", f$title[i], ")"))))))
    })
    observeEvent(input$pick, { picked(input$pick); how(NULL); send("how_progress", "") })
    row = reactive({
      g = picked()
      f = found()
      if (is.null(g) || !g %in% f$group_id) NULL else f[f$group_id == g, ][1, ]
    })
    output$detail = renderUI({
      r = row()
      if (is.null(r)) return(NULL)
      ids = unlist(r$place_ids)
      places = str_split_1(r$places, "; ")
      tagList(tags$hr(), tags$h5(r$name),
              tags$div(class = "survai-formula", HTML(kx(r$latex, TRUE) %|NA% htmltools::htmlEscape(r$latex))),
              tags$p(class = "small", tags$strong("Role: "), r$role, "; ", tags$strong("design: "), r$design),
              symbol_table(r$symbols),
              if (nzchar(r$condition %||% "")) tags$p(class = "small", tags$strong("Condition: "), r$condition),
              if (SHOW_SOURCES) tagList(
                tags$p(class = "small", tags$strong(sprintf("Where it occurs (%d):", length(ids)))),
                tags$ul(class = "small", map2(ids, places, function(p, lab) tags$li(HTML(open_link(ns("open"), p, htmltools::htmlEscape(lab))))))),
              examples_box(formula_examples(con, r$place_ids, r$name, FORMULA_EXAMPLES)),
              tags$div(style = "margin-top: 0.8em;",
                       bslib::input_task_button(ns("how_btn"), "Show me how in R", label_busy = "Working..."),
                       tags$span(class = "small text-muted", " Uses 2 model calls and needs your key (Start here).")))
    })

    # "Show me how in R": ask() with this formula given first, and My data from the Ask tab
    task = ExtendedTask$new(function(question, key, my_data, pin) {
      asker(question, MODEL_PROFILE, key, con, NULL, my_data, open_input = ns("how_open"), pin = pin,
                on_stage = function(s) send("how_progress", c(plan = "Planning the search...", search = "Searching the library...",
                                                            answer = "Writing the answer...")[[s]]))
    }) |> bslib::bind_task_button("how_btn")
    observeEvent(input$how_btn, {
      r = row()
      key = session_key(session$token)
      if (is.null(r)) return()
      if (is.null(key)) return(showNotification("Paste your API key on Start here first.", type = "warning"))
      note = call_limit_note(2L, session$token)
      if (!is.null(note)) return(showNotification(note, type = "error", duration = NULL))
      add_calls(2L, session$token)
      state$calls = state$calls + 1L
      how(NULL)
      task$invoke(formula_question(r$name), key, state$my_data, r)
    })
    observeEvent(task$status(), {
      if (task$status() == "success") { how(task$result()); send("how_progress", "") }
      else if (task$status() == "error") {
        send("how_progress", "")
        how(list(error = conditionMessage(tryCatch(task$result(), error = function(e) e))))
      }
    })
    output$how = renderUI({
      r = how()
      if (is.null(r)) return(NULL)
      if (!is.null(r$error)) return(warn_box(tags$strong("The question could not be answered. "), r$error))
      notes = flag_notes(r$checks)
      tagList(tags$hr(), tags$h6(r$question), HTML(r$html), if (length(notes)) tags$div(class = "survai-flags", map(notes, tags$div)),
              if (SHOW_SOURCES && nrow(r$cited)) source_lines(r$cited, ns("how_open")))
    })
    observeEvent(input$how_open, {
      s = how()$cited
      if (is.null(s) || !input$how_open %in% s$label) return()
      c = source_card(con, s$passage_id[s$label == input$how_open][1])
      if (!is.null(c)) showModal(source_modal(c, str_remove(input$how_open, "^S")))
    })

    observeEvent(input$open, shown(input$open))
    if (SHOW_SOURCES) card_server("card", con, shown, empty = "Pick a formula, then a place where it occurs, to read the passage here.")
  })
}


# ==== Report reader ====

report_ui <- function(id) {
  ns = NS(id)
  tagList(
    tags$p("Upload a survey's technical or methodology report (PDF or Word). It is read by the model, not searched in the store, ",
           "and summarized in a fixed checklist: the design, the weights, variance estimation, and a design call for R, with page numbers."),
    fileInput(ns("file"), NULL, accept = c(".pdf", ".docx"), buttonLabel = "Choose a report", width = "100%"),
    uiOutput(ns("about")),
    bslib::input_task_button(ns("read"), "Read the report", label_busy = "Reading..."),
    tags$div(style = "margin-top: 1em;", uiOutput(ns("summary"))))
}

report_server <- function(id, state, reader = read_report_async) {
  moduleServer(id, function(input, output, session) {
    rep = reactive({ req(input$file); report_text(input$file$datapath, input$file$name) })
    output$about = renderUI({
      r = rep()
      if (!is.null(r$note)) return(warn_box(r$note))
      chars = sum(nchar(r$pages))
      calls = report_calls(report_parts(r$pages))
      tags$p(sprintf("%s: %s, %s characters. Reading it will use %d model call%s%s.", input$file$name,
                     if (r$paged) paste(length(r$pages), "pages") else "a Word file (no page numbers)",
                     format(chars, big.mark = ","), calls, if (calls == 1) "" else "s",
                     if (calls > 1) sprintf(" (it is split into %d parts, then combined)", calls - 1L) else ""))
    })
    task = ExtendedTask$new(function(r, key) reader(r, MODEL_PROFILE, key)) |> bslib::bind_task_button("read")
    observeEvent(input$read, {
      r = rep()
      key = session_key(session$token)
      if (!is.null(r$note)) return(showNotification(r$note, type = "warning"))
      if (is.null(key)) return(showNotification("Paste your API key on Start here first.", type = "warning"))
      n = report_calls(report_parts(r$pages))
      note = call_limit_note(n, session$token)
      if (!is.null(note)) return(showNotification(note, type = "error", duration = NULL))
      add_calls(n, session$token)
      state$calls = state$calls + 1L
      task$invoke(r, key)
    })
    output$summary = renderUI({
      if (task$status() == "error") return(warn_box(tags$strong("The report could not be read. "),
                                                    conditionMessage(tryCatch(task$result(), error = function(e) e))))
      if (task$status() != "success") return(NULL)
      x = task$result()
      tagList(HTML(render_md(x$text)), tags$p(class = "small text-muted", sprintf("%d model call%s.", x$calls, if (x$calls == 1) "" else "s")))
    })
  })
}
