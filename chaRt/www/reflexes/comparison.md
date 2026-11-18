# Comparison

Version: 0.1

Comparing amounts between groups: bar, dot, slope, small multiples.

## Reflexes

### bar_or_dot
- **When:** An amount is compared across groups.
- **Say:** Use a bar when the amounts are counts, shares or totals, where the distance from zero is the message. Use a dot when the groups' values are close together and far from zero (DATA shows the quartiles close relative to the level), or when there are many groups.
- **Never:** Do not use a bar for values that cannot meaningfully start at zero.
- **Label:** Bars for amounts from zero
- **Source:** SURV752, Graphical Perception, Trade-Offs and Comparative Advantages (the same data as bars from 0, bars from 0.4, and a dot plot); Tufte 1983, graphical integrity 1 (SURV727).

### sorting
- **When:** A bar, dot or box has an unordered group on x.
- **Say:** Leave `sort` out: R sorts by value. Set `level_order` when the groups have their own order (an ordered column, age bands, years). Set `alphabetical` only when the analyst will look names up and is not comparing.
- **Label:** Sorted to show the pattern
- **Source:** SURV752, Comparisons, "How to sort": alphabetical order helps look-up but does not reveal patterns; sort by value or by the structure in the data.

### two_points_slope
- **When:** The question compares the same groups at exactly two points (before and after, first and last year, two conditions).
- **Say:** Use a slope: the two points on x through a filter, the groups in `color`. Slopes show change and change of rank, and do not need a zero base.
- **Never:** Do not use a slope for more than two points; that is a line.
- **Label:** Two points in time as a slope
- **Source:** SURV752, Comparison, Comparison, Comparison (comparing before and after: slope graph) and Comparisons (slope against line charts).

### small_multiples
- **When:** More than 5 groups would share one chart as lines, or as bars side by side.
- **Say:** Use `facet` on the group, one panel each, when the reader should see each group's own shape. Keep one chart with a highlight when the reader should compare groups at the same points.
- **Label:** Many groups as small multiples
- **Source:** SURV752, Comparisons, "Some ideas regarding when to use small multiples" (more than 5 groups; normal line charts are better for comparing lines at specific points); Tufte 2001, p. 168, on small multiples.

### common_scales
- **When:** A spec uses `facet`.
- **Say:** Leave `free_y` out, so every panel has the same scale and panels can be compared. Set it only when the question is about the shape within each panel and the levels differ so much that the small ones would be flat, and say so in `say`.
- **Label:** Panels share one scale
- **Source:** SURV752, Comparison, Comparison, Comparison, "Some Graphical Principles for Comparisons" (common graph size, common scales, helpful alignment); Comparisons, "Different scales?".

### grouped_bars
- **When:** A bar is split by a second group through `color`.
- **Say:** Do it only when the second group has at most 4 values. With more, use `facet`, or a heatmap of the two groups.
- **Label:** Few bars per group
- **Source:** This app's working limit; SURV752, Comparisons ("How much is too much?").

### lines_need_order
- **When:** Tempted to connect groups with a line.
- **Say:** Use a line only when x is time or an ordered column. For unordered groups use bar or dot.
- **Never:** Do not connect unordered categories: a connecting line makes readers see a sequence that is not there.
- **Label:** Lines only along an order
- **Source:** SURV752, Graphical Perception: the Gestalt principle of connection (connected objects are perceived as a group), and the bar chart against line chart trade-off.

### against_a_standard
- **When:** The question compares groups with a target, a benchmark or an average that is a number, not a column.
- **Say:** If the standard is one of the groups (a national row, a named competitor), highlight it. Otherwise say in `cannot` that a reference line is not available yet.
- **Label:** Compared with a standard
- **Source:** SURV752, Comparison, Comparison, Comparison (comparing to a standard: bullet graph). Bullet graphs are not offered in this version.
