---
id: "jpsm/ML_social_science_SURV613/lectures/10-03-SurrogateModels"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Interpretable ML"
original: "ML_social_science_SURV613/lectures/10-03-SurrogateModels.pdf"
pages: 5
sha256: "3de02378897a3fcde2f238edba5d500cf508bdfb0c86150d9ca7feb00aca42f7"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:07"
---

<!-- page 1 -->

# Interpretable ML
## Surrogate Models

<!-- page 2 -->

Surrogate Models

# Global Surrogate

General idea: Approximate “black box” model with a simpler model

1. Get predictions of black box model for a dataset (e.g., the training data)
2. Select an interpretable model type
   1. linear model, decision tree, ...
3. Train the interpretable model with the black box predictions as the outcome
4. Check performance of the surrogate model
5. Interpret the surrogate model

$\rightarrow$ Use, e.g., a single tree to “summarize” a random forests decisions

Machine Learning for Social Science

Interpretable ML

<!-- page 3 -->

Surrogate Models

# Local Surrogate

LIME – Local interpretable model-agnostic explanations (Ribeiro et al. 2016)

- Focus on explaining individual predictions
- Assumption: Complex model is linear/ simple on a local scale
- Intuition: Fit a locally optimal model $g$ given proximity measure $\pi_x$ and complexity $\Omega(g)$

$$
\text{explanation}(x) = \arg \min_{g \in G} L(f, g, \pi_x) + \Omega(g)
$$

1. Select instance of interest and permute observation $n$ times
2. Predict the outcome of permuted observations with the complex model
3. Weight the new observations according to their proximity to the instance of interest
4. Train a weighted, interpretable model on the permuted data
5. Interpret the local model

Machine Learning for Social Science | Interpretable ML | 3 / 5

<!-- page 4 -->

Surrogate Models

# Local Surrogate

Figure: Local interpretable model-agnostic explanations (LIME)

(a) Intuition

(b) Example

Actual prediction: 25.05
LocalModel prediction: 29.21

feature.value
rm=6.575
lstat=4.98
ptratio=15.3

effect
-10 0 10 20

Machine Learning for Social Science
Interpretable ML

<!-- page 5 -->

Surrogate Models

# More interpretable ML

* Shapley values and SHAP
  * https://link.springer.com/article/10.1007/s10115-013-0679-x
  * https://arxiv.org/abs/1705.07874
* Feature interaction (H-statistic)
  * https://arxiv.org/abs/0811.1679
* Partial dependence-based variable importance
  * https://arxiv.org/pdf/1805.04755.pdf
* Representative trees from ensembles
  * https://www.ncbi.nlm.nih.gov/pubmed/22302520

Machine Learning for Social Science
Interpretable ML
