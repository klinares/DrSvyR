---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_18"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 18.pdf"
pages: 36
sha256: "eeb765517404855805953a749be3945f0d891869cf1acf55ff53350bbe55e4ac"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:15"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference
## Chapter 18: Nonprobability Sampling

Sunghee Lee

---

Sunghee Lee (U of Michigan) | Prac Tools Ch. 18 | 1 / 36

<!-- page 2 -->

# Outline

1. 1. Background

2. 2. Approaches to Inference
   - 2.1 Quasi-Randomization
   - 2.2 Super Population
   - 2.3 Summary
   - 2.4 Exercise

---
Sunghee Lee (U of Michigan) | Prac Tools Ch. 18 | 2 / 36

<!-- page 3 -->

1. Background

# 1. Background

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 3 / 36

<!-- page 4 -->

1. Background

# History and Examples of Nonprobability Sampling

* Historical – Quota sampling
* Feasibility – Experiments in agricultural research and critical trials
* Historical Examples
  * 1936 Presidental Election poll (Landon vs. Roosevelt) with Literary Digest subscribers
  * 1948 Presidental Election polls (Dewey vs. Truman) by Gallup and Roper using quota samples
  * 2015 British parliamentary election polls and 2016 US Presidential Election polls (Probability sample $\rightarrow$ Nonprobability)
* Convenient sampling: Using volunteers; e.g., Literary Digest poll, Google Surveys, Opt-in Web panels
* Sample matching: Draw samples that match the population on a set of characteristics; e.g., Quota sampling
* Network sampling: E.g., Snowball sampling, Respondent driven sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 4 / 36

<!-- page 5 -->

1. Background

# Emergence of Nontraditional Electronic Data

* Because of declining response rates and ever increasing costs, pressures to find alternatives to expensive probability sampling have been building.

* Many of these non-traditional databases, despite being large, are not probability samples, but analysts want to project them to full finite populations.

**Data Sources**
* SURVEY
* Social Media
* Consumer Data
* Administrative Records

**Social Climate**

**Political Climate**

**Data Scope**
* Multiple Countries
* Single Country
* Selected Regions
* Multiple Subgroups

**Data Granularity & Continuity**
* Micro data
* Estimates
* Single cross-sectional
* Multiple cross-sectional
* Longitudinal

Pasek & Lee (2022 Fig 1)

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 5 / 36

<!-- page 6 -->

1. Background

# Fit For Purpose: Meeting Goals

* Relevance: Statistical information meets user needs?
* Accuracy: Statistical information correctly describes the phenomena it was designed to measure?
* Timeliness: Delay between the end of the reference period to which statistical information pertains and the date on which the information becomes available.
* Accessibility: Ease with which statistical information can be obtained.
* Coherence: Statistical information is logically consistent and can be brought together with information from other sources or different time periods?
* Interpretability: Availability of supplementary information (metadata) necessary to understand, analyze and utilize statistical information appropriately

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 6 / 36

<!-- page 7 -->

1. Background

# Problems with Nonprobability Samples

- Selection bias: Little known about the selection process
- Nonresponse: Not a problem only for probability samples
- Attrition: Esp. Web panels
- Measurement error: Mode effect; Motivated by incentives $\rightarrow$ satisficing
- Complex data structure
- Uncertain continutity (e.g., MTurk $\rightarrow$ CloudResearch)

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 7 / 36

<!-- page 8 -->

1. Background

# Selection Bias in Nonprobability Sampling - 1

From missing data point of view

For a population parameter vector $\mathbf{\Theta}$, its inference based on $\mathbf{Y}_s$ (data observed from a sample $s$) can be expressed in a likelihood function:

$$L(\mathbf{\Theta}; s, \mathbf{Y}_s) \propto \int pr(s|\mathbf{Y}; \mathbf{\Theta})f(\mathbf{y}; \mathbf{\Theta})\, d\mathbf{Y}_{\bar{s}},$$

where

- $pr(s|\mathbf{Y}; \mathbf{\Theta})$: Selection probability given $\mathbf{Y}$ determined by sample design; Sampling mechanism
- $f(\mathbf{Y}; \mathbf{\Theta})$: Estimation model for $\mathbf{Y}$
- $\mathbf{Y}_{\bar{s}}$: Nonsampled part of $\mathbf{Y}$ in the population
- $\mathbf{Y} = \mathbf{Y}_s + \mathbf{Y}_{\bar{s}} = (Y_1, Y_2, \cdots, Y_N)$

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 8 / 36

<!-- page 9 -->

1. Background

# Selection Bias in Nonprobability Sampling - 2

* $\mathbf{X}$: $n \times p$ matrix for sample design or covariate in estimation
* $\boldsymbol{\delta}_s = (\delta_1, \delta_2, \cdots, \delta_N)$: Vector a 1,0 indicator for a sample $s$
* $\boldsymbol{\Phi}$: Unknown parameter related to sampling
* Sampling mechanism:
  $$pr(\boldsymbol{\delta}_s | \mathbf{Y}, \mathbf{X}; \boldsymbol{\Phi})$$
* In probability sampling:
  $$pr(\boldsymbol{\delta}_s | \mathbf{Y}, \mathbf{X}; \boldsymbol{\Phi}) = pr(\boldsymbol{\delta}_s | \mathbf{X}) \text{ or } pr(\boldsymbol{\delta}_s) \text{ in SRS}$$
  $$\rightarrow L(\boldsymbol{\Theta}; s, \mathbf{Y}_s) \propto \int pr(\boldsymbol{\delta}_s | \mathbf{X}) f(\mathbf{Y} | \mathbf{X}; \boldsymbol{\Theta}) \, d\mathbf{Y}_{\bar{s}}$$
* In nonprobability sampling:
  $$pr(\boldsymbol{\delta}_s | \mathbf{Y}, \mathbf{X}; \boldsymbol{\Phi}) \neq pr(\boldsymbol{\delta}_s | \mathbf{X})$$
  $$\rightarrow L(\boldsymbol{\Theta}; s, \mathbf{Y}_s) \propto \int pr(\boldsymbol{\delta}_s | \mathbf{Y}, \mathbf{X}; \boldsymbol{\Phi}) f(\mathbf{Y} | \mathbf{X}; \boldsymbol{\Theta}) \, d\mathbf{Y}_{\bar{s}}$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 9 / 36

<!-- page 10 -->

2. Approaches to Inference

# 2. Approaches to Inference

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 10 / 36

<!-- page 11 -->

2. Approaches to Inference

# Nonprobability Sampling and Inference

* Design-based inference is "off the table" for nonprobability sampling
* Quasi-randomization approaches
  * Modelling $pr(\boldsymbol{\delta}_s|\mathbf{Y}, \mathbf{X}; \boldsymbol{\Phi})$
  * Ideally MAR, leading to $pr(\boldsymbol{\delta}_s|\mathbf{Y}, \mathbf{X}; \boldsymbol{\Phi}) = pr(\boldsymbol{\delta}_s|\mathbf{X}; \boldsymbol{\Phi})$
  * Psuedo-inclusion probabilities
  * Not targetted to a particular variable of interest
* Superpopulation approaches
  * Modelling $f(\mathbf{Y}|\mathbf{X}; \boldsymbol{\Theta})$
  * Calibration
  * Multilevel regression and poststratificaiton (MRP)
  * Targetted to a particular variable of interest
* We will denote $\mathbf{X}$ with $\mathbf{X}$ and $\mathbf{Z}$ to denote availability differences in some places but will use $\mathbf{X}$ for brevity

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 11 / 36

<!-- page 12 -->

2. Approaches to Inference

# Set-Up: Combine prob+nonprob samples and pop data

| | $i$ | $\boldsymbol{Y}$ | $\boldsymbol{X}$ | $\boldsymbol{Z}$ | $\pi$ |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Nonprob Sample** | $1$ | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| **Nonprob Sample** | $2$ | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| **Nonprob Sample** | $3$ | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| **Prob Sample** | $4$ | $?$ | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| **Prob Sample** | $5$ | $?$ | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| **Prob Sample** | $6$ | $?$ | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| **Non-Sampled** | $7$ | $?$ | $?$ | $\checkmark$ | $?$ |
| **Non-Sampled** | $8$ | $?$ | $?$ | $\checkmark$ | $?$ |
| **Non-Sampled** | $9$ | $?$ | $?$ | $\checkmark$ | $?$ |
| **Non-Sampled** | $10$ | $?$ | $?$ | $\checkmark$ | $?$ |
| **Non-Sampled** | $11$ | $?$ | $?$ | $\checkmark$ | $?$ |
| **Non-Sampled** | $12$ | $?$ | $?$ | $\checkmark$ | $?$ |
| **Non-Sampled** | $13$ | $?$ | $?$ | $\checkmark$ | $?$ |
| **Non-Sampled** | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ |
| **Non-Sampled** | $N$ | $?$ | $?$ | $\checkmark$ | $?$ |

$\boldsymbol{Y}, \boldsymbol{X}, \boldsymbol{Z}$: Random variables
$\pi$: Selection probability

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 12 / 36

<!-- page 13 -->

2. Approaches to Inference 2.1 Quasi-Randomization

## 2.1 Quasi-Randomization

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 13 / 36

<!-- page 14 -->

2. Approaches to Inference 2.1 Quasi-Randomization

# Set-Up: Pseudo-Weights

| $i$ | $\boldsymbol{Y}$ | $\boldsymbol{X}$ | $\boldsymbol{Z}$ | $\pi$ | $\pi_{np}$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | $\checkmark$ | $\checkmark$ | $\checkmark$ | ?/$\checkmark$ | $f(\pi_{np}|X, Z, \pi_p)$ |
| 2 | $\checkmark$ | $\checkmark$ | $\checkmark$ | ?/$\checkmark$ | $f(\pi_{np}|X, Z, \pi_p)$ |
| 3 | $\checkmark$ | $\checkmark$ | $\checkmark$ | ?/$\checkmark$ | $f(\pi_{np}|X, Z, \pi_p)$ |
| 4 | ? | $\checkmark$ | $\checkmark$ | $\checkmark$ | |
| 5 | ? | $\checkmark$ | $\checkmark$ | $\checkmark$ | |
| 6 | ? | $\checkmark$ | $\checkmark$ | $\checkmark$ | |
| 7 | ? | ? | $\checkmark$ | ? | |
| 8 | ? | ? | $\checkmark$ | ? | |
| 9 | ? | ? | $\checkmark$ | ? | |
| 10 | ? | ? | $\checkmark$ | ? | |
| 11 | ? | ? | $\checkmark$ | ? | |
| 12 | ? | ? | $\checkmark$ | ? | |
| 13 | ? | ? | $\checkmark$ | ? | |
| $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ | |
| $N$ | ? | ? | $\checkmark$ | ? | |

* Assumes a hidden selection mechanism for nonprob sample that is estimable with $\boldsymbol{X}, \boldsymbol{Z}$
* Generate weights that can be used for nonprob sample alone; or if $\boldsymbol{Y}$ available for prob sample, in combination with prob sample.
* No direct modeling of $\boldsymbol{Y}$ given $\boldsymbol{X}, \boldsymbol{Z}$

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 14 / 36

<!-- page 15 -->

2. Approaches to Inference   2.1 Quasi-Randomization

# Pseudo-Weights - 1

Estimating $pr(\boldsymbol{\delta}_s|\mathbf{X}; \boldsymbol{\Phi})$ with MAR

- $S_i$, $S_i^*$: 1,0 sampling indicator of the prob ($S_i$) and nonprob sample ($S_i^*$)

$$\begin{aligned}
pr(S_i^* = 1|\mathbf{x}_i) &= \frac{pr(\mathbf{x}_i|S_i^* = 1)pr(S_i^* = 1)}{pr(\mathbf{x}_i)} \\
&\propto \frac{pr(\mathbf{x}_i|S_i^* = 1)}{pr(\mathbf{x}_i|S_i = 1)}pr(S_i = 1|\mathbf{x}_i) \quad \text{through Baye's rule}
\end{aligned}$$

- Difficult to estimate $pr(\mathbf{x}_i|S_i = 1)$ and $pr(\mathbf{x}_i|S_i^* = 1)$
  $\rightarrow$ Use combined prob+nonprob sample with
  $C_i$: 1,0 indicator of nonprob case in the combined data

$$\frac{pr(\mathbf{x}_i|C_i = 1)}{pr(\mathbf{x}_i|C_i = 0)} \propto \frac{pr(C_i = 1|\mathbf{x}_i)}{pr(C_i = 0|\mathbf{x}_i)} = \frac{pr(C_i = 1|\mathbf{x}_i)}{1 - pr(C_i = 1|\mathbf{x}_i)}$$

$$\Rightarrow pr(S_i^* = 1|\mathbf{x}_i) \propto \frac{pr(C_i = 1|\mathbf{x}_i)}{1 - pr(C_i = 1|\mathbf{x}_i)}pr(S_i = 1|\mathbf{x}_i)$$

Sunghee Lee (U of Michigan)   Prac Tools Ch. 18   15 / 36

<!-- page 16 -->

2. Approaches to Inference
2.1 Quasi-Randomization

# Pseudo-Weights - 2

Pseudo-Weights, $w_i$

* When $\mathbf{X}$ contains all variables related to prob sample design, nonresponse and poststratification adjustments, $pr(S_i = 1|\mathbf{x}_i)$ is known
$$
\begin{aligned}
w_i &= \hat{pr}(S_i^* = 1|\mathbf{x}_i)^{-1} \\
&= \frac{1 - \hat{pr}(C_i = 1|\mathbf{x}_i)}{\hat{pr}(C_i = 1|\mathbf{x}_i)}\frac{1}{pr(S = 1|\mathbf{x}_i)}
\end{aligned}
$$
where $\hat{pr}(C_i = 1|\mathbf{x}_i)$ estimated from logistic regression

* Otherwise, $pr(S_i = 1|\mathbf{x}_i) = \tilde{w}_i^{-1}$ needs to be estimated (e.g., beta regression of $\mathbf{x}_i$ on $w_i$)
$$
w_i = \frac{1 - \hat{pr}(C_i = 1|\mathbf{x}_i)}{\hat{pr}(C_i = 1|\mathbf{x}_i)}\frac{1}{\hat{pr}(S = 1|\mathbf{x}_i)}
$$

Sunghee Lee (U of Michigan)
Prac Tools Ch. 18

<!-- page 17 -->

2. Approaches to Inference 2.1 Quasi-Randomization

# Pseudo-Weights - 3

Pseudo-Weights, $w_i$ (cont’d)

* Or estimate $pr(S_i^* = 1|\mathbf{x}_i)$ not conditioned on being in the combined sample
  * Run a weighted logistic regression of the combined sample with a weight of 1 for nonprobability cases and the probability sampling weight for probability sample cases $\rightarrow w_i = \hat{pr}(S_i^* = 1|\mathbf{x}_i)^{-1}$
* The models can include $\mathbf{Y}$, if available in prob and nonprob surveys
* For high-dimensional $\mathbf{X}$, consider reduction methods (e.g., LASSO, BART, Superlearner)

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 17 / 36

<!-- page 18 -->

2. Approaches to Inference   2.1 Quasi-Randomization

# Pseudo-Weights - 4

* For point estimates
  * If $Y$ avaialble only in nonprob, use $w_i$ (can also be normalized to the population size)
  * If $Y$ avaialble in both and if to use the combined sample, normalize weights
    * For nonprob cases: $\hat{w}_i = w_i C_{S^*}$, where
      $$C_{S^*} = \frac{n_{S^*}}{n_{S^*} + n_S} \frac{\sum I(C_i = 0)\tilde{w}_i}{\sum I(C_i = 1)\tilde{w}_i}$$
      (i.e., Weighted fraction of the nonprob sample equals to the unweighted fraction of the nonprob sample in the combined data)
    * For prob cases: $\hat{w}_i = \tilde{w}_i C_S$, where
      $$C_S = \frac{n_S}{n_{S^*} + n_S}$$

* For variance estimation
  * Jackknife estimator: treat nonprob as a single stratum and prob following its own design info

Sunghee Lee (U of Michigan)   Prac Tools Ch. 18   18 / 36

<!-- page 19 -->

2. Approaches to Inference 2.1 Quasi-Randomization

# Pseudo-Weights: Example, Lee (2006) - 1

* Nonprob Web sample ($s^W$):
* Prob ("Reference") sample ($s_R$):
* Outcome variables
  * $y_{blks}$: Warm feelings towards blacks
  * $y_{vote}$: Voting in 2000 presidential election
* Used various unconditional models (e.g., various sets of $\mathbf{X}$) for estimating $pr(S_i^* = 1|\mathbf{x}_i)$
* Created subclasses ($c$) based on $\hat{pr}(S_i^* = 1|\mathbf{x}_i)$
* Nonprob adjustment weight based on the subclasses:

$$
w_i = d_i^W f_c = d_i^W \frac{\sum_{k \in s_c^R} d_k^R / \sum_{k \in s^R} d_k^R}{\sum_{i \in s_c^W} d_i^W / \sum_{i \in s^W} d_i^W}
$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 19 / 36

<!-- page 20 -->

2. Approaches to Inference
2.1 Quasi-Randomization

# Pseudo-Weights: Example, Lee (2006) - 2

*Table 3. Composition of Propensity Score Models$^{\text{a}}$*

| Covariate | Propensity score models | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Demographic (*D*) | *D1* | | *D2* | | *D3* | |
| | All covariates | | Significant covariates | | Nonsignificant covariates | |
| | $y_{\text{blks}}$ | $y_{\text{vote}}$ | $y_{\text{blks}}$ | $y_{\text{vote}}$ | $y_{\text{blks}}$ | $y_{\text{vote}}$ |
| Age | $\surd$ | $\surd$ | $\surd$ | $\surd$ | | |
| Educ | $\surd$ | $\surd$ | $\surd$ | $\surd$ | | |
| $\dots\dots$ | | | | | | |
| Nondemographic (*N*) | *N1* | | *N2* | | *N3* | |
| | All covariates | | Significant covariates | | Nonsignificant covariates | |
| | $y_{\text{blks}}$ | $y_{\text{vote}}$ | $y_{\text{blks}}$ | $y_{\text{vote}}$ | $y_{\text{blks}}$ | $y_{\text{vote}}$ |
| Class | $\surd$ | $\surd$ | | $\surd$ | $\surd$ | |
| Work | $\surd$ | $\surd$ | | | $\surd$ | $\surd$ |
| $\dots\dots$ | | | | | | |
| Demographics and nondemographics (*A*) | *A1* | | *A2* | | *A3* | |
| | All covariates | | Significant covariates | | Nonsignificant covariates | |
| | $y_{\text{blks}}$ | $y_{\text{vote}}$ | $y_{\text{blks}}$ | $y_{\text{vote}}$ | $y_{\text{blks}}$ | $y_{\text{vote}}$ |
| | *D1* + *N1* | *D1* + *N1* | *D2* + *N2* | *D2* + *N2* | *D3* + *N3* | *D3* + *N3* |

$^{\text{a}}$ Included covariates are indicated by check marks.
Note: Propensity Model 4, not shown in the table, is the combination of *D1* and *N2*.

Sunghee Lee (U of Michigan)
Prac Tools Ch. 18

<!-- page 21 -->

2. Approaches to Inference $\quad$ 2.1 Quasi-Randomization

# Pseudo-Weights: Example, Lee (2006) - 3

*Table 5. Reference Sample, Unadjusted, and Propensity Score Adjusted Web Sample Estimates for $y_{blks}$ and $y_{vote}$*

| | $s^{W.ST}$ | | | | | $s^{W.HI}$ | | | | |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| | *estimate* | *bias* | *p.bias* | *se* | *p.se* | *estimate* | *bias* | *p.bias* | *se* | *p.se* |
| $y_{blks}$ | | | | | | | | | | |
| $(M = 2,000)$ | | | | | | | | | | |
| $y.R$ | 0.612 | | | 0.034 | | 0.612 | | | 0.034 | |
| $y.U$ | 0.636 | 0.024 | | 0.016 | | 0.675 | 0.064 | | 0.016 | |
| $y.D1$ | 0.623 | 0.012 | 52.4% | 0.022 | 38.1% | 0.638 | 0.026 | 58.6% | 0.032 | 100.0% |
| $y_{vote}$ | | | | | | | | | | |
| $(M = 1,971)$ | | | | | | | | | | |
| $y.R$ | 0.650 | | | 0.034 | | 0.650 | | | 0.034 | |
| $y.U$ | 0.715 | 0.065 | | 0.015 | | 0.817 | 0.167 | | 0.013 | |
| $y.D1$ | 0.709 | 0.059 | 9.7% | 0.022 | 46.7% | 0.724 | 0.074 | 55.7% | 0.031 | 138.5% |

Note: $y.R$: Reference sample estimate.
$y.U$: Unadjusted web sample estimate.
$y.D1$: Web sample estimate after PSA using Model $D1$.

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 18 $\quad$ 21 / 36

<!-- page 22 -->

2. Approaches to Inference
2.1 Quasi-Randomization

# Pseudo-Weights: Example, Lee (2006) - 4

*Fig. 4. Distributions of the web estimates by different propensity score adjustments*

Sunghee Lee (U of Michigan)
Prac Tools Ch. 18

*[Figure: This figure consists of two side-by-side box plot panels showing the distributions of web estimates for "Warm feelings towards blacks" (Panel A, y-axis from 0.50 to 0.80) and "Voting participation" (Panel B, y-axis from 0.5 to 0.9). Both panels compare six different estimation methods on the x-axis ($y.R$, $y.U$, $y.D1$, $y.N1$, $y.A1$, and $y.4$) against solid ($\bar{y}.R$) and dashed ($\bar{y}.U$) horizontal reference lines, demonstrating that the four propensity score-adjusted estimates ($y.D1$ through $y.4$) shift the distributions downward from the unadjusted estimate ($y.U$) toward the reference level ($y.R$).]*

<!-- page 23 -->

2. Approaches to Inference 2.2 Super Population

# 2.2 Super Population

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 23 / 36

<!-- page 24 -->

2. Approaches to Inference
2.2 Super Population

# Set-Up: Calibration

| $i$ | $\boldsymbol{Y}$ | $\boldsymbol{X}$ | $\boldsymbol{Z}$ | $\pi$ |
| :---: | :---: | :---: | :---: | :---: |
| 1 | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| 2 | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| 3 | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| 4 | ? | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| 5 | ? | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| 6 | ? | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| 7 | ? | ? | $\checkmark$ | ? |
| 8 | ? | ? | $\checkmark$ | ? |
| 9 | ? | ? | $\checkmark$ | ? |
| 10 | ? | ? | $\checkmark$ | ? |
| 11 | ? | ? | $\checkmark$ | ? |
| 12 | ? | ? | $\checkmark$ | ? |
| 13 | ? | ? | $\checkmark$ | ? |
| $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ |
| $N$ | ? | ? | $\checkmark$ | ? |

* $E_M(y_i | \boldsymbol{z}_i) = \boldsymbol{z}_i^T \boldsymbol{\beta}$
* $\hat{y}_i = \boldsymbol{z}_i^T \widehat{\boldsymbol{\beta}}$
* $\hat{t}_y = \sum_{i \in U} \hat{y}_i = \boldsymbol{t}_{Uz}^T \widehat{\boldsymbol{\beta}}$
* $\widehat{\overline{Y}} = \overline{\boldsymbol{Z}}_U^T \widehat{\boldsymbol{\beta}}$, where $\overline{\boldsymbol{Z}}_U = \frac{\boldsymbol{t}_{Uz}}{N}$
* Assumes $\boldsymbol{Y} \perp \mathbf{s} | (\boldsymbol{X}, \boldsymbol{Z})$
* Focus on using nonprob sample.
* If $\boldsymbol{t}_{Ux}$ is known, $\boldsymbol{x}$ can be incorporated.

Sunghee Lee (U of Michigan)
Prac Tools Ch. 18

<!-- page 25 -->

2. Approaches to Inference   2.2 Super Population

# Set-Up: Multilevel reg and poststrat (MRP)

| $i$ | $\boldsymbol{Y}$ | $\boldsymbol{X}$ | $\boldsymbol{Z}$ | $\pi$ |
| :---: | :---: | :---: | :---: | :---: |
| 1 | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| 2 | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| 3 | $\checkmark$ | $\checkmark$ | $\checkmark$ | $?/\checkmark$ |
| 4 | $f(Y|X,Z)$ | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| 5 | $f(Y|X,Z)$ | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| 6 | $f(Y|X,Z)$ | $\checkmark$ | $\checkmark$ | $\checkmark$ |
| 7 | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |
| 8 | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |
| 9 | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |
| 10 | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |
| 11 | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |
| 12 | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |
| 13 | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |
| $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ |
| $N$ | $f(Y|X,Z)$ | $f(X|Z)$ | $\checkmark$ | $?$ |

* Assumes $(\boldsymbol{X}|\boldsymbol{Z}) \perp \boldsymbol{s}$
* Assumes $f(X|Z)$ is correct
* Assumes $(\boldsymbol{Y}|\boldsymbol{X},\boldsymbol{Z}) \perp \boldsymbol{s}$
* Assumes $f(Y|X,Z)$is correct; useful for low-dimension $\boldsymbol{Y}$
* Allows use of the entire population data; requires rich $\boldsymbol{Z}$ to be plausible

Sunghee Lee (U of Michigan)   Prac Tools Ch. 18   25 / 36

<!-- page 26 -->

2. Approaches to Inference 2.2 Super Population

# Multilevel Regression & Poststrat. (MRP) - 1

* Poststratification with $h = 1, \cdots , H$ poststrata

$$\hat{y}^{PS} = \frac{\sum_h N_h \hat{y}_h}{\sum_h N_h}$$

* Estimate of $y$ at any superpopulation level $s$ (e.g., Michigan)

$$\hat{y}_s^{PS} = \frac{\sum_{h \in H_s} N_h \hat{y}_h}{\sum_{h \in H_s} N_h}$$

  * Issues with poststratification: Simple average of poststaratum means
  * What if we assume a SRS from a population within each poststratum?
    $\rightarrow$ Sparse cells; Unstable estimates
  * Model-based poststratification using multilevel regression and poststratification (MRP)
    * Bayesian hierarchical model to estimate for sparse poststrata
    * Average over poststrata, weighted by poststrata size in the population

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 26 / 36

<!-- page 27 -->

2. Approaches to Inference
2.2 Super Population

# MRP - 2

Consider $Y_i \sim BERNOULLI(\pi_i)$ (i.e., binary)

$K$ variables forming $h = 1, \cdots, H$ poststrata

$log \frac{\pi_i}{1 - \pi_i} = \beta_0 + \sum_{k=1}^K \beta_{j[i]}^k$, where

$j[i]$ denotes the category of $k^{th}$ variable $i$ unit belongs to

* Priors: $\beta_{j[i]}^k \stackrel{\text{iid}}{\sim} N(0, \sigma_b^2); \quad \sigma_b^2 \sim inv - \chi^2(\nu, \sigma_0^2)$
* Weak priors for $\beta_0$, $\nu$ and $\sigma_0^2$
* Use Markov Chain Monte Carlo to get draws from the posterior distribution of $\beta_0$, $\beta_{j[i]}^k$ and $\sigma_b^2$
* Use draw of $\beta_0$ and $\beta_{j[i]}^k$ to estimate $\hat{\mu}_h = \frac{\sum_{i \in h} \hat{\pi}_i}{n_h}$
* Aggregate $\hat{\mu}_h$ by $P_h$ (proportion of poststratum $h$ in the populaiton)

Sunghee Lee (U of Michigan)
Prac Tools Ch. 18

<!-- page 28 -->

2. Approaches to Inference 2.2 Super Population

# MRP: Example, Wang et al. (2015) - 1

Wang, W., Rothschild, D., Goel, S., & Gelman, A. (2015). Forecasting elections with non-representative polls. International Journal of Forecasting, 31(3), 980-991. (On Canvas)

* Predicting 2012 presidential election outcome from a panel of $n = 350,000$ Xbox users
* $Y_i \sim BERNOULLI(\pi_i)$: Obama over Romney
* Detailed and highly predictive covariates about voting behaviors: state, education, sex, age, race, party, ideaology, 2008 voting behavior
* Prediction model: $log \frac{\pi_i}{1 - \pi_i} = \beta_0 + \beta_{j[i]}^{state} + \beta_{j[i]}^{edu} + \beta_{j[i]}^{sex} + \beta_{j[i]}^{age} + \beta_{j[i]}^{race} + \beta_{j[i]}^{party} + \beta_{j[i]}^{ideaology} + \beta_{j[i]}^{lastvote} + interactions$
* Poststratification data: 2008 exit poll with n=101,638 (e.g., Proportion of female voters in Michigan who are politically liberal 18-29 year-old Hispanics and voted for Obama in 2008)

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 28 / 36

<!-- page 29 -->

2. Approaches to Inference 2.2 Super Population

# MRP: Example, Wang et al. (2015) - 2

Xbox Users vs. 2012 Exit Poll ("truth")

**Fig. 1.** A comparison of the demographic, partisan, and 2008 vote distributions in the Xbox dataset and the 2012 electorate (as measured by adjusted exit polls). As one might expect, the sex and age distributions exhibit considerable differences.

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 29 / 36

*[Figure: This multi-panel line plot compares demographic, partisan, and voting distributions between Xbox users (solid line) and the 2012 Exit Poll (dashed line), plotting percentage shares (0% to 100%) on the vertical axis against categories of Sex, Race, Age, Education, State, Party ID, Ideology, and 2008 Vote on the horizontal axis. The main pattern shows dramatic differences in sex and age—with the Xbox sample being overwhelmingly male and aged 18–29 compared to the more balanced exit poll—while distributions across race, state, and ideology are much more closely aligned.]*

<!-- page 30 -->

2. Approaches to Inference 2.2 Super Population

# MRP: Example, Wang et al. (2015) - 3

## Xbox Estimates vs. Pollster.com Estimates

**Fig. 2.** Daily (unadjusted) Xbox estimates of the two-party Obama support during the 45 days leading up to the 2012 presidential election, which suggest a landslide victory for Mitt Romney. The dotted blue line indicates a consensus average of traditional polls (the daily aggregated polling results from Pollster.com), the horizontal dashed line at 52% indicates the actual two-party vote share obtained by Barack Obama, and the vertical dotted lines give the dates of the three presidential debates. (For the interpretation of the references to colour in this figure legend, the reader is referred to the web version of this article.)

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 30 / 36

*[Figure: The line plot displays the percentage of "Two-party Obama Support" (on the y-axis, ranging from 35% to over 50%) over time (from Sep. 24 to Nov. 05 on the x-axis), comparing unadjusted "Xbox Raw" estimates (solid red line) against "Pollster.com" consensus polling averages (dotted blue line). The main pattern shows that while the Pollster.com estimates remain steady and close to the actual 52% election outcome (horizontal dashed line), the unadjusted Xbox estimates are much more volatile and consistently lower, dropping sharply to around 35% in mid-October between the presidential debates (marked by vertical dotted lines).]*

<!-- page 31 -->

2. Approaches to Inference 2.2 Super Population

# MRP: Example, Wang et al. (2015) - 4

MRP Xbox Estimates vs. Pollster.com Estimates

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 31 / 36

<!-- page 32 -->

2. Approaches to Inference
2.2 Super Population

# MRP: Example, Wang et al. (2015) - 5

**Secret Sauce!**
Xbox vs. 2012 Exit Poll ("truth") on Obama Vote Share

Sunghee Lee (U of Michigan)
Prac Tools Ch. 18

<!-- page 33 -->

2. Approaches to Inference 2.3 Summary

# 2.3 Summary

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 33 / 36

<!-- page 34 -->

2. Approaches to Inference 2.3 Summary

# Inference of Nonprobability Sample

- Models are necessary
- Quasi-randomization: Convenient; $w_i$ for any $y$
- Superpopulation: Model specific to each $y$
- Model specification and richness/relevance of covariates
- Variance estimation requires caution
- Fit for purpose

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 34 / 36

<!-- page 35 -->

2. Approaches to Inference 2.4 Exercise

# 2.4 Exercise

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 35 / 36

<!-- page 36 -->

2. Approaches to Inference 2.4 Exercise

# Pseudo-Weights

* Nonprobability sample data: COVID.csv
* Probability sample data: GSS.csv
* Population data: ACS.csv
* Variable of interest: Proportion of people who rated a statement, "I think politics influenced the development of the COVID-19 vaccines", with moderately agree and strongly agree.

  **See Exercise Nonprob in Class12Lab.pdf**

* What are options for this inference given the data availability?

Sunghee Lee (U of Michigan) Prac Tools Ch. 18 36 / 36
