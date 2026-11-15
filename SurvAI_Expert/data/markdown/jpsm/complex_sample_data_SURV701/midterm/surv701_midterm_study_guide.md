---
id: "jpsm/complex_sample_data_SURV701/midterm/surv701_midterm_study_guide"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "SURV/SURVMETH 701 Midterm Study Guide"
original: "complex_sample_data_SURV701/midterm/surv701_midterm_study_guide.qmd"
pages: 
sha256: "953acc5db6522dd7d616d428a6bc6f36082a9392e636b26f9aba26c543587759"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:51"
---


```r
#| label: setup
#| eval: false
library(tidyverse)
library(survey)
library(knitr)
library(kableExtra)
```

\newpage

# Module 1: Complex Sample Designs & Design Effects

## What Is a Complex Sample?

A **complex sample** is a probability sample developed using one or more of:
**stratification**, **clustering (multistage selection)**, and **unequal probability weighting**.
These features improve statistical efficiency, reduce data collection costs, or improve precision
for subgroup analyses relative to simple random sampling (SRS).

Unlike SRS, complex designs do **not** assume i.i.d. observations or equal selection
probabilities. However, unbiased estimates with measurable sampling error remain possible.

## Key Design Features

### Stratification

- The population is partitioned into subgroups (strata) before sampling.
- **Efficiency goal:** Form strata so that $Y$ is **homogeneous within strata** but
  **heterogeneous across strata**.
- Effect on variance: stratification generally **decreases** variance relative to SRS ($D^2 < 1$).

### Cluster Sampling

- Elements are selected in groups (clusters) rather than individually.
- Primary motivation is **cost reduction** of data collection.
- Effect on variance: clustering generally **increases** variance relative to SRS ($D^2 > 1$)
  because elements within a cluster tend to resemble each other (positive $\rho$).

### Multistage Designs

Sampling proceeds in stages; e.g., NHANES:

1. **Stage 1 (PSU):** Counties stratified by region and MSA status; selected by PPeS.
2. **Stage 2 (SSU):** Area segments within PSUs selected by PPeS.
3. **Stage 3:** Housing units within segments listed and sampled.

## Design Effect (DEFF)

The design effect compares the variance under a complex design to the variance under SRS
of the **same sample size $n$**:

\begin{keybox}[Design Effect Definition]
$$D^2(\bar{y}) = \frac{V(\bar{y}_{complex})}{V(\bar{y}_{SRS})}$$

Estimated from sample data by:
$$d^2(\bar{y}) = \frac{v(\bar{y}_{complex})}{v(\bar{y}_{SRS})}$$
\end{keybox}

**Interpretation:**

- $D^2 > 1$: Complex design is **less efficient** than SRS (clustering dominates).
- $D^2 < 1$: Complex design is **more efficient** than SRS (stratification dominates).
- $D^2 = 1$: Equally efficient as SRS.

### Design Effect, ICC, and Effective Sample Size

For equal-probability cluster sampling with $b$ elements per cluster, the design effect
depends on cluster size and the intraclass correlation coefficient $\rho$:

\begin{keybox}[Cluster DEFF: ICC and Effective Sample Size]
$$D^2(\bar{y}) \approx 1 + (b-1)\rho$$

Estimating $\rho$ from the observed DEFF:
$$\hat{\rho} = \frac{d^2(\bar{y}) - 1}{b - 1}$$

Effective sample size (accounts for design inflation):
$$n_{eff} = \frac{n}{D^2(\bar{y})}$$
\end{keybox}

**Interpretation of $\rho$:**

- $\rho > 0$: Within-cluster observations more similar than between clusters $\to$ inflated variance.
- $\rho < 0$: Within-cluster observations more different than between clusters $\to$ variance reduction.
- $\rho = 0$: No within-cluster homogeneity; $D^2 = 1$.

### R: Computing Design Effects (Homework 1)

```r
#| label: hw1-deff

# Define the four designs from HW1 Appendix
srs_design      <- svydesign(ids = ~1,       data = hw1_data)
strat_design    <- svydesign(ids = ~1,       strata = ~stratum, data = hw1_data)
cluster_design  <- svydesign(ids = ~cluster, data = hw1_data)
strat_cl_design <- svydesign(ids = ~cluster, strata = ~stratum, data = hw1_data)

# Extract mean and SE for each design
get_results <- function(design, label) {
  m <- svymean(~observation, design)
  tibble(Design = label, Mean = coef(m), SE = SE(m))
}

bind_rows(
  get_results(srs_design,      "1. SRS"),
  get_results(strat_design,    "2. Stratified"),
  get_results(cluster_design,  "3. Cluster"),
  get_results(strat_cl_design, "4. Strat-Cluster")
) |> kable(digits = 4)

# Compute DEFF relative to SRS variance
var_srs <- vcov(svymean(~observation, srs_design))[1, 1]

tibble(
  Design = c("2. Stratified", "3. Cluster", "4. Strat-Cluster"),
  DEFF   = c(
    vcov(svymean(~observation, strat_design))[1,1]    / var_srs,
    vcov(svymean(~observation, cluster_design))[1,1]  / var_srs,
    vcov(svymean(~observation, strat_cl_design))[1,1] / var_srs
  )
) |> kable(digits = 4)
# Expected output:
# Design            DEFF
# 2. Stratified     0.8432   <- D^2 < 1: stratification gains precision
# 3. Cluster        1.6414   <- D^2 > 1: clustering inflates variance
# 4. Strat-Cluster  1.1726   <- net effect of both features
```

\newpage

# Module 2: Survey Weighting

## Why Weight?

Weighting compensates for three sources of imbalance between sample and population:

1. **Unequal probabilities of selection**
2. **Nonresponse** (unit nonresponse)
3. **Post-stratification / calibration** — aligning weighted sample distributions to known
   population totals

## The Three Weight Components

\begin{keybox}[Overall Survey Weight]
$$w_i = w_{sel,i} \;\times\; w_{nr,i} \;\times\; w_{ps,i}$$
\end{keybox}

### 1. Selection Weight ($w_{sel}$)

Each element selected with probability $f_i$ receives:
$$w_{sel,i} = \frac{1}{f_i}$$

Under an **EPSEM** design, all $f_i$ are equal and the unweighted sample mean is unbiased.
Under a **non-EPSEM** design, a weighted estimator is required:

\begin{keybox}[Weighted Mean Estimator]
$$\bar{y}_w = \frac{\sum_i w_i y_i}{\sum_i w_i} = \frac{\hat{Y}}{\hat{N}}$$
\end{keybox}

### R: SRS vs. Weighted vs. Full Complex Design (Homework 2)

```r
#| label: hw2-designs

# SRS design (ignore all design features)
srs_design <- svydesign(ids = ~1, data = ess_data, weights = NULL)

# Weights only (no stratification or clustering)
design_weights_only <- svydesign(ids = ~1, weights = ~PSPWGHT, data = ess_data)

# Full complex design: weights + strata + clusters
design_full <- svydesign(
  ids     = ~PSU,
  strata  = ~STRATIFY,
  weights = ~PSPWGHT,
  data    = ess_data,
  nest    = TRUE   # PSU codes nested within strata
)

# Compare SE across the three designs
vars <- c("STFLIFE", "TRSTPLC")

map_dfr(vars, function(var) {
  fml <- as.formula(paste0("~", var))
  tibble(
    Variable   = var,
    SE_SRS     = as.numeric(SE(svymean(fml, srs_design,          na.rm = TRUE))),
    SE_Wtd     = as.numeric(SE(svymean(fml, design_weights_only, na.rm = TRUE))),
    SE_Complex = as.numeric(SE(svymean(fml, design_full,         na.rm = TRUE)))
  )
}) |> kable(digits = 5)
# Expected output:
# Variable  SE_SRS   SE_Wtd   SE_Complex
# STFLIFE   0.04704  0.05559  0.08545
# TRSTPLC   0.05241  0.06161  0.10390
# Weighting increases SE (unequal weights reduce effective n).
# Full clustering further inflates SE beyond the weighted-only design.
```

### 2. Nonresponse Adjustment Weight ($w_{nr}$)

Differential nonresponse causes bias even after selection weighting:

$$\text{Bias}(\bar{Y}_R) = \bar{Y}_R - \bar{Y} = (1 - RR) \times (\bar{Y}_R - \bar{Y}_{NR})$$

where $RR$ is the expected population response rate.

**Two common adjustment methods:**

**a) Weighting Class Adjustment:** Cross-classify respondents and nonrespondents into
cells $c$ using categorical variables that (1) predict nonresponse and (2) are associated
with survey outcomes. The adjustment:

$$w_{nr,wc,i} = \frac{1}{rrate_c}$$

**b) Response Propensity Weighting:** Estimate response probability via logistic regression.
Adjustment is the inverse of the predicted propensity.

> **Variable selection difference:** Weighting class adjustment requires *categorical*
> predictors; response propensity methods can use continuous and categorical predictors.

### 3. Post-stratification Weight ($w_{ps}$)

Calibrates to known population counts $N_l$ to reduce noncoverage bias and variance:

$$w_{ps,l,i} = \frac{N_l}{\hat{N}_l} = \frac{N_l}{\sum_{i=1}^{n_l}(w_{sel,i} \times w_{nr,i})}$$

**Four construction steps:**

1. Define post-strata using census or administrative data.
2. Obtain population counts $N_l$ from the external source.
3. Compute the weighted sample count $\hat{N}_l$ within each post-stratum.
4. Form $N_l / \hat{N}_l$ as the adjustment factor.

More complex variants include **calibration** and **raking**.

## Confidence Intervals

\begin{keybox}[95\% Confidence Interval]
$$CI_{0.95}(\hat{\theta}) = \hat{\theta} \;\pm\; t_{df,\,0.975} \;\times\; se(\hat{\theta})$$

Degrees of freedom approximation: $df \approx a - H$ (total PSUs $-$ total strata).
\end{keybox}

**Interpretation:** Under repeated sampling from the same design, 95% of computed
intervals will contain the true population parameter.

\newpage

# Module 3: Sampling Error Calculation Models (SECM)

## Ultimate Cluster Assumptions

A **Sampling Error Calculation Model (SECM)** simplifies variance estimation using four
assumptions:

**(a)** PSUs are sampled **with replacement** (WR).
**(b)** All elements within each ultimate cluster are selected.
**(c)** The design is treated as **single-stage**.
**(d)** Result: the SECM produces a **conservative overestimate** of the true sampling
variance. The WR assumption ignores the negative correlation between PSU selections
that arises under without-replacement sampling. The overestimation is slight (Kish, 1965)
so reported standard errors are **safe** — they will be somewhat larger than the truth, but
never smaller. This is a desirable property for inference.

An **ultimate cluster** is all sample elements within a PSU, regardless of the actual number
of sub-stages of selection.

## Constructing the SECM: Three Adjustment Scenarios

### Collapsing Strata

**When:** A stratum contains only **one PSU** — impossible to estimate within-stratum
variance from a single unit.

**Method:** Pair adjacent single-PSU strata into one artificial stratum with two SECUs.

**Bias direction:** The collapsed stratum is larger and more heterogeneous $\to$ variance
estimate **overestimates** the true variance (conservative).

### Combining Strata

**When:** The design has too many strata; the data producer wishes to simplify SECU coding
or limit disclosure risk.

**Bias direction:** Larger, more heterogeneous combined strata $\to$ variance estimate
**overestimates** the true variance (conservative).

### Random Grouping

**When:** Strata contain many PSUs; the data producer wishes to reduce SECU codes or
limit disclosure.

**Method:** Randomly assign PSUs within a stratum into two groups (SECUs).

**Bias direction:** Random assignment produces balanced groups with similar totals $\to$
variance estimate is approximately **unbiased**.

\begin{warnbox}[Bias Direction Summary]
\begin{tabular}{lll}
\toprule
Scenario & When Used & Bias Direction \\
\midrule
Collapsing strata & 1 PSU per stratum     & Conservative (over-estimates) \\
Combining strata  & Too many strata       & Conservative (over-estimates) \\
Random grouping   & Many PSUs per stratum & Approximately unbiased        \\
\bottomrule
\end{tabular}
\end{warnbox}

## Notes on Real-World SECMs

- Large self-representing (SR) PSUs define multiple strata.
- Smaller SR PSUs define their own single stratum.
- Non-self-representing (NSR) PSUs are paired and collapsed into strata with two SECUs.
- SECU codes are often **masked** (randomly scrambled) in public-use files to prevent PSU
  identification.

\newpage

# Modules 4--6: Variance Estimation & Percentile Estimation

## Overview

Variance estimation for nonlinear statistics under complex sampling uses two main approaches:

1. **Taylor Series Linearization (TSL):** Approximates the nonlinear statistic as a linear
   function of sample totals; derives an analytic variance formula.
2. **Replication Methods:** Creates sub-samples (replicates), computes the statistic for each,
   and uses the spread across replicates to estimate variance.

## Taylor Series Linearization (Module 4)

### Variance of a Ratio (Corrected Notation)

For a ratio estimator $\hat{R} = \hat{Y}/\hat{X}$ where $\hat{Y}$ and $\hat{X}$ are estimated
**population totals**, the TSL variance formula is:

\begin{keybox}[Variance of a Ratio --- Using Population Totals]
$$\widehat{\text{Var}}(\hat{R}) \approx \frac{\widehat{\text{Var}}(\hat{Y}) \;+\; \hat{R}^2\,\widehat{\text{Var}}(\hat{X}) \;-\; 2\hat{R}\,\widehat{\text{Cov}}(\hat{Y},\,\hat{X})}{\hat{X}^2}$$

The denominator is $\hat{X}^2$ --- the square of the estimated \textbf{total} of the
denominator variable, not a sample mean. This preserves the correct variance scale when
working with weighted sums. For the weighted mean $\bar{y}_w = \hat{Y}/\hat{N}$,
$\hat{X} = \hat{N}$ (estimated population size).
\end{keybox}

### TSL Variance: Stratified Cluster Design (2 PSUs per Stratum)

Define PSU-level weighted totals: $x_{h\alpha} = \sum_i w_{h\alpha i}\,y_{h\alpha i}$ and
$z_{h\alpha} = \sum_i w_{h\alpha i}$. Set differences: $dx_h = x_{h1} - x_{h2}$,
$dz_h = z_{h1} - z_{h2}$.

\begin{keybox}[TSL Variance: 2 PSUs per Stratum]
$$\widehat{\text{Var}}(\bar{y}_w) = \frac{\displaystyle\sum_h (dx_h)^2 \;+\; \bar{y}_w^2 \sum_h (dz_h)^2 \;-\; 2\bar{y}_w \sum_h dx_h\,dz_h}{\hat{X}^2}$$

where $\hat{X} = \sum_h (z_{h1} + z_{h2})$ is the total estimated $\hat{N}$.
\end{keybox}

### TSL Variance: Multiple PSUs per Stratum

For $a_h$ PSUs in stratum $h$:

$$
(dx_h)^2 = \frac{a_h}{a_h-1}\left[\sum_\alpha x_{h\alpha}^2 - \frac{\bigl(\sum_\alpha x_{h\alpha}\bigr)^2}{a_h}\right]
$$

The same structure applies to $(dz_h)^2$ and the cross-product $dx_h\,dz_h$.

### R: Specifying the TSL Design

```r
#| label: tsl-design

# Full complex design using TSL (the default in the survey package)
design_tsl <- svydesign(
  ids     = ~PSU,      # cluster / PSU identifier
  strata  = ~STRATIFY, # stratum identifier
  weights = ~PSPWGHT,  # final survey weight
  data    = ess_data,
  nest    = TRUE       # PSU codes are nested within strata
)

# Weighted mean and SE via TSL
svymean(~STFLIFE, design_tsl, na.rm = TRUE)

# Weighted total
svytotal(~STFLIFE, design_tsl, na.rm = TRUE)
```

## Replication Methods (Module 5)

### General Steps for All Replication Methods

1. Create replicates from sampled cases (method-specific).
2. Assign revised replicate weights $w_i^{(k)}$.
3. Compute $\hat{q}^{(k)}$ for each replicate using replicate weights.
4. Apply the replication variance formula.
5. Construct CIs using $\hat{q}$, $se(\hat{q})$, and $df \approx a - H$.

### Jackknife Repeated Replication (JRR)

**Replicate construction:** Delete one PSU at a time. For replicate $k$ formed by deleting
PSU $h\alpha$, the replicate weight is:

\begin{keybox}[JRR Replicate Weights --- Complete Specification]
$$w_i^{(k)} = \begin{cases}
0                               & i \in h\alpha \quad\text{(deleted PSU)} \\[4pt]
\dfrac{a_h}{a_h - 1}\,w_i     & i \in h\alpha' \quad\text{(other PSUs in stratum $h$)} \\[6pt]
w_i                             & i \notin h \quad\text{(all other strata, unchanged)}
\end{cases}$$

The factor $a_h/(a_h-1)$ inflates the remaining cases in stratum $h$ so that the
weighted total remains consistent with the full-sample estimate across all replicates.
\end{keybox}

\begin{keybox}[JRR Variance Estimator]
$$\widehat{\text{Var}}_{JRR}(\hat{q}) = \sum_{h=1}^H \frac{a_h - 1}{a_h} \sum_{\alpha=1}^{a_h} (\hat{q}_{(h\alpha)} - \hat{q})^2$$

For a paired design (2 PSUs per stratum):
$$= \frac{1}{2}\sum_{k=1}^a (\hat{q}_k - \hat{q})^2$$
\end{keybox}

### Balanced Repeated Replication (BRR)

**Requirement:** Exactly **2 PSUs per stratum**.

**Replicate construction:** Use a **Hadamard matrix** to determine which PSU is dropped
in each half-sample replicate ($C$ replicates total; minimum $C \geq H$).

\begin{keybox}[BRR Replicate Weight \& Variance]
$$w_i^{(c)} = \begin{cases} 0 & i \text{ is in the dropped PSU} \\ 2w_i & \text{otherwise} \end{cases}$$

$$\widehat{\text{Var}}_{BRR}(\hat{q}) = \frac{1}{C}\sum_{c=1}^C (\hat{q}_c - \hat{q})^2$$
\end{keybox}

### Bootstrap

For each replicate $b$: sample $m_h = a_h - 1$ PSUs **with replacement** from stratum $h$.

\begin{keybox}[Bootstrap Replicate Weight \& Variance]
$$w_i^{(b)} = w_i \cdot \frac{a_h}{m_h} \cdot r_{h\alpha}^{(b)}$$

where $r_{h\alpha}^{(b)}$ is the number of times PSU $h\alpha$ is selected in replicate $b$.

$$\widehat{\text{Var}}_{Bootstrap}(\hat{q}) = \frac{1}{B}\sum_{b=1}^B (\hat{q}_b - \hat{q})^2$$
\end{keybox}

### R: JRR via `as.svrepdesign` (Homework 3)

```r
#| label: hw3-jrr

# Convert TSL design to JRR stratified delete-one jackknife
design_jrr <- as.svrepdesign(design_tsl, type = "JKn")

# Compare TSL vs JRR standard errors
map_dfr(c("STFLIFE", "TRSTPLC"), function(v) {
  fml <- as.formula(paste0("~", v))
  tsl <- svymean(fml, design_tsl, na.rm = TRUE)
  jrr <- svymean(fml, design_jrr, na.rm = TRUE)
  tibble(
    Variable = v,
    Mean     = coef(tsl),
    SE_TSL   = as.numeric(SE(tsl)),
    SE_JRR   = as.numeric(SE(jrr)),
    Ratio    = as.numeric(SE(jrr) / SE(tsl))
  )
}) |> kable(digits = 5)
# Expected output (HW3 results):
# Variable  Mean    SE_TSL   SE_JRR   Ratio
# STFLIFE   5.8121  0.08545  0.08566  1.0025
# TRSTPLC   3.5177  0.10390  0.10416  1.0025
#
# JRR and TSL are asymptotically equivalent for smooth statistics (e.g., means).
# TSL uses a first-order linear approximation; JRR is fully nonparametric.
```

### Method Comparison

```r
#| label: tbl-replication-methods
#| tbl-cap: "Comparison of Replication-Based Variance Methods"
#| eval: true
#| echo: false
library(tidyverse)
library(knitr)
library(kableExtra)
tibble(
  Method     = c("JRR", "BRR", "Bootstrap"),
  `PSU Req.` = c("$\\geq$ 2 PSUs/stratum", "Exactly 2 PSUs/stratum",
                 "$\\geq$ 2 PSUs/stratum"),
  Replicates = c("$\\sum a_h$ (one per PSU)", "$\\geq H$ (Hadamard)",
                 "$B$ (user-specified)"),
  `Key Feature` = c(
    "Delete one PSU; re-weight stratum",
    "Half-sample via Hadamard matrix",
    "Resample PSUs with replacement"
  )
) |>
  kbl(booktabs = TRUE, escape = FALSE, linesep = "") |>
  kable_styling(latex_options = c("hold_position", "striped"), font_size = 10) |>
  column_spec(1, bold = TRUE)
```

## Percentile / Quantile Estimation (Module 6)

### Population CDF and Weighted Estimator

The population CDF:
$$F(x) = \frac{\sum_{i=1}^N \mathbf{1}(y_i \leq x)}{N}$$

The complex-sample weighted estimator:

\begin{keybox}[Weighted CDF Estimator]
$$\hat{F}(x) = \frac{\displaystyle\sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i}\,\mathbf{1}(y_{h\alpha i} \leq x)}{\displaystyle\sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i}}$$
\end{keybox}

### Estimating the $q$-th Quantile

Find the smallest $x$ such that $\hat{F}(x) \geq q$. For variance estimation, **BRR is
recommended** (Kovar, Rao, and Wu, 1988); TSL (Binder, 1991) is also available.

### Subpopulation Analysis

\begin{warnbox}[Subpopulation Size as a Random Variable]
In subpopulation analysis, the subpopulation sample size $n_s$ must be treated as a
\textbf{random variable}, not a fixed constant.

\begin{itemize}
  \item \textbf{Conditional analysis} (treats $n_s$ as fixed): ignores the variability
  in who falls in the subpopulation. Standard errors are \textbf{too small}.
  \item \textbf{Unconditional analysis} (treats $n_s$ as random): the correct approach.
  Implemented in R by retaining all observations in the full \texttt{svydesign} object and
  using \texttt{svyby()} to subset, rather than filtering the data before
  \texttt{svydesign()}.
\end{itemize}
\end{warnbox}

Additionally, the covariance between subpopulation estimates is often **positive** due to
clustering, even when subpopulations are mutually exclusive (e.g., males and females).
The covariance is zero only when subpopulations are defined by **distinct design strata**.

```r
#| label: subpopulation

# Correct: svyby() treats n_s as random (unconditional)
svyby(~STFLIFE, ~SEX, design_full, svymean, na.rm = TRUE)

# INCORRECT approach -- do not filter data before svydesign():
# design_male <- svydesign(..., data = filter(ess_data, SEX == 1))
# This treats n_s as fixed (conditional) and underestimates SE.
```

\newpage

# Module 7: Categorical Data Analysis

## Univariate Analysis

**Graphical displays:** bar charts, pie charts, histograms.

### Estimating a Proportion

\begin{keybox}[Weighted Proportion Estimator]
$$\hat{p}_k = \frac{\hat{N}_k}{\hat{N}} = \frac{\displaystyle\sum_h\sum_\alpha\sum_i w_{h\alpha i}\,\mathbf{1}(i \in k)}{\displaystyle\sum_h\sum_\alpha\sum_i w_{h\alpha i}}$$
\end{keybox}

### Variance of a Proportion (TSL)

$$\widehat{\text{Var}}_{TSL}(\hat{p}_k) = \frac{\widehat{\text{Var}}(\hat{N}_k) + \hat{p}_k^2\,\widehat{\text{Var}}(\hat{N}) - 2\hat{p}_k\,\widehat{\text{Cov}}(\hat{N}_k,\,\hat{N})}{\hat{N}^2}$$

### Confidence Intervals for a Proportion

**Normal approximation** (may go outside $[0,1]$ when $\hat{p}_k$ is near 0 or 1):
$$CI(\pi_k) = \hat{p}_k \pm t_{0.975,\,df} \cdot se(\hat{p}_k)$$

**Logit-transform method** (always stays within $[0,1]$; preferred when $\hat{p}_k$ is
extreme):

\begin{keybox}[Logit-Transformed CI --- Full Two-Step Procedure]
\textbf{Step 1: Compute logit-scale bounds.}
$$A = \log\!\left(\frac{\hat{p}_k}{1-\hat{p}_k}\right) - \frac{t_{0.975,df}\cdot se(\hat{p}_k)}{(1-\hat{p}_k)\hat{p}_k}$$
$$B = \log\!\left(\frac{\hat{p}_k}{1-\hat{p}_k}\right) + \frac{t_{0.975,df}\cdot se(\hat{p}_k)}{(1-\hat{p}_k)\hat{p}_k}$$

\textbf{Step 2: Back-transform to the probability scale.}
$$\text{Lower CI} = \frac{e^A}{1 + e^A}, \qquad \text{Upper CI} = \frac{e^B}{1 + e^B}$$

Without Step 2, the result is in logit units and \textbf{cannot} be interpreted as a
proportion. Both steps are required for a complete answer.
\end{keybox}

\begin{warnbox}[Exam Note]
If an exam question provides $\hat{p}_k$ and $se(\hat{p}_k)$, you are expected to compute
both bounds $A$ and $B$ (Step 1), then back-transform each to the probability scale (Step 2).
\end{warnbox}

## Bivariate Analysis: Contingency Tables

For an $R \times C$ table, total, row, and column proportions can each be estimated under
the complex design.

```r
#| label: contingency-r

# Weighted contingency table (counts)
svytable(~factor_var + response_var, design = design_full)

# Row proportions with SE — use svyby() (treats subpopulation n_s as random)
svyby(
  formula = ~response_var,
  by      = ~factor_var,
  design  = design_full,
  FUN     = svymean,
  na.rm   = TRUE
)
```

## Chi-Square Tests for Independence

### Standard (SRS) Test Statistics

**Pearson $\chi^2$:**
$$X^2_{Pearson} = n_{++} \cdot \sum_r\sum_c \frac{(p_{rc} - \hat{\pi}_{rc})^2}{\hat{\pi}_{rc}}$$

**Likelihood Ratio $G^2$:**
$$G^2 = 2 \cdot n_{++} \cdot \sum_r\sum_c p_{rc} \ln\!\left(\frac{p_{rc}}{\hat{\pi}_{rc}}\right)$$

Both follow $\chi^2_{(R-1)(C-1)}$ under $H_0$ with SRS data. These are **invalid** for
complex survey data without design adjustment: ignoring the design biases the estimated
proportions that enter the test statistics.

## Design-Adjusted Chi-Square Tests

### Fellegi (1980) Method

1. Compute the **average design effect** across all table cell proportions: $\overline{DEFF}$.
2. Divide the SRS Pearson $\chi^2$ by $\overline{DEFF}$:
$$X^2_{Fellegi} = X^2_{Pearson} \,/\, \overline{DEFF}$$
3. Compare to $\chi^2_{(R-1)(C-1)}$.

### Rao-Scott First-Order Correction

Uses weighted proportions and adjusts by the **generalized design effect** (GDEFF): the
mean of the eigenvalues $\delta_j$ of the matrix $\mathbf{D}$ (ratio of complex-design to
SRS variance across cell proportions).

\begin{keybox}[Rao-Scott First-Order Statistics]
$$X^2_{RS1} = X^2_{Pearson} \,/\, GDEFF \;\sim\chi^2_{(R-1)(C-1)}$$
$$G^2_{RS1} = G^2 \,/\, GDEFF \;\sim\chi^2_{(R-1)(C-1)}$$

F-statistic form (denominator $df = s = \#\text{clusters} - \#\text{strata}$):
$$F_{RS} = \frac{X^2_{RS1}}{(R-1)(C-1)} \;\sim F_{(R-1)(C-1),\;(R-1)(C-1)\cdot s}$$
\end{keybox}

### Rao-Scott Second-Order Correction

The first-order correction assumes eigenvalues $\delta_j$ are approximately equal across
cells. When design effects are **highly heterogeneous** across cells, the first-order correction
can overstate significance. The second-order correction adds $\hat{a}^2$, the squared
coefficient of variation of the eigenvalues:

\begin{keybox}[Rao-Scott Second-Order Correction]
$$X^2_{RS2} = \frac{X^2_{RS1}}{1 + \hat{a}^2}$$

where $\hat{a}^2 = \text{CV}^2(\delta_j) = \dfrac{\text{Var}(\delta_j)}{\bar{\delta}^2}$
is the ratio of the variance to the squared mean of the eigenvalues.

\textbf{When to use:} Apply the second-order correction when the design effects vary
substantially across cells (high $\hat{a}^2$). The first-order correction is sufficient when
design effects are roughly homogeneous.
\end{keybox}

### R: Design-Adjusted Chi-Square Test

```r
#| label: chisq-r

# Rao-Scott first-order chi-square (default statistic)
svychisq(~factor_var + response_var,
         design    = design_full,
         statistic = "Chisq")

# F-statistic version (Rao-Scott)
svychisq(~factor_var + response_var,
         design    = design_full,
         statistic = "F")
```

\newpage

# Quick Reference: Key Formulas

```r
#| label: tbl-key-formulas
#| tbl-cap: "Key Formulas by Module"
#| eval: true
#| echo: false
library(tidyverse)
library(knitr)
library(kableExtra)
tibble(
  Quantity = c(
    "Weighted mean",
    "Design effect",
    "ICC from DEFF",
    "DEFF (cluster, 2-stage)",
    "Effective sample size",
    "NR weighting class",
    "Post-strat weight",
    "Var of ratio (TSL)",
    "JRR variance (paired)",
    "BRR variance",
    "Bootstrap variance",
    "Weighted proportion",
    "Logit CI lower",
    "Logit CI upper",
    "NR bias",
    "RS second-order"
  ),
  Formula = c(
    "$\\bar{y}_w = \\sum_i w_i y_i \\,/\\, \\sum_i w_i$",
    "$d^2 = v(\\bar{y}_{complex}) \\,/\\, v(\\bar{y}_{SRS})$",
    "$\\hat{\\rho} = (d^2 - 1)\\,/\\,(b-1)$",
    "$D^2 \\approx 1 + (b-1)\\rho$",
    "$n_{eff} = n \\,/\\, D^2$",
    "$w_{nr,wc,i} = 1 \\,/\\, rrate_c$",
    "$w_{ps,l,i} = N_l \\,/\\, \\hat{N}_l$",
    "$[\\widehat{\\mathrm{Var}}(\\hat{Y}) + \\hat{R}^2\\widehat{\\mathrm{Var}}(\\hat{X}) - 2\\hat{R}\\widehat{\\mathrm{Cov}}(\\hat{Y},\\hat{X})]\\,/\\,\\hat{X}^2$",
    "$\\frac{1}{2}\\sum_k(\\hat{q}_k - \\hat{q})^2$",
    "$\\frac{1}{C}\\sum_c(\\hat{q}_c - \\hat{q})^2$",
    "$\\frac{1}{B}\\sum_b(\\hat{q}_b - \\hat{q})^2$",
    "$\\hat{p}_k = \\hat{N}_k \\,/\\, \\hat{N}$",
    "$e^A \\,/\\, (1 + e^A)$",
    "$e^B \\,/\\, (1 + e^B)$",
    "$(1-RR)(\\bar{Y}_R - \\bar{Y}_{NR})$",
    "$X^2_{RS2} = X^2_{RS1} \\,/\\, (1 + \\hat{a}^2)$"
  ),
  Module = c("2","1","1","1","1","2","2","4","5","5","5","7","7","7","2","7")
) |>
  kbl(booktabs = TRUE, escape = FALSE, linesep = "") |>
  kable_styling(latex_options = c("hold_position", "striped"), font_size = 8.5) |>
  column_spec(1, bold = TRUE, width = "3.8cm") |>
  column_spec(2, width = "8.5cm") |>
  column_spec(3, width = "1.2cm")
```

\newpage

# Practice Questions by Module

## Module 1

1. Under what conditions does stratification **increase** rather than decrease efficiency?
2. You observe $d^2 = 1.64$ with cluster size $b = 3$. Compute $\hat{\rho}$ and interpret it.
3. A stratified design yields $D^2 = 0.84$. Explain what this means in plain English.
4. If $n = 400$ and $D^2 = 2.0$, what is $n_{eff}$? What does this imply for precision?

## Module 2

5. An element is selected with $f_i = 0.05$. What is $w_{sel,i}$?
6. A weighting class has $rrate_c = 0.75$. What is $w_{nr,wc,i}$?
7. Why does weighting for nonresponse generally **increase** standard errors?
8. List the four steps to construct a post-stratification weight.

## Module 3

9. A stratum has only 1 PSU selected. What adjustment is needed, and in which direction
   does this bias the variance estimate?
10. State the four SECM assumptions. Which one creates the conservative overestimate, and
    why is this still considered safe for inference?
11. Compare the bias directions for collapsing strata vs. random grouping.

## Modules 4--6

12. In the TSL variance for a ratio, why is $\hat{X}^2$ (the squared estimated population
    total) in the denominator rather than a sample mean squared?
13. Write the complete JRR replicate weight $w_i^{(k)}$ for all three cases: deleted PSU,
    remaining PSUs in the same stratum, and PSUs in other strata.
14. You have 4 strata with exactly 2 PSUs each. (a) Which replication method is uniquely
    suited? (b) What is the minimum number of BRR replicates? (c) What are the $df$?
15. Show the R code to convert a TSL `svydesign` to a JRR design and compare SEs.
16. Why must $n_s$ be treated as a random variable in subpopulation analysis? What R
    function implements this correctly?

## Module 7

17. Given $\hat{p}_k = 0.08$ and $se(\hat{p}_k) = 0.015$ with $df = 50$, compute the
    **complete** logit-transformed 95% CI. Show both Step 1 (logit bounds) and Step 2
    (back-transformation to the probability scale).
18. `svychisq()` output reports Pearson $\chi^2 = 29.18$ and $GDEFF = 1.15$.
    (a) What is $X^2_{RS1}$?
    (b) What are the $df$ for a $4 \times 2$ table?
    (c) Under what condition would you additionally apply the second-order correction?
19. Why is the standard Pearson $\chi^2$ invalid for complex survey data?
20. Explain the difference between the Fellegi and Rao-Scott correction approaches.
