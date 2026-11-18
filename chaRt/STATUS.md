# chaRt: status

## Phase 1b, 2026-11-17: four fixes to the data layer

Branch `chart`. Not pushed. No model calls.

### Built

- **Values that mean missing.** `read_data(path, name, missing)` adds the analyst's values to
  `DATA_NA`; readr matches them to whole cells after trimming (checked: `9` leaves `99` and `19`
  alone). The Data tab has "Values that mean missing, one per line" and "Read again", which calls
  `reread_data()`. The codebook keeps `missing_codes`; an uploaded codebook re-reads the file with
  them before `check_codebook()` runs and fills the box. `mostly_numbers_note()` now points to the
  box. FH read with `..` has 24 integer columns and one id, and no problems.
- **Whole-number ids.** A whole-number column of distinct values is `id` only when it is an
  unbroken run or its name matches `ID_NAME_PATTERN`; otherwise `integer` with `DISTINCT_NOTE`.
- **Roles follow the type.** `role_choices()` from `ROLE_CHOICES`; the role select offers only
  those; a type change keeps an allowed role and otherwise gives the default; `check_codebook()`
  refuses a role the type does not allow, naming the column.
- **Ordered levels one per line** in a `textAreaInput`, read by `parse_lines()`.
- `tests/smoke.R`: 52 checks (the 39, 12 asked for, and 1 on what Read again carries).

### Departures from the Phase 1b prompt

- **Read again carries what the analyst chose, not what R chose.** A type other than R's own
  (`detected`) and a role other than the type's default are kept, or dropped with a sentence. A
  type or role that R chose is chosen again from the data without a note; otherwise reading FH
  again with `..` gave 46 sentences saying text columns were now integer. Labels, their sources and
  the row sentence are always kept. One extra smoke check covers this.
- **A Phase 1 bug fixed:** `codebook_detail()` gave only the count of distinct values for any
  column with more than 30 values, numbers included, so a number's range and quartiles were never
  sent. The 30-level rule now applies only to category, flag and ordered columns, as DESIGN.md
  section 4 says.
- `missing_codes` is stored as text when there are codes and as an empty list (written `[]`) when
  there are none, because the yaml package reads a one-item list back as text; this keeps the round
  trip `identical()`.
- The "every value is different" rule, for whole numbers as for words, needs more than
  `CODEBOOK_MAX_LEVELS` rows, so a short file of distinct numbers is not called an id.
- An integer column can carry both notes, joined by "; ".
- A codebook uploaded on the Data tab now needs the data file to have been uploaded in this
  session (the file is read again with the codebook's values); before, a profile was enough.

### Noticed, not changed

- FH's political rights columns hold `-2` as their minimum. It may be a code; that is the analyst's
  call, and the box takes it if so.
- footballdata's `Birthday` is text: its dates are not in a form readr reads as dates.

## Phase 1, 2026-11-17: Phase 0 fixes, Data and Codebook

Branch `chart`. Not pushed. No model calls in the app.

### Built

- Part A: the connection heading on Start here is "Settings and connection". `tests/llm_check.R`
  defaults to `openai/gpt-6-luna` on OpenRouter, takes `CHART_TEST_MODEL` for checks 1 and 2, and
  stops before any call if the model is an Opus model. The probe lists knitr, rmarkdown, ggplot2,
  readr, dplyr, tidyr and tibble, and has a second render: a `.qmd` with one R chunk that draws a
  ggplot and prints `plotly::ggplotly()` of it.
- `R/data.R`: `read_data`, `profile_data`, `new_codebook`, `write_codebook`, `read_codebook`,
  `check_codebook`, `apply_codebook`, `edit_entry`, `codebook_ready`, `type_choices`,
  `codebook_index`, `codebook_detail`, and their helpers.
- The Data and Codebook tabs, with `data`, `problems`, `profile` and `codebook` in the shared state.
- `tests/smoke.R`: 39 checks (the 7 from Phase 0, 4 for each of five files, and 12 on the messy file).

### Findings

- Live check, with the key: the ping works on `claude-sonnet-5-5`, but structured output through
  ellmer 0.4.2 (`$chat_structured()`) is refused by the API for that model: "tool_choice: type
  "tool" and "any" are not supported for this model" (HTTP 400). The same call works on
  `claude-sonnet-4-5` and through OpenRouter (`openai/gpt-6-luna`). Not worked around: for
  Sonnet 5.5 the design falls back to `llm_json()`.
- FH_disaggregated.csv marks missing values with `..`, so 23 of its 25 columns read as text (about
  40 distinct values each). The Data tab says so for each column. Recoding is the analyst's call.
- R did not see the key from Git Bash: Git Bash sets `HOME` to `C:/Users/keval`, so R looked for
  `.Renviron` there; R's own home on this machine is `C:/Users/keval/OneDrive/Documents`, where the
  file is. From PowerShell R sees both keys.

### Not confirmed

- The row numbers readr gives for a ragged line are file line numbers (header = line 1) in the cases
  tried; for a value that fails to parse after the types are guessed from every row, this was not
  seen and so not checked.
- A level that contains a comma cannot be put in order in the Codebook tab, whose order box splits on
  commas.

### Departures from the Phase 1 prompt

- `read_data` also reports a column that is mostly numbers with a few words in it (the `..` of FH),
  naming up to three of the words. Nothing is recoded.
- The YAML holds `distinct` and the values and counts as `values` and `counts`, not the `levels: 5`
  of DESIGN.md section 5, since the prompt names `distinct` for the count. It also holds `detected`,
  R's own type, so the allowed type changes can be worked out after the analyst changes a type.
- `type_choices` also allows `integer` to `ordered` (it allows `integer` to `category`, and
  `category` to `ordered`), and `id` back to `integer` when the id is made of whole numbers (R typed
  it `id` on a guess, and nothing is converted on a guess).
- `check_codebook` also refuses an unknown role, a label not marked file, ai_guess or user, and an
  ordered column whose order is not exactly its levels.
- `id` is assigned when the column has more than `CODEBOOK_MAX_LEVELS` rows, as the prompt says,
  counting all rows, missing ones included.
- The role select offers all six roles for every column; the prompt fixes only which types are
  allowed.
- FH has no column whose type can change except `pr_2014` (integer to id), so the by-hand test set
  that one type, and also set a role on `pr_2003`.
- The probe's renders set `QUARTO_R` to the R running the app, so the R chunk runs in the same
  installation.
- The in-app browser has no file picker, so for the by-hand test the course file was fetched from a
  temporary read-only local server and handed to the file input with JavaScript. The server and the
  app were stopped afterwards; nothing was written to the repository.

## Phase 0, 2026-11-17: skeleton, key box and probes

Branch `chart`, from `main`. Not pushed.

### Built

- `app.R` in QuestionR's seven sections: settings (classification, logo, office, 50 MB upload limit,
  source link, default profile), the `home` and `work` profiles chosen by `CHART_PROFILE`, the
  package, ellmer and masking checks, Cairo, the layout (banner, header with Source code button,
  logo, title and dark-mode switch, six tabs) and a server with `mod_key_server` and
  `mod_connect_server` only.
- `R/llm.R`, copied from QuestionR. Removed: the drafter, QuestionR's per-task token limits (now
  `label`, `suggest`, `refine`, `summarize` at 8000 as placeholders, and `ping`),
  `LLM_CUTOFF_ADVICE`, and `llm_complete_all()` with `llm_json_all()` (see below).
- `R/ui.R`: the tab names, `advice_box`, `warn_box`, `office_logo`, `model_label`, Start here (one
  paragraph, the key box, the connection check), the "Built in a later phase." placeholder, and
  `mod_connect_ui` / `mod_connect_server` copied from QuestionR.
- `R/_disable_autoload.R`, `.rscignore`, `.gitignore`. No `www/logo/`: `office_logo()` draws a
  dashed box when the folder or file is missing, as in QuestionR.
- `tests/smoke.R` (7 checks, no model calls) and `tests/llm_check.R` (ping, structured output in
  both API styles).
- `probe/app.R`: versions, Quarto, a render from inside the app, Cairo PNG, `tempdir()`, and the
  "Copy results" text.

### Not built

Everything from Phase 1 on: Data, Codebook, Explore, Report and Methodology are one line each. No
`R/data.R`, `R/spec.R`, `R/theme.R`, `R/reflexes.R`, `report.qmd`, `www/reflexes/` or
`build/convert_skill.R`.

### Not confirmed

- The live check has not been run with keys: neither `ANTHROPIC_API_KEY` nor `OPENROUTER_API_KEY`
  is set on this machine, so it made no calls. Whether structured output works on either route is
  still open.
- The OpenRouter model `openai/gpt-4o-mini` is a guess at a small, cheap model that is still
  listed; `OPENROUTER_MODEL` overrides it.
- The `quarto` R package is not installed here, so the name of its path function could not be
  checked. The probe uses `quarto::quarto_path()` only if the installed package exports that name,
  otherwise `QUARTO_PATH`, then the PATH, and says which route it took. It renders with the Quarto
  command line (`quarto render file --to html`, with `embed-resources: true` in the document), not
  through the R package.

### Departures from the Phase 0 prompt

- `llm_complete_all()` and `llm_json_all()` were not copied. They send several requests at once;
  CLAUDE.md rule 3 allows that for QuestionR only, and DESIGN.md says chaRt has no parallelism. So
  `promises` and `later` are not in `APP_PACKAGES`. `llm_json()` keeps its `first` argument
  unchanged.
- Copied code keeps QuestionR's `<-` inside some function bodies (the modules), since the prompt
  says not to refactor what is copied. New code uses `=`.
- The key box keeps QuestionR's wording, which refers to "Settings and connection below"; in chaRt
  the section is headed "Models".
- The loop check reads R's parse data (the `for`, `while` and `repeat` keywords), so the word
  "repeat" in a comment of `llm.R` does not count.
- `.rscignore` also lists `phase0_prompt.md`, `.rscignore` and `.gitignore`.
- The probe uses base `lapply()` and `vapply()`, not purrr, so that it starts on a server with only
  shiny installed.
