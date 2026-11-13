# Checks the language-model connection with real calls: run from inside
#   svysegment/ after setting the key, e.g.
#     Sys.setenv(ANTHROPIC_API_KEY = "...")   # or put it in .Renviron
#     source("tests/llm_check.R")
# Three calls in all: a model list, one segment name, one written reading.
# Only illustrative figures are sent, never survey data.

app = shiny::shinyAppDir("."); invisible(app$serverFuncSource())
cat("Endpoint:", WISE_LLM$base_url, "\nModels:  ", WISE_LLM$worker, "(names),",
    WISE_LLM$pm, "(writing)\n")
stopifnot("No key set: see the top of this file" = nzchar(Sys.getenv(WISE_LLM$key_var)))

# 1. Is the model ID one the endpoint serves?
ids = tryCatch(ellmer::models_anthropic(base_url = WISE_LLM$base_url)$id,
               error = function(e) { cat("Model list unavailable:", conditionMessage(e), "\n"); NULL })
if (!is.null(ids))
  cat("Model IDs served include ours:", all(c(WISE_LLM$worker, WISE_LLM$pm) %in% ids),
      "\n  e.g.", paste(head(grep("opus", ids, value = TRUE), 5), collapse = ", "), "\n")

# 2. A segment name, exactly as the Names screen asks for one.
t1 = system.time(nm <- tryCatch(
  llm_write(help_example_prompt(), c("label", "description"), role = "worker"),
  error = function(e) paste("FAILED:", conditionMessage(e))))
cat("\n--- segment name (", round(t1[["elapsed"]], 1), "s) ---\n")
if (is.list(nm)) cat("label:      ", nm$label, "\ndescription:", nm$description, "\n") else cat(nm, "\n")

# 3. A written reading, with the AI reflexes and the number check.
evidence = paste(
  "SEGMENT SHARES OF THE POPULATION, WITH 95% INTERVALS",
  "| segment | share | lo | hi |",
  "| Engaged | 0.312 | 0.281 | 0.345 |",
  "| Detached | 0.688 | 0.655 | 0.719 |",
  "",
  "TASK",
  "Write one or two sentences for a policy reader on how large each segment is.",
  'Return only valid JSON: {"summary": "..."}', sep = "\n")
t2 = system.time(rd <- tryCatch(llm_write(evidence, "summary"),
                                error = function(e) paste("FAILED:", conditionMessage(e))))
cat("\n--- written reading (", round(t2[["elapsed"]], 1), "s; reflexes + number check) ---\n")
cat(if (is.list(rd)) rd$summary else rd, "\n")
