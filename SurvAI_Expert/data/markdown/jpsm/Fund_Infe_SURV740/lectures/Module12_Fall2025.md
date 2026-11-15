---
id: "jpsm/Fund_Infe_SURV740/lectures/Module12_Fall2025"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Fundamentals of Inference"
original: "Fund_Infe_SURV740/lectures/Module12_Fall2025.pdf"
pages: 37
sha256: "0161bfb395d9fcd5a3c855733267a3ebabc4a51ef9bb89f96518e965d133024c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:03"
---

<!-- page 1 -->

# Fundamentals of Inference

Yan Li ([email])
SurvMeth / Surv 740
Module 12, Fall 2025

<!-- page 2 -->

# Model-Assisted Inference

* **Design-based inference:**
  * Relies purely on the *randomization of the sampling design*.
  * The population values $y_i$ are treated as fixed, and randomness comes only from *which units were sampled*.
    Example: Horvitz–Thompson estimators in probability sampling.
* **Model-based inference:**
  * Assumes a *statistical model* (e.g., $y_i = x_i^\top \beta + \varepsilon_i$) for how the population values are generated.
  * The inference depends on the model’s validity rather than on the sampling design.
* **What model-assisted inference does?**
  * It still uses the **design-based framework** for validity
  * But it uses a **working model** to construct more efficient estimators

<!-- page 3 -->

**Formal** setup: Suppose we want to estimate the population total:

$$
Y = \sum_{i=1}^N y_i
$$

- Under a working model for $y_i$ such as

$$
y_i = \boldsymbol{x_i \beta} + e_i, E(e_i) = 0
$$

  We predict $\hat{y}_i^w = \boldsymbol{x}_i^\top \hat{\boldsymbol{\beta}}_w$,

$$
\hat{T}_M = \sum_{i=1}^N \hat{y}_i^w
$$

- Design-based estimator is

$$
\hat{T}_d = \sum_{i=1}^n d_i y_i
$$

- **Model-assisted** estimator is
  - **Design-consistent** (even if the model is wrong)
  - **Efficient** (if the model is approximately correct).

<!-- page 4 -->

# GREG: An Example of <u>Model-Assisted</u> Inference

* GREG estimator from Module 11: Define

$$
w_i = d_i \left\{ 1 + \left( \mathbf{X} - \widehat{\mathbf{X}}_{\mathrm{d}} \right)^T \mathbf{T}^{-1} \mathbf{x_i} \right\}
$$

$$
\mathbf{T} = \sum_{i=1}^n d_i \mathbf{x}_i \mathbf{x}_i^T
$$

$$
\widehat{\mathbf{X}}_{\boldsymbol{d}} = \sum_{i=1}^n d_i \mathbf{x}_i
$$

* We will show that there is an underlying linear model behind the development of these weights (the “assisting model”).

* For simplicity, we will focus on estimation of totals:

$$
\widehat{T}_w = \sum_{i=1}^n w_i y_i
$$

<!-- page 5 -->

$$
\begin{aligned}
\widehat{\boldsymbol{T}}_{\boldsymbol{w}} &= \sum_{i=1}^{n} \boldsymbol{w}_i \boldsymbol{y}_i \\
&= \sum_{i=1}^{n} \boldsymbol{d}_i \left\{ \boldsymbol{1} + \left( \boldsymbol{X} - \widehat{\boldsymbol{X}}_{\boldsymbol{d}} \right)^{\boldsymbol{T}} \boldsymbol{T}^{-1} \boldsymbol{x}_i \right\} \boldsymbol{y}_i \\
&= \sum_{i=1}^{n} \boldsymbol{d}_i \boldsymbol{y}_i + \sum_{i=1}^{n} \boldsymbol{d}_i \left\{ \left( \boldsymbol{X} - \widehat{\boldsymbol{X}}_{\boldsymbol{d}} \right)^{\boldsymbol{T}} \boldsymbol{T}^{-1} \boldsymbol{x}_i \right\} \boldsymbol{y}_i \\
&= \widehat{\boldsymbol{T}}_{\boldsymbol{d}} + \left( \boldsymbol{X} - \widehat{\boldsymbol{X}}_{\boldsymbol{d}} \right)^{\boldsymbol{T}} \boldsymbol{T}^{-1} \sum_{i=1}^{n} \boldsymbol{d}_i \boldsymbol{x}_i \boldsymbol{y}_i
\end{aligned}
$$

* Hence, the GREG estimator of the total is the **standard design-based estimator** ($\widehat{\text{T}}_d$) of the total *<u>plus a model-assisted correction</u> that adjusts for the difference between the known population totals* ($\boldsymbol{\text{X}}$) *for the auxiliary variables and the population totals for the auxiliary variables estimated from the sample* ($\widehat{\boldsymbol{\text{X}}}_{\boldsymbol{d}}$)*.*
  * Recall that poststratification is a special case – $\boldsymbol{\text{X}}$ is categorical, and includes all interactions

<!-- page 6 -->

$$
\begin{aligned}
\widehat{T}_w &= \widehat{T}_d + (X - \widehat{X})^T \widehat{\beta}_w \\
&= \sum_{i=1}^n d_i y_i + \sum_{i=1}^N x_i^T \widehat{\beta}_w - \sum_{i=1}^n d_i x_i^T \widehat{\beta}_w \\
&= \sum_{i=1}^N x_i^T \widehat{\beta}_w + \sum_{i=1}^n d_i \{y_i - x_i^T \widehat{\beta}_w\} \\
&= \sum_{i=1}^N \widehat{y}_i^w + \sum_{i=1}^n d_i \{y_i - \widehat{y}_i^w\} \\
&= \sum_{i=1}^N \widehat{y}_i^w
\end{aligned}
$$

* Alternatively, we can view this as resulting from a **prediction** across the population values of the auxiliary covariates, adjusted by a design-weighted sum of residuals.

* *Why does the last equality hold?*
  * What is the (weighted) mean of the residuals? Hence, what is the (weighted) sum?

<!-- page 7 -->

* We can replace the weighted regression estimator with an unweighted regression estimator
  * The model estimator is more stable, so *if the model is approximately correct*, variance will be reduced
  * We can still correct for model misspecification (at the cost of increased variance)

* We can replace the linear model with generalized linear model estimators (e.g., logistic regression).

<!-- page 8 -->

Let's consider a simulation study,

* Finite population of size $N = 10,000$. Each unit $i = 1, ..., N$ has three covariates:
  * $x_1 \sim N(0, 1)$ —a standard normal variable.
  * $x_2 \sim N(0, 4)$ —a normal variable with variance 4.
  * $x_3 \sim Bernoulli(0.2)$ —a binary indicator taking value 1 with 20% probability.
  * $y \sim N(\mu, 1)$ with $\mu = -2 + x_1 - x_2 + x_3 - x_1x_2$

* Survey sample: $n = 500$

$$mos_i = \exp(-2 + 0.5x_{1i} + 0.5x_{2i} + x_{3i})$$

$$d_i = \frac{\sum_{j=1}^N mos_j}{n \times mos_i}$$

We introduce unequal probability of selection, proportional to $mos_i$, the function of covariates. We then draw repeated probability samples of size 1,000.

<!-- page 9 -->

* **Design-based** Estimate of Mean Outcome (Horvitz-Thompson, or H-T, estimator):

$$\hat{\bar{Y}}_d = N^{-1} \sum_{i=1}^n d_i y_i$$

* **Model-assisted** Estimate of Mean Outcome (using $x_3$, $(x_1, x_3)$, or $(x_1, x_2, x_3)$ as predictors ) – design-weighted regression (GREG):

$$\hat{\bar{Y}}_w = N^{-1} \left( \sum_{i=1}^N \hat{y}_i^w + \sum_{i=1}^n d_i (y_i - \hat{y}_i^w) \right),$$

$$\hat{y}_i^W = \mathbf{x}_i^T \hat{\boldsymbol{\beta}}_w$$

$$\hat{\boldsymbol{\beta}}_w = \left( \sum_{i=1}^n d_i \mathbf{x}_i \mathbf{x}_i^T \right)^{-1} \left( \sum_{i=1}^n d_i \mathbf{x}_i^T y_i \right)$$

* **Model-assisted** Estimate of Mean Outcome ($x_3$, $(x_1, x_3)$, or $(x_1, x_2, x_3)$ as predictors ) – unweighted regression (Doubly Robust):

$$\hat{\bar{Y}}_R = N^{-1} \left( \sum_{i=1}^N \hat{y}_i + \sum_{i=1}^n d_i (y_i - \hat{y}_i) \right),$$

$$\hat{y}_i = \boldsymbol{X}_i^T \hat{\boldsymbol{\beta}}_0$$

$$\hat{\boldsymbol{\beta}}_0 = \left( \sum_{i=1}^n \mathbf{x}_i \mathbf{x}_i^T \right)^{-1} \left( \sum_{i=1}^n y_i \mathbf{x}_i^T \right)$$

<!-- page 10 -->

### Bias

**Estimator** &nbsp; GREG &nbsp; Doubly Robust &nbsp; H-T

Calibration Variables for GREG and DR: `x3`, `(x1,x3)`, `(x1,x2,x3)`, `(x1,x2,x3,x1*x2)`

### SE

Calibration Variables for GREG and DR: `x3`, `(x1,x3)`, `(x1,x2,x3)`, `(x1,x2,x3,x1*x2)`

### RMSE

Calibration Variables for GREG and DR: `x3`, `(x1,x3)`, `(x1,x2,x3)`, `(x1,x2,x3,x1*x2)`

**<u>Key Take-away</u>: Note that the model assistance (via GREG) gives us <u>highest-quality estimates</u> than the standard H-T and DR estimators, especially when predditor set correctly specify the outcome model!**

<!-- page 11 -->

We can repeat this using a binary indicator as the outcome.

This time, we get “assistance” from a logistic regression model:

$$
\log \left( \frac{P(Y_i = 1)}{1 - P(Y_i = 1)} \right) = \mathbf{X}_i^T \boldsymbol{\beta}
$$

<!-- page 12 -->

### Bias

**Estimator** &emsp; GREG &emsp; Doubly Robust &emsp; H-T

* **Bias**: 0.00, 0.02, 0.04, 0.06
* **Calibration Variables for GREG and DR**: `x3`, `(x1,x3)`, `(x1,x2,x3)`, `(x1,x2,x3,x1*x2)`

### SE

* **SE**: 0.00, 0.02, 0.04, 0.06
* **Calibration Variables for GREG and DR**: `x3`, `(x1,x3)`, `(x1,x2,x3)`, `(x1,x2,x3,x1*x2)`

### RMSE

* **RMSE**: 0.00, 0.02, 0.04, 0.06
* **Calibration Variables for GREG and DR**: `x3`, `(x1,x3)`, `(x1,x2,x3)`, `(x1,x2,x3,x1*x2)`

<u>**Key Take-away**</u>**: The model-assisted GREG approach continues to give us most efficient estimates, especially when predictor set correctly specify the outcome model!**

<!-- page 13 -->

# Role of Model in Design-Based Inference

* Previous slides have focused on inference about a (scalar) quantity, such as a population mean or total.
    * Descriptive statistics
* What about when we are interested in estimating parameters in a more complex regression model?
    * Analytic statistics

We will focus on simple no-intercept linear regression as an <u>example</u>.

$$Y_i = \beta X_i + \varepsilon_i, \quad \varepsilon_i \sim N(0, \sigma^2)$$

<!-- page 14 -->

In terms of **finite population inference**, we can consider fitting the linear model to the data from the entire population to obtain the population slope: that is, find B such that

$$\sum_{i=1}^N (Y_i - BX_i)X_i = 0$$

This yields to the population equivalent of the linear regression model solution:

$$B = \frac{\sum_{i=1}^N Y_i X_i}{\sum_{i=1}^N X_i^2}$$

<!-- page 15 -->

Note that B is unbiased for $\beta$ (under the superpopulation model) if the underlying model is correct in the population:

$$E_{Y|X}(B) = \frac{\sum_{i=1}^{N} X_i E_{\xi}(Y_i)}{\sum_{i=1}^{N} X_i^2} = \frac{\sum_{i=1}^{N} X_i^2 \beta}{\sum_{i=1}^{N} X_i^2} = \frac{\beta \sum_{i=1}^{N} X_i^2}{\sum_{i=1}^{N} X_i^2} = \beta$$

* Can think of the regression model as representing a superpopulation and the finite population as a simple random sample from that (infinite) superpopulation.

<!-- page 16 -->

What if the model is **misspecified**? Suppose we fit our linear slope model, but the true relationship in the population is quadratic, so that $E_{Y|X}(Y_i) = \beta X_i^2$ . Then:

$$
E_{Y|X}(B) = \frac{\sum_{i=1}^{N} X_i E_\xi(Y_i)}{\sum_{i=1}^{N} X_i^2} = \frac{\sum_{i=1}^{N} X_i^3 \beta}{\sum_{i=1}^{N} X_i^2} = \beta \frac{\sum_{i=1}^{N} X_i^3}{\sum_{i=1}^{N} X_i^2}
$$

* $B$ no longer estimates the true parameter governing this quadratic relationship, but rather the best linear approximation between $Y$ and $X$.

<!-- page 17 -->

# Visualization of Misspecification

<!-- page 18 -->

To deal with design issues, particularly unequal probabilities of selection, note that our score equation is just a population sum.

* Hence, we can just use our weighted sample sum to estimate the population sum, and solve for $\hat{B}$ using weighted totals:

$$\sum_{i=1}^{n} w_i (y_i - \hat{B}_w x_i) x_i = 0 \Rightarrow \hat{B}_w = \frac{\sum_{i=1}^{n} w_i y_i x_i}{\sum_{i=1}^{n} w_i x_i^2}$$

* This will be (approximately) unbiased for $B$, whatever its interpretation (superpopulation parameter or best linear approximation).
* If misspecified model: unbiased estimate (with respect to the sample design) of a poor model for the superpopulation!

<!-- page 19 -->

* Note that if the underlying model is correct and sampling is <u>independent</u> of the conditional distribution of $Y$ given $X$, the <u>unweighted</u> estimator will be <u>consistent</u> for $B$:

$$
\hat{B}_U = \frac{\sum_{i=1}^n y_i x_i}{\sum_{i=1}^n x_i^2} = \frac{\sum_{i=1}^N I_i X_i Y_i}{\sum_{i=1}^N I_i X_i^2}
$$

Since $I$ is independent of $Y|X$, we have

$$
E_I E_{Y|X}(\hat{B}_U) = E_I \frac{\sum_{i=1}^N I_i X_i E_{Y|X}(Y_i)}{\sum_{i=1}^N I_i X_i^2} = E_I \frac{B \sum_{i=1}^N I_i X_i^2}{\sum_{i=1}^N I_i X_i^2} = B
$$

(note this is <u>not</u> iterated expectation, it is taking expectation first with respect to the model and then with respect to the sample design.)

<!-- page 20 -->

* If the model is misspecified, however, we will need to use the <u>weighted</u> estimator of B even if sampling is <u>independent</u> of the conditional distribution of $Y$ given $X$, unless sampling is also independent of $X$.
  * **Question:** are we ever certain that the model has been correctly specified?

* If sampling is dependent on $Y$ given $X$, e.g., if observations with positive residuals are more likely to be sampled than observations with negative residuals, <u>weighted</u> estimator is required <u>regardless of model misspecification status</u> (i.e., unweighted estimator will be biased!).

<!-- page 21 -->

- Example shows when model miss-specified
  - Weighted and unweighted analyses results might differ.
- Regressed birthweight on gestational age, see Table 4.3-1.
  Different weighted and unweighted estimates of slopes.

**Table 4.3-1. Weighted and Unweighted Linear Regressions of Gestational Age$^a$ on Birth-weight (Sample Size = 9448)**

| Independent Variable | Weighted Analysis: Parameter Estimate | Weighted Analysis: Standard Error | Unweighted Analysis: Parameter Estimate | Unweighted Analysis: Standard Error |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | 32.08 | .17 | 26.36 | .14 |
| Birthweight (g) | .00215 | .00005 | .00383 | .00005 |

Data from the 1988 NMIHS.

$^a$Gestational age is operationally defined as the difference in the date of the last menstrual period and the date of delivery (in weeks). These dates are reported on the birth certificate.

<!-- page 22 -->

**Figure 4.3-1.** Plot of weighted mean gestational age versus weighted mean birthweight for successive groups of approximately 500 observations. Areas of bubbles are proportional to the estimated population sizes of the groups. The straight line is the weighted linear regression fit to the original (ungrouped) data.

<!-- page 23 -->

Figure 4.3-2 is analogous to Figure 4.3-1 Unweighted
Area of bubbles ~ group sample sizes.

**Figure 4.3-2.** Plot of mean gestational age versus mean birthweight for successive groups of approximately 500 observations. Areas of bubbles are proportional to the sample sizes of the groups. The straight line is the unweighted linear regression fit to the original (ungrouped) data.

<!-- page 24 -->

- Form 20 groups by birthweight with about 500 observations in each group.

- Figures 4.3-1

  Weighted mean gestational age vs. weighted mean birth weight  
  Area of bubbles $\sim$ estimated population size  
  Line is weighted linear regression in Table 4.3-1

- Figures 4.3-2

  Unweighted mean gestational age vs. unweighted mean birth weight  
  Area of bubbles $\sim$ sample size  
  Line is unweighted linear regression in Table 4.3-1

<!-- page 25 -->

**Conclusions:**

* Model is miss-specified: Quadratic not linear.
  – Sample and population birthweight distributions differ so weighted and unweighted analyses fit to different parts of population curve.

* Weighted analysis estimates population parameter B slope
  – Consistent for different sample designs.

* Unweighted estimator is not consistent
  – Varying by designs.

* When quadratic included
  – Weighted and unweighted analysis agree.

<!-- page 26 -->

# Final Exam Review

The Final Exam will be a 2.5-hour, in-class, open-notes, open-book exam on Dec 5, 2025, from 1-3:30pm.

**Topics to be covered:**

1. Basic concepts of design-based, model-based, and superpopulation inference approaches from the last six lectures (T/F; Multiple-choice)
2. Design-based inference under complex sampling, including design effect and ESS concepts (including related calculations)
3. Bias, Variance, and MSE of competing estimators
4. Bayesian finite population inference under a specified prior, likelihood, and posterior (including computation and interpretation of credible intervals)

<!-- page 27 -->

# Final Exam Review

**Strategies for success:**

1. Be prepared to conduct calculations efficiently in Excel or R (whichever you feel more comfortable with for evaluating expressions)
2. Submit your work on Canvas
3. Be prepared to submit your work, in the form of an Excel sheet or R script, along with your solutions
4. **Read the problems carefully, and only do what you are being asked to do (nothing more, nothing fancy)**
5. Review all lecture notes and readings (focusing on main takeaways from the readings)
6. Revisit all homework assignments and any errors made!

<!-- page 28 -->

# Model-Based Inference

Model-based inference focuses on incorporating the design directly into the model.

With **stratification**:

$$
y_{hi}|\mu_h, \sigma_h^2 \sim N(\mu_h, \sigma_h^2)
$$

This model allows for **different means and variances** across the $h = 1,...,H$ sample design strata (like having fixed effects of the strata in a regression model, allowing the error variance to change across the strata).

<!-- page 29 -->

We can carry out estimation of a population mean in the **Bayesian finite population inference** framework by proposing a prior $p(\mu_h, \sigma_h^2)$, e.g., using the flat prior $p(\mu_h, \log \sigma_h^2) \propto 1$, which yields the posterior

$$\mu_h | \bar{y}_h \sim t_{n_h - 1}\left(\bar{y}_h, \frac{(1 - f_h)s_h^2}{n_h}\right)$$

We can use simulation to empirically compute $P(\bar{Y} | \mathbf{y}, \mathbf{z})$ ($z_{li}$ being an indicator for stratum, equal to 1 if $l = h$ and 0 otherwise):

1) Draw $\bar{Y}_h^{rep}$ from $t_{n_h - 1}(\bar{y}_h, (1 - f_h)s_h^2 / n_h)$

2) Compute $\bar{Y}^{rep}$ as $\quad \frac{1}{N} \sum_h \left(n_h \bar{y}_h + (N_h - n_h)\bar{Y}_h^{rep}\right)$

3) Repeat 1,000 times

<!-- page 30 -->

Similarly, **cluster sampling** can be dealt with by using a random effects model (why <u>random</u> effects?):

$$y_{ki}|\mu, \sigma^2, b_k \sim N(\mu + b_k, \sigma^2)$$

$$b_k \sim N(0, \tau^2)$$

If $\sigma^2$ and $\tau^2$ are known, and the population sizes in each of the clusters is known, we can implement an algorithm to obtain draws of the population mean as follows (assuming a **flat prior** for $\mu, \ p(\mu) \propto 1$):

<!-- page 31 -->

1) For all clusters in the population, draw $\bar{Y}_k^{rep}$ from $N(\tilde{y}_k, v_k^2)$, where

$$\tilde{y}_k = w_k \bar{y}_k + (1 - w_k)\tilde{y},$$

$$w_k = \frac{n_k \tau^2}{n_k \tau^2 + \sigma^2}$$

$$\tilde{y} = \frac{\sum_k \frac{n_k \tau^2}{n_k \tau^2 + \sigma^2} \bar{y}_k}{\sum_k \frac{n_k \tau^2}{n_k \tau^2 + \sigma^2}}$$

$$v_k = (1 - f_k) \left( \sum_k \frac{n_k \tau^2}{n_k \tau^2 + \sigma^2} \right)^{-1}$$

For the sampled clusters

---

$$\tilde{y}_k = \tilde{y}$$

$$v_k = \left( \sum_k \frac{n_k \tau^2}{n_k \tau^2 + \sigma^2} \right)^{-1}$$

For the non-sampled clusters

<!-- page 32 -->

2) Compute $\bar{Y}_{rep}$ as

$$
N^{-1}\left[\sum_{k=1}^{K} N_k\left(\frac{n_k}{N_k}\bar{y}_k + \frac{N_k - n_k}{N_k}\bar{Y}_k^{rep}\right) + \sum_{k=K+1}^{M} N_k\bar{Y}_k^{rep}\right]
$$

assuming that the $K$ clusters are randomly sampled from a population of $M$ clusters

3) Repeat 1,000 times

<!-- page 33 -->

To **incorporate unequal probabilities of selection**, we return to the stratified model, where

$$y_{hi}|\mu_h, \sigma_h^2, (z_i = h) \sim N(\mu_h, \sigma_h^2)$$

Now the strata refer to the **elements** of the population **with equal probabilities of selection.**

In the case of a disproportionally stratified model, this yields (with flat priors on the means and variances) a posterior mean of the population mean equal to the weighted estimator:

$$E(\bar{Y}|y, z) = \sum_{h=1}^H P_h E(\bar{Y}_h|y, z) = N^{-1} \sum_{h=1}^H N_h \bar{y}_h$$

$$= N^{-1} \sum_{h=1}^H \frac{N_h}{n_h} \sum_{i=1}^{n_h} y_{hi} = N^{-1} \sum_{i=1}^n d_i y_i$$

where $d_i$ is the inverse of the probability of selection (a.k.a. the base weight, or selection weight).

<!-- page 34 -->

Alternatively, if each individual in the sample has a unique or nearly unique weight, we can think about **extensions**:

$$
Y_i \mid \pi_i \sim N(g(\pi_i), \pi_i^k \sigma^2)
$$

See Little and references for a discussion of this model using a “smoothing spline” for $g(\pi_i)$ and a fixed value of $k$.

<!-- page 35 -->

## Simulation: Unequal Probabilities of Selection

Consider three models for income:

1) $Y_i \sim N(\beta_0, \sigma^2)$

2) $Y_i \sim N(\beta_0 + \beta_1 \pi_i, \sigma^2)$

3) $Y_i \sim N(\beta_0 + \beta_1 \pi_i + \beta_2 \pi_i^2 + \beta_3 \pi_i^3, \sigma^2)$

* $\hat{\boldsymbol{\beta}} = (X^T X)^{-1} X^T \mathbf{y}$ where X is determined by the design matrix: a column of 1s for 1), column of 1s and $\pi_i$ for 2), column of 1s, $\pi_i$, $\pi_i^2$, and $\pi_i^3$ for 3).
* $\hat{\sigma}^2 = (n - 1)^{-1} \sum_{i=1}^n (y_i - \hat{y}_i)^2$ for $\hat{y}_i = \mathbf{x}_i^T \hat{\boldsymbol{\beta}}$ .

<!-- page 36 -->

Assume the probability of selection is known or estimable for all elements of the population.

Approximate draw from posterior distribution $p(\beta \mid \mathbf{y}, \boldsymbol{\pi})$ as follows (will cheat and treat $\sigma^2$ as known and equal to $\hat{\sigma}^2$):

1) Obtain posterior draw of $\boldsymbol{\beta}^{rep}$ from multivariate normal centered at $\widehat{\boldsymbol{\beta}}$ with covariance matrix $\hat{\sigma}^2 (X^T X)^{-1}$.
2) Compute $\bar{Y}^{rep}$ as $N^{-1} \left[ \sum_{i=1}^n y_i + \sum_{i=n+1}^N \hat{y}_i \right]$.

<!-- page 37 -->

| | H-T | Model 1 | Model 2 | Model 3 |
| :--- | :---: | :---: | :---: | :---: |
| Bias | **58** | -4407 | -1703 | 2018 |
| SE | 9332 | **7688** | 9247 | 10691 |
| RMSE | 9327 | **8858** | 9398 | 10874 |

Given these simulation results, which model would you choose?
