# Live model check for chaRt, at home only. Makes real calls and costs a little.
# Run from inside chaRt/:   Rscript --no-init-file tests/llm_check.R
# The keys come from the environment (.Renviron): ANTHROPIC_API_KEY for checks 1 and 2,
#   OPENROUTER_API_KEY for check 3. A test script may read them; the app never does. On Windows,
#   run it from PowerShell or RStudio: Git Bash sets HOME, which moves R's "~" away from the
#   Documents folder that holds .Renviron.
# Five checks, each printing what it sent and what came back:
#   1. ping the home model through llm_ping();
#   2. structured output through the chat object llm_chat() builds for the home model (Anthropic);
#   3. the same request in the OpenAI style, through ellmer::chat_openai_compatible() against
#      OpenRouter, standing in for the work endpoint;
#   7. Phase 5: headlines and summaries for ten hand-written charts on three files (LIVE_SUMMARY),
#      through summarize_inputs(): two calls and any repairs; saved to tests/live_replies.rds and
#      shown on tests/live_gallery.html under "Phase 5" (tests/live_gallery.R);
#   8. Phase 6: tests/data/orders.csv read with -99 and N/A as missing, label_columns(), one row is "one
#      order", then twelve turns through chat_turn() (LIVE_TURNS, selecting as the plan says) and a headline
#      and summary for every chart on the canvas. Calls are counted and the run stops at 20 (LIVE_MAX_CALLS).
#      Saved as `phase6` beside the rest and shown on the page under "Phase 6".
#   (Steps 4 to 6, the Phase 3 and 4 runs of the suggest and refine calls, went with those calls; the numbers
#   of the others are kept.)
# CHART_LIVE_STEPS chooses which run, for example "1,8"; 1 to 3 by default (steps 7 and 8 cost more, so they
#   are asked for).
# Structured output is ellmer's Chat$chat_structured(..., type, echo, convert), with the type built
#   from type_object(), type_enum(values), type_string() and type_boolean(); checked in ellmer 0.4.2.
#   If it fails, nothing works around it: the design falls back to llm_json().

stopifnot("Run from inside chaRt/" = file.exists("app.R") && dir.exists("R"))
invisible(shiny::shinyAppDir("."))

ANTHROPIC_KEY <- Sys.getenv("ANTHROPIC_API_KEY")
OPENROUTER_KEY <- Sys.getenv("OPENROUTER_API_KEY")

# A small, cheap model on OpenRouter (the one QuestionR's live runs used); OPENROUTER_MODEL
#   overrides it.
OPENROUTER_MODEL <- Sys.getenv("OPENROUTER_MODEL", "openai/gpt-6-luna")

# CHART_TEST_MODEL replaces the home model's id for checks 1 and 2 (for example claude-sonnet-4-5).
#   The default is the home profile's model, the one the app will call. Live tests use Sonnet
#   models only: an Opus id stops the script before any call.
CHART_TEST_MODEL <- Sys.getenv("CHART_TEST_MODEL")
if (grepl("opus", CHART_TEST_MODEL, ignore.case = TRUE) || grepl("opus", APP_PROFILES$home$id, ignore.case = TRUE))
  stop("Live tests call Sonnet models only; '", if (nzchar(CHART_TEST_MODEL)) CHART_TEST_MODEL else APP_PROFILES$home$id,
       "' is an Opus model.", call. = FALSE)
OPENROUTER <- list(api = "openai", base_url = "https://openrouter.ai/api/v1", id = OPENROUTER_MODEL)

LIVE_STEPS <- trimws(strsplit(Sys.getenv("CHART_LIVE_STEPS", "1,2,3"), ",", fixed = TRUE)[[1]])
step_on <- function(n) as.character(n) %in% LIVE_STEPS

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
    chat = llm_chat(m, SPEC_SYSTEM, LLM_MAX_TOKENS[["chat"]], key)
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

home <- APP_PROFILES$home
if (nzchar(CHART_TEST_MODEL)) home$id <- CHART_TEST_MODEL
if (step_on(1)) {
heading(1, "Ping the home model through llm_ping()")
say("Model:  ", home$id, " at ", home$base_url)
say("Sent:   ", LLM_PING_PROMPT)
if (!nzchar(ANTHROPIC_KEY)) {
  say("Result: no call was made; ANTHROPIC_API_KEY is not set.")
} else {
  p = llm_ping(home, key = ANTHROPIC_KEY)
  say("Back:   ", p$message, " (", sprintf("%.1f", p$seconds), " s)")
  say("Result: ", if (isTRUE(p$ok)) "the home model answered." else "the ping FAILED.")
}
}


# ---- 2. structured output, Anthropic style -----------------------------------------------

if (step_on(2)) {
  heading(2, "Structured output, Anthropic style")
  structured_check(home, ANTHROPIC_KEY, "llm_chat() -> ellmer::chat_anthropic(), then $chat_structured()")
}


# ---- 3. structured output, OpenAI style --------------------------------------------------

if (step_on(3)) {
  heading(3, "Structured output, OpenAI style (OpenRouter)")
  structured_check(OPENROUTER, OPENROUTER_KEY, "llm_chat() -> ellmer::chat_openai_compatible(), then $chat_structured()")
}


# ---- 7. Phase 5: headlines and summaries ------------------------------------------------------------

if (step_on(7)) {
  heading(7, "Phase 5: summarize_inputs() on ten charts")
  if (!exists("live_summary")) source(file.path("tests", "live_gallery.R"))
  say("Model:  ", home$id, " at ", home$base_url)
  if (!nzchar(ANTHROPIC_KEY)) {
    say("Result: no call was made; ANTHROPIC_API_KEY is not set.")
  } else {
    started <- Sys.time()
    live_summary(home, ANTHROPIC_KEY, say)
    say("  wall time ", sprintf("%.0f", as.numeric(difftime(Sys.time(), started, units = "secs"))), " s")
    live_page()
  }
}


# ---- 8. Phase 6: the chat, twelve turns on orders.csv ------------------------------------------------

if (step_on(8)) {
  heading(8, "Phase 6: chat_turn() on tests/data/orders.csv, twelve turns, then headlines and summaries")
  if (!exists("live_chat")) source(file.path("tests", "live_gallery.R"))
  say("Model:  ", home$id, " at ", home$base_url)
  if (!nzchar(ANTHROPIC_KEY)) {
    say("Result: no call was made; ANTHROPIC_API_KEY is not set.")
  } else {
    live_chat(home, ANTHROPIC_KEY, say)
    live_page()
  }
}

cat("\n")
