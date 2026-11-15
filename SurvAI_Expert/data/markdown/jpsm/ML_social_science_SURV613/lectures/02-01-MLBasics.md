---
id: "jpsm/ML_social_science_SURV613/lectures/02-01-MLBasics"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "ML Basics"
original: "ML_social_science_SURV613/lectures/02-01-MLBasics.pdf"
pages: 14
sha256: "2372d07b310dc721673f63ebdc1e050414b27fa617ba4b935e6de05e15bdc13e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:05"
---

<!-- page 1 -->

# ML Basics

Machine Learning for Social Science

<!-- page 2 -->

Introduction

# ML process

Machine Learning task
$\downarrow$
Get and integrate data
$\downarrow$
Explore and pre-process data
$\downarrow$
Features
$\downarrow$
Training and tuning
$\downarrow$
Evaluation
$\downarrow$
Deploy, maintain and update

Machine Learning for Social Science

ML Basics

<!-- page 3 -->

# Introduction

Unsupervised Learning
* Finding patterns in data using a set of input variables $X$

Supervised Learning
* Predicting an output variable $Y$ based on a set of input variables $X$
  1. Learn the relationship between input and output using **training data** (with $X$ and $Y$)

$$Y = f(X) + \varepsilon$$

  2. Predict the output based on the prediction model (of step 1) for **new test data** ($\sim$only $X$ available)
* continuous $Y$: regression, categorical $Y$: classification
* Focus on **prediction**

<!-- page 4 -->

Introduction

# Introduction

Unsupervised Learning
* Finding patterns in data using a set of input variables $X$

Supervised Learning
* Predicting an output variable $Y$ based on a set of input variables $X$
  1. Learn the relationship between input and output using **training data** (with $X$ and $Y$)

$$Y = f(X) + \varepsilon$$

  2. Predict the output based on the prediction model (of step 1) for **new test data** ($\sim$only $X$ available)
* continuous $Y$: regression, categorical $Y$: classification
* Focus on **prediction**

Machine Learning for Social Science | ML Basics | 3 / 8

<!-- page 5 -->

# Introduction

Unsupervised Learning
* Finding patterns in data using a set of input variables $X$

Supervised Learning
* Predicting an output variable $Y$ based on a set of input variables $X$
  1. Learn the relationship between input and output using **training data** (with $X$ and $Y$)
$$
Y = f(X) + \varepsilon
$$
  2. Predict the output based on the prediction model (of step 1) for **new test data** ($\sim$only $X$ available)
* continuous $Y$: regression, categorical $Y$: classification
* Focus on **prediction**

<!-- page 6 -->

# Introduction

Unsupervised Learning
* Finding patterns in data using a set of input variables $X$

Supervised Learning
* Predicting an output variable $Y$ based on a set of input variables $X$
  1. Learn the relationship between input and output using **training data** (with $X$ and $Y$)

     $$Y = f(X) + \varepsilon$$

  2. Predict the output based on the prediction model (of step 1) for **new test data** ($\sim$only $X$ available)
* continuous $Y$: regression, categorical $Y$: classification
* Focus on **prediction**

<!-- page 7 -->

# ML basics

**Supervised Learning**: Find function $f(x)$ that makes optimal predictions in a **new data set**

Prerequisites:

* **Representation**: What is the *hypothesis space*, the family of functions to search over?
    * Describes possible relationships between $X$ and $Y$
    * Examples: $f(x) = x'\beta$ is linear, or $f$ is a tree.
* **Evaluation**: What is the criterion to choose between different functions?
    * Measures predictive performance
    * Examples: Mean Squared Error, Logistic Loss
* **Computation**: How is $f$ actually calculated?
    * Speed and memory space may be limiting factors

<!-- page 8 -->

Machine Learning basics

# ML basics

**Supervised Learning**: Find function $f(x)$ that makes optimal predictions in a **new data set**

Prerequisites:

* **Representation**: What is the *hypothesis space*, the family of functions to search over?
    * Describes possible relationships between $X$ and $Y$
    * Examples: $f(x) = x'\beta$ is linear, or $f$ is a tree.
* **Evaluation**: What is the criterion to choose between different functions?
    * Measures predictive performance
    * Examples: Mean Squared Error, Logistic Loss
* **Computation**: How is $f$ actually calculated?
    * Speed and memory space may be limiting factors

---

Machine Learning for Social Science
ML Basics

<!-- page 9 -->

# ML basics

**Supervised Learning**: Find function $f(x)$ that makes optimal predictions in a **new data set**

Prerequisites:

* **Representation**: What is the *hypothesis space*, the family of functions to search over?
    * Describes possible relationships between $X$ and $Y$
    * Examples: $f(x) = x'\beta$ is linear, or $f$ is a tree.
* **Evaluation**: What is the criterion to choose between different functions?
    * Measures predictive performance
    * Examples: Mean Squared Error, Logistic Loss
* **Computation**: How is $f$ actually calculated?
    * Speed and memory space may be limiting factors

<!-- page 10 -->

# ML basics

**Supervised Learning**: Find function $f(x)$ that makes optimal predictions in a **new data set**

Prerequisites:

* **Representation**: What is the *hypothesis space*, the family of functions to search over?
    * Describes possible relationships between $X$ and $Y$
    * Examples: $f(x) = x'\beta$ is linear, or $f$ is a tree.
* **Evaluation**: What is the criterion to choose between different functions?
    * Measures predictive performance
    * Examples: Mean Squared Error, Logistic Loss
* **Computation**: How is $f$ actually calculated?
    * Speed and memory space may be limiting factors

<!-- page 11 -->

Machine Learning basics

# ML basics

Table: Estimating $f(x)$

| Regression methods | (tree-based) ML methods |
| :---: | :---: |
| parametric | non-parametric |
| linearity, additivity | flexible functional form |
| prior model specification | "built-in" feature selection |
| theory-driven | data-driven |
| $\rightarrow$ Inference | $\rightarrow$ Prediction |

Machine Learning for Social Science | ML Basics | 5 / 8

<!-- page 12 -->

Machine Learning basics

# ML basics

## Figure: Flexibility-Interpretability Trade-Off

Interpretability
- High
- Low

Flexibility
- Low
- High

- Subset Selection
- Lasso
- Least Squares
- Generalized Additive Models
- Trees
- Bagging, Boosting
- Support Vector Machines

James et al. (2013)

Machine Learning for Social Science
ML Basics

<!-- page 13 -->

Machine Learning basics

# ML basics

Estimation requires (at least implicitly):
- a target distribution $\mathbb{P}_{Y|X}$, or
- a loss function

Table: Possible choices

| Setting | Loss | Target $f(x)$ |
| ---: | ---: | ---: |
| Regression | $(y - f(x))^2$ | $\text{mean}(y|x)$ |
| Regression | $|y - f(x)|$ | $\text{median}(y|x)$ |
| Regression | $\rho_\tau(y - f(x))$ | $F_{y|x}^{-1}(\tau)$ |
| Classification | Deviance | $\pi_{y|x}$ |

Prediction perspective:
- Machine Learning mindset is more focused on evaluation criteria – and therefore – on loss functions

Machine Learning for Social Science

ML Basics

<!-- page 14 -->

# References

Buskirk, T. D., Kirchner, A., Eck, A., Signorino, C. S. (2018). An Introduction to Machine Learning Methods for Survey Researchers. *Survey Practice 11*(1).

Domingos, P. (2012). A few useful things to know about machine learning. *Communications of the ACM 55*(10), 78–87.

Hastie, T., Tibshirani, R., Friedman, J. (2009). *The Elements of Statistical Learning: Data Mining, Inference, and Prediction*. New York, NY: Springer.

James, G., Witten, D., Hastie, T., Tibshirani, R. (2013). *An Introduction to Statistical Learning*. New York, NY: Springer.
