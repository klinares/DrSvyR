# Editorial

Version: 0.1

## Intent

A chart for a general reader in a magazine or a briefing: one clear point, read in five seconds,
then rewarding a second look. Confident, quiet, generous with space.

## Composition

- The plot is the hero. Title block at top left, aligned with the left edge of the plot area, not
  centred. Title in the display face from `tok`, large and bold; subtitle one size down in the
  muted colour; caption small, at bottom left.
- Generous margins: at least a title's height of space between the title block and the plot.
- No panel border, no axis line unless it is the zero line of a bar chart. Grid lines only along
  the value axis, hairline, in `tok$grid`; none when the marks are labelled.
- Axis text small and muted. Drop an axis title when the subtitle or the tick labels already say
  what the axis is.
- Prefer a horizontal layout for ranked categories, with the names left-aligned and readable.

## Colour

- One accent (`tok$accent`) for what the chart is about; `tok$slate` for context; `tok$muted`
  for text that supports. Use `pal(n)` only when the series are a real set of equals, and then at
  most five.
- Never colour for variety. If nothing is emphasised by the spec's `highlight`, a single series
  is drawn in the accent and multiple series in the palette.

## Labels and annotation

- Name lines at their right ends in the line's own colour; no legend.
- On a ranked bar or dot chart, write each value at the end of its mark and remove the value axis.
- At most two annotations, each a short phrase from `facts` set beside the point it describes,
  with a thin leader only if it cannot sit next to it.
- Numbers use thousands separators and the fewest digits that are honest.

## Motion

- `draw` for lines (through time), `rise` for bars and histograms, `wipe` for dense charts and
  heatmaps, `fade` otherwise. Labels and annotations arrive last.

## Checklist for the review

1. Can the point of the chart be seen in five seconds?
2. Is any text clipped, overlapping, or smaller than the axis text?
3. Is there a legend, grid line, tick or border the chart would be clearer without?
4. Does anything in colour not deserve it?
5. Do bars start at zero, and are compared panels on one scale?
6. Is every number on the chart one from the facts?

## Never

- Centred titles, boxed legends, gradient fills, drop shadows, rotated axis labels at 45 degrees,
  rainbow palettes, more than two annotations.
