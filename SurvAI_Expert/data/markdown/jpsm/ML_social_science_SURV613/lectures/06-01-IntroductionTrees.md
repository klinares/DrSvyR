---
id: "jpsm/ML_social_science_SURV613/lectures/06-01-IntroductionTrees"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Decision Trees I"
original: "ML_social_science_SURV613/lectures/06-01-IntroductionTrees.pdf"
pages: 13
sha256: "c27de9de3792d05cf63fd21c55bf60165db6a1395ed615b5c08eebdf16c5db73"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:06"
---

<!-- page 1 -->

# Decision Trees I

## Introduction to Decision Trees

<!-- page 2 -->

# Introduction

Decision Trees
- Data-driven approach for relating $X$ and $Y$
- Popular and (somewhat) easy to interpret
- Important building block (base learner) for ensemble methods
- Many different tree building algorithms exist (Zhang & Singer 2010, Loh 2014)
  - Focus on interaction detection, prediction, parameter instability...

<!-- page 3 -->

Introduction

# Introduction

## Figure: Decision Tree Algorithms

(a) RPART
(b) CHAID
(c) C4.5
(g) GUIDE univariate
(j) GUIDE linear
(k) CTREE

Loh (2014)

Machine Learning for Social Science
Decision Trees I

<!-- page 4 -->

# Classification and Regression Trees (CART)

Classification and Regression Trees (CART)
* Approach for partitioning the predictor space into smaller subregions via “recursive binary splitting”
* Results in a “top-down” tree structure with...
  * Internal nodes within the tree
  * Terminal nodes as endpoints
* Can be applied to regression and classification problems

<!-- page 5 -->

# Classification and Regression Trees (CART)

Figure: A small tree

$X_1 \le t_1$
$X_2 \le t_2$
$X_1 \le t_3$
$X_2 \le t_4$
$R_1$
$R_2$
$R_3$
$R_4$
$R_5$

James et al. (2013)

---
Machine Learning for Social Science | Decision Trees I | 5 / 11

<!-- page 6 -->

Classification and Regression Trees (CART) Tree growing

# Tree growing

Growing a **regression tree**

Define pairs of regions for all $X_1, X_2, ..., X_p$ predictors and cutpoints $c$

$$\tau_L(j, c) = \{X | X_j < c\} \text{ and } \tau_R(j, c) = \{X | X_j \geq c\}$$

Find split $s$ which maximizes the reduction in $RSS$

$$\Delta RSS(s, \tau) = RSS(\tau) - RSS(\tau_L) - RSS(\tau_R)$$

$$RSS(\tau) = \sum_{i \in \tau} (y_i - \hat{y})^2$$

with $\hat{y}$ being the mean of $y$ in node $\tau$

Machine Learning for Social Science Decision Trees I 6 / 11

<!-- page 7 -->

Classification and Regression Trees (CART) | Tree growing

# Tree growing

Growing a **regression tree**

Define pairs of regions for all $X_1, X_2, ..., X_p$ predictors and cutpoints $c$

$$
\tau_L(j, c) = \{X | X_j < c\} \text{ and } \tau_R(j, c) = \{X | X_j \geq c\}
$$

Find split $s$ which maximizes the reduction in $RSS$

$$
\Delta RSS(s, \tau) = RSS(\tau) - RSS(\tau_L) - RSS(\tau_R)
$$

$$
RSS(\tau) = \sum_{i \in \tau} (y_i - \hat{y})^2
$$

with $\hat{y}$ being the mean of $y$ in node $\tau$

Machine Learning for Social Science | Decision Trees I | 6 / 11

<!-- page 8 -->

Classification and Regression Trees (CART) | Tree growing

# Tree growing

Growing a **classification tree**

Define pairs of regions for all $X_1, X_2, ..., X_p$ predictors and cutpoints $c$

$$\tau_L(j, c) = \{X | X_j < c\} \text{ and } \tau_R(j, c) = \{X | X_j \ge c\}$$

Find split $s$ which maximizes the reduction in node impurity

$$\Delta I(s, \tau) = I(\tau) - p(\tau_L)I(\tau_L) - p(\tau_R)I(\tau_R)$$

Impurity measures

$$I_{Gini}(\tau) = \sum_{k=1}^{K} \hat{p}_k(1 - \hat{p}_k)$$

$$I_{entropy}(\tau) = - \sum_{k=1}^{K} \hat{p}_k \log \hat{p}_k$$

with $\hat{p}_k$ being the proportion of observations from class $k$ in node $\tau$

Machine Learning for Social Science | Decision Trees I | 7 / 11

<!-- page 9 -->

Classification and Regression Trees (CART) | Tree growing

# Tree growing

Growing a **classification tree**

Define pairs of regions for all $X_1, X_2, ..., X_p$ predictors and cutpoints $c$

$$\tau_L(j, c) = \{X | X_j < c\} \text{ and } \tau_R(j, c) = \{X | X_j \ge c\}$$

Find split $s$ which maximizes the reduction in node impurity

$$\Delta I(s, \tau) = I(\tau) - p(\tau_L)I(\tau_L) - p(\tau_R)I(\tau_R)$$

Impurity measures

$$I_{\text{Gini}}(\tau) = \sum_{k=1}^K \hat{p}_k(1 - \hat{p}_k)$$

$$I_{\text{entropy}}(\tau) = -\sum_{k=1}^K \hat{p}_k \log \hat{p}_k$$

with $\hat{p}_k$ being the proportion of observations from class $k$ in node $\tau$

Machine Learning for Social Science | Decision Trees I | 7 / 11

<!-- page 10 -->

Classification and Regression Trees (CART) | Tree growing

# Tree growing

Figure: Misclassification error, Gini index & entropy (scaled)

Hastie et al. (2009)

Machine Learning for Social Science | Decision Trees I | 8 / 11

<!-- page 11 -->

Classification and Regression Trees (CART) | Tree growing

# Tree growing

---
**Algorithm 1:** Tree growing process
---
1 Define stopping criteria;
2 Assign training data to root node;
3 **if** *stopping criterion is reached* **then**
4 &nbsp;&nbsp;&nbsp;&nbsp;end splitting;
5 **else**
6 &nbsp;&nbsp;&nbsp;&nbsp;find the optimal split point;
7 &nbsp;&nbsp;&nbsp;&nbsp;split node into two subnodes at this split point;
8 &nbsp;&nbsp;&nbsp;&nbsp;**for** *each node of the current tree* **do**
9 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;continue tree growing process;
10 &nbsp;&nbsp;&nbsp;&nbsp;**end**
11 **end**
---

Machine Learning for Social Science | Decision Trees I | 9 / 11

<!-- page 12 -->

Classification and Regression Trees (CART) | Tree growing

# Tree structure

A given tree

$$
\mathcal{T} = \sum_{m=1}^{M} \gamma_m \cdot 1_{(i \in \tau_m)}
$$

consists of a set of $m = 1, 2, \dots, M$ nodes which can be used for prediction by...

- Regression
  - ...using the mean of $y$ for training observations in $\tau_m$
- Classification
  - ...going with the majority class in $\tau_m$

$\rightarrow$ Prediction surface: Block-wise relationship between features and outcome

---

Machine Learning for Social Science | Decision Trees I | 10 / 11

<!-- page 13 -->

Classification and Regression Trees (CART) | Tree growing

# Tree structure

Figure: CART examples

### (a) Regression tree

```
                     lstat>=9.725
                     /          \
                    /            \
           lstat>=16.21        lstat>=4.65
             /      \            /       \
       dis< 2.004  20.17    age< 88.95  dis>=3.055
        /      \              /     \     /     \
     11.72    16.54    lon>=-71.04 38.63 36.55  47.96
                         /      \
                      22.84    27.85
```

### (b) Classification tree

```
                       Sex=male
                       /      \
                      /        \
                 Age>=6.5    Pclass=3
                  /    \      /     \
                 0      1  Fare>=20.8 1
                            /     \
                           0   Age>=16.5
                                 /    \
                                0      1
```

---
Machine Learning for Social Science | Decision Trees I | 11 / 11
