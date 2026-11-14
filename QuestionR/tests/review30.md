# review30 (tests/llm_check.R review30)

Run 2026-11-14 08:18, model claude-sonnet-5-5, 5 calls, 123 seconds by the clock. Status: ok.

| Call | Seconds | Tokens in | Cached in | Tokens out | Finish | Attempts | Status |
|---|---|---|---|---|---|---|---|
| part 1 | 64 | 8,265 | 0 | 5,565 | success | 1 | ok |
| part 2 | 83 | 8,233 | 0 | 8,375 | success | 1 | ok |
| part 3 | 65 | 8,247 | 0 | 5,796 | success | 1 | ok |
| part 4 | 57 | 8,116 | 0 | 4,752 | success | 1 | ok |
| whole | 39 | 2,836 | 5,756 | 2,340 | success | 2 | ok |

Flags per question: fix mean 0.97 (max 3), consider mean 0.63 (max 2).
Quotes found in the text: 48 of 48.
Calls that needed a repeat attempt: 1.
Deliberate faults flagged at either level: 8 of 8: Q11 yes; Q12 yes; Q17 yes; Q14 yes; Q15 yes; Q16 yes; Q13 yes; Q5/Q17 scale reversal yes.

Bottom line:
> 18 of 30 questions have a problem likely to change answers, and 6 more have points to consider.
> The largest group is comprehension problems (8): attitude object not named or bounded (2), unfamiliar or technical words (1), asks two things at once (1), and 4 other kinds.
> The questionnaire as a whole: routing leads to inapplicable questions (Q14, Q15, Q16, Q29); earlier question shapes a later one (Q5, Q6, Q8, Q17, Q30); scales or periods inconsistent across questions (Q5, Q17, Q18, Q25).

