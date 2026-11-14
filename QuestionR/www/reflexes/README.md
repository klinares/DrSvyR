# QuestionR reflexes

Text files that steer every model call in QuestionR. QuestionR is the AI tool; these files are its
AI reflexes. The expertise lives here, not in the model.

## Format (the parser is `R/reflexes.R`)

- `# Title` and a `Version:` line near the top.
- `## Persona` (core.md only): one paragraph. Its first sentence opens the message the analyst sees
  and can edit; the rest opens the system prompt.
- `## Guidelines`: an optional heading line, then one-line bullets. core.md's go into the message
  the analyst sees; a kind file's (attitudinal, behavioral, sensitive) are added after it for a
  draft. Never in the system prompt: the Reflexes are the rules, the Guidelines only remind.
- `## Reflexes`: one `### id` per reflex (lower case, underscores), each with one-line fields:
  - `- **When:**` the situation the rule applies to.
  - `- **Say:**` what to do.
  - `- **Never:**` optional, what not to do.
  - `- **Check:**` optional. A yes/no question; the Check lines in force are the CHECKLIST a
    review is given, and a flag must cite one of them.
  - `- **Label:**` optional, at most 6 words, the plain name of the fault the Check finds. Shown to
    the analyst (the bottom line, Criteria applied, the Methodology table). Never sent to a model.
  - `- **Applies:**` optional, a comma list from `attitudinal, behavioral, sensitive, any`. With
    none, a reflex of a kind file applies to that kind and any other reflex to any question.
  - `- **Source:**` optional. Shown on the Methodology page. Never sent to a model.
- `## Instrument checks` (evaluate.md only): reflexes in the same form, whose Check lines go only to
  the call that reviews the questionnaire as a whole.
- `## Prohibitions`: one bullet each.
- `## Output format`: the reply format, sent as written (generate.md, evaluate.md, refine.md).
- HTML comments are notes for people and are stripped before anything is sent.
- No real numbers or real survey items in examples. Use [placeholders].

## Which files go with which call

R assembles every prompt in a fixed order; no model writes one, so the same form gives the same
prompt. Blank form fields are left out, not guessed.

| Call | Files, in order | CHECKLIST |
|---|---|---|
| Write questions: draft (the drafter) | core, generate, the kind's file, mode | none |
| Write questions: refine (the main model) | core, refine, the kind's file, mode | Check lines of core, generate, the kind's file and mode, with the draft as JSON |
| Evaluate: a part | core, evaluate, the files of the kinds ticked, mode | every Check line in force but the instrument checks |
| Evaluate: the whole | the same | the instrument checks only |

`mode.md` is filtered before sending: `any_mode`, the reflexes for the modes chosen, and
`mixed_mode` when more than one is chosen. In a review the kind files bring only their reflexes
that have a Check line.
