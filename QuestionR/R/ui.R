# ui.R for QuestionR
# The tab titles, the small helpers the tabs share, and Start here. The other
#   screens are in ui_generate.R. Function definitions and constants only (root
#   CLAUDE.md rule 2).

# The tab titles, in order. The navlist in app.R and any code that moves the
#   analyst between tabs both read this.
QUESTIONR_TABS <- c("Start here", "1. Brief", "2. Prompt", "3. Results",
                    "4. Output", "Methodology")


# ---- shared helpers ----------------------------------------------------------

# A note the analyst should read. The theme variables keep it legible in dark
#   mode.
advice_box <- function(...) {
  shiny::tags$div(
    style = paste("background: var(--bs-tertiary-bg);",
                  "border-left: 3px solid var(--bs-primary);",
                  "color: var(--bs-body-color);",
                  "padding: 8px 12px; margin: 12px 0;"),
    ...)
}

# A consequence the analyst should see before they cause it. The fallbacks
#   matter: a fixed background with an inherited foreground is how a panel ends
#   up pale text on a pale block the moment the theme changes underneath it.
warn_box <- function(...) {
  shiny::tags$div(
    style = paste(
      "background: var(--bs-warning-bg-subtle, #fdf6ec);",
      "border-left: 3px solid var(--bs-warning, #d9a441);",
      "color: var(--bs-warning-text-emphasis, var(--bs-body-color));",
      "padding: 8px 12px; margin: 12px 0; font-size: 90%;"),
    ...)
}

# ---- the office logo ---------------------------------------------------------
# The file named in app.R (APP_LOGO), served from www/logo/. Until it exists,
#   a dashed box shows where it goes.
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

# What a review has been shown to do, in the words of the Methodology tab: the section "How it was
#   tested" of www/methodology.md, with the result of the one test and its limits, copied as it
#   stands (it is read from the file, so it cannot drift from it), and the model in force.
pilot_notice <- function(path = METHODOLOGY_FILE, m = APP_MODEL) {
  txt = tryCatch(readLines(path, encoding = "UTF-8", warn = FALSE), error = function(e) character(0))
  at = grep("^## How it was tested", txt)
  rest = if (length(at)) txt[-seq_len(at[[1]])]
  section = trimws(paste(rest[cumsum(grepl("^#", rest)) == 0L], collapse = "\n"))
  advice_box(
    tags$strong("This is a pilot. "),
    "The review step has been tested once, on a published set of questions with known faults. This is what the ",
    "Methodology tab says of it:",
    if (nzchar(section)) HTML(shiny::markdown(section))
    else tags$p("(The Methodology tab's account of the test could not be read.)"),
    tags$p(paste0("The model in force here is ", m$id, "; that test used claude-sonnet-5-5.")))
}

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

# Start here: the welcome in www/start.md as it is, then the key box, then, closed, the settings in
#   force, the pilot notice and the connection check. The panel opens by itself when a profile still
#   holds placeholders, since that is the first thing to deal with.
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
      pilot_notice(),
      tags$h5("Settings in force"),
      tags$table(
        class = "table table-sm",
        tags$tbody(
          row("Profile", APP_PROFILE),
          row("Classification banner", APP_CLASSIFICATION),
          row("Pasted questionnaire limit",
              paste(format(APP_MAX_PASTE_CHARS, big.mark = ","), "characters")))),
      mod_connect_ui("connect")))
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
