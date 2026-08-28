# setup.R for DrSvyR — install what the app needs. Run once: source("setup.R")

pkgs <- c(
  # app
  "shiny", "bslib", "markdown", "rstudioapi",
  # data
  "dplyr", "purrr", "tibble", "tidyr", "stringr", "readr",
  "forcats", "lubridate", "rlang", "glue", "haven",
  # design and models
  "survey", "lavaan", "clue", "matrixStats", "future", "furrr",
  # figures, tables, files
  "ggplot2", "viridis", "knitr",
  "fs", "here", "digest", "rappdirs", "yaml", "jsonlite", "base64enc",
  # optional: without it the analysis still runs, the prose does not
  "ellmer")

# officer, flextable and kableExtra are deliberately absent. Each needs Rtools
#   where the mirror carries no binary, which an analyst cannot install, and
#   the HTML report needs none of them.

new <- setdiff(pkgs, rownames(installed.packages()))
if (length(new)) install.packages(new) else message("Nothing to install.")
