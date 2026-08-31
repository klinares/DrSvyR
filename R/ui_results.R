# ui_results.R for DrSvyR
# Screens 9 to 11: scoring, results, outputs.

# Merged from: 
#   mod_score.R
#   mod_domains.R
#   mod_report.R

# ---- mod_score ---------------------------------------------------------

# mod_score.R for WISE repo
# Stage 9: score respondents and say who was reached.

# No model call here. Nothing on this screen is a matter of interpretation.

mod_score_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("runner")),
    uiOutput(ns("body"))
  )
}


mod_score_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$labels))
        tags$p(class = "text-muted", "Settle the names first.")
    })

    output$runner <- renderUI({
      req(state$labels)
      tagList(
        tags$h4("Score respondents"),
        help_box("scoring"),
        actionButton(ns("run"), "Score", class = "btn-primary"))
    })

    observeEvent(input$run, {
      req(state$labels)
      res <- try(withProgress(message = "Scoring", value = 0.4, {
        sc <- score_lca(state)

        setProgress(0.75, message = "Building the design")
        # The design is rebuilt on the scored frame rather than reused. Case
        #   exclusions can create singleton strata the released file does not
        #   have, and that has to fail here rather than silently contribute
        #   zero variance later.
        reached <- if (identical(state$cfg$arm, "lca")) !is.na(sc$segment)
                   else sc$scored
        des <- build_rep_design(sc[reached, ], state$cfg)

        list(scored = sc, design = des,
             coverage = score_coverage(sc, state$cfg$arm,
                                       length(state$cfg$items)),
             quality = assignment_quality(sc, state$cfg$arm),
             shares = group_shares(sc, state$cfg$arm, state$labels,
                                   des$rep_des))
      }), silent = TRUE)

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }

      state$scored <- res$scored
      state$score_design <- res$design
      state$coverage <- res$coverage
      state$quality <- res$quality
      state$shares <- res$shares

      log_decision(
        "labels", "Respondents scored",
        decision = paste0(
          res$coverage$n[3], " of ", res$coverage$n[1],
          " respondents scored; the measurement model was fitted on ",
          res$coverage$n[2], "."),
        evidence = log_table(res$coverage))

      showNotification("Scored. Continue to Domains.", type = "message",
                       duration = NULL)
    })

    output$body <- renderUI({
      req(state$coverage)
      lca <- identical(state$cfg$arm, "lca")
      tagList(
        tags$hr(),
        tags$h4("Who was reached"),
        tableOutput(ns("coverage")),

        if (lca) tagList(
          tags$hr(),
          tags$h4("Where the groups sit"),
          help_box("shares"),
          tableOutput(ns("shares")),

          tags$hr(),
          tags$h4("How certain the assignments are"),
          help_box("quality"),
          plotOutput(ns("quality_plot"), height = "300px"),
          tableOutput(ns("quality")))
        else NULL)
    })

    output$coverage <- renderTable({
      req(state$coverage)
      state$coverage |>
        transmute(Respondents = group, n = format(n, big.mark = ","),
                  `%` = percent)
    }, width = "100%")

    output$shares <- renderTable({
      req(state$shares)
      state$shares |>
        transmute(Group = group, n = n, Unweighted = unweighted,
                  Weighted = weighted, SE = se)
    }, width = "100%")

    output$quality <- renderTable({ req(state$quality); state$quality },
                                  width = "100%")

    output$quality_plot <- renderPlot({
      req(state$quality)
      plot_assignment_quality(state$quality)
    }, bg = "transparent")
  })
}

# ---- mod_domains -------------------------------------------------------

# mod_domains.R for WISE repo
# Stage 10: how the groups or scores are distributed across the domains.

# The model reads these tables only after R has decided which differences the
#   analysis resolves. It is handed the list and told to translate it. It never
#   sees a standard error and never decides significance for itself.

mod_domains_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("runner")),
    uiOutput(ns("body"))
  )
}


mod_domains_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$scored))
        tags$p(class = "text-muted", "Score respondents first.")
    })

    output$runner <- renderUI({
      req(state$scored)
      tagList(
        tags$h4("Domain estimates"),
        help_box("domains"),
        tags$p(length(state$cfg$aux), " domain(s). The corrected column ",
               "refits inside every replicate, so this takes a few minutes."),
        actionButton(ns("run"), "Estimate", class = "btn-primary"))
    })

    observeEvent(input$run, {
      req(state$scored)
      res <- try(withProgress(message = "Estimating", value = 0, {
        # Four steps in both arms now that the factor arm computes its
        #   contrasts too: unweighted, design-based, corrected, contrasts.
        tick <- function(what) incProgress(1 / 4, detail = what)
        out <- domains_lca(state, tick)
        out$marg <- domain_marginals(
          if (identical(state$cfg$arm, "lca"))
            filter(state$scored, !is.na(segment)) else filter(state$scored, scored),
          state$cfg$aux, state$score_design$rep_des)
        out
      }), silent = TRUE)

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$domains <- res
      state$domain_reads <- NULL
      showNotification("Estimated. Read each domain below.", type = "message")
    })

    output$body <- renderUI({
      req(state$domains)
      tagList(
        tags$hr(),
        help_box("invariance"),

        tags$h4("What the design costs"),
        help_box("estimator_gap"),
        tableOutput(ns("gap")),

        tags$hr(),
        selectInput(ns("which"), "Domain", choices = state$cfg$aux,
                    width = "40%"),
        plotOutput(ns("plot"), height = "540px"),
        tags$h5("Differences the analysis resolves"),
        help_box("resolved"),
        verbatimTextOutput(ns("resolved")),
        tableOutput(ns("tbl")),

        tags$hr(),
        actionButton(ns("read"),
                     paste0("Read all ", length(state$cfg$aux),
                            " domains (", length(state$cfg$aux), " calls)")),
        uiOutput(ns("reads")),
        tags$hr(),
        tags$p(class = "text-muted",
               "Not happy with a name? The wording can be changed at any ",
               "point; nothing computed depends on it."),
        actionButton(ns("edit_names"), "Edit the names"),
        NULL)
    })

    # The two gaps, side by side. This is the number the whole workflow exists
    #   to produce: how far the design moves an estimate, and how far the
    #   assignment moves it again, both against the design-based standard error
    #   they should be read against.
    output$gap <- renderTable({
      req(state$domains)
      d <- state$domains$dom
      w <- pick_estimator(d, "Unweighted") |> arrange(variable, segment, level)
      x <- pick_estimator(d, "Design-based") |> arrange(variable, segment, level)
      y <- pick_estimator(d, "Corrected") |> arrange(variable, segment, level)
      ratio <- x$se / w$se

      tibble(
        Quantity = c("Median shift from weighting",
                     "Median shift from the correction",
                     "Largest shift from the correction",
                     "Median design-based standard error",
                     "Design-based SE against unweighted"),
        Value = c(sprintf("%.4f", median(abs(x$p - w$p), na.rm = TRUE)),
                  sprintf("%.4f", median(abs(y$p - x$p), na.rm = TRUE)),
                  sprintf("%.4f", max(abs(y$p - x$p), na.rm = TRUE)),
                  sprintf("%.4f", median(x$se, na.rm = TRUE)),
                  sprintf("%.2f times", median(ratio[is.finite(ratio)]))))
    }, width = "100%")

    output$plot <- renderPlot({
      req(state$domains, input$which)
      plot_domain(state$domains$dom, input$which, state$labels$Label)
    }, bg = "transparent")

    output$resolved <- renderText({
      req(state$domains, input$which)
      resolved_pairs(state$domains, input$which, state$labels$Label)
    })

    output$tbl <- renderTable({
      req(state$domains, input$which)
      state$domains$dom |>
        filter(variable == input$which) |>
        mutate(Group = state$labels$Label[segment]) |>
        transmute(Group, Level = level, Estimator = as.character(estimator),
                  Estimate = round(p, 3), SE = round(se, 3),
                  `95% interval` = paste0("[", round(lo, 3), ", ",
                                          round(hi, 3), "]")) |>
        arrange(Group, Level, Estimator)
    }, width = "100%")

    # One call per domain, in a single pass. R has already decided which pairs
    #   separate; the model is given that list and translates it.
    observeEvent(input$read, {
      req(state$domains)
      reads <- list()
      withProgress(message = "Reading", value = 0, {
        walk(state$cfg$aux, function(v) {
          incProgress(1 / length(state$cfg$aux), detail = v)
          res <- try(llm_json(
            prompt_domain_read(
              state$domains$dom, state$domains$marg, v,
              labels = state$labels$Label,
              context = state$context %||% "",
              values_header = state$domains$values_header,
              est = "Design-based", wald = state$domains$wald),
            role = "pm", system_prompt = persona_pm,
            validate = validate_fields(c("finding", "caution"))), silent = TRUE)
          if (inherits(res, "try-error")) {
            showNotification(paste0(v, ": ",
                                    conditionMessage(attr(res, "condition"))),
                             type = "error", duration = NULL)
            return()
          }
          reads[[v]] <<- res
        })
      })
      state$domain_reads <- reads
    })

    # The freeze file is keyed to model_key(), so a name edited here cannot
    #   attach to a model it does not describe.
    observeEvent(input$edit_names, { state$goto <- "8. Names" })

    output$reads <- renderUI({
      req(state$domain_reads)
      map(names(state$domain_reads), function(v) {
        r <- state$domain_reads[[v]]
        tagList(
          tags$h5(v),
          advice_box(tags$p(r$finding),
                     tags$p(tags$strong("What the design changed: "), r$caution)))
      })
    })
  })
}

# ---- mod_report --------------------------------------------------------

# mod_report.R for WISE repo
# Stage 11: review the report, then save everything.

# The analyst reads the report here before any file is written. Preview and
#   document come from the same block list, so what is approved is what is
#   saved rather than a second rendering that might differ.

mod_report_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("runner")),
    uiOutput(ns("preview")),
    uiOutput(ns("written"))
  )
}


mod_report_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$domains))
        tags$p(class = "text-muted", "Estimate the domains first.")
    })

    output$runner <- renderUI({
      req(state$domains)
      tagList(
        tags$h4("The report"),
        help_box("report"),
        if (!nzchar(state$question %||% ""))
          tags$p(class = "text-muted",
                 "No research question was set on the Items tab, so the ",
                 "report is ordered by domain."),
        checkboxInput(ns("summarise"),
                      "Have the methodologist write the summary (1 call)",
                      value = TRUE),
        actionButton(ns("build"), "Build the report", class = "btn-primary"),
        actionButton(ns("edit_names"), "Edit the names"),
        tags$p(class = "text-muted",
               "Names can be changed at any point. Rebuild the report ",
               "afterwards and the new wording is used throughout."))
    })

    observeEvent(input$build, {
      req(state$domains)
      summary_text <- NULL; not_answered <- NULL

      if (isTRUE(input$summarise)) {
        s <- try(withProgress(message = "Writing the summary", value = 0.5, {
          llm_json(prompt_report_summary(state), role = "pm",
                   system_prompt = persona_pm,
                   validate = validate_fields(c("summary", "not_answered")))
        }), silent = TRUE)
        if (inherits(s, "try-error"))
          showNotification(paste("Summary skipped:",
                                 conditionMessage(attr(s, "condition"))),
                           type = "warning", duration = NULL)
        else { summary_text <- s$summary; not_answered <- s$not_answered }
      }

      state$report_summary <- summary_text
      state$report_not_answered <- not_answered

      html <- try(withProgress(message = "Rendering", value = 0.6, {
        report_html(state, summary_text, not_answered)
      }), silent = TRUE)

      if (inherits(html, "try-error")) {
        showNotification(conditionMessage(attr(html, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$report_html <- html
    })

    # The freeze file is keyed to model_key(), so a name edited here cannot
    #   attach to a model it does not describe.
    observeEvent(input$edit_names, { state$goto <- "8. Names" })

    output$preview <- renderUI({
      req(state$report_html)
      tagList(
        tags$hr(),
        # Bounded and scrollable, so the page below stays reachable and the
        #   analyst can see how long the report actually is.
        tags$div(
          style = paste("max-height:70vh; overflow-y:auto; padding:1.2em 1.6em;",
                        "border:1px solid var(--bs-border-color);",
                        "border-radius:4px;",
                        "background: var(--bs-body-bg);"),
          state$report_html),
        tags$hr(),
        tags$h5("Save it"),
        help_box("report_save"),
        radioButtons(ns("format"), "Data file format", inline = TRUE,
                     choices = c("SPSS (.sav)" = "sav", "Stata (.dta)" = "dta"),
                     selected = if (identical(state$format, "stata")) "dta"
                                else "sav"),
        actionButton(ns("save"), "Save the report and all outputs",
                     class = "btn-primary"))
    })

    observeEvent(input$save, {
      req(state$report_html)
      res <- try(withProgress(message = "Writing", value = 0, {
        incProgress(0.3, detail = "report")

        # HTML is the report. It is self-contained, every figure is embedded,
        #   it opens in Word, and it needs no package beyond the ones the
        #   analysis already uses.
        rep <- build_report_html(state, state$report_summary,
                                 state$report_not_answered)

        incProgress(0.4, detail = "data file")
        dat <- export_data(state, input$format)
        incProgress(0.3, detail = "tables")
        c(rep, dat, unlist(export_tables(state)))
      }), silent = TRUE)

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }

      state$outputs <- res
      log_decision(
        "labels", "Outputs written",
        decision = paste0(length(res), " files written."),
        evidence = paste(paste0("- ", fs::path_file(res)), collapse = "\n"))
      showNotification("Saved.", type = "message", duration = NULL)
    })

    output$written <- renderUI({
      req(state$outputs)
      tagList(
        tags$hr(),
        tags$h4("Where everything is"),
        tags$p("In ", tags$code(state$work_dir), ":"),
        tags$ul(
          tags$li(tags$strong("output/"), " — the report, your survey file ",
                  "with the new columns, and every table as CSV"),
          tags$li(tags$strong("decisions/"), " — what you chose at each step ",
                  "and the evidence you had at the time"),
          tags$li(tags$strong("dict/"), " — the data dictionary")),
        tags$ul(map(state$outputs, function(p)
          tags$li(tags$code(fs::path_rel(p, state$work_dir))))),
        help_box("finished"))
    })
  })
}

