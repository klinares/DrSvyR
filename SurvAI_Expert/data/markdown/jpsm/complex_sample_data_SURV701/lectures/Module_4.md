---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_4"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_4.pdf"
pages: 32
sha256: "03744952dcfbac6a6edc79d53977a5aa1b513350d9ba2b7a1e7930d5a7190234"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:50"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

SURV/SURVMETH 701

Lecture Notes: Module 4

## Taylor Series Linearization;
## Software for Estimating Sampling Errors of Estimated Descriptive Statistics

Instructor: Yan Li

e-mail: [email]

1

<!-- page 2 -->

# Linear Statistics/Estimators

Definition: The statistic is a linear function (linear combination) of the data.

$$
\theta = \sum_{i=1}^{N} a_i \cdot y_i \text{ ; } \quad \hat{\theta} = \sum_{i=1}^{n} a_i \cdot y_i
$$

*Example 1, Mean :*

$$
\bar{Y} = \sum_{i=1}^{N} \frac{1}{N} \cdot y_i \text{ ; } \quad \bar{y} = \sum_{i=1}^{n} \frac{1}{n} \cdot y_i
$$

*Example 2, Population Total :*

$$
Y = \sum_{i=1}^{N} y_i \text{ ; } \quad \hat{Y} = \sum_{i=1}^{n} \frac{N}{n} \cdot y_i
$$

2

<!-- page 3 -->

* Weighted sample mean is linear or nonlinear?

$$\bar{y}_w = \frac{\sum_h \sum_\alpha \sum_i y_{h\alpha i} w_{h\alpha i}}{\sum_h \sum_\alpha \sum_i w_{h\alpha i}} = \frac{x}{z}$$

$y_{h\alpha i} = \text{Measurement on unit } i \text{ in cluster } \alpha \text{ in stratum } h$

$w_{h\alpha i} = \text{Corresponding weight}$

* Certain other statistics such as regression coefficients and correlation coefficients are nonlinear functions of linear statistics

3

<!-- page 4 -->

Under SRS, SSRS, and equal size (b) cluster sampling

$$z = \sum_{i=1}^n \frac{N}{n} = N \text{ under SRS sampling}$$

$$z = \sum_{h=1}^H \sum_{i=1}^{n_h} \frac{N_h}{n_h} = \sum_h N_h = N \text{ under SSRS sampling}$$

$$z = \sum_{\alpha=1}^a \sum_{i=1}^b w_{\alpha i} = \sum_{\alpha=1}^a \sum_{i=1}^b \frac{A}{a} = \sum_{\alpha=1}^a \frac{Ab}{a} = Ab = N \text{ under equal size (b) cluster sampling}$$

How about unequal size ($b_\alpha$) cluster sampling?

$$z = \sum_{\alpha=1}^a \sum_{i=1}^{b_\alpha} w_{\alpha i} = \sum_{\alpha=1}^a \sum_{i=1}^{b_\alpha} \frac{A}{a} = \frac{A}{a} \sum_{\alpha=1}^a b_\alpha, \text{depending on sizes of selected clusters}$$

4

<!-- page 5 -->

# Approaches to Complex Sample Variance Estimation

* Complicated if the estimate is a ***nonlinear*** function of sample quantities
* Two approaches:
  - Taylor Series Linearization (TSL) technique
    * Approximate nonlinear statistics as a linear function of sample totals
    * Leads to a specific form of the variance estimator for each statistic
  - Replication or Resampling Methods technique
    * Jackknife Repeated Replication (JRR)
    * Balanced Repeated Replication (BRR)
    * Bootstrapping

5

<!-- page 6 -->

# Taylor Series Linearization of a Function: Basic result from calculus

$$
f(x) = function\ (smooth)
$$

$$
f'(x_o)
$$

$$
f(x) \approx f(x_o) + (x - x_o) \left[ \frac{df}{dx} \right]_{x=x_o}
$$

$$
x_o - value\ of\ x\ at\ which\ f(x)\ will\ be\ approximated.
$$

$f(x)$

$x$

6

<!-- page 7 -->

# Taylor Series Linearization: Extension to function of 2 or more variables

$$
f(x, z) \cong f(x_o, z_o) + (x - x_o) \underbrace{\left[ \frac{\partial f}{\partial x} \right]_{x=x_o, z=z_o}}_{A} + (z - z_o) \underbrace{\left[ \frac{\partial f}{\partial z} \right]_{x=x_o, z=z_o}}_{B}
$$

$$
Var\big(f(x, z)\big) \approx A^2 Var(x) + B^2 Var(z) + 2AB Cov(x, z)
$$

$$
f(x, z) = R = \bar{y}_w = \frac{\sum_h \sum_\alpha \sum_i y_{h\alpha i} w_{h\alpha i}}{\sum_h \sum_\alpha \sum_i w_{h\alpha i}} = \frac{x}{z}
$$

$$
A = \frac{\partial f}{\partial x} = \frac{1}{z_o}
$$

$$
B = \frac{\partial f}{\partial z} = - \frac{x_o}{z_o^2}
$$

$$
Var\left( \frac{x}{z} \right) \cong \frac{Var(x) + R^2 \times Var(z) - 2 \times R \times Cov(x, z)}{z_o^2}
$$

$$
R = \frac{x_o}{z_o}
$$

7

<!-- page 8 -->

# Taylor Series Linearization: Notes about computation

* Note that $x_0$ and $z_0$ are expected values, which (for an unbiased estimator) are the fixed population parameters (or population totals)
* Use sample estimates based on unbiased estimators to evaluate $\text{Var}(x)$, $\text{Var}(z)$ or $\text{Cov}(x,z)$
* We know how to compute terms like $var(x)$ and $var(z)$, as these are variances of sample totals

$$
var(f(x, z)) \approx A^2var(x) + B^2var(z) + 2ABcov(x, z)
$$

8

<!-- page 9 -->

# Weighted mean with no clustering and stratification

$$\bar{y}_w = \frac{\sum_i y_i w_i}{\sum_i w_i} = \frac{x}{z}$$

$$x_i = w_i y_i, \quad x = \sum_i x_i$$

$$z_i = w_i, \quad z = \sum_i z_i$$

$$var(x) = n \cdot s_x^2$$

$$var(z) = n \cdot s_z^2$$

$$cov(x, z) = n \cdot s_{xz}$$

$$var(\bar{y}_w) = \frac{1}{z^2} \{n \cdot s_x^2 + \bar{y}_w^2 \cdot n \cdot s_z^2 - 2\bar{y}_w \cdot n \cdot s_{xz}\}$$

9

<!-- page 10 -->

where

$$
s_x^2 = \frac{1}{n-1} \sum_i (x_i - \bar{x})^2
$$

$$
s_z^2 = \frac{1}{n-1} \sum_i (z_i - \bar{z})^2
$$

$$
s_{xz} = \frac{1}{n-1} \sum_i (x_i - \bar{x})(z_i - \bar{z})
$$

Reference: Chapter 6, Survey Sampling by Kish (1965)

10

<!-- page 11 -->

# Simple Example of Weighted Mean and Sampling Variance

| | Weight ($w$) | Response ($Y$) | $\text{x} = w \times Y$ |
| :--- | :---: | :---: | :---: |
| | 2 | 10 | 20 |
| | 3 | 11 | 33 |
| | 1 | 22 | 22 |
| | 2 | 10 | 20 |
| | 1 | 31 | 31 |
| Total | 9 | 84 | 126 |

11

<!-- page 12 -->

$$\bar{y}_w = \frac{\sum_{i=1}^n w_i y_i}{\sum_{i=1}^n w_i} = \frac{20 + 33 + \cdots + 31}{2 + 3 + \cdots + 1} = 14$$

$$s_x^2 = \frac{\sum_{i=1}^n (x_i - \bar{x})^2}{n - 1} = \frac{\sum_{i=1}^n x_i^2 - n\bar{x}^2}{n - 1} = \frac{3334 - 5(25.2)^2}{5 - 1} = 39.7$$

$$s_z^2 = \frac{\sum_{i=1}^n (z_i - \bar{z})^2}{n - 1} = \frac{\sum_{i=1}^n z_i^2 - n\bar{z}^2}{n - 1} = \frac{19 - 5(1.8)^2}{5 - 1} = 0.7$$

$$s_{xz} = \frac{\sum_{i=1}^n (x_i - \bar{x})(z_i - \bar{z})}{n - 1} = \frac{\sum_{i=1}^n x_i z_i - n\bar{x}\bar{z}}{n - 1} = \frac{232 - 5(25.2)(1.8)}{5 - 1} = 1.3$$

$$var(\bar{y}_w) = \frac{1}{z^2}\{n s_x^2 + n \bar{y}_w^2 s_z^2 - 2 n \bar{y}_w s_{xz}\}$$

$$var(\bar{y}_w) = \frac{1}{9^2}\{5 (39.7) + 5(14)^2 .7 - 2(5)(14)(1.3)\} = 8.67$$

95% Confidence interval:

$$14 \pm 2.78 \cdot \sqrt{8.67} = (5.81, 22.19)$$

12

<!-- page 13 -->

# Weighted Mean Example Using SAS

```sas
*SAS Data Set Creation;
data one;
input strata psu wght response;
datalines;
1 1 2 10
1 2 3 11
1 3 1 22
1 4 2 10
1 5 1 31
;
```

13

<!-- page 14 -->

## Weighted Mean Example Using SAS:
## SAS Release 9.3, PROC SURVEYMEANS

```sas
PROC SURVEYMEANS DATA=ONE;
  STRATUM STRATA;
  CLUSTER PSU;
  WEIGHT WGHT;
  VAR RESPONSE;
RUN;
```

14

<!-- page 15 -->

# Weighted Mean Example Using SAS PROC SURVEYMEANS: Results

```
                   The SAS System                        1

                   The SURVEYMEANS Procedure

                         Data Summary

                Number of Strata               1
                Number of Clusters             5
                Number of Observations          5
                Sum of Weights                9


                         Statistics

                                  Std Error
Variable           N        Mean      of Mean     95% CL for Mean
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
response           5     14.000000     2.944969   5.82345660 22.1765434
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
```

15

<!-- page 16 -->

# Taylor Series Linearization Method

Stratified cluster sampling design: <u>2 PSUs per Stratum</u>

$$\bar{y}_w = \frac{\sum_h (x_{h1} + x_{h2})}{\sum_h (z_{h1} + z_{h2})} = \frac{\sum_h (x_h)}{\sum_h (z_h)} = \frac{x}{z}$$

$$\text{Set}: \quad dx_h = x_{h1} - x_{h2} \, , \quad dz_h = z_{h1} - z_{h2}$$

$$\text{var}(\bar{y}_w) = \frac{\sum_h (dx_h)^2 + \bar{y}_w^2 \sum_h (dz_h)^2 - 2\bar{y}_w \sum_h dx_h dz_h}{z^2}$$

16

<!-- page 17 -->

# Taylor Series Linearization Method
## Stratified, cluster sampling: Multiple PSUs per Stratum

$$(dx_h)^2 = \frac{a_h}{a_h - 1} \left[ \sum_{\alpha} x_{h\alpha}^2 - \frac{\left( \sum_{\alpha} x_{h\alpha} \right)^2}{a_h} \right]$$

$$(dz_h)^2 = \frac{a_h}{a_h - 1} \left[ \sum_{\alpha} z_{h\alpha}^2 - \frac{\left( \sum_{\alpha} z_{h\alpha} \right)^2}{a_h} \right]$$

$$dx_h dz_h = \frac{a_h}{a_h - 1} \left[ \sum_{\alpha} x_{h\alpha} z_{h\alpha} - \frac{\left( \sum_{\alpha} x_{h\alpha} \sum_{\alpha} z_{h\alpha} \right)}{a_h} \right]$$

17

<!-- page 18 -->

* Linearization is a widely used technique for estimating variance of any functions of the weighted totals (e.g., ratios, subgroup differences in the ratios, regression coefficients and correlation coefficients).
* Approximation works well if the denominator has less variability. Typically, this procedure is not recommended if the coefficient of variation of the denominator is greater than 0.2 (some would say 0.15). See Kish (1965), Section 6.6.

$$
\begin{aligned}
& cv(z) = se(z) / z = se(\bar{z}) / \bar{z} \\
& = \frac{s_z}{\bar{z}\sqrt{n}} \\
& Example: \\
& = \frac{\sqrt{0.7}}{1.8\sqrt{5}} = 0.2079
\end{aligned}
$$

* SUDAAN, Stata, IVEware %Describe, SAS and other programs use this method of estimation by default.

18

<!-- page 19 -->

# Software Packages with Programs Available for Analysis of Complex Sample Survey Data

**<u>Stata</u>: The “svy” commands**
* svyset: define design variables
* svydes: describe survey design
* svy: mean
* svy: regress
* many additional “svy” commands

**<u>SAS</u>: The “SURVEY” procedures**
* PROC SURVEYMEANS
* PROC SURVEYREG
* PROC SURVEYFREQ
* PROC SURVEYLOGISTIC
* PROC SURVEYPHREG

19

<!-- page 20 -->

# Software Available, cont'd

**<u>IVEware</u>: SAS-based (macros) or stand-alone**
* %DESCRIBE (descriptive statistics)
* %REGRESS (regression modeling)
* %SASMOD (additional SAS procs)

**<u>SUDAAN</u>: SAS-based or stand-alone procedures**
* DESCRIPT
* CROSSTAB
* REGRESS
* LOGISTIC
* many others...for more info, visit
<u>http://www.rti.org/sudaan/</u>

20

<!-- page 21 -->

# Additional Software Packages

* **WesVar PC®**
  - Free stand-alone software developed by WESTAT corporation
  - Visit http://www.westat.com/ for more information
* **IBM SPSS® Statistics: Complex Samples Module**
  - Add-on module, requires SPSS base to run
  - Needs to be purchased separately from SPSS base
  - Visit http://www.spss.com/ for more information

21

<!-- page 22 -->

# Additional Software Packages

- R `survey` Package ([http://cran.r-project.org](http://cran.r-project.org))
  - `survey` package under Packages menu (Windows) or Packages and Data (Mac)
  - `svydesign(arguments)`, `svyrepdesign()` to specify design / weights
  - `svymean( ), svytotal(), svyplot()`
  - `svyratio(), svyglm(), svyolr(), svyloglin(), svycoxph()`
- Others: Mplus (for modeling)

22

<!-- page 23 -->

# Stata Commands for Estimating Descriptive Statistics and their Standard Errors

* **Stata:**
  – svy: mean (continuous / binary variables),
  – svy: prop, svy: tab (categorical variables)
  – Taylor Series Linearization, Jackknife Repeated Replication (JRR), and Balanced Repeated Replication (BRR); replication techniques will be discussed later
  – Capable of utilizing information from all stages of the sample design (first stage information is really all that is necessary for robust variance estimation; this additional capability allows survey sampling statisticians to decompose variances)

23

<!-- page 24 -->

# Descriptive Statistics: Means and Proportions
# Mean total household assets (HRS 2006).

**data hrs;** set s701.hrs_analysis_ex_c1_c9_2011; **run;**

**proc surveymeans data=hrs nobs df mean stderr clm ;**

strata stratum ; cluster secu ; weight kwgthh ;

domain kfinr ; /* want kfinr = 1 for financial reporters of households */

var h8atota ;

**run ;**

**Stata:**

. svyset secu [pweight = kwgthh], strata(stratum)

. svy, subpop(if kfinr == 1): mean h8atota

. estat effects

| n | df | $\overline{y}_w$ | $se(\overline{y}_w)$ | $CI_{.95}(\overline{y}_w)$ | $d^2(\overline{y}_w)$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 11,942 | 56 | \$527,313 | \$28,012 | (\$471,196, \$583,429) | 1.52 |

24

<!-- page 25 -->

# Descriptive Statistics: **Totals**

$$\hat{Y}_w = \sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i} y_{h\alpha i} = \hat{Y}.$$

$$\hat{Y}_w = \sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i} y_{h\alpha i} = \hat{M} \le \sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i} \cdot 1 = \hat{N}$$

for $Y=\{\text{1 if member of subpopulation, 0 otherwise}\}$

25

<!-- page 26 -->

# Descriptive Statistics: Totals (Stata)
## **Total** Persons w/ Lifetime MDE by Marital Status (NCS-R)

```stata
. use “s701/ncsr_analysis_examples_c1_c10_2011.dta“, clear
* Generate population weights, given that weights are scaled to sum to n
. gen popweight = ncsrwtsh * 209128094 / 9282
. svyset seclustr [pweight = popweight], strata(sestrat)
. svy: total mde, over(mar3cat)
. mat list e(b)
. estat effects
```

| Subpop | $n$ | Estimated Total Lifetime MDE | Estimated Standard Error | 95% CI |
| :---: | :---: | :---: | :---: | :---: |
| **Married** | **5322** | **20,304,190** | **1,584,109** | **(17,199,395, 23,408,986)** |
| **Sep./Wid./Div.** | **2017** | **10,360,671** | **702,601** | **(8,983,558, 11,737,783)** |
| **Never Married** | **1943** | **9,427,345** | **773,137** | **(7,912,024, 10,942,667)** |

26

<!-- page 27 -->

# Descriptive Statistics: Totals (SAS V9.2+)
## Total Persons w/ Lifetime MDE by Marital Status (NCS-R)

**data ncsr;**
  set S701_analysis_ex_c1_c10_2011;
  ncsrwtsh_pop = ncsrwtsh \* **209128094 / 9282;**
**run;**

**proc surveymeans data=ncsr nobs sum df stderr clsum ;**
  strata sestrat ;
  cluster seclustr ;
  weight ncsrwtsh_pop ;
  var mde ;
  **domain mar3cat** ;
**run ;**

**(Output not shown here.)**

27

<!-- page 28 -->

# Descriptive Statistics: **Ratios** of Two Variables

$$\hat{R} = \frac{\hat{Y}}{\hat{X}} = \frac{\sum_{h=1}^H \sum_{a=1}^{\alpha_h} \sum_{i=1}^{n_{ha}} w_{hai} y_{hai}}{\sum_{h=1}^H \sum_{a=1}^{\alpha_h} \sum_{i=1}^{n_{ha}} w_{hai} x_{hai}}$$

$$var(\hat{R}) = \frac{var(\hat{Y}) + \hat{R}^2 var(\hat{X}) - 2 \hat{R} cov(\hat{Y}, \hat{X})}{\hat{X}^2}$$

28

<!-- page 29 -->

# Descriptive Statistics: Ratios of Two Variables.
## **Ratio** of HD Chol./Tot Chol. (NHANES)

* gen age18p = 1 if age >= 18 and age != .
* replace age18p = 0 if age < 18
* svyset sdmvpsu [pweight=wtmec2yr], strata(sdmvstra)
* svy, subpop(age18p): ratio (lbdhdd/lbxtc)

| $n$ | $df$ | $\hat{R}$ | $se(\hat{R})$ | $CI_{.95}(\hat{R})$ |
| :---: | :---: | :---: | :---: | :---: |
| 4996 | 15 | 0.275 | 0.002 | (0.271,0.280) |

29

<!-- page 30 -->

# Descriptive Estimation: Don’t Forget Graphics!

* Graphics are a powerful tool in the effect descriptive presentation of survey results

* Important to remember that graphics should reflect survey weighting to provide an unbiased portrayal of population distributions

* Software systems and even programs within single systems may require special procedures to ensure graphics reflect population estimates.

* Stata enables inclusion of survey weights as PWEIGHTS in many graphics programs (same in R).

30

<!-- page 31 -->

# Descriptive Estimation: Histogram
# Total Cholesterol (NHANES)

* generate int_wtmec2yr = int(wtmec2yr)
* histogram lbxtc if age18p [fweight=int_wtmec2yr]

31

<!-- page 32 -->

# Boxplot: Total Cholesterol by Gender (NHANES)

* graph box lbxtc [pweight=wtmec2yr] if age18p==1, by(female)

32
