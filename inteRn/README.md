# inteRn

An AI coding intern that lives in RStudio, for survey researchers and data
scientists. Built by a survey methodologist, for survey methodologists.

It helps with everyday R work -- writing and fixing tidyverse code, survey
designs, figures, Quarto reports, codebooks -- and it can see what is in your
R session, **but only its structure**: names, types, labels and suppressed
aggregates, never your data's values. It follows the shared skills in
[`../ai_skills`](../ai_skills/README.md), the same ones Claude Code reads.

```r
ask("Write srvyr code for the share who trust courts by region, with 95% CIs.")
svy %ask% "Which variables still carry 8/9 missing-value codes?"
open_intern()                      # a chat in the Viewer; the console stays free
```

## What leaves your R session, and what never does

| Sent to the model | Never sent |
|---|---|
| object names, classes, dimensions | rows, cell values, min and max |
| column names, types, variable labels, value labels, factor levels | free-text answers, names, IDs |
| counts and shares, with every count under `suppress_n` (default 10) shown as `<10`, and one more cell marked `suppressed` so the small one cannot be worked out | data files (`.csv .sav .dta .rds .parquet .xlsx ...`), rendered reports (`.html .pdf .docx`) |
| means, SDs and quartiles of numeric columns | the printed output of code it runs, unless you choose to share it |
| code and text files in the folders you allow (credentials scrubbed) | `.Renviron`, `.Rprofile`, `.Rhistory`, anything under `.git/` |
| function source (credentials and personal paths scrubbed) | your API key (it is passed to the API client and nowhere else) |

Anything that changes something -- running code, writing a file -- is shown to
you first and needs your approval. The codebook skill writes exactly what it
sent to the model to `sent_to_model.txt`, so it can be audited.

## Set up (new user, about 10 minutes)

**1. Get the folder.** Clone the repository that holds `inteRn/` and
`ai_skills/` (they sit side by side), or copy both folders anywhere. Pull to
update; nothing is installed as a package.

**2. Install R packages** (R 4.1 or later; RStudio recommended):

```r
install.packages(c(
  "ellmer", "purrr", "rlang",                                  # core
  "httpuv", "promises", "later", "jsonlite", "commonmark",     # open_intern()
  "lintr", "rstudioapi", "diffobj", "yaml", "viridisLite",     # lint gate, diffs, skills
  "dplyr", "tibble", "ggplot2", "scales", "survey", "srvyr",   # skill scripts
  "nanoparquet", "knitr", "rmarkdown", "palmerpenguins"))       # codebook skill
```

For the codebook skill also install the data-dict command-line tool (no
admin rights, no PATH change) and [Quarto](https://quarto.org):

```r
pak::pak("tidyverse/data-dict/r")
datadict::dd_install()
```

**3. Your settings.** Copy `inteRn/config.example.R` to `inteRn/config.R`
and edit the copy: the endpoint (`base_url`), the model IDs (`pm`,
`worker`), and the folders the intern may read and write (`allow_dirs`).
`config.R` is ignored by git. Check model IDs against
`ellmer::models_anthropic()` or your work server's list.

**4. Your key.** Open your user `.Renviron` with `usethis::edit_r_environ()`
and add one line, using the variable name in `key_var`:

```
ANTHROPIC_API_KEY=your-key-here
```

On Windows RStudio keeps this file in your Documents folder, which may be
`OneDrive\Documents`. Never put the key in `config.R` or in code.

**5. Load it in every interactive session.** Open your `.Rprofile` with
`usethis::edit_r_profile()` and add, with your own path:

```r
if (interactive()) source("C:/path/to/inteRn/inteRn.R")
```

**6. Restart R and check.**

```r
intern_config()          # settings in use; says whether the key is found (never shows it)
ask("Say hello in one line.")
```

**7. (Optional) Claude Code.** To have Claude Code read the same skills, link
them from the repository root (one-time, per clone):

```
mklink /J .claude\skills ai_skills          (Windows, cmd)
ln -s ../ai_skills .claude/skills           (macOS / Linux)
```

## Using it

| You type | What happens |
|---|---|
| `ask("...")` | One question in the session's conversation. Blocks only while the model replies; approvals are asked in the console. `ask("...", new = TRUE)` starts over. |
| `obj %ask% "..."` | Sends `obj`'s structure with the question. Works on expressions too (`palmerpenguins::penguins %ask% "..."`); put pipelines in parentheses: `(df \|> filter(x > 1)) %ask% "..."`. |
| `open_intern()` / `close_intern()` | A chat page in the Viewer. Your console stays free while the model thinks; approvals appear as buttons. Code blocks have Copy, Insert (at the cursor) and To console. |
| `/reflex add <lesson>` | In `ask()` or the Viewer: appends a dated lesson to `ai_skills/reflexes.md` (not sent to the model). `/reflex list`, `/help`. Or `reflex_add("...")`. |
| `intern_source_skill("dataviz", "theme_intern.R")` | Loads a skill's helper functions into your session. |
| `intern_complete(prompt, system)` | One request, no tools, no history (used by the codebook skill). |
| `intern_reset()` | Forget the conversation. |
| `intern_config()` | Show the settings and whether the key is found. |

**Tools the model can call:** `env_summary`, `describe_object`,
`profile_object`, `get_function_source`, `list_files`, `read_file`,
`write_file` (shows a diff, needs approval), `run_code` (needs approval; you
choose whether it sees the output), `load_skill`.

**The lint gate.** R code in every reply is checked with lintr before you see
it: no `for`/`while`/`repeat` loops, no base graphics, colourblind-safe colours
only (Okabe-Ito or viridis), no `== NA`, no `T`/`F`. Failing code goes back to
the model for a rewrite, at most twice (`lint_retries`); whatever still fails
is shown with the problems listed. Code the model did not run gets
`# UNTESTED` as its first line. A block that starts with `# BAD EXAMPLE` (what
not to do, for teaching or review) is left alone and shown next to the
corrected version; `# nolint` comments do not switch the gate off. Turn it off
with `lint = FALSE` in `config.R`.

## Files

```
inteRn/
  inteRn.R            entry point, sourced from ~/.Rprofile
  config.example.R    settings template (copy to config.R)
  system.md           who the intern is and the rules that never bend
  R/                  function definitions only, one area per file
  www/                the Viewer chat page
  tests/smoke.R       offline checks (no API calls)
  tests/skills_check.R  the skills, their scripts and examples (no API calls)
  tests/live_check.R  one real round trip (needs a key; costs a few cents)
  tests/viewer_demo.R the Viewer with a stand-in model
```

Run the offline checks from the repository root:

```
Rscript --no-init-file inteRn/tests/smoke.R
Rscript --no-init-file inteRn/tests/skills_check.R
```

## Troubleshooting

- **"No API key"** -- the variable named in `key_var` is not set. Check with
  `nzchar(Sys.getenv("ANTHROPIC_API_KEY"))` after restarting R. `Rscript`
  started from Git Bash or another terminal may look for `.Renviron` in a
  different home folder than RStudio; point it at the file with
  `R_ENVIRON_USER`.
- **"model not found"** -- a model ID in `config.R` is not one your endpoint
  serves; compare with `ellmer::models_anthropic()`.
- **The Viewer stops responding** -- it is answered by your R session between
  console commands; it waits while code is running in the console.
- **"temperature is deprecated"** -- leave `temperature = NULL`.
- **Lint gate does nothing** -- `install.packages("lintr")`.
