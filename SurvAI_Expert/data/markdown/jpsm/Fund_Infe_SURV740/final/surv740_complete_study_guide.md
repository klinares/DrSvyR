---
id: "jpsm/Fund_Infe_SURV740/final/surv740_complete_study_guide"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "SURV 740: Fundamentals of Inference - Complete Final Exam Study Guide"
original: "Fund_Infe_SURV740/final/surv740_complete_study_guide.qmd"
pages: 
sha256: "bdc1f1ca131ece55404f2ce0b5661fecf2551cc1e4f2ef1970c42d3f35022835"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:02"
---


```r
#| label: setup
#| include: false
library(tidyverse)
library(knitr)
options(digits = 4)
```

# Overview of Statistical Inference Methods

## Key Definitions

**Statistical Inference**: The process of drawing conclusions about an
underlying population based on a sample or subset of the data.

**Estimand** ($Q$): The quantity of interest in the population (e.g.,
mean, total, variance).

**Estimate** ($q$): The value computed from sample data to approximate
$Q$.

**Estimation Procedure**: A method that, when applied to sample data,
produces an estimate.

## Inductive vs Deductive Reasoning

| Type | Direction | Description | Framework |
|-----------------|------------------|---------------------|------------------|
| **Inductive** | Particular → General | Use sample to draw conclusions about population | Bayesian |
| **Deductive** | General → Particular | Theory → Hypothesis → Prediction → Compare with data | Frequentist |

## Design-Based vs Model-Based Inference

### Design-Based (Randomization) Inference

| Feature | Description |
|------------------------------|------------------------------------------|
| Population values | **Fixed** constants $Y_1, \ldots, Y_N$ |
| Source of randomness | **Sampling indicator** $I_j$ (random variable) |
| Requirements | Probability sample with known $\pi_j > 0$ |
| Key properties | Unbiased, minimum variance, design-consistent |
| Limitations | Requires probability sampling, 100% response, large samples |

### Model-Based Inference

| Feature | Description |
|------------------------------|------------------------------------------|
| Population values | **Random** realizations from statistical model |
| Source of randomness | Model distribution (e.g., $Y_i \sim N(\mu, \sigma^2)$) |
| Requirements | Correctly specified model |
| Types | Frequentist or Bayesian |

### Ignorable vs Non-Ignorable Designs

**Ignorable**: $P(I|Y,Z) = P(I|Z)$ — sampling mechanism doesn't depend
on Y given design variables Z

**Non-Ignorable**: $P(I|Y,Z) \neq P(I|Z)$ — sampling depends on outcome
even after conditioning on Z

## Superpopulation Theory

The finite population is viewed as a random sample from an infinite
superpopulation:

$$E(\hat{\theta}) = E_M[E_I(\hat{\theta})]$$

$$Var(\hat{\theta}) = \underbrace{E_M[V_I(\hat{\theta})]}_{\text{Design variance}} + \underbrace{V_M[E_I(\hat{\theta})]}_{\text{Superpopulation variance } \approx O(1/N)}$$

The second term is negligible for large $N$.

\newpage

# Design-Based (Randomization) Inference

## Basic Framework

**Population**: $Y = \{Y_1, \ldots, Y_N\}$

**Estimand**: $Q = Q(Y)$ (e.g., population mean, total)

**Design**: $Pr(I_1, \ldots, I_N)$ where $I_j = 1$ if unit $j$ selected

**Sample**: $y = \{y_1, \ldots, y_n\} \subset Y$

**Sampling Distribution**: Distribution of $q(y)$ across all possible
samples

## Properties of Estimators

### Unbiasedness

$$E(q) = \sum_{s=1}^{S} p_s \cdot q_s = Q$$

where $p_s$ = probability of sample $s$, $q_s$ = estimate from sample
$s$.

For EPSEM: $E(q) = \frac{1}{S}\sum_{s=1}^{S} q_s = Q$

### Sampling Variance

$$V = \sum_{s=1}^{S} p_s (q_s - \bar{q}_S)^2$$

For EPSEM: $V = \frac{1}{S}\sum_{s=1}^{S} (q_s - Q)^2$

### Mean Squared Error (MSE)

$$MSE(\hat{\theta}) = Var(\hat{\theta}) + [Bias(\hat{\theta})]^2$$

### Design Consistency

$$|q_s - Q| \rightarrow 0 \text{ as } n \rightarrow N$$

## Simple Random Sampling (SRSWOR)

### Variance Formulas

| Quantity | Population Parameter | Sample Estimator |
|-----------------|------------------------------|-------------------------|
| **Variable Variance** | $\sigma^2 = \frac{1}{N-1}\sum_{j=1}^{N}(Y_j - \bar{Y})^2$ | $s^2 = \frac{1}{n-1}\sum_{i=1}^{n}(y_i - \bar{y})^2$ |
| **Sampling Variance** | $V(\bar{y}) = (1-f)\frac{\sigma^2}{n}$ | $\widehat{Var}(\bar{y}) = (1-f)\frac{s^2}{n}$ |
| **FPC** | $f = n/N$ |  |

**Note**: $E(s^2) = \sigma^2$ (sample variance is unbiased for
population variance)

### Variance for Proportions

For $\hat{p} = \bar{y}$ where $y_i \in \{0,1\}$:

$$\widehat{Var}(\hat{p}) = (1-f)\frac{\hat{p}(1-\hat{p})}{n-1}$$

**Note**: Use $(n-1)$ for sample data (Bessel's correction); use $n$ for
population.

## Confidence Intervals

### Large Sample Normal Approximation

If $\frac{q - E(q)}{\sqrt{V}} \sim N(0,1)$ approximately, then:

$$CI_{1-\alpha} = q \pm z_{\alpha/2} \times \sqrt{\widehat{Var}(q)}$$

| Confidence Level | $z_{\alpha/2}$ |
|------------------|----------------|
| 90%              | 1.645          |
| 95%              | 1.96           |
| 99%              | 2.576          |

**Interpretation**: In 95% of samples drawn under this design, the true
parameter would be within those bounds.

### Transformations for Non-Normal Distributions

**Delta Method**: For transformation $g(q)$:

$$Var(g(q)) \approx \left[\frac{\partial g}{\partial q}\bigg|_{q=E(q)}\right]^2 \times V$$

| Transformation | Formula | Back-Transform | Use For |
|---------------------|----------------|---------------------|----------------|
| **Logit** | $\log\left(\frac{\hat{p}}{1-\hat{p}}\right)$ | $\frac{e^x}{1+e^x}$ | Proportions near 0 or 1 |
| **Arcsine-sqrt** | $\arcsin(\sqrt{\hat{p}})$ | $\sin^2(x)$ | Proportions |
| **Log** | $\log(q)$ | $e^x$ | Positive, skewed |

**Logit Variance**:
$Var_{logit} = \frac{Var(\hat{p})}{[\hat{p}(1-\hat{p})]^2}$

## Sample Size Determination

### For Proportions

$$n = \frac{z_{\alpha/2}^2 \cdot p(1-p)}{d^2}$$

-   Use $p = 0.5$ for maximum (conservative) sample size
-   $d$ = desired margin of error (half-width of CI)

**Alternative (variance-based)**: $V_{max} \leq c$ gives
$n \geq 1 + \frac{1}{4c}$

### For Means

$$n = \frac{z_{\alpha/2}^2 \cdot \sigma^2}{d^2}$$

## Design Effects

### Definition

$$DEFF = \frac{Var(\hat{\theta})_{complex}}{Var(\hat{\theta})_{SRS}}$$

-   **DEFF \> 1**: Complex design is *less* efficient than SRS
-   **DEFF \< 1**: Complex design is *more* efficient than SRS

### Effective Sample Size (ESS)

$$n_{eff} = \frac{n}{DEFF}$$

**Interpretation**: Size of SRS that would give equivalent precision.

### DEFF Components

| Design Feature        | Effect on Variance | DEFF Formula                 |
|-----------------------|--------------------|------------------------------|
| **Stratification**    | Decreases          | Generally \< 1               |
| **Clustering**        | Increases          | $DEFF \approx 1 + (b-1)\rho$ |
| **Unequal Weighting** | Increases          | $DEFF \approx 1 + CV_w^2$    |

where:

-   $b$ = average cluster size
-   $\rho$ = intraclass correlation coefficient (ICC)
-   $CV_w = s_w/\bar{w}$ = coefficient of variation of weights

### Combined DEFF

$$DEFF_{total} \approx DEFF_{weight} \times DEFF_{cluster} \times DEFF_{strat}$$

### Inefficiency of Weighting (Loss Factor)

$$L \approx 1 + CV_w^2$$

**Example**: If $CV_w = 0.5$, then $L = 1.25$ → 25% variance increase
due to weighting.

\newpage

# Horvitz-Thompson Estimator

## Definition

**Population Total**:
$$\hat{T}_{HT} = \sum_{i \in s} \frac{y_i}{\pi_i} = \sum_{i \in s} w_i y_i$$

**Population Mean**:
$$\hat{\bar{Y}}_{HT} = \frac{\sum_{i \in s} w_i y_i}{\sum_{i \in s} w_i} = \frac{\hat{T}_{HT}}{N}$$

where $w_i = 1/\pi_i$ = design weight, $\pi_i = Pr(I_i = 1)$

## Properties

-   **Unbiased**: $E(\hat{T}_{HT}) = T$ for any set of Y values
-   **Proof**:
    $E(\hat{T}_{HT}) = \sum_{j=1}^{N} E(I_j) \frac{Y_j}{\pi_j} = \sum_{j=1}^{N} \pi_j \frac{Y_j}{\pi_j} = T$

## Model-Based Justification

Under the model
$y_i \sim (E(y_i) = \beta\pi_i, Var(y_i) = \sigma^2\pi_i^2)$:

-   HT estimator = Weighted Least Squares estimate of $\beta$

## Basu's Elephant Problem

**Setup**: 11 elephants, need to estimate total weight, can weigh only
1.

| Design | Probability | Estimate | Mean | SD | Problem |
|------------|-------------|------------|------------|------------|------------|
| Manager's | Middle = 1.0 | 121,000 | 121,000 | 0 | Biased, not probability |
| Statistician's | Middle = 0.9, Others = 0.01 | Varies | 120,800 | 328,585 | Huge variance |
| Equal probability | All = 1/11 | 11×selected | 120,800 | 15,025 | Best |

**Lesson**: Unbiasedness doesn't guarantee good individual estimates.
High variance can make estimates useless.

\newpage

# Bayesian Inference

## Bayes Theorem

$$P(\theta|y) = \frac{P(y|\theta) \cdot P(\theta)}{P(y)} \propto \underbrace{P(y|\theta)}_{\text{Likelihood}} \times \underbrace{P(\theta)}_{\text{Prior}}$$

$$\text{Posterior} \propto \text{Prior} \times \text{Likelihood}$$

## Types of Priors

| Type | Description | Example |
|------------------|--------------------------------|-----------------------|
| **Informative** | Strong prior beliefs | Beta(10, 10) |
| **Diffuse/Vague** | Weak prior, wide variability | Beta(0.1, 0.1) |
| **Non-informative** | Minimal prior influence | Beta(1, 1) = Uniform |
| **Improper** | Doesn't integrate to 1, but yields proper posterior | $p(\theta) \propto 1$ |
| **Jeffreys** | Invariant under reparameterization | $p(\theta) \propto \sqrt{det(I(\theta))}$ |

## Conjugate Priors

| Likelihood | Parameter | Conjugate Prior | Posterior |
|-----------------|-----------------|----------------------|-----------------|
| Binomial$(n, \theta)$ | $\theta$ | Beta$(\alpha, \beta)$ | Beta$(\alpha + y, \beta + n - y)$ |
| Normal$(\mu, \sigma^2)$ known $\sigma^2$ | $\mu$ | Normal$(\mu_0, \sigma_0^2)$ | Normal (precision-weighted) |
| Normal$(\mu, \sigma^2)$ known $\mu$ | $\sigma^2$ | Inverse-Gamma$(\alpha, \beta)$ | Inverse-Gamma (updated) |
| Poisson$(\lambda)$ | $\lambda$ | Gamma$(\alpha, \beta)$ | Gamma$(\alpha + \sum y_i, \beta + n)$ |

### Beta Distribution Properties

$$\text{Beta}(\alpha, \beta): \quad E(\theta) = \frac{\alpha}{\alpha + \beta}, \quad Mode = \frac{\alpha - 1}{\alpha + \beta - 2}$$

-   $\alpha$ = prior "successes", $\beta$ = prior "failures"
-   Beta(1,1) = Uniform (non-informative)

### Normal-Normal Update (Precision Weighting)

Prior: $\mu \sim N(\mu_0, \sigma_0^2)$, Data: $\bar{y}$ with variance
$\sigma^2/n$

$$\text{Posterior Mean} = \frac{\tau_0 \mu_0 + \tau_{data} \bar{y}}{\tau_0 + \tau_{data}}$$

where $\tau_0 = 1/\sigma_0^2$ (prior precision),
$\tau_{data} = n/\sigma^2$ (data precision)

## Jeffreys (Non-informative) Priors

| Model | Jeffreys Prior | Notes |
|------------------|-------------------------------------|------------------|
| Binomial | $p(\theta) \propto \theta^{-1}(1-\theta)^{-1}$ | Improper |
| Normal (mean) | $p(\mu, \sigma) \propto \sigma^{-1}$ | Improper |
| Poisson | $p(\lambda) \propto \lambda^{-1}$ | Improper |
| General | $p(\theta) \propto \sqrt{det(I(\theta))}$ | Fisher information |

**Improper priors** can yield proper posteriors and matching frequentist
CIs.

## Credible Intervals

**Definition**: Interval $[L, U]$ such that
$P(L \leq \theta \leq U | y) = 1 - \alpha$

**Highest Posterior Density (HPD)**: Shortest interval containing
$(1-\alpha)$ probability

| Type                    | Bounds | Interpretation                            |
|-----------------|------------------|-------------------------------------|
| **Confidence Interval** | Random | "95% of intervals contain $\theta$"       |
| **Credible Interval**   | Fixed  | "95% probability $\theta$ is in interval" |

## Bayesian Finite Population Inference

### Setup

-   **Included data**: $y_{inc} = \{y_1, \ldots, y_n\}$
-   **Excluded (to predict)**: $Y_{exc} = \{Y_{n+1}, \ldots, Y_N\}$
-   **Goal**: Inference about $P(Y_{exc} | y_{inc}, Z, I)$

### Algorithm

1.  **Draw** $\theta^{(r)}$ from posterior $\pi(\theta | y_{inc})$
2.  **Simulate** $Y_{exc}^{(r)} | \theta^{(r)} \sim$ model distribution
3.  **Compute** estimand: $Q^{(r)} = Q(y_{inc}, Y_{exc}^{(r)})$
4.  **Repeat** $R$ times to get distribution of $Q$
5.  **Summarize**: Mean, credible intervals from
    $\{Q^{(1)}, \ldots, Q^{(R)}\}$

### Example: Population Mean

$$\bar{Y}^{(r)} = \frac{1}{N}\left(n\bar{y}_{inc} + (N-n)\bar{Y}_{exc}^{(r)}\right)$$

### Complex Samples

For complex designs with design variables $Z$:

$$P(Y, I | Z) = P(Y | Z) \cdot P(I | Y, Z)$$

Two-stage construction:

1.  Draw $\theta$ from $\pi(\theta | Y_{inc}, Z, I)$
2.  Draw $Y_{exc}$ from $P(Y_{exc} | \theta, Z)$

## General Bayesian Approach (Unknown Posterior Form)

### Maximum Likelihood Estimation

$$\hat{\theta}_{MLE} = \arg\max_\theta \ell(\theta | y_{inc}) = \arg\max_\theta \sum_i \log f(y_i | \theta)$$

### Information Matrix

$$I(\theta) = -E\left[\frac{\partial^2 \log f(y|\theta)}{\partial\theta \partial\theta^T}\right]$$

$$\hat{V} = I^{-1}(\hat{\theta})$$

### Posterior Approximation

With prior mean $\theta_P$ and variance $V_P$:

$$E(\theta | y_{inc}) \approx (\hat{V}^{-1} + V_P^{-1})^{-1}(\hat{V}^{-1}\hat{\theta} + V_P^{-1}\theta_P)$$

$$V(\theta | y_{inc}) \approx (\hat{V}^{-1} + V_P^{-1})^{-1}$$

For large samples:
$\theta | y_{inc} \approx N(E(\theta|y_{inc}), V(\theta|y_{inc}))$

\newpage

# Calibrated Bayes

## Concept

Combine the best of both approaches:

$$\underbrace{\text{Bayesian Inference}}_{\text{for estimation}} + \underbrace{\text{Frequentist Checking}}_{\text{for model validation}}$$

**NOT**: Frequentist for estimation + Bayesian for checking (this is
reversed!)

## Posterior Predictive Checking

**Goal**: Are observed data consistent with repeated simulations from
the fitted model?

### Process

1.  Draw parameters from posterior:
    $\theta^{(r)} \sim \pi(\theta | y_{obs})$
2.  Simulate replicate data: $y^{(r)} \sim f(y | \theta^{(r)})$
3.  Compute test statistic: $T(y^{(r)})$
4.  Compare $T(y_{obs})$ to distribution of $T(y^{(r)})$
5.  Compute posterior predictive p-value

**Good model**: Observed statistics should be consistent with simulated
distribution.

\newpage

# Auxiliary Information

## Poststratification

### Purpose

1.  **Variance reduction**: Leverage known population structure
2.  **Bias reduction**: Adjust for differential nonresponse (under MAR)

### Assumptions

-   Variables collected in survey (not on original frame)
-   Related to key survey measures
-   Population totals available from external source
-   **Only works under MAR** (not MNAR)

### Weight Adjustment

$$w_{ps,l,i} = \frac{N_l}{\hat{N}_l} = \frac{N_l}{\sum_{i \in s_l} w_{sel,i} \times w_{nr,i}}$$

**Simplified**: Weight adjustment = Population proportion / Sample
proportion

### Variance Reduction

$$V(\bar{y}_{ps}) \approx \frac{1}{n}\sum_{h=1}^{H} P_h S_h^2 \quad \text{(within strata only)}$$

$$V(\bar{y}_{SRS}) = \frac{1}{n}\sum_{h=1}^{H} P_h S_h^2 + \frac{1}{n}\sum_{h=1}^{H} P_h(\bar{Y}_h - \bar{Y})^2$$

**Key**: Larger between-stratum variance → larger efficiency gains

### Missing Data Mechanisms

| Mechanism | Definition             | Poststratification Effect |
|-----------|------------------------|---------------------------|
| **MAR**   | $P(R|Y,X) = P(R|X)$    | Removes bias ✓            |
| **MNAR**  | $P(R|Y,X) \neq P(R|X)$ | Does NOT remove bias ✗    |

## Raking (Iterative Proportional Fitting)

### When to Use

-   Only **marginal distributions** known (not cross-classified counts)
-   No important interactions between raking variables
-   Algorithm converges reliably

### Algorithm

1.  Adjust weights to match margin 1:
    $A_i = \frac{N_i}{\sum_j w_{ij}^{(k)} n_{ij}}$
2.  Update weights: $w_{ij}^{(k+1)} = w_{ij}^{(k)} \times A_i$
3.  Adjust weights to match margin 2:
    $B_j = \frac{M_j}{\sum_i w_{ij}^{(k+1)} n_{ij}}$
4.  Update weights: $w_{ij}^{(k+2)} = w_{ij}^{(k+1)} \times B_j$
5.  Iterate until convergence

### Example Calculation

Target: Age 18-34 = 30%, Observed: 20%

$$\text{Raking factor} = \frac{0.30}{0.20} = 1.50$$

## GREG (Generalized Regression) Estimation

### Calibration Framework

Recalibrate weights $d_i$ to $w_i$ such that $\sum_i w_i x_i = X$ (known
totals)

Minimize distance:
$D(d_i, w_i) = \frac{1}{2}\sum_{i \in s} \frac{(w_i - d_i)^2}{d_i}$

### GREG Weights

$$w_{i,GREG} = d_i \left[1 + (X - \hat{X}_d)^T T^{-1} x_i\right]$$

where:

-   $T = \sum_{i \in s} d_i x_i x_i^T$
-   $\hat{X}_d = \sum_{i \in s} d_i x_i$
-   $X$ = known population totals

### GREG Estimator

$$\hat{T}_{GREG} = \hat{T}_d + (X - \hat{X}_d)^T \hat{\beta}_w$$

$$= \sum_{i=1}^{N} \hat{y}_i^w + \sum_{i \in s} d_i(y_i - \hat{y}_i^w)$$

where $\hat{y}_i^w = x_i^T \hat{\beta}_w$ (weighted regression
prediction)

**Key Property**: Poststratification is a special case when X is
categorical with all interactions.

\newpage

# Non-Probability Samples

## Sources of Bias

| Type | Definition | Example |
|------------------|-------------------------------|------------------------|
| **Undercoverage** | Target population ≠ Covered population | Web survey excludes non-internet users |
| **Selection bias** | Some groups more likely to volunteer | Self-selected panels over-represent heavy internet users |

## Propensity Score Assumptions

For valid inference from non-probability samples:

| Assumption | Statement | Meaning |
|---------------------------|-------------------------|---------------------|
| **Conditional Exchangeability** | $\delta^{(np)} \perp Y | X$ | Participation independent of outcome given covariates |
| **Positivity** | $\pi_j^{(np)} > 0$ for all $j \in FP$ | All population units have positive participation probability |
| **Independence** | $Cov(\delta_i^{(np)}, \delta_j^{(np)} | x_i, x_j) = 0$ | Participation decisions are independent |
| **Reference survey** | Representative probability sample available | Need benchmark for adjustment |

## Propensity Score Methods

### PS Weighting: Adjusted Logistic Propensity (ALP)

**Step 1**: Combine non-probability sample ($s_{np}$) and weighted
probability sample ($s_p$)

**Step 2**: Fit logistic regression to estimate propensity:
$$\log\left(\frac{p(x_i)}{1-p(x_i)}\right) = \beta^T g(x_i)$$

**Step 3**: Compute weights:
$$w_i^{ALP} = \frac{1-\hat{p}_i}{\hat{p}_i}$$

**Step 4**: Estimate:
$$\bar{y}^{ALP} = \frac{\sum_{j \in s_{np}} w_j^{ALP} y_j}{\sum_{j \in s_{np}} w_j^{ALP}}$$

### PS Matching: Subclassification (PSC)

1.  Estimate propensity scores for combined sample
2.  Sort and partition into $G$ subclasses
3.  Within each subclass $g$:
    $$w_j^{PSC} = \frac{\sum_{k \in s_p(g)} d_k}{n_{np}(g)}$$

**Assumption**: Equal representation within subclasses

### PS Matching: Kernel Weighting (KW)

$$w_j^{KW} = \sum_{i \in s_p} \frac{K\left(\frac{p_i - p_j}{h}\right)}{\sum_{j' \in s_{np}} K\left(\frac{p_i - p_{j'}}{h}\right)} \cdot d_i$$

where $K(\cdot)$ = kernel function (e.g., standard normal), $h$ =
bandwidth

**Advantages**:

-   More stable than PS weighting
-   Robust to model misspecification
-   Doesn't require equal-probability-within-class assumption

### Comparison

| Method | Pros | Cons |
|-----------------------------|----------------------|----------------------|
| **PS Weighting (ALP)** | Corrects bias under true model | Sensitive to misspecification; extreme weights |
| **PS Subclassification** | More stable | Assumes equal representation in classes |
| **Kernel Weighting** | Robust, stable | More complex |

\newpage

# Model-Assisted Inference

## Key Principle

$$\text{Design-based validity} + \text{Model-based efficiency}$$

Use a **working model** to improve efficiency while maintaining
design-based validity.

## GREG as Model-Assisted Estimator

$$\hat{T}_w = \sum_{i=1}^{N} \hat{y}_i^w + \sum_{i=1}^{n} d_i(y_i - \hat{y}_i^w)$$

where $\hat{y}_i^w = x_i^T \hat{\beta}_w$ (design-weighted regression
prediction)

**Properties**:

-   **Design consistent**: Valid even if model is wrong
-   **Efficient**: If model is correct, variance is reduced

## Doubly Robust (DR) Estimator

$$\hat{T}_R = \sum_{i=1}^{N} \hat{y}_i + \sum_{i=1}^{n} d_i(y_i - \hat{y}_i)$$

where $\hat{y}_i = x_i^T \hat{\beta}_0$ (unweighted regression
prediction)

**Key Property**: Valid if **either** outcome model **OR** weight model
is correct.

## Estimator Comparison

| Estimator | Model | Weights | Valid If | Best When |
|---------------|---------------|---------------|---------------|---------------|
| **H-T** | None | In estimator | Probability sample | No auxiliary info |
| **GREG** | Yes (weighted) | In regression & residuals | Probability sample | Good auxiliaries |
| **DR** | Yes (unweighted) | Only in residuals | Model OR weights correct | Model approximately correct |

## Weighted vs Unweighted Estimation

### When to Use Weights

| Condition                 | Use Weights? | Reason                        |
|---------------------------|--------------|-------------------------------|
| Descriptive statistics    | **YES**      | Ensure representativeness     |
| Model misspecified        | **YES**      | Weights correct for selection |
| Sampling depends on $Y|X$ | **YES**      | Informative sampling          |
| Population inference      | **YES**      | Match target population       |

### When Unweighted May Be Valid

| Condition | Weights Optional? | Reason |
|--------------------|-----------------------------------|------------------|
| Model correct AND sampling independent of $Y|X$ | Yes | Model handles selection |
| Internal validity focus (associations) | Sometimes | Focus on relationships |
| All selection-related covariates in model | Yes | Model adjusts for selection |

**Decision Rule**: If in doubt, use weights.

\newpage

# Key Formulas Quick Reference

## Mean Squared Error

$$MSE(\hat{\theta}) = Var(\hat{\theta}) + [Bias(\hat{\theta})]^2$$

## Variance Estimation

| Design            | $\widehat{Var}(\bar{y})$              |
|-------------------|---------------------------------------|
| SRSWOR            | $(1-f)\frac{s^2}{n}$                  |
| Proportion        | $(1-f)\frac{\hat{p}(1-\hat{p})}{n-1}$ |
| Two-stage cluster | $(1-f)\frac{s_a^2}{a}$                |

## Bayesian Updates

| Prior | Likelihood | Posterior Mean |
|-----------------|------------------------|-------------------------------|
| $N(\mu_0, \sigma_0^2)$ | $N(\mu, \sigma^2/n)$ | $\frac{\tau_0 \mu_0 + \tau_{data}\bar{y}}{\tau_0 + \tau_{data}}$ |
| Beta$(\alpha, \beta)$ | Binomial$(n, \theta)$ | $\frac{\alpha + y}{\alpha + \beta + n}$ |

## Design Effects

| Type      | Formula                                  |
|-----------|------------------------------------------|
| General   | $DEFF = \frac{Var_{complex}}{Var_{SRS}}$ |
| Cluster   | $DEFF \approx 1 + (b-1)\rho$             |
| Weighting | $L \approx 1 + CV_w^2$                   |
| ESS       | $n_{eff} = n / DEFF$                     |

## Sample Size

| For         | Formula                        |
|-------------|--------------------------------|
| Proportions | $n = \frac{z^2 p(1-p)}{d^2}$   |
| Means       | $n = \frac{z^2 \sigma^2}{d^2}$ |

## Estimators

| Estimator | Formula |
|---------------------------------------|---------------------------------|
| H-T Total | $\hat{T}_{HT} = \sum_{i \in s} \frac{y_i}{\pi_i}$ |
| GREG | $\hat{T}_{GREG} = \hat{T}_d + (X - \hat{X}_d)^T \hat{\beta}_w$ |
| Poststrat weight | $w_{ps} = \frac{N_l}{\hat{N}_l}$ |
| ALP weight | $w^{ALP} = \frac{1-\hat{p}}{\hat{p}}$ |

## Transformations

| Transform | Formula | Variance |
|--------------------------|----------------------|------------------------|
| Logit | $\log(\frac{\hat{p}}{1-\hat{p}})$ | $\frac{Var(\hat{p})}{[\hat{p}(1-\hat{p})]^2}$ |

\newpage

# Appendix: R Code Templates

## Horvitz-Thompson Estimator

```r
#| eval: false
ht_estimate <- function(y, pi, N = NULL) {
  w <- 1/pi
  total <- sum(w * y)
  if (!is.null(N)) return(total / N)  # Mean
  return(total)  # Total
}
```

## GREG Estimator

```r
#| eval: false
greg_estimate <- function(sample_data, pop_data, formula, N) {
  # Weighted regression
  model <- lm(formula, data = sample_data, weights = d)
  
  # Predict for population
  pop_data$y_pred <- predict(model, newdata = pop_data)
  sample_data$resid <- sample_data$y - predict(model)
  
  # GREG = sum of predictions + weighted residuals
  mean(pop_data$y_pred) + sum(sample_data$d * sample_data$resid) / N
}
```

## Bayesian Finite Population Inference

```r
#| eval: false
bayes_fpi <- function(N, n, y, n_sims = 2500, alpha = 1, beta = 1) {
  # Posterior draws for theta
  theta <- rbeta(n_sims, alpha + y, beta + n - y)
  
  # Simulate non-sampled counts
  y_exc <- rbinom(n_sims, N - n, theta)
  
  # Population proportion
  (y + y_exc) / N
}

# Example usage
set.seed(740)
props <- bayes_fpi(N = 1000, n = 50, y = 38)
c(mean = mean(props), 
  lower = quantile(props, 0.025), 
  upper = quantile(props, 0.975))
```

## Design Effect Calculations

```r
#| eval: false
# Cluster DEFF
deff_cluster <- function(b, rho) {
  1 + (b - 1) * rho
}

# Weighting inefficiency
deff_weight <- function(cv_w) {
  1 + cv_w^2
}

# Effective sample size
ess <- function(n, deff) {
  n / deff
}
```

## Logit Transformation CI

```r
#| eval: false
logit_ci <- function(p_hat, var_p, alpha = 0.05) {
  z <- qnorm(1 - alpha/2)
  
  # Transform
  logit_p <- log(p_hat / (1 - p_hat))
  var_logit <- var_p / (p_hat * (1 - p_hat))^2
  se_logit <- sqrt(var_logit)
  
  # CI on logit scale
  ci_logit <- logit_p + c(-1, 1) * z * se_logit
  
  # Back-transform
  exp(ci_logit) / (1 + exp(ci_logit))
}
```
