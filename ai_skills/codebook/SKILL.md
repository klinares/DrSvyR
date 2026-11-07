---
name: codebook
description: Document a dataset as a validated data-dict.yaml and a Quarto codebook/EDA report -- profiled locally, described from suppressed aggregates only, reviewed by the analyst, validated with the data-dict CLI. Use when asked for a codebook, data dictionary, variable documentation or a first look at a dataset.
when_to_use: Writing or updating a codebook or data dictionary; documenting variables, labels, codes and units; preparing data for sharing or archiving; an initial exploratory report on a new dataset.
---

# Codebook and data dictionary

A codebook is only as good as what its author knows. The meaning, units,
codes and quirks of a dataset live with the people who produced it, not in
the column names. So this is an interview, not a transcription: describe what
the evidence supports, and turn everything else into a question (`todo`) for
the analyst. A confident invented description is worse than an open question.

The dictionary follows the tidyverse data-dict spec
(https://data-dict.tidyverse.org/spec.html; `data-dict spec` prints it).
Notes on the spec and the CLI: `references/data-dict-notes.md`.
Functions for every step: `scripts/codebook.R`. Report template:
`templates/codebook.qmd`.

## Privacy: what may leave the session

Microdata never goes to a language model. Only these do:

- column names, types, variable labels, value labels, factor levels;
- aggregates as plain text (`profile_text()`), with every count below the
  suppression threshold (default 10) shown as "<10", one more cell hidden
  where needed so it cannot be recovered from the total, min and max never
  shown, and rare free-text values hidden entirely;
- the `data-dict draft` skeleton with its `examples`, `range` and `source`
  removed (`redact_dictionary()`).

`codebook_draft()` writes exactly what it sent to `sent_to_model.txt` beside
the dictionary, so anyone can audit it.

## Steps

1. **Profile locally** -- `codebook_profile(data, suppress_n)`. Look for
   survey missing-value codes (8/9, 98/99, -1) still stored as numbers,
   labelled variables, free-text columns and identifiers.
2. **Draft** -- `codebook_draft(data, dir, table, describe = <model function>,
   context = "<what the analyst told you>")`. It runs `data-dict draft`
   locally, sends the redacted draft and the suppressed profile to the model,
   and merges the proposal back locally: labels, descriptions, enum values
   (accepted only if they match the data exactly), units, `display:
   restricted` for anything that could identify a person (with real examples
   replaced by placeholders), and `todo` questions. With `describe = NULL` it
   stops after the local draft and you write the descriptions yourself.
3. **Review with the analyst** -- go through every `todo` in
   `data-dict.yaml`. Resolve a todo only with an answer; never delete one by
   guessing. Ask concrete questions ("`income` looks like annual household
   income in dollars -- right?").
4. **Validate** -- `dd_validate(dir)` runs `data-dict validate-data` and
   returns the status and a table of problems. Fix errors; open todos remain
   as warnings until answered.
5. **Render** -- `codebook_render(dir, title = "...")` copies the template and
   the dataviz theme next to the dictionary and renders an HTML codebook:
   variable table, missingness, a chart per variable, open questions. It
   follows the dataviz skill and applies the same suppression.

## Rules for descriptions

- Say what one row is, the population, the source and the period.
- For each column: what it measures, in the units given; how missing and
  special codes are stored; whether it is derived, and from what.
- Use `enum` only when every category is known; keep value labels and the
  codes they stand for (record codes in `details`).
- Survey design variables (weights, strata, PSUs, replicate weights) are
  documented as such, with how to use them (see the survey-design skill).
- Never write a number in a description that is not in the evidence.
- Mark identifiers, names, contact details and precise locations
  `display: restricted`.

## In inteRn

```r
intern_source_skill("codebook", "codebook.R")
dir <- codebook_draft(my_data, "codebook", table = "my_data",
                      describe = intern_complete,
                      context = "One row per respondent, wave 3, 2024.")
dd_validate("codebook")$status
codebook_render("codebook", title = "My survey, wave 3")
```

inteRn's `read_file` shows a data-dict.yaml with its examples and ranges
removed, and `write_file` will not overwrite one: edit it by hand or re-run
`codebook_draft()`.
