# chaRt: status

## Phase 2b, 2026-11-17: renderer fixes after the gallery review

Branch `chart`. Not pushed. No model calls. The tabs are unchanged.

### Built

- Static charts: ties across the `top_n` cut and equal values are noted; line and slope end labels
  are drawn only when no two would touch (`SPEC_LABEL_GAP`), otherwise a legend on the right in
  the order of the end values; highlight labels sit inward of their points; facet and colour on
  one column draw one colour; yellow is the eighth colour; boxes sort by median; heatmap rows run
  in level order, top to bottom, and up to `SPEC_HEAT_LABELS` cells print their value in black or
  white; points mostly on shared positions are drawn with `geom_count()`; two legends stack and a
  long one wraps; a sideways bar or dot has no title on its name axis; room below zero comes from
  the table.
- The code: `top_n` as `arrange(desc(value), name) |> slice_head(n = n)` (or a helper column and
  `consecutive_id()` when an x has several rows); the order with `factor()`; no `tapply()`,
  `sort()` or `head()`; the file by its name only; `rename()` for repaired names; one step per line,
  wrapped only past `SPEC_CODE_WIDTH`.
- Encoding: `read_data()` guesses it with `readr::guess_encoding()`; a Latin-family guess is read
  as windows-1252; the problems say so; the codebook keeps `encoding`; the code passes it.
- The widget is made from a variant of the plot with no direct labels, the legend kept and a
  tooltip naming each value with its codebook label; the title (bold) and subtitle are shown and
  wrapped, the caption below, the text scaled, the legend on the right.
- `CLAUDE.md`, rule 1: `chaRt/R/spec.R` is the one file that calls dplyr, tidyr, ggplot2 and scales
  without `pkg::`.
- `tests/smoke.R`: 111 checks (90 before, 21 new). Two gold specs added (25 in all): a Latin-1 bar
  and a line whose labels fit.

### What still differs in the plotly version

- Its default font is wider than the static chart's (heights match at the same size).
- The legend of a line chart is alphabetical, not in end-value order (ggplotly ignores `breaks`).
- A bubble chart's colour and size legends are merged into one list without size keys.
- The heatmap's colour bar and the rug look as before (bar on the right, rug opaque).
- Highlighted lines and points carry no legend: their names are in the tooltip.

### Readings

- "The n shown" in the tie note is how many of the tied values are shown.
- A line chart with a highlight whose labels would touch colours the highlighted lines from the
  palette and shows them in a legend (one highlight colour would make the legend useless).
- More than 8 lines whose labels would touch: no labels, no legend (one colour), and a note.
- Item 10's exception: the name axis keeps its title when the spec gives `x_label`, the field for
  that column (the prompt says `y_label`, which is the value axis's).
- Item 8 applies to scatter charts without a highlight (a bubble already sizes its points).
- The tie-break is dplyr's `arrange()` order, which sorts text in the C locale (capitals first).
- Encoding: readr guessed the Latin-1 test file as ISO-8859-2 (65%), which would turn "São" into
  "Săo". Any Latin-family guess is read as windows-1252, and the sentence then says it is a guess.
- A file that is not UTF-8 breaks vroom's delimiter guessing, so for such a file `read_data()`
  takes the delimiter that splits the header into the most columns.

### Not confirmed

- That the plotly text scale (`SPEC_PLOTLY_TEXT`) matches on other screens; it was set from
  ggplotly's point-to-pixel ratio and checked by eye in the gallery.

## Phase 2, 2026-11-17: the renderer

Branch `chart`. Not pushed. No model calls. The tabs are unchanged.

### Built

- `R/theme.R`: `chart_theme(base_size, grid)`, `chart_palette(n)` (Okabe-Ito, at most 8),
  `chart_fill_scale()`, `chart_colour_scale()`, `CHART_HIGHLIGHT`, `CHART_GREY`, and
  `CHART_SINGLE`, `CHART_SEQUENTIAL`, `CHART_MAX_GROUPS`.
- `R/spec.R`: `spec_defaults()`, `spec_check()`, `spec_table()`, `spec_lint()`, `spec_plot()`,
  `spec_widget()`, `spec_code()`, `spec_size()`. The table's steps and the plot's layers are built
  once as R calls: `spec_table()` and `spec_plot()` evaluate them, `spec_code()` writes them out.
- `tests/gold_specs.yaml` (23 specs, at least two per family), `tests/gallery.R` (helpers, and the
  gallery when run as a script), `tests/gallery.html` (written, git-ignored).
- `tests/smoke.R`: 90 checks (52 before, 38 new).

### Findings

- ggplotly() gave no warning for any gold spec, including once the figure is built.
- In the plotly version: the subtitle and caption are dropped; text is about 1.4 times larger
  than in the static chart at the same pixel size, and a long title is cut off rather than
  wrapped; direct labels ignore `check_overlap`, `hjust` and `vjust`, so line-end labels pile up
  and point labels sit on their points; the heatmap's colour bar moves to the right; a legend at
  the top overlaps the title; the rug loses its transparency.
- The yaml package reads a bare `y` (as a key or a value) as TRUE (YAML 1.1). The gold file quotes
  it. Specs from a model arrive as JSON, which has no such problem.
- FH's political rights scores tie at 40 for more than the top 10; `top_n` keeps the first in
  alphabetical order among ties.

### Readings of the prompt (where section 1 was ambiguous)

- More than 8 colours: the palette stops at 8. A line or slope chart with more draws every line in
  one colour with its name at the end; a scatter or bubble chart with more is refused.
- A scatter or bubble chart takes a highlight or a color, not both.
- "The value axis starts at zero" has no spec field to change: a bar's layers always include zero.
  Whether there are negative values is read from the codebook's minimum of y (the plot is built
  without the data), so the FH bars, whose column has a -2 somewhere, get a little room below zero.
- "Small multiples share their scales": `facet_wrap()` is fixed unless `free_y`, so nothing changes.
- The sort a bar or dot falls back on depends on x's type, so it is decided with the codebook, not
  in `spec_defaults()`. `level_order` is the analyst's order for an ordered x, numeric order for
  numbers, and alphabetical for an unordered category.
- `share` is the share of rows within a facet, not within a colour.
- The table of a scatter, bubble, histogram or box is the rows drawn (the columns in use), not
  binned or summarised.
- A histogram's bins when none are given: Freedman-Diaconis, kept within 5 to 60, written into
  the spec by the lint so the code reproduces them. "Top n of N" is written the same way.
- `top_n` and `sort` are refused outside the families that use them; `log_x` only on a measure x of
  a scatter, bubble or histogram.
- The "k of n rows left out" note counts n after the filter.

### Departures

- The lint's fixes that have no spec field (`.flip`, `.alpha`, `.binned`) are kept in the spec with
  a leading dot; `spec_check()` refuses them from outside. `spec_code()` takes the spec as
  `spec_plot()` left it (`attr(plot, "spec")`), since those fixes depend on the data and
  `spec_code()` is given none. It reads the file's header to find the delimiter and the blank or
  repeated column names to rename.
- `chart_theme()` takes `grid` ("y", "x", "xy", "none"): the value axis differs by family, and the
  code must end with `chart_theme()`.
- The calls in `R/spec.R` name dplyr, tidyr, ggplot2 and scales functions without `pkg::`, so the
  written code reads as a person writes it; they are evaluated in `spec_env()`, which holds those
  packages' exports.
- Additions: an `arrange()` step so a bar's table is in drawn order; comma labels on value axes;
  `coord_cartesian(clip = "off")` where labels sit at the edge; extra gold specs (a dot, a bubble, a
  highlighted slope and a box).
- `base64enc` was not needed. The smoke test runs the generated code in a separate `Rscript`.

### Not confirmed

- How the charts look at work with the office theme, and whether plotly there behaves the same.
- FH's `Cote d'Ivoire` is not valid UTF-8 in the file. It appears in no gold chart; how it would be
  drawn or written into code is unchecked.

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
