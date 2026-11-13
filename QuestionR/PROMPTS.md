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

## Phase 4e: the gold test, with the items file from the Claude project

```
tests/gold_items.csv is now in place, written by the Claude project from
Appendix B of the paper (the replication repository named there does not
exist). Read its four header lines. Do not edit the file.

Check it first and tell me what you find: 27 items (20 flawed, 7 control),
48 known problems, one row per known problem and one row per control item,
columns id, set, topic, question, scale, scale_complete, problem_id,
problem_type, problem, needs_full_scale. Lines starting with # are comments.

Then do step 4e of DESIGN.md section 13, with these additions:

- What the model is shown for each item, as the pasted questionnaire, and
  nothing else from the file:
    Q1. <question>
    Response options: <scale>
  When scale_complete is FALSE, write the second line as
    Response options: a scale running from <first> to <last> (the options in
    between are not shown in this test)
  so the model is not led to think the two end options are the whole scale.
- The paper prints only the end options for 16 of the 27 scales. Three known
  problems (needs_full_scale TRUE) cannot be judged without the options in
  between. Report the share found twice: of all 48, and of the 45 that can
  be judged. Report findings per control item twice as well: all findings at
  severity 5 or above, and those left after setting aside any finding that
  is only about the in-between options not being shown.
- Everything else as section 13 and the Phase 4 prompt say: each item
  reviewed alone through run_review(); the model never sees the answer key,
  the topic, the set or the id beyond "Q1"; raw replies saved under
  tests/gold_runs/ with no key in them; matching done by you after all 27
  are saved, exact, approximate or none, one to one; no skill, prompt,
  threshold or test changed to move the numbers; a call cut off at its
  ceiling is recorded and not rerun.
- In tests/gold_summary.md also give: detection by problem_type; seconds and
  output tokens per item (mean and range); the count of findings below
  severity 5 on flawed and on control items; and every finding at 5 or above
  on a flawed item that matched nothing, in full, for the Claude project to
  judge.

Before any live call tell me the number of calls (27) and the cost, and wait
for my yes.

Then finish Phase 4: run tests/smoke.R and tests/review.R 4 until there is
no FAIL you can fix, update STATUS.md as the Phase 4 prompt says, including
the settings from 4d (evaluation ceiling 43,000 tokens, paste cap 4,000
characters), commit with REVIEW.md, do not push, and stop. Tell me to take
REVIEW.md, STATUS.md, tests/review_tokens.md, tests/gold_summary.md and
tests/gold_matches.csv to the Claude project.
```

## Phase 5: review rulings, long questionnaires, output, methodology

```
Read CLAUDE.md, then QuestionR/DESIGN.md section 14 (it wins over earlier
sections where they differ) and section 8, QuestionR/STATUS.md, the changed
skill file QuestionR/www/skills/evaluate.md (now 0.3),
QuestionR/www/methodology.md, and QuestionR/tests/review.R, which has a new
section 10.

First commit the files the Claude project changed, as they are, in one
commit: DESIGN.md, PROMPTS.md, tests/review.R, www/skills/evaluate.md,
www/methodology.md.

Do Phase 5 as the table in DESIGN.md section 14 defines it, steps 5a to 5e,
one commit each.

Notes:
- 5a changes the Evaluate prompts once, because evaluate.md changed. Record
  the new hashes; the drafting hashes must not move.
- 5b: run_review() for a one-part questionnaire must give the same prompt
  and hash as before 5b (apart from the 5a change). The item and instrument
  ASK sentences are fixed text in the TASKS registry; show them in
  STATUS.md. The engine stays free of Shiny: progress goes through the
  progress argument.
- 5c: the output is built by plain functions in R/checks.R (or a new
  R/output.R if checks.R passes about 600 lines; the budget is 12 files),
  so smoke can build it without a browser. The disclosure block names the
  profile, each model id as the endpoint names it, the date, each skill
  file's version, the prompt hashes and whether a prompt was edited, which
  candidate each kept item came from, and the line "Expert-review appraisal
  and first drafts by language models. Not a pretest. Test with real
  respondents before fielding." No key, ever, in the output or the log; add
  a smoke check that a planted key string is absent from both.
- 5d: render the markdown with a function that is already installed with
  Shiny; check installed help, and say in STATUS.md which you used.
- 5e: before the live run tell me the number of calls and the rough cost
  and wait for my yes. Write the 30 questions yourself, plain and varied,
  with a few deliberate faults; they are only there to exercise the parts.

Rules, unchanged: root CLAUDE.md hard rules; no edits to www/skills/; no
change to what tests/review.R checks (a bug in it: fix only the bug and
report the diff); no invented functions or arguments; never weaken a test;
do not push; do not rerun the gold test. If something in section 14 cannot
be built as written, stop and say so in STATUS.md.

At the end run tests/smoke.R and tests/review.R 5 until there is no FAIL you
can fix, and commit with REVIEW.md.

Finish by updating STATUS.md: what was built, decisions and their defaults,
anything skipped or stubbed, the 5e numbers, anything a model did that the
skills did not expect, every remaining FAIL, and an updated click-through
list that covers both flows end to end, the Output tab pasted into Word,
and the Methodology tab. Then stop and tell me to take REVIEW.md, STATUS.md,
tests/review_long.md, tests/output_generate.txt and tests/output_review.txt
to the Claude project.
```

## Phase 6: ready for work

```
Read CLAUDE.md, then QuestionR/DESIGN.md section 15 (it wins over earlier
sections where they differ) and section 12 "Work readiness", and
QuestionR/STATUS.md.

First commit the files the Claude project changed, as they are: DESIGN.md
and PROMPTS.md.

Do Phase 6 as the table in section 15 defines it, steps 6a to 6d, one commit
each, then prepare 6e.

Kevin's instruction for this phase: as few scripts as possible, each as
simple as possible. So:
- Add no new file. The budget of 12 is full; 6a should bring it down.
- Prefer deleting to adding. Where a helper is used once, fold it in; where
  two do the same job, keep one. Do not restructure working code for its
  own sake, and change no behaviour while tidying.
- New settings go in app.R section 1 with a plain comment each. No new
  abstraction for them.
- Add only the smoke checks section 15 names. Do not grow tests/review.R.

Notes:
- 6b: find the OpenRouter id for the project manager model in OpenRouter's
  public model list; do not guess it. Check installed ellmer help before
  using reasoning_effort or renaming the token limit; if ellmer 0.4.2 does
  not support one of them, say so in STATUS.md and leave it out.
- 6c: the pilot notice gives the gold result exactly as
  www/methodology.md states it, with its limits. Do not round it up.
- 6d: write for an analyst who has not seen this repository. State nothing
  about Posit Connect that you have not verified; mark the rest "to check
  at work".
- No live call in this phase except the connection check under the
  rehearsal profile, with my pasted key, when I run 6e myself.

Rules, unchanged: root CLAUDE.md hard rules; no edits to www/skills/; no
change to tests/review.R; no invented functions or arguments; never weaken
a test; do not push; do not rerun the gold test. The prompt hashes must not
move in this phase.

At the end run tests/smoke.R and tests/review.R 5 until both are clean, and
commit with REVIEW.md.

Finish by updating STATUS.md: what was removed, what was added, every file
left and its one job, line counts before and after, anything in section 15
you could not do, and the 6e click-through list for me under the rehearsal
profile. Then stop and tell me to run 6e and to take REVIEW.md, STATUS.md
and README.md to the Claude project.
```

## Phase 7: changes after Kevin's rehearsal

```
Read CLAUDE.md, then QuestionR/DESIGN.md section 16 (it wins over earlier
sections where they differ), QuestionR/STATUS.md, the rewritten skill file
QuestionR/www/skills/pm_appraise.md (now 0.4), and the two page texts
QuestionR/www/start.md and QuestionR/www/methodology.md.

First commit the files the Claude project changed, as they are, in one
commit: DESIGN.md, PROMPTS.md, tests/review.R, www/skills/pm_appraise.md,
www/start.md, www/methodology.md.

Do Phase 7 as the table in section 16 defines it, steps 7a to 7d, one commit
each.

Kevin's standing instruction: as few scripts as possible, each as simple as
possible. Add no new code file. Delete the code and tests the old appraisal
screens needed. Do not build more than section 16 asks for.

Notes:
- 7a: the reviewer returns letters and ids; R copies the wording. Edits and
  swaps by the analyst live in the session state and the run log, never in
  the drafts themselves. Keep the editable fields plain: a text box for the
  stem, one for each option, a remove button.
- 7b: check installed ellmer help before writing anything. Root CLAUDE.md
  rule 3 is lifted by Kevin for model calls only, as section 16 says; amend
  the rule in one sentence and change nothing else in that file. The engine
  stays free of Shiny. If the documented way needs the Shiny event loop,
  say in STATUS.md how smoke exercises it.
- 7c: render the two markdown files as they are. Do not rewrite their text;
  if a line does not fit the page, tell me.
- Before any live call say the number of calls and the rough cost and wait
  for my yes. One live draft run (3 items, all workers, the reviewer) is
  enough; record seconds for the drafts sent together against the 87
  seconds they took one after another in Phase 3.

Rules, unchanged: root CLAUDE.md hard rules apart from the amendment above;
no edits to www/skills/; no change to what tests/review.R checks (a bug in
it: fix only the bug and report the diff); no invented functions or
arguments; never weaken a test; do not push; do not rerun the gold test.

At the end run tests/smoke.R and tests/review.R 5 until both are clean, and
commit with REVIEW.md.

Finish by updating STATUS.md: what was removed, what was added, every file
left and its one job, the timing, anything in section 16 you could not do,
and a short click-through list for me. Then stop and tell me to try it and
to take REVIEW.md and STATUS.md to the Claude project.
```

## Phase 8 (revised 2026-11-13)

```
Read CLAUDE.md, then QuestionR/DESIGN.md sections 16 and 17, QuestionR/STATUS.md
(Phase 7) and QuestionR/www/skills/README.md. This prompt REPLACES the Phase 8
prompt at the end of QuestionR/PROMPTS.md: overwrite that section with this
prompt, word for word, under the heading "## Phase 8 (revised 2026-11-13)".
Where this prompt and DESIGN.md section 17 disagree, this prompt wins; add a
short note at the end of section 17 saying so and listing what changed.

Confirm `git branch --show-current` is questionr. Commit the Claude project's
files already on disk first, alone, as "QuestionR: changes from the Claude
project": QuestionR/DESIGN.md, QuestionR/PROMPTS.md, QuestionR/www/methodology.md,
QuestionR/www/start.md, QuestionR/www/how_it_works.svg, QuestionR/www/fw_*.svg,
QuestionR/www/skills_materials/README.md. Leave QuestionR/skills_next/ for 8a.

Kevin's rulings, which this phase implements. Do not reinterpret them:
1. The analyst never sees the system prompt (the rules). Not on the Prompt tab,
   not in a collapsed panel, nowhere on that page. It is still sent and still
   recorded in the run log and the Output disclosure.
2. The analyst sees one editable box, the message. It starts with this persona,
   exactly as written here:
   "You are a senior survey methodologist trained in the Total Survey Error
   tradition, working for a public opinion analyst who knows the subject matter
   and the country but is not a questionnaire design specialist. Your job is to
   reduce measurement error: you judge every question by what a respondent must
   do to understand it, recall the information, form a judgment and report an
   answer. Write plainly. You draft and appraise; the analyst decides, and
   nothing you produce replaces testing with real respondents."
   (It is the ## Persona of core.md; read it from there, do not paste a copy
   into the code.)
3. Analysts can edit the message. They cannot edit the skills.
4. The frameworks that guided the skills must be easy to find and complete,
   with diagrams and short summaries, cited only as the webinar slides cite
   them.
5. Remove every script and file that is no longer needed.

One commit per item below.

8a. Skills and the message.
    - Move QuestionR/skills_next/{core,attitudinal,behavioral,sensitive,README}.md
      over the same names in QuestionR/www/skills/ and delete skills_next/.
      They are the Claude project's files: move them, do not edit them. Change
      the parser in the same commit, or the app will not start.
    - Parser (R/skills.R): accept "## Guidelines" (an optional heading line,
      then bullets). Still stop on any other unknown section.
    - The message for a draft, in this order: the persona; "Brief:" and the
      form's lines; "Task:" and the ask sentence; core.md's Guidelines; the
      task file's Guidelines. For a review: the persona, the brief, the task,
      the questionnaire as pasted, core.md's Guidelines. The labels PREPARE,
      ASK and CHARACTERIZE are no longer written.
    - The persona leaves the system prompt, so it is sent once.
    - R appends the review checklist (where there is one) and the reply format
      AFTER the analyst's text when it sends. The analyst never sees them, so
      an edit cannot break parsing.
    - The brief check and the appraisal are never shown to the analyst. They
      keep their layout, apart from the persona's move.
    - Every prompt hash changes. Record the new ones in STATUS.md.

8b. Prompt tab (R/ui_generate.R). Delete the "System prompt (the rules)" text
    area, its label, and every read of input$system. Show only the message
    box, labelled "The prompt (you can edit this)", then one line under it:
    "The survey design rules are sent with this prompt every time and cannot
    be edited here. You can read them on the Methodology tab." Do the same
    for Evaluate. Then grep the whole app (R/, app.R, www/) for any other
    place that shows the system prompt to the analyst and remove it, except
    the run log and the Output disclosure. List every place you checked in
    STATUS.md.

8c. Frameworks in www/methodology.md and www/fw_*.svg. Kevin authorises you
    to edit these files in this phase.
    Source material: the slide PDFs in QuestionR/www/skills_materials/
    (Quex_Design_Session1.pdf, Quex_Design_Session2.pdf,
    Quex_Design_Session_3.pdf). Read the relevant pages as images. Every
    label, arrow and reference must come from a slide. If a slide does not
    give something, leave it out and say so in STATUS.md. Do not invent
    content or references, and do not add slide numbers.
    - Move "## The frameworks behind the rules" to directly after "## What it
      is built on", and open it with one sentence: these frameworks are what
      the skills were written from, and each skill below names the ones it
      draws on.
    - Total Survey Error, expanded (www/fw_tse.svg). The current diagram shows
      only the measurement side. Redraw it with both sides as in Session 1's
      "Survey from a quality perspective" slide, adapted from Groves et al.
      (2009), Figure 2.5. Measurement: construct, measurement, response,
      edited response, with validity, measurement error and processing error.
      Representation: target population, sampling frame, sample, respondents,
      post-survey adjustments, with coverage, sampling, nonresponse and
      adjustment error. Both meet at the survey statistic. Highlight validity
      and measurement error as the errors the slide calls essential to
      questionnaire design. If the slide image shows anything different from
      this description, follow the slide and say what differed.
    - From construct to question (NEW, www/fw_construct.svg). Two parts, from
      Session 1:
      (i) the three ways a question fails: measure the wrong concept
          (specification error), measure the right concept imperfectly
          (operationalization error), measure the right concept but the
          respondent's answer differs from the true value (response error),
          with the slide's "Last week, did you work..." example;
      (ii) decomposition: from abstract, multidimensional concepts to
          specific, single-dimensioned domains (Peytcheva and Yan 2025, as
          the slide cites it), and the "errors from conceptualization to
          operationalization to analysis" slide (Willimack and Snijkers 2012,
          as the slide cites it). Draw that slide's content only.
      Write a short summary saying this is why every draft starts from the
      construct and writes one item per domain (core.md construct_first).
    - Keep fw_response.svg, fw_testing.svg and fw_trapd.svg. Check each
      against its slide and correct anything that differs.
    - Each framework: diagram, a 3 to 5 sentence summary in plain words, then
      an italic line with its references exactly as the slides give them.
      Same visual style as the existing SVGs: own white panel, no JavaScript.
    - Skills table: add a column "Frameworks", filled from each file's Source
      lines (Total Survey Error, response model, construct and decomposition,
      testing methods, TRAPD, sensitive questions). If a skill's Source lines
      name none of them, write "Session guidelines". Do not guess.
    - Below the table, one closed panel per skill file in the order core,
      generate, attitudinal, behavioral, sensitive, mode, cross_cultural,
      evaluate, pm_brief, pm_appraise. Title: the file's "# " heading and
      Version. Body: the file as markdown with HTML comments removed. Use the
      reader in R/skills.R; do not write a second parser. Do not draw
      www/skills/README.md.
    - "How it was tested" must stay one section with that exact heading:
      pilot_notice() reads it.

8d. Source code button. APP_SOURCE_URL in app.R section 1, value
    https://github.com/klinares/drsvyr/tree/main/QuestionR. A small outline
    button "Source code", top left of the header. Target _blank,
    rel noopener.

8e. Materials. Add www/skills_materials to QuestionR/.rscignore. In the root
    .gitignore ignore QuestionR/www/skills_materials/*.pdf, then re-admit by
    name only "QuestionR/www/skills_materials/Evaluating Unedited AI-Generated
    Psychometric Scales.pdf" (CC BY-NC-ND). Confirm with `git check-ignore -v`.
    The other PDFs stay on disk: 8c reads them.

8f. Start here key text. Replace the four TODO strings in KEY_INSTRUCTIONS in
    R/llm.R with:
      where:  "Ask the person who manages the AI service for your office for a key."
      create: "Use a key issued to you, not one shared by a team, so that use can be traced to the person who made it."
      models: "The key must be able to reach every model listed under Settings and connection below. Check connections there before you start."
      cost:   "If a request is refused for quota or cost, stop and ask the person who issued the key; do not borrow someone else's."

8g. Remove what is no longer needed. For each candidate, show the evidence
    (grep for callers, or what replaced it), then delete it:
    - functions in QuestionR/R/ with no callers in R/, app.R or the tests,
      including skills_table() if 8c no longer uses it;
    - code that only served the deleted system prompt box or the PREPARE /
      ASK / CHARACTERIZE labels;
    - QuestionR/skills_next/ (after 8a);
    - QuestionR/tests/ outputs that no test reads (check llm_check.out,
      output_generate.txt, output_review.txt, run_generate.json,
      review_long.*). Keep any that tests/review.R or tests/smoke.R reads,
      and say which reads each;
    - `git rm --cached inteRn/tests/live_log.md` (main's inteRn/.gitignore
      excludes it; keep the file on disk);
    - `git rm prompts/extract_reflexes.md`;
    - untracked .Rhistory files anywhere in the repository.
    Do not touch svysegment/ or SurvAI_Expert/. List everything removed in
    STATUS.md with its reason. If you are unsure, do not delete: list it
    and ask.

8h. Hardening. R/checks.R line 397: write the curly quotes as “ and
    ”. In tests/smoke.R, let the two checks that expect <span> inside a
    button accept the label with or without it.

8i. Smoke. Update the checks the changes touch. Add checks that:
    - the Prompt tab's HTML contains no "System prompt" and no text from
      core.md's Reflexes;
    - the message begins with the persona;
    - every .svg in www/ parses as XML;
    - every image named in start.md and methodology.md exists.
    Do not weaken any other check.

Run tests/smoke.R and tests/review.R 5 until both are clean. Then make ONE
live draft run (3 items, all workers, the reviewer) to confirm the new
message still returns items R can parse. Before you run it, say the number of
calls and wait for my yes. Commit with REVIEW.md. Update STATUS.md: what
changed, what was removed and why, the new hashes, the live result, and a
short click-through list. Commit.

Then prepare the merge to main, but do not push:
- `git config user.email` is "your@email.com". Stop and ask me for the
  address, and set it for this repository only.
- `git fetch origin`. Local main is behind origin/main, which has the inteRn
  merge. Make a branch merge-questionr from origin/main and merge questionr
  into it with --no-ff. CLAUDE.md will conflict: keep both the inteRn rows
  and the QuestionR section, and make the Layout table list svysegment,
  QuestionR and inteRn. Check README.md lists all three. Run QuestionR's and
  svysegment's smoke tests from the merged tree.
- Show me `git log --oneline -5`, `git diff --stat origin/main` and the
  merged CLAUDE.md, then stop.

Rules: root CLAUDE.md hard rules; no edits to www/skills/ beyond the move in
8a; no change to what tests/review.R checks beyond what 8a forces (report the
diff); no invented functions, arguments, figures or references; never weaken
a test; do not push.
```
