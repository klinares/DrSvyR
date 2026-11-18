# chaRt, Phase 4: the chat that refines a chart

An analyst opens one chart, types what to change, and the chart's spec is revised. Wording is
edited directly, with no model call.

## Read first

`CLAUDE.md`; `chaRt/STATUS.md`; `chaRt/DESIGN.md` sections 7 and 17;
`chaRt/www/reflexes/README.md`, `refine.md` (new) and `suggest.md` (version 0.3);
`chaRt/R/reflexes.R`, `R/spec.R`, `R/ui.R`.

## Rules

As in Phase 3b: branch `chart`, small commits, no push, nothing outside `chaRt/`, tests from
PowerShell, Sonnet only, every reply through `llm_json()`, no reply ever run as code, the reflex
files are not yours to edit, every function and argument confirmed in the installed package
(shinychat above all). Run `git status` before any checkout, stash or restore, and stop if a file
you did not change shows as modified. No new files. No em-dashes in prose.

## A. Three things seen in the 3b charts

1. **The fitted curve is trimmed within each group.** In the panel-per-position scatter the
   Defender curve runs through an empty stretch, because the percentiles are taken over all the
   rows. Take the 1st and 99th percentiles of x within each colour or facet group that has at
   least `SPEC_FIT_TRIM_N` rows, for loess and for linear.
2. **A slope's colours.** The renderer still notes "8 colours are hard to tell apart" on a slope.
   For a slope the note is given only above the palette's own limit.
3. **Grouped bars read in the legend's order.** In a sideways grouped bar the bars within a group
   run bottom to top while the legend runs left to right, so the first legend entry is the
   bottom bar. Make the first legend entry the top bar.

## B. One system prompt for both chart calls

`refine.md` joins the chart files, so `CALL_FILES$suggest` and `CALL_FILES$refine` are the same
seven files and `assemble_system()` gives the identical text for both: a chat turn then reads the
system prompt from the cache a suggest call wrote. The reply format is no longer "the last
file's": each call's user message ends with `REPLY FORMAT` and the Output format of its own file
(`suggest.md` or `refine.md`). Update the checksums.

## C. `refine_chart()` in `R/reflexes.R`

`refine_chart(chart, message, cb, data, last = NULL, ask = llm_json, palette, m)`

The user message, in this order:

- the DATA block: the head line, the whole index, and detail only for the columns the current
  spec uses;
- `CURRENT SPEC` and the spec as JSON, as the model or the analyst last left it (without the
  renderer's own dot-fields);
- `NOTES` and the lint notes R gave for it, or "none";
- when there was a turn before this one on the same chart, `LAST EXCHANGE` with the analyst's
  previous message and the reply's `say`, `ask` or `cannot`. One turn back only, never the
  transcript;
- `ANALYST:` and the message;
- `REPLY FORMAT` and `refine.md`'s Output format.

The reply has exactly one of `spec`, `ask`, `cannot`:

- `spec`: checked as in `suggest_charts()` (`spec_check()`, `spec_table()`, an unknown `rule`
  removed). If it fails, one repair call with the sentences, once. If it still fails, the chart
  is unchanged and the sentences are returned for the chat.
- `ask` or `cannot`: returned as text; the chart is unchanged.
- More than one of the three, or none: treated as a reply that failed, with one plain sentence.

When a column the new spec uses was not in the detail sent, that is fine: R checks it against
the codebook as always. Each call is recorded as in Phase 3, with fresh and cached tokens.

## D. The Explore tab

Each chart gets an id when it is drawn. The report list holds ids, so a chart refined after it
was added to the report is the refined one.

- **A fourth control on each card, "Refine".** It opens that chart in a wide view in place of
  the cards: the chart large on the left with its notes and rule label; on the right, in this
  order, "Back to all charts", the wording boxes, and the chat.
- **Wording, with no model call.** Five text inputs filled from the spec: title, subtitle,
  caption, x-axis title, y-axis title. A blank box means R's default. Changes apply when the
  analyst leaves the box or presses "Apply wording".
- **The chat** (shinychat; confirm the input's event name and how to append one complete
  message). The analyst's message goes to `refine_chart()`. While it runs, the input is disabled
  if the installed shinychat allows it; otherwise further messages are ignored until it returns,
  with a line saying so. The reply appended to the chat is: for a new spec, `say`, then any lint
  notes that are new; for `ask` or `cannot`, its text; for a failure, the sentences. The chat's
  greeting says in two lines what to ask for (form, grouping, filter, highlight, top n) and
  that colours are set by the palette boxes and wording by the boxes above.
- **Undo and Reset.** Every accepted change (by chat or by the wording boxes) pushes the previous
  spec onto that chart's own history. "Undo" steps back one; "Reset" returns to the spec the
  chart was first drawn with. Neither makes a model call.
- Each chart keeps its own chat messages, history and last exchange for the session; opening
  another chart shows that chart's.
- "Interactive view", "Show code" and "Add to report" also appear in the wide view.

## E. Tests

### `tests/smoke.R` (no model calls; keep all 166)

- A1, A2, A3, each on a spec made to trigger it.
- The system prompts of `suggest` and `refine` are identical; each user message ends with its
  own file's reply format.
- The refine user message for the messy file holds no `SECRET_VALUE_123`, gives detail only for
  the spec's columns, carries one exchange back and not two, and keeps the analyst's message
  outside the DATA block.
- `refine_chart()` with stand-in replies: a good spec replaces the chart and pushes history; a
  bad spec triggers exactly one repair; still bad leaves the chart unchanged and returns the
  sentences; `ask` and `cannot` leave it unchanged; a reply with both `spec` and `cannot`, and a
  reply with none, are failures; a reply that is not JSON gives one sentence.
- The Explore server with `shiny::testServer()` and a stand-in: wording boxes change the spec
  with no call recorded; Undo and Reset restore the earlier and the first spec; a chart refined
  after "Add to report" is the refined one in the report list; two charts keep separate
  histories.

### `tests/llm_check.R` (live, Sonnet, one run)

Step 6, on charts drawn from hand-written specs so no suggest call is needed, each message a
turn on the chart as the previous turn left it:

- **Football, bar of the count by Position:** "make it a dot plot"; "only the Bundesliga and
  LaLiga"; "split it by league instead of filtering"; "make it a pie chart"; "use red and blue".
- **Panel, line of revenue by year coloured by region:** "highlight Islands and Coast"; "just
  show 2015 against 2024"; "sort the regions alphabetically"; "title it Islands pulled ahead";
  "undo that".
- **FH (missing `..`), scatter of pr_2014 against cl_2014:** "label Norway and Cuba"; "add a
  straight line instead of the curve"; "show it over time"; "group them".

Print for each turn: seconds, fresh and cached input tokens, output tokens, which of spec, ask,
cannot or failure came back, whether a repair was needed, `say` or the text, and the revised
spec as YAML. Totals at the end. Write the charts after each accepted turn into
`tests/live_gallery.html` under a "Phase 4" heading.

## Order of work

Commit after each: the reflex files and checksums; A; B; C with its tests; D with its tests; the
live run.

## Report back

1. Files changed, with line counts.
2. The new checks' output and the total.
3. The live run's output, complete.
4. For the shinychat functions you used: their names and arguments as installed, and anything in
   section D the installed version could not do.
5. Any turn where the reply went against `refine.md`, with the reply.
6. Everything you could not confirm, and every departure from this prompt and why.
