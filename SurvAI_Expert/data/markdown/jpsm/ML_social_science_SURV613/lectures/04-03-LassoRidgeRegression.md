---
id: "jpsm/ML_social_science_SURV613/lectures/04-03-LassoRidgeRegression"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Regularized regression I"
original: "ML_social_science_SURV613/lectures/04-03-LassoRidgeRegression.pdf"
pages: 13
sha256: "b70d45a2a6796b5d43c194c89c2dbfc5a9510998bca2b9ed070e0e3b850e8294"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:10"
---

<!-- page 1 -->

# Regularized regression I
## Lasso and Ridge Regression

<!-- page 2 -->

# Regularization

Penalized regression models

* (Even) regression models can be over-parameterized (large $p$, small $n$)
* Shrinkage / Regularization methods
  * Consider model complexity in the estimation process by...
  * ...shrinking regression coefficients towards zero

$\rightarrow$ Ridge regression & Lasso

---
Machine Learning for Social Science | Regularized regression I | 2 / 12

<!-- page 3 -->

# Ridge regression

OLS regression

$$
\hat{\beta}_{OLS} = \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^n (y_i - \beta_0 - \sum_{j=1}^p \beta_j x_{ij})^2 \right\}
$$

$\rightarrow$ Minimizes (“only”) RSS

Ridge regression

$$
\begin{aligned}
\hat{\beta}_{ridge} &= \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^n (y_i - \beta_0 - \sum_{j=1}^p \beta_j x_{ij})^2 + \lambda \sum_{j=1}^p \beta_j^2 \right\} \\
&= RSS + \lambda \sum_{j=1}^p \beta_j^2
\end{aligned}
$$

$\rightarrow$ Introduces a **shrinkage penalty**: Fit - complexity trade-off

<!-- page 4 -->

# Ridge regression

OLS regression

$$\hat{\beta}_{OLS} = \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^{n} (y_i - \beta_0 - \sum_{j=1}^{p} \beta_j x_{ij})^2 \right\}$$

$\rightarrow$ Minimizes (“only”) RSS

Ridge regression

$$\begin{aligned}
\hat{\beta}_{ridge} &= \underset{\beta}{\text{argmin}} \left\{ \sum_{i=1}^{n} (y_i - \beta_0 - \sum_{j=1}^{p} \beta_j x_{ij})^2 + \lambda \sum_{j=1}^{p} \beta_j^2 \right\} \\
&= RSS + \lambda \sum_{j=1}^{p} \beta_j^2
\end{aligned}$$

$\rightarrow$ Introduces a **shrinkage penalty**: Fit - complexity trade-off

<!-- page 5 -->

# Ridge regression

Comparing OLS and Ridge regression

$RSS = (\mathbf{y} - \mathbf{X}\beta)'(\mathbf{y} - \mathbf{X}\beta)$

$RSS(\lambda) = (\mathbf{y} - \mathbf{X}\beta)'(\mathbf{y} - \mathbf{X}\beta) + \lambda\beta'\beta$

$$
\hat{\beta}_{OLS} = (\mathbf{X}'\mathbf{X})^{-1}\mathbf{X}'\mathbf{y}
$$

$$
\hat{\beta}_{ridge} = (\mathbf{X}'\mathbf{X} + \lambda\mathbf{I})^{-1}\mathbf{X}'\mathbf{y}
$$

As a result...

* OLS regression needs $\mathbf{X}$ to be of full column rank
* Ridge regression (still) allows matrix inversion due to $\lambda\mathbf{I}$

<!-- page 6 -->

# Lasso

Other penalties are possible

Ridge regression

* Penalty on $\ell_2$ norm of $\beta$
* $\|\beta\|_2 = \sqrt{\sum_{j=1}^{p} \beta_j^2}$

Lasso (Least Absolute Shrinkage and Selection Operator)

$$
\hat{\beta}_{lasso} = \operatorname*{argmin}_{\beta} \left\{ \sum_{i=1}^{n} (y_i - \beta_0 - \sum_{j=1}^{p} \beta_j x_{ij})^2 + \lambda \sum_{j=1}^{p} |\beta_j| \right\}
$$

* Penalty on $\ell_1$ norm of $\beta$
* $\|\beta\|_1 = \sum_{j=1}^{p} |\beta_j|$

Machine Learning for Social Science | Regularized regression I | 5 / 12

<!-- page 7 -->

# Lasso

Other penalties are possible

Ridge regression

* Penalty on $\ell_2$ norm of $\boldsymbol{\beta}$
* $\|\boldsymbol{\beta}\|_2 = \sqrt{\sum_{j=1}^p \beta_j^2}$

Lasso (Least Absolute Shrinkage and Selection Operator)

$$
\hat{\boldsymbol{\beta}}_{lasso} = \operatorname*{argmin}_{\boldsymbol{\beta}} \left\{ \sum_{i=1}^n \left(y_i - \beta_0 - \sum_{j=1}^p \beta_j x_{ij}\right)^2 + \lambda \sum_{j=1}^p |\beta_j| \right\}
$$

* Penalty on $\ell_1$ norm of $\boldsymbol{\beta}$
* $\|\boldsymbol{\beta}\|_1 = \sum_{j=1}^p |\beta_j|$

<!-- page 8 -->

Lasso

# Penalty term

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

Machine Learning for Social Science
Regularized regression I

<!-- page 9 -->

Lasso

# Penalty term

Figure: Constraint regions and RSS contours

(a) $|\beta_1| + |\beta_2| \le t$

(b) $\beta_1^2 + \beta_2^2 \le t^2$

$\beta_2$

$\hat{\beta}$

$\beta_1$

$\beta_2$

$\hat{\beta}$

$\beta_1$

Efron & Hastie (2016)

Machine Learning for Social Science

Regularized regression I

*[Figure: The figure consists of two side-by-side coordinate plots with horizontal axis $\beta_1$ and vertical axis $\beta_2$ that compare the constraint regions and residual sum of squares (RSS) contours for Lasso ($L_1$) versus Ridge ($L_2$) regularization. Both plots show red elliptical RSS contours centered at the unconstrained estimate $\hat{\beta}$, demonstrating that the contours touch the cyan diamond-shaped $L_1$ constraint region at a corner on the $\beta_2$ axis (where $\beta_1 = 0$), whereas they touch the cyan circular $L_2$ constraint region at a point away from the axes where neither parameter is zero.]*

<!-- page 10 -->

Lasso

# Penalty term

Figure: Coefficient paths

(a) Lasso

$$\|\hat{\beta}\|_1 / \|\tilde{\beta}\|_1$$

(b) Ridge

$$\|\hat{\beta}\|_2 / \|\tilde{\beta}\|_2$$

Hastie et al. (2015)

Machine Learning for Social Science

Regularized regression I

*[Figure: The figure consists of two side-by-side line plots comparing coefficient paths for (a) Lasso and (b) Ridge regression across five predictor variables (`funding`, `not-hs`, `college4`, `college`, and `hs`), with "Coefficients" on the vertical axes and the relative coefficient norms ($\|\hat{\beta}\|_1/\|\tilde{\beta}\|_1$ and $\|\hat{\beta}\|_2/\|\tilde{\beta}\|_2$, ranging from 0.0 to 1.0) on the horizontal axes. As the horizontal norm ratio decreases toward zero, the Ridge coefficients shrink smoothly and simultaneously toward zero, whereas the Lasso coefficients follow piecewise-linear paths that reach exactly zero sequentially at different threshold values.]*

<!-- page 11 -->

Lasso

# Penalty term

Other types of penalties?

$$\tilde{\boldsymbol{\beta}} = \underset{\boldsymbol{\beta}}{\text{argmin}} \left\{ \sum_{i=1}^n (y_i - \beta_0 - \sum_{j=1}^p \beta_j x_{ij})^2 + \lambda \sum_{j=1}^p |\beta_j|^q \right\}$$

Figure: Constraint regions for different values of $q$

$q = 4$

$q = 2$

$q = 1$

$q = 0.5$

$q = 0.1$

Hastie et al. (2009)

Machine Learning for Social Science

Regularized regression I

*[Figure: The figure displays five plots on unlabeled two-dimensional Cartesian axes, comparing the geometric constraint regions for different values of the penalty exponent $q$ ($q = 4, 2, 1, 0.5,$ and $0.1$). As $q$ decreases from $4$ to $0.1$, the cyan boundary transitions from a rounded square ($q=4$), to a circle ($q=2$), a diamond ($q=1$), a concave four-pointed star ($q=0.5$), and finally collapses onto the axes to form a cross ($q=0.1$).]*

<!-- page 12 -->

# Software Resources

Resources for R

* Standard package for ridge regression, lasso: `glmnet`
* Feature selection by filter: e.g. via `sbf` in `caret`
* Recursive feature elimination: e.g. `rfe` via in `caret`

<!-- page 13 -->

References

# References

Efron, B. and Hastie, T. (2016). Sparse Modeling and the Lasso. In Efron, B. and Hastie, T. (Eds.), *Computer Age Statistical Inference: Algorithms, Evidence and Data Science* (pp. 298–324). New York, NY: Cambridge University Press

Hastie, T., Tibshirani, R., Friedman, J. (2009). *The Elements of Statistical Learning: Data Mining, Inference, and Prediction.* New York, NY: Springer.

Hastie, T., Tibshirani, R., Wainwright, M. (2015). *Statistical Learning with Sparsity: The Lasso and Generalizations.* Boca Raton, FL: Chapman & Hall/CRC.

James, G., Witten, D., Hastie, T., Tibshirani, R. (2013). *An Introduction to Statistical Learning.* New York, NY: Springer.

Kuhn, M., Johnson, K. (2013). *Applied Predictive Modeling.* New York, NY: Springer.

Machine Learning for Social Science

Regularized regression I
