# Prompts for Claude Code

Paste one prompt per session, from the repository root (`D:\repos\DrSvyR`).
Each ends at a review gate: bring `QuestionR/REVIEW.md` and
`QuestionR/STATUS.md` back to the Claude project before the next one. Later
prompts are added here after each review.

## Phases 0 and 1: scaffold, skills loader, prompt assembly

```
Read CLAUDE.md, then QuestionR/DESIGN.md, QuestionR/STATUS.md,
QuestionR/www/skills/README.md and QuestionR/tests/review.R. Read
svysegment/app.R, svysegment/R/llm.R, svysegment/R/ai_reflexes.R and
office_logo() in svysegment/R/ui_help.R for the patterns DESIGN.md section 3
says to copy.

Create branch questionr from main. Do Phase 0, then Phase 1, exactly as
DESIGN.md section 10 defines them. Then stop.

Rules:
- The root CLAUDE.md hard rules apply. No for or while loops, native pipe
  only, R/ holds function definitions and constants only.
- Do not edit anything in QuestionR/www/skills/. It is checksummed.
- Do not change what QuestionR/tests/review.R checks. If it has a bug, fix
  only the bug and report the diff in STATUS.md.
- skills.R must define build_prompt(form) and build_checklist(form) exactly
  as the contract in DESIGN.md section 5 says, including the form field
  names and the PREPARE labels.
- No model calls in these two phases. Do not write llm.R beyond what Phase 0
  needs for the key box.
- Do not invent package functions or arguments. Check installed help. Record
  each VERIFY you resolve in STATUS.md with the function and arguments found.
- Never weaken a test to make it pass. If something in DESIGN.md or the
  skills cannot be done as written, stop and say so in STATUS.md.

After each phase, from inside QuestionR/ in PowerShell:
  & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/smoke.R
  & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/review.R <phase>
Fix what fails in your own code and rerun until REVIEW.md shows no FAIL that
you can fix. Leave any FAIL you cannot fix visible and explain it.

Commit once per phase, REVIEW.md included. Do not push.

Finish by updating STATUS.md: what was built, decisions taken and their
defaults, anything skipped, stubbed or hard-coded, anything that surprised
you, and every remaining FAIL in REVIEW.md with its cause. Then stop and
tell me to take REVIEW.md and STATUS.md to the Claude project.
```

## Phase 1b and Phase 2: review changes, then the model layer

```
Read CLAUDE.md, then QuestionR/DESIGN.md and QuestionR/STATUS.md, above all
the section "Review of Phases 0 and 1". Read the changed skill files in
QuestionR/www/skills/ (core, generate, attitudinal, behavioral, sensitive,
evaluate, README) and QuestionR/tests/review.R, which has new checks.

Stay on branch questionr. First commit the files the Claude project changed
(DESIGN.md, STATUS.md, PROMPTS.md, tests/review.R, www/skills/) as they are,
in one commit of their own.

Phase 1b. Bring R/skills.R and tests/smoke.R into line with DESIGN.md
sections 4 and 5 as they now read:
- cross_cultural.md is sent when a country is given, or the output language
  or the source language is not English.
- "Output language:" is always printed, English when blank. "Source
  language:" only when filled and different from the output language.
- For Evaluate, a CHECKLIST block of "id: question" lines, exactly what
  build_checklist(form) returns, sits between QUESTIONNAIRE and CHARACTERIZE.
  Drafting prompts carry none.
Run tests/smoke.R and tests/review.R 1 until section 6 of REVIEW.md shows no
FAIL for all five forms. Commit.

Phase 2, as DESIGN.md section 10 defines it: R/llm.R for both API styles,
the Start here connection check, tests/llm_check.R.
- Resolve the VERIFY in DESIGN.md section 6 first: read the installed ellmer
  help for chat_anthropic and for the OpenAI-compatible function, and record
  in STATUS.md the function, the arguments used, and the ellmer version.
  Use only arguments the help page lists.
- Copy the logic of svysegment/R/llm.R that DESIGN.md section 3 names: the
  key in a closure, parse_json_block() with its repairs, clean_model_reply(),
  is_placeholder_reply(), JSON_QUOTE_RULE, the client-error class, retry with
  a session cap. One call function serves both API styles.
- In R/, a model with key_source "analyst" must never fall back to the
  environment. Only a model with key_source "server" reads its key_var.
- tests/llm_check.R may read ANTHROPIC_API_KEY and OPENROUTER_API_KEY from
  .Renviron and passes the PM key to the call function directly. For this
  phase it makes one small JSON call to each of the four models using the
  attitudinal review form from tests/review.R with n_items = 2, and writes
  model, seconds, whether the JSON parsed, whether the reply has exactly 2
  items, and the first 300 characters of each reply to tests/llm_check.out.
  No brief check, appraisal or gold test yet.
- Before any live call, tell me the number of calls and the rough cost, and
  wait for my yes.
- Add JSON repair cases to tests/smoke.R (a stray inner quote, a missing
  closing quote, a fenced reply, a placeholder reply, a reply cut off at the
  token limit).

The rules from the first prompt still hold: root CLAUDE.md hard rules, no
edits to www/skills/, no change to what tests/review.R checks, no invented
functions or arguments, never weaken a test, do not push.

After each of the two phases run tests/smoke.R and tests/review.R (1 after
Phase 1b, 2 after Phase 2) and commit with REVIEW.md. Finish by updating
STATUS.md as before, including every remaining FAIL and anything a model did
that the skills did not expect. Then stop and tell me to take REVIEW.md,
STATUS.md and tests/llm_check.out to the Claude project.
```

## Phase 3: registry, flow engine and the Generate screens

```
Read CLAUDE.md, then QuestionR/DESIGN.md, above all section 12, which wins
over the earlier sections. Read QuestionR/STATUS.md, the skill files
QuestionR/www/skills/pm_brief.md, pm_appraise.md and generate.md, and
QuestionR/tests/review.R, which has a new section 8 for this phase.

First commit the files the Claude project changed, as they are, in one
commit: DESIGN.md, PROMPTS.md, tests/review.R, www/methodology.md,
www/skills/pm_appraise.md.

Do Phase 3 as DESIGN.md section 12 defines it, in three commits:

3a. Registry and assembler. Replace TASK_FILES and TASK_ASK with the TASKS
    registry. Add build_step_prompt(form, step, ...); keep build_prompt(form)
    as the "work" step with byte-identical output (the hashes in REVIEW.md
    section 6 must not change). Smoke and review.R 2 stay clean.

3b. Engine and checks, no Shiny. R/checks.R: the reply schemas and
    validators, item count (parts not counted), coded defaults. R/flow.R:
    run_brief, run_drafts, run_appraisal with exactly the arguments and the
    result fields in section 12. They reach a model only through ask; they
    never look up a key and never call Shiny. Candidates are relabelled A,
    B, C in an order shuffled by seed; no model id or name may reach the
    appraisal prompt. A worker that fails or returns an invalid reply is
    recorded as failed and the run goes on. Extend tests/smoke.R to run the
    whole flow on a fake ask.

3c. Screens. One module per tab, reading the registry: Brief (task
    dropdown, the fields the task lists, a tick box per worker, brief check
    with a Skip button), Prompt (approve, or edit; an edited prompt is
    marked edited with both hashes), Results (per candidate: items with
    parts indented, coded defaults, failed checks with the failing words;
    then coverage, differences, the merged option labelled untested, what
    to test first; a tick per item to keep), Run again (the form kept, a
    "what to change" box that becomes the REVISION block). Every model call
    sits behind an error handler that puts a plain message on the page, and
    a progress line shows before each call. Tabs for later phases stay as
    placeholders.

Rules, unchanged: root CLAUDE.md hard rules; no edits to www/skills/; no
change to what tests/review.R checks (a bug in it: fix only the bug and
report the diff); no invented functions or arguments (ellmer is 0.4.2; check
installed help); never weaken a test; do not push. If something in section
12 cannot be built as written, stop and say so in STATUS.md.

After 3c: tell me the number of calls and the rough cost of one live run
through the engine (a 3-item attitudinal draft, all three workers, brief
check and appraisal) and wait for my yes. Save its run log as
tests/run_generate.json, with no key in it.

Then run tests/smoke.R and tests/review.R 3 until there is no FAIL you can
fix, and commit with REVIEW.md.

Finish by updating STATUS.md: what was built, decisions and their defaults,
anything skipped or stubbed, seconds and tokens for each live call, anything
a model did that the skills did not expect, every remaining FAIL, and a
short click-through list for Kevin to try in the browser. Then stop and tell
me to take REVIEW.md, STATUS.md and tests/run_generate.json to the Claude
project.
```

## Phase 4: review changes, the Evaluate flow, token measurement, gold test

```
Read CLAUDE.md, then QuestionR/DESIGN.md sections 12 and 13 (13 wins where
they differ), QuestionR/STATUS.md, the changed skill files
QuestionR/www/skills/generate.md and pm_appraise.md (both now 0.3) and
evaluate.md, and QuestionR/tests/review.R, which has a new section 9.

First commit the files the Claude project changed, as they are, in one
commit: DESIGN.md, PROMPTS.md, tests/review.R, www/skills/generate.md,
www/skills/pm_appraise.md.

Do Phase 4 as the table in DESIGN.md section 13 defines it, steps 4a to 4e,
one commit each.

Notes:
- 4a changes the drafting prompts once, because generate.md changed. Record
  the new hashes; from then on they must not move.
- The gold items: take the 20 flawed and 7 control questions, their scales
  and the 48 known problems from the authors' public replication repository,
  github.com/PatrickSturgis/cogbot-replication. Keep their wording exactly.
  Put the citation (Sturgis, Roberts and Robinson 2026, Survey Futures
  Working Paper 15) in the file header. If you cannot get the file, stop and
  tell me; do not write the items from memory.
- Review each gold item alone, as a one-question questionnaire, with the
  form: research question "Evaluate this survey question", population
  "Adults in the general population", mode web, no country, English. The
  model must not see the answer key or which set an item is in.
- Match findings to the key yourself, after all 27 reviews are saved, reading
  each finding beside that item's known problems. Exact: same problem, same
  framing. Approximate: same underlying issue, different emphasis. Each
  finding matches at most one known problem and each known problem at most
  one finding. Say in gold_summary.md that the matching was done by you, the
  builder, and is to be checked.
- Do not change a skill, a prompt, a threshold or a test to improve the gold
  numbers. Report them as they come.
- Live calls: before 4d say the cost and wait for my yes; before 4e say the
  number of calls (27) and the cost and wait for my yes. Save raw replies
  under tests/gold_runs/, with no key in them.
- If any live call is cut off at its ceiling, record it and go on; do not
  raise a ceiling during the gold test.

Rules, unchanged: root CLAUDE.md hard rules; no edits to www/skills/; no
change to what tests/review.R checks (a bug in it: fix only the bug and
report the diff); no invented functions or arguments (ellmer is 0.4.2; check
installed help); never weaken a test; do not push. If something in section
13 cannot be built as written, stop and say so in STATUS.md.

At the end run tests/smoke.R and tests/review.R 4 until there is no FAIL you
can fix, and commit with REVIEW.md.

Finish by updating STATUS.md: what was built, decisions and their defaults,
anything skipped or stubbed, seconds and tokens for the live calls, the gold
numbers, anything a model did that the skills did not expect, every
remaining FAIL, and an updated click-through list. Then stop and tell me to
take REVIEW.md, STATUS.md, tests/review_tokens.md, tests/gold_summary.md and
tests/gold_matches.csv to the Claude project.
```

