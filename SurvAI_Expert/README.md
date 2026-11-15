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
| Ask | A question (up to four parts), with optional details of the person's data ("My data"). | 2 per question |
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
| `www/reflexes/` | What the model is told: `plan.md` (the search plan), `answer.md` (how answers are written), `report.md` (the report reader). |

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

## At work

1. Pull the repository (the branch with SurvAI_Expert).
2. Copy in the textbook, which is kept out of the repository: `data/markdown/practools/` and
   `data/catalog/practools/`, from the home copy. If they are absent, carry on: the app works
   without the textbook, it just cannot cite it (go to step 3).
3. Build the store, from inside `SurvAI_Expert/`: `Rscript --no-init-file build/03_store.R`. It
   builds from whatever sources are present and prints "Missing on disk, skipped: n documents"
   for any that are not. It then checks the receipt, one row per table and source: "identical"
   means the store matches the one built at home. Without the textbook, its rows show as missing
   and the rest should still match.
4. Fill the `work` profile in `app.R` (api, base_url, id), set `CALLS_PER_WINDOW <- 300`, and, if
   sources are to be shown, set `APP_SOURCE_URL` to the internal copy of the repository, branch
   included (for example `https://<host>/<repo>/blob/main/SurvAI_Expert/`). Set
   `SURVAI_PROFILE=work`.
5. Check it (see "Tests" below): `Rscript --no-init-file tests/smoke.R`, then
   `Rscript --no-init-file tests/eval.R` and `Rscript --no-init-file tests/eval.R answers`, and
   compare `tests/eval_report.md` with the home run, `tests/eval_report_home.md`. Without the
   textbook, questions written from it score lower.
6. Deploy: `rsconnect::deployApp("SurvAI_Expert", appName = "SurvAI_Expert")`. `build/`, `tests/`
   and `data/build/` are left out by `.rscignore`; `data/markdown/`, `data/catalog/` and
   `data/store/` go with the app.

## The scripts

| Script | What it does |
| --- | --- |
| `build/01_convert.R` | Converted the course files to markdown (home only; uses a model). |
| `build/02_catalog.R` | Split the markdown into passages, formulas and code, and labelled them (home only; uses a model). |
| `build/03_store.R` | Builds the DuckDB store from `data/markdown/` and `data/catalog/`; no model, no network. |
| `app.R` | Settings, layout and server. |
| `R/retrieve.R` | Keyword search (BM25 in SQL), formulas, code, R examples for a formula, source cards. |
| `R/llm.R` | Plan, gather, answer, and the app's streaming versions of the calls. |
| `R/render.R` | Checks an answer, renumbers or hides its sources, and renders markdown, maths (KaTeX, as MathML) and code. |
| `R/report.R` | The report reader: text from PDF or Word, split when long. |
| `R/ui.R` | The five tabs, the source window, the session key and call count. |
| `tests/smoke.R` | Loads the app and runs each tab's server with the model stubbed, under both `SHOW_SOURCES` settings. |
| `tests/eval.R` | Part 1: retrieval test (no model). `tests/eval.R answers`: part 2, the answer test with a judge. |

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
