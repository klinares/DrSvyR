# app.R for WISE repo
# Entry point. Open wise.Rproj in RStudio and click Run App.

# One folder of R code, sourced flat and alphabetically. Load order does not
#   matter because every file defines functions rather than calling them, with
#   one exception: zz_llm.R supersedes four functions that also live in
#   engine_05_prompts_label.R, and the zz_ prefix is what makes it load last.

# The engine calls survey, lavaan, viridis, furrr, knitr and kableExtra by bare
#   name, so they are attached rather than referenced with ::.

library(shiny)
library(bslib)
library(tidyverse)
library(haven)
library(survey)
library(lavaan)
library(viridis)
library(furrr)
library(knitr)
library(kableExtra)

walk(list.files("R", full.names = TRUE, pattern = "[.][Rr]$"), source)


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
    goto          = NULL)
}

WISE_TABS <- c("1. Project", "2. Design", "3. Items", "4. Domains",
               "5. Review", "6. Search", "7. Model", "8. Names",
               "9. Scoring", "10. Results", "11. Outputs", "Help")


ui <- page_fluid(
  theme = bs_theme(version = 5, preset = "flatly"),
  title = "WISE",
  
  div(
    style = "display:flex; align-items:center; gap:1rem; margin-bottom:0.5rem;",
    div(tags$h2("WISE", style = "margin:0;"),
        tags$p(tags$em("Weighted Inference for Survey Estimation"),
               style = "margin:0;")),
    div(style = "margin-left:auto;", input_dark_mode(id = "dark_mode"))),
  
  tags$hr(),
  
  navlistPanel(
    id = "stage",
    widths = c(3, 9),
    well = FALSE,
    
    tabPanel(WISE_TABS[1], mod_project_ui("project")),
    tabPanel(WISE_TABS[2], mod_design_ui("design")),
    tabPanel(WISE_TABS[3], mod_items_ui("items")),
    tabPanel(WISE_TABS[4], mod_recode_ui("recode")),
    tabPanel(WISE_TABS[5], mod_config_ui("config")),
    tabPanel(WISE_TABS[6], mod_search_ui("search")),
    tabPanel(WISE_TABS[7], mod_model_ui("model")),
    tabPanel(WISE_TABS[8], mod_labels_ui("labels")),
    tabPanel(WISE_TABS[9], mod_score_ui("score")),
    tabPanel(WISE_TABS[10], mod_domains_ui("domains")),
    tabPanel(WISE_TABS[11], mod_report_ui("report")),
    
    # The README rendered in place rather than linked out, so the guide is
    #   available with no network and cannot drift from the version installed.
    tabPanel(WISE_TABS[12], includeMarkdown("README.md"))
  )
)


server <- function(input, output, session) {
  state <- new_state()
  
  # Plots read the mode from an option rather than taking it as an argument.
  #   Correct for one analyst on one machine; on a shared server this has to
  #   become session state or one user's setting will follow another's plots.
  observe({
    options(wise.dark = identical(input$dark_mode, "dark"))
  })
  
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
}


shinyApp(ui, server)