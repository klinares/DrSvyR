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
   line"). "Style" sets one of six styles (Clean, Minimal, Magazine, Data desk, Newspaper, Dark) and
   the palettes for every chart. A card can be shown as an interactive chart ("Interactive") or a
   short video ("Animate"). "Write headlines" gives each chart a headline and a summary. The "In
   dashboard" switch and Move up and Move down on each card choose what goes in the dashboard and in
   what order. "Add a summary table" puts a table of descriptive statistics on the canvas.
5. **Export.** "Export dashboard" asks for a title, subtitle, author, date and introduction, up to
   three key numbers, and for each chart a picture, an interactive chart or a video. "Build the
   dashboard" makes `dashboard_<date>.zip` with `dashboard.html` and `codebook.html` (each one
   file), `data_dictionary.yaml`, `charts.R` and a `charts/` folder (PNG at 300 dpi, SVG when
   svglite is installed, MP4 for a video, CSV for a table).

The Methodology page says how a chart is chosen and drawn and where each rule comes from.

## What it will not do

- It does not apply survey weights or a sample design. Summary statistics and their 95% intervals
  assume a simple random sample of independent rows, and say so under every table.
- It does not run anything the model writes. The model returns a small structured specification;
  R checks it and draws every chart. The model does not choose colours.
- It does not clean, reshape or join data. It reads one delimited text file of up to 50 MB.
- It does not test hypotheses or fit models. A chart can show a fitted line; that is a drawing, not
  a test.
- It does not need Quarto or pandoc, and it does not use X11. Charts are drawn with ragg, else R's
  cairo, else svglite.
- It keeps nothing between sessions. The file, the canvas and the key are gone when the tab closes;
  download the dictionary and the dashboard.

## The key rule

**The model never sees the rows, and every number comes from R.**

- The model is sent the data dictionary (file name, row count, what a row is, and each column's name,
  label, type, role and share missing) and, for the columns in play, a summary: a number's range and
  quartiles, a category's levels and counts (30 levels or fewer), a date's range. A column of
  identifiers or free text is sent as a count of distinct values only. Writing a headline sends the
  numbers R computed for that chart's table, with names in identifier and text columns replaced by
  placeholders.
- R computes every number. A headline, a summary or a chat answer that states a number is checked
  against what R computed; a failed text is sent back once and then shown flagged.
- A picture and a video in the exported dashboard hold no rows. An interactive chart holds the
  values of every row it plots, and the export dialog says so beside the choice.

**The key.** The app reads the key only from the box on Start here. It is held in memory for the
session, never saved, never written to a log or to the exports, and never read from the
environment: an `ANTHROPIC_API_KEY` in `.Renviron` is ignored by the app. Only the test scripts in
`tests/` read the environment, and only at home.

## Run it here

Install the packages once. These are required (the app stops at start-up and names any that is
missing):

```r
install.packages(c("shiny", "bslib", "purrr", "commonmark", "digest", "dplyr", "ellmer", "ggplot2",
                   "htmltools", "httr2", "jsonlite", "plotly", "readr", "rlang", "S7", "scales",
                   "shinychat", "tibble", "tidyr", "yaml", "zip"))
```

These are optional and the app starts without them: `ragg` (the usual chart device), `svglite`
(SVG files in the export), `systemfonts` (the bundled typefaces), `paletteer` (more palettes) and
`av` (videos). Built and tested with ellmer 0.4.2 and R 4.6.

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
| `R/spec.R` | The chart spec, its checks, the ggplot, the plotly version, the R code of a chart, the video engine |
| `R/theme.R` | The typefaces, the six styles, the palettes, the one chart device |
| `R/llm.R` | The session key, the model call, JSON repair, the connection check |
| `R/reflexes.R` | The prompts and the three model calls (labels, chat, headlines) with their number and word checks |
| `R/ui.R` | Every page, the canvas, the dashboard and codebook writers |
| `www/reflexes/` | The rules the model is given, one markdown file per topic, written outside this repository |
| `www/fonts/` | Inter and Source Serif 4, under the SIL Open Font License |
| `www/methodology.md` | The text of the Methodology page |
| `probe/app.R` | The probe |
| `tests/` | The smoke test, the live scripts, the gold specs, the sample file `tests/data/orders.csv`. Not deployed |
| `DESIGN.md`, `STATUS.md` | The design, and where the build stands |
