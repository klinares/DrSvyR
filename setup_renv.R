# setup_renv.R for WISE repo
# Capture the environment, then prove it can be restored.

# Run from the repository root. A lockfile that has never been restored on a
#   second machine is a claim, not a guarantee, so the second half of this
#   checks the claim rather than trusting renv's dependency scan.

# renv::dependencies() finds packages from library() and :: calls in the
#   source. That misses nothing here, but it also cannot know which version an
#   analyst will end up with, which is what the lockfile is for.

# ---- 1. Initialise or update ------------------------------------------------

if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")

if (!file.exists("renv.lock")) {
  renv::init(bare = FALSE)
} else {
  renv::snapshot(prompt = FALSE)
}


# ---- 2. Check nothing was missed --------------------------------------------

# Everything the app attaches or namespaces, listed explicitly. renv's scan
#   should find all of these; the point of naming them is that a package used
#   only inside a string or a do.call would be invisible to the scan and
#   visible here.
WISE_PACKAGES <- c(
  # app
  "shiny", "bslib", "htmltools",
  # data
  "tidyverse", "dplyr", "tidyr", "purrr", "tibble", "stringr", "readr",
  "rlang", "glue", "haven", "janitor",
  # design and models
  "survey", "lavaan", "clue", "matrixStats", "MASS",
  # parallel
  "future", "furrr",
  # plots and tables
  "ggplot2", "viridis", "knitr", "kableExtra", "officer", "flextable",
  # infrastructure
  "fs", "digest", "rappdirs", "yaml", "jsonlite", "ellmer", "usethis"
)

lock <- jsonlite::fromJSON("renv.lock")
locked <- names(lock$Packages)
missing <- setdiff(WISE_PACKAGES, locked)

cat("\nPackages in the lockfile:", length(locked), "\n")
cat("Named here but not locked:",
    if (length(missing)) paste(missing, collapse = ", ") else "none", "\n")

if (length(missing)) {
  cat("\nInstall them and snapshot again:\n",
      "  install.packages(c(", paste0('"', missing, '"', collapse = ", "),
      "))\n  renv::snapshot()\n", sep = "")
}


# ---- 3. Record what the lockfile cannot ------------------------------------

# renv pins packages. It does not pin R itself, the system libraries a package
#   was built against, or Quarto. Writing those down is the difference between
#   a reproducible environment and a reproducible package list.

writeLines(c(
  "# Environment",
  "",
  "Written by reference/setup_renv.R. Update it when the environment changes.",
  "",
  paste0("- R: ", R.version.string),
  paste0("- Platform: ", R.version$platform),
  paste0("- Locked packages: ", length(locked)),
  paste0("- Snapshot taken: ", format(Sys.Date(), "%Y-%m-%d")),
  paste0("- Repositories: ",
         paste(paste0(names(getOption("repos")), " = ", getOption("repos")),
               collapse = "; ")),
  "",
  "## Restoring",
  "",
  "```r",
  "renv::restore()",
  "```",
  "",
  "renv pins package versions. It does not pin R itself or the system",
  "libraries a package was compiled against. An analyst on a different R",
  "minor version may resolve different builds; if results have to match to",
  "the last digit, match the R version above as well.",
  "",
  "## If restore fails on a secured mirror",
  "",
  "A frozen CRAN snapshot may not carry a version the lockfile names. Check",
  "with `available.packages()[\"<pkg>\", \"Version\"]`, and note that dplyr",
  "must be 1.2.0 or later: `recode_values()` and its `unmatched = \"error\"`",
  "stop are load-bearing in the recode stage."
), "ENVIRONMENT.md")

cat("\nWrote ENVIRONMENT.md\n")


# ---- 4. Prove it restores ---------------------------------------------------

cat("\nTo prove the lockfile works, from a clean clone elsewhere:\n",
    "  renv::restore()\n",
    "  shiny::runApp()\n",
    "and run one analysis end to end. A lockfile that has only ever been\n",
    "written is untested.\n", sep = "")
