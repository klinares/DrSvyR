---
id: "jpsm/ML_social_science_SURV613/lectures/06-02-TreePruning"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Decision Trees I"
original: "ML_social_science_SURV613/lectures/06-02-TreePruning.pdf"
pages: 11
sha256: "7d9015b915335ef4ede993771beb10f1076398d5a79589da61b7de0d843b9375"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:11"
---

<!-- page 1 -->

# Decision Trees I

## Tree Pruning

<!-- page 2 -->

# Tree structure

Figure: CART examples

(a) Regression tree

```
                     lstat>=9.725
            ┌──────────────┴──────────────┐
      lstat>=16.21                   lstat>=4.65
      ┌─────┴─────┐                 ┌─────┴─────┐
 dis< 2.004     20.17          age< 88.95   dis>=3.055
  ┌───┴───┐                    ┌────┴────┐   ┌───┴───┐
11.72   16.54             lon>=-71.04  38.63 36.55  47.96
                           ┌───┴───┐
                         22.84   27.85
```

(b) Classification tree

```
                      Sex=male
            ┌─────────────┴─────────────┐
        Age>=6.5                     Pclass=3
        ┌───┴───┐                 ┌─────┴─────┐
        0       1            Fare>=20.8       1
                              ┌───┴───┐
                              0   Age>=16.5
                                  ┌───┴───┐
                                  0       1
```

Machine Learning for Social Science | Decision Trees I | 2 / 9

*[Figure: The figure displays two side-by-side hierarchical decision tree diagrams titled "CART examples," comparing "(a) Regression tree" on the left and "(b) Classification tree" on the right, without standard coordinate axes. The regression tree splits on numerical variables (`lstat`, `dis`, `age`, `lon`) to yield continuous numeric terminal leaf values (ranging from 11.72 to 47.96), whereas the classification tree splits on demographic and passenger attributes (`Sex`, `Age`, `Pclass`, `Fare`) to assign observations into binary terminal classes (0 or 1).]*

<!-- page 3 -->

# Tree structure

Figure: Tree prediction surface (example)

Machine Learning for Social Science

Decision Trees I

*[Figure: The figure is a 3D surface plot illustrating an example of a decision tree prediction surface across two input axes (`x1` and `x2`) and one vertical output axis (`yhat`). The main pattern shows a piecewise-constant, step-like structure where the predicted value (`yhat`) remains flat within rectangular regions of the `x1`-`x2` plane and jumps abruptly in height across region boundaries, reaching its highest peak in the back-right corner.]*

<!-- page 4 -->

# Tree structure

Figure: High variance in trees

* Overfitting = Poor generalization to new data
* Function approximates training data well, but the number of terminal nodes is high

Machine Learning for Social Science

Decision Trees I

*[Figure: The plot, titled "Figure: High variance in trees," displays a single red step-function curve representing a decision tree's predictions with $x$ on the horizontal axis (ranging from 0.0 to 10.0) and $y$ on the vertical axis (marked at 2, 4, and 6). The main pattern shows three distinct vertical plateaus—around $y=2$ (for $x < 2.8$), $y=5$ (for $2.8 < x < 8.0$), and $y=7$ (for $x > 8.0$)—each exhibiting frequent, jagged fluctuations that illustrate overfitting and high variance.]*

<!-- page 5 -->

# Tree pruning

Stopping rules
* Minimum number of cases in terminal nodes
* Decrease in impurity exceeds some threshold

$\rightarrow$ However, worthless splits can be followed by good splits

Cost complexity pruning
Find optimal subtree(s) $\mathcal{T}_\alpha$ by balancing tree quality $SSE(\mathcal{T}) = \sum(y_i - \hat{y}_i(\mathcal{T}))^2$ and tree size $|\mathcal{T}|$

$$C_\alpha(\mathcal{T}) = SSE(\mathcal{T}) + \alpha|\mathcal{T}|$$

* $\alpha$ controls the penalty on the number of terminal nodes
* $\alpha$ can be chosen through CV

<!-- page 6 -->

# Tree pruning

Stopping rules
* Minimum number of cases in terminal nodes
* Decrease in impurity exceeds some threshold

$\rightarrow$ However, worthless splits can be followed by good splits

Cost complexity pruning

Find optimal subtree(s) $\mathcal{T}_\alpha$ by balancing tree quality $SSE(\mathcal{T}) = \sum(y_i - \hat{y}_i(\mathcal{T}))^2$ and tree size $|\mathcal{T}|$

$$C_\alpha(\mathcal{T}) = SSE(\mathcal{T}) + \alpha|\mathcal{T}|$$

* $\alpha$ controls the penalty on the number of terminal nodes
* $\alpha$ can be chosen through CV

<!-- page 7 -->

Tree pruning

# Surrogate splits and costs

Missings
* Create a new category for missing values
* Use surrogate splits
  1. Choose best (primary) predictor based on complete cases
  2. Search for surrogate variables which mimic the chosen split
  3. Use surrogates if values for primary predictor are missing

Costs

$$
\mathbf{L} = \begin{pmatrix} 0 & L_{fp} \\ L_{fn} & 0 \end{pmatrix}
$$

* Typically $L_{fp} = L_{fn} = 1$
* Misclassifications can be weighted differently
  * Modification of loss-matrix through weights / modified Gini index

Machine Learning for Social Science | Decision Trees I | 6 / 9

<!-- page 8 -->

Tree pruning

# Surrogate splits and costs

Missings
- Create a new category for missing values
- Use surrogate splits
  1. Choose best (primary) predictor based on complete cases
  2. Search for surrogate variables which mimic the chosen split
  3. Use surrogates if values for primary predictor are missing

Costs

$$
\mathbf{L} = \begin{pmatrix} 0 & L_{fp} \\ L_{fn} & 0 \end{pmatrix}
$$

- Typically $L_{fp} = L_{fn} = 1$
- Misclassifications can be weighted differently
  - Modification of loss-matrix through weights / modified Gini index

Machine Learning for Social Science | Decision Trees I | 6 / 9

<!-- page 9 -->

# Summary

- Divide-and-conquer strategy that splits the data into subgroups
- Surface from decision trees is a non-smooth step function
- No need to specify the functional form in advance (unlike regression)
- Non-linearities and interactions are handled automatically
- Limitations: Instability(!), competition among correlated predictors, biased variable selection

<!-- page 10 -->

# Software Resources

Resources for R
* Basic CART implementation: `tree`
* Standard package to build CARTs: `rpart`
  * Includes build-in Cross-Validation and `prune` function
* Unified infrastructure for tree representation: `partykit`

<!-- page 11 -->

# References

Hastie, T., Tibshirani, R., Friedman, J. (2009). *The Elements of Statistical Learning: Data Mining, Inference, and Prediction*. New York, NY: Springer.

James, G., Witten, D., Hastie, T., Tibshirani, R. (2013). *An Introduction to Statistical Learning*. New York, NY: Springer.

Loh, W.-Y. (2014). Fifty Years of Classification and Regression Trees. *International Statistical Review 82*(3), 329–348.

Zhang, H., Singer, B. (2010). *Recursive Partitioning and Applications*. New York, NY: Springer.
