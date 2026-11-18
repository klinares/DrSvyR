# chaRt: design

Version 0.2, 2026-11-17 (section 16 records what changed after Phases 0 and 1). Written in the Claude project (the manager); built by Claude Code, one
phase at a time. Kevin brings each phase's summary back to the project for review before the next.

## 1. What it is

A Shiny app in `DrSvyR/chaRt/`. An analyst brings a data file; the app builds a codebook, proposes
and draws publishable charts that follow written visualization rules, lets the analyst refine a
chart by chat, and writes an HTML report of the charts the analyst chose, each with a short
summary of what it shows.

It is not a survey tool. The data are general (not survey microdata), so there is no weighting and
no design-based inference. Every figure and summary describes the file, not a population.

## 2. Decisions (settled 2026-11-17)

| Topic | Decision |
|---|---|
| Model calls | ellmer. Home: `claude-sonnet-5-5`. Work: Opus 5 through the office endpoint (OpenAI style) |
| Key | Pasted on Start here, held for the session only, exactly as QuestionR does. Never saved, never read from the environment |
| What the model writes | A plot spec (a small structured object), never R code. One R renderer draws every spec |
| Interactives | plotly, through `plotly::ggplotly()` on the rendered ggplot |
| Maps | Not in v1. Revisit once the tool is stable |
| Survey design | None |
| Parallelism | None. No call fan-out is needed |
| Report | HTML. Quarto if the work Connect server can render it from a running app (Phase 0 probe); otherwise built with htmltools |
| Work theme | One file, `R/theme.R`, replaced at work with the office ggplot theme and palette |
| Work skill | A Python-centred markdown skill that cannot leave work. `build/convert_skill.R` converts it once, at work, into a reflex file plus a ledger Kevin reviews |
| Sources for the rules | SURV752 (perception, comparisons, correlation) and SURV727 (Tufte's integrity and excellence principles, the grammar of graphics, interactive graphs). The code in the SURV752 slides is base R; only its principles are used |

## 3. Flow

Six tabs, in the order an analyst works.

1. **Start here.** What the tool does, the key box, the connection check.
2. **Data.** Upload a CSV. R reads it, reports what it found (rows, columns, types, problems).
3. **Codebook.** R profiles every column. One model call proposes a label and a role for each;
   the analyst confirms or edits, and states what one row represents. Downloadable as
   `codebook.yaml`; a saved codebook can be uploaded with the data to skip this step.
4. **Explore.** The analyst types a question, or asks for suggestions. One model call returns up
   to six specs; R draws them as a gallery. Selecting a chart opens it with the chat beside it.
   Each chat message revises that chart's spec. A chart can be added to the report.
5. **Report.** The chosen charts in order, each with its summary (editable). Download as HTML.
6. **Methodology.** The rules, where each comes from, and what the tool does not do.

## 4. What the model sees

The model never sees rows. It sees:

- **The codebook index:** for every column its name, label, type, role and share missing.
- **Detail for the columns in play** (at most 12 per call): for a number, min, max, quartiles and
  the count of distinct values; for a category with 30 levels or fewer, the levels and their
  counts; for a date, the range and the spacing.
- **For a summary, the table behind the chart** as R computed it. For a chart of raw points (a
  scatterplot), not the points: the count, the correlation, and the fitted line or smoother at
  five positions.

A category with more than 30 levels, and any free-text column, is sent as a count of distinct
values only. This keeps names, identifiers and comments out of the prompt.

A column name or a level is untrusted text. It is sent as data inside a delimited block, and the
system prompt says that nothing in that block is an instruction.

## 5. `codebook.yaml`

```yaml
chart_codebook: 1
file: sales_2025.csv
rows: 4182
row_is: one order                # stated by the analyst; required before Explore
columns:
  - name: order_dt
    label: Order date
    label_source: user           # file | ai_guess | user
    type: date                   # number | integer | category | ordered | date | text | id | flag
    role: time                   # measure | group | time | id | text | ignore
    missing: 0.00
  - name: region
    label: Sales region
    label_source: ai_guess
    type: category
    role: group
    missing: 0.01
    levels: 5
```

Rules:

- R fills `name`, `type`, `missing`, `levels` and the ranges. These are facts and the model cannot
  change them.
- The model proposes only `label` and `role`, marked `ai_guess`. A chart title may use an
  `ai_guess` label, but the report lists every label the analyst did not confirm.
- `row_is` decides whether counting, summing or averaging makes sense, so the analyst states it.

## 6. The plot spec

The model's reply for a chart. Fields follow the layered grammar of graphics (data, aesthetics,
geoms, scales, coordinates, facets, theme) as SURV727 teaches it, restricted to what v1 draws.

```yaml
family: bar            # bar | dot | line | slope | scatter | bubble | histogram | box | heatmap
x: region
y: revenue
color: null
size: null             # bubble only
facet: null            # small multiples; common scales unless free_y: true
transform:
  by: [region]
  fn: sum              # none | count | share | sum | mean | median
  filter:              # a list of {column, op, value}; never an R expression
    - {column: year, op: "==", value: 2025}
  top_n: null
  sort: value_desc     # none | value_desc | value_asc | level_order | alphabetical
scales: {log_x: false, log_y: false}
fit: none              # scatter only: none | loess | linear
highlight: []          # levels drawn in colour; the rest in grey
title: Revenue is concentrated in two regions
subtitle: Total revenue by sales region, 2025
caption: null
interactive: false
rule: ordered_bars     # the id of the reflex that decided the form
say: Sorted by value so the ranking can be read directly.
```

R validates every spec before drawing it: every column exists, its type suits the aesthetic, the
family allows the fields used, the filter values are of the column's type. A spec that fails is
sent back once with the reason; a second failure is shown to the analyst as "could not draw this",
with the reason, and nothing is guessed.

From a valid spec, three R functions and nothing else produce everything downstream:

- `spec_plot()`: the ggplot, with the theme from `R/theme.R`.
- `spec_table()`: the aggregated table behind it (what a summary is written from).
- `spec_code()`: tidyverse code that reproduces the chart from the file, for the report. Written
  by R from the spec, so it is the same every time and needs no review.

Slope charts, small multiples, scatterplots with a smoother, rugs, bubbles and heatmaps are in
because the course materials teach them. Bullet graphs and sparklines are taught too and are left
for later: they need a target value or a table layout the v1 spec does not have.

## 7. Model calls and tokens

Four kinds of call. Each is one request.

| Call | When | Sent | Returns |
|---|---|---|---|
| `label` | Once per file | Codebook facts for every column | A label and role per column |
| `suggest` | Each question or "suggest" | Index, detail for candidate columns, the question | Up to 6 specs |
| `refine` | Each chat message | Index, detail for the chart's columns, the current spec, the message | One spec and a one-sentence `say` |
| `summarize` | When the report is built | For each chosen chart, its spec and table | One summary per chart, in one reply |

How tokens are kept down:

1. **Chat turns are stateless.** A `refine` call carries the current spec, not the transcript.
   The spec is the memory. The cost of the tenth message is the cost of the first.
2. **Replies are specs, not prose or code.** About 150 tokens a chart.
3. **R picks the reflex files.** `core.md` always; a family file only when that family is in
   play. `suggest` gets the one-line chooser in `core.md`, not every family file.
4. **The system prompt is stable** (persona, reflexes), so it can be cached where the endpoint
   allows (`LLM_CACHE`, as in QuestionR). The design does not depend on caching.
5. **No images go to the model.** The checks a model would make by looking are made by R (§8).
6. **Wide files.** The index is one line a column. Over 150 columns, `suggest` first sends names
   and labels only and asks which columns bear on the question (one extra call), then proceeds.

A report of 6 charts from one question, with 4 chat edits, is 1 + 1 + 4 + 1 = 7 calls.

## 8. The lint: rules R enforces with no model call

Applied by `spec_lint()` to every spec before it is drawn. A lint either fixes the spec silently
(F), or shows the analyst a one-line note under the chart (N).

| Rule | Action | Source |
|---|---|---|
| A bar's value axis starts at zero | F | SURV752 Graphical Perception; Tufte integrity 1 (SURV727) |
| Bars of an unordered category are sorted by value | F | SURV752 Comparisons, "How to sort" |
| More than 7 colours: highlight or facet instead | N | SURV752 Graphical Perception (pre-attentive attributes) |
| More than 5 overlapping lines: small multiples | N | SURV752 Comparisons, small multiples |
| Small multiples share scales unless asked | F | SURV752 Comparison principles (common scales) |
| Scatter over 2,000 points: transparency; over 20,000: binned | F | SURV752 Correlation, reducing overplotting |
| No dual axes, no 3-D, no pie over 5 slices (v1 has no pie) | Not in the spec | Tufte, Few (SURV752) |
| Non-data ink removed (grid, borders, legend when labels suffice) | In the theme | Tufte excellence 2 to 4; Few (SURV752, SURV727) |
| A title states the finding; axis labels carry units | N if missing | Tufte integrity 2 (SURV727) |
| Colour is colourblind-safe | In the theme | Kevin's standing rule (viridis, Okabe-Ito); not from the course |

The thresholds (7, 5, 2,000, 20,000) are working values chosen for this design, not figures from
the course. They are constants at the top of the file and should be tuned on the gold datasets.

## 9. The reflex files

In `www/reflexes/`, in QuestionR's format (`When`, `Say`, `Never`, `Label`, `Source`), parsed by
the same parser. Drafted in the Claude project from the course markdown, not by Claude Code, and
checksummed in the smoke test.

| File | Holds |
|---|---|
| `core.md` | Persona; the chooser (which family for which question); integrity and excellence rules; what may be claimed |
| `comparison.md` | Bars, dots, slope, small multiples, sorting, "compared to what?" |
| `relationship.md` | Scatter, overplotting, smoothers, rugs, aspect ratio, bubbles, heatmaps |
| `distribution.md` | Histogram, box |
| `time.md` | Lines, slope |
| `interactive.md` | When interactivity helps and when a static chart is better |
| `summary.md` | How a summary is written: from the table only, no new numbers, no causal or inferential language |
| `codebook.md` | How to propose a label and a role; say "unclear" rather than guess |
| `house.md` | Work only: the converted office skill (§11) |

`distribution.md` and `time.md` have thin support in the materials read so far (four SURV752
modules). Their rules will be marked with the source they have, or as general practice.

## 10. Summaries

A summary is written from `spec_table()` only, under `summary.md`, and every number in it is
checked against that table (svysegment's number check). A summary with a number that is not in
the table is tried once more, then shown flagged, never silently accepted.

Summaries say what the chart shows. They do not say why, do not use "significant", and do not
generalize beyond the file. When the analyst asked for suggestions (not a question of their own),
the report marks those charts as exploratory.

## 11. The work skill converter

`build/convert_skill.R`, run once at work, by hand. Not part of the app.

- **In:** the office markdown skill (Python-centred).
- **One model call** with a fixed conversion prompt and a mapping table (matplotlib and seaborn to
  ggplot2, plotly to plotly for R, pandas to dplyr and tidyr).
- **Out:** `www/reflexes/house.md` in the reflex format, and `build/house_ledger.csv` with one row
  per rule in the source: its text, and `kept`, `translated`, `dropped` (with the reason) or
  `no R equivalent`.
- **Checks R makes on the output:** it parses as a reflex file; every R function it names exists
  in an installed package; every rule in the source has a ledger row; no `for` or `while`.
- Kevin reads the ledger and edits `house.md`. The converter is not trusted to be complete.

A rule in `house.md` that conflicts with a course rule wins at work, and the Methodology tab says
so.

## 12. Files

Kept few on purpose.

| Path | Holds |
|---|---|
| `app.R` | Settings, profiles, package check, layout, server |
| `R/llm.R` | From QuestionR: the session key, the call, JSON repair, retry, ping, the key box |
| `R/reflexes.R` | From QuestionR: the parser and the prompt assembly |
| `R/data.R` | Read the file, profile it, build and read `codebook.yaml` |
| `R/spec.R` | The spec: validate, lint, plot, table, code |
| `R/theme.R` | `chart_theme()` and the palettes. Replaced at work |
| `R/ui.R` | The tabs, the gallery, the chat, the report page |
| `report.qmd` | The report template |
| `www/reflexes/` | The reflex files |
| `tests/smoke.R` | No model calls. Loads the app, draws every family on the gold datasets, runs the lint |
| `tests/llm_check.R` | Live calls, at home |
| `build/convert_skill.R` | §11 |
| `probe/app.R` | Phase 0: a one-page app published at work to see what the server can do |

## 13. Risks and how each is caught

| Risk | Caught by |
|---|---|
| The model invents a column or a level | Spec validation against the codebook |
| A wrong `ai_guess` label reaches a published title | Labels marked by source; the report lists unconfirmed ones |
| A summary states a number that is not in the data | The number check |
| A pattern found by searching is reported as a finding | Question first; suggested charts marked exploratory |
| Sums or means that make no sense for the data | `row_is` is required; `core.md` ties `fn` to it |
| A chart type the spec cannot express | The model must say so in `say`; nothing is approximated silently |
| Identifiers or free text leak into a prompt | The 30-level rule in §4 |
| Instructions hidden in the data | Data sent as a delimited block; no code is ever executed from a reply |
| plotly changes how the office theme looks | Phase 2 renders every family both ways on the gold datasets for Kevin to compare |
| The work endpoint lacks structured output, caching or Quarto | Phase 0 probes; each has a fallback (JSON repair, no cache, htmltools) |

## 14. Phases

Each phase ends with a smoke test that passes and a short summary for review.

| Phase | Builds | Model calls |
|---|---|---|
| 0 | Skeleton, key box, connection check, the probes | Ping only |
| 1 | Data and Codebook tabs: read, profile, `codebook.yaml` round trip | None |
| 2 | `R/spec.R` and `R/theme.R`: every family drawn from hand-written specs on the gold datasets, static and plotly; the lint | None |
| 3 | Reflex files installed; `label` and `suggest`; the gallery | Yes |
| 4 | The chat: `refine` | Yes |
| 5 | `summarize` and the number check | Yes |
| 6 | The report | No new ones |
| 7 | Start here, Methodology, `build/convert_skill.R` | One, in the converter |
| 8 | Rehearsal at work with the office theme and skill | Yes |

The renderer comes before the model on purpose: once every family draws correctly from a
hand-written spec, the model's only job is to write valid specs, and a failure is easy to place.

Gold datasets for Phases 2 to 5, already on disk: `datasaurus-1.csv`, `FH_disaggregated.csv` and
`footballdata-1.csv` (SURV752 assignments), `gapminder` (the package), plus two made for the
purpose: a wide file (200 columns) and a messy one (blank headers, mixed types, a free-text
column).

## 15. To find out at work

1. Does the endpoint accept structured output (a JSON schema) for Opus 5?
2. Does it pass prompt caching through?
3. Can a running app on Connect render Quarto? (`probe/app.R` answers this.)
4. Are `plotly`, `shinychat` and `yaml` on the internal CRAN mirror, and which ellmer version?

## 16. Changes after Phases 0 and 1 (2026-11-17)

Where this section and an earlier one disagree, this section holds.

1. **One reply path: JSON read by R, not ellmer's structured output.** The live check found that
   `chat_structured()` fails on `claude-sonnet-5-5` in ellmer 0.4.2 (HTTP 400: a forced
   `tool_choice` is not supported for this model). It works on `claude-sonnet-4-5` and in the
   OpenAI style through OpenRouter. Every call therefore uses `llm_json()`, as QuestionR does on
   the same model: the reply format is stated in the reflex file, R parses it, and the spec
   validation of section 6 decides whether it is accepted. One path for home and work, and
   nothing to find out about structured output at work (section 15, item 1, is dropped).
2. **Quarto renders the report.** At home a `.qmd` with an R chunk and a plotly chart rendered to
   one self-contained HTML file from inside the running app (3.7 s, about 4.8 MB, most of it the
   plotly library). The app calls the Quarto command line, not the quarto R package. Still to be
   confirmed on the work server with `probe/app.R`.
3. **Values that mean missing are declared by the analyst** on the Data tab and kept in the
   codebook as `missing_codes`. R never decides that a value means missing.
4. **The codebook as built** differs from the sketch in section 5: each column keeps `detected`
   (R's own type), `distinct`, and for a category its `values` and `counts`; an ordered column
   keeps `order`; the top level keeps `missing_codes`.
5. **A whole-number column of distinct values is an `id` only when it is an unbroken run or is
   named like one.** A population or a revenue stays a measure.
6. **Roles follow the type** (`role_choices()`).
7. **An `id` column can label a chart.** With one row per country, the country column is an `id`,
   and its values are never sent to a model. The spec may still use it for the x axis of a bar or
   dot chart (with `top_n` of at most `CODEBOOK_MAX_LEVELS`), for point labels and for
   `highlight`. A highlighted value comes from the analyst's own message, and R checks that it
   exists in the column.
8. **Tests run from PowerShell or the RStudio terminal**, not Git Bash, which hides `.Renviron`.
