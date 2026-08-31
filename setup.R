# setup.R for DrSvyR — install what the app needs. Run once: source("setup.R")
#
# Every package below is reached by name somewhere in R/ or app.R. The list is
#   checked against the code rather than maintained by hand, so a package that
#   stops being used comes off it.

pkgs <- c(
  # app
  "shiny", "bslib", "rstudioapi",
  #   markdown is not called by name anywhere. shiny::includeMarkdown() needs
  #   it at runtime to render the Start here tab, and its absence shows up as a
  #   blank first screen rather than an error, which is why it is named here.
  "markdown",
  # data
  "dplyr", "purrr", "tibble", "tidyr", "stringr", "readr",
  "forcats", "lubridate", "rlang", "haven", "janitor",
  # design and models
  #   lavaan is here for lavCor() alone: the weighted polychoric correlations
  #   behind the eigenvalue check that tells an analyst their battery looks
  #   like one continuum. No model in this app is fitted with it.
  "survey", "lavaan", "clue", "matrixStats", "future", "furrr",
  # figures and files
  "ggplot2", "viridis", "knitr",
  "fs", "here", "digest", "rappdirs", "yaml", "jsonlite", "base64enc",
  # optional: without it the analysis still runs, the prose does not
  "ellmer")

# Deliberately absent, each for a reason worth keeping written down.
#
#   officer, flextable, kableExtra
#     Each needs Rtools where the mirror carries no binary, which an analyst
#     cannot install. The Word export that used the first two has been removed
#     rather than kept as a second output to maintain: the HTML report opens in
#     Word directly and needs nothing beyond the list above.
#
#   glue
#     A stringr dependency, installed alongside it. Naming it here implies the
#     app calls it directly, and it does not.
#
#   usethis
#     Named in one error message as something for the analyst to run. The app
#     never calls it.

new <- setdiff(pkgs, rownames(installed.packages()))
if (length(new)) install.packages(new) else message("Nothing to install.")
