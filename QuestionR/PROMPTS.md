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
