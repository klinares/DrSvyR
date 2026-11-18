# chaRt probe -- a one-page Shiny app to publish once at work, to learn what the server can do.
#   Run:     shiny::runApp("chaRt/probe")
#   Publish: rsconnect::deployApp("chaRt/probe", appName = "chaRt-probe")
# No model calls and no key. Every check is wrapped in tryCatch, so one failure does not hide the
#   others, and its answer is "yes", "no" or the error text. The table is repeated as plain text
#   under "Copy results", to be typed back at home. Needs only shiny, so it starts on a bare server;
#   that is why it uses base lapply() and vapply() rather than purrr (still no loops).

library(shiny)

APP_CLASSIFICATION <- "UNCLASSIFIED"

# The packages chaRt will need, reported with their versions.
PROBE_PACKAGES <- c("plotly", "shinychat", "yaml", "quarto", "ragg", "htmltools")

# The three-line document rendered from inside the running app (plus the YAML fences).
PROBE_QMD <- c("---",
               "title: chaRt probe",
               "format: {html: {embed-resources: true}}",
               "---",
               "Quarto rendered this page from inside a running Shiny app.")

options(bitmapType = "cairo")


# ---- the checks ----------------------------------------------------------------------------

# One check: its answer as text, or the error (or warning) it met.
probe <- function(expr)
  tryCatch(expr, warning = function(w) paste("warning:", conditionMessage(w)),
           error = function(e) paste("error:", conditionMessage(e)))

pkg_version <- function(p)
  if (requireNamespace(p, quietly = TRUE)) paste("yes,", as.character(utils::packageVersion(p))) else "no"

# Where Quarto is. The quarto R package was not installed where this probe was written, so the
#   name of its path function could not be confirmed there: quarto_path() is used only if the
#   installed package exports that name, and the route taken is reported. Otherwise QUARTO_PATH,
#   then the PATH.
quarto_bin <- function() {
  from_pkg = if (requireNamespace("quarto", quietly = TRUE) && "quarto_path" %in% getNamespaceExports("quarto"))
    tryCatch(getExportedValue("quarto", "quarto_path")(), error = function(e) NULL)
  env = Sys.getenv("QUARTO_PATH")
  path = Sys.which("quarto")
  if (length(from_pkg) && nzchar(from_pkg)) list(path = unname(from_pkg), how = "quarto::quarto_path()")
  else if (nzchar(env) && file.exists(env)) list(path = env, how = "QUARTO_PATH")
  else if (nzchar(path)) list(path = unname(path), how = "the PATH")
  else NULL
}

quarto_found <- function() {
  q = quarto_bin()
  if (is.null(q)) return("no (not from the quarto package, QUARTO_PATH or the PATH)")
  paste0("yes, ", q$path, " (found through ", q$how, ")")
}

quarto_version <- function() {
  q = quarto_bin()
  if (is.null(q)) return("no (Quarto not found)")
  out = suppressWarnings(system2(q$path, "--version", stdout = TRUE, stderr = TRUE))
  paste(out, collapse = " ")
}

# Renders PROBE_QMD in a fresh folder under tempdir() with the Quarto command line, and says
#   whether the HTML came out self-contained (no side folder of files) and how long it took.
quarto_render <- function() {
  q = quarto_bin()
  if (is.null(q)) return("no (Quarto not found)")
  dir = tempfile("probe_qmd_")
  dir.create(dir)
  qmd = file.path(dir, "probe.qmd")
  writeLines(PROBE_QMD, qmd)
  started = Sys.time()
  # A failed command also raises a warning; its output says more, so the warning is not kept.
  out = suppressWarnings(system2(q$path, c("render", shQuote(qmd), "--to", "html", "--quiet"),
                                 stdout = TRUE, stderr = TRUE))
  secs = as.numeric(difftime(Sys.time(), started, units = "secs"))
  status = if (is.null(attr(out, "status"))) 0L else attr(out, "status")
  html = file.path(dir, "probe.html")
  if (status != 0L || !file.exists(html))
    return(paste0("no, after ", sprintf("%.1f", secs), " s (exit status ", status, "): ",
                  substr(paste(out, collapse = " "), 1, 400)))
  side = dir.exists(file.path(dir, "probe_files"))
  paste0("yes, in ", sprintf("%.1f", secs), " s; ", round(file.size(html) / 1024), " KB; ",
         if (side) "NOT self-contained (a probe_files folder was written)" else "self-contained")
}

cairo_png <- function() {
  f = tempfile(fileext = ".png")
  grDevices::png(f, width = 400, height = 300, type = "cairo")
  graphics::plot(1:10, main = "chaRt probe")
  grDevices::dev.off()
  if (file.exists(f) && file.size(f) > 0)
    paste0("yes, ", round(file.size(f) / 1024, 1), " KB (capabilities('cairo') is ", capabilities("cairo"), ")")
  else "no (no file was written)"
}

tempdir_writable <- function() {
  f = tempfile("probe_write_")
  writeLines("chaRt probe", f)
  back = readLines(f)
  unlink(f)
  if (identical(back, "chaRt probe")) paste("yes,", tempdir()) else "no (what was read back differs)"
}

# Every check, in the order the table shows them.
run_checks <- function() {
  rows = c(
    list(list("R version", function() R.version.string),
         list("shiny", function() pkg_version("shiny")),
         list("ellmer", function() pkg_version("ellmer"))),
    lapply(PROBE_PACKAGES, function(p) list(p, function() pkg_version(p))),
    list(list("Quarto found", quarto_found),
         list("Quarto version", quarto_version),
         list("A .qmd renders to self-contained HTML from the app", quarto_render),
         list("A PNG draws with type = \"cairo\"", cairo_png),
         list("tempdir() is writable", tempdir_writable)))
  data.frame(Check = vapply(rows, function(r) r[[1]], character(1)),
             Result = vapply(rows, function(r) as.character(probe(r[[2]]()))[1], character(1)))
}

as_text <- function(tab)
  paste(c(paste("chaRt probe,", format(Sys.time(), "%Y-%m-%d %H:%M %Z")),
          paste0(tab$Check, ": ", tab$Result)), collapse = "\n")


# ---- the page ---------------------------------------------------------------------------

ui <- fluidPage(
  title = "chaRt probe",
  tags$div(
    style = paste("background:#b40404; color:#fff; text-align:center;",
                  "font-weight:700; letter-spacing:0.06em;",
                  "padding:5px 0; font-size:13px;"),
    APP_CLASSIFICATION),
  tags$h2("chaRt probe"),
  tags$p("What this server can do for chaRt. Nothing is sent anywhere; no key is needed."),
  tableOutput("checks"),
  tags$h4("Copy results"),
  tags$p("The same table as plain text, to copy or type back at home."),
  uiOutput("copy"))

server <- function(input, output, session) {
  checks <- reactive(withProgress(message = "Running the checks", value = 0.5, run_checks()))
  output$checks <- renderTable(checks(), striped = TRUE, bordered = TRUE)
  output$copy <- renderUI(
    textAreaInput("copy_text", NULL, value = as_text(checks()), width = "100%", rows = nrow(checks()) + 3))
}

shinyApp(ui, server)
