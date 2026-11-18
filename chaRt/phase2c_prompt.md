# chaRt, Phase 2c: colour palettes from paletteer (no model calls)

Run after Phase 2b is committed.

Kevin's rulings: palettes come from the paletteer package; analysts choose from a short curated
list of colourblind-safe palettes, not from everything paletteer holds; the palette is chosen
once for a report, so every chart in it matches; the model never chooses colours, so the spec
gets no palette field.

## Read first

`CLAUDE.md`, `chaRt/STATUS.md`, `chaRt/R/theme.R`, and how `chaRt/R/spec.R` uses the palette.

## Rules

As in Phase 2b. One new package: `paletteer`. No new files. Before writing anything, confirm in
the installed paletteer: the functions that return a discrete and a continuous palette, their
arguments, the tables that list palette names, and whether a palette can be drawn when the
package it came from is not installed. Report what you find. No em-dashes in prose.

## 1. `R/theme.R`: the list of palettes

`CHART_PALETTES`: a named list, one entry per palette, each with:

- `label`: what the analyst sees.
- `kind`: `qualitative`, `sequential` or `diverging`.
- one of `paletteer` (the palette's name as paletteer takes it) or `colours` (a vector of hex
  colours, so the office palette can be added at work without paletteer).
- for a qualitative palette, `max`: how many groups it can show.

Two entries need no package and are the defaults: Okabe-Ito (qualitative, with yellow last, as
Phase 2b left it) and viridis (sequential). If paletteer is not installed, the app still starts
and offers only the entries that have `colours` or are built in.

Candidates for the rest. Use each only if its name is in the installed paletteer's tables; list
in the report any that are not, and do not substitute a look-alike:

| Kind | Candidates |
|---|---|
| Qualitative | Paul Tol's bright, muted and vibrant (from khroma) |
| Sequential | magma, cividis and mako (viridis family); batlow (scico); ColorBrewer Blues and YlGnBu |
| Diverging | vik (scico); ColorBrewer RdBu, PuOr and BrBG; Tol's sunset (khroma) |

These were chosen from memory as palettes designed or flagged for colour-vision deficiency. That
is a claim to check, not a fact: see the test in section 4.

Functions, replacing the fixed ones where they exist:

- `chart_palettes(kind)`: the names and labels on offer for a kind, defaults first.
- `chart_palette(n, name)`: n colours of a qualitative palette; an error past its `max`.
- `chart_sequential(name)` and `chart_diverging(name)`: the colours for a continuous scale.
- `chart_palette_default()`: `list(qualitative = , sequential = , diverging = )`, the three
  names a report starts with. At work Kevin changes this one function.

`CHART_HIGHLIGHT` and `CHART_GREY` stay as they are.

## 2. `R/spec.R`

- `spec_plot()`, `spec_widget()` and `spec_code()` take `palette = chart_palette_default()`.
- The generated code keeps writing the hex colours in directly, so it runs without paletteer.
- The hard limit on colours is the chosen qualitative palette's `max`. The lint's note at more
  than `SPEC_COLOURS` (7) stays, since it is about what a reader can tell apart, not about what
  the palette holds.
- One new spec field, `heatmap` only: `midpoint`, a number. When it is given, the fill uses the
  diverging palette centred on it; otherwise the sequential palette, as now. `spec_check()`
  refuses it on other families.

## 3. `app.R` and the probe

Add `paletteer` to `PROBE_PACKAGES` in `probe/app.R`. Do not add it to `APP_PACKAGES`, since the
app must start without it. The dropdowns that let the analyst choose arrive with the Explore
tab; nothing changes in the tabs now.

## 4. Tests

Keep every existing check. Add:

- Every entry of `CHART_PALETTES` returns valid hex colours, and a qualitative one returns
  exactly `max` distinct colours at its limit.
- With paletteer made unavailable (stub the check that looks for it), `chart_palettes()` offers
  only the built-in and `colours` entries, and the gold specs still draw.
- A heatmap with `midpoint` uses the diverging colours and is centred on the midpoint; `midpoint`
  on a bar is refused.
- The generated code for a chart drawn with a non-default palette contains that palette's hex
  colours and reproduces the table.
- A table, printed and not judged: if the colorspace package is installed, for each qualitative
  palette at its `max`, the smallest distance between any two of its colours in CIELAB, as seen
  normally and under simulated deuteranopia, protanopia and tritanopia; for each sequential
  palette, whether lightness changes in one direction from end to end. If colorspace is not
  installed, say so and skip it. Do not install it.

Add a section at the end of `tests/gallery.html`: three charts (the football scatter by foot,
the 8-region line chart, the price heatmap, and the price heatmap again with a midpoint) drawn
under every palette of the matching kind, each titled with the palette's label.

## Report back

1. What the installed paletteer provides (functions, arguments, name tables, whether source
   packages are needed), and which candidates were not found.
2. Files changed, with line counts.
3. The smoke test's new checks and the total.
4. The colour-distance table, or that it was skipped.
5. Everything you could not confirm, and every departure from this prompt and why.
