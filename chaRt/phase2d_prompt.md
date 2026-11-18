# chaRt, Phase 2d: last renderer fixes before the model (no model calls)

The rebuilt gallery (25 charts and the palette section) was reviewed chart by chart in the
Claude project. Five small changes, then the renderer is closed.

## Read first

`CLAUDE.md`, `chaRt/STATUS.md`, `chaRt/R/spec.R`, `chaRt/R/theme.R`, `chaRt/R/data.R`.

## Rules

As in Phase 2b and 2c: branch `chart`, small commits, no push, nothing outside `chaRt/`, no model
calls, tests from PowerShell, thresholds as named constants, every function and argument
confirmed in the installed package, no new packages, no new files. No em-dashes in prose.

## 1. Repeated positions on a scatter: spread the points, do not size them

Phase 2b, item 8, was the wrong call. In the height and weight chart `geom_count` gives large
overlapping blobs, and the right-footed players bury the left-footed ones under every palette.

When more than `SPEC_OVERLAP_SHARE` of the rows share their x and y with another row:

- draw every row as its own point, moved at random by at most `SPEC_JITTER` (0.4) of the
  smallest gap between distinct values on each axis (confirm `ggplot2::resolution()` and
  `position_jitter()` with its `seed` argument), with a fixed seed so the chart is the same
  every time;
- make the points transparent, as the row-count rule does;
- note: "Points are moved slightly so that rows sharing a position can be seen."

The generated code uses the same jitter and seed. `spec_table()` is unchanged: the rows as they
are. No size legend. This applies with and without `color`. Remove `geom_count` from the
renderer.

## 2. A bubble chart with many bubbles

The forwards chart has several hundred overlapping bubbles in four colours and cannot be read.
With more than `SPEC_BUBBLE_N` (60) bubbles, add the note "A bubble chart with this many points
is hard to read; filter, or use a scatter." Nothing is changed in the chart.

## 3. Palettes

- Remove batlow and vik from `CHART_PALETTES`: they need the scico package, which is one more
  package to ask for on the work server, and the list has enough without them.
- In the printed colour table, add the diverging palettes: for each, whether lightness is
  highest or lowest at the middle colour and moves in one direction along each arm.

## 4. The file's encoding is the analyst's to correct

`read_data()` reads any Latin-family guess as windows-1252. That is right for a Western European
file and wrong for a Central European one, and R cannot tell which.

- `read_data(path, name, missing = character(), encoding = NULL)`: `NULL` means guess, as now.
- **Data tab:** beside "Values that mean missing", a select "File encoding" with "Detected
  (<what was used>)", UTF-8, windows-1252, ISO-8859-2 and ISO-8859-15. "Read again" uses it.
- The codebook keeps the encoding that was used, and an uploaded codebook's encoding is used
  when its file is read, as `missing_codes` is.

## 5. Tests and gallery

Keep all 115. Add: the jitter rule draws one point per row, is the same on a second call, and
its code reproduces the table; `geom_count` appears nowhere in `R/`; the bubble note; batlow and
vik are gone; a file written in ISO-8859-2 with "Łódź" reads wrongly by the guess and rightly
with `encoding = "ISO-8859-2"`, and the codebook carries it. Show the new checks can fail.
Rebuild `tests/gallery.html`.

## Report back

1. Files changed, with line counts.
2. The new checks' output and the total.
3. The colour table's new diverging rows.
4. Everything you could not confirm, and every departure from this prompt and why.
