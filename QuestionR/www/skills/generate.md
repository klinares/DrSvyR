# Generate

Version: 0.3

Sent with every request to write new items, after core.md and before the task
file. How a draft is built from the brief and what it must declare.

## Reflexes

### design_not_topic
- **When:** Before writing any item.
- **Say:** Write for the construct, target population, mode and country in the brief. An item for a telephone interview and an item for a mobile web form are different items.
- **Check:** Is the item usable as written in the stated mode for the stated population?
- **Source:** Haensch, IASS/WSS Session 3 (recommendation 2); Buskirk, Eck and Timbrook 2025

### declare_defaults
- **When:** Every item you write.
- **Say:** Every response format is a design decision, not a default. For each item state the decisions you made, as separate entries with one reason each: open or closed, number of options, whether every option has a verbal label, whether there is a midpoint, whether there is a don't-know or no-opinion option, the direction the options run, and the reference period if there is one.
- **Never:** Do not reach for a five-point agree-disagree scale, a yes/no pair or an open text box because it is the usual choice.
- **Source:** Haensch, IASS/WSS Session 3 (every default is a design decision; recommendation 4); Fuchs, Haensch and Weber 2026 (models default to five points and omit don't-know); Padgett, Maiorino and Gutierrez 2024 as reported in Fuchs et al. (too many open-ended and yes/no items)

### labelled_scales
- **When:** Any ordered response scale.
- **Say:** Give every scale point a verbal label, in the same grammatical form, evenly spaced in meaning. If numbers are shown they run in the same direction as the labels. Decide whether the construct is bipolar (two opposite poles, a meaningful middle) or unipolar (none to a lot) and build the scale to match.
- **Never:** Do not mix label constructions within one scale, and do not use negative numbers on a unipolar construct.
- **Check:** Are all points labelled in one consistent form, with poles that match the construct?
- **Source:** SURV632 Class 8 (verbal and numeric labels; conceptual and visual midpoint); Fuchs, Haensch and Weber 2026 (label and number correspondence); Sturgis, Roberts and Robinson 2026 (inconsistent label constructions; endpoint-only labels)

### midpoint_and_dont_know
- **When:** Any attitude or evaluation item.
- **Say:** Decide both explicitly. Offer a midpoint when a middle position is a real answer on the construct. Offer don't know or no opinion when a real share of the population will not have the knowledge or an attitude; say in the notes that offering it raises its use. Keep a not-applicable answer separate from both.
- **Source:** SURV632 Class 8 (don't-know filters, middle alternatives); Yan, IASS/WSS Session 1 (full and quasi filters)

### response_order
- **When:** Any closed item.
- **Say:** For unordered lists, note that options should be randomized or rotated where the mode allows, and why: readers favour early options, listeners favour late ones. Keep ordered scales in one direction throughout an instrument.
- **Source:** Krosnick and Alwin 1987; SURV632 Class 8 (response order effects by mode)

### count_and_scope
- **When:** Every request.
- **Say:** Write exactly the number of items asked for. A filter question, a branch or an unfolding bracket that exists only to serve one item goes in that item's parts and is not counted. If the construct cannot be covered in that number, say which domains are left out.
- **Never:** Do not add extra items or alternates that were not asked for, and do not use parts to add questions on another domain.

### existing_items_first
- **When:** Any request to write new items.
- **Say:** Remind the analyst once, in the notes, that previously evaluated questions on this construct should be looked for first and checked for transfer to this population, language and mode. Using or adapting an existing question is usually better than writing a new one.
- **Never:** Do not suggest specific existing items or sources from memory.
- **Source:** Yan, IASS/WSS Session 1 (three ways of drafting); Haensch, IASS/WSS Session 3 (recommendation 1)

### note_similarity
- **When:** A draft you have written closely resembles a published item you recognise.
- **Say:** Say so in that item's notes, without naming a source, so the analyst can look for the original and use it with attribution instead.
- **Source:** Martini, Scagnelli and Trujillo Medina 2026

## Prohibitions

- Never return an item without its response options or a statement that it is open-ended.
- Never return two versions of one item.

## Output format

Return one JSON object with these fields.

- "items": a list. Each item has:
  - "id": a short code, [construct abbreviation] plus a number.
  - "domain": the single domain of the construct this item measures.
  - "intro": lead-in text read or shown before the question, or an empty string.
  - "stem": the question, in the output language.
  - "options": a list of response options in the order shown, in the output language; an empty list for an open question.
  - "open_format": for an open question, what is entered and its unit; otherwise an empty string.
  - "parts": a list, usually empty. Filter, branch or bracket questions that belong to this item, in the order asked; each has "when" (who is asked it, or "before the item" for a filter), "stem" and "options", in the output language.
  - "programming": routing, filter, randomization and interviewer instructions, in English, as short imperative notes.
  - "decisions": the design decisions required by declare_defaults, one short line each, in English.
  - "source_english": when the output language is not English, the English wording the item was drafted from; otherwise an empty string.
  - "notes": risks, what to test and how, in English.
- "not_covered": domains of the construct left out, or an empty list.
- "missing_from_brief": anything you needed that the brief did not say.
