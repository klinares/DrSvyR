# Phase 13: every title states the finding

Kevin's ruling: a chart's title is always analytic, never descriptive. "Revenue by region" is a description. "West has the highest total revenue, 940,000" is a title.

The safety rule does not change: the call that chooses a chart has not seen the plotted values, so it still may not write a finding. The finding comes from FACTS, which R computes from the plotted table.

Do Phase 12c first if it is not done. Conventions as before: native pipe, no for/while/repeat, no new files in `R/`, commits only under `chaRt/`, no push, tests from PowerShell, look before you say done. At most 10 live calls, Sonnet only, for Part C's look.

## Part A: R writes a headline for every chart, with no model call

1. One function writes a headline from a chart's FACTS the moment the chart is drawn. Every family, every form the app can draw (small multiples, index, share, top n, two periods).
2. It is one sentence of at most 12 words, and may carry one number. It uses only what FACTS states, writes each name exactly as FACTS writes it, and follows summary.md's rules: about the file, no cause, no "significant".
3. What it says, by what the chart is for:
   - a comparison of groups: the highest group and its value;
   - a change over time: the direction from the first point to the latest, with one of the two values, or for several series the one that ends highest;
   - two points per group (slope, dumbbell): the group that changed most and by how much, if FACTS gives the change;
   - a relationship: the direction and the correlation FACTS states;
   - a distribution: the median, and which way the tail runs if FACTS says;
   - groups of distributions (box, violin): the highest and the lowest median;
   - a heatmap: the highest cell.
4. When there is nothing to contrast, it says so with the value. The manager's thresholds, each a named constant, each stated in the report so Kevin can change it: groups are "similar" when the highest is less than 1.1 times the lowest; a relationship is "no clear relation" when the correlation is between -0.2 and 0.2. These are the manager's choices, not a standard.
5. If a family's FACTS lacks what item 3 needs, add it to `spec_facts()` and list what was added.
6. Run `check_numbers()` and `check_words()` on every headline R writes, as on a model's. One that fails is a bug: the test fails, and the app falls back to the sentence "What is plotted: " plus the description rather than show an unchecked claim.
7. Report the headline R writes for each of the gold specs, in a table, so the manager can read all of them.

## Part B: the headline is the title, everywhere

1. The top line of a chart is its headline: on the card, in the picture (PNG and SVG), on every frame, in the interactive chart, in the exported page, in the export dialog's list, and in `charts.R`.
2. The spec's `title` (the description) is shown as the line under it. The spec's `subtitle` (filter, period, unit) follows on the same line or the next, whichever the label-box checks pass.
3. Nowhere a reader sees is the description the top line. The CANVAS block the model reads still names charts by description, since that is how the analyst refers to them; say in the chat reply both the headline and the description when naming a chart.
4. The design call gets the headline as `txt$title` and the description as `txt$subtitle`.
5. Longer titles: the label-box checks must pass with a 12-word headline at every card width and at 390 pixels. Wrap, never shrink below the style's title size, never clip.
6. A headline the analyst types replaces R's and is marked as the analyst's own, as now.

## Part C: the model's headline replaces R's when it passes

1. The Headline button and the summary call work as now. A model headline that passes the checks replaces R's. One that fails after its repair leaves R's in place, and the card says which it is showing.
2. "About this dashboard" says, per chart, whether the headline was written by R from the facts, by the model and checked, or by the analyst and not checked.
3. Live look, at most 10 calls: the eight charts of Part F of Phase 11, R's headline beside the model's. Report both columns.

## Part D: the manager's files, text given here, placed verbatim

`www/reflexes/core.md`, reflex `title_describes`, bump the file's version by 0.1:
- **Say:** `title` says what is plotted, in plain words and at most 10: the measure, how it is summarised, the grouping. R shows it as the line under the chart's headline, never as the headline. The subtitle carries the filter, the period or the unit. `say` gives, in one sentence for the analyst, why this form suits the question.
- **Never:** unchanged except its last sentence, which becomes: R writes the headline that states the finding from the drawn chart's table as soon as the chart is drawn.
- **Label:** Description sits under the headline

`www/reflexes/summary.md`, reflex `headline_states_the_point`, bump the version by 0.1:
- **Never:** Do not write a label ("Revenue by region") as a headline; that is the chart's description, which R shows under it.

`www/methodology.md`, a new paragraph at the end of the principles, bump the version to 0.4:

**The title states the finding.** Every chart's title is one sentence that says what the chart shows, written from the numbers R computed and checked against them. What is plotted (the measure, the grouping, the period) is the line under it. A title you write yourself is kept and marked as your own, because chaRt has not checked it.

Commit these in the same commit as the code that reads them. Update the checksums and the rule counts.

## Part E: checks

1. No drawn chart, card, frame, exported page or `charts.R` has the description as its top line (every gold spec, every style).
2. Every R headline passes both checks and is at most 12 words, for every gold spec and for the messy file.
3. The "similar" and "no clear relation" cases, each side of each threshold.
4. A failing R headline falls back as Part A 6 says.
5. The model's headline replaces R's only when it passes; the About block names the writer of each.
6. A mutation for each new check. Both smoke runs pass.
7. Rebuild `tests/dashboard_motion/`, `tests/dashboard_motion_briefing/` and `tests/dashboard_designed/`.

## Report

`manager/done-13.md`: the table of R's headlines, the two-column table of Part C, what was added to FACTS, the thresholds, what was seen and by whom, what was not seen, and the two count lines.
