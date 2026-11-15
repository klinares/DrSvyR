---
id: "jpsm/ML_social_science_SURV613/lectures/08-03-GradientBoosting2"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Boosting I"
original: "ML_social_science_SURV613/lectures/08-03-GradientBoosting2.pdf"
pages: 7
sha256: "4082d5cbb85cb3a7f90edff1500e0d4ff0fe7d8bf6b5af5186ce00f867f140a3"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:07"
---

<!-- page 1 -->

# Boosting I

## Shrinkage, Subsampling, Tuning for Gradient Boosting

<!-- page 2 -->

# Shrinkage, Subsampling, Tuning

Shrinkage
- Additional tweak in Gradient boosting
- Slow down learning rate to avoid overfitting
- Learning rate is controlled by $\lambda$
  - $f_m(x) = f_{m-1}(x) + \lambda \sum_{j=1}^{J_m} \gamma_{jm} I(x \in R_{jm})$

Subsampling
- Optional add-on in Gradient boosting
- Use a random sample (w/o replacement) of pseudo-residuals in each step
- Can be introduced to improve performance and speed
  - “Stochastic gradient boosting”

<!-- page 3 -->

Shrinkage, Subsampling, Tuning

# Shrinkage, Subsampling, Tuning

Tuning Gradient Boosting Machines

- Number of trees $M$
  - Number of “iterations”
  - Overfitting can occur for large $M$
- Interaction depth $D$
  - Number of splits for each tree
  - Boosting stumps: $D = 1$
- Shrinkage parameter $\lambda$
  - e.g. $\lambda = 0.01$, $\lambda = 0.001$
  - Smaller $\lambda$ needs larger $M$
- ...

Machine Learning for Social Science
Boosting I

<!-- page 4 -->

# Shrinkage, Subsampling, Tuning

Figure: Performance by number of iterations and shrinkage$^1$

---

$^1$Source: Ridgeway 2018

Machine Learning for Social Science | Boosting I | 4 / 7

<!-- page 5 -->

# Summary

- Boosting sequentially combines multiple models into a powerful ensemble
- Similar to random forests, boosting is a “general purpose” approach
- A lot of different flavors exist
- Specific implementations can be compared in a large train and tune loop
- Drawbacks: Low interpretability and (often) high computational costs

<!-- page 6 -->

# Software Resources

Resources for R

* AdaBoost: `fastAdaboost`
  * AdaBoost implementation with C++ backend
* Standard package for Gradient Boosting: `gbm`
  * Implementation and extensions of AdaBoost and GBM (Ridgeway 2018)

<!-- page 7 -->

# References

Friedman, J. (2001). Greedy Function Approximation: A Gradient Boosting Machine. *The Annals of Statistics*, *29*(5), 1189–1232.

Hastie, T., Tibshirani, R., Friedman, J. (2009). *The Elements of Statistical Learning: Data Mining, Inference, and Prediction*. New York, NY: Springer.

Ridgeway, G. (2018). *Generalized Boosted Models: A guide to the gbm package*. `https://cran.r-project.org/web/packages/gbm/vignettes/gbm.pdf`.

Schapire, R. E. and Freund, Y. (2012). *Boosting: Foundations and Algorithms*. Cambridge, MA: MIT Press.
