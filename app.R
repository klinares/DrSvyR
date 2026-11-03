# DrSvyR -- Shiny app.
#   Run:     shiny::runApp(".")      (or Run App in RStudio with this file open)
#   Publish: rsconnect::deployApp(".")

# Branch shiny_app. On main DrSvyR is an R package launched with
#   drsvyr::run_drsvyr(). This branch is the same analysis as a plain Shiny app
#   directory, because a package is something a server has to install and a
#   directory is something it can just run:
#     app.R        this file: settings, state, layout, server
#     R/           function definitions only, sourced below
#     help.md      the Start here page
#     www/         static files, served at the site root by Shiny itself
#     data/        the demonstration survey


# ---- 1. settings an administrator may change -------------------------------

# The marking shown above every screen and written into the report. Edit it
#   here; it is one line on purpose.
APP_CLASSIFICATION <- "UNCLASSIFIED"

# Largest survey file the Project screen accepts. Shiny's default is 5 MB,
#   which any real survey clears. haven expands a .sav to two to four times its
#   size in memory and the raw file, codebook and design frame coexist, so this
#   is the number to lower first on a small server.
APP_MAX_UPLOAD_MB <- 300


# ---- 2. packages ------------------------------------------------------------

# Order matters. survey attaches Matrix, whose expand(), pack() and unpack()
#   mask tidyr's, so the tidyverse is attached after it and its verbs win.
library(shiny)
library(bslib)
library(survey)
library(haven)
library(ggplot2)
library(purrr)
library(stringr)
library(tibble)
library(tidyr)
library(dplyr)

# Called as pkg::fn() in R/ and never attached. Listed so a missing one stops
#   the app here, by name, rather than three screens later.
APP_PACKAGES <- c(
  "base64enc", "curl", "digest", "fs", "janitor", "jsonlite", "knitr",
  "markdown", "matrixStats", "MetBrewer", "readr", "rlang", "viridis", "yaml")

local({
  missing = discard(APP_PACKAGES, requireNamespace, quietly = TRUE)
  if (length(missing))
    stop("Not installed, so the app cannot start: ",
         paste(missing, collapse = ", "), call. = FALSE)
})

# What a NAMESPACE used to guarantee, checked. A masked verb fails here rather
#   than producing a wrong table later.
stopifnot(
  identical(filter, dplyr::filter), identical(select, dplyr::select),
  identical(count, dplyr::count),   identical(expand, tidyr::expand),
  identical(pack, tidyr::pack),     identical(unpack, tidyr::unpack),
  identical(map, purrr::map))


# ---- 3. the code in R/ ------------------------------------------------------

# Every file there defines functions and nothing else, which is what makes
#   sourcing the folder in any order safe. Keep it that way.
walk(sort(list.files("R", pattern = "[.]R$", full.names = TRUE)), function(f)
  tryCatch(sys.source(f, envir = globalenv()),
           error = function(e) stop("Failed loading ", f, ": ",
                                    conditionMessage(e), call. = FALSE)))


# ---- 4. process settings ----------------------------------------------------

# Cairo for every PNG: renderPlot() and the report figures alike. A Linux
#   server with no display has no X11, and R's default bitmap device there can
#   still be Xlib, which fails with "unable to start device PNG". plot_data_uri()
#   in R/results.R also asks for cairo explicitly.
options(bitmapType = "cairo",
        shiny.maxRequestSize = APP_MAX_UPLOAD_MB * 1024^2)


# ---- 5. state ---------------------------------------------------------------

# One state object, passed to every module. Modules read from it and write to
#   it; they never talk to each other. A stage that needs something a previous
#   stage has not produced sees NULL and says so, which is what makes the
#   sequence enforce itself without explicit gating.
# goto is the exception: a module that has invalidated everything downstream
#   sets it, and the observer in the server moves the analyst there.
new_state <- function() {
  reactiveValues(
    work_dir = NULL, data_file = NULL, format = NULL, raw = NULL,
    codebook = NULL, design_map = NULL, design_dat = NULL,
    design_checks = NULL, context = NULL, na_codes = NULL,
    item_frame = NULL, item_summary = NULL, demo_specs = NULL,
    demo_dat = NULL, demo_counts = NULL, recode_audit = NULL,
    cfg = NULL, cfg_paths = NULL, config_readback = NULL,
    search = NULL, search_key = NULL, dimension = NULL, search_reading = NULL,
    model = NULL, model_key = NULL, model_accepted = NULL, model_dat = NULL,
    measure = NULL, diag_reading = NULL,
    labels = NULL, labels_drafted = NULL, labels_edited = NULL,
    scored = NULL, score_design = NULL, coverage = NULL, quality = NULL,
    shares = NULL, domains = NULL, domain_reads = NULL, question = NULL,
    report_summary = NULL, report_not_answered = NULL,
    report_classification = NULL, report_html = NULL, outputs = NULL,
    key_version = 0L,
    goto = NULL)
}

# Start here is first so it is where the app opens.
WISE_TABS <- c("Start here",
               "1. Project", "2. Design", "3. Items", "4. Domains",
               "5. Review", "6. Search", "7. Model", "8. Names",
               "9. Scoring", "10. Results", "11. Outputs")


# ---- 6. layout --------------------------------------------------------------

ui <- page_fluid(
  theme = bs_theme(version = 5, preset = "flatly"),
  title = "DrSvyR",

  # Above everything, on every tab.
  tags$div(
    style = paste("background:#b40404; color:#fff; text-align:center;",
                  "font-weight:700; letter-spacing:0.06em;",
                  "padding:5px 0; font-size:13px;"),
    APP_CLASSIFICATION),

  div(
    style = "display:flex; align-items:center; gap:1rem; margin-bottom:0.5rem;",
    div(tags$h2("DrSvyR", style = "margin:0;"),
        tags$p(tags$em("A survey methodologist you can consult, working on ",
                       "data you already have."),
               style = "margin:0;")),
    div(style = "margin-left:auto;", input_dark_mode(id = "dark_mode"))),

  # Markdown images carry no sizing; this keeps the help figures in the panel.
  tags$head(tags$style(HTML(
    ".tab-content img { max-width: 100%; height: auto; }"))),

  tags$hr(),

  navlistPanel(
    id = "stage", widths = c(3, 9), well = FALSE,

    # help.md's images are written as figures/..., and Shiny serves www/ at
    #   the site root, so they resolve with no resource path to register.
    tabPanel(WISE_TABS[1], includeMarkdown("help.md"), mod_key_ui("key")),

    tabPanel(WISE_TABS[2],  mod_project_ui("project")),
    tabPanel(WISE_TABS[3],  mod_design_ui("design")),
    tabPanel(WISE_TABS[4],  mod_items_ui("items")),
    tabPanel(WISE_TABS[5],  mod_recode_ui("recode")),
    tabPanel(WISE_TABS[6],  mod_config_ui("config")),
    tabPanel(WISE_TABS[7],  mod_search_ui("search")),
    tabPanel(WISE_TABS[8],  mod_model_ui("model")),
    tabPanel(WISE_TABS[9],  mod_labels_ui("labels")),
    tabPanel(WISE_TABS[10], mod_score_ui("score")),
    tabPanel(WISE_TABS[11], mod_domains_ui("domains")),
    tabPanel(WISE_TABS[12], mod_report_ui("report"))))


# ---- 7. server --------------------------------------------------------------

server <- function(input, output, session) {
  state <- new_state()

  observeEvent(state$goto, {
    updateNavlistPanel(session, "stage", selected = state$goto)
    state$goto <- NULL
  }, ignoreNULL = TRUE)

  mod_key_server("key", state)
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
