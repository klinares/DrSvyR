# SurvAI Expert

A Shiny app that answers survey methodology questions from a library of course materials: JPSM
lecture notes, slides, assignments and exams, a sampling and weighting textbook, and R code. Each
answer is written from passages found in the library; formulas are shown as stored, never retyped
by the model, and each formula is followed by an R example built from the library's code.

Each question makes two model calls: one plans the search, one writes the answer. The key is
pasted on the Start here tab and held for the session only.

## The five tabs

| Tab | What it does | Model calls |
| --- | --- | --- |
| Start here | What the tool is for, two figures, the key box and the call count. | none |
| Ask | A question (up to four parts), or a situation to get advice on (options, trade-offs by source of error, a recommendation), with optional details of the person's survey and data ("My survey"). | 2 per question |
| Formulas | Searches the stored formulas; each shows its symbols, up to 3 R examples from the library and a "Show me how in R" button (which asks about that formula with the Ask tab's My data). | none; 2 for the button |
| Report reader | Reads a survey's technical report (PDF or Word) into an analyst's checklist. | 1; a long report, one per part plus 1 |
| Methodology | The sources of error, what is in the library (counts from the store), how answers are produced and checked, how it was tested, limits. | none |

## Settings at the top of `app.R`

- `MODEL_PROFILES` and `MODEL_PROFILE`: the model and its endpoint; `SURVAI_PROFILE=work` picks the work profile.
- `SHOW_SOURCES` (now `FALSE`): whether answers show their sources. `FALSE` hides the citation
  numbers, the "Sources (n)" line, the source link under each formula, the dotted underline of
  uncited text and its legend, and, on the Formulas tab, the course filter, each result's course
  and document, and "Where it occurs". "Check:" sentences lose their source numbers. Citations are
  still requested, checked and stored, so `tests/eval.R` gives the same results either way.
  `TRUE` shows all of it.
- `CALLS_PER_WINDOW`, `CALLS_WINDOW_HOURS`: the call limit per session (none at home; 300 over 4 hours at work).
- `APP_SOURCE_URL`, `SOURCES_NOT_IN_REPO`: where a source's file opens when sources are shown.
- `KEY_ENV`: the environment variable the key is read from for console use and tests.

## Text you can edit (no code)

| File | What it is |
| --- | --- |
| `www/start_here.md` | The Start here text. The lines `[TSE figure]` and `[What it does figure]` place the two figures. |
| `www/methodology.md` | The Methodology text. `{{LIBRARY_TABLE}}` places the table of library counts. |
| `www/reflexes/` | What the model is told: `plan.md` (the search plan, and whether a message is a lookup or a request for advice), `answer.md` (how a lookup is answered), `advise.md` (how advice is given), `report.md` (the report reader). |

The two figures are `www/fw_tse.svg` (the Total Survey Error framework) and `www/what_it_does.svg`
(what you can do with the tool). Each is shown full width up to 900px, with the `<title>` inside
the SVG as its alt text; to replace one, keep its file name and its `<title>`.

## Run at home

```r
shiny::runApp("SurvAI_Expert")
```

The store `data/store/survai.duckdb` must exist; build it once (below). From the console, without
the app: `setwd("SurvAI_Expert"); source("app.R"); ask("your question")`, with the key in
`ANTHROPIC_API_KEY`.

## Getting it running at work (throwaway: delete this section once it is live)

Everything needed is text in git. Nothing binary travels: the store is built at work from the
text files, with no model calls and no network. Only steps 6 to 8 use model calls (2, about 36
and about 180), so they fit one 4-hour window of 300 if the app is not used meanwhile.

**1. Get the files.** Pull the repository. The textbook is the one source kept out of the public
repository:

- With the textbook: clone the private repository `klinares/survai-practools` and copy its
  `data/` folder over `SurvAI_Expert/data/`, then build the store (step 3).
- Without it: carry on. The app works; it has about 1,100 fewer passages and 550 fewer formulas.

**2. Check the packages.** In R:

```r
need <- c("shiny", "bslib", "dplyr", "purrr", "stringr", "tibble", "tidyverse", "DBI", "duckdb",
          "commonmark", "coro", "ellmer", "htmltools", "jsonlite", "katex", "later", "pdftools",
          "promises", "tidyr", "xml2")
setdiff(need, rownames(installed.packages()))   # install whatever this prints
packageVersion("ellmer")                        # 0.4.2 or later
packageVersion("duckdb")                        # home build used 1.5.5
```

**3. Build the store** (about 20 seconds). From inside `SurvAI_Expert/`:

```
Rscript --no-init-file build/03_store.R
```

It ends with the receipt check, one line per table that differs from the build recorded in
`data/catalog/receipt.csv`. "Receipt: identical" means the store matches. Without the textbook,
`practools` rows are missing and the word-count tables are smaller; that is expected. If every
table differs, the DuckDB version is the likely cause: the row counts should still match.

**4. Fill the `work` profile at the top of `app.R`.** It is set up for an OpenAI-compatible
endpoint and starts with the settings every such endpoint accepts.

- `base_url`: the endpoint, ending before `/chat/completions`. `id`: what it calls Opus 5.
- Leave `json = "prompt"`, `stream = FALSE` and `effort = NULL` until step 6 works. Then try,
  one at a time: `stream = TRUE` (answers appear as they are written), `json =
  "response_format"` (stricter replies). If a call is refused, the error names the setting to
  change back.
- `CALLS_PER_WINDOW <- 300`.
- `KEY_ENV`: the name of the environment variable holding the work key (tests and console only;
  in the app the key is pasted on Start here).
- `APP_CLASSIFICATION`, `APP_OFFICE`, and a logo file in `www/logo/` named as in `APP_LOGO`.

Then set `SURVAI_PROFILE=work`, for example in `.Renviron`.

**5. Test without spending calls.** From inside `SurvAI_Expert/`:

```
Rscript --no-init-file tests/smoke.R      # every line "ok"
Rscript --no-init-file tests/eval.R       # search test; home figures are in tests/eval_report_home.md
```

**6. Ask one question and one request for advice from the console (4 calls).**

```r
setwd("SurvAI_Expert"); source("app.R")
ask("What is the design effect from unequal weighting?")$answer
ask("After raking, my weights run from 0.1 to 25. Should I trim them?")$answer
```

The first should give a formula and an R example; the second should have the headings "What I
understand", "Options", "What I would do" and "What to check".

**7. Run the advice test (about 36 calls).**

```
Rscript --no-init-file tests/eval.R advice
```

Read `tests/advice_report.md`: how many of the 12 situations passed, and which points were
missed.

**8. Run the accuracy test (about 180 calls, 25 minutes).**

```
Rscript --no-init-file tests/eval.R answers
```

Compare `tests/eval_report.md` with the home run in `tests/eval_report_home.md`. The top of
each report is written for reporting upward.

**9. Open the app and try it.** `shiny::runApp("SurvAI_Expert")`, paste the key on Start here,
ask a question, ask for advice with "My survey" filled in, look up a formula, and upload one
real technical report to the Report reader.

**10. Deploy.**

```r
rsconnect::deployApp("SurvAI_Expert", appName = "SurvAI_Expert")
```

`.rscignore` leaves out `build/`, `tests/` and `data/build/`. The store, `data/markdown/` and
`data/catalog/` go with the app.

**11. Delete this section** and commit.

## Keeping it up to date

There is one thing to maintain: the text files under `data/markdown/` and `data/catalog/`. The
store is always rebuilt from them with `build/03_store.R`. New material is converted and
catalogued at home (`build/01_convert.R`, `build/02_catalog.R`), committed as text, and pulled
at work, where step 3 is run again. What the model is told lives in `www/reflexes/` and what the
pages say in `www/start_here.md` and `www/methodology.md`; all are plain text.

## The scripts

| Script | What it does |
| --- | --- |
| `build/01_convert.R` | Converted the course files to markdown (home only; uses a model). |
| `build/02_catalog.R` | Split the markdown into passages, formulas and code, and labelled them (home only; uses a model). |
| `build/03_store.R` | Builds the DuckDB store from `data/markdown/` and `data/catalog/`; no model, no network. Repairs R code by rule (console prompts, printed output, LaTeX escapes, blocks cut by a page break); only code that parses is searched or shown. |
| `app.R` | Settings, layout and server. |
| `R/retrieve.R` | Keyword search (BM25 in SQL), formulas, code, R examples for a formula, source cards. |
| `R/llm.R` | Plan, gather, answer, and the app's streaming versions of the calls. |
| `R/render.R` | Checks an answer, renumbers or hides its sources, and renders markdown, maths (KaTeX, as MathML) and code. |
| `R/report.R` | The report reader: text from PDF or Word, split when long. |
| `R/ui.R` | The five tabs, the source window, the session key and call count. |
| `tests/smoke.R` | Loads the app and runs each tab's server with the model stubbed, under both `SHOW_SOURCES` settings. |
| `tests/eval.R` | Part 1: retrieval test (no model). `tests/eval.R answers`: part 2, the answer test with a judge. `tests/eval.R advice`: part 3, 12 situations from `tests/advice.csv` graded against the points a methodologist should raise. |

## Tests

Run from inside `SurvAI_Expert/`, after the store is built.

| Command | Calls | Reads | Writes (not in git) |
| --- | --- | --- | --- |
| `Rscript --no-init-file tests/smoke.R` | none, no key | the store, `www/` | nothing |
| `Rscript --no-init-file tests/eval.R` | none | `tests/gold.csv`, the store | `tests/eval_retrieval.csv` |
| `Rscript --no-init-file tests/eval.R answers` | about 180; key from the variable named by `KEY_ENV` | `tests/gold.csv`, the store | `tests/eval_report.md`, `tests/eval_answers.csv` |

`tests/gold.csv` holds the 108 gold questions. `tests/eval_report_home.md` is the home run, kept
in git as the baseline; each run of the eval prints its name at the end so the two can be
compared. The three output files are rewritten by every run and are ignored by git.
