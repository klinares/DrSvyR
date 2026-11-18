# chaRt

chaRt is a Shiny app that turns a data file into publishable charts. It builds a codebook, proposes
and draws charts that follow written visualization rules, lets the analyst refine a chart by chat,
and writes an HTML report of the charts the analyst chose, each with a short summary. The data are
general, not survey microdata: every chart and summary describes the file, not a population.

Built so far: the skeleton, the key box, the connection check and the probe (Phase 0), the Data and
Codebook tabs (Phase 1), the renderer, which draws every chart family from a spec (Phase 2), and the
first model calls: labels proposed for the codebook, and charts proposed for a question on the
Explore tab (Phase 3). `DESIGN.md` is the whole design and `STATUS.md` says what is built.

## What is in this folder

| Path | What it is |
|---|---|
| `app.R` | The settings, the profiles, the packages check, the layout and the server |
| `R/llm.R` | From QuestionR: the session key, the model call, JSON repair, retry, the connection check and the key box |
| `R/data.R` | Read a delimited file, profile and type its columns, build, write, read and check `codebook.yaml`, and the column texts a model will be sent |
| `R/spec.R` | The plot spec: defaults, the check against the codebook, the table that is drawn, the lint, the ggplot, the plotly version, the R code that reproduces a chart, and its size. Every threshold is a constant at the top |
| `R/theme.R` | `chart_theme()`, the palettes an analyst may choose from (`CHART_PALETTES`), the highlight colours, and `chart_palette_default()`. The one file replaced at work |
| `R/reflexes.R` | Reads the reflex files, assembles every prompt, and makes the two calls: `label_columns()` and `suggest_charts()` |
| `R/ui.R` | The tab names, the shared helpers, the logo, Start here, the connection check, and the Data, Codebook and Explore tabs |
| `www/reflexes/` | The rules the model is given, one markdown file per topic, written in the Claude project and not edited here; `README.md` there gives the format |
| `tests/` | The smoke test, the live check and its page (`live_gallery.R`), the gold specs (`gold_specs.yaml`) and the gallery (`gallery.R`), at home. Not deployed |
| `probe/app.R` | A separate one-page app, published once at work to learn what the server can do |
| `DESIGN.md`, `STATUS.md` | The design, and where the build stands |

## Install and run

```r
install.packages(c("shiny", "bslib", "purrr", "digest", "dplyr", "ellmer", "ggplot2", "httr2", "jsonlite",
                   "plotly", "readr", "rlang", "S7", "scales", "tibble", "tidyr", "yaml"))
shiny::runApp("chaRt")
```

Built and tested with ellmer 0.4.2; the app stops at start-up, naming anything missing.

`paletteer` is optional (`install.packages("paletteer")`). Without it the app starts and offers
only the palettes that need no package: Okabe-Ito, viridis and a built-in blue-red. With it,
Paul Tol's, ColorBrewer's and the viridis family's palettes are offered too. A report uses one qualitative, one sequential and one diverging palette throughout;
the model never chooses colours. The code a chart comes with writes its colours in, so it runs
without paletteer.

## The profiles

Everything an administrator may change is in `app.R`, section 1: the classification banner, the
logo, the upload limit, the Source code link, `APP_DEFAULT_PROFILE` and `APP_PROFILES`. A profile is
one model: `api` (`"anthropic"`, or `"openai"` for the OpenAI style), `base_url` (up to and
including `/v1`) and `id`. The environment variable `CHART_PROFILE` chooses a profile; when it is not
set, `APP_DEFAULT_PROFILE` does.

| Profile | What it is |
|---|---|
| `home` | `claude-sonnet-5-5` on Anthropic's API |
| `work` | The office endpoint, OpenAI style. `<work base url>` and `<model id at work>` are placeholders to fill in at work; until then Start here says so and nothing is called |

## Data and Codebook

The Data tab reads a CSV or other delimited text file (readr guesses the delimiter). Blank cells
and `NA` are always missing. Any other value (`..`, `-99`) is missing only if the analyst lists it
under "Values that mean missing" and presses "Read again"; it must match a whole cell. Reading
again keeps the labels, roles and row sentence already entered. The file's encoding is guessed; a
file that is not UTF-8 is read as windows-1252, which is right for Western European files. If
names with accents look wrong (a Central European file), choose the encoding under "File encoding"
(UTF-8, windows-1252, ISO-8859-2 or ISO-8859-15) and press "Read again". A column that is mostly numbers
with a few words in it is reported. The tab lists the problems found and a table of the columns
with R's type for each.

The Codebook tab asks what one row represents (charts need it) and shows the columns, 25 to a
page, each with its label, type, role and facts. A type can only be changed to one the data can
be, and a role to one the type allows. "Download codebook.yaml" saves it, with the values that mean
missing and the encoding; uploading the same file with that codebook on the Data tab reads the file again with
those values and that encoding, and brings the labels, types, roles, level orders and row sentence back. A codebook that does not match
the file is refused with the reasons, and nothing is merged. Every fact (missing share, distinct
count, ranges, levels) comes from the file in hand, never from an uploaded codebook.

## Labels and charts from the model

Both calls need the key. The model is sent the codebook (file name, rows, what a row is, and each
column's name, label, type, role, missing share and summary), never the rows. Every reply is JSON
that R reads and checks; none is run as code.

**Suggest labels** (Codebook tab) asks for a label for every column, 60 columns to a call. A label
lands only where the label is still the file's own; it is marked "AI guess", and "check this" when
the model said it was not sure. Editing it, or ticking Accept, makes it yours; "Accept all AI
labels on this page" does that for the page. The model's guess at what one row is fills the row box
as a placeholder, with "Use this"; it is never set for you.

**Explore** asks for charts: type a question and press Draw, or press "Suggest charts for this
file". When more than 60 columns are in play the model first picks the 60 that bear on the
question. Each chart it proposes is checked by the renderer; if any is refused, the model gets one
chance to correct it, with the reasons, and what is still refused is listed under "Could not be
drawn". Each card shows the chart, the renderer's notes, what the model said, the rule it followed,
and buttons to add it to the report, to switch to the interactive view and to show the R code. The
three palette selects change the colours of every chart without a new call. The foot of the tab
counts the calls and tokens of the session.

The rules the model follows are the reflex files in `www/reflexes/`. They are read when the app
starts; a file that has lost its shape stops the app there, naming the file and the rule.

## The key

The key is pasted into the box on Start here and held for the session only, exactly as in
QuestionR. It is never saved, never written to a log, and never read from the environment: an
`ANTHROPIC_API_KEY` set in `.Renviron` is ignored by the app. Closing the tab discards it.

## Tests

From inside `chaRt/`:

```bash
Rscript --no-init-file tests/smoke.R       # no model calls
Rscript --no-init-file tests/llm_check.R   # live calls, at home; costs a little
Rscript --no-init-file tests/gallery.R     # writes tests/gallery.html (git-ignored); needs Quarto
Rscript --no-init-file tests/live_gallery.R   # rebuilds tests/live_gallery.html from the last live run; no calls
```

The smoke test loads the app the way Connect does and checks the rules for `R/`, the loops and the
key, and reads, profiles and round-trips the codebook of three course files (from
`D:/repos/UMD_JPSM_coursework/Data_visualization_SURV752/assignments/`, skipped when absent), a wide
file and a messy file it makes itself. It then draws every gold spec in `tests/gold_specs.yaml`:
the check, the table, the ggplot, the plotly version, and the code, which it runs in a separate R
process and compares with the table. It tests each lint rule and refuses a set of bad specs,
printing what each refusal said. It checks that every reflex file parses and has the checksum the
test holds (update `REFLEX_SHA` in `tests/smoke.R` when a file changes on purpose), that the
system prompts hold no Source, Label or comment text, that `spec_reference()` covers exactly what
`spec_check()` accepts, and runs both calls against stand-in replies. The gallery shows every gold spec as a page: its lint notes, the
static chart beside its plotly version at the same size, the first rows of its table, and its
code. The live check reads `ANTHROPIC_API_KEY` and
`OPENROUTER_API_KEY` from the environment (a test may; the app never does), pings the home model,
and asks for structured output in the Anthropic style and, through OpenRouter, in the OpenAI style
that stands in for the work endpoint. Its fourth check labels FH, football and a made-up panel
file and asks twelve questions of the suggest call (about 20 calls), printing what each call cost
and returned; it saves the replies to `tests/live_replies.rds` and writes `tests/live_gallery.html`
(both git-ignored). `CHART_LIVE_STEPS` chooses the checks (for example `1,4`). `CHART_TEST_MODEL`
replaces the home model for checks 1, 2 and 4 (Sonnet models only); `OPENROUTER_MODEL` replaces the
OpenRouter model.

Run the tests from PowerShell or the RStudio terminal, not Git Bash. Git Bash sets `HOME`, so R
looks for `.Renviron` in the wrong folder and the live check finds no key.

## The probe

`probe/app.R` needs only shiny, makes no model calls and needs no key. Publish it once at work:

```r
rsconnect::deployApp("chaRt/probe", appName = "chaRt-probe")
```

Open it, wait for the table to fill in, and copy the text under "Copy results". It reports the
versions of R and the packages chaRt needs, whether Quarto is found and renders two small documents
to self-contained HTML from inside the running app (one plain, one with an R chunk that draws a
ggplot and its plotly version), whether a PNG draws with Cairo, and whether `tempdir()` is writable.

## Publishing the app

```r
rsconnect::deployApp("chaRt", appName = "chaRt")
```

`.rscignore` keeps `tests/`, `build/`, `probe/` and the markdown files out of the bundle.
