# QuestionR

A Shiny app that helps a public opinion analyst draft survey items and review a
questionnaire. Every model call is steered by text files grounded in survey
methodology (`www/skills/`), and every output says it is a first draft or an
expert-review appraisal by a language model, not a pretest.

`DESIGN.md` says what it does and how it is built in phases; `STATUS.md` says
where it stands.

## Run

From the repository root:

```r
shiny::runApp("QuestionR")
```

`QUESTIONR_PROFILE` chooses the models: `home` (the default) or `work`. The
profiles are the list at the top of `app.R`.

## Keys

The project manager model's key is pasted into the box on Start here. It is held
for the session only and never read from the environment. At home the three
worker models go through OpenRouter and read `OPENROUTER_API_KEY` from the
server's environment (`.Renviron` at home).

## Packages

shiny, bslib, purrr, stringr, digest. Later phases add ellmer and jsonlite.

## Test

From inside `QuestionR/`, with no API calls:

```
Rscript --no-init-file tests/smoke.R
Rscript --no-init-file tests/review.R <phase>
```

`tests/` is home only and is deleted at work. `tests/review.R` writes
`REVIEW.md`, the evidence that goes back to the Claude project after each phase.
