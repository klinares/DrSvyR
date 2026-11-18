# chaRt, Phase 1: Phase 0 fixes, then Data and Codebook (no model calls)

## Read first

1. `CLAUDE.md` at the repository root. Its hard rules apply.
2. `chaRt/DESIGN.md`, sections 3, 4, 5 and 12.
3. `chaRt/STATUS.md`.

## Rules

- Branch `chart`. Small commits. Do not push. Touch nothing outside `chaRt/`.
- Do not create or edit any file outside the repository, including editor or tool settings in
  the home folder. If you need a preview, start the app from the command line.
- R style as in Phase 0. New code uses `=` inside function bodies. No `for`, `while`, `repeat`.
- Never invent a function or an argument: confirm each in the installed package first, and list
  what you could not confirm.
- No model calls anywhere in this phase. No em-dashes in prose.
- New packages allowed: `readr`, `dplyr`, `tidyr`, `tibble`, `yaml`. No others. In particular no
  table-widget package (DT, rhandsontable, reactable).
- New files allowed: `R/data.R`, and additions to `R/ui.R`, `app.R`, `tests/smoke.R`,
  `probe/app.R`, `README.md`, `STATUS.md`. Nothing else.

## Part A: Phase 0 fixes

1. **Heading.** In `R/ui.R`, rename the "Models" heading to "Settings and connection", so the
   key box wording copied from QuestionR is true and `R/llm.R` stays as copied.
2. **OpenRouter model.** In `tests/llm_check.R`, change the default of `OPENROUTER_MODEL` to
   `openai/gpt-6-luna` (an id already used in QuestionR).
3. **Probe: packages.** Add to `PROBE_PACKAGES`: `knitr`, `rmarkdown`, `ggplot2`, `readr`,
   `dplyr`, `tidyr`, `tibble`.
4. **Probe: the render that matters.** The Phase 0 render has no R code in it, so it only shows
   that Quarto can run pandoc. Keep it, and add a second check: a `.qmd` with one R chunk that
   draws a small ggplot and prints `plotly::ggplotly()` of it, rendered to self-contained HTML
   with the Quarto command line, as the first one is. Report yes or no, seconds, file size, and
   whether a `_files` folder was left; on failure the first 400 characters of the output. If
   `knitr`, `rmarkdown`, `ggplot2` or `plotly` is missing, the check says which and does not run.
5. **Outside the repository.** Say exactly what you added to `C:\Users\keval\.claude\launch.json`
   in Phase 0 so Kevin can remove it. Do not edit that file again.

Commit Part A on its own before starting Part B.

## Part B: `R/data.R`

Function definitions and constants only. Everything below is deterministic R.

### B1. Read the file

`read_data(path, name)` returns `list(data, problems)`.

- CSV and other delimited text, read with readr. Let readr guess the delimiter if the installed
  version supports that (confirm how); otherwise comma only, and say so.
- Guess column types from every row, not the first thousand.
- Empty strings and `NA` are missing. No other value is treated as missing, and no value is
  recoded. Sentinel codes such as -99 are the analyst's call.
- Blank or duplicate column names are repaired to unique names. Every rename goes in `problems`.
- `problems` is a character vector of plain sentences for the analyst: renames, rows readr could
  not parse (count and the first few row numbers), columns that are entirely missing, and a
  file with no rows or one column. A file that cannot be read stops with one plain sentence.

### B2. Profile and type

`profile_data(data)` returns one entry per column with `name`, `type`, `missing` (share, two
decimals), `distinct` (count), and the detail for its type:

| Type | Assigned when | Detail kept |
|---|---|---|
| `date` | Date or date-time | min, max, the most common gap between consecutive distinct values |
| `flag` | Logical, or exactly two distinct non-missing values | the two values and their counts |
| `integer` | Whole numbers | min, max, quartiles |
| `number` | Other numeric | min, max, quartiles |
| `id` | Every non-missing value distinct, and the column is character or integer, and there are more than `CODEBOOK_MAX_LEVELS` rows | nothing but `distinct` |
| `category` | Character or factor with at most `CODEBOOK_MAX_LEVELS` distinct values | levels and counts, most common first |
| `text` | Any other character column | nothing but `distinct` |
| `ordered` | Never by R. Only the analyst sets it | levels in the analyst's order |

`CODEBOOK_MAX_LEVELS <- 30L`, a constant at the top of the file.

An `integer` column with 10 or fewer distinct values gets a note, "may be a coded category",
and is left as `integer`. Nothing is converted on a guess.

Default `role` from type: `number` and `integer` are `measure`; `category`, `flag` and `ordered`
are `group`; `date` is `time`; `id` is `id`; `text` is `text`. An `integer` column whose values
all lie between 1800 and 2100 and whose name contains "year" (any case) is `time`.

### B3. The codebook

`new_codebook(profile, file, rows)` builds the list that DESIGN.md section 5 shows. `label`
starts as the column name with `label_source: file`. `row_is` starts empty.

- `write_codebook(cb, path)` and `read_codebook(path)` use the yaml package. A codebook written
  and read back must be identical (`identical()`), and the smoke test checks it.
- `check_codebook(cb, profile)` compares an uploaded codebook with the file just read. It
  returns plain sentences: columns in one and not the other, and a type in the codebook that the
  data cannot be (for example `date` for a column of words). With any such sentence the codebook
  is not applied. Nothing is merged or guessed.
- `codebook_ready(cb)` is `TRUE` only when `row_is` is not blank.
- Facts (`name`, `missing`, `distinct`, ranges, levels and counts) always come from the profile
  of the file in hand, never from an uploaded codebook. From an uploaded codebook only `label`,
  `label_source`, `type`, `role`, the order of an `ordered` column's levels and `row_is` are
  taken.
- The analyst may change `type` only to one the data can be: `category` to `ordered` or `text`,
  `integer` to `category` (when it has at most `CODEBOOK_MAX_LEVELS` values) or `id`, `number`
  to nothing else, any type to role `ignore`. `type_choices(entry)` returns the allowed set.

### B4. What a model will be sent (built and tested now, used in Phase 3)

- `codebook_index(cb)`: one line per column: name, label, type, role, share missing.
- `codebook_detail(cb, columns)`: for at most 12 named columns, the detail of DESIGN.md
  section 4. For `id` and `text` columns, and for anything with more than
  `CODEBOOK_MAX_LEVELS` levels, only the count of distinct values. Asking for more than 12
  columns is an error.

Neither function ever takes the data as an argument: they read only the codebook, so a row
cannot reach a prompt through them.

## Part C: the tabs (`R/ui.R`, `app.R`)

State added to `new_state()`: `data`, `problems`, `profile`, `codebook`.

**Data tab.** A file input (the size limit stated beside it), then, once a file is read: the
file name, rows and columns, the `problems` sentences in a warning box (or "No problems found"),
and a plain table of the columns with type, share missing and distinct count. An optional second
file input takes a saved `codebook.yaml`; what `check_codebook()` says is shown, and the
codebook is applied only when it says nothing.

**Codebook tab.** Before a file is read, one line saying to start on Data.

- At the top: a text input, "What does one row represent?" (for example "one order", "one
  country in one year"), with a note that charts cannot be drawn until it is filled in.
- Then the columns, 25 to a page with Previous and Next, as rows of plain Shiny inputs: the name
  (fixed), a text input for the label, a select for the type (`type_choices()`), a select for
  the role, and the facts in small grey text (share missing, distinct count, range or levels,
  and the "may be a coded category" note). For an `ordered` column, a text input holding its
  levels separated by commas, in order; it is accepted only when it is exactly the column's
  levels.
- A label the analyst edits becomes `label_source: user`.
- A count above the list: how many labels are still the column name.
- "Download codebook.yaml".

Edits update `state$codebook` at once, and survive moving between pages and tabs.

Explore, Report and Methodology stay as they are.

## Part D: `tests/smoke.R`

Keep the seven Phase 0 checks. Add checks on these files:

- Three course files, read from
  `D:/repos/UMD_JPSM_coursework/Data_visualization_SURV752/assignments/` (`datasaurus-1.csv`,
  `FH_disaggregated.csv`, `footballdata-1.csv`). If the folder is not there, skip them and say
  so. Do not copy them into the repository.
- A wide file made by the test with a fixed seed: 300 rows, 200 columns of mixed types.
- A messy file made by the test: a blank header, a duplicated header, a column of numbers with
  some words in it, an all-missing column, a date column, a free-text column, an id column, a
  category with 45 levels, and an integer column coded 1 to 5. The free-text, id and 45-level
  columns each contain the planted string `SECRET_VALUE_123`.

For every file: it reads; the profile has one entry per column with a known type; the codebook
survives a write and read unchanged; `codebook_ready()` is `FALSE` until `row_is` is set.

For the messy file also: the two renames are reported; the all-missing column is reported; the
45-level column is `text`, the 1 to 5 column is `integer` with the note; `SECRET_VALUE_123`
appears nowhere in `codebook_index()` or in `codebook_detail()` for any columns; asking
`codebook_detail()` for 13 columns is an error; a codebook with one column renamed is refused by
`check_codebook()` with a sentence that names the column.

Show that the checks can fail, as you did in Phase 0.

## Verify before you report

- `Rscript --no-init-file tests/smoke.R` passes, from inside `chaRt/`.
- The app starts from the repository root with the command in the Phase 0 prompt.
- By hand, in the running app: upload `FH_disaggregated.csv`, edit two labels, set one type, fill
  in the row sentence, download the codebook, restart the app, upload the file and the codebook,
  and confirm the edits came back.
- `git status` is clean on `chart`; nothing outside `chaRt/` changed.

## Report back

1. Files changed, with line counts.
2. The smoke test's output.
3. The probe's table at home, with the new render check.
4. For `FH_disaggregated.csv`: the output of `codebook_index()` and of `codebook_detail()` for
   its first five columns, as text.
5. What you added to `launch.json` in Phase 0.
6. Everything you could not confirm, and every departure from this prompt and why.
