---
id: "jpsm/ML_social_science_SURV613/lectures/05-01-Introduction"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Regularized regression II"
original: "ML_social_science_SURV613/lectures/05-01-Introduction.pdf"
pages: 7
sha256: "1920aaa8b941b67eb049eb22df0155c0e72eda6d0c096988b0e8d08ddb7c67c1"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:10"
---

<!-- page 1 -->

# Regularized regression II

## Introduction

<!-- page 2 -->

# Introduction

Feature selection methods
- Wrapper
  - Search algorithms that add and/or remove predictors to optimize performance
  - e.g. forward, backward, and best subset selection
- Filter
  - Test individual predictors outside of the predictive model
  - e.g. $t$-tests, $r$, $\chi^2$
- **$\ell_1$ regularization**

<!-- page 3 -->

# Ridge & Lasso

Ridge regression

$$\hat{\beta}_{ridge} = \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^n (y_i - \beta_0 - \sum_{j=1}^p \beta_j x_{ij})^2 + \lambda \sum_{j=1}^p \beta_j^2 \right\}$$

* Penalty on $\ell_2$ norm of $\beta$
* $\|\beta\|_2 = \sqrt{\sum_{j=1}^p \beta_j^2}$

Lasso (Least Absolute Shrinkage and Selection Operator)

$$\hat{\beta}_{lasso} = \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^n (y_i - \beta_0 \sum_{j=1}^p \beta_j x_{ij})^2 + \lambda \sum_{j=1}^p |\beta_j| \right\}$$

* Penalty on $\ell_1$ norm of $\beta$
* $\|\beta\|_1 = \sum_{j=1}^p |\beta_j|$

<!-- page 4 -->

# Ridge & Lasso

Ridge regression

$$
\hat{\beta}_{ridge} = \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^n (y_i - \beta_0 - \sum_{j=1}^p \beta_j x_{ij})^2 + \lambda \sum_{j=1}^p \beta_j^2 \right\}
$$

* Penalty on $\ell_2$ norm of $\beta$
* $\|\beta\|_2 = \sqrt{\sum_{j=1}^p \beta_j^2}$

Lasso (Least Absolute Shrinkage and Selection Operator)

$$
\hat{\beta}_{lasso} = \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^n (y_i - \beta_0 \sum_{j=1}^p \beta_j x_{ij})^2 + \lambda \sum_{j=1}^p |\beta_j| \right\}
$$

* Penalty on $\ell_1$ norm of $\beta$
* $\|\beta\|_1 = \sum_{j=1}^p |\beta_j|$

Machine Learning for Social Science

Regularized regression II

<!-- page 5 -->

# Ridge & Lasso

Increasing the penalty on model complexity
* $\lambda = 0$
  * Models are equivalent to OLS
* $\lambda \to \infty$
  * Ridge regression ($RSS + \lambda \|\beta\|_2^2$)
    * Coefficients are shrunken towards zero
    * Shrinks coefficients of correlated predictors towards each other
  * Lasso ($RSS + \lambda \|\beta\|_1$)
    * Coefficients are eventually shrunken exactly to zero (i.e. performs **variable selection**)
    * Erratic paths for correlated predictors

$\to$ The penalty $\lambda$ is a tuning parameter

---

Machine Learning for Social Science

Regularized regression II

<!-- page 6 -->

# Ridge & Lasso

Figure: Coefficient paths

(a) Lasso
(b) Ridge

$$\|\hat{\beta}\|_1 / \|\tilde{\beta}\|_1$$

$$\|\hat{\beta}\|_2 / \|\tilde{\beta}\|_2$$

Efron & Hastie (2016)

Machine Learning for Social Science
Regularized regression II

*[Figure: This two-panel line plot compares the coefficient paths for five variables (funding, not-hs, college4, college, and hs) under (a) Lasso and (b) Ridge regression, plotting "Coefficients" (ranging from -5 to 10) on the y-axis against the relative $L_1$ or $L_2$ norm of the estimated coefficients (from 0.0 to 1.0) on the x-axis. The main pattern shows that as the norm ratio decreases toward zero from right to left, Ridge coefficients shrink smoothly and simultaneously toward zero, whereas Lasso coefficients follow piecewise-linear paths and hit zero sequentially at different threshold values.]*

<!-- page 7 -->

# Motivation for Extensions

Limitations of Lasso and Ridge Regression:

- Lasso can be too aggressive in setting coefficients to 0.
- With highly correlated predictors, Lasso tends to choose one and ignore others.
- On the other hand, Ridge Regression doesn't actually set predictors to 0, so limited use in variable selection.
