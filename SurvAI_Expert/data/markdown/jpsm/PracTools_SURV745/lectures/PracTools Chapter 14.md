---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_14"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 14.pdf"
pages: 43
sha256: "a886105a0044fe6d56e5be321663bee8d35c5860d8dd73a6b593a40c5f748573"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:15"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference
## Chapter 14: Calibration and Other Uses of Auxiliary Data in Weighting

Sunghee Lee

---
Sunghee Lee (U of Michigan) | Prac Tools Ch. 14 | 1 / 43

<!-- page 2 -->

# Outline

1. 1. Overview

2. 2. Weight Calibration

3. 3. Poststratification & Raking
   * 3.1 Poststratification
   * 3.2 Raking

4. 4. General Regression Estimation

5. 5. Weight Variability
   * 5.1 Bounding Weights with Quadratic Programming
   * 5.2 Weights Trimming

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 2 / 43

<!-- page 3 -->

1. Overview

# 1. Overview

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 3 / 43

<!-- page 4 -->

1. Overview

# Introduction

* First few steps used in weight calculation: base weights, adjustments of unknown eligibility, and nonresponse adjustments
* Last step, which is extremely important in many surveys, is to use auxiliary data to correct coverage problems and to reduce standard errors.
  * By auxiliary data, we mean information that is available for the entire frame or target population
  * Can be either for each individual population unit or in aggregate form.
* Business surveys: frame might have number of employees from an earlier time period for each establishment.
* Household surveys: counts of persons in groups defined by age, race/ethnicity, and gender may be published from a census or from population projections.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 4 / 43

<!-- page 5 -->

1. Overview

# Uses of Calibration

* Reduce variances
* Correct for frame undercoverage
  * In HH surveys in US, estimates of number of young black or Hispanic males are usually 75-80% of census counts
  * By creating weights that reproduce census counts we can "correct" for undercoverage
* To correct for coverage and/or nonresponse, responding sample cases do have to be a good representation of the full population, meaning that either
  1. adjustments in VDK Ch. 13 to weights correct any potential bias due to nonresponse, or
  2. analysis variables for respondents follow same model as full population and that model can be approximated by the calibration techniques in VDK Ch. 14

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 5 / 43

<!-- page 6 -->

1. Overview

# Figure 14.1

Scatterplots of two hypothetical relationships between a survey variable $y$ and an auxiliary $x$

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 6 / 43

*[Figure: The figure presents two side-by-side scatterplots comparing hypothetical relationships between an auxiliary variable $x$ (horizontal axis, ranging from 20 to 80) and a survey variable $y$ (vertical axis, ranging from 50 to 90). Both plots show a positive association where $y$ increases with $x$, with the left plot illustrating a tight, slightly curved upward trend with low variance, and the right plot displaying a more dispersed, heteroscedastic trend where variance increases at higher values of $x$.]*

<!-- page 7 -->

2. Weight Calibration

# 2. Weight Calibration

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 7 / 43

<!-- page 8 -->

2. Weight Calibration

# Calibration

* Term "calibration" introduced by Deville & Särndal (1992)
* Use auxiliaries to improve efficiency
* Sources: frame, administrative records, published statistics
* Used for:
  * Reducing variances
  * Correcting for coverage errors
  * Adjustment for nonresponse

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 8 / 43

<!-- page 9 -->

2. Weight Calibration

# Example 14.1 Ratio Estimator

* Ratio estimator of a mean in *srswor*
  $$\bar{y}_R = \bar{y}_s \frac{\bar{x}_U}{\bar{x}_s}, \text{ where}$$
  * $\bar{y}_s = \sum_s y_i/n$: unweighted means of an analysis variable $y$
  * $\bar{x}_s = \sum_s x_i/n$: unweighted means of an auxiliary variable $x$
  * $\bar{x}_U$: the population mean of $x$
* If we set $y = x$ and evaluate, we get
  $$\bar{x}_R = \bar{x}_s \frac{\bar{x}_U}{\bar{x}_s} = \bar{x}_U$$
* In this sense, the ratio estimator is calibrated to the population mean of $x$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 9 / 43

<!-- page 10 -->

2. Weight Calibration

# Calibration Problem

Formally, the following problem is solved with weight calibration:

Find the set of weights, $\{w_i\}_{i \in s}$ that

* Minimize a measure of the distance, $L(w, d)$, between the input weights ($\{d_i\}_{i \in s}$) and the calibrated weights
* Subject to constraints:
  $$\sum_{i \in s} w_i \mathbf{x}_i = \sum_{k \in U} \mathbf{x}_k \qquad (14.1),$$
  where
  * $\mathbf{x}_i = (x_{i1}, x_{i2}, \cdots, x_{ip})^T$: the set of $p$ auxiliary variables for unit $i$
  * $w_i = d_i g_i$: a function of the input weight and an adjustment (the $g$-weight) that satisfies the constraints.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 10 / 43

<!-- page 11 -->

2. Weight Calibration

# Distance Functions

* One choice of $L$ is the least squares distance function,
$$
L(w, d) = \sum_{s} (w_{i} - d_{i})^{2} / d_{i} \qquad (14.2)
$$
Minimizing this, subject to the constraint in (14.1), leads to the general regression estimator or GREG.
GREGs include many of the estimators used in practice.

* Another distance function is
$$
L(w, d) = \sum_{s} \left[ w_{i}\log \left( \frac{w_{i}}{d_{i}} \right) - w_{i} + d_{i} \right] \qquad (14.3)
$$
This leads to a type of raking estimator.

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 14 $\qquad$ 11 / 43

<!-- page 12 -->

3. Poststratification & Raking

# 3. Poststratification & Raking

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 12 / 43

<!-- page 13 -->

3. Poststratification & Raking | 3.1 Poststratification

# 3.1 Poststratification

Sunghee Lee (U of Michigan) | Prac Tools Ch. 14 | 13 / 43

<!-- page 14 -->

3. Poststratification & Raking 3.1 Poststratification

# Poststratification - 1

* Poststratified and raking estimators common in household surveys of persons where the auxiliary variables are indicators for demographic groups.
  – Persons may be classified by age group, sex, and race/ethnicity.
* Weighting classes formed by crossing all categories of the qualitative variables
* Construct weights that reproduce the class-specific population counts in the weighted estimates.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 14 / 43

<!-- page 15 -->

3. Poststratification & Raking 3.1 Poststratification

# Poststratification - 2

- Poststratification estimator of a total is defined as

$$
\hat{T}_{yPS} = \sum_{\gamma=1}^{G} N_\gamma \frac{\hat{t}_{y\gamma}}{\hat{N}_\gamma}
$$

  where
  - $N_\gamma$: the population count (aka a control or control total) for weighting poststratum $\gamma$
  - $\hat{t}_{y\gamma} = \sum_{s_\gamma} d_i y_i$: the estimated total of $y$ in weighting class (or poststratum) $\gamma$ based on input weights
  - $s_\gamma$: set of sample units in poststratum $\gamma$
  - $\hat{N}_\gamma = \sum_{s_\gamma} d_k$: estimated population size of poststratum $\gamma$ based on the input weights
  - $G$: total number of poststrata

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 15 / 43

<!-- page 16 -->

3. Poststratification & Raking 3.1 Poststratification

# Poststratification - 3

* The implied final weight for unit $i$ in poststratum $\gamma$
  $$
  w_i = d_i \frac{N_\gamma}{\hat{N}_\gamma} \qquad (14.4)
  $$
  where $g_i = N_\gamma / \hat{N}_\gamma$ is the poststratification adjustment factor.
* $g_i$ is called a $g$-weight in generic equation $w_i = d_i g_i$.
* The PS estimator can be written as $\hat{T}_{yPS} = \sum_{i \in s} w_i y_i$, i.e., a weighted sum of the data values.
* Weighting classes are called poststrata because they are applied after the sample is selected
* Crosses of variables can be used: $(\text{age group}) \times (\text{sex})$

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 16 / 43

<!-- page 17 -->

3. Poststratification & Raking 3.1 Poststratification

# Model for Poststratification

- PS estimator is special case of GREG with the least squares distance function in (14.2).
- Model that naturally accompanies $\hat{T}_{yPS}$ is one where units have a common mean and variance within a poststratum:
$$
E_M(y_i) = \beta_\gamma \quad Var_M(y_i) = \sigma_\gamma^2 \qquad (14.5)
$$
- The $x$ vector for a unit has $G$ components, each containing a 0/1 indicator for whether or not a unit is in a particular poststratum.

**See VDK Examples 14.2 and 14.3 in Class12Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 17 / 43

<!-- page 18 -->

3. Poststratification & Raking 3.2 Raking

# 3.2 Raking

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 18 / 43

<!-- page 19 -->

3. Poststratification & Raking 3.2 Raking

# Raking

- In PS example, all weighting classes formed by cross of age group and Hispanicity are used as poststrata.
  - Population control needed for each class
  - Minimum $n$ requirements usually imposed; otherwise unstable $\hat{N}_\gamma$.
- In raking, only marginal (e.g., age group and Hisp) control counts needed.
  - Especially relevant when only marginal counts are available
- Raked estimator is also associated with a linear model. Model in a two-variable raking problem is:

$$E_M(y_i) = \mu + \alpha_j + \beta_k \quad Var_M(y_i) = \sigma^2 \tag{14.6}$$

- PS model for mean that naturally goes with cross of two variables is $E_M(y_i) = \mu + \alpha_j + \beta_k + (\alpha\beta)_{jk}$
  $\rightarrow$ Raking model has main effects only and fewer parameters.

**See Example 14.4 in Class12Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 19 / 43

<!-- page 20 -->

4. General Regression Estimation

# 4. General Regression Estimation

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 20 / 43

<!-- page 21 -->

4. General Regression Estimation

# General Regression Estimation (GREG)

$$
\begin{aligned}
\hat{T}_{yGREG} &= \hat{t}_y + \left(\mathbf{t}_x - \hat{\mathbf{t}}_x\right)^T \hat{\mathbf{B}} \\
&= \sum_{i \in s} \left[1 + \left(\mathbf{t}_x - \hat{\mathbf{t}}_x\right)^T \left(\mathbf{X}^T \mathbf{D} \mathbf{V}^{-1} \mathbf{X}\right)^{-1} \mathbf{x}_i / v_i\right] d_i y_i
\end{aligned}
$$

where

- $\hat{t}_y = \sum_s d_i y_i$: estimator of total based on input weights
- $\mathbf{t}_x = (t_{x1}, \cdots, t_{xp})^T$: $p \times 1$ vector of population (or control) totals of the $p$ auxiliary variables
- $\hat{\mathbf{t}}_x = \sum_s d_i \mathbf{x}_i$: estimate of totals of $x$'s based on the $d_i$ weights
- $\mathbf{x}_i$: $p \times 1$ vector of auxiliary values for the sample unit $i$

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 21 / 43

<!-- page 22 -->

4. General Regression Estimation

# GREG and Calibration Estimation - 1

- $\mathbf{D} = diag(d_i)$: $n \times n$ diagonal matrix of input weights
- $\mathbf{X} = \begin{pmatrix} \mathbf{x}_1^T \\ \mathbf{x}_2^T \\ \vdots \\ \mathbf{x}_n^T \end{pmatrix}$ : $n \times p$ matrix of auxiliaries for the $n$ sample units
- $\hat{\mathbf{B}} = \left(\mathbf{X}^T \mathbf{D} \mathbf{V}^{-1} \mathbf{X}\right)^{-1} \mathbf{X}^T \mathbf{D} \mathbf{V}^{-1} \mathbf{y}$
- $\mathbf{y} = (y_1, \cdots, y_n)^T$: vector of $y$'s for the $n$ sample units
- $\mathbf{V} = diag(v_i)$: $n \times p$ matrix of variance parameters in underlying linear model
- GREG can be formulated using a block-diagonal or some other non-diagonal covariance matrix, but this is seldom done in practice.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 22 / 43

<!-- page 23 -->

4. General Regression Estimation

# GREG and Calibration Estimation - 2

* The $p \times 1$ vector, $\hat{\mathbf{B}}$, estimates slope in model $y_i = \mathbf{x}_i^T \boldsymbol{\beta} + \epsilon_i$ where $\epsilon_i$ have mean 0 and variance $v_i$
* In the case of *srswor* design and base weights, $\hat{\mathbf{B}}$ reduces to $\left(\mathbf{X}^T\mathbf{X}\right)^{-1}\mathbf{X}^T\mathbf{y}$
* If model errors were all 0, then $\hat{\mathbf{B}} = \boldsymbol{\beta}$ and GREG reduces to $\mathbf{t}_x^T\boldsymbol{\beta}$, which is also population sum of the $y$'s ($= T_y$).
* In that case, $y$ for each unit in population can be predicted without error as $\mathbf{x}_i^T\boldsymbol{\beta}$, and the GREG would be exactly equal to $T_y$ in every sample.
  $\rightarrow$ The better the predictor that $x$ is of $y$, the smaller the variance of the GREG.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 23 / 43

<!-- page 24 -->

4. General Regression Estimation

# GREG and Calibration Estimation - 3

* An estimated total for a $y$ is calculated as
  $$
  \hat{T}_{yGREG} = \sum_s w_i y_i
  $$
  * $w_i = d_i g_i$
  * $g$-weight, $g_i = \left[ 1 + \left( \mathbf{t}_x - \hat{\mathbf{t}}_x \right)^T \left( \mathbf{X}^T \mathbf{DV}^{-1} \mathbf{X} \right)^{-1} \mathbf{x}_i / v_i \right]$
* The final $w_i$ weights do not depend on any analysis variables ($y$'s). $\rightarrow$ Same set of weights can be used for any estimated total.
* Estimates of many quantities, like means, model parameters, and quantiles, depend on estimating totals. For example, a mean would be estimated as
  $$
  \hat{\bar{y}}_{GREG} = \sum_s w_i y_i / \sum_s w_i
  $$

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 14 $\qquad$ 24 / 43

<!-- page 25 -->

4. General Regression Estimation

# Practical considerations in using GREGs - 1

* Population totals of the auxiliaries should ideally be true values and known without error.
  * If population $x$ totals are incorrect, then either $\mathbf{t}_x - \hat{\mathbf{t}}_x$ will not estimate 0, or $\mathbf{t}_x - \hat{\mathbf{t}}_x$ will not give the correct coverage adjustment.
  * But, in some surveys, it may be desirable to use estimates of the $\mathbf{t}_x$ controls from a larger or higher quality survey than the one you are weighting. True if there are $x$'s that are very predictive of analysis variables, but only pop estimates from another survey available.
* The estimated auxiliary totals, $\hat{\mathbf{t}}_x = \sum_s d_i \mathbf{x}_i$, should be measured in same way in population as in the survey.
  * Suppose one of the $x$'s is household annual income. If a census and the survey collect income using different question wordings, this non-comparability could affect $\mathbf{t}_x - \hat{\mathbf{t}}_x$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 25 / 43

<!-- page 26 -->

4. General Regression Estimation

# Practical considerations in using GREGs - 2

- An association exists between outcome and auxiliary variables and is "effectively" represented by a linear model.
  - Although a close association between $x$'s and the analysis variables is not necessary for the GREG to be approximately unbiased, a model that fits well will yield lower variances.
  - Some formal model-fitting is an important step in weighting.
- The fact that calibration adjustments $\{g_i\}_{i=1}^n$ are sample-dependent needs to be accounted for in variance estimation.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 26 / 43

<!-- page 27 -->

4. General Regression Estimation

# Models behind some Textbook Estimators

VDK Table 14.4. Examples of Estimators, Sample Designs and Models

| Estimator | Design | Estimated total | Model mean | Model variance |
| :--- | :--- | :--- | :--- | :--- |
| Expansion | *srswor* | $\hat{t}_0 = N\bar{y}_s$ | $E_M(y) = \mu$ | $Var_M(y) = \sigma^2$ |
| Ratio | *srswor* | $\hat{t}_R = N\bar{y}_s \frac{\bar{x}_U}{\bar{x}_s}$ | $E_M(y) = \beta x$ | $Var_M(y) = \sigma^2 x$ |
| Poststratified | *srswor* | $\hat{t}_{yPS} = \sum_{g=1}^G N_g \left(\hat{t}_{yg} / \hat{N}_g\right)$ | $E_M(y_i) = \beta_g$ | $Var_M(y_i) = \sigma_g^2$ |
| Stratified expansion | *stsrswor* | $\hat{t}_{y,st} = \sum_h N_h \bar{y}_{hs}$ | $E_M(y_{hi}) = \mu_h$ | $Var_M(y_{hi}) = \sigma_h^2$ |
| Stratified combined ratio | *stsrswor* | $\hat{t}_{CR} = \hat{t}_{y,st} \frac{N\bar{x}_U}{\sum_h N_h \bar{x}_{hs}}$ | $E_M(y_{hi}) = \beta x_{hi}$ | $Var_M(y_{hi}) = \sigma^2 x_{hi}$ |
| Stratified separate ratio | *stsrswor* | $\hat{t}_{SR} = \sum_h N_h \bar{y}_{hs} \frac{\bar{x}_{Uh}}{\bar{x}_{hs}}$ | $E_M(y_{hi}) = \beta_h x_{hi}$ | $Var_M(y_{hi}) = \sigma_h^2 x_{hi}$ |
| Stratified combined regression | *stsrswor* | $\hat{t}_{CL} = \hat{t}_{y,st} + N\hat{B}(\bar{x}_U - \bar{x}_{st})$ with $\bar{x}_{st} = \sum_h N_h \bar{x}_{hs}/N, \hat{B} = \tilde{s}_{xy}/\tilde{s}_x^2$ $\tilde{s}_{xy} = \sum_h \frac{N_h}{n_h} \sum_{s_h} (x_{hi} - \bar{x}_{hs})(y_{hi} - \bar{y}_{hs})$ $\tilde{s}_x^2 = \sum_h \frac{N_h}{n_h} \sum_{s_h} (x_{hi} - \bar{x}_{hs})^2$ | $E_M(y_{hi}) = \alpha + \beta x_{hi}$ | $Var_M(y_{hi}) = \sigma^2$ |
| Stratified separate regression | *stsrswor* | $\hat{t}_{SL} = \sum_h N_h \left[\bar{y}_{hs} + \hat{B}_h (\bar{x}_{Uh} - \bar{x}_{hs})\right]$ | $E_M(y_{hi}) = \alpha_h + \beta_h x_{hi}$ | $Var_M(y_{hi}) = \sigma_h^2$ |

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 27 / 43

<!-- page 28 -->

4. General Regression Estimation

# Using Both Quantitative and Qualitative Auxiliaries

**See Example Quan Qual in Class12Lab.pdf**

Sunghee Lee (U of Michigan)

Prac Tools Ch. 14

<!-- page 29 -->

4. General Regression Estimation

# GREG Example

**See Example GREG in Class12Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 29 / 43

<!-- page 30 -->

4. General Regression Estimation

# Covariate Selection

* Selecting covariates to use in calibration is difficult because the weights can be used for many response variables.
* In practice, weights are often computed without examining any analysis variables at all.
* Divorcing weighting from analysis is common in one-time surveys.
* General rules-of-thumb may be used to select covariates or a simple procedure like poststratification may be used.
* In continuing surveys that are periodically repeated, there is an opportunity to use prior data to guide weight creation.
* Regardless of circumstances, looking at how poststratification, raking, GREG, etc. perform for some important estimates is always good practice.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 30 / 43

<!-- page 31 -->

5. Weight Variability

# 5. Weight Variability

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 31 / 43

<!-- page 32 -->

5. Weight Variability

# Reasons for Varying Weights

1. Varying selection probabilities as in *pps* sampling or stratified sampling with different sampling rates in the strata
2. Over- or under-sampling groups of units based on domain membership
3. Unequal response rates (and/or rates of unknown eligibility) in different subgroups leading to unequal weight adjustments
4. Calibration to auxiliaries to reduce variances or correct for frame coverage errors.

- In some cases, varying weights may be designed into the sample, as in (1) and (2) above.
- In other applications, varying weights are needed to correct for potential nonresponse bias or differential under-coverage as in (3) and (4).
- However, highly differential weights can increase the variances of estimates even if they decrease bias.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 32 / 43

<!-- page 33 -->

5. Weight Variability

# Design Effect Due to Weighting - 1

Kish (1965, 1992) introduced a ”design effect due to weighting” which is equal to one plus the relvariance of the sample weights:

$$
\begin{aligned}
deff_w &= 1 + relvar(w) \\
&= 1 + \frac{\sum_s (w_i - \bar{w})^2 / n}{\bar{w}^2} \qquad (14.8)
\end{aligned}
$$

where $\bar{w} = \frac{\sum_s w_i}{n}$

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 33 / 43

<!-- page 34 -->

5. Weight Variability

# Design Effect Due to Weighting - 2

- Widely used, possibly over-used, measure that is interpreted as the increase in variance of an estimator due to having weights that are not all the same.
- Kish also writes $deff_w$ as $1 + L$ with $L$ being inflation above the variance that would be obtained with a self-weighting sample.
- Practitioners often compute $deff_w$ while developing final weights, and use it to make a judgment about whether any weights should be modified because they are "too variable".
- No universally accepted rules-of-thumb to gauge when $deff_w$ is "large."
- $deff_w$ of 1.5 or larger frequently lead to some action being taken.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 34 / 43

<!-- page 35 -->

5. Weight Variability

# Derivation of Kish $deff_w$ Measure - 1

* Consider an *stsrswor* with $n_h$ sample units allocated to stratum $h$.
* $deff_w$ is ratio of variance of stratified expansion estimator, $y_{st} = \sum_{h=1}^H W_h \bar{y}_{sh}$, with unequal weighting to the variance of the same estimator with proportional allocation, assuming stratum variances are equal:

$$deff_w = \frac{V(\bar{y}_{st}) \text{ with non-proportional allocation}}{V(\bar{y}_{st}) \text{ with proportional allocation}}$$

* Key assumption is that a proportional allocation is optimal for the study.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 35 / 43

<!-- page 36 -->

5. Weight Variability

# Derivation of Kish $deff_w$ Measure - 2

* $deff_w$ may be useful if equal weighting is appropriate, i.e., stratum variances are equal or, at least, not expected to be extremely different.
* May be true in some household surveys.
* $deff_w$ is largely irrelevant in many applications:
  * Establishment or institution surveys where variances are known to differ among strata
  * Household surveys where different subgroups are intentionally sampled at different rates to obtain desired sample sizes
  * Different nonresponse adjustments are needed to reduce bias (even though the initial sample may be self-weighting).
* Design effect due to Spencer (2000) accounts for relationship of $y$ to an $x$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 36 / 43

<!-- page 37 -->

5. Weight Variability 5.1 Bounding Weights with Quadratic Programming

# 5.1 Bounding Weights with Quadratic Programming

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 37 / 43

<!-- page 38 -->

5. Weight Variability 5.1 Bounding Weights with Quadratic Programming

# Quadratic Programming (QP)

A QP problem with constraints has the following general form:

* Find the vector $\mathbf{k}$ to minimize $\Phi = \frac{1}{2} \mathbf{k}^T \Sigma \mathbf{k} - \mathbf{z}^T \mathbf{k}$
* Subject to the constraints $\mathbf{C}^T \mathbf{k} \geq \mathbf{c}_0$
  where $\Sigma$ is a symmetric matrix of constants and $\mathbf{z}$ is a vector of constants.

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 38 / 43

<!-- page 39 -->

5. Weight Variability   5.1 Bounding Weights with Quadratic Programming

# QP Applied to Weight Calculation - 1

* Find the set of weights $\{w_k\}_{k\in s}$ that minimizes $\dfrac{\sum_s (w_k - d_k)^2}{d_k}$
* Subject to $\sum_s w_k \mathbf{x}_k = \mathbf{t}_x$ and $L \ge w_k \ge U$.

  To see that this fits into the general QP mold, first note that

$$\begin{aligned}
\sum_s (w_k - d_k)^2 / d_k &= \mathbf{w}^T \mathbf{D}^{-1} \mathbf{w} - 2 \mathbf{d} \mathbf{D}^{-1} \mathbf{w} + \mathbf{d} \mathbf{D}^{-1} \mathbf{d} \\
&= \mathbf{w}^T \mathbf{D}^{-1} \mathbf{w} - 2 \mathbf{1}_n^T \mathbf{w} + \sum_s d_k
\end{aligned}$$

  with $\mathbf{D} = diag(d_k)$ and $\mathbf{w} = (w_1, \cdots, w_n)^T$.

* The weight formulation corresponds to the general problem with $\mathbf{k} = \mathbf{w}, \mathbf{z} = 2 \times \mathbf{1}_n$, and $\Sigma = \mathbf{D}^{-1}$.

Sunghee Lee (U of Michigan)   Prac Tools Ch. 14   39 / 43

<!-- page 40 -->

5. Weight Variability   5.1 Bounding Weights with Quadratic Programming

# QP Applied to Weight Calculation - 2

- The sum of input weights, $\sum_s d_k$, is a constant, given the sample.
- Solving the weight calibration problem is equivalent to minimizing
$$\Phi = \mathbf{w}^T \mathbf{D}^{-1} \mathbf{w} - 2\mathbf{1}_n^T \mathbf{w}$$
- The bounds on the weights fit the general form, $\mathbf{C}^T \mathbf{k} \ge \mathbf{c}_0$, with
$$\mathbf{C} = \begin{pmatrix} \mathbf{X}_{\mathbf{S}} \\ \mathbf{I}_{\mathbf{n}} \\ -\mathbf{I}_{\mathbf{n}} \end{pmatrix} \text{ and } c_0 = \begin{pmatrix} \mathbf{t}_{\mathbf{X}} \\ L\mathbf{1}_{\mathbf{n}} \\ -U\mathbf{1}_{\mathbf{n}} \end{pmatrix}$$
where $\mathbf{X}_s$ is the $n \times p$ matrix of auxiliaries for the sample units and $\mathbf{I}_{\mathbf{n}}$ is an $n \times n$ identity matrix.
- The bounds $L \ge w_k \ge U$ are different from the bounds, $L \ge w_k / d_k \ge U$, used for the GREG weights in VDK 14.3.2.

**See VDK Example 14.7 in Class13Lab.pdf**

Sunghee Lee (U of Michigan)   Prac Tools Ch. 14   40 / 43

<!-- page 41 -->

5. Weight Variability 5.2 Weights Trimming

# 5.2 Weights Trimming

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 41 / 43

<!-- page 42 -->

5. Weight Variability   5.2 Weights Trimming

# Weights Trimming and Redistribution - 1

The form of weight trimming that may be most common can be summarized as follows:

1. Set upper and lower bounds on weights. One method used in National Assessment of Educational Progress (NAEP) is to trim any weight greater than 3.5 times the median weight back to $3.5w_{med}$.
2. Any weight greater than upper bound (or less than lower bound) is reset to the bound. That is,
$$w_{k,trim} = \begin{cases} U & w_k \geq U \\ w_k & L < w_k < U \\ L & w_k \leq L \end{cases}$$
Define $\{w_{k,trim}\}_{k \in s}$ to be the set of trimmed weights.

Sunghee Lee (U of Michigan)   Prac Tools Ch. 14   42 / 43

<!-- page 43 -->

5. Weight Variability 5.2 Weights Trimming

# Weights Trimming and Redistribution - 2

3. Determine $K = \sum_{k \in s} |w_k - w_{k,trim}|$, i.e., the net amount of weight lost by trimming.
4. Distribute $K$ evenly among the units whose weights were not trimmed.
5. Repeat the steps (2) – (4) until no weights fail the bounds check.

**See VDK Example 14.9 in Class13Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 14 43 / 43
