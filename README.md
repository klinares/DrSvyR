# DrSvyR

**A survey methodologist you can consult, working on data you already have.**

Finding groups or a scale inside a battery of survey questions, with standard
errors that respect how the sample was actually drawn — and a record of who
decided what.

You do not need to write any R. You do need to know your survey.

---

## What Dr. Svy is, and is not

The tool has an AI methodologist in it. It is worth being exact about what that
means, because the obvious reading — an AI that does the analysis — is wrong.

![Protocol, reflexes, and the analyst](figures/fig_protocol.png)

**Protocol** is what the workflow does regardless of anyone's opinion. A stratum
with one sampling unit halts the analysis. The classification table is rebuilt
inside every replicate. The log-likelihood is rescaled before BIC is computed. A
ranking is never reported as a test. No respondent record ever reaches the
model. The analyst enters their chosen number *before* the model offers a view.
None of these are instructions a model follows — they are conditions of the code
running at all, and you can read them in the source.

**Reflexes** are what Dr. Svy notices and says. It sees an entropy of 0.71 and
says what that means for your decision; it sees a design effect of two and
flags it. Trained, immediate, occasionally wrong — and attached to no authority
whatsoever. A reflex is a reaction, not a decision. Nobody was ever compelled by
someone else's reflex.

**The analyst signs.** Which items form a battery, how many groups, whether a
name fits the profile, which category is the reference, whether an item comes
out. Every one of those is recorded with the evidence that was on screen at the
time, in a decision log that ships with the results.

Dr. Svy diagnoses and recommends. It does not prescribe, and it cannot
overrule.

---

## What the analysis does

You have a battery of related questions and want to know how respondents differ
on it. There are two ways they can:

- **In which answers they favour.** Some agree with these items and reject
  those; others do the reverse. The result is a **segment** for each respondent.
- **In how much.** Everyone sits somewhere on one scale, low to high. The result
  is a **score** for each respondent.

Which fits is a property of your data. The tool shows the evidence; you decide.

**Why not just use standard software:** every standard error here comes from the
survey design — the stratification, the clustering, the weights — carried from
the measurement model through to the group estimates without interruption.
Defaults elsewhere assume a simple random sample and report intervals around
half the size they should be. Differences that look decisive under those
defaults often are not.

---

## The workflow

![The eleven stages](figures/fig_stages.png)

Amber steps are the ones you decide. Nothing runs until you press a button.

**The gate that matters most is step 6.** You see the evidence — the criteria,
and a picture of what the groups actually look like at each candidate size —
and you enter a number. Nothing is pre-filled and nothing is suggested, because
whatever appeared in that box first would become the answer. Only after your
choice is recorded does Dr. Svy say what it makes of the evidence. If that
changes your mind, enter a different number; both are in the log.

---

## What you need

- A survey file, **SPSS (.sav)** or **Stata (.dta)**.
- The technical report for that survey, as a **PDF**, if you have one.
- Design variables in the file: a **weight**, a **stratum**, a **primary
  sampling unit**, and a **respondent id**. This is for stratified clustered
  designs; weights alone are not enough.
- A few hundred completed interviews or more.

---

## Setup, once

1. **Clone this repository** and open `DrSvyR.Rproj` in RStudio.
2. **Install the packages**: `renv::restore()`.
3. **Add your API key.** `usethis::edit_r_environ()`, add one line —
   `OPENROUTER_API_KEY=your-key-here` — save, restart R. That is the only thing
   that goes in there.
4. **Create a work folder** outside the repository and copy your survey file
   into it. The app will refuse a folder inside the repository.

Then click **Run App**.

### Trying it first

`demo/` holds the 2023 AmericasBarometer file for Ecuador and its technical
report. Point the app at `demo/` as your work folder and you can walk the whole
workflow before bringing your own data. Results go to `demo/results/`.

---

## What you get

In your work folder, under `output/`:

- **A report** — the findings, the groups and what they mean, the distribution
  across your domains, and the caveats attached to the numbers they belong to.
  Reviewed on screen before anything is written.
- **Your survey file back**, with segment membership or factor scores added,
  plus the columns needed to use them correctly.
- **Every table as a CSV**, ready to paste.
- **A decision log** — each choice you made and the evidence you had when you
  made it.

---

## The protocol, in full

The list a methodologist should audit. Each of these is enforced in code, and
none of them can be turned off from the interface.

| | |
|---|---|
| A stratum with one sampling unit halts the design | It cannot take the replicate scaling, and continuing would contribute zero variance from the strata carrying least information |
| Missing or non-positive weights halt the run | Different estimators silently disagree about who is in the sample |
| The classification table is rebuilt inside every replicate | Holding it fixed treats classification error as known |
| The log-likelihood is rescaled before BIC | Without it the criterion leans toward too many groups |
| Rankings are never reported as tests | Bivariate residuals and modification indices order things; no reference distribution applies |
| No respondent record reaches the model | It sees variable names, question wording, response labels and aggregates |
| The dimension is entered before any interpretation is offered | Presentation order is what makes the choice the analyst's |
| Names are keyed to the specification that produced them | Change the battery and the saved names refuse to load rather than reattach to different groups |
| Item removal is capped at one round, and the count is printed in the report | Fit statistics after a specification search are optimistic, and a reader cannot discount what they are not told |
| Failed replicates are counted and disclosed | Dropping them understates variance rather than merely widening it |

---

## Limitations

- **The analysis assumes each question works the same way in every group being
  compared, and does not test it.** If an item means something different to
  younger and older respondents, or in one region than another, a difference
  between those groups may reflect the question rather than the thing being
  measured. Testing this is measurement invariance analysis — scalar invariance
  for the factor arm, homogeneity of item-response probabilities for the class
  arm — and it is not implemented here. Where there is reason to suspect it,
  consult a survey methodologist trained in psychometrics before treating a
  domain difference as substantive.
- Requires a stratified clustered design.
- The factor arm treats items as ordered categories by default, which scores
  only complete responders. Treating them as continuous reaches more people at
  the cost of an approximation; the app offers that choice when the response
  scales justify it.
- Fit statistics reported after removing an item are optimistic. The number of
  rounds appears in the report.
- Drafted names are drafts. No claim is made about their validity.

---

## Method

The full specification — every formula, every diagnostic, what was verified
against what, and what remains untested — is in
`methodology_v1.0.pdf`, written for both a manager and a survey statistician
and shipped with every set of results.

Worked examples on public data, running the same engine end to end, are in the
[weighted_inference_survey_estimation](https://github.com/klinares/weighted_inference_survey_estimation)
repository.

## Data acknowledgment

The demonstration uses the 2023 AmericasBarometer for Ecuador by the LAPOP Lab
at Vanderbilt University.
