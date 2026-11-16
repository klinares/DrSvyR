---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_5"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_5.pdf"
pages: 30
sha256: "322ae661eede33aba1db2fe04faf889438f14aedcf0cd4514f671c2606467ee3"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:53"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

### SURV/SURVMETH 701

### Lecture Notes: Module 5

## Replication Methods for Variance Estimation

### Instructor: Yan Li

### e-mail: [email]

1

<!-- page 2 -->

# Alternatives to Taylor Series Linearization

* The linearization technique is useful if the estimate can be expressed as a function of sample totals; readily available in Stata, SAS, and other software
* Linearization requires analytic manipulations, computation of derivatives
* **Not directly suitable for percentiles such as the median or functions of percentiles (non-smooth functions)**
* Replication techniques are useful for almost any type of estimate
* Empirical comparisons of the different techniques: Kish and Frankel (1974), Kovar, Rao and Wu (1988), Korn and Graubard (1999) (See Canvas)

2

<!-- page 3 -->

# Steps in Replicated Methods

1. Create replicates using sampled cases (unique to each method). Software uses sampling error codes provided in the data set.
   - <u>Jackknife Repeated Replication (JRR) replicate sample</u>: leave out one PSU, and re-weight cases in “deletion stratum”.
   - <u>Balanced Repeated Replication (BRR) replicate sample</u>: given two PSUs per stratum, leave out one PSU from each stratum (based on a “balanced” Hadamard matrix to eliminate covariances when estimating variances), and re-weight cases (see ASDA, Chapter 3).

2. Create revised weight for replicate sample.

3. Compute weighted estimates of population statistic of interest for each replicate using replicate weight.

4. Apply replicated variance estimation formula to derive standard errors.

5. Construct confidence intervals (or hypothesis tests) based on estimated statistics, standard errors, and correct degrees of freedom (generally use the previously discussed $a - \text{H}$ approximation).

3

<!-- page 4 -->

# Replication-based Variance Estimation: Options in Stata

* **Jackknife Repeated Replication (JRR)**
  - Stata: Use `svy, vce(jackknife):` commands
* **Balanced Repeated Replication (BRR)**
  - Stata: Use `svy brr, hadamard(…):` commands
  - Requires two cluster codes per stratum!
* **Bootstrapping**
  - Stata: see Kolenikov (2010, Stata Journal).
  - Example:
    ```
    . svyset [pw=finalwgt], vce(bootstrap) bsrweight(bw*)
    . svy: logistic highbp height weight age female
    ```

4

<!-- page 5 -->

# Replicate Weighting

* JRR, BRR, and bootstrap programs adjust the values of the sample selection weights to create “replicate weights” using the above procedures. Default - no adjustment to original survey weights.
* If nonresponse adjustment and post-stratification adjustments are included in the final survey weight, <u>survey statisticians advocate that these be recomputed for each sample replicate</u>.
* WesVar PC (Westat, Inc.) assists in developing replicate weight adjustments that reflect nonresponse and post-stratification.
* **Replicate weights** are added to data set (one per replicate):

$$
\mathbf{w}=[\mathbf{w}(1), \ldots, \mathbf{w}(\mathbf{K})]
$$

5

<!-- page 6 -->

# Simple Data Example (4 Strata, 2 PSUs/Stratum)

| Stratum | PSU (Cluster) | Case | $y_i$ | $\mathbf{w_i}$ |
| :---: | :---: | :---: | :---: | :---: |
| **1** | **1** | **1** | **.58** | **1** |
| | **1** | **2** | **.48** | **2** |
| **1** | **2** | **1** | **.42** | **2** |
| | **2** | **2** | **.57** | **2** |
| | | | | |
| **2** | **1** | **1** | **.39** | **1** |
| | **1** | **2** | **.46** | **2** |
| **2** | **2** | **1** | **.50** | **2** |
| | **2** | **2** | **.21** | **1** |
| | | | | |
| **3** | **1** | **1** | **.39** | **1** |
| | **1** | **2** | **.47** | **2** |
| **3** | **2** | **1** | **.44** | **1** |
| | **2** | **2** | **.43** | **1** |
| | | | | |
| **4** | **1** | **1** | **.64** | **1** |
| | **1** | **2** | **.55** | **1** |
| **4** | **2** | **1** | **.47** | **2** |
| | **2** | **2** | **.50** | **2** |

<!-- page 7 -->

# JRR: Constructing Replicates, Replicate Weights

* There are several approaches to constructing the JRR replicates. The “Delete One” method that is often the default in survey analysis software is illustrated here.

* For the Delete One JRR variance estimator, each stratum will contribute $a_h$ replicates, where for each replicate, one of the clusters in a single stratum is deleted.

* In our data example, $H=4$ and $a_h=2$ for $h = 1,\dots,4$, so the total number of required JRR replicates for the Delete One JRR is:

$$\sum_{h=1}^{4} a_h = 8$$

7

<!-- page 8 -->

# JRR: Constructing Replicates, Replicate Weights

* Suppose there are H strata with $a_h$ clusters in the $h^{th}$ stratum. H=4, $a_h$=2 in example data set.

* A JRR replicate is constructed by deleting one PSU from one stratum. The first replicate leaves out the 1st PSU in Stratum 1.

* The replicate weight for this first replicate multiplies the weights for remaining cases in the “deletion stratum” by a factor of $a_h/[a_h - 1]$. This equals 2 in our example. Weight values for Replicate 1 remain unchanged for cases in all other strata.

8

<!-- page 9 -->

# JRR Replicate 1: Data Example

| Stratum | PSU (Cluster) | Case | $y_i$ | $w_{i,\text{rep}}$ |
| :---: | :---: | :---: | :---: | :---: |
| 1 | 1 | 1 | . | . |
| | 1 | 2 | . | . |
| 1 | 2 | 1 | .42 | 2x2 |
| | 2 | 2 | .57 | 2x2 |
| | | | | |
| 2 | 1 | 1 | .39 | 1 |
| | 1 | 2 | .46 | 2 |
| 2 | 2 | 1 | .50 | 2 |
| | 2 | 2 | .21 | 1 |
| | | | | |
| 3 | 1 | 1 | .39 | 1 |
| | 1 | 2 | .47 | 2 |
| 3 | 2 | 1 | .44 | 1 |
| | 2 | 2 | .43 | 1 |
| | | | | |
| 4 | 1 | 1 | .64 | 1 |
| | 1 | 2 | .55 | 1 |
| 4 | 2 | 1 | .47 | 2 |
| | 2 | 2 | .50 | 2 |

9

<!-- page 10 -->

# JRR Replicate 2 (of 8): Data Example

| Stratum | PSU (Cluster) | Case | $y_i$ | $w_{i,\text{rep}}$ |
| :---: | :---: | :---: | :---: | :---: |
| 1 | 1 | 1 | .58 | 1x2 |
| | 1 | 2 | .48 | 2x2 |
| 1 | 2 | 1 | . | . |
| | 2 | 2 | . | . |
| | | | | |
| 2 | 1 | 1 | .39 | 1 |
| | 1 | 2 | .46 | 2 |
| 2 | 2 | 1 | .50 | 2 |
| | 2 | 2 | .21 | 1 |
| | | | | |
| 3 | 1 | 1 | .39 | 1 |
| | 1 | 2 | .47 | 2 |
| 3 | 2 | 1 | .44 | 1 |
| | 2 | 2 | .43 | 1 |
| | | | | |
| 4 | 1 | 1 | .64 | 1 |
| | 1 | 2 | .55 | 1 |
| 4 | 2 | 1 | .47 | 2 |
| | 2 | 2 | .50 | 2 |

10

<!-- page 11 -->

# JRR: Constructing Estimates

Here, eight replicates are created and the weighted estimate:

$\hat{q}_k = \bar{y}_k^w = \frac{\sum_{i \in rep}^{n_{rep}} y_i w_{i,rep}}{\sum_{i \in rep}^{n_{rep}} w_{i,rep}}$ is computed for each of $k=1,\ldots,8$ replicates

$$\hat{\text{q}}_{1(\text{del 1\_1})} = 0.47240; \ \hat{\text{q}}_{3(\text{del 2\_1})} = 0.46958; \ \hat{\text{q}}_{5(\text{del 3\_1})} = 0.47434; \ \hat{\text{q}}_{7(\text{del 4\_1})} = 0.46615$$

$$\hat{\text{q}}_{2(\text{del 1\_2})} = 0.47521; \ \hat{\text{q}}_{4(\text{del 2\_2})} = 0.47791; \ \hat{\text{q}}_{6(\text{del 3\_2})} = 0.47320; \ \hat{\text{q}}_{8(\text{del 4\_2})} = 0.48272;$$

$\hat{q} = \frac{\sum_{i=1}^n y_i w_i}{\sum_{i=1}^n w_i}$ the full sample estimate is also computed.

$\hat{\text{q}}=0.47375$

11

<!-- page 12 -->

# JRR Variance Estimation: Delete 1

* If stratum and cluster codes are **available** in the data set:

$$\text{var}_{JRR}(\hat{q}) = \sum_{h=1}^{H} \frac{a_h - 1}{a_h} \sum_{\alpha=1}^{a_h} (\hat{q}_{(h\alpha)} - \hat{q})^2$$

*where*

$\hat{q}_{(h\alpha)} = \text{weighted estimate of Q for replicate where}$

$\text{cluster } \alpha \text{ in stratum } h \text{ has been deleted;}$

$$df = a - H$$

* If **only (*a*) replicate weights** are available in the data set:

$$\text{var}_{JRR}(\hat{q}) = \frac{a - 1}{a} \sum_{k=1}^{a} (\hat{q}_k - \hat{q})^2$$

$$df = a - 1$$

12

<!-- page 13 -->

# JRR: Estimating the Sampling Variance

Since stratum and cluster codes are **available** in the data example

$$
\begin{aligned}
var_{JRR_{DelOne}}(\hat{q}) &= \sum_{h=1}^{H} \frac{a_h - 1}{a_h} \sum_{\alpha=1}^{a_h} \left(\hat{q}_{(h\alpha)} - \hat{q}\right)^2 \\
&= \sum_{h=1}^{4} \frac{1}{2} \sum_{\alpha=1}^{2} \left(\hat{q}_{(h\alpha)} - \hat{q}\right)^2 \\
&= .5 \sum_{k=1}^{8} (\hat{q}_k - \hat{q})^2
\end{aligned}
$$

13

<!-- page 14 -->

# JRR: Estimating the Sampling Variance

$$var_{JRR_{DelOne}}(\hat{q}) = 0.5 \sum_{k=1}^{8} (\hat{q}_k - \hat{q})^2 = .0000801449$$

$$se_{JRR}(\bar{y}^w) = \sqrt{.0000801449} = .008952$$

$$\begin{aligned}
CI(\bar{y}^w) &= .47375 \mp t_{1-\frac{\alpha}{2},4} \cdot .008952 \\
&= .47375 \mp 2.7764 \cdot .008952 \\
&= (.4489, .4986)
\end{aligned}$$

14

<!-- page 15 -->

# Alternative for Replication Variance Estimates

* <u>Stata Code</u>

```stata
svyset [pweight=wgtvar], vce(jackknife) jkrweight(wt*)
svy: mean varname
```

15

<!-- page 16 -->

# Half Sample Replicates

* Assume a paired selection design (2 PSUs per stratum design)
* A half sample is defined by choosing one PSU from each stratum.
* A complement of a half sample is made up of all those PSUs not in the half sample. A complement is also a half sample.
* There are $2^H$ possible half samples and their complements. We only need $H$ half samples for variance estimation. (Why?)

16

<!-- page 17 -->

# Half-Sample Replication

## Consider the following choice of 4 half samples:

| *Halfsample* | Stratum 1 | Stratum 2 | Stratum 3 | Stratum 4 |
| :---: | :---: | :---: | :---: | :---: |
| 1 | + | + | + | - |
| 2 | + | - | - | - |
| 3 | - | - | + | - |
| 4 | - | + | - | - |

+ First element (PSU) is selected
- Second element (PSU) is selected

17

<!-- page 18 -->

# Balanced Repeated Replication (BRR)

* Square arrays of $+$ and $-$ that define **balanced** (orthogonal) half samples are called **Hadamard matrices**. Placket and Burman (Biometrika, 1946) have tabulated these matrices for $H=4,8,12,16,\dots,200$ (all multiples of 4)

* Computer algorithms are available for creating these Hadamard matrices (Stata, WesVar PC), which simplify variance estimation (eliminating covariance terms).

* What if the number of strata is not multiple of 4? In this case only partial balance can be achieved.
  - For $H=3$ drop one column from the matrix for $H=4$. For $H=5$ choose the matrix with $H=8$ and drop 3 strata (columns).

18

<!-- page 19 -->

# BRR: Constructing Replicates, Replicate Weights

* Suppose there are H strata with $a_h$ clusters. H=4, $a_h=2$ in example data set.
* A BRR replicate is constructed by deleting one PSU from each stratum according to the pattern specified in the Hadamard matrix.
  - Example: the first replicate leaves out the $2^{\text{nd}}$ PSU in Strata 1,2,3 and the $1^{\text{st}}$ PSU in Stratum 4.
* The replicate weight for this first replicate multiplies the weights for remaining cases in the half-sample by a factor of 2.

19

<!-- page 20 -->

# BRR Replicate 1: Data Example

| Stratum | PSU (Cluster) | Case | $y_i$ | $w_{i,\text{rep}}$ |
| :---: | :---: | :---: | :---: | :---: |
| **1** | **1** | **1** | **.58** | **1x2** |
| | **1** | **2** | **.48** | **2x2** |
| **1** | **2** | **1** | **.** | **.** |
| | **2** | **2** | **.** | **.** |
| | | | | |
| **2** | **1** | **1** | **.39** | **1x2** |
| | **1** | **2** | **.46** | **2x2** |
| **2** | **2** | **1** | **.** | **.** |
| | **2** | **2** | **.** | **.** |
| | | | | |
| **3** | **1** | **1** | **.39** | **1x2** |
| | **1** | **2** | **.47** | **2x2** |
| **3** | **2** | **1** | **.** | **.** |
| | **2** | **2** | **.** | **.** |
| | | | | |
| **4** | **1** | **1** | **.** | **.** |
| | **1** | **2** | **.** | **.** |
| **4** | **2** | **1** | **.47** | **2x2** |
| | **2** | **2** | **.50** | **2x2** |

20

<!-- page 21 -->

# BRR: Constructing Replicates, Replicate Weights(2)

* Example: the second replicate leaves out the $2^{\text{nd}}$ PSU in Stratum 1 and the $1^{\text{st}}$ PSU in Strata 2,3,4.
* Again, the replicate weight for this second replicate multiplies the weights for remaining cases in the half-sample by a factor of 2 (nonresponse and calibration adjustments could also be applied).
* Four half-sample replicates are created based on the deletion pattern in the Hadamard matrix

21

<!-- page 22 -->

# BRR Replicate 2: Data Example

| Stratum | PSU (Cluster) | Case | $y_i$ | $\text{w}_{i,2,\text{brr}}$ |
| :---: | :---: | :---: | :---: | :---: |
| 1 | 1 | 1 | .58 | 1x2 |
| | 1 | 2 | .48 | 2x2 |
| 1 | 2 | 1 | . | . |
| | 2 | 2 | . | . |
| | | | | |
| 2 | 1 | 1 | . | . |
| | 1 | 2 | . | . |
| 2 | 2 | 1 | .50 | 2x2 |
| | 2 | 2 | .21 | 1x2 |
| | | | | |
| 3 | 1 | 1 | . | . |
| | 1 | 2 | . | . |
| 3 | 2 | 1 | .44 | 1x2 |
| | 2 | 2 | .43 | 1x2 |
| | | | | |
| 4 | 1 | 1 | . | . |
| | 1 | 2 | . | . |
| 4 | 2 | 1 | .47 | 2x2 |
| | 2 | 2 | .50 | 2x2 |

22

<!-- page 23 -->

# BRR: Constructing Estimates

$$
\widehat{q_r} = y_r^w = \frac{\sum_{i \in rep}^{n_{rep}} y_i \cdot w_{i,rep}}{\sum_{i \in rep}^{n_{rep}} w_{i,rep}}
$$

is computed for each of r=1,…,4 replicates

$$
\widehat{q_1} = .4708; \; \widehat{q_2} = .4633; \; \widehat{q_3} = .4614; \; \widehat{q_4} = .4692;
$$

$$
\hat{q} = \frac{\sum_{i=1}^n y_i \cdot w_i}{\sum_{i=1}^n w_i}
$$

the full sample estimate is also computed.

$$
\hat{q} = .4737
$$

23

<!-- page 24 -->

# BRR: Estimating the Sampling Variance

$$\begin{aligned}
\text{var}_{BRR}(\hat{q}) &= \frac{1}{R}\sum_{r=1}^R (\hat{q}_r - \hat{q})^2 \\
&= \frac{1}{4}\sum_{r=1}^4 (\bar{y}_r - \bar{y})^2 \\
&= .00007248
\end{aligned}$$

$$\begin{aligned}
se_{BRR}(\bar{y}) &= \sqrt{.0000748} = .008515 \\
CI(\bar{y}) &= 0.47375 \pm t_{1-\alpha/2, 4} \cdot .008515 \\
&= 0.47375 \pm 2.7764 \cdot (.008515) = (0.45011, 0.49739)
\end{aligned}$$

Recall that JRR resulted in a 95% CI of $(0.4493, 0.4981)$, resulting in extremely similar inferences.

24

<!-- page 25 -->

# Rao-Wu (1988) Rescaling Bootstrap: Variance Estimation

* The variance estimate based on $b=1,\ldots,B$ bootstrap estimates (based on with-replacement samples of the same size) is the Monte Carlo approximation:

$$
\text{var}_{Boot}(\hat{q}) = \frac{1}{B}\sum_{b=1}^{B}(\hat{q}_{(b)} - \hat{q})^2
$$

* For large numbers of bootstrap replicates, i.e. $b\gg 100$, a histogram of the bootstrap simulates the sampling distribution of the estimator
  * May be used to examine asymptotic normality assumption
  * May be used to derive asymmetric CIs for population values

25

<!-- page 26 -->

# Rao-Wu Rescaling Bootstrap: Replicate Formation for Complex Samples

* $\text{b}=1,\dots, \text{B}$ bootstrap replicates formed by sampling with replacement (SWR) $\text{m}_\text{h}$ PSUs from each of the $\text{h}=1,\dots\text{H}$ primary stage strata.

* Recommendation (Rust and Rao, 1996) is to set $m_h=a_h-1$ (one less than the number of sample PSUs in stratum h)

* For $m_h=a_h-1$, the bootstrap weight for the selected replicate is:

$$
w_{h\alpha i}^{(b)} = w_{h\alpha i} \cdot \frac{a_h}{(a_h - 1)} \cdot r_{h\alpha}^{(b)};
$$

$$
\begin{aligned}
where: r_{h\alpha}^{(b)} = \;&\text{the count of time PSU } \alpha \\
&\text{is selected in replicate b.}
\end{aligned}
$$

26

<!-- page 27 -->

# Example Comparison of Standard Error Estimates for Estimates of Population Parameters (source: NCS-R).

| Statistic / Method | | Estimate | Standard Error |
| :--- | :---: | :---: | :---: |
| ***Major depression*** | TSL | 19.1711% | 0.4877% |
| (Prevalence) | JRR | 19.1711% | 0.4878% |
| | BRR | 19.1711% | 0.4896% |
| | | | |
| ***Alcohol Dependence*** | TSL | 5.4065% | 0.3248% |
| (Prevalence) | JRR | 5.4065% | 0.3248% |
| | BRR | 5.4065% | 0.3251% |
| | | | |
| ***Household Income*** | TSL | \$59,277.06 | \$1596.34 |
| (Mean) | JRR | \$59,277.06 | \$1596.65 |
| | BRR | \$59,277.06 | \$1595.37 |

27

<!-- page 28 -->

# Empirical Comparison of Methods

* Data Set: Health and Retirement Study: HRS Wave 1 (1992)
* Software/Variance estimation methods
  - SRS
  - WesVar BRR and JRR with Replicate Weighting for Nonresponse and Poststratification
  - SAS TSL, BRR, JRR using only full sample weight and program creation of replicates
  - R System: Rao, Wu (1988, 1992) Bootstrap with full sample weight (NR and PS adjustments not redone for each Bootstrap replicate)

28

<!-- page 29 -->

# Comparison of Variance Estimation Methods: HRS (1992) Means, Full Adult Sample

| Variable | n | Mean (Wgt) | SRS (SE) | W-BRR (SE) | W-JKK (SE) | S-TSL (SE) | S-BRR (SE) | S-JKK (SE) | R-BS (SE) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Years of School** | **9759** | **12.31** | **0.031** | **0.078** | **0.077** | **0.077** | **0.077** | **0.077** | **0.076** |
| **Body Weight (lbs)** | **9759** | **172.35** | **0.374** | **0.447** | **0.432** | **0.435** | **0.434** | **0.435** | **0.404** |
| **Memory Recall (Words in Test 10)** | **9085** | **7.57** | **0.028** | **0.064** | **0.064** | **0.066** | **0.066** | **0.066** | **0.067** |

29

<!-- page 30 -->

# Comparison of Variance Estimation Methods: HRS (1992) Linear Regression, Words Recalled.

| Coefficients | Coef Est (Wgt) | SRS (SE) | W-BRR (SE) | W-JKK (SE) | S-TSL (SE) | S-BRR (SE) | S-JKK (SE) | R-BS (SE) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **INTERCEPT** | **4.88** | **0.120** | **0.170** | **0.170** | **0.166** | **0.170** | **0.166** | **0.178** |
| **Male** | **-0.93** | **0.052** | **0.063** | **0.065** | **0.064** | **0.064** | **0.064** | **0.061** |
| **Black** | **-1.24** | **0.084** | **0.089** | **0.091** | **0.093** | **0.094** | **0.093** | **0.096** |
| **Hispanic** | **-0.51** | **0.107** | **0.140** | **0.143** | **0.141** | **0.141** | **0.141** | **0.139** |
| **SCHLYRS** | **0.27** | **0.009** | **0.011** | **0.012** | **0.011** | **0.011** | **0.011** | **0.012** |

30
