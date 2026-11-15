# ui_formulas.R: the Formulas tab. Searches the stored formulas; no model calls. Function
#   definitions and constants only.

FORMULA_RESULTS <- 40L

formulas_ui <- function(id) {
  ns = NS(id)
  v = read_vocab()
  courses = character()   # filled in by the server, from the store
  pick = function(name, label, choices) selectizeInput(ns(name), label, choices = choices, multiple = TRUE, width = "100%")
  bslib::layout_columns(col_widths = c(7, 5),
    tagList(
      textInput(ns("query"), "Search formulas", width = "100%", placeholder = "e.g. variance of the ratio estimator"),
      bslib::layout_columns(col_widths = c(3, 3, 3, 3),
        pick("role", "Role", v$value[v$facet == "role"]), pick("design", "Design", v$value[v$facet == "design"]),
        pick("topic", "Topic", v$value[v$facet == "topic"]), pick("course", "Course", courses)),
      checkboxInput(ns("general"), "General formulas only", value = TRUE),
      uiOutput(ns("results")), uiOutput(ns("detail"))),
    card_ui(ns("card")))
}

symbol_table <- function(symbols) {
  s = str_trim(unlist(str_split(symbols %||% "", ";")))
  s = s[nzchar(s)]
  if (!length(s)) return(tags$p(class = "text-muted small", "No symbols are defined in the text around it."))
  tags$table(class = "table table-sm small", tags$tbody(map(s, function(x) tags$tr(
    tags$td(HTML(kx(str_trim(str_extract(x, "^[^=]+")), FALSE) %|NA% htmltools::htmlEscape(str_extract(x, "^[^=]+")))),
    tags$td(str_trim(str_remove(x, "^[^=]+=\\s*")))))))
}

`%|NA%` <- function(a, b) if (is.na(a)) b else a

formulas_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    updateSelectizeInput(session, "course", choices = dbGetQuery(con, "SELECT DISTINCT course FROM docs WHERE course <> '' ORDER BY course")$course)
    found = reactive(find_formulas(con, input$query %||% "", role = input$role, design = input$design,
                                   general = if (isTRUE(input$general)) TRUE else NULL, k = FORMULA_RESULTS,
                                   topic = input$topic, course = input$course)) |> debounce(400)
    picked = reactiveVal(NULL)
    shown = reactiveVal(NULL)
    output$results = renderUI({
      f = found()
      if (!nrow(f)) return(tags$p(class = "text-muted", "No formula matches."))
      tags$div(style = "max-height: 320px; overflow-y: auto;", tags$ol(class = "small", map(seq_len(nrow(f)), function(i)
        tags$li(HTML(open_link(ns("pick"), f$group_id[i], htmltools::htmlEscape(f$name[i]))),
                tags$span(class = "text-muted", paste0(" (", f$course[i], ", ", f$title[i], ")"))))))
    })
    observeEvent(input$pick, picked(input$pick))
    output$detail = renderUI({
      g = picked()
      f = found()
      if (is.null(g) || !g %in% f$group_id) return(NULL)
      r = f[f$group_id == g, ][1, ]
      ids = unlist(r$place_ids)
      places = str_split_1(r$places, "; ")
      tagList(tags$hr(), tags$h5(r$name),
              tags$div(class = "survai-formula", HTML(kx(r$latex, TRUE) %|NA% htmltools::htmlEscape(r$latex))),
              tags$p(class = "small", tags$strong("Role: "), r$role, "; ", tags$strong("design: "), r$design),
              symbol_table(r$symbols),
              if (nzchar(r$condition %||% "")) tags$p(class = "small", tags$strong("Condition: "), r$condition),
              tags$p(class = "small", tags$strong(sprintf("Where it occurs (%d):", length(ids)))),
              tags$ul(class = "small", map2(ids, places, function(p, lab) tags$li(HTML(open_link(ns("open"), p, htmltools::htmlEscape(lab)))))))
    })
    observeEvent(input$open, shown(input$open))
    card_server("card", con, shown, empty = "Pick a formula, then a place where it occurs, to read the passage here.")
  })
}
