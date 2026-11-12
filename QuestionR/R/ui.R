# ui.R for QuestionR
# The tab titles, the small helpers the tabs share, Start here, and the
#   placeholders for the tabs not built yet. The Generate flow's four screens
#   (Brief, Prompt, Results, Run again) are in ui_generate.R. Function
#   definitions and constants only (root CLAUDE.md rule 2).

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

# Where a model's key comes from, in words. Never the key itself.
key_source_label <- function(m) {
  if (identical(m$key_source, "analyst")) "key pasted below"
  else paste0("key from the server variable ", m$key_var)
}

model_label <- function(m)
  tagList(tags$code(m$id), tags$br(),
          tags$span(class = "text-muted small",
                    paste0(m$api, " API at ", m$base_url, "; ", key_source_label(m))))

# The settings that are in force for this process, read from the globals app.R
#   assigns (APP_CLASSIFICATION, APP_PROFILE, APP_MAX_PASTE_CHARS). The models
#   are in their own table, with whether each has a key.
settings_table <- function() {
  row = function(label, value) tags$tr(tags$th(scope = "row", label), tags$td(value))
  tags$table(
    class = "table table-sm",
    tags$tbody(
      row("Profile", APP_PROFILE),
      row("Classification banner", APP_CLASSIFICATION),
      row("Pasted questionnaire limit",
          paste(format(APP_MAX_PASTE_CHARS, big.mark = ","), "characters"))))
}

help_ui <- function() {
  tagList(
    tags$h3(QUESTIONR_TABS[1]),
    tags$p("QuestionR helps a public opinion analyst draft survey items and ",
           "review a questionnaire. Every model call is steered by plain text ",
           "files grounded in survey methodology; the expertise is in those ",
           "files, not in the model."),

    tags$h5("What it is not"),
    advice_box(tags$ul(
      class = "mb-0",
      tags$li("It is not a pretest. A draft is a first draft written by a ",
              "language model, and a review is an expert-review appraisal by a ",
              "language model. Test with real respondents before fielding."),
      tags$li("It does not choose for you. It compares and flags; you decide. ",
              "Nothing it produces is called validated."),
      tags$li("It saves nothing you paste. Text you enter goes only to the ",
              "model endpoints listed below."))),

    tags$h5("Settings in force"),
    settings_table())
}

# The models, and whether each has a key; and a button that makes one very small
#   call to each. Never shows a key. A model with no key is not called: it says
#   what is missing. The calls run one after another, and that R process is busy
#   until they finish. ping is the function that calls one model, so a test can
#   stand in for the network.
mod_connect_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$hr(),
    tags$h4("Models"),
    uiOutput(ns("models")),
    actionButton(ns("check"), "Check connections"),
    tags$p(class = "text-muted small mt-2",
           "Makes one very small call to each model that has a key, and shows ",
           "whether it answered or what the endpoint said. Nothing you have ",
           "entered is sent."),
    uiOutput(ns("result")))
}

mod_connect_server <- function(id, state, ping = llm_ping) {
  moduleServer(id, function(input, output, session) {
    results <- reactiveVal(NULL)

    output$models <- renderUI({
      state$key_version   # a key pasted or forgotten changes who is ready
      tags$table(
        class = "table table-sm",
        tags$thead(tags$tr(tags$th("Role"), tags$th("Model"), tags$th("Key"))),
        tags$tbody(purrr::map(llm_models(), function(x) {
          ready = llm_key_ready(x$m)
          tags$tr(tags$td(x$role), tags$td(model_label(x$m)),
                  tags$td(if (ready) tags$span(class = "text-success", "ready")
                          else tagList(tags$span(class = "text-warning", "waits for a key"),
                                       tags$br(),
                                       tags$span(class = "text-muted small", llm_key_hint(x$m)))))
        })))
    })

    observeEvent(input$check, {
      ms <- llm_models()
      withProgress(message = "Checking connections", value = 0, {
        out <- purrr::map(ms, function(x) {
          incProgress(1 / length(ms), detail = x$m$id)
          r <- if (llm_key_ready(x$m)) ping(x$m) else llm_ping(x$m)
          c(list(role = x$role, model = x$m$id), r)
        })
        results(out)
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


# ---- the tabs that are not built yet -----------------------------------------

# One placeholder per later tab, naming the phase that builds it (DESIGN.md
#   section 10), so an empty tab is not mistaken for a broken one.
tab_placeholder <- function(title, phase, what)
  tagList(
    tags$h3(title),
    tags$p(tags$em(paste0("Not built yet: this tab arrives in Phase ", phase, "."))),
    tags$p(what))
