# ai_skills

Shared instructions for AI coding assistants working on survey and
data-science projects in R. The same folders are read by inteRn (the RStudio
intern in `../inteRn`), by Claude Code, and by any agent that understands the
`SKILL.md` format. Write once, use everywhere.

## Skills

| Skill | Use it for | Scripts |
|---|---|---|
| [`tidyverse-style`](tidyverse-style/SKILL.md) | Writing, reviewing or refactoring any R code: tidyverse/tidymodels idioms, purrr instead of loops, reproducible pipelines | -- |
| [`dataviz`](dataviz/SKILL.md) | Any figure: chart choice from graphical perception, data-ink, colourblind-safe palettes, survey estimates with intervals | `theme_intern.R`, `palette_check.R` |
| [`survey-design`](survey-design/SKILL.md) | Weights, strata, PSUs, FPC, replicate weights, design-based estimation, TSE/TEF | `design_check.R` |
| [`codebook`](codebook/SKILL.md) | A validated data-dict.yaml and a Quarto codebook: local profile, suppressed aggregates to the model, analyst review, `data-dict validate-data` | `codebook.R` (+ `templates/codebook.qmd`) |

[`reflexes.md`](reflexes.md) is a dated log of lessons learned, one line per
lesson, appended (never rewritten) with `/reflex add <text>` in inteRn or by
hand. inteRn puts the latest entries in its instructions.

## Format

```
<skill-name>/
  SKILL.md        frontmatter + instructions (required)
  references/     longer notes the agent reads on demand (optional)
  scripts/        R the agent can source and run (optional)
```

`SKILL.md` starts with YAML frontmatter, one `key: value` per line:

```yaml
---
name: skill-name            # lower case, digits, hyphens; same as the folder
description: What the skill covers and when to use it, in one or two sentences.
when_to_use: The requests or situations that should trigger it.
---
```

The body is markdown: rules first, then detail. HTML comments are notes for
people and are stripped before an agent reads the file.

## Writing a skill

- General guidance for anyone on the team, not personal notes, paths or names.
- Rules an agent can follow and a reviewer can check ("bar axes start at
  zero"), with the reason when it is not obvious.
- Keep `SKILL.md` short enough to read every time; move long material to
  `references/`.
- Scripts hold functions only (no top-level calls), use `pkg::fn()` so nothing
  needs attaching, use no loops, and must run on public data
  (`palmerpenguins`, `survey::api`). Test them with
  `Rscript --no-init-file inteRn/tests/skills_check.R`.
- Never put microdata, keys or personal paths in a skill.

## How agents load them

- **inteRn** lists every skill's name, description and `when_to_use` in its
  system prompt and loads a body on demand (`load_skill`). Scripts are sourced
  with `intern_source_skill("<skill>", "<script>.R")`. The folder is
  `skills_dir` in `inteRn/config.R` (default: this folder).
- **Claude Code** reads skills from `.claude/skills/<name>/SKILL.md`. Point it
  here with a link rather than a copy, so there is one source of truth, e.g.
  on Windows from the repository root:
  `mklink /J .claude\skills ai_skills` (or a symbolic link on macOS/Linux:
  `ln -s ../ai_skills .claude/skills`).
