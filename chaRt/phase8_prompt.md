# chaRt, Phase 8: a server with no X11, the methodology page, and the dashboard export

Kevin has used the app and asked for four things. Three are here; the fourth (MP4 motion) is
Phase 9 and depends on what Part A finds.

1. The work Posit Connect server has no X11. Nothing in the app may need it.
2. A Methodology page: Tufte's principles, which chart suits which question, and example
   questions a user can try.
3. The analyst chooses which charts go into the exported dashboard, and exports it.

## Read first

`CLAUDE.md`; `chaRt/manager/README.md`; `chaRt/STATUS.md` (Phase 7b and Phase 7);
`chaRt/DESIGN.md` section 18; `chaRt/www/methodology.md` (new, written by the manager; not yours
to edit); `chaRt/probe/app.R`; in `R/ui.R` the Explore server and the Methodology page; every
place in `R/` and `tests/` that opens a graphics device or measures text.

## How the work is done

The mailbox, as in Phase 7. You are the lead: one Sonnet worker per part, one at a time; a
checkpoint at the end of each part and wherever `manager/README.md` requires one; number them from
q-008; wait for the answer. First commit `www/methodology.md` and add `phase8_prompt.md` to
`.rscignore` by name. The report goes to `manager/done-8.md`.

## Rules

As before: branch `chart`, small commits, no push, commit only files under `chaRt/`, tests from
PowerShell, Sonnet only, no reply run as code, reflex files and `methodology.md` are not yours to
edit, every function and argument confirmed in the installed package, no `for` loops, no new
files in `R/`, no em-dashes in prose, all text reaching the chat through `md_text()`. For every
item marked (look), open what was drawn and look at it before you say it is done. Nothing new is
installed without a checkpoint.

## Part A. No X11, anywhere

On Linux without X11, base R's `png()` fails unless it is told to use cairo, and any text
measurement made with no device open starts the default device. The app draws with ragg, which
needs neither X11 nor cairo; the risk is every place that does not go through it.

1. **Audit.** List every call in `R/`, `tests/gallery.R`, `probe/` and any `.qmd` or template that
   opens a device, saves a plot, converts a plot, or measures text: `png`, `jpeg`, `svg`, `pdf`,
   `ggsave`, `renderPlot`, `renderImage`, `plotly::ggplotly`, `ggplot_build`/`ggplotGrob` followed
   by grid metrics (`grobWidth`, `stringWidth`, `convertUnit`, `deviceLoc`), `systemfonts`, ragg,
   `av`. For each: which device is open when it runs, and whether it could open the default
   device. Put the table in the checkpoint.
2. **One way in.** A single function in `R/theme.R`, `chart_device(file, width, height, dpi)`,
   opens the device: ragg when installed; else `grDevices::png(type = "cairo")` when
   `capabilities("cairo")`; else `svglite` when installed; else a plain sentence that the server
   cannot draw. Nothing else in the app opens a device. Every text measurement runs inside a
   device opened by it (and closes it). At start-up, set `options(bitmapType = "cairo")` when
   cairo is there, and `options(shiny.useragg = TRUE)` if the installed shiny has it (confirm),
   so a stray call cannot reach X11. Start here says once which device is in use.
3. **The fallbacks must really draw.** Check each path by forcing it (ragg "absent", then cairo),
   and compare one chart's PNG size and that the bundled fonts are used; say what differs. The
   bundled fonts on the cairo path may not register through `systemfonts`: find out, and say.
4. **Prove it without a display.** If a Linux R without X11 is at hand use it; on Windows, say
   plainly that the no-X11 case cannot be reproduced here and what the probe will show instead.
5. **The probe** (`probe/app.R`) gains a "Graphics" section: `capabilities()` for X11, cairo,
   png, jpeg; ragg, svglite, Cairo, systemfonts, av installed and their versions; a chart drawn
   by each available path and shown; whether the bundled fonts registered; `Sys.info()` and
   `R.version.string`. It still makes no model call and reads no key. Kevin publishes it at work;
   Phase 9 waits on its output.
6. **A numeric code for missing (from the manager's run).** A file with `-99` in a numeric column
   was read with no warning, because only text values in mostly-numeric columns are offered as
   missing. Add: a numeric value that is repeated (at least 5 rows or 1% of rows), sits outside
   the rest of the column by more than 3 times the interquartile range beyond the quartiles, and
   is one of the usual forms (negative in an otherwise non-negative column; or all nines, as 99,
   999, 9999, with or without a minus) is offered in the chat as "Treat '-99' as missing", the
   same button as for text. It is an offer, never applied without the click. A check with a
   column where 999 is a real maximum (not repeated) that must not be offered.

## Part B. The Methodology page and things to ask

1. **The page** shows, in this order: `www/methodology.md` rendered as HTML (confirm how the
   installed shiny or commonmark renders markdown with a table; the file's `{measure}` style
   braces are shown as they are); then "The rules the model follows", built from the reflex
   files by the existing parser: grouped by file, each rule's Label, its When and Say in one or
   two lines, and its Source, in a collapsed section per file; then "How a reply is checked"
   (the number check, the word check, the repair, in plain words from what the code does); then
   the styles and fonts with their licences. No model call. A contents list at the top.
2. **A small drawn example beside each row of "Which chart for which question"** (look): one
   thumbnail per family from `tests/gold_specs.yaml`'s data shipped with the app, or drawn from a
   tiny built-in table if that data is not deployed. Fixed images made at start-up, not per
   session.
3. **Things to ask, from the analyst's own columns.** A function
   `example_questions(cb)` (in `R/reflexes.R`, no model call) fills the page's question templates
   from the data dictionary: `{measure}`, `{measure2}`, `{measure3}` from columns with the
   measure role, `{group}`, `{group2}` from group-like columns, `{time}` from the time column,
   using each column's label. A template whose columns the file does not have is left out. Up
   to eight questions, each tagged with its chart family.
   - On **Explore**, when the dictionary is ready and the canvas is empty, the chat shows them as
     suggestion cards under "Try one of these", next to Suggest charts. A click sends it.
   - On **Methodology**, when a file is loaded, a section "Questions for your file" lists the same
     ones with a button that sends the question and opens Explore.
   - Labels and names go through `md_text()`; a check with a hostile label.
4. Checks: the page renders with no file and with a file; every reflex rule with a Label appears
   once; the templates fill and drop correctly for a file with no time column and one with no
   group; nothing here calls the model.

## Part C. Choosing charts and exporting the dashboard

1. **Choosing.** Each card has an "In dashboard" switch (on when the card is made). The canvas
   header shows "n of m in the dashboard". Cards can be reordered (move up, move down buttons;
   drag only if bslib or an installed package gives it without new dependencies). A button
   "Export dashboard" opens a dialog.
2. **The dialog.** Title, subtitle, author, date (today, editable), a short introduction (plain
   text; not checked by the number check, and the dialog says so); which of the three value
   boxes to show; the list of chosen charts in order with a small picture of each and, per
   chart, "picture" or "interactive". Warnings shown here, not after: a chosen chart with no
   headline; a chart whose text is marked as changed; a chosen palette that fails the
   colour-vision mark.
3. **Disclosure.** An interactive scatter, bubble or box chart carries its points into the
   file: anyone with the HTML can read every plotted row's values. A bar, line or heatmap
   carries only its totals. The dialog says this in one sentence beside each chart set to
   "interactive" that is drawn from rows, and the default for those families is "picture". A
   check that a "picture" export of a scatter holds no row values (search the file for a planted
   value).
4. **What is written.** One zip, `dashboard_<date>.zip`:
   - `dashboard.html`: one self-contained file, written by R with `htmltools` and no other
     program. **Kevin's ruling: the work Posit Connect has no Quarto, so nothing in the app may
     call Quarto, and do not assume pandoc either** (`htmlwidgets::saveWidget(selfcontained =
     TRUE)` needs pandoc; confirm, and do not use it). Everything is inlined by our own code:
     the stylesheet in a `<style>` element, charts as base64 PNG at 300 dpi, the bundled fonts
     as base64 `@font-face`, and, only when at least one chart is set to "interactive", the
     scripts those widgets need read from the installed packages' dependency files and written
     into `<script>` elements (confirm how htmltools resolves a widget's dependencies; say what
     the file weighs with and without). No request leaves the page when it is opened offline:
     check by searching the file for `http://` and `https://` in `src` and `href`. The layout
     is plain CSS grid of cards, responsive, in the chosen style's colours; a print stylesheet
     so the page prints one card per block. The page: title block, the value boxes, then one card per
     chart in order with headline, chart, summary, the notes and the source line; a last
     "About" card with the file name, rows and columns, the date, the model used for the text,
     which texts passed the checks, and the sentence from `methodology.md` that a chart
     describes the file. The chosen style's fonts and colours carry into the page.
   - `data_dictionary.yaml` (as now) and `codebook.html`: a readable page from the dictionary,
     one section per column (label, type, role, missing codes, a small summary: range and
     quartiles for measures, level counts for groups with at most 30 levels, distinct count
     only for ids, text and long categories). No row values beyond those summaries.
   - `charts/`: each chosen chart as PNG at 300 dpi and as SVG if svglite is installed, and
     `charts.R`, the `spec_code()` of each in one script.
5. **If Quarto is absent or older than the dashboard format,** the export still works: the same
   content written as one HTML file by `htmltools` with the charts as embedded PNGs (no
   interactive charts), and the dialog says which kind was made and why. Check both paths.
6. **Time.** Rendering is slow (the probe measured it). The working line says "Building the
   dashboard"; the buttons are disabled; an error from Quarto is shown in plain words with the
   last lines of its log, never a silent failure.
7. Checks: the switch and order reach the export; an unchosen chart is nowhere in the zip; the
   zip's contents for a three-chart canvas; `SECRET_VALUE_123` from the messy file is in no
   exported file; the fallback path; a failing Quarto call.
8. **Look.** Export a five-chart dashboard from stand-in charts in each of two styles (Clean,
   Dark), open `dashboard.html` and `codebook.html`, and look at them at desktop and phone
   width. Say what you saw. Put both in `tests/` (git-ignored) for the manager to open.

## Checkpoints

End of each part. Part A's carries the audit table and what could not be reproduced without a
Linux server. Part C's says which Quarto was found, the size and build time of the dashboard,
and what the two pages looked like.

## Report back (`manager/done-8.md`)

1. Files changed, with line counts; checks added and replaced.
2. The smoke total.
3. Part A: the audit table; which device paths drew; the fonts on each; what only the work
   server can show.
4. Part B: what the page holds; the example questions for `orders.csv` and for the messy file.
5. Part C: the zip's listing with sizes; build times; both export paths.
6. What was seen in the browser and in the exported files, and what nobody has seen.
7. Everything you could not confirm, and every departure and why.
