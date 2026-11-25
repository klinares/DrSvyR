# chaRt

chaRt turns one data file into publishable charts and a dashboard page. You bring a delimited
text file (CSV, TSV or similar). chaRt builds a data dictionary for it, then you work in a chat
beside a canvas of charts: ask a question, change a chart in words, or press a button. Each chart
can have a headline and a short summary whose numbers R checks against the chart's own data. The
charts can be exported as a dashboard page, a codebook page and the R code that redraws every chart.

Every chart and every summary describes the file, not a population. The data are general, not
survey microdata.

## The five-minute path

1. **Start here.** Paste an API key into the key box and press "Use this key". "Check the
   connection" makes one very small call to confirm that it works.
2. **Data.** Choose the file. chaRt reads it, guesses a type and a role for each column and shows
   them in the data dictionary. Correct what is wrong, say what one row is (for example "one
   order"), and list any values that mean missing (for example `-99`), then press "Read again". The
   "Summary statistics" section under the dictionary needs no key and no model.
3. **Ask.** On Explore, press "Label the columns" in the chat (one model call that writes a label
   for every column, marked "AI guess"). Then type a question ("How has revenue changed by
   region?") or press "Suggest charts". A chart is drawn for each answer and added to the canvas.
4. **Choose.** Click a chart to select it and change it in words ("sort by value", "make it a
   line"). "Style" sets one of seven styles (Clean, Minimal, Magazine, Data desk, Newspaper, Dark, Briefing: an off-white ground, a hairline grid across the chart, condensed upper-case titles, one deep blue and slate greys) and
   the palettes for every chart. In every style a highlight is the style's accent against its slate grey, and R never colours the largest bar by itself. Beyond bars, lines, scatters, histograms, boxes and heatmaps there are a
   dumbbell (each group's two values, for exactly two periods or conditions, on one scale), a density view
   (a scatter of more than 2,000 points becomes counts of rows, in the style's own colours, by itself: hexagons 30 across when the `hexbin` package is installed, rectangles when it is not, and rectangles at the values of an axis that has at most 40 different values), a violin with its box
   (when you ask for the shape: filled lightly in the series colour, with the outlying rows as dots), lines indexed to 100 at their first period (to compare growth: all in one panel, the lines you highlight in the accent and the others in grey, named at their ends), a moving
   average over the raw line (when you ask for a trend), and call-outs: a marked point is a small box with a
   thin leader. A card can be shown as an interactive chart ("Interactive": the same chart as an SVG, with a tooltip and hover on each mark and no zoom) or a
   short video ("Animate"). "Write headlines" gives each chart a headline and a summary. The "In
   dashboard" switch and Move up and Move down on each card choose what goes in the dashboard and in
   what order. "Add a summary table" puts a table of descriptive statistics on the canvas.
5. **Export.** "Export dashboard" asks for a title, subtitle, author, date and introduction, a
   classification marking (it starts as the marking shown above every screen, `APP_CLASSIFICATION` in
   `app.R`; it cannot be blank and is at most 80 characters), up to three key numbers (a strip of at most six at the top of the page: each a small-capital label over its value, with the file's
   rows, columns and period), and for each
   chart a picture, an interactive chart or a video, each drawn for the size of its card (a card with a row to itself, on a wide screen, has the chart on the left and the text on the right; a video stands on its finished chart before it plays and after, with a Replay button). "Build the dashboard" makes
   `<marking>_dashboard_<date>.zip` (the marking in lower case with other characters as underscores,
   so `unclassified_dashboard_2026-11-22.zip`) with `dashboard.html` and `codebook.html` (each one
   file), `data_dictionary.yaml`, `charts.R` and a `charts/` folder (PNG at 300 dpi, SVG when
   svglite is installed, MP4 for a video, CSV for a table). Everything in it carries the marking: a
   red band at the top and the bottom of each page (and of every printed page), of each PNG and SVG
   and of every frame of each MP4, and a first line `# <marking>` in `charts.R`, the dictionary and
   each CSV (a program that reads a CSV must skip that one line: `readr::read_csv(file, skip = 1)`).
   The marking is yours to state: the app does not judge or change it, and it is never sent to the model.

The Methodology page says how a chart is chosen and drawn and where each rule comes from.

## Design: the model draws, R computes

Each card has **Design**, and the canvas has **Design all**. The chart appears at once in the rule-drawn form and stays the
fall-back: a design is a second drawing of the same table, made by the model following a **design skill** (a markdown file; the
Style dialog lists them with each one's Intent line, and has "Design new charts automatically", off at first, because a design
costs two to four model calls). R computes the spec, the plotted table and the facts as always. The model writes drawing code
for that table; R refuses code that calls anything outside a list of functions (`design_toolkit()`), runs what remains in an
environment that holds nothing else, and refuses a drawing that cuts a bar's zero, drops rows, adds a second axis, writes a
number that is not in the facts, or clips, overlaps or lowers the contrast of its text. A refusal is one sentence the model is
shown once. Then the model looks at the picture and either says it is fine or sends corrected code, which is checked in the same
way, at most twice. If anything fails the card keeps its standard drawing and says in one line why.

A designed card shows "Designed with <skill>", a switch between the designed and the standard drawing, and Code shows the
code the model wrote with the table it draws. In the chat, "design this", "redesign this", "make it look better" and "make it
publication ready" start a design with no chat call; a message that asks for a specific look ("put the legend inside", "make the
title bigger") goes to the design call as the analyst's WISH. The export carries the picture, the 300 dpi file, the code as part of
`charts.R` with the table beside it as a CSV so the script runs alone, and the classification marking on all of it. The interactive
view of a designed chart has tooltips when every layer of marks is one ggiraph has a twin for (bars, columns, points and tiles drawn from
their data as they are; not lines, counts, bins or fitted curves); otherwise the card offers the picture and the standard interactive view, labelled as such.

This is an allow-list interpreter, not a proven sandbox: see `DESIGN.md` section 19.

| Setting in `app.R` | What it is |
|---|---|
| `APP_DESIGN_IMAGES` | `"all"` (the default), `"aggregated"` or `"none"`: which pictures may be sent to the model for the review. |
| `APP_SKILLS_DIR` | A folder of the office's own design skills (markdown files of at most 120 lines: a title, `Version:`, an Intent section and a checklist for the review; see `www/skills/README.md`). `""` for none. They are read where the app runs. The text of an office skill goes to the model with a design call and is never written to a log, a report or an export. |

`ggrepel`, `ggtext`, `patchwork` and `forcats` are optional: a design may use their functions when they are installed, and
`app.R` names them in `requireNamespace()` calls so that a deployment asks Connect for them.

## What it will not do

- It does not apply survey weights or a sample design. Summary statistics and their 95% intervals
  assume a simple random sample of independent rows, and say so under every table.
- It runs code the model wrote only when you press Design, and then only under an allow-list of functions, with R
  checking the drawing (see "Design" below). Everywhere else the model returns a small structured specification;
  R checks it and draws every chart. The model does not choose colours: a designed chart uses the style's own colours and palette.
- It does not clean, reshape or join data. It reads one delimited text file of up to 50 MB.
- It does not test hypotheses or fit models. A chart can show a fitted line; that is a drawing, not
  a test.
- It does not need Quarto or pandoc, and it does not use X11. Charts are drawn with ragg, else R's
  cairo, else svglite.
- It keeps nothing between sessions. The file, the canvas and the key are gone when the tab closes;
  download the dictionary and the dashboard.

## The key rule

**The model never receives the rows of your file as text, and every number comes from R.**

- The model is sent the data dictionary (file name, row count, what a row is, and each column's name,
  label, type, role and share missing) and, for the columns in play, a summary: a number's range and
  quartiles, a category's levels and counts (30 levels or fewer), a date's range. A column of
  identifiers or free text is sent as a count of distinct values only. Writing a headline sends the
  numbers R computed for that chart's table, with names in identifier and text columns replaced by
  placeholders.
- **Design sends more, and says so.** When you press Design on a chart, the model is also sent the table the chart plots
  if that table is aggregated and has at most 60 rows (never rows of your file; the names in identifier and text columns
  are placeholders), the design skill you chose and the chart's facts. It then looks at the picture of the chart, to correct
  its own drawing. The picture of a scatter, bubble, box or violin chart shows individual rows as marks, so those rows can
  be read from it. `APP_DESIGN_IMAGES` in `app.R` limits this: `"all"` (the default) sends the picture of every chart that is
  designed, `"aggregated"` sends only pictures of charts drawn from aggregated tables, and `"none"` sends no picture (a
  design is then not reviewed by looking). Start here and the Methodology page say the same in the app.
- R computes every number. A headline, a summary or a chat answer that states a number is checked
  against what R computed; a failed text is sent back once and then shown flagged.
- A picture and a video in the exported dashboard hold no rows. An interactive chart holds the
  values of every row it plots (in its tooltips, to three significant digits, and in the drawing),
  and the export dialog says so beside the choice.

**The key.** The app reads the key only from the box on Start here. It is held in memory for the
session, never saved, never written to a log or to the exports, and never read from the
environment: an `ANTHROPIC_API_KEY` in `.Renviron` is ignored by the app. Only the test scripts in
`tests/` read the environment, and only at home.

## Run it here

Install the packages once. These are required (the app stops at start-up and names any that is
missing):

```r
install.packages(c("shiny", "bslib", "purrr", "commonmark", "digest", "dplyr", "ellmer", "ggiraph",
                   "ggplot2", "htmltools", "httr2", "jsonlite", "readr", "rlang", "S7", "scales",
                   "shinychat", "tibble", "tidyr", "yaml", "zip"))
```

These are optional and the app starts without them: `ragg` (the usual chart device), `svglite`
(SVG files in the export), `systemfonts` (the bundled typefaces), `paletteer` (more palettes) and
`av` (videos) and `hexbin` (the density view is hexagons with it and rectangles without; `install.packages("hexbin")`; a deployment asks Connect for it when it is installed where the app is published). Built and tested with ellmer 0.4.2 and R 4.6.

From the folder that holds `chaRt/` (the repository root), in R, RStudio or an R terminal:

```r
shiny::runApp("chaRt")
```

or from a shell: `Rscript -e "shiny::runApp('chaRt', launch.browser = TRUE)"`. Open the app, paste a
key on Start here, and go on to Data.

The model is chosen by a profile in `app.R` (section 1): `home` is `claude-sonnet-5-5` on
Anthropic's API; `work` is an OpenAI-style endpoint whose base URL and model id are placeholders to
fill in at work. The environment variable `CHART_PROFILE` picks one; without it `APP_DEFAULT_PROFILE`
(`home`) is used. The banner, logo, upload limit and Source code link are in the same section.

## Using your office's ggplot theme

If your office has a ggplot theme function, chaRt can use it as a chart style and make it the default. The file stays where it
is (on the work machine): it is read when the app starts and is never copied into this folder. Five settings at the top of `app.R`:

| Setting | What it is |
|---|---|
| `APP_THEME_FILE` | The path of the R file that defines the theme function. `""` (the default) means none. Keep the file outside `chaRt/`, so that it is not committed or published. |
| `APP_THEME_FUNCTION` | The name of the function in that file. It is called with no arguments and must return a ggplot theme. |
| `APP_THEME_NAME` | What the Style dialog calls the style (`"Office"`). |
| `APP_THEME_ACCENT` | The colour of a highlighted mark, which a theme cannot give. |
| `APP_THEME_SLATE` | The colour of the marks behind a highlight, which a theme cannot give either. |

When the app starts, it sources the file into an environment of its own and calls the function. It reads every element with
`ggplot2::calc_element()` and fills a style from it (`style_from_theme()` in `R/theme.R`), with your theme added last.
- **Code that comes with a chart:** it carries your theme's values as a plain `theme()` call, so it runs on a machine without
  the file.
- **When the theme can't be used:** a missing file, a syntax error or a wrong function name leaves the usual default style. The
  app still starts, and Start here says why in one sentence.
- **Missing fonts:** a font your theme names that this machine does not have is drawn in the default sans, and Start here
  names it.
- **Colours that fail the contrast checks:** they are listed on Start here as a warning.

Two stand-ins are in `tests/`, a light one and a dark one, to try the settings with. For example, set `APP_THEME_FILE` to
`"tests/theme_standin_light.R"` and `APP_THEME_FUNCTION` to `"theme_standin_light"`.

## Publish: the probe first, then the app

Both go to Posit Connect with `rsconnect`. Run these yourself at work; nothing here publishes.

1. **The probe** is a separate one-page app that needs only shiny, makes no model call and needs no
   key. It reports the server's R and package versions, whether Quarto is found, how a chart draws
   without X11 (ragg, cairo, svglite, and a font), and whether a short MP4 can be made (av,
   libx264, ten frames encoded, then 30 frames of 1280 by 720 drawn and encoded, with the seconds).
   Publish it, open it, wait for the tables to fill in, and copy the text under "Copy results":

   ```r
   rsconnect::deployApp("chaRt/probe", appName = "chaRt-probe")
   ```

2. **The app.** What goes up is decided by `.rscignore`: `app.R`, `R/` and `www/` (the reflex
   files, the typefaces and `methodology.md`) are in; `tests/`, `probe/`, `build/`, the notes
   (`README.md`, `DESIGN.md`, `STATUS.md`), the phase prompts, `manager/` and any `.Renviron` are
   out. `rsconnect::listDeploymentFiles("chaRt")` lists the bundle without publishing it, and
   `tests/smoke.R` checks that list. Then:

   ```r
   rsconnect::deployApp("chaRt", appName = "chaRt")
   ```

   Connect needs the packages above installed for it. Set `CHART_PROFILE` as an environment
   variable of the content if it should not use `home`. Users paste their own key on Start here.

## Tests

From inside `chaRt/`, in PowerShell or the RStudio terminal (not Git Bash). Neither of these makes
a model call, and they must be run one after the other, never together:

```
Rscript --no-init-file tests/smoke.R
$env:CHART_SMOKE = "heavy"; Rscript --no-init-file tests/smoke.R; Remove-Item Env:CHART_SMOKE
```

The first is the fast run and the second the heavy run (see `STATUS.md` for what is in each and how
long they take). `tests/llm_check.R` and `tests/live_run_9.R` make live model calls and need
`ANTHROPIC_API_KEY` in the environment.

## What is in this folder

| Path | What it is |
|---|---|
| `app.R` | Settings, profiles, the packages check, the page and the server |
| `R/data.R` | Reading a file, the data dictionary, summary statistics |
| `R/spec.R` | The chart spec, its checks, the ggplot, the interactive version (ggiraph), the R code of a chart, the video engine |
| `R/theme.R` | The typefaces, the seven styles, the palettes, the one chart device |
| `R/llm.R` | The session key, the model call, JSON repair, the connection check |
| `R/reflexes.R` | The prompts and the model calls (labels, chat, headlines, design) with their number and word checks, the design skills |
| `R/ui.R` | Every page, the canvas, the dashboard and codebook writers |
| `www/reflexes/` | The rules the model is given, one markdown file per topic, written outside this repository |
| `www/fonts/` | Inter, Source Serif 4 and Barlow Condensed (SemiBold and Bold: the Briefing style's titles), under the SIL Open Font License |

| `www/methodology.md` | The text of the Methodology page |
| `probe/app.R` | The probe |
| `tests/` | The smoke test, the live scripts, the gold specs, the sample file `tests/data/orders.csv`. Not deployed |
| `DESIGN.md`, `STATUS.md` | The design, and where the build stands |
