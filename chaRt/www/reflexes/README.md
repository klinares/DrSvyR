# chaRt reflexes

Text files that steer every model call in chaRt. chaRt is the AI tool; these files are its AI
reflexes. The expertise lives here, not in the model. They are drafted in the Claude project from
the SURV752 and SURV727 course materials, not by Claude Code, and the smoke test holds their
checksums, so an edit that was not meant shows up.

## Format (the parser is `R/reflexes.R`)

- `# Title` and a `Version:` line near the top.
- `## Persona`: one paragraph. The first file of a call supplies it.
- `## Reflexes`: one `### id` per reflex (lower case, underscores), each with one-line fields:
  - `- **When:**` the situation the rule applies to.
  - `- **Say:**` what to do.
  - `- **Never:**` optional, what not to do.
  - `- **Label:**` optional, at most 6 words: the plain name of the rule. Shown to the analyst
    under a chart (the spec's `rule` field names a reflex) and on the Methodology page. Never sent.
  - `- **Source:**` where the rule comes from. Shown on the Methodology page. Never sent. A rule
    that is not from the course materials says so.
- `## Prohibitions`: one bullet each.
- `## Output format`: the reply format, sent as written (codebook.md, chat.md, summary.md).
- HTML comments are notes for people and are stripped before anything is sent.
- No real data values in examples. Use [placeholders].

## Which files go with which call

R assembles every prompt in a fixed order; no model writes one, so the same file, codebook and
question give the same prompt.

| Call | Reflexes in the system prompt | R adds, in the user message |
|---|---|---|
| `label` (a button) | codebook | the DATA block (file name and every column's facts), codebook.md's reply format |
| `chat` (every message the analyst types) | core, comparison, relationship, distribution, time, suggest, refine, chat | the DATA block, the CANVAS (each chart's id, title, family and columns), the SELECTED chart's spec and notes or "none", the last exchange, the analyst's message, chat.md's reply format |
| `summarize` (a button) | summary | the CHARTS block (each chart's id, title, row and facts), summary.md's reply format |

After the reflexes and prohibitions, the system prompt of `chat` ends with the SPEC REFERENCE,
written by R from `R/spec.R`. It is the same for every turn, so it is read from the cache.

suggest.md and refine.md hold rules only; the one reply format for a chat turn is in chat.md.
