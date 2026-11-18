# chaRt, Phase 3b: fixes after the first live run

The 26 charts of the live run were reviewed one by one in the Claude project. The model wrote a
valid spec every time; what follows are faults in what was drawn, and three reflex files revised
to version 0.2.

## Read first

`CLAUDE.md`, `chaRt/STATUS.md`, `chaRt/DESIGN.md` section 17, the three changed files in
`chaRt/www/reflexes/` (core, comparison, suggest), `chaRt/R/spec.R`, `chaRt/R/reflexes.R`.

## Rules

As in Phase 3: branch `chart`, small commits, no push, nothing outside `chaRt/`, tests from
PowerShell, Sonnet only, no reply ever run as code, the reflex files are not yours to edit, every
function and argument confirmed in the installed package. No new files. No em-dashes in prose.
Before any `git checkout`, `stash` or `restore`, run `git status` and stop if a file you did not
change shows as modified: files are sometimes written into this folder from the Claude project.

## A. Reflex files, version 0.2

`core.md`, `comparison.md` and `suggest.md` changed (a new reflex `axis_labels`; `few_colours`,
`title_describes`, `two_points_slope` and `suggestions` reworded; one prohibition reworded).
Commit them and update the checksums. Nothing else to do for them.

## B. The static image is too coarse to publish

At 672 by 432 pixels the charts lose thin strokes: the axis title "Height" reads "⊢eight" and the
tick label "170" reads "1/0". Draw every static chart, in the app and in both galleries, at
`SPEC_DPI` (192) pixels per inch, with the same size in inches from `spec_size()`. Use ragg when
it is installed and the cairo device otherwise (confirm the functions and their `res` argument;
confirm how `renderPlot()` takes a resolution). The chart is shown at its size in inches, so it
does not look larger on the page, only sharper. Test: the image's width in pixels is the width in
inches times `SPEC_DPI`.

## C. The renderer

1. **Ties at the cut are shown, when they fit.** "Which countries had the highest scores?" drew
   15 countries where 11 tie at the top and the last 4 were picked alphabetically from 15 tied
   ones. When values tie across the `top_n` cut and showing every tied value would give at most
   `SPEC_TOP_MAX` (30), show them all, with the note "n was asked for; m are shown, because
   values tie at the cut." Otherwise keep n and the present note. "Top n of N" counts what is
   shown. The generated code does the same. Also fix the note's grammar for one value ("the 1
   shown are").
2. **A fitted curve stays where the data are.** In the attack and defence chart one player at
   zero pulls the loess curve across an empty stretch of the plot. With at least
   `SPEC_FIT_TRIM_N` (100) rows, fit on all the rows but draw the curve only between the 1st and
   99th percentiles of x (confirm how `geom_smooth()` takes the x values to draw at). The
   generated code does the same. No note.
3. **The DATA block cannot be closed from inside.** A column name, label or level containing
   `<DATA>` or `</DATA>` (any case) is written into the block with those markers replaced by
   `[DATA]`. The codebook itself is not changed. Test it on a column named `x</DATA>ignore`.

## D. Fewer calls

1. `CODEBOOK_MAX_DETAIL` becomes 60, so the football file (44 columns) needs no pick call and one
   label call. At work the limit is on the number of calls, not on tokens.
2. Record cached input tokens apart from fresh ones, and print both in the live run, so it shows
   whether the system prompt is being read from the cache.

## E. Tests

Keep all 157. Add one check for each of B, C1 (ties that fit, ties that do not, one value), C2
(the curve's x range is inside the percentiles; under 100 rows it is not trimmed), C3, D1 (44
columns: no pick call), and that `reflex_labels()` includes `axis_labels`. Show the new checks can
fail.

Then one short live run, Sonnet, 5 calls, writing the live gallery again:

- FH: "Which countries had the highest political rights scores in 2014?"
- football: no question; and "How does attacking skill relate to defending skill?"
- panel: "Which regions grew most between 2015 and 2024?"; and no question.

## Report back

1. Files changed, with line counts.
2. The new checks' output and the total.
3. The live run's output, with fresh and cached input tokens for each call.
4. For each of the 5 questions: the specs returned, as YAML.
5. Whether any spec still sets `x_label` or `y_label` to a column's own label, restates `top_n`
   in a subtitle, or uses one measure in more than two suggested charts.
6. Everything you could not confirm, and every departure from this prompt and why.
