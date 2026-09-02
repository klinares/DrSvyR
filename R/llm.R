# llm.R for DrSvyR -- OpenRouter endpoint
# Endpoint, models, and every model call in the workflow.

# THIS IS THE HOME VARIANT. It reaches OpenRouter through ellmer's own client
#   and knows nothing about any other provider. The work variant that reaches
#   an OpenAI-compatible endpoint is llm-openai.R at the repository root;
#   exactly one of the two belongs in R/ at a time, and app.R stops if it
#   finds both.

# ---- configuration -----------------------------------------------------

# Committed to the repository deliberately. The endpoint and the model names
#   are properties of the deployment rather than of the analyst, so a change is
#   a reviewable commit and every analyst picks it up on the next pull, rather
#   than a dozen people editing a dotfile. The analyst's .Renviron holds one
#   line: the key.

WISE_LLM <- list(
  base_url = "https://openrouter.ai/api/v1",
  key_var  = "OPENROUTER_API_KEY",

  pm          = "meta-llama/llama-4-maverick",
  worker      = "meta-llama/llama-3.1-70b-instruct",
  pm_fallback = "openai/gpt-5.4-nano",

  # "server" reads key_var from the environment. "analyst" ignores the
  #   environment entirely and requires a key pasted into the app.
  key_source = "server",
  timeout    = 120,

  # A reply cut off by the token ceiling is not a parse failure the analyst can
  #   do anything about: the JSON simply stops mid-string. The naming and
  #   reading prompts carry response labels and item wording, so the replies
  #   are longer than a default of a few hundred tokens allows.
  max_tokens = 4000)

# ---- zz_llm ------------------------------------------------------------

# Every model call in the workflow goes through this file.

#   1. Client construction
#   2. Call budget
#   3. JSON calls, retry and fallback
#   4. Freeze-file keying

# Endpoint and models come from the block at the top of this file, which is in
#   the repository. The key comes from the environment or from the analyst and
#   is never written anywhere: it is passed as an argument and stays local to
#   the call. Nothing here calls Sys.setenv().

# Requires: ellmer, purrr, jsonlite, digest, dplyr, tibble, readr, fs


# Section 1 builds the client. Two roles: the project manager reads the
#   analysis and writes prose, the worker names one segment.
#______________________________________________________________________________

# getDefaultReactiveDomain() is the current Shiny session inside any reactive,
#   and NULL outside one -- so a script keeps the environment behaviour it has
#   always had and nothing below changes for a desktop run.
llm_session_key <- function() {
  s = shiny::getDefaultReactiveDomain()
  if (is.null(s)) return(NULL)
  k = .llm_state$keys[[s$token]]
  if (is.null(k) || !nzchar(k)) NULL else k
}

llm_set_session_key <- function(key) {
  s = shiny::getDefaultReactiveDomain()
  if (is.null(s)) stop("No session to attach a key to.", call. = FALSE)
  .llm_state$keys[[s$token]] <- key
  invisible(TRUE)
}

llm_clear_session_key <- function(token) {
  .llm_state$keys[[token]] <- NULL
  invisible(TRUE)
}

llm_api_key <- function() {
  # In "analyst" mode the environment is not consulted at all. That is the
  #   point: a key set on a shared server would otherwise be picked up by an
  #   analyst who never supplied one, and spent without anyone noticing.
  from_env = if (identical(WISE_LLM$key_source %||% "server", "server"))
    Sys.getenv(WISE_LLM$key_var) else ""

  key = llm_session_key() %||% from_env
  if (!nzchar(key))
    stop(WISE_LLM$key_var, " is not set. Either paste a key on the Start here ",
         "tab, or run usethis::edit_r_environ(), add\n",
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
  # Built by name rather than passed positionally, and max_tokens only where
  #   the installed ellmer knows the argument. An older version would take it
  #   into ... and ignore it silently, which is the worst of the three
  #   outcomes: the ceiling stays low and nothing says so.
  args = list(temperature = 0, seed = seed)
  if ("max_tokens" %in% names(formals(ellmer::params)))
    args$max_tokens = WISE_LLM$max_tokens %||% 4000L
  else
    warning("This version of ellmer has no max_tokens argument, so the token ",
            "ceiling is the endpoint's default. A long reply may come back ",
            "truncated mid-JSON.", call. = FALSE)
  p = do.call(ellmer::params, args)

  # ellmer's OpenRouter client reads the key from the process environment, so
  #   it cannot carry a per-session one. When an analyst has typed a key, the
  #   compatible client is used instead and the key travels in the closure.
  #   With no typed key this is exactly the path it has always taken.
  if (is.null(llm_session_key()) &&
      identical(WISE_LLM$provider, "openrouter")) {
    # ellmer's own client reads the key from the environment and sets the
    #   headers itself, so there is nothing to get wrong here.
    ellmer::chat_openrouter(model = model, system_prompt = system_prompt,
                            params = p, echo = "none")
  } else {
    # credentials must be a function; api_key is deprecated as of ellmer 0.4.0.
    key = llm_api_key()
    url = WISE_LLM$base_url
    ellmer::chat_openai_compatible(
      base_url = url,
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

# Keys typed into the app, one slot per Shiny session. On a server each analyst
#   supplies their own and it lives here for the length of their session only:
#   never written to disk, never in the decision log, never in state (which is
#   exported), and never through Sys.setenv(), which would leak it to every
#   other session in the process.
.llm_state$keys <- list()

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

# A bare double quote inside a JSON string ends the string, and the parser then
#   sees the rest of the sentence as a syntax error. Models do this constantly
#   when the prompt hands them quoted response labels: "0.79 probability of
#   having "Nada" confidence" is what came back, and yajl stopped at the N.

# Repaired rather than rejected, because the reply is right and only its
#   punctuation is wrong, and because a retry produces the same sentence.

# A quote is a genuine end-of-string only if the next thing that is not
#   whitespace is a comma, a colon, a closing brace or bracket, or the end of
#   the text. Anything else is a quotation mark the model meant as prose, and
#   it is escaped.
JSON_CLOSERS <- c(",", ":", "}", "]", "")

repair_json_quotes <- function(txt) {
  ch = strsplit(txt, "", fixed = TRUE)[[1]]
  if (!length(ch)) return(txt)

  # The next non-whitespace character for every position, worked out once so
  #   the scan below stays a single pass.
  ws = ch %in% c(" ", "\t", "\n", "\r")
  pos = which(!ws)
  nxt = pos[findInterval(seq_along(ch), pos) + 1L]
  nxt_ch = ifelse(is.na(nxt), "", ch[nxt])

  st = purrr::reduce(seq_along(ch), function(s, i) {
    c1 = ch[i]
    if (s$esc) { s$esc = FALSE; return(s) }
    if (identical(c1, "\\")) { s$esc = TRUE; return(s) }
    if (!identical(c1, "\"")) return(s)
    if (!s$ins) { s$ins = TRUE; return(s) }
    if (nxt_ch[i] %in% JSON_CLOSERS) { s$ins = FALSE; return(s) }
    s$stray = c(s$stray, i)
    s
  }, .init = list(ins = FALSE, esc = FALSE, stray = integer(0)))

  if (!length(st$stray)) return(txt)
  ch[st$stray] = "\\\""
  paste(ch, collapse = "")
}

# The other half of the same failure: the model omits the quote that ends the
#   last value and the parser runs off the end. What came back was
#   {"summary": "... with 'Black' as the reference.}  -- a closing brace, and no
#   closing quote before it. Telling a small model to avoid double quotes
#   inside a value makes this more likely, not less, so the rule and the repair
#   have to travel together.

# One scan, used twice: once to find out whether the text ends inside a string
#   and what brackets are still open, and again after the quote is put back.
json_scan <- function(txt) {
  ch = strsplit(txt, "", fixed = TRUE)[[1]]
  purrr::reduce(ch, function(s, c1) {
    if (s$esc) { s$esc = FALSE; return(s) }
    if (s$ins) {
      if (identical(c1, "\\")) s$esc = TRUE
      else if (identical(c1, "\"")) s$ins = FALSE
      return(s)
    }
    if (identical(c1, "\"")) { s$ins = TRUE; return(s) }
    if (c1 %in% c("{", "[")) s$open = c(s$open, c1)
    else if (c1 %in% c("}", "]") && length(s$open))
      s$open = s$open[-length(s$open)]
    s
  }, .init = list(ins = FALSE, esc = FALSE, open = character(0)))
}

repair_json_close <- function(txt) {
  st = json_scan(txt)

  # The quote goes before whatever closing braces the model did write, not
  #   after them. Appended at the end instead, the brace lands inside the value
  #   and the summary ends with a stray character.
  if (isTRUE(st$ins)) {
    at = regexpr("[[:space:]}\\]]*$", txt)
    txt = if (at > 0)
      paste0(substr(txt, 1, at - 1L), "\"", substr(txt, at, nchar(txt)))
    else paste0(txt, "\"")
    st = json_scan(txt)
  }

  if (!length(st$open)) return(txt)
  paste0(txt, paste(rev(ifelse(st$open == "{", "}", "]")), collapse = ""))
}

# Some models wrap valid JSON in prose or fences despite being told not to, so
#   the object is pulled out by pattern rather than parsed from the whole reply.

# Where there is no closing brace at all, everything from the first one is
#   taken and repair_json_close() finishes it. The alternative is "No JSON
#   found" on a reply that is entirely there apart from its last character.
json_candidate <- function(txt, pattern) {
  m = regmatches(txt, regexpr(pattern, txt, perl = TRUE))
  if (length(m)) return(m)
  i = regexpr("\\{", txt)
  if (i < 0) return(character(0))
  substr(txt, i, nchar(txt))
}

# The reply is carried into the error. "Request failed after 3 attempts" with
#   nothing else is a message an analyst can act on only by asking someone to
#   reproduce it.
parse_json_block <- function(txt, pattern = "(?s)\\{.*\\}") {
  m = json_candidate(txt, pattern)
  if (!length(m)) stop("No JSON found in the model reply:\n", txt,
                       call. = FALSE)

  obj = try(jsonlite::fromJSON(m, simplifyVector = FALSE), silent = TRUE)
  if (!inherits(obj, "try-error")) return(obj)

  # Three repairs, in the order that makes each one meaningful. A stray quote
  #   inside a value changes where the scan thinks the strings start and end,
  #   so closing before escaping would close the wrong string; and a reply can
  #   need both.
  done = purrr::compact(purrr::map(
    list(repair_json_quotes(m),
         repair_json_close(m),
         repair_json_close(repair_json_quotes(m))),
    function(fixed) {
      if (identical(fixed, m)) return(NULL)
      r = try(jsonlite::fromJSON(fixed, simplifyVector = FALSE), silent = TRUE)
      if (inherits(r, "try-error")) NULL else r
    }))
  if (length(done)) return(done[[1]])

  stop("The model reply is not valid JSON and could not be repaired.\n",
       conditionMessage(attr(obj, "condition")), "\n--- reply ---\n",
       substr(m, 1, 1200), call. = FALSE)
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

# Appended to every JSON prompt rather than written into each one. The prompts
#   live in engine.R, which is shared by copy with the reference workflow and
#   has no business knowing how this app parses a reply. Repairing a stray
#   quote afterwards works; not producing one is cheaper.
# Worded so it cannot be read as "avoid quotes". The first version said only
#   "no double quotes inside a value" and the model dropped the quote that
#   ends the value as well, which is a worse failure than the one it fixed.
JSON_QUOTE_RULE <- paste(
  "Return exactly one JSON object and nothing before or after it.",
  "Every key and every string value must both open AND close with a double",
  "quote -- including the last value in the object.",
  "Inside a value, use single quotes for any quoted word: 'Nada', not",
  "\"Nada\". Do not put a line break inside a value.")

llm_json <- function(prompt, role = "worker", system_prompt = NULL,
                     validate = NULL, pattern = "(?s)\\{.*\\}", seed = NULL,
                     max_times = 3L, session_cap = 10L) {

  ask = paste0(prompt, "\n\n", JSON_QUOTE_RULE)

  attempt = function(model) {
    if (.llm_state$retries >= session_cap)
      stop("Session retry cap of ", session_cap, " reached. The prompt or the ",
           "endpoint needs attention; further attempts would spend quota ",
           "without diagnosing it.", call. = FALSE)
    .llm_state$calls <- .llm_state$calls + 1L
    parse_json_block(llm_chat(model, system_prompt, seed)$chat(ask,
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

# The data is hashed alongside the specification, and it has to be. A fit is
#   determined by both, and a key made of the specification alone matches
#   across datasets that happen to share variable names and category counts --
#   two waves of the same survey, the same instrument in a second country.
#   Run the second one in a work folder that already holds the first and the
#   cache returns the first wave's model, the app scores the second wave's
#   respondents with it, and the report describes the wrong fit. There is no
#   symptom: the numbers are plausible, the diagnostics are clean, and nothing
#   in the output says which file the parameters came from. Labels are keyed
#   the same way and would carry over with it.

# unclass() on each column because the hash has to depend on the values and
#   not on a label attribute or a tibble class that a different reader might
#   have attached; without it the key churns and the cache never hits.
# dimension = 0 keys the search rather than one fitted model: everything the
#   whole start set depends on, with the number of groups left out. That is
#   what lets the fit step ask "is the search in front of me still the search
#   for this battery and this file" and get a yes or a no.
model_key <- function(cfg, items, dimension, data) {
  digest::digest(list(
    items = sort(items),
    dimension = dimension,
    cats = cfg$cats[sort(items)],
    min_items = cfg$min_items,
    seed = cfg$seed,
    n_starts = cfg$n_starts,
    n_short = cfg$n_short,
    n_keep = cfg$n_keep,
    data = digest::digest(lapply(data, unclass))))
}

