# chaRt, Phase 2: the renderer (no model calls)

Every chart family drawn from hand-written specs, with the lint, the theme, the plotly version
and the code that reproduces each chart. When this phase is done, the only thing a model will
ever have to do is write a valid spec.

## Read first

`CLAUDE.md`; `chaRt/DESIGN.md` sections 6, 8 and 16; `chaRt/STATUS.md`; `chaRt/R/data.R`.

Where this prompt and DESIGN.md section 6 differ, this prompt holds. DESIGN.md is brought up to
date in the Claude project after the phase.

## Rules

- Branch `chart`, small commits, no push, nothing outside `chaRt/`, no file outside the
  repository, no model calls. Run tests from PowerShell.
- R style as before: native pipe, no `for`, `while`, `repeat`, `pkg::fn()` in `R/`, `=` inside
  function bodies. `R/` holds function definitions and constants only.
- Confirm every function and argument in the installed package before using it, and list what
  you could not confirm. This matters most for plotly and for ggplot2 4.0.
- New packages allowed: `ggplot2`, `dplyr`, `tidyr`, `scales`, `plotly`, `base64enc` only if
  needed for the gallery. No ggrepel, no forcats, no patchwork.
- New files allowed: `R/spec.R`, `R/theme.R`, `tests/gold_specs.yaml`, `tests/gallery.R`.
  `tests/gallery.html` is written by the gallery script and is git-ignored. The app's tabs do
  not change in this phase.
- Every threshold is a named constant at the top of `R/spec.R`.
- No em-dashes in prose.

## 1. The spec

A spec is a named list (it will arrive as JSON). Flat, no nesting except `filter` and
`highlight`. Any field not listed here is an error.

| Field | Value | Default |
|---|---|---|
| `family` | `bar`, `dot`, `line`, `slope`, `scatter`, `bubble`, `histogram`, `box`, `heatmap` | required |
| `x`, `y` | column names | by family |
| `color` | column name | none |
| `size` | column name (`bubble` only) | none |
| `facet` | column name | none |
| `fn` | `none`, `count`, `share`, `sum`, `mean`, `median` | by family |
| `filter` | list of `{column, op, value}`; `op` is `==`, `!=`, `>`, `>=`, `<`, `<=` or `in` | none |
| `top_n` | whole number, 1 to `SPEC_TOP_MAX` (30) | none |
| `sort` | `value_desc`, `value_asc`, `level_order`, `alphabetical` | by family |
| `log_x`, `log_y` | true or false | false |
| `fit` | `none`, `loess`, `linear` (`scatter`, `bubble`) | `none` |
| `rug` | true or false (`scatter`) | false |
| `bins` | whole number, 5 to 60 (`histogram`) | R chooses |
| `free_y` | true or false (with `facet`) | false |
| `highlight` | `{column, values}` | none |
| `title`, `subtitle`, `caption`, `x_label`, `y_label` | text | labels from the codebook |
| `interactive` | true or false | false |
| `rule`, `say` | text; carried, not used by the renderer | none |

"Group-like" below means type `category`, `ordered`, `flag`, or an `integer` with at most
`CODEBOOK_MAX_LEVELS` distinct values. "Name-like" means type `id` or `text`: allowed where
stated, and only together with `top_n` (or a filter that leaves at most `SPEC_TOP_MAX` values).
"Measure" means type `number` or `integer`. "Time" means type `date`, or role `time`.
A column with role `ignore` cannot be used at all.

| Family | x | y | Other | fn |
|---|---|---|---|---|
| `bar` | group-like or name-like | measure, or none with `count` or `share` | `color` group-like, at most `SPEC_BAR_GROUPS` (4) levels | default `count` without y, else required |
| `dot` | as `bar` | as `bar` | `color` group-like, at most 4 levels | as `bar` |
| `line` | time | measure | `color` group-like or name-like | required |
| `slope` | time or group-like, with exactly two values after the filter | measure | `color` required: group-like or name-like, the thing each line follows | required |
| `scatter` | measure | measure | `color` group-like | must be `none` |
| `bubble` | measure | measure | `size` measure, required; `color` group-like | must be `none` |
| `histogram` | measure | none | | must be `none` |
| `box` | group-like, at most `SPEC_BOX_GROUPS` (12) levels | measure | | must be `none` |
| `heatmap` | group-like or time | group-like | `color` is the measure filled in; without it, the fill is the count | `count` without `color`, else required and not `none` |

`facet` is group-like, at most `SPEC_FACET_MAX` (16) panels, for every family but `slope`.

With `fn: none` in `bar`, `dot`, `line` or `slope`, each combination of x, color and facet must
have exactly one row after the filter. If not, that is an error whose sentence says to choose a
function. `share` is the share of rows, within a facet when there is one.

`top_n` keeps the n largest by the plotted value: the x values for `bar` and `dot`, the color
values for `line` and `slope`. Nothing is lumped into "Other". The chart's subtitle gains
"Top n of N" when the analyst gave no subtitle.

`highlight`: the named values are drawn in the highlight colour and labelled; everything else
is grey. Its column is the x column for `bar` and `dot`, the color column for `line` and
`slope`, and any name-like or group-like column for `scatter` and `bubble`. A value that is not
in the column after the filter is an error naming it.

Rows with a missing value in any column the spec uses are left out, and the count is kept.

## 2. `R/spec.R`

- `spec_defaults(spec)`: fills the defaults above. Nothing else.
- `spec_check(spec, cb)`: the reasons a spec cannot be drawn, as plain sentences that name the
  field and the column; an empty vector when it can. It reads only the codebook. Every rule in
  section 1 that does not need the data is checked here.
- `spec_table(spec, data, cb)`: the table that is drawn, after the filter, the missing-row
  removal, the aggregation, `top_n` and the sort. Attributes: `rows_used`, `rows_dropped`,
  `groups_total` (N in "Top n of N"). The rules that need the data (one row per combination, two
  values for a slope, panel and level limits after the filter, highlight values present) are
  checked here and raise an error of class `spec_error` with one plain sentence.
- `spec_lint(spec, cb, table)`: returns `list(spec, notes)`. Fixes (F) change the spec
  silently; notes (N) are one-line sentences for the analyst.

  | Rule | Action |
  |---|---|
  | `bar`: the value axis starts at zero; `log` on the value axis is removed | F, and N when a log scale was removed |
  | `bar`, `dot`: an unordered x is sorted `value_desc` unless the spec gave a sort; an `ordered` x is `level_order` | F |
  | `bar`, `dot`, `box`: drawn sideways when there are more than `SPEC_FLIP_BARS` (8) or any label is longer than `SPEC_FLIP_CHARS` (12) | F |
  | More than `SPEC_COLOURS` (7) colours | N: highlight or facet |
  | `line`: more than `SPEC_LINES` (5) lines with no highlight and no facet | N: small multiples or a highlight |
  | `facet`: common scales unless `free_y` | F |
  | `scatter`, `bubble`: over `SPEC_ALPHA_N` (2000) rows the points are transparent; over `SPEC_BIN_N` (20000) the chart is binned counts | F, with N |
  | `interactive` with more than `SPEC_WIDGET_N` (5000) marks | F to false, with N |
  | No `title` | N |
  | Rows left out for missing values | N: "k of n rows left out: missing values" |

- `spec_plot(spec, data, cb)`: the ggplot. Runs defaults, check, table and lint itself, so one
  call is enough; `attr(, "notes")` carries the lint notes. Axis titles are the codebook labels
  unless the spec gives them. Direct labels use `geom_text(check_overlap = TRUE)`.
- `spec_widget(plot)`: `plotly::ggplotly()` of it, with a tooltip of the plotted values and the
  mode bar reduced to the download button if the installed plotly allows that.
- `spec_code(spec, cb, file)`: one string of R code that reads `file` (with the codebook's
  `missing_codes`), builds the same table with dplyr and tidyr, and draws the same chart with
  ggplot2, ending `+ chart_theme()`. Native pipe, no loops, `library()` calls at the top,
  written the way a person would write it: no helper from this app except `chart_theme()`, and
  no step that does nothing. It is generated from the validated spec only; column names and
  values are written as quoted strings or backticked names, never pasted in raw.
- `spec_size(spec, table)`: width and height in inches for a static figure: 7 by 4.5, taller
  for sideways bars with many rows and for facets.

## 3. `R/theme.R`

The file Kevin replaces at work, so keep it small and self-contained: it may use ggplot2 and
grDevices and nothing from the rest of the app.

- `chart_theme(base_size = 12)`: a minimal theme with high data-ink: no panel border, no minor
  grid, a light major grid only along the value axis, title left-aligned and bold, legend on top
  and absent when direct labels carry it.
- `chart_palette(n)`: the Okabe-Ito colours for up to 8 groups (confirm how the installed R
  provides them); more than 8 is an error, since the lint should have spoken first.
- `chart_fill_scale()` and `chart_colour_scale()`: viridis for a continuous fill or colour.
- `CHART_HIGHLIGHT` and `CHART_GREY`: the two colours a highlight uses.

## 4. Gold specs and tests

`tests/gold_specs.yaml`: a list of entries, each with `name`, `file`, `missing` (codes, may be
empty), `row_is`, and `spec`. At least these, and at least two per family:

- **datasaurus-1.csv:** scatter of x and y faceted by dataset (13 panels); the same for one
  dataset with a linear fit.
- **FH_disaggregated.csv, missing `..`:** bar of the 10 highest `pr_2014` by `Country`
  (`fn: none`, name-like x); dot of the same for `cl_2014`; scatter of `pr_2014` against
  `cl_2014` with a loess fit and three countries highlighted; histogram of `pr_2014`.
- **footballdata-1.csv:** bar of the count by `Position`; bar of the 10 most common
  `Nationality` (name-like, `top_n`); box of `Height` by `Position`; scatter of `Height`
  against `Weight` coloured by `Foot` with a rug; heatmap of `Position` by `Foot`; histogram of
  `Age` faceted by `League`.
- **panel.csv, made by the test with a fixed seed:** 8 regions by 10 years, with `revenue`,
  `units` and `price`. Line of revenue by year coloured by region (8 lines, so the lint
  speaks); the same with two regions highlighted; the same faceted; slope of revenue, first
  year against last, by region; bubble of price against units sized by revenue for the last
  year; heatmap of region by year filled with mean price; bar of total revenue by region with
  `interactive: true`.

Add to `tests/smoke.R` (keep all 52):

- Every gold spec: `spec_check()` is empty; `spec_table()` has rows; `spec_plot()` builds and
  `ggplot2::ggplot_build()` runs without error or warning; `spec_widget()` returns an
  htmlwidget; the warnings `ggplotly()` gives, if any, are collected and printed, not hidden.
- Every gold spec: the code from `spec_code()` parses, runs in a fresh environment that has
  only `chart_theme()`, contains no `for`, `while` or `repeat`, and produces a table equal
  (`all.equal`) to `spec_table()`.
- The lint: one check per row of the table in section 2, each on a spec made to trigger it.
- Bad specs, each refused with a sentence that names the fault: an unknown field; an unknown
  family; a column not in the codebook; a column with role `ignore`; a text column on a `bar`
  with no `top_n`; a measure as the x of a `bar`; `fn: none` where groups repeat; `fn: mean` on
  a `scatter`; a `slope` whose x has three values; a `bubble` with no `size`; a filter comparing
  a number column with a word; a `facet` with more panels than the limit; a highlight value
  that is not in the column; `top_n` of 0 and of 31.
- The messy file: a chart using the id column as a name-like x with `top_n` draws, and
  `SECRET_VALUE_123` appears nowhere in `spec_check()` messages for any bad spec on that file.

Show that the checks can fail.

## 5. `tests/gallery.R`

Writes `tests/gallery.html`: one self-contained page, rendered with the Quarto command line as
`probe/app.R` does, with one section per gold spec: its name; the lint notes; the static chart
at `spec_size()`; the plotly version beside or below it; the first 10 rows of `spec_table()`;
the code from `spec_code()`. This page is how Kevin judges the charts and whether plotly keeps
the theme, so make the static and the plotly versions easy to compare.

## Order of work

Commit after each: (1) `R/theme.R`; (2) defaults, check and table, with their tests; (3) the
plot for each family; (4) the lint; (5) the code; (6) the widget; (7) the gallery.

## Report back

1. Files changed, with line counts.
2. The smoke test's output.
3. Every sentence the bad specs produced.
4. Every warning `ggplotly()` gave, by family, and anything in the gallery where the plotly
   version differs visibly from the static one.
5. The output of `spec_code()` for three specs: the FH top-10 bar, the football scatter, and the
   panel slope.
6. Any rule in section 1 that turned out to be ambiguous or wrong when you built it, and what
   you did. Do not quietly pick a reading: say which you picked.
7. Everything you could not confirm, and every departure from this prompt and why.
