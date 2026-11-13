# inteRn.R -- an AI coding intern for RStudio, in one file.
#
# Set up once (in RStudio's console):  source("<path>/inteRn/install.R")
# Then use it in the console:          ask("...")   my_data %ask% "..."   open_intern()
#
# It sees the names, types and labels of your objects -- never their values --
#   and asks before running code or writing files. Settings are in the block
#   below; to change one without editing this file, create config.R next to it
#   with lines such as   INTERN_LLM$pm <- "claude-sonnet-5-5"
# The API key is read from the environment variable ANTHROPIC_API_KEY
#   (usethis::edit_r_environ()), never from a file in this folder.

local({
  # ---- 1. where am I ----------------------------------------------------
  # source() keeps the file name in its frame as `ofile`; RStudio's
  #   debugSource() as `fileName`. INTERN_HOME overrides both.
  home = Sys.getenv("INTERN_HOME")
  if (!nzchar(home)) {
    frames = rev(sys.frames())
    hit = Filter(function(f) exists("ofile", envir = f, inherits = FALSE) ||
                   exists("fileName", envir = f, inherits = FALSE), frames)
    # No %||% here: base R has it only from 4.4.
    file = if (length(hit))
      get0("ofile", envir = hit[[1]], inherits = FALSE,
           ifnotfound = get0("fileName", envir = hit[[1]], inherits = FALSE))
    if (is.null(file)) {
      message("inteRn: could not tell which folder inteRn.R is in. ",
              "Set INTERN_HOME in .Renviron to that folder.")
      return(invisible(NULL))
    }
    home = dirname(file)
  }
  home = normalizePath(home, winslash = "/", mustWork = FALSE)

  # ---- 2. packages ------------------------------------------------------
  need = c("ellmer", "purrr", "rlang")
  missing = need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    message("inteRn: not loaded. Install first: install.packages(c(\"",
            paste(missing, collapse = "\", \""), "\"))")
    return(invisible(NULL))
  }

  # ---- 3. everything else lives in one private environment ----------------
  # Parent is base, so every other function is written pkg::fn(): that keeps
  #   it working from .Rprofile, before utils and stats are attached.
  core = new.env(parent = baseenv())
  core$.home = home

  evalq({
    # ==== settings ============================================================

    INTERN_LLM <- list(
      # Anthropic's public API. At work, the server's base URL, ending where
      #   Anthropic's ends (the part before /messages).
      base_url = "https://api.anthropic.com/v1",
      # The name of the environment variable that holds the key -- not the key.
      key_var  = "ANTHROPIC_API_KEY",

      # The model IDs exactly as the endpoint names them. Check against
      #   ellmer::models_anthropic() or the work server's model list: a wrong ID
      #   fails every call with "model not found". Every reply, including lint
      #   rewrites, comes from this one model.
      pm          = "claude-sonnet-5",
      # Tried once after the main model fails with a server-side error. NULL for
      #   none.
      pm_fallback = NULL,

      # "server" reads key_var from the environment. "analyst" ignores the
      #   environment and asks for the key once per R session (kept in memory
      #   only, never written anywhere).
      key_source = "server",
      # Seconds to wait for one reply.
      timeout    = 120,

      # Ceiling for each reply, including the model's internal reasoning.
      #   Too low and a long answer is cut off before it is written.
      max_tokens  = 8000,
      # NULL sends no temperature. Recent Claude models refuse the setting
      #   ("temperature is deprecated for this model"); set a number only for a
      #   model that accepts one.
      temperature = NULL,

      # Prompt caching: the system prompt and tools are resent every turn, so a
      #   five-minute cache saves cost across a session. "1h", or "none" if the
      #   endpoint rejects cache instructions.
      cache = "5m",

      # The only folders read_file() and write_file() may touch. "." means the
      #   working directory at the time of the call (your current project), so
      #   it follows you from project to project.
      allow_dirs = c("."),

      # Any count below this is shown as "<n" and never sent to the model.
      suppress_n = 10,

      # The lint gate: R code in a reply is checked with lintr (no loops, no base
      #   graphics, colourblind-safe colours) and sent back for a rewrite up to
      #   lint_retries times before you see it. FALSE turns it off.
      lint = TRUE,
      lint_retries = 2)

    # config_load.R -- checks INTERN_LLM (config.R) and resolves its folders.
    # Function definitions and constants only.

    `%||%` <- function(x, y) if (is.null(x)) y else x

    # What the user sees after sourcing inteRn.R. Everything else stays private.
    INTERN_EXPORTS <- c("ask", "%ask%", "open_intern", "close_intern", "intern_reset",
                        "intern_config", "intern_help")

    # Per-session state: the conversation, a key typed in "analyst" mode, and the
    #   function that asks the user to approve a tool call. An environment, so a
    #   stray options() call cannot reset it.
    .state <- new.env(parent = emptyenv())

    is_string <- function(x) is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
    is_count  <- function(x) is.numeric(x) && length(x) == 1L && !is.na(x) && x >= 1

    # One check per field: a test and what to say when it fails.
    INTERN_CHECKS <- list(
      base_url    = list(is_string, "a URL in quotes"),
      key_var     = list(is_string, "the NAME of the environment variable holding the key"),
      pm          = list(is_string, "a model ID in quotes"),
      pm_fallback = list(function(x) is.null(x) || is_string(x), "NULL or a model ID"),
      key_source  = list(function(x) is_string(x) && x %in% c("server", "analyst"),
                         "\"server\" or \"analyst\""),
      timeout     = list(is_count, "a number of seconds"),
      max_tokens  = list(is_count, "a whole number"),
      temperature = list(function(x) is.null(x) || (is.numeric(x) && length(x) == 1L),
                         "NULL or a number"),
      cache       = list(function(x) is_string(x) && x %in% c("5m", "1h", "none"),
                         "\"5m\", \"1h\" or \"none\""),
      allow_dirs  = list(function(x) is.character(x) && length(x) >= 1L && all(nzchar(x)),
                         "one or more folder paths"),
      suppress_n  = list(is_count, "a whole number, 1 or more"),
      lint        = list(function(x) is.null(x) || isTRUE(x) || isFALSE(x), "TRUE or FALSE"),
      lint_retries = list(function(x) is.null(x) || (is.numeric(x) && length(x) == 1L && x >= 0),
                          "a whole number, 0 or more"))

    # Fields added after the first release: a config.R without them still works.
    INTERN_OPTIONAL <- c("pm_fallback", "temperature", "lint", "lint_retries")

    # Problems as sentences; character(0) when the config is usable.
    intern_config_problems <- function(cfg = get0("INTERN_LLM", inherits = TRUE)) {
      if (!is.list(cfg)) return("config.R must define a list called INTERN_LLM.")
      bad = purrr::imap(INTERN_CHECKS, function(chk, field) {
        if (!field %in% names(cfg) && !field %in% INTERN_OPTIONAL)
          return(paste0("`", field, "` is missing; it should be ", chk[[2]], "."))
        if (!chk[[1]](cfg[[field]]))
          return(paste0("`", field, "` should be ", chk[[2]], "."))
        NULL
      })
      # A key pasted where its variable name belongs would be sent to no one, but
      #   it would sit in a file that gets copied around.
      leak = if (is_string(cfg$key_var) && grepl("^(sk-|sk_|ghp_|Bearer )", cfg$key_var))
        "`key_var` looks like a key. Put the key in .Renviron and its variable name here."
      c(unlist(purrr::compact(bad), use.names = FALSE), leak)
    }

    intern_model <- function(role = "pm") {
      m = INTERN_LLM[[role]]
      if (!is_string(m)) stop("No model configured for role '", role, "' in config.R.",
                              call. = FALSE)
      m
    }

    # allow_dirs, resolved now: "." is whatever the working directory is at the
    #   time of the call.
    intern_allow_dirs <- function()
      unique(normalizePath(INTERN_LLM$allow_dirs, winslash = "/", mustWork = FALSE))

    # Whether a key would be found, without making a call or showing the key.
    intern_key_status <- function() {
      if (identical(INTERN_LLM$key_source, "analyst"))
        return(if (is.null(.state$key)) "asked for on first use (analyst mode)"
               else "typed this session (analyst mode)")
      if (nzchar(Sys.getenv(INTERN_LLM$key_var))) paste0(INTERN_LLM$key_var, " is set")
      else paste0(INTERN_LLM$key_var, " is NOT set: add it to .Renviron and restart R")
    }

    # Exported. The settings in use, with the key reported as set or not, never
    #   shown.
    intern_config <- function() {
      cfg = INTERN_LLM
      shown = purrr::imap_chr(cfg, function(v, k)
        sprintf("  %-12s %s", k, if (is.null(v)) "NULL" else paste(v, collapse = ", ")))
      problems = intern_config_problems(cfg)
      cat("inteRn settings", if (file.exists(file.path(.home, "config.R"))) " (with your config.R)", "\n",
          paste(shown, collapse = "\n"), "\n\n",
          "  key          ", intern_key_status(), "\n",
          "  may read and write in: ", paste(intern_allow_dirs(), collapse = "; "), "\n",
          if (length(problems)) paste0("\nProblems:\n", paste0("  - ", problems, collapse = "\n"), "\n"),
          sep = "")
      invisible(cfg)
    }

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

    # prompt.R -- the system prompt each conversation starts with.
    # Function definitions only.

    # system.md, without its HTML comments (notes for people) and its title.
    intern_system_prompt <- function(path = file.path(.home, "system.md")) {
      if (!file.exists(path)) stop("inteRn's system.md is missing: ", path, call. = FALSE)
      txt = paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
      txt = gsub("(?s)<!--.*?-->", "", txt, perl = TRUE)
      txt = sub("^\\s*# [^\n]*\n", "", txt)
      trimws(gsub("\n{3,}", "\n\n", txt))
    }

    # scrub.R -- removes credentials, personal paths and e-mail addresses from
    #   text before it can reach the model. Function definitions and constants
    #   only.

    # Credentials: replaced wherever they appear.
    SCRUB_SECRETS <- c(
      "sk-ant-[A-Za-z0-9_-]{8,}",                 # Anthropic
      "sk-[A-Za-z0-9_-]{20,}",                    # OpenAI-style
      "gh[pousr]_[A-Za-z0-9]{20,}",               # GitHub
      "AKIA[0-9A-Z]{16}",                         # AWS access key ID
      "xox[abprs]-[A-Za-z0-9-]{10,}",             # Slack
      "(?i)bearer\\s+[A-Za-z0-9._~+/=-]{8,}")      # Authorization headers

    # key = "value" style assignments: the name is kept, the value is not.
    SCRUB_ASSIGN <- paste0(
      "(?i)\\b([A-Za-z0-9_.]*(api[_.-]?key|token|secret|passw(or)?d|pwd|credential)",
      "[A-Za-z0-9_.]*)(\\s*(=|<-|:)\\s*)([\"'])[^\"'\\n]+\\6")

    # Paths that name a machine or a person.
    SCRUB_PATHS <- c(
      "(?i)\\b[a-z]:[\\\\/][^\"'\\s,)]*",          # C:\..., D:/...
      "\\\\\\\\[^\"'\\s,)]+",                     # \\server\share
      "/(home|Users)/[^\"'\\s,)]+",                # /home/me, /Users/me
      "~/[^\"'\\s,)]*")                            # ~/...

    SCRUB_EMAIL <- "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    # paths = FALSE for file contents the model may edit and write back: a path
    #   replaced by "<path>" there would be written into the user's file.
    scrub_text <- function(x, paths = TRUE) {
      x = paste(x, collapse = "\n")
      x = purrr::reduce(SCRUB_SECRETS, function(t, p) gsub(p, "<redacted>", t, perl = TRUE),
                        .init = x)
      x = gsub(SCRUB_ASSIGN, "\\1\\4\\6<redacted>\\6", x, perl = TRUE)
      x = gsub(SCRUB_EMAIL, "<email>", x, perl = TRUE)
      if (paths)
        x = purrr::reduce(SCRUB_PATHS, function(t, p) gsub(p, "<path>", t, perl = TRUE),
                          .init = x)
      x
    }

    # Whether text carries one of the placeholders scrub_text() writes. Used to
    #   refuse a write that would put "<redacted>" into a real file.
    has_scrub_marks <- function(x) grepl("<redacted>|<path>|<email>", paste(x, collapse = "\n"))

    # fs_guard.R -- which files the intern may read or write, and how a user
    #   approves a tool call. Function definitions and constants only.

    # Data files are never read, even inside allow_dirs: microdata does not go to
    #   the API. Code, Quarto, markdown and YAML are fine.
    INTERN_DATA_EXT <- c("csv", "tsv", "gz", "zip", "sav", "zsav", "por",
                         "dta", "sas7bdat", "xpt", "rds", "rda", "rdata", "parquet",
                         "feather", "arrow", "xlsx", "xlsm", "xlsb", "xls", "ods", "sqlite", "db", "sas7bcat",
                         "duckdb", "json", "jsonl", "ndjson", "dat",
                         # rendered reports can print rows of data
                         "html", "htm", "pdf", "docx")

    # Files that hold keys or history, never read or written.
    INTERN_SECRET_FILES <- c(".renviron", ".rprofile", ".env", ".rhistory",
                             ".netrc", ".git-credentials", "id_rsa", "id_ed25519")
    # ...and their copies (.Renviron.bak, .env.local) and key files by extension.
    is_secret_name <- function(name)
      name %in% INTERN_SECRET_FILES ||
        any(startsWith(name, paste0(INTERN_SECRET_FILES, "."))) ||
        tools::file_ext(name) %in% c("pem", "key", "p12", "pfx", "ppk")

    INTERN_MAX_READ <- 200 * 1024    # bytes

    on_windows <- function() identical(.Platform$OS.type, "windows")

    # The absolute form of a path whose parent folder exists. normalizePath()
    #   cannot be trusted on a file that does not exist yet, so the parent is
    #   resolved (which also resolves "..") and the file name put back.
    resolve_path <- function(path) {
      parent = dirname(path)
      if (!dir.exists(parent)) stop("The folder ", parent, " does not exist.", call. = FALSE)
      file.path(normalizePath(parent, winslash = "/", mustWork = TRUE), basename(path))
    }

    inside <- function(path, dirs) {
      norm = function(x) if (on_windows()) tolower(x) else x
      p = norm(path)
      any(purrr::map_lgl(norm(sub("/+$", "", dirs)), function(d) p == d || startsWith(p, paste0(d, "/"))))
    }

    # The resolved path if the intern may use it, else an error that says why.
    #   The reason goes back to the model, so it names no absolute path.
    intern_check_path <- function(path, mode = c("read", "write")) {
      mode = match.arg(mode)
      if (!is_string(path)) stop("No path given.", call. = FALSE)
      # Windows opens "data.csv.", "data.csv " and "data.csv::$DATA" as data.csv,
      #   so such names would slip past the checks below.
      if (on_windows() && grepl("[. ]$|:", basename(path)) &&
          !grepl("^([.]{1,2}|[A-Za-z]:)$", basename(path)))
        stop("'", basename(path), "' is not a usable file name (it ends in a dot or space, ",
             "or has a colon).", call. = FALSE)
      p = resolve_path(path)
      # The real name of an existing file, so a short name (RENVIR~1) is checked
      #   as .Renviron.
      if (file.exists(p)) p = normalizePath(p, winslash = "/", mustWork = TRUE)
      name = tolower(basename(p))
      if (!inside(p, intern_allow_dirs()))
        stop("'", basename(p), "' is outside the folders inteRn may use (allow_dirs in config.R).",
             call. = FALSE)
      if (is_secret_name(name) || grepl("/\\.git/", tolower(p)))
        stop("'", basename(p), "' may hold keys or history; inteRn does not touch it.",
             call. = FALSE)
      if (mode == "read" && tools::file_ext(name) %in% INTERN_DATA_EXT)
        stop("'", basename(p), "' looks like a data file. Data never goes to the model; ",
             "describe the object in R instead (describe_object).", call. = FALSE)
      p
    }

    # ---- approvals ---------------------------------------------------------

    # Every tool call that changes something asks first. The last choice is
    #   always the refusal, and it is what happens when nobody can be asked.

    # Ask, then carry on with then(choice). In a turn that started in the Viewer
    #   the question goes to the Viewer and this returns a promise: ellmer awaits
    #   a tool's promise, so the console stays free while the user decides. In a
    #   console turn (ask()) it asks in the console and returns the value.
    #   `show` prints the detail richly in the console (a coloured diff);
    #   `detail` is the plain text the Viewer shows.
    with_approval <- function(what, choices, then, detail = NULL, show = NULL) {
      if (identical(.state$channel, "viewer") && !is.null(.state$ws))
        return(promises::then(viewer_ask(what, choices, detail), then))
      if (is.function(show)) show() else if (length(detail)) cat("\n", detail, sep = "\n")
      then(intern_approve(what, choices))
    }

    # The console question. Tests swap in .state$approver.
    intern_approve <- function(what, choices = c("Yes", "No")) {
      approver = .state$approver %||% console_approver
      approver(what, choices)
    }

    # Non-interactive sessions (tests) refuse unless the option
    #   intern.auto_approve names one of the choices.
    console_approver <- function(what, choices) {
      refuse = choices[length(choices)]
      if (!interactive()) {
        auto = getOption("intern.auto_approve")
        return(if (is_string(auto) && auto %in% choices) auto else refuse)
      }
      cat("\n", what, "\n", sep = "")
      i = utils::menu(choices, title = "inteRn asks:")
      if (i == 0L) refuse else choices[i]
    }

    # ---- diffs -------------------------------------------------------------

    diff_banners <- function(label) list(tar.banner = paste(label, "(now)"),
                                         cur.banner = paste(label, "(proposed)"))

    # For the console: diffobj in colour if installed, else the new text.
    show_diff <- function(old, new, label) {
      if (requireNamespace("diffobj", quietly = TRUE)) {
        b = diff_banners(label)
        print(diffobj::diffChr(old, new, mode = "unified", pager = "off",
                               tar.banner = b$tar.banner, cur.banner = b$cur.banner))
      } else {
        cat(diff_text(old, new, label), sep = "\n")
      }
      invisible(NULL)
    }

    # For the Viewer: the same diff as plain lines.
    diff_text <- function(old, new, label) {
      if (!requireNamespace("diffobj", quietly = TRUE))
        return(c(paste("---", label, if (length(old)) "(replacing the current file)" else "(new file)"),
                 new))
      b = diff_banners(label)
      as.character(diffobj::diffChr(old, new, format = "raw", mode = "unified", pager = "off",
                                    tar.banner = b$tar.banner, cur.banner = b$cur.banner))
    }

    # metadata.R -- what the model may know about the R session.
    #
    # Two levels, and nothing beyond them reaches the API:
    #   describe_*  structure only: names, classes, dimensions, column types,
    #               variable labels, factor levels and value labels. No values.
    #   profile_*   aggregates: counts, shares, means and quartiles, as plain
    #               text, with every count below suppress_n shown as "<n" and
    #               one more cell suppressed so the small one cannot be worked
    #               out from the total. Minimum and maximum are never shown:
    #               each is one respondent's value.
    # Everything returned passes through scrub_text().
    # Function definitions and constants only.

    MAX_LEVELS <- 25L    # levels or labels listed per variable
    MAX_COLS   <- 300L   # columns described or profiled per data frame
    MAX_ITEMS  <- 50L    # elements listed for a list

    # ---- small pieces ------------------------------------------------------

    dims_text <- function(x)
      if (!is.null(dim(x))) paste(dim(x), collapse = " x ") else paste("length", length(x))

    type_of <- function(col) {
      if (inherits(col, "haven_labelled")) return(paste("labelled", typeof(unclass(col))))
      if (is.ordered(col)) return("ordered factor")
      if (is.factor(col)) return("factor")
      class(col)[1]
    }

    listed <- function(x, sep = " | ") {
      shown = utils::head(x, MAX_LEVELS)
      paste0(paste(shown, collapse = sep),
             if (length(x) > MAX_LEVELS) paste0(sep, "... (", length(x) - MAX_LEVELS, " more)"))
    }

    var_label <- function(col) {
      lab = attr(col, "label", exact = TRUE)
      if (is_string(lab)) lab else NULL
    }

    capped <- function(x, label) {
      if (ncol(x) <= MAX_COLS) return(list(x = x, note = NULL))
      list(x = x[seq_len(MAX_COLS)],
           note = paste0("(only the first ", MAX_COLS, " of ", ncol(x), " columns of `",
                         label, "` are listed)"))
    }

    # ---- describe: structure only ------------------------------------------

    # A factor made from free text (names, e-mails, open answers) rather than a
    #   codebook: most of the levels in use are rare. Its levels are not listed.
    is_free_text_factor <- function(col, k = INTERN_LLM$suppress_n) {
      n = as.integer(table(col))
      is.factor(col) && any(n > 0) && mean(n[n > 0] < k) > 0.5
    }

    factor_levels_text <- function(col, prefix = paste0(nlevels(col), " levels: "))
      if (is_free_text_factor(col))
        paste0(nlevels(col), " levels (not listed: most are rare, so they may be names or free text)")
      else paste0(prefix, listed(levels(col)))

    describe_column <- function(col, name) {
      labs = attr(col, "labels", exact = TRUE)
      paste(c(
        sprintf("- %s <%s>", name, type_of(col)),
        if (!is.null(var_label(col))) sprintf("label \"%s\"", var_label(col)),
        if (is.factor(col)) factor_levels_text(col),
        if (length(labs)) paste0("value labels: ",
                                 listed(paste0(unname(labs), "=", names(labs)), sep = ", "))),
        collapse = "; ")
    }

    describe_df <- function(x, label) {
      cp = capped(x, label)
      groups = if (inherits(x, "grouped_df"))
        setdiff(names(attr(x, "groups")), ".rows")
      c(sprintf("`%s`: %s, %s rows x %s columns%s", label, paste(class(x), collapse = "/"),
                nrow(x), ncol(x),
                if (length(groups)) paste0(", grouped by ", paste(groups, collapse = ", ")) else ""),
        unname(purrr::imap_chr(cp$x, describe_column)),
        cp$note)
    }

    # Strata and PSU counts are properties of the design, not of anyone in it,
    #   and a stratum with one PSU is the first thing a variance estimate needs
    #   to know about.
    describe_design <- function(x, label) {
      head_line = sprintf("`%s`: survey design (%s), %s rows",
                          label, paste(class(x), collapse = "/"), nrow(x$variables))
      call_line = if (is.call(x$call))
        paste("created by:", paste(deparse(x$call, width.cutoff = 200L), collapse = " "))
        else if (inherits(x, "tbl_svy")) "created by: srvyr"
      design_lines = if (inherits(x, "svyrep.design")) {
        c(paste0("replicate weights: type ", x$type %||% "unknown", ", ",
                 length(x$rscales), " replicates", if (isTRUE(x$mse)) ", mse = TRUE"))
      } else if (!is.null(x$strata) && !is.null(x$cluster)) {
        # A subset keeps the strata levels it no longer has (NA here).
        psu = tapply(x$cluster[[1]], x$strata[[1]], function(v) length(unique(v)))
        psu = psu[!is.na(psu)]
        c(paste0(length(psu), " strata, ", sum(psu), " PSUs at stage 1"),
          if (any(psu == 1L)) paste0(sum(psu == 1L), " strata have a single PSU ",
                                     "(see options(survey.lonely.psu))"))
      }
      c(head_line, call_line, design_lines,
        "its variables:", describe_df(x$variables, "variables")[-1])
    }

    describe_list <- function(x, label) {
      nm = names(x) %||% rep("", length(x))
      items = purrr::map2_chr(utils::head(x, MAX_ITEMS), utils::head(nm, MAX_ITEMS),
                              function(el, n) sprintf("  $%s <%s, %s>",
                                                      if (nzchar(n)) n else "?",
                                                      class(el)[1], dims_text(el)))
      fml = tryCatch(paste(deparse(stats::formula(x)), collapse = " "), error = function(e) NULL)
      c(sprintf("`%s`: %s, %s", label, paste(class(x), collapse = "/"), dims_text(x)),
        if (!is.null(fml)) paste("formula:", fml),
        items,
        if (length(x) > MAX_ITEMS) paste0("  ... (", length(x) - MAX_ITEMS, " more)"))
    }

    describe_atomic <- function(x, label)
      paste(c(sprintf("`%s`: %s, %s", label, type_of(x), dims_text(x)),
              if (!is.null(var_label(x))) sprintf("label \"%s\"", var_label(x)),
              if (is.factor(x)) factor_levels_text(x, "levels: ")),
            collapse = "; ")

    # Any value, described by structure. `label` is how the model will refer to it.
    describe_value <- function(x, label) {
      out = if (inherits(x, c("survey.design", "svyrep.design"))) describe_design(x, label)
        else if (is.data.frame(x)) describe_df(x, label)
        else if (is.function(x)) sprintf("`%s`: function(%s)", label,
                                         paste(names(formals(x)), collapse = ", "))
        else if (is.atomic(x) || is.null(x)) describe_atomic(x, label)
        else if (is.list(x)) describe_list(x, label)
        else sprintf("`%s`: %s", label, paste(class(x), collapse = "/"))
      scrub_text(out)
    }

    # An object by name: from the workspace, or one %ask% was given as an
    #   expression (palmerpenguins::penguins, a pipeline), pinned under its label
    #   for this conversation. NULL when there is none.
    find_object <- function(name, env = globalenv()) {
      if (!is_string(name)) return(NULL)
      if (exists(name, envir = env, inherits = FALSE))
        return(list(value = get(name, envir = env, inherits = FALSE)))
      if (name %in% names(.state$pinned)) return(list(value = .state$pinned[[name]]))
      NULL
    }

    describe_object <- function(name, env = globalenv()) {
      obj = find_object(name, env)
      if (is.null(obj))
        return(paste0("There is no object called `", name, "` in the workspace. ",
                      "Call env_summary to see what there is."))
      describe_value(obj$value, name)
    }

    # One line per object in the workspace.
    env_summary <- function(env = globalenv()) {
      nms = ls(env)
      if (!length(nms)) return("The workspace is empty.")
      lines = purrr::map_chr(nms, function(n) {
        x = get(n, envir = env, inherits = FALSE)
        sprintf("- %s <%s> %s", n, paste(class(x), collapse = "/"), dims_text(x))
      })
      scrub_text(c(paste0("Workspace objects (", length(nms), "):"), lines))
    }

    # ---- profile: suppressed aggregates ------------------------------------

    # Counts as text. Cells from 1 to k-1 become "<k". When exactly one cell in a
    #   variable is that small, the next-smallest nonzero cell is hidden too, so
    #   the small one cannot be recovered by subtraction from the total. That
    #   second cell is marked "suppressed", not "<k": it may be large, and saying
    #   "<k" would be false (a model read it literally in testing).
    suppress_counts <- function(n, k) {
      small = n > 0 & n < k
      others = which(!small & n > 0)
      extra = rep(FALSE, length(n))
      if (sum(small) == 1L && length(others))
        extra[others[which.min(n[others])]] = TRUE
      out = format(n, big.mark = ",", trim = TRUE)
      out[extra] = "suppressed"
      out[small] = paste0("<", k)
      out
    }

    is_hidden <- function(shown) startsWith(shown, "<") | shown == "suppressed"

    fmt_num <- function(x) format(signif(x, 4), big.mark = ",", scientific = FALSE, trim = TRUE)

    # A labelled column as a factor of its value labels, without needing haven.
    #   Values with no label are grouped as "(unlabelled value)".
    labelled_as_factor <- function(col) {
      labs = attr(col, "labels", exact = TRUE)
      v = unclass(col)
      out = names(labs)[match(v, labs)]
      out[is.na(out) & !is.na(v)] = "(unlabelled value)"
      factor(out, levels = unique(c(names(labs), if (any(out == "(unlabelled value)", na.rm = TRUE))
        "(unlabelled value)")))
    }

    # A frequency table. For character and numeric columns the text of a
    #   suppressed value is hidden as well as its count: a rare text value may be
    #   a name or a free-text answer, and a rare number may be the minimum or
    #   maximum. `n_miss_hidden` is a missing count shown as <k: it joins the
    #   suppression, or the shown counts would add up to it, and percentages are
    #   dropped, or they would give the number of valid values.
    #   Returns the text and whether any cell was hidden.
    profile_categorical <- function(values, n_valid, k, hide_rare_text, n_miss_hidden = 0L) {
      tab = table(values, useNA = "no")
      names(tab)[names(tab) == ""] = "(empty string)"
      n = as.integer(tab)
      shown = utils::head(suppress_counts(c(n, n_miss_hidden), k), length(n))
      sup = is_hidden(shown)
      cells = if (n_miss_hidden > 0) paste0(names(tab), " ", shown)
        else ifelse(sup, paste0(names(tab), " ", shown),
                    sprintf("%s %s (%.0f%%)", names(tab), shown, 100 * n / n_valid))
      if (hide_rare_text && any(sup))
        cells = c(cells[!sup], paste0(sum(sup), " other values, hidden (rare, or hidden to protect a rare one)"))
      structure(listed(cells, sep = "; "), hidden = any(sup))
    }

    # Inf and -Inf are left out of the summaries and their count is suppressed
    #   like any other.
    profile_numeric <- function(v, k) {
      n_inf = sum(is.infinite(v))
      inf_txt = if (n_inf == 0) "" else paste0("; ", if (n_inf < k) paste0("<", k) else n_inf,
                                               " values are Inf or -Inf (left out above)")
      v = v[is.finite(v)]
      if (length(v) < k) return(paste0("fewer than ", k, " finite values", inf_txt))
      q = stats::quantile(v, c(0.25, 0.5, 0.75), names = FALSE)
      paste0(sprintf("mean %s, sd %s, quartiles %s / %s / %s (min and max withheld)",
                     fmt_num(mean(v)), fmt_num(stats::sd(v)), fmt_num(q[1]), fmt_num(q[2]), fmt_num(q[3])),
             inf_txt)
    }

    profile_column <- function(col, name, k) {
      n_miss = sum(is.na(col))
      n_valid = length(col) - n_miss
      head_txt = sprintf("- %s <%s>%s: ", name, type_of(col),
                         if (!is.null(var_label(col))) sprintf(" \"%s\"", var_label(col)) else "")
      miss_txt = if (n_miss > 0 && n_miss < k) paste0("missing <", k)
                 else paste0(format(n_valid, big.mark = ","), " valid, ",
                             format(n_miss, big.mark = ","), " missing")
      if (n_valid < k)
        return(paste0(head_txt, "fewer than ", k, " valid values; nothing more shown."))

      v = col[!is.na(col)]
      m = if (n_miss > 0 && n_miss < k) n_miss else 0L
      body = if (inherits(col, "haven_labelled")) {
        profile_categorical(labelled_as_factor(v), n_valid, k, hide_rare_text = FALSE, m)
      } else if (is.factor(col) || is.logical(col)) {
        profile_categorical(v, n_valid, k, hide_rare_text = is_free_text_factor(col, k), m)
      } else if (is.numeric(col) && length(unique(v)) <= 10L) {
        # With a count hidden the mean is withheld: times the number of valid
        #   values it would give the count back. Quartiles are values many share.
        tab = profile_categorical(v, n_valid, k, hide_rare_text = TRUE, m)
        q = stats::quantile(as.numeric(v), c(0.25, 0.5, 0.75), names = FALSE, type = 1)
        if (isTRUE(attr(tab, "hidden")))
          paste0(tab, "; quartiles ", paste(fmt_num(q), collapse = " / "),
                 " (mean withheld: it would reveal a hidden count)")
        else paste0(tab, "; mean ", fmt_num(mean(v)))
      } else if (is.character(col) && length(unique(v)) <= MAX_LEVELS) {
        profile_categorical(v, n_valid, k, hide_rare_text = TRUE, m)
      } else if (is.numeric(col)) {
        profile_numeric(as.numeric(v), k)
      } else if (inherits(col, "difftime")) {
        paste0(profile_numeric(as.numeric(v), k), ", in ", units(col))
      } else if (inherits(col, c("Date", "POSIXt"))) {
        q = stats::quantile(as.numeric(v), c(0.05, 0.95), names = FALSE)
        o = if (inherits(col, "Date")) as.Date(q) else as.POSIXct(q, origin = "1970-01-01")
        paste0("middle 90% from ", format(o[1], "%Y-%m"), " to ", format(o[2], "%Y-%m"))
      } else if (is.character(col)) {
        paste0(format(length(unique(v)), big.mark = ","), " distinct values (not listed)")
      } else {
        "no summary for this type"
      }
      paste0(head_txt, miss_txt, ". ", as.vector(body))
    }

    # A data frame (or the variables of a survey design) as suppressed,
    #   unweighted aggregates in plain text.
    profile_value <- function(x, label, k = INTERN_LLM$suppress_n) {
      design = inherits(x, c("survey.design", "svyrep.design"))
      df = if (design) x$variables else x
      if (!is.data.frame(df))
        return(paste0("`", label, "` is not a data frame or survey design, so there is ",
                      "nothing to profile. describe_object shows its structure."))
      cp = capped(df, label)
      out = c(sprintf(paste0("Profile of `%s`: %s rows x %s columns. Counts are unweighted%s. ",
                             "Counts below %s are shown as <%s. A count shown as \"suppressed\" is hidden only so ",
                             "a small one cannot be worked out; it may be large. Minimum and maximum are never shown."),
                      label, nrow(df), ncol(df),
                      if (design) " (respondents, not population estimates)" else "", k, k),
              unname(purrr::imap_chr(cp$x, profile_column, k = k)),
              cp$note)
      scrub_text(out)
    }

    profile_object <- function(name, env = globalenv()) {
      obj = find_object(name, env)
      if (is.null(obj)) return(paste0("There is no object called `", name, "` in the workspace."))
      profile_value(obj$value, name)
    }

    # tools.R -- the tools the model may call, as ellmer::tool() definitions.
    #
    # Read-only tools return metadata or suppressed aggregates (metadata.R).
    #   Tools that change something -- write_file, run_code -- show the user what
    #   they will do and ask first (with_approval(), fs_guard.R), in the console
    #   or in the Viewer depending on where the turn started. A refusal goes back
    #   to the model as a plain result that says so, which works the same whether
    #   the tool returned a value or a promise.
    # Function definitions and constants only.

    MAX_SOURCE_LINES <- 400L
    MAX_SHARED_CHARS <- 4000L
    MAX_LIST_FILES   <- 200L

    # ---- function source ---------------------------------------------------

    get_function_source_tool <- function(name) {
      fn = tryCatch({
        if (grepl(":::?", name)) {
          parts = strsplit(name, ":::?")[[1]]
          get(parts[2], envir = asNamespace(parts[1]), inherits = FALSE)
        } else get(name, envir = globalenv(), mode = "function")
      }, error = function(e) NULL)
      if (!is.function(fn)) return(paste0("No function called `", name, "` was found."))
      src = deparse(fn, control = "useSource")
      scrub_text(c(utils::head(src, MAX_SOURCE_LINES),
                   if (length(src) > MAX_SOURCE_LINES)
                     paste0("# ... (", length(src) - MAX_SOURCE_LINES, " more lines)")))
    }

    # ---- files -------------------------------------------------------------

    list_files_tool <- function(dir = ".") {
      d = intern_check_path(file.path(dir, "."), "write")   # a folder: same rules as writing
      d = dirname(d)
      files = list.files(d, recursive = TRUE, all.files = FALSE)
      files = files[!grepl("(^|/)(\\.git|renv|\\.Rproj\\.user)/", files)]
      if (!length(files)) return("No files there.")
      c(paste0(length(files), " files", if (length(files) > MAX_LIST_FILES)
                 paste0(", first ", MAX_LIST_FILES, " shown"), ":"),
        utils::head(files, MAX_LIST_FILES)) |> paste(collapse = "\n")
    }

    # Credentials are scrubbed; paths are not, because the model may edit this
    #   text and write it back (see write_file_tool).
    read_file_tool <- function(path) {
      p = intern_check_path(path, "read")
      if (!file.exists(p)) return(paste0("There is no file '", path, "'."))
      if (file.size(p) > INTERN_MAX_READ)
        return(paste0("'", basename(p), "' is larger than ", INTERN_MAX_READ / 1024,
                      " KB; inteRn does not read files that size."))
      lines = readLines(p, warn = FALSE, encoding = "UTF-8")
      paste0("Contents of ", basename(p), ":\n", scrub_text(lines, paths = FALSE))
    }

    # Code written to a file meets the same rules as code in a reply: an R
    #   script is linted whole, a Quarto or R Markdown file chunk by chunk.
    #   NULL (write it) for other files, with the gate off, or if lintr fails.
    file_lint <- function(path, content) {
      ext = tolower(tools::file_ext(path))
      if (!ext %in% c("r", "qmd", "rmd") || !gate_on()) return(NULL)
      text = if (ext == "r") paste0("```r\n", content, "\n```") else content
      safe_lint(text)
    }

    write_file_tool <- function(path, content) {
      p = intern_check_path(path, "write")
      if (has_scrub_marks(content))
        return(paste("Not written: the content contains a <redacted>, <path> or <email>",
                     "placeholder, which would replace the real value in the file.",
                     "Leave those lines out or ask the user for the value."))
      problems = file_lint(p, content)
      if (length(problems) && nrow(problems))
        return(paste0("Not written: the R code did not pass the lint gate:\n",
                      paste0("- line ", problems$line, ": ", problems$message, collapse = "\n"),
                      "\nFix it and call write_file again."))
      new = strsplit(content, "\r?\n")[[1]]
      old = if (file.exists(p)) readLines(p, warn = FALSE, encoding = "UTF-8") else character(0)
      with_approval(
        paste0("inteRn wants to ", if (length(old)) "change " else "create ", basename(p), "."),
        c("Write it", "Don't write it"),
        detail = diff_text(old, new, basename(p)),
        show = function() show_diff(old, new, basename(p)),
        then = function(choice) {
          if (!identical(choice, "Write it"))
            return(REFUSED("write this file"))
          con = file(p, open = "w", encoding = "UTF-8")
          on.exit(close(con), add = TRUE)
          writeLines(new, con)
          sprintf("Wrote %s (%d lines).", basename(p), length(new))
        })
    }

    # What the model is told when the user says no.
    REFUSED <- function(what, instead = "ask what they would like instead.")
      paste0("The user chose not to ", what, ". Do not try again in another way; ", instead)

    # ---- running code ------------------------------------------------------

    # Class and shape of every workspace object, to report what code changed
    #   without looking at values.
    workspace_shape <- function(env = globalenv())
      purrr::map_chr(rlang::set_names(ls(env)), function(n) {
        x = get(n, envir = env, inherits = FALSE)
        paste0("<", class(x)[1], "> ", dims_text(x))
      })

    shape_changes <- function(before, after) {
      new = setdiff(names(after), names(before))
      gone = setdiff(names(before), names(after))
      both = intersect(names(before), names(after))
      moved = both[before[both] != after[both]]
      c(if (length(new)) paste0("Created: ", paste(new, after[new], collapse = "; ")),
        if (length(gone)) paste0("Removed: ", paste(gone, collapse = ", ")),
        if (length(moved)) paste0("Changed shape: ", paste(moved, after[moved], collapse = "; ")))
    }

    # The user sees the output. The model sees whether it ran, the error, any
    #   warnings, and what objects appeared or changed shape -- and the output
    #   itself only if the user chose to share it.
    run_code_tool <- function(code) {
      exprs = tryCatch(parse(text = code, keep.source = FALSE), error = function(e) e)
      if (inherits(exprs, "error"))
        return(paste("The code does not parse:", scrub_text(conditionMessage(exprs))))
      share = RUN_SHARE
      with_approval("inteRn wants to run this in your session:",
                    c("Run", share, "Don't run"), detail = code,
                    then = function(choice) {
                      if (!choice %in% c("Run", share))
                        return(REFUSED("run this code", paste(
                          "if they asked for code, give it in your reply as a code block",
                          "for them to run themselves.")))
                      run_approved(exprs, share = identical(choice, share))
                    })
    }

    RUN_SHARE <- "Run and share the output with inteRn"

    run_approved <- function(exprs, share) {
      before = workspace_shape()
      warns = character(0)
      res = NULL
      out = utils::capture.output(
        res <- tryCatch(
          withCallingHandlers({
            source(exprs = exprs, local = globalenv(), echo = FALSE, print.eval = TRUE)
            NULL
          }, warning = function(w) {
            warns <<- c(warns, conditionMessage(w))
            invokeRestart("muffleWarning")
          }),
          error = function(e) e))
      if (length(out)) cat(out, sep = "\n")
      if (length(warns)) message("Warnings:\n", paste0("  ", warns, collapse = "\n"))
      # The user sees the output in the Viewer too. It stays on this machine:
      #   the page is served from 127.0.0.1 and nothing here goes to the model.
      if (identical(.state$channel, "viewer"))
        viewer_send(list(type = "output",
                         text = paste(c(out, if (length(warns)) paste("Warning:", warns),
                                        if (inherits(res, "error")) paste("Error:", conditionMessage(res))),
                                      collapse = "\n")))

      status = if (inherits(res, "error"))
        paste("Error:", substr(scrub_text(conditionMessage(res)), 1, 300))
      else "Ran without error."
      paste(c(
        status,
        if (length(warns)) paste0(length(warns), " warning(s): ",
                                  substr(scrub_text(utils::head(warns, 3)), 1, 300)),
        shape_changes(before, workspace_shape()),
        if (share)
          paste0("Output, shared by the user:\n",
                 substr(scrub_text(out), 1, MAX_SHARED_CHARS))
        else "The printed output was shown to the user and not shared with you."),
        collapse = "\n")
    }

    # ---- registry ----------------------------------------------------------

    # Errors become the tool's result, so the model reads why (a refused data
    #   file, a missing folder) and the user's console shows no ellmer warning.
    #   The wrapper keeps f's arguments: ellmer checks them against the tool's.
    tool_text <- function(f) {
      g = function() tryCatch(do.call(f, mget(names(formals(f)), environment())),
                              error = function(e) paste("Not done:", scrub_text(conditionMessage(e))))
      formals(g) = formals(f)
      g
    }

    intern_tools <- function() list(
      ellmer::tool(
        function() env_summary(),
        name = "env_summary",
        description = paste("List the objects in the user's R workspace with their class and",
                            "dimensions. No values."),
        arguments = list()),
      ellmer::tool(
        function(name) describe_object(name),
        name = "describe_object",
        description = paste("Structure of one workspace object: class, dimensions, column names",
                            "and types, variable labels, factor levels and value labels; for a",
                            "survey design, its call, strata and PSU counts. No values."),
        arguments = list(name = ellmer::type_string("Name of the object in the workspace."))),
      ellmer::tool(
        function(name) profile_object(name),
        name = "profile_object",
        description = paste("Unweighted aggregates for each column of a data frame or survey",
                            "design: valid and missing counts, frequency tables, mean, sd and",
                            "quartiles. Small counts are suppressed; min and max are never shown."),
        arguments = list(name = ellmer::type_string("Name of the data frame or design."))),
      ellmer::tool(
        tool_text(function(name) get_function_source_tool(name)),
        name = "get_function_source",
        description = paste("Source code of a function in the session, or of a package function",
                            "written pkg::fn. Credentials and paths are removed."),
        arguments = list(name = ellmer::type_string("Function name, or pkg::fn."))),
      ellmer::tool(
        tool_text(function(dir = ".") list_files_tool(dir)),
        name = "list_files",
        description = "File names (not contents) in an allowed folder, recursively.",
        arguments = list(dir = ellmer::type_string(
          "Folder, relative to the working directory. Default '.'.", required = FALSE))),
      ellmer::tool(
        tool_text(function(path) read_file_tool(path)),
        name = "read_file",
        description = paste("Read a code or text file (R, Quarto, markdown, YAML) in an allowed",
                            "folder. Data files are refused."),
        arguments = list(path = ellmer::type_string("File path, relative to the working directory."))),
      ellmer::tool(
        tool_text(function(path, content) write_file_tool(path, content)),
        name = "write_file",
        description = paste("Create or replace a file in an allowed folder with the full new",
                            "content. The user sees a diff and must approve."),
        arguments = list(
          path = ellmer::type_string("File path, relative to the working directory."),
          content = ellmer::type_string("The complete new file content."))),
      ellmer::tool(
        function(code) run_code_tool(code),
        name = "run_code",
        description = paste("Run R code in the user's global environment after they approve it.",
                            "Only when the user asks you to run something or you need the result",
                            "to answer; when they ask you to write or show code, put it in your",
                            "reply instead. You get back success or the error and which objects",
                            "changed; the printed output only if the user shares it."),
        arguments = list(code = ellmer::type_string("R code to run."))))

    # ask.R -- asking from the console: ask() and the %ask% pipe.
    # Function definitions only.

    # Exported. One question in the session's ongoing conversation. Blocks the
    #   console while the model replies; tools it calls run here and ask for
    #   approval in the console. new = TRUE starts a fresh conversation first.
    ask <- function(prompt, new = FALSE) {
      if (!is_string(prompt)) stop("ask() takes one question as a string.", call. = FALSE)
      if (isTRUE(.state$busy))
        stop("inteRn is still answering in the Viewer; wait for it to finish.", call. = FALSE)
      if (isTRUE(new)) intern_reset()
      .state$channel = "console"
      on.exit(.state$channel <- NULL, add = TRUE)
      reply = intern_send(prompt)
      if (is.null(reply)) return(invisible(NULL))
      out = structure(reply, class = "intern_reply")
      print(out)
      invisible(out)
    }

    # Exported. obj %ask% "question" sends the object's structure (never its
    #   values) with the question. %ask% binds tighter than |>, so put a pipeline
    #   in parentheses: (df |> filter(x > 1)) %ask% "...".
    `%ask%` <- function(x, prompt) {
      label = paste(deparse(substitute(x), width.cutoff = 60L), collapse = " ")
      if (nchar(label) > 80L) label = paste0(substr(label, 1, 77), "...")
      # Not a workspace object (a pkg::data reference, a pipeline): keep the
      #   value for this conversation, so describe_object and profile_object can
      #   reach it by its label instead of the model guessing.
      if (!exists(label, envir = globalenv(), inherits = FALSE))
        .state$pinned[[label]] = x
      meta = describe_value(x, label)
      ask(paste0("This question is about `", label, "`. Its structure (no values):\n\n",
                 meta, "\n\nThe tools describe_object and profile_object accept the name `",
                 label, "`.\n\nQuestion: ", prompt))
    }

    print.intern_reply <- function(x, ...) {
      cat("\n", unclass(x), "\n\n", sep = "")
      invisible(x)
    }

    # viewer.R -- the chat in the RStudio Viewer, without blocking the console.
    #
    # How it stays out of the way:
    #   - httpuv serves the page and a websocket from 127.0.0.1. httpuv does its
    #     networking on a background thread and hands requests to R through the
    #     later event loop, which runs whenever the console is idle.
    #   - A question is sent with chat_async(). While the model is thinking the
    #     console is free. Tools run in this R session between API calls, so they
    #     see the same workspace as the console; approvals appear in the Viewer
    #     and ellmer waits on them as promises.
    #   - Shiny is not used: runApp() blocks the console, and shinychat needs a
    #     Shiny session.
    #
    # The page and the socket need a random token, so another program or a web
    #   page on this machine cannot drive the intern or answer its approvals.
    #   Model replies are rendered from markdown and then cut down to a short list
    #   of tags and attributes, so a reply cannot inject script into the page.
    # Function definitions and constants only.

    # ---- opening and closing -----------------------------------------------

    # Exported. Open (or reopen) the chat. launch = FALSE starts the server and
    #   returns the URL without showing it.
    open_intern <- function(launch = TRUE) {
      for_pkgs = c("httpuv", "promises", "later", "jsonlite", "commonmark")
      missing = for_pkgs[!purrr::map_lgl(for_pkgs, requireNamespace, quietly = TRUE)]
      if (length(missing))
        stop("open_intern() needs: install.packages(c(\"", paste(missing, collapse = "\", \""),
             "\"))", call. = FALSE)
      if (is.null(.state$server)) {
        .state$token = new_token()
        .state$port = keep_rng(httpuv::randomPort(host = "127.0.0.1"))
        .state$server = httpuv::startServer("127.0.0.1", .state$port, viewer_app())
        .state$transcript = list()
        .state$pending = list()
      }
      url = sprintf("http://127.0.0.1:%s/?t=%s", .state$port, .state$token)
      if (isTRUE(launch)) {
        if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
          rstudioapi::viewer(url)
        else utils::browseURL(url)
      }
      invisible(url)
    }

    # Runs expr without touching the user's random-number stream, so opening the
    #   Viewer never changes the results of a seeded analysis.
    keep_rng <- function(expr) {
      had = exists(".Random.seed", envir = globalenv(), inherits = FALSE)
      old = if (had) get(".Random.seed", envir = globalenv(), inherits = FALSE)
      on.exit(if (had) assign(".Random.seed", old, envir = globalenv())
              else if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
                rm(".Random.seed", envir = globalenv()), add = TRUE)
      expr
    }

    # The access token. From the system's secure random source (openssl, which
    #   ellmer already needs), never from R's generator: after set.seed() that
    #   would give the same token every time.
    new_token <- function() {
      if (requireNamespace("openssl", quietly = TRUE))
        return(paste(as.character(openssl::rand_bytes(16)), collapse = ""))
      keep_rng({
        set.seed(NULL)
        paste(sample(c(0:9, letters[1:6]), 32, replace = TRUE), collapse = "")
      })
    }

    # Exported. Stop the server. The conversation is kept for ask() and the next
    #   open_intern().
    close_intern <- function() {
      if (!is.null(.state$server)) httpuv::stopServer(.state$server)
      refuse_pending()
      .state$server = NULL
      .state$ws = NULL
      .state$busy = FALSE
      .state$channel = NULL
      invisible(NULL)
    }

    # ---- HTTP and websocket ------------------------------------------------

    VIEWER_FILES <- c("/chat.js" = "application/javascript; charset=utf-8",
                      "/chat.css" = "text/css; charset=utf-8")

    query_token <- function(q) {
      m = regmatches(q %||% "", regexpr("(?<=[?&]t=)[0-9a-f]+", q %||% "", perl = TRUE))
      if (length(m)) m else ""
    }

    http_response <- function(status, type, body)
      list(status = status, headers = list("Content-Type" = type, "Cache-Control" = "no-store"),
           body = body)

    viewer_page <- function() {
      html = paste(readLines(file.path(.home, "www", "index.html"), encoding = "UTF-8",
                             warn = FALSE), collapse = "\n")
      sub("{{TOKEN}}", .state$token, html, fixed = TRUE)
    }

    viewer_app <- function() list(
      call = function(req) {
        path = req$PATH_INFO
        if (identical(path, "/")) {
          if (!identical(query_token(req$QUERY_STRING), .state$token))
            return(http_response(403L, "text/plain", "Open inteRn with open_intern()."))
          return(http_response(200L, "text/html; charset=utf-8", viewer_page()))
        }
        if (path %in% names(VIEWER_FILES)) {
          f = file.path(.home, "www", sub("^/", "", path))
          return(http_response(200L, VIEWER_FILES[[path]],
                               paste(readLines(f, encoding = "UTF-8", warn = FALSE),
                                     collapse = "\n")))
        }
        http_response(404L, "text/plain", "Not found")
      },
      onWSOpen = function(ws) {
        if (!identical(query_token(ws$request$QUERY_STRING), .state$token)) {
          ws$close()
          return(invisible(NULL))
        }
        # One page at a time: a reopened Viewer replaces the old connection.
        if (!is.null(.state$ws) && !identical(.state$ws, ws))
          tryCatch(.state$ws$close(), error = function(e) NULL)
        .state$ws = ws
        ws$onMessage(function(binary, msg) viewer_handle(msg))
        ws$onClose(function() {
          if (identical(.state$ws, ws)) {
            .state$ws = NULL
            refuse_pending()
          }
        })
      })

    # Messages to the page. Kept in a transcript (capped) so a reloaded Viewer
    #   can show the conversation again.
    VIEWER_KEEP <- c("user", "assistant", "tool", "output", "error", "note")
    MAX_TRANSCRIPT <- 300L

    viewer_send <- function(msg) {
      if (msg$type %in% VIEWER_KEEP)
        .state$transcript = utils::tail(c(.state$transcript, list(msg)), MAX_TRANSCRIPT)
      ws = .state$ws
      if (!is.null(ws))
        tryCatch(ws$send(jsonlite::toJSON(msg, auto_unbox = TRUE, null = "null")),
                 error = function(e) NULL)
      invisible(NULL)
    }

    # Every message from the page. Errors are reported in the page, never left
    #   to kill the server.
    viewer_handle <- function(raw) {
      tryCatch({
        m = jsonlite::fromJSON(raw, simplifyVector = FALSE)
        switch(m$type %||% "",
          hello   = viewer_hello(),
          user    = viewer_turn(m$text),
          approve = viewer_answer(m$id, m$choice),
          reset   = viewer_reset(),
          insert  = viewer_to_rstudio(m$code, "insert"),
          console = viewer_to_rstudio(m$code, "console"),
          NULL)
      }, error = function(e)
        viewer_send(list(type = "error", text = conditionMessage(e))))
      invisible(NULL)
    }

    viewer_hello <- function() {
      ws = .state$ws
      if (is.null(ws)) return(invisible(NULL))
      ws$send(jsonlite::toJSON(list(type = "replay", items = .state$transcript,
                                    busy = isTRUE(.state$busy), model = INTERN_LLM$pm),
                               auto_unbox = TRUE, null = "null"))
    }

    viewer_reset <- function() {
      if (isTRUE(.state$busy))
        return(viewer_send(list(type = "error",
                                text = "Wait for the current answer before starting over.")))
      .state$chat = NULL
      .state$pinned = list()
      .state$transcript = list()
      viewer_send(list(type = "cleared"))
    }

    # Code blocks in a reply can go to the editor (at the cursor) or to the
    #   console without running, so the user presses Enter themselves.
    viewer_to_rstudio <- function(code, where) {
      if (!is_string(code)) return(invisible(NULL))
      if (!requireNamespace("rstudioapi", quietly = TRUE) || !rstudioapi::isAvailable())
        return(viewer_send(list(type = "note", text = "That button needs RStudio.")))
      if (identical(where, "insert")) rstudioapi::insertText(text = code)
      else rstudioapi::sendToConsole(code, execute = FALSE)
      invisible(NULL)
    }

    # ---- one turn ------------------------------------------------------------

    viewer_turn <- function(text) {
      if (!is_string(text)) return(invisible(NULL))
      if (isTRUE(.state$busy))
        return(viewer_send(list(type = "error", text = "Still answering the last question.")))
      viewer_send(list(type = "user", text = text))
      chat = tryCatch(intern_get_chat(), error = function(e) e)
      if (inherits(chat, "error"))
        return(viewer_send(list(type = "error", text = conditionMessage(chat))))
      viewer_hook(chat)

      .state$busy = TRUE
      .state$channel = "viewer"
      viewer_send(list(type = "busy", value = TRUE))
      done = function() {
        .state$busy = FALSE
        .state$channel = NULL
        viewer_send(list(type = "busy", value = FALSE))
      }
      p = tryCatch(intern_send_async(text, chat), error = function(e) promises::promise_reject(e))
      p |>
        promises::then(
          onFulfilled = function(reply)
            viewer_send(list(type = "assistant", html = render_reply(reply))),
          onRejected = function(e)
            viewer_send(list(type = "error", text = conditionMessage(e)))) |>
        promises::finally(done)
      invisible(NULL)
    }

    # Tool calls show as a line in the page while they run. Registered once per
    #   conversation object.
    viewer_hook <- function(chat) {
      if (identical(.state$hooked, chat) || !is.function(chat$on_tool_request)) return(invisible())
      chat$on_tool_request(function(request) {
        if (!identical(.state$channel, "viewer")) return(invisible())
        args = tryCatch(request@arguments, error = function(e) list())
        shown = purrr::imap_chr(args, function(v, k)
          paste0(k, " = ", substr(paste(format(v), collapse = " "), 1, 60)))
        viewer_send(list(type = "tool",
                         text = paste0(tryCatch(request@name, error = function(e) "tool"),
                                       "(", paste(shown, collapse = ", "), ")")))
      })
      .state$hooked = chat
      invisible()
    }

    # ---- approvals in the page -----------------------------------------------

    # A promise for the user's choice. The page shows the question, the detail
    #   (code or a diff) and one button per choice. An answer that is not one of
    #   the choices, or a page closed before answering, counts as the refusal
    #   (the last choice).
    viewer_ask <- function(what, choices, detail = NULL) {
      promises::promise(function(resolve, reject) {
        .state$approval_n = (.state$approval_n %||% 0L) + 1L
        id = paste0("a", .state$approval_n)
        .state$pending[[id]] = function(choice)
          resolve(if (is_string(choice) && choice %in% choices) choice else choices[length(choices)])
        viewer_send(list(type = "approval", id = id, title = what,
                         detail = paste(detail %||% "", collapse = "\n"),
                         choices = as.list(choices)))
      })
    }

    viewer_answer <- function(id, choice) {
      f = .state$pending[[id %||% ""]]
      if (is.null(f)) return(invisible(NULL))
      .state$pending[[id]] = NULL
      f(choice)
    }

    refuse_pending <- function() {
      pend = .state$pending %||% list()
      .state$pending = list()
      purrr::walk(pend, function(f) f(NA_character_))
    }

    # ---- rendering a reply ---------------------------------------------------

    # Markdown to HTML, then everything but a short list of tags removed.
    #   commonmark escapes "<" in text, so every "<" left in its output is a tag:
    #   either one commonmark wrote, or raw HTML the model put in the reply.
    SAFE_TAGS <- c("p", "pre", "code", "em", "strong", "del", "ul", "ol", "li", "blockquote",
                   "h1", "h2", "h3", "h4", "h5", "h6", "a", "table", "thead", "tbody", "tr",
                   "th", "td", "hr", "br", "sup", "sub")

    safe_attrs <- function(tag, attrs) {
      keep = function(pattern) {
        m = regmatches(attrs, regexpr(pattern, attrs, perl = TRUE))
        if (length(m)) paste0(" ", m) else ""
      }
      switch(tag,
        code = keep("class=\"language-[A-Za-z0-9_+-]+\""),
        a = {
          href = keep("href=\"https?://[^\"]*\"")
          if (nzchar(href)) paste0(href, " target=\"_blank\" rel=\"noopener noreferrer\"") else ""
        },
        th = , td = keep("align=\"(left|right|center)\""),
        ol = keep("start=\"[0-9]+\""),
        "")
    }

    sanitize_html <- function(html) {
      pattern = "<(/?)([A-Za-z][A-Za-z0-9]*)([^>]*)>"
      tags = gregexpr(pattern, html, perl = TRUE)
      regmatches(html, tags) = list(purrr::map_chr(regmatches(html, tags)[[1]], function(t) {
        parts = regmatches(t, regexec(pattern, t, perl = TRUE))[[1]]
        name = tolower(parts[3])
        if (!name %in% SAFE_TAGS) return(gsub("<", "&lt;", gsub(">", "&gt;", t, fixed = TRUE), fixed = TRUE))
        if (nzchar(parts[2])) return(paste0("</", name, ">"))
        paste0("<", name, safe_attrs(name, parts[4]), ">")
      }))
      html
    }

    render_reply <- function(text)
      sanitize_html(commonmark::markdown_html(text, extensions = TRUE))

    # lint_gate.R -- R code in a reply passes lintr before the user sees it.
    #
    # Every ```r block in a reply is linted with the custom linters below (no
    #   loops, no base graphics, colourblind-safe colours) plus two correctness
    #   checks. On failure the problems go back to the model in the same
    #   conversation and it rewrites the reply, at most lint_retries times
    #   (config.R, default 2). Whatever still fails is shown with a note listing
    #   the problems, never silently. Blocks that pass and were not run with
    #   run_code get "# UNTESTED" as their first line if the model left it off.
    #
    # Skipped, with one message per session, when lintr is not installed.
    # Function definitions and constants only.

    # ---- linters -----------------------------------------------------------

    BASE_GRAPHICS <- c("plot", "hist", "barplot", "pie", "boxplot", "dotchart", "matplot",
                       "stripchart", "mosaicplot", "svyhist", "svyboxplot", "svyplot")
    UNSAFE_PALETTES <- c("rainbow", "heat.colors", "terrain.colors", "topo.colors", "cm.colors")
    OKABE_ITO_SET <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
                       "#CC79A7", "#000000", "#FFFFFF")

    xpath_calls <- function(fns)
      paste0("//SYMBOL_FUNCTION_CALL[", paste0("text() = '", fns, "'", collapse = " or "), "]")

    no_loop_linter <- function()
      lintr::make_linter_from_xpath(
        "//FOR | //WHILE | //REPEAT",
        "No for, while or repeat loops: use purrr (map(), walk(), reduce()) or a vectorised function.",
        type = "warning")()

    no_base_graphics_linter <- function()
      lintr::make_linter_from_xpath(
        xpath_calls(BASE_GRAPHICS),
        "No base graphics: use ggplot2.",
        type = "warning")()

    # Unsafe palette functions, and hex colours that are neither Okabe-Ito nor
    #   from a viridis map.
    palette_linter <- function() lintr::Linter(function(source_expression) {
      xml = source_expression$xml_parsed_content
      if (is.null(xml)) return(list())
      bad_fun = xml2::xml_find_all(xml, xpath_calls(UNSAFE_PALETTES))
      strs = xml2::xml_find_all(xml, "//STR_CONST")
      vals = toupper(gsub("^[\"']|[\"']$", "", xml2::xml_text(strs)))
      hex = grepl("^#[0-9A-F]{6}([0-9A-F]{2})?$", vals)
      unsafe = hex
      unsafe[hex] = !safe_hex(substr(vals[hex], 1, 7))
      c(lintr::xml_nodes_to_lints(bad_fun, source_expression,
                                  "Not colourblind-safe: use Okabe-Ito or a viridis scale.", type = "warning"),
        lintr::xml_nodes_to_lints(strs[unsafe], source_expression,
                                  "Colour is not Okabe-Ito or viridis; pick a colourblind-safe one.",
                                  type = "warning"))
    }, linter_level = "expression")

    # Okabe-Ito, white, or within 3 per channel of a viridis-family colour.
    safe_hex <- function(hex) {
      if (!length(hex)) return(logical(0))
      fam = .state$viridis_rgb
      if (is.null(fam)) {
        opts = c("A", "B", "C", "D", "E", "F", "G")       # not "H", turbo: a rainbow
        fam = grDevices::col2rgb(unlist(purrr::map(opts, function(o)
          substr(viridisLite::viridis(256, option = o), 1, 7))))
        .state$viridis_rgb = fam
      }
      purrr::map_lgl(hex, function(h)
        h %in% OKABE_ITO_SET ||
          any(colSums(abs(fam - as.vector(grDevices::col2rgb(h))) <= 3) == 3))
    }

    intern_linters <- function() list(
      no_loop = no_loop_linter(),
      no_base_graphics = no_base_graphics_linter(),
      palette = palette_linter(),
      equals_na = lintr::equals_na_linter(),
      T_and_F_symbol = lintr::T_and_F_symbol_linter())

    # ---- finding and checking code ---------------------------------------------

    CODE_BLOCK <- "(?s)```\\{?[rR]\\}?[^\\n]*\\n(.*?)```"

    code_blocks <- function(text) {
      text = paste(text, collapse = "\n")          # also copes with character(0)
      m = regmatches(text, gregexpr(CODE_BLOCK, text, perl = TRUE))[[1]]
      sub(CODE_BLOCK, "\\1", m, perl = TRUE)
    }

    # A block shown on purpose as what not to do starts with "# BAD EXAMPLE".
    #   It is neither linted nor marked UNTESTED; the marker keeps it visible to
    #   the reader.
    is_bad_example <- function(code) grepl("^\\s*#\\s*BAD EXAMPLE", code)

    # One row per problem across the reply's code blocks. `# nolint` comments
    #   are removed first: the model may not switch the gate off for real code.
    lint_reply <- function(text) {
      blocks = code_blocks(text)
      if (!length(blocks)) return(data.frame(block = integer(), line = integer(), message = character()))
      rows = purrr::imap(blocks, function(code, i) {
        if (is_bad_example(code)) return(NULL)
        code = gsub("#\\s*nolint[^\n]*", "", code, perl = TRUE)
        res = as.data.frame(lintr::lint(text = paste0(code, "\n"), linters = intern_linters()))
        if (!nrow(res)) return(NULL)
        data.frame(block = i, line = res$line_number, message = res$message)
      })
      out = do.call(rbind, purrr::compact(rows))
      if (is.null(out)) data.frame(block = integer(), line = integer(), message = character()) else out
    }

    lint_feedback <- function(problems)
      paste0("The R code in your reply did not pass the lint gate:\n",
             paste0("- code block ", problems$block, ", line ", problems$line, ": ",
                    problems$message, collapse = "\n"),
             "\n\nRewrite your whole reply with corrected code. Keep everything else the same, ",
             "and do not mention this check.")

    norm_code <- function(x) gsub("\\s+", " ", trimws(x))

    # Code the model ran this turn with run_code, so those blocks are not
    #   marked UNTESTED.
    ran_this_turn <- function(chat, n_before) {
      turns = chat$get_turns()
      new = if (length(turns) > n_before) turns[seq.int(n_before + 1, length(turns))] else list()
      calls = purrr::list_flatten(purrr::map(new, function(t)
        purrr::keep(t@contents, function(x) inherits(x, "ellmer::ContentToolRequest") &&
                      identical(x@name, "run_code"))))
      purrr::map_chr(calls, function(x) norm_code(x@arguments$code %||% ""))
    }

    # "# UNTESTED" as the first line of every block that lacks it and was not run.
    #   The marker gets the fence's indentation, so a block inside a list item
    #   stays inside it.
    INDENTED_BLOCK <- "(?sm)(?:^([ \t]*))?```\\{?[rR]\\}?[^\\n]*\\n(.*?)```"

    mark_untested <- function(text, ran = character(0)) {
      text = paste(text, collapse = "\n")
      m = gregexpr(INDENTED_BLOCK, text, perl = TRUE)
      regmatches(text, m) = list(purrr::map_chr(regmatches(text, m)[[1]], function(block) {
        code = sub(INDENTED_BLOCK, "\\2", block, perl = TRUE)
        if (grepl("^\\s*#\\s*UNTESTED", code) || is_bad_example(code) || norm_code(code) %in% ran)
          return(block)
        indent = sub(INDENTED_BLOCK, "\\1", block, perl = TRUE)
        sub("^([^`]*```\\{?[rR]\\}?[^\\n]*\\n)", paste0("\\1", indent, "# UNTESTED\n"), block,
            perl = TRUE)
      }))
      text
    }

    gate_on <- function() {
      if (identical(INTERN_LLM$lint, FALSE)) return(FALSE)
      if (requireNamespace("lintr", quietly = TRUE)) return(TRUE)
      if (!isTRUE(.state$lint_warned)) {
        message("inteRn: lintr is not installed, so replies are not linted. install.packages(\"lintr\")")
        .state$lint_warned = TRUE
      }
      FALSE
    }

    lint_retries <- function() as.integer(INTERN_LLM$lint_retries %||% 2L)

    finish_reply <- function(reply, problems, chat, n_before) {
      reply = mark_untested(reply, ran_this_turn(chat, n_before))
      if (!nrow(problems)) return(reply)
      paste0(reply, "\n\n> **Lint gate:** this code still has problems after ", lint_retries(),
             " rewrites:\n", paste0("> - block ", problems$block, ", line ", problems$line, ": ",
                                    problems$message, collapse = "\n"))
    }

    # ---- the gate, blocking and async -------------------------------------------

    # reply: the model's text. send: function(prompt) -> reply text, in the same
    #   conversation. Recurses at most lint_retries() times.
    # A linter that fails must never cost the user the reply: the gate is skipped
    #   with a message instead.
    safe_lint <- function(reply) tryCatch(lint_reply(reply), error = function(e) {
      message("inteRn: the lint gate failed and was skipped: ", conditionMessage(e))
      NULL
    })

    lint_gate <- function(reply, chat, send, n_before, attempt = 0L) {
      if (is_empty_reply(reply) || !gate_on()) return(reply)
      problems = safe_lint(reply)
      if (is.null(problems)) return(reply)
      if (!nrow(problems) || attempt >= lint_retries())
        return(finish_reply(reply, problems, chat, n_before))
      if (identical(.state$channel, "viewer"))
        viewer_send(list(type = "tool", text = paste0("lint gate: ", nrow(problems),
                                                     " problem(s), asking for a rewrite")))
      rewrite = send(lint_feedback(problems))
      if (is.null(rewrite)) return(finish_reply(reply, problems, chat, n_before))
      lint_gate(rewrite, chat, send, n_before, attempt + 1L)
    }

    # The same, for a promise of a reply; returns a promise.
    lint_gate_async <- function(reply, chat, send_async, n_before, attempt = 0L) {
      if (is_empty_reply(reply) || !gate_on()) return(reply)
      problems = safe_lint(reply)
      if (is.null(problems)) return(reply)
      if (!nrow(problems) || attempt >= lint_retries())
        return(finish_reply(reply, problems, chat, n_before))
      viewer_send(list(type = "tool", text = paste0("lint gate: ", nrow(problems),
                                                   " problem(s), asking for a rewrite")))
      promises::then(send_async(lint_feedback(problems)), function(r) {
        if (is.null(r)) return(finish_reply(reply, problems, chat, n_before))
        lint_gate_async(r, chat, send_async, n_before, attempt + 1L)
      })
    }

    # help.R -- the quick start shown when inteRn loads, and intern_help().
    # Function definitions only.

    # Exported. How to use inteRn, in one screen. Shown at startup; call it any
    #   time. options(intern.quiet = TRUE) in .Rprofile stops the startup copy.
    intern_help <- function() {
      key_ok = identical(INTERN_LLM$key_source, "analyst") || nzchar(Sys.getenv(INTERN_LLM$key_var))
      cat(
        "\n-- inteRn: your AI coding intern ------------------------------------\n",
        "  It sees the names, types and labels of your objects, never their values.\n\n",
        "  ask(\"How do I set up a survey design for my data?\")   ask a question\n",
        "  my_data %ask% \"Which variables need recoding?\"        ask about an object\n",
        "  open_intern()                                          chat in the Viewer\n",
        "  intern_reset()   start over      intern_help()   show this again\n\n",
        "  It asks before running code or writing files. Code it hasn't run is\n",
        "  marked # UNTESTED: run it yourself before trusting it.\n",
        if (!key_ok) paste0("\n  ! No API key found. Add ", INTERN_LLM$key_var,
                            "=... with usethis::edit_r_environ(), then restart R.\n"),
        "---------------------------------------------------------------------\n\n",
        sep = "")
      invisible(NULL)
    }
  }, core)

  # Optional overrides, e.g. INTERN_LLM$pm <- "claude-sonnet-5-5"
  cfg = file.path(home, "config.R")
  if (file.exists(cfg)) sys.source(cfg, envir = core)
  problems = core$intern_config_problems()
  if (length(problems))
    message("inteRn: settings need attention:\n", paste0("  - ", problems, collapse = "\n"))

  # ---- 4. what the user sees -------------------------------------------------
  if ("inteRn" %in% search()) detach("inteRn", character.only = TRUE)
  pub = attach(NULL, name = "inteRn", warn.conflicts = FALSE)
  purrr::walk(core$INTERN_EXPORTS, function(n) assign(n, get(n, envir = core), envir = pub))
  registerS3method("print", "intern_reply", core$print.intern_reply, envir = core)
  if (!isTRUE(getOption("intern.quiet"))) core$intern_help()
  invisible(NULL)
})
