# chaRt, Phase 5: headlines and summaries, with every number checked

The one call that says what a chart shows. R computes the facts from the plotted table, the model
writes a headline and a short summary from those facts only, and R checks every number it wrote.

## Read first

`CLAUDE.md`; `chaRt/STATUS.md`; `chaRt/DESIGN.md` sections 4, 10 and 17;
`chaRt/www/reflexes/summary.md` (new) and `refine.md` (version 0.2);
`svysegment/R/ai_reflexes.R` and wherever svysegment checks the numbers in a model's text (read
how it does it; copy the idea, not the survey parts); `chaRt/R/reflexes.R`, `R/spec.R`, `R/ui.R`.

## Rules

As in Phase 4: branch `chart`, small commits, no push, nothing outside `chaRt/`, tests from
PowerShell, Sonnet only, every reply through `llm_json()`, no reply ever run as code, the reflex
files are not yours to edit, every function and argument confirmed in the installed package. Run
`git status` before any checkout, stash or restore. No new files, no new packages. No em-dashes in
prose.

## A. A curve that cannot be fitted says so

On the attack and defence chart coloured by position, loess fails for the goalkeepers (8 distinct
values of x) and ggplot2 drops that curve with warnings. For any group whose x has fewer than
`SPEC_FIT_MIN_DISTINCT` (10) distinct values, or whose fit fails, draw no curve for that group and
add the note "No curve for <group>: too few different values of <x label>." (or "No curve: ..."
when there are no groups). No warning reaches the console or the page. The generated code leaves
that group's curve out too.

## B. `spec_facts(spec, table, cb)` in `R/spec.R`

The facts a summary may use: plain text, one fact per line, each number written once in the form
R wants it quoted. It is computed from `spec_table()` and the spec, never by a model. Rounding:
3 significant digits for measures, whole numbers for counts, one decimal for percentages, two for
correlations; thousands separators as the chart's axis shows them. The same value always prints
the same way.

Every family: what is plotted in words (measure label, function, grouping, filter, facet); `rows
used` and, when any, `rows left out for missing values`; whether the chart is exploratory.

| Family | Facts |
|---|---|
| `bar`, `dot` | Each plotted value with its group (all of them; there are at most 30); highest and lowest with their groups; how many tie at the highest; the highest as a multiple of the lowest when both are positive; for `count` and `sum`, the total and each of the top three as a percentage of it; with `color`, the same within each x group |
| `line` | For each series, or for the highlighted ones and the 3 largest and 3 smallest by change when there are more than 8: first and last value with their times, the change, the percentage change when the first is positive, the highest and lowest with their times; which series rose most and fell most |
| `slope` | For each line: start, end, change, percentage change, rank at start and at end; largest rise, largest fall, how many rose and how many fell |
| `scatter`, `bubble` | Rows; the range of x and of y; Pearson and Spearman correlations; with `color` or `facet`, the Pearson correlation within each group of at least 10 rows; with a fit, the fitted y at the 10th, 30th, 50th, 70th and 90th percentiles of x; for each highlighted point its x and y; for `bubble`, the range of size. Never the points themselves |
| `histogram` | Rows; minimum, quartiles, maximum, mean; the bin with the most rows, its range and its count |
| `box` | For each group: rows, median, quartiles, minimum, maximum; highest and lowest median with their groups |
| `heatmap` | Each cell's value when there are at most `SPEC_HEAT_LABELS` cells, else the 5 highest and 5 lowest with their row and column; the highest and lowest row and column by their mean or total |

With `facet` on other families, the same facts within each panel, up to `SPEC_FACET_MAX` panels.

**Names are not sent.** A value of an `id` or `text` column is written in the facts as a token,
`[[N1]]`, `[[N2]]`, in order of first appearance. `spec_facts()` returns the text and the map from
token to name. Values of `category`, `ordered` and `flag` columns are written as they are.

## C. The number check, in `R/reflexes.R`

`check_numbers(text, facts, spec)` returns the numbers in `text` that are not allowed.

- A number is allowed when it is in `facts` as written, or is a number in `facts` rounded to fewer
  digits (at least two significant), or is a value in the spec's own `filter` or `top_n`, or
  is a year that appears in the facts.
- Compare values, not strings: "1,200", "1200" and "1.2 thousand" are the same number; "12%" and
  "12 percent" are 12. A number written as a word from one to twelve is checked as that number.
- Ordinals, and digits inside a `[[N1]]` token, are not numbers.

Also `check_words(text)`: the words `summary.md` forbids (cause, causes, caused, leads to, drives,
due to, because of, effect, impact, significant, significantly, representative), matched as whole
words, any case. Keep the list as a constant beside the function.

## D. `summarize_charts(charts, cb, data, ask, palette, m)`

- The system prompt is `summary.md` alone (its own persona, reflexes, prohibitions). It is the same
  for every call.
- The user message: `<CHARTS>`, then for each chart its id, its title, and its facts, then
  `</CHARTS>`, then `REPLY FORMAT` and `summary.md`'s Output format. Names in a title that are
  values of an `id` or `text` column are tokens there too. `data_safe()` covers this block's own
  markers as it does `<DATA>`.
- Up to `SUMMARY_BATCH` (8) charts in one call; more go in further calls, one after another.
- For each chart in the reply: `check_numbers()` and `check_words()` on the headline and on the
  summary, and every token is one of that chart's. If anything fails, one repair call for the
  failed charts only: the same message for those charts, then `YOUR REPLY`, then `PROBLEMS` naming,
  per chart, the numbers that are not in its FACTS, the words that are not allowed, and the tokens
  that are not known. Check again. No second repair.
- Then put the names back for the tokens.
- Returned per chart: headline, summary, `checked` (TRUE, or FALSE with the remaining problems),
  and the hash of the spec they were written for.
- A chart whose reply is missing is returned with a plain sentence and no text.
- Each call is recorded with fresh and cached tokens.

## E. The app

In the wide view, under the chart, a box "Headline and summary":

- Before any is written: a button "Write headline and summary" (one call for this chart).
- Once written: the headline and the summary in two text boxes the analyst can edit, and under
  them one line: "Every number matches the chart's data." or, in a warning colour, what does not
  ("58 is not a number in this chart's data"; "'drives' suggests a cause").
- The analyst's edits are checked the same way as they type or on leaving the box, with no model
  call. A failed check warns; it never blocks. The analyst decides.
- When the chart's spec has changed since the text was written, the box says "The chart has
  changed since this was written." with a button "Write again". The old text stays until then.
- The wording box for the title is checked by `check_numbers()` and `check_words()` too, with the
  same one-line warning, since an analyst may type a finding as a title.
- On the cards, a chart with a headline shows it above the title.

Above the cards, when at least one chart is in the report: a button "Write headlines and summaries
for the report (n charts)", which calls `summarize_charts()` once for every report chart that has
none or whose spec has changed.

## F. Tests

### `tests/smoke.R` (no model calls; keep all 184)

- A: the goalkeepers' group gets no curve and the note; no warning is raised; the code agrees.
- `spec_facts()` for one gold spec of each family: every number in it can be recomputed from
  `spec_table()` by the test; the same call twice gives the same text; a chart with a name-like x
  has tokens and no names; for the messy file `SECRET_VALUE_123` is nowhere in the facts.
- `check_numbers()`: a fact as written passes; rounded to fewer digits passes; rounded wrongly
  fails; a difference of two facts fails; "1,200" against "1200" passes; "12%" against "12
  percent" passes; "three" is checked as 3; a filter year passes; "1st" and "[[N2]]" are ignored.
- `check_words()`: each forbidden word is caught as a whole word; "effective" and "causeway" are
  not.
- `summarize_charts()` with stand-in replies: a clean reply is `checked`; a reply with an invented
  number triggers exactly one repair, for that chart only; still wrong comes back `checked` FALSE
  with the number named; an unknown token is a problem; tokens come back as names; 9 charts make
  two calls; a missing chart gives its sentence; the summary's system prompt is identical on two
  builds and holds no Source or Label text.
- The Explore server with `shiny::testServer()`: writing fills the boxes; editing a number to one
  not in the facts shows the warning and makes no call; changing the spec marks the text as out of
  date; the report button sends only the charts that need it.

### `tests/llm_check.R` (live, Sonnet, one run), step 7

Charts from hand-written specs, so no other call is needed:

- FH (missing `..`): the bar of the highest `pr_2014` (ties); the scatter of `pr_2014` against
  `cl_2014` with a loess fit and Norway and Cuba highlighted; the histogram of `pr_2014`.
- football: the box of `Height` by `Position`; the bar of the 15 most common `Nationality`; the
  heatmap of mean `Age` by `League` and `Position`; the scatter of `Attack` against `Defence`
  coloured by `Position`.
- panel: the slope of revenue 2015 against 2024 by region; the faceted line of revenue by year;
  the bar of total revenue by region, marked exploratory.

Ten charts, so two calls. Print for each call: seconds, fresh and cached tokens in, tokens out,
repairs. For each chart: its facts, the headline, the summary, and the result of the checks.
Totals at the end. Add them to `tests/live_gallery.html` under "Phase 5": each chart with its
headline above it, its summary under it, then its facts.

## Order of work

Commit after each: the reflex files and checksums; A; B with its tests; C with its tests; D with
its tests; E with its tests; the live run.

## Report back

1. Files changed, with line counts.
2. The new checks' output and the total.
3. How svysegment's number check works, in three sentences, and what you took from it.
4. The live run's output, complete: facts, headline, summary and check result for all ten charts.
5. Any headline or summary that passed the checks but says something the facts do not support,
   as you read them. Read all ten against their facts and say so either way.
6. Everything you could not confirm, and every departure from this prompt and why.
