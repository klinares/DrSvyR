# DrSvyR, branch `shiny_app`

`main` is an R package launched with `drsvyr::run_drsvyr()`. This branch is the
same analysis as a plain Shiny app directory, so Posit Connect can run it
without installing anything. Work on this branch only; `main` is cleaned up
separately.

## Layout

| Path | What it is |
|---|---|
| `app.R` | Settings, `library()` calls, masking checks, sources `R/`, state (`new_state`), `WISE_TABS`, `ui`, `server`, `shinyApp(ui, server)` |
| `R/` | 12 files, function definitions only: core, data, engine, llm, model, plots, reflexes, report_bundle, results, ui_data, ui_model, ui_results. Sourced flat, alphabetically, by `app.R` |
| `help.md` | The "Start here" tab |
| `www/figures/` | Help images. Shiny serves `www/` at the site root, so `help.md` links them as `figures/...` |
| `data/` | LAPOP Ecuador 2023 demo `.sav`, found by `demo_survey_path()` |
| `tests/smoke.R` | Smoke test. Listed in `.rscignore`, never deployed |
| `README.md` `LICENSE` `.gitignore` `.rscignore` | |

## Settings at the top of app.R

- `APP_CLASSIFICATION`: the banner on every screen and in the report.
- `APP_MAX_UPLOAD_MB`: largest upload; sets `shiny.maxRequestSize`.
- `options(bitmapType = "cairo")`: Connect has no X11.
- `APP_PACKAGES`: packages used as `pkg::fn()`; a missing one stops startup.
- The LLM endpoint is `WISE_LLM` in `R/llm.R`, not in `app.R`.

## Hard rules

1. R code is tidyverse style. NEVER use `for` or `while` loops. Use purrr
   (`map`, `map_dbl`, `walk`, `imap`, `reduce`, `detect`, `keep`/`discard`).
2. Files in `R/` contain only function definitions and constant assignments.
   No top-level calls, no `library()`. No two files may define the same name:
   alphabetical sourcing would silently pick a winner.
3. No parallelism: no future, furrr, parallel, mirai.
4. No package scaffolding: no DESCRIPTION, NAMESPACE, `system.file()`, or
   installed-package assumptions.
5. Assets go in `www/` (served) or `data/` (read from `getwd()/data`). No
   `addResourcePath()`, no new asset folders.
6. Do not change statistical behaviour (EM, start sets, replicate variance,
   design handling) unless asked. If a change could move an estimate, stop
   and say so.
7. Do not invent package functions or arguments. Check the installed help or
   say you are unsure.
8. Commit on `shiny_app` only, in small focused commits with clear messages.
   Never commit to `main`, never force-push, never delete branches, ask
   before pushing.

## Run

```r
shiny::runApp(".")
```

Headless: `Rscript --no-init-file -e "shiny::runApp('.', port = 8765, launch.browser = FALSE)"`.
`--no-init-file` keeps a personal `.Rprofile` out, as on Connect.

## Test

```
Rscript --no-init-file tests/smoke.R
```

Sources `app.R`, runs a small `search_sizes()` on the demo data, checks
`plot_data_uri()`, then times a full-size search (`WISE_FIXED` settings,
K 2:10). The full search takes about 10 minutes, so expect a wait.

## Publish

```r
rsconnect::deployApp(".", appName = "drsvyr")
```

Everything in the directory is uploaded unless `.rscignore` lists it.

The full search (~10 min) blocks its R process. In Connect's Runtime settings
set Max connections per process = 1 so it blocks only its own analyst, size
Max processes to memory, and check the timeouts outlast a 10-minute search.
ExtendedTask would need mirai (rule 3), so it is not used.
