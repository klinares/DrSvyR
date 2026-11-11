# openrouter_check.R -- THROWAWAY. Delete once QuestionR's own tests/llm_check.R
#   exists. Checks, at home, that the three worker models answer through
#   OpenRouter with the key in .Renviron (OPENROUTER_API_KEY). The project
#   manager model is not tested here: its key is pasted into the app.
#
# Run from PowerShell (from Git Bash the key looks unset):
#   & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" tests/openrouter_check.R
# or source() it in RStudio. Cost: three short calls, a fraction of a cent.
#
# Needs: ellmer, httr2, purrr, tibble, jsonlite.

# The three worker models, as OpenRouter names them (Kevin, 2026-11-11).
MODELS <- c(
  gemma = "google/gemma-4-31b-it",
  llama = "meta-llama/llama-4-maverick",
  gpt   = "openai/gpt-6-luna-decisions")

# What to look for when an ID above is not served.
FAMILIES <- c(gemma = "gemma-4", llama = "llama-4", gpt = "gpt-6")

stopifnot("OPENROUTER_API_KEY is not set: add it to .Renviron and restart R" =
            nzchar(Sys.getenv("OPENROUTER_API_KEY")))


# ---- 1. are the IDs ones OpenRouter serves? ---------------------------------

# The model list is public; no key is sent.
served <- httr2::request("https://openrouter.ai/api/v1/models") |>
  httr2::req_perform() |>
  httr2::resp_body_json() |>
  purrr::pluck("data") |>
  purrr::map_chr("id")

purrr::iwalk(MODELS, function(id, role) {
  if (id %in% served) return(cat("served:     ", id, "\n"))
  near = grep(FAMILIES[[role]], served, value = TRUE, fixed = TRUE)
  cat("NOT served: ", id, "\n  candidates: ",
      if (length(near)) paste(near, collapse = ", ") else "none found", "\n")
})

ready <- purrr::keep(MODELS, function(id) id %in% served)


# ---- 2. one small call each, in the shape QuestionR will use ----------------

SYSTEM <- "You are a survey methodologist. Return exactly one JSON object and nothing else."
ASK <- paste(
  "Write one survey question measuring how often adults read a newspaper,",
  "for a self-administered web survey.",
  'Return only JSON: {"stem": "...", "options": ["...", "..."]}')

# TRUE when the reply holds a JSON object with both fields, fenced or not.
json_ok <- function(txt) {
  m = regmatches(txt, regexpr("(?s)\\{.*\\}", txt, perl = TRUE))
  if (!length(m)) return(FALSE)
  obj = tryCatch(jsonlite::fromJSON(m, simplifyVector = FALSE),
                 error = function(e) NULL)
  !is.null(obj) && all(c("stem", "options") %in% names(obj))
}

ask_one <- function(id) {
  started = Sys.time()
  reply = tryCatch({
    # chat_openrouter() reads OPENROUTER_API_KEY from the environment.
    chat = ellmer::chat_openrouter(system_prompt = SYSTEM, model = id,
                                   echo = "none")
    as.character(chat$chat(ASK, echo = "none"))
  }, error = function(e) paste("FAILED:", conditionMessage(e)))
  tibble::tibble(
    model = id,
    seconds = round(as.numeric(difftime(Sys.time(), started, units = "secs")), 1),
    json_ok = json_ok(reply),
    reply = substr(gsub("\\s+", " ", reply), 1, 300))
}

results <- purrr::map(ready, ask_one) |> purrr::list_rbind()

cat("\n")
print(results, width = 200)
cat("\nAll three answered with usable JSON:",
    nrow(results) == length(MODELS) && all(results$json_ok), "\n")
