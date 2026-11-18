# Live model check for chaRt, at home only. Makes real calls and costs a little.
# Run from inside chaRt/:   Rscript --no-init-file tests/llm_check.R
# The keys come from the environment (.Renviron): ANTHROPIC_API_KEY for checks 1 and 2,
#   OPENROUTER_API_KEY for check 3. A test script may read them; the app never does.
# Three checks, each printing what it sent and what came back:
#   1. ping the home model through llm_ping();
#   2. structured output through the chat object llm_chat() builds for the home model (Anthropic);
#   3. the same request in the OpenAI style, through ellmer::chat_openai_compatible() against
#      OpenRouter, standing in for the work endpoint.
# Structured output is ellmer's Chat$chat_structured(..., type, echo, convert), with the type built
#   from type_object(), type_enum(values), type_string() and type_boolean(); checked in ellmer 0.4.2.
#   If it fails, nothing works around it: the design falls back to llm_json().

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
invisible(shiny::shinyAppDir("."))

ANTHROPIC_KEY <- Sys.getenv("ANTHROPIC_API_KEY")
OPENROUTER_KEY <- Sys.getenv("OPENROUTER_API_KEY")

# A small, cheap model on OpenRouter; OPENROUTER_MODEL overrides it.
OPENROUTER_MODEL <- Sys.getenv("OPENROUTER_MODEL", "openai/gpt-4o-mini")
OPENROUTER <- list(api = "openai", base_url = "https://openrouter.ai/api/v1", id = OPENROUTER_MODEL)

FAMILIES <- c("bar", "dot", "line", "slope", "scatter", "bubble", "histogram", "box", "heatmap")

SPEC_TYPE <- ellmer::type_object(
  "The form of one chart.",
  family = ellmer::type_enum(values = FAMILIES, description = "The chart family."),
  x = ellmer::type_string("The column on the x axis."),
  log_x = ellmer::type_boolean("Whether the x axis needs a log scale."))

SPEC_SYSTEM <- "You choose chart forms for a data analyst. Answer only with the requested fields."
SPEC_ASK <- paste("A file has one row per order, with the columns region (a category with 5 levels)",
                  "and revenue (a number in dollars, from 12 to 98,000). Choose a chart that compares",
                  "total revenue across the regions. Give its family, the column on its x axis, and",
                  "whether that axis needs a log scale.")

scrub <- function(txt) purrr::reduce(c(ANTHROPIC_KEY, OPENROUTER_KEY), function(t, k) if (nzchar(k)) gsub(k, "[key]", t, fixed = TRUE) else t,
                                     .init = as.character(txt))
say <- function(...) cat(scrub(paste0(...)), "\n", sep = "")
heading <- function(n, what) cat("\n==== ", n, ". ", what, " ", strrep("=", max(3, 60 - nchar(what))), "\n", sep = "")

# Whether a reply is the object asked for: exactly the three fields, of the right kinds.
matches_schema <- function(x)
  is.list(x) && setequal(names(x), c("family", "x", "log_x")) &&
    is.character(x$family) && length(x$family) == 1L && x$family %in% FAMILIES &&
    is.character(x$x) && length(x$x) == 1L && nzchar(x$x) &&
    is.logical(x$log_x) && length(x$log_x) == 1L && !is.na(x$log_x)

structured_check <- function(m, key, route) {
  say("Route:  ", route)
  say("Model:  ", m$id, " at ", m$base_url)
  say("System: ", SPEC_SYSTEM)
  say("Sent:   ", SPEC_ASK)
  say("Type:   family = enum(", paste(FAMILIES, collapse = ", "), "), x = string, log_x = boolean")
  if (!nzchar(key)) return(say("Result: no call was made; the key for this route is not set."))
  started = Sys.time()
  out = tryCatch({
    chat = llm_chat(m, SPEC_SYSTEM, LLM_MAX_TOKENS[["suggest"]], key)
    chat$chat_structured(SPEC_ASK, type = SPEC_TYPE, echo = "none")
  }, error = function(e) e)
  secs = as.numeric(difftime(Sys.time(), started, units = "secs"))
  if (inherits(out, "error"))
    return(say("Result: structured output FAILED after ", sprintf("%.1f", secs), " s: ",
               substr(conditionMessage(llm_root_cause(out)), 1, 600)))
  say("Back:   ", jsonlite::toJSON(out, auto_unbox = TRUE))
  say("Result: structured output works (", sprintf("%.1f", secs), " s); the reply ",
      if (matches_schema(out)) "matches the schema." else "does NOT match the schema.")
}


# ---- 1. ping ---------------------------------------------------------------------------

heading(1, "Ping the home model through llm_ping()")
home <- APP_PROFILES$home
say("Model:  ", home$id, " at ", home$base_url)
say("Sent:   ", LLM_PING_PROMPT)
if (!nzchar(ANTHROPIC_KEY)) {
  say("Result: no call was made; ANTHROPIC_API_KEY is not set.")
} else {
  p = llm_ping(home, key = ANTHROPIC_KEY)
  say("Back:   ", p$message, " (", sprintf("%.1f", p$seconds), " s)")
  say("Result: ", if (isTRUE(p$ok)) "the home model answered." else "the ping FAILED.")
}


# ---- 2. structured output, Anthropic style -----------------------------------------------

heading(2, "Structured output, Anthropic style")
structured_check(home, ANTHROPIC_KEY, "llm_chat() -> ellmer::chat_anthropic(), then $chat_structured()")


# ---- 3. structured output, OpenAI style --------------------------------------------------

heading(3, "Structured output, OpenAI style (OpenRouter)")
structured_check(OPENROUTER, OPENROUTER_KEY, "llm_chat() -> ellmer::chat_openai_compatible(), then $chat_structured()")

cat("\n")
