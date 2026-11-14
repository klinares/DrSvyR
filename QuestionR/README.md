# QuestionR

A Shiny app that puts one language model in the role of an expert reviewer and item writer for a
public opinion analyst. It works on one part of Total Survey Error: measurement error that comes
from the questionnaire itself (wording, response options, order). Two jobs:

1. **Evaluate questions.** Paste questionnaire items with their response options. The page gives a
   bottom line, up to five questions to fix first (the question with the words at fault
   highlighted, one line per problem, and a rewrite), and a table of every question whose rows
   open to all its flags.
2. **Write questions.** Describe a construct; the model drafts 1 to 6 attitudinal, behavioral or
   sensitive items, then checks its own drafts against the same written criteria in a second call.

Every call is steered by plain text files, the AI reflexes (`www/reflexes/`). R assembles every
prompt from them, so the same form gives the same prompt. **It is not a pretest.**

## What is in this folder

| Path | What it is |
|---|---|
| `app.R` | The settings, the profiles, the packages check, the layout and the server |
| `R/` | `reflexes.R` reads the reflex files and builds prompts; `llm.R` calls the model and holds the key box; `flow.R` runs a review or a draft; `checks.R` checks replies, splits a questionnaire and builds the bottom line; `output.R` draws results for the page and for Word; `ui.R` and `ui_tasks.R` draw the tabs |
| `www/reflexes/` | The reflex files. Plain text; `www/reflexes/README.md` has the format |
| `www/start.md`, `www/methodology.md`, `www/*.svg` | Start here and the Methodology page, and their figures |
| `www/reflex_materials/` | The materials the reflexes were drawn from (not deployed) |
| `www/logo/` | The office logo, if you add one |
| `tests/`, `archive/`, `STATUS.md` | How it was built and tested, at home. Not needed to run it |

## Install and run

```r
install.packages(c("shiny", "bslib", "purrr", "stringr", "digest", "ellmer", "httr2",
                   "jsonlite", "rlang", "S7"))
shiny::runApp("QuestionR")
```

Built and tested with ellmer 0.4.2; the app stops at start-up, naming anything missing.

## The model and the key

Everything an administrator may change is in `app.R`, section 1: the classification banner, the
logo, the size limits, `APP_DEFAULT_PROFILE`, and `APP_PROFILES`. A profile is one model: `api`
(`"anthropic"` or `"openai"` for the OpenAI style), `base_url` (up to and including `/v1`) and `id`.
`QUESTIONR_PROFILE` (an environment variable) chooses a profile; when it is not set,
`APP_DEFAULT_PROFILE` does.

| Profile | What it is |
|---|---|
| `home` | `claude-sonnet-5-5` on Anthropic's API |
| `work` | `<placeholders>` to fill in at work |

The key is pasted into the box on Start here. It is held for that session only, in the R process's
memory: never saved, never read from the environment, and never written into the page, the Word
copy or the run log.

## Setting up at work

1. Copy the `QuestionR/` folder. `tests/`, `archive/` and `STATUS.md` can be left behind.
2. Fill in the `work` profile in `app.R` (`api`, `base_url`, `id`) and set
   `APP_DEFAULT_PROFILE <- "work"`. An endpoint that wants the older name for the reply limit
   takes `max_tokens_name = "max_tokens"`.
3. Set `APP_LOGO`, `APP_OFFICE` and `APP_CLASSIFICATION`; replace `KEY_INSTRUCTIONS` in `R/llm.R`
   with your own wording on where to get a key.
4. Start the app. While a placeholder is left, Settings and connection on Start here says which,
   and the model is not called.
5. Paste the key and press **Check the connection**: one very small call, "Ready" or the
   endpoint's own words.
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
`tests/`, `archive/`, `STATUS.md`, this README and `www/reflex_materials/` out. A review sends its
parts four at a time inside the one R process, which is busy until they finish. To check at work:
Connect's time limits against the longest call, whether the server reaches the endpoint, and
whether the browser's Copy for Word works there.

## Adding a rule

Add a `### id` block to a reflex file with its `When`, `Say` and, if wanted, `Never`, `Check`,
`Label`, `Applies` and `Source` lines (`www/reflexes/README.md`). A rule with a `Check` line is on
the checklist a review cites. The reflex files are checksummed in `tests/smoke.R`, so a change
there is deliberate; the Methodology table reads them as they are.

## At home: the tests

From inside `QuestionR/`, with no model calls: `Rscript --no-init-file tests/smoke.R`.
`tests/llm_check.R example`, `review30` and `gold` make real calls and cost money; they do nothing
until one is named.
