# chaRt, Phase 10b: last faults, seen by the manager in the live Briefing dashboard

The manager opened `tests/dashboard_live10/dashboard.html` at 1400 pixels. Everything below was
seen there. This is the closing fix list: do these, look at each, report, and stop. No new
features.

## How

You do it yourself or with one Sonnet worker; no mailbox. Rules as Phase 10 (branch `chart`, no
push, only `chaRt/`, PowerShell, Sonnet only, no Quarto, pandoc or X11, no `for` loops, no new
files in `R/`, look before you say done, do not start WSL). Add `phase10b_prompt.md` to
`.rscignore`. The heavy smoke run is near its limit: move a slow check to the fast run first.
At most 6 Sonnet calls (item 10). Report in the chat, in `manager/done-10b.md` and at the top of
`STATUS.md`.

## The list (all look)

1. **The video card shows empty axes.** In the export the video's still is the first frame
   (axes, no line), small, with tiny text. The poster, the reduced-motion still and the frame
   the video rests on after playing must be the finished chart. Set the poster to the last
   frame explicitly; when the video ends it stays on its last frame; a "Replay" control under
   it. Open the page in headed Chrome if it is on this machine (not only headless) and say what
   a person sees before, during and after play. The video in a card is drawn for the card's
   width (text near 12 CSS pixels), as the pictures are, not a scaled-down 1280 frame.
2. **The density chart looks broken.** Rectangles in the viridis palette on a Briefing page,
   thin strips where an axis holds whole numbers on a log scale, and a fitted line running
   through empty space.
   - Colour: the style's own sequential ramp, from a light tint to the accent (the chosen
     sequential palette only when the analyst picked one).
   - Bins: computed on the scale that is drawn (log when the axis is log), about 30 across; an
     axis with at most 40 distinct values is binned at those values, so no strip and no gap
     that the data do not have.
   - Hexagons when `hexbin` is installed (ask Kevin once to install it; go on with rectangles if
     he does not answer).
   - The fitted curve is drawn only over the range of x where there are rows.
   - Empty cells are not drawn; the legend title is "Orders" or the dictionary's word for a row
     in the plural when there is one, else "Rows".
3. **An interactive chart fills only part of a full-width card** (the dumbbell sits in the left
   60% with blank space to its right). An interactive chart is sized to its card like a
   picture, and takes a half-width card unless it has more than four panels.
4. **Full-width cards waste their right side,** because the summary stops at 62 characters. In a
   full-width card on a wide screen, put the chart on the left (about 62%) and the headline's
   subtitle, summary, notes and source in a column on the right; stack them under 900 pixels.
5. **Raw dates in the text.** "from 132,000 (2023-12-01)", "in 2023-01-01", "In the year to
   2024-12-01". The facts must name periods as the axis does: "Dec 2023" for monthly data, the
   year for yearly, the date in words ("3 Jan 2024") for daily. Change it where the facts are
   formatted, so headlines, summaries, tooltips, key numbers and annotations all follow; the
   number check must still find them (check it).
6. **The key-number strip is bare.** Give each item a small-capital label above its value, as the
   mock-up has: "ROWS" over "3,000", "COLUMNS" over "22", "PERIOD" over "Jan 2022 to Dec 2024";
   a chosen fact has what it is as the label and the chart's name under the value. All values
   in one row share a type size (the size the longest one needs), and sit on one baseline.
7. **Headlines end in a full stop,** which reads oddly in capitals. R drops one trailing full
   stop from a headline when it is shown as a heading (the stored text is unchanged).
8. **Violins are bare outlines.** Fill them with the series colour at about 20% opacity (one
   colour for all groups unless the spec has a colour column); the box inside stays solid.
   Outlying points beyond the whiskers are drawn as small dots, as in the box chart.
9. **Indexed lines were split into nine panels,** which defeats an index: its point is a common
   start in one panel. For a line chart with `index: first`, R keeps every series in one panel
   whatever their number, names them at their ends (dropping names that would collide, with a
   note), and draws series that are not highlighted in the slate. In
   `www/reflexes/time.md`, replace the Say line of `index_to_compare_growth` with exactly:

   ```
   - **Say:** Set `index` to `first`, so every line starts at 100 and its height is growth since the first period. Keep all the series in one panel, with no `facet`, and use `highlight` for the few the question is about.
   ```

   and raise the file's version by 0.1. Nothing else in that file. `spec_check()` refuses
   `index` together with `facet` with a sentence the model can act on.
10. **Live, at most 6 Sonnet calls,** on `tests/data/orders.csv` with the saved dictionary if
    there is one: "which categories grew fastest?"; "is unit price related to units?"; "how has
    revenue changed month by month? show the trend"; headlines; export in Briefing marked
    "UNCLASSIFIED//FOR TEST", the trend as video, to `tests/dashboard_final/`. Open it and look
    at it at 1400 and 500 pixels, and put a screenshot of each in `tests/` for the manager.

## Report

For each item: what you saw after the change. Then both smoke totals, the live output, and what
is still unseen. Say plainly if an item could not be done.
