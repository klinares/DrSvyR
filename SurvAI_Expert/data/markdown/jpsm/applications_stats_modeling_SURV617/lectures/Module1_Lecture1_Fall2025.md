---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module1_Lecture1_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "Applications of Statistical Modeling:"
original: "applications_stats_modeling_SURV617/lectures/Module1_Lecture1_Fall2025.pdf"
pages: 48
sha256: "e5d01ba6ff55c33dbdaa1ab2badcdac25eb2e6f93111834651b5cac549d30db8"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:39"
---

<!-- page 1 -->

# Applications of Statistical Modeling:
## Module #1, Lecture #1

### Course Overview;
### Multilevel Modeling Concepts

Instructor: Brady T. West
Email: [email]
Office: 4118 ISR (734-647-4615)

1

<!-- page 2 -->

# Course Overview

* Welcome to SURV 617 / SURVMETH 687!
* We will begin today with a detailed overview of the **course syllabus**, available on the Canvas site for the course

2

<!-- page 3 -->

# Prerequisites

* Applied statistical methods
  - Univariate and multivariate distributions
  - Multiple regression
  - Logistic regression
  - Model diagnostics/interpretation
* Maximum likelihood estimation, (weighted) least squares estimation
* Hypothesis testing
* Applied sampling methods

3

<!-- page 4 -->

# Given those prerequisites, you should remember that...

* Linear regression: suppose the continuous outcome $Y$ is measured for individual $i$,

$$
Y_i = \beta_0 + \beta_1 X_i + \epsilon_i, \quad \epsilon_i | X_i \sim_{iid} N(0, \sigma^2)
$$

* Logistic regression: the outcome is a binary variable with values 0/1

$$
\text{Log}\left(\frac{\Pr(Y_i = 1)}{\Pr(Y_i = 0)}\right) = \beta_0 + \beta_1 X_i
$$

4

<!-- page 5 -->

# Recommended Readings

* *Regression and Other Stories*, Andrew Gelman, Jennifer Hill, Aki Vehtari, 2020, Cambridge press.
  – Accessible at https://avehtari.github.io/ROS-Examples/
* *Data Analysis Using Regression and Multilevel/Hierarchical Models*, Andrew Gelman and Jennifer Hill, 2006, Cambridge press.

*Feel free to raise questions and comments about these readings at any point!*

5

<!-- page 6 -->

# The ESS Data

6

<!-- page 7 -->

# The European Social Survey (ESS) Data

* Data were collected in face-to-face interviews from a national sample of 1,703 adults in Belgium
* Variables include respondent ID, interviewer ID, and 22 variables measuring attitudes and opinions of the respondents on various topics
* Also included are final respondent weights (based on a complex sample design), along with interviewer-specific response rates (percentage scale)
* Available in SAS, SPSS, Stata, and R formats on Canvas

7

<!-- page 8 -->

# Key Motivating Issues

* Account for interviewer effects:
  - Measure interviewer variation
  - Include interviewer-specific covariates
* Adjust for complex sample design features
* Incorporate survey weights
* ***Key point**: observations are not independent and share some similar characteristics*
* Example of clustered data, where clusters are indicated by interviewer IDs

8

<!-- page 9 -->

# Multilevel Modeling

9

<!-- page 10 -->

# Multilevel Modeling

* **Multilevel models** are regression models that include **random effects** associated with either:
  - <u>**Randomly Sampled**</u> **Clusters** of units of analysis (in cross-sectional studies; e.g., census blocks)
  - <u>**Randomly Sampled**</u> **Subjects**, measured repeatedly (in longitudinal / repeated measures studies; e.g., volunteers for a clinical study)
  - <u>**Both**</u> **Clusters and Subjects** (in clustered longitudinal data sets; e.g., HRS)

10

<!-- page 11 -->

# What Are Random Effects?

* **Random effects** are random variables that allow the coefficients in a regression model to randomly vary depending on the cluster or subject under study
* For this reason, multilevel models are also known as:
  – Random coefficient models
  – Varying coefficient models
  – Subject-specific models
  – Hierarchical linear models (reflecting the data hierarchy of a clustered or longitudinal data set)
  – Mixed-effects models (reason will become apparent soon)

11

<!-- page 12 -->

# Random Effects, cont’d

* Because they are <u>random variables</u>, we need to define a probability distribution for the random effects $\rightarrow$ multilevel models have additional parameters to estimate!
* In many cases, clusters or subjects are not randomly sampled based on a probability sample design; we assume that they are a random subsample from a larger population (e.g., survey interviewers)

12

<!-- page 13 -->

# Example Model Specification

* Consider the following model for a continuous dependent variable $Y$, measured on person $i$ within cluster $j$:

$$
y_{ij} = \beta_0 + \beta_1 x_{1ij} + u_{0j} + u_{1j} x_{1ij} + e_{ij}
$$

Fixed effects $\quad$ Random effects $\quad$ Error

13

<!-- page 14 -->

# Example Model Specification, cont’d

* The **fixed effects** are what you probably know from prior classes as *regression coefficients* or *regression parameters*
* These are *unknown constants* defining relationships between predictors and dependent variables that we wish to estimate
* The **random effects** are *random variables*; we therefore need to define their distributions!

14

<!-- page 15 -->

# Example Model Specification, cont’d

* The following are examples of commonly assumed distributions for the random effects and random error terms (see McCulloch and Neuhaus, 2011):

$$y_{ij} = \beta_0 + \beta_1 x_{1ij} + u_{0j} + u_{1j} x_{1ij} + e_{ij}$$

$$\begin{pmatrix} u_{0j} \\ u_{1j} \end{pmatrix} \sim N\left(\begin{pmatrix} 0 \\ 0 \end{pmatrix}, \begin{pmatrix} \sigma_0^2 & \sigma_{01} \\ \sigma_{01} & \sigma_1^2 \end{pmatrix} \equiv D\right)$$

$$e_{ij} \sim N(0, \sigma^2)$$

Errors independent of random effects (?)

Variance-covariance Matrix of Random Effects ($D$)

15

<!-- page 16 -->

# Multilevel (or Hierarchical) Specification

* An alternative way of specifying this model that some analysts prefer (used by the HLM and MLwiN software):

**Level 1:**

$$y_{ij} = \beta_{0j} + \beta_{1j}x_{1ij} + e_{ij}$$

Random coefficients (<u>**not parameters!**</u>)

**Level 2:**

$$\beta_{0j} = \beta_0 + u_{0j}$$

$$\beta_{1j} = \beta_1 + u_{1j}$$

When combined, we have the same model!

16

<!-- page 17 -->

# Why the Hierarchical Specification?

* This specification clearly defines the role of covariates measured at higher levels in multilevel models
* View each Level 2 equation for a random coefficient as an intercept-only regression model (where the DV is a random coefficient)!
* We try to **explain variance** in the random effects by adding the fixed effects of Level-2 covariates to these models!

17

<!-- page 18 -->

# Why the Hierarchical Specification?

* For example: $\beta_{0j} = \beta_0 + u_{0j}$
* Fit a model, and compute the estimated variance of the random intercepts: $\hat{\sigma}_0^2 = 2$
* Include a fixed effect of subject gender in the model (assume a longitudinal study):
$$\beta_{0j} = \beta_0 + \beta_2 MALE_j + u_{0j}$$
* Now, $\hat{\sigma}_0^2 = 1$ ; we explained 50% of the variance in the intercepts with gender!

18

<!-- page 19 -->

# Matrix Specification

* Matrix specification is important for understanding how models are estimated
* **Conditional** on a set of random effects, we have the following distribution for the **vector** of observations on subject (or cluster) $j$:

$$y_j | u_j \sim N(X_j \beta + Z_j u_j, R_j)$$

* $X_j$: Design matrix of covariates
* $\beta$: Fixed effects vector
* $Z_j$: (Smaller) Design matrix of covariates
* $u_j$: Random effects vector
* $R_j$: Variance-covariance matrix of random errors

19

<!-- page 20 -->

# Implied Marginal Model

* **Marginally**, averaged across all random effects, we have the following distribution:

$$
y_j \sim N(X_j \beta, Z_j D Z'_j + R_j \equiv V_j)
$$

Vector of expected means for subject (or cluster) $j$

Marginal variance-covariance matrix of observations on subject (or cluster) $j$

* Note where the marginal variances and covariances of observed values come from!

20

<!-- page 21 -->

# Implied Marginal Model

* Important Observations:
  - A multilevel model **implies** the marginal model
  - When we include random effects in a model, the variances of the random effects in $D$ need to be positive (i.e., the $D$ matrix is **positive definite**)
  - We could also fit the implied marginal model **without** random effects, and estimate parameters describing the covariances of the observations (more flexible); no longer a **mixed model**, but allows for negative within-cluster correlations

21

<!-- page 22 -->

# Implied Marginal Model: Example

* In a model with random intercepts only and two observations per cluster, this is the implied marginal variance-covariance matrix :

$$V_j = \begin{pmatrix} \sigma_0^2 + \sigma^2 & \sigma_0^2 \\ \sigma_0^2 & \sigma_0^2 + \sigma^2 \end{pmatrix}$$

* Note that the covariance of the two observations is defined by the variance of the random intercepts! *It therefore can't be negative.* What if this is not the best model?

22

<!-- page 23 -->

# Implied Marginal Model: Example

* In these cases, the software will complain that you are trying to estimate a variance component which is negative, or set the component equal to zero
* As a solution, you can **fit the implied marginal model, <u>rather than the multilevel model with random effects</u>**, which in this case would have a *compound symmetry* structure for the random errors, allowing for negative covariances among the random errors
* We can no longer talk about the random effects in this case, however, or refer to this as a mixed model

23

<!-- page 24 -->

# Aliasing

* We also have to be careful about **aliasing** when specifying models, which leads to the case where parameters cannot be uniquely identified in estimation; don’t over-specify the model!
* For example, we would not be able to include random intercepts **and** allow the random errors to have a compound symmetry structure (we are modeling the same covariance twice!!!)
* In this case, there would be infinitely many solutions for the parameter estimates, and the software will complain during estimation

24

<!-- page 25 -->

# Review!

* Multilevel model: mixed effects (fixed and random), conditional specification
* Marginal model: variance-covariance matrix
* Equivalent specifications:
  * Conditional: random intercept only
  * Marginal: covariance matrix with compound symmetry structure and positive correlation
* Parameters of interest (to be estimated): fixed effects, variances, and covariances

25

<!-- page 26 -->

# Model Building

* Generally two strategies used in practice:
    1. **Top-down Strategy**
        * Start with fully-specified model, including all fixed effects of interest
        * Identify “optimal” variance-covariance structures for random effects and random errors
        * Eliminate non-significant fixed effects
        * Re-consider variance-covariance structures

26

<!-- page 27 -->

# Model Building, cont’d

## 2. Step-up Strategy (Variance Explanation)
* Start with an “empty” or “unconditional” model, with only a random intercept (and possibly random error)
* Add Level-1 predictors to explain variance in the random errors, and possibly allow their effects to randomly vary
* Add Level-2 predictors to explain variance in random effects at Level 2, possibly allowing <u>their</u> effects to vary at higher levels
* Add Level-3 predictors…

27

<!-- page 28 -->

# Modeling Practice

1. Model specification, clear notation!
2. Model estimation
   * Coefficients (or fixed effects) and their variances
   * covariance parameters
3. Model comparison
   * Hypothesis testing
   * Information criteria
4. Model diagnostics
5. Model interpretation: Inference/prediction

28

<!-- page 29 -->

# Estimation of Model Parameters

* Multilevel models are generally estimated using some form of **maximum likelihood estimation**. The basic idea:
  * Form the likelihood function, or the probability of the observed data, assuming independent subjects / clusters denoted by $j$:

$$L(\beta, \theta) = \prod_{j=1}^{n} f(y_j \mid X_j, \beta, \theta)$$

  * $f$ is the **probability density function** for a given dependent variable defined by the **marginal model** (e.g., multivariate normal), and theta = the variance-covariance parameters
  * For some models (generalized linear mixed models), the likelihood first needs to be *approximated*

29

<!-- page 30 -->

# Estimation of Model Parameters

- Next, use iterative mathematical methods (e.g., Newton-Raphson) to find the parameter estimates that maximize the (approximate) likelihood. Two strategies:
  - **ML estimation.** Estimate the variance-covariance parameters first (define the fixed effects as a function of the covariates and the marginal variance-covariance matrix in the likelihood), and then use *generalized least squares (GLS)* to estimate the fixed effects:
    $$
    \hat{\beta} = \left( \sum_j X'_j \hat{V}_j^{-1} X_j \right)^{-1} \sum_j X'_j \hat{V}_j^{-1} y_j
    $$
  - **Restricted ML estimation (REML).** Same idea, but account for the loss of degrees of freedom from estimating the fixed effects first, then use GLS

30

<!-- page 31 -->

# REML vs. ML

* Distinction important for **normal** outcomes
* REML estimation is generally the default for normal outcomes, as it results in **unbiased estimates** of covariance parameters
* ML estimation is better for testing fixed effects (more on this later...), but results in **biased estimates** of covariance parameters
* Be careful to recognize the default of the software that you are using!

31

<!-- page 32 -->

# Variance Estimation

* Variance estimates for the estimated fixed effects can be computed using standard GLS results (biased, but why?):

$$\text{var}(\hat{\beta}) = \left( \sum_{j} X'_j \hat{V}_j^{-1} X_j \right)^{-1}$$

* Variance estimation for the estimated covariance parameters is not nearly as straightforward; can be based on the **Hessian matrix**, which is a by-product of the maximum likelihood estimation process; requires asymptotic (large-sample) assumptions
* Many authors now advocate Bayesian approaches for estimating the variance of covariance parameters (or for making inference more generally); see West and Ellliott (2014)

32

<!-- page 33 -->

# Hypothesis Testing

* When fitting multilevel models, many hypothesis tests regarding the parameters are based on comparisons of *competing* models
* **Reference model:** A “full” or “saturated” model containing all parameters of interest; different from the null model where only intercepts are included
* **Nested model:** A “reduced” model, where some of the parameters in the reference model are constrained to zero

33

<!-- page 34 -->

# Likelihood Ratio Tests

* Compared to the reference model, does fitting the nested model substantially drop the likelihood (or make the observed data seem less likely)?
* Likelihood Ratio Tests: -2 **ML** log-likelihoods
  - Fixed Effects
  - Covariance Parameters

34

<!-- page 35 -->

# Likelihood Ratio Tests for **Fixed Effects**

* Simple idea, but assumes “large” sample of clusters and “large” samples within clusters
* **Null hypothesis:** selected fixed effects are all equal to zero (not important predictors)
* **Test statistic:** difference in final -2 **ML** log-likelihoods between nested and reference models (nested model has some fixed effects set to zero)
* Refer difference to chi-square distribution with $q$ degrees of freedom, where $q$ is difference between two models in number of fixed effects estimated

35

<!-- page 36 -->

# Likelihood Ratio Tests for **Covariance Parameters**

* **If null hypothesis does not specify that a covariance parameter is equal to the boundary of its parameter space (e.g., a variance is equal to zero):**
  – Same approach as for fixed effects, using REML
* **If testing that a variance is equal to zero (e.g., the variance of a given random effect):**
  – Compute test statistic, but refer to approximate **mixture** of chi-square distributions
  – Examples of this approach will be provided
  – Not widely implemented in software...

36

<!-- page 37 -->

# Approximate t-tests

* **Tests of null hypotheses that individual parameters are equal to zero:** divide estimate by estimated standard error, and refer statistic to a given t distribution or $N(0,1)$
* When using t distributions, degrees of freedom are only *approximate*, because we use an *estimate* of the marginal variance-covariance matrix when computing standard errors (failure to account for this uncertainty leads to bias!); many possible methods
* Not recommended for covariance parameters, but still produced by some software

37

<!-- page 38 -->

# Approximate F-tests

* Same basic idea as for t-tests, only extended to multiple parameters
* Same issues with approximate degrees of freedom (some software does not even compute these approximate tests!)
* Similar to likelihood ratio tests, useful for testing hypotheses about multiple parameters (e.g., fixed effects associated with a categorical predictor)

38

<!-- page 39 -->

# Other Testing Methods

* The exact null distribution of the likelihood ratio test statistic for **variance components** (in models with random intercepts only) has been derived by other researchers, and an R routine enables simulations from this null distribution (used by West and Olson, 2010)
  - Will be demonstrated in next lecture
* Bayesian approaches to inference are also possible (see West and Elliott, 2014)

39

<!-- page 40 -->

# Information Criteria (IC)

* IC are used to compare competing models that don’t have a clear nesting relationship
* AIC, BIC, other adjusted versions; penalize for number of parameters being estimated
* “Smaller is better”: decision criterion
* No clear winner has been demonstrated in the literature to date; best to compare models based on multiple criteria

40

<!-- page 41 -->

# Model Diagnostics

* We need to check whether distributional assumptions for the model are satisfied before interpreting a "final" model
* Important diagnostic analyses to consider:
  - Examine standard (Q-Q, fitted-residual, etc.) plots of "conditional" <u>studentized</u> residuals, which account for predicted values of random effects (EBLUPs) and are scaled by the estimated SD of the residuals
  - Examine **influence diagnostics** for both individual observations and higher-level clusters (SAS farthest along, but not many software options at this point)
  - Examine Q-Q plots for predicted values of random effects (EBLUPs), to check for normality and outliers

41

<!-- page 42 -->

# Why Are Diagnostics Important?

* Tests of significance and other forms of inference based on probability models all rely on various distributional assumptions
* If these assumptions are violated, the methods used to make inferences may also be invalid (e.g., non-normal residuals $\rightarrow$ p-values should not be used to test hypotheses)
* We may see interesting patterns; consider the famous case of the BISON DATA in R (Canvas)!
  – http://www4.stat.ncsu.edu/~stefansk/

42

<!-- page 43 -->

# Predicted Random Effects: EBLUPs

* **E**mpirical **B**est **L**inear **U**nbiased **P**redictors of the random effects in a model
* Keep in mind that we do not <u>estimate</u> random effects (they are random variables); we estimate their **variances** and **covariances**
* We can compute their predicted values based on our data: $\hat{u}_j = E(u_j | Y_j = y_j) = DZ'_j \hat{V}_j^{-1}(y_j - X_j \beta)$
* We can also compute a variance-covariance matrix for these predictions, for testing

43

<!-- page 44 -->

# Intraclass Correlation Coefficients

- ICCs are measures describing the homogeneity of responses within a cluster (or within a subject) that we can estimate
- **Two-level models, random intercepts only:**

$$
ICC = \frac{\sigma_0^2}{\sigma_0^2 + \sigma^2}
$$

- **Three-level models, random intercepts only:**

$$
ICC_2 = \frac{\sigma_{0,2}^2 + \sigma_{0,3}^2}{\sigma_{0,2}^2 + \sigma_{0,3}^2 + \sigma^2} \quad ICC_3 = \frac{\sigma_{0,3}^2}{\sigma_{0,2}^2 + \sigma_{0,3}^2 + \sigma^2}
$$

44

<!-- page 45 -->

# Missing Data

* While multilevel models are great for analyzing unbalanced data sets (due to missing data or unbalanced study designs), we do make assumptions about missing data
* Missing data are assumed to be **missing at random (MAR)**; that is, conditional on the other variables in a model, observations with missing data are only randomly different from observations without missing data
* Important to include as many relevant covariates for an outcome as possible to make this plausible

45

<!-- page 46 -->

# Centering Continuous Covariates

* Recall that the intercept in a model is the expected value of the outcome when all covariates are zero (this may not be realistic!)
* This interpretation is especially important when we fit models allowing the intercept to randomly vary across subjects/clusters
* It’s generally a good idea to **center** continuous covariates, either at the overall mean or the cluster-specific mean of the covariate, to make the intercept more interpretable

46

<!-- page 47 -->

# Sample Size Considerations

* Simulations suggest that for cross-sectional studies, at least 30 clusters are needed with at least 30 observations per cluster (30/30) to have reliable parameter estimates in multilevel models
* Rules vary: 20/50, 50/20, 10/100, 100/10
* Generally close to 1,000 observations needed
* For longitudinal studies, better to use software / simulations; simulations are good practice in general!
  * www.umich.edu/~bwest/almmussp.html
* Having many clusters with only one observation can lead to estimation problems

47

<!-- page 48 -->

# Thinking Ahead...

* In the next class, we will focus on various software procedures that are capable of fitting multilevel models, and how to use them
* Please take a careful look at the assigned readings for next week
* Please think about possible team members and a data set for the final project!

48
