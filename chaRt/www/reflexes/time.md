# Time

Version: 0.3

A measure over time: line, slope.

## Reflexes

### line_for_time
- **When:** A measure is followed over three or more points in time.
- **Say:** Use a line with the time column on x. With one row per time point (and per group), `fn` is none; otherwise choose the function by what a row is.
- **Never:** Do not sort or rank the time axis by value.
- **Label:** Change over time as a line
- **Source:** SURV752, Graphical Perception: a line chart connects 2-D positions to give shape to a series of values.

### many_series
- **When:** A line chart would carry more than 5 series.
- **Say:** If the question is about a few of them, highlight those and leave the rest grey. If it is about every one, use `facet` on the series column.
- **Label:** Many series untangled
- **Source:** SURV752, Comparisons: small multiple line charts untangle overlapping lines; sparklines as the alternative when many lines overlap or cover very different ranges.

### money_over_time
- **When:** The measure is an amount of money and x is time.
- **Say:** Unless the column's label says the amounts are adjusted for inflation, say in `say` that they are not.
- **Label:** Money over time, as recorded
- **Source:** Tufte 1983, graphical integrity 4 (deflated and standardised units of money in time series), as presented in SURV727.

### index_to_compare_growth
- **When:** The question is which series grew faster, and the series differ a lot in size.
- **Say:** Set `index` to `first`, so every line starts at 100 and its height is growth since the first period. Keep all the series in one panel, with no `facet`, and use `highlight` for the few the question is about.
- **Never:** Do not index when the question is about amounts, and do not describe an indexed value as an amount.
- **Label:** Indexed to compare growth
- **Source:** Design rule of this app; Tufte 1983 on comparing like with like.

### smooth_on_request
- **When:** The analyst asks for a trend, a moving average or a smoother line in a noisy series.
- **Say:** Set `smooth` to a number of periods that covers one cycle (12 for monthly data with a yearly cycle, 4 for quarterly). The raw values stay visible behind it.
- **Never:** Do not smooth on your own, and do not report a smoothed value as if it were a month's value.
- **Label:** Moving average over raw values
- **Source:** Design rule of this app (a smoother must not replace the data it summarises).
