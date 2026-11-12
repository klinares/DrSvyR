# ui_generate.R for QuestionR
# The screens of the Generate flow: Brief, Prompt, Results and Run again, one
#   module each (DESIGN.md section 12). They hold no flow logic. They gather the
#   form, call the engine in R/flow.R, and draw what it returns; the dropdown,
#   the fields and the worker boxes all read the registry (TASKS) and the model
#   list (APP_MODELS), so a new task or worker needs no change here. This is the
#   second half of ui.R, the split DESIGN.md section 12 allows, which brings the
#   code files to ten of the ten it budgets. Function definitions and constants
#   only.


# ---- the one state object ---------------------------------------------------------

# Every module reads and writes this, and none talks to another. app.R makes it
#   from these. key_version changes whenever the pasted key is saved or forgotten.
#   form is the cleaned form the Brief tab handed on; approved is the prompt the
#   analyst approved (edited or not); run_id changes to start a run; the rest is
#   what the last run returned. kept is the items the analyst ticked.
STATE_DEFAULTS <- list(
  key_version = 0L, form = NULL, workers = NULL, brief = NULL, approved = NULL,
  run_id = 0L, round = 0L, drafts = NULL, appraisal = NULL, review = NULL, seed = NULL,
  kept = list(), revision = "", rounds = list())

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

# The function a run hands to the engine as `ask`. It says on the page, before
#   each call, which model is about to be asked, then makes the call through
#   llm_json(), which finds the key for that model. Must run inside withProgress().
#   total is how many calls the run will make.
progress_ask <- function(total) {
  n = 0L
  function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    n <<- n + 1L
    setProgress(value = (n - 1L) / total, message = paste0("Call ", n, " of ", total),
                detail = paste0("Asking ", m$id, ". The calls run one after another; ",
                                "this can take a few minutes."))
    llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens,
             validate = validate)
  }
}

task_choices <- function()
  purrr::set_names(names(TASKS), purrr::map_chr(TASKS, "label"))

# The names of the tasks a test picks out, as a JavaScript condition on the task
#   dropdown, so a field or a box is shown for those tasks only and keeps what
#   was typed in it when the task changes.
tasks_condition <- function(tasks)
  paste0(jsonlite::toJSON(tasks), ".indexOf(input.task) >= 0")

# The date and time as the log writes it.
now_label <- function() format(Sys.time(), "%Y-%m-%d %H:%M")


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
             "Each ticked model gets the same prompt, one after another. Fewer models cost less.")),
    uiOutput(ns("revision_note")),
    tags$div(
      actionButton(ns("check"), "Check the brief", class = "btn-primary"),
      actionButton(ns("skip"), "Skip the brief check")),
    tags$p(class = "text-muted small mt-2",
           "The brief check asks the project manager model what a designer would still ",
           "need to know. It needs the key from Start here. Skipping goes straight to the prompt."),
    uiOutput(ns("message")),
    uiOutput(ns("result")))
}

# A brief check's answer, on the page: whether the brief is complete, what is
#   missing (blocking first), whether another task fits, and the criteria that
#   will be applied. continue is the button that goes on to the prompt.
brief_panel <- function(res, ns) {
  if (identical(res$status, "skipped"))
    return(tags$p(class = "text-muted", "The brief check was skipped."))
  if (!identical(res$status, "ok"))
    return(warn_box(tags$strong("The brief check did not come back. "), res$error,
                    tags$br(), "You can try again, or skip it."))
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
        advice_box("Evaluate sends your questionnaire to the project manager model once, with ",
                   "the methodology files' checklist, and shows its findings question by question. ",
                   "The limit is ", format(APP_MAX_PASTE_CHARS, big.mark = ","), " characters; a longer ",
                   "questionnaire is reviewed in parts.")
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
                       " Or skip the check."))
        return()
      }
      state$form <- p$form
      state$workers <- p$workers
      state$brief <- tryCatch(
        withProgress(message = "Checking the brief", value = 0,
                     run_brief(p$form, pm, ask = make_ask(1L))),
        error = function(e) list(status = "failed", error = plain_message(e), reply = NULL))
    })

    observeEvent(input$skip, proceed(list(status = "skipped")))
    observeEvent(input$continue, proceed(NULL))

    output$message <- renderUI(if (!is.null(message())) warn_box(message()))
    output$result <- renderUI(safe_ui(if (!is.null(state$brief)) brief_panel(state$brief, session$ns)))
  })
}


# ---- tab 2: Prompt ----------------------------------------------------------------------------

mod_prompt_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$style(".qr-prompt textarea { font-family: monospace; font-size: 85%; }"),
    tags$h3(QUESTIONR_TABS[3]),
    tags$p("This is exactly what the workers will be sent. R assembled it from the form and ",
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

    assembled <- reactive({
      if (is.null(state$form)) return(NULL)
      tryCatch(build_prompt(state$form), error = function(e) e)
    })

    output$body <- renderUI(safe_ui({
      reset()
      a = assembled()
      if (is.null(a))
        return(tags$p(class = "text-muted", "Fill in the Brief tab, then continue from there."))
      if (inherits(a, "error"))
        return(warn_box("The prompt could not be assembled: ", plain_message(a)))
      draft = TASKS[[state$form$task]]$kind == "draft"
      tagList(
        tags$p(class = "text-muted small", "Skill files used: ", paste(a$files, collapse = ", ")),
        tags$div(class = "qr-prompt",
                 textAreaInput(session$ns("system"), "System prompt (the rules)", value = a$system,
                               rows = 12, width = "100%", resize = "vertical"),
                 textAreaInput(session$ns("user"), "Message (the brief, the ask, the reply format)",
                               value = a$user, rows = 14, width = "100%", resize = "vertical")),
        if (draft) tags$p(paste0(
          "Approving runs ", length(state$workers), if (length(state$workers) == 1L) " worker" else " workers",
          " one after another, then the appraisal by the project manager: ", length(state$workers) + 1L,
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
      if (is.null(a) || inherits(a, "error") || is.null(input$system)) return(NULL)
      sys = unix(input$system)
      usr = unix(input$user)
      if (identical(sys, a$system) && identical(usr, a$user))
        tags$p(class = "text-muted small", "As assembled. Hash ", tags$code(substr(a$hash, 1, 16)), ".")
      else warn_box(tags$strong("Edited. "), "Assembled hash ", tags$code(substr(a$hash, 1, 16)),
                    "; edited hash ", tags$code(substr(prompt_hash(sys, usr), 1, 16)), ".")
    }))

    observeEvent(input$approve, {
      message(NULL)
      a = assembled()
      if (is.null(a) || inherits(a, "error")) {
        message("There is no prompt to approve. Fill in the Brief tab first.")
        return()
      }
      sys = unix(input$system)
      usr = unix(input$user)
      if (!nzchar(trimws(sys)) || !nzchar(trimws(usr))) {
        message("The prompt is empty. Reset it to the assembled prompt, or write one.")
        return()
      }
      state$approved <- list(system = sys, user = usr, hash = prompt_hash(sys, usr), files = a$files,
                             edited = !identical(sys, a$system) || !identical(usr, a$user),
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

# Fails rated 5 or above are listed; the rest are folded away, as a review's
#   findings are (DESIGN.md section 13).
fail_list <- function(fails, checklist, none_text) {
  shown = purrr::keep(fails, function(f) f$shown)
  low = purrr::discard(fails, function(f) f$shown)
  tagList(
    if (length(shown)) tags$ul(class = "small", purrr::map(shown, fail_entry, checklist = checklist))
    else tags$p(class = "small", none_text),
    if (length(low)) tags$details(
      tags$summary(class = "small", paste0(length(low), if (length(low) == 1L) " fail" else " fails",
                                           " rated below 5")),
      tags$ul(class = "small", purrr::map(low, fail_entry, checklist = checklist))))
}

# What the appraiser said an item failed, with its words, and the check's question
#   from the checklist that was sent. An item the appraiser gave no entry is not
#   a pass: it says so.
fails_block <- function(fails, checklist, appraised, appraisal_ok) {
  if (!appraisal_ok)
    return(tags$p(class = "text-muted small", "Not appraised: the appraisal did not come back."))
  if (!appraised)
    return(tags$p(class = "text-warning small", "Not appraised: the appraiser gave this item no entry."))
  fail_list(fails, checklist, "No failed check rated 5 or above.")
}

# The fails about a candidate's set of items as a whole (keying, coverage, order),
#   which count against no single item.
set_fails_block <- function(set_fails, letter, checklist) {
  mine = purrr::keep(set_fails, function(f) identical(f$candidate, letter))
  if (!length(mine)) return(NULL)
  tagList(tags$h6(paste0("Across candidate ", letter, "'s whole set")),
          fail_list(mine, checklist, "No set-level fail rated 5 or above."))
}

# The input id of the tick box for item `position` of candidate `letter`.
keep_input <- function(letter, position) paste0("keep_", letter, "_", position)

item_card <- function(it, letter, position, ns, checklist, chk, appraisal_ok, language) {
  it = full_item(it)
  defaults = code_defaults(it, language)
  fails = purrr::keep(chk$fails %||% list(), function(f) identical(f$candidate, letter) && identical(f$id, it$id))
  appraised = !paste(letter, it$id, sep = "|") %in% chk$not_appraised
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
      if (identical(defaults$decisions, "not itemised"))
        tags$p(class = "mb-1", tags$span(class = "badge text-bg-warning", "decisions not itemised"),
               tags$span(class = "text-muted small", " The model wrote its design decisions as one string.")),
      tags$details(tags$summary(class = "small", "Coded defaults (by R, from the item as written)"),
                   defaults_table(defaults)),
      fails_block(fails, checklist, appraised, appraisal_ok),
      checkboxInput(ns(keep_input(letter, position)), "Keep this item", value = FALSE)))
}

candidate_panel <- function(letter, model, reply, ns, checklist, chk, appraisal_ok, language) {
  items = unname(reply$items)
  tagList(
    tags$h5(paste("Candidate", letter), tags$span(class = "text-muted small", " written by ", tags$code(model))),
    purrr::imap(items, function(it, i)
      item_card(it, letter, i, ns, checklist, chk, appraisal_ok, language)),
    if (appraisal_ok) set_fails_block(chk$set_fails, letter, checklist),
    if (length(reply$not_covered))
      tags$p(class = "text-muted small", "Domains this candidate left out: ",
             paste(purrr::map_chr(reply$not_covered, function(d) paste(unlist(d), collapse = " ")), collapse = "; ")),
    if (length(reply$missing_from_brief))
      tags$p(class = "text-muted small", "What it said the brief did not give: ",
             paste(purrr::map_chr(reply$missing_from_brief, function(d) paste(unlist(d), collapse = " ")), collapse = "; ")))
}

# The text of one item of one candidate, found by letter and id, as drafted.
find_item <- function(cands, letter, id) {
  hits = purrr::keep(unname(cands[[letter]]$items), function(it) identical(it$id, id))
  if (length(hits)) hits[[1]]
}

# Everything below the candidates: the coverage the appraiser reported, how the
#   candidates differ, the merged option built from items copied from the
#   candidates (R shows the candidates' own words, not the appraiser's), what to
#   test first, and what R found wrong with the appraisal itself.
appraisal_panel <- function(reply, chk, cands, language) {
  label = function(x) paste(unlist(x), collapse = " ")
  merged = reply$merged %||% list()
  tagList(
    tags$h4("The appraisal, across the candidates"),
    advice_box("An expert-review appraisal by a language model against a fixed checklist. ",
               "It compares; it does not choose, and nothing here is validated. It cannot show ",
               "how respondents will understand or answer. The appraiser saw the candidates ",
               "as A, B and C, without knowing which model wrote which."),
    if (length(chk$unknown_checks) || length(chk$unknown_items) || length(chk$merged_problems))
      warn_box(tags$strong("R's checks on the appraisal found: "), tags$ul(class = "mb-0", c(
        purrr::map(chk$unknown_checks, function(x) tags$li("It cited '", x, "', which is not a check that was sent.")),
        purrr::map(chk$unknown_items, function(x) tags$li("It gave an entry for ", x, ", which is no candidate's item.")),
        purrr::map(chk$merged_problems, tags$li)))),
    if (length(reply$coverage)) tagList(
      tags$h5("Coverage by domain"),
      tags$table(class = "table table-sm",
                 tags$thead(tags$tr(tags$th("Domain"), tags$th("Covered by"), tags$th("Items with no fail rated 5 or above"))),
                 tags$tbody(purrr::map(reply$coverage, function(r)
                   tags$tr(tags$td(label(r$domain)), tags$td(label(r$covered_by)),
                           tags$td(if (length(r$clean_items))
                             paste(purrr::map_chr(r$clean_items, label), collapse = "; ") else "none")))))),
    if (length(reply$differences)) tagList(
      tags$h5("How the candidates differ"),
      tags$ul(purrr::map(reply$differences, function(d) tags$li(label(d))))),
    tags$h5("Merged option"),
    tags$p(class = "text-muted small",
           "A fourth option, untested like the others. Each item is copied word for word from the ",
           "candidate named, and only from items with no fail rated 5 or above."),
    if (!length(merged)) tags$p("The appraiser offered no merged option.")
    else purrr::map(merged, function(m) {
      it = if (nzchar(m$candidate %||% "") && nzchar(m$id %||% "")) find_item(cands, m$candidate, m$id)
      if (is.null(it))
        tags$p(class = "text-muted",
               paste0(label(m$domain), ": no candidate item is free of a fail rated 5 or above."))
      else tags$div(class = "card mb-2", tags$div(
        class = "card-body py-2",
        tags$div(class = "text-muted small", paste0(label(m$domain), " · from candidate ", m$candidate)),
        tags$p(class = "mb-1", tags$strong(it$stem)), options_list(it$options, it$open_format %||% "")))
    }),
    if (length(reply$test_first)) tagList(
      tags$h5("What to test first"),
      tags$ul(purrr::map(reply$test_first, function(t)
        tags$li(paste0("Candidate ", t$candidate %||% "?", ", item ", t$id %||% "?", ": ", label(t$method)))))),
    if (nzchar(label(reply$limits))) tags$p(tags$em(label(reply$limits))))
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

# Findings at severity 5 and above are listed; the rest are folded away. A question
#   with no finding says none were found by this review, never that it has no problems.
review_findings <- function(rows, checklist) {
  as_rows = purrr::map(seq_len(nrow(rows)), function(i) as.list(rows[i, ]))
  shown = purrr::keep(as_rows, function(r) r$shown)
  low = purrr::discard(as_rows, function(r) r$shown)
  tagList(
    if (!length(as_rows)) tags$p(class = "small", "No problem was found by this review.")
    else if (!length(shown)) tags$p(class = "small", "No finding rated 5 or above.")
    else tags$ul(class = "small", purrr::map(shown, review_finding, checklist = checklist)),
    if (length(low)) tags$details(
      tags$summary(class = "small", paste0(length(low), if (length(low) == 1L) " finding" else " findings",
                                           " rated below 5")),
      tags$ul(class = "small", purrr::map(low, review_finding, checklist = checklist))))
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

# Everything the review said, question by question and then as a whole, with R's
#   flags on it. rv is run_review()'s result.
review_panel <- function(f, rv, round) {
  if (!identical(rv$status, "ok"))
    return(tagList(
      tags$p(class = "text-muted small", paste0("Round ", round, ".")),
      warn_box(tags$strong("The review did not come back. "), rv$error)))
  reply = rv$reply
  checklist = build_checklist(f)
  flags = check_review(reply, f)
  approved = attr(rv, "prompt")
  question = flags[flags$scope == "question", ]
  n_missing = sum(!question$evidence_found)
  n_unknown = sum(!flags$check_known)
  label = function(x) paste(unlist(x), collapse = " ")
  tagList(
    tags$p(class = "text-muted small",
           paste0("Round ", round, ". One review by the project manager. Prompt hash "),
           tags$code(substr(rv$hash, 1, 16)),
           if (isTRUE(approved$edited))
             paste0(" (edited; assembled hash ", substr(approved$original_hash, 1, 16), ")"), "."),
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

mod_results_server <- function(id, state, go = function(tab) invisible(NULL), make_ask = progress_ask) {
  moduleServer(id, function(input, output, session) {
    problem <- reactiveVal(NULL)
    result <- reactiveVal(NULL)

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
          list(review = run_review(f, pm, ask = make_ask(1L), prompt = approved))
        })
        else withProgress(message = "Running the workers", value = 0, {
          ask = make_ask(length(ws) + 1L)
          drafts = run_drafts(f, ws, ask = ask, prompt = approved)
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
      state$kept <- list()
      state$rounds <- c(state$rounds, list(
        if (review) flow_round(f, pm, brief = brief, review = out$review)
        else flow_round(f, pm, brief = brief, drafts = out$drafts, appraisal = out$appraisal, seed = seed)))
      result(list(form = f, round = state$round))
    }, ignoreInit = TRUE)

    # The items ticked, as the candidate letter, the item's position and its id.
    observe({
      r = result()
      req(r, state$drafts)
      cands = candidates_of(state$drafts, state$seed)
      state$kept <- purrr::list_flatten(unname(purrr::imap(cands, function(reply, letter)
        purrr::compact(purrr::imap(unname(reply$items), function(it, i)
          if (isTRUE(input[[keep_input(letter, i)]]))
            list(candidate = letter, position = i, id = it$id %||% ""))))))
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
        return(review_panel(f, state$review, r$round))
      drafts = state$drafts
      ap = state$appraisal
      approved = attr(drafts, "prompt")
      cands = candidates_of(drafts, state$seed)
      labels = labels_of(drafts, state$seed)
      checklist = build_checklist(f)
      appraisal_ok = identical(ap$status, "ok")
      chk = if (appraisal_ok) check_appraisal(ap$reply, cands, checklist)
            else list(fails = list(), not_appraised = character(0))
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
        if (!appraisal_ok) warn_box(tags$strong("The appraisal did not come back. "), ap$error,
                                    " The candidates are shown without it."),
        if (!length(cands)) tags$p("No candidate to show."),
        purrr::imap(cands, function(reply, letter)
          candidate_panel(letter, labels[[letter]], reply, session$ns, checklist, chk, appraisal_ok,
                          f$output_language)),
        if (appraisal_ok) appraisal_panel(ap$reply, chk, cands, f$output_language),
        tags$details(tags$summary(paste0("Criteria that were applied (", length(checklist), ")")),
                     tags$ul(class = "small", purrr::imap(as.list(checklist), function(q, id)
                       tags$li(tags$strong(id), ": ", q)))))
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
