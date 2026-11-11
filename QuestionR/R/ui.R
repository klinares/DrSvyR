# ui.R for QuestionR
# The tabs' UI, and the small helpers they share. Function definitions and
#   constants only (root CLAUDE.md rule 2). Phase 0: Start here is real, the
#   other tabs are placeholders that say which phase builds them.

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

# Where a model's key comes from, in words. Never the key itself, and never a
#   look at the environment: whether a variable is set is Phase 2's connection
#   check.
key_source_label <- function(m) {
  if (identical(m$key_source, "analyst")) "key pasted below"
  else paste0("key from the server variable ", m$key_var)
}

model_label <- function(m)
  tagList(tags$code(m$id), tags$br(),
          tags$span(class = "text-muted small",
                    paste0(m$api, " API at ", m$base_url, "; ", key_source_label(m))))

# The settings that are in force for this process, read from the globals app.R
#   assigns (APP_CLASSIFICATION, APP_PROFILE, APP_MODELS, APP_MAX_PASTE_CHARS).
settings_table <- function() {
  row = function(label, value) tags$tr(tags$th(scope = "row", label), tags$td(value))
  tags$table(
    class = "table table-sm",
    tags$tbody(
      row("Profile", APP_PROFILE),
      row("Classification banner", APP_CLASSIFICATION),
      row("Project manager", model_label(APP_MODELS$pm)),
      purrr::imap(APP_MODELS$workers, function(m, i)
        row(paste("Worker", i), model_label(m))),
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


# ---- the tabs that are not built yet -----------------------------------------

# One placeholder per later tab, naming the phase that builds it (DESIGN.md
#   section 10), so an empty tab is not mistaken for a broken one.
tab_placeholder <- function(title, phase, what)
  tagList(
    tags$h3(title),
    tags$p(tags$em(paste0("Not built yet: this tab arrives in Phase ", phase, "."))),
    tags$p(what))
