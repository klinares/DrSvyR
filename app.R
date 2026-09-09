# DrSvyR, as a Shiny app.

# This is the entrypoint. shiny::runApp(".") runs it, and Posit Connect
#   publishes it, because the last value it produces is a shiny.appobj.

# Branch shiny_drsvyr. On main this repository is an R package: R/ is evaluated
#   at build time, NAMESPACE declares the imports, and drsvyr::run_drsvyr()
#   launches it. That arrangement cannot be published to an internal Connect,
#   which has no way to install the package -- reaching GitHub is not available
#   and there is no internal repository hosting it. So this branch is the same
#   source, loaded the way the pre-package version loaded it: R/ sourced flat,
#   dependencies attached here.

# The one thing that costs is NAMESPACE. It was what made filter(), map() and
#   expand() resolve without anyone thinking about the search path. The library
#   block and the assertion below replace it, and the assertion is the half
#   that matters -- it makes a masked verb a startup failure rather than a
#   wrong table at stage 10.


# ---- 1. packages ------------------------------------------------------------

# Load order is not arbitrary. survey attaches Matrix, whose expand(), pack()
#   and unpack() mask tidyr's, so the tidyverse side is attached last and its
#   verbs win. Same rule as everywhere else in this project.
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

# The rest are called namespace-qualified throughout and are never attached.
#   Named here anyway: rsconnect discovers dependencies by walking source for
#   library() and pkg:: calls, and when a restore fails this is the list to
#   hand a repository administrator.
DRSVYR_PACKAGES <- c(
  "base64enc", "bslib", "digest", "dplyr", "fs", "furrr", "future",
  "ggplot2", "haven", "janitor", "jsonlite", "knitr", "markdown",
  "matrixStats", "purrr", "readr", "rlang", "shiny", "stringr", "survey",
  "tibble", "tidyr", "viridis", "yaml", "zip")

# ellmer and curl are deliberately optional. Everything except the AI Survey
#   Methodologist works without them, llm_require() already says so in words an
#   analyst can act on, and on some internal mirrors the available ellmer is
#   broken -- a hard requirement would turn a working deployment into a failed
#   one over a feature the analysis does not need.
DRSVYR_PACKAGES_OPTIONAL <- c("ellmer", "curl")

# Named, not counted. A failure inside the source loop below names a file and
#   not a package; this names the package.
local({
  have = function(p) requireNamespace(p, quietly = TRUE)
  missing = discard(DRSVYR_PACKAGES, have)
  if (length(missing))
    stop("These packages are not installed here, so the app cannot start:\n  ",
         paste(missing, collapse = ", "), call. = FALSE)

  absent = discard(DRSVYR_PACKAGES_OPTIONAL, have)
  if (length(absent))
    message("Optional and absent: ", paste(absent, collapse = ", "),
            ". The AI Survey Methodologist is off; everything else runs.")
})

# What NAMESPACE used to guarantee, asserted.
stopifnot(
  identical(filter, dplyr::filter),
  identical(select, dplyr::select),
  identical(count,  dplyr::count),
  identical(expand, tidyr::expand),
  identical(pack,   tidyr::pack),
  identical(unpack, tidyr::unpack),
  identical(map,    purrr::map))


# ---- 2. the source ----------------------------------------------------------

# Flat and alphabetical, which is safe only because no file in R/ has a
#   top-level statement other than an assignment. Keep it that way: a call left
#   at the top of a file in R/ is evaluated on every process start, in an order
#   nobody chose, possibly before the thing it depends on exists.
local({
  files = sort(list.files("R", pattern = "[.][Rr]$", full.names = TRUE))
  if (!length(files))
    stop("No R/ directory beside app.R.", call. = FALSE)
  walk(files, function(f) sys.source(f, envir = globalenv()))
})


# ---- 3. the app -------------------------------------------------------------

# drsvyr_app() maps the figures resource path, sets shiny.maxRequestSize and
#   future.globals.maxSize, and returns the object. app_file() in R/core.R is
#   the only function that knows the source is a directory rather than a
#   library.
drsvyr_app()
