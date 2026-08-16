# ui_data.R for DrSvyR
# Screens 1 to 4: project, design, items, domains.

# Merged from: 
#   mod_project.R
#   mod_design.R
#   mod_items.R
#   mod_recode.R

# ---- mod_project -------------------------------------------------------

# mod_project.R for WISE repo
# Stage 1: choose the work folder and read the survey file.

# The analyst creates one folder and drops the data file and the technical
#   report into it. Everything else is scaffolded here, because requiring a
#   correctly pre-built folder tree is a whole category of failure that looks
#   like a bug in the workflow.

mod_project_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$h4("Work folder"),
    help_box("project"),

    fluidRow(
      column(9, textInput(ns("path"), NULL, width = "100%",
                          placeholder = "D:/work/my_project")),
      column(3, actionButton(ns("browse"), "Browse", width = "100%"))),

    actionButton(ns("use"), "Use this folder", class = "btn-primary"),
    tags$hr(),

    uiOutput(ns("folder_status")),
    tableOutput(ns("found")),

    uiOutput(ns("file_picker")),
    uiOutput(ns("read_status"))
  )
}


mod_project_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Pre-fill with whatever was used last. Stored outside the repository, so
    #   there is nothing repo-adjacent to commit by accident.
    observe({
      last <- last_work_folder()
      if (!is.null(last)) updateTextInput(session, "path", value = last)
    }) |> bindEvent(TRUE, once = TRUE)

    # rstudioapi is present because the app runs from RStudio, but the app must
    #   still work if it is not, so typing a path stays a first-class option.
    observeEvent(input$browse, {
      if (!rstudioapi::isAvailable()) {
        showNotification("Type the folder path instead.", type = "warning")
        return()
      }
      chosen <- rstudioapi::selectDirectory("Choose the work folder")
      if (!is.null(chosen)) updateTextInput(session, "path", value = chosen)
    })

    observeEvent(input$use, {
      req(nzchar(input$path))
      res <- try(scaffold_work_folder(input$path), silent = TRUE)

      if (inherits(res, "try-error")) {
        state$work_dir <- NULL
        showNotification(conditionMessage(attr(res, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      remember_work_folder()
      state$work_dir <- as.character(res)
      state$raw <- NULL          # a new folder invalidates everything after it
      state$codebook <- NULL
      state$design_dat <- NULL
    })

    output$folder_status <- renderUI({
      if (is.null(state$work_dir))
        return(tags$p(class = "text-muted", "No work folder set."))
      tagList(
        tags$p(tags$strong("Using: "), state$work_dir),
        tags$p(class = "text-muted",
               "Subfolders: ", paste(WISE_SUBDIRS, collapse = ", ")))
    })

    found <- reactive({
      req(state$work_dir)
      survey_work_folder(state$work_dir)
    })

    output$found <- renderTable({
      f <- found()
      if (!nrow(f)) return(NULL)
      transmute(f, kind, file = fs::path_rel(file, state$work_dir))
    })

    # Only data files are offered. A folder with no .sav or .dta is the common
    #   case of an analyst who has not copied the file in yet, and saying so is
    #   more useful than an empty dropdown.
    output$file_picker <- renderUI({
      f <- found()
      data_files <- filter(f, kind == "data")$file
      if (!length(data_files))
        return(tags$p(class = "text-danger",
                      "No .sav or .dta file found. Copy the survey file into ",
                      "the folder and press Use this folder again."))
      tagList(
        selectInput(ns("data_file"), "Survey file",
                    choices = set_names(data_files,
                                        fs::path_file(data_files)),
                    width = "100%"),
        actionButton(ns("read"), "Read file", class = "btn-primary"))
    })

    observeEvent(input$read, {
      req(input$data_file)
      withProgress(message = "Reading survey file", value = 0.3, {
        raw <- try(read_survey(input$data_file), silent = TRUE)
        if (inherits(raw, "try-error")) {
          showNotification(conditionMessage(attr(raw, "condition")),
                           type = "error", duration = NULL)
          return()
        }
        setProgress(0.7, message = "Building codebook")
        state$format <- survey_format(raw)
        state$data_file <- input$data_file
        state$raw <- raw
        state$codebook <- build_codebook(raw)
        state$design_dat <- NULL       # a new file invalidates the design
        state$design_map <- NULL
      })
    })

    output$read_status <- renderUI({
      req(state$raw)
      tagList(
        tags$hr(),
        tags$p(tags$strong(format(nrow(state$raw), big.mark = ",")),
               " respondents, ",
               tags$strong(ncol(state$raw)), " variables, format ",
               tags$strong(state$format), "."),
        if (identical(state$format, "stata"))
          tags$p(class = "text-warning",
                 "Stata files carry extended missing values as tagged NAs, ",
                 "already missing to R. Treating a 'don't know' as a ",
                 "substantive category is not available for this format."),
        tags$p(class = "text-muted", "Continue to Design."))
    })
  })
}

# ---- mod_design --------------------------------------------------------

# mod_design.R for WISE repo
# Stage 2: confirm the complex design and check the specification.

# Nominations are suggestions for a dropdown, never selections. The variable
#   named "strata" is not automatically the stratum -- on the demonstration
#   file it carries a weight's label -- so the analyst confirms and the checks
#   below are what settle whether the choice holds.

mod_design_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("selectors")),
    uiOutput(ns("aliases")),
    tags$hr(),
    tableOutput(ns("checks")),
    uiOutput(ns("verdict"))
  )
}


mod_design_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$raw))
        tags$p(class = "text-muted", "Read a survey file in Project first.")
    })

    nominations <- reactive({
      req(state$raw, state$codebook)
      group_nominations(state$raw, nominate_design(state$codebook))
    })

    # Every variable in the file is offered, with the nominated ones first, so
    #   a pattern that missed is an inconvenience rather than a dead end.
    choices_for <- function(role) {
      nom <- filter(nominations(), role == !!role)$variable
      all <- state$codebook$variable
      c(nom, setdiff(all, nom))
    }

    output$selectors <- renderUI({
      req(state$raw)
      tagList(
        tags$h4("Design variables"),
        help_box("design"),
        fluidRow(
          column(3, selectInput(ns("id"), "Respondent id",
                                choices_for("id"), width = "100%")),
          column(3, selectInput(ns("strata"), "Stratum",
                                choices_for("strata"), width = "100%")),
          column(3, selectInput(ns("psu"), "Primary sampling unit",
                                choices_for("psu"), width = "100%")),
          column(3, selectInput(ns("weight"), "Weight",
                                choices_for("weight"), width = "100%"))),
        actionButton(ns("check"), "Check design", class = "btn-primary"))
    })

    # Two candidates that cut the sample the same way are interchangeable, and
    #   saying so removes a choice the analyst cannot make on the evidence.
    output$aliases <- renderUI({
      req(state$raw)
      dup <- nominations() |>
        group_by(role, group) |>
        filter(n() > 1) |>
        summarise(vars = paste(variable, collapse = " = "), .groups = "drop")
      if (!nrow(dup)) return(NULL)
      tags$p(class = "text-muted",
             "Identical partitions, either may be used: ",
             paste(dup$vars, collapse = "; "), ".")
    })

    observeEvent(input$check, {
      map <- c(id = input$id, strata = input$strata,
               psu = input$psu, weight = input$weight)
      dd <- try(build_design_frame(state$raw, map), silent = TRUE)

      if (inherits(dd, "try-error")) {
        showNotification(conditionMessage(attr(dd, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$design_map <- map
      state$design_dat <- dd
      state$design_checks <- design_checks(dd)
    })

    output$checks <- renderTable({
      req(state$design_checks)
      state$design_checks |>
        transmute(Check = check, Value = value,
                  Status = recode_values(status,
                                         "ok" ~ "", "warn" ~ "warn",
                                         "stop" ~ "STOP"),
                  Note = note)
    }, width = "100%")

    # A stop is a specification that cannot produce honest standard errors, so
    #   it blocks rather than warns. A warn is information the analyst carries
    #   forward into how they read the estimates.
    output$verdict <- renderUI({
      req(state$design_checks)
      n_stop <- sum(state$design_checks$status == "stop")
      n_warn <- sum(state$design_checks$status == "warn")

      if (n_stop > 0)
        return(tags$p(class = "text-danger",
                      tags$strong(n_stop), " check(s) halt the design. ",
                      "Fix the specification before continuing."))
      tagList(
        tags$p(class = "text-success",
               "Design accepted. Replicate weights will be stratified ",
               "jackknife over ", tags$strong(n_distinct(state$design_dat$psu)),
               " PSUs."),
        if (n_warn > 0)
          tags$p(class = "text-warning",
                 tags$strong(n_warn), " warning(s) above. These do not block ",
                 "the analysis but they change how the estimates should be ",
                 "read."))
    })
  })
}

# ---- mod_items ---------------------------------------------------------

# mod_items.R for WISE repo
# Stage 3: explore the candidate items and choose an arm.

# The analyst designed the questionnaire, so item content is their call and the
#   app should get out of the way. The two things they cannot see by eye are
#   variation and dimensionality, so those are computed and shown.

mod_items_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),

    uiOutput(ns("context_box")),

    tags$hr(),
    tags$h4("Don't know and refused"),
    help_box("na_codes"),
    tableOutput(ns("na_table")),
    uiOutput(ns("na_confirm")),

    tags$hr(),
    tags$h4("Choose the battery"),
    help_box("items"),
    uiOutput(ns("item_picker")),

    uiOutput(ns("variation_block")),

    tags$hr(),
    tags$h4("Which model fits this battery"),
    help_box("arm_intro"),
    uiOutput(ns("arm_block"))
  )
}


mod_items_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$design_dat))
        tags$p(class = "text-muted", "Confirm the design first.")
    })

    # The free-text goal travels into every prompt from here on and into the
    #   report's framing, so it is collected once and shown back rather than
    #   asked for repeatedly.
    output$context_box <- renderUI({
      req(state$design_dat)
      tagList(
        tags$h4("Study context"),
        textAreaInput(ns("context"), NULL, width = "100%", rows = 4,
                      value = state$context %||% "",
                      placeholder = paste(
                        "Country, what the study is for, who reads the",
                        "results, and what you want the segments or the",
                        "factor to tell you.")),
        # Asked here rather than at the report, and deliberately. A question
        #   written after the results are known is a question chosen to match
        #   the answer. Written now, it can order the report without deciding
        #   what goes in it.
        textAreaInput(ns("question"), "Research question (optional)",
                      width = "100%", rows = 2,
                      value = state$question %||% "",
                      placeholder = paste(
                        "What you want this analysis to answer. It sets what",
                        "the report leads with -- every difference the data",
                        "resolve is reported either way, and the report says",
                        "what the question cannot be answered on.")),
        actionButton(ns("save_context"), "Save"))
    })

    observeEvent(input$save_context, {
      state$context <- input$context
      state$question <- input$question
      showNotification("Saved.", type = "message")
    })

    # ---- nonresponse codes -------------------------------------------------

    na_candidates <- reactive({
      req(state$raw, state$codebook)
      detect_na_codes(state$raw, candidate_items(state$codebook)$variable)
    })

    output$na_table <- renderTable({
      req(state$design_dat)
      na_candidates() |>
        transmute(Code = code, Response = response, Source = source,
                  `Items affected` = n_items)
    })

    output$na_confirm <- renderUI({
      req(state$design_dat)
      cand <- na_candidates()
      tagList(
        checkboxGroupInput(ns("na_codes"), NULL,
                           choices = set_names(cand$code,
                                               paste0(cand$code, " — ", cand$response)),
                           selected = cand$code, inline = TRUE),
        tags$p(class = "text-muted",
               "Unchecking a code keeps it as a substantive answer category."))
    })

    # ---- items -------------------------------------------------------------

    output$item_picker <- renderUI({
      req(state$codebook)
      cand <- candidate_items(state$codebook)
      tagList(
        selectizeInput(ns("items"), "Battery", multiple = TRUE, width = "100%",
                       choices = set_names(cand$variable,
                                           paste0(cand$variable, " — ", cand$label)),
                       options = list(placeholder = "Choose the items")),
        checkboxInput(ns("complete"), "Fit on item-complete cases only",
                      value = TRUE),
        actionButton(ns("build"), "Summarise", class = "btn-primary"))
    })

    # Every failure here is a statement about the battery the analyst chose --
    #   a split ballot, an item nobody answered, too few complete responders --
    #   so it is shown rather than allowed to take the session down.
    observeEvent(input$build, {
      req(length(input$items) >= 3)
      map <- set_names(input$items, input$items)

      fr <- try(build_item_frame(state$raw, map,
                                 na_codes = as.numeric(input$na_codes),
                                 complete_cases = isTRUE(input$complete)),
                silent = TRUE)
      if (inherits(fr, "try-error")) {
        state$item_frame <- NULL; state$item_summary <- NULL
        state$arm_diag <- NULL; state$arm_advice <- NULL
        showNotification(conditionMessage(attr(fr, "condition")),
                         type = "error", duration = NULL)
        return()
      }

      state$item_frame <- fr
      state$item_summary <- item_summary(fr)
      state$arm_advice <- NULL
      # Carried forward: the recode stage needs the same codes so a "don't
      #   know" is missing in a demographic exactly as it is in an item.
      state$na_codes <- as.numeric(input$na_codes)

      diag <- try(arm_diagnostics(fr, state$design_dat), silent = TRUE)
      if (inherits(diag, "try-error")) {
        state$arm_diag <- NULL
        showNotification(conditionMessage(attr(diag, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$arm_diag <- diag
    })

    # The help text appears only once there is something to read, so an empty
    #   screen is not also a wall of instructions.
    output$variation_block <- renderUI({
      req(state$item_frame)
      fr <- state$item_frame
      tagList(
        tags$h4("How people answered"),
        help_box("variation"),
        tags$p(tags$strong(format(sum(fr$in_analysis), big.mark = ",")),
               " of ", format(nrow(fr$item_dat), big.mark = ","),
               " respondents qualify for this battery."),
        plotOutput(ns("dist_plot"), height = "380px"),
        tableOutput(ns("item_tbl")))
    })

    output$dist_plot <- renderPlot({
      req(state$item_frame)
      plot_items(state$item_frame)
    })

    # modal_pct is the column to read: an item everyone answers the same way
    #   passes every fit statistic and carries no information about who differs.
    output$item_tbl <- renderTable({
      req(state$item_summary)
      state$item_summary |>
        transmute(Item = item, Categories = categories, Answered = answered,
                  `Shared with fewest` = min_shared,
                  `Missing %` = missing_pct, `Modal %` = modal_pct,
                  Flag = coalesce(flag, ""))
    }, width = "100%")

    # ---- arm ---------------------------------------------------------------

    output$arm_block <- renderUI({
      req(state$arm_diag)
      tagList(
        help_box("arm_choice"),

        tags$h5("What the answers suggest"),
        help_box("arm_evidence"),
        tableOutput(ns("arm_tbl")),

        tags$h5("What do you expect?"),
        radioButtons(
          ns("preference"), NULL,
          choiceNames = list(
            tags$span(tags$strong("Distinct groups."),
                      " People fall into types that answer in different",
                      " patterns. Each respondent gets a group."),
            tags$span(tags$strong("Degrees of one thing."),
                      " Everyone sits on a single scale from low to high.",
                      " Each respondent gets a score.")),
          choiceValues = list("lca", "cfa")),

        help_box("arm_ask"),
        actionButton(ns("ask"), "Ask the methodologist"),
        actionButton(ns("commit"), "Use this and continue", class = "btn-primary"),
        uiOutput(ns("arm_advice")),
        uiOutput(ns("estimator_block")))
    })

    # Offered only where the response scales justify it. Treating a two- or
    #   three-category item as continuous is not an approximation, it is wrong;
    #   at five or more the approximation is one most methodologists would
    #   accept, and it is the difference between scoring everyone and scoring
    #   only complete responders.
    output$estimator_block <- renderUI({
      req(state$arm_diag)
      if (!identical(input$preference, "cfa")) return(NULL)
      if (state$arm_diag$min_categories < 5) return(NULL)

      tagList(
        tags$hr(),
        tags$h5("How should the answer scales be treated?"),
        help_box("estimator"),
        radioButtons(
          ns("estimator"), NULL,
          choiceNames = list(
            tags$span(tags$strong("As ordered categories."),
                      " More exact. Only respondents who answered every",
                      " question can be given a score."),
            tags$span(tags$strong("As a continuous scale."),
                      " An approximation. Respondents who skipped some",
                      " questions can still be scored from the ones they",
                      " answered.")),
          choiceValues = list("WLSMV", "ML"),
          selected = state$estimator %||% "WLSMV"))
    })

    output$arm_tbl <- renderTable({
      req(state$arm_diag)
      state$arm_diag |>
        transmute(Items = n_items, `Response formats` = n_formats,
                  `1st eigenvalue` = eigen_1, `2nd eigenvalue` = eigen_2,
                  `Ratio` = eigen_ratio,
                  `Explained by one scale %` = var_explained_1)
    }, width = "100%")

    # The model reads R's numbers and the stated goal, and argues once. It never
    #   overrides: pressing Use this arm is what settles it.
    observeEvent(input$ask, {
      req(state$arm_diag, state$item_summary)
      withProgress(message = "Asking", value = 0.5, {
        res <- try(llm_json(
          prompt_arm_recommendation(state$arm_diag, state$item_summary,
                                    input$preference, state$context %||% ""),
          role = "pm", system_prompt = persona_pm,
          validate = validate_fields(c("recommendation", "reasoning"))),
          silent = TRUE)
        if (inherits(res, "try-error")) {
          showNotification(conditionMessage(attr(res, "condition")),
                           type = "error", duration = NULL)
          return()
        }
        state$arm_advice <- res
      })
    })

    output$arm_advice <- renderUI({
      req(state$arm_advice)
      a <- state$arm_advice
      agrees <- isTRUE(a$agrees_with_preference)
      advice_box(
        tags$p(tags$strong(
          if (agrees) "The methodologist agrees with you."
          else "The methodologist disagrees with you.")),
        tags$p(a$reasoning),
        tags$p(class = "text-muted",
               "Your choice is what runs. A disagreement is recorded in the ",
               "report either way."))
    })

    observeEvent(input$commit, {
      req(input$preference, state$item_frame)
      state$arm <- input$preference
      state$estimator <- if (identical(input$preference, "cfa"))
        (input$estimator %||% "WLSMV") else NULL

      showNotification(
        paste0("Set to ",
               if (identical(input$preference, "lca")) "distinct groups"
               else paste0("one continuum, items treated as ",
                           if (identical(state$estimator, "ML"))
                             "a continuous scale" else "ordered categories"),
               "."),
        type = "message")
    })
  })
}

# ---- mod_recode --------------------------------------------------------

# mod_recode.R for WISE repo
# Stage 4: collapse the demographic and attitudinal domains.

# One control per observed category. Typing the same group name against two
#   categories merges them; leaving one blank treats it as missing. That is the
#   whole interaction, and it is deliberately literal: a drag-and-drop grouping
#   would be quicker and would hide which source label went where, which is the
#   one thing the audit exists to show.

# Suggestions are made by a single button covering every variable at once.
#   Registering one observer per dynamically drawn button stacks duplicates
#   every time the categories are reloaded, and the duplicates fire silently.

mod_recode_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("gate")),
    uiOutput(ns("picker")),
    uiOutput(ns("editors")),
    uiOutput(ns("apply_row")),
    uiOutput(ns("results"))
  )
}


mod_recode_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$gate <- renderUI({
      if (is.null(state$arm))
        tags$p(class = "text-muted", "Choose an arm in Items first.")
    })

    na_codes <- reactive(as.numeric(state$na_codes %||% numeric(0)))

    output$picker <- renderUI({
      req(state$arm, state$codebook)
      cand <- demo_candidates(state$codebook) |>
        filter(!variable %in% state$item_frame$items)
      tagList(
        tags$h4("Domains"),
        help_box("domains_pick"),
        selectizeInput(ns("vars"), NULL, multiple = TRUE, width = "100%",
                       choices = set_names(cand$variable,
                                           paste0(cand$variable, " — ", cand$label)),
                       options = list(placeholder = "Choose the demographics")),
        actionButton(ns("load"), "Show categories"))
    })

    # Held in a reactiveVal rather than recomputed, so the editors do not reset
    #   every time an unrelated input changes.
    loaded <- reactiveVal(NULL)

    observeEvent(input$load, {
      req(length(input$vars) >= 1)
      loaded(map(input$vars, function(v) {
        row <- filter(state$codebook, variable == v)
        kind <- if (row$n_responses > 1 && row$n_responses <= 30) "map" else "cut"
        list(variable = v, label = row$label, kind = kind,
             levels = if (kind == "map")
               observed_levels(state$raw, v, na_codes()) else NULL,
             summary = if (kind == "cut")
               numeric_summary(state$raw, v, na_codes()) else NULL)
      }) |> set_names(input$vars))
    })

    output$editors <- renderUI({
      req(loaded())
      map(loaded(), function(L) {
        if (identical(L$kind, "map")) {
          rows <- map(seq_len(nrow(L$levels)), function(i) {
            fluidRow(
              column(6, tags$p(style = "margin-top:6px;",
                               L$levels$source_label[i],
                               tags$span(class = "text-muted",
                                         paste0("  (n = ", L$levels$n[i], ")")))),
              column(6, textInput(ns(paste0("map_", L$variable, "_", i)), NULL,
                                  value = L$levels$source_label[i],
                                  width = "100%")))
          })
          tagList(
            tags$hr(),
            tags$h5(paste0(L$variable, " — ", L$label)),
            help_box("recode_map"),
            rows,
            selectInput(ns(paste0("ref_", L$variable)), "Reference level",
                        choices = c("choose one" = ""), width = "50%"))
        } else {
          tagList(
            tags$hr(),
            tags$h5(paste0(L$variable, " — ", L$label)),
            help_box("recode_cut"),
            tableOutput(ns(paste0("num_", L$variable))),
            textInput(ns(paste0("brk_", L$variable)), "Cut points",
                      value = "", width = "50%",
                      placeholder = "lowest, cut, cut, ..., Inf"),
            textInput(ns(paste0("lab_", L$variable)), "Band names",
                      value = "", width = "50%",
                      placeholder = "one fewer name than cut points"),
            selectInput(ns(paste0("ref_", L$variable)), "Reference level",
                        choices = c("choose one" = ""), width = "50%"))
        }
      })
    })

    # The reference dropdowns offer only groups that currently exist, so they
    #   follow whatever the analyst types and cannot name a group that was
    #   renamed or removed. Deliberately not proposed by the model: which level
    #   the findings are read against is a presentation decision.
    group_names <- reactive({
      req(loaded())
      map(loaded(), function(L) {
        vals <- if (identical(L$kind, "map")) {
          map_chr(seq_len(nrow(L$levels)), function(i)
            input[[paste0("map_", L$variable, "_", i)]] %||% "")
        } else {
          str_trim(str_split(input[[paste0("lab_", L$variable)]] %||% "",
                             ",")[[1]])
        }
        sort(unique(vals[nzchar(vals)]))
      }) |> set_names(names(loaded()))
    })

    observe({
      iwalk(group_names(), function(ch, nm) {
        if (!length(ch)) return()
        updateSelectInput(session, paste0("ref_", nm),
                          choices = c("choose one" = "", ch),
                          selected = isolate(input[[paste0("ref_", nm)]]) %||% "")
      })
    })

    # Numeric summaries are rendered per variable, so the outputs are created
    #   when the variables are loaded rather than declared in the UI up front.
    observeEvent(loaded(), {
      walk(loaded(), function(L) {
        if (identical(L$kind, "cut"))
          output[[paste0("num_", L$variable)]] <- renderTable(L$summary)
      })
    })

    # An empty box means missing, which is correct and invisible: it reads as
    #   "not filled in yet" rather than as a decision. Listing the consequence
    #   before Apply is the difference between choosing to drop a category and
    #   discovering afterwards that you did.
    to_missing <- reactive({
      req(loaded())
      map(loaded(), function(L) {
        if (!identical(L$kind, "map")) return(NULL)
        tgt <- map_chr(seq_len(nrow(L$levels)), function(i)
          input[[paste0("map_", L$variable, "_", i)]] %||% "")
        blank <- !nzchar(tgt)
        if (!any(blank)) return(NULL)
        tibble(variable = L$variable,
               source_label = L$levels$source_label[blank],
               n = L$levels$n[blank])
      }) |> list_rbind()
    })

    output$apply_row <- renderUI({
      req(loaded())
      n_map <- sum(map_chr(loaded(), "kind") == "map")
      drop <- to_missing()

      tagList(
        tags$hr(),
        if (n_map > 0)
          tagList(
            actionButton(ns("suggest"),
                         paste0("Suggest groupings (", n_map, " call",
                                if (n_map != 1) "s" else "", ")")),
            tags$span(class = "text-muted",
                      "  Fills the boxes. Nothing is applied until you press ",
                      "Apply recodes.")),

        if (!is.null(drop) && nrow(drop) > 0)
          warn_box(
            tags$strong("These categories will be treated as missing:"),
            tags$ul(map(seq_len(nrow(drop)), function(i)
              tags$li(drop$variable[i], ": ", drop$source_label[i],
                      " (n = ", drop$n[i], ")"))),
            tags$div("Respondents in these categories are dropped from every ",
                     "estimate involving that domain. Type a group name to ",
                     "keep them.")),

        tags$br(),
        actionButton(ns("apply"), "Apply recodes", class = "btn-primary"))
    })

    # One observer, one pass over every labelled variable. A failure on one
    #   variable is reported and the rest continue: a proposal is a convenience
    #   and losing it should not cost the others.
    observeEvent(input$suggest, {
      req(loaded())
      targets <- keep(loaded(), function(L) identical(L$kind, "map"))
      withProgress(message = "Asking", value = 0, {
        iwalk(targets, function(L, nm) {
          incProgress(1 / length(targets), detail = nm)

          res <- try(llm_json(
            prompt_demo_grouping(L$variable, L$label, L$levels,
                                 state$context %||% ""),
            role = "pm", system_prompt = persona_pm,
            validate = validate_fields("groups")), silent = TRUE)

          if (inherits(res, "try-error")) {
            showNotification(paste0(nm, ": ",
                                    conditionMessage(attr(res, "condition"))),
                             type = "error", duration = NULL)
            return()
          }

          proposed <- set_names(
            map_chr(res$groups, function(g) as.character(g$group %||% "")),
            map_chr(res$groups, function(g) as.character(g$source %||% "")))

          walk(seq_len(nrow(L$levels)), function(i) {
            src <- L$levels$source_label[i]
            if (src %in% names(proposed))
              updateTextInput(session, paste0("map_", L$variable, "_", i),
                              value = unname(proposed[src]))
          })
        })
      })
      showNotification("Groupings filled in. Choose a reference level for each.",
                       type = "message", duration = 8)
    })

    observeEvent(input$apply, {
      req(loaded())

      # Every domain needs a reference level and it is the analyst's to pick.
      #   Checked before anything is built, so the message names what is missing
      #   rather than surfacing as a factor with an arbitrary first level.
      missing_ref <- keep(names(loaded()), function(nm)
        !nzchar(input[[paste0("ref_", nm)]] %||% ""))
      if (length(missing_ref)) {
        showNotification(
          paste0("Choose a reference level for: ",
                 paste(missing_ref, collapse = ", "),
                 ". This is the group later comparisons are read against."),
          type = "warning", duration = NULL)
        return()
      }

      specs <- map(loaded(), function(L) {
        ref <- input[[paste0("ref_", L$variable)]]
        if (identical(L$kind, "map")) {
          tgt <- map_chr(seq_len(nrow(L$levels)), function(i)
            input[[paste0("map_", L$variable, "_", i)]] %||% "")
          m <- set_names(if_else(nzchar(tgt), tgt, NA_character_),
                         L$levels$source_label)
          list(source = L$variable, kind = "map", map = m, reference = ref)
        } else {
          brk <- suppressWarnings(as.numeric(str_trim(
            str_split(input[[paste0("brk_", L$variable)]] %||% "", ",")[[1]])))
          lab <- str_trim(str_split(
            input[[paste0("lab_", L$variable)]] %||% "", ",")[[1]])
          list(source = L$variable, kind = "cut", breaks = brk, labels = lab,
               reference = ref)
        }
      })

      dd <- try(build_demo_frame(state$raw, specs, na_codes()), silent = TRUE)
      if (inherits(dd, "try-error")) {
        showNotification(conditionMessage(attr(dd, "condition")),
                         type = "error", duration = NULL)
        return()
      }
      state$demo_specs <- specs
      state$demo_dat <- dd
      state$demo_counts <- demo_counts(dd)
      state$recode_audit <- recode_audit(state$raw, dd, specs)

      small <- sum(!is.na(state$demo_counts$flag))
      showNotification(
        paste0(length(specs), " domain",
               if (length(specs) != 1) "s" else "", " applied. ",
               if (small > 0)
                 paste0(small, " group", if (small != 1) "s are" else " is",
                        " too small to report — check the table below. ")
               else "",
               "Read the audit, then continue to Dictionary."),
        type = if (small > 0) "warning" else "message", duration = NULL)
    })

    output$results <- renderUI({
      req(state$demo_counts)
      tagList(
        tags$hr(),
        tags$h4("Result"),
        help_box("recode_result"),
        tableOutput(ns("counts")),
        tags$h5("Audit"),
        help_box("recode_audit"),
        tableOutput(ns("audit")))
    })

    output$counts <- renderTable({
      req(state$demo_counts)
      state$demo_counts |>
        transmute(Variable = variable, Level = level, n = n,
                  Missing = missing, Flag = coalesce(flag, ""))
    }, width = "100%")

    output$audit <- renderTable({
      req(state$recode_audit)
      state$recode_audit |>
        transmute(Variable = variable, `Source label` = source_label,
                  `Became` = coalesce(recoded, "(missing)"), n = n)
    }, width = "100%")
  })
}

