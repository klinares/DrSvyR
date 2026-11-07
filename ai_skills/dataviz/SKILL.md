---
name: dataviz
description: Making figures for survey and social-science data with ggplot2 -- chart choice grounded in graphical perception, high data-ink ratio, colourblind-safe palettes, and honest displays of survey estimates with design-based intervals. Use before writing any plotting code.
when_to_use: Any chart, figure, plot or visual table in R or Quarto; reviewing or redesigning an existing figure; plotting survey estimates, weighted versus unweighted comparisons, or confidence intervals.
---

# Data visualisation

Grounded in graphical-perception research (Cleveland & McGill; Heer &
Bostock), Tufte's data-ink principle and Few's design rules, as taught in
JPSM SURV752. Longer notes: `references/principles.md` (perception and chart
choice) and `references/survey_displays.md` (estimates, intervals, weights).
Helpers: `scripts/theme_intern.R` (theme, Okabe-Ito scales, an estimate plot)
and `scripts/palette_check.R` (is this palette colourblind-safe?).

## Always

1. **ggplot2 only.** Never base `plot()`, `hist()`, `barplot()`, `pie()`.
2. **Colourblind-safe colour.** Categorical: Okabe-Ito
   (`scale_colour_okabe_ito()` from the helper script, or
   `ggokabeito` if installed). Ordered or continuous: viridis
   (`scale_fill_viridis_c()`, `scale_colour_viridis_d()`; options "viridis",
   "cividis", "magma"). Never rainbow, `heat.colors()`, or red-green pairs.
   Colour is never the only cue that carries meaning: add labels, shape or
   position as well.
3. **Maximise the data-ink ratio.** Remove anything that can be erased
   without losing information: background fills, heavy gridlines, borders,
   3-D, shadows, redundant legends. Keep a light grid only along the axis
   people read values from. `theme_intern()` does this.
4. **The title states the finding**, not the variable names ("Trust in
   courts is lower among younger adults", not "Trust by age"). Subtitle: the
   population, the measure and the units. Caption: the source, the survey
   year, n, and how intervals were computed.
5. **Label directly** where possible (end-of-line labels, labels on bars)
   instead of a legend the eye must travel to.

## Choosing the chart

People judge **position on a common scale** most accurately, then length,
then angle, area, colour intensity and hue, in that order. So:

| Question | Use | Avoid |
|---|---|---|
| Compare values across categories | dot plot or bar chart, sorted by value, horizontal if labels are long | pie, donut, 3-D bars |
| Estimates with uncertainty | point and interval (`geom_pointrange()`), sorted | bars with error whiskers ("dynamite plots") |
| Change between two time points | slope chart | two pies, side-by-side bars |
| Trends over time | line chart; small multiples when lines overlap | more than about five lines on one panel |
| Distribution of one variable | histogram (choose the bin width), density, or box plot by group | a single mean bar |
| Relationship of two variables | scatter plot; with many points use transparency, smaller points, `geom_hex()` or 2-D density, and marginal rugs or box plots | an unreadable blob |
| Parts of a whole | stacked bar for few parts; a 100% stacked bar for Likert items, diverging around the midpoint | pie with many slices |
| Compare to a standard or target | bullet graph, or a reference line | an unmarked target |
| Many groups at once | small multiples (`facet_wrap()`) with shared scales | one crowded panel |

Bars encode by length, so **bar axes start at zero**. Dot plots and lines may
start elsewhere when zero is not meaningful, but say so.

Ask Tufte's question for every figure: **compared to what?** Show the
comparison the reader needs (a previous wave, another group, the national
figure, a target) on the same scale.

## Survey estimates

- Plot **design-based estimates** (from a `survey`/`srvyr` design), with their
  **95% confidence intervals**. Say in the caption how the intervals were
  computed (e.g. "Taylor linearisation", "jackknife replicate weights").
- Never plot unweighted sample shares as if they were population estimates.
  When weighted and unweighted values are shown together (to show what the
  weights do), mark which is which in the legend and title.
- Don't judge a difference by whether two intervals overlap. If a difference
  matters, estimate and test the difference itself and report that.
- Show the denominator: the population and the n behind each estimate.
  Flag or suppress estimates from small cells (e.g. unweighted n below 30, or
  a relative standard error above 30%) rather than plotting them as precise.
- Likert batteries: diverging stacked bars, the neutral category centred, the
  same item order throughout, and "don't know" shown separately, not hidden.

## Quarto

- One figure per chunk, labelled `#| label: fig-...` with `#| fig-cap:` and
  `#| fig-alt:` (alt text that states the finding).
- Fix the size (`#| fig-width`, `#| fig-height`) so text is readable, and use
  the same theme for every figure in a report.

## Before you hand it over

Check: Is the finding in the title? Is every non-data element needed? Is the
colour colourblind-safe and redundant with another cue? Do bars start at
zero? Are survey intervals design-based, and is that said in the caption?
