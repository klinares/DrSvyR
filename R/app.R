# Column names, declared.

# Every name below is a COLUMN referred to inside a dplyr verb or an aes(),
#   not a variable this package fails to define. R CMD check walks the code
#   without evaluating it, so it cannot tell dplyr::filter(d, segment == k)
#   from a reference to a missing object, and reports all of them.
# This list is harvested from the check's own "Undefined global functions or
#   variables" output rather than written by hand, and it should be
#   regenerated the same way rather than appended to by guesswork. Keeping it
#   curated is the point: a blanket suppression would hide the one entry that
#   really is a missing object, which is the failure mode this whole check
#   exists to catch.
# AIC and BIC are here rather than imported from stats: they are columns built
#   in search_sizes() and read by plot_bic(). So is example, a column in the
#   nonresponse-code clash table. See the note in NAMESPACE.
utils::globalVariables(c(
  ".wise_id", "AIC", "BIC", "Claim", "Description", "Estimator", "Group",
  "K", "Label", "Level", "answered", "assigned", "b", "bvr",
  "categories", "cell", "check", "criterion", "delta", "discrimination",
  "estimator", "example", "flag", "gap", "group", "hi", "hi_a", "hi_b",
  "id", "idx", "idx_a", "idx_b", "item", "kind", "label", "level", "lo",
  "lo_a", "lo_b", "m", "max_posterior", "mean_certainty", "measure",
  "mid", "min_shared", "missing_pct", "modal_pct", "n_items",
  "n_items_answered", "n_psu", "n_responses", "n_scored",
  "n_substantive", "nn", "note", "outside", "p_adj", "percent",
  "prevalence", "prob", "psu", "question", "recoded", "response",
  "responses", "role", "sd_level", "sd_pattern", "se", "segment",
  "share", "source_label", "status", "strata", "target", "value",
  "variable", "weighted"))


# The application: its state, its layout, its server, and the one function a
#   user calls.

# This was app.R at the repository root and it is now package code. What went
#   with the move, and why none of it is missed:
#   - library() calls. NAMESPACE declares the imports now, so filter(), map(),
#     aes() and the rest resolve the same way without attaching anything to
#     the user's search path.
#   - the dir.exists("R") guard, and the loop that parsed every file in R/ and
#     refused any with a top-level statement. A package's R/ is evaluated at
#     build time and R CMD check reports exactly this, better and earlier.
#   - the count of files matching ^llm in R/. There is one llm.R now and the
#     endpoint is an option, so there is no second file for the alphabet to
#     choose between.
#   That is roughly seventy lines of scaffolding deleted, all of it there to
#   police problems that being a package removes rather than solves.

# One state object, passed to every module. Modules read from it and write to
#   it; they never talk to each other. A stage that needs something a previous
#   stage has not produced sees NULL and says so, which is what makes the
#   sequence enforce itself without explicit gating.

# goto is the exception: a module that has invalidated everything downstream
#   sets it, and the observer below moves the analyst there. Without it, "go
#   back and start again" is an instruction rather than a step.
new_state <- function() {
  reactiveValues(
    work_dir      = NULL,
    data_file     = NULL,
    format        = NULL,
    raw           = NULL,
    codebook      = NULL,
    design_map    = NULL,
    design_dat    = NULL,
    design_checks = NULL,
    context       = NULL,
    na_codes      = NULL,
    item_frame    = NULL,
    item_summary  = NULL,
    demo_specs    = NULL,
    demo_dat      = NULL,
    demo_counts   = NULL,
    recode_audit  = NULL,
    cfg           = NULL,
    cfg_paths     = NULL,
    config_readback = NULL,
    search        = NULL,
    search_key    = NULL,
    dimension     = NULL,
    search_reading = NULL,
    model         = NULL,
    model_key     = NULL,
    model_accepted = NULL,
    model_dat     = NULL,
    measure       = NULL,
    diag_reading  = NULL,
    labels        = NULL,
    labels_drafted = NULL,
    labels_edited = NULL,
    scored        = NULL,
    score_design  = NULL,
    coverage      = NULL,
    quality       = NULL,
    shares        = NULL,
    domains       = NULL,
    domain_reads  = NULL,
    question      = NULL,
    report_summary = NULL,
    report_not_answered = NULL,
    report_classification = NULL,
    report_html   = NULL,
    outputs       = NULL,

    # The methodologist panel. proposals is every staged action and what the
    #   analyst did with it; pending_proposal is the one awaiting a decision.
    #   key_version is a counter, never a key: it exists so a change of key
    #   discards any conversation holding the previous one.
    proposals         = NULL,
    pending_proposal  = NULL,
    key_version       = 0L,

    goto          = NULL)
}

# Start here is first so it is where the app opens. An analyst landing on
#   "1. Project" with no orientation has to work out what the tool is from a
#   folder picker, and a guide sitting thirteenth in the list is one nobody
#   reads. Methodologist sits outside the numbered sequence for the opposite
#   reason: it is not a stage to be completed but an adviser available at any
#   of them.
WISE_TABS <- c("Start here",
               "1. Project", "2. Design", "3. Items", "4. Domains",
               "5. Review", "6. Search", "7. Model", "8. Names",
               "9. Scoring", "10. Results", "11. Outputs",
               "AI Survey Methodologist")


app_ui <- function() page_fluid(
  theme = bs_theme(version = 5, preset = "flatly"),
  title = "DrSvyR",

  # First child, so it sits above the header and above whichever tab is open.
  #   One banner rather than one per tab: this is one page with tabs inside
  #   it, not many pages.
  classification_banner(),

  div(
    style = "display:flex; align-items:center; gap:1rem; margin-bottom:0.5rem;",
    div(tags$h2("DrSvyR", style = "margin:0;"),
        tags$p(tags$em("A survey methodologist you can consult, working on ",
                       "data you already have."),
               style = "margin:0;")),
    div(style = "margin-left:auto;", input_dark_mode(id = "dark_mode"))),
  
  # Markdown rendered by includeMarkdown() carries no sizing, so a figure comes
  #   through at its natural pixel width and overflows the panel. Scoped to the
  #   tab content, so it constrains the Help figures without reaching the
  #   header above them.
  tags$head(tags$style(HTML(
    ".tab-content img { max-width: 100%; height: auto; }"))),

  tags$hr(),
  
  navlistPanel(
    id = "stage",
    widths = c(3, 9),
    well = FALSE,
    
    # help.md rather than README.md. One document cannot serve both a reader
    #   deciding whether to trust the tool and an analyst who has it open and
    #   needs to start; they want opposite things. Rendered in place rather
    #   than linked out, so it needs no network and cannot drift from the
    #   version installed.
    tabPanel(WISE_TABS[1],
             includeMarkdown(system.file("app", "help.md", package = "drsvyr")),
             mod_key_ui("key")),

    tabPanel(WISE_TABS[2], mod_project_ui("project")),
    tabPanel(WISE_TABS[3], mod_design_ui("design")),
    tabPanel(WISE_TABS[4], mod_items_ui("items")),
    tabPanel(WISE_TABS[5], mod_recode_ui("recode")),
    tabPanel(WISE_TABS[6], mod_config_ui("config")),
    tabPanel(WISE_TABS[7], mod_search_ui("search")),
    tabPanel(WISE_TABS[8], mod_model_ui("model")),
    tabPanel(WISE_TABS[9], mod_labels_ui("labels")),
    tabPanel(WISE_TABS[10], mod_score_ui("score")),
    tabPanel(WISE_TABS[11], mod_domains_ui("domains")),
    tabPanel(WISE_TABS[12], mod_report_ui("report")),

    tabPanel(WISE_TABS[13], mod_chat_ui("chat"))
  )
)


app_server <- function(input, output, session) {
  state <- new_state()
  
  # Figures are theme-neutral, so nothing here has to know which mode is in
  #   use. That is what makes them safe on a server: the option this used to
  #   set was process-wide and would have followed one analyst into another's
  #   plots.
  
  observeEvent(state$goto, {
    updateNavlistPanel(session, "stage", selected = state$goto)
    state$goto <- NULL
  }, ignoreNULL = TRUE)
  
  mod_project_server("project", state)
  mod_design_server("design", state)
  mod_items_server("items", state)
  mod_recode_server("recode", state)
  mod_config_server("config", state)
  mod_search_server("search", state)
  mod_model_server("model", state)
  mod_labels_server("labels", state)
  mod_score_server("score", state)
  mod_domains_server("domains", state)
  mod_report_server("report", state)

  # "Why did this respondent not get a score" cannot be answered from the
  #   console, because state lives in here and nowhere else. On request, a
  #   plain snapshot is left in the global environment when the session ends
  #   -- a copy, not the reactiveValues object, so nothing typed afterwards
  #   can write back into a run. Enable with options(drsvyr.debug = TRUE)
  #   before runApp().
  if (isTRUE(getOption("drsvyr.debug")))
    session$onSessionEnded(function()
      assign("state", isolate(reactiveValuesToList(state)),
             envir = globalenv()))

  # Handed the current tab rather than inferring the stage from whatever state
  #   happens to hold, so it answers about where the analyst actually is.
  mod_chat_server("chat", state, reactive(input$stage))
  mod_key_server("key", state)
}




# The entry point, and the only thing this package exports.

# Everything an analyst needs is behind one call: drsvyr::run_drsvyr(). No
#   working directory to be in, no .Rproj to open, no folder to source. That is
#   the point of the conversion -- the launch script and the server deployment
#   both reduce to this line.
run_drsvyr <- function(port = getOption("drsvyr.port", 7817L),
                       host = "127.0.0.1",
                       launch.browser = interactive()) {

  # Shiny serves static files from the resource paths it is told about and
  #   nowhere else, so a figure referenced as figures/... from the help
  #   markdown would render on GitHub and 404 in the app. Mapped from inside
  #   the installed package rather than from the working directory, because
  #   there is no longer any assumption about where the user is sitting.
  figs = system.file("app", "figures", package = "drsvyr")
  if (nzchar(figs)) addResourcePath("figures", figs)

  # An uploaded .sav is the whole point of the Project screen and Shiny's
  #   default ceiling is 5 MB, which any real survey file clears immediately
  #   and fails on with a message that names neither the size nor the limit.
  # Set per call rather than at load: this is a property of running the app,
  #   not of having the package installed, and a package that changed a global
  #   option on load would be changing it for everything else in the session.
  old = options(shiny.maxRequestSize = getOption("drsvyr.max_upload",
                                                 300 * 1024^2))
  on.exit(options(old), add = TRUE)

  # The port is probed before it is used, rather than tried and caught on
  #   failure. An earlier version wrapped runApp() itself in tryCatch and
  #   matched the error text for "already in use" -- and that failed in
  #   practice, because the R-level condition was "Failed to create server"
  #   with no mention of the port; the more specific text is written directly
  #   to stderr by httpuv's C++ layer and never reaches the R condition object
  #   at all. Matching internal wording that isn't guaranteed to stay the same
  #   is the wrong foundation for this.
  # httpuv::startServer() on a trivial handler is the same bind call runApp()
  #   would make, stopped immediately after it succeeds. If it throws, the
  #   port was taken; nothing else can be wrong with a one-line handler, so
  #   any error here is treated as exactly that. This is the ordinary shape of
  #   an analyst's session, not an edge case: close the browser tab, leave the
  #   terminal running, run this again tomorrow, and the port from yesterday
  #   is still held. Ten tries is generous for a stray previous session.
  free = NULL
  for (p in seq(port, port + 9L)) {
    probe = tryCatch(startServer(host, p, list()), error = function(e) NULL)
    if (!is.null(probe)) { stopServer(probe); free = p; break }
    if (p == port) cat("Port ", port, " is already in use -- trying another.\n",
                       sep = "")
  }
  if (is.null(free))
    stop("Ports ", port, " through ", port + 9L, " are all in use. Close ",
         "whatever else is running, or set options(drsvyr.port = ...) to a ",
         "different range.", call. = FALSE)

  runApp(shinyApp(app_ui(), app_server), port = free, host = host,
        launch.browser = launch.browser)
}
