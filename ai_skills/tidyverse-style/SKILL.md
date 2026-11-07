---
name: tidyverse-style
description: How R code is written in survey and data-science projects -- tidyverse and tidymodels idioms, purrr instead of loops, functional and reproducible pipelines. Use whenever writing, reviewing or refactoring R code.
when_to_use: Any request that produces or changes R code, a Quarto chunk, or an R script; code review; turning a loop or base-R script into tidyverse style.
---

# tidyverse style

Code is read far more often than it is written, usually by someone checking
an estimate months later. These rules make it predictable to read and safe to
re-run. Worked good/bad pairs are in `references/examples.md`.

## Non-negotiable

1. **No `for`, `while` or `repeat` loops.** Iterate with purrr:
   `map()` and its typed forms (`map_dbl()`, `map_chr()`, `map_lgl()`,
   `map_int()`), `map2()`, `pmap()`, `imap()` for index or name, `walk()` for
   side effects (writing files, printing), `reduce()` / `accumulate()` for
   running state, `keep()` / `discard()` / `detect()` for filtering lists.
   Prefer a vectorised function or a grouped `summarise()` over any iteration.
2. **Native pipe `|>`**, one step per line, the verb first. A pipeline longer
   than about ten steps is split into named intermediate objects or functions.
3. **No side effects at the top of a script that break re-running:** no
   `setwd()`, no `rm(list = ls())`, no `install.packages()`, no absolute
   paths. Paths are built with `here::here()` or are relative to the project.
4. **Never invent a function or an argument.** If unsure whether
   `pkg::fn(arg = )` exists, check `?fn` or `args(pkg::fn)`, or say so.

## Shape of the code

- **Data frames in, data frames out.** Use tibbles. Keep data tidy: one row
  per unit of observation, one column per variable. Reshape with
  `pivot_longer()` / `pivot_wider()`, not `reshape()` or `melt()`.
- **dplyr verbs** over base subsetting: `filter()`, `select()`, `mutate()`,
  `summarise()` with `.by =` (or `group_by()` ... `ungroup()`), `arrange()`,
  `count()`, the `*_join()` family with an explicit `by = join_by(...)`.
- **Recoding**: `case_when()` for conditions, `recode_values()` for mapping
  codes to values (dplyr >= 1.2; `case_match()` is deprecated there, use it
  only on older dplyr), `if_else()` for two cases -- never nested `ifelse()`.
  `recode_values(x, ..., unmatched = "error")` stops on a code you did not
  list, which catches undocumented survey codes.
- **Factors** through forcats (`fct_recode()`, `fct_relevel()`,
  `fct_lump_n()`); keep value labels from haven until you deliberately convert
  with `haven::as_factor()`.
- **Many columns at once**: `across()` with tidyselect helpers
  (`where(is.numeric)`, `starts_with("q")`), not copy-pasted lines.
- **Missing values** are explicit: say how each `NA` is handled
  (`na.rm = TRUE`, `drop_na()`, `replace_na()`), and never let a survey's
  "don't know" or "refused" codes (e.g. 8, 9, 98, 99) pass silently as numbers.
  Convert them to `NA` or to a labelled level on purpose.
- **Strings** with stringr (`str_detect()`, `str_replace()`), dates with
  lubridate.
- **Functions** for anything done twice. Small, named for what they return,
  arguments explicit, no reliance on global objects. Validate inputs early
  with `stopifnot()` or `rlang::abort()` and a readable message. Use
  `{{ }}` (embracing) for column arguments.
- **Modelling** with tidymodels where it fits (recipes, parsnip, workflows,
  rsample, yardstick, `broom::tidy()` for results). For survey models use
  the survey or srvyr design (see the survey-design skill), then `broom::tidy()`.

## Naming and layout

- `snake_case` for objects and functions; nouns for data, verbs for functions.
- Two-space indentation, a space after commas and around `=` / `<-` / `|>`,
  lines under about 80 characters.
- Comment *why*, not *what*. Section headers with `# ---- name ----`.
- In Quarto, one idea per chunk, chunk labels (`#| label: fit-model`), and
  `#| echo: false` only for chunks the reader truly does not need to see.

## Reproducibility

- Load packages once at the top with `library()`; in reusable code call
  `pkg::fn()` instead.
- `set.seed()` before anything random, with the seed visible.
- Record the session (`sessionInfo()` or `renv`) in reports.
- Code that has not been run is marked `# UNTESTED` on its first line.
