# app.R for DrSvyR
# Entry point. Open the .Rproj in this folder in RStudio and click Run App.

# One folder of R code, sourced flat and alphabetically. Load order does not
#   matter: every file in R/ defines functions and never calls them. That is
#   the rule that makes the flat source safe, and it is why app.R and
#   setup_renv.R live here rather than in R/ -- both do things.

# The engine calls survey, lavaan, viridis, furrr and knitr by bare name, so
#   they are attached rather than referenced with ::. kableExtra is not: its
#   only user was lca_table(), which nothing calls, and it needs Rtools on a
#   mirror without a binary for it.

library(shiny)
library(bslib)

# The tidyverse meta-package is deliberately not attached. Installing it drags
#   in a large set this project never touches -- googledrive, googlesheets4,
#   httr, rvest, xml2, broom, modelr, dbplyr, reprex -- and on a curated mirror
#   every one of those is another package to get approved. The nine below are
#   what library(tidyverse) would have attached, and nothing else.
library(dplyr); library(purrr); library(tibble); library(tidyr)
library(stringr); library(ggplot2); library(readr)
library(forcats); library(lubridate)

library(haven)
library(survey)
library(lavaan)
library(viridis)
library(furrr)
library(knitr)

# Every path below is relative to the repository root, so a session started
#   somewhere else fails later and in a way that describes anything but the
#   cause. Checked here, where the message can name it.
if (!dir.exists("R"))
  stop("Cannot see the R/ folder from ", getwd(), ".\n",
       "Open the .Rproj in the repository folder and run the app from there.",
       call. = FALSE)

walk(list.files("R", full.names = TRUE, pattern = "[.][Rr]$"), source)

# Shiny serves static files from www/ and nowhere else, so a figure referenced
#   from README.md as figures/... would render on GitHub and 404 in the Help
#   tab. Mapping the folder makes one path work in both places.
if (dir.exists("figures")) addResourcePath("figures", "figures")


# One state object, passed to every module. Modules read from it and write to
#   it; they never talk to each other. A stage that needs something a previous
#   stage has not produced sees NULL and says so, which is what makes the
#   sequence enforce itself without explicit gating.

# goto is the exception: a module that has invalidated everything downstream
#   sets it, and the observer below moves the analyst there. Without it, "go
#   back and start again" is an instruction rather than a step.
new_state <- function() {
  reactiveValues(
    work_dir      = NULL,
    data_file     = NULL,
    format        = NULL,
    raw           = NULL,
    codebook      = NULL,
    design_map    = NULL,
    design_dat    = NULL,
    design_checks = NULL,
    context       = NULL,
    na_codes      = NULL,
    item_frame    = NULL,
    item_summary  = NULL,
    item_suggestions = NULL,
    arm_diag      = NULL,
    arm_advice    = NULL,
    arm           = NULL,
    estimator     = NULL,
    demo_specs    = NULL,
    demo_dat      = NULL,
    demo_counts   = NULL,
    recode_audit  = NULL,
    cfg           = NULL,
    cfg_paths     = NULL,
    config_readback = NULL,
    search        = NULL,
    dimension     = NULL,
    search_reading = NULL,
    model         = NULL,
    model_key     = NULL,
    model_accepted = NULL,
    model_dat     = NULL,
    measure       = NULL,
    diag_reading  = NULL,
    labels        = NULL,
    labels_drafted = NULL,
    labels_edited = NULL,
    scored        = NULL,
    score_design  = NULL,
    coverage      = NULL,
    quality       = NULL,
    shares        = NULL,
    domains       = NULL,
    domain_reads  = NULL,
    question      = NULL,
    report_summary = NULL,
    report_not_answered = NULL,
    report_html   = NULL,
    outputs       = NULL,

    # The methodologist panel. proposals is every staged action and what the
    #   analyst did with it; pending_proposal is the one awaiting a decision.
    #   key_version is a counter, never a key: it exists so a change of key
    #   discards any conversation holding the previous one.
    proposals         = NULL,
    pending_proposal  = NULL,
    key_version       = 0L,

    goto          = NULL)
}

# Start here is first so it is where the app opens. An analyst landing on
#   "1. Project" with no orientation has to work out what the tool is from a
#   folder picker, and a guide sitting thirteenth in the list is one nobody
#   reads. Methodologist sits outside the numbered sequence for the opposite
#   reason: it is not a stage to be completed but an adviser available at any
#   of them.
WISE_TABS <- c("Start here",
               "1. Project", "2. Design", "3. Items", "4. Domains",
               "5. Review", "6. Search", "7. Model", "8. Names",
               "9. Scoring", "10. Results", "11. Outputs",
               "Methodologist")


ui <- page_fluid(
  theme = bs_theme(version = 5, preset = "flatly"),
  title = "DrSvyR",
  
  div(
    style = "display:flex; align-items:center; gap:1rem; margin-bottom:0.5rem;",
    div(tags$h2("DrSvyR", style = "margin:0;"),
        tags$p(tags$em("Design-based segmentation for survey data"),
               style = "margin:0;")),
    div(style = "margin-left:auto;", input_dark_mode(id = "dark_mode"))),
  
  # Markdown rendered by includeMarkdown() carries no sizing, so a figure comes
  #   through at its natural pixel width and overflows the panel. Scoped to the
  #   tab content, so it constrains the Help figures without reaching the
  #   header above them.
  tags$head(tags$style(HTML(
    ".tab-content img { max-width: 100%; height: auto; }"))),

  tags$hr(),
  
  navlistPanel(
    id = "stage",
    widths = c(3, 9),
    well = FALSE,
    
    # help.md rather than README.md. One document cannot serve both a reader
    #   deciding whether to trust the tool and an analyst who has it open and
    #   needs to start; they want opposite things. Rendered in place rather
    #   than linked out, so it needs no network and cannot drift from the
    #   version installed.
    tabPanel(WISE_TABS[1],
             includeMarkdown("help.md"),
             mod_key_ui("key")),

    tabPanel(WISE_TABS[2], mod_project_ui("project")),
    tabPanel(WISE_TABS[3], mod_design_ui("design")),
    tabPanel(WISE_TABS[4], mod_items_ui("items")),
    tabPanel(WISE_TABS[5], mod_recode_ui("recode")),
    tabPanel(WISE_TABS[6], mod_config_ui("config")),
    tabPanel(WISE_TABS[7], mod_search_ui("search")),
    tabPanel(WISE_TABS[8], mod_model_ui("model")),
    tabPanel(WISE_TABS[9], mod_labels_ui("labels")),
    tabPanel(WISE_TABS[10], mod_score_ui("score")),
    tabPanel(WISE_TABS[11], mod_domains_ui("domains")),
    tabPanel(WISE_TABS[12], mod_report_ui("report")),

    tabPanel(WISE_TABS[13], mod_chat_ui("chat"))
  )
)


server <- function(input, output, session) {
  state <- new_state()
  
  # Figures are theme-neutral, so nothing here has to know which mode is in
  #   use. That is what makes them safe on a server: the option this used to
  #   set was process-wide and would have followed one analyst into another's
  #   plots.
  
  observeEvent(state$goto, {
    updateNavlistPanel(session, "stage", selected = state$goto)
    state$goto <- NULL
  }, ignoreNULL = TRUE)
  
  mod_project_server("project", state)
  mod_design_server("design", state)
  mod_items_server("items", state)
  mod_recode_server("recode", state)
  mod_config_server("config", state)
  mod_search_server("search", state)
  mod_model_server("model", state)
  mod_labels_server("labels", state)
  mod_score_server("score", state)
  mod_domains_server("domains", state)
  mod_report_server("report", state)

  # "Why did this respondent not get a score" cannot be answered from the
  #   console, because state lives in here and nowhere else. On request, a
  #   plain snapshot is left in the global environment when the session ends
  #   -- a copy, not the reactiveValues object, so nothing typed afterwards
  #   can write back into a run. Enable with options(drsvyr.debug = TRUE)
  #   before runApp().
  if (isTRUE(getOption("drsvyr.debug")))
    session$onSessionEnded(function()
      assign("state", isolate(reactiveValuesToList(state)),
             envir = globalenv()))

  # Handed the current tab rather than inferring the stage from whatever state
  #   happens to hold, so it answers about where the analyst actually is.
  mod_chat_server("chat", state, reactive(input$stage))
  mod_key_server("key", state)
}


shinyApp(ui, server)
