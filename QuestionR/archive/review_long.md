# One live long review, in parts (tests/llm_check.R go review30)

Run: 2026-11-12 18:38 | profile: home
Model: claude-sonnet-5-5 | evaluation ceiling 43000 tokens a call, batch size 4000 characters, paste cap 40000; none was changed for this run.
Questionnaire: tests/review_long_questionnaire.txt, written for this test: 30 questions in 30 blocks, 5028 characters.
Form: research question "Household energy use, travel and quality of life", population "Adults aged 18 and over living in England", mode web, no country, English.
Parts: 2 (first blocks 1, 24), so 3 calls: one for each part and one for the instrument as a whole.

| Call | Characters | Seconds | Tokens in | Tokens out | Finish | Attempts | Status |
|---|---|---|---|---|---|---|---|
| part 1 of 2 | 3766 | 129.2 | 5,592 | 18,207 | success | 1 | ok |
| part 2 of 2 | 1260 | 62.6 | 4,645 | 8,421 | success | 1 | ok |
| instrument | 5028 | 111.0 | 5,663 | 15,386 | success | 1 | ok |

Total: 303 seconds (5.0 minutes), 15,900 tokens in, 42,014 tokens out. Result status: ok.

Failed parts: none.

Findings: 45 in all: 34 about questions and 11 about the instrument.
By band: Fix before fielding 4, Needs your judgment 25, Minor 16.
**Share of question findings whose evidence was found in the pasted text: 34 of 34 (100.0%).** Phase 4's gold run found 55 of 100 (45 had evidence that was a description).
Checks not in the checklist that was sent: 0.
Questions back: 30 of 30; ids exactly as pasted, in order.
Item calls that filled fields they were told to leave empty (instrument, test_first, trapd, not_assessed): 0 of 2 (0, 0 entries).
The instrument call returned 0 question entries (it was told to leave items empty).

