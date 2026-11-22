# chaRt, Phase 9: finish. A dashboard that looks published, and charts that move

Kevin wants the app near complete in this phase. Two things are left that he has asked for: the
exported dashboard must look like a published page (the manager opened the Phase 8 export and it
does not yet), and every chart should be able to animate ("as if MP4 visuals from a magazine's
website"). Then a closing pass so the folder can be deployed.

## How the work is done

No mailbox this time: the three Phase 8 checkpoints went unanswered and cost time. You are the
lead; use one Sonnet worker per part, one at a time, and rerun the smoke test yourself after each
part. Where this prompt leaves a choice, take the option that keeps the chart truthful and the
app working without a new dependency, say what you chose in the report, and go on. Stop and ask
Kevin in the chat only before removing a file, installing a package, or a live run beyond the
calls allowed here. First commit `www/methodology.md` (0.2: one template reworded) and add
`phase9_prompt.md` to `.rscignore` by name. The report goes to `manager/done-9.md` and a new top
section of `STATUS.md`.

## Rules

As before: branch `chart`, small commits, no push, commit only files under `chaRt/`, tests from
PowerShell, Sonnet only, no reply run as code, reflex files and `methodology.md` are not yours to
edit, every function and argument confirmed in the installed package, no `for` loops, no new
files in `R/`, no em-dashes in prose, text reaching the chat through `md_text()`, every device
through `chart_device()`, no Quarto, no pandoc, no X11. Do not start WSL or any other system on
this machine. **Look before you say done:** every item marked (look) is opened as a picture, a
page or a video and looked at, at desktop and at phone width where it is a page.

## Part A. The exported dashboard and codebook (seen by the manager; all look)

What the manager saw in `tests/dashboard_clean` and `tests/dashboard_dark`:

1. **The page uses half the screen.** Content is about 800 pixels wide and sits at the left of a
   1400 pixel window. Centre it; let it grow to about 1240 pixels; two cards per row from 900
   pixels up, one below.
2. **Holes in the grid.** A full-width interactive card leaves an empty cell beside the card
   before it. Lay the cards out so no row has a hole: an interactive card takes a full row and
   the card before it widens to a full row when it would otherwise sit alone.
3. **Chart text is too small to read,** and on a phone it is illegible. The 300 dpi picture is
   drawn large and scaled down. Draw each exported chart at the size it is shown: a desktop
   picture whose text comes out near 12 CSS pixels at the card's width, and a second, narrower
   drawing of the same chart for screens under 600 pixels (fewer axis breaks, labels that still
   fit; use the label box check from Phase 7b on it), chosen by the page with a `<picture>`
   element. Both at twice the display size in pixels so they are sharp. The 300 dpi PNG and the
   SVG stay in `charts/` for print.
4. **Everything is said twice.** A card shows the headline, then the chart's own title inside the
   picture, then the source line inside the picture, then the source line again under the
   summary. In the dashboard: the headline is the card's heading; the chart's title is its
   subtitle in the card's HTML; the picture is drawn without title or caption; the source line
   appears once, under the card. The `charts/` files keep title and source inside the picture.
5. **Dates on axes** read "2022-01-01". Format a time axis by its span: years, "Jan 2022", or
   "3 Jan" (in the app as well as the export).
6. **Value boxes** are grey slabs. Give them the style's accent (a rule or the number in the
   accent colour), and let the analyst add up to three key numbers from the facts of chosen
   charts in the export dialog (each a fact line picked from a list, never typed), shown as
   further boxes with their chart's name under them.
7. **The page should look like the chosen style,** not like a default page: the style's title
   face for headings, its background, its rules. A masthead block: title, subtitle, author and
   date, then the introduction in a readable measure (about 70 characters). A foot with the
   About text and "Made with chaRt".
8. **The codebook** is a list of grey boxes. Make it a document: a summary table of all columns
   at the top (name, label, type, role, missing share), then one compact section per column with
   a small drawn summary (a histogram for a measure, bars for a group's levels, a line of counts
   over time for a date; nothing for ids, text and long categories). "Label: from the file"
   reads as if that were the label: when a column has no label, show a dash and say "no label
   given". No row values.
9. **Print.** Open the print preview of the dashboard and the codebook (confirm how; headless
   Chrome's `--print-to-pdf` if Chrome is on this machine) and look at the PDF: no card split
   across pages, backgrounds printed light whatever the style.
10. Export a five-chart dashboard in **every one of the six styles** from stand-in charts with
    sensible stand-in specs (sorted bars, a time axis in order, a scatter without a column of
    points at zero), into `tests/dashboard_<style>/`, and look at each at 1400 and 390 pixels.

## Part B. Animation

**Kevin's ruling: every chart family animates where it can.** The manager's conditions, which
keep that honest: the animation is an entrance that ends on exactly the static chart; axes,
scales and titles are fixed from the first frame at their final values; numbers (value labels,
annotations, end labels) appear only once the marks are at their true size; it is short; and a
reader who has asked their system for reduced motion gets the static chart.

1. **How.** Frames are drawn by our own renderer through `chart_device()` and encoded to MP4 with
   `av` (installed here: 0.9.6; confirm `av::av_encode_video()` and its arguments). A function
   `spec_frames(spec, data, palette, style, n)` returns the plots for progress 0 to 1;
   `spec_video(spec, data, ..., file)` draws and encodes. No gganimate. If `av` is not installed
   the Animate control is hidden and Start here says videos are unavailable on this server.
2. **The motion, by family.** Progress is eased (slow, fast, slow; a cubic ease in and out).
   - line, slope: the lines draw from the first x to the last, the newest point interpolated
     between data points; all series together.
   - bar, histogram: bars rise from the axis to their value, in the order drawn, each starting
     slightly after the one before.
   - dot: dots travel from the axis to their value.
   - scatter, bubble: points appear in order along x; then the fitted curve draws.
   - box: each group's box opens from its median outward, groups in order.
   - heatmap: cells fill one column (or row, when x is not ordered) at a time.
   - small multiples: all panels move together.
   - Then labels, annotations and names fade in over the last part; then the finished chart is
     held.
3. **Scales never move.** Take the limits and breaks from the finished chart's built panels and
   pin them for every frame; a check compares each frame's built limits and breaks with the
   last frame's. The last frame must equal the static chart: compare the built data of the last
   frame with `spec_plot()`'s.
4. **Timing and size.** 24 frames a second; about 3 seconds of motion, 0.6 for the labels, and a
   2 second hold made by repeating the last frame's file in the encoder's input, not by drawing
   it again. 1920 by 1080 for the download; 1280 by 720 for the card and the dashboard. Measure
   the seconds per frame and per video for each family and report them. If a video takes more
   than 45 seconds, lower the drawn frame count (12 a second, each shown twice) before lowering
   the size.
5. **In the app.** Each card gets "Animate": the working line says "Drawing the video" with a
   count of frames done if the installed shiny can show progress from inside the call (confirm;
   else the plain line), the card then shows the video in place of the picture (autoplay, muted,
   loop off, controls on, `playsinline`), with "Replay", "Download MP4" and "Picture" to go
   back. A chart whose spec changes drops its video. In the chat, with a chart selected, a
   message that only asks for it ("animate", "animate this", "play it", "make it a video", "make
   a video of this") is handled by R with no model call; with none selected R answers "Click a
   chart first, then ask me to animate it."
6. **In the export.** The dialog's per-chart choice becomes picture, interactive or video. A
   video is embedded in `dashboard.html` as a base64 MP4 in a `<video>` element with the static
   picture as its poster and as what is shown under `prefers-reduced-motion`; it plays once when
   it scrolls into view (a few lines of script in the page; no library). The MP4 also goes in
   `charts/`. Say what a five-video dashboard weighs. A video carries no rows; say so beside the
   choice for the families drawn from rows.
7. **Look (all of it).** Encode one video per family in Clean and in Dark. For each, extract the
   first, a middle and the last frame as PNG (`av` can read frames back, or keep the frame files)
   and look at the three: axes identical, nothing clipped, labels only at the end, the last equal
   to the static chart. Put the videos and a page `tests/videos.html` that shows them all in
   `tests/` (git-ignored) for the manager and Kevin.
8. Checks (no model call): frames' scales pinned; last frame equals the static chart; labels
   absent before the label phase; the chat phrases with and without a selection; the video
   dropped on a spec change; the export with a video has a poster and the reduced-motion rule;
   `av` absent hides the control.

## Part C. Closing pass

1. **The probe** reports, for the work server: av present and a ten-frame encode; seconds to draw
   30 frames at 1280 by 720; and everything Phase 8 added. It is what Kevin publishes first.
2. **A deploy check without deploying:** list what a Connect bundle of `chaRt/` would hold by the
   `.rscignore` and the manifest's packages (confirm how `rsconnect` lists them without
   publishing; do not publish), and its size. Fonts, reflex files, `methodology.md` in; tests,
   prompts, mailbox, probe out.
3. **README.md** for a new user: what it does, the five-minute path (file, dictionary, ask,
   choose, export), what it will not do, the key rule, how to run locally, how to publish the
   probe then the app. **STATUS.md**: a current-state section of at most 80 lines at the top
   (what works, what is unverified, known limits), and the phase history moved under one
   "History" heading unchanged.
4. **Live, at most 10 calls (Sonnet):** on `tests/data/orders.csv`: label the columns; "How has
   revenue changed by region?"; "which product categories bring in the most revenue?"; "is
   satisfaction lower when shipping takes longer?"; write headlines; then export all three, one
   as picture, one as interactive, one as video, in the Magazine style, to
   `tests/dashboard_live/`. Open it and look. This is the first dashboard with real headlines.

## Part D. Summary statistics (added by Kevin after the rest was written; do it after Part A)

Descriptive statistics of the file, computed by R with no model call, in three places.

1. **One function,** `summary_table(data, cb, measures = NULL, by = NULL)` in `R/data.R`, returns
   a tibble. Missing codes from the dictionary are already NA.
   - For a measure: n, missing (count and share), mean, standard deviation, minimum, first
     quartile, median, third quartile, maximum, and the 95% confidence interval of the mean (item
     5). Numbers formatted by the facts' number functions.
   - For a group-like column: n, missing, number of levels, and the levels with count, share and
     the share's 95% interval
     (all when there are at most 30, else the 10 most frequent and "and k others").
   - For a date or time column: n, missing, first, last, and the usual gap.
   - For ids, text and long categories: n, missing and distinct count only.
   - With `by` (one group-like column of at most 30 levels): the measure rows repeated for each
     level, plus "All rows".
   - Each column uses the rows it has (n is shown for each, since it differs by column).
2. **Data page:** a "Summary statistics" section under the dictionary: the table for every
   column, a select "By group" (none by default), and "Download CSV". Shown once a file is read;
   it does not wait for labels.
3. **A table card on the canvas:** a button "Add a summary table" opens a dialog: measures (one
   or more), by group (optional), a title. The card shows the table (a plain HTML table in the
   style's type, numbers right-aligned), has the "In dashboard" switch, Move, Edit text (title
   only) and Remove, and no Interactive, Code, Headline or Animate. In the chat, a message that
   only asks for it ("summary statistics", "summary table", "describe the columns") is answered
   by R opening that dialog, with no model call.
4. **Export:** a chosen table card is a card in `dashboard.html` (a real table, not a picture),
   and `charts/` gets it as CSV. `codebook.html` gets the per-column statistics in its summary
   table at the top.
5. **95% confidence intervals, assuming a simple random sample (Kevin's ruling).**
   - For a measure's mean: mean plus or minus t times the standard error, with standard error
     sd / sqrt(n) and t from `stats::qt(0.975, n - 1)`; shown as two columns, "95% CI low" and
     "95% CI high"; none when n is under 2 or the sd is 0 or NA. No finite population correction.
   - For a level's share: the Wilson score interval (write it out in base R; do not use
     `prop.test`'s continuity correction), on the rows that are not missing for that column.
   - With `by`, within each level, on that level's own n.
   - No interval for a median, a quartile, a minimum or a maximum, and no tests.
   - **The line under every table that shows an interval,** always, in the app, the CSV (as a
     comment row at the top or a `note` column; choose what opens cleanly in Excel) and the
     export: "95% confidence intervals assume a simple random sample of independent rows. No
     weights or sample design are applied; for clustered or weighted data the true intervals
     are usually wider. If the file is a complete count and not a sample, an interval has no
     sampling meaning." A table with no interval keeps the shorter line: "Descriptive statistics
     of the rows in this file. No weights or sample design are applied."
   - The column headers say "95% CI (SRS)". A switch "Show 95% CI" in the Data page section and
     in the table card's dialog, on by default.
   - For a measure whose dictionary type is a rating or other ordered score, mark the mean, the
     standard deviation and the interval with a note "treats the steps of the scale as equal".
   - Checks by hand on the ten-row fixture: the t interval for one measure and the Wilson
     interval for one share, each to four significant digits against values computed
     independently in the test (not by calling the function under test).
6. **Small groups.** With `by`, a level with fewer than 5 rows is marked, and the export dialog
   warns once that a table shows statistics for groups of fewer than 5 rows, which can describe
   individuals. It is the analyst's decision; nothing is suppressed automatically.
7. **Privacy.** The table is drawn in the browser and written to the export; it is never sent to
   the model. A check that no chat message built after a table card is added holds any of its
   numbers beyond what the DATA block already carried.
8. Checks: each column kind; `by`; the scale note; the small-group mark; the CSV; the table card
   in the export; `SECRET_VALUE_123` in no summary; and the numbers against values worked out by
   hand for a ten-row fixture (mean, SD with n minus 1, quartiles by R's default type 7, and say
   in the table's note which quartile rule is used).
9. **Look:** the Data page section, a table card on the canvas, and the table in an exported
   dashboard in Clean and Dark, at both widths (a wide table must scroll sideways inside its
   card on a phone, not break the page).

## Report (`manager/done-9.md`)

0. Part D: what the three places look like; the hand-checked fixture; every choice made.

1. Files changed, with line counts; checks added and replaced; the smoke total.
2. Part A: for each of the ten items, what you saw after the change, at both widths.
3. Part B: seconds per frame and per video by family; file sizes; what the three frames of each
   family showed; every family that could not animate as written and what it does instead.
4. Part C: the bundle listing and size; the live run's output; what the live dashboard looked
   like.
5. What nobody has seen, what could not be confirmed, and every choice you made where this
   prompt left one.
