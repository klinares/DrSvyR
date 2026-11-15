---
id: "jpsm/complex_sample_data_SURV701/labs/Module_10_SAS_supplement"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lab"
title: "Module #5: Logistic Regression with Survey Data"
original: "complex_sample_data_SURV701/labs/Module_10_SAS_supplement.pdf"
pages: 34
sha256: "4465f593c7a0edc5395a41b25bcd7b3a70d4ec93034a8b43a729c2a818d27a76"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:48"
---

<!-- page 1 -->

# Module #5: Logistic Regression with Survey Data

All too commonly, linear regression models are fit to dichotomous outcome variables. We begin this module by discussing the perils of that practice, and then introduce logistic regression, a preferred alternative.

Instead of modeling the outcome directly as a 0/1 indicator variable of some event or characteristic, the notion behind logistic regression is to model a transformation of it—namely, the natural logarithm of the odds, which we defined in an earlier class as the *log-odds* or the *logit*. We will see how to do so with PROC SURVEYLOGISTIC, making use of data from the 2010 National Ambulatory Medical Survey (NAMCS).

As we did with linear regression, we first introduce the technique under the simple random sampling setting, then discuss modifications in the presence of complex survey data.

STAT674 – GMU – Lewis

1

<!-- page 2 -->

# Linear Regression with a Dichotomous Outcome

Suppose $y = 1$ indicates some event occurred and $y = 0$ indicates it did not occur. In the plot below, larger values of $x$ tend to be associated with a higher probability of the event occurring and vice versa. We can think of the least square regression line as a linear probability model: $\Pr(y_i = 1 \mid x_i) = p_i = \beta_0 + \beta_1 x_i + \varepsilon_i$

<u>Issues</u>:

1. Predicted probabilities may fall outside of 0 and 1.
2. Errors distributed binomially, not normally.
3. Error variance not constant (i.e., heteroscedasticity) – more variability around $x = 5$ than, say, $x = 1$ or $x = 9$.

STAT674 – GMU – Lewis

2

<!-- page 3 -->

# Logistic Regression

Instead of directly modeling $p_i$, a logistic regression model expresses the *log-odds*, or *logit*, as a linear function of $x$:

$$\ln \left( \frac{p_i}{1 - p_i} \right) = \beta_0 + \beta_1 x_i$$

As Allison (2012) notes, converting $p_i$ to the odds, $p_i / (1 - p_i)$, removes any kind of upper bound, and taking the natural logarithm of the odds removes any kind of lower bound, because the asymptote of the natural logarithm function is 0.

Using the fundamental property that $\exp(\ln(x)) = x$, we can convert a logit to a probability at any time by exponentiating both sides and solving for $p_i$, which returns

$$p_i = \frac{\exp(\beta_0 + \beta_1 x_i)}{1 + \exp(\beta_0 + \beta_1 x_i)}$$

---
STAT674 – GMU – Lewis
3

<!-- page 4 -->

# Visualizing the Logistic Regression Model

Before walking through computation details of how to estimate and interpret model parameters, the plot below shows how the predicted probabilities under the new model specification never actually reach 0 or 1. There is linearity on the logit scale, but some curvature on the probability scale.

STAT674 – GMU – Lewis

4

<!-- page 5 -->

# Interpreting Logistic Regression Parameters

The logit transformation results in a different interpretation of $\beta_1$ than that of linear regression. Instead of interpreting it as the expected increase in the outcome (or probability) given a one-unit increase in $x$, it represents the expected change in the logit given a one-unit change in $x$.

To see why, consider a case with $x = 6$ relative to a case with $x = 5$:

$$l_1 - l_2 = (\beta_0 + 6\beta_1) - (\beta_0 + 5\beta_1) = \beta_1$$

Because $\ln(x) - \ln(y) = \ln(x/y)$, $\beta_1$ can be expressed as

$$l_1 - l_2 = \ln\left(\frac{p_1}{1 - p_1}\right) - \ln\left(\frac{p_2}{1 - p_2}\right) = \ln\left(\left[\frac{p_1}{1 - p_1}\right] / \left[\frac{p_2}{1 - p_2}\right]\right)$$

So, we can exponentiate $\beta_1$ to convert it back to an odds ratio, which is a little easier to deal with than a logit.

STAT674 – GMU – Lewis 5

<!-- page 6 -->

# Interpreting Logistic Regression Parameters (2)

To provide a numerical example, suppose that an estimated parameter for a logistic regression model comes out to 0.5. This means the estimated odds ratio is $\exp(0.5) = 1.6847$.

An odds ratio such as this derived from a logistic regression model is often colloquially interpreted with a statement such as “a one-unit increase in $x$ is associated with a 68.47% higher likelihood of the event occurring.” In reality, that interpretation is more befitting of the relative risk statistic we talked about in Module #4. The two are nearly equivalent only when the underlying $p_i$ is small (Agresti, 2013).

When the odds of the event are constant for all values of $x$, the odds ratio of any two cases with different $x_i$’s will be 1, causing the log-odds ratio to be 0, since $\ln(1) = 0$. Therefore, conducting a hypothesis test to determine whether a logistic regression parameter is significantly different from 0 is just as relevant in logistic regression as it is in linear regression.

---

STAT674 – GMU – Lewis

6

<!-- page 7 -->

# Interpreting Categorical Variables

Consider the table below, which contains counts of developing lung cancer based on whether or not the individual is a smoker.

| | **Lung Cancer** | **No Lung Cancer** | **Row Totals** |
| :---: | :---: | :---: | :---: |
| **Smoker** | 200 | 1,800 | 2,000 |
| **Non-Smoker** | 160 | 7,840 | 8,000 |
| **Column Totals** | 360 | 9,640 | 10,000 |

If we were to model lung cancer as a function of smoking, we might create a predictor variable to be $x_i = 1$ if the $i^{\text{th}}$ individual is a smoker and $x_i = 0$ if a non-smoker.

Prior to even fitting a logistic regression model to the data summarized above, we can reason that the “smoker” parameter will equal the natural logarithm of the odds ratio, or $\ln[(200 \times 7840)/(160 \times 1800)] = \ln(5.4444) = 1.6946$.

STAT674 – GMU – Lewis

7

<!-- page 8 -->

# Interpreting Categorical Variables (2)

This extends to variables with $K > 2$ distinct values. For example suppose smokers were further classified based on the number of cigarettes smoked per day: less than one pack or one pack or more. This renders the overall effect of smoking to be a categorical variable with $K = 3$ values.

| | **Lung Cancer** | **No Lung Cancer** | **Row Totals** |
| :---: | :---: | :---: | :---: |
| **Smoker: $< 1$ Pack/Day** | 100 | 1,400 | 1,500 |
| **Smoker: $\ge 1$ Pack/Day** | 100 | 400 | 500 |
| **Non-Smoker** | 160 | 7,840 | 8,000 |
| **Column Totals** | 360 | 9,640 | 10,000 |

Similarly to how we handled categorical effects in linear regression, we create $K - 1 = 2$ indicator variables to invoke the *reference parameterization*:
* $x_{1i} = 1$ if $i^{\text{th}}$ individual smokes less than a pack/day; $0$ otherwise
* $x_{2i} = 1$ if $i^{\text{th}}$ individual smokes a pack/day or more; $0$ otherwise.
* Note: the value without a parameter (non-smoker) is called the *reference* category.

---
STAT674 – GMU – Lewis  8

<!-- page 9 -->

# Interpreting Categorical Variables (3)

| | **Lung Cancer** | **No Lung Cancer** | **Row Totals** |
| :--- | :---: | :---: | :---: |
| **Smoker: $< 1$ Pack/Day** | 100 | 1,400 | 1,500 |
| **Smoker: $\ge 1$ Pack/Day** | 100 | 400 | 500 |
| **Non-Smoker** | 160 | 7,840 | 8,000 |
| **Column Totals** | 360 | 9,640 | 10,000 |

We can think of the two parameters as the log-odds ratios of two 2 x 2 tables, one for each of the two smoking frequency designations versus the reference category, non-smokers.

For example, with respect to the counts above, the parameter associated with $x_1$ would be would be calculated as $\ln[(100 \times 7840)/(160 \times 1400)] = \ln(3.5) = 1.2528$. The parameter associated with $x_2$ would be calculated as

$\ln[(100 \times 7840)/(160 \times 400)] = \ln(12.25) = 2.5056$.

---

STAT674 – GMU – Lewis 9

<!-- page 10 -->

# Estimating Logistic Regression Parameters

Let $\mathbf{X}$ be the $n \times p$ design matrix consisting of one row for each of the $n$ units in the sample, a column of $1$’s to represent the intercept, and a set of $p - 1$ additional columns housing either continuous variables or $0/1$ indicator variables to represent categorical variable effects.

Let $\mathbf{x_i}$ represent the row of the design matrix associated with the $i^{\text{th}}$ unit and let $\boldsymbol{\beta}$ be the $p \times 1$ vector of model parameters, such that

$$p_i = \frac{\exp(\mathbf{x_i}\boldsymbol{\beta})}{1 + \exp(\mathbf{x_i}\boldsymbol{\beta})}$$

With the outcome coded $y_i = 1$ for an event and $y_i = 0$ for a non-event, our goal is to find $\boldsymbol{\beta}$ such that we maximize the following *likelihood function*:

$$L = \prod_{i=1}^n p_i^{y_i} (1 - p_i)^{1-y_i}$$

STAT674 – GMU – Lewis 10

<!-- page 11 -->

# Estimating Logistic Regression Parameters (2)

Taking the natural logarithm of the likelihood function makes things easier because it converts power terms into coefficients and products into summations. Specifically, we can instead maximize the *log-likelihood function*:

$$\ln(L) = \sum_{i=1}^{n} y_i \ln(p_i) + (1 - y_i) \ln(1 - p_i)$$

To do so, we express the equation above in terms of the underlying parameters in $\boldsymbol{\beta}$ and set all partial derivatives equal to 0. This results in a system of $p$ equations:

$$\sum_{i=1}^{n} x_{ji} y_i - \sum_{i=1}^{n} x_{ji} p_i = 0$$

Because the equations are nonlinear, there are no closed-form solutions (except in a few special situations). The work-around is to iterate through plausible values (e.g., using the Newton-Raphson algorithm) until the betas converges to a set of values called the *maximum likelihood estimates*.

STAT674 – GMU – Lewis 11

<!-- page 12 -->

# Model Parameter Covariance Matrix

Once we have the maximum likelihood estimates, which we can denote $\hat{\beta}$, we can find the model parameter covariance matrix as

$$
\text{cov}(\hat{\mathbf{\beta}}) = (\mathbf{X}^{\mathbf{T}}\mathbf{V}\mathbf{X})^{-1}
$$

where $\mathbf{X}$ is the $n \times p$ design matrix, and $\mathbf{V}$ is an $n \times n$ diagonal matrix with terms $\hat{p}_i(1 - \hat{p}_i)$ where

$$
\hat{p}_i = \frac{\exp(\mathbf{x}_{\mathbf{i}}\hat{\mathbf{\beta}})}{1 + \exp(\mathbf{x}_{\mathbf{i}}\hat{\mathbf{\beta}})}
$$

Just as in the linear regression case, entries along the diagonal of the model parameter covariance matrix are the estimated variances for the $p$ model parameters, while off-diagonal entries are covariances between two particular model parameters. The $p(p - 1)/2$ distinct covariances are symmetric about the diagonal.

STAT674 – GMU – Lewis 12

<!-- page 13 -->

# Hypothesis Testing of Regression Coefficients

As with linear regression models, the model parameter covariance matrix can be used to test hypotheses about the parameters, such as whether any are not significantly different from 0 and could therefore be dropped from the model.

In general, to test $H_0: \beta_j = 0$ vs. $H_1: \beta_j \neq 0$ for some $j$, we can formulate a *Wald chi-square test statistic* as follows:

$$
W = \left( \frac{\hat{\beta}_j}{\sqrt{\text{var}(\hat{\beta}_j)}} \right)^2
$$

which is like a squared version of the $t$ test we use in linear regression. As such, $W$ is referenced against the $100(1 - \alpha)^{\text{th}}$ percentile of a chi-square distribution with 1 degree of freedom. If greater than that value, the null hypothesis is rejected.

---

STAT674 – GMU – Lewis

13

<!-- page 14 -->

# Hypothesis Testing of Regression Coefficients (2)

Parameter-specific tests can also be conducted using matrix algebra. For example, we can define a $p \times 1$ *contrast vector* $\mathbf{C}$ comprised of all zeros except the row corresponding to the parameter being tested, which is assigned a 1, and then find

$$W = (\mathbf{C}^{\text{T}}\hat{\boldsymbol{\beta}})^{\text{T}}(\mathbf{C}^{\text{T}}\mathbf{cov}(\hat{\boldsymbol{\beta}})\mathbf{C})^{-1}(\mathbf{C}^{\text{T}}\hat{\boldsymbol{\beta}})$$

Notice how this is similar to the $F$ statistic we discussed in the linear regression setting:

$$F = (\mathbf{C}^{\text{T}}\hat{\boldsymbol{\beta}})^{\text{T}}(\mathbf{C}^{\text{T}}\mathbf{cov}(\hat{\boldsymbol{\beta}})\mathbf{C})^{-1}(\mathbf{C}^{\text{T}}\hat{\boldsymbol{\beta}}) / \text{rank}(\mathbf{C})$$

However, we do not divide the $W$ statistic by the rank of $\mathbf{C}$ like we do in linear regression (although in present case, $\text{rank}(\mathbf{C}) = 1$, so there is effectively no difference). Instead, we reference $W$ to a chi-square distribution with $\text{rank}(\mathbf{C})$ degrees of freedom.

---
STAT674 – GMU – Lewis
14

<!-- page 15 -->

# Hypothesis Testing Using Deviances

Because there is no error term in a logistic regression model, there is no ANOVA table. Rather than assessing the change in the SSE, we can inspect what happens to a quantity called the *deviance*:

$$D = -2\ln(L)$$

Specifically, we can carry out a *likelihood ratio test* by finding

$$G = D_{red} - D_{full}$$

where $D_{full}$ denotes the deviance of the full model and $D_{red}$ the like for the reduced model, one where $q$ parameters have been dropped. Because adding more terms to the model can only serve to reduce the deviance, $G$ is always positive. If $G$ surpasses the $100(1 - \alpha)^{\text{th}}$ percentile of a chi-square distribution with $q$ degrees of freedom, there is evidence we can drop the parameters.

* NOTE: this may not be numerically equivalent to the matrix algebra approach (as it is with linear regression), but results will be close.

---
STAT674 – GMU – Lewis

15

<!-- page 16 -->

# Logistic Regression with Survey Data

To estimate parameters, survey weights ($w_i$'s) are used as part of a *pseudo-maximum likelihood function*:

$$PL = \prod_{i=1}^{n} \left[ {p_i}^{y_i} (1 - p_i)^{1 - y_i} \right]^{w_i}$$

so-named because it is our best estimate of the full-population likelihood:

$$L = \prod_{i=1}^{N} {p_i}^{y_i} (1 - p_i)^{1 - y_i}$$

Like we do in the simple random setting, we maximize the natural logarithm of the pseudo-maximum likelihood function, find partial derivatives, and then solve the following system of equations, one for each of the $p$ parameters:

$$\sum_{i=1}^{n} w_i x_{ji} y_i - \sum_{i=1}^{n} w_i x_{ji} p_i = 0$$

STAT674 – GMU – Lewis

16

<!-- page 17 -->

# Logistic Regression with Survey Data (2)

The Newton-Raphson algorithm is one example tool we can use to solve and arrive at a solution, $\hat{\mathbf{B}}$, referred to as *the pseudo-maximum likelihood estimate*.

As with linear regression, we typically denote finite population logistic regression parameters with Roman letters instead of Greek letters.

And, of course, we can always transform the logit for the $i^{\text{th}}$ case into a probability by finding

$$\hat{p}_i = \frac{\exp(\mathbf{x_i}\hat{\mathbf{B}})}{1 + \exp(\mathbf{x_i}\hat{\mathbf{B}})}$$

where $\mathbf{x_i}$ is the $i^{\text{th}}$ row of $\mathbf{X}$, the design matrix.

STAT674 – GMU – Lewis

17

<!-- page 18 -->

# Logistic Regression with Survey Data (3)

The model parameter covariance matrix can be estimated using a multivariate generalization of Taylor series linearization applicable to implicit functions proposed by Binder (1983):

$$\text{cov}(\hat{\mathbf{B}}) = (\mathbf{X}^{\text{T}}\mathbf{W}\mathbf{V}\mathbf{X})^{-1}\text{var}(\sum_{i=1}^{n} w_i \mathbf{u}_{\mathbf{i}})(\mathbf{X}^{\text{T}}\mathbf{W}\mathbf{V}\mathbf{X})^{-1}$$

where $\mathbf{u}_{\mathbf{i}} = \mathbf{x}_{\mathbf{i}}(y_i - \hat{p}_i)$, $\mathbf{x}_{\mathbf{i}}$ is the $i^{\text{th}}$ row of the design matrix, $\mathbf{W}$ is an $n \text{ x } n$ diagonal matrix of weights, and $\mathbf{V}$ is an $n \text{ x } n$ diagonal matrix of terms $\hat{p}_i(1 - \hat{p}_i)$

Note: all three SURVEY procedures with modeling capabilities (PROC SURVEYREG, PROC SURVEYLOGISTIC, and PROC SURVEYPHREG) apply the adjustment factor $(n - 1)/(n - p)$ when estimating the model parameter covariance matrix based on a recommendation by Hidiroglou et al. (1980) to reduce bias that can occur in small samples. If you do not want this adjustment factor to be used, specify VADJUST=NONE after the slash in the MODEL statement.

---

STAT674 – GMU – Lewis

18

<!-- page 19 -->

# Hypothesis Testing of Regression Coefficients

Heeringa et al. (2010) point out how the assumptions underlying the deviance-based, likelihood-ratio test are invalidated in presence of complex survey data. Research is ongoing on alternatives, but as yet there is nothing widely programmed into available software. So, best to stick with the matrix algebra approach for conducting hypothesis tests on parameters.

As in linear regression, the current recommendation is to implement an adjustment a la Korn and Graubard (1990), but recall that was based on an $F$ statistic. We need to first divide $W$, the Wald chi-square defined earlier, by the rank of $\mathbf{C}$, denoted below as $q$, to convert the chi-square statistic into an $F$ statistic:

$$
F_{ADJ} = \frac{W}{q} \times \frac{(df - q + 1)}{df}
$$

which we can then reference against an $F$ distribution with $q$ and $df - q + 1$ degrees of freedom for the numerator and denominator, respectively, $df$ is the complex survey degrees of freedom (#PSUs - #strata). NOTE: SAS reports $W$, not $F_{ADJ}$.

STAT674 – GMU – Lewis

19

<!-- page 20 -->

# Example Using 2010 NAMCS

Suppose a health researcher wants to model whether medication is prescribed during the visit as a function of the patient's gender, age, race, primary reason for the visit, the total number of chronic conditions afflicting the patient, and time spent with the physician.

Recall the 2010 NAMCS data has three features of complex survey data:

1. Stratification – distinct codes of the variable CSTRATM
2. Clustering – distinct codes of the variable CPSUM
3. Unequal Weights – variable PATWT

There are a total of 626 unique PSUs amongst 74 strata, which means there are $626 - 74 = 552$ complex survey degrees of freedom.

---

STAT674 – GMU – Lewis

20

<!-- page 21 -->

# Variable Summary for NAMCS 2010 Model

| Variable Name | Description | Coding Structure |
| :--- | :--- | :--- |
| MED | Indicator of medication prescribed or renewed | 0 = No<br>1 = Yes |
| TIMEMD | Time spent with physician in minutes | Continuous |
| SEX | Patient gender | 1 = Female<br>2 = Male |
| AGE | Patient age in years | Continuous |
| RACER | Patient race | 1 = White<br>2 = Black<br>3 = Other |
| TOTCHRON | Patient’s total number of chronic conditions | Integer |
| MAJOR | Primary reason for the visit | 1 = New problem (< 3 months onset)<br>2 = Chronic problem, routine<br>3 = Chronic problem, flare up<br>4 = Pre-/Post-surgery<br>5 = Preventive care (e.g. routine prenatal, screening) |

STAT674 – GMU – Lewis

21

<!-- page 22 -->

# PROC SURVEYLOGISTIC Syntax

Syntax below fits the model while accounting for the complex survey features. Numeric variables to be treated as categorical are placed in the CLASS statement. The PARAM=REF option after slash invokes the reference parameterization, which is not the default. The default is the *effect parameterization*, which is not as easy to interpret (Lewis, 2007).

The EVENT=‘1’ syntax tells PROC SURVEYLOGISTIC which outcome is to be modeled $\rightarrow$ specifying EVENT=‘0’ would change sign of estimated model parameters.

```sas
*** Program 6.1;
proc surveylogistic data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class SEX RACER MAJOR / param=ref;
  model MED (event='1') = SEX RACER MAJOR
                          AGE TOTCHRON TIMEMD;
  weight PATWT;
run;
```

By default, PROC SURVEYLOGISTIC generates A LOT of output…

---
STAT674 – GMU – Lewis  22

<!-- page 23 -->

# PROC SURVEYLOGISTIC Output

### The SURVEYLOGISTIC Procedure

#### Model Information

| | |
| :--- | :--- |
| Data Set | WORK.NAMCS_2010 |
| Response Variable | MED |
| Number of Response Levels | 2 |
| Stratum Variable | CSTRATM |
| Number of Strata | 74 |
| Cluster Variable | CPSUM |
| Number of Clusters | 626 |
| Weight Variable | PATWT |
| Model | Binary Logit |
| Optimization Technique | Fisher's Scoring |
| Variance Adjustment | Degrees of Freedom (DF) |

#### Variance Estimation

| | |
| :--- | :--- |
| Method | Taylor Series |
| Variance Adjustment | Degrees of Freedom (DF) |

| | |
| :--- | ---: |
| Number of Observations Read | 31229 |
| Number of Observations Used | 31229 |
| Sum of Weights Read | 1.0088E9 |
| Sum of Weights Used | 1.0088E9 |

#### Response Profile

| Ordered Value | MED | Total Frequency | Total Weight |
| :---: | :---: | :---: | :---: |
| 1 | 0 | 8248 | 251274996 |
| 2 | 1 | 22981 | 757527009 |

Probability modeled is MED=1.

Per below, PROC SURVEYLOGISTIC defaults to assigning reference group as last value in sort-ordered list of $K$ unique values for given CLASS statement variable.

* Can change with CLASS statement syntax like SEX (REF=‘1’) RACER (REF=‘2’);

#### Class Level Information

| Class | Value | Design Variables | |
| :--- | :---: | :---: | :---: |
| SEX | 1 | 1 | |
| | 2 | 0 | |
| RACER | 1 | 1 | 0 |
| | 2 | 0 | 1 |
| | 3 | 0 | 0 |

---
STAT674 – GMU – Lewis 23

<!-- page 24 -->

# PROC SURVEYLOGISTIC Output (2)

Estimated model parameters and $W$ statistics for $H_0$: $B_j = 0$ vs. $H_1$: $B_j \neq 0$ for $j = 1, \dots, p$:

**The SURVEYLOGISTIC Procedure**

**Analysis of Maximum Likelihood Estimates**

| Parameter | | DF | Estimate | Standard Error | Wald Chi-Square | Pr > ChiSq |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| Intercept | | 1 | 0.1114 | 0.2070 | 0.2898 | 0.5904 |
| SEX | 1 | 1 | 0.0183 | 0.0435 | 0.1770 | 0.6740 |
| RACER | 1 | 1 | 0.4837 | 0.1860 | 6.7587 | 0.0093 |
| RACER | 2 | 1 | 0.6960 | 0.2009 | 12.0078 | 0.0005 |
| MAJOR | 1 | 1 | 0.3501 | 0.0861 | 16.5503 | <.0001 |
| MAJOR | 2 | 1 | 0.5611 | 0.1190 | 22.2340 | <.0001 |
| MAJOR | 3 | 1 | 0.4515 | 0.1043 | 18.7457 | <.0001 |
| MAJOR | 4 | 1 | -0.7982 | 0.1186 | 45.3271 | <.0001 |
| AGE | | 1 | 0.00306 | 0.00169 | 3.2606 | 0.0710 |
| TOTCHRON | | 1 | 0.1749 | 0.0197 | 79.2365 | <.0001 |
| TIMEMD | | 1 | -0.00092 | 0.00241 | 0.1454 | 0.7029 |

---
STAT674 – GMU – Lewis

24

<!-- page 25 -->

# PROC SURVEYLOGISTIC Output (3)

Like PROC SURVEYREG, PROC SURVEYLOGISTIC outputs a series of tests for each model “effect,” a single parameter for a continuous predictor variable or the set of $K - 1$ parameters associated with a categorical variable consisting of $K$ distinct levels. The single parameter version assigns $\mathbf{C}$ as a $p \times 1$ vector of zeros for all rows except that corresponding to the given parameter, which is assigned a value of 1. For a categorical variable, $\mathbf{C}$ is a $p \times (K - 1)$ vector consisting of a separate column for each level of the categorical variable constructed in the same manner.

Notice how for single parameters the statistic below matches the statistic seen on last slide.

**Type 3 Analysis of Effects**

| Effect | DF | Wald Chi-Square | Pr > ChiSq |
| :--- | ---: | ---: | ---: |
| SEX | 1 | 0.1770 | 0.6740 |
| RACER | 2 | 13.8646 | 0.0010 |
| MAJOR | 4 | 137.8999 | <.0001 |
| AGE | 1 | 3.2606 | 0.0710 |
| TOTCHRON | 1 | 79.2365 | <.0001 |
| TIMEMD | 1 | 0.1454 | 0.7029 |

---
STAT674 – GMU – Lewis

25

<!-- page 26 -->

# Testing for a Reduced Model

Scrutinizing the model parameter summary, we can observe that none of the effects attributable to patient gender (SEX), patient age (AGER), or time spent with the physician (TIMEMD) are significant at the $\alpha = 0.05$ level.

Suppose we wanted to determine whether all terms related to those three effects can be removed from the model. We can do this using the CONTRAST statement in PROC SURVEYLOGISTIC.

Our main concern is to properly populate the contrast matrix $\mathbf{C}$ with *contrast coefficients*. We name the effect and then provide the coefficient(s) immediately afterwards. For a continuous effect, one value is sufficient, but $K - 1$ values are needed for categorical variable effects with $K$ distinct levels. Any effect not explicitly listed is given a value of $0$.

---
STAT674 – GMU – Lewis 26

<!-- page 27 -->

# PROC SURVEYLOGISTIC Syntax to Test for a Reduced Model

There is no longer a requirement that the coefficients for any categorical effect sum to 0 as there was in PROC SURVEYREG. We simply omit the coefficient for the reference category in the CONTRAST statement specification.

Also, recall any effect not listed is assigned a contrast coefficient(s) of 0.

```sas
*** Program 6.2;
proc surveylogistic data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class SEX RACER MAJOR / param=ref;
  model MED (event='1') = SEX RACER MAJOR
                          AGE TOTCHRON TIMEMD;
weight PATWT;
contrast 'Test of Reduced Model‘
  SEX 1,
  AGE 1,
  TIMEMD 1;
run;
```

STAT674 – GMU – Lewis

27

<!-- page 28 -->

# PROC SURVEYLOGISTIC Syntax to Test for a Reduced Model (2)

**Contrast Test Results**

| Contrast | DF | Wald Chi-Square | Pr > ChiSq |
| :--- | :---: | :---: | :---: |
| Test of Reduced Model | 3 | 3.4495 | 0.3274 |

As of SAS Version 9.4, PROC SURVEYLOGISTIC does not adjust the $F$ statistic per the recommendation of Korn and Graubard (1990). In fact, it doesn't even report an $F$ statistic. It reports the $W$ statistic discussed earlier.

To get to $F_{ADJ}$, we would need to find

$$
F_{ADJ} = \frac{W}{q} \times \frac{(df - q + 1)}{df} = \frac{3.4495}{3} \times \frac{(552 - 3 + 1)}{552} = 1.1457
$$

which has a $p$ value of 0.66 based on a reference $F$ distribution with $q = 3$ numerator and $df - q + 1 = 552 - 3 + 1 = 550$ denominator degrees of freedom $\rightarrow$ same conclusion, though: all terms can safely be dropped from model.

---
STAT674 – GMU – Lewis
28

<!-- page 29 -->

# Customizing Odds Ratios

Just like we compared the mean outcome for two covariate profiles in the linear regression context, we might want to compare odds ratios for two covariate profiles in the logistic regression context.

PROC SURVEYLOGISTIC outputs a series of odds ratios by default. For continuous variables, the odds ratio represents two cases one-unit apart; for categorical variables, the odds ratio represents a case in the $k^{\text{th}}$ level relative to the reference category. Remember, these are just the exponentiated parameter estimates, which you can request be output by specifying the option EXPB after the slash in the MODEL statement.

**Odds Ratio Estimates**

| Effect | | Point Estimate | 95% Wald Confidence Limits | |
| :--- | :--- | :---: | :---: | :---: |
| **SEX** | **1 vs 2** | 1.018 | 0.935 | 1.109 |
| **RACER** | **1 vs 3** | 1.622 | 1.126 | 2.336 |
| **RACER** | **2 vs 3** | 2.006 | 1.353 | 2.973 |
| **MAJOR** | **1 vs 5** | 1.419 | 1.199 | 1.680 |
| **MAJOR** | **2 vs 5** | 1.753 | 1.388 | 2.213 |
| **MAJOR** | **3 vs 5** | 1.571 | 1.280 | 1.927 |
| **MAJOR** | **4 vs 5** | 0.450 | 0.357 | 0.568 |
| **AGE** | | 1.003 | 1.000 | 1.006 |
| **TOTCHRON** | | 1.191 | 1.146 | 1.238 |
| **TIMEMD** | | 0.999 | 0.994 | 1.004 |

STAT674 – GMU – Lewis

29

<!-- page 30 -->

# Customizing Odds Ratios (2)

While the odds ratios reported on the previous slide can be useful, we might also want to find customized odds ratios. For example, we cannot use the summary on the last slide to get an odds ratio for MAJOR=2 versus MAJOR=3. As another example, what if we wanted to compare an odds ratio for two cases 3 units apart with respect to a continuous predictor variable?

PROC LOGISTIC has the ODDSRATIO statement, which can be a really handy tool, but as of now it is not available in PROC SURVEYLOGISTIC. But we can use the CONTRAST statement just the same.

The general strategy is as follows:

1. Express the two logits in terms of the betas.
2. Subtract one from the other, and reduce/cancel terms.
3. Specify the remaining terms and their coefficients in a CONTRAST statement.

---

STAT674 – GMU – Lewis 30

<!-- page 31 -->

# Customizing Odds Ratios: Example with TOTCHRON

As a simple example, suppose we wanted to find the odds ratio for medication being prescribed for two cases equivalent for everything except the first having three more chronic conditions than the second.

Logit for Case 1: $\hat{l}_1 = \hat{B}_0 + \hat{B}_{sex}x_{sex,i} + \hat{B}_{age}x_{age,i} + \hat{B}_{race1}x_{race1,i} + \hat{B}_{race2}x_{race2,i}$

$$
\begin{aligned}
&\hat{B}_{maj1}x_{maj1,i} + \hat{B}_{maj2}x_{maj2,i} + \hat{B}_{maj3}x_{maj3,i} + \hat{B}_{maj4}x_{maj4,i} + \\
&\hat{B}_{timemd}x_{timemd,i} + \hat{B}_{totchron}(x_{totchron,i} + 3)
\end{aligned}
$$

Logit for Case 2: $\hat{l}_2 = \hat{B}_0 + \hat{B}_{sex}x_{sex,i} + \hat{B}_{age}x_{age,i} + \hat{B}_{race1}x_{race1,i} + \hat{B}_{race2}x_{race2,i}$

$$
\begin{aligned}
&\hat{B}_{maj1}x_{maj1,i} + \hat{B}_{maj2}x_{maj2,i} + \hat{B}_{maj3}x_{maj3,i} + \hat{B}_{maj4}x_{maj4,i} + \\
&\hat{B}_{timemd}x_{timemd,i} + \hat{B}_{totchron}x_{totchron,i}
\end{aligned}
$$

After subtracting the second logit from the first, all that remains is 3 times the parameter estimate for TOTCHRON…

---
STAT674 – GMU – Lewis
31

<!-- page 32 -->

# Customizing Odds Ratios: Example with TOTCHRON (2)

CONTRAST statement below estimates logit difference ($0.5581$) and tests whether it is significantly different from $0$—or, equivalent, whether the odds ratio ($1.7474$) is significantly different from $1$. As judged by the low $p$ value, these values are significant. Note that the ESTIMATE=BOTH option outputs both results (default output is only $W$ statistic and associated $p$ value).

```sas
*** Program 6.6;
proc surveylogistic data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class RACER MAJOR / param=ref;
  model MED (event='1') = RACER MAJOR
                          TOTCHRON;
weight PATWT;
contrast 'TOTCHRON + 3' TOTCHRON 3 / estimate=both;
run;
```

### Contrast Estimation and Testing Results by Row

| Contrast | Type | Row | Estimate | Standard Error | Alpha | Confidence | Limits | Wald Chi-Square | Pr > ChiSq |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **TOTCHRON + 3** | **PARM** | 1 | 0.5581 | 0.0584 | 0.05 | 0.4436 | 0.6727 | 91.1766 | <.0001 |
| **TOTCHRON + 3** | **EXP** | 1 | 1.7474 | 0.1021 | 0.05 | 1.5582 | 1.9595 | 91.1766 | <.0001 |

---

STAT674 – GMU – Lewis

32

<!-- page 33 -->

# Customizing Odds Ratios: More Complex Example

As another example, returning to original “full” model, suppose we wanted to find the odds ratio for medication being prescribed for two cases: one for a 77-year-old white male with 2 chronic conditions visiting the doctor for reason MAJOR=2 who spent 15 minutes with the doctor, and another for a 53-year-old man with 4 chronic conditions visiting the doctor for reason MAJOR=4 who spent 8 minutes with the doctor.

Logit for Case 1: $\hat{l}_1 = \hat{B}_0 + \hat{B}_{age}(77) + \hat{B}_{race1} + \hat{B}_{maj2} + \hat{B}_{timemd}(15) + \hat{B}_{totchron}(2)$

Logit for Case 2: $\hat{l}_2 = \hat{B}_0 + \hat{B}_{age}(53) + \hat{B}_{race1} + \hat{B}_{maj4} + \hat{B}_{timemd}(8) + \hat{B}_{totchron}(4)$

After subtracting the second logit from the first:

$$
\hat{l}_1 - \hat{l}_2 = \hat{B}_{age}(24) + \hat{B}_{maj2} - \hat{B}_{maj4} + \hat{B}_{timemd}(7) + \hat{B}_{totchron}(-2)
$$

STAT674 – GMU – Lewis

33

<!-- page 34 -->

# Customizing Odds Ratios: More Complex Example (2)

CONTRAST statement below estimates logit difference (1.0703) and tests whether it is significantly different from 0—or, equivalent, whether the odds ratio (2.9162) is significantly different from 1. Both are significant.

```
proc surveylogistic data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class SEX RACER MAJOR / param=ref;
  model MED (event='1') = SEX RACER MAJOR
                          AGE TOTCHRON TIMEMD;
  weight PATWT;
  contrast 'Custom Odds Ratio'
           AGE 24
           MAJOR 0 1 0 -1
           TIMEMD 7
           TOTCHRON -2 / estimate=both;
run;
```

**Contrast Estimation and Testing Results by Row**

| Contrast | Type | Row | Estimate | Standard Error | Alpha | Confidence | Limits | Wald Chi-Square | Pr > ChiSq |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Custom Odds Ratio** | **PARM** | **1** | **1.0703** | **0.1249** | **0.05** | **0.8255** | **1.3151** | **73.4110** | **<.0001** |
| **Custom Odds Ratio** | **EXP** | **1** | **2.9162** | **0.3643** | **0.05** | **2.2829** | **3.7252** | **73.4110** | **<.0001** |

---
STAT674 – GMU – Lewis 34
