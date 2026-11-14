# ui.R for QuestionR
# The tab titles, the helpers the tabs share, Start here and Methodology; the task pages are in
#   ui_tasks.R. Function definitions and constants only.

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
placeholder_notice <- function(m = APP_MODEL) {
  bad = llm_placeholders(m)
  if (!length(bad)) return(NULL)
  warn_box(
    tags$strong(paste0("The ", APP_PROFILE, " profile still has placeholders to fill in. ")),
    "Open app.R, section 1, and replace each <placeholder> (README.md, Setting up at work). Still to fill in: ",
    paste(bad, collapse = ", "), ".")
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
    tags$h4("Model"),
    uiOutput(ns("models")),
    actionButton(ns("check"), "Check the connection"),
    tags$p(class = "text-muted small mt-2",
           "Makes one very small call to the model, and shows whether it answered ",
           "or what the endpoint said. Nothing you have entered is sent."),
    uiOutput(ns("result")))
}

mod_connect_server <- function(id, state, ping = llm_ping) {
  moduleServer(id, function(input, output, session) {
    results <- reactiveVal(NULL)

    output$models <- renderUI({
      state$key_version   # a key pasted or forgotten changes whether it is ready
      m = APP_MODEL
      tags$p(model_label(m), tags$br(),
             if (length(llm_placeholders(m))) tags$span(class = "text-warning", "Waits for the settings in app.R.")
             else if (llm_key_ready(m)) tags$span(class = "text-success", "Ready.")
             else tags$span(class = "text-warning", paste("Waits for a key.", KEY_HINT)))
    })

    observeEvent(input$check, {
      m <- APP_MODEL
      withProgress(message = "Checking the connection", value = 0.5, {
        r <- if (llm_key_ready(m)) ping(m) else llm_ping(m)
        results(list(c(list(model = m$id), r)))
      })
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
