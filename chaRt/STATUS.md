# chaRt: status

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
