# chaRt, Phase 2b: fixes to the renderer after looking at the gallery (no model calls)

The 23 static charts in `tests/gallery.html` were reviewed one by one in the Claude project.
The renderer works; these are the faults a reader of the charts would see.

## Read first

`CLAUDE.md`, `chaRt/STATUS.md`, `chaRt/phase2_prompt.md`, `chaRt/R/spec.R`, `chaRt/R/theme.R`.

## Rules

As in Phase 2: branch `chart`, small commits, no push, nothing outside `chaRt/`, no model calls,
tests from PowerShell, every threshold a named constant, confirm every function and argument in
the installed package. No new packages (no ggrepel) and no new files. No em-dashes in prose.

`R/spec.R` builds its plots from expressions evaluated in `spec_env()` so that the code shown to
the analyst is the code that drew the chart. Keep that. Add one line to the root `CLAUDE.md`,
under rule 1, saying `chaRt/R/spec.R` is the one file where dplyr, tidyr, ggplot2 and scales
functions are called without `pkg::`, and why.

## A. The static charts

1. **Ties at the cut.** The FH top-10 bar shows ten equal bars chosen alphabetically from more
   than ten countries at the same score, and nothing says so. When values tie across the
   `top_n` cut, add the note "m values tie at the cut; the n shown are the first
   alphabetically." When every plotted value is the same, add "Every value shown is the same."
2. **Direct labels are never dropped silently.** In the 8-line chart and the 8-line slope,
   `check_overlap` removed three labels and the legend was off, so three lines cannot be
   identified. New rule for `line` and `slope`: put the end values in order; if any two
   neighbours are closer than `SPEC_LABEL_GAP` (0.04) of the y range, draw no end labels and
   show the legend, on the right, in the order of the end values. With a `highlight`, only the
   highlighted lines are labelled, and the same test applies to them. Do not use
   `check_overlap` anywhere a legend has been removed.
3. **Highlight labels on a scatter or bubble.** "United States of America" ran off the right
   edge and over "Norway". Put a label to the left of its point when the point is in the right
   half of the x range, to the right otherwise, and leave room at the edge.
4. **Facet and colour on the same column.** The faceted line chart coloured each panel
   differently and labelled each line with the name already in its strip. When `facet` and
   `color` are the same column: one colour, no end labels, no legend.
5. **Yellow.** The Highlands line and its label are close to invisible on white. Reorder
   `chart_palette()` so yellow is the eighth colour, used only when there are eight groups.
6. **Box plots** are sorted by median, highest first, unless x is `ordered` or the spec gives a
   `sort`. Allow `sort` on `box`.
7. **Heatmaps.** Rows read top to bottom in level order (alphabetical for an unordered
   category); the price heatmap has West at the top. With at most `SPEC_HEAT_LABELS` (40) cells,
   print each cell's value in it, in black or white, whichever contrasts more with the cell.
8. **Overplotting by repeated positions.** The height and weight scatter has about 1,800 rows on
   a whole-number grid, so most points hide others, and the row-count rule does not fire. Before
   the row-count rules: when more than `SPEC_OVERLAP_SHARE` (0.5) of the rows share their x and
   y with another row, draw one point per position sized by the number of rows there
   (`geom_count`, confirm it), with the note "Points are sized by how many rows share the
   position." With a `color`, count within colour.
9. **Legends are not cut off.** The football bubble's size legend runs off the right edge. When
   a chart has two legends, stack them, and give long legends more than one row.
10. **Name axes need no title.** In a sideways `bar` or `dot`, drop the title of the axis that
    lists the names ("Country" beside a list of countries) unless the spec gives `y_label`.
11. **Room below zero** on a bar comes from the table that is drawn, not from the codebook's
    minimum: ten bars at 40 need none.

## B. The code shown to the analyst

12. **Tidyverse, as a person would write it.** The FH bar's code uses `tapply()`, `sort()` and
    `head()` inside `filter()`. A `top_n` is `arrange(desc(<value>), <name>) |> slice_head(n = n)`,
    which also gives the alphabetical tie-break; ordering the bars is a `mutate()` with
    `factor()`. No base R where a dplyr or tidyr verb does the job. One pipe step per line; an
    argument list breaks only when the line would pass 100 characters.
13. **The file by its name only.** The code reads `"FH_disaggregated.csv"`, not a full path, with
    a comment saying to set the folder. A server's temporary path must never appear.
14. **Repaired column names** are restored with `rename()`, not `names(x)[i] <-`.

## C. Text that is not UTF-8

15. FH's "Cote d'Ivoire" is not valid UTF-8 in the file. Files saved from Excel on Windows
    often are not. In `read_data()`: find the file's encoding with readr (confirm the function),
    read with it, and when it is not UTF-8 add the sentence "The file was read as <encoding>."
    to `problems`. Keep it in the codebook as `encoding`, and have `spec_code()` pass it. If the
    guess is unsure, say so in the sentence. Test: a Latin-1 file made by the test with
    "Côte d'Ivoire" and "São Tomé" reads to valid UTF-8, draws as a bar with those names, and
    its generated code reproduces the table.

## D. The plotly version

The static chart is the published form. The plotly version is a second view for reading values
by hovering. Do not chase pixel parity; fix what misleads or breaks:

16. Title and subtitle both shown (the subtitle smaller, under the title), wrapped so neither is
    cut; the caption shown below the chart.
17. Text scaled so it matches the static chart at the same size.
18. No direct labels in the widget (plotly ignores their placement): show the legend there, and
    put it where it does not cover the title.
19. The tooltip names each value with its codebook label.

Then list, in the report, what still differs.

## Tests

Keep all 90. Add one check per item above that can be checked without looking (1 to 8, 10 to
15, 16, 18), each on a spec or file made to trigger it, and show the new checks can fail.
Rebuild `tests/gallery.html`. Add gold specs where an item has none: the Latin-1 bar, and a
line chart whose end values are well apart so its labels are kept.

## Report back

1. Files changed, with line counts.
2. The smoke test's output for the new checks, and the total.
3. `spec_code()` for the FH top-10 bar and the football scatter, as they are now.
4. For each of items 1 to 11: one sentence on what the gallery chart looks like now.
5. What still differs between the static and plotly versions.
6. Any item that turned out ambiguous or wrong, and the reading you picked.
7. Everything you could not confirm, and every departure from this prompt and why.
