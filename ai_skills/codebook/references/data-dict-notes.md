# data-dict: notes for the codebook skill

Summarised from the spec (https://data-dict.tidyverse.org/spec.html, spec
0.1.0) and the CLI's help (data-dict 0.0.3). `data-dict spec` prints the full
spec; `data-dict skill-create` and `data-dict skill-read` print the CLI's own
agent skills, which this skill follows.

## Install

- R (no PATH change): `pak::pak("tidyverse/data-dict/r")`, then
  `datadict::dd_install()`. The binary goes to
  `tools::R_user_dir("datadict", "cache")`; `datadict::dd_path()` finds it.
- Or `uv tool install data-dict-yaml` / `pipx install data-dict-yaml`, or the
  installer script from the GitHub releases (adds itself to PATH).

## File shape

```yaml
$version: 0.1.0                       # required
$learn_more: https://data-dict.tidyverse.org/
name: penguins
label: Palmer penguins
description: >
  One row per penguin ...
todo: |                               # open questions; each is a warning
  - ...
tables:                               # a list
  - name: penguins
    source:
      parquet: penguins.parquet       # relative to the yaml
    columns:                          # a list
      - name: species
        label: Species
        type: enum
        values: [Adelie, Chinstrap, Gentoo]   # or a map {code: label}; strings
        description: ...
      - name: body_mass_g
        type: number(quantity)
        units: g
        range: [2700, 6300]           # inclusive; .inf / -.inf for open ends
      - name: id
        type: number(id)
        constraints: [primary_key]    # primary_key implies required + unique
        examples: [101, 102, 103]
```

## Types and what they require

| type | requires | notes |
|---|---|---|
| `number` | `examples` (or `range`) | integers and doubles alike |
| `number(id)` | `examples` | codes and identifiers |
| `number(ordinal)` | `range` | ordered scales |
| `number(quantity)` | `range`; `units` allowed | measurements, counts, money |
| `string` | `examples` | free text, names |
| `enum` | `values` | every category; values are strings |
| `boolean`, `date`, `datetime` | `range` for dates; `time_zone` for datetime | |
| `list(...)`, `struct` | `fields` for struct | nested data |

Other column keys: `label`, `description`, `details`, `constraints`
(`required`, `unique`, `primary_key`, `foreign_key`, or `assert:` maps),
`display: restricted` (sensitive; excluded from user-facing output), `todo`.

## CLI

| command | does | reads data? |
|---|---|---|
| `draft <files.parquet>` | writes a starting data-dict.yaml: types, observed ranges and examples, todos | yes, locally |
| `describe <file> [col]` | per-column summary | yes, locally |
| `validate-spec [dict]` | is the YAML a valid dictionary? | no |
| `validate-meta [dict]` | do column names and types match? | metadata only |
| `validate-data [dict]` | do values match (types, enums, ranges, constraints)? | yes |
| `render [dict]` | self-contained HTML dictionary | optional |
| `export-spec`, `export-data` | JSON | |

Validation flags: `--json` (a report with `status` pass/warning/error,
`steps`, `problems` with `code`, `severity`, `message`, `location`),
`--html <file>`, `--table <name>`. Errors fail a pipeline; warnings (such as
an unresolved `todo`, code S31) do not.

## Privacy

`draft` puts real values into `examples` and `range`. They stay in the local
file, but:

- they are stripped before anything is sent to a model
  (`redact_dictionary()`);
- for `display: restricted` columns they are replaced with placeholders
  ("REDACTED-1", or 1, 2, 3), because real values must never appear in a
  shared dictionary;
- for ranges on restricted quantities, coarsen or remove them by hand before
  sharing.
