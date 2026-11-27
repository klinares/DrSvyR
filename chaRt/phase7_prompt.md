# chaRt, Phase 7: charts that look publishable

Kevin's verdict on the charts so far: "very simple and not publishable". This phase gives them a
designed look: named styles, a bundled typeface, values written on the marks, marks for the
points that matter, and a source line. It starts with the fixes from the Phase 6 and 6b reviews.
The engine does not change: the model writes a spec, R checks and draws it, and R writes every
number that appears on a chart.

## Read first

`CLAUDE.md`; `chaRt/manager/README.md`; `chaRt/STATUS.md` (Phase 6b and Phase 6);
`chaRt/DESIGN.md` section 18; `chaRt/R/theme.R`; in `chaRt/R/spec.R` the functions `spec_check`,
`spec_lint`, `spec_plot`, `spec_widget`, `spec_code`, `spec_facts`, `spec_reference`;
`chaRt/www/reflexes/refine.md` (0.4, changed by the manager: one new reflex,
`marks_on_the_chart`, and "chart style" added to `not_in_the_chat`).

## How the work is done

The mailbox, as in Phase 6 (`chaRt/manager/README.md`). You are the lead: one Sonnet worker per
part, one at a time; a checkpoint at the end of each part and wherever that file requires one;
wait for the answer. First commit `www/reflexes/refine.md` with its checksum, and add
`phase7_prompt.md` to `.rscignore` by name. The report goes to `manager/done-7.md`.

## Rules

As before: branch `chart`, small commits, no push, nothing outside `chaRt/` created, edited or
deleted, tests from PowerShell, Sonnet only, every reply through `llm_json()`, no reply run as
code, reflex files are not yours to edit, every function and argument confirmed in the installed
package, no `for` loops, no new files in `R/`, no em-dashes in prose. Commit only files under
`chaRt/`; if `git status` shows changes elsewhere in the repository, leave them and name them in
the checkpoint. All text reaching the chat goes through `md_text()`.

Packages: nothing new is installed without a checkpoint. `systemfonts`, `ragg` and `farver`
should already be there; confirm. If `ggrepel` or `ggtext` is installed you may use it, and the
chart must still draw without it.

## Part A. Fixes from the reviews

1. **Line facts say more than two end points.** A headline compared January with December and
   called it a rise. For `line`, add to each series (at most the seven shown, or the highlighted
   ones): its highest point and when, its lowest and when; and when x is monthly or quarterly and
   the series covers more than one year, the last value against the same period a year earlier.
   Add one line for the chart: "Points per series: n". When a series has fewer than three
   points, say so and give no highest or lowest.
2. **Correlation on the scale that is drawn.** With `log_x` or `log_y`, compute the Pearson
   correlation on the logged values and word it "Pearson correlation on the log scale shown".
   The Spearman rule is unchanged (it does not depend on the scale); the "not a straight line"
   sentence then refers to the scale shown.
3. **`check_words()`: take "half" out** of the multiple words. It flagged "the middle half".
   "halved" stays.
4. **A rule must belong to the chart's family.** A histogram came back with the rule
   `box_across_groups`, so its card would show the wrong label. Build the map from rule to
   families from the reflex files if they carry enough to do it; if not, post a checkpoint with
   the list of rules and what each file says, and I will add what is missing. A rule that does
   not fit the family is removed, as an unknown rule is.
5. **Colour-vision check at the number of colours drawn.** `CHART_PALETTE_CVD` holds the result
   for five colours. Store it for every n from 2 to the palette's `max`. The tick in the Style
   select stays as it is (five). A chart that draws n colours from a palette whose result at n is
   under `CHART_CVD_MARK` gets a lint note: "Some of these n colours are hard to tell apart for
   readers with colour-vision differences."
6. **MetBrewer sequential and diverging palettes.** Kevin asked for MetBrewer by name and got
   three qualitative sets. From the installed paletteer's tables, list every MetBrewer palette
   with its kind as MetBrewer documents it (confirm where that is recorded; do not guess a kind
   from the colours), and its check result. Put the table in the Part A checkpoint with your
   proposal; add them after the answer.
7. **A chart's `say` after a change.** In the Phase 6 run, after "only 2024" the reply text
   described the change but the chart's stored `say` still described the chart before it. Report
   in the checkpoint how `say` is stored and shown today (the chat text, the card, the spec), and
   propose the rule; do not change it before the answer.

## Part B. Styles and type

1. **A typeface that travels with the app.** Charts are drawn by ragg on a server whose fonts we
   do not control. Bundle one sans family and one serif family under `www/fonts/`, each with its
   licence file, registered at start-up (`systemfonts`; confirm the function) and declared to the
   page with `@font-face` so plotly and the HTML use the same faces. Proposal: Inter and Source
   Serif 4, both under the SIL Open Font License as far as I know; confirm the licence from the
   files you download, and take regular, semibold and bold only. If you cannot download them,
   post a checkpoint. With the fonts missing, the app starts and draws in the default sans, and
   says so once on Start here.
2. **`CHART_STYLES`** in `R/theme.R`: a list, one entry per style, each a set of named values
   (background, panel, text colours, grid colour and which grids, axis line and ticks, title
   family, weight and size, subtitle, caption, strip, the single-series colour rule, the grey
   used behind a highlight, legend place). `chart_theme()` takes `style`. Six styles, named
   neutrally: the handout these come from names publications, and the app must not suggest it is
   theirs or copy a logo or tag.
   - **Clean** (default; today's look, tightened): white, a light grid along the value axis
     only, bold sans title, grey subtitle.
   - **Minimal** (after Tukey and Tufte): no grid, no axis line, ticks only; range frame if
     ggplot2 can do it simply (confirm), else plain; the least ink that still reads.
   - **Magazine**: a pale tinted background, white horizontal grid, a heavy sans title, the
     value axis labels inside the top of the plot where that reads well, a thin rule above the
     title.
   - **Data desk**: light grey background, darker grid in both directions, large bold title,
     axis titles kept, no axis lines.
   - **Newspaper**: white, serif title and subtitle, sans labels, thin black rule under the
     title block, hairline grid.
   - **Dark**: near-black background, light text, muted grid.
3. **Every style must hold these**, and a check must test each: text against its background at
   4.5 to 1 or better; grid against background lower than text against background; the
   highlight grey visible but weaker than any palette colour; on Dark, a palette colour too dark
   to see (Okabe-Ito's black) swapped for a light one, in the chart and in `spec_code()`.
4. **The single series follows the palette**: one series with no colour column is drawn in the
   chosen qualitative palette's first colour, not a fixed blue.
5. **One style per dashboard**, chosen in the Style dialog beside the palettes, with a small
   drawn sample of each. It is the analyst's choice; the model never names a style. Changing it
   redraws every card and does not mark any text as changed.
6. `spec_widget()` (plotly) and `spec_code()` follow the style. The code `spec_code()` prints
   must still run on its own in a clean R session with ggplot2 and dplyr: it carries the style
   as a plain `theme()` call and falls back to the default sans when the bundled font is not
   registered. Check that by running the printed code in the smoke test for each style.

## Part C. Words and numbers on the chart, all written by R

Two new spec fields. Add them to `spec_check()`, `spec_reference()`, `spec_code()` and the
YAML; the reflex for them is already in `refine.md`.

1. **`labels`: `auto` (default), `on`, `off`.** Values written on the marks.
   - `auto` writes them on a bar or dot chart with at most 12 marks and no facets, and at the
     end of each line when there are at most 7 series (the series name, in the series colour, in
     place of the legend; the value too when there is room). With labels on a bar or dot chart
     the value axis loses its grid and keeps its title.
   - Numbers are formatted as the facts format them (the same function), so a label and a
     headline never disagree.
   - Labels must not overlap each other or the marks: use `ggrepel` if installed; without it,
     drop the labels that would collide and say so in the notes.
   - On a heatmap, `on` writes each cell's value when there are at most 60 cells, in black or
     white by the cell's lightness.
2. **`annotate`: up to two of `highest`, `lowest`, `first`, `latest`.** R finds the point,
   marks it and writes its value (and its x value where that helps). For `line` with several
   series it applies to the highlighted series, or to the series with the highest value when
   none is highlighted. For `scatter` and `bubble`, `highest` and `lowest` refer to y. Families
   that cannot take a kind refuse it in `spec_check()` with a sentence. The model never writes
   the text of an annotation.
3. **Highlighted points carry their names** on a scatter or bubble when the highlight names at
   most 8 values, drawn by R from the data.
4. **A source line under every chart**, written by R into the caption when the analyst has not
   written one: "Source: <the dictionary's source, else the file name>. <n> rows<; the filter in
   words><; m left out for missing values>." Add an optional `source` line to the data
   dictionary's file-level fields (the Data page and the YAML). The analyst's own caption
   replaces the source line; say in the notes when it does.
5. `spec_widget()`: labels and annotations survive the conversion to plotly, or the notes say
   which did not; nothing is silently lost.
6. Facts and checks are unchanged by this part: labels and annotations show numbers the facts
   already hold. Add a check that every number R writes on a chart for `labels` and `annotate`
   appears in that chart's facts.

## Part D. The screen, a style sheet, the tests and a short live run

1. **The screen.** The Style dialog gains the style choice. The file-name value box does not
   wrap in large type (smaller type or a cut with the full name as a tooltip). Card buttons read
   clearly in dark mode. If `bsicons` is installed, the card buttons take icons with their words
   as labels for screen readers.
2. **`tests/style_sheet.html`** (written by `tests/gallery.R`, no model call): every family from
   `tests/gold_specs.yaml` drawn in every style with the default palette, then one family in
   every qualitative palette on Clean and on Dark, and three charts with labels and
   annotations. This page is how Kevin judges the look without a key. Git-ignored, like the
   other generated pages.
3. **`tests/smoke.R`.** Keep what applies. Add one check per item above, show each can fail,
   and say which were replaced and why.
4. **`tests/llm_check.R` step 9** (live, Sonnet, at most 12 calls, with the call counter), on
   `tests/data/orders.csv`:
   1. "How has revenue changed by region?"
   2. select it; "mark the highest month"
   3. "which product categories bring in the most revenue?" (expect value labels by `auto`)
   4. select it; "remove the numbers on the bars"
   5. select it; "use the newspaper style" (expect `cannot`, pointing at Style)
   6. "do cheaper items sell in larger quantities?" then `summarize_charts()` for the canvas.
   Print per turn what step 8 prints. Check from the output: after turn 1, the line chart's
   facts hold highest, lowest and, if it is monthly, the year-earlier line; the scatter's
   correlation names the scale.
5. **Look at it.** With the `chart` preview: the Style dialog with its samples, and one card
   redrawn in each style if you can get a chart on the canvas without a key (the smoke test's
   stand-in is not available in the preview; say what you could and could not see).

## Checkpoints

End of each part, as `manager/README.md` says. Part A's must carry the MetBrewer table (item 6),
the rule-to-family findings (item 4) and the `say` report (item 7). Part B's must say what the
fonts' licences are and how each style scored on the contrast checks. Part D's live run needs no
checkpoint unless it would pass 12 calls.

## Report back (`manager/done-7.md`)

1. Files changed, with line counts; checks replaced, with reasons.
2. The smoke total and the new checks' lines.
3. The styles: each one's values and its contrast numbers. The fonts and their licences.
4. The live run's output, complete, and which turns went to the wrong kind of reply.
5. What `spec_widget()` keeps and loses under each style, labels and annotations included.
6. What was seen in the browser and on the style sheet, and what nobody has seen.
7. Everything you could not confirm, and every departure and why.
