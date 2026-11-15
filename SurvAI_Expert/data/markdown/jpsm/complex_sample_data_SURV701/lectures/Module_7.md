---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_7"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_7.pdf"
pages: 44
sha256: "aea23ade8ed8a6b882776cd1b2fe0cdd508ef5371e35ccba27768f86b84a4fc5"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:51"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

SURV/SURVMETH 701

Lecture Notes: Module 7

## Analysis Methods for Categorical Data

Instructor: Yan Li

e-mail: [email]

<!-- page 2 -->

# Forms of Categorical Data

* Nominal - Categories are labels, no metric implied (e.g., Gender, Region).
* Ordinal - Categories imply ordered metric. e.g., education, grouped underlying continuous (age brackets).
* Counts – Special case of ordinal. Exact metric, discrete events, occurrences.

2

<!-- page 3 -->

# Nominal Categorical Data: NCS-R
# <u>Weighted</u> Distribution of U.S. Adults by Employment Category

(NLF: not in the labor force)

3

<!-- page 4 -->

# Ordinal Categorical Data:
# HRS 2006. <u>Weighted</u> Distribution.
# Self-rating of Health Status

Proportion
.3
.2
.1
0
Excellent Very Good Good Fair Poor

4

<!-- page 5 -->

# Count Data: HRS 2006
# Falls in the Past 24 Months

5

<!-- page 6 -->

# Categorical Data Analysis

* Univariate Tests (e.g., $\text{H}_\text{o}\text{: } p = p_0$)
* Bivariate and Multi-way Tables (here)
* Loglinear Models (not widely implemented in survey analysis software)
* Logistic Models (later in course)
* Poisson and other GLMs (later in course)

6

<!-- page 7 -->

# Univariate Methods

* Graphical display of data
* Primarily estimation of proportions and functions of proportions
* Ordinal, count – descriptive statistics for continuous variables <u>used with caution</u>
* Estimation of $p$, standard errors, CIs
* Goodness of fit tests

7

<!-- page 8 -->

# <u>Estimated</u> distribution: U.S. Adults by Hypertension Status. Source: NHANES

| Status | Percentage |
| :--- | :--- |
| Normal | 47.1% |
| Pre-Hypertensive | 41.9% |
| Stage 1 Hypertensive | 8.6% |
| Stage 2 Hypertensive | 2.4% |

8

<!-- page 9 -->

# Univariate Analysis

* Estimation of simple proportions:

$$p = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i} I_{i\in 1}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i}} = \frac{\widehat{N}_1}{\widehat{N}} = \frac{y}{x}$$

* Recall that a proportion is simply the mean of $y = \{0,1\}$

9

<!-- page 10 -->

# Univariate Analysis

* TSL variance of simple proportions:

$$v(p) = \frac{V(\widehat{N}_1) + p^2V(\widehat{N}) - 2pCov(\widehat{N}_1, \widehat{N})}{\widehat{N}^2}$$

* Recall: $percent = 100 \ p,$

$$se(percent) = 100 \ se(p),$$

$$\operatorname{var}(percent) = 100^2 \ \operatorname{var}(p)$$

10

<!-- page 11 -->

# Univariate Analysis

* Confidence intervals: asymptotic normal method (assume asymptotic normality of sampling distributions)
  - **Stata:** svy: mean, svy: ratio

$$CI_{.95}(\pi) = p \mp t_{.975,df} \cdot se(p)$$

11

<!-- page 12 -->

# Univariate Analysis

* Confidence intervals: logit transform method
  – **Stata:** svy: tab, svy: prop

$$
CI[logit(\pi)] = \{A, B\} = \left\{ \begin{array}{c} \ln \frac{p}{1 - p} - \frac{t_{1 - \alpha/2, df} \cdot se(p)}{p \cdot (1 - p)} \\ \ln \frac{p}{1 - p} + \frac{t_{1 - \alpha/2, df} \cdot se(p)}{p \cdot (1 - p)} \end{array} \right\}
$$

$$
CI(\pi) = \left\{ \frac{e^A}{1 + e^A}, \frac{e^B}{1 + e^B} \right\}
$$

12

<!-- page 13 -->

# Confidence Intervals for Proportions: Proportion 18+ with Irregular Heartbeat [NHANES (2011-12) – Recode not shown]

<u>Stata Code:</u>
svyset sdmvpsu [pweight = wtmec2yr], strata(sdmvstra)
svy, subpop(age18p): tab irregular, se ci col deff
svy, subpop(age18p): proportion irregular
svy, subpop(age18p): mean irregular

| Variable | $n$ | Design $df$ | Estimated Proportion | Linearized SE | 95% CI | Design Effect |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Stata svy: tab, CI based on logit transform technique** | | | | | | |
| **Irregular** | **5,374** | **17** | **0.0164** | **0.0017** | **(0.0132, 0.0204)** | **1.21** |
| **Stata svy: prop, CI based on logit transform technique** | | | | | | |
| **Irregular** | **5,374** | **17** | **0.0164** | **0.0017** | **(0.0132, 0.0204)** | **1.21** |
| **Stata svy: mean, CI computed using the standard symmetric interval** | | | | | | |
| **Irregular** | **5,374** | **17** | **0.0164** | **0.0017** | **(0.0129, 0.0200)** | **1.21** |

13

<!-- page 14 -->

# Univariate Analysis: Multinomial Variables

* Variance estimation by TSL or Replication
* Stata: `svy: tab catvar, obs se`
* SAS: PROC SURVEYFREQ
* NHANES Example in SAS:

  **proc surveyfreq data = nhanes;**
  weight wtmec2yr;
  stratum sdmvstra;
  cluster sdmvpsu;
  tables **age18p**\*irregular / row cl; \*Here age18p is a subpopulation;
  **run;**

<!-- page 15 -->

# Univariate Analysis: Multinomial

* Estimation follows that for binary proportions:

$$p_k = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i} I_k}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i}} = \frac{\widehat{N}_k}{\widehat{N}}$$

14

<!-- page 16 -->

# Univariate Analysis: Multinomial

* Variance estimation by TSL or Replication
* CIs in Stata's svy: tab and svy: prop command use the logit transform method
* Goodness of Fit Hypothesis test ($\text{H}_0$: $\boldsymbol{\pi} = \boldsymbol{\pi}_0$): Stata mgof command

15

<!-- page 17 -->

# Estimating Proportions for Multinomial Variables

* svyset sdmvpsu [pweight = wtmec2yr], strata(sdmvstra)
* svy, subpop(age18p): tab bp_cat, obs se ci col
* svy, subpop(age18p): tab bp_cat, deff

**Estimated Proportions of U.S. Adults by Blood Pressure Status. Source: 2011-2012 NHANES**

| Blood Pressure Category | $n$ | Estimated Proportion | Linearized SE | 95% CI | Design Effect |
| :---: | :---: | :---: | :---: | :---: | :---: |
| Normal | 2438 | 0.472 | 0.016 | (0.440, 0.505) | 6.70 |
| Pre-Hypertension | 2284 | 0.428 | 0.012 | (0.403, 0.454) | 4.10 |
| Stage 1 Hypertension | 489 | 0.080 | 0.006 | (0.068, 0.093) | 3.19 |
| Stage 2 Hypertension | 145 | 0.020 | 0.004 | (0.013, 0.03) | 6.79 |

16

<!-- page 18 -->

# Example: Goodness of Fit for a Vector of Proportions: Hypothesized $\pi$ for Hypertension Status Category

recode bp_cat (1=.5) (2=.3) (3=.15) (4=.05), generate(pi)

*Next, the mgof command is submitted to test the null hypothesis:*
mgof bp_cat = pi if age18p == 1, svy

| Goodness-of-fit Statistic | $X^2$ | $p(\chi_3^2 > X^2)$ |
| :---: | :---: | :---: |
| Rao-Scott $X_{\text{Pearson}}^2$ | $450.24$ | $p < 0.0001$ |
| $X_{\text{LR, Jann}}^2$ | $465.48$ | $p < 0.0001$ |

17

<!-- page 19 -->

# Bivariate Categorical Data Analysis

* Contingency Tables
  – Total proportions
  – Row, column proportions
* Hypothesis Tests of Independence
* Odds Ratios, Relative Risk
* Simple Logit and Odds Ratios
* Regression Models (later)

18

<!-- page 20 -->

# Estimated distribution: Hypertension Status by Gender. Source: NHANES

19

<!-- page 21 -->

# NCS-R Example: 2 x 2 Table

* Example: Suppose that we are interested in studying the association between gender and a lifetime major depression episode ($1=\text{yes}$, $0=\text{no}$).

20

<!-- page 22 -->

# Proportions of Interest

Total proportion: e.g. $p_{\text{M0}} = \frac{\hat{N}_{\text{M0}}}{\hat{N}_{++}}$

Row proportion: e.g. $p_{\text{0|M}} = \frac{\hat{N}_{\text{M0}}}{\hat{N}_{\text{M+}}}$

Column proportion: e.g. $p_{\text{M|0}} = \frac{\hat{N}_{\text{M0}}}{\hat{N}_{\text{+0}}}$

21

<!-- page 23 -->

# Estimation of Total and Row Proportions

svyset seclustr [pweight = ncsrwtsh], strata(sestrat)

svy: tab sex mde, se ci deff

svy: tab sex mde, row se ci deff

| Description | Parameter | Estimated Proportion | Linearized SE | 95% CI | Design Effect |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **Total Proportions** | | | | | |
| Male, no MDE | $\pi_{A0}$ | 0.406 | 0.007 | (0.393, 0.421) | 1.87 |
| Male, MDE | $\pi_{A1}$ | 0.072 | 0.003 | (0.066, 0.080) | 1.64 |
| Female, no MDE | $\pi_{B0}$ | 0.402 | 0.005 | (0.391, 0.413) | 1.11 |
| Female, MDE | $\pi_{B1}$ | 0.120 | 0.003 | (0.114, 0.126) | 0.81 |
| **Row Proportions** | | | | | |
| No MDE \| Male | $\pi_{0|A}$ | 0.849 | 0.008 | (0.833, 0.864) | 2.08 |
| MDE \| Male | $\pi_{1|A}$ | 0.151 | 0.008 | (0.136, 0.167) | 2.08 |
| No MDE \| Female | $\pi_{0|B}$ | 0.770 | 0.006 | (0.759, 0.782) | 0.87 |
| MDE \| Female | $\pi_{1|B}$ | 0.230 | 0.006 | (0.218, 0.241) | 0.87 |

22

<!-- page 24 -->

# NCS-R: MDE x Gender
## Weighted Estimates of Total Proportions

| | MDE=NO (0) | MDE=YES (1) | Total |
| :---: | :---: | :---: | :---: |
| MEN (M) | $\mathbf{p_{A0}=0.406}$ | $\mathbf{p_{A1}=0.072}$ | $\mathbf{p_{A+}=0.478}$ |
| WOMEN (F) | $\mathbf{p_{B0}=0.402}$ | $\mathbf{p_{B1}=0.120}$ | $\mathbf{p_{B+}=0.522}$ |
| Total | $\mathbf{P_{+0}=0.808}$ | $\mathbf{P_{+1}=0.192}$ | $\mathbf{p_{++}=1.000}$ |

23

<!-- page 25 -->

# NCS-R: MDE x Gender
## Weighted Estimates of Row Proportions

| | MDE=NO (0) | MDE=YES (1) | Total |
| :---: | :--- | :--- | :--- |
| **MEN**<br>**(M)** | $\mathbf{P_{0|A}}=$ | $\mathbf{P_{1|A}}=$ | $\mathbf{p_{A+}}=$ |
| **WOMEN**<br>**(F)** | $\mathbf{P_{0|B}}=$ | $\mathbf{P_{1|B}}=$ | $\mathbf{p_{B+}}=$ |

24

<!-- page 26 -->

# Estimation of Total and Row Proportions (SAS)

**proc surveyfreq data = ncsr;**

weight ncsrwtsh;

stratum sestrat;

cluster seclustr;

tables sex\*mde / row cl deff;

**run;**

<!-- page 27 -->

* The logistic or polytomous regression model framework can be used analyze categorical data when one variable can be designated as the dependent variable and other variables as explanatory or predictor variables.
* Many times we are interested only in investigating associations between a set of categorical variables.
* A common approach is to compute a chi-square statistic under the null hypothesis, and fail to reject the null hypothesis if this chi-square statistic is within the range of values that would be expected.

25

<!-- page 28 -->

# Simple Hypothesis Tests

* ($2 \times 2$ table). Under the null hypothesis of independence:

i) *as a Chi square "test of independence"*

$$H_0 \quad P_{rc} = P_{r+} P_{+c}$$

ii) *as a test of difference in two proportions,*

$$H_0 : \Pr(Depress = c \mid Sex = r) = \Pr(Depress = c \mid Sex = r')$$

26

<!-- page 29 -->

# Chi-square Tests: Pearson and Likelihood Ratio

- The chi-square test statistic is a measure of distance between the expected and observed counts in cells.

- Pearson:
$$X_{Pearson}^2 = n_{++} \cdot \sum_r \sum_c (p_{rc} - \hat{\pi}_{rc})^2 / \hat{\pi}_{rc}$$

- Likelihood Ratio:
$$G^2 = 2 \cdot n_{++} \cdot \sum_r \sum_c p_{rc} \times \ln\left(\frac{p_{rc}}{\hat{\pi}_{rc}}\right)$$

- If the observed data are consistent with the null hypothesis, then we would expect this distance measure (the test statistic) to be small.

27

<!-- page 30 -->

# Adjusting for Design Effects

* How to incorporate the design features into this analysis? Since ignoring the design features (weighting) can introduce bias in the estimated proportions that goes into making the Chi-square statistics, the above analysis is not valid.
* Two approaches:
  – Fellegi (JASA, 1980) corrects the SRS Chi-square statistic.
  – Rao-Scott (1984, Biometrika), Rao-Thomas (1987)

28

<!-- page 31 -->

# Fellegi Method

* Compute the average design effect of the proportions involved in the Chi-square statistic. For the 4 proportions in the NCS $2 \times 2$ example in the handout example (different from text example), the average design effect is $\sim 1.3575$.
* Divide the SRS Chi-square test statistic by this average design effect. The corrected Chi-square statistic is $108.2913/1.3575 = 87.64$.
* P-value is obtained by referring the corrected statistics to a Chi-square distribution with degrees of freedom $(r-1)(c-1)$.

29

<!-- page 32 -->

# Rao-Scott Method

* Use the weighted proportions in the construction of Chi-square statistics. Develop an approximate F-reference distribution for determining p-value.
* This is analytically more complicated and requires computation of generalized design effects. These are the eigenvalues of the matrix given on the next page.
* SAS, SUDAAN, and Stata have all implemented this approach.

30

<!-- page 33 -->

# Rao-Scott Generalized Design Effect

$$
\begin{aligned}
&\text{\textit{Generalized design effects are the}} \\
&\text{\textit{eigen values of the matrix}} : \\
&D = V_{Des} V_{SRS}^{-1} \\
&\text{\textit{where}} : \\
&V_{Des} = \text{\textit{Design}}-\text{\textit{based covariance matrix}} \\
&\quad\quad\quad \text{\textit{for estimated proportions; and}} \\
&V_{SRS} = \text{\textit{SRS covariance matrix}} \\
&\quad\quad\quad \text{\textit{for estimated proportions}}
\end{aligned}
$$

31

<!-- page 34 -->

# Design-adjusted $X^2$ Test Statistics

* First order correction (SAS system default):

$$X^2_{R\ S} = X^2_{Pearson} / GDEFF,$$

$$G^2_{R\ S} = G^2 / GDEFF$$

* *GDEFF: the mean of the eigenvalues, or the “average design effect” (see ASDA, p. 176)*

32

<!-- page 35 -->

# Design-adjusted $X^2$ Test Statistics

* Second order correction
* Stata system default, SAS V9.3 option:

$$
{X^2}_{R\ S} = {X^2}_{Pearson} / GDEFF / (1 + a^2),
$$

$$
G^2_{R\ S} = G^2 / GDEFF / (1 + a^2)
$$

  where:

  a = coefficient of variation of eigenvalues of D matrix.

33

<!-- page 36 -->

# Rao-Scott Correction for 2-Way Tables

*for a two-way table of proportions,*

$$
\begin{aligned}
GDEFF &= \left\{ \begin{array}{l}
\sum_r \sum_c (1 - \hat{P}_{rc}) \cdot DEFF(\hat{P}_{rc}) \\
\quad - \sum_r (1 - \hat{P}_{r.}) \cdot DEFF(\hat{P}_{r.}) \\
\quad - \sum_c (1 - \hat{P}_{.c}) \cdot DEFF(\hat{P}_{.c})
\end{array} \right\} / (r - 1)(c - 1) \\
&= \text{Mean Generalized Design Effect} \\
&= \text{Mean of eigenvalues of } \boldsymbol{D} \text{ matrix}
\end{aligned}
$$

34

<!-- page 37 -->

# Rao-Scott Chi-Square
## (First order correction as in SAS default).

$$
R-S\ Chi-Square:
$$

$$
Q_{rs} = Q_{Pearson} / GDEFF
$$

$$
\sim \chi^2_{(R-1)(C-1)}\ under\ H_0
$$

$$
or:\qquad F = Q_{rs} / (R-1)(C-1)
$$

$$
\sim F_{(R-1)(C-1),(R-1)(C-1)S}\ under\ H_0
$$

$$
where: s = \# clusters - \# strata\ in\ complex\ design.
$$

35

<!-- page 38 -->

# Rao-Scott Likelihood Ratio Chi-Square (First order correction as in SAS default).

$$
\begin{aligned}
R - S\ LR\ Chi - Square : \ & G_{RS}^2 = G^2 / GDEFF \\
& \sim \chi_{(R-1)(C-1)}^2\ under\ H_0 \\
or : \qquad\qquad\qquad\qquad\qquad & F = G_{RS}^2 / \{(C - 1)(R - 1)\} \\
& \sim F_{(C-1)(R-1),S(C-1)(R-1)} \\
where : s = \#clusters - \# & strata\ in\ complex\ design.
\end{aligned}
$$

36

<!-- page 39 -->

## Alcohol Dependence vs. Education Level for Young Adults Age 18-28. Source: NCS-R.

<u>In Stata:</u>

svyset seclustr [pweight = ncsrwtsh], strata(sestrat)

svy, subpop(**if 18<=age<29**): tab ed4cat ald, row se ci deff

<u>In SAS V9.2+:</u>

title "Analysis Example : Proportions by Subgroups: NCSR" ;

**proc surveyfreq** data=ncsr ;

  strata sestrat ;

  cluster seclustr ;

  weight ncsrwtsh;

  tables **age29**\*ed4cat\*ald / row deff chisq ;

\* tables **age29**\*ed4cat\*ald / row deff chisq(secondorder) ; \*(OPTIONAL);

  format ed4cat edf. ald aldf. ; **run** ;

37

<!-- page 40 -->

**Table 6.8:** Design-adjusted Analysis of Alcohol Dependence vs. Education Level for Young Adults Age 18-28. Source: NCS-R.

| Education Level (Grades) | Alcohol Dependence (ALD) Row Percentages (0 = No) | Alcohol Dependence (ALD) Row Percentages (1 = Yes) | Alcohol Dependence (ALD) Row Percentages (Total) |
| :---: | :---: | :---: | :---: |
| 0-11 | 0.909 (0.029) | 0.091 (0.029) | 1.000 |
| 12 | 0.951 (0.014) | 0.049 (0.014) | 1.000 |
| 13-15 | 0.951 (0.010) | 0.049 (0.010) | 1.000 |
| 16+ | 0.931 (0.014) | 0.069 (0.014) | 1.000 |
| Total | 0.940 (0.009) | 0.060 (0.009) | 1.000 |
| **Tests of Independence (Note the difference!)** | | | |
| Unadjusted $X^2$ | $\text{P } (\chi^2_{(3)} > X^2_{\text{Pearson}})$ | Rao-Scott $F$ | $\text{P } (F_{2.75, 115.53} > F_{\text{R-S}})$ |
| $X^2_{\text{Pearson}} = 27.21$ | **$p < 0.0001$** | $F_{R\text{-}S, Pearson} = 1.64$ | **$p = 0.18$** |
| **Parameters of the Rao-Scott Design-Adjusted Test** | | | |
| $n_{18\text{-}29} = 1275$ | $\text{Design } df = 42$ | $GDEFF = 6.62$ | $a = 0.56$ |

38

<!-- page 41 -->

# Odds Ratios and Relative Risks

$$
\begin{aligned}
\hat{\psi} &= \frac{Odds(MDE = 1 | Male)}{Odds(MDE = 1 | Female)} = \frac{p_{1|A} / (1 - p_{1|A})}{p_{1|B} / (1 - p_{1|B})} = \frac{p_{1|A} / p_{0|A}}{p_{1|B} / p_{0|B}} \\
&= \frac{0.151 / 0.849}{0.230 / 0.770} = 0.595
\end{aligned}
$$

$$
\begin{aligned}
\hat{R}R &= \frac{\text{Prob}(MDE = 1 | Male)}{\text{Prob}(MDE = 1 | Female)} \\
&= \frac{p_{1|A}}{p_{1|B}} = \frac{0.151}{0.230} = 0.656
\end{aligned}
$$

40

<!-- page 42 -->

# Logit of a Proportion

$$
\begin{aligned}
\text{logit}(p_{1|A}) &= \ln(Odds(MDE = 1 | Male)) = \ln\left(\frac{p_{1|A}}{1 - p_{1|A}}\right) \\
&= \ln\left(\frac{0.151}{0.849}\right) = -1.727 \\
\text{logit}(p_{1|B}) &= \ln(Odds(MDE = 1 | Female) = \ln\left(\frac{p_{1|B}}{1 - p_{1|B}}\right) \\
&= \ln\left(\frac{0.230}{0.770}\right) = -1.208
\end{aligned}
$$

41

<!-- page 43 -->

# Logit Regression and Odds Ratios

$$
\text{logit}(P(MDE = 1 | SEX)) = \beta_0 + \beta_1 \cdot I_{male}
$$

$$
\begin{aligned}
\hat{\psi} &= \frac{p_{1|A}/(1 - p_{1|A})}{p_{1|B}/(1 - p_{1|B})} = \frac{\exp(\text{logit}(p_{1|A}))}{\exp(\text{logit}(p_{1|B}))} \\
&= \frac{\exp(\hat{\beta}_0 + \hat{\beta}_1 \cdot 1)}{\exp(\hat{\beta}_0 + \hat{\beta}_1 \cdot 0)} = \exp(\hat{\beta}_1)
\end{aligned}
$$

42

<!-- page 44 -->

# Confidence Intervals for Unadjusted Odds Ratios

$$CI(\psi) = \begin{pmatrix} CIL = \exp(\hat{\beta}_1 - t_{1-\alpha/2, df} \cdot se(\hat{\beta}_1)), \\ CIU = \exp(\hat{\beta}_1 + t_{1-\alpha/2, df} \cdot se(\hat{\beta}_1)) \end{pmatrix}$$

43
