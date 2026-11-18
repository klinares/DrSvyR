# Time

Version: 0.1

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
