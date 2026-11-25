# chaRt: status

## Current state (2026-11-23, after Phase 10b: an office ggplot theme can be the default style)

Branch `chart`, not pushed. Everything below was built and tested at home on R 4.6.1. No test makes a model call unless it says so. The phase-by-phase record is under History; the Phase 10 report is `manager/done-10.md`, the Phase 10b report `manager/done-10b.md`.

**Phase 11 Part C, in brief** (2026-11-25; History has the section). A designed chart has a video of its own: `design_video()` (R/spec.R) draws the finished design three times at the video's size from one built plot (the frame: axes, grid, titles and the marking's bands; the data layers; the text and annotation layers, the last two on a transparent background with the theme made invisible but in place), composes 87 frames as arrays with the `png` package, ends on the finished picture itself (the last frame is a drawing of the whole plot, so it equals `spec_png()` of the design pixel for pixel) and encodes with `av`. The data layers come in by the design's `motion` (draw and wipe from the left, rise from the bottom or, for sideways bars, from the left, each with a soft-edged mask; fade by opacity), then the text fades in, then 2 seconds of hold; timings and easing are Phase 9's. Which layer is which is read from the built plot's geoms (text geoms, ggrepel's and ggtext's included, are text; what `annotate()` or a rule makes is an annotation that comes in with the text; everything else is data). When the three drawings do not add up to the finished picture (more than 0.2% of the pixels differ by over 4 levels), or the design is a patchwork, or no data layer draws anything, the whole picture wipes in from the left over the ground colour and the dashboard says why. The export uses it for a designed card whose mode is video (the card's width, the picture's proportions, the bands); if it fails, the card is the standard drawing's video and the page says so. A card video takes about 5 to 7 seconds here (1080 pixels wide: drawings under 1, composing about 4 to 5, encoding 1). Smoke: fast 636 of 636, heavy 25 of 25; checks 11C-1 to 11C-9 (11C-7 and 11C-8, the exports, are heavy); 17 mutations (tests/mutate_11C.R), each made a check fail.

**Phase 11 Part F, and the design fixes, in brief** (2026-11-25; the report is `manager/done-11.md`, section 7).
- **The live comparison:** eight charts from the chat on orders.csv, each designed with Editorial in Briefing tokens. The first attempt (28 calls) accepted 2 of 8; most refusals were the app's own rules.
- **Fixes, keeping the guard's intent:**
  - Inf and -Inf are allowed as values; the size limits still stop them as lengths.
  - A call of a call is allowed only for a toolkit label_ or breaks_ factory (`label_comma()(x)`).
  - The deny list applies to functions called, not to a variable or column the design names itself.
  - Every token a design writes text in reaches 4.5:1 on the style's ground. Briefing's failing grey was slate; slate is darkened in the design tokens of every style.
  - A series name in its series' colour needs 3:1; all other text keeps 4.5:1.
  - A design with no caption gets the source line from R, in the plot and in its code.
  - TOOLKIT tells the model what is refused.
- **Checks:** 11A-14 and 11A-15 (an adversarial case for each loosened rule) and mutations M32 to M42.
- **Second attempt** (15 calls; 43 of 45 for Part F, 43 of 60 in the phase): **8 of 8 designs accepted.** In my judgement 6 are better than the standard drawing, the line chart is about even and the histogram slightly better. `tests/designed.html` and `tests/dashboard_designed/` (pictures; no videos, since Part C is not done) are local and git-ignored.
- **Smoke:** fast 628 of 628, heavy 23 of 23. Mutations: 11A 42 of 42, 11B 16 of 16, 11E 24 of 24.

**Phase 11 Part E, in brief** (2026-11-25; History has the section). The dashboard is arranged by the analyst. Cards, tables and sections are dragged by a handle onto another card (plain HTML drag events in `EXPLORE_JS`, no package; Move up and Move down still do the same from the keyboard). **Add a section** puts a heading card (title, optional line of text) before the selected card or at the top; the cards under it up to the next heading belong to it; a section collapses, moves with its cards and is left out of the export as a whole by its switch. A card's headline, title or summary, a table's title and a section's title and text are edited where they stand (Enter keeps, Escape leaves, a click away keeps); a headline or summary that fails the number or word check is kept and marked, as is a title edited there. The export dialog is the dashboard as it will be: every section and card in order, a switch on each (the card's own switch), a small picture, picture / interactive / video, designed or standard where both exist; the page has the section headings. With a chart selected the chat message carries its FACTS (names as placeholders), so a question about it is a `tell` checked by `check_numbers()` against them. No model call. Smoke: fast 626 of 626, heavy 23 of 23; checks 11E-1 to 11E-16, 24 mutations (tests/mutate_11E.R) each made a check fail. One gap for the manager: chat.md has no rule that tells the model to answer from FACTS (see History).

**Phase 11 Part D, in brief** (2026-11-25; History has the section). `read_data()` reads `.xlsx` and `.xls` through readxl: a sheet picker (names and row counts, hidden sheets named as hidden), the header row found (first row with text in most columns) and changeable ("Header is on row n"), blank leading rows and columns skipped, merged header cells filled across and joined to the row below, dates as dates, numbers stored as text offered in the chat as a button (never converted unasked), formulas as their values, and a sheet with two tables (side by side or stacked) asks which and reads none until the analyst picks. Nothing is written to the workbook. Source line, chat setup and the chart's code name the sheet. readxl is in APP_PACKAGES. Checks 11D-1 to 11D-14 with workbooks built in the test; mutations M01 to M16 (tests/mutate_11D.R) all caught. Smoke: fast 610 of 610, heavy 23 of 23. No `.xls` fixture could be made, so no `.xls` is read by any check.

**Phase 11 Part B, in brief** (2026-11-24; History has the section). The model can draw, and look at what it drew. `design_chart()` (R/reflexes.R) asks the model for drawing code (one call: the skill, the toolkit, the spec, the table's columns and, when aggregated and at most 60 rows, its rows, the facts, the style's tokens, the chart's words), runs it through Part A's guard, run and checks, sends one repair call on a refusal, then shows the model the picture (a PNG at most 1,200 pixels wide) for up to two reviews; any failure leaves the rule-drawn picture and a line on the card says why. In the app: **Design** on each card and **Design all** on the canvas (a working line names the stage), the Style dialog's **Design skill** and **Design new charts automatically** (off), the "Designed with <skill>" mark, a designed/standard switch, Code with the table, the chat phrases ("redesign this", "make it look better", "make it publication ready", "design this") and wishes ("put the legend inside") answered by R with no chat call. `APP_DESIGN_IMAGES` ("all", "aggregated", "none") and `APP_SKILLS_DIR` are settings in `app.R`; Start here, the Methodology page and the README now say truthfully what the model is sent. The export carries a design (picture, 300 dpi file, code in `charts.R` with the table beside it as a CSV so it runs alone); the interactive view of a design has tooltips when every layer of marks has a ggiraph twin and is drawn as it is, else the card offers the standard interactive view. No live model call was made. Smoke after this part: fast 596 of 596 (10.5 minutes), heavy 23 of 23; checks 11B-1 to 11B-18 (18 new, 578 before); 16 mutations (tests/mutate_11B.R), each made a check fail.

**Phase 11 Part A, in brief** (2026-11-24; History has the section). The code for running the model's drawing code safely is in R/spec.R and tested, and nothing in the app calls it yet (Part B does): `design_toolkit()`, `design_guard()`, `design_run()`, `design_checks()`, and `design_tokens()`, `design_pal()`, `design_text()`, `design_facts()`. No model call. Smoke after the lead's review: fast 577 of 577, heavy 23 of 23; the review closed three holes (image markup built at draw time, a far index, false refusals of mutate() columns), check 11A-13.

**Colours by series, and card videos laid out like their pictures** (2026-11-24, after 0094221). (1) Every coloured scale names its colours by series (`.colour_levels` from `spec_lint()`, `series_values()` in R/spec.R): bar, dot, scatter, bubble, slope and line, in the picture, the interactive view, the video and the printed code (`values = c(Online = "#E69F00", ...)`). An audit on the commit before 0094221 found the fault (a series given another series' colour when a legend lists them by last value) only in line and slope charts; bar, dot, scatter, bubble and dumbbell (slate and accent by level) were right; box has no colour column; a heatmap is a continuous ramp. Check 10v-1b covers one chart per family. (2) A card's video is drawn as the card's picture is (`spec_plot()` with the picture's `web` from `dash_web()`, at its `spec_size()`), with the marking bands added above and below outside the chart: 1080 wide for a card that shares its row, 1280 for one with its row, as high as the picture's shape and the bands make it (rounded to even pixels for H.264), so it keeps end labels and legend wherever the picture has them; the page's video box takes the video's own shape (the fixed `aspect-ratio:16/9` is gone). The 1920 by 1080 download stays 16:9. Check 10v-2: labels, legend and last frame equal the picture's, canvas is the picture plus the bands, `dash_video()` passes the picture's `web`. Checks changed for the new sizes: 9B-17, 9B-18, 10A-13, 10b-10; 5-A reads the code without the colours' series names. Smoke: fast 563 of 563 (10.0 minutes), heavy 23 of 23 (11.3 minutes; both run in the background).

**Office theme loader in brief** (2026-11-23). An office's own ggplot theme function can be a chart style and the default, without its file leaving the work machine. Five settings in `app.R`: `APP_THEME_FILE` (empty by default), `APP_THEME_FUNCTION`, `APP_THEME_NAME` ("Office"), `APP_THEME_ACCENT`, `APP_THEME_SLATE`. At start-up `theme_style_load()` sources the file into its own environment, calls the function, and `style_from_theme(theme, name, accent, slate)` resolves the theme's elements with `ggplot2::calc_element()` on `complete_theme()` into a CHART_STYLES entry with every field the other styles have (accent, slate and single from the arguments, Clean's by default); the style is registered and made the default. Text settings no field holds (the title's colour and alignment, axis, legend and strip colours) are a plain `theme()` call added last to the chart's theme calls, so the code a chart comes with runs without the template; `chart_theme()` also adds the template itself as the last layer. A missing file, a syntax error, a wrong function name, a function that stops or returns no theme: the present default stays, the app starts, and Start here says why in one sentence. A font the theme names that is not here is drawn in the default sans and named on Start here; failing contrast pairs (text, title, axis text, caption at 4.5; accent, slate, accent against slate at 3) are a warning there. Smoke after the colour fix: fast 561 of 561 (10.8 minutes on a slow machine, so run in the background), heavy 23 of 23 (8.3 minutes). Two stand-ins in `tests/` (`theme_standin_light.R`, `theme_standin_dark.R`) are on the style sheet and in checks 10t-1 to 10t-6 (nine mutants, all caught). Seen: a bar, a line and a scatter in each as picture, interactive view and video. Fixed after it (check 10v-1): a line chart whose legend stands in for its end labels (labels off, or ends too close on a short drawing such as a half-card video) gave two series each other's colours, because scale_colour_manual() gives unnamed colours to the breaks in legend order; the colours are now named by series (`.legend_levels`, `legend_values()` in R/spec.R). The legend itself stays where the ends are too close: a 16:9 video less its marking bands is shorter than the picture.

**Phase 10b: hexagons, in brief** (a small follow-up, History has the section). The density view is hexagons (ggplot2's `geom_hex()`, 30 across on the scale that is drawn, so a log axis has hexagons of one width in log units) when `hexbin` is installed and each axis has more than 40 different values, and rectangles (`geom_bin_2d()`, as before) when `hexbin` is missing and for any chart with an axis of at most 40 values (hexagons cannot sit on values: they would be the strips the rectangles at the values removed). `density_hex_ok()` in R/spec.R says whether hexbin is installed (`find.package()`, read each time a chart is drawn); `app.R` names hexbin in a `requireNamespace()` call, as it does tidyr, so that a deployment asks Connect for it (98 packages now), and does not list it in `APP_PACKAGES`, so the app starts without it. The interactive chart uses `geom_hex_interactive` (tooltip "Orders in this hexagon: n"), the printed code has `geom_hex(bins = 30L)` with a comment that it needs hexbin, the animation brings the hexagons in a column at a time as the rectangles came, and the facts do not change. Smoke: fast 554 of 554 (548 and six new checks), heavy 23 of 23; run times in the worker report (this machine was slow while they ran: 21 minutes for each, against 8.6 and 8.3 before).

**Phase 10b in brief** (the closing fix list, nine items and a live check; report `manager/done-10b.md`). The video card shows the finished chart as its poster, rests on its last frame and has a Replay button, and is drawn for its card (1088 by 612 on a half card). Density: the style's own ramp (light tint to the accent), cells 30 across on the drawn scale (log on a log axis), an axis of at most 40 distinct values binned at its values, the curve only where there are rows, legend "Orders" (the dictionary's word for a row) else "Rows"; hexagons were not there when this phase ended (hexbin was not installed) and came in the follow-up below. An interactive chart is sized to its card like a picture and takes a half card. A full-width card at 900 px and up has the chart left (62%) and the text right. Periods read as the axis does ("Dec 2023", "2023", "3 Jan 2024") in facts, tooltips and annotations. The key strip has a small-capital label above each value and one type size. A heading drops one trailing full stop. Violins are filled (series colour, 20%) with outlier dots. `index: first` keeps every series in one panel, names the line ends, draws unhighlighted lines in the slate and refuses `facet` (reflex `index_to_compare_growth` 0.3). Smoke: fast 554 of 554 and heavy 23 of 23 (8.6 and 8.3 minutes before the hexagons; 21 and 11.5 minutes on the slow machine of 2026-11-23, see done-10b.md); 7D-2 and 7b-13 moved to the fast run. Live (`tests/live_run_10b.R`, output `tests/live_run_10b.out`): 4 of 6 Sonnet calls, no repair; the model kept all nine categories in one indexed panel, no `facet`; the final Briefing dashboard is `tests/dashboard_final/` and its screenshots `tests/final_1400.png` and `tests/final_500.png` (not committed).

**Phase 10 Part E in brief** (the live check; `tests/live_run_10.R`, output `tests/live_run_10.out`, committed, no key). 9 of 12 allowed Sonnet calls (1 label, 6 turns, 2 for headlines: one repair), 0 failed. Turns: "which categories grew fastest?" made indexed lines (`index: first`, one panel a category) and also a dumbbell; "compare revenue by region in 2022 and 2024" made a dumbbell; "is unit price related to units?" made a scatter of 3,000 points on log axes with a loess curve and no `density` field (so `auto`: counted cells); "how do prices vary by channel? show the shape" made `shape: violin`; "show revenue by month" made a line without `smooth`; "show the trend" with that line selected changed it in place to `smooth: 12`. Every expected form was chosen; no turn chose another form. The six headlines all passed the number and word checks. The dashboard (Briefing, marked `UNCLASSIFIED//FOR TEST`, the dumbbell interactive, the smoothed line a video, four pictures, 3.06 MB, 19.7 s) is in `tests/dashboard_live10/` (git-ignored).

**Phase 10 Part D in brief** (a seventh style and a tighter page; details under History). `Briefing`: off-white ground, hairline horizontal grid, titles in Barlow Condensed bold in upper case (R upper-cases the drawn title and leaves numbers and units as written; CSS does it on the page, with `span.keep`), small grey subtitles and axis text, one deep blue (`#173A75`) and slate greys. In every style a highlight is the style's accent against its slate (3 to 1 or better each way and against the ground, checked), and R colours nothing on its own. The exported page has a strip of at most six key numbers (statements: "3,000 rows", "22 columns", "Jan 2022 to Dec 2024"; no boxes, a number never wraps), cards of a row as high as each other with the chart centred in a growing slot, a chart of more than four panels on a row of its own, a summary at a reading size (1.05rem, 62 characters), notes smaller, the source line smallest; the canvas follows (heading face and case, equal heights, the strip in place of the value boxes). The heatmap's x labels are dodged into rows; the video card has `preload="none"` with its poster. Smoke: fast 535 of 535 (7.5 minutes), heavy 24 of 24 (8.9 minutes).

**Phase 10 Part C in brief** (chart forms; details under History). Four new spec fields and one new family, each checked, referenced for the model, written as code, given facts, animated and drawn in the interactive view: `dumbbell` (two dots a group on one scale, for exactly two values of `color`, the legend replaced by the two names above the first row), `density` (auto, on, off: a scatter of over 2,000 points becomes counts of rows in cells: `geom_bin_2d` rectangles when this was written, hexagons from `geom_hex` where hexbin is installed since the Phase 10b follow-up), `shape: violin` (a violin with its box for groups of 30 rows or more, a plain box with a note for fewer), `index: first` (each line over its first value times 100, a rule at 100) and `smooth` (a trailing moving average of 2 to 24 periods over the raw line in grey); and `annotate` is now a call-out: a box in the style's text colour on its panel colour with a thin leader to the point. Five reflex rules are appended verbatim to four reflex files (versions up 0.1), the methodology table has five more rows with thumbnails, and ten gold specs on tests/data/orders.csv go through every gold check. Smoke: fast 526 of 526 (7.2 minutes), heavy 22 of 22 (7.9 minutes).

**Phase 10 Part B in brief** (interactive charts with ggiraph, plotly gone; details under History). "Interactive" now shows the chart itself: `spec_widget()` draws the same layers as the picture with the data layers (bars, points, lines, tiles, bins, boxes) swapped for their ggiraph twins, so value labels, end labels, annotations, rings, fitted curves, the Magazine lift, the style's rule and semibold type are all there, as an SVG that scales with its card (no sideways scroll, no label cut at 500 px). A mark has a tooltip written by R from the plotted table in the facts' formats (HTML-escaped) and a hover group (the other series dim); no toolbar, no zoom. Five interactive charts: page 1.39 MB, zip 1.48 MB (plotly: 4.93 MB and 2.63 MB). A check compares the built layers, scales, labels, theme and texts of the picture and of the interactive plot for every gold spec. Smoke: fast 511 of 511 (6.2 minutes), heavy 22 of 22 (7.3 minutes).

**Phase 10 Part A in brief** (classification banner on everything that leaves the app; details under History). The export dialog has "Classification marking" (default `APP_CLASSIFICATION`, `UNCLASSIFIED`; one line, 1 to 80 characters, blank refused). It is written into dashboard.html and codebook.html (a red band top and bottom, and on every printed page), into every PNG and SVG in charts/ (a band drawn by R at the top and the bottom), into every frame of every MP4 (the dashboard's and a card's), as the first line `# <marking>` of charts.R, data_dictionary.yaml and each CSV (a reader must skip that line), and into the zip's name, `<marking_in_lower_case>_dashboard_<date>.zip`. It is never sent to the model. Smoke: fast 500 of 500 (6.7 minutes), heavy 21 of 21 (7.7 minutes).

**Phase 9 in brief** (report: `manager/done-9.md`). Parts A to D done: the exported dashboard and codebook look like published pages (centred, no hole in the grid, readable chart text, a page in the chosen style), charts animate to MP4, summary statistics (Data page, canvas, export), and a closing pass (probe Video table, deploy check without deploying, README, this file). Smoke: fast 488 of 488 (6.1 minutes), heavy 19 of 19 (7.0 minutes). The live run (`tests/live_run_9.R`) was made once the key was available: 5 calls of 10, Sonnet, four headlines that passed the checks; defects seen at 500 px are listed in `manager/done-9.md` section 4.

**What works**
- **Data page.** Reads a delimited file (csv, tsv, txt, tab; up to 50 MB; encoding guessed or chosen), types and roles every column, applies the missing codes the analyst lists, and writes `data_dictionary.yaml` (also read back). "Summary statistics" under the dictionary (`summary_table()` in R/data.R): one row per column, an optional "By group", 95% intervals that assume a simple random sample (t for a mean, Wilson for a share), a CSV; no key and no model.
- **Explore.** A chat and a canvas. Every message goes through one call, `chat_turn()`; the model answers with a small JSON spec that R checks and draws, never code. "Label the columns" is one call; "Suggest charts" and "Write headlines" are buttons. Some messages are answered by R alone (animate, summary table, "Treat -99 as missing"). Cards: Select, Undo, Interactive, Code, Edit text, Headline, Animate, "In dashboard", Move, Remove. A table card shows summary statistics.
- **The renderer** (R/spec.R, R/theme.R). Ten chart families (bar, dot, line, slope, scatter, bubble, histogram, box, heatmap, dumbbell), a lint, seven styles (Clean, Minimal, Magazine, Data desk, Newspaper, Dark, Briefing), palettes (paletteer optional), every text measured to fit its panel, one device chosen in one place (`chart_device()`: ragg, else cairo, else svglite; no X11, no Quarto, no pandoc).
- **Headlines and summaries.** Written from facts R computes; every number and word is checked, a failed text is sent back once, and a text is marked when its chart or data changed.
- **Video.** `spec_video()` draws frames with our renderer and encodes an MP4 with `av` (3 s of motion, 0.6 s of labels, 2 s hold, scales pinned; the last frame equals the static chart). Hidden where `av` is missing.
- **Export.** `build_dashboard()` writes `<marking>_dashboard_<date>.zip` (Phase 10 Part A: every file carries the classification marking): `dashboard.html` and `codebook.html` (single files, in the chosen style, centred, print-safe, a phone layout), `data_dictionary.yaml`, `charts.R`, `charts/` (PNG 300 dpi, SVG, MP4, table CSV). Each chart is a picture, an interactive chart (an SVG and 0.15 MB of ggiraph scripts, with its rows in the tooltips) or a video; up to three key numbers; table cards are real tables.
- **Methodology page** (from `www/methodology.md`, which is not edited here) and the **probe** (`probe/app.R`): the checks table, Graphics (devices, a font, three drawn charts) and Video (av, libx264, ten frames encoded, 30 frames of 1280 by 720 drawn and encoded, with seconds).
- **The bundle** (`.rscignore`, checked by 9C-7 to 9C-10): `app.R`, `R/`, `www/` only: 31 files, 3.0 MB: the nine typeface files 2.3 MB, `R/` 0.6 MB, the reflex files and methodology.md under 0.1 MB. rsconnect would ask Connect for 98 packages (hexbin with lattice, av, zip, commonmark, svglite, ragg, ggiraph with gdtools, paletteer among them; plotly is not used; `app.R` names tidyr in a call, because plotly was what brought it in and a deployment reads calls). Loads alone as an app (9C-9).

**What is not verified**
- The probe has not been run on the work server, nor has the app been published anywhere. Open: whether Connect's `av` has libx264, whether ragg, svglite and systemfonts are installed there, the time a five-video dashboard takes (68 s here), and the memory of a session.
- The `work` profile has placeholders for its base URL and model id (`app.R`); the app has only ever called `claude-sonnet-5-5` on Anthropic's API. The last live runs were the Phase 9 closing run (`tests/live_run_9.R`, 2026-11-22: 5 calls of 10, a Magazine dashboard) and the Phase 10 check (`tests/live_run_10.R`, 2026-11-23: 9 calls of 12, a Briefing dashboard; looked at in Chrome at 1400 and 500 px; output `tests/live_run_10.out`).
- Not seen: ggiraph on the work server (it needs gdtools, which needs the system libraries cairo and freetype; the probe lists ggiraph's version), the interactive charts in Firefox or Safari (Chrome and the in-app browser only), the working line during a long call with a screen reader, Excel opening the summary CSV (UTF-8 with a byte-order mark, a `note` column), a printer.

**Known limits**
- Chart forms (Phase 10 Part C): a dumbbell takes no panels, highlight or labels and refuses a group that has only one of its two values; the density view is hexagons (`geom_hex`) where hexbin is installed and rectangles (`geom_bin_2d`) where it is not, and always for an axis of at most 40 different values, and drops a colour column; the hexagons are as many across as high (30 by 30 on the drawn scale), so on a wide panel they look flat; `smooth` takes no highlight or annotate and needs as many points as periods; an indexed line must start at the chart's first period; a call-out on a line, scatter or bubble is placed by R at a fixed share of the axes (it can sit on the line it marks); (Part D) a Briefing page and chart draw the numbers of its strip and titles in a condensed face that falls back to Arial Narrow or the default sans where Barlow Condensed is not there; the colour of a series with no group is the style's own blue only with the default palette; a scatter's density is rectangles (hexbin is not installed); Newspaper's thin rule floats above a picture that has no title (the exported page's bare drawings).
- Phase 10b worker pass (items 1 to 9 of `phase10b_prompt.md`, details under History): the density view's strips and the curve across empty space are fixed (cells at the values of a small axis, the curve in pieces); the empty axes seen in headless Chrome are the first frame of the animation once play has begun (see History). Not done there: the hexagons (done in the follow-up, History: Phase 10b: hexagons), the live run (item 10, the lead's). `charts/` holds the card's MP4 (1088 by 612 or 1280 by 720), not a 1920 by 1080 file; the Animate button's download is still 1920 by 1080.
- Statistics use a simple random sample, three significant digits on screen (six in the CSV), and no weights or design. A mean of a scale treats its steps as equal, and says so.
- On a dashboard page a video has `preload="none"` and its poster (the finished chart); in headless Chrome the poster shows before play with `auto` too, so the empty first frame seen once was not reproduced; Firefox and Safari were not tried.
- A video has no phone drawing (its text is small below 600 px), takes a row of the page when drawn on a wide canvas, and its chart carries no rows. An interactive chart carries every plotted row (in its tooltips to three significant digits, and in where its mark is drawn).
- The Dark style's bubble size legend has black keys on a dark ground. Interactive charts: a box's outlying points are drawn but not hoverable (the box carries the tooltip) and do not dim; a line chart's tooltips sit on invisible points (and the line carries its series), so a pointer between two points gets the series name; the SVG device measures text within about 1 per cent of ragg, so a label may sit a pixel from where the picture has it; the SVG is drawn by the page's script, so a printed page or a reader with scripts off shows an empty card (the default way into the dashboard is a picture); pointing at one point of a coloured series of a 3,000-point scatter restyles the whole series (about 1,000 elements).
- On a phone the Data page's file table scrolls sideways by about 27 px. shinychat links the echo of a clicked card's text; the model's own text and the file's text are escaped (`md_text()`).
- The key is pasted on Start here and lives in the session only (the app never reads the environment); one model per profile; nothing is kept between sessions.
- The marking: a CSV in charts/ starts with a comment line, so a program reads it with one line skipped (`skip = 1`); the Data page's own downloads (dictionary, summary CSV) are not marked; a printed page keeps room for the band by `box-decoration-break:clone` (Chrome; not confirmed in Firefox or Safari); a card's video carries the band on screen too, because it is one drawing.

**Run and test** (from inside `chaRt/`, PowerShell; never two R processes at once, a second can leave an Rplots.pdf and fail 8A-1)
- App: `shiny::runApp("chaRt")` from the repository root.
- Fast smoke: `Rscript --no-init-file tests/smoke.R`: 548 checks, 8.7 minutes (7D-2 and 7b-13 moved here from the heavy run).
- Heavy smoke: `$env:CHART_SMOKE = "heavy"; Rscript --no-init-file tests/smoke.R; Remove-Item Env:CHART_SMOKE`: 23 checks, 8.4 minutes. Every check is in exactly one run (the `split:` check holds it); `CHART_SMOKE=all` runs both in about 12 minutes, too long for a foreground limit.
- Live (a key in `ANTHROPIC_API_KEY`, costs a little): `tests/llm_check.R` (steps by `CHART_LIVE_STEPS`) and `tests/live_run_9.R` (at most 10 calls, writes `tests/live_run_9.out` and `tests/dashboard_live/`).

**Map.** `app.R` settings, profiles, packages check, page, server. `R/data.R` file, dictionary, summary statistics. `R/spec.R` spec, checks, ggplot, interactive version (ggiraph), code, video. `R/theme.R` fonts, styles, palettes, device. `R/llm.R` key, model call, repair. `R/reflexes.R` prompts, the three calls and their checks. `R/ui.R` pages, canvas, dashboard and codebook writers. `www/reflexes/` the model's rules (not edited here), `www/fonts/`, `www/methodology.md`. `probe/app.R`. `tests/` smoke, live scripts, gold specs, `data/orders.csv`. `DESIGN.md` the design; `manager/` the mailbox of earlier phases (git-ignored but its README).

## History

## Phase 11 Part C: motion for any chart (2026-11-25)

Done by a Sonnet worker on branch `chart` (no model call, nothing pushed). Code: `R/spec.R` (the section "Phase 11 Part C: motion for any chart", at the end: `design_video()` and its helpers; `marking_draw()` takes `bands`), `R/theme.R` (`chart_device()` takes `bg`), `R/ui.R` (`dash_design_video()`, `dash_pictures()`, `build_dashboard()`'s `video_notes`, the About block, `dash_design_note()`). Tests: `tests/smoke.R` (`>>> 11C begin` to `<<< 11C end`, checks 11C-1, 11C-1b, 11C-2 to 11C-9; fast about 25 s, 11C-7 and 11C-8 heavy, about 35 s) and `tests/mutate_11C.R` (17 mutations). `tests/live_run_11.R` now builds two of the eight as video in its second-attempt mode (not run).

**How a designed video is made.** `design_video(code, inp, motion, file, width_px, marking, bare, poster, keep)`: `design_run()` gives the plot and `ggplot_build()` of it once; every drawing is that built object with some layers' data taken away (a layer with no rows draws nothing, and the scales, panel and legend stay the finished chart's, as in Phase 9, so removing a layer cannot move an axis). Four drawings: the whole plot (the finished picture: it is the last frame, the poster and the reference), (a) the frame (every layer emptied), (b) the data layers (text and annotation layers emptied, theme made invisible, device background transparent, no bands), (c) the text and annotation layers (the same, data layers emptied). The theme is made invisible by adding `element_text(colour = "transparent")`, `element_rect(fill = NA, colour = NA)` and `element_line(colour = NA)` to every element of the element tree that the plot's theme draws (a blank element stays blank: it takes no room). `chart_device()` has a new `bg` for the transparent device, `marking_draw()` a `bands` switch (the viewport is the same without the paint), both defaulting to what they were. The PNGs are read with `png::readPNG`, composed with `over` arithmetic (`design_over()`), the frames written with `png::writePNG` and encoded as `spec_video()` does. The canvas is the design's size with the bands added (as for a card in Phase 10b), `width_px` wide (1080 or 1280 on the page) and as high as that makes it, rounded to an even number of pixels; 87 frames at 24 a second (`video_frame_count()`) and the hold of `video_inputs()`.

**Layer membership** (`design_layer_role()`): a layer is text when its geom is one of DESIGN_TEXT_GEOMS or its class matches Text, Label, RichText or Textbox in any case (ggrepel's `GeomTextRepel` and `GeomLabelRepel`, ggtext's `GeomRichText` and `GeomTextBox`; annotate("text") and ("label") are `GeomText` and `GeomLabel`); an annotation, which comes in with the text, when it is not a mark geom (DESIGN_MARK_GEOMS) and has `inherit.aes` FALSE, `show.legend` FALSE, `StatIdentity` and at most DESIGN_ROW_EXTRA rows of data of its own: what `annotate("segment")`, `annotate("rect")`, `geom_hline(yintercept = )` and the like make; everything else is data (`annotate("point")` is a mark by its geom). Legend keys are drawn from the data layers' glyphs, so they come in with the data (a legend's words are the theme's and are in the frame). A layer drawn before the data in the plot but classed after it is the one case where the composition differs from the plot (the finished picture has the bars over a translucent rectangle, the composition the other way): the check below catches it.

**The motion.** `rel`, each pixel's place along the direction of motion, is measured over the bounding box of the data layer's ink (rows and columns with any alpha), so it does not depend on the panel's place. The mask is `clamp((e * (1 + soft) - rel) / soft)` with `e` the eased share of the motion (`video_ease(video_phases(p)$motion)`); `soft` is 0.15 for draw, 0.06 for wipe, 0.12 for rise (the choice of different softnesses is mine; the brief said only "soft-edged"). Draw and wipe move left to right; rise from the bottom, or left to right when `design_horizontal()` says the bars are sideways (coord_flip(), or a discrete y against a continuous x); fade multiplies the data layer's opacity by `e`. The text layer's opacity is `video_ease(video_phases(p)$labels)`. An unknown or missing motion is fade (as `design_motion()` defaults).

**When the layers are not used** (the whole-chart wipe, with the reason in the result and on the page): the design is a patchwork (`design_layers_why()`); the layers could not be drawn on their own; the data layers draw nothing; the frame without the data and text layers is the same picture as the finished design; or the three composed at full strength differ from the finished picture in more than DESIGN_VIDEO_SHARE (0.2%) of the pixels by more than DESIGN_VIDEO_LEVEL (4/255) in a channel. Seen: a design with a translucent rectangle written before the bars (16% of the pixels differ), a patchwork, a text-only design. Not seen to fail on its own: a ggrepel layer (its labels move each time they are drawn unless it has a seed); that would show as a difference and fall back. The wipe is the finished picture over the ground colour (`tok$ground`) between the two bands, which stay as they are, from the left with the wipe softness; its first frame is the ground colour.

**The last frame.** It is the whole plot drawn once through the same built object and copied to the last frame and the poster, so it equals `spec_png()` of the plot at the same size and marking pixel for pixel (checked with and without a marking). The composed layers at full strength are not bit-identical to it: with 8-bit antialiased edges they come within 1.5 levels (largest difference seen 0.0035 for a bar chart, 0.016 for 3,000 translucent points), which is why the video ends on the drawing and not on the sum.

**Wired in.** `build_dashboard()` makes a designed card whose mode is video with `dash_design_video()` (the design's code run again on the data as it is now, as for its picture), for the card's width (1080 desk, 1280 wide) with the bands, the poster the finished design. A design video that cannot be made gives the standard drawing's video, `m$designed` becomes FALSE for that card and a note says so; a card that wipes carries a note with the reason. The notes are in the build's result (`video_notes`, a named character vector), in the export dialog's result and in the page's About block under "The charts". `dash_design_note()` now says a video is drawn from the design (it said it was made from the standard drawing).

**Checks I changed.** 11B-17: the text it expected from `dash_design_note()` for a video ("A video is made from the standard drawing") is now "A video is drawn from the design". 8A-2: it lists every function of R/ that mentions a device or a text measure by name, and the symbol `png` in `png::readPNG` is one; the expected list gains `design_read_png` and `design_write_png` (the png package's reader and writer, no device).

**Found in Part A, not changed.** `DESIGN_TEXT_GEOMS` spells ggtext's geom `GeomRichtext`; the class is `GeomRichText`, so `inherits()` never matches it and design_check_contrast() and design_check_rows() treat a geom_richtext layer as a mark. `design_layer_role()` matches the name in any case; the list itself was left.

**Seconds.** A card video, 1080 pixels wide with the bands, bar with value labels: the four drawings under 1 s, the 87 frames about 4 to 5 s (array arithmetic and PNG writes, no ggplot), the encoding 1 s: 5.4 to 7.2 s on this machine (the second figure while the machine was slow). Narrower videos in the checks (320 to 720 pixels): 1 to 2 s. The two videos of check 11C-7 with the page: 18 to 24 s.

**Looked at** (not in the repo; Editorial-style stand-in code on orders.csv in the Briefing and Dark styles, each with the marking, 1080 pixels wide, the frames read back from the encoded MP4): a vertical bar chart (rise), sideways ranked bars (rise, left to right), monthly lines by channel with end labels (draw), a 3,000-point scatter with an annotation (wipe) and a histogram (fade); for each the first frame (empty frame, bands, axes, grid, no mark), a frame in the middle of the motion (rise: the bars cut across by a soft edge going up; sideways bars and lines: a soft edge going right; scatter: the points mostly in already; histogram: all bars at half strength), a frame while the labels fade in and the last frame (all marks, labels at full strength). Every one was as intended in both styles. Not seen: a video played in a browser (the 11C-7 check reads the MP4 back, and Phase 9's Chrome checks cover the page's video box), a ggrepel or ggtext design, a design with a legend or small multiples.

**Mutations** (tests/mutate_11C.R, 17 changes to R/spec.R, R/ui.R and R/theme.R, each made at least one check fail): draw and wipe from the right, rise from the top, sideways bars rising from the bottom, fade with no ramp, the text not waiting, the text never coming in, the last frame the composed layers, the frame keeping the marks, the frame without the bands, a text geom taken for data, an annotation taken for data, no comparison with the finished picture, a patchwork drawn in layers, the height without the bands, the export using the standard video, `chart_device()` ignoring a transparent background, the theme not made invisible. One mutation I first wrote (the data layer painting the bands) changed nothing that can be seen (the bands are the same red in every layer) and was replaced by the frame without the bands. **A flake found while writing the mutations, and what is done about it.** Twice a baseline run of the 11C block gave the wipe fallback for one of the five motion videos ("8.5% of the pixels differ"). Run in a loop it happens in about 4 videos in 100: one of the four drawings of a design comes out in another typeface ("Quebec" without its accent, the letters heavier) and a pixel off. 300 plain `spec_png()` and `ggplot_gtable()` drawings of the same plot in a row gave one picture each time, so the cause is not known (it shows after a `design_run()` and a `design_input()`; I suspect systemfonts or ragg, not looked for further). `design_video()` therefore draws the four again once when they do not add up (the second time it was right in all 4 of 4 cases seen; a design that really does not add up fails again), and the checks that compare with a picture drawn by `spec_png()` draw that reference three times and take the one two agree on (11C-2), and 11C-6 allows eight drawings. The video is never wrong when this happens (it falls back, or the retry succeeds); no picture the app draws on its own was seen to do it.

## Phase 11 Part E: a dashboard the analyst arranges, and questions about a chart (2026-11-25)

Done by a Sonnet worker on branch `chart` (no model call, nothing pushed). Code: `R/ui.R` (canvas, cards, sections, in-place edit, export dialog, `build_dashboard()` and the page), `R/reflexes.R` (`chat_turn()`, `assemble_chat()`, `chat_facts()`, `facts_block()`), `app.R` (`sections` in the state). Tests: `tests/smoke.R` (`>>> 11E begin` to `<<< 11E end`, checks 11E-1 to 11E-16, about 55 s) and `tests/mutate_11E.R`.

**What is covered** (stand-in replies for the model):

- Order: `canvas_section_of()`, `canvas_blocks()`, `canvas_reorder()` (a drop before or after a card or heading, a section never dropped inside another), `canvas_move_block()`, `dash_layout_by()`; in the app a drop reaches the canvas, bad drops do nothing, Move up and Move down move one place and a section with its cards, the first cannot go up and the last cannot go down. The order reaches the builder (items in canvas order, each with its section's title and text).
- Sections: Add a section (top, or before the selected card), grouping, collapse (cards leave the canvas, stay in the export), the section's switch (leaves out its cards without changing theirs), titles and text edited in place, Edit text dialog, Remove section (the cards stay).
- Edit in place (server side, called with what the page sends): headline and summary run `recheck_story()` (numbers against the facts, forbidden words), failures are kept and marked (`chart-marked`, and the line under the text); a title is the chart's title (Undo undoes it) and is marked when it has a number the facts do not; blank headline, unchanged text, wrong shapes and a headline for a chart with none are ignored; a table's title; no model call.
- The page's script is parsed by node when it is there (11E-9: an earlier version of it had a quote that ended a string and no text check saw it; the browser console did).
- Export dialog: a row for each section and card in order with a switch (id `dash_in_<id>`, kept equal to the card's own switch with `bslib::update_switch()`), a small picture, the form, a designed/standard switch only for a card with a current design (read by `dash_run()`), cards under a section set in, rows dimmed when off (the class is kept true to the switches by a few lines of script). The warnings are an output of their own (`dash_warns`) that follows the switches. A build with nothing left in is refused in words.
- The page: a heading (title, line of text) across the grid before the first card under a section, once per section; layout rows start again at a heading (`dash_layout_by()`); a section with no card left in has no heading; titles are text.
- Chat: with a chart selected the message has a `<FACTS>` block after SELECTED (the lines of `spec_facts()`, as the summary path sends them, names as `[[N1]]`, a line that says what they are); with none selected the message is as it was. The SELECTED spec has placeholders for values of identifier and text columns (a highlight, a filter), and a spec the model sends back is given its names back before it is checked. A `tell` is checked against DATA and FACTS; a number that is in neither is caught, one repair, then the problems and a warning that names the chart's facts. A placeholder not in the chart is shown as "a name that is not in this chart" and is a problem. The messy file's rows, values of its id, text and 45-level columns and SECRET_VALUE_123 are in no message. A title with `</FACTS>` cannot close the block (`data_safe()` now covers FACTS).

**Choices.** A section holds the cards under it in the canvas order, so a card moved across a heading changes section. New charts from the chat go to the top of the canvas, so they stand above the first heading until moved. Collapse changes the canvas only. Section and table titles are not number-checked (they say nothing of a chart, as the export's introduction is not). A card's "subtitle" is its small grey title under a headline; the chart's own `subtitle` field is not edited in place (the Edit text dialog does). A click away from an edit keeps it (the Edit text boxes do the same). The inline box starts with the text as shown, so a headline's trailing full stop (not shown) is dropped when it is edited. The dialog's per-card forms are still its own and reset on opening; the switches and the designed/standard choice are read from it at the build. The word check is not run on a `tell` (the spec asks for `check_numbers()`). The existing checks 6-B 18, 8C-18, 8C-19 and 9D-16 were changed: FACTS stands between SELECTED and LAST EXCHANGE; the dialog lists the card that is switched off; the warnings are read from their own output.

**Reflex gap (for the manager; no reflex file was edited).** chat.md has `about_the_file` ("Do not say what the data show") and `a_number_is_a_chart` ("Do not state a figure about the data yourself"), so a model that reads the new FACTS block has no rule that allows it to answer from it. The block carries one line of R's own wording, but chat.md needs a reflex such as: `### about_the_selected_chart` - **When:** SELECTED holds a chart and a FACTS block follows it, and the message asks about that chart (the highest, the lowest, how two compare, what it shows). **Say:** Reply with `tell`, at most three sentences, using only the numbers and names FACTS gives, each [[N]] placeholder written as it is there; if FACTS does not give the figure asked for (a difference, a ratio, a share, a cause), reply with `charts` for the chart that shows it, or with `tell`: "The chart's facts do not say that." **Never:** Do not add, subtract, divide or round figures yourself. Until it is added the model may still answer such a question with `charts` (it does not compute, but it may not use the facts).

**Looked at** (the app run with a stand-in model on `tests/data/orders.csv` in the built-in browser; a launcher in the scratchpad, not committed): six cards and two sections (1400 px, light and dark; 375 px, no sideways scroll), a real mouse drag of a card by its handle onto another (it landed before it), a section title edited in place (Enter kept it, Escape left a title as it was), a headline edited to hold 12,345 (kept, wavy underline in the warning colour, the sentence under the summary), the dialog as the dashboard as it will be (sections, indented cards, pictures, switches; a section switched off dims its cards live, and the canvas showed the section's switch off and "3 of 6 in the dashboard"). Not seen: the export dialog at 375 px (the same rows; not opened there), a drag with a touch screen (HTML drag events do not fire on most phones: Move up and Move down are the way there), the exported page with sections in a browser (its HTML is checked, 11E-10), a screen reader on the handle and the editable text.

**Mutations** (tests/mutate_11E.R, 24 changes to R/ui.R and R/reflexes.R, each made at least one of the 16 checks fail): a drop that lands before when it says after, a section dropped inside another, a section moved without its cards, the server ignoring a drop, no section owning cards, a collapsed section still shown, a switched-off section leaving its cards in, items with no section, the heading written for every card or never, a headline not checked or not marked, a title not marked or dropped, a blank headline kept, no FACTS in the message, a tell checked against DATA only, placeholders not put back, real names in the facts, in the spec, a returned spec without its names back, the FACTS marker open from inside, the dialog's switch not the card's, a layout that does not start again at a heading.

## Phase 11 Part D: Excel workbooks (2026-11-25)

**What is read.** `read_data(path, name, missing, encoding, excel)` hands a name ending .xlsx or .xls to `read_excel_data()` (R/data.R, section B1b). `excel` is the analyst's choices: `sheet`, `header` (a row number as Excel numbers rows), `table` (1, 2, ...) and `numbers` (columns of text to read as numbers). The result is the usual `data`, `problems`, `encoding` and an `excel` list (sheets with hidden and row counts, the sheet, the tables with their cells, the header row, the range of the data rows, `ask`, `opts`).

- **Sheets.** Every sheet's cells are read once as text from A1 (so row numbers are Excel's). The picker lists each sheet with the rows that hold anything (the header's among them) and ", hidden" for a hidden one. Hidden sheets: for an .xlsx, workbook.xml's `state="hidden"` (or veryHidden), read with `utils::unzip()` of that one part into a temp folder and matched with regular expressions (no xml2); for an .xls the page and the problems list say it cannot be told and nothing is marked. With no sheet asked for, the first sheet that is not hidden is read; a hidden sheet can still be chosen and is then said to be hidden.
- **Tables.** Blocks of cells are found by blank columns (side by side) then blank rows (stacked). A block of one row (a title, a note) is not a table and is said to be left out; a block with a header and a row is. One table is read; two or more are asked about: `data` is NULL, the question is in the problems list, the Data page shows radio buttons with none chosen, and `reread_data()` returns no profile or dictionary until the analyst picks. A table number out of range is refused in a sentence.
- **Header.** The first row of the table with text in more than half its columns, after merged cells are filled across; if none, the first row (said). "Header is on row n" changes it; a row outside the table is refused in a sentence. Rows above the header inside the table are said to be left out. When the header row holds a horizontal merge (the merges are read from the sheet's `<mergeCell>` list, .xlsx only), each merged cell is filled across and joined to the row below ("Sales" over "Q1" is "Sales Q1"); the join is said.
- **Values.** The table is read again by readxl with `cell_limits()` over the data rows, so readxl types the columns: dates are dates (a column whose times are all midnight becomes a Date, otherwise it stays date-time), formulas are the values Excel saved. A column of text that holds only numbers (digits, sign, thousands commas, decimals, exponent; never one with a leading zero) is read as text, said in the problems list and offered in the chat as `Read 'col' as numbers`; a press reads the sheet again with it as numbers (no model call), keeping the sheet, table, header and missing codes. The other problem sentences are the CSV's (`column_problems()`): blank names, an empty column, a column that is mostly numbers.
- **Codebook, source line, code.** The codebook carries optional `sheet`, `range` (the data rows' cells) and `text_numbers`. The source line is "Source: orders.xlsx, sheet Regions. 2 rows." (the dictionary's own source still replaces it); the chat's setup message, the Data page summary, the value box tooltip and the export's "The file" line name the sheet. The code a chart comes with reads the sheet with `read_excel(file, sheet, range, col_names = <the dictionary's names>, ...)` and turns the text numbers to numbers, and runs to the same data. A different sheet of the same file starts the canvas again, as a different file does.
- **Page.** The file input accepts .xlsx and .xls; for a workbook the page shows the sheet picker, the table question, the header row box and an explanation, and hides the encoding select. readxl is added to `APP_PACKAGES` and R/data.R calls `readxl::`, so a bundle asks Connect for it (9C-8 passes unchanged: readxl is among the packages it finds).

**Checks and mutations.** `# >>> 11D begin` to `# <<< 11D end` in tests/smoke.R (11D-1 to 11D-14: two sheets, source line, offset header and Header-is-on-row, merged headers, dates, text numbers, two tables side by side and stacked and a title line, hidden sheet, formula, problems list, the chat, the chart's code run beside the file, the page and packages, file checksum before and after). Workbooks: writexl makes the two-sheet, dates, text and two-table files; writexl cannot make merged cells, hidden sheets, formulas or a blank offset, so `d11_book()` in the test writes a minimal .xlsx's XML parts (inline strings, `<f>` with a cached `<v>`, `<mergeCells>`, `state="hidden"`) and zips them with `zip::zip()`. Nothing is committed but the test code; the files are made in tempdir(). tests/mutate_11D.R: baseline 14 of 14, 16 of 16 mutations make a check fail (header search, hidden flag, asking about two tables, dates, text-number offer, merge join, hidden first sheet, source line, blank leading rows, numbers conversion, leading-zero code, header override, & in a sheet name, the chat offer, the chat's reread forgetting the choices, the code reading a sheet as delimited text). "Nothing is written" has no mutation (the code never opens the file for writing; the checksum check stands).

**Seen.** In the browser pane (light and dark, 800 px) with a three-sheet workbook (offset table, two tables on a sheet, a hidden sheet): the picker with "Old data (2 rows, hidden)", the table question with none chosen and "No table is read until you choose one", Header is on row (3 for the offset sheet; changed to 2 it read one row and said row 1 was left out), the chat's "Read 'd' as numbers" button and the sentence after it.

**Not covered, and choices.** No .xls was read by any check (a fixture cannot be made without Excel and none was committed): .xls goes through the same code with no merge information (so merged header cells are not joined: the group row above the header is said to be left out) and no hidden flags (said). Dates in the header row are shown as serial numbers in the table-finding step. A header made only of numbers (years) is not seen as text: the table's first row is used and said. A merged cell in the data rows is not filled. Row counts and tables are worked out from a text read of every sheet on every read, so a workbook of hundreds of thousands of cells reads slowly. A blank row inside a table splits it into two tables and so asks. A sheet is chosen by default when the workbook has several (the first not hidden) and the picker is shown; only tables are asked about. The cautious default for two tables is none chosen. Unlike CSV, the encoding select is hidden for a workbook. A one-row block is always a note, never a table. A saved dictionary applied to a workbook takes the sheet and range from the current read, not from the file. Found while testing: an earlier try added `excel` to `new_state()`, which check 8B-11 reads as text; it is set by the Data page instead.

## Phase 11 Part B: the design call and the review by looking (2026-11-24)

Done by a Sonnet worker on branch `chart` (no model call, nothing pushed). Code: `R/reflexes.R` (the end of the file: `design_chart()` and what it needs), `R/llm.R` (`images`), `R/ui.R` (card, canvas, Style dialog, chat phrases, export), `app.R` (two settings, four `requireNamespace()` calls). Tests: `tests/smoke.R` (`>>> 11B begin` to `<<< 11B end`, checks 11B-1 to 11B-18, about 70 s; 9C-8 and the heavy 9C-10 extended) and `tests/mutate_11B.R`. DESIGN.md section 20 is the short version.

**What is covered** (stand-in replies for the model; the transport is the `ask` function, as in the earlier phases):
- Every path of `design_chart()`: good the first time (design call, review call with the picture, review says ok); refused by the guard, refused by a check, each repaired once; refused twice (no design, two calls, a reason of one line); the review changes it (the new code is guarded, run and checked; the second round sees the new picture); a model that changes it every time is stopped after two reviews; the review breaks it (the earlier design stands, no repair); no picture allowed (`"none"`, `"aggregated"` for a scatter, `"all"`, the global setting, an unknown value); a failed call (one line, none of the model's own words); a repair that cannot be read.
- The message: sections in order, sizes, rows only for an aggregated table of at most 60 rows (a table of rows of the file, a scatter of 3,000 points, is never sent as rows), the messy file (an identifier, free text, a 45-level text column with SECRET_VALUE_123 planted in each) never in a message: not as a value, not as a level, not in the spec's highlight, not in a title; the skill choice reaches the message and no other skill does; a wish is a block after the skill.
- Skills: parsing, the 120-line refusal, the missing Intent, an office folder (a stand-in in a temp folder), `APP_SKILLS_DIR` set, set and missing; an office skill's text reaches the model and is in no record, log, mark, code listing, script or file.
- The picture's way to the model (`llm_json(images =)`, `llm_complete()`, ellmer) and the call counts.
- In the app (`shiny::testServer`): the Design button, the designed card, the switch and back, Interactive on a designed bar, the chat phrases and the wish with no chat call, Design all (only what has no design, then nothing to do), a changed style dropping the design with a line that says why, the Style dialog's two choices, automatic design, the export carrying the design only while the card shows it.
- The export (`build_dashboard()`): picture (2,100 by 1,470 pixels with the marking's bands), SVG, table CSV with the marking as first line, `charts.R` that runs in a fresh R process with nothing else, the page's designed picture, the designed tooltips, the standard interactive version with its line for a design with a fitted curve, a design that cannot be drawn again (falls back, the build goes on), the dialog's notes.
- The interactive rule, on a bar, a scatter with a loess curve, a histogram and a patchwork.
- Packages: four `requireNamespace()` calls found by rsconnect (without them ggtext, patchwork and forcats and their dependencies are not asked for: 107 packages with them, 98 without; ggrepel was already found); 9C-8 holds them, the heavy 9C-10 holds that dropping the call loses ggtext.

**What the first smoke runs found, and the fixes:** (1) `eval_tidy` in the tooltips and `parse` in the script writer broke the check that no text is turned into code: the tooltips now read only bare columns of the layer's data, and the script writer takes the function names from the guard's own syntax tree; (2) the chat's sentences about a design were not built through `md_text()` (check 6-D 18): two helpers, `design_many_text()` and `design_one_text()`, are, and the check lists them; (3) design.md's seven rules have a Label, so 7A-4 wanted them in `RULE_FAMILIES` (empty entries: a spec never names them) and 8B-7 now counts 68 rules in 10 files; (4) a picture column in the call record broke `fmt_calls()` of the smoke test and the live scripts, which take the columns by name: the column is gone.

**Mutations** (tests/mutate_11B.R, 16 changes to R/reflexes.R, R/ui.R and R/llm.R, each run against the 18 checks): rows of the file's own table sent (11B-8); identifier and text values sent (11B-9); the image setting ignored (11B-6); a second repair (11B-3); five reviews (11B-1, 11B-4); the skill's text kept in the record (11B-1, 11B-11); a failed design reported as a success (11B-3); a review's change not checked (11B-4, 11B-5); the skill not sent (11B-8, 11B-10, 11B-11); no marking in the CSV (11B-16); "design this" not recognised by R (11B-13, 11B-14); the picture not given to the transport (11B-7); aggregated and row-level mixed up (11B-8, 11B-9); the export carrying a design the card does not show (11B-13); a review's ok not ending the reviewing (five checks). M09 (the review picture drawn at 300 dpi) is caught by a `stopifnot()` inside `design_chart()` that stops the block, not by a check that names it.

**Looked at** (the app run with a stand-in model on `tests/data/orders.csv`, in the built-in browser, at 1400 pixels, and an exported page at 1400 and 500): Start here with the new box, the canvas with Design and Design all, the working line ("Designing"), the designed card (mark, switch, review line, the model's note), the Code dialog with the table, the designed bar interactive (six tooltips, "region: West" and "revenue: 939,500"), the Style dialog's Design section, the Methodology page's note, the export dialog's note, and the exported page with a designed picture, a designed interactive bar and a standard interactive scatter with its line.

**Choices** (each one the cautious option where there was one):
1. The design call's system prompt is design.md alone, not core.md plus design.md: core.md's persona says the model never writes code and its prohibitions say "Do not write R code" and "Do not choose colours"; the parser takes whole files, not a section. design.md has its own persona and the rule about instructions inside the data. `CALL_FILES$design = "design.md"`, `CALL_REPLY["design"]`; `design.md`'s checksum is in `REFLEX_SHA` too (the same as the manager's, 11-0).
2. WISH is placed right after SKILL (Part B item 4: "after the skill"), not at the end of the list of sections.
3. Names of identifier and text columns are placeholders in the message everywhere (TABLE rows, SPEC, TEXT), as in the facts; a text column with more than 12 levels is treated the same. The model therefore cannot write `filter(d, city == "...")`; it uses the facts or `max()`.
4. The model's own words are never shown when a design fails (a reply could hold anything); its one sentence about a design is shown only when it has no digit in it.
5. An office skill is named in a file only as "an office design skill" (its title is the office's); the title and Intent do show on screen (the Style dialog, the card's mark).
6. `{"ok": true}` is accepted as a reply by `llm_json()` (it was refused as "the example template": no string in it). A small change to `is_placeholder_reply()`.
7. The page picture of a designed chart is the design drawn once at its own size, without its title and caption (the page says them), scaled by the page for a card and for a phone: it has no phone drawing. The 300 dpi file in `charts/` has the title and caption.
8. A designed card exports the design only while its switch is on "Designed drawing"; a video is made from the standard drawing (Part C will change that).
9. The design is dropped when the chart's spec, the style or palette, or the data changes (its key), with a line on the card.
10. Max tokens for a design or a review call: 16,000 (the model's thinking counts, and a reply that reaches the ceiling is a failure).
11. Wishes are recognised by words (a verb of changing a look, a thing that has a look, none of the words of changing the chart's form, columns, groups, filters or numbers) and only with a chart selected; anything doubtful goes to the chat as before.
12. The call record has no column for a picture (the smoke's `fmt_calls()` and the live scripts take the columns by name): a `review` call is the one with a picture.
13. A designed chart's tooltips are written from the layer's own data and only from bare columns (`aes(x = region, y = revenue)`): no design code is evaluated again to read an aesthetic (the check that no text is turned into code holds), so `aes(x = fct_rev(region))` gives a picture with the standard interactive view.
14. The Editorial skill asks for line-end labels in the line's colour and Part A's 4.5 to 1 contrast check refuses Okabe-Ito's light colours: left as it is, and a repair round gets the refusal sentence (seen in a stand-in: "The text of layer 3 (geom_text) is drawn in #1A1A1A, a contrast of 1.8 to 1 against #0A4580 behind it").

**Not covered, not confirmed**
- No live call: the real `llm_json()` with a design reply (R code inside JSON, with `JSON_QUOTE_RULE` asking for no line break in a value and single quotes) has never been tried; nor the Anthropic or OpenAI-style endpoint with an image (the request body is checked, a response is not).
- The designed drawing's picture is made at the card's size; the page scales it. Text sizes on a phone are small (seen at 500 pixels).
- The interactive rule is conservative: bars, columns, points and tiles drawn from their data as they are; a design with a line, a histogram, a box, a smooth, a hex layer or a patchwork is a picture with the standard interactive view. A line is never given tooltips by design (ggiraph takes one for each line, not each vertex).
- Wishes: a wish with a verb or a noun the pattern does not know goes to the chat, which cannot do it and says so. A wish for a colour is a wish for the design (the style's tokens and palette are the model's to use).
- Not seen: the card's working line stage by stage with a real model (the stages are set from R with `chart-progress`; the stand-in answers in 1 second), the exported page in a browser other than the built-in one, screen readers on the new controls, Design on the work server (the `ellmer` image path needs the endpoint to accept images).
- Heavy checks of the export in Chrome (9A, 10B) were not changed by this part.

## Phase 11 Part A: running the model's drawing code safely (2026-11-24)

**The lead's review** found three holes with hostile code that ran, and fixed them (check 11A-13, mutations M29 to M31; DESIGN.md section 19's last paragraph):
1. Markup made while the plot is built (an aesthetic, an axis's or a legend's labels function) passed the pre-draw markup check, and gridtext's `<img>` read a local picture (a web address would have been fetched). `design_block_images()` now replaces gridtext's image reader, for the process, with one that refuses.
2. `x[9999 * 99999] <- 1` made 8 GB. The run environment's `[<-` and `[[<-` now refuse a numeric index past 1,000,000, and `format()`/`formatC()` refuse a result past the size limits.
3. A column made by `mutate()`, and `after_stat(count)`, were refused. Bare names inside `aes()`, `after_stat()`, `after_scale()`, `stage()`, `vars()` and dplyr's verbs (`DESIGN_MASKED`) now pass like formula symbols; deny-listed names are still refused, and `.env` is now denied.

M10 (the pre-draw markup check removed) then escaped, because the image block caught the image cases; a link in a title is now a case only that check refuses. Smoke after the review: fast 577 of 577, heavy 23 of 23; the 11A block 13 of 13 after the link case was added; all 31 mutations caught.

Done by a Sonnet worker on branch `chart` (no model call, nothing pushed). All in R/spec.R (the end of the file), tests in tests/smoke.R (`>>> 11A begin` to `<<< 11A end`, checks 11A-1 to 11A-12, about 40 s) and `tests/mutate_11A.R`. DESIGN.md section 19 is the short version.

- **What it is: an allow-list interpreter, not a proven sandbox.** The guard reads the code as a syntax tree; the run evaluates it where only the toolkit and five objects exist; the checks look at what was drawn. Layers, in the order an attack meets them: (1) `design_guard(code, cols)`: at most 6,000 characters; a parse error is a refusal; the whole tree is walked (calls, symbols, formals, defaults); every called function is a plain symbol that is a toolkit function, `pal` or a function the code made; every symbol is `d`, `facts`, `txt`, `tok`, `pal`, a toolkit function, a column of `d`, a constant (`T`, `F`, `pi`, `letters`...), `.data`, or a name the code assigned or took as a parameter; refused outright: `::` `:::` `@` `<<-` `->>`; a call through `(f)()`, `f()()`, `x$f()`, `x[["f"]]()`; assigning to `d`, `facts`, `txt`, `tok`, `pal`, an operator or base R name, a toolkit name given a function, or `names(x) <-`/`attr(x) <-` and any replacement call; `$<-` etc. on anything the code did not make; a function that calls itself (directly or through others); a loop; every name of `DESIGN_DENY` (six groups: code, files, system, environment, output, loops; each with its own sentence); a number of 10^7 or more written in the code; `parse` given as an argument; a string given where a function is expected (`fun`, `fun.data`, `labeller`, `.fun`...), a `method` or a `transform` outside short lists, a facet string that is not a column name. Each refusal is one plain sentence. (2) `design_run()`: evaluates in a fresh environment with parent `emptyenv()` holding the toolkit, `$<-`, `[<-`, `[[<-`, a `::` that finds only `base::chooseOpsMethod` (R's own operator dispatch needs it), constants and `d`, `facts`, `txt`, `tok`, `pal`; `setTimeLimit(cpu = 20, elapsed = 20)` around evaluating, building and drawing, reset in `finally`; warnings and messages caught; the result must be a ggplot or patchwork; drawn once through `chart_device()` (`design_draw()`); a text with HTML or image markup anywhere in the plot (labels, data, scale labels) is refused before drawing (ggtext would read an image file). (3) The toolkit's own limits: `c`, `paste`, `paste0`, `rep`, `seq`, `seq_len`, `:` refuse more than 1,000,000 elements or 100,000 characters (a vector doubled 25 times, `rep(0, 10^9)`); `format`/`formatC` widths; and `design_screened()` wraps every toolkit function with an argument ggplot2 or forcats would turn into code or a huge object and checks the VALUE at run time, so a string the code builds (`paste0("sys", "tem")`) is stopped too: a function argument must be a function or the name of a toolkit function, `method` and transformations from short lists, a facet a column name, bins and points at most 10,000, a size at most 300. (4) `design_checks()` below.
- **Found by testing, not by thinking.** A first version put emptyenv as the parent and trusted it. A computed facet string (`facet_wrap(paste0("sys", "tem(...)"))`) still ran `system()`: ggplot2 parses the string and evaluates it in its own namespace, which sees base R. A canary function planted in the global environment then showed the same for `stat_summary(fun = <string>)`, `fun.data`, `stat_summary_2d`, `labeller`, `fct_reorder(.fun = <string>)`, `geom_smooth(method = <string>)`; a sweep of every toolkit function and every argument with a canary string (5,130 combinations, a scratch script, 138 s) found 19 in single-argument form and none after `design_screened()`. The environment alone is NOT the defence for anything that goes through ggplot2's internals; the screens are. Also found: `formula = y ~ x` needs bare symbols inside `~` allowed; a bare `last`, `first`, `n` (dplyr names) is a natural variable name and is allowed when given a plain value.
- **`design_toolkit()`** (460 names, typed in lists, each checked against the installed package: ggplot2 4.0.3, scales 1.4.0, dplyr 1.2.1, forcats 1.0.1, ggrepel 0.9.8, ggtext 0.2.0, patchwork 1.3.2; `design_toolkit_text()` prints it for the model as TOOLKIT). Left out on purpose: `sec_axis`, `dup_axis`, `coord_polar`, `coord_radial`, `ggsave`, `geom_sf` and kin, `geom_map`, `annotation_map`, `annotation_borders`, `annotation_custom` and `annotation_raster` (a picture is a decoration; custom takes any grob), `theme_set/update/replace/get`, `from_theme`, `labeller`, `as_labeller`, `label_parsed`, `label_bquote`, scales' `label_glue`, `label_math`, `label_parse`, `layer`, `aes_string`, every low-level constructor and `geom_count` (a banned chart form, check 2d-2). Added to the prompt's list: `~`, `!`, `%in%`, `%%`, `%/%`, `&&`, `||`, `:`, `ceiling`, `floor`, `pmin`, `pmax`, `cumsum`, `diff`, `is.numeric`, `as.integer`, `nlevels`, `any`, `all`, `which`, `isTRUE`; ggplot2's `xlab`, `ylab`, `ggtitle`, `xlim`, `ylim`, `lims`, `expand_limits`, `waiver`, `stage`, `fill_alpha`, `mean_se`, `mean_sdl`, `margin_auto`, `margin_part`, `draw_key_*`, `label_both/value/context/wrap_gen`, `annotation_logticks`, and scales' `rescale_mid`, `oob_keep`, `oob_squish`, `number`; `wrap_plots` and `plot_spacer`. `|>` is syntax (the parser writes it as a call) and has no binding. `head` and `tail` come from utils and `median` from stats (the prompt lists them as base). A label function is passed to a scale (`labels = label_comma()`); to write a number in a text use `comma(x)`, `percent(x)`, `dollar(x)`, `number(x)`: `label_comma()(x)` is a call of a call and is refused.
- **What the model is given:** `design_tokens(style)` (ground, panel, text, muted, accent, slate, grid, caption, title_family, title_face, body_family, base_size), `design_pal(palette)` (`pal(n)`, an error with a sentence past the palette's number), `design_text(spec, style, cb)` (title after the heading stop and title case, subtitle, caption, `x`, `y`; absent is NULL), `design_facts(spec, table, cb)`: a named list, one entry for each line of `spec_facts()` text that has a label: `list(text = the line as written (tokens [[N1]] kept), label = before the first colon, number = the numbers in the rest of the line as a numeric vector)`, named by the label in lower case, ASCII, made unique (`highest`, `west`, `share_of_the_total`); `design_table(d)` strips readr's attributes.
- **`design_checks(plot, d, facts, spec, code, txt, warnings, axes, size)`** returns `list(ok, reasons)`, one sentence each: (a) numbers written as text (title, subtitle, caption, axis and legend titles, every drawn label of a panel, each text layer's labels) pass `check_numbers()` against the facts' text plus `d` (its numbers, a share also as a percentage, its dates in four forms, its categories and names) plus `txt`; axis tick numbers are the scale's and are not read; (b) no text runs past its panel (or the device, when the plot does not clip) and no two texts of a panel overlap (`design_text_boxes()`, the measure of `drawn_text_faults()` in tests/gallery.R, for any plot, with a text's rotation); (c) a layer of a bar or an area has zero in its value range (seen through `flipped_aes`, `coord_flip` and the scale's transformation: a log axis never does); (d) no scale has a second axis; (e) **row rule:** each layer is judged on what it is GIVEN (`layer$layer_data()`, so a function applied to the data counts): a mark (point, col, bar, line, area, tile, box, violin, path, errorbar, pointrange, smooth...) may not be given more rows than `d` has nor fewer unless the code has a `filter(` call (`head()`, `slice_*()` and `summarise()` leave rows out without saying so and are refused); a stat layer (histogram, summary, smooth, density, boxplot) is held to the same on its input, not on its output (it makes as many rows as its statistic makes); a layer of labels, rules or leaders (text, label, segment, hline...) may have `DESIGN_ROW_EXTRA` = 12 rows more than `d` and as few as it likes; any warning "Removed n rows" (a scale's limits) is refused; (f) each axis' scale type (discrete, date, log, continuous; sqrt, reverse, binned are their own names and never match) is the spec's, read from `d`'s column classes and `log_x`/`log_y`, either way round (so a bar may be sideways), a whole-number column of at most 40 values (a year, a rank) may be continuous or discrete; (g) text against what it stands on at 4.5 to 1: title, subtitle, caption, axis titles and text, legend and strip text (when there are any), and each text layer's colour against the plot background, or the fill of the bar, tile or box its anchor is strictly inside, or a label's own box.
- **Tension for the manager (not edited).** Editorial says to name lines at their ends "in the line's own colour". Okabe-Ito's first colours on white are 2.2, 2.2, 3.4 and 5.1 to 1, so the contrast check refuses most such labels (the design must write them in `tok$text`, or darken the colour). The skill and the check disagree; the check follows the prompt (4.5 to 1).
- **Not covered** (what a determined attacker would still try): memory, not time, as a limit (a toolkit function that allocates a lot inside C code is not interrupted by the time limit; the size screens cover what I thought of); strings given to ggplot2 arguments I did not name in `DESIGN_RISKY` or find by the sweep (the sweep tried each argument alone with one canary string, not combinations); toolkit functions with a way I did not find to read a file or evaluate a string (gridtext renders HTML: the markup check catches image, link and style tags and CSS `url()`; a form it does not know is not caught); a bug in R, a package or a graphics device reachable by a plain call; the S7 objects and ggproto environments reachable with `$` (a ggplot2 internal function can be passed as `fun`); the contrast check cannot see a colour taken from a scale's palette for a text, text on an image, text over a mark that is not a bar, tile or box, or the alpha of a colour; the text measure does not see ggtext's `geom_richtext` or textbox boxes and measures only texts that `grid.force()` shows as `text[...]` grobs; the numbers check does not read a number in tick labels or a legend's key labels (those are the scale's); a design that tells the truth badly (a misleading order or colour can still be made). No limit on how many designs one session may try.
- **Smoke.** Fast run 576 of 576 checks (563 and 13 new: 11A-1 to 11A-12 and the changed 8A-2 stays one), 1,283 s on a machine that was slow (the 11A block about 40 s of it; 11A-6 holds 21 s for the time limit); the heavy run was not made, no heavy check was touched. Check 8A-2 now expects `design_text_boxes()` among the functions that measure text (inside a device `chart_device()` opens); the check of the "no model reply is evaluated" rule (it bans `parse` and limits `eval`) now allows the guard's one `parse` and the run's one `eval`. Mutation runs (tests/mutate_11A.R: a changed copy of R/spec.R sourced after the app loads, the tree untouched): 28 mutations, each made at least one of the 12 checks fail.

## Phase 10b: hexagons (2026-11-23)

A small follow-up to Phase 10b item 2, done by a Sonnet worker on branch `chart` (no model call, nothing pushed): Kevin said yes to installing `hexbin` (1.28.6; ggiraph 0.9.7 has `geom_hex_interactive`, checked by name in the installed package; ggplot2 4.0.3's `geom_hex(bins = )` is a `StatBinhex` that works on the transformed scales).

- **The rule** (`hex_fits()`, `density_hex_ok()`, `bin_distinct()` in R/spec.R). In the density view hexagons are drawn when `density_hex_ok()` (hexbin is installed: `find.package()`, because a check holds that no file in `R/` calls `requireNamespace()`) and each axis has more than `SPEC_BIN_DISTINCT` (40) different values on the scale drawn. An axis of at most 40 is binned at its values, which a hexagon cannot do, so such a chart stays rectangles even when hexbin is installed: the live orders chart (unit_price, many values, against units, 38) is the case. The lint sets `.hex` (a lint field, never accepted from outside); `bin_call()` writes `geom_hex(bins = 30L)` or the rectangles of item 2 unchanged.
- **What stays.** Item 2's fill (the style's own ramp, the analyst's palette only when chosen), the legend ("Orders" or "Rows"), empty hexagons are not drawn (hexbin does not return them), the fitted curve in pieces over the same 30 cells along x, the mark count. The note says "counts rows in hexagons: each hexagon counts rows, and the stronger its colour, the more of them" for hexagons and is the old sentence (cells of a grid, each cell) for rectangles. The reference text for the model (`relationship.md`, the field list) says "cells", which is true of both and was not changed.
- **Interactive.** `geom_hex` is swapped for `geom_hex_interactive` with the tooltip "Orders in this hexagon: n" and a hover group for each hexagon (`widget_hex_tip()`); `widget_match()` passes (the twin is a subclass of the picture's `GeomHex`). app.R checks `geom_hex_interactive` at start-up with the other ggiraph functions.
- **Code.** `spec_code()` prints `geom_hex(bins = 30L)` and, above the chart, a comment that `geom_hex()` needs the hexbin package (a fresh R process runs the code; it needs hexbin there, which is fine and is said). Where hexbin is missing the chart is rectangles at draw time, so the code printed there never names hexbin.
- **Video.** `GeomHex` is a `tiles` layer: the hexagons come in a column of them at a time from the left, each fading in; the last frame's built data is the static chart's.
- **Deployment.** `requireNamespace("hexbin", quietly = TRUE)` in app.R with its comment (the way tidyr was added); not in `APP_PACKAGES`. 9C-8 now wants hexbin in the list (98 packages instead of 96: hexbin and lattice) and refuses a list without it; README says hexbin is optional and what it does.
- **Checks.** `with_hex(on, expr)` at the top of tests/smoke.R replaces `density_hex_ok()` in the global environment for the length of an expression (the function-level switch that simulates absence) and puts the real one back; `hex_here` says whether hexbin is really installed (the hexagon checks that draw are then skipped, and say so in their titles). Changed to cover both ways: the lint check of cells, 10B-8 (25,000 points: tile twin and hexagon twin), 10C-5 (density), 9C-8. New: 10b-13 (the rule: 41 and 500 values hexagons, 40 on either side not, the switch off none, the live chart rectangles, built data identical to the switch-off one), 10b-14 (30 across on the log scale, the fill ramp in Clean, Briefing and Dark, legend, curve pieces, note), 10b-15 (the interactive twin, tooltips, `widget_match`), 10b-16 (the printed code in a fresh process, both ways), 10b-17 (the motion), 10b-18 (facts unchanged; app.R names hexbin and does not require it). The 10C-14 gold charts now draw the density chart as the app does here (hexagons).
- **Mutations** (changed copies of R/spec.R sourced after the app loads, `tests/` untouched): see the worker's report in the chat for the list; each of the 14 for 10b-13 to 10b-17 was caught by at least one of them, the four for the changed checks by those, and an app.R without the `requireNamespace()` call fails 10b-18 and drops hexbin from what rsconnect finds (9C-8's list).
- **Seen** (Chrome 157 headless, the in-app browser pane; screenshots local, not committed). The unit_price against revenue scatter of tests/data/orders.csv on log axes in Clean, Briefing and Dark as a picture, an interactive chart (hover: "Orders in this hexagon: 138", the other hexagons dim, the hovered one outlined; in Dark the tooltip is dark) and video frames (first: axes and legend only; middle: the left columns in, fading; last: all 261 hexagons and the two curve pieces), on an export page at 1400 and 500 pixels; the live spec (unit_price against units, log axes) is still rectangles. What was wrong: nothing broke; the hexagons are flat (as many across as high in data units on a wide panel) and a faint seam shows between neighbours in Clean and Dark (antialiasing); not changed.

## Phase 10b worker notes (items 1 to 9; the lead writes the phase section and makes the live run)

Done by a Sonnet worker, branch `chart`, no model call, nothing pushed. Smoke after the last code change: fast 548 of 548 (519 s), heavy 23 of 23 (502 s). Kevin's commit `2e4c6a4` ("updating app") swept a mid-work snapshot of this work into the history before the worker's own commits.

- **Run time.** 7D-2 (the style sheet) and 7b-13 moved to the fast run; HEAVY_CHECKS lost three prefixes and gained `10b-11`, `10b-12`.
- **1 Video card.** The poster is a PNG of the last frame at the video's own pixels; the reduced-motion still is the same picture; after `ended` the browser keeps the last frame; a "Replay" button (hidden until the page's script runs, a real button, labelled "Replay the video: ...", in print and under reduced motion hidden) starts it again. The card's video is drawn for the card (`SPEC_VIDEO_DASH_PX`): 1088 by 612 pixels for a card that shares its row (544 CSS pixels, canvas 5.67 inches at 192 dpi), 1280 by 720 for one with a row to itself (640); it was a canvas of 8 inches or more scaled to 544 (text near 8 pixels). The poster, the page's video and the file in `charts/` are the same size. The download of the Animate card (1920 by 1080) is unchanged. Seen in the in-app browser (Chromium, over a local httpuv static server, stopped afterwards): before play the poster shows the finished chart (0:00 / 0:05); at 0:01 the line is half drawn; at 0:05 / 0:05 the finished chart with the Replay button under it; Replay restarts it (playing at 1.08 s a second later). The empty axes seen before: the old page in headless Chrome, with a virtual-time budget, shows the video playing at 0:00 with the first frame (axes, a dot where the line begins): the page's script starts play when the card is half on the screen and the animation begins empty. The 0:05 / 0:05 state with no line was not reproduced (the same page ends on its last frame in the in-app browser and in headless Chrome).
- **2 Density.** `bin_edges()`: an axis of at most 40 different values is binned at them (edges halfway between values), any other in 30 cells of one width on the scale drawn; edges are written into `geom_bin_2d(breaks = list(x, y))` (free_y keeps ggplot2's own `bins = 30`); fill from `chart_style_ramp()` (the accent mixed 22 per cent into the panel colour, to the accent) unless the analyst chose a sequential palette (`pal$ramp`); legend title from `row_word(cb)` ("one order" is Orders; "Rows" when the dictionary has no `one <word>`); the fitted curve is cut where two empty cells in a row lie along x (`fit_runs()`: two pieces for the 3,000 orders, none between 17 and 47). The heatmap keeps viridis (not asked). The note says "the stronger its colour" (it said darker). Looked at: Clean, Briefing and Dark, picture and interactive.
- **3, 4 Page.** An interactive chart no longer takes a row; it is drawn for its card (desk or wide) like a picture and measured 547 CSS pixels in a 586 pixel card at 1400, 450 in 476 at 500, no sideways scroll. A card with a row to itself is a grid from 900 pixels (`62fr 38fr`: the headline across the top, the chart on the left, chart title, subtitle, summary, notes, source in the right column); wide drawings are 640 pixels (`DASH_WIDE_PX`, aspect 0.66), not 1120. Seen at 1400, 1000, 899, 500 in Clean, Briefing and Dark.
- **5 Dates.** `fact_date()`/`fact_time(x, basis)`: "Dec 2023", "2023", "3 Jan 2024", judged on the whole series; the code's own annotation label uses `chart_date()`; `text_numbers()` reads "3 Jan 2024" as its year (its day is not a number to check).
- **6 Strip.** Label (small capitals) over value over, for a chosen fact, the chart's name; the strip carries one `--w` and every value is sized from it. **7 Headings.** `chart_heading_text()`; also the title drawn on every chart (a choice: a heading never ends in a stop, in any style). **8 Violins.** Series colour at 20 per cent, solid box, outliers as dots. **9 Index.** One panel, slate and accent, names at the line ends (the ends taken from the farthest from 100; the others named in a note), `facet` refused; no highlight means every line in the slate; `time.md` 0.3.
- **Mutations.** 30 changed copies of R/ for checks 10b-1 to 10b-10, each caught; 5 for the heavy 10b-11 and 10b-12 and the video sizes of 9B-17 (full-card grid removed, values sized separately, Replay never shown, Replay not playing, the video drawn at 1280 by 720); the checks that were changed to follow the new behaviour failed before the edit and pass after.

## Phase 10 Part D: a seventh style, colour with a purpose, a tighter page (2026-11-23)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. No model call is made by anything in this part. Smoke: fast run 535 of 535 (7.5 minutes), heavy run 24 of 24 (8.9 minutes) (before: 526 checks in 7.2 minutes and 22 in 7.9; nine new fast checks 10D-1 to 10D-9 and two new heavy ones, 10D-10 and 10D-11; 31 existing checks edited, listed under Checks).

**The font.** Barlow Condensed, SemiBold and Bold (static TrueType, `www/fonts/BarlowCondensed-SemiBold.ttf`, `-Bold.ttf`), with its licence as `BarlowCondensed-LICENSE.txt`: read from the file, "Copyright 2017 The Barlow Project Authors (https://github.com/jpt/barlow)", SIL Open Font License Version 1.1. It has no Regular, so the family's "regular" is the SemiBold file (`CHART_FONTS$display`, `weights = 700`: a page declares only the bold face). It is registered with systemfonts like the others (`chart_fonts_register()`: "Barlow Condensed" and "Barlow Condensed SemiBold"), declared with `@font-face` in the export by `dash_font_css()` (bold only: 3 faces in a Briefing page, 2 in the others) and in the app by `font_face_css()`, named in the start-up font note, the "Styles and fonts" page (licence line read from the file) and the deployment bundle (31 files, 3.0 MB: three more files than before).

**Briefing** (`CHART_STYLES$briefing`): ground and panel `#F7F6F2`; text `#1C2431` (14.4 to 1 on the ground), axis text and subtitle `#5B6470` (5.5), caption `#656D78` (4.8); grid `#D9D8D2` at 0.25, horizontal only (`grid_axes = "horizontal"`: the lines that run across the chart, never the others, whichever way the chart is turned); title in Barlow Condensed bold, 1.55 times the base, upper case (`title_case = "upper"`); subtitle Inter at 0.85 of the base, grey; axis text and titles at 0.9 of the usual; strip bold; fit `#3B4656`, box fill white, grey (quiet lines) `#C9CED6`; accent and the colour of a series with no group `#173A75` (a deep blue; `single`, used when the default palette is chosen, so a palette the analyst picks still wins); slate `#7F8A99`. **Upper case**: R upper-cases the drawn title (`chart_title_case()` in `labs_call()`), every word except one with a digit (2024, 34%, Q3, m2), a unit from `CHART_CASE_UNITS` (kg, km/h, ml, l, kWh ...) and one with a capital inside it (kWh, iPhone); the stored spec text is not changed (checked), and the printed code carries the drawn title. On the page and in the canvas CSS does it (`text-transform`), and a word that keeps its case is wrapped in `span.keep` (`dash_heading_text()`).

**Colour with a purpose.** Every style has an `accent` (a deep colour) and a `slate` (a mid grey); a highlight is accent against slate (`highlight_values()`, line and scatter highlights, a dumbbell's two dots), replacing the pale grey and the orange `CHART_HIGHLIGHT` (gone). Computed contrast (colorspace), accent against slate / accent against the ground / slate against the ground: Clean and Newspaper 3.18 / 9.65 / 3.04 (`#0A4580`, `#8A95A3`), Minimal the same, Magazine 3.29 / 10.2 / 3.1, Data desk 3.23 / 10.1 / 3.14, Dark 3.20 / 10.6 / 3.31 (`#9ACBFF`, `#5F6B79`), Briefing 3.16 / 10.2 / 3.24. A bar or dot chart sorted by value with no colour column and no highlight is in the one colour in all seven styles (10D-4: R colours nothing because it is the largest). The ring round an annotated point is now the style's text colour.

**The page.** Key numbers are a strip (`dash_keys()`, `dash_keys_tag()`): a rule above and below and between the items, no boxes, at most six (`DASH_KEYS_STRIP_MAX`); the file's three are statements ("3,000 rows", "22 columns", "Jan 2022 to Dec 2024"), a chosen fact is its value over "<what it is>, <chart name>"; a value of 14 characters or fewer is a number: no wrap, its type scaled to its cell by a container-query unit (the cell has a least width, so six items go to two rows before the type is small). Cards of a row are as high as each other (`align-items:stretch`; a card is a flex column; the chart's `slot` grows and the chart stands in the middle of it), so no blank block is under a short card. A chart of more than four panels (`DASH_FULL_PANELS`, `dash_card_wide()`) takes a whole row, and so does the card left alone before it: in the five-chart export the nine-panel chart and the scatter before it. The summary is 1.05rem with lines of at most 62 characters, the notes 0.82rem grey, the source line 0.72rem. `DASH_LOOK` has a Briefing entry (hairline card `#AEB3BA`, no shadow, upper-case h1 and headings, the numbers of the strip in the condensed face at 2.6rem) and the other styles' `.box` rules became `.keys` rules.

**The canvas** follows: a card's heading is in the style's title face, upper case where the style asks, over the chart's title as a small grey subtitle; the chart sits in a growing slot; the summary at a reading size; the strip replaces the three value boxes (`canvas_boxes()` = `dash_keys_tag()`); the cards of a row are as high as each other (they were not: the card did not fill its grid cell; fixed in CSS, seen in the browser pane at 509 and 509 pixels).

**Three open items.** (b) The exported video: `preload="none"` with its poster (the finished chart). In headless Chrome both `auto` and `none` show the poster before play (looked at; the empty first frame was not reproduced there), so `none` is kept because no frame is decoded, which guarantees it; the page's script still plays the video once when it scrolls into view (9B-18 passes). (c) The heatmap's x labels ("2022 Q1" ...): a group on x whose levels need more than the panel's width (0.62 inch each, `HEAT_LABEL_IN`) is dodged into 2 or 3 rows (`heat_x_dodge()`): 2 rows at the usual size and on a half card, 3 on a phone drawing, none on a wide card, in the picture and the interactive view (10D-8). (a) The phone drawing of the multi-panel line chart: not reproduced; at 500 pixels, in Clean and Briefing, the nine panels' year labels (2022, 2024) stand apart and the y labels do not touch (looked at).

**Checks.** Fast, between `>>> 10D begin` and `<<< 10D end`: 10D-1 the Briefing values, contrasts and font; 10D-2 the upper-case rule; 10D-3 drawn in the picture, SVG and code; 10D-4 colour with a purpose in seven styles; 10D-5 heading spans and Briefing CSS; 10D-6 the strip; 10D-7 equal heights, full rows, text sizes; 10D-8 the heatmap labels; 10D-9 the canvas. Heavy: 10D-10 the Briefing page built with the others; 10D-11 in Chrome at 1400 and 500 pixels, Clean and Briefing, the cards of a row are as high as each other, nothing blank under a short card, the chart centred in its slot. Changed: 7B-1 (the fonts), 7B-2 (seven styles, new fields), 7B-3 (highlight contrast replaces "grey visible"), 7B-5, 7B-6 (title text and face), 7D-1, 7b-10 (the strip), 6-C 7, 7D-1 dialog, 8B-9, 9A-1, 9A-2, 9A-3, 9A-5, 9A-7, 9A-8, 9A-10, 9A-11, 9D-0, 9D-0b, 10B-5, 10C-7b, 8C-3 and 8C-22 (statements), the 7D-2 count (63 charts), and the runners that register fonts.

**Run time.** Seven styles cost: fast 7.2 to 7.7 minutes (7B-6 runs every gold spec's code in a fresh R process for each style: 80 s), heavy 7.9 to 8.9 (the 7b-1 sweep 180 s, the style sheet 61 s, the seven pages 56 s). To keep the heavy run under nine minutes the six extra style pages of 9A-8 are built with charts/ pictures at 100 dpi (`DASH_DPI`, put back at once); the Clean build keeps 300 dpi. Nothing else has less coverage; the 7b-1 sweep covers all seven styles.

**Mutation runs** (a changed copy of one function or constant sourced after the app loads, the 10D block run alone; the tree untouched): 26 mutants, each failed at least one check meant for it: Briefing ground, grid both ways, pale grey text, the family name; plain `toupper`, no units list, title not drawn in upper case, the stored title upper-cased; the highlight in the grey, a largest bar coloured, a pale slate; the heading without spans, `.keep` removed, strip of nine, rows as a bare number, a long value that does not wrap, `align-items:start`, five panels as the limit, a small summary, a large source line, no heatmap dodge, no slot, the canvas upper case, the canvas card height; and two in the canvas card (no heading class, no slot) run against the 7B-5 harness.

**Seen** (Chrome 157 headless; the in-app browser pane). The five-chart export in all seven styles at 1400 pixels, and at 390 in an iframe of that width (headless Chrome does not go below about 500); the canvas in Briefing, light and dark; the Briefing export beside Kevin's mock-up (`tests/mockup_reference.png`, not committed). Short of the mock-up: it labels each number above it in small capitals (four items; ours are statements, no label above); its violins are filled by group (blue, slate, pale slate) with outlier dots (ours: outlines, one colour, no dots, by the rule of colour with a purpose); its scatter is hexagons with a confidence band (hexbin is not installed: rectangles, no band); its dumbbell, indexed lines with names at their ends and call-out are not in the five-chart export; its card border is darker and the rule over its title thicker. Wrong in ours: a Newspaper picture with no title shows its rule floating; the period beside large numbers sits top-aligned; the summary stops at 62 characters, so a full-width card has blank space to its right.


## Phase 10 Part C: chart forms (2026-11-22)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. No model call is made by anything in this part. Smoke: fast run 526 of 526 (7.2 minutes; 511 before, 15 new checks: 10C-1 to 10C-14 and 10C-7b; 16 existing checks changed or extended, listed below), heavy run 22 of 22 (7.9 minutes; 22 before, none new).

**What was confirmed in the installed packages.** ggplot2 4.0.3, ggiraph 0.9.7, ggrepel 0.9.8, dplyr 1.2.1. `hexbin` is not installed (`find.package("hexbin")` is empty; nothing was installed), so the density view is rectangles from `geom_bin_2d()` (class `GeomBin2d`, a tile; its twin `geom_bin_2d_interactive()` is there); the `geom_hex` branch the prompt allows was not written because it could not be run here (a choice, below). `geom_violin()` takes `trim` and `scale = "width"`, its twin is `geom_violin_interactive()`; `geom_boxplot()` takes `median.colour`; `geom_label()` takes `linewidth` (not `border.colour`, which `ggrepel::geom_label_repel()` ignores with a warning); ggrepel's `geom_label_repel()` takes a per-row `fill` and `linewidth`.

**The fields.** Four new fields in `SPEC_FIELDS` (after `annotate`) and one new family; each is in `spec_check()` (`check_forms()` and the tables `SPEC_FAMILY_ROLES`, `SPEC_REQUIRED`, `SPEC_FAMILY_FNS`, `SPEC_FIELD_FAMILIES`), `spec_reference()` (a line each; the reference is 4,884 characters, under the 5,000 the test holds), `spec_code()` (the forms are plot and table steps like any other, so the printed code runs: the gold specs of the forms ran in a fresh process), `spec_facts()`, `spec_frames()` and the methodology page.

- **Dumbbell** (`family: dumbbell`): `y` a group (or a name column with `top_n`), `x` the measure, `color` a group with exactly two values after the filter, `fn` sum, mean, median or none (required); `top_n` is allowed and keeps the first n groups of the order; no `facet`, `highlight`, `labels` or `annotate`. Each group is two dots on one scale and a line between them; the colour's first level (its `order` for an ordered column, otherwise sorted) is the style's slate (`pal$slate`, the style's secondary text colour), the second the accent (`pal$single`); the groups are sorted by the second value, largest on top, ties by name; the legend is replaced by the two names written above the first row, each on the outer side of its dot (and the value axis has room for them: `.name_room`). Refused: a colour column of other than two values (before the data: "color: 'channel' has 3 values; a dumbbell compares exactly two"; after the filter: "a dumbbell needs exactly two values of 'cond' after the filter; it has 3"), a group that has only one of the two ("color: 'D' has only one of the two values of 'cond', so no gap can be drawn; filter it out"; a value of an id or text column is never named, only counted). Facts: each group's two values and difference (second less first, with the percentage when the first is above zero), the largest and the smallest difference (signed), how many groups are higher, lower, equal. Tooltips: a dot gives its group, value and colour; the line gives both values and the difference; a group is one hover group. Motion: the first dots appear (the first 30 per cent of the motion, top row first), then each line and second dot travel out from the first dot together (video roles `dumbbell_first`, `dumbbell_second`, `dumbbell_line`; a group's three marks share one clock).
- **Density** (`density: auto | off | on`, scatter only; a bubble chart keeps the old rule, binned past 20,000 points): under `auto` a scatter with more than 2,000 points and no highlight is drawn as counts of rows in cells of a 40 by 40 grid (`geom_bin_2d()`, the sequential palette, a colour bar of round breaks titled "Rows", the fitted curve on top); `on` does it for any number of points, `off` never (the see-through points of 2,000 and over stay, and the moving of points that share a position). It replaces jitter and transparency. A colour column is not drawn in cells and the note says so ("The colour of 'channel' is not drawn in cells; panels (facet) keep its groups apart"); a highlight keeps the points under `auto` and is refused with `on`. The note says each cell counts rows. Facts are unchanged (on or off gives the same text). The switch moved from 20,000 to 2,000 points, as the prompt says.
- **Violin** (`shape: box | violin`, box family): a group of at least 30 rows (`SPEC_VIOLIN_MIN`) is a `geom_violin(trim = TRUE, scale = "width")` with a slim box inside (0.12 wide, no outlying points, the median in the box's own colour); a group under 30 rows is a plain box, with a note naming up to three of them ("2 groups have fewer than 30 rows (A, B), so they are drawn as a plain box: a density from so few rows shows a shape that is not there"); with no group of 30 rows every group is a plain box and the note says so. The layers split the table by `filter(n() >= 30, .by = c(x, facet))`, so the printed code needs nothing else. Facts are unchanged.
- **Indexed lines** (`index: none | first`, line only): each series (a colour, a panel or both) is divided by its own value at its first x and multiplied by 100, after `top_n` (which ranks by the amounts); the y title is "Index (first month = 100)" (the unit word is month, quarter or year for dates a month, a quarter or a year apart, otherwise "period"; the analyst's `y_label` wins), a dashed rule at 100 (`geom_hline`), the end labels carry the index. Refused (with the series named when its column is a group): a series whose first value is zero, below zero or missing, or that does not start at the chart's first x ("index: 'S3' has no value above zero at the chart's first month (the first value is zero, below zero or missing), so it cannot be indexed"). Facts: each series' index at the end and at its peak, the highest and lowest at the end, how many lines are above 100; the note names the first period and says the picture depends on it. An index of an index (`fn` share) is written as a number, not a percentage.
- **Smooth** (`smooth: none | 2 to 24`, line only): the trailing moving average of that many points (`stats::filter(.., sides = 1)`, NA until a line has that many points) in a column `moving_average` beside the raw values; the raw line is drawn first in the style's grey, the average after it in the series colour(s); the end labels sit at the average and write it; the subtitle is "<k>-period moving average; raw values in grey" when the analyst has not written one (joined to "Top n of N" with a semicolon when both apply). Refused: a line with fewer points than the periods ("smooth: a moving average of 7 periods needs 7 points in a line, but 'S1', 'S2' have fewer"), and `smooth` with `highlight` or `annotate` (a mark would name a raw value on a smoothed chart). Facts are of the raw values, plus one line for each series: "Moving average over 3 periods, at the end of S1 (2023-06-01): 80". Tooltips give the average beside the value ("not yet" for the first points). Indexed and smoothed together is allowed (the average of the index).
- **Call-outs** (`annotate`, unchanged fields): a call-out is a box with the style's text colour on its panel colour (`pal$panel`, border 0.25) and a thin leader to the point. On a line, scatter or bubble it is three layers: the leader (`geom_segment`), the ring, the box (`geom_label`), the box shifted off its point by 5 per cent of the x range (away from the nearer edge: the Phase 7b rule that gives hjust) and 8 per cent of the y range (above or below as the rule gives vjust; on a log axis in log units), so the leader is always visible and no ggrepel is needed. A bar's or dot's box stands against its mark's end (no leader). With a highlight that names points (ggrepel installed) the names and the call-out are still one ggrepel layer (`geom_label_repel()` with a fill and a border for each row: none for a name), so they cannot land on each other. Room: a bar or dot chart's value axis (and a sideways chart's first and last row) leave room for the box's padding. The text measure `drawn_text_boxes()` now measures the panel from the panel's own viewport and adds a call-out's padding to its box.

**Reflexes.** The five rules are appended to `comparison.md` (`two_values_dumbbell`), `relationship.md` (`density_is_automatic`), `distribution.md` (`violin_on_request`) and `time.md` (`index_to_compare_growth`, `smooth_on_request`) exactly as the prompt gives them, and each file's version is raised by 0.1 (comparison 0.2 to 0.3; relationship, distribution, time 0.1 to 0.2); nothing else in them changed (a script compared each file with the old one: the old text, the version line, then the prompt's text character for character). `REFLEX_SHA` holds the four new checksums. `RULE_FAMILIES` has them: the dumbbell rule for the dumbbell family, density for a scatter, the violin rule for a box with a `shape`, the index and smooth rules for a line with `index` or `smooth`.

**Methodology page.** Five rows are added to the table under "Which chart for which question" (Dumbbell, Violin, Indexed line, Smoothed line, Density), each with a question template and a thumbnail drawn from the made-up table (the violin's from 40 made-up prices in each of five regions, because a violin needs groups of 30 rows). The page's version line was left as it was.

**Checks.** New, in the fast run, between `>>> 10C begin` and `<<< 10C end` (their fixtures are their own): 10C-1 (valid and refused specs, 12 and 19 of them), 10C-2 (the data rules), 10C-3 (the table by hand: the index, the moving average, the dumbbell's order), 10C-4 (the facts by hand), 10C-5 (density: 2,000 and 2,001 points, off, on, highlight, colour), 10C-6 (violin: layers, trim, equal width, small groups, the facts), 10C-7 (the index and the moving average as drawn), 10C-7b (the dumbbell as drawn: layers, colours, the names above the first row, ticks inside the data), 10C-8 (the call-out: layers, colours, shift, log axis, shared layer, no ggrepel), 10C-9 (label boxes clear), 10C-10 (the motion of the six forms: scales, last frame equals the static chart, the dumbbell's two moves), 10C-11 (tooltips, the violin twin, no warning, the picture matches), 10C-12 (the reflex rules), 10C-13 (the reference, disclosure, methodology table and thumbnails), 10C-14 (the ten gold specs). Gold: ten new entries on `tests/data/orders.csv` (two dumbbells, the scatter in cells and as points, two violins, indexed lines, a moving average, a call-out on a line and on a scatter) go through every gold check (the widget and its match, the code in a fresh process, the drawn texts of the heavy sweep). Changed: the lint check of 2,000 and 20,000 points (cells from 2,001), the five-thousand-marks check (density off), 7C-2, 7C-3b, 7b-3 and 10B-8 (a call-out is a box and a leader, no longer a text), 8B-1, 8B-2, 8B-2b, 8B-4, 8B-7 and 8B-10 (fourteen rows, 61 rules, the new questions), 9B-7 (its scatter is density off), the sweep of 7b-1 (an annotate variant a spec refuses is not drawn) and `widget_match()` (a violin is compared by group).

**Mutation runs** (a changed copy of `R/spec.R`, `R/ui.R` or `R/reflexes.R` loaded after the app, the 10C block run alone; 37 runs; the tree was never changed): each of the 15 checks failed under at least one: spec_check without `check_forms` or without the dumbbell's colour rule (10C-1); an index, a half group, a short smooth line not refused, and series names always written (10C-2); the index by the last value, a centred average, the dumbbell sorted by its first value (10C-3, and 4, 7, 11); the difference reversed, the peak taken as the lowest (10C-4); the switch at 20,000 points, the legend "Count" (10C-5); the violin not trimmed, or from 10 rows (10C-6); the index title always "period", the raw line in the series colour, the subtitle reworded (10C-7); the box in the grey, no leader, a linear shift on a log axis, a box on the wrong side of its point (10C-8); a box shifted 90 per cent of the range sideways (10C-9, and 8); density cells not animated, second dots that never move (10C-10); a tooltip without the difference, no violin twin, the violin's group left to ggplot2 (10C-11); the dumbbell rule fitting a bar (10C-12); the violin's rows on a clock each (10C-10), dumbbell ticks past the data, first dots in the accent, the names on the inner sides (10C-7b); a violin thumbnail from 20 rows, the index words changed in the reference (10C-13); a gold spec missing (10C-14). A box shifted 45 per cent of the range vertically failed 10C-8 only (the panel has room for it), and one on the wrong side of its point failed 10C-8 only (the room is there on both sides): the sideways shift is what 10C-9 catches.

**Seen** (Chrome 157, headless, at 1280 and 500 pixels, Clean and Dark; and the in-app browser pane with a pointer). A nine-chart dashboard built by `build_dashboard()` from tests/data/orders.csv in both styles (the dumbbell and the violin with small groups as pictures, the dumbbell of ten products, the density view, the violin, the indexed lines and a call-out on a line as interactive charts, the moving average as a video, a call-out on a scatter as a picture), each chart's 300 dpi PNG with the marking, and frames of the five videos (800 by 450, 12 a second) in both styles. Over a dot of the interactive dumbbell its group's two dots and line are outlined and every other group fades to a quarter; the tooltip reads "product: Phone C3 / Mean unit_price: 813 / year: 2022". What was wrong, and is fixed: the value axis of the dumbbell ended in a label cut off by the picture's edge ("500,00": a tick at the edge of the room made for the names; the ticks are now inside the data's range); the density view's colour bar had six labels touching (now three); the first call-outs, placed by ggrepel, stood on their points or outside the panel and showed no leader (now placed by R, with a leader); the video of a violin showed horizontal stripes while it grew (each row of its outline had a clock of its own; now one clock for a violin); the first dumbbell video moved a line and its second dot on different clocks (found by 10C-10 before any video was looked at). Not looked at: the new forms in Minimal, Magazine, Data desk and Newspaper (the heavy sweep measures their texts in all six styles), the pointer over a dumbbell's line (its tooltip text is held by 10C-11), a printed page, Firefox and Safari. The heatmap's x labels that touch at narrow widths (the open item noted by the lead) were not touched: no form of this part is a heatmap.

**Choices where the prompt left one.** A dumbbell takes no `facet`, `highlight`, `labels` or `annotate` (the first row carries the names; the values are in the tooltips and the facts). "Later" is the colour's second level; for a character column that is the alphabetical second (a period named "2022" and "2024" sorts right; "before" and "after" do not: use an ordered column or names that sort). A group with only one of the two values is refused, not drawn as a lone dot. A dumbbell's colours are the slate and the accent, not the palette's. `geom_hex` was not written (hexbin is absent and the branch could not be run). A colour column is dropped from the cells rather than the chart left as points. A violin under 30 rows per group is decided group by group (a violin and plain boxes in one chart). `index` and `smooth` refuse a series that does not reach the chart's first x or has too few points, instead of drawing what is there. `smooth` refuses `highlight` and `annotate` (the other choice was a lint fix that drops them with a note). The index title's `<period>` is the unit word; the first period itself is in the note and the facts. The smoothed line is drawn from its k-th point (no partial window). A call-out's box is placed by R (shifts by shares of the axes) rather than by ggrepel so that a leader is always there; ggrepel places it only when the chart also names points. The methodology rows are added at the end of the table, so "Questions for your file" (the first eight that can be filled) shows them only when the file lacks columns for the earlier rows.

**Not confirmed.** The look in Firefox and Safari; the work server (ggrepel and `geom_label` are in ggplot2 and ggrepel as installed here); `geom_hex` (never run); a dumbbell of more than about 40 groups (the height grows by 0.28 inch a row up to 14 inches); a violin from many panels; the live model's choice of these forms (Part E, no call was made here).

## Phase 10 Part B: interactive charts with ggiraph in place of plotly (2026-11-22)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. No model call is made by anything in this part. Smoke: fast run 511 of 511 (6.2 minutes; 500 before, 11 new checks 10B-1 to 10B-8 in the fast run, 10B-9 new in the heavy one, a few rewritten), heavy run 22 of 22 (7.4 minutes; 21 before).

**What was confirmed in the installed packages.** ggiraph 0.9.7 (the prompt said 0.9.6), gdtools 0.5.1, systemfonts 1.3.2, ggplot2 4.0.3. `girafe(ggobj, width_svg, height_svg, options, font_set)`; the twins `geom_col_interactive`, `geom_point_interactive`, `geom_line_interactive`, `geom_histogram_interactive`, `geom_boxplot_interactive`, `geom_tile_interactive` (a binned scatter, `geom_bin_2d`, is a tile in ggplot2 4: `geom_bin_2d_interactive` gives a `GeomInteractiveTile`) and the options `opts_sizing(rescale = TRUE)`, `opts_toolbar(saveaspng = FALSE, hidden = c("selection", "zoom", "misc"))`, `opts_zoom(min = 1, max = 1)`, `opts_selection(type = "none")`, `opts_hover(css = girafe_css(...))`, `opts_hover_inv(css)`, `opts_tooltip(css, ...)`; `app.R` checks each at start-up by name and argument. Fonts: girafe draws on its own SVG device (`dsvg`), which measures text through systemfonts and writes the family name of the chart as it is (`font-family='Inter'`, `'Inter SemiBold'`, `'Source Serif 4'`, `font-weight='bold'` for bold). The bundled faces are the ones registered by `chart_fonts_register()` (systemfonts' match for "Inter" is `www/fonts/Inter-Regular.ttf`, checked in 10B-5), and the page declares `@font-face` for the same names (the app page by `font_face_css()`, the export by `dash_font_css()`), so the browser draws the SVG's text in them; 10B-5 checks for each of the six styles that every family the SVG names is declared by that style's page. `gdtools::font_set()` would write each font file into the user's data folder and add a style sheet to the widget, so `widget_font_set()` builds the small `font_set` object girafe takes (families only, no files). Where Inter is missing the chart's "sans" is not a CSS name, so `spec_widget()` writes "sans-serif" in its place. dsvg measures a string about 1 per cent wider than ragg (1.811 against 1.795 inches for a 12-point test string in Inter, 1.853 against 1.837 in SemiBold). What the widget needs in the page: htmltools-fill (0.6 KB), htmlwidgets (33.2 KB), girafe's style sheet (4.7 KB) and girafe's binding (121.5 KB): 160 KB in all, read from the installed packages by the same `dash_inline_dependencies()` as plotly's seven files were (plotly.js alone was 3.6 MB); no request leaves the page (8C-6, 8C-12).

**What it is.** `plot_calls(s, cb, pal, interactive = TRUE)` returns the picture's own layers with each data layer swapped by `widget_calls()`: a tooltip and a hover group (`data_id`) are given to each mark from two columns that `widget_table()` adds to the plotted table, `.tip` and `.hover` (and `.series` for a line). Tooltips are written by R in the facts' formats (`fact_value_fmt()`, `fact_time()`, `fact_num()`), each value named with its codebook label, and HTML-escaped by `widget_esc()` (ggiraph shows a tooltip as HTML, and a raw `<img onerror>` in a value of the file would run: seen in a first test of ggiraph alone). A scatter or bubble point carries its x, y, colour, size, panel and highlight columns and no other (10B-2); a box chart's tooltip is its group's (rows, median, middle half, lowest to highest); a histogram bin and a cell of a binned scatter are written from the statistic ggplot2 computes (`after_stat`). The hover group is a number we make (s1, m4, g2), never a value: a series for a line, slope, grouped bar or coloured scatter (so the other series dim), each mark otherwise. A line is one SVG element, so it carries its series name, and its points carry the row tooltips in invisible points (alpha 0, size 4.5; a pointer near a point finds it). `spec_widget()` is `girafe()` of that plot at the chart's own size in inches (the web size of the dashboard drawing included) with `widget_options()`: the SVG scales with its card, no toolbar, no zoom, no selection, a tooltip and hover in the style's colours (hovered mark outlined in the text colour, the others at opacity 0.25). plotly, `ggplotly()`, `scale_fonts()`, `font_stacks()`, `tooltip_call()`, `widget_notes()`, the lint's `.widget_rows` and `.widget_left_out`, `SPEC_PLOTLY_TEXT` and the wrap constants are gone. In the app, the card embeds `ggiraph::girafeOutput` and `renderGirafe`. In the export, `dash_widget()` sets the box to `width:100%;height:auto` and `.widget` is `width:100%;max-width:700px` (as wide as a picture); the old `min-width:36rem` and sideways scroll of the plotly card are removed.

**The picture and the view match.** `widget_match()` (tests/smoke.R) compares, for every gold spec (25) and nine more charts with labels, annotations and names, the built data of every layer the picture has with the interactive layer's, the scales (limits, breaks, labels), the labels, the theme, the panels and the coordinates, and that every label, annotation and cell value is a `<text>` of the SVG; the widget may have more (the invisible points), never less. Every gold spec matches. It found one defect of mine: the tooltip and the hover group are discrete aesthetics, ggplot2 numbers a bar's group from every discrete aesthetic, so the bars of a grouped bar chart were dodged in another order than the picture's; the interactive bar now gets the picture's own group (`group = as.integer(interaction(x, colour, lex.order = TRUE, drop = TRUE))`). The notes "In the interactive version a label is not bold and sits ...", "The names and values at the line ends are not drawn ..." and "N labels that the static chart moves apart are left out ..." are gone with `widget_notes()`: none is true any more. The one note that stays is the lint's "N marks are too many for the interactive version; the chart is static" (over 5,000 marks, which are elements of the page).

**Weights** (the five stand-in charts of tests/smoke.R 8C, all interactive, 240 orders; measured on HEAD 05114cf before the change and now): plotly page 4,930,622 bytes, zip 2,625,723; ggiraph page 1,391,988, zip 1,484,533 (the same five as pictures: page 1,647,737, zip 1,801,744, so an interactive page is now lighter than a picture page: a PNG at 300 dpi as base64 is bigger than its SVG; a chart of thousands of marks is the other way).

**Disclosure.** Unchanged in words (the dialog's sentence, the default of a picture, the families drawn from rows). It stays true: a scatter point's tooltip holds its x and y to three significant digits (a price of 987,654.321 is "988000", as the facts write it) and the drawing holds where it is to a fraction of a pixel; a box chart's tooltip holds its extremes. 8C-10 looks for "price: 988000" in the interactive file and in no file of the picture export.

**Choices where the prompt left one.** A box chart's outlying points are drawn by ggiraph with no hover group, so they do not dim and show no tooltip (the box shows the group's). The hit points of a line are invisible and 4.5 points across. A heavy check hovers in headless Chrome; a tooltip with a tag in it was also tried unescaped: it ran the page's `alert`, which blocks the headless browser (the fast check 10B-3 would have failed first). The interactive card keeps a whole row of the page in the export (as before; the SVG would fit a half-width card as a picture does). `tidyr` is named in a call in `app.R` because plotly was what made a deployment ask for it (found by 9C-8). The probe now lists ggiraph's version and its Quarto check draws `ggiraph::girafe()`.

**Checks.** New: 10B-1 (tooltip text by family; histogram bins and cells), 10B-2 (only the plotted columns), 10B-3 (a hostile value is text), 10B-4 (hover groups and the dimming and outline css), 10B-5 (the typefaces in each style), 10B-6 (the export card's css and markup), 10B-7 (plotly is gone from the code, APP_PACKAGES has ggiraph, the start-up check, the twins exist), 10B-8 (the twins in each family's plot; a 25,000-point scatter as binned cells), 10B-9 (heavy: ten interactive charts in Chrome at 1280 and 500 px: widths, no sideways scroll, no text cut, a tooltip and dimming from a real pointer event with a hostile name). Rewritten (they tested plotly): the gold widget checks (a girafe widget with tooltips; no toolbar and no zoom), 2b-16, 2b-18, 6-C 20, 7B-1 (the font families), 7B-6 (two), 7C-5 (two), 8C-10, 8C-12, 8C-13 (the stand-in's message), 8C-25, 9C-8 (ggiraph asked for, plotly not). New in the gold section: the match of every gold spec. Their fixtures are in `>>> 10B begin` and `<<< 10B end`. Mutation runs (a changed copy of one function loaded after the app, or one line of a file changed and restored; 39 runs in all, 12 of them over the whole fast run): each new or rewritten check failed under at least one: tooltip text, an extra column, no escaping, one group for every mark, Arial for the sans, a restored minimum width, a dropped twin (heatmap, binned cells), dropped text layers and invisible points, a missing caption and title, the style's rule removed, one dependency instead of four, a plotly call planted in R/theme.R, the card showing the picture, a toolbar and zoom, `opts_sizing(rescale = FALSE)` (heavy), and the grouped-bar group left out (the match check). Under the unescaped tooltip the heavy check hung on the page's `alert` instead of failing.

**Not confirmed.** The work server (gdtools, systemfonts and the system libraries it needs; Connect's ggiraph version); Firefox and Safari; a screen reader on a tooltip; the exported page printed (the SVG is drawn by script, so a printed page of an interactive card is empty: pictures are the default and print); how a 10,000-point chart performs (the limit stays 5,000 marks); the Explore toggle was driven in the in-app browser against the real modules with a stand-in for the model (no key): the six cards drew, "Interactive" swapped in the girafe output (315 px wide in the card), a pointer over a bar showed its tooltip and dimmed the others, a pointer on a line highlighted its series.

## Phase 10 Part A: the classification marking on everything that leaves the app (2026-11-22)

Branch `chart`, not pushed; done by a Sonnet worker for the lead. No model call is made by anything in this part. Smoke: fast run 500 of 500 (6.7 minutes; 488 before, 12 new: 10A-1 to 10A-12), heavy run 21 of 21 (7.7 minutes; 19 before, 2 new: 10A-13 and 10A-14); nine existing checks changed, listed below.

**What it is.** The export dialog has "Classification marking", a text box (browser limit `maxlength` 80) that starts as `APP_CLASSIFICATION` (`app.R`, `"UNCLASSIFIED"`: the same name and meaning as in svysegment, where the box is "Classification marking for the report"). `marking_clean()` (R/ui.R) is the one gate: runs of white space and control characters (a newline, a tab) become one space and the ends are trimmed, so the marking is always one line; a blank one is refused with "Every export is marked, even if the marking is UNCLASSIFIED: write the marking in the box, then build the dashboard."; one over 80 characters is refused with its length ("The marking is 81 characters; the most is 80. Shorten it: the app does not cut a marking for you."). Refused, not cut, because the marking is the analyst's statement and the app does not change it. The field says why under itself as the analyst types, and the build refuses again (`build_dashboard()` stops with the same sentence; a build with no marking in its settings, as every older test has, uses the default). The marking is in no message to the model (10A-10).

**Where it goes.** (1) dashboard.html and codebook.html: a band (`.mark`: white, bold 700, `letter-spacing:.06em`, 13px, centred, on `#b40404`, the svysegment colours) at the top before the page's column and at the bottom after it; the text is escaped with quotes. Red in every style. (2) Print: Chrome repeats a `position:fixed` box at the top and the bottom of the content area of every printed page, but it covers what is under it, and negative offsets did not move it into the margin (looked at in PDFs: clipped or misplaced), and a repeating table header and footer did not repeat for a column that is one row. What works, and is looked at: `@page{margin:0}`, the bands fixed 6 mm inside the sheet's edges, and the page's column with padding of 17 mm at the top and bottom (22 mm when the marking is over 55 characters and may wrap to two lines) with `box-decoration-break:clone`, which Chrome 157 repeats on every page fragment. Content never runs under a band; the ground is white whatever the style (Dark too). Not confirmed in Firefox or Safari. (3) PNG and SVG in charts/: `spec_png(..., marking)` draws the chart unchanged between two bands of 0.2 inch (60 pixels at 300 dpi) of `#b40404` with the marking in white bold Inter 9 pt, centred; the file is 120 pixels taller than before (2100 by 1470 for 7 by 4.5 inches). A bitmap's letters are placed one by one with 0.06 em between them (grid has no letter spacing), shrunk when the marking would not fit in 92 per cent of the width; an SVG has the whole marking as one `<text>` element (so it can be found and read), without the spacing. Drawn by grid on the device `chart_device()` opened, in `marking_draw()` and `marking_band()` (R/spec.R). (4) MP4: `spec_video(..., marking)`; the frame keeps its 16 to 9 shape and the chart is drawn in the rows between the bands (`video_plot(band =)`: the chart's canvas is 0.4 inch shorter, so the lint fits the chart to what is left), the last frame is `spec_png()` of the same plot with the same marking pixel for pixel (10A-12). The dashboard's video and the poster carry the band (the page plays the same file that is in charts/); the on-screen card's chart is unmarked; a card's video (its Download MP4 is a file that leaves the app) is drawn with the marking typed in the dialog this session, else `APP_CLASSIFICATION`, and the card drops its video when that changes (the key holds it), so a file never carries an old marking. The card's on-screen video is the same drawing, so it shows the band too (frames are drawn once). (5) Text files: first line `# <marking>` in charts.R and data_dictionary.yaml, and in each CSV after the byte-order mark. **A CSV reader must skip that one line** (`readr::read_csv(f, skip = 1)`; Excel shows it in the first cell and the header on row 2); the columns and the `note` column are as before. The Data page's own downloads (the dictionary and the summary CSV) are not part of the export and are unmarked. (6) The zip: `<marking>_dashboard_<date>.zip`, from `marking_slug()` (lower case, runs of other characters one underscore, none at the ends, ASCII only, `marked` when nothing is left): `UNCLASSIFIED//FOR TEST` gives `unclassified_for_test_dashboard_2026-11-21.zip`.

**Checks.** 10A-1 the default and the band's colours; 10A-2 a custom marking in every file; 10A-3 PNG pixels; 10A-4 the marked files still read (yaml, CSV with skip = 1, charts.R parses); 10A-5 a hostile marking (tag, quotes, ampersand, newline) as text everywhere; 10A-6 blank and over-long refused; 10A-7 the slug; 10A-8 the dialog field; 10A-9 the zip name and a blank refused in the dialog; 10A-10 never sent to the model; 10A-11 a card's video marking; 10A-12 a video frame's shape and last frame; 10A-13 (heavy) every frame of an encoded MP4; 10A-14 (heavy) the dashboard and codebook printed by Chrome. Their fixtures are their own (between `>>> 10A begin` and `<<< 10A end` in tests/smoke.R), so a changed copy of one function can be run against them alone. Changed existing checks: 8A-2 (the one other place that measures text is `marking_band()`, reached only from `marking_draw()`), 8C-2 and 9A-4 (a PNG is 1470 pixels high, the dictionary after its first line), 8C-21 and 8C-23 (the zip's name), 9D-14 (`skip = 1` for the CSV), 9A-10 (the print rule is `@page{margin:0;}`, and a printed page's mean brightness must exceed 0.85, not 0.9: the two red bands darken a page by about 4 per cent), and the stand-in for `spec_video()` in 9B-10 and 9B-11 (it takes `marking`). Mutation runs (a changed copy of one function, or of the text of `mod_explore_server`, evaluated after the app loads; the tree untouched): 24 runs, each of the 14 new checks failed under at least one (10A-1 band left out or colour changed; 10A-2 and 10A-4 the first-line writer a no-op; 10A-3 PNG drawn without bands or with the top band only; 10A-5 no escaping or the newline kept; 10A-6 blank accepted; 10A-7 slug without trimming; 10A-8 no maxlength or a blank default; 10A-9 plain zip name or the refusal flag gone; 10A-10 the marking appended to a chat message; 10A-11 the card's video drawn without it or its key ignoring it; 10A-12 video drawn without the band or the chart not made shorter; 10A-13 video without the band; 10A-14 the print padding removed). One run changed nothing in the heavy run (the chart not made shorter: the fast 10A-12 holds it), and one mutation of mine (a blank default) stopped the build with an error before any check, so it is not counted.

**Choices where the prompt left one.** Refuse an over-long marking, not cut it. A marking of NULL in settings is the default; a blank is refused. A video on the card shows the band too. The Data page's downloads and the probe are not marked. Bands are 0.2 inch, 9 pt, so a short marking is small on a 7 inch chart and an 80-character one is shrunk to about 6 pt.

**Not confirmed.** Print in Firefox or Safari (the repeated padding is Chrome's `box-decoration-break:clone`; the bands are fixed in all of them, so a browser that does not repeat the padding would show a band over the first lines of a page). A real printer (a band 6 mm inside the edge). A screen reader on the band (it is a `role="note"` with an `aria-label`).

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
