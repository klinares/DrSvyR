---
id: "jpsm/ML_social_science_SURV613/lectures/06-04-ModelBasedRecursivePartitioning"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Decision Trees II"
original: "ML_social_science_SURV613/lectures/06-04-ModelBasedRecursivePartitioning.pdf"
pages: 15
sha256: "0a5cc3edf80336d9e42c712f4beed6f15744c7c0175ca1cc4fc08efc8b7229b8"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:11"
---

<!-- page 1 -->

# Decision Trees II
## Model-Based Recursive Partitioning

<!-- page 2 -->

# Introduction

Extending Decision Trees
* Conditional Inference Trees (Hothorn et al. 2006)
  * Addresses selection bias for variables with many potential split points
  * Separates variable and split point decision
  * Variable selection and stopping criterion based on statistical test
* Model-based Recursive Partitioning (Zeileis et al. 2008)
  * Connects recursive partitioning with fitting parametric (regression) models
  * Approach to fitting "homogeneous" models in tree nodes

<!-- page 3 -->

Model-based Recursive Partitioning

# Model-based Recursive Partitioning

1. Introduction
2. **Model-based Recursive Partitioning**
3. Summary
4. Software Resources
5. References

Machine Learning for Social Science

Decision Trees II

<!-- page 4 -->

# Model-based Recursive Partitioning

* Specify a parametric model in advance
    * Constant leaves: $y \sim \mathcal{N}(\theta, \sigma^2)$
    * OLS regression: $y|x \sim \mathcal{N}(x'\theta, \sigma^2)$
    * logit, survival, ...
* Three types of variables
    * Response variable $y$
    * Predictor variables $x_1, \dots, x_p$
    * Partitioning variables $z_1, \dots, z_j$

$\rightarrow$ Use the partitioning variables $z_1, \dots, z_j$ to partition the $n$ observations into distinct groups with **separate models**

<!-- page 5 -->

Model-based Recursive Partitioning

# Model-based Recursive Partitioning

* Specify a parametric model in advance
  * Constant leaves: $y \sim \mathcal{N}(\theta, \sigma^2)$
  * OLS regression: $y|x \sim \mathcal{N}(x'\theta, \sigma^2)$
  * logit, survival, ...
* Three types of variables
  * Response variable $y$
  * Predictor variables $x_1, \dots, x_p$
  * Partitioning variables $z_1, \dots, z_j$

$\rightarrow$ Use the partitioning variables $z_1, \dots, z_j$ to partition the $n$ observations into distinct groups with **separate models**

Machine Learning for Social Science
Decision Trees II

<!-- page 6 -->

Model-based Recursive Partitioning

# Model-based Recursive Partitioning

---
**Algorithm 1:** Recursive partitioning with GLMs
---
**Parameter :** $p$-value threshold  
**Initialization:** Fit initial model using all observations

1 Perform M-fluctuation tests for each partitioning variable ($H_0$: stability of $\hat{\beta}$);
2 **if** *minimum $p$-value exceeds threshold* **then**
3 | end partitioning (global $H_0$ not rejected);
4 **else**
5 | choose partitioning variable associated with the smallest $p$-value;
6 | find the optimal split point;
7 | split node into two subnodes at this split point;
8 | **for** *each node of the current tree* **do**
9 | | continue partitioning process;
10 | **end**
11 **end**
---

Machine Learning for Social Science | Decision Trees II | 5 / 12

<!-- page 7 -->

Model-based Recursive Partitioning

# Model-based Recursive Partitioning

M-fluctuation tests

Starting point: Objective function of OLS or ML

$$
\hat{\theta} = \underset{\theta}{\text{argmin}} \sum_{i=1}^{n} \Psi(y_i, x_i, \theta)
$$

Solved via score function

$$
\frac{\partial \Psi(y_i, x_i, \theta)}{\partial \theta}
$$

Partial derivations (e.g., $y = \beta_0 + \beta_1 x + \epsilon$)

$$
\frac{d\Psi(y_i, x_i, \beta_0, \beta_1)}{d\beta_0} = \epsilon_i \quad \text{and} \quad \frac{d\Psi(y_i, x_i, \beta_0, \beta_1)}{d\beta_1} = x_i \epsilon_i
$$

$\rightarrow$ Order contributions to score function evaluated at the current estimates with respect to partitioning variable to detect **structural change**

Machine Learning for Social Science
Decision Trees II

<!-- page 8 -->

# Model-based Recursive Partitioning

M-fluctuation tests

Starting point: Objective function of OLS or ML

$$\hat{\theta} = \underset{\theta}{\text{argmin}} \sum_{i=1}^n \Psi(y_i, x_i, \theta)$$

Solved via score function

$$\frac{\partial \Psi(y_i, x_i, \theta)}{\partial \theta}$$

Partial derivations (e.g., $y = \beta_0 + \beta_1 x + \epsilon$)

$$\frac{d\Psi(y_i, x_i, \beta_0, \beta_1)}{d\beta_0} = \epsilon_i \quad \text{and} \quad \frac{d\Psi(y_i, x_i, \beta_0, \beta_1)}{d\beta_1} = x_i \epsilon_i$$

$\rightarrow$ Order contributions to score function evaluated at the current estimates with respect to partitioning variable to detect **structural change**

<!-- page 9 -->

Model-based Recursive Partitioning

# Model-based Recursive Partitioning

M-fluctuation tests

Starting point: Objective function of OLS or ML

$$\hat{\theta} = \underset{\theta}{\text{argmin}} \sum_{i=1}^{n} \Psi(y_i, x_i, \theta)$$

Solved via score function

$$\frac{\partial \Psi(y_i, x_i, \theta)}{\partial \theta}$$

Partial derivations (e.g., $y = \beta_0 + \beta_1 x + \epsilon$)

$$\frac{d\Psi(y_i, x_i, \beta_0, \beta_1)}{d\beta_0} = \epsilon_i \quad \text{and} \quad \frac{d\Psi(y_i, x_i, \beta_0, \beta_1)}{d\beta_1} = x_i \epsilon_i$$

$\rightarrow$ Order contributions to score function evaluated at the current estimates with respect to partitioning variable to detect **structural change**

Machine Learning for Social Science

Decision Trees II

<!-- page 10 -->

Model-based Recursive Partitioning

# Model-based Recursive Partitioning

Figure: Structural change illustration with $x_i\{\text{treatment } (\Delta), \text{control } (\circ)\}$

(a) $\epsilon_i$ by $z$

$\psi_\alpha$

$z_1$

(b) $x_i\epsilon_i$ by $z$

$\psi_\beta$

$z_1$

Seibold et al. (2016)

Machine Learning for Social Science

Decision Trees II

*[Figure: The figure consists of two side-by-side scatter plots illustrating structural change by comparing a treatment group (triangles) and a control group (circles) across the horizontal axis $z_1$ (ranging from -3 to 2) against vertical axes $\psi_\alpha$ in panel (a) and $\psi_\beta$ in panel (b) (ranging from -2 to 2). In panel (a), treatment values shift from predominantly negative to positive as $z_1$ increases past zero while control values shift in the opposite direction, whereas in panel (b), control values lie flat at zero and treatment values show the same upward step from negative to positive around $z_1 = 0$.]*

<!-- page 11 -->

# Model-based Recursive Partitioning

Controlling tree complexity
* Test-based stopping
  * $\alpha$ (`alpha`, default = 0.05)
* Tree-based stopping
  * Observations per node (`minsize`)
  * Tree depth (`maxdepth`)
* Post-pruning
  * Prune nodes by checking AIC or BIC improvements

<!-- page 12 -->

# Model-based Recursive Partitioning

Figure: Linear-regression-based tree with partial scatterplots

Zeileis et al. (2008)

*[Figure: This diagram shows a linear-regression-based decision tree that splits data based on `tax` and `ptratio` thresholds into five terminal nodes (Nodes 3, 6, 7, 8, and 9). Each terminal node compares two stacked partial scatterplots (with y-axes from 1 to 54, top x-axes from 0.3 to 3.9, and bottom x-axes from 6.3 to 83.5), illustrating a negative trend in the top row of plots and a generally positive trend in the bottom row across the partitioned subgroups.]*

<!-- page 13 -->

# Summary

* Recursive partitioning approach can be complemented with permutation and M-fluctuation tests
* Adjusts and (heavily) extends CART idea
* Model-based Recursive Partitioning
  1. Tree-based approach to explore interactions
  2. Can be used to detect model misspecification (Kopf et al. 2010)
  3. Extensions for various types of models available (e.g. Strobl et al. 2015)

<!-- page 14 -->

# Software Resources

Resources for R

* A Laboratory for Recursive Partytioning: `party`
    * Includes `ctree` (Conditional Inference Trees) and `mob` (Model-based Recursive Partitioning)
* A Toolkit for Recursive Partytioning: `partykit`
    * Includes a re-implementation of `ctree` and new interfaces for `mob` (`lmtree`, `glmtree`)

<!-- page 15 -->

# References

Hothorn, T., Hornik, K., Zeileis, A. (2006). Unbiased Recursive Partitioning: A Conditional Inference Framework. *Journal of Computational and Graphical Statistics 15*(3), 651–674.

Kopf, J., Augustin, T., and Strobl, C. (2010). *The Potential of Model-based Recursive Partitioning in the Social Sciences – Revisiting Ockham's Razor.* Technical Report Number 88, University of Munich.

Seibold, H., Zeileis, A., Hothorn, T. (2016). Model-Based Recursive Partitioning for Subgroup Analyses. *The International Journal of Biostatistics 12*(1), 45–63.

Strobl, C., Kopf, J., Zeileis, A. (2015). Rasch Trees: A New Method for Detecting Differential Item Functioning in the Rasch Model. *Psychometrika 80*(2), 289–316.

Zeileis, A., Hothorn, T., Hornik, K. (2008). Model-Based Recursive Partitioning. *Journal of Computational and Graphical Statistics 17*(2), 492–514.

Zeileis, A., Hornik, K. (2007). Generalized M-fluctuation tests for parameter instability. *Statistica Neerlandica 61*(4), 488–508.
