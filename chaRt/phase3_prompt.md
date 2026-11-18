# chaRt, Phase 3: the first model calls (labels and suggestions) and the Explore tab

The renderer is closed. This phase connects a model to it: one call that proposes column labels,
one that turns a question into chart specs, and the Explore tab that shows the charts.

## Read first

`CLAUDE.md`; `chaRt/DESIGN.md` sections 4, 7, 16 and 17; `chaRt/STATUS.md`;
`chaRt/www/reflexes/README.md` and every file beside it; `QuestionR/R/reflexes.R` (the parser and
the prompt assembly you will copy from); `chaRt/R/llm.R`, `R/spec.R`, `R/data.R`, `R/ui.R`.

## Rules

- Branch `chart`, small commits, no push, nothing outside `chaRt/`, no file outside the
  repository. Tests from PowerShell.
- R style as before. Confirm every function and argument in the installed package.
- **The reflex files in `chaRt/www/reflexes/` are written in the Claude project. Do not edit
  them.** If one cannot be parsed, or a rule in one cannot work with the renderer, stop and
  report it; do not reword it.
- Every model reply goes through `llm_json()`. Do not use `chat_structured()`.
- Live calls use Sonnet models only, from `tests/llm_check.R` and from the app when Kevin types a
  key. Never an Opus model in a test. The app still never reads a key from the environment.
- No model reply is ever evaluated as code. A reply is JSON that R reads and checks.
- New files allowed: `R/reflexes.R`, `tests/live_gallery.R`. New packages: `digest` (prompt
  hash), `jsonlite` if not already used. No others.
- No em-dashes in prose.

## A. Two things left from Phase 2d

1. The legend keys of a jittered scatter are as faint as its points. Draw legend keys solid.
2. `CODEBOOK_MAX_DETAIL` becomes 40. Detail lines are short, so a typical file fits in one call.

## B. `R/reflexes.R`

Copy the parser from `QuestionR/R/reflexes.R` and cut it to the format in
`chaRt/www/reflexes/README.md`: Title, Version, Persona, Reflexes (When, Say, Never, Label,
Source), Prohibitions, Output format. No Guidelines, Check, Applies or Instrument checks. Keep its
strictness: a line that is not part of the format stops the app, naming the file and the reflex.
Source and Label lines and HTML comments are never sent to a model.

- `CALL_FILES`: `label = "codebook.md"`; `suggest = c("core.md", "comparison.md",
  "relationship.md", "distribution.md", "time.md", "suggest.md")`.
- `assemble_system(call)`: the persona of the call's first file, then each file's reflexes as
  QuestionR's `reflex_line()` writes them, then every prohibition. For `suggest`, then
  `SPEC REFERENCE` and the text from `spec_reference()` (section C). The system prompt of a call
  is the same for every file and question, so it can be cached.
- `data_block(cb, columns)`: the DATA block. One line with the file name, the number of rows and
  `row_is`; then `codebook_index(cb)`; then `codebook_detail(cb, columns)`. It is wrapped in
  `<DATA>` and `</DATA>` lines. It takes the codebook only, never the data.
- `assemble_user(call, cb, columns, question)`: the DATA block; for `suggest` the line
  `QUESTION:` and the analyst's text, or `QUESTION: (none; suggest charts)`; then
  `REPLY FORMAT` and the Output format of the call's last file.
- `prompt_hash(system, user)`: sha256, as QuestionR does.
- `reflex_labels()`: reflex id to Label, for the app's own text.
- `check_reflex_files()` at start-up, as QuestionR does, and the smoke test holds each file's
  checksum.

## C. `spec_reference()` in `R/spec.R`

The text that tells a model what a spec may contain: every field with its allowed values, and
for each family which fields it takes and what kind of column each needs. Build it from the same
constants and tables `spec_check()` uses, so the two cannot disagree; do not write it by hand.
Plain text, compact, no R syntax. It says that any field not listed is refused. A smoke check
confirms every family and every field `spec_check()` accepts appears in it, and nothing else.

## D. The two calls

Both take the function that asks the model as an argument (`ask = llm_json`), so the smoke test
can pass a stand-in that returns canned replies.

### `label_columns(cb, ask)`

- Sends `label` with detail for every column, in batches of `CODEBOOK_MAX_DETAIL` when there are
  more (one call per batch, one after another).
- Reads `labels` and `row_is_guess`. A name that is not a column, or a column missing from the
  reply, is ignored or left as it is; neither is an error.
- Applies a label only to a column whose `label_source` is still `file`. It becomes `ai_guess`,
  and the entry keeps `sure` (true or false). A label the analyst wrote is never touched.
- `row_is_guess` is returned for the app to offer; `row_is` itself is never set by a model.

### `suggest_charts(cb, data, question, ask, palette)`

1. Columns in play: every column whose role is not `ignore`. When there are more than
   `CODEBOOK_MAX_DETAIL`, first one `pick` call: the index only, the question, and the reply
   `{"columns": [...]}` of at most that many names; names that are not columns are dropped. Put
   the pick call's short instruction and reply format in `R/reflexes.R` as constants, since it
   has no reflex file.
2. One `suggest` call. Read `charts` and `cannot`.
3. For each chart: `spec_check()`, then `spec_table()`. A `rule` that is not a reflex id is
   removed, not refused.
4. If any chart failed, one repair call, once: the same system prompt; the user message is the
   original one, then `YOUR REPLY` with the reply, then `PROBLEMS` with each failed chart's
   number and its sentences, then "Send the whole reply again with those charts corrected or
   removed." Check the new reply the same way. No second repair.
5. Return, for every chart that passed: the spec, its table, its lint notes; and separately the
   `cannot` sentences and, for charts that still failed, their sentences. Nothing is guessed or
   patched by R.
6. Record for each call: which call, the prompt hash, the characters sent, the tokens in and out
   if ellmer reports them (confirm how), the seconds, and whether a repair was needed.

A chart from a request with no question is marked `exploratory = TRUE`.

## E. The app

### Codebook tab

- A button "Suggest labels" (needs the key; says so when there is none). While it runs, the
  button is disabled and a line says the model is reading the column summaries, not the rows.
- A label that is an AI guess shows a small "AI guess" tag beside it, and "check this" when
  `sure` is false. Editing it, or ticking "Accept" beside it, makes it the analyst's. One button
  "Accept all AI labels on this page".
- The count above the list becomes: labels still the column name, AI guesses not yet accepted.
- When `row_is` is blank and a guess came back, the box shows it as a placeholder with a button
  "Use this".

### Explore tab

Before a codebook is ready (`codebook_ready()`), one line saying what is missing.

- **Top:** a text box "What do you want to see?" with a button "Draw", and a second button
  "Suggest charts for this file". Under them, three small selects for the report's palettes
  (qualitative, sequential, diverging) from `chart_palettes()`, defaults from
  `chart_palette_default()`. Changing one redraws the charts; it makes no model call.
- **While a call runs:** the buttons are disabled and one line says what is happening.
- **Results:** the `cannot` sentences in a plain box; then one card per chart, two to a row:
  the static chart at `spec_size()`; under it the lint notes; `say`; the Label of its `rule`;
  "Exploratory" when it is; and three controls: "Add to report" (kept in the shared state as an
  ordered list of specs; the Report tab is a later phase, so show only a count on the tab),
  "Interactive view" (swaps the static chart for `spec_widget()` in that card), and "Show code"
  (the text of `spec_code()`).
- Charts that failed after the repair are listed at the bottom under "Could not be drawn", each
  with its sentences.
- A new question replaces the cards; charts already added to the report stay in the report.
- A small line at the foot of the tab: calls made this session and tokens used, from the record
  in D6.

## F. Tests

### `tests/smoke.R` (no model calls; keep all 120)

- Every reflex file parses; a file with a stray line, a missing Version or an unknown field stops
  with a message naming the file and the reflex; checksums match.
- The system prompt of each call is identical on two builds, contains no Source or Label text
  and no HTML comment, and for `suggest` ends with the spec reference.
- `spec_reference()` covers exactly what `spec_check()` accepts.
- The DATA block for the messy file contains no `SECRET_VALUE_123`, and the user message for
  that file with a question that contains "ignore your instructions" keeps the question outside
  the DATA block.
- `label_columns()` with stand-in replies: labels land as `ai_guess` with `sure`; an analyst's
  label is untouched; an unknown name and a missing column do no harm; a reply that is not JSON
  gives one plain sentence and changes nothing.
- `suggest_charts()` with stand-in replies: a good reply gives charts; a reply with one bad chart
  triggers exactly one repair and the corrected chart is kept; a reply still bad after the repair
  lists the chart under failed and keeps the good ones; an unknown `rule` is removed; more than
  40 columns triggers one pick call first; no question marks charts exploratory.
- No file in `R/` contains `eval(parse(` applied to model output; state how you checked.

### `tests/llm_check.R` and `tests/live_gallery.R` (live, Sonnet, run from PowerShell)

Keep the existing checks. Add a run that, for each of FH (missing `..`, `row_is` "one country"),
football (`row_is` "one player") and the panel file (`row_is` "one region in one year"):

1. calls `label_columns()` and prints each column's name, label and `sure`;
2. calls `suggest_charts()` for these, on the codebook as labelled:
   - FH: "Which countries had the highest political rights scores in 2014?"; "How do political
     rights and civil liberties go together in 2014?"; "How have political rights changed since
     2003?"; and no question.
   - football: "Are goalkeepers taller than other players?"; "Which nationalities are most
     common?"; "How does height relate to weight, and does it differ by foot?"; and no question.
   - panel: "How has revenue changed in each region?"; "Which regions grew most between 2015 and
     2024?"; "Do regions that sell more units charge less?"; and no question.
3. prints, per call: seconds, characters sent, tokens in and out, charts returned, charts valid
   first time, charts valid after repair, the `cannot` sentences, and the failed charts'
   sentences; and at the end the totals.

`tests/live_gallery.R` writes `tests/live_gallery.html` (git-ignored) from that run: per
question, the question, `cannot`, and each chart with its notes, `say`, rule label and spec as
YAML. Save the raw replies beside it as `tests/live_replies.rds` (git-ignored) so the page can be
rebuilt without new calls.

About 15 labelling and suggestion calls in all. Run it once; if a fault in the code makes you run
it again, say how many calls were made in total.

## Order of work

Commit after each: A; B with its tests; C; D with the stand-in tests; E; F's live run.

## Report back

1. Files changed, with line counts.
2. The smoke test's new checks and the total.
3. The full system prompt of the `suggest` call, as sent (it is the same every time), and its
   length in characters.
4. The live run's printed output, complete.
5. For FH: the labels the model proposed, with `sure`.
6. Anything in a reflex file that the model plainly did not follow, with the reply that shows it.
7. Everything you could not confirm, and every departure from this prompt and why.
