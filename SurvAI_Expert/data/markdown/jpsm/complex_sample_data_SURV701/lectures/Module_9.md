---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_9"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_9.pdf"
pages: 38
sha256: "4b809efdf2e602b7f304fe559b0b6f6691d2ac9d64b6c6b9259a95940fdcd6ac"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:51"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

SURV/SURVMETH 701

Lecture Notes: Module 9

**Linear Regression for Complex Samples**

Instructor: Yan Li

e-mail: [email]

1

<!-- page 2 -->

# Regression Analysis of Complex Sample Survey Data: What changes?

* **Finite Population Model**
  * Estimate relationships of variables in a <u>**finite**</u> population, using sample data
  * Population itself is a sample from a theoretical <u>**superpopulation**</u>, governed by some regression model
* **Weights**
  * Finite population estimation weights, not necessarily related to residual variance (sampling weights)
  * Weighted least squares (WLS) estimation of parameters <u>works</u>, but estimation of standard errors <u>does not</u>
* **Correlated residuals (within a cluster)**
  * Variance estimation formulas appropriate for stratified cluster samples: Taylor series, Replication methods
  * Overall F-test assumptions do not apply

2

<!-- page 3 -->

# Regression Analysis of Complex Sample Survey Data: What remains the same?

* WLS estimation is computationally the same for parameter estimates

* Residual analysis for checking normality of residuals, homogeneity of variance, model fit
  * <u>Transformations are preferred</u> to WLS for heterogeneity!

* $t$-tests of individual parameters in regression model using correct $\text{SE}(\beta)$

* Wald tests or transformed F-tests of multi-parameter hypotheses

3

<!-- page 4 -->

# Regression Analysis of Survey Data: Finite population approach

$$
y_i = x_i B + e_i
$$

$$
E(y_i | x_i) = \hat{y}_i = x_i B,
$$

where

B is the vector of coefficients in the linear predictor, $\hat{y}_i$, that minimizes the prediction error in the finite survey population

Mean Square Prediction Error

$$
\sum_{i=1}^{N_0} (y_i - \hat{y}_i)^2
$$

4

<!-- page 5 -->

Superpopulation Model

$$y = \beta_0 + \beta_1 x + \varepsilon$$

$N^{(1)}$

$N^{(2)}$

Finite Population 1

$$y_i = B_{0(1)} + B_{1(1)}x_i + e_i$$

$$i = 1, \dots, N^{(1)}$$

Finite Population 2

$$y_j = B_{0(2)} + B_{1(2)}x_j + e_j$$

$$j = 1, \dots, N^{(2)}$$

5

<!-- page 6 -->

# Finite Population Model: Relationship to the “Superpopulation”

* **Superpopulation**: Finite population itself is a sample from a theoretical population satisfying some regression model
* $\beta$ is the **superpopulation parameter** and $B$ is the **finite population parameter**
* Generally, $B = \beta + O(N^{-1/2})$. **Unbiased estimate of $B$ can serve as an unbiased estimate of $\beta$.**
* Model diagnostics can be used to assess (1) the superpopulation model or (2) suitability of $B$ as a summary measure of relationships

6

<!-- page 7 -->

# Estimation of $B$ in Finite Population

* An estimate of $B$ is obtained by minimizing this objective function:

$$\sum_{i=1}^{N_0} (y_i - x_i B)^2$$

* An unbiased estimate of the above total is:

$$\sum_h \sum_c \sum_{i \in sample} w_{hci} (y_{hci} - x_{hci} b)^2$$

* Estimates derived previously for $b$ in WLS minimize the above estimate of the actual objective function

* **<u>Key premise</u>**: To obtain an approximately design-unbiased estimate of $B$, provided there is a need for representing the population with a single regression coefficient

7

<!-- page 8 -->

# Estimation of $B$

$$
B = \frac{\sum_{i=1}^{N_0} y_i x_i}{\sum_{i=1}^{N_0} x_i^2} = \frac{T_{XY}}{T_{X^2}}
$$

estimate this ratio by:

$$
b = \frac{\sum_{i=1}^{n} w_i y_i x_i}{\sum_{i=1}^{n} w_i x_i^2} = \frac{t_{xy}}{t_{x^2}}
$$

8

<!-- page 9 -->

# To Weight or Not To Weight?

* There is generally little debate about the need to use weights for estimation of descriptive parameters (means, proportions, totals, etc.) using survey data
* There is more debate regarding the use of weights when fitting regression models to survey data (see <u>ASDA Ch. 7</u>)
* In the finite population modeling framework, **model specification is important:**
  - Poor specification of a model, when combined with weighted estimation, will result in unbiased estimates of the regression coefficients in a **poor finite population model**
  - Good specification of a model, when combined with weighted estimation, will result in inflated standard errors (no need to use weights if model has been correctly specified!)
  - See Korn and Graubard (1999, Section 4.3) for an example

9

<!-- page 10 -->

# To Weight or Not To Weight?

* **Compare models fitted with and without weights:**
  - Large changes in parameter estimates suggest model misspecification, and that at the very least weights should be used to obtain unbiased estimates
  - Small changes in parameter estimates and large changes in standard errors would suggest appropriate specification, and minimal problems with using unweighted models
  - Some argue to use the weight as an actual covariate in regression models (helps to make the sampling mechanism ignorable; see <u>ASDA Chapter 13</u>)
  - Check sensitivity of results to different approaches!
  - See **Bollen et al. (2016)** on Canvas for further reading about the use of weights when fitting regression models

10

<!-- page 11 -->

# An Alternative Weighting Approach

* Outlined by Pfeffermann (2011); see Canvas
* The “q-weighted” Approach:
  * Regress the final weights on the predictor variables
  * Save the predicted values for the final weights as a function of the predictor variables
  * Divide the final weights by their predicted values
  * Use these adjusted weights in WLS estimation
  * See the illustration in the <u>ASDA Chapter 7</u>
* Pfeffermann (2011) presents simulation results suggesting that this approach yields weighted estimates with improved efficiency

11

<!-- page 12 -->

# Estimating the Variance of $b$

* For stratified cluster sampling, the weighted **sample totals** of $u$ and $v$ (the elements summed in the numerator and denominator) across the strata are used to estimate $B$. <u>If we write the statistic of interest as a function of totals</u>, we can use the Taylor series method of variance estimation, modified to account for clustering and stratification

* A replication method can also be used. Delete a cluster, reweight the remaining clusters in the same strata, refit the regression model. Use the formulas given earlier to compute a JRR variance estimate

* Generate balanced half-samples, fit regression models to half samples. Use the formula given earlier to estimate sampling variance

12

<!-- page 13 -->

# Var($b$): Taylor Series

$$u_i = w_i x_i y_i$$

$$v_i = w_i x_i^2$$

$$b = \frac{\sum_{i=1}^n u_i}{\sum_{i=1}^n v_i}$$

$$var(b) = \frac{var(u) + b^2 var(v) - 2b cov(u, v)}{v^2}$$

13

<!-- page 14 -->

# Hypothesis Testing

Tests of individual coefficients :

$$H_0 : B_j = 0$$

$$t = \frac{b_j - 0}{se(b_j)}$$

under $H_0 \sim \text{Student } t, \text{with } df = \#clusters - H$

14

<!-- page 15 -->

# Overall and Partial F-Tests for Regression: Wald $X^2$

* The analogs to the ordinary least squares (OLS) overall F-test of $H(0)$: $\boldsymbol{\beta}=\mathbf{0}$ and partial F-tests of the form $H(0)$: $\boldsymbol{\beta}_2=\mathbf{0}$, where $\boldsymbol{\beta}_2=\{\beta_j \text{ for } j=1,\dots,p_2\}$, are based on a Wald-type Test Statistic:

$$\text{Overall}: \text{Modified } X_{W,\text{overall}}^2 = \frac{\hat{\boldsymbol{B}}^T \hat{\boldsymbol{\Sigma}}(\hat{\boldsymbol{B}})^{-1} \hat{\boldsymbol{B}}}{p} = F_{W,\text{overall}}$$

$$\text{Partial}: \text{Modified } X_{W,\text{partial}}^2 = \frac{\hat{\boldsymbol{B}}_2^T \hat{\boldsymbol{\Sigma}}(\hat{\boldsymbol{B}}_2)^{-1} \hat{\boldsymbol{B}}_2}{p_2} = F_{W,\text{partial}}$$

$$\begin{aligned} \text{where}: \ & \hat{\boldsymbol{B}}, \hat{\boldsymbol{B}}_2 \text{ are vectors of estimated regression parameters; and} \\ & \hat{\boldsymbol{\Sigma}}(\hat{\boldsymbol{B}}), \hat{\boldsymbol{\Sigma}}(\hat{\boldsymbol{B}}_2) \text{ are the estimated variance / covariance matrices.} \end{aligned}$$

Also $R^2$ is based on survey-weighted sums of squares:

$$R_{\text{weighted}}^2 = 1 - \frac{WSSE}{WSST}$$

15

<!-- page 16 -->

# Wald Tests of Multi-parameter Hypotheses for Complex Sample Survey Data

* In analysis of complex sample survey data, Wald Tests are the primary means of performing multi-parameter tests of hypotheses in linear and generalized linear regression models:

$$X_W^2 = [\boldsymbol{C}\hat{\boldsymbol{B}}]'[\boldsymbol{C}\hat{\boldsymbol{\Sigma}}(\hat{\boldsymbol{B}})\boldsymbol{C}']^{-1}[\boldsymbol{C}\hat{\boldsymbol{B}}] \approx \frac{\text{contrast "squared"}}{\text{variance of contrast}}$$

*where* :

$C$ is a contrast matrix ($\text{p x p}$);

$\hat{\boldsymbol{B}}$ is a ($\text{p x 1}$) vector of parameter estimates; and

$\hat{\boldsymbol{\Sigma}}(\hat{\boldsymbol{B}})$ is a ($\text{p x p}$) variance-covariance matrix for $\hat{\boldsymbol{B}}$.

16

<!-- page 17 -->

# Wald Tests of Multi-parameter Hypotheses for Complex Sample Survey Data

* First, suppose that a specified linear regression model includes three parameters of interest, i.e., $\boldsymbol{B}' = [B_1, B_2, B_3]$. Using this more general framework for the Wald test statistic, if one wished to test the null hypothesis $H_0: B_2 - B_3 = 0$ (or equivalently $H_0: B_2 = B_3$), the $\boldsymbol{C}$ matrix would take the following form:

$$C = \begin{bmatrix} 0 & 0 & 0 \\ 0 & 1 & -1 \\ 0 & 0 & 0 \end{bmatrix}$$

* In Stata, Wald Tests are requested using the **test** post-estimation commands or statements (see below).

17

<!-- page 18 -->

# Software Procedures for Regression Analysis of Survey Data

* **SAS**: PROC SURVEYREG
  – Allows choice of Taylor Series Linearization or Replication for Variance Estimation
* **Stata**: the svy: regress command
  – Allows choice of Taylor Series Linearization or Replication Methods for Variance Estimation
* **IVEware**: %REGRESS
  – Uses Jackknife Repeated Replication for Variance Estimation
* **R**: the svyglm() function
* **WesVar**: the Regression module

18

<!-- page 19 -->

# <u>Example</u>: Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP. Initial Bivariate analysis (Stata)

```stata
gen bpxdi1_1 = bpxdi1
replace bpxdi1_1 = . if bpxdi1 == 0
svyset sdmvpsu [pweight = wtmec2yr], strata(sdmvstra)
svy, subpop(age18p): mean age
gen agec = age-46.36
* bivariate tests
svy, subpop(age18p): regress bpxdi1_1 i.ridreth1
test 2.ridreth1 3.ridreth1 4.ridreth1 5.ridreth1
svy, subpop(age18p): regress bpxdi1_1 i.marcat
test 2.marcat 3.marcat
svy, subpop(age18p): regress bpxdi1_1 i.riagendr
test 2.riagendr
svy, subpop(age18p): regress bpxdi1_1 agec
test agec
```

19

<!-- page 20 -->

# Bivariate Analysis Results

| Predictor Variable | Parameter Estimate (Linearized SE) | Test Statistic | $p$-value |
| :--- | :---: | :---: | :---: |
| **Ethnicity ($n = 5,112$)** | | Wald $F(4,12) = 3.93$ | $0.02$ |
| &emsp; Mexican American | -- | -- | -- |
| &emsp; Other Hispanic | $-0.15\ (1.46)$ | $t(17) = -0.11$ | $0.92$ |
| &emsp; Non-Hispanic White | $2.18\ (0.74)$ | $t(17) = 2.94$ | $< 0.01$ |
| &emsp; Non-Hispanic Black | $2.29\ (0.70)$ | $t(17) = 3.26$ | $< 0.01$ |
| &emsp; Other Race | $1.30\ (0.70)$ | $t(17) = 1.85$ | $0.08$ |
| **Age (Cent.) ($n = 5,112$)** | | Wald $F(1,17) = 4.35$ | $0.05$ |
| | $0.04\ (0.02)$ | $t(17) = 2.09$ | $0.05$ |
| **Gender ($n = 5,112$)** | | Wald $F(1,17) = 15.01$ | $< 0.01$ |
| &emsp; Male | -- | -- | -- |
| &emsp; Female | $-2.20\ (0.57)$ | $t(17) = -3.87$ | $< 0.01$ |
| **Marital Status ($n = 4,578$)** | | Wald $F(2,16) = 0.85$ | $0.45$ |
| &emsp; Married | -- | -- | -- |
| &emsp; Previously Married | $-0.15\ (0.70)$ | $t(17) = -0.21$ | $0.84$ |
| &emsp; Never Married | $-1.12\ (0.84)$ | $t(17) = -1.33$ | $0.20$ |

20

<!-- page 21 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP: Naïve OLS Model (Stata).

```stata
regress bpxdi1_1 i.ridreth1 i.riagendr agec if age18p == 1
```

| Predictor | Parameter Estimate | Standard Error | $t$-statistic ($df$) | $p$-value | 95% CI |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Intercept | 70.78 | 0.55 | 129.20 (5105) | <0.001 | (69.71, 71.86) |
| **Ethnicity** | | | | | |
| Other Hispanic | 0.26 | 0.74 | 0.35 (5105) | 0.730 | (-1.19, 1.70) |
| White | 1.19 | 0.60 | 2.00 (5105) | 0.046 | (0.02, 2.36) |
| Black | 2.20 | 0.62 | 3.58 (5105) | <0.001 | (0.99, 3.41) |
| Other | 2.01 | 0.66 | 3.04 (5105) | 0.002 | (0.72, 3.31) |
| Mexican | -- | -- | -- | -- | -- |
| **Gender** | | | | | |
| Female | -2.40 | 0.33 | -7.25 (5105) | <0.001 | (-3.05, -1.75) |
| Male | -- | -- | -- | -- | -- |
| **Age (Centered)** | 0.04 | 0.01 | 4.58 (5105) | <0.001 | (0.02, 0.06) |

21

<!-- page 22 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP: Adjusting for Complex Sample Design.

<u>Stata Code:</u>

```stata
svyset sdmvpsu [pweight = wtmec2yr],
  strata(sdmvstra)
svy, subpop(age18p): regress bpxdi1_1 i.ridreth1
  i.riagendr agec
estat effects, deff
```

22

<!-- page 23 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP: Adjusting for Complex Design.

| Predictor | Est. | SE | $t$-statistic ($df$) | $p$-value | 95% CI | DEFF |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| Intercept | 71.15 | 0.52 | 137.4 (17) | $< 0.001$ | (70.06, 72.245) | 1.06 |
| **Ethnicity** | | | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Other Hispanic | -0.14 | 1.37 | -0.10 (17) | 0.92 | (-3.04, 2.76) | 3.86 |
| &nbsp;&nbsp;&nbsp;&nbsp;White | 1.90 | 0.81 | 2.35 (17) | 0.03 | (0.20, 3.61) | 2.47 |
| &nbsp;&nbsp;&nbsp;&nbsp;Black | 2.30 | 0.66 | 3.46 (17) | 0.003 | (0.90, 3.70) | 1.00 |
| &nbsp;&nbsp;&nbsp;&nbsp;Other | 1.26 | 0.71 | 1.79 (17) | 0.09 | (-0.23, 2.75) | 1.09 |
| &nbsp;&nbsp;&nbsp;&nbsp;Mexican | -- | -- | -- | -- | -- | -- |
| **Gender** | | | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Female | -2.29 | 0.55 | -4.18 (17) | 0.001 | (-3.45, -1.13) | 6.02 |
| &nbsp;&nbsp;&nbsp;&nbsp;Male | -- | -- | -- | -- | -- | -- |
| **Age (Centered)** | **0.04** | **0.02** | **1.77 (17)** | **0.10** | **(-0.01, 0.08)** | **3.10** |

23

<!-- page 24 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP: Examining Model Fit.

```
predict resids, resid
scatter resids agec
```

24

<!-- page 25 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP: Incorporating $\text{Age}^2$

```stata
gen agecsq = agec * agec
```

25

<!-- page 26 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP: Testing First-Order Interactions of Age with Ethnicity and Gender

```
svy, subpop(age18p): regress bpxdi1_1 i.ridreth1
  i.riagendr agec agecsq i.ridreth1#c.agec
  i.ridreth1#c.agecsq

test 2.ridreth1#c.agec 3.ridreth1#c.agec 4.ridreth1#c.agec
  5.ridreth1#c.agec 2.ridreth1#c.agecsq
  3.ridreth1#c.agecsq 4.ridreth1#c.agecsq
  5.ridreth1#c.agecsq
```

Wald test: $\text{F}(8, 10) = 7.00, p = 0.003$

```
svy, subpop(age18p): regress bpxdi1_1 i.ridreth1
  i.riagendr agec agecsq i.ridreth1#c.agec
  i.ridreth1#c.agecsq i.riagendr#c.agec
  i.riagendr#c.agecsq

test 2.riagendr#c.agec 2.riagendr#c.agecsq
```

Wald Test: $F(2, 16) = 4.83, p = 0.02$

26

<!-- page 27 -->

# Fitting a Multiple Regression Model to NHANES 2005-06 Data on Diastolic BP: Final Model ($\text{R}^2=0.12$ !)

```stata
svy, subpop(age18p): regress bpxdi1_1 i.ridreth1
i.riagendr agec c.agec#c.agec i.ridreth1#c.agec
i.ridreth1#c.agec#c.agec i.riagendr#c.agec
i.riagendr#c.agec#c.agec
```

27

<!-- page 28 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP: Analyze Residuals.

```stata
predict ehat1, resid
symplot ehat1, name(sym_ehat1_1, replace)
title(Symplot of Residuals)
histogram ehat1, normal name(h_ehat1, replace)
title(Histogram of Residuals)
qnorm ehat1, name(qnorm_ehat1, replace)
title(Normal Q-Q Plot of Residuals)
predict yhat1, xb
scatter ehat1 yhat1, name(ehat1xyhat1, replace)
title(Residuals vs. Predicted Y)
graph combine sym_ehat1_1 h_ehat1 qnorm_ehat1
ehat1xyhat1, rows(2)
```

28

<!-- page 29 -->

# Fitting a Multiple Regression Model to NHANES 2011-12 Data on Diastolic BP. Residual Diagnostics.

29

<!-- page 30 -->

# Regression Diagnostics for Complex Samples

* See <u>ASDA Chapter 7</u> for more details regarding recent developments in regression diagnostics for complex sample survey data
* Thus far, the design-based diagnostics have only been implemented in a contributed R package (svydiags); Chapter 7 includes a fully-worked example in R
* There will likely be rapid developments in this area in the very near future; don’t forget about the importance of examining model diagnostics!

30

<!-- page 31 -->

**If weighted estimators are estimating the population parameters, what is unweighted estimators estimating?**

31

<!-- page 32 -->

- Example shows when model miss-specified
  - Weighted and unweighted analyses results might differ.
  - Regressed birthweight on gestational age, see Table 4.3-1. Different weighted and unweighted estimates of slopes.

**Table 4.3-1. Weighted and Unweighted Linear Regressions of Gestational Age$^a$ on Birthweight (Sample Size = 9448)**

| | Weighted Analysis | | Unweighted Analysis | |
| :--- | :---: | :---: | :---: | :---: |
| **Independent Variable** | **Parameter Estimate** | **Standard Error** | **Parameter Estimate** | **Standard Error** |
| Intercept | 32.08 | .17 | 26.36 | .14 |
| Birthweight (g) | .00215 | .00005 | .00383 | .00005 |

Data from the 1988 NMIHS.
$^a$Gestational age is operationally defined as the difference in the date of the last menstrual period and the date of delivery (in weeks). These dates are reported on the birth certificate.

32

<!-- page 33 -->

* Form 20 groups by birthweight with about 500 observations in each group.

* Figures 4.3-1

  Weighted mean gestational age vs. weighted mean birth weight
  Area of bubbles $\sim$ estimated population size
  Line is weighted linear regression in Table 4.3-1

* Figures 4.3-2

  Unweighted mean gestational age vs. unweighted mean birth weight
  Area of bubbles $\sim$ sample size
  Line is unweighted linear regression in Table 4.3-1

33

<!-- page 34 -->

**Figure 4.3-1.** Plot of weighted mean gestational age versus weighted mean birthweight for successive groups of approximately 500 observations. Areas of bubbles are proportional to the estimated population sizes of the groups. The straight line is the weighted linear regression fit to the original (ungrouped) data.

34

<!-- page 35 -->

Figure 4.3-2 is analogous to Figure 4.3-1 Unweighted
Area of bubbles ~ group sample sizes.

**Figure 4.3-2.** Plot of mean gestational age versus mean birthweight for successive groups of approximately 500 observations. Areas of bubbles are proportional to the sample sizes of the groups. The straight line is the unweighted linear regression fit to the original (ungrouped) data.

35

<!-- page 36 -->

### Conclusions:

* Model is miss-specified: Quadratic not linear.
  – Sample and population birthweight distributions differ so weighted and unweighted analyses fit to different parts of population curve.

* Weighted analysis estimates population parameter B slope
  – Consistent for different sample designs.

* Unweighted estimator is not consistent
  – Varying by designs.

* When quadratic included
  – Weighted and unweighted analysis agree.

36

<!-- page 37 -->

* Example shows when covariate is omitted
  - weighted and unweighted analyses may differ.

  - Table 4.3-2 shows % maternal smoking in year before delivery of baby by mother's education level in 1988 NMIHS.

**Table 4.3-2. Weighted and Unweighted Percentages of Maternal Smoking by Mother's Education**

| Mother's Education | Weighted $\% \pm \text{SE}$ | Unweighted $\% \pm \text{SE}$ |
| :--- | :---: | :---: |
| $< 12\text{ years}$ | $31.5 \pm 1.0$ | $32.8 \pm 0.7$ |
| $12\text{ years}$ | $37.3 \pm 1.2$ | $33.2 \pm 0.8$ |
| $> 12\text{ years}$ | $20.2 \pm 1.1$ | $21.7 \pm 0.8$ |

Data from the 1988 NMIHS.

  - Weighted and unweighted analyses show different results
    - Difference between Education 12 yrs and $<12$ yrs IS 5.8% with weighted analysis vs. 0.4% for unweighted analyses.
    **Q:** Why such large difference?

37

<!-- page 38 -->

- Stratify the table by race because of differential sampling rates by race. See table 4.3-3.

**Table 4.3-3. Weighted and Unweighted Percentages of Maternal Smoking by Mother's Education, Separately for Blacks and Nonblacks**

| Mother's Education | Blacks Weighted $\% \pm \text{SE}$ | Blacks Unweighted $\% \pm \text{SE}$ | Nonblacks Weighted $\% \pm \text{SE}$ | Nonblacks Unweighted $\% \pm \text{SE}$ |
| :--- | :---: | :---: | :---: | :---: |
| $< 12$ years | $29.4 \pm 1.1$ | $31.2 \pm 1.0$ | $32.0 \pm 1.3$ | $34.6 \pm 1.1$ |
| $= 12$ years | $24.6 \pm 1.1$ | $26.2 \pm 1.0$ | $40.6 \pm 1.5$ | $42.5 \pm 1.3$ |
| $> 12$ years | $20.6 \pm 1.3$ | $21.5 \pm 1.3$ | $20.2 \pm 1.2$ | $21.9 \pm 1.1$ |

Data from the 1988 NMIHS.

- Weighted and unweighted analysis agree closely
- Table 4.3-2 averages over race, weighted and unweighted analysis differ
- Race is an omitted covariate causing the difference between weighted and unweighted results.

38
