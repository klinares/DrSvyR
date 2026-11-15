---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_10"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_10.pdf"
pages: 46
sha256: "e941faa1d11909c503d9bb2f78a8678b6d79e22ab399a34a82a8be47fa392fd7"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:52"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

SURV/SURVMETH 701

Lecture Notes: Module 10

**Logistic Regression Analysis for Complex Samples**

Instructor: Yan Li

e-mail: [email]

1

<!-- page 2 -->

# Brief Review

* Linear regression for complex samples
* Difference from OLS
  - Goal: estimate relationships of variables in a **<u>finite</u>** population, using sample data
  - Variance estimation formulas appropriate for stratified cluster samples: Taylor series, Replication methods
* Similarity with OLS
  - Weighted least squares (WLS) estimation of parameters
  - Residual analysis for checking normality of residuals, homogeneity of variance, model fit
  - $t$-tests of individual parameters in regression
  - Wald tests or transformed F-tests of multi-parameter hypotheses

2

<!-- page 3 -->

# Logistic Regression Analysis of Complex Sample Survey Data

<u>Outline of Topic</u>

* The standard logistic regression model (in an SRS setting)
* The need for pseudo maximum likelihood estimation with complex sample designs
* Parameter estimation and variance estimation in the complex sample design setting

Software Applications / Examples
* Stata

3

<!-- page 4 -->

# Examples of Categorical Response Data

**HRS 2006 N001:** “Are you currently covered by Medicare health insurance?”

**NHANES DIQ010:** “Have you ever been told by a doctor or health professional that you have diabetes or sugar diabetes?”

**NCSR SC26_4:** “Did you ever use drugs or alcohol so often that it interfered with your responsibilities at work, at school or at home?

4

<!-- page 5 -->

# Analytic Problem in Binary Logistic Regression Models

Response: $Y = \binom{0}{1} = f(x)$

Predictors: $X$

1) Categorical – Nominal (e.g., Region)

2) Categorical – Ordinal (e.g., Education)

3) Continuous (e.g., Weight in kg)

4) Mixture of Categorical and Continuous

5

<!-- page 6 -->

# Odds Ratio Statistic

$$
\psi = \frac{Odds(A)}{Odds(B)} = \frac{P_{A1} / P_{A0}}{P_{B1} / P_{B0}} = \frac{P_{A1} \bullet P_{B0}}{P_{A0} \bullet P_{B1}}
$$

The **odds ratio** ($\psi$) is the statistic most often used to interpret results of logistic model fitting.

$$
\text{ex: } y = \begin{cases} 1 & \text{lung cancer} \\ 0 & \text{no lung cancer} \end{cases}
$$

$$
x = \begin{cases} A & \text{lifetime smoker} \\ B & \text{never a smoker} \end{cases}
$$

$$
\hat{\psi} = \frac{.50 / .50}{.05 / .95} = 19
$$

<u>Interpretation</u>: A lifetime smoker has odds of contracting lung cancer that are estimated to be 19 times that of a never smoker.

6

<!-- page 7 -->

# Statements about Odds Ratios

$$\hat{\psi} = \frac{\frac{p(y=1 \mid A)}{p(y=0 \mid A)}}{\frac{p(y=1 \mid B)}{p(y=0 \mid B)}} = \frac{.50 / .50}{.05 / .95} = 19$$

* **Always correct:** A lifetime smoker's odds of contracting lung cancer are 19 times greater than the odds for a never smoker.

* If (probability of lung cancer < .05), then, "The probability that a lifetime smoker will contract lung cancer is 19 times greater than that of a never smoker."

  - This is a **Relative Risk (RR)** interpretation!
  - $\text{RR} = p(y = 1 \mid A) / p(y = 1 \mid B)$
  - Example: $\text{RR} = 0.50 / 0.05 = 10$ (very different from 19!)

7

<!-- page 8 -->

# Logit Function and Relationship to Odds Ratios

$$
\text{logit}(Y=1|X) = \log \left( \frac{p(Y=1|X)}{p(Y=0|X)} \right)
$$

$$
\text{e.g.} \quad \text{logit}(Y=1|X=A) = \log \left( \frac{p(Y=1|A)}{p(Y=0|A)} \right) = \log \left( \frac{.50}{.50} \right) = 0.000
$$

$$
\text{logit}(Y=1|X=B) = \log \left( \frac{p(Y=1|B)}{p(Y=0|B)} \right) = \log \left( \frac{.05}{.95} \right) = -2.944
$$

$$
\begin{aligned}
\psi(A:B) &= \exp \left\{ \log \left( \frac{p(Y=1|A)}{p(Y=0|A)} \right) \right\} \div \exp \left\{ \log \left( \frac{p(Y=1|B)}{p(Y=0|B)} \right) \right\} \\
&= \exp \left\{ \log \left( \frac{p(Y=1|A)}{p(Y=0|A)} \right) - \log \left( \frac{p(Y=1|B)}{p(Y=0|B)} \right) \right\} \\
&= \exp \{ \text{logit}(Y=1|X=A) - \text{logit}(Y=1|X=B) \} \\
&= \exp \{ 0.000 - (-2.944) \} = 19
\end{aligned}
$$

8

<!-- page 9 -->

# Jumping Ahead

What if we could identify a linear model to estimate the logits:

$$g(E(Y)) = g(p(Y = 1 | X)) = \beta_0 + \beta_1 X$$

*if* we choose $g(E(Y)) = \text{logit}(p(Y = 1 | X))$

$$\text{logit}(p(Y = 1 | X)) = \beta_0 + \beta_1 X$$

$$\text{e.g. define : } X = \begin{cases} 1 & \text{if smoker (A)} \\ 0 & \text{if not (B)} \end{cases}$$

then, from above:

$$\psi = \frac{\exp[\text{logit}(P_{1|A})]}{\exp[\text{logit}(P_{1|B})]}$$

$$= \frac{\exp(\beta_0 + \beta_1)}{\exp(\beta_0)}$$

$$= \exp(\beta_1)$$

9

<!-- page 10 -->

# How Do We Model These Data?

linear in $E(Y)$? (OLS)

$$E(y) = \beta_0 + \beta_1 X$$

non-linear in $E(Y)$?

10

<!-- page 11 -->

# Generalized Linear Model: Logistic Regression

$$
\begin{aligned}
g(E(Y \mid \boldsymbol{x})) &= g(\pi(\boldsymbol{x})) = \text{logit}(\pi(\boldsymbol{x})) \\
&= \ln\left(\frac{\pi(\boldsymbol{x})}{1 - \pi(\boldsymbol{x})}\right) = X\beta
\end{aligned}
$$

$$
\hat{\pi}(\boldsymbol{x}) = g^{-1}(g(\hat{\pi}(\boldsymbol{x}))) = \frac{\exp(X\hat{\beta})}{1 + \exp(X\hat{\beta})}
$$

11

<!-- page 12 -->

# Link Functions, $g(Z)$, for Binary Data

12

*[Figure: This line graph compares three link functions for binary data—Probit (solid line), Logit (dashed line), and Complementary LogLog (dotted line)—by plotting their cumulative distribution function (CDF) values from 0 to 1 on the vertical axis against $Z$ values from -4 to 4 on the horizontal axis. All three curves exhibit S-shaped monotonic growth from 0 to 1, with the symmetric Probit and Logit curves intersecting at $Z = 0$ (CDF = 0.5) while the asymmetric Complementary LogLog curve rises more gradually at negative $Z$ values and approaches 1 most rapidly at positive $Z$ values.]*

<!-- page 13 -->

# GLMs for Binary Data

* Three primary choices of links:
  - Logit
  - Probit
  - Complementary Log-Log (C-L-L)

* Focus here on **Logit**; few differences in model inferences, coefficients for probit are scaled differently from logit and C-L-L.

* Probit is often used in economics and related disciplines.

* Complementary-log-log has application when predicted probabilities are near 0 or 1.

* Stata (PROC SURVEYLOGISTIC also features these link functions):
  - svy: logit and svy: logistic
  - svy: probit
  - svy: cloglog

13

<!-- page 14 -->

# Logistic Regression Model (SRS Setting)

$$\text{Likelihood} = \prod_{i=1}^{n} \pi(x_i)^{Y_i} \cdot [1 - \pi(x_i)]^{1 - Y_i}$$

$$\text{where: } \pi(x_i) = \frac{\exp(x_i \beta)}{1 + \exp(x_i \beta)}$$

**<u>Parameter estimates</u>**: $\hat{\beta}_{MLE} = \{\hat{\beta}_0, \hat{\beta}_1, \dots, \hat{\beta}_p\}$.

An iterative algorithm is used to obtain MLEs
(Newton-Raphson method)

**<u>Variance of Parameter Estimates</u>**: $\hat{V}(\hat{\beta}) = I^{-1}(\beta) | \beta = \hat{\beta}$
the inverse of the “information matrix” $I(\beta)$, evaluated at the maximum likelihood estimate

14

<!-- page 15 -->

# Confidence Intervals for Parameter Estimates (SRS)

$$CI(\beta) = \hat{\beta} \pm 1.96 \times se(\hat{\beta}) \text{ for } \alpha = .05$$

$$\hat{\psi}_j = e^{\hat{\beta}_j}$$

$$CI(\psi_j = e^{\beta_j}):$$

$$\text{Lower - } e^{\hat{\beta}_j - 1.96 \times se(\hat{\beta}_j)}$$

$$\text{Upper - } e^{\hat{\beta}_j + 1.96 \times se(\hat{\beta}_j)}$$

$\hat{\psi}_j =$ multiplicative change in odds for a one-unit change in $X_j$, with all other $X_{j \neq k}$ held constant (e.g., 1.5 implies that the odds are expected to increase by 50%).

15

<!-- page 16 -->

# Testing Significance of Effects in Fitted Models (SRS)

**Likelihood ratio test:**

Under $H_0: \beta_j = 0$

$$G = -2 \ln \left( \frac{likelihood - reduced\ model}{likelihood - full\ model} \right) \sim X_q^2,$$

*Chi-square with $q$ degrees of freedom*

$q =$ # parameters in full model - # parameters in reduced model

16

<!-- page 17 -->

# Odds Ratios in Multivariate Models

* Single X, no interactions:

$$
\begin{aligned}
\hat{\psi}_{x=X_k} &= e^{\hat{\beta}_k} \\
&= \text{the odds ratio for } y=1, \\
&\quad \text{comparing } X_k+1 \text{ to } X_k, \\
&\quad \text{holding all other variables} \\
&\quad \text{fixed at } \underset{\sim}{x}_{j \neq k} = \underset{\sim}{X}_{j \neq k}
\end{aligned}
$$

17

<!-- page 18 -->

# Odds Ratios in Multivariate Models

Multiple X variables (predictors) and/or Interactions:

Given $\underset{\sim}{\text{X}}_1, \underset{\sim}{\text{X}}_2$ – two covariate "patterns"

1) Evaluate: $\text{logit}(\text{y}=1 | \underset{\sim}{\text{X}}_1), \text{logit}(\text{y}=1 | \underset{\sim}{\text{X}}_2)$

2) Compute difference:

$$
\Delta = \text{logit}(\text{y}=1 | \underset{\sim}{\text{X}}_1) - \text{logit}(\text{y}=1 | \underset{\sim}{\text{X}}_2)
$$

3) Estimate: $\hat{\psi}_{X1\text{ vs. X2}} = e^\Delta$

18

<!-- page 19 -->

# Goodness of Fit, Model Diagnostics

* Criteria (Hosmer et al., 2013):
  - 1) $(y - \hat{\pi})$ should be small and not irregular over $x$
  - 2) Individual $(y_j - \hat{\pi}_j)$ should not have extreme influence
* Goodness of Fit
  - Hosmer-Lemeshow Test
  - Pearson, Deviance
  - ROC, Area under the curve
  - Squared correlation between $(Y, \pi)$
  - Pseudo $R^2$ (not equivalent to $R^2$ in linear regression, and only approximate; use to compare models only)

* Influence
  - “Hat” values for logistic regression
  - “Cook’s D-like” measures
  - Change in X2 due to deletion of cases or “patterns” of cases with identical x’s.

19

<!-- page 20 -->

# Logistic Regression Analysis for Complex Sample Survey Data

**<u>Recall SRS Results:</u>**

$$
\ln\left(\frac{\pi(X_i)}{1 - \pi(X_i)}\right) = \beta_0 + \beta_1 X_i
$$

**multiple logistic regression:**

$$
\pi(x_i) = \frac{e^{x_i'\beta}}{1 + e^{x_i'\beta}}
$$

$$
\underset{\sim}{\beta} = \{\beta_0, \beta_1, \dots, B_p\}
$$

$$
\underset{\sim}{x} = \{x_1, x_2, \dots, x_p\}
$$

$$
l(\beta) = \prod_{i=1}^n \pi(x_i)^{Y_i} (1 - \pi(x_i))^{1 - Y_i}; Y_i \text{ are distributed as } B(1, \pi(x_i))
$$

- $\hat{\beta}$ by maximum likelihood
- $\text{se}\left(\hat{\beta}\right)$ by $I^{-1}(\beta) \mid \beta = \hat{\beta}$
- LRT to test model effects

20

<!-- page 21 -->

# What’s Different from the SRS Setting?

Complex Sample Survey Data:

$$
\ln \left( \frac{\pi(X_i)}{1 - \pi(X_i)} \right) = B_0 + B_1 X_i
$$

$$
\pi(X_i) = \frac{e^{X_i B}}{1 + e^{X_i B}} \qquad B = \{B_0, B_1, \dots, B_p\}
$$

$L(B)$ is different from $L(\beta)$ in the SRS setting, due to weights, stratification, and cluster sampling!

$L(B) = ?$

* $\hat{B} \neq \hat{\beta}$
* $\hat{B}$ estimated?
* $se(\hat{B}) \neq I^{-1}(B)|B = \hat{B}$
* $se(\hat{B})$ estimated?
* Hypothesis tests? Goodness of fit?

21

<!-- page 22 -->

# Iterative Pseudo-Likelihood Method for Logistic Regression (Binder, 1981, 1983)

<u>Recall</u>: $L(B)_{(\text{complex})}$ is different from $L(\beta)_{(\text{SRS})}$

<u>Approach</u>:

1) Estimate $B$ as we would $\beta$ with iterative maximum likelihood estimation methods (incorporating the weights).

2) Derive the $V\hat{a}r(\hat{B})$ as a matrix function of the "score equations," which are linear functions [we know how to estimate complex sample variances for linear functions of totals]. Simpler alternatives: JRR and BRR.

3) Use Wald-type statistics for making inferences about $B$.

22

<!-- page 23 -->

# Pseudo-Maximum Likelihood for Logistic Regression

Pseudo ln(Likelihood):

$$
\ln\text{PL}(\text{B}) = \sum_{\text{h}=1}^{\text{H}} \sum_{\alpha=1}^{\text{a}_{\text{h}}} \sum_{\text{i}=1}^{\text{n}_{\alpha}} \text{w}_{\text{h}\alpha\text{i}}\text{y}_{\text{h}\alpha\text{i}} \cdot \ln(\pi(x_{h\alpha i})) + \sum_{\text{h}=1}^{\text{H}} \sum_{\alpha=1}^{\text{a}_{\text{h}}} \sum_{\text{i}=1}^{\text{n}_{\alpha}} w_{h\alpha i} \left(1 - y_{\text{h}\alpha\text{i}}\right) \cdot \ln(1 - \pi(x_{h\alpha i}))
$$

where:

$$
\pi(x_i) = e^{x_i B} / (1 + e^{x_i B}), \;\; \hat{\pi}(x_i) = e^{x_i b} / (1 + e^{x_i b})
$$

and $\text{b} =$ the vector of coefficient estimates that solves:

$$
S(B) = \frac{\delta \ln PL(B)}{\delta B}\Big|_{B=b} = 0 =
$$

$$
= \sum_{h} \sum_{\alpha} \sum_{i} w_{h\alpha i}(y_{h\alpha i} - \hat{\pi}(x_{h\alpha i}))x'_{h\alpha i} = \sum_{h} \sum_{\alpha} \sum_{i} s_{h\alpha i}
$$

23

<!-- page 24 -->

# Variance-Covariance Matrix for Estimated Parameters: Linearization

$$
\begin{aligned}
\boldsymbol{J} &= -\left[\frac{\delta^2 \ln PL(\boldsymbol{B})}{\delta^2 \boldsymbol{B}}\right] | \, \boldsymbol{B} = \hat{\boldsymbol{B}} \\
&= \sum_h \sum_\alpha \sum_i \boldsymbol{x}'_{h\alpha i}\boldsymbol{x}_{h\alpha i} w_{h\alpha i} \hat{\pi}_{h\alpha i}(\boldsymbol{B})(1 - \hat{\pi}_{h\alpha i}(\boldsymbol{B}))
\end{aligned}
$$

$$
V\hat{a}r(\hat{\boldsymbol{B}}) = (\boldsymbol{J}^{-1})\operatorname{var}[S(\hat{\boldsymbol{B}})](\boldsymbol{J}^{-1})
$$

24

<!-- page 25 -->

# Variance-Covariance Matrix for Estimated Parameters: Linearization

$$\text{var}[S(\hat{\boldsymbol{B}})] = \frac{n - 1}{n - (p + 1)} \sum_{h=1}^{H} \frac{a_h}{(a_h - 1)} \sum_{\alpha=1}^{a_h} (\boldsymbol{s}_{h\alpha} - \overline{\boldsymbol{s}}_h)'(\boldsymbol{s}_{h\alpha} - \overline{\boldsymbol{s}}_h)$$

which for $n$ large is:

$$\text{var}[S(\hat{\boldsymbol{B}})] \cong \sum_{h=1}^{H} \frac{a_h}{(a_h - 1)} \sum_{\alpha=1}^{a_h} (\boldsymbol{s}_{h\alpha} - \overline{\boldsymbol{s}}_h)'(\boldsymbol{s}_{h\alpha} - \overline{\boldsymbol{s}}_h)$$

where for the logistic link :

$$\boldsymbol{s}_{h\alpha} = \sum_{i=1}^{n_{h\alpha}} \boldsymbol{s}_{h\alpha i} = \sum_{i=1}^{n_{h\alpha}} w_{h\alpha i} (y_{h\alpha i} - \hat{\pi}_{h\alpha i}(\boldsymbol{B})) \, \boldsymbol{x}_{h\alpha i}' \text{ ; and}$$

$$\overline{\boldsymbol{s}}_h = \frac{1}{a_h} \sum_{\alpha=1}^{a_h} \boldsymbol{s}_{h\alpha}$$

25

<!-- page 26 -->

## Hypothesis Testing

$$B' = \left[ B_1, \dots, B_p \right]$$

$$H_o: \qquad CB = 0$$

$$X_{Wald}^2 = \left[ C\hat{B} \right]' \left[ C V\hat{a}r\left( \hat{B} \right) C' \right]^{-1} \left[ C\hat{B} \right]$$

$$= \frac{\text{contrast "squared"}}{\text{variance of contrast}}$$

Under $H_o$: $X_{Wald}^2$ is distributed as $\chi_q^2$

where $q =$ the rank of C

26

<!-- page 27 -->

# Hypothesis Testing: 1

$$
B' = B_1, B_2, B_3
$$

$$
C = \begin{bmatrix} 0 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 0 \end{bmatrix}
$$

CB tests $\quad H_0: \quad B_2 = 0$

$$
\text{d.f.} = \text{rank}(C) = 1
$$

27

<!-- page 28 -->

# Hypothesis Testing: 2

$$
C = \begin{bmatrix} 0 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 1 \end{bmatrix}
$$

CB tests $H_0: B_2 = B_3 = 0$

$$
\text{d.f.} = \text{rank}(C) = 2
$$

28

<!-- page 29 -->

# Hypothesis Testing: 3

$$
C = \begin{bmatrix} 0 & 0 & 0 \\ 0 & 1 & -1 \\ 0 & 0 & 0 \end{bmatrix}
$$

CB tests $H_0$: $B_2 - B_3 = 0$

$$\text{d.f.} = \text{rank}(C) = 1$$

29

<!-- page 30 -->

# Hypothesis Testing in Stata

*Tests of individual coefficients :*

$$H_0 : 1 \cdot B_j = 0$$

$$t = \frac{b_j - 0}{se(b_j)}$$

*under $H_0 \sim \text{Student } t, \text{with } df = \#clusters - H$*

*Tests of multiple coefficients :*

$$H_0 : \underset{\sim}{B}_{(2)} = \{B_{q+1}, B_2, \dots, B_p\} = ,\dots, 0\}$$

$$F_{Wald} = \frac{\chi^2_{Wald}}{(p - q)}$$

*under $H_0 \sim F \ df = (p - q, \#clusters - H)$*

30

<!-- page 31 -->

# Wald Tests in Stata

* First, code the model fit in the svy: regress (or svy: logit, svy: poisson, etc.) regression program

* Follow the execution of the svy: [   ] regression command with the execution of a test statement

* e.g. (for ASDA Chapter 8 example), to test the null hypothesis that all of the parameters associated with AG4CAT are equal to zero, use this test statement:

  test 2.ag4cat 3.ag4cat 4.ag4cat

31

<!-- page 32 -->

## Software Procedures for Logistic Regression Analysis of Survey Data

* **Stata**: the svy: logit and svy: logistic commands
  - svy: logistic defaults to odds ratio output; **coef** option yields logistic model parameter estimates
  - svy: logit defaults to log-odds (B) output; **or** option yields odds ratios
  - “i.” prefix defines categorical predictors
    * Default to lowest alphanumeric category for reference
    * Change reference category for categorical predictors using ib#.
  - Post-estimation **test** statement for Wald tests of multi-parameter hypotheses

32

<!-- page 33 -->

# <u>Example</u>: Logistic regression Analysis of NCS-R data: Specifying the Preliminary Model

* In this example, we assess the significance of potential predictors of having lifetime major depression for adults greater than 17 years of age.

* **<u>Dependent Variable</u>**: (MDE: 1=Yes, 0=No)

* **<u>Predictor Variables</u>**:
  * AGE4CAT (1=18-29; 2=30-44; 3=45-49; 4=60+)
  * SEX (1 = Male; 2 = Female)
  * ALD (1 = alcohol dependent; 0= not ALD)
  * EDCAT (1=<12; 2=12; 3=13-15; 4=16+)
  * MARCAT (1=Married; 2=Previously; 3=Never)

33

<!-- page 34 -->

# <u>Example</u>: Logistic regression Analysis of NCS-R data: Examining Bivariate Associations.

<u>Stata Code:</u>

```stata
svyset seclustr [pweight = ncsrwtlg], strata(sestrat)
svy: tab ag4cat mde, row
svy: tab sex mde, row
svy: tab ald mde, row
svy: tab ed4cat mde, row
svy: tab mar3cat mde, row
```

34

<!-- page 35 -->

# <u>Example</u>: Logistic regression Analysis of NCS-R data: Examining Bivariate Associations.

| Predictor | Rao-Scott $F$-test | Category | % with MDE (SE) |
| :--- | :---: | :---: | :---: |
| **AGE4CAT** | $F(2.76, 115.97) = 26.39$<br>$p < 0.01$ | **18-29** | **18.4% (0.9)** |
| | | **30-44** | **22.9% (1.1)** |
| | | **45-59** | **22.3% (1.3)** |
| | | **60+** | **11.1% (1.0)** |
| **SEX** | $F(1, 42) = 44.83$<br>$p < 0.01$ | **Male** | **15.3% (0.9)** |
| | | **Female** | **22.6% (0.7)** |
| **ALD** | $F(1, 42) = 120.03$<br>$p < 0.01$ | **Yes** | **45.2% (0.3)** |
| | | **No** | **17.7% (0.7)** |
| **ED4CAT** | $F(2.90, 121.93) = 4.30$<br>$p < 0.01$ | **<12 yrs** | **16.3% (1.2)** |
| | | **12 yrs** | **18.6% (0.8)** |
| | | **13-15 yrs** | **21.3% (1.0)** |
| | | **16+ yrs** | **19.7% (1.1)** |
| **MAR3CAT** | $F(1.90, 79.74) = 11.08$<br>$p < 0.01$ | **Married** | **17.3% (0.7)** |
| | | **Previously** | **23.9% (1.5)** |
| | | **Never** | **19.4% (1.1)** |

35

<!-- page 36 -->

# <u>Example</u>: Logistic regression Analysis of NCS-R data: Fit preliminary model.

## <u>Stata Code:</u>

```stata
svy: logistic mde i.ag4cat ib2.sex ald i.ed4cat i.mar3cat
svy: logistic mde i.ag4cat ib2.sex ald i.ed4cat i.mar3cat, coef

svy: logit mde i.ag4cat ib2.sex ald i.ed4cat i.mar3cat
```

Estimated odds ratios and 95% CIs can be generated in svy: logit by adding the or option:

```stata
svy: logit mde i.ag4cat ib2.sex ald i.ed4cat i.mar3cat, or
```

Other software systems (e.g., SAS PROC SURVEYLOGISTIC) will output both the estimated logistic regression coefficients (and standard errors) and the corresponding odds ratio estimates.

36

<!-- page 37 -->

# Example: Logistic Regression Analysis of NCS-R data: Fit Preliminary Model.

| Predictor* | Category | $\hat{B}$ | $se(\hat{B})$ | $t$ | $P(t_{42} > t)$ |
| :--- | :---: | :---: | :---: | :---: | :---: |
| INTERCEPT | | -1.583 | 0.121 | -13.12 | <0.001 |
| AGE4CAT | 30-44 | 0.255 | 0.122 | 2.71 | 0.100 |
| | 45-59 | 0.206 | 0.113 | 2.26 | 0.029 |
| | 60+ | -0.676 | 0.072 | -4.78 | < 0.001 |
| SEX | Male | -0.577 | 0.138 | -7.48 | < 0.001 |
| ALD | Yes | 1.424 | 0.640 | 9.24 | < 0.001 |
| ED4CAT | 12 | 0.079 | 0.105 | 0.82 | 0.418 |
| | 13-15 | 0.231 | 0.117 | 2.48 | 0.017 |
| | 16+ | 0.163 | 0.130 | 1.47 | 0.148 |
| MAR3CAT | Previously | 0.486 | 0.139 | 5.69 | <0.001 |
| | Never | 0.116 | 0.121 | 1.07 | 0.290 |

\* Source: NCS-R, $n = 5,692$, adjusted Wald test for all parameters: $F(10,33) = 28.07, p < 0.001$. Reference categories for categorical predictors are: AGE4CAT (18-29); SEX (Female); ALD (No); ED4CAT (<12 yrs); MAR3CAT (Married).

37

<!-- page 38 -->

# Example: Logistic Regression Analysis of NCS-R data: Interpret Model Results as Odds Ratio Estimates.

| Predictor* | Category | $\hat{\psi}$ | 95% CI for $\hat{\psi}$ |
| :--- | :---: | :---: | :---: |
| | 30-44 | 1.29 | (1.067, 1.562) |
| AGE4CAT | 45-59 | 1.23 | (1.022, 1.479) |
| | 60+ | 0.51 | (0.383, 0.677) |
| SEX | Male | 0.56 | (0.480, 0.656) |
| ALD | Yes | 4.15 | (3.042, 5.668) |
| | 12 | 1.08 | (0.890, 1.316) |
| ED4CAT | 13-15 | 1.26 | (1.044, 1.519) |
| | 16+ | 1.18 | (0.941, 1.471) |
| MAR3CAT | Previously | 1.63 | (1.369, 1.932) |
| | Never | 1.12 | (0.903, 1.396) |

38

<!-- page 39 -->

# <u>Example</u>: Logistic Regression Analysis of NCS-R data: Wald Tests of Multi-parameter Predictors.

```
test 2.ag4cat 3.ag4cat 4.ag4cat
test 2.mar3cat 3.mar3cat
test 2.ed4cat 3.ed4cat 4.ed4cat
```

| Categorical Predictor | $F$-test Statistic | $P(\mathcal{F} > F)$ |
| :--- | :---: | :--- |
| AGE4CAT | $F_{(3,40)} = 19.03$ | $< 0.001$ |
| ED4CAT | $F_{(3,40)} = 2.13$ | $0.112$ |
| MAR3CAT | $F_{(2,41)} = 16.60$ | $< 0.001$ |

39

<!-- page 40 -->

# <u>Example</u>: Logistic Regression Analysis of NCS-R data: Test overall goodness of fit of preliminary model.

* Use Archer and Lemeshow’s (2006, 2007) design-adjusted test to assess the goodness of fit of this initial model.

* estat gof &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (post-estimation command)

* The resulting design-adjusted $F$-statistic reported in the Stata Results window is equal to $F_{\text{A-L}} = 1.229$, with a $p$-value of $0.310$. This suggests that the null hypothesis that the model fits the data well is not rejected. We therefore have confidence moving forward that the fit of this initial model is reasonable.

40

<!-- page 41 -->

### <u>Example 2</u>: Logistic regression analysis of NCS-R ALD. Compare Logit, Probit, CLL Link Models.

svy: logit ald i.ag4cat ib2.sex i.ed4cat i.mar3cat

svy: probit ald i.ag4cat ib2.sex i.ed4cat i.mar3cat

svy: cloglog ald i.ag4cat ib2.sex i.ed4cat i.mar3cat

41

<!-- page 42 -->

# Example 2: Logistic regression analysis of NCS-R ALD. Compare Logit, Probit, CLL Link Models.

| Predictor* | Category | Logistic $\hat{B}$ | Logistic $se(\hat{B})$ | Logistic $p$ | Probit $\hat{B}$ | Probit $se(\hat{B})$ | Probit $p$ | Complementary L-L $\hat{B}$ | Complementary L-L $se(\hat{B})$ | Complementary L-L $p$ |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Intercept** | | -3.124 | 0.225 | <0.01 | -1.719 | 0.105 | <0.01 | -3.140 | 0.218 | <0.01 |
| **SEX** | **Male** | 0.997 | 0.119 | <0.01 | 0.471 | 0.056 | <0.01 | 0.965 | 0.115 | <0.01 |
| **AGE4CAT** | **30-44** | 0.146 | 0.178 | 0.416 | 0.065 | 0.084 | 0.444 | 0.143 | 0.171 | 0.408 |
| | **45-59** | -0.051 | 0.144 | 0.726 | -0.034 | 0.067 | 0.609 | -0.045 | 0.140 | 0.748 |
| | **60+** | -1.120 | 0.212 | <0.01 | -0.531 | 0.093 | <0.01 | -1.083 | 0.209 | <0.01 |
| **ED4CAT** | **12 yrs** | -0.268 | 0.194 | 0.173 | -0.124 | 0.095 | 0.200 | -0.260 | 0.185 | 0.167 |
| | **13-15 yrs** | -0.264 | 0.176 | 0.141 | -0.124 | 0.085 | 0.152 | -0.256 | 0.169 | 0.137 |
| | **16+ yrs** | -0.736 | 0.197 | <0.01 | -0.339 | 0.092 | <0.01 | -0.713 | 0.190 | <0.01 |
| **MAR3CAT** | **Previously** | 0.517 | 0.142 | <0.01 | 0.255 | 0.069 | <0.01 | 0.494 | 0.136 | <0.01 |
| | **Never** | 0.065 | 0.169 | .0701 | 0.039 | 0.077 | 0.616 | 0.060 | 0.164 | 0.713 |

42

<!-- page 43 -->

# Plotting Predicted Marginal Probabilities and Effects in Stata

* Stata offers extremely easy-to-use post-estimation commands for calculation and plotting of marginal predicted probabilities based on fitted models

* Default calculation: compute a model-based predicted probability for <u>everyone in the data set as if they all belonged to the same subgroup</u>, and average the predictions

* One can plot marginal predicted probabilities for different subgroups, or average marginal effects (i.e., expected changes in predicted probabilities associated with a one-unit increase in a given predictor)

* The next few slides present some of the examples illustrated in Chapter 8 of ASDA (Second Edition)

43

<!-- page 44 -->

# Plotting Marginal Predicted Probabilities in Stata

```stata
svy: logit mde i.ald i.ag4cat
margins ald, by(ag4cat)
marginsplot
```

### Predictive Margins of ald with 95% CIs

* **Y-axis:** Pr(Mde) (.1, .2, .3, .4, .5, .6)
* **X-axis:** 1=alcohol dependence 0=no alcohol dependence (0, 1)
* **Legend:**
  * ag4cat=1
  * ag4cat=2
  * ag4cat=3
  * ag4cat=4

44

<!-- page 45 -->

# Plotting Average Marginal Effects in Stata

```stata
margins, dydx(2.edcat3) by(male) at(kage=(50(10)90))
marginsplot
```

45

*[Figure: This line plot with 95% confidence interval error bars shows the "Average Marginal Effects of HS Education" (y-axis, ranging from 0 to .15) across "age at 2006 interview" (x-axis, from 50 to 90), comparing Females (solid blue line) and Males (dashed red line). Across all ages, males exhibit higher average marginal effects (peaking slightly around age 70 before declining) than females (whose values gradually decline after age 60), though their 95% confidence intervals overlap throughout.]*

<!-- page 46 -->

# Plotting Average Marginal Effects in Stata

```
margins, dydx(ald) by(ag4cat)
marginsplot
```

Average Marginal Effects of ALD with 95% CIs

Age Category: 1=17-29 2=30-44 3=45-59 4=60+

46

*[Figure: This line plot shows the average marginal effects of ALD with 95% confidence intervals (vertical axis, ranging from .1 to .3) across four age categories (horizontal axis: 1=17-29, 2=30-44, 3=45-59, 4=60+). The effect increases slightly from roughly .205 in the youngest group to around .24 in the two middle age groups before dropping sharply to under .14 for those aged 60 and older.]*
