---
id: "jpsm/Fund_Infe_SURV740/lectures/Module_Causal_Inf4_YL"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Marginal Structural Models"
original: "Fund_Infe_SURV740/lectures/Module Causal Inf4 YL.pdf"
pages: 44
sha256: "89a4f7fd44b408aff3f7194a42958cd7b36b4787c18286dd0cd603defeed1613"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:03"
---

<!-- page 1 -->

# Marginal Structural Models

Jeffe MM et al AS 2004; 58:272

Robins JM et al EPID 2000; 11: 550

<!-- page 2 -->

# Example 1

## Some Notations

* $A$: Exposure/treatment level
* Y: Outcome of interest measured
* L: Confounder, common cause of A and Y

Assume no unmeasured confounders given $L$

Figure 1.

**Question: How to estimate the causal effect of A on Y?**

<!-- page 3 -->

### Solution 1 (Standardization method):

$$
\begin{aligned}
E(Y^{a=1}) &- E(Y^{a=0}) \\
&= \sum_l pr(Y = 1|A = 1, L = l)pr(L = l) \\
&- \sum_l pr(Y = 1|A = 0, L = l)pr(L = l)
\end{aligned}
$$

i.e. $L$-standardized risk in the treated minus that in the untreated,

*that is*,

weighted average of the $L$-stratum-specific risks in the treated *minus*

weighted average of the $L$-stratum-specific risks in the untreated,

with weights *the population share in the stratum $l$*

Equivalently,

Estimate the association of $A$ with Y $\underline{\text{within each stratum } l}$

<!-- page 4 -->

## Solution 2 (MSM method):

$A$ $Y$
$L$

Two steps:

1. Remove the association between A and L
2. Estimate the association A with Y without conditioning on $L$

### How to remove the A-L association?

This is exactly what <u>marginal structural models</u> accomplish!

<!-- page 5 -->

**Example 1 (cont.):**

Table below summarizes observed data of $(Y, A_0, L_0)$. Assume the three variables follow the relationship of Figure 1. Estimate the causal effect of A on Y using **MSM** method and **Standardized** method.

| | $L_0 = 1$, $A_0 = 1$ | $L_0 = 1$, $A_0 = 0$ | $L_0 = 0$, $A_0 = 1$ | $L_0 = 0$, $A_0 = 0$ |
| :--- | :---: | :---: | :---: | :---: |
| $Y = 1$ | 108 | 24 | 20 | 40 |
| $Y = 0$ | 252 | 16 | 30 | 10 |
| Total | 360 | 40 | 50 | 50 |

<!-- page 6 -->

<u>Standardization</u> Method (stratum-specific analysis):

$$
E(Y^{A_0=1}) - E(Y^{A_0=0})
$$

$$
= \sum_l pr(Y = 1|\boldsymbol{A_0 = 1}, L_0 = l)pr(L_0 = l)
$$

$$
- \sum_l pr(Y = 1|\boldsymbol{A_0 = 0}, L_0 = l)pr(L_0 = l)
$$

$$
= \left(\frac{20}{50} \times \frac{100}{500} + \frac{108}{360} \times \frac{400}{500}\right) - \left(\frac{40}{50} \times \frac{100}{500} + \frac{24}{40} \times \frac{400}{500}\right)
$$

$$
= .32 - .64 = -.32
$$

**How about MSM method?**

<!-- page 7 -->

### Example 1 (Cont.): MSM method

Step 1: Model $logit(Pr(A = 1|L = l)) = \alpha + \beta l$

Step 2: Derive weights $w_i = \frac{1}{pr(A = a|L = l)}$ for units with $(A, L) = (0,0), (0,1), (1,0), (1,1)$, respectively,

| | $L_0 = 1$ | | $L_0 = 0$ | |
| :--- | :---: | :---: | :---: | :---: |
| | $A_0 = 1$ | $A_0 = 0$ | $A_0 = 1$ | $A_0 = 0$ |
| $Y = 1$ | 108 | 24 | 20 | 40 |
| $Y = 0$ | 252 | 16 | 30 | 10 |
| Total | 360 | 40 | 50 | 50 |

<!-- page 8 -->

## Step 3: Create pseudo-population

| $L_0$ | $A_0$ | $Y$ | N Observed Population | $pr(A_0|L_0)$ | $w$ | N Pseudo Population |
|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 108 | 0.9 | 1.11 | 120 |
| 1 | 1 | 0 | 252 | 0.9 | 1.11 | 280 |
| 1 | 0 | 1 | 24 | 0.1 | 10 | 240 |
| 1 | 0 | 0 | 16 | 0.1 | 10 | 160 |
| 0 | 1 | 1 | 20 | 0.5 | 2 | 40 |
| 0 | 1 | 0 | 30 | 0.5 | 2 | 60 |
| 0 | 0 | 1 | 40 | 0.5 | 2 | 80 |
| 0 | 0 | 0 | 10 | 0.5 | 2 | 20 |

<!-- page 9 -->

Step 4: Estimate model parameter in MSM in the pseudo-population

$$E(Y^a) = pr(Y = 1|A_0 = a)$$

$$\tau = E(Y^{a=1}) - E(Y^{a=0})$$

$$= pr(Y = 1|A_0 = 1) - pr(Y = 1|A_0 = 0)$$

$$= \frac{120 + 40}{120 + 280 + 40 + 60} - \frac{240 + 80}{240 + 160 + 80 + 20} = -0.32$$

~ Same results as obtained by standardization method?

Above – risk difference (RD). How to obtain causal risk ratio (RR), and causal odds ratio (OR) in the population?

<!-- page 10 -->

# A little more complicated example using MSM

<u>More notations:</u>

* $\mathbf{X}$: Measured pretreatment covariates
* $\boldsymbol{V} \in \boldsymbol{X}$: a subset of $\boldsymbol{X}$, including pretreatement covariates whose association with $Y$ is of interest
* $Y^a$: Potential outcome if receive level $a$
* $f(Y^a | \boldsymbol{V})$: Marginal density of a potential outcome in the subset defined by $\boldsymbol{V}$.

<!-- page 11 -->

Estimate causal effect $\leftrightarrow$ Compare $E(Y^a|\boldsymbol{V})$ vs. $E(Y^{a'}|\boldsymbol{V})$

<u>Marginal</u> density $E(Y^a|\boldsymbol{V}) \sim$ *Identifiable* under assumptions:

1. **Conditional Exchangeability**: Potential outcomes do not predict treatment assignment once one accounts for baseline covariates $X$
$$Y^a \perp A|X \text{ for all } a$$
(Rosenbaum and Rubin, 1983)

2. **Positivity**: There is nonzero probabilities that subjects with any covariates level $X$ receive treatment level $a$, i.e.
$1 > \Pr(A = a|X) > 0$.

<!-- page 12 -->

# Marginal Structural Model (MSM)

~ Model the **marginal** expectations of the potential outcomes $Y^a$ given specified baseline covariates $\boldsymbol{V}$:

$$E(Y^a|V) = q(a, V)$$

For example, $E(Y^a|V) = q(a, V) = expit(a\beta_a + V\beta_v)$,

where

$\beta_a$: Effect of treatment group A=$a$ on odds of success

$\beta_v$: Effect of covariates $\boldsymbol{V}$ on odds of success

$expit(r) \equiv \frac{\exp(r)}{1 + \exp(r)}$ such that $logit\big(expit(r)\big) = r$

~ They are **structural** models, because they model the probabilities of potential outcomes $Y^a$

<!-- page 13 -->

## Estimation under MSM (4-step procedure)

Step 1: Model the association of covariates and treatment assignment $Pr(A = a|X)$

Step 2: Use the specified model to derive weights

Step 3: Use the weights to create an artificial (pseudo-) population in which covariates are not associated with the treatment indicator $A \perp X$.

Step 4: Estimate the parameters in MSM using artificial (pseudo-) population

<!-- page 14 -->

# **Example 2:** *A study of Arteriovenous Fistula Surgery*

Data (Feldman et al. 2003) of $n=348$ subjects undergoing AVF surgery

Background: subjects with renal disease require a kidney transplant to replace the lack of function of their failed native kidneys. *Hemodialysis* is the most common form of kidney replacement, and its successful implementation depends on the ability to maintain a surgically created vascular conduit capable of sustaining high blood flows. *Native arteriovenous fistula* (AVF) is one such conduit. *Heparin* is used to prevent blood clots from forming during or after surgery, which can affect the successful maturation of the graft; potential benefit of *Heparin* with different levels of dose were not, however, confirmed at the time of the study.

**Aim**: Identify patients whose AVF surgeries are likely to succeed and so perform the surgery only for the subgroup.

<!-- page 15 -->

Y ($=1$ if surgery is successful - successful use of AVF in hemodialysis; $=0$ otherwise)

A: heparin use ($=1$ if at least 1,000 units, high dose; $=0$ otherwise)

$\boldsymbol{X}$: personal characteristics

* Age ($<=40$; $41-56$; $57-69$; $70+$ as reference)
* Prior permanent access (Yes or No)
* Dependent on dialysis (Yes or No)
* Cardiovascular disease (Yes or No)
* Blood Pressure at admission (Low or normal), and
<u>Size of the vessels,</u> collected in the surgical procedure but not measured before surgery

<!-- page 16 -->

**Aim**: Identify patients whose AVF surgeries are likely to succeed and so perform the surgery only for the subgroup

That is,

Identify patients with large $E(Y^a = 1|V)$ if treated by treatment level $a$ that is deemed to be preferable,

Equivalently,

Estimate the probability of success of the procedure if someone were provided the optimal heparin dose.

<!-- page 17 -->

### Estimation (4 steps)

Step 1: Construct the Model: $logit\{\Pr(A = 1|X)\} = X\beta$

Step 2: Compute weight for unit $i$ by the inverse of estimated probability of treatment assignment

$$w_i = \frac{I\{A_i = 1\}}{p_i} + \frac{1 - I\{A_i = 1\}}{1 - p_i},$$

where probability of treatment $p_i = \Pr(A_i = 1|X_i)$ is estimated by $\hat{p}_i = expit(X_i\hat{\beta})$

<!-- page 18 -->

# Step 3: Create pseudo-population

## Pseudo-population

* Suppose $P(A=1|X)=0.9$

<u>Original Population</u>

<u>Treated</u>

Apply weight $\frac{1}{0.9} = \frac{10}{9}$ to each

<u>Control</u>

Apply weight $\frac{1}{0.1} = 10$

<u>Pseudo-population</u>

<u>Treated</u>

<u>Control</u>

<!-- page 19 -->

* Suppose a subject's probability, given covariates, of receiving treatment is .9
* Weight: inverse of the probability that a subject with $X$ received his/her observed treatment
* Apply the weights to the study subjects (original population) creates an artificial population which perfectly balanced $X$ used to derive the weights

In the pseudo-population, everyone is equally likely to be treated, no matter $X$ values

<!-- page 20 -->

*Table 2. Logistic Regression Model for Associations of Various Predictors With High-Dose Heparin Use*

| | Coefficient ($\hat{\beta}$) | Standard error | Odds ratio | *p* value |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | .87 | .52 | | |
| Age (reference: 70+) | | | | $<$.0001 |
| $\quad \le$40 | $-1.72$ | .34 | .18 | |
| $\quad$41–56 | $-1.54$ | .48 | .21 | |
| $\quad$57–69 | $-.68$ | .38 | .51 | |
| Prior permanent access? | | | | .01 |
| $\quad$Yes | .67 | .27 | 1.94 | |
| Upstream vein diameter (reference: $<$ 3 mm) | | | | .04 |
| $\quad$3–4 | $-.46$ | .59 | .63 | |
| $\quad$4–5 | $-.60$ | .64 | .55 | |
| $\quad >$5 | $-1.27$ | .67 | .28 | |
| Dependent on dialysis? | | | | .23 |
| $\quad$Yes | $-.42$ | .35 | .66 | |
| Cardiovascular disease? | | | | .57 |
| $\quad$Yes | $-.10$ | .18 | .90 | |
| Blood pressure at admission | | | | .73 |
| $\quad$Low (versus normal) | $-.13$ | .38 | .87 | |

- $logit\{\Pr(A = 1|X)\} = X\beta$
- Older people receives high dose heparin use
- Smaller vassals receive high dose heparin use

<!-- page 21 -->

*Figure 1. Boxplots of distributions of continuous covariates by heparin dose.*

*Figure 2. Weighted boxplots of distributions of continuous covariates by heparin dose.*

<!-- page 22 -->

* Figure 1 shows that subjects receiving high-dose heparin are more likely to be older and have smaller vessels used in the surgery;

  Because older age and smaller vessels are associated with poorer outcomes, one would expect analyses that do not control for these variables to understate the benefit of heparin.

* Figure 2 shows that imbalance of age and vessel size between treatment groups is removed after weighting.

  Now let us estimate causal effect of heparin use (A) on the outcome (Y)

<!-- page 23 -->

# Step 4: Estimate model parameter in MSM

Under assumptions:

* Conditional Exchangeability: Given $X$ the treatment assignment A is random; $X$ fully captures the confounding $Y^a \perp A|X$
* Positivity: propensity scores are strictly positive (0, 1)

Under MSM:

$$E(Y_i^a | V) = \mu_i(\beta) = expit(a\beta_a + V\beta_v) \text{ for } a=0, 1$$

Solving estimating equations below for $\boldsymbol{\beta}$ in the pseudo-population

$$\sum_{i=1}^n \boldsymbol{w_i} \frac{\partial \mu_i^T}{\partial \beta} Var^{-1}(Y_i)\{Y_i - \mu_i(\beta)\} = 0$$

$$\leftrightarrow \sum_{i=1}^n w_i \{Y_i - \mu_i(\beta)\}(A_i, V_i)^T = 0$$

The estimates are denoted by $\widehat{\boldsymbol{\beta}}$.

<!-- page 24 -->

Causal OR:

$$
\text{OR} = \frac{p(Y_i^1 = 1|V)}{p(Y_i^1 = 0|V)} \bigg/ \frac{p(Y_i^0 = 1|V)}{p(Y_i^0 = 0|V)},
$$

estimated by

$$
\widehat{\text{OR}} = \frac{\dfrac{\exp(\widehat{\beta_1} + V\widehat{\beta_v})}{1 + \exp(\widehat{\beta_1} + V\widehat{\beta_v})}}{\dfrac{1}{1 + \exp(\widehat{\beta_1} + V\widehat{\beta_v})}} \Bigg/ \frac{\dfrac{\exp(V\widehat{\beta_v})}{1 + \exp(V\widehat{\beta_v})}}{\dfrac{1}{1 + \exp(V\widehat{\beta_v})}} = \exp(\widehat{\beta_1})
$$

The resulting $\exp(\widehat{\beta_1})$ estimates <u>causal effect of treatment A=1 on the outcome in OR scale</u>.

Variance of $\widehat{\beta_1}$ can be estimated by the robust variance estimator (Liang and Zeger, 1986)

<!-- page 25 -->

*Table 3. Marginal Structural Logistic Regression Model for Successful AVF Maturation*

| | Coefficient ($\hat{\beta}$) | Standard error | Odds ratio | *p* value |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | .26 | .45 | | |
| High-dose heparin | | | | $<.0001$ |
| &nbsp;&nbsp;&nbsp;&nbsp;Yes | 1.05 | .17 | 2.86 | |
| Age (reference: 70+) | | | | .075 |
| &nbsp;&nbsp;&nbsp;&nbsp;$\le 40$ | 1.15 | .52 | 3.15 | |
| &nbsp;&nbsp;&nbsp;&nbsp;41–56 | .63 | .40 | 1.87 | |
| &nbsp;&nbsp;&nbsp;&nbsp;57–69 | .10 | .25 | 1.11 | |
| Prior permanent access? | | | | .035 |
| &nbsp;&nbsp;&nbsp;&nbsp;Yes | .48 | .23 | 1.61 | |
| Dependent on dialysis? | | | | .028 |
| &nbsp;&nbsp;&nbsp;&nbsp;Yes | $-.68$ | .31 | .51 | |
| Cardiovascular disease? | | | | .001 |
| &nbsp;&nbsp;&nbsp;&nbsp;Yes | $-1.24$ | .38 | .29 | |
| Blood pressure at admission | | | | .250 |
| &nbsp;&nbsp;&nbsp;&nbsp;Low (versus normal) | $-.45$ | .38 | .64 | |

* High-dose heparin increases the odds of successful maturation by 2.86 times
* Younger age, not being on dialysis, not having cardiovascular disease, having had previous permanent access are all associated with higher prob. of success.

<!-- page 26 -->

*Figure 3. Histogram of predicted probabilities of success, $E(Y^1 | \mathbf{X}; \hat{\boldsymbol{\beta}})$ in AVF study.*

Figure 3 shows the distribution of predicted $Y$ under high-dose $A=1$

* Substantial variation among subjects
* The model distinguishes subjects with high success from those less likely to succeed

<!-- page 27 -->

*Table 4. Odds Ratios From Various Weighted and Unweighted Logistic Regression Models for the Association of Heparin With Surgical Success*

| | *Standard models (no weights)* | | | *Marginal structural models (weights)* | | |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| *Covariates in structural model ($V$)* | *Point estimate* | *95% confidence interval* | | *Point estimate* | *95% confidence interval* | |
| 1. None | 1.7 | 1.3 | 2.2 | 2.4 | 1.7 | 3.4 |
| 2. Age (3 terms), dialysis dependent,<br>&nbsp;&nbsp;&nbsp;&nbsp;history of cardiovascular<br>&nbsp;&nbsp;&nbsp;&nbsp;disease, prior vascular access,<br>&nbsp;&nbsp;&nbsp;&nbsp;admission mean arterial pressure | 2.2 | 1.6 | 3.0 | 2.9 | 2.1 | 4.0 |
| 3. Variables in 2, upstream venous diameter (three terms) | 2.7 | 2.1 | 3.6 | 2.9 | 2.1 | 4.1 |

NOTE: Heparin use is classified as high (at least 1,000 units during surgery) or low (less than 1,000 units; includes no use).

Three MSMs include models controlling for

1. No covariates in $\boldsymbol{V}$, but A only
2. The same covariates $\boldsymbol{V}$ as in our logistic MSM
3. All covariates $\boldsymbol{X}$, including the postsurgery variable

<!-- page 28 -->

Observations by comparing weighted and unweighted analyses

* Weighted form of all models provides a valid estimate of causal odds ratio
* Model 2 conditional on presurgery covariates $\boldsymbol{V}$ is useful for identifying subjects whose surgery is likely to succeed
* Under Model 2 we have OR(A)=2.2 vs. 2.9: the unweighted model $\text{E}(\text{Y}|V)$ doesn’t control for confounding by vessel size; in contrast, our MSM estimates control confounding by vessel size through weighting
* Under Model 3 we have similar effects OR(A)=2.7 vs. 2.9: both models control for confounding by vessel size. However, the model does not make the predictions on $E(Y^a|V)$, which is of greatest clinical interest.

<!-- page 29 -->

# Time dependent treatments

More notations:

* $A_1$: Exposure/treatment level at time 1 (e.g. anti-HIV drugs)
* $A_2$: Exposure/treatment level at time 2
* $Z$: a covariate measured between times 1 and 2 (e.g. HIV molecules detected in serum)
* $U$: an unmeasured common cause of $Z$ and $Y$ (e.g. immune function)
* $Y$: outcome measure after time 2
  e.g. CD4 cell $\text{count}/(m^3 \times 100)$, so 2.5 is $250\text{ cells}/m^3$

<!-- page 30 -->

**Goal**: Estimate the causal effect of time-varying treatment (both $A_1$ and $A_2$) on the outcome Y

$$
\begin{array}{ccccccc}
A_1 & \rightarrow & Z & \rightarrow & A_2 & \rightarrow & Y \\
& & \nwarrow & & & \nearrow & \\
& & & U & & &
\end{array}
$$

Figure 2

Dilemma:
* If we estimate the association of $(A_1, A_2)$ with Y <u>without</u> conditioning on Z, then there is an open pathway through $\text{A}_2$-Z-U-Y
* If we estimate the association of $(A_1, A_2)$ with Y <u>with</u> conditioning on Z, then there is an open pathway through $\text{A}_1$-U-Y

**What can we do?**

<!-- page 31 -->

## A SOLUTION (MSM):

$$
\begin{array}{ccccccc}
A_1 & \rightarrow & Z & \not\rightarrow & A_2 & \rightarrow & Y \\
& & \nwarrow & & & \nearrow & \\
& & & U & & &
\end{array}
$$

Remove $Z$-$A_2$ association $\rightarrow$ we estimate the causal effect from $(A_1, A_2)$ on $Y$ <u>without conditioning on $Z$</u>, since $A_2$-$Z$-$U$-$Y$ pathway is blocked by removing $Z$-$A2$ association

### How to remove the A2-Z association?

This is exactly what <u>marginal structural models</u> accomplish!

<!-- page 32 -->

### Estimation:

Observed Data

| N | Z | A1 | A2 | g(A) | Y |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 25 | 0 | 0 | 0 | 0 | 1.55 |
| 8 | 0 | 0 | 1 | .5 | 2.55 |
| 4 | 1 | 0 | 0 | 0 | 2.85 |
| 13 | 1 | 0 | 1 | .5 | 3.85 |
| 13 | 0 | 1 | 0 | .5 | 1.65 |
| 4 | 0 | 1 | 1 | 1 | 2.65 |
| 8 | 1 | 1 | 0 | .5 | 2.95 |
| 25 | 1 | 1 | 1 | 1 | 3.95 |

$g(A)$: a chosen function of $A1$ and $A2$,

For example, $g(A) = (A1+A2)/2$

Define $A=\{A1, A2\}$, estimate causal effect of $g(A)$ on $Y$!

<!-- page 33 -->

# Association Models with Parameter $\alpha's$

## – Without conditioning on Z:

Model 1: $\quad E(Y|g(A)) = \alpha_0 + \alpha_1 g(A)$

```r
> lm(Y~g.A, weight=N)

Call:
lm(formula = Y ~ g.A, weights = N)

Coefficients:
(Intercept)         g.A
      1.729       2.041
```

**$\rightarrow$ There is about 204 cells/$m^3$ difference**

<!-- page 34 -->

– **Conditioning on Z:**

Model 2: $E(Y|g(A), Z) = \alpha_0 + \alpha_1 g(A) + \alpha_2 Z$

```r
> lm(Y~g.A+Z, weight=N)

Call:
lm(formula = Y ~ g.A + Z, weights = N)

Coefficients:
(Intercept)          g.A            Z
      1.532        1.006        1.429
```

**$\rightarrow$ There is about 101 cells/$m^3$ difference**

<!-- page 35 -->

### MSM - Remove association between Z and A2:

Step 1: propensity model ($p_1 = pr(A_1 = a | \emptyset); p_2 = pr(A_2 = a | Z = z)$)

$$pr(A_1 = 0 | \emptyset) = \frac{50}{100}; \; pr(A_1 = 1 | \emptyset) = \frac{50}{100};$$

$$pr(A_2 = 0 | Z = 0) = \frac{38}{50}; \; pr(A_2 = 1 | Z = 0) = \frac{12}{50};$$

$$pr(A_2 = 0 | Z = 1) = \frac{12}{50}; \; pr(A_2 = 1 | Z = 1) = \frac{38}{50};$$

Step 2: derive weights: ($w = 1/(p_1 p_2)$)

| N | Z | A1 | A2 | g(A) | Y | w |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 25 | 0 | 0 | 0 | 0 | 1.55 | 2.63 |
| 8 | 0 | 0 | 1 | .5 | 2.55 | 8.33 |
| 4 | 1 | 0 | 0 | 0 | 2.85 | 8.33 |
| 13 | 1 | 0 | 1 | .5 | 3.85 | 2.63 |
| 13 | 0 | 1 | 0 | .5 | 1.65 | 2.63 |
| 4 | 0 | 1 | 1 | 1 | 2.65 | 8.33 |
| 8 | 1 | 1 | 0 | .5 | 2.95 | 8.33 |
| 25 | 1 | 1 | 1 | 1 | 3.95 | 2.63 |

<!-- page 36 -->

Step 3: create pseudo-population

Step 4: estimate MSM parameters without conditioning on Z

$$E(Y^a) = \beta_0 + \beta_1 g(a)$$

```r
> lm(Y~g.A, weight=N*w)

Call:
lm(formula = Y ~ g.A, weights = N * w)

Coefficients:
(Intercept)         g.A
      1.987       1.526
```

**$\rightarrow$ There is about 153 cells/$m^3$ difference**

<!-- page 37 -->

**In Summary:** MSMs can be used to estimate causal effect of a time-varying treatment on an outcome

Using Z to calculate the weights in MSM, rather than by adding Z to the regression model as regressors

<!-- page 38 -->

### Check association between A2 and Z:

* **In unweighted data:**

```r
> asso=glm(A2~Z, weight=N, family=binomial(link="logit"))
> exp(cbind("Odds ratio" = coef(asso), confint.default(asso, level = 0.95)))
            Odds ratio     2.5 %    97.5 %
(Intercept)  0.3157895 0.1650226  0.604299
Z           10.0277777 4.0050011 25.107690
```

Here, $N$ is the count in each cell defined by A1, A2, and Z

Note that the value of one is not in the estimated 95% CI (4, 25.1).

$$
\begin{array}{ccccccc}
A_1 & \rightarrow & Z & \rightarrow & A_2 & \rightarrow & Y \\
& & & \nwarrow & & \nearrow & \\
& & & & U & &
\end{array}
$$

<!-- page 39 -->

* **In weighted data**

```r
> asso.w=glm(A2~Z, weight=N*w, family=binomial(link="logit"))
Warning message:
In eval(family$initialize) : non-integer #successes in a binomial glm!
> exp(cbind("Odds ratio.w" = coef(asso.w), confint.default(asso.w, level = 0.95)))
            Odds ratio.w    2.5 %  97.5 %
(Intercept)     1.0002001 0.7580166 1.31976
Z               0.9995999 0.6753724 1.47948
```

Note that the value of one is in the estimated 95% CI (.675, 1.479)

$$
\begin{array}{ccccccc}
A_1 & \rightarrow & Z & \not\rightarrow & A_2 & & Y \\
& & & \nwarrow & & \nearrow & \\
& & & & U & &
\end{array}
$$

<!-- page 40 -->

# Stabilized weights

* The probabilities $pr(A = a|Z = z)$ may vary greatly between subjects $\rightarrow$ Extremely large values of the weight $\rightarrow$ Large variance of $\beta$ estimates
* Stabilized weights

$$w_i^s = pr(A = a_i)/pr(A = a_i|Z = z_i)$$

<!-- page 41 -->

# Revisit Example 3 – MSM estimation

Step 1: propensity model ($p_1 = pr(A_1 = a|\emptyset)$; $p_2 = pr(A_2 = a|Z = z)$)

$$pr(A_1 = 0|\emptyset) = \frac{50}{100}; \; pr(A_1 = 1|\emptyset) = \frac{50}{100};$$

$$pr(A_2 = 0|Z = 0) = \frac{38}{50}; \; pr(A_2 = 1|Z = 0) = \frac{12}{50};$$

$$pr(A_2 = 0|Z = 1) = \frac{12}{50}; \; pr(A_2 = 1|Z = 1) = \frac{38}{50};$$

Step 2: derive stabilized weights: $\left(sw = \frac{pr(A_1=a)pr(A_2=a)}{p_1 p_2}\right)$

| N | Z | A1 | A2 | g(A) | Y | w | sw |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 25 | 0 | 0 | 0 | 0 | 1.55 | 2.63 | 0.66 |
| 8 | 0 | 0 | 1 | .5 | 2.55 | 8.33 | 2.08 |
| 4 | 1 | 0 | 0 | 0 | 2.85 | 8.33 | 2.08 |
| 13 | 1 | 0 | 1 | .5 | 3.85 | 2.63 | 0.66 |
| 13 | 0 | 1 | 0 | .5 | 1.65 | 2.63 | 0.66 |
| 4 | 0 | 1 | 1 | 1 | 2.65 | 8.33 | 2.08 |
| 8 | 1 | 1 | 0 | .5 | 2.95 | 8.33 | 2.08 |
| 25 | 1 | 1 | 1 | 1 | 3.95 | 2.63 | 0.66 |

<!-- page 42 -->

# MSM vs. Propensity Score Weighting Method

## Similarities:

- Both methods involve creating weights derived from estimated propensity scores to balance covariates
- In special case when treatment is dichotomous and time-independent, MSM estimator becomes essentially equivalent to PS weighting estimator

## Differences:

- MSM explicitly models potential outcomes, making them more flexible and suitable for generalization to studies with non-dichotomous or time-dependent treatments.

<!-- page 43 -->

### R codes

```r
#----------------------------------------------------------
#Codes for MSM method
#----------------------------------------------------------
#-input data
      N=c(25,8,4,13,13, 4,8,25)
      Z=c(0,0,1,1,0,0,1,1)
      A1=c(0,0,0,0,1,1,1,1)
      A2=c(0,1,0,1,0,1,0,1)
      g.A=(A1+A2)/2
      Y=c(1.55,2.55,2.85,3.85,1.65,2.65,2.95,3.95)

#-input weights and stabilized weights for MSM estimation
      w=c(2.63,8.33,8.33,2.63,2.63,8.33,8.33,2.63)
      sw=c(.6579,2.0833,2.0833,.6579,.6579,2.0833,2.0833,.6579)

#-analyses under association models 1&2 and the MSM
      asso.1=lm(Y~g.A, weight=N)
      asso.2=lm(Y~g.A+Z, weight=N)
      msm.w=lm(Y~g.A, weight=N*w)
      msm.sw=lm(Y~g.A, weight=N*sw)

#-association between A2 and Z in unweighted vs. weighted data
      A2.Z=glm(A2~Z, weight=N, family=binomial(link="logit"))
      exp(cbind("Odds ratio" = coef(A2.Z), confint.default(A2.Z, level =
      0.95)))

      A2.Z.w=glm(A2~Z, weight=N*w, family=binomial(link="logit"))
      exp(cbind("Odds ratio.w" = coef(A2.Z.w), confint.default(A2.Z.w,
      level = 0.95)))
```

<!-- page 44 -->

*[No text on this page]*
