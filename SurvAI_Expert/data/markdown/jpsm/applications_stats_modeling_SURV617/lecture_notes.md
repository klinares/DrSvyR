---
id: "jpsm/applications_stats_modeling_SURV617/lecture_notes"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "lecture_notes"
original: "applications_stats_modeling_SURV617/lecture_notes.pdf"
pages: 11
sha256: "dbdbee73e471338b1fc1f2954195055a11d251b5ebb9b2bbaadca290684fcb10"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:39"
---

<!-- page 1 -->

Notes Applications of statistical modeling:

Team
andrew forresster [[email]](mailto:[email])
doris

**8/26/25 MLM concepts**

* In logistic regression, $p(1-p)$ once we know the mean we know the variance so we don not need the error term.
* If we have all 50 states in the data, it is not a random sample. We can just include a fixed effect.
* The effects of clusters are considered random because they come from a random sample.
* Random effects are random variables that vary by a cluster, and we define a probability distributions for these random effect (just like the error term in OLS).
* Clusters are not randomly sampled based on a probability sample design, but we assume that they are from a random subsample from a larger population.

$$y_{ij} = \beta_0 + \beta_1 x_{1ij} + u_{0j} + u_{1j} x_{1ij} + e_{ij}$$

Fixed effects $\quad$ Random effects $\quad$ Error

* Us are random variables, not fixed parameters.
    * U_0j combines with beta_0 to allow random intercepts to vary by clusters.
        * ex. neighborhood income.
    * U_ij allows for a slope to vary (i.e., education level) by cluster. Do different neighborhoods tend to have different education levels?
    * This is only a feature of the cluster.
    * The betas are the regression parameters. These are unknown constants that define constant relationships.
    * Random effects are random variables and we need to define their distributions.

$$y_{ij} = \beta_0 + \beta_1 x_{1ij} + u_{0j} + u_{1j} x_{1ij} + e_{ij}$$

$$\begin{pmatrix} u_{0j} \\ u_{1j} \end{pmatrix} \sim N \left( \begin{pmatrix} 0 \\ 0 \end{pmatrix}, \begin{pmatrix} \sigma_0^2 & \sigma_{01} \\ \sigma_{01} & \sigma_1^2 \end{pmatrix} \equiv D \right)$$

$$e_{ij} \sim N(0, \sigma^2)$$

Errors independent of random effects (?)

Variance-covariance Matrix of Random Effects ($D$)

<!-- page 2 -->

* These random effects arise from a multi normal distributions.
  * 6 parameters the betas and the unique sigmas in D, and sigma in e.
  * The mean vector is 0, on average there is no deviations in the clusters.
  * Since we have two random variables we need a variance-covariance structure.
    * Sigma squared allows us to have the random intercepts.
    * Sigma (covariance) allows us to have random slopes.
      * Ex, a neighborhood with a higher intercept, could have more variability in the slope.
  * If we care about variability in intercepts and slopes than we conduct MLM.
    * If there is variability, can we explain it.
    * If there is no correlation in the variability, we can remove these sigma parameters and simplify.
  * D is the variance-covariance specification.
* We can test hypothesis on these parameters.

**Level 1:**

$$y_{ij} = \beta_{0j} + \beta_{1j}x_{1ij} + e_{ij}$$

Random coefficients (**<u>not parameters!</u>**)

**Level 2:**

$$\beta_{0j} = \beta_0 + u_{0j}$$

$$\beta_{1j} = \beta_1 + u_{1j}$$

* Multilevel specification of the same mode.
  * Level 1 model we let the coefficients randomly vary. No single parameter specified here.
  * Level 2, parameters entered here, beta plus a random disturbance associated with the class.
  * Ex of a RQ what % of the variability is explained by the clustering?

$$\beta_{0j} = \beta_0 + \beta_2 \text{MALE}_j + u_{0j}$$

* This adds a fixed effect of male (could be a teacher’s gender), beta 2 on the intercept.
* MLM implies a marginal model

**Marginally**, averaged across all random effects, we have the following distribution:

$$y_j \sim N(X_j \beta, Z_j D Z_j' + R_j \equiv V_j)$$

Vector of expected means for subject (or cluster) $j$

Marginal variance-covariance matrix of observations on subject (or cluster) $j$

<!-- page 3 -->

$$
V_j = \begin{pmatrix} \sigma_0^2 + \sigma^2 & \sigma_0^2 \\ \sigma_0^2 & \sigma_0^2 + \sigma^2 \end{pmatrix} \quad .
$$

* Implied marginal variance-covariance matrix.
  * Every cluster has their own random intercept.
* Maximum likelihood, what is the most likely y values to been seen across clusters.
* REML – restricted ML estimation. , count for the loss of df from estimating fixed effects.
  * ML is good for testing fixed effects, but use REML to show unbiased estimates. Add this in report.
    * This distinction only for continuous outcome.
* Variance estimation
  * we use an estimate to estimate, the V matrix, and if misspecified, standard errors are affected.
* Hypothesis testing
  * reference model – full model with all parameters.
  * nested model, hypothesis model are constrained to 0.
  * likelihood ratio tests – does fitting a nested model drop the likelihood, make observed data less likely.
    * Test statistic from ML, -2 log-likelihoods between nested and reference models. Difference in chi-square distribution with q degrees of freedom.
    * For covariance parameters, when testing, it has to be right at the boundary, variance cannot be less than 0. Covariance can be 0.
      * same -2 loglikelihood from REML.
        * If the hypothesis is set to 0, we use a t-test and refer to a mixture of chi-square distributions.
  * Information criteria, like AIC, BIC penalize for number of parameters being estimated. Generally used for models that are not nested, meaning that they are not a reduced model, more for comparing competing models.
  * Model diagnostics
    * QQ plots, conditional residuals account for random effects (empirical best linear unbiased predictors EBLUP). Calculate predictions of U_0.
      * Tests of significant rely on assumptions.
      * Remember, we dot estimate the random effects because they are not parameters.
  * Intraclass correlation coefficients
    * measures that describes the homogeneity within cluster, but a measure for cross-sectional data for models with random intercepts.
  * Missing data – assumed missing at random. Fitting an MLM on data that has missing not at random is a bad idea.
  *

<!-- page 4 -->

**Software for fitting MLM 9/2/25**

This multilevel approach successfully accounts for the within-subject correlation while providing insights into both population-level trends and individual variation in blood pressure trajectories over time.

* Time start at 0, just like centering, make the intercept meaningful such as baseline in wave 1 or year.
* Assumption between time and outcome is linear, but if it s not linear, we need a squared term.
    * Visualize data and check for relationships.
    * Practice writing D matrix.

### `lmer()` syntax

$$D = \begin{bmatrix} \sigma_{int}^2 & \sigma_{it} \\ \cdot & \sigma_t^2 \end{bmatrix}$$

```r
> library(lmerTest)
> example.model <- lmer(vsae ~ iv1 + time + factor(male)
+ (time | subject),
REML = T,
data = datan)
> summary(example.model)
> ranef(example.model)
> ranova(example.model)
```

* Load the lmerTest package, enabling approximate tests of fixed-effect parameters
* First part of model formula: DV, and fixed effects
* Coefficient for TIME and intercept (by default) randomly vary across subjects, with UN structure
* Estimation method (REML), and data frame object
* Use the summary() function to view estimates, tests, and information criteria
* Print EBLUPs for all random coefficients
* Generate multi-parameter tests for fixed effects (also used for likelihood ratio tests, where two model fit objects are input)

* If we remove the slope, than D is a scalar with one value sigma^2, no covariance.
* If we want to relax the D matrix, say to allow gender to vary at level 2, use lme. Slide 9.
* ranef() function shows the random effect deviations.
* rand() function calculates mixture based p value.
* Corr in the random effects is the covariance. Look at the direction of the correlation.

<!-- page 5 -->

Lecture 3

Study Guide: Multilevel Models and Interviewer Effects with R Implementation

Core Concepts from Lecture

**Random Effects Criteria:** Units must be randomly sampled from a larger population. Example: If all 4 regions are included, region is a fixed effect. If 50 regions are randomly selected from 100, region can be a random effect.

**Interviewer Effects Framework:** Measurement error specific to interviewers creating natural clusters:

* Model: $y_{ij} = X_i + M_j + e_{ij}$ where $M_j \sim N(0, \sigma_{int}^2)$ and $e_{ij} \sim N(0, \sigma^2)$
* Unconditional model: $y_{ij} = \beta_0 + \mu_{0j} + e_{ij}$

**Variance Components and ICC:**

* $\rho_{int} = \sigma_0^2 / (\sigma_0^2 + \sigma^2)$
* Tests $H_0: \sigma_{int}^2 = 0$ using mixture-based LRT

R Implementation

Setup

```r
library(lme4)
library(lmerTest)
library(tidyverse)

# Custom LRT for multiple random effects (mixture of χ²₁ and χ²₂)
lrt.pvalue <- function(fit1, fit2) {
  lrtstat <- (-2 * as.numeric(summary(fit2)$logLik)) -
             (-2 * as.numeric(summary(fit1)$logLik))
  pvalue = 0.5 * (1 - pchisq(lrtstat, 2)) +
           0.5 * (1 - pchisq(lrtstat, 1))
  return(pvalue)
}
```

Data Exploration

```r
# Check workloads (always unbalanced)
ess_belgium %>%
  group_by(intnum) %>%
  summarise(n = n())

# Visualize interviewer variation
ess_sub <- subset(ess_belgium, intnum < 2000)
plot(ess_sub$pplhlp ~ factor(ess_sub$intnum))
```

<!-- page 6 -->

Unconditional Model

```r
mod1 <- lmer(pplhlp ~ 1 + (1|intnum), REML = TRUE, data = 
ess_belgium)
summary(mod1)
rand(mod1)  # Tests H₀: σ²₀ = 0
```

**Results from lecture:**

* $\hat{\beta}_0 = 4.75$ (overall mean)
* $\hat{\sigma}^2_0 = 0.23$ (interviewer variance)
* $\hat{\sigma}^2 = 3.79$ (residual variance)
* $\hat{\rho} = 0.057$ ($p < 0.0001$)

Adding Level-2 Covariates

```r
mod2 <- lmer(pplhlp ~ int_rr + (1|intnum), REML = TRUE, data = 
ess_belgium)
```

Response rate didn't explain variance ($p = 0.637$); $\sigma^2_0$ unchanged.

Random Coefficient Model

```r
mod3 <- lmer(pplhlp ~ trstplc + (trstplc|intnum), REML = TRUE, data = 
ess_belgium)

# Test random slope
mod3a <- lmer(pplhlp ~ trstplc + (1|intnum), REML = TRUE, data = 
ess_belgium)

# Manual LRT calculation or use custom function
0.5*(1-pchisq(23.5,1)) + 0.5*(1-pchisq(23.5,2))  # p < 0.001
lrt.pvalue(mod3, mod3a)
```

**Model with D matrix:**

* Fixed effects: $\hat{\beta}_0 = 3.89$, $\hat{\beta}_1 = 0.14$
* D matrix: $\hat{\sigma}^2_0 = 0.69$, $\hat{\sigma}^2_1 = 0.01$, $\hat{\sigma}_{01} = -0.07$
* Correlation = $-0.82$ (convergence warning)

Diagnostics (Essential for Every Model)

```r
# Residuals (key assumption check)
qqnorm(resid(mod1))
qqline(resid(mod1))

# Random effects
qqnorm(ranef(mod1)$intnum[,1])
qqline(ranef(mod1)$intnum[,1])

# For random slopes
```

<!-- page 7 -->

```r
qqnorm(ranef(mod3)$intnum[,2])
qqline(ranef(mod3)$intnum[,2])
```

Critical Implementation Notes

1. **Missing Data**: ESS codes 88/888 as missing - must clean before analysis
2. **Model Notation**:
    * Random intercept: `(1|intnum)`
    * Random slope: `(trstplc|intnum)`
3. **Centering**: Essential for random slopes to ensure intercept interpretability at meaningful values
4. **Diagnostics**: Check residuals for normality, not raw outcomes
5. **Variance Inflation**: Even small $\rho_{\text{int}}$ reduces effective sample size as workload (B) increases

MLM Advantages

* Handles unbalanced workloads
* Incorporates interviewer-level covariates
* Allows variance to differ by mode (CAPI vs. CATI)
* Enables crossed random effects (when not aliased)
* Provides partial pooling between complete and no pooling approaches

**Longitudinal models:**

* difference between anova and multilevel is the number of parameters.
    * Also, can't really use categorical variables.
    * In ordinary regression, we look at the mean structure.
* In multilevel, because of partial pooling smaller cluster sizes shrink close to the overall mean, because of the contribution of larger size clusters.
* We need to assume data is correlated across time within individuals.
* What fixed effect to capture moderation of time slope as a function of group. Interaction between age level 1, and group level 2 covariate. Examines trajectories.
* GEE models generalized estimating equations, marginal models.
    * Marginal models do not have random effects.
* With longitudinal we consider the R\_i matrix since errors may be correlated.
    * Level 1 is time varying predictors of the outcomes.
    * Level 2 explains variance with level 1 predictors.
* Take away points
    * Remember the difference in possible inferences between multilevel and marginal models:
        * Hierarchical / Multilevel: include explicit random effects, and inferences are subject-specific (i.e., you are "controlling" for random subject effects, and fixed effects represent what happens when a covariate changes for a given subject)
        * Marginal: Population-averaged effects (what happens, on average, across all subjects in a study?)
    * What is the correct function of time.

<!-- page 8 -->

HW 1:

* Incomplete interpretations of the slopes.
  * Beta 1, expected change in the predicted variable as it increases by one unit.
  * If we had other covariates, adjusting or holding fixed for other covariates.
* Error variance issues
  * what is left over in the unexplained error within individual. Do we have an epsilon in logistic model, no.
* Interactions – read the announcement readings and learn to interpret.

Applications of Statistical modeling
* midterm

# Midterm Exam Notes

* Scope:
  – Multilevel modeling (linear, logistic)
  – Marginal modeling (linear, logistic)
  – Software syntax / output interpretation
  – Everything up through and including today’s lecture (Lectures 1-5 in Module 1)
  – Nothing about complex sampling!
* Logistics: Two hours, open notes, open book, open laptops; **<u>no electronic communication</u>**

<!-- page 9 -->

# Midterm Exam Notes

* T/F and MC questions covering important concepts, short-answer questions, model specification, execution of data analysis, interpretation of example output
* Practice Exam
  * Available on Canvas in **Midterm Exam** folder
  * Please study this carefully, and <u>make sure that you are prepared to perform real data analysis</u>
* Questions?

* Practice midterm on canvas
* objectives
  * if estimating variance, multilevel models but overall marginal growth, use marginal linear model.
    * Marginal meaning average trends across everyone – it is not a multilevel model, think total assets for each education levels.
      * A marginal model the coefficients don’t randomly vary, variance-covariance matrix is different from multilevel despite using packages for multilevels.
      * An approach for longitudinal, the V matrix is the R because there are no random effects, this variance covariance is driven by the V matrix. This is the important part.
    * For multilevel models, the question would be about growth in total assets as a function of demographic characteristics.
* In an AR multilevel model, the Phi (correlation), persistent parameter can be negative since we have a lot of clusters. This happens with random slope.
  * With only one fixed effect and random intercept, 5 parameters beta0, beta1, sigma^2, sigma^2_0, and since we add a correlation matrix, we are estimating rho, the correlation of the adjacent matrix. Because corAr is added, there is a correlation matrix rho estimated. If we were using an unstructured variance-covaraince, we would be estimating 10 parameters.

```r
Obj1.fit.2 <- lme(
  totassets000 ~ yrssince00,
  random = ~ 1 | hhidpn,
  correlation = corAR1(form = ~ 1 | hhidpn),
  method = "REML",
  na.action = "na.omit",
  control = list(opt = "optim"),
  data = temphrs
)
```

<!-- page 10 -->

* We need a more complicated approach because we have the variance of the slopes. The null hypothesis is testing a variance that cannot be 0 to begin with.

```r
lrt.pvalue <- function(fit1, fit2) {
lrtstat <-
(-2 * as.numeric(summary(fit2)$logLik)) - (-2 *
as.numeric(summary(fit1)$logLik))
pvalue = 0.5 * (1 - pchisq(lrtstat, 2)) + 0.5 * (1 -
pchisq(lrtstat, 1))
return(pvalue)
}
lrt.pvalue(Obj1.fit.1, Obj1.fit.2)
```

* % of variance explained by adding fixed effect.
  * Intercept variance: (Model full $\text{sigma}^2_0$ - Model reduced $\text{sigma}^2_0$ ) / Model full $\text{sigma}^2_0$
  * slope variance: (Model full $\text{sigma}^2_1$ - Model reduced $\text{sigma}^2_1$ ) / Model full $\text{sigma}^2_1$
* If we had time with 4 categories, can we estimate different effects for each unique differences, 2000 vs 2002, etc.
  * Also, if the data is household, we only have one observation per household for each time point, so no variability within year_household.
* Latent class growth anaylysis
  * certain groups defined by trajectories.
* Objective 2, marginal linear model
  * we can use the gls() function within the LME package. Allows us to relax correlation structure. Find best trend in growth, we only care about the overall marginal trend.
    * We use the unstructured correlation structure; corSymm() argument.
    * The weights argument says we are using an identify matrix structure.
    * Look at the marginal variance covariance matrix to examine if variance is equal and constant. If not, this AR may not be appropriate but marginal models may be.
    * No explicit random effeccts.
* Link between random effect models and penalized splines.
  * Many time points and continuous outcome measures, unique curves defined by knots. Splines provide an alternative.
  * Splines functions are defined by a series of linked line curves. In longitudinal, the knots are were slopes are changing.
  * Penalized splines, penalty for how rough the fit of a spline is. Each curve has their own random time slopes to find an overall functional form. This allows the predictor to change.
* Objective 3, binary outcome. Use of glmer().
* Objective 4, geepak::geeglm() to fit marginal models to longitudinal data.

<!-- page 11 -->

**Complex sample designs**

* we can use replicated variance estimation or taylor series linearization approaches to get unibased variance estimation.
  * Singleton problem, when one strata has on cluster, lonely PSU stratum.
* Muthen and Satorra prominent paper fitting SEM to complex samples. Also how to compute standard errors with these designs.
  * Stapleton 2006 recommends how to implement Muthen's work.
* SEM assumption IID and multivariate normal distribution
  * ignoring informative weights can bias parameter estimates.
  * How do we incorporate weights?
    * You compute weighted estimated for the variables in the model in the sample variance/covariance. Each contribution gets raised to their weight.
    * Given the weights in the likelihood function, parameters are then estimated.
    * Taylor series linearization is used to compute variances.
    * Variability in weights also needs to be accounted for in estimating standard errors.
      * Why not use replications? Computationally intensive.
    * Weighted likelihood estimation with taylor series linearization = pseudo-maximum likelihood (PML) estimation.
  * Variance estimation, take standard errors and multiply by design effects from previous studies, it is okay for the variance but if weights are important to the point estimate it may lead to bias. We need to correct for bias and variance.
    * What if we adjusted weights and normalized them? It doesn't work well for all parameters, it may approximate, but for some parameters may be off.
  * Fit statistics have to be adjusted with complex sampling features.
    * Rao-Scott – adjustement for design effects.
    * These test statistics have to be scaled.
  * Alternative model approach (Muthen's work)
    * Basic idea is to fit an SEM using random effects to account for clustering, the question is do we assume a global variance or each cluster gets their own variance?
      * This is a multilevel model.
    * Lavaan.survey in r is discontinued, but look into BRMS.
  * Singleton problem, one cluster in a strata. We can split into two random groups. This is called random grouping. Than declare the pseudo clusters. Now there are at least two clusters. Even numbers cluster can join together, and odd can join odd.
    * 30-50 cases per cluster to represent the sub groups.
    * Some random groups may be too small.
      * Look at the entropy, with weights it went down in the LCA example which can mean that individual probabilities are more noisy.
