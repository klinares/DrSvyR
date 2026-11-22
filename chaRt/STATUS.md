# chaRt: status

## Current state (2026-11-22, end of Phase 9)

Branch `chart`, not pushed. Everything below was built and tested at home on R 4.6.1. No test makes a model call unless it says so. The phase-by-phase record is under History.

**Phase 9 in brief** (report: `manager/done-9.md`). Parts A to D done: the exported dashboard and codebook look like published pages (centred, no hole in the grid, readable chart text, a page in the chosen style), charts animate to MP4, summary statistics (Data page, canvas, export), and a closing pass (probe Video table, deploy check without deploying, README, this file). Smoke: fast 488 of 488 (6.1 minutes), heavy 19 of 19 (7.0 minutes). **Not done: the live run** (`tests/live_run_9.R`), because no key was available; so no dashboard with real model headlines has been seen.

**What works**
- **Data page.** Reads a delimited file (csv, tsv, txt, tab; up to 50 MB; encoding guessed or chosen), types and roles every column, applies the missing codes the analyst lists, and writes `data_dictionary.yaml` (also read back). "Summary statistics" under the dictionary (`summary_table()` in R/data.R): one row per column, an optional "By group", 95% intervals that assume a simple random sample (t for a mean, Wilson for a share), a CSV; no key and no model.
- **Explore.** A chat and a canvas. Every message goes through one call, `chat_turn()`; the model answers with a small JSON spec that R checks and draws, never code. "Label the columns" is one call; "Suggest charts" and "Write headlines" are buttons. Some messages are answered by R alone (animate, summary table, "Treat -99 as missing"). Cards: Select, Undo, Interactive, Code, Edit text, Headline, Animate, "In dashboard", Move, Remove. A table card shows summary statistics.
- **The renderer** (R/spec.R, R/theme.R). Ten chart families, a lint, six styles (Clean, Minimal, Magazine, Data desk, Newspaper, Dark), palettes (paletteer optional), every text measured to fit its panel, one device chosen in one place (`chart_device()`: ragg, else cairo, else svglite; no X11, no Quarto, no pandoc).
- **Headlines and summaries.** Written from facts R computes; every number and word is checked, a failed text is sent back once, and a text is marked when its chart or data changed.
- **Video.** `spec_video()` draws frames with our renderer and encodes an MP4 with `av` (3 s of motion, 0.6 s of labels, 2 s hold, scales pinned; the last frame equals the static chart). Hidden where `av` is missing.
- **Export.** `build_dashboard()` writes `dashboard_<date>.zip`: `dashboard.html` and `codebook.html` (single files, in the chosen style, centred, print-safe, a phone layout), `data_dictionary.yaml`, `charts.R`, `charts/` (PNG 300 dpi, SVG, MP4, table CSV). Each chart is a picture, an interactive chart (plotly, with its rows) or a video; up to three key numbers; table cards are real tables.
- **Methodology page** (from `www/methodology.md`, which is not edited here) and the **probe** (`probe/app.R`): the checks table, Graphics (devices, a font, three drawn charts) and Video (av, libx264, ten frames encoded, 30 frames of 1280 by 720 drawn and encoded, with seconds).
- **The bundle** (`.rscignore`, checked by 9C-7 to 9C-10): `app.R`, `R/`, `www/` only: 28 files, 2.6 MB: the six typefaces 2.0 MB, `R/` 0.6 MB, the reflex files and methodology.md under 0.1 MB. rsconnect would ask Connect for 95 packages (av, zip, commonmark, svglite, ragg, plotly, paletteer among them; ggiraph is not used). Loads alone as an app (9C-9).

**What is not verified**
- The probe has not been run on the work server, nor has the app been published anywhere. Open: whether Connect's `av` has libx264, whether ragg, svglite and systemfonts are installed there, the time a five-video dashboard takes (68 s here), and the memory of a session.
- The `work` profile has placeholders for its base URL and model id (`app.R`); the app has only ever called `claude-sonnet-5-5` on Anthropic's API. The last live runs were Phase 7b; the live run of Part C (`tests/live_run_9.R`: label, three questions, headlines, a Magazine dashboard of a picture, an interactive chart and a video) has NOT been made, because no key was available to the worker; its export step was run with stand-in charts and headlines (`CHART_LIVE_DRY=1`, no call) and the page looked at in Chrome at 1280 and 500 px.
- Not seen: the working line during a long call with a screen reader, Excel opening the summary CSV (UTF-8 with a byte-order mark, a `note` column), a printer.

**Known limits**
- Statistics use a simple random sample, three significant digits on screen (six in the CSV), and no weights or design. A mean of a scale treats its steps as equal, and says so.
- On a dashboard page a video shows its first frame (empty axes), not its poster, until it scrolls into view (`preload="auto"`); a `preload` change was tried once and not confirmed.
- A video has no phone drawing (its text is small below 600 px), takes a row of the page when drawn on a wide canvas, and its chart carries no rows. An interactive chart carries every plotted row.
- The Dark style's bubble size legend has black keys on a dark ground. A line chart's plotly version has tick labels that touch at card width.
- On a phone the Data page's file table scrolls sideways by about 27 px. shinychat links the echo of a clicked card's text; the model's own text and the file's text are escaped (`md_text()`).
- The key is pasted on Start here and lives in the session only (the app never reads the environment); one model per profile; nothing is kept between sessions.

**Run and test** (from inside `chaRt/`, PowerShell; never two R processes at once, a second can leave an Rplots.pdf and fail 8A-1)
- App: `shiny::runApp("chaRt")` from the repository root.
- Fast smoke: `Rscript --no-init-file tests/smoke.R`: 488 checks, 6.1 minutes.
- Heavy smoke: `$env:CHART_SMOKE = "heavy"; Rscript --no-init-file tests/smoke.R; Remove-Item Env:CHART_SMOKE`: 19 checks, 7.0 minutes. Every check is in exactly one run (the `split:` check holds it); `CHART_SMOKE=all` runs both in about 12 minutes, too long for a foreground limit.
- Live (a key in `ANTHROPIC_API_KEY`, costs a little): `tests/llm_check.R` (steps by `CHART_LIVE_STEPS`) and `tests/live_run_9.R` (at most 10 calls, writes `tests/live_run_9.out` and `tests/dashboard_live/`).

**Map.** `app.R` settings, profiles, packages check, page, server. `R/data.R` file, dictionary, summary statistics. `R/spec.R` spec, checks, ggplot, plotly, code, video. `R/theme.R` fonts, styles, palettes, device. `R/llm.R` key, model call, repair. `R/reflexes.R` prompts, the three calls and their checks. `R/ui.R` pages, canvas, dashboard and codebook writers. `www/reflexes/` the model's rules (not edited here), `www/fonts/`, `www/methodology.md`. `probe/app.R`. `tests/` smoke, live scripts, gold specs, `data/orders.csv`. `DESIGN.md` the design; `manager/` the mailbox of earlier phases (git-ignored but its README).

## History

## Phase 9 Part B: animation (2026-11-22)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. No model call is made by anything in this part. Smoke: fast run 482 of 482 (6.0 minutes; 468 before, 14 new: 9B-1 to 9B-14; one changed), heavy run 15 of 15 (6.5 minutes; 11 before, 4 new: 9B-15 to 9B-18).

**What it is.** Every chart card has an Animate button (shown only where the av package and a picture-writing device are there: `video_available()` in R/spec.R; Start here says so once either way). It makes an MP4 of the chart: the marks come in over 3 seconds, the labels, annotations and names fade in over 0.6, and the finished chart is held for 2. The card then shows the video in place of the picture (`<video autoplay muted playsinline controls>`, no loop, the file as a data address, so no resource path) with Replay (a line of script), Download MP4 (the 1920 by 1080 file) and Picture. A chart whose spec, palette, style or data changes drops its video. In the chat, a message that only asks for it ("animate", "animate this", "play it", "make it a video", "make a video of this", any case, trailing punctuation, a "please" or "can you") is answered by R with no model call; with no chart selected R says "Click a chart first, then ask me to animate it." (through `md_text()`). In the export dialog the choice per chart is Picture, Interactive or Video.

**How a frame is made (R/spec.R, the end of the file).** `video_plot()` draws the chart with `spec_plot()` on a 16 to 9 canvas (8 by 4.5 inches; 10 or 12 inches wide when sideways bars or rows of panels need the height; 6.4 inches for the dashboard, whose card is 540 pixels wide, so text is near 12 CSS pixels). `video_context()` builds the finished chart once (`ggplot_build()`), so every scale, break, axis, legend and panel is the finished chart's. `video_frame(ctx, progress)` returns that built object with each layer's data cut down for the moment, which is how gganimate draws its frames; at progress 1 every layer is the built data untouched, so the last frame is the static chart (a check compares the built data, and a heavy check compares the last frame drawn with the static picture pixel for pixel: identical). `spec_frames(spec, data, cb, palette, style, n)` returns the frames for progress 0 to 1 (the signature has `cb`, which the prompt's did not: `spec_plot()` needs it). `spec_video()` draws 87 frames (3.6 seconds at 24 a second) with `chart_device()`, writes them as PNG files, and encodes with `av::av_encode_video(input, output, framerate = 24, vfilter = "format=yuv420p", verbose = FALSE)`: the input list names the last file 48 more times (the 2-second hold, not drawn again). The 1280 by 720 copy is the same frames scaled by the encoder (`scale=1280:720`), so frames are drawn once. If one frame of the label phase would make the drawing take over 45 seconds, it is drawn at 12 frames a second, each shown twice (none of the families needed it).

**The motion by family.** Cubic ease in and out (`video_ease()`). line, slope: lines draw from the first x to the last, all series and panels together, the newest point interpolated; a slope chart's points are there when the line reaches them. bar, histogram: bars rise from the axis (the value end times the share), each starting later than the one before (the last at half the motion), sideways bars from the top. dot: dots travel from the value axis (the panel's edge) to their value, fading in. scatter, bubble: points grow in along x (in the order of x; points with the same x come together), then the fitted curve is drawn over the last 30 per cent of the motion. box: each box opens from its median outward (whiskers, quartiles, notches), groups in order, the outlying points when the box is open. heatmap: cells fade in a column at a time when x is ordered (a date, a number, an ordered factor), a row at a time (from the top) when it is not. small multiples: all panels move together (the same x, the same progress). Labels (values on marks, end labels, names, annotation words and rings, cell values) are absent until the label phase, then fade in. Every family animates as written; nothing falls back.

**Checks** (9B-1 to 9B-14 fast, 9B-15 to 9B-18 heavy; the heavy run's four are in HEAVY_CHECKS): see the report of the part. Mutation runs (a changed copy of one function sourced after the app loads; the tree untouched): 17 of 18 mutations tripped the check meant for it (15 in the fast run, 3 in the heavy): the scales retrained for each frame (9B-3), the last frame not whole (9B-4), labels from the start (9B-5), the 'play it' phrase removed or the none-selected sentence changed (9B-9, 9B-10), no drop on a spec change (9B-11), video_available() always TRUE (9B-12), the reduced-motion rule, the poster or the page script removed or made unconditional (9B-14), no hold (9B-2, and with real files 9B-15, 9B-16, 9B-18), no stagger (9B-6, 9B-8), a heatmap always by rows (9B-8), the curve drawn with the points (9B-7), a linear ease (9B-1), the MP4 left out of charts/ (9B-17). One mutation changed nothing: asking the encoder for yuv444p instead of yuv420p still gave yuv420p, because av converts to what libx264 takes; the filter is kept as a statement of intent. The first run of the new checks also found two faults of mine, a video not dropped on a spec change (the observer did not depend on the spec) and the curve drawn as one point before its turn, both fixed.

**Choices where the prompt left one.** The video of a card has the chart's title, subtitle and source line in it, as the card's picture has; the dashboard's video has none (the page says them) and is the same file in `charts/`, so `charts/` has no video with a title in it (a second 1920 by 1080 drawing per chart would double the time). A video drawn on a canvas wider than 8 inches (rows of panels) takes a row of the page to itself, or its text would be about 5 pixels. The page script is in dashboard.html only when a video is (a picture-only page still has no script; the check says so). The dashboard's video shows its finished chart as a still (the poster, and a second element) under `prefers-reduced-motion` and in print. A video has no phone drawing: the text of a 6.4-inch drawing at 340 pixels is small (the video has a full-screen control). Progress in the working line is a custom message per frame ("Drawing the video, 22 of 87 frames"; checked live in the browser pane to arrive while the call is running), not shiny::withProgress, whose bar would show in a corner beside the line.

**Not confirmed.** Whether libx264 is in the ffmpeg of the av package on Connect (here the bundled ffmpeg has it; on Linux av uses the system's libav, where `h264` may be absent and the default codec is chosen by the muxer). The Dark style's bubble size legend has black keys on a dark ground (a fault of the static chart, seen in its video). A five-video dashboard (orders file, Clean) took 68 seconds to build; its zip is 2.8 MB, dashboard.html 2.2 MB (most of that the typefaces and the pictures; the five MP4s are 33 to 60 KB each). Seconds to draw 87 frames at 1920 by 1080 and encode two files, by family: bar 14, dot 14, line 17, slope 17, scatter 17, bubble 21, histogram 14, box 15, heatmap 16, small multiples 32 (0.11 to 0.34 seconds a frame); files 0.04 to 0.14 MB at 1920 and 0.03 to 0.12 MB at 1280.

## Phase 9 Part D: summary statistics (2026-11-22)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. No model call is made by anything in this part. Smoke: fast run 468 of 468 (451 before, 17 new: 9D-1 to 9D-17; one changed), heavy run 11 of 11 (10 before; 9D-18 new). The first commit of this part, the value box fix, added 9D-0 (fast) and 9D-0b (heavy).

**First, a small fix.** In the exported dashboard.html a value box number could break in two ("2,740,00" and "0") when the box was narrow. A number (a value with no space in it) now has the class `num`: `white-space:nowrap`, and where the browser has container query units (`@supports (width:1cqi)`) its font size is the smaller of the style's size (`--max`, 1.9rem, 1.5rem on a phone) and the width of its own box divided by an estimate of its width in ems (`--w`, from `dash_value_em()`). Six boxes stay in one row at 1400 pixels and two to a row on a phone; a text value (the period) still wraps between words. Checks 9D-0 (the CSS and markup) and 9D-0b (Chrome at 1400 and 500 pixels, and on a stress page that forces the boxes to 110 pixels, where the old CSS gave a two-line box of 76 pixels).

**One function.** `summary_table(data, cb, measures = NULL, by = NULL)` (R/data.R) returns a tibble of raw numbers, one row for each column (for a group-like column each level; with `by`, each measure for each level of the group and for "All rows"). Fields: column, label, kind, group, level, rows, n, missing_n, missing_share, distinct, mean, sd, min, q1, median, q3, max, mean_ci_low and high, levels, count, share, share_ci_low and high, first, last, gap, scale, small. The kind comes from the dictionary type: number, and a whole number that is not a time, are measures; category, ordered and flag are groups; date, and a whole number with the time role (a year), are times; ids, text and anything whose data cannot be what its type says have n, missing and the number of different values only. A group of more than 30 levels (not possible from a dictionary that has made it text, but the function does not rely on that) shows its ten most frequent and "and k others". `summary_blocks()` writes the numbers with the facts' functions (`fact_num` to three significant digits, `fact_count`, `fact_pct`), `summary_notes()` the lines under a table, `summary_csv()` the CSV. Kept: the tibble is numeric (so a CSV is numbers); the formatted text is made from it.

**The intervals** (assuming a simple random sample, as Kevin ruled): a mean's t interval from `stats::qt(0.975, n - 1)`, none for n under 2 or an SD of 0 or NA; a share's Wilson interval written out in base R on the rows that column has, within each level of `by` on that level's own rows; no interval for a median, a quartile, a minimum or a maximum. The note under every table that shows an interval and the shorter note under one that does not are Kevin's words, kept as they are (checked word for word); the headers say "95% CI (SRS) low" and "high"; the quartile rule (R's default, type 7) is said under a table that shows quartiles. "Show 95% CI" is a switch on the Data page and in the table dialog.

**The scale note.** The dictionary has no measure typed "rating": an ordered column is a group (levels and shares, no mean). A column gets the dagger on its mean, SD and interval and the line "treats the steps of the scale as equal" when it is a measure of type integer (the analyst left it a measure) with at most ten different values lying in an unbroken run of whole numbers (1 to 5, 0 to 9). That is the dictionary's own "may be a coded category" columns that are also a run of steps; a whole-number column with gaps (a discount of 0, 5, 10, 15, 30 per cent) is a quantity and has no note. In orders.csv this marks satisfaction only.

**Small groups.** With `by`, a level of fewer than 5 rows says "(under 5 rows)" in its group cell and a line under the table says what it means; `small` is TRUE in the tibble and `small_group` in the CSV. The export dialog warns once ("A table shows statistics for groups of fewer than 5 rows, which can describe individuals. Nothing is hidden; whether to publish them is your decision.") and names the tables that have such a group. Nothing is suppressed.

**Three places.** (1) Data page: a "Summary statistics" section under the dictionary (`mod_summary_ui/server`, registered in app.R), shown once a file is read and not waiting for labels: a select "By group", the switch "Show 95% CI", "Download CSV", and the table in four blocks (numbers, groups and categories, dates and times, other columns). (2) The canvas: "Add a summary table" opens a dialog (measures, one or more; by group; title; the switch); the card is a plain HTML table in the style's type, with "In dashboard", Move up and Move down, Edit text (the title) and Remove, and no Select, Undo, Interactive, Code, Headline or Animate. A table has an id (t1, t2, ...) in the canvas order and its definition in `state$tables`; it takes a row of the canvas grid to itself (`:has()` on bslib's grid item). A chat message that only asks for it ("summary statistics", "summary table", "describe the columns", with a please or a full stop) is answered by R opening the dialog, no model call. (3) The export: a table is a card of dashboard.html (a real table in a box that scrolls sideways; on a phone no cell wraps) with the note under it, the card takes a row to itself, and charts/ gets a CSV; codebook.html's summary table at the top has n, Distinct, Mean, SD, Min, Median, Max and the interval after the five columns it had, with the notes under it.

**The CSV** is UTF-8 with a byte-order mark (`readr::write_excel_csv`, so Excel reads accents), the header on the first row, an empty cell for none, raw numbers to six significant digits, and the note in a last column `note` on every row (a comment row above the header would be taken by Excel and most readers for the header). Text cells that a spreadsheet would run as a formula (a leading =, @, + or - that is not a number) get an apostrophe in front. Excel itself was not run here.

**Privacy.** The table is drawn in the browser and written to the export. It is not in the CANVAS, SELECTED or LAST EXCHANGE of a chat message: the canvas ids that are charts (`chart_ids()`) are all `run_turn()` hands to `chat_turn()`, so not even a table's id or title goes to the model. Check 9D-13 sends a message after a table card is added and holds that none of the 40 or more numbers of the table is in it outside the DATA block.

**Checks** 9D-1 to 9D-18 (see tests/smoke.R): the ten-row fixture by hand (3.5, 5.5, 7.5, 8.5, 9.5, 10.5, 12.5, 13.5, 14.5, 19.5: mean 10.5, SD 4.690, quartiles 7.75, 10 and 13.25, t interval 7.145 to 13.86 with t(9) = 2.262157, Wilson 7 of 10 = 0.3968 to 0.8922, each to four significant digits against arithmetic written out in the test), each kind of column, `by`, the scale note, the small-group mark, the notes word for word, the CSV, SECRET_VALUE_123, hostile labels, the Data page, the card, the chat, privacy, the export and its dialog, the code (no model, no loop), and Chrome at 1400 and 500 pixels. Changed: 9A-9's header test now ends where the new columns begin. Mutation runs (27 in memory, files never changed): each caught by at least one check.

**Things to know.**
- A statistic is written to three significant digits (the facts' rule), so a maximum of 35,663.6 reads 35,700; the CSV has six digits.
- On a phone the Data page's older file table (Column, Type, Missing, Distinct; not changed here) is a little wider than the screen and the page scrolls sideways by about 27 pixels; the summary tables scroll inside their own boxes.
- The tables' font in the app is the style's own; the app page itself follows the system's light or dark setting.

## Phase 9 Part A: the exported dashboard and codebook (2026-11-22)

The smoke test is now two runs, because the one run took 9.8 minutes and the foreground limit is 10. From inside chaRt/: `Rscript --no-init-file tests/smoke.R` is the fast run (about 5.3 minutes, 450 checks, the default), and `$env:CHART_SMOKE = "heavy"; Rscript --no-init-file tests/smoke.R; Remove-Item Env:CHART_SMOKE` is the heavy run (about 5 minutes, 9 checks: the 400-chart sweep of drawn texts 7b-1, the style sheet 7D-2 with 7b-13, and 9A-1 and 9A-8 to 9A-11, the dashboard in six styles measured and printed by Chrome). Run them one after the other, never together. Each prints its own count line (`[fast] ...` and `[heavy] ...`) and exits with status 1 on a failure; every check is in exactly one run, 449 plus 9 being the 458 of before, plus the new `split:` check that reads smoke.R and holds that no check sits under the other run's guard and every heavy title prefix starts exactly one check. The header of tests/smoke.R says the same.

## Phase 8 Part C: choosing charts and exporting the dashboard (2026-11-21)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. Smoke: **447 of 447** (421 before; 26 new checks, 8C-1 to 8C-25 and 8C-8b; none removed; two test helpers
widened, see below). No model call is made by anything in this part; no Quarto and no pandoc anywhere in the app (Kevin's ruling: the work server has neither).

**Links in cards (first commit).** shinychat's browser code (remark) undoes a backslash escape and then links the text that is left. So `md_text()`'s backslashes kept a bare
`http://`, `https://` or `www.` address in a column label from becoming a link in cmark-gfm (R's commonmark) but not in the browser: it became a link in a suggestion card and in
plain chat text alike (seen in the browser pane). `md_text()` now also writes the ":" after http or https and the "." after www as a one-mark `<span>`, as it already wrote the "@";
no zero-width or other hidden character is added, and the `data-suggestion` attribute (the text a click sends) is unchanged. After the change the browser showed 0 links for all four
forms in a card and in plain text. One thing is left that this cannot touch: when a card is clicked its text is shown, by shinychat's own code, as the analyst's message, and that echo
is linked (the analyst's own typed text is linked the same way); breaking it would change what is sent.

**Choosing.** Each card has an "In dashboard" switch (a `reactiveVal` made with the chart, in `made$dash`, on when the card is made; it survives Undo, reordering and a redraw as the
Interactive view does) and Move up / Move down buttons (the first cannot go up, the last cannot go down; the canvas order is the dashboard's order). The canvas header says
"n of m in the dashboard" and has the Export dashboard button. No drag: neither bslib nor any package the app already uses gives it.

**The dialog** (Export dashboard): title (filled with the file's name), subtitle, author, date (today), an introduction (plain text; the dialog says it is not checked by the number
check), which of the three value boxes to show, and each chosen chart in order with a small picture and "Picture" or "Interactive". Warnings are at the top, before anything is built: a
chosen chart with no headline, a chart whose text is marked as changed, a chosen palette that fails the colour-vision mark. Beside a chart set to Interactive that is drawn from rows
the dialog says in one sentence that the values of every plotted row are written into the file and a picture holds none. A chart is drawn from rows when it is a scatter, bubble or
box, or when its marks are rows (fn none) for a bar, dot, line, slope or heatmap (`chart_from_rows()`); the default for those is a picture, and for the others the card's own view.
The Build the dashboard button is a `chart-call` button (disabled in the browser from the click, the working line says "Building the dashboard", `with_busy()` clears it); an error is
shown in the dialog in plain words with the last four lines of the build's own message, the button works again, and nothing is added to the chat. A built zip is offered for download
from the dialog (`downloadHandler`); building again removes the earlier zip.

**What is written** (`build_dashboard()` in R/ui.R; the whole of it is R: htmltools for the two pages, `zip::zipr()` for the zip): `dashboard_<date>.zip` holding `dashboard.html`,
`codebook.html`, `data_dictionary.yaml` (what the Data page writes), `charts.R` (the code of each chart, as the Code dialog shows it) and `charts/NN_<title>.png` (300 dpi) with
`NN_<title>.svg` when svglite is installed (it is: 2.2.2; written through `chart_device(kind = "svglite")`, a new `kind` argument; the SVG names the family and does not carry the font).
`dashboard.html` is one file: the stylesheet in a `<style>`, the bundled typefaces the style uses as base64 `@font-face`, each chart as a base64 PNG, a CSS grid of cards that wraps from
columns to one, a print stylesheet (a card is never split; `print-color-adjust: exact` so a style prints as it looks), the title block, the chosen value boxes, a card for each chart
(headline or title, chart, summary, notes, source line) and an About card (file, rows and columns, date, author, the model that wrote the text, which texts passed the checks, how many
charts are pictures, a link to the codebook, and the paragraph of `www/methodology.md` that says a chart describes the file, read from the file). Only when a chart is interactive are the
scripts its widget needs written in: `htmltools::as.tags()` of the plotly widget, `findDependencies()`, `resolveDependencies()`, then each dependency's files read from the installed
packages (htmlwidgets, plotly's binding, typedarray, jquery, crosstalk, plotly.js) into `<script>` and `<style>` elements, with `</script` written as `<\/script`. An interactive card
takes the full width of the page. `htmlwidgets::saveWidget(selfcontained = TRUE)` calls pandoc (confirmed in its source) and is not used. A chart whose interactive version cannot be made
is written as a picture, the dialog's result and the About card say so. `codebook.html` has one section for each column, from the dictionary only (`column_summary()` in R/data.R): a
number's range and quartiles, a date's range, the level counts of a group of at most 30 levels, and for an id, a text and a longer category only the number of different values.
Both pages are written with `htmltools` tags (a `<head>` tag is not used: htmltools moves it out when it renders), all in the style chosen; no `src` or `href` is an address, no `url()`
that is not a data address.

**Measured on this machine** (orders.csv, 3,000 rows; ragg; seconds are a build, not a page): 3 charts as pictures 2.9 s, zip 1.60 MB, dashboard.html 1.53 MB; 3 charts interactive (bar,
line, scatter of 3,000 rows) 2.5 s, zip 2.54 MB, dashboard.html 5.06 MB; 5 charts as pictures 2.2 s, zip 1.86 MB, dashboard.html 1.73 MB; 5 charts interactive 3.3 s, zip 2.67 MB,
dashboard.html 5.09 MB. The two Inter faces are about 1.1 MB of every page (also in codebook.html, 1.13 MB), plotly.js 3.58 MB of an interactive one. `zip::zipr()` needs no zip program
(with `PATH` cut down to R's own folder and `R_ZIPCMD` wrong the build still writes the zip, and `utils::zip()` fails); its default `mode` in zip 3.0.2 is "cherry-pick", which drops the
folder names, so the call says `mode = "mirror"`.

**Looked at** (the browser pane, stand-in charts from tests/data/orders.csv, headlines are placeholder text; unpacked in tests/dashboard_clean/ and tests/dashboard_dark/, git-ignored):
Clean and Dark at 1280 and 375 wide, and both codebook pages. No page scrolls sideways at 375 px; the charts scale to the card (they are pictures, so their text gets small on a phone);
Inter loads (it did not at first: `jsonlite::base64_enc()` breaks its lines and a `url()` may not hold one; fixed and checked); Dark's text is 7.0 to 15.6 to 1 against its
background; the print rules were looked at by turning `@media print` into `@media all` in the page (the pane has no print preview): one card to a block, a single column. What is not
good: a line chart's interactive version (`spec_widget()`, not changed here) has tick labels that touch each other and a source line that meets the axis title at card width; the
interactive card is therefore full width, and below 40 rem it scrolls sideways inside its card; a Dark page prints on a dark ground.

**Checks.** 8C-1 the link fix; 8C-2 the zip of a three-chart canvas (listing, 2100 by 1350 PNG, SVG, dictionary, charts.R); 8C-3 and 8C-4 the page and the About card; 8C-5 style, fonts, grid,
print and phone rules; 8C-6 no request leaves either page (and the search finds a planted one); 8C-7 both pages parse (balanced tags, xml2); 8C-8 and 8C-8b the codebook; 8C-9
`SECRET_VALUE_123` in no exported file; 8C-10 a picture export of a scatter holds no planted value and an interactive one does; 8C-11 which charts carry rows; 8C-12 the scripts and the
weight; 8C-13 the interactive fallback; 8C-14 a failing step; 8C-15 the zip needs no program; 8C-16 helpers; 8C-17 the switch, the count, Undo, the order; 8C-18 to 8C-20 the dialog, its
warnings and the sentence; 8C-21 the switch and the order reach the export and the unchosen chart is nowhere; 8C-22 title, author, date and boxes reach the page; 8C-23 the result, the
disabled button and the working words; 8C-24 a failing build; 8C-25 no Quarto, pandoc, model or loop. Mutation runs (in memory; the files were never changed): 42 mutations, each caught
by at least one check (a model call in the export, a request to the web, the unchosen chart kept, a picture that carries the widget, no span, no mirror, the switch starting off, and so
on). Two checks first stopped on an error instead of failing and were made to fail cleanly. Changed: the helpers `d6_seen()` and `d6_bare()` also undo the one-mark spans of `md_text()`.

**Things to know.**
- `zip` is now in `APP_PACKAGES` (installed here: 3.0.2); svglite is used when it is there and is not required.
- The About card's model is `APP_MODEL$id` of the profile in use; a text the analyst edited is still said to be checked (it is checked again on every edit, but not marked as edited).
- The intro, title, subtitle and author are the analyst's own words and are not checked; the dialog and the About card say so.
- The built zip lives in the session's temporary folder until the next build or the end of the session.
- The date in the zip's name is the date typed in the dialog.

## Phase 8 Part B: the Methodology page and things to ask (2026-11-21)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. Smoke: **421 of 421** (409 before; 12 new checks, 8B-1 to 8B-11 and 8B-2b; 3 changed, none removed).
Part C is not started. No model call is made by anything in this part.

**The page** (Methodology, `mod_method_ui()` in R/ui.R; `www/methodology.md` is the manager's and is not edited). In order: the manager's text as HTML, with a
contents list after its opening paragraph; "Questions for your file"; "The rules the model follows"; "How a reply is checked"; "Styles and fonts". The text is
rendered by `commonmark::markdown_html(extensions = TRUE)`, which is what `shiny::markdown()` calls (checked: the same HTML for this file); tables are an
extension, so without `extensions` the table would stay raw text. `commonmark` is now in `APP_PACKAGES` (it is installed with shiny). The `{measure}` braces are
shown as written. Everything except the questions is the same for every session, so it is built when the app starts.

**Small drawn examples.** A first column of thumbnails in the "Which chart for which question" table, one for each of its nine rows, keyed by the first word of
the row's "The chart" cell (`method_thumb_key()`). They are drawn by `spec_plot()` and `spec_png()` (so `chart_device()`) from a made-up table
(`method_thumb_data()`: five regions by ten years, units, price and revenue, with no random numbers) at 72 pixels per inch, 7 by 4.5 inches, shown 9 rem wide,
as data addresses. `method_thumbs()` draws them once (about 4 seconds, 130 KB of PNG in all) and caches them; app.R calls it when it starts. A note under the table says
they come from a made-up table and show form, not a finding. A server that cannot draw has none, and the page goes without. The course files are not deployed
and `tests/` is not, so nothing else was available.

**Things to ask.** `example_questions(cb)` (R/reflexes.R) reads the table's last column: the text in quotes (straight or curly), with `{measure}`, `{measure2}`,
`{measure3}`, `{group}`, `{group2}` and `{time}`. The table is found by its heading and its columns by their header cells (`methodology_templates()`), so a
reordered table reads the same; `check_methodology_file()` at start-up stops the app, naming the file, if the heading, the table or a column is gone. Slots are
filled from the dictionary: measures from the columns with the measure role (first, second, third), groups from those with the group role (at most
`SPEC_FACET_MAX` values), time from the first with the time role; a column with fewer than two values or mostly missing fills none; the label (`col_title()`) is
used, one line, cut at 60 characters; the fill is in one pass, so text that goes into a slot is never read as a slot. A template whose slots are not all filled is
left out; at most eight, in the table's order, each tagged with the table's chart name ("Bar, or dot"). On Explore, when the dictionary is ready and the canvas is
empty, the ready message is followed by "Try one of these:" and the questions as suggestion cards (`say_ready()`). On Methodology the section lists them with an
"Ask this" button (a `chart-call` button): the server puts that question in `state$ask_request`, the Explore server passes it to the chat with
`shinychat::update_chat_user_input(submit = TRUE)`, so it goes as the analyst's message by the path a card takes, and the button also opens the Explore tab.

**Rules, checks, styles.** The rules are built by the existing parser: 56 labelled rules in 9 files (core 12, comparison 8, relationship 7, distribution 2, time 3,
suggest 2, refine 8, chat 4, summary 10), each with its Label, When, Say and Source, in a collapsed `<details>` for each file; 10 rules have no label (codebook.md's
four and six in other files) and are counted, not listed. "How a reply is checked" is written from `check_numbers()`, `check_words()`, `names_back()`,
`check_chart()` and the one repair in `chat_turn()` and `summarize_batch()`; its examples (69,700 passes for 69,712; 70,000 does not) are run by check 8B-8, and
the forbidden and multiple words are the code's own constants. Styles and fonts: the six style samples of the Style dialog and the two bundled typefaces with the
SIL Open Font License 1.1, the holder's line read from the licence file, and a link to the file in `www/fonts/`.

**Checks.** 8B-1 templates parsed (also from a reversed table with other text and tables around it and from curly quotes; the errors); 8B-2 and 8B-2b the filling and
dropping (no time, no group, neither, no measure, nothing, a constant column, a mostly-missing one, a group of 17 values; orders.csv, the messy file); 8B-3 a hostile
label; 8B-4 the page with no file; 8B-5 the page with a file and the buttons; 8B-6 the Explore cards and the request from Methodology; 8B-7 every labelled rule once;
8B-8 the checks text; 8B-9 styles and fonts; 8B-10 the thumbnails (drawn once, at start-up, from a table with no random numbers); 8B-11 no model call, start-up.
Changed: 6-C 5, 6-C 7 and 6-C 25 now ask that the ready message start with `SETUP_READY` (the cards follow it) instead of being equal to it. Mutation runs: every new
check failed in at least one run (see the report).

**Things to know.**
- The last template, "Show that in a panel for each {group}.", says "that", which means the chart before it. As a card on an empty canvas it has nothing to point
  at. It is the ninth, so it is cut when eight others fit, and appears for a file with few columns. Not edited (the file is the manager's).
- A bare `http://` address in a label shows as a link in a suggestion card: shinychat's browser code links it although `md_text()` backslashes its punctuation (seen in
  the browser; the page's own list on Methodology escapes it and links nothing). `md_text()` is not changed here.
- The question text is sent to the model as the analyst's message, with the label in it; the label is already in the DATA block of every call.
- `later_ui()` and `LATER_PHASE` are no longer used; kept because check 6-C 30 names `later_ui`.

## Phase 8 Part A: no X11, anywhere (2026-11-21)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. Smoke: **409 of 409** (396 before; 13 new checks, 1 changed,
none removed). Part B and Part C are not started.

**The one way in.** `chart_device(file, width, height, dpi)` (R/theme.R) opens the only device the app opens: ragg when it is
installed, else `png(type = "cairo")` when `capabilities("cairo")`, else svglite (an SVG), else it stops with
`CHART_DEVICE_NONE`, a plain sentence. `spec_png()` and tests/gallery.R's `drawn_text_boxes()` (the text measurement) run
inside it and close it. Four switches (`ragg_installed()`, `cairo_available()`, `svglite_installed()`,
`shiny_has_useragg()`) let a check stand in for a server without ragg or without cairo. `chart_device_options()` (called from
app.R) sets `bitmapType` to "cairo" when R has cairo, and `shiny.useragg` to TRUE when shiny is 1.7.2 or later (NEWS: that is
where `renderPlot()` began to use ragg, with that option). Start here says which device is in use, once (`device_note()`).
A check (8A-2) reads every function in app.R and R/ and fails if any other calls a device opener, `ggsave`, `strwidth` or a
grid unit conversion; the audit found none outside the gallery, which now goes through `chart_device()`.

**What the audit left that is not ours.** `plotly::ggplotly()` (spec_widget) opens its own `grDevices::png(tempfile())` to
convert sizes, with the default type, which is `options(bitmapType)`, hence the start-up option; where `capabilities("png")` and
`("jpeg")` are both FALSE and the Cairo package is absent, ggplotly stops with its own message and the interactive version
cannot be made (the static chart still draws). In a non-interactive R (Rscript, a Shiny server) a stray `print(plot)` with no
device open starts the `pdf` device, not X11: it writes `Rplots.pdf` and measures text with the pdf device's fonts. Check 8A-1
looks for that file.

**The paths compared** (one bar chart of orders.csv, 7 by 4.5 inches at SPEC_DPI 192): ragg 1344 x 864 px, about 45 KB, drawn in
Inter; cairo 1344 x 864 px, about 17 KB, drawn in the operating system's default sans (Arial on this Windows machine): the
bundled files are registered with systemfonts, which ragg and svglite read, and base R's cairo device asks the operating system,
which does not know them. Same layout, same size; the type differs. svglite writes the family name into the SVG and measures with
systemfonts, but a browser showing the SVG as a picture has no such font, so it is not counted as using the bundled ones. On a
Linux machine that already has Inter installed (the WSL test below) cairo drew Inter too, because the system had it, and
`register_font()` said the family already exists (so `chart_fonts_register()` returns FALSE for it there, with the family still
available).

**No X11, proved as far as it can be here.** Windows has none to remove. A WSL Ubuntu (R 4.4.2, DISPLAY unset, `X11` FALSE,
cairo TRUE) was at hand: `chart_device()` drew by ragg, cairo and svglite and said "cannot draw" with none; `png(type =
"Xlib")` failed there with "unable to open connection to X11 display"; `plotly::ggplotly()` worked with `bitmapType` cairo; the
probe's Graphics section ran and drew all three. That is not Connect: the whole app (ellmer, shinychat, S7, ggplot2 4) was not
run there, and the server's packages, fonts and `capabilities()` may differ. The probe will show them.

**The probe** (probe/app.R) has a Graphics section: `capabilities()` for X11, cairo, png and jpeg, DISPLAY, `bitmapType` at start
and now, whether `png(type = "Xlib")` opens, ragg, svglite, Cairo, systemfonts and av with versions, R and the system (the
`Sys.info()` fields without host and user names), whether a font file registers with systemfonts and is found by name (the bundled
Inter if www/fonts is copied beside the probe, else the first monospace TrueType file the server has), and one chart drawn by each
available device and shown. No model call, no key, self-contained.

**Numeric codes for missing (item 6).** `numeric_code_words()` and `missing_candidates()` (R/data.R): a value of a numeric column
that is repeated (at least 5 rows or 1% of the rows, and never one row), is in a usual form (negative while the rest of the
column is not, or all nines of two digits or more, with or without a minus), and lies more than 3 interquartile ranges beyond
the nearer quartile of the rest of the column, is offered in the chat as "Treat '-99' as missing", the same button and the same
`TREAT_PATTERN` click as a word, at most 3 a column. It is an offer; nothing is applied until the click. The value is offered as
the text `format()` gives, so a file that writes it as "-99.0" is read again with no change and the chat says so.
The messy test file's planted -99 (score column, 3 rows of 120) is now offered; check 6-C 1 expects it.

## Phase 7b: faults found by looking at the charts (2026-11-21)

Branch `chart`, not pushed; done by the lead alone (no mailbox, no workers). Smoke: **395 of 395** (381 before; 14 new
checks, 8 changed, none removed); one smoke run takes about 6 minutes. Commits: 489f3f9 (summary.md 0.3 and its checksum,
`change_over_time` in `RULE_FAMILIES` as "any", like the other summary.md rules; `.rscignore` names phase7b_prompt.md),
9d8ec0e (the drawing), 95fbf56 (the checks, the screen, the style sheet).

**The lesson of Phase 7, and what now checks for it.** `drawn_text_faults()` (tests/gallery.R) measures every text a
chart's panels draw on the chart as drawn: the plot is printed to a ragg device of its own size, `grid::grid.force()`
turns ggrepel's labels into text grobs, and each grob's box is measured with grid (`deviceLoc()` for its anchor, taken in
the label's own font settings, because ggrepel writes a moved label's place as an offset in font units; `grobWidth()`,
`grobHeight()`, `grobDescent()`, its hjust and vjust). A text must lie inside its panel when the plot clips (a text past
the panel is cut off, which is what "ghest: 765,000" was), inside the device when it does not (end labels); no two texts
of a panel may overlap; an annotation keeps clear of a rug's band. Check 7b-1 runs it on every gold spec with
`labels: on` and each annotate kind it takes, in all six styles: 402 charts, about 130 seconds. It found, beyond the
items: a sideways bar's or dot's tied annotation running past its panel, and a scatter's highlighted name overlapping
its annotation (two ggrepel layers do not push one another apart).

**What changed in the drawing.**
- An annotation's text runs away from the nearer edge (point in the left third: to the right; right third: to the left),
  sits below a point near the top and above one near the bottom; over an upright bar or dot it is centred, its kind,
  value and any tie on lines of their own ("Highest" / "765,000"). The value axis gets the room the longest text past a
  mark needs, worked out from the data's range (ggplot2's expansion is a share of the range, not of the panel; the
  same mistake made the end-label room too small for long labels, also fixed).
- A marked point that is the last point of a line with an end label is said in the end label ("Islands  116,000,
  highest"); no second text; the ring stays. A scatter's or bubble's names and annotations share one ggrepel layer.
- Ties: "Highest: 100, one of 2 points" (the count is R's, from the table drawn; the facts do not hold it, and check
  7C-6 sets it aside). A label ggrepel moves is kept above and right of a rug's band (`xlim`, `ylim`; not on a log axis).
- Every bar or dot carrying its value: the value axis keeps its title and loses its numbers and ticks.
- A line chart in panels marks the point in each panel up to 6 panels, each only if its number is in the facts; with
  more, none, and a note. A chart whose colour is its facet counts.
- A line chart's time-axis breaks are `pretty()` of the data's own range, kept within it (no "2026").
- Axis and legend titles: the dictionary's label, else the name with underscores as spaces and a capital first letter.
  The facts keep the label as it is.
- Heatmap legend: four to six round breaks inside the range (`get_guide_data()` counts what the legend shows) and a
  colour bar 2.4 inches long. A palette entry may carry `single`; Okabe-Ito's is #0072B2.

**The screen.** The Period box says "Jan 2023 to Dec 2024" in 1rem type, one line, with the full dates as its tooltip;
on a canvas narrower than bslib's lg breakpoint (down to 576 pixels, where the sidebar still sits beside it) the third
box takes a row of its own. Seen in the `chart` preview at 576, 991, 992 and 1024 pixels: one line at each.

**Item 11 (the chat text of a charts reply).** The app was right: `chat_reply_text()` reads each chart's say beside its
spec. Only the live run's printout (`live_reply_text()` in tests/live_gallery.R) read `spec$say`, which Phase 7 stopped
storing; fixed. Check 7b-11 replays the Phase 7 run's first reply from tests/live_replies.rds through `chat_turn()`.

**Item 12 (the row that did not reach Explore).** No order of events in the app was found that loses it. A Data page
that is hidden is not redrawn (Shiny suspends hidden outputs): after a file is read while Explore is showing, the
Data page keeps the first file's boxes, "one sale" still in them, until it is shown; then it is drawn with new boxes
(a new generation of ids) and a row typed there reaches Explore (reproduced in the preview). The Phase 7 sighting
fits the browser automation typing into the old, hidden box, which already said "one sale", so nothing was sent.
Check 7b-12 (`testServer()`): file one, row, ready; file two, new boxes, not ready, the old box's value ignored; row
typed in the new box, ready.

**Item 14 (live, 4 calls, Sonnet).** Calls: chat 1, then summarize 2 (a first reply that failed a check and its
repair), then summarize 1 more. The turn came back `charts`: a line of revenue by month in six panels by region. The
facts sent hold, for each panel, first and last, highest and lowest with when, and the value a year before the last
point (output in tests/live_run_7b.out, git-ignored). No headline was obtained in that run: the scratch script printed
the wrong list and lost the reply to the third call, and the fourth call's reply could not be read.

**Item 14, second run** (Kevin approved 4 more calls; 3 used; tests/live_run_7b2.out). Chat 1: the same chart (line, six
panels by region). Summary 1: not valid JSON: the model wrote its JSON and then went on ("Wait, I must check that
headline..."), and the reply parser takes everything from the first `{` to the last `}`, so text after the object breaks
it. Summary 2 (same chart and facts), checked clean, no repair:
- HEADLINE: "West revenue ended December 2024 at 69,700, its highest month, while East fell over the final year."
- SUMMARY: "West ended at 69,700 in 2024-12-01, up 11,100 over the final year from 58,600, and 9.3 times its January 2022
  start. East was the one panel that fell over that year, by 20,300 to 7,460. The chart draws on 3,000 orders; Central
  has 35 monthly points and the other regions have 36."
In this one reply summary.md 0.3 did what it asks: the headline rests on the peak and the change over the last year,
not on the first and last month, and "9.3 times its start" stands beside the year-earlier change. One reply is not a
test of the rule.

**The reply parser, fixed afterwards.** `parse_json_block()` (R/llm.R) now tries `json_first_object()` when the whole
span from the first `{` to the last `}` does not parse: the first complete object, found by scanning outside strings, so
braces and quotes inside a value do not end it, and what the model wrote after it is not read. The quote and closing
repairs still apply after it, so a reply cut off inside a string is repaired as before. Check 7b-14 covers a reply with
text and a second object after its JSON, through `parse_json_block()` and `llm_json()`, and the cut-off reply; with the
repair undone, that check alone fails (395 of 396); smoke is **396 of 396**. The actual failing reply was not saved in
full, so the fix is checked on a made-up reply of the same shape, not on that one.

**Not confirmed.** The plotly versions of the changed charts (bare axis, merged end labels) were not seen in a browser;
the box measure is of the string's box, not its ink (tolerance 0.02 inch); the rug's band is not kept on a log axis;
the style sheet's before pictures need git on the path (without it the row shows after only).

## Phase 7, notes carried while it is built (2026-11-20)

Branch `chart`. Not pushed. The full Phase 7 report goes to `manager/done-7.md` at its end; these are the things a
later reader of this file needs before then.

- **The plotly version shows less than the static chart.** plotly shows semibold as bold (it has no weight between
  regular and bold for a font family), and it drops Magazine's lifted value-axis labels (the static chart sets them
  above their grid line with a theme margin that plotly does not carry). Everything else a style sets (colours, grid,
  fonts, the Newspaper rule, the palette, the Dark swap) is kept; see Part B's report.
- **Diverging means balanced** (a-006). A diverging palette is offered only if its lightness has one extreme at the
  middle colour (or one of the two middle colours when the length is even) and its two end colours are within 20
  lightness units. MetBrewer's diverging sets kept: Benedictus, Cassatt1, Cassatt2, Demuth, Ingres, Isfahan1, Johnson,
  Juarez, Moreau, OKeeffe1, Troy; dropped as diverging: Hiroshige, Hokusai1, Homer1, VanGogh1, Veronese.
- **Part C: words and numbers on the chart, all written by R.** Two spec fields, `labels` (auto, on, off) and `annotate` (up to
  two of highest, lowest, first, latest), in `spec_check()`, `spec_reference()`, `spec_code()` and the YAML (a bare `on` or
  `off` in YAML reads as TRUE or FALSE; both mean the same here). Every number on a label or annotation is written by the
  facts' own number functions (`fact_num()`, `fact_count()`, `fact_fixed()`, made of base R so the written code carries a copy),
  and a check finds each one in the chart's facts. The facts are unchanged.
  - **ggrepel** (0.9.8, installed) moves apart the names on a scatter's or bubble's highlighted points and the words of an
    annotation on a line, scatter or bubble. It cannot place a label against a bar (it knows the label's anchor, not the
    bar), so the value labels of a bar or dot are placed by R at the end of the mark, with or without ggrepel, and the ones
    that would collide are left out and counted in the notes. Without ggrepel the point labels are treated the same way: only
    the names and annotations that fit a rough layout of the panel (in inches, from the label's characters) are drawn, the
    others are counted in the notes, with "ggrepel, which moves labels apart, is not installed". The line-end labels are
    unchanged by ggrepel: ends that touch get a legend in the order of their values, as before.
  - **The source line** is written by R into the caption when the analyst has not written one ("Source: <the dictionary's
    source, else the file name>. <n> rows; <the filter in words>; <m> left out for missing values."); the analyst's caption
    replaces it and the notes say so. The data dictionary has an optional file-level `source` (Data page box and YAML).
  - **The Code dialog prints the chart as drawn** (the linted spec, the chosen palette and style), not the stored spec.
  - **The interactive version** keeps value labels, annotations, the names on points and a heatmap's cell values as text
    traces (placed above their mark, to the right of a sideways bar); it drops the line-end labels (it has a legend) and
    the names that would run into another, and says so in the card's notes while it is shown.
- **A colour that cannot be seen is not drawn** (a-006). In any style a palette colour under 10 dE (CIE2000) from the
  style's background is skipped and the palette's usable count for that style drops (`palette_usable()` in
  `R/theme.R`). Rules of a-007 supersede the first Part C version of the Dark swap: on Dark each palette colour under
  3 to 1 is replaced by its own lightened version (`chart_lighten()`: CIELCh lightness raised, hue and chroma kept as far
  as the gamut allows, until 3 to 1; farver `decode_colour(to = "lch")` and `encode_colour(from = "lch")`), so no colour is
  lost and no two groups share one (black becomes a grey of about 3.04 to 1, not #EDEDED); then the skip for a colour
  under 10 dE from the background; then, on Dark, the skip of a colour under 10 dE from an earlier colour kept. Dark's
  highlight grey is #565E68 (it was #5E6670: a lightened black sits just over 3 to 1, and the grey must stay weaker than
  every palette colour).
- **Value labels under `auto`** (a-007): if any bar or dot label would be left out, none is written, the value axis keeps
  its grid, and the notes say "Values are not written on the marks because some would overlap." Under `on`, the labels
  that fit are written and the notes keep the count.
- **Palettes are judged on the colours as drawn** (a-007): the 11 colours a diverging chart gets (`chart_diverging()`), not the
  longer list a package stores. ColorBrewer PuOr (ends 23.7 lightness units apart) is no longer offered as diverging; the
  earlier reading of Crameri's 256 stored colours by index is dropped: Vanimo, Vik and Bam pass on the 11 drawn.
  The heatmap cell cap stays at 40.
- **Part D: the screen.** The Style dialog has the six styles with samples (Part B). The file-name value box is set at
  1.1rem on one line, cut with an ellipsis, with the full name as its tooltip. Card buttons have dark-mode rules (light
  text from the theme's own dark colours; the hue only in the border), since the theme's primary is a dark navy. `bsicons`
  is not installed, so the card buttons are words only. `tests/style_sheet.html` (git-ignored, written by
  `Rscript --no-init-file tests/gallery.R style_sheet`, no model call) shows every family in every style, every
  qualitative palette on Clean and Dark, labels and annotations, each family with labels and annotate in Newspaper and
  Dark, and the MetBrewer palettes on offer. `tests/llm_check.R` step 9 is the six-turn live run (at most 12 calls).

## Phase 6b, 2026-11-20: more palettes, a working signal, a clean folder

Branch `chart`. Not pushed. No model call. Kevin approved the proposals at the STOP ("Go, as
proposed"). The palette and working-line work went in under Kevin's own commit aef2456 ("adding
shiny app"), which also holds the two SurvAI_Expert files; then 4d2ae05 (old prompts removed) and
f04add3 (`.rscignore`).

### Files changed and removed (7f8a3de..HEAD, added / removed)

| File | Lines |
|---|---|
| `R/theme.R` | +147 / -25 |
| `R/ui.R` | +111 / -13 |
| `tests/smoke.R` | +138 / -4 |
| `R/spec.R` | +24 / -6 |
| `R/reflexes.R` | +3 / -3 |
| `.rscignore` | +2 / -2 |
| `phase6b_prompt.md` | +126 (Kevin's prompt) |
| Removed: `phase0_prompt.md`, `phase1_prompt.md`, `phase1b_prompt.md`, `phase2_prompt.md`, `phase2b_prompt.md`, `phase2c_prompt.md`, `phase2d_prompt.md`, `phase3_prompt.md`, `phase3b_prompt.md`, `phase4_prompt.md`, `phase5_prompt.md` | -1,512 |

Also removed, untracked: `data/chaRt_test_orders.csv`, a byte-for-byte copy of
`tests/data/orders.csv` that nothing read and that `.rscignore` would have shipped. Left, as the
prompt says: the generated files in `tests/` (already git-ignored), `.Rhistory`, and the mailbox's
`q-*`, `a-*` and `done-6.md`.

### Smoke test

298 of 298 (285 before; 13 new):

```
ok    6b-1: every listed palette (58, of which 55 through paletteer) has its name in the installed paletteer's tables and resolves to valid colours
ok    6b-1: the stored colour-vision result of every palette matches palette_cvd() recomputed now
ok    6b-1: the selects group the palettes by source, the default first, and the mark sits beside exactly the palettes that pass
ok    6b-1: a qualitative palette with fewer colours than a chart needs is not stretched: the chart (8 regions, Moth has 5) is drawn and coded with Okabe-Ito and its notes say so
ok    6b-1: each Style select is a selectize input whose options show a strip of the palette's colours before its name (render option); the strip's colours are the palette's, and the name goes through escape()
ok    6b-1: choosing a palette that fails the colour-vision check shows the one line under Style; the defaults and a passing palette show none; no model call
ok    6b-1: without paletteer the selects offer only the built-in palettes, a chart still draws and the page still builds
ok    6b-2: the working line is in the page under the chat's input: hidden, role="status", aria-live polite, three dots hidden from screen readers, and words
ok    6b-2: the script shows the line from the browser on a chat send, a suggestion or a call button, adds 'still working' after 8 seconds, and hides it on chart-busy and when Shiny is idle or disconnected; the dots stop for reduced motion
ok    6b-2: Suggest charts, Write headlines and a card's Headline carry their words (Thinking, Writing headlines, Writing a headline)
ok    6b-2: the script's own wordsFor(), run in V8: a question and a suggestion give 'Thinking', 'Label the columns' gives 'Labelling columns', a Treat or row button 'Working'
ok    6b-2: the working line adds nothing to the chat's messages: after a turn the chat holds the reply only, LAST EXCHANGE is the question and its reply, and busy was set and cleared
ok    6b-2: shiny's page-level pulse is on as a second signal (useBusyIndicators(spinners = FALSE, pulse = TRUE, fade = FALSE)); no spinner on the cards
```

Two existing checks changed: 4-A2 (an 8-region slope under a 7-colour palette is now drawn with
Okabe-Ito and says so, in place of the "8 colours" note), and the button regexes of 6-C 28 and
6-D 13 (a `data-working` attribute now sits between `class` and `id`). Scratch runs with the work
undone made every new check fail except four that match fixed text in the page and script (the
script check, the button words, nothing appended to the chat, the pulse).

### Palettes now offered

The check: the smallest CIE2000 difference (`farver::compare_colour(method = "cie2000")`) between
any two of a palette's first five colours (five spread along a sequential or diverging one) after
simulating deuteranopia, protanopia and tritanopia (`colorspace::deutan()`, `protan()`, `tritan()`),
the worst of the three. The mark (a tick after the name) is 8 or more (`CHART_CVD_MARK`, approved).
The results are written out in `CHART_PALETTE_CVD`, so the app needs neither colorspace nor
paletteer to show the marks; the smoke test recomputes them.

- Qualitative: Built in: Okabe-Ito (12.1, default). khroma: Paul Tol bright (8.7), muted (17.7),
  vibrant (8.6), medium contrast (12.1). ggthemes: Tableau Classic Color Blind (16.9), Stata
  Economist (13.7), Excel Office Theme (12.2). MetBrewer: Archambault (15.7), Veronese (15.6),
  Johnson (14.6). NatParksPalettes: Kings Canyon (21.7), Death Valley (15.8), Torres (15.3). nord:
  Algoma Forest (9.4), Moose Pond (8.6). PNWColors: Moth (13.2), Bay (11.6). CARTOColors: Safe
  (17.7). wesanderson: Darjeeling 2 (13.9), Isle of Dogs 1 (12.2), Isle of Dogs 2 (8.4). All marked.
- Sequential: viridis: Viridis (13.4, default), Magma (14.2), Cividis (13.0), Mako (13.9).
  ColorBrewer: Blues (9.9), YlGnBu (7.0, not marked). khroma: Paul Tol smooth rainbow (17.0),
  Crameri Oslo (19.4), grayC (18.4). ggthemes: Tableau Classic Blue (11.1), Gray Warm (11.0),
  Classic Gray (10.5). nord: Halifax Harbor (8.3). PNWColors: Lake (13.5), Mushroom (12.6), Winter
  (11.9). CARTOColors: DarkMint (12.9), BrwnYl (12.0), BluYl (11.2).
- Diverging: ColorBrewer: RdBu (22.9, default), PuOr (24.7), BrBG (13.7). khroma: Paul Tol sunset
  (18.7), Crameri Vanimo (27.9), Vik (28.2), Bam (24.1). ggthemes: Tableau Red-Blue-White (25.2),
  Orange-Blue-White (25.1), Classic Orange-White-Blue (23.5). nord: Silver Mine (8.5). PNWColors:
  Shuksan 2 (15.0), Anemone (8.3). CARTOColors: Earth (15.2), ArmyRose (12.5), Geyser (11.4).
  Built in: Blue-red (13.9, the fallback without paletteer).

The selects group by source, with the default's group first; each option and the chosen item show
a strip of the palette's colours before the name (selectize.js's `render` option through
`selectizeInput(options = list(render = I(...)))`). A chosen palette that fails puts one line under
Style: "This palette is hard to tell apart for some readers with colour-vision differences." A
qualitative palette with fewer colours than a chart draws is not stretched: that chart uses the
default palette and its notes say so. The colour count is now the drawn table's (`.n_colours`, set
by the lint), not the codebook's, so a chart filtered to fewer groups keeps the chosen palette.

### Finding: rsconnect does not expand patterns in `.rscignore`

rsconnect 1.11.2's `listDeploymentFiles()` showed `phase6_prompt.md` and `phase6b_prompt.md` in a
deployment although `.rscignore` listed `phase*_prompt.md`. `.rscignore` now names each prompt; a
new prompt file must be added to it by name. With that, a deployment carries `app.R`, `R/` and
`www/reflexes/` only: no tests, prompts, mailbox, probe or documents.

### Seen in the browser (the `chart` preview; no key typed)

- Style dialog (a small file handed to the Data page, "one sale" typed as the row): the legend
  line with the tick; three selectize selects, each chosen palette with its swatch strip and tick;
  the Groups list open, grouped Built in, khroma (Paul Tol, Crameri), ggthemes, MetBrewer,
  NatParksPalettes, nord, PNWColors, CARTOColors, wesanderson, each option with its strip; choosing
  ColorBrewer YlGnBu (no tick) put the warning line under Style on the canvas.
- Working line: recorded with a MutationObserver, not seen by eye. On a chat send and on Suggest
  charts it appeared with "Thinking" and went about 7 to 10 ms later, when the "needs a key" reply
  came back. A long call, the "still working" words after 8 seconds, the reduced-motion dots and
  shiny's pulse were not seen.

### Not confirmed, and departures

- Not confirmed: the working line during a real call of several seconds; that a screen reader
  announces it; the pulse; how shinychat's own pending dots and the working line look together.
- The lightest-colour contrast is not shown in the app: every qualitative palette offered,
  Okabe-Ito included, has a lightest colour under 3 to 1 on white, so a note would stand beside
  every one. It is in the STOP table.
- `khroma::okabeito` is left out (the built-in Okabe-Ito is the same set); Paul Tol muted stays
  under its old name.
- The working line also goes when Shiny reports the server idle or disconnected, so a failed call
  does not leave it showing.
- STATUS.md was not shortened: the prompt asked for the shorter file as a proposal only.
- Kevin's commit aef2456 holds `SurvAI_Expert/build/03_store.R` and
  `SurvAI_Expert/data/catalog/receipt.csv`, which earlier phases kept out of every commit; it has
  not been pushed, and I have not changed it.

## Phase 6, 2026-11-19: facts fixes, one call for every message, the chat-first screen

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5` (step 8 of `tests/llm_check.R`): 16 calls.

### Built

- Part A, the facts. The top histogram bin is clipped to the data's minimum and maximum. A heatmap's
  row and column lines are worked out from the rows of the data with the spec's own function
  ("All rows in Goalkeeper: mean 28.7"; `spec_facts()` takes `data`, and without it leaves those lines
  out, never falling back to the mean of the cells). Every family states "Groups shown" and "Rows after
  the filter". When every plotted value is the same: "Every value shown: v", and no Lowest or multiple.
  A line or slope series gets "end is m times start" when both are positive. One correlation (Pearson);
  the Spearman only when the two differ by more than 0.1, with a line saying the relationship is not a
  straight line. `check_numbers()` no longer reads "one" as a number. `check_words()` allows "doubled",
  "tripled", "quadrupled", "twice", "halved" and "half" only when the chart's facts hold a multiple that
  supports the word. The probe reports av, gganimate, gifski, ffmpeg, an MP4 encoded from ten PNG frames,
  Quarto, and a `format: dashboard` document, plain and with `embed-resources: true`.
- Part B, one call for every message. `chat_turn(message, canvas, selected, cb, data, last, ask, palette,
  m)` in `R/reflexes.R` replaces `suggest_charts()` and `refine_chart()`. The reply has exactly one of
  `charts`, `spec`, `ask`, `cannot`, `tell`, and may have up to three `next` strings of at most six
  words. `CALL_FILES$chat` is core, comparison, relationship, distribution, time, suggest, refine,
  chat; the reply format is `chat.md`'s; the system prompt is identical on every turn. The user message
  is DATA, CANVAS, SELECTED, LAST EXCHANGE, `ANALYST:` and the message, REPLY FORMAT; `data_safe()`
  covers the new markers. The suggestion message `(suggest charts for this file)` alone marks charts
  exploratory. A `spec` with nothing selected is a failed reply with a sentence and no call; a `tell`
  with a number that is not in DATA gets one repair, then the warning.
- Part C, the screen. `app_ui()` in `R/ui.R`: the classification banner above `bslib::page_navbar()`
  with the logo, title, Source code link and dark-mode switch in the bar, and four pages: Start here,
  Data (the file, then the data dictionary; the download is `data_dictionary.yaml`), Explore and
  Methodology. Explore is `bslib::layout_sidebar()` with shinychat in a 38% sidebar and the canvas on
  the right: three value boxes, a card for each chart (full screen, newest first, two to a row) with
  Select, Undo, Interactive, Code, Edit text, Headline and Remove; Style; "Suggest charts" and "Write
  headlines" under the chat; setup written by R in the chat with no model call except "Label the
  columns". The old Explore tab, wide view, report list and Phase 4 and 5 screens are gone;
  `state$report` is `state$canvas`.
- Part D, the checks and the fixes the manager asked for after Part C.
  - What reaches the chat is escaped (see below). `md_text()` is stricter than in Part C, `one_line()`
    puts a `next` entry on one line, `suggestion_list()` escapes the text twice (as attribute and as
    markdown).
  - Setup texts are matched exactly in R and acted on only while their button is on offer: a "Treat"
    text for a value the file does not hold (or already treated) does nothing and says so; so do the
    label text once labelled and a row guess no longer on offer. An analyst's own message that
    merely contains such a text goes to `chat_turn()`.
  - A headline and summary are stored with a data version (a digest of the data when written). The same
    file read again keeps the canvas; if the data changed the charts are drawn again from it, their notes
    are made again, every text is marked "The data has changed since this was written, so its numbers
    may no longer hold." and the chat says how many. The spec-hash rule is unchanged.
  - The footer buttons ("Suggest charts", "Write headlines", and each card's Headline) were drawn very
    faint in dark mode: the theme's outline-primary colour is `#2c3e50` on `#212529`. A style change in
    `EXPLORE_CSS` gives class `chart-call` the page's emphasis colour (black on light, white on dark) for
    text and border, the body colour when disabled, at opacity .65. Wording and behaviour are unchanged.
  - Removed: `chart_reset()` and `new_chart()$first` (no Reset button), the `suggest` and `refine`
    entries of `LLM_MAX_TOKENS`, `tests/llm_check.R` steps 4, 5 and 6, and in `tests/live_gallery.R`
    `live_run()`, `live_refine()`, `LIVE_FILES`, `LIVE_FILES_3B`, `LIVE_REFINE`, `first_counts()`,
    `live_phase4_html()` and `live_chart_html()`. The page keeps Phase 5 and gains Phase 6.
  - `tests/llm_check.R` step 8 and `live_chat()` in `tests/live_gallery.R`: `tests/data/orders.csv` read
    with `-99` and `N/A` as missing, one label call, row is "one order", twelve turns through `chat_turn()`
    with the selecting the plan says, then `summarize_charts()` for every chart on the canvas; calls are
    counted and the run stops at 24 (`LIVE_MAX_CALLS`; the manager allowed 24 for the one run); saved as `phase6`, shown under "Phase 6".
  - `tests/smoke.R`: a section "Phase 6 D" (18 checks, 6-D 1 to 18); 285 checks in all, 285 pass. Single
    mutations of `R/ui.R` (29, in scratch) each make at least one 6-D check fail.

### Finding: shinychat 0.4.0 does not sanitise assistant messages

File: `lib/shiny/shinychat.js` in the installed package (`C:/Users/keval/AppData/Local/R/win-library/4.6/shinychat/`).
An assistant message is drawn through remark, remark-rehype with `allowDangerousHtml` and rehype-raw, and
no sanitiser. Three facts follow:

1. Raw HTML in the text is allowed: a tag becomes a real element, so an `<img onerror=...>` in a file
   value or a model reply would run.
2. `javascript:` links are kept: a markdown link keeps its address (the link handler only adds
   `target` and `rel` to http and https links and does not filter the scheme).
3. Any element with class `suggestion` (or a `data-suggestion` attribute) becomes a clickable card, and with
   class `submit` a click sends its text as the analyst's message. Text from a file or a model could
   therefore put words in the analyst's mouth.

Only the analyst's own messages (role "user") go through rehype-sanitize. Nothing in the R side of
`chat_append_message()` escapes anything.

**The rule that follows: no text from a file or from the model reaches `chat_append_message()` except
through `md_text()`.** `md_text()` backslashes every ASCII punctuation mark (CommonMark's one escape for
all of them) and writes `&`, `<`, `>` as entities, so no emphasis, link, image, code, list, heading, table,
tag or entity can start; it also stops autolinks: the backslash on `:` and `.` stops `http://`, `https://`
and `www.`, and an e-mail address (found in the text after the escapes are undone, so nothing but a break
in the text stops it) has its `@` written as `<span>@</span>`, which the reader sees and copies as a plain
`@`, with no invisible character (checked against commonmark with `extensions = TRUE`, which implements
the GFM autolinks, not against shinychat's own remark). A suggestion's `data-suggestion` value is
`htmltools::htmlEscape(attribute = TRUE)` and its text goes through `md_text()` too; a `next` entry is put on
one line. `say()` in `R/ui.R` is the only place that calls `chat_append_message()` and takes R's own wording
only. `tests/smoke.R` (6-D 18) reads `R/ui.R` as code and fails if there is a second
`chat_append_message()` call, or a `say()` call whose text is not built only from strings, `SETUP_*`
constants, a few named symbols, numbers, `md_text()` or the helpers that call it (`chat_reply_text()`,
`story_line()`), joined by `paste()`, `paste0()`, `c()` and `if`. Later phases keep to this rule.

### The live run

`tests/data/orders.csv`, read with -99 and N/A as missing: one label call, twelve chat turns, then
headlines and summaries for the 11 charts on the canvas. 16 calls of the 24 allowed: 1 label, 12
chat, 3 summarize (2 batches and 1 repair). No chat turn needed a repair, and every turn came back
as the kind the prompt expected: turn 4 added a chart, turn 5 asked which chart, turn 6 answered
with a chart, turn 7 told, turn 12 refused the pie. The one repair was for "half" in a histogram's
summary ("the middle half"), which the facts do not back with a multiple. 11 of 11 texts checked.
Input tokens 38,767 fresh and 80,282 from the cache (the 6,924-token system prompt after the first
turn); 13,192 out; 116 s in calls.

### Departures

- bsicons is not installed: card buttons carry words, not icons.
- A different file clears the canvas, the selection, the texts and the last exchange; the same file read
  again keeps them.
- "Changed since this was written" compares the spec's hash, so Undo back to the spec a text was written
  for clears the mark; a data change does not clear.
- "Label the columns" is matched exactly (it was matched ignoring case) and is on offer only while its
  button is: after the label step, or when the dictionary was ready from the start, the text says so and
  makes no call.
- Phase 3 and Phase 4 sections are no longer on the live page (their runs went with the suggest and
  refine calls); the saved run still holds them.

### Not seen

Nobody has seen the screen with a file in it in a browser: what a click does on a card, the suggestion
cards, the buttons being disabled during a call, and the dark-mode buttons are covered by
`shiny::testServer()` and by reading the code only. Kevin's own run is the check.

## Phase 5, 2026-11-18: headlines and summaries, every number checked

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5`: 4 calls (2 and 2 repairs).

### Built

- Reflex files: `summary.md` (new, 10 reflexes, the `summarize` call's only file) and `refine.md`
  0.2; checksums in `REFLEX_SHA`.
- `R/spec.R`: a group whose x has fewer than `SPEC_FIT_MIN_DISTINCT` (10) different values, or whose
  fit raises a warning or an error (`fit_works()`), gets no curve and the note "No curve for
  <group>: too few different values of <x>." (a failed fit: "the curve could not be fitted."); the
  code leaves it out too. `spec_facts(spec, table, cb, exploratory)`: the facts of each family,
  from the plotted table, names of id and text columns as tokens; `fact_num()` and the other
  formatters write each value one way.
- `R/reflexes.R`: `check_numbers()` (values, not strings; rounding keeps two significant digits;
  filter and top_n values; years in the facts; one to twelve as words) and `check_words()` with
  `SUMMARY_FORBIDDEN`. `summarize_charts()` and `summarize_inputs()`: batches of `SUMMARY_BATCH`
  (8), one repair for the charts that failed, names put back, `checked`, and the spec's hash
  (`spec_hash()`).
- `R/ui.R`: the "Headline and summary" box in the wide view (Write, two boxes checked on every
  edit, the one-line result, "The chart has changed since this was written." with Write again);
  the title box checked the same way; the headline above a card's chart; the report button above
  the cards. `app.R`: `stories` in the shared state.
- `tests/smoke.R`: 213 checks (184, the summarize prompt check, and 28 for Phase 5).
  `tests/llm_check.R` step 7 and `live_summary()` in `tests/live_gallery.R`; the page has a
  "Phase 5" section.

### The live run

Ten charts, all checked in the end: 7 at once, 3 after a repair. The repairs were for 1,851 (the
model added rows used and rows left out), "one" (in "the only positive one", read as the number 1)
and 8 (the number of regions, which a bar's facts do not state). Input tokens 7,343 fresh and
3,537 from the cache (the 1,179-token system prompt, after the first call).

### Departures

- `spec_facts()` takes `exploratory`, which a chart holds and its spec does not.
- The CHARTS block gives "One row is" for each chart, so the live run can send charts of three
  files in one batch through `summarize_inputs()`; `summarize_charts()` is that for one file.
- A chart missing from a reply is not sent in the repair call; only charts whose text failed are.
- A fit that fails with enough different values gets its own note, not the "too few" one.
- The report button counts the charts it will send, not all the report's charts.
- The wide view was checked with `shiny::testServer()`, not in a browser.

### Noticed, not changed

- A histogram's top bin can reach past the data (34.8 to 45.2 on scores that end at 40); the facts
  give the bin's edges as ggplot2 draws them.
- A heatmap's row and column "mean" is the mean of the cells, not of the rows behind them, and the
  facts do not say so; the model wrote it as the goalkeepers' mean age.
- "one" as a pronoun fails the number check.

## Phase 4, 2026-11-18: the chat that refines a chart

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5`: 14 calls.

### Built

- Reflex files: `refine.md` (new, 7 reflexes) and `suggest.md` 0.3; checksums in `REFLEX_SHA`.
- `R/spec.R`: a fitted curve is trimmed to the 1st and 99th percentiles of x within each colour or
  facet group of `SPEC_FIT_TRIM_N` rows or more (`fit_ranges()`, `fit_calls()`: one
  `geom_smooth(data = ~ filter(.x, ...), xseq = ...)` per such group, one untrimmed layer for the
  smaller groups), for loess and linear. A slope's colour note comes only past the palette's own
  limit. A sideways grouped bar dodges with `position_dodge(reverse = TRUE)`, so the first legend
  entry is the top bar.
- `R/reflexes.R`: `CHART_FILES` (seven files) for both `suggest` and `refine`, so their system
  prompts are identical; `CALL_REPLY` and `reply_format()` end each user message with its own
  file's reply format. `refine_chart()`, `assemble_refine()`, `refine_kind()`, `new_chart()`,
  `chart_apply()`, `chart_undo()`, `chart_reset()`, `chart_columns()`.
- `R/ui.R`: charts get ids (`state$charts`); the report holds ids. Each card has "Refine", which
  opens the wide view: the chart, its notes and rule, Interactive view, Show code and Add to report
  on the left; Back to all charts, five wording boxes (`updateOn = "blur"`) with Apply wording, Undo
  and Reset, and a shinychat chat on the right. Each chart keeps its chat, history and last
  exchange. `mod_explore_server()` takes `ask`, for the test's stand-in.
- `app.R`: shinychat in `APP_PACKAGES`; `charts` in the shared state.
- `tests/smoke.R`: 184 checks (166 and 18 new). `tests/llm_check.R` step 6 and `live_refine()` in
  `tests/live_gallery.R`; the page has a "Phase 4" section.

### shinychat 0.4.0, as installed

- `chat_ui(id, ..., messages, greeting, placeholder, width, height, fill, icon_assistant,
  enable_cancel, footer)`: `messages` is a list of `list(role, content)`.
- The analyst's message arrives as `input[[paste0(id, "_user_input")]]`.
- `chat_append_message(id, msg, chunk = FALSE, operation, icon, session)` appends one complete
  message (`msg = list(role, content)`).
- The client disables its own input from the moment a message is sent until a complete message is
  appended (`inputDisabled` in its JavaScript); there is no server function to disable it, and none
  is needed.

### The live run

14 turns: 8 specs, 2 questions back, 4 cannot, no failure, no repair; 36 s. Input tokens 24,283
fresh and 80,080 from the cache: after the first call every turn read the 6,160-token system prompt
from the cache, across all three files.

### Against refine.md

- `smallest_change`: "just show 2015 against 2024" also changed the line to a slope.
- "add a straight line instead of the curve" on a chart with no curve: the say speaks of the
  curve becoming a line.
- "title it Islands pulled ahead": the title was copied exactly, but the say adds that the title
  states a finding not checked against the values, which `analyst_words` says is not the model's
  concern.

### Departures

- The live run used the codebooks labelled in the saved run, so it made no label call; it is saved
  in `tests/live_replies.rds` as `phase4`, beside the Phase 3b run.
- A refine reply is not passed to `llm_json()` with a validate function, so a reply with more
  than one of spec, ask and cannot, or none, fails at once instead of being retried.
- The wide view and the chat were checked with `shiny::testServer()`, not in a browser.

### Noticed, not changed

- The football goalkeepers' Attack has 8 distinct values; a loess curve on that group fails
  however it is drawn, and ggplot2 leaves it out with warnings (the 3b chart of attack against
  defence coloured by position).

## Phase 3b, 2026-11-18: fixes after the first live run

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5`: 5 calls.

### Built

- Reflex files `core.md`, `comparison.md` and `suggest.md` at version 0.2 (new reflex
  `axis_labels`); checksums in `REFLEX_SHA`.
- `R/spec.R`: `SPEC_DPI` (192) and `spec_png()`, which draws a chart at its size in inches with
  `ragg::agg_png()` when ragg is installed and `grDevices::png(type = "cairo")` otherwise. The
  Explore tab shows it with `renderImage()` at its size in CSS inches (96 CSS pixels each);
  both galleries draw at `SPEC_DPI` (the gallery through knitr's `ragg_png` device).
- Ties at the `top_n` cut are all shown when they make at most `SPEC_TOP_MAX`, with the note "n was
  asked for; m are shown, because values tie at the cut."; the lint field `.top_n` carries m into
  the subtitle ("Top m of N"), the colours and the code (`slice_head(n = m)`). Otherwise top_n
  and the old note, which now says "the 1 shown is" for one value.
- A fitted curve on `SPEC_FIT_TRIM_N` (100) rows or more is fitted on every row and drawn at
  `SPEC_FIT_POINTS` (80) values between the 1st and 99th percentiles of x, through
  `geom_smooth(xseq = seq(...), na.rm = TRUE)` (`.fit_range`; on the log10 scale when `log_x`).
  The code does the same.
- `R/reflexes.R`: `data_safe()` writes `<DATA>` and `</DATA>` (any case) as `[DATA]` inside the
  DATA block and the pick call's block. The call record has `tokens_in` (fresh) and
  `tokens_cached`; the Explore tab's foot shows both.
- `R/data.R`: `CODEBOOK_MAX_DETAIL` is 60.
- `tests/smoke.R`: 166 checks (157 and 9 new). `tests/llm_check.R` step 5 and `LIVE_FILES_3B`
  in `tests/live_gallery.R`: five suggest calls on the codebooks labelled in the saved run.

### The live run

5 calls, no repair, no failure, 37 s; input tokens 14,972 fresh and 21,700 from the cache; 4,409
out. The first call wrote the cache; each of the other four read the system prompt from it
(5,425 tokens). All 15 charts were valid the first time. No spec repeats a column's label as an
axis title or restates `top_n` in a subtitle, and no measure is in more than two suggested charts.
"Which regions grew most" is now a slope of the 8 regions.

### Departures

- Three Phase 2b checks and two Phase 3 checks expected the old behaviour (10 bars for FH's top
  10, where 11 tie; 40 columns to a call); they now expect the new one. The count is unchanged.
- The live run used the labels of the Phase 3 run (saved in `tests/live_replies.rds`), so it made
  no label call: the prompt's five calls are all suggest calls.
- `na.rm = TRUE` on the trimmed curve: with colour or facet groups, each group's loess is NA where
  xseq runs past its own data, and ggplot2 warned (seen in the live page; a check now covers it).
- The tabs were checked with `shiny::testServer()`, not in a browser.

### Noticed, not changed

- The slope of 8 regions gets the lint note "8 colours are hard to tell apart; highlight the few
  that matter, or use small multiples (facet)", which `few_colours` v0.2 now allows for a slope.
- With colour groups and `fit: linear`, each group's line runs across the whole trimmed range,
  past its own data.

## Phase 3, 2026-11-18: the first model calls (labels and suggestions) and the Explore tab

Branch `chart`. Not pushed. One live run, on `claude-sonnet-5-5`: 21 calls (the ping and 20).

### Built

- `R/reflexes.R`: QuestionR's parser, cut to the format in `www/reflexes/README.md` and as strict
  (a stray line, a missing Version, an unknown field or section stops the app, naming the file and
  the reflex); `CALL_FILES`, `check_reflex_files()` at start-up, `reflex_labels()`,
  `assemble_system()`, `data_block()`, `assemble_user()`, `prompt_hash()` (sha256 with digest);
  the pick call's words (`PICK_SYSTEM`, `PICK_ASK`, `PICK_FORMAT`); `label_columns()` and
  `suggest_charts()`, each taking `ask = llm_json`; the record of every call.
- `R/spec.R`: `spec_check()` reads its rules from tables (`SPEC_FAMILY_ROLES`, `SPEC_REQUIRED`,
  `SPEC_FAMILY_FNS`, `SPEC_FIELD_FAMILIES`, `SPEC_KIND_TEXT`); `spec_reference()` writes the same
  tables out as plain text (3,546 characters). Legend keys of see-through points are solid.
- `R/data.R`: an `ai_guess` label keeps `sure`; `accept_label()`; editing a label drops `sure`.
  `CODEBOOK_MAX_DETAIL` is 40.
- `R/ui.R`: Codebook tab: "Suggest labels", "AI guess" and "check this" tags, Accept, "Accept all AI
  labels on this page", the new count line, the row guess as a placeholder with "Use this". The
  Explore tab. The Report tab shows how many charts were added. `busy_button()` disables a button
  in the browser while its call runs.
- `tests/smoke.R`: 157 checks (120 before, 37 new), with `REFLEX_SHA`. `tests/live_gallery.R` and
  step 4 of `tests/llm_check.R`; `CHART_LIVE_STEPS` chooses the steps.

### The live run

20 calls (label 4, pick 4, suggest 12), no repair, no failure; 111 s; 94,493 tokens in and 12,037
out. All 26 charts were valid the first time. The suggest system prompt is 15,477 characters, the
same for every call. The pick call ran for every football question, since 44 columns are in play.

### What the model did not follow

- `suggestions`: "Leave out columns of type id or text unless they name the rows": the football
  suggestions include a bar of Nationality (text, 86 values).
- `sorting`: "Leave `sort` out": two bars set `sort: value_desc`.
- `two_points_slope`: "Which regions grew most between 2015 and 2024?" got a line per region
  (faceted, ten years), not a slope; its `say` gives the eight colours a slope would need. With 8
  regions the rules conflict: a slope cannot be faceted and `few_colours` stops at 7.
- `title_describes` and the prohibition ("no ... number in any field"): subtitles and `say` carry
  counts taken from DATA ("All 8 regions", "all 80 region-years", "The 15 countries with the largest
  2014 scores"). None states a finding.
- `suggestions` ("each a different comparison on different columns"): the FH suggestions use
  `pr_2014` in three of five charts.

### Departures

- Commit B holds all of `R/reflexes.R`, the two calls included; their stand-in tests came with D.
  B's checks of the suggest prompt need `spec_reference()`, committed in C.
- The no-eval check: no file in `app.R` or `R/` calls `parse()`, `str2lang()`,
  `str2expression()`, `eval_tidy()` or `evalq()`, and the only `eval()` calls are the three in
  `spec.R` on calls R builds from a checked spec. Read from the parse data.
- A pick reply that cannot be read stops the request with one sentence (`PICK_FAILED`), rather than
  going on with no column in detail.
- The live run skipped `llm_check.R`'s structured-output checks (2 and 3); check 3 calls an OpenAI
  model on OpenRouter.
- The tabs were exercised with `shiny::testServer()` and a stand-in model, not in a browser.

### Noticed, not changed

- The tie note says "the 1 shown are the first alphabetically" when one value is shown (R/spec.R).
- A column name or label holding the text `</DATA>` would close the DATA block early; nothing
  escapes it.
- `.rscignore` does not list `phase1_prompt.md` to `phase3_prompt.md`.

## Phase 2d, 2026-11-18: last renderer fixes

Branch `chart`. Not pushed. No model calls. The renderer is closed.

### Built

- `R/spec.R`: a scatter with more than `SPEC_OVERLAP_SHARE` of its rows on shared positions draws
  every row, moved at random by at most `SPEC_JITTER` (0.4) of the smallest gap between distinct
  values on each axis (`resolution(x, zero = FALSE)`, on log10 values for a log axis), with
  `position_jitter(seed = SPEC_JITTER_SEED)`, see-through (`SPEC_ALPHA`), and the note "Points are
  moved slightly so that rows sharing a position can be seen." The lint field `.counted` is now
  `.jitter`; `geom_count` and the "Rows" size legend are gone. A bubble chart with more than
  `SPEC_BUBBLE_N` (60) bubbles gets the note "A bubble chart with this many points is hard to
  read; filter, or use a scatter."
- `R/theme.R`: batlow and vik removed (15 palettes, all drawable with paletteer alone).
- `R/data.R`: `read_data(path, name, missing, encoding = NULL)` and `reread_data(..., encoding =
  NULL)`; `NULL` is the guess. A file readr makes no guess for and whose first lines are not valid
  UTF-8 is read as windows-1252, with the guess note. `DATA_ENCODINGS`.
- `R/ui.R`: the Data tab's "File encoding" select ("Detected (<what was used>)", UTF-8,
  windows-1252, ISO-8859-2, ISO-8859-15), used by "Read again". An uploaded codebook's encoding is
  used to read its file, and the select shows it.
- `tests/smoke.R`: 120 checks. 2b-8 (sized by count) is replaced by two 2d-1 checks; 2d-2 to 2d-5
  are new. The colour table prints the diverging palettes.

### Departures

- Check 2b-8 was removed, since 2d reverses it; 120 = 115 - 1 + 6.
- The jitter rule still skips a highlighted scatter, as 2b-8 did: the highlight's labels sit at the
  real positions.
- `read_codebook()` no longer fills a missing encoding with "UTF-8": a codebook written before 2b
  has none, and its file's encoding is then guessed.
- No guess at all from readr (it made none for the short ISO-8859-2 test file) used to mean UTF-8,
  and the read failed; now such a file is checked for valid UTF-8 first.

## Phase 2c, 2026-11-17: colour palettes from paletteer

Branch `chart`. Not pushed. No model calls. The tabs are unchanged.

### What the installed paletteer (1.7.0) provides

- `paletteer_d(palette, n, direction, type)` for a discrete palette and `paletteer_c(palette, n,
  direction)` for a continuous one; the palette is named "package::palette". Also
  `paletteer_dynamic()` and `scale_colour_paletteer_d/_c/_binned` and the fill versions.
- Name tables: `palettes_d_names` (package, palette, length, type, novelty), `palettes_c_names`
  (package, palette, type), `palettes_dynamic_names`, and the colours themselves in `palettes_d`.
- A discrete palette needs only paletteer, which holds its colours (khroma's bright drew without
  khroma). A continuous one is drawn by its source package: `viridis::` needs viridisLite
  (installed), `scico::` needs scico (not installed, so batlow and vik cannot be drawn here).
- Every candidate is in the tables: khroma bright, muted, vibrant (discrete) and sunset (discrete,
  divergent); viridis magma, cividis, mako and scico batlow, vik (continuous); ColorBrewer Blues,
  YlGnBu, RdBu, PuOr and BrBG as `RColorBrewer::` (discrete) and also as `grDevices::`
  (continuous). The `RColorBrewer::` versions are used: they are ColorBrewer's own colours and
  need no package beyond paletteer.

### Built

- `R/theme.R`: `CHART_PALETTES` (17 entries), `paletteer_installed()`, `palette_colours()`,
  `chart_palettes(kind)`, `chart_palette(n, name)`, `chart_palette_max()`, `chart_sequential()`,
  `chart_diverging()`, `chart_palette_default()`.
- `R/spec.R`: `spec_check()`, `spec_table()`, `spec_plot()`, `spec_code()` and `spec_widget()` take
  `palette`; the hard limit on colours is the chosen qualitative palette's `max`; the heatmap's
  `midpoint` fills with the diverging palette centred on it (`rescale_mid()` as the scale's
  rescaler, and the same in the cell-label contrast).
- `probe/app.R` lists paletteer. It is not in `APP_PACKAGES`.
- `tests/smoke.R`: 115 checks (111 before, 4 new) and the printed colour-distance table; the
  gallery ends with a palette section (19 charts).

### Departures

- A third entry needs no package: "Blue-red (built in)", `grDevices::hcl.colors(11, "Blue-Red
  2")`, written out. Without it there would be no diverging palette when paletteer is missing;
  `chart_palette_default()` uses it then, and ColorBrewer RdBu otherwise.
- `spec_check()`, `spec_table()` and `spec_lint()` also take the palette (or its max), since the
  colour limit is now the palette's.
- `spec_widget(plot, palette)`: the widget is converted from the plot, so it keeps the palette the
  plot was drawn with; another palette needs a new `spec_plot()`.
- `paletteer_installed()` uses `find.package()`, not `requireNamespace()`, which the smoke test
  forbids in `R/` (and CLAUDE.md forbids `system.file()`).
- `theme.R` uses base `Filter()` and `vapply()` rather than purrr, to keep the file free of
  packages beyond ggplot2, grDevices and (optionally) paletteer.
- A qualitative palette with fewer colours than the lines of a chart (Tol bright and vibrant hold
  7; the panel has 8 regions) draws the lines in one colour, as for more than 8 before; the
  palette section shows this.

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
