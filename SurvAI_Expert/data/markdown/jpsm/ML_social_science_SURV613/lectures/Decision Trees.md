---
id: "jpsm/ML_social_science_SURV613/lectures/Decision_Trees"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Decision Trees"
original: "ML_social_science_SURV613/lectures/Decision Trees.pdf"
pages: 12
sha256: "b3f8c5797e02919864f0796a9ddd1a9610abb344abad181d0085200a6abc1f9e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:07"
---

<!-- page 1 -->

# Decision Trees

<!-- page 2 -->

# Benefits of Decision Trees

* Easy to interpret
* Easy to understand
* Extensions can add more to interpretability

But: Downside is that they are not very powerful for making good predictions.

<!-- page 3 -->

# Decision Trees

Note on terminology:

* Regression trees refer to trees used for regression (i.e., numerical outcome).
* Classification trees refer to trees used for classification (i.e., categorical outcome).

<!-- page 4 -->

# Interpreting Trees

Follow the steps from the top to make a prediction for a given observation.

Terminal node shows estimate.

## (a) Regression tree

* `lstat>=9.725`
  * `lstat>=16.21`
    * `dis< 2.004`
      * `11.72`
      * `16.54`
    * `20.17`
  * `lstat>=4.65`
    * `age< 88.95`
      * `lon>=-71.04`
        * `22.84`
        * `27.85`
      * `38.63`
    * `dis>=3.055`
      * `36.55`
      * `47.96`

<!-- page 5 -->

$y$

6

4

2

0.0 2.5 5.0 7.5 10.0

$x$

<!-- page 6 -->

y

6

4

2

0.0

2.5

5.0

7.5

10.0

x

<!-- page 7 -->

6

y

4

2

0.0

2.5

5.0

x

7.5

10.0

<!-- page 8 -->

# Dealing with Correlated Predictors

We’ll see how we can use the idea of decision trees and deal with correlated predictors when we get to ensemble models

General idea: We only use a few of the predictors at a time.

<!-- page 9 -->

# Surrogate Splits

Used to address issues that can arise with missing data.

Idea: Determine split, then find another variable that mimics that split. Use the other variable if there is a missing value in the original variable.

<!-- page 10 -->

# Looking Ahead

Individual trees tend to **overfit.** How can we address this to get better models?

**Ensemble methods** such as Random Forests tries to address some of the issues with individual trees.

* Use only a subset of predictors at a time.
* Use a bootstrap sample of observations.

<!-- page 11 -->

# Variations on Trees

Conditional Inference trees and Model based recursive partitioning aim to put more of a structure on building trees. These provide more **interpretability**.

Generally, if prediction is our primary purpose, we’ll use **regular trees as base learners.**

<!-- page 12 -->

# Imbalanced Datasets

* Note: We **don’t need to set the majority class** of a terminal node as our prediction. We can get scores out of the proportion in the terminal node.
* Using **different metrics (and tuning)** can help identify the best model for prediction.
* There are methods to deal with imbalance data (we will discuss later).
