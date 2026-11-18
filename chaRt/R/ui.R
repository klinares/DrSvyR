# ui.R for chaRt
# What the analyst sees. Phase 0: the shared helpers, the office logo, the tab names, Start here and
#   the connection check. advice_box, warn_box, office_logo, model_label, mod_connect_ui and
#   mod_connect_server are copied from QuestionR/R/ui.R unchanged. Function definitions and
#   constants only.


# ---- the tabs ----------------------------------------------------------------

CHART_TABS <- c("Start here", "Data", "Codebook", "Explore", "Report", "Methodology")

# What a tab that a later phase builds says until then.
LATER_PHASE <- "Built in a later phase."


# ---- shared helpers (from QuestionR) -----------------------------------------

# A note to read, and a warning. Theme variables, with fallbacks, keep both legible in dark mode.
advice_box <- function(...)
  shiny::tags$div(style = paste("background: var(--bs-tertiary-bg); border-left: 3px solid var(--bs-primary);",
                                "color: var(--bs-body-color); padding: 8px 12px; margin: 12px 0;"), ...)

warn_box <- function(...)
  shiny::tags$div(style = paste("background: var(--bs-warning-bg-subtle, #fdf6ec); border-left: 3px solid var(--bs-warning, #d9a441);",
                                "color: var(--bs-warning-text-emphasis, var(--bs-body-color)); padding: 8px 12px; margin: 12px 0;",
                                "font-size: 90%;"), ...)

# The office logo named in app.R, from www/logo/; a dashed box until it exists.
office_logo <- function(file, office = "") {
  logo = if (file.exists(file.path("www", "logo", file)))
    tags$img(src = file.path("logo", file), alt = "Office logo", style = "height:48px;")
  else
    tags$div(style = paste("height:48px; width:160px; border:2px dashed #adb5bd;",
                           "border-radius:4px; color:#6c757d; font-size:12px;",
                           "display:flex; align-items:center; justify-content:center;"),
             "Office logo")
  tags$div(style = "display:flex; align-items:center; gap:12px;",
           logo,
           if (nzchar(office)) tags$span(style = "font-weight:600;", office))
}


# A button for a model call. Shiny runs the call before it draws again, so the button disables
#   itself in the browser and shows `busy` under it; the server draws it again, enabled, when the
#   call is done. ready = FALSE draws it disabled.
busy_button <- function(id, label, busy, ready = TRUE, class = "btn-primary") {
  busy_id = paste0(id, "_busy")
  tagList(actionButton(id, label, class = class, disabled = !ready,
                       onclick = paste0("this.disabled = true; document.getElementById('", busy_id, "').style.display = 'block';")),
          tags$p(id = busy_id, class = "text-muted small", style = "display:none; margin-top:0.25rem;", busy))
}

# What went wrong in a call, under the sentence: the reply as llm_json() reported it.
call_detail <- function(detail)
  if (!is.null(detail)) tags$details(tags$summary("What the model sent back"), tags$pre(substr(detail, 1, 1500)))


# ---- Start here --------------------------------------------------------------

# The model as the page names it: the id, the API style in words and where it is called.
#   Never the key.
model_label <- function(m)
  tagList(tags$code(m$id), tags$br(),
          tags$span(class = "text-muted small",
                    paste0(switch(m$api %||% "", anthropic = "Anthropic API", openai = "OpenAI-style API",
                                  paste0("API '", m$api, "'")),
                           " at ", m$base_url, "; key pasted below")))

# Start here: what the tool does, the key box, then the connection check.
start_ui <- function()
  tagList(
    tags$p("chaRt builds a codebook for a data file you bring, proposes and draws publishable charts ",
           "that follow written visualization rules, lets you refine a chart by chat, and writes an HTML ",
           "report of the charts you choose, each with a short summary of what it shows. Every chart and ",
           "summary describes the file, not a population."),
    mod_key_ui("key"),
    mod_connect_ui("connect"))

# A tab that a later phase builds.
later_ui <- function() tags$p(class = "text-muted", LATER_PHASE)


# ---- the connection check (from QuestionR) -----------------------------------

# The model, and whether it has a key; and a button that makes one very small call to it. Never
#   shows a key. With no key it is not called: it says what is missing. ping is the function that
#   calls the model, so a test can stand in for the network.
mod_connect_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$hr(),
    tags$h4("Settings and connection"),
    uiOutput(ns("models")),
    actionButton(ns("check"), "Check the connection"),
    tags$p(class = "text-muted small mt-2",
           "Makes one very small call to each model, and shows whether it answered ",
           "or what the endpoint said. Nothing you have entered is sent."),
    uiOutput(ns("result")))
}

mod_connect_server <- function(id, state, ping = llm_ping) {
  moduleServer(id, function(input, output, session) {
    results <- reactiveVal(NULL)

    output$models <- renderUI({
      state$key_version   # a key pasted or forgotten changes whether it is ready
      purrr::imap(app_models(), function(m, role)
        tags$p(tags$strong(role), tags$br(), model_label(m), tags$br(),
               if (length(llm_placeholders(m))) tags$span(class = "text-warning", "Waits for the settings in app.R.")
               else if (llm_key_ready(m)) tags$span(class = "text-success", "Ready.")
               else tags$span(class = "text-warning", paste("Waits for a key.", KEY_HINT))))
    })

    observeEvent(input$check, {
      withProgress(message = "Checking the connection", value = 0.5,
                   results(purrr::map(unname(app_models()), function(m)
                     c(list(model = m$id), if (llm_key_ready(m)) ping(m) else llm_ping(m)))))
    })

    output$result <- renderUI({
      out <- results()
      if (is.null(out)) return(NULL)
      tags$table(
        class = "table table-sm",
        tags$thead(tags$tr(tags$th("Model"), tags$th("Result"), tags$th("Seconds"))),
        tags$tbody(purrr::map(out, function(r)
          tags$tr(tags$td(tags$code(r$model)),
                  tags$td(tags$span(class = if (isTRUE(r$ok)) "text-success" else "text-danger",
                                    if (isTRUE(r$ok)) "Ready" else r$message)),
                  tags$td(if (is.na(r$seconds)) "" else sprintf("%.1f", r$seconds))))))
    })
  })
}


# ---- Data -----------------------------------------------------------------------------------

# The Data tab: a delimited file, what R found in it, and an optional saved codebook.
mod_data_ui <- function(id) {
  ns = NS(id)
  tagList(
    fileInput(ns("file"), paste0("Data file: CSV or other delimited text, up to ", APP_MAX_UPLOAD_MB, " MB"),
              accept = c(".csv", ".tsv", ".txt", ".tab"), width = "100%"),
    textAreaInput(ns("missing"), "Values that mean missing, one per line", rows = 2, width = "100%",
                  placeholder = "for example: ..\n-99"),
    tags$p(class = "text-muted small", "Blank cells and NA are always missing. Anything else is missing only if you list it here; ",
           "a value must match a whole cell."),
    selectInput(ns("encoding"), "File encoding", choices = encoding_choices(NULL), width = "100%"),
    tags$p(class = "text-muted small", "The encoding is guessed. If names with accents look wrong, choose another and read again: ",
           "windows-1252 for Western European files, ISO-8859-2 for Central European ones."),
    actionButton(ns("reread"), "Read again", class = "btn-sm mb-3"),
    uiOutput(ns("reread_note")),
    uiOutput(ns("summary")),
    tableOutput(ns("columns")),
    tags$hr(),
    fileInput(ns("codebook"), "Optional: a saved codebook.yaml for this file", accept = c(".yaml", ".yml"), width = "100%"),
    uiOutput(ns("codebook_note")))
}

# The File encoding choices: the guess first (its value is "", its label names what the guess
#   was), then DATA_ENCODINGS.
encoding_choices <- function(detected) {
  guess = if (is.null(detected)) "Detected" else paste0("Detected (", detected, ")")
  c(stats::setNames("", guess), stats::setNames(DATA_ENCODINGS, DATA_ENCODINGS))
}

mod_data_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    read_error = reactiveVal(NULL)
    codebook_note = reactiveVal(NULL)
    reread_note = reactiveVal(NULL)
    upload = reactiveVal(NULL)         # the data file as uploaded, kept so it can be read again
    detected = reactiveVal(NULL)       # the encoding the guess picked for that file

    # The encoding chosen on the tab: NULL for the guess.
    chosen_encoding = function() if (nzchar(input$encoding %||% "")) input$encoding
    # After a read: the guess's label names what it picked, and the select shows `selected`.
    show_encoding = function(res, selected) {
      if (is.null(selected) && !inherits(res, "error")) detected(res$read$encoding)
      updateSelectInput(session, "encoding", choices = encoding_choices(detected()), selected = selected %||% "")
    }

    # A read, or the error it met, into the shared state.
    take = function(res, codebook = res$codebook) {
      if (inherits(res, "error")) {
        read_error(conditionMessage(res))
        state$data = NULL; state$problems = NULL; state$profile = NULL; state$codebook = NULL; state$path = NULL
        return(invisible(FALSE))
      }
      read_error(NULL)
      state$path = isolate(upload())$path
      state$data = res$read$data
      state$problems = res$read$problems
      state$profile = res$profile
      state$codebook = codebook
      invisible(TRUE)
    }

    observeEvent(input$file, {
      f = input$file
      upload(list(path = f$datapath, name = f$name))
      codebook_note(NULL); reread_note(NULL); detected(NULL)
      res = tryCatch(reread_data(f$datapath, f$name, parse_missing(input$missing)), error = function(e) e)
      take(res)
      show_encoding(res, NULL)
    })

    # The same upload read again with the values that mean missing; what the analyst entered in
    #   the codebook is kept for every column whose name is unchanged.
    observeEvent(input$reread, {
      u = upload()
      if (is.null(u)) return(reread_note(warn_box("Choose a data file first.")))
      enc = chosen_encoding()
      res = tryCatch(reread_data(u$path, u$name, parse_missing(input$missing), old = state$codebook, encoding = enc),
                     error = function(e) e)
      ok = take(res)
      show_encoding(res, enc)
      if (ok)
        reread_note(if (length(res$notes)) warn_box(tags$ul(purrr::map(res$notes, tags$li)))
                    else advice_box("Read again. Your labels, roles and row sentence are kept."))
    })

    output$reread_note = renderUI(reread_note())

    # A saved codebook: the file is first read again with its missing_codes and its encoding, then
    #   the codebook is applied only when check_codebook() has nothing to say about it.
    observeEvent(input$codebook, {
      u = upload()
      if (is.null(u)) return(codebook_note(warn_box("Read the data file first, then the codebook.")))
      up = tryCatch(read_codebook(input$codebook$datapath), error = function(e) e)
      if (inherits(up, "error")) return(codebook_note(warn_box(conditionMessage(up))))
      codes = missing_codes(up)
      res = tryCatch(reread_data(u$path, u$name, codes, encoding = up$encoding), error = function(e) e)
      if (inherits(res, "error")) return(codebook_note(warn_box(conditionMessage(res))))
      why = check_codebook(up, res$profile)
      if (length(why))
        return(codebook_note(warn_box(tags$strong("The codebook was not applied."), tags$ul(purrr::map(why, tags$li)))))
      take(res, apply_codebook(up, res$profile, u$name, nrow(res$read$data), res$read$encoding))
      updateTextAreaInput(session, "missing", value = paste(codes, collapse = "\n"))
      show_encoding(res, up$encoding)
      reread_note(NULL)
      codebook_note(advice_box("The codebook was applied: its values that mean missing, encoding, labels, types, roles and row ",
                               "sentence are in use; every fact comes from the file."))
    })

    output$codebook_note = renderUI(codebook_note())

    output$summary = renderUI({
      if (!is.null(read_error())) return(warn_box(read_error()))
      if (is.null(state$data)) return(NULL)
      tagList(
        tags$p(tags$strong(state$codebook$file),
               paste0(": ", format_num(nrow(state$data)), " rows, ", format_num(ncol(state$data)), " columns.")),
        if (length(state$problems)) warn_box(tags$ul(purrr::map(state$problems, tags$li)))
        else tags$p(class = "text-success", "No problems found."))
    })

    output$columns = renderTable({
      prof = state$profile
      if (is.null(prof) || !is.null(read_error())) return(NULL)
      data.frame(Column = purrr::map_chr(prof, "name"), Type = purrr::map_chr(prof, "type"),
                 Missing = sprintf("%.2f", purrr::map_dbl(prof, "missing")),
                 Distinct = format_num(purrr::map_int(prof, function(p) as.integer(p$distinct))))
    }, striped = TRUE, spacing = "xs")
  })
}


# ---- Codebook -------------------------------------------------------------------------------

CODEBOOK_PAGE_SIZE <- 25L
LABEL_BUSY <- "The model is reading the column summaries, not the rows. This can take a minute."

# The Codebook tab: what one row represents, then the columns, CODEBOOK_PAGE_SIZE to a page.
mod_codebook_ui <- function(id) {
  ns = NS(id)
  tagList(uiOutput(ns("status")), uiOutput(ns("suggest")), uiOutput(ns("page")), uiOutput(ns("footer")))
}

# The page is drawn from the codebook only when the page, a type or the whole codebook changes,
#   so typing in a box is never interrupted by a redraw. Input ids carry a generation number, so a
#   box left over from an earlier codebook or page is never read into this one.
mod_codebook_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    page = reactiveVal(1L)
    gen = reactiveVal(0L)
    mine = reactiveVal(NULL)           # the codebook as this module last wrote it
    order_notes = reactiveVal(character(0))
    calls_done = reactiveVal(0L)       # bumped after a label call, so its button is drawn again
    label_note = reactiveVal(NULL)
    guess = reactiveVal(NULL)          # the model's row_is_guess, offered while row_is is blank
    input_id = function(what, i) paste0("g", gen(), "_", what, "_", i)
    # A codebook this module wrote, drawn again on the same page.
    write_here = function(new) { mine(new); state$codebook = new; gen(isolate(gen()) + 1L) }
    on_page = function(cb) {
      n = length(cb$columns)
      if (!n) return(integer(0))
      seq.int((page() - 1L) * CODEBOOK_PAGE_SIZE + 1L, min(n, page() * CODEBOOK_PAGE_SIZE))
    }

    # A codebook this module did not write (a new file, an applied codebook): start again on page 1.
    observeEvent(state$codebook, {
      if (!identical(state$codebook, mine())) {
        mine(state$codebook); page(1L); order_notes(character(0)); guess(NULL); label_note(NULL); gen(gen() + 1L)
      }
    }, ignoreNULL = FALSE)

    observeEvent(input$prev, { page(max(1L, page() - 1L)); gen(gen() + 1L) })
    observeEvent(input$`next`, {
      last = max(1L, ceiling(length(state$codebook$columns) / CODEBOOK_PAGE_SIZE))
      page(min(last, page() + 1L)); gen(gen() + 1L)
    })

    output$status = renderUI({
      cb = state$codebook
      if (is.null(cb)) return(tags$p(class = "text-muted", "Start on the Data tab: read a file there first."))
      unnamed = sum(purrr::map_lgl(cb$columns, function(e) identical(e$label, e$name)))
      guessed = sum(purrr::map_lgl(cb$columns, function(e) identical(e$label_source, "ai_guess")))
      tagList(
        if (!codebook_ready(cb)) warn_box("Charts cannot be drawn until you say what one row represents."),
        tags$p(paste0(format_num(unnamed), " of ", format_num(length(cb$columns)), " labels are still the column name; ",
                      format_num(guessed), if (guessed == 1L) " AI guess is" else " AI guesses are", " not yet accepted.")),
        if (length(order_notes())) warn_box(tags$ul(purrr::map(order_notes(), tags$li))))
    })

    # Suggest labels: one label call per CODEBOOK_MAX_DETAIL columns. Only labels still the file's
    #   own change; the page is drawn again where it was.
    output$suggest = renderUI({
      state$key_version; calls_done()
      if (is.null(state$codebook)) return(NULL)
      ready = llm_key_ready()
      tags$div(class = "my-2",
               busy_button(ns("suggest_labels"), "Suggest labels", LABEL_BUSY, ready = ready),
               if (!ready) tags$p(class = "text-muted small", "Suggest labels needs a key. ", KEY_HINT),
               label_note())
    })

    observeEvent(input$suggest_labels, {
      cb = state$codebook
      if (is.null(cb)) return()
      res = label_columns(cb)
      state$calls = dplyr::bind_rows(state$calls, res$calls)
      if (!is.null(res$error)) {
        label_note(warn_box(res$error, call_detail(res$detail)))
      } else {
        landed = sum(purrr::map2_lgl(cb$columns, res$codebook$columns, function(a, b) !identical(a$label, b$label)))
        unsure = sum(purrr::map_lgl(res$codebook$columns, function(e) identical(e$label_source, "ai_guess") && identical(e$sure, FALSE)))
        label_note(advice_box(paste0(format_num(landed), " labels were suggested",
                                     if (unsure) paste0(", ", unsure, " of them marked 'check this'"),
                                     ". Labels you wrote were not changed. Edit a label or tick Accept to make it yours.")))
        guess(res$row_is_guess)
        write_here(res$codebook)
      }
      calls_done(calls_done() + 1L)
    })

    observeEvent(input$use_guess, {
      new = state$codebook
      if (is.null(new) || is.null(guess())) return()
      new$row_is = guess()
      write_here(new)
    })

    observeEvent(input$accept_all, {
      cb = state$codebook
      if (is.null(cb)) return()
      idx = on_page(cb)
      new = cb
      new$columns[idx] = purrr::map(cb$columns[idx], accept_label)
      if (!identical(new, cb)) { mine(new); state$codebook = new }
    })

    output$page = renderUI({
      gen()
      cb = isolate(state$codebook)
      if (is.null(cb)) return(NULL)
      idx = isolate(on_page(cb))
      n = length(cb$columns)
      offer = isolate(guess())
      offer = if (!codebook_ready(cb) && !is.null(offer)) offer
      # The tag beside each label follows the codebook, so it goes when the label is edited or accepted.
      purrr::walk(idx, function(i) {
        output[[input_id("tag", i)]] = renderUI(label_tag(state$codebook$columns[[i]], ns(input_id("accept", i))))
      })
      tagList(
        tags$div(class = "d-flex align-items-end gap-2",
                 tags$div(style = "flex:1;",
                          textInput(ns(input_id("row_is", 0L)), "What does one row represent?", value = cb$row_is, width = "100%",
                                    placeholder = offer %||% "for example: one order, or one country in one year")),
                 if (!is.null(offer)) tags$div(class = "mb-3", actionButton(ns("use_guess"), "Use this", class = "btn-sm"))),
        tags$div(class = "d-flex align-items-center gap-2 my-2",
                 actionButton(ns("prev"), "Previous", class = "btn-sm"),
                 tags$span(paste0("Columns ", if (n) idx[1] else 0L, " to ", if (n) idx[length(idx)] else 0L, " of ", n)),
                 actionButton(ns("next"), "Next", class = "btn-sm"),
                 actionButton(ns("accept_all"), "Accept all AI labels on this page", class = "btn-sm btn-outline-secondary ms-auto")),
        purrr::map(idx, function(i) codebook_row(cb$columns[[i]], function(what) ns(input_id(what, i)))))
    })

    output$footer = renderUI(if (!is.null(state$codebook)) downloadButton(ns("download"), "Download codebook.yaml"))
    output$download = downloadHandler(filename = "codebook.yaml", content = function(file) write_codebook(state$codebook, file))

    # Every box on the page, read together; what differs from the codebook is written to it. A
    #   changed type redraws the page, since it changes the role and may add the order box.
    observe({
      gen()                            # read first: a new codebook or page re-runs this
      cb = isolate(state$codebook)
      if (is.null(cb)) return()
      idx = isolate(on_page(cb))
      row_is = input[[input_id("row_is", 0L)]]
      vals = purrr::map(idx, function(i) list(label = input[[input_id("label", i)]], type = input[[input_id("type", i)]],
                                              role = input[[input_id("role", i)]], order = input[[input_id("order", i)]],
                                              accept = input[[input_id("accept", i)]]))
      new = cb
      if (!is.null(row_is)) new$row_is = row_is
      edited = purrr::map2(cb$columns[idx], vals, function(e, v) {
        type_changed = !is.null(v$type) && !identical(v$type, e$type)
        order = if (!type_changed && !is.null(v$order)) parse_lines(v$order)
        note = if (!is.null(order) && identical(e$type, "ordered") && !order_ok(order, e))
          paste0("The order for ", e$name, " was not accepted: list exactly these levels, one per line: ",
                 paste(e$values, collapse = " | "), ".")
        entry = edit_entry(e, label = v$label, type = v$type, role = if (!type_changed) v$role, order = order)
        list(entry = if (isTRUE(v$accept)) accept_label(entry) else entry, note = note, retyped = type_changed)
      })
      new$columns[idx] = purrr::map(edited, "entry")
      order_notes(unlist(purrr::map(edited, "note")))
      if (!identical(new, cb)) {
        mine(new)
        state$codebook = new
        if (any(purrr::map_lgl(edited, "retyped"))) gen(isolate(gen()) + 1L)
      }
    })
  })
}

# One column of the codebook as plain inputs: the name, the label, the type, the role, the order
#   of an ordered column's levels, and the facts in small grey text.
codebook_row <- function(e, id)
  tags$div(class = "row g-2 align-items-end border-bottom py-2",
    tags$div(class = "col-md-2", tags$code(e$name)),
    tags$div(class = "col-md-4", textInput(id("label"), NULL, value = e$label, width = "100%")),
    tags$div(class = "col-md-2", selectInput(id("type"), NULL, choices = type_choices(e), selected = e$type,
                                             selectize = FALSE, width = "100%")),
    tags$div(class = "col-md-2", selectInput(id("role"), NULL, choices = role_choices(e), selected = e$role,
                                             selectize = FALSE, width = "100%")),
    tags$div(class = "col-md-2 small", uiOutput(id("tag"))),
    if (identical(e$type, "ordered"))
      tags$div(class = "col-12", textAreaInput(id("order"), "Levels in order, one per line",
                                               value = paste(e$order, collapse = "\n"), width = "100%",
                                               rows = min(length(e$order), CODEBOOK_MAX_LEVELS))),
    tags$div(class = "col-12 small text-muted", facts_text(e)))

# Beside a label: "AI guess" (and "check this" when the model was not sure) with an Accept box, or
#   where the label came from.
label_tag <- function(e, accept_id) {
  if (is.null(e)) return(NULL)
  if (!identical(e$label_source, "ai_guess")) return(tags$span(class = "text-muted", paste("label:", e$label_source)))
  tagList(tags$span(class = "badge bg-warning text-dark", "AI guess"),
          if (!isTRUE(e$sure)) tags$span(class = "text-danger ms-1", "check this"),
          checkboxInput(accept_id, "Accept", value = FALSE))
}


# ---- Explore --------------------------------------------------------------------------------

EXPLORE_BUSY <- "The model is choosing charts from the codebook; it does not see the rows. This can take a minute or two."
CSS_PPI <- 96                # a CSS inch, in CSS pixels: a static chart is shown at its size in inches
EXPLORE_PALETTE_KINDS <-c(qualitative = "Groups", sequential = "Sequential fill", diverging = "Diverging fill")

# The Explore tab: a question, or a request for suggestions, drawn as charts the renderer checked.
mod_explore_ui <- function(id) {
  ns = NS(id)
  def = chart_palette_default()
  tagList(
    uiOutput(ns("gate")),
    textAreaInput(ns("question"), "What do you want to see?", width = "100%", rows = 2,
                  placeholder = "for example: Which regions grew most between 2015 and 2024?"),
    uiOutput(ns("buttons")),
    tags$div(class = "d-flex gap-3 flex-wrap my-2",
             purrr::imap(EXPLORE_PALETTE_KINDS, function(label, kind)
               selectInput(ns(paste0("pal_", kind)), label, choices = stats::setNames(names(chart_palettes(kind)), chart_palettes(kind)),
                           selected = def[[kind]], selectize = FALSE, width = "220px"))),
    uiOutput(ns("results")),
    tags$hr(),
    uiOutput(ns("foot")))
}

mod_explore_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    res = reactiveVal(NULL)            # what suggest_charts() returned for the last request
    rgen = reactiveVal(0L)             # one number per request, in the ids of its cards
    calls_done = reactiveVal(0L)
    note = reactiveVal(NULL)
    rule_labels = reflex_labels()

    # The report's palettes; changing one draws the charts again and makes no call.
    palette = reactive(purrr::map(purrr::set_names(names(EXPLORE_PALETTE_KINDS)), function(kind)
      input[[paste0("pal_", kind)]] %||% chart_palette_default()[[kind]]))
    observe(state$palette <- palette())

    ready = reactive(codebook_ready(state$codebook) && !is.null(state$data))
    output$gate = renderUI({
      if (is.null(state$codebook)) return(warn_box("Read a data file on the Data tab first."))
      if (!codebook_ready(state$codebook)) return(warn_box("Say what one row represents on the Codebook tab first; charts are drawn only after that."))
      NULL
    })

    output$buttons = renderUI({
      state$key_version; calls_done()
      can = ready() && llm_key_ready()
      tagList(tags$div(class = "d-flex gap-2",
                       busy_button(ns("draw"), "Draw", EXPLORE_BUSY, ready = can),
                       busy_button(ns("suggest"), "Suggest charts for this file", EXPLORE_BUSY, ready = can, class = "btn-outline-primary")),
              if (ready() && !llm_key_ready()) tags$p(class = "text-muted small", "Drawing needs a key. ", KEY_HINT),
              note())
    })

    run = function(question) {
      note(NULL)
      out = suggest_charts(state$codebook, state$data, question, palette = palette())
      state$calls = dplyr::bind_rows(state$calls, out$calls)
      res(out); rgen(rgen() + 1L)
      calls_done(calls_done() + 1L)
    }
    observeEvent(input$draw, {
      q = trimws(input$question %||% "")
      if (!nzchar(q)) { note(warn_box("Type a question first, or use Suggest charts for this file.")); return(calls_done(calls_done() + 1L)) }
      run(q)
    })
    observeEvent(input$suggest, run(NULL))

    # One card per chart. Its outputs are made here, with the request's number in their ids.
    observeEvent(rgen(), {
      out = res()
      if (is.null(out)) return()
      g = rgen()
      purrr::iwalk(out$charts, function(ch, i) {
        cid = function(what) paste0("r", g, "_", what, "_", i)
        drawn = reactive(tryCatch(spec_plot(ch$spec, state$data, state$codebook, palette()), error = function(e) e))
        # Drawn at SPEC_DPI pixels per inch and shown at its size in inches, so it is sharper, not larger.
        output[[cid("static")]] = renderImage({
          p = drawn()
          if (inherits(p, "error")) stop(conditionMessage(p), call. = FALSE)
          f = tempfile(fileext = ".png")
          size = spec_png(p, f)
          list(src = f, contentType = "image/png", alt = attr(p, "spec")$title %||% "chart",
               width = round(size[["width"]] * CSS_PPI), height = round(size[["height"]] * CSS_PPI),
               style = "max-width:100%; height:auto;")
        }, deleteFile = TRUE)
        output[[cid("widget")]] = plotly::renderPlotly({
          p = drawn()
          if (inherits(p, "error")) stop(conditionMessage(p), call. = FALSE)
          spec_widget(p)
        })
        output[[cid("view")]] = renderUI({
          if ((input[[cid("interactive")]] %||% 0L) %% 2L == 1L) plotly::plotlyOutput(ns(cid("widget")), height = "450px")
          else imageOutput(ns(cid("static")), height = "auto")
        })
        output[[cid("notes")]] = renderUI({
          p = drawn()
          if (inherits(p, "error")) return(warn_box(conditionMessage(p)))
          if (length(attr(p, "notes"))) tags$ul(class = "small", purrr::map(attr(p, "notes"), tags$li))
        })
        output[[cid("code")]] = renderUI({
          if ((input[[cid("show_code")]] %||% 0L) %% 2L == 0L) return(NULL)
          code = tryCatch(spec_code(ch$spec, state$codebook, state$path, palette()), error = function(e) conditionMessage(e))
          tags$pre(class = "small", paste(code, collapse = "\n"))
        })
        observeEvent(input[[cid("add")]], {
          state$report = c(state$report, list(ch$spec))
          showNotification(paste0("Added to the report (", length(state$report), " in all)."), type = "message")
        }, ignoreInit = TRUE)
      })
    })

    output$results = renderUI({
      out = res()
      if (is.null(out)) return(NULL)
      g = rgen()
      cid = function(what, i) ns(paste0("r", g, "_", what, "_", i))
      cards = purrr::imap(out$charts, function(ch, i) {
        rule = ch$spec$rule
        bslib::card(
          uiOutput(cid("view", i)),
          uiOutput(cid("notes", i)),
          if (is_text1(ch$spec$say)) tags$p(ch$spec$say),
          tags$p(class = "small text-muted",
                 if (!is.null(rule) && !is.na(rule_labels[rule])) paste0("Rule: ", rule_labels[[rule]]),
                 if (isTRUE(ch$exploratory)) tags$span(class = "badge bg-secondary ms-1", "Exploratory")),
          tags$div(class = "d-flex gap-2 flex-wrap",
                   actionButton(cid("add", i), "Add to report", class = "btn-sm btn-primary"),
                   actionButton(cid("interactive", i), "Interactive view", class = "btn-sm"),
                   actionButton(cid("show_code", i), "Show code", class = "btn-sm")),
          uiOutput(cid("code", i)))
      })
      tagList(
        if (!is.null(out$error)) warn_box(out$error, call_detail(out$detail)),
        if (length(out$cannot)) advice_box(purrr::map(out$cannot, tags$p)),
        if (length(cards)) do.call(bslib::layout_column_wrap, c(list(width = 1 / 2), cards)),
        if (is.null(out$error) && !length(cards) && !length(out$cannot) && !length(out$failed))
          tags$p(class = "text-muted", "The model returned no charts."),
        if (length(out$failed))
          tags$div(tags$h5("Could not be drawn"),
                   tags$ul(purrr::map(out$failed, function(f)
                     tags$li(tags$strong(paste0("Chart ", f$number, if (is_text1(f$spec$title)) paste0(", '", f$spec$title, "'"), ": ")),
                             paste(f$sentences, collapse = " "))))))
    })

    output$foot = renderUI({
      calls = state$calls
      n = if (is.null(calls)) 0L else nrow(calls)
      tin = if (n) sum(calls$tokens_in, na.rm = TRUE) else 0
      tcache = if (n) sum(calls$tokens_cached, na.rm = TRUE) else 0
      tout = if (n) sum(calls$tokens_out, na.rm = TRUE) else 0
      tags$p(class = "small text-muted", paste0("Model calls this session: ", format_num(n), "; tokens in ", format_num(tin),
                                                " (and ", format_num(tcache), " read from the cache), out ", format_num(tout), "."))
    })
  })
}


# ---- Report ---------------------------------------------------------------------------------

# The Report tab is a later phase; until then it shows how many charts were added to it.
mod_report_ui <- function(id) uiOutput(NS(id)("count"))

mod_report_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    output$count = renderUI({
      n = length(state$report)
      tags$p(paste0(format_num(n), if (n == 1L) " chart has" else " charts have", " been added to the report. ", LATER_PHASE))
    })
  })
}
