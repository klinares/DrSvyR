# ui_chat.R for DrSvyR
# The methodologist panel: one continuous conversation with the project manager.

#   1. Capability probing
#   2. The system prompt
#   3. The conversation
#   4. Proposals
#   5. The module

# The pipeline calls in llm.R stay stateless and are untouched. This is the one
#   place with memory, and it is the overseer rather than the machinery: it
#   watches the project, is told when the specification changes, and answers
#   follow-up questions. Nothing it says enters a computation.

# Retries and the fallback deliberately do not run inside the conversation. A
#   failed call can leave a partial turn behind, and a retry against a
#   corrupted history turns a transient failure into a sticky one. On any
#   failure the chat object is rebuilt and the analyst is told the history was
#   reset, because losing the history is recoverable and silently corrupting it
#   is not.

# Requires: shiny, ellmer, purrr, dplyr, fs

# Not a truncation point. Past this the panel says the conversation is long and
#   offers to clear it, rather than quietly dropping the turns that would have
#   explained why an earlier answer was given.
PM_CHAT_MAX_TURNS <- 24L


# Section 1. What the installed ellmer actually offers.
#______________________________________________________________________________

# The accessors for token usage have moved across ellmer versions and this app
#   has to run against whatever is on the analyst's machine, so the name is
#   probed once and its absence costs a badge rather than the feature.
pm_tokens <- function(chat) {
  got = purrr::detect(c("get_tokens", "tokens"), function(nm) {
    f = try(chat[[nm]], silent = TRUE)
    !inherits(f, "try-error") && is.function(f)
  })
  if (is.null(got)) return(NA_integer_)
  v = try(sum(unlist(chat[[got]]()), na.rm = TRUE), silent = TRUE)
  if (inherits(v, "try-error") || !is.finite(v)) NA_integer_ else as.integer(v)
}


# Section 2. What the project manager is told it is.
#______________________________________________________________________________

# Assembled from reflexes.R at run time rather than written out here, so the
#   catalogue is the single place any of it changes and the version in force is
#   the version stamped in the report.
pm_system <- function(state, stage_key) {

  paste(
    persona_pm,
    "",
    "You are overseeing one analysis from start to finish and you remember it.",
    "When the analyst changes the specification you will be told; take it into",
    "account rather than referring to the model that no longer exists.",
    "",
    reflex_prompt(stage = stage_key),
    "",
    "HOW TO ANSWER",
    "Answer in plain prose, briefly. Explain what a number means for the",
    "analyst's decision rather than defining the statistic.",
    "",
    "If and only if you want to propose an action, end your reply with a JSON",
    "object in a fenced block, after the prose:",
    '{"reflex_id": "...", "action": "...", "claim": "...",',
    ' "evidence": [{"field": "...", "value": ...}]}',
    "",
    "The evidence you cite must come from the numbers you were given in this",
    "turn. A proposal citing anything else is discarded before the analyst",
    "sees it, so inventing a plausible figure costs you the proposal.",
    "Most turns need no proposal at all.",
    sep = "\n")
}

# Only the fields some reflex at this stage is entitled to, and nothing else.
#   The analyst's data never travels; these are computed summaries.
pm_evidence_block <- function(state, stage_key) {
  ev = try(reflex_evidence(state, stage_key), silent = TRUE)
  if (inherits(ev, "try-error") || !length(ev))
    return("NUMBERS AVAILABLE AT THIS STAGE\n  (none yet)")

  fmt = function(x) {
    x = x[!is.na(x)]
    if (!length(x)) return("--")
    if (is.numeric(x)) x = round(x, 4)
    s = paste(utils::head(as.character(x), 25), collapse = ", ")
    if (length(x) > 25) paste0(s, ", ... (", length(x), " values)") else s
  }
  paste0("NUMBERS AVAILABLE AT THIS STAGE\n",
         paste0("  ", names(ev), " = ", purrr::map_chr(ev, fmt), collapse = "\n"))
}


# Section 3. The conversation.
#______________________________________________________________________________

pm_chat_new <- function(state, stage_key) {
  llm_chat(llm_model("pm"), system_prompt = pm_system(state, stage_key))
}

# Returns the reply and says whether the history survived, so the panel can
#   tell the analyst rather than carrying on as though nothing happened.
pm_say <- function(chat, text) {
  out = try(chat$chat(text, echo = FALSE), silent = TRUE)
  if (inherits(out, "try-error"))
    list(ok = FALSE, text = conditionMessage(attr(out, "condition")))
  else list(ok = TRUE, text = as.character(out))
}


# Section 4. Proposals.
#______________________________________________________________________________

# The prose is shown whatever happens. A proposal is shown only if the protocol
#   in reflexes.R accepts it, and a rejected proposal is reported as rejected
#   rather than dropped, because a model repeatedly failing validation is
#   something the analyst should see.
pm_extract_proposal <- function(reply, state, stage_key) {
  obj = try(parse_json_block(reply), silent = TRUE)
  if (inherits(obj, "try-error")) return(NULL)

  observed = try(reflex_evidence(state, stage_key), silent = TRUE)
  if (inherits(observed, "try-error")) observed = list()

  ok = try(validate_proposal(obj, observed), silent = TRUE)
  if (inherits(ok, "try-error"))
    return(list(valid = FALSE, why = conditionMessage(attr(ok, "condition"))))

  list(valid = TRUE, proposal = obj)
}

# Accepting records the decision and sends the analyst to the tab where the
#   change is actually made. It never makes the change itself: the protocol
#   cannot check whether the inference behind a proposal is sound, only whether
#   the arithmetic was quoted correctly, so a human hand stays on every edit.
PM_ACTION_TAB <- c(
  flag_for_report   = NA_character_,
  revisit_design    = "2. Design",
  change_estimator  = "3. Items",
  merge_levels      = "4. Domains",
  change_k          = "5. Review",
  suppress_estimate = "10. Results",
  none              = NA_character_)


# Section 5. The module.
#______________________________________________________________________________

mod_chat_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$h4("AI Survey Methodologist"),
    tags$p(class = "text-muted",
           "One conversation for the whole session. It is told when the ",
           "specification changes and it remembers what you have discussed. ",
           "Nothing it says enters a calculation, and it cannot change the ",
           "analysis -- proposals are staged for you to accept or reject."),

    uiOutput(ns("meter")),
    tags$hr(),
    uiOutput(ns("history")),
    uiOutput(ns("pending")),

    textAreaInput(ns("msg"), NULL, width = "100%", rows = 3,
                  placeholder = paste(
                    "Ask about anything in the analysis so far -- why a number",
                    "looks the way it does, what a diagnostic means for your",
                    "decision, what you should check next.")),
    actionButton(ns("send"), "Send", class = "btn-primary"),
    actionButton(ns("clear"), "Clear conversation"))
}


mod_chat_server <- function(id, state, stage = reactive(NULL)) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    chat <- reactiveVal(NULL)
    log  <- reactiveVal(list())     # what is shown, and what is written out
    turns <- reactiveVal(0L)
    reset_note <- reactiveVal(NULL)

    # The key is captured in a closure by the chat object, so dropping it from
    #   the registry does not remove it from a conversation already holding
    #   one. The object is discarded whenever the key changes -- which is also
    #   correct on its own terms, since a new key may be a different account.
    observeEvent(state$key_version, {
      if (is.null(chat())) return()
      chat(NULL); turns(0L)
      say("system", paste(
        "The API key changed, so this conversation was discarded rather than",
        "continued against a key it was not started with."), "note")
    }, ignoreInit = TRUE, ignoreNULL = TRUE)

    # The stage name drives which reflexes are in scope. Taken from the tab the
    #   analyst is on rather than inferred from what state happens to hold, so
    #   the model is answering about where they are.
    stage_key <- reactive({
      s = stage() %||% ""
      dplyr::case_when(
        grepl("Design", s)  ~ "design",
        grepl("Items", s)   ~ "items",
        grepl("Review", s)  ~ "config",
        grepl("Search|Model|Names", s) ~ "model",
        grepl("Domains|Scoring|Results", s) ~ "domains",
        grepl("Outputs", s) ~ "report",
        TRUE ~ "items")
    })

    say <- function(role, text, kind = "msg") {
      log(c(log(), list(list(role = role, text = text, kind = kind))))
    }

    ensure_chat <- function() {
      if (is.null(chat())) chat(pm_chat_new(state, stage_key()))
      chat()
    }

    # ---- the specification changed ----------------------------------------

    # An overseer that is not told the model changed will keep citing the old
    #   one. Injected as a turn rather than resetting the conversation, so the
    #   history of how the analysis got here survives -- which is the point of
    #   having an overseer at all.
    observeEvent(state$model_key, {
      if (is.null(chat())) return()
      note <- paste0(
        "SPECIFICATION CHANGED. The analyst refitted. Groups: ",
        state$dimension, ". Items: ", length(state$cfg$items),
        ". Numbers you were given earlier no longer describe the current ",
        "model; use the ones supplied from here on. Acknowledge in one ",
        "sentence.")
      res <- pm_say(chat(), note)
      turns(turns() + 1L)
      say("system", paste("Specification changed -- refitted at",
                          state$dimension, "segments."), "note")
      if (res$ok) say("assistant", res$text)
    }, ignoreInit = TRUE, ignoreNULL = TRUE)

    # ---- sending ------------------------------------------------------------

    observeEvent(input$send, {
      req(nzchar(trimws(input$msg %||% "")))
      msg <- trimws(input$msg)
      sk <- stage_key()
      say("user", msg)
      updateTextAreaInput(session, "msg", value = "")

      withProgress(message = "Asking the AI Survey Methodologist", value = 0.5, {
        res <- pm_say(ensure_chat(),
                      paste0(pm_evidence_block(state, sk), "\n\n", msg))

        if (!res$ok) {
          # Rebuilt rather than retried in place. See the note at the top.
          chat(pm_chat_new(state, sk))
          turns(0L)
          reset_note(res$text)
          say("system", paste0(
            "That call failed and the conversation was reset rather than ",
            "retried, because a failed turn can leave the history in a state ",
            "nothing downstream would notice. Error: ", res$text), "warn")
          return()
        }

        turns(turns() + 1L)
        reset_note(NULL)

        # The fenced proposal is stripped from what is shown, but only the
        #   surrounding whitespace is trimmed: squishing would collapse the
        #   paragraph breaks the reply is rendered with.
        prose <- trimws(sub("(?s)```.*?```", "", res$text, perl = TRUE))
        say("assistant", if (nzchar(prose)) prose else res$text)

        p <- pm_extract_proposal(res$text, state, sk)
        if (is.null(p)) {
          state$pending_proposal <- NULL
        } else if (isFALSE(p$valid)) {
          state$pending_proposal <- NULL
          say("system", paste0(
            "It attached a proposal that the protocol rejected, so it is not ",
            "shown: ", p$why), "warn")
        } else {
          state$pending_proposal <- c(p$proposal, list(stage = sk))
        }
      })
    })

    observeEvent(input$clear, {
      chat(NULL); log(list()); turns(0L); reset_note(NULL)
      state$pending_proposal <- NULL
      showNotification("Conversation cleared.", type = "message")
    })

    # ---- what the analyst sees ---------------------------------------------

    output$meter <- renderUI({
      tk <- if (is.null(chat())) NA_integer_ else pm_tokens(chat())
      long <- turns() >= PM_CHAT_MAX_TURNS
      tagList(
        tags$p(class = "text-muted",
               tags$strong(turns()), " turn(s)",
               if (!is.na(tk)) paste0(" \u00b7 ", format(tk, big.mark = ","),
                                      " tokens") else "",
               " \u00b7 stage: ", tags$code(stage_key()),
               " \u00b7 reflexes v", SURV_REFLEXES_VERSION),
        if (long) warn_box(
          tags$div("This conversation is long. Every turn resends the whole ",
                   "history, so the cost per answer is still growing. Nothing ",
                   "has been dropped and nothing will be silently: clear it ",
                   "when the thread has served its purpose.")))
    })

    output$history <- renderUI({
      h <- log()
      if (!length(h))
        return(tags$p(class = "text-muted", "Nothing asked yet."))

      tagList(purrr::map(h, function(m) {
        if (identical(m$role, "user"))
          tags$div(style = paste("background: var(--bs-secondary-bg);",
                                 "border-radius: 6px; padding: 8px 12px;",
                                 "margin: 0.4em 0 0.4em 3em;"),
                   tags$strong("You: "), m$text)
        else if (identical(m$kind, "warn")) warn_box(tags$div(m$text))
        else if (identical(m$kind, "note"))
          tags$p(class = "text-muted", tags$em(m$text))
        else advice_box(tags$div(style = "white-space:pre-line;", m$text))
      }))
    })

    # One pending proposal at a time, with fixed input ids. Rendering a card
    #   per proposal would mean registering an observer per card, and those
    #   stack silently every time the list redraws.
    output$pending <- renderUI({
      p <- state$pending_proposal
      if (is.null(p)) return(NULL)
      r <- SURV_REFLEXES[[p$reflex_id]]

      ev <- paste(purrr::map_chr(p$evidence, function(e)
        paste0(e$field, " = ", e$value)), collapse = ", ")

      tagList(
        tags$hr(),
        tags$div(
          style = paste("border-left: 4px solid var(--bs-primary);",
                        "padding: 8px 12px; margin: 0.6em 0;"),
          tags$p(tags$strong("Proposal: "), SURV_ACTIONS[[p$action]]),
          tags$p(p$claim),
          tags$p(class = "text-muted",
                 "Reflex ", tags$code(p$reflex_id),
                 " \u00b7 evidence ", tags$code(ev),
                 " \u00b7 threshold ",
                 tags$code(if (is.na(r$threshold)) "none set"
                           else as.character(r$threshold)),
                 if (!r$sourced) " (this project's convention, not a standard)"
                 else ""),
          tags$p(class = "text-muted", tags$em("Source: "), r$source),

          textInput(ns("reject_why"), "Reason, if you are rejecting this",
                    width = "100%",
                    placeholder = "Why this does not apply here."),
          actionButton(ns("accept"), "Accept", class = "btn-primary"),
          actionButton(ns("reject"), "Reject")))
    })

    record <- function(p, decision, reason = "") {
      state$proposals <- c(state$proposals %||% list(),
        list(list(reflex_id = p$reflex_id, action = p$action,
                  claim = p$claim, stage = p$stage,
                  evidence = p$evidence, decision = decision,
                  reason = reason,
                  time = format(Sys.time(), "%Y-%m-%d %H:%M"))))
      state$pending_proposal <- NULL
    }

    observeEvent(input$accept, {
      p <- state$pending_proposal
      req(!is.null(p))
      record(p, "accepted")
      tab <- PM_ACTION_TAB[[p$action]]
      say("system", paste0("Accepted: ", SURV_ACTIONS[[p$action]]), "note")
      if (!is.na(tab)) {
        state$goto <- tab
        showNotification(paste0("Recorded. The change itself is made in ", tab,
                                "."), type = "message", duration = 8)
      } else {
        showNotification("Recorded for the report.", type = "message")
      }
    })

    # The reason is required. Recording that a proposal was rejected says only
    #   that the analysis went this way; recording why is what lets someone
    #   reconstruct the reasoning later, including the analyst.
    observeEvent(input$reject, {
      p <- state$pending_proposal
      req(!is.null(p))
      why <- trimws(input$reject_why %||% "")
      if (!nzchar(why)) {
        showNotification(
          paste("Give a reason for rejecting this. It goes in the decision",
                "log and it is the part that explains the analysis."),
          type = "warning", duration = NULL)
        return()
      }
      record(p, "rejected", why)
      say("system", paste0("Rejected: ", why), "note")
      updateTextInput(session, "reject_why", value = "")
    })

    # ---- the transcript on disk --------------------------------------------

    # Written beside the decision log rather than kept in memory, so the
    #   conversation that shaped the report is auditable next to it. Silent
    #   when no work folder is set, because the panel is usable before one is.
    observe({
      h <- log()
      if (!length(h) || is.null(state$work_dir)) return()
      f <- try(wise_path("decisions", "methodologist.md"), silent = TRUE)
      if (inherits(f, "try-error")) return()

      body <- purrr::map_chr(h, function(m)
        paste0("**", switch(m$role, user = "Analyst", assistant = "Methodologist",
                            "Note"), ".** ", m$text))

      decided <- purrr::map_chr(state$proposals %||% list(), function(d)
        paste0("- ", d$time, " \u00b7 ", d$reflex_id, " \u00b7 ", d$action, " \u00b7 ",
               toupper(d$decision),
               if (nzchar(d$reason)) paste0(" \u2014 ", d$reason) else ""))

      try(writeLines(c(
        paste0("# Methodologist transcript"), "",
        paste0("Reflex catalogue v", SURV_REFLEXES_VERSION,
               " \u00b7 DrSvyR v", WISE_VERSION), "",
        body, "",
        if (length(decided)) c("## Proposals", "", decided) else NULL), f),
        silent = TRUE)
    })
  })
}


# ---- the API key --------------------------------------------------------

# On a server the analyst has no .Renviron to edit, so the key is typed here
#   and held for the length of their session only. It is never written to disk,
#   never enters state (which is exported), never reaches the decision log or
#   the methodologist transcript, and is dropped when the session ends.

# The field is masked, but masking is a courtesy: the value crosses the network
#   in the request body. This panel assumes the app is served over HTTPS.

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
    ns <- session$ns
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
      env <- identical(WISE_LLM$key_source %||% "server", "server") &&
             nzchar(Sys.getenv(WISE_LLM$key_var))

      if (mine)
        tags$p(class = "text-success",
               "A key you supplied is in use for this session.")
      else if (env)
        tags$p(class = "text-muted",
               "Using the key configured on this machine. Paste your own ",
               "below to use it instead for this session.")
      else
        warn_box(tags$div(
          "No key is set, so the AI Survey Methodologist and the drafted names are ",
          "unavailable. Everything else works: the model still fits, the ",
          "estimates and their margins are unaffected, and the report is ",
          "written with generic names and no prose."))
    })
  })
}
