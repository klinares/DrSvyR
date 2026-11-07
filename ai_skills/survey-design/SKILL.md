---
name: survey-design
description: Design-based analysis of complex survey data in R -- weights, strata, PSUs, finite population corrections and replicate weights with survey and srvyr, read through the Total Survey Error and Total Error Framework lenses. Use whenever estimates, standard errors, tests or models are computed from survey data.
when_to_use: Setting up a survey design object; any weighted estimate, proportion, total, ratio, quantile, domain estimate, regression or test on survey data; reviewing survey code; questions about design effects, lonely PSUs, replicate weights, weighting or survey error.
---

# Survey design and design-based estimation

The sample design is part of the estimator. Every estimate uses the weights;
every standard error uses the strata, the clusters (PSUs) and, where given,
the finite population correction or the replicate weights. Ignoring weights
biases point estimates; ignoring clustering and stratification misstates
standard errors -- clustering usually makes them too small.

Templates and pitfalls: `references/design_objects.md`.
Error frameworks: `references/error_frameworks.md`.
Checks before building a design, usable from scripts or an app:
`scripts/design_check.R`.

## Workflow

1. **Find the design variables in the documentation**, not by guessing from
   column names: final weight, stratum, PSU (and later-stage units if the
   design needs them), FPC or population sizes, replicate weights and their
   method (JK1, JKn, BRR, Fay, bootstrap, SDR) with their scale factors.
2. **Check them** (`check_design_inputs()`): weights present, positive and
   not missing; strata and PSUs not missing; PSU codes nested within strata
   (if PSU codes repeat across strata, use `nest = TRUE`); strata with a
   single PSU; replicate-weight columns all present.
3. **Build one design object** and use it for everything:
   - Taylor linearisation: `survey::svydesign(ids = ~psu, strata = ~stratum,
     weights = ~wt, fpc = ~fpc, nest = TRUE, data = d)` or
     `srvyr::as_survey_design(ids = psu, strata = stratum, weights = wt, ...)`.
   - Replicate weights supplied by the data producer:
     `survey::svrepdesign(weights = ~wt, repweights = "repwt[0-9]+", type = "JKn",
     scale = , rscales = , mse = TRUE, data = d)` -- take `type`, `scale`,
     `rscales` from the documentation; they differ between surveys.
4. **Estimate from the design**: `svymean()`, `svytotal()`, `svyratio()`,
   `svyquantile()`, `svyciprop()` for proportions near 0 or 1, `svyby()` for
   groups, `svyglm()` for regression, `svychisq()` for tables; or srvyr's
   `survey_mean()`, `survey_prop()`, `survey_total()`, `survey_quantile()`.
   Always report the standard error or a 95% interval with the estimate.
5. **Report**: the estimate, its interval, the unweighted n, the variance
   method, and the design degrees of freedom when they are small.

## Rules

- **Domains (subgroups): subset the design, not the data.**
  `subset(des, region == "North")`, `svyby(~y, ~region, des, svymean)`, or
  srvyr `filter()` on the design. Filtering the data first drops PSUs and
  strata from the variance calculation and gives wrong standard errors.
- **Design effects** are ratios of *variances* (design variance over the
  variance under simple random sampling of the same size); the ratio of
  standard errors is the square root. Get them with
  `svymean(~y, des, deff = TRUE)` then `deff()`. Effective sample size is
  n / deff. Kish's approximation deff ~ 1 + (b - 1) roh needs the intraclass
  correlation roh and the cluster size b; projecting to a new design needs
  roh, not the old deff. The weighting effect alone is about 1 + CV^2 of the
  weights.
- **Element variance vs sampling variance**: S^2 or P(1 - P) describes spread
  among units and does not depend on the design; the sampling variance of an
  estimator does. Do not call S^2/n an element variance.
- **A stratum with one PSU** cannot contribute a variance estimate.
  `options(survey.lonely.psu = "adjust")` (or "average", "certainty") changes
  how linearisation treats it; collapsing strata is a design decision to
  state, not a silent repair.
- **Degrees of freedom**: for designs with few PSUs, base intervals on t with
  the design df: `confint(est, df = degf(des))`.
- **Tests and models**: use the design-based versions (`svyttest()`,
  `svychisq()` with the Rao-Scott correction, `svyglm()`; `regTermTest()` for
  joint tests). Don't use `lm()`/`glm()` with `weights =` -- that treats
  weights as precision weights and gets the standard errors wrong.
- **Weights are not frequency counts.** Unweighted counts describe the
  sample; weighted estimates describe the population. Say which one a number
  is.
- **Response rates bound the risk of nonresponse bias; they do not measure
  it.** Bias depends on how response propensity covaries with the survey
  variable.
- **Never choose for the analyst**: which weight, which reference level, how
  to collapse strata, how to treat "don't know" are their decisions. Lay out
  the evidence and the trade-off.

## Total Survey Error and the Total Error Framework

Place a design or quality question in an error framework and say what it
trades against what (details in `references/error_frameworks.md`):

- **Representation**: coverage error (frame vs target population), sampling
  error, nonresponse error, adjustment error (weighting).
- **Measurement**: validity (construct vs question), measurement error
  (respondent, interviewer, mode, questionnaire), processing error (coding,
  editing, imputation).
- For non-probability or administrative ("found") data, the **Total Error
  Framework** adds errors in how records are generated, selected and
  linked; design-based variance alone does not describe them.

Intervals from a design capture **sampling error only**. Say so when the
other errors could matter more.

## For apps and scripts

`scripts/design_check.R` holds plain functions (`check_design_inputs()`,
`build_design()`, `design_summary()`) that take a data frame and a design
specification and return tibbles, with no printing and no global state, so a
Shiny app or a pipeline can call them directly.
