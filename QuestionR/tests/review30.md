# review30 (tests/llm_check.R review30)

Run 2026-11-14 11:59, model claude-sonnet-5-5, 5 calls, 93 seconds by the clock. Status: ok.

| Call | Seconds | Tokens in | Cached in | Tokens out | Finish | Attempts | Status |
|---|---|---|---|---|---|---|---|
| part 1 | 46 | 2,954 | 5,783 | 6,061 | success | 1 | ok |
| part 2 | 73 | 2,922 | 5,783 | 9,777 | success | 1 | ok |
| part 3 | 58 | 2,936 | 5,783 | 7,917 | success | 1 | ok |
| part 4 | 42 | 2,805 | 5,783 | 5,470 | success | 1 | ok |
| whole | 20 | 3,195 | 5,783 | 2,225 | success | 1 | ok |

Flags per question: fix mean 1.00 (max 2), consider mean 0.77 (max 2).
Quotes found in the text: 53 of 53.
Calls that needed a repeat attempt: 0.
Deliberate faults flagged at either level: 8 of 8: Q11 yes; Q12 yes; Q17 yes; Q14 yes; Q15 yes; Q16 yes; Q13 yes; Q5/Q17 scale reversal yes.

Bottom line:
> 21 of 30 questions need a fix; 2 more have points to consider. Most common: words with more than one meaning (5), reference period unclear or too long (5), no truthful answer for non-doers (4).
> Questions 5, 6, 8, 9 and 30: earlier question shapes a later one. Questions 14, 15, 16 and 29: routing leads to inapplicable questions. Questions 5 and 17: scales or periods inconsistent across questions.

