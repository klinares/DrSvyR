---
id: "jpsm/ML_social_science_SURV613/lectures/04-01-IntroRegularizedRegression"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Regularized regression I"
original: "ML_social_science_SURV613/lectures/04-01-IntroRegularizedRegression.pdf"
pages: 5
sha256: "10c8441c9a27778f349783d4f2b06f95f9ab004c506f7017a68038024368201e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:10"
---

<!-- page 1 -->

# Regularized regression I

<!-- page 2 -->

Introduction

# Motivation

Selecting features for prediction
* Prediction problems might involve data with many potential features (and less domain knowledge)
  * Contrasts theory-based hypothesis testing perspective
  * Relates to building parsimonious models (e.g. with respect to AIC, BIC)
* Interest in developing sparse models to improve:
  * Prediction accuracy
  * Model interpretability

$\rightarrow$ Remove non-informative variables to improve effectiveness

---

Machine Learning for Social Science

Regularized regression I

<!-- page 3 -->

Introduction

# Motivation

Is feature selection necessary?

* Regression models
  * Run into problems in high dimensions (large $p$, small $n$)
    * $p \approx n$: Overfitting and poor prediction performance
    * $p > n$: OLS can not be estimated
* Tree-based models
  * Involve built-in feature selection
  * Less affected by irrelevant features
* Support vector machines, neural networks
  * Negatively affected by irrelevant features

Machine Learning for Social Science
Regularized regression I

<!-- page 4 -->

Introduction

# Selecting Predictors

Figure: Consequences of non-informative predictors

Kuhn & Johnson (2013)

Machine Learning for Social Science

Regularized regression I

*[Figure: The figure is a three-panel line plot showing the consequences of adding non-informative predictors, with the "Number of Additional Non-Informative Predictors" (from 0 to 500) on the x-axis and "RMSE (Test Set)" (from 0.7 to 1.1) on the y-axis. It compares eight machine learning algorithms grouped into "Linear Models," "Non-Linear Models," and "Trees," demonstrating that while RMSE increases sharply with added noise for models like Neural Networks and Linear Regression, it remains relatively flat and stable for tree-based models, MARS, and lasso.]*

<!-- page 5 -->

Introduction

# Feature Selection Methods

Feature selection methods
- Wrapper
  - Search algorithms that add and/or remove predictors to optimize performance
  - e.g. forward, backward, and best subset selection
- Filter
  - Test individual predictors outside of the predictive model
  - e.g. $t$-tests, $r$, $\chi^2$
- **$\ell_1$ regularization**

Machine Learning for Social Science
Regularized regression I
