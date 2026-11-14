# Evaluate a questionnaire

Version: 0.8

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
- **Say:** Take each item through every question in the CHECKLIST. Report only problems that are specific to this question and likely to change answers. A well-designed item gets an empty flags list. For each flag copy into quote the exact words from the question or its options that cause it, character for character, with no ellipsis and no paraphrase. When the fault is something missing, copy the words it is missing from and say what is missing in why.
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
- **Label:** Hard recall or mental arithmetic
- **Source:** Yan, IASS/WSS Session 1 (retrieval and judgment problems); SURV632 (telescoping; estimation strategies)

### response_scale
- **When:** Any closed item.
- **Say:** Check that the options answer the question asked, are balanced where the construct is bipolar, are labelled consistently, have a midpoint and a don't-know or not-applicable option where needed, and do not use vague quantifiers for frequency.
- **Check:** Do the response options match the question and treat both directions evenly?
- **Label:** Options mismatched or unbalanced
- **Source:** SURV632 Class 8; Sturgis, Roberts and Robinson 2026 (response-mapping problems); Fuchs, Haensch and Weber 2026

### agree_disagree_and_grids
- **When:** Agree-disagree items or a battery sharing one scale.
- **Say:** Note the acquiescence risk and whether a construct-specific format would do the same job. In a battery, check that items are keyed in both directions and that the grid suits the mode.
- **Check:** If the item uses agree-disagree options or sits in a grid, is that format needed, with items keyed in both directions?
- **Label:** Needless agree-disagree or grid format
- **Source:** Yan, IASS/WSS Session 1; SURV632 Class 8 and Class 11

### fix_or_consider
- **When:** Setting the level of every flag.
- **Say:** Mark a flag fix only for a fault in the question as written: it breaks one of the general guidelines (unfamiliar or ambiguous words, a long or negative sentence, two things at once, leading wording, options that are not exhaustive and exclusive), it does not apply to some of the people asked, or it asks for something respondents cannot recall or work out as asked. Mark it consider when it is a design choice a careful designer could defend (end points labelled only, no don't-know option, no time frame on a general attitude), when it depends on something you were not told, or when it is about sensitivity alone. A valid concern does not always need a fix.
- **Never:** Do not mark a flag fix because a question could be more precise. Do not lower a real fault to consider to keep the list short.
- **Source:** NORC 2026 as reported in Yan, IASS/WSS Session 2 (most problems an AI reviewer identifies are valid concerns, but not all need a fix; methodologists decide which flags need revision); Yan, IASS/WSS Session 1 (general guidelines; faulty presupposition; retrieval)

### rewrite_ready
- **When:** A question has a fix-level flag.
- **Say:** Write the rewrite as a finished question the analyst could take to testing: the full stem and every response option, in plain words, no longer than it needs to be. Put a definition or a time frame in one short lead-in sentence, not inside the stem. Use a [placeholder] for a date, a local term or a threshold you were not given. If fixing a fault means two questions, write both.
- **Never:** Do not fix one fault by adding another: no new clause that makes the stem long, no new term that needs its own definition.
- **Source:** Yan, IASS/WSS Session 1 (general guidelines 1 and 2; writing attitudinal questions 3: clearly specified concepts in simple language without making the question too long or too syntactically complicated)
## Instrument checks

<!--
The checks the whole-questionnaire call takes, and only that call. An item call never
carries them.
-->

### context_and_order
- **When:** Reviewing the instrument as a whole.
- **Say:** Check that questions on a topic are grouped and run from general to specific; that an earlier item does not supply the answer, the standard of comparison or the mood for a later one; that early questions are easy and on the stated topic; and that sensitive and demographic items come late.
- **Check:** Is the order free of an earlier item that would shape answers to a later one?
- **Label:** Earlier question shapes a later one
- **Source:** Yan, IASS/WSS Session 2 (advice on grouping questions); SURV632 Class 7 (assimilation and contrast; general and specific items)

### filters_and_routing
- **When:** Reviewing the instrument as a whole.
- **Say:** Check that every item reaches only respondents it applies to, that each filter has a destination for every answer, and that no item is unreachable or asked twice.
- **Check:** Does every respondent path lead only to questions that apply?
- **Label:** Routing leads to inapplicable questions
- **Source:** Yan, IASS/WSS Session 2 (grouping advice 6); Padgett, Maiorino and Gutierrez 2024 as reported in Fuchs, Haensch and Weber 2026 (logical order is a known weakness)

### scale_consistency
- **When:** Reviewing the instrument as a whole.
- **Say:** Check that the same kind of question uses the same scale, direction and labels throughout, and that reference periods do not change without warning.
- **Check:** Are scales, their direction and reference periods consistent across the instrument?
- **Label:** Scales or periods inconsistent across questions
- **Source:** Haensch, IASS/WSS Session 3 (recommendation 5)

### fit_to_objectives
- **When:** The brief states research questions or an analysis plan.
- **Say:** List research questions with no item measuring them, and items that serve no stated question. Ask whether the items needed for screening, weighting and calibration are present and worded as in the benchmark source the analyst will use.
- **Never:** Do not judge fit to objectives when the brief gives none; say that it was not assessed.
- **Check:** Is every stated research question measured, and does every item serve one?
- **Label:** Research question not measured
- **Source:** Yan, IASS/WSS Session 2 (final checklist: objectives, sampling, mode, processing, analysis, adjustment)

## Prohibitions

- Never score or rank the questionnaire as a whole.
- Never say an item has no problems; say none were found by this review.
- Never report how many respondents would misunderstand an item.
- Never write a why of more than 25 words, and never write anything the format does not ask for.

## Output format

Return one JSON object. Write findings in English, and write a rewrite in the language of the question. Be brief: nothing outside the fields below is shown to the analyst.

For questions, the object is {"items": [...]}, one entry per question, in the order given. Each entry has:

- "id": the question's own label, or its position.
- "flags": every problem you stand behind, most damaging first; an empty list if there is none. Each flag has:
  - "check": the id of the CHECKLIST check it fails.
  - "stage": "comprehension", "retrieval", "judgment" or "reporting".
  - "level": "fix" for a fault in the question as written; "consider" for a defensible design choice, something that depends on knowledge you were not given, or sensitivity alone.
  - "quote": words copied exactly from the question or its options.
  - "why": at most 25 words: what the respondent cannot do, in plain words.
- "rewrite": one rewrite of the whole question and its options that fixes its fix-level flags and changes nothing else; an empty string when it has no fix-level flag.

For the questionnaire as a whole, the object is {"instrument": [...]}: at most 3 flags of the same shape, each with "questions" (a list of the ids of the questions it concerns) in place of "quote".

Nothing else: no severity, no probe, no test plan, no rewrite of a single flag.
