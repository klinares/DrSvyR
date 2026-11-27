# chaRt, Phase 7b: faults found by looking at the charts

The manager looked at `tests/style_sheet.html` and read `manager/done-7.md`. Every item below was
seen on a drawn chart or in the live run. Small phase: no mailbox and no workers; you do it
yourself. Report in the chat and as a new top section of `STATUS.md`.

## Rules

As before: branch `chart`, small commits, no push, commit only files under `chaRt/`, tests from
PowerShell, Sonnet only and at most 4 model calls (item 13), reflex files are not yours to edit,
every function and argument confirmed in the installed package, no `for` loops, no new files in
`R/`, no em-dashes in prose. First commit `www/reflexes/summary.md` (0.3, one new reflex,
`change_over_time`) with its checksum, and add `phase7b_prompt.md` to `.rscignore` by name.

**The lesson of Phase 7.** 381 checks passed while an annotation was cut off at the edge of the
plot. A check that a label exists is not a check that it can be read. For every item marked
(look), draw the chart to a PNG, open the PNG and look at it before you say it is fixed, and say
in the report which ones you looked at.

## Labels and annotations

1. **Annotation text is cut off at the plot edge (look).** On the annotated bar chart the label
   reads "ghest: 765,000". A label must lie wholly inside the plot: choose its side from the
   point's place (left half of the panel: text runs right; right half: text runs left; near the
   top: text sits below), and widen the panel's expansion when it still would not fit. Add a
   check that works on the drawn chart: for every text R writes (value labels, end labels,
   annotations, names), the text's box, measured from the built plot (confirm how: `ggplot_build`
   and grid string metrics, or `systemfonts`), lies inside the device. Run it for every gold spec
   with `labels: on` and each `annotate` kind, in all six styles.
2. **An annotation sits on a line's end label (look).** "Highest and latest: 116,000 (2024)"
   covers "Islands". When the marked point is the last point of a series that has an end label,
   merge them: the end label carries the words ("Islands 116,000, highest") and no second text
   is drawn; the ring stays. The same box check as item 1, extended: no two texts R writes
   overlap.
3. **An annotation sits on the rug (look).** "Lowest: 55" over the rug ticks. Annotations keep
   clear of the rug's band. When several points tie for the highest or lowest, mark one and say
   so in the words ("Highest: 100, one of 2 points").
4. **Redundant value axis.** When every bar or dot carries its value, the value axis keeps its
   title and loses its numbers and ticks. When any label is missing, the axis is complete.
5. **A facetted line chart with `annotate`** marks one panel only today. Mark the point in each
   panel when there are at most 6 panels (each number is in the facts, or the mark is not drawn);
   above 6, mark none and say why in the notes.

## Axes and titles

6. **The time axis prints a tick beyond the data (look).** Line charts run to 2026 for the end
   labels and print "2026". Room for labels comes from expansion or the plot margin; breaks stay
   within the data's range.
7. **Axis titles use the data dictionary's label,** not the raw column name ("Region", not
   "region"), wherever the model or analyst gave no axis title. Where there is no label, the
   column name with underscores as spaces and a capital first letter. A category axis whose
   title only repeats what its tick labels make plain keeps the title; do not try to guess.
   `spec_code()` prints the same titles.
8. **Heatmap legend shows two ticks.** Give it four to six, at round values, in every style.
9. **A default colour for a single series.** A palette entry may carry `single`, the colour used
   when a chart has one series; without it, the first colour as now. Set Okabe-Ito's to its blue
   (#0072B2). The Dark rule (3 to 1) applies to it as to any colour.

## Screen and tests

10. **The Period value box wraps over four lines.** Show "Jan 2023 to Dec 2024" (month and year
    when the span is over 60 days, else the dates), in type that fits on one line at the canvas's
    narrowest two-column width, with the full dates as a tooltip.
11. **The chat text of a `charts` reply.** The Phase 7 live run printed an empty `text:` for all
    three `charts` turns, after `say` stopped being stored in the spec. Find out whether that is
    only the test's printout or whether the app's chat also shows nothing but "Added to the
    canvas." Fix whichever is wrong, and add a check on what `chat_reply_text()` returns for a
    `charts` reply taken from a real saved reply in `tests/live_replies.rds`.
12. **"A row typed on the Data page did not reach Explore", seen once.** Read the code path from
    the Data page's row field to Explore's ready state after a second file is read, and say what
    order of events could lose it. Add a `testServer()` check for: file one, row typed, file two,
    row typed, Explore ready. If you cannot find a cause, say so; do not paper over it.
13. **The style sheet.** Fix the gold bar spec's title (Islands is highest, so the title must
    not say Coast). Replace the heatmap in the "labels and annotate" rows with one of at most 40
    cells so it shows its cell values, and caption it "cell values" (heatmaps take no
    annotate). Add a row "Phase 7b" with the charts of items 1, 2, 3, 4, 6 and 8 before and
    after, if the old drawing can still be produced from git; otherwise after only.
14. **Live, at most 4 calls:** on `tests/data/orders.csv`, "How has revenue changed by region?",
    then `summarize_charts()`. Print the facts sent and the headline and summary. This is to see
    whether `summary.md` 0.3 stops a headline built on the first and last month alone. Report
    what it wrote; do not tune anything to it.

## Report

1. Files changed, with line counts; checks added and changed.
2. The smoke total.
3. For each of items 1, 2, 3, 6, 8, 10: what you saw when you opened the PNG or the page.
4. Item 11: what was wrong. Item 12: what you found.
5. Item 14's output.
6. Everything you could not confirm, and every departure and why.
