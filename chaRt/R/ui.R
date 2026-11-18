# ui.R for chaRt
# What the analyst sees. Phase 0: the shared helpers, the office logo, the tab names, Start here and
#   the connection check. advice_box, warn_box, office_logo, model_label, mod_connect_ui and
#   mod_connect_server are copied from QuestionR/R/ui.R unchanged. Function definitions and
#   constants only.


# ---- the tabs ----------------------------------------------------------------

CHART_TABS <- c("Start here", "Data", "Codebook", "Explore", "Report", "Methodology")

# What a tab that a later phase builds says until then.
LATER_PHASE <- "Built in a later phase."


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
    tags$p("chaRt builds a codebook for a data file you bring, proposes and draws publishable charts ",
           "that follow written visualization rules, lets you refine a chart by chat, and writes an HTML ",
           "report of the charts you choose, each with a short summary of what it shows. Every chart and ",
           "summary describes the file, not a population."),
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
