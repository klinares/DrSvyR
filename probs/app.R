# DrSvyR deployment probe.

# A single-file Shiny app that exercises the parts of the DrSvyR workflow most
#   likely to behave differently on a server than on a laptop, and reports what
#   it found. Publish this before publishing the app.

# Deliberately standalone: it does not source R/ and shares no code with the
#   application. A failure here is unambiguous, which is the whole point. It
#   attaches the same packages the app does, so its manifest is the app's
#   manifest and a restore failure reproduces exactly.

#   rsconnect::deployApp("probe", appName = "drsvyr-probe")

# Every check is wrapped. A diagnostic tool that dies on its first failure
#   tells you one thing per deployment cycle; this one tells you all of them.

library(shiny)
library(bslib)
library(survey)
library(ggplot2)
library(purrr)
library(dplyr)

APP_PACKAGES <- c(
  "base64enc", "bslib", "digest", "dplyr", "fs", "furrr", "future",
  "ggplot2", "haven", "janitor", "jsonlite", "knitr", "markdown",
  "matrixStats", "purrr", "readr", "rlang", "shiny", "stringr", "survey",
  "tibble", "tidyr", "viridis", "yaml", "zip")

OPTIONAL <- c("ellmer", "curl")

# Environment variables the app reads. Named here so the probe reports on
#   exactly what the app will look for, and an unset one shows as unset rather
#   than as a default nobody chose.
APP_ENV <- c("DRSVYR_DEPLOY", "DRSVYR_CLASSIFICATION", "DRSVYR_WORKERS",
             "DRSVYR_LLM_BASE_URL", "DRSVYR_LLM_KEY_VAR",
             "DRSVYR_LLM_KEY_SOURCE", "DRSVYR_LLM_PM", "DRSVYR_LLM_WORKER",
             "DRSVYR_LLM_PM_FALLBACK")


`%||%` <- function(x, y) if (is.null(x)) y else x


# ---- reporting ---------------------------------------------------------------

# One row per check: a verdict, a label, and whatever the check learned.
#   try_check() is what keeps a failure local -- it records the condition
#   message as the detail and moves on.
try_check <- function(label, expr) {
  t0 = Sys.time()
  out = tryCatch(list(ok = TRUE, detail = force(expr)),
                 error = function(e) list(ok = FALSE,
                                          detail = conditionMessage(e)),
                 warning = function(w) list(ok = NA,
                                            detail = conditionMessage(w)))
  tibble::tibble(check = label,
                 result = if (isTRUE(out$ok)) "PASS"
                          else if (is.na(out$ok)) "WARN" else "FAIL",
                 detail = paste(as.character(out$detail), collapse = " "),
                 secs = round(as.numeric(difftime(Sys.time(), t0,
                                                  units = "secs")), 2))
}

verdict_html <- function(df) {
  colour = c(PASS = "#1a7f37", WARN = "#9a6700", FAIL = "#b40404")
  rows = pmap_chr(df, function(check, result, detail, secs)
    paste0("<tr><td style='padding:4px 10px;font-weight:600;color:",
           colour[[result]], "'>", result,
           "</td><td style='padding:4px 10px'>", htmltools::htmlEscape(check),
           "</td><td style='padding:4px 10px;font-family:monospace;",
           "font-size:12px'>", htmltools::htmlEscape(detail),
           "</td><td style='padding:4px 10px;color:#666'>", secs, "s</td></tr>"))
  HTML(paste0("<table style='border-collapse:collapse;width:100%;",
              "font-size:13px'>", paste(rows, collapse = ""), "</table>"))
}


# ---- the checks --------------------------------------------------------------

# 1. What restored, and at what version. This is the answer to the question the
#    restore failures have been asking: the mirror served SOMETHING, and this
#    says what.
check_packages <- function() {
  ver = function(p) tryCatch(as.character(utils::packageVersion(p)),
                             error = function(e) NA_character_)
  map_dfr(c(APP_PACKAGES, OPTIONAL), function(p) {
    v = ver(p)
    tibble::tibble(
      check = p,
      result = if (!is.na(v)) "PASS" else if (p %in% OPTIONAL) "WARN" else "FAIL",
      detail = if (!is.na(v)) v else "not installed",
      secs = 0)
  })
}

# 2. Where the process is standing and what it thinks it has. availableCores()
#    reads a container's CPU quota where there is one, so this is the number
#    the app's worker cap is computed from.
check_environment <- function(session) {
  list(
    try_check("R version", R.version.string),
    try_check("Platform", R.version$platform),
    try_check("Working directory", getwd()),
    try_check("tempdir()", tempdir()),
    try_check("future::availableCores()",
              as.character(future::availableCores())),
    try_check("Connect user (session$user)",
              session$user %||% "NULL -- not behind Connect auth"),
    try_check("Memory limit reported by R",
              tryCatch(format(as.numeric(unlist(strsplit(
                system("cat /sys/fs/cgroup/memory.max", intern = TRUE), " "))[1])
                / 1024^3, digits = 3),
                error = function(e) "cgroup v2 file not readable")))
}

# 3. Environment variables. Values are shown, not just presence, EXCEPT for
#    anything whose name suggests a key -- a probe that prints a credential to
#    a browser is a probe that has created the problem it was checking for.
check_env_vars <- function() {
  map_dfr(APP_ENV, function(v) {
    val = Sys.getenv(v, "")
    secret = grepl("KEY$|TOKEN|SECRET", v)
    tibble::tibble(
      check = v,
      result = if (nzchar(val)) "PASS" else "WARN",
      detail = if (!nzchar(val)) "unset"
               else if (secret) paste0("set (", nchar(val), " chars, hidden)")
               else val,
      secs = 0)
  })
}

# 4. The filesystem the app actually uses. open_session_folder() writes under
#    tempfile(); this is the same shape, plus the zip that the Outputs screen
#    hands the analyst. All three have to work or the workflow has no exit.
check_filesystem <- function() {
  d = tempfile("drsvyr_probe_")
  list(
    try_check("Create per-session folder under tempdir()", {
      dir.create(file.path(d, "output"), recursive = TRUE); d }),
    try_check("Write a file into it", {
      writeLines(c("a,b", "1,2"), file.path(d, "output", "t.csv"))
      paste(file.size(file.path(d, "output", "t.csv")), "bytes") }),
    try_check("Read it back",
              paste(readLines(file.path(d, "output", "t.csv")), collapse = " | ")),
    try_check("Build a zip (zip::zip, as the Outputs screen does)", {
      z = tempfile(fileext = ".zip")
      zip::zip(z, files = "output/t.csv", root = d, mode = "cherry-pick")
      paste(file.size(z), "bytes") }),
    try_check("Delete the folder", {
      unlink(d, recursive = TRUE)
      if (dir.exists(d)) stop("still present") else "removed" }))
}

# 5. The demonstration survey. The app finds it at inst/extdata via a getwd()
#    fallback. .gitignore excludes *.sav and re-admits that folder by negation,
#    and that negation has failed silently before -- a bundle without the file
#    starts fine and offers no demo, which nobody notices until an analyst
#    without data of their own opens it.
check_data <- function() {
  cand = c("extdata", "inst/extdata", "../inst/extdata")
  found = unlist(map(cand, function(p)
    if (dir.exists(p)) list.files(p, pattern = "[.](sav|zsav|dta)$",
                                  full.names = TRUE) else character(0)))
  if (!length(found))
    return(list(tibble::tibble(
      check = "Demonstration survey present", result = "WARN",
      detail = paste("no .sav or .dta under", paste(cand, collapse = ", ")),
      secs = 0)))
  f = found[[1]]
  list(
    try_check("Demonstration survey present", f),
    try_check("haven can read it", {
      d = if (grepl("[.]dta$", f)) haven::read_dta(f) else haven::read_sav(f)
      paste(nrow(d), "rows,", ncol(d), "columns") }))
}

# 6. The estimation chain, on synthetic data so it runs whether or not the
#    survey file shipped. This is the real test of survey plus Matrix plus
#    survival: a stratified clustered design, a JKn replicate design, and a
#    replicate-weighted mean with its standard error. If the mirror served a
#    broken or mismatched Matrix, it fails here rather than in the app.
check_survey <- function() {
  # An environment rather than <<-, so the design objects the second and third
  #   checks need are passed between them explicitly. <<- would have walked out
  #   to the global environment, which on a server is shared by every session
  #   in the process.
  st = new.env(parent = emptyenv())
  set.seed(1)
  n_str = 8; n_psu = 6; n_per = 25
  d = expand.grid(str = seq_len(n_str), psu = seq_len(n_psu),
                  i = seq_len(n_per)) |>
    mutate(psu_id = paste(str, psu, sep = "_"),
           w = runif(n(), 0.5, 2.5),
           y = rbinom(n(), 1, 0.4))
  list(
    try_check("svydesign() on a stratified clustered frame", {
      st$des = svydesign(ids = ~psu_id, strata = ~str, weights = ~w,
                        data = d, nest = TRUE)
      paste(nrow(d), "rows,", n_str, "strata,", n_str * n_psu, "PSUs") }),
    try_check("as.svrepdesign(type = 'JKn')", {
      st$rep_des = as.svrepdesign(st$des, type = "JKn")
      paste(ncol(st$rep_des$repweights), "replicate weights,",
            "df =", survey::degf(st$rep_des)) }),
    try_check("svymean() on the replicate design", {
      m = svymean(~y, st$rep_des)
      paste0("mean = ", round(coef(m), 4),
             ", SE = ", round(survey::SE(m), 4)) }))
}

# 7. Parallelism. multisession starts real R processes, and a container that
#    forbids it, or one whose memory ceiling cannot hold three copies of the
#    session, fails here. This is the check most likely to surprise: it always
#    works on a laptop.
check_parallel <- function() {
  w = suppressWarnings(as.integer(Sys.getenv("DRSVYR_WORKERS", "2")))
  if (is.na(w) || w < 1) w = 2L
  list(
    try_check(paste0("future::plan(multisession, workers = ", w, ")"), {
      future::plan(future::multisession, workers = w)
      paste(future::nbrOfWorkers(), "workers started") }),
    try_check("furrr::future_map() across the workers", {
      pids = furrr::future_map(1:4, function(i) Sys.getpid(),
                               .options = furrr::furrr_options(seed = NULL))
      paste(length(unique(unlist(pids))), "distinct process ids") }),
    try_check("Shut the workers down", {
      future::plan(future::sequential); "sequential" }))
}

# 8. Graphics. A headless container without the right fonts renders but with
#    substitutions, and a container without a working device does not render
#    at all. Either way it is better known here than on the Items screen.
check_graphics <- function() {
  list(
    try_check("Render a ggplot to PNG", {
      p = ggplot(data.frame(x = 1:10, y = (1:10)^2), aes(x, y)) +
        geom_col(fill = viridis::viridis(1)) + theme_minimal()
      f = tempfile(fileext = ".png")
      ggsave(f, p, width = 4, height = 3, dpi = 96)
      paste(file.size(f), "bytes") }),
    try_check("base64 encode it (as the report does)", {
      f = tempfile(fileext = ".png")
      ggsave(f, ggplot(data.frame(x = 1), aes(x, x)) + geom_point(),
             width = 2, height = 2, dpi = 72)
      paste(nchar(base64enc::base64encode(f)), "characters") }))
}


# ---- app ---------------------------------------------------------------------

ui <- page_fluid(
  theme = bs_theme(version = 5, preset = "flatly"),
  title = "DrSvyR deployment probe",

  tags$h3("DrSvyR deployment probe"),
  tags$p(class = "text-muted",
         "Exercises the parts of the workflow most likely to behave ",
         "differently on a server. Nothing here shares code with the app, so ",
         "a failure below is about the environment, not about DrSvyR."),
  tags$hr(),

  navset_tab(
    nav_panel("Summary",     uiOutput("summary")),
    nav_panel("Packages",    uiOutput("packages")),
    nav_panel("Environment", uiOutput("environment")),
    nav_panel("Settings",    uiOutput("envvars")),
    nav_panel("Filesystem",  uiOutput("filesystem")),
    nav_panel("Data",        uiOutput("data")),
    nav_panel("Estimation",  uiOutput("survey")),
    nav_panel("Parallel",    uiOutput("parallel")),
    nav_panel("Graphics",    uiOutput("graphics"))),

  tags$hr(),
  downloadButton("download", "Download the full report as CSV"))

server <- function(input, output, session) {

  # Run once per session and cache. Several of these take a second or two and
  #   re-running them on every tab switch would make the probe itself look
  #   like a performance problem.
  results <- reactive({
    list(
      packages    = check_packages(),
      environment = bind_rows(check_environment(session)),
      envvars     = check_env_vars(),
      filesystem  = bind_rows(check_filesystem()),
      data        = bind_rows(check_data()),
      survey      = bind_rows(check_survey()),
      parallel    = bind_rows(check_parallel()),
      graphics    = bind_rows(check_graphics()))
  })

  output$summary <- renderUI({
    r <- results()
    all <- bind_rows(imap(r, function(df, nm) mutate(df, section = nm)))
    n <- table(factor(all$result, levels = c("PASS", "WARN", "FAIL")))
    tagList(
      tags$h4(sprintf("%d pass, %d warn, %d fail", n[["PASS"]], n[["WARN"]],
                      n[["FAIL"]])),
      if (n[["FAIL"]] > 0)
        tagList(tags$p(tags$strong("Failures:")),
                verdict_html(filter(all, result == "FAIL")))
      else tags$p(class = "text-success",
                  "Nothing failed. The environment supports the workflow."),
      if (n[["WARN"]] > 0)
        tagList(tags$hr(), tags$p(tags$strong("Warnings:")),
                verdict_html(filter(all, result == "WARN"))))
  })

  walk(c("packages", "environment", "envvars", "filesystem", "data",
         "survey", "parallel", "graphics"), function(nm)
    output[[nm]] <- renderUI(verdict_html(results()[[nm]])))

  output$download <- downloadHandler(
    filename = function()
      paste0("drsvyr-probe-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".csv"),
    content = function(file) {
      r <- results()
      readr::write_csv(
        bind_rows(imap(r, function(df, nm) mutate(df, section = nm))) |>
          select(section, check, result, detail, secs),
        file)
    })
}

shinyApp(ui, server)
