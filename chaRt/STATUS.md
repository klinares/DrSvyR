# chaRt: status

## Phase 7, notes carried while it is built (2026-11-20)

Branch `chart`. Not pushed. The full Phase 7 report goes to `manager/done-7.md` at its end; these are the things a
later reader of this file needs before then.

- **The plotly version shows less than the static chart.** plotly shows semibold as bold (it has no weight between
  regular and bold for a font family), and it drops Magazine's lifted value-axis labels (the static chart sets them
  above their grid line with a theme margin that plotly does not carry). Everything else a style sets (colours, grid,
  fonts, the Newspaper rule, the palette, the Dark swap) is kept; see Part B's report.
- **Diverging means balanced** (a-006). A diverging palette is offered only if its lightness has one extreme at the
  middle colour (or one of the two middle colours when the length is even) and its two end colours are within 20
  lightness units. MetBrewer's diverging sets kept: Benedictus, Cassatt1, Cassatt2, Demuth, Ingres, Isfahan1, Johnson,
  Juarez, Moreau, OKeeffe1, Troy; dropped as diverging: Hiroshige, Hokusai1, Homer1, VanGogh1, Veronese.
- **A colour that cannot be seen is not drawn** (a-006). In any style a palette colour under 10 dE (CIE2000) from the
  style's background is skipped and the palette's usable count for that style drops (`palette_usable()` in
  `R/theme.R`); on Dark the swap of a too-dark colour for the light one comes first, then a swapped colour that repeats
  an earlier one is skipped, then the skip.

## Phase 6b, 2026-11-20: more palettes, a working signal, a clean folder

Branch `chart`. Not pushed. No model call. Kevin approved the proposals at the STOP ("Go, as
proposed"). The palette and working-line work went in under Kevin's own commit aef2456 ("adding
shiny app"), which also holds the two SurvAI_Expert files; then 4d2ae05 (old prompts removed) and
f04add3 (`.rscignore`).

### Files changed and removed (7f8a3de..HEAD, added / removed)

| File | Lines |
|---|---|
| `R/theme.R` | +147 / -25 |
| `R/ui.R` | +111 / -13 |
| `tests/smoke.R` | +138 / -4 |
| `R/spec.R` | +24 / -6 |
| `R/reflexes.R` | +3 / -3 |
| `.rscignore` | +2 / -2 |
| `phase6b_prompt.md` | +126 (Kevin's prompt) |
| Removed: `phase0_prompt.md`, `phase1_prompt.md`, `phase1b_prompt.md`, `phase2_prompt.md`, `phase2b_prompt.md`, `phase2c_prompt.md`, `phase2d_prompt.md`, `phase3_prompt.md`, `phase3b_prompt.md`, `phase4_prompt.md`, `phase5_prompt.md` | -1,512 |

Also removed, untracked: `data/chaRt_test_orders.csv`, a byte-for-byte copy of
`tests/data/orders.csv` that nothing read and that `.rscignore` would have shipped. Left, as the
prompt says: the generated files in `tests/` (already git-ignored), `.Rhistory`, and the mailbox's
`q-*`, `a-*` and `done-6.md`.

### Smoke test

298 of 298 (285 before; 13 new):

```
ok    6b-1: every listed palette (58, of which 55 through paletteer) has its name in the installed paletteer's tables and resolves to valid colours
ok    6b-1: the stored colour-vision result of every palette matches palette_cvd() recomputed now
ok    6b-1: the selects group the palettes by source, the default first, and the mark sits beside exactly the palettes that pass
ok    6b-1: a qualitative palette with fewer colours than a chart needs is not stretched: the chart (8 regions, Moth has 5) is drawn and coded with Okabe-Ito and its notes say so
ok    6b-1: each Style select is a selectize input whose options show a strip of the palette's colours before its name (render option); the strip's colours are the palette's, and the name goes through escape()
ok    6b-1: choosing a palette that fails the colour-vision check shows the one line under Style; the defaults and a passing palette show none; no model call
ok    6b-1: without paletteer the selects offer only the built-in palettes, a chart still draws and the page still builds
ok    6b-2: the working line is in the page under the chat's input: hidden, role="status", aria-live polite, three dots hidden from screen readers, and words
ok    6b-2: the script shows the line from the browser on a chat send, a suggestion or a call button, adds 'still working' after 8 seconds, and hides it on chart-busy and when Shiny is idle or disconnected; the dots stop for reduced motion
ok    6b-2: Suggest charts, Write headlines and a card's Headline carry their words (Thinking, Writing headlines, Writing a headline)
ok    6b-2: the script's own wordsFor(), run in V8: a question and a suggestion give 'Thinking', 'Label the columns' gives 'Labelling columns', a Treat or row button 'Working'
ok    6b-2: the working line adds nothing to the chat's messages: after a turn the chat holds the reply only, LAST EXCHANGE is the question and its reply, and busy was set and cleared
ok    6b-2: shiny's page-level pulse is on as a second signal (useBusyIndicators(spinners = FALSE, pulse = TRUE, fade = FALSE)); no spinner on the cards
```

Two existing checks changed: 4-A2 (an 8-region slope under a 7-colour palette is now drawn with
Okabe-Ito and says so, in place of the "8 colours" note), and the button regexes of 6-C 28 and
6-D 13 (a `data-working` attribute now sits between `class` and `id`). Scratch runs with the work
undone made every new check fail except four that match fixed text in the page and script (the
script check, the button words, nothing appended to the chat, the pulse).

### Palettes now offered

The check: the smallest CIE2000 difference (`farver::compare_colour(method = "cie2000")`) between
any two of a palette's first five colours (five spread along a sequential or diverging one) after
simulating deuteranopia, protanopia and tritanopia (`colorspace::deutan()`, `protan()`, `tritan()`),
the worst of the three. The mark (a tick after the name) is 8 or more (`CHART_CVD_MARK`, approved).
The results are written out in `CHART_PALETTE_CVD`, so the app needs neither colorspace nor
paletteer to show the marks; the smoke test recomputes them.

- Qualitative: Built in: Okabe-Ito (12.1, default). khroma: Paul Tol bright (8.7), muted (17.7),
  vibrant (8.6), medium contrast (12.1). ggthemes: Tableau Classic Color Blind (16.9), Stata
  Economist (13.7), Excel Office Theme (12.2). MetBrewer: Archambault (15.7), Veronese (15.6),
  Johnson (14.6). NatParksPalettes: Kings Canyon (21.7), Death Valley (15.8), Torres (15.3). nord:
  Algoma Forest (9.4), Moose Pond (8.6). PNWColors: Moth (13.2), Bay (11.6). CARTOColors: Safe
  (17.7). wesanderson: Darjeeling 2 (13.9), Isle of Dogs 1 (12.2), Isle of Dogs 2 (8.4). All marked.
- Sequential: viridis: Viridis (13.4, default), Magma (14.2), Cividis (13.0), Mako (13.9).
  ColorBrewer: Blues (9.9), YlGnBu (7.0, not marked). khroma: Paul Tol smooth rainbow (17.0),
  Crameri Oslo (19.4), grayC (18.4). ggthemes: Tableau Classic Blue (11.1), Gray Warm (11.0),
  Classic Gray (10.5). nord: Halifax Harbor (8.3). PNWColors: Lake (13.5), Mushroom (12.6), Winter
  (11.9). CARTOColors: DarkMint (12.9), BrwnYl (12.0), BluYl (11.2).
- Diverging: ColorBrewer: RdBu (22.9, default), PuOr (24.7), BrBG (13.7). khroma: Paul Tol sunset
  (18.7), Crameri Vanimo (27.9), Vik (28.2), Bam (24.1). ggthemes: Tableau Red-Blue-White (25.2),
  Orange-Blue-White (25.1), Classic Orange-White-Blue (23.5). nord: Silver Mine (8.5). PNWColors:
  Shuksan 2 (15.0), Anemone (8.3). CARTOColors: Earth (15.2), ArmyRose (12.5), Geyser (11.4).
  Built in: Blue-red (13.9, the fallback without paletteer).

The selects group by source, with the default's group first; each option and the chosen item show
a strip of the palette's colours before the name (selectize.js's `render` option through
`selectizeInput(options = list(render = I(...)))`). A chosen palette that fails puts one line under
Style: "This palette is hard to tell apart for some readers with colour-vision differences." A
qualitative palette with fewer colours than a chart draws is not stretched: that chart uses the
default palette and its notes say so. The colour count is now the drawn table's (`.n_colours`, set
by the lint), not the codebook's, so a chart filtered to fewer groups keeps the chosen palette.

### Finding: rsconnect does not expand patterns in `.rscignore`

rsconnect 1.11.2's `listDeploymentFiles()` showed `phase6_prompt.md` and `phase6b_prompt.md` in a
deployment although `.rscignore` listed `phase*_prompt.md`. `.rscignore` now names each prompt; a
new prompt file must be added to it by name. With that, a deployment carries `app.R`, `R/` and
`www/reflexes/` only: no tests, prompts, mailbox, probe or documents.

### Seen in the browser (the `chart` preview; no key typed)

- Style dialog (a small file handed to the Data page, "one sale" typed as the row): the legend
  line with the tick; three selectize selects, each chosen palette with its swatch strip and tick;
  the Groups list open, grouped Built in, khroma (Paul Tol, Crameri), ggthemes, MetBrewer,
  NatParksPalettes, nord, PNWColors, CARTOColors, wesanderson, each option with its strip; choosing
  ColorBrewer YlGnBu (no tick) put the warning line under Style on the canvas.
- Working line: recorded with a MutationObserver, not seen by eye. On a chat send and on Suggest
  charts it appeared with "Thinking" and went about 7 to 10 ms later, when the "needs a key" reply
  came back. A long call, the "still working" words after 8 seconds, the reduced-motion dots and
  shiny's pulse were not seen.

### Not confirmed, and departures

- Not confirmed: the working line during a real call of several seconds; that a screen reader
  announces it; the pulse; how shinychat's own pending dots and the working line look together.
- The lightest-colour contrast is not shown in the app: every qualitative palette offered,
  Okabe-Ito included, has a lightest colour under 3 to 1 on white, so a note would stand beside
  every one. It is in the STOP table.
- `khroma::okabeito` is left out (the built-in Okabe-Ito is the same set); Paul Tol muted stays
  under its old name.
- The working line also goes when Shiny reports the server idle or disconnected, so a failed call
  does not leave it showing.
- STATUS.md was not shortened: the prompt asked for the shorter file as a proposal only.
- Kevin's commit aef2456 holds `SurvAI_Expert/build/03_store.R` and
  `SurvAI_Expert/data/catalog/receipt.csv`, which earlier phases kept out of every commit; it has
  not been pushed, and I have not changed it.

## Phase 6, 2026-11-19: facts fixes, one call for every message, the chat-first screen

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5` (step 8 of `tests/llm_check.R`): 16 calls.

### Built

- Part A, the facts. The top histogram bin is clipped to the data's minimum and maximum. A heatmap's
  row and column lines are worked out from the rows of the data with the spec's own function
  ("All rows in Goalkeeper: mean 28.7"; `spec_facts()` takes `data`, and without it leaves those lines
  out, never falling back to the mean of the cells). Every family states "Groups shown" and "Rows after
  the filter". When every plotted value is the same: "Every value shown: v", and no Lowest or multiple.
  A line or slope series gets "end is m times start" when both are positive. One correlation (Pearson);
  the Spearman only when the two differ by more than 0.1, with a line saying the relationship is not a
  straight line. `check_numbers()` no longer reads "one" as a number. `check_words()` allows "doubled",
  "tripled", "quadrupled", "twice", "halved" and "half" only when the chart's facts hold a multiple that
  supports the word. The probe reports av, gganimate, gifski, ffmpeg, an MP4 encoded from ten PNG frames,
  Quarto, and a `format: dashboard` document, plain and with `embed-resources: true`.
- Part B, one call for every message. `chat_turn(message, canvas, selected, cb, data, last, ask, palette,
  m)` in `R/reflexes.R` replaces `suggest_charts()` and `refine_chart()`. The reply has exactly one of
  `charts`, `spec`, `ask`, `cannot`, `tell`, and may have up to three `next` strings of at most six
  words. `CALL_FILES$chat` is core, comparison, relationship, distribution, time, suggest, refine,
  chat; the reply format is `chat.md`'s; the system prompt is identical on every turn. The user message
  is DATA, CANVAS, SELECTED, LAST EXCHANGE, `ANALYST:` and the message, REPLY FORMAT; `data_safe()`
  covers the new markers. The suggestion message `(suggest charts for this file)` alone marks charts
  exploratory. A `spec` with nothing selected is a failed reply with a sentence and no call; a `tell`
  with a number that is not in DATA gets one repair, then the warning.
- Part C, the screen. `app_ui()` in `R/ui.R`: the classification banner above `bslib::page_navbar()`
  with the logo, title, Source code link and dark-mode switch in the bar, and four pages: Start here,
  Data (the file, then the data dictionary; the download is `data_dictionary.yaml`), Explore and
  Methodology. Explore is `bslib::layout_sidebar()` with shinychat in a 38% sidebar and the canvas on
  the right: three value boxes, a card for each chart (full screen, newest first, two to a row) with
  Select, Undo, Interactive, Code, Edit text, Headline and Remove; Style; "Suggest charts" and "Write
  headlines" under the chat; setup written by R in the chat with no model call except "Label the
  columns". The old Explore tab, wide view, report list and Phase 4 and 5 screens are gone;
  `state$report` is `state$canvas`.
- Part D, the checks and the fixes the manager asked for after Part C.
  - What reaches the chat is escaped (see below). `md_text()` is stricter than in Part C, `one_line()`
    puts a `next` entry on one line, `suggestion_list()` escapes the text twice (as attribute and as
    markdown).
  - Setup texts are matched exactly in R and acted on only while their button is on offer: a "Treat"
    text for a value the file does not hold (or already treated) does nothing and says so; so do the
    label text once labelled and a row guess no longer on offer. An analyst's own message that
    merely contains such a text goes to `chat_turn()`.
  - A headline and summary are stored with a data version (a digest of the data when written). The same
    file read again keeps the canvas; if the data changed the charts are drawn again from it, their notes
    are made again, every text is marked "The data has changed since this was written, so its numbers
    may no longer hold." and the chat says how many. The spec-hash rule is unchanged.
  - The footer buttons ("Suggest charts", "Write headlines", and each card's Headline) were drawn very
    faint in dark mode: the theme's outline-primary colour is `#2c3e50` on `#212529`. A style change in
    `EXPLORE_CSS` gives class `chart-call` the page's emphasis colour (black on light, white on dark) for
    text and border, the body colour when disabled, at opacity .65. Wording and behaviour are unchanged.
  - Removed: `chart_reset()` and `new_chart()$first` (no Reset button), the `suggest` and `refine`
    entries of `LLM_MAX_TOKENS`, `tests/llm_check.R` steps 4, 5 and 6, and in `tests/live_gallery.R`
    `live_run()`, `live_refine()`, `LIVE_FILES`, `LIVE_FILES_3B`, `LIVE_REFINE`, `first_counts()`,
    `live_phase4_html()` and `live_chart_html()`. The page keeps Phase 5 and gains Phase 6.
  - `tests/llm_check.R` step 8 and `live_chat()` in `tests/live_gallery.R`: `tests/data/orders.csv` read
    with `-99` and `N/A` as missing, one label call, row is "one order", twelve turns through `chat_turn()`
    with the selecting the plan says, then `summarize_charts()` for every chart on the canvas; calls are
    counted and the run stops at 24 (`LIVE_MAX_CALLS`; the manager allowed 24 for the one run); saved as `phase6`, shown under "Phase 6".
  - `tests/smoke.R`: a section "Phase 6 D" (18 checks, 6-D 1 to 18); 285 checks in all, 285 pass. Single
    mutations of `R/ui.R` (29, in scratch) each make at least one 6-D check fail.

### Finding: shinychat 0.4.0 does not sanitise assistant messages

File: `lib/shiny/shinychat.js` in the installed package (`C:/Users/keval/AppData/Local/R/win-library/4.6/shinychat/`).
An assistant message is drawn through remark, remark-rehype with `allowDangerousHtml` and rehype-raw, and
no sanitiser. Three facts follow:

1. Raw HTML in the text is allowed: a tag becomes a real element, so an `<img onerror=...>` in a file
   value or a model reply would run.
2. `javascript:` links are kept: a markdown link keeps its address (the link handler only adds
   `target` and `rel` to http and https links and does not filter the scheme).
3. Any element with class `suggestion` (or a `data-suggestion` attribute) becomes a clickable card, and with
   class `submit` a click sends its text as the analyst's message. Text from a file or a model could
   therefore put words in the analyst's mouth.

Only the analyst's own messages (role "user") go through rehype-sanitize. Nothing in the R side of
`chat_append_message()` escapes anything.

**The rule that follows: no text from a file or from the model reaches `chat_append_message()` except
through `md_text()`.** `md_text()` backslashes every ASCII punctuation mark (CommonMark's one escape for
all of them) and writes `&`, `<`, `>` as entities, so no emphasis, link, image, code, list, heading, table,
tag or entity can start; it also stops autolinks: the backslash on `:` and `.` stops `http://`, `https://`
and `www.`, and an e-mail address (found in the text after the escapes are undone, so nothing but a break
in the text stops it) has its `@` written as `<span>@</span>`, which the reader sees and copies as a plain
`@`, with no invisible character (checked against commonmark with `extensions = TRUE`, which implements
the GFM autolinks, not against shinychat's own remark). A suggestion's `data-suggestion` value is
`htmltools::htmlEscape(attribute = TRUE)` and its text goes through `md_text()` too; a `next` entry is put on
one line. `say()` in `R/ui.R` is the only place that calls `chat_append_message()` and takes R's own wording
only. `tests/smoke.R` (6-D 18) reads `R/ui.R` as code and fails if there is a second
`chat_append_message()` call, or a `say()` call whose text is not built only from strings, `SETUP_*`
constants, a few named symbols, numbers, `md_text()` or the helpers that call it (`chat_reply_text()`,
`story_line()`), joined by `paste()`, `paste0()`, `c()` and `if`. Later phases keep to this rule.

### The live run

`tests/data/orders.csv`, read with -99 and N/A as missing: one label call, twelve chat turns, then
headlines and summaries for the 11 charts on the canvas. 16 calls of the 24 allowed: 1 label, 12
chat, 3 summarize (2 batches and 1 repair). No chat turn needed a repair, and every turn came back
as the kind the prompt expected: turn 4 added a chart, turn 5 asked which chart, turn 6 answered
with a chart, turn 7 told, turn 12 refused the pie. The one repair was for "half" in a histogram's
summary ("the middle half"), which the facts do not back with a multiple. 11 of 11 texts checked.
Input tokens 38,767 fresh and 80,282 from the cache (the 6,924-token system prompt after the first
turn); 13,192 out; 116 s in calls.

### Departures

- bsicons is not installed: card buttons carry words, not icons.
- A different file clears the canvas, the selection, the texts and the last exchange; the same file read
  again keeps them.
- "Changed since this was written" compares the spec's hash, so Undo back to the spec a text was written
  for clears the mark; a data change does not clear.
- "Label the columns" is matched exactly (it was matched ignoring case) and is on offer only while its
  button is: after the label step, or when the dictionary was ready from the start, the text says so and
  makes no call.
- Phase 3 and Phase 4 sections are no longer on the live page (their runs went with the suggest and
  refine calls); the saved run still holds them.

### Not seen

Nobody has seen the screen with a file in it in a browser: what a click does on a card, the suggestion
cards, the buttons being disabled during a call, and the dark-mode buttons are covered by
`shiny::testServer()` and by reading the code only. Kevin's own run is the check.

## Phase 5, 2026-11-18: headlines and summaries, every number checked

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5`: 4 calls (2 and 2 repairs).

### Built

- Reflex files: `summary.md` (new, 10 reflexes, the `summarize` call's only file) and `refine.md`
  0.2; checksums in `REFLEX_SHA`.
- `R/spec.R`: a group whose x has fewer than `SPEC_FIT_MIN_DISTINCT` (10) different values, or whose
  fit raises a warning or an error (`fit_works()`), gets no curve and the note "No curve for
  <group>: too few different values of <x>." (a failed fit: "the curve could not be fitted."); the
  code leaves it out too. `spec_facts(spec, table, cb, exploratory)`: the facts of each family,
  from the plotted table, names of id and text columns as tokens; `fact_num()` and the other
  formatters write each value one way.
- `R/reflexes.R`: `check_numbers()` (values, not strings; rounding keeps two significant digits;
  filter and top_n values; years in the facts; one to twelve as words) and `check_words()` with
  `SUMMARY_FORBIDDEN`. `summarize_charts()` and `summarize_inputs()`: batches of `SUMMARY_BATCH`
  (8), one repair for the charts that failed, names put back, `checked`, and the spec's hash
  (`spec_hash()`).
- `R/ui.R`: the "Headline and summary" box in the wide view (Write, two boxes checked on every
  edit, the one-line result, "The chart has changed since this was written." with Write again);
  the title box checked the same way; the headline above a card's chart; the report button above
  the cards. `app.R`: `stories` in the shared state.
- `tests/smoke.R`: 213 checks (184, the summarize prompt check, and 28 for Phase 5).
  `tests/llm_check.R` step 7 and `live_summary()` in `tests/live_gallery.R`; the page has a
  "Phase 5" section.

### The live run

Ten charts, all checked in the end: 7 at once, 3 after a repair. The repairs were for 1,851 (the
model added rows used and rows left out), "one" (in "the only positive one", read as the number 1)
and 8 (the number of regions, which a bar's facts do not state). Input tokens 7,343 fresh and
3,537 from the cache (the 1,179-token system prompt, after the first call).

### Departures

- `spec_facts()` takes `exploratory`, which a chart holds and its spec does not.
- The CHARTS block gives "One row is" for each chart, so the live run can send charts of three
  files in one batch through `summarize_inputs()`; `summarize_charts()` is that for one file.
- A chart missing from a reply is not sent in the repair call; only charts whose text failed are.
- A fit that fails with enough different values gets its own note, not the "too few" one.
- The report button counts the charts it will send, not all the report's charts.
- The wide view was checked with `shiny::testServer()`, not in a browser.

### Noticed, not changed

- A histogram's top bin can reach past the data (34.8 to 45.2 on scores that end at 40); the facts
  give the bin's edges as ggplot2 draws them.
- A heatmap's row and column "mean" is the mean of the cells, not of the rows behind them, and the
  facts do not say so; the model wrote it as the goalkeepers' mean age.
- "one" as a pronoun fails the number check.

## Phase 4, 2026-11-18: the chat that refines a chart

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5`: 14 calls.

### Built

- Reflex files: `refine.md` (new, 7 reflexes) and `suggest.md` 0.3; checksums in `REFLEX_SHA`.
- `R/spec.R`: a fitted curve is trimmed to the 1st and 99th percentiles of x within each colour or
  facet group of `SPEC_FIT_TRIM_N` rows or more (`fit_ranges()`, `fit_calls()`: one
  `geom_smooth(data = ~ filter(.x, ...), xseq = ...)` per such group, one untrimmed layer for the
  smaller groups), for loess and linear. A slope's colour note comes only past the palette's own
  limit. A sideways grouped bar dodges with `position_dodge(reverse = TRUE)`, so the first legend
  entry is the top bar.
- `R/reflexes.R`: `CHART_FILES` (seven files) for both `suggest` and `refine`, so their system
  prompts are identical; `CALL_REPLY` and `reply_format()` end each user message with its own
  file's reply format. `refine_chart()`, `assemble_refine()`, `refine_kind()`, `new_chart()`,
  `chart_apply()`, `chart_undo()`, `chart_reset()`, `chart_columns()`.
- `R/ui.R`: charts get ids (`state$charts`); the report holds ids. Each card has "Refine", which
  opens the wide view: the chart, its notes and rule, Interactive view, Show code and Add to report
  on the left; Back to all charts, five wording boxes (`updateOn = "blur"`) with Apply wording, Undo
  and Reset, and a shinychat chat on the right. Each chart keeps its chat, history and last
  exchange. `mod_explore_server()` takes `ask`, for the test's stand-in.
- `app.R`: shinychat in `APP_PACKAGES`; `charts` in the shared state.
- `tests/smoke.R`: 184 checks (166 and 18 new). `tests/llm_check.R` step 6 and `live_refine()` in
  `tests/live_gallery.R`; the page has a "Phase 4" section.

### shinychat 0.4.0, as installed

- `chat_ui(id, ..., messages, greeting, placeholder, width, height, fill, icon_assistant,
  enable_cancel, footer)`: `messages` is a list of `list(role, content)`.
- The analyst's message arrives as `input[[paste0(id, "_user_input")]]`.
- `chat_append_message(id, msg, chunk = FALSE, operation, icon, session)` appends one complete
  message (`msg = list(role, content)`).
- The client disables its own input from the moment a message is sent until a complete message is
  appended (`inputDisabled` in its JavaScript); there is no server function to disable it, and none
  is needed.

### The live run

14 turns: 8 specs, 2 questions back, 4 cannot, no failure, no repair; 36 s. Input tokens 24,283
fresh and 80,080 from the cache: after the first call every turn read the 6,160-token system prompt
from the cache, across all three files.

### Against refine.md

- `smallest_change`: "just show 2015 against 2024" also changed the line to a slope.
- "add a straight line instead of the curve" on a chart with no curve: the say speaks of the
  curve becoming a line.
- "title it Islands pulled ahead": the title was copied exactly, but the say adds that the title
  states a finding not checked against the values, which `analyst_words` says is not the model's
  concern.

### Departures

- The live run used the codebooks labelled in the saved run, so it made no label call; it is saved
  in `tests/live_replies.rds` as `phase4`, beside the Phase 3b run.
- A refine reply is not passed to `llm_json()` with a validate function, so a reply with more
  than one of spec, ask and cannot, or none, fails at once instead of being retried.
- The wide view and the chat were checked with `shiny::testServer()`, not in a browser.

### Noticed, not changed

- The football goalkeepers' Attack has 8 distinct values; a loess curve on that group fails
  however it is drawn, and ggplot2 leaves it out with warnings (the 3b chart of attack against
  defence coloured by position).

## Phase 3b, 2026-11-18: fixes after the first live run

Branch `chart`. Not pushed. One live run on `claude-sonnet-5-5`: 5 calls.

### Built

- Reflex files `core.md`, `comparison.md` and `suggest.md` at version 0.2 (new reflex
  `axis_labels`); checksums in `REFLEX_SHA`.
- `R/spec.R`: `SPEC_DPI` (192) and `spec_png()`, which draws a chart at its size in inches with
  `ragg::agg_png()` when ragg is installed and `grDevices::png(type = "cairo")` otherwise. The
  Explore tab shows it with `renderImage()` at its size in CSS inches (96 CSS pixels each);
  both galleries draw at `SPEC_DPI` (the gallery through knitr's `ragg_png` device).
- Ties at the `top_n` cut are all shown when they make at most `SPEC_TOP_MAX`, with the note "n was
  asked for; m are shown, because values tie at the cut."; the lint field `.top_n` carries m into
  the subtitle ("Top m of N"), the colours and the code (`slice_head(n = m)`). Otherwise top_n
  and the old note, which now says "the 1 shown is" for one value.
- A fitted curve on `SPEC_FIT_TRIM_N` (100) rows or more is fitted on every row and drawn at
  `SPEC_FIT_POINTS` (80) values between the 1st and 99th percentiles of x, through
  `geom_smooth(xseq = seq(...), na.rm = TRUE)` (`.fit_range`; on the log10 scale when `log_x`).
  The code does the same.
- `R/reflexes.R`: `data_safe()` writes `<DATA>` and `</DATA>` (any case) as `[DATA]` inside the
  DATA block and the pick call's block. The call record has `tokens_in` (fresh) and
  `tokens_cached`; the Explore tab's foot shows both.
- `R/data.R`: `CODEBOOK_MAX_DETAIL` is 60.
- `tests/smoke.R`: 166 checks (157 and 9 new). `tests/llm_check.R` step 5 and `LIVE_FILES_3B`
  in `tests/live_gallery.R`: five suggest calls on the codebooks labelled in the saved run.

### The live run

5 calls, no repair, no failure, 37 s; input tokens 14,972 fresh and 21,700 from the cache; 4,409
out. The first call wrote the cache; each of the other four read the system prompt from it
(5,425 tokens). All 15 charts were valid the first time. No spec repeats a column's label as an
axis title or restates `top_n` in a subtitle, and no measure is in more than two suggested charts.
"Which regions grew most" is now a slope of the 8 regions.

### Departures

- Three Phase 2b checks and two Phase 3 checks expected the old behaviour (10 bars for FH's top
  10, where 11 tie; 40 columns to a call); they now expect the new one. The count is unchanged.
- The live run used the labels of the Phase 3 run (saved in `tests/live_replies.rds`), so it made
  no label call: the prompt's five calls are all suggest calls.
- `na.rm = TRUE` on the trimmed curve: with colour or facet groups, each group's loess is NA where
  xseq runs past its own data, and ggplot2 warned (seen in the live page; a check now covers it).
- The tabs were checked with `shiny::testServer()`, not in a browser.

### Noticed, not changed

- The slope of 8 regions gets the lint note "8 colours are hard to tell apart; highlight the few
  that matter, or use small multiples (facet)", which `few_colours` v0.2 now allows for a slope.
- With colour groups and `fit: linear`, each group's line runs across the whole trimmed range,
  past its own data.

## Phase 3, 2026-11-18: the first model calls (labels and suggestions) and the Explore tab

Branch `chart`. Not pushed. One live run, on `claude-sonnet-5-5`: 21 calls (the ping and 20).

### Built

- `R/reflexes.R`: QuestionR's parser, cut to the format in `www/reflexes/README.md` and as strict
  (a stray line, a missing Version, an unknown field or section stops the app, naming the file and
  the reflex); `CALL_FILES`, `check_reflex_files()` at start-up, `reflex_labels()`,
  `assemble_system()`, `data_block()`, `assemble_user()`, `prompt_hash()` (sha256 with digest);
  the pick call's words (`PICK_SYSTEM`, `PICK_ASK`, `PICK_FORMAT`); `label_columns()` and
  `suggest_charts()`, each taking `ask = llm_json`; the record of every call.
- `R/spec.R`: `spec_check()` reads its rules from tables (`SPEC_FAMILY_ROLES`, `SPEC_REQUIRED`,
  `SPEC_FAMILY_FNS`, `SPEC_FIELD_FAMILIES`, `SPEC_KIND_TEXT`); `spec_reference()` writes the same
  tables out as plain text (3,546 characters). Legend keys of see-through points are solid.
- `R/data.R`: an `ai_guess` label keeps `sure`; `accept_label()`; editing a label drops `sure`.
  `CODEBOOK_MAX_DETAIL` is 40.
- `R/ui.R`: Codebook tab: "Suggest labels", "AI guess" and "check this" tags, Accept, "Accept all AI
  labels on this page", the new count line, the row guess as a placeholder with "Use this". The
  Explore tab. The Report tab shows how many charts were added. `busy_button()` disables a button
  in the browser while its call runs.
- `tests/smoke.R`: 157 checks (120 before, 37 new), with `REFLEX_SHA`. `tests/live_gallery.R` and
  step 4 of `tests/llm_check.R`; `CHART_LIVE_STEPS` chooses the steps.

### The live run

20 calls (label 4, pick 4, suggest 12), no repair, no failure; 111 s; 94,493 tokens in and 12,037
out. All 26 charts were valid the first time. The suggest system prompt is 15,477 characters, the
same for every call. The pick call ran for every football question, since 44 columns are in play.

### What the model did not follow

- `suggestions`: "Leave out columns of type id or text unless they name the rows": the football
  suggestions include a bar of Nationality (text, 86 values).
- `sorting`: "Leave `sort` out": two bars set `sort: value_desc`.
- `two_points_slope`: "Which regions grew most between 2015 and 2024?" got a line per region
  (faceted, ten years), not a slope; its `say` gives the eight colours a slope would need. With 8
  regions the rules conflict: a slope cannot be faceted and `few_colours` stops at 7.
- `title_describes` and the prohibition ("no ... number in any field"): subtitles and `say` carry
  counts taken from DATA ("All 8 regions", "all 80 region-years", "The 15 countries with the largest
  2014 scores"). None states a finding.
- `suggestions` ("each a different comparison on different columns"): the FH suggestions use
  `pr_2014` in three of five charts.

### Departures

- Commit B holds all of `R/reflexes.R`, the two calls included; their stand-in tests came with D.
  B's checks of the suggest prompt need `spec_reference()`, committed in C.
- The no-eval check: no file in `app.R` or `R/` calls `parse()`, `str2lang()`,
  `str2expression()`, `eval_tidy()` or `evalq()`, and the only `eval()` calls are the three in
  `spec.R` on calls R builds from a checked spec. Read from the parse data.
- A pick reply that cannot be read stops the request with one sentence (`PICK_FAILED`), rather than
  going on with no column in detail.
- The live run skipped `llm_check.R`'s structured-output checks (2 and 3); check 3 calls an OpenAI
  model on OpenRouter.
- The tabs were exercised with `shiny::testServer()` and a stand-in model, not in a browser.

### Noticed, not changed

- The tie note says "the 1 shown are the first alphabetically" when one value is shown (R/spec.R).
- A column name or label holding the text `</DATA>` would close the DATA block early; nothing
  escapes it.
- `.rscignore` does not list `phase1_prompt.md` to `phase3_prompt.md`.

## Phase 2d, 2026-11-18: last renderer fixes

Branch `chart`. Not pushed. No model calls. The renderer is closed.

### Built

- `R/spec.R`: a scatter with more than `SPEC_OVERLAP_SHARE` of its rows on shared positions draws
  every row, moved at random by at most `SPEC_JITTER` (0.4) of the smallest gap between distinct
  values on each axis (`resolution(x, zero = FALSE)`, on log10 values for a log axis), with
  `position_jitter(seed = SPEC_JITTER_SEED)`, see-through (`SPEC_ALPHA`), and the note "Points are
  moved slightly so that rows sharing a position can be seen." The lint field `.counted` is now
  `.jitter`; `geom_count` and the "Rows" size legend are gone. A bubble chart with more than
  `SPEC_BUBBLE_N` (60) bubbles gets the note "A bubble chart with this many points is hard to
  read; filter, or use a scatter."
- `R/theme.R`: batlow and vik removed (15 palettes, all drawable with paletteer alone).
- `R/data.R`: `read_data(path, name, missing, encoding = NULL)` and `reread_data(..., encoding =
  NULL)`; `NULL` is the guess. A file readr makes no guess for and whose first lines are not valid
  UTF-8 is read as windows-1252, with the guess note. `DATA_ENCODINGS`.
- `R/ui.R`: the Data tab's "File encoding" select ("Detected (<what was used>)", UTF-8,
  windows-1252, ISO-8859-2, ISO-8859-15), used by "Read again". An uploaded codebook's encoding is
  used to read its file, and the select shows it.
- `tests/smoke.R`: 120 checks. 2b-8 (sized by count) is replaced by two 2d-1 checks; 2d-2 to 2d-5
  are new. The colour table prints the diverging palettes.

### Departures

- Check 2b-8 was removed, since 2d reverses it; 120 = 115 - 1 + 6.
- The jitter rule still skips a highlighted scatter, as 2b-8 did: the highlight's labels sit at the
  real positions.
- `read_codebook()` no longer fills a missing encoding with "UTF-8": a codebook written before 2b
  has none, and its file's encoding is then guessed.
- No guess at all from readr (it made none for the short ISO-8859-2 test file) used to mean UTF-8,
  and the read failed; now such a file is checked for valid UTF-8 first.

## Phase 2c, 2026-11-17: colour palettes from paletteer

Branch `chart`. Not pushed. No model calls. The tabs are unchanged.

### What the installed paletteer (1.7.0) provides

- `paletteer_d(palette, n, direction, type)` for a discrete palette and `paletteer_c(palette, n,
  direction)` for a continuous one; the palette is named "package::palette". Also
  `paletteer_dynamic()` and `scale_colour_paletteer_d/_c/_binned` and the fill versions.
- Name tables: `palettes_d_names` (package, palette, length, type, novelty), `palettes_c_names`
  (package, palette, type), `palettes_dynamic_names`, and the colours themselves in `palettes_d`.
- A discrete palette needs only paletteer, which holds its colours (khroma's bright drew without
  khroma). A continuous one is drawn by its source package: `viridis::` needs viridisLite
  (installed), `scico::` needs scico (not installed, so batlow and vik cannot be drawn here).
- Every candidate is in the tables: khroma bright, muted, vibrant (discrete) and sunset (discrete,
  divergent); viridis magma, cividis, mako and scico batlow, vik (continuous); ColorBrewer Blues,
  YlGnBu, RdBu, PuOr and BrBG as `RColorBrewer::` (discrete) and also as `grDevices::`
  (continuous). The `RColorBrewer::` versions are used: they are ColorBrewer's own colours and
  need no package beyond paletteer.

### Built

- `R/theme.R`: `CHART_PALETTES` (17 entries), `paletteer_installed()`, `palette_colours()`,
  `chart_palettes(kind)`, `chart_palette(n, name)`, `chart_palette_max()`, `chart_sequential()`,
  `chart_diverging()`, `chart_palette_default()`.
- `R/spec.R`: `spec_check()`, `spec_table()`, `spec_plot()`, `spec_code()` and `spec_widget()` take
  `palette`; the hard limit on colours is the chosen qualitative palette's `max`; the heatmap's
  `midpoint` fills with the diverging palette centred on it (`rescale_mid()` as the scale's
  rescaler, and the same in the cell-label contrast).
- `probe/app.R` lists paletteer. It is not in `APP_PACKAGES`.
- `tests/smoke.R`: 115 checks (111 before, 4 new) and the printed colour-distance table; the
  gallery ends with a palette section (19 charts).

### Departures

- A third entry needs no package: "Blue-red (built in)", `grDevices::hcl.colors(11, "Blue-Red
  2")`, written out. Without it there would be no diverging palette when paletteer is missing;
  `chart_palette_default()` uses it then, and ColorBrewer RdBu otherwise.
- `spec_check()`, `spec_table()` and `spec_lint()` also take the palette (or its max), since the
  colour limit is now the palette's.
- `spec_widget(plot, palette)`: the widget is converted from the plot, so it keeps the palette the
  plot was drawn with; another palette needs a new `spec_plot()`.
- `paletteer_installed()` uses `find.package()`, not `requireNamespace()`, which the smoke test
  forbids in `R/` (and CLAUDE.md forbids `system.file()`).
- `theme.R` uses base `Filter()` and `vapply()` rather than purrr, to keep the file free of
  packages beyond ggplot2, grDevices and (optionally) paletteer.
- A qualitative palette with fewer colours than the lines of a chart (Tol bright and vibrant hold
  7; the panel has 8 regions) draws the lines in one colour, as for more than 8 before; the
  palette section shows this.

## Phase 2b, 2026-11-17: renderer fixes after the gallery review

Branch `chart`. Not pushed. No model calls. The tabs are unchanged.

### Built

- Static charts: ties across the `top_n` cut and equal values are noted; line and slope end labels
  are drawn only when no two would touch (`SPEC_LABEL_GAP`), otherwise a legend on the right in
  the order of the end values; highlight labels sit inward of their points; facet and colour on
  one column draw one colour; yellow is the eighth colour; boxes sort by median; heatmap rows run
  in level order, top to bottom, and up to `SPEC_HEAT_LABELS` cells print their value in black or
  white; points mostly on shared positions are drawn with `geom_count()`; two legends stack and a
  long one wraps; a sideways bar or dot has no title on its name axis; room below zero comes from
  the table.
- The code: `top_n` as `arrange(desc(value), name) |> slice_head(n = n)` (or a helper column and
  `consecutive_id()` when an x has several rows); the order with `factor()`; no `tapply()`,
  `sort()` or `head()`; the file by its name only; `rename()` for repaired names; one step per line,
  wrapped only past `SPEC_CODE_WIDTH`.
- Encoding: `read_data()` guesses it with `readr::guess_encoding()`; a Latin-family guess is read
  as windows-1252; the problems say so; the codebook keeps `encoding`; the code passes it.
- The widget is made from a variant of the plot with no direct labels, the legend kept and a
  tooltip naming each value with its codebook label; the title (bold) and subtitle are shown and
  wrapped, the caption below, the text scaled, the legend on the right.
- `CLAUDE.md`, rule 1: `chaRt/R/spec.R` is the one file that calls dplyr, tidyr, ggplot2 and scales
  without `pkg::`.
- `tests/smoke.R`: 111 checks (90 before, 21 new). Two gold specs added (25 in all): a Latin-1 bar
  and a line whose labels fit.

### What still differs in the plotly version

- Its default font is wider than the static chart's (heights match at the same size).
- The legend of a line chart is alphabetical, not in end-value order (ggplotly ignores `breaks`).
- A bubble chart's colour and size legends are merged into one list without size keys.
- The heatmap's colour bar and the rug look as before (bar on the right, rug opaque).
- Highlighted lines and points carry no legend: their names are in the tooltip.

### Readings

- "The n shown" in the tie note is how many of the tied values are shown.
- A line chart with a highlight whose labels would touch colours the highlighted lines from the
  palette and shows them in a legend (one highlight colour would make the legend useless).
- More than 8 lines whose labels would touch: no labels, no legend (one colour), and a note.
- Item 10's exception: the name axis keeps its title when the spec gives `x_label`, the field for
  that column (the prompt says `y_label`, which is the value axis's).
- Item 8 applies to scatter charts without a highlight (a bubble already sizes its points).
- The tie-break is dplyr's `arrange()` order, which sorts text in the C locale (capitals first).
- Encoding: readr guessed the Latin-1 test file as ISO-8859-2 (65%), which would turn "São" into
  "Săo". Any Latin-family guess is read as windows-1252, and the sentence then says it is a guess.
- A file that is not UTF-8 breaks vroom's delimiter guessing, so for such a file `read_data()`
  takes the delimiter that splits the header into the most columns.

### Not confirmed

- That the plotly text scale (`SPEC_PLOTLY_TEXT`) matches on other screens; it was set from
  ggplotly's point-to-pixel ratio and checked by eye in the gallery.

## Phase 2, 2026-11-17: the renderer

Branch `chart`. Not pushed. No model calls. The tabs are unchanged.

### Built

- `R/theme.R`: `chart_theme(base_size, grid)`, `chart_palette(n)` (Okabe-Ito, at most 8),
  `chart_fill_scale()`, `chart_colour_scale()`, `CHART_HIGHLIGHT`, `CHART_GREY`, and
  `CHART_SINGLE`, `CHART_SEQUENTIAL`, `CHART_MAX_GROUPS`.
- `R/spec.R`: `spec_defaults()`, `spec_check()`, `spec_table()`, `spec_lint()`, `spec_plot()`,
  `spec_widget()`, `spec_code()`, `spec_size()`. The table's steps and the plot's layers are built
  once as R calls: `spec_table()` and `spec_plot()` evaluate them, `spec_code()` writes them out.
- `tests/gold_specs.yaml` (23 specs, at least two per family), `tests/gallery.R` (helpers, and the
  gallery when run as a script), `tests/gallery.html` (written, git-ignored).
- `tests/smoke.R`: 90 checks (52 before, 38 new).

### Findings

- ggplotly() gave no warning for any gold spec, including once the figure is built.
- In the plotly version: the subtitle and caption are dropped; text is about 1.4 times larger
  than in the static chart at the same pixel size, and a long title is cut off rather than
  wrapped; direct labels ignore `check_overlap`, `hjust` and `vjust`, so line-end labels pile up
  and point labels sit on their points; the heatmap's colour bar moves to the right; a legend at
  the top overlaps the title; the rug loses its transparency.
- The yaml package reads a bare `y` (as a key or a value) as TRUE (YAML 1.1). The gold file quotes
  it. Specs from a model arrive as JSON, which has no such problem.
- FH's political rights scores tie at 40 for more than the top 10; `top_n` keeps the first in
  alphabetical order among ties.

### Readings of the prompt (where section 1 was ambiguous)

- More than 8 colours: the palette stops at 8. A line or slope chart with more draws every line in
  one colour with its name at the end; a scatter or bubble chart with more is refused.
- A scatter or bubble chart takes a highlight or a color, not both.
- "The value axis starts at zero" has no spec field to change: a bar's layers always include zero.
  Whether there are negative values is read from the codebook's minimum of y (the plot is built
  without the data), so the FH bars, whose column has a -2 somewhere, get a little room below zero.
- "Small multiples share their scales": `facet_wrap()` is fixed unless `free_y`, so nothing changes.
- The sort a bar or dot falls back on depends on x's type, so it is decided with the codebook, not
  in `spec_defaults()`. `level_order` is the analyst's order for an ordered x, numeric order for
  numbers, and alphabetical for an unordered category.
- `share` is the share of rows within a facet, not within a colour.
- The table of a scatter, bubble, histogram or box is the rows drawn (the columns in use), not
  binned or summarised.
- A histogram's bins when none are given: Freedman-Diaconis, kept within 5 to 60, written into
  the spec by the lint so the code reproduces them. "Top n of N" is written the same way.
- `top_n` and `sort` are refused outside the families that use them; `log_x` only on a measure x of
  a scatter, bubble or histogram.
- The "k of n rows left out" note counts n after the filter.

### Departures

- The lint's fixes that have no spec field (`.flip`, `.alpha`, `.binned`) are kept in the spec with
  a leading dot; `spec_check()` refuses them from outside. `spec_code()` takes the spec as
  `spec_plot()` left it (`attr(plot, "spec")`), since those fixes depend on the data and
  `spec_code()` is given none. It reads the file's header to find the delimiter and the blank or
  repeated column names to rename.
- `chart_theme()` takes `grid` ("y", "x", "xy", "none"): the value axis differs by family, and the
  code must end with `chart_theme()`.
- The calls in `R/spec.R` name dplyr, tidyr, ggplot2 and scales functions without `pkg::`, so the
  written code reads as a person writes it; they are evaluated in `spec_env()`, which holds those
  packages' exports.
- Additions: an `arrange()` step so a bar's table is in drawn order; comma labels on value axes;
  `coord_cartesian(clip = "off")` where labels sit at the edge; extra gold specs (a dot, a bubble, a
  highlighted slope and a box).
- `base64enc` was not needed. The smoke test runs the generated code in a separate `Rscript`.

### Not confirmed

- How the charts look at work with the office theme, and whether plotly there behaves the same.
- FH's `Cote d'Ivoire` is not valid UTF-8 in the file. It appears in no gold chart; how it would be
  drawn or written into code is unchecked.

## Phase 1b, 2026-11-17: four fixes to the data layer

Branch `chart`. Not pushed. No model calls.

### Built

- **Values that mean missing.** `read_data(path, name, missing)` adds the analyst's values to
  `DATA_NA`; readr matches them to whole cells after trimming (checked: `9` leaves `99` and `19`
  alone). The Data tab has "Values that mean missing, one per line" and "Read again", which calls
  `reread_data()`. The codebook keeps `missing_codes`; an uploaded codebook re-reads the file with
  them before `check_codebook()` runs and fills the box. `mostly_numbers_note()` now points to the
  box. FH read with `..` has 24 integer columns and one id, and no problems.
- **Whole-number ids.** A whole-number column of distinct values is `id` only when it is an
  unbroken run or its name matches `ID_NAME_PATTERN`; otherwise `integer` with `DISTINCT_NOTE`.
- **Roles follow the type.** `role_choices()` from `ROLE_CHOICES`; the role select offers only
  those; a type change keeps an allowed role and otherwise gives the default; `check_codebook()`
  refuses a role the type does not allow, naming the column.
- **Ordered levels one per line** in a `textAreaInput`, read by `parse_lines()`.
- `tests/smoke.R`: 52 checks (the 39, 12 asked for, and 1 on what Read again carries).

### Departures from the Phase 1b prompt

- **Read again carries what the analyst chose, not what R chose.** A type other than R's own
  (`detected`) and a role other than the type's default are kept, or dropped with a sentence. A
  type or role that R chose is chosen again from the data without a note; otherwise reading FH
  again with `..` gave 46 sentences saying text columns were now integer. Labels, their sources and
  the row sentence are always kept. One extra smoke check covers this.
- **A Phase 1 bug fixed:** `codebook_detail()` gave only the count of distinct values for any
  column with more than 30 values, numbers included, so a number's range and quartiles were never
  sent. The 30-level rule now applies only to category, flag and ordered columns, as DESIGN.md
  section 4 says.
- `missing_codes` is stored as text when there are codes and as an empty list (written `[]`) when
  there are none, because the yaml package reads a one-item list back as text; this keeps the round
  trip `identical()`.
- The "every value is different" rule, for whole numbers as for words, needs more than
  `CODEBOOK_MAX_LEVELS` rows, so a short file of distinct numbers is not called an id.
- An integer column can carry both notes, joined by "; ".
- A codebook uploaded on the Data tab now needs the data file to have been uploaded in this
  session (the file is read again with the codebook's values); before, a profile was enough.

### Noticed, not changed

- FH's political rights columns hold `-2` as their minimum. It may be a code; that is the analyst's
  call, and the box takes it if so.
- footballdata's `Birthday` is text: its dates are not in a form readr reads as dates.

## Phase 1, 2026-11-17: Phase 0 fixes, Data and Codebook

Branch `chart`. Not pushed. No model calls in the app.

### Built

- Part A: the connection heading on Start here is "Settings and connection". `tests/llm_check.R`
  defaults to `openai/gpt-6-luna` on OpenRouter, takes `CHART_TEST_MODEL` for checks 1 and 2, and
  stops before any call if the model is an Opus model. The probe lists knitr, rmarkdown, ggplot2,
  readr, dplyr, tidyr and tibble, and has a second render: a `.qmd` with one R chunk that draws a
  ggplot and prints `plotly::ggplotly()` of it.
- `R/data.R`: `read_data`, `profile_data`, `new_codebook`, `write_codebook`, `read_codebook`,
  `check_codebook`, `apply_codebook`, `edit_entry`, `codebook_ready`, `type_choices`,
  `codebook_index`, `codebook_detail`, and their helpers.
- The Data and Codebook tabs, with `data`, `problems`, `profile` and `codebook` in the shared state.
- `tests/smoke.R`: 39 checks (the 7 from Phase 0, 4 for each of five files, and 12 on the messy file).

### Findings

- Live check, with the key: the ping works on `claude-sonnet-5-5`, but structured output through
  ellmer 0.4.2 (`$chat_structured()`) is refused by the API for that model: "tool_choice: type
  "tool" and "any" are not supported for this model" (HTTP 400). The same call works on
  `claude-sonnet-4-5` and through OpenRouter (`openai/gpt-6-luna`). Not worked around: for
  Sonnet 5.5 the design falls back to `llm_json()`.
- FH_disaggregated.csv marks missing values with `..`, so 23 of its 25 columns read as text (about
  40 distinct values each). The Data tab says so for each column. Recoding is the analyst's call.
- R did not see the key from Git Bash: Git Bash sets `HOME` to `C:/Users/keval`, so R looked for
  `.Renviron` there; R's own home on this machine is `C:/Users/keval/OneDrive/Documents`, where the
  file is. From PowerShell R sees both keys.

### Not confirmed

- The row numbers readr gives for a ragged line are file line numbers (header = line 1) in the cases
  tried; for a value that fails to parse after the types are guessed from every row, this was not
  seen and so not checked.
- A level that contains a comma cannot be put in order in the Codebook tab, whose order box splits on
  commas.

### Departures from the Phase 1 prompt

- `read_data` also reports a column that is mostly numbers with a few words in it (the `..` of FH),
  naming up to three of the words. Nothing is recoded.
- The YAML holds `distinct` and the values and counts as `values` and `counts`, not the `levels: 5`
  of DESIGN.md section 5, since the prompt names `distinct` for the count. It also holds `detected`,
  R's own type, so the allowed type changes can be worked out after the analyst changes a type.
- `type_choices` also allows `integer` to `ordered` (it allows `integer` to `category`, and
  `category` to `ordered`), and `id` back to `integer` when the id is made of whole numbers (R typed
  it `id` on a guess, and nothing is converted on a guess).
- `check_codebook` also refuses an unknown role, a label not marked file, ai_guess or user, and an
  ordered column whose order is not exactly its levels.
- `id` is assigned when the column has more than `CODEBOOK_MAX_LEVELS` rows, as the prompt says,
  counting all rows, missing ones included.
- The role select offers all six roles for every column; the prompt fixes only which types are
  allowed.
- FH has no column whose type can change except `pr_2014` (integer to id), so the by-hand test set
  that one type, and also set a role on `pr_2003`.
- The probe's renders set `QUARTO_R` to the R running the app, so the R chunk runs in the same
  installation.
- The in-app browser has no file picker, so for the by-hand test the course file was fetched from a
  temporary read-only local server and handed to the file input with JavaScript. The server and the
  app were stopped afterwards; nothing was written to the repository.

## Phase 0, 2026-11-17: skeleton, key box and probes

Branch `chart`, from `main`. Not pushed.

### Built

- `app.R` in QuestionR's seven sections: settings (classification, logo, office, 50 MB upload limit,
  source link, default profile), the `home` and `work` profiles chosen by `CHART_PROFILE`, the
  package, ellmer and masking checks, Cairo, the layout (banner, header with Source code button,
  logo, title and dark-mode switch, six tabs) and a server with `mod_key_server` and
  `mod_connect_server` only.
- `R/llm.R`, copied from QuestionR. Removed: the drafter, QuestionR's per-task token limits (now
  `label`, `suggest`, `refine`, `summarize` at 8000 as placeholders, and `ping`),
  `LLM_CUTOFF_ADVICE`, and `llm_complete_all()` with `llm_json_all()` (see below).
- `R/ui.R`: the tab names, `advice_box`, `warn_box`, `office_logo`, `model_label`, Start here (one
  paragraph, the key box, the connection check), the "Built in a later phase." placeholder, and
  `mod_connect_ui` / `mod_connect_server` copied from QuestionR.
- `R/_disable_autoload.R`, `.rscignore`, `.gitignore`. No `www/logo/`: `office_logo()` draws a
  dashed box when the folder or file is missing, as in QuestionR.
- `tests/smoke.R` (7 checks, no model calls) and `tests/llm_check.R` (ping, structured output in
  both API styles).
- `probe/app.R`: versions, Quarto, a render from inside the app, Cairo PNG, `tempdir()`, and the
  "Copy results" text.

### Not built

Everything from Phase 1 on: Data, Codebook, Explore, Report and Methodology are one line each. No
`R/data.R`, `R/spec.R`, `R/theme.R`, `R/reflexes.R`, `report.qmd`, `www/reflexes/` or
`build/convert_skill.R`.

### Not confirmed

- The live check has not been run with keys: neither `ANTHROPIC_API_KEY` nor `OPENROUTER_API_KEY`
  is set on this machine, so it made no calls. Whether structured output works on either route is
  still open.
- The OpenRouter model `openai/gpt-4o-mini` is a guess at a small, cheap model that is still
  listed; `OPENROUTER_MODEL` overrides it.
- The `quarto` R package is not installed here, so the name of its path function could not be
  checked. The probe uses `quarto::quarto_path()` only if the installed package exports that name,
  otherwise `QUARTO_PATH`, then the PATH, and says which route it took. It renders with the Quarto
  command line (`quarto render file --to html`, with `embed-resources: true` in the document), not
  through the R package.

### Departures from the Phase 0 prompt

- `llm_complete_all()` and `llm_json_all()` were not copied. They send several requests at once;
  CLAUDE.md rule 3 allows that for QuestionR only, and DESIGN.md says chaRt has no parallelism. So
  `promises` and `later` are not in `APP_PACKAGES`. `llm_json()` keeps its `first` argument
  unchanged.
- Copied code keeps QuestionR's `<-` inside some function bodies (the modules), since the prompt
  says not to refactor what is copied. New code uses `=`.
- The key box keeps QuestionR's wording, which refers to "Settings and connection below"; in chaRt
  the section is headed "Models".
- The loop check reads R's parse data (the `for`, `while` and `repeat` keywords), so the word
  "repeat" in a comment of `llm.R` does not count.
- `.rscignore` also lists `phase0_prompt.md`, `.rscignore` and `.gitignore`.
- The probe uses base `lapply()` and `vapply()`, not purrr, so that it starts on a server with only
  shiny installed.
