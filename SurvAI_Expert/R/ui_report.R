# ui_report.R: the Report reader tab. Function definitions and constants only.

report_ui <- function(id) {
  ns = NS(id)
  tagList(
    tags$p("Upload a survey's technical or methodology report (PDF or Word). It is read by the model, not searched in the store, ",
           "and summarized in a fixed checklist: the design, the weights, variance estimation, and a design call for R, with page numbers."),
    fileInput(ns("file"), NULL, accept = c(".pdf", ".docx"), buttonLabel = "Choose a report", width = "100%"),
    uiOutput(ns("about")),
    bslib::input_task_button(ns("read"), "Read the report", label_busy = "Reading..."),
    tags$div(style = "margin-top: 1em;", uiOutput(ns("summary"))))
}

report_server <- function(id, state, reader = read_report_async) {
  moduleServer(id, function(input, output, session) {
    rep = reactive({ req(input$file); report_text(input$file$datapath, input$file$name) })
    output$about = renderUI({
      r = rep()
      if (!is.null(r$note)) return(warn_box(r$note))
      chars = sum(nchar(r$pages))
      calls = report_calls(report_parts(r$pages))
      tags$p(sprintf("%s: %s, %s characters. Reading it will use %d model call%s%s.", input$file$name,
                     if (r$paged) paste(length(r$pages), "pages") else "a Word file (no page numbers)",
                     format(chars, big.mark = ","), calls, if (calls == 1) "" else "s",
                     if (calls > 1) sprintf(" (it is split into %d parts, then combined)", calls - 1L) else ""))
    })
    task = ExtendedTask$new(function(r, key) reader(r, MODEL_PROFILE, key)) |> bslib::bind_task_button("read")
    observeEvent(input$read, {
      r = rep()
      key = session_key(session$token)
      if (!is.null(r$note)) return(showNotification(r$note, type = "warning"))
      if (is.null(key)) return(showNotification("Paste your API key on Start here first.", type = "warning"))
      n = report_calls(report_parts(r$pages))
      note = call_limit_note(n, session$token)
      if (!is.null(note)) return(showNotification(note, type = "error", duration = NULL))
      add_calls(n, session$token)
      state$calls = state$calls + 1L
      task$invoke(r, key)
    })
    output$summary = renderUI({
      if (task$status() == "error") return(warn_box(tags$strong("The report could not be read. "),
                                                    conditionMessage(tryCatch(task$result(), error = function(e) e))))
      if (task$status() != "success") return(NULL)
      x = task$result()
      tagList(HTML(render_md(x$text)), tags$p(class = "small text-muted", sprintf("%d model call%s.", x$calls, if (x$calls == 1) "" else "s")))
    })
  })
}
