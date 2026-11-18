# chaRt, Phase 0: skeleton, key box and probes

You are building the first phase of a new Shiny app, chaRt, in this repository (DrSvyR).

## Read first

1. `CLAUDE.md` at the repository root. Its hard rules apply to everything you write.
2. `chaRt/DESIGN.md`. The whole design. Phase 0 builds only what is listed below; do not start
   later phases.
3. `QuestionR/app.R`, `QuestionR/R/llm.R`, `QuestionR/README.md`. chaRt copies their structure.

## Rules for this phase

- Work on a new branch `chart`, made from `main`. Small commits. Do not push. Do not touch
  `svysegment/`, `QuestionR/`, `SurvAI_Expert/` or `inteRn/`.
- R style: tidyverse, native pipe `|>`, no `for`, `while` or `repeat`, `pkg::fn()` in `R/`,
  `=` inside function bodies and `<-` outside. Files in `R/` hold function definitions and
  constants only.
- Never invent a function or an argument. Before you call anything from ellmer, shinychat,
  plotly or quarto, check it in the installed package (`help()`, `getNamespaceExports()`,
  `formals()`). If you cannot confirm it, stop and say so in the summary.
- No em-dashes in any prose you write (README, comments, page text).
- Keep the file count to what is listed. Do not add helpers, config files or folders.

## Build

### 1. `chaRt/app.R`

Same seven sections, in the same order, as `QuestionR/app.R`.

- Settings: `APP_CLASSIFICATION <- "UNCLASSIFIED"`, `APP_LOGO`, `APP_OFFICE`,
  `APP_MAX_UPLOAD_MB <- 50` (sets `shiny.maxRequestSize`), `APP_SOURCE_URL`,
  `APP_DEFAULT_PROFILE <- "home"`.
- `APP_PROFILES`: `home` is `api = "anthropic"`, `base_url = "https://api.anthropic.com/v1"`,
  `id = "claude-sonnet-5-5"`. `work` is `api = "openai"` with `<work base url>` and
  `<model id at work>` placeholders. No drafter. The environment variable is `CHART_PROFILE`.
- The package check, the ellmer function-and-argument check and the masking check, as QuestionR
  has them. Add to `APP_PACKAGES` only what Phase 0 uses.
- `options(bitmapType = "cairo")`.
- Layout: the classification banner, the header (Source code button, logo, title "chaRt",
  dark-mode switch), then a `navlistPanel` with six tabs: Start here, Data, Codebook, Explore,
  Report, Methodology. Start here holds one short paragraph saying what the tool does, the key
  box and the connection check. The other five each hold one line: "Built in a later phase."
- Server: `mod_key_server` and `mod_connect_server` only.

### 2. `chaRt/R/llm.R`

Copy `QuestionR/R/llm.R` and remove only what is QuestionR's: the drafter, the per-task entries
of `LLM_MAX_TOKENS` (keep `ping`; add `label`, `suggest`, `refine`, `summarize` at 8000 each as
placeholders) and `LLM_CUTOFF_ADVICE`. Keep the session key, `llm_chat`, `llm_complete`,
`llm_json`, the JSON repair, `llm_ping`, the key box and its wording. If `mod_connect_server` or
the logo and box helpers live in `QuestionR/R/ui.R`, copy just those into `chaRt/R/ui.R`.

Do not refactor what you copy. The aim is the same behaviour under a new name.

### 3. The small files

`R/_disable_autoload.R`, `.rscignore` (keeps `tests`, `build`, `probe`, `README.md`, `DESIGN.md`,
`STATUS.md` out of the bundle), `.gitignore`, and `www/logo/` if QuestionR needs one to exist.

### 4. `chaRt/tests/smoke.R` (no model calls)

Run as `Rscript --no-init-file tests/smoke.R` from inside `chaRt/`. It checks, and prints one
line per check with a final count:

- the app loads through `shiny::shinyAppDir(".")`;
- no file in `R/` has a top-level call or a `library()`;
- no name is defined in two files of `R/`;
- no `for (`, `while (` or `repeat` anywhere in `app.R` or `R/`;
- with no key, `llm_key_ready()` is `FALSE` and `llm_ping()` returns the "Waits for a key" message;
- the string `ANTHROPIC_API_KEY` does not appear in `app.R` or `R/` except in a comment saying it
  is ignored.

### 5. `chaRt/tests/llm_check.R` (live, at home only)

Reads the key from the environment (test scripts may; the app never does). Three checks, each
printing what it sent and what came back:

1. **Ping** the home model through `llm_ping()`.
2. **Structured output, Anthropic style.** Through the same chat object `llm_chat()` builds, ask
   for a three-field object (`family` a string from a fixed set, `x` a string, `log_x` a
   boolean) using ellmer's structured-output method. Confirm the method's name and arguments in
   the installed ellmer first. Report: does it work, and does the reply match the schema.
3. **Structured output, OpenAI style.** The same request through `ellmer::chat_openai_compatible`
   against OpenRouter (`OPENROUTER_API_KEY`, base URL `https://openrouter.ai/api/v1`, a small
   cheap model). This stands in for the work endpoint. Report the same two things.

If structured output fails on either route, do not work around it. Report it; the design falls
back to `llm_json()`.

### 6. `chaRt/probe/app.R`

A separate one-file Shiny app that Kevin will publish at work to learn what the server can do.
No model calls, no key. One page with a table of checks, each "yes", "no" or the error text:

- the versions of R, shiny, ellmer, and whether `plotly`, `shinychat`, `yaml`, `quarto`, `ragg`
  and `htmltools` are installed (with versions);
- whether Quarto is found (confirm the function that reports its path in the installed `quarto`
  package) and its version;
- whether a three-line `.qmd` written to `tempdir()` renders to self-contained HTML from inside
  the running app, and how many seconds it took;
- whether a PNG can be drawn with `bitmapType = "cairo"`;
- whether `tempdir()` is writable.

Wrap every check in `tryCatch` so one failure does not hide the others. Add a "Copy results"
text area holding the table as plain text, since Kevin has to type the results back at home.
Same classification banner as the main app.

### 7. shinychat: look, do not build

Report the installed shinychat version and the names of its exported functions for a chat UI,
for appending a message, and for streaming, with their arguments. Say whether a reply can be
appended as one complete message (chaRt's chat replies are short and not streamed). Build
nothing with it in this phase.

### 8. Documentation

- `chaRt/README.md`: what the app is (three sentences), how to run it, the profiles, how the key
  is handled, how to run the two tests, how to publish the probe.
- `chaRt/STATUS.md`: what Phase 0 built, what is not built, anything you could not confirm.
- Add a chaRt row to the layout table in the root `CLAUDE.md` and a line in the root `README.md`.
  Change nothing else in either file.

## Verify before you report

- `Rscript --no-init-file tests/smoke.R` passes.
- `Rscript --no-init-file -e "shiny::runApp('chaRt', port = 8765, launch.browser = FALSE)"` from
  the repository root starts without error.
- `shiny::runApp('chaRt/probe')` starts and its table fills in.
- `git status` is clean on branch `chart`, and nothing outside `chaRt/`, `CLAUDE.md` and
  `README.md` changed.

## Report back (Kevin pastes this into the Claude project)

1. The files created, with line counts.
2. The smoke test's output.
3. The output of `tests/llm_check.R`, all three checks.
4. The probe's table as run at home.
5. The shinychat findings from step 7.
6. Everything you could not confirm, and every place you departed from this prompt and why.
