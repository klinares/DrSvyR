# QuestionR

A Shiny app that helps a public opinion analyst **draft survey items** and **review a
questionnaire**. Every model call is steered by plain text files grounded in survey
methodology (`www/skills/`); the expertise is in those files, not in the model. The app
assembles each prompt itself, so the same brief gives the same prompt, and every output says
what it is: a first draft, or an expert-review appraisal, by a language model. **It is not a
pretest.** It is a pilot: the Methodology tab says how the review step did on the one test it
has had, and what that test cannot show.

What it does, in four tabs after "Start here":

1. **Brief**: choose a task (an attitudinal scale, behavioral items, sensitive-topic items, or
   evaluate a pasted questionnaire) and describe what you need. **Build the instructions** goes
   straight on; **Check my brief first** asks a model whether the brief is complete.
2. **Prompt**: read the prompt the model will be sent (a short message: who it is told to be, your
   brief, the task and a few guidelines); approve it or edit it first. The survey design rules
   are sent with it every time and cannot be edited; they are on the Methodology tab.
3. **Results**: for drafting, the workers draft together and a project manager model reviews the
   drafts and recommends one item for each part of what you need. You see that set, with its
   concerns in three bands by severity, and edit any wording, remove an item, or swap in another
   model's draft ("See all drafts"). For a review, the findings question by question, in three
   bands by severity.
4. **Output**: the set as you left it, or the review, laid out to paste into Word, with a
   disclosure of the use of language models (it says which items you edited or swapped in), and
   a download of the run log.

## What is in this folder

| Path | What it is |
|---|---|
| `app.R` | The settings, the models, the packages check, the layout and the server |
| `R/` | The code, one job a file: `skills.R` reads the skill files and builds prompts; `llm.R` calls the models and holds the key box; `flow.R` runs a draft or a review step by step; `checks.R` checks and codes what a model sends back; `output.R` builds the Word output and the Methodology page; `ui.R` and `ui_generate.R` draw the tabs |
| `www/skills/` | The rule files. Plain text; see `www/skills/README.md` for the format |
| `www/start.md`, `www/methodology.md` | The Start here welcome and the Methodology tab's note, as markdown, with the pictures `www/how_it_works.svg` and `www/fw_*.svg` |
| `www/skills_materials/` | The list of the materials the skills were drawn from, and the one open-licensed paper; the rest stay with the maintainer and are never deployed |
| `www/logo/` | The office logo, if you add one |
| `tests/`, `DESIGN.md`, `STATUS.md`, `PROMPTS.md`, `REVIEW.md` | How it was built and tested, at home. Not needed to run it |

## Install and run

R packages (the app stops at start-up, naming any that is missing):

```r
install.packages(c("shiny", "bslib", "purrr", "stringr", "digest",
                   "ellmer", "httr2", "jsonlite", "rlang", "S7"))
```

It was built and tested with ellmer 0.4.2. From the folder that holds `QuestionR/`:

```r
shiny::runApp("QuestionR")
```

## Which models, and which keys

Everything an administrator may change is in `app.R`, section 1, each with a comment: the
classification banner, the logo, the size limits, `APP_DEFAULT_PROFILE`, and the profiles.

A **profile** is a project manager model and a list of worker models. `QUESTIONR_PROFILE`
(an environment variable) chooses one; when it is not set, `APP_DEFAULT_PROFILE` does.

| Profile | What it is |
|---|---|
| `home` | The project manager on Anthropic's own API with a key pasted into the app; three workers through OpenRouter, with the key in the server's environment (`OPENROUTER_API_KEY`) |
| `rehearsal` | All four models through OpenRouter in the OpenAI style, all on **one key pasted into the app**, as it will be at work. For trying the app before the move |
| `work` | The same shape with `<placeholders>` to fill in (below) |

A **key** is pasted into the box on Start here. It is held for that session only, in the R
process's memory; it is not saved, not put in the environment, and not written into any output
or the run log (the app takes it out of anything it shows or lets you download). A model whose
entry says `key_source = "server"` reads the environment variable named in its `key_var`
instead.

## Setting up at work

1. **Copy the `QuestionR/` folder** to the work machine.
2. **Delete** `tests/`, `DESIGN.md`, `STATUS.md`, `PROMPTS.md` and `REVIEW.md`. The app does not
   need them. Keep `www/` and `R/`.
3. **Fill in the `work` profile** in `app.R`, section 1. Each model is a list with:
   `api` (`"anthropic"` if the endpoint speaks Anthropic's API, `"openai"` if it speaks the
   OpenAI style; any model, the project manager too, may be either); `base_url` (the address
   up to and including `/v1`, as in the `home` profile; the app adds the rest); `id` (the model
   name exactly as the endpoint names it); and `key_source = "analyst"` (the key is pasted into
   the app). Add or delete worker entries freely. A fuller list of the options is the comment
   above `APP_PROFILES`.
4. **Set `APP_DEFAULT_PROFILE <- "work"`** (one line, just above the profiles).
5. **Logo and banner.** Put the logo in `www/logo/` and set `APP_LOGO` (the file name) and, if
   you want a name beside it, `APP_OFFICE`. Set `APP_CLASSIFICATION` to the marking that
   belongs above every screen.
6. **Say where to get a key.** `KEY_INSTRUCTIONS` in `R/llm.R` is four lines of general wording
   that Start here shows under "Where to get one" (ask the person who manages the AI service for
   your office; use a key issued to you). Replace them with your own instructions if you have them.
7. **Start the app** (`shiny::runApp("QuestionR")`). While anything in angle brackets is left,
   Start here lists the entries still to fill in and does not call that model.
8. **Paste the key** on Start here and press **Check connections**. It makes one very small call
   to each model and shows "Ready" or the endpoint's own words. If a model does not answer,
   the table below says what to change.
9. **Rehearse**: run the connection check, one small draft run, one short review, and paste the
   Output into Word, before anyone relies on it.

### What an error probably means

| Start here shows | Probably | What to change |
|---|---|---|
| "Waits for a key" | No key pasted (or the server variable is not set) | Paste the key, or set the variable named in `key_var` |
| "Not set up: base_url, id still hold a placeholder" | The work block is not filled in | `app.R`, section 1 |
| "The call to ... failed" | The address is not reachable or not right: a typo, a proxy, a certificate, no network | `base_url`; ask your network administrator whether the server can reach it. To check at work |
| "refused the request ... (HTTP 401)" or "403" | The key is wrong, expired or not allowed to use this model | The key; whoever issues it |
| "refused the request ... (HTTP 404)" | The model id, or the address, is wrong | `id`, or `base_url` |
| "refused the request ... (HTTP 400)" with a message about a parameter | The endpoint rejects something the app sends: for the OpenAI style, most often the name of the limit on the length of a reply | Add `max_tokens_name = "max_tokens"` to that entry (the default sends `max_completion_tokens`), or remove `reasoning_effort` from it if you set one |
| "refused the request ... (HTTP 429)" | The endpoint is limiting how fast you call it; the app tries again | Wait; ask for a higher limit |
| "answered with an empty reply" | The model returned nothing | Try again; try another model |
| "The reply is not what was asked for ..." (in a run, not the check) | The model's answer was not usable after three tries | Run again; for a worker, another model |
| "reached the token limit" | The answer was longer than the app allows for that step | Ask for fewer items; paste fewer questions |

## Posit Connect

What is verified in this repository, and what is not.

- **Verified here:** the app is a plain Shiny app directory (an `app.R` and the folders above, no
  package); `R/` is read by `app.R` itself; a model call runs inside the R process and the app is
  busy until it ends, which at home took one to two minutes for a draft run and about five minutes
  for a review of 30 questions; nothing the analyst pastes is saved on the server, and the run log
  and the output exist only for the session and the download. `.rscignore` lists the files that
  should not be published (`tests`, the design and status notes, this README).
- **From this repository's own notes, not verified here: to check at work.** Publishing with
  `rsconnect::deployApp("QuestionR", appName = "QuestionR")`; that Connect leaves out what
  `.rscignore` lists; that one connection per R process is the right setting while a call is
  running, and how many processes to allow.
- **To check at work:** whether Connect's own time limits (a request, an idle connection) are
  longer than the longest call (about two minutes for one 4,000-character part of a review, at
  home); how the server's environment variables, including `QUESTIONR_PROFILE`, are set; whether
  the server can reach your endpoint; whether the browser's copy button works there (if not,
  select the box on the Output tab and copy by hand: that always works).

## Adding a model, a task or a rule

- **A model.** Add a list to `workers` in a profile (or change `pm`), as in step 3 above. Nothing
  else changes: the tick boxes on the Brief tab, the connection check and the disclosure all read
  the profile.
- **A task.** Write a skill file in `www/skills/` (format in `www/skills/README.md`), add its name
  to `SKILL_FILES` in `R/skills.R`, and add one entry to `TASKS` in the same file: `label` (what
  the dropdown says), `kind` (`"draft"` or `"review"`), `files` (the skill files, in order),
  `ask` (the fixed sentence of the request) and `fields` (which form fields the Brief tab shows).
  The dropdown, the form, the prompt and the checklist read `TASKS`. A task that needs a reply in
  a new shape also needs an entry in `REPLY_SCHEMAS` in `R/checks.R`.
- **A rule.** Add a block to the right skill file: a `### id` line (lower case, underscores) and
  its `When`, `Say` and, if you want one, `Never`, `Check` and `Source` lines. A rule with a
  `Check` line becomes a question on the appraisal checklist (the Methodology tab is
  `www/methodology.md`, written by hand, so say there what you changed). A change to a rule changes every prompt built from it, and the Prompt tab shows the
  new hash.

## At home: the tests

From inside `QuestionR/`, with no model calls:

```
Rscript --no-init-file tests/smoke.R
Rscript --no-init-file tests/review.R 5
```

`tests/review.R` writes `REVIEW.md`, the evidence that goes back to the Claude project after each
phase. `tests/llm_check.R generate`, `review30` and `gold` make real calls and cost money; they
do nothing until they are named.
