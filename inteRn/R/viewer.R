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
  sc = tryCatch(slash_command(text), error = function(e) paste("Error:", conditionMessage(e)))
  if (!is.null(sc)) {
    viewer_send(list(type = "user", text = text))
    return(viewer_send(list(type = "note", text = sc)))
  }
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
