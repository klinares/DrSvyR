# DrSvyR — brief for an assistant

Paste this whole file before asking for help with the code. It exists because
`README.md` says what the repository is and `help.md` is written for the
analyst using the app; neither says how the thing is built or which of its
choices are load-bearing. Most of the mistakes an assistant makes here are not
bad code — they are correct-looking changes that break an invariant nobody
wrote down.

---

## What it is

A Shiny app that fits **one model**: a latent class analysis on complex survey
data, weighted, with every standard error coming from the survey's own
replicate design. An analyst who does not write code drives it; a language
model drafts prose at four points and never touches a number.

It wraps a validated Quarto workflow that lives in a separate repository
(WISE). The reference reports there are what the app's numbers were checked
against. **The app and the reference share an engine by copy, not by import** —
`R/engine.R` here and `source_code.R` there. A fix in one does not reach the
other.

There used to be a second arm — a confirmatory factor model — and it has been
removed entirely, along with `lavaan`. If you find a reference to CFA, factors,
loadings or arms anywhere outside a comment explaining the removal, it is a
leftover and should go.

---

## The sequence

Eleven screens, in order. Each one refuses to work until the one before it has
produced something, which is what makes the order enforce itself without
explicit gating.

| # | Screen | Produces |
|---|---|---|
| 1 | Project | `work_dir`, `data_file`, `raw`, `codebook` |
| 2 | Design | `design_map`, `design_dat`, `design_checks` |
| 3 | Items | `item_frame`, `na_codes`, `context`, `question` |
| 4 | Domains | `demo_specs`, `demo_dat`, `recode_audit` |
| 5 | Review | `cfg` — written to `output/cfg.R` and frozen |
| 6 | Search | `search` (a fit at every K), `search_key` |
| 7 | Model | `model` (fit + diagnostics), `measure` (intervals) |
| 8 | Names | `labels` — drafted by the model, edited by the analyst |
| 9 | Scoring | `scored`, `score_design`, `coverage`, `shares` |
| 10 | Results | `domains`, `domain_reads` |
| 11 | Outputs | the report, the CSVs, the scored `.sav` |

One `state` object, a `reactiveValues`, is passed to every module. Modules read
and write it; they never call each other. `state$goto` is the exception: a
module that has invalidated everything downstream sets it and an observer moves
the analyst there.

---

## The files

`app.R` and `setup.R` live at the root and *do* things. Everything in `R/` only
defines functions and is sourced flat and alphabetically, so load order does
not matter — **that rule is what makes the flat source safe, and it holds only
as long as no two files define the same name.**

| File | Lines | What is in it |
|---|---|---|
| `R/core.R` | 749 | Paths, the work folder, the worker count, caching, the decision log, error capture, every line of help text |
| `R/data.R` | 738 | Reading the file, the design frame, nonresponse codes, the item frame, the recodes |
| `R/engine.R` | 669 | The estimation engine. Weighted EM, label alignment, the replicate design, BCH, scoring, prompts. **Never edited per dataset** |
| `R/model.R` | 804 | Configuration, the size search, the fitted model, intervals on it, the names |
| `R/results.R` | 1228 | Scoring, domain estimation, the delivered file, the report |
| `R/plots.R` | 104 | One theme, applied everywhere |
| `R/llm.R` | 296 | Every model call. **Endpoint-specific — see below** |
| `R/ui_*.R` | 2888 | The four screen groups |

---

## Things that will bite you

### The engine is shared by copy

`R/engine.R` was derived from `source_code.R` in the WISE repository. If you
change `em_run`, `bch_weights`, `replicate_variance` or `build_rep_design`,
say so — the other copy needs the same change or the app stops matching the
reference reports it was validated against.

`em_run()` carries an "AI Assistance w/ this section, careful to not modify"
marker. Leave it alone unless asked directly.

### Two LLM files, one of which must not be in `R/`

`R/llm.R` reaches OpenRouter. `llm-openai.R`, at the repository root, reaches
an OpenAI-compatible endpoint. They define the same function names, so if both
were in `R/` the alphabet would silently decide which endpoint the app talks
to. `app.R` counts files matching `^llm` in `R/` and stops if there is more
than one.

**`llm-openai.R` is generated.** Edit `R/llm.R` and run
`source("make_llm_openai.R")`. Editing the generated file by hand is how the
two drifted apart last time, and the drift was in `model_key()` — which decides
whether a cached fit belongs to the data in front of it.

### Nothing in `R/` may run

Every file in `R/` defines functions and never calls them. `app.R` sources the
folder flat and alphabetically, so that rule is what makes load order
irrelevant — and it is also the difference between a working app and one that
will not start at all.

`check_globals.R` sources `R/` itself. A copy of it left in `R/` is therefore
sourced by the loop in `app.R`, sources `R/` again, and takes the app down at
startup with *"evaluation nested too deeply: infinite recursion"* — a message
that names no file and points at no line. `app.R` now parses every file in `R/`
before sourcing it and refuses anything with a top-level statement, naming the
file and the statements. `check_globals.R` refuses the same thing rather than
recursing into it.

`app.R`, `setup.R`, `check_globals.R` and `make_llm_openai.R` all *do* things
and belong at the repository root.

### Determinism is a promise, and three things keep it

1. **Seeds are passed as data, never drawn inside a worker.** `start_seeds()`
   makes them from `cfg$seed` and `K`.
2. **The two-stage start set picks survivors globally, not per block.** The
   best twenty of two hundred is one answer; the best twenty of each of four
   blocks of fifty is a different one, and the machine's core count must not
   decide which model the analyst is shown.
3. **`in_blocks()`, not `split(x, cut(...))`.** `cut(x, 1)` errors, which broke
   `DRSVYR_WORKERS=1` entirely, and cutting three items into four intervals
   leaves an empty block.

If you touch the search, re-check that the result is identical at 1, 2, 4 and 7
workers — parameters, not just log-likelihood.

### The search already fitted the model

`search_sizes()` fits every K in `K_range` from the full start set and keeps
them all. The Model screen **takes** `state$search$fits[[K]]`; it does not
refit. Those two calls were byte-identical and one of them was waste.

What the refit was quietly providing was protection against a stale search —
the battery can be rebuilt on the Items screen without `state$search` being
cleared. That is now a key comparison: `model_key(cfg, items, 0L, dat)` is
recorded when the search runs and checked when the model is taken. If the
search is stale the app stops, because the criteria the analyst chose K from
are stale too.

`fit_final()` still exists and the app does not call it. It is the entry point
for a script working from the written `cfg.R`.

### `model_key()` decides whether a cached fit is the right one

It hashes the specification **and the data**. Without the data, two waves of
the same survey with the same variable names produce the same key, the cache
returns the first wave's model, and the report describes the wrong fit with no
symptom at all. Do not remove a field from it without thinking hard.

### Process-global state on a shared server

The app runs on Posit Connect, where **one R process serves several analysts**.
Anything stored outside a session is shared between them.

- The work folder is keyed on the Shiny session token (`core.R`, `.wise$sessions`).
- API keys are held in a session-scoped registry in `llm.R`. **Nothing calls
  `Sys.setenv()`.** A key written into the process outlives the session that
  set it and is readable by every other one.
- `future::plan()` *is* process-global and cannot be otherwise. Every session
  resolves the same worker count from the same place, so they all want the same
  plan and `init_parallel()` becomes a no-op after the first call.

### The design gate is at Review, not at Design

`design_checks()` marks a specification `stop` when it cannot produce honest
standard errors — a missing weight, a non-positive weight, a singleton stratum.
The Design screen prints that, and for a long time printing was all that
happened: `assert_design_ok()` existed and nothing called it. A singleton
stratum still stopped later, inside `build_rep_design()`; a zero weight stopped
nowhere and was carried into every estimate downstream.

It is now called when the analyst approves the configuration, which is the
choke point every later screen depends on. If you add a new `stop` row to
`design_checks()`, that is where it takes effect.

### The work folder is refused inside the repository

`assert_outside_repo()` was made a no-op at one point and the refusal survived
only as a message on the Project screen — so the comment there claiming core.R
was the enforcement was false. It is real again, called from `wise_path()`
(every write is built there) and from `scaffold_work_folder()` (so the refusal
lands when the folder is adopted rather than several screens later). The
survey file is unaffected: it is only ever read and may live anywhere,
including `demo/`.

### Errors must name where they came from

`try(expr, silent = TRUE)` keeps the message and throws the call stack away.
Every step an analyst can press a button for goes through `wise_try(expr,
"label")`, which captures the stack while it is still standing, names the
deepest frame that is one of the app's own functions, and appends the whole
thing to `errors.log` in the work folder. Do not replace it with `try()`.

`check_dims(n, expected, what, detail)` is for the points where a matrix built
from respondents meets one built from estimates. "Non-conformable arguments" is
a true statement that helps nobody.

### Deleting things

A deleted top-level constant is invisible to `parse()`, invisible to a
call-graph walk over functions, and shows up only when the one line that reads
it happens to run. `BOUNDARY_TOL` was lost that way and surfaced as *"object
'BOUNDARY_TOL' not found"* three screens later.

Run `source("check_globals.R")` from the repository root after any deletion. It
lists every name the code uses that nothing in `R/` defines, and refuses to run
if a script has been left in `R/`.

### Style

- **No `for` loops.** `purrr::map()` and friends, always.
- Tidyverse conventions throughout; `=` for assignment inside functions and
  `<-` at top level, matching what is already there.
- Comments explain *why*, in prose, above the thing they describe. There are a
  lot of them and they are load-bearing — several record a bug that was fixed
  and would otherwise be reintroduced.
- Line endings are **CRLF**. A file returned with LF shows every line as
  changed.
- `kableExtra`, `flextable`, `officer` and `lavaan` are deliberately absent:
  the first three need Rtools, which analysts cannot install, and the fourth
  went with the factor arm.

---

## Methodology, briefly

- **Design-based throughout.** One stratified jackknife (`JKn`) replicate set
  drives the measurement model, the domain estimates and the corrections. A
  stratum with one PSU is a hard stop — it cannot take the `n_h/(n_h-1)`
  scaling, and `survey.lonely.psu` governs linearisation, not replicate
  construction.
- **Weighted EM** under a design-weighted pseudo-likelihood. A missing answer
  contributes zero on the log scale and drops out of the product, so partial
  responders are scored rather than dropped.
- **BCH three-step correction** for the domain estimates. `D` holds the
  design-weighted classification error rates and is rebuilt inside every
  replicate; the posteriors and the modal assignment are held at their
  full-sample values. That is standard practice and it makes the intervals
  optimistic — the report says so.
- **Logit-scale intervals** on every probability, so they stay inside `(0,1)`
  without truncation. Estimates within `BOUNDARY_TOL` of a boundary get a Wald
  interval instead and come back flagged.
- **Measurement invariance is assumed, not tested.** A real group difference
  and a difference in how a question is understood are indistinguishable in
  these tables. The report's status table says so.
- **Diagnostics rank, they do not test.** Bivariate residuals, discrimination
  and the level-against-pattern ratio have no reference distribution under a
  pseudo-likelihood. Never write a threshold into any of them.

---

## What the language model is and is not allowed to do

It drafts names for the segments, reads the diagnostics, reads the domain
tables, and writes the report summary. In every case **R computes the
conclusion and the model translates it.** The domain prompt is handed the list
of pairs that separated, worked out by a design-based Wald test on the
replicate covariance, Holm-adjusted; it never sees a standard error and never
decides significance.

The survey data never reaches it. Item wording, response labels and fitted
parameters do; a respondent record does not.

---

## Asking for help well

Include: the exact error text, the relevant block from `errors.log` (it names
the function), and which screen you were on. The log is in the work folder.

Say which of these you want:
- **a diagnosis** — do not change anything until it is agreed
- **a minimal fix** — the smallest change that addresses it
- **a whole-file replacement** — say so, and expect the whole file back with
  CRLF preserved

Ask for the reasoning to be checked against `SURV*_reference.qmd` if the change
touches the methodology.
