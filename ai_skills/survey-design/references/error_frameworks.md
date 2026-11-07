# Error frameworks

## Total Survey Error (TSE)

TSE treats the quality of an estimate as the sum of errors from every step
between the population and the published number. Groves et al. (2009) draw
it as two strands meeting at the estimate:

**Representation** -- who is in the data

| Error | Arises when | Typical evidence |
|---|---|---|
| Coverage | the frame misses or duplicates parts of the target population | frame vs external counts; undercoverage of e.g. cell-only or unhoused people |
| Sampling | only a sample is observed | design-based standard errors, design effects |
| Nonresponse (unit, item) | sampled units or answers are missing and differ from respondents | response rates (risk only), R-indicators, frame-variable comparisons, follow-up studies |
| Adjustment | weights or imputation do not remove the bias they target | sensitivity to weighting choices; weighting effect 1 + CV^2 |

**Measurement** -- what is recorded

| Error | Arises when | Typical evidence |
|---|---|---|
| Validity | the question does not capture the construct | cognitive testing, construct validation |
| Measurement | answers depart from true values (respondent, interviewer, mode, wording, order) | interviewer variance, mode experiments, reinterviews |
| Processing | coding, editing, imputation or linkage change values | coder reliability, edit-rate audits |

Each error has a bias and a variance component; mean squared error combines
them. Design decisions trade them: a cheaper mode may cut sampling error
(bigger n) while adding measurement and coverage error.

## Total Error Framework (TEF) for found and non-probability data

Administrative records, digital traces and opt-in panels are not drawn by a
known random process, so sampling theory does not describe them. Total error
frameworks for such data (e.g. Amaya, Biemer & Kinyon 2020; Japec et al.
2015; Biemer 2016) keep the TSE logic and add the steps where these data go
wrong:

- **Generation**: who produces records and why (platform users, programme
  participants), and what is never recorded.
- **Selection / extraction**: which records are pulled, filtered or
  de-duplicated.
- **Linkage**: false matches and missed matches when sources are joined.
- **Coding and transformation**: classification, text processing, model-based
  derived variables.
- **Analysis**: model and adjustment choices (quasi-randomisation weights,
  superpopulation models), with their own assumptions.

Design-based variance estimates do not apply to these data in the usual way.
Report what adjustment model was used, what it assumes, and how sensitive the
estimate is to it.

## Using the frameworks in practice

- Name the error source an issue belongs to before proposing a fix.
- Say what the fix trades: e.g. raking to more margins can reduce
  nonresponse bias but increases the weighting effect (variance).
- Intervals from the design cover sampling error only; say so when coverage,
  nonresponse or measurement error could plausibly be larger.

## Sources

Groves, Fowler, Couper, Lepkowski, Singer & Tourangeau (2009), *Survey
Methodology*; Biemer & Lyberg (2003), *Introduction to Survey Quality*;
Biemer (2010), "Total survey error: design, implementation and evaluation";
Amaya, Biemer & Kinyon (2020), "Total error in a big data world: adapting the
TSE framework to big data"; JPSM SURV720/721 (Total Survey Error), SURV625,
SURV701.
