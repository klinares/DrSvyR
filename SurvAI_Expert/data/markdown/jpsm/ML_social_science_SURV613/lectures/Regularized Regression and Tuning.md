---
id: "jpsm/ML_social_science_SURV613/lectures/Regularized_Regression_and_Tuning"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Regularized Regression and Tuning"
original: "ML_social_science_SURV613/lectures/Regularized Regression and Tuning.pdf"
pages: 9
sha256: "529eb08d6562351cb68389ed62f399780ab02181b8802fe304a1e0a58aca9a03"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:12"
---

<!-- page 1 -->

# Regularized Regression and Tuning

<!-- page 2 -->

# General Rule in ML

If there is a parameter or a decision to be made, we use cross-validation (or another validation technique) to optimize for predictive performance

* For regularized regression, this means choice of alpha, lambda.
* CV is done for tuning everything at once.

Survey design in CV: Can use different CV methods (such as stratified) and models.

* Most important thing is to get unbiased estimates of performance.

<!-- page 3 -->

# Steps under ML Framework

1. Split data into training and test.
2. With training, use cross-validation to tune
    a. Split into train-validation using CV folds.
    b. Fit elastic net models with various values of lambda and alpha.
    c. Find best model using validation.
3. Evaluate best model on test set.

<!-- page 4 -->

# Computation Time

Regularized regression is generally relatively fast.

We'll really start to see it slow down with ensemble methods.

<!-- page 5 -->

# Lasso and Ridge Regression

Two ways of thinking about it:

* Shrinkage penalty - instead of finding the beta coefficients that minimize the residual sum of squares, find the beta coefficients that **minimize RSS + penalty on coefficients** (to shrink coefficients)
* Constraint regions - **minimize RSS with the constraint** that coefficients can’t be too big.

<!-- page 6 -->

## Figure: Constraint regions and RSS contours

(a) $|\beta_1| + |\beta_2| \le t$

(b) $\beta_1^2 + \beta_2^2 \le t^2$

$\beta_1$ $\beta_2$ $\hat{\beta}$

Efron & Hastie (2016)

*[Figure: The figure shows two side-by-side diagrams on axes $\beta_1$ (horizontal) and $\beta_2$ (vertical) comparing the constraint regions and residual sum of squares (RSS) contours around the least squares estimate $\hat{\beta}$ for (a) $L_1$ regularization ($|\beta_1| + |\beta_2| \le t$) and (b) $L_2$ regularization ($\beta_1^2 + \beta_2^2 \le t^2$). The main pattern illustrates that the elliptical red RSS contours intersect the diamond-shaped cyan $L_1$ constraint region at a corner directly on the $\beta_2$ axis (setting $\beta_1 = 0$), whereas they intersect the circular cyan $L_2$ constraint region at a point off the axis where both parameters remain non-zero.]*

<!-- page 7 -->

# Features and Feature Selection

We typically do not check for significance of predictors in regularized regression under ML framework.

* Goal is prediction, so significance is not important – only performance on test set.

Usually want to include all variables and tune for best predictive ability.

* May need to use domain knowledge for generating features

<!-- page 8 -->

# Elastic Net

**Note:** Elastic net with alpha = 0 is Ridge Regression. Elastic Net with alpha = 1 is Lasso.

So, only need to **fit Elastic Net and tune alpha** instead of needing to do Lasso and Ridge separately.

<!-- page 9 -->

# Idea behind Group Lasso

Some variables should be considered together for variable selection purposes.

* Dummies of the same categorical variable.
* Related variables like latitude/longitude

Make sure that sending all of the related variables are sent to zero at the same time if they are set to zero.
