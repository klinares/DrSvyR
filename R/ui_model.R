# ui_model.R for DrSvyR
# Screens 5 to 8: review, search, model, names.

# Merged from: 
#   mod_config.R
#   mod_search.R
#   mod_model.R
#   mod_labels.R

# ---- mod_config --------------------------------------------------------

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
        if (is.null(state$demo_dat)) "the domains")
      if (length(missing))
        tags$p(class = "text-muted",
               "Still to do: ", paste(missing, collapse = ", "), ".")
    })

    cfg <- reactive({
      req(state$design_dat, state$item_frame, state$demo_dat)
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

      # The Design screen prints STOP against a specification that cannot
      #   produce honest standard errors, and until now that was all it did --
      #   assert_design_ok() existed and nothing called it, so a zero weight
      #   was announced and then carried into every estimate downstream. A
      #   singleton stratum stopped later, in build_rep_design(); a
      #   non-positive weight stopped nowhere at all. This is the choke point:
      #   nothing runs before a configuration is approved.
      blocked <- wise_try(assert_design_ok(state$design_checks),
                          "Approving the configuration")
      if (inherits(blocked, "try-error")) {
        showNotification(conditionMessage(attr(blocked, "condition")),
                         type = "error", duration = NULL)
        state$goto <- WISE_TABS[3]
        return()
      }

      paths <- wise_try({
        p1 <- write_cfg(cf, wise_path("output", "cfg.R"))
        p2 <- write_data_dict(state, cf, wise_path("dict", "data-dict.yaml"))

        log_decision("scope", "Analysis configured",
                     decision = paste0(
                       "Battery of ",
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
      }, "Writing the configuration")

      if (inherits(paths, "try-error")) {
        showNotification(conditionMessage(attr(paths, "condition")),
                         type = "error", duration = NULL)
        return()
      }

      state$cfg <- cf

      # A model fitted under the previous configuration is not this
      #   configuration's model. Leaving it in state means a panel can render
      #   parameters from a battery the analyst has already changed. Refitting
      #   is cheap: the cache is keyed on the
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

# Stage 6: choose the number of groups.

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
      tagList(
        tags$h4("Search"),
        help_box("search"),
        tags$p(length(cfg$K_range), " models will be fitted, each from ",
               cfg$n_starts, " random starts. All ", cfg$n_starts,
               " run for ", cfg$n_short, " iterations; the best ",
               cfg$n_keep, " are then taken to convergence. ",
               "The screen will not respond while it runs."),

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
      withProgress(message = "Fitting", value = 0, {
        tick <- function(k) incProgress(1 / length(cfg$K_range),
                                        detail = paste("size", k))
        res <- wise_try(search_sizes(cfg, dat, tick), "The search")
      })

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$search <- res
      # What this search is a search of. The fit step compares it against the
      #   battery and file in front of it then, and refuses a search that has
      #   since gone stale.
      state$search_key <- model_key(cfg, cfg$items, 0L, dat)
      state$dimension <- NULL
      state$search_reading <- NULL
    })

    # ---- evidence ----------------------------------------------------------

    output$evidence <- renderUI({
      req(state$search)
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
    })

    output$bic <- renderPlot({ req(state$search); plot_bic(state$search$stats) })

    output$stats <- renderTable({
      req(state$search)
      state$search$stats |> mutate(across(where(is.logical), as.character)) |>
        mutate(flag = coalesce(flag, ""))
    }, width = "100%")

    output$profile_picker <- renderUI({
      req(state$search)
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
      grid <- cfg$K_range
      tagList(
        tags$hr(),
        tags$h4("How many groups?"),
        help_box("dimension_choice"),
        numericInput(ns("dim"), NULL, value = NA, width = "120px",
                     min = min(grid), max = max(grid), step = 1),
        actionButton(ns("commit"), "Use this number", class = "btn-primary"))
    })

    observeEvent(input$commit, {
      req(state$search, !is.na(input$dim))
      cfg <- state$cfg
      grid <- cfg$K_range
      if (!input$dim %in% grid) {
        showNotification(paste0("Choose a number between ", min(grid), " and ",
                                max(grid), "."), type = "warning")
        return()
      }
      state$dimension <- as.integer(input$dim)
      state$search_reading <- NULL

      log_decision(
        "dimension",
        paste0("Number of groups: ", state$dimension),
        decision = paste0(
          "The analyst chose ", state$dimension, " groups",
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
                                  state$context %||% ""),
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
        tags$p("The search already fitted ", tags$strong(state$dimension),
               " groups from ", state$cfg$n_starts,
               " starts. This reads that model and works out what it does ",
               "and does not account for."),
        actionButton(ns("run"), "Diagnose this model", class = "btn-primary"))
    })

    observeEvent(input$run, {
      req(state$cfg, state$dimension)
      cfg <- state$cfg
      dat <- bind_cols(state$design_dat,
                       state$item_frame$item_dat)[state$item_frame$in_analysis, ]
      # The search already fitted this. Two hundred starts at every size in
      #   K_range, and the analyst chose a size from that range -- so the model
      #   at the chosen size is sitting in state$search$fits, produced by the
      #   identical call on the identical data. Refitting it recomputed a known
      #   answer and made the analyst wait for it.

      # What the refit was quietly providing was protection against a stale
      #   search: the battery can be rebuilt on the Items screen without
      #   state$search being cleared, and the refit would then have been on the
      #   new data. That is not the rescue it looks like. If the search is
      #   stale then so is the table the analyst read the number off, and a
      #   correct fit at a number chosen from the wrong evidence is worse than
      #   a stop. So it stops.
      search_key <- model_key(cfg, cfg$items, 0L, dat)
      if (!identical(search_key, state$search_key)) {
        showNotification(
          paste("The battery or the file has changed since the search ran, so",
                "the criteria you chose this number from no longer describe",
                "this analysis. Run the search again."),
          type = "error", duration = NULL)
        return()
      }

      fit <- state$search$fits[[as.character(state$dimension)]]
      if (is.null(fit)) {
        showNotification(
          paste0("The search holds no fit at ", state$dimension, " groups. ",
                 "Run the search again."), type = "error", duration = NULL)
        return()
      }

      # The diagnostics are the work that is left, and they are not free --
      #   the bivariate residuals are one weighted two-way table per pair of
      #   items. Computed for the chosen size only, which is why the search
      #   does not compute them for all nine.
      key <- model_key(cfg, cfg$items, state$dimension, dat)

      res <- wise_try(withProgress(message = "Diagnosing", value = 0.4, {
        list(fit = fit,
             diag = cached("diag", key, function() diagnose_model(fit, cfg, dat)))
      }), "Diagnosing the model")

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$model <- res
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

      res <- wise_try(withProgress(message = "Refitting in every replicate",
                              value = 0.2, {
        # Built on the WHOLE frame and restricted with an index, never
        #   rebuilt on the item-complete rows. Rebuilding drops any PSU that
        #   contributed no complete responder, which changes n_h, the
        #   n_h / (n_h - 1) scaling and the degrees of freedom -- the
        #   conditional subpopulation approach SURV701 warns against. It also
        #   gave this table a different degf from the domain table while the
        #   report said both came from one replicate set.
        full <- state$design_dat |>
          dplyr::bind_cols(state$item_frame$item_dat)
        keep <- state$item_frame$in_analysis
        des <- build_rep_design(full, cfg)
        measurement_se(cfg, dat, state$model$fit, des$rep_des, keep)
      }), "Estimating the uncertainty")

      if (inherits(res, "try-error")) {
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$measure <- res
    })

    # ---- results -----------------------------------------------------------

    output$body <- renderUI({
      req(state$model)
      tagList(
        tags$hr(),
        tags$h4("The measurement model"),
        plotOutput(ns("profiles"), height = "380px"),

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
        help_box("level_pattern"),
        tableOutput(ns("ratio")),

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
      tagList(
        tags$p(class = "text-muted",
               "From ", state$measure$replicates,
               " jackknife replicates, one refit each."),
        plotOutput(ns("prof_ci"), height = "400px"),
        tags$h5("Group sizes"),
        tableOutput(ns("shares_ci")))
    })

    # Every panel below requires the thing it is about to draw, not just the
    #   object that would contain it. state$measure is NULL until the variance
    #   step has run and one of its tables can come back NULL on its own, so
    #   req() on the container alone lets mutate() run on NULL and throw where
    #   the traceback names a renderTable rather than a cause.

    output$prof_ci <- renderPlot({
      req(state$measure$profile)
      plot_profiles_ci(state$measure$profile,
                       labels = state$labels$Label,
                       title = paste0(state$dimension, " groups"))
    }, bg = "transparent")

    output$shares_ci <- renderTable({
      req(state$measure$shares)
      state$measure$shares |>
        transmute(Group = group, Share = share, SE = se,
                  `95% interval` = paste0("[", lo, ", ", hi, "]"))
    }, width = "100%")

    output$disc_plot <- renderPlot({
      req(state$model$diag$discrimination)
      plot_discrimination(state$model$diag$discrimination)
    }, bg = "transparent")

    output$disc  <- renderTable({
      req(state$model$diag$discrimination)
      state$model$diag$discrimination |> mutate(flag = coalesce(flag, "")) },
      width = "100%")
    output$bvr   <- renderTable({
      req(state$model$diag$bvr); state$model$diag$bvr },
      width = "100%")
    output$ratio <- renderTable({
      req(state$model$diag$ratio); state$model$diag$ratio },
      width = "100%")

    observeEvent(input$read, {
      req(state$model)
      withProgress(message = "Reading", value = 0.5, {
        res <- try(llm_json(
          prompt_diagnostics(state$model$diag, state$dimension,
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
        evidence = log_table(state$model$diag$discrimination))

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
      state$search_key <- NULL
      state$search_reading <- NULL
      state$diag_reading <- NULL
      state$cfg <- NULL
      state$cfg_paths <- NULL

      showNotification(
        HTML(paste0(
          "<b>Recorded.</b> Three steps from here:<br>",
          "1. <b>Items</b> — remove ", paste(drop, collapse = ", "),
          " from the battery and press Summarise.<br>",
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
                          " groups",
                          " accepted after ", iteration_count(),
                          " round(s) of item removal."),
        evidence = log_table(state$model$diag$discrimination))
      showNotification("Accepted. Continue to Labels.", type = "message",
                       duration = NULL)
    })
  })
}

# ---- mod_labels --------------------------------------------------------

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

      res <- wise_try(withProgress(message = "Drafting", value = 0, {
        tick <- function(k) incProgress(1 / n_targets(), detail = k)
        drafted <- draft_labels(state, tick)
        setProgress(0.95, message = "Checking for duplicates")
        resolve_collisions(drafted, cfg)
      }), "Drafting the names")

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
      parts <- fs::dir_ls(wise_path("output"),
                          regexp = "labels[.]partial[.].*[.]csv$",
                          fail = FALSE)
      keep <- paste0("labels.partial.", substr(state$model_key, 1, 12), ".csv")
      walk(parts[fs::path_file(parts) != keep], fs::file_delete)

      load_or_draft(force = TRUE)
    })

    # ---- editor ------------------------------------------------------------

    output$editor <- renderUI({
      req(state$labels, state$model)
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
                   plotOutput(ns(paste0("prof_", i)), height = "220px"))))
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
      walk(seq_len(nrow(state$labels)), function(i) {
        output[[paste0("prof_", i)]] <- renderPlot({
          fit <- state$model$fit
          col <- viridis::viridis(1)

          # With the replicate refit done, the band is shown: a name should
          #   describe a shape the data actually resolves, not one the point
          #   estimates happen to trace.
          one <- if (!is.null(state$measure$profile))
            filter(state$measure$profile, group == i)
          else
            filter(profile_frame(fit, state$cfg$items),
                   group == paste0("Group ", i)) |>
              mutate(lo = NA_real_, hi = NA_real_)

          cap <- if (!is.null(state$measure$shares))
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
             "Saved to ", tags$code("output/labels.csv"),
             ". Editing that file by hand is also a way to take over naming; ",
             "deleting it triggers a redraft.")
    })
  })
}
