---
id: "jpsm/complex_sample_data_SURV701/labs/Module_6_SAS_supplement"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lab"
title: "Module #6: Domain Estimation"
original: "complex_sample_data_SURV701/labs/Module_6_SAS_supplement.pdf"
pages: 34
sha256: "738cef2d4ab5af6b571e34df904f0be34c722c4e1568fc7943a9027a36ef9ffd"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:48"
---

<!-- page 1 -->

# Module #6: Domain Estimation

Most of the examples presented in previous modules involved estimating parameters at the population level (e.g., ratio of electricity consumption to square footage for all buildings in the CBECS target population), but sometimes we want to estimate those parameters at a sub-population level (e.g., same ratio, but by region of country). Formulating point estimates for sub-populations is called *domain estimation*, and is the topic of this module.

Despite sounding like a straightforward task, intuition leads the naïve researcher to subset the data set for cases in the given domain. We will see why that practice is risky and introduce the DOMAIN statement, available in most SURVEY procedures, which is the tool researchers should use.

STAT674 – GMU – Lewis

1

<!-- page 2 -->

# Example: Mathematics Aptitude Survey

To facilitate exposition of domain estimation concepts, consider a hypothetical mathematics aptitude survey of students from a particular high school.

Suppose the high school consists of four classes—grades 9 through 12—and that the students within each class are assigned to one of 10 homerooms, not necessarily of equal size.

The objective is to select a sample of students to administer a mathematics examination at the start and end of school year. Supplemental information on these students will also be collected, such as whether or not they received any kind of mathematics tutoring.

STAT674 – GMU – Lewis

2

<!-- page 3 -->

# Example: Mathematics Aptitude Survey (2)

Suppose class standing was used as the stratification factor. To facilitate data collection, a sample of two homerooms was selected within each class and, ultimately, two students were selected within each sampled homeroom. Hence, a total of 16 students from the high school were sampled.

**Homeroom**

| **Class** | | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| | 9 | | | | | | | | | | |
| | 10 | | | | | | | | | | |
| | 11 | | | | | | | | | | |
| | 12 | | | | | | | | | | |

---
STAT674 – GMU – Lewis 3

<!-- page 4 -->

# Domain Estimation Strategies

While the overall school-level assessment is surely an objective, so might be estimation at the grade level, by class standing, or by gender.

Subsetting the data, either in a prior DATA step or via a BY or WHERE statement is risky. It won’t affect point estimates but, depending on the type of domain, it could produce erroneous measures of uncertainty. For example, SAS issues the following warning when it detects a WHERE statement in a SURVEY procedure:

```
NOTE: The input data set is subset by WHERE, OBS, or FIRSTOBS. This provides a
completely separate analysis of the subset. It does not provide a statistically
valid subpopulation or domain analysis, where the total number of units in the
subpopulation is not known with certainty. If you want a domain analysis, you
should include the domain variables in a DOMAIN statement.
```

In general, it is only permissible to subset the data is if the domain constitutes a *proper subset*, meaning all (primary) sampling units from one or more strata. But, putting the domain-defining variables in the DOMAIN statement will always produce correct results, so it is best practice to do so.

STAT674 – GMU – Lewis

4

<!-- page 5 -->

# Example Domains

Two Proper Subsets:
1. Tenth grade only
2. Underclassmen only

General Domain:
* Males only

STAT674 – GMU – Lewis

5

<!-- page 6 -->

# Mathematics Aptitude Survey Data Set

```sas
data test;
  input class class_type $ homeroom grade1 tutor $ grade2 weight;
datalines;
12 upper 1 87 Y 94 49.5
12 upper 1 89 N 89 49.5
12 upper 2 91 Y 94 48
12 upper 2 84 Y 92 48
11 upper 1 82 N 84 47.5
11 upper 1 94 N 95 47.5
11 upper 2 93 N 95 48
11 upper 2 94 Y 97 48
10 under 1 78 N 81 39
10 under 1 84 N 84 39
10 under 2 90 N 87 37.5
10 under 2 82 N 85 37.5
 9 under 1 88 N 88 40
 9 under 1 93 Y 91 40
 9 under 2 77 Y 85 48
 9 under 2 81 N 84 48
;
run;
```

STAT674 – GMU – Lewis 6

<!-- page 7 -->

# Analyzing Proper Subsets: Subsetting

```sas
*** Program 8.1;
* analyzing proper subsets with the BY statement';
proc sort data=test;
  by class_type;
run;

proc surveymeans data=test mean stderr;
  by class_type;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight;
run;
```

------------ class_type=under ------------

**The SURVEYMEANS Procedure**

**Data Summary**

| | |
| :--- | ---: |
| Number of Strata | 2 |
| Number of Clusters | 4 |
| Number of Observations | 8 |
| Sum of Weights | 329 |

**Statistics**

| Variable | Mean | Std Error of Mean |
| :--- | ---: | ---: |
| grade2 | 85.583587 | 1.513723 |

------------ class_type=upper ------------

**The SURVEYMEANS Procedure**

**Data Summary**

| | |
| :--- | ---: |
| Number of Strata | 2 |
| Number of Clusters | 4 |
| Number of Observations | 8 |
| Sum of Weights | 386 |

**Statistics**

| Variable | Mean | Std Error of Mean |
| :--- | ---: | ---: |
| grade2 | 92.500000 | 1.653268 |

---
STAT674 – GMU – Lewis  7

<!-- page 8 -->

# Analyzing Proper Subsets: DOMAIN Statement

Notice how putting CLASS_TYPE in DOMAIN statement produces same results:

```sas
* analyzing proper subsets with the DOMAIN statement;
proc surveymeans data=test mean stderr;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight;
domain class_type;
run;
```

**Domain Statistics in class_type**

| class_type | Variable | Mean | Std Error of Mean |
| :--- | :--- | :--- | :--- |
| **under** | **grade2** | **85.583587** | **1.513723** |
| **upper** | **grade2** | **92.500000** | **1.653268** |

---

STAT674 – GMU – Lewis 8

<!-- page 9 -->

# Non-Proper Subset Example

Now consider what happens for the Y/N variable TUTOR, an indicator for whether the student has had any formal mathematics tutoring during the school year:

```sas
*** Program 8.2;
proc surveymeans data=test mean stderr;
  where tutor='Y';
  stratum class;
  cluster homeroom;
  var grade2;
weight weight;
run;
```

```sas
proc surveymeans data=test mean stderr;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight;
domain tutor;
run;
```

**Statistics**

| Variable | Mean | Std Error of Mean |
| :--- | ---: | ---: |
| **grade2** | **92.209591** | **1.058435** |

**Domain Statistics in tutor**

| tutor | Variable | Mean | Std Error of Mean |
| :--- | :--- | ---: | ---: |
| **N** | **grade2** | **87.439446** | **0.881354** |
| **Y** | **grade2** | **92.209591** | **1.336977** |

Same point estimate, but standard error is lower when subsetting. Notice the warning message sent to log:

```
NOTE: Only one cluster in a stratum for variable(s) grade2. The estimate of
variance for grade2 will omit this stratum.
```

STAT674 – GMU – Lewis

9

<!-- page 10 -->

# Underlying Theoretical Issues

General process for estimating the variance of a stratified point estimate involves summing stratum-specific variances, all of which are positive (unless it happens to be 0). So, omitting them could lead to a downwardly biased overall variance estimate.

Behind the scenes, SAS creates a 0/1 indicator variable $d_{hij}$ if the sampling unit falls in the $d^{\text{th}}$ domain, and uses it as a multiplicative factor on the weight $w_{hij}$. For example, a domain mean is calculated by finding:

$$
\hat{\bar{y}}_d = \frac{\hat{Y}_d}{\hat{N}_d} = \frac{\sum_{h=1}^H \sum_{i=1}^{n_h} \sum_{j=1}^{m_{hi}} w_{hij} d_{hij} y_{hij}}{\sum_{h=1}^H \sum_{i=1}^{n_h} \sum_{j=1}^{m_{hi}} w_{hij} d_{hij}}
$$

---
STAT674 – GMU – Lewis 10

<!-- page 11 -->

# Underlying Theoretical Issues (2)

To obtain a variance estimate for the domain mean at bottom of previous slide, principles of Taylor series linearization can be used:

$$
\text{var}\left(\frac{\hat{Y}_d}{\hat{N}_d}\right) \approx \frac{1}{\hat{N}_d^2}\left[\text{var}(\hat{Y}_d) + \left(\frac{\hat{Y}_d}{\hat{N}_d}\right)^2\text{var}(\hat{N}_d) - 2\left(\frac{\hat{Y}_d}{\hat{N}_d}\right)\text{cov}(\hat{Y}_d, \hat{N}_d)\right]
$$

where, for example (ignoring the FPC terms)

$$
\text{var}(\hat{Y}_d) = \sum_{h=1}^{H} \frac{n_h}{(n_h - 1)} \sum_{i=1}^{n_h} \left( \sum_{j=1}^{m_{hi}} w_{hij}d_{hij}y_{hij} - \frac{\sum_{i=1}^{n_h} \sum_{j=1}^{m_{hi}} w_{hij}d_{hij}y_{hij}}{n_h} \right)^2
$$

and

$$
\text{cov}(\hat{Y}_d, \hat{N}_d) = \sum_{h=1}^{H} \frac{n_h}{(n_h - 1)} \sum_{i=1}^{n_h} \left( \sum_{j=1}^{m_{hi}} w_{hij}d_{hij}y_{hij} - \frac{\sum_{i=1}^{n_h} \sum_{j=1}^{m_{hi}} w_{hij}d_{hij}y_{hij}}{n_h} \right) \left( \sum_{j=1}^{m_{hi}} w_{hij}d_{hij} - \frac{\sum_{i=1}^{n_h} \sum_{j=1}^{m_{hi}} w_{hij}d_{hij}}{n_h} \right)
$$

STAT674 – GMU – Lewis

11

<!-- page 12 -->

# Underlying Theoretical Issues (3)

Scrutinizing the formulas on the previous slide, we can extract even more theoretical support for the risks associated with subsetting:

1. If the domain appears in only one PSU within a stratum, the SURVEY procedure sees $n_h = 1$, which introduces a multiplicative factor of zero in the denominators of the variance and covariance equations. Therefore, all three terms are undefined.
2. The stratum-specific contribution to the overall variance estimate of the domain statistic is likely non-zero even if the domain is represented by a single PSU in the stratum. Consider a simple example where $n_h = 2$, each with $m_{hi} = 1$, but the domain characteristic is present in only one of the two PSUs. Except in rare circumstances, the squared deviations will be non-zero for *both* PSUs, even the one which does not reside in the domain.
3. Although we omitted them in expressions presented in previous slide, subsetting the data could disturb any FPC terms $(1 - n_h/N_h)$ when they are applicable. As a general rule, FPCs are based on the overall stratum sample size relative to the overall stratum population size, not the domain-specific stratum sample size relative to the domain-specific stratum population size.

---
STAT674 – GMU – Lewis  12

<!-- page 13 -->

# Domain-Specific Weights

Since the terms $w_{hij}$ and $d_{hij}$ are always bundled together as $w_{hij}d_{hij}$, we can interpret this as if a domain-specific weight $w_{dhij} = w_{hij}d_{hij}$ is created for purposes of estimating the $d^{\text{th}}$ domain's statistics and measures of uncertainty, a weight equaling the original weight if the sampling unit is in the domain and zero otherwise. From there, traditional formulas apply.

Therefore, it would seem feasible to create a domain-specific weight in a DATA step and utilize that in the WEIGHT statement of the SURVEY procedure, foregoing the DOMAIN statement. This will not work, however, because any SURVEY procedure eliminates all observations with a weight less than or equal to 0 at the outset.

Graubard and Korn (1996) suggested a general work-around: assign units outside of the domain a weight that is miniscule, yet strictly greater than zero.

---
STAT674 – GMU – Lewis  13

<!-- page 14 -->

# Domain-Specific Weights (2)

Notice how syntax below matches what was produced by the DOMAIN statement:

```sas
*** Program 8.3;
data test_d;
  set test;
weight_d=weight*(tutor='Y') + .000000000001;
run;

proc surveymeans data=test_d mean stderr;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight_d;
run;
```

**Statistics**

| Variable | Mean | Std Error of Mean |
| :--- | :---: | :---: |
| grade2 | 92.209591 | 1.336977 |

---
STAT674 – GMU – Lewis
14

<!-- page 15 -->

# Domain Estimation for Totals

Although exposition here has focused on the mean, the same ideas translate to other population parameters. For example, in Module #2 we estimated the total number of buildings in CBECS 2003 target population that use district steam. Syntax below estimates the totals by region of the country.

```sas
*** Program 8.4;
proc format;
  value YESNO
    1='Yes'
    2='No';
  value REGION
    1='Northeast'
    2='Midwest'
    3='South'
    4='West';
run;

proc surveymeans data=CBECS_2003 nobs sum;
  strata STRATUM8;
  cluster PAIR8;
  class STUSED8;
  var STUSED8;
weight ADJWT8;
domain REGION8;
format STUSED8 YESNO. REGION8 REGION.;
run;
```

STAT674 – GMU – Lewis

15

<!-- page 16 -->

# Domain Estimation for Totals (2)

Overall estimates followed by regional estimates:

### Statistics

| Variable | Level | N | Sum | Std Dev |
| :--- | :--- | ---: | ---: | ---: |
| STUSED8 | Yes | 265 | 47106 | 7602.878471 |
| | No | 4950 | 4811644 | 239130 |

---

### The SURVEYMEANS Procedure
### Domain Statistics in REGION8

| REGION8 | Variable | Level | N | Sum | Std Dev |
| :--- | :--- | :--- | ---: | ---: | ---: |
| Northeast | STUSED8 | Yes | 82 | 14439 | 3441.342497 |
| | | No | 810 | 746707 | 85320 |
| Midwest | STUSED8 | Yes | 59 | 8286.370000 | 3108.224143 |
| | | No | 1322 | 1296453 | 131788 |
| South | STUSED8 | Yes | 82 | 14030 | 4537.608964 |
| | | No | 1887 | 1859165 | 172366 |
| West | STUSED8 | Yes | 42 | 10351 | 4322.839074 |
| | | No | 931 | 909319 | 74058 |

STAT674 – GMU – Lewis

16

<!-- page 17 -->

# Domain Estimation for Totals (3)

Technically, PROC SURVEYFREQ has no DOMAIN statement, but the TABLES statement serves the same purpose.

```sas
proc surveyfreq data=CBECS_2003;
  strata STRATUM8;
  cluster PAIR8;
  tables REGION8*STUSED8 /
         nopercent;
weight ADJWT8;
format STUSED8 YESNO.
       REGION8 REGION.;
run;
```

**Table of REGION8 by STUSED8**

| REGION8 | STUSED8 | Frequency | Weighted Frequency | Std Dev of Wgt Freq |
| :--- | :--- | ---: | ---: | ---: |
| **Northeast** | **Yes** | 82 | 14439 | 3441 |
| | **No** | 810 | 746707 | 85320 |
| | **Total** | 892 | 761145 | 86534 |
| **Midwest** | **Yes** | 59 | 8286 | 3108 |
| | **No** | 1322 | 1296453 | 131788 |
| | **Total** | 1381 | 1304739 | 131990 |
| **South** | **Yes** | 82 | 14030 | 4538 |
| | **No** | 1887 | 1859165 | 172366 |
| | **Total** | 1969 | 1873195 | 171492 |
| **West** | **Yes** | 42 | 10351 | 4323 |
| | **No** | 931 | 909319 | 74058 |
| | **Total** | 973 | 919670 | 74197 |
| **Total** | **Yes** | 265 | 47106 | 7603 |
| | **No** | 4950 | 4811644 | 239130 |
| | **Total** | 5215 | 4858750 | 239288 |

STAT674 – GMU – Lewis

17

<!-- page 18 -->

# Domain Estimation for Linear Models

As one more example, recall in Module #4 how we reduced a model of time spent with the physician (TIMEMD) down to one including whether the doctor is the lone physician in the practice (SOLO), the primary reason for the visit (MAJOR), patient age (AGE), and the total number of chronic conditions afflicting the patient (TOTCHRON).

It turns out a small subset of visits on the NAMCS 2010 public-use data set—854 out of 31,229—the physician and patient did not actually see one another. These visits are flagged by the 0/1 indicator variable PHYS, where a 1 signifies the physician met with the patient. For records where PHYS=0, the TIMEMD variable is 0.

Hence, we may wish to refit the model controlling for the domain defined by PHYS=1.

---
STAT674 – GMU – Lewis  
18

<!-- page 19 -->

# Domain Estimation for Linear Models (2)

Below are two equivalent ways to restrict to cases in the desired domain (output suppressed):

```sas
*** Program 8.5;
* using the DOMAIN statement in PROC SURVEYREG;
proc surveyreg data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class SOLO MAJOR;
  model TIMEMD = SOLO MAJOR
                 AGE TOTCHRON / solution;
weight PATWT;
domain PHYS;
run;

* creating and using a domain-specific weight;
data NAMCS_2010_d;
  set NAMCS_2010;
PATWT_d=PHYS*PATWT + .0000000000001;
run;
proc surveyreg data=NAMCS_2010_d;
  strata CSTRATM;
  cluster CPSUM;
  class SOLO MAJOR;
  model TIMEMD = SOLO MAJOR
                 AGE TOTCHRON / solution;
weight PATWT_d;
run;
```

STAT674 – GMU – Lewis

19

<!-- page 20 -->

# Significance Testing of Domain Mean Differences

After obtaining domain point estimates and measures of uncertainty, a commonly ensuing objective is to seek to determine whether the differences observed are statistically significant. This is especially true when the point estimates are means.

That is, we wish to test $H_0 : \bar{y}_1 = \bar{y}_2$ vs. $H_1 : \bar{y}_1 \neq \bar{y}_2$ , which we can do by comparing

$$t = \frac{\hat{\bar{y}}_1 - \hat{\bar{y}}_2}{\text{se}(\hat{\bar{y}}_1 - \hat{\bar{y}}_2)}$$

to the appropriate student $t$ distribution. Note that the standard error of the difference can be expressed as follows:

$$\text{se}(\hat{\bar{y}}_1 - \hat{\bar{y}}_2) = \sqrt{\text{var}(\hat{\bar{y}}_1) + \text{var}(\hat{\bar{y}}_2) - 2\text{cov}(\hat{\bar{y}}_1, \hat{\bar{y}}_2)}$$

---

STAT674 – GMU – Lewis

20

<!-- page 21 -->

# Significance Testing of Domain Means (2)

The complicating factor is the covariance term. If the two domain means are drawn from a disjoint set of PSUs, it's zero and you can get the remaining measures of uncertainty with the DOMAIN statement in PROC SURVEYMEANS.

Any kind of overlap generally results in a non-zero covariance term, which we cannot easily get with PROC SURVEYMEANS. We can, however, with PROC SURVEYREG. (In fact, it can be used in the case of disjoint PSUs as well.)

Why PROC SURVEYREG? If we fit a model with an intercept and a single predictor variable, a dichotomous 0/1 indicator variable distinguishing the two domains, the $t$ test assessing whether the indicator variable's parameter is significantly different from zero is equivalent to the $t$ statistic specified in previous slide.

---

STAT674 – GMU – Lewis

21

<!-- page 22 -->

# Domain Mean Significance Testing with PROC SURVEYREG: Example 1

Disjoint PSUs Example with Mathematics Aptitude Survey Data Set:

```sas
*** Program 8.6;
* testing year-end mean scores for underclassmen vs. upperclassmen;
proc surveyreg data=test;
  stratum class;
  cluster homeroom;
  class class_type;
  model grade2 = class_type / solution vadjust=none;
weight weight;
run;
```

### Estimated Regression Coefficients

| Parameter | Estimate | Standard Error | t Value | Pr > \|t\| |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | 92.5000000 | 1.65326793 | 55.95 | <.0001 |
| class_type under | -6.9164134 | 2.24157393 | -3.09 | 0.0367 |
| class_type upper | 0.0000000 | 0.00000000 | | . |

$$\sqrt{1.5137^2 + 1.6533^2} \approx 2.2416$$

$$=$$

$$t = \frac{\hat{\bar{y}}_{under} - \hat{\bar{y}}_{upper}}{\text{se}(\hat{\bar{y}}_{under} - \hat{\bar{y}}_{upper})} = \frac{-6.9164}{2.2416}$$

---
STAT674 – GMU – Lewis

22

<!-- page 23 -->

# Domain Mean Significance Testing with PROC SURVEYREG: Example 2

Overlapping PSUs Example with Mathematics Aptitude Survey Data Set:

```sas
*** Program 8.6;
* testing year-end mean scores for tutored students vs. non-tutored students;
proc surveyreg data=test;
  stratum class;
  cluster homeroom;
  class tutor;
  model grade2 = tutor / solution vadjust=none;
weight weight;
run;
```

**Estimated Regression Coefficients**

| Parameter | Estimate | Standard Error | t Value | Pr > \|t\| |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | 92.2095915 | 1.33697702 | 68.97 | <.0001 |
| tutor N | -4.7701451 | 1.00169127 | -4.76 | 0.0089 |
| tutor Y | 0.0000000 | 0.00000000 | | . |

$$\sqrt{0.8814^2 + 1.3370^2} = 1.6014 \xrightarrow[\neq]{} t = \frac{\hat{\bar{y}}_{Tutor=N} - \hat{\bar{y}}_{Tutor=Y}}{\text{se}(\hat{\bar{y}}_{Tutor=N} - \hat{\bar{y}}_{Tutor=Y})} = \frac{-4.7701}{1.0017}$$

STAT674 – GMU – Lewis

23

<!-- page 24 -->

# Domain Mean Significance Testing: Repeated Measures

Given that the examinations were administered at the start and end of the school year, we may be interested in estimating the mean change in mathematics aptitude over those two points in time. This introduces two possible causes for a covariance between the two domain means, one attributable to the sample design and another due to repeated measures being taken from the same set of sampled students.

One strategy to avoid explicit calculation of any kind of covariance is to create a new variable $d_{hij} = y_{2hij} - y_{1hij}$, where $y_{2hij}$ is the student’s year-end test score and $y_{1hij}$ is the test score from the beginning of the school year. Using this new variate, we can carry out the following hypothesis tests:

$$H_0 : \bar{d} = \bar{y}_2 - \bar{y}_1 = 0 \qquad H_1 : \bar{d} = \bar{y}_2 - \bar{y}_1 \neq 0$$

Hence, a bivariate estimation problem has been converted into a univariate one, so we can use PROC SURVEYMEANS...

STAT674 – GMU – Lewis 24

<!-- page 25 -->

# Domain Mean Significance Testing: Repeated Measures (2)

```sas
*** Program 8.7;
* difference variable approach;
data test;
  set test;
diff=grade2-grade1;
run;

proc surveymeans data=test mean stderr t;
  stratum class;
  cluster homeroom;
  var diff;
weight weight;
run;
```

### The SURVEYMEANS Procedure

#### Data Summary

| | |
| :--- | ---: |
| **Number of Strata** | **4** |
| **Number of Clusters** | **8** |
| **Number of Observations** | **16** |
| **Sum of Weights** | **715** |

#### Statistics

| Variable | Mean | Std Error of Mean | t Value | Pr > \|t\| |
| :--- | ---: | ---: | ---: | ---: |
| **diff** | **2.548252** | **0.860450** | **2.96** | **0.0415** |

STAT674 – GMU – Lewis

25

<!-- page 26 -->

# Domain Mean Significance Testing: Repeated Measures (3)

Another way of conducting the same $t$ test can be derived from a technique shown in Example 5.13 of Heeringa et al. (2010). The notion is to reorient the data set such that the indicator variable regression approach can be implemented.

First step is to stack the data set with observations from the first domain (i.e., the first time point) on top of observations from the second domain (i.e., the second time point). Then, we assign a domain indicator variable to be 1 for records from the second domain and 0 otherwise, and use this as the lone predictor variable in a linear regression model on the outcome variable, using PROC SURVEYREG to account for the complex survey features.

Note: this strategy could even be used in an SRS setting, you would just want to create and utilize a PSU indicator with unique sampling unit identifiers.

STAT674 – GMU – Lewis 26

<!-- page 27 -->

# Domain Mean Significance Testing: Repeated Measures (4)

```sas
*** Program 8.7;
* data stacking approach;
data test_stacked;
  set test (in=d1 rename=(grade1=grade))
      test (in=d2 rename=(grade2=grade));
domain=d2;
run;

proc surveyreg data=test_stacked;
  stratum class;
  cluster homeroom;
  model grade = domain / vadjust=none;
weight weight;
run;
```

**Estimated Regression Coefficients**

| Parameter | Estimate | Standard Error | t Value | Pr > \|t\| |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | 86.7692308 | 1.72841398 | 50.20 | <.0001 |
| domain | 2.5482517 | 0.86044990 | 2.96 | 0.0415 |

NOTE: The denominator degrees of freedom for the t tests is 4.

---

STAT674 – GMU – Lewis

27

<!-- page 28 -->

# Domain Mean Significance Testing: Comparing More than Two Domains

The techniques just demonstrated would be monotonous in a production environment where a vast number of domain comparisons are desired. Even a single domain variable consisting of $K$ distinct domains would necessitate $K(K - 1)/2$ unique domain mean significance tests, requiring us to code in as many 0/1 indicator variables and as many MODEL statements. In these situations, the LSMEANS statement in PROC SURVEYREG is a handy tool

To motivate one example using the NAMCS, suppose we sought to compare the mean time spent with the physician (TIMEMD) across the $5(5 - 1)/2 = 10$ combinations of primary reason for the visit:

| Variable Name | Description | Coding Structure |
| :--- | :--- | :--- |
| MAJOR | Primary reason for the visit | 1 = New problem ($< 3$ months onset)<br>2 = Chronic problem, routine<br>3 = Chronic problem, flare up<br>4 = Pre-/Post-surgery<br>5 = Preventive care (e.g. routine prenatal, screening) |

STAT674 – GMU – Lewis

28

<!-- page 29 -->

# Domain Mean Significance Testing: Comparing More than Two Domains (2)

```sas
*** Program 8.8;
proc surveyreg data=NAMCS_2010;
  stratum CSTRATM;
  cluster CPSUM;
  class MAJOR;
  model TIMEMD = MAJOR /
          vadjust=none;
weight PATWT;
lsmeans MAJOR / diff;
run;
```

### The SURVEYREG Procedure

#### Regression Analysis for Dependent Variable TIMEMD

##### MAJOR Least Squares Means

| MAJOR | Estimate | Standard Error | DF | t Value | Pr > \|t\| |
|---|---|---|---|---|---|
| 1 | 19.9857 | 0.5793 | 552 | 34.50 | <.0001 |
| 2 | 20.5501 | 0.3991 | 552 | 51.49 | <.0001 |
| 3 | 21.9394 | 0.6398 | 552 | 34.29 | <.0001 |
| 4 | 17.6291 | 0.6836 | 552 | 25.79 | <.0001 |
| 5 | 20.4920 | 0.5478 | 552 | 37.41 | <.0001 |

##### Differences of MAJOR Least Squares Means

| MAJOR | _MAJOR | Estimate | Standard Error | DF | t Value | Pr > \|t\| |
|---|---|---|---|---|---|---|
| 1 | 2 | -0.5645 | 0.6291 | 552 | -0.90 | 0.3700 |
| 1 | 3 | -1.9538 | 0.6706 | 552 | -2.91 | 0.0037 |
| 1 | 4 | 2.3565 | 0.8340 | 552 | 2.83 | 0.0049 |
| 1 | 5 | -0.5064 | 0.5776 | 552 | -0.88 | 0.3810 |
| 2 | 3 | -1.3893 | 0.6548 | 552 | -2.12 | 0.0343 |
| 2 | 4 | 2.9210 | 0.7524 | 552 | 3.88 | 0.0001 |
| 2 | 5 | 0.05808 | 0.6413 | 552 | 0.09 | 0.9279 |
| 3 | 4 | 4.3103 | 0.8340 | 552 | 5.17 | <.0001 |
| 3 | 5 | 1.4474 | 0.7624 | 552 | 1.90 | 0.0582 |
| 4 | 5 | -2.8629 | 0.7798 | 552 | -3.67 | 0.0003 |

STAT674 – GMU – Lewis

29

<!-- page 30 -->

# Domain Mean Significance Testing: Comparing More than Two Domains (3)

A few parting points:

* The analysis could be extended even further by including one or more variables in a DOMAIN statement. For example, if we had specified SEX in the DOMAIN statement, the same analysis would be output, followed by comparable analyses for male and female patients.
* Another potential extension of interest would be to control for one or more covariates by adding them to the MODEL statement. For example, if we added SEX as an independent variable in the MODEL statement, the LSMEANS differences would be interpreted as differences in mean time spent with the physician while simultaneously accounting for patient gender.
* In general, the PROC SURVEYREG approaches translate to dichotomous outcome variables so long as the two categories are coded one unit apart (e.g., via a 0/1 indicator variable). In fact, we can conceive of the risk difference statistic as a domain mean significance test when both the outcome and domain indicator are dichotomous.

---
STAT674 – GMU – Lewis

30

<!-- page 31 -->

# Degrees of Freedom Considerations

Most survey statisticians would agree that the traditional complex survey degrees of freedom rule of thumb—the number of distinct PSUs minus the number of strata—is too large when estimating a quantity for a sparse domain, or one not present in all PSUs and/or strata. The literature is a bit mixed regarding the ideal alternative:

* Heeringa et al. (2010): number of PSUs less the number of strata for strata where the domain appears in a least one PSU.
* Korn and Graubard (1999): the number of unique PSUs containing at least one domain case minus the number of strata in which these PSUs are situated.

Recall that the degrees of freedom will not affect point estimates or their estimated variances, but can impact the $p$ values of hypothesis tests and confidence interval widths.

---

STAT674 – GMU – Lewis

31

<!-- page 32 -->

# Modifying the Degrees of Freedom

By default, the given SURVEY procedure does not modify the degrees of freedom for domain analysis; it sticks with #PSUs - #strata. Per the table below, each SURVEY procedure seems to have a different option or keyword for manually assignment; some offered no option at time book was published, but now do.

| Procedure | Option |
| :--- | :--- |
| PROC SURVEYMEANS | Nothing available at present |
| PROC SURVEYFREQ | DF=*number* option after the slash in the TABLES statement |
| PROC SURVEYREG | DF=*number* option after the slash in the MODEL statement |
| PROC SURVEYLOGISTIC | DF=*number* option after the slash in the MODEL statement |
| PROC SURVEYPHREG | DF=*number* option after the slash in the MODEL statement |

To implement the adjustment advocated by Heeringa et al. (2010) in any SURVEY procedure, you can just subset the complex survey data set to strata containing at least one sampling unit in the domain.

STAT674 – GMU – Lewis

32

<!-- page 33 -->

# Modifying the Degrees of Freedom: Example

Revisiting the domain analysis in the hypothetical mathematics aptitude survey of the mean year-end test score for students who received tutoring, suppose we sought to find the endpoints of a 95% confidence interval. (Neither PSU from tenth grade stratum had tutored students.) Syntax below shows the domain-specific weight approach:

```sas
*** Program 8.10;
proc surveymeans data=test_d mean stderr clm df;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight_d;
run;
```

**Statistics**

| Variable | DF | Mean | Std Error of Mean | 95% CL for Mean |
| :--- | ---: | ---: | ---: | :--- |
| grade2 | 4 | 92.209591 | 1.336977 | 88.4975482 95.9216348 |

---
STAT674 – GMU – Lewis &emsp; 33

<!-- page 34 -->

# Modifying the Degrees of Freedom: Example (2)

Syntax below shows one way to implement the Heeringa et al. (2010) recommended adjustment:

```sas
*** Program 8.10;
* preliminary PROC SQL step subsets the data for strata with at least one
  PSU in the domain defined by TUTOR='Y';
proc sql;
  create table test_d_adj as
  select *
    from test_d
   where class in(select distinct class from test_d where tutor='Y');
quit;

proc surveymeans data=test_d_adj mean stderr clm df;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight_d;
run;
```

**Statistics**

| Variable | DF | Mean | Std Error of Mean | 95% CL for Mean |
| :--- | :---: | :---: | :---: | :---: |
| **grade2** | **3** | **92.209591** | **1.336977** | **87.9547339 96.4644491** |

STAT674 – GMU – Lewis

34
