# chaRt

chaRt is a Shiny app that turns a data file into publishable charts. It builds a data dictionary,
then the analyst works in one chat beside the charts being built: ask a question, change a chart in
words, or press a button where typing is slower. The charts follow written visualization rules and
are drawn by one R renderer; each can have a headline and a short summary whose numbers R checks
against the chart's own data. The data are general, not survey microdata: every chart and summary
describes the file, not a population.

Built so far: the skeleton, the key box, the connection check and the probe (Phase 0), the Data page
and data dictionary (Phase 1), the renderer, which draws every chart family from a spec (Phase 2),
the model calls and their checks (Phases 3 to 5), and the chat-first screen: Explore is a chat on the
left and a canvas of charts on the right, every message going through one call, `chat_turn()`
(Phase 6). An HTML export of the canvas is a later phase. `DESIGN.md` is the whole design and
`STATUS.md` says what is built.

## What is in this folder

| Path | What it is |
|---|---|
| `app.R` | The settings, the profiles, the packages check, the layout and the server |
| `R/llm.R` | From QuestionR: the session key, the model call, JSON repair, retry, the connection check and the key box |
| `R/data.R` | Read a delimited file, profile and type its columns, build, write, read and check `data_dictionary.yaml`, and the column texts a model will be sent |
| `R/spec.R` | The plot spec: defaults, the check against the codebook, the table that is drawn, the lint, the ggplot, the plotly version, the R code that reproduces a chart, and its size. Every threshold is a constant at the top |
| `R/theme.R` | The typeface (`CHART_FONTS`, registered with systemfonts by `chart_fonts_register()` from `app.R`), the six styles (`CHART_STYLES`), `chart_theme()` and `chart_theme_calls()`, the palettes an analyst may choose from (`CHART_PALETTES`), the highlight colour, and `chart_palette_default()`. The one file replaced at work |
| `R/reflexes.R` | Reads the reflex files, assembles every prompt, and makes the three calls: `label_columns()`, `chat_turn()` (every chat message) and `summarize_charts()` (headlines and summaries), with the number and word checks |
| `R/ui.R` | The page (banner and navbar), the shared helpers, the logo, Start here, the connection check, the Data page (file, then data dictionary) and the Explore screen (chat and canvas) |
| `www/reflexes/` | The rules the model is given, one markdown file per topic, written in the Claude project and not edited here; `README.md` there gives the format |
| `www/fonts/` | Inter and Source Serif 4 (static TrueType: regular, semibold, bold) with their licence files, both under the SIL Open Font License 1.1. Registered at start-up and declared with `@font-face`; without them charts draw in the default fonts and Start here says so |
| `tests/` | The smoke test, the live check and its page (`live_gallery.R`), the gold specs (`gold_specs.yaml`) and the gallery (`gallery.R`), at home. Not deployed |
| `probe/app.R` | A separate one-page app, published once at work to learn what the server can do |
| `DESIGN.md`, `STATUS.md` | The design, and where the build stands |

## Install and run

```r
install.packages(c("shiny", "bslib", "purrr", "digest", "dplyr", "ellmer", "ggplot2", "htmltools", "httr2",
                   "jsonlite", "plotly", "readr", "rlang", "S7", "scales", "shinychat", "tibble", "tidyr", "yaml"))
shiny::runApp("chaRt")
```

Built and tested with ellmer 0.4.2; the app stops at start-up, naming anything missing.

`ragg` is optional too: with it, static charts are drawn with ragg, otherwise with the cairo device; either way at 192 pixels per inch, shown at their size in inches.

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

## The pages

The page is a navbar under the classification banner, with the logo, the title, the Source code link
and the dark-mode switch in the bar, and four pages: **Start here**, **Data**, **Explore** and
**Methodology** (a placeholder).

## Data and the data dictionary

The Data page reads a CSV or other delimited text file (readr guesses the delimiter). Blank cells
and `NA` are always missing. Any other value (`..`, `-99`) is missing only if the analyst lists it
under "Values that mean missing" and presses "Read again" (or presses "Treat '<value>' as missing"
in the Explore chat); it must match a whole cell. Reading again keeps the labels, roles and row
sentence already entered. The file's encoding is guessed; a file that is not UTF-8 is read as
windows-1252, which is right for Western European files. If names with accents look wrong (a Central
European file), choose the encoding under "File encoding" (UTF-8, windows-1252, ISO-8859-2 or
ISO-8859-15) and press "Read again". A column that is mostly numbers with a few words in it is
reported. The page lists the problems found and a table of the columns with R's type for each.

Under it, the data dictionary asks what one row represents (charts need it) and shows the columns, 25
to a page, each with its label, type, role and facts. A type can only be changed to one the data can
be, and a role to one the type allows. "Download data_dictionary.yaml" saves it, with the values that
mean missing and the encoding; uploading the same file with that file on the Data page reads the file
again with those values and that encoding, and brings the labels, types, roles, level orders and row
sentence back. A dictionary that does not match the file is refused with the reasons, and nothing is
merged. Every fact (missing share, distinct count, ranges, levels) comes from the file in hand, never
from an uploaded dictionary.

## Explore: the chat and the canvas

Explore needs a file and a data dictionary that says what one row represents. The chat (shinychat) is
on the left, about 38% of the width; the canvas is on the right; in a narrow window the chat stacks
above the canvas. The model is sent the data dictionary (file name, rows, what a row is, and each
column's name, label, type, role, missing share and summary), never the rows. Every reply is JSON
that R reads and checks; none is run as code.

**Setup, written by R in the chat with no model call** (except the one noted). When a file is read the
chat says "Read <file>: n rows, m columns." and the problems found. For a column that is mostly
numbers with a few words in it there is a button "Treat '<value>' as missing", which reads the file
again with it. "Label the columns" is one `label` call: a label for every column, marked "AI guess"
(and "check this" when the model was not sure), never over a label the analyst wrote; the chat says
how many, and links to the Data page. The model's guess at what one row is comes as a button "A row
is <guess>". When the dictionary is ready the chat says to ask a question or press Suggest charts.
The buttons are suggestions, drawn by shinychat as small cards; a click sends their text. R matches
those texts exactly and acts on one only while its button is on offer: a "Treat" text for a value the
file does not hold (or that is already treated) does nothing and says so, and an analyst's own message
that merely contains such a text ("why does it say Treat 'N/A' as missing?") goes to the model like any
other.

**Every other message is one call, `chat_turn()`.** The model is sent the data dictionary, a line for
each chart on the canvas (id, title, family, columns), the selected chart's id, spec and notes, the
last exchange (one turn back, the analyst's message and the reply's text, never R's setup lines), and
the message. It answers with exactly one of: `charts` (new charts, each checked by the renderer, one
repair call for any that fail, the rest listed as not drawn), `spec` (a change to the selected chart;
refused with a sentence when nothing is selected), `ask` (one question back), `cannot` (what the
chat cannot do) or `tell` (a few sentences about the file, whose numbers R checks against what it
sent), and may add up to three `next` suggestions of at most six words. Charts from the "Suggest
charts" button (the message "(suggest charts for this file)") are marked Exploratory. The system
prompt is the same on every turn.

**What reaches the chat is escaped.** shinychat 0.4.0 draws an assistant message as markdown with raw
HTML switched on and no sanitiser, and a span of class "suggestion" is a button that sends text as the
analyst. So text from the file (file name, column names in the problems, a value on a Treat button,
the row guess) and the model's words (say, ask, cannot, tell, next, a failed chart's title and
sentences, a headline check) go through `md_text()`: every punctuation mark is backslashed and `&`,
`<` and `>` become entities, so the reader sees the text as it was and no tag, link, image or button
can come out of it. A suggestion's text is escaped again as an attribute value.

**The canvas.** Three plain value boxes (rows, columns, and the period of the time column, else the
file name), then one card for each chart, two to a row, newest first. A card shows the headline when
there is one with the title under it, the static chart (full screen available), the renderer's notes
in small grey text, the summary, the rule's label and "Exploratory". Clicking a card, or its Select
button, selects it (an accent border; the chat's box then says "Change <title>, or ask something new");
clicking again, or Deselect, clears it. Each card has Undo (disabled with no history), Interactive
(the plotly version), Code (the R code that reproduces it, with a copy button), Edit text (the five
wording boxes, and the headline and summary when written, each with a one-line check and no model
call), Headline (one call for this chart) and Remove. "Style" opens the three palette selects; no call
is made. Under the chat, "Suggest charts" and "Write headlines" are always there; while a call runs
they and every Headline button are disabled. "Write headlines" sends only the charts that have none
or whose text is out of date.

**A headline and summary** are written by one `summarize` call from facts R computes from the chart's
table (the model never sees rows, and names in id or text columns are sent as tokens). R checks every
number and the forbidden words; a reply that fails is sent back once with the problems. The text is
marked "changed since this was written" when the chart's spec is no longer the one it was written for
(Undo back to that spec clears it), or when the data is no longer the data it was written from: reading
the same file again with different missing values keeps the canvas, draws the charts again from the new
data and marks every text. A different file clears the canvas and starts the chat again.

The foot of the screen counts the calls and tokens of the session. The rules the model follows are the
reflex files in `www/reflexes/`. They are read when the app starts; a file that has lost its shape
stops the app there, naming the file and the rule.

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
key, and reads, profiles and round-trips the data dictionary of three course files (from
`D:/repos/UMD_JPSM_coursework/Data_visualization_SURV752/assignments/`, skipped when absent), a wide
file and a messy file it makes itself. It then draws every gold spec in `tests/gold_specs.yaml`:
the check, the table, the ggplot, the plotly version, and the code, which it runs in a separate R
process and compares with the table. It tests each lint rule and refuses a set of bad specs,
printing what each refusal said. It checks that every reflex file parses and has the checksum the
test holds (update `REFLEX_SHA` in `tests/smoke.R` when a file changes on purpose), that the
system prompts hold no Source, Label or comment text, and that `spec_reference()` covers exactly what
`spec_check()` accepts. It runs `chat_turn()` against stand-in replies, one check for each kind of
reply and each failure (a spec with nothing selected, a tell with a number that is not in DATA, a
seven-word `next`, the suggestion message marking charts exploratory, two kinds in one reply), the
chat message for the messy file (no value in it, only names on the canvas, one exchange back, the
analyst's message outside every block) and the system prompt being the same on every turn. It runs
the Explore screen through `shiny::testServer()` with a stand-in model: the setup buttons, a question
adding cards, selecting then changing a chart, Undo, Remove, Edit text, Write headlines, a changed
chart being marked, and (Phase 6 D) what is escaped on its way to the chat, setup texts matched
exactly, and a data change marking the texts. What `testServer()` cannot do (a click in the browser,
the buttons being disabled during a call, how the screen looks) is not tested there. The gallery shows
every gold spec as a page: its lint notes, the static chart beside its plotly version at the same size,
the first rows of its table, and its code.

The live check reads `ANTHROPIC_API_KEY` and `OPENROUTER_API_KEY` from the environment (a test may;
the app never does). Step 1 pings the home model, steps 2 and 3 ask for structured output in the
Anthropic style and, through OpenRouter, in the OpenAI style that stands in for the work endpoint.
Step 7 asks for headlines and summaries of ten hand-written charts on three files (two calls and any
repairs) and shows them on `tests/live_gallery.html` under "Phase 5". Step 8 (Phase 6) reads
`tests/data/orders.csv` (3,000 synthetic orders, 22 columns; `-99` and `N/A` mean missing; a row is
one order), makes one label call, sends twelve messages through `chat_turn()` as an analyst would
(selecting and deselecting a chart as the plan says), then asks for a headline and summary for every
chart on the canvas. It counts its calls and stops at 24, and prints for each turn the seconds, fresh
and cached tokens, the kind of reply, repairs, the text, `next` and the specs as YAML, then each
headline and summary with its check result and the totals. Each call prints its input tokens read
fresh and from the prompt cache. Steps 7 and 8 save to `tests/live_replies.rds` and write
`tests/live_gallery.html` (both git-ignored). `CHART_LIVE_STEPS` chooses the steps (default `1,2,3`;
for example `1,8`). `CHART_TEST_MODEL` replaces the home model for steps 1 and 2 (Sonnet models only);
`OPENROUTER_MODEL` replaces the OpenRouter model.

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
