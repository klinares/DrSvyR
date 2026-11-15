---
id: "jpsm/ML_social_science_SURV613/lectures/07-02-Bagging"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Bagging, Random Forests, Extra Trees"
original: "ML_social_science_SURV613/lectures/07-02-Bagging.pdf"
pages: 9
sha256: "0ea909084ad62ccefef02925eb2084c64ac93f1e5948e0684318948659d2bab0"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:06"
---

<!-- page 1 -->

# Bagging, Random Forests, Extra Trees

## Bagging

<!-- page 2 -->

# Bootstrap

Figure: Bootstrap process$^1$

| Obs | X | Y |
| :--- | :--- | :--- |
| 1 | 4.3 | 2.4 |
| 2 | 2.1 | 1.1 |
| 3 | 5.3 | 2.8 |

Original Data ($Z$)

$Z^{*1}$

| Obs | X | Y |
| :--- | :--- | :--- |
| 3 | 5.3 | 2.8 |
| 1 | 4.3 | 2.4 |
| 3 | 5.3 | 2.8 |

$\hat{\alpha}^{*1}$

$Z^{*2}$

| Obs | X | Y |
| :--- | :--- | :--- |
| 2 | 2.1 | 1.1 |
| 3 | 5.3 | 2.8 |
| 1 | 4.3 | 2.4 |

$\hat{\alpha}^{*2}$

$Z^{*B}$

| Obs | X | Y |
| :--- | :--- | :--- |
| 2 | 2.1 | 1.1 |
| 2 | 2.1 | 1.1 |
| 1 | 4.3 | 2.4 |

$\hat{\alpha}^{*B}$

$^1$James et al. (2013)

<!-- page 3 -->

# Bootstrap

Bootstrap: Sampling $B$ samples of size $n$ with replacement from original data set

Applications
* Estimate the variability of model parameters
  * e.g. standard errors of regression coefficients
* Estimate test error with training data
  * Fit model on bootstrap samples and predict original training set
  * “.632” & “$.632^+$” estimator
* Construct an ensemble of learners for prediction
  * **Bagging**: Bootstrap Aggregating
  * Train prediction models on bootstrap samples

<!-- page 4 -->

Bagging Bootstrap

# Bootstrap Aggregating

Bagging process

1. Draw $B$ bootstrap samples from the training data
2. Build a prediction model $\hat{f}^{*b}(x)$ for each sample using a base learner
3. Compute the combined prediction $\hat{f}_{bag}(x)$ over all samples
   - Regression: $\hat{f}_{bag}(x) = \frac{1}{B} \sum_{b=1}^{B} \hat{f}^{*b}(x)$
   - Classification: $\hat{G}_{bag}(x) = \arg \max_k \hat{f}_{bag}(x)$

$\rightarrow$ Averaging over multiple predictions reduces variance / increases prediction accuracy

Machine Learning for Social Science Bagging, Random Forests, Extra Trees 4 / 9

<!-- page 5 -->

Bagging Bootstrap

# Bootstrap Aggregating

Observations in each bootstrap sample

$$
\begin{aligned}
P(\text{obs } i \in \text{sample } b) &= 1 - \left(1 - \frac{1}{n}\right)^n \\
&\approx 1 - e^{-1} \\
&= 0.632
\end{aligned}
$$

Out-of-bag (OOB) Error
* Sampling with replacement leads to models based on subsets of the data
* Unused (OOB) observations can be used for test error estimation
  1. Generate predictions for case $i$ using models where $i$ was OOB
  2. Average predictions for $i$ and estimate test error
  3. Compute OOB error over all cases

Machine Learning for Social Science Bagging, Random Forests, Extra Trees 5 / 9

<!-- page 6 -->

Bagging Bagging Trees

# Bagging Trees

---
**Algorithm 1:** Bagging Trees
---
**1** Set number of trees $B$;
**2** Define stopping criteria;
**3** **for** $b = 1$ *to* $B$ **do**
**4** $\quad$ draw a bootstrap sample from the training data;
**5** $\quad$ assign sampled data to root node;
**6** $\quad$ **if** *stopping criterion is reached* **then**
**7** $\quad\quad$ end splitting;
**8** $\quad$ **else**
**9** $\quad\quad$ find the optimal split point among the predictor space;
**10** $\quad\quad$ split node into two subnodes at this split point;
**11** $\quad\quad$ **for** *each node of the current tree* **do**
**12** $\quad\quad\quad$ continue tree growing process;
**13** $\quad\quad$ **end**
**14** $\quad$ **end**
**15** **end**
---

Machine Learning for Social Science Bagging, Random Forests, Extra Trees 6 / 9

<!-- page 7 -->

# Bagging Trees

Figure: Bagging Trees

(a) $\text{b} = 1$

(b) $\text{b} = 2$

(c) $\text{b} = 3$

<!-- page 8 -->

# Bagging Trees

General motivation: Assume training observations $(x_i, y_i)$ from a distribution $\mathcal{P}$ and bootstrap data $x_i^*$, $y_i^*$ sampled from $\mathcal{P}$

$$
\begin{aligned}
\mathsf{E}_{\mathcal{P}}[Y - \hat{f}^*(x)]^2 &= \mathsf{E}_{\mathcal{P}}[Y - \mathsf{E}_{\mathcal{P}}\hat{f}^*(x) + \mathsf{E}_{\mathcal{P}}\hat{f}^*(x) - \hat{f}^*(x)]^2 \\
&= \mathsf{E}_{\mathcal{P}}[Y - \mathsf{E}_{\mathcal{P}}\hat{f}^*(x)]^2 + \mathsf{E}_{\mathcal{P}}[\hat{f}^*(x) - \mathsf{E}_{\mathcal{P}}\hat{f}^*(x)]^2 \\
&\ge \mathsf{E}_{\mathcal{P}}[Y - \mathsf{E}_{\mathcal{P}}\hat{f}^*(x)]^2
\end{aligned}
$$

$\rightarrow$ Suggests that Bagging decreases mean-squared error

<!-- page 9 -->

# bNN

Bagged nearest neighbors
1. For $b = 1$ to $B$ do
    1. Draw a bootstrap sample $b$ from the training data
    2. Identify the K nearest neighbors of test example
    3. Estimate $\hat{f}^{*b}(x)$ (regression: $\frac{1}{K} \sum y_i$, classification: $\frac{1}{K} \sum I(y_i = j)$)
2. Average all $\hat{f}^{*b}(x)$ to obtain $\hat{f}_{bag}(x)$

kNN vs. bNN
* kNN not much affected by bagging
* Resample sizes (Hall & Samworth 2005)
    * (m out of n) Bootstrapping: Improvement if resample size $< 0.69n$
    * Subsampling (w/o replacement): Improvement if resample size $< 0.5n$
