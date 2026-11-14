# QuestionR -- Shiny app, one of the apps in the DrSvyR repository.
#   Run:     shiny::runApp("QuestionR")   (or Run App in RStudio, this file open)
#   Publish: rsconnect::deployApp("QuestionR", appName = "QuestionR")

# A plain Shiny app directory: this file (settings, layout, server), R/ (function definitions
#   only, sourced below) and www/ (served by Shiny: reflexes/, the figures, logo/). README.md says
#   how to set it up.


# ---- 1. settings an administrator may change -------------------------------

# The marking shown above every screen.
APP_CLASSIFICATION <- "UNCLASSIFIED"

# The office logo, a file in www/logo/ (a dashed box until it is there), and an optional name.
APP_LOGO <- "office_logo.png"
APP_OFFICE <- ""

# Largest questionnaire Evaluate accepts, in characters; nothing is truncated. Its questions are
#   packed into parts of at most APP_BATCH_QUESTIONS questions and APP_BATCH_CHARS characters, one
#   call each, sent four at a time, and one more call looks at the questionnaire as a whole.
APP_MAX_PASTE_CHARS <- 60000
APP_BATCH_QUESTIONS <- 8
APP_BATCH_CHARS <- 8000

# Where the "Source code" button in the header links to. At work, point it at the internal copy.
APP_SOURCE_URL <- "https://github.com/klinares/drsvyr/tree/main/QuestionR"

# The profile used when the environment variable QUESTIONR_PROFILE is not set: "home" or "work".
APP_DEFAULT_PROFILE <- "home"

# The main model per profile (the reviewer, and the editor of Write questions), and an optional
#   drafter for Write questions (without one, the main model drafts). Both use the one key pasted
#   into the box on Start here and held for the session; the environment is never read for it.
#     api              "anthropic" or "openai" (the OpenAI style)
#     base_url, id     where it is called and what the endpoint names it
#     reasoning_effort optional, "low", "medium" or "high"; sent only when set
#     max_tokens_name  optional, openai style only: "max_tokens" for an endpoint that wants
#                      the older name for the reply limit (ellmer sends max_completion_tokens)
#   work: placeholders in angle brackets, to be filled in at work (see README.md).
APP_PROFILES <- list(
  home = list(api = "anthropic", base_url = "https://api.anthropic.com/v1", id = "claude-sonnet-5-5",
              drafter = list(api = "anthropic", base_url = "https://api.anthropic.com/v1", id = "claude-sonnet-4-5")),
  work = list(api = "openai", base_url = "<work base url>", id = "<model id at work>",
              drafter = list(api = "openai", base_url = "<work base url>", id = "<drafter id at work>")))

APP_PROFILE <- local({
  p = tolower(trimws(Sys.getenv("QUESTIONR_PROFILE")))
  if (nzchar(p)) p else APP_DEFAULT_PROFILE
})
if (!APP_PROFILE %in% names(APP_PROFILES))
  stop("The profile is '", APP_PROFILE, "' (QUESTIONR_PROFILE, or APP_DEFAULT_PROFILE when that is not set); ",
       "it must be one of: ", paste(names(APP_PROFILES), collapse = ", "), call. = FALSE)
APP_MODEL <- APP_PROFILES[[APP_PROFILE]]


# ---- 2. packages ------------------------------------------------------------

library(shiny)
library(bslib)
library(purrr)
library(stringr)

# Called as pkg::fn() in R/ and never attached; listed so a missing one stops the app here, by name.
APP_PACKAGES <- c("digest", "ellmer", "htmltools", "httr2", "jsonlite", "later", "promises", "rlang", "S7")

local({
  missing = discard(APP_PACKAGES, requireNamespace, quietly = TRUE)
  if (length(missing)) stop("Not installed, so the app cannot start: ", paste(missing, collapse = ", "), call. = FALSE)
})

# The ellmer functions and arguments R/llm.R calls, checked here so a different ellmer stops the
#   app with a plain message, not in the middle of a call. Built and tested with ellmer 0.4.2.
local({
  calls = list(chat_anthropic = c("system_prompt", "params", "model", "cache", "base_url", "credentials", "echo"),
               chat_openai_compatible = c("base_url", "name", "system_prompt", "credentials", "model", "params",
                                          "api_args", "echo"),
               params = c("temperature", "max_tokens", "reasoning_effort"))
  gone = unlist(imap(calls, function(args, fn) {
    if (!fn %in% getNamespaceExports("ellmer")) return(fn)
    absent = setdiff(args, names(formals(getExportedValue("ellmer", fn))))
    if (length(absent)) paste0(fn, "(", paste(absent, collapse = ", "), ")")
  }))
  if (length(gone))
    stop("The installed ellmer (", as.character(packageVersion("ellmer")), ") has no ",
         paste(gone, collapse = "; "), ". QuestionR needs ellmer 0.4.2 or a later version that has them: ",
         "install it with install.packages(\"ellmer\") and start the app again.", call. = FALSE)
})

# The verbs R/ relies on, checked to be the ones meant: a masked verb fails here.
stopifnot(identical(map, purrr::map), identical(keep, purrr::keep), identical(discard, purrr::discard),
          identical(walk, purrr::walk))


# ---- 3. the code in R/ ------------------------------------------------------

# Every file there defines functions and constants and nothing else, so the order is safe.
walk(sort(list.files("R", pattern = "[.]R$", full.names = TRUE)), function(f)
  tryCatch(sys.source(f, envir = globalenv()),
           error = function(e) stop("Failed loading ", f, ": ", conditionMessage(e), call. = FALSE)))

# Every reflex file parsed now, so one that has lost its shape stops the app here, named.
invisible(check_reflex_files())

# runApp() evaluates this file in an environment of its own, so the settings R/ reads are put
#   in the global environment, where R/ lives.
list2env(list(APP_CLASSIFICATION = APP_CLASSIFICATION, APP_PROFILE = APP_PROFILE, APP_PROFILES = APP_PROFILES,
              APP_MODEL = APP_MODEL, APP_MAX_PASTE_CHARS = APP_MAX_PASTE_CHARS,
              APP_BATCH_QUESTIONS = APP_BATCH_QUESTIONS, APP_BATCH_CHARS = APP_BATCH_CHARS),
         envir = globalenv())


# ---- 4. process settings ----------------------------------------------------

# Cairo for every PNG: a Linux server with no display has no X11. No plots yet; set so a later
#   one does not fail on Connect.
options(bitmapType = "cairo")


# ---- 5. state ---------------------------------------------------------------

# The state the modules share: key_version, which changes whenever the pasted key
#   is saved or forgotten, so anything that depends on a key can re-run. Each task
#   page keeps its own run in a state of its own (STATE_DEFAULTS in R/ui.R).
new_state <- function() reactiveValues(key_version = 0L)


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
    tags$a("Source code", href = APP_SOURCE_URL, target = "_blank", rel = "noopener",
           class = "btn btn-outline-secondary btn-sm"),
    office_logo(APP_LOGO, APP_OFFICE),
    div(tags$h2("QuestionR", style = "margin:0;"),
        tags$p(tags$em("An AI reviewer and item writer for questionnaires, steered by written reflexes."),
               style = "margin:0;")),
    div(style = "margin-left:auto;", input_dark_mode(id = "dark_mode"))),

  tags$hr(),

  navlistPanel(
    id = "stage", widths = c(3, 9), well = FALSE,

    tabPanel(QUESTIONR_TABS[1], start_ui()),

    tabPanel(QUESTIONR_TABS[2], mod_task_ui("evaluate", "review")),
    tabPanel(QUESTIONR_TABS[3], mod_task_ui("write", "draft")),
    tabPanel(QUESTIONR_TABS[4], methodology_ui())))


# ---- 7. server --------------------------------------------------------------

server <- function(input, output, session) {
  state <- new_state()
  mod_key_server("key", state)
  mod_connect_server("connect", state)
  mod_task_server("evaluate", "review", state, make_ask_all = progress_ask_all)
  mod_task_server("write", "draft", state, make_ask_all = progress_ask_all)
}


shinyApp(ui, server)
