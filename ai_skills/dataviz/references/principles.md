# Principles behind the dataviz skill

Background for the rules in `SKILL.md`, in our own words, from the
graphical-perception and design literature as taught in JPSM SURV752.

## Perception

Seeing happens in stages. **Pre-attentive** processing picks out some visual
attributes automatically and in a fraction of a second: position, length,
width, size, orientation, shape, curvature, enclosure, hue, intensity, and
spatial grouping. **Working memory** then handles a few chunks at a time, and
**long-term memory** recognises familiar patterns.

Use pre-attentive attributes deliberately, for three jobs:

1. **Encoding data** -- which attribute carries the values.
2. **Directing attention** -- one highlighted series among grey ones.
3. **Building a visual hierarchy** -- what is read first, second, last.

A highlight only pops out when the distractors are uniform. The more kinds of
distractor there are, the less any single attribute stands out.

### Not all attributes carry quantities

| Attribute | Read as a quantity? |
|---|---|
| 2-D position | yes |
| length | yes |
| width, size, colour intensity | only roughly |
| orientation, shape, enclosure, hue | no -- categories only |

Cleveland and McGill's experiments, replicated with crowdsourced participants
by Heer and Bostock (2010), rank the accuracy of judgements: position on a
common scale, then position on unaligned scales, then length, then angle and
slope, then area, then colour intensity and hue. That is why dot plots and bar
charts beat pie charts and bubble charts for comparing values, and why a
second circle "twice as big" is so hard to judge.

### Gestalt grouping

People see groups where elements are close together (proximity), look alike
(similarity), share a boundary (enclosure), line up (continuity), or are
joined by a line (connection), and they complete open shapes (closure). Use
these to group what belongs together -- a legend's order matching the lines,
related bars next to each other -- and avoid accidental groupings.

## Data-ink

Tufte: above all, show the data. The **data-ink ratio** is the share of a
graphic's ink that shows non-redundant data; raise it by erasing non-data ink
and redundant data ink, then revise. Few's version for screens:

- **Reduce non-data pixels**: remove what adds nothing (would the meaning
  suffer if it were gone?), then make what remains -- axes, gridlines, labels
  -- thin and light grey.
- **Enhance data pixels**: drop data that does not serve the point, and
  emphasise the most important data with colour, size or weight.

Data-ink is a direction, not an absolute: a light grid that helps people read
values earns its ink.

## Titles

Readers look at the title first and remember a figure by its title. A title
that states the finding is recalled; a vague one ("Figure 1") is not. Readers
rarely notice when a title and the data disagree, so the title must be
accurate to the data shown.

## Comparisons

"Compared to what?" is the central question. Common comparisons and the forms
that suit them:

- **Before and after**: slope chart -- two axes, one line per series; slope
  and direction show change, and it shows ranks and percentage change without
  needing a zero baseline.
- **To a standard**: bullet graph, or a reference line; make an implicit
  standard explicit.
- **Over time with many series**: sparklines or small multiples, when lines
  would overlap or sit on very different ranges.
- **By subgroup**: small multiples on shared scales.

Visualising uncertainty can mislead: error bars on bar charts invite readers
to treat the bar as the whole story, and overlapping intervals are routinely
misread as "no difference".

## Many points

Overplotting hides structure. In order of preference: smaller points,
transparency (`alpha`), jitter for discrete values, binning (`geom_hex()`,
`geom_bin2d()`) or 2-D density contours, and, with very large data, a random
sample of points (say so). Add marginal rugs or box plots to show each
variable's distribution, and "slice" one variable into bands with small
multiples to see conditional relationships.

## Sources

Ware (2004), *Information Visualization*; Cleveland & McGill (1984); Heer &
Bostock (2010), *Crowdsourcing graphical perception*; Tufte (2001), *The
Visual Display of Quantitative Information*; Few (2009), *Now You See It*;
JPSM SURV752 lectures on graphical perception, comparison and correlation.
