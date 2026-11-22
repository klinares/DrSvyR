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
    tags$head(tags$style(HTML(font_face_css()))),
    tags$div(class = "chart-classification",
             style = paste("background:#b40404; color:#fff; text-align:center;",
                           "font-weight:700; letter-spacing:0.06em;",
                           "padding:5px 0; font-size:13px;"),
             classification),
    # shiny's page-level pulse while the server is busy, as a second signal; no spinners on the cards.
    shiny::useBusyIndicators(spinners = FALSE, pulse = TRUE, fade = FALSE),
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
      bslib::nav_panel(CHART_TABS[4], tags$div(class = "container py-3 chart-method", mod_method_ui("method"))),
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
    device_note(),
    fonts_note(),
    mod_key_ui("key"),
    mod_connect_ui("connect"))

# Said once on Start here: which device draws the charts (chart_device() in R/theme.R). ragg is the usual answer and
#   is said quietly; cairo or svglite, which a server without ragg falls back to, is said in a box, with what they
#   cannot do (use the bundled typefaces); a server that can draw with none says so.
device_note <- function() {
  kind = chart_device_kind()
  if (identical(kind, "none")) return(warn_box(CHART_DEVICE_NONE))
  if (identical(kind, "ragg")) return(tags$p(class = "text-muted small", "Charts are drawn with ragg."))
  warn_box(paste0("Charts are drawn with ", switch(kind, cairo = "R's cairo graphics, because the ragg package is not installed here",
                                                     svglite = "the svglite package, as SVG pictures, because neither ragg nor R's cairo graphics is here"), ".",
                  if (!chart_device_uses_bundled_fonts(kind))
                    paste0(" This device does not use the bundled typefaces: the charts are drawn in the fonts ",
                           switch(kind, cairo = "this server has.", svglite = "that the browser showing them has."))))
}

# Said once on Start here when this machine cannot draw in a bundled typeface (www/fonts/ missing, or systemfonts
#   not installed): the charts are drawn in the default fonts instead. Nothing when both are there.
fonts_note <- function() {
  missing = chart_fonts_missing()
  if (!length(missing)) return(NULL)
  many = length(missing) > 1L
  warn_box(paste0("The typeface", if (many) "s ", if (!many) " ", paste(missing, collapse = " and "), if (many) " are" else " is",
                  " not available here, so charts are drawn in the default ", paste(names(missing), collapse = " and "), " font", if (many) "s", "."))
}

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
        textInput(ns(input_id("source", 0L)), "Source of the data (optional)", value = cb$source %||% "", width = "100%",
                  placeholder = "for example: Statistics Canada, Labour Force Survey, 2023"),
        tags$p(class = "small text-muted", "Written under every chart as \"Source: ...\". With none, the file name is used."),
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
      source = input[[input_id("source", 0L)]]
      vals = purrr::map(idx, function(i) list(label = input[[input_id("label", i)]], type = input[[input_id("type", i)]],
                                              role = input[[input_id("role", i)]], order = input[[input_id("order", i)]],
                                              accept = input[[input_id("accept", i)]]))
      new = cb
      if (!is.null(row_is)) new$row_is = row_is
      if (!is.null(source)) new = codebook_source(new, source)
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
PALETTE_CVD_LEGEND <- paste0("A", CHART_CVD_TICK, " marks a palette whose colours stay apart for readers with the three common ",
                             "colour-vision differences (the check in R/theme.R).")
PALETTE_CVD_WARNING <- "This palette is hard to tell apart for some readers with colour-vision differences."

# The colours shown beside a palette's name in the Style selects: up to eight of a qualitative
#   palette, seven along a sequential or diverging one.
palette_swatch <- function(name) {
  e = CHART_PALETTES[[name]]
  cols = if (identical(e$kind, "qualitative")) utils::head(palette_colours(name), 8L) else palette_colours(name, 7L)
  cols[grepl("^#[0-9A-F]{6}$", cols)]
}

# selectize.js's render option for the Style selects: each option and the chosen item show a strip of
#   the palette's colours before its name. The colours come from window.chartSwatches, written by
#   palette_swatch_script(); the name goes through selectize's escape().
PALETTE_SWATCH_RENDER <- paste0("{option: function(item, escape) { return window.chartSwatchRow(item, escape); }, ",
                                "item: function(item, escape) { return window.chartSwatchRow(item, escape); }}")
palette_swatch_script <- function(names) {
  sw = stats::setNames(lapply(names, palette_swatch), names)
  tags$script(HTML(paste0(
    "window.chartSwatches = ", jsonlite::toJSON(sw), ";\n",
    "window.chartSwatchRow = function(item, escape) {\n",
    "  var c = (window.chartSwatches || {})[item.value] || [];\n",
    "  var s = c.filter(function(h) { return /^#[0-9A-F]{6}$/.test(h); }).map(function(h) {\n",
    "    return '<span class=\"chart-swatch\" style=\"background:' + h + '\"></span>'; }).join('');\n",
    "  return '<div><span class=\"chart-swatches\" aria-hidden=\"true\">' + s + '</span>' + escape(item.label) + '</div>';\n",
    "};")))
}
# @font-face for the bundled families, served from www/fonts/ (Shiny serves www/ at the site root, so the
#   address is relative to it), under the names the charts use: plotly and the page then draw in the same
#   faces as the static charts. "<family> SemiBold" is the semibold file as its regular face.
font_face_css <- function() {
  face = function(family, weight, file)
    paste0("@font-face { font-family: '", family, "'; font-weight: ", weight, "; font-style: normal; font-display: swap; ",
           "src: url('fonts/", file, "') format('truetype'); }")
  paste(unlist(purrr::map(CHART_FONTS, function(f)
    c(face(f$family, 400, f$regular), face(f$family, 700, f$bold),
      face(paste(f$family, "SemiBold"), 400, f$semibold), face(paste(f$family, "SemiBold"), 700, f$bold)))), collapse = "\n")
}

# A small drawn sample of a style for the Style dialog: an SVG of the style's own background, title in its
#   typeface, subtitle, grid (as the style draws it), four bars in `colour` (the chosen palette's first colour as
#   the style shows it), ticks and rule. It carries no text a reader needs; the choice's label does.
STYLE_SAMPLE_SIZE <- c(width = 132, height = 84)
style_sample_svg <- function(style, colour) {
  st = chart_style(style)
  w = STYLE_SAMPLE_SIZE[["width"]]; h = STYLE_SAMPLE_SIZE[["height"]]
  semibold = identical(st$title_weight, "semibold")
  title_fam = font_css(chart_font_family(st$title_font, if (semibold) "semibold" else "regular"))
  sub_fam = font_css(chart_font_family(st$subtitle_font))
  line = function(x1, y1, x2, y2, col, width) sprintf("<line x1=\"%s\" y1=\"%s\" x2=\"%s\" y2=\"%s\" stroke=\"%s\" stroke-width=\"%s\"/>", x1, y1, x2, y2, col, width)
  gw = max(st$grid_width * 2, 0.6)
  hgrid = if (!identical(st$grid_axes, "none")) purrr::map_chr(c(40, 52, 64), function(y) line(10, y, 122, y, st$grid, gw))
  vgrid = if (identical(st$grid_axes, "both")) purrr::map_chr(c(38, 66, 94), function(x) line(x, 36, x, 70, st$grid, gw))
  heights = c(28, 21, 15, 9)
  xs = c(16, 44, 72, 100)
  bars = purrr::map2_chr(xs, heights, function(x, ht) sprintf("<rect x=\"%s\" y=\"%s\" width=\"20\" height=\"%s\" fill=\"%s\"/>", x, 70 - ht, ht, colour))
  ticks = if (!is.na(st$ticks)) purrr::map_chr(xs + 10, function(x) line(x, 70, x, 73, st$ticks, 0.8))
  rule = if (!is.na(st$rule)) line(10, 31, 122, 31, st$rule, 1)
  paste0("<svg class=\"chart-style-sample\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ", w, " ", h, "\" width=\"", w, "\" height=\"", h,
         "\" role=\"img\" aria-label=\"Sample of the ", st$label, " style\">",
         "<rect width=\"", w, "\" height=\"", h, "\" fill=\"", st$background, "\"/>",
         "<text x=\"10\" y=\"14\" font-size=\"", round(9 * st$title_size, 1), "\" font-weight=\"", if (identical(st$title_weight, "bold")) 700 else 400,
         "\" font-family=\"", title_fam, "\" fill=\"", st$text, "\">Title</text>",
         "<text x=\"10\" y=\"25\" font-size=\"6.5\" font-family=\"", sub_fam, "\" fill=\"", st$text_2, "\">A subtitle</text>",
         paste(c(rule, hgrid, vgrid, bars, ticks), collapse = ""), "</svg>")
}

# One style in the dialog's list: the sample and its name.
style_choice_ui <- function(style, colour) {
  st = chart_style(style)
  tags$span(class = "chart-style-choice", HTML(style_sample_svg(style, colour)),
            tags$span(class = "chart-style-name d-block", st$label),
            tags$span(class = "chart-style-note d-block small text-muted", st$note))
}

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
SETUP_TRY <- "Try one of these:"
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
    says = purrr::keep(purrr::map_chr(r$charts, function(ch) if (is_text1(ch$say)) ch$say else if (is_text1(ch$spec$say)) ch$spec$say else NA_character_), Negate(is.na))
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
  period = if (!is.null(time) && time$name %in% names(data)) tryCatch(period_text(range(data[[time$name]], na.rm = TRUE)), error = function(e) NULL)
  box = function(title, value) bslib::value_box(title, value, fill = FALSE)
  # The file name and the period are long and value boxes are large type: each is set smaller, on one line (cut with an
  #   ellipsis if it must be), with the full text as its tooltip.
  small = function(title, cls, text, full) box(title, tags$span(class = cls, title = full, text))
  # The third box takes half the row on a wide canvas, and a row of its own on a narrow one (below bslib's lg breakpoint,
  #   down to 576 pixels, where the sidebar still sits beside the canvas), so the period fits on one line (Phase 7b).
  bslib::layout_columns(col_widths = bslib::breakpoints(sm = c(6, 6, 12), lg = c(3, 3, 6)), fill = FALSE, class = "chart-boxes",
                        box("Rows", format_num(nrow(data))), box("Columns", format_num(ncol(data))),
                        if (!is.null(period)) small("Period", "chart-box-period", period$short, period$full)
                        else small("File", "chart-box-file", cb$file %||% "", cb$file %||% ""))
}

# The period a time column covers, for its value box (Phase 7b): `short` is month and year ("Jan 2023 to Dec 2024") when the
#   dates span more than 60 days, else the dates; `full` is the first and last date, for the tooltip. Years as numbers stay
#   as they are ("2015 to 2024"). Month names from month.abb, so the box does not depend on the server's locale.
period_text <- function(rng) {
  if (inherits(rng, c("Date", "POSIXt"))) {
    d = as.Date(rng)
    full = paste(date_text(rng), collapse = " to ")
    month = function(x) paste(month.abb[as.integer(format(x, "%m"))], format(x, "%Y"))
    short = if (as.numeric(diff(d)) > 60) paste(month(d), collapse = " to ") else full
    return(list(short = short, full = full))
  }
  both = paste(format(rng, big.mark = "", scientific = FALSE, trim = TRUE), collapse = " to ")
  list(short = both, full = both)
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
#   the server says its call is done ("chart-busy"), so two calls cannot overlap. At the same moment, in the
#   browser and without the server (which is busy until the call ends), the working line at the foot of the
#   chat shows three dots and words for the action (WORKING_WORDS; a button's data-working); after
#   WORKING_LATER_MS it adds WORKING_LATER. It goes when the server re-enables the buttons, and also when
#   Shiny reports the server idle or disconnected, so a call that fails does not leave it showing. The line has
#   role="status", so a screen reader announces it, and its dots stay still when the system asks for reduced
#   motion. It is not a chat message: nothing is added to the chat's messages. A link to #open-data-page opens
#   the Data page.
WORKING_WORDS <- c(chat = "Thinking", suggest = "Thinking", headlines = "Writing headlines", headline = "Writing a headline",
                   label = "Labelling columns", setup = "Working")
WORKING_LATER <- ", still working"
WORKING_LATER_MS <- 8000L
EXPLORE_CSS <- "
.chart-swatches { display: inline-flex; margin-right: .4rem; vertical-align: middle; }
.chart-swatch { display: inline-block; width: .8rem; height: .8rem; border: 1px solid rgba(0, 0, 0, .15); }
.chart-style-grid .shiny-options-group { display: grid; grid-template-columns: 1fr 1fr; gap: .6rem; }
.chart-style-grid .radio { margin: 0; padding: 0; }
.chart-style-grid label { display: block; cursor: pointer; }
.chart-style-choice { display: inline-block; vertical-align: top; }
.chart-style-sample { display: block; max-width: 100%; height: auto; border: 1px solid rgba(128, 128, 128, .5); margin-bottom: .2rem; }
.chart-style-name { font-weight: 600; }
.chart-card { cursor: pointer; }
.chart-boxes .bslib-value-box .chart-box-file, .chart-boxes .bslib-value-box .chart-box-period { display: block; font-size: 1.1rem; line-height: 1.4; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%; }
.chart-boxes .bslib-value-box .chart-box-period { font-size: 1rem; }
.chart-boxes .bslib-value-box .value-box-area { min-width: 0; }
/* Card buttons in dark mode: Bootstrap's outline buttons and the theme's primary (a dark navy) keep their light-mode colours on a dark
   card and read faintly. Text and fills take the theme's body colours for dark mode (light text, 11 to 1 on the card); the hue stays in the
   border (the theme's text-emphasis colours for primary and danger). */
[data-bs-theme='dark'] .chart-card .btn-outline-secondary,
[data-bs-theme='dark'] .chart-card .btn-outline-primary:not(.chart-call) {
  --bs-btn-color: var(--bs-body-color); --bs-btn-border-color: var(--bs-body-color);
  --bs-btn-hover-color: var(--bs-body-bg); --bs-btn-hover-bg: var(--bs-body-color); --bs-btn-hover-border-color: var(--bs-body-color);
  --bs-btn-active-color: var(--bs-body-bg); --bs-btn-active-bg: var(--bs-body-color); --bs-btn-active-border-color: var(--bs-body-color);
  --bs-btn-disabled-color: var(--bs-secondary-color); --bs-btn-disabled-border-color: var(--bs-secondary-color); --bs-btn-disabled-opacity: .75;
}
[data-bs-theme='dark'] .chart-card .btn-outline-primary:not(.chart-call) { --bs-btn-border-color: var(--bs-primary-text-emphasis); }
[data-bs-theme='dark'] .chart-card .btn-outline-danger {
  --bs-btn-color: var(--bs-danger-text-emphasis); --bs-btn-border-color: var(--bs-danger-text-emphasis);
  --bs-btn-hover-color: var(--bs-body-bg); --bs-btn-hover-bg: var(--bs-danger-text-emphasis); --bs-btn-hover-border-color: var(--bs-danger-text-emphasis);
  --bs-btn-active-color: var(--bs-body-bg); --bs-btn-active-bg: var(--bs-danger-text-emphasis); --bs-btn-active-border-color: var(--bs-danger-text-emphasis);
}
[data-bs-theme='dark'] .chart-card .btn-primary {
  --bs-btn-color: var(--bs-body-bg); --bs-btn-bg: var(--bs-body-color); --bs-btn-border-color: var(--bs-primary-text-emphasis);
  --bs-btn-hover-color: var(--bs-body-bg); --bs-btn-hover-bg: var(--bs-body-color); --bs-btn-hover-border-color: var(--bs-primary-text-emphasis);
}
.chart-call {
  --bs-btn-color: var(--bs-emphasis-color); --bs-btn-border-color: var(--bs-emphasis-color);
  --bs-btn-hover-color: var(--bs-body-bg); --bs-btn-hover-bg: var(--bs-emphasis-color); --bs-btn-hover-border-color: var(--bs-emphasis-color);
  --bs-btn-active-color: var(--bs-body-bg); --bs-btn-active-bg: var(--bs-emphasis-color); --bs-btn-active-border-color: var(--bs-emphasis-color);
  --bs-btn-disabled-color: var(--bs-body-color); --bs-btn-disabled-bg: transparent; --bs-btn-disabled-border-color: var(--bs-body-color);
  --bs-btn-disabled-opacity: .65;
}
.chart-call:disabled { cursor: not-allowed; }
.chart-canvas { padding: .75rem 1rem; }
.chart-working { font-size: .875rem; color: var(--bs-secondary-color); margin-top: .5rem; }
.chart-working[hidden] { display: none; }
.chart-working-dot { display: inline-block; width: .4rem; height: .4rem; margin-right: .2rem; border-radius: 50%;
  background: currentColor; animation: chart-working-pulse 1.2s infinite ease-in-out; }
.chart-working-dot:nth-child(2) { animation-delay: .2s; }
.chart-working-dot:nth-child(3) { animation-delay: .4s; margin-right: .5rem; }
@keyframes chart-working-pulse { 0%, 80%, 100% { opacity: .25; } 40% { opacity: 1; } }
@media (prefers-reduced-motion: reduce) { .chart-working-dot { animation: none; opacity: .7; } }
"
EXPLORE_JS <- paste0("
(function () {
  if (window.chartExplore) return;
  window.chartExplore = true;
  var WORDS = ", jsonlite::toJSON(as.list(WORKING_WORDS), auto_unbox = TRUE), ";
  var LATER = ", jsonlite::toJSON(WORKING_LATER, auto_unbox = TRUE), ";
  var timer = null;
  function line() { return document.querySelector('.chart-working'); }
  function work(words) {
    var el = line();
    if (!el) return;
    var lab = el.querySelector('.chart-working-words');
    if (lab) lab.textContent = words;
    el.hidden = false;
    if (timer) clearTimeout(timer);
    timer = setTimeout(function () { if (lab && !el.hidden) lab.textContent = words + LATER; }, ", WORKING_LATER_MS, ");
  }
  function done() {
    if (timer) { clearTimeout(timer); timer = null; }
    var el = line();
    if (el) el.hidden = true;
  }
  function wordsFor(text) {
    text = String(text || '');
    if (text === 'Label the columns') return WORDS.label;
    if (/^Treat '.*' as missing$/.test(text) || /^A row is /.test(text)) return WORDS.setup;
    return WORDS.chat;
  }
  function busy(on) {
    document.querySelectorAll('.chart-call').forEach(function (b) { b.disabled = !!on; });
    if (!on) done();
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
    if (b && !b.disabled) {
      var words = b.getAttribute('data-working') || WORDS.chat;
      setTimeout(function () { busy(true); work(words); }, 0);
    }
  }, true);
  if (window.jQuery) {
    jQuery(document).on('shiny:inputchanged', function (e) {
      if (e.name && /chat_user_input$/.test(e.name)) { busy(true); work(wordsFor(e.value)); }
    });
    jQuery(document).on('shiny:idle shiny:disconnected', function () { done(); });
  }
  if (window.Shiny && Shiny.addCustomMessageHandler) {
    Shiny.addCustomMessageHandler('chart-busy', function (m) { busy(m.on); });
  }
})();
")

# The working line under the chat's input: hidden until a call starts (see EXPLORE_JS).
working_line <- function()
  tags$div(class = "chart-working", role = "status", `aria-live` = "polite", hidden = NA,
           tags$span(class = "chart-working-dot", `aria-hidden` = "true"), tags$span(class = "chart-working-dot", `aria-hidden` = "true"),
           tags$span(class = "chart-working-dot", `aria-hidden` = "true"), tags$span(class = "chart-working-words", WORKING_WORDS[["chat"]]))

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
        footer = tags$div(tags$div(class = "d-flex flex-wrap gap-2 mt-2",
                                   actionButton(ns("suggest"), "Suggest charts", class = "btn-sm btn-outline-primary chart-call",
                                                `data-working` = WORKING_WORDS[["suggest"]]),
                                   actionButton(ns("write_headlines"), "Write headlines", class = "btn-sm btn-outline-primary chart-call",
                                                `data-working` = WORKING_WORDS[["headlines"]])),
                          working_line()))),
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

    # The dictionary is ready: the line that says so and, while the canvas is empty, questions to try, as suggestion cards (the
    #   templates of www/methodology.md filled from the dictionary: example_questions(), no model call). A card sends its question.
    say_ready = function() {
      tries = if (!length(isolate(state$canvas))) example_questions(isolate(state$codebook))$question else character(0)
      say(c(SETUP_READY, if (length(tries)) SETUP_TRY), tries)
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
        if (!identical(made$ready_for, key)) { made$ready_for = key; say_ready() }
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
        say_ready()
      }
    }, ignoreInit = TRUE)

    # A question that Methodology's "Ask this" button put in state$ask_request: sent as if the analyst had pressed a suggestion
    #   card, so it shows as the analyst's message and goes the same way (setup_action(), then chat_turn()).
    observeEvent(state$ask_request, {
      req = state$ask_request
      if (is.list(req) && is_text1(req$text) && nzchar(trimws(req$text)))
        shinychat::update_chat_user_input("chat", value = req$text, submit = TRUE, focus = FALSE)
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
                         actionButton(ns("deselect"), "Deselect", class = "btn-sm btn-outline-secondary")),
               uiOutput(ns("style_warning"), class = "w-100"))
    })

    # One line under Style when a chosen palette does not pass the colour-vision check.
    output$style_warning = renderUI({
      p = palette()
      if (all(purrr::map_lgl(unlist(p[names(EXPLORE_PALETTE_KINDS)]), palette_passes))) return(NULL)
      tags$p(class = "small mb-0", style = "color: var(--bs-warning-text-emphasis, #8a5a00);", PALETTE_CVD_WARNING)
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

    # Style: the chart style and the three palettes, in a dialog; changing one draws every chart again and makes no
    #   model call. The style is one for the whole dashboard (palette()$style): the analyst's choice, never the model's,
    #   and it changes no text.
    observeEvent(input$style, {
      pal = isolate(palette())
      sample_colour = chart_palette(1L, pal$qualitative, pal$style %||% CHART_STYLE_DEFAULT)[[1]]
      showModal(modalDialog(
        title = "Style", size = "l", easyClose = TRUE, footer = modalButton("Close"),
        tags$p(class = "small text-muted", "The style and the palettes apply to every chart on the canvas. Changing one draws the charts again; ",
               "no model call is made and no text changes."),
        tags$div(class = "row g-3",
          tags$div(class = "col-md-7 chart-style-grid",
                   tags$h6("Chart style"),
                   radioButtons(ns("style_choice"), NULL, width = "100%",
                                choiceNames = purrr::map(names(CHART_STYLES), style_choice_ui, colour = sample_colour),
                                choiceValues = names(CHART_STYLES), selected = pal$style %||% CHART_STYLE_DEFAULT)),
          tags$div(class = "col-md-5",
                   tags$h6("Palettes"),
                   tags$p(class = "small text-muted", PALETTE_CVD_LEGEND),
                   palette_swatch_script(unlist(purrr::map(names(EXPLORE_PALETTE_KINDS), function(kind) names(chart_palettes(kind))))),
                   purrr::imap(EXPLORE_PALETTE_KINDS, function(label, kind)
                     selectizeInput(ns(paste0("pal_", kind)), label, choices = chart_palette_groups(kind), selected = pal[[kind]],
                                    width = "100%", options = list(render = I(PALETTE_SWATCH_RENDER))))))))
    })
    observeEvent(input$style_choice, {
      p = isolate(palette())
      v = input$style_choice
      if (v %in% names(CHART_STYLES) && !identical(p$style, v)) { p$style = v; palette(p) }
    }, ignoreInit = TRUE)
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
                   btn("headline", "Headline", "btn-outline-primary chart-call", `data-working` = WORKING_WORDS[["headline"]]),
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
        kind = chart_device_kind()
        f = tempfile(fileext = chart_device_ext(kind))
        size = spec_png(p, f)
        list(src = f, contentType = chart_device_type(kind), alt = attr(p, "spec")$title %||% "chart",
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
        shown = c(attr(p, "notes"), if (isTRUE(made$interactive[[chart_id]]())) widget_notes(attr(p, "spec")))
        if (length(shown)) tags$ul(class = "small text-muted", purrr::map(shown, tags$li))
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
        # The chart as drawn: the spec as the lint left it (sideways bars, end labels, the legend's order, the source line), the
        #   palette and style chosen, so the code gives the card's chart.
        p = drawn()
        code = if (inherits(p, "error")) conditionMessage(p)
               else tryCatch(spec_code(attr(p, "spec"), isolate(state$codebook), isolate(state$path), isolate(palette())), error = function(e) conditionMessage(e))
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


# ---- Methodology -----------------------------------------------------------------------------------------------------
#   The page, in this order: www/methodology.md as HTML (the manager's text, never edited here; a small drawn example
#   beside each row of its "Which chart for which question" table); "Questions for your file", the page's templates filled
#   from the data dictionary (example_questions(), no model call); "The rules the model follows", built from the reflex files
#   by their own parser; "How a reply is checked"; the styles and fonts with their licences. A contents list at the top. No
#   part of it calls a model. Everything but the questions is the same for every session, so it is built once, when the app
#   starts (the pictures from a table made here, not from any file of the analyst's).

# A thumbnail is the chart as the app draws it, 7 by 4.5 inches, at 72 pixels per inch, shown about 9 rem wide.
METHOD_THUMB_SIZE <- c(width = 7, height = 4.5)
METHOD_THUMB_DPI <- 72L

# One thumbnail for each family of the table: the key is the first word of the table's "The chart" cell, lower case
#   ("Bar, or dot" is bar, "Small multiples" is small). The specs are written as the gold specs are, against the table
#   method_thumb_data() makes.
METHOD_THUMB_SPECS <- list(
  bar = list(family = "bar", x = "region", y = "revenue", fn = "sum"),
  line = list(family = "line", x = "year", y = "revenue", color = "region", fn = "sum"),
  slope = list(family = "slope", x = "year", y = "revenue", color = "region", fn = "sum",
               filter = list(list(column = "year", op = "in", value = c(2015L, 2024L)))),
  scatter = list(family = "scatter", x = "units", y = "price", fit = "loess"),
  bubble = list(family = "bubble", x = "units", y = "price", size = "revenue",
                filter = list(list(column = "year", op = "==", value = 2024L))),
  histogram = list(family = "histogram", x = "revenue"),
  box = list(family = "box", x = "region", y = "price"),
  heatmap = list(family = "heatmap", x = "year", y = "region", color = "price", fn = "mean", labels = "off"),
  small = list(family = "line", x = "year", y = "revenue", facet = "region", fn = "sum"))
METHOD_THUMB_ALT <- c(
  bar = "A small bar chart: one bar for each of five groups.", line = "A small line chart: one line for each of five groups over ten years.",
  slope = "A small slope chart: five groups at two points in time, joined by lines.",
  scatter = "A small scatter chart: one point for each row, with a fitted curve.",
  bubble = "A small bubble chart: five points, the size of each showing a third measure.",
  histogram = "A small histogram: how one measure is spread out.", box = "A small box chart: the spread of one measure for each of five groups.",
  heatmap = "A small heatmap: one measure in the cells of two groupings.", small = "Small multiples: the same line chart repeated in a panel for each of five groups.")
METHOD_THUMB_NOTE <- paste("The small pictures are drawn by chaRt from a made-up table of five regions over ten years. They show the form of each",
                           "chart, not a finding.")

# The thumbnails are made once per process: the first call draws them, and app.R makes that call when it starts.
METHOD_CACHE <- new.env()

# A tiny table, the same every time and made with no random numbers: five regions by ten years, with units, price and revenue.
method_thumb_data <- function() {
  regions = c("North", "South", "East", "West", "Central")
  grid = expand.grid(year = 2015:2024, region = regions, stringsAsFactors = FALSE)
  r = match(grid$region, regions)
  wobble = function(k) sin(k * 12.9898 + r * 78.233 + grid$year * 37.719)
  units = round(100 * c(1.0, 0.8, 1.3, 0.6, 1.0)[r] * (1 + c(0.06, 0.0, 0.03, 0.09, -0.02)[r])^(grid$year - 2015L) * (1 + 0.08 * wobble(1)))
  price = round(10 + 0.07 * units + 3 * wobble(2), 2)
  tibble::tibble(region = grid$region, year = grid$year, units = units, price = price, revenue = round(units * price, 2))
}

# One thumbnail as a data address, drawn on the device chart_device() opens, as every chart is.
method_thumb_draw <- function(spec, data, cb) {
  p = spec_plot(spec, data, cb)
  f = tempfile(fileext = chart_device_ext())
  on.exit(unlink(f))
  spec_png(p, f, size = METHOD_THUMB_SIZE, dpi = METHOD_THUMB_DPI)
  paste0("data:", chart_device_type(), ";base64,", jsonlite::base64_enc(readBin(f, "raw", file.size(f))))
}

# The thumbnails by key; NULL for one that could not be drawn (a server that cannot draw has none, and the page goes without).
method_thumbs <- function() {
  if (is.null(METHOD_CACHE$thumbs)) {
    data = method_thumb_data()
    cb = new_codebook(profile_data(data), "made-up table", nrow(data))
    cb$row_is = "one region in one year"
    METHOD_CACHE$thumbs = purrr::map(METHOD_THUMB_SPECS, function(s) tryCatch(method_thumb_draw(s, data, cb), error = function(e) NULL))
  }
  METHOD_CACHE$thumbs
}

method_thumb_key <- function(chart) tolower(sub("[ ,].*$", "", trimws(chart)))

# The page's own headings get an id so the contents list can link to them: "method-" and the heading as lower case words.
method_slug <- function(x)
  paste0("method-", gsub("^-+|-+$", "", gsub("[^a-z0-9]+", "-", tolower(gsub("<[^>]+>|&[a-z#0-9]+;", "", x)))))

method_add_ids <- function(html) {
  found = gregexpr("<h2>(.*?)</h2>", html, perl = TRUE)
  hits = regmatches(html, found)[[1]]
  if (!length(hits)) return(html)
  text = sub("^<h2>(.*)</h2>$", "\\1", hits)
  regmatches(html, found) = list(paste0("<h2 id=\"", method_slug(text), "\">", text, "</h2>"))
  html
}

# The id and text (as HTML) of each "##" heading of the rendered page.
method_headings <- function(html) {
  hits = regmatches(html, gregexpr("<h2 id=\"[^\"]+\">.*?</h2>", html, perl = TRUE))[[1]]
  list(id = sub("^<h2 id=\"([^\"]+)\">.*$", "\\1", hits), text = sub("^<h2 id=\"[^\"]+\">(.*)</h2>$", "\\1", hits))
}

# The table under "Which chart for which question", in a scrolling box, with a first column of thumbnails: one cell for
#   each row, from the table's own order (the templates are read from the same rows). The html is left as it was if the
#   table is not there or has a different number of rows.
method_add_thumbs <- function(html, templates, thumbs) {
  pat = paste0("(?s)<h2[^>]*>", METHODOLOGY_TABLE_HEADING, "</h2>\\s*<table>(.*?)</table>")
  at = regexpr(pat, html, perl = TRUE)
  if (at < 0L) return(html)
  table_html = regmatches(html, regexec(pat, html, perl = TRUE))[[1]][2]
  start = regexpr("<tbody>", table_html, fixed = TRUE)
  head_html = substr(table_html, 1L, start - 1L)
  body_html = substr(table_html, start, nchar(table_html))
  rows = gregexpr("<tr>", body_html, fixed = TRUE)
  keys = method_thumb_key(templates$chart)
  if (start < 0L || length(rows[[1]]) != length(keys)) return(html)
  alt = function(key) if (key %in% names(METHOD_THUMB_ALT)) METHOD_THUMB_ALT[[key]] else ""
  cell = function(key) paste0("<tr><td class=\"chart-method-thumb\">",
                              if (!is.null(thumbs[[key]]))
                                paste0("<img src=\"", thumbs[[key]], "\" alt=\"", htmltools::htmlEscape(alt(key), attribute = TRUE), "\" loading=\"lazy\">"),
                              "</td>")
  regmatches(body_html, rows) = list(purrr::map_chr(keys, cell))
  head_html = sub("<tr>", "<tr><th scope=\"col\">Example</th>", head_html, fixed = TRUE)
  heading = sub("(?s)<table>.*$", "", regmatches(html, at)[[1]], perl = TRUE)
  new = paste0(heading, "<div class=\"table-responsive\"><table class=\"table table-sm align-middle chart-method-table\">", head_html, body_html,
               "</table></div><p class=\"small text-muted\">", htmltools::htmlEscape(METHOD_THUMB_NOTE), "</p>")
  paste0(substr(html, 1L, at - 1L), new, substr(html, at + attr(at, "match.length"), nchar(html)))
}

# The sections the page adds after the manager's text, as id and title, in order.
METHOD_SECTIONS <- c("method-questions" = "Questions for your file", "method-rules" = "The rules the model follows",
                     "method-checks" = "How a reply is checked", "method-styles" = "Styles and fonts")

method_contents <- function(ids, titles)
  tags$nav(class = "chart-method-contents card card-body mb-4", `aria-label` = "Contents",
           tags$p(class = "fw-semibold mb-1", "On this page"),
           tags$ul(class = "list-unstyled mb-0 chart-method-toc",
                   purrr::map2(ids, titles, function(id, title) tags$li(tags$a(href = paste0("#", id), HTML(title))))))

# The manager's page as HTML, by commonmark with extensions (what shiny::markdown() calls: tables are an extension), with the
#   thumbnails in the table and an id on each heading; and the contents list after the opening paragraph, where the
#   first "##" heading starts. The braces of the question templates are shown as they are.
method_text_ui <- function(path = METHODOLOGY_FILE) {
  md = paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  html = method_add_ids(commonmark::markdown_html(md, extensions = TRUE))
  html = method_add_thumbs(html, methodology_templates(path), method_thumbs())
  heads = method_headings(html)
  first = regexpr("<h2", html, fixed = TRUE)
  contents = method_contents(c(heads$id, names(METHOD_SECTIONS)), c(heads$text, unname(METHOD_SECTIONS)))
  if (first < 0L) return(tagList(HTML(html), contents))
  tagList(HTML(substr(html, 1L, first - 1L)), contents, HTML(substr(html, first, nchar(html))))
}

# "The rules the model follows": every reflex with a Label, from the parsed reflex files, grouped by file, a collapsed
#   section for each: the label, when it applies, what it says, and its source. A rule with no Label (the analyst never
#   reads it, and the column-labelling file has none) is counted, not listed.
method_rules_ui <- function(dir = REFLEXES_DIR) {
  files = purrr::map(REFLEX_FILES, read_reflex_file, dir)
  shown = purrr::map(files, function(s) purrr::keep(unname(s$reflexes), function(r) !is.na(r$label)))
  hidden = sum(lengths(purrr::map(files, function(s) s$reflexes))) - sum(lengths(shown))
  rule_ui = function(r)
    tags$div(class = "chart-rule mb-3",
             tags$div(class = "fw-semibold", r$label),
             tags$div(class = "small", tags$span(class = "text-muted", "When: "), r$when),
             tags$div(class = "small", tags$span(class = "text-muted", "Say: "), r$say),
             tags$div(class = "small text-muted", "Source: ", if (!is.na(r$source)) r$source))
  tags$section(
    id = "method-rules",
    tags$h2("The rules the model follows"),
    tags$p("The model is given these written rules with every request. Each says when it applies and what to say, and each carries its ",
           "source. ", paste0(sum(lengths(shown)), " rules are listed here, in ", sum(lengths(shown) > 0L), " files",
                              if (hidden > 0L) paste0("; ", hidden, " more have no label and are not listed"), ".")),
    purrr::map2(files, shown, function(s, rules) if (length(rules))
      tags$details(class = "chart-rule-file mb-2",
                   tags$summary(class = "fw-semibold", paste0(s$title, " (", s$file, ", version ", s$version, "): ", length(rules), if (length(rules) == 1L) " rule" else " rules")),
                   tags$div(class = "mt-2 ms-3", purrr::map(rules, rule_ui)))))
}

# "How a reply is checked", in plain words, from what R does with a reply (check_numbers(), check_words(), names_back(),
#   check_chart(), summarize_batch() and chat_turn()). The words and numbers it quotes are the code's own constants.
method_checks_ui <- function() {
  words = function(x) paste0("'", x, "'", collapse = ", ")
  tags$section(
    id = "method-checks",
    tags$h2("How a reply is checked"),
    tags$p("The model's reply is only text. R reads it as data and never runs it, and R checks it before anything is shown as ",
           "fact. The checks look at numbers, words and names; they cannot tell whether a sentence is a fair reading of the chart."),
    tags$h3(class = "h5", "The number check"),
    tags$p(paste0("Every number in a headline, a summary or a description of the file is looked for among the numbers R computed for that ",
           "chart (its facts). A number passes when it is one of them, however it is written: '1,200', '1200' and '1.2 thousand' are one number, ",
           "and a percent sign is ignored. It also passes when it is one of them rounded to fewer digits that still keep at least two ",
           "significant digits: 69,700 passes for 69,712, and 70,000 does not. A number in the chart's own filter or top-n passes, and so ",
           "does a year that appears in the facts. The words from '", names(NUMBER_WORDS)[1L], "' to '", names(NUMBER_WORDS)[length(NUMBER_WORDS)],
           "' are checked as numbers; 'one' is not, because it is nearly always a pronoun. A date such as 2024-12-01 counts as its year.")),
    tags$h3(class = "h5", "The word check"),
    tags$p(paste0("Words that claim a cause, or reach beyond the rows of the file, are not allowed: ", words(SUMMARY_FORBIDDEN), ". Words that state ",
           "a multiple, ", words(names(MULTIPLE_WORDS)), ", pass only when the chart's facts state a multiple that supports them: at least 2 for ",
           "'doubled' and 'twice', 3 for 'tripled', 4 for 'quadrupled', at most 0.5 for 'halved'.")),
    tags$h3(class = "h5", "The names check"),
    tags$p("The model writes a name from your file as a token, such as [[N1]], and R puts the name back. A token that is not a name in ",
           "that chart is flagged."),
    tags$h3(class = "h5", "The chart check"),
    tags$p("A chart the model asks for is checked before it is drawn. Its rule must be one of the written rules and must fit the chart's ",
           "family (otherwise the rule is dropped, with no repair). Its columns must exist, not be ignored and be of a kind that part of the ",
           "chart takes; its function, filter, top-n, sort, fit and every other field must be ones that family takes; and R must be able to ",
           "build the chart's table from the rows. R then looks for faults a reader would notice, such as too many colours, and adds a note ",
           "to the chart for each."),
    tags$h3(class = "h5", "The repair"),
    tags$p("A reply that fails a check gets one repair call: the model is shown its own reply, the problems found and the request to send the ",
           "reply again corrected. The new reply is checked in the same way. There is no second repair. Text that still fails is kept and marked ",
           "on its card, with each problem in plain words; a chart that still fails is not drawn, and the chat says why."),
    tags$h3(class = "h5", "Your own edits"),
    tags$p("A headline or summary you edit is checked by the same number and word checks as you leave the box, with no model call. A text is ",
           "marked as changed when the chart, or the data, is no longer what it was written for."),
    tags$h3(class = "h5", "Text from the model or the file"),
    tags$p("A name, label or model sentence is escaped before the chat shows it, so it is read as text and never starts a link, a picture or ",
           "formatting."))
}

# The styles, each with its small sample (the one the Style dialog shows), and the two bundled typefaces with their licences.
FONT_LICENCE <- "SIL Open Font License, Version 1.1"
FONT_LICENCE_FILES <- c(sans = "Inter-LICENSE.txt", serif = "SourceSerif4-LICENSE.md")

# The first line of a font's licence file, which names its copyright holder.
font_copyright <- function(file) {
  path = file.path(CHART_FONT_DIR, file)
  if (!file.exists(path)) return("(the licence file is not in this copy of the app)")
  trimws(readLines(path, n = 1L, encoding = "UTF-8", warn = FALSE))
}

method_styles_ui <- function() {
  colour = chart_palette(1L, chart_palette_default()$qualitative, CHART_STYLE_DEFAULT)[[1]]
  serif_in = purrr::map_chr(purrr::keep(CHART_STYLES, function(s) "serif" %in% c(s$title_font, s$subtitle_font)), "label")
  font_ui = function(role) {
    f = CHART_FONTS[[role]]
    file = FONT_LICENCE_FILES[[role]]
    tags$li(class = "mb-2",
            tags$span(class = "fw-semibold", style = paste0("font-family: ", f$css, ";"), paste0(f$family, ":")),
            paste0(if (identical(role, "serif")) paste0("the title and subtitle of the ", paste(serif_in, collapse = " and "), " style, in regular, semibold and bold. ")
                   else "all other chart text, in regular, semibold and bold. ",
                   "Licence: ", FONT_LICENCE, ". ", font_copyright(file), " "),
            tags$a(href = file.path("fonts", file), target = "_blank", rel = "noopener", "Licence text"))
  }
  tags$section(
    id = "method-styles",
    tags$h2("Styles and fonts"),
    tags$p("A dashboard has one style, chosen with the Style button on Explore; the model never chooses it. Each style is a set of colours, ",
           "a grid and a title in one of two typefaces."),
    tags$div(class = "row g-3 mb-3",
             purrr::map(names(CHART_STYLES), function(nm) {
               st = CHART_STYLES[[nm]]
               tags$div(class = "col-6 col-md-4 col-lg-2",
                        HTML(style_sample_svg(nm, colour)), tags$div(class = "fw-semibold", st$label), tags$div(class = "small text-muted", st$note))
             })),
    tags$h3(class = "h5", "The typefaces"),
    tags$p("Two typefaces are bundled with the app, so a chart looks the same on any server (when it is drawn by ragg; see Start here)."),
    tags$ul(class = "list-unstyled", purrr::map(names(CHART_FONTS), font_ui)))
}

METHOD_CSS <- "
.chart-method { max-width: 62rem; }
.chart-method h2 { margin-top: 2rem; }
.chart-method-toc li { margin: .15rem 0; }
.chart-method-table td, .chart-method-table th { vertical-align: top; }
.chart-method-thumb { width: 9.5rem; min-width: 9.5rem; }
.chart-method-thumb img { display: block; width: 9rem; height: auto; border: 1px solid rgba(128, 128, 128, .5); }
.chart-method .chart-style-sample { width: 100%; max-width: 12rem; }
.chart-rule-file > summary { cursor: pointer; }
.chart-question { display: flex; gap: .75rem; align-items: baseline; padding: .35rem 0; border-bottom: 1px solid rgba(128, 128, 128, .25); }
.chart-question .btn { flex: none; }
"

# The Methodology page: its parts, and a place for the questions, which depend on the file.
mod_method_ui <- function(id) {
  ns = NS(id)
  tagList(
    method_text_ui(),
    tags$section(id = "method-questions", tags$h2("Questions for your file"), uiOutput(ns("questions"))),
    method_rules_ui(),
    method_checks_ui(),
    method_styles_ui(),
    tags$style(HTML(METHOD_CSS)))
}

# "Questions for your file": what is there to say before a file is read, when none of the templates fits it, and the
#   questions, each with a button. The text of a question comes from the analyst's own labels; it is put in the page as
#   text by htmltools, which escapes it, and the button sends the question the server holds, not a text from the browser.
method_questions_ui <- function(ns, cb, questions, ready) {
  if (is.null(cb))
    return(tags$p(class = "text-muted", "Read a data file on the Data page, and questions made from its columns appear here. ",
                  tags$a(href = "#open-data-page", "Open the Data page")))
  if (!nrow(questions))
    return(tags$p(class = "text-muted", "None of the question templates above fits the columns of this file: they need columns with the ",
                  "measure, group or time role, and a column with fewer than two different values or mostly missing is not used."))
  tagList(
    tags$p("Made from the labels of your columns by filling in the templates above, with no model call. A button sends the question to Explore.",
           if (!ready) " Explore will first ask what one row of the file is, because the data dictionary does not say yet."),
    purrr::map(seq_len(nrow(questions)), function(i)
      tags$div(class = "chart-question",
               actionButton(ns(paste0("ask_", i)), "Ask this", class = "btn-sm btn-outline-primary chart-call",
                            `data-working` = WORKING_WORDS[["chat"]],
                            onclick = "var t = document.querySelector('.navbar [data-value=\"Explore\"]'); if (t) t.click();"),
               tags$span(questions$question[[i]]),
               tags$span(class = "badge text-bg-secondary flex-none", questions$family[[i]]))))
}

# The questions follow the data dictionary. A button puts its question in state$ask_request, which the Explore server sends
#   as the analyst's message (a question, not a model call made here).
mod_method_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    questions = reactive(if (!is.null(state$codebook)) example_questions(state$codebook))
    output$questions = renderUI(method_questions_ui(ns, state$codebook, questions(), codebook_ready(state$codebook)))
    purrr::walk(seq_len(EXAMPLE_QUESTIONS_MAX), function(i)
      observeEvent(input[[paste0("ask_", i)]], {
        q = questions()
        if (!is.null(q) && i <= nrow(q)) state$ask_request = list(text = q$question[[i]], t = as.numeric(Sys.time()))
      }))
  })
}
