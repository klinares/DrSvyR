# QuestionR status: Phase 8 (one reviewer, short answers, reflexes)

2026-11-13, branch `questionr`. Built in Claude Code from the Phase 8 brief. Earlier status, review,
design and prompt notes are in `archive/`.

## What was built

- **One model.** `APP_PROFILES` is `home` (claude-sonnet-5-5, Anthropic API) and `work`
  (placeholders), both on a key pasted into the app. The environment is read only for the
  profile's name. The Anthropic style caches the system prompt for five minutes
  (`chat_anthropic(cache = "5m")`, as the installed ellmer 0.4.2 documents it).
- **Evaluate questions.** The reply is flags: check, stage, level (fix or consider), quote, a why of
  at most 25 words, and one rewrite when there is a fix flag. R refuses and retries more than 8
  flags on a question, a why over 30 words, a check not sent, a missing quote, a bad stage or level,
  and a reply that skips a question. A quote not found in the pasted text is marked, not dropped.
  Questions are split on blank lines, else on label lines (`Q1.`, `1.`, `1)`, `A1`), packed into
  parts of at most 15 questions and 8,000 characters (paste limit 60,000), sent four at a time,
  plus one call on the whole questionnaire when there is more than one question. Ceilings: 6,000
  per part, 1,500 for the whole. The page: a bottom line R builds from the flags, up to five cards
  to fix first, a table of all questions whose rows open to every flag, a closed panel on how it was
  produced, Copy for Word and the run log.
- **Write questions.** Call 1 drafts 1 to 6 items; call 2 sends them as a questionnaire through the
  same items call in a fresh chat, with the Check lines of core.md, the kind's file and the modes.
  A rewrite for a fix flag replaces the draft and the item says so; otherwise its one line is its
  design why. Then not covered and needs from the analyst, and a closed Criteria applied panel.
- **Tabs.** Start here, Evaluate questions, Write questions, Methodology. Each task is one page:
  the form, one button, a short editable box (109 to 121 words for the standard forms) and Run,
  then the results. The box never holds the system prompt, checklist, reply format or questions;
  an edit is recorded in the run log only.
- **Start here and Methodology.** Structure and figures as the brief orders them: `fw_tse.svg`
  with the measurement side in colour, `start_example.svg` (the top panel of the old
  `fw_construct.svg`, with the Session 1 credit), the worked example drawn from
  `www/start_example.json` by the card Results uses (a box says it is not recorded yet), the
  four-box `how_it_works.svg`, and the Methodology sections with placeholders for the Claude
  project's text and a reflex table read from the reflex files.
- **Reflex files.** Parser: optional `Label` (at most 6 words, never sent) and `Applies`, and an
  `## Instrument checks` group in evaluate.md. Labels added to every reflex with a Check line;
  `severity`, `rewrite_and_probe` and `what_to_test` replaced by `short_and_ranked`; `restraint`,
  `known_overcalls`, `known_misses` unchanged. New checksums in `tests/smoke.R`.

## What was deleted

Workers, blind candidate labels, the appraisal, the brief check and their reflex files
(`pm_appraise.md`, `pm_brief.md`), `cross_cultural.md`, See all drafts, swap, Run again with
REVISION, the Brief, Prompt, Results and Output tabs, the rehearsal profile, OpenRouter, server
keys, the pilot notice, the reflex panels, `fw_testing.svg`, `fw_example.svg`, `tests/review.R`.
TRAPD, its figure and the language fields were already gone in Phase 9.

## Line counts

| | Before (questionr at the start) | After |
|---|---|---|
| `app.R` + `R/` | 3,696 | 2,195 |
| `tests/*.R` | 4,067 (smoke 3,092, review 659, llm_check 316) | 727 (smoke 556, llm_check 171) |

The brief gave 4,072 for `app.R` + `R/`; `main` had 4,153 and `questionr` 3,696 when this began.
Smoke: 69 checks, all passing.

## Decisions taken, with the default used

1. Started from `questionr` (Phase 9). Where the brief named something already gone there, it was treated as done.
2. The PDFs are committed under short names: the `.gitignore` rule that kept them out is removed, and `*.pdf` is binary in `.gitattributes`.
3. The old smoke test was replaced at 8c, since most of it tested the fan-out, and grown phase by phase.
4. The Label, Applies and instrument-group parser landed in 8d, because the bottom line needs labels; the Labels themselves were added in 8h.
5. A reflex with no Applies line applies to its kind file's kind, or to any question. In a review, kind files send only their reflexes that have a Check line.
6. Every call of one review has the same system prompt (all reflexes in force); only the CHECKLIST differs, so the cache can serve the later calls.
7. The persona's first sentence goes in the box and the rest opens the system prompt. A kind file's guidelines go after the box for a draft.
8. Question ids come from the pasted text (its label, else its position) and are mapped by order, not taken from the model.
9. "A problem likely to change answers" means at least one fix flag. The stage line counts each such question's first fix flag. Consider-only questions get a clause.
10. The whole-questionnaire call goes in the same group of four as the parts.
11. The Write check's message asks for a review. Its checklist leaves out evaluate.md's and generate.md's Check lines, as the brief says.
12. A rewrite is read back as "question, then options joined by ' / '" (the layout the check was shown). Otherwise it becomes the question and the options stay.
13. Copy for Word (Evaluate): the bottom line, the fix-first cards and the table rows. The flags behind closed rows are not copied, and there is no footer.
14. Forms: Evaluate has no "Other details"; Write has no "Existing items to keep" or "Other details". Items default to 3.
15. The review page is scrubbed of the session key too, though no key can reach a reply.
16. Draft ceiling 6,000 tokens (was 12,000 for up to 10 items with notes).
17. Each reflex file's version is bumped one step for these mechanical edits.
18. `QUESTIONR_PROFILE` is kept, since it names a profile, not a key.
19. Start here has the two sentences the brief specifies. The Methodology text is `[Text to come.]` except the pointer and the language-versions sentence.
20. `tests/gold_summary.md` and `tests/llm_check.out` went to `archive/` as well. The old `tests/gold_runs/*.json` stay as the earlier baseline.
21. `llm_check.R` reads the key from `QUESTIONR_KEY` or `ANTHROPIC_API_KEY` (test script only). It counts the Q5/Q17 scale reversal only from a whole-questionnaire flag naming both, since the two are in different parts.

## For the Claude project (reflex text this phase did not touch)

- `restraint` (kept word for word) tells the model to copy words "into evidence"; the reply field is `quote`.
- `declare_defaults`, `existing_items_first`, `note_similarity` and `midpoint_and_dont_know` refer to notes or decisions, which the draft reply no longer has.
- `not_a_pretest` asks which items need testing and by what method; no field carries it, and `short_and_ranked` says to write nothing the format does not ask for.
- No coded defaults exist (removed in Phase 9), so Criteria applied lists check labels only.

## Not verified

- Any live call: `example`, `review30` and `gold` wait for Kevin's yes. `www/start_example.json` does not exist yet.
- Whether the cache is read: the first group of four calls all write it; `review30` reports cached tokens.
- The token ceiling of 6,000 for a 15-question part, until `review30`.
- Publishing to Connect, and the work endpoint.
