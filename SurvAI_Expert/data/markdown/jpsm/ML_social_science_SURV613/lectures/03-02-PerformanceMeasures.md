---
id: "jpsm/ML_social_science_SURV613/lectures/03-02-PerformanceMeasures"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Performance measures & kNN"
original: "ML_social_science_SURV613/lectures/03-02-PerformanceMeasures.pdf"
pages: 9
sha256: "2f0688a960ac32baf0dfef40d64c760b8600276e047fc9d2243300a877715739"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:10"
---

<!-- page 1 -->

# Performance measures & kNN

## Performance Measures

<!-- page 2 -->

# Performance measures for classification

Probabilities, thresholds and prediction for classification

$$
y_i = \begin{cases} 1 & \text{if} \quad p_i > c \\ 0 & \text{if} \quad p_i \leq c \end{cases}
$$

Table: Confusion matrix

| | | Prediction | | |
| :--- | :---: | :---: | :---: | :---: |
| | | 0 | 1 | |
| | 0 | True Negatives (TN) | False Positives (FP) | N' |
| Reference | 1 | False Negatives (FN) | True Positives (TP) | P' |
| | | N | P | |

Machine Learning for Social Science
Performance measures & kNN

<!-- page 3 -->

# Performance measures for classification

Confusion matrix metrics

* Global performance
  * Accuracy: $\frac{TP+TN}{TP+FP+TN+FN}$
  * Misclassification rate: $\frac{FP+FN}{TP+FP+TN+FN}$
  * No Information rate
* Row / column performance
  * Sensitivity (Recall): $\frac{TP}{TP+FN}$
  * Specificity: $\frac{TN}{TN+FP}$
  * Positive predictive value (Precision): $\frac{TP}{TP+FP}$
  * Negative predictive value: $\frac{TN}{TN+FN}$
  * False positive rate: $\frac{FP}{FP+TN}$
  * False negative rate: $\frac{FN}{FN+TP}$

Table: Confusion matrix

| | | Prediction | | |
| :--- | :---: | :---: | :---: | :---: |
| | | 0 | 1 | |
| Reference | 0 | TN | FP | N' |
| | 1 | FN | TP | P' |
| | | N | P | |

<!-- page 4 -->

# Performance measures for classification

Combined measures

- Balanced Accuracy
$$(\text{Sensitivity} + \text{Specificity})/2$$

- $F1$
$$2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}}$$

- Cohen's $\kappa$
  - Compares observed ($p_0$) and random ($p_e$) accuracy
  - $p_e = \frac{(N' \times N) + (P' \times P)}{(TP + FP + TN + FN)^2}$
$$1 - \frac{1 - p_0}{1 - p_e}$$

<!-- page 5 -->

# Performance measures for classification

Figure: Varying the classification threshold I

(a) Sensitivity and specificity

Sensitivity

Specificity

1.0

0.8

0.6

0.4

0.2

0.0

0.0

0.2

0.4

0.6

0.8

Threshold

(b) Precision and recall

Recall

Precision

1.0

0.8

0.6

0.4

0.2

0.0

0.0

0.2

0.4

0.6

0.8

Threshold

Machine Learning for Social Science

Performance measures & kNN

*[Figure: The figure consists of two side-by-side line plots showing classification performance measures (ranging from 0.0 to 1.0 on the vertical axes) as a function of the classification "Threshold" (ranging from 0.0 to 0.8+ on the horizontal axes), comparing Sensitivity (solid line) and Specificity (dotted line) in panel (a), and Recall (solid line) and Precision (dotted line) in panel (b). As the threshold increases, both Sensitivity and Recall decrease monotonically from 1.0 to 0.0, whereas Specificity increases smoothly from 0.0 to 1.0 and Precision generally increases (with some fluctuations) from around 0.35 to 1.0, crossing their respective counterparts near a threshold of 0.4.]*

<!-- page 6 -->

# Performance measures for classification

Figure: Varying the classification threshold II

(a) ROC curves

(b) PR curves

$\rightarrow$ AUC-ROC: Area under the receiver operating characteristic curve
$\rightarrow$ AUC-PR: Area under the precision–recall curve

Machine Learning for Social Science
Performance measures & kNN

*[Figure: The figure consists of two side-by-side line plots comparing the performance of "Classifier 1" (black line) and "Classifier 2" (grey line) across varying classification thresholds: (a) ROC curves plotting "Sensitivity" against "1 - Specificity", and (b) PR curves plotting "Precision" against "Recall". While both classifiers exhibit very similar upward trajectories in the ROC plot, the PR curve reveals a sharper distinction at low recall values (below 0.3), where Classifier 1 maintains much higher precision than Classifier 2 before both curves decline together as recall increases.]*

<!-- page 7 -->

# Performance measures for classification

How many true positives are among the high risk observations?

1. Rank observations by risk scores
2. Classify top K % as positive/ relevant
3. Compute precision

Figure: Precision at top K

Classifier 1
Classifier 2

Precision
1.0
0.8
0.6
0.4
0.2

Top K
0
50
100
150

Machine Learning for Social Science
Performance measures & kNN

*[Figure: The line plot, titled "Figure: Precision at top K," compares "Classifier 1" (black line) and "Classifier 2" (grey line) by plotting "Precision" on the vertical axis (ranging from 0.2 to 1.0) against "Top K" on the horizontal axis (ranging from 0 to 150). For both classifiers, precision generally decreases as Top K increases, with Classifier 1 starting higher near 1.0 before both curves converge and decline together from around 0.7 down to below 0.4.]*

<!-- page 8 -->

Software Resources

# Software Resources

Resources for R

* kNN classifier: `knn` in package `class`
  * Tune k using CV: `knn.cv`
  * Package `e1071`: `tune.knn`
* Performance evaluation
  * Collection of performance metrics: `MLmetrics`, `verification`
  * ROC and PR curves: e.g. `PRROC`, `pROC`

Machine Learning for Social Science
Performance measures & kNN

<!-- page 9 -->

# References

Hossin, M., Sulaiman, M. N. (2015). A review on evaluation metrics for data classification evaluations. *International Journal of Data Mining & Knowledge Management Process*, 5(2): 1–11.

James, G., Witten, D., Hastie, T., Tibshirani, R. (2013). *An Introduction to Statistical Learning*. New York, NY: Springer.

Sokolova, M., Lapalme, G. (2009). A systematic analysis of performance measures for classification tasks. *Information Processing & Management*, 45(4): 427–437.
