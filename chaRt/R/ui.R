# ui.R for chaRt
# What the analyst sees: the shared helpers, the office logo, the four pages (Start here, Data,
#   Explore, Methodology), the connection check, the Data page (the file, then its data dictionary) and
#   the Explore screen (a chat on the left, the canvas of charts on the right). advice_box, warn_box,
#   office_logo, model_label, mod_connect_ui and mod_connect_server are copied from QuestionR/R/ui.R
#   unchanged. Function definitions and constants only.


# ---- the pages ---------------------------------------------------------------

CHART_TABS <- c("Start here", "Data", "Explore", "Methodology")

# What a page that a later phase builds says until then.
LATER_PHASE <- "Built in a later phase."

# The whole page: the classification banner above a navbar page. The logo, title, Source code link and
#   dark-mode switch are in the bar. bslib::page_navbar() has no place above its bar, so the banner is
#   the first thing in the page, before the bar; only Explore fills the window, the others scroll.
app_ui <- function(classification, logo, office, source_url)
  tagList(
    tags$div(class = "chart-classification",
             style = paste("background:#b40404; color:#fff; text-align:center;",
                           "font-weight:700; letter-spacing:0.06em;",
                           "padding:5px 0; font-size:13px;"),
             classification),
    bslib::page_navbar(
      title = tags$span(class = "d-inline-flex align-items-center gap-3",
                        office_logo(logo, office),
                        tags$span(class = "d-inline-flex flex-column lh-sm",
                                  tags$span(class = "fs-4 fw-semibold", "chaRt"),
                                  tags$span(class = "small fw-normal d-none d-xl-inline",
                                            "Publishable charts from a data file, drawn to written visualization rules."))),
      id = "stage", window_title = "chaRt", fillable = CHART_TABS[3],
      theme = bslib::bs_theme(version = 5, preset = "flatly"),
      bslib::nav_panel(CHART_TABS[1], tags$div(class = "container py-3", start_ui())),
      bslib::nav_panel(CHART_TABS[2], tags$div(class = "container py-3", data_page_ui())),
      bslib::nav_panel(CHART_TABS[3], mod_explore_ui("explore")),
      bslib::nav_panel(CHART_TABS[4], tags$div(class = "container py-3", later_ui())),
      bslib::nav_spacer(),
      bslib::nav_item(tags$a("Source code", href = source_url, target = "_blank", rel = "noopener",
                             class = "btn btn-outline-secondary btn-sm")),
      bslib::nav_item(bslib::input_dark_mode(id = "dark_mode"))))


# ---- shared helpers (from QuestionR) -----------------------------------------

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


# A button for a model call. Shiny runs the call before it draws again, so the button disables
#   itself in the browser and shows `busy` under it; the server draws it again, enabled, when the
#   call is done. ready = FALSE draws it disabled.
busy_button <- function(id, label, busy, ready = TRUE, class = "btn-primary") {
  busy_id = paste0(id, "_busy")
  tagList(actionButton(id, label, class = class, disabled = !ready,
                       onclick = paste0("this.disabled = true; document.getElementById('", busy_id, "').style.display = 'block';")),
          tags$p(id = busy_id, class = "text-muted small", style = "display:none; margin-top:0.25rem;", busy))
}

# What went wrong in a call, under the sentence: the reply as llm_json() reported it.
call_detail <- function(detail)
  if (!is.null(detail)) tags$details(tags$summary("What the model sent back"), tags$pre(substr(detail, 1, 1500)))


# ---- Start here --------------------------------------------------------------

# The model as the page names it: the id, the API style in words and where it is called.
#   Never the key.
model_label <- function(m)
  tagList(tags$code(m$id), tags$br(),
          tags$span(class = "text-muted small",
                    paste0(switch(m$api %||% "", anthropic = "Anthropic API", openai = "OpenAI-style API",
                                  paste0("API '", m$api, "'")),
                           " at ", m$base_url, "; key pasted below")))

# Start here: what the tool does, the key box, then the connection check.
start_ui <- function()
  tagList(
    tags$p("chaRt builds a data dictionary for a data file you bring, proposes and draws publishable charts ",
           "that follow written visualization rules, and lets you change a chart by chat. Charts collect ",
           "on a canvas, each with a headline and a short summary of what it shows. Every chart and ",
           "summary describes the file, not a population. Start on the Data page, then go to Explore."),
    mod_key_ui("key"),
    mod_connect_ui("connect"))

# A tab that a later phase builds.
later_ui <- function() tags$p(class = "text-muted", LATER_PHASE)


# ---- the connection check (from QuestionR) -----------------------------------

# The model, and whether it has a key; and a button that makes one very small call to it. Never
#   shows a key. With no key it is not called: it says what is missing. ping is the function that
#   calls the model, so a test can stand in for the network.
mod_connect_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$hr(),
    tags$h4("Settings and connection"),
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


# ---- Data -----------------------------------------------------------------------------------

# The Data page: the file, what R found in it, and its data dictionary, one under the other.
data_page_ui <- function()
  tagList(tags$h4("Data file"),
          mod_data_ui("data"),
          tags$hr(),
          tags$h4("Data dictionary"),
          tags$p(class = "text-muted small",
                 "The data dictionary says what one row represents and gives each column a label, a type and a role. ",
                 "Charts are drawn only after it says what one row represents."),
          mod_codebook_ui("codebook"))

# The data file: a delimited file, what R found in it, and an optional saved data dictionary.
mod_data_ui <- function(id) {
  ns = NS(id)
  tagList(
    fileInput(ns("file"), paste0("Data file: CSV or other delimited text, up to ", APP_MAX_UPLOAD_MB, " MB"),
              accept = c(".csv", ".tsv", ".txt", ".tab"), width = "100%"),
    textAreaInput(ns("missing"), "Values that mean missing, one per line", rows = 2, width = "100%",
                  placeholder = "for example: ..\n-99"),
    tags$p(class = "text-muted small", "Blank cells and NA are always missing. Anything else is missing only if you list it here; ",
           "a value must match a whole cell."),
    selectInput(ns("encoding"), "File encoding", choices = encoding_choices(NULL), width = "100%"),
    tags$p(class = "text-muted small", "The encoding is guessed. If names with accents look wrong, choose another and read again: ",
           "windows-1252 for Western European files, ISO-8859-2 for Central European ones."),
    actionButton(ns("reread"), "Read again", class = "btn-sm mb-3"),
    uiOutput(ns("reread_note")),
    uiOutput(ns("summary")),
    tableOutput(ns("columns")),
    tags$hr(),
    fileInput(ns("codebook"), "Optional: a saved data_dictionary.yaml for this file", accept = c(".yaml", ".yml"), width = "100%"),
    uiOutput(ns("codebook_note")))
}

# The File encoding choices: the guess first (its value is "", its label names what the guess
#   was), then DATA_ENCODINGS.
encoding_choices <- function(detected) {
  guess = if (is.null(detected)) "Detected" else paste0("Detected (", detected, ")")
  c(stats::setNames("", guess), stats::setNames(DATA_ENCODINGS, DATA_ENCODINGS))
}

mod_data_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    read_error = reactiveVal(NULL)
    codebook_note = reactiveVal(NULL)
    reread_note = reactiveVal(NULL)
    upload = reactiveVal(NULL)         # the data file as uploaded, kept so it can be read again
    detected = reactiveVal(NULL)       # the encoding the guess picked for that file

    # The encoding chosen on the tab: NULL for the guess.
    chosen_encoding = function() if (nzchar(input$encoding %||% "")) input$encoding
    # After a read: the guess's label names what it picked, and the select shows `selected`.
    show_encoding = function(res, selected) {
      if (is.null(selected) && !inherits(res, "error")) detected(res$read$encoding)
      updateSelectInput(session, "encoding", choices = encoding_choices(detected()), selected = selected %||% "")
    }

    # A read, or the error it met, into the shared state.
    take = function(res, codebook = res$codebook) {
      if (inherits(res, "error")) {
        read_error(conditionMessage(res))
        state$data = NULL; state$problems = NULL; state$profile = NULL; state$codebook = NULL; state$path = NULL
        return(invisible(FALSE))
      }
      read_error(NULL)
      state$path = isolate(upload())$path
      state$data = res$read$data
      state$problems = res$read$problems
      state$profile = res$profile
      state$codebook = codebook
      invisible(TRUE)
    }

    observeEvent(input$file, {
      f = input$file
      upload(list(path = f$datapath, name = f$name))
      codebook_note(NULL); reread_note(NULL); detected(NULL)
      res = tryCatch(reread_data(f$datapath, f$name, parse_missing(input$missing)), error = function(e) e)
      take(res)
      show_encoding(res, NULL)
    })

    # The same upload read again with the values that mean missing; what the analyst entered in
    #   the codebook is kept for every column whose name is unchanged.
    observeEvent(input$reread, {
      u = upload()
      if (is.null(u)) return(reread_note(warn_box("Choose a data file first.")))
      enc = chosen_encoding()
      res = tryCatch(reread_data(u$path, u$name, parse_missing(input$missing), old = state$codebook, encoding = enc),
                     error = function(e) e)
      ok = take(res)
      show_encoding(res, enc)
      if (ok)
        reread_note(if (length(res$notes)) warn_box(tags$ul(purrr::map(res$notes, tags$li)))
                    else advice_box("Read again. Your labels, roles and row sentence are kept."))
    })

    output$reread_note = renderUI(reread_note())

    # Values that mean missing added elsewhere (the chat's "Treat ... as missing" reads the file again)
    #   are shown in the box, so that Read again here keeps them.
    observeEvent(missing_codes(state$codebook), {
      codes = missing_codes(state$codebook)
      if (!identical(codes, parse_missing(input$missing)))
        updateTextAreaInput(session, "missing", value = paste(codes, collapse = "\n"))
    })

    # A saved codebook: the file is first read again with its missing_codes and its encoding, then
    #   the codebook is applied only when check_codebook() has nothing to say about it.
    observeEvent(input$codebook, {
      u = upload()
      if (is.null(u)) return(codebook_note(warn_box("Read the data file first, then the data dictionary.")))
      up = tryCatch(read_codebook(input$codebook$datapath), error = function(e) e)
      if (inherits(up, "error")) return(codebook_note(warn_box(conditionMessage(up))))
      codes = missing_codes(up)
      res = tryCatch(reread_data(u$path, u$name, codes, encoding = up$encoding), error = function(e) e)
      if (inherits(res, "error")) return(codebook_note(warn_box(conditionMessage(res))))
      why = check_codebook(up, res$profile)
      if (length(why))
        return(codebook_note(warn_box(tags$strong("The data dictionary was not applied."), tags$ul(purrr::map(why, tags$li)))))
      take(res, apply_codebook(up, res$profile, u$name, nrow(res$read$data), res$read$encoding))
      updateTextAreaInput(session, "missing", value = paste(codes, collapse = "\n"))
      show_encoding(res, up$encoding)
      reread_note(NULL)
      codebook_note(advice_box("The data dictionary was applied: its values that mean missing, encoding, labels, types, roles and row ",
                               "sentence are in use; every fact comes from the file."))
    })

    output$codebook_note = renderUI(codebook_note())

    output$summary = renderUI({
      if (!is.null(read_error())) return(warn_box(read_error()))
      if (is.null(state$data)) return(NULL)
      tagList(
        tags$p(tags$strong(state$codebook$file),
               paste0(": ", format_num(nrow(state$data)), " rows, ", format_num(ncol(state$data)), " columns.")),
        if (length(state$problems)) warn_box(tags$ul(purrr::map(state$problems, tags$li)))
        else tags$p(class = "text-success", "No problems found."))
    })

    output$columns = renderTable({
      prof = state$profile
      if (is.null(prof) || !is.null(read_error())) return(NULL)
      data.frame(Column = purrr::map_chr(prof, "name"), Type = purrr::map_chr(prof, "type"),
                 Missing = sprintf("%.2f", purrr::map_dbl(prof, "missing")),
                 Distinct = format_num(purrr::map_int(prof, function(p) as.integer(p$distinct))))
    }, striped = TRUE, spacing = "xs")
  })
}


# ---- Codebook -------------------------------------------------------------------------------

CODEBOOK_PAGE_SIZE <- 25L
LABEL_BUSY <- "The model is reading the column summaries, not the rows. This can take a minute."

# The data dictionary: what one row represents, then the columns, CODEBOOK_PAGE_SIZE to a page.
mod_codebook_ui <- function(id) {
  ns = NS(id)
  tagList(uiOutput(ns("status")), uiOutput(ns("suggest")), uiOutput(ns("page")), uiOutput(ns("footer")))
}

# The page is drawn from the codebook only when the page, a type or the whole codebook changes,
#   so typing in a box is never interrupted by a redraw. Input ids carry a generation number, so a
#   box left over from an earlier codebook or page is never read into this one.
mod_codebook_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    page = reactiveVal(1L)
    gen = reactiveVal(0L)
    mine = reactiveVal(NULL)           # the codebook as this module last wrote it
    order_notes = reactiveVal(character(0))
    calls_done = reactiveVal(0L)       # bumped after a label call, so its button is drawn again
    label_note = reactiveVal(NULL)
    guess = reactiveVal(NULL)          # the model's row_is_guess, offered while row_is is blank
    input_id = function(what, i) paste0("g", gen(), "_", what, "_", i)
    # A codebook this module wrote, drawn again on the same page.
    write_here = function(new) { mine(new); state$codebook = new; gen(isolate(gen()) + 1L) }
    on_page = function(cb) {
      n = length(cb$columns)
      if (!n) return(integer(0))
      seq.int((page() - 1L) * CODEBOOK_PAGE_SIZE + 1L, min(n, page() * CODEBOOK_PAGE_SIZE))
    }

    # A codebook this module did not write (a new file, an applied codebook): start again on page 1.
    observeEvent(state$codebook, {
      if (!identical(state$codebook, mine())) {
        mine(state$codebook); page(1L); order_notes(character(0)); guess(NULL); label_note(NULL); gen(gen() + 1L)
      }
    }, ignoreNULL = FALSE)

    observeEvent(input$prev, { page(max(1L, page() - 1L)); gen(gen() + 1L) })
    observeEvent(input$`next`, {
      last = max(1L, ceiling(length(state$codebook$columns) / CODEBOOK_PAGE_SIZE))
      page(min(last, page() + 1L)); gen(gen() + 1L)
    })

    output$status = renderUI({
      cb = state$codebook
      if (is.null(cb)) return(tags$p(class = "text-muted", "Read a data file above first."))
      unnamed = sum(purrr::map_lgl(cb$columns, function(e) identical(e$label, e$name)))
      guessed = sum(purrr::map_lgl(cb$columns, function(e) identical(e$label_source, "ai_guess")))
      tagList(
        if (!codebook_ready(cb)) warn_box("Charts cannot be drawn until you say what one row represents."),
        tags$p(paste0(format_num(unnamed), " of ", format_num(length(cb$columns)), " labels are still the column name; ",
                      format_num(guessed), if (guessed == 1L) " AI guess is" else " AI guesses are", " not yet accepted.")),
        if (length(order_notes())) warn_box(tags$ul(purrr::map(order_notes(), tags$li))))
    })

    # Suggest labels: one label call per CODEBOOK_MAX_DETAIL columns. Only labels still the file's
    #   own change; the page is drawn again where it was.
    output$suggest = renderUI({
      state$key_version; calls_done()
      if (is.null(state$codebook)) return(NULL)
      ready = llm_key_ready()
      tags$div(class = "my-2",
               busy_button(ns("suggest_labels"), "Suggest labels", LABEL_BUSY, ready = ready),
               if (!ready) tags$p(class = "text-muted small", "Suggest labels needs a key. ", KEY_HINT),
               label_note())
    })

    observeEvent(input$suggest_labels, {
      cb = state$codebook
      if (is.null(cb)) return()
      res = label_columns(cb)
      state$calls = dplyr::bind_rows(state$calls, res$calls)
      if (!is.null(res$error)) {
        label_note(warn_box(res$error, call_detail(res$detail)))
      } else {
        landed = sum(purrr::map2_lgl(cb$columns, res$codebook$columns, function(a, b) !identical(a$label, b$label)))
        unsure = sum(purrr::map_lgl(res$codebook$columns, function(e) identical(e$label_source, "ai_guess") && identical(e$sure, FALSE)))
        label_note(advice_box(paste0(format_num(landed), " labels were suggested",
                                     if (unsure) paste0(", ", unsure, " of them marked 'check this'"),
                                     ". Labels you wrote were not changed. Edit a label or tick Accept to make it yours.")))
        guess(res$row_is_guess)
        write_here(res$codebook)
      }
      calls_done(calls_done() + 1L)
    })

    observeEvent(input$use_guess, {
      new = state$codebook
      if (is.null(new) || is.null(guess())) return()
      new$row_is = guess()
      write_here(new)
    })

    observeEvent(input$accept_all, {
      cb = state$codebook
      if (is.null(cb)) return()
      idx = on_page(cb)
      new = cb
      new$columns[idx] = purrr::map(cb$columns[idx], accept_label)
      if (!identical(new, cb)) { mine(new); state$codebook = new }
    })

    output$page = renderUI({
      gen()
      cb = isolate(state$codebook)
      if (is.null(cb)) return(NULL)
      idx = isolate(on_page(cb))
      n = length(cb$columns)
      offer = isolate(guess())
      offer = if (!codebook_ready(cb) && !is.null(offer)) offer
      # The tag beside each label follows the codebook, so it goes when the label is edited or accepted.
      purrr::walk(idx, function(i) {
        output[[input_id("tag", i)]] = renderUI(label_tag(state$codebook$columns[[i]], ns(input_id("accept", i))))
      })
      tagList(
        tags$div(class = "d-flex align-items-end gap-2",
                 tags$div(style = "flex:1;",
                          textInput(ns(input_id("row_is", 0L)), "What does one row represent?", value = cb$row_is, width = "100%",
                                    placeholder = offer %||% "for example: one order, or one country in one year")),
                 if (!is.null(offer)) tags$div(class = "mb-3", actionButton(ns("use_guess"), "Use this", class = "btn-sm"))),
        tags$div(class = "d-flex align-items-center gap-2 my-2",
                 actionButton(ns("prev"), "Previous", class = "btn-sm"),
                 tags$span(paste0("Columns ", if (n) idx[1] else 0L, " to ", if (n) idx[length(idx)] else 0L, " of ", n)),
                 actionButton(ns("next"), "Next", class = "btn-sm"),
                 actionButton(ns("accept_all"), "Accept all AI labels on this page", class = "btn-sm btn-outline-secondary ms-auto")),
        purrr::map(idx, function(i) codebook_row(cb$columns[[i]], function(what) ns(input_id(what, i)))))
    })

    output$footer = renderUI(if (!is.null(state$codebook)) downloadButton(ns("download"), "Download data_dictionary.yaml"))
    output$download = downloadHandler(filename = "data_dictionary.yaml", content = function(file) write_codebook(state$codebook, file))

    # Every box on the page, read together; what differs from the codebook is written to it. A
    #   changed type redraws the page, since it changes the role and may add the order box.
    observe({
      gen()                            # read first: a new codebook or page re-runs this
      cb = isolate(state$codebook)
      if (is.null(cb)) return()
      idx = isolate(on_page(cb))
      row_is = input[[input_id("row_is", 0L)]]
      vals = purrr::map(idx, function(i) list(label = input[[input_id("label", i)]], type = input[[input_id("type", i)]],
                                              role = input[[input_id("role", i)]], order = input[[input_id("order", i)]],
                                              accept = input[[input_id("accept", i)]]))
      new = cb
      if (!is.null(row_is)) new$row_is = row_is
      edited = purrr::map2(cb$columns[idx], vals, function(e, v) {
        type_changed = !is.null(v$type) && !identical(v$type, e$type)
        order = if (!type_changed && !is.null(v$order)) parse_lines(v$order)
        note = if (!is.null(order) && identical(e$type, "ordered") && !order_ok(order, e))
          paste0("The order for ", e$name, " was not accepted: list exactly these levels, one per line: ",
                 paste(e$values, collapse = " | "), ".")
        entry = edit_entry(e, label = v$label, type = v$type, role = if (!type_changed) v$role, order = order)
        list(entry = if (isTRUE(v$accept)) accept_label(entry) else entry, note = note, retyped = type_changed)
      })
      new$columns[idx] = purrr::map(edited, "entry")
      order_notes(unlist(purrr::map(edited, "note")))
      if (!identical(new, cb)) {
        mine(new)
        state$codebook = new
        if (any(purrr::map_lgl(edited, "retyped"))) gen(isolate(gen()) + 1L)
      }
    })
  })
}

# One column of the codebook as plain inputs: the name, the label, the type, the role, the order
#   of an ordered column's levels, and the facts in small grey text.
codebook_row <- function(e, id)
  tags$div(class = "row g-2 align-items-end border-bottom py-2",
    tags$div(class = "col-md-2", tags$code(e$name)),
    tags$div(class = "col-md-4", textInput(id("label"), NULL, value = e$label, width = "100%")),
    tags$div(class = "col-md-2", selectInput(id("type"), NULL, choices = type_choices(e), selected = e$type,
                                             selectize = FALSE, width = "100%")),
    tags$div(class = "col-md-2", selectInput(id("role"), NULL, choices = role_choices(e), selected = e$role,
                                             selectize = FALSE, width = "100%")),
    tags$div(class = "col-md-2 small", uiOutput(id("tag"))),
    if (identical(e$type, "ordered"))
      tags$div(class = "col-12", textAreaInput(id("order"), "Levels in order, one per line",
                                               value = paste(e$order, collapse = "\n"), width = "100%",
                                               rows = min(length(e$order), CODEBOOK_MAX_LEVELS))),
    tags$div(class = "col-12 small text-muted", facts_text(e)))

# Beside a label: "AI guess" (and "check this" when the model was not sure) with an Accept box, or
#   where the label came from.
label_tag <- function(e, accept_id) {
  if (is.null(e)) return(NULL)
  if (!identical(e$label_source, "ai_guess")) return(tags$span(class = "text-muted", paste("label:", e$label_source)))
  tagList(tags$span(class = "badge bg-warning text-dark", "AI guess"),
          if (!isTRUE(e$sure)) tags$span(class = "text-danger ms-1", "check this"),
          checkboxInput(accept_id, "Accept", value = FALSE))
}


# ---- Explore --------------------------------------------------------------------------------

# Two columns that fill the window: the chat on the left (about 38% of the width), the canvas on the right.
#   The chat does the setup (R writes those messages, no model call) and carries every question; the canvas is
#   the value boxes, then one card for each chart, two to a row, newest first.

CSS_PPI <- 96                # a CSS inch, in CSS pixels: a static chart is shown at its size in inches
EXPLORE_PALETTE_KINDS <- c(qualitative = "Groups", sequential = "Sequential fill", diverging = "Diverging fill")
EXPLORE_PLACEHOLDER <- "Ask a question about your data"
EXPLORE_WIDTH <- "38%"

# The wording a chart's spec carries, edited in boxes with no model call; a blank box is R's default.
WORDING_FIELDS <- c(title = "Title", subtitle = "Subtitle", caption = "Caption", x_label = "X-axis title", y_label = "Y-axis title")

SUMMARY_ALL_OK <- "Every number matches the chart's data."
SUMMARY_STALE <- "The chart has changed since this was written."
SUMMARY_STALE_DATA <- "The data has changed since this was written, so its numbers may no longer hold."

# What R says in the chat during setup. Each is a sentence R writes; none is ever sent to a model.
SETUP_WELCOME <- paste("Start on the Data page: choose a data file there. Setup then goes on here, in this chat,",
                       "with no model call except \"Label the columns\". After that, ask a question about your data.")
SETUP_LABEL <- "Label the columns"
SETUP_READY <- "Ask a question about your data, or press Suggest charts."
DATA_PAGE_LINK <- "[Open the Data page](#open-data-page)"
SETUP_NEED_DATA <- paste("Read a data file on the Data page first.", DATA_PAGE_LINK)
SETUP_NEED_ROW <- paste("The data dictionary does not say what one row represents yet, and charts are drawn only after it does.",
                        "Press \"Label the columns\" and then the row guess, or write it on the Data page.", DATA_PAGE_LINK)

# A story: the headline and summary of a chart as last written or edited, with the hash of the spec
#   they were written for, the facts (names as they are) and that spec, and the problems the checks
#   found. Checked again on every edit, with no model call.
recheck_story <- function(st)
  utils::modifyList(st, list(problems = problem_sentences(summary_problems(st$headline, st$summary, st$facts, st$spec))))

# The one line under a headline and summary, or under a title: all well, or what is not, in the
#   warning colour.
check_line <- function(problems, ok = SUMMARY_ALL_OK) {
  if (!length(problems)) return(if (!is.null(ok)) tags$p(class = "small text-success mb-0", ok))
  tags$p(class = "small mb-0", style = "color: var(--bs-warning-text-emphasis, #8a5a00);", paste0(paste(problems, collapse = "; "), "."))
}

# The warning line under a description of the file that holds a number DATA does not give.
TELL_WARNING <- "Not every number here is in the description of the file: "

# Text from a model or a file, made safe for a chat message. shinychat 0.4.0 draws an assistant message as markdown
#   with raw HTML switched on and no sanitiser (see the note above say() in mod_explore_server()), so anything that is
#   not R's own wording passes through here first: every ASCII punctuation mark gets a backslash (the one escape
#   CommonMark gives them all, so no emphasis, link, image, code, list, heading or table can start), and "&", "<" and ">"
#   become entities (so no tag or entity can start). The reader sees the text as it was.
#   Nothing may become a link either. GFM turns http://, https://, www. and e-mail addresses into links by itself. The
#   backslash on ":" and "." stops the first three (checked against commonmark with extensions); an address with "@" is
#   found in the text after the escapes are undone, and no escape or entity stops that, so the "@" is written as a
#   <span>@</span>: the text on either side is then not one text, and the reader sees and copies a plain "@".
md_text <- function(x)
  gsub("@", "<span>@</span>", htmltools::htmlEscape(gsub("([!\"#$%'()*+,./:;=?\\[\\\\\\]^_`{|}~-])", "\\\\\\1", as.character(x), perl = TRUE)),
       fixed = TRUE)

# A reply's text on one line: the whitespace inside it, a newline above all, becomes one space.
one_line <- function(x) trimws(gsub("[[:space:]]+", " ", as.character(x)))

# The text a chat turn appends, as markdown that is safe to show: for charts each chart's say as a short list and
#   "Added to the canvas.", then any reason for a chart it could not draw; for a new spec its say and the notes it did
#   not have before; for ask, cannot and tell the text (a tell with a number that is not in the description of the file
#   has the warning line under it); for a failure the sentences. Whatever the model wrote goes through md_text().
chat_reply_text <- function(r) {
  if (identical(r$kind, "charts")) {
    says = purrr::keep(purrr::map_chr(r$charts, function(ch) if (is_text1(ch$spec$say)) ch$spec$say else NA_character_), Negate(is.na))
    not_drawn = purrr::map_chr(r$failed, function(f)
      paste0("Chart ", f$number, if (is_text1(f$spec$title)) paste0(" (", md_text(f$spec$title), ")"), " was not drawn: ", md_text(paste(f$sentences, collapse = " "))))
    return(paste(c(if (length(says)) paste0("- ", md_text(says), collapse = "\n"), if (length(r$charts)) "Added to the canvas.", md_text(r$cannot), not_drawn),
                 collapse = "\n\n"))
  }
  if (identical(r$kind, "spec")) return(paste(c(md_text(r$text), if (length(r$new_notes)) paste("Note:", md_text(r$new_notes))), collapse = "\n\n"))
  paste(c(md_text(paste(r$text, collapse = " ")),
          if (identical(r$kind, "tell") && length(r$problems)) paste0(TELL_WARNING, md_text(paste(r$problems, collapse = ", ")), ".")),
        collapse = "\n\n")
}

# Clickable suggestions: shinychat 0.4.0 draws a markdown list whose every item is a span of class "suggestion" as a
#   grid of cards; class "submit" sends the text as the analyst's message on a click (without it the click only fills
#   the box), and data-suggestion is the text sent. The text is escaped for both places it lands: as an attribute value
#   (quotes and all) and as markdown in the span.
suggestion_list <- function(texts)
  paste0("- <span class=\"suggestion submit\" data-suggestion=\"", htmltools::htmlEscape(texts, attribute = TRUE), "\">", md_text(texts), "</span>",
         collapse = "\n")

# The words of the setup buttons: what a click sends, which R recognizes and answers without a model call.
treat_text <- function(value) paste0("Treat '", value, "' as missing")
TREAT_PATTERN <- "^Treat '(.*)' as missing$"
row_text <- function(guess) paste0("A row is ", guess)

# A chart's title for the chat and the screen reader, or `fallback` when it has none.
chart_title <- function(chart, fallback = "this chart") {
  t = chart$spec$title
  if (is_text1(t) && nzchar(trimws(t))) trimws(t) else fallback
}

# Three plain value boxes from the data, no model call: rows, columns, and the period of the first column with
#   the time role (its first and last value), else the file name.
canvas_boxes <- function(data, cb) {
  time = purrr::detect(cb$columns, function(e) identical(e$role, "time"))
  period = if (!is.null(time) && time$name %in% names(data)) tryCatch({
    x = data[[time$name]]
    rng = range(x, na.rm = TRUE)
    both = if (inherits(rng, c("Date", "POSIXt"))) date_text(rng) else format(rng, big.mark = "", scientific = FALSE, trim = TRUE)
    paste(both, collapse = " to ")
  }, error = function(e) NULL)
  box = function(title, value) bslib::value_box(title, value, fill = FALSE)
  do.call(bslib::layout_column_wrap,
          c(list(width = 1 / 3, fill = FALSE, class = "chart-boxes"),
            list(box("Rows", format_num(nrow(data))), box("Columns", format_num(ncol(data))),
                 if (!is.null(period)) box("Period", period) else box("File", cb$file %||% ""))))
}

# A click on a card selects it, unless it lands on a button, link, box or the full screen button, which have
#   their own meaning. The value carries the time, so the same card clicked twice still reaches the server.
card_click_js <- function(input_id)
  paste0("if (event.target.closest('button, a, input, select, textarea, label, .js-plotly-plot, .bslib-full-screen-enter')) return; ",
         "Shiny.setInputValue('", input_id, "', {id: this.dataset.chartId, t: Date.now()}, {priority: 'event'});")

# The copy button of the Code dialog.
copy_js <- function(code_id)
  paste0("var t = document.getElementById('", code_id, "'); var s = t.innerText; ",
         "if (navigator.clipboard && window.isSecureContext) { navigator.clipboard.writeText(s); } ",
         "else { var r = document.createRange(); r.selectNodeContents(t); var g = window.getSelection(); g.removeAllRanges(); ",
         "g.addRange(r); document.execCommand('copy'); } this.textContent = 'Copied';")

# The screen's own style and script, once. Buttons with class chart-call (Suggest charts, Write headlines, each
#   card's Headline) are disabled when one is clicked or a message is sent in the chat, and enabled again when
#   the server says its call is done ("chart-busy"), so two calls cannot overlap. A link to #open-data-page
#   opens the Data page.
EXPLORE_CSS <- "
.chart-card { cursor: pointer; }
.chart-card.chart-selected { border: 2px solid var(--bs-primary); box-shadow: 0 0 0 .2rem rgba(var(--bs-primary-rgb), .25); }
.chart-call {
  --bs-btn-color: var(--bs-emphasis-color); --bs-btn-border-color: var(--bs-emphasis-color);
  --bs-btn-hover-color: var(--bs-body-bg); --bs-btn-hover-bg: var(--bs-emphasis-color); --bs-btn-hover-border-color: var(--bs-emphasis-color);
  --bs-btn-active-color: var(--bs-body-bg); --bs-btn-active-bg: var(--bs-emphasis-color); --bs-btn-active-border-color: var(--bs-emphasis-color);
  --bs-btn-disabled-color: var(--bs-body-color); --bs-btn-disabled-bg: transparent; --bs-btn-disabled-border-color: var(--bs-body-color);
  --bs-btn-disabled-opacity: .65;
}
.chart-call:disabled { cursor: not-allowed; }
.chart-canvas { padding: .75rem 1rem; }
"
EXPLORE_JS <- "
(function () {
  if (window.chartExplore) return;
  window.chartExplore = true;
  function busy(on) {
    document.querySelectorAll('.chart-call').forEach(function (b) { b.disabled = !!on; });
  }
  document.addEventListener('click', function (e) {
    var link = e.target.closest('a[href=\"#open-data-page\"]');
    if (link) {
      e.preventDefault();
      var tab = document.querySelector('.navbar [data-value=\"Data\"]');
      if (tab) tab.click();
      return;
    }
    var b = e.target.closest('.chart-call');
    if (b && !b.disabled) setTimeout(function () { busy(true); }, 0);
  }, true);
  if (window.jQuery) {
    jQuery(document).on('shiny:inputchanged', function (e) {
      if (e.name && /chat_user_input$/.test(e.name)) busy(true);
    });
  }
  if (window.Shiny && Shiny.addCustomMessageHandler) {
    Shiny.addCustomMessageHandler('chart-busy', function (m) { busy(m.on); });
  }
})();
"

# The Explore screen: the chat (shinychat) in a sidebar 38% wide that is always open and stacks above the canvas
#   in a narrow window; Suggest charts and Write headlines sit under its input.
mod_explore_ui <- function(id) {
  ns = NS(id)
  bslib::layout_sidebar(
    fillable = TRUE,
    sidebar = bslib::sidebar(
      id = ns("side"), width = EXPLORE_WIDTH, open = list(desktop = "always", mobile = "always-above"),
      fillable = TRUE, resizable = FALSE, padding = 12, max_height_mobile = "70vh",
      shinychat::chat_ui(
        ns("chat"), width = "100%", fill = TRUE, placeholder = EXPLORE_PLACEHOLDER,
        messages = list(list(role = "assistant", content = SETUP_WELCOME)),
        footer = tags$div(class = "d-flex flex-wrap gap-2 mt-2",
                          actionButton(ns("suggest"), "Suggest charts", class = "btn-sm btn-outline-primary chart-call"),
                          actionButton(ns("write_headlines"), "Write headlines", class = "btn-sm btn-outline-primary chart-call")))),
    tags$div(class = "chart-canvas",
             uiOutput(ns("gate")), uiOutput(ns("boxes")), uiOutput(ns("bar")), uiOutput(ns("cards")), uiOutput(ns("foot"))),
    tags$style(HTML(EXPLORE_CSS)),
    tags$script(HTML(EXPLORE_JS)))
}

# ask is the function that asks the model (llm_json, or a stand-in in a test).
mod_explore_server <- function(id, state, ask = llm_json) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    rule_labels = reflex_labels()
    selected = reactiveVal(NULL)       # the id of the selected chart, or NULL
    last = reactiveVal(NULL)           # the analyst's last message and the model's reply text to it, and nothing else
    busy = reactiveVal(FALSE)          # TRUE while a call to the model runs
    palette = reactiveVal(chart_palette_default())
    treat = reactiveVal(character(0))  # the values the chat offers to treat as missing
    guess = reactiveVal(NULL)          # the model's guess at what one row is, offered while the dictionary has none
    story_note = reactiveValues()      # per chart: the sentence when no headline could be written
    made = new.env()
    made$n = 0L                        # charts made, for their ids
    made$ids = character(0)            # the charts whose outputs and observers exist
    made$key = NULL                    # the file read last: its name and column names
    made$ready_for = NULL              # the key the "ask a question" line was said for
    made$reread = NULL                 # the value the file was last read again with, for the message
    made$notes = character(0)
    made$data_key = NULL               # the digest of the data last read, to tell a read that changed it
    made$label_offer = FALSE           # whether the "Label the columns" button is on offer
    made$rows_offered = character(0)   # the row guesses that were offered, whichever is on offer now
    made$log = list()                 # every message R put in the chat (role, content), for the tests
    made$busy_log = logical(0)         # TRUE when a call started, FALSE when it was done
    made$chart = new.env()             # per chart: the chart, its headline and summary, whether it is selected
    made$story = new.env()             #   and whether its interactive view is shown, each a reactiveVal, so a change to
    made$sel = new.env()               #   one chart draws only that chart again
    made$interactive = new.env()

    # The data as it is now, as a digest: a text is written from the data of that moment and is stale when this changes.
    data_key = reactive(if (!is.null(state$data)) digest::digest(state$data))

    cid = function(chart_id, what) paste0(chart_id, "_", what)
    ready = reactive(codebook_ready(state$codebook) && !is.null(state$data))
    needs_key = function() identical(ask, llm_json) && !llm_key_ready()
    warn_style = "color: var(--bs-warning-text-emphasis, #8a5a00);"

    # A call to the model is running: every Suggest charts, Write headlines and Headline button is disabled in the
    #   browser from the click (see EXPLORE_JS), and enabled again here when the call is done, however it ends.
    with_busy = function(code) {
      busy(TRUE)
      made$busy_log = c(made$busy_log, TRUE)
      on.exit({
        busy(FALSE)
        made$busy_log = c(made$busy_log, FALSE)
        session$sendCustomMessage("chart-busy", list(on = FALSE))
      })
      force(code)
    }

    # A message in the chat: markdown, then clickable suggestions. shinychat 0.4.0 (lib/shiny/shinychat.js) draws an
    #   assistant message through remark, remark-rehype with allowDangerousHtml and rehype-raw, with no sanitiser: a tag in
    #   the text becomes a real element, an <img onerror> would run, a markdown link may carry a javascript: address, and a
    #   span of class "suggestion" is a button that sends text as the analyst. (Only the analyst's own messages, role "user",
    #   are sanitised and shown as text.) So `text` is R's own wording, and every piece that comes from a file or a model is
    #   put through md_text() where it is joined in; the suggestions are escaped by suggestion_list().
    say = function(text, suggestions = character(0), role = "assistant") {
      body = paste(c(paste(text, collapse = "\n\n"), if (length(suggestions)) suggestion_list(suggestions)), collapse = "\n\n")
      made$log = c(made$log, list(list(role = role, content = body)))
      shinychat::chat_append_message("chat", list(role = role, content = body), chunk = FALSE)
      invisible()
    }

    # ---- the charts and their texts -------------------------------------------------------------

    chart_of = function(chart_id) isolate(state$charts)[[chart_id]]
    story_of = function(chart_id) isolate(state$stories)[[chart_id]]
    set_chart = function(chart) {
      cs = isolate(state$charts) %||% list()
      cs[[chart$id]] = chart
      state$charts = cs
      if (!is.null(made$chart[[chart$id]])) made$chart[[chart$id]](chart)
    }
    set_story = function(chart_id, st) {
      ss = isolate(state$stories) %||% list()
      ss[[chart_id]] = st
      state$stories = ss
      if (!is.null(made$story[[chart_id]])) made$story[[chart_id]](st)
    }
    # A text is current while the chart's spec is the one it was written for (its hash) and the data is the data it was
    #   written from (`data`, the digest of the data then); either one changing makes it stale. `why` says which.
    story_stale = function(st, chart, data_now) {
      if (is.null(st)) return(NA_character_)
      if (!identical(st$hash, spec_hash(chart$spec))) return("chart")
      if (!identical(st$data, data_now)) return("data")
      NA_character_
    }
    needs_story = function(chart_id) {
      st = story_of(chart_id)
      is.null(st) || !is.na(story_stale(st, chart_of(chart_id), isolate(data_key())))
    }
    set_selected = function(chart_id) {
      old = isolate(selected())
      if (identical(old, chart_id)) return(invisible())
      selected(chart_id)
      if (!is.null(old) && !is.null(made$sel[[old]])) made$sel[[old]](FALSE)
      if (!is.null(chart_id) && !is.null(made$sel[[chart_id]])) made$sel[[chart_id]](TRUE)
    }
    toggle_selected = function(chart_id) set_selected(if (identical(isolate(selected()), chart_id)) NULL else chart_id)
    notes_for = function(spec) {
      r = check_chart(spec, isolate(state$codebook), isolate(state$data), isolate(palette()), chat_rule_ids())
      if (isTRUE(r$ok)) r$notes else character(0)
    }

    # New charts go to the top of the canvas, in the order the reply gave them.
    add_charts = function(charts) {
      ids = purrr::map_chr(charts, function(ch) {
        made$n = made$n + 1L
        chart = new_chart(paste0("c", made$n), ch$spec, ch$notes)
        chart$exploratory = isTRUE(ch$exploratory)
        set_chart(chart)
        make_chart(chart$id)
        chart$id
      })
      state$canvas = c(unname(ids), isolate(state$canvas))
      invisible(ids)
    }

    # Removing the selected chart clears the selection.
    remove_chart = function(chart_id) {
      if (identical(isolate(selected()), chart_id)) set_selected(NULL)
      cs = isolate(state$charts); cs[[chart_id]] = NULL; state$charts = cs
      ss = isolate(state$stories); ss[[chart_id]] = NULL; state$stories = ss
      state$canvas = setdiff(isolate(state$canvas), chart_id)
    }

    reset_canvas = function() {
      set_selected(NULL)
      state$charts = list(); state$stories = list(); state$canvas = character(0)
      last(NULL)
    }

    # Headlines and summaries for these charts: one summarize_charts() call, written from facts R computed. A
    #   chart that got none keeps any text it had, and its sentence is shown on its card.
    write_stories = function(chart_ids) {
      out = summarize_charts(unname(purrr::map(chart_ids, chart_of)), isolate(state$codebook), isolate(state$data), ask = ask,
                             palette = isolate(palette()))
      state$calls = dplyr::bind_rows(isolate(state$calls), out$calls)
      purrr::walk(out$charts, function(r) {
        if (is.null(r$headline)) { story_note[[r$id]] = r$text; return(invisible()) }
        set_story(r$id, list(headline = r$headline, summary = r$summary, hash = r$hash, data = isolate(data_key()), facts = r$facts,
                             spec = r$spec, problems = r$problems))
        story_note[[r$id]] = NULL
      })
      out
    }
    story_line = function(out) {
      got = purrr::keep(out$charts, function(r) !is.null(r$headline))
      missed = purrr::keep(out$charts, function(r) is.null(r$headline))
      title_of = function(i) chart_title(chart_of(i), i)
      paste(c(if (length(got)) paste0("Wrote the headline and summary for ", length(got), if (length(got) == 1L) " chart." else " charts."),
              purrr::map_chr(purrr::keep(got, function(r) length(r$problems) > 0L),
                             function(r) paste0("Check the text of ", md_text(title_of(r$id)), ": ", md_text(paste(r$problems, collapse = "; ")), ".")),
              purrr::map_chr(missed, function(r) paste0(md_text(title_of(r$id)), ": ", md_text(r$text)))), collapse = "\n\n")
    }

    # ---- the chat -----------------------------------------------------------------------------------

    # Whether a message may go to the model; if not, the chat says why. `what` names the action for the key sentence.
    send_ok = function(what = "Asking") {
      if (is.null(isolate(state$data)) || is.null(isolate(state$codebook))) { say(SETUP_NEED_DATA); return(FALSE) }
      if (!codebook_ready(isolate(state$codebook))) { say(SETUP_NEED_ROW); return(FALSE) }
      if (needs_key()) { say(paste(what, "needs a key.", KEY_HINT)); return(FALSE) }
      TRUE
    }

    # One chat turn: the canvas (newest first), the selected chart and the last exchange go with the message. The
    #   last exchange is this message and the reply's text, never anything R wrote in the chat during setup.
    run_turn = function(msg) {
      canvas = unname(purrr::map(isolate(state$canvas), chart_of))
      r = chat_turn(msg, canvas, isolate(selected()), isolate(state$codebook), isolate(state$data), last = isolate(last()), ask = ask,
                    palette = isolate(palette()))
      state$calls = dplyr::bind_rows(isolate(state$calls), r$calls)
      last(r$last)
      if (identical(r$kind, "spec") && !is.null(r$chart)) set_chart(r$chart)
      if (identical(r$kind, "charts")) add_charts(r$charts)
      say(chat_reply_text(r), one_line(r$`next`))
      invisible(r)
    }

    # The setup buttons are suggestions whose text R recognizes, matched exactly, and a click is not a question for the
    #   model. A text is acted on only while its button is on offer: a "Treat" text for a value that is not offered now
    #   (the file does not hold it, or it was already treated) does nothing and says so, as do the label text once the
    #   label step is done (or was never offered) and a row text that is not the guess on offer. Any other message, one
    #   that merely contains such a text included, is the analyst's own and goes to chat_turn().
    setup_action = function(msg) {
      m = trimws(msg)
      value = purrr::detect(treat(), function(w) identical(m, treat_text(w)))
      if (!is.null(value)) return(function() treat_missing(value))
      if (grepl(TREAT_PATTERN, m, perl = TRUE))
        return(function() say(paste0("No button offers '", md_text(sub(TREAT_PATTERN, "\\1", m, perl = TRUE)), "' now: the file holds no such value among its numbers, ",
                                     "or it is already treated as missing. Nothing was changed and the model was not asked.")))
      if (identical(m, SETUP_LABEL)) return(if (isTRUE(made$label_offer)) label_now else function()
        say("The Label the columns button is not on offer now: the columns were labelled already, or the data dictionary did not need it. Edit the labels on the Data page, which also has Suggest labels."))
      g = guess()
      if (!is.null(g) && identical(m, row_text(g))) return(function() use_guess(g))
      if (m %in% made$rows_offered) return(function() say("That row guess is not on offer now. Write what one row is on the Data page."))
      NULL
    }

    handle_message = function(msg) {
      action = setup_action(msg)
      if (!is.null(action)) return(invisible(action()))
      if (send_ok()) run_turn(msg)
      invisible()
    }

    observeEvent(input$chat_user_input, {
      msg = trimws(input$chat_user_input)
      if (nzchar(msg)) with_busy(handle_message(msg))
    })

    observeEvent(input$suggest, with_busy({
      say("Suggest charts", role = "user")
      if (send_ok()) run_turn(SUGGEST_MESSAGE)
    }))

    observeEvent(input$write_headlines, with_busy({
      say("Write headlines", role = "user")
      if (send_ok("Writing headlines")) {
        todo = purrr::keep(isolate(state$canvas), needs_story)
        if (!length(todo)) say(if (length(isolate(state$canvas))) "Every chart on the canvas already has a headline and summary that match it."
                               else "There are no charts on the canvas yet.")
        else say(story_line(write_stories(todo)))
      }
    }))

    # ---- setup: R's own messages --------------------------------------------------------------------

    # Treat a value as missing: the file is read again with it, as the Data page does, and the new read is said.
    treat_missing = function(value) {
      cb = isolate(state$codebook)
      path = isolate(state$path)
      if (is.null(cb) || !is_text1(path) || !file.exists(path))
        return(say("The file is no longer there to read again. Choose it again on the Data page."))
      res = tryCatch(reread_data(path, cb$file, unique(c(missing_codes(cb), value)), old = cb, encoding = cb$encoding), error = function(e) e)
      if (inherits(res, "error")) return(say(md_text(conditionMessage(res))))
      same = identical(res$read$data, isolate(state$data))
      made$reread = if (!same) value
      made$notes = res$notes
      state$data = res$read$data; state$problems = res$read$problems; state$profile = res$profile; state$codebook = res$codebook
      if (same) say(paste0("Nothing changed: no cell is exactly '", md_text(value), "'."))
      invisible()
    }

    # The one setup call: labels for the columns, and the model's guess at what one row is.
    label_now = function() {
      cb = isolate(state$codebook)
      if (is.null(cb)) return(say(SETUP_NEED_DATA))
      if (needs_key()) return(say(paste("Labelling needs a key.", KEY_HINT)))
      res = label_columns(cb, ask = ask)
      state$calls = dplyr::bind_rows(isolate(state$calls), res$calls)
      if (!is.null(res$error)) return(say(md_text(res$error)))
      made$label_offer = FALSE
      landed = sum(purrr::map2_lgl(cb$columns, res$codebook$columns, function(a, b) !identical(a$label, b$label)))
      unsure = sum(purrr::map_lgl(res$codebook$columns, function(e) identical(e$label_source, "ai_guess") && identical(e$sure, FALSE)))
      state$codebook = res$codebook
      g = if (!codebook_ready(res$codebook)) res$row_is_guess
      guess(g)
      if (!is.null(g)) made$rows_offered = union(made$rows_offered, row_text(g))
      say(c(paste0(format_num(landed), if (landed == 1L) " label was" else " labels were", " proposed",
                   if (unsure) paste0(", ", unsure, " of them marked 'check this'"),
                   ". Labels you wrote were not changed. Review and edit them on the Data page. ", DATA_PAGE_LINK),
            if (!is.null(g)) "The model also guessed what one row is. You can edit it on the Data page."),
          if (!is.null(g)) row_text(g))
    }

    use_guess = function(g) {
      cb = isolate(state$codebook)
      if (is.null(cb)) return(say(SETUP_NEED_DATA))
      cb$row_is = g
      guess(NULL)
      state$codebook = cb
      say(paste0("One row is ", md_text(g), "."))
    }

    # A file was read (or read again): what was read and what was wrong with it, a button for each value that may
    #   mean missing, and the next step. A different file starts the canvas and the conversation again.
    observeEvent(state$data, {
      data = state$data
      cb = state$codebook
      if (is.null(data) || is.null(cb)) return()
      key = list(file = cb$file, columns = names(data))
      fresh = !identical(made$key, key)
      if (fresh && !is.null(made$key)) {
        reset_canvas()
        guess(NULL)
        made$log = list()
        shinychat::chat_clear("chat")
        say("A different file was read, so the canvas and the conversation start again.")
      }
      if (fresh) { made$ready_for = NULL; made$rows_offered = character(0) }
      made$key = key
      # The same file read again keeps the canvas. When the data changed, the charts are drawn again from it (they read the
      #   data as it is) with their notes made again, and every written headline and summary is stale (story_stale()), as
      #   its numbers may no longer hold.
      dk = data_key()
      changed = !fresh && !identical(made$data_key, dk)
      made$data_key = dk
      if (changed) purrr::walk(isolate(state$canvas), function(i) {
        ch = chart_of(i)
        ch$notes = notes_for(ch$spec)
        set_chart(ch)
      })
      n_texts = if (changed) sum(purrr::map_lgl(isolate(state$canvas), function(i) !is.null(story_of(i)))) else 0L
      # A value on a button must be one line, to sit in the markup of one suggestion.
      words = purrr::discard(missing_candidates(data), function(w) grepl("[\r\n]", w))
      treat(words)
      again = made$reread
      made$reread = NULL
      problems = state$problems
      say(c(paste0("Read ", md_text(cb$file), if (!is.null(again)) paste0(" again with '", md_text(again), "' as missing"), ": ", format_num(nrow(data)), " rows, ",
                   format_num(ncol(data)), " columns."),
            if (length(problems)) paste0("- ", md_text(problems), collapse = "\n") else "No problems found.",
            if (length(made$notes)) paste0("- ", md_text(made$notes), collapse = "\n"),
            if (changed && length(isolate(state$canvas)))
              paste0("The data changed, so the ", length(isolate(state$canvas)), if (length(isolate(state$canvas)) == 1L) " chart on the canvas was" else " charts on the canvas were",
                     " drawn again from it.", if (n_texts) paste0(" ", n_texts, if (n_texts == 1L) " headline and summary is" else " headlines and summaries are",
                                                                  " marked as changed since written, because their numbers may no longer hold. Press Write headlines to write them again.")),
            if (length(words)) "If one of these stands for missing, press it and the file is read again:"),
          if (length(words)) treat_text(words))
      made$notes = character(0)
      made$label_offer = FALSE
      if (codebook_ready(cb)) {
        if (!identical(made$ready_for, key)) { made$ready_for = key; say(SETUP_READY) }
      } else {
        made$label_offer = TRUE
        say(c("Next, the data dictionary: each column needs a label, and it needs to say what one row represents.",
              "The model can propose both from the column summaries; it does not see the rows. You can also fill them in on the Data page."),
            SETUP_LABEL)
      }
    })

    # The dictionary became ready (a row guess pressed, or the row written on the Data page).
    observeEvent(ready(), {
      if (isTRUE(ready()) && !is.null(made$key) && !identical(made$ready_for, made$key)) {
        made$ready_for = made$key
        say(SETUP_READY)
      }
    }, ignoreInit = TRUE)

    # ---- the canvas ---------------------------------------------------------------------------------

    output$gate = renderUI({
      if (is.null(state$codebook) || is.null(state$data))
        return(warn_box("Read a data file on the Data page first. ", tags$a(href = "#open-data-page", "Open the Data page")))
      if (!codebook_ready(state$codebook))
        return(warn_box("The data dictionary does not say what one row represents yet, and charts are drawn only after it does. ",
                        "Press \"Label the columns\" in the chat and then the row guess, or write it on the Data page. ",
                        tags$a(href = "#open-data-page", "Open the Data page")))
      NULL
    })

    output$boxes = renderUI(if (!is.null(state$data) && !is.null(state$codebook)) canvas_boxes(state$data, state$codebook))

    output$bar = renderUI({
      if (!ready()) return(NULL)
      n = length(state$canvas)
      sel = selected()
      chosen = if (!is.null(sel) && !is.null(made$chart[[sel]])) chart_title(made$chart[[sel]](), sel)
      tags$div(class = "d-flex align-items-center flex-wrap gap-2 my-2",
               actionButton(ns("style"), "Style", class = "btn-sm btn-outline-secondary"),
               tags$span(class = "text-muted small", paste0(format_num(n), if (n == 1L) " chart" else " charts")),
               if (!is.null(chosen))
                 tagList(tags$span(class = "small", paste0("Selected: ", chosen)),
                         actionButton(ns("deselect"), "Deselect", class = "btn-sm btn-outline-secondary")))
    })

    output$cards = renderUI({
      if (!ready()) return(NULL)
      ids = state$canvas
      if (!length(ids)) return(tags$p(class = "text-muted", "No charts yet. Ask a question, or press Suggest charts."))
      do.call(bslib::layout_column_wrap,
              c(list(width = 1 / 2, fill = FALSE, heights_equal = "row"), purrr::map(ids, function(i) uiOutput(ns(cid(i, "card"))))))
    })

    output$foot = renderUI({
      calls = state$calls
      n = if (is.null(calls)) 0L else nrow(calls)
      tin = if (n) sum(calls$tokens_in, na.rm = TRUE) else 0
      tcache = if (n) sum(calls$tokens_cached, na.rm = TRUE) else 0
      tout = if (n) sum(calls$tokens_out, na.rm = TRUE) else 0
      tags$p(class = "small text-muted mt-3", paste0("Model calls this session: ", format_num(n), "; tokens in ", format_num(tin),
                                                     " (and ", format_num(tcache), " read from the cache), out ", format_num(tout), "."))
    })

    # Style: the three palettes, in a dialog; changing one draws the charts again and makes no model call.
    observeEvent(input$style, {
      pal = isolate(palette())
      showModal(modalDialog(
        title = "Style", easyClose = TRUE, footer = modalButton("Close"),
        tags$p(class = "small text-muted", "The palettes colour every chart on the canvas. Changing one draws the charts again; no model call is made."),
        purrr::imap(EXPLORE_PALETTE_KINDS, function(label, kind)
          selectInput(ns(paste0("pal_", kind)), label, choices = stats::setNames(names(chart_palettes(kind)), chart_palettes(kind)),
                      selected = pal[[kind]], selectize = FALSE, width = "100%"))))
    })
    purrr::walk(names(EXPLORE_PALETTE_KINDS), function(kind)
      observeEvent(input[[paste0("pal_", kind)]], {
        p = isolate(palette())
        v = input[[paste0("pal_", kind)]]
        if (!identical(p[[kind]], v)) { p[[kind]] = v; palette(p) }
      }, ignoreInit = TRUE))
    observe(state$palette <- palette())

    # Selecting: a click on a card (see card_click_js), the card's Select button, or Deselect. The chat's placeholder
    #   follows the selected chart.
    observeEvent(input$card_click, {
      i = input$card_click$id
      if (is_text1(i) && i %in% isolate(state$canvas)) toggle_selected(i)
    })
    observeEvent(input$deselect, set_selected(NULL))
    placeholder = reactive({
      sel = selected()
      if (is.null(sel) || is.null(made$chart[[sel]])) return(EXPLORE_PLACEHOLDER)
      paste0("Change ", chart_title(made$chart[[sel]]()), ", or ask something new")
    })
    observe(shinychat::update_chat_user_input("chat", placeholder = placeholder()))

    # ---- one card -----------------------------------------------------------------------------------

    card_ui = function(chart_id) {
      ch = made$chart[[chart_id]]()
      if (is.null(ch)) return(NULL)
      st = made$story[[chart_id]]()
      sel = isTRUE(made$sel[[chart_id]]())
      interactive = isTRUE(made$interactive[[chart_id]]())
      note = story_note[[chart_id]]
      title = chart_title(ch, "Untitled chart")
      stale = story_stale(st, ch, data_key())
      rule = ch$spec$rule
      label = if (is_text1(rule) && !is.na(rule_labels[rule])) rule_labels[[rule]]
      btn = function(what, text, class = "btn-outline-secondary", ...)
        actionButton(ns(cid(chart_id, what)), text, class = paste("btn-sm", class), ...)
      head = if (!is.null(st) && is_text1(st$headline) && nzchar(st$headline))
        tags$div(tags$div(class = "fw-semibold", st$headline), tags$div(class = "small text-muted", title))
      else tags$div(class = "fw-semibold", title)
      bslib::card(
        full_screen = TRUE, fill = FALSE, class = paste("chart-card", if (sel) "chart-selected"),
        `data-chart-id` = chart_id, onclick = card_click_js(ns("card_click")),
        bslib::card_header(
          class = "d-flex flex-column gap-2", head,
          tags$div(class = "d-flex flex-wrap gap-1",
                   btn("select", if (sel) "Deselect" else "Select", if (sel) "btn-primary" else "btn-outline-primary"),
                   btn("undo", "Undo", disabled = !length(ch$history)),
                   btn("interactive", if (interactive) "Static" else "Interactive"),
                   btn("code", "Code"),
                   btn("edit", "Edit text"),
                   btn("headline", "Headline", "btn-outline-primary chart-call"),
                   btn("remove", "Remove", "btn-outline-danger"))),
        bslib::card_body(
          fillable = FALSE, fill = FALSE,
          uiOutput(ns(cid(chart_id, "view"))),
          uiOutput(ns(cid(chart_id, "notes"))),
          if (!is.null(st)) tags$p(class = "mb-1", st$summary),
          if (!is.na(stale)) tags$p(class = "small mb-1", style = warn_style, if (identical(stale, "chart")) SUMMARY_STALE else SUMMARY_STALE_DATA),
          if (!is.null(st) && length(st$problems)) check_line(st$problems, ok = NULL),
          if (!is.null(note)) tags$p(class = "small mb-1", style = warn_style, note),
          tags$p(class = "small text-muted mb-0",
                 if (!is.null(label)) paste0("Rule: ", label),
                 if (isTRUE(ch$exploratory)) tags$span(class = "badge bg-secondary ms-1", "Exploratory"))))
    }

    # A chart's outputs and observers, made once, when it is added.
    make_chart = function(chart_id) {
      if (chart_id %in% made$ids) return(invisible())
      made$ids = c(made$ids, chart_id)
      made$chart[[chart_id]] = reactiveVal(chart_of(chart_id))
      made$story[[chart_id]] = reactiveVal(story_of(chart_id))
      made$sel[[chart_id]] = reactiveVal(FALSE)
      made$interactive[[chart_id]] = reactiveVal(FALSE)
      drawn = reactive(tryCatch(spec_plot(made$chart[[chart_id]]()$spec, state$data, state$codebook, palette()), error = function(e) e))
      # The facts the checks in the Edit text dialog compare against, from the chart as it is now.
      facts = reactive({
        x = summary_input(made$chart[[chart_id]](), state$codebook, state$data, palette())
        if (is.null(x$error)) list(text = names_back(x$facts$text, x$facts$names), spec = x$spec)
      })

      output[[cid(chart_id, "card")]] = renderUI(card_ui(chart_id))
      # Drawn at SPEC_DPI pixels per inch and shown at its size in inches, so it is sharper, not larger.
      output[[cid(chart_id, "static")]] = renderImage({
        p = drawn()
        if (inherits(p, "error")) stop(conditionMessage(p), call. = FALSE)
        f = tempfile(fileext = ".png")
        size = spec_png(p, f)
        list(src = f, contentType = "image/png", alt = attr(p, "spec")$title %||% "chart",
             width = round(size[["width"]] * CSS_PPI), height = round(size[["height"]] * CSS_PPI),
             style = "max-width:100%; height:auto;")
      }, deleteFile = TRUE)
      output[[cid(chart_id, "widget")]] = plotly::renderPlotly({
        p = drawn()
        if (inherits(p, "error")) stop(conditionMessage(p), call. = FALSE)
        spec_widget(p)
      })
      output[[cid(chart_id, "view")]] = renderUI({
        if (isTRUE(made$interactive[[chart_id]]())) plotly::plotlyOutput(ns(cid(chart_id, "widget")), height = "450px")
        else imageOutput(ns(cid(chart_id, "static")), height = "auto")
      })
      output[[cid(chart_id, "notes")]] = renderUI({
        p = drawn()
        if (inherits(p, "error")) return(warn_box(conditionMessage(p)))
        if (length(attr(p, "notes"))) tags$ul(class = "small text-muted", purrr::map(attr(p, "notes"), tags$li))
      })

      # The buttons of the header.
      observeEvent(input[[cid(chart_id, "select")]], toggle_selected(chart_id))
      observeEvent(input[[cid(chart_id, "interactive")]], {
        rv = made$interactive[[chart_id]]
        rv(!isTRUE(isolate(rv())))
      })
      observeEvent(input[[cid(chart_id, "undo")]], {
        ch = chart_of(chart_id)
        if (is.null(ch) || !length(ch$history)) return()
        ch = chart_undo(ch)
        ch$notes = notes_for(ch$spec)
        set_chart(ch)
      })
      observeEvent(input[[cid(chart_id, "remove")]], remove_chart(chart_id))
      observeEvent(input[[cid(chart_id, "headline")]], with_busy(if (send_ok("Writing a headline")) say(story_line(write_stories(chart_id)))))

      # Code: a dialog with the R code of this chart and a button that copies it.
      observeEvent(input[[cid(chart_id, "code")]], {
        ch = chart_of(chart_id)
        if (is.null(ch)) return()
        code = tryCatch(spec_code(ch$spec, isolate(state$codebook), isolate(state$path), isolate(palette())), error = function(e) conditionMessage(e))
        code_id = ns(cid(chart_id, "code_text"))
        showModal(modalDialog(
          title = paste0("Code: ", chart_title(ch)), size = "l", easyClose = TRUE,
          tags$pre(id = code_id, class = "small", paste(code, collapse = "\n")),
          footer = tagList(tags$button(type = "button", class = "btn btn-sm btn-outline-primary", onclick = copy_js(code_id), "Copy code"),
                           modalButton("Close"))))
      })

      # Edit text: the five wording boxes, and the headline and summary when they are written. No model call. Each box
      #   is checked against the chart's facts as it is left; the wording is applied with the button, a headline or
      #   summary as its box is left.
      observeEvent(input[[cid(chart_id, "edit")]], {
        ch = chart_of(chart_id)
        if (is.null(ch)) return()
        st = story_of(chart_id)
        box = function(f) ns(cid(chart_id, f))
        showModal(modalDialog(
          title = paste0("Edit text: ", chart_title(ch)), size = "l", easyClose = FALSE,
          tags$p(class = "small text-muted", "No model call is made here. Each box is checked against the chart's data when you leave it."),
          purrr::imap(WORDING_FIELDS, function(label, f)
            tagList(textInput(box(paste0("w_", f)), label, value = ch$spec[[f]] %||% "", width = "100%", updateOn = "blur"),
                    uiOutput(box(paste0("chk_", f))))),
          if (!is.null(st))
            tagList(tags$hr(),
                    textInput(box("s_head"), "Headline", value = st$headline, width = "100%", updateOn = "blur"), uiOutput(box("chk_head")),
                    textAreaInput(box("s_sum"), "Summary", value = st$summary, width = "100%", rows = 4, updateOn = "blur"), uiOutput(box("chk_sum"))),
          footer = tagList(modalButton("Close"), actionButton(box("apply"), "Apply wording", class = "btn-primary"))))
      })
      purrr::walk(names(WORDING_FIELDS), function(f)
        output[[cid(chart_id, paste0("chk_", f))]] = renderUI({
          txt = input[[cid(chart_id, paste0("w_", f))]] %||% made$chart[[chart_id]]()$spec[[f]] %||% ""
          x = facts()
          if (!nzchar(trimws(txt)) || is.null(x)) return(NULL)
          check_line(problem_sentences(summary_problems(txt, NULL, x$text, x$spec)))
        }))
      output[[cid(chart_id, "chk_head")]] = renderUI({
        st = made$story[[chart_id]]()
        if (!is.null(st)) check_line(problem_sentences(summary_problems(st$headline, NULL, st$facts, st$spec)))
      })
      output[[cid(chart_id, "chk_sum")]] = renderUI({
        st = made$story[[chart_id]]()
        if (!is.null(st)) check_line(problem_sentences(summary_problems(NULL, st$summary, st$facts, st$spec)))
      })
      purrr::iwalk(c(s_head = "headline", s_sum = "summary"), function(field, box)
        observeEvent(input[[cid(chart_id, box)]], {
          st = story_of(chart_id)
          v = input[[cid(chart_id, box)]]
          if (is.null(st) || identical(v, st[[field]])) return()
          st[[field]] = v
          set_story(chart_id, recheck_story(st))
        }, ignoreInit = TRUE))
      observeEvent(input[[cid(chart_id, "apply")]], {
        ch = chart_of(chart_id)
        if (is.null(ch)) return()
        spec = purrr::reduce(names(WORDING_FIELDS), function(sp, f) {
          v = input[[cid(chart_id, paste0("w_", f))]]
          if (is.null(v)) return(sp)
          v = trimws(v)
          sp[[f]] = if (nzchar(v)) v
          sp
        }, .init = ch$spec)
        if (!identical(spec, ch$spec)) set_chart(chart_apply(ch, spec, notes_for(spec)))
        removeModal()
      })
      invisible()
    }
  })
}
