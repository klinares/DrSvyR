# llm.R for QuestionR
# Phase 0: the key box only. The model call for both API styles, JSON parse and
#   repair, and the retry arrive in Phase 2 and are not here yet.

# A key is pasted by the analyst into the box on Start here and held for the
#   length of that analyst's session, in the registry below and nowhere else:
#   never written to disk, never in the run log, never in state (which is
#   exported), and never through Sys.setenv(), which would leak it to every
#   other session in the process. Nothing in this file reads the environment.
#   A model whose key_source is "analyst" (APP_MODELS in app.R) takes its key
#   from here and ignores any ANTHROPIC_API_KEY that happens to be set.


# ---- per-process state ---------------------------------------------------

# An environment rather than an option, so a stray options() call cannot reset
#   it. One slot per Shiny session, keyed by the session token.
.llm_state <- new.env(parent = emptyenv())
.llm_state$keys <- list()


# ---- the session key -------------------------------------------------------

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


# ---- the key box -------------------------------------------------------------

# On Start here, because the brief check, the appraisal and the Evaluate task
#   all need a key.

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
    session$onSessionEnded(function() llm_clear_session_key(token))

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
