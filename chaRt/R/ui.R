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
    privacy_ui(),
    device_note(),
    fonts_note(),
    theme_note(),
    skills_note(),
    video_note(),
    mod_key_ui("key"),
    mod_connect_ui("connect"))

# What the model is sent, in words, for Start here, the Methodology page and the README (Phase 11 Part B: the model used to be told nothing of the file but
#   its columns; a design call sends more). The setting APP_DESIGN_IMAGES says which pictures leave this server.
PRIVACY_BASE <- paste("The model never receives the rows of your file as text. It is sent the data dictionary, a summary of each column in play, and, to write a headline,",
                      "the numbers R worked out for that chart, with the names from identifier and text columns replaced by placeholders.")
PRIVACY_DESIGN <- paste("When you press Design, the model is also sent the table the chart plots, if that table is aggregated and has at most", DESIGN_TABLE_ROWS_MAX,
                        "rows (never rows of your file), and the picture of the chart, so that it can look at its own drawing and correct it.",
                        "The picture of a scatter, bubble, box or violin chart shows individual rows as marks, so those rows can be read from it.")
design_privacy_images <- function(setting = design_images_setting())
  switch(setting,
         all = "This server sends the picture of every chart that is designed.",
         aggregated = "This server sends the picture only of charts drawn from aggregated tables, never of a chart whose marks are rows of the file.",
         "This server sends no picture, so a design is not reviewed by looking.")
privacy_text <- function(setting = design_images_setting()) c(PRIVACY_BASE, PRIVACY_DESIGN, design_privacy_images(setting))

privacy_ui <- function(setting = design_images_setting())
  advice_box(tags$p(tags$strong("What the model is sent")), purrr::map(privacy_text(setting), tags$p))

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

# Said once on Start here: whether this server makes videos (the Animate button). Quiet when it does; when it does not (no av package,
#   or a device that writes SVG), in a box, with why (video_unavailable_text() in R/spec.R).
video_note <- function() {
  why = video_unavailable_text()
  if (is.null(why)) tags$p(class = "text-muted small", "Charts can be animated: the Animate button on a chart draws its frames, and the card (and an exported dashboard) plays them in the browser.")
  else warn_box(why)
}

# Said once on Start here when this machine cannot draw in a bundled typeface (www/fonts/ missing, or systemfonts
#   not installed): the charts are drawn in the default fonts instead. Nothing when both are there.
fonts_note <- function() {
  missing = chart_fonts_missing()
  if (!length(missing)) return(NULL)
  many = length(missing) > 1L
  warn_box(paste0("The typeface", if (many) "s ", if (!many) " ", if (many) paste0(paste(utils::head(missing, -1L), collapse = ", "), " and ", utils::tail(missing, 1L)) else missing, if (many) " are" else " is",
                  " not available here, so charts are drawn in the default ", paste(unique(purrr::map_chr(CHART_FONTS[names(missing)], "fallback")), collapse = " and "), " font", if (many) "s", "."))
}

# Said once on Start here about the office's ggplot theme (APP_THEME_FILE in app.R): why it is not used, a font it names that is
#   missing here, or colours of it that fail the contrast checks; a warning, never an error. Nothing when no theme is set or all is well.
theme_note <- function(notes = if (exists("APP_THEME_NOTES", envir = globalenv())) get("APP_THEME_NOTES", envir = globalenv()) else character(0)) {
  if (!length(notes)) return(NULL)
  tagList(purrr::map(notes, warn_box))
}

# Said once on Start here about the design skills that could not be used (a file over 120 lines, one with no Intent), or a skills folder that is not there.
skills_note <- function(notes = skills_notes()) {
  if (!length(notes)) return(NULL)
  tagList(purrr::map(notes, warn_box))
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
          mod_codebook_ui("codebook"),
          tags$hr(),
          tags$h4("Summary statistics"),
          mod_summary_ui("summary"))

# The data file: a delimited file or an Excel workbook, what R found in it, and an optional saved data dictionary. For a workbook the
#   page also shows which sheet, which table when the sheet holds several, and the row the header is on (excel_box()).
mod_data_ui <- function(id) {
  ns = NS(id)
  tagList(
    fileInput(ns("file"), paste0("Data file: CSV or other delimited text, or an Excel workbook (.xlsx, .xls), up to ", APP_MAX_UPLOAD_MB, " MB"),
              accept = c(".csv", ".tsv", ".txt", ".tab", EXCEL_ACCEPT), width = "100%"),
    uiOutput(ns("excel_box")),
    textAreaInput(ns("missing"), "Values that mean missing, one per line", rows = 2, width = "100%",
                  placeholder = "for example: ..\n-99"),
    tags$p(class = "text-muted small", "Blank cells and NA are always missing. Anything else is missing only if you list it here; ",
           "a value must match a whole cell."),
    conditionalPanel("!output.excel_file", ns = ns,
      selectInput(ns("encoding"), "File encoding", choices = encoding_choices(NULL), width = "100%"),
      tags$p(class = "text-muted small", "The encoding is guessed. If names with accents look wrong, choose another and read again: ",
             "windows-1252 for Western European files, ISO-8859-2 for Central European ones.")),
    actionButton(ns("reread"), "Read again", class = "btn-sm mb-3"),
    uiOutput(ns("reread_note")),
    uiOutput(ns("summary")),
    tableOutput(ns("columns")),
    tags$hr(),
    fileInput(ns("codebook"), "Optional: a saved data_dictionary.yaml for this file", accept = c(".yaml", ".yml"), width = "100%"),
    uiOutput(ns("codebook_note")))
}

# What the Data page shows of an Excel workbook, from what read_excel_data() found (`ex`, state$excel): the sheet to read (names and row
#   counts; a hidden sheet named as hidden; for an .xls, a sentence that hidden sheets cannot be told), which table when the sheet holds more
#   than one (none selected until the analyst chooses), and the row the header is on, which R found and the analyst may change.
EXCEL_ACCEPT <- paste0(".", EXCEL_EXTENSIONS)
excel_box <- function(ns, ex) {
  if (is.null(ex)) return(NULL)
  many = nrow(ex$sheets) > 1L
  tagList(tags$div(class = "border rounded p-2 mb-3",
    tags$strong("Excel workbook"),
    if (many) selectInput(ns("sheet"), "Sheet (rows used in each)", choices = excel_sheet_choices(ex$sheets), selected = ex$sheet, width = "100%", selectize = FALSE),
    if (many && !ex$hidden_known) tags$p(class = "text-muted small", "This is an .xls file: it does not say which sheets are hidden, so hidden ones cannot be told and every sheet is listed as it is."),
    if (many && ex$hidden_known && any(ex$sheets$hidden)) tags$p(class = "text-muted small", "Hidden sheets are listed as hidden; you can still read one."),
    if (nrow(ex$tables) > 1L)
      radioButtons(ns("table"), paste0("This sheet holds ", nrow(ex$tables), " tables. Which one?"), choices = excel_table_choices(ex$tables),
                   selected = if (!is.null(ex$table)) as.character(ex$table) else character(0), width = "100%"),
    if (identical(ex$ask, "table")) tags$p(class = "small", style = "color: var(--bs-warning-text-emphasis, #8a5a00);", "No table is read until you choose one."),
    if (!is.null(ex$header)) tagList(
      numericInput(ns("header"), "Header is on row", value = ex$header, min = 1, step = 1, width = "12rem"),
      tags$p(class = "text-muted small", "R takes the first row with text in most columns as the header, and the rows below it as the data. ",
             "Rows are numbered as Excel numbers them. Change the row if R chose wrongly. Blank rows and columns before the table are skipped, ",
             "merged header cells are filled across and joined to the row below, and nothing is written to the workbook."))))
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
    excel_opts = function() isolate(state$excel)$opts   # what was chosen of an Excel workbook (sheet, header, table, numbers), NULL for a delimited file
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
      state$excel = res$read$excel        # kept after an error, so the controls stay to put it right
      state$data = res$read$data          # NULL while the analyst has not said which table of a sheet
      state$problems = res$read$problems
      state$profile = res$profile
      state$codebook = codebook
      invisible(!is.null(res$read$data))
    }
    # An Excel workbook read again with one thing changed (the sheet, the table, the header row).
    excel_again = function(change, keep = TRUE) {
      u = upload()
      if (is.null(u) || is.null(excel_opts())) return()
      res = tryCatch(reread_data(u$path, u$name, parse_missing(input$missing), old = if (keep) isolate(state$codebook), excel = utils::modifyList(excel_opts(), change)),
                     error = function(e) e)
      ok = take(res)
      reread_note(if (ok) advice_box(if (keep) "Read again. Your labels, roles and row sentence are kept for the columns that are still there." else "Read again."))
    }
    observeEvent(input$sheet, if (!is.null(excel_opts()) && !identical(input$sheet, excel_opts()$sheet))
      excel_again(list(sheet = input$sheet, header = NULL, table = NULL, numbers = NULL), keep = FALSE), ignoreInit = TRUE)
    observeEvent(input$table, if (!is.null(excel_opts()) && !identical(as.integer(input$table), excel_opts()$table))
      excel_again(list(table = as.integer(input$table), header = NULL, numbers = NULL), keep = FALSE), ignoreInit = TRUE)
    observeEvent(input$header, {
      h = input$header
      if (!is.null(excel_opts()) && is.numeric(h) && !is.na(h) && !identical(as.integer(h), isolate(state$excel)$header))
        excel_again(list(header = as.integer(h), numbers = NULL))
    }, ignoreInit = TRUE)
    output$excel_box = renderUI(excel_box(session$ns, state$excel))
    output$excel_file = renderText(if (!is.null(state$excel)) "yes" else "")
    outputOptions(output, "excel_file", suspendWhenHidden = FALSE)

    observeEvent(input$file, {
      f = input$file
      upload(list(path = f$datapath, name = f$name))
      codebook_note(NULL); reread_note(NULL); detected(NULL)
      state$excel = NULL
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
      res = tryCatch(reread_data(u$path, u$name, parse_missing(input$missing), old = state$codebook, encoding = enc, excel = excel_opts()),
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
      res = tryCatch(reread_data(u$path, u$name, codes, encoding = up$encoding, excel = excel_opts()), error = function(e) e)
      if (inherits(res, "error")) return(codebook_note(warn_box(conditionMessage(res))))
      if (is.null(res$read$data)) return(codebook_note(warn_box("Choose which table of the sheet to read first, then the data dictionary.")))
      why = check_codebook(up, res$profile)
      if (length(why))
        return(codebook_note(warn_box(tags$strong("The data dictionary was not applied."), tags$ul(purrr::map(why, tags$li)))))
      take(res, apply_codebook(up, res$profile, u$name, nrow(res$read$data), res$read$encoding, res$read$excel))
      updateTextAreaInput(session, "missing", value = paste(codes, collapse = "\n"))
      show_encoding(res, up$encoding)
      reread_note(NULL)
      codebook_note(advice_box("The data dictionary was applied: its values that mean missing, encoding, labels, types, roles and row ",
                               "sentence are in use; every fact comes from the file."))
    })

    output$codebook_note = renderUI(codebook_note())

    output$summary = renderUI({
      if (!is.null(read_error())) return(warn_box(read_error()))
      if (is.null(state$data)) return(if (identical(state$excel$ask, "table") && length(state$problems)) warn_box(tags$ul(purrr::map(state$problems, tags$li))))
      tagList(
        tags$p(tags$strong(paste0(state$codebook$file, if (is_text1(state$codebook$sheet)) paste0(", sheet ", state$codebook$sheet))),
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



# ---- Summary statistics -----------------------------------------------------------------------------------------------------
#   The numbers are R's (summary_table() in R/data.R) and are drawn in the browser as plain HTML tables in three places: the Data
#   page, a table card on the canvas, and the exported dashboard and codebook. They are never sent to a model: a table card is not in
#   the CANVAS, SELECTED or LAST EXCHANGE of a chat message (the cards of the canvas that the chat sees are the charts), and the chat
#   reads no number of it. No model call is made by anything here.

# A message that only asks for a summary table: "summary statistics", "summary table", "describe the columns", with at most a polite
#   word or two around them. Anything more (a column, a question) is the analyst's own and goes on to the model.
SUMMARY_REQUEST_PATTERN <- paste0("^(please )?((can|could) you )?((show|give|make|add|build|create|do) (me )?)?(a |an |the |some )?",
                                  "((summary|descriptive) (statistics|stats|table|tables)|describe (the )?(columns|variables))( please)?$")
summary_request <- function(msg) {
  m = tolower(trimws(gsub("[[:space:]]+", " ", as.character(msg))))
  m = trimws(sub("[.!?]+$", "", m))
  length(m) == 1L && !is.na(m) && grepl(SUMMARY_REQUEST_PATTERN, m, perl = TRUE)
}

# A message that only asks for the selected chart to be animated: "animate", "animate this", "play it", "make it a video", "make a video of this",
#   with at most a polite word or two around it. R answers it with no model call. Plain groups only, so the same pattern runs in the browser's
#   script (the working line says "Drawing the animation" at once).
ANIMATE_PATTERN <- paste0("^(please )?((can|could) you )?(animate( (this|it|that|the chart|this chart))?|play (it|this|that)|",
                          "(make|turn) (it|this|that) (into |in)?a video|(make|create) (me )?a video( of (this|it|that|the chart|this chart))?)( please)?$")
animate_request <- function(msg) {
  m = tolower(trimws(gsub("[[:space:]]+", " ", as.character(msg))))
  m = trimws(sub("[.!?]+$", "", m))
  length(m) == 1L && !is.na(m) && grepl(ANIMATE_PATTERN, m, perl = TRUE)
}
ANIMATE_NONE <- "Click a chart first, then ask me to animate it."

# A message that only asks for the selected chart to be designed: "design this", "redesign this", "make it look better", "make it publication ready", with at
#   most a polite word or two around it. R starts a design with no chat call. Plain groups only, so the same pattern runs in the browser's script.
DESIGN_PATTERN <- paste0("^(please )?((can|could) you )?(please )?(((re)?design|restyle|polish|beautify)( (this|it|that|the chart|this chart|the selected chart))?|",
                         "make (it|this|that|the chart|this chart) (look (better|nicer|great|good|professional|prettier)|publication[- ]ready|publishable|print[- ]ready|better)|",
                         "make (it|this|that|the chart|this chart) ready for (publication|print))( please)?$")
design_request <- function(msg) {
  m = tolower(trimws(gsub("[[:space:]]+", " ", as.character(msg))))
  m = trimws(sub("[.!?]+$", "", m))
  length(m) == 1L && !is.na(m) && grepl(DESIGN_PATTERN, m, perl = TRUE)
}
DESIGN_NONE <- "Click a chart first, then ask me to design it."

# A message that asks for a specific look of the selected chart ("put the legend inside", "make the title bigger", "use a darker background"): a verb of
#   changing a look, a thing that has a look, and none of the words of changing what the chart is made of (its form, columns, groups, filters or numbers). R sends
#   it to the design call as its WISH (no chat call). Anything doubtful is the analyst's own message and goes to the chat as before.
DESIGN_WISH_VERBS <- "\\b(put|move|place|make|use|set|change|remove|hide|add|give|increase|decrease|reduce|enlarge|shrink|turn|drop|lighten|darken|thicken|centre|center|align|rotate|space|widen|narrow|tidy)\\b"
DESIGN_WISH_THINGS <- "\\b(legend|title|subtitle|caption|background|font|typeface|labels?|gridlines?|grid lines?|grid|axis|axes|margins?|spacing|text|annotations?|colou?rs?|border|bars?|lines?|points|dots|headline)\\b"
DESIGN_WISH_NOT <- paste0("\\b(bar chart|line chart|scatter|histogram|heatmap|heat map|box ?plot|violin|dot chart|slope|dumbbell|bubble|pie|facet|panels?|small multiples|",
                          "group(ed)? by|split by|by [a-z_]+|per [a-z_]+|filter|only|exclude|include|top [0-9]+|sort|order|log scale|log axis|percent|share|average|mean|total|sum|count|",
                          "to say|to read|say|reads?|called|named|wording|rename)\\b")
design_wish <- function(msg) {
  m = tolower(trimws(gsub("[[:space:]]+", " ", as.character(msg))))
  length(m) == 1L && !is.na(m) && nchar(m) >= 6L && nchar(m) <= DESIGN_WISH_MAX && !design_request(m) &&
    grepl(DESIGN_WISH_VERBS, m, perl = TRUE) && grepl(DESIGN_WISH_THINGS, m, perl = TRUE) && !grepl(DESIGN_WISH_NOT, m, perl = TRUE)
}

SETUP_SUMMARY <- paste("Choose the columns for the summary table in the dialog. R works the numbers out from the file; no model is asked, and",
                           "nothing of the table is sent to one.")
SUMMARY_PRIVACY <-"Worked out by R from the file and drawn in your browser; no model is asked and nothing here is sent to one."
SUMMARY_NO_MEASURE <- "This file has no column of numbers to summarise as a measure."
SUMMARY_CSS <- "
.stat-block { margin: 0 0 1rem; }
.stat-title { font-weight: 600; margin: 0 0 .25rem; }
.stat-block .table-scroll { overflow-x: auto; max-width: 100%; }
.stat-table { border-collapse: collapse; font-size: .85rem; width: 100%; }
.stat-table th { text-align: left; font-weight: 600; white-space: nowrap; border-bottom: 2px solid currentColor; padding: .25rem .7rem .25rem 0; vertical-align: bottom; }
.stat-table td { padding: .25rem .7rem .25rem 0; border-bottom: 1px solid rgba(128, 128, 128, .35); vertical-align: top; }
.stat-table td.n, .stat-table th.n { text-align: right; white-space: nowrap; }
.stat-table td { white-space: nowrap; }
.stat-notes .stat-note { font-size: .8rem; color: var(--bs-secondary-color, #555); margin: 0 0 .25rem; }
/* a table card has a row to itself in the canvas grid (bslib wraps each card in a grid item) */
.bslib-grid-item:has(.chart-table-card) { grid-column: 1 / -1; }
"

# The summary tables as plain HTML (one for each kind of column, each scrolling sideways inside its own box when it is wider than its
#   place), then the lines under them (summary_notes()). `tb` is summary_table()'s tibble; `ci` whether the intervals are shown. A
#   file's own words (a column name, a label, a level) are text in the tags, so none can be markup.
summary_tag <- function(tb, ci = TRUE) {
  blocks = summary_blocks(tb, ci)
  tagList(
    purrr::map(blocks, function(b) {
      cols = seq_along(b$table)
      tags$div(class = "stat-block",
        if (length(blocks) > 1L) tags$p(class = "stat-title", b$title),
        tags$div(class = "table-scroll", role = "region", tabindex = "0", `aria-label` = b$title,
          tags$table(class = "stat-table",
            tags$thead(tags$tr(purrr::map(cols, function(j) tags$th(scope = "col", class = if (b$right[[j]]) "n", names(b$table)[[j]])))),
            tags$tbody(purrr::map(seq_len(nrow(b$table)), function(i)
              tags$tr(purrr::map(cols, function(j) tags$td(class = if (b$right[[j]]) "n", b$table[[j]][[i]]))))))))
    }),
    tags$div(class = "stat-notes", purrr::map(summary_notes(tb, ci), function(n) tags$p(class = "stat-note", n))))
}

# The columns a summary table can be taken as a measure (a number, a whole number that is not a time) and the columns it can be taken by
#   (a group-like column of at most CODEBOOK_MAX_LEVELS levels), as named choices for a select: the label (the name) is the choice's
#   name, the column name its value.
summary_choice <- function(e) if (is_text1(e$label) && nzchar(trimws(e$label)) && !identical(e$label, e$name)) paste0(e$label, " (", e$name, ")") else e$name
summary_measure_choices <- function(cb, data) {
  ok = purrr::keep(cb$columns, function(e) e$name %in% names(data) && identical(summary_kind(e, data[[e$name]]), "measure"))
  stats::setNames(purrr::map_chr(ok, "name"), purrr::map_chr(ok, summary_choice))
}
summary_by_choices <- function(cb, data) {
  ok = purrr::keep(cb$columns, function(e) e$name %in% names(data) && identical(summary_kind(e, data[[e$name]]), "group") &&
                     length(unique(data[[e$name]][!is.na(data[[e$name]])])) <= CODEBOOK_MAX_LEVELS)
  c(None = "", stats::setNames(purrr::map_chr(ok, "name"), purrr::map_chr(ok, summary_choice)))
}

# A table's title when the analyst types none: the measures' labels (the first three), then "by" and the group's label.
summary_title <- function(measures, by, cb) {
  lab = function(n) { e = purrr::detect(cb$columns, function(c) identical(c$name, n)); if (is.null(e)) n else if (is_text1(e$label) && nzchar(trimws(e$label))) trimws(e$label) else n }
  shown = purrr::map_chr(utils::head(measures, 3L), lab)
  paste0("Summary statistics: ", paste(shown, collapse = ", "), if (length(measures) > 3L) paste0(" and ", length(measures) - 3L, " more"),
         if (is_text1(by) && nzchar(by)) paste0(", by ", lab(by)))
}

# The Data page's section: the summary of every column of the file read, shown once a file is read (it does not wait for labels), with a
#   select for the group, the switch for the intervals and the CSV. The controls are fixed and the select is refilled when the
#   groups change, so nothing the analyst chose is lost while the dictionary is edited.
mod_summary_ui <- function(id) {
  ns = NS(id)
  tagList(
    conditionalPanel("!output.has_data", ns = ns, tags$p(class = "text-muted", "Read a data file above first.")),
    conditionalPanel("output.has_data", ns = ns,
      tags$style(HTML(SUMMARY_CSS)),
      tags$p(class = "text-muted small", "Statistics of every column of the file. ", SUMMARY_PRIVACY),
      tags$div(class = "d-flex flex-wrap align-items-end gap-3 mb-2",
               tags$div(style = "min-width: 14rem;", selectInput(ns("by"), "By group", choices = c(None = ""), selectize = FALSE, width = "100%")),
               tags$div(class = "mb-3", bslib::input_switch(ns("ci"), "Show 95% CI", value = TRUE)),
               tags$div(class = "mb-3", downloadButton(ns("download"), "Download CSV", class = "btn-sm btn-outline-secondary"))),
      uiOutput(ns("table"))))
}

mod_summary_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    # "yes" when a file is read, else empty: the page shows the section on it (conditionalPanel reads it as true or false)
    output$has_data = renderText(if (!is.null(state$data) && !is.null(state$codebook)) "yes" else "")
    outputOptions(output, "has_data", suspendWhenHidden = FALSE)

    # The select holds the group-like columns; it is filled again only when that set changes, and keeps its choice while it can.
    choices = reactive({
      if (is.null(state$data) || is.null(state$codebook)) return(c(None = ""))
      summary_by_choices(state$codebook, state$data)
    })
    observeEvent(choices(), {
      keep = isolate(input$by) %||% ""
      updateSelectInput(session, "by", choices = choices(), selected = if (keep %in% choices()) keep else "")
    })

    by = reactive({ b = input$by %||% ""; if (nzchar(b) && b %in% choices()) b })
    table = reactive({
      if (is.null(state$data) || is.null(state$codebook)) return(NULL)
      tryCatch(summary_table(state$data, state$codebook, NULL, by()), error = function(e) e)
    })
    show_ci = reactive(!identical(input$ci, FALSE))

    output$table = renderUI({
      tb = table()
      if (is.null(tb)) return(NULL)
      if (inherits(tb, "error")) return(warn_box(conditionMessage(tb)))
      summary_tag(tb, show_ci())
    })
    output$download = downloadHandler(
      filename = function() "summary_statistics.csv",
      content = function(file) {
        tb = table()
        if (is.null(tb) || inherits(tb, "error")) stop("There is no summary to write.", call. = FALSE)
        summary_csv(tb, show_ci(), file)
      })
  })
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
#   address is relative to it), under the names the charts use: the SVG of an interactive chart and the page then draw in
#   the same faces as the static charts. "<family> SemiBold" is the semibold file as its regular face.
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
         "\" font-family=\"", title_fam, "\" fill=\"", st$text, "\">", chart_title_case("Title", style), "</text>",
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

# The headline a chart shows (Phase 13), and who wrote it: the analyst's own (st$headline_by "analyst": typed on the card or in Edit text) as written;
#   else the model's, when it passed the number and word checks and the limits (and, when the chart or its data has changed since it was written, `stale`,
#   the manager's ruling: when it passes them again against the chart's facts now, r_head$facts); else R's (`r_head`, r_headline()), or R's fallback when
#   it could not write one. `note` says why R's is shown in place of the model's. Returns list(text, by, note); by is "analyst", "model", "r" or "fallback".
headline_shown <- function(st, r_head, stale = NA_character_) {
  r = list(text = r_head$text, by = if (identical(r_head$source, "r")) "r" else "fallback", note = NULL)
  if (is.null(st) || !is_text1(st$headline) || !nzchar(trimws(st$headline))) return(r)
  if (identical(st$headline_by, "analyst")) return(list(text = trimws(st$headline), by = "analyst", note = NULL))
  # checked against the facts it was written from; a story kept without them stands on the problems found when it was written
  passed = if (is_text1(st$facts) && nzchar(st$facts)) summary_ok(summary_problems(st$headline, NULL, st$facts, st$spec)) else !length(st$problems)
  if (passed && !is.na(stale)) {
    now = r_head$facts
    held = !is.null(now) && summary_ok(summary_problems(st$headline, NULL, names_back(now$text, now$names), r_head$spec %||% st$spec))
    if (!held) { r$note = HEADLINE_MODEL_CHANGED; return(r) }
  }
  if (passed) return(list(text = trimws(st$headline), by = "model", note = NULL))
  r$note = HEADLINE_MODEL_FAILED
  r
}
HEADLINE_BY_TEXT <- c(r = "Headline written by R from the chart's facts.", model = "Headline written by the model and checked against the chart's facts.",
                      analyst = "Your own headline: kept as you wrote it, and not checked by chaRt.",
                      fallback = "R could not write a headline from this chart's facts, so the title says what is plotted.")
HEADLINE_MODEL_FAILED <- "The model's headline did not pass its checks, so R's is shown."
HEADLINE_MODEL_CHANGED <- "The chart has changed and the model's headline no longer passes its checks against it, so R's is shown."

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
TELL_WARNING_CHART <- "Not every number here is in this chart's facts: "

# Text from a model or a file, made safe for a chat message. shinychat 0.4.0 draws an assistant message as markdown
#   with raw HTML switched on and no sanitiser (see the note above say() in mod_explore_server()), so anything that is
#   not R's own wording passes through here first: every ASCII punctuation mark gets a backslash (the one escape
#   CommonMark gives them all, so no emphasis, link, image, code, list, heading or table can start), and "&", "<" and ">"
#   become entities (so no tag or entity can start). The reader sees the text as it was.
#   Nothing may become a link either. GFM turns http://, https://, www. and e-mail addresses into links by itself. The
#   backslash on ":" and "." stops the first three in cmark-gfm (R's commonmark with extensions) but NOT in shinychat's
#   browser code (remark): it undoes the escapes and then links the text that is left, in a chat message and in a suggestion
#   card alike (seen in the browser, Phase 8 Part C). An address with "@" is found the same way, and no escape or entity
#   stops that. So the one mark that completes an address is also written as a <span>: the ":" after "http" or "https", the
#   "." after "www", and the "@". The text on either side of a span is not one text, so no address is found in it, and the
#   reader sees and copies the plain character; no zero-width or other hidden character is added.
md_text <- function(x) {
  escaped = htmltools::htmlEscape(gsub("([!\"#$%'()*+,./:;=?\\[\\\\\\]^_`{|}~-])", "\\\\\\1", as.character(x), perl = TRUE))
  gsub("@", "<span>@</span>", gsub("(?i)(https?|www)(\\\\[:.])", "\\1<span>\\2</span>", escaped, perl = TRUE), fixed = TRUE)
}

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
          if (identical(r$kind, "tell") && length(r$problems)) paste0(if (isTRUE(r$facts_used)) TELL_WARNING_CHART else TELL_WARNING, md_text(paste(r$problems, collapse = ", ")), ".")),
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
# The same for a column of an Excel sheet that holds only numbers stored as text: a button reads it as numbers.
numbers_text <- function(col) paste0("Read '", col, "' as numbers")
NUMBERS_PATTERN <- "^Read '(.*)' as numbers$"
row_text <- function(guess) paste0("A row is ", guess)

# A chart's title for the chat and the screen reader, or `fallback` when it has none.
chart_title <- function(chart, fallback = "this chart") {
  t = chart$spec$title
  if (is_text1(t) && nzchar(trimws(t))) trimws(t) else fallback
}

# The key numbers of the canvas, in the strip that stands where three value boxes did (Phase 10 Part D): plain statements from the data, no
#   model call: "Rows" over "3,000", "Columns" over "22" and "Period" over the period of the first column with the time role ("Jan 2022 to Dec 2024"), else the file name.
#   The same strip, in the page's own stylesheet, heads the exported dashboard (dash_keys_tag()).
canvas_boxes <- function(data, cb) {
  v = canvas_box_values(data, cb)
  keys = purrr::map(unname(v), function(b) list(label = b$label, value = b$value, full = b$full, what = NULL, cls = b$cls))
  dash_keys_tag(keys, class = "chart-keys")
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
  paste0("if (event.target.closest('button, a, input, select, textarea, label, video, .girafe, .bslib-full-screen-enter, .chart-editable, .chart-drag')) return; ",
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
                   label = "Labelling columns", setup = "Working", dashboard = "Building the dashboard", animate = "Drawing the animation", design = "Designing")
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
/* the cards of a row are as high as each other: the grid cell (a flex box) is as high as the row, and the card grows to fill it */
.chart-canvas .bslib-grid-item .chart-card { flex: 1 1 auto; }

.chart-card .card-body { display: flex; flex-direction: column; }

.chart-card .chart-slot { flex: 1 1 auto; display: flex; flex-direction: column; justify-content: center; min-width: 0; }
.chart-upper { text-transform: uppercase; letter-spacing: .005em; }
.chart-upper .keep { text-transform: none; }
.chart-heading { font-size: 1.1rem; line-height: 1.2; }
.chart-card-sub { margin-top: .15rem; }
.chart-summary { font-size: 1.05rem; line-height: 1.55; max-width: 62ch; }
.chart-notes { font-size: .82rem; max-width: 75ch; }
/* The key numbers at the top of the canvas: a strip, a number large over its words, a thin rule between the items, no boxes (the same markup as the
   exported page's strip). A number never wraps or is cut: its type shrinks to its cell (container query units, --w its width in ems) and a cell has a
   least width, so the strip goes to a second row before the type gets small. */
.chart-keys { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 10.5rem), 1fr)); overflow: hidden; margin-bottom: 1rem;
              border-top: 1px solid var(--bs-border-color); border-bottom: 1px solid var(--bs-border-color); }
.chart-keys .key { min-width: 0; margin-left: -1px; padding: .7rem 1rem .75rem; border-left: 1px solid var(--bs-border-color); }
.chart-keys { align-items: start; }
.chart-keys .key-label { color: var(--bs-secondary-color); font-variant-caps: all-small-caps; letter-spacing: .06em; font-size: .95rem; line-height: 1.3; margin-bottom: .1rem;
                         white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.chart-keys .key-value { --max: 1.9rem; font-size: var(--max); font-weight: 700; line-height: 1.1; overflow-wrap: break-word; text-wrap: balance; }
.chart-keys .key-value.num { white-space: nowrap; }
.chart-keys .key-what { color: var(--bs-secondary-color); font-size: .85rem; line-height: 1.3; margin-top: .3rem; overflow-wrap: anywhere; }
@supports (width: 1cqi) { .chart-keys .key { container-type: inline-size; } .chart-keys .key-value { font-size: min(var(--max), calc(100cqi / var(--w))); } }
.chart-keys .key-value.chart-box-file { display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%; }

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
/* Phase 11 Part E: the handle a card is dragged by, the line that shows where it will land, text edited where it stands, and a section's heading */
.chart-drag { display: inline-block; cursor: grab; user-select: none; padding: 0 .4rem; color: var(--bs-secondary-color); font-weight: 700; letter-spacing: -.2em; line-height: 1.6; }
.chart-drag:hover { color: var(--bs-body-color); }
.chart-dragging { opacity: .45; }
.chart-drop-before { box-shadow: 0 -5px 0 0 var(--bs-primary-text-emphasis, #0d6efd); }
.chart-drop-after { box-shadow: 0 5px 0 0 var(--bs-primary-text-emphasis, #0d6efd); }
.chart-editable { cursor: text; }
.chart-editable:hover, .chart-editable:focus-visible { outline: 1px dashed var(--bs-secondary-color); outline-offset: 2px; }
.chart-marked { text-decoration: underline wavy var(--bs-warning-text-emphasis, #8a5a00); text-underline-offset: .25em; }
.chart-inline-input { width: 100%; min-width: 12rem; }
.chart-card .card-header > .chart-edit-wide, .chart-card .card-header > div:first-child { width: 100%; }
/* the export dialog's rows: left out is dimmed, and says why (kept true to the switches by the page's script) */
[data-dash-row] .dash-why, [data-dash-row] .dash-all-off { display: none; }
[data-dash-row].dash-off .dash-body { opacity: .55; }
[data-dash-row].dash-sec-off .dash-why { display: block; }
[data-dash-row].dash-off .dash-all-off { display: block; }
.chart-section { border-top: 3px solid var(--bs-primary-text-emphasis, #0d6efd); padding-top: .5rem; }
.chart-section-title { font-size: 1.35rem; line-height: 1.2; margin: 0; overflow-wrap: anywhere; }
.chart-section-text { margin: .25rem 0 0; max-width: 75ch; overflow-wrap: anywhere; }
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
  function progress(words) {
    var el = line();
    var lab = el && el.querySelector('.chart-working-words');
    if (!lab || el.hidden) return;
    if (timer) { clearTimeout(timer); timer = null; }
    lab.textContent = words;
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
    if (new RegExp(", jsonlite::toJSON(ANIMATE_PATTERN, auto_unbox = TRUE), ", 'i').test(text.trim().replace(/[.!?]+$/, ''))) return WORDS.animate;
    if (new RegExp(", jsonlite::toJSON(DESIGN_PATTERN, auto_unbox = TRUE), ", 'i').test(text.trim().replace(/[.!?]+$/, ''))) return WORDS.design;
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
    Shiny.addCustomMessageHandler('chart-progress', function (m) { progress(m.words); });
  }
  // Phase 11 Part E. Dragging: a card, a table or a section is picked up by its handle (class chart-drag) and put down on another card; the
  //   server is told which and whether it lands before or after (the lower right half of the target is after). Plain drag events, no package:
  //   the Move up and Move down buttons do the same from the keyboard.
  var dragging = null;
  function mark(el, cls) {
    document.querySelectorAll('.chart-drop-before, .chart-drop-after').forEach(function (x) { x.classList.remove('chart-drop-before', 'chart-drop-after'); });
    if (el) el.classList.add(cls);
  }
  function over(e) {
    var t = dragging && e.target.closest ? e.target.closest('[data-canvas-id]') : null;
    if (!t || t.getAttribute('data-canvas-id') === dragging) return null;
    var r = t.getBoundingClientRect();
    return { el: t, after: ((e.clientX - r.left) / r.width + (e.clientY - r.top) / r.height) > 1 };
  }
  document.addEventListener('dragstart', function (e) {
    var h = e.target.closest && e.target.closest('.chart-drag');
    var card = h && h.closest('[data-canvas-id]');
    if (!card) return;
    dragging = card.getAttribute('data-canvas-id');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', dragging);
    if (e.dataTransfer.setDragImage) e.dataTransfer.setDragImage(card, 16, 16);
    setTimeout(function () { card.classList.add('chart-dragging'); }, 0);
  });
  document.addEventListener('dragover', function (e) {
    var o = over(e);
    if (!o) return;
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    mark(o.el, o.after ? 'chart-drop-after' : 'chart-drop-before');
  });
  document.addEventListener('drop', function (e) {
    var o = over(e);
    var canvas = o && o.el.closest('.chart-canvas');
    if (!o || !canvas) return;
    e.preventDefault();
    Shiny.setInputValue(canvas.getAttribute('data-drop-input'),
      { id: dragging, target: o.el.getAttribute('data-canvas-id'), after: o.after, t: Date.now() }, { priority: 'event' });
  });
  document.addEventListener('dragend', function () {
    dragging = null;
    mark(null);
    document.querySelectorAll('.chart-dragging').forEach(function (x) { x.classList.remove('chart-dragging'); });
  });
  // Editing where the text stands: a click (or Enter on the focused text) puts a box in its place; Enter keeps the edit (the server is told), Escape
  //   leaves it, and so does nothing changed. Leaving the box by a click elsewhere keeps the edit. Shift+Enter is a new line in a summary.
  function editStart(el) {
    var next = el.nextElementSibling;
    if (next && next.classList.contains('chart-inline-input')) return;
    var multi = el.getAttribute('data-multiline') === '1';
    var input = document.createElement(multi ? 'textarea' : 'input');
    if (!multi) input.type = 'text'; else input.rows = 4;
    input.className = 'form-control form-control-sm chart-inline-input';
    var original = el.getAttribute('data-empty') === '1' ? '' : el.textContent.trim();
    input.value = original;
    input.setAttribute('aria-label', 'Edit the ' + (el.getAttribute('data-label') || 'text') + '. Enter keeps it, Escape leaves it.');
    var done = false;
    function finish(keep) {
      if (done) return;
      done = true;
      var v = input.value;
      input.remove();
      el.hidden = false;
      if (keep && v !== original)
        Shiny.setInputValue(el.getAttribute('data-input'), { field: el.getAttribute('data-field'), value: v, t: Date.now() }, { priority: 'event' });
    }
    input.addEventListener('keydown', function (e) {
      e.stopPropagation();
      if (e.key === 'Escape') { e.preventDefault(); finish(false); }
      else if (e.key === 'Enter' && !(multi && e.shiftKey)) { e.preventDefault(); finish(true); }
    });
    input.addEventListener('blur', function () { finish(true); });
    el.hidden = true;
    el.parentNode.insertBefore(input, el.nextSibling);
    input.focus();
    input.select();
  }
  document.addEventListener('click', function (e) {
    var el = e.target.closest && e.target.closest('.chart-editable');
    if (el) editStart(el);
  });
  // The export dialog: a row is dimmed when its switch is off or its section's is, as the switches are flipped.
  document.addEventListener('change', function (e) {
    if (!e.target || !e.target.id || e.target.id.indexOf('dash_in_') < 0) return;
    var rows = document.querySelectorAll('[data-dash-row]');
    var off = {};
    rows.forEach(function (r) {
      var sw = r.querySelector('input[id*=dash_in_]');
      if (r.hasAttribute('data-dash-section-row') && sw) off[r.getAttribute('data-dash-row')] = !sw.checked;
    });
    rows.forEach(function (r) {
      var sw = r.querySelector('input[id*=dash_in_]');
      var sec =r.getAttribute('data-dash-in');
      var via = !!(sec && off[sec]);
      r.classList.toggle('dash-off', !!(sw && !sw.checked) || via);
      r.classList.toggle('dash-sec-off', via);
    });
  });
  document.addEventListener('keydown', function (e) {
    var el = e.target.classList && e.target.classList.contains('chart-editable') ? e.target : null;
    if (el && (e.key === 'Enter' || e.key === ' ')) { e.preventDefault(); editStart(el); }
  });
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
    tags$div(class = "chart-canvas", `data-drop-input` = ns("canvas_move"),
             uiOutput(ns("gate")), uiOutput(ns("boxes")), uiOutput(ns("bar")), uiOutput(ns("cards")), uiOutput(ns("foot"))),
    tags$style(HTML(EXPLORE_CSS)),
    tags$style(HTML(SUMMARY_CSS)),
    tags$script(HTML(EXPLORE_JS)),
    tags$style(HTML(DASH_VIDEO_CSS)),   # the player of an animated chart on a card (Phase 12), the page's own
    tags$script(HTML(MOTION_JS)))
}

# ask is the function that asks the model (llm_json, or a stand-in in a test); build is the function that builds the dashboard zip
#   (build_dashboard, or a stand-in in a test).
mod_explore_server <- function(id, state, ask = llm_json, build = build_dashboard) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    rule_labels = reflex_labels()
    selected = reactiveVal(NULL)       # the id of the selected chart, or NULL
    last = reactiveVal(NULL)           # the analyst's last message and the model's reply text to it, and nothing else
    busy = reactiveVal(FALSE)          # TRUE while a call to the model runs
    palette = reactiveVal(chart_palette_default())
    skills = skills_load()             # the design skills found (www/skills/ and APP_SKILLS_DIR), read once; an office skill's text stays in this list
    dopts = reactiveValues(skill = skill_default(skills), auto = FALSE)   # the skill chosen in the Style dialog, and whether new charts are designed at once
    treat = reactiveVal(character(0))  # the values the chat offers to treat as missing
    numbers_offer = reactiveVal(character(0))   # the columns of an Excel sheet the chat offers to read as numbers (they are stored as text)
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
    made$dash = new.env()              # per chart: whether it is in the dashboard (a reactiveVal, TRUE when the card is made)
    made$video = new.env()             # per chart: its motion (a reactiveVal: NULL, or list(key, frames_json, last, px, ...) of dash_motion_of()); the key is what it was drawn from
    made$showv = new.env()             #   and whether the card shows it in place of the picture (a reactiveVal)
    made$design = new.env()            # per chart: its design (a reactiveVal: NULL, or what design_chart() made, with the key it was made from and its plot)
    made$showd = new.env()             #   whether the card shows the designed drawing (a reactiveVal), and the one line that says why a design was not used or was dropped
    made$dnote = new.env()
    made$dwidget = new.env()           #   and the designed drawing with tooltips (a reactive), which is empty, with a reason, when its layers cannot have them
    session$onSessionEnded(function() purrr::walk(ls(made$design), function(i) { dz = shiny::isolate(made$design[[i]]()); if (!is.null(dz)) unlink(dz$file) }))
    made$thumbs = new.env()            # the small pictures of the export dialog, by chart spec, palette and data
    made$tn = 0L                       # summary tables made, for their ids (t1, t2, ...)
    made$table = new.env()             # per table: its definition (title, measures, by, ci), a reactiveVal; a table's switch for the dashboard is in made$dash
    made$tbl = new.env()               #   and the numbers worked out for it (summary_table(), or the error), a reactive, so a new palette does not work them again
    made$sn = 0L                       # sections made, for their ids (s1, s2, ...); a section is a heading card on the canvas, its definition in state$sections
    made$section = new.env()           # per section: its definition (title, text, collapsed), a reactiveVal; a section's switch for the dashboard is in made$dash
    made$facts = new.env()             # per chart: its facts as the checks of the Edit text dialog and of the in-place edits read them (a reactive)
    made$edited = new.env()            # per chart: the title last edited in place (a reactiveVal: NULL or list(text)), so that a title which fails the checks is marked
    made$rhead = new.env()             # per chart: the headline R writes from its facts (Phase 13; a reactive: r_headline())
    made$shown = new.env()             # per chart: the headline the card shows and who wrote it (a reactive: headline_shown())
    made$drawn = new.env()             # per chart: the card's drawing, with no title block (a reactive; the check of the manager's ruling reads it)
    dash_on = reactiveVal(0L)          # counts the switches flipped in the export dialog, so that its warnings are drawn again
    table_msg = reactiveVal(NULL)      # what the Add a summary table dialog says when it cannot add (no measure chosen)
    dash_result = reactiveVal(NULL)    # what the last build of the dashboard gave, or the error it met
    dash_gen = reactiveVal(0L)         # counts builds and openings, so the dialog's button area is drawn again
    dash_fields = reactiveValues()     # what the analyst typed in the dialog, kept for the next time it opens

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
    # Whether a chart is in the dashboard: the card's "In dashboard" switch, made with the chart, on until it is turned off.
    in_dash = function(chart_id) !is.null(made$dash[[chart_id]]) && isTRUE(made$dash[[chart_id]]())
    # A summary table is a card on the canvas with an id of its own (t1, t2, ...), in the canvas order; its definition is in state$tables.
    #   The canvas ids that are charts are what the chat, the headlines and the redraws work on; a table is none of them, so what the
    #   model is sent never holds a table (nor its id or title).
    table_of = function(id) (isolate(state$tables) %||% list())[[id]]
    chart_ids = function() purrr::keep(isolate(state$canvas), function(i) !is.null(chart_of(i)))
    # One place up or down in the canvas, which is the order of the dashboard; the first cannot go up nor the last down.
    move_chart = function(chart_id, by) {
      ids = isolate(state$canvas)
      # A section moves with its cards, past the section (or the cards before the first heading) next to it.
      if (chart_id %in% section_ids()) return(invisible(state$canvas <- canvas_move_block(ids, section_ids(), chart_id, by)))
      at = match(chart_id, ids)
      to = at + by
      if (is.na(at) || to < 1L || to > length(ids)) return(invisible())
      ids[c(at, to)] = ids[c(to, at)]
      state$canvas = ids
    }
    # Sections (Phase 11 Part E): a heading card on the canvas, a title and a line of text. The cards under it, up to the next heading, belong to it. Its
    #   definition (id, title, text, collapsed) is in state$sections; the canvas order holds its id among the cards' ids.
    section_of = function(id) (isolate(state$sections) %||% list())[[id]]
    section_ids = function() names(isolate(state$sections) %||% list())
    set_section = function(id, def) {
      ss = isolate(state$sections) %||% list()
      ss[[id]] = def
      state$sections = ss
      if (!is.null(made$section[[id]])) made$section[[id]](def)
    }
    section_info = function(id) { d = section_of(id); list(id = id, title = d$title, text = d$text) }
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

    # Removing a summary table takes its card off the canvas and its definition out of the state.
    remove_table = function(table_id) {
      ts = isolate(state$tables) %||% list(); ts[[table_id]] = NULL; state$tables = ts
      state$canvas = setdiff(isolate(state$canvas), table_id)
    }

    # Removing a section takes its heading off the canvas; its cards stay, under the section before it (or under none).
    remove_section = function(section_id) {
      ss = isolate(state$sections) %||% list(); ss[[section_id]] = NULL; state$sections = ss
      state$canvas = setdiff(isolate(state$canvas), section_id)
    }

    # "Add a section": a heading card, before the selected chart when one is selected, else at the top of the canvas.
    add_section = function() {
      made$sn = made$sn + 1L
      id = paste0("s", made$sn)
      set_section(id, list(id = id, title = SECTION_TITLE_DEFAULT, text = "", collapsed = FALSE))
      make_section(id)
      ids = isolate(state$canvas)
      sel = isolate(selected())
      at = if (is_text1(sel)) match(sel, ids) else NA_integer_
      state$canvas = if (is.na(at)) c(id, ids) else append(ids, id, after = at - 1L)
      invisible(id)
    }

    # Text edited where it stands (a card's headline, title or summary, a table's or a section's title, a section's text): `v` is what the page sent,
    #   list(field, value). A headline or summary is kept and checked as the Edit text dialog checks it (numbers and words against the chart's facts; a text that
    #   fails is kept, marked, and the line under it says why); a title is the chart's title (Undo undoes it) and is checked the same way when the card is drawn.
    #   A blank headline is not kept. No model is asked.
    edit_in_place = function(id, v) {
      if (!is.list(v) || !is_text1(v$field) || !is.character(v$value) || length(v$value) != 1L || is.na(v$value)) return(invisible())
      value = trimws(v$value)
      field = v$field
      if (!is.null(section_of(id))) {
        def = section_of(id)
        if (identical(field, "title")) def$title = if (nzchar(value)) value else SECTION_TITLE_DEFAULT
        else if (identical(field, "text")) def$text = value
        else return(invisible())
        return(invisible(set_section(id, def)))
      }
      if (!is.null(table_of(id))) {
        def = table_of(id)
        if (!identical(field, "title")) return(invisible())
        def$title = if (nzchar(value)) value else summary_title(def$measures, def$by, isolate(state$codebook))
        ts = isolate(state$tables); ts[[id]] = def; state$tables = ts
        return(invisible(made$table[[id]](def)))
      }
      ch = chart_of(id)
      if (is.null(ch)) return(invisible())
      if (field %in% c("headline", "summary")) {
        st = story_of(id) %||% analyst_story(id)
        if (is.null(st) || !nzchar(value) || identical(st[[field]], value)) return(invisible())
        st[[field]] = value
        if (identical(field, "headline")) st$headline_by = "analyst"
        return(invisible(set_story(id, recheck_story(st))))
      }
      if (!identical(field, "title")) return(invisible())
      spec = ch$spec
      spec$title = if (nzchar(value)) value
      made$edited[[id]](list(text = if (nzchar(value)) value))
      if (!identical(spec, ch$spec)) set_chart(chart_apply(ch, spec, notes_for(spec)))
      invisible()
    }

    # A story for a chart that has none, to hold a headline the analyst types (Phase 13): no summary, the chart's facts and spec as they are now.
    analyst_story = function(id) {
      ch = chart_of(id)
      x = if (!is.null(ch)) tryCatch(summary_input(ch, isolate(state$codebook), isolate(state$data), isolate(palette())), error = function(e) NULL)
      if (is.null(x) || !is.null(x$error)) return(NULL)
      list(headline = NULL, summary = NULL, hash = spec_hash(ch$spec), data = isolate(data_key()), facts = names_back(x$facts$text, x$facts$names),
           spec = ch$spec, problems = character(0), headline_by = "analyst")
    }
    # A chart named in a message to the analyst (Phase 13): the headline it shows, and the description in brackets.
    chart_name = function(i, fallback = "the chart") {
      ch = chart_of(i)
      if (is.null(ch)) return(fallback)
      h = if (!is.null(made$shown[[i]])) tryCatch(isolate(made$shown[[i]]())$text, error = function(e) NULL)
      d = chart_title(ch, fallback)
      if (is_text1(h) && nzchar(h) && !identical(h, d)) paste0(h, " (", d, ")") else d
    }

    # A card's switch in the export dialog is the card's own "In dashboard" switch: the two are kept the same.
    dash_switch = function(id) observeEvent(input[[paste0("dash_in_", id)]], {
      v = isTRUE(input[[paste0("dash_in_", id)]])
      rv = made$dash[[id]]
      if (!is.null(rv) && !identical(isolate(rv()), v)) {
        rv(v)
        bslib::update_switch(cid(id, "dash"), value = v, session = session)
      }
      dash_on(isolate(dash_on()) + 1L)
    }, ignoreInit = TRUE)

    reset_canvas = function() {
      set_selected(NULL)
      state$charts = list(); state$stories = list(); state$canvas = character(0); state$tables = list(); state$sections = list()
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
                             spec = r$spec, problems = r$problems, headline_by = "model"))
        story_note[[r$id]] = NULL
      })
      out
    }
    story_line = function(out) {
      got = purrr::keep(out$charts, function(r) !is.null(r$headline))
      missed = purrr::keep(out$charts, function(r) is.null(r$headline))
      title_of = function(i) chart_name(i, i)
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
      canvas = unname(purrr::map(chart_ids(), chart_of))     # the charts only: no summary table goes to the model
      r = chat_turn(msg, canvas, isolate(selected()), isolate(state$codebook), isolate(state$data), last = isolate(last()), ask = ask,
                    palette = isolate(palette()))
      state$calls = dplyr::bind_rows(isolate(state$calls), r$calls)
      last(r$last)
      if (identical(r$kind, "spec") && !is.null(r$chart)) set_chart(r$chart)
      new_ids = if (identical(r$kind, "charts")) add_charts(r$charts)
      say(chat_reply_text(r), one_line(r$`next`))
      # "Design new charts automatically" (Style, off by default): each new chart is designed after the reply, one design after another.
      if (isTRUE(isolate(dopts$auto)) && length(new_ids) && !is.null(skill_chosen())) design_many(new_ids)
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
      col = purrr::detect(numbers_offer(), function(w) identical(m, numbers_text(w)))
      if (!is.null(col)) return(function() treat_missing(numbers = col))
      if (grepl(NUMBERS_PATTERN, m, perl = TRUE))
        return(function() say(paste0("No button offers to read '", md_text(sub(NUMBERS_PATTERN, "\\1", m, perl = TRUE)), "' as numbers now: the sheet holds no such column of numbers stored as text, ",
                                     "or it is already read as numbers. Nothing was changed and the model was not asked.")))
      if (grepl(TREAT_PATTERN, m, perl = TRUE))
        return(function() say(paste0("No button offers '", md_text(sub(TREAT_PATTERN, "\\1", m, perl = TRUE)), "' now: the file holds no such value among its numbers, ",
                                     "or it is already treated as missing. Nothing was changed and the model was not asked.")))
      if (identical(m, SETUP_LABEL)) return(if (isTRUE(made$label_offer)) label_now else function()
        say("The Label the columns button is not on offer now: the columns were labelled already, or the data dictionary did not need it. Edit the labels on the Data page, which also has Suggest labels."))
      g = guess()
      if (!is.null(g) && identical(m, row_text(g))) return(function() use_guess(g))
      if (m %in% made$rows_offered) return(function() say("That row guess is not on offer now. Write what one row is on the Data page."))
      # A message that only asks for the selected chart to be animated is answered by R: no model call.
      if (animate_request(m)) return(animate_selected)
      # So is one that only asks for it to be designed, and one that asks for a specific look of a selected chart (a wish for the design call).
      if (design_request(m)) return(design_selected)
      if (design_wish(m) && !is.null(selected_chart(unname(purrr::map(chart_ids(), chart_of)), isolate(selected())))) return(function() design_selected(wish = m))
      # A message that only asks for summary statistics is answered by R opening the dialog of the summary table: no model call.
      if (summary_request(m)) return(function() if (isTRUE(open_table_dialog())) say(SETUP_SUMMARY))
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
        todo = purrr::keep(chart_ids(), needs_story)
        if (!length(todo)) say(if (length(chart_ids())) "Every chart on the canvas already has a headline and summary that match it."
                               else "There are no charts on the canvas yet.")
        else say(story_line(write_stories(todo)))
      }
    }))

    # ---- setup: R's own messages --------------------------------------------------------------------

    # Treat a value as missing: the file is read again with it, as the Data page does, and the new read is said.
    #   For an Excel sheet `numbers` names a column of text to read as numbers; the sheet, table and header the analyst chose are kept.
    treat_missing = function(value = NULL, numbers = NULL) {
      cb = isolate(state$codebook)
      path = isolate(state$path)
      if (is.null(cb) || !is_text1(path) || !file.exists(path))
        return(say("The file is no longer there to read again. Choose it again on the Data page."))
      excel = isolate(state$excel)$opts
      if (!is.null(excel) && length(numbers)) excel$numbers = unique(c(excel$numbers, numbers))
      res = tryCatch(reread_data(path, cb$file, unique(c(missing_codes(cb), value)), old = cb, encoding = cb$encoding, excel = excel), error = function(e) e)
      if (inherits(res, "error")) return(say(md_text(conditionMessage(res))))
      same = identical(res$read$data, isolate(state$data))
      made$reread = if (!same) value
      made$reread_numbers = if (!same) numbers
      made$notes = res$notes
      state$data = res$read$data; state$problems = res$read$problems; state$profile = res$profile; state$codebook = res$codebook; state$excel = res$read$excel
      if (same) say(if (is.null(value)) "Nothing changed." else paste0("Nothing changed: no cell is exactly '", md_text(value), "'."))
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
      key = list(file = cb$file, sheet = cb$sheet, columns = names(data))
      fresh = !identical(made$key, key)
      if (fresh && !is.null(made$key)) {
        reset_canvas()
        guess(NULL)
        made$log = list()
        shinychat::chat_clear("chat")
        say(paste0("A different ", if (identical(made$key$file, key$file)) "sheet" else "file", " was read, so the canvas and the conversation start again."))
      }
      if (fresh) { made$ready_for = NULL; made$rows_offered = character(0) }
      made$key = key
      # The same file read again keeps the canvas. When the data changed, the charts are drawn again from it (they read the
      #   data as it is) with their notes made again, and every written headline and summary is stale (story_stale()), as
      #   its numbers may no longer hold.
      dk = data_key()
      changed = !fresh && !identical(made$data_key, dk)
      made$data_key = dk
      if (changed) purrr::walk(chart_ids(), function(i) {
        ch = chart_of(i)
        ch$notes = notes_for(ch$spec)
        set_chart(ch)
      })
      n_texts = if (changed) sum(purrr::map_lgl(chart_ids(), function(i) !is.null(story_of(i)))) else 0L
      # A value on a button must be one line, to sit in the markup of one suggestion.
      words = purrr::discard(missing_candidates(data), function(w) grepl("[\r\n]", w))
      treat(words)
      cols = if (is_text1(cb$sheet)) text_number_columns(data) else character(0)
      numbers_offer(cols)
      again = made$reread
      again_numbers = made$reread_numbers
      made$reread = NULL
      made$reread_numbers = NULL
      problems = state$problems
      say(c(paste0("Read ", md_text(cb$file), if (is_text1(cb$sheet)) paste0(", sheet ", md_text(cb$sheet)),
                   if (!is.null(again)) paste0(" again with '", md_text(again), "' as missing"),
                   if (length(again_numbers)) paste0(" again with ", paste0("'", md_text(again_numbers), "'", collapse = ", "), " read as numbers"),
                   ": ", format_num(nrow(data)), " rows, ", format_num(ncol(data)), " columns."),
            if (length(problems)) paste0("- ", md_text(problems), collapse = "\n") else "No problems found.",
            if (length(made$notes)) paste0("- ", md_text(made$notes), collapse = "\n"),
            if (changed && length(chart_ids()))
              paste0("The data changed, so the ", length(chart_ids()), if (length(chart_ids()) == 1L) " chart on the canvas was" else " charts on the canvas were",
                     " drawn again from it.", if (n_texts) paste0(" ", n_texts, if (n_texts == 1L) " headline and summary is" else " headlines and summaries are",
                                                                  " marked as changed since written, because their numbers may no longer hold. Press Write headlines to write them again.")),
            if (length(words)) "If one of these stands for missing, press it and the file is read again:",
            if (length(cols)) paste0("The sheet stores ", if (length(cols) == 1L) "this column" else "these columns", " of numbers as text: ", paste(md_text(cols), collapse = ", "),
                                     ". To read ", if (length(cols) == 1L) "it" else "one", " as numbers, press its button.")),
          c(if (length(words)) treat_text(words), if (length(cols)) numbers_text(cols)))
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
      cards = state$canvas
      secs = names(state$sections)
      body = setdiff(cards, secs)                                                    # the charts and the tables; a section is a heading, not a card
      n = length(purrr::keep(body, function(i) !is.null(state$charts[[i]])))     # charts; the rest of the canvas is summary tables
      n_tables = length(body) - n
      sel = selected()
      chosen = if (!is.null(sel) && !is.null(made$chart[[sel]])) chart_title(made$chart[[sel]](), sel)
      sec_of = canvas_section_of(cards, secs)
      n_in = sum(purrr::map2_lgl(cards, sec_of, function(i, s) !i %in% secs && in_dash(i) && (is.na(s) || in_dash(s))))
      tags$div(class = "d-flex align-items-center flex-wrap gap-2 my-2",
               actionButton(ns("style"), "Style", class = "btn-sm btn-outline-secondary"),
               tags$span(class = "text-muted small", paste0(format_num(n), if (n == 1L) " chart" else " charts",
                                                            if (n_tables) paste0(", ", format_num(n_tables), if (n_tables == 1L) " table" else " tables"),
                                                            if (length(secs)) paste0(", ", format_num(length(secs)), if (length(secs) == 1L) " section" else " sections"))),
               tags$span(class = "text-muted small chart-in-dashboard", paste0(format_num(n_in), " of ", format_num(length(body)), " in the dashboard")),
               actionButton(ns("add_table"), "Add a summary table", class = "btn-sm btn-outline-secondary"),
               actionButton(ns("add_section"), "Add a section", class = "btn-sm btn-outline-secondary",
                            title = "A heading card; the cards under it, up to the next heading, belong to it. It goes before the selected chart, or at the top."),
               actionButton(ns("design_all"), "Design all", class = "btn-sm btn-outline-primary chart-call", `data-working` = WORKING_WORDS[["design"]],
                            title = "Designs each chart on the canvas that has no current design: two to four model calls for each", disabled = if (is.null(skill_chosen())) NA),
               actionButton(ns("export"), "Export dashboard", class = "btn-sm btn-outline-secondary"),
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

    # What the arrangement of the canvas is, so that the cards are laid out again only when the order, the sections or a collapse change (not when a section's words do).
    canvas_layout = reactive({
      ss = state$sections
      list(ids = state$canvas, secs = names(ss), collapsed = names(purrr::keep(ss, function(d) isTRUE(d$collapsed))))
    })
    # The canvas in blocks: each section's heading and then its cards (two to a row, as before), none shown while the section is collapsed; the cards before the
    #   first heading come first.
    output$cards = renderUI({
      if (!ready()) return(NULL)
      lay = canvas_layout()
      if (!length(lay$ids)) return(tags$p(class = "text-muted", "No charts yet. Ask a question, or press Suggest charts."))
      tagList(purrr::map(canvas_blocks(lay$ids, lay$secs), function(b) {
        head = b[[1]] %in% lay$secs
        cards = if (head) b[-1] else b
        shown = if (head && b[[1]] %in% lay$collapsed) character(0) else cards
        tagList(if (head) uiOutput(ns(cid(b[[1]], "card"))),
                if (length(shown))
                  do.call(bslib::layout_column_wrap, c(list(width = 1 / 2, fill = FALSE, heights_equal = "row"), purrr::map(shown, function(i) uiOutput(ns(cid(i, "card")))))))
      }))
    })
    observeEvent(input$add_section, add_section())
    # A card put down by hand: the page says which card (or section), on which card, before or after.
    observeEvent(input$canvas_move, {
      v = input$canvas_move
      ids = isolate(state$canvas)
      if (!is.list(v) || !is_text1(v$id) || !is_text1(v$target) || !v$id %in% ids || !v$target %in% ids) return()
      state$canvas = canvas_reorder(ids, section_ids(), v$id, v$target, isTRUE(v$after))
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
                                    width = "100%", options = list(render = I(PALETTE_SWATCH_RENDER)))))),
        tags$hr(),
        tags$h6("Design"),
        tags$p(class = "small text-muted", "Design asks the model to draw a chart again, following the skill below; R runs and checks its code, and the chart keeps its standard drawing as the fall-back. ",
               "A design costs two to four model calls: the design, a second if R refuses its drawing, and up to two looks at the picture."),
        if (length(skills_ok(skills)))
          radioButtons(ns("design_skill"), "Design skill", width = "100%", selected = isolate(dopts$skill),
                       choiceNames = unname(purrr::map(skills_ok(skills), function(sk) tags$span(tags$span(class = "chart-style-name", sk$title),
                                                                                                 if (isTRUE(sk$office)) tags$span(class = "badge bg-secondary ms-1", "Office"),
                                                                                                 tags$span(class = "d-block small text-muted", sk$intent)))),
                       choiceValues = names(skills_ok(skills)))
        else tags$p(class = "small", style = warn_style, "No design skill is available."),
        purrr::map(purrr::keep(skills, function(sk) !isTRUE(sk$ok)), function(sk) tags$p(class = "small", style = warn_style, sk$reason)) |> unname(),
        bslib::input_switch(ns("design_auto"), "Design new charts automatically", value = isolate(dopts$auto)),
        tags$p(class = "small text-muted", "Off by default. When on, each chart the chat adds is designed after it is drawn."),
        tags$p(class = "small text-muted", paste(privacy_text(), collapse = " "))))
    })
    observeEvent(input$design_skill, {
      v = input$design_skill
      if (is_text1(v) && v %in% names(skills_ok(skills)) && !identical(isolate(dopts$skill), v)) dopts$skill = v
    }, ignoreInit = TRUE)
    observeEvent(input$design_auto, dopts$auto <- isTRUE(input$design_auto), ignoreInit = TRUE)
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
      if (is_text1(i) && i %in% isolate(state$canvas) && !is.null(chart_of(i))) toggle_selected(i)
    })
    observeEvent(input$deselect, set_selected(NULL))
    placeholder = reactive({
      sel = selected()
      if (is.null(sel) || is.null(made$chart[[sel]])) return(EXPLORE_PLACEHOLDER)
      paste0("Change ", chart_title(made$chart[[sel]]()), ", or ask something new")
    })
    observe(shinychat::update_chat_user_input("chat", placeholder = placeholder()))

    # ---- exporting the dashboard ------------------------------------------------------------------------------------

    # The chosen charts, in the order of the canvas, as build_dashboard() takes them (the mode is the dialog's to fill in).
    #   A summary table is an item too (list(id, table, mode = "table"), with no chart or story), at its place in the canvas order.
    # A card as the dashboard takes it, whatever its switch says (the dialog lists every card).
    canvas_entry = function(i) {
      if (!is.null(table_of(i))) list(id = i, table = table_of(i), mode = "table", stale = NA_character_)
      else list(id = i, chart = chart_of(i), story = story_of(i), mode = "picture", design = design_shown(i),
                stale = story_stale(story_of(i), chart_of(i), isolate(data_key())),
                shown = if (!is.null(made$rhead[[i]])) tryCatch(headline_shown(story_of(i), isolate(made$rhead[[i]]()), story_stale(story_of(i), chart_of(i), isolate(data_key()))),
                                                              error = function(e) NULL))
    }
    # What goes in: the charts and tables whose switch is on, and whose section's switch is on (a section that is off leaves out every card under it), in the
    #   order of the canvas, each with the section it stands under (id, title, text) for the page's headings.
    dash_items = function() {
      ids = isolate(state$canvas)
      sec = canvas_section_of(ids, section_ids())
      on = purrr::map2_lgl(ids, sec, function(i, s) (!is.null(chart_of(i)) || !is.null(table_of(i))) && in_dash(i) && (is.na(s) || in_dash(s)))
      purrr::map2(ids[on], sec[on], function(i, s) { it = canvas_entry(i); if (!is.na(s)) it$section = section_info(s); it })
    }
    item_title = function(it) if (!is.null(it$table)) it$table$title else chart_title(it$chart, "Untitled chart")

    # A chart's small picture for the dialog as a data address, drawn once for a given spec, palette and data; NULL for a chart that
    #   cannot be drawn now.
    dash_thumb = function(chart) {
      key = digest::digest(list(spec_hash(chart$spec), isolate(palette()), isolate(data_key())))
      if (is.null(made$thumbs[[key]]))
        made$thumbs[[key]] = tryCatch({
          f = tempfile(fileext = chart_device_ext())
          spec_png(spec_plot(chart$spec, isolate(state$data), isolate(state$codebook), isolate(palette())), f, dpi = DASH_THUMB_DPI)
          uri = dash_data_uri(f, chart_device_type())
          unlink(f)
          uri
        }, error = function(e) NA_character_)
      if (is.na(made$thumbs[[key]])) NULL else made$thumbs[[key]]
    }

    # The lines of a chart's facts that can be a key number (dash_fact_choices()), worked out by R from the plotted table; kept for a
    #   given spec and data. An empty list for a chart that cannot be drawn now.
    dash_fact_list = function(chart) {
      key = digest::digest(list("facts", spec_hash(chart$spec), isolate(palette()), isolate(data_key())))
      if (is.null(made$thumbs[[key]]))
        made$thumbs[[key]] = tryCatch({
          p = spec_plot(chart$spec, isolate(state$data), isolate(state$codebook), isolate(palette()))
          f = spec_facts(attr(p, "spec"), attr(p, "table"), isolate(state$codebook), data = isolate(state$data))
          dash_fact_choices(f$text, f$names)
        }, error = function(e) list())
      made$thumbs[[key]]
    }

    # The choices of the three key-number selects: "None", then each chosen chart's lines as a group named by the chart, each value
    #   "chart id|number of the line" (never typed text).
    dash_key_choices = function(items) {
      groups = purrr::compact(purrr::map(items, function(it) {
        f = dash_fact_list(it$chart)
        if (length(f)) stats::setNames(list(stats::setNames(paste0(it$id, "|", seq_along(f)), purrr::map_chr(f, function(x) substr(paste0(x$label, ": ", x$value), 1L, 90L)))),
                                       chart_title(it$chart, "Untitled chart"))
      }))
      c(list("None" = ""), unlist(unname(groups), recursive = FALSE))
    }

    dash_mode_id = function(chart_id) paste0("dash_mode_", chart_id)
    dash_title_default = function() paste("Dashboard:", isolate(state$codebook)$file %||% "the data file")

    # Export dashboard: the dialog. Warnings first, then the title block and the introduction, the value boxes, and each chosen
    #   chart in order with its small picture, its choice of picture or interactive and, when it is interactive and drawn from rows,
    #   the sentence that says what that puts in the file.
    observeEvent(input$export, {
      items = dash_items()
      if (!length(items))
        return(showModal(modalDialog(title = "Export dashboard", easyClose = TRUE, footer = modalButton("Close"),
                                     warn_box("No chart is in the dashboard. Switch \"In dashboard\" on for at least one card (and for its section), then press Export dashboard again."))))
      # The dashboard as it will be: every section and card of the canvas in order, each with its switch (the same as the one on the canvas).
      ids = isolate(state$canvas)
      secs = section_ids()
      sec_of = stats::setNames(canvas_section_of(ids, secs), ids)
      entries = purrr::compact(purrr::map(ids, function(i)
        if (i %in% secs) list(id = i, section = section_info(i)) else if (!is.null(chart_of(i)) || !is.null(table_of(i))) canvas_entry(i)))
      boxes = canvas_box_values(isolate(state$data), isolate(state$codebook))
      chart_items = purrr::keep(entries, function(it) is.null(it$table) && is.null(it$section))
      # The warnings follow the switches: what is left out is not warned about.
      output$dash_warns = renderUI({
        dash_on()
        its = dash_items()
        if (!length(its)) return(NULL)
        titles = purrr::map_chr(its, item_title)
        # A table with a group that has fewer than SUMMARY_SMALL_ROWS rows is named once in one warning (nothing is hidden).
        small = purrr::map_chr(purrr::keep(its, function(it) !is.null(it$table) && is_text1(it$table$by) && nzchar(it$table$by)), function(it)
          if (isTRUE(tryCatch(any(summary_table(isolate(state$data), isolate(state$codebook), it$table$measures, it$table$by)$small), error = function(e) FALSE))) it$table$title else NA_character_)
        warns = dashboard_warnings(titles, purrr::map_chr(its, "stale"), isolate(palette()), small = small[!is.na(small)])
        if (length(warns)) tags$div(class = "mb-3", purrr::map(unname(warns), function(w) tags$p(class = "small mb-1", style = warn_style, w)))
      })
      purrr::walk(chart_items, function(it)
        output[[paste0("dash_note_", it$id)]] = renderUI({
          mode = input[[dash_mode_id(it$id)]]
          tagList(
            if (!is.null(it$design)) tags$p(class = "small mb-0 text-muted", dash_design_note(it$design, it$chart$spec, mode)),
            if (identical(mode, "interactive") && (chart_from_rows(it$chart$spec)))
              tags$p(class = "small mb-0", style = warn_style, DASH_DISCLOSURE)
            else if (identical(mode, "video"))
              tagList(tags$p(class = "small mb-0 text-muted", DASH_VIDEO_TIME,
                             tryCatch(paste0(" It adds about ", dash_size_text(dash_motion_estimate(it$chart, isolate(state$data), isolate(state$codebook), isolate(palette()))), " to the page."),
                                      error = function(e) "")),
                      if (chart_from_rows(it$chart$spec)) tags$p(class = "small mb-0", style = warn_style, DASH_VIDEO_DISCLOSURE)))
        }))
      dash_result(NULL)
      dash_gen(isolate(dash_gen()) + 1L)
      number = cumsum(purrr::map_lgl(entries, function(it) is.null(it$section)))
      showModal(modalDialog(
        title = "Export dashboard", size = "l", easyClose = FALSE, footer = modalButton("Close"),
        tags$p(class = "small text-muted", "One zip, named after the marking: the dashboard as one page, the data dictionary and a codebook page, and each chart as a picture and a script (each summary table as a CSV; an animated chart is a picture there, and moves only in the page). ",
               "On the page each chart is drawn at the size it is shown, and again for a phone. ",
               "Nothing here calls a model."),
        uiOutput(ns("dash_warns")),
        tags$div(class = "row g-2",
                 tags$div(class = "col-md-6", textInput(ns("dash_title"), "Title", value = isolate(dash_fields$title) %||% dash_title_default(), width = "100%")),
                 tags$div(class = "col-md-6", textInput(ns("dash_subtitle"), "Subtitle", value = isolate(dash_fields$subtitle) %||% "", width = "100%")),
                 tags$div(class = "col-md-6", textInput(ns("dash_author"), "Author", value = isolate(dash_fields$author) %||% "", width = "100%")),
                 tags$div(class = "col-md-6", dateInput(ns("dash_date"), "Date", value = Sys.Date(), width = "100%"))),
        tags$div(class = "mt-2",
                 marking_input(ns("dash_marking"), isolate(dash_fields$marking) %||% APP_CLASSIFICATION),
                 uiOutput(ns("dash_marking_note")),
                 tags$p(class = "small text-muted", DASH_MARKING_NOTE)),
        textAreaInput(ns("dash_intro"), "Introduction", value = isolate(dash_fields$intro) %||% "", width = "100%", rows = 3,
                      placeholder = "A few sentences for the reader, at the top of the page"),
        tags$p(class = "small text-muted", DASH_INTRO_NOTE),
        checkboxGroupInput(ns("dash_boxes"), "Value boxes to show", inline = TRUE, selected = names(DASH_BOX_CHOICES),
                           choiceNames = unname(c(DASH_BOX_CHOICES[1:2], boxes$third$title)), choiceValues = names(DASH_BOX_CHOICES)),
        tags$h6("Key numbers (up to three)"),
        tags$p(class = "small text-muted", "Each is a line from the facts of one chart, worked out by R from the numbers the chart draws, and is shown as one more box at the top of the page with the chart's name under it. ",
               "You pick it from the list; it is never typed. A number of a chart that is left out is not shown."),
        {
          choices = dash_key_choices(chart_items)
          if (length(choices) > 1L)
            tags$div(class = "row g-2", purrr::map(seq_len(DASH_KEYS_MAX), function(k)
              tags$div(class = "col-md-4", selectInput(ns(paste0("dash_key", k)), paste("Key number", k), choices = choices, selected = "", width = "100%"))))
          else tags$p(class = "small text-muted", "No chart in the dashboard has a line of facts that can be a key number.")
        },
        tags$h6("The dashboard as it will be"),
        tags$p(class = "small text-muted", "Sections and cards in the order of the canvas, each with a small picture. The switch on a card leaves it out; the switch on a section leaves out the section and every card under it (the cards' own switches stay as they are). ",
               "Change the order on the canvas: drag a card by its handle, or press Move up and Move down. ",
               "A picture is the smallest file. An interactive chart is written into the page as its drawing (an SVG with a tooltip on each mark) and the scripts of the chart package (about 0.2 MB, once); a chart of thousands of marks makes the page larger.",
               if (video_available()) " An animated chart's frames are drawn for the page, as it will be shown there, and written into it; it plays once when it scrolls into view and stops on the finished chart."),
        purrr::map2(entries, number, function(it, k) {
          sec = sec_of[[it$id]]
          on_id = ns(paste0("dash_in_", it$id))
          if (!is.null(it$section))
            return(dash_section_row(it$section, on_id, isolate(in_dash(it$id)), n_cards = sum(sec_of == it$id, na.rm = TRUE) - 1L))
          nested = !is.na(sec)
          why_off = if (nested && !isolate(in_dash(sec))) DASH_WHY_OFF
          if (!is.null(it$table)) dash_table_row(it, k, isolate(state$codebook), on_id = on_id, on = isolate(in_dash(it$id)), in_section = if (nested) sec, why_off = why_off)
          else dash_chart_row(it, k, dash_thumb(it$chart), ns(dash_mode_id(it$id)), ns(paste0("dash_note_", it$id)),
                              dashboard_default_mode(it$chart, isolate(made$interactive[[it$id]]())),
                              on_id = on_id, on = isolate(in_dash(it$id)), in_section = if (nested) sec, why_off = why_off,
                              design_id = if (!is.null(design_current(it$id))) ns(paste0("dash_des_", it$id)), design_on = isTRUE(isolate(made$showd[[it$id]]())))
        }),
        uiOutput(ns("dash_action"))))
    })
    # The marking field says at once, under itself, why a blank or a too long marking will be refused when the dashboard is built.
    output$dash_marking_note = renderUI({
      m = marking_clean(if (is.null(input$dash_marking)) APP_CLASSIFICATION else input$dash_marking)
      if (!m$ok) tags$p(class = "small mb-1", style = warn_style, m$why)
    })
    purrr::walk(c("title", "subtitle", "author", "intro", "marking"), function(f)
      observeEvent(input[[paste0("dash_", f)]], dash_fields[[f]] <- input[[paste0("dash_", f)]], ignoreInit = TRUE))

    # The button, and what the last build gave: the file to download, or the error in plain words with the last lines of its own
    #   message. Drawn again after each build, so the button is enabled again and its busy line hidden.
    output$dash_action = renderUI({
      dash_gen()
      res = isolate(dash_result())
      tagList(
        if (isTRUE(res$refused))
          tags$div(class = "alert alert-danger mt-3", role = "alert", tags$p(class = "mb-0", res$lines))
        else if (!is.null(res) && !isTRUE(res$ok))
          tags$div(class = "alert alert-danger mt-3", role = "alert", tags$p(class = "mb-2", DASH_ERROR_TEXT), tags$pre(class = "small mb-0", res$lines)),
        if (isTRUE(res$ok))
          tags$div(class = "alert alert-success mt-3", role = "status",
                   tags$p(class = "mb-1", paste0("Built ", res$name, ": ", dash_size_text(res$bytes), " in ", format(round(res$seconds, 1), nsmall = 1), " seconds. ",
                                                 sum(res$modes != "table"), if (sum(res$modes != "table") == 1L) " chart: " else " charts: ", sum(res$modes == "picture"), " as ",
                                                 if (sum(res$modes == "picture") == 1L) "a picture" else "pictures", " and ", sum(res$modes == "interactive"), " interactive",
                                                 if (any(res$modes == "video")) paste0(" and ", sum(res$modes == "video"), " animated") else "", ".",
                                                 if (any(res$modes == "table")) paste0(" ", sum(res$modes == "table"), if (sum(res$modes == "table") == 1L) " summary table" else " summary tables",
                                                                                       " (a table in the page and a CSV in charts/).") else "")),
                   unname(purrr::imap(res$fallbacks[!is.na(res$fallbacks)], function(why, t)
                     tags$p(class = "small mb-1", style = warn_style, paste0("'", t, "' is a picture: its ", res$fallback_of[[t]] %||% "interactive version", " could not be made (", why, ").")))),
                   unname(purrr::imap(res$video_notes[!is.na(res$video_notes)], function(note, t) tags$p(class = "small mb-1", paste0("'", t, "': ", note)))),
                   tags$p(class = "small mb-0", "Unzip it and open dashboard.html in any browser; it needs no connection.")),
        tags$div(class = "d-flex flex-wrap align-items-center gap-2 mt-3",
                 actionButton(ns("dash_build"), "Build the dashboard", class = "btn-primary chart-call", `data-working` = WORKING_WORDS[["dashboard"]],
                              onclick = paste0("this.disabled = true; document.getElementById('", ns("dash_build_busy"), "').style.display = 'block';")),
                 if (isTRUE(res$ok)) downloadButton(ns("dash_download"), paste("Download", res$name), class = "btn-outline-secondary")),
        tags$p(id = ns("dash_build_busy"), class = "text-muted small", style = "display:none; margin-top:0.25rem;",
               paste0(WORKING_WORDS[["dashboard"]], ". With interactive or animated charts this can take a few minutes; the page stays as it is until it is done.")))
    })
    output$dash_download = downloadHandler(
      filename = function() isolate(dash_result())$name %||% "dashboard.zip",
      content = function(file) file.copy(isolate(dash_result())$zip, file, overwrite = TRUE))

    # Build the dashboard: the chosen charts as they are now, in order, each in the mode the dialog shows, built by `build` into a zip
    #   in a folder of this session. A failure is shown in the dialog (the step that failed and the last lines of the message), and the
    #   button works again; nothing is left half-written.
    dash_run = function() {
      dir = tempfile("dashboard_zip_")
      # Whatever goes wrong, from reading the dialog to the last step of the build, is an answer for the dialog, never a stopped session.
      tryCatch({
        items = purrr::map(dash_items(), function(it) {
          m = input[[dash_mode_id(it$id)]]
          if (is.null(it$table)) it$mode = if (is_text1(m) && m %in% DASH_MODES) m else dashboard_default_mode(it$chart, isolate(made$interactive[[it$id]]()))
          # a card with a design: the dialog's own choice, designed or standard (the card's, when the dialog is not there)
          des = input[[paste0("dash_des_", it$id)]]
          if (is.null(it$table) && !is.null(des)) it$design = if (isTRUE(des)) design_current(it$id)
          it
        })
        if (!length(items)) return(list(ok = FALSE, refused = TRUE, lines = "No chart is in the dashboard: every card, or every section, is switched off. Switch one on and build again."))
        d = input$dash_date
        mk = marking_clean(if (is.null(input$dash_marking)) APP_CLASSIFICATION else input$dash_marking)   # no field (a test with no dialog): the default; a blank is refused
        if (!mk$ok) return(list(ok = FALSE, refused = TRUE, lines = mk$why))
        settings = list(marking = mk$text, title = input$dash_title %||% "", subtitle = input$dash_subtitle %||% "", author = input$dash_author %||% "",
                        date = if (inherits(d, "Date") && !is.na(d)) d else Sys.Date(), intro = input$dash_intro %||% "",
                        boxes = intersect(input$dash_boxes, names(DASH_BOX_CHOICES)),
                        keys = unique(purrr::keep(unlist(purrr::map(seq_len(DASH_KEYS_MAX), function(k) input[[paste0("dash_key", k)]])),
                                                  function(v) is_text1(v) && nzchar(v))))
        old = isolate(dash_result())$zip
        if (is_text1(old)) unlink(dirname(old), recursive = TRUE)
        dir.create(dir)
        name = paste0(marking_slug(mk$text), "_dashboard_", format(settings$date, "%Y-%m-%d"), ".zip")
        c(list(ok = TRUE, name = name),
          build(items, isolate(state$data), isolate(state$codebook), isolate(palette()), settings, isolate(state$path), file.path(dir, name)))
      }, error = function(e) {
        unlink(dir, recursive = TRUE)
        list(ok = FALSE, lines = dash_last_lines(conditionMessage(dash_root_error(e))))
      })
    }
    observeEvent(input$dash_build, with_busy({
      dash_result(dash_run())
      dash_gen(isolate(dash_gen()) + 1L)
    }))

    # ---- one card -----------------------------------------------------------------------------------

    card_ui = function(chart_id) {
      ch = made$chart[[chart_id]]()
      if (is.null(ch)) return(NULL)
      st = made$story[[chart_id]]()
      sel = isTRUE(made$sel[[chart_id]]())
      interactive = isTRUE(made$interactive[[chart_id]]())
      note = story_note[[chart_id]]
      dz = made$design[[chart_id]]()
      dnote = made$dnote[[chart_id]]()
      title = chart_title(ch, "Untitled chart")
      stale = story_stale(st, ch, data_key())
      ids = state$canvas                 # the order of the dashboard: the cards' Move up and Move down read it
      at = match(chart_id, ids)
      rule = ch$spec$rule
      label = if (is_text1(rule) && !is.na(rule_labels[rule])) rule_labels[[rule]]
      btn = function(what, text, class = "btn-outline-secondary", ...)
        actionButton(ns(cid(chart_id, what)), text, class = paste("btn-sm", class), ...)
      # The heading follows the style as the exported page's does (Phase 10 Part D): its title face, upper case where the style asks for it (CSS; a
      #   number or a unit keeps its case), over the chart's title as a small grey subtitle.
      sty = chart_style(palette()$style %||% CHART_STYLE_DEFAULT)
      heading = function(text) tags$div(class = css_class("fw-semibold chart-heading", if (identical(sty$title_case, "upper")) "chart-upper"),
                                        style = paste0("font-family: ", CHART_FONTS[[sty$title_font]]$css, ";"), dash_heading_text(text, palette()$style %||% CHART_STYLE_DEFAULT))
      # The words stand where they are edited (Phase 11 Part E): a click puts a box in their place, Enter keeps what is written, Escape leaves it. A headline and
      #   a summary that fail the number or word check are kept and marked (and the line under them says why); a title is checked the same way when it was edited here.
      ed_id = ns(cid(chart_id, "ed"))
      bad_in = function(headline, summary) !is.null(st) && !is.null(st$facts) && !summary_ok(summary_problems(headline, summary, st$facts, st$spec))
      ed = made$edited[[chart_id]]()
      title_bad = if (!is.null(ed) && identical(ed$text, ch$spec$title)) {
        x = made$facts[[chart_id]]()
        if (!is.null(x)) problem_sentences(summary_problems(ed$text, NULL, x$text, x$spec)) else character(0)
      } else character(0)
      title_tag = function(tag) editable_tag(tag, ed_id, "title", ch$spec$title %||% "", "title", bad = length(title_bad) > 0L)
      # Phase 13: the headline is the card's top line, always (the analyst's, the model's when it passed, else R's); the description under it; then who wrote it
      shown = made$shown[[chart_id]]()
      head = tags$div(editable_tag(heading(shown$text), ed_id, "headline", shown$text, "headline", bad = identical(shown$by, "analyst") && bad_in(shown$text, NULL)),
                      title_tag(tags$div(class = "small text-muted chart-card-sub", title)),
                      tags$div(class = "small text-muted chart-head-by", HEADLINE_BY_TEXT[[shown$by]], if (!is.null(shown$note)) paste0(" ", shown$note)),
                      if (length(title_bad)) check_line(title_bad, ok = NULL))
      bslib::card(
        full_screen = TRUE, fill = FALSE, class = paste("chart-card", if (sel) "chart-selected"),
        `data-chart-id` = chart_id, `data-canvas-id` = chart_id, onclick = card_click_js(ns("card_click")),
        bslib::card_header(
          class = "d-flex flex-column gap-2", head,
          tags$div(class = "d-flex flex-wrap gap-1",
                   btn("select", if (sel) "Deselect" else "Select", if (sel) "btn-primary" else "btn-outline-primary"),
                   btn("undo", "Undo", disabled = !length(ch$history)),
                   btn("interactive", if (interactive) "Static" else "Interactive"),
                   if (video_available()) btn("animate", "Animate", "btn-outline-primary chart-call", `data-working` = WORKING_WORDS[["animate"]]),
                   btn("design", "Design", "btn-outline-primary chart-call", `data-working` = WORKING_WORDS[["design"]], disabled = if (is.null(skill_chosen())) NA),
                   btn("code", "Code"),
                   btn("edit", "Edit text"),
                   btn("headline", "Headline", "btn-outline-primary chart-call", `data-working` = WORKING_WORDS[["headline"]]),
                   btn("remove", "Remove", "btn-outline-danger")),
          # The dashboard's choice and order: the switch, and one place up or down (the canvas order is the dashboard's).
          tags$div(class = "d-flex flex-wrap align-items-center gap-2 chart-dash-row", drag_handle(),
                   bslib::input_switch(ns(cid(chart_id, "dash")), "In dashboard", value = isolate(in_dash(chart_id))),
                   if (!is.null(dz)) bslib::input_switch(ns(cid(chart_id, "showd")), "Designed drawing", value = isolate(isTRUE(made$showd[[chart_id]]()))),
                   btn("up", "Move up", disabled = isTRUE(at <= 1L)), btn("down", "Move down", disabled = isTRUE(at >= length(ids))))),
        bslib::card_body(
          fillable = FALSE, fill = FALSE,
          # the chart's slot takes what the row's height leaves, so a short card has no blank block under it
          tags$div(class = "chart-slot", uiOutput(ns(cid(chart_id, "view")))),
          uiOutput(ns(cid(chart_id, "notes"))),
          if (!is.null(dz)) tags$p(class = "small text-muted mb-1 chart-designed", dash_design_mark(dz)),
          if (!is.null(dnote)) tags$p(class = "small mb-1 chart-design-note", style = warn_style, dnote),
          if (!is.null(st) && is_text1(st$summary)) editable_tag(tags$p(class = "mb-1 chart-summary", st$summary), ed_id, "summary", st$summary, "summary", multiline = TRUE, bad = bad_in(NULL, st$summary)),
          if (!is.na(stale)) tags$p(class = "small mb-1", style = warn_style, if (identical(stale, "chart")) SUMMARY_STALE else SUMMARY_STALE_DATA),
          if (!is.null(st) && length(st$problems)) check_line(st$problems, ok = NULL),
          if (!is.null(note)) tags$p(class = "small mb-1", style = warn_style, note),
          tags$p(class = "small text-muted mb-0",
                 if (!is.null(label)) paste0("Rule: ", label),
                 if (isTRUE(ch$exploratory)) tags$span(class = "badge bg-secondary ms-1", "Exploratory"))))
    }

    # ---- a chart's design ------------------------------------------------------------------------------------------

    skill_chosen = function() skills_ok(skills)[[isolate(dopts$skill) %||% ""]]
    # What a design is made from: the spec, the palette and style, and the data. A design whose key is not the chart's key now is dropped.
    design_key = function(chart_id) {
      ch = made$chart[[chart_id]]()   # not isolated: the observer that drops a design depends on the spec, the palette and the data
      if (is.null(ch)) NULL else digest::digest(list(spec_hash(ch$spec), palette(), data_key()))
    }
    drop_design = function(chart_id, why = NULL) {
      dz = isolate(made$design[[chart_id]]())
      if (!is.null(dz)) unlink(c(dz$file, dz$card_file))
      made$design[[chart_id]](NULL)
      made$showd[[chart_id]](FALSE)
      if (!is.null(why)) made$dnote[[chart_id]](why)
    }
    # A design that stands for the card now (made from the chart as it is), or NULL.
    design_current = function(chart_id) {
      dz = isolate(made$design[[chart_id]]())
      if (!is.null(dz) && identical(dz$key, isolate(design_key(chart_id)))) dz
    }
    # The design the card is showing, or NULL: the export carries what the card shows.
    design_shown = function(chart_id) if (isTRUE(isolate(made$showd[[chart_id]]()))) design_current(chart_id)

    # One design: design_chart() with this session's skill, key and model, the calls recorded, the stages said in the working line. Returns TRUE when the
    #   card now has a design; if not, the card keeps its standard drawing and says why in one line. `prefix` goes before the stage ("Chart 2 of 5: ").
    design_now = function(chart_id, wish = NULL, prefix = "") {
      ch = chart_of(chart_id)
      skill = skill_chosen()
      if (is.null(ch)) return(invisible(FALSE))
      if (is.null(skill)) { made$dnote[[chart_id]]("Not designed: no design skill is available."); return(invisible(FALSE)) }
      shown = if (!is.null(made$shown[[chart_id]])) isolate(made$shown[[chart_id]]())
      if (!is.null(shown) && shown$by %in% c("analyst", "model")) ch$spec$.headline = shown$text
      res = tryCatch(design_chart(ch, skill, isolate(state$data), isolate(state$codebook), isolate(palette()), ask = ask, wish = wish, images = design_images_setting(),
                                  stage = function(s) session$sendCustomMessage("chart-progress", list(words = paste0(prefix, "Designing: ", s)))),
                     error = function(e) list(ok = FALSE, reason = design_line(conditionMessage(dash_root_error(e)), 160L), calls = NULL))
      state$calls = dplyr::bind_rows(isolate(state$calls), res$calls)
      if (!isTRUE(res$ok)) {
        made$dnote[[chart_id]](paste0("The design was not used: ", sub("[.]$", "", res$reason), ". The chart keeps its standard drawing."))
        return(invisible(FALSE))
      }
      drop_design(chart_id)
      dz = res$design
      # the card shows the design with no title block (its heading carries the headline); the design's own drawing, with its title, is what leaves the page
      card = tryCatch(design_card_picture(dz, ch, isolate(state$data), isolate(state$codebook), isolate(palette())), error = function(e) NULL)
      if (!is.null(card)) { dz$card_file = card$file; dz$card_plot = card$plot }
      dz$key = isolate(design_key(chart_id))
      made$design[[chart_id]](dz)
      made$showd[[chart_id]](TRUE)
      made$showv[[chart_id]](FALSE)
      made$dnote[[chart_id]](NULL)
      invisible(TRUE)
    }
    # Several, in turn, and what happened in one line each.
    calls_made = function() { cl = isolate(state$calls); if (is.null(cl)) 0L else nrow(cl) }
    design_many = function(ids) {
      n = length(ids)
      before = calls_made()
      done = purrr::imap_lgl(ids, function(i, k) isTRUE(design_now(i, prefix = if (n > 1L) paste0("Chart ", k, " of ", n, ": ") else "")))
      say(design_many_text(skill_chosen()$title, purrr::map_chr(ids, function(i) chart_name(i, i)), purrr::map_chr(ids, function(i) isolate(made$dnote[[i]]()) %||% ""), done,
                           calls_made() - before))
      invisible(done)
    }
    # The chat's "design this" (and a wish for a look): the selected chart, or the sentence that says to click one. No chat call is made.
    design_selected = function(wish = NULL) {
      sel = isolate(selected())
      if (is.null(sel) || is.null(chart_of(sel))) return(say(md_text(DESIGN_NONE)))
      if (!send_ok("Designing")) return(invisible())
      before = calls_made()
      if (isTRUE(design_now(sel, wish))) {
        dz = isolate(made$design[[sel]]())
        say(design_one_text(chart_name(sel), dz$skill$title, dz$wish, calls_made() - before))
      } else say(md_text(isolate(made$dnote[[sel]]()) %||% "The design was not used."))
    }
    observeEvent(input$design_all, with_busy({
      say("Design all", role = "user")
      if (send_ok("Designing")) {
        ids = chart_ids()
        todo = purrr::keep(ids, function(i) is.null(design_current(i)))
        if (!length(ids)) say("There are no charts on the canvas yet.")
        else if (!length(todo)) say("Every chart on the canvas already has a design that matches it. Press Design on a card to design it again.")
        else design_many(todo)
      }
    }))

    # ---- a chart's motion (Phase 12: frames the browser plays, no file) -------------------------------------------------

    # What a motion is drawn from: the spec, the palette and style, and the data. A motion whose key is not the chart's key now is dropped.
    video_key = function(chart_id) {
      ch = made$chart[[chart_id]]()   # not isolated: the observer that drops a motion depends on the spec, the palette and the data
      if (is.null(ch)) NULL else digest::digest(list(spec_hash(ch$spec), palette(), data_key()))
    }
    drop_video = function(chart_id) {
      made$video[[chart_id]](NULL)
      made$showv[[chart_id]](FALSE)
    }
    # The card's view of a motion: the page's player (motion_tag(), MOTION_JS, which the app's page carries once), the frames as data addresses (no resource path,
    #   which Connect would need), played once when the card shows it; then Replay (the player's own button) and Picture.
    video_view = function(chart_id, v) {
      tagList(
        motion_tag(v$frames_json, v$last, round(v$px / DASH_SCALE), paste("Animated chart:", chart_title(chart_of(chart_id), "this chart")), v$fps, v$first),
        tags$div(class = "d-flex flex-wrap gap-1 mt-2",
                 actionButton(ns(cid(chart_id, "picture")), "Picture", class = "btn-sm btn-outline-secondary")))
    }
    # Animate: draws the frames unless the chart has a current motion, and shows it in place of the picture. The frames done are said in the working line
    #   as they are drawn (a custom message from inside the call). It returns TRUE when the card shows the motion.
    animate_chart = function(chart_id) {
      ch = chart_of(chart_id)
      if (is.null(ch) || !video_available()) return(invisible(FALSE))
      v = isolate(made$video[[chart_id]]())
      key = video_key(chart_id)
      if (is.null(v) || !identical(v$key, key)) {
        drop_video(chart_id)
        words = WORKING_WORDS[["animate"]]
        spec = ch$spec
        spec$.untitled = TRUE   # the card's heading carries the headline: the frames have no title block
        res = tryCatch(spec_video(spec, isolate(state$data), isolate(state$codebook), isolate(palette()), width = SPEC_VIDEO_DASH_PX$desk[["width"]],
                                  on_frame = function(i, n) session$sendCustomMessage("chart-progress", list(words = paste0(words, ", ", i, " of ", n, " frames")))),
                       error = function(e) e)
        if (inherits(res, "error")) {
          say(paste0("The animation could not be made: ", md_text(conditionMessage(res)), " The chart is unchanged."))
          return(invisible(FALSE))
        }
        made$video[[chart_id]](c(list(key = key), dash_motion_of(res, "desk")))
      }
      made$interactive[[chart_id]](FALSE)
      made$showv[[chart_id]](TRUE)
      invisible(TRUE)
    }
    # The chat's "animate": the selected chart, or the sentence that says to click one. No model is asked.
    animate_selected = function() {
      why = video_unavailable_text()
      if (!is.null(why)) return(say(md_text(why)))
      sel = isolate(selected())
      if (is.null(sel) || is.null(chart_of(sel))) return(say(md_text(ANIMATE_NONE)))
      if (isTRUE(animate_chart(sel))) say(paste0("Animated ", md_text(chart_name(sel)), ". It plays once on the card and stops on the finished chart: Replay plays it again and Picture goes back. No model was asked."))
    }

    # A chart's outputs and observers, made once, when it is added.
    make_chart = function(chart_id) {
      if (chart_id %in% made$ids) return(invisible())
      made$ids = c(made$ids, chart_id)
      made$chart[[chart_id]] = reactiveVal(chart_of(chart_id))
      made$story[[chart_id]] = reactiveVal(story_of(chart_id))
      made$sel[[chart_id]] = reactiveVal(FALSE)
      made$interactive[[chart_id]] = reactiveVal(FALSE)
      made$dash[[chart_id]] = reactiveVal(TRUE)
      made$video[[chart_id]] = reactiveVal(NULL)
      made$showv[[chart_id]] = reactiveVal(FALSE)
      made$design[[chart_id]] = reactiveVal(NULL)
      made$showd[[chart_id]] = reactiveVal(FALSE)
      made$dnote[[chart_id]] = reactiveVal(NULL)
      made$edited[[chart_id]] = reactiveVal(NULL)
      made$dwidget[[chart_id]] = reactive({
        dz = made$design[[chart_id]]()
        if (is.null(dz)) return(NULL)
        tryCatch(design_widget(dz$card_plot %||% dz$plot, dz$size, palette()), error = function(e) structure(list(), why = "the design could not be drawn with tooltips"))
      })
      # Phase 13: R's headline from the chart's facts, the one the card shows (headline_shown()), and the drawing with it as its title
      made$rhead[[chart_id]] = reactive(tryCatch(r_headline(made$chart[[chart_id]](), state$codebook, state$data, palette()),
                                                 error = function(e) list(text = paste0(HEADLINE_FALLBACK, made$chart[[chart_id]]()$spec$title %||% ""), source = "fallback")))
      made$shown[[chart_id]] = reactive(headline_shown(made$story[[chart_id]](), made$rhead[[chart_id]](),
                                                       story_stale(made$story[[chart_id]](), made$chart[[chart_id]](), data_key())))
      # the manager's ruling: the card's HTML heading carries the headline and the description, so the drawing has no title block (`.untitled`)
      drawn = reactive(tryCatch({
        spec = made$chart[[chart_id]]()$spec
        spec$.untitled = TRUE
        spec_plot(spec, state$data, state$codebook, palette())
      }, error = function(e) e))
      # The facts the checks in the Edit text dialog compare against, from the chart as it is now.
      facts = reactive({
        x = summary_input(made$chart[[chart_id]](), state$codebook, state$data, palette())
        if (is.null(x$error)) list(text = names_back(x$facts$text, x$facts$names), spec = x$spec)
      })

      made$facts[[chart_id]] = facts
      made$drawn[[chart_id]] = drawn
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
      output[[cid(chart_id, "widget")]] = ggiraph::renderGirafe({
        p = drawn()
        if (inherits(p, "error")) stop(conditionMessage(p), call. = FALSE)
        spec_widget(p)
      })
      output[[cid(chart_id, "dstatic")]] = renderImage({
        dz = design_current(chart_id)
        if (is.null(dz)) stop("The design is not there.", call. = FALSE)
        list(src = dz$card_file %||% dz$file, contentType = chart_device_type(), alt = paste("Designed drawing:", made$shown[[chart_id]]()$text %||% "chart"),
             width = round(dz$size[["width"]] * CSS_PPI), height = round(dz$size[["height"]] * CSS_PPI), style = "max-width:100%; height:auto;")
      }, deleteFile = FALSE)
      output[[cid(chart_id, "dwidget")]] = ggiraph::renderGirafe({
        w = made$dwidget[[chart_id]]()
        if (!length(w)) stop(attr(w, "why") %||% "no design", call. = FALSE)
        w
      })
      output[[cid(chart_id, "view")]] = renderUI({
        v = made$video[[chart_id]]()
        dz = made$design[[chart_id]]()
        shown = !is.null(dz) && isTRUE(made$showd[[chart_id]]()) && identical(dz$key, design_key(chart_id))
        if (isTRUE(made$showv[[chart_id]]()) && !is.null(v) && identical(v$key, video_key(chart_id))) video_view(chart_id, v)
        else if (isTRUE(made$interactive[[chart_id]]())) {
          # A designed drawing is interactive only when design_widget() can give its layers tooltips; otherwise the standard interactive view, labelled as such.
          w = if (shown) made$dwidget[[chart_id]]()
          if (shown && length(w)) ggiraph::girafeOutput(ns(cid(chart_id, "dwidget")), width = "100%")
          else tagList(ggiraph::girafeOutput(ns(cid(chart_id, "widget")), width = "100%"),
                       if (shown) tags$p(class = "small text-muted mb-0 chart-standard-interactive", paste0("The standard interactive view: the designed drawing is a picture (", attr(w, "why") %||% "no tooltips", ").")))
        }
        else if (shown) imageOutput(ns(cid(chart_id, "dstatic")), height = "auto")
        else imageOutput(ns(cid(chart_id, "static")), height = "auto")
      })
      # The design is dropped when what it was made from changes (the chart's spec, the palette or style, the data): the card shows the standard drawing again.
      observe({
        dz = made$design[[chart_id]]()
        if (!is.null(dz) && !identical(dz$key, design_key(chart_id)))
          drop_design(chart_id, "The designed drawing was dropped because the chart, the style or the data changed. Press Design to make it again.")
      })
      # The motion is dropped when what it was drawn from changes (the chart's spec, the palette or style, the data): the card shows the picture again.
      observe({
        v = made$video[[chart_id]]()
        if (!is.null(v) && !identical(v$key, video_key(chart_id))) drop_video(chart_id)
      })
      output[[cid(chart_id, "notes")]] = renderUI({
        p = drawn()
        if (inherits(p, "error")) return(warn_box(conditionMessage(p)))
        shown = attr(p, "notes")
        if (length(shown)) tags$ul(class = "small text-muted chart-notes", purrr::map(shown, tags$li))
      })

      # The buttons of the header.
      observeEvent(input[[cid(chart_id, "select")]], toggle_selected(chart_id))
      observeEvent(input[[cid(chart_id, "interactive")]], {
        rv = made$interactive[[chart_id]]
        rv(!isTRUE(isolate(rv())))
        if (isTRUE(isolate(rv()))) made$showv[[chart_id]](FALSE)
      })
      observeEvent(input[[cid(chart_id, "animate")]], with_busy(animate_chart(chart_id)))
      observeEvent(input[[cid(chart_id, "design")]], with_busy(if (send_ok("Designing")) design_now(chart_id)))
      observeEvent(input[[cid(chart_id, "showd")]], {
        v = isTRUE(input[[cid(chart_id, "showd")]])
        if (!identical(isolate(made$showd[[chart_id]]()), v)) made$showd[[chart_id]](v)
      }, ignoreInit = TRUE)
      observeEvent(input[[cid(chart_id, "picture")]], made$showv[[chart_id]](FALSE))
      observeEvent(input[[cid(chart_id, "undo")]], {
        ch = chart_of(chart_id)
        if (is.null(ch) || !length(ch$history)) return()
        ch = chart_undo(ch)
        ch$notes = notes_for(ch$spec)
        set_chart(ch)
      })
      observeEvent(input[[cid(chart_id, "remove")]], remove_chart(chart_id))
      # The dashboard: the switch is kept with the chart (as the Interactive view is), so Undo and a new order leave it as it was.
      observeEvent(input[[cid(chart_id, "dash")]], {
        rv = made$dash[[chart_id]]
        v = isTRUE(input[[cid(chart_id, "dash")]])
        if (!identical(isolate(rv()), v)) rv(v)
      }, ignoreInit = TRUE)
      observeEvent(input[[cid(chart_id, "up")]], move_chart(chart_id, -1L))
      observeEvent(input[[cid(chart_id, "down")]], move_chart(chart_id, 1L))
      observeEvent(input[[cid(chart_id, "ed")]], edit_in_place(chart_id, input[[cid(chart_id, "ed")]]))
      dash_switch(chart_id)
      observeEvent(input[[cid(chart_id, "headline")]], with_busy(if (send_ok("Writing a headline")) say(story_line(write_stories(chart_id)))))

      # Code: a dialog with the R code of this chart and a button that copies it.
      observeEvent(input[[cid(chart_id, "code")]], {
        ch = chart_of(chart_id)
        if (is.null(ch)) return()
        # The chart as drawn: the spec as the lint left it (sideways bars, end labels, the legend's order, the source line), the
        #   palette and style chosen, so the code gives the card's chart.
        # the code draws the chart as charts.R does (the manager's ruling: a picture that leaves the card carries its headline and description), not the card's
        #   drawing, which has no title block
        p = tryCatch({
          sp = ch$spec
          sh = isolate(made$shown[[chart_id]]())
          if (!is.null(sh) && sh$by %in% c("analyst", "model")) sp$.headline = sh$text
          spec_plot(sp, isolate(state$data), isolate(state$codebook), isolate(palette()))
        }, error = function(e) e)
        dz = design_shown(chart_id)
        code = if (!is.null(dz)) design_code_lines(dz)
               else if (inherits(p, "error")) conditionMessage(p)
               else tryCatch(spec_code(attr(p, "spec"), isolate(state$codebook), isolate(state$path), isolate(palette())), error = function(e) conditionMessage(e))
        code_id = ns(cid(chart_id, "code_text"))
        showModal(modalDialog(
          title = paste0("Code: ", chart_title(ch)), size = "l", easyClose = TRUE,
          tags$pre(id = code_id, class = "small", paste(code, collapse = "\n")),
          if (!is.null(dz)) tagList(tags$h6("The table it draws"), design_table_tag(dz$table)),
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
          if (identical(field, "headline")) st$headline_by = "analyst"
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

    # ---- a section's card ---------------------------------------------------------------------------------------------

    # The heading card: its title and its line of text (each edited where it stands, or with Edit text), Collapse (hides the cards under it on the canvas; the
    #   export is not changed by it), Remove section (the cards stay), the switch for the dashboard (off leaves out the section and its cards), Move up and
    #   Move down (the section goes with its cards, past the section next to it), and the handle it is dragged by.
    section_card_ui = function(sid) {
      def = made$section[[sid]]()
      if (is.null(def)) return(NULL)
      blocks = canvas_blocks(state$canvas, names(state$sections))
      at = which(purrr::map_lgl(blocks, function(b) identical(b[[1]], sid)))
      n = if (length(at)) length(blocks[[at]]) - 1L else 0L
      collapsed = isTRUE(def$collapsed)
      sty = chart_style(palette()$style %||% CHART_STYLE_DEFAULT)
      btn = function(what, text, class = "btn-outline-secondary", ...)
        actionButton(ns(cid(sid, what)), text, class = paste("btn-sm", class), ...)
      ed_id = ns(cid(sid, "ed"))
      tags$div(class = "chart-section my-3", `data-canvas-id` = sid, `data-section-id` = sid, role = "group", `aria-label` = paste("Section:", def$title),
               tags$div(class = "d-flex align-items-start gap-2", drag_handle(),
                        tags$div(class = "flex-grow-1 min-w-0",
                                 editable_tag(tags$h2(class = css_class("fw-semibold chart-section-title", if (identical(sty$title_case, "upper")) "chart-upper"),
                                                      style = paste0("font-family: ", CHART_FONTS[[sty$title_font]]$css, ";"),
                                                      dash_heading_text(def$title, palette()$style %||% CHART_STYLE_DEFAULT)), ed_id, "title", def$title, "section title"),
                                 editable_tag(if (nzchar(def$text)) tags$p(class = "chart-section-text", def$text)
                                              else tags$p(class = "chart-section-text small text-muted", "Click to add a line of text"),
                                              ed_id, "text", def$text, "section text", multiline = TRUE))),
               tags$div(class = "d-flex flex-wrap align-items-center gap-2 mt-2 chart-dash-row",
                        btn("collapse", if (collapsed) "Expand" else "Collapse", `aria-expanded` = if (collapsed) "false" else "true"),
                        btn("edit", "Edit text"),
                        btn("remove", "Remove section", "btn-outline-danger"),
                        tags$span(class = "small text-muted", paste0(n, if (n == 1L) " card" else " cards", if (collapsed && n) " (hidden)")),
                        bslib::input_switch(ns(cid(sid, "dash")), "In dashboard", value = isolate(in_dash(sid))),
                        btn("up", "Move up", disabled = isTRUE(at <= 1L)), btn("down", "Move down", disabled = isTRUE(at >= length(blocks)))))
    }

    # A section's outputs and observers, made once, when it is added.
    make_section = function(sid) {
      if (sid %in% made$ids) return(invisible())
      made$ids = c(made$ids, sid)
      made$section[[sid]] = reactiveVal(section_of(sid))
      made$dash[[sid]] = reactiveVal(TRUE)
      output[[cid(sid, "card")]] = renderUI(section_card_ui(sid))
      observeEvent(input[[cid(sid, "remove")]], remove_section(sid))
      observeEvent(input[[cid(sid, "dash")]], {
        rv = made$dash[[sid]]
        v = isTRUE(input[[cid(sid, "dash")]])
        if (!identical(isolate(rv()), v)) rv(v)
      }, ignoreInit = TRUE)
      dash_switch(sid)
      observeEvent(input[[cid(sid, "up")]], move_chart(sid, -1L))
      observeEvent(input[[cid(sid, "down")]], move_chart(sid, 1L))
      observeEvent(input[[cid(sid, "collapse")]], {
        def = section_of(sid)
        if (!is.null(def)) { def$collapsed = !isTRUE(def$collapsed); set_section(sid, def) }
      })
      observeEvent(input[[cid(sid, "ed")]], edit_in_place(sid, input[[cid(sid, "ed")]]))
      # Edit text: the title and the line of text, applied with the button (the same as editing them where they stand). Nothing here is checked: a section's words
      #   say nothing about a chart.
      observeEvent(input[[cid(sid, "edit")]], {
        def = section_of(sid)
        if (is.null(def)) return()
        showModal(modalDialog(
          title = paste0("Edit text: ", def$title), size = "l", easyClose = FALSE,
          textInput(ns(cid(sid, "w_title")), "Title", value = def$title, width = "100%"),
          textAreaInput(ns(cid(sid, "w_text")), "Line of text (optional)", value = def$text, width = "100%", rows = 3),
          footer = tagList(modalButton("Close"), actionButton(ns(cid(sid, "apply")), "Apply wording", class = "btn-primary"))))
      })
      observeEvent(input[[cid(sid, "apply")]], {
        def = section_of(sid)
        if (is.null(def)) return()
        title = trimws(input[[cid(sid, "w_title")]] %||% "")
        def$title = if (nzchar(title)) title else SECTION_TITLE_DEFAULT
        def$text = trimws(input[[cid(sid, "w_text")]] %||% "")
        set_section(sid, def)
        removeModal()
      })
      invisible()
    }

    # ---- a summary table's card ---------------------------------------------------------------------------------------

    # The Add a summary table dialog: the measures (one or more), a group to take them by (optional), a title and the switch for the 95%
    #   intervals. R works the numbers out from the file; no model is asked. A chat message that only asks for summary statistics opens it
    #   too. Returns TRUE when the dialog opened (it does not before a file is read and the dictionary says what a row is).
    open_table_dialog = function() {
      cb = isolate(state$codebook)
      data = isolate(state$data)
      if (is.null(data) || is.null(cb)) { say(SETUP_NEED_DATA); return(invisible(FALSE)) }
      if (!codebook_ready(cb)) { say(SETUP_NEED_ROW); return(invisible(FALSE)) }
      table_msg(NULL)
      showModal(modalDialog(
        title = "Add a summary table", size = "l", easyClose = TRUE,
        footer = tagList(modalButton("Cancel"), actionButton(ns("table_add"), "Add table", class = "btn-primary")),
        tags$p(class = "small text-muted", SUMMARY_PRIVACY),
        selectizeInput(ns("table_measures"), "Measures (one or more)", choices = summary_measure_choices(cb, data), multiple = TRUE, width = "100%",
                       options = list(placeholder = "Choose columns")),
        selectInput(ns("table_by"), "By group (optional)", choices = summary_by_choices(cb, data), selectize = FALSE, width = "100%"),
        textInput(ns("table_title"), "Title", value = "", width = "100%", placeholder = "Left blank, the title names the columns"),
        bslib::input_switch(ns("table_ci"), "Show 95% CI", value = TRUE),
        tags$p(class = "small text-muted", "95% intervals assume a simple random sample, and the note under the table says so."),
        uiOutput(ns("table_msg"))))
      invisible(TRUE)
    }
    output$table_msg = renderUI(if (!is.null(table_msg())) warn_box(table_msg()))
    observeEvent(input$add_table, open_table_dialog())

    # A table is added on top of the canvas, as a chart is, with its switch for the dashboard on.
    add_table = function(def) {
      made$tn = made$tn + 1L
      def$id = paste0("t", made$tn)
      ts = isolate(state$tables) %||% list()
      ts[[def$id]] = def
      state$tables = ts
      make_table(def$id)
      state$canvas = c(def$id, isolate(state$canvas))
      invisible(def$id)
    }

    observeEvent(input$table_add, {
      cb = isolate(state$codebook)
      data = isolate(state$data)
      if (is.null(cb) || is.null(data)) return()
      allowed = unname(summary_measure_choices(cb, data))
      m = as.character(input$table_measures)
      m = m[m %in% allowed]
      if (!length(m)) return(table_msg(if (length(allowed)) "Choose at least one measure." else SUMMARY_NO_MEASURE))
      by = input$table_by %||% ""
      by = if (nzchar(by) && by %in% summary_by_choices(cb, data)) by
      title = trimws(input$table_title %||% "")
      add_table(list(title = if (nzchar(title)) title else summary_title(m, by, cb), measures = m, by = by, ci = !identical(input$table_ci, FALSE)))
      removeModal()
    })

    # The card: the title, Edit text (the title only) and Remove, the dashboard's switch with Move up and Move down, and the table as plain HTML
    #   in the style's type (its title face for the title, its subtitle face for the table). A table has no picture and no text written by a
    #   model, so it has no Select, Interactive, Code, Headline or Animate.
    table_card_ui = function(table_id) {
      def = made$table[[table_id]]()
      if (is.null(def)) return(NULL)
      tb = made$tbl[[table_id]]()
      st = chart_style(palette()$style %||% CHART_STYLE_DEFAULT)
      ids = state$canvas
      at = match(table_id, ids)
      btn = function(what, text, class = "btn-outline-secondary", ...)
        actionButton(ns(cid(table_id, what)), text, class = paste("btn-sm", class), ...)
      bslib::card(
        full_screen = TRUE, fill = FALSE, class = "chart-card chart-table-card", `data-table-id` = table_id, `data-canvas-id` = table_id,
        bslib::card_header(
          class = "d-flex flex-column align-items-start gap-2",
          editable_tag(tags$div(class = css_class("fw-semibold chart-heading", if (identical(st$title_case, "upper")) "chart-upper"), style = paste0("font-family: ", CHART_FONTS[[st$title_font]]$css, ";"),
                               dash_heading_text(def$title, palette()$style %||% CHART_STYLE_DEFAULT)), ns(cid(table_id, "ed")), "title", def$title, "title"),

          tags$div(class = "d-flex flex-wrap gap-1", btn("edit", "Edit text"), btn("remove", "Remove", "btn-outline-danger")),
          tags$div(class = "d-flex flex-wrap align-items-center gap-2 chart-dash-row", drag_handle(),
                   bslib::input_switch(ns(cid(table_id, "dash")), "In dashboard", value = isolate(in_dash(table_id))),
                   btn("up", "Move up", disabled = isTRUE(at <= 1L)), btn("down", "Move down", disabled = isTRUE(at >= length(ids))))),
        bslib::card_body(
          fillable = FALSE, fill = FALSE, style = paste0("font-family: ", CHART_FONTS[[st$subtitle_font]]$css, ";"),
          if (inherits(tb, "error")) warn_box(conditionMessage(tb)) else summary_tag(tb, def$ci)))
    }

    # A table's outputs and observers, made once, when it is added.
    make_table = function(table_id) {
      if (table_id %in% made$ids) return(invisible())
      made$ids = c(made$ids, table_id)
      made$table[[table_id]] = reactiveVal(table_of(table_id))
      made$dash[[table_id]] = reactiveVal(TRUE)
      made$tbl[[table_id]] = reactive({
        def = made$table[[table_id]]()
        tryCatch(summary_table(state$data, state$codebook, def$measures, def$by), error = function(e) e)
      })
      output[[cid(table_id, "card")]] = renderUI(table_card_ui(table_id))
      observeEvent(input[[cid(table_id, "remove")]], remove_table(table_id))
      observeEvent(input[[cid(table_id, "dash")]], {
        rv = made$dash[[table_id]]
        v = isTRUE(input[[cid(table_id, "dash")]])
        if (!identical(isolate(rv()), v)) rv(v)
      }, ignoreInit = TRUE)
      observeEvent(input[[cid(table_id, "up")]], move_chart(table_id, -1L))
      observeEvent(input[[cid(table_id, "down")]], move_chart(table_id, 1L))
      observeEvent(input[[cid(table_id, "ed")]], edit_in_place(table_id, input[[cid(table_id, "ed")]]))
      dash_switch(table_id)
      # Edit text: the title only (a table holds no other text), applied with the button; blank is the title R writes from the columns.
      observeEvent(input[[cid(table_id, "edit")]], {
        def = table_of(table_id)
        if (is.null(def)) return()
        showModal(modalDialog(
          title = paste0("Edit text: ", def$title), size = "l", easyClose = FALSE,
          textInput(ns(cid(table_id, "w_title")), "Title", value = def$title, width = "100%"),
          footer = tagList(modalButton("Close"), actionButton(ns(cid(table_id, "apply")), "Apply wording", class = "btn-primary"))))
      })
      observeEvent(input[[cid(table_id, "apply")]], {
        def = table_of(table_id)
        if (is.null(def)) return()
        title = trimws(input[[cid(table_id, "w_title")]] %||% "")
        def$title = if (nzchar(title)) title else summary_title(def$measures, def$by, isolate(state$codebook))
        ts = isolate(state$tables); ts[[table_id]] = def; state$tables = ts
        made$table[[table_id]](def)
        removeModal()
      })
      invisible()
    }
  })
}


# ---- Sections and the order of the canvas (Phase 11 Part E) ---------------------------------------------------------------
#   The canvas is a list of ids: charts (c1), tables (t1) and sections (s1). A section is a heading; the cards under it, up to the next heading, belong to it.
#   The functions below take the ids and `secs`, the ids that are sections, and return ids (no state): the order is the dashboard's.

SECTION_TITLE_DEFAULT <- "New section"

# The section each id stands under: the last heading at or before it (a heading stands under itself); NA before the first heading.
canvas_section_of <- function(ids, secs) {
  if (!length(ids)) return(character(0))
  as.character(unlist(utils::tail(purrr::accumulate(ids, function(cur, i) if (i %in% secs) i else cur, .init = NA_character_), -1L)))
}

# The canvas in blocks: a heading with the cards under it; the cards before the first heading are the first block (with no heading).
canvas_blocks <- function(ids, secs) {
  if (!length(ids)) return(list())
  key = canvas_section_of(ids, secs)
  key = ifelse(is.na(key), "", key)
  unname(split(ids, factor(key, levels = unique(key))))
}

# A section moved `by` places among the blocks, with its cards; the ids as they were when it cannot move.
canvas_move_block <- function(ids, secs, id, by) {
  blocks = canvas_blocks(ids, secs)
  at = which(purrr::map_lgl(blocks, function(b) identical(b[[1]], id)))
  to = at + by
  if (length(at) != 1L || to < 1L || to > length(blocks)) return(ids)
  blocks[c(at, to)] = blocks[c(to, at)]
  unlist(blocks)
}

# `id` (a card, or a section, which takes its cards) put before or after `target`. A card lands before or after the card (or heading) it is dropped on, so a card
#   dropped on the lower half of a heading is the first of that section. A section lands before or after the block of the card it is dropped on, never inside it.
canvas_reorder <- function(ids, secs, id, target, after = FALSE) {
  if (!id %in% ids || !target %in% ids || identical(id, target)) return(ids)
  moving = if (id %in% secs) unlist(purrr::keep(canvas_blocks(ids, secs), function(b) identical(b[[1]], id))) else id
  if (target %in% moving) return(ids)
  rest = setdiff(ids, moving)
  ref = target
  if (id %in% secs) {
    block = purrr::detect(canvas_blocks(rest, secs), function(b) target %in% b)
    ref = if (after) utils::tail(block, 1L) else block[[1]]
  }
  at = match(ref, rest)
  append(rest, moving, after = if (after) at else at - 1L)
}

# The handle a card is dragged by (the page's script, EXPLORE_JS, does the rest).
drag_handle <- function()
  tags$span(class = "chart-drag", draggable = "true", role = "img", `aria-label` = "Drag handle",
            title = "Drag to move. Move up and Move down do the same from the keyboard.", HTML("&#8942;&#8942;"))

# A text that is edited where it stands: the tag, made a target of the page's in-place edit (EXPLORE_JS), which starts the box with the text as shown. `value` says
#   whether there is a text (none: the box starts empty, whatever the tag shows in its place), `field` is what the server is told, `bad` marks a text that failed the checks.
editable_tag <- function(tag, input_id, field, value, label, multiline = FALSE, bad = FALSE)
  htmltools::tagAppendAttributes(tag, class = css_class("chart-editable", if (bad) "chart-marked"), tabindex = "0", role = "button",
                                 title = paste0("Click to edit the ", label, ". Enter keeps it, Escape leaves it."),
                                 `data-input` = input_id, `data-field` = field, `data-empty` = if (!is_text1(value) || !nzchar(value)) "1", `data-label` = label,
                                 `data-multiline` = if (multiline) "1")

# ---- Exporting the dashboard ------------------------------------------------------------------------------------------
#   The analyst chooses the charts that go in (the "In dashboard" switch on each card), puts them in order (Move up, Move down)
#   and presses Export dashboard. A dialog asks for the title, subtitle, author, date and a short introduction, which of the
#   three value boxes to show, and for each chart whether it goes in as a picture or as an interactive chart. Building writes one
#   zip: dashboard.html (one self-contained page), data_dictionary.yaml and codebook.html, and charts/ (each chart as a 300 dpi
#   PNG and, when svglite is installed, as an SVG, and charts.R, the code of each). Everything is written by R: htmltools writes
#   both pages, with no Quarto, no pandoc and no other program (htmlwidgets::saveWidget(selfcontained = TRUE) needs pandoc, so it
#   is not used), and zip::zipr() writes the zip (the zip package carries its own zip code, so no zip program is needed on
#   Windows or on a Linux server; utils::zip() would need one). The stylesheet, the pictures and the bundled typefaces are
#   inlined in the page, and only when a chart is interactive the scripts its widget needs are read from the installed
#   packages' dependency files and written into <script> elements, so nothing is requested when the page is opened offline.
#   No part of it calls a model.

DASH_DPI <- 300L                # pixels per inch of the pictures in the file
DASH_THUMB_DPI <- 40L           # ... and of the small ones in the dialog
DASH_ROW_FAMILIES <- c("scatter", "bubble", "box")
DASH_TOTAL_FAMILIES <- c("bar", "dot", "line", "slope", "heatmap", "dumbbell")
DASH_MODES <- c(Picture = "picture", Interactive = "interactive", Animated = "video")   # the dialog offers Animated only when this server can draw the frames (video_available())
DASH_BOX_CHOICES <- c(rows = "Rows", columns = "Columns", third = "Period, or the file name")
DASH_DISCLOSURE <- paste("In the interactive version the values of every plotted row are written into the file, so anyone who opens it can read",
                         "them; a picture holds none.")
DASH_VIDEO_DISCLOSURE <- paste("An animated chart carries no rows: it is pictures of the chart, so no value of the file can be read from it. The page shows the finished chart, as a still,",
                                "to a reader whose system asks for less motion, and in print.")
DASH_VIDEO_TIME <- "An animated chart takes some seconds to draw; its frames are written into the page."

# The player of an animated chart (Phase 12; Phase 12b), in the page and in the app's card: plain script, no library. A box holds the finished chart as an <img>
#   (what a reader sees without script, with less motion asked for, in print, when the motion ends, and when the frames cannot be read) and its frames as data
#   addresses in a JSON script element (every frame but the last, each with the number of times in a row it is shown; the last is the <img>). In the page
#   (Phase 12c) that element stands after all the cards and the box names it (data-frames), so that a card's own markup is short and whole at the first
#   paint; in the app's card it is inside the box. The frames are read only once the page has been read (not while it is loading).
# - Before a box has played, its <img> is hidden (the class motion-js on <html>, set as the page starts by MOTION_HEAD_JS and by this script, under the style
#   sheet's rule; never under reduced motion, never in print), so a card that is going to play never shows the finished chart first.
# - When a box comes within a screen of the view, or Replay is pressed, it is made ready (`prepare`): an Image for each frame, loaded and decoded, the first
#   before the rest (a frame counts as ready when it has loaded, and its decode() is waited for at most 250 ms: decode() does not settle in a browser on
#   virtual time; a frame that has already failed to load is failed at once); the first is drawn on a <canvas> laid over the <img> as soon as it is decoded, so the box shows the start of the motion, not a blank. A box that moves
#   more than a screen away before it played lets its images go. If the frames cannot be read or decoded (in MOTION_WAIT_MS), the box rests on the <img>.
# - It plays once, when half of the box is first on the screen and its frames are decoded (the place is read when the page is ready, scrolls or is resized:
#   no IntersectionObserver, which does not run in a browser without a screen), from frame 0: one timer for each frame kept, held for its repeats at 12 a
#   second (data-fps); when the last frame is due it takes the canvas away and lets the images go, so the box rests on the <img> (data-still).
# - The "Replay" button under it, hidden until the script runs, makes the images again and plays from the first. Under prefers-reduced-motion nothing is made
#   or played and the button stays hidden. Before print a box that is playing or getting ready stops and rests on the <img>. A box added later (the app's
#   card, drawn by Shiny) is found by a MutationObserver.
# - The canvas is drawn in software (willReadFrequently): on a canvas drawn by the graphics card, every frame drawn becomes a texture that Chrome keeps
#   after the page has let the frame go (about 290 MB in the GPU process for each of the five test charts' cards that played, tests/motion_realtime_12b.mjs).
MOTION_WAIT_MS <- 10000L
MOTION_JS <- paste0("(function () {
  var reduced = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };
  window.chartMotion = true;
  if (!reduced()) document.documentElement.classList.add('motion-js');
  var loaded = function (im) { return new Promise(function (ok, no) { if (im.complete) { if (im.naturalWidth) ok(); else no(); } else { im.onload = ok; im.onerror = no; } }); };
  var decode = function (im) { return loaded(im).then(function () { return im.decode ? Promise.race([im.decode().catch(function () {}), new Promise(function (ok) { setTimeout(ok, 250); })]) : null; }); };
  var release = function (box) {
    if (box._timer) { clearTimeout(box._timer); box._timer = null; }
    if (box._canvas) { box._canvas.remove(); box._canvas = null; }
    box._images = null; box._frames = null; box._ready = false; box._want = false; box._token = (box._token || 0) + 1;
    box.removeAttribute('data-playing'); box.removeAttribute('data-loading');
  };
  var rest = function (box) { release(box); box.setAttribute('data-still', ''); };
  var canvas = function (box) {
    if (box._canvas) return box._canvas;
    var img = box.querySelector('img.motion-still'), c = document.createElement('canvas');
    c.width = img.naturalWidth || +img.getAttribute('width'); c.height = img.naturalHeight || +img.getAttribute('height');
    c.className = 'motion-canvas'; c.setAttribute('aria-hidden', 'true');
    box.querySelector('.motion-stage').appendChild(c);
    box._canvas = c;
    return c;
  };
  var draw = function (box, i) {
    var im = box._images[i], c = canvas(box), g = c.getContext('2d', { willReadFrequently: true });
    if (!(im.complete && im.naturalWidth)) return;
    g.clearRect(0, 0, c.width, c.height); g.drawImage(im, 0, 0, c.width, c.height);
  };
  var play = function (box) {
    if (reduced()) return;
    if (!box._ready) { box._want = true; prepare(box); return; }
    box._want = false;
    if (box._timer) clearTimeout(box._timer);
    var d = box._frames, fps = +box.getAttribute('data-fps') || 12;
    box.setAttribute('data-playing', '');
    var show = function (i) {
      if (i >= d.frames.length) { box.setAttribute('data-played', String((+box.getAttribute('data-played') || 0) + 1)); rest(box); return; }
      draw(box, i);
      box.setAttribute('data-frame', String(i));
      box._timer = setTimeout(function () { show(i + 1); }, Math.round(1000 * d.repeats[i] / fps));
    };
    show(0);
  };
  var holder = function (box) { var id = box.getAttribute('data-frames'); return id ? document.getElementById(id) : box.querySelector('script.motion-frames'); };
  var prepare = function (box) {
    if (box._images || reduced() || document.readyState === 'loading') return;
    var token = box._token = (box._token || 0) + 1;
    var fail = function () { if (box._token !== token) return; rest(box); box._seen = true; box.setAttribute('data-failed', ''); };
    try { box._frames = JSON.parse(holder(box).textContent); } catch (e) { box._frames = null; }
    if (!box._frames || !box._frames.frames || !box._frames.frames.length) { fail(); return; }
    box.setAttribute('data-loading', '');
    box._images = box._frames.frames.map(function (u) { var im = new Image(); im.src = u; return im; });
    var wait = setTimeout(fail, ", MOTION_WAIT_MS, ");
    decode(box._images[0]).then(function () {
      if (box._token !== token) return;
      draw(box, 0);
      return Promise.all(box._images.slice(1).map(decode)).then(function () {
        if (box._token !== token) return;
        clearTimeout(wait); box._ready = true; box.removeAttribute('data-loading');
        if (box._want) play(box); else look();
      });
    }).catch(function () { clearTimeout(wait); fail(); });
  };
  var inView = function (box) {
    var r = box.getBoundingClientRect(), h = window.innerHeight || document.documentElement.clientHeight;
    if (!r.height || !h) return false;
    return Math.min(r.bottom, h) - Math.max(r.top, 0) >= Math.min(r.height, h) / 2;
  };
  var near = function (box) {
    var r = box.getBoundingClientRect(), h = window.innerHeight || document.documentElement.clientHeight;
    return !!r.height && r.bottom > -h && r.top < 2 * h;
  };
  var boxes = [];
  var look = function () {
    boxes = boxes.filter(function (box) { return box.isConnected; });
    boxes.forEach(function (box) {
      if (box._want) { prepare(box); return; }
      if (box._seen) return;
      if (inView(box)) { box._seen = true; play(box); }
      else if (near(box)) prepare(box);
      else if (box._images) release(box);
    });
  };
  var ready = function (box) {
    if (box._known) return; box._known = true;
    if (reduced()) return;
    var btn = box.querySelector('button.motion-replay');
    if (btn) { btn.hidden = false; btn.addEventListener('click', function () { box._seen = true; box.removeAttribute('data-failed'); release(box); play(box); }); }
    boxes.push(box);
  };
  var all = function () { document.querySelectorAll('.motion').forEach(ready); look(); };
  window.addEventListener('scroll', look, { passive: true });
  window.addEventListener('resize', look);
  window.addEventListener('load', look);
  window.addEventListener('beforeprint', function () { boxes.forEach(function (box) { if (box._images) { box._seen = true; rest(box); } }); });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', all); else all();
  if ('MutationObserver' in window) new MutationObserver(all).observe(document.documentElement, { childList: true, subtree: true });
})();")

# The first script of a page that holds an animated chart, in its <head>: it marks <html> with motion-js before any card is drawn, so the style sheet hides
#   the finished pictures of the cards that are going to play (not under reduced motion). If the player has not run by the time the page has loaded (a browser
#   that cannot run it), the mark is taken away and every card shows its finished chart.
MOTION_HEAD_JS <- paste0("(function () { if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return; var h = document.documentElement; h.classList.add('motion-js'); ",
                         "window.addEventListener('load', function () { if (!window.chartMotion) h.classList.remove('motion-js'); }); })();")

# The box of an animated chart: as wide as its frames were drawn for (set on the box), never wider. The canvas lies over the finished picture while it plays;
#   in print and under reduced motion only the finished picture is shown.
DASH_VIDEO_CSS <- paste0(
  ".motion{width:100%;}\n",
  ".motion-stage{position:relative;}\n",
  ".motion img.motion-still{display:block;width:100%;height:auto;}\n",
  "html.motion-js .motion:not([data-still]) img.motion-still,.motion[data-playing] img.motion-still{visibility:hidden;}\n",
  ".motion img.motion-first{display:none;}html.motion-js .motion:not([data-still]) img.motion-first{display:block;position:absolute;left:0;top:0;width:100%;height:100%;}\n",
  ".motion canvas.motion-canvas{position:absolute;left:0;top:0;width:100%;height:100%;}\n",
  ".motion .motion-replay{display:inline-block;margin:.45rem 0 0;font:inherit;font-size:.85rem;line-height:1.2;color:var(--text);background:transparent;border:1px solid var(--text2);border-radius:.25rem;padding:.25rem .8rem;cursor:pointer;}\n",
  ".motion .motion-replay[hidden]{display:none;}\n",
  # a phone (Phase 12c): the card's phone drawing in place of its motion; 599 is DASH_PHONE_MAX_PX (defined below this; a check holds them equal)
  ".card img.motion-phone,img.motion-phone{display:none;}@media screen and (max-width:599px){.motion-wrap:has(+ img.motion-phone){display:none;}.card .motion-wrap + img.motion-phone,.motion-wrap + img.motion-phone{display:block;width:100%;height:auto;}}\n",
  "html.motion-js .motion .motion-replay[hidden]{display:inline-block;visibility:hidden;}\n",
  ".motion .motion-replay:hover{background:var(--box);}\n",
  ".motion .motion-replay:focus-visible{outline:3px solid var(--accent);outline-offset:2px;}\n",
  "@media (prefers-reduced-motion:reduce){.motion canvas.motion-canvas,.motion .motion-replay,.motion img.motion-first{display:none !important;}.motion img.motion-still{visibility:visible !important;}}\n",
  "@media print{.motion canvas.motion-canvas,.motion .motion-replay,.motion img.motion-first{display:none !important;}.motion img.motion-still{visibility:visible !important;}}\n")

# The frames of a motion as the player reads them: the frames but the last as data addresses with their repeat counts, as JSON. `mo` is what spec_video() or
#   design_video() returned.
motion_frames_json <- function(mo) {
  k = length(mo$files) - 1L
  jsonlite::toJSON(list(frames = purrr::map_chr(utils::head(mo$files, k), function(f) dash_data_uri(f, "image/png")), repeats = utils::head(mo$repeats, k)), auto_unbox = FALSE)
}

# The estimate of the bytes an animated chart adds to the page, said in the export dialog before it is built: its finished picture is drawn once, as its last frame
#   would be for a card that shares its row (no bands: Phase 12c), and the frames but the last are taken to weigh DASH_MOTION_EST_SHARE of it each, as base64.
#   The share is what the five stand-in charts of the test dashboard weighed (tests/motion_weight_12.R: 0.65 to 0.73; the early frames hold less ink).
DASH_MOTION_EST_SHARE <- 0.7
dash_motion_estimate <- function(chart, data, cb, palette, size = "desk") {
  f = tempfile(fileext = ".png")
  on.exit(unlink(f))
  p = video_plot(chart$spec, data, cb, palette, bare = TRUE, web = dash_web(size))
  cv = attr(p, "canvas")
  w = SPEC_VIDEO_DASH_PX[[size]][["width"]]
  video_draw(ggplot2::ggplot_build(p), f, cv[["width"]], cv[["height"]], w / cv[["width"]])
  4 / 3 * file.size(f) * DASH_MOTION_EST_SHARE * (video_frame_count() - 1L)
}

# The bytes an animated chart adds to a page beyond its finished picture: the frames but the last, as base64 (four characters for three bytes).
motion_added_bytes <- function(mo) sum(4 * ceiling(file.size(utils::head(mo$files, -1L)) / 3))

# The markup of an animated chart: the box, the finished chart as an <img> (`last`: its data address), the frames, and the Replay button. `css` is the width and height
#   it is shown at, in CSS pixels; `fps` the frames a second. `first` (Phase 12c), the data address of frame 0, is a second <img> laid over the finished one and shown
#   only while the page is marked motion-js and the box has not played (DASH_VIDEO_CSS), so a card that is going to play shows the start of its motion from the
#   first paint; without script, under reduced motion and in print it is not shown. It is decorative (empty alt, hidden from assistive technology).
#   `frames_id`: the id of the frames' element when it stands elsewhere in the page (motion_frames_tag()); without it, the frames are inside the box.
motion_tag <- function(frames_json, last, css, alt, fps = SPEC_VIDEO_FPS, first = NULL, frames_id = NULL) {
  tags$div(class = "motion", style = paste0("max-width:", css[["width"]], "px;"), `data-fps` = fps, `data-frames` = frames_id,
    tags$div(class = "motion-stage", tags$img(class = "motion-still", src = last, alt = alt, width = css[["width"]], height = css[["height"]]),
             if (!is.null(first)) tags$img(class = "motion-first", src = first, alt = "", `aria-hidden` = "true", decoding = "sync", width = css[["width"]], height = css[["height"]])),
    if (is.null(frames_id)) tags$script(type = "application/json", class = "motion-frames", HTML(frames_json)),
    tags$button(type = "button", class = "motion-replay", hidden = NA, `aria-label` = paste0("Replay the animation: ", alt), "Replay"))
}

DASH_MARKING_NOTE <- paste("The marking is written into every file of the zip: a band at the top and bottom of each page and picture (and of every frame of an animated chart), a first line of the script, the data dictionary",
                          "and each table's CSV (a reader must skip that line), and the start of the zip's name. It is your statement: chaRt does not judge or change it, and it is never sent to a model.",
                          "It cannot be blank, and it is at most", MARKING_MAX, "characters.")
DASH_INTRO_NOTE <- "Plain text, shown as you write it. It is not checked by the number check."
DASH_DESCRIBES <- "A chart describes the file, not the world."
DASH_ERROR_TEXT <- paste("The dashboard was not built, and nothing was saved. Your charts, texts and choices are unchanged, so you can press",
                         "the button again. If it fails again, the last lines of the message below say which step failed.")

# The page and its pictures (Phase 9). The cards stand in a column at most DASH_PAGE_PX wide, centred, two to a row from DASH_TWO_PX
#   and one below. A chart is drawn for the width it is shown at, so its text comes out near 12 CSS pixels: DASH_DESK_PX for a card
#   that shares its row, DASH_WIDE_PX for one that has the row to itself (Phase 12c: the whole width of the row, about 1,155 CSS pixels inside a card of the
#   widest page, with its texts under it; DASH_ASPECT keeps it to half as high as wide), and a narrower drawing of DASH_PHONE_PX for a screen of
#   at most DASH_PHONE_MAX_PX pixels. A drawing is made at 96 CSS pixels to the inch and DASH_SCALE pixels for each one it is shown
#   at, so it is sharp on a screen of twice the density. DASH_ASPECT is its height over its width.
DASH_PAGE_PX <- 1240L
DASH_TWO_PX <- 900L
DASH_PHONE_MAX_PX <- 599L
DASH_DESK_PX <- 540L
DASH_WIDE_PX <- 1150L
DASH_PHONE_PX <- 340L
DASH_PRINT_ROOM_MM <- c(one = 17, two = 22)   # the room a printed page keeps at its top and at its bottom for the classification band: a marking of one line, and a long one (over 55 characters) that may wrap to two
DASH_ASPECT <- c(desk = 0.64, wide = 0.5, phone = 0.8)
DASH_SCALE <- 2L
DASH_CSS_DPI <- 96L
DASH_KEYS_MAX <- 3L             # key numbers the analyst may add, each a line of a chart's facts
DASH_KEYS_STRIP_MAX <- 6L       # the strip at the top of the page holds at most these: the file's three and the analyst's three
DASH_KEY_SHORT <- 14L           # a key value of this many characters or fewer is a number: it does not wrap and its type shrinks to its cell
DASH_FULL_PANELS <- 4L          # a chart with more panels than this (small multiples) takes a whole row of the page
DASH_PICTURE_SIZES <- c("desk", "wide", "phone")
DASH_PX <- c(desk = DASH_DESK_PX, wide = DASH_WIDE_PX, phone = DASH_PHONE_PX)

# The lines of a chart's facts that say what the chart is about and carry no number a reader would want in a box.
DASH_FACT_SKIP <- c("Plotted", "Filter", "Shown", "Highlighted", "Fitted curve", "Rows used", "Rows after the filter", "Groups shown",
                    "Rows left out for missing values", "Exploratory", "Values", "Groups at the highest value", "Points", "Points per series")

# How each style's page differs beyond its colours and typefaces (the look of its masthead, its cards and its strip of key numbers), as CSS over the
#   custom properties --bg, --text, --text2, --caption, --grid, --box, --accent and --rule. A style with no entry is drawn as Clean.
DASH_LOOK <- list(
  clean = paste0(".masthead{border-bottom:3px solid var(--accent);}",
                 ".card{background:var(--bg);border:1px solid var(--grid);border-radius:.5rem;padding:1rem;}"),
  minimal = paste0(".masthead{border-bottom:1px solid var(--text2);}",
                   ".card{background:transparent;border:0;border-top:1px solid var(--text2);border-radius:0;padding:.75rem 0 0;}",
                   ".keys{border-top:3px solid var(--accent);border-bottom:0;}"),
  magazine = paste0(".masthead{border-top:10px solid var(--accent);padding-top:1.25rem;}",
                    ".card{background:var(--bg);border:3px solid var(--grid);border-radius:.25rem;padding:1rem;}",
                    ".keys{border-top:6px solid var(--accent);border-bottom:3px solid var(--grid);}"),
  desk = paste0(".masthead{border-bottom:5px solid var(--text);}",
                ".card{background:var(--bg);border:2px solid var(--grid);border-radius:0;padding:1rem;}",
                ".keys{border-top:5px solid var(--text);border-bottom:2px solid var(--grid);}",
                ".key-label,.card-sub{text-transform:uppercase;letter-spacing:.04em;font-size:.78rem;}"),
  newspaper = paste0(".masthead{text-align:center;border-top:4px solid var(--rule);border-bottom:1px solid var(--rule);padding:1.1rem 0 1.2rem;}",
                     ".masthead .intro{margin-left:auto;margin-right:auto;text-align:left;}",
                     ".card{background:transparent;border:0;border-top:1px solid var(--rule);border-radius:0;padding:.75rem 0 0;}",
                     ".keys{border-top:2px solid var(--rule);}"),
  dark = paste0(".masthead{border-bottom:3px solid var(--accent);}",
                ".card{background:var(--bg);border:1px solid var(--grid);border-radius:.8rem;padding:1.1rem;}"),
  # Briefing: a hairline round each card and no shadow, headings in condensed upper case over small grey subtitles (the span `keep` holds a number
  #   or a unit as written), the strip of key numbers between two hairlines with its numbers in the condensed face.
  briefing = paste0(".masthead{border-bottom:1px solid var(--text);padding-bottom:1rem;}",
                    "h1,.card h2,.stat-title{text-transform:uppercase;letter-spacing:.005em;}",
                    ".subtitle{font-size:1.05rem;}",
                    ".card{background:var(--bg);border:1px solid #AEB3BA;border-radius:2px;padding:1rem 1.15rem;box-shadow:none;}",
                    ".card h2{font-size:1.5rem;line-height:1.08;margin-bottom:.35rem;}",
                    ".card-sub{font-size:.88rem;margin-bottom:.5rem;}",
                    ".keys{border-top:1px solid var(--text);border-bottom:1px solid var(--text);}",
                    ".key-value{--max:2.6rem;}"))


# The class attribute from names, leaving out the ones that are NULL ("card" or "card full", never "card ").
css_class <- function(...) paste(c(...), collapse = " ")

# What spec_plot() is told of a drawing for the page, by its size (desk, wide or phone): the inches it is shown at (CSS pixels over 96),
#   no title, subtitle or source line, and fewer breaks on the x axis of the phone drawing.
dash_web <- function(size) {
  width = DASH_PX[[size]] / DASH_CSS_DPI
  list(width = width, height = round(width * DASH_ASPECT[[size]], 2), bare = TRUE, few_breaks = identical(size, "phone"))
}

# Which cards of the page take a whole row, given the cards that must (an interactive chart, a chart drawn wide): `wide`, one
#   flag for each card in order. The page is two columns wide, so a card that is not wide shares its row with the next; a wide
#   card takes the row, and the card before it, left alone in its row, takes a whole row too (as does a last card with no
#   partner), so that no row of the page has a hole. Returns a flag for each card: TRUE for a card that has its row.
dash_layout <- function(wide) {
  n = length(wide)
  out = purrr::reduce(seq_len(n), function(st, i) {
    if (isTRUE(wide[[i]])) {
      if (st$open) st$full[[st$last]] = TRUE
      st$full[[i]] = TRUE
      st$open = FALSE
    } else if (st$open) {
      st$open = FALSE
    } else {
      st$open = TRUE
      st$last = i
    }
    st
  }, .init = list(full = rep(FALSE, n), open = FALSE, last = 0L))
  if (out$open) out$full[[out$last]] = TRUE
  out$full
}

# The same, a section at a time: a heading takes a whole row, so a card does not share its row with one of another section. `section` is the id of the section
#   each card stands under ("" for none), in order.
dash_layout_by <- function(wide, section) {
  if (!length(wide)) return(logical(0))
  runs = rep(seq_along(rle(section)$lengths), rle(section)$lengths)
  unlist(purrr::map(unname(split(wide, factor(runs, levels = unique(runs)))), dash_layout))
}

# The rows of a page that have a hole, given which cards have a row to themselves: lay the cards out two to a row, in order, as the
#   page's grid does, and count the rows that hold one card that is not full. (The page's own layout leaves none.)
dash_holes <- function(full) {
  out = purrr::reduce(full, function(st, f) {
    if (isTRUE(f)) { if (st$open) st$holes = st$holes + 1L; st$open = FALSE }
    else st$open = !st$open
    st
  }, .init = list(open = FALSE, holes = 0L))
  out$holes + as.integer(out$open)
}

# Whether a chart's interactive version carries the values of the rows it plots: a scatter, bubble or box chart does, and so does any
#   other chart whose marks are rows (fn none: one row for each bar, dot, line point or cell). A bar, line or heatmap of totals
#   (count, share, sum, mean, median) carries only its totals, and a histogram only its bins.
chart_from_rows <- function(spec) {
  s = spec_defaults(spec_public(spec))
  fam = s$family %||% ""
  fam %in% DASH_ROW_FAMILIES || (fam %in% DASH_TOTAL_FAMILIES && identical(s$fn %||% "none", "none"))
}

# The way a chart goes into the dashboard when the dialog opens: a picture, unless it is not drawn from rows and its card is
#   showing the interactive version.
dashboard_default_mode <- function(chart, interactive_now = FALSE)
  if (chart_from_rows(chart$spec) || !isTRUE(interactive_now)) "picture" else "interactive"

# The warnings of the dialog, as sentences named by what they are about (changed, palette, small groups). `titles` and `stale` (NA, "chart"
#   or "data", as story_stale() says) describe the chosen charts in order (Phase 13: no chart is without a headline now, R writes one, so the
#   warning of one that had none is gone); the palette is the three chosen. `small` is
#   the titles of the summary tables that show a group of fewer than SUMMARY_SMALL_ROWS rows: one warning for all of them (nothing is hidden).
dashboard_warnings <- function(titles, stale, palette, small = character(0)) {
  bad = purrr::keep(names(EXPLORE_PALETTE_KINDS), function(k) !palette_passes(palette[[k]]))
  c(if (any(!is.na(stale)))
      list(changed = paste0("Marked as changed since it was written: ", paste(titles[!is.na(stale)], collapse = "; "),
                            ". The page shows the headline and summary as they are now, and each card in the page says nothing of this; write them again first if you want them to match."))
    else NULL,
    if (length(bad))
      list(palette = paste(purrr::map_chr(bad, function(k) paste0("The ", tolower(EXPLORE_PALETTE_KINDS[[k]]), " palette (", CHART_PALETTES[[palette[[k]]]]$label, "): ",
                                                                   PALETTE_CVD_WARNING)), collapse = " "))
    else NULL,
    if (length(small)) list(small_groups = paste0(SUMMARY_SMALL_WARNING, " Marked in: ", paste(small, collapse = "; "), "."))
    else NULL)
}

# ---- the classification marking (Phase 10 Part A) ---------------------------------------------------------------------------
# What the analyst writes in the export dialog, as svysegment's report has it: the marking is the analyst's statement, and the app does
#   not judge it or change its words. It is written into every file of the export (the band at the top and bottom of each page, picture and
#   video; the first line of charts.R, data_dictionary.yaml and each CSV; the name of the zip) and is never sent to a model. The default is
#   APP_CLASSIFICATION, the marking shown above every screen (app.R). marking_clean() is the one gate: it takes what was typed and returns
#   list(ok, text, why). Runs of white space and control characters (a newline, a tab) become one space and the ends are trimmed, so the
#   marking is always one line (it cannot end a comment line of a script or a yaml file); a blank one is refused, and one of more than
#   MARKING_MAX characters is refused with its length (the app does not cut it: a marking cut short is not what the analyst said).
MARKING_BLANK <- "Every export is marked, even if the marking is UNCLASSIFIED: write the marking in the box, then build the dashboard."
marking_long <- function(n) paste0("The marking is ", n, " characters; the most is ", MARKING_MAX, ". Shorten it: the app does not cut a marking for you.")

marking_clean <- function(x) {
  one = if (is_text1(x) && validUTF8(x)) trimws(gsub("[[:space:][:cntrl:]]+", " ", enc2utf8(x))) else ""
  n = nchar(one)
  list(ok = n > 0L && n <= MARKING_MAX, text = one, why = if (!n) MARKING_BLANK else if (n > MARKING_MAX) marking_long(n))
}

# The marking to write: what `x` says, or APP_CLASSIFICATION when nothing was given (NULL); a refused marking stops with its sentence.
marking_of <- function(x = NULL) {
  m = marking_clean(if (is.null(x)) APP_CLASSIFICATION else x)
  if (!m$ok) stop(m$why, call. = FALSE)
  m$text
}

# The marking as the start of a file name: lower case, every run of characters that are not letters or digits one underscore, none at either
#   end, ASCII only (accents are transliterated or dropped), so no path character can be in it; "marked" when nothing is left.
marking_slug <- function(x) {
  s = gsub("^_+|_+$", "", gsub("[^a-z0-9]+", "_", tolower(iconv(as.character(x), to = "ASCII//TRANSLIT", sub = ""))))
  if (length(s) != 1L || is.na(s) || !nzchar(s)) "marked" else s
}

# The first line of a script, a yaml file or a CSV: the marking as a comment.
marking_comment <- function(x) paste0("# ", marking_of(x))

# Puts a comment line first in `file` (after a byte-order mark when it has one, so that the file still starts as UTF-8 with a mark).
marking_prepend <- function(file, line) {
  raw = readBin(file, "raw", file.size(file))
  bom = length(raw) >= 3L && identical(raw[1:3], as.raw(c(0xef, 0xbb, 0xbf)))
  keep = if (bom) 3L else 0L
  writeBin(c(raw[seq_len(keep)], charToRaw(enc2utf8(paste0(line, "\n"))), raw[seq_len(length(raw) - keep) + keep]), file)
  invisible(file)
}

# The marking's text box in the export dialog: a text input with the browser's own limit of MARKING_MAX characters (marking_clean() refuses more).
marking_input <- function(id, value)
  htmltools::tagQuery(textInput(id, "Classification marking", value = value, width = "100%"))$find("input")$addAttrs(maxlength = MARKING_MAX, autocomplete = "off")$allTags()

# The band of a page: the marking in white bold type, letter-spaced, on #b40404 (the colour, weight and spacing of svysegment's report), full width,
#   outside the page's width-limited column. `where` is "top" or "bottom"; the text is escaped, quotes included.
dash_band <- function(marking, where) {
  tags$div(class = paste("mark", where), role = "note", `aria-label` = "Classification marking", htmltools::HTML(htmltools::htmlEscape(marking, attribute = TRUE)))
}
# A chart's title as a file name: lower-case ASCII words joined by underscores, at most 40 characters.
dash_slug <- function(x) {
  s = gsub("^_+|_+$", "", gsub("[^a-z0-9]+", "_", tolower(iconv(as.character(x), to = "ASCII//TRANSLIT", sub = ""))))
  if (is.na(s) || !nzchar(s)) "chart" else substr(s, 1L, 40L)
}

# The long form of a date, from month.name so that it does not depend on the server's locale.
dash_date_text <- function(d)
  paste(as.integer(format(d, "%d")), month.name[as.integer(format(d, "%m"))], format(d, "%Y"))

dash_b64 <- function(file) gsub("[\r\n]", "", jsonlite::base64_enc(readBin(file, "raw", file.size(file))))   # base64_enc() breaks its lines; a url() may not hold one
dash_data_uri <- function(file, type) paste0("data:", type, ";base64,", dash_b64(file))
dash_read_text <- function(file) {
  x = rawToChar(readBin(file, "raw", file.size(file)))
  Encoding(x) = "UTF-8"
  x
}

# The bundled typefaces the style uses (its title, subtitle and body families: regular and bold, and the semibold face when the
#   style's title is semibold) as @font-face rules with the font files in the rule itself, so the page needs no file beside it.
dash_font_css <- function(style) {
  st = chart_style(style)
  roles = unique(c("sans", st$title_font, st$subtitle_font))
  face = function(family, weight, file) {
    path = file.path(CHART_FONT_DIR, file)
    if (file.exists(path))
      paste0("@font-face{font-family:'", family, "';font-weight:", weight, ";font-style:normal;src:url('data:font/ttf;base64,", dash_b64(path),
             "') format('truetype');}")
  }
  paste(unlist(purrr::map(roles, function(r) {
    f = CHART_FONTS[[r]]
    c(if (!identical(f$weights, 700)) face(f$family, 400, f$regular), face(f$family, 700, f$bold),
      if (identical(st$title_weight, "semibold") && identical(r, st$title_font)) face(paste(f$family, "SemiBold"), 400, f$semibold))
  })), collapse = "\n")
}

# The page's stylesheet in the chosen style's colours, typefaces and look (DASH_LOOK): a column centred at most DASH_PAGE_PX wide, a grid
#   of two cards to a row from DASH_TWO_PX and one below, a phone rule, and a print stylesheet that keeps each card whole on a page and
#   prints on a light ground whatever the style. The colours are custom properties.
dash_css <- function(style, accent) {
  st = chart_style(style)
  title_css = function(role) CHART_FONTS[[role]]$css
  title_family = if (identical(st$title_weight, "semibold")) paste0("'", CHART_FONTS[[st$title_font]]$family, " SemiBold', ", title_css(st$title_font)) else title_css(st$title_font)
  title_weight = if (identical(st$title_weight, "bold")) 700 else 400
  h1_rem = round(0.9 + 1.4 * st$title_size, 2)
  look = DASH_LOOK[[style]] %||% DASH_LOOK[["clean"]]
  paste0(
    ":root{--bg:", st$background, ";--text:", st$text, ";--text2:", st$text_2, ";--caption:", st$caption, ";--grid:", st$grid, ";--box:", st$box_fill,
    ";--accent:", accent, ";--rule:", if (is.na(st$rule)) st$text else st$rule, ";--title-font:", title_family, ";}\n",
    "*{box-sizing:border-box;}\n",
    "html{-webkit-text-size-adjust:100%;}\n",
    "body{margin:0;background:var(--bg);color:var(--text);font-family:", title_css("sans"), ";line-height:1.5;}\n",
    # The classification band (dash_band()): the same red whatever the style, outside the page's column; a long marking wraps inside it.
    ".mark{background:", MARKING_COLOUR, ";color:#fff;text-align:center;font-weight:700;letter-spacing:.06em;font-size:13px;line-height:1.4;padding:5px 12px;overflow-wrap:anywhere;}\n",
    ".page{max-width:", DASH_PAGE_PX, "px;margin:0 auto;padding:1.5rem 1.5rem 3rem;}\n",
    ".masthead{padding:0 0 1.25rem;margin-bottom:1.5rem;}\n",
    "h1{font-family:var(--title-font);font-weight:", title_weight, ";font-size:clamp(1.8rem,4.5vw,", h1_rem, "rem);line-height:1.15;margin:0 0 .4rem;overflow-wrap:anywhere;}\n",
    ".subtitle{font-family:", title_css(st$subtitle_font), ";color:var(--text2);font-size:1.25rem;margin:0;overflow-wrap:anywhere;}\n",
    ".byline{color:var(--caption);font-size:.9rem;margin:.7rem 0 0;}\n",
    ".intro{max-width:70ch;margin-top:1rem;font-size:1.05rem;}\n.intro p{margin:.5rem 0;}\n",
    # The key numbers: a strip, a number large over its words, a thin rule between the items and no boxes. A number never wraps or is cut: its type
    #   shrinks to the width of its own cell (a container query unit, with --w its width in ems, estimated by dash_value_em()), and a cell has a least
    #   width, so a strip of six becomes two rows before the type gets small. The left rule of each item is pulled over the one before it, and the
    #   first of each row is clipped.
    ".keys{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,10.5rem),1fr));overflow:hidden;margin:0 0 1.5rem;border-top:1px solid var(--rule);border-bottom:1px solid var(--grid);}\n",
    ".key{min-width:0;margin-left:-1px;padding:.85rem 1.1rem .9rem;border-left:1px solid var(--grid);}\n",
    ".keys{align-items:start;}\n",
    ".key-label{color:var(--text2);font-variant-caps:all-small-caps;letter-spacing:.06em;font-size:.95rem;line-height:1.3;margin:0 0 .1rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}\n",
    ".key-value{--max:2.1rem;font-family:var(--title-font);font-size:var(--max);font-weight:700;line-height:1.1;overflow-wrap:break-word;text-wrap:balance;}\n",
    ".key-value.num{white-space:nowrap;}\n",
    "@supports (width:1cqi){.key{container-type:inline-size;}.key-value{font-size:min(var(--max),calc(100cqi / var(--w)));}}\n",
    ".key-what{color:var(--caption);font-size:.85rem;line-height:1.3;margin-top:.3rem;overflow-wrap:anywhere;}\n",
    ".grid{display:grid;grid-template-columns:minmax(0,1fr);gap:1.25rem;align-items:stretch;}\n",
    "@media (min-width:", DASH_TWO_PX, "px){.grid{grid-template-columns:repeat(2,minmax(0,1fr));}.card.full{grid-column:1/-1;}.card.full img,.card.full .widget{max-width:none;}}\n",
    # A section's heading (Phase 11 Part E): across the row, over the cards under it, a rule in the accent above it.
    ".section-head{grid-column:1/-1;margin:.9rem 0 -.25rem;padding-top:.7rem;border-top:2px solid var(--accent);}\n",
    ".section-head h2{font-family:var(--title-font);font-weight:", title_weight, ";font-size:1.6rem;line-height:1.2;margin:0;overflow-wrap:anywhere;}\n",
    ".section-head p{color:var(--text2);margin:.35rem 0 0;max-width:70ch;overflow-wrap:anywhere;}\n",
    if (identical(st$title_case, "upper")) ".section-head h2{text-transform:uppercase;letter-spacing:.005em;}.section-head h2 .keep{text-transform:none;}\n",
    "@media print{.section-head{break-after:avoid;page-break-after:avoid;margin:1rem 0 .5rem;}}\n",
    # A card is a column that fills the height of its row (the grid stretches it); its chart's slot takes what is left, so the chart stands in the
    #   middle of the card and no blank block is under a short one.
    ".card{min-width:0;display:flex;flex-direction:column;}\n.card .slot{flex:1 1 auto;display:flex;flex-direction:column;justify-content:center;min-width:0;}\n",
    # A card that has a row to itself (Phase 12c): its chart across the whole row (drawn at DASH_WIDE_PX), its texts under it, as in a card that shares its
    #   row. (Phase 10b put the texts in a column on the right of a chart 62% wide.)
    ".card h2{font-family:var(--title-font);font-weight:", title_weight, ";font-size:1.3rem;line-height:1.3;margin:0 0 .5rem;overflow-wrap:anywhere;}\n",
    ".card-sub{color:var(--text2);font-size:.95rem;margin:0 0 .6rem;overflow-wrap:anywhere;}\n",
    ".card-note{color:var(--caption);font-size:.85rem;margin:0 0 .6rem;overflow-wrap:anywhere;}\n",
    ".card picture{display:block;}\n.card img.print-only{display:none;}\n",
    ".card img{display:block;width:100%;max-width:700px;height:auto;}\n",
    ".widget{width:100%;max-width:700px;overflow:hidden;}\n", DASH_VIDEO_CSS,
    # Under a chart, three sizes: the summary at a reading size and a measure of at most 62 characters, the notes smaller and grey, the source line smallest.
    ".summary{font-size:1.05rem;line-height:1.55;max-width:62ch;margin:.9rem 0 0;}\n",
    ".notes{color:var(--text2);font-size:.82rem;line-height:1.45;max-width:75ch;margin:.7rem 0 0;padding-left:1.1rem;}\n",
    ".source{color:var(--caption);font-size:.72rem;margin:.6rem 0 0;overflow-wrap:anywhere;}\n",
    ".keep{text-transform:none;}\n",
    ".foot{margin-top:2.5rem;padding-top:1.25rem;border-top:1px solid var(--rule);}\n",
    ".foot h2{font-family:var(--title-font);font-weight:", title_weight, ";font-size:1.1rem;margin:0 0 .5rem;}\n",
    ".about dl{margin:0;}\n.about dt{font-weight:700;margin-top:.7rem;}\n.about dd{margin:.1rem 0 0;color:var(--text2);overflow-wrap:anywhere;max-width:70ch;}\n",
    ".about ul{margin:.2rem 0 0;padding-left:1.1rem;}\n",
    ".made{color:var(--caption);font-size:.85rem;margin:1.5rem 0 0;}\n",
    "a{color:var(--text);text-decoration-thickness:1px;}\n",
    ".muted{color:var(--caption);}\n",
    ".table-scroll{overflow-x:auto;margin:0 0 2rem;}\n",
    ".summary-table{width:100%;border-collapse:collapse;font-size:.9rem;}\n",
    ".summary-table th{text-align:left;color:var(--text2);font-weight:700;border-bottom:2px solid var(--text);}\n",
    ".summary-table th,.summary-table td{padding:.35rem .8rem .35rem 0;border-bottom:1px solid var(--grid);vertical-align:top;}\n",
    ".summary-table td.n,.summary-table th.n{text-align:right;white-space:nowrap;}\n",
    ".col-section{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,21rem);gap:.1rem 1.75rem;padding:1.1rem 0;border-top:1px solid var(--grid);break-inside:avoid;}\n",
    ".col-section>h2,.col-section>.name{grid-column:1/-1;}\n",
    ".col-section h2{font-family:var(--title-font);font-weight:", title_weight, ";font-size:1.15rem;margin:0;overflow-wrap:anywhere;}\n",
    ".col-section .name{color:var(--caption);font-size:.85rem;margin:0 0 .5rem;overflow-wrap:anywhere;}\n",
    ".col-section dl{display:grid;grid-template-columns:minmax(7rem,max-content) 1fr;gap:.25rem .9rem;margin:0;font-size:.95rem;}\n",
    ".col-section dt{color:var(--text2);}\n.col-section dd{margin:0;overflow-wrap:anywhere;}\n",
    ".col-section figure{margin:0;align-self:start;}\n.col-section figure img{display:block;width:100%;height:auto;}\n.col-section figure img.print-only{display:none;}\n",
    ".col-section figcaption{color:var(--caption);font-size:.8rem;margin-top:.15rem;}\n",
    ".levels{border-collapse:collapse;margin:.25rem 0 0;font-size:.9rem;width:100%;max-width:28rem;}\n",
    ".levels th,.levels td{border-bottom:1px solid var(--grid);padding:.2rem .5rem;text-align:left;overflow-wrap:anywhere;}\n",
    ".levels td.n{text-align:right;white-space:nowrap;}\n",
    # The summary tables (a card of the page): a real table that scrolls sideways inside its own box when it is wider than its place.
    ".stat-block{margin:0 0 1rem;}.stat-title{font-weight:700;margin:0 0 .25rem;color:var(--text2);}\n",
    ".stat-block .table-scroll{overflow-x:auto;margin:0;max-width:100%;}\n",
    ".stat-table{border-collapse:collapse;font-size:.85rem;width:100%;}\n",
    ".stat-table th{text-align:left;color:var(--text2);font-weight:700;white-space:nowrap;border-bottom:2px solid var(--text);padding:.3rem .8rem .3rem 0;vertical-align:bottom;}\n",
    ".stat-table td{padding:.3rem .8rem .3rem 0;border-bottom:1px solid var(--grid);vertical-align:top;}\n",
    ".stat-table td.n,.stat-table th.n{text-align:right;white-space:nowrap;}\n",
    ".table-scroll.has-notes{margin-bottom:.4rem;}.page>.stat-notes{margin:0 0 2rem;}\n",
    ".stat-notes .stat-note{color:var(--caption);font-size:.8rem;margin:.3rem 0 0;max-width:80ch;}\n",
    look, "\n",
    "@media (max-width:", DASH_PHONE_MAX_PX, "px){.page{padding:1rem .75rem 2rem;}.card{padding:.75rem;}.col-section{grid-template-columns:minmax(0,1fr);}.col-section dl{grid-template-columns:1fr;gap:0;}",
    ".col-section dd{margin-bottom:.4rem;}.summary-table{font-size:.8rem;}.summary-table th,.summary-table td{white-space:nowrap;}.stat-table th,.stat-table td{white-space:nowrap;}.keys{grid-template-columns:repeat(2,minmax(0,1fr));}.key{padding:.7rem .8rem .75rem;}.key-value{--max:1.7rem;}}\n",
    # Print. The classification band is fixed: Chrome repeats a fixed box at the top and at the bottom of the content area of every printed page, and a
    #   fixed box covers what is under it. Negative offsets do not move it into the margin (looked at in a PDF: the band is clipped or misplaced), and a
    #   repeating table header and footer did not repeat for a column that is one row. So the sheet has no margin at the top and bottom, the bands stand
    #   6 mm inside its edges (a printer cannot print to the edge), and the page's column has top and bottom padding that is repeated on every fragment of
    #   it (box-decoration-break: clone), as deep as the band needs (DASH_PRINT_ROOM_MM): content never runs under a band.
    "@page{margin:0;}\n",
    "@media print{:root{--bg:#FFFFFF;--text:#111111;--text2:#333333;--caption:#555555;--grid:#BBBBBB;--box:#F2F2F2;--rule:#111111;}",
    ".mark{position:fixed;left:8mm;right:8mm;}.mark.top{top:6mm;}.mark.bottom{bottom:6mm;}",
    "body{-webkit-print-color-adjust:exact;print-color-adjust:exact;background:#FFFFFF;color:#111111;}.page{max-width:none;padding:", DASH_PRINT_ROOM_MM[["one"]], "mm 14mm;box-decoration-break:clone;-webkit-box-decoration-break:clone;}",
    "body.long .page{padding-top:", DASH_PRINT_ROOM_MM[["two"]], "mm;padding-bottom:", DASH_PRINT_ROOM_MM[["two"]], "mm;}",
    ".grid{display:block;}.card,.col-section,.key,.foot{break-inside:avoid;page-break-inside:avoid;}.card{margin:0 0 .8rem;}.card img{width:auto;max-width:100%;max-height:6.6in;}.card picture.screen-only,.card .motion-wrap.screen-only{display:none;}.card img.print-only,.col-section figure img.print-only{display:block;}.motion canvas.motion-canvas,.motion .motion-replay{display:none !important;}.motion img.motion-still{visibility:visible !important;max-width:100%;}.col-section figure img.screen-only{display:none;}",
    ".keys{display:flex;flex-wrap:wrap;overflow:visible;}.key{flex:1 1 10rem;}.masthead{break-after:avoid;}h2{break-after:avoid;}.stat-block .table-scroll{overflow:visible;}.stat-table{font-size:.7rem;}}\n")
}

# The three key numbers about the file, by key (rows, columns, third): `title` names the choice in the export dialog, `label` is the small
#   label over the value ("Rows", "Columns", "Period" or "File"), `value` the value ("3,000", "22", "Jan 2022 to Dec 2024" or the file's name),
#   `full` the text to show in full (the tooltip: the first and last date, or the whole name), `cls` the class of a long value.
canvas_box_values <- function(data, cb) {
  time = purrr::detect(cb$columns, function(e) identical(e$role, "time"))
  period = if (!is.null(time) && time$name %in% names(data)) tryCatch(period_text(range(data[[time$name]], na.rm = TRUE)), error = function(e) NULL)
  n_rows = nrow(data)
  n_cols = ncol(data)
  list(rows = list(title = "Rows", label = if (n_rows == 1L) "Row" else "Rows", value = format_num(n_rows), full = format_num(n_rows), cls = ""),
       columns = list(title = "Columns", label = if (n_cols == 1L) "Column" else "Columns", value = format_num(n_cols), full = format_num(n_cols), cls = ""),
       third = if (!is.null(period)) list(title = "Period", label = "Period", value = period$short, full = period$full, cls = "chart-box-period")
               else list(title = "File", label = "File", value = cb$file %||% "", full = paste0(cb$file %||% "", if (is_text1(cb$sheet)) paste0(", sheet ", cb$sheet)), cls = "chart-box-file"))
}

# The scripts and style sheets of a widget's dependencies, read from the installed packages' files, as <style> and <script>
#   elements. A dependency that is only an address (no file on this server) cannot be written into the page and stops the build.
dash_dependency_dir <- function(dep) {
  src = dep$src
  if (!is.null(dep$package) && !is.null(src$file)) system.file(src$file, package = dep$package) else src$file
}
dash_dependency_files <- function(x) unlist(purrr::map(x, function(f) if (is.list(f)) f$src else f))
dash_inline_dependencies <- function(deps) {
  purrr::map(deps, function(dep) {
    dir = dash_dependency_dir(dep)
    if (is.null(dir) || !nzchar(dir) || !dir.exists(dir))
      stop("The interactive charts need the files of '", dep$name, "', and this server does not have them on disk.", call. = FALSE)
    css = file.path(dir, dash_dependency_files(dep$stylesheet))
    js = file.path(dir, dash_dependency_files(dep$script))
    missing = c(css, js)[!file.exists(c(css, js))]
    if (length(missing)) stop("A file of '", dep$name, "' is not on this server: ", basename(missing[1]), ".", call. = FALSE)
    tagList(purrr::map(css, function(f) tags$style(HTML(dash_read_text(f)))),
            # a script's text must not hold the end of a script element
            purrr::map(js, function(f) tags$script(HTML(gsub("</script", "<\\\\/script", dash_read_text(f), ignore.case = TRUE, perl = TRUE)))))
  })
}

# The widget of an interactive chart as the page holds it: the element and its data as JSON, and the dependencies it needs.
dash_widget <- function(w) {
  # the box is as wide as the card and as tall as the SVG makes it (the SVG scales with the box; htmlwidgets' own default is 960 by 500 pixels)
  w$width = "100%"
  w$height = "auto"
  tg = htmltools::as.tags(w)
  list(html = htmltools::renderTags(tg)$html, deps = htmltools::findDependencies(tg))
}

# The paragraphs of the introduction, as plain text.
dash_paragraphs <- function(x) {
  x = trimws(x %||% "")
  if (nzchar(x)) purrr::map(strsplit(x, "[[:space:]]*\n[[:space:]]*\n[[:space:]]*")[[1]], function(p) tags$p(trimws(p)))
}

# The paragraph of www/methodology.md that says a chart describes the file (the manager's words, read from the file; the sentence
#   alone if the file cannot be read).
dash_describes <- function(path = METHODOLOGY_FILE) {
  lines = tryCatch(readLines(path, encoding = "UTF-8", warn = FALSE), error = function(e) character(0))
  at = grep(DASH_DESCRIBES, gsub("*", "", lines, fixed = TRUE), fixed = TRUE)
  if (!length(at)) return(DASH_DESCRIBES)
  rest = lines[at[1]:length(lines)]
  blank = which(!nzchar(trimws(rest)))
  para = rest[seq_len(if (length(blank)) blank[1] - 1L else length(rest))]
  gsub("[[:space:]]+", " ", trimws(gsub("*", "", paste(para, collapse = " "), fixed = TRUE)))
}

# What each chart's text got from the checks, for the About card: the sentence and whether it passed.
dash_text_status <- function(it) {
  st = it$story
  if (is.null(st) || !is_text1(st$headline) || !nzchar(trimws(st$headline))) return("has no headline or summary")
  if (length(st$problems)) paste0("did not pass the checks (", paste(st$problems, collapse = "; "), ")")
  else "passed the number check and the word check"
}

# Who wrote a card's headline, for the About block (Phase 13).
DASH_HEADLINE_BY <- c(r = "written by R from the numbers it worked out from the file", model = "written by the model and checked against those numbers",
                      analyst = "written by the author and not checked", fallback = "R could not write one from those numbers, so it says what is plotted")

# The About block of the foot: the file, when, the model that wrote the text, which texts passed the checks, what is interactive, the note.
dash_about <- function(items, settings, cb, data, model) {
  texts = purrr::keep(items, function(it) !is.null(it$story) && is_text1(it$story$headline) && nzchar(trimws(it$story$headline)))
  fell = purrr::keep(items, function(it) !is.null(it$fallback))
  modes = purrr::map_chr(items, "mode")
  charts = purrr::keep(items, function(it) !identical(it$mode, "table"))
  tables = purrr::keep(items, function(it) identical(it$mode, "table"))
  entry = function(term, ...) list(tags$dt(term), tags$dd(...))
  tags$section(class = "about", `aria-labelledby` = "about-heading",
    tags$h2(id = "about-heading", "About this dashboard"),
    tags$dl(
      entry("The file", paste0(cb$file %||% "the data file", if (is_text1(cb$sheet)) paste0(", sheet ", cb$sheet), ": ", format_num(nrow(data)), " rows and ", format_num(ncol(data)), " columns.",
                               if (codebook_ready(cb)) paste0(" One row is ", trimws(cb$row_is), "."),
                               if (is_text1(cb$source) && nzchar(trimws(cb$source))) paste0(" Source: ", trimws(cb$source), "."))),
      entry("Made", paste0(dash_date_text(settings$date), if (nzchar(trimws(settings$author %||% ""))) paste0(", by ", trimws(settings$author)), ".")),
      entry("The text", if (length(texts)) paste0("The headlines and summaries were written by the model ", model,
                                                   " from numbers that chaRt worked out from the file, and each was checked against those numbers when it was written",
                                                   " or edited. The title, subtitle, author and introduction above are the author's own and are not checked.")
                        else "No headline or summary in this dashboard was written by a model. The title, subtitle, author and introduction above are the author's own and are not checked."),
      if (length(charts)) entry("The headlines", tags$ul(purrr::map(charts, function(it) tags$li(paste0(it$headline %||% it$title, " (", it$title, "): ",
                                                                         DASH_HEADLINE_BY[[it$headline_by %||% "r"]], "."))))),
      if (length(charts)) entry("What the checks said", tags$ul(purrr::map(charts, function(it) tags$li(paste0(it$title, ": ", dash_text_status(it), "."))))),
      if (any(purrr::map_lgl(charts, function(it) isTRUE(it$designed))))
        entry("Designed charts", paste0(sum(purrr::map_lgl(charts, function(it) isTRUE(it$designed))), " chart(s) were drawn from code that a model wrote, following ",
                                        paste(unique(purrr::map_chr(purrr::keep(charts, function(it) isTRUE(it$designed)), function(it) design_skill_label(it$design$skill))), collapse = " and "),
                                        ". R checked the code against a list of functions it may call, ran it on the table of the chart, and refused a drawing that cut off or covered text, left out rows, cut a bar's zero or wrote a number that was not in the chart's facts. The model was shown the picture of each chart it designed. ",
                                        "Each designed chart's script and table are in charts.R and charts/.")),
      if (length(charts)) entry("The charts", paste0(sum(modes == "picture"), if (sum(modes == "picture") == 1L) " picture" else " pictures",
                                 if (any(modes == "video")) paste0(", ", sum(modes == "interactive"), " interactive and ", sum(modes == "video"), " animated. ")
                                 else paste0(" and ", sum(modes == "interactive"), " interactive. "),
                                 if (any(modes == "interactive"))
                                   "An interactive chart carries the values of the rows it plots, in this file." else "A picture holds no row values.",
                                 if (any(modes == "video")) " An animated chart holds no row values: it is pictures of the chart.",
                                 purrr::map_chr(fell, function(it) paste0(" '", it$title, "' is a picture because its ", it$fallback_of %||% "interactive version", " could not be made: ", it$fallback)) |> paste(collapse = ""),
                                 purrr::map_chr(purrr::keep(items, function(it) is_text1(it$video_note)), function(it) paste0(" '", it$title, "': ", it$video_note)) |> paste(collapse = ""))),
      if (length(tables)) entry("The summary tables", paste0(length(tables), if (length(tables) == 1L) " table" else " tables", " of statistics, worked out by R from the rows of the file with no model; ",
                                 "each is also a CSV in charts/. A table shows statistics of columns and groups, never a row. The note under each says how its numbers were made. The tables: ",
                                 paste(purrr::map_chr(tables, "title"), collapse = "; "), ".")),
      entry("The data dictionary", "Column by column: ", tags$a(href = "codebook.html", "codebook.html"), " and data_dictionary.yaml, in the same folder."),
      entry("Read this first", dash_describes())))
}

# The picture of a card as the page holds it: a <picture> whose img is the drawing for a card of the card's size (the one with the
#   row to itself when the card has it), and whose sources, in the order a browser tries them, are the narrow drawing for a screen of at
#   most DASH_PHONE_MAX_PX pixels and, for a card that has a row to itself, the half-width drawing for a screen too narrow for two
#   columns. Each has twice the pixels it is shown at ("2x"). For print a second img, shown only when the page is printed (a browser does
#   not choose a <picture> source again for print): the drawing for a half-width card, in the Clean style when the page is dark (a dark
#   page prints on a light ground), for a dark style or a card that has its row.
dash_picture_tag <- function(it, full, alt) {
  p = it$pictures
  main = if (full && !is.null(p$wide)) p$wide else p$desk
  src = function(pic, media) htmltools::tag("source", list(media = media, srcset = paste0(pic$uri, " 2x")))
  paper = p$print %||% if (full && !is.null(p$wide)) p$desk
  tagList(
    tags$picture(class = if (!is.null(paper)) "screen-only",
      src(p$phone, paste0("(max-width:", DASH_PHONE_MAX_PX, "px)")),
      if (full && !is.null(p$wide)) src(p$desk, paste0("(max-width:", DASH_TWO_PX - 1L, "px)")),
      tags$img(src = main$uri, alt = alt, width = main$pixels[[1]], height = main$pixels[[2]])),
    if (!is.null(paper)) tags$img(class = "print-only", src = paper$uri, alt = alt, width = paper$pixels[[1]], height = paper$pixels[[2]]))
}

# An animated chart in the page (Phase 12): motion_tag() for its frames, shown as wide as they were drawn for (css pixels = the frames' pixels over DASH_SCALE), so its
#   text is the size it was drawn at. Phase 12c: on a screen of at most DASH_PHONE_MAX_PX pixels the motion is not shown (nor played) and the card is its phone
#   drawing, still; in print, when there is one, the print drawing (the half-width one for a card that has its row, the Clean one for a dark style).
# The id of an animated card's frames in the page, and their element, which the page puts after all its cards (NULL id: an item with no id keeps them in its box).
motion_frames_id <- function(it) if (!is.null(it$id)) paste0("motion-frames-", it$id)
motion_frames_tag <- function(it) tags$script(type = "application/json", class = "motion-frames", id = motion_frames_id(it), HTML(it$video$frames_json))
dash_video_tag <- function(it, alt) {
  v = it$video
  p = it$pictures
  tagList(
    tags$div(class = css_class("motion-wrap", if (!is.null(p$print)) "screen-only"),
             motion_tag(v$frames_json, v$last, round(v$px / DASH_SCALE), alt, v$fps %||% SPEC_VIDEO_FPS, v$first, motion_frames_id(it))),
    if (!is.null(p$phone)) tags$img(class = "motion-phone", src = p$phone$uri, alt = alt, width = p$phone$pixels[[1]], height = p$phone$pixels[[2]]),
    if (!is.null(p$print)) tags$img(class = "print-only", src = p$print$uri, alt = alt, width = p$print$pixels[[1]], height = p$print$pixels[[2]]))
}

# One card of the page: the headline as its heading (the chart's title, if there is no headline), the chart's title as its subtitle (and
#   the chart's own subtitle under it), the chart (a picture, or the widget), the summary, the notes the chart carries and the source
#   line, once. The drawing has no title and no source line. `full`: the card has a whole row to itself.
dash_card <- function(it, full = FALSE, style = NULL) {
  if (identical(it$mode, "table")) return(dash_table_card(it, full, style))
  headed = is_text1(it$headline) && nzchar(trimws(it$headline))
  alt = paste0(it$title, if (headed) paste0(". ", it$headline))
  tags$article(class = css_class("card", if (full) "full"),
    tags$h2(dash_heading_text(if (headed) it$headline else it$title, style %||% CHART_STYLE_DEFAULT)),
    if (headed) tags$p(class = "card-sub", it$title),
    if (is_text1(it$chart_subtitle) && nzchar(it$chart_subtitle)) tags$p(class = "card-note", it$chart_subtitle),
    # the chart's slot grows to the height of the row, so a short card has no blank block under it (the chart stands in the middle of it)
    tags$div(class = "slot",
      if (identical(it$mode, "interactive")) tagList(tags$div(class = "widget", HTML(it$widget_html)))
      else if (identical(it$mode, "video")) dash_video_tag(it, alt)
      else dash_picture_tag(it, full, alt)),
    if (is_text1(it$widget_note) && !identical(it$mode, "picture")) tags$p(class = "card-note", it$widget_note),
    if (is_text1(it$summary) && nzchar(trimws(it$summary))) tags$p(class = "summary", it$summary),
    if (length(it$notes)) tags$ul(class = "notes", purrr::map(it$notes, tags$li)),
    if (is_text1(it$source)) tags$p(class = "source", it$source))
}

# A line of a chart's facts that can be a key number, as list(label, value): the facts' own words, with a figure in them, from the facts
#   text (spec_facts()$text) and `tokens`, the map (token = name) of the ones that stand for names in it. A line that holds several figures
#   ("The line: first 39,000 (2022-01-01), last 142,000 (2024-12-01), ...") is one choice for each (commas inside brackets do not
#   split). The bookkeeping lines (what is plotted, the filter, the rows used) are not offered.
dash_fact_choices <- function(text, tokens = character(0)) {
  lines = trimws(strsplit(text %||% "", "\n", fixed = TRUE)[[1]])
  lines = sub("^- ", "", lines[nzchar(lines)])
  lines = lines[grepl("^[^:]+: .*[0-9]", lines) & !grepl("^Panel ", lines) & !sub(":.*$", "", lines) %in% DASH_FACT_SKIP]
  named = function(x) purrr::reduce(names(tokens), function(acc, tok) gsub(tok, tokens[[tok]], acc, fixed = TRUE), .init = x)
  unlist(purrr::map(lines, function(l) {
    label = sub(":.*$", "", l)
    pieces = trimws(strsplit(sub("^[^:]+: ", "", l), "(?<![0-9]), (?![^(]*\\))|; ", perl = TRUE)[[1]])
    pieces = pieces[grepl("[0-9]", pieces)]
    purrr::map(pieces, function(v) list(label = named(label), value = named(v)))
  }), recursive = FALSE)
}

# The key numbers of the page's top, as list(label, value, full, what, cls): the file's (rows, columns, the period or the file name, as chosen:
#   "Rows" over "3,000", "Columns" over "22", "Period" over "Jan 2022 to Dec 2024") and then the key numbers the analyst picked, each with what
#   it is as its label and the chart's name under its value. At most DASH_KEYS_STRIP_MAX (six).
dash_keys <- function(settings, cb, data, items) {
  file = canvas_box_values(data, cb)[intersect(c("rows", "columns", "third"), settings$boxes)]
  files = purrr::map(unname(file), function(b) list(label = b$label, value = b$value, full = b$full, what = NULL, cls = b$cls))
  keys = purrr::compact(purrr::map(unique(settings$keys %||% character(0)), function(k) {
    at = regexec("^(.*)\\|([0-9]+)$", k)[[1]]
    if (at[[1]] < 0L) return(NULL)
    id = regmatches(k, list(at))[[1]][2]
    n = as.integer(regmatches(k, list(at))[[1]][3])
    it = purrr::detect(items, function(m) identical(m$id, id))
    f = if (!is.null(it) && n >= 1L && n <= length(it$facts)) it$facts[[n]]
    if (!is.null(f)) list(label = f$label, value = f$value, full = f$value, what = it$title, cls = "")
  }))
  utils::head(c(files, utils::head(keys, DASH_KEYS_MAX)), DASH_KEYS_STRIP_MAX)
}

# The width of a key number's text in ems of its font, estimated (a digit 0.64, a comma, point or space 0.3, anything else 0.72, and 8% over; a
#   condensed face, `narrow`, 0.7 of that), so that the page can scale a number to the cell it sits in; never under 1, so that the size is never
#   a division by zero.
dash_value_em <- function(value, narrow = FALSE) {
  ch = strsplit(as.character(value), "")[[1]]
  round(max(1, (if (narrow) 0.7 else 1) * 1.08 * sum(dplyr::case_when(grepl("[0-9]", ch) ~ 0.64, ch %in% c(",", ".", " ") ~ 0.3, TRUE ~ 0.72))), 2)
}

# The width a key value needs in ems of its font (dash_value_em()), which sets the size of every value of the strip: a value of DASH_KEY_SHORT
#   characters or fewer is a number and never wraps; a longer one (a period, a file's name) may break at its spaces over two lines, so it needs
#   a little over half its width.
dash_key_need <- function(value, narrow = FALSE) {
  em = dash_value_em(value, narrow)
  if (nchar(value) <= DASH_KEY_SHORT) em else max(1, round(0.6 * em, 2))
}

# The strip of key numbers (Phase 10b): each item is a small-capital label over its value, then, for a chosen fact, the chart's name; a thin rule
#   between the items, no boxes. `keys` is a list of list(label, value, full, what, cls). Every value of the strip has one type size, the largest
#   that the longest value needs in the width of its cell (`--w` on the strip is that value's width in ems; the stylesheet divides the cell's
#   width by it), so the numbers sit on one baseline (the labels are one line each). `narrow`: the condensed face.
dash_keys_tag <- function(keys, class = NULL, narrow = FALSE) {
  if (!length(keys)) return(NULL)
  need = max(purrr::map_dbl(keys, function(k) dash_key_need(k$value, narrow)))
  tags$div(class = css_class("keys", class), role = "group", `aria-label` = "Key numbers", style = paste0("--w:", need, ";"),
           purrr::map(keys, function(k) {
             short = nchar(k$value) <= DASH_KEY_SHORT
             tags$div(class = "key",
                      tags$div(class = "key-label", title = k$label, k$label),
                      tags$div(class = css_class("key-value", if (short) "num" else "long", if (nzchar(k$cls %||% "")) k$cls), title = k$full, k$value),
                      if (!is.null(k$what)) tags$div(class = "key-what", k$what))
           }))
}

# A heading as the page writes it, without one trailing full stop (chart_heading_text(): the stored text keeps it). A style that sets its headings in upper case (its `title_case`) does it with CSS (text-transform), which
#   would also turn "kg" into "KG" and "kWh" into "KWH": a word that keeps its case (chart_case_tokens(): a number, a unit) is wrapped in a
#   span the stylesheet leaves alone. A style that does not has the plain text.
dash_heading_text <- function(text, style) {
  text = chart_heading_text(text)     # one trailing full stop is not shown in a heading (Phase 10b)
  if (!identical(chart_style(style)$title_case, "upper") || !is_text1(text)) return(text)
  tk = chart_case_tokens(text)
  # words that keep their case go in spans; the text between them (words and spaces) stays one string
  span = tk$keep & grepl("\\S", tk$text)
  runs = rle(span)
  ends = cumsum(runs$lengths)
  purrr::pmap(list(runs$values, ends - runs$lengths + 1L, ends), function(is_span, from, to)
    if (is_span) tags$span(class = "keep", paste(tk$text[from:to], collapse = "")) else paste(tk$text[from:to], collapse = ""))
}

# A section's heading in the page: its title, and its line of text when there is one, across the whole row.
dash_section_head <- function(sec, style)
  tags$div(class = "section-head", tags$h2(dash_heading_text(sec$title, style)),
           if (is_text1(sec$text) && nzchar(trimws(sec$text))) tags$p(sec$text))

# The cards of the page in order, a section's heading before the first card under it. A card has `section` (id, title, text) when it stands under one.
dash_cards <- function(items, full, style) {
  cards = purrr::map2(items, full, dash_card, style = style)
  purrr::imap(cards, function(card, k) {
    sec = items[[k]]$section
    first = !is.null(sec) && (k == 1L || !identical(items[[k - 1L]]$section$id, sec$id))
    tagList(if (first) dash_section_head(sec, style), card)
  })
}

# The page, as one string: the masthead (title, subtitle, author, date, the introduction at a reading measure), the boxes, a card for each chart
#   in order (those with a row to themselves, from `full`), and the foot (the About text and "Made with chaRt"); the style sheet, typefaces,
#   pictures and (when a chart is interactive) scripts all inside it.
dash_page <- function(items, settings, cb, data, palette, model, full = rep(FALSE, length(items))) {
  mark = marking_of(settings$marking)
  style = palette$style %||% CHART_STYLE_DEFAULT
  accent = spec_palette(palette)$single
  keys = dash_keys(settings, cb, data, items)
  deps = htmltools::resolveDependencies(unlist(purrr::map(items, function(it) it$deps), recursive = FALSE) %||% list())
  title = if (nzchar(trimws(settings$title %||% ""))) trimws(settings$title) else paste("Dashboard:", cb$file %||% "the data file")
  author = trimws(settings$author %||% "")
  head = tagList(tags$meta(charset = "utf-8"), tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"), tags$title(title),
                   if (any(purrr::map_chr(items, "mode") == "video")) tags$script(HTML(MOTION_HEAD_JS)),
                   tags$style(HTML(paste(dash_font_css(style), dash_css(style, accent), sep = "\n"))), dash_inline_dependencies(deps))
  body = tags$body(class = if (nchar(mark) > 55L) "long", dash_band(mark, "top"), tags$div(class = "page",
    tags$header(class = "masthead", tags$h1(dash_heading_text(title, style)),
                if (nzchar(trimws(settings$subtitle %||% ""))) tags$p(class = "subtitle", trimws(settings$subtitle)),
                tags$p(class = "byline", if (nzchar(author)) tags$span(class = "author", author), if (nzchar(author)) " · ", tags$time(dash_date_text(settings$date))),
                tags$div(class = "intro", dash_paragraphs(settings$intro))),
    dash_keys_tag(keys, narrow = identical(chart_style(style)$title_font, "display")),
    tags$main(class = "grid", dash_cards(items, full, style)),
    tags$footer(class = "foot", dash_about(items, settings, cb, data, model), tags$p(class = "made", "Made with chaRt")),
    purrr::map(purrr::keep(items, function(it) identical(it$mode, "video") && !is.null(it$id)), motion_frames_tag),
    if (any(purrr::map_chr(items, "mode") == "video")) tags$script(HTML(MOTION_JS))), dash_band(mark, "bottom"))
  dash_document(head, body)
}

# The percentage of the rows missing, for a table cell or a sentence: whole numbers, and "under 1%" where it is more than none.
dash_pct <- function(x) if (isTRUE(x > 0) && x < 0.005) "under 1%" else sprintf("%.0f%%", 100 * (x %||% 0))

# The codebook's small picture of a column (inline, as a data address), drawn on the device chart_device() opens in the page's style and
#   palette: a histogram for a measure, bars for the levels of a group (at most CODEBOOK_FIG_LEVELS, the most frequent when there are more),
#   a line of counts over time for a date; nothing for an id, a text, a category with too many levels, a column with no value or a
#   drawing that fails. `s` is column_summary(e). The picture holds no row value: a histogram's bars, the dictionary's own level counts,
#   counts of rows for each month or year.
CODEBOOK_FIG_LEVELS <- 12L
CODEBOOK_FIG <- c(width = 3.6, height = 1.4)
codebook_figure <- function(e, s, data, palette) {
  if (is.null(data) || !e$name %in% names(data) || identical(s$kind, "distinct")) return(NULL)
  style = palette$style %||% CHART_STYLE_DEFAULT
  col = spec_palette(palette)$single
  x = data[[e$name]]
  small = ggplot2::theme(axis.title = ggplot2::element_blank(), axis.text.y = ggplot2::element_blank(), axis.ticks = ggplot2::element_blank(),
                         panel.grid.major.x = ggplot2::element_blank(), plot.margin = ggplot2::margin(4, 8, 2, 4))
  size = CODEBOOK_FIG
  p = tryCatch(switch(s$kind,
    range = {
      v = suppressWarnings(as.numeric(x[!is.na(x)]))
      if (length(v) < 2L || length(unique(v)) < 2L) return(NULL)
      ggplot2::ggplot(data.frame(v = v), ggplot2::aes(v)) + ggplot2::geom_histogram(bins = min(20L, length(unique(v))), fill = col) +
        ggplot2::scale_x_continuous(labels = scales::label_number(big.mark = if (identical(e$role, "time")) "" else ","), n.breaks = 5) +
        chart_theme(style, base_size = 10, grid = "y", legend = "none") + small
    },
    dates = {
      d = as.Date(x[!is.na(x)])
      if (length(d) < 2L) return(NULL)
      span = as.numeric(diff(range(d)))
      period = as.Date(format(d, if (span > 3 * 365) "%Y-01-01" else if (span > 60) "%Y-%m-01" else "%Y-%m-%d"))
      counts = dplyr::count(data.frame(period = period), period)
      if (nrow(counts) < 2L) return(NULL)
      ggplot2::ggplot(counts, ggplot2::aes(period, n)) + ggplot2::geom_line(colour = col, linewidth = 0.9) +
        ggplot2::scale_x_date(labels = time_labels()) + chart_theme(style, base_size = 10, grid = "y", legend = "none") + small
    },
    levels = {
      k = order(-s$counts, seq_along(s$counts))[seq_len(min(length(s$counts), CODEBOOK_FIG_LEVELS))]
      shown = data.frame(level = substr(s$values[k], 1L, 26L), n = s$counts[k])
      size = c(width = CODEBOOK_FIG[["width"]], height = max(0.7, 0.2 * nrow(shown) + 0.3))
      ggplot2::ggplot(shown, ggplot2::aes(n, factor(level, levels = rev(level)))) + ggplot2::geom_col(fill = col, width = 0.7) +
        ggplot2::scale_x_continuous(labels = scales::label_comma(), n.breaks = 4, expand = ggplot2::expansion(mult = c(0, 0.05))) +
        chart_theme(style, base_size = 10, grid = "x", legend = "none") + small + ggplot2::theme(axis.text.y = ggplot2::element_text(), panel.grid.major.x = ggplot2::element_line())
    },
    NULL), error = function(err) NULL)
  if (is.null(p)) return(NULL)
  f = tempfile(fileext = chart_device_ext())
  on.exit(unlink(f))
  ok = tryCatch({ spec_png(p, f, size = size, dpi = DASH_CSS_DPI * DASH_SCALE); TRUE }, error = function(err) FALSE)
  if (!ok) return(NULL)
  list(uri = dash_data_uri(f, chart_device_type()), size = size, kind = s$kind,
       note = if (identical(s$kind, "levels") && length(s$counts) > CODEBOOK_FIG_LEVELS)
         paste0("The ", CODEBOOK_FIG_LEVELS, " most frequent of ", length(s$counts), " levels") else
       switch(s$kind, range = "How the values are spread", dates = "Rows over time", levels = "Rows at each level"))
}

# The codebook page, a document: a table of every column at the top (name, label, type, role, share missing), then a compact section for
#   each column from the data dictionary (column_summary()): label, type, role, missing, a range and quartiles, or the level counts of a
#   group of at most CODEBOOK_MAX_LEVELS levels, or the number of distinct values alone, and where `data` is given a small drawn summary
#   (codebook_figure()). A column with no label shows a dash and says so. No row value is in it: the summaries and the drawings
#   describe a column, they do not show a row.
codebook_page <- function(cb, palette = chart_palette_default(), date = Sys.Date(), data = NULL, marking = NULL) {
  mark = marking_of(marking)
  style = palette$style %||% CHART_STYLE_DEFAULT
  accent = spec_palette(palette)$single
  cols = cb$columns
  # The statistics of each column for the table at the top, from the data in hand (summary_table(): measures, levels, dates, and for an id or a
  #   text only n and the number of different values); none when no data is given. They describe a column; no row of the file is in them.
  stats = if (!is.null(data)) tryCatch(summary_per_column(summary_table(data, cb)), error = function(err) NULL)
  stat_head = c("n", "Distinct", "Mean", "SD", "Min", "Median", "Max", paste(SUMMARY_CI_HEADER, c("low", "high")))
  stat_cells = function(e) {
    r = stats[match(e$name, stats$column), ]
    meas = identical(r$kind, "measure")
    cell = function(applies, text) if (applies) summary_txt(text) else ""
    tagList(purrr::map(c(
      summary_cnt(r$n), summary_cnt(r$distinct),
      cell(meas, summary_num(r$mean, r$scale)), cell(meas, summary_num(r$sd, r$scale)),
      cell(meas || identical(r$kind, "time"), if (meas) summary_num(r$min) else r$first), cell(meas, summary_num(r$median)),
      cell(meas || identical(r$kind, "time"), if (meas) summary_num(r$max) else r$last),
      cell(meas, summary_num(r$mean_ci_low, r$scale)), cell(meas, summary_num(r$mean_ci_high, r$scale))), function(x) tags$td(class = "n", x)))
  }
  num = function(x, big = TRUE) if (is.numeric(x)) format(x, big.mark = if (big) "," else "", scientific = FALSE, trim = TRUE, drop0trailing = TRUE) else as.character(x)
  row = function(term, value) if (!is.null(value) && length(value) && !all(is.na(value))) list(tags$dt(term), tags$dd(value))
  has_label = function(e) is_text1(e$label) && nzchar(trimws(e$label)) && !identical(e$label, e$name)
  label_cell = function(e) if (has_label(e)) e$label else tagList("–", tags$span(class = "muted", " no label given"))
  provenance = function(e) switch(e$label_source %||% "file", user = "written by the analyst", ai_guess = if (isFALSE(e$sure)) "proposed by a model, marked 'check this'" else "proposed by a model", NULL)
  section = function(e, i) {
    s = column_summary(e)
    fig = codebook_figure(e, s, data, palette)
    paper = if (!is.null(fig) && identical(style, "dark")) codebook_figure(e, s, data, utils::modifyList(palette, list(style = "clean")))
    tags$section(class = "col-section", id = paste0("col-", i),
      tags$h2(if (has_label(e)) e$label else e$name),
      tags$p(class = "name", paste0("Column ", e$name)),
      tags$dl(
        row("Label", if (has_label(e)) tagList(e$label, if (!is.null(provenance(e))) tags$span(class = "muted", paste0(" (", provenance(e), ")"))) else label_cell(e)),
        row("Type", paste0(e$type, if (!identical(e$type, e$detected %||% e$type)) paste0(" (found as ", e$detected, ")"))),
        row("Role", e$role),
        row("Missing", paste(dash_pct(e$missing), "of the rows")),
        switch(s$kind,
          range = list(row("Range", paste(num(s$min, !identical(e$role, "time")), "to", num(s$max, !identical(e$role, "time")))),
                       row("Quartiles", paste(purrr::map_chr(s$quartiles, num, big = !identical(e$role, "time")), collapse = ", ")), row("Note", s$note)),
          dates = list(row("Range", paste(s$min, "to", s$max)), row("Usually", if (!is.null(s$gap)) paste(s$gap, "apart"))),
          levels = list(list(tags$dt("Levels"), tags$dd(tags$table(class = "levels",
                           tags$thead(tags$tr(tags$th("Value"), tags$th("Rows"), tags$th("Share"))),
                           tags$tbody(purrr::map2(s$values, s$counts, function(v, n)
                             tags$tr(tags$td(v), tags$td(class = "n", format_num(n)), tags$td(class = "n", sprintf("%.0f%%", 100 * n / sum(s$counts))))))))),
                        NULL),
          distinct = row("Different values", num(s$distinct)))),
      if (!is.null(fig)) {
        alt = paste0(fig$note, ": ", if (has_label(e)) e$label else e$name)
        img = function(f, class = NULL) tags$img(class = class, src = f$uri, alt = alt, width = round(f$size[[1]] * DASH_CSS_DPI), height = round(f$size[[2]] * DASH_CSS_DPI))
        tags$figure(img(fig, if (!is.null(paper)) "screen-only"), if (!is.null(paper)) img(paper, "print-only"), tags$figcaption(fig$note))
      })
  }
  codes = missing_codes(cb)
  title = paste("Codebook:", cb$file %||% "the data file")
  head = tagList(tags$meta(charset = "utf-8"), tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"), tags$title(title),
                   tags$style(HTML(paste(dash_font_css(style), dash_css(style, accent), sep = "\n"))))
  body = tags$body(class = if (nchar(mark) > 55L) "long", dash_band(mark, "top"), tags$div(class = "page",
    tags$header(class = "masthead", tags$h1(title),
                tags$p(class = "subtitle", paste0(format_num(cb$rows %||% 0L), " rows and ", format_num(length(cols)), " columns",
                                                  if (codebook_ready(cb)) paste0("; one row is ", trimws(cb$row_is)), ".")),
                tags$p(class = "byline", dash_date_text(date), if (is_text1(cb$source) && nzchar(trimws(cb$source))) paste0(" · Source: ", trimws(cb$source))),
                tags$div(class = "intro", tags$p("This page describes each column from the data dictionary: no row of the file is shown, only a summary of each column."),
                         if (length(codes)) tags$p(paste0("These values were read as missing in every column: ", paste(codes, collapse = ", "), ".")))),
    tags$div(class = css_class("table-scroll", if (!is.null(stats)) "has-notes"), tags$table(class = "summary-table",
      tags$thead(tags$tr(purrr::map(c("Column", "Label", "Type", "Role", "Missing", if (!is.null(stats)) stat_head), function(h)
        tags$th(scope = "col", class = if (!h %in% c("Column", "Label", "Type", "Role")) "n", h)))),
      tags$tbody(purrr::imap(cols, function(e, i)
        tags$tr(tags$td(tags$a(href = paste0("#col-", i), e$name)), tags$td(label_cell(e)), tags$td(e$type), tags$td(e$role), tags$td(class = "n", dash_pct(e$missing)),
                if (!is.null(stats)) stat_cells(e)))))),
    if (!is.null(stats)) tags$div(class = "stat-notes", purrr::map(summary_notes(stats, TRUE), function(n) tags$p(class = "stat-note", n))),
    tags$main(purrr::imap(cols, function(e, i) section(e, i)))), dash_band(mark, "bottom"))
  dash_document(head, body)
}

# The whole document as text. tags$head() is not used: htmltools moves a head tag out of the page it renders, so the
#   head is written here, in front of the body.
dash_document <- function(head, body)
  paste0("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n", as.character(head), "\n</head>\n", as.character(body), "\n</html>\n")

# purrr wraps an error raised inside a map in one of its own ("In index: 2") with the real one as its parent: the real one is the
#   message the analyst should see.
dash_root_error <- function(e) if (!is.null(e$parent)) dash_root_error(e$parent) else e

# A step of the build: a failure says which step it was, then the build's own message.
dash_step <- function(what, code)
  tryCatch(code, error = function(e) stop("While ", what, ": ", conditionMessage(e), call. = FALSE))

# One chart of the dashboard, made, in two parts. This part draws the plot as the card draws it, writes its picture at DASH_DPI and its SVG
#   (when svglite is installed) into the staging folder for charts/ (title and source line in them, for print), writes its code and works
#   out the lines of its facts a key number may be. What the page shows for an interactive chart or a video is made in the second part,
#   once the layout says how wide the card is (dash_pictures()). `it` is list(id, chart, story, mode, stale).
dash_chart <- function(it, i, stage, data, cb, palette, path, widget, kind, marking) {
  chart = it$chart
  title = chart_title(chart, "Untitled chart")
  what = paste0("drawing chart ", i, " (", title, ")")
  # Phase 13: the headline the card shows (the app's, or worked out here as the app would) is the picture's title, the card's heading and the code's title
  shown = it$shown %||% headline_shown(it$story, r_headline(chart, cb, data, palette), it$stale %||% NA_character_)
  chart$spec$.headline = shown$text
  p = dash_step(what, spec_plot(chart$spec, data, cb, palette))
  s = attr(p, "spec")
  stem = file.path("charts", sprintf("%02d_%s", i, dash_slug(title)))
  # A chart whose card shows its design is written from the design (the picture, the script and the table beside it); when the design cannot be drawn
  #   again, the standard drawing is written and the card says why.
  designed = if (!is.null(it$design)) tryCatch(dash_design_files(it$design, chart, i, stem, stage, data, cb, palette, kind, marking), error = function(e) conditionMessage(dash_root_error(e)))
  if (is.list(designed)) {
    size = designed$size
    pic_file = NULL
    vector_file = NULL
    code = designed$code
  } else {
    pic_file = paste0(stem, chart_device_ext(kind))
    size = dash_step(what, spec_png(p, file.path(stage, pic_file), dpi = DASH_DPI, kind = kind, marking = marking))
    vector_file = if (!identical(kind, "svglite") && svglite_installed()) paste0(stem, ".svg")
    if (!is.null(vector_file)) dash_step(what, spec_png(p, file.path(stage, vector_file), size = size, kind = "svglite", marking = marking))
    code = tryCatch(spec_code(s, cb, path, palette), error = function(e) paste0("# The code of this chart could not be written: ", conditionMessage(e)))
  }
  facts = tryCatch({ f = spec_facts(s, attr(p, "table"), cb, data = data); dash_fact_choices(f$text, f$names) }, error = function(e) list())
  st = it$story
  panels = if (!is.null(s$facet) && s$facet %in% names(attr(p, "table"))) length(unique(attr(p, "table")[[s$facet]])) else 1L
  list(id = it$id, title = title, headline = shown$text, headline_by = shown$by, summary = if (!is.null(st)) st$summary, story = st, chart_subtitle = s$subtitle,
       mode = it$mode, fallback = if (is.character(designed)) designed, fallback_of = if (is.character(designed)) "designed drawing", facts = facts,
       designed = is.list(designed), design = if (is.list(designed)) it$design,
       # a chart drawn on a canvas wider than 8 inches (many sideways bars) is shown across the page, or its text would be too small to read
       natural_wide = identical(unname(size[["width"]]), SPEC_SIZE[["max_width"]]),
       panels = panels,
       notes = attr(p, "notes"), source = s$caption,
       files = if (is.list(designed)) designed$files else c(pic_file, vector_file), code = code)
}

# The motion of a chart for the page (Phase 12): its frames drawn without title, subtitle or source line (the page says them), for the width it is shown at
#   (`size`: desk, a card that shares its row, or wide, a card with a row to itself; SPEC_VIDEO_DASH_PX), held in memory as data
#   addresses (charts/ gets no file of them). Returns list(frames_json, last, first (frame 0, for the box's first picture: Phase 12c), px, fps, added, first_bytes, kept, drawn, seconds, size, canvas).
dash_motion_of <- function(mo, size) {
  on.exit(unlink(mo$dir, recursive = TRUE))
  list(frames_json = motion_frames_json(mo), last = dash_data_uri(mo$last, "image/png"), first = dash_data_uri(mo$files[[1]], "image/png"), px = mo$px, fps = mo$fps,
       added = motion_added_bytes(mo), first_bytes = 4 * ceiling(file.size(mo$files[[1]]) / 3),
       kept = length(mo$files), drawn = mo$drawn, seconds = mo$seconds, size = size, canvas = mo$canvas,
       frame_bytes = file.size(mo$files), repeats = mo$repeats)
}
#   Phase 12c, Kevin's ruling: a chart inside the page carries no classification bands of its own (the page has its two; the files in charts/, which leave the
#   page, keep theirs), so the frames and the finished picture are drawn without them, as a picture card's drawings are.
dash_video <- function(chart, data, cb, palette, size = "desk")
  dash_motion_of(spec_video(chart$spec, data, cb, palette, width = SPEC_VIDEO_DASH_PX[[size]][["width"]], bare = TRUE, web = dash_web(size)), size)

# The motion of a designed chart for the page (Phase 11 Part C): design_video() on the design's code, for the card's width as dash_video() is, without title,
#   subtitle or source line, and without bands (Phase 12c). Returns what dash_video() does, and `mode` ("layers": the design's data layers come in by its motion, then
#   its labels; "wipe": the three drawings did not add up, the whole picture wipes in) with `reason` (why it wipes).
dash_design_video <- function(dz, chart, data, cb, palette, size = "desk") {
  inp = design_input(chart, data, cb, palette)
  r = design_video(dz$code, inp, dz$motion, width_px = SPEC_VIDEO_DASH_PX[[size]][["width"]], bare = TRUE)
  c(dash_motion_of(r, size), list(designed = TRUE, mode = r$mode, reason = r$reason, motion = r$motion))
}

# Whether a card asks for a whole row by what it is (Phase 10b): a table, a chart drawn wide (many sideways bars), or small multiples of more
#   than DASH_FULL_PANELS panels, which are cramped in half a row. An interactive chart no longer does: it is sized to its card as a picture is.
#   `m` is a made card: list(mode, natural_wide, panels).
dash_card_wide <- function(m) identical(m$mode, "table") || isTRUE(m$natural_wide) || (m$panels %||% 1L) > DASH_FULL_PANELS

# The second part: what the page shows for a chart, made once the layout is known (a card that has a row to itself is shown wider). A picture
#   is the chart without title, subtitle or source line, drawn by spec_plot() for the size it is shown at (the lint reckons with that size) and
#   written at DASH_SCALE pixels for each one shown: desk, for a card that shares its row; wide, for one that has its row; phone, narrower and
#   with fewer breaks on its x axis, for a screen of at most DASH_PHONE_MAX_PX pixels; and, in a dark style only, a light drawing in the Clean
#   style for print. They are held in memory (data addresses) and are not written to charts/. An interactive chart is the widget drawn for the
#   card's size, and a video is drawn for it too; one that cannot be made is a picture, and says why in `fallback`.
dash_pictures <- function(m, full, i, chart, data, cb, palette, kind, widget = spec_widget, stage = NULL, marking = NULL) {
  if (identical(m$mode, "table")) return(m)
  card = if (full) "wide" else "desk"
  what = paste0("drawing chart ", i, " (", m$title, ")")
  # A designed chart: its picture for the page (the design without its title and caption, as wide as it was designed), and, when it is interactive, the design
  #   itself with tooltips if design_widget() can give its layers some, else the standard interactive version with a line that says so.
  dp = NULL
  if (isTRUE(m$designed)) {
    dp = tryCatch(dash_design_picture(m$design, chart, data, cb, palette, kind), error = function(e) conditionMessage(dash_root_error(e)))
    if (!is.list(dp)) {
      m$fallback = sub("\n.*$", "", dp)
      m$fallback_of = "designed drawing"
      m$designed = FALSE
      dp = NULL
    } else if (identical(m$mode, "interactive")) {
      w = tryCatch(design_widget(dp$plot, dp$size, palette), error = function(e) structure(list(), why = "the design could not be drawn with tooltips"))
      if (length(w)) {
        dw = tryCatch(dash_widget(w), error = function(e) NULL)
        if (is.list(dw)) return(utils::modifyList(m, list(widget_html = dw$html, deps = dw$deps)))
      }
      m$widget_note = paste0("The standard interactive version: the designed drawing is a picture (", attr(w, "why") %||% "its layers cannot have tooltips", ").")
    }
  }
  draw = function(size, pal = palette) {
    p = dash_step(what, spec_plot(chart$spec, data, cb, pal, web = dash_web(size)))
    f = tempfile(fileext = chart_device_ext(kind))
    on.exit(unlink(f))
    sz = dash_step(what, spec_png(p, f, dpi = DASH_CSS_DPI * DASH_SCALE, kind = kind))
    list(uri = dash_data_uri(f, chart_device_type(kind)), pixels = round(sz * DASH_CSS_DPI))
  }
  light = if (identical(palette$style, "dark")) utils::modifyList(palette, list(style = "clean"))
  if (identical(m$mode, "interactive")) {
    w = tryCatch(dash_widget(widget(spec_plot(chart$spec, data, cb, palette, web = dash_web(card)))), error = function(e) conditionMessage(e))
    if (is.list(w)) return(utils::modifyList(m, list(widget_html = w$html, deps = w$deps)))
    m$fallback = sub("\n.*$", "", w)
    m$mode = "picture"
  } else if (identical(m$mode, "video")) {
    # A designed chart's motion is made from the design (design_video()); when that cannot be made, the standard drawing's motion is, and the card says so.
    v = NULL
    if (isTRUE(m$designed)) {
      v = tryCatch(dash_design_video(m$design, chart, data, cb, palette, card), error = function(e) conditionMessage(e))
      m$video_note = if (is.list(v)) { if (identical(v$mode, "wipe")) paste0("The animation wipes the designed drawing in from the left as one picture, because ", v$reason, ".") }
                     else paste0("The animation of the designed drawing could not be made (", sub("\n.*$", "", v), "), so it animates the standard drawing.")
    }
    if (!is.list(v)) {
      v = tryCatch(dash_video(chart, data, cb, palette, card), error = function(e) conditionMessage(e))
      if (is.list(v) && isTRUE(m$designed)) { m$designed = FALSE; m$design = NULL }
      if (!is.list(v)) m$video_note = NULL
    }
    if (is.list(v)) {
      m$video = v
      # Phase 12c: its still drawing for a phone (shown in place of the motion on a narrow screen, where frames drawn for the card would be too small to read),
      #   and for print the half-width drawing when the card has its row or the style is dark (in Clean), as a picture card has
      m$pictures = if (!is.null(dp) && isTRUE(m$designed)) list(phone = dp$pic, print = if (full) dp$pic)
                   else list(phone = draw("phone"), print = if (!is.null(light)) draw("desk", light) else if (full) draw("desk"))
      return(m)
    }
    m$fallback = sub("\n.*$", "", v)
    m$fallback_of = "animation"
    m$mode = "picture"
  }
  m$pictures = if (!is.null(dp)) list(desk = dp$pic, phone = dp$pic, wide = if (full) dp$pic)
               else list(desk = draw("desk"), phone = draw("phone"), wide = if (full) draw("wide"), print = if (!is.null(light)) draw("desk", light))
  m
}

# One summary table of the dashboard, made. `it` is list(id, table, mode = "table") where `table` is list(title, measures, by, ci). The statistics are
#   worked out here from the data in hand (summary_table()) and written to charts/ as a CSV (summary_csv(): header on the first row, the note in a
#   column), and the page gets the table itself as HTML (dash_table_card()), not a picture. No model is called and no row of the file is written: a
#   measure's statistics, a group's levels and counts, nothing of a text or an id but how many values it has.
dash_table <- function(it, i, stage, data, cb, marking) {
  t = it$table
  what = paste0("working out table ", i, " (", t$title, ")")
  tb = dash_step(what, summary_table(data, cb, t$measures, t$by))
  file = file.path("charts", sprintf("%02d_%s.csv", i, dash_slug(t$title)))
  dash_step(what, summary_csv(tb, t$ci, file.path(stage, file), marking = marking))
  list(id = it$id, title = t$title, mode = "table", tb = tb, ci = isTRUE(t$ci), small = any(tb$small %in% TRUE), files = file,
       code = c(paste0("# A summary table, not a chart: ", t$title, "."),
                paste0("#   Columns: ", paste(t$measures, collapse = ", "), if (is_text1(t$by) && nzchar(t$by)) paste0("; by ", t$by), "."),
                paste0("#   Worked out by chaRt from the file with no model; the numbers are in ", file, ". ", summary_notes(tb, isTRUE(t$ci))[1])))
}

# The card of a table in the page: the title as the heading, the table (a real table that scrolls sideways inside its card when it is
#   wider than the card) and the lines under it. A table has a row to itself.
dash_table_card <- function(it, full = TRUE, style = NULL)
  tags$article(class = css_class("card", "table-card", if (full) "full"),
    tags$h2(dash_heading_text(it$title, style %||% CHART_STYLE_DEFAULT)),
    summary_tag(it$tb, it$ci))

# A table in the dialog's list: its title and the columns it takes, and what is written (a table in the page and a CSV in charts/).
dash_table_row <- function(it, i, cb, on_id = NULL, on = TRUE, in_section = NULL, why_off = NULL) {
  t = it$table
  tags$div(class = css_class("d-flex gap-3 align-items-start border-bottom py-2", if (!is.null(in_section)) "ms-4 ps-3 border-start", if (!isTRUE(on) || !is.null(why_off)) "dash-off", if (!is.null(why_off)) "dash-sec-off"),
           `data-dash-row` = it$id, `data-dash-in` = in_section,
           if (!is.null(on_id)) dash_row_switch(on_id, on),
           tags$div(class = "small text-muted dash-body", style = "width:9rem; flex:none;", "Summary table"),
           tags$div(class = "flex-grow-1 dash-body",
                    tags$div(class = "fw-semibold", paste0(i, ". ", t$title)),
                    tags$div(class = "small text-muted", paste0("Columns: ", paste(purrr::map_chr(t$measures, function(n) summary_choice(purrr::detect(cb$columns, function(e) identical(e$name, n)) %||% list(name = n))), collapse = ", "),
                                                               if (is_text1(t$by) && nzchar(t$by)) paste0("; by ", t$by), if (!isTRUE(t$ci)) "; without 95% intervals")),
                    tags$div(class = "small dash-why", DASH_WHY_OFF),
                    tags$div(class = "small", "Goes in the page as a table (no model text) and in charts/ as a CSV.")))
}

# ---- what carries a design: the code with its table, the script that runs alone ------------------------------------------------------------

# How a design names its skill in a file or a page: the title and version of an app skill; an office's own skill is only called one (its name is the office's).
design_skill_label <- function(skill) if (isTRUE(skill$office)) "an office design skill" else paste0(skill$title, " (version ", skill$version, ")")

# What the chat says after designs (Phase 11 Part B): every piece that came from the file, the analyst or the model goes through md_text().
design_many_text <- function(skill_title, titles, notes, designed, calls)
  paste(c(paste0("Designed ", sum(designed), " of ", length(designed), if (length(designed) == 1L) " chart" else " charts", " with ", md_text(skill_title),
                 ". Each card has a switch between the designed and the standard drawing, and Code shows what the model wrote."),
          if (any(!designed)) paste0(md_text(titles[!designed]), ": ", md_text(notes[!designed])),
          paste0(calls, " model calls.")), collapse = "\n\n")
design_one_text <- function(title, skill_title, wish, calls)
  paste0("Designed ", md_text(title), " with ", md_text(skill_title), if (!is.null(wish)) paste0(", with your wish: ", md_text(wish)), ". ",
         "The card's \"Designed drawing\" switch goes back to the standard drawing; Code shows what the model wrote. No chat call was made: ", calls, " design calls.")

# The code as the Code dialog shows it: what it is, then the model's code as written.
design_code_lines <- function(dz)
  c(paste0("# Designed with ", design_skill_label(dz$skill), ". The model wrote the code below; R checked it against a list of the functions it may call,"),
    "# ran it on the table shown under it, and checked the drawing (zero baselines, no clipped or overlapping text, every number from the facts).",
    "# d is that table; facts, txt, tok and pal(n) are given by the app (the exported charts.R defines them, so it runs on its own).",
    strsplit(dz$code, "\n", fixed = TRUE)[[1]])

# The table a design draws, for the Code dialog: its first rows, and how many there are (the export writes them all as a CSV).
design_table_tag <- function(table, n = 20L) {
  t = utils::head(as.data.frame(table), n)
  cell = function(x) if (inherits(x, c("Date", "POSIXct"))) format(as.Date(x), "%Y-%m-%d") else if (is.numeric(x)) format(signif(x, 6), scientific = FALSE, trim = TRUE, drop0trailing = TRUE) else as.character(x)
  tagList(
    tags$div(class = "table-responsive",
             tags$table(class = "table table-sm small",
                        tags$thead(tags$tr(purrr::map(names(t), tags$th))),
                        tags$tbody(purrr::map(seq_len(nrow(t)), function(i) tags$tr(purrr::map(names(t), function(n) tags$td(cell(t[[n]][[i]])))))))),
    tags$p(class = "small text-muted", paste0(format(nrow(table), big.mark = ","), if (nrow(table) == 1L) " row" else " rows", if (nrow(table) > n) paste0(", the first ", n, " shown"),
                                              ". Exported, the whole table is a CSV beside charts.R.")))
}

# The line under a designed card: which skill, what the model said (when it said one sentence without a number), and whether it looked at the picture.
dash_design_mark <- function(dz)
  paste(c(paste0("Designed with ", dz$skill$title, "."), dz$review, if (is_text1(dz$say)) paste0("The model's note: ", dz$say)), collapse = " ")

# What the export dialog says about a designed chart: where its picture comes from, what is written beside the script, and what each way of showing it does.
dash_design_note <- function(dz, spec, mode) {
  inter = if (identical(mode, "interactive")) {
    ok = if (!is.null(dz$plot)) design_interactive_ok(dz$plot) else list(ok = FALSE, reason = "the design's drawing is not there")
    if (isTRUE(ok$ok)) " Interactive: tooltips on the designed drawing."
    else paste0(" Interactive: the standard interactive view, because the designed drawing cannot have tooltips (", ok$reason, ").")
  }
  paste0("Designed with ", design_skill_label(dz$skill), ": the picture is the model's code run again on the file as it is now. The plotted table is written beside charts.R as a CSV so the script runs alone",
         if (chart_from_rows(spec)) ", and that CSV holds the rows this chart plots" else "", ".",
         inter, if (identical(mode, "video")) " An animated chart is drawn from the design: its marks come in by the motion the model chose (rise, draw, wipe or fade), then its labels fade in; if the design's layers cannot be drawn apart, the whole picture wipes in from the left." else "")
}

# The script of one designed chart, so that it runs alone: the packages its code uses, the table read back from its CSV (dates and levels as they were), the
#   facts, words, tokens and palette function the code is given, and the code, whose last expression draws the chart. `inp` is design_input()'s; `csv` is the
#   CSV's path relative to charts.R; `marking_skip` is the number of lines to skip (the marking's comment line).
design_script <- function(dz, inp, csv, title = "", skip = 1L) {
  g = design_guard(dz$code, names(inp$d))   # the guard's own reading of the code (a syntax tree, never evaluated)
  fns = if (isTRUE(g$ok)) unique(unlist(purrr::map(as.list(g$exprs), all.names))) else character(0)
  pk = attr(design_toolkit(), "package")
  libs = union("ggplot2", setdiff(unique(pk[intersect(fns, names(pk))]), c("base", "utils", "stats")))
  d = inp$d
  restore = unlist(purrr::imap(d, function(x, nm) {
    ref = paste0("d[[", deparse(nm), "]]")
    if (inherits(x, "Date")) paste0(ref, " <- as.Date(", ref, ")")
    else if (inherits(x, "POSIXct")) paste0(ref, " <- as.POSIXct(", ref, ", tz = \"UTC\")")
    else if (is.factor(x)) paste0(ref, " <- factor(", ref, ", levels = ", paste(deparse(levels(x), width.cutoff = 500L), collapse = ""), ")")
  }), use.names = FALSE)
  dput_lines = function(x) paste(deparse(x, width.cutoff = 100L), collapse = "\n")
  pals = purrr::compact(purrr::map(1:12, function(n) tryCatch(inp$pal(n), error = function(e) NULL)))
  c(paste0("# Chart: ", title, ". Designed with ", design_skill_label(dz$skill), "."),
    "# The model wrote the drawing code; it runs on the table below. d, facts, txt, tok and pal are what the app gave it.",
    paste0("library(", libs, ")"), "",
    paste0("d <- read.csv(", deparse(csv), ", skip = ", skip, ", check.names = FALSE, stringsAsFactors = FALSE)   # the first line of the CSV is the marking"),
    restore,
    paste0("facts <- ", dput_lines(inp$facts)),
    paste0("txt <- ", dput_lines(inp$txt)),
    paste0("tok <- ", dput_lines(inp$tok)),
    paste0("pal <- function(n) ", dput_lines(pals), "[[n]]"),
    "chart <- local({",
    paste0("  ", strsplit(dz$code, "\n", fixed = TRUE)[[1]]),
    "})",
    "chart   # draws it; ggsave(\"chart.png\", chart, width = 7, height = 4.5, dpi = 300) saves it")
}

# The files of one designed chart for the zip: the picture at DASH_DPI with the marking (and an SVG when svglite is there), the plotted table as a CSV
#   (the marking is its first line, a reader skips it), and the script that runs alone. The drawing is made again from the design's code on the file as it
#   is now (the card's design key held that it is the same chart, style and data). Returns list(files, code, size, plot) or stops with the sentence.
dash_design_files <- function(dz, chart, i, stem, stage, data, cb, palette, kind, marking) {
  inp = design_input(chart, data, cb, palette)
  r = design_run(dz$code, inp$d, inp$facts, inp$txt, inp$tok, inp$pal, size = inp$size, dpi = 40L)
  if (!r$ok) stop(r$reason, call. = FALSE)
  pic_file = paste0(stem, chart_device_ext(kind))
  spec_png(r$plot, file.path(stage, pic_file), size = inp$size, dpi = DASH_DPI, kind = kind, marking = marking)
  vector_file = if (!identical(kind, "svglite") && svglite_installed()) paste0(stem, ".svg")
  if (!is.null(vector_file)) spec_png(r$plot, file.path(stage, vector_file), size = inp$size, kind = "svglite", marking = marking)
  csv_file = paste0(stem, "_table.csv")
  readr::write_csv(inp$d, file.path(stage, csv_file))
  marking_prepend(file.path(stage, csv_file), marking_comment(marking))
  list(files = c(pic_file, vector_file, csv_file), size = inp$size, plot = r$plot,
       code = design_script(dz, inp, csv_file, chart_title(chart, "Untitled chart")))
}

# The picture of a designed chart for the page: the design drawn without its title, subtitle and caption (the page says them), once, as wide as it was designed;
#   the page scales it for the card and for a phone. A design has no phone drawing of its own. Stops with the sentence when it cannot be drawn.
# The same for the app's card (the manager's ruling: its heading carries the headline): the design drawn with no title, subtitle or caption, kept in a file
#   until the design is dropped. Returns list(file, plot, size).
design_card_picture <- function(dz, chart, data, cb, palette) {
  inp = design_input(chart, data, cb, palette)
  bare = inp$txt[setdiff(names(inp$txt), c("title", "subtitle", "caption"))]
  r = design_run(dz$code, inp$d, inp$facts, bare, inp$tok, inp$pal, size = inp$size, dpi = SPEC_DPI, keep = TRUE)
  if (!r$ok) stop(r$reason, call. = FALSE)
  list(file = r$file, plot = r$plot, size = inp$size)
}

dash_design_picture <- function(dz, chart, data, cb, palette, kind) {
  inp = design_input(chart, data, cb, palette)
  bare = inp$txt[setdiff(names(inp$txt), c("title", "subtitle", "caption"))]
  r = design_run(dz$code, inp$d, inp$facts, bare, inp$tok, inp$pal, size = inp$size, dpi = DASH_CSS_DPI * DASH_SCALE, keep = TRUE)
  if (!r$ok) stop(r$reason, call. = FALSE)
  on.exit(unlink(r$file))
  list(pic = list(uri = dash_data_uri(r$file, chart_device_type(kind)), pixels = round(inp$size * DASH_CSS_DPI)), plot = r$plot, size = inp$size, palette = palette)
}

# Builds the dashboard zip. `items` is list(id, chart, story, mode, stale) for each chosen chart in the order shown (a summary table is an item
#   too: list(id, table = list(title, measures, by, ci), mode = "table"), a card of its own with a row to itself and a CSV in charts/); `settings` is
#   list(title, subtitle, author, date, intro, boxes, keys): `keys` are the key numbers chosen, as "chart id|number of the fact line". The
#   pages and the charts are staged in a folder of their own and written to `zip_file`; the folder is removed. `widget` makes the
#   interactive version of a plot (spec_widget; a check can stand in a failing one). The cards are laid out first (dash_layout(): an
#   interactive or wide chart has its row, and a card left alone beside it has its row too), then each chart is drawn for the size it
#   is shown at. Returns what was written: the zip, its size, the seconds, the files in it, how each chart went in, why a chart is a
#   picture when its interactive version was asked for, and which cards have a row to themselves. An error says which step failed.
build_dashboard <- function(items, data, cb, palette, settings, path, zip_file, model = APP_MODEL$id, widget = spec_widget) {
  started = proc.time()[["elapsed"]]
  if (!length(items)) stop("No chart is in the dashboard.", call. = FALSE)
  mark = marking_of(settings$marking)
  settings$marking = mark
  stage = tempfile("dashboard_")
  dir.create(file.path(stage, "charts"), recursive = TRUE)
  on.exit(unlink(stage, recursive = TRUE), add = TRUE)
  kind = chart_device_kind()
  settings$date = if (inherits(settings$date, "Date") && !is.na(settings$date)) settings$date else Sys.Date()
  made = tryCatch(purrr::imap(unname(items), function(it, i)
                    if (!is.null(it$table)) dash_table(it, i, stage, data, cb, mark) else dash_chart(it, i, stage, data, cb, palette, path, widget, kind, mark)),
                  error = function(e) stop(conditionMessage(dash_root_error(e)), call. = FALSE))
  full = dash_layout_by(purrr::map_lgl(made, dash_card_wide), purrr::map_chr(unname(items), function(it) it$section$id %||% ""))
  made = tryCatch(purrr::pmap(list(made, full, seq_along(made), unname(items)), function(m, f, i, it) dash_pictures(m, f, i, it$chart, data, cb, palette, kind, widget, stage, mark)),
                  error = function(e) stop(conditionMessage(dash_root_error(e)), call. = FALSE))
  made = purrr::map2(made, unname(items), function(m, it) { m$section = it$section; m })   # the section each card stands under, for the page's headings
  dash_step("writing dashboard.html", writeBin(charToRaw(enc2utf8(dash_page(made, settings, cb, data, palette, model, full))), file.path(stage, "dashboard.html")))
  dash_step("writing codebook.html", writeBin(charToRaw(enc2utf8(codebook_page(cb, palette, settings$date, data, mark))), file.path(stage, "codebook.html")))
  dash_step("writing data_dictionary.yaml", { write_codebook(cb, file.path(stage, "data_dictionary.yaml")); marking_prepend(file.path(stage, "data_dictionary.yaml"), marking_comment(mark)) })
  dash_step("writing charts.R", writeBin(charToRaw(enc2utf8(paste(c(marking_comment(mark), "# The code of each chart in the dashboard, in the order shown. Run a chart's part on its own;",
                                                                   "# each reads the data file named in it, which is not in this zip.",
                                                                   unlist(purrr::imap(made, function(m, i) c("", paste0("# ---- Chart ", i, ": ", m$title, " ", strrep("-", 20)), m$code)))),
                                                                 collapse = "\n"))), file.path(stage, "charts.R")))
  chart_files = sort(unlist(purrr::map(made, "files")))
  dash_step("writing the zip", {
    if (file.exists(zip_file)) unlink(zip_file)
    zip::zipr(zip_file, files = c("dashboard.html", "codebook.html", "data_dictionary.yaml", "charts.R", chart_files), root = stage, include_directories = FALSE, mode = "mirror")
  })
  listing = zip::zip_list(zip_file)
  list(zip = zip_file, bytes = file.size(zip_file), seconds = proc.time()[["elapsed"]] - started,
       files = stats::setNames(listing$uncompressed_size, listing$filename), modes = purrr::map_chr(made, "mode"), full = full,
       fallbacks = stats::setNames(purrr::map_chr(made, function(m) m$fallback %||% NA_character_), purrr::map_chr(made, "title")),
       video_notes = stats::setNames(purrr::map_chr(made, function(m) m$video_note %||% NA_character_), purrr::map_chr(made, "title")),
       fallback_of = stats::setNames(purrr::map_chr(made, function(m) m$fallback_of %||% "interactive version"), purrr::map_chr(made, "title")), device = kind)
}

# A size in bytes for a sentence: kilobytes below a megabyte, else megabytes to one decimal.
dash_size_text <- function(b) if (b < 1024^2) paste0(format(round(b / 1024), big.mark = ","), " KB") else paste0(format(round(b / 1024^2, 1), nsmall = 1), " MB")

# The last lines of a build's own message (at most four, each cut at 300 characters), for the dialog.
dash_last_lines <- function(msg) paste(utils::tail(substr(strsplit(as.character(msg), "\n")[[1]], 1L, 300L), 4L), collapse = "\n")

# One chart in the dialog's list: its small picture, its title and headline, the choice of picture or interactive, and the line
#   that says what an interactive version of it carries. `mode_id` is the radio's input id and `note_id` its note's output id.
dash_chart_row <- function(it, i, thumb, mode_id, note_id, mode, on_id = NULL, on = TRUE, in_section = NULL, why_off = NULL, design_id = NULL, design_on = FALSE) {
  head = if (!is.null(it$shown) && is_text1(it$shown$text)) it$shown$text else if (!is.null(it$story) && is_text1(it$story$headline) && nzchar(it$story$headline)) it$story$headline
  off = !isTRUE(on) || !is.null(why_off)   # the page's script keeps these classes true to the switches as they are flipped (EXPLORE_JS)
  tags$div(class = css_class("d-flex gap-3 align-items-start border-bottom py-2", if (!is.null(in_section)) "ms-4 ps-3 border-start", if (off) "dash-off", if (!is.null(why_off)) "dash-sec-off"),
           `data-dash-row` = it$id, `data-dash-in` = in_section,
           if (!is.null(on_id)) dash_row_switch(on_id, on),
           tags$div(class = "d-flex gap-3 align-items-start flex-grow-1 dash-body",
                    if (!is.null(thumb)) tags$img(src = thumb, alt = paste("Small picture of", chart_title(it$chart, "this chart")),
                                                  style = "width:9rem; height:auto; border:1px solid rgba(128,128,128,.5); flex:none;")
                    else tags$div(class = "small text-muted", style = "width:9rem; flex:none;", "No picture: this chart could not be drawn."),
                    tags$div(class = "flex-grow-1",
                             tags$div(class = "fw-semibold", paste0(i, ". ", head %||% chart_title(it$chart, "Untitled chart"))),
                             if (!is.null(head)) tags$div(class = "small text-muted", chart_title(it$chart, "Untitled chart")),
                             tags$div(class = "small dash-why", DASH_WHY_OFF),
                             radioButtons(mode_id, NULL, choices = if (video_available()) DASH_MODES else DASH_MODES[DASH_MODES != "video"], selected = mode, inline = TRUE),
                             if (!is.null(design_id)) bslib::input_switch(design_id, "Designed drawing (off: the standard drawing)", value = design_on),
                             uiOutput(note_id))))
}

DASH_WHY_OFF <- "Left out with its section."

# The switch at the left of a row of the dialog: the card's own "In dashboard" switch.
dash_row_switch <- function(on_id, on)
  tags$div(style = "width:6.5rem; flex:none;", bslib::input_switch(on_id, "Include", value = isTRUE(on)))

# A section in the dialog's list: its title and line of text, how many cards stand under it, and its switch (off leaves out every card under it).
dash_section_row <- function(sec, on_id, on, n_cards = 0L)
  tags$div(class = css_class("d-flex gap-3 align-items-start border-top border-bottom py-2 mt-2", if (!isTRUE(on)) "dash-off"), `data-dash-row` = sec$id, `data-dash-section-row` = "1",
           dash_row_switch(on_id, on),
           tags$div(class = "d-flex gap-3 align-items-start flex-grow-1 dash-body",
                    tags$div(style = "width:9rem; flex:none;", `aria-hidden` = "true",
                             tags$div(style = "height:6px; width:60%; background:currentColor; opacity:.75; margin:.35rem 0;"),
                             tags$div(style = "height:4px; width:90%; background:currentColor; opacity:.3;")),
                    tags$div(class = "flex-grow-1",
                             tags$div(class = "small text-uppercase text-muted", "Section"),
                             tags$div(class = "fw-semibold", sec$title),
                             if (is_text1(sec$text) && nzchar(sec$text)) tags$div(class = "small text-muted", sec$text),
                             tags$div(class = "small", paste0(n_cards, if (n_cards == 1L) " card" else " cards", " under it"), tags$div(class = "small dash-all-off", "All of them are left out of the page.")))))

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
  small = list(family = "line", x = "year", y = "revenue", facet = "region", fn = "sum"),
  dumbbell = list(family = "dumbbell", y = "region", x = "revenue", color = "year", fn = "sum",
                  filter = list(list(column = "year", op = "in", value = c(2015L, 2024L)))),
  violin = list(family = "box", x = "region", y = "price", shape = "violin"),
  indexed = list(family = "line", x = "year", y = "revenue", color = "region", fn = "sum", index = "first"),
  smoothed = list(family = "line", x = "year", y = "revenue", fn = "sum", smooth = 3L),
  density = list(family = "scatter", x = "units", y = "price", density = "on"))
# A violin needs groups of at least SPEC_VIOLIN_MIN rows, which the five regions of ten years do not have: its thumbnail is drawn from 40 made-up prices in each region.
METHOD_THUMB_ROWS <- c("violin")
METHOD_THUMB_ALT <- c(
  bar = "A small bar chart: one bar for each of five groups.", line = "A small line chart: one line for each of five groups over ten years.",
  slope = "A small slope chart: five groups at two points in time, joined by lines.",
  scatter = "A small scatter chart: one point for each row, with a fitted curve.",
  bubble = "A small bubble chart: five points, the size of each showing a third measure.",
  histogram = "A small histogram: how one measure is spread out.", box = "A small box chart: the spread of one measure for each of five groups.",
  heatmap = "A small heatmap: one measure in the cells of two groupings.", small = "Small multiples: the same line chart repeated in a panel for each of five groups.",
  dumbbell = "A small dumbbell chart: for each of five groups, two dots joined by a line, one for each of two years.",
  violin = "A small violin chart: the shape of one measure in each of five groups, with a box inside each.",
  indexed = "A small indexed line chart: five lines that all start at 100.", smoothed = "A small line chart: a line and its moving average over it.",
  density = "A small density chart: counts of rows in the cells of a grid, from two measures.")
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

# 40 made-up prices in each of the five regions, the same every time and made with no random numbers: a violin's thumbnail needs groups of 30 rows or more.
method_thumb_rows <- function() {
  regions = c("North", "South", "East", "West", "Central")
  grid = expand.grid(i = 1:40, region = regions, stringsAsFactors = FALSE)
  r = match(grid$region, regions)
  tibble::tibble(region = grid$region, price = round(8 + 3 * r + 9 * (1 + sin(grid$i * 12.9898 + r * 78.233))^2, 2))
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
    rows = method_thumb_rows()
    cb_rows = new_codebook(profile_data(rows), "made-up table", nrow(rows))
    cb_rows$row_is = "one price in one region"
    METHOD_CACHE$thumbs = purrr::imap(METHOD_THUMB_SPECS, function(s, key)
      tryCatch(if (key %in% METHOD_THUMB_ROWS) method_thumb_draw(s, rows, cb_rows) else method_thumb_draw(s, data, cb), error = function(e) NULL))
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
           "' are checked as numbers; 'one' is not, because it is nearly always a pronoun. A date such as 2024-12-01 or 3 Jan 2024 counts as its year, and 'Dec 2023' is its year alone.")),
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
FONT_LICENCE_FILES <- c(sans = "Inter-LICENSE.txt", serif = "SourceSerif4-LICENSE.md", display = "BarlowCondensed-LICENSE.txt")

# The first line of a font's licence file, which names its copyright holder.
font_copyright <- function(file) {
  path = file.path(CHART_FONT_DIR, file)
  if (!file.exists(path)) return("(the licence file is not in this copy of the app)")
  trimws(readLines(path, n = 1L, encoding = "UTF-8", warn = FALSE))
}

method_styles_ui <- function() {
  colour = chart_palette(1L, chart_palette_default()$qualitative, CHART_STYLE_DEFAULT)[[1]]
  serif_in = purrr::map_chr(purrr::keep(CHART_STYLES, function(s) "serif" %in% c(s$title_font, s$subtitle_font)), "label")
  display_in = purrr::map_chr(purrr::keep(CHART_STYLES, function(s) "display" %in% c(s$title_font, s$subtitle_font)), "label")
  font_ui = function(role) {
    f = CHART_FONTS[[role]]
    file = FONT_LICENCE_FILES[[role]]
    tags$li(class = "mb-2",
            tags$span(class = "fw-semibold", style = paste0("font-family: ", f$css, ";"), paste0(f$family, ":")),
            paste0(switch(role,
                          serif = paste0("the title and subtitle of the ", paste(serif_in, collapse = " and "), " style, in regular, semibold and bold. "),
                          display = paste0("the title of the ", paste(display_in, collapse = " and "), " style, in upper case, in bold. "),
                          "all other chart text, in regular, semibold and bold. "),
                   "Licence: ", FONT_LICENCE, ". ", font_copyright(file), " "),
            tags$a(href = file.path("fonts", file), target = "_blank", rel = "noopener", "Licence text"))
  }
  tags$section(
    id = "method-styles",
    tags$h2("Styles and fonts"),
    tags$p("A dashboard has one style, chosen with the Style button on Explore; the model never chooses it. Each style is a set of colours, ",
           "a grid and a title in one of three typefaces."),
    tags$div(class = "row g-3 mb-3",
             purrr::map(names(CHART_STYLES), function(nm) {
               st = CHART_STYLES[[nm]]
               tags$div(class = "col-6 col-md-4 col-lg-2",
                        HTML(style_sample_svg(nm, colour)), tags$div(class = "fw-semibold", st$label), tags$div(class = "small text-muted", st$note))
             })),
    tags$h3(class = "h5", "The typefaces"),
    tags$p("Three typefaces are bundled with the app, so a chart looks the same on any server (when it is drawn by ragg; see Start here)."),
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
    method_privacy_ui(),
    method_text_ui(),
    tags$section(id = "method-questions", tags$h2("Questions for your file"), uiOutput(ns("questions"))),
    method_rules_ui(),
    method_checks_ui(),
    method_styles_ui(),
    tags$style(HTML(METHOD_CSS)))
}

# Put above the manager's text (www/methodology.md, which is not edited here): its first paragraph says the model never sees the rows, which holds for
#   choosing a chart and writing a headline and is not the whole of it once a chart can be designed.
method_privacy_ui <- function(setting = design_images_setting())
  advice_box(tags$p(tags$strong("A note before the text below.")),
             tags$p("The text below says the model reads a description of your columns, never the rows, and that it does not draw. That is how it chooses a chart and writes a headline, and the rule-drawn chart ",
                    "stays the first drawing and the fall-back. Designing a chart is the exception: the model writes the drawing code, R checks it against a list of the functions it may call and runs it, and the model is sent more:"),
             purrr::map(privacy_text(setting), tags$p))

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
