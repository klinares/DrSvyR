# QuestionR review evidence, Phase 5

Generated 2026-11-12 21:35 by tests/review.R on R version 4.6.1 (2026-06-24 ucrt).
Packages: shiny 1.14.0, bslib 0.12.0, ellmer 0.4.2, purrr 1.2.2, dplyr 1.2.1, stringr 1.6.0, jsonlite 2.0.0, digest 0.6.39

## 1. Git

Branch:
~~~~
questionr
exit status: 0
~~~~
Last commits:
~~~~
9a07c6a QuestionR 6d: README for an analyst who has not seen the repository
ca20ae8 QuestionR 6c: Start here says what is in force; startup and profile notices
76378d6 QuestionR 6b: work settings in app.R section 1
55451c9 QuestionR 6a: tidy, fewer scripts
9e9b6dc QuestionR: changes from the Claude project (design section 15, prompts)
867c3ad QuestionR 5e: one live long review, final STATUS and REVIEW for Phase 5
9af8f4c QuestionR 5e preparation: the 30-question questionnaire and llm_check.R go review30
f15601d QuestionR: readability fixes found in the browser (5c, 5d)
45206ac QuestionR 5d: the Methodology tab
7dc49f5 QuestionR 5c: the Output tab for both flows, the disclosure block and the run log
191dcfb QuestionR 5b: long questionnaires are reviewed in parts
58cfbb3 QuestionR 5a: severity bands in both Results views, evidence comparison, evaluate 0.3 hashes
b026f0a QuestionR: changes from the Claude project (design section 14, evaluate 0.3, methodology, review.R section 10)
f96b3e1 QuestionR Phase 4: gold test results, final STATUS and REVIEW
01c7100 QuestionR 4e preparation: gold items file and the gold runner
exit status: 0
~~~~
Uncommitted:
~~~~
 M R/ui.R
 M REVIEW.md
exit status: 0
~~~~
Changed against main (outside QuestionR/ expect only the root README.md and CLAUDE.md):
~~~~
 CLAUDE.md                                     |    1 +
 QuestionR/.rscignore                          |    7 +
 QuestionR/DESIGN.md                           |  702 ++++++
 QuestionR/PROMPTS.md                          |  391 ++++
 QuestionR/R/_disable_autoload.R               |    5 +
 QuestionR/R/checks.R                          |  447 ++++
 QuestionR/R/flow.R                            |  361 ++++
 QuestionR/R/llm.R                             |  625 ++++++
 QuestionR/R/output.R                          |  352 +++
 QuestionR/R/skills.R                          |  650 ++++++
 QuestionR/R/ui.R                              |  200 ++
 QuestionR/R/ui_generate.R                     |  970 +++++++++
 QuestionR/README.md                           |  157 ++
 QuestionR/REVIEW.md                           | 1872 ++++++++++++++++
 QuestionR/STATUS.md                           | 1732 +++++++++++++++
 QuestionR/app.R                               |  241 +++
 QuestionR/tests/gold_items.csv                |   60 +
 QuestionR/tests/gold_matches.csv              |   68 +
 QuestionR/tests/gold_runs/C1.json             |   98 +
 QuestionR/tests/gold_runs/C3.json             |   98 +
 QuestionR/tests/gold_runs/C4.json             |   98 +
 QuestionR/tests/gold_runs/C5.json             |   98 +
 QuestionR/tests/gold_runs/C6.json             |   98 +
 QuestionR/tests/gold_runs/C7.json             |  108 +
 QuestionR/tests/gold_runs/C8.json             |   98 +
 QuestionR/tests/gold_runs/F1.json             |  128 ++
 QuestionR/tests/gold_runs/F10.json            |  108 +
 QuestionR/tests/gold_runs/F11.json            |  109 +
 QuestionR/tests/gold_runs/F12.json            |  108 +
 QuestionR/tests/gold_runs/F13.json            |  108 +
 QuestionR/tests/gold_runs/F14.json            |  118 +
 QuestionR/tests/gold_runs/F15.json            |  150 ++
 QuestionR/tests/gold_runs/F16.json            |  128 ++
 QuestionR/tests/gold_runs/F17.json            |  108 +
 QuestionR/tests/gold_runs/F18.json            |  149 ++
 QuestionR/tests/gold_runs/F19.json            |  128 ++
 QuestionR/tests/gold_runs/F2.json             |   98 +
 QuestionR/tests/gold_runs/F20.json            |  141 ++
 QuestionR/tests/gold_runs/F3.json             |  118 +
 QuestionR/tests/gold_runs/F4.json             |  150 ++
 QuestionR/tests/gold_runs/F5.json             |  131 ++
 QuestionR/tests/gold_runs/F6.json             |  108 +
 QuestionR/tests/gold_runs/F7.json             |  130 ++
 QuestionR/tests/gold_runs/F8.json             |  108 +
 QuestionR/tests/gold_runs/F9.json             |  119 +
 QuestionR/tests/gold_runs/_calls.csv          |   28 +
 QuestionR/tests/gold_runs/_findings.csv       |  103 +
 QuestionR/tests/gold_summary.md               |  121 ++
 QuestionR/tests/llm_check.R                   |  319 +++
 QuestionR/tests/llm_check.out                 |   24 +
 QuestionR/tests/output_generate.txt           |   60 +
 QuestionR/tests/output_review.txt             |   64 +
 QuestionR/tests/review.R                      |  680 ++++++
 QuestionR/tests/review_long.json              | 1393 ++++++++++++
 QuestionR/tests/review_long.md                |   26 +
 QuestionR/tests/review_long_questionnaire.txt |   89 +
 QuestionR/tests/review_questionnaire.txt      |   15 +
 QuestionR/tests/review_tokens.md              |   18 +
 QuestionR/tests/run_generate.json             |  864 ++++++++
 QuestionR/tests/smoke.R                       | 2863 +++++++++++++++++++++++++
 QuestionR/www/methodology.md                  |   85 +
 QuestionR/www/skills/README.md                |   66 +
 QuestionR/www/skills/attitudinal.md           |   72 +
 QuestionR/www/skills/behavioral.md            |   67 +
 QuestionR/www/skills/core.md                  |   92 +
 QuestionR/www/skills/cross_cultural.md        |   66 +
 QuestionR/www/skills/evaluate.md              |  117 +
 QuestionR/www/skills/generate.md              |   77 +
 QuestionR/www/skills/mode.md                  |   57 +
 QuestionR/www/skills/pm_appraise.md           |   77 +
 QuestionR/www/skills/pm_brief.md              |   42 +
 QuestionR/www/skills/sensitive.md             |   90 +
 README.md                                     |    2 +
 73 files changed, 19559 insertions(+)
exit status: 0
~~~~

## 2. Files and budget

| file | lines |
|---|---|
| app.R | 241 |
| R/_disable_autoload.R | 5 |
| R/checks.R | 447 |
| R/flow.R | 361 |
| R/llm.R | 625 |
| R/output.R | 352 |
| R/skills.R | 650 |
| R/ui.R | 199 |
| R/ui_generate.R | 970 |
| tests/llm_check.R | 319 |
| tests/review.R | 680 |
| tests/smoke.R | 2863 |

Code files counted: 11 of 12 allowed: PASS
R/_disable_autoload.R present and empty of code: PASS

## 3. Hard rules

| rule | found | result |
|---|---|---|
| for / while / repeat, anywhere | none | PASS |
| magrittr pipe %>%, anywhere | none | PASS |
| library() or require() inside R/ | none | PASS |
| Sys.setenv() in the app | none | PASS |
| addResourcePath() or system.file() in the app | none | PASS |
| parallelism (future, furrr, mirai, parallel, parallel_chat*) | none | PASS |
| key read from the environment for a pasted-key model (Sys.getenv in R/, listed for reading) | R/llm.R:125 Sys.getenv | READ |

Top-level expressions in R/ that are not assignments: PASS
Names defined more than once across R/: PASS
pkg::fn calls checked: 32. Not exported by the installed package: PASS

## 4. Skill files

PASS means the file is byte for byte what the Claude project drafted (line endings aside).

| file | result | sha |
|---|---|---|
| README.md | PASS | 47826ef73309cfc3cd72ac45091efb43241a7875d150f2d1fac69a8dbef5b606 |
| attitudinal.md | PASS | fa9e369f521353670f3e245f9318b1eaf8fcddb54163932d53a1ae0642b69a35 |
| behavioral.md | PASS | c22273bf2dbb02e4e939b8ee98bf6980c5dd093398b20312c3e82f92df1c3ead |
| core.md | PASS | 770a402a6dc4b60389e4c266f43cdaa28dc8ccc0e88938f76cb9b72a54379f35 |
| cross_cultural.md | PASS | 6c8a19b8c17b19808b4cfca788b3c76a7595d54a3a25a71e355391cb944bdd4d |
| evaluate.md | PASS | 6d9780ab2f5af0aaac9f4761a00ae3916b10c8ba00cab674f1a7c387fbb838cb |
| generate.md | PASS | 9512f3229d76fb064f316780d2291ba3a405376f19b5f1087e6c9a66d7355ee2 |
| mode.md | PASS | 98d2c27cd11711f142e9903a85efd65c902bef4cfa7f4d615df6b0d3df3f60e0 |
| pm_appraise.md | PASS | f45e6e4ae77020fadf0cc1d6162b84f015300984e4eafcc9e83cf0116472c4eb |
| pm_brief.md | PASS | a1686dbea0a0aa619269086b5f0372b32a017fe07ae252aee20d5e52e3b4856a |
| sensitive.md | PASS | 0ebc82a948f01caed0847f3d4a6cda87216f33dc3039e764cb8c1ab8ac45e726 |

Files in www/skills not on the list: none

## 5. Smoke test output, verbatim

~~~~
Loading required package: shiny

Attaching package: 'bslib'

The following object is masked from 'package:utils':

    page

ok  shinyAppDir() returns a shiny.appobj
ok  app.R sources without error
ok  the settings R/ reads are in the global environment
ok  the Cairo bitmap type is set
ok  the page is served
ok  the classification banner shows
ok  the logo shows, or its placeholder box does
ok  every tab is in the navlist
ok  the key box is on Start here
ok  no tab is a placeholder any more, and the Methodology tab holds the note and the rules table
ok  home profile: PM on a pasted key, three workers
ok  work profile loads
ok  an unknown profile stops the app and names the choices
ok  the profile switch: unset runs APP_DEFAULT_PROFILE; rehearsal is four OpenAI-style models on OpenRouter, all on the pasted key, the project manager anthropic/claude-sonnet-5.5
ok  no key is held before one is pasted
ok  a pasted key is held for the session, trimmed
ok  the key is not in the environment
ok  saving the key bumps key_version
ok  a forgotten key is gone
ok  every skill file parses
ok  each skill file has a title, a version, a sha and at least one reflex
ok  core.md carries the persona
ok  the four files whose reply R parses carry an Output format
ok  the parser found every Source line, Check line and comment in the raw files
ok  a well-formed fixture parses, keeping Check and Source
ok  a reflex with no Say stops, naming the file and the reflex
ok  a misspelt field name stops, naming the reflex
ok  a field wrapped onto a second line stops
ok  a repeated field stops
ok  an empty field stops
ok  a reflex id with capitals or hyphens stops
ok  two reflexes with one id stop
ok  text before the first reflex stops
ok  an unknown section stops
ok  a missing Reflexes section stops
ok  a prohibition wrapped onto a second line stops
ok  an HTML comment that never closes stops
ok  a missing Version line stops
ok  a missing file stops
ok  a prompt assembles for each of 56 task, mode and country combinations
ok  the same form twice gives the same prompt and the same hash
ok  the contract: build_prompt(form) and build_checklist(form), and what build_prompt returns
ok  no Source text is in any prompt
ok  no HTML comment text is in any prompt
ok  no Check question is in a drafting prompt, system or user
ok  no Check question is in a review's system prompt
ok  no Source or Check field label is in any prompt
ok  the files used are core, the task's files, mode, and cross_cultural only with a country
ok  the persona opens the system prompt, and the prohibitions close it, headed as overriding
ok  every prohibition of every file in force is in the system prompt
ok  mode.md keeps any_mode, the modes chosen, and mixed_mode only with more than one
ok  cross_cultural.md is in with a country and out without
ok  every reflex of a drafting task file is in, and of the other task files out
ok  no reflex id appears twice in one prompt
ok  PREPARE, ASK, CHARACTERIZE come in that order, once each as a heading
ok  the Output format of the file that carries it is in the user message, as written
ok  the number of items is in the ask for the drafting tasks
ok  the pasted questionnaire follows ASK, whole and as pasted, and only for Evaluate
ok  a review's CHECKLIST is exactly build_checklist(form), id: question, between QUESTIONNAIRE and CHARACTERIZE
ok  a drafting prompt has no CHECKLIST block and no Check question in its user message
ok  the checklist is a named character vector of the Check lines in force
ok  the checklist follows the mode filter: web in, telephone out, one_thing in
ok  a reflex with no Check line is not in the checklist (restraint, in Evaluate)
ok  a change to any one field of the form changes the hash
ok  a changed questionnaire changes the Evaluate hash
ok  a blank is the same blank: empty, character(0), NA, or only spaces
ok  the order modes are ticked in does not matter
ok  a Windows line ending is the same as a newline
ok  a change to a skill file changes the hash
ok  the PREPARE labels are the contract's, in its order, each on its own line
ok  blank fields leave no PREPARE line, except Output language, which is always there
ok  a blank output language prints as English, and hashes as English
ok  the source language is left out when it is the same as the output language
ok  the source language is printed when it differs from the output language
ok  the survey mode line reads in words, in the fixed order of the modes
ok  a REVISION line is in the ask on a rerun and nowhere else
ok  cross_cultural is sent for a country, a non-English output language, or a non-English source language
ok  cross_cultural is not sent when both languages are English or blank and no country is given
ok  a review with a Spanish source language: cross_cultural in, both language lines, its checks in the CHECKLIST
ok  a form with no research question stops
ok  an unknown task stops
ok  a drafting task with no number of items stops
ok  a number of items that is not a whole number of one or more stops
ok  Evaluate with no questionnaire stops
ok  a field that is not in the contract stops
ok  an unknown survey mode stops
ok  repair: a bare double quote inside a value is escaped, and the rest is kept
ok  repair: the quote the model left off the last value is put back
ok  repair: a reply cut off inside a value is closed, and what arrived is kept
ok  repair: JSON inside a code fence and prose is found
ok  repair: chat-template tokens and a bare 'assistant' line are stripped before parsing
ok  a reply with no JSON fails, and says so
ok  a reply that cannot be repaired fails, carrying the reply
ok  the echoed template ({"stem": "..."}) and an empty object count as no answer
ok  a good reply comes back parsed, with the raw text, the message as sent and one attempt
ok  the message sent is the approved prompt plus the quote rule, and nothing else
ok  a reply that is not JSON is tried again, and the second one is returned
ok  a transient error (503, a timeout) is tried again, and the third attempt succeeds
ok  a reply that never parses fails after exactly three attempts
ok  the failure names the model, the endpoint and why it stopped, and carries the raw reply
ok  a reply cut off at the token limit is a failure even when what arrived would parse, and is not tried again
ok  the ceilings are section 13's (brief 4000, drafting 12000, appraisal 24000) and the timeout 600 s
ok  the echoed example object is a failed attempt, retried
ok  a reply that fails the validator is tried again; one that passes is returned
ok  a validator's own message reaches the analyst when every attempt fails
ok  a client error (bad key, unknown model) is raised at once and not tried again
ok  no key is a client error before any call is made, and says what to do
ok  a failed call uses two repeat attempts of the session's allowance
ok  once the allowance is used the next call fails at once, with the reason, and makes no call
ok  clearing the counters gives the session its allowance back
ok  a pasted-key model ignores ANTHROPIC_API_KEY, even when it is set
ok  a server model reads the variable named in key_var
ok  a server model with the variable unset or empty has no key
ok  each kind of model is told what to do about a missing key
ok  a server model with no key_var, or a key_source that is neither, is a client error
ok  at home the project manager takes a pasted key and the workers a server variable
ok  a pasted-key model gets the pasted key, not the environment's
ok  a key pasted in one session is not visible to another
ok  anthropic: the Anthropic provider, with the model, base URL, ceiling and system prompt given
ok  openai: the OpenAI-compatible provider, with the model, base URL and ceiling given
ok  no temperature is set unless the model's entry sets one
ok  the key travels in a closure that returns it, and is not in the environment
ok  a chat with no key, or an api that is neither anthropic nor openai, is a client error
ok  anthropic style: the key in x-api-key, the ceiling as max_tokens, the system prompt sent, no temperature
ok  openai style: the key as a Bearer token, the ceiling as max_completion_tokens, the system prompt sent, no temperature
ok  a reply carries why it stopped, the endpoint, the tokens and the seconds
ok  a reply that stopped at the token limit says so, in both API styles
ok  a 404 is a client error and carries the endpoint's own words
ok  a 401 is a client error, and the key the endpoint echoed back is blanked
ok  a 502 with no content type is an error the analyst can read, and is not a client error
ok  llm_json() through the real path: the echoed object comes back parsed, with the message as sent
ok  a 404 through llm_json() makes one request, not three
ok  a reply cut off at the ceiling is requested once, then fails saying so
ok  the same on the OpenAI-style call, whose ceiling is max_completion_tokens
ok  the connection check's call: ready when the endpoint answers, one request each, the reply kept
ok  the connection check's call: the endpoint's own words when it refuses, never the key
ok  the connection check makes no call for a model with no key, and says what to do
ok  no key reached the environment
ok  the table lists the project manager and each worker, with the key's source in words
ok  with no pasted key the project manager waits for one, whatever ANTHROPIC_API_KEY holds; the workers are ready
ok  Check connections calls each model that has a key and none that has not
ok  the result shows ready, the endpoint's words for a refusal, and what a keyless model waits for
ok  pasting a key makes the project manager ready, with no key on the page
ok  with a key the project manager is called as well, and no key is on the page
ok  Start here has the models table and the Check connections button
ok  TASKS has the four tasks, each with a label, a kind, files, an ask and fields
ok  a task's kind is draft or review, and only Evaluate is a review
ok  every file a task names is a skill file, core.md leads, and mode.md is in
ok  every field a task shows is a field of the form, and none is the task itself
ok  a drafting task asks for items and shows the count; a review shows the questionnaire instead
ok  a task that is not in the registry stops, naming the choices
ok  TASK_FILES and TASK_ASK are gone: the registry is the only place
ok  build_step_prompt(form, step, candidates, part), and build_prompt(form) is its work step
ok  an unknown step stops, naming the five
ok  the brief check sends core, pm_brief and the task's own files, in that order
ok  the brief check's system prompt holds the brief rules and the task's rules, and no drafting output format
ok  the brief check's user message is PREPARE, ASK, CHECKLIST, CHARACTERIZE, with pm_brief's output format
ok  the brief check names the task the analyst chose, and its CHECKLIST is exactly build_checklist(form)
ok  the brief check is deterministic, and holds no Source text, comment or Check field
ok  the brief check's Check questions are in its user message only, never in the system prompt
ok  the brief check's hash differs from the work prompt's, and a changed field changes it
ok  the appraisal sends core and pm_appraise only, and none of the drafting rules
ok  the appraisal's user message is PREPARE, ASK, CANDIDATES, CHECKLIST, CHARACTERIZE, in that order
ok  the appraisal's CHECKLIST is exactly what the workers' files give, and their questions are not in the system prompt
ok  the appraisal says how many candidates and how many items each was asked for
ok  each candidate is one JSON line with its letter, its stems, its options, its parts and its decisions
ok  a worker's own notes never reach the appraisal, and an empty source_english is left out
ok  the appraisal is deterministic and its hash follows the candidates
ok  the appraisal holds no Source text, comment or Check field
ok  the appraisal stops for a review task, and for no candidate or an unnamed one
ok  a draft with the number of items asked for, each closed or open, passes
ok  a draft with too many or too few items fails, saying how many and how many were asked for
ok  questions in an item's parts are not counted as items
ok  a reply with no items field, or an item with no stem, id or domain, fails naming the field
ok  an item with neither options nor an open_format fails, naming the item
ok  a reply that is not an object, or whose items are not a list, fails
ok  the draft validator is what llm_json() is given: a fields problem is a readable sentence ending in a full stop
ok  a brief check with its fields passes; one with a string for complete, or a question with no ask, fails
ok  an appraisal with its seven fields passes, empty lists included; a missing limits or set_fails fails
ok  a fail must name its check and give a severity from 1 to 10, one about the set too
ok  a format that has no schema stops, naming it
ok  a new output format is one entry: the validator is built from REPLY_SCHEMAS alone
ok  coded defaults match the hand-coded fixture: five labelled points and a don't know
ok  coded defaults match the hand-coded fixture: four points, end labels only, a reference period, no don't know
ok  coded defaults match the hand-coded fixture: an open item
ok  coded defaults match the hand-coded fixture: a curly apostrophe and a not-applicable option
ok  coded defaults match the hand-coded fixture: French: points, don't know and period are not coded
ok  coded defaults match the hand-coded fixture: an item with only a stem and options
ok  the coded defaults read as words for a table, with not coded where it is
ok  a five-point scale whose decisions say there is no midpoint is odd and stated as no midpoint, and R does not say 'midpoint' for the count
ok  what an item says about a midpoint is read as yes, no or not stated, in the phrasings the models used
ok  decisions written as one string or one entry are flagged not itemised, two or more are itemised, none is none
ok  an appraisal's fails are read with whether each check is an id that was sent
ok  a fail is shown at severity 5 or above and folded below it; one with no severity is shown
ok  the fails about a candidate's whole set are kept apart, with the items they name, and count against no item
ok  an item the appraiser gave no entry is not appraised, not a pass; an entry for no item is flagged
ok  a merged item that does not exist, or has a fail rated 5 or above, is a problem; one with only a low fail is not; an empty domain is not
ok  an appraisal with nothing wrong has no flags
ok  each result has exactly the fields the design names
ok  the flow makes one brief call, one call per worker in the workers' order, and one appraisal call
ok  each call gets its step's ceiling, and the brief and appraisal hold no worker's name
ok  every worker gets the same approved prompt, which is the list's 'prompt' attribute
ok  the brief check's prompt is the brief step's, and its reply is kept
ok  an ok draft keeps its parsed reply and a time; the model is the id the endpoint is called by
ok  the labels are A, B, C over the three models, the same for the same seed, and not the workers' order for every seed
ok  candidate A is the draft of the model labelled A, whatever the seed
ok  shuffling by seed leaves the random number generator alone
ok  the appraisal prompt shows each letter with the draft of the model that letter stands for, and no model name anywhere
ok  the appraisal's status, hash and reply are kept, and its error is empty
ok  a worker that errors, and one that returns the wrong number of items, are failed with their reasons; the first still arrives
ok  the appraisal covers only the drafts that arrived: one candidate, A, over the one model that answered
ok  a failed appraisal is recorded with its reason and the labels, and nothing is raised
ok  with no draft there is nothing to appraise, and the project manager is not called
ok  a brief check that errors, or whose form cannot become a prompt, is failed with a plain reason and is not raised
ok  a reply the brief validator refuses is a failed brief check
ok  a model's name in a draft stops the appraisal before it is sent, saying why, and the call is not made
ok  an edited prompt is the one sent to every worker, and is kept as the list's attribute
ok  run_drafts needs a task that drafts, a prompt that is a prompt, and run_appraisal a seed
ok  the engine reaches a model only through ask, and never looks up a key: no flow function calls Sys.getenv or llm_key_for
ok  through llm_json(): a draft with the wrong number of items is retried until it is right, and the whole flow is ok
ok  the call record keeps the reply as sent, why it stopped, the tokens and the attempts
ok  the round is the log: schema 1, the time and a summary first, then the form, seed, prompts and replies, as valid JSON
ok  the summary has one row per call with the step, model, status, seconds, tokens and attempts
ok  no key is in the log, though the call that made it was given one
ok  a round with only the form is a valid log too
ok  the state object is made from STATE_DEFAULTS, and every field a module uses is in it
ok  every field any task lists has a widget spec, so a new task that reuses fields needs no screen change
ok  the registry's progress_ask announces the model on the page before it makes each call
ok  Skip carries the cleaned form and the ticked workers on, marks the brief skipped, and moves to the prompt
ok  a form that cannot be a prompt says why on the page, and goes nowhere
ok  no worker ticked says so, and goes nowhere
ok  no number of items says so, and goes nowhere
ok  the brief check without the project manager's key says what to do and makes no call
ok  with a key the brief check makes one call to the project manager and shows its questions and criteria
ok  the brief check's prompt is the brief step's, and no key is on the page
ok  Continue after a check keeps the check and moves to the prompt
ok  a brief check that fails is said on the page in words, with the reason, and offers to skip
ok  a field the chosen task does not show is blank in the form, whatever was typed there before
ok  a field the task does show is carried (the reference period, for behavioral items)
ok  Evaluate carries its questionnaire, no item count and no workers, and says to leave a blank line between questions, how long one call is and what the limit is
ok  a questionnaire over the cap is refused on the Brief tab with its length and the limit, and nothing moves on
ok  a single block too long for one call is refused on the Brief tab, quoting where it starts, and nothing moves on
ok  a requested change is shown on the Brief tab with the round it belongs to, and can be dropped
ok  the change goes into the form as its revision, and so into the prompt as a REVISION block
ok  dropping the change clears it
ok  the Brief tab has the dropdown, the form, a box per worker, the check and the skip button
ok  each field is shown for exactly the tasks that list it, and the worker boxes for the drafting tasks
ok  a task added to TASKS is in the dropdown, its fields are shown for it, and it assembles a prompt
ok  a worker added to the model list gets its own box, and nothing else changes
ok  the registry and the model list are back as they were
ok  with no form the Prompt tab asks for the Brief first
ok  the assembled prompt is shown whole and editable, with the skill files used
ok  an untouched prompt is shown as assembled, with its hash
ok  approving it as it is records it unedited, with one hash, starts a run and moves to Results
ok  an edited prompt is marked edited, showing both hashes
ok  approving an edited prompt sends the edited text, marks it edited, and keeps both hashes
ok  a browser's line endings are not an edit
ok  an empty prompt is refused on the page, and no run starts
ok  Evaluate's prompt can be read and approved: the button is on and the page says it makes one call
ok  approving a review prompt, edited or not, starts a run with the edited text and both hashes
ok  before any run the Results tab says nothing has been run
ok  a run makes one call per worker and one for the appraisal, and records the round in the state and the log
ok  each candidate is shown by letter with its items, options and the model that wrote it
ok  each item shows the coded defaults and has a tick box to keep it
ok  a failed check is shown with the appraiser's failing words and the check's question; one that was not sent is flagged
ok  an item the appraiser gave no entry is not shown as passed
ok  fails below severity 5 are folded away, not listed, and a candidate's set-level fails are shown once under it
ok  an item whose design decisions are one entry, not several, is flagged on the page (every canned item here)
ok  below the candidates: coverage, differences, the merged option labelled untested, what to test first, the limits
ok  R's checks on the appraisal are shown: the check that was not sent, and the items given no entry
ok  the criteria applied are listed, and the prompt hash and seed are shown, with no model name given to the appraiser
ok  ticking items records them by candidate letter, position and id, and unticking removes them
ok  an item unticked is no longer kept
ok  a second run is a second round in the log, with nothing kept
ok  a worker that failed is listed with its reason, the other two are shown, and the appraisal covers two candidates
ok  a failed appraisal is said in words with its reason; the candidates are still shown, none marked appraised
ok  a run that cannot start (no form) stops with a plain sentence on the page, not an error
ok  Run again is not offered before there is a round to run again
ok  after a round, Run again offers a box for what to change
ok  what is typed becomes the revision, trimmed, and the Brief tab opens with the form as it was
ok  a blank box clears the revision and still goes back to the brief
ok  the page has the Generate tabs' controls, and no tab is a placeholder
ok  no key is anywhere on the page
ok  the log keeps the brief check's and the appraisal's own call records: raw reply, tokens, attempts
ok  a model's own words for labelling every point are read as yes, in the phrasings the live run produced
ok  labels said to be partial or absent are read as no, and a silence is not stated
ok  a cut-off brief check says to try again or skip; a cut-off draft to ask for fewer items; a cut-off appraisal to untick a worker
ok  an error that is not a cut-off gets no cut-off advice
ok  a run drafts at most 10 items: 10 is accepted, 11 is refused saying so, and the form's box stops at 10
ok  a pasted questionnaire over the cap is refused, saying how long it is and what the limit is; at the cap it is accepted
ok  Luna is the last of the workers (decision 15)
ok  a model entry's reasoning_effort reaches the Anthropic-style call as adaptive thinking with that effort; unset sends neither
ok  on the OpenAI-style call reasoning_effort and the name of the token limit reach the wire through api_args, only when the entry sets them; the Anthropic style keeps max_tokens; no profile entry sets either
ok  a review with its five fields passes: findings per question, instrument findings, TRAPD, test_first, not_assessed
ok  a question's id may be a label or a number, and an empty list of findings is a question with none
ok  a review missing a field, or with a finding that has no check, evidence, problem or severity from 1 to 10, fails naming the question
ok  run_review has the fields of run_brief and batches (one entry here), uses build_prompt()'s prompt, and makes one call at the evaluation ceiling
ok  a review that errors, is cut off, or fails the schema is failed with a plain reason and is not raised
ok  a form that is not a review, or has no questionnaire, or is over the cap, is failed without a call
ok  run_review never looks up a key and reaches no model but through ask
ok  check_review gives one row per finding, questions and instrument alike, with the columns the flow needs
ok  a quote that is in the text, and a check that was sent, are accepted; an invented quote and an unknown check are flagged, not dropped
ok  a quote is found whatever its case, spacing, curly quotes or enclosing quotation marks
ok  severity 5 and above is shown, below 5 is not, and a finding with no severity is shown
ok  a review with no findings is a data frame with no rows and the same columns
ok  the review's checks need the CHECKLIST that was sent: ids in it are known, others are not
ok  a review round is a log too: the summary row, the review with its prompt hash and its call record
ok  a review run makes one call to the project manager at the evaluation ceiling, and records the round, with no candidates
ok  the page says it is one review, shows the prompt hash and that it was edited, and does not claim validation
ok  findings are shown question by question, in the order pasted, a question with a numeric id included
ok  a finding at severity 5 or above shows its check and the check's question, severity, quote, rewrite and probe
ok  a finding below 5 is folded away, and flagged when its quote is not in the text or its check was not sent
ok  a question with no finding says none was found by this review, never that it has no problems
ok  instrument-level findings are shown apart, naming the questions involved
ok  an empty TRAPD block is not drawn; what to test first and what was not assessed are
ok  R's checks on the review are counted: the quote that is not in the text and the check that was not sent
ok  the criteria that were applied are listed
ok  a review of translated text shows the TRAPD steps that are still needed, and only those
ok  a review that fails is said on the page in words, with its reason, and the round is still recorded
ok  two findings on one question, a test_first given as plain ids, and no not_assessed are all drawn
ok  run_review sends an edited prompt when given one, and keeps it as the result's prompt with its own hash
ok  severity_band: 7 and above fix, 5 and 6 judgment, below 5 minor, none given judgment (the cut at 5 is unchanged)
ok  a review's findings are shown in three bands, highest first, the Minor band folded away
ok  a question with only minor findings says none is rated 5 or above and shows no band heading
ok  an appraisal's fails use the same bands: a fail with no severity is in the middle band, below 5 is folded
ok  evidence is compared without case, spacing or the kind of quotation mark, with quotes around the whole of it dropped
ok  evidence with an ellipsis, a paraphrase, or nothing is not found, and an ellipsis is not removed
ok  split_questionnaire: more than one part, none over the limit, whole blocks in order, joined by a blank line they give the text back
ok  split_questionnaire: a short text is one part; runs of blank lines and CRLF line endings count as one separator
ok  split_questionnaire: a block over the limit stops, saying which block, how long, and quoting its first words
ok  APP_BATCH_CHARS is 4000 and APP_MAX_PASTE_CHARS is 40000, and both are in the global environment for R/ to read
ok  review_plan: one call of kind all for a short text; an items call per part then an instrument call for a long one
ok  an item call has only its part of the text, the part sentence with its numbers, and every check but the four instrument ones
ok  the instrument call has the whole questionnaire, only the four instrument checks, and the sentence that fills the other fields
ok  the part sentences are fixed text from the registry, so the same part gives the same prompt and hash; the system prompt is the work step's
ok  a part prompt needs a review task and a part of its own kind; a part sentence needs a task that has one
ok  a one-part questionnaire's prompt is the work prompt, as before (same hash), and the registry gives it no part sentence
ok  a long review makes one call per part and one for the instrument, each at the evaluation ceiling, and says before each which it is
ok  a long review's result has run_review's fields and batches: one per call, in order, each with kind, part, status, hash, seconds and its reply
ok  the reply holds all 30 questions in the order pasted, the instrument findings and not_assessed from the instrument call only
ok  the call record of a long review adds up its calls: seconds, and tokens in and out
ok  a part that fails gives status partial naming it, keeps the questions of the other parts in order, and the instrument call still runs
ok  the instrument call failing leaves the questions and an empty instrument; every call failing is failed with no reply
ok  running a failed part again makes one call for it, keeps the other calls as they were, and gives status ok with all 30 questions
ok  an edited prompt cannot be sent in a long review (it is several prompts); a questionnaire with a block too long fails without a call
ok  run_review reaches no model and no Shiny function but through ask and progress
ok  a long review's log summary has one row per call, naming the part; a one-call review keeps its one row
ok  the run log of a long review holds every call: its hash, its prompt, its reply and its call record
ok  the Prompt tab for a long review says it is several calls, shows the first part's prompt, and offers no editing
ok  approving it records the first part's prompt as assembled, not edited, with its hash, and starts the run
ok  a run of a long review asks for one progress step per call, records one round with the summary rows, and shows the part that failed
ok  the page for a long review lists a prompt hash for each call and shows the questions that came back and the instrument findings
ok  the button's input runs that part again, and the page, the review and the round in the log are replaced by one with nothing missing
ok  a drafting output has the kept items in the order they were ticked, each with its id, introduction, stem, numbered options and programming notes
ok  the HTML is plain: headings, paragraphs, an ordered list of options that Word keeps numbered, emphasis for the introduction, a block quote for a part
ok  the HTML and the plain text say the same: every line of the text is in the HTML's text, in the same order
ok  the output language not being English puts the English source wording in italics after each item
ok  a language other than the source puts the TRAPD block above the disclosure block, and an English one has none
ok  the disclosure names the date, the profile, the project manager and each worker model by its id, and which models were asked but did not draft
ok  the disclosure gives the version of each skill file used, and pm_brief.md only when the brief was checked
ok  the disclosure gives each prompt's hash in full, says the drafting prompt was not edited, and says it was when it was
ok  the disclosure says which candidate each kept item came from and the model behind it, and ends with the fixed line
ok  with no item kept, or a tick that points at nothing, the output says so and has no disclosure to make
ok  a review's output is question by question, each question's findings in the severity bands, highest first, the Minor ones listed too
ok  a finding gives its quote, problem, and a rewrite and a probe each said to be untested; a quote R did not find is flagged
ok  the instrument findings, what to test first and what the review could not judge follow, then the disclosure with the review prompt's hash
ok  a review of translated text prints what its trapd field says is still needed, or the fixed lines when it said nothing
ok  a review in parts lists a prompt hash for each call, and one with a part missing says so at the top; no review gives a plain message
ok  the run log is one JSON file with a schema, the profile, the time and every round; the kept items are in it
ok  a planted key is absent from the log, which says where it was taken out, and a string too short to be a key is left alone
ok  no output text or HTML carries a planted key: it is not in the run's data, and scrub_secrets takes it out of anything that is
ok  known_keys gives the analyst's pasted key and a server key, none when there is none; the output and log functions never read a key themselves
ok  the two sample outputs are saved as tests/output_generate.txt and tests/output_review.txt
ok  before anything has run, the Output tab says there is nothing to show and offers no download
ok  a drafting round with nothing ticked says no item has been kept
ok  ticking items on Results puts them on the Output tab in HTML for Word and in a plain text box, with the disclosure block
ok  un-ticking an item takes it off the Output tab
ok  the downloads are the plain text and the run log, and the page says no key is in the log
ok  the text download is the output as plain text; the log download is JSON with a schema, the round and the items kept
ok  a key in the session, and echoed in a model's reply, is in neither the page, nor the text download, nor the log download
ok  a review's Output tab shows the review question by question in the bands, and the disclosure, with no Keep boxes
ok  the review's run log has its round, its prompt hash and its call record
ok  the page has the Output tab's boxes in place of its placeholder, and no key is anywhere on it
ok  skills_table has one row for every reflex of every skill file, with its file, id, when and source, in the order of the files
ok  the Methodology page renders the note: its headings, its numbered list, and its tables as tables
ok  below the note there is a block for each skill file with its title and version, and a row for every one of its reflexes
ok  each rule's source is shown as the skill file gives it, and a rule with none says so
ok  a methodology file that is missing, or a skills folder that is, is said in words and does not stop the page
Warning message:
In file(con, "r") :
  cannot open file 'www/no_such_note.md': No such file or directory
ok  the page's Methodology tab is the note and the table, and the app starts with it (the whole page was built above)
ok  a profile that still holds placeholders says which entries to fill in, the connection check does not call it, and the work profile's page builds; a filled profile says nothing
ok  when the only worker is of the project manager's own family, Results says the appraiser reviewed a draft from its own family; with workers of other families it says nothing
exit status: 0
~~~~

## 6. Prompt assembly

### attitudinal

| check | result |
|---|---|
| system and user are single strings | PASS |
| same form twice gives the same hash | PASS |
| a changed research question changes the hash | PASS |
| persona present | PASS |
| PREPARE, ASK, CHARACTERIZE in that order | PASS |
| no source text sent (IASS/WSS, SURV632, Sturgis, Tourangeau) | PASS |
| no HTML comment or Source or Check field sent | PASS |
| core reflex one_thing present | PASS |
| any_mode present | PASS |
| prohibitions headed as overriding | PASS |
| Output language line always present | PASS |
| reworded prohibition in force (skills 0.2) | PASS |
| existing_items_first only in drafting prompts | PASS |
| CHECKLIST block only in a review, after QUESTIONNAIRE and before CHARACTERIZE | PASS |
| parts field only in drafting prompts | PASS |
| task file sent (attitude_object) | PASS |
| generate.md sent (declare_defaults) | PASS |
| other task files not sent (reference_period, forgiving_intro) | PASS |
| web kept; telephone, mobile_web, mixed_mode dropped | PASS |
| cross_cultural not sent (no country, English) | PASS |
| blank fields left out (no Country, no Reference period line) | PASS |
| Output language: English shown; Source language left out when the same | PASS |
| number of items in the ask | PASS |

hash: 8f3b2f326d01f516a47cb867c120e6a3bcacb31a04eab31ed400a9f534f306fc
files: core.md, generate.md, attitudinal.md, mode.md
characters: system 11026, user 1770

Checklist (id: question):
~~~~
construct_first: Does the item measure the construct or domain named in the brief and only that?
plain_words: Would every member of the target population read each key term the same way, without a definition they do not have?
simple_syntax: Is the stem free of stacked clauses and of negations?
specific_concrete: Is it clear exactly what, whose, where and when the question is about?
one_thing: Does the question ask about exactly one thing, so that no respondent would want to answer its parts differently?
no_presupposition: Does the question apply to every respondent who will be asked it?
neutral_wording: Is the wording free of any push toward one answer?
options_fit: Can every respondent find exactly one option that is true for them?
design_not_topic: Is the item usable as written in the stated mode for the stated population?
labelled_scales: Are all points labelled in one consistent form, with poles that match the construct?
attitude_object: Is the attitude object named and bounded so that respondents will have the same thing in mind?
specific_before_vague: If a general item is included, is it placed before the specific items on its topic?
construct_specific_options: Are the response options in the construct's own terms and not agree-disagree?
balanced_stem: Does the stem state both poles or both positions?
non_attitudes: Is there a route for respondents who have no knowledge of or opinion about the object?
keying: Does the set include items keyed in both directions, without negations?
cover_the_construct: Does each item tap a distinct stated domain, with no item a rewording of another?
any_mode: Does the item work as written in the stated mode?
web: Is everything the respondent needs to answer on screen with the question?
~~~~
System prompt:
~~~~
You are a senior survey methodologist trained in the Total Survey Error tradition, working for a public opinion analyst who knows the subject matter and the country but is not a questionnaire design specialist. Your job is to reduce measurement error: you judge every question by what a respondent must do to understand it, recall the information, form a judgment and report an answer. Write plainly. You draft and appraise; the analyst decides, and nothing you produce replaces testing with real respondents.

REFLEXES: Core (v0.2)
- construct_first (Every item.) Start from the construct in the brief, not the topic. If the construct is abstract or has several dimensions, break it into specific single-dimension domains and write one item per domain. An item that measures the wrong concept is a worse error than one that measures the right concept imperfectly. MUST NOT: Do not widen or change the construct to make an item easier to write.
- response_process (Every item.) Walk the item through the four stages a respondent goes through: comprehension, retrieval, judgment or estimation, reporting. A fault at any one stage is measurement error. Name the stage when you name a fault.
- plain_words (Every question stem, instruction and response option.) Use simple, familiar words that the whole target population uses in the same way. Replace technical terms, jargon, slang and idioms, or define them inside the question. MUST NOT: Do not use a word with more than one common sense where the other sense would change the answer.
- simple_syntax (Every question stem.) One short sentence where possible, main clause first. Move conditions, definitions and time frames into a separate lead-in sentence instead of stacking clauses. MUST NOT: No single or double negations in the stem. No negative interrogatives.
- specific_concrete (Every item.) Name the specific object, behaviour, place and time the question is about. Replace vague quantifiers in stems and options with concrete amounts or frequencies where the task allows.
- one_thing (Every item.) Ask about one thing at a time. Two objects, two behaviours or two qualities joined by "and" or "or" become two items.
- no_presupposition (Every item.) Check what the question assumes about the respondent: that they work, have a partner, use a service, have heard of the topic, hold an opinion. Where the assumption fails for part of the population, add a filter question or a not-applicable option. This fault is easy to miss, so check it explicitly.
- neutral_wording (Every item except a deliberate forgiving introduction to a sensitive question.) Word the stem so no answer is the expected one. No premises stated as fact, no appeals to authority or to what most people think, no emotive terms.
- options_fit (Every closed item.) Response options are exhaustive and mutually exclusive, answer the question that was asked in the same terms, and give every respondent a true answer to pick.
- brief_only (Every sentence you write.) Work only from the brief and these instructions. If the brief does not say something you need (population, mode, reference period, what the estimate is for), say what is missing instead of assuming it. MUST NOT: Do not state facts about the country, the population, its laws, languages or customs that are not in the brief. Do not name a survey, scale or study as the source of an item, and do not describe any item as validated, tested, standard or reliable.
- not_a_pretest (Every output.) What you produce is an expert-review appraisal or a first draft. Say which items most need testing with real respondents and by what method (cognitive interview, web probing, split-ballot experiment, pilot). MUST NOT: Do not describe how real respondents will answer, and do not say an item is ready to field.

REFLEXES: Generate (v0.3)
- design_not_topic (Before writing any item.) Write for the construct, target population, mode and country in the brief. An item for a telephone interview and an item for a mobile web form are different items.
- declare_defaults (Every item you write.) Every response format is a design decision, not a default. For each item state the decisions you made, as separate entries with one reason each: open or closed, number of options, whether every option has a verbal label, whether there is a midpoint, whether there is a don't-know or no-opinion option, the direction the options run, and the reference period if there is one. MUST NOT: Do not reach for a five-point agree-disagree scale, a yes/no pair or an open text box because it is the usual choice.
- labelled_scales (Any ordered response scale.) Give every scale point a verbal label, in the same grammatical form, evenly spaced in meaning. If numbers are shown they run in the same direction as the labels. Decide whether the construct is bipolar (two opposite poles, a meaningful middle) or unipolar (none to a lot) and build the scale to match. MUST NOT: Do not mix label constructions within one scale, and do not use negative numbers on a unipolar construct.
- midpoint_and_dont_know (Any attitude or evaluation item.) Decide both explicitly. Offer a midpoint when a middle position is a real answer on the construct. Offer don't know or no opinion when a real share of the population will not have the knowledge or an attitude; say in the notes that offering it raises its use. Keep a not-applicable answer separate from both.
- response_order (Any closed item.) For unordered lists, note that options should be randomized or rotated where the mode allows, and why: readers favour early options, listeners favour late ones. Keep ordered scales in one direction throughout an instrument.
- count_and_scope (Every request.) Write exactly the number of items asked for. A filter question, a branch or an unfolding bracket that exists only to serve one item goes in that item's parts and is not counted. If the construct cannot be covered in that number, say which domains are left out. MUST NOT: Do not add extra items or alternates that were not asked for, and do not use parts to add questions on another domain.
- existing_items_first (Any request to write new items.) Remind the analyst once, in the notes, that previously evaluated questions on this construct should be looked for first and checked for transfer to this population, language and mode. Using or adapting an existing question is usually better than writing a new one. MUST NOT: Do not suggest specific existing items or sources from memory.
- note_similarity (A draft you have written closely resembles a published item you recognise.) Say so in that item's notes, without naming a source, so the analyst can look for the original and use it with attribution instead.

REFLEXES: Attitudinal scale (v0.2)
- attitude_object (Every attitude item.) Name one clearly bounded attitude object. If the object is broad, give a short definition before the question, in simple words, without making the question long.
- specific_before_vague (Choosing what each item asks.) Prefer specific questions: they are less open to context effects and relate more closely to behaviour. If a general item is needed, place it before the specific items on the same topic and say so in the programming note.
- construct_specific_options (Choosing the response format.) Ask about the construct directly with options in its own terms (how safe, how often, how much confidence) instead of a statement with agree-disagree options. Agree-disagree invites acquiescence and makes the respondent answer two questions at once. MUST NOT: Do not use agree-disagree for statements of fact, for statements with a quantity or comparison inside them, or for statements about the respondent's own experience.
- balanced_stem (Any item that poses a position.) Put both sides in the stem (favor or oppose; should or should not be allowed), or pose the item as a choice between two stated positions.
- direction_then_intensity (A bipolar attitude asked by telephone or interviewer, or where a long scale would be read aloud.) Offer branching: first direction, then how strongly, with a follow-up lean question for those who choose neither. Put the main direction question in the item and the intensity and lean questions in its parts.
- non_attitudes (The population may not have heard of the object or formed a view.) Add a filter question or a no-opinion option so respondents without an attitude are not pushed to invent one. Say in the notes that a strongly worded filter increases no-opinion answers.
- keying (A set of items meant to form one scale.) Vary the direction of items so that a high score does not always mean choosing the same end, to expose acquiescence and straightlining. Write reverse-direction items as positive statements of the opposite pole. MUST NOT: Do not create a reverse item by adding "not" to another item.
- cover_the_construct (A set of items meant to form one scale.) List the domains of the construct first, then write items so each domain is covered and no two items are rewordings of each other. Where the construct has cognitive, affective and behavioural components, say which each item taps.
- context_in_the_set (Ordering the items and noting presentation.) Note in programming that item order within the set should be randomized or rotated where the mode allows, and that a grid should be avoided on small screens.
- scale_is_a_draft (The notes for any set of items meant to form a scale.) State that the set is an untested item pool. Before scores are used it needs a pilot with real respondents and checks of dimensionality and reliability, and subscales need more scrutiny than the total. For use in more than one country or language, comparability has to be tested, not assumed. MUST NOT: Do not predict reliability, factor structure or validity.

REFLEXES: Mode (v0.1)
- any_mode (Any mode.) Write and appraise each item as it will reach the respondent in the stated mode: seen or heard, with or without an interviewer, on what size of screen.
- web (Mode is web, self-administered on a computer.) Respondents read and can see all options: keep unordered lists short and note randomization because early options are favoured. Put definitions in the question text, not behind a click. Keep labels visible for every scale point and spacing even. MUST NOT: Do not rely on an interviewer to clarify, probe or record a volunteered don't know.

PROHIBITIONS (override anything from training)
- Never invent a citation, a survey name, a statistic or a fact about a country.
- Never name a source, an author or a course in what you write. Use a rule's id only in a JSON field that asks for one.
- Never choose for the analyst: you flag and draft, they decide.
- Never write anything outside the JSON fields asked for.
- Never return an item without its response options or a statement that it is open-ended.
- Never return two versions of one item.
- Never present a set of items as an established or validated scale.
- Never assume a mode the brief does not state; ask for it.
~~~~
User message:
~~~~
PREPARE
Research question: How much do adults trust the national electoral commission?
Construct: Trust in the national electoral commission
Target population: Adults aged 18 and over
Survey mode: web
Output language: English

ASK
Write exactly 6 survey items for the brief above, to be combined into one attitude scale. Follow every rule you were given. Reply in the format given at the end of this message.

CHARACTERIZE
Return one JSON object with these fields.

- "items": a list. Each item has:
  - "id": a short code, [construct abbreviation] plus a number.
  - "domain": the single domain of the construct this item measures.
  - "intro": lead-in text read or shown before the question, or an empty string.
  - "stem": the question, in the output language.
  - "options": a list of response options in the order shown, in the output language; an empty list for an open question.
  - "open_format": for an open question, what is entered and its unit; otherwise an empty string.
  - "parts": a list, usually empty. Filter, branch or bracket questions that belong to this item, in the order asked; each has "when" (who is asked it, or "before the item" for a filter), "stem" and "options", in the output language.
  - "programming": routing, filter, randomization and interviewer instructions, in English, as short imperative notes.
  - "decisions": the design decisions required by declare_defaults, one short line each, in English.
  - "source_english": when the output language is not English, the English wording the item was drafted from; otherwise an empty string.
  - "notes": risks, what to test and how, in English.
- "not_covered": domains of the construct left out, or an empty list.
- "missing_from_brief": anything you needed that the brief did not say.
~~~~

### behavioral

| check | result |
|---|---|
| system and user are single strings | PASS |
| same form twice gives the same hash | PASS |
| a changed research question changes the hash | PASS |
| persona present | PASS |
| PREPARE, ASK, CHARACTERIZE in that order | PASS |
| no source text sent (IASS/WSS, SURV632, Sturgis, Tourangeau) | PASS |
| no HTML comment or Source or Check field sent | PASS |
| core reflex one_thing present | PASS |
| any_mode present | PASS |
| prohibitions headed as overriding | PASS |
| Output language line always present | PASS |
| reworded prohibition in force (skills 0.2) | PASS |
| existing_items_first only in drafting prompts | PASS |
| CHECKLIST block only in a review, after QUESTIONNAIRE and before CHARACTERIZE | PASS |
| parts field only in drafting prompts | PASS |
| task file sent (how_many_or_how_often) | PASS |
| telephone, face_to_face, mixed_mode kept; web dropped | PASS |
| cross_cultural sent (trapd, output_language) | PASS |
| form values present (Kenya, Swahili, past 7 days) | PASS |
| Source language shown when it differs from the output language | PASS |

hash: bf022b8c13313a5c576ef8e21004e3e77c123e295c8fd122112073121bfa890a
files: core.md, generate.md, behavioral.md, mode.md, cross_cultural.md
characters: system 15450, user 1831

Checklist (id: question):
~~~~
construct_first: Does the item measure the construct or domain named in the brief and only that?
plain_words: Would every member of the target population read each key term the same way, without a definition they do not have?
simple_syntax: Is the stem free of stacked clauses and of negations?
specific_concrete: Is it clear exactly what, whose, where and when the question is about?
one_thing: Does the question ask about exactly one thing, so that no respondent would want to answer its parts differently?
no_presupposition: Does the question apply to every respondent who will be asked it?
neutral_wording: Is the wording free of any push toward one answer?
options_fit: Can every respondent find exactly one option that is true for them?
design_not_topic: Is the item usable as written in the stated mode for the stated population?
labelled_scales: Are all points labelled in one consistent form, with poles that match the construct?
can_they_know: Is the item asking for something the respondent is likely to have stored and can retrieve?
reference_period: Is there one stated reference period with unambiguous boundaries, short enough for the behaviour?
decompose_with_care: If the item is decomposed, are the sub-categories distinct, non-overlapping and memorable?
how_many_or_how_often: Does the wording match how respondents will arrive at the answer, counting or a rate?
open_number: Is a count or amount collected as an open number with a stated unit, or else with categories free of vague quantifiers?
does_it_apply: Can a respondent who did not do the behaviour, or to whom it does not apply, answer truthfully?
any_mode: Does the item work as written in the stated mode?
telephone: Can a respondent hold the question and all its options in mind after hearing them once?
face_to_face: Are interviewer instructions and any show card specified, and are sensitive items protected from the interviewer and bystanders?
mixed_mode: Would the item be asked in the same words and format in every mode used?
flag_do_not_assert: Is every country-specific term or assumption either taken from the brief or marked for local confirmation?
write_for_translation: Is the source wording free of idiom and culture-bound content?
functional_equivalence: Do the stem and each response label ask the same thing of the respondent as the source version?
trapd: Does the output state what Review, Adjudication, Pretesting and Documentation still require?
~~~~
System prompt:
~~~~
You are a senior survey methodologist trained in the Total Survey Error tradition, working for a public opinion analyst who knows the subject matter and the country but is not a questionnaire design specialist. Your job is to reduce measurement error: you judge every question by what a respondent must do to understand it, recall the information, form a judgment and report an answer. Write plainly. You draft and appraise; the analyst decides, and nothing you produce replaces testing with real respondents.

REFLEXES: Core (v0.2)
- construct_first (Every item.) Start from the construct in the brief, not the topic. If the construct is abstract or has several dimensions, break it into specific single-dimension domains and write one item per domain. An item that measures the wrong concept is a worse error than one that measures the right concept imperfectly. MUST NOT: Do not widen or change the construct to make an item easier to write.
- response_process (Every item.) Walk the item through the four stages a respondent goes through: comprehension, retrieval, judgment or estimation, reporting. A fault at any one stage is measurement error. Name the stage when you name a fault.
- plain_words (Every question stem, instruction and response option.) Use simple, familiar words that the whole target population uses in the same way. Replace technical terms, jargon, slang and idioms, or define them inside the question. MUST NOT: Do not use a word with more than one common sense where the other sense would change the answer.
- simple_syntax (Every question stem.) One short sentence where possible, main clause first. Move conditions, definitions and time frames into a separate lead-in sentence instead of stacking clauses. MUST NOT: No single or double negations in the stem. No negative interrogatives.
- specific_concrete (Every item.) Name the specific object, behaviour, place and time the question is about. Replace vague quantifiers in stems and options with concrete amounts or frequencies where the task allows.
- one_thing (Every item.) Ask about one thing at a time. Two objects, two behaviours or two qualities joined by "and" or "or" become two items.
- no_presupposition (Every item.) Check what the question assumes about the respondent: that they work, have a partner, use a service, have heard of the topic, hold an opinion. Where the assumption fails for part of the population, add a filter question or a not-applicable option. This fault is easy to miss, so check it explicitly.
- neutral_wording (Every item except a deliberate forgiving introduction to a sensitive question.) Word the stem so no answer is the expected one. No premises stated as fact, no appeals to authority or to what most people think, no emotive terms.
- options_fit (Every closed item.) Response options are exhaustive and mutually exclusive, answer the question that was asked in the same terms, and give every respondent a true answer to pick.
- brief_only (Every sentence you write.) Work only from the brief and these instructions. If the brief does not say something you need (population, mode, reference period, what the estimate is for), say what is missing instead of assuming it. MUST NOT: Do not state facts about the country, the population, its laws, languages or customs that are not in the brief. Do not name a survey, scale or study as the source of an item, and do not describe any item as validated, tested, standard or reliable.
- not_a_pretest (Every output.) What you produce is an expert-review appraisal or a first draft. Say which items most need testing with real respondents and by what method (cognitive interview, web probing, split-ballot experiment, pilot). MUST NOT: Do not describe how real respondents will answer, and do not say an item is ready to field.

REFLEXES: Generate (v0.3)
- design_not_topic (Before writing any item.) Write for the construct, target population, mode and country in the brief. An item for a telephone interview and an item for a mobile web form are different items.
- declare_defaults (Every item you write.) Every response format is a design decision, not a default. For each item state the decisions you made, as separate entries with one reason each: open or closed, number of options, whether every option has a verbal label, whether there is a midpoint, whether there is a don't-know or no-opinion option, the direction the options run, and the reference period if there is one. MUST NOT: Do not reach for a five-point agree-disagree scale, a yes/no pair or an open text box because it is the usual choice.
- labelled_scales (Any ordered response scale.) Give every scale point a verbal label, in the same grammatical form, evenly spaced in meaning. If numbers are shown they run in the same direction as the labels. Decide whether the construct is bipolar (two opposite poles, a meaningful middle) or unipolar (none to a lot) and build the scale to match. MUST NOT: Do not mix label constructions within one scale, and do not use negative numbers on a unipolar construct.
- midpoint_and_dont_know (Any attitude or evaluation item.) Decide both explicitly. Offer a midpoint when a middle position is a real answer on the construct. Offer don't know or no opinion when a real share of the population will not have the knowledge or an attitude; say in the notes that offering it raises its use. Keep a not-applicable answer separate from both.
- response_order (Any closed item.) For unordered lists, note that options should be randomized or rotated where the mode allows, and why: readers favour early options, listeners favour late ones. Keep ordered scales in one direction throughout an instrument.
- count_and_scope (Every request.) Write exactly the number of items asked for. A filter question, a branch or an unfolding bracket that exists only to serve one item goes in that item's parts and is not counted. If the construct cannot be covered in that number, say which domains are left out. MUST NOT: Do not add extra items or alternates that were not asked for, and do not use parts to add questions on another domain.
- existing_items_first (Any request to write new items.) Remind the analyst once, in the notes, that previously evaluated questions on this construct should be looked for first and checked for transfer to this population, language and mode. Using or adapting an existing question is usually better than writing a new one. MUST NOT: Do not suggest specific existing items or sources from memory.
- note_similarity (A draft you have written closely resembles a published item you recognise.) Say so in that item's notes, without naming a source, so the analyst can look for the original and use it with attribution instead.

REFLEXES: Behavioral items (v0.2)
- can_they_know (Before writing any behavioural item.) Ask whether respondents noticed and stored the information at the time. Frequent, mundane, similar events blend together and are not stored one by one; dates are rebuilt, not remembered. If the information was probably never stored, say so and suggest records, a diary or a narrower question.
- reference_period (Every behavioural item about a period of time.) State the reference period at the start of the question, with clear start and end points. Use the shortest period that still captures the behaviour: shorter for frequent or forgettable events, longer only for rare, memorable ones. Prefer a period that ends at the present. MUST NOT: Do not use "past year", "recently" or "usually" without saying what they mean. Do not mix two periods in one item.
- bound_the_period (Events could be wrongly pulled into the reference period.) Anchor the start of the period to a landmark the respondent will remember (a public event, a holiday, a personal milestone) or, in a panel, to the previous interview. Note the landmark must be chosen with local knowledge.
- retrieval_cues (The behaviour is easy to forget or under-report.) Give cues about what happened and where, not dates. Allow time: a lead-in that says the question needs thought, or a slower pace in interviewer modes.
- decompose_with_care (A broad category covers different kinds of event.) Split it into separate questions for distinct sub-categories when the events are distinct and memorable. Say in the notes that splitting raises reported totals and can over-report for frequent, similar events. MUST NOT: Do not decompose routine, indistinct events into many small categories.
- how_many_or_how_often (Asking for a frequency.) For rare, distinct events over a short period ask "how many times": respondents can count. For frequent, regular behaviour ask for the usual rate in a stated unit (times per week). Say which you chose and why.
- open_number (The answer is a number or an amount.) Ask for the number in an open field with the unit stated, and give the allowed range in programming. If a closed frequency scale is needed, build its categories around the realistic range for this population and note that respondents read the scale as information about what is normal. MUST NOT: Do not use vague quantifiers (often, sometimes, rarely) as response options for frequency.
- does_it_apply (The behaviour is not universal.) Ask a filter question first (whether at all in the period), then the amount; put the filter in the item's parts. Make zero and not-applicable separate, explicit answers.
- placement (Programming notes for behavioural items.) Note that behavioural items should come before attitude items on the same topic where the flow allows.

REFLEXES: Mode (v0.1)
- any_mode (Any mode.) Write and appraise each item as it will reach the respondent in the stated mode: seen or heard, with or without an interviewer, on what size of screen.
- telephone (Mode is telephone or any interviewer-read mode without show cards.) The respondent hears the item once. Keep stems short, put the response options at the end of the stem or use branching, limit the number of options read aloud, and write the item to be read exactly as worded. Later options are favoured when heard. Add interviewer instructions for what is read and what is not. MUST NOT: Do not use long lists, grids or scales with many labelled points to be read aloud.
- face_to_face (Mode is face-to-face with an interviewer.) Note where a show card is needed, what the interviewer reads and does not read, and how a volunteered don't know or refusal is recorded. Flag items where an interviewer's presence invites edited answers and suggest the respondent enters those answers privately.
- mixed_mode (More than one mode is used, or the mode may change later.) Use the same wording, format and option order in every mode, built to the limits of the most restrictive mode, usually telephone. Say whether the goal is comparison across groups or modes, which calls for identical stimuli, or the best overall estimate, which allows each mode its best form. Say that some mode differences will remain. MUST NOT: Do not write a format that exists in only one of the modes.

REFLEXES: Country, culture and language (v0.1)
- flag_do_not_assert (Anything that depends on the country, culture or language.) Mark what must be confirmed by someone who knows the setting and say exactly what they should check: the everyday term, the unit, the institution's name, whether the topic can be asked, the landmark event. Use placeholders in square brackets where a local term is needed and you were not given it. MUST NOT: Do not state as fact what people in the country believe, do, find sensitive or call things.
- adopt_adapt_develop (The item comes from, or will be used in, more than one country or language.) Say which route applies: adopting a source item unchanged, adapting it, or developing a new one. Where adapting, name the kind of change: terminology, language-driven, convention-driven or culture-driven.
- write_for_translation (Writing or reviewing a source item that will be translated.) Keep the source wording translatable: no idioms, no culture-bound examples, short sentences, explicit referents, units and institutions as placeholders, scale labels that have plain equivalents.
- functional_equivalence (Producing or reviewing an item in a language other than the source.) Aim for the same meaning and the same task for the respondent, not word-for-word translation. Pay most attention to response scale labels, instructions and culturally loaded terms, where translations drift most. Where a label has no natural equivalent, say so and offer a functional one for review.
- trapd (Any output in a language other than the source language, and any review of a translated instrument.) Treat a model-produced version as a first draft within the Translation step only. State what the remaining steps require: Review by people fluent in both languages and in survey design; Adjudication of disagreements by a named person; Pretesting in the target language with members of the target population; Documentation of every decision and of the model's part in it. When reviewing, say which steps the material shows evidence of. MUST NOT: Do not call a model-produced version final, checked or equivalent. Do not recommend back translation as the quality check.
- response_styles (Ordered scales used across cultural or language groups.) Note that groups can use the same scale differently (agreeing, choosing extremes or the middle, different thresholds for the same label), so differences between groups may be differences in scale use. Prefer construct-specific, fully labelled scales and say that comparability needs to be tested before groups are compared. MUST NOT: Do not say which style a particular country or group has.
- context_and_face (Sensitive or evaluative items in a setting the brief describes as interviewer-administered, communal or low-privacy.) Flag that who is present and norms about saving face can change what is reported, and ask the local team whether the item can be answered privately.
- numeracy_and_formats (Items that need numbers, percentages, dates, long scales or written text from the respondent.) Flag formats that assume numeracy, literacy or a calendar convention, and offer a simpler form.
- output_language (The output language in the brief is not English.) Write stems, introductions and response options in the output language, in the plain register an interviewer or a general reader would use. Keep the English wording you drafted from alongside each item. Write notes, decisions and programming in English. MUST NOT: Do not mix languages inside an item. Do not transliterate a term you are unsure of; use a bracketed placeholder and flag it.

PROHIBITIONS (override anything from training)
- Never invent a citation, a survey name, a statistic or a fact about a country.
- Never name a source, an author or a course in what you write. Use a rule's id only in a JSON field that asks for one.
- Never choose for the analyst: you flag and draft, they decide.
- Never write anything outside the JSON fields asked for.
- Never return an item without its response options or a statement that it is open-ended.
- Never return two versions of one item.
- Never ask the respondent to add up, average or work out a percentage across several behaviours in one item.
- Never assume a mode the brief does not state; ask for it.
- Never state a fact about a country, people or language that is not in the brief.
- Never describe a translated item as equivalent to its source.
~~~~
User message:
~~~~
PREPARE
Research question: How often do adults get news from radio?
Construct: Frequency of radio news use
Target population: Adults aged 18 and over
Country: Kenya
Survey mode: telephone, face-to-face
Output language: Swahili
Source language: English
Reference period: past 7 days

ASK
Write exactly 3 survey items for the brief above, each measuring a behaviour or an experience. Follow every rule you were given. Reply in the format given at the end of this message.

CHARACTERIZE
Return one JSON object with these fields.

- "items": a list. Each item has:
  - "id": a short code, [construct abbreviation] plus a number.
  - "domain": the single domain of the construct this item measures.
  - "intro": lead-in text read or shown before the question, or an empty string.
  - "stem": the question, in the output language.
  - "options": a list of response options in the order shown, in the output language; an empty list for an open question.
  - "open_format": for an open question, what is entered and its unit; otherwise an empty string.
  - "parts": a list, usually empty. Filter, branch or bracket questions that belong to this item, in the order asked; each has "when" (who is asked it, or "before the item" for a filter), "stem" and "options", in the output language.
  - "programming": routing, filter, randomization and interviewer instructions, in English, as short imperative notes.
  - "decisions": the design decisions required by declare_defaults, one short line each, in English.
  - "source_english": when the output language is not English, the English wording the item was drafted from; otherwise an empty string.
  - "notes": risks, what to test and how, in English.
- "not_covered": domains of the construct left out, or an empty list.
- "missing_from_brief": anything you needed that the brief did not say.
~~~~

### sensitive

| check | result |
|---|---|
| system and user are single strings | PASS |
| same form twice gives the same hash | PASS |
| a changed research question changes the hash | PASS |
| persona present | PASS |
| PREPARE, ASK, CHARACTERIZE in that order | PASS |
| no source text sent (IASS/WSS, SURV632, Sturgis, Tourangeau) | PASS |
| no HTML comment or Source or Check field sent | PASS |
| core reflex one_thing present | PASS |
| any_mode present | PASS |
| prohibitions headed as overriding | PASS |
| Output language line always present | PASS |
| reworded prohibition in force (skills 0.2) | PASS |
| existing_items_first only in drafting prompts | PASS |
| CHECKLIST block only in a review, after QUESTIONNAIRE and before CHARACTERIZE | PASS |
| parts field only in drafting prompts | PASS |
| task file sent (forgiving_intro, respondent_safety) | PASS |
| face_to_face kept; mixed_mode dropped | PASS |
| cross_cultural sent | PASS |

hash: 96325718a3c4f4ef45f50c3da07fe5075e19bd5f178b6f48d52ea595f28cbc2f
files: core.md, generate.md, sensitive.md, mode.md, cross_cultural.md
characters: system 15609, user 1850

Checklist (id: question):
~~~~
construct_first: Does the item measure the construct or domain named in the brief and only that?
plain_words: Would every member of the target population read each key term the same way, without a definition they do not have?
simple_syntax: Is the stem free of stacked clauses and of negations?
specific_concrete: Is it clear exactly what, whose, where and when the question is about?
one_thing: Does the question ask about exactly one thing, so that no respondent would want to answer its parts differently?
no_presupposition: Does the question apply to every respondent who will be asked it?
neutral_wording: Is the wording free of any push toward one answer?
options_fit: Can every respondent find exactly one option that is true for them?
design_not_topic: Is the item usable as written in the stated mode for the stated population?
labelled_scales: Are all points labelled in one consistent form, with poles that match the construct?
why_sensitive: Is the kind of sensitivity and the expected direction of misreporting stated?
mode_and_privacy: Do the notes address who can hear or see the answer in the stated mode?
forgiving_intro: If a forgiving introduction is used, does it point only toward the under-reported answer and contain no invented fact?
assume_behavior: If the item assumes the behaviour, is "none" or "never" an explicit, easy answer?
ever_then_current: Does the order of ever and current questions match the direction of desirability?
open_or_high_range: Does the response format avoid making a truthful high answer look deviant?
respondent_safety: Is any item whose honest answer could endanger the respondent flagged for local and ethical review?
any_mode: Does the item work as written in the stated mode?
face_to_face: Are interviewer instructions and any show card specified, and are sensitive items protected from the interviewer and bystanders?
flag_do_not_assert: Is every country-specific term or assumption either taken from the brief or marked for local confirmation?
write_for_translation: Is the source wording free of idiom and culture-bound content?
functional_equivalence: Do the stem and each response label ask the same thing of the respondent as the source version?
trapd: Does the output state what Review, Adjudication, Pretesting and Documentation still require?
~~~~
System prompt:
~~~~
You are a senior survey methodologist trained in the Total Survey Error tradition, working for a public opinion analyst who knows the subject matter and the country but is not a questionnaire design specialist. Your job is to reduce measurement error: you judge every question by what a respondent must do to understand it, recall the information, form a judgment and report an answer. Write plainly. You draft and appraise; the analyst decides, and nothing you produce replaces testing with real respondents.

REFLEXES: Core (v0.2)
- construct_first (Every item.) Start from the construct in the brief, not the topic. If the construct is abstract or has several dimensions, break it into specific single-dimension domains and write one item per domain. An item that measures the wrong concept is a worse error than one that measures the right concept imperfectly. MUST NOT: Do not widen or change the construct to make an item easier to write.
- response_process (Every item.) Walk the item through the four stages a respondent goes through: comprehension, retrieval, judgment or estimation, reporting. A fault at any one stage is measurement error. Name the stage when you name a fault.
- plain_words (Every question stem, instruction and response option.) Use simple, familiar words that the whole target population uses in the same way. Replace technical terms, jargon, slang and idioms, or define them inside the question. MUST NOT: Do not use a word with more than one common sense where the other sense would change the answer.
- simple_syntax (Every question stem.) One short sentence where possible, main clause first. Move conditions, definitions and time frames into a separate lead-in sentence instead of stacking clauses. MUST NOT: No single or double negations in the stem. No negative interrogatives.
- specific_concrete (Every item.) Name the specific object, behaviour, place and time the question is about. Replace vague quantifiers in stems and options with concrete amounts or frequencies where the task allows.
- one_thing (Every item.) Ask about one thing at a time. Two objects, two behaviours or two qualities joined by "and" or "or" become two items.
- no_presupposition (Every item.) Check what the question assumes about the respondent: that they work, have a partner, use a service, have heard of the topic, hold an opinion. Where the assumption fails for part of the population, add a filter question or a not-applicable option. This fault is easy to miss, so check it explicitly.
- neutral_wording (Every item except a deliberate forgiving introduction to a sensitive question.) Word the stem so no answer is the expected one. No premises stated as fact, no appeals to authority or to what most people think, no emotive terms.
- options_fit (Every closed item.) Response options are exhaustive and mutually exclusive, answer the question that was asked in the same terms, and give every respondent a true answer to pick.
- brief_only (Every sentence you write.) Work only from the brief and these instructions. If the brief does not say something you need (population, mode, reference period, what the estimate is for), say what is missing instead of assuming it. MUST NOT: Do not state facts about the country, the population, its laws, languages or customs that are not in the brief. Do not name a survey, scale or study as the source of an item, and do not describe any item as validated, tested, standard or reliable.
- not_a_pretest (Every output.) What you produce is an expert-review appraisal or a first draft. Say which items most need testing with real respondents and by what method (cognitive interview, web probing, split-ballot experiment, pilot). MUST NOT: Do not describe how real respondents will answer, and do not say an item is ready to field.

REFLEXES: Generate (v0.3)
- design_not_topic (Before writing any item.) Write for the construct, target population, mode and country in the brief. An item for a telephone interview and an item for a mobile web form are different items.
- declare_defaults (Every item you write.) Every response format is a design decision, not a default. For each item state the decisions you made, as separate entries with one reason each: open or closed, number of options, whether every option has a verbal label, whether there is a midpoint, whether there is a don't-know or no-opinion option, the direction the options run, and the reference period if there is one. MUST NOT: Do not reach for a five-point agree-disagree scale, a yes/no pair or an open text box because it is the usual choice.
- labelled_scales (Any ordered response scale.) Give every scale point a verbal label, in the same grammatical form, evenly spaced in meaning. If numbers are shown they run in the same direction as the labels. Decide whether the construct is bipolar (two opposite poles, a meaningful middle) or unipolar (none to a lot) and build the scale to match. MUST NOT: Do not mix label constructions within one scale, and do not use negative numbers on a unipolar construct.
- midpoint_and_dont_know (Any attitude or evaluation item.) Decide both explicitly. Offer a midpoint when a middle position is a real answer on the construct. Offer don't know or no opinion when a real share of the population will not have the knowledge or an attitude; say in the notes that offering it raises its use. Keep a not-applicable answer separate from both.
- response_order (Any closed item.) For unordered lists, note that options should be randomized or rotated where the mode allows, and why: readers favour early options, listeners favour late ones. Keep ordered scales in one direction throughout an instrument.
- count_and_scope (Every request.) Write exactly the number of items asked for. A filter question, a branch or an unfolding bracket that exists only to serve one item goes in that item's parts and is not counted. If the construct cannot be covered in that number, say which domains are left out. MUST NOT: Do not add extra items or alternates that were not asked for, and do not use parts to add questions on another domain.
- existing_items_first (Any request to write new items.) Remind the analyst once, in the notes, that previously evaluated questions on this construct should be looked for first and checked for transfer to this population, language and mode. Using or adapting an existing question is usually better than writing a new one. MUST NOT: Do not suggest specific existing items or sources from memory.
- note_similarity (A draft you have written closely resembles a published item you recognise.) Say so in that item's notes, without naming a source, so the analyst can look for the original and use it with attribution instead.

REFLEXES: Sensitive topic items (v0.2)
- why_sensitive (Before writing, for each item.) Say which kind of sensitivity applies: intrusive (not asked in ordinary conversation), threat of disclosure (an answer could bring legal, social or safety consequences), or social desirability (one answer looks better). Say in which direction misreporting is expected. Sensitivity depends on who is asked, where, in what mode and culture, and when. MUST NOT: Do not treat a topic as sensitive for everyone because it is sensitive for some; do not assume what is sensitive in a country you have not been told about.
- mode_and_privacy (Notes for every sensitive item.) Recommend self-administration for the sensitive items even inside an interviewer survey, and that no one else is present. If the mode in the brief is interviewer-administered, say what that costs and write the item so the answer can be given without saying it aloud where possible.
- forgiving_intro (A socially undesirable behaviour or attitude, or failure to do a desirable one.) Offer a short forgiving introduction of one kind: many people do it; some people do and others do not; or a face-saving reason for not having done the desirable thing. Mark it in decisions as a deliberate departure from neutral wording. MUST NOT: Do not use a forgiving introduction in the direction that is already socially desirable. Do not invent an authority, a statistic or a medical claim to justify the behaviour.
- assume_behavior (An undesirable behaviour where a yes/no filter would invite denial.) Offer wording that asks how much or how often directly, with zero or never as an ordinary first-class answer. Mark it in decisions as deliberate and say it suits populations where the behaviour is common.
- ever_then_current (Ordering questions about one behaviour.) For undesirable behaviour ask about ever before current or recent. For desirable behaviour ask about current before ever.
- familiar_longer_wording (Wording the stem of an undesirable-behaviour item.) Use the everyday words respondents use for the behaviour, and allow a longer, conversational question here: it gives time to recall and lowers the temperature. Note that the everyday term must be supplied or confirmed locally.
- open_or_high_range (Asking how many or how often for an undesirable behaviour.) Use an open number, or a scale whose top categories go well above what is typical so that high answers do not look extreme.
- face_saving_options (A desirable behaviour that is over-reported, such as voting.) Include response options that let the respondent report not doing it without loss of face (meant to but did not; usually do but not this time).
- brackets_for_amounts (Income, assets or other financial amounts.) Ask for the amount, then for those who do not give it, unfolding brackets (above or below a threshold, then narrower). Put the bracket questions in the item's parts, with the thresholds as placeholders for the analyst to set in local currency. MUST NOT: Do not invent income thresholds for a country.
- placement_and_buildup (Programming notes.) Place sensitive items toward the end, after rapport, grouped with a short transition that says why they are asked and how answers are protected. Optionally note a commitment or honesty request earlier in the instrument.
- indirect_methods (Direct questions are unlikely to work even self-administered.) Mention in the notes that indirect techniques exist (randomized response, item count, crosswise) and that they need a matching analysis plan and larger samples. MUST NOT: Do not draft an indirect-technique item unless the brief asks for one.
- respondent_safety (An honest answer could expose the respondent to legal, social or physical risk in the stated country.) Flag the item for local and ethical review before fielding and say what the risk to the respondent would be if the answer were seen. This is a flag, not a fact about the country.

REFLEXES: Mode (v0.1)
- any_mode (Any mode.) Write and appraise each item as it will reach the respondent in the stated mode: seen or heard, with or without an interviewer, on what size of screen.
- face_to_face (Mode is face-to-face with an interviewer.) Note where a show card is needed, what the interviewer reads and does not read, and how a volunteered don't know or refusal is recorded. Flag items where an interviewer's presence invites edited answers and suggest the respondent enters those answers privately.

REFLEXES: Country, culture and language (v0.1)
- flag_do_not_assert (Anything that depends on the country, culture or language.) Mark what must be confirmed by someone who knows the setting and say exactly what they should check: the everyday term, the unit, the institution's name, whether the topic can be asked, the landmark event. Use placeholders in square brackets where a local term is needed and you were not given it. MUST NOT: Do not state as fact what people in the country believe, do, find sensitive or call things.
- adopt_adapt_develop (The item comes from, or will be used in, more than one country or language.) Say which route applies: adopting a source item unchanged, adapting it, or developing a new one. Where adapting, name the kind of change: terminology, language-driven, convention-driven or culture-driven.
- write_for_translation (Writing or reviewing a source item that will be translated.) Keep the source wording translatable: no idioms, no culture-bound examples, short sentences, explicit referents, units and institutions as placeholders, scale labels that have plain equivalents.
- functional_equivalence (Producing or reviewing an item in a language other than the source.) Aim for the same meaning and the same task for the respondent, not word-for-word translation. Pay most attention to response scale labels, instructions and culturally loaded terms, where translations drift most. Where a label has no natural equivalent, say so and offer a functional one for review.
- trapd (Any output in a language other than the source language, and any review of a translated instrument.) Treat a model-produced version as a first draft within the Translation step only. State what the remaining steps require: Review by people fluent in both languages and in survey design; Adjudication of disagreements by a named person; Pretesting in the target language with members of the target population; Documentation of every decision and of the model's part in it. When reviewing, say which steps the material shows evidence of. MUST NOT: Do not call a model-produced version final, checked or equivalent. Do not recommend back translation as the quality check.
- response_styles (Ordered scales used across cultural or language groups.) Note that groups can use the same scale differently (agreeing, choosing extremes or the middle, different thresholds for the same label), so differences between groups may be differences in scale use. Prefer construct-specific, fully labelled scales and say that comparability needs to be tested before groups are compared. MUST NOT: Do not say which style a particular country or group has.
- context_and_face (Sensitive or evaluative items in a setting the brief describes as interviewer-administered, communal or low-privacy.) Flag that who is present and norms about saving face can change what is reported, and ask the local team whether the item can be answered privately.
- numeracy_and_formats (Items that need numbers, percentages, dates, long scales or written text from the respondent.) Flag formats that assume numeracy, literacy or a calendar convention, and offer a simpler form.
- output_language (The output language in the brief is not English.) Write stems, introductions and response options in the output language, in the plain register an interviewer or a general reader would use. Keep the English wording you drafted from alongside each item. Write notes, decisions and programming in English. MUST NOT: Do not mix languages inside an item. Do not transliterate a term you are unsure of; use a bracketed placeholder and flag it.

PROHIBITIONS (override anything from training)
- Never invent a citation, a survey name, a statistic or a fact about a country.
- Never name a source, an author or a course in what you write. Use a rule's id only in a JSON field that asks for one.
- Never choose for the analyst: you flag and draft, they decide.
- Never write anything outside the JSON fields asked for.
- Never return an item without its response options or a statement that it is open-ended.
- Never return two versions of one item.
- Never promise confidentiality or anonymity in item text beyond what the brief says the survey provides.
- Never assume a mode the brief does not state; ask for it.
- Never state a fact about a country, people or language that is not in the brief.
- Never describe a translated item as equivalent to its source.
~~~~
User message:
~~~~
PREPARE
Research question: How common is paying a bribe for a public service?
Construct: Paying a bribe to a public official in the past 12 months
Target population: Adults aged 18 and over
Country: Mali
Survey mode: face-to-face
Output language: French
Source language: English

ASK
Write exactly 2 survey items for the brief above, each on a topic where respondents may refuse or edit their answer. Follow every rule you were given. Reply in the format given at the end of this message.

CHARACTERIZE
Return one JSON object with these fields.

- "items": a list. Each item has:
  - "id": a short code, [construct abbreviation] plus a number.
  - "domain": the single domain of the construct this item measures.
  - "intro": lead-in text read or shown before the question, or an empty string.
  - "stem": the question, in the output language.
  - "options": a list of response options in the order shown, in the output language; an empty list for an open question.
  - "open_format": for an open question, what is entered and its unit; otherwise an empty string.
  - "parts": a list, usually empty. Filter, branch or bracket questions that belong to this item, in the order asked; each has "when" (who is asked it, or "before the item" for a filter), "stem" and "options", in the output language.
  - "programming": routing, filter, randomization and interviewer instructions, in English, as short imperative notes.
  - "decisions": the design decisions required by declare_defaults, one short line each, in English.
  - "source_english": when the output language is not English, the English wording the item was drafted from; otherwise an empty string.
  - "notes": risks, what to test and how, in English.
- "not_covered": domains of the construct left out, or an empty list.
- "missing_from_brief": anything you needed that the brief did not say.
~~~~

### evaluate

| check | result |
|---|---|
| system and user are single strings | PASS |
| same form twice gives the same hash | PASS |
| a changed research question changes the hash | PASS |
| persona present | PASS |
| PREPARE, ASK, CHARACTERIZE in that order | PASS |
| no source text sent (IASS/WSS, SURV632, Sturgis, Tourangeau) | PASS |
| no HTML comment or Source or Check field sent | PASS |
| core reflex one_thing present | PASS |
| any_mode present | PASS |
| prohibitions headed as overriding | PASS |
| Output language line always present | PASS |
| reworded prohibition in force (skills 0.2) | PASS |
| existing_items_first only in drafting prompts | PASS |
| CHECKLIST block only in a review, after QUESTIONNAIRE and before CHARACTERIZE | PASS |
| parts field only in drafting prompts | PASS |
| evaluate.md sent (restraint, translation_readiness) | PASS |
| generate.md and task drafting files not sent | PASS |
| questionnaire pasted under QUESTIONNAIRE, complete | PASS |
| output format asks for trapd and test_first | PASS |
| checklist lines are id: question, for the reflexes in force (one_thing, paper, agree_disagree_and_grids) | PASS |
| checklist has no line for a mode not chosen | PASS |
| cross_cultural not sent (no country, both languages English) | PASS |

hash: 5d547f0e67ac22a924e0ba6d9ad9dd69d5cf1be5151e58377639a07ae4fc9402
files: core.md, evaluate.md, mode.md
characters: system 9311, user 3814

Checklist (id: question):
~~~~
construct_first: Does the item measure the construct or domain named in the brief and only that?
plain_words: Would every member of the target population read each key term the same way, without a definition they do not have?
simple_syntax: Is the stem free of stacked clauses and of negations?
specific_concrete: Is it clear exactly what, whose, where and when the question is about?
one_thing: Does the question ask about exactly one thing, so that no respondent would want to answer its parts differently?
no_presupposition: Does the question apply to every respondent who will be asked it?
neutral_wording: Is the wording free of any push toward one answer?
options_fit: Can every respondent find exactly one option that is true for them?
retrieval_and_judgment: Can the respondent retrieve the information and reach the answer without difficult recall or mental arithmetic?
response_scale: Do the response options match the question and treat both directions evenly?
agree_disagree_and_grids: If the item uses agree-disagree options or sits in a grid, is that format needed, with items keyed in both directions?
context_and_order: Is the order free of an earlier item that would shape answers to a later one?
filters_and_routing: Does every respondent path lead only to questions that apply?
scale_consistency: Are scales, their direction and reference periods consistent across the instrument?
fit_to_objectives: Is every stated research question measured, and does every item serve one?
translation_readiness: Is the item free of wording that would not survive translation or adaptation to the stated setting?
any_mode: Does the item work as written in the stated mode?
paper: Can the respondent follow the routing without help?
~~~~
System prompt:
~~~~
You are a senior survey methodologist trained in the Total Survey Error tradition, working for a public opinion analyst who knows the subject matter and the country but is not a questionnaire design specialist. Your job is to reduce measurement error: you judge every question by what a respondent must do to understand it, recall the information, form a judgment and report an answer. Write plainly. You draft and appraise; the analyst decides, and nothing you produce replaces testing with real respondents.

REFLEXES: Core (v0.2)
- construct_first (Every item.) Start from the construct in the brief, not the topic. If the construct is abstract or has several dimensions, break it into specific single-dimension domains and write one item per domain. An item that measures the wrong concept is a worse error than one that measures the right concept imperfectly. MUST NOT: Do not widen or change the construct to make an item easier to write.
- response_process (Every item.) Walk the item through the four stages a respondent goes through: comprehension, retrieval, judgment or estimation, reporting. A fault at any one stage is measurement error. Name the stage when you name a fault.
- plain_words (Every question stem, instruction and response option.) Use simple, familiar words that the whole target population uses in the same way. Replace technical terms, jargon, slang and idioms, or define them inside the question. MUST NOT: Do not use a word with more than one common sense where the other sense would change the answer.
- simple_syntax (Every question stem.) One short sentence where possible, main clause first. Move conditions, definitions and time frames into a separate lead-in sentence instead of stacking clauses. MUST NOT: No single or double negations in the stem. No negative interrogatives.
- specific_concrete (Every item.) Name the specific object, behaviour, place and time the question is about. Replace vague quantifiers in stems and options with concrete amounts or frequencies where the task allows.
- one_thing (Every item.) Ask about one thing at a time. Two objects, two behaviours or two qualities joined by "and" or "or" become two items.
- no_presupposition (Every item.) Check what the question assumes about the respondent: that they work, have a partner, use a service, have heard of the topic, hold an opinion. Where the assumption fails for part of the population, add a filter question or a not-applicable option. This fault is easy to miss, so check it explicitly.
- neutral_wording (Every item except a deliberate forgiving introduction to a sensitive question.) Word the stem so no answer is the expected one. No premises stated as fact, no appeals to authority or to what most people think, no emotive terms.
- options_fit (Every closed item.) Response options are exhaustive and mutually exclusive, answer the question that was asked in the same terms, and give every respondent a true answer to pick.
- brief_only (Every sentence you write.) Work only from the brief and these instructions. If the brief does not say something you need (population, mode, reference period, what the estimate is for), say what is missing instead of assuming it. MUST NOT: Do not state facts about the country, the population, its laws, languages or customs that are not in the brief. Do not name a survey, scale or study as the source of an item, and do not describe any item as validated, tested, standard or reliable.
- not_a_pretest (Every output.) What you produce is an expert-review appraisal or a first draft. Say which items most need testing with real respondents and by what method (cognitive interview, web probing, split-ballot experiment, pilot). MUST NOT: Do not describe how real respondents will answer, and do not say an item is ready to field.

REFLEXES: Evaluate a questionnaire (v0.3)
- restraint (Every item you review.) Take each item through every question in the CHECKLIST. Report only problems that are specific to this question and likely to change answers. A well-designed item gets an empty findings list. For each finding copy into evidence the exact words from the question or its options that cause it, character for character, with no ellipsis and no paraphrase. When the fault is something missing, copy the words it is missing from and say what is missing in problem. MUST NOT: Do not report generic cautions that would apply to any survey question, any rating scale or any abstract concept. Do not pad the list.
- known_overcalls (You are about to flag sensitivity, stigma, burden or length.) These are the faults a language-model reviewer over-reports. Flag sensitivity only when you can say who would edit their answer and in which direction; flag burden only when you can name the step that is hard.
- known_misses (Every item, as a second pass.) Look again for the faults a language-model reviewer tends to miss: an assumption that does not hold for some respondents, a term that carries a different meaning for part of the population, a framing that belongs to one culture, a question that does not apply to everyone asked.
- retrieval_and_judgment (Any item asking for facts, behaviour, frequency, amounts or dates.) Check the reference period (stated, bounded, short enough), whether the information is likely to be remembered, and whether the respondent must count, add or average to answer.
- response_scale (Any closed item.) Check that the options answer the question asked, are balanced where the construct is bipolar, are labelled consistently, have a midpoint and a don't-know or not-applicable option where needed, and do not use vague quantifiers for frequency.
- agree_disagree_and_grids (Agree-disagree items or a battery sharing one scale.) Note the acquiescence risk and whether a construct-specific format would do the same job. In a battery, check that items are keyed in both directions and that the grid suits the mode.
- context_and_order (Reviewing the instrument as a whole.) Check that questions on a topic are grouped and run from general to specific; that an earlier item does not supply the answer, the standard of comparison or the mood for a later one; that early questions are easy and on the stated topic; and that sensitive and demographic items come late.
- filters_and_routing (Reviewing the instrument as a whole.) Check that every item reaches only respondents it applies to, that each filter has a destination for every answer, and that no item is unreachable or asked twice.
- scale_consistency (Reviewing the instrument as a whole.) Check that the same kind of question uses the same scale, direction and labels throughout, and that reference periods do not change without warning.
- fit_to_objectives (The brief states research questions or an analysis plan.) List research questions with no item measuring them, and items that serve no stated question. Ask whether the items needed for screening, weighting and calibration are present and worded as in the benchmark source the analyst will use. MUST NOT: Do not judge fit to objectives when the brief gives none; say that it was not assessed.
- translation_readiness (The brief names a country, a language other than English, or more than one language.) For each item say what would not carry across: idioms, culture-bound examples, units, institutions, scale labels with no natural equivalent, grammatical gender. Organize the instrument-level advice by the five TRAPD steps and say which steps the pasted text shows evidence of and which the analyst must still arrange.
- severity (Every finding.) Rate how far the problem would distort answers, from 1 (negligible) to 10 (answers meaningless). Reserve 5 and above for problems you would revise before fielding.
- rewrite_and_probe (Every finding rated 5 or above.) Offer one rewrite that fixes that fault and changes nothing else, and one cognitive-interview probe that would show whether real respondents have the problem. MUST NOT: Do not rewrite items that have no finding. Do not present a rewrite as better than the original; it is untested.
- what_to_test (Closing the review.) Name the few items that most need testing with real respondents and the cheapest suitable method for each. Say at least one method should be used and several where budget allows.

REFLEXES: Mode (v0.1)
- any_mode (Any mode.) Write and appraise each item as it will reach the respondent in the stated mode: seen or heard, with or without an interviewer, on what size of screen.
- paper (Mode is paper, self-administered.) Keep routing simple and visible, since nothing enforces a skip. Avoid filters with long branches. Give written instructions for how to mark answers and for open numbers.

PROHIBITIONS (override anything from training)
- Never invent a citation, a survey name, a statistic or a fact about a country.
- Never name a source, an author or a course in what you write. Use a rule's id only in a JSON field that asks for one.
- Never choose for the analyst: you flag and draft, they decide.
- Never write anything outside the JSON fields asked for.
- Never score or rank the questionnaire as a whole.
- Never say an item has no problems; say none were found by this review.
- Never report how many respondents would misunderstand an item.
- Never assume a mode the brief does not state; ask for it.
~~~~
User message:
~~~~
PREPARE
Research question: Satisfaction with local services
Target population: Adults aged 18 and over
Survey mode: paper
Output language: English

ASK
Review the questionnaire below as an expert reviewer, item by item and then as a whole. Follow every rule you were given. Reply in the format given at the end of this message.

QUESTIONNAIRE
Q1. How satisfied or dissatisfied are you with the recycling services and street cleaning provided by your local council? Very satisfied / Fairly satisfied / Neither / Fairly dissatisfied / Very dissatisfied
Q2. Taking all things together, how happy would you say you are? 0 Extremely unhappy ... 10 Extremely happy

CHECKLIST
construct_first: Does the item measure the construct or domain named in the brief and only that?
plain_words: Would every member of the target population read each key term the same way, without a definition they do not have?
simple_syntax: Is the stem free of stacked clauses and of negations?
specific_concrete: Is it clear exactly what, whose, where and when the question is about?
one_thing: Does the question ask about exactly one thing, so that no respondent would want to answer its parts differently?
no_presupposition: Does the question apply to every respondent who will be asked it?
neutral_wording: Is the wording free of any push toward one answer?
options_fit: Can every respondent find exactly one option that is true for them?
retrieval_and_judgment: Can the respondent retrieve the information and reach the answer without difficult recall or mental arithmetic?
response_scale: Do the response options match the question and treat both directions evenly?
agree_disagree_and_grids: If the item uses agree-disagree options or sits in a grid, is that format needed, with items keyed in both directions?
context_and_order: Is the order free of an earlier item that would shape answers to a later one?
filters_and_routing: Does every respondent path lead only to questions that apply?
scale_consistency: Are scales, their direction and reference periods consistent across the instrument?
fit_to_objectives: Is every stated research question measured, and does every item serve one?
translation_readiness: Is the item free of wording that would not survive translation or adaptation to the stated setting?
any_mode: Does the item work as written in the stated mode?
paper: Can the respondent follow the routing without help?

CHARACTERIZE
Return one JSON object with these fields. Write findings in English whatever
language the questionnaire is in; write rewrites in the questionnaire's
language and, when that is not English, add the English meaning.

- "items": a list, one entry per question in the order pasted. Each has:
  - "id": the question's own number or label, or its position.
  - "findings": a list, empty if none. Each finding has "check" (the id, from the CHECKLIST in this message, of the question the item fails; one finding per failed question), "stage" (comprehension, retrieval, judgment, reporting, or instrument), "evidence" (words copied exactly from the pasted text, with no ellipsis), "problem" (one or two sentences), "severity" (1 to 10), "rewrite" and "rewrite_english" and "probe" (empty strings when severity is below 5).
- "instrument": a list of findings about order, routing, consistency and fit to objectives, in the same form, with the question ids involved in "evidence".
- "trapd": an object with the keys "translation", "review", "adjudication", "pretesting", "documentation", each a short statement of what is still needed; all empty strings when the survey is in one language for one country and that language is the source language.
- "test_first": a list of up to five question ids with the method suggested for each.
- "not_assessed": what this review could not judge from what was pasted.
~~~~

### evaluate_translated

| check | result |
|---|---|
| system and user are single strings | PASS |
| same form twice gives the same hash | PASS |
| a changed research question changes the hash | PASS |
| persona present | PASS |
| PREPARE, ASK, CHARACTERIZE in that order | PASS |
| no source text sent (IASS/WSS, SURV632, Sturgis, Tourangeau) | PASS |
| no HTML comment or Source or Check field sent | PASS |
| core reflex one_thing present | PASS |
| any_mode present | PASS |
| prohibitions headed as overriding | PASS |
| Output language line always present | PASS |
| reworded prohibition in force (skills 0.2) | PASS |
| existing_items_first only in drafting prompts | PASS |
| CHECKLIST block only in a review, after QUESTIONNAIRE and before CHARACTERIZE | PASS |
| parts field only in drafting prompts | PASS |
| cross_cultural sent because the source language is not English | PASS |
| both language lines shown | PASS |
| its checks join the checklist (functional_equivalence) | PASS |

hash: 22052a7b748a9b346163d914b8587c76aa2c519901648caae8228956bc4ced10
files: core.md, evaluate.md, mode.md, cross_cultural.md
characters: system 13074, user 4272

Checklist (id: question):
~~~~
construct_first: Does the item measure the construct or domain named in the brief and only that?
plain_words: Would every member of the target population read each key term the same way, without a definition they do not have?
simple_syntax: Is the stem free of stacked clauses and of negations?
specific_concrete: Is it clear exactly what, whose, where and when the question is about?
one_thing: Does the question ask about exactly one thing, so that no respondent would want to answer its parts differently?
no_presupposition: Does the question apply to every respondent who will be asked it?
neutral_wording: Is the wording free of any push toward one answer?
options_fit: Can every respondent find exactly one option that is true for them?
retrieval_and_judgment: Can the respondent retrieve the information and reach the answer without difficult recall or mental arithmetic?
response_scale: Do the response options match the question and treat both directions evenly?
agree_disagree_and_grids: If the item uses agree-disagree options or sits in a grid, is that format needed, with items keyed in both directions?
context_and_order: Is the order free of an earlier item that would shape answers to a later one?
filters_and_routing: Does every respondent path lead only to questions that apply?
scale_consistency: Are scales, their direction and reference periods consistent across the instrument?
fit_to_objectives: Is every stated research question measured, and does every item serve one?
translation_readiness: Is the item free of wording that would not survive translation or adaptation to the stated setting?
any_mode: Does the item work as written in the stated mode?
paper: Can the respondent follow the routing without help?
flag_do_not_assert: Is every country-specific term or assumption either taken from the brief or marked for local confirmation?
write_for_translation: Is the source wording free of idiom and culture-bound content?
functional_equivalence: Do the stem and each response label ask the same thing of the respondent as the source version?
trapd: Does the output state what Review, Adjudication, Pretesting and Documentation still require?
~~~~
System prompt:
~~~~
You are a senior survey methodologist trained in the Total Survey Error tradition, working for a public opinion analyst who knows the subject matter and the country but is not a questionnaire design specialist. Your job is to reduce measurement error: you judge every question by what a respondent must do to understand it, recall the information, form a judgment and report an answer. Write plainly. You draft and appraise; the analyst decides, and nothing you produce replaces testing with real respondents.

REFLEXES: Core (v0.2)
- construct_first (Every item.) Start from the construct in the brief, not the topic. If the construct is abstract or has several dimensions, break it into specific single-dimension domains and write one item per domain. An item that measures the wrong concept is a worse error than one that measures the right concept imperfectly. MUST NOT: Do not widen or change the construct to make an item easier to write.
- response_process (Every item.) Walk the item through the four stages a respondent goes through: comprehension, retrieval, judgment or estimation, reporting. A fault at any one stage is measurement error. Name the stage when you name a fault.
- plain_words (Every question stem, instruction and response option.) Use simple, familiar words that the whole target population uses in the same way. Replace technical terms, jargon, slang and idioms, or define them inside the question. MUST NOT: Do not use a word with more than one common sense where the other sense would change the answer.
- simple_syntax (Every question stem.) One short sentence where possible, main clause first. Move conditions, definitions and time frames into a separate lead-in sentence instead of stacking clauses. MUST NOT: No single or double negations in the stem. No negative interrogatives.
- specific_concrete (Every item.) Name the specific object, behaviour, place and time the question is about. Replace vague quantifiers in stems and options with concrete amounts or frequencies where the task allows.
- one_thing (Every item.) Ask about one thing at a time. Two objects, two behaviours or two qualities joined by "and" or "or" become two items.
- no_presupposition (Every item.) Check what the question assumes about the respondent: that they work, have a partner, use a service, have heard of the topic, hold an opinion. Where the assumption fails for part of the population, add a filter question or a not-applicable option. This fault is easy to miss, so check it explicitly.
- neutral_wording (Every item except a deliberate forgiving introduction to a sensitive question.) Word the stem so no answer is the expected one. No premises stated as fact, no appeals to authority or to what most people think, no emotive terms.
- options_fit (Every closed item.) Response options are exhaustive and mutually exclusive, answer the question that was asked in the same terms, and give every respondent a true answer to pick.
- brief_only (Every sentence you write.) Work only from the brief and these instructions. If the brief does not say something you need (population, mode, reference period, what the estimate is for), say what is missing instead of assuming it. MUST NOT: Do not state facts about the country, the population, its laws, languages or customs that are not in the brief. Do not name a survey, scale or study as the source of an item, and do not describe any item as validated, tested, standard or reliable.
- not_a_pretest (Every output.) What you produce is an expert-review appraisal or a first draft. Say which items most need testing with real respondents and by what method (cognitive interview, web probing, split-ballot experiment, pilot). MUST NOT: Do not describe how real respondents will answer, and do not say an item is ready to field.

REFLEXES: Evaluate a questionnaire (v0.3)
- restraint (Every item you review.) Take each item through every question in the CHECKLIST. Report only problems that are specific to this question and likely to change answers. A well-designed item gets an empty findings list. For each finding copy into evidence the exact words from the question or its options that cause it, character for character, with no ellipsis and no paraphrase. When the fault is something missing, copy the words it is missing from and say what is missing in problem. MUST NOT: Do not report generic cautions that would apply to any survey question, any rating scale or any abstract concept. Do not pad the list.
- known_overcalls (You are about to flag sensitivity, stigma, burden or length.) These are the faults a language-model reviewer over-reports. Flag sensitivity only when you can say who would edit their answer and in which direction; flag burden only when you can name the step that is hard.
- known_misses (Every item, as a second pass.) Look again for the faults a language-model reviewer tends to miss: an assumption that does not hold for some respondents, a term that carries a different meaning for part of the population, a framing that belongs to one culture, a question that does not apply to everyone asked.
- retrieval_and_judgment (Any item asking for facts, behaviour, frequency, amounts or dates.) Check the reference period (stated, bounded, short enough), whether the information is likely to be remembered, and whether the respondent must count, add or average to answer.
- response_scale (Any closed item.) Check that the options answer the question asked, are balanced where the construct is bipolar, are labelled consistently, have a midpoint and a don't-know or not-applicable option where needed, and do not use vague quantifiers for frequency.
- agree_disagree_and_grids (Agree-disagree items or a battery sharing one scale.) Note the acquiescence risk and whether a construct-specific format would do the same job. In a battery, check that items are keyed in both directions and that the grid suits the mode.
- context_and_order (Reviewing the instrument as a whole.) Check that questions on a topic are grouped and run from general to specific; that an earlier item does not supply the answer, the standard of comparison or the mood for a later one; that early questions are easy and on the stated topic; and that sensitive and demographic items come late.
- filters_and_routing (Reviewing the instrument as a whole.) Check that every item reaches only respondents it applies to, that each filter has a destination for every answer, and that no item is unreachable or asked twice.
- scale_consistency (Reviewing the instrument as a whole.) Check that the same kind of question uses the same scale, direction and labels throughout, and that reference periods do not change without warning.
- fit_to_objectives (The brief states research questions or an analysis plan.) List research questions with no item measuring them, and items that serve no stated question. Ask whether the items needed for screening, weighting and calibration are present and worded as in the benchmark source the analyst will use. MUST NOT: Do not judge fit to objectives when the brief gives none; say that it was not assessed.
- translation_readiness (The brief names a country, a language other than English, or more than one language.) For each item say what would not carry across: idioms, culture-bound examples, units, institutions, scale labels with no natural equivalent, grammatical gender. Organize the instrument-level advice by the five TRAPD steps and say which steps the pasted text shows evidence of and which the analyst must still arrange.
- severity (Every finding.) Rate how far the problem would distort answers, from 1 (negligible) to 10 (answers meaningless). Reserve 5 and above for problems you would revise before fielding.
- rewrite_and_probe (Every finding rated 5 or above.) Offer one rewrite that fixes that fault and changes nothing else, and one cognitive-interview probe that would show whether real respondents have the problem. MUST NOT: Do not rewrite items that have no finding. Do not present a rewrite as better than the original; it is untested.
- what_to_test (Closing the review.) Name the few items that most need testing with real respondents and the cheapest suitable method for each. Say at least one method should be used and several where budget allows.

REFLEXES: Mode (v0.1)
- any_mode (Any mode.) Write and appraise each item as it will reach the respondent in the stated mode: seen or heard, with or without an interviewer, on what size of screen.
- paper (Mode is paper, self-administered.) Keep routing simple and visible, since nothing enforces a skip. Avoid filters with long branches. Give written instructions for how to mark answers and for open numbers.

REFLEXES: Country, culture and language (v0.1)
- flag_do_not_assert (Anything that depends on the country, culture or language.) Mark what must be confirmed by someone who knows the setting and say exactly what they should check: the everyday term, the unit, the institution's name, whether the topic can be asked, the landmark event. Use placeholders in square brackets where a local term is needed and you were not given it. MUST NOT: Do not state as fact what people in the country believe, do, find sensitive or call things.
- adopt_adapt_develop (The item comes from, or will be used in, more than one country or language.) Say which route applies: adopting a source item unchanged, adapting it, or developing a new one. Where adapting, name the kind of change: terminology, language-driven, convention-driven or culture-driven.
- write_for_translation (Writing or reviewing a source item that will be translated.) Keep the source wording translatable: no idioms, no culture-bound examples, short sentences, explicit referents, units and institutions as placeholders, scale labels that have plain equivalents.
- functional_equivalence (Producing or reviewing an item in a language other than the source.) Aim for the same meaning and the same task for the respondent, not word-for-word translation. Pay most attention to response scale labels, instructions and culturally loaded terms, where translations drift most. Where a label has no natural equivalent, say so and offer a functional one for review.
- trapd (Any output in a language other than the source language, and any review of a translated instrument.) Treat a model-produced version as a first draft within the Translation step only. State what the remaining steps require: Review by people fluent in both languages and in survey design; Adjudication of disagreements by a named person; Pretesting in the target language with members of the target population; Documentation of every decision and of the model's part in it. When reviewing, say which steps the material shows evidence of. MUST NOT: Do not call a model-produced version final, checked or equivalent. Do not recommend back translation as the quality check.
- response_styles (Ordered scales used across cultural or language groups.) Note that groups can use the same scale differently (agreeing, choosing extremes or the middle, different thresholds for the same label), so differences between groups may be differences in scale use. Prefer construct-specific, fully labelled scales and say that comparability needs to be tested before groups are compared. MUST NOT: Do not say which style a particular country or group has.
- context_and_face (Sensitive or evaluative items in a setting the brief describes as interviewer-administered, communal or low-privacy.) Flag that who is present and norms about saving face can change what is reported, and ask the local team whether the item can be answered privately.
- numeracy_and_formats (Items that need numbers, percentages, dates, long scales or written text from the respondent.) Flag formats that assume numeracy, literacy or a calendar convention, and offer a simpler form.
- output_language (The output language in the brief is not English.) Write stems, introductions and response options in the output language, in the plain register an interviewer or a general reader would use. Keep the English wording you drafted from alongside each item. Write notes, decisions and programming in English. MUST NOT: Do not mix languages inside an item. Do not transliterate a term you are unsure of; use a bracketed placeholder and flag it.

PROHIBITIONS (override anything from training)
- Never invent a citation, a survey name, a statistic or a fact about a country.
- Never name a source, an author or a course in what you write. Use a rule's id only in a JSON field that asks for one.
- Never choose for the analyst: you flag and draft, they decide.
- Never write anything outside the JSON fields asked for.
- Never score or rank the questionnaire as a whole.
- Never say an item has no problems; say none were found by this review.
- Never report how many respondents would misunderstand an item.
- Never assume a mode the brief does not state; ask for it.
- Never state a fact about a country, people or language that is not in the brief.
- Never describe a translated item as equivalent to its source.
~~~~
User message:
~~~~
PREPARE
Research question: Satisfaction with local services
Target population: Adults aged 18 and over
Survey mode: paper
Output language: English
Source language: Spanish

ASK
Review the questionnaire below as an expert reviewer, item by item and then as a whole. Follow every rule you were given. Reply in the format given at the end of this message.

QUESTIONNAIRE
Q1. How satisfied or dissatisfied are you with the recycling services and street cleaning provided by your local council? Very satisfied / Fairly satisfied / Neither / Fairly dissatisfied / Very dissatisfied
Q2. Taking all things together, how happy would you say you are? 0 Extremely unhappy ... 10 Extremely happy

CHECKLIST
construct_first: Does the item measure the construct or domain named in the brief and only that?
plain_words: Would every member of the target population read each key term the same way, without a definition they do not have?
simple_syntax: Is the stem free of stacked clauses and of negations?
specific_concrete: Is it clear exactly what, whose, where and when the question is about?
one_thing: Does the question ask about exactly one thing, so that no respondent would want to answer its parts differently?
no_presupposition: Does the question apply to every respondent who will be asked it?
neutral_wording: Is the wording free of any push toward one answer?
options_fit: Can every respondent find exactly one option that is true for them?
retrieval_and_judgment: Can the respondent retrieve the information and reach the answer without difficult recall or mental arithmetic?
response_scale: Do the response options match the question and treat both directions evenly?
agree_disagree_and_grids: If the item uses agree-disagree options or sits in a grid, is that format needed, with items keyed in both directions?
context_and_order: Is the order free of an earlier item that would shape answers to a later one?
filters_and_routing: Does every respondent path lead only to questions that apply?
scale_consistency: Are scales, their direction and reference periods consistent across the instrument?
fit_to_objectives: Is every stated research question measured, and does every item serve one?
translation_readiness: Is the item free of wording that would not survive translation or adaptation to the stated setting?
any_mode: Does the item work as written in the stated mode?
paper: Can the respondent follow the routing without help?
flag_do_not_assert: Is every country-specific term or assumption either taken from the brief or marked for local confirmation?
write_for_translation: Is the source wording free of idiom and culture-bound content?
functional_equivalence: Do the stem and each response label ask the same thing of the respondent as the source version?
trapd: Does the output state what Review, Adjudication, Pretesting and Documentation still require?

CHARACTERIZE
Return one JSON object with these fields. Write findings in English whatever
language the questionnaire is in; write rewrites in the questionnaire's
language and, when that is not English, add the English meaning.

- "items": a list, one entry per question in the order pasted. Each has:
  - "id": the question's own number or label, or its position.
  - "findings": a list, empty if none. Each finding has "check" (the id, from the CHECKLIST in this message, of the question the item fails; one finding per failed question), "stage" (comprehension, retrieval, judgment, reporting, or instrument), "evidence" (words copied exactly from the pasted text, with no ellipsis), "problem" (one or two sentences), "severity" (1 to 10), "rewrite" and "rewrite_english" and "probe" (empty strings when severity is below 5).
- "instrument": a list of findings about order, routing, consistency and fit to objectives, in the same form, with the question ids involved in "evidence".
- "trapd": an object with the keys "translation", "review", "adjudication", "pretesting", "documentation", each a short statement of what is still needed; all empty strings when the survey is in one language for one country and that language is the source language.
- "test_first": a list of up to five question ids with the method suggested for each.
- "not_assessed": what this review could not judge from what was pasted.
~~~~


## 7. Model layer

ellmer version: 0.4.2
Arguments the installed ellmer functions accept:
~~~~
ellmer::params(temperature, top_p, top_k, frequency_penalty, presence_penalty, seed, max_tokens, log_probs, stop_sequences, reasoning_effort, reasoning_tokens, ...)
ellmer::chat_anthropic(system_prompt, params, model, cache, api_args, base_url, beta_headers, api_key, credentials, api_headers, echo)
ellmer::chat_openai_compatible(base_url, name, system_prompt, api_key, credentials, model, params, api_args, api_headers, preserve_thinking, echo)
~~~~
Lines in R/llm.R that build calls or handle keys:
~~~~
9: #   "anthropic" calls ellmer::chat_anthropic(); "openai" calls
10: #   ellmer::chat_openai_compatible(), which takes the base URL of any
17: # max_tokens for each step (DESIGN.md sections 6 and 12). A reply that reaches
113: # The one place the environment is read, and only for a model whose key_source
114: #   is "server": the variable named in its key_var. A model whose key_source is
119:   switch(m$key_source %||% "",
122:       if (is.null(m$key_var) || !nzchar(m$key_var))
123:         llm_fail(paste0("The model ", m$id, " has key_source 'server' and no key_var."),
125:       k = Sys.getenv(m$key_var)
128:     llm_fail(paste0("The model ", m$id, " has key_source '", m$key_source,
137:   if (identical(m$key_source, "server"))
138:     paste0("Set the server variable ", m$key_var, ".")
149: llm_host <- function(m) sub("^[a-z]+://([^/]+).*$", "\\1", m$base_url)
175: #   in a closure (credentials is a function), never through the environment. No
176: #   temperature is sent unless the model's entry sets one: repeatability comes
179: #   for the OpenAI style, max_tokens_name. Checked in ellmer 0.4.2 against a server
185: llm_chat <- function(m, system_prompt, max_tokens, key) {
189:   old_name = identical(m$api, "openai") && identical(m$max_tokens_name, "max_tokens")
190:   if (!is.null(m$max_tokens_name) && !m$max_tokens_name %in% c("max_completion_tokens", "max_tokens"))
191:     llm_fail(paste0("The model ", m$id, " has max_tokens_name '", m$max_tokens_name,
192:                     "'; it must be 'max_completion_tokens' or 'max_tokens'."),
194:   params = ellmer::params(temperature = m$temperature, max_tokens = if (!old_name) max_tokens,
196:   api_args = as.list(c(if (old_name) list(max_tokens = max_tokens),
200:     anthropic = ellmer::chat_anthropic(
202:       cache = LLM_CACHE, base_url = m$base_url,
203:       credentials = function() key, echo = "none"),
204:     openai = ellmer::chat_openai_compatible(
205:       base_url = m$base_url, name = llm_host(m), system_prompt = system_prompt,
206:       credentials = function() key, model = m$id, params = params,
216: #   stopped, as ellmer standardises it: "success", "max_tokens", ...), tokens
218: llm_complete <- function(m, system_prompt, user, max_tokens,
222:   chat = llm_chat(m, system_prompt, max_tokens, key)
428: #   environment for a model whose key_source is "analyst". complete is the
435: llm_json <- function(user, m, system_prompt = NULL, max_tokens, validate = NULL,
456:     out = complete(m, system_prompt, ask, max_tokens, key)
465:     if (identical(finish, "max_tokens"))
466:       llm_fail(paste0(served, "The reply reached the token limit (", max_tokens,
~~~~
Live check output (tests/llm_check.out), verbatim:
~~~~
QuestionR live check (tests/llm_check.R)
Run: 2026-11-11 21:05 | profile: home | ellmer 0.4.2
Draft prompt hash:  1f303eea542179e4ccaeae36146fa437b68cfedbc40e99a2c79420192b6b48b3
Review prompt hash: 907cea17ade3998b18d48d0974ad2c5a381fb3f84737962a8167cd0c6a8948a7

[ OK ] Project manager | claude-sonnet-5-5 | connection check | 1.3 s | 1 call | finish: -
      reply (first 300): OK
[ OK ] Worker 1 | google/gemma-4-31b-it | connection check | 0.5 s | 1 call | finish: -
      reply (first 300): OK
[ OK ] Worker 2 | meta-llama/llama-4-maverick | connection check | 0.5 s | 1 call | finish: -
      reply (first 300): OK
[ OK ] Worker 3 | openai/gpt-6-luna | connection check | 0.9 s | 1 call | finish: -
      reply (first 300): OK
[ OK ] Worker 1 | google/gemma-4-31b-it | draft, 2 items | 8.1 s | 1 call | finish: success | tokens in 2889 out 535
      reply (first 300): ```json { "items": [ { "id": "NEC_1", "domain": "competence and honesty (general trust)", "intro": "", "stem": "How much trust do you have in the national electoral commission?", "options": [ "A great deal of trust", "A lot of trust", "A moderate amount of trust", "A little trust", "No trust at all"
[ OK ] Worker 2 | meta-llama/llama-4-maverick | draft, 2 items | 5.7 s | 1 call | finish: success | tokens in 2784 out 454
      reply (first 300): ```json { "items": [ { "id": "Tnec1", "domain": "fairness", "intro": "", "stem": "How confident are you that the national electoral commission counts votes fairly?", "options": ["Not at all confident", "Not very confident", "Somewhat confident", "Very confident", "Extremely confident"], "open_format
[ OK ] Worker 3 | openai/gpt-6-luna | draft, 2 items | 32.1 s | 1 call | finish: success | tokens in 2779 out 2740
      reply (first 300): { "items": [ { "id": "TR1", "domain": "Trust in accurate vote counting", "intro": "", "stem": "How much do you trust the national electoral commission to count votes accurately?", "options": [ "No trust at all", "A little trust", "A moderate amount of trust", "A lot of trust", "A great deal of trust
[ OK ] Project manager | claude-sonnet-5-5 | small review | 47.4 s | 1 call | finish: success | tokens in 4155 out 6241
      findings: 6; check ids not in the CHECKLIST sent: 0
      reply (first 300): {"items":[{"id":"Q1","findings":[{"check":"one_thing","stage":"judgment","evidence":"'the recycling services and street cleaning provided by your local council'","problem":"Two different services are joined by 'and' under one rating. A respondent who is happy with recycling but unhappy with street c

ALL GREEN: TRUE  (8 of 8 calls)
~~~~

## 8. Registry and flow engine

| check | result |
|---|---|
| TASKS has the four tasks, each with label, kind, files, ask, fields | PASS |
| task kinds are draft or review, evaluate is review | PASS |
| build_step_prompt(form, 'work') equals build_prompt(form) | PASS |
| brief check: status ok, reply has questions and criteria | PASS |
| brief check prompt: persona, pm_brief and the task's rules; no drafting output format | PASS |
| drafts: one entry per worker, in order, all ok | PASS |
| each ok draft keeps the parsed reply with 2 items | PASS |
| a worker error and a wrong item count are recorded as failed, with a reason, and the run goes on | PASS |
| appraisal: status ok, labels A, B, C map onto the three model ids | PASS |
| same seed gives the same labels | PASS |
| only drafts that are ok become candidates | PASS |
| no model id, vendor or endpoint reaches the appraisal prompt | PASS |
| appraisal prompt: CANDIDATES then CHECKLIST then CHARACTERIZE, with the stems and the check questions | PASS |
| documentation checks are not in the appraisal checklist (skills 0.3) | PASS |
| appraisal system prompt: persona and pm_appraise rules, not the drafting rules | PASS |
| flow.R has no Shiny in it | PASS |
| flow.R never looks up a key | PASS |

Live run log (tests/run_generate.json), first 60 lines:
~~~~
{
  "schema": 1,
  "time": "2026-11-11T22:06:27-0500",
  "summary": [
    {
      "step": "brief check",
      "model": "claude-sonnet-5-5",
      "status": "failed",
      "seconds": 17.2372,
      "finish": null,
      "attempts": null,
      "tokens_in": null,
      "tokens_out": null,
      "error": "[claude-sonnet-5-5 via api.anthropic.com, finish: max_tokens] The reply reached the token limit (2000) without finishing, so it was cut off. Ask for fewer items and run again. It starts: {\"complete\": false, \"questions\": [{\"ask\": \"Which country is this for, and what is the official name of the national elec"
    },
    {
      "step": "draft",
      "model": "google/gemma-4-31b-it",
      "status": "ok",
      "seconds": 26.3108,
      "finish": "success",
      "attempts": 1,
      "tokens_in": 2889,
      "tokens_out": 700,
      "error": null
    },
    {
      "step": "draft",
      "model": "meta-llama/llama-4-maverick",
      "status": "ok",
      "seconds": 8.3293,
      "finish": "success",
      "attempts": 1,
      "tokens_in": 2784,
      "tokens_out": 614,
      "error": null
    },
    {
      "step": "draft",
      "model": "openai/gpt-6-luna",
      "status": "ok",
      "seconds": 52.8825,
      "finish": "success",
      "attempts": 1,
      "tokens_in": 2779,
      "tokens_out": 4550,
      "error": null
    },
    {
      "step": "appraisal",
      "model": "claude-sonnet-5-5",
      "status": "ok",
      "seconds": 91.0643,
      "finish": "success",
      "attempts": 1,
      "tokens_in": 5320,
      "tokens_out": 12961,
      "error": null
    }
  ],
~~~~

## 9. Review flow and gold test

| check | result |
|---|---|
| run_review: status ok, with system, user, hash and the parsed reply | PASS |
| run_review uses the prompt build_prompt() gives | PASS |
| a failed call is status failed with a reason, not an R error | PASS |
| check_review returns one row per finding with item, check, severity, evidence_found, check_known | PASS |
| a real quote and a sent check id are accepted | PASS |
| an invented quote and an unknown check id are flagged, not dropped | PASS |

tests/gold_items.csv rows: 59

Token measurement (tests/review_tokens.md), verbatim:
~~~~
# Token measurement: one 15-question review (tests/llm_check.R go review15)

Run: 2026-11-12 06:36 | profile: home
Model: claude-sonnet-5-5 | prompt hash fdae7e07ec83e84b0d67d18f6e6f8edf3cf16b67417eb329095c8a425c661194
Questionnaire: tests/review_questionnaire.txt, written for this test: 15 questions, 1823 characters.
Form: research question "Satisfaction with and use of local council services", population "Adults aged 18 and over living in the council area", mode web, no country, English.
Ceiling used for this measurement: 24000 tokens (the app's was 8000 until this run).

| Seconds | Tokens in | Tokens out | Finish | Attempts | Status |
|---|---|---|---|---|---|
| 154.9 | 4774 | 21272 | success | 1 | ok |

Findings: 33 in all, 20 rated 5 or above; 4 about the instrument. R's checks: 1 quotes not found, 0 checks not sent.

## Settings this implies

About twice what it used: an evaluation ceiling of 43000 tokens. The paste cap to match, about twice the characters of this questionnaire: 4000 characters.

~~~~

Gold test matches (tests/gold_matches.csv), verbatim:
~~~~
item,set,scope,finding_check,finding_problem,severity,matched_problem_id,match,only_unshown_options,note,evidence
F1,flawed,question,one_thing,Recycling and street cleaning are two different services joined by 'and'. A respondent who is satisfied with one and dissatisfied with the other has no true answer on a single scale. Any midpoint answer or choice of one service cannot be told apart in the data.,7,F1-P1,exact,,,'the recycling services and street cleaning provided by your local council'
F1,flawed,question,no_presupposition,"The stem assumes every respondent has these services from the local council and has had some experience of them. Some respondents may have a private or landlord arrangement, no recycling collection, or no idea who provides the service. For them the question does not apply, and there is no filter.",5,F1-P2,exact,,"The finding also says respondents may have had no experience of the services (F1-P3's content); one finding matches one problem, so F1-P3 counts as not found.",'provided by your local council'
F2,flawed,question,specific_concrete,"The wording does not say whose finances count (own or household), which part of them (income, savings, debts, spending) or what 'current' covers (today, this month, this year). The respondent has to settle all three before judging, so answers can differ in meaning from one person to the next.",6,F2-P1,exact,,,'your current financial situation'
F3,flawed,question,plain_words,"The stem gives no definition of 'vigorous' or 'moderate', so respondents may draw the line between them in different places, and some may treat the two as the same thing. On the web the definition has to be on screen with the question, and the stem has none.",6,,none,,,'vigorous physical activity and moderate physical activity'
F3,flawed,question,specific_concrete,"The stem does not say whether activity at paid work, housework, getting around or in free time counts. Respondents who have physically active jobs or do heavy housework could include it or leave it out, and the estimate would shift accordingly.",5,,none,,,'physical activity' (no setting named) and 'In a typical week'
F3,flawed,question,one_thing,"The item asks about two different intensities of activity and requires one total. A respondent may do a lot of one kind and little of the other, and the total hides this. The two hours-per-week quantities can no longer be analysed separately.",6,F3-P1,exact,,,'vigorous physical activity and moderate physical activity combined'
F3,flawed,question,retrieval_and_judgment,"Respondents must decide what a 'typical' week is, estimate hours for two kinds of activity and add them in their heads. This is harder for people whose weeks vary, for example because of shift work, seasons or irregular exercise. Short bouts spread across the week are also hard to recall and total up.",6,F3-P2,exact,,,"'In a typical week, how many hours ... combined'"
F4,flawed,question,neutral_wording,"The opening states as fact that pressure on public services is growing, and the tag 'don't you think' invites a yes. The closing clause frames immigrants as a possible burden. Together these make agreement the expected answer and supply a reason for it before the respondent has formed a view.",9,F4-P1,exact,,,"'Given the growing pressure on public services, don't you think that the government should do more' and 'particularly those who may not contribute to the economy'"
F4,flawed,question,simple_syntax,"The stem is a negative interrogative. It also stacks an introductory clause, a main clause and a trailing qualifier in one sentence. Respondents must keep all of it in mind, and with a negative question it is unclear what 'agree' means.",6,F4-P2,exact,,,"'don't you think that the government should do more to reduce the number of immigrants coming to this country, particularly those who may not contribute to the economy'"
F4,flawed,question,one_thing,"The item asks about reducing immigration in general and about reducing it for one subgroup. A respondent who wants fewer non-contributing immigrants but not fewer immigrants overall, or the reverse, has no accurate answer. 'Do more' and 'reduce the number' also add a policy-effort judgment to a judgment about the level.",7,,none,,,"'reduce the number of immigrants coming to this country, particularly those who may not contribute to the economy'"
F4,flawed,question,plain_words,"'Contribute to the economy' can mean paid work, paying tax, running a business, unpaid care or spending. 'May not' also leaves open whether it means now or in future. Respondents will read the group differently. 'Immigrants' may likewise be read as including or excluding refugees, students or long-settled residents.",6,,none,,,'those who may not contribute to the economy'
F4,flawed,question,specific_concrete,"'Do more' compares against current government action that many respondents may not know, and no policy, group or time frame is named. Respondents may answer about the current level of immigration, about government effort, or about a general feeling. These are different things.",5,,none,,,'the government should do more to reduce the number of immigrants'
F4,flawed,question,agree_disagree_and_grids,"A one-sided statement is open to acquiescence, and the leading wording adds to the pull toward agreeing. A direct question about the preferred level of immigration would ask for the same judgment without requiring respondents to convert it into agreement.",5,,none,,,"Strongly agree to Strongly disagree, attached to a single statement worded in one direction"
F5,flawed,question,no_presupposition,"The question assumes every respondent has an employer and a work contract. Retired people, students, unemployed people, full-time carers and many self-employed people have no terms of employment to rate. They must skip, guess or pick a scale point that is not true for them. Respondents with more than one job also do not know which job to rate.",8,F5-P3,exact,,,'your terms of employment' asked of 'Adults in the general population' with no filter and no not-applicable option
F5,flawed,question,plain_words,"This is a contract-style phrase. Some respondents will read it narrowly as pay, hours and holidays in their contract. Others will read it as the job in general, the workplace or their manager. The answer then rests on different content for different people.",6,F5-P1,exact,,,'terms of employment'
F5,flawed,question,response_scale,"The scale has three positive points and two negative points, so it is not balanced, and there is no neutral middle point. 'Completely' and 'very' are hard to tell apart, and the order of 'very' and 'fairly' depends on how each respondent reads these intensity words. Respondents who are neither satisfied nor dissatisfied have no true option, and no 'not applicable' option is offered (see the finding on presupposition).",6,F5-P2,exact,,,'Completely satisfied / Very satisfied / Fairly satisfied / Not very satisfied / Not at all satisfied'
F5,flawed,instrument,filters_and_routing,"Every adult respondent reaches Q1, so the question reaches people it does not apply to, and no route leads non-employees to a suitable next question. A screening question and a skip are needed before Q1 in the full instrument.",7,,none,,,"Q1 is the only item, with no screening question before it and no routing for people who are not employees"
F6,flawed,question,retrieval_and_judgment,"To answer, the respondent may have to find out what other household members receive, add several incomes together, convert weekly, annual or irregular pay into a monthly figure, and work out a before-tax figure when they may only know what is paid into their account. Each of these steps can produce a wrong total or a mixed basis (some before tax, some after).",7,F6-P2,approximate,,"Borderline: the finding is about the respondent having to find out and add up what other household members receive, not about household income being unidentifiable as such.","'total monthly income from all sources, before tax and deductions' for the household"
F6,flawed,question,specific_concrete,"The item does not say who counts as part of the household (for example adult children, lodgers, or relatives who share only some costs). It also does not say which month is meant (last month, a usual month, or an average), which matters when income varies. On the web there is no interviewer to explain, so any definition must be in the visible question text. The household definition should match the benchmark source the analyst will compare against, which the brief does not name.",6,,none,,,'household's' and 'monthly'
F6,flawed,question,plain_words,"'All sources' does not tell the respondent whether benefits, pensions, gifts from family, savings withdrawals, loans or one-off payments count. 'Deductions' is a payroll term whose scope (pension contributions, loan repayments, other items) is not clear to everyone. Respondents may therefore include different things.",5,,none,,,'from all sources' and 'before tax and deductions'
F7,flawed,question,one_thing,"The stem asks about two destinations, work and essential services, and the services are themselves several things. A respondent who finds the trip to work easy but the trip to a clinic hard has no single true answer and must average or pick one part. The analyst cannot tell which part the answer describes.",7,F7-P1,exact,,,'get to work and to access essential services such as healthcare'
F7,flawed,question,no_presupposition,"The stem assumes the respondent has a job they travel to. Retired people, unemployed people, full-time carers and people who work from home do not fit. The brief gives no filter, so these respondents must guess, skip or answer about something else.",6,F7-P3,exact,,,'get to work'
F7,flawed,question,plain_words,"'Essential services' has no fixed meaning, and one example does not say which others count. 'Access' can mean physically travelling there, getting an appointment, affording it or being eligible. Respondents may therefore answer about different things.",5,,none,,,'access essential services such as healthcare'
F7,flawed,question,specific_concrete,"The stem does not say whether difficulty means distance, travel time, cost, lack of transport or something else. It does not say which way of travelling to think of, or whether to think of a usual trip or the worst one. Respondents will fill these gaps differently. The analyst must decide which dimension and reference period the study needs.",5,,none,,,"'How easy or difficult is it' with no time frame, no way of travelling and no dimension of difficulty"
F7,flawed,question,options_fit,"A respondent who does not travel to work, or who has not needed healthcare, has no true option on the scale shown. A respondent whose answers differ between work and services also has no true option. The in-between options were not shown, so a midpoint could not be checked.",5,F7-P2,exact,,,'a scale running from Very easy to Very difficult' with no 'does not apply' option visible
F8,flawed,question,plain_words,"The term has no definition on screen. Respondents can differ on whether messaging apps, video-sharing sites, forums or workplace tools count, so the same hours could be reported or left out differently. 'Platforms' is also a technical word that not everyone uses for these services. The brief does not say which services the analyst wants counted, so that decision has to come from the analyst.",6,F8-P1,exact,,,'social media platforms'
F8,flawed,question,retrieval_and_judgment,"Respondents must recall many short sessions across several apps and devices, add them up, and convert the total to hours. Use that is spread through the day or runs in the background is hard to total. Respondents are likely to fall back on a guess or a stereotype of their own use.",6,F8-P2,exact,,,'Roughly how many hours per week do you spend on social media platforms?'
F9,flawed,question,one_thing,"The statement joins a view about how severe punishment should be with a view about longer prison sentences. A respondent who wants severe punishment but through other means, or who does not accept longer sentences, has no true answer on one agree-disagree scale. The 'even if' clause also assumes that severe punishment means longer prison terms.",7,,none,,,"'deserve to be punished severely, even if this means longer prison sentences'"
F9,flawed,question,specific_concrete,"Respondents may picture very different crimes (for example violent crime, fraud, drug offences) and different meanings of 'severely'. The answers then reflect different private reference points rather than one common object. Choosing which crimes to name, or whether to leave the term broad, narrows or changes the construct and is the analyst's decision.",5,,none,,,'serious crimes' and 'punished severely'
F9,flawed,question,agree_disagree_and_grids,"Only the punitive side is stated and there is no item keyed the other way, so acquiescence would inflate agreement and cannot be separated from the attitude. A construct-specific question about how severe punishment should be could do the same job without a statement to accept or reject.",5,,none,,,'To what extent do you agree or disagree?' after a single one-directional statement
F10,flawed,question,one_thing,"The stem asks about two situations at once. A respondent who feels safe in daylight but uneasy at night has no single true answer and must pick one, average the two, or answer for only one part. The result cannot be read as either time of day.",7,F10-P1,exact,,,'during the day and after dark'
F10,flawed,question,specific_concrete,"The stem does not say how large 'your neighbourhood' is. It could mean the street, the block, or a wider district. It also does not say whether it means being at home or walking outside, or what the respondent should be safe from, such as crime, traffic or something else. Respondents will fill these gaps differently.",5,F10-P2,exact,,,'safe in your neighbourhood'
F11,flawed,question,no_presupposition,"The question assumes every respondent needed, and tried to get, an appointment in the past 12 months. Respondents who did not need one, or who needed one but never tried to book, have no true answer on an easy-to-difficult scale. They may skip, guess, or pick a middle point, and that would mix non-users into the ratings.",6,F11-P3,exact,,,'when you needed one' with no filter before the item and no not-applicable option shown
F11,flawed,question,specific_concrete,"The phrase covers many kinds of provider (for example doctor, nurse, dentist, specialist, therapist, pharmacist). It also does not say whether a phone, video or walk-in contact counts as an appointment. Respondents will include different providers and contacts, and one who found a doctor easy but a specialist hard has no single true answer. The scope of 'healthcare professional' depends on what the analyst wants to measure, which the brief does not say.",6,F11-P1,exact,,,'a healthcare professional'
F11,flawed,question,retrieval_and_judgment,"A 12-month period can cover several appointments with different levels of difficulty. The respondent must remember them and average them into one rating, or may base the answer on the most recent or most memorable one. Different respondents will use different strategies.",5,F11-P2,exact,,,"'In the past 12 months, how easy has it been'"
F12,flawed,question,neutral_wording,"The first sentence states a claim as fact and appeals to research. It tells respondents what answer is expected before they judge for themselves, so high importance is favoured. This review cannot check whether the claim is true, but a question should not carry it as a premise.",9,F12-P1,exact,,,'Research consistently shows that children benefit from having a parent at home in the early years.'
F12,flawed,question,one_thing,"The item changes its object from 'a parent' to 'mothers', so the question bundles gender with the at-home arrangement. A respondent who thinks it matters that a parent is home, but not that it is the mother, has no accurate answer. Whether the intended construct is parental care or mothers' roles is not stated in the brief.",6,F12-P2,approximate,,"Same feature (the shift from 'a parent' to 'mothers') but framed as bundling gender with the at-home arrangement (one_thing), not as sensitivity.","The lead-in says 'a parent at home', but the question asks 'that mothers stay at home'."
F12,flawed,question,specific_concrete,"The phrase does not say whether it means full time, or whether a mother who works part time or from home counts. Respondents may read it differently and answer different questions. The analyst must decide which meaning is intended.",5,,none,,,'stay at home to look after their children'
F13,flawed,question,specific_concrete,"The first phrase asks for an overall view of life. The second narrows it to the present moment. Respondents may answer from today's mood or from a longer stretch of their life, and the brief does not say which time frame the analyst intends.",5,,none,,,'Taking everything into account' together with 'at this moment'
F14,flawed,question,one_thing,"The stem asks about two qualities joined by 'and'. A respondent who finds childcare easy to get but too costly, or the reverse, has no true answer on a single satisfaction scale. Any answer also mixes two judgments, so it cannot be read as either one.",7,F14-P1,exact,,,'availability and affordability of childcare services'
F14,flawed,question,no_presupposition,"The stem assumes the respondent knows enough about local childcare to judge it. Adults with no children, or whose children no longer need care, may have no basis for an answer. They must either guess, pick a midpoint they do not mean, or leave the item. Whether the analyst wants the views of all adults or only those with experience is not stated in the brief.",7,F14-P2,exact,,"Borderline between exact and approximate: framed as respondents lacking a basis to judge childcare (adults with no children), where the known problem says the question assumes a need for childcare.",'How satisfied are you with ... childcare services in your area?' asked of 'Adults in the general population' with no filter or not-applicable option
F14,flawed,question,plain_words,"The term can be read as formal paid provision, such as nurseries or paid carers. It can also be read to include care by grandparents or other relatives, or after-school care. Which meaning a respondent picks changes what they judge. The analyst must decide which kinds of care the item is meant to cover.",5,,none,,,'childcare services'
F14,flawed,question,specific_concrete,"'Area' has no fixed size. Respondents may think of their street, their town or a wider region, and may judge different sets of providers. Where it is meant to apply, such as near home or near work, is also left open.",5,,none,,,'in your area'
F15,flawed,question,neutral_wording,"The lead-in states two contested claims as fact and says what the respondent is expected to value. Respondents who want to appear responsible, or who feel they should have acted, may report more change than they made, and those who disagree with the claims may be pushed to react to them. The shifts would come from the framing, not from behaviour.",8,F15-P1,exact,,,'Considering the urgent need to address climate change and the fact that individual actions collectively make a significant difference'
F15,flawed,question,plain_words,"This is a technical or metaphorical term, and the item gives no definition. Some respondents may read it as energy use only, others as all environmental harm, and others may not know it. The web mode allows the definition to sit in the question text.",6,,none,,,'personal carbon footprint'
F15,flawed,question,one_thing,"'Daily habits' covers many different behaviours, such as travel, food, home energy and shopping. A respondent who changed one area but not another has no clear answer. To pick one position on the scale, the respondent must recall changes across all areas, add them up, and decide which count as done 'specifically' for this reason. The brief names no construct, so the domains that matter are for the analyst to choose.",6,,none,,,'changes to your daily habits'
F15,flawed,question,options_fit,"The question asks about change over the past year. Someone who already lived in a low-carbon way before that year, and so made no recent change, has no true option: 'Not at all' would suggest they do nothing. The in-between options were not shown, so they could not be checked.",5,,none,,,Response options 'A great deal' to 'Not at all'
F16,flawed,question,plain_words,"'Community organisation' has no shared boundary. Respondents may differ on whether a place of worship, sports club, school parents' group, trade union or national charity counts. 'Work' may also be read as a job-like task, so helping at a one-off event could be left out. The brief does not say which organisations the analyst wants counted.",6,F16-P1,exact,,,'voluntary or unpaid work for a community organisation'
F16,flawed,question,specific_concrete,"A 'time' is not defined. A weekly volunteer might count each session, count each week, or count the whole year as one ongoing commitment, and a one-off event might count as one. 'Past year' could also mean the last 12 months or the calendar year.",6,F16-P3,approximate,,"The finding's main point is that a 'time' is undefined; its last sentence says 'past year' could mean the last 12 months or the calendar year, which is F16-P3.",'How many times in the past year'
F16,flawed,question,retrieval_and_judgment,"The respondent must recall and count episodes over 12 months. Regular volunteers have to multiply or estimate, and occasional volunteers may forget one-off events. The task is hard at the retrieval stage in different ways for these two groups.",5,F16-P2,exact,,,'How many times in the past year' combined with a top option of 'More than 10 times'
F17,flawed,question,options_fit,"The stem asks how adequate the space is, which invites an answer such as 'very adequate' or 'not at all adequate'. The options instead measure whether there is too much or too little space. A respondent with plenty of space may think 'adequate' fits well but find no matching option, or may be unsure how 'adequate' maps onto 'too much'. The stem and the scale ask different questions.",6,F17-P2,exact,,,'How adequate is the amount of space' paired with options running from 'Far too much space' to 'Far too little space'
F17,flawed,question,specific_concrete,"The question does not say which space counts: rooms inside, storage, a garden, balcony or other outdoor areas. It does not say which needs count: sleeping, privacy, working or studying at home, hosting, storage. Respondents may fill these gaps differently, so the same housing situation could get different answers. The analyst must decide what the space construct covers, and this review cannot decide it.",5,,none,,,'the amount of space in the home' and 'the needs of your household'
F18,flawed,question,one_thing,"The stem asks about two topics with one answer. A respondent who argues often about money but never about children has no true single answer. Anyone who answers has to average the two topics in their head, and the analyst cannot tell which topic drove the answer.",8,F18-P1,exact,,,'argue about money and about how to raise your children'
F18,flawed,question,no_presupposition,"The stem assumes every respondent has a partner and children they are raising. Adults in the general population include people with no partner and people with no children, so the question does not apply to them. The wording also assumes that arguments happen at all.",8,F18-P3,exact,,,'you and your partner' and 'your children'
F18,flawed,question,specific_concrete,"The stem gives no reference period, so each respondent picks their own: the past week, the past year, or the whole relationship. Answers are then not comparable. The brief gives no reference period, so its length is the analyst's choice.",6,,none,,,'How often do you...' with no time frame
F18,flawed,question,options_fit,"No option is offered for people with no partner or no children. They must choose 'Never', which is untrue for them and mixes them with partnered respondents who do not argue. This overlaps with the presupposition finding: a filter question or a 'does not apply' option would each solve it, and the analyst decides which.",5,,none,,,'a scale running from Very often to Never'
F18,flawed,instrument,filters_and_routing,"Nothing sends people without a partner, or without children, past Q1. Every adult in the general population would reach an item that applies only to some of them. In web mode no interviewer can skip or clarify it.",6,,none,,,Q1 is the only item pasted and no screening question comes before it
F19,flawed,question,neutral_wording,The opening clause states as fact that there were scandals and links them to the trust judgment. This pushes respondents toward low trust and supplies the mood and the standard of comparison for the answer.,8,F19-P1,exact,,,Given the recent scandals in government
F19,flawed,question,no_presupposition,"The question assumes every respondent knows of these scandals and accepts that they happened. Respondents who know of none, or who dispute the label 'scandals', cannot answer on the terms given. The brief does not say which events are meant.",6,,none,,,the recent scandals in government
F19,flawed,question,specific_concrete,"It is not clear whose trust is being asked about: national, regional or local politicians, the governing party, or all of them. Respondents must choose their own referent and may differ, and they must average across many people to answer. The analyst should choose the level that matches the research aim, which the brief does not state.",5,,none,,,politicians
F20,flawed,question,simple_syntax,"One sentence holds the question, a 'not including' exclusion list, a 'but including' inclusion list and a time frame. The respondent has to keep both lists in mind before reaching the end, and the negated exclusion adds load. Some respondents will lose part of the rule and answer on their own idea of leisure.",6,F20-P1,exact,,,"not including time spent on domestic tasks, caring responsibilities, or personal grooming, but including any time spent on hobbies, socialising, watching television, reading, or using the internet for personal enjoyment"
F20,flawed,question,retrieval_and_judgment,"The respondent must recall several separate activities, estimate time for each, add them up, and average over days that may differ. Activities that overlap, such as television on while doing chores or internet use at work, make the sum harder to judge. Anyone whose weekdays vary has no 'typical' day to retrieve.",6,F20-P3,exact,,,"On a typical weekday, approximately how many hours do you spend on leisure activities ... hobbies, socialising, watching television, reading, or using the internet"
F20,flawed,question,plain_words,"These are formal terms and may not be read the same way by everyone. 'Caring responsibilities' may be taken to mean only care for someone ill or dependent, so playing with one's own child could be counted as leisure by some and as care by others. 'Domestic tasks' may or may not include cooking, gardening or shopping.",5,,none,,,"domestic tasks, caring responsibilities, or personal grooming"
F20,flawed,question,specific_concrete,"The lists do not say how to treat activities that fall between categories, such as sport or exercise, resting or doing nothing, religious or community activity, or cooking or gardening done for pleasure. Respondents will draw the boundary differently, so totals are not comparable. Which of these belong in the construct is the analyst's decision.",5,F20-P2,exact,,"Matched to this finding (activities between categories) rather than to the plain_words finding on the exclusion terms, because one finding matches one problem.",leisure activities
C7,control,question,plain_words,"'Fruit' is read differently by different people: fresh only, or also dried, tinned or frozen fruit, fruit in a smoothie, or fruit cooked into a dish. The exclusion names only juice, so the other forms are left to each respondent. Which forms count is the analyst's decision, and the brief does not say.",5,,none,,,"fruit, excluding drinking juice"
C7,control,question,specific_concrete,"The stem gives no time frame, so each respondent picks their own period, such as last week, a typical week or the current season. Fruit eating can vary by season and by week. The unit 'times' is also undefined: it could mean separate eating occasions or pieces of fruit, so someone who eats two apples at once could answer either way. Which period fits depends on what the estimate is for, and the brief does not say.",5,,none,,,'How often do you eat fruit' with the top option 'Three times or more a day'
C8,control,question,specific_concrete,"The item does not say which parts of life to consider (for example work, money, health, family), so respondents could each pick different parts or average over them. 'Nowadays' gives no clear time frame, so it is unclear whether the answer is about this week, this year or recent years. The brief names no construct or reference period, so the analyst must decide how narrow the item should be.",5,,none,,,'over your life in general nowadays'
~~~~

Gold test summary (tests/gold_summary.md), verbatim:
~~~~
# Gold test: the Evaluate review against the known problems

Test items: Sturgis, P., Roberts, C. and Robinson, T. (2026), LLMs for survey pretesting: How well can large language models identify flaws in survey questions? Survey Futures Working Paper 15, Appendix B, as transcribed by the Claude project into `tests/gold_items.csv` (20 flawed questions with 48 known problems; 7 European Social Survey core items as controls). Run on 2026-11-12.

**The matching of findings to known problems was done by the builder (Claude, in Claude Code), by reading, after all 27 reviews were saved. It is a judgement and is to be checked.** Every match is in `tests/gold_matches.csv` with a note where it was a close call; the borderline ones are listed below. Nothing in the app, a skill, a prompt, a threshold or a test was changed after seeing the results.

## How it was run

- Each of the 27 items was reviewed alone through `run_review()`, as a one-question questionnaire (`Q1. <question>` and a `Response options:` line), by the project manager model (claude-sonnet-5-5) with the app's own evaluation ceiling of 43,000 tokens, which was not raised. Form: research question "Evaluate this survey question", population "Adults in the general population", web, no country, English.
- The model was shown only the question and its options. Where the paper prints only the two end options (`scale_complete` FALSE, 19 of the 27 items in the file) the line reads `a scale running from <first> to <last> (the options in between are not shown in this test)`. The runner asserts before every call that the prompt holds no id, topic, set, problem id or problem text.
- All 27 calls finished (27 ok, 0 cut off, 0 other failures), each on the first attempt. Raw replies are in `tests/gold_runs/<id>.json`.
- Matching: only findings rated 5 or above were matched. Exact means the same problem with the same framing; approximate means the same underlying issue with a different emphasis. One finding matches at most one known problem and the reverse. Findings about the instrument (routing across questions) were matched like the others; there were none at 5 or above on a control item.

## Share of known problems found

- **Of all 48: 36 found, 75.0%** (33 exact, 3 approximate). Target 65%.
- **Of the 45 that can be judged from the end options alone: 36 found, 80.0%.** The 3 problems that need the full scale (F2-P2, F12-P3, F19-P2) were all not found.

Approximate matches, and the close calls among the exact ones, are the least certain: F6-P2, F12-P2 and F16-P3 (approximate), F14-P2 (exact, borderline), and F1-P2, where one finding states the content of two known problems and only one can be credited.

### Detection by problem type

| Problem type | Known | Found | Share | Judgeable | Found of judgeable |
|---|---|---|---|---|---|
| presupposition | 9 | 7 | 77.8% | 9 | 9 |
| vague/ambiguous | 9 | 8 | 88.9% | 9 | 9 |
| response-mapping | 7 | 3 | 42.9% | 4 | 4 |
| double-barrelled | 6 | 6 | 100.0% | 6 | 6 |
| leading/loaded | 5 | 4 | 80.0% | 5 | 5 |
| retrieval/recall | 5 | 5 | 100.0% | 5 | 5 |
| sensitivity | 4 | 1 | 25.0% | 4 | 4 |
| complex-syntax | 3 | 2 | 66.7% | 3 | 3 |

### Known problems not found

| Problem | Type | Known problem | Closest finding below severity 5 (builder's reading) |
|---|---|---|---|
| F1-P3 | presupposition | assumes respondent has experience of services | none separate; the severity 5 presupposition finding that matched F1-P2 also says respondents may have no experience of the services |
| F2-P2 | response-mapping | categories use inconsistent linguistic constructions | finding 7 (severity 4, response_scale): the two end labels are not parallel and the verb phrases differ |
| F6-P1 | sensitivity | precise income is a highly sensitive question | none |
| F9-P1 | leading/loaded | frames punishment as deserved | finding 37 (severity 4, neutral_wording): 'deserve' asserts a moral claim as fact |
| F9-P2 | sensitivity | social desirability around criminal justice attitudes | none |
| F12-P3 | response-mapping | no neutral midpoint | none |
| F13-P1 | vague/ambiguous | "the way things are going" conflates trajectory with current state | finding 49 (severity 4, plain_words): 'the way things are going' read as state or as direction |
| F13-P2 | response-mapping | only endpoints labelled on 0 to 10 scale | finding 50 (severity 4, response_scale): only the endpoints carry words |
| F15-P2 | complex-syntax | long sentence with conditional premise, domain specification, purpose clause, and time reference | finding 60 (severity 4, simple_syntax): one sentence stacking two premises, a purpose clause and a time frame |
| F17-P1 | presupposition | assumes respondent has a fixed home | finding 69 (severity 3, no_presupposition): assumes one home and one clear household |
| F18-P2 | sensitivity | reporting arguments is sensitive | none |
| F19-P2 | response-mapping | asymmetric scale interacts with leading preamble | none |

Findings are shown to the analyst only at severity 5 or above, so the ones in the last column would not have been seen. Six of the twelve (F2-P2, F9-P1, F13-P1, F13-P2, F15-P2, F17-P1) have a finding of that kind that matches them on the builder's reading; counting them would give 42 of 48. That is context, not the result: the threshold was not changed.

## Control items (7 ESS core items)

- **Findings rated 5 or above per control item: 0.43** (3 findings over 7 items; 2 of the 7 items have any). Target at most 1.0.
- **After setting aside findings that are only about the in-between options not being shown: 0.43** (3 findings). None of the control findings at 5 or above was only about that, so the two counts are the same. Instrument-level findings at 5 or above on a control item: 0.

| Control item | Findings at 5 or above (question) | (instrument) | After setting aside unshown-options findings |
|---|---|---|---|
| C1 | 0 | 0 | 0 |
| C3 | 0 | 0 | 0 |
| C4 | 0 | 0 | 0 |
| C5 | 0 | 0 | 0 |
| C6 | 0 | 0 | 0 |
| C7 | 2 | 0 | 2 |
| C8 | 1 | 0 | 1 |

The control findings at 5 or above:

- C7, plain_words, severity 5, on fruit, excluding drinking juice: 'Fruit' is read differently by different people: fresh only, or also dried, tinned or frozen fruit, fruit in a smoothie, or fruit cooked into a dish. The exclusion names only juice, so the other forms are left to each respondent. Which forms count is the analyst's decision, and the brief does not say.
- C7, specific_concrete, severity 5, on 'How often do you eat fruit' with the top option 'Three times or more a day': The stem gives no time frame, so each respondent picks their own period, such as last week, a typical week or the current season. Fruit eating can vary by season and by week. The unit 'times' is also undefined: it could mean separate eating occasions or pieces of fruit, so someone who eats two apples at once could answer either way. Which period fits depends on what the estimate is for, and the brief does not say.
- C8, specific_concrete, severity 5, on 'over your life in general nowadays': The item does not say which parts of life to consider (for example work, money, health, family), so respondents could each pick different parts or average over them. 'Nowadays' gives no clear time frame, so it is unclear whether the answer is about this week, this year or recent years. The brief names no construct or reference period, so the analyst must decide how narrow the item should be.

## Seconds and output tokens per item

| | Seconds | Output tokens |
|---|---|---|
| All 27 | mean 31.0, range 17.6 to 47.6 | mean 3940, range 2179 to 6521 |
| 20 flawed | mean 33.5, range 22.0 to 47.6 | mean 4301, range 2698 to 6521 |
| 7 control | mean 23.9, range 17.6 to 40.9 | mean 2907, range 2179 to 5278 |
~~~~

## 10. Long questionnaires, output and methodology

| check | result |
|---|---|
| split: more than one part, none over the limit | PASS |
| split: every block kept whole, once, in order | PASS |
| split: a single block over the limit stops with a message | PASS |
| long review: one call per part and one for the instrument | PASS |
| long review: item calls carry no instrument checks, the instrument call carries no item checks | PASS |
| long review: status ok, all 30 items in pasted order, instrument findings kept | PASS |
| long review: batches recorded, one per call, each with status and hash | PASS |
| a failed part gives status partial, names the part, and keeps the rest | PASS |
| a short questionnaire is still one call with the Phase 4 prompt | PASS |
| skills_table: one row per reflex with file, id, when, source | PASS |
| www/methodology.md present | PASS |

Long live review (tests/review_long.md), verbatim:
~~~~
# One live long review, in parts (tests/llm_check.R go review30)

Run: 2026-11-12 18:38 | profile: home
Model: claude-sonnet-5-5 | evaluation ceiling 43000 tokens a call, batch size 4000 characters, paste cap 40000; none was changed for this run.
Questionnaire: tests/review_long_questionnaire.txt, written for this test: 30 questions in 30 blocks, 5028 characters.
Form: research question "Household energy use, travel and quality of life", population "Adults aged 18 and over living in England", mode web, no country, English.
Parts: 2 (first blocks 1, 24), so 3 calls: one for each part and one for the instrument as a whole.

| Call | Characters | Seconds | Tokens in | Tokens out | Finish | Attempts | Status |
|---|---|---|---|---|---|---|---|
| part 1 of 2 | 3766 | 129.2 | 5,592 | 18,207 | success | 1 | ok |
| part 2 of 2 | 1260 | 62.6 | 4,645 | 8,421 | success | 1 | ok |
| instrument | 5028 | 111.0 | 5,663 | 15,386 | success | 1 | ok |

Total: 303 seconds (5.0 minutes), 15,900 tokens in, 42,014 tokens out. Result status: ok.

Failed parts: none.

Findings: 45 in all: 34 about questions and 11 about the instrument.
By band: Fix before fielding 4, Needs your judgment 25, Minor 16.
**Share of question findings whose evidence was found in the pasted text: 34 of 34 (100.0%).** Phase 4's gold run found 55 of 100 (45 had evidence that was a description).
Checks not in the checklist that was sent: 0.
Questions back: 30 of 30; ids exactly as pasted, in order.
Item calls that filled fields they were told to leave empty (instrument, test_first, trapd, not_assessed): 0 of 2 (0, 0 entries).
The instrument call returned 0 question entries (it was told to leave items empty).

~~~~

Sample output for Word, drafting (tests/output_generate.txt), verbatim:
~~~~
Survey items
============

First drafts by language models, untested.

CONF1
-----

Nous allons vous poser quelques questions sur la commission électorale nationale.

Dans quelle mesure faites-vous confiance à la commission électorale nationale ? (modèle 1)

1. Beaucoup
2. Assez
3. Peu
4. Pas du tout

[Randomize the order of options 1 to 4; keep Pas du tout last.]

English source: How much do you trust the national electoral commission? (1)

CONF2
-----

Dans quelle mesure faites-vous confiance à la commission électorale nationale ? (modèle 2)

1. Beaucoup
2. Assez
3. Peu
4. Pas du tout

    Asked if the answer is Peu or Pas du tout: Pourquoi ?

English source: How much do you trust the national electoral commission? (2)

TRAPD: what is still needed
===========================

- The model's version is a first draft inside the Translation step only.
- Review by people fluent in both languages and in survey design is still needed.
- Adjudication of disagreements by a named person is still needed.
- Pretesting in the target language with members of the target population is still needed.
- Documentation of every decision, and of the model's part in it, is still needed.

Disclosure of the use of language models
========================================

- Date: 2026-11-12 09:30
- Profile: home
- Project manager model: vendor-p/pm-model (example.invalid)
- Worker models that drafted: vendor-a/model-one (example.invalid); vendor-b/model-two (example.invalid); vendor-c/model-three (example.invalid)
- Skill files and versions: core.md 0.2; generate.md 0.3; attitudinal.md 0.2; mode.md 0.1; cross_cultural.md 0.1; pm_appraise.md 0.3; pm_brief.md 0.1
- Brief check prompt: 395ddacac624fd946a3de8f690cdd69ba36b282b35b74b3df4c7f54c9e56afff
- Drafting prompt (not edited): b6438476295bc94614d64a469052af204f45cdb8c43030daa3735363398dae72
- Appraisal prompt: bbde744f6041e821f31f8abea85dab6ec16d8e222da11db74b1ab5f4ee63887c
- Item 1 (CONF1): candidate A, written by vendor-a/model-one
- Item 2 (CONF2): candidate C, written by vendor-b/model-two

Expert-review appraisal and first drafts by language models. Not a pretest. Test with real respondents before fielding.

~~~~

Sample output for Word, review (tests/output_review.txt), verbatim:
~~~~
Review of the questionnaire, question by question
=================================================

An expert-review appraisal by a language model against a fixed checklist. It shows where a respondent may have trouble. A rewrite or a probe is untested.

Question Q1
-----------

Fix before fielding

- one_thing (severity 8): "recycling services and street cleaning". Two services in one question. A rewrite, untested: How satisfied are you with the recycling services? A probe: Which service did you think of?

Needs your judgment

- response_scale (severity 6): "Fairly satisfied / Fairly dissatisfied". There is no middle option.

Minor (rated below 5)

- plain_words (severity 3): "street cleaning". Could mean sweeping or litter bins.

Question Q2
-----------

Fix before fielding

- neutral_wording (severity 7): "Do you agree that the council should". Invites agreement.

Needs your judgment

- no_presupposition (severity 5) [quote not found in the text]: "words that are nowhere in the questionnaire". Assumes an opinion.

Question Q3
-----------

No problem was found by this review.

The instrument as a whole
=========================

Needs your judgment

- filters_and_routing (severity 5): Questions: Q2 and Q3. Q3 applies only to library users.

What to test first
==================

- Question Q1: cognitive interviews

What this review could not judge
================================

Fit to objectives was not assessed: the brief names no analysis plan.

Disclosure of the use of language models
========================================

- Date: 2026-11-12 09:30
- Profile: home
- Project manager model: vendor-p/pm-model (example.invalid)
- Skill files and versions: core.md 0.2; evaluate.md 0.3; mode.md 0.1
- Review prompt (not edited): 4cb3acaf9cc38c1a4ab6d4947c0d87a877aabf83661baab1ccd571a67e8ecdf8

Expert-review appraisal and first drafts by language models. Not a pretest. Test with real respondents before fielding.

~~~~
