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
- `## Output format`: the reply format, sent as written (codebook.md, suggest.md).
- HTML comments are notes for people and are stripped before anything is sent.
- No real data values in examples. Use [placeholders].

## Which files go with which call

R assembles every prompt in a fixed order; no model writes one, so the same file, codebook and
question give the same prompt.

| Call | Reflexes in the system prompt | R adds, in the user message |
|---|---|---|
| `label` (Codebook tab) | codebook | the DATA block (file name and every column's facts), codebook.md's reply format |
| `suggest` (Explore tab) | core, comparison, relationship, distribution, time, suggest, refine | the DATA block, the analyst's question, suggest.md's reply format |
| `refine` (the chat) | the same seven, so the system prompt is identical and is read from the cache | the DATA block (the index, and detail for the chart's own columns), the current spec, R's notes, the last exchange, the analyst's message, refine.md's reply format |

After the reflexes and prohibitions, the system prompt of `suggest` and `refine` ends with the
SPEC REFERENCE, written by R from `R/spec.R`.

The files for `summarize` (headlines and summaries) and `interactive` come in later phases.
