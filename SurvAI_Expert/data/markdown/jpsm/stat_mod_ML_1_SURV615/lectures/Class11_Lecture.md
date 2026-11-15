---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class11_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class11_Lecture.pdf"
pages: 61
sha256: "a6fd521c3f33408df3acfebd6dadda1896961d15578a66d20c98934fb452d833"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:23"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #11

John Kubale

November 12, 2024

<!-- page 2 -->

# Outline

* Problems with Model Errors – What do we do?
  * Zero Mean Assumption
  * Constant Variance Assumption
  * Normality Assumption
* Problems with Predictors
  * Collinearity
  * Variable Rescaling
* Lack of Fit

<!-- page 3 -->

# Announcements

* No quiz today!

<!-- page 4 -->

# Problems with Model Errors

What do we do?

<!-- page 5 -->

# Zero Mean Assumption

<!-- page 6 -->

# Zero Mean Error Violation

$E(\epsilon_i) \neq 0$

What is the problem?

* OLS estimators are not unbiased

  e.g., Cannot guarantee $E(\hat{\beta}_{OLS}) = \beta$

What to do?

* Include other predictors: e.g., polynomials or splines (Class #12), interactions
* Variable transformation (Class #12)

<!-- page 7 -->

# Constant Variance Assumption

<!-- page 8 -->

# Homoscedasticity (i.e., Constant Variance) Violation

$V(\epsilon_i) = \sigma^2 \text{ vs. } V(\epsilon_i) = \sigma_i^2$

What is the problem?

* Cannot guarantee that $\hat{V}(\hat{\beta})$ is unbiased of $V(\hat{\beta})$
* Any problem with using $\hat{\beta}_{OLS}$?

What to do?

* Heteroscedastic consistent variance estimator (will calculate in lab)
* Weighted least squares estimation (will do in lab)
* Variable transformation (Class #12)

<!-- page 9 -->

# Weighted Least Squares Estimators - 1

OLS:

* $min_{\boldsymbol{\beta}} \sum_{i=1} n(Y_i - \boldsymbol{X}_i\boldsymbol{\beta})^2$
* $\hat{\boldsymbol{\beta}}_{OLS} = (\sum_{i=1}^n \boldsymbol{X}_i^T \boldsymbol{X}_i)^{-1} \sum_{i=1}^n \boldsymbol{X}_i^T Y_i = (\boldsymbol{X}^T\boldsymbol{X})^{-1}\boldsymbol{X}^T\boldsymbol{Y}$

WLS:

* $min_{\boldsymbol{\beta}} \sum_{i=1} n w_i(Y_i - \boldsymbol{X}_i\boldsymbol{\beta})^2$ for a set of weights $w_i \ge 0$
* $\hat{\boldsymbol{\beta}}_W = (\sum_{i=1}^n w_i \boldsymbol{X}_i^T \boldsymbol{X}_i)^{-1} \sum_{i=1}^n w_i \boldsymbol{X}_i^T Y_i = (\boldsymbol{X}^T\boldsymbol{W}\boldsymbol{X})^{-1}\boldsymbol{X}^T\boldsymbol{W}\boldsymbol{Y}$
* $\boldsymbol{W} = diag(w_1, \cdots, w_n)$

OLS is a special case of WLS when $w_1 = \cdots = w_n = 1$ (i.e., $\boldsymbol{W} = \boldsymbol{I}_n$).

<!-- page 10 -->

# Weighted Least Squares Estimators - 2

What does WLS do?

* We are implicitly regressing $\sqrt{w_i}Y_i$ on $\sqrt{w_i}X_i$
* Residuals become $\sqrt{w_i}\hat{\epsilon}_i$ $\longrightarrow$ Observations with low variability get high weight and those with high variability get low weight.

How do we find $w_i$?

* **<u>Not easy!</u>**
* $V(\epsilon) \propto X_i \rightarrow w_i = X_i^{-1}$
* Use the absolute residuals
* Use the squared residuals

<!-- page 11 -->

# Weighted Least Squares Estimators - 3

What does WLS do?
* We are implicitly regressing $\sqrt{w_i}Y_i$ on $\sqrt{w_i}X_i$
* Residuals become $\sqrt{w_i}\hat{\epsilon}_i$

How do we find $w_i$?
* **<u>Not easy!</u>**
* $V(\epsilon) \propto X_i \rightarrow w_i = X_i^{-1}$
* Other common approaches
  * Use the absolute residuals
  * Use the squared residuals

Might choose this option after seeing positive relationship in plot of $|\hat{\varepsilon}_i|$ against $x_i$.

<!-- page 12 -->

# Normality Assumption

<!-- page 13 -->

# Non-normal Distribution of Errors

* What is the main issue if we reject the hypothesis of normally distributed errors?
* Problem: Cannot use the $t$-tests for $H_0: \beta_j = 0$
* Solution: Bootstrap standard error (more in Class #14) or Robust Regression (see Faraway text)

<!-- page 14 -->

# Problems with Predictors

<!-- page 15 -->

# Collinearity

<!-- page 16 -->

# Collinearity (i.e., Lack of identifiability)

* When some predictors are linear combinations of other predictors.
  * Called “exact collinearity”
* We’ve seen this before as a “lack of identifiability”.

<!-- page 17 -->

# Collinearity (i.e., Lack of identifiability)

Using the `Wage` dataset from the `ISLR2` package we'll fit a simple linear regression model with `wage` as a function of `jobclass` (specified as 2 dummy variables).

We'll create our dummy variables manually in this case. Specifically:

* indus: 1 = industrial; 0 = non-industrial
* info: 1 = information; 0 = non-information

```r
lm(wage ~ indus + info, Wage)
```

<!-- page 18 -->

# Collinearity (i.e., Lack of identifiability)

```r
Call:
lm(formula = wage ~ indus + info, data = wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.507 -25.362  -6.117  15.697 197.750 

Coefficients: (1 not defined because of singularities)
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  120.593      1.070  112.69   <2e-16 ***
indus        -17.272      1.492  -11.58   <2e-16 ***
info              NA         NA      NA       NA    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

<!-- page 19 -->

# Collinearity (i.e., Lack of identifiability)

```r
> head(model.matrix(mod_j1))
       (Intercept) indus info
231655           1     1    0
86582            1     0    1
161300           1     1    0
155159           1     0    1
11443            1     0    1
376662           1     0    1
```

Both of our predictors are dummy/indicator variables derived from the `jobclass` variable.

Does anything stand out?

They’re simply the inverse of each other. No additional information is provided by one that’s not already provided by the other. We’re trying to use 3 parameters to model only 2 groups.

<!-- page 20 -->

# Collinearity (i.e., Lack of identifiability)

* For a model $Y = X\beta + \epsilon$ with $\epsilon \sim N_n(\epsilon, \sigma^2 I_n)$ to be estimable $X$ needs to be of full column rank (i.e., no repeating information)
* $X_i = (1, X_{i1}, \dots, X_{ip})$, for a subject $i$ on $p$ variables, is referred as collinear if $X_{ij}$ can be expressed as linear combination of $X$'s
* Effect of collinearity
$V\big(\hat{\beta}_j\big) = \sigma^2 \frac{1}{1 - R_j^2} \frac{1}{\sum_{i=1}^n (X_{ij} - \bar{X}_j)^2}$, where
  * $\bar{X}_j = n^{-1} \sum_{i=1}^n X_{ij}$
  * $R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept
* No collinearity $\Leftrightarrow R_j^2 = 0 \Leftrightarrow V\big(\hat{\beta}_j\big) = \frac{\sigma^2}{\sum_{i=1}^n (X_{ij} - \bar{X}_j)^2} = \frac{\sigma^2}{S_{XX}}$
* Not no collinearity $\Leftrightarrow 0 < R_j^2 \le 1 \frac{\sigma^2}{S_{XX}} < V\big(\hat{\beta}_j\big) \le \infty$

<!-- page 21 -->

# How do we handle collinearity?

* Exact collinearity collinearity can be dealt with by removing one or more of the problematic variables $\rightarrow$ e.g., the reference group dummy variable.

<!-- page 22 -->

# How do we handle collinearity?

* Exact collinearity can be dealt with by removing one or more of the problematic variables $\rightarrow$ e.g., the reference group dummy variable.
* What about when the collinearity is not exact?
  * This is more difficult and requires careful assessment of how severe the collinearity (or multicollinearity) is.

<!-- page 23 -->

# Why might non-exact collinearity be problematic?

<!-- page 24 -->

# Collinearity Indicators

* To understand why collinearity (even when non-exact) can be problematic let's look at one of the indicators used to assess it.
    * Variance Inflation Factor

<!-- page 25 -->

# Collinearity Indicator - Variance Inflation Factor (VIF)

For a predictor $X_j$, $V(\hat{\beta}_j) = \sigma^2 \frac{1}{1-R_j^2} \frac{1}{(X_{ij} - \bar{X}_j)^2}$, where

$R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept

Variance Inflation Factor: $VIF_j = \frac{1}{1-R_j^2}$

When $X_j$ is orthogonal to other predictors

$\Leftrightarrow R_j^2 = 0 \Leftrightarrow VIF_j = 1$

When $X_j$ is highly correlated with other predictors

$\Leftrightarrow R_j^2 \to 1 \Leftrightarrow VIF_j \to \infty$

<!-- page 26 -->

# Collinearity Indicator - Variance Inflation Factor (VIF)

For a predictor $X_j$, $V(\hat{\beta}_j) = \sigma^2 \frac{1}{1 - R_j^2} \frac{1}{(X_{ij} - \bar{X}_j)^2}$, where

$R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept

Variance Inflation Factor: $VIF_j = \frac{1}{1 - R_j^2}$

When $X_j$ is orthogonal to other predictors

$\Leftrightarrow R_j^2 = 0 \Leftrightarrow VIF_j = 1$

When $X_j$ is highly correlated with other predictors

$\Leftrightarrow R_j^2 \to 1 \Leftrightarrow VIF_j \to \infty$

What would you expect $R_j^2$ to look like when there is substantial collinearity?

<!-- page 27 -->

# Collinearity Indicator - Variance Inflation Factor (VIF)

For a predictor $X_j$, $V(\hat{\beta}_j) = \sigma^2 \frac{1}{1-R_j^2} \frac{1}{(X_{ij}-\bar{X}_j)^2}$, where

$R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept

Variance Inflation Factor: $VIF_j = \frac{1}{1-R_j^2}$

More collinearity $\rightarrow$ Larger $R_j^2$
Less collinearity $\rightarrow$ Smaller $R_j^2$

When $X_j$ is orthogonal to other predictors

$\Leftrightarrow R_j^2 = 0 \Leftrightarrow VIF_j = 1$

What does this mean for the variance of our predictors?

When $X_j$ is highly correlated with other predictors

$\Leftrightarrow R_j^2 \rightarrow 1 \Leftrightarrow VIF_j \rightarrow \infty$

<!-- page 28 -->

# Collinearity Indicator - Variance Inflation Factor (VIF)

For a predictor $X_j$, $V(\hat{\beta}_j) = \sigma^2 \frac{1}{1-R_j^2} \frac{1}{(X_{ij}-\bar{X}_j)^2}$, where

$R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept

Variance Inflation Factor: $VIF_j = \frac{1}{1-R_j^2}$

More collinearity $\rightarrow$ Larger $R_j^2$ $\rightarrow$ Smaller denominator $\rightarrow$ Larger VIF
Less collinearity $\rightarrow$ Smaller $R_j^2$ $\rightarrow$ Larger denominator $\rightarrow$ Smaller VIF

$\Leftrightarrow R_j^2 = 0 \Leftrightarrow VIF_j = 1$

When $X_j$ is highly correlated with other predictors

$\Leftrightarrow R_j^2 \rightarrow 1 \Leftrightarrow VIF_j \rightarrow \infty$

<!-- page 29 -->

# Collinearity Indicator - Variance Inflation Factor (VIF)

For a predictor $X_j, V(\hat{\beta}_j) = \sigma^2 \frac{1}{1-R_j^2} \frac{1}{(X_{ij}-\bar{X}_j)^2}$, where

$R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept

Variance Inflation Factor: $VIF_j = \frac{1}{1-R_j^2}$

When $X_j$ is orthogonal to other predictors

$\Leftrightarrow R_j^2=0 \Leftrightarrow VIF_j=1$

When $X_j$ is highly correlated with other predictors

$\Leftrightarrow R_j^2 \rightarrow 1 \Leftrightarrow VIF_j \rightarrow \infty$

So, what would we expect to see with high collinearity/large VIF?

<!-- page 30 -->

# Collinearity example

Let's look at an example using the `seatpos` data from the `faraway` package

* Data on 38 drivers regarding where they prefer their seat position along with age and measures of physical size (weight, length of extremities, etc.)
* We'll fit a model with `hipcenter` (distance in mm from hips to fixed location in car) as a function of the other 8 variables in the dataset.
  * 
```r
lmod <- lm(hipcenter ~ ., seatpos)
```

<!-- page 31 -->

# Collinearity example

* Before we look at the model and VIF let's look at the correlation matrix for the predictors.
* Anything stand out?

```r
> round(cor(seatpos[,-9]),2)
          Age Weight HtShoes    Ht Seated  Arm Thigh   Leg
Age      1.00   0.08   -0.08 -0.09  -0.17 0.36  0.09 -0.04
Weight   0.08   1.00    0.83  0.83   0.78 0.70  0.57  0.78
HtShoes -0.08   0.83    1.00  1.00   0.93 0.75  0.72  0.91
Ht      -0.09   0.83    1.00  1.00   0.93 0.75  0.73  0.91
Seated  -0.17   0.78    0.93  0.93   1.00 0.63  0.61  0.81
Arm      0.36   0.70    0.75  0.75   0.63 1.00  0.67  0.75
Thigh    0.09   0.57    0.72  0.73   0.61 0.67  1.00  0.65
Leg     -0.04   0.78    0.91  0.91   0.81 0.75  0.65  1.00
> 
```

<!-- page 32 -->

# Collinearity example

* Before we look at the model and VIF let's look at the correlation matrix for the predictors.
* Anything stand out?

There are some pretty large pairwise correlations!
Ht:HtShoes, Seated:Ht, Seated:HtShoes, Ht:Weight, among others.

```r
> round(cor(seatpos[,-9]),2)
          Age Weight HtShoes    Ht Seated  Arm Thigh   Leg
Age      1.00   0.08   -0.08 -0.09  -0.17 0.36  0.09 -0.04
Weight   0.08   1.00    0.83  0.83   0.78 0.70  0.57  0.78
HtShoes -0.08   0.83    1.00  1.00   0.93 0.75  0.72  0.91
Ht      -0.09   0.83    1.00  1.00   0.93 0.75  0.73  0.91
Seated  -0.17   0.78    0.93  0.93   1.00 0.63  0.61  0.81
Arm      0.36   0.70    0.75  0.75   0.63 1.00  0.67  0.75
Thigh    0.09   0.57    0.72  0.73   0.61 0.67  1.00  0.65
Leg     -0.04   0.78    0.91  0.91   0.81 0.75  0.65  1.00
> 
```

<!-- page 33 -->

# Collinearity example

* Let’s look at the VIF for each predictor using the `vif()` function from the `faraway` package.
* Unsurprisingly Ht and HtShoes have the largest VIF suggesting a large amount of variance inflation.
* Specifically, taking $\sqrt{VIF}$ will let us approximate how much larger (i.e., inflated) the standard error of a given predictor is with this collinearity than if no collinearity was present in the model.

```r
> vif(lmod)
       Age     Weight    HtShoes         Ht     Seated        Arm      Thigh        Leg 
  1.997931   3.647030 307.429378 333.137832   8.951054   4.496368   2.762886   6.694291 
```

<!-- page 34 -->

# Collinearity example

* Let' ... edictor us ... om the `far` ...
* Uns ... have the ... ge amc ...
* Spe ... t us approximate how much larger (i.e., inflated) the standard error of a given predictor is with this collinearity than if no collinearity was present in the model.

> $\sqrt{307.43} = 17.5 \rightarrow$ the standard error for `HtShoes` in the model is 17.5 times larger than it would have been without collinearity.

> $\sqrt{333.14} = 18.3 \rightarrow$ the standard error for `Ht` in the model is 18.3 times larger than it would have been without collinearity.

```r
> vif(lmod)
       Age     Weight    HtShoes         Ht     Seated        Arm      Thigh        Leg 
  1.997931   3.647030 307.429378 333.137832   8.951054   4.496368   2.762886   6.694291 
```

<!-- page 35 -->

# Collinearity example

$\sqrt{307.43} = 17.5 \rightarrow$ the standard error for `HtShoes` is 17.5 times larger than it would have been without collinearity.

$\sqrt{333.14} = 18.3 \rightarrow$ the standard error for `Ht` is 18.3 times larger than it would have been without collinearity.

\*\*While we can't use this as a correction, it does give us a good sense of how severe the effect is.\*\*

```r
> vif(lmod)
       Age     Weight    HtShoes         Ht     Seated        Arm      Thigh        Leg 
  1.997931   3.647030 307.429378 333.137832   8.951054   4.496368   2.762886   6.694291 
```

<!-- page 36 -->

# Other indicators of collinearity

<!-- page 37 -->

# Collinearity Indicators

1. Variance Inflation Factor: Measure and assess existence of collinearity
2. Correlation among predictors: Assess existence of collinearity
3. Eigenvalues: Measure and understand collinearity
4. Condition Number/Index: Measure and understand collinearity

<!-- page 38 -->

# Collinearity Indicators

1. Variance Inflation Factor: Measure and assess existence of collinearity
2. Correlation among predictors: Assess existence of collinearity
3. Eigenvalues: Measure and understand collinearity
4. Condition Number/Index: Measure and understand collinearity

<!-- page 39 -->

# Collinearity Indicator 2 - Eigenvalues

OLS Estimators: $\hat{\boldsymbol{\beta}} = (\boldsymbol{X}^T\boldsymbol{X})^{-1}\boldsymbol{X}^T\boldsymbol{Y}$ $\quad V(\hat{\boldsymbol{\beta}}) = \sigma^2(\boldsymbol{X}^T\boldsymbol{X})^{-1}$

Spectral decomposition: $\boldsymbol{X}^T\boldsymbol{X} = \boldsymbol{V}\boldsymbol{D}^2\boldsymbol{V}^T$, where

$\boldsymbol{V}$ is a $p \times p$ matrix such that $\boldsymbol{V}\boldsymbol{V}^T = \boldsymbol{I}_p$,

$\boldsymbol{D}^2$ is a $p \times p$ diagonal matrix such that $\boldsymbol{D}^2 = diag(d_1^2, \cdots, d_p^2)$,

$d_1^2, \cdots, d_p^2$ values are the eigenvalues of $\boldsymbol{X}^T\boldsymbol{X}$,

the columns of $\boldsymbol{V}$ contain the associated eigenvectors.

Also, $(\boldsymbol{X}^T\boldsymbol{X})^{-1} = \boldsymbol{V}\boldsymbol{D}^{-2}\boldsymbol{V}^T$, where

$\boldsymbol{D}^{-2} = diag(d_1^{-2}, \cdots, d_p^{-2})$

$d_1^{-2}, \cdots, d_p^{-2}$ are the eigenvalues of $(\boldsymbol{X}^T\boldsymbol{X})^{-1}$

Eigenvalues provide information about the behavior of OLS estimates as

$$V(\hat{\boldsymbol{\beta}}) = \sigma^2(\boldsymbol{X}^T\boldsymbol{X})^{-1} = \sigma^2\boldsymbol{V}\boldsymbol{D}^{-2}\boldsymbol{V}^T$$

Therefore, $d_j^2 \to 0 \quad \Leftrightarrow \quad d_j^{-2} \to \infty \quad \Leftrightarrow \quad V(\hat{\beta}_j) \to \infty$

<!-- page 40 -->

# Collinearity Indicator 2 - Eigenvalues

OLS Estimators: $\hat{\boldsymbol{\beta}} = (\boldsymbol{X}^T\boldsymbol{X})^{-1}\boldsymbol{X}^T\boldsymbol{Y}$ $\quad V(\hat{\boldsymbol{\beta}}) = \sigma^2(\boldsymbol{X}^T\boldsymbol{X})^{-1}$

Spectral decomposition: $\boldsymbol{X}^T\boldsymbol{X} = \boldsymbol{V}\boldsymbol{D}^2\boldsymbol{V}^T$, where
$\boldsymbol{V}$ is a $p \times p$ matrix such that $\boldsymbol{V}\boldsymbol{V}^T = \boldsymbol{I}_p$,
$\boldsymbol{D}^2$ is a $p \times p$ diagonal matrix such that $\boldsymbol{D}^2 = diag(d_1^2, \cdots, d_p^2)$

* Eigenvalue of $0$ indicates exact collinearity.
* Several small eigenvalues suggests multicollinearity.
* Smaller eigenvalue $\rightarrow$ more problematic collinearity.

Also, $(\boldsymbol{X}^T\boldsymbol{X})^{-1} = \boldsymbol{V}\boldsymbol{D}^{-2}\boldsymbol{V}^T$, where
$\boldsymbol{D}^{-2} = diag(d_1^{-2}, \cdots, d_p^{-2})$
$d_1^{-2}, \cdots, d_p^{-2}$ are the eigenvalues of $(\boldsymbol{X}^T\boldsymbol{X})^{-1}$

Eigenvalues provide information about the behavior of OLS estimates as
$$V(\hat{\boldsymbol{\beta}}) = \sigma^2(\boldsymbol{X}^T\boldsymbol{X})^{-1} = \sigma^2\boldsymbol{V}\boldsymbol{D}^{-2}\boldsymbol{V}^T$$

Therefore, $d_j^2 \rightarrow 0 \quad \Leftrightarrow \quad d_j^{-2} \rightarrow \infty \quad \Leftrightarrow \quad V(\hat{\beta}_j) \rightarrow \infty$

<!-- page 41 -->

# Collinearity Indicator 4 – Condition Number/Kappa

Overall measure of the eigenvalues of $X^T X$

Condition number: $\mathcal{K} = \sqrt{\frac{max_{(1 \le j \le p)} d_j}{min_{(1 \le j \le p)} d_j}}$

> Condition number ($\mathcal{K}$)/indices ($n_j$) provide a means for identifying whether there are concerning eigenvalues.

**Large $\mathcal{K}$: At least one of the eigenvalues is small relative to the rest**

Condition index: $n_j = \sqrt{\frac{max_{(1 \le j \le p)} d_j}{d_j}}$ for $j = 1, \dots, p$

Largest $n_j = \mathcal{K}$

> Condition number ($\mathcal{K}$)$\ge 30$ is considered large.
> Still worth examining other condition indices ($n_j$), as there may be more than one linear combination contributing to the collinearity.

<!-- page 42 -->

# Practical Guidelines for Collinearity

Diagnostics

1. Find $\mathcal{K} \ge 30$ and examine other $n_j$
2. Examine VIF
3. Examine correlation – Remember this is only looking at pairwise correlation

What to do?

* Remove predictors(s) with large collinearity $\rightarrow$ not always ideal/feasible
* Ridge regression – see SURV 616/SURVMETH 686

<!-- page 43 -->

# Collinearity – Summing Up

* What does the formula below actually tell us?
* $condition\ number = \sqrt{\max(eigenvalue) / eigenvalue_i}$
  * The higher the condition number the greater the difference between your largest eigenvalue and the eigenvalue in the denominator
* Kappa is simply your largest condition number or
  * $\text{kappa} = \sqrt{\max(eigenvalue) / \min(eigenvalue)}$
  * We should investigate if kappa > 30
  * Does kappa >30 mean there is definitely collinearity?

<!-- page 44 -->

# Collinearity – Summing Up

No! Large condition numbers and/or a kappa > 30 only tells us that at least one of our eigenvalues is much smaller than our largest eigenvalue

This could be due to collinearity – denominator of condition number formula is close to 0 leading to large condition number/kappa

Could also be driven by very large maximum eigenvalue – numerator of condition number is large leading to large condition number/kappa

<!-- page 45 -->

# Collinearity – Summing Up

* Should look at what potential collinearity is doing to our variance
  * Do we need to drop a variable?
  * If so, which one(s)?

$$VIF(\hat{\beta}_j) = \frac{1}{1 - R_{X_j|X_{-j}}^2}$$

* Rule of thumb in the social sciences is predictors with VIF > 5 are likely problematic
* Can also roughly interpret $\sqrt{VIF}$ as how much larger we would expect our standard error for that variable to be compared to if there were no collinearity
  * E.g., $VIF = 307.4 \rightarrow \sqrt{307.4} = 17.5$ would expect standard error to be 17.5 times larger than if no collinearity $\rightarrow$ while useful can’t be applied as a correction because didn’t actually observe orthogonal data

<!-- page 46 -->

# Variable Rescaling

<!-- page 47 -->

# Rescaling Predictors (and Outcomes)

Why rescaling?

* The range is really large or really small

$\rightarrow$Estimated coefficients may be too small or too large

* Different measurement systems

$\rightarrow$Interpretation of estimated coefficients may not be straight-forward

* Different relationship between $Y$ and a numeric $X$ depends on the range of $X$

$\rightarrow$Recode $X$ as a categorical variable

* Rescaling does not change hypothesis testing, but does change the magnitudes of model parameters

* NOT TRANSFORMATION

<!-- page 48 -->

# Rescaling the outcome – Example

* Fit model of median value of owner-occupied home in \$1000 (`medv` in `Boston` dataset) predicted by `tax` (full property tax rate per \$10,000)

```r
mod1 <- lm(medv ~ tax, Boston)
```

* Put `medv` back on original scale and fit model

```r
mod2 <- lm((medv*1000) ~ tax, Boston)
```

<!-- page 49 -->

# Rescaling your outcome

Rescaling your outcome doesn't impact the relationship, only the units on which it's being assessed.

```r
Call:
lm(formula = medv ~ tax, data = Boston)

Residuals:
    Min      1Q  Median      3Q     Max 
-14.091  -5.173  -2.085   3.158  34.058 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 32.970654   0.948296   34.77   <2e-16 ***
tax         -0.025568   0.002147  -11.91   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 8.133 on 504 degrees of freedom
Multiple R-squared:  0.2195,	Adjusted R-squared:  0.218 
F-statistic: 141.8 on 1 and 504 DF,  p-value: < 2.2e-16
```

```r
Call:
lm(formula = (medv * 1000) ~ tax, data = Boston)

Residuals:
   Min     1Q Median     3Q    Max 
-14091  -5173  -2085   3158  34058 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 32970.654    948.296   34.77   <2e-16 ***
tax           -25.568      2.147  -11.91   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 8133 on 504 degrees of freedom
Multiple R-squared:  0.2195,	Adjusted R-squared:  0.218 
F-statistic: 141.8 on 1 and 504 DF,  p-value: < 2.2e-16
```

<!-- page 50 -->

# Rescaling your predictor

* Fit model of median value of owner-occupied home in \$1000 (`medv` in `Boston` dataset) predicted by `tax` (full property tax rate per \$10,000)

```r
mod1 <- lm(medv ~ tax, Boston)
```

* Put `tax` back on original scale and fit model

```r
Boston$tax2 <- Boston$tax*10000
mod3 <- lm(medv ~ tax2, Boston)
```

<!-- page 51 -->

# Rescaling your predictor

Rescaling your predictor doesn't impact the relationship, only the units on which it's being assessed.

```r
Call:
lm(formula = medv ~ tax, data = Boston)

Residuals:
    Min      1Q  Median      3Q     Max 
-14.091  -5.173  -2.085   3.158  34.058 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 32.970654   0.948296   34.77   <2e-16 ***
tax         -0.025568   0.002147  -11.91   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 8.133 on 504 degrees of freedom
Multiple R-squared:  0.2195,	Adjusted R-squared:  0.218 
F-statistic: 141.8 on 1 and 504 DF,  p-value: < 2.2e-16
```

```r
Call:
lm(formula = medv ~ tax2, data = Boston)

Residuals:
    Min      1Q  Median      3Q     Max 
-14.091  -5.173  -2.085   3.158  34.058 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)  3.297e+01  9.483e-01   34.77   <2e-16 ***
tax2        -2.557e-06  2.147e-07  -11.91   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 8.133 on 504 degrees of freedom
Multiple R-squared:  0.2195,	Adjusted R-squared:  0.218 
F-statistic: 141.8 on 1 and 504 DF,  p-value: < 2.2e-16
```

<!-- page 52 -->

# Lack of Fit

<!-- page 53 -->

# Lack of fit

* We’ve talked about how we might compare fit between models, but what about fit of a given model?
  * Ideally we would compare $\hat{\sigma}^2$ to $\sigma^2$ -- so why don’t we?

<!-- page 54 -->

# Lack of fit

* We’ve talked about how we might compare fit between models, but what about fit of a given model?
  * Ideally we would compare $\hat{\sigma}^2$ to $\sigma^2$ -- so why don’t we?
  * Don’t generally know $\sigma^2$
* So, what can we do?

<!-- page 55 -->

# Lack of Fit

* Need to compare $\hat{\sigma}^2$ to some model-free estimator of $\sigma^2$
* When we have repeated values can use this to our advantage
  * Must be independent (i.e., can’t be repeated measures of same individuals)!

$n$ values for a predictor variable, and

$m_i$ observations of the outcome variable for the $i^{th}$ value of the predictor variable

$$
Y_{ij} = \beta_0 + \beta_1 X_{1i} + \epsilon_{ij},
$$

Where $i = 1, \dots, n; j = 1, \dots, m_i$ and $\epsilon_{ij} \sim N(0, \sigma^2)$

$$
\rightarrow \bar{Y}_i = \frac{\sum_{i=1}^{m_i} Y_{ij}}{m_i} \sim N(\beta_0 + \beta_1 X_{1i}, \frac{\sigma^2}{m_i})
$$

<!-- page 56 -->

# Lack of Fit

* Need to compare $\hat{\sigma}^2$ to some model-free estimator of $\sigma^2$
* When we have repeated values can use this to our advantage
  * Must be independent (i.e., can’t be repeated measures of same individuals)!

Let $y_{ij}$ represent the $i^{th}$ observation in a group of true replicates $j$

The pure error (model-free estimate of $\sigma^2$) is given by $\frac{SS_{pe}}{df_{pe}}$ and

$$
SS_{pe} = \sum_i \sum_j (y_{ij} - \bar{y}_j)^2
$$

Where $\bar{y}_j$ is the mean within replicate group $j$.

$df_{pe} = \#replicates_j - 1 = n - \# \text{ groups}$

<!-- page 57 -->

# Lack of Fit

* Need to compare $\hat{\sigma}^2$ to some model-free estimator of $\sigma^2$
* When we have repeated values can use this to our advantage
  * Must be independen... ...ndividuals)!

So how do go about getting this model-free estimate of $\sigma^2$ AKA pure error?

Let $y_{ij}$ represent the $i^{t}$... ...cates $j$

The pure error (model-free estimate of $\sigma^2$) is given by $\frac{SS_{pe}}{df_{pe}}$ and

$$
SS_{pe} = \sum_i \sum_j (y_{ij} - \bar{y}_j)^2
$$

Where $\bar{y}_j$ is the mean within replicate group $j$.

$df_{pe} = \#replicates_j - 1 = n - \#\ groups$

<!-- page 58 -->

# Lack of Fit

Estimating “pure error”

* Fit a model where a parameter is estimated for each group of observations for a given value of $x$.
  * We can do this in R by wrapping a continuous predictor in the `factor()` function when we fit the model.
* The $\hat{\sigma}^2$ from this model will be our “pure error”.
* This model in itself tells us nothing interesting about the predictors relationship with the response, it simply fits a mean to each group of replicates.
  * Values of $x$ without replicates are estimated exactly and don’t contribute to $\hat{\sigma}^2$.
* We can then compare this model with the regression model of interest using an F test.

<!-- page 59 -->

# Lack of Fit Testing - 1

$$
\begin{aligned}
RSS &= \sum_{i=1}^n \sum_{j=1}^{m_i} (Y_{ij} - \hat{Y}_i)^2 \\
&= \sum_{i=1}^n \sum_{j=1}^{m_i} ((Y_{ij} - \bar{Y}_i) + (\bar{Y}_i - \hat{Y}_i))^2 \\
&= \sum_{i=1}^n \sum_{j=1}^{m_i} (Y_{ij} - \bar{Y}_i)^2 + \sum_{i=1}^n \sum_{j=1}^{m_i} (\bar{Y}_i - \hat{Y}_i)^2 \\
&\quad + 2 \sum_{i=1}^n \sum_{j=1}^{m_i} (Y_{ij} - \bar{Y}_i)(\bar{Y}_i - \hat{Y}_i) \\
&= \sum_{i=1}^n \sum_{j=1}^{m_i} (Y_{ij} - \bar{Y}_i)^2 + \sum_{i=1}^n m_i (\bar{Y}_i - \hat{Y}_i)^2 \\
&= \boxed{RSS_{PureError} + RSS_{LackofFit}}
\end{aligned}
$$

<!-- page 60 -->

# Lack of Fit Testing - 2

When using all $m_i$ observations,

$$RSS_{PureError} = \sum_{i=1}^n \sum_{j=1}^{m_i} (Y_{ij} - \bar{Y}_i)^2$$

with $df_{PureError} = df_{TotalError} - df_{LackofFit} = \sum_{i=1}^n (m_i - 1)$

$$\to RSS_{PureError} \sim \sigma^2 \chi^2_{df_{PureError}}$$

$$RSS_{LackofFit} = \sum_{i=1}^n m_i (\bar{Y}_i - \hat{Y}_i)^2$$

with $df_{LackofFit} = df_{TotalError} - df_{PureError} = n - 2$

$$\to RSS_{LackofFit} \sim \sigma^2 \chi^2_{df_{LackofFit}}$$

As $RSS_{PureError}$ and $RSS_{LackofFit}$ are independent,

$F$-test of lack of fit:

$$F = \frac{MSE_{LackofFit}}{MSE_{PureError}} = \frac{RSS_{LackofFit} / df_{LackofFit}}{RSS_{PureError} / df_{PureError}} \sim F^{df_{LackofFit}}_{df_{PureError}}$$

<!-- page 61 -->

# Lab Session

What should we learn today?

* Problems with predictors
    * Checking collinearity: 1) Eigenvalues; 2) Variance Inflation Factor (VIF); 3) Condition number ($\mathcal{K}$) and index ($n_j$)
    * Variable rescaling

* Problems with model errors
    * Zero mean assumption (Solutions Class #12)
    * Constant variance (i.e., homoscedasticity) assumption
        $\rightarrow$Solution: 1) Heteroscedastic consistent variance estimator; 2) Weighted linear regression; 3) Variable transformation (Class #12)
    * Normality assumption
    * Lack of fit
