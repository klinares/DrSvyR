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

## Live runs (2026-11-13, home profile, Kevin's yes; 40 calls and 1 retry)

- Connection check: claude-sonnet-5-5 and claude-sonnet-4-5 both Ready.
- gold: 27 of 27, 12.7 s, 2,167 tokens in and 1,450 out per item. Fix flags per flawed item 2.85, per
  control item 0.29 (C7 and C8 have one each). 98 flags, every quote found. F3 needed a second
  attempt. `tests/gold_runs/2026-11-13-2257_claude-sonnet-5-5/_flags.csv`. The first attempt wrote
  to the Phase 8 folder of the same day and model, skipped every item and made no call; run folders
  are now named by date, time and model.
- review30: 5 calls, 94 s; fix flags per question 1.13 (max 3), consider 0.97 (max 3); 63 of 63
  quotes found; no repeat attempts; all 8 deliberate faults flagged. `tests/review30.md`.
- Write: behavioral 36 s, attitudinal 60 s, sensitive 44 s, 2 calls each, no retries; token counts
  now recorded for single calls (draft 355 to 803 out, refine 3,128 to 5,701 out).

## Phase 10 (2026-11-13)

- 10a: sensitive.md (likely_edited) and behavioral.md (no_adding_up) installed as written.
- 10b: a "before the item" part is drawn above the intro and stem, on the page and in Copy for
  Word; parts are edited like the stem and options; the domain is a small label under each heading
  (in Copy for Word too, so it matches the page).
- 10c: the bottom line names at most three kinds of fault, then "and N other kinds".
- Live (Kevin's yes, 29 calls): gold 27 of 27 in `tests/gold_runs/2026-11-13-2316_claude-sonnet-5-5/`;
  fix flags per flawed item 2.45, per control item 0.29 (C7 only); likely_edited cited once (F6,
  consider); 93 of 94 quotes found; F5 and C3 needed 2 attempts and F6 needed 3 (376 s).
  One behavioral Write run, 33 s, filter drawn above the stem. Smoke 74.

## Phase 10e (2026-11-14)

- evaluate.md 0.8 installed as written (fix_or_consider; fix only for a fault in the question as
  written). Smoke 74.
- Live (Kevin's yes, 32 calls and 4 retries): gold 27 of 27 in
  `tests/gold_runs/2026-11-14-0816_claude-sonnet-5-5/`; fix flags per flawed item 3.00 (consider
  1.30), per control item 0.29 (consider 2.00; C7 only, 2 fix flags); likely_edited not cited;
  102 of 102 quotes found; F1, F16 and C4 needed 2 attempts; no item over 60 s (longest F1, 39 s).
- review30: 5 calls, 123 s; fix 0.97 and consider 0.63 per question; 48 of 48 quotes; the whole
  call needed 2 attempts. Deliberate faults 8 of 8 at either level; at fix level 5 of 8 on the
  questions (Q11, Q12, Q13, Q14, Q17), 7 of 8 counting the routing flag on the whole (Q14 to Q16);
  the Q5/Q17 scale reversal is consider.
- The reason an attempt was refused is kept only when every attempt fails, so the reasons for these
  retries are not on record.

## Not verified

- Copy for Word of the new layout in a real browser.
