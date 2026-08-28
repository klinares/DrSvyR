# ui_model.R for DrSvyR
# Screens 5 to 8: review, search, model, names.

# Merged from: 
#   mod_config.R
#   mod_search.R
#   mod_model.R
#   mod_labels.R

# ---- mod_config --------------------------------------------------------

# mod_config.R for WISE repo
# Stage 5: review the specification and commit to it.

# The last point at which anything can be changed cheaply. After this the model
#   is fitted, and going back means going back through the search.

mod_config_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("body"))
  )
}


mod_config_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      missing <- c(
        if (is.null(state$design_dat)) "the design",
        if (is.null(state$item_frame)) "a battery",
        if (is.null(state$arm)) "an arm",
        if (is.null(state$demo_dat)) "the domains")
      if (length(missing))
        tags$p(class = "text-muted",
               "Still to do: ", paste(missing, collapse = ", "), ".")
    })

    cfg <- reactive({
      req(state$design_dat, state$item_frame, state$arm, state$demo_dat)
      build_cfg(state)
    })

    output$body <- renderUI({
      req(cfg())
      tagList(
        tags$h4("The analysis as configured"),
        help_box("config"),
        tableOutput(ns("summary")),

        tags$hr(),
        actionButton(ns("readback"), "Read this back in plain language"),
        tags$span(class = "text-muted", "  One call. Optional."),
        uiOutput(ns("readback_out")),

        tags$hr(),
        help_box("config_commit"),
        actionButton(ns("commit"), "Approve and write the configuration",
                     class = "btn-primary"),
        uiOutput(ns("written")))
    })

    output$summary <- renderTable({
      req(cfg())
      config_summary(state, cfg())
    }, width = "100%")

    # The model restates decisions it did not make. A paragraph that does not
    #   match the table above is a sign the configuration is not what the
    #   analyst thinks it is, which is worth one call to find out here rather
    #   than after the model is fitted.
    observeEvent(input$readback, {
      req(cfg())
      withProgress(message = "Reading back", value = 0.5, {
        res <- try(llm_json(
          prompt_config_readback(config_summary(state, cfg()),
                                 state$context %||% ""),
          role = "pm", system_prompt = persona_pm,
          validate = validate_fields("summary")), silent = TRUE)
        if (inherits(res, "try-error")) {
          showNotification(conditionMessage(attr(res, "condition")),
                           type = "error", duration = NULL)
          return()
        }
        state$config_readback <- res$summary
      })
    })

    output$readback_out <- renderUI({
      req(state$config_readback)
      advice_box(
        tags$p(state$config_readback),
        tags$p(class = "text-muted",
               "Check this against the table. If it describes something you ",
               "did not intend, go back rather than forward."))
    })

    observeEvent(input$commit, {
      req(cfg())
      cf <- cfg()
      stamp <- format(Sys.time(), "%Y-%m-%d %H:%M")

      paths <- try({
        p1 <- write_cfg(cf, wise_path("output", cf$arm, "cfg.R"))
        p2 <- write_data_dict(state, cf, wise_path("dict", "data-dict.yaml"))

        log_decision("scope", "Analysis configured",
                     decision = paste0(
                       "Arm: ", toupper(cf$arm), ". Battery of ",
                       length(cf$items), " items, fitted on ",
                       sum(state$item_frame$in_analysis), " respondents. ",
                       length(cf$aux), " domains."),
                     evidence = log_table(config_summary(state, cf)),
                     stamp = stamp)

        log_decision("design", "Design confirmed",
                     decision = paste0(
                       "id = ", state$design_map[["id"]],
                       ", stratum = ", state$design_map[["strata"]],
                       ", PSU = ", state$design_map[["psu"]],
                       ", weight = ", state$design_map[["weight"]], "."),
                     evidence = log_table(state$design_checks), stamp = stamp)

        log_decision("recodes", "Domains collapsed",
                     decision = paste0(length(cf$aux), " domains applied."),
                     evidence = log_table(state$recode_audit), stamp = stamp)

        c(p1, p2)
      }, silent = TRUE)

      if (inherits(paths, "try-error")) {
        showNotification(conditionMessage(attr(paths, "condition")),
                         type = "error", duration = NULL)
        return()
      }

      state$cfg <- cf

      # A model fitted under the previous configuration is not this
      #   configuration's model, and one fitted under the other arm is not even
      #   the same shape. Leaving it in state is what let a class model reach
      #   the factor panels. Refitting is cheap: the cache is keyed on the
      #   specification and the data, so an unchanged configuration comes back
      #   without re-running anything.
      state$model <- NULL
      state$model_key <- NULL
      state$model_dat <- NULL
      state$model_accepted <- NULL
      state$measure <- NULL
      state$diag_reading <- NULL

      state$cfg_paths <- paths
      showNotification("Configuration written. Continue to Search.",
                       type = "message", duration = NULL)
    })

    output$written <- renderUI({
      req(state$cfg_paths)
      tagList(
        tags$p(class = "text-success", "Written to your work folder:"),
        tags$ul(map(state$cfg_paths, function(p)
          tags$li(tags$code(fs::path_rel(p, state$work_dir))))),
        tags$p(class = "text-muted",
               "The decision log is in ", tags$code("decisions/"),
               ". It records what you chose and the evidence you had."))
    })
  })
}

# ---- mod_search --------------------------------------------------------

# mod_search.R for WISE repo
# Stage 6: choose the number of groups or factors.

# Order of presentation is the whole design here. The evidence and the profiles
#   come first, the analyst commits to a number, and only then does the model
#   say what it makes of it. Shown the other way round, the model's number
#   becomes the analyst's and the gate is decorative.

mod_search_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("runner")),
    uiOutput(ns("evidence")),
    uiOutput(ns("chooser")),
    uiOutput(ns("narration"))
  )
}


mod_search_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$cfg))
        tags$p(class = "text-muted", "Approve the configuration in Review first.")
    })

    output$runner <- renderUI({
      req(state$cfg)
      cfg <- state$cfg
      n_fits <- if (identical(cfg$arm, "lca")) length(cfg$K_range)
                else length(cfg$k_range)
      tagList(
        tags$h4("Search"),
        help_box("search"),
        tags$p(n_fits, " models will be fitted",
               if (identical(cfg$arm, "lca"))
                 paste0(", each from ", cfg$n_starts,
                        " random starts across ", cfg$workers, " workers")
               else "",
               ". The screen will not respond while it runs."),
        actionButton(ns("run"), "Run the search", class = "btn-primary"))
    })

    # Synchronous, with the progress bar stepping per model. The session is
    #   unresponsive while it runs, which is acceptable for one analyst waiting
    #   on their own analysis and much easier to diagnose than a background
    #   process. If this becomes a shared deployment it wants callr and polling.
    observeEvent(input$run, {
      req(state$cfg)
      cfg <- state$cfg
      dat <- bind_cols(state$design_dat,
                       state$item_frame$item_dat)[state$item_frame$in_analysis, ]
      grid <- if (identical(cfg$arm, "lca")) cfg$K_range else cfg$k_range

      withProgress(message = "Fitting", value = 0, {
        tick <- function(k) incProgress(1 / length(grid),
                                        detail = paste("size", k))
        res <- try(
          if (identical(cfg$arm, "lca")) search_lca(cfg, dat, tick)
          else search_cfa(cfg, dat, tick),
          silent = TRUE)
      })

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$search <- res
      state$dimension <- NULL
      state$search_reading <- NULL
    })

    # ---- evidence ----------------------------------------------------------

    output$evidence <- renderUI({
      req(state$search)
      if (identical(state$cfg$arm, "lca")) {
        tagList(
          tags$hr(),
          tags$h4("What the criteria say"),
          plotOutput(ns("bic"), height = "300px"),
          tableOutput(ns("stats")),
          tags$hr(),
          tags$h4("What the groups look like"),
          help_box("profiles"),
          uiOutput(ns("profile_picker")),
          plotOutput(ns("profiles"), height = "380px"))
      } else {
        tagList(
          tags$hr(),
          tags$h4("How many dimensions the answers carry"),
          plotOutput(ns("scree"), height = "300px"),
          tableOutput(ns("eigen")),
          tags$hr(),
          tags$h4("Fit at each number of factors"),
          tableOutput(ns("stats")))
      }
    })

    output$bic <- renderPlot({ req(state$search); plot_bic(state$search$stats) })
    output$scree <- renderPlot({ req(state$search); plot_scree(state$search$eigen) })

    output$stats <- renderTable({
      req(state$search)
      state$search$stats |> mutate(across(where(is.logical), as.character)) |>
        mutate(flag = coalesce(flag, ""))
    }, width = "100%")

    output$eigen <- renderTable({
      req(state$search)
      state$search$eigen |>
        transmute(Component = component, Eigenvalue = eigenvalue,
                  `No structure` = reference,
                  Retain = if_else(retain, "yes", ""))
    }, width = "100%")

    output$profile_picker <- renderUI({
      req(state$search, identical(state$cfg$arm, "lca"))
      ks <- state$cfg$K_range
      radioButtons(ns("show_k"), "Show the profiles for", inline = TRUE,
                   choices = ks, selected = ks[min(3, length(ks))])
    })

    output$profiles <- renderPlot({
      req(state$search, input$show_k)
      fit <- state$search$fits[[as.character(input$show_k)]]
      plot_profiles(fit, state$cfg$items,
                    paste0(input$show_k, " groups"))
    })

    # ---- the choice --------------------------------------------------------

    output$chooser <- renderUI({
      req(state$search)
      cfg <- state$cfg
      grid <- if (identical(cfg$arm, "lca")) cfg$K_range else cfg$k_range
      tagList(
        tags$hr(),
        tags$h4(if (identical(cfg$arm, "lca")) "How many groups?"
                else "How many factors?"),
        help_box("dimension_choice"),
        numericInput(ns("dim"), NULL, value = NA, width = "120px",
                     min = min(grid), max = max(grid), step = 1),
        actionButton(ns("commit"), "Use this number", class = "btn-primary"))
    })

    observeEvent(input$commit, {
      req(state$search, !is.na(input$dim))
      cfg <- state$cfg
      grid <- if (identical(cfg$arm, "lca")) cfg$K_range else cfg$k_range
      if (!input$dim %in% grid) {
        showNotification(paste0("Choose a number between ", min(grid), " and ",
                                max(grid), "."), type = "warning")
        return()
      }
      state$dimension <- as.integer(input$dim)
      state$search_reading <- NULL

      log_decision(
        "dimension",
        paste0(if (identical(cfg$arm, "lca")) "Number of groups: "
               else "Number of factors: ", state$dimension),
        decision = paste0(
          "The analyst chose ", state$dimension,
          if (identical(cfg$arm, "lca")) " groups" else " factors",
          ", before any interpretation of the evidence was offered."),
        evidence = log_table(state$search$stats))

      showNotification("Recorded. You can now ask for a reading of the evidence.",
                       type = "message", duration = 8)
    })

    # ---- narration, after the choice ---------------------------------------

    output$narration <- renderUI({
      req(state$dimension)
      tagList(
        tags$hr(),
        tags$p(tags$strong("You chose ", state$dimension, ".")),
        help_box("search_reading"),
        actionButton(ns("read"), "What does the evidence say?"),
        uiOutput(ns("reading_out")),
        tags$br(),
        tags$p(class = "text-muted",
               "When you are satisfied, continue to Model."))
    })

    observeEvent(input$read, {
      req(state$dimension, state$search)
      withProgress(message = "Reading", value = 0.5, {
        res <- try(llm_json(
          prompt_search_narration(state$search$stats, state$dimension,
                                  state$cfg$arm, state$context %||% ""),
          role = "pm", system_prompt = persona_pm,
          validate = validate_fields("reading")), silent = TRUE)
        if (inherits(res, "try-error")) {
          showNotification(conditionMessage(attr(res, "condition")),
                           type = "error", duration = NULL)
          return()
        }
        state$search_reading <- res
      })
    })

    output$reading_out <- renderUI({
      req(state$search_reading)
      r <- state$search_reading
      advice_box(
        tags$p(r$reading),
        tags$p(class = "text-muted",
               "Your number stands. If this changes your mind, enter a ",
               "different one above -- both choices are recorded."))
    })
  })
}

# ---- mod_model ---------------------------------------------------------

# mod_model.R for WISE repo
# Stage 7: the fitted model and what it does not account for.

# One return is permitted from here to Items. The limit is not about the
#   analyst's judgement -- it is that a model narrating diagnostics is an engine
#   for producing plausible reasons to drop things, and an unbounded loop ends
#   with a battery selected to fit rather than a battery that measures. Every
#   round is logged and the count appears in the report.

MAX_REFITS <- 1L

mod_model_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("runner")),
    uiOutput(ns("body"))
  )
}


mod_model_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$dimension))
        tags$p(class = "text-muted", "Choose a number in Search first.")
    })

    output$runner <- renderUI({
      req(state$dimension)
      tagList(
        tags$h4("Fit the model"),
        help_box("final_model"),
        tags$p("Fitting ", tags$strong(state$dimension),
               if (identical(state$cfg$arm, "lca"))
                 paste0(" groups from ", state$cfg$n_starts, " starts.")
               else " factors."),
        actionButton(ns("run"), "Fit", class = "btn-primary"))
    })

    observeEvent(input$run, {
      req(state$cfg, state$dimension)
      cfg <- state$cfg
      dat <- bind_cols(state$design_dat,
                       state$item_frame$item_dat)[state$item_frame$in_analysis, ]
      # dat, not just the specification: the cached fit belongs to this file.
      key <- model_key(cfg, cfg$items, state$dimension, dat)

      res <- try(withProgress(message = "Fitting", value = 0.4, {
        if (identical(cfg$arm, "lca")) {
          fit <- cached("fit", key, function() fit_final_lca(cfg, dat, state$dimension))
          setProgress(0.7, message = "Diagnosing")
          list(fit = fit, diag = diagnose_lca(fit, cfg, dat), factors = NULL)
        } else {
          factors <- assign_factors(
            state$search$fits[[as.character(state$dimension)]], cfg$items)
          fit <- cached("fit", key, function() fit_final_cfa(cfg, dat, factors))
          setProgress(0.7, message = "Diagnosing")
          list(fit = fit, diag = diagnose_cfa(fit, cfg), factors = factors,
               health = cfa_health(fit))
        }
      }), silent = TRUE)

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      # The arm travels with the object. Every panel that renders part of a
      #   model asks the model which arm it came from, rather than asking the
      #   configuration, which can be cleared or changed underneath it.
      state$model <- c(res, list(arm = cfg$arm))
      state$model_key <- key
      state$model_dat <- dat
      state$diag_reading <- NULL
      state$measure <- NULL
    })

    # Separate and explicit, because it refits the model inside every replicate
    #   and that is minutes rather than seconds. It is also the point of the
    #   workflow: without it the measurement model is a set of numbers with no
    #   stated precision, and an analyst has nothing to tell them whether two
    #   groups differ on an item or merely look as though they do.
    observeEvent(input$variance, {
      req(state$model)
      cfg <- state$cfg
      dat <- state$model_dat

      # Which estimator runs is decided by the model in hand, not by the
      #   configuration. They can disagree -- approving the other arm after a
      #   fit leaves the old model in state -- and when they do, branching on
      #   the configuration hands a class fit to the factor estimator.
      if (!arm_is(state$model, cfg$arm)) {
        showNotification(
          paste0("The fitted model is a ", toupper(state$model$arm %||% "?"),
                 " model and the configuration now says ", toupper(cfg$arm),
                 ". Fit the model again before running the variance step."),
          type = "error", duration = NULL)
        return()
      }

      res <- try(withProgress(message = "Refitting in every replicate",
                              value = 0.2, {
        des <- build_rep_design(dat, cfg)
        if (arm_is(state$model, "lca"))
          measurement_se_lca(cfg, dat, state$model$fit, des$des, des$rep_des)
        else
          measurement_se_cfa(cfg, dat, state$model$fit, state$model$factors,
                             des$des, des$rep_des)
      }), silent = TRUE)

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$measure <- c(res, list(arm = state$model$arm))
    })

    # ---- results -----------------------------------------------------------

    output$body <- renderUI({
      req(state$model)
      # The model's own arm, not the configuration's. This panel decides which
      #   of the two shapes to lay out, and the configuration can already be
      #   pointing at the other one.
      lca <- arm_is(state$model, "lca")
      health <- state$model$health
      tagList(
        # Shown before anything is read off the fit. A model that did not
        #   identify still draws a diagram and prints a table, and nothing
        #   downstream would say otherwise.
        if (!is.null(health) && !health$ok)
          warn_box(
            tags$strong("This model did not fit cleanly."),
            tags$ul(map(health$problems, tags$li)),
            tags$div(
              "The numbers below print, but they are not a unique solution ",
              "and should not be reported. Usually this means the battery is ",
              "being asked to support more factors than it can, or that two ",
              "items are nearly the same question. Go back and fit fewer ",
              "factors, or remove an item.")),

        tags$hr(),
        tags$h4("The measurement model"),
        if (lca) plotOutput(ns("profiles"), height = "380px")
        else tagList(
          help_box("cfa_diagram"),
          plotOutput(ns("diagram"), height = "560px"),
          tags$h5("Which items belong to which factor"),
          verbatimTextOutput(ns("factors"))),

        tags$hr(),
        tags$h4("How precise are these?"),
        help_box("measurement_variance"),
        if (is.null(state$measure))
          tagList(
            tags$p("The model will be refitted inside each replicate. ",
                   "This takes longer than the fit itself."),
            actionButton(ns("variance"), "Estimate the uncertainty",
                         class = "btn-primary"))
        else uiOutput(ns("variance_out")),

        tags$hr(),
        tags$h4("What the model accounts for"),
        help_box("diagnostics"),
        if (lca) tagList(
          tags$p(tags$strong("Separation: "),
                 round(state$model$diag$entropy, 3),
                 tags$span(class = "text-muted",
                           " — how cleanly people fall into one group.")),
          tags$h5("How far each item separates the groups"),
          plotOutput(ns("disc_plot"), height = "340px"),
          tableOutput(ns("disc")),
          tags$h5("Pairs the model accounts for least well"),
          tableOutput(ns("bvr")),
          tags$h5("Level against pattern"),
          tableOutput(ns("ratio")))
        else tagList(
          tags$h5("Loadings"), tableOutput(ns("load")),
          tags$h5("Fit"), tableOutput(ns("fitm")),
          tags$h5("Pairs the model accounts for least well"),
          tableOutput(ns("mi"))),

        tags$hr(),
        actionButton(ns("read")," What do these say?"),
        uiOutput(ns("reading_out")),

        tags$hr(),
        uiOutput(ns("decision")))
    })

    output$profiles <- renderPlot({
      req(state$model)
      plot_profiles(state$model$fit, state$cfg$items,
                    paste0(state$dimension, " groups"))
    })

    output$variance_out <- renderUI({
      req(state$measure)
      if (arm_is(state$measure, "lca"))
        tagList(
          tags$p(class = "text-muted",
                 "From ", state$measure$replicates,
                 " jackknife replicates, one refit each."),
          plotOutput(ns("prof_ci"), height = "400px"),
          tags$h5("Group sizes"),
          tableOutput(ns("shares_ci")))
      else
        tagList(
          tags$p(class = "text-muted",
                 "From ",
                 state$measure$replicates - (state$measure$failed %||% 0L),
                 " of ", state$measure$replicates,
                 " jackknife replicates, one refit each."),
          if ((state$measure$failed %||% 0L) > 0)
            warn_box(
              tags$strong(state$measure$failed, " replicate refits did not ",
                          "converge and were dropped."),
              tags$div(
                "Every replicate is meant to contribute, so the intervals ",
                "below are narrower than they should be rather than merely ",
                "noisier. Treat them as a lower bound. A handful is common; ",
                "a large share usually means the model is asking more of the ",
                "battery than it can carry.")),
          plotOutput(ns("load_ci"), height = "400px"),
          tableOutput(ns("load_ci_tbl")),
          if (!is.null(state$measure$correlations))
            tagList(tags$h5("Correlation between the factors"),
                    tableOutput(ns("corr_tbl"))))
    })

    # Every panel below asks two questions before it renders: is this object
    #   from my arm, and is the thing I am about to draw actually there. Both
    #   are needed. The arm check alone would pass a factor model whose
    #   modification indices came back as a try-error; the presence check alone
    #   would pass a class model's shares to a factor panel that wanted
    #   loadings and got NULL. req() stops the output cleanly either way, so a
    #   stale panel goes blank instead of throwing.

    output$prof_ci <- renderPlot({
      req(arm_is(state$measure, "lca"), state$measure$profile)
      plot_profiles_ci(state$measure$profile,
                       labels = state$labels$Label,
                       title = paste0(state$dimension, " groups"))
    }, bg = "transparent")

    output$shares_ci <- renderTable({
      req(arm_is(state$measure, "lca"), state$measure$shares)
      state$measure$shares |>
        transmute(Group = group, Share = share, SE = se,
                  `95% interval` = paste0("[", lo, ", ", hi, "]"))
    }, width = "100%")

    output$load_ci <- renderPlot({
      req(arm_is(state$measure, "cfa"), state$measure$loadings)
      plot_loadings_ci(state$measure$loadings)
    }, bg = "transparent")

    output$load_ci_tbl <- renderTable({
      req(arm_is(state$measure, "cfa"), state$measure$loadings)
      state$measure$loadings |>
        transmute(Factor = factor, Item = item, Loading = loading, SE = se,
                  `95% interval` = paste0("[", lo, ", ", hi, "]"))
    }, width = "100%")

    output$corr_tbl <- renderTable({
      req(arm_is(state$measure, "cfa"), state$measure$correlations)
      state$measure$correlations |>
        transmute(Between = paste(a, "and", b), r = r, SE = se,
                  `95% interval` = paste0("[", lo, ", ", hi, "]"))
    }, width = "100%")

    # The correlations are the measure's, so they are only passed when the
    #   measure belongs to this model. Otherwise the diagram draws from the
    #   model alone, which is what it does before the variance step has run.
    output$diagram <- renderPlot({
      req(arm_is(state$model, "cfa"), state$model$fit)
      plot_cfa_diagram(
        state$model$fit,
        correlations = if (arm_is(state$measure, "cfa"))
          state$measure$correlations)
    }, bg = "transparent")

    output$disc_plot <- renderPlot({
      req(arm_is(state$model, "lca"), state$model$diag$discrimination)
      plot_discrimination(state$model$diag$discrimination)
    }, bg = "transparent")

    output$factors <- renderPrint({
      req(arm_is(state$model, "cfa"), state$model$factors)
      state$model$factors })
    output$disc  <- renderTable({
      req(arm_is(state$model, "lca"), state$model$diag$discrimination)
      state$model$diag$discrimination |> mutate(flag = coalesce(flag, "")) },
      width = "100%")
    output$bvr   <- renderTable({
      req(arm_is(state$model, "lca"), state$model$diag$bvr)
      state$model$diag$bvr },
      width = "100%")
    output$ratio <- renderTable({
      req(arm_is(state$model, "lca"), state$model$diag$ratio)
      state$model$diag$ratio },
      width = "100%")
    output$load  <- renderTable({
      req(arm_is(state$model, "cfa"), state$model$diag$loadings)
      state$model$diag$loadings |> mutate(flag = coalesce(flag, "")) },
      width = "100%")
    output$fitm  <- renderTable({
      req(arm_is(state$model, "cfa"), state$model$diag$fit)
      state$model$diag$fit },
      width = "100%")
    output$mi    <- renderTable({
      req(arm_is(state$model, "cfa"), state$model$diag$mi)
      state$model$diag$mi },
      width = "100%")

    observeEvent(input$read, {
      req(state$model)
      withProgress(message = "Reading", value = 0.5, {
        res <- try(llm_json(
          prompt_diagnostics(state$model$diag, state$model$arm, state$dimension,
                             state$context %||% ""),
          role = "pm", system_prompt = persona_pm,
          validate = validate_fields("reading")), silent = TRUE)
        if (inherits(res, "try-error")) {
          showNotification(conditionMessage(attr(res, "condition")),
                           type = "error", duration = NULL)
          return()
        }
        state$diag_reading <- res
      })
    })

    output$reading_out <- renderUI({
      req(state$diag_reading)
      advice_box(
        tags$p(state$diag_reading$reading),
        tags$p(class = "text-muted",
               "These rank items; none of them is a test. Whether an item ",
               "belongs is a question about the question, which is yours."))
    })

    # ---- proceed, or go back once ------------------------------------------

    output$decision <- renderUI({
      req(state$model)
      used <- iteration_count()
      tagList(
        help_box("refit"),
        tags$p(tags$strong("Rounds used: "), used, " of ", MAX_REFITS, "."),
        if (used < MAX_REFITS)
          tagList(
            textInput(ns("drop"), "Items to remove, comma separated",
                      width = "60%", placeholder = "leave empty to keep all"),
            textInput(ns("why"), "Why", width = "100%",
                      placeholder = "recorded in the report"),
            actionButton(ns("refit"), "Record and go back to Items"))
        else
          tags$p(class = "text-muted",
                 "No further rounds. The report will say the specification ",
                 "was arrived at over ", used + 1, " rounds."),
        tags$br(),
        actionButton(ns("accept"), "Accept this model", class = "btn-primary"))
    })

    observeEvent(input$refit, {
      req(nzchar(input$drop), nzchar(input$why))
      drop <- str_trim(str_split(input$drop, ",")[[1]])
      bad <- setdiff(drop, state$cfg$items)
      if (length(bad)) {
        showNotification(paste("Not in the battery:", paste(bad, collapse = ", ")),
                         type = "warning")
        return()
      }
      log_decision(
        "iterations",
        paste0("Round ", iteration_count() + 1, ": removed ",
               paste(drop, collapse = ", ")),
        decision = input$why,
        evidence = log_table(if (identical(state$cfg$arm, "lca"))
          state$model$diag$discrimination else state$model$diag$loadings))

      # Everything downstream of the battery is invalid now, so it is cleared
      #   rather than left to look current. The domains survive: they do not
      #   depend on which items are in the battery.
      state$model <- NULL
      state$model_key <- NULL
      state$model_dat <- NULL
      state$model_accepted <- NULL
      # The measure belongs to the model that has just been invalidated. It was
      #   left behind here, and a stale measure is what fed NULL into the
      #   interval panels while the configuration was NULL beside it.
      state$measure <- NULL
      state$dimension <- NULL
      state$search <- NULL
      state$search_reading <- NULL
      state$diag_reading <- NULL
      state$cfg <- NULL
      state$cfg_paths <- NULL

      showNotification(
        HTML(paste0(
          "<b>Recorded.</b> Three steps from here:<br>",
          "1. <b>Items</b> — remove ", paste(drop, collapse = ", "),
          " from the battery and press Summarise, then Use this arm.<br>",
          "2. <b>Review</b> — approve the configuration again.<br>",
          "3. <b>Search</b> — run it again and choose a number.<br>",
          "Your domains are unaffected and do not need redoing.")),
        type = "message", duration = NULL)

      state$goto <- WISE_TABS[3]
    })

    observeEvent(input$accept, {
      req(state$model)
      state$model_accepted <- TRUE
      log_decision(
        "dimension", "Model accepted",
        decision = paste0(state$dimension,
                          if (identical(state$cfg$arm, "lca")) " groups"
                          else " factors",
                          " accepted after ", iteration_count(),
                          " round(s) of item removal."),
        evidence = if (identical(state$cfg$arm, "lca"))
          log_table(state$model$diag$discrimination)
          else log_table(state$model$diag$loadings))
      showNotification("Accepted. Continue to Labels.", type = "message",
                       duration = NULL)
    })
  })
}

# ---- mod_labels --------------------------------------------------------

# mod_labels.R for WISE repo
# Stage 8: name what the model found.

# The profile sits beside every name, because the check the analyst is being
#   asked to make is whether the name describes the numbers next to it. A name
#   presented on its own is a name that gets accepted.

# Whether a name was edited is recorded. A run in which every drafted name was
#   accepted unchanged is not wrong, but it is worth a reader knowing.

mod_labels_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("runner")),
    uiOutput(ns("editor"))
  )
}


mod_labels_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (!isTRUE(state$model_accepted))
        tags$p(class = "text-muted", "Accept a model in Model first.")
    })

    n_targets <- reactive({
      req(state$model)
      length(label_targets(state))
    })

    output$runner <- renderUI({
      req(state$model_accepted)
      existing <- try(read_labels(state$cfg, state$model_key, n_targets()),
                      silent = TRUE)
      stale <- inherits(existing, "try-error")
      have <- !stale && !is.null(existing)

      tagList(
        tags$h4("Names"),
        help_box("labels"),

        # A saved file that does not match is a dead end unless the analyst can
        #   clear it from here. Telling them to delete a file by hand is not an
        #   instruction this app gets to give.
        if (stale)
          warn_box(
            tags$strong("Saved names do not match this model."),
            tags$div(conditionMessage(attr(existing, "condition"))),
            tags$div("They were written for a different specification, so ",
                     "they no longer describe what they name. Discarding them ",
                     "and drafting again is the only safe option; if you want ",
                     "to keep any of the wording, copy it out first."))
        else if (have)
          tags$p(class = "text-success",
                 "Saved names found and they match this model.")
        else
          tags$p(n_targets(), " names will be drafted, one call each."),

        if (!stale)
          actionButton(ns("draft"),
                       if (have) "Load the saved names" else "Draft the names",
                       class = "btn-primary"),
        if (stale || have)
          actionButton(ns("redraft"),
                       if (stale) "Discard them and draft again"
                       else "Discard and redraft",
                       class = if (stale) "btn-primary" else NULL))
    })

    load_or_draft <- function(force = FALSE) {
      cfg <- state$cfg
      key <- state$model_key

      if (!force) {
        existing <- try(read_labels(cfg, key, n_targets()), silent = TRUE)
        if (!inherits(existing, "try-error") && !is.null(existing)) {
          state$labels <- select(existing, target, Label, Description)
          state$labels_edited <- isTRUE(existing$analyst_edited[1])
          return(invisible(TRUE))
        }
      }

      res <- try(withProgress(message = "Drafting", value = 0, {
        tick <- function(k) incProgress(1 / n_targets(), detail = k)
        drafted <- draft_labels(state, tick)
        setProgress(0.95, message = "Checking for duplicates")
        resolve_collisions(drafted, cfg)
      }), silent = TRUE)

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return(invisible(FALSE))
      }

      state$labels <- res$labels
      state$labels_drafted <- res$labels
      state$labels_edited <- FALSE
      write_labels(res$labels, cfg, key, edited = FALSE)

      if (res$ran)
        showNotification(
          paste("Two or more names were too alike to tell apart, so those were",
                "revised. The rest are as first drafted."),
          type = "message", duration = 10)
      invisible(TRUE)
    }

    observeEvent(input$draft, load_or_draft(force = FALSE))

    observeEvent(input$redraft, {
      f <- label_file(state$cfg)
      if (fs::file_exists(f)) fs::file_delete(f)

      # Part files from abandoned runs go too. They are keyed to the model, so
      #   only the ones that cannot apply here are removed.
      parts <- fs::dir_ls(wise_path("output", state$cfg$arm),
                          regexp = "labels[.]partial[.].*[.]csv$",
                          fail = FALSE)
      keep <- paste0("labels.partial.", substr(state$model_key, 1, 12), ".csv")
      walk(parts[fs::path_file(parts) != keep], fs::file_delete)

      load_or_draft(force = TRUE)
    })

    # ---- editor ------------------------------------------------------------

    output$editor <- renderUI({
      req(state$labels, state$model)
      lca <- arm_is(state$model, "lca")
      lab <- state$labels

      rows <- map(seq_len(nrow(lab)), function(i) {
        tagList(
          tags$hr(),
          fluidRow(
            column(5,
                   textInput(ns(paste0("lab_", i)), NULL, value = lab$Label[i],
                             width = "100%"),
                   textAreaInput(ns(paste0("desc_", i)), NULL, rows = 4,
                                 value = lab$Description[i], width = "100%")),
            column(7,
                   if (lca) plotOutput(ns(paste0("prof_", i)), height = "220px")
                   else tableOutput(ns(paste0("load_", i))))))
      })

      tagList(
        tags$hr(),
        tags$h4("Check each name against what it describes"),
        help_box("labels_check"),
        rows,
        tags$hr(),
        actionButton(ns("save"), "Save the names", class = "btn-primary"),
        uiOutput(ns("saved")))
    })

    # Outputs are created per target when the labels arrive, since the number
    #   of them is not known until the model is fitted.
    observeEvent(state$labels, {
      req(state$model)
      lca <- arm_is(state$model, "lca")
      walk(seq_len(nrow(state$labels)), function(i) {
        if (lca) {
          output[[paste0("prof_", i)]] <- renderPlot({
            fit <- state$model$fit
            col <- viridis::viridis(1)

            # With the replicate refit done, the band is shown: a name should
            #   describe a shape the data actually resolves, not one the point
            #   estimates happen to trace.
            # arm_is rather than a NULL test, for the same reason as every
            #   other panel: a measure from the other arm has no profile and
            #   the filter would run on NULL.
            one <- if (arm_is(state$measure, "lca"))
              filter(state$measure$profile, group == i)
            else
              filter(profile_frame(fit, state$cfg$items),
                     group == paste0("Group ", i)) |>
                mutate(lo = NA_real_, hi = NA_real_)

            cap <- if (arm_is(state$measure, "lca"))
              sprintf("%.0f%% of the population [%.0f, %.0f]",
                      100 * state$measure$shares$share[i],
                      100 * state$measure$shares$lo[i],
                      100 * state$measure$shares$hi[i])
            else paste0(round(100 * fit$pi[i]), "% of respondents")

            p <- ggplot(one, aes(item, value, group = 1))
            if (!all(is.na(one$lo)))
              p <- p + geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.18,
                                   fill = col, colour = NA)
            p + geom_line(linewidth = 0.8, colour = col) +
              geom_point(size = 1.8, colour = col) +
              scale_y_continuous(limits = c(0, 1)) +
              labs(x = NULL, y = NULL, caption = cap) +
              wise_theme() +
              theme(axis.text.x = element_text(angle = 45, hjust = 1))
          }, bg = "transparent")
        } else {
          output[[paste0("load_", i)]] <- renderTable({
            fn <- state$labels$target[i]
            if (arm_is(state$measure, "cfa"))
              state$measure$loadings |>
                filter(factor == fn) |>
                arrange(desc(abs(loading))) |>
                transmute(Item = item, Loading = loading,
                          `95% interval` = paste0("[", lo, ", ", hi, "]"))
            else
              state$model$diag$loadings |>
                filter(factor == fn) |>
                arrange(desc(abs(loading))) |>
                transmute(Item = item, Loading = loading)
          }, width = "100%")
        }
      })
    })

    observeEvent(input$save, {
      req(state$labels)
      edited <- map(seq_len(nrow(state$labels)), function(i)
        tibble(target = state$labels$target[i],
               Label = input[[paste0("lab_", i)]] %||% state$labels$Label[i],
               Description = input[[paste0("desc_", i)]] %||%
                 state$labels$Description[i])) |> list_rbind()

      changed <- !identical(edited$Label, state$labels_drafted$Label) ||
                 !identical(edited$Description, state$labels_drafted$Description)

      state$labels <- edited
      state$labels_edited <- changed
      write_labels(edited, state$cfg, state$model_key, edited = changed)

      log_decision(
        "labels", "Names settled",
        decision = if (changed)
          "The analyst edited the drafted names."
          else "The analyst accepted every drafted name unchanged.",
        evidence = log_table(edited))

      showNotification(
        if (changed) "Saved. Continue to Scoring."
        else paste("Saved. Every drafted name was accepted unchanged, which",
                   "the report will note."),
        type = "message", duration = NULL)
    })

    output$saved <- renderUI({
      req(state$labels_edited)
      tags$p(class = "text-muted",
             "Saved to ", tags$code("output/", state$cfg$arm, "/labels.csv"),
             ". Editing that file by hand is also a way to take over naming; ",
             "deleting it triggers a redraft.")
    })
  })
}
