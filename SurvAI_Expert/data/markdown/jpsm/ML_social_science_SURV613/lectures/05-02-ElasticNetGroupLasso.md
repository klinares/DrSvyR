---
id: "jpsm/ML_social_science_SURV613/lectures/05-02-ElasticNetGroupLasso"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Regularized regression II"
original: "ML_social_science_SURV613/lectures/05-02-ElasticNetGroupLasso.pdf"
pages: 7
sha256: "d67f465519c9f8863ff5136669dfe30932e8cfdaddde5df98a660e370aa69a13"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:06"
---

<!-- page 1 -->

# Regularized regression II

## Elastic Net and Group Lasso

<!-- page 2 -->

# Elastic net

A compromise between ridge and lasso

$$
\underset{\beta_0, \beta}{\text{minimize}} \left\{ \sum_{i=1}^n (y_i - \beta_0 - x_i' \beta)^2 + \lambda \Big[ (1 - \alpha) \|\beta\|_2^2 + \alpha \|\beta\|_1 \Big] \right\}
$$

Elastic net

* Introduces a mixing parameter $\alpha \in [0, 1]$
  * $\alpha = 0$: Ridge regression
  * $\alpha = 1$: Lasso
* $\alpha$ is an additional tuning parameter

<!-- page 3 -->

# Elastic net

Figure: Coefficient paths with elastic net

$\alpha = 1.0$
Coefficients $\hat{\beta}_j$
$\|\hat{\beta}\|_1$

$\alpha = 0.3$
Coefficients $\hat{\beta}_j$
$\|\hat{\beta}\|_1$

Hastie et al. (2015)

<!-- page 4 -->

Elastic net

# Extensions

Categorical outcomes

$$
\underset{\beta_0, \beta}{\text{minimize}} \left\{ -\frac{1}{n}\mathcal{L}(\beta_0, \beta; \mathbf{y}, \mathbf{X}) + \lambda\|\beta\|_1 \right\}
$$

- Shrinkage can be applied with binary and multinomial outcomes...
- ...by introducing a penalty in the likelihood function

A note on standardization

- Contribution to penalty term dependent on scale
- Ridge and Lasso typically applied with standardized features

Machine Learning for Social Science

Regularized regression II

<!-- page 5 -->

# Extensions

Penalty factors

$$
\lambda \sum_{j=1}^p v_j P_\alpha(\beta_j) = \lambda \sum_{j=1}^p v_j \left[(1 - \alpha) \frac{1}{2} \beta_j^2 + \alpha |\beta_j|\right]
$$

- Allows to control the regularization process given prior/ substantive knowledge
- Specify separate penalty factors for individual coefficients
- Set $v_j$ equal to zero to not penalize at all

<!-- page 6 -->

Elastic net

# Group Lasso

Regularization with feature groups
- Standard lasso considers predictors independently
- Not desirable when features have a natural group structure
  - Groups of dummy variables
  - Main effects and interactions

$\rightarrow$ Group lasso in- or excludes groups of variables together

Machine Learning for Social Science

Regularized regression II

<!-- page 7 -->

# Group Lasso

Regression with covariate groups
* $z_{ij}$ represents covariates in group $j$
* $\theta_j$ a group of regression coefficients

$$\theta_0 + \sum_{j=1}^J z'_{ij} \theta_j$$

Group lasso

$$\operatorname{argmin}_{\theta_0, \theta_j} \left\{ \sum_{i=1}^n (y_i - \theta_0 - \sum_{j=1}^J z'_{ij} \theta_j)^2 + \lambda \sum_{j=1}^J \|\theta_j\|_2 \right\}$$

Properties
* All elements of $\hat{\theta}_j$ will be either zero or non-zero
* With groups of single covariates, group lasso equals lasso
