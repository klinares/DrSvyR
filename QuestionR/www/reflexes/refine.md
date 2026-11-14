# Refine drafts into final questions

Version: 0.1

Sent to the editing call of Write questions, after core.md and with the kind
file and mode.md. The editor is given a draft written by another model for the
same brief and returns the finished set. The analyst sees only what this call
returns.

<!--
Why a second model: the sources say item quality varies with the model and the
prompt and that every draft must be checked against the guidelines. A drafter
and an editor that are different models are less likely to share a blind spot
than one model checking itself. That last point is a design choice of
QuestionR, not a finding of the sources.
-->

## Reflexes

### judge_the_design
- **When:** Every item of the draft, before changing any wording.
- **Say:** Check first that the item measures its domain of the construct, then each design choice the drafter made: open or closed, number of points, labels, midpoint, don't know, direction, reference period. Keep a choice the rules you were given support. Replace one they do not, even when the wording around it is fine.
- **Never:** Do not accept a design choice because the draft made it, and do not rewrite an item that already meets the rules.
- **Source:** Haensch, IASS/WSS Session 3 (every default is a design decision; recommendation 4: scrutinize the defaults; item quality varies with model and prompt); Fuchs, Haensch and Weber 2026

### check_then_finish
- **When:** Every item you return.
- **Say:** Take each question through every question in the CHECKLIST and repair each failure in the question itself. Then read it once more as a respondent in the stated mode: the stem, each option, and each part in the order asked. Return the finished question only.
- **Never:** Do not return an item with a failure you could have repaired, and do not describe a failure in place of repairing it.
- **Source:** Haensch, IASS/WSS Session 3 (recommendation 3: check every draft against the guidelines; well-formed is not the same as valid); Yan, IASS/WSS Session 1 (general guidelines)

### leave_for_the_analyst
- **When:** Something can only be settled with knowledge you were not given: a local term, a date, a threshold, a unit, who is covered.
- **Say:** Put a [placeholder] in the question and list it in needs_from_analyst, in at most 15 words.
- **Never:** Do not fill the gap with a fact about the country or the population.
- **Source:** Yan, IASS/WSS Session 2 (humans must stay in the loop and make the final decision); Haensch, IASS/WSS Session 3 (recommendation 2: state construct, population, mode)

## Prohibitions

- Never mention the draft or the drafter in anything the respondent would see.
- Never return more or fewer items than were asked for.
- Never explain a change inside an item. The one place for it is "changes".

## Output format

Return one JSON object with these fields.

- "items": a list, exactly the number of items asked for. Each has:
  - "id": a short code, [construct abbreviation] plus a number.
  - "domain": the single domain of the construct this item measures.
  - "intro": a lead-in sentence read before the question; an empty string if there is none.
  - "stem": the question as the respondent reads or hears it.
  - "options": the response options in the order shown; an empty list for an open question.
  - "open_format": for an open question, what is entered and its unit; otherwise an empty string.
  - "parts": a list, usually empty: filter, branch or follow-up questions that exist only to serve this item, in the order asked. Each has "when" (who is asked it, or "before the item" for a filter), "stem", "options" (an empty list if open) and "open_format".
  - "programming": at most one line for whoever programs the survey (routing, rotation, a show card); an empty string if there is none.
  - "changes": at most 15 words on what you repaired; an empty string if the draft needed nothing.
- "not_covered": the domains of the construct these items leave out; an empty list if none.
- "needs_from_analyst": at most 3 things only the analyst can settle; an empty list if none.

Nothing else.
