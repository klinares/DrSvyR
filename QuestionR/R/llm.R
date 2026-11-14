# llm.R for QuestionR
# The model layer: the session key, the one call function for both API styles, JSON parse and
#   repair, retry with a session cap, the connection check and the key box. Nothing here is a
#   prompt: R/reflexes.R writes those. The model is APP_MODEL in app.R. "anthropic" calls
#   ellmer::chat_anthropic(), "openai" ellmer::chat_openai_compatible(); checked in ellmer 0.4.2.
#   Function definitions and constants only.


# ---- settings of the call --------------------------------------------------------------

# max_tokens per kind of call; the model's thinking counts against it (Sonnet 5.5 thinks by default,
#   at effort high). A reply that reaches the ceiling is a failure, not a short answer,
#   and is not retried: the same prompt is cut off at the same place.
LLM_MAX_TOKENS <- c(items = 24000L, instrument = 8000L, draft = 16000L, refine = 24000L, ping = 200L)

# What a cut-off reply tells the analyst to do, by kind of call.
LLM_CUTOFF_ADVICE <- c(draft = "Ask for fewer items and run again.", evaluate = "Paste fewer questions and run again.")

# Seconds before a request gives up (ellmer reads the option ellmer_timeout_s).
LLM_TIMEOUT_S <- 600
LLM_PING_TIMEOUT_S <- 60

# Anthropic prompt caching, as ellmer 0.4.2 documents chat_anthropic(cache =): "5m", "1h" or
#   "none". The calls of one review share their system prompt, so later ones can read it from the
#   cache. Set "none" behind a proxy that rejects cache instructions.
LLM_CACHE <- "5m"

LLM_PING_PROMPT <- "Reply with the single word OK."


# ---- the session key -------------------------------------------------------------------

# keys: one slot per Shiny session, by its token; retries: repeat attempts each session has used;
#   calls: requests this process has made. The key is pasted on Start here and held here for the
#   session only: never on disk, in the log, in exported state, or in the environment (which
#   would leak it to every session in the process).
.llm_state <- new.env(parent = emptyenv())
.llm_state$keys <- list()
.llm_state$retries <- list()
.llm_state$calls <- 0L

llm_session_id <- function() {
  s = shiny::getDefaultReactiveDomain()
  if (is.null(s)) "script" else s$token
}

llm_session_key <- function() {
  k = .llm_state$keys[[llm_session_id()]]
  if (is.null(k) || !nzchar(k)) NULL else k
}

llm_set_session_key <- function(key) {
  if (is.null(shiny::getDefaultReactiveDomain())) stop("No session to attach a key to.", call. = FALSE)
  .llm_state$keys[[llm_session_id()]] <- key
  invisible(TRUE)
}

llm_clear_session_key <- function(token) .llm_state$keys[[token]] <- NULL
llm_retries_used <- function() .llm_state$retries[[llm_session_id()]] %||% 0L
llm_add_retries <- function(n) .llm_state$retries[[llm_session_id()]] <- llm_retries_used() + as.integer(n)
llm_clear_counters <- function(token) .llm_state$retries[[token]] <- NULL

# The key is the pasted one and nothing else: an ANTHROPIC_API_KEY set at home is ignored.
llm_key_for <- function(m = APP_MODEL) llm_session_key()
llm_key_ready <- function(m = APP_MODEL) !is.null(llm_key_for(m))
KEY_HINT <- "Paste a key into the key box on Start here."

# The models of a profile, named for the page: the main model, and the drafter when there is one.
app_models <- function(m = APP_MODEL)
  purrr::compact(list(`Main model` = m[names(m) != "drafter"], Drafter = m$drafter))

llm_host <- function(m) sub("^[a-z]+://([^/]+).*$", "\\1", m$base_url)

# The entries of a model that still hold a <placeholder> (the work profile before it is filled in).
llm_placeholders <- function(m = APP_MODEL)
  names(purrr::keep(m, function(v) is.character(v) && length(v) == 1L && grepl("^<.+>$", v)))


# ---- errors and the call ------------------------------------------------------------------

# Every error raised here is an "llm_error" carrying the raw reply when there was one. A client
#   error (one a second attempt will not change) is also an "llm_client_error" and is not retried.
llm_fail <- function(msg, class = NULL, raw = NULL) rlang::abort(msg, class = c(class, "llm_error"), raw = raw, call = NULL)

# purrr and rlang wrap an error raised inside map(); the innermost one is the cause.
llm_root_cause <- function(e) if (inherits(e$parent, "condition")) llm_root_cause(e$parent) else e

no_key <- function(m) llm_fail(paste0("There is no key for ", m$id, ". ", KEY_HINT), class = "llm_client_error")

# The ellmer chat object for one model; no request is made here. The key travels in a closure,
#   never through the environment. No temperature is sent unless the entry sets one. An entry may
#   set reasoning_effort and, for the OpenAI style, max_tokens_name; checked in ellmer 0.4.2:
#   params() turns reasoning_effort into adaptive thinking for "anthropic" but drops it for
#   "openai", and sends max_completion_tokens, so for "openai" those two go in api_args.
llm_chat <- function(m, system_prompt, max_tokens, key) {
  if (is.null(key) || !nzchar(key)) no_key(m)
  if (!is.null(m$max_tokens_name) && !m$max_tokens_name %in% c("max_completion_tokens", "max_tokens"))
    llm_fail(paste0("The model ", m$id, " has max_tokens_name '", m$max_tokens_name,
                    "'; it must be 'max_completion_tokens' or 'max_tokens'."), class = "llm_client_error")
  old_name = identical(m$api, "openai") && identical(m$max_tokens_name, "max_tokens")
  params = ellmer::params(temperature = m$temperature, max_tokens = if (!old_name) max_tokens,
                          reasoning_effort = if (identical(m$api, "anthropic")) m$reasoning_effort)
  api_args = as.list(c(if (old_name) list(max_tokens = max_tokens),
                       if (identical(m$api, "openai") && !is.null(m$reasoning_effort)) list(reasoning_effort = m$reasoning_effort)))
  switch(m$api %||% "",
    anthropic = ellmer::chat_anthropic(system_prompt = system_prompt, params = params, model = m$id, cache = LLM_CACHE,
                                       base_url = m$base_url, credentials = function() key, echo = "none"),
    openai = ellmer::chat_openai_compatible(base_url = m$base_url, name = llm_host(m), system_prompt = system_prompt,
                                            credentials = function() key, model = m$id, params = params,
                                            api_args = api_args, echo = "none"),
    llm_fail(paste0("The model ", m$id, " has api '", m$api, "'; it must be 'anthropic' or 'openai'."),
             class = "llm_client_error"))
}

# What the endpoint said when a call failed, from the response body ("model not found"), as an
#   error. A 4xx other than 429 is a client error.
llm_refuse <- function(e, m, key) {
  cause = llm_root_cause(e)
  resp = e$resp %||% cause$resp
  status = if (is.null(resp)) NA_integer_ else httr2::resp_status(resp)
  why = tryCatch(jsonlite::fromJSON(httr2::resp_body_string(resp))$error$message, error = function(e2) NULL) %||%
    conditionMessage(cause)
  msg = paste0(if (is.na(status)) "The call to " else "The endpoint refused the request for ", m$id,
               if (!is.na(status)) paste0(" (HTTP ", status, ")") else " failed", ": ", substr(why, 1, 300))
  llm_fail(gsub(key, "[key]", msg, fixed = TRUE),
           class = if (!is.na(status) && status >= 400 && status < 500 && status != 429) "llm_client_error")
}

# A reply as text, with provider, finish (as ellmer names it: "success", "max_tokens", ...),
#   tokens (input, output, cached input) and seconds as attributes.
llm_reply <- function(chat, reply, m, started) {
  turn = tryCatch(chat$last_turn(), error = function(e) NULL)
  finish = tryCatch(S7::prop(turn, "finish_reason"), error = function(e) NA_character_)
  structure(as.character(reply), provider = llm_host(m),
            finish = if (length(finish) != 1L || is.na(finish)) "unknown" else as.character(finish),
            tokens = tryCatch(S7::prop(turn, "tokens"), error = function(e) NULL),
            seconds = as.numeric(difftime(Sys.time(), started, units = "secs")))
}

# One request, one fresh chat object: no history carries from one request to the next.
llm_complete <- function(m, system_prompt, user, max_tokens, key = llm_key_for(m), timeout = LLM_TIMEOUT_S) {
  old = options(ellmer_timeout_s = timeout)
  on.exit(options(old), add = TRUE)
  chat = llm_chat(m, system_prompt, max_tokens, key)
  started = Sys.time()
  # The reply is made first: llm_reply() reads the chat's last turn, which exists only after it.
  reply = tryCatch(chat$chat(user, echo = "none"), error = function(e) llm_refuse(e, m, key))
  llm_reply(chat, reply, m, started)
}

# Several requests sent together in this one R process: each gets its own chat object, and
#   ellmer's chat_async() starts it; later::run_now() lets them make progress side by side until
#   every one has settled. Returns, in order, each reply or the error it met.
llm_complete_all <- function(requests, timeout = LLM_TIMEOUT_S) {
  old = options(ellmer_timeout_s = timeout)
  on.exit(options(old), add = TRUE)
  state = new.env()
  state$out = vector("list", length(requests))
  state$done = rep(FALSE, length(requests))
  settle = function(i, value) { state$out[[i]] = value; state$done[[i]] = TRUE }
  caught = function(expr) tryCatch(expr, error = function(e) e)
  purrr::iwalk(requests, function(r, i) {
    key = r$key %||% llm_key_for(r$m)
    chat = caught(if (is.null(key) || !nzchar(key)) no_key(r$m) else llm_chat(r$m, r$system_prompt, r$max_tokens, key))
    if (inherits(chat, "error")) return(settle(i, chat))
    started = Sys.time()
    tryCatch(promises::then(chat$chat_async(r$user),
                            onFulfilled = function(v) settle(i, caught(llm_reply(chat, v, r$m, started))),
                            onRejected = function(e) settle(i, caught(llm_refuse(e, r$m, key)))),
             error = function(e) settle(i, caught(llm_refuse(e, r$m, key))))
  })
  # Half-second turns, up to a little over the timeout; a purrr search, not a loop.
  purrr::detect(seq_len(ceiling(2 * (timeout + 60))), function(k) {
    later::run_now(timeoutSecs = 0.5)
    all(state$done)
  })
  purrr::imap(state$out, function(x, i)
    x %||% caught(llm_fail(paste0("The call to ", requests[[i]]$m$id, " failed: no answer came back in time."))))
}


# ---- JSON parse and repair (from svysegment/R/llm.R) -----------------------------------------

# A bare double quote inside a value ends the string early, a fault models make when a stem holds a
#   quoted word. A quote ends a string only if the next thing that is not whitespace is a comma, a
#   colon, a closing brace or bracket, or the end; any other quote is escaped.
JSON_CLOSERS <- c(",", ":", "}", "]", "")

repair_json_quotes <- function(txt) {
  ch = strsplit(txt, "", fixed = TRUE)[[1]]
  if (!length(ch)) return(txt)
  pos = which(!ch %in% c(" ", "\t", "\n", "\r"))
  nxt = pos[findInterval(seq_along(ch), pos) + 1L]
  nxt_ch = ifelse(is.na(nxt), "", ch[nxt])
  st = purrr::reduce(seq_along(ch), function(s, i) {
    if (s$esc) { s$esc = FALSE; return(s) }
    if (identical(ch[i], "\\")) { s$esc = TRUE; return(s) }
    if (!identical(ch[i], "\"")) return(s)
    if (!s$ins) { s$ins = TRUE; return(s) }
    if (nxt_ch[i] %in% JSON_CLOSERS) { s$ins = FALSE; return(s) }
    s$stray = c(s$stray, i)
    s
  }, .init = list(ins = FALSE, esc = FALSE, stray = integer(0)))
  if (!length(st$stray)) return(txt)
  ch[st$stray] = "\\\""
  paste(ch, collapse = "")
}

# Whether the text ends inside a string, and which brackets are still open.
json_scan <- function(txt)
  purrr::reduce(strsplit(txt, "", fixed = TRUE)[[1]], function(s, c1) {
    if (s$esc) { s$esc = FALSE; return(s) }
    if (s$ins) {
      if (identical(c1, "\\")) s$esc = TRUE else if (identical(c1, "\"")) s$ins = FALSE
      return(s)
    }
    if (identical(c1, "\"")) { s$ins = TRUE; return(s) }
    if (c1 %in% c("{", "[")) s$open = c(s$open, c1)
    else if (c1 %in% c("}", "]") && length(s$open)) s$open = s$open[-length(s$open)]
    s
  }, .init = list(ins = FALSE, esc = FALSE, open = character(0)))

# The other half of the fault: the quote that ends the last value is missing, or the reply was cut
#   off. The quote goes back before any closing braces the model did write, then what is open is closed.
repair_json_close <- function(txt) {
  st = json_scan(txt)
  if (isTRUE(st$ins)) {
    at = regexpr("[[:space:]}\\]]*$", txt)
    txt = if (at > 0) paste0(substr(txt, 1, at - 1L), "\"", substr(txt, at, nchar(txt))) else paste0(txt, "\"")
    st = json_scan(txt)
  }
  if (!length(st$open)) return(txt)
  paste0(txt, paste(rev(ifelse(st$open == "{", "}", "]")), collapse = ""))
}

# The object pulled out by pattern, since some models wrap it in prose or fences; with no closing
#   brace, everything from the first one.
json_candidate <- function(txt, pattern) {
  m = regmatches(txt, regexpr(pattern, txt, perl = TRUE))
  if (length(m)) return(m)
  i = regexpr("\\{", txt)
  if (i < 0) character(0) else substr(txt, i, nchar(txt))
}

parse_json_block <- function(txt, pattern = "(?s)\\{.*\\}") {
  m = json_candidate(txt, pattern)
  if (!length(m)) stop("No JSON found in the model reply:\n", txt, call. = FALSE)
  obj = try(jsonlite::fromJSON(m, simplifyVector = FALSE), silent = TRUE)
  if (!inherits(obj, "try-error")) return(obj)
  # Escaping first: a stray quote changes where the scan thinks strings end, and a reply can need both.
  done = purrr::compact(purrr::map(list(repair_json_quotes(m), repair_json_close(m), repair_json_close(repair_json_quotes(m))),
    function(fixed) {
      if (identical(fixed, m)) return(NULL)
      r = try(jsonlite::fromJSON(fixed, simplifyVector = FALSE), silent = TRUE)
      if (inherits(r, "try-error")) NULL else r
    }))
  if (length(done)) return(done[[1]])
  stop("The model reply is not valid JSON and could not be repaired.\n", conditionMessage(attr(obj, "condition")),
       "\n--- reply ---\n", substr(m, 1, 1200), call. = FALSE)
}

# Added to every message at the moment of the call. Worded so it cannot be read as "avoid quotes":
#   told only that, a model drops the quote that ends the value as well.
JSON_QUOTE_RULE <- paste(
  "Return exactly one JSON object and nothing before or after it.",
  "Every key and every string value must both open AND close with a double",
  "quote -- including the last value in the object.",
  "Inside a value, use single quotes for any quoted word: 'often', not",
  "\"often\". Do not put a line break inside a value.")

# Chat-template tokens that leak from some endpoints, stripped before parsing.
clean_model_reply <- function(txt) {
  txt = gsub("<\\|[^|>]{1,40}\\|>", " ", txt, perl = TRUE)
  trimws(gsub("(?m)^\\s*(assistant|user|system)\\s*$", "", txt, perl = TRUE))
}

# The prompt's example object echoed back: it parses, but it is no answer.
is_placeholder_reply <- function(obj) {
  vals = unlist(obj, use.names = FALSE)
  vals = vals[is.character(vals)]
  !length(vals) || all(trimws(vals) %in% c("", "...", "…"))
}


# ---- one JSON call, with retry -------------------------------------------------------------

# One model, one message, one parsed object. A timeout, a 5xx, a reply that is not JSON, the echoed
#   template, and a reply validate() refuses are tried again, up to max_times attempts; a client
#   error and a reply cut off at the ceiling are not. session_cap stops a broken prompt draining
#   the quota: once a session has used that many repeat attempts, the next call fails at once.
#   complete makes the request, so a test can stand in for the network; first is a first attempt
#   already made by llm_complete_all(). Returns obj, raw, finish, tokens, user_sent, model, attempts,
#   seconds and refused (why each attempt before the one returned was refused); a failure carries the
#   last raw reply as $raw.
llm_json <- function(user, m, system_prompt = NULL, max_tokens, validate = NULL, pattern = "(?s)\\{.*\\}",
                     max_times = 3L, session_cap = 10L, pause_base = 2, pause_min = 1, key = NULL,
                     complete = llm_complete, first = NULL) {
  key = key %||% llm_key_for(m)
  if (is.null(key) || !nzchar(key)) no_key(m)
  ask = paste0(user, "\n\n", JSON_QUOTE_RULE)
  attempt = function() {
    if (llm_retries_used() >= session_cap)
      llm_fail(paste0("The session's retry cap of ", session_cap, " is reached. The prompt or the endpoint needs ",
                      "attention; more attempts would spend quota without diagnosing it."), class = "llm_client_error")
    .llm_state$calls <- .llm_state$calls + 1L
    out = if (is.null(first)) complete(m, system_prompt, ask, max_tokens, key)
          else { made = first; first <<- NULL; if (inherits(made, "error")) stop(made); made }
    finish = attr(out, "finish") %||% "unknown"
    txt = as.character(out)
    # Which model and why it stopped, first in every failure: R cuts long messages short.
    served = paste0("[", m$id, " via ", attr(out, "provider") %||% llm_host(m), ", finish: ", finish, "] ")
    if (identical(finish, "max_tokens"))
      llm_fail(paste0(served, "The reply reached the token limit (", max_tokens, ") without finishing, so it was cut off. ",
                      "It starts: ", substr(txt, 1, 120)), class = "llm_truncated", raw = txt)
    reply = clean_model_reply(txt)
    obj = tryCatch(parse_json_block(reply, pattern),
                   error = function(e) llm_fail(paste0(served, substr(conditionMessage(e), 1, 400)), raw = txt))
    if (is_placeholder_reply(obj))
      llm_fail(paste0(served, "The model returned the example template instead of an answer:\n", substr(reply, 1, 300)), raw = txt)
    if (!is.null(validate))
      tryCatch(validate(obj), error = function(e) llm_fail(paste0(served, conditionMessage(llm_root_cause(e))), raw = txt))
    list(obj = obj, raw = txt, finish = finish, tokens = attr(out, "tokens"))
  }
  # insistently() says only "failed after 3 attempts", so the last attempt's own error is kept; a
  #   client error or a cut-off reply is returned, not raised, so it is not sent again.
  last = NULL
  refused = character(0)
  sent_seconds = as.numeric(attr(first, "seconds") %||% 0)
  before = .llm_state$calls
  started = Sys.time()
  res = try(purrr::insistently(function()
    tryCatch(withCallingHandlers(attempt(), error = function(e) { last <<- e; refused <<- c(refused, substr(conditionMessage(e), 1, 300)) }),
             llm_client_error = function(e) e, llm_truncated = function(e) e),
    rate = purrr::rate_backoff(pause_base = pause_base, pause_min = pause_min, max_times = max_times), quiet = TRUE)(),
    silent = TRUE)
  made = .llm_state$calls - before
  llm_add_retries(max(0L, made - 1L))
  if (inherits(res, c("llm_client_error", "llm_truncated", "try-error"))) stop(last %||% attr(res, "condition") %||% res)
  c(res, list(user_sent = ask, model = m$id, attempts = made, refused = as.list(refused),
              seconds = as.numeric(difftime(Sys.time(), started, units = "secs")) + sent_seconds))
}

# Several JSON calls sent together: the first attempts go out at once through llm_complete_all(),
#   then each reply gets what llm_json() does to one. Returns, in order, each result or its error.
llm_json_all <- function(requests) {
  first = llm_complete_all(requests)
  purrr::map2(requests, first, function(r, f) tryCatch(do.call(llm_json, c(r, list(first = f))), error = function(e) e))
}


# ---- the connection check -------------------------------------------------------------------

# One very small call, no retry: ready, or the endpoint's own words. With no key or a placeholder
#   it is not called and says what is missing. The only connection test there is at work.
llm_ping <- function(m, key = NULL, complete = llm_complete) {
  if (length(llm_placeholders(m)))
    return(list(ok = FALSE, seconds = NA_real_, message = paste0("Not set up: ", paste(llm_placeholders(m), collapse = ", "),
                                                               " still hold a placeholder in app.R. See README.md, Setting up at work.")))
  key = key %||% llm_key_for(m)
  if (is.null(key) || !nzchar(key)) return(list(ok = FALSE, seconds = NA_real_, message = paste("Waits for a key.", KEY_HINT)))
  started = Sys.time()
  .llm_state$calls <- .llm_state$calls + 1L
  out = tryCatch({
    txt = as.character(complete(m, NULL, LLM_PING_PROMPT, LLM_MAX_TOKENS[["ping"]], key, LLM_PING_TIMEOUT_S))
    if (nzchar(trimws(txt))) list(ok = TRUE, message = "Ready.") else list(ok = FALSE, message = "The endpoint answered with an empty reply.")
  }, error = function(e) list(ok = FALSE, message = conditionMessage(e)))
  c(out, list(seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))))
}


# ---- the key box ----------------------------------------------------------------------------

# What Start here says under "Where to get one". Replace it with your deployment's own wording.
KEY_INSTRUCTIONS <- c(
  "Ask the person who manages the AI service for your office for a key.",
  "Use a key issued to you, not one shared by a team, so that use can be traced to the person who made it.",
  "The key must be able to reach the model listed under Settings and connection below. Check the connection there before you start.",
  "If a request is refused for quota or cost, stop and ask the person who issued the key; do not borrow someone else's.")

mod_key_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$hr(), tags$h4("Your API key"), uiOutput(ns("status")),
    passwordInput(ns("key"), NULL, width = "100%", placeholder = "Paste your key here"),
    actionButton(ns("save"), "Use this key", class = "btn-primary"), actionButton(ns("clear"), "Forget it"),
    advice_box(tags$p(tags$strong("Where to get one")), purrr::map(KEY_INSTRUCTIONS, tags$p),
               tags$p(tags$em("The key is kept for this session only. It is not saved anywhere, it is not written into ",
                              "your results or the run log, and closing the tab discards it."))))
}

mod_key_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    token <- session$token
    changed <- function(note) {
      updateTextInput(session, "key", value = "")
      state$key_version <- (state$key_version %||% 0L) + 1L
      showNotification(note, type = "message")
    }
    observeEvent(input$save, {
      k <- trimws(input$key %||% "")
      if (!nzchar(k)) return(showNotification("Nothing pasted.", type = "warning"))
      llm_set_session_key(k)
      changed("Key accepted for this session.")
    })
    observeEvent(input$clear, { llm_clear_session_key(token); changed("Key forgotten.") })
    # Dropped when the tab closes, not left for the lifetime of the R process.
    session$onSessionEnded(function() { llm_clear_session_key(token); llm_clear_counters(token) })
    output$status <- renderUI({
      state$key_version
      if (!is.null(llm_session_key())) tags$p(class = "text-success", "A key you supplied is in use for this session.")
      else warn_box("No key has been pasted. Nothing can be run until you paste one.")
    })
  })
}
