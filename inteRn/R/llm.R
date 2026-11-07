# llm.R -- the key, the chat object, and sending a turn (blocking or async).
# Adapted from svysegment's llm.R: same endpoint settings, the key kept in a
#   closure, the endpoint's own error message surfaced, client errors not
#   retried. Function definitions only.

# ---- key ---------------------------------------------------------------

# The key is passed to ellmer as a function, so it travels in a closure and
#   never through Sys.setenv(), and it is never printed or written anywhere.
intern_key <- function(cfg = INTERN_LLM) {
  if (identical(cfg$key_source, "analyst")) {
    if (is.null(.state$key)) {
      if (!requireNamespace("rstudioapi", quietly = TRUE) || !rstudioapi::isAvailable())
        stop("key_source = \"analyst\" needs RStudio to ask for the key. ",
             "Use key_source = \"server\" and set ", cfg$key_var, " in .Renviron.",
             call. = FALSE)
      k = rstudioapi::askForPassword("API key for inteRn (kept for this R session only)")
      if (!is_string(k)) stop("No key entered.", call. = FALSE)
      .state$key = k
    }
    return(.state$key)
  }
  k = Sys.getenv(cfg$key_var)
  if (!nzchar(k))
    stop("No API key. Add ", cfg$key_var, "=... to your .Renviron ",
         "(usethis::edit_r_environ()) and restart R.", call. = FALSE)
  k
}

# ---- chat object -------------------------------------------------------

# A fresh conversation with the system prompt and the tools registered.
intern_new_chat <- function(role = "pm", system_prompt = intern_system_prompt(),
                            tools = intern_tools()) {
  cfg = INTERN_LLM
  key = intern_key(cfg)
  chat = ellmer::chat_anthropic(
    system_prompt = system_prompt,
    model = intern_model(role),
    params = ellmer::params(temperature = cfg$temperature,
                            max_tokens = as.integer(cfg$max_tokens)),
    cache = cfg$cache,
    base_url = cfg$base_url,
    credentials = function() key,
    echo = "none")
  if (length(tools)) chat$register_tools(tools)
  chat
}

# The session's conversation, started on first use.
intern_get_chat <- function() {
  if (is.null(.state$chat)) .state$chat = intern_new_chat()
  .state$chat
}

# Exported. Forget the conversation; the next question starts a new one.
intern_reset <- function() {
  .state$chat = NULL
  .state$pinned = list()
  message("inteRn: conversation cleared.")
  invisible(NULL)
}

# Exported. One request, one reply, no tools and no history: for jobs whose
#   input is assembled in R, such as the codebook skill's dictionary draft,
#   where the code decides exactly what is sent. Uses the "worker" model.
#   Signature fits the codebook skill's `describe` argument.
intern_complete <- function(prompt, system = NULL, role = "worker") {
  if (!is_string(prompt)) stop("intern_complete() takes the prompt as one string.", call. = FALSE)
  chat = intern_new_chat(role = role, system_prompt = system, tools = list())
  old = options(ellmer_timeout_s = INTERN_LLM$timeout)
  on.exit(options(old), add = TRUE)
  tryCatch(as.character(chat$chat(prompt, echo = "none")),
           error = function(e) stop(intern_endpoint_error(e, chat$get_model())))
}

# ---- errors ------------------------------------------------------------

root_cause <- function(e)
  if (inherits(e$parent, "condition")) root_cause(e$parent) else e

# The endpoint's own explanation ("model not found", "credit balance too
#   low") rather than httr2's bare status. A 4xx other than 429 will not change
#   on retry, so it is classed "intern_client_error" and not retried.
intern_endpoint_error <- function(e, model) {
  resp = e$resp %||% root_cause(e)$resp
  status = if (is.null(resp)) NA_integer_ else httr2::resp_status(resp)
  why = tryCatch(jsonlite::fromJSON(httr2::resp_body_string(resp))$error$message,
                 error = function(e2) NULL) %||% conditionMessage(root_cause(e))
  client = !is.na(status) && status >= 400 && status < 500 && status != 429
  rlang::error_cnd(
    class = c(if (client) "intern_client_error", "intern_error"),
    message = paste0("The endpoint refused the request for ", model,
                     if (!is.na(status)) paste0(" (HTTP ", status, ")"), ": ",
                     substr(scrub_text(why), 1, 300)))
}

# ---- sending a turn ----------------------------------------------------

# Blocking: used by ask(). The console is busy only while this runs. If the
#   call fails or is interrupted, the conversation is put back as it was
#   before the question, so a half-finished turn (a tool request with no
#   result) cannot break the next one. One retry on the fallback model for
#   server-side failures.
intern_send <- function(prompt, chat = intern_get_chat()) {
  before = chat$get_turns()
  old = options(ellmer_timeout_s = INTERN_LLM$timeout)
  on.exit(options(old), add = TRUE)

  once = function(p = prompt) as.character(chat$chat(p, echo = "none"))
  restore = function() chat$set_turns(before)

  reply = tryCatch(once(),
    interrupt = function(e) {
      restore()
      message("inteRn: interrupted; that question was dropped from the conversation.")
      invisible(NULL)
    },
    error = function(e) {
      restore()
      err = intern_endpoint_error(e, chat$get_model())
      fb = INTERN_LLM$pm_fallback
      if (inherits(err, "intern_client_error") || is.null(fb)) stop(err)
      message("inteRn: ", conditionMessage(err), "\nTrying ", fb, " once.")
      main = chat$get_model()
      chat$set_model(fb)
      on.exit(chat$set_model(main), add = TRUE)
      tryCatch(once(), error = function(e2) {
        restore()
        stop(intern_endpoint_error(e2, fb))
      })
    })
  if (is.null(reply)) return(NULL)                     # interrupted
  send = function(p) tryCatch(once(p), error = function(e) NULL)
  reply = fill_empty_reply(reply, chat, send)
  # R code in the reply is linted; failures go back for a rewrite
  #   (lint_gate.R). A rewrite that errors leaves the reply as it was.
  lint_gate(reply, chat, n_before = length(before), send = send)
}

# ---- empty replies -------------------------------------------------------

# A model can end its last turn with only its internal reasoning and no text,
#   or run out of tokens while reasoning. The user would see nothing, so it is
#   asked once to write the answer; a cut-off reply says so instead.
EMPTY_NUDGE <- "You ended your turn without writing an answer for the user. Write your answer now."

is_empty_reply <- function(reply)
  !length(reply) || all(is.na(reply)) || !nzchar(trimws(paste(reply, collapse = "")))

last_stop_reason <- function(chat)
  tryCatch(S7::prop(chat$last_turn(), "json")$stop_reason, error = function(e) NULL)

empty_reply_note <- function(chat) {
  if (identical(last_stop_reason(chat), "max_tokens"))
    return(paste0("_(The reply was cut off at the max_tokens limit (", INTERN_LLM$max_tokens,
                  ") before the model wrote an answer. Raise max_tokens in config.R, or ",
                  "ask a narrower question.)_"))
  "_(The model returned an empty reply. Please ask again.)_"
}

fill_empty_reply <- function(reply, chat, send) {
  if (!is_empty_reply(reply)) return(reply)
  if (identical(last_stop_reason(chat), "max_tokens")) return(empty_reply_note(chat))
  again = send(EMPTY_NUDGE)
  if (is_empty_reply(again)) empty_reply_note(chat) else again
}

fill_empty_reply_async <- function(reply, chat, send_async) {
  if (!is_empty_reply(reply)) return(reply)
  if (identical(last_stop_reason(chat), "max_tokens")) return(empty_reply_note(chat))
  promises::then(send_async(EMPTY_NUDGE), function(again)
    if (is_empty_reply(again)) empty_reply_note(chat) else again)
}

# Async: used by the Viewer chat. Returns a promise for the reply text.
#   Tools still run in this R session, between API calls, whenever the
#   console is idle. The reply goes through the lint gate like ask()'s.
intern_send_async <- function(prompt, chat = intern_get_chat()) {
  before = chat$get_turns()
  # Read when each request is built, which may be after this function
  #   returns, so it is set rather than restored on exit.
  options(ellmer_timeout_s = INTERN_LLM$timeout)
  # A one-argument function, not as.character itself: promises passes extra
  #   arguments to a function that accepts `...`, and as.character then
  #   returns character(0) -- every Viewer reply came out empty.
  ask_async = function(p) promises::then(chat$chat_async(p, tool_mode = "sequential"),
                                         function(x) as.character(x))
  ask_async(prompt) |>
    promises::catch(function(e) {
      chat$set_turns(before)
      stop(intern_endpoint_error(e, chat$get_model()))
    }) |>
    promises::then(function(reply) {
      send_async = function(p) promises::catch(ask_async(p), function(e) NULL)
      promises::then(promises::promise_resolve(fill_empty_reply_async(reply, chat, send_async)),
                     function(r) lint_gate_async(r, chat, n_before = length(before),
                                                 send_async = send_async))
    })
}
