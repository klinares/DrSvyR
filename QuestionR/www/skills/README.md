# QuestionR skills

Draft 0.2, 2026-11-11. Text files that steer every model call in QuestionR.
The expertise lives here, not in the model: swap the model and none of it moves.

## Format (same parser as svysegment/R/ai_reflexes.R, two additions)

- `Version:` line near the top.
- `## Persona` (core.md only): one paragraph.
- `## Reflexes`: one `### id` per reflex (lower case, underscores), each with
  one-line fields:
  - `- **When:**` the situation the rule applies to.
  - `- **Say:**` what to do.
  - `- **Never:**` optional, what not to do.
  - `- **Check:**` optional and NEW. A yes/no question the project manager
    answers for each candidate item. The Check lines of the files in force are
    the appraisal checklist, and the list of their ids is the "criteria
    evaluated against" summary shown to the analyst.
  - `- **Source:**` optional. Shown on the Methodology tab. Never sent to a
    model: sent, sources get copied into output as citations.
- `## Prohibitions`: one bullet each.
- `## Output format`: NEW name for svysegment's "Reporting style". Sent as
  written.
- HTML comments are notes for people and are stripped before sending.
- No real numbers or real survey items in examples. Use [placeholders].

## Which files go with which call

The prompt is assembled by R in this fixed order, never written by a model,
so the same form produces the same prompt. Blank form fields are omitted, not
guessed.

| Step | Model | Files, in order |
|---|---|---|
| Brief check | PM | core, pm_brief, then the task file |
| Generate: attitudinal scale | each worker | core, generate, attitudinal, mode, cross_cultural |
| Generate: behavioral items | each worker | core, generate, behavioral, mode, cross_cultural |
| Generate: sensitive items | each worker | core, generate, sensitive, mode, cross_cultural |
| Evaluate questionnaire | PM only | core, evaluate, mode, cross_cultural |
| Appraise candidates | PM | core, pm_appraise, then the Check lines of the files the workers received |

`mode.md` is filtered by R before sending: `any_mode`, the reflexes whose id
is a mode chosen in the form, and `mixed_mode` when more than one is chosen.
`cross_cultural.md` is sent whole whenever a country is given, or the output
language or the source language is not English.

The user message has three labelled blocks in Buskirk, Eck and Timbrook's
order: PREPARE (the brief: research question, construct, population, country,
mode, output language, anything else), ASK (the task and how many items),
CHARACTERIZE (the Output format section of `generate.md` or `evaluate.md`).
For Evaluate two blocks sit between ASK and CHARACTERIZE: QUESTIONNAIRE (as
pasted) and CHECKLIST (one `id: question` line per Check in force). Drafting
prompts carry no Check questions; the appraiser gets them instead.

## What R does, not the model

- Codes each candidate's design defaults from the returned JSON: format,
  number of options, fully or partly labelled, midpoint, don't-know option,
  reference period. Shown beside the PM's appraisal.
- Hides model names from the PM (candidates are A, B, C).
- Drops evaluation findings with severity below 5 into a collapsed
  "minor" list.
- Lays the chosen items out for Word and appends the disclosure block:
  models and versions, date, skill file versions, the prompt, which items were
  generated or revised with AI, and the line "Expert-review appraisal by a
  language model. Not a pretest."
