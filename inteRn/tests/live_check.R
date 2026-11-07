# live_check.R -- one real round trip to the endpoint. Needs the key named in
#   config.R (key_var) to be set. Costs a few cents.
#
# Run interactively in RStudio after sourcing inteRn.R:
#   source("<path>/inteRn/tests/live_check.R")
#
# 1. The model ID is one the endpoint serves.
# 2. ask() answers, and calls describe_object on a toy object by itself.
# 3. %ask% works on palmerpenguins.

core = environment(get("ask", envir = as.environment("inteRn")))
cfg = core$INTERN_LLM

if (identical(cfg$base_url, "https://api.anthropic.com/v1")) {
  ids = ellmer::models_anthropic(credentials = function() core$intern_key())$id
  cat("pm model listed by the endpoint:", cfg$pm %in% ids, "\n")
  if (!cfg$pm %in% ids)
    cat("Closest IDs:", paste(utils::head(grep("sonnet|opus", ids, value = TRUE), 8),
                              collapse = ", "), "\n")
}

demo_toy = data.frame(id = 1:20, grp = factor(rep(c("a", "b"), 10)), y = stats::rnorm(20))
ask("What columns does demo_toy have, and what type is each? Use your tools.", new = TRUE)
palmerpenguins::penguins %ask% "Which columns have missing values I should check, and how would you check them with the tidyverse?"
rm(demo_toy)
