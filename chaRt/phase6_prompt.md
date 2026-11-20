# chaRt, Phase 6: facts fixes, then the chat-first screen

Kevin has used the app and ruled: it should feel like Shiny Assistant. One chat on the left, the
dashboard being built on the right, a few buttons where typing is slower. The engine (renderer,
spec checks, reflexes, facts, number check) stays; the screens are rebuilt around it.

## Read first

`CLAUDE.md`; `chaRt/STATUS.md`; `chaRt/DESIGN.md` section 18;
`chaRt/www/reflexes/README.md`, `chat.md` (new), `summary.md` (0.2), `suggest.md` (0.4) and
`refine.md` (0.3); `chaRt/R/reflexes.R`, `R/spec.R`, `R/ui.R`, `app.R`.

## How the work is done

Read `chaRt/manager/README.md` first. You are the lead: hand each part (A, B, C, the tests and
live run of D) to one worker subagent at a time, on a Sonnet model if you can choose the model,
and post a checkpoint to the manager at the end of each part and wherever that file requires one.
Wait for the answer before the next part. Add `manager/*` and `!manager/README.md` to
`chaRt/.gitignore`, and `manager` and every `phase*_prompt.md` to `chaRt/.rscignore`.

## Rules

As before: branch `chart`, small commits, no push, nothing outside `chaRt/`, tests from
PowerShell, Sonnet only, every reply through `llm_json()`, no reply ever run as code, the reflex
files are not yours to edit, every function and argument confirmed in the installed package
(bslib and shinychat above all). Run `git status` before any checkout, stash or restore. No new
packages beyond `bsicons` if it is installed (the screen must work without it). No new files in
`R/`. No em-dashes in prose.

**Looking at the screen.** If a preview configuration named `chart` already exists on this
machine, you may start it and look at the screens in the browser pane. Do not create or edit a
configuration, and do not type a key into the app. With no key, the screens up to the first model
call can still be seen; say in the report exactly what you saw and what you did not.

## Part A. Facts and checks (from the Phase 5 review)

1. **Histogram bin.** The bin with the most rows is reported with the edges ggplot2 draws, which
   can lie outside the data ("34.8 to 45.2" when the maximum is 40). Clip the reported edges to
   the data's minimum and maximum.
2. **Heatmap rows and columns.** "Column with the highest mean: Goalkeeper (28.7)" is the mean of
   four cells, not of the goalkeepers. Compute each row's and column's value from the rows of the
   data with the spec's own function (the mean age of all goalkeepers; the count or total for
   `count` and `sum`), and word it so: "All rows in Goalkeeper: mean 28.9".
3. **Counts the model reaches for.** Add to the facts of every family "Groups shown: n" where
   there are groups, and "Rows after the filter: n" (rows used plus rows left out), so "8
   regions" and "1,851 players" are facts.
4. **Nothing to compare.** When every plotted value is the same, give "Every value shown: v" and
   leave out Lowest and "Highest as a multiple of the lowest".
5. **Change as a multiple.** For `line` and `slope`, add to each series "end is m times start"
   (two significant digits) when both are positive.
6. **One correlation unless they disagree.** Give the Pearson correlation; add the Spearman only
   when the two differ by more than 0.1, with the line "The two differ, so the relationship is
   not a straight line."
7. **`check_numbers()`: "one" is not a number.** It is nearly always a pronoun. Two to twelve
   are still checked.
8. **`check_words()`: multiples.** "doubled", "tripled", "quadrupled", "twice", "halved" and
   "half" are allowed only when that chart's facts hold a multiple that supports the word (at
   least 2, 3, 4, 2; at most 0.5, 0.5). Otherwise the sentence is "'doubled' is a comparison the
   chart's facts do not state."
9. Update the tests that these change, add one check for each item, and show they can fail. Then
   rerun the ten-chart live step once and print each headline and summary with its check result.
10. **Probe: video.** Kevin's office skills make MP4 files of charts being drawn, and chaRt will
    make its own from R in a later phase. In `probe/app.R`, add `av`, `gganimate` and `gifski` to
    `PROBE_PACKAGES`, report whether an `ffmpeg` program is on the path, and, only when `av` is
    installed, encode ten small PNG frames drawn in the probe into an MP4 in `tempdir()` and
    report yes or no, seconds and file size (confirm `av`'s encoding function and its arguments
    in the installed package; if `av` is not installed here, write the check and say it could not
    be run). Also report the Quarto version, and whether a three-line `format: dashboard`
    document renders.

## Part B. One call for every message: `chat_turn()`

`CALL_FILES$chat` is core, comparison, relationship, distribution, time, suggest, refine, chat.
`suggest.md` and `refine.md` no longer have an Output format; the reply format is `chat.md`'s.
The `suggest` and `refine` calls go away, and `suggest_charts()` and `refine_chart()` are folded
into:

`chat_turn(message, canvas, selected, cb, data, last = NULL, ask = llm_json, palette, m)`

The user message, in this order: the DATA block (index, and detail for up to
`CODEBOOK_MAX_DETAIL` columns; a pick call first only above that, as now); `CANVAS` with one line
per chart (id, title, family, the columns it uses), or "empty"; `SELECTED` with that chart's id,
its spec as JSON and its notes, or "none"; `LAST EXCHANGE` (one turn back); `ANALYST:` and the
message; `REPLY FORMAT` and `chat.md`'s Output format. `data_safe()` covers the new markers.

The reply has exactly one of `charts`, `spec`, `ask`, `cannot`, `tell`, and may have `next`:

- `charts`: each checked as before (`spec_check()`, `spec_table()`, unknown `rule` removed), one
  repair call for the failed ones, then listed as not drawn with their sentences. A `cannot`
  list may come with it. Charts from a message that asked for suggestions with no question are
  exploratory: the "Suggest charts" button sends the fixed message `(suggest charts for this
  file)`, and only that message marks them.
- `spec`: valid only when a chart is selected; otherwise it is a failed reply with the sentence
  "No chart is selected, so there is nothing to change. Click a chart first." Checked and
  repaired as before; on success the selected chart's spec is replaced and the old one pushed
  onto its history.
- `ask`, `cannot`: text; nothing changes.
- `tell`: text, checked with `check_numbers()` against the DATA block that was sent; a number
  that is not in it gets one repair, then the text is shown with the warning line under it.
- `next`: up to three strings of at most six words; anything else in it is dropped silently.
- More than one of the five, or none: a failed reply, one plain sentence, no retry.

Every call is recorded as before. The system prompt is identical on every turn.

## Part C. The screen

`bslib::page_navbar()` with the classification banner above it and the logo, title, Source code
link and dark-mode switch in the bar. Four pages: **Start here** (what the tool does, the key box,
the connection check: as now), **Data** (the present Data and Codebook tabs, one under the other,
unchanged in what they do; rename the codebook download to `data_dictionary.yaml`, and say "data
dictionary" in the page's text), **Explore**, **Methodology** (placeholder as now). Remove the old
Explore tab, its wide view and its Phase 4 and 5 screens; keep nothing that is not used.

### Explore

Two columns that fill the window (`layout_columns()` or `layout_sidebar()`, whichever holds up
when the window is narrow): the chat on the left at about 38% of the width, the canvas on the
right. Before the data dictionary is ready (`codebook_ready()`), the chat still works for setup
(below) and the canvas says what is missing.

**The chat (shinychat).**

- Setup messages are written by R, with no model call:
  - when a file is read: "Read <file>: n rows, m columns." then the problems, each as a line;
  - for each column that is mostly numbers with a few words, a button "Treat '<value>' as
    missing", which reads the file again with it;
  - a button "Label the columns" (one `label` call); afterwards a line with how many labels were
    proposed and how many say "check this", and a link to the Data page;
  - the row guess as a button "A row is <guess>", and a line saying it can be edited on the Data
    page;
  - once ready: "Ask a question about your data, or press Suggest charts."
- The analyst's messages go to `chat_turn()`. What is appended: for `charts`, each chart's `say`
  as one short list and "Added to the canvas."; for `spec`, `say` and any new notes; for the
  others, the text; for a failure, its sentences.
- `next` and the setup buttons are shown as clickable suggestions if the installed shinychat has
  them (confirm how); otherwise as a row of small buttons under the chat. A click sends the text
  as the analyst's message.
- Always present under the input: "Suggest charts" and "Write headlines".

**The canvas.**

- A row of three plain value boxes, from the data and with no model call: rows, columns, and the
  period when there is a column with the time role (its first and last value), else the file
  name. (Key numbers chosen by the analyst come with the export phase.)
- One `bslib::card(full_screen = TRUE)` per chart, two to a row, newest first. The header shows
  the headline when there is one and the title under it, else the title. The body: the static
  chart at `spec_size()` and `SPEC_DPI`, the lint notes in small grey text, the summary when
  there is one, the rule's Label, and "Exploratory" when it is.
- Clicking a card selects it: an accent border, and the chat's placeholder becomes "Change
  <title>, or ask something new". Clicking it again, or "Deselect", clears the selection.
- Buttons in each card's header, icons with a text label for screen readers (use bsicons when it
  is installed, short words otherwise): Undo (disabled with no history), Interactive (swaps in
  `spec_widget()`), Code (a dialog with `spec_code()` and a copy button), Edit text (a dialog
  with the five wording boxes and, when written, the headline and summary boxes, each with the
  one-line check from `check_numbers()` and `check_words()`; no model call), Headline (writes or
  rewrites this chart's headline and summary; one call), Remove.
- "Write headlines" under the chat calls `summarize_charts()` once for every chart on the canvas
  that has none or has changed. A chart whose spec changed after its text was written shows "The
  chart has changed since this was written." beside the text until it is rewritten.
- Above the cards on the right: "Style", which opens the three palette selects (no model call),
  and a count of charts. No export button yet.
- A foot line: calls this session, fresh and cached tokens.

The canvas is the dashboard: there is no separate report list.

## Part D. Test data and tests

`tests/data/orders.csv` is a synthetic file written in the Claude project (3,000 orders, 22
columns; `-99` and `N/A` mean missing; one row is one order). It may be committed.

### `tests/smoke.R` (no model calls)

Keep every check that still applies; replace those for the removed screens and calls; say in the
report which were removed and why. Add:

- `chat_turn()` with stand-in replies, one check for each kind of reply and each failure named in
  Part B, including: `spec` with nothing selected; `charts` leaving the selected chart untouched;
  `tell` with a number not in DATA; `next` with a seven-word entry dropped; the suggestion message
  marking charts exploratory and an ordinary question not.
- The chat user message for the messy file: no `SECRET_VALUE_123`; CANVAS lists ids, titles and
  columns and no values; one exchange back; the analyst's message outside every block.
- The system prompt is the same on two turns and for a turn with and without a selected chart.
- The Explore server with `shiny::testServer()` and a stand-in: the setup buttons do what they say
  with no model call except "Label the columns"; a question adds cards; selecting then changing
  replaces that card's chart; Undo, Remove, Edit text; "Write headlines" sends only what needs it;
  a changed chart is marked.

### `tests/llm_check.R` (live, Sonnet, one run), step 8, on `tests/data/orders.csv`

Read it with `-99` and `N/A` as missing; `label_columns()`; `row_is` "one order". Then these turns
through `chat_turn()`, selecting as stated:

1. (nothing selected) "How has revenue changed by region?"
2. select the first chart; "highlight West"
3. (still selected) "only 2024"
4. (still selected) "which products sell the most units?" It should add a chart, not change this
   one.
5. deselect; "make it a bar chart". It should ask which chart.
6. (nothing selected) "how many orders were returned?" It should answer with a chart.
7. "what is in this file?" It should `tell`.
8. "do cheaper items sell in larger quantities?"
9. select that chart; "colour by channel"
10. `(suggest charts for this file)`
11. "is satisfaction lower when shipping takes longer?"
12. select it; "make it a pie chart"

Then `summarize_charts()` for every chart on the canvas. Print per turn: seconds, fresh and cached
tokens, the kind of reply, repairs, the text, `next`, and the specs as YAML; then each headline and
summary with its check result; then totals. Write `tests/live_gallery.html` with a "Phase 6"
section showing the canvas as it ended.

## Order of work

Commit after each: the reflex files, checksums and `tests/data/orders.csv`; Part A; Part B with
its tests; Part C with its tests; the live run.

## Report back (write it to `manager/done-6.md`)

1. Files changed, with line counts, and the checks removed with the reason for each.
2. The new checks' output and the total.
3. Part A's rerun: the ten headlines and summaries with their check results.
4. The live run's output, complete.
5. Which turns went to the wrong kind of reply, if any, with the reply.
6. What the installed bslib and shinychat gave you for: the two-column layout, full-screen cards,
   value boxes, clickable suggestions, and a card that can be clicked to select. Name the
   functions and arguments, and say what could not be done as written.
7. What you saw in the browser, screen by screen, or that no preview configuration existed.
8. Everything you could not confirm, and every departure from this prompt and why.
