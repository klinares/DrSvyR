# QuestionR: design

One of the apps in the DrSvyR repository. A Shiny app that helps a public
opinion analyst draft survey items and review a questionnaire, with every model
call steered by text files grounded in survey methodology.

Status and the next task are in `STATUS.md`. The root `CLAUDE.md` hard rules
apply here in full (tidyverse, no `for`/`while`, no parallelism, no package
scaffolding, `R/` holds function definitions only, assets in `www/` or
`data/`). Where this file and the root `CLAUDE.md` disagree, `CLAUDE.md` wins.

Decisions marked **(Kevin)** were made by Kevin. Items marked **VERIFY** are
assumptions to check against installed help or a real run before relying on
them; do not invent functions or arguments.


## 1. Goals, in priority order

1. **Grounded.** What a model is told, and what its output is checked against,
   comes from `www/reflexes/*.md`, each rule traced to a source. The expertise
   is in those files, not in the model.
2. **Repeatable.** The same form produces the same prompt, character for
   character. R assembles the prompt; no model writes it. **(Kevin)**
3. **The analyst decides.** The project manager model appraises and compares.
   It never picks a winner and never calls anything validated. **(Kevin)**
4. **Honest about what it is.** Every output says it is an expert-review
   appraisal or a first draft by a language model, not a pretest, and carries
   a disclosure block (models, date, reflex versions, prompt).
5. **Works at work.** Same banner, logo, Cairo setting and key handling as
   `svysegment`. One pasted key at work.
6. **Small.** At most 8 code files (section 3).
7. **Checkable.** The app is built by a cheaper model (Sonnet 5.5 in Claude
   Code). After every phase a script, not the builder, writes the evidence
   that goes back to the Claude project for review (section 9).

Not goals: retrieval or a vector store; translation as a finished product;
simulated respondents or synthetic cognitive interviews (possible later);
saving anything an analyst pastes.


## 2. What the app does

Four tasks, chosen from a dropdown **(Kevin)**:

| Task | Workers | Project manager |
|---|---|---|
| Attitudinal scale | each worker model drafts | brief check, then appraisal |
| Behavioral items | each worker model drafts | brief check, then appraisal |
| Sensitive topic items | each worker model drafts | brief check, then appraisal |
| Evaluate questionnaire (pasted text) | none | brief check, then the review itself |

Several models are used for drafting because models and prompts produce
different design choices. Evaluation uses one model and one fixed checklist,
because open-weight models flag far more problems on sound items. No worker
is from the project manager's model family, so the appraiser never judges
its own family's draft.

### Tabs

| Tab | What it holds | Model call |
|---|---|---|
| Start here | What the app is and is not, settings in force, key box | no |
| 1. Brief | Task dropdown and the form | PM: brief check |
| 2. Prompt | The assembled prompt, editable, with Approve | no |
| 3. Results | Generate: candidates side by side, coded defaults, appraisal. Evaluate: findings table | workers, then PM |
| 4. Output | Chosen items laid out for Word, disclosure block, run log download | no |
| Methodology | The note, the reflexes as readable text, sources per rule | no |

### The form (tab 1)

Research question (required); construct, in a sentence; task; target
population; country; survey mode, one or more of web, mobile web, telephone,
face-to-face, paper; output language (default English); source language
(default English); number of items (generate tasks); reference period and
unit (behavioral); existing items to keep; other details; for Evaluate, the
pasted questionnaire. Blank fields are left out of the prompt, never guessed.

### The flow

1. **Brief check.** PM receives `core`, `pm_brief`, the task file and the
   form. Returns what is missing (at most five questions, blocking or
   optional) and the criteria that will be applied, in plain words. The
   analyst answers in the form or proceeds.
2. **Prompt.** R assembles the prompt (section 5) and shows it. The analyst
   approves it or edits it. An edited prompt is marked `edited` in the log
   with both hashes.
3. **Run.** Generate: each worker gets the same approved prompt, one after
   another. R validates each reply, codes its design defaults, and relabels
   the candidates A, B, C in an order shuffled with a seed stored in the log,
   so the PM does not know which model wrote which. Then the PM appraises
   (`pm_appraise`). Evaluate: the PM runs the review once.
4. **Results.** Generate: per candidate, the items, R's coded defaults, and
   the PM's pass, fail or not-applicable per check with the failing words.
   Below: coverage by domain, how the candidates differ, the merged option
   (labelled as a fourth, untested option), what to test first. The analyst
   ticks the items to keep, from any candidate. Evaluate: findings at
   severity 5 and above shown, the rest collapsed; instrument-level findings;
   the TRAPD block; what to test first.
5. **Again.** "Run again" returns to tab 1 with the form kept and a "what to
   change" box. Its text is added to the prompt as a labelled REVISION block.
   Each round is a new entry in the run log.
6. **Output.** The kept items (or the review) formatted for Word, then the
   disclosure block.


## 3. Folder and file budget

```
QuestionR/
  app.R                 settings, library(), sources R/, state, ui, server
  R/
    _disable_autoload.R
    llm.R               profile, key, one call function for both API styles,
                        JSON parse and repair, retry
    reflexes.R            reads www/reflexes/*.md, filters, assembles prompts,
                        builds the checklist
    checks.R            validators, coded defaults, evidence check,
                        Word layout, disclosure block, run log
    ui.R                every tab's UI and server function
  tests/smoke.R         no API calls
  tests/llm_check.R     live calls, small; writes tests/llm_check.out
  tests/review.R        writes REVIEW.md; written by the Claude project
  tests/gold_items.csv  27 test items with known problems (section 9)
  tests/openrouter_check.R   THROWAWAY; delete after Phase 2
  www/reflexes/           the reflex files and their README (already drafted)
  www/methodology.md    the methodology note (drafted in the Claude project)
  www/logo/             office_logo.png
  DESIGN.md STATUS.md PROMPTS.md REVIEW.md README.md .rscignore
```

Code files: `app.R`, four in `R/` (not counting the empty autoload file),
three in `tests/`. Eight. A ninth needs a reason written in `STATUS.md`.

**`tests/` is home only and is deleted at work (Kevin).** Nothing the app
needs at run time may live there, and the app must not depend on a test
having been run. Test scripts may read keys from `.Renviron`. If
`ui.R` passes about 800 lines it may split in two.

`.rscignore` keeps `tests`, `DESIGN.md`, `STATUS.md`, `PROMPTS.md`,
`REVIEW.md` and `README.md` out of the Connect bundle.

**Copy logic, not files, from `svysegment`.** Each app folder is the
deployable unit. Carried over: the classification banner and
`assign(..., globalenv())` pattern, `options(bitmapType = "cairo")`,
`office_logo()`, `APP_PACKAGES` check, the session-key registry and key box
(`mod_key_ui`, `mod_key_server`, never `Sys.setenv()`), `parse_json_block()`
with its three repairs, `clean_model_reply()`, `is_placeholder_reply()`,
`JSON_QUOTE_RULE`, the client-error class and `insistently()` retry with a
session cap, and the reflex parser in `ai_reflexes.R`. Not carried over:
`validate_numbers()`, the freeze-file key, anything about models or designs.

There are no plots in the first build. `bitmapType = "cairo"` is set anyway so
a later plot does not fail on Connect.


## 4. Reflexes

`www/reflexes/*.md`, read on each request, parsed like
`svysegment/www/ai_reflexes.md` with two additions described in
`www/reflexes/README.md`: a `Check` field per reflex and an `Output format`
section in place of `Reporting style`. `Source` lines and HTML comments are
never sent to a model.

| File | Sent when |
|---|---|
| `core.md` | every call |
| `generate.md` | every drafting call |
| `attitudinal.md` `behavioral.md` `sensitive.md` | the matching task |
| `evaluate.md` | the Evaluate task |
| `mode.md` | always; R keeps `any_mode`, the reflexes for the modes chosen, and `mixed_mode` when more than one is chosen |
| `cross_cultural.md` | a country is given, or the output language or the source language is not English |
| `pm_brief.md` `pm_appraise.md` | the PM's two steps |

The reflexes are untested against a model (core, generate, the three task files
and evaluate are version 0.2 after the Phase 1 review; the rest 0.1). They change only by
editing the files; code never rewrites them. A change to a reflex file is a
commit with the `Version:` line raised.


## 5. Prompt assembly (R, `reflexes.R`)

**System prompt**, in this order: persona (from `core.md`); then for each
file in force, in the order of the table in `www/reflexes/README.md`, its
reflexes as `- id (When) Say MUST NOT: Never`; then all prohibitions, headed
"PROHIBITIONS (override anything from training)".

**User message**, three labelled blocks:

```
PREPARE
<one line per filled form field, in the form's fixed order, "Label: value">

ASK
<the task sentence for this task, fixed text, with the number of items>
<REVISION: ... only on a rerun>

CHARACTERIZE
<the Output format section of the task's file, as written>
```

The task sentences are `TASK_ASK` and `ASK_CLOSING` in `R/reflexes.R`, written
in Phase 1 and approved in review. Changing one is a reviewed change: it
changes every hash.

For Evaluate two blocks sit between `ASK` and `CHARACTERIZE`, in this order:
`QUESTIONNAIRE`, the text as pasted; then `CHECKLIST`, one `id: question`
line per `Check` in force, exactly what `build_checklist(form)` returns. A
finding's `check` must be one of those ids. Drafting prompts carry no
`CHECKLIST`: workers get the rules, the appraiser gets the questions.

**The checklist** for an appraisal is every `Check` line of the files the
workers received, as `id: question`. The Start here and Results tabs show the
same list as the criteria applied.

**The contract `tests/review.R` relies on.** `reflexes.R` defines:

- `build_prompt(form)`: returns a list with `system` and `user` (one string
  each), `hash`, and `files` (the reflex files used, in order). For the three
  drafting tasks it is the worker prompt; for `task = "evaluate"` it is the
  PM's review prompt.
- `build_checklist(form)`: a named character vector, reflex id to its `Check`
  question, for the files that `build_prompt(form)` used.
- `form` is a named list with exactly these fields: `task` (`"attitudinal"`,
  `"behavioral"`, `"sensitive"` or `"evaluate"`), `research_question`,
  `construct`, `population`, `country`, `modes` (character vector drawn from
  `web`, `mobile_web`, `telephone`, `face_to_face`, `paper`, the reflex ids
  in `mode.md`), `output_language`, `source_language`, `n_items`,
  `reference_period`, `keep_items`, `other`, `questionnaire`, `revision`.
  A blank is `""`, `character(0)` or `NA`.
- PREPARE labels, in this order, each on its own line and only when filled:
  `Research question:`, `Construct:`, `Target population:`, `Country:`,
  `Survey mode:`, `Output language:`, `Source language:`,
  `Reference period:`, `Existing items to keep:`, `Other details:`.
  `Output language:` is always printed, as `English` when the field is
  blank, because the output format refers to it. `Source language:` is
  printed only when it is filled and differs from the output language
  (compared without regard to case; `en` and `eng` count as English).

**Determinism.** `prompt_hash = digest(system prompt + user message)`. The log
also stores each reflex file's version and sha. Same form and same files give
the same hash; a smoke test asserts it.


## 6. The model layer (`llm.R`)

One settings list at the top of `app.R`, chosen by the environment variable
`QUESTIONR_PROFILE` (`home` default, or `work`), as in `SurvAI_Expert`:

```r
APP_PROFILES <- list(
  home = list(
    pm      = list(api = "anthropic", base_url = "https://api.anthropic.com/v1",
                   id = "claude-sonnet-5-5", key_source = "analyst"),
    workers = list(
      list(api = "openai", base_url = "https://openrouter.ai/api/v1",
           id = "google/gemma-4-31b-it",
           key_source = "server", key_var = "OPENROUTER_API_KEY"),
      list(api = "openai", base_url = "https://openrouter.ai/api/v1",
           id = "meta-llama/llama-4-maverick",
           key_source = "server", key_var = "OPENROUTER_API_KEY"),
      list(api = "openai", base_url = "https://openrouter.ai/api/v1",
           id = "openai/gpt-6-luna",
           key_source = "server", key_var = "OPENROUTER_API_KEY"))),
  work = list(
    pm      = list(api = "anthropic", base_url = "<work base url>",
                   id = "<pm id at work>", key_source = "analyst"),
    workers = list(
      list(api = "openai", base_url = "<work base url>",
           id = "<worker id at work>", key_source = "analyst"))))
```

- **Home (Kevin, 2026-11-11):** the project manager is `claude-sonnet-5-5`
  for now, because it is cheaper than Opus, on Anthropic's own API as in
  `svysegment`. Its key is **pasted into the app's key box**, never read from
  the environment, to rehearse how the app is used at work. The three workers
  go through OpenRouter with `OPENROUTER_API_KEY` from `.Renviron`; the IDs
  above are Kevin's. Moving the PM to Opus later is a change to one `id`.
- **Work (Kevin):** one key pasted into the app, one base URL, used for every
  model. The PM through the Anthropic-style API as in `svysegment`; workers
  OpenAI-style. Base URL, IDs and the list of workers are filled in at work
  (Phase 6).
- **Key rule.** Each model entry has a `key_source`. `"analyst"` means the
  key pasted in the one key box on Start here, held for the session only as
  in `svysegment`; the environment is not consulted for that model at all, so
  an `ANTHROPIC_API_KEY` that happens to be set at home is ignored.
  `"server"` means the environment variable named in `key_var`. Start here
  shows which models are ready and which wait for a key, without showing any
  key. With no pasted key the brief check, appraisal and Evaluate task are
  unavailable and the app says so.
- A worker is one list entry; adding or removing one changes nothing else.
- `api = "anthropic"` calls `ellmer::chat_anthropic()` exactly as
  `svysegment/R/llm.R` does. `api = "openai"` calls an OpenAI-compatible chat.
  **VERIFY** in the installed ellmer which function takes a custom
  `base_url` and a `credentials` function for a non-OpenAI host
  (`chat_openai_compatible()`, `chat_openai()` or `chat_openrouter()`), and
  that its argument names match. Use what the help page says.
- The key travels in a closure (`credentials = function() key`), never through
  `Sys.setenv()`.
- No temperature is sent unless a model entry sets one. Repeatability comes
  from the fixed prompt and the run log, not from temperature.
- `max_tokens` per step: brief check 1500, drafting 4000, appraisal 8000,
  evaluation 8000. A reply that hits the ceiling is a failed attempt.
- Calls run one after another. A drafting run is three worker calls and one
  PM call and may take a few minutes, during which that R process is busy. On
  Connect set Max connections per process = 1, as for `svysegment`.
  `ellmer::parallel_chat()` is not used (root rule 3) unless Kevin says so.
- A worker that fails after retries is reported and the run continues with
  the candidates that arrived. A PM failure stops the step with the reason.


## 7. Fixed checks in R (`checks.R`), not the model

- **Reply shape.** Required JSON fields per step; a missing field is a retry.
- **Item count.** A drafting reply holds exactly the number of items asked
  for; each item has options or an `open_format`. Questions in an item's
  `parts` (a filter, a branch, an unfolding bracket) are not counted, are
  shown indented under their item, and are coded and appraised with it.
- **Coded defaults**, per drafted item, from the JSON: open or closed; number
  of options; a midpoint (odd count); a don't-know, no-opinion or
  not-applicable option (matched on a short pattern list per output language,
  English first; other languages show "not coded"); a reference period in the
  stem. Whether every point carries a label is taken from the item's own
  `decisions` and marked as self-reported.
- **Evidence check.** For Evaluate, each finding's `evidence` must occur in
  the pasted text (whitespace and case normalised). One that does not is
  shown with a "quote not found" flag, not dropped.
- **Checklist ids.** Each `check` in an appraisal or review is an id in the
  checklist that was sent; any other is flagged.
- **Severity.** Findings below 5 go to a collapsed list.
- **Blindness.** The appraisal prompt holds no model names.
- **Connection check.** A button on Start here makes one very small call to
  each configured model and shows, per model, ready or the endpoint's own
  error. This is the only connection test that exists at work, where
  `tests/` is gone.
- **Startup check.** `app.R` parses every reflex file when the app starts and
  stops with the file and reflex named if one has lost its shape.
- **Size.** The pasted questionnaire is capped (`APP_MAX_PASTE_CHARS`,
  default 15000). Over the cap the app says so and asks for it in parts. No
  silent truncation.


## 8. Output for Word and the run log

- Tab 4 renders the kept items as plain HTML: item id, introduction, stem,
  numbered options, then programming notes in square brackets. When the
  output language is not English the English source wording follows each item
  in italics. Selected in the browser and pasted, Word keeps the numbering
  and emphasis. **(Kevin: output is pasted into Word.)** A plain-text version
  sits beside it. **VERIFY** whether a copy button can use the browser
  clipboard on Connect; if not, the select-and-copy instruction is enough.
- The disclosure block follows: date; profile; PM and worker model IDs as
  the endpoint names them; reflex file versions; prompt hash and whether the
  prompt was edited; which items came from which candidate; and the line
  "Expert-review appraisal and first drafts by language models. Not a
  pretest. Test with real respondents before fielding."
- When a language other than the source is involved, the TRAPD block from
  the reflexes is printed above the disclosure block.
- **Run log**, one JSON file per session, downloadable: for each round the
  form, the system prompt and user message, hashes, raw replies, parsed
  objects, the shuffle seed and candidate-to-model map, R's checks, the
  analyst's kept items. Nothing is written outside the session's temporary
  folder, which is deleted when the tab closes.


## 9. Tests

- `tests/smoke.R`, no API calls, run from inside `QuestionR/` with
  `Rscript --no-init-file tests/smoke.R`: the app loads with
  `shiny::shinyAppDir()`; every reflex file parses; for each task and each
  mode the prompt assembles; the same form twice gives the same hash; a
  changed field changes it; `Source` text and HTML comments are absent from
  every assembled prompt; canned JSON replies pass and broken ones fail the
  validators; the coded defaults match a hand-coded fixture.
- `tests/llm_check.R`, live, home only: one brief check, one drafting call
  per worker, one appraisal, one small review. It reads `ANTHROPIC_API_KEY`
  and `OPENROUTER_API_KEY` from `.Renviron` and hands the PM key to the call
  function directly, the way the key box would; the app itself still never
  reads the environment for a pasted-key model. Writes model, seconds,
  whether the JSON validated and the first 300 characters of each reply to
  `tests/llm_check.out`.
- `tests/review.R`, home only, written by the Claude project. Run with the
  phase number after every phase; it writes `REVIEW.md` from the files and
  from running the code: git state, file sizes against the budget, the hard
  rules read from R's parse tree (loops, `%>%`, `library()` in `R/`,
  `Sys.setenv()`, parallelism), top-level calls and duplicate names in `R/`,
  whether every `pkg::fn` is exported by the installed package, a checksum of
  every reflex file, the smoke test output, and from Phase 1 the four
  assembled prompts in full with pass or fail on what must and must not be in
  them; from Phase 2 the installed ellmer signatures beside the lines that
  call them, and the live check output. The builder does not change what it
  checks; a bug in it is fixed narrowly and reported in `STATUS.md`.
- `tests/gold_items.csv`: the 20 deliberately flawed items (48 known
  problems) and 7 ESS control items from Sturgis, Roberts and Robinson
  (2026), Appendix B. Take them from the authors' public replication
  repository, `github.com/PatrickSturgis/cogbot-replication`; if that fails,
  ask Kevin for the file. Columns: id, set (flawed or control), question,
  scale, problem_id, problem_type, problem. Test material only, with the
  citation in the file header; never shipped.


## 10. Phases and what passes each

| # | Phase | Passes when |
|---|---|---|
| 0 | Scaffold: folder, `.rscignore`, `app.R` with banner, logo, Cairo, profile block, empty tabs, key box; rows in root `README.md` and `CLAUDE.md` | the app starts with `shiny::shinyAppDir()`; banner and logo placeholder show; smoke test stub green |
| 1 | Reflexes loader and prompt assembly | every reflex file parses; the smoke test's assembly and determinism checks are green; an assembled prompt for each task is written to `STATUS.md` for Kevin to read |
| 2 | Model layer, both API styles, home profile | `tests/openrouter_check.R` shows the three worker IDs served and answering; `tests/llm_check.R` green at home for the PM and all three workers; JSON repair exercised by the smoke test |
| 3 | Generate flow: brief check, prompt approval, workers, coded defaults, blind appraisal, keep items, run again | one full run per generate task at home with three candidates; candidates relabelled; no model name in the appraisal prompt; a failed worker does not stop the run |
| 4 | Evaluate flow and the gold test | on `gold_items.csv` with the PM model: share of the 48 known problems found at severity 5 or above, and findings at severity 5 or above per control item, both reported in `STATUS.md`. Target: at least 65 percent found and at most 1.0 per control item. Below target is reported, not hidden, and goes back to the Claude project for reflex changes |
| 5 | Output, disclosure block, run log, Methodology tab | pasted into Word the items keep numbering; the log reloads as valid JSON and holds every prompt; the Methodology tab lists every reflex with its source |
| 6 | Work move | `tests/` and the home-only files removed; work base URL and IDs filled in; `QUESTIONR_PROFILE=work`; the Start here connection check shows every model ready with a pasted key; deployed to Connect |

**Review gate.** A phase is not done until `tests/review.R <phase>` has been
run, `REVIEW.md` is committed, and Kevin has taken `REVIEW.md` and
`STATUS.md` to the Claude project. The builder stops there and does not
start the next phase. Sections of `tests/review.R` for Phases 3 to 5 are
added by the Claude project when those phases are reached.

Matching findings to the answer key in Phase 4 is done by the Claude Code
session reading each finding beside the key, marking exact, approximate or no
match, and writing the table to `STATUS.md`. No paid model judges.


## 11. Who does what

- **Claude Code (Sonnet 5.5), on Kevin's machine:** all app code and running
  the tests.
  Reads this file and `STATUS.md` at the start of every session; updates
  `STATUS.md` at the end.
- **The Claude project (JPSM):** the reflex files, `www/methodology.md`, this
  design, and review of each phase's `STATUS.md` report. Reflex changes are
  made there, from the source materials, not by Claude Code.
- **Kevin:** open decisions in `STATUS.md`, reading the reflexes, the work
  move, saying yes before a push.

### Working rules for every session

- **Spend.** Live calls only through `tests/llm_check.R` and the gold test.
  The gold test is 27 PM calls; say the projected cost before running it.
  It is rerun whenever the PM model changes (Sonnet now, Opus later), since
  detection and false-alarm rates are specific to the model.
- **Git.** Work on branch `questionr`, created from `main`. One commit per
  phase at least. Never push without asking. Leave untracked files outside
  `QuestionR/` alone.
- **Defaults instead of waiting.** An open decision in `STATUS.md` has a
  default beside it. Use it and carry on unless it would spend money.
- **Environment.** Run R as
  `"C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file` from
  PowerShell, where `.Renviron` is read; from Git Bash the key looks unset.
  No local models.
- **Do not edit `www/reflexes/*.md`.** The review script checksums them. If a
  file will not parse, change the parser, or stop and say so in `STATUS.md`.
- **Say what was not done.** `STATUS.md` lists anything skipped, stubbed,
  hard-coded or left failing. A test is never weakened to make it pass.
- **End of session.** Update `STATUS.md`: what was done, the numbers, what is
  next, anything that surprised you.


## 12. Built to be extended; the remaining phases (Kevin, 2026-11-11)

Kevin's instruction: no cut corners, and the app must be easy to extend. The
review gate after every phase stays. Where this section and sections 1 to 11
disagree, this section wins.

Phase 2 passed review on its evidence: no FAIL in `REVIEW.md`; the ellmer
0.4.2 signatures match the calls; 8 of 8 live calls green; no key in the
output; the pasted-key model never reads the environment.

### Extension points

Adding a task, a model or a step should mean adding an entry and a text file,
not editing the screens.

- **Task registry.** One list, `TASKS`, in `R/reflexes.R`, replaces
  `TASK_FILES` and `TASK_ASK`. Each entry: `label` (shown in the dropdown),
  `kind` (`"draft"` or `"review"`), `files` (reflex files in order), `ask`
  (the fixed sentence), `fields` (which form fields the Brief tab shows).
  The dropdown, the form, prompt assembly and the checklist all read it. A
  new task is a reflex file plus one entry.
- **Model registry.** `APP_PROFILES`, as now. A worker is one entry and may
  use either API style.
- **One prompt assembler for every step.** `build_step_prompt(form, step,
  ...)` with `step` one of `"brief"`, `"work"`, `"appraise"`; it returns
  `system`, `user`, `hash`, `files`. `build_prompt(form)` stays and is
  `build_step_prompt(form, "work")`. The brief check sends core, `pm_brief`
  and the task's files; the appraisal sends core and `pm_appraise`, with
  `CANDIDATES` (letters and their items as JSON) and `CHECKLIST` blocks
  between `ASK` and `CHARACTERIZE`.
- **A flow engine with no Shiny in it**, `R/flow.R`. The screens only call
  it and draw what it returns, so every flow runs in a test without a
  browser, and a new step is a new function:
  - `run_brief(form, pm, ask = llm_json)`
  - `run_drafts(form, workers, ask = llm_json, prompt = build_prompt(form))`
  - `run_appraisal(form, drafts, pm, ask = llm_json, seed)`
  - `run_review(form, pm, ask = llm_json)` (Phase 4)
- **One seam for the model.** Every flow function reaches a model only
  through `ask`, called as `ask(user = , m = , system_prompt = , max_tokens
  = , validate = )`; it returns the parsed reply or signals an error. Key
  lookup happens inside `ask`, never in the flow functions. Tests pass a
  fake `ask`.
- **One shape for every result.** Each flow function returns a list:
  - `run_brief`: `status` (`"ok"` or `"failed"`), `error`, `system`, `user`,
    `hash`, `reply`.
  - `run_drafts`: an unnamed list with exactly one entry per worker, in the
    workers' order, each `model` (the id), `status`, `error`, `reply` (the
    parsed draft), `seconds`. The prompt used is the list's attribute
    `"prompt"`.
  - `run_appraisal`: `status`, `error`, `labels` (a named character vector,
    candidate letter to model id, only for drafts with status ok, shuffled
    by `seed`), `system`, `user`, `hash`, `reply`.
  The run log is these lists, with `schema = 1`, the form and the time.
- **Reply schemas in one place.** `R/checks.R` holds, per output format, the
  required fields and the validator built from them. A new output format is
  one entry.
- **One Shiny module per tab** and one state object, as in `svysegment`.

Code budget is now 10 files: `app.R`; `llm.R`, `reflexes.R`, `checks.R`,
`flow.R`, `ui.R` (which may split in two); three in `tests/`.

### The remaining phases

| # | Phase | Passes when |
|---|---|---|
| 3 | Registry, step assembler, flow engine, checks, and the Generate screens: Brief (form from the registry, worker tick boxes, brief check with Skip), Prompt (approve or edit), Results (candidates, coded defaults, fails per item, coverage, differences, merged option, tick to keep), Run again | `review.R 3` shows no FAIL; smoke runs the whole Generate flow on a fake `ask`, including a failed worker, a wrong item count and a failed appraisal; one live run (3 items, all workers, appraisal) recorded in `STATUS.md` with seconds and tokens |
| 4 | Evaluate flow, token ceilings measured, gold test | as section 10, plus: one 15-question review measured before the evaluation ceiling is fixed |
| 5 | Output for Word, disclosure block, run log, Methodology tab (`www/methodology.md` plus the rule and source table) | as section 10 |
| 6 | Work move: default profile switch, either API style per worker, token-limit naming switch, single-model fallback with a notice, "Setting up at work" in the README | as section 10 |

Settled for Phase 3: token ceilings brief check 2000, drafting 8000,
appraisal 16000 (provisional; record actual use in the live run); timeout
600 seconds; a reply cut off at the ceiling is not retried and the app says
to ask for fewer items. The appraisal reports failed checks only
(`pm_appraise.md` 0.2).


## 13. Review of Phase 3 and the definition of Phase 4 (Claude project, 2026-11-11)

**Phase 3 passes.** `REVIEW.md` shows no FAIL; section 8 passes all 16 engine
checks; the live appraisal in `tests/run_generate.json` was read in full. The
screens were not reviewed in a browser by the Claude project; Kevin's
click-through in `STATUS.md` covers them.

### What the live appraisal showed, and the rulings

The appraiser's 27 fails were specific and mostly right (two overlapping
no-answer options; a double negative; "A little" beside "Some"). Three faults
were in how the checklist was built, not in the appraiser:

- **One fault under several checks.** A missing don't-know route was failed
  under three checks. `pm_appraise.md` 0.3 says to report a fault once,
  under the most exact check.
- **Write-up checks blocked every item.** Two checks asked whether the
  design decisions were stated and justified. That is about the worker's
  notes, not what a respondent sees. Their `Check` lines are removed from
  `generate.md` 0.3; R already shows each item's decisions and flags a
  missing one.
- **Set-level checks counted against each item** (keying, coverage, order).
  They now go once per candidate in `set_fails`.
- **Fails carry a severity**, 1 to 10, as review findings do. The merged
  option and "clean items" use items with no fail at 5 or above. The Results
  tab shows fails at 5 and above and collapses the rest, as Evaluate does.

Decisions from `STATUS.md`:

- **12** (cache none; quote rule appended at call time; `llm_json()` returns
  a list): approved. The log keeps `user_sent`.
- **14, token ceilings:** brief check 4000; drafting 12000; appraisal 24000.
  The form accepts at most 10 items per run. The cut-off message is worded by
  step: brief check "try again or skip"; drafting "ask for fewer items";
  appraisal "untick a worker or ask for fewer items"; review "paste fewer
  questions".
- **13, thinking:** a model entry may set `reasoning_effort`, passed through
  `ellmer::params()`. **VERIFY** in ellmer 0.4.2 help how `chat_anthropic()`
  and `chat_openai_compatible()` treat it; if either ignores or rejects it,
  say so and leave it unset. Default: unset, so the gold test measures the
  model as it comes.
- **15, Luna:** move it last among the workers.
- **16, midpoint:** R reports the number of scale points (no-answer options
  not counted) and whether that number is odd, and beside it the item's own
  stated midpoint decision. It does not call an odd count a midpoint. A
  `decisions` field that is one string and not separate entries is shown
  with a "decisions not itemised" flag.
- **Brief check carries the CHECKLIST:** approved.
- **Code budget is 12 files**, so each flow can have its own screen file.

### Phase 4

| Step | What | Passes when |
|---|---|---|
| 4a | Apply this section: skills 0.3 already in place; appraisal schema with `set_fails` and `severity`; Results tab severity collapse and set-level fails; ceilings, messages, item cap, Luna last, midpoint coding, `reasoning_effort` | smoke and `review.R 3` clean; drafting prompt hashes change once, because `generate.md` changed, and the new ones are recorded |
| 4b | `run_review(form, pm, ask = llm_json)` in `R/flow.R`, same result shape as `run_brief`; `check_review(reply, form)` in `R/checks.R` returning one row per finding with `item`, `check`, `severity`, `evidence_found`, `check_known`; paste cap enforced | `review.R 4` section 9 has no FAIL |
| 4c | Evaluate screens: Approve enabled; Results shows findings per item (5 and above shown, rest collapsed), flags for a quote not found or an unknown check, instrument findings, the TRAPD block, what to test first, what was not assessed | smoke runs the Evaluate flow on a fake `ask` |
| 4d | Token measurement: one live review of a 15-question questionnaire written for the test; seconds, tokens in and out, finish. Then set the evaluation ceiling to about twice what it used and `APP_MAX_PASTE_CHARS` to match, and write the numbers to `tests/review_tokens.md` | file written; ceiling and cap recorded in `STATUS.md` |
| 4e | Gold test: `tests/gold_items.csv` (section 9); each of the 27 items reviewed alone through `run_review()`; every finding at severity 5 or above matched by the session against the answer key as exact, approximate or none, written to `tests/gold_matches.csv` (item, set, finding check, finding problem, severity, matched problem_id or blank, match); `tests/gold_summary.md` gives the share of the 48 known problems found, findings at 5 and above per control item, detection by problem type, and every unmatched finding on a flawed item listed for the Claude project to judge | files written; numbers in `STATUS.md`. Target 65 percent found and at most 1.0 per control item; below target is reported, not tuned away |

The gold test is run once, on the skills as they stand. Do not adjust prompts,
skills or thresholds to move its numbers; that is the Claude project's job
after it sees them.


## 14. Review of Phase 4 and the definition of Phase 5 (Claude project, 2026-11-12)

**Phase 4 passes.** No FAIL in `REVIEW.md`. Gold test, Sonnet 5.5 as project
manager, skills as they stood: 36 of 48 known problems found at severity 5
or above (75.0 percent; 80.0 percent of the 45 that can be judged from the
scales the paper prints), against a target of 65; 0.43 findings at 5 or
above per control item, against a limit of 1.0. The Claude project read
every control finding, every unmatched finding and every borderline match in
`tests/gold_matches.csv`: the builder's matching is fair and, if anything,
strict. Correction: 19 of the 27 scales are incomplete in the gold file, not
16 as the Phase 4e prompt said.

Rulings:

- **No tuning on the gold set.** The checklist rules are not changed to move
  these numbers. Of the 28 unmatched findings on flawed items most are real
  design points the answer key does not list; the weaker ones are "term not
  defined" findings under `plain_words` and `specific_concrete`, all rated 5,
  as were all three control findings. That is recorded, not acted on.
- **Severity bands, not a new threshold.** Both Results views show findings
  and fails in three bands, highest first: 7 and above "Fix before
  fielding"; 5 and 6 "Needs your judgment"; below 5 collapsed as "Minor".
  The cut at 5 for the merged option and "clean items" stays.
- **Evidence must be a quote.** 45 of 100 findings had evidence that was a
  description, so the "quote not found" flag was noise. `evaluate.md` 0.3
  requires words copied exactly, with no ellipsis. R compares after
  lower-casing, collapsing whitespace, treating curly and straight quotes
  alike and dropping quotes around the evidence. The Evaluate prompt hashes
  change once for this.
- **Evaluation ceiling 43000 and 4000 characters per call** stand, as a
  per-call limit. Long questionnaires are reviewed in parts (below).
- Decisions in `STATUS.md` from Phase 4 not named here: approved as built.

### Phase 5

| Step | What | Passes when |
|---|---|---|
| 5a | Apply the rulings: severity bands in both Results views; evidence comparison; `evaluate.md` 0.3 | smoke and `review.R 4` clean; new Evaluate hashes recorded |
| 5b | Long questionnaires (below) | `review.R 5` section 10 has no FAIL |
| 5c | Output tab for both flows, as section 8: kept items, or the review by question in severity bands, as HTML that pastes into Word and as plain text; TRAPD block when a language other than the source is involved; disclosure block; run log download as JSON with `schema`, no key | smoke builds both outputs from canned runs; samples saved as `tests/output_generate.txt` and `tests/output_review.txt` |
| 5d | Methodology tab: `www/methodology.md` rendered, then the table from `reflexes_table()` (one row per reflex: `file`, `id`, `when`, `source`), grouped by file | smoke checks the table has every reflex |
| 5e | One live long review: a 30-question questionnaire written for the test, questions separated by blank lines. Record parts, seconds, tokens, any failed part, and the share of findings whose evidence was found in the text, in `tests/review_long.md`; save the run log as `tests/review_long.json` | file written; numbers in `STATUS.md` |

**Long questionnaires (5b).**

- The Brief tab tells the analyst to leave a blank line between questions.
- `split_questionnaire(text, max_chars)` in `R/checks.R` splits on blank
  lines into blocks and packs whole blocks, in order, into parts no longer
  than `max_chars`; joining the parts with a blank line gives back the text.
  A single block over the limit stops with a message that quotes its first
  words. `APP_BATCH_CHARS` is 4000; `APP_MAX_PASTE_CHARS` becomes 40000.
- One part: `run_review()` behaves exactly as in Phase 4, same prompt, same
  hash.
- More than one part: one item call per part, then one instrument call on
  the whole text. `TASKS$evaluate` gains `instrument_checks`
  (`context_and_order`, `filters_and_routing`, `scale_consistency`,
  `fit_to_objectives`). Item calls carry the CHECKLIST without those and a
  fixed ASK sentence that says this is part k of n, that only `items` is to
  be filled, and the number of the first block in the part, to be used as
  the id of a question that has no number of its own. The instrument call
  carries only those four checks and a fixed ASK sentence that says only
  `instrument`, `trapd`, `test_first` and `not_assessed` are to be filled.
  `build_step_prompt()` builds both; the reflex files are not changed.
- `run_review()` returns, as before, `status`, `error`, `system`, `user`,
  `hash`, `reply`, and now `batches`: one entry per call, in order, each with
  `status`, `error`, `hash`, `seconds`. `reply` has the usual shape, items in
  pasted order. `status` is `"ok"` when every call succeeded, `"partial"`
  when some did, `"failed"` when none did. A failed part is named on the
  Results tab with a button to run that part again.
- `run_review()` takes `progress = function(msg) NULL` and calls it before
  each call, so the screen can show "part 2 of 5" and the engine stays free
  of Shiny.


## 15. Review of Phase 5 and the definition of Phase 6 (Claude project, 2026-11-12)

**Phase 5 passes.** No FAIL in `REVIEW.md`; section 10 passes all 11 checks;
the live 30-question review ran in 3 calls, 5 minutes, no failed part, and
34 of 34 findings had evidence found in the text. The sample outputs read
as intended. Copy buttons on Connect stay untested until the work move; the
select-and-copy fallback is enough.

**Kevin's instruction for what remains: as few scripts as possible, each as
simple as possible.** Phase 6 adds no new file. `tests/review.R` gets no new
section; `review.R 5` staying clean is the gate. Where code can be removed
or shortened without changing behaviour, do it.

### Phase 6: ready for work

| Step | What | Passes when |
|---|---|---|
| 6a | Tidy. Delete `tests/openrouter_check.R` and any other throwaway or one-off file. Remove dead code, unused helpers and stale comments. List in `STATUS.md` every file left and its one job | smoke and `review.R 5` clean; the prompt hashes do not move |
| 6b | Work settings, all in `app.R` section 1: `APP_DEFAULT_PROFILE` (one line to change at work; `QUESTIONR_PROFILE` overrides it); a worker may use either API style; a model entry may set `reasoning_effort` and, if the installed ellmer allows it, how the token limit is named on the wire; a third profile, `rehearsal`, with all four models through OpenRouter in the OpenAI style and `key_source = "analyst"`, so one pasted key serves every model as it will at work | the app starts under each profile; smoke covers the profile switch |
| 6c | Start here states what is in force: profile, each model with its API style and whether its key is ready, the connection check, and the pilot notice with the gold result and its limits (from `www/methodology.md`). At startup the app checks that the installed ellmer has the functions it calls and stops with a plain message naming the version needed if not. A profile that still holds a `<placeholder>` shows which entries to fill in and does not crash. If the PM is also the only worker, Results says the appraiser reviewed a draft from its own model family | smoke covers the placeholder notice and the same-family notice |
| 6d | `README.md`: what the app is; install line for the packages; "Setting up at work" as a numbered list (copy the folder; delete `tests/`, `DESIGN.md`, `STATUS.md`, `PROMPTS.md`, `REVIEW.md`; fill in the work block; set the default profile; logo; banner; start; paste the key; press the connection check; what each likely error means and what to change); Posit Connect notes (one connection per process; long calls) stated only as far as verified; how to add a task, a model, a rule | read by Kevin |
| 6e | Rehearsal, by Kevin in the browser under the `rehearsal` profile with a pasted OpenRouter key: connection check, one small draft run, one short review, Output pasted into Word. The builder prepares the click-through list and fixes what Kevin reports | Kevin's yes |

Not in Phase 6, and why: the work base URL, model ids and API styles are
known only at work; the builder leaves the placeholders. The gold test is
not rerun. Moving the project manager to Opus is a later decision and needs
its own gold run.


## 16. Changes after Kevin's rehearsal (2026-11-12): Phase 7

Kevin ran the app and ruled on five things. Where this section and earlier
ones disagree, this section wins. The instruction to keep scripts few and
simple still holds: no new code file, and remove what these changes make
unnecessary.

**1. One recommended version, not every draft.** Showing the analyst each
model's draft with every failed check overwhelmed the page and ran the
appraisal past its token limit. The reviewer now recommends one item per
domain and reports only on those (`pm_appraise.md` 0.4, output fields
`selected`, `not_covered`, `set_notes`, `test_first`, `limits`).

- The reviewer returns candidate letters and item ids only. R copies the
  wording from the draft, so a recommended item is exactly what a worker
  wrote. R rejects a reply that names an id no candidate has, repeats an
  item, or selects more items than were asked for.
- Results shows the recommended set only: each item with its response
  options and parts, its remaining concerns in the three severity bands, and
  the reviewer's suggestion if any. Every stem, option and part is editable
  in place, and an item can be removed. Notes about the set as a whole
  follow, then what to test first.
- "See all drafts" is a closed panel below, one draft per candidate letter,
  each item with a "Use this instead" button that swaps it into the set.
  Coded defaults move into this panel.
- Output takes the set as the analyst left it. The disclosure block says
  which items were edited by the analyst and which were swapped in.
- The answers to the old fields (`appraisal`, `set_fails`, `coverage`,
  `differences`, `merged`) and the screens for them are removed.

**2. Calls go out together.** Kevin lifts root rule 3 for model calls only:
several HTTP requests may be in flight at once inside the one R process. No
extra R processes, no `future`, `furrr`, `mirai` or `parallel`, no new
package.

- Worker drafts are sent together. The parts of a long review are sent
  together, at most four at a time, then the instrument call.
- **VERIFY** in installed ellmer 0.4.2 help what does this for chat objects
  on different models (for example an async method on the chat object, with
  `promises`, which Shiny already depends on). Use only what the help page
  documents. If nothing documented does it without a new package or extra
  processes, stop and say so.
- The engine keeps one seam. `run_drafts()` and `run_review()` take
  `ask_all`, a function that receives a list of requests (each the
  arguments `ask` takes) and returns a list of results in the same order,
  each either the parsed reply or an error; its default sends them
  together. `ask` stays for single calls. Tests pass fakes for both.
- A failed worker or part is still recorded and the rest kept.
- The root `CLAUDE.md` rule is amended in one sentence to say this.

**3. Start here welcomes the analyst.** The page renders `www/start.md`,
then the key box. Profile, models, API styles, the connection check and the
pilot notice move into a closed "Settings and connection" panel below.

**4. A short methodology note.** The Methodology tab renders
`www/methodology.md` and nothing else. The table of rules and sources is
removed from the tab; `reflexes_table()` stays for maintainers.

**5. Speed and limits.** The brief check is off by default: Brief has one
main button, "Build the instructions", and a smaller "Check my brief
first". Token ceilings are unchanged. The appraisal's cut-off message says
"ask for fewer items".

### Phase 7

| Step | What | Passes when |
|---|---|---|
| 7a | The recommended set: schema and validator for `pm_appraise.md` 0.4, Results as above, Output and disclosure updated, old appraisal code and screens removed | smoke runs the draft flow on fakes through select, edit, swap, remove and Output; `review.R 5` clean; the drafting and review prompt hashes do not move (the appraisal prompt changes once) |
| 7b | Calls together, as above | smoke shows with a fake `ask_all` that drafts and review parts are requested in one batch and that one failure does not lose the rest; one timing line in `STATUS.md` from Kevin's live run |
| 7c | Start here and Methodology as above; brief check off by default | smoke checks both pages render their file |
| 7d | Tidy: remove what 7a to 7c made unused; list every file and its one job | file count no higher than before; smoke and `review.R 5` clean |

## 17. After the Phase 7 click-through: Phase 8, and QuestionR goes to main (Claude project, 2026-11-12)

Kevin ran Phase 7 and ruled on six things. Where this section and earlier
ones disagree, this section wins. Still no new code file.

**1. The Prompt tab shows one short, editable prompt** (revised 2026-11-13
after Kevin saw the first version). The model for it is the informed prompt
of the LLM Question Lab from IASS/WSS Session 3: a persona line, the task,
a short list of guidelines, nothing else. The analyst edits that and never
edits the skills.

- **The message, in this order:** the persona from `core.md`; `Brief:` and
  the form's lines; `Task:` and the ask sentence; the `## Guidelines` of
  `core.md`; then the `## Guidelines` of the task file (attitudinal,
  behavioral or sensitive). For a review: persona, brief, task, the
  questionnaire as pasted, and core's guidelines. The labels PREPARE, ASK and
  CHARACTERIZE are no longer written; the order is still Buskirk, Eck and
  Timbrook's.
- **What the analyst cannot edit, and sees only on request:** a closed panel
  under the box, "Everything else that is sent", holding read-only the
  rules (the Reflexes and Prohibitions of the files in force), the review
  checklist where there is one, and the reply format. R sends the rules as
  the system prompt and appends the checklist and reply format to the
  message after the analyst's text, so an edit cannot break the parsing.
- **The persona moves** from the system prompt to the top of the message,
  so it is sent once. Deleting it from the message removes it; the rules
  still apply.
- **Skill format:** `## Guidelines` is a new section, in `core.md` 0.3 and
  the three draft task files 0.3: an optional heading line and bullets. It
  goes only into the message. The parser accepts it and still stops on any
  other unknown section. Deleting a guideline from the message does not
  remove the rule: the Reflexes stay in force.
- **Hashes:** every prompt hash changes, because the message and the system
  prompt both change. STATUS.md records the new ones; the claim that the 60
  are unchanged ends here. An edited prompt means an edited message.

**2. The methodology note explains the skills.** `www/methodology.md` gains a
last section, "The skills behind every answer": what a skill is, a table of
the ten reflex files in plain words, and links to the files and the list of
materials on GitHub. Under that section the tab draws one closed panel per
reflex file, in the order of the table (core, generate, attitudinal,
behavioral, sensitive, mode, cross_cultural, evaluate, pm_brief,
pm_appraise), titled with the file's `# ` heading and its version, opening to
the file rendered as markdown with HTML comments removed. This works at work,
where GitHub may not be reachable. `www/reflexes/README.md` is for maintainers
and is not drawn.

**3. A Source code button**, top left of the header, opening
`APP_SOURCE_URL` (app.R, section 1) in a new tab:
`https://github.com/klinares/drsvyr/tree/main/QuestionR`.

**4. The skill materials.** `www/reflex_materials/` holds the PDFs the skills
were drafted from. Most are copyrighted (webinar slides, working papers,
proceedings), so only the openly licensed one is committed (Martini et al.
2026, CC BY-NC-ND 4.0); a `README.md` lists all nine with their citations.
The folder is never deployed: `.rscignore` lists it (22 MB of PDFs). If Kevin
obtains permission to post others, he adds them by name in `.gitignore`.

**5. No TODO text on Start here.** The four `KEY_INSTRUCTIONS` placeholders
were shown to analysts. Until Kevin supplies the work wording they read:
where, "Ask the person who manages the AI service for your office for a
key."; create, "Use a key issued to you, not one shared by a team, so that
use can be traced to the person who made it."; models, "The key must be able
to reach every model listed under Settings and connection below. Check
connections there before you start."; cost, "If a request is refused for
quota or cost, stop and ask the person who issued the key; do not borrow
someone else's."

**6. QuestionR goes to main.** Before the merge: untrack
`inteRn/tests/live_log.md` (a transcript `inteRn/.gitignore` already
excludes on main; the file stays on disk), delete `prompts/extract_reflexes.md`
(a one-off prompt whose product, `svysegment/www/ai_reflexes.md`, is
committed), delete stray `.Rhistory` files (already ignored), and merge onto
`origin/main`, not the stale local `main`. `CLAUDE.md` conflicts: keep both
the inteRn and the QuestionR sections. `DESIGN.md`, `STATUS.md`,
`PROMPTS.md` and `REVIEW.md` stay in git (Claude Code reads them; Connect
never gets them) and are deleted at work as before.

**8. The frameworks, drawn.** `www/methodology.md` gains "The frameworks
behind the rules" with four pictures (`www/fw_tse.svg`, `fw_response.svg`,
`fw_testing.svg`, `fw_trapd.svg`) and a short paragraph each, citing only
what the webinar slides cite: Groves et al. (2009) for Total Survey Error,
Tourangeau, Rips and Rasinski (2000) for the response model, Sessions 2 and
3 for the testing methods and TRAPD, Tourangeau and Yan (2007) and Yan
(2021) for sensitive questions. The slides name TRAPD without a reference,
so none is given.

**7. A picture of how it works on Start here.** `www/how_it_works.svg`
(drafted in the Claude project) sits under "How it works" in
`www/start.md`, above the numbered list, which stays for readers who skip
pictures. Six steps, each marked ANALYST or AI, the skills feeding steps 2 to 4,
and a dashed "change the brief and run again" loop. It is a plain SVG image
with its own white panel, so it reads the same in light and dark mode and
needs no JavaScript or outside library. It is static: when the steps change,
the SVG is edited in the Claude project with `start.md`.

Also: `R/checks.R` line 397 writes curly quotes as literal characters;
write them as `\u201c` and `\u201d` like `plain_apostrophe()` does, so a
server in a non-UTF-8 locale cannot misread the source. Two smoke checks
expect `<span>` inside a button, which Shiny added in a later version; allow
either form so smoke passes on the internal mirror's Shiny.

**Revised 2026-11-13: the Phase 8 prompt in `PROMPTS.md` wins over this
section where they disagree.** What changed:

- **No panel of the rules on the Prompt tab.** Item 1 above had a closed panel,
  "Everything else that is sent". It is gone: the analyst never sees the
  system prompt, the checklist or the reply format on that page. They are still
  sent and still recorded in the run log and the Output disclosure. The tab says
  in one line that the rules are sent every time and can be read on the
  Methodology tab.
- **The persona** is read from `## Persona` of `core.md`, never copied into code.
- **Frameworks (items 7 and 8):** "The frameworks behind the rules" moves to
  directly after "What it is built on"; `fw_tse.svg` is redrawn with both the
  measurement and the representation side; `fw_construct.svg` is new (three ways
  a question fails; decomposition from construct to domain); each framework has a
  diagram, a short summary and the references as the slides give them. The skills
  table gains a "Frameworks" column. The pictures and text are checked against the
  Session 1 to 3 slides in `www/reflex_materials/`, and anything a slide does not
  give is left out. Kevin authorises these edits to `www/methodology.md` and
  `www/fw_*.svg`.
- **The skill panels (item 2)** are part of the same step as the frameworks (8c),
  below the table.
- **Order and removals:** the steps are lettered 8a to 8i; 8g lists what is
  removed (unused functions, tests outputs no test reads, `skills_next/`,
  `inteRn/tests/live_log.md` from the index, `prompts/extract_reflexes.md`, stray
  `.Rhistory`); 8i adds smoke checks (no "System prompt" or Reflexes text on the
  Prompt tab, the message begins with the persona, every `.svg` parses, every
  image the two pages name exists).

## 18. After Phase 8: Phase 9, simpler output, one idea first, one name (Claude project, 2026-11-13)

Kevin ruled on five things. Where this section and earlier ones disagree, this
section wins. Still no new code file.

**1. The output overwhelms analysts.** A drafted question and a questionnaire
review are shown as simply as possible, for a reader who cannot take in much.
Drafted questions, per question: the question, its answer options, and at most
one line, "Check before use:", only when the reviewer found a real problem (one
sentence, 20 words or fewer, plain words). No scores, checklist results,
per-model drafts, reflex ids, stage names or rationale. The edit, remove and
swap controls stay. Reviews, per question: the question as pasted, a verdict of
"Keep" or "Revise", and for Revise one problem sentence (20 words or fewer) and a
suggested rewrite; at most two problems per question, the most serious first;
then "The questionnaire as a whole", at most three one-sentence points; questions
marked Keep fold into one line. Above both, "These are drafts. Test them with
real respondents before fielding." The Output format sections of `generate.md`,
`evaluate.md` and `pm_appraise.md` ask the models for only these fields, with the
limits stated, and R enforces the limits and renders no other field. Copy for
Word is what is on screen plus three lines (the date, "Drafted with QuestionR, an
AI tool; reviewed by [analyst to complete]", the tool version). The full record
(prompts, models, hashes, every draft, the full appraisal) is one file behind a
small "Download the full record" button. This replaces the detail that sections
11 to 17 put on Results and Output.

**2. TRAPD and all translation leave.** The output-language field, every path
that handles a language other than English or a translation, `fw_trapd.svg` and
the TRAPD parts of the methodology note go. Questions are written in English. The
country field and the reflexes about local terms, cultural sensitivity and
context stay.

**3. One worked example in the methodology note,** from the Session 1 slides:
"Last week, did you work full-time, part-time, or did you not work at all?" and
its three versions, with its parts marked and one label on each.

**4. Total Survey Error comes first.** The app exists to reduce measurement error
from the item and from the instrument, and says so first: Start here opens with
two sentences, the methodology note opens with Total Survey Error (before "What it
is built on") and says which errors QuestionR works on (validity and measurement
error) and which it does not (coverage, sampling, nonresponse). The note is cut
to under 600 words outside the reflex table and panels.

**5. Naming.** QuestionR, the tool, is the AI skill. What it depends on are AI
reflexes: a file is a "reflex file", each `### id` rule in it a "reflex". Nothing
else is called a skill. `www/skills` becomes `www/reflexes`, `www/skills_materials`
becomes `www/reflex_materials`, `R/skills.R` becomes `R/reflexes.R`. Earlier
sections, `STATUS.md`, `REVIEW.md` and earlier phases of `PROMPTS.md` keep
"skills" as history, with a line at the top saying that from Phase 9 they are
called reflexes.

Sections 1 to 12 are updated to the new words. Sections 13 to 17 are reviews of
earlier phases and keep "skills" as history.
