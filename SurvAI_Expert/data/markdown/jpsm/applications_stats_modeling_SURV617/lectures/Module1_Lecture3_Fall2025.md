---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module1_Lecture3_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "Applications of Statistical Modeling:"
original: "applications_stats_modeling_SURV617/lectures/Module1_Lecture3_Fall2025.pdf"
pages: 18
sha256: "036ad2bcc2a5c7c118a83ba2afc4b2d91ff43d314ec5d1ac46783d1084d0493c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:41"
---

<!-- page 1 -->

# Applications of Statistical Modeling:
## Module #1, Lecture #3

### Multilevel Modeling Application:
### Interviewer Effects in the European Social Survey

Instructor: Brady T. West

Email: [[email]](mailto:[email])

1

<!-- page 2 -->

# Lecture Overview

* Today, we’ll begin with a review of interviewer effects; some of this may be new, and you may have seen some of it in other classes
* We’ll then turn to applications involving the European Social Survey (ESS) data, estimating interviewer variance for selected survey variables and interpreting the results
* We’ll also discuss how to fit the models using selected software procedures

2

<!-- page 3 -->

# Interviewer Effects

* Classically viewed as a type of measurement error specific to an interviewer
* Determinants of Intra-Interviewer Correlations (“rho-int”); see West and Blom (2017, JSSAM)
  * Computerization (ACASI/SAQs); correlations expected to be negligible
  * Telephone (smaller) vs. Face-to-face (larger)
  * Items? Open vs. closed, or Factual vs. attitudinal; not many differences
  * Controlled feedback and probing...
  * Interviewer experience / training? Interviewer behaviors / non-verbal signs?
  * Demographics of interviewers and respondents
  * Different recruitment of different types of cases (West and Olson, 2010); argument against measurement error hypothesis

3

<!-- page 4 -->

# Variance Inflation

* As the sizes of workloads increase, effective sample size is reduced, even for small values of intra-interviewer correlations
* Workload could be reduced by hiring more interviewers, but...
* Wouldn’t that cost more?
* Better to reduce rho-int as much as possible through training, supervision, and good questionnaire design principles

4

<!-- page 5 -->

# Multilevel Modeling Approaches

* In recent years, methodological studies have taken advantage of multilevel modeling techniques to study interviewer variance
* Effects of individual interviewers $j$ ($M_j$) on survey measures $y$ for respondent $i$ are treated as **random**:

$$y_{ij} = X_i + M_j + e_{ij}$$

$$M_j \sim N(0, \sigma_{\text{int}}^2)$$

$$e_{ij} \sim N(0, \sigma^2)$$

* In most applications, variance in the true values ($X_i$) and the random errors ($e_{ij}$) are combined into the error variance term, and a fixed intercept is used

5

<!-- page 6 -->

# Multilevel Modeling Approaches

* **Advantages:**
  - Capable of handling <u>unbalanced workloads</u> across interviewers (some models require equal workloads!)
  - Capable of including interviewer-specific covariates in an effort to explain variance across interviewers
  - Capable of allowing interviewer variance to vary depending on the type of interviewer (e.g., CAPI vs. CATI)
  - Models with **crossed random effects** enable studies of the contributions of areas and interviewers to overall variance (e.g., O’Muircheartaigh and Campanelli, 1998)
    * Example: interviewers work in multiple randomly sampled PSUs, and we wish to disentangle interviewer and PSU effects

6

<!-- page 7 -->

# Multilevel Modeling Approaches

* Assuming that interviewers were randomly sampled from some hypothetical super-population of interviewers (the assumption needed to treat effects as random), we can compute “rho-int” (the intra-interviewer correlation) for a given survey measure as follows:

$$\rho_{\text{int}} = \sigma_{\text{int}}^2 / \sigma_y^2 = \sigma_{\text{int}}^2 / (\sigma_X^2 + \sigma_{\text{int}}^2 + \sigma_e^2) = \sigma_{\text{int}}^2 / (\sigma_{\text{int}}^2 + \sigma_\varepsilon^2)$$

* We can thus indirectly test whether rho-int is zero by performing appropriate tests for the interviewer variance component ($\sigma_{\text{int}}^2$)

7

<!-- page 8 -->

# Interviewer Effects in the ESS (Refer to the R Markdown file)

* We will now consider examples of estimating interviewer effects in the European Social Survey (ESS) Data, to illustrate multilevel modeling and diagnostics
* We will begin by using multilevel models to estimate the interviewer variance components for selected variables
* We will then try to explain any interviewer variance by using the interviewer-specific response rates (which could indicate interviewer-specific nonresponse bias)
* We’ll focus on R and go through the code and output in great detail; Stata code is on the following slides
* We’ll then consider a random coefficient model

8

<!-- page 9 -->

# Random Intercept Model: Stata Code

```stata
mixed pplhlp || intnum: , variance reml
* note: mixture-based LRT is automatic!
predict int_eblups, reffects
collapse int_eblups, by(intnum)
qnorm int_eblups, ytitle(EBLUPs of Random
  Interviewer Effects)
predict st_resid, rstandard
qnorm st_resid
* note: add interviewer-level covariate
mixed pplhlp int_rr || intnum: , variance
  reml
```

9

<!-- page 10 -->

# Random Coefficient Model: Stata Code

```stata
mixed pplhlp trstplc ||
  intnum: trstplc,
  covariance(unstruct)
  variance reml
```

LRT needs to be done manually. Only automatic for random intercept models.

10

<!-- page 11 -->

# Three Questions!

Suppose that we have $n$ groups/clusters of units:

1. Assuming no other covariates, what are the potential options for modeling the effects of the clusters?
2. What is the difference between an ordinary regression model and a multilevel regression model?
3. What if we have covariates both for Level 1 and Level 2?

11

<!-- page 12 -->

# Ordinary versus Multilevel Regression

* Ordinary regression: a reference category and $n-1$ indicators
  - Mean structure changed
* Multilevel regression: $n$ indicators
  - Variance structure changed
  - Better for many groups and small sizes
  - Flexible to expand
  - Borrow information across groups: **partial pooling**

12

<!-- page 13 -->

# Partial Pooling without Predictors:

* Complete pooling—excluding a group indicator $y_{ij} = \mu_0 + \epsilon_{ij}$
* No pooling—estimating separate models with each group $j = 1, \dots, n$, $y_{ij} = \mu_{0j} + \epsilon_{ij}$
* Partial pooling-multilevel model: $y_{ij} = \mu_{0j} + \epsilon_{ij}, \mu_{0j} \sim N(0, \sigma_0^2)$

13

<!-- page 14 -->

# Partial-pooling Estimates

* Weighted average between unpooled estimate $\bar{y}_j$ and the completely pooled estimate $\bar{y}_{all}$
* Capture unit and group-level variation

$$
\hat{\mu}_{0j}^{multilevel} \approx \frac{\frac{n_j}{\sigma^2} \bar{y}_j + \frac{1}{\sigma_0^2} \bar{y}_{all}}{\frac{n_j}{\sigma^2} + \frac{1}{\sigma_0^2}}
$$

* when the group size $n_j$ is large, or the between-group variance $\sigma_0^2$ is large, $\hat{\mu}_{0j}^{multilevel}$ will be close to $\bar{y}_j$
* when the group size $n_j$ is small, or the between-group variance $\sigma_0^2$ is small, $\hat{u}_{0j}^{multilevel}$ will be close to $\bar{y}_{all}$

14

<!-- page 15 -->

# Adding Predictors

* Multilevel model with random intercepts and slopes:
$$y_{ij} = \alpha_i + \beta_i x_{ij} + \epsilon_{ij}$$
$$\alpha_i = \gamma_0^\alpha + \gamma_1^\alpha u_i + \gamma_i^\alpha$$
$$\beta_i = \gamma_0^\beta + \gamma_1^\beta u_i + \gamma_i^\beta$$

* Combine as:
$$y_{ij} = \gamma_0^\alpha + \gamma_1^\alpha u_i + \gamma_0^\beta x_{ij} + \gamma_1^\beta u_i x_{ij}$$
$$+ \gamma_i^\alpha + \gamma_i^\beta x_{ij} + \epsilon_{ij}$$

15

<!-- page 16 -->

# Panel Surveys with Complex Sample Designs

* Consider panel surveys with a complex *initial* sample designs (stratification, cluster sampling, weighting)
* Repeatedly measure the initially sampled units at multiple follow-up waves
* Next week, we will introduce design-based and model-based approaches to account for:
  – Correlation of repeated measurements
  – Complex sampling features
  – Different patterns of nonresponse

16

<!-- page 17 -->

# Some Final Thoughts

* Importantly, we would make the same inferences regardless of the software used
* “Automatic” mixture-based LRTs of variance components and intra-interviewer correlations are generally available, <u>for random intercept models</u>
* Some amount of work may be required for diagnostics in each package, **but it is important to always consider them**

17

<!-- page 18 -->

# Your Analysis Projects

* **Be creative!** Do some data exploration, and try to find some interesting patterns in your data...
* Try a random coefficient model! Not a lot of research considers between-cluster variance in regression coefficients...important for longitudinal data
* Try to explain variance in the residuals and the random effects! Consider aggregating L1 variables...
* Carefully consider model diagnostics!
* Be <u>**careful**</u> and <u>**clear**</u> with your interpretations

18
