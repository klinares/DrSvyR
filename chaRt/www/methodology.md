# How chaRt chooses and draws a chart

Version: 0.4

chaRt does not let a model draw. The model reads a description of your columns (never the rows),
picks a chart form by the written rules below, and hands R a short specification. R checks it,
computes every number, and draws it. Every number in a headline or summary is checked against the
numbers R computed for that chart. This page says what the rules are and where they come from.

## The principles

**Show the data, and compare.** A chart exists to answer "compared to what?" (Tufte, 2006). Every
chart here is built around one comparison: between groups, over time, between two measures, or
against a distribution. If a question has no comparison in it, a number in a sentence is the
better answer.

**Graphical integrity.** The size of an effect on the page should match its size in the data
(Tufte, 1983). In practice: bars start at zero, because a bar's length is its value; panels that
are meant to be compared share a scale; a time axis is spaced as time is; and a chart says how many
rows are behind it and how many were left out.

**Spend ink on data.** Grid lines, boxes, legends and decoration compete with the data for
attention (Tufte, 1983, on data-ink and chartjunk). chaRt writes values on the marks and names at
the ends of lines where they fit, and then removes the axis numbers or legend they make
redundant.

**Position first.** People read some encodings more accurately than others. Position along a
common scale is read best, then length, then angle and slope, then area, then colour intensity
(Cleveland and McGill, 1984). So the most important comparison is placed on a common axis, and
area (a bubble's size) or colour is used only for a secondary variable. This is why chaRt draws no
pie charts: a pie asks for an angle and area judgement where a dot or bar chart offers position.

**Small multiples.** The same small chart repeated for each group, on the same scales, lets the
eye compare many groups without decoding a crowded legend (Tufte, 1990). chaRt uses panels when
one chart would need more than about seven colours.

**Few colours, and colours everyone can tell apart.** Colour marks group membership or emphasis,
not decoration. Palettes are scored for readers with colour-vision differences, and one group can
be drawn in colour against grey when it is the point of the chart.

**A chart describes the file, not the world.** Headlines and summaries state what these rows show.
They do not claim a cause, and they do not generalise to a population: chaRt knows nothing about
how the rows were collected.

**The title states the finding.** Every chart's title is one sentence that says what the chart shows, written from the numbers R computed and checked against them. What is plotted (the measure, the grouping, the period) is the line under it. A title you write yourself is kept and marked as your own, because chaRt has not checked it.

## Which chart for which question

| The question | The chart | Use it when | Ask something like |
|---|---|---|---|
| How do groups compare on one number? | Bar, or dot | One measure, a handful of groups. Dots when the values are far from zero and the differences are small. | "Which {group} has the highest {measure}?" |
| How has it changed over time? | Line | A time column with many points. One line per group, up to about seven. | "How has {measure} changed over {time}?" |
| What changed between two points in time? | Slope | Exactly two periods, several groups. | "Compare {measure} in the first and last {time} for each {group}." |
| Is one measure related to another? | Scatter | Two measures, one point per row. A fitted curve shows the form. | "Is {measure} related to {measure2}?" |
| The same, with a third measure | Bubble | Sparingly: area is read poorly, so the third measure is background. | "Show {measure} against {measure2}, sized by {measure3}." |
| How is one measure spread out? | Histogram | One measure; you want its shape, centre and tails. | "How is {measure} distributed?" |
| How does a spread differ across groups? | Box | One measure, several groups; medians and ranges side by side. | "How does {measure} vary across {group}?" |
| How do two groupings combine? | Heatmap | Two category columns and one number per cell. | "Show {measure} by {group} and {group2}." |
| One pattern, many groups | Small multiples | Any of the above, when there are too many groups for colour. | "Show {measure} in a panel for each {group}." |
| How much did each group change between two periods or conditions? | Dumbbell | Exactly two periods or conditions and more than a few groups: each group's two dots share one scale, so the gap is read as a length. | "Compare {measure} for each {group} at the two values of {group2}." |
| What shape does a measure take in each group? | Violin | Only when you ask for the shape: a violin with its box inside, for groups of at least 30 rows. | "Show the shape of {measure} in each {group}, as violins." |
| Which series grew fastest? | Indexed line | Series that differ a lot in size: each line is divided by its first value, so every line starts at 100. | "Index {measure} over {time} for each {group}, to compare growth." |
| What is the trend in a noisy series? | Smoothed line | Only when you ask for a trend: a moving average over the raw line, which stays visible in grey. | "Show a 12-period moving average of {measure} over {time}." |
| Is one measure related to another when there are thousands of rows? | Density | A scatter with more than 2,000 points: R counts rows in cells instead of drawing points that pile up. | "Is {measure} related to {measure2}? Show it as counts in cells." |

You can also change a chart you have selected: "only 2024", "highlight West", "sort by value",
"use a log scale", "mark the highest point", "remove the numbers on the bars".

## What chaRt will not do, and why

- **Pie and doughnut charts, 3D, dual axes.** Each hides or distorts the comparison.
- **Cause.** "Because", "led to", "drove" are not written: a chart of a file shows association.
- **Numbers the data do not hold.** A sentence with a number that is not in the chart's computed
  facts is flagged, repaired once, and marked if it still fails.
- **Rows to the model.** The model sees column names, types, labels and summaries. Categories with
  many levels, identifiers and free text are sent as counts only.

## What to check yourself

- **Missing values.** Rows with a missing value in a charted column are left out, and the chart
  says how many. Whether the rows left out differ from those kept is for you to judge.
- **Scores on a scale.** A mean of a 1-to-5 rating treats the steps as equal. That is common and
  it is an assumption.
- **Two end points are not a trend.** Look at the whole line before trusting "rose" or "fell".
- **Weights and design.** chaRt does not apply survey weights or account for a sample design.
  Charts of survey data made here describe the respondents in the file.
- **Confidence intervals.** The summary tables give 95% intervals that assume a simple random
  sample of independent rows: a t interval for a mean and a Wilson interval for a share. With
  clustering, stratification or weights the true intervals are usually wider, and for a complete
  count an interval has no sampling meaning. Charts show no intervals.

## Sources

- Cleveland, W. S., and McGill, R. (1984). Graphical perception: theory, experimentation, and
  application to the development of graphical methods. *Journal of the American Statistical
  Association*, 79(387), 531-554.
- Tufte, E. R. (1983). *The Visual Display of Quantitative Information.* Graphics Press.
- Tufte, E. R. (1990). *Envisioning Information.* Graphics Press.
- Tufte, E. R. (2006). *Beautiful Evidence.* Graphics Press.

The rules are applied as taught in SURV752 (Data Visualization) and SURV727 (Fundamentals of
Computing and Data Display), Joint Program in Survey Methodology. Each rule the model follows is
listed below with its source.
