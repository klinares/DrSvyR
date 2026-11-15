---
id: "jpsm/complex_sample_data_SURV701/labs/Module_9_SAS_supplement"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lab"
title: "Module #4: Linear Regression with Survey Data"
original: "complex_sample_data_SURV701/labs/Module_9_SAS_supplement.pdf"
pages: 32
sha256: "be2fa87199103eb259136fb3a110cf7080894089d3a20547cc824ac2b76d1812"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:48"
---

<!-- page 1 -->

# Module #4: Linear Regression with Survey Data

In this module, we review the “traditional” theory for fitting and interpreting linear regression models, that which assumes data have been collected via simple random sampling. Then we discuss the nuances introduced by complex survey data. An emphasis is placed on matrix algebra to estimate parameters and to test whether models can be reduced by eliminating parameters. The notation and execution generalizes to other linear model settings.

Examples highlight the functionality of PROC SURVEYREG, making use of data from the 2010 National Ambulatory Medical Survey (NAMCS), a nationwide survey of physician visits sponsored by the National Center for Health Statistics.

---
STAT674 – GMU – Lewis 1

<!-- page 2 -->

# Traditional Linear Regression

Linear regression is a tool for relating one or more explanatory, or predictor, variables ($x$'s) to a continuous outcome variable $y$. (With only one predictor, it's called *simple linear regression*.) Regression models enable us to estimate the impact of a particular variable on the expected value of an outcome variable while simultaneously accounting for other covariates. Visually, the notion is to fit a line of best fit to data, such as:

---

STAT674 – GMU – Lewis

2

<!-- page 3 -->

# Traditional Linear Regression (2)

While there are various criteria for the line of “best fit,” a popular strategy is to find the line that minimizes the sum of the squared vertical distances between data points and the line. The resulting line is called the *least squares regression line*, and for the single predictor case illustrated on previous slide, the regression line equation might look something like

$$
y_i = \beta_0 + \beta_1 x_i + \varepsilon_i
$$

where $\beta_0$ represents the intercept, or expected value of $y$ when $x = 0$, and $\beta_1$ represents the slope of the regression line, or expected change in $y$ given a one-unit increase in $x$.

Collectively, the beta terms are called *model parameters* or *coefficients*. The term $\varepsilon_i$ represents a *residual*, or the deviation of the observed value from the regression line.

STAT674 – GMU – Lewis 3

<!-- page 4 -->

# Mean Squared Error of the Model

A critical assumption in least squares regression theory is that the residuals are i.i.d. with a constant variance, $\sigma_\varepsilon^2$, called the *mean squared error* (MSE) of the model. A measure of model precision, the MSE can be interpreted as the average squared $\varepsilon_i$, the average square distance between the $y_i$'s and the regression line.

The constant variance assumption means that if we were to plot the residuals along the $y$-axis as a function of the predicted values, there would be no decipherable pattern(s). Figure to the right illustrates three example violations.

STAT674 – GMU – Lewis

4

<!-- page 5 -->

# Estimating Simple Linear Regression Parameters

Given a simple random sample of size $n$, we can estimate the simple linear regression model parameters by

$$\hat{\beta}_1 = \frac{\sum_{i=1}^{n} (x_i - \hat{\bar{x}})(y_i - \hat{\bar{y}})}{\sum_{i=1}^{n} (x_i - \hat{\bar{x}})^2} \quad \text{and} \quad \hat{\beta}_0 = \hat{\bar{y}} - \hat{\beta}_1 \hat{\bar{x}}$$

The MSE can be estimated as $\hat{\sigma}_{\varepsilon}^2 = \frac{\sum_{i=1}^{n} (y_i - \hat{y}_i)^2}{n - 2}$

where $\hat{y}_i = \hat{\beta}_0 + \hat{\beta}_1 x_i$ and the denominator is technically $n - p$, where $p$ is the number of parameters in the model ($p = 2$ in SLR setting).

---

STAT674 – GMU – Lewis

5

<!-- page 6 -->

# Estimating Parameters with Matrix Algebra

Alternatively, we can estimate model parameters by defining $\mathbf{X}$, the *design matrix*, and $\mathbf{Y}$, the *outcome vector* as follows:

$$
\mathbf{X} = \begin{bmatrix} 1 & x_1 \\ 1 & x_2 \\ \cdot & \cdot \\ \cdot & \cdot \\ \cdot & \cdot \\ 1 & x_n \end{bmatrix} \qquad \qquad \mathbf{Y} = \begin{bmatrix} y_1 \\ y_2 \\ \cdot \\ \cdot \\ \cdot \\ y_n \end{bmatrix}
$$

and then find $\hat{\boldsymbol{\beta}} = (\mathbf{X}^{\mathbf{T}}\mathbf{X})^{-1}\mathbf{X}^{\mathbf{T}}\mathbf{Y}$, which is a 2 x 1 vector where the first row is the estimated intercept and the second row is the estimated slope. (If model has no intercept, the first column of 1’s can be dropped.)

So the model can be written in terms of matrices: $\mathbf{Y} = \mathbf{X}\hat{\boldsymbol{\beta}} + \mathbf{e}$, where $\mathbf{e}$ is an $n$ x 1 vector of residuals.

---
STAT674 – GMU – Lewis 6

<!-- page 7 -->

# Parameterizing Categorical Variable Effects

Suppose one is analyzing results from a clinical trial of $n = 6$ patients, where four patients were randomly assigned to a treatment group and two were assigned to a control group receiving no treatment. The treatment effect can be parameterized as a single 0/1 indicator variable, where a case is coded as 1 if part of the treatment group and 0 if part of the control group. If the first four cases in the data set correspond to the treatment group, the design matrix would be defined as

$$\mathbf{X}_1 = \begin{bmatrix} 1 & 1 \\ 1 & 1 \\ 1 & 1 \\ 1 & 1 \\ 1 & 0 \\ 1 & 0 \end{bmatrix}$$

STAT674 – GMU – Lewis

7

<!-- page 8 -->

# Parameterizing Categorical Variable Effects (2)

Now suppose the four patients in the treatment group actually received one of two treatments: two individuals received Treatment A and two received Treatment B. This converts a binomial predictor variable setting into a trinomial predictor. To account for the third category, we must append an additional indicator variable column to the design matrix as follows:

$$
\mathbf{X}_2 = \begin{bmatrix} 1 & 1 & 0 \\ 1 & 1 & 0 \\ 1 & 0 & 1 \\ 1 & 0 & 1 \\ 1 & 0 & 0 \\ 1 & 0 & 0 \end{bmatrix}
$$

Generally speaking, when a categorical predictor consists of $K$ classes or levels, we need to construct $(K - 1)$ indicator variables to exploit the *reference parameterization* of categorical variable effects – SAS will do this for us when we specify the variable in the CLASS statement of PROC SURVEYREG.

---
STAT674 – GMU – Lewis 8

<!-- page 9 -->

# Parameterizing Categorical Variable Effects (3)

Given a $6 \times 1$ outcome vector $\mathbf{Y}$, the design matrix $\mathbf{X}_1$ in the first parameterization results in $(\mathbf{X}_1^T\mathbf{X}_1)^{-1}\mathbf{X}_1^T\mathbf{Y}$, which is a $2 \times 1$ matrix of “beta hats” where the first row represents the mean of the control group, the average outcome for cases having $x_i = 0$, the second row represents the treatment effect, or the average change in the outcome variable transitioning from $x_i = 0$ to $x_i = 1$. The sum of the two beta terms would represent the average outcome of the treatment group.

Under the second parameterization using the design matrix $\mathbf{X}_2$, $(\mathbf{X}_2^T\mathbf{X}_2)^{-1}\mathbf{X}_2^T\mathbf{Y}$ is a $3 \times 1$ vector. The term associated with the first row is the mean outcome for the control group, It represents the mean of $y$ where both treatment indicator variables are zero. The term in the second row can be interpreted as the expected change in the outcome attributable to Treatment A relative to the control, and the term corresponding to the third row is the like for Treatment B. The difference between these two parameters is an estimate of the mean change in the outcome between Treatment A and B.

STAT674 – GMU – Lewis 9

<!-- page 10 -->

# Model Parameter Covariance Matrix

Another important piece to any model is the estimated $p$ x $p$ *model parameter covariance matrix*, defined as

$$\text{cov}(\hat{\boldsymbol{\beta}}) = \hat{\sigma}_\varepsilon^2 (\mathbf{X}^\text{T}\mathbf{X})^{-1}$$

which, for the simple linear regression case, produces a matrix that looks like

$$\text{cov}(\hat{\boldsymbol{\beta}}) = \begin{bmatrix} \text{var}(\hat{\beta}_0) & \text{cov}(\hat{\beta}_0, \hat{\beta}_1) \\ \text{cov}(\hat{\beta}_0, \hat{\beta}_1) & \text{var}(\hat{\beta}_1) \end{bmatrix}$$

In general, entries along the diagonal are the estimated variances for the $p$ model parameters, while off-diagonal entries are covariances between two particular model parameters. The $p(p - 1)/2$ distinct covariances are symmetric about the diagonal.

---
STAT674 – GMU – Lewis 10

<!-- page 11 -->

# Hypothesis Testing of Regression Coefficients

The model parameter covariance matrix can be used to test hypotheses about the regression model parameters, such as whether two or more are equivalent, or whether any are not significantly different from $0$ and could therefore be dropped from the model.

For example, we may wish to test $H_0\text{: } \beta_j = 0$ vs. $H_1\text{: } \beta_j \neq 0$ for some $j$. Most software will automatically carry out these tests and output results alongside the listing of estimated model parameters. The test statistic is

$$t = \hat{\beta}_j / \sqrt{\text{var}(\hat{\beta}_j)}$$

which is referenced against the $100(1 - \alpha/2)^{\text{th}}$ percentile of a $t$ distribution with $n - p$ degrees of freedom. If greater than that value, the null hypothesis is rejected.

---
STAT674 – GMU – Lewis  
11

<!-- page 12 -->

# Hypothesis Testing of Regression Coefficients (2)

Alternatively, parameter-specific tests can be conducted using matrix algebra.

For example, suppose that the model at hand is

$$
y_i = \beta_0 + \beta_1 x_i + \varepsilon_i
$$

and we have used the sample data to estimate $\hat{\boldsymbol{\beta}} = \begin{bmatrix} \hat{\beta}_0 \\ \hat{\beta}_1 \end{bmatrix}$

We can test $H_0: \beta_1 = 0$ vs. $H_1: \beta_1 \neq 0$ by defining the contrast vector $\mathbf{C} = \begin{bmatrix} 0 \\ 1 \end{bmatrix}$

then finding

$$
F = (\mathbf{C}^\mathbf{T}\hat{\boldsymbol{\beta}})^\mathbf{T}(\mathbf{C}^\mathbf{T}\mathbf{cov}(\hat{\boldsymbol{\beta}})\mathbf{C})^{-1}(\mathbf{C}^\mathbf{T}\hat{\boldsymbol{\beta}})
$$

which is a scalar that can be referenced against an $F$ distribution with 1 numerator degree of freedom and $n - 2$ denominator degrees of freedom. If the test statistic exceeds that value, the null hypothesis is rejected.

---

STAT674 – GMU – Lewis 12

<!-- page 13 -->

# Multi-Parameter Hypothesis Testing

The technique generalizes to multi-column contrast matrices as follows:

$$F = (\mathbf{C}^\mathbf{T}\hat{\boldsymbol{\beta}})^\mathbf{T}(\mathbf{C}^\mathbf{T}\mathbf{cov}(\hat{\boldsymbol{\beta}})\mathbf{C})^{-1}(\mathbf{C}^\mathbf{T}\hat{\boldsymbol{\beta}})/\text{rank}(\mathbf{C})$$

where $\text{rank}(\mathbf{C})$ denotes the number of linearly independent columns of the contrast matrix $\mathbf{C}$.

Continuing with the clinical trial example with two treatments, suppose the full model is

$$y_i = \beta_0 + \beta_1 x_{1i} + \beta_2 x_{2i} + \varepsilon_i$$

and we want to test $H_0: \beta_1 = 0, \beta_2 = 0$ vs. $H_1: \beta_1 \neq 0, \beta_2 \neq 0$.

In other words, we want to test whether both treatment effects are simultaneously indistinguishable from the control…

STAT674 – GMU – Lewis 13

<!-- page 14 -->

# Multi-Parameter Hypothesis Testing (2)

To test this new hypothesis, we can augment the contrast matrix with an additional column by constructing

$$\mathbf{C} = \begin{bmatrix} 0 & 0 \\ 1 & 0 \\ 0 & 1 \end{bmatrix}$$

The structure of the $F$ test is still the same, and still produces a scalar, only now $\text{rank}(\mathbf{C}) = 2$, and so the test statistic is referenced against an $F$ distribution with $2$ numerator degrees of freedom. The denominator degrees of freedom is still $n - p$.

These are just a few example parameter tests. Sticking with the same model on previous slide, what would we be testing with the following?

$$\mathbf{C} = \begin{bmatrix} 0 \\ 1 \\ -1 \end{bmatrix}$$

---
STAT674 – GMU – Lewis 14

<!-- page 15 -->

# Hypothesis Testing with an ANOVA Table

In the case of linear regression models, another way to test whether a model can be reduced is to use components of an *analysis of variance* (ANOVA) table.

| Source | Sum of Squares | Degrees of Freedom | Mean of Squares | F |
| :--- | :--- | :---: | :--- | :---: |
| Model | $\text{SSM} = \sum_{i=1}^n (\hat{y}_i - \hat{\bar{y}})^2$ | $p - 1$ | $\text{MSM} = \text{SSM}/(p - 1)$ | $\text{MSM}/\text{MSE}$ |
| Error | $\text{SSE} = \sum_{i=1}^n (y_i - \hat{y}_i)^2$ | $n - p$ | $\text{MSE} = \text{SSE}/(n - p)$ | |
| Total | $\text{SST} = \sum_{i=1}^n (y_i - \hat{\bar{y}})^2$ | $n - 1$ | | |

For example, the $F$ test reported in an ANOVA table is the test for whether the model can be reduced to an intercept-only model.

STAT674 – GMU – Lewis

15

<!-- page 16 -->

# Hypothesis Testing with an ANOVA Table (2)

Note that each additional variable incorporated into a linear regression model will reduce the SSE. So if we denote the residual sum of squares for the full model $\text{SSE}_{\text{full}}$ and the same quantity for the reduced model $\text{SSE}_{\text{red}}$, we know that $\text{SSE}_{\text{full}} < \text{SSE}_{\text{red}}$.

To assess the importance of one or more variables in the model, we can evaluate whether the residual sum of squares is substantively reduced by its inclusion. This line of reasoning forms the basis of the following general $F$ test for simplifying a model:

$$
F = \frac{(\text{SSE}_{\text{red}} - \text{SSE}_{\text{full}})/q}{\hat{\sigma}^2_{\varepsilon(\text{full})}}
$$

where $q$ is the number of parameters dropped and the sigma squared term is the MSE of the full model, which can be referenced against an $F$ distribution with $q$ and $n - p$ numerator and denominator degrees of freedom, respectively.

STAT674 – GMU – Lewis 16

<!-- page 17 -->

# Linear Regression with Survey Data

In addition to violating many of the underlying assumptions of traditional least square regression, model parameters have a subtly different interpretation, which is often reflected in the literature by denoting them with a Roman letter such as a $B_0$ or $B_1$ as opposed to a Greek letter.

The finite population parameters of a simple linear regression model can be estimated by

$$
\hat{B}_1 = \frac{\sum_{i=1}^{n} w_i (x_i - \hat{\bar{x}}_w)(y_i - \hat{\bar{y}}_w)}{\sum_{i=1}^{n} w_i (x_i - \hat{\bar{x}}_w)^2} \qquad \text{and} \qquad \hat{B}_0 = \hat{\bar{y}}_w - \hat{B}_1 \hat{\bar{x}}_w
$$

where the $w_i$ is the survey weight for the $i^\text{th}$ sampling unit and the “w” subscript indicates a weighted mean.

STAT674 – GMU – Lewis

17

<!-- page 18 -->

# Linear Regression with Survey Data (2)

The estimated parameters in the previous slide are referred to as *weighted least squares estimates*.

For example, $\hat{B}_1$ estimates $B_1 = \frac{\sum_{i=1}^{N}(x_i - \bar{x})(y_i - \bar{y})}{\sum_{i=1}^{N}(x_i - \bar{x})^2}$, which can be thought of as the

slope coefficient that would be computed if we had data for the entire population.

Of course, we can also use matrix algebra. After defining the design matrix $\mathbf{X}$ the $n \times 1$ outcome vector $\mathbf{Y}$ in the same manner discussed earlier, we can compute

$$\hat{\mathbf{B}} = (\mathbf{X}^{\mathbf{T}}\mathbf{W}\mathbf{X})^{-\mathbf{1}}\mathbf{X}^{\mathbf{T}}\mathbf{W}\mathbf{Y}$$

where $\mathbf{W}$ is an $n \times n$ diagonal matrix of weights ($w_i$'s)

STAT674 – GMU – Lewis 18

<!-- page 19 -->

# Linear Regression with Survey Data (3)

The model parameter covariance matrix can be estimated using a multivariate generalization of Taylor series linearization:

$$
\text{cov}(\hat{\mathbf{B}}) = (\mathbf{X}^{\mathbf{T}}\mathbf{W}\mathbf{X})^{-\mathbf{1}}\,\text{var}(\sum_{i=1}^n w_i\mathbf{u}_{\mathbf{i}})(\mathbf{X}^{\mathbf{T}}\mathbf{W}\mathbf{X})^{-\mathbf{1}}
$$

where $\mathbf{u}_{\mathbf{i}} = \mathbf{x}_{\mathbf{i}}(y_i - \mathbf{x}_{\mathbf{i}}\hat{\mathbf{B}})$ and $\mathbf{x}_{\mathbf{i}}$ is the $i^{\text{th}}$ row of the design matrix.

Note: all three SURVEY procedures with modeling capabilities (PROC SURVEYREG, PROC SURVEYLOGISTIC, and PROC SURVEYPHREG) apply the adjustment factor $(n - 1)/(n - p)$ when estimating the model parameter covariance matrix based on a recommendation by Hidiroglou et al. (1980) to reduce bias that can occur in small samples. If you do not want this adjustment factor to be used, specify VADJUST=NONE after the slash in the MODEL statement.

---
STAT674 – GMU – Lewis  
19

<!-- page 20 -->

# Testing for a Reduced Model in Linear Regression with Survey Data

As before, to test whether a linear regression model can be reduced, we can construct a contrast vector/matrix $\mathbf{C}$ and then find

$$
F = (\mathbf{C}^\mathbf{T}\hat{\mathbf{B}})^\mathbf{T}(\mathbf{C}^\mathbf{T}\mathbf{cov}(\hat{\mathbf{B}})\mathbf{C})^{-1}(\mathbf{C}^\mathbf{T}\hat{\mathbf{B}}) / \mathrm{rank}(\mathbf{C})
$$

where $\mathrm{rank}(\mathbf{C})$ is the number of linearly independent columns of $\mathbf{C}$.

However, this test statistic may not abide by the distribution assumed under the null hypothesis. Korn and Graubard (1990) suggest the modified test statistic

$$
F_{ADJ} = F \times \frac{df - q + 1}{df}
$$

where $F$ is the original test statistic, $df$ is the complex survey degrees of freedom (#PSUs - #strata), and $q$ is the number of parameters dropped. $F_{ADJ}$ can then be referenced against an $F$ distribution with $q$ and $df - q + 1$ degrees of freedom for the numerator and denominator, respectively.

STAT674 – GMU – Lewis

20

<!-- page 21 -->

# Example Using 2010 NAMCS

Suppose a health researcher wants to model the average time spent with the physician as a function of the patient’s gender, age, race, primary reason for the visit, the total number of chronic conditions afflicting the patient, whether any medication was prescribed or renewed, and whether the physician practices alone.

The 2010 NAMCS data has three features of complex survey data:

1. Stratification – distinct codes of the variable CSTRATM
2. Clustering – distinct codes of the variable CPSUM
3. Unequal Weights – variable PATWT

There are a total of 626 unique PSUs amongst 74 strata, which means there are $626 - 74 = 552$ complex survey degrees of freedom.

---
STAT674 – GMU – Lewis

21

<!-- page 22 -->

# Variable Summary for NAMCS 2010 Model

| Variable Name | Description | Coding Structure |
| :--- | :--- | :--- |
| TIMEMD | Time spent with physician in minutes | Continuous |
| MED | Indicator of medication prescribed or renewed | 0 = No<br>1 = Yes |
| SEX | Patient gender | 1 = Female<br>2 = Male |
| AGE | Patient age in years | Continuous |
| RACER | Patient race | 1 = White<br>2 = Black<br>3 = Other |
| TOTCHRON | Patient’s total number of chronic conditions | Integer |
| MAJOR | Primary reason for the visit | 1 = New problem ($<$ 3 months onset)<br>2 = Chronic problem, routine<br>3 = Chronic problem, flare up<br>4 = Pre-/Post-surgery<br>5 = Preventive care (e.g. routine prenatal, screening) |
| SOLO | Indicator of solo physician practice | 1 = Yes<br>2 = No |

STAT674 – GMU – Lewis

22

<!-- page 23 -->

# PROC SURVEYREG Syntax and Output

Syntax below fits the model accounting for the complex survey features. Numeric variables to be treated as categorical are placed in the CLASS statement. If your model includes categorical variables, the SOLUTION option after the slash in the MODEL statement is needed to have the estimated model parameters output.

```sas
*** Program 5.1;
proc surveyreg data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class MED SEX RACER SOLO MAJOR;
  model TIMEMD = MED SEX RACER
                 SOLO MAJOR
                 AGE TOTCHRON /
                 solution;
weight PATWT;
run;
```

**Class Level Information**

| CLASS Variable | Levels | Values |
| :--- | :---: | :--- |
| **MED** | 2 | 0 1 |
| **SEX** | 2 | 1 2 |
| **RACER** | 3 | 1 2 3 |
| **SOLO** | 2 | 1 2 |
| **MAJOR** | 5 | 1 2 3 4 5 |

---

STAT674 – GMU – Lewis

23

<!-- page 24 -->

# PROC SURVEYREG Syntax and Output (2)

Estimated model parameters and $t$ tests for $H_0: B_j = 0$ vs. $H_1: B_j \neq 0$ for $j = 1, \dots, p$:

### Regression Analysis for Dependent Variable TIMEMD

#### Estimated Regression Coefficients

| Parameter | Estimate | Standard Error | t Value | Pr > \|t\| |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | 19.1261704 | 1.11637316 | 17.13 | <.0001 |
| MED 0 | 0.0876849 | 0.45899764 | 0.19 | 0.8486 |
| MED 1 | 0.0000000 | 0.00000000 | . | . |
| SEX 1 | -0.0114210 | 0.27513318 | -0.04 | 0.9669 |
| SEX 2 | 0.0000000 | 0.00000000 | . | . |
| RACER 1 | 0.2436353 | 1.08408259 | 0.22 | 0.8223 |
| RACER 2 | -0.6642309 | 1.18409324 | -0.56 | 0.5751 |
| RACER 3 | 0.0000000 | 0.00000000 | . | . |
| SOLO 1 | 1.2315973 | 0.80516484 | 1.53 | 0.1267 |
| SOLO 2 | 0.0000000 | 0.00000000 | . | . |
| MAJOR 1 | -0.7737222 | 0.59559493 | -1.30 | 0.1945 |
| MAJOR 2 | -0.8589240 | 0.77258999 | -1.11 | 0.2667 |
| MAJOR 3 | 0.6710944 | 0.81024046 | 0.83 | 0.4079 |
| MAJOR 4 | -3.6219092 | 0.87574082 | -4.14 | <.0001 |
| MAJOR 5 | 0.0000000 | 0.00000000 | . | . |
| AGE | 0.0216502 | 0.01195026 | 1.81 | 0.0706 |
| TOTCHRON | 0.3639201 | 0.09893484 | 3.68 | 0.0003 |

STAT674 – GMU – Lewis

24

<!-- page 25 -->

# PROC SURVEYREG Syntax and Output (3)

PROC SURVEYREG also outputs a series of $F$ tests: one for the overall model and one for each “effect,” a single parameter for a continuous predictor variable or the set of $K - 1$ parameters associated with a categorical variable consisting of $K$ distinct levels. The single parameter version assigns $\mathbf{C}$ as a $p \times 1$ vector of zeros for all rows except that corresponding to the given parameter, which is assigned a value of 1. For a categorical variable, $\mathbf{C}$ is a $p \times (K - 1)$ vector consisting of a separate column for each level of the categorical variable constructed in the same manner.

Notice how for single parameters the $F$ statistic is the squared $t$ statistic seen on last slide.

**Tests of Model Effects**

| Effect | Num DF | F Value | Pr > F |
| :--- | ---: | ---: | ---: |
| Model | 11 | 5.20 | <.0001 |
| Intercept | 1 | 824.94 | <.0001 |
| MED | 1 | 0.04 | 0.8486 |
| SEX | 1 | 0.00 | 0.9669 |
| RACER | 2 | 1.11 | 0.3294 |
| SOLO | 1 | 2.34 | 0.1267 |
| MAJOR | 4 | 7.84 | <.0001 |
| AGE | 1 | 3.28 | 0.0706 |
| TOTCHRON | 1 | 13.53 | 0.0003 |

STAT674 – GMU – Lewis

25

<!-- page 26 -->

# Testing for a Reduced Model

Scrutinizing the model parameter summary, we can observe that none of the effects attributable to medication being prescribed or renewed (MED), patient gender (SEX), or patient race (RACER) are even marginally significant.

Suppose we wanted to determine whether all terms related to those three effects can be removed from the model. We can do this via a general $F$ test using the CONTRAST statement in PROC SURVEYREG.

Our main concern is to properly populate the contrast matrix $\mathbf{C}$ with *contrast coefficients*. We name the effect and then provide the coefficient(s) immediately afterwards. For a continuous effect, one value is sufficient, but $K$ values are needed for categorical variable effects with $K$ distinct levels. Any effect not explicitly listed is given a value of 0.

---

STAT674 – GMU – Lewis

26

<!-- page 27 -->

# PROC SURVEYREG Syntax to Test for a Reduced Model

Because there is a requirement that the coefficients for any categorical effect sum to 0, we must assign a coefficient of -1 to the dropped indicator variable, which happens to be the last in the sort-ordered list of values.

Note that any effect not listed is assigned a contrast coefficient(s) of 0. Also, the contrast matrix is not output by default, but you can specify the option E after the slash in the CONTRAST statement to have it printed to the listing – good idea when the model or contrast is complex, such as one involving interactions.

```sas
*** Program 5.2;
proc surveyreg data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class MED SEX RACER SOLO MAJOR;
  model TIMEMD = MED SEX RACER
                 SOLO MAJOR
                 AGE TOTCHRON /
                 solution;
  weight PATWT;
  contrast 'Test of Reduced Model'
           MED 1 -1,
           SEX 1 -1,
           RACER 1 0 -1,
           RACER 0 1 -1;
run;
```

STAT674 – GMU – Lewis

27

<!-- page 28 -->

# PROC SURVEYREG Syntax to Test for a Reduced Model (2)

**Analysis of Contrasts**

| Contrast | Num DF | F Value | Pr > F |
| :--- | :---: | :---: | :---: |
| Test of Reduced Model | 4 | 0.57 | 0.6832 |

The null hypothesis of this test states all model parameters associated with MED, SEX, and RACER are jointly equal to zero. Since the $p$ value associated with this $F$ statistic is large, we fail to reject the null hypothesis. It appears all terms related to these three predictor variables could be safely eliminated from the model.

As of SAS Version 9.4, PROC SURVEYREG does not adjust the $F$ statistic per the recommendation of Korn and Graubard (1990). That is, it reports $F$, not $F_{ADJ}$.

This is inconsequential in the present example since the adjustment factor would be $(df - q + 1)/df = (552 - 4 + 1)/552 \approx 1$, but the discrepancy between the two could be greater for other models and/or sample designs.

STAT674 – GMU – Lewis

28

<!-- page 29 -->

# Estimating the Mean Outcome for Targeted Covariate Profiles

Another popular strategy after fine-tuning the parameters in a regression model is to compute and discuss the expected values for one or more targeted covariate profiles. For instance, one might be interested in comparing the mean time spent with the doctor for a 77-year-old who has one chronic condition visiting a sole practitioner for preventative care relative to a 45-year-old, also with one chronic condition but on a routine visit to a group practitioner related to the chronic condition.

If we define the covariate profile as a $p \text{ x } 1$ vector $\mathbf{L}$, then we can estimate the mean outcome by

$$
\mathbf{L}^\text{T}\hat{\mathbf{B}}
$$

and its variance as

$$
\text{var}(\mathbf{L}^\text{T}\hat{\mathbf{B}}) = \mathbf{L}^\text{T}\text{cov}(\hat{\mathbf{B}})\mathbf{L}
$$

STAT674 – GMU – Lewis

29

<!-- page 30 -->

# Estimating the Mean Outcome for Targeted Covariate Profiles

The ESTIMATE statement in PROC SURVEYREG can be used to compute the quantities in the previous slide (standard error is square root of variance).

```sas
*** Program 5.4;
proc surveyreg data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class SOLO MAJOR;
  model TIMEMD = SOLO MAJOR
                 AGE TOTCHRON;
  weight PATWT;
  estimate 'Case 1'
    INTERCEPT 1 AGE 77 TOTCHRON 1 SOLO 1 0 MAJOR 0 0 0 0 1;
  estimate 'Case 2'
    INTERCEPT 1 AGE 45 TOTCHRON 1 SOLO 0 1 MAJOR 0 1 0 0 0;
run;
```

**Regression Analysis for Dependent Variable TIMEMD**

**Estimate**

| Label | Estimate | Standard Error | DF | t Value | Pr > \|t\| |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Case 1 | 22.5506 | 0.9213 | 552 | 24.48 | <.0001 |

**Estimate**

| Label | Estimate | Standard Error | DF | t Value | Pr > \|t\| |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Case 2 | 19.7455 | 0.4598 | 552 | 42.95 | <.0001 |

STAT674 – GMU – Lewis

30

<!-- page 31 -->

# Estimating the Mean Outcome for Targeted Covariate Profiles

A natural follow-up question is do the two patients’ expected times spent with the doctor differ significantly from one another? (We are actually jumping ahead a bit to the concept of domain mean comparisons, which is covered in more detail in Module #6.) That is, we want to test

$$H_0 : \bar{y}_1 = \bar{y}_2 \text{ vs. } H_1 : \bar{y}_1 \neq \bar{y}_2$$

by comparing

$$t = \frac{\hat{\bar{y}}_1 - \hat{\bar{y}}_2}{\sqrt{\text{var}(\hat{\bar{y}}_1) + \text{var}(\hat{\bar{y}}_2) - 2\text{ cov}(\hat{\bar{y}}_1, \hat{\bar{y}}_2)}}$$

to a student $t$ distribution with #PSUs - #strata = 552 degrees of freedom. By substituting estimated model parameters for the two “y hat” terms, we can exploit the ESTIMATE statement in PROC SURVEYREG to carry out this test.

STAT674 – GMU – Lewis 31

<!-- page 32 -->

# Estimating the Mean Outcome for Targeted Covariate Profiles

In essence, the algebra is just to subtract the two sets of coefficients of $\mathbf{L}$ from the corresponding ESTIMATE statements in Program 5.4. The result below is an estimate of the difference between the two mean outcomes, which appears to be significant.

```sas
*** Program 5.6;
proc surveyreg data=NAMCS_2010;
  strata CSTRATM;
  cluster CPSUM;
  class SOLO MAJOR;
  model TIMEMD = SOLO MAJOR
                 AGE TOTCHRON;
weight PATWT;
estimate 'Case 1 - Case 2' AGE 32 SOLO 1 -1 MAJOR 0 -1 0 0 1;
run;
```

**Regression Analysis for Dependent Variable TIMEMD**

**Estimate**

| Label | Estimate | Standard Error | DF | t Value | Pr > |t| |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Case 1 - Case 2 | 2.8052 | 1.1326 | 552 | 2.48 | 0.0136 |

STAT674 – GMU – Lewis

32
