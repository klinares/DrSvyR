# llm.R for DrSvyR
# Endpoint, models, and every model call in the workflow.

# Merged from: 
#   zz_llm_config.R
#   zz_llm.R

# ---- zz_llm_config -----------------------------------------------------

# llm_config.R for WISE repo
# Endpoint, key variable and models. Committed to the repository deliberately.

# The analyst's .Renviron holds one line and nothing else. Everything below is
#   a property of the deployment rather than of the analyst, so it lives in
#   version control where a change is reviewable and every analyst picks it up
#   on the next pull. Moving to a different endpoint is a commit, not a dozen
#   people editing a dotfile.

WISE_LLM <- list(

  # "openrouter" uses ellmer's own OpenRouter client, which handles auth from
  #   the environment. "compatible" uses chat_openai_compatible() against
  #   base_url with an explicit credentials function. Both go through
  #   llm_chat(), so nothing downstream knows which is in use.
  provider = "openrouter",

  base_url = "https://openrouter.ai/api/v1",

  # The one variable an analyst sets in .Renviron. Named for the provider
  #   because it changes together with the endpoint rather than with the
  #   analyst.
  key_var = "OPENROUTER_API_KEY",

  # The project manager reads the workflow and writes prose: the design brief,
  #   the search narration, the diagnostics, the report sections.
  pm = "meta-llama/llama-4-maverick",

  # The worker does one bounded job many times over: one label per segment or
  #   factor. Split from the project manager to keep the call quota available
  #   for the work that needs the larger model.
  worker = "meta-llama/llama-3.1-70b-instruct",

  # Tried once when the project manager fails after its retries. A different
  #   provider is the point: a fallback on the same endpoint does not survive
  #   the failure mode it exists for. It is also a much smaller model, so a
  #   run that used it says so in the report rather than passing thinner prose
  #   off as the primary model's considered view.
  pm_fallback = "openai/gpt-5.4-nano",

  # Seconds. Long enough for a report section, short enough that an analyst
  #   watching a spinner learns something has gone wrong.
  timeout = 120
)

# ---- zz_llm ------------------------------------------------------------

# llm.R for WISE repo
# Every model call in the workflow goes through this file.

#   1. Client construction
#   2. Call budget
#   3. JSON calls, retry and fallback
#   4. Freeze-file keying

# Endpoint and models come from R/llm_config.R, which is in the repository.
#   The key comes from the environment and is never written anywhere: it is
#   passed as an argument and stays local to the call. Nothing here calls
#   Sys.setenv().

# Requires: ellmer, purrr, jsonlite, digest, dplyr, tibble, readr, fs


# Section 1 builds the client. Two roles: the project manager reads the
#   analysis and writes prose, the worker labels one segment or factor.
#______________________________________________________________________________

llm_api_key <- function() {
  key = Sys.getenv(WISE_LLM$key_var)
  if (!nzchar(key))
    stop(WISE_LLM$key_var, " is not set. Run usethis::edit_r_environ(), add\n",
         "  ", WISE_LLM$key_var, "=your-key\n",
         "save, and restart R.", call. = FALSE)
  key
}

llm_model <- function(role) {
  m = WISE_LLM[[role]]
  if (is.null(m)) stop("No model configured for role '", role, "'.", call. = FALSE)
  m
}

# A fresh chat object per call is deliberate, not wasteful. ellmer chat objects
#   accumulate turns, and the per-segment naming design depends on each segment
#   being read in isolation; a shared client would carry segment k-1 into
#   segment k and reintroduce the confusion that reading them separately
#   avoids. Construction is cheap.

# temperature 0 throughout. seed is passed where the provider honours it and
#   ignored where it does not, so it is a convenience rather than the
#   reproducibility mechanism; the freeze file is that.

llm_chat <- function(model, system_prompt = NULL, seed = NULL) {
  p = ellmer::params(temperature = 0, seed = seed)

  if (identical(WISE_LLM$provider, "openrouter")) {
    # ellmer's own client reads the key from the environment and sets the
    #   headers itself, so there is nothing to get wrong here.
    ellmer::chat_openrouter(model = model, system_prompt = system_prompt,
                            params = p, echo = "none")
  } else {
    # credentials must be a function; api_key is deprecated as of ellmer 0.4.0.
    key = llm_api_key()
    ellmer::chat_openai_compatible(
      base_url = WISE_LLM$base_url,
      model = model,
      credentials = function() list(Authorization = paste("Bearer", key)),
      system_prompt = system_prompt,
      params = p,
      echo = "none")
  }
}


# Section 2 counts calls. The quota is per rolling window and shared with
#   whatever else the analyst is doing, so the count is shown in the app rather
#   than discovered when a call fails.
#______________________________________________________________________________

# An environment rather than an option, so a stray options() call cannot reset
#   it and the count survives being read from a background process.

.llm_state <- new.env(parent = emptyenv())
.llm_state$calls <- 0L
.llm_state$retries <- 0L
.llm_state$fallbacks <- 0L

llm_calls_used <- function() {
  list(calls = .llm_state$calls,
       retries = .llm_state$retries,
       fallbacks = .llm_state$fallbacks)
}

llm_reset_count <- function() {
  .llm_state$calls <- 0L
  .llm_state$retries <- 0L
  .llm_state$fallbacks <- 0L
  invisible(NULL)
}


# Section 3 is the call itself.
#______________________________________________________________________________

# Some models wrap valid JSON in prose or fences despite being told not to, so
#   the object is pulled out by pattern rather than parsed from the whole reply.
parse_json_block <- function(txt, pattern = "(?s)\\{.*\\}") {
  m = regmatches(txt, regexpr(pattern, txt, perl = TRUE))
  if (length(m) == 0) stop("No JSON found in the model reply:\n", txt,
                           call. = FALSE)
  jsonlite::fromJSON(m, simplifyVector = FALSE)
}

# The distinction that matters is whether a second attempt could plausibly
#   succeed. A timeout, a 5xx, a rate limit, or a reply the model wrapped in
#   prose are all worth another try. A reply that parsed but carried the wrong
#   fields is a prompt problem: the same prompt produces the same rejection,
#   and retrying it spends quota to learn nothing. So the retry wraps the
#   request and the parse, and validation sits outside it.

# session_cap stops a systematically broken prompt from draining the window one
#   retry at a time. It is deliberately low: hitting it means something needs
#   fixing, not waiting.

llm_json <- function(prompt, role = "worker", system_prompt = NULL,
                     validate = NULL, pattern = "(?s)\\{.*\\}", seed = NULL,
                     max_times = 3L, session_cap = 10L) {

  attempt = function(model) {
    if (.llm_state$retries >= session_cap)
      stop("Session retry cap of ", session_cap, " reached. The prompt or the ",
           "endpoint needs attention; further attempts would spend quota ",
           "without diagnosing it.", call. = FALSE)
    .llm_state$calls <- .llm_state$calls + 1L
    parse_json_block(llm_chat(model, system_prompt, seed)$chat(prompt,
                                                               echo = FALSE),
                     pattern)
  }

  # quiet = FALSE deliberately. A retry wrapper that hides why it retried is
  #   worse than no wrapper: the analyst sees "failed after 3 attempts" and has
  #   nothing to act on, and so does whoever they call.
  before = .llm_state$calls
  obj = try(
    purrr::insistently(function() attempt(llm_model(role)),
                       rate = purrr::rate_backoff(pause_base = 2,
                                                  max_times = max_times),
                       quiet = FALSE)(),
    silent = TRUE)
  .llm_state$retries <- .llm_state$retries +
    max(0L, .llm_state$calls - before - 1L)

  # One fallback attempt, and only for the project manager. The worker's job is
  #   small and repeated; if it is failing, a different model is unlikely to be
  #   the reason and the analyst should see the error.
  if (inherits(obj, "try-error") && identical(role, "pm")) {
    message("Project manager model failed; trying ", llm_model("pm_fallback"), ".")
    .llm_state$fallbacks <- .llm_state$fallbacks + 1L
    obj = attempt(llm_model("pm_fallback"))
  }

  if (inherits(obj, "try-error"))
    stop(conditionMessage(attr(obj, "condition")), call. = FALSE)

  if (!is.null(validate)) validate(obj)
  obj
}

# Validators are plain functions that stop with a readable message. Keeping
#   them out of the prompt means the app can say which field the model omitted
#   rather than showing a parse error.

validate_fields <- function(need) {
  function(obj) {
    missing = setdiff(need, names(obj))
    if (length(missing))
      stop("Model reply is missing: ", paste(missing, collapse = ", "),
           call. = FALSE)
    invisible(TRUE)
  }
}


# Section 4 keys the freeze file to the model it was drafted for.
#______________________________________________________________________________

# A row-count check catches a change in K and nothing else. Dropping an item
#   and refitting at the same K produces different segments in a different
#   order, the row count still matches, and the previous run's names attach
#   silently to segments that are no longer the ones they described. That is a
#   presentation error with no symptom, which is the worst kind.

# The key covers the specification rather than the fitted parameters. Starting
#   values come from a deterministic seed sequence, so the same specification
#   returns the same fit in the same order; hashing the parameters instead
#   would make the key sensitive to floating-point noise and force a redraft
#   after a no-op re-run.

model_key <- function(cfg, items, dimension) {
  digest::digest(list(
    items = sort(items),
    dimension = dimension,
    cats = cfg$cats[sort(items)],
    min_items = cfg$min_items,
    estimator = cfg$estimator,
    seed = cfg$seed,
    n_starts = cfg$n_starts))
}

