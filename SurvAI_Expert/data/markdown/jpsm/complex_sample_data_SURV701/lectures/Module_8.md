---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_8"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_8.pdf"
pages: 28
sha256: "da2ffffcccb0497ff99cb5bee6195a73d2adba8c6ca1b9d713dc47876de2bb03"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:53"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

SURV/SURVMETH 701

Lecture Notes: Module 8

## Linear Regression Review

Instructor: Yan Li

e-mail: [email]

1

<!-- page 2 -->

# Discussion Outline

## PART 1
* Simple Linear Regression
* Ordinary Least Squares (OLS)
* Model Building
* Regression Diagnostics
* Transformations
* Weighted Least Squares (WLS)

## PART 2
* Linear Regression for Complex Sample Survey Data

2

<!-- page 3 -->

# Regression Analysis

* **Regression Analysis**: A study of the relationship between variables.
* Two classes of variables: Response or dependent variables (“left hand side variables”) and predictor or independent variables (“right hand side variables,” covariates, explanatory variables, regressors, etc.).
* Objective: To ***infer*** about the expected value of the response or some characteristic of the distribution of the response variable ***conditional*** on the predictors.
* Predictors are assumed to be known or fixed constants.
* **Linear Model**: Refers to a class of models used to define this relationship that are linear functions of unknown parameters, $\beta$.
* $y =$ Response variable, $x =$ predictor variables

3

<!-- page 4 -->

# Steps in a Regression Analysis

1. **Postulate a model.** General behavior of the responses on the subjects for a given set of values of the predictors. The model is based on subject matter knowledge and empirical investigation of the data. The model will have a certain number of unknown quantities called parameters. <u>Not all subjects will exactly follow the pattern specified by the model</u>. The statistical errors or residuals are simple devices to account for the model’s failure to provide an exact fit.

2. **Analyze data to obtain the estimates of the parameters and their standard errors.**

3. **Diagnostics are used to examine the suitability of model.** This may lead to a modification of the model structure. We will then cycle back to the model fitting and model diagnosis process.

4. **The estimates and standard errors from the final model are then used characterize or infer about the conditional distribution of $y$ given $x$.**

4

<!-- page 5 -->

# Structure of the Regression Model

* Regression models the relationship of a function of the expected value of the dependent variable, $g(E(y))$, to the independent variables $\mathbf{x} = \{x_1, \dots, x_p\}$.

For regression models that are linear in the parameters:

$$
g(E(y)) = g(\hat{Y}) = \beta_o + \beta_1 x_1 + \cdots + \beta_p x_p
$$

5

<!-- page 6 -->

# Structure of the Regression Model

* The function $g(.)$ is called the link function

* Common links in applied regression analysis
  - Linear regression: Identity, $g(E(y))=E(y)$
  - Logistic regression: Logit, $g(E(y))=\log[E(y)/(1-E(y))]$
  - Probit regression: Probit, $g(E(y))=\Phi^{-1}(E(y))$
  - Poisson, NB: $g(E(y))=\log(E(y/t))=\log(E(y))-\log(t)$

6

<!-- page 7 -->

# Simple Linear Regression

Our focus will be on a broad class of models (at least for now) called ***Linear Models. These models are linear functions of unknown parameters.***

* <u>Linear models</u>

$$y = \beta_0 + \beta_1 x + \epsilon$$

$$y = \beta_0 + \beta_1 x + \beta_2 x^2 + \epsilon$$

$$\boldsymbol{y} = \boldsymbol{\beta x} + \boldsymbol{\epsilon}$$

* <u>Nonlinear models</u>

$$y = \beta_0 + \beta_1 x^{\beta_2} + \epsilon$$

$\beta_0, \beta_1, \beta_2$: unknown parameters

7

<!-- page 8 -->

# Estimation of the Parameters

* Approach to parameter estimation will depend on the link function, $g(.)$ and the assumed distribution of $Y$
* For example:
  - Linear regression
    * $g(E(y)) = E(y)$, $Y \sim N(X\beta, \sigma_{y.x})$
  - Logistic
    * $g(E(y) = \text{logit}(E(y))$, $Y \sim B(1, \pi(X))$

8

<!-- page 9 -->

# Simple Linear Regression Model

**<u>M1</u>:** $y_i = x_i\beta + \epsilon_i \text{ (vector notation)}$

$$= \beta_0 + \beta_1x_{1i} + \cdots + \beta_px_{pi} + \epsilon_i,$$

where

$$y_i \sim Normal(x_i\beta, \sigma^2)$$

$$\beta = \{\beta_0, \beta_1, \dots, \beta_p\}'$$

$$\epsilon_i = \text{residual for subject } i$$

$$E(\epsilon_i|x_i) = 0$$

$$Var(\epsilon_i|x_i) = \sigma^2(\text{constant variance})$$

$$Cov(\epsilon_i, \epsilon_j|x_i, x_j) = 0(\text{uncorrelated})$$

9

<!-- page 10 -->

# Simple Linear Regression Model

Implications:

$$
\begin{aligned}
\text{E}(y_i|x_i) &= E(x_i\beta) + E(\epsilon_i) = x_i\beta + 0 \\
&= x_i\beta \text{ (regression function)} \\
&= \beta_0 + \beta_1 x_{1i} + \dots + \beta_p x_{pi},
\end{aligned}
$$

with

$$x_i = \{1, x_{1i}, \dots x_{pi}\} \text{ and}$$

$$\beta = \{\beta_0, \beta_1, \dots, \beta_p\}'$$

$$\epsilon_i|x_i \sim Normal(0, \sigma^2)$$

$$Var(y_i|x_i) = \sigma^2$$

$$Cov(y_i, y_j|x_i, x_j) = 0$$

10

<!-- page 11 -->

# Interpretation of Regression Coefficients

* Simple Linear regression model

$$\text{E}(y|x = x_0) = \beta_0 + \beta_1 x_0$$

$$\text{E}(y|x = x_0 + 1) = \beta_0 + \beta_1 x_0 + \beta_1$$

* On the average, the expected change in $y$ for unit change in $x$

$$\beta_1 = \text{E}(y|x = x_0 + 1) - \text{E}(y|x = x_0)$$

* Add a confounding variable

$$\text{E}(y|x = x_0, z_0) = \beta_0 + \beta_1 x_0 + \beta_2 z_0$$

$$\text{E}(y|x = x_0 + 1, z_0) = \beta_0 + \beta_1 x_0 + \beta_1 + \beta_2 z_0$$

$$\beta_1 = \text{E}(y|x = x_0 + 1, z_0) - \text{E}(y|x = x_0, z_0)$$

$\beta_1 =$ the “expected” (average) change in y for one unit increase in the independent varaible x, holding z constant.

*A portion of x-y relationship is attributable to z*

11

<!-- page 12 -->

# Interpreting Linear Regression Coefficients: Intercept Terms

* Intercept $\beta_0 = \text{E}(y|x = 0, z = 0)$ is often not of much interest as it may represent expectation outside the range of data
* Re-formulation (centering) of the predictors in the model can make intercept interpretable

$$
y = \beta_0^* + \beta_1(x - \bar{x}) + \beta_2(z - \bar{z}) + \epsilon,
$$

$$
\beta_0^* = \bar{y} = \text{“}Centercept\text{”}
$$

* Models with no intercept force the regression through $y=0$, $x=0$.

12

<!-- page 13 -->

# Interpreting Linear Regression Coefficients: Nonlinear and Interaction terms

* Caution about interpreting with nonlinear terms:

$$y = \beta_0 + \beta_1 x + \beta_2 x^2 + \epsilon,$$

$\beta_1, \beta_2$ linked

$\beta_1$ alone in the presence of $\beta_2$ has no interpretation

$\beta_2$ measures the extent of nonlinearity

* Or interaction terms:

$$y = \beta_0 + \beta_1 x + \beta_2 z + \gamma_1 xz + \epsilon,$$

$\beta_1, \beta_2, \gamma_1$ linked

To determine the effect of an increase in $x$ on the expected value of $y$, must evaluate the functions at $x$ and $(x+1)$ and take the difference.

13

<!-- page 14 -->

# Indicator Variables (a.k.a. dummy variables)

* Required to represent effects of levels of categorical variables in regression models
* Several ways to specify, which determines how coefficients are interpreted
* Here: $(0,1)$ “parameterization”

14

<!-- page 15 -->

# Indicator Variables: Reference Category

e.g.

$$
X = \text{Race} = \begin{array}{cl}
1 & \text{White} \\
2 & \text{Black} \\
3 & \text{Other}
\end{array}
$$

Choose 1 reference category:
* Choose to aid your research objective
* **Some choose most prevalent group**

15

<!-- page 16 -->

# Indicator Variables: Category Examples

### Race

| 1 | 2 | 3 |
|---|---|---|

### Region

| 1 | 2 | 3 | 4 |
|---|---|---|---|

### Cataract

| 1 | 2 |
|---|---|

16

<!-- page 17 -->

# Indicator Variables: Example (0,1 Method)

$$Model: \quad Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2$$

$$X_1 = \begin{cases} 1 & \text{if race} = 2 \\ 0 & \text{otherwise} \end{cases}$$

$$X_2 = \begin{cases} 1 & \text{if race} = 3 \\ 0 & \text{otherwise} \end{cases}$$

$$\begin{aligned}
\text{Black R: } & Y = \beta_0 + \beta_1 \cdot 1 + \beta_2 \cdot 0 \\
\text{Other R: } & Y = \beta_0 + \beta_1 \cdot 0 + \beta_2 \cdot 1 \\
\text{White R: } & Y = \beta_0 + \beta_1 \cdot 0 + \beta_2 \cdot 0
\end{aligned}$$

17

<!-- page 18 -->

# Indicator Variables: Interpreting coefficients

$\beta_1$ is the effect on $\text{E}(g(y))$ of being Black vs. White

$\beta_2$ is the effect of being Other vs. White

$\beta_0$ is the effect of being White on $\text{E}(g(y))$

For this reference paramterization,

the effect of being Black vs. Other is:

$$
E\big( \ Y_{(Black)} \mid \underset{\sim}{x} \ \big) - E\big( \ Y_{(Other)} \mid \underset{\sim}{x} \ \big)
$$

$$
= \big[ \ \beta_1 \cdot 1 \ \big] - \big[ \ \beta_2 \cdot 1 \ \big]
$$

$$
= \beta_1 - \beta_2 \quad \quad \quad \quad \quad \quad \quad ,
$$

18

<!-- page 19 -->

# Software Defaults

* Stata: **svy: regress** command
  * Indicate categorical predictors in the list of predictors with i.catvar
  * Use ib3.catvar, for example, to set 3 as the reference category
  * This syntax will be demonstrated in examples

19

<!-- page 20 -->

# Estimation Method: Least Squares Estimation

* By far the most popular method for estimating the unknown parameters is the Method of Least Squares.
* Estimate $\beta$ by minimizing the residual sum of squares,

$$\sum_{i=1}^{n} (y_i - x_i\beta)^2$$

* Estimate of $\sigma^2$:

$$\hat{\sigma}^2 = \frac{\sum_{i=1}^{n} (y_i - x_i\beta)^2}{n - p - 1}$$

$p =$ number of covariates in the regression Model of M1

20

<!-- page 21 -->

# Properties of Least Squares Estimate

* Analytically simple. It is a linear function of the response values.
* Unbiased: $E(\hat{\beta}|x) = \beta$
* It has the lowest variance among all other unbiased estimates that are also linear functions of the response values. (B.L.U.E.)
* Under normal errors, the least squares estimates are also maximum likelihood estimates.
* Sampling distribution of the regression coefficients follows a $t$-distribution

$$\frac{\hat{\beta}_k - \beta_k}{se(\hat{\beta}_k)} \sim t_{n-p-1}$$

* It is sensitive to outliers, influential points, heteroskedastic variances!

21

<!-- page 22 -->

# Least Squares Regression:
# Comparison of Two Models

$x = (x_1, x_2)$

$x_1 = p_1$ predictors

$x_2 = p_2$ predictors

Compare:

$$y = x\beta + \epsilon \ (Full \ model)$$

*vs.*

$$y = x_1\beta_1 + \epsilon \ (reduced \ model)$$

Under $H_0: \beta_2 = \{\beta_{p_1+1}, \dots, \beta_p\} = \{0, \dots, 0\}$

$$F = \frac{\frac{SSE(reduced) - SSE(full)}{(n - p_1 - 1) - (n - p_1 - p_2 - 1)}}{\frac{SSE(full)}{(n - p_1 - p_2 - 1)}} \sim F(p_2, n - p_1 - p_2 - 1)$$

22

<!-- page 23 -->

# Confidence Interval (CI) for $E(y|x)$
# Prediction Interval Unknown $y$ Given $x$

$x_f$: Predictors; $y_f$: Unobserved $y$

$$
\underline{\hat{E}(y_f|x_f) = x_f\hat{\beta}}
$$

$$
\operatorname{var}(\hat{E}(y_f|x_f)) = x_f\Sigma(\hat{\beta})x_f
$$

$$
100(1-\alpha)\% \text{ CI:} \quad x_f\hat{\beta} \mp t_{1-\frac{\alpha}{2}, n-p-1}\sqrt{\operatorname{var}(\hat{E}(y_f|x_f))}
$$

$$
\underline{\hat{y}_f = x_f\hat{\beta} + \epsilon}
$$

$$
\operatorname{var}(\hat{y}_f) = x_f\Sigma(\hat{\beta})x_f + \hat{\sigma}^2
$$

$$
100(1-\alpha)\% \text{ prediction limits: } x_f\hat{\beta} \mp t_{1-\frac{\alpha}{2}, n-p-1}\sqrt{\operatorname{var}(\hat{E}(y_f|x_f)) + \hat{\sigma}^2}
$$

23

<!-- page 24 -->

# Diagnostics, Model Fit

* Non-normality of residuals
  * Diagnostic Plots (x-y, Q-Q plots, histograms)
  * Tests (e.g. Kolmogorov-Smirnov; very powerful against $\text{H}_\text{o}$)
* Heterogeneity of Variance
  * Diagnostic Plots
* Outliers
  * Residual plots
  * Influence statistics
    * Studentized residuals (y)
    * Hat statistics (leverage)
    * Cook’s D (influence)
    * Neter et al. (1996) for details

24

<!-- page 25 -->

# Residual Plots

* The residuals from the fitted model,
  $$e_i = (y_i - \hat{y}_i) = (y_i - x_i \hat{\beta}); i = 1, \dots, n$$
  provide information about the appropriateness of the model.

* Most diagnostic procedures involve inspecting the plots of the residuals.

* A plot of the residuals against the predictors can indicate non-linearity, non-constant variance (here a plot against the predicted values may be useful).

* Histogram of the residuals will be useful to detect departures from normality.

* A quantile-quantile plot is another graphical tool useful for detecting non-normality (this is a plot of quantiles estimated from residuals against those computed from a normal or theoretical distribution; a straight line indicates normality).

25

<!-- page 26 -->

# Transformation to Normality

* A common remedial measure for non-normality or heterogeneity of variance is transformation of the dependent variable.
* One has to be careful because it destroys the nice interpretation of the parameters.
* A common transformation that is often used (and still has nice interpretation) is the natural (base e) log-transformation:

$$\mathrm{L}og\ y = \beta_0 + \beta_1 x + \epsilon$$

$$\frac{E(y|x = x_0 + 1)}{E(y|x = x_0)} = e^{\beta_1}$$

26

<!-- page 27 -->

# Weighted Least Squares

* When the residual plots indicate evidence of non-constant variance, either the dependent variable is transformed or the variance can be directly modeled.
* When the variance is modeled, a **weighted least squares (WLS)** approach is used to estimate the parameters.
* <u>Weights in WLS</u> are inversely proportional to the residual variance.

$$WRSS = \sum_{i}^{n} w_{i,ls} (y_i - x_i \hat{\beta})^2 ,$$

$$x_i = (1, x_{i1}, \dots, x_{ip})$$

27

<!-- page 28 -->

# Example: heterogeneity of variance that is a function of a predictor variable.

$var(e_i) = \sigma^2 x_{i1}$

$x_{i1} = predictor\ (positive)$

$W_i = \frac{1}{\sigma^2 x_{i1}}$

$$WRSS = \sum_{i}^{n} \frac{(y_i - x_i\hat{\beta})^2}{\sigma^2 x_{i1}},$$

where

$$x_i = (1, x_{i1}, \dots, x_{ip})$$

28
