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
  "ggplot2", "viridis", "knitr", "kableExtra",
  "fs", "here", "digest", "rappdirs", "yaml", "jsonlite", "base64enc",
  # optional: ellmer for the model, officer + flextable for Word output
  "ellmer", "officer", "flextable")

new <- setdiff(pkgs, rownames(installed.packages()))
if (length(new)) install.packages(new) else message("Nothing to install.")