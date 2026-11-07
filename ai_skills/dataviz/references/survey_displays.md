# Displaying survey estimates

## Estimates with intervals

Compute estimates from the design, then plot points and intervals.

```r
library(dplyr)
library(srvyr)
library(ggplot2)
intern_source_skill("dataviz", "theme_intern.R")   # or source the script

data(api, package = "survey")
des <- apistrat |>
  as_survey_design(strata = stype, weights = pw, fpc = fpc)

est <- des |>
  group_by(stype) |>
  summarise(api00 = survey_mean(api00, vartype = "ci"), n = unweighted(n()))

plot_estimates(est, x = api00, y = stype, lower = api00_low, upper = api00_upp,
               title = "High schools score lowest on the 2000 API",
               subtitle = "Mean API score by school type, California schools, 2000",
               caption = "Source: survey::apistrat (stratified sample). 95% CIs, Taylor linearisation.")
```

Points and horizontal intervals, sorted by the estimate, read more accurately
than bars with whiskers.

## Proportions

`survey_prop()` or `survey_mean()` on a 0/1 variable, with
`proportion = TRUE` for intervals that stay inside 0-1 when estimates are
near the edges. Show percentages on the axis
(`scale_x_continuous(labels = scales::label_percent())`).

## Comparing groups

- To say two groups differ, estimate the difference and its interval
  (`svyby()` then `svycontrast()`, or a design-based regression) and show
  that; overlapping intervals are not a test.
- Show at most the differences the reader needs. Order categories
  meaningfully (by estimate, or by the natural order of an ordinal variable).

## Weighted versus unweighted

To show what the weights do (useful in methods sections and in nonresponse
work), plot both on the same axis with clearly different marks:

- Okabe-Ito colours plus different shapes (colour is not the only cue).
- Legend entries "Weighted estimate (population)" and "Unweighted sample
  share (respondents)".
- The title says what the comparison shows, e.g. "Weighting raises the
  estimated share of young adults".

Never show only the unweighted figure as the survey's estimate.

## Small cells and precision

- Report the unweighted n behind each estimate (in a label, a table, or the
  caption).
- Flag or suppress estimates whose unweighted n is small (for example below
  30) or whose relative standard error is large (for example above 30%).
  Grey them out or drop them, and say so in the caption.
- Never plot a cell that would disclose a small group in a public report;
  follow the project's suppression rule.

## Likert items

- Diverging stacked bars centred on the neutral category; agree to the right,
  disagree to the left, in an ordered palette (viridis "cividis", or two
  Okabe-Ito hues for the two sides).
- The same item order across figures; sort by the share agreeing.
- "Don't know" and "Refused" shown as a separate bar or noted, not silently
  dropped.

## Captions

A caption names the source, the survey and year, the population, the n, that
estimates are weighted, and how intervals were computed (Taylor
linearisation, jackknife, bootstrap, BRR).
