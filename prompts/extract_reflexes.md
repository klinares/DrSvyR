# Extract reporting style from example reports

A prompt for turning published reports into reporting-style rules and examples
for `svysegment/www/ai_reflexes.md`, without storing the reports anywhere in
this repository.

**How to use it.** Open a chat with Claude, attach the report PDFs, and paste
everything below the line. Paste the current `ai_reflexes.md` where the prompt
says so. Review what comes back, then copy the parts you keep into
`ai_reflexes.md`: bullets under `## Reporting style`, pairs under
`### Examples`. The app reads the file on its next request.

---

You are helping a survey methodologist write instructions for a language model
that drafts the text of a survey segmentation report (latent class analysis on
complex survey data, with design-based estimates and 95 percent intervals).

The attached reports are examples of how results like these are written up.
Read them **only for how the results are written**: sentence patterns, how
estimates, intervals and comparisons are worded, how segments are described,
how limits are stated. Ignore what they found.

Below is the current instructions file. Your output will be added to its
"Reporting style" section.

```
[PASTE THE CURRENT ai_reflexes.md HERE]
```

Return exactly three parts, in markdown, and nothing else.

**1. Style bullets.** At most 8 bullets, one line each, in the same form as
the existing "Reporting style" bullets. Include only patterns that appear in
more than one place in the reports and that the existing file does not
already say.

**2. Examples.** At most 6 pairs, each in this exact form:

    **[What the example is about]**

    - Write: "[a sentence in the reports' style]"
    - Avoid: "[the version a careless writer would produce]" (why, in a few words)

**3. Left out.** A short list of any pattern in the reports that contradicts
the existing file, with the rule it breaks (for example, calling a result
"significant", causal wording, judging differences by overlapping intervals,
quoting a point estimate without its interval).

Rules for your output:

- Replace every number, percentage, segment name, group, country, survey name
  and question with a placeholder in square brackets: [share], [lower],
  [upper], [Segment name], [level A], [question], [answer]. No digits may
  appear anywhere in parts 1 and 2.
- Write the examples in your own words, in the reports' style. Do not copy
  sentences from the reports, and quote no more than a few words.
- Keep within the existing file's rules: figures only from the evidence, no
  causal language, no "significant", unresolved differences are "not
  separated" rather than "equal", members described by what they are more
  likely to say.
- Do not add reflexes, prohibitions or new sections.
