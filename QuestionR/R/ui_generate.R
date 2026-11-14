# ui_generate.R for QuestionR
# The screens of the Generate flow: Brief, Prompt, Results and Run again, one
#   module each (DESIGN.md section 12). They hold no flow logic. They gather the
#   form, call the engine in R/flow.R, and draw what it returns; the dropdown,
#   the fields and the worker boxes all read the registry (TASKS) and the model
#   list (APP_MODELS), so a new task or worker needs no change here. It also
#   holds the Output tab. The second half of ui.R. Function definitions and
#   constants only.


# ---- the one state object ---------------------------------------------------------

# Every module reads and writes this, and none talks to another. app.R makes it
#   from these. key_version changes whenever the pasted key is saved or forgotten.
#   form is the cleaned form the Brief tab handed on; approved is the prompt the
#   analyst approved (edited or not); run_id changes to start a run; the rest is
#   what the last run returned. set is the items in the recommended set as the analyst has it
#   (set_entry() in output.R) and edits what the analyst changed in them, by entry.
STATE_DEFAULTS <- list(
  key_version = 0L, form = NULL, workers = NULL, brief = NULL, approved = NULL,
  run_id = 0L, round = 0L, drafts = NULL, appraisal = NULL, review = NULL, seed = NULL,
  set = list(), edits = list(), revision = "", rounds = list())

# A task's kind, from a form. A form with no usable task counts as a drafting one,
#   so a run that cannot start fails in the engine, with its reason, as any other.
task_kind <- function(f) {
  t = f$task
  if (is.character(t) && length(t) == 1L && t %in% names(TASKS)) TASKS[[t]]$kind else "draft"
}


# ---- shared pieces -------------------------------------------------------------------

# A message for the page, never a stack trace. Long endpoint messages are cut.
plain_message <- function(e) substr(conditionMessage(e), 1, 600)

# An output's UI built safely: whatever goes wrong in drawing it is said on the
#   page in words, and the rest of the app carries on.
safe_ui <- function(expr)
  tryCatch(expr, error = function(e)
    warn_box(tags$strong("This part could not be drawn. "), plain_message(e)))

# What the engine last said it was about to do (run_review's progress argument), for
#   progress_ask() to put on the page. An environment, so a callback can set it.
PROGRESS_NOTE <- new.env()

# The function a run hands to the engine as `ask`. It says on the page, before
#   each call, which model is about to be asked, then makes the call through
#   llm_json(), which finds the key for that model. Must run inside withProgress().
#   total is how many calls the run will make.
progress_ask <- function(total) {
  n = 0L
  function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    n <<- n + 1L
    # A review in parts says which part it is on, through progress() in run_review().
    note = PROGRESS_NOTE$msg %||% ""
    PROGRESS_NOTE$msg <- NULL
    setProgress(value = (n - 1L) / total,
                message = if (nzchar(note)) paste0(note, " (call ", n, " of ", total, ")")
                          else paste0("Call ", n, " of ", total),
                detail = paste0("Asking ", m$id, ". This can take a few minutes."))
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens,
             validate = validate)
  }
}

# The same for requests sent together (llm_json_all): says on the page which models are being
#   asked, then sends them. Must run inside withProgress().
progress_ask_all <- function(total) {
  function(requests) {
    note = PROGRESS_NOTE$msg %||% ""
    PROGRESS_NOTE$msg <- NULL
    setProgress(value = 0,
                message = if (nzchar(note)) note else paste0("Asking ", length(requests), " models together"),
                detail = paste0("Asking ", paste(purrr::map_chr(requests, function(r) r$m$id), collapse = ", "),
                                ". They run side by side; this can take a few minutes."))
    llm_json_all(requests)
  }
}

task_choices <- function()
  purrr::set_names(names(TASKS), purrr::map_chr(TASKS, "label"))

# The names of the tasks a test picks out, as a JavaScript condition on the task
#   dropdown, so a field or a box is shown for those tasks only and keeps what
#   was typed in it when the task changes.
tasks_condition <- function(tasks)
  paste0(jsonlite::toJSON(tasks), ".indexOf(input.task) >= 0")


# ---- the form's widgets, one per field -------------------------------------------------

# How each form field is asked for. The registry says which tasks show which
#   field; this says what the field looks like. A new field is one entry.
FIELD_SPECS <- list(
  research_question = list(label = "Research question (required)", type = "area", rows = 2,
                           help = "What the survey needs to find out."),
  construct = list(label = "Construct", type = "text",
                   help = "In a sentence, and its domains if it has several."),
  population = list(label = "Target population", type = "text"),
  country = list(label = "Country", type = "text",
                 help = "Leave it blank if the questionnaire is not for one country."),
  modes = list(label = "Survey mode", type = "modes",
               help = "One or more. Leave all clear if it is not yet decided."),
  n_items = list(label = "Number of items (at most 10 a run)", type = "number", value = 6),
  reference_period = list(label = "Reference period and unit", type = "text",
                          help = "For behaviour: for example 'the past 7 days', and what is counted."),
  keep_items = list(label = "Existing items to keep", type = "area", rows = 3,
                    help = "Items already evaluated that the new ones must fit with."),
  other = list(label = "Other details", type = "area", rows = 3),
  questionnaire = list(label = "Questionnaire to review (pasted)", type = "area", rows = 12))

field_widget <- function(field, ns) {
  s = FIELD_SPECS[[field]]
  id = ns(field)
  tagList(
    switch(s$type,
      text = textInput(id, s$label, value = s$value %||% "", width = "100%"),
      area = textAreaInput(id, s$label, rows = s$rows %||% 3, width = "100%", resize = "vertical"),
      number = numericInput(id, s$label, value = s$value %||% 1, min = 1, step = 1,
                            max = if (field == "n_items") MAX_ITEMS_PER_RUN else NA),
      modes = checkboxGroupInput(id, s$label, inline = TRUE,
                                 choices = purrr::set_names(names(MODE_LABELS), unname(MODE_LABELS)))),
    if (!is.null(s$help)) tags$p(class = "text-muted small mt-n2", s$help))
}


# ---- tab 1: Brief ----------------------------------------------------------------------------

mod_brief_ui <- function(id) {
  ns <- NS(id)
  fields = intersect(FORM_FIELDS, names(FIELD_SPECS))
  worker_ids = purrr::map_chr(APP_MODELS$workers, "id")
  tagList(
    tags$h3(QUESTIONR_TABS[2]),
    tags$p("Choose the task and describe what you need. Anything you leave blank is ",
           "left out of the prompt, never guessed."),
    selectInput(ns("task"), "Task", choices = task_choices(), width = "100%"),
    uiOutput(ns("task_note")),
    purrr::map(fields, function(f)
      conditionalPanel(tasks_condition(names(purrr::keep(TASKS, function(t) f %in% t$fields))),
                       ns = ns, field_widget(f, ns))),
    conditionalPanel(
      tasks_condition(names(purrr::keep(TASKS, function(t) identical(t$kind, "draft")))), ns = ns,
      checkboxGroupInput(ns("workers"), "Workers that will each draft the items",
                         choices = purrr::set_names(worker_ids, worker_ids), selected = worker_ids),
      tags$p(class = "text-muted small mt-n2",
             "Each ticked model gets the same prompt, all at once. Fewer models cost less.")),
    uiOutput(ns("revision_note")),
    tags$div(
      actionButton(ns("build"), "Build the instructions", class = "btn-primary"),
      actionButton(ns("check"), "Check my brief first", class = "btn-sm btn-outline-secondary ms-2")),
    tags$p(class = "text-muted small mt-2",
           "Building the instructions goes straight to the prompt, for you to read before anything is sent. ",
           "Checking the brief first asks the project manager model what a designer would still need to ",
           "know; it needs the key from Start here and takes a call."),
    uiOutput(ns("message")),
    uiOutput(ns("result")))
}

# A brief check's answer, on the page: whether the brief is complete, what is
#   missing (blocking first), whether another task fits, and the criteria that
#   will be applied. continue is the button that goes on to the prompt.
brief_panel <- function(res, ns) {
  if (identical(res$status, "skipped"))
    return(tags$p(class = "text-muted", "The brief was not checked."))
  if (!identical(res$status, "ok"))
    return(warn_box(tags$strong("The brief check did not come back. "), res$error,
                    tags$br(), "You can try again, or build the instructions without it."))
  r = res$reply
  qs = r$questions
  qs = qs[order(!purrr::map_lgl(qs, function(q) isTRUE(q$blocking)))]
  tagList(
    tags$h5("Brief check"),
    advice_box(if (isTRUE(r$complete)) "The project manager found nothing blocking in the brief."
               else "The project manager found gaps that block the task, marked below."),
    if (length(qs)) tags$ul(purrr::map(qs, function(q)
      tags$li(tags$strong(if (isTRUE(q$blocking)) "Blocking: " else "Optional: "), q$ask,
              if (nzchar(q$why %||% "")) tags$span(class = "text-muted", " ", q$why)))),
    if (nzchar(r$task_fit %||% "")) advice_box(tags$strong("Task: "), r$task_fit),
    if (length(r$criteria)) tagList(
      tags$h6("Criteria that will be applied"),
      tags$ul(purrr::map(r$criteria, function(cr) tags$li(paste(unlist(cr), collapse = " "))))),
    actionButton(ns("continue"), "Continue to the prompt", class = "btn-primary"))
}

# make_ask(total) returns the function the engine calls a model through. A test
#   hands in a fake; the app uses progress_ask. go(tab) moves to another tab.
mod_brief_server <- function(id, state, go = function(tab) invisible(NULL), make_ask = progress_ask) {
  moduleServer(id, function(input, output, session) {
    message <- reactiveVal(NULL)

    # The form as typed. A field the chosen task does not show is blank, so a
    #   value typed under one task never leaks into another's prompt.
    form_now <- reactive({
      task = input$task %||% names(TASKS)[1]
      shown = TASKS[[task]]$fields
      typed = purrr::map(purrr::set_names(setdiff(FORM_FIELDS, c("task", "revision"))), function(k)
        if (k %in% shown) input[[k]])
      c(list(task = task), typed, list(revision = state$revision %||% ""))
    })

    chosen_workers <- reactive({
      ids = input$workers %||% character(0)
      purrr::keep(APP_MODELS$workers, function(m) m$id %in% ids)
    })

    # The cleaned form, or NULL with the reason on the page.
    prepare <- function() {
      message(NULL)
      tryCatch({
        f = clean_form(form_now())
        # A block too long to be a part says so here, not at the end of a run.
        if (TASKS[[f$task]]$kind == "review") review_plan(f$questionnaire, APP_BATCH_CHARS)
        ws = if (TASKS[[f$task]]$kind == "draft") chosen_workers() else list()
        if (TASKS[[f$task]]$kind == "draft" && !length(ws))
          stop("Tick at least one worker to draft the items.", call. = FALSE)
        list(form = f, workers = ws)
      }, error = function(e) {
        message(plain_message(e))
        NULL
      })
    }

    proceed <- function(brief) {
      p = prepare()
      if (is.null(p)) return(invisible(NULL))
      state$form <- p$form
      state$workers <- p$workers
      state$brief <- brief %||% state$brief
      go(QUESTIONR_TABS[3])
    }

    output$task_note <- renderUI({
      task = input$task %||% names(TASKS)[1]
      if (TASKS[[task]]$kind == "review")
        advice_box("Evaluate sends your questionnaire to the project manager model, with ",
                   "the methodology files' checklist, and shows its findings question by question. ",
                   tags$strong("Leave a blank line between questions"), ", each with its response ",
                   "options straight under it. Up to ", format(APP_BATCH_CHARS, big.mark = ","),
                   " characters is one call. A longer questionnaire is split at the blank lines into ",
                   "parts of that size, reviewed one call each, and one more call looks at the order, ",
                   "routing and consistency of the whole. The limit is ",
                   format(APP_MAX_PASTE_CHARS, big.mark = ","), " characters.")
    })

    output$revision_note <- renderUI({
      rev = state$revision %||% ""
      if (nzchar(rev))
        advice_box(tags$strong(paste0("Round ", (state$round %||% 0L) + 1L, ". ")),
                   "Your requested change goes into the prompt as a REVISION block: ",
                   tags$em(rev), tags$br(),
                   actionButton(session$ns("drop_revision"), "Drop the change", class = "btn-sm"))
    })
    observeEvent(input$drop_revision, state$revision <- "")

    observeEvent(input$check, {
      p = prepare()
      if (is.null(p)) return()
      pm = APP_MODELS$pm
      if (!llm_key_ready(pm)) {
        message(paste0("The brief check needs the project manager's key. ", llm_key_hint(pm),
                       " Or build the instructions without the check."))
        return()
      }
      state$form <- p$form
      state$workers <- p$workers
      state$brief <- tryCatch(
        withProgress(message = "Checking the brief", value = 0,
                     run_brief(p$form, pm, ask = make_ask(1L))),
        error = function(e) list(status = "failed", error = plain_message(e), reply = NULL))
    })

    observeEvent(input$build, proceed(list(status = "skipped")))
    observeEvent(input$continue, proceed(NULL))

    output$message <- renderUI(if (!is.null(message())) warn_box(message()))
    output$result <- renderUI(safe_ui(if (!is.null(state$brief)) brief_panel(state$brief, session$ns)))
  })
}


# ---- tab 2: Prompt ----------------------------------------------------------------------------

# The one line under the prompt box. The rules are sent with every prompt and are not shown here.
RULES_NOTE <- paste("The survey design rules are sent with this prompt every time and cannot be edited here.",
                    "You can read them on the Methodology tab.")

mod_prompt_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$style(".qr-prompt textarea { font-family: monospace; font-size: 85%; }"),
    tags$h3(QUESTIONR_TABS[3]),
    tags$p("This is the prompt the model will be sent. R assembled it from the form and ",
           "the methodology files; no model wrote it. Approve it as it is, or edit it first: ",
           "an edited prompt is marked as edited, with both hashes, wherever it is recorded."),
    uiOutput(ns("body")),
    uiOutput(ns("status")),
    uiOutput(ns("message")))
}

mod_prompt_server <- function(id, state, go = function(tab) invisible(NULL)) {
  moduleServer(id, function(input, output, session) {
    reset <- reactiveVal(0L)
    message <- reactiveVal(NULL)
    unix <- function(x) gsub("\r\n?", "\n", x %||% "")

    # One prompt, or for a review in parts the first part's, with `calls`, the number
    #   of calls the review will make (the parts and the instrument).
    assembled <- reactive({
      if (is.null(state$form)) return(NULL)
      tryCatch({
        f = state$form
        plan = if (task_kind(f) == "review") review_plan(f$questionnaire, APP_BATCH_CHARS)
        if (length(plan) > 1L) c(build_step_prompt(f, "items", part = plan[[1]]), list(calls = length(plan)))
        else build_prompt(f)
      }, error = function(e) e)
    })

    output$body <- renderUI(safe_ui({
      reset()
      a = assembled()
      if (is.null(a))
        return(tags$p(class = "text-muted", "Fill in the Brief tab, then continue from there."))
      if (inherits(a, "error"))
        return(warn_box("The prompt could not be assembled: ", plain_message(a)))
      draft = TASKS[[state$form$task]]$kind == "draft"
      if (!is.null(a$calls)) return(tagList(
        tags$p(class = "text-muted small", "Reflex files used: ", paste(a$files, collapse = ", ")),
        advice_box(tags$strong(paste0("This questionnaire is reviewed in ", a$calls - 1L, " parts. ")),
                   paste0("Each part is one call, and one more call looks at the instrument as a whole: ",
                          a$calls, " calls: the parts together, at most four at a time, then the whole. "),
                   "Below is the first part's prompt. The other ",
                   "parts differ only in their questions, the part number and the number of their ",
                   "first block; the last call has the whole questionnaire and only the checks about ",
                   "order, routing, consistency and fit to objectives. Because it is several prompts, ",
                   "it cannot be edited here. Hash of the first: ", tags$code(substr(a$hash, 1, 16)), "."),
        tags$details(tags$summary("The first part's prompt"), tags$pre(class = "small", a$message)),
        tags$p(class = "text-muted small", RULES_NOTE),
        tags$p("It can take several minutes, and the app is busy until it finishes."),
        actionButton(session$ns("approve"), "Approve and run", class = "btn-primary")))
      tagList(
        tags$p(class = "text-muted small", "Reflex files used: ", paste(a$files, collapse = ", ")),
        tags$div(class = "qr-prompt",
                 textAreaInput(session$ns("user"), "The prompt (you can edit this)",
                               value = a$message, rows = 18, width = "100%", resize = "vertical")),
        tags$p(class = "text-muted small", RULES_NOTE),
        if (draft) tags$p(paste0(
          "Approving runs ", length(state$workers), if (length(state$workers) == 1L) " worker" else " workers",
          " together, then the reviewer recommends a set: ", length(state$workers) + 1L,
          " model calls. It can take a few minutes, and the app is busy until it finishes."))
        else tags$p("Approving makes one model call: the project manager reviews the questionnaire. ",
                    "It can take a minute or two, and the app is busy until it finishes."),
        actionButton(session$ns("approve"), "Approve and run", class = "btn-primary"),
        actionButton(session$ns("reset"), "Reset to the assembled prompt"))
    }))
    observeEvent(input$reset, reset(reset() + 1L))

    # Whether what is in the boxes is what R assembled, and the hash of each.
    output$status <- renderUI(safe_ui({
      a = assembled()
      if (is.null(a) || inherits(a, "error") || !is.null(a$calls) || is.null(input$user)) return(NULL)
      msg = unix(input$user)
      if (identical(msg, a$message))
        tags$p(class = "text-muted small", "As assembled. Hash ", tags$code(substr(a$hash, 1, 16)), ".")
      else warn_box(tags$strong("Edited. "), "Assembled hash ", tags$code(substr(a$hash, 1, 16)),
                    "; edited hash ", tags$code(substr(prompt_hash(a$system, sent_user(msg, a$tail)), 1, 16)), ".")
    }))

    observeEvent(input$approve, {
      message(NULL)
      a = assembled()
      if (is.null(a) || inherits(a, "error")) {
        message("There is no prompt to approve. Fill in the Brief tab first.")
        return()
      }
      # A review in parts is approved as assembled: its prompts are several, and not edited. The
      #   rules (the system prompt) are never the analyst's to change: they are what R assembled.
      msg = if (is.null(a$calls)) unix(input$user) else a$message
      if (!nzchar(trimws(msg))) {
        message("The prompt is empty. Reset it to the assembled prompt, or write one.")
        return()
      }
      # What is sent is the analyst's text and, after it, R's tail (the checklist and the reply format).
      usr = sent_user(msg, a$tail)
      state$approved <- list(system = a$system, user = usr, hash = prompt_hash(a$system, usr), files = a$files,
                             edited = !identical(msg, a$message),
                             original_hash = a$hash)
      state$run_id <- (state$run_id %||% 0L) + 1L
      go(QUESTIONR_TABS[4])
    })

    output$message <- renderUI(if (!is.null(message())) warn_box(message()))
  })
}


# ---- tab 3: Results ----------------------------------------------------------------------------

# Results shows the analyst only what they need to act (DESIGN.md section 18): for a drafted question,
#   the question, its answer options and, only when the reviewer found a real problem, one line to
#   check before use; for a review, the questions that need revising, with the problem and a suggested
#   rewrite. Prompts, hashes, models, scores and every other draft are in the full record.

# An ordered list of options, or what an open item collects.
options_list <- function(options, open_format = "") {
  opts = purrr::map_chr(options, function(o) paste(unlist(o), collapse = " "))
  if (length(opts)) tags$ol(class = "mb-1", purrr::map(opts, tags$li))
  else tags$p(class = "text-muted mb-1", paste0("[Open question",
                                                if (nzchar(open_format)) paste0(": ", open_format), "]"))
}

# A button that sets one input of the Results module to a value when it is pressed. A plain
#   button and one observer for all of them, so the number of items does not matter.
set_button <- function(label, input, value, ns, class = "btn btn-sm btn-primary")
  tags$button(type = "button", class = class,
              onclick = sprintf("Shiny.setInputValue('%s', '%s', {priority: 'event'})", ns(input), value),
              label)

# The text of one option: what the page shows and edits.
option_text <- function(o) paste(unlist(o), collapse = " ")

# One question of the set, numbered i: the question and each answer option in a plain text box so it
#   can be edited in place (boxes are named by edit_input_id() and read by edits_from_inputs()); under
#   them, when the reviewer found a real problem, the one line "Check before use:"; and the button that
#   takes the question out. ed is what the analyst changed before (output.R), so the boxes can be
#   drawn again as they were left.
set_card <- function(e, it, i, ns, ed = NULL) {
  box = function(id, value, label = NULL) textInput(ns(id), label, value = value, width = "100%")
  it = full_item(it)
  tags$div(
    class = "card mb-2",
    tags$div(
      class = "card-body py-2",
      box(edit_input_id(e$uid, "stem"), ed$stem %||% it$stem, paste("Question", i)),
      if (length(it$options))
        purrr::imap(purrr::map_chr(it$options, option_text), function(o, j)
          box(edit_input_id(e$uid, paste0("o", j)), ed$options[[as.character(j)]] %||% o))
      else tags$p(class = "text-muted mb-1", paste0("[Open question",
                                                    if (nzchar(it$open_format)) paste0(": ", it$open_format), "]")),
      if (nzchar(e$check)) tags$p(class = "mb-1", tags$em(CHECK_LABEL), " ", e$check),
      set_button("Remove from the set", "remove", e$uid, ns, "btn btn-sm btn-outline-secondary")))
}

# The recommended set, as the analyst has it now, under the one sentence.
set_panel <- function(set, cands, ns, edits) {
  items = purrr::imap(set, function(e, i)
    set_card(e, unname(cands[[e$candidate]]$items)[[e$position]], i, ns, edits[[e$uid]]))
  tagList(
    tags$p(tags$em(RESULT_NOTICE)),
    if (!length(set)) tags$p("The set is empty. Open the other questions below and use one.") else items)
}

# The other questions the workers drafted, closed until asked for, by domain. Each has a button that
#   puts it in the set: in place of the question chosen in the box at the top, or at the end of the set.
#   No model is named and nothing is scored: only the question and its answer options.
drafts_panel <- function(cands, set, ns, open) {
  targets = c("at the end of the set" = "",
              purrr::set_names(purrr::map_chr(set, "uid"),
                               purrr::imap_chr(set, function(e, i) paste0("in place of question ", i))))
  in_set = purrr::map_chr(set, "uid")
  others = purrr::compact(unname(unlist(purrr::imap(cands, function(reply, letter)
    purrr::imap(unname(reply$items), function(it, i)
      if (!paste0(letter, "_", i) %in% in_set)
        list(uid = paste0(letter, "_", i), item = full_item(it)))), recursive = FALSE)))
  domains = purrr::map_chr(others, function(o) o$item$domain)
  tags$details(
    id = ns("drafts"), open = if (isTRUE(open)) NA,
    ontoggle = sprintf("Shiny.setInputValue('%s', this.open)", ns("drafts_open")),
    tags$summary("See all drafts"),
    selectInput(ns("swap_target"), "A question you use from here goes", choices = targets, width = "100%"),
    purrr::map(unique(domains), function(d)
      tagList(
        tags$h6(class = "mt-2 mb-1", d),
        purrr::map(others[domains == d], function(o)
          tags$div(
            class = "card mb-2",
            tags$div(
              class = "card-body py-2",
              tags$p(class = "mb-1", tags$strong(o$item$stem)),
              options_list(o$item$options, o$item$open_format),
              set_button("Use this instead", "swap", o$uid, ns)))))))
}


# ---- Results for a review (the Evaluate task) ------------------------------------------------

# A button for each call of a review that failed, which runs that call again. It sets
#   the module's `rerun` input to the call's place in rv$batches.
rerun_buttons <- function(rv, ns = identity) {
  failed = which(!purrr::map_lgl(rv$batches, function(b) identical(b$status, "ok")))
  if (length(rv$batches) < 2L || !length(failed)) return(NULL)
  tags$ul(class = "mb-0 mt-2", purrr::map(failed, function(i) {
    b = rv$batches[[i]]
    tags$li(
      if (identical(b$kind, "instrument")) "The instrument as a whole"
      else paste0("Part ", b$part, " of ", b$n_parts, ", from block ", b$first_block),
      ": ", b$error %||% "", " ",
      tags$button(type = "button", class = "btn btn-sm btn-primary",
                  onclick = sprintf("Shiny.setInputValue('%s', %d, {priority: 'event'})", ns("rerun"), i),
                  "Run this part again"))
  }))
}

# The review as the analyst is shown it: the one sentence; each question marked Revise with the
#   question as pasted, the verdict, at most two problems and a suggested rewrite; the questions
#   marked Keep in one line; and at most three points about the questionnaire as a whole (R holds the
#   review to these limits, shape_review()). rv is run_review()'s result.
review_panel <- function(f, rv, ns = identity) {
  if (identical(rv$status, "failed") || is.null(rv$reply))
    return(tagList(warn_box(tags$strong("The review did not come back. "), rv$error),
                   rerun_buttons(rv, ns)))
  sh = shape_review(rv$reply, f$questionnaire)
  revise = purrr::keep(sh$questions, function(q) identical(q$verdict, "Revise"))
  tagList(
    tags$p(tags$em(RESULT_NOTICE)),
    if (identical(rv$status, "partial"))
      warn_box(tags$strong("Part of the review did not come back. "),
               "What did is shown below; the rest is missing, not clear of problems.",
               rerun_buttons(rv, ns)),
    purrr::map(revise, function(q)
      tags$div(class = "card mb-2", tags$div(
        class = "card-body py-2",
        tags$h6(paste("Question", q$id)),
        if (nzchar(q$text)) tags$p(class = "mb-1", style = "white-space: pre-line;", q$text),
        tags$p(class = "mb-1", tags$strong("Revise")),
        purrr::map(q$problems, function(p)
          tagList(tags$p(class = "mb-1", paste0("Problem: ", p$problem)),
                  if (nzchar(p$rewrite)) tags$p(class = "mb-1", paste0("Suggested rewrite: ", p$rewrite))))))),
    if (length(sh$keep))
      tags$p(paste0(if (length(sh$keep) == 1L) "Question " else "Questions ", paste(sh$keep, collapse = ", "),
                    ": keep as written")),
    if (length(sh$instrument))
      tagList(tags$h5("The questionnaire as a whole"), tags$ul(purrr::map(sh$instrument, tags$li))))
}


mod_results_ui <- function(id) {
  ns <- NS(id)
  tagList(tags$h3(QUESTIONR_TABS[4]), uiOutput(ns("results")))
}

mod_results_server <- function(id, state, go = function(tab) invisible(NULL), make_ask = progress_ask,
                               make_ask_all = NULL) {
  moduleServer(id, function(input, output, session) {
    problem <- reactiveVal(NULL)
    result <- reactiveVal(NULL)
    # What run_review() is about to do, for progress_ask() to put on the page.
    say_progress <- function(msg) PROGRESS_NOTE$msg <- msg

    # A run starts when the prompt is approved. Each model call is announced on
    #   the page before it is made, and nothing a call does can stop the page.
    observeEvent(state$run_id, {
      problem(NULL)
      f = state$form
      ws = state$workers
      approved = state$approved
      pm = APP_MODELS$pm
      seed = sample.int(.Machine$integer.max, 1L)
      review = identical(task_kind(f), "review")
      out = tryCatch(
        if (review) withProgress(message = "Reviewing the questionnaire", value = 0, {
          # one call, or a call for each part and one for the instrument; one when the
          #   questionnaire cannot be split, since run_review() then fails without a call
          calls = tryCatch(length(review_plan(f$questionnaire, APP_BATCH_CHARS)), error = function(e) 1L)
          ask = make_ask(calls)
          list(review = run_review(f, pm, ask = ask, progress = say_progress,
                                   ask_all = if (is.null(make_ask_all)) ask_all_for(ask) else make_ask_all(calls),
                                   # an edited prompt is sent only when the review is one call
                                   prompt = if (calls == 1L) approved))
        })
        else withProgress(message = "Running the workers", value = 0, {
          ask = make_ask(1L)
          drafts = run_drafts(f, ws, ask = ask, prompt = approved,
                              ask_all = if (is.null(make_ask_all)) ask_all_for(ask) else make_ask_all(length(ws)))
          list(drafts = drafts, appraisal = run_appraisal(f, drafts, pm, ask = ask, seed = seed))
        }),
        error = function(e) {
          problem(paste0("The run stopped: ", plain_message(e)))
          NULL
        })
      if (is.null(out)) return()
      brief = state$brief
      brief = if (is.list(brief) && brief$status %in% c("ok", "failed")) brief
      state$round <- (state$round %||% 0L) + 1L
      state$drafts <- out$drafts
      state$appraisal <- out$appraisal
      state$review <- out$review
      state$seed <- if (review) NULL else seed
      state$set <- if (!review && identical(out$appraisal$status, "ok"))
        initial_set(check_appraisal(out$appraisal$reply, candidates_of(out$drafts, seed)))
      else list()
      state$edits <- list()
      state$rounds <- c(state$rounds, list(
        if (review) flow_round(f, pm, brief = brief, review = out$review)
        else flow_round(f, pm, brief = brief, drafts = out$drafts, appraisal = out$appraisal, seed = seed)))
      result(list(form = f, round = state$round))
    }, ignoreInit = TRUE)

    # A part of a review that failed, run again: the other calls are kept, the review
    #   and the round in the log are replaced by the one that now holds the new call.
    observeEvent(input$rerun, {
      rv = state$review
      f = state$form
      req(rv, f, input$rerun)
      out = tryCatch(
        withProgress(message = "Running the part again", value = 0,
                     rerun_review_part(f, APP_MODELS$pm, rv, as.integer(input$rerun),
                                       ask = make_ask(1L), progress = say_progress)),
        error = function(e) {
          problem(paste0("The part could not be run again: ", plain_message(e)))
          NULL
        })
      if (is.null(out)) return()
      problem(NULL)
      state$review <- out
      brief = state$brief
      brief = if (is.list(brief) && brief$status %in% c("ok", "failed")) brief
      n = length(state$rounds)
      if (n) state$rounds[[n]] <- flow_round(f, APP_MODELS$pm, brief = brief, review = out)
    })

    # What the analyst changes in the set: typing in a box, taking a question out, using one from the
    #   other drafts. Edits are read from the boxes into state$edits (the page is not drawn again for them,
    #   so a box keeps its cursor); the set itself changes only on a swap or a removal.
    observe({
      req(length(state$set) > 0L, state$drafts)
      state$edits <- edits_from_inputs(state$set, state$drafts, state$seed, function(id) input[[id]])
    })
    observeEvent(input$remove, state$set <- set_remove(state$set, input$remove))
    observeEvent(input$swap, {
      req(state$drafts, input$swap)
      at = as.integer(sub("^.*_", "", input$swap))
      letter = sub("_.*$", "", input$swap)
      it = unname(candidates_of(state$drafts, state$seed)[[letter]]$items)[[at]]
      state$set <- set_swap(state$set, set_entry(letter, at, it$id %||% "", it$domain %||% "", swapped = TRUE),
                            if (nzchar(input$swap_target %||% "")) input$swap_target)
    })

    output$results <- renderUI(safe_ui({
      if (!is.null(problem())) return(warn_box(problem()))
      r = result()
      if (is.null(r))
        return(tags$p(class = "text-muted",
                      "Nothing has been run yet. Fill in the Brief tab, approve the prompt on the next tab, ",
                      "and the questions, or the review, appear here."))
      f = r$form
      if (identical(task_kind(f), "review"))
        return(review_panel(f, state$review, session$ns))
      drafts = state$drafts
      ap = state$appraisal
      cands = candidates_of(drafts, state$seed)
      failed = purrr::keep(unname(as.list(drafts)), function(d) !identical(d$status, "ok"))
      tagList(
        # A worker that failed matters only when none came back; the record has the rest.
        if (!length(cands)) warn_box(
          tags$strong("No draft came back. "),
          tags$ul(class = "mb-0", purrr::map(failed, function(d) tags$li(tags$code(d$model), ": ", d$error)))),
        if (length(cands) && !identical(ap$status, "ok"))
          warn_box(tags$strong("The reviewer did not come back. "), ap$error,
                   " There is no recommended set; the other questions are below, and you can build a set from them."),
        uiOutput(session$ns("set_ui")),
        uiOutput(session$ns("drafts_ui")))
    }))

    # The set and the other drafts are drawn on their own, so a swap or a removal redraws them and
    #   nothing else. What the analyst typed is put back from state$edits, which they do not read.
    output$set_ui <- renderUI(safe_ui({
      req(result(), state$drafts)
      set_panel(state$set, candidates_of(state$drafts, state$seed), session$ns, isolate(state$edits))
    }))
    output$drafts_ui <- renderUI(safe_ui({
      req(result(), state$drafts)
      drafts_panel(candidates_of(state$drafts, state$seed), state$set, session$ns,
                   open = isolate(input$drafts_open) %||% !length(state$set))
    }))
  })
}

# ---- Run again ----------------------------------------------------------------------------------

# Below the results. What the analyst types becomes the REVISION block of the
#   next prompt; the form is kept as it was, and the brief tab opens for it.
mod_again_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("panel"))
}

mod_again_server <- function(id, state, go = function(tab) invisible(NULL)) {
  moduleServer(id, function(input, output, session) {
    output$panel <- renderUI({
      if ((state$round %||% 0L) < 1L) return(NULL)
      tagList(
        tags$hr(),
        tags$h4("Run again"),
        tags$p("Say what to change. Your words are added to the prompt as a labelled REVISION ",
               "block, and your form stays as it is. Each round is a new entry in the run log."),
        textAreaInput(session$ns("change"), "What to change", rows = 3, width = "100%",
                      resize = "vertical"),
        actionButton(session$ns("again"), "Back to the brief with this change", class = "btn-primary"))
    })

    observeEvent(input$again, {
      state$revision <- trimws(gsub("\r\n?", "\n", input$change %||% ""))
      go(QUESTIONR_TABS[2])
    })
  })
}


# ---- tab 4: Output ---------------------------------------------------------------------------------

# What is on the Results screen, laid out for Word and followed by three lines (the date, who drafted and
#   reviewed, the tool's version); and, behind one small button, the full record.
#   Everything is built by build_output() and run_log_json() in R/output.R. A key is taken out of
#   anything shown or downloaded (scrub_secrets()), though none is ever in the data.
mod_output_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$h3(QUESTIONR_TABS[5]),
    uiOutput(ns("view")),
    uiOutput(ns("downloads")))
}

# A button that selects what is on the page and copies it. Copying from a script depends on
#   the browser, so the text says to select and copy by hand when it does not work.
copy_button <- function(label, target, rich = TRUE)
  tags$button(type = "button", class = "btn btn-sm btn-primary me-2", label,
              onclick = sprintf(paste0(
                "var el=document.getElementById('%s'); var ok=false; try{",
                if (rich) "var r=document.createRange(); r.selectNodeContents(el); var s=window.getSelection(); s.removeAllRanges(); s.addRange(r);"
                else "el.select();",
                "ok=document.execCommand('copy');}catch(e){} this.nextElementSibling.textContent= ok ? ' Copied.' : ' Not copied: select the text and copy it yourself.';"),
                target))

mod_output_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    secrets <- reactive({
      state$key_version
      known_keys()
    })

    built <- reactive({
      req((state$round %||% 0L) >= 1L, state$form)
      build_output(state$form, drafts = state$drafts, seed = state$seed,
                   set = state$set, edits = state$edits, review = state$review)
    })

    output$view <- renderUI(safe_ui({
      if ((state$round %||% 0L) < 1L)
        return(tags$p(class = "text-muted",
                      "Nothing to show yet. Draft items or review a questionnaire on the earlier tabs, ",
                      "and the result is laid out here."))
      o = built()
      html = scrub_secrets(paste(as.character(o$html), collapse = "\n"), secrets())
      tagList(
        tags$p("Press the button, or select what is in the box, and paste it into Word: the numbering and ",
               "the emphasis are kept."),
        # Black on white whatever the theme: a browser copies the colours it shows, and light
        #   text copied from the dark theme would be invisible on a Word page.
        tags$style(paste0(".qr-word, .qr-word * { color: #000 !important; background: transparent !important; } ",
                          ".qr-word { background: #fff !important; } .qr-word blockquote { border-left: 3px solid #adb5bd; ",
                          "padding-left: 0.75rem; margin-left: 1rem; font-size: inherit; }")),
        tags$div(id = session$ns("html_box"), class = "qr-word",
                 style = "border: 1px solid #adb5bd; padding: 12px 16px;",
                 HTML(html)),
        tags$p(class = "mt-2", copy_button("Copy for Word", session$ns("html_box"), TRUE), tags$span(class = "small")))
    }))

    output$downloads <- renderUI({
      if ((state$round %||% 0L) < 1L) return(NULL)
      tags$p(class = "mt-4",
             downloadButton(session$ns("get_log"), "Download the full record", class = "btn-sm btn-outline-secondary"),
             tags$span(class = "text-muted small ms-2",
                       "Prompts, models, hashes, every draft and the full reply, for your files."))
    })

    output$get_log <- downloadHandler(
      filename = function() paste0("questionr-record-", format(Sys.time(), "%Y%m%d-%H%M"), ".json"),
      content = function(file) {
        rounds = state$rounds
        n = length(rounds)
        chosen = if (!is.null(state$drafts)) final_set(state$set, state$edits, state$drafts, state$seed) else list()
        if (n && !is.null(state$drafts))
          rounds[[n]]$analyst <- list(set = state$set, edits = state$edits, final = chosen)
        brief = state$brief
        brief = if (is.list(brief) && identical(brief$status, "ok")) brief
        disclosure = strsplit(doc_text(disclosure_blocks(state$form, chosen, state$drafts, state$appraisal, state$review,
                                                         brief, state$approved)), "\n", fixed = TRUE)[[1]]
        writeLines(run_log_json(rounds, secrets = secrets(), disclosure = disclosure), file, useBytes = TRUE)
      })
  })
}
