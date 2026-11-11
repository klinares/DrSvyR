# Evaluate a questionnaire

Version: 0.1

Task file for appraising a pasted questionnaire: an expert review, item by
item and then as a whole. The reflexes in core.md are the item checklist; this
file adds the checks that only apply to a review and to the whole instrument.

<!--
Calibrated on Sturgis, Roberts and Robinson (2026): a checklist that names
problem types finds more than an open review, especially presupposition and
leading wording; restraint language cuts false alarms on good items; severity
below 5 is mostly noise. The regression test for this file is their 20 flawed
items and 7 ESS control items (tests/, not shipped).
-->

## Reflexes

### restraint
- **When:** Every item you review.
- **Say:** Report only problems that are specific to this question and likely to change answers. A well-designed item gets an empty findings list. For each finding quote the exact words or feature that cause it.
- **Never:** Do not report generic cautions that would apply to any survey question, any rating scale or any abstract concept. Do not pad the list.
- **Source:** Sturgis, Roberts and Robinson 2026 (restraint and false positives on ESS control items)

### known_overcalls
- **When:** You are about to flag sensitivity, stigma, burden or length.
- **Say:** These are the faults a language-model reviewer over-reports. Flag sensitivity only when you can say who would edit their answer and in which direction; flag burden only when you can name the step that is hard.
- **Source:** NORC 2026 and Slowinski et al. 2026 as reported in Yan, IASS/WSS Session 2 and Haensch, IASS/WSS Session 3

### known_misses
- **When:** Every item, as a second pass.
- **Say:** Look again for the faults a language-model reviewer tends to miss: an assumption that does not hold for some respondents, a term that carries a different meaning for part of the population, a framing that belongs to one culture, a question that does not apply to everyone asked.
- **Source:** NORC 2026 and Slowinski et al. 2026 as reported in Yan, IASS/WSS Session 2 and Haensch, IASS/WSS Session 3; Sturgis, Roberts and Robinson 2026

### retrieval_and_judgment
- **When:** Any item asking for facts, behaviour, frequency, amounts or dates.
- **Say:** Check the reference period (stated, bounded, short enough), whether the information is likely to be remembered, and whether the respondent must count, add or average to answer.
- **Check:** Can the respondent retrieve the information and reach the answer without difficult recall or mental arithmetic?
- **Source:** Yan, IASS/WSS Session 1 (retrieval and judgment problems); SURV632 (telescoping; estimation strategies)

### response_scale
- **When:** Any closed item.
- **Say:** Check that the options answer the question asked, are balanced where the construct is bipolar, are labelled consistently, have a midpoint and a don't-know or not-applicable option where needed, and do not use vague quantifiers for frequency.
- **Check:** Do the response options match the question and treat both directions evenly?
- **Source:** SURV632 Class 8; Sturgis, Roberts and Robinson 2026 (response-mapping problems); Fuchs, Haensch and Weber 2026

### agree_disagree_and_grids
- **When:** Agree-disagree items or a battery sharing one scale.
- **Say:** Note the acquiescence risk and whether a construct-specific format would do the same job. In a battery, check that items are keyed in both directions and that the grid suits the mode.
- **Source:** Yan, IASS/WSS Session 1; SURV632 Class 8 and Class 11

### context_and_order
- **When:** Reviewing the instrument as a whole.
- **Say:** Check that questions on a topic are grouped and run from general to specific; that an earlier item does not supply the answer, the standard of comparison or the mood for a later one; that early questions are easy and on the stated topic; and that sensitive and demographic items come late.
- **Check:** Is the order free of an earlier item that would shape answers to a later one?
- **Source:** Yan, IASS/WSS Session 2 (advice on grouping questions); SURV632 Class 7 (assimilation and contrast; general and specific items)

### filters_and_routing
- **When:** Reviewing the instrument as a whole.
- **Say:** Check that every item reaches only respondents it applies to, that each filter has a destination for every answer, and that no item is unreachable or asked twice.
- **Check:** Does every respondent path lead only to questions that apply?
- **Source:** Yan, IASS/WSS Session 2 (grouping advice 6); Padgett, Maiorino and Gutierrez 2024 as reported in Fuchs, Haensch and Weber 2026 (logical order is a known weakness)

### scale_consistency
- **When:** Reviewing the instrument as a whole.
- **Say:** Check that the same kind of question uses the same scale, direction and labels throughout, and that reference periods do not change without warning.
- **Check:** Are scales, their direction and reference periods consistent across the instrument?
- **Source:** Haensch, IASS/WSS Session 3 (recommendation 5)

### fit_to_objectives
- **When:** The brief states research questions or an analysis plan.
- **Say:** List research questions with no item measuring them, and items that serve no stated question. Ask whether the items needed for screening, weighting and calibration are present and worded as in the benchmark source the analyst will use.
- **Never:** Do not judge fit to objectives when the brief gives none; say that it was not assessed.
- **Check:** Is every stated research question measured, and does every item serve one?
- **Source:** Yan, IASS/WSS Session 2 (final checklist: objectives, sampling, mode, processing, analysis, adjustment)

### translation_readiness
- **When:** The brief names a country, a language other than English, or more than one language.
- **Say:** For each item say what would not carry across: idioms, culture-bound examples, units, institutions, scale labels with no natural equivalent, grammatical gender. Organize the instrument-level advice by the five TRAPD steps and say which steps the pasted text shows evidence of and which the analyst must still arrange.
- **Check:** Is the item free of wording that would not survive translation or adaptation to the stated setting?
- **Source:** Yan, IASS/WSS Session 2 (3MC surveys; TRAPD); Metheney and Yehle 2024 as reported in Haensch, IASS/WSS Session 3; SURV632 Class 12

### severity
- **When:** Every finding.
- **Say:** Rate how far the problem would distort answers, from 1 (negligible) to 10 (answers meaningless). Reserve 5 and above for problems you would revise before fielding.

### rewrite_and_probe
- **When:** Every finding rated 5 or above.
- **Say:** Offer one rewrite that fixes that fault and changes nothing else, and one cognitive-interview probe that would show whether real respondents have the problem.
- **Never:** Do not rewrite items that have no finding. Do not present a rewrite as better than the original; it is untested.
- **Source:** Adhikari et al. 2025 as reported in Haensch, IASS/WSS Session 3 (experts rated model-revised items worse than originals); Yan, IASS/WSS Session 2 (cognitive interviews)

### what_to_test
- **When:** Closing the review.
- **Say:** Name the few items that most need testing with real respondents and the cheapest suitable method for each. Say at least one method should be used and several where budget allows.
- **Source:** Yan, IASS/WSS Session 2 (choosing testing methods); Tourangeau et al. 2020 as cited by Yan

## Prohibitions

- Never score or rank the questionnaire as a whole.
- Never say an item has no problems; say none were found by this review.
- Never report how many respondents would misunderstand an item.

## Output format

Return one JSON object with these fields. Write findings in English whatever
language the questionnaire is in; write rewrites in the questionnaire's
language and, when that is not English, add the English meaning.

- "items": a list, one entry per question in the order pasted. Each has:
  - "id": the question's own number or label, or its position.
  - "findings": a list, empty if none. Each finding has "check" (the reflex id), "stage" (comprehension, retrieval, judgment, reporting, or instrument), "evidence" (the exact words or feature), "problem" (one or two sentences), "severity" (1 to 10), "rewrite" and "rewrite_english" and "probe" (empty strings when severity is below 5).
- "instrument": a list of findings about order, routing, consistency and fit to objectives, in the same form, with the question ids involved in "evidence".
- "trapd": an object with the keys "translation", "review", "adjudication", "pretesting", "documentation", each a short statement of what is still needed; all empty strings when the survey is in one language for one country and that language is the source language.
- "test_first": a list of up to five question ids with the method suggested for each.
- "not_assessed": what this review could not judge from what was pasted.
