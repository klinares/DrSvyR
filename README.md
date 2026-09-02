# DrSvyR

#  ![](images/clipboard-2542862929.jpeg){width="280"}

**A survey methodologist you can consult, working on data you already have.**

Finding groups inside a battery of survey questions, with standard errors that respect how the sample was actually drawn — and a record of who decided what.

You do not need to write any R. You do need to know your survey.

------------------------------------------------------------------------

## What DrSvyR is, and is not

The tool has an AI methodologist in it. It is worth being exact about what that means, because the obvious reading — an AI that does the analysis — is wrong.

![Protocol, reflexes, and the analyst](figures/fig_protocol.png)

**Protocol** is what the workflow does regardless of anyone's opinion. A stratum with one sampling unit halts the analysis. The classification table is rebuilt inside every replicate. The log-likelihood is rescaled before BIC is computed. A ranking is never reported as a test. No respondent record ever reaches the model. The analyst enters their chosen number *before* the model offers a view. None of these are instructions a model follows — they are conditions of the code running at all, and you can read them in the source.

**Reflexes** are what DrSvyR notices and says. It sees an entropy of 0.71 and says what that means for your decision; it sees a design effect of two and flags it. Trained, immediate, occasionally wrong — and attached to no authority whatsoever. A reflex is a reaction, not a decision. Nobody was ever compelled by someone else's reflex.

**The analyst signs.** Which items form a battery, how many groups, whether a name fits the profile, which category is the reference, whether an item comes out. Every one of those is recorded with the evidence that was on screen at the time, in a decision log that ships with the results.

DrSvyR diagnoses and recommends. It does not prescribe, and it cannot overrule.

------------------------------------------------------------------------

## What the analysis does

You have a battery of related questions and want to know how respondents differ on it. This tool answers one version of that question: **do they fall into a small number of distinct types, each with its own way of answering the set?** Some agree with these items and reject those; others do the reverse. The result is a **segment** for each respondent.

That is a latent class model, and it is the only model this tool fits. There is no factor arm and no `lavaan` — an earlier version had both and they were removed. If a battery of yours is better described by one continuum than by a handful of types, this is the wrong tool for it and you will need a weighted confirmatory factor model somewhere else. That judgement is yours; the app no longer offers a diagnostic for it.

**Why not just use standard software:** every standard error here comes from the survey design — the stratification, the clustering, the weights — carried from the measurement model through to the group estimates without interruption. Defaults elsewhere assume a simple random sample and report intervals around half the size they should be. Differences that look decisive under those defaults often are not.

------------------------------------------------------------------------

## The workflow

![The eleven stages](figures/fig_stages.png)

Amber steps are the ones you decide. Nothing runs until you press a button.

**The gate that matters most is step 6.** You see the evidence — the criteria, and a picture of what the groups actually look like at each candidate size — and you enter a number. Nothing is pre-filled and nothing is suggested, because whatever appeared in that box first would become the answer. Only after your choice is recorded does DrSvyR say what it makes of the evidence. If that changes your mind, enter a different number; both are in the log.

**Search is where the time goes.** Every candidate size is fitted from two hundred starting points. All two hundred run a short burst; the best twenty are taken to convergence. That two-stage set gets the same maximum as running all two hundred to convergence for roughly a third of the EM iterations, and — this is the part that matters — the survivors are picked across the whole set, not within each parallel block, so the machine's core count cannot change which model you are shown.

**Model does not refit.** The size you chose was already fitted during the search, and that fit is what the Model screen takes. The two used to be byte-identical computations and one of them was waste. What the refit was quietly providing was protection against a stale search — you can rebuild the battery on Items without clearing the search — so that is now an explicit key comparison, and a stale search stops rather than being read from.

------------------------------------------------------------------------

## What you need

- A survey file, **SPSS (.sav)** or **Stata (.dta)**.
- The technical report for that survey, as a **PDF**, if you have one.
- Design variables in the file: a **weight**, a **stratum**, a **primary sampling unit**, and a **respondent id**. This is for stratified clustered designs; weights alone are not enough.
- A few hundred completed interviews or more.

------------------------------------------------------------------------

## Setup, once

1.  **Clone this repository** and open `DrSvyR.Rproj` in RStudio.
2.  **Install the packages**: `source("setup.R")`. It installs only what is missing, and the file records why each package is there and why several obvious ones are deliberately absent.
3.  **Add your API key.** `usethis::edit_r_environ()`, add one line — for the OpenRouter build, `OPENROUTER_API_KEY=your-key-here`; for the OpenAI-compatible build, `OPENAI_API_KEY=your-key-here` — save, restart R. **That is the only thing that belongs in there.** On a shared server you can instead paste a key on the Start here tab, where it lives for the length of your session, is never written to disk, and is never visible to another session.
4.  **Create a work folder outside the repository.** Outputs, the decision log and cached fits are written there, and the app refuses a folder inside the clone — scored respondent data one `git add .` from being committed is the failure this exists to prevent. Your survey file is only ever read, so it can stay wherever it already is, including in the repository's own `demo/` folder.

Then click **Run App**.

### Which LLM file

Two exist and they define the same function names:

| File           | Endpoint                       | Where it lives               |
|------------------------|------------------------|------------------------|
| `R/llm.R`      | OpenRouter                     | in `R/`, sourced             |
| `llm-openai.R` | any OpenAI-compatible endpoint | repository root, not sourced |

Exactly one belongs in `R/` at a time — with both there the alphabet would decide which endpoint the app talks to and nothing would say so, and `app.R` stops at startup if it finds more than one. To switch, swap the files.

**`llm-openai.R` is generated.** Edit `R/llm.R`, then `source("make_llm_openai.R")`. Editing it by hand is how the two last drifted apart, and the drift was in the function that decides whether a cached fit belongs to the data in front of it.

### Cores

The search runs in parallel. By default it takes one fewer than the cores the machine reports, capped at twelve — so a Windows desktop and a Linux server each use what they have without either being told a number about the other. To override, put `DRSVYR_WORKERS=6` in `.Renviron`, or set `options(drsvyr.workers = 6)`. On a shared server, leave it alone.

The worker count changes how long the search takes and **not** what it produces. If you change anything in the search, re-check that: identical parameters, not just an identical log-likelihood, at one, two, four and seven workers.

------------------------------------------------------------------------

## What you get

In your work folder:

- `output/report.html` — the findings, the groups and what they mean, the distribution across your domains, and the caveats attached to the numbers they belong to. Self-contained, every figure embedded, opens in Word if a document is what somebody wants. Reviewed on screen before anything is written. A `.docx` is written as well **if** `officer` and `flextable` happen to be installed; neither is required and neither is in `setup.R`.
- `output/<yourfile>_wise.sav` (or `.dta`) — your survey file back, with segment membership added, plus the posterior columns needed to use it correctly.
- `output/*.csv` — every table, ready to paste.
- `output/cfg.R` — the analysis specification, re-runnable without this app.
- `decisions/` — each choice you made and the evidence you had when you made it.
- `errors.log` — every failed step, with the function it failed in and the stack below it. This is the file to send when something goes wrong.
- `cache/` — fitted models keyed to the specification and the data. Safe to delete.

------------------------------------------------------------------------

## The protocol, in full

The list a methodologist should audit. Each of these is enforced in code, and none of them can be turned off from the interface.

|  |  |
|------------------------------------|------------------------------------|
| A stratum with one sampling unit halts the design | It cannot take the replicate scaling, and continuing would contribute zero variance from the strata carrying least information |
| Missing or non-positive weights halt at Review | Different estimators silently disagree about who is in the sample. The Design screen prints the stop; approving a configuration is where it is refused |
| The classification table is rebuilt inside every replicate | Holding it fixed treats classification error as known |
| The log-likelihood is rescaled before BIC | Without it the criterion leans toward too many groups |
| Rankings are never reported as tests | Bivariate residuals order item pairs; no reference distribution applies |
| No respondent record reaches the model | It sees variable names, question wording, response labels and aggregates |
| The dimension is entered before any interpretation is offered | Presentation order is what makes the choice the analyst's |
| Names are keyed to the specification that produced them | Change the battery and the saved names refuse to load rather than reattach to different groups |
| Item removal is capped at one round, and the count is printed in the report | Fit statistics after a specification search are optimistic, and a reader cannot discount what they are not told |
| Failed replicates are counted and disclosed | Dropping them understates variance rather than merely widening it |
| The work folder cannot be inside the repository | `wise_path()` builds every write and refuses one under the repository root, so scored respondent data cannot end up somewhere a `git add .` reaches |
| The model shown is the model the search fitted, or the run stops | A refit that silently disagreed with the criteria the size was chosen from would be undetectable |
| `svyby` output is read by position, and the column count is checked first | Its naming for a factor outcome varies by version, so reading by name is the fragile option here; `check_dims()` refuses a table that is not one estimate and one standard error per segment |

------------------------------------------------------------------------

## Checking it without running it

`source("check_globals.R")` from the repository root, after any deletion.

It sources `R/`, walks every function, and lists every name the code uses that nothing in `R/` defines and no attached package exports. A deleted top-level constant is invisible to `parse()`, invisible to a call-graph walk, and shows up only when the one line that reads it happens to run — which is how `BOUNDARY_TOL` went missing and surfaced three screens later as *"object 'BOUNDARY_TOL' not found"*.

It also refuses to run if a script has been left in `R/`. Everything in `R/` defines and never runs; `app.R`, `setup.R`, `check_globals.R` and `make_llm_openai.R` all *do* things and belong at the root. A script in `R/` is sourced at every startup, and one that sources `R/` itself takes the app down with *"evaluation nested too deeply: infinite recursion"* — a message that names nothing. `app.R` checks for this too, and names the file.

------------------------------------------------------------------------

## Limitations

- **The analysis assumes each question works the same way in every group being compared, and does not test it.** If an item means something different to younger and older respondents, or in one region than another, a difference between those groups may reflect the question rather than the thing being measured. Testing this is measurement invariance analysis — homogeneity of item-response probabilities across groups — and it is not implemented here. Where there is reason to suspect it, consult a survey methodologist trained in psychometrics before treating a domain difference as substantive.
- Requires a stratified clustered design.
- **Domain intervals hold the measurement model fixed.** The classification table is recomputed in every replicate; the posteriors and the assignment are not. This is standard three-step practice and it makes the intervals optimistic. On the reference implementation, propagating that uncertainty multiplied the corrected standard errors on one demographic by a median of 2.17.
- **The classification table is inverted without a conditioning check.** An exactly singular table stops the run, because `solve()` refuses it. A near-singular one — a segment that took very few assignments — does not, and the correction it produces will be unstable rather than wrong-looking.
- Variance is within-mode: it expresses design variance around the reported solution, not uncertainty about which mode the likelihood should have found.
- Fit statistics reported after removing an item are optimistic. The number of rounds appears in the report.
- Drafted names are drafts. No claim is made about their validity.

------------------------------------------------------------------------

## Method

The reference implementation is the Quarto workflow in the [weighted_inference_survey_estimation](https://github.com/klinares/weighted_inference_survey_estimation) repository — `source_code.R` and `survey_lca_report.qmd`. That is what this app's numbers were validated against, and the two share an engine **by copy, not by import**: a change to `em_run()`, `bch_weights()`, `replicate_variance()` or `build_rep_design()` in one of them does not reach the other.

`PROJECT.md` in this repository is the brief to hand an assistant before asking it to change anything here. It records the invariants that are load-bearing and undocumented everywhere else.

## Data acknowledgment

The demonstration uses the 2023 AmericasBarometer for Ecuador by the LAPOP Lab at Vanderbilt University.
