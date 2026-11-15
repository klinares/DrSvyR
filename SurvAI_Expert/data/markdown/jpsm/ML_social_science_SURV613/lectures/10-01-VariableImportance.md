---
id: "jpsm/ML_social_science_SURV613/lectures/10-01-VariableImportance"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Interpretable ML"
original: "ML_social_science_SURV613/lectures/10-01-VariableImportance.pdf"
pages: 5
sha256: "91941482c06567cdfa13149ffafe1b491dadd6d4c1f17935f6d6248e6c03c360"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:07"
---

<!-- page 1 -->

# Interpretable ML
## Variable Importance

<!-- page 2 -->

# Introduction

---
**Algorithm 1:** Grow a Random Forest
---
**1** Set number of trees $B$;
**2** Set predictor subset size $m$;
**3** Define stopping criteria;
**4** **for** $b = 1$ *to* $B$ **do**
**5** $\quad$ draw a bootstrap sample from the training data;
**6** $\quad$ assign sampled data to root node;
**7** $\quad$ **if** *stopping criterion is reached* **then**
**8** $\quad\quad$ end splitting;
**9** $\quad$ **else**
**10** $\quad\quad$ draw a random sample $m$ from the $p$ predictors;
**11** $\quad\quad$ find the optimal split point among $m$;
**12** $\quad\quad$ split node into two subnodes at this split point;
**13** $\quad\quad$ **for** *each node of the current tree* **do**
**14** $\quad\quad\quad$ continue tree growing process;
**15** $\quad\quad$ **end**
**16** $\quad$ **end**
**17** **end**
---

Machine Learning for Social Science $\quad$ Interpretable ML $\quad$ 2 / 5

<!-- page 3 -->

# Interpretable ML

Interpreting Random Forests

* Inspect each tree of the forest
  * Inefficient for 500+ trees
* Variable importance
  * Summary of “effect size”
* Partial dependence plots
  * Graphical representation of “effect structure”
* ...

<!-- page 4 -->

Interpretable ML Variable Importance

# Variable Importance

Variable importance with CART

$$
\mathcal{I}_\ell^2(T) = \sum_{t=1}^{J-1} \hat{i}_t^2 I(v(t) = \ell)
$$

* Sum of squared improvements $\hat{i}^2$ over all internal nodes with predictor $X_\ell$
  * Regression: Overall reduction in RSS caused by $X_\ell$
  * Classification: Overall reduction of impurity caused by $X_\ell$

Importance with Random Forests

$$
\mathcal{I}_\ell^2 = \frac{1}{M} \sum_{m=1}^M \mathcal{I}_\ell^2(T_m)
$$

* Average improvement caused by predictor $X_\ell$ over all trees

Machine Learning for Social Science Interpretable ML 4 / 5

<!-- page 5 -->

Interpretable ML | Variable Importance

# Variable Importance

Permutation feature importance (Fisher et al. 2018)

1. Estimate the original model error $e_{orig}(\hat{f}) = L(Y, \hat{f}(X))$
2. For each feature $j \in 1, \dots, p$
    1. Generate feature matrix $X_{perm\,j}$ by permuting the values of feature $X_j$ in $X$
    2. Estimate error $e_{perm} = L(Y, \hat{f}(X_{perm\,j}))$ based on the predictions of the permuted data
    3. Calculate permutation feature importance $FI_j = \frac{e_{perm}(\hat{f})}{e_{orig}(\hat{f})}$ or via $FI_j = e_{perm}(\hat{f}) - e_{orig}(\hat{f})$
3. Output $FI$ for all variables

Machine Learning for Social Science | Interpretable ML | 5 / 5
