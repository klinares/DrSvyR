---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class12_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class12_Lecture.pdf"
pages: 66
sha256: "b6a6abdd478f7a0f52a761592af4262e343d753f750178f0afdb592326a6c684"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:16"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #12

John Kubale

November 19, 2024

<!-- page 2 -->

# Outline

* Review
* Variable Transformation
    * Transforming Outcome Variables
    * Interpreting transformed variables
    * Polynomials
    * GAMs
* Model Selection
    * Background
    * Criterion-Based Procedures
    * Forward, Backward, Stepwise Selection

<!-- page 3 -->

# Review

<!-- page 4 -->

# Collinearity

* Eigenvalues, condition numbers, and kappa
* Variance inflation factor

<!-- page 5 -->

# Collinearity

* Eigenvalues – we’re concerned about any predictors with eigenvalues close to $0$ as a value of $0$ indicates perfect collinearity
* Condition numbers (and kappa) give us another way of assessing eigenvalues

<!-- page 6 -->

# Collinearity

* What does the formula below actually tell us?
* $condition\ number = \sqrt{\max(eigenvalue)/eigenvalue_i}$
  * The higher the condition number the greater the difference between your largest eigenvalue and the eigenvalue in the denominator
* Kappa is simply your largest condition number or
  * $\text{kappa}=\sqrt{\max(eigenvalue)/\min(eigenvalue)}$
  * We should investigate if kappa > 30
  * Does kappa >30 mean there is definitely collinearity?

<!-- page 7 -->

# Collinearity

No! Large condition numbers and/or a kappa > 30 only tells us that at least one of our eigenvalues is much smaller than our largest eigenvalue

This could be due to collinearity – denominator of condition number formula is close to 0 leading to large condition number/kappa

Could also be driven by very large maximum eigenvalue – numerator of condition number is large leading to large condition number/kappa

<!-- page 8 -->

# Variance inflation factor

* Should look at what potential collinearity is doing to our variance
  * Do we need to drop a variable?
  * If so, which one(s)?

$$VIF(\hat{\beta}_j) = \frac{1}{1 - R^2_{X_j|X_{-j}}}$$

* Rule of thumb in the social sciences is predictors with VIF > 5 or 10 are likely problematic
* Can also roughly interpret $\sqrt{VIF}$ as how much larger we would expect our standard error for that variable to be compared to if there were no collinearity
  * E.g., $VIF = 307.4 \rightarrow \sqrt{307.4} = 17.5$ would expect standard error to be 17.5 times larger than if no collinearity $\rightarrow$ while useful can't be applied as a correction because didn't actually observe orthogonal data

<!-- page 9 -->

# Variable Transformation

<!-- page 10 -->

# Why variable transformation?

Why transform?

* Can improve model fit
  * Linear relationship
  * Prediction
* Potential remedy when important OLS assumptions are violated
  * Zero error mean
  * Constant error variance

Why not transform?

* Interpretation difficulty (e.g., logwage)
* There are more flexible tools available

We will examine transformation through simulated data

<!-- page 11 -->

# Example: Simulated Data

```r
id<-c(1:1000)
set.seed(9); x<-rnorm(1000,7,4)
set.seed(123); e<-rnorm(1000,0,1)

y1<-1.5+0.3*x+e
y2<-1.5+5*log(x+6)+e
y3<-1.5+3*1/x+e
y4<-exp(1.5-0.3*x+e)-1
y5<-1/(1.5+3*x+e)
y6<-exp(1.5+3*log(x+6)+e)
```

1. What is being done in the data? Relationship between x and each of y1 to y6?

2. What would happen to the residuals and fitted values if we are to model each of y1 to y6 onto x in simple linear regression?

<!-- page 12 -->

# Example: Scatterplots Without Transformation

<!-- page 13 -->

# Example: Scatterplots with Transformation

<!-- page 14 -->

# Transforming Outcome Variables

<!-- page 15 -->

# Box-Cox Family of Transformation on Y

Seek a value of $\lambda$ such that $Y_i^{(\lambda)} = X\beta_i + \epsilon_i$ with $\epsilon_i \sim N(0, \sigma^2)$

Common in practice: $\lambda \in [-2, 2]$

$$
Y^{(\lambda)} = \begin{cases} \frac{Y^\lambda - 1}{\lambda} & \text{for } \lambda \neq 0 \\ \ln(Y) & \text{for } \lambda = 0 \end{cases}
$$

| | |
| :--- | :--- |
| $\lambda = 2$ | Squared Tranformation |
| $\lambda = 1$ | No Tranformation |
| $\lambda = 0.5$ | Square Root Tranformation |
| $\lambda = 0$ | Log Tranformation |
| $\lambda = -0.5$ | Inverse Square Root Tranformation |
| $\lambda = -1$ | Inverse Tranformation |
| $\lambda = -2$ | Inverse Squared Tranformation |

<!-- page 16 -->

# Log transformation of Y

<!-- page 17 -->

# Log transformation of Y

<!-- page 18 -->

# Log transformation of Y

* Potential issues with log transformation
  * Values $\le 0$ will cause issues
* Common tweaks:
  * Can add small increment to 0 values in data
  * Can add constant to all values. But what constant?
* $y' = \log(y + \alpha) \rightarrow$ want to find $\alpha$
* Can use the `logtrans()` function in the `MASS` package to find $\alpha$

<!-- page 19 -->

# Log transformation of Y

* Potential issues with log transformation
  * Values $\le 0$ will cause issues
* Common tweaks:
  * Can add small increment to 0 values in data
  * Can add constant to all values. But what constant?
* $y' = \log(y + \alpha) \rightarrow$ want to find $\alpha$
* Can use the `logtrans()` function in the `MASS` package to find $\alpha$

> Approach comes with some serious drawbacks as it can reduce interpretability, complicate assessment of goodness of fit, results in lost information, etc.

<!-- page 20 -->

# Interpretation of transformed variable

| Common Box-Cox Transformations | |
| :--- | :--- |
| **Lambda value ($\lambda$)** | **Transformed data ($Y'$)** |
| -3 | $Y^{-3} = 1/Y^3$ |
| -2 | $Y^{-2} = 1/Y^2$ |
| -1 | $Y^{-1} = 1/Y^1$ |
| -0.5 | $Y^{-0.5} = 1/(\sqrt{Y})$ |
| 0 | $\log(Y)^{**}$ |
| 0.5 | $Y^{0.5} = \sqrt{Y}$ |
| 1 | $Y^1 = Y$ |
| 2 | $Y^2$ |
| 3 | $Y^3$ |

https://www.statisticshowto.com/probability-and-statistics/normal-distributions/box-cox-transformation/

<!-- page 21 -->

# Example

- Let's start with some simulated data
- We'll first fit a linear regression model using OLS:
  - `mod <- lm(y ~ x1 + x2, dat)`

```r
library(mgcv)
library(MASS)
set.seed(123)
dat = gamSim(
  1,
  n = 400,
  dist = "normal",
  scale = 1,
  verbose = FALSE
)
```

<!-- page 22 -->

# Example

* Now let’s check our OLS assumptions, particularly homoscedasticity and error normality.
* What do you see?

<!-- page 23 -->

# Example

* Now let’s check our OLS assumptions, particularly homoscedasticity and error normality.
* What do you see? $\rightarrow$ Clear funnel shape and some issues with the tails.

<!-- page 24 -->

# Example

* We can use the boxcox() function to see if any transformations might make sense.
* In between 0.5 (square root transformation) and 1 (no transformation).
* Let’s try a square root transformation.

<!-- page 25 -->

# Example

* We can use the boxcox() function to see if any transformations might make sense.
* In between 0.5 (square root transformation) and 1 (no transformation).
* Let’s try a square root transformation.
  * ```r
    mod_t <- lm(sqrt(y) ~ x1 + x2, dat)
    ```

<!-- page 26 -->

# Example

* We can use the boxcox() function to see if any transformations might make sense.
* In between 0.5 (square root transformation) and 1 (no transformation).
* Let’s try a square root transformation.
  * 
```r
mod_t <- lm(sqrt(y) ~ x1 + x2, dat)
```

<!-- page 27 -->

# Example

* We can use the boxcox() function to see if any transformations might make sense.
* In between 0.5 (square root transformation) and 1 (no transformation).
* Let's try a square root transformation.
  * 
```r
mod_t <- lm(sqrt(y) ~ x1 + x2, dat)
```

<!-- page 28 -->

# Example

* We can use the boxcox() function to see if any transformations might make sense.
* In between 0.5 (square root transformation) and 1 (no transformation).
* Let's try a square root transformation.
  * 
```r
mod_t <- lm(sqrt(y) ~ x1 + x2, dat)
```

Helped a bit, but still issues with the lower tail.

<!-- page 29 -->

# Example

* We can use the boxcox() function to see if any transformations might make sense.
* In between 0.5 (square root transformation) and 1 (no transformation).
* Let's try a square root transformation.
  * ```r
    mod_t <- lm(sqrt(y) ~ x1 + x2, dat)
    ```

Helped a bit, but still issues with the lower tail.

What else could we try to address this?

<!-- page 30 -->

# Polynomial regression

<!-- page 31 -->

# Polynomial Regression

* Polynomial regression models can account for non-linear relationships by including different order polynomials (e.g., quadratic $[x^2]$, cubic $[x^3]$, etc.) as predictors.

<!-- page 32 -->

# Polynomial Regression

* Polynomial regression models can account for non-linear relationships by including different order polynomials (e.g., quadratic [$x^2$], cubic [$x^3$], etc.) as predictors.

We can see clear non-linear relationships between each predictor and the outcome.

Maybe polynomial regression can help.

Predictors vs. Y
x1
x2
Predictor

<!-- page 33 -->

# Polynomial Regression

Original model:
```r
lm(y ~ x1 + x2, dat)
```

Transformed model:
```r
lm(sqrt(y) ~ x1 + x2, dat)
```

* Let's try fitting 2 polynomial regression models:

Polynomial model 1:
```r
lm(y ~ x1 + x2 + I(x1^2) + I(x2^2), dat)
```

Polynomial model 2:
```r
lm(y ~ x1 + x2 + I(x1^2) + I(x2^2) + I(x2^3), dat)
```

<!-- page 34 -->

# Polynomial Regression

Polynomial model 1:

```r
lm(y ~ x1 + x2 + I(x1^2) + I(x2^2), dat)
```

<!-- page 35 -->

# Polynomial Regression

Polynomial model 1:

```r
lm(y ~ x1 + x2 + I(x1^2) + I(x2^2), dat)
```

QQ plot looks a lot better, but still see funnel shape in residuals/fitted plot suggesting heteroscedasticity.

Let's add a 3$^{rd}$ order polynomial to the model for x2 to see if that helps.

<!-- page 36 -->

# Polynomial Regression

Polynomial model 2:

```r
lm(y ~ x1 + x2 + I(x1^2) + I(x2^2) + I(x2^3), dat)
```

<!-- page 37 -->

# Polynomial Regression

Polynomial model 2:

```r
lm(y ~ x1 + x2 + I(x1^2) + I(x2^2) + I(x2^3), dat)
```

QQ plot looks a little worse than the first polynomial model, but funnel shape in residuals/fitted plot now gone.

So why can't we just keep adding higher order polynomials to our model?

<!-- page 38 -->

# Polynomial Regression

* Rarely will true exposure:outcome relationship actually be a quadratic or cubic relationship.
    * Can be a useful approximation, but very prone to overfitting.
* These limitations become particularly clear when we have more complex non-linear relationships.

<!-- page 39 -->

# Polynomial Regression – Example 2

- Let’s look at an example with a more complex relationship using some synthetic data.
- We’ll then fit multiple polynomial regression models with increasingly higher-order terms

```r
set.seed(123)


x  = runif(500)
mu = sin(2 * (4 * x - 2)) + 2 * exp(-(16 ^ 2) * ((x - .5) ^ 2))
y  = rnorm(500, mu, .3)
d  = data.frame(x, y)
```

https://m-clark.github.io/generalized-additive-models/case_for_gam.html#polynomial-regression-1

<!-- page 40 -->

# Polynomial Regression – Example 2

* Let’s loo ne synthetic
  data.
* We’ll the ly higher-order
  terms

```r
set.seed(

x  = runi
mu = sin(
y  = rnor
d  = data
```

https://m-clark.github.io/generalized-additive-models/case_for_gam.html#polynomial-regression-1

<!-- page 41 -->

# Polynomial Regression – Example 2

* Higher order polynomials still fit the data poorly in some areas and is frequently more “wiggly” than necessary.

https://m-clark.github.io/generalized-additive-models/case_for_gam.html#polynomial-regression-1

<!-- page 42 -->

# Generalized Additive Models (GAMs)

* Generalized additive models with smoothed predictors offer a solution

Generalized additive model:

$$Y = \beta_0 + f_1(X_1) + f_2(X_2) + \epsilon$$

Linear regression model:

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

<!-- page 43 -->

# Generalized Additive Models (GAMs)

Essentially can be thought of as breaking the model into different sections with each section fit using a function.

https://m-clark.github.io/generalized-additive-models/technical.html

<!-- page 44 -->

# Generalized Additive Models (GAMs)

Putting it all together we get something like this.

https://m-clark.github.io/generalized-additive-models/technical.html

<!-- page 45 -->

# Model Selection

<!-- page 46 -->

# Background

<!-- page 47 -->

# Why model selection?

* Model parsimony
  * Occam’s razor: “among several plausible explanations for a phenomenon, the simplest is often the best”
  * Can reduce noise (i.e., wasted degrees of freedom)
  * Can reduce data collection resources
* Depends on what you’re trying to do with the model
  * Explain a given phenomenon
  * Predict future observations

<!-- page 48 -->

# Model Selection Methods

* Technical procedures
    * Model comparison: General $F$-test (Class #5)
    * Predictor significance
    * Criterion-based: Akaike Information Criteria (AIC), Bayesian Information Criterion (BIC), Mallow’s $C_p$, Adjusted $R^2$, many more
    * Forward, Backward, Stepwise selection
    * These are all just techniques – consider as a reference
* Theoretical procedures
    * Explaining an outcome variable
    * Effect of a particular predictor
    * <u>**\*\*If there are important predictors, do not drop them merely based on the results of statistical techniques\*\***</u>
    * <u>**Consult subject matter of the analysis**</u> first and then consider carrying out mechanical/statistical procedures

<!-- page 49 -->

# General $F$-Test

* The more predictors to a model, the better the model explains the outcome, unless $Y \perp\!\!\!\perp X$
* We want **<u>parsimony</u>** in our model
* How do we know which model is better?

Consider a full model with $k$ predictors (including an intercept) and a reduced model with $p$ predictors

$$
\begin{aligned}
F &= \frac{(RSS_{Reduced} - RSS_{Full}) / (df_{Reduced} - df_{Full})}{RSS_{Full} / df_{Full}} \\
&= \frac{(RSS_{Reduced} - RSS_{Full}) / (k - p)}{RSS_{Full} / (n - k)} \sim F_{n - k}^{k - p} \\
\rightarrow \text{Test } &H_0 : RSS_{Reduced} = RSS_{Full}
\end{aligned}
$$

<!-- page 50 -->

# Criterion-Based Procedures

<!-- page 51 -->

# Likelihood Function

* Likelihood function: $\mathcal{L}(\theta|y) = P(Y = y|\theta) = f(y|\theta)$
  * $\theta$: parameters; $y$: observed data; $f$: probability density function
  * $\mathcal{L}(\theta|y) = \prod_i f(y_i|\theta)$
* Log-likelihood function: $\ell(\theta|y) = \log(\mathcal{L}(\theta|y))$
  * $\ell(\theta|y) = \log \prod_i (f(y_i|\theta)) = \sum_{i=1}^n \log(f(y_i|\theta)) \sum_i \ell(\theta|y_i)$
  * More desirable properties than $\mathcal{L}(\theta|y)$ (e.g., concave [remember Box-Cox], calculation

Maximum Likelihood Estimation (MLE)

* Find the values of the model parameters that maximize the likelihood function over the parameter space (i.e., the likelihood that the model produces the observed data)
* Log-likelihood is used in this process by solving its derivative with respect to $\theta$ set to 0
* Model with high or low log-likelihood?

<!-- page 52 -->

# Likelihood Function

* Likelihood function: $\mathcal{L}(\theta|y) = P(Y = y|\theta) = f(y|\theta)$
  * $\theta$: parameters; $y$: observed data; $f$: probability density function
  * $\mathcal{L}(\theta|y) = \prod_i f(y_i|\theta)$
* Log-likelihood function: $\ell(\theta|y) = \log(\mathcal{L}(\theta|y))$
  * $\ell(\theta|y) = \log \prod_i(f(y_i|\theta)) = \sum_{i=1}^n \log(f(y_i|\theta)) \sum_i \ell(\theta|y_i)$
  * More desirable properties than $\mathcal{L}(\theta|y)$ (e.g., concave [remember Box-Cox], calculation

Maximum Likelihood Estimation (MLE)

* Find the values of the model parameters that maximize the likelihood function over the parameter space (i.e., the likelihood that the model produces the observed data)
* Log-likelihood is used in this process by solving its derivative with respect to $\theta$ set to 0
* Model with high or low log-likelihood? Higher!

<!-- page 53 -->

# Akaike Information Criterion (AIC)

A model with $p$ predictors

$$AIC = -2\ell(\hat{\theta}) + 2p$$

* For linear regression
  * $-2\ell(\hat{\theta}) = n \log \frac{RSS}{n} + \text{constant}$
  * Constant is the same for a given outcome variable and assumed error distribution (can be ignored when comparing models)
* Model fit = simplicity
* Better model has smaller or larger AIC?
* Bayesian information criterion (BIC)
  * $BIC = -2\ell(\hat{\theta}) + p \log(n)$

<!-- page 54 -->

# Akaike Information Criterion (AIC)

A model with $p$ predictors

$$AIC = -2\ell(\hat{\theta}) + 2p$$

* For linear regression
  * $-2\ell(\hat{\theta}) = n \log \frac{RSS}{n} + \text{constant}$
  * Constant is the same for a given outcome variable and assumed error distribution (can be ignored when comparing models)
* Model fit = simplicity
* Better model has smaller or larger AIC? $\quad$ $\boxed{\text{Smaller!}}$
* Bayesian information criterion (BIC)
  * $BIC = -2\ell(\hat{\theta}) + p \log(n)$

<!-- page 55 -->

# Adjusted $R^2$

- $R^2 = \frac{SS_{reg}}{SS_y} = 1 - \frac{RSS}{SS_Y}$

- $R_a^2 = 1 - \frac{^{RSS}/_{(n-p)}}{^{SS_Y}/_{(n-1)}} = 1 - \frac{\hat{\sigma}_{model}^2}{\hat{\sigma}_{null}^2} = 1 - \frac{n-1}{n-p}(1 - R^2)$

- Want larger or smaller?

<!-- page 56 -->

# Mallow’s $C_p$

* $C_p = \frac{RSS_p}{\hat{\sigma}^2} + 2p - n$, where
  * $RSS_p$: $RSS$ of the reduced model with $p$ parameters
  * $n$: Sample size
  * $\hat{\sigma}^2$: $MSE$ of the full model with $k$ predictors $\hat{\sigma}^2 = RSS_k / (n - k)$

* $C_p = \frac{RSS_p - RSS_k}{\hat{\sigma}^2} + p - (k - p) = (k - p)(F_p - 1) + p$,

Where $F_p = \frac{(RSS_p - RSS_k)/((n - p) - (n - k))}{RSS_k / (n - k)}$

  * $C_p$ of full model = $p$
  * $C_p$ if $p$ predictor model fits $\approx p$
  * $C_p$ around or less than $p$ desirable

<!-- page 57 -->

# Mallow's $C_p$

* $C_p = \frac{RSS_p}{\widehat{\sigma}^2} + 2p - n$, where
  * $RSS_p$: $RSS$ of the reduced model with $p$ parameters
  * $n$: Sample size
  * $\widehat{\sigma}^2$: $MSE$ of the full model with $k$ predictors $\widehat{\sigma}^2 = RSS_k / (n - k)$

Want larger or smaller?

* $C_p = \frac{RSS_p - RSS_k}{\widehat{\sigma}^2} + p - (k - p) = (k - p)(F_p - 1) + p$,

Where $F_p = \frac{(RSS_p - RSS_k) / ((n - p) - (n - k))}{RSS_k / (n - k)}$
  * $C_p$ of full model $= p$
  * $C_p$ if $p$ predictor model fits $\approx p$
  * $C_p$ around or less than $p$ desirable

<!-- page 58 -->

# Mallow's $C_p$

* $C_p = \frac{RSS_p}{\hat{\sigma}^2} + 2p - n$, where
  * $RSS_p$: $RSS$ of the reduced model with $p$ parameters
  * $n$: Sample size
  * $\hat{\sigma}^2$: $MSE$ of the full model with $k$ predictors $\hat{\sigma}^2 = RSS_k / (n - k)$

Smaller!

* $C_p = \frac{RSS_p - RSS_k}{\hat{\sigma}^2} + p - (k - p) = (k - p)(F_p - 1) + p$,

Where $F_p = \frac{(RSS_p - RSS_k) / ((n - p) - (n - k))}{RSS_k / (n - k)}$

  * $C_p$ of full model $= p$
  * $C_p$ if $p$ predictor model fits $\approx p$
  * $C_p$ around or less than $p$ desirable

<!-- page 59 -->

# Forward, Backward, Stepwise Selection

<!-- page 60 -->

# Forward Selection

1. Start with a model only with an intercept as a running model
2. Choose the most significant predictor by running simple regressions and include it to the running model
3. Add one predictor among the remainder to the running model and choose the most significant set of two predictors
4. Continue until no additional predictors make a significant contribution to the model

Or replace predictor significance with AIC

<!-- page 61 -->

# Backward Selection

1. Start with the full model
2. Eliminate the least significant predictor and create a reduced model
3. Continue to eliminate the least significant predictor from reduced models
4. Continue until all variables in the model are significant

Or replace predictor significance

<!-- page 62 -->

# Stepwise Selection

Combination of Forward and Backward Selection

1. Start with an intercept only model
2. Choose the most significant predictor and add it to the model
3. Add each predictor among those remaining (one at a time) to the model and choose the most significant set of two predictors
4. Check if any variables become non-significant. If any are, then eliminate one at a time as in Backward selection
5. When no more variables can be eliminated, add variables to the model

Or replace predictor significance with AIC

<!-- page 63 -->

# Why might these methods be problematic?

<!-- page 64 -->

# Why might these methods be problematic?

* Summary of the problem: $E(\hat{\beta}|\hat{\beta}\ is\ significant) \neq \beta$ ([Chatfield, 1995]())
* Biased $R^2$, $\hat{\beta}$, standard errors, and p-values
* $F$ and $\chi^2$ statistics do not have the claimed distribution$^2$ ([Grambsch & O’Brien, 1991]())
* Will result in residual confounding if use variable selection to find confounders ([Greenland, 2000]())
* Derksen & Keselman ([1992]()) found that in stepwise analyses the final model represented noise 0.20-0.74 of time, final model usually contained <1/2 actual number of authentic predictors

https://hbiostat.org/rmsc/multivar#sec-multivar-variable-selection

<!-- page 65 -->

# Example: Issues with Technical Selection Methods

```r
set.seed(13)
dat <- data.frame(matrix(data = rnorm(2100, 0,1),
                        nrow = 100, ncol = 21))
colnames(dat)<-c("x1","x2","x3","x4","x5",
                 "x6","x7","x8","x9","x10",
                 "x11","x12","x13","x14","x15",
                 "x16","x17","x18","x19","x20","y")

dat.mod<-lm(y~.,dat)

summary(stepAIC(dat.mod,direction = "both"))
```

What do you expect to see in dat.mod?

<!-- page 66 -->

# Lab

What should we learn today?

* Variable transformation
  * How to find proper transformation for predictors
  * How to find proper transformation for the outcome
  * How to fit a polynomial regression
  * How do we interpret results when using variable transformation
  * How to fit a GAM
* Technical model selection
  * Criterion-based: AIC, Adjusted $R^2$, BIC, Mallow's $C_p$
