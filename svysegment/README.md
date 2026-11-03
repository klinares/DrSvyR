# svysegment

Finds a small number of distinct respondent types in a battery of related
survey questions, places every respondent it can reach in the type their
answers fit best, and compares those types across the groups you care about.
Every margin of error comes from the survey's own design: strata, clusters
and weights, carried through replicate weights from the model to the group
estimates.

The model is a weighted latent class analysis. If a battery is better
described by one continuum than by a handful of types, this is the wrong tool
for it.

You do not need to write any R. You do need to know your survey: which
variables carry the respondent identifier, the stratum, the sampling unit and
the weight.

## Run it

```r
install.packages(c(
  "shiny", "bslib", "survey", "haven", "ggplot2", "purrr", "stringr",
  "tibble", "tidyr", "dplyr", "base64enc", "clue", "digest", "ellmer", "fs",
  "janitor", "jsonlite", "knitr", "matrixStats", "MetBrewer", "readr",
  "rlang", "viridis", "yaml"))

shiny::runApp("svysegment")      # from the repository root
```

Or open `svysegment/app.R` in RStudio and press **Run App**.

An API key on the **Start here** screen lets a language model draft segment
names and written sections from figures the app has already computed. It never
sees a respondent record. Without a key the model, the estimates and the
report are identical; only the drafted prose is missing.

## Publish it to Posit Connect

```r
rsconnect::deployApp("svysegment", appName = "svysegment")
```

This folder is the deployable unit; `.rscignore` keeps this README and
`tests/` out of the bundle. Connect must be able to install the packages
above.

In the content's **Runtime** settings, set **Max connections per process = 1**.
The full model search takes about three minutes on the demonstration survey,
longer with more respondents or items, and occupies its R process for that
time; with one connection per process it holds up only the analyst who started
it. Size **Max processes** to the server's memory.

## What the analyst takes away

Two downloads on **11. Outputs**: the report, one self-contained HTML file
holding every table and figure, the decision log and the specification (any
table can be saved from it as CSV), and the survey file with each respondent's
segment and posterior probabilities added. The session's working folder is
temporary and is deleted when the tab closes.

## What is where

| Path | What it is |
|---|---|
| `app.R` | Settings, packages, state, layout, server. Ends in `shinyApp(ui, server)`. |
| `R/` | Function definitions only, sourced by `app.R`. |
| `R/ui_help.R` | The **Start here** page: what the method is, how to use it, its limits, and the naming prompt. |
| `www/reports/` | The method report (PDF), linked from Start here. Shiny serves `www/` at the site root. |
| `www/logo/` | The office logo, `office_logo.png` unless `APP_LOGO` says otherwise. |
| `www/ai_reflexes.md` | The AI reflexes: what a model writing for the app knows and may say, and the reporting style with examples. Edit it to change them; it is read on every request. |
| `data/` | The demonstration survey (LAPOP AmericasBarometer, Ecuador 2023). |

## Settings

At the top of `app.R`:

- `APP_CLASSIFICATION`: the marking on every screen and in the report.
- `APP_MAX_UPLOAD_MB`: the largest survey file accepted.
- `APP_LOGO`, `APP_OFFICE`: the logo file in `www/logo/`, and an optional office
  name beside it.

The language-model endpoint, models and key variable are `WISE_LLM` in
`R/llm.R`.

## Data acknowledgment

The demonstration uses the 2023 AmericasBarometer for Ecuador by the LAPOP Lab
at Vanderbilt University.
