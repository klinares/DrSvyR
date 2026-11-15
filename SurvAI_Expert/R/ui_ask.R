# ui_ask.R: the Ask tab. A question runs as an ExtendedTask (plan, search, answer); the answer
#   streams into the page and is replaced, when complete, by the rendered answer with formulas from
#   the store. Function definitions and constants only.

STREAM_EVERY_S <- 0.3   # how often the streaming answer is redrawn

ask_ui <- function(id) {
  ns = NS(id)
  my_data = bslib::accordion(open = FALSE, bslib::accordion_panel(
    "My data (optional)",
    tags$p(class = "small text-muted", "Variable names from your data file, so the R code uses them."),
    bslib::layout_columns(col_widths = c(4, 4, 4),
      textInput(ns("weight"), "Weight"), textInput(ns("strata"), "Strata"), textInput(ns("cluster"), "Cluster (PSU)"),
      textInput(ns("fpc"), "FPC"), textInput(ns("replicates"), "Replicate weights"), textInput(ns("outcomes"), "Outcome variables")),
    textInput(ns("design"), "About the design", width = "100%",
              placeholder = "e.g. two-stage sample of schools then students, 40 strata")))
  bslib::layout_columns(col_widths = c(7, 5),
    tagList(
      textAreaInput(ns("question"), "Your question", width = "100%", rows = 3),
      my_data,
      tags$div(style = "margin: 8px 0;", bslib::input_task_button(ns("ask"), "Ask", label_busy = "Working..."),
               actionButton(ns("new_topic"), "New topic"), textOutput(ns("topic"), inline = TRUE)),
      tags$div(id = ns("progress"), class = "text-muted small"),
      tags$div(id = ns("live"), class = "survai-live"),
      uiOutput(ns("answer"))),
    card_ui(ns("card")))
}

# Plain notes for whatever check_answer() flagged.
flag_notes <- function(ck) {
  n = function(k, one, many) if (k == 1) one else sprintf(many, k)
  c(if (length(ck$bad_cites)) paste("Cites a source that was not given:", paste(ck$bad_cites, collapse = ", ")),
    if (length(ck$bad_tokens)) paste("Formula token not among the formulas given:", paste(ck$bad_tokens, collapse = ", ")),
    if (ck$display_math) "The answer typed a display formula itself instead of using a stored one; check it against the sources.",
    if (!ck$code_parses) "The R code does not parse as written.",
    if (length(ck$unverified)) paste0(n(length(ck$unverified), "1 function not verified", "%d functions not verified"),
                                       " against the store: ", paste(ck$unverified, collapse = ", ")),
    if (ck$uncited) paste0(n(ck$uncited, "1 sentence has", "%d sentences have"), " no citation and no \"Not from the store\" label."))
}

source_lines <- function(src, open_input) tags$ol(class = "survai-sources small", style = "list-style: none; padding-left: 0;",
  pmap(list(src$label, src$description, src$doc_id, src$title, src$pages), function(l, d, doc, ti, pg) {
    course = str_match(doc, "_(SURV\\d+)/")[, 2]
    meta = paste(discard(c(if (!is.na(course)) course, ti, pg), function(x) !nzchar(x %||% "")), collapse = ", ")
    tags$li(HTML(open_link(open_input, l, paste0("<strong>", l, "</strong>"))), " ", d, tags$span(class = "text-muted", paste0(" (", meta, ")")))
  }))

ask_server <- function(id, state, con, asker = ask_async) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    context = reactiveVal(NULL)
    result = reactiveVal(NULL)
    shown = reactiveVal(NULL)
    send = function(el, html) session$sendCustomMessage("survai-html", list(id = ns(el), html = as.character(html)))
    task = ExtendedTask$new(function(question, key, ctx, my_data) {
      last = new.env()
      last$t = Sys.time() - 10
      asker(question, MODEL_PROFILE, key, con, ctx, my_data, open_input = ns("open"),
            on_stage = function(s) send("progress", c(plan = "Planning the search...", search = "Searching the store...",
                                                      answer = "Writing the answer...")[[s]]),
            on_text = function(txt) if (as.numeric(difftime(Sys.time(), last$t, units = "secs")) > STREAM_EVERY_S) {
              last$t = Sys.time()
              send("live", render_md(txt, math = FALSE))
            })
    }) |> bslib::bind_task_button("ask")

    observeEvent(input$ask, {
      q = str_squish(input$question %||% "")
      key = session_key(session$token)
      if (!nzchar(q)) return(showNotification("Type a question first.", type = "warning"))
      if (is.null(key)) return(showNotification("Paste your API key on Start here first.", type = "warning"))
      note = call_limit_note(2L, session$token)
      if (!is.null(note)) return(showNotification(note, type = "error", duration = NULL))
      add_calls(2L, session$token)
      state$calls = state$calls + 1L
      result(NULL)
      send("live", "")
      task$invoke(q, key, context(), map(set_names(names(DATA_FIELDS)), function(f) input[[f]] %||% ""))
    })

    observeEvent(task$status(), {
      if (task$status() == "success") {
        r = task$result()
        result(r)
        context(list(question = r$question, answer = r$answer))
        send("live", "")
        send("progress", sprintf("Planned in %.0f s, searched in %.1f s, answered in %.0f s.", r$sec[["plan"]], r$sec[["search"]], r$sec[["answer"]]))
      } else if (task$status() == "error") {
        send("live", "")
        send("progress", "")
        result(list(error = conditionMessage(tryCatch(task$result(), error = function(e) e))))
      }
    })

    observeEvent(input$new_topic, { context(NULL); result(NULL); shown(NULL); send("progress", ""); updateTextAreaInput(session, "question", value = "") })
    output$topic = renderText(if (is.null(context())) "" else "Follow-up: the last question and answer are kept.")

    output$answer = renderUI({
      r = result()
      if (is.null(r)) return(NULL)
      if (!is.null(r$error)) return(warn_box(tags$strong("The question could not be answered. "), r$error))
      notes = flag_notes(r$checks)
      tagList(HTML(r$html), if (length(notes)) tags$div(class = "survai-flags", map(notes, tags$div)),
              tags$h5("Sources", style = "margin-top: 1em;"), source_lines(r$gathered$sources, ns("open")))
    })

    observeEvent(input$open, {
      s = result()$gathered$sources
      if (!is.null(s) && input$open %in% s$label) shown(s$passage_id[s$label == input$open][1])
    })
    card_server("card", con, shown)
  })
}
