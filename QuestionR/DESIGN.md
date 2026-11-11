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
   comes from `www/skills/*.md`, each rule traced to a source. The expertise
   is in those files, not in the model.
2. **Repeatable.** The same form produces the same prompt, character for
   character. R assembles the prompt; no model writes it. **(Kevin)**
3. **The analyst decides.** The project manager model appraises and compares.
   It never picks a winner and never calls anything validated. **(Kevin)**
4. **Honest about what it is.** Every output says it is an expert-review
   appraisal or a first draft by a language model, not a pretest, and carries
   a disclosure block (models, date, skill versions, prompt).
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
| Methodology | The note, the skills as readable text, sources per rule | no |

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
    skills.R            reads www/skills/*.md, filters, assembles prompts,
                        builds the checklist
    checks.R            validators, coded defaults, evidence check,
                        Word layout, disclosure block, run log
    ui.R                every tab's UI and server function
  tests/smoke.R         no API calls
  tests/llm_check.R     live calls, small; writes tests/llm_check.out
  tests/review.R        writes REVIEW.md; written by the Claude project
  tests/gold_items.csv  27 test items with known problems (section 9)
  tests/openrouter_check.R   THROWAWAY; delete after Phase 2
  www/skills/           the skill files and their README (already drafted)
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


## 4. Skills

`www/skills/*.md`, read on each request, parsed like
`svysegment/www/ai_reflexes.md` with two additions described in
`www/skills/README.md`: a `Check` field per reflex and an `Output format`
section in place of `Reporting style`. `Source` lines and HTML comments are
never sent to a model.

| File | Sent when |
|---|---|
| `core.md` | every call |
| `generate.md` | every drafting call |
| `attitudinal.md` `behavioral.md` `sensitive.md` | the matching task |
| `evaluate.md` | the Evaluate task |
| `mode.md` | always; R keeps `any_mode`, the reflexes for the modes chosen, and `mixed_mode` when more than one is chosen |
| `cross_cultural.md` | a country is given or the output language is not English |
| `pm_brief.md` `pm_appraise.md` | the PM's two steps |

The skills are version 0.1 and untested against a model. They change only by
editing the files; code never rewrites them. A change to a skill file is a
commit with the `Version:` line raised.


## 5. Prompt assembly (R, `skills.R`)

**System prompt**, in this order: persona (from `core.md`); then for each
file in force, in the order of the table in `www/skills/README.md`, its
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

For Evaluate the pasted questionnaire follows `ASK` under the heading
`QUESTIONNAIRE`, as pasted.

**The checklist** for an appraisal is every `Check` line of the files the
workers received, as `id: question`. The Start here and Results tabs show the
same list as the criteria applied.

**The contract `tests/review.R` relies on.** `skills.R` defines:

- `build_prompt(form)`: returns a list with `system` and `user` (one string
  each), `hash`, and `files` (the skill files used, in order). For the three
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
  `Output language:` and `Source language:` are left out when both are
  English.

**Determinism.** `prompt_hash = digest(system prompt + user message)`. The log
also stores each skill file's version and sha. Same form and same files give
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
           id = "openai/gpt-6-luna-decisions",
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
  for; each item has options or an `open_format`.
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
- **Startup check.** `app.R` parses every skill file when the app starts and
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
  the endpoint names them; skill file versions; prompt hash and whether the
  prompt was edited; which items came from which candidate; and the line
  "Expert-review appraisal and first drafts by language models. Not a
  pretest. Test with real respondents before fielding."
- When a language other than the source is involved, the TRAPD block from
  the skills is printed above the disclosure block.
- **Run log**, one JSON file per session, downloadable: for each round the
  form, the system prompt and user message, hashes, raw replies, parsed
  objects, the shuffle seed and candidate-to-model map, R's checks, the
  analyst's kept items. Nothing is written outside the session's temporary
  folder, which is deleted when the tab closes.


## 9. Tests

- `tests/smoke.R`, no API calls, run from inside `QuestionR/` with
  `Rscript --no-init-file tests/smoke.R`: the app loads with
  `shiny::shinyAppDir()`; every skill file parses; for each task and each
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
  every skill file, the smoke test output, and from Phase 1 the four
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
| 1 | Skills loader and prompt assembly | every skill file parses; the smoke test's assembly and determinism checks are green; an assembled prompt for each task is written to `STATUS.md` for Kevin to read |
| 2 | Model layer, both API styles, home profile | `tests/openrouter_check.R` shows the three worker IDs served and answering; `tests/llm_check.R` green at home for the PM and all three workers; JSON repair exercised by the smoke test |
| 3 | Generate flow: brief check, prompt approval, workers, coded defaults, blind appraisal, keep items, run again | one full run per generate task at home with three candidates; candidates relabelled; no model name in the appraisal prompt; a failed worker does not stop the run |
| 4 | Evaluate flow and the gold test | on `gold_items.csv` with the PM model: share of the 48 known problems found at severity 5 or above, and findings at severity 5 or above per control item, both reported in `STATUS.md`. Target: at least 65 percent found and at most 1.0 per control item. Below target is reported, not hidden, and goes back to the Claude project for skill changes |
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
- **The Claude project (JPSM):** the skill files, `www/methodology.md`, this
  design, and review of each phase's `STATUS.md` report. Skill changes are
  made there, from the source materials, not by Claude Code.
- **Kevin:** open decisions in `STATUS.md`, reading the skills, the work
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
- **Do not edit `www/skills/*.md`.** The review script checksums them. If a
  file will not parse, change the parser, or stop and say so in `STATUS.md`.
- **Say what was not done.** `STATUS.md` lists anything skipped, stubbed,
  hard-coded or left failing. A test is never weakened to make it pass.
- **End of session.** Update `STATUS.md`: what was done, the numbers, what is
  next, anything that surprised you.
