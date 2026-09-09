# DrSvyR, as a Shiny app.
# shiny::runApp(".") runs it. rsconnect::deployApp(".") publishes it.

# ---- 1. packages ------------------------------------------------------------

# Load order matters: survey attaches Matrix, whose expand(), pack() and
#   unpack() mask tidyr's, so the tidyverse side is attached last.
library(shiny)
library(bslib)
library(survey)
library(haven)
library(ggplot2)
library(purrr)
library(stringr)
library(tibble)
library(tidyr)
library(dplyr)

# Called namespace-qualified in R/ and never attached. Named so a missing one
#   is a startup error naming the package, and so there is a list to hand a
#   repository administrator when a deployment will not restore.
APP_PACKAGES <- c(
  "base64enc", "bslib", "digest", "dplyr", "fs", "furrr", "future",
  "ggplot2", "haven", "janitor", "jsonlite", "knitr", "markdown",
  "matrixStats", "purrr", "readr", "rlang", "shiny", "stringr", "survey",
  "tibble", "tidyr", "viridis", "yaml", "zip")

local({
  have = function(p) requireNamespace(p, quietly = TRUE)
  missing = discard(APP_PACKAGES, have)
  if (length(missing))
    stop("Not installed, so the app cannot start:\n  ",
         paste(missing, collapse = ", "), call. = FALSE)
  
  # ellmer and curl are optional. Without them the AI Survey Methodologist is
  #   off and every number is unaffected.
  absent = discard(c("ellmer", "curl"), have)
  if (length(absent))
    message("Optional and absent: ", paste(absent, collapse = ", "))
})

# What NAMESPACE used to guarantee. A masked verb becomes a startup failure
#   rather than a wrong table at stage 10.
stopifnot(
  identical(filter, dplyr::filter),
  identical(select, dplyr::select),
  identical(count,  dplyr::count),
  identical(expand, tidyr::expand),
  identical(pack,   tidyr::pack),
  identical(unpack, tidyr::unpack),
  identical(map,    purrr::map))


# ---- 2. the source ----------------------------------------------------------

# R/ holds function definitions only, so alphabetical order is safe. Keep it
#   that way: a top-level call there runs on every process start.
local({
  files = sort(list.files("R", pattern = "[.][Rr]$", full.names = TRUE))
  if (!length(files))
    stop("No R/ beside app.R. Run this from the repository root.",
         call. = FALSE)
  
  # globals.R is package-only: utils::globalVariables() errors outside a
  #   package, naming neither the file nor the reason.
  files = discard(files, function(f) basename(f) == "globals.R")
  
  # Named on failure. sys.source() otherwise raises whatever the file raised
  #   without saying which file that was.
  walk(files, function(f)
    tryCatch(sys.source(f, envir = globalenv()),
             error = function(e)
               stop("Failed loading ", f, ":\n  ", conditionMessage(e),
                    call. = FALSE)))
})

stopifnot(exists("app_ui", mode = "function"),
          exists("app_server", mode = "function"),
          exists("app_file", mode = "function"))


# ---- 3. process settings ----------------------------------------------------

# Shiny serves static files only from resource paths it is told about, so a
#   figure referenced as figures/... from help.md would 404 without this.
local({
  figs = app_file("figures")
  if (!fs::dir_exists(figs))
    stop("Help figures missing: ", figs, call. = FALSE)
  addResourcePath("figures", figs)
})

# Shiny's default upload ceiling is 5 MB, which any real survey file clears.
#   150 MB rather than more: haven expands a .sav to two to four times its
#   size on disk, and the raw file, codebook and design frame coexist.
# future's default globals ceiling is 500 MB, which the item matrix clears on
#   a large survey; the error when it does names a byte count and no variable.
options(
  shiny.maxRequestSize   = getOption("drsvyr.max_upload", 150 * 1024^2),
  future.globals.maxSize = getOption("drsvyr.globals_max", 1024^3))


# ---- 4. the app -------------------------------------------------------------

ui <- app_ui()

server <- app_server

shinyApp(ui, server)