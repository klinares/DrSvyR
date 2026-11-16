---
id: "jpsm/ML_social_science_SURV613/lectures/04-02-StepwiseSelection"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Regularized regression I"
original: "ML_social_science_SURV613/lectures/04-02-StepwiseSelection.pdf"
pages: 5
sha256: "99ad34a30545626dc5bfa413f86cbd904f1f9f26f26d0fe51a6330ce8899f233"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:10"
---

<!-- page 1 -->

# Regularized regression I
## Stepwise Variable Selection

<!-- page 2 -->

# Stepwise Variable Selection

---
**Algorithm 1:** Classical forward selection
---
**1** Set $p$-value threshold $\tau$;
**2** Initialize empty model;
**3** **repeat**
**4** $\quad$ **for** *each predictor not in the model* **do**
**5** $\quad\quad$ Add the predictor to the current model;
**6** $\quad\quad$ Estimate the statistical significance of the new term;
**7** $\quad$ **end**
**8** $\quad$ **if** *the smallest $p$ is less than $\tau$* **then**
**9** $\quad\quad$ Include the corresponding predictor in the model;
**10** $\quad$ **end**
**11** **until** *no significant predictor remains outside the model*;
---

Machine Learning for Social Science $\quad$ Regularized regression I $\quad$ 2 / 5

<!-- page 3 -->

# Stepwise Variable Selection

There are a number of **serious** problems here!

1. Multiple testing issue
2. Objective function does not focus on prediction accuracy
3. Prone to performance evaluation bias

Adjusting stepwise selection approaches

1. Usage of performance measures instead of $p$-values
2. Implement feature selection in a (proper) **resampling setting**
3. Interweave feature selection in the model-building process

<!-- page 4 -->

# Stepwise Variable Selection

---
**Algorithm 2:** Forward selection with resampling
---
**1** Set the number of resampling iterations;  
**2** Set the number of features $p$;  
**3** Initialize empty model;  
**4** **for** *each resampling iteration* **do**  
**5** $\quad$ Partition data into training and hold-out set;  
**6** $\quad$ **for** $k = 0, \dots, p - 1$ **do**  
**7** $\quad \quad$ Consider all $p - k$ models that add an additional predictor to the current model;  
**8** $\quad \quad$ Choose the best among these models in terms of loss in the training data;  
**9** $\quad \quad$ Evaluate the chosen model in the hold-out set;  
**10** $\quad$ **end**  
**11** **end**  
**12** Determine the best number of predictors over all hold-out sets;  

---

Machine Learning for Social Science $\quad$ Regularized regression I $\quad$ 4 / 5

<!-- page 5 -->

# Stepwise Variable Selection

Cross-Validation done wrong

* **Never** separate feature selection and CV
  * CV *after* selection on full data *biases* performance measures
  * Hold-out samples are no longer independent test sets
* Include feature selection within the CV loop
* Unsupervised screening on full data is valid

Figure: Correlations of $y$ with unrelated $x$'s with incorrect and correct CV

Hastie et al. (2009)

*[Figure: The figure consists of two stacked histograms comparing the distributions of correlations between selected predictors and an outcome under incorrect ("Wrong way", top in red) versus correct ("Right way", bottom in green) cross-validation. In both plots, the x-axis shows "Correlations of Selected Predictors with Outcome" from -1.0 to 1.0 and the y-axis shows "Frequency" from 0 to 30, illustrating that the "Wrong way" distribution is noticeably shifted toward positive correlations (peaking around 0.2 to 0.6), whereas the "Right way" distribution is more symmetrically centered around 0.0.]*
