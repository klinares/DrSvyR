# QuestionR review evidence, Phase 0

Generated 2026-11-11 12:56 by tests/review.R on R version 4.6.1 (2026-06-24 ucrt).
Packages: shiny 1.14.0, bslib 0.12.0, ellmer 0.4.2, purrr 1.2.2, dplyr 1.2.1, stringr 1.6.0, jsonlite 2.0.0, digest 0.6.39

## 1. Git

Branch:
~~~~
questionr
exit status: 0
~~~~
Last commits:
~~~~
00e5741 svysegment: segment names follow the AI reflexes
6ed970c svysegment: number check accepts correctly rounded figures
877cd8d svysegment: send no temperature unless one is configured
aeee335 svysegment: call Claude through ellmer::chat_anthropic() instead of hand-built OpenRouter requests
62600f2 svysegment: AI reflexes as a markdown document, with a reporting style and examples
1db630b svysegment: AI reflexes for every model-written passage, grounded in survey methodology
b168e50 svysegment: Start here names the language models in use; best practices replace limits
df9547a svysegment: standard writing rules for every model-written passage; always write the summary
f95a888 svysegment: plots readable in light and dark themes
fca7039 svysegment: let the analyst set the range of segment numbers to search
c22f1f4 svysegment: card layout for Start here; method report and office logo
f7ec3f9 svysegment: record the survey and research question on Items; use both to name segments
5f5ab8a svysegment: speed up the EM engine without changing a number
21635ba svysegment docs: the full search takes about three minutes, not ten
1e055a1 svysegment: remove unused arguments and stale text
exit status: 0
~~~~
Uncommitted:
~~~~
?? ./
exit status: 0
~~~~
Changed against main (outside QuestionR/ expect only the root README.md and CLAUDE.md):
~~~~
exit status: 0
~~~~

## 2. Files and budget

| file | lines |
|---|---|
| app.R | 186 |
| R/_disable_autoload.R | 5 |
| R/llm.R | 129 |
| R/ui.R | 118 |
| tests/openrouter_check.R | 81 |
| tests/review.R | 365 |
| tests/smoke.R | 96 |

Code files counted: 5 of 8 allowed: PASS
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
| key read from the environment for a pasted-key model (Sys.getenv in R/, listed for reading) | none | READ |

Top-level expressions in R/ that are not assignments: PASS
Names defined more than once across R/: PASS
pkg::fn calls checked: 7. Not exported by the installed package: PASS

## 4. Skill files

PASS means the file is byte for byte what the Claude project drafted (line endings aside).

| file | result | sha |
|---|---|---|
| README.md | PASS | 1f56ceef8b247da8e33ae6989c4c73cbc40e1ff3b6086e5fc47eddb9854c0452 |
| attitudinal.md | PASS | a926209144f478d58aab78c966c540d53c71796352edc8c3cab88793234163f9 |
| behavioral.md | PASS | 4398ccff91973dd238b4688147b6dc548becd0545bc6d07b1c2a273b6e7261d4 |
| core.md | PASS | a83d291513ca83405b5ca07013a139fb5bb1563c5882ff15c4ec584b7edf4007 |
| cross_cultural.md | PASS | 6c8a19b8c17b19808b4cfca788b3c76a7595d54a3a25a71e355391cb944bdd4d |
| evaluate.md | PASS | 01c5046be626db9f2029a45f80aba6c7877b9f7ee560ffb264d9ee33896c62a5 |
| generate.md | PASS | 1308a588568d53e23881f0793accb4ec8517a36201e3fbfcfd3cf1944e0bde92 |
| mode.md | PASS | 98d2c27cd11711f142e9903a85efd65c902bef4cfa7f4d615df6b0d3df3f60e0 |
| pm_appraise.md | PASS | a34bcaff18ea705a863a337603505d958a940f8457b448fc030698b4773ed401 |
| pm_brief.md | PASS | a1686dbea0a0aa619269086b5f0372b32a017fe07ae252aee20d5e52e3b4856a |
| sensitive.md | PASS | a5484618ef4a50f97a4d5fd1e4d98ca43c54af3505077d6fd743d515792465f0 |

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
ok  the not-yet-built tabs say so
ok  home profile: PM on a pasted key, three workers
ok  work profile loads
ok  an unknown profile stops the app and names the choices
ok  no key is held before one is pasted
ok  a pasted key is held for the session, trimmed
ok  the key is not in the environment
ok  saving the key bumps key_version
ok  a forgotten key is gone
exit status: 0
~~~~

## 6. Prompt assembly

Not due until Phase 1.

## 7. Model layer

Not due until Phase 2.
