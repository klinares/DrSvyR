# QuestionR status: Phase 9 (final questions, new reflexes, fewer files)

2026-11-13, branch `questionr`. The Phase 8 status, with its live runs, is `archive/STATUS_phase8.md`.

## What changed

- **9a.** The Claude project's reflex files (core, generate, evaluate, attitudinal, behavioral,
  sensitive, mode, and the new refine.md), `start.md` and `methodology.md` are installed as
  written. A draft's or refine's parts are objects (`when`, `stem`, `options`, `open_format`).
  Start here has no worked-example card; `start_example.svg` is on the Methodology page and the
  reflex table is still last. The renderer draws the table and the block quotes in `start.md`;
  in the block quotes "Yes / No" falls on the question's line (one line break inside a
  paragraph, as commonmark draws it), and the page was not rewritten.
- **9b.** Write questions is two calls by two models: the drafter drafts (core, generate, the
  kind's file, the modes); the main model edits in a fresh chat (core, refine, the kind's file,
  the modes; the brief, the draft as JSON, the CHECKLIST of core, generate, the kind's file and
  the modes, and refine.md's reply format). Home: drafter `claude-sonnet-4-5`, main
  `claude-sonnet-5-5`, one pasted key. Up to 10 items; refine ceiling 24,000. The page shows the
  final questions only, as they are asked, then "Before you field these", then a closed "How these
  were written". The check call and the reading back of a rewrite are gone.
- **9c.** 8 questions a part (30 questions: 4 parts and 1 call on the whole, 5 calls). "Most are"
  only above half, else "The largest group is"; whole-questionnaire ids in pasted order; a rewrite
  drawn with each option on its own line when it splits cleanly. `llm_check.R review30` and `gold`
  take an optional model id.
- **9d.** `R/` is `reflexes.R`, `llm.R`, `review.R` (checks and flows), `ui.R` (tabs, results,
  task pages) and `_disable_autoload.R`. The old gold baseline and `gold_matches.csv` are in
  `archive/`. `tests/review30.json`, `tests/write_run.json` and `Claude outputs/` are ignored.

## Line counts

| | Before Phase 9 | After |
|---|---|---|
| `app.R` + `R/` | 2,195 | 2,234 |
| `tests/*.R` | 727 | 748 |

Smoke: 72 checks, all passing. `app.R` + `R/` is above the 2,200 of Phase 8: the refine call, the
final-question layout and the second model added about 40 lines net of what was removed.

## Decisions taken, with the default used

1. The refine call's message is assembled by R (persona sentence, an edit task, the brief, the guidelines), not the analyst's edited box, which steers the draft only.
2. refine.md asks for `changes` of at most 15 words; R refuses over 20, the brief's guard.
3. A part's lead is its `when` with a capital and a colon ("If a great deal:"); an open question's answer line is "Answer: " and its `open_format` as the model wrote it.
4. On the Write page the intro and stem are boxes that wrap and can be edited; options are boxes; parts and programming are read-only text.
5. The run log names the model of each call (drafter or main).
6. A rewrite counts as question plus options only when its options (its last line, or the text after its last "?") are two or more of at most 8 words each.
7. Parts go four calls at a time; the whole-questionnaire call joins the last group (30 questions: a group of 4, then 1).
8. `Claude outputs/` was never tracked, so it is ignored and left on disk.

## Not verified

- The drafter id `claude-sonnet-4-5` against the API: the connection check is a live call and waits for Kevin's yes, before any run.
- Any live run of Phase 9: gold, review30 and the three Write runs wait for Kevin's yes.
- The token counts of single calls are recorded since the fix at the end of Phase 8, not yet seen live.
