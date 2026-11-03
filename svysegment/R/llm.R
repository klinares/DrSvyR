# llm.R for DrSvyR
# Endpoint, models, and every model call in the workflow.

# Every call goes through ellmer::chat_anthropic() to Anthropic's Messages API
#   at WISE_LLM$base_url: Anthropic's own API, or a work server that serves
#   Claude behind the same API. Pointing the app elsewhere means changing the
#   block below, nothing more.

# ---- configuration -----------------------------------------------------

# Committed to the repository deliberately. The endpoint and the model names
#   are properties of the deployment rather than of the analyst, so a change is
#   a reviewable commit and every analyst picks it up on the next pull, rather
#   than a dozen people editing a dotfile. The analyst's .Renviron holds one
#   line: the key.

WISE_LLM <- list(
  # Anthropic's public API. At work, the server's base URL, ending where
  #   Anthropic's ends (the part before /messages).
  base_url = "https://api.anthropic.com/v1",
  key_var  = "ANTHROPIC_API_KEY",

  # The model IDs exactly as the endpoint names them. Check against
  #   ellmer::models_anthropic() or the work server's model list: a wrong ID
  #   fails every call with "model not found". One model for both roles means
  #   one model's behaviour to understand.
  pm          = "claude-opus-5",
  worker      = "claude-opus-5",
  # Tried once after the main model's retries fail. NULL for none.
  pm_fallback = NULL,

  # "server" reads key_var from the environment. "analyst" ignores the
  #   environment entirely and requires a key pasted into the app.
  key_source = "server",
  timeout    = 120,

  # Ceiling for each reply. The answers are a few hundred tokens; a reply that
  #   reaches this is almost always a model repeating itself, and is treated as
  #   a failed attempt rather than parsed.
  max_tokens  = 1500,
  # NULL sends no temperature. Recent Claude models refuse the setting
  #   ("temperature is deprecated for this model"); set a number only for a
  #   model that accepts one.
  temperature = NULL,

  # Prompt caching. The AI reflexes are a long system prompt sent with every
  #   written passage, so a five-minute cache saves cost across a session.
  #   "none" if the endpoint rejects cache instructions.
  cache = "5m")

# ---- zz_llm ------------------------------------------------------------

# Every model call in the workflow goes through this file.

#   1. Keys and models
#   2. Per-process state
#   3. JSON calls, retry and fallback
#   4. Freeze-file keying

# Endpoint and models come from the block at the top of this file, which is in
#   the repository. The key comes from the environment or from the analyst and
#   is never written anywhere: it is passed as an argument and stays local to
#   the call. Nothing here calls Sys.setenv().

# Requires: ellmer, purrr, jsonlite, digest, dplyr, tibble, readr, fs


# Section 1 finds the key and the model. Two roles: the project manager reads
#   the analysis and writes prose, the worker names one segment.
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

# In "analyst" mode the environment is not consulted at all. That is the
#   point: a key set on a shared server would otherwise be picked up by an
#   analyst who never supplied one, and spent without anyone noticing.
llm_server_key_set <- function()
  identical(WISE_LLM$key_source %||% "server", "server") &&
    nzchar(Sys.getenv(WISE_LLM$key_var))

# Whether a call would find a key, without making one. Screens that offer
#   drafting ask this before offering it.
llm_key_available <- function() !is.null(llm_session_key()) || llm_server_key_set()

llm_api_key <- function() {
  if (!llm_key_available())
    stop("No API key is set, so nothing can be drafted. Paste a key on the ",
         "Start here tab, or set ", WISE_LLM$key_var, " on the server. ",
         "Everything else works without one.", call. = FALSE)
  llm_session_key() %||% Sys.getenv(WISE_LLM$key_var)
}

llm_model <- function(role) {
  m = WISE_LLM[[role]]
  if (is.null(m)) stop("No model configured for role '", role, "'.", call. = FALSE)
  m
}

# Section 2 is per-process state: the keys analysts type, and a call count
#   that caps retries per session so a failing endpoint is not hammered.
#______________________________________________________________________________

# An environment rather than an option, so a stray options() call cannot reset
#   it.

.llm_state <- new.env(parent = emptyenv())

# Keys typed into the app, one slot per Shiny session. On a server each analyst
#   supplies their own and it lives here for the length of their session only:
#   never written to disk, never in the decision log, never in state (which is
#   exported), and never through Sys.setenv(), which would leak it to every
#   other session in the process.
.llm_state$keys <- list()

.llm_state$calls <- 0L
.llm_state$retries <- 0L


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
# Worded so it cannot be read as "avoid quotes": told only "no double quotes
#   inside a value", a model drops the quote that ends the value as well.
JSON_QUOTE_RULE <- paste(
  "Return exactly one JSON object and nothing before or after it.",
  "Every key and every string value must both open AND close with a double",
  "quote -- including the last value in the object.",
  "Inside a value, use single quotes for any quoted word: 'Nada', not",
  "\"Nada\". Do not put a line break inside a value.")

# One request, one fresh chat object: no history is carried from one request
#   to the next, so each segment is named without seeing the others. ellmer
#   speaks Anthropic's Messages API, so the request and reply shapes are
#   Anthropic's whether the endpoint is Anthropic's or a work server's.
# The token ceiling, and a temperature only if one is set, come from
#   WISE_LLM. Reproducibility comes from the freeze file, not from temperature.
# The reply is plain text; llm_json() finds and repairs the JSON in it, so a
#   model that wraps JSON in a code fence or a sentence is still read.
llm_complete <- function(model, system_prompt, user) {
  key = llm_api_key()
  old = options(ellmer_timeout_s = WISE_LLM$timeout %||% 120)
  on.exit(options(old), add = TRUE)

  chat = ellmer::chat_anthropic(
    system_prompt = system_prompt,
    model = model,
    params = ellmer::params(temperature = WISE_LLM$temperature,
                            max_tokens = WISE_LLM$max_tokens %||% 1500L),
    cache = WISE_LLM$cache %||% "5m",
    base_url = WISE_LLM$base_url,
    # A function, so the key travels in this closure and never through the
    #   environment, where every session in the process could read it.
    credentials = function() key,
    echo = "none")

  reply = tryCatch(chat$chat(user, echo = "none"), error = function(e) {
    # The endpoint's own explanation is in the response body ("model not
    #   found", "credit balance too low"); httr2's message alone is just the
    #   status. A client error (4xx other than 429) will not change on retry,
    #   so it is classed for llm_json() to stop at once.
    resp = e$resp %||% root_cause(e)$resp
    status = if (is.null(resp)) NA_integer_ else httr2::resp_status(resp)
    why = tryCatch(jsonlite::fromJSON(httr2::resp_body_string(resp))$error$message,
                   error = function(e2) NULL) %||% conditionMessage(root_cause(e))
    rlang::abort(paste0("The endpoint refused the request for ", model,
                        if (!is.na(status)) paste0(" (HTTP ", status, ")"), ": ",
                        substr(why, 1, 300)),
                 class = if (!is.na(status) && status >= 400 && status < 500 &&
                             status != 429) "llm_client_error")
  })

  # Anthropic reports why a reply stopped; "max_tokens" means it was cut off
  #   mid-answer. Read defensively: if this ellmer keeps it elsewhere, the
  #   reply is still parsed and a cut-off one fails as invalid JSON.
  turn = utils::tail(chat$get_turns(), 1)[[1]]
  stop_reason = tryCatch(S7::prop(turn, "json")$stop_reason, error = function(e) NULL)
  reply = as.character(reply)
  attr(reply, "provider") = sub("^[a-z]+://([^/]+).*$", "\\1", WISE_LLM$base_url)
  attr(reply, "finish") = if (identical(stop_reason, "max_tokens")) "length"
                          else stop_reason %||% "unknown"
  reply
}

# Two failures seen from endpoints, neither of which a parse repair can fix:
#   1. Chat-template tokens leaking into the reply (<|end_header_id|>,
#      <|eot_id|>, a bare "assistant" line), seen from open-weight models on
#      a shared endpoint. Stripped before parsing; harmless otherwise.
#   2. The model echoing the prompt's example object, so every value is "...".
#      It parses as valid JSON and would reach the app as a segment named
#      "...". It is treated as a failed attempt, so it is retried.
clean_model_reply <- function(txt) {
  txt = gsub("<\\|[^|>]{1,40}\\|>", " ", txt, perl = TRUE)
  txt = gsub("(?m)^\\s*(assistant|user|system)\\s*$", "", txt, perl = TRUE)
  trimws(txt)
}

is_placeholder_reply <- function(obj) {
  vals = unlist(obj, use.names = FALSE)
  vals = vals[is.character(vals)]
  !length(vals) || all(trimws(vals) %in% c("", "...", "\u2026"))
}

llm_json <- function(prompt, role = "worker", system_prompt = NULL,
                     validate = NULL, pattern = "(?s)\\{.*\\}",
                     max_times = 3L, session_cap = 10L) {

  # A missing key is not a transient failure. Checked once, here, so it is
  #   reported at once instead of after three retries and a fallback model.
  llm_api_key()

  ask = paste0(prompt, "\n\n", JSON_QUOTE_RULE)

  attempt = function(model) {
    if (.llm_state$retries >= session_cap)
      stop("Session retry cap of ", session_cap, " reached. The prompt or the ",
           "endpoint needs attention; further attempts would spend quota ",
           "without diagnosing it.", call. = FALSE)
    .llm_state$calls <- .llm_state$calls + 1L
    raw = llm_complete(model, system_prompt, ask)
    # Which model and endpoint, and why the reply stopped, on every failure.
    # Put first, not last: R cuts long error messages short, and a
    #   degenerate reply is long, so a name at the end was lost.
    served = paste0("[", model, " via ", attr(raw, "provider"),
                    ", finish: ", attr(raw, "finish"), "] ")
    if (identical(attr(raw, "finish"), "length"))
      stop(served, "The reply reached the token limit without finishing, ",
           "which on these prompts means the model was repeating itself. ",
           "It starts: ", substr(raw, 1, 120), call. = FALSE)
    reply = clean_model_reply(raw)
    obj = tryCatch(parse_json_block(reply, pattern),
                   error = function(e)
                     stop(served, substr(conditionMessage(e), 1, 400),
                          call. = FALSE))
    if (is_placeholder_reply(obj))
      stop(served, "The model returned the example template instead of an ",
           "answer:\n", substr(reply, 1, 300), call. = FALSE)
    # Checked inside the attempt, so a reply that fails a check is asked for
    #   again like any other bad reply, rather than ending the call.
    if (!is.null(validate))
      tryCatch(validate(obj), error = function(e)
        stop(served, conditionMessage(root_cause(e)), call. = FALSE))
    obj
  }

  # insistently() reports only "Request failed after 3 attempts", so the last
  #   attempt's own error is kept: that is the reason the analyst needs.
  last = NULL
  logged = function(model)
    withCallingHandlers(attempt(model), error = function(e) last <<- e)

  before = .llm_state$calls
  # A client error (bad key, unknown model, bad request) is returned rather
  #   than raised inside the retry loop, so it is not sent three times.
  obj = try(
    purrr::insistently(function()
                         tryCatch(logged(llm_model(role)),
                                  llm_client_error = function(e) e),
                       rate = purrr::rate_backoff(pause_base = 2,
                                                  max_times = max_times),
                       quiet = FALSE)(),
    silent = TRUE)
  if (inherits(obj, "llm_client_error"))
    obj = structure(conditionMessage(obj), class = "try-error", condition = obj)
  .llm_state$retries <- .llm_state$retries +
    max(0L, .llm_state$calls - before - 1L)

  # One fallback attempt, for both roles. The failure this catches is an
  #   endpoint serving a model badly, which a different model does fix.
  if (inherits(obj, "try-error") && !is.null(WISE_LLM$pm_fallback)) {
    message("The ", role, " model failed; trying ", llm_model("pm_fallback"), ".")
    obj = try(logged(llm_model("pm_fallback")), silent = TRUE)
  }

  if (inherits(obj, "try-error"))
    stop(conditionMessage(last %||% attr(obj, "condition")), call. = FALSE)

  obj
}

# Validators are plain functions that stop with a readable message. Keeping
#   them out of the prompt means the app can say which field the model omitted
#   rather than showing a parse error.

# Every passage the app has a model write goes through here: the AI reflexes
#   as the system prompt (ai_reflexes_prompt(), ai_reflexes.R), the fields the
#   reply must carry, and its numbers checked against the request.
llm_write <- function(prompt, fields) {
  system = ai_reflexes_prompt()
  llm_json(prompt, role = "pm", system_prompt = system,
           validate = validate_all(validate_fields(fields),
                                   validate_numbers(paste(system, prompt))))
}

# Several checks as one: each must pass.
validate_all <- function(...) {
  checks = list(...)
  function(obj) purrr::walk(checks, function(check) check(obj))
}

# Numbers in a model's prose that are not in what it was given are the
#   commonest invention, so every number in the reply is looked for in the
#   evidence: the request and its instructions. It passes when the evidence
#   holds it at the precision written, or as a percentage of a proportion
#   (0.312 in a table may be written 31% or 31.2%). "At the precision written"
#   means within half a unit of the last digit, so 0.345 may be 35% or 34%:
#   round() would refuse one of them, since R rounds a half to even.
validate_numbers <- function(evidence) {
  num = "-?[0-9]+([.][0-9]+)?"
  ev = as.numeric(regmatches(evidence, gregexpr(num, evidence))[[1]])
  function(obj) {
    txt = paste(unlist(purrr::keep(obj, is.character)), collapse = " ")
    found = regmatches(txt, gregexpr(num, txt))[[1]]
    unknown = purrr::discard(found, function(s) {
      d = nchar(sub("^[^.]*[.]?", "", s))
      x = as.numeric(s)
      tol = 0.5 * 10^-d + 1e-9
      any(abs(ev - x) <= tol) || any(abs(100 * ev - x) <= tol)
    })
    if (length(unknown))
      stop("The draft cites numbers that are not in the figures it was given (",
           paste(unique(unknown), collapse = ", "), "), so it was not used.",
           call. = FALSE)
    invisible(TRUE)
  }
}

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


# ---- the key box -------------------------------------------------------

# On Start here, because every feature that drafts names or prose needs a key.

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
        "is not written into your results, and closing the tab discards it. ",
        "The analysis itself runs without a key -- you lose the drafted names ",
        "and the written sections, not the estimates."))))
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
    session$onSessionEnded(function() llm_clear_session_key(token))

    output$status <- renderUI({
      set()
      mine <- !is.null(llm_session_key())
      env <- llm_server_key_set()

      if (mine)
        tags$p(class = "text-success",
               "A key you supplied is in use for this session.")
      else if (env)
        tags$p(class = "text-muted",
               "Using the key configured on this machine. Paste your own ",
               "below to use it instead for this session.")
      else
        warn_box(tags$div(
          "No key is set, so the drafted names and written sections are ",
          "unavailable. Everything else works: the model still fits, the ",
          "estimates and their margins are unaffected, and the report is ",
          "written with generic names and no prose."))
    })
  })
}
