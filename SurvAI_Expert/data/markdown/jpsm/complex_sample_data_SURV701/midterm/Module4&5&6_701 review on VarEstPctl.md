---
id: "jpsm/complex_sample_data_SURV701/midterm/Module4&5&6_701_review_on_VarEstPctl"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Review on Variance Estimation Methods 2/27/20"
original: "complex_sample_data_SURV701/midterm/Module4&5&6_701 review on VarEstPctl.pdf"
pages: 4
sha256: "b9deb39030cf95cf906e32affd4b5bc161d4d456b7f3be01348c47f06dbb49da"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:51"
---

<!-- page 1 -->

# Review on Variance Estimation Methods 2/27/20

- Taylor linearization

$$
f(x, z) \approx f(x_0, z_0) + (x - x_0) \left. \frac{\partial f}{\partial x} \right|_{\substack{x=x_0 \\ z=z_0}} + (z - z_0) \left. \frac{\partial f}{\partial z} \right|_{\substack{x=x_0 \\ z=z_0}}
$$

Define $A = \left. \frac{\partial f}{\partial x} \right|_{\substack{x=x_0 \\ z=z_0}}$ and $B = \left. \frac{\partial f}{\partial z} \right|_{\substack{x=x_0 \\ z=z_0}}$

$$
Var_{TL} f(x, z) \approx A^2 Var(x) + B^2 Var(z) + 2AB Cov(x, z)
$$

<u>For example,</u> Ratio Estimate

$$
R = \frac{x}{z}
$$

$$
Var(R) \approx \frac{Var(x) + R^2 Var(z) - 2R Cov(x, z)}{z^2}
$$

- Alternative Variance Estimation – Replication Methods

*Five* Steps in Replicated Methods

1. Create replicates using sampled cases (unique to each method). Software uses sampling error codes provided in the data set.
   – Jackknife Repeated Replication (JRR) replicate sample: leave out one PSU, and re-weight cases in “deletion stratum”.
   – Balanced Repeated Replication (BRR) replicate sample: given two PSUs per stratum, leave out one PSU from each stratum (based on a “balanced” Hadamard matrix to eliminate covariances when estimating variances), and re-weight cases

<!-- page 2 -->

**2. Create revised weight for replicate sample.**

3. Compute weighted estimates of population statistic of interest for each replicate using replicate weight.

**4. Apply replicated variance estimation formula to derive standard errors.**

5. Construct confidence intervals (or hypothesis tests) based on estimated statistics, standard errors, and correct degrees of freedom (use the previously discussed $a - \text{H}$ approximation).

<u>For JRR</u>

$$Var_{JRR} = \sum_{h=1}^{H} \frac{a_h - 1}{a_h} \sum_{\alpha=1}^{a_h} \left( \hat{q}_{(h\alpha)} - \hat{q} \right)^2$$

$$\text{For paired design} = \frac{1}{2} \sum_{h=1}^{H} \left[ \left( \hat{q}_{(h1)} - \hat{q} \right)^2 + \left( \hat{q}_{(h2)} - \hat{q} \right)^2 \right] = \frac{1}{2} \sum_{k=1}^{a} (\hat{q}_k - \hat{q})^2,$$

where

$$w_i^{(h\alpha)} = \begin{cases} 0 & i \in h\alpha \\ \frac{a_h}{a_h - 1} w_i & i \in h\alpha' \\ w_i & i \notin h \end{cases}$$

<u>For BRR</u>

$$Var_{BRR} = \frac{1}{C} \sum_{c=1}^{C} (\hat{q}_c - \hat{q})^2,$$

For each replication half PSUs are sampled by Hadamard matrix

$$w_i^{(c)} = \begin{cases} 0 & i \text{ is selected} \\ 2w_i & o.w. \end{cases}$$

<!-- page 3 -->

<u>For Bootstrap</u>

$$
Var_{BRR} = \frac{1}{B} \sum_{b=1}^{B} (\hat{q}_b - \hat{q})^2,
$$

For each replication, $m_h = a_h - 1$ PSUs are sampled with replacement

$$
w_i^{(b)} = w_i \frac{a_h}{m_h} r_{h\alpha}^{(b)}
$$

with $r_{h\alpha}^{(b)}$ the number of times $\text{PSU}-h\alpha$ is selected in replicate b

## Review of module 6 on Quartile Estimation

1. What are population CDF, and weighted estimator of CDF?

First, the CDF for a variable y in a given population:

$$
F(x) = \frac{\sum_{i=1}^{N} I(y_i \le x)}{N}
$$

A weighted estimator of this CDF can be written as follows:

$$
\hat{F}(x) = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i} I(y_{h\alpha i} \le x)}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i}}
$$

<!-- page 4 -->

2. Estimating the $q$th quantile?

Ungrouped method: first order sample values from smallest to largest, $x_1, \dots, x_n$, and then find the value of $j$ such that

$$\hat{F}(x_j) \le q < \hat{F}(x_{j+1}).$$

Then, a weighted estimate of the $q$-th population quantile, $X_q$, is computed as follows:

$$\hat{X}_q = x_j + \frac{q - \hat{F}(x_j)}{\hat{F}(x_{j+1}) - \hat{F}(x_j)}(x_{j+1} - x_j)$$

**Table below shows values for PPS sample of $n = 8$ observations from a finite population and the corresponding final weights.**

| Sample units $i$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $x_i$ | 1 | 2 | 2.5 | 3.6 | 4.2 | 5.5 | 6.1 | 7 |
| $w_i$ | 3 | 4 | 5 | 1 | 2 | 2 | 2 | 1 |
| | | | | | | | | |
| | | | | | | | | |

**Estimate the median for the x values in the population.**
