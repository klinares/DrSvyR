---
id: "jpsm/ML_social_science_SURV613/lectures/12-01-Stacking"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "ML Toolbox"
original: "ML_social_science_SURV613/lectures/12-01-Stacking.pdf"
pages: 10
sha256: "99b8ef125c020a66c88ecaa0a6922d75f378cc914b9b5f52d727d467cc8572e6"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:07"
---

<!-- page 1 -->

# ML Toolbox
## Additional Tools with ML

<!-- page 2 -->

# Introduction

Improving prediction performance

- **Stacking** methods
    - Find optimal combination of lower-level models
    - Utilize different types of methods to build ensemble
- Classification with class imbalance
    - Threshold optimization
    - Cost-sensitive training/ case weights
    - **Over- and under-sampling**

<!-- page 3 -->

# Stacking

Combining prediction models

- Do we have to select one ML method to build the final model?
  - Performances might differ between regions of the data
- General idea: Combine multiple models' predictions with a **meta-model**
- Utilize diverse lower-level models that "span the space"
- Draw on advantages of different model types

$\rightarrow$ Wolpert 1992, Breiman 1996

<!-- page 4 -->

# Stacking

Figure: Stacking process$^1$

Original Training Data
$$\mathbf{X}_{m \times n}$$

Level 1 Models
- model 1
- model 2
- $\vdots$
- model M

Level 2 training data: M predictions are now features
$$\begin{bmatrix} | & & | \\ \hat{y}^{\mu 1} & \cdots & \hat{y}^{\mu M} \\ | & & | \end{bmatrix}_{m \times M}$$
$$\mathbf{X}^{(l2)}$$

Level 2 Model(s)
- Level 2 model

Final prediction
$$\begin{bmatrix} | \\ \hat{y}^{\text{fin}} \\ | \end{bmatrix}$$

---
$^1$`https://burakhimmetoglu.com/2016/12/01/stacking-models-for-improved-predictions/`

Machine Learning for Social Science | ML Toolbox | 4 / 10

<!-- page 5 -->

Stacking

# Second level data

Figure: Create second level training data$^2$

| |
| :---: |
| N |
| N-1 |
| N-2 |
| $\vdots$ |
| j |
| $\vdots$ |
| 2 |
| 1 |

Holdout fold

$$
\begin{matrix}
\mu_1 & \mu_2 & & \mu_M \\
\left[\hat{y}_{F1}^{\mu 1}\right] & \left[\hat{y}_{F1}^{\mu 2}\right] & \cdots\cdots\cdots & \left[\hat{y}_{F1}^{\mu M}\right]
\end{matrix}
$$

| |
| :---: |
| N |
| N-1 |
| N-2 |
| $\vdots$ |
| j |
| $\vdots$ |
| 2 |
| 1 |

Holdout fold

$$
\begin{matrix}
\mu_1 & \mu_2 & & \mu_M \\
\left[\hat{y}_{Fj}^{\mu 1}\right] & \left[\hat{y}_{Fj}^{\mu 2}\right] & \cdots\cdots\cdots & \left[\hat{y}_{Fj}^{\mu M}\right]
\end{matrix}
$$

---

$^2$https://burakhimmetoglu.com/2016/12/01/stacking-models-for-improved-predictions/

Machine Learning for Social Science

ML Toolbox

<!-- page 6 -->

Stacking

# Second level model

Input: Cross-validated predictions $\hat{f}_m^{-i}(x)$

Estimate stacking weights via linear regression...

$$
\hat{w}^{st} = \underset{w}{\operatorname{argmin}} \sum_{i=1}^N \left[ y_i - \sum_{m=1}^M w_m \hat{f}_m^{-i}(x_i) \right]^2
$$

...or logistic regression for classification problems.

Final prediction

$$
\sum_m \hat{w}_m^{st} \hat{f}_m(x)
$$

$\rightarrow$ Super learner will perform asymptotically as well as the best base learner (van der Laan et al. 2007)

Machine Learning for Social Science
ML Toolbox

<!-- page 7 -->

# Stacking process

---
**Algorithm 1:** Stacking
---
**Parameter :** V folds, M base learner $\psi_m$, metalearning method $\phi$
**Initialization:** Partition training data into V folds

1 **for** $v = 1$ *to* $V$ **do**
2 &emsp; **for** $m = 1$ *to* $M$ **do**
3 &emsp; &emsp; Obtain cross-validated predictions $\hat{\psi}_m^{-v}$ ;
4 &emsp; **end**
5 **end**
6 Fit meta model $\hat{\phi}$ using $\hat{\psi}_m^{-v}$ as inputs ;
7 Fit M base models with full training data and save with $\hat{\phi}$ for prediction ;
---

<!-- page 8 -->

Stacking

# Super Learner

Figure: Super Learner$^3$

Data

1. Split data into V blocks
2. Train each candidate learner
   lm | D/S/A | . . . | RF
3. Predict the outcomes in the validation block based on the corresponding training block candidate learner

| Z | | | | obs. |
| :---: | :---: | :---: | :---: | :---: |
| lm | D/S/A | . . . | RF | Y |
| 1 | 1 | | 1 | 1 |
| 2 | 2 | | 2 | 2 |
| .<br>.<br>. | .<br>.<br>. | | .<br>.<br>. | .<br>.<br>. |
| V | V | | V | V |

4. Model selection and fitting for the regression of the observed outcome onto the predicted outcomes from the candidate learners
   $$\text{E}(Y|Z) = m(z; \beta)$$
5. Evaluate super learner by combining predictions from each candidate learner (step 0) with $m(z; \beta)$ (steps 1-4)
0. Train each candidate learner on entire dataset
   lm | D/S/A | . . . | RF

Super Learner

---
$^3$van der Laan et al. (2007)

Machine Learning for Social Science | ML Toolbox | 8 / 10

<!-- page 9 -->

# Extensions

- Blending
  - Throw predictions from various models into one hold-out set
  - Train meta model only on this hold-out set
- Subsemble (Sapp et al. 2014)
  - Introduce additional subset partitions for base learner training
- Feature-Weighted Linear Stacking (Sill et al. 2009)
  - Combines model predictions with meta-features
  - Uses prediction-feature products as meta-model inputs

<!-- page 10 -->

Stacking

# Feature-Weighted Linear Stacking

Figure: Comparison of SLS and FWLS$^4$

## Standard Linear Stacking

Blended Prediction
- w_1 -> SVD
- w_2 -> K-NN
- w_3 -> RBM

$$b(x) = \sum_i w_i g_i(x)$$

## Feature-Weighted Linear Stacking

Blended Prediction
- v_11 -> SVD*f_1
- v_12 -> SVD*f_2
- v_21 -> K-NN*f_1
- v_22 -> K-NN*f_2
- v_31 -> RBM*f_1
- v_32 -> RBM*f_2

$$w_i(x) = \sum_j v_{ij} f_j(x) \text{ , } b(x) = \sum_{i,j} v_{ij} f_j(x) g_i(x)$$

---
$^4$Sill et al. (2009)

Machine Learning for Social Science | ML Toolbox | 10 / 10
