# DrSvyR

A repository of Shiny apps for complex survey data. Each app is a
self-contained folder at the top level; `svysegment/` is the first. There is no
R package any more.

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
| `inteRn/` | Not an app: the AI coding intern for RStudio. `inteRn.R` is sourced from a user's `~/.Rprofile`; `R/` holds definitions only (same rule 2); settings in a gitignored `config.R` copied from `config.example.R`. Tests: `Rscript --no-init-file inteRn/tests/smoke.R` and `inteRn/tests/skills_check.R` (no API calls). Setup in `inteRn/README.md` |
| `ai_skills/` | Shared skills (SKILL.md folders) for inteRn, Claude Code and other agents, plus `reflexes.md`. `.claude/skills` is a gitignored junction to it |

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
2. Files in an app's `R/` contain only function definitions and constant
   assignments. No top-level calls, no `library()`. No two files may define
   the same name: alphabetical sourcing would silently pick a winner. `R/` is
   sourced into the global environment but `runApp()` runs `app.R` in its
   own, so `R/` cannot see objects made in `app.R` unless `app.R` assigns
   them to `globalenv()` (as it does `APP_CLASSIFICATION`). Test by loading
   with `shiny::shinyAppDir()`, not `source("app.R")`, which hides this.
   `R/_disable_autoload.R` stops Shiny auto-sourcing `R/` as well, which
   would load every function twice and run the server on the other copy.
3. No parallelism: no future, furrr, parallel, mirai.
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
