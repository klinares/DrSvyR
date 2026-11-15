# SurvAI Expert

A Shiny app that answers survey methodology questions from a store of course materials: JPSM
lecture notes, slides, assignments and exams, a sampling and weighting textbook, and R code.
Each answer cites the passages it used; formulas are shown as stored, never retyped by the model;
R code follows the course code. It also searches the stored formulas directly (no model), and
reads a survey's technical report into an analyst's checklist.

Each question makes two model calls: one plans the search, one writes the answer. The key is
pasted on the Start here page and held for the session only.

## Run at home

```r
shiny::runApp("SurvAI_Expert")
```

The store `data/store/survai.duckdb` must exist; build it once (below). From the console, without
the app: `setwd("SurvAI_Expert"); source("app.R"); ask("your question")`, with the key in
`ANTHROPIC_API_KEY`.

## At work

1. Pull the repository (branch with SurvAI_Expert).
2. Build the store, from inside `SurvAI_Expert/`: `Rscript --no-init-file build/03_store.R`.
   It prints the receipt check: "identical" means the store matches the one built at home
   (the textbook, kept out of the repository, will show as missing and its tables differ).
3. Fill the `work` profile in `app.R` (api, base_url, id), set `CALLS_PER_WINDOW <- 300`
   (counted over `CALLS_WINDOW_HOURS`, 4), and set `APP_SOURCE_URL` to the internal copy of the
   repository, branch included (for example `https://<host>/<repo>/blob/main/SurvAI_Expert/`).
   Set `SURVAI_PROFILE=work`.
4. Check it: `Rscript --no-init-file tests/smoke.R` (no key), then
   `Rscript --no-init-file tests/eval.R answers` (makes about 180 calls; reads the key from the
   variable named by `KEY_ENV` in `app.R`) and read `tests/eval_report.md`.
5. Deploy: `rsconnect::deployApp("SurvAI_Expert", appName = "SurvAI_Expert")`. `build/`, `tests/`
   and `data/build/` are left out by `.rscignore`; `data/markdown/` goes with the app.

## The scripts

| Script | What it does |
| --- | --- |
| `build/01_convert.R` | Converted the course files to markdown (home only; uses a model). |
| `build/02_catalog.R` | Split the markdown into passages, formulas and code, and labelled them (home only; uses a model). |
| `build/03_store.R` | Builds the DuckDB store from `data/markdown/` and `data/catalog/`; no model, no network. |
| `app.R` | Settings, layout and server. |
| `R/retrieve.R` | Keyword search (BM25 in SQL), formulas, code, source cards. |
| `R/llm.R` | Plan, gather, answer, and the app's streaming versions of the calls. |
| `R/render.R` | Checks an answer and renders markdown, maths (KaTeX, as MathML) and code. |
| `R/report.R` | The report reader: text from PDF or Word, split when long. |
| `R/ui.R` | The five tabs (Start here, Ask, Formulas, Report reader, Methodology), the source card and window, the session key and call count. Page text is in `www/start_here.md` and `www/methodology.md`. |
| `www/reflexes/` | What the model is told: `plan.md`, `answer.md`, `report.md`. Edit these, not the code. |
| `tests/smoke.R` | Loads the app and runs each tab's server with the model stubbed. |
| `tests/eval.R` | Part 1: retrieval test (no model). `tests/eval.R answers`: part 2, the answer test with a judge. |
