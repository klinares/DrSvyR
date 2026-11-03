# DrSvyR — Shiny app (branch `shiny_app`)

This branch is DrSvyR as a plain Shiny app: clone it, install the packages,
run it. Nothing is installed or built. The R package, launched with
`drsvyr::run_drsvyr()`, lives on `main`.

## Run it

```r
install.packages(c(
  "shiny", "bslib", "survey", "haven", "ggplot2", "purrr", "stringr",
  "tibble", "tidyr", "dplyr", "base64enc", "digest", "fs", "janitor",
  "jsonlite", "knitr", "markdown", "matrixStats", "readr", "rlang",
  "viridis", "yaml"))

shiny::runApp(".")      # from the repository root
```

Or open `app.R` in RStudio and press **Run App**.

Optional: `install.packages(c("ellmer", "curl"))` and an API key on the
**Start here** screen let a language model draft segment names and written
sections. Without them the model, the estimates and the report are identical;
only the drafted prose is missing.

## Publish it to Posit Connect

```r
rsconnect::deployApp(".", appName = "drsvyr")
```

The repository is the deployable unit. `.rscignore` keeps this README and the
licence out of the bundle.

## What is where

| Path | What it is |
|---|---|
| `app.R` | Settings, packages, state, layout, server. Ends in `shinyApp(ui, server)`. |
| `R/` | Function definitions only. Sourced by `app.R`. |
| `help.md` | The **Start here** page. |
| `www/figures/` | Images for `help.md`. Shiny serves `www/` at the site root. |
| `data/` | The demonstration survey (LAPOP AmericasBarometer, Ecuador 2023). |

## Settings

Two lines at the top of `app.R`:

- `APP_CLASSIFICATION` — the marking on every screen and in the report.
- `APP_MAX_UPLOAD_MB` — the largest survey file accepted.

The language-model endpoint and models are set in `R/llm.R`.

## How this differs from `main`

- No package scaffolding (`DESCRIPTION`, `NAMESPACE`, `man/`, `inst/`).
- The AI Survey Methodologist chat tab is removed. The key box moved to
  `R/llm.R` and stays on Start here, because the other drafting features use it.
- Single-core. `future` and `furrr` are gone; the search returns the same
  model, more slowly.
- All PNGs are drawn with cairo, so no X11 is needed on the server.

## Data acknowledgment

The demonstration uses the 2023 AmericasBarometer for Ecuador by the LAPOP Lab at Vanderbilt University.
