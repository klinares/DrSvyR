# session.R: the key and the call count of each Shiny session. The key is pasted on Start here and
#   held here for the session only: never on disk, in a log, or in the environment. Function
#   definitions and constants only.

CALL_WINDOW_MINUTES <- 60   # CALLS_PER_WINDOW (app.R) counts calls in this rolling window, per session

.sessions <- new.env(parent = emptyenv())
.sessions$keys <- list()
.sessions$calls <- list()

session_token <- function(session = shiny::getDefaultReactiveDomain()) if (is.null(session)) "console" else session$token

session_key <- function(token = session_token()) {
  k = .sessions$keys[[token]]
  if (is.null(k) || !nzchar(k)) NULL else k
}
set_session_key <- function(key, token = session_token()) .sessions$keys[[token]] <- key
forget_session <- function(token) { .sessions$keys[[token]] <- NULL; .sessions$calls[[token]] <- NULL }

# Calls are recorded with their time; the count shown is for the whole session.
add_calls <- function(n, token = session_token()) .sessions$calls[[token]] <- c(.sessions$calls[[token]], rep(Sys.time(), n))
calls_made <- function(token = session_token()) length(.sessions$calls[[token]])
calls_in_window <- function(token = session_token())
  sum(.sessions$calls[[token]] > Sys.time() - CALL_WINDOW_MINUTES * 60)

# NULL when n more calls are allowed, else the message to show.
call_limit_note <- function(n, token = session_token(), limit = CALLS_PER_WINDOW) {
  if (is.na(limit) || calls_in_window(token) + n <= limit) return(NULL)
  sprintf("This session has made %d model calls in the last %d minutes, and the limit is %d. Wait a while and try again.",
          calls_in_window(token), CALL_WINDOW_MINUTES, limit)
}

KEY_INSTRUCTIONS <- c(
  "Ask the person who manages the AI service for your office for a key.",
  "Use a key issued to you, not one shared by a team, so that use can be traced to the person who made it.",
  "If a request is refused for quota or cost, stop and ask the person who issued the key.")

mod_key_ui <- function(id) {
  ns = NS(id)
  tagList(
    tags$h4("Your API key"), uiOutput(ns("status")),
    passwordInput(ns("key"), NULL, width = "100%", placeholder = "Paste your key here"),
    actionButton(ns("save"), "Use this key", class = "btn-primary"), actionButton(ns("clear"), "Forget it"),
    advice_box(tags$p(tags$strong("Where to get one")), map(KEY_INSTRUCTIONS, tags$p),
               tags$p(tags$em("The key is kept for this session only. It is not saved anywhere, and closing the tab discards it."))))
}

mod_key_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    token = session$token
    changed = function(note) {
      updateTextInput(session, "key", value = "")
      state$key_version = state$key_version + 1L
      showNotification(note, type = "message")
    }
    observeEvent(input$save, {
      k = trimws(input$key %||% "")
      if (!nzchar(k)) return(showNotification("Nothing pasted.", type = "warning"))
      set_session_key(k, token)
      changed("Key accepted for this session.")
    })
    observeEvent(input$clear, { .sessions$keys[[token]] <- NULL; changed("Key forgotten.") })
    session$onSessionEnded(function() forget_session(token))
    output$status = renderUI({
      state$key_version
      if (!is.null(session_key(token))) tags$p(class = "text-success", "A key you supplied is in use for this session.")
      else warn_box("No key has been pasted. Questions and the report reader need one; the Formulas page does not.")
    })
  })
}
