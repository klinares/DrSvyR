# ui_generate.R for QuestionR
# The screens of the tasks: Brief, Prompt and Results, one module each. They hold no flow logic:
#   they gather the form, call the engine in R/flow.R, and draw what it returns. The drawing of a
#   result (the review page, the drafted items, Copy for Word, the run log) is in functions of its
#   own, so any screen can use them. Function definitions and constants only.


# ---- the one state object ---------------------------------------------------------

# Every module reads and writes this, and none talks to another. key_version changes whenever the
#   pasted key is saved or forgotten; form is the cleaned form; prompt is the message as assembled
#   and as the analyst left it; run_id changes to start a run; the rest is what the last run
#   returned. items is the drafted items as the analyst has them and edits what they changed.
STATE_DEFAULTS <- list(
  key_version = 0L, form = NULL, prompt = NULL, run_id = 0L, round = 0L, draft = NULL,
  review = NULL, items = list(), edits = list(), rounds = list())

task_kind <- function(f) {
  t = f$task
  if (is.character(t) && length(t) == 1L && t %in% names(TASKS)) TASKS[[t]]$kind else "draft"
}


# ---- shared pieces -------------------------------------------------------------------

# A message for the page, never a stack trace. Long endpoint messages are cut.
plain_message <- function(e) substr(conditionMessage(e), 1, 600)

safe_ui <- function(expr)
  tryCatch(expr, error = function(e) warn_box(tags$strong("This part could not be drawn. "), plain_message(e)))

# What the engine last said it was about to do, for progress_ask() to put on the page.
PROGRESS_NOTE <- new.env()

# The function a run hands to the engine as `ask`: it says on the page that a call is going out,
#   then makes it through llm_json(). Must run inside withProgress().
progress_ask <- function(total) {
  n = 0L
  function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    n <<- n + 1L
    setProgress(value = (n - 1L) / total, message = paste0("Call ", n, " of ", total),
                detail = paste0("Asking ", m$id, ". This can take a minute."))
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens, validate = validate)
  }
}

# The same for calls sent together (llm_json_all).
progress_ask_all <- function(total) {
  function(requests) {
    note = PROGRESS_NOTE$msg %||% ""
    PROGRESS_NOTE$msg <- NULL
    setProgress(value = 0, message = if (nzchar(note)) note else paste("Sending", length(requests), "calls together"),
                detail = "They run side by side; this can take a minute or two.")
    llm_json_all(requests)
  }
}

tasks_condition <- function(tasks) paste0(jsonlite::toJSON(tasks), ".indexOf(input.task) >= 0")


# ---- the form's widgets, one per field -------------------------------------------------

FIELD_SPECS <- list(
  research_question = list(label = "Research question (required)", type = "area", rows = 2),
  construct = list(label = "Construct", type = "text", help = "In a sentence, and its domains if it has several."),
  population = list(label = "Target population", type = "text"),
  country = list(label = "Country (optional)", type = "text"),
  modes = list(label = "Survey mode", type = "choices", choices = MODE_LABELS),
  n_items = list(label = "Number of items (1 to 6)", type = "number", value = 3),
  reference_period = list(label = "Reference period", type = "text", help = "For example: the past 7 days."),
  kinds = list(label = "Kinds of question in the questionnaire", type = "choices",
               choices = purrr::set_names(KINDS, KINDS), selected = KINDS),
  questionnaire = list(label = "Questions with their response options", type = "area", rows = 12,
                       help = "Leave a blank line between questions, or start each with its label (Q1., 1., 1), A1)."))

field_widget <- function(field, ns) {
  s = FIELD_SPECS[[field]]
  tagList(
    switch(s$type,
      text = textInput(ns(field), s$label, width = "100%"),
      area = textAreaInput(ns(field), s$label, rows = s$rows, width = "100%", resize = "vertical"),
      number = numericInput(ns(field), s$label, value = s$value, min = 1, max = MAX_ITEMS_PER_RUN, step = 1),
      choices = checkboxGroupInput(ns(field), s$label, inline = TRUE, selected = s$selected,
                                   choices = purrr::set_names(names(s$choices), unname(s$choices)))),
    if (!is.null(s$help)) tags$p(class = "text-muted small mt-n2", s$help))
}


# ---- tab 1: Brief ----------------------------------------------------------------------------

mod_brief_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$h3(QUESTIONR_TABS[2]),
    selectInput(ns("task"), "Task", choices = purrr::set_names(names(TASKS), purrr::map_chr(TASKS, "label")), width = "100%"),
    purrr::map(setdiff(FORM_FIELDS, "task"), function(f)
      conditionalPanel(tasks_condition(names(purrr::keep(TASKS, function(t) f %in% t$fields))), ns = ns, field_widget(f, ns))),
    actionButton(ns("build"), "Build the instructions", class = "btn-primary"),
    uiOutput(ns("message")))
}

mod_brief_server <- function(id, state, go = function(tab) invisible(NULL)) {
  moduleServer(id, function(input, output, session) {
    message <- reactiveVal(NULL)
    observeEvent(input$build, {
      message(NULL)
      task = input$task %||% names(TASKS)[1]
      typed = purrr::map(purrr::set_names(setdiff(FORM_FIELDS, "task")), function(k)
        if (k %in% TASKS[[task]]$fields) input[[k]])
      f = tryCatch({
        f = clean_form(c(list(task = task), typed))
        if (task_kind(f) == "review") review_plan(f$questionnaire)
        f
      }, error = function(e) { message(plain_message(e)); NULL })
      if (is.null(f)) return()
      state$form <- f
      go(QUESTIONR_TABS[3])
    })
    output$message <- renderUI(if (!is.null(message())) warn_box(message()))
  })
}


# ---- tab 2: Prompt ----------------------------------------------------------------------------

mod_prompt_ui <- function(id) {
  ns <- NS(id)
  tagList(tags$h3(QUESTIONR_TABS[3]), uiOutput(ns("body")), uiOutput(ns("message")))
}

mod_prompt_server <- function(id, state, go = function(tab) invisible(NULL)) {
  moduleServer(id, function(input, output, session) {
    message <- reactiveVal(NULL)
    assembled <- reactive({
      req(state$form)
      tryCatch(assemble_message(state$form), error = function(e) e)
    })
    output$body <- renderUI(safe_ui({
      a = assembled()
      if (inherits(a, "error")) return(warn_box("The prompt could not be assembled: ", plain_message(a)))
      tagList(
        textAreaInput(session$ns("user"), "What the model is told (you can edit this)", value = a,
                      rows = 14, width = "100%", resize = "vertical"),
        actionButton(session$ns("approve"), "Run", class = "btn-primary"))
    }))
    observeEvent(input$approve, {
      message(NULL)
      a = assembled()
      msg = gsub("\r\n?", "\n", input$user %||% "")
      if (inherits(a, "error") || !nzchar(trimws(msg))) {
        message("There is nothing to send.")
        return()
      }
      state$prompt <- list(assembled = a, sent = msg)
      state$run_id <- (state$run_id %||% 0L) + 1L
      go(QUESTIONR_TABS[4])
    })
    output$message <- renderUI(if (!is.null(message())) warn_box(message()))
  })
}


# ---- drawing a result -------------------------------------------------------------------------

# A button that sets one input of a module to a value when it is pressed.
set_button <- function(label, input, value, ns, class = "btn btn-sm btn-outline-secondary")
  tags$button(type = "button", class = class, label,
              onclick = sprintf("Shiny.setInputValue('%s', '%s', {priority: 'event'})", ns(input), value))

# A card drawn from its blocks, so the page and the Word copy are the same words.
card_ui <- function(blocks) tags$div(class = "card mb-2", tags$div(class = "card-body py-2", doc_html(blocks)))

# The review page, top to bottom: the bottom line, what to fix first, all questions (a row opens to
#   the card with every flag), and, closed, how it was produced. A part that did not come back is
#   said, with a button to run it again.
review_page <- function(rv, ns, prompt_files = character(0)) {
  sh = shape_review(rv)
  failed = which(!purrr::map_lgl(rv$batches, function(b) identical(b$status, "ok")))
  tagList(
    if (length(failed)) warn_box(
      tags$strong("Part of the review did not come back. "), "Its questions are marked as not reviewed, not as clear.",
      tags$ul(class = "mb-0", purrr::map(failed, function(i) tags$li(
        rv$batches[[i]]$error, " ", set_button("Run this part again", "rerun", i, ns, "btn btn-sm btn-primary"))))),
    tags$h4("Bottom line"), purrr::map(bottom_line(sh), tags$p),
    if (length(fix_first(sh))) tagList(tags$h4("What to fix first"),
                                       purrr::map(fix_first(sh), function(q) card_ui(card_blocks(q, "fix")))),
    tags$h4("All questions"),
    tags$div(class = "qr-rows", purrr::map(sh$questions, function(q)
      tags$details(class = "border-bottom py-1",
                   tags$summary(tags$span(class = "fw-semibold me-2", q$id), first_words(q$text),
                                tags$span(class = "float-end small text-muted",
                                          if (q$reviewed) paste0("fix ", n_level(q, "fix"), ", consider ", n_level(q, "consider"))
                                          else "not reviewed")),
                   card_ui(card_blocks(q))))))
}

produced_panel <- function(files, calls)
  tags$details(class = "mt-3", tags$summary("How this was produced"),
               tags$ul(class = "small", purrr::map(produced_lines(files, calls), tags$li)))

# Copy for Word and the run log, at the bottom of a result. What is copied is the blocks drawn black
#   on white in a box off the screen, because a browser copies the colours it shows.
copy_and_log <- function(blocks, ns, secrets = character(0))
  tagList(
    tags$div(id = ns("word"), class = "qr-word", style = "position:absolute; left:-10000px; top:0; width:700px;",
             HTML(scrub_secrets(paste(as.character(doc_html(blocks)), collapse = "\n"), secrets))),
    tags$p(class = "mt-4",
           tags$button(type = "button", class = "btn btn-sm btn-primary me-2", "Copy for Word",
                       onclick = sprintf(paste0(
                         "var el=document.getElementById('%s'); var ok=false; try{var r=document.createRange(); ",
                         "r.selectNodeContents(el); var s=window.getSelection(); s.removeAllRanges(); s.addRange(r); ",
                         "ok=document.execCommand('copy'); s.removeAllRanges();}catch(e){} ",
                         "this.nextElementSibling.textContent= ok ? ' Copied.' : ' Not copied: your browser blocked it.';"), ns("word"))),
           tags$span(class = "small me-3"),
           downloadButton(ns("get_log"), "Download the run log", class = "btn-sm btn-outline-secondary")))

# One drafted question, numbered i: the question and each option in a box, edited in place, and the
#   button that takes it out.
item_card <- function(it, i, ns, ed = NULL) {
  box = function(id, value, label = NULL) textInput(ns(id), label, value = value, width = "100%")
  tags$div(class = "card mb-2", tags$div(
    class = "card-body py-2",
    box(edit_input_id(it$uid, "stem"), ed$stem %||% it$stem, paste("Question", i)),
    if (length(it$options))
      purrr::imap(purrr::map_chr(it$options, option_text), function(o, j)
        box(edit_input_id(it$uid, paste0("o", j)), ed$options[[as.character(j)]] %||% o))
    else tags$p(class = "text-muted mb-1", paste0("[Open question", if (nzchar(it$open_format)) paste0(": ", it$open_format), "]")),
    if (nzchar(it$note %||% "")) tags$p(class = "small text-muted mb-1", it$note),
    set_button("Remove", "remove", it$uid, ns)))
}


# ---- tab 3: Results ----------------------------------------------------------------------------

mod_results_ui <- function(id) {
  ns <- NS(id)
  tagList(tags$h3(QUESTIONR_TABS[4]), uiOutput(ns("results")), uiOutput(ns("items_ui")), uiOutput(ns("bottom")))
}

mod_results_server <- function(id, state, make_ask = progress_ask, make_ask_all = NULL) {
  moduleServer(id, function(input, output, session) {
    problem <- reactiveVal(NULL)
    say_progress <- function(msg) PROGRESS_NOTE$msg <- msg

    observeEvent(state$run_id, {
      problem(NULL)
      f = state$form
      msg = state$prompt$sent
      m = APP_MODEL
      out = tryCatch(
        if (task_kind(f) == "review") withProgress(message = "Reviewing the questionnaire", value = 0, {
          calls = length(review_plan(f$questionnaire))
          ask = make_ask(calls)
          list(review = run_review(f, m, ask = ask, message = msg, progress = say_progress,
                                   ask_all = if (is.null(make_ask_all)) ask_all_for(ask) else make_ask_all(calls)))
        })
        else withProgress(message = "Drafting the items", value = 0,
                          list(draft = run_draft(f, m, ask = make_ask(1L), message = msg))),
        error = function(e) { problem(paste0("The run stopped: ", plain_message(e))); NULL })
      if (is.null(out)) return()
      state$round <- (state$round %||% 0L) + 1L
      state$draft <- out$draft
      state$review <- out$review
      state$items <- if (identical(out$draft$status, "ok")) draft_items(out$draft$reply) else list()
      state$edits <- list()
      state$rounds <- c(state$rounds, list(flow_round(f, m, draft = out$draft, review = out$review, prompt = state$prompt)))
    }, ignoreInit = TRUE)

    observeEvent(input$rerun, {
      req(state$review, state$form)
      out = tryCatch(withProgress(message = "Running the part again", value = 0,
                                  rerun_review_part(state$form, APP_MODEL, state$review, as.integer(input$rerun),
                                                    ask = make_ask(1L), message = state$prompt$sent)),
                     error = function(e) { problem(paste0("The part could not be run again: ", plain_message(e))); NULL })
      if (is.null(out)) return()
      state$review <- out
      n = length(state$rounds)
      if (n) state$rounds[[n]] <- flow_round(state$form, APP_MODEL, review = out, prompt = state$prompt)
    })

    observe({
      req(length(state$items) > 0L)
      state$edits <- edits_from_inputs(state$items, function(id) input[[id]])
    })
    observeEvent(input$remove, state$items <- item_remove(state$items, input$remove))

    files = reactive(names(reflexes_in_force(state$form, if (task_kind(state$form) == "review") "items" else "draft")))

    output$results <- renderUI(safe_ui({
      if (!is.null(problem())) return(warn_box(problem()))
      if ((state$round %||% 0L) < 1L) return(tags$p(class = "text-muted", "Nothing has been run yet."))
      if (task_kind(state$form) == "review") {
        rv = state$review
        if (identical(rv$status, "failed") && !length(rv$batches)) return(warn_box(rv$error))
        state$key_version
        return(HTML(scrub_secrets(as.character(review_page(rv, session$ns)), known_keys())))
      }
      d = state$draft
      if (!identical(d$status, "ok")) warn_box(tags$strong("The draft did not come back. "), d$error)
      else tags$p(tags$em(WRITE_NOTICE))
    }))

    # Drawn on their own, so a removal redraws them and nothing else; what the analyst typed is put
    #   back from state$edits, which they do not read.
    output$items_ui <- renderUI(safe_ui({
      req(state$round >= 1L, task_kind(state$form) == "draft", identical(state$draft$status, "ok"))
      purrr::imap(state$items, function(it, i) item_card(it, i, session$ns, isolate(state$edits)[[it$uid]]))
    }))

    blocks <- reactive({
      if (task_kind(state$form) == "review") review_blocks(shape_review(state$review))
      else draft_blocks(final_items(state$items, state$edits))
    })

    output$bottom <- renderUI(safe_ui({
      req(state$round >= 1L)
      state$key_version
      tagList(copy_and_log(blocks(), session$ns, known_keys()),
              produced_panel(files(), run_calls(state$draft, state$review)))
    }))

    output$get_log <- downloadHandler(
      filename = function() paste0("questionr-run-log-", format(Sys.time(), "%Y%m%d-%H%M"), ".json"),
      content = function(file) {
        rounds = state$rounds
        n = length(rounds)
        if (n && !is.null(state$draft))
          rounds[[n]]$analyst <- list(edits = state$edits, final = final_items(state$items, state$edits))
        writeLines(run_log_json(rounds, secrets = known_keys()), file, useBytes = TRUE)
      })
  })
}
