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

# The family a model belongs to, from its id: the name after the vendor's slash, up to its
#   first dash, dot, space or digit ("anthropic/claude-sonnet-5.5" and "claude-sonnet-5-5" are
#   both "claude").
model_family <- function(id) tolower(sub("[-_. 0-9].*$", "", sub("^.*/", "", id)))

# When every draft came from the appraiser's own family (the project manager is also the only
#   worker, say), the appraisal is not a view from outside, and Results says so.
same_family_note <- function(pm_id, writers) {
  if (!length(writers) || !all(model_family(writers) == model_family(pm_id))) return(NULL)
  warn_box(tags$strong("The appraiser reviewed a draft from its own model family. "),
           paste0("The appraisal was made by ", pm_id, " of ",
                  if (length(writers) == 1L) "a draft" else "drafts", " written by ",
                  paste(writers, collapse = ", "), ", a model of the same family, so it is not a view from outside. ",
                  "Read it with that in mind."))
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
  output_language = list(label = "Output language", type = "text", value = "English"),
  source_language = list(label = "Source language", type = "text", value = "English",
                         help = "The language the items are translated from, if any."),
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

# An ordered list of options, or what an open item collects.
options_list <- function(options, open_format = "") {
  opts = purrr::map_chr(options, function(o) paste(unlist(o), collapse = " "))
  if (length(opts)) tags$ol(class = "mb-1", purrr::map(opts, tags$li))
  else tags$p(class = "text-muted mb-1", paste0("[Open question",
                                                if (nzchar(open_format)) paste0(": ", open_format), "]"))
}

# Filter, branch and bracket questions, indented under their item.
parts_block <- function(parts)
  purrr::map(parts, function(p)
    tags$div(style = "margin-left:1.25rem; padding-left:0.75rem; border-left:3px solid var(--bs-border-color);",
             tags$div(class = "text-muted small", paste0("Part, asked ", p$when %||% "", ":")),
             tags$div(p$stem %||% ""),
             options_list(p$options)))

defaults_table <- function(d) {
  lab = defaults_labels(d)
  tags$table(class = "table table-sm small mb-1",
             tags$tbody(purrr::imap(as.list(lab), function(v, k)
               tags$tr(tags$td(class = "text-muted", k), tags$td(v)))))
}

# One fail: the check, its severity, the check's question from the checklist that
#   was sent, the failing words, the stage and the reason. A fail about a set of
#   items also names them.
fail_entry <- function(f, checklist)
  tags$li(tags$strong(f$check),
          if (nzchar(f$items %||% "")) tags$span(class = "text-muted", paste0(" (items ", f$items, ")")),
          if (!is.na(f$severity)) tags$span(class = "badge text-bg-secondary ms-1", paste("severity", f$severity)),
          if (!f$known) tags$span(class = "badge text-bg-warning ms-1", "not a check that was sent"),
          if (f$known) tags$span(class = "text-muted", ": ", checklist[[f$check]]),
          if (nzchar(f$evidence)) tagList(tags$br(), "Failing words: ", tags$q(f$evidence)),
          if (nzchar(f$stage)) tags$span(class = "text-muted", paste0(" (", f$stage, ")")),
          if (nzchar(f$why)) tagList(tags$br(), f$why))

# Entries (fails or findings, each with a `severity`) in the three bands of
#   DESIGN.md section 14, highest first: "Fix before fielding" (7 and above) and
#   "Needs your judgment" (5 and 6) are listed under their headings, and the Minor
#   band (below 5) is folded away. draw makes one entry; noun is "fail" or
#   "finding"; none_text says what stands when nothing is rated 5 or above.
banded_list <- function(entries, draw, noun, none_text) {
  band = severity_band(purrr::map_dbl(entries, function(e) as.numeric(e$severity %||% NA_real_)))
  of = function(b) entries[band == b]
  listed = function(b) if (length(of(b))) tagList(
    tags$h6(class = "mt-2 mb-1", SEVERITY_BANDS[[b]]),
    tags$ul(class = "small", purrr::map(of(b), draw)))
  tagList(
    if (!any(band != "minor")) tags$p(class = "small", none_text),
    listed("fix"), listed("judgment"),
    if (length(of("minor"))) tags$details(
      tags$summary(class = "small", paste0(length(of("minor")), " minor ",
                                           if (length(of("minor")) == 1L) noun else paste0(noun, "s"),
                                           ", rated below 5")),
      tags$ul(class = "small", purrr::map(of("minor"), draw))))
}

# A candidate's fails in the bands.
fail_list <- function(fails, checklist, none_text)
  banded_list(fails, function(f) fail_entry(f, checklist), "fail", none_text)

# A button that sets one input of the Results module to a value when it is pressed. A plain
#   button and one observer for all of them, so the number of items does not matter.
set_button <- function(label, input, value, ns, class = "btn btn-sm btn-primary")
  tags$button(type = "button", class = class,
              onclick = sprintf("Shiny.setInputValue('%s', '%s', {priority: 'event'})", ns(input), value),
              label)

# The text of one option or part: what the page shows and edits.
option_text <- function(o) paste(unlist(o), collapse = " ")

# One item of the set, each stem, option and part in a plain text box so it can be edited in
#   place; boxes are named by edit_input_id() and what they hold is read by edits_from_inputs().
#   ed is what the analyst changed before (output.R), so the boxes can be drawn again as they
#   were left. Under it: the reviewer's reason, what it still doubts in the three bands, and
#   its suggestion if any, which is a suggestion and not a new item.
set_card <- function(e, it, model, ns, checklist, ed = NULL) {
  box = function(id, value, label = NULL) textInput(ns(id), label, value = value, width = "100%")
  options_boxes = function(prefix, opts, now)
    purrr::imap(purrr::map_chr(opts, option_text), function(o, j)
      box(edit_input_id(e$uid, prefix, paste0("o", j)), now[[as.character(j)]] %||% o))
  it = full_item(it)
  tags$div(
    class = "card mb-2",
    tags$div(
      class = "card-body py-2",
      tags$div(tags$strong(it$id), tags$span(class = "text-muted", paste0(" · ", e$domain, " · candidate ", e$candidate,
                                                                          ", written by ", model)),
               if (isTRUE(e$swapped)) tags$span(class = "badge text-bg-info ms-1", "swapped in by you"),
               if (!is.null(ed)) tags$span(class = "badge text-bg-secondary ms-1", "edited")),
      if (nzchar(e$why)) tags$p(class = "text-muted small mb-1", paste0("Why this one: ", e$why)),
      if (nzchar(it$intro)) tags$p(class = "mb-1", tags$em(it$intro)),
      box(edit_input_id(e$uid, "stem"), ed$stem %||% it$stem),
      if (length(it$options)) options_boxes(NULL, it$options, ed$options %||% list())
      else tags$p(class = "text-muted mb-1", paste0("[Open question",
                                                    if (nzchar(it$open_format)) paste0(": ", it$open_format), "]")),
      purrr::imap(it$parts, function(p, i)
        tags$div(style = "margin-left:1.25rem; padding-left:0.75rem; border-left:3px solid var(--bs-border-color);",
                 tags$div(class = "text-muted small", paste0("Part, asked ", p$when %||% "", ":")),
                 box(edit_input_id(e$uid, paste0("p", i), "stem"), ed$parts[[as.character(i)]]$stem %||% p$stem %||% ""),
                 options_boxes(paste0("p", i), p$options %||% list(), ed$parts[[as.character(i)]]$options %||% list()))),
      if (nzchar(it$programming)) tags$p(class = "text-muted small mb-1", paste0("[", it$programming, "]")),
      tags$h6(class = "mt-2 mb-0", "What the reviewer still doubts"),
      fail_list(e$concerns, checklist, "Nothing rated 5 or above."),
      if (nzchar(e$suggestion)) tags$p(class = "mb-1", tags$em("A suggested change, untested: "), e$suggestion),
      set_button("Remove from the set", "remove", e$uid, ns, "btn btn-sm btn-outline-secondary")))
}

# The recommended set, as the analyst has it now, then the reviewer's notes on the set as a whole.
#   chk is check_appraisal() (NULL when the reviewer did not come back), reply its parsed reply.
set_panel <- function(set, cands, labels, ns, checklist, edits, chk, reply) {
  items = purrr::map(set, function(e) {
    it = unname(cands[[e$candidate]]$items)[[e$position]]
    set_card(e, it, labels[[e$candidate]], ns, checklist, edits[[e$uid]])
  })
  tagList(
    tags$h4("The recommended set"),
    advice_box("An expert-review appraisal by a language model against a fixed checklist: one item for each ",
               "domain, chosen from the drafts and copied exactly as a worker wrote it. It cannot show how ",
               "respondents will understand or answer, and nothing here is validated. Change anything in the ",
               "boxes, take an item out, or put one from the drafts below in its place."),
    if (!length(set)) tags$p("The set is empty. Open the drafts below and use an item from one.") else items,
    if (length(chk$not_covered)) tags$p(class = "text-muted small",
                                        paste0("No draft item was good enough to recommend for: ", paste(chk$not_covered, collapse = "; "))),
    if (length(chk$set_notes)) tagList(tags$h5("About the set as a whole"),
                                       fail_list(chk$set_notes, checklist, "Nothing rated 5 or above.")),
    if (length(reply$test_first)) tagList(
      tags$h5("What to test first"),
      tags$ul(purrr::map(reply$test_first, function(t)
        tags$li(paste0("Item ", paste(unlist(t$id %||% "?"), collapse = " "), ": ", paste(unlist(t$method), collapse = " ")))))),
    if (nzchar(paste(unlist(reply$limits), collapse = " ")))
      tags$p(tags$em(paste(unlist(reply$limits), collapse = " "))))
}

# Every draft, a candidate at a time, closed until asked for. Each item has a button that puts it
#   in the set: in place of the item chosen in the box at the top, or at the end of the set. The
#   coded defaults are here, beside the draft they describe.
drafts_panel <- function(cands, labels, set, ns, language, open) {
  targets = c("at the end of the set" = "",
              purrr::set_names(purrr::map_chr(set, "uid"),
                               purrr::imap_chr(set, function(e, i) paste0("in place of item ", i, " (", e$id, ")"))))
  tags$details(
    id = ns("drafts"), open = if (isTRUE(open)) NA,
    ontoggle = sprintf("Shiny.setInputValue('%s', this.open)", ns("drafts_open")),
    tags$summary(paste0("See all drafts (", length(cands), if (length(cands) == 1L) " candidate)" else " candidates)")),
    selectInput(ns("swap_target"), "An item you use from a draft goes", choices = targets, width = "100%"),
    purrr::imap(cands, function(reply, letter)
      tagList(
        tags$h5(paste("Candidate", letter), tags$span(class = "text-muted small", " written by ", tags$code(labels[[letter]]))),
        purrr::imap(unname(reply$items), function(it, i) {
          it = full_item(it)
          tags$div(
            class = "card mb-2",
            tags$div(
              class = "card-body py-2",
              tags$div(tags$strong(it$id), tags$span(class = "text-muted", " · ", it$domain)),
              if (nzchar(it$intro)) tags$p(class = "mb-1", tags$em(it$intro)),
              tags$p(class = "mb-1", tags$strong(it$stem)),
              options_list(it$options, it$open_format),
              parts_block(it$parts),
              if (nzchar(it$programming)) tags$p(class = "text-muted small mb-1", paste0("[", it$programming, "]")),
              if (identical(code_defaults(it, language)$decisions, "not itemised"))
                tags$p(class = "mb-1", tags$span(class = "badge text-bg-warning", "decisions not itemised"),
                       tags$span(class = "text-muted small", " The model wrote its design decisions as one string.")),
              tags$details(tags$summary(class = "small", "Coded defaults (by R, from the item as written)"),
                           defaults_table(code_defaults(it, language))),
              if (!paste0(letter, "_", i) %in% purrr::map_chr(set, "uid"))
                set_button("Use this instead", "swap", paste0(letter, "_", i), ns)))
        }))))
}


# ---- Results for a review (the Evaluate task) ------------------------------------------------

# One finding, from a row of check_review(): the check and its question, the
#   severity, flags for a check that was not sent and for a quote that is not in
#   the pasted text, then the quote, the problem, and an untested rewrite and probe.
review_finding <- function(r, checklist)
  tags$li(
    tags$strong(r$check),
    tags$span(class = "badge text-bg-secondary ms-1", paste("severity", r$severity)),
    if (!r$check_known) tags$span(class = "badge text-bg-warning ms-1", "not a check that was sent"),
    if (r$scope == "question" && !isTRUE(r$evidence_found))
      tags$span(class = "badge text-bg-warning ms-1", "quote not found"),
    if (r$check_known) tags$span(class = "text-muted", ": ", checklist[[r$check]]),
    tags$br(),
    if (r$scope == "question") tagList("Quote: ", tags$q(r$evidence)) else paste0("Questions: ", r$evidence),
    if (nzchar(r$stage)) tags$span(class = "text-muted", paste0(" (", r$stage, ")")),
    if (nzchar(r$problem)) tagList(tags$br(), r$problem),
    if (nzchar(r$rewrite)) tagList(
      tags$br(), tags$em("A rewrite, untested: "), r$rewrite,
      if (nzchar(r$rewrite_english)) paste0(" (in English: ", r$rewrite_english, ")")),
    if (nzchar(r$probe)) tagList(tags$br(), tags$em("A probe: "), r$probe))

# Findings in the three severity bands. A question with no finding says none were
#   found by this review, never that it has no problems.
review_findings <- function(rows, checklist) {
  as_rows = purrr::map(seq_len(nrow(rows)), function(i) as.list(rows[i, ]))
  if (!length(as_rows)) return(tags$p(class = "small", "No problem was found by this review."))
  banded_list(as_rows, function(r) review_finding(r, checklist), "finding",
              "No finding rated 5 or above.")
}

# The TRAPD steps the review says are still needed. Nothing is drawn when the
#   survey is in one language for one country and the review left them all empty.
TRAPD_STEPS <- c(translation = "Translation", review = "Review", adjudication = "Adjudication",
                 pretesting = "Pretesting", documentation = "Documentation")

trapd_block <- function(trapd) {
  said = purrr::map_chr(names(TRAPD_STEPS), function(k) paste(unlist(trapd[[k]] %||% ""), collapse = " "))
  if (!any(nzchar(trimws(said)))) return(NULL)
  tagList(tags$h5("TRAPD: what is still needed"),
          tags$ul(purrr::imap(purrr::keep(purrr::set_names(said, TRAPD_STEPS[names(TRAPD_STEPS)]),
                                          function(s) nzchar(trimws(s))),
                              function(text, step) tags$li(tags$strong(step), ": ", text))))
}

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

# Everything the review said, question by question and then as a whole, with R's
#   flags on it. rv is run_review()'s result.
review_panel <- function(f, rv, round, ns = identity) {
  if (identical(rv$status, "failed") || is.null(rv$reply))
    return(tagList(
      tags$p(class = "text-muted small", paste0("Round ", round, ".")),
      warn_box(tags$strong("The review did not come back. "), rv$error),
      rerun_buttons(rv, ns)))
  reply = rv$reply
  checklist = build_checklist(f)
  flags = check_review(reply, f)
  approved = attr(rv, "prompt")
  question = flags[flags$scope == "question", ]
  n_missing = sum(!question$evidence_found)
  n_unknown = sum(!flags$check_known)
  label = function(x) paste(unlist(x), collapse = " ")
  tagList(
    if (length(rv$batches) > 1L)
      tags$p(class = "text-muted small",
             paste0("Round ", round, ". One review by the project manager, in ", length(rv$batches) - 1L,
                    " parts and one call on the instrument as a whole. "),
             tags$details(tags$summary("Prompt hashes, one per call"),
                          tags$ul(purrr::map(rv$batches, function(b)
                            tags$li(if (identical(b$kind, "instrument")) "The instrument as a whole"
                                    else paste0("Part ", b$part, " (from block ", b$first_block, ")"), ": ",
                                    tags$code(substr(b$hash %||% "", 1, 16)),
                                    if (!identical(b$status, "ok")) " (did not come back)")))))
    else tags$p(class = "text-muted small",
           paste0("Round ", round, ". One review by the project manager. Prompt hash "),
           tags$code(substr(rv$hash, 1, 16)),
           if (isTRUE(approved$edited))
             paste0(" (edited; assembled hash ", substr(approved$original_hash, 1, 16), ")"), "."),
    if (identical(rv$status, "partial"))
      warn_box(tags$strong("Part of the review did not come back. "),
               "What did is shown below; the rest is missing, not clear of problems.",
               rerun_buttons(rv, ns)),
    advice_box("An expert-review appraisal by a language model against a fixed checklist. It shows ",
               "where a respondent may have trouble; it cannot show how respondents will understand ",
               "or answer, a rewrite or a probe is untested, and nothing here is validated."),
    if (n_missing || n_unknown)
      warn_box(tags$strong("R's checks on the review found: "), tags$ul(class = "mb-0", c(
        if (n_missing) list(tags$li(n_missing, if (n_missing == 1L) " quote that is" else " quotes that are",
                                    " not in the pasted text (flagged below).")),
        if (n_unknown) list(tags$li(n_unknown, if (n_unknown == 1L) " finding cites" else " findings cite",
                                    " a check that was not sent (flagged below).")))))
    else NULL,
    tags$h4("Question by question"),
    purrr::imap(unname(reply$items), function(it, i)
      tags$div(class = "card mb-2", tags$div(
        class = "card-body py-2",
        tags$h6(paste("Question", label(it$id))),
        review_findings(flags[flags$scope == "question" & flags$position == i, ], checklist)))),
    tags$h4("The instrument as a whole"),
    review_findings(flags[flags$scope == "instrument", ], checklist),
    trapd_block(reply$trapd),
    if (length(reply$test_first)) tagList(
      tags$h5("What to test first"),
      tags$ul(purrr::map(reply$test_first, function(t)
        tags$li(if (is.list(t) && !is.null(t$id))
          paste0("Question ", label(t$id), ": ", label(t$method)) else label(t))))),
    if (nzchar(label(reply$not_assessed)))
      tagList(tags$h5("What this review could not judge"), tags$p(label(reply$not_assessed))),
    tags$details(tags$summary(paste0("Criteria that were applied (", length(checklist), ")")),
                 tags$ul(class = "small", purrr::imap(as.list(checklist), function(q, id)
                   tags$li(tags$strong(id), ": ", q)))))
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
        initial_set(check_appraisal(out$appraisal$reply, candidates_of(out$drafts, seed), build_checklist(f)))
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

    # What the analyst changes in the set: typing in a box, taking an item out, using one from the
    #   drafts. Edits are read from the boxes into state$edits (the page is not drawn again for them,
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
                      "and the candidates, or the review's findings, appear here."))
      f = r$form
      if (identical(task_kind(f), "review"))
        return(review_panel(f, state$review, r$round, session$ns))
      drafts = state$drafts
      ap = state$appraisal
      approved = attr(drafts, "prompt")
      cands = candidates_of(drafts, state$seed)
      labels = labels_of(drafts, state$seed)
      checklist = build_checklist(f)
      appraisal_ok = identical(ap$status, "ok")
      failed = purrr::keep(unname(as.list(drafts)), function(d) !identical(d$status, "ok"))
      tagList(
        tags$p(class = "text-muted small",
               paste0("Round ", r$round, ". ", length(cands), " of ", length(drafts),
                      " workers returned usable drafts. Prompt hash "),
               tags$code(substr(approved$hash, 1, 16)),
               if (isTRUE(approved$edited))
                 paste0(" (edited; assembled hash ", substr(approved$original_hash, 1, 16), ")"),
               paste0(". Labels shuffled with seed ", state$seed, ".")),
        if (length(failed)) warn_box(
          tags$strong("Did not return a usable draft: "),
          tags$ul(class = "mb-0", purrr::map(failed, function(d)
            tags$li(tags$code(d$model), ": ", d$error)))),
        if (!appraisal_ok) warn_box(tags$strong("The reviewer did not come back. "), ap$error,
                                    " There is no recommended set; the drafts are below, and you can build a set from them."),
        if (appraisal_ok) same_family_note(APP_MODELS$pm$id, unname(labels)),
        if (!length(cands)) tags$p("No draft to show."),
        uiOutput(session$ns("set_ui")),
        uiOutput(session$ns("drafts_ui")),
        tags$details(tags$summary(paste0("Criteria that were applied (", length(checklist), ")")),
                     tags$ul(class = "small", purrr::imap(as.list(checklist), function(q, id)
                       tags$li(tags$strong(id), ": ", q)))))
    }))

    # The set and the drafts are drawn on their own, so a swap or a removal redraws them and
    #   nothing else. What the analyst typed is put back from state$edits, which they do not read.
    set_context <- function() {
      f = result()$form
      list(f = f, cands = candidates_of(state$drafts, state$seed), labels = labels_of(state$drafts, state$seed),
           checklist = build_checklist(f), ap = state$appraisal)
    }
    output$set_ui <- renderUI(safe_ui({
      req(result(), state$drafts)
      x = set_context()
      appraisal_ok = identical(x$ap$status, "ok")
      set_panel(state$set, x$cands, x$labels, session$ns, x$checklist, isolate(state$edits),
                if (appraisal_ok) check_appraisal(x$ap$reply, x$cands, x$checklist), if (appraisal_ok) x$ap$reply)
    }))
    output$drafts_ui <- renderUI(safe_ui({
      req(result(), state$drafts)
      x = set_context()
      drafts_panel(x$cands, x$labels, state$set, session$ns, x$f$output_language,
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

# The set as the analyst left it, or the review, laid out for Word, with the disclosure block; and the
#   run log.
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
      brief = state$brief
      brief = if (is.list(brief) && identical(brief$status, "ok")) brief
      build_output(state$form, drafts = state$drafts, appraisal = state$appraisal, seed = state$seed,
                   set = state$set, edits = state$edits, review = state$review, brief = brief,
                   approved = state$approved)
    })

    output$view <- renderUI(safe_ui({
      if ((state$round %||% 0L) < 1L)
        return(tags$p(class = "text-muted",
                      "Nothing to show yet. Draft items or review a questionnaire on the earlier tabs, ",
                      "and the result is laid out here."))
      o = built()
      html = scrub_secrets(paste(as.character(o$html), collapse = "\n"), secrets())
      txt = scrub_secrets(o$text, secrets())
      tagList(
        advice_box("Select what is in the first box, or press the button, and paste it into Word: ",
                   "the numbering and the emphasis are kept. The second box is the same thing as plain ",
                   "text. Both end with a disclosure of the use of language models, to keep with the questionnaire."),
        tags$h5("For Word"),
        # Black on white whatever the theme: a browser copies the colours it shows, and light
        #   text copied from the dark theme would be invisible on a Word page.
        tags$style(paste0(".qr-word, .qr-word * { color: #000 !important; background: transparent !important; } ",
                          ".qr-word { background: #fff !important; } .qr-word blockquote { border-left: 3px solid #adb5bd; ",
                          "padding-left: 0.75rem; margin-left: 1rem; font-size: inherit; }")),
        tags$div(id = session$ns("html_box"), class = "qr-word",
                 style = "border: 1px solid #adb5bd; padding: 12px 16px;",
                 HTML(html)),
        tags$p(class = "mt-2", copy_button("Copy for Word", session$ns("html_box"), TRUE), tags$span(class = "small")),
        tags$h5("Plain text"),
        tags$textarea(id = session$ns("text_box"), class = "form-control", rows = 14, readonly = NA,
                      style = "font-family: monospace; font-size: 85%;", txt),
        tags$p(class = "mt-2", copy_button("Copy plain text", session$ns("text_box"), FALSE), tags$span(class = "small")))
    }))

    output$downloads <- renderUI({
      if ((state$round %||% 0L) < 1L) return(NULL)
      tagList(
        tags$hr(),
        tags$h5("Downloads"),
        tags$p("The run log is one JSON file with every round of this session: the forms, the prompts and their hashes, ",
               "the replies as the models sent them, the shuffle seed and which model wrote which candidate, and the set ",
               "as you left it, with what you edited and swapped. No key is ever in it. It is made in this session only; nothing is stored on the server."),
        downloadButton(session$ns("get_text"), "Download the plain text", class = "btn-sm me-2"),
        downloadButton(session$ns("get_log"), "Download the run log (JSON)", class = "btn-sm"))
    })

    output$get_text <- downloadHandler(
      filename = function() paste0("questionr-output-", format(Sys.time(), "%Y%m%d-%H%M"), ".txt"),
      content = function(file) writeLines(scrub_secrets(built()$text, secrets()), file, useBytes = TRUE))

    output$get_log <- downloadHandler(
      filename = function() paste0("questionr-run-log-", format(Sys.time(), "%Y%m%d-%H%M"), ".json"),
      content = function(file) {
        rounds = state$rounds
        n = length(rounds)
        if (n && !is.null(state$drafts))
          rounds[[n]]$analyst <- list(set = state$set, edits = state$edits,
                                      final = final_set(state$set, state$edits, state$drafts, state$seed))
        writeLines(run_log_json(rounds, secrets = secrets()), file, useBytes = TRUE)
      })
  })
}
