# QuestionR

What goes to work is `app.R`, `R/` and `www/` without the PDFs in `www/reflex_materials/`.

A Shiny app that puts language models in the role of an expert reviewer and item writer for a
public opinion analyst. It works on one part of Total Survey Error: measurement error that comes
from the questionnaire itself (wording, response options, order). Two jobs:

1. **Evaluate questions.** Paste questionnaire items with their response options. The page gives a
   bottom line of two lines at most, then one row per question in the order pasted, with a chip
   (Fix, Consider, None found). A question to fix opens on one short summary and the suggested
   wording, laid out as it is asked; the original with the words at fault highlighted, the flags
   and the programming text are behind a closed Details.
2. **Write questions.** Describe a construct; one model (the drafter) drafts 1 to 10 attitudinal,
   behavioral or sensitive items, and the main model edits them against the written criteria. The
   page shows only the final questions, in boxes that can be edited; what the editor changed and
   the criteria it applied are behind a closed Details. Two calls a run.

Every call is steered by plain text files, the AI reflexes (`www/reflexes/`). R assembles every
prompt from them, so the same form gives the same prompt. **It is not a pretest.**

## What is in this folder

| Path | What it is |
|---|---|
| `app.R` | The settings, the profiles, the packages check, the layout and the server |
| `R/` | `reflexes.R` reads the reflex files and builds prompts; `llm.R` calls the models and holds the key box; `review.R` checks replies, splits a questionnaire, builds the bottom line and runs a review or a Write run; `ui.R` draws the tabs, the results and the Word copy |
| `www/reflexes/` | The reflex files. Plain text; `www/reflexes/README.md` has the format |
| `www/start.md`, `www/methodology.md`, `www/gold_summary.md`, `www/*.svg` | Start here and the Methodology page (its test paragraph is written by `tests/gold_test.R`), and their figures |
| `www/reflex_materials/` | The materials the reflexes were drawn from: the PDFs (not deployed), a markdown copy of each (deployed, linked from Methodology) and `sources.csv` |
| `www/logo/` | The office logo, if you add one |
| `tests/` | The tests, at home. Not needed to run it |

## Install and run

```r
install.packages(c("shiny", "bslib", "purrr", "stringr", "digest", "ellmer", "httr2",
                   "jsonlite", "rlang", "S7"))
shiny::runApp("QuestionR")
```

Built and tested with ellmer 0.4.2; the app stops at start-up, naming anything missing.

## The model and the key

Everything an administrator may change is in `app.R`, section 1: the classification banner, the
logo, the size limits, `APP_DEFAULT_PROFILE`, and `APP_PROFILES`. A profile is the main model (the
reviewer, and the editor of Write questions) and an optional `drafter`; each has `api` (`"anthropic"`
or `"openai"` for the OpenAI style), `base_url` (up to and including `/v1`) and `id`. Without a
drafter the main model drafts.
`QUESTIONR_PROFILE` (an environment variable) chooses a profile; when it is not set,
`APP_DEFAULT_PROFILE` does.

| Profile | What it is |
|---|---|
| `home` | main `claude-sonnet-5-5`, drafter `claude-sonnet-4-5`, both on Anthropic's API |
| `work` | `<placeholders>` for both, to fill in at work |

Both models use the one pasted key. At work the limit is the number of calls (300 every 4 hours):
a review of 30 questions is 5 calls, a Write run 2, and a failed reply is tried up to 3 times.

The key is pasted into the box on Start here. It is held for that session only, in the R process's
memory: never saved, never read from the environment, and never written into the page, the Word
copy or the run log.

## Setting up at work

1. Copy the `QuestionR/` folder. `tests/` can be left behind.
2. Fill in the `work` profile in `app.R` (`api`, `base_url`, `id`, for the main model and the
   drafter) and set
   `APP_DEFAULT_PROFILE <- "work"`. An endpoint that wants the older name for the reply limit
   takes `max_tokens_name = "max_tokens"`.
3. Set `APP_LOGO`, `APP_OFFICE` and `APP_CLASSIFICATION`; replace `KEY_INSTRUCTIONS` in `R/llm.R`
   with your own wording on where to get a key.
4. Start the app. While a placeholder is left, Settings and connection on Start here says which,
   and the model is not called.
5. Paste the key and press **Check the connection**: one very small call to each model, "Ready"
   or the endpoint's own words.
6. Rehearse: one short review and one Write questions run, and paste each into Word.

| Start here shows | Probably | What to change |
|---|---|---|
| "Waits for a key" | No key pasted | Paste the key |
| "Not set up: base_url, id ..." | The work profile is not filled in | `app.R`, section 1 |
| "The call to ... failed" | The address is not reachable | `base_url`; the network |
| "refused the request ... (HTTP 401)" or "403" | The key is wrong or not allowed this model | The key |
| "refused the request ... (HTTP 404)" | The model id or the address is wrong | `id`, `base_url` |
| "refused the request ... (HTTP 400)" about a parameter | The endpoint rejects the name of the reply limit | `max_tokens_name = "max_tokens"` |
| "refused the request ... (HTTP 429)" | Rate limit; the app tries again | Wait |
| "reached the token limit" | The reply was longer than the app allows | Fewer items; fewer questions |

## Posit Connect

Publish with `rsconnect::deployApp("QuestionR", appName = "QuestionR")`; `.rscignore` keeps
`tests/` and this README out, and `www/reflex_materials/.rscignore` the PDFs. A review sends its
parts four at a time inside the one R process, which is busy until they finish.

## Known limits

- It is not a pretest. Every flag and rewrite is a model's reading against written criteria, and
  a methodologist decides which flags need a revision.
- Flags vary from run to run. On the 27 gold items (20 with a known fault, 7 controls), the last
  run gave 3.0 fix flags per flawed item and 0.29 per control item (one control item had two), and
  about 2 points to consider per control item.
- A review is 8 questions a call, four calls at a time, then one call on the whole questionnaire
  (30 questions: 5 calls, about 2 minutes). A question's own call sees only its part; the call on
  the whole sees every question, for routing, order and scales.
- A reply that is not what was asked for (no JSON, a check not sent, a summary over 45 words, a fix
  flag with no rewrite) is tried again, up to 3 attempts; a session stops after 10 repeat
  attempts. The reason for each refused attempt is in the run log.
- A flag whose quoted words are not in the question is shown with "quote not found in your text",
  never dropped.
- Text in square brackets or capitals addressed to the programmer is not reviewed as wording; the
  model returns it under Details.
- The reply ceilings (in `R/llm.R`) leave room for the model's reasoning: 24,000 tokens for a part,
  8,000 for the whole, 16,000 for a draft and 24,000 for an edit.

## To check at work

- The `work` profile: the endpoint's `base_url`, the main model's and the drafter's ids, and
  whether it wants `max_tokens_name = "max_tokens"`.
- The call budget: 300 calls every 4 hours (a review of 30 questions is 5 calls, a Write run 2,
  plus any repeat attempts).
- Posit Connect: its time limits against the longest call (a part can take a minute or more), and
  whether the server reaches the endpoint.
- Copy for Word in a real browser at work, with and without "Include details", pasted into Word.

## Adding a rule

Add a `### id` block to a reflex file with its `When`, `Say` and, if wanted, `Never`, `Check`,
`Label`, `Applies` and `Source` lines (`www/reflexes/README.md`). A rule with a `Check` line is on
the checklist a review cites. The reflex files are checksummed in `tests/smoke.R`, so a change
there is deliberate; the Methodology page lists them as they are.

## At home: the tests

From inside `QuestionR/`, with no model calls: `Rscript --no-init-file tests/smoke.R`.
`tests/llm_check.R review30` (with an optional model id) makes real calls; it does nothing until
review30 is named.

`tests/gold_test.R` is the 20-question test, at home or at work: it reviews the 27 test questions
(27 calls), asks the main model in a separate chat which flag matches which planted fault (20
calls), and writes `www/gold_summary.md` (the paragraph on the Methodology page) and a `summary.md`
in a new folder in `tests/gold_runs/`. Set `PROFILE` at its top. To correct the matching by hand:
edit `match` in that folder's `matches.csv`, put a name in `checked_by`, set `RUN_REVIEWS` and
`RUN_MATCHING` to `FALSE` and run it again; it rebuilds both files with no calls.
