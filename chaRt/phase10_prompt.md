# chaRt, Phase 10: the look Kevin asked for, a classification banner on every export, richer charts

Run this after Phase 9 is finished and reported. Kevin sent a mock-up of an "executive review"
dashboard and said the charts "should look much nicer than they are". The mock-up is a generated
picture: its text is garbled and two of its charts are wrong (an index chart with categories on
the time axis; bubbles sized by the value the axis already shows). Take its design language, not
its content:

- condensed, upper-case headlines over small grey subtitles; a strip of key numbers without
  boxes; thin-ruled cards on an off-white ground; a restrained two-tone palette (one accent, the
  rest slate) with colour spent only on what matters;
- chart forms beyond bar and line: a dumbbell, a density view of a crowded scatter, a violin with
  its box, lines indexed to 100 with names at their ends, a smoothed line over the raw one,
  call-out annotations;
- charts that respond to the pointer and still look exactly like the drawn chart.

## How the work is done

As Phase 9: you are the lead, one Sonnet worker per part, no mailbox, the smoke test (both runs)
after each part. Add `phase10_prompt.md` to `.rscignore` by name. Report to `manager/done-10.md`
and a new top section of `STATUS.md`. Stop and ask Kevin in the chat only before installing a
package, removing a file, or a live run beyond the calls allowed here.

## Rules

As Phase 9, including: no Quarto, no pandoc, no X11, every device through `chart_device()`, no
`for` loops, no new files in `R/`, look at everything marked (look), do not start WSL. One
exception to "reflex files are not yours to edit": Part C gives reflex text to append **verbatim**
to four files and one version line to change in each; do exactly that and nothing else in them,
and update the checksums.

## Part A. Classification banner on everything that leaves the app

As in `svysegment` (`R/ui_results.R`: a text box "Classification marking for the report",
default `APP_CLASSIFICATION`; `R/report_bundle.R`: a full-width band written into the file,
"because the report is opened later, elsewhere, by people who never saw this app"). Read both
before you start, and use the same colours and weight (white bold on #b40404, letter-spaced).

1. The export dialog gains "Classification marking", default `APP_CLASSIFICATION`, free text, at
   most 80 characters, escaped. Blank is refused with a sentence: every export is marked, even
   if the marking is UNCLASSIFIED.
2. `dashboard.html` and `codebook.html`: the band at the top and again at the bottom of the page,
   outside the width-limited wrap. In print: on every printed page, top and bottom (confirm how
   in Chrome's print: a fixed-position band repeats on each page; look at the PDF).
3. Files that can be separated from the page carry it too: each PNG in `charts/` gets a thin band
   at top and bottom drawn by R (the SVG likewise); each MP4 gets it on every frame;
   `charts.R`, the CSVs and `data_dictionary.yaml` get it as a first-line comment; the zip is
   named `<marking in lower case with underscores>_dashboard_<date>.zip`.
4. The marking is the analyst's statement. The app does not judge or change it, and it is never
   sent to the model.
5. Checks: the default; a custom marking reaches every file in the zip (search each text file;
   for pictures, check the band's pixels); a hostile marking with a tag in it arrives as text; a
   blank is refused.
6. (look) Clean and Dark dashboards and one PNG, with "UNCLASSIFIED" and with a long marking.

## Part B. Interactive charts that look like the chart: ggiraph in place of plotly

Today "Interactive" converts the chart with plotly. STATUS records what that loses: value labels,
end labels, annotations, the Magazine lift, semibold type, and it embeds 3 MB of script. Kevin
proposed `ggiraph`, which draws the same ggplot as SVG and adds tooltips and hover.

1. Find out: is `ggiraph` installed here, and its version? If not, ask Kevin to install it and
   wait. Confirm in the installed version: `girafe()`, the `*_interactive` geoms the nine
   families need, `opts_hover`, `opts_tooltip`, `opts_sizing`, how fonts are chosen (the bundled
   faces must be used; say how you verified it), and what the widget needs in the page.
2. `spec_widget()` returns a girafe widget built from the same layers as `spec_plot()`, with the
   data layer swapped for its interactive twin. The tooltip of a mark is written by R from the
   plotted table: the group or x value, the value formatted as the facts format it, and for a
   point drawn from a row only the columns the chart plots. Hover dims the other series. No
   zoom, no toolbar.
3. The picture and the interactive view must match: for every gold spec, compare the built
   layers, scales, labels and annotations of the two; none may be missing from the interactive
   one. Remove every "the interactive version does not show" note that is no longer true.
4. Export: an interactive chart is embedded as its SVG and the few scripts girafe needs, inlined
   by our own code as now. Report the weight of a dashboard with five interactive charts before
   and after. The disclosure rule stands: a chart drawn from rows carries those rows' plotted
   values in its tooltips; the dialog's sentence and the default (picture) do not change.
5. Remove plotly from the app when nothing uses it (code, `APP_PACKAGES`, notes, checks, the
   probe keeps reporting its version only if something still needs it). If ggiraph cannot do a
   family, keep the picture for that family and say so; do not keep two engines.
6. (look) Each family's interactive view in Clean and Dark, in the app and in an export, with the
   pointer over a mark.

## Part C. Chart forms

Each is a small addition to the spec, drawn by R, with facts, lint, code and a reflex. Field
names below are fixed; add each to `spec_check()`, `spec_reference()`, `spec_code()`,
`spec_facts()`, `spec_frames()` and the methodology page's examples.

1. **Dumbbell** (new family `dumbbell`): for each group on y (sorted by the later value), two
   dots on a common scale joined by a line, one for each of exactly two values of the `color`
   column (two periods, two conditions). Fields: `y` group, `x` measure, `color` a column with
   exactly two values after filtering, `fn`. The two dots take the accent and the slate; the
   legend is replaced by the two names written above the first row. Facts: each group's two
   values and their difference, the largest and smallest difference. `spec_check()` refuses more
   or fewer than two values with a sentence. Animation: the first dots appear, then each line
   and second dot travel out.
2. **Density for a crowded scatter** (`density`: `auto`, `off`, `on`; scatter only). Under `auto`
   R switches from points to binned counts when more than 2,000 points are drawn: hexagons with
   `geom_hex` if the `hexbin` package is installed, else rectangles with `geom_bin_2d`
   (confirm both; do not install). Sequential palette, a "Rows" legend, the fitted curve on top.
   The notes say that each cell counts rows. It replaces jitter and transparency when on. Facts
   unchanged.
3. **Violin with its box** (`shape`: `box`, `violin`; box family). The violin is trimmed to the
   data (`trim = TRUE`), scaled to equal width, with the median and quartiles drawn inside as a
   slim box; groups under 30 rows are drawn as a plain box with a note, because a density from
   few rows shows shape that is not there. Facts unchanged (medians, quartiles, n).
4. **Indexed lines** (`index`: `none`, `first`; line only). Each series is divided by its first
   value and multiplied by 100; the y title becomes "Index (first <period> = 100)"; a rule at
   100. Refused with a sentence when a series' first value is zero, negative or missing. Facts:
   each series' index at the end and at its peak; the notes say that the picture depends on the
   starting period.
5. **A smoothed line over the raw one** (`smooth`: `none`, or a whole number of periods from 2 to
   24; line only). The trailing moving average of that many periods in the series colour, the
   raw series behind it in the grey; the subtitle says "<k>-period moving average; raw values in
   grey" when the analyst has not written one. Facts are of the raw values, and one line gives
   the smoothed value at the end.
6. **Call-out annotations.** An `annotate` mark is drawn as a small label box with a thin leader
   to the point (the style's text colour on its panel colour), placed by the Phase 7b rules. The
   label-box checks cover it.
7. **Reflexes: append verbatim,** then raise each file's version by 0.1.

   To `www/reflexes/comparison.md`:

   ```
   ### two_values_dumbbell
   - **When:** The question compares the same groups at exactly two values of another column (two periods, before and after, two conditions) and there are more than a few groups.
   - **Say:** Use the `dumbbell` family: the groups on y, the measure on x, the two-valued column as `color`. Each group's two dots share one scale, so the gap is read as a length.
   - **Never:** Do not use it when the second column has more than two values after the filter; use lines or panels.
   - **Label:** Two values per group, one scale
   - **Source:** Cleveland and McGill 1984 (position on a common scale); dot plots as presented in SURV752.
   ```

   To `www/reflexes/relationship.md`:

   ```
   ### density_is_automatic
   - **When:** A scatter would draw thousands of points.
   - **Say:** Leave `density` out or set it to `auto`; R counts rows in cells when the points would pile up. Set `on` or `off` only when the analyst asks.
   - **Never:** Do not sample rows or cut the data to thin a scatter.
   - **Label:** Crowded points shown as counts
   - **Source:** Design rule of this app; overplotting as presented in SURV752.
   ```

   To `www/reflexes/distribution.md`:

   ```
   ### violin_on_request
   - **When:** The analyst asks for the shape of a distribution in each group, or for a violin.
   - **Say:** Use the `box` family with `shape` set to `violin`. The box inside still carries the median and quartiles.
   - **Never:** Do not choose a violin on your own for a first look; a box or a panel of histograms says more with less.
   - **Label:** Violin only when asked
   - **Source:** Design rule of this app (a smoothed density can suggest shape the rows do not support).
   ```

   To `www/reflexes/time.md`:

   ```
   ### index_to_compare_growth
   - **When:** The question is which series grew faster, and the series differ a lot in size.
   - **Say:** Set `index` to `first`, so every line starts at 100 and its height is growth since the first period.
   - **Never:** Do not index when the question is about amounts, and do not describe an indexed value as an amount.
   - **Label:** Indexed to compare growth
   - **Source:** Design rule of this app; Tufte 1983 on comparing like with like.

   ### smooth_on_request
   - **When:** The analyst asks for a trend, a moving average or a smoother line in a noisy series.
   - **Say:** Set `smooth` to a number of periods that covers one cycle (12 for monthly data with a yearly cycle, 4 for quarterly). The raw values stay visible behind it.
   - **Never:** Do not smooth on your own, and do not report a smoothed value as if it were a month's value.
   - **Label:** Moving average over raw values
   - **Source:** Design rule of this app (a smoother must not replace the data it summarises).
   ```

   Add each new rule to `RULE_FAMILIES` with its family and conditions.
8. Checks for each form: valid and refused specs; facts by hand on a small fixture (the index, the
   moving average, the dumbbell differences); last animation frame equals the static chart; the
   printed code runs in a fresh process; label boxes clear.
9. (look) Each new form in Clean, Briefing (Part D) and Dark, drawn from `tests/data/orders.csv`
   with sensible specs, as picture, interactive view and video.

## Part D. A seventh style, and a tighter page

1. **Style "Briefing"** (the mock-up's manner): off-white ground (#f7f6f2 or near; check
   contrast), cards with a hairline border and no shadow, headlines in a condensed bold face in
   upper case, subtitles small and grey, axis text small, horizontal hairline grid only, one
   accent (a deep blue) and slate greys. Bundle one condensed display face under the SIL Open
   Font License with its licence file (proposal: Barlow Condensed, semibold and bold; confirm the
   licence from the files you download; if you cannot download, ask Kevin). Upper case is applied
   by R to chart titles in this style and by CSS to card headings in the export; the stored text
   is not changed, and numbers and units keep their case.
2. **Colour with a purpose, in every style.** A bar or dot chart sorted by value, with no colour
   column and no highlight, draws every mark in the single colour as now. Do not colour the
   largest one on R's own initiative: emphasis is a statement, and it stays with the model's
   `highlight` and the analyst. What changes is the default for a `highlight`: the highlighted
   marks take the accent and the rest the style's slate (not a pale grey that disappears on a
   projector); check contrast between the two at 3 to 1.
3. **The exported page.**
   - Key numbers as a strip: label in small capitals, number large, a thin rule between items,
     no boxes; at most six; a number never wraps or is cut (shrink the type, then drop to two
     rows). Rewrite the three built-in ones as plain statements ("3,000 rows", "22 columns",
     "Jan 2022 to Dec 2024"), and a chosen fact as "<value>" over "<what it is>, <chart name>".
   - Cards in a row share a height, and a card stretches to fill it, so there is no blank block
     under a short card (look at the scatter card in `tests/dashboard_magazine`).
   - Small multiples in a half-width card are cramped: a chart with more than four panels takes
     a full row.
   - The summary under a chart is set at a reading size with a maximum line length; notes are
     smaller and grey; the source line smallest.
4. **The app's canvas follows the same rules** where they apply (the card heading and subtitle,
   equal heights, the key-number strip in place of the three value boxes).
5. (look) The same five-chart export in all seven styles at 1400 and 390 pixels, and the canvas
   in light and dark mode. Put the Briefing export beside Kevin's mock-up
   (`tests/mockup_reference.png`, put there by the manager; do not commit it, add it to `.gitignore`) and say plainly where ours still
   falls short.

## Part E. Live check and close

At most 12 Sonnet calls on `tests/data/orders.csv`: label; "which categories grew fastest?"
(expect indexed lines); "compare revenue by region in 2022 and 2024" (expect a dumbbell); "is
unit price related to units?" (expect density by `auto`, 3,000 rows); "how do prices vary by
channel? show the shape" (expect a violin); select the revenue line and "show the trend" (expect
`smooth`); headlines; export all in Briefing, marked "UNCLASSIFIED//FOR TEST", one as video, one
interactive, to `tests/dashboard_live10/`. Open it and look. Say which turn chose a form other
than the one expected, with the reply.

## Report (`manager/done-10.md`)

1. Files changed, with line counts; checks added and replaced; both smoke totals.
2. Part A: where the marking appears, file by file; what the printed PDF showed.
3. Part B: ggiraph's version and what was confirmed; what matches and what does not, by family;
   export weights before and after; whether plotly is gone.
4. Part C: each form, with its hand-checked facts and what you saw.
5. Part D: the Briefing style's values, the font and licence, and the side-by-side with the
   mock-up.
6. Part E: the live output and what the dashboard looked like.
7. What nobody has seen, what could not be confirmed, every choice made where this prompt left
   one.
