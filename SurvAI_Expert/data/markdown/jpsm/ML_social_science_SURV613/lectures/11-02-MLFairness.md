---
id: "jpsm/ML_social_science_SURV613/lectures/11-02-MLFairness"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Bias and Fairness in ML"
original: "ML_social_science_SURV613/lectures/11-02-MLFairness.pdf"
pages: 10
sha256: "1707a08986935fd3ef9219f6b185d2ef93f7d54fffef6399ce2168280f1da539"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:07"
---

<!-- page 1 -->

# Bias and Fairness in ML

## Fairness

<!-- page 2 -->

# Fairness Definitions

Equality of Treatment
* Fairness through Unawareness
    * An algorithm is fair if protected attributes are not explicitly used in the decision-making process
* Counterfactual Fairness
    * An algorithm is fair if its output remains the same when the protected attribute is flipped to its counterfactual value

Equality of Outcomes
* Demographic Parity
    * Members of groups have an equal probability of being assigned to the positive class
* Conditional Statistical Parity
    * Demographic parity holds given a set of legitimate factors
* Fairness Through Awareness
    * An algorithm is fair if it gives similar predictions to similar individuals

<!-- page 3 -->

# Fairness Definitions

Equality of Performance/ Error

* Predictive Parity
  * Equalizing $FDR_g = \frac{FP_g}{FP_g + TP_g}$
* Sufficiency
  * Equalizing $FDR_g$ and $FOR_g = \frac{FN_g}{FN_g + TN_g}$
* Equal Opportunity
  * Equalizing $FNR_g = \frac{FN_g}{FN_g + TP_g}$
* Equalized Odds
  * Equalizing $FNR_g$ and $FPR_g = \frac{FP_g}{FP_g + TN_g}$
* Treatment Equality
  * Equalizing $\frac{FP_g}{FN_g}$
* Test Fairness
  * Considers complete score distribution across groups

Table: Confusion matrix

| | | Prediction | | |
| :--- | :---: | :---: | :---: | :---: |
| | | 0 | 1 | |
| **Reference** | 0 | TN | FP | N' |
| | 1 | FN | TP | P' |
| | | N | P | |

$\rightarrow$ *Notions are in conflict with each other and with overall accuracy*

<!-- page 4 -->

# Fairness Definitions

Equality of Performance/ Error

* Predictive Parity
  * Equalizing $FDR_g = \frac{FP_g}{FP_g + TP_g}$
* Sufficiency
  * Equalizing $FDR_g$ and $FOR_g = \frac{FN_g}{FN_g + TN_g}$
* Equal Opportunity
  * Equalizing $FNR_g = \frac{FN_g}{FN_g + TP_g}$
* Equalized Odds
  * Equalizing $FNR_g$ and $FPR_g = \frac{FP_g}{FP_g + TN_g}$
* Treatment Equality
  * Equalizing $\frac{FP_g}{FN_g}$
* Test Fairness
  * Considers complete score distribution across groups

Table: Confusion matrix

| | | Prediction | | |
| :--- | :---: | :---: | :---: | :---: |
| | | 0 | 1 | |
| **Reference** | 0 | TN | FP | N' |
| | 1 | FN | TP | P' |
| | | N | P | |

$\rightarrow$ *Notions are in conflict with each other and with overall accuracy*

<!-- page 5 -->

# Fairness Definitions

1. Individual Fairness: Give similar predictions to similar individuals
2. Group Fairness: Treat different groups equally
3. Subgroup Fairness: Extend group fairness to large collection of subgroups

Table: Categorizing Fairness Notions (Mehrabi et al. 2019)

| | Group | Individual |
| :--- | :---: | :---: |
| Demographic parity | x | |
| Conditional statistical parity | x | |
| Equalized odds | x | |
| Equal opportunity | x | |
| Fairness through unawareness | | x |
| Fairness through awareness | | x |
| Counterfactual fairness | | x |

<!-- page 6 -->

Fair ML Fairness Definitions

# Fairness Definitions

Figure: Choosing Fairness Metrics (Saleiro et al. 2018)

* **Do you want to be fair based on disparate representation OR based on disparate errors of your system?**
  * **Representation**
    * **Do you need to select equal # of people from each group OR proportional to their % in the overall population?**
      * **Equal Numbers**
        * Equal Selection Parity
      * **Proportional**
        * Demographic Parity
  * **Errors**
    * **Do you trust the labels?**
      * **Yes**
        * **Are your interventions punitive or assistive?**
          * **Punitive (could hurt individuals)**
            * FP Parity
            * FDR Parity
            * FP/GS Parity
            * FPR Parity
          * **Assistive (will help individuals)**
            * FN Parity
            * FOR Parity
            * FN/GS Parity
            * FNR Parity
      * **No**
        * Counterfactual Fairness

Machine Learning for Social Science Bias and Fairness in ML 5 / 9

<!-- page 7 -->

Fair ML   Methods for Fair ML

# Methods for Fair ML

Some Potential Solutions (Berk et al. 2017)

1. Pre-processing
    * Eliminating sources of unfairness in data before model training
        * Remove linear dependence between legitimate and protected predictors
        * Re-label some response values to make base rates comparable
        * Perturb class membership for protected attributes for some cases
2. In-processing
    * Making fairness adjustments as part of the model building process
        * Add fairness penalty to loss function
3. Post-processing
    * Adjust model output post-training to make it more fair
        * Randomly re-assign some predicted class labels

Machine Learning for Social Science   Bias and Fairness in ML   6 / 9

<!-- page 8 -->

# Software Resources

Resources for R

* PDP, ICE, ALE
  * Plot model surfaces: `plotmo`
  * Partial Dependence Plots: `pdp`
  * ICE plots: `ICEbox`
  * ALE plots: `ALEPlot`
* Interpretable Machine Learning in R: `iml`
* Descriptive mAchine Learning EXplanations: `DALEX`

<!-- page 9 -->

# References

Mehrabi, N., Morstatter, F., Saxena, N., Lerman, K., Galstyan, A. (2019). A Survey on Bias and Fairness in Machine Learning. `https://arxiv.org/abs/1908.09635`.

Molnar, C. (2019). Interpretable Machine Learning. A Guide for Making Black Box Models Explainable. `https://christophm.github.io/interpretable-ml-book/`.

Rodolfa, K. T., Saleiro, P., Ghani, R. (2019). Bias and Fairness. In: Foster, I., Ghani, R., Jarmin, R. S., Kreuter, F., and Lane, J. (Eds.). Big Data and Social Science: A Practical Guide to Methods and Tools. `https://coleridge-initiative.github.io/big-data-and-social-science/`.

<!-- page 10 -->

# References

Apley, D. W. (2016). Visualizing the effects of predictor variables in black box supervised learning models. `https://arxiv.org/abs/1612.08468`.

Berk, R., Heidari, H., Jabbari, S., Kearns, M., Roth, A. (2017). Fairness in Criminal Justice Risk Assessments: The State of the Art. `https://arxiv.org/abs/1703.09207`

Fisher, A., Rudin, C., Dominici, F. (2018). Model Class Reliance: Variable importance measures for any machine learning model class, from the ‘Rashomon’ perspective. `http://arxiv.org/abs/1801.01489`.

Friedman, J. (2001). Greedy Function Approximation: A Gradient Boosting Machine. *The Annals of Statistics*, *29*(5), 1189–1232.

Goldstein, A., Kapelner, A., Bleich, J., Pitkin, E. (2014). Peeking Inside the Black Box: Visualizing Statistical Learning with Plots of Individual Conditional Expectation. `https://arxiv.org/abs/1309.6392`.

Lum, K. and Isaac, W. (2016). To predict and serve? Significance 13, 14–19.

Murdoch, W., Singh, C., Kumbier, K., Abbasi-Asl, R., Yu, B. (2019). Interpretable machine learning: definitions, methods, and applications. `https://arxiv.org/abs/1901.04592`.

Ribeiro, M. T., Singh, S., Guestrin, C. (2016). Why should I trust you?: Explaining the predictions of any classifier. `https://arxiv.org/abs/1602.04938`.

Saleiro, P., Kuester, B., Stevens, A., Anisfeld, A., Hinkson, L., London, J., Ghani, R. (2018). Aequitas: A Bias and Fairness Audit Toolkit. `https://arxiv.org/abs/1811.05577`
