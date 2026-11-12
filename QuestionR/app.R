# QuestionR -- Shiny app, one of the apps in the DrSvyR repository.
#   Run:     shiny::runApp("QuestionR")   (or Run App in RStudio, this file open)
#   Publish: rsconnect::deployApp("QuestionR", appName = "QuestionR")

# A plain Shiny app directory, not a package, so a server can run it as is:
#     app.R        this file: settings, state, layout, server
#     R/           function definitions only, sourced below
#     www/         static files, served at the site root by Shiny itself:
#                  skills/ (the text files that steer every model call) and
#                  logo/ (the office logo)
# DESIGN.md says what the app does and in which phases it is built; STATUS.md
#   says where it stands.


# ---- 1. settings an administrator may change -------------------------------

# The marking shown above every screen and written into the output. Edit it
#   here; it is one line on purpose.
APP_CLASSIFICATION <- "UNCLASSIFIED"

# The office logo, a file in www/logo/. Until it is there a dashed placeholder
#   box shows where it goes. The office name beside it is optional.
APP_LOGO <- "office_logo.png"
APP_OFFICE <- ""

# Largest questionnaire the Evaluate task accepts, in characters. Over it the
#   app says so and asks for the questionnaire in parts; nothing is truncated.
#   A longer questionnaire is reviewed in parts (DESIGN.md section 14): whole
#   blocks, split on blank lines, are packed into parts of at most
#   APP_BATCH_CHARS characters, one call to the project manager each, then one
#   more call for the instrument as a whole. APP_BATCH_CHARS is the per-call
#   limit Phase 4d measured: about twice a 1,823-character questionnaire, to
#   match the evaluation ceiling (tests/review_tokens.md).
APP_MAX_PASTE_CHARS <- 40000
APP_BATCH_CHARS <- 4000

# Which models do which job, chosen by the environment variable
#   QUESTIONR_PROFILE ("home" if unset, or "work"). Each model has a key_source:
#   "analyst" is the key pasted into the key box on Start here, held for the
#   session only, and the environment is not consulted for it at all;
#   "server" is the environment variable named in key_var. A worker is one list
#   entry; adding or removing one changes nothing else. The work entries are
#   placeholders until Phase 6.
APP_PROFILES <- list(
  home = list(
    pm      = list(api = "anthropic", base_url = "https://api.anthropic.com/v1",
                   id = "claude-sonnet-5-5", key_source = "analyst"),
    workers = list(
      list(api = "openai", base_url = "https://openrouter.ai/api/v1",
           id = "google/gemma-4-31b-it",
           key_source = "server", key_var = "OPENROUTER_API_KEY"),
      list(api = "openai", base_url = "https://openrouter.ai/api/v1",
           id = "meta-llama/llama-4-maverick",
           key_source = "server", key_var = "OPENROUTER_API_KEY"),
      list(api = "openai", base_url = "https://openrouter.ai/api/v1",
           id = "openai/gpt-6-luna",
           key_source = "server", key_var = "OPENROUTER_API_KEY"))),
  work = list(
    pm      = list(api = "anthropic", base_url = "<work base url>",
                   id = "<pm id at work>", key_source = "analyst"),
    workers = list(
      list(api = "openai", base_url = "<work base url>",
           id = "<worker id at work>", key_source = "analyst"))))

APP_PROFILE <- local({
  p = tolower(trimws(Sys.getenv("QUESTIONR_PROFILE")))
  if (nzchar(p)) p else "home"
})
if (!APP_PROFILE %in% names(APP_PROFILES))
  stop("QUESTIONR_PROFILE is '", APP_PROFILE, "'; it must be one of: ",
       paste(names(APP_PROFILES), collapse = ", "), call. = FALSE)
APP_MODELS <- APP_PROFILES[[APP_PROFILE]]


# ---- 2. packages ------------------------------------------------------------

library(shiny)
library(bslib)
library(purrr)
library(stringr)

# Called as pkg::fn() in R/ and never attached. Listed so a missing one stops
#   the app here, by name, rather than three screens later. S7 and httr2 come
#   with ellmer; R/llm.R calls them directly, to read a reply's finish reason and
#   an HTTP error's status.
APP_PACKAGES <- c("digest", "ellmer", "httr2", "jsonlite", "rlang", "S7")

local({
  missing = discard(APP_PACKAGES, requireNamespace, quietly = TRUE)
  if (length(missing))
    stop("Not installed, so the app cannot start: ",
         paste(missing, collapse = ", "), call. = FALSE)
})

# The verbs R/ relies on, checked to be the ones meant. A masked verb fails
#   here rather than producing a wrong prompt later.
stopifnot(
  identical(map, purrr::map), identical(keep, purrr::keep),
  identical(discard, purrr::discard), identical(walk, purrr::walk))


# ---- 3. the code in R/ ------------------------------------------------------

# Every file there defines functions and constants and nothing else, which is
#   what makes sourcing the folder in any order safe. Keep it that way.
walk(sort(list.files("R", pattern = "[.]R$", full.names = TRUE)), function(f)
  tryCatch(sys.source(f, envir = globalenv()),
           error = function(e) stop("Failed loading ", f, ": ",
                                    conditionMessage(e), call. = FALSE)))

# Every skill file parsed now, so one that has lost its shape stops the app here
#   with the file and the reflex named, not at the first request that needs it.
invisible(check_skills())

# R/ lives in the global environment, but runApp() evaluates this file in an
#   environment of its own, so nothing assigned here is visible to R/ unless
#   it is put there. These are the settings R/ reads.
list2env(list(APP_CLASSIFICATION = APP_CLASSIFICATION,
              APP_PROFILE = APP_PROFILE,
              APP_MODELS = APP_MODELS,
              APP_MAX_PASTE_CHARS = APP_MAX_PASTE_CHARS,
              APP_BATCH_CHARS = APP_BATCH_CHARS),
         envir = globalenv())


# ---- 4. process settings ----------------------------------------------------

# Cairo for every PNG. A Linux server with no display has no X11, and R's
#   default bitmap device there can still be Xlib, which fails with "unable to
#   start device PNG". There are no plots in the first build; this is set so a
#   later one does not fail on Connect.
options(bitmapType = "cairo")


# ---- 5. state ---------------------------------------------------------------

# One state object, passed to every module. Modules read from it and write to
#   it; they never talk to each other. What it holds, and what each field is for,
#   is STATE_DEFAULTS in R/ui_generate.R, so a test can make the same object.
#   key_version changes whenever the pasted key is saved or forgotten, so
#   anything that depends on a key can re-run.
new_state <- function() do.call(reactiveValues, STATE_DEFAULTS)


# ---- 6. layout --------------------------------------------------------------

ui <- page_fluid(
  theme = bs_theme(version = 5, preset = "flatly"),
  title = "QuestionR",

  # Above everything, on every tab.
  tags$div(
    style = paste("background:#b40404; color:#fff; text-align:center;",
                  "font-weight:700; letter-spacing:0.06em;",
                  "padding:5px 0; font-size:13px;"),
    APP_CLASSIFICATION),

  div(
    style = "display:flex; align-items:center; gap:1rem; margin:0.5rem 0;",
    office_logo(APP_LOGO, APP_OFFICE),
    div(tags$h2("QuestionR", style = "margin:0;"),
        tags$p(tags$em("Draft survey items and review a questionnaire, with ",
                       "every model call steered by methodology files."),
               style = "margin:0;")),
    div(style = "margin-left:auto;", input_dark_mode(id = "dark_mode"))),

  tags$hr(),

  navlistPanel(
    id = "stage", widths = c(3, 9), well = FALSE,

    tabPanel(QUESTIONR_TABS[1], help_ui(), mod_key_ui("key"), mod_connect_ui("connect")),

    tabPanel(QUESTIONR_TABS[2], mod_brief_ui("brief")),
    tabPanel(QUESTIONR_TABS[3], mod_prompt_ui("prompt")),
    tabPanel(QUESTIONR_TABS[4], mod_results_ui("results"), mod_again_ui("again")),
    tabPanel(QUESTIONR_TABS[5], mod_output_ui("output")),
    tabPanel(QUESTIONR_TABS[6], methodology_page())))


# ---- 7. server --------------------------------------------------------------

server <- function(input, output, session) {
  state <- new_state()
  # How a module moves the analyst to another tab. It is given the root session,
  #   because a module's own session would look for the navlist inside its namespace.
  go <- function(tab) updateNavlistPanel(session, "stage", selected = tab)
  mod_key_server("key", state)
  mod_connect_server("connect", state)
  mod_brief_server("brief", state, go = go)
  mod_prompt_server("prompt", state, go = go)
  mod_results_server("results", state, go = go)
  mod_again_server("again", state, go = go)
  mod_output_server("output", state)
}


shinyApp(ui, server)
