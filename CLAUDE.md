# DrSvyR

A repository of Shiny apps for complex survey data. Each app is a
self-contained folder at the top level; `svysegment/` is the first and
`QuestionR/` the second. `inteRn/` is not an app. There is no R package any more.

## Layout

| Path | What it is |
|---|---|
| `README.md` `.gitignore` | Shared by every app |
| `svysegment/app.R` | Settings, `library()` calls, masking checks, sources `R/`, state (`new_state`), `ui`, `server`, `shinyApp(ui, server)` |
| `svysegment/R/` | 13 files of function definitions only, plus the empty `_disable_autoload.R`: ai_reflexes, core, data, engine, llm, model, plots, report_bundle, results, ui_data, ui_help, ui_model, ui_results. Sourced flat, alphabetically, by `app.R` |
| `svysegment/R/ui_help.R` | The "Start here" tab, in cards, and the office logo |
| `svysegment/www/reports/` `svysegment/www/logo/` | Method report PDF and office logo. Shiny serves `www/` at the site root |
| `svysegment/data/` | LAPOP Ecuador 2023 demo `.sav`, found by `demo_survey_path()` |
| `svysegment/tests/smoke.R` | Smoke test, kept out of the bundle by `.rscignore` |
| `QuestionR/` | An AI reviewer and item writer for questionnaires: Evaluate questions and Write questions, one model. Read `QuestionR/README.md` and `QuestionR/STATUS.md` first; `QuestionR/archive/` holds earlier phases. Its reflex files, `www/reflexes/*.md`, are checksummed in `tests/smoke.R` and are edited in the Claude project, not by code. `tests/` is home only. Test: `Rscript --no-init-file tests/smoke.R` from inside `QuestionR/` (no API calls); `tests/llm_check.R review30` or `gold` make live calls |
| `inteRn/` | Not an app: an AI coding intern for RStudio. One script, `inteRn/inteRn.R`, set up with `source("inteRn/install.R")`. Test: `Rscript --no-init-file inteRn/tests/smoke.R` (no API calls); `inteRn/tests/live.R` asks the real model (needs the key, costs a little) |
| `chaRt/` | Publishable charts from a data file: codebook, chart specs drawn by one R renderer, chat refinement, HTML report. Read `chaRt/DESIGN.md` and `chaRt/STATUS.md` first; built one phase at a time (Phase 0: skeleton, key box, probe). `probe/` is a separate app published once at work. Test: `Rscript --no-init-file tests/smoke.R` from inside `chaRt/` (no API calls); `tests/llm_check.R` makes live calls |
| `SurvAI_Expert/` | Answers survey methodology questions from a library of course materials, with sources, formulas shown as stored and R examples; also advises on a described situation. Read `SurvAI_Expert/README.md` first. The store, `data/store/survai.duckdb`, is built from the text in `data/markdown/` and `data/catalog/` by `Rscript --no-init-file build/03_store.R` (from inside `SurvAI_Expert/`) and is never copied. `build/01_convert.R` and `build/02_catalog.R` are home only. Test: `Rscript --no-init-file tests/smoke.R` from inside `SurvAI_Expert/` (no API calls) |

## svysegment settings (top of app.R)

- `APP_CLASSIFICATION`: the banner on every screen and in the report.
- `APP_MAX_UPLOAD_MB`: largest upload; sets `shiny.maxRequestSize`.
- `APP_LOGO`, `APP_OFFICE`: logo file in `www/logo/` and optional office name.
- `options(bitmapType = "cairo")`: Connect has no X11.
- `APP_PACKAGES`: packages used as `pkg::fn()`; a missing one stops startup.
- The LLM endpoint is `WISE_LLM` in `R/llm.R`; what the writing model knows, may say and how it words the report is `www/ai_reflexes.md` (markdown, parsed by `R/ai_reflexes.R`).

## Hard rules

1. R code is tidyverse style. NEVER use `for` or `while` loops. Use purrr
   (`map`, `map_dbl`, `walk`, `imap`, `reduce`, `detect`, `keep`/`discard`).
   `chaRt/R/spec.R` is the one file where dplyr, tidyr, ggplot2 and scales functions are called without `pkg::`: it builds each chart as R calls that are both evaluated (in `spec_env()`) and shown to the analyst as code, so they are written as a person would write them.
2. Files in an app's `R/` contain only function definitions and constant
   assignments. No top-level calls, no `library()`. No two files may define
   the same name: alphabetical sourcing would silently pick a winner. `R/` is
   sourced into the global environment but `runApp()` runs `app.R` in its
   own, so `R/` cannot see objects made in `app.R` unless `app.R` assigns
   them to `globalenv()` (as it does `APP_CLASSIFICATION`). Test by loading
   with `shiny::shinyAppDir()`, not `source("app.R")`, which hides this.
   `R/_disable_autoload.R` stops Shiny auto-sourcing `R/` as well, which
   would load every function twice and run the server on the other copy.
3. No parallelism: no future, furrr, parallel, mirai. (Exception, for QuestionR's model calls only: several HTTP requests may be in flight at once inside the one R process, with no extra R processes and no new package.)
4. No package scaffolding: no DESCRIPTION, NAMESPACE, `system.file()`, or
   installed-package assumptions.
5. Assets go in the app's `www/` (served) or `data/` (read from
   `getwd()/data`). No `addResourcePath()`, no new asset folders.
6. Do not change statistical behaviour (EM, start sets, replicate variance,
   design handling) unless asked. If a change could move an estimate, stop
   and say so.
7. Do not invent package functions or arguments. Check the installed help or
   say you are unsure.
8. Small focused commits with clear messages. Never force-push, never delete
   branches, ask before pushing.

## Run, test, publish (from the repository root)

```r
shiny::runApp("svysegment")
rsconnect::deployApp("svysegment", appName = "svysegment")
```

Headless: `Rscript --no-init-file -e "shiny::runApp('svysegment', port = 8765, launch.browser = FALSE)"`.
`--no-init-file` keeps a personal `.Rprofile` out, as on Connect.

Smoke test, run from inside `svysegment/`: `Rscript --no-init-file tests/smoke.R`.
It sources `app.R`, runs a small `search_sizes()` on the demo data, checks
`plot_data_uri()`, then times a full-size search (about 3 minutes).

Publishing uploads everything in the app folder that its `.rscignore` does not
list. The full search blocks its R process, so in Connect's Runtime settings
set Max connections per process = 1 and size Max processes to memory.
ExtendedTask would need mirai (rule 3), so it is not used.
