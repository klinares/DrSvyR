---
id: "jpsm/ML_social_science_SURV613/lectures/09-02-ModelBasedBoosting"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Boosting II"
original: "ML_social_science_SURV613/lectures/09-02-ModelBasedBoosting.pdf"
pages: 13
sha256: "b1c55632d3d0782cd6445b3a8a5dcf3f0b2ddf78e1ad2c71baa225c1e34ae943"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:11"
---

<!-- page 1 -->

# Boosting II
## Model-Based Boosting

<!-- page 2 -->

# Model-based Boosting

Boosting with regression models?

* Properties of OLS regression
  * The residuals $e$ and $X$ are uncorrelated
  * OLS finds the minimum SSE given a linear functional form
* There is nothing left to boost!

Component-wise/ model-based boosting

* Boosting with GLMs (linear, splines) as base learners
* Takes **small models** (components) at each iteration
* Returns an interpretable prediction function
* Performs variable selection and regularization

<!-- page 3 -->

# Model-based Boosting

Boosting with regression models?

* Properties of OLS regression
  * The residuals $e$ and $X$ are uncorrelated
  * OLS finds the minimum SSE given a linear functional form
* There is nothing left to boost!

Component-wise/ model-based boosting

* Boosting with GLMs (linear, splines) as base learners
* Takes **small models** (components) at each iteration
* Returns an interpretable prediction function
* Performs variable selection and regularization

<!-- page 4 -->

# Model-based Boosting

**Boosting linear models$^1$**

1. Initialization
   * Specify a set of base learners $h_1(x_{i1}) = \beta_1 x_{i1}, \dots, h_p(x_{i1}) = \beta_p x_{ip}$
   * Initialize model $\hat{f}^0 = \bar{y}$
2. For $m = 1 \textit{ to } m_{stop}$
   1. Compute residuals $u_i^m$ based on the current model
   2. Fit each base-learner *separately* to the current residuals
      $$\mathbb{E}(u_i^m) = \hat{h}_1^m(x_{i1}), \dots, \mathbb{E}(u_i^m) = \hat{h}_p^m(x_{ip})$$
   3. Select the best base learner $h_{j^*}$: $j^* = \text{argmin} \sum(u_i^m - \hat{h}_j^m(x_{ij}))^2$
   4. Update the current model (w. shrinkage $\nu$): $\hat{f}^m(\mathbf{x}_i) = \hat{f}^{m-1}(\mathbf{x}_i) + \nu \hat{h}_{j^*}^m(x_{ij})$

---
$^1$`https://github.com/SocialScienceDataLab/statistical-boosting-with-mboost`

Machine Learning for Social Science | Boosting II | 3 / 12

<!-- page 5 -->

# Model-based Boosting

The final boosting estimate

$$\hat{f} = \hat{f}_1 + \dots + \hat{f}_P$$

- Can be expressed as an additive function of the base learners
- Includes sums of individual estimates for each base learner
  - $\hat{f}_j$ equals sum of $\nu\hat{\mathbf{u}}^m$ over all iterations where base learner $j$ was selected
  - Coefficients can be summed equivalently
- $m_{stop}$ controls **variable selection** and **regularization**
  - Variables might not be selected up to $m_{stop}$
  - Shrinkage parameter $\nu$ causes coefficients to increase slowly

<!-- page 6 -->

Model-based Boosting

# Variable selection and regularization

Figure: Coefficient paths in model-based boosting$^2$

---

$^2$Hofner et al. (2014)

Machine Learning for Social Science | Boosting II | 5 / 12

*[Figure: The line plot shows coefficient paths in model-based boosting, plotting "Coefficients" on the vertical axis (from below 0 to over 3) against the "Number of boosting iterations" on the horizontal axis (from 0 to 100). It compares eight variables (`anthro3b`, `anthro3a`, `kneebreadth`, `anthro3c`, `hipcirc`, `waistcirc`, `age`, and `elbowbreadth`), showing that variables enter the model at different iterations and generally increase in magnitude before leveling off, with `anthro3b` and `anthro3a` reaching the highest positive values while `elbowbreadth` becomes slightly negative after iteration 55.]*

<!-- page 7 -->

Model-based Boosting

# Base learners

Base learners in `mboost`

* `bols`
  * Linear base learner
* `bbs`
  * Smooth base learner: P-splines
* `bspatial`
  * Smooth base learner: bivariate P-splines
* `brandom`, `btree`, ...

Machine Learning for Social Science
Boosting II

<!-- page 8 -->

Model-based Boosting

# Boosting splines

Figure: Boosting with a P-spline base-learner at different iterations$^3$

**model fit at m = 1**

**model fit at m = 30**

**model fit at m = 110**

**model fit at m = 50000**

---
$^3$Mayr et al. (2014)

Machine Learning for Social Science
Boosting II

*[Figure: A 2x2 grid of scatter plots displays boosting with a P-spline base-learner, comparing the fitted model (solid red line) against a true underlying curve (dashed black line) and observed data points (open circles) across an unlabeled horizontal axis (-0.2 to 0.2) and a vertical axis $y$ (-0.10 to 0.10). Comparing four iteration steps ($m = 1$, $m = 30$, $m = 110$, and $m = 50000$), the plots show the red fitted curve progressing from an underfitted, nearly flat line at $m = 1$, to closely matching the true dashed curve at $m = 30$ and $m = 110$, and finally becoming jagged and overfitted to the noise at $m = 50000$.]*

<!-- page 9 -->

Grid search and random search

# Grid search and random search

1. Model-based Boosting
2. **Grid search and random search**
3. Software Resources
4. References

Machine Learning for Social Science
Boosting II

<!-- page 10 -->

Grid search and random search

# Grid search and random search

Tuning many hyperparameters

- (Exhaustive) Grid search
  - Expands a grid over all combinations of considered try-out values
  - Can become inefficient with many tuning parameters

- Random search (Bergstra & Benglio 2012)
  - Considers only a random selection of tuning parameter combinations
  - Benefit depends on method and implementation

- Adaptive search (Kuhn 2014)
  - Guided search by considering performance within the search process
  - Adaptive removal of unpromising parameter settings

Machine Learning for Social Science | Boosting II | 9 / 12

<!-- page 11 -->

Grid search and random search

# Grid search and random search

Figure: Grid and random search with two tuning parameters$^4$

(a) Grid layout

Unimportant parameter

Important parameter

(b) Random layout

Unimportant parameter

Important parameter

---

$^4$Bergstra and Benglio (2012)

Machine Learning for Social Science

Boosting II

*[Figure: The figure consists of two side-by-side diagrams comparing a "(a) Grid layout" and a "(b) Random layout" for nine sampled points across two axes labeled "Important parameter" (horizontal) and "Unimportant parameter" (vertical), with marginal curves along the top and left borders. The main pattern shows that while the 3x3 grid layout only tests three distinct values along the important parameter axis (missing the peak of the green top curve), the random layout tests nine distinct values along that same axis, successfully capturing the peak.]*

<!-- page 12 -->

# Software Resources

Resources for R

* Extreme Gradient Boosting: `xgboost`
  * Competitive and scalable boosting approach (Chen & Guestrin 2016)
  * XGBoost Explainer:
    `https://www.rdocumentation.org/packages/xgboostExplainer/versions/0.1`
* Model-based Boosting: `mboost`
  * Implements various linear and non-linear base learners (Hofner et al. 2014)

<!-- page 13 -->

# References

Bergstra, J., Bengio, Y. (2012). Random search for hyper-parameter optimization. *Journal of Machine Learning Research 13*, 281–305.

Chen, T., Guestrin, C. (2016). *XGBoost: A scalable tree boosting system.* `https://arxiv.org/abs/1603.02754`.

Hastie, T., Tibshirani, R., Friedman, J. (2009). *The Elements of Statistical Learning: Data Mining, Inference, and Prediction.* New York, NY: Springer.

Hofner, B., Mayr, A., Robinzonov, N, Schmid, M. (2014). Model-based boosting in R: a hands-on tutorial using the R package mboost. *Computational Statistics 29(1-2)*, 3–35.

Kuhn, M. (2014). *Futility Analysis in the Cross-Validation of Machine Learning Models.* `https://arxiv.org/abs/1405.6974`.

Mayr, A., Binder, H., Gefeller, O., Schmid, M. (2014). *The evolution of boosting algorithms – from machine learning to statistical modeling.* `https://arxiv.org/abs/1403.1452`.
