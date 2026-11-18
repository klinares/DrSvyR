# Relationship

Version: 0.1

Two measures against each other: scatter, bubble, heatmap.

## Reflexes

### scatter_for_two_measures
- **When:** The question asks how two measures go together.
- **Say:** Use a scatter, each row a point, `fn` none. Put the measure the analyst treats as the outcome on y. A scatter lets the reader judge direction, strength, form, clusters, gaps and unusual points.
- **Never:** Do not summarise one measure within bands of the other when the rows can be shown.
- **Label:** Two measures as a scatter
- **Source:** SURV752, Correlation (Friendly and Denis 2005 on the scatterplot; correlation, functional form, clusters, gaps, outliers) and module 4 (direction, strength, form, unusual observations).

### fit_shows_form
- **When:** A scatter has enough points for a pattern (DATA shows more than about 50 rows).
- **Say:** Set `fit` to `loess` to show the form of the relationship without assuming a straight line. Use `linear` only when the analyst asks for a straight-line fit.
- **Never:** Do not describe a fitted line as an effect or a cause.
- **Label:** A smoother shows the form
- **Source:** SURV752, Correlation: Cleveland 1993 on graphing and fitting; parametric fitting and LOESS smoothers.

### known_groups
- **When:** The question asks whether the relationship differs between groups.
- **Say:** Colour the points by that group when it has at most 7 values and the file is small enough to tell them apart; with more points or more groups, use `facet` on the group.
- **Label:** Groups shown within the scatter
- **Source:** SURV752, Correlation (module 4), "Colour by a known group"; Correlation, parametric fitting by group.

### overplotting_is_handled
- **When:** The file has many rows.
- **Say:** Keep the scatter. R makes points transparent, spreads points that share a position, or bins them, and tells the analyst.
- **Never:** Do not switch to a summary chart only because there are many rows.
- **Source:** SURV752, Correlation, Reducing Overplotting (smaller symbols, jittering for discrete values, alpha blending, sampling, density). The thresholds are this app's working values.

### rug_on_request
- **When:** The analyst asks to see how each measure is distributed alongside the scatter.
- **Say:** Set `rug` to true. Leave it out otherwise.
- **Label:** Margins shown as a rug
- **Source:** SURV752, Correlation, Enhancing Scatterplots: Rugs; the class discussion in module 4 notes that readers outside statistics may not read a rug, so it is off by default.

### bubble_sparingly
- **When:** A third measure matters to the question and the scatter has few points (about 30 or fewer after the filter).
- **Say:** Use a bubble with the third measure in `size`. Size is read roughly, so keep the two measures the question is about on x and y.
- **Never:** Do not use a bubble for a file with hundreds of rows; filter first or use a scatter.
- **Label:** A third measure as size
- **Source:** SURV752, Correlation (module 4), Bubbles (the radius scales linearly but the area quadratically); Graphical Perception (size is perceived only roughly).

### heatmap_two_groups
- **When:** A count or a measure is compared across two groupings at once, and bars would need too many colours or panels.
- **Say:** Use a heatmap: one group on x, the other on y, and the measure in `color` with its `fn`, or no `color` for the count. Give `midpoint` only when the values have a meaningful centre (zero for a change, a stated target).
- **Label:** Two groupings as a heatmap
- **Source:** SURV752, Correlation (module 4), Heatmap; colour intensity is perceived only roughly (Graphical Perception), so R prints the cell values when there are few cells.

### log_scale
- **When:** A measure on a scatter or bubble is positive and DATA shows its largest value more than about 100 times its smallest, with most values near the bottom.
- **Say:** Set the log scale for that axis and say so in `say`.
- **Never:** Do not use a log scale on a measure that has zero or negative values, or on the value axis of a bar.
- **Label:** Log scale for a wide range
- **Source:** General practice; not from the course materials.
