---
id: "jpsm/ML_social_science_SURV613/lectures/06-03-CTREE"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Decision Trees II"
original: "ML_social_science_SURV613/lectures/06-03-CTREE.pdf"
pages: 7
sha256: "20068161a7aea4313d59464ffef205f7198c36e392543d5d559ccff20956d7ab"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:11"
---

<!-- page 1 -->

# Decision Trees II
## Conditional Inference Trees

<!-- page 2 -->

Introduction

# Introduction

Extending Decision Trees
* Conditional Inference Trees (Hothorn et al. 2006)
  * Addresses selection bias for variables with many potential split points
  * Separates variable and split point decision
  * Variable selection and stopping criterion based on statistical test
* Model-based Recursive Partitioning (Zeileis et al. 2008)
  * Connects recursive partitioning with fitting parametric (regression) models
  * Approach to fitting “homogeneous” models in tree nodes

Machine Learning for Social Science

Decision Trees II

<!-- page 3 -->

# Conditional Inference Trees

---
**Algorithm 1:** Grow a CTREE
---
**Parameter :** $p$-value threshold
**Initialization:** Assign training data to root node

**1** Perform permutation tests for each covariate ($H_0$: $Y$ and $X_j$ independent);
**2** **if** *minimum $p$-value exceeds threshold* **then**
**3** $\quad$ end splitting (global $H_0$ not rejected);
**4** **else**
**5** $\quad$ select covariate with strongest association (smallest $p$-value);
**6** $\quad$ find the optimal split point for the selected variable;
**7** $\quad$ split node into two subnodes at this split point;
**8** $\quad$ **for** *each node of the current tree* **do**
**9** $\quad\quad$ continue tree growing process;
**10** $\quad$ **end**
**11** **end**
---

<!-- page 4 -->

# Conditional Inference Trees

General test statistic for **variable selection** with weights $w$, transformation $g$ and influence function $h$:

$$
\mathbf{T}_j = vec \left( \sum_{i=1}^n w_i g_j(X_{ij}) h(Y_i, (Y_1, \dots, Y_n))^T \right)
$$

Continuous case: $\mathbf{T}_j = \sum_{i \in node} X_{ji} Y_i$

Standardized test statistic:

$$
c(\mathbf{t}, \mu, \Sigma) = \max_{k=1,\dots,pq} \left| \frac{(\mathbf{t} - \mu)_k}{\sqrt{(\Sigma)_{kk}}} \right|
$$

Continuous case: $c \propto \text{Pearson's } r$

<!-- page 5 -->

Conditional Inference Trees

# Conditional Inference Trees

Permutation tests
* Unconditional/ parametric tests involve distribution assumptions
* Conditional tests: Consider distribution of test statistic given the observed data
* Idea: Infer null distribution from randomly shuffled data
* General procedure
  1. Calculate test statistic $c_{j0}$
  2. For all possible permutations
     1. Permute values of variables
     2. Calculate test statistic $c$
  3. Count number of $c$ which are more extreme than $c_{j0}$, $n_{extreme}$
  4. $p = \frac{n_{extreme}}{n_{permutations}}$

Machine Learning for Social Science | Decision Trees II | 5 / 7

<!-- page 6 -->

Conditional Inference Trees

# Conditional Inference Trees

General test statistic for **split point selection** with $A$ denoting a possible partition:

$$\mathbf{T}_{j^*}^A = vec \left( \sum_{i=1}^n w_i I(X_{j^*i} \in A) \cdot h(Y_i, (Y_1, \dots, Y_n))^T \right)$$

Continuous case: $\mathbf{T}_{j^*}^A = n_A \bar{Y}_A$

Search for partition $A$ which maximizes the (standardized) test statistic $c$:

$$A^* = argmax_A c(\mathbf{t}_{j^*}^A, \mu_{j^*}^A, \Sigma_{j^*}^A)$$

Continuous case: Maximize difference between $\bar{Y}_A$ and $\bar{Y}_{node}$

Machine Learning for Social Science
Decision Trees II

<!-- page 7 -->

# Conditional Inference Trees

Figure: Conditional Inference Tree of employment status with SOEP (2008) data

Kopf et al. (2010)

*[Figure: The figure shows a conditional inference tree analyzing employment status by splitting the data first by gender (male vs. female) and then by age ($\le 62$ vs. $> 62$ for males; $\le 60$ vs. $> 60$ for females). At the bottom, four terminal bar plots display the proportions (from 0 to 1 on the y-axis) of "full time" versus "other" employment (on the x-axis), revealing that males aged 62 or younger are predominantly employed full-time, while females aged 60 or younger have a lower full-time proportion, and both genders in the older age brackets are almost exclusively in the "other" category.]*
