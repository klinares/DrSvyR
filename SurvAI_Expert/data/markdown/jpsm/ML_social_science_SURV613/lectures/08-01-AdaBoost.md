---
id: "jpsm/ML_social_science_SURV613/lectures/08-01-AdaBoost"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Boosting I"
original: "ML_social_science_SURV613/lectures/08-01-AdaBoost.pdf"
pages: 6
sha256: "b531034fe95837052e61b8bddd09207d441a126565b6501415deb8fb7fdd5ad4"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:06"
---

<!-- page 1 -->

# Boosting I

## Introduction to Boosting; AdaBoost

<!-- page 2 -->

# Introduction

**Boosting**

- Class of ensemble methods which combine **sequential** prediction models
- Adaptive approach with focus on "difficult observations"
- Different flavors exist
  - AdaBoost
  - Gradient Boosting Machines (GBM)
  - ...
- Can be applied to different (weak) base learners
  - Boosting trees
  - ...

<!-- page 3 -->

AdaBoost

# AdaBoost

Figure: Process of AdaBoost algorithm$^1$

$$G(x) = \text{sign} \left[ \sum_{m=1}^M \alpha_m G_m(x) \right]$$

Weighted Sample $\quad G_M(x)$

Weighted Sample $\quad G_3(x)$

Weighted Sample $\quad G_2(x)$

Training Sample $\quad G_1(x)$

---
$^1$Source: Hastie et al. 2009

Machine Learning for Social Science $\quad$ Boosting I $\quad$ 3 / 6

<!-- page 4 -->

# AdaBoost

**AdaBoost**

- Algorithm for classification problems ($Y \in \{-1, 1\}$)
- Estimate a sequence of classifiers using reweighted data
- AdaBoost process
  1. Fit classifier $G_m(x)$ to weighted data (intitial weights $w_i = \frac{1}{n}$)
  2. Compute the misclassification rate

$$\text{err}_m = \frac{\sum_{i=1}^n w_i I(y_i \neq G_m(x_i))}{\sum_{i=1}^n w_i}$$

  3. Compute the classifier weight $\alpha_m = \log((1 - \text{err}_m)/\text{err}_m)$
  4. Recalculate weights $w_i = w_i \exp(\alpha_m I(y_i \neq G_m(x_i)))$
- Majority vote classification: $G(x) = \text{sign}\big[\sum_{m=1}^M \alpha_m G_m(x)\big]$

<!-- page 5 -->

# Boosting Stumps

Figure: (Ada)Boosting stumps (example)$^2$

(a) Step 1: $\alpha_1 = 0.42$

$D_1$  
$h_1$

(b) Step 2: $\alpha_2 = 0.65$

$D_2$  
$h_2$

(c) Step 3: $\alpha_3 = 0.92$

$D_3$  
$h_3$

---
$^2$Source: Shapire & Freund 2012

<!-- page 6 -->

AdaBoost Boosting Stumps

# Boosting Stumps

Figure: Step 4: Combine models

$$
H = \text{sign} \left( 0.42 \quad + 0.65 \quad + 0.92 \quad \right) =
$$

Machine Learning for Social Science Boosting I 6 / 6
