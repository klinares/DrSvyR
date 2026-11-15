# SurvAI_Expert -- answers survey methodology questions from a store of course materials, with
#   sources, formulas from the store, and R code. One of the apps in the DrSvyR repository.
#   Run:     shiny::runApp("SurvAI_Expert")
#   Console: setwd("SurvAI_Expert"); source("app.R"); ask("How do I compute a design effect for a cluster sample?")
#   The store is data/store/survai.duckdb, built by build/03_store.R. README.md says how to set it up.


# ---- 1. settings an administrator may change -------------------------------

# The marking shown above every screen, and the office logo (a file in www/logo/) and name.
APP_CLASSIFICATION <- "UNCLASSIFIED"
APP_LOGO <- "office_logo.png"
APP_OFFICE <- ""

# The model per profile, called through ellmer only. Each question uses two calls.
#   api        "anthropic" (ellmer::chat_anthropic) or "openai" (ellmer::chat_openai_compatible)
#   base_url   where it is called; id: what the endpoint names the model
#   effort     reasoning effort per kind of call, sent only when set
#   json       how a reply is held to a JSON schema: "output_config" (Anthropic structured
#              output), "response_format" (OpenAI style), or "prompt" (asked for in words only)
#   price      USD per million tokens (input, output, cached input), for the cost lines; NA when unknown
#   work: placeholders in angle brackets, to be filled in at work.
MODEL_PROFILES <- list(
  home = list(api = "anthropic", base_url = "https://api.anthropic.com/v1", id = "claude-sonnet-5-5",
              effort = c(plan = "low", answer = "medium", judge = "medium", report = "medium"), json = "output_config",
              price = c(input = 2, output = 10, cached = 0.10)),
  work = list(api = "<api at work: anthropic or openai>", base_url = "<work base url>", id = "<Opus 5 id at work>",
              effort = c(plan = "low", answer = "medium", judge = "medium", report = "medium"), json = "response_format",
              price = c(input = NA, output = NA, cached = NA)))

# The profile used when the environment variable SURVAI_PROFILE is not set: "home" or "work".
MODEL_PROFILE <- local({
  p = tolower(trimws(Sys.getenv("SURVAI_PROFILE")))
  if (nzchar(p)) p else "home"
})

# Where a source's markdown file opens: {path} is its path under SurvAI_Expert/, {line} its first
#   line. At work, point it at the internal copy of the repository.
APP_SOURCE_URL <- "https://github.com/klinares/drsvyr/blob/main/SurvAI_Expert/{path}?plain=1#L{line}"

# Model calls one session may make in CALL_WINDOW_MINUTES (R/session.R); NA for no limit.
CALLS_PER_WINDOW <- NA_integer_   # at work: 300

STORE_PATH <- "data/store/survai.duckdb"
VOCAB_CSV <- "data/catalog/vocabulary.csv"
REFLEX_DIR <- "www/reflexes"

# Console use and tests only: the environment variable the key is read from. In the app, the key is
#   the one pasted on Start here, held for the session; the environment is not read for it.
KEY_ENV <- "ANTHROPIC_API_KEY"

if (!MODEL_PROFILE %in% names(MODEL_PROFILES))
  stop("The profile is '", MODEL_PROFILE, "' (SURVAI_PROFILE); it must be one of: ",
       paste(names(MODEL_PROFILES), collapse = ", "), call. = FALSE)


# ---- 2. packages ------------------------------------------------------------

library(shiny)
library(bslib)
library(dplyr)
library(purrr)
library(stringr)
library(tibble)
library(DBI)
library(duckdb)

# Called as pkg::fn() in R/ and never attached; a missing one stops here, by name.
APP_PACKAGES <- c("commonmark", "coro", "ellmer", "htmltools", "jsonlite", "katex", "later", "pdftools", "promises", "tidyr", "xml2")
local({
  missing = discard(APP_PACKAGES, requireNamespace, quietly = TRUE)
  if (length(missing)) stop("Not installed, so the app cannot start: ", paste(missing, collapse = ", "), call. = FALSE)
})

# The ellmer functions and arguments R/llm.R calls; built and tested with ellmer 0.4.2.
local({
  calls = list(chat_anthropic = c("system_prompt", "params", "model", "api_args", "base_url", "credentials", "echo"),
               chat_openai_compatible = c("base_url", "name", "system_prompt", "credentials", "model", "params", "api_args", "echo"),
               params = "max_tokens")
  gone = unlist(imap(calls, function(args, fn) {
    if (!fn %in% getNamespaceExports("ellmer")) return(fn)
    absent = setdiff(args, names(formals(getExportedValue("ellmer", fn))))
    if (length(absent)) paste0(fn, "(", paste(absent, collapse = ", "), ")")
  }))
  if (length(gone)) stop("The installed ellmer (", as.character(packageVersion("ellmer")), ") has no ",
                         paste(gone, collapse = "; "), ". Install ellmer 0.4.2 or later.", call. = FALSE)
})

stopifnot(identical(map, purrr::map), identical(keep, purrr::keep), identical(filter, dplyr::filter))


# ---- 3. the code in R/ ------------------------------------------------------

walk(sort(list.files("R", pattern = "[.]R$", full.names = TRUE)), function(f)
  tryCatch(sys.source(f, envir = globalenv()),
           error = function(e) stop("Failed loading ", f, ": ", conditionMessage(e), call. = FALSE)))

# runApp() evaluates this file in an environment of its own, so the settings R/ reads are put in
#   the global environment, where R/ lives.
list2env(list(APP_CLASSIFICATION = APP_CLASSIFICATION, MODEL_PROFILES = MODEL_PROFILES, MODEL_PROFILE = MODEL_PROFILE,
              APP_SOURCE_URL = APP_SOURCE_URL, CALLS_PER_WINDOW = CALLS_PER_WINDOW, STORE_PATH = STORE_PATH,
              VOCAB_CSV = VOCAB_CSV, REFLEX_DIR = REFLEX_DIR, KEY_ENV = KEY_ENV), envir = globalenv())


# ---- 4. process settings ----------------------------------------------------

options(bitmapType = "cairo", ellmer_timeout_s = LLM_TIMEOUT_S)
if (!file.exists(STORE_PATH)) stop("The store ", STORE_PATH, " is missing: run build/03_store.R first.", call. = FALSE)


# ---- 5. layout --------------------------------------------------------------

ui <- page_fluid(
  theme = bs_theme(version = 5, preset = "flatly"),
  title = "SurvAI Expert",
  tags$head(tags$style(HTML(APP_CSS)), tags$script(HTML(APP_JS))),
  classification_banner(APP_CLASSIFICATION),
  div(style = "display:flex; align-items:center; gap:1rem; margin:0.5rem 0;",
      office_logo(APP_LOGO, APP_OFFICE),
      div(tags$h2("SurvAI Expert", style = "margin:0;"),
          tags$p(tags$em("Survey methodology answers from the course materials, with sources."), style = "margin:0;")),
      div(style = "margin-left:auto;", input_dark_mode(id = "dark_mode"))),
  tags$hr(),
  navlistPanel(
    id = "tab", widths = c(2, 10), well = FALSE,
    tabPanel(APP_TABS[1], start_ui("start")),
    tabPanel(APP_TABS[2], ask_ui("ask")),
    tabPanel(APP_TABS[3], formulas_ui("formulas")),
    tabPanel(APP_TABS[4], report_ui("report"))))


# ---- 6. server --------------------------------------------------------------

server <- function(input, output, session) {
  # The store, opened read only once per session.
  con <- store_connect(STORE_PATH)
  session$onSessionEnded(function() dbDisconnect(con))
  state <- reactiveValues(key_version = 0L, calls = 0L)
  start_server("start", state, con)
  ask_server("ask", state, con)
  formulas_server("formulas", con)
  report_server("report", state)
}


shinyApp(ui, server)
