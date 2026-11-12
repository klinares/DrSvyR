# llm.R for QuestionR
# The model layer: where a model's key comes from, the one call function for
#   both API styles, JSON parse and repair, retry with a session cap, the
#   connection check's call, and the key box. Nothing here is a prompt: R/skills.R
#   writes those. Function definitions and constants only (root CLAUDE.md rule 2).

# Which models there are, and where each one's key comes from, is APP_MODELS in
#   app.R (assigned to the global environment, so this file can read it).
#   "anthropic" calls ellmer::chat_anthropic(); "openai" calls
#   ellmer::chat_openai_compatible(), which takes the base URL of any
#   OpenAI-style endpoint (OpenRouter at home, the work server at work).
#   Resolved in the installed ellmer 0.4.2 and recorded in STATUS.md.


# ---- settings of the call ------------------------------------------------------

# max_tokens for each step (DESIGN.md sections 6 and 12). A reply that reaches
#   the ceiling is a failure, not a short answer, and is not retried: the same
#   prompt is cut off at the same place. ping is the connection check's very
#   small call. Brief, draft and appraisal are Kevin's Phase 3 settings,
#   provisional until a live run has recorded how much each step really uses;
#   evaluate is about twice what one live review of a 15-question, 1,823-character
#   questionnaire used (21,272 tokens out in 155 seconds; tests/review_tokens.md).
LLM_MAX_TOKENS <- c(brief = 4000L, draft = 12000L, appraisal = 24000L,
                    evaluate = 43000L, ping = 200L)

# What a cut-off reply tells the analyst to do, by step (DESIGN.md section 13).
#   llm_json() says only that the reply was cut off; the flow adds this, because
#   only the flow knows which step it was.
LLM_CUTOFF_ADVICE <- c(
  brief = "Try the brief check again, or skip it.",
  draft = "Ask for fewer items and run again.",
  appraisal = "Untick a worker or ask for fewer items, and run again.",
  evaluate = "Paste fewer questions and run again.")

# Seconds before one request gives up. ellmer reads this from the option
#   ellmer_timeout_s (its own default is five minutes); svysegment sets it the
#   same way. The connection check waits less.
LLM_TIMEOUT_S <- 600
LLM_PING_TIMEOUT_S <- 60

# Anthropic prompt caching. Each step has a different system prompt, so there is
#   little to reuse within five minutes and a cache write costs more than a plain
#   read; "none" also works behind a proxy that rejects cache instructions.
LLM_CACHE <- "none"

# What the connection check says to a model. No analyst text goes in it.
LLM_PING_PROMPT <- "Reply with the single word OK."


# ---- per-process state ---------------------------------------------------------

# An environment rather than an option, so a stray options() call cannot reset
#   it. keys: one slot per Shiny session, keyed by the session token. retries:
#   how many repeat attempts each session has used, for the session cap. calls:
#   every request this process has made.
.llm_state <- new.env(parent = emptyenv())
.llm_state$keys <- list()
.llm_state$retries <- list()
.llm_state$calls <- 0L


# ---- the session key -------------------------------------------------------------

# A key is pasted by the analyst into the box on Start here and held for the
#   length of that analyst's session, in the registry above and nowhere else:
#   never written to disk, never in the run log, never in state (which is
#   exported), and never through Sys.setenv(), which would leak it to every
#   other session in the process.

# getDefaultReactiveDomain() is the current Shiny session inside any reactive,
#   and NULL outside one.
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

# The session a call belongs to, for the retry cap. Outside Shiny, "script".
llm_session_id <- function() {
  s = shiny::getDefaultReactiveDomain()
  if (is.null(s)) "script" else s$token
}

llm_retries_used <- function() .llm_state$retries[[llm_session_id()]] %||% 0L

llm_add_retries <- function(n) {
  id = llm_session_id()
  .llm_state$retries[[id]] <- (.llm_state$retries[[id]] %||% 0L) + as.integer(n)
  invisible(NULL)
}

llm_clear_counters <- function(token) {
  .llm_state$retries[[token]] <- NULL
  invisible(TRUE)
}


# ---- where a model's key comes from ----------------------------------------------

# The one place the environment is read, and only for a model whose key_source
#   is "server": the variable named in its key_var. A model whose key_source is
#   "analyst" gets the key pasted into the key box and nothing else; the
#   environment is not consulted for it, so an ANTHROPIC_API_KEY that happens to
#   be set at home is ignored. NULL when there is no key.
llm_key_for <- function(m) {
  switch(m$key_source %||% "",
    analyst = llm_session_key(),
    server = {
      if (is.null(m$key_var) || !nzchar(m$key_var))
        llm_fail(paste0("The model ", m$id, " has key_source 'server' and no key_var."),
                 class = "llm_client_error")
      k = Sys.getenv(m$key_var)
      if (nzchar(k)) k else NULL
    },
    llm_fail(paste0("The model ", m$id, " has key_source '", m$key_source,
                    "'; it must be 'analyst' or 'server'."),
             class = "llm_client_error"))
}

llm_key_ready <- function(m) !is.null(llm_key_for(m))

# What the analyst or the administrator has to do to give a model a key.
llm_key_hint <- function(m) {
  if (identical(m$key_source, "server"))
    paste0("Set the server variable ", m$key_var, ".")
  else
    "Paste a key into the key box on Start here."
}

# The models in force, project manager first, each with a role for display.
llm_models <- function()
  c(list(list(role = "Project manager", m = APP_MODELS$pm)),
    purrr::imap(APP_MODELS$workers, function(m, i)
      list(role = paste("Worker", i), m = m)))

llm_host <- function(m) sub("^[a-z]+://([^/]+).*$", "\\1", m$base_url)


# ---- errors ------------------------------------------------------------------------

# Every error this file raises is an "llm_error" and carries the model's raw
#   reply when there was one, so a failed call can still be read. A client error
#   (the endpoint refused the request in a way a second attempt will not change)
#   is also an "llm_client_error", and is not retried.
llm_fail <- function(msg, class = NULL, raw = NULL)
  rlang::abort(msg, class = c(class, "llm_error"), raw = raw, call = NULL)

# purrr and rlang wrap an error raised inside map() in one that names the index,
#   and keep the original as $parent. The innermost error is the cause.
llm_root_cause <- function(e)
  if (inherits(e$parent, "condition")) llm_root_cause(e$parent) else e


# ---- the call -----------------------------------------------------------------------

# The ellmer chat object for one model: no request is made here. The key travels
#   in a closure (credentials is a function), never through the environment. No
#   temperature is sent unless the model's entry sets one: repeatability comes
#   from the fixed prompt and the run log, and recent Claude models refuse the
#   setting. A model entry may set reasoning_effort ("low", "medium", "high"),
#   which goes through ellmer::params(). Checked in ellmer 0.4.2 against a server
#   on this machine: chat_anthropic() turns it into adaptive thinking with that
#   effort, but chat_openai_compatible() does not send it at all. No entry sets it,
#   so a model is measured as it comes.
llm_chat <- function(m, system_prompt, max_tokens, key) {
  if (is.null(key) || !nzchar(key))
    llm_fail(paste0("There is no key for ", m$id, ". ", llm_key_hint(m)),
             class = "llm_client_error")
  params = ellmer::params(temperature = m$temperature, max_tokens = max_tokens,
                          reasoning_effort = m$reasoning_effort)
  switch(m$api %||% "",
    anthropic = ellmer::chat_anthropic(
      system_prompt = system_prompt, params = params, model = m$id,
      cache = LLM_CACHE, base_url = m$base_url,
      credentials = function() key, echo = "none"),
    openai = ellmer::chat_openai_compatible(
      base_url = m$base_url, name = llm_host(m), system_prompt = system_prompt,
      credentials = function() key, model = m$id, params = params,
      echo = "none"),
    llm_fail(paste0("The model ", m$id, " has api '", m$api,
                    "'; it must be 'anthropic' or 'openai'."),
             class = "llm_client_error"))
}

# One request, one fresh chat object: no history carries from one request to the
#   next. The reply is plain text; llm_json() finds and repairs the JSON in it.
#   The reply carries attributes: provider (the host), finish (why the model
#   stopped, as ellmer standardises it: "success", "max_tokens", ...), tokens
#   (input, output, cached input) and seconds.
llm_complete <- function(m, system_prompt, user, max_tokens,
                         key = llm_key_for(m), timeout = LLM_TIMEOUT_S) {
  old = options(ellmer_timeout_s = timeout)
  on.exit(options(old), add = TRUE)
  chat = llm_chat(m, system_prompt, max_tokens, key)
  started = Sys.time()

  reply = tryCatch(chat$chat(user, echo = "none"), error = function(e) {
    # The endpoint's own explanation is in the response body ("model not
    #   found", "credit balance too low"); httr2's message alone is just the
    #   status. A client error (4xx other than 429) will not change on retry.
    cause = llm_root_cause(e)
    resp = e$resp %||% cause$resp
    status = if (is.null(resp)) NA_integer_ else httr2::resp_status(resp)
    why = tryCatch(jsonlite::fromJSON(httr2::resp_body_string(resp))$error$message,
                   error = function(e2) NULL) %||% conditionMessage(cause)
    msg = paste0(if (is.na(status)) "The call to " else "The endpoint refused the request for ",
                 m$id, if (!is.na(status)) paste0(" (HTTP ", status, ")"),
                 if (is.na(status)) " failed", ": ", substr(why, 1, 300))
    llm_fail(gsub(key, "[key]", msg, fixed = TRUE),
             class = if (!is.na(status) && status >= 400 && status < 500 && status != 429)
               "llm_client_error")
  })

  # Read defensively: a missing turn or property is not worth losing the reply.
  turn = tryCatch(chat$last_turn(), error = function(e) NULL)
  finish = tryCatch(S7::prop(turn, "finish_reason"), error = function(e) NA_character_)
  reply = as.character(reply)
  attr(reply, "provider") = llm_host(m)
  attr(reply, "finish") = if (length(finish) != 1L || is.na(finish)) "unknown" else as.character(finish)
  attr(reply, "tokens") = tryCatch(S7::prop(turn, "tokens"), error = function(e) NULL)
  attr(reply, "seconds") = as.numeric(difftime(Sys.time(), started, units = "secs"))
  reply
}


# ---- JSON parse and repair (from svysegment/R/llm.R) --------------------------------

# A bare double quote inside a JSON string ends the string, and the parser then
#   sees the rest of the sentence as a syntax error. Models do this when a
#   stem holds a quoted word. Repaired rather than rejected, because the reply is
#   right and only its punctuation is wrong, and because a retry produces the
#   same sentence.

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
#   last value and the parser runs off the end. One scan, used twice: once to
#   find out whether the text ends inside a string and what brackets are still
#   open, and again after the quote is put back.
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
  #   and the text ends with a stray character.
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
#   Where there is no closing brace at all, everything from the first one is
#   taken and repair_json_close() finishes it.
json_candidate <- function(txt, pattern) {
  m = regmatches(txt, regexpr(pattern, txt, perl = TRUE))
  if (length(m)) return(m)
  i = regexpr("\\{", txt)
  if (i < 0) return(character(0))
  substr(txt, i, nchar(txt))
}

# The reply is carried into the error: "could not be repaired" with nothing else
#   is a message an analyst can act on only by asking someone to reproduce it.
parse_json_block <- function(txt, pattern = "(?s)\\{.*\\}") {
  m = json_candidate(txt, pattern)
  if (!length(m)) stop("No JSON found in the model reply:\n", txt, call. = FALSE)

  obj = try(jsonlite::fromJSON(m, simplifyVector = FALSE), silent = TRUE)
  if (!inherits(obj, "try-error")) return(obj)

  # Three repairs, in the order that makes each one meaningful. A stray quote
  #   inside a value changes where the scan thinks the strings start and end, so
  #   closing before escaping would close the wrong string; and a reply can need
  #   both.
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

# Appended to every JSON prompt at the moment of the call, rather than written
#   into each one: R/skills.R builds the prompt the analyst sees and approves,
#   and has no business knowing how a reply is parsed. llm_json() returns the
#   message as sent, so the log can hold both. Worded so it cannot be read as
#   "avoid quotes": told only "no double quotes inside a value", a model drops
#   the quote that ends the value as well.
JSON_QUOTE_RULE <- paste(
  "Return exactly one JSON object and nothing before or after it.",
  "Every key and every string value must both open AND close with a double",
  "quote -- including the last value in the object.",
  "Inside a value, use single quotes for any quoted word: 'often', not",
  "\"often\". Do not put a line break inside a value.")

# Two failures seen from endpoints, neither of which a parse repair can fix:
#   1. Chat-template tokens leaking into the reply (<|end_header_id|>,
#      <|eot_id|>, a bare "assistant" line), seen from open-weight models on a
#      shared endpoint. Stripped before parsing; harmless otherwise.
#   2. The model echoing the prompt's example object, so every value is "...".
#      It parses as valid JSON and would reach the app as an answer. It is a
#      failed attempt, so it is retried.
clean_model_reply <- function(txt) {
  txt = gsub("<\\|[^|>]{1,40}\\|>", " ", txt, perl = TRUE)
  txt = gsub("(?m)^\\s*(assistant|user|system)\\s*$", "", txt, perl = TRUE)
  trimws(txt)
}

is_placeholder_reply <- function(obj) {
  vals = unlist(obj, use.names = FALSE)
  vals = vals[is.character(vals)]
  !length(vals) || all(trimws(vals) %in% c("", "...", "…"))
}


# ---- one JSON call, with retry -------------------------------------------------------

# One model, one message, one parsed object. The distinction that matters is
#   whether a second attempt could plausibly succeed. A timeout, a 5xx, a rate
#   limit, a reply that is not JSON, and the echoed template are all worth
#   another try. A client error (a bad key, an unknown model) is not: it is
#   raised at once. Nor is a reply cut off at the token limit (class
#   llm_truncated): the same prompt is cut off at the same place, so a retry only
#   spends the ceiling again. A reply that parsed but carried
#   the wrong fields is a prompt problem, so validate (a function that stops with
#   a readable message) is applied last, inside the attempt, and only when asked
#   for; R/checks.R brings the validators.
#
# max_times is the number of attempts. session_cap stops a systematically broken
#   prompt from draining the quota one retry at a time: once a session has used
#   that many repeat attempts, no more are made and the call fails at once.
#   Each attempt is also retried by ellmer itself on a 429 or 503.
#
# key defaults to llm_key_for(m). tests/llm_check.R hands the project manager's
#   key in directly, the way the key box would; the app never reads the
#   environment for a model whose key_source is "analyst". complete is the
#   function that makes the request, so a test can stand in for the network.
#
# Returns the parsed object and everything the run log keeps: obj, raw (the
#   reply as the model sent it), user_sent (the message with JSON_QUOTE_RULE
#   added), model, finish, tokens, seconds and attempts. On failure the error
#   carries the last raw reply as $raw.
llm_json <- function(user, m, system_prompt = NULL, max_tokens, validate = NULL,
                     pattern = "(?s)\\{.*\\}", max_times = 3L, session_cap = 10L,
                     pause_base = 2, pause_min = 1, key = NULL,
                     complete = llm_complete) {

  # A missing key is not a transient failure. Checked once, here, so it is
  #   reported at once instead of after three retries.
  key = key %||% llm_key_for(m)
  if (is.null(key) || !nzchar(key))
    llm_fail(paste0("There is no key for ", m$id, ". ", llm_key_hint(m)),
             class = "llm_client_error")

  ask = paste0(user, "\n\n", JSON_QUOTE_RULE)

  attempt = function() {
    if (llm_retries_used() >= session_cap)
      llm_fail(paste0("The session's retry cap of ", session_cap, " is reached. The ",
                      "prompt or the endpoint needs attention; more attempts would ",
                      "spend quota without diagnosing it."),
               class = "llm_client_error")
    .llm_state$calls <- .llm_state$calls + 1L
    out = complete(m, system_prompt, ask, max_tokens, key)
    finish = attr(out, "finish") %||% "unknown"
    # The reply as text, without the attributes that describe it: this is what
    #   the log keeps and what a failure carries as $raw.
    txt = as.character(out)
    # Which model and endpoint, and why the reply stopped, on every failure. Put
    #   first, not last: R cuts long error messages short.
    served = paste0("[", m$id, " via ", attr(out, "provider") %||% llm_host(m),
                    ", finish: ", finish, "] ")
    if (identical(finish, "max_tokens"))
      llm_fail(paste0(served, "The reply reached the token limit (", max_tokens,
                      ") without finishing, so it was cut off. It starts: ",
                      substr(txt, 1, 120)),
               class = "llm_truncated", raw = txt)
    reply = clean_model_reply(txt)
    obj = tryCatch(parse_json_block(reply, pattern),
                   error = function(e)
                     llm_fail(paste0(served, substr(conditionMessage(e), 1, 400)), raw = txt))
    if (is_placeholder_reply(obj))
      llm_fail(paste0(served, "The model returned the example template instead of ",
                      "an answer:\n", substr(reply, 1, 300)), raw = txt)
    if (!is.null(validate))
      tryCatch(validate(obj), error = function(e)
        llm_fail(paste0(served, conditionMessage(llm_root_cause(e))), raw = txt))
    list(obj = obj, raw = txt, finish = finish, tokens = attr(out, "tokens"))
  }

  # insistently() reports only "Request failed after 3 attempts", so the last
  #   attempt's own error is kept: that is the reason the analyst needs.
  last = NULL
  logged = function() withCallingHandlers(attempt(), error = function(e) last <<- e)

  before = .llm_state$calls
  started = Sys.time()
  # A client error is returned rather than raised inside the retry loop, so it
  #   is not sent three times.
  res = try(
    purrr::insistently(function()
                         tryCatch(logged(), llm_client_error = function(e) e,
                                  llm_truncated = function(e) e),
                       rate = purrr::rate_backoff(pause_base = pause_base,
                                                  pause_min = pause_min,
                                                  max_times = max_times),
                       quiet = TRUE)(),
    silent = TRUE)
  made = .llm_state$calls - before
  llm_add_retries(max(0L, made - 1L))
  if (inherits(res, c("llm_client_error", "llm_truncated")))
    res = structure(conditionMessage(res), class = "try-error", condition = res)
  if (inherits(res, "try-error")) stop(last %||% attr(res, "condition"))

  c(res, list(user_sent = ask, model = m$id, attempts = made,
              seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))))
}


# ---- the connection check's call -----------------------------------------------------

# One very small call to one model, no retry, answering ready or the endpoint's
#   own words. A model that has no key is not called: it says what is missing.
#   This is the only connection test that exists at work, where tests/ is gone.
llm_ping <- function(m, key = NULL, complete = llm_complete) {
  key = key %||% llm_key_for(m)
  if (is.null(key) || !nzchar(key))
    return(list(ok = FALSE, seconds = NA_real_,
                message = paste("Waits for a key.", llm_key_hint(m))))
  started = Sys.time()
  .llm_state$calls <- .llm_state$calls + 1L
  # reply is what the model said, for a test to show; the screen shows message.
  out = tryCatch({
    txt = as.character(complete(m, NULL, LLM_PING_PROMPT, LLM_MAX_TOKENS[["ping"]], key,
                                LLM_PING_TIMEOUT_S))
    if (nzchar(trimws(txt))) list(ok = TRUE, message = "Ready.", reply = txt)
    else list(ok = FALSE, message = "The endpoint answered with an empty reply.", reply = "")
  }, error = function(e) list(ok = FALSE, message = conditionMessage(e), reply = ""))
  c(out, list(seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))))
}


# ---- the key box -------------------------------------------------------------------

# On Start here, because the brief check, the appraisal and the Evaluate task all
#   need a key.

# WHERE TO GET A KEY -- replace the placeholder text below with the real
#   instructions for your deployment before handing this to anyone.
KEY_INSTRUCTIONS <- list(
  where = "TODO: name the provider and the page to open, e.g. 'Sign in at <URL> and open Settings -> Keys'.",
  create = "TODO: how to create a key, and which permissions or spending limit to set.",
  models = "TODO: which models the key must be able to reach, and anything to enable first.",
  cost   = "TODO: who pays, and what to do when the quota runs out.")

mod_key_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$hr(),
    tags$h4("Your API key"),
    uiOutput(ns("status")),

    passwordInput(ns("key"), NULL, width = "100%",
                  placeholder = "Paste your key here"),
    actionButton(ns("save"), "Use this key", class = "btn-primary"),
    actionButton(ns("clear"), "Forget it"),

    tags$div(
      style = paste("background: var(--bs-secondary-bg);",
                    "border-left: 3px solid var(--bs-border-color);",
                    "color: var(--bs-body-color);",
                    "padding: 8px 12px; margin: 12px 0;",
                    "font-size: 90%; white-space: pre-line;"),
      tags$p(tags$strong("Where to get one")),
      tags$p(KEY_INSTRUCTIONS$where),
      tags$p(KEY_INSTRUCTIONS$create),
      tags$p(KEY_INSTRUCTIONS$models),
      tags$p(KEY_INSTRUCTIONS$cost),
      tags$p(tags$em(
        "The key is kept for this session only. It is not saved anywhere, it ",
        "is not written into your results or the run log, and closing the tab ",
        "discards it."))))
}

mod_key_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    token <- session$token
    set <- reactiveVal(0L)

    observeEvent(input$save, {
      k <- trimws(input$key %||% "")
      if (!nzchar(k)) {
        showNotification("Nothing pasted.", type = "warning")
        return()
      }
      llm_set_session_key(k)
      updateTextInput(session, "key", value = "")
      set(set() + 1L)
      state$key_version <- (state$key_version %||% 0L) + 1L
      showNotification("Key accepted for this session.", type = "message")
    })

    observeEvent(input$clear, {
      llm_clear_session_key(token)
      updateTextInput(session, "key", value = "")
      set(set() + 1L)
      state$key_version <- (state$key_version %||% 0L) + 1L
      showNotification("Key forgotten.", type = "message")
    })

    # Dropped when the tab closes rather than left in the registry for the
    #   lifetime of the R process.
    session$onSessionEnded(function() {
      llm_clear_session_key(token)
      llm_clear_counters(token)
    })

    output$status <- renderUI({
      set()
      if (!is.null(llm_session_key()))
        tags$p(class = "text-success",
               "A key you supplied is in use for this session.")
      else
        warn_box(tags$div(
          "No key has been pasted. The brief check, the appraisal and the ",
          "Evaluate task are unavailable until you paste one."))
    })
  })
}
