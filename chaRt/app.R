# chaRt -- Shiny app, one of the apps in the DrSvyR repository.
#   Run:     shiny::runApp("chaRt")   (or Run App in RStudio, this file open)
#   Publish: rsconnect::deployApp("chaRt", appName = "chaRt")

# A plain Shiny app directory: this file (settings, layout, server), R/ (function definitions
#   only, sourced below) and www/ (served by Shiny: logo/). README.md says how to set it up.
#   DESIGN.md is the whole design; this is Phase 0, the skeleton.


# ---- 1. settings an administrator may change -------------------------------

# The marking shown above every screen.
APP_CLASSIFICATION <- "UNCLASSIFIED"

# The office logo, a file in www/logo/ (a dashed box until it is there), and an optional name.
APP_LOGO <- "office_logo.png"
APP_OFFICE <- ""

# Largest data file the Data page accepts, in megabytes.
APP_MAX_UPLOAD_MB <- 50

# Where the "Source code" button in the header links to. At work, point it at the internal copy.
APP_SOURCE_URL <- "https://github.com/klinares/drsvyr/tree/main/chaRt"

# The profile used when the environment variable CHART_PROFILE is not set: "home" or "work".
APP_DEFAULT_PROFILE <- "home"

# The model per profile. It uses the key pasted into the box on Start here and held for the
#   session; the environment is never read for it.
#     api              "anthropic" or "openai" (the OpenAI style)
#     base_url, id     where it is called and what the endpoint names it
#     reasoning_effort optional, "low", "medium" or "high"; sent only when set
#     max_tokens_name  optional, openai style only: "max_tokens" for an endpoint that wants
#                      the older name for the reply limit (ellmer sends max_completion_tokens)
#   work: placeholders in angle brackets, to be filled in at work (see README.md).
APP_PROFILES <- list(
  home = list(api = "anthropic", base_url = "https://api.anthropic.com/v1", id = "claude-sonnet-5-5"),
  work = list(api = "openai", base_url = "<work base url>", id = "<model id at work>"))

APP_PROFILE <- local({
  p = tolower(trimws(Sys.getenv("CHART_PROFILE")))
  if (nzchar(p)) p else APP_DEFAULT_PROFILE
})
if (!APP_PROFILE %in% names(APP_PROFILES))
  stop("The profile is '", APP_PROFILE, "' (CHART_PROFILE, or APP_DEFAULT_PROFILE when that is not set); ",
       "it must be one of: ", paste(names(APP_PROFILES), collapse = ", "), call. = FALSE)
APP_MODEL <- APP_PROFILES[[APP_PROFILE]]


# ---- 2. packages ------------------------------------------------------------

library(shiny)
library(bslib)
library(purrr)

# Called as pkg::fn() in R/ and never attached; listed so a missing one stops the app here, by name.
APP_PACKAGES <- c("commonmark", "digest", "dplyr", "ellmer", "ggiraph", "ggplot2", "htmltools", "httr2", "jsonlite", "readr", "rlang", "S7", "scales",
                  "shinychat", "tibble", "tidyr", "yaml", "zip")

# tidyr is used only by name (R/spec.R takes the exports of SPEC_PACKAGES), so a deployment, which finds the packages to install by reading the
#   calls in the code, would not ask for it: plotly used to bring it in as a dependency. This call is what it reads (Phase 10 Part B, found by 9C-8).
requireNamespace("tidyr", quietly = TRUE)

# hexbin is optional: R/spec.R draws a crowded scatter as hexagons (ggplot2's geom_hex()) when density_hex_ok() finds the package, and as rectangles when it
#   does not, so it is not in APP_PACKAGES and its absence stops nothing. R/ finds it with find.package() (R/ may not call requireNamespace()), which a
#   deployment does not read; this call is what it reads, so Connect installs hexbin when it is installed here (Phase 10b hexagons, found by 9C-8).
requireNamespace("hexbin", quietly = TRUE)

local({
  missing = discard(APP_PACKAGES, requireNamespace, quietly = TRUE)
  if (length(missing)) stop("Not installed, so the app cannot start: ", paste(missing, collapse = ", "), call. = FALSE)
})

# The ellmer functions and arguments R/llm.R calls, checked here so a different ellmer stops the
#   app with a plain message, not in the middle of a call. Built and tested with ellmer 0.4.2.
local({
  calls = list(chat_anthropic = c("system_prompt", "params", "model", "cache", "base_url", "credentials", "echo"),
               chat_openai_compatible = c("base_url", "name", "system_prompt", "credentials", "model", "params",
                                          "api_args", "echo"),
               params = c("temperature", "max_tokens", "reasoning_effort"))
  gone = unlist(imap(calls, function(args, fn) {
    if (!fn %in% getNamespaceExports("ellmer")) return(fn)
    absent = setdiff(args, names(formals(getExportedValue("ellmer", fn))))
    if (length(absent)) paste0(fn, "(", paste(absent, collapse = ", "), ")")
  }))
  if (length(gone))
    stop("The installed ellmer (", as.character(packageVersion("ellmer")), ") has no ",
         paste(gone, collapse = "; "), ". chaRt needs ellmer 0.4.2 or a later version that has them: ",
         "install it with install.packages(\"ellmer\") and start the app again.", call. = FALSE)
})

# The ggiraph functions and arguments R/spec.R calls for the interactive version of a chart (and the twins of the layers it swaps in),
#   checked the same way. Built and tested with ggiraph 0.9.7 (the arguments are those of its help pages).
local({
  calls = list(girafe = c("ggobj", "width_svg", "height_svg", "options", "font_set"), girafe_css = c("css", "text", "point", "line"),
               opts_sizing = c("rescale", "width"), opts_toolbar = c("saveaspng", "hidden"), opts_zoom = c("min", "max"),
               opts_selection = "type", opts_hover = "css", opts_hover_inv = "css",
               opts_tooltip = c("css", "opacity", "offx", "offy", "use_fill", "use_stroke"),
               geom_col_interactive = character(0), geom_point_interactive = character(0), geom_line_interactive = character(0),
               geom_histogram_interactive = character(0), geom_boxplot_interactive = character(0), geom_tile_interactive = character(0),
               geom_bin_2d_interactive = character(0), geom_hex_interactive = character(0), girafeOutput = c("outputId", "width"), renderGirafe = "expr")
  gone = unlist(imap(calls, function(args, fn) {
    if (!fn %in% getNamespaceExports("ggiraph")) return(fn)
    absent = setdiff(args, names(formals(getExportedValue("ggiraph", fn))))
    if (length(absent)) paste0(fn, "(", paste(absent, collapse = ", "), ")")
  }))
  if (length(gone))
    stop("The installed ggiraph (", as.character(packageVersion("ggiraph")), ") has no ", paste(gone, collapse = "; "),
         ". chaRt needs ggiraph 0.9.7 or a later version that has them: install it with install.packages(\"ggiraph\") and start the app again.",
         call. = FALSE)
})

# The verbs R/ relies on, checked to be the ones meant: a masked verb fails here.
stopifnot(identical(map, purrr::map), identical(keep, purrr::keep), identical(discard, purrr::discard),
          identical(walk, purrr::walk))


# ---- 3. the code in R/ ------------------------------------------------------

# Every file there defines functions and constants and nothing else, so the order is safe.
walk(sort(list.files("R", pattern = "[.]R$", full.names = TRUE)), function(f)
  tryCatch(sys.source(f, envir = globalenv()),
           error = function(e) stop("Failed loading ", f, ": ", conditionMessage(e), call. = FALSE)))

# runApp() evaluates this file in an environment of its own, so the settings R/ reads are put
#   in the global environment, where R/ lives.
list2env(list(APP_CLASSIFICATION = APP_CLASSIFICATION, APP_PROFILE = APP_PROFILE, APP_PROFILES = APP_PROFILES,
              APP_MODEL = APP_MODEL, APP_MAX_UPLOAD_MB = APP_MAX_UPLOAD_MB),
         envir = globalenv())

# Every reflex file in www/reflexes/ parsed now, so one that has lost its shape stops the app here,
#   naming the file and the reflex, not in the middle of a call.
check_reflex_files()

# www/methodology.md read for its table of question templates (Methodology page, and the questions on Explore), so a file that
#   has lost the table stops the app here, naming the file.
check_methodology_file()

# The three bundled typefaces in www/fonts/ (Inter, Source Serif 4 and Barlow Condensed), registered with systemfonts so that charts are
#   drawn in them whatever the server has installed. Missing files or no systemfonts: the app starts, charts
#   are drawn in the default fonts, and Start here says so once (chart_fonts_missing()).
chart_fonts_register()


# ---- 4. process settings ----------------------------------------------------

# Cairo for every PNG a stray call opens (a Linux server with no display has no X11), and ragg for shiny's own plots, when
#   R and shiny have them: chart_device_options() in R/theme.R. Charts themselves are drawn by chart_device(), the one
#   way a device is opened (R/theme.R); Start here says which device is in use.
chart_device_options()

# The small pictures on the Methodology page, drawn now and once (R/ui.R): not per session, and not from any file of the
#   analyst's. A server that cannot draw gets a page without them.
method_thumbs()

# The largest upload, in bytes.
options(shiny.maxRequestSize = APP_MAX_UPLOAD_MB * 1024^2)


# ---- 5. state ---------------------------------------------------------------

# The state the modules share: key_version, which changes whenever the pasted key
#   is saved or forgotten, so anything that depends on a key can re-run; the data as read, the
#   sentences about it (problems), its profile, the data dictionary the analyst edits (codebook) and the
#   path of the upload (for the code a chart comes with); the record of every model call (calls); every
#   chart drawn this session, by id (charts), and the ids of those on the canvas, newest first (canvas), where a summary table is a card
#   too (its id is in canvas and its definition, by id, in tables; the chat sees only the charts);
#   the headline and summary written for a chart, by id (stories); the three palettes; and ask_request, a question that
#   Methodology's "Ask this" button hands to Explore.
new_state <- function() reactiveValues(key_version = 0L, data = NULL, problems = NULL, profile = NULL, codebook = NULL,
                                       path = NULL, calls = NULL, charts = list(), canvas = character(0), stories = list(),
                                       tables = list(), palette = chart_palette_default(), ask_request = NULL)


# ---- 6. layout --------------------------------------------------------------

# The banner, then the navbar page: Start here, Data, Explore, Methodology (R/ui.R).
ui <- app_ui(APP_CLASSIFICATION, APP_LOGO, APP_OFFICE, APP_SOURCE_URL)


# ---- 7. server --------------------------------------------------------------

server <- function(input, output, session) {
  state <- new_state()
  mod_key_server("key", state)
  mod_connect_server("connect", state)
  mod_data_server("data", state)
  mod_codebook_server("codebook", state)
  mod_summary_server("summary", state)
  mod_explore_server("explore", state)
  mod_method_server("method", state)
}


shinyApp(ui, server)
