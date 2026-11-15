---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_6"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_6.pdf"
pages: 26
sha256: "8cfc91c285778fc8dfe37296815069535a70f89e766604be1e5228b59acad984"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:50"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

SURV/SURVMETH 701

Lecture Notes: Module 6

## Percentiles, Subpopulation Analysis, and Functions of Estimates

Instructor: Yan Li

e-mail: [email]

<!-- page 2 -->

# Estimation of Percentiles

* Analysts are often interested in estimating more than just the mean to describe the distribution of a variable in a population
* Example: $95^{\text{th}}$ percentile of PSA levels in a national sample of men over age 40
* Example: Median total assets (a very skewed variable) for rural homes
* Example: Quartiles of systolic blood pressure for African-American females

2

<!-- page 3 -->

# The Ungrouped Estimation Method

* First, Define the population CDF for a variable:
$$F(x) = \frac{\sum_{i=1}^{N} I(y_i \le x)}{N}$$

* A weighted estimator of this CDF can be written as follows:
$$\widehat{F}(x) = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i} I(y_{h\alpha i} \le x)}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i}}$$

3

<!-- page 4 -->

# The Ungrouped Estimation Method

- The $q$-th quantile for a variable $y$ is the smallest value of the variable such that the estimated CDF is greater than or equal to $q$ ($q = 0.25, 0.5, 0.75$, etc.)
- First order sample values from smallest to largest, $x_{(1)}, \dots, x_{(n)}$, and then find the value of $j$ such that

$$\hat{F}(x_j) \le q < \hat{F}(x_{j+1}).$$

4

<!-- page 5 -->

# The Ungrouped Estimation Method

- Then, a weighted estimate of the $q$-th population quantile, $X_q$, is computed as follows:

$$
\hat{X}_q = x_j + \frac{q - \hat{F}(x_j)}{\hat{F}(x_{j+1}) - \hat{F}(x_j)} (x_{j+1} - x_j)
$$

- Taylor Series Linearization (Binder, 1991) approaches can be used to estimate the variance of this estimate, but BRR approaches are recommended (Kovar, Rao, and Wu, 1988)

5

<!-- page 6 -->

# Software for Design-based Estimation of Percentiles

* SUDAAN: Taylor Series Linearization (TSL)
* WesVar: Balanced Repeated Replication (recommended)
* SAS: Woodruff’s Method (uses TSL)
* Procedures enabling appropriate computation of standard errors and confidence intervals (using BRR) are not readily implemented in the current versions of Stata and SPSS
* Stata users can install the user-written *epctile* command (`findit epctile, net install epctile.pkg`)

6

<!-- page 7 -->

# Estimation of Percentiles: Total Household Wealth (2012 HRS)

| | SAS(TSL) | | SAS(BRR) | | Stata(TSL) | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Percentile | $\hat{Q}_p$ | $se(\hat{Q}_p)$ | $\hat{Q}_p$ | $se(\hat{Q}_p)$ | $\hat{Q}_p$ | $se(\hat{Q}_p)$ |
| $Q_{25}$ | \$21,953 | \$2,215 | \$21,953 | \$2,287 | \$22,000 | \$2,200 |
| $Q_{50}$<br>(Median) | \$141,907 | \$7,754 | \$141,907 | \$7,761 | \$142,000 | \$8,000 |
| $Q_{75}$ | \$439,965 | \$18,652 | \$439,965 | \$19,940 | \$440,000 | \$18,869 |

Stata code:
```stata
svyset secu [pweight = nwgthh], strata(stratum)
epctile H11ATOTA, percentiles(25 50 75) subpop(if nfinr==1) svy
```

7

<!-- page 8 -->

# Subpopulation Analysis

* Examples of Subpopulations:
  - Men, women
  - Age groups
  - Disease groups (asthma sufferers)
  - Voters
  - Home Owners
  - Persons with income >\$20,000

8

<!-- page 9 -->

# “Unconditional” vs. “Conditional” Analysis

* Cochran (1977), West et al. (2008) – “Conditional” analysis “conditions” on observed subpopulation sizes as though they were fixed. Results from using “if”, “by”, or “where” statements when analyzing the data.

* Conditional analysis is OK for simple random samples…

* …but not necessarily for stratified samples:
  – Distribution of subpopulation cases, $m(h)$, to strata $h=1,\dots H$ is a **random variable**. *Rarely* fixed.
  – Correct if the subpopulation of interest is used to define explicit strata, e.g., Census Region in a multi-stage national sample of U.S. households, or gender in a stratified (by sex) sample of men and women in a University student body.

9

<!-- page 10 -->

# “Unconditional” vs. “Conditional” Analysis

* “Unconditional” analysis treats stratum subpopulation sizes as a random variable, $m(h), h=1,\dots,H$
  * Variability of subpopulation across strata and to clusters within strata (including $m(hi)=0$) must be reflected in the variance estimation.
* Stata subpop() and SAS DOMAIN keywords/options ensure that this variability is reflected in standard errors of estimates.

10

<!-- page 11 -->

# “Unconditional” vs. “Conditional” Analysis

* Incorrect conditional analyses can also result in the case where only one sampling error computation unit (SECU) is detected within a stratum by the software, preventing appropriate variance estimation!
* Sampling error calculation models based on combining strata attempt to prevent this from happening…
* …but caution is still needed. When in doubt, use the unconditional approach!

11

<!-- page 12 -->

# Unconditional Analyses in Stata

* over(*varname*) option for command
  * *varname* is a categorical variable
  * Analyses (correct) will be replicated for each level of the categorical *varname*
* subpop(*varname*) for command
  * *varname* is a user-generated 0,1 variable where 1 indicates membership in subclass
  * applies to all svy procedures

12

<!-- page 13 -->

# Unconditional Analyses in Stata

* The Stata subpop( ) feature always produces the correct result.

* Stata examines the design distribution (by strata and clusters) of the subpopulation. If a stratum contains 0 cases, that stratum and its clusters do not contribute to degrees of freedom, i.e., $\text{DF} = \text{\# clusters} - \text{\# of strata}$.

13

<!-- page 14 -->

# Functions of Estimates: Stata svy: mean
# Mean Household Assets by Education (2012 HRS)

* gen finr = 1
* replace finr = 0 if kfinr != 1
* svyset secu [pweight = nwgthh], strata(stratum)
* svy, subpop(finr): mean h11atota, over(edcat)

| Education of Head | Stata Label | $\bar{y}_w$ | $se(\bar{y}_w)$ | $CI_{.95}(\bar{y}_w)$ |
| :---: | :---: | :---: | :---: | :---: |
| 0-11 yrs | 1 | \$122,089 | \$10,595 | (\$100,863 , \$143,314) |
| 12 yrs | 2 | \$259,027 | \$9,802 | (\$239,390, \$278,664) |
| 13-15 yrs | 3 | \$336,308 | \$17,201 | (\$301,849, \$370,768) |
| 16+ yrs | 4 | \$834,141 | \$46,478 | (\$741,035, \$927,247) |

14

<!-- page 15 -->

# Sampling Errors for Functions of Estimates: Differences of Subpopulation Means

$$\text{var}(\sum_{j=1}^J a_j \hat{\theta}_j) = \sum_{j=1}^J a_j^2 \text{var}(\hat{\theta}_j) + 2 \cdot \sum_{j=1}^{J-1} \sum_{k>j}^K a_j a_k \cdot \text{cov}(\hat{\theta}_j, \hat{\theta}_k)$$

*where* : $a_j, a_k$ are any chosen constants.

Example:

$$\text{var}(\bar{\text{y}}_{\text{sub1}} - \bar{\text{y}}_{\text{sub2}}) = \text{var}(\bar{\text{y}}_{\text{sub1}}) + \text{var}(\bar{\text{y}}_{\text{sub2}}) - 2\text{cov}(\bar{\text{y}}_{\text{sub1}}, \bar{\text{y}}_{\text{sub2}})$$

*where* : $\bar{\text{y}}_{\text{sub1}}, \bar{\text{y}}_{\text{sub2}}$ are estimates of the mean of y for two subclasses.

15

<!-- page 16 -->

# Sampling Errors for Functions of Estimates: Complex Sample Designs

* Sampling errors for statistics that are functions of survey estimates require computations of variances and covariances of estimates. These should be stored by the software in a variance/covariance matrix.

* In complex sample designs, the covariance terms for subpopulation estimates are often positive due to the clustering (non-independence) in the design.

* This is true even when the subpopulations are distinct (male and female). The covariance will be zero if the subpopulations are defined by distinct design strata (e.g., Northeast vs. South Region).

16

<!-- page 17 -->

# Stata Example: Compute Subpopulation Means

. svy, vce(linearized): mean numadl, over(arthrtis)

```
1: arthrtis = 1
2: arthrtis = 2
------------------------------------------------------------
                    Mean  Std. Err.     [95% Conf. Interval]
------------------------------------------------------------
numadl       |
           1 |  .9487063   .0356663    .8780096    1.019403
           2 |  .3940189   .0279537    .3386098     .449428
------------------------------------------------------------
```

17

<!-- page 18 -->

# Stata Example (2): Compute the standard error for the difference of the subpopulation means.

. lincom [numadl]1-[numadl]2

```
 ( 1)  [numadl]1 - [numadl]2 = 0

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         (1) |   .5546874   .0408345    13.58   0.000     .4737463    .6356285
------------------------------------------------------------------------------
```

Note: Difference in two estimates from previous slide!

18

<!-- page 19 -->

# Stata Example: Display Variance/Covariance Matrix for the Two Subpopulation Means

```
. estat vce

Covariance matrix of coefficients of mean model

             |         numadl
        e(V) |        1         2
-------------+------------------------
numadl       |
           1 | .00127208
           2 | .00019302  .00078141
```

19

<!-- page 20 -->

# Difference of Means: Stata lincom post-estimation Total Assets by Education Level of Head: 2012 HRS

*Command immediately following svy: mean command from Slide 15:*

`lincom [h11atota]1 - [h11atota]4`

| Education of Head | $\bar{y}_{0-11} - \bar{y}_{16+}$ | $se(\bar{y}_{0-11} - \bar{y}_{16+})$ | $CI_{.95}(\bar{y}_{0-11} - \bar{y}_{16+})$ |
| :---: | :---: | :---: | :---: |
| 0-11 vs. 16+ | -\$712,052 | \$48,886 | (-\$809,983, -\$614,122) |

Note: Difference in two estimates from Slide 15.

20

<!-- page 21 -->

# Stata Example: Display Variance-Covariance Matrix for the Subpopulation Means

. estat vce

Covariance matrix of coefficients of mean model

| Subpopulation | 1 | 2 | 3 | 4 |
| :---: | :---: | :---: | :---: | :---: |
| 1 | $1.123 \times 10^8$ | $0.257 \times 10^8$ | $0.564 \times 10^8$ | $-0.587 \times 10^8$ |
| 2 | | $0.961 \times 10^8$ | $0.640 \times 10^8$ | $0.194 \times 10^8$ |
| 3 | | | $2.959 \times 10^8$ | $1.572 \times 10^8$ |
| 4 | | | | $2.160 \times 10^{10}$ |

21

<!-- page 22 -->

# Difference of Means: Hand Computation Total Assets by Education Level of Head: 2012 HRS

$$
\begin{aligned}
se(\bar{y}_{0-11} - \bar{y}_{16+}) &= \sqrt{var(\bar{y}_{0-11}) + var(\bar{y}_{16+}) - 2 \times cov(\bar{y}_{0-11}, \bar{y}_{16+})} \\
&= \sqrt{[1.123 + 21.600 - 2 \times (-0.587)] \times 10^8} \\
&= \$48,886
\end{aligned}
$$

22

<!-- page 23 -->

## Example: Estimating a Difference of Means over Time
## Total Assets: HRS 2004 vs. 2006

```stata
gen weight = jwgthh
replace weight = kwgthh if year == 2006
gen finr04 = 1 if (year==2004 & jfinr==1)
gen finr06 = 1 if (year==2006 & kfinr==1)
gen finr0406 = 1 if finr04==1 | finr06==1
svyset secu [pweight = weight], strata(stratum)
svy, subpop(finr0406): mean totassets, over(year)
lincom [totassets]2004 - [totassets]2006
```

| Contrast | $\bar{y}_{2004} - \bar{y}_{2006}$ | $se(\bar{y}_{2004} - \bar{y}_{2006})$ | $CI_{.95}(\bar{y}_{2004} - \bar{y}_{2006})$ |
| :---: | :---: | :---: | :---: |
| 2004 vs. 2006 | -\$115,526 | \$20,025 | (-\$155,642, -\$75,411) |

23

<!-- page 24 -->

# Example: SAS Difference in Means using PROC SURVEYMEANS and PROC SURVEYREG

* Use of PROC SURVEYMEANS to calculate means/se

* Subsequent use of PROC SURVEYREG with a LSMEANS / diff statement for test if means are significantly different

24

<!-- page 25 -->

# PROC SURVEYMEANS Output

**proc surveymeans data=one;**
strata sestrat ; cluster seclustr ;
weight ncsrwtlg ;
var bmi ;
domain ed4cat;
**run ;**

**The SURVEYMEANS Procedure**

| Data Summary | |
| :--- | ---: |
| **Number of Strata** | 42 |
| **Number of Clusters** | 84 |
| **Number of Observations** | 9282 |
| **Number of Observations Used** | 5692 |
| **Number of Obs with Nonpositive Weights** | 3590 |
| **Sum of Weights** | 5692.00048 |

| | | | | | | |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: |
| **Statistics** | | | | | | |
| **Variable** | **Label** | **N** | **Mean** | **Std Error of Mean** | **95% CL for Mean** | |
| **bmi** | Body Mass Index | 5099 | 27.160539 | 0.129700 | 26.8987936 | 27.4222842 |

| | | | | | | | |
| ---: | :--- | :--- | ---: | ---: | ---: | ---: | ---: |
| **Domain Analysis: 1=0-11 Years 2=12 Years 3=13-15 Years 4=16+ Years** | | | | | | | |
| **1=0-11 Years 2=12 Years 3=13-15 Years 4=16+ Years** | **Variable** | **Label** | **N** | **Mean** | **Std Error of Mean** | **95% CL for Mean** | |
| 1 | **bmi** | Body Mass Index | 767 | 27.371506 | 0.309041 | 26.7478353 | 27.9951760 |
| 2 | **bmi** | Body Mass Index | 1521 | 27.705417 | 0.182695 | 27.3367223 | 28.0741111 |
| 3 | **bmi** | Body Mass Index | 1528 | 27.161737 | 0.228553 | 26.7004982 | 27.6229761 |
| 4 | **bmi** | Body Mass Index | 1283 | 26.265901 | 0.169481 | 25.9238745 | 26.6079268 |

25

<!-- page 26 -->

# PROC SURVEYREG Output

**proc surveyreg data=one;**
strata sestrat ; cluster seclustr ;
weight ncsrwtlg ;
class ed4cat ;
model bmi=ed4cat / solution ;
lsmeans ed4cat / diff;
**run ;**

| ED4CAT Least Squares Means | | | | | |
| :--- | ---: | ---: | ---: | ---: | ---: |
| **1=0-11 Years 2=12 Years 3=13-15 Years 4=16+ Years** | **Estimate** | **Standard Error** | **DF** | **t Value** | **Pr > \|t\|** |
| 1 | 27.3715 | 0.3091 | 42 | 88.54 | <.0001 |
| 2 | 27.7054 | 0.1827 | 42 | 151.60 | <.0001 |
| 3 | 27.1617 | 0.2286 | 42 | 118.81 | <.0001 |
| 4 | 26.2659 | 0.1695 | 42 | 154.93 | <.0001 |

| Differences of ED4CAT Least Squares Means | | | | | | |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: |
| **1=0-11 Years 2=12 Years 3=13-15 Years 4=16+ Years** | **1=0-11 Years 2=12 Years 3=13-15 Years 4=16+ Years** | **Estimate** | **Standard Error** | **DF** | **t Value** | **Pr > \|t\|** |
| 1 | 2 | -0.3339 | 0.3368 | 42 | -0.99 | 0.3272 |
| 1 | 3 | 0.2098 | 0.3235 | 42 | 0.65 | 0.5202 |
| 1 | 4 | 1.1056 | 0.3221 | 42 | 3.43 | 0.0014 |
| 2 | 3 | 0.5437 | 0.3186 | 42 | 1.71 | 0.0953 |
| 2 | 4 | 1.4395 | 0.2427 | 42 | 5.93 | <.0001 |
| 3 | 4 | 0.8958 | 0.2717 | 42 | 3.30 | 0.0020 |

26
