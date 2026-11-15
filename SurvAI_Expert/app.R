# SurvAI_Expert -- answers survey methodology questions from the course store, with sources.
#   Console (no UI yet):  source("app.R"); ask("How do I compute a design effect for a cluster sample?")
#   The store is data/store/survai.duckdb, built by build/03_store.R.


# ---- 1. settings an administrator may change -------------------------------

# The model per profile, called through ellmer only.
#   api        "anthropic" (ellmer::chat_anthropic) or "openai" (ellmer::chat_openai_compatible)
#   base_url   where it is called; id: what the endpoint names the model
#   effort     reasoning effort per kind of call, sent only when set
#   json       how a reply is held to a JSON schema: "output_config" (Anthropic structured
#              output), "response_format" (OpenAI style), or "prompt" (asked for in words only)
#   price      USD per million tokens (input, output, cached input), for the cost lines; NA when unknown
#   work: placeholders in angle brackets, to be filled in at work.
MODEL_PROFILES <- list(
  home = list(api = "anthropic", base_url = "https://api.anthropic.com/v1", id = "claude-sonnet-5-5",
              effort = c(plan = "low", answer = "medium", judge = "medium"), json = "output_config",
              price = c(input = 2, output = 10, cached = 0.10)),
  work = list(api = "<api at work: anthropic or openai>", base_url = "<work base url>", id = "<Opus 5 id at work>",
              effort = c(plan = "low", answer = "medium", judge = "medium"), json = "response_format",
              price = c(input = NA, output = NA, cached = NA)))

# The profile used when the environment variable SURVAI_PROFILE is not set.
MODEL_PROFILE <- local({
  p = tolower(trimws(Sys.getenv("SURVAI_PROFILE")))
  if (nzchar(p)) p else "home"
})

# For console use and tests only: the environment variable the key is read from. The key is
#   passed to each call as credentials and is never written to a file, a log or the console.
KEY_ENV <- "ANTHROPIC_API_KEY"

STORE_PATH <- "data/store/survai.duckdb"
VOCAB_CSV <- "data/catalog/vocabulary.csv"
REFLEX_DIR <- "www/reflexes"

if (!MODEL_PROFILE %in% names(MODEL_PROFILES))
  stop("The profile is '", MODEL_PROFILE, "' (SURVAI_PROFILE); it must be one of: ",
       paste(names(MODEL_PROFILES), collapse = ", "), call. = FALSE)


# ---- 2. packages ------------------------------------------------------------

library(dplyr)
library(purrr)
library(stringr)
library(tibble)
library(DBI)
library(duckdb)

# Called as pkg::fn() in R/ and never attached; a missing one stops here, by name.
APP_PACKAGES <- c("commonmark", "ellmer", "htmltools", "jsonlite", "katex", "tidyr")
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


# ---- 3. the code in R/ ------------------------------------------------------

walk(sort(list.files("R", pattern = "[.]R$", full.names = TRUE)), function(f)
  tryCatch(sys.source(f, envir = globalenv()),
           error = function(e) stop("Failed loading ", f, ": ", conditionMessage(e), call. = FALSE)))

list2env(list(MODEL_PROFILES = MODEL_PROFILES, MODEL_PROFILE = MODEL_PROFILE, KEY_ENV = KEY_ENV,
              STORE_PATH = STORE_PATH, VOCAB_CSV = VOCAB_CSV, REFLEX_DIR = REFLEX_DIR), envir = globalenv())
