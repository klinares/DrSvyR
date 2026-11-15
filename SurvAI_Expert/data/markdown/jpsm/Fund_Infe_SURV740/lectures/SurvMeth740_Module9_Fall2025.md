---
id: "jpsm/Fund_Infe_SURV740/lectures/SurvMeth740_Module9_Fall2025"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Fundamentals of Inference"
original: "Fund_Infe_SURV740/lectures/SurvMeth740_Module9_Fall2025.pdf"
pages: 62
sha256: "b589014ae0835c38e9ab4aa2ffb14f5246af3d4d990eba7c80011eff57b155ff"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:04"
---

<!-- page 1 -->

# Fundamentals of Inference

Barry Graubard ([email])
SurvMeth / Surv 740
Module 9, Fall 2025

1

<!-- page 2 -->

# Topics in Inference

* **Methods for Making Finite Population Inference**

  * **Design-Based** vs. **Model-Based**
    * **Design-Based**
      * **Random Sample Surveys**
      * Randomized Experiments
    * **Model-Based**
      * **Frequentist**
      * **Bayesian**

* **Add Superpopulation Model to provide Finite Population**

  * **Superpopulation**
    * **Design-Based** vs. **Model-Based**
      * **Design-Based**
        * **Random Sample Surveys**
        * Randomized Experiments
      * **Model-Based**
        * **Frequentist**
        * **Bayesian**

2

<!-- page 3 -->

# Horvitz-Thompson (HT) Estimator

-
- Estimand of interest: Population Total, $Q(Y) = \sum_{j=1}^{N} Y_j$
- Survey Design and Estimation Procedure, $q(y)$:

*Survey design:*

$$Pr(I_j = 1) = \pi_j, j = 1, ..., N$$

*Sample*

$$\{y_1, y_2, ..., y_n\} \subset \{Y_1, Y_2, ..., Y_N\}$$

*HT estimator:*

$$q(y) = \sum_{i=1}^{n} y_i / \pi_i = \sum_{j=1}^{N} I_j Y_j / \pi_j$$

Can write $q(y) = \sum_{i=1}^{n} w_i y_i$, $w_i = 1 / \pi_i$ as a sample weighted total.

3

<!-- page 4 -->

# Horvitz-Thompson Estimator: Properties

- $q(y)$ is an unbiased estimator of $Q(Y)$ for any set of values of $Y$:

$$E[q(y)] = \sum_{j=1}^N E(I_j)Y_j/\pi_j = \sum_{j=1}^N Y_j = Q(Y)$$

$$(note: E(I_j) = Pr(I_j = 1) = \pi_j)$$

- A related estimator, $q(y)$, of the population mean $Q(Y) = \frac{1}{N} \sum_{j=1}^N Y_j$:

$$q(y) = \sum_{i=1}^n (y_i/\pi_i) / \sum_{i=1}^n (1/\pi_i).$$

If $\sum_{i=1}^n 1/\pi_i = N$, then $E[q(y)] = Q(Y)$, i.e., $q(y)$ is an unbiased estimator of $Q(Y)$.

Often only $E[\sum_{i=1}^n 1/\pi_i] = E[\sum_{j=1}^N I_j/\pi_j] = N$ then $q(y)$ is a ratio estimator of $Q(Y)$.

So $E[q(y)] \neq Q(Y)$, i.e., is biased, but $q(y)$ is a consistent (see Module 7 slide 46) estimator of $Q(Y)$.

4

<!-- page 5 -->

# Unbiased on average, but...

* An estimator can be unbiased, i.e., averaged across all samples
* But we only select one sample....
* What if no sample is “good” by itself?

5

<!-- page 6 -->

# Basu’s Elephant: Circus Manager vs. Statistician

* A circus has a herd of 11 elephants of varying sizes
  * Given the food needed when going from one town to another, the manager needs an estimate of the total weight of the herd
* But only one elephant can be weighed!
* For years, the circus manager takes the following approach:
  * Pick out one elephant that he considers to be the “middle-of-the-herd” in terms of weight
  * Weigh that elephant and multiply by 11
* He has not been sure about his methodology and somebody told him that what he is doing is not a probability sample

6

<!-- page 7 -->

# Basu's Elephant, continued

* Circus manager meets a statistician and describes his method
* Statistician sees some value in the methodology but suggests a modification to make it a probability sampling design
* Proposed design:
  - Choose the the middle of the herd elephant with probability 0.9
  - Assign the selection probability of 0.01 to each of the remaining 10 elephants
  - Use Horvitz-Thompson procedure for estimating the total
* Circus manager then decides to implement this method but soon got into big trouble

7

<!-- page 8 -->

# Basu’s Elephant: Trouble!

* Suppose that the 11 elephants’ weights (in pounds) are $\{9000, 9500, 10000, 10100, 10500, 11000, 11100, 11600, 11700, 12800, 13500\}$: **sum=120,800,** mean=10,982
* Statistician’s procedure:
  – If the selected value is 11,000: the estimate of the TOTAL weight is $11,000/0.9=12,222$ !!!
  – If the selected value is 13,500: the estimate of the total weight is $13,500/0.01=1,350,000$ !!!!
  – If the selected value is 9,000: the estimate of the total is $9,000/0.01=900,000$!!!
  – **<u>Every</u> estimate is problematic but the average (weighted by the probability of the sample) is the true value**
* Previous estimate by circus manager: **$11,000 \times 11 = 121,000$**
* Circus fired the statistician, gave a bonus to the manager
* Basu jokes that now the statistician decides to become a professor
* **Reference:** Basu, D. (1971). An essay on the logical foundations of survey sampling, Part 1 (with discussion), In: Godambe and Sprott (Eds.), Foundations of Statistical Inference, 203–242, Holt, Reinhart and Winston, Toronto. pp. 212-213.

8

<!-- page 9 -->

# Model-Based Inference

* Basu’s elephant example is an extreme case of where the randomization (design-based) approach to inference can lead to poor conclusions based on a single sample.
* We consider an overview of **model-based inference**
* What is a model in this context?
* We will first talk about Frequentist inference and then Bayesian inference that are both model-based

9

<!-- page 10 -->

# Statistical Models

* A **statistical model** is a [mathematical model]() that embodies a set of [statistical assumptions]() concerning the generation of [sample data]() (and similar data from a larger [population]()). A statistical model represents, often in considerably idealized form, the **data-generating process.** (ref. Wikipedia)
  * Think of a machine, governed by parameters (regression coefficients, variances, etc.), that continuously spits out data!
* A **statistical model** is usually specified as a mathematical relationship between one or more [random variables]() and other non-random variables.

10

<!-- page 11 -->

# Statistical Models

***“All models are wrong, but some models are useful.”*** -- Box

11

<!-- page 12 -->

# Two Major Issues in Estimation and Inferential for Analyzing Complex Survey Data

* Sample weighting
  - Use of sample design weights vs. not use of sample design weights (unweighted) in estimation and inference

* Variance estimation
  - Use of design-based vs. model-based variance estimation

    Design-based variance estimation take account of the sample design, e.g., sample weights, any stratification or clustering, in the variance estimation without strong model assumptions, e.g., uses Taylor linearization method and replication methods like jackknife or bootstrap to estimate the variances.

    Model-based variance estimation may not fully take account of the sample design and can make model assumptions, e.g., normal distribution of the data.

12

<!-- page 13 -->

# Design weighted vs. Unweighted estimation of means

- Design-based weighted estimators give approximately unbiased estimates of population parameters.
  Why not always do weighted estimation?
  One reason weighted estimation can be inefficient. Consider

$$\bar{y}_w = \frac{\sum_{i=1}^n w_i y_i}{\sum_{i=1}^n w_i} \text{ and } \bar{y}_u = \frac{\sum_{i=1}^n y_i}{n}$$

- Consider a probabilistic model:
  Let sample weights $w_i$ be fixed constants and $y_i$ are iid (independent identically distributed) random variables with mean $\mu$ variance $\sigma^2$ (similar to the superpopulation setup in Module 7 slide 49) then $\bar{y}_w$ and $\bar{y}_u$ are unbiased estimators for $\mu$, i.e.,

$$E[\bar{y}_w] = E\left[ \frac{\sum_{i=1}^n w_i y_i}{\sum_{i=1}^n w_i} \right] = \frac{\sum_{i=1}^n w_i E[y_i]}{\sum_{i=1}^n w_i} = \frac{\sum_{i=1}^n w_i \mu}{\sum_{i=1}^n w_i} = \mu$$

$$\text{and } E[\bar{y}_u] = E\left[ \frac{\sum_{i=1}^n y_i}{n} \right] = \frac{\sum_{i=1}^n E[y_i]}{n} = \frac{\sum_{i=1}^n \mu}{n} = \mu$$

  Note $w_i$ are unrelated to $y_i$. It can be shown that

$$Var(\bar{y}_w) = \sigma^2 \sum_{i=1}^n w_i^2 / (\sum_{i=1}^n w_i)^2$$

$$Var(\bar{y}_u) = \sigma^2 / n .$$

### Module 7 slide 49
- Let the target finite population values be $\{Y_1, Y_2, \cdots, Y_N\}$ be generated from a superpopulation model:
  $Y_i$ are independent and identically distributed random variables with mean $\mu$ and variance $\sigma^2$.

13

<!-- page 14 -->

# Design weights vs. unweighted for estimation of means

- How much smaller is $Var\bar{y}_u$ than $Var\bar{y}_w$? (Assume $y_i$ are iid random variables with mean $\mu$ variance $\sigma^2$)

$$inefficiency_0 = \frac{Var\bar{y}_w - Var\bar{y}_u}{Var\bar{y}_w} = 1 - \frac{Var\bar{y}_u}{Var\bar{y}_w}$$

$$= 1 - \frac{(\sum_{i=1}^n w_i)^2}{n \sum_{i=1}^n w_i^2} \approx \frac{CV^2}{1 + CV^2}$$

$CV = \frac{\sqrt{\frac{1}{n-1} \sum_{i=1}^n (w_i - \bar{w})^2}}{\frac{1}{n} \sum_{i=1}^n w_i}$ the coefficient of variation of sample weights, i.e., the standard deviation of the weights divided by mean of the weights.

- $Inefficiency_0$ is the proportional decrease in the variance by using $\bar{y}_u$ instead of $\bar{y}_w$.
  How does the $inefficiency_0$ above relate to $deff_{weight}$ defined on slide 20 of Module 8?
  Recall that the $deff_{weight} = 1 + CV^2$ then $inefficiency_0 = 1 - (deff_{weight})^{-1}$

The subscript“$0$" in "$Inefficiency_0$" refers to the computation when $\bar{y}_u$ is unbiased for the population mean, i.e., $w_i$ are unnecessary or called “noninformative”.

14

<!-- page 15 -->

# Table shows $Inefficiency_0$ varies by survey and subpopulation

**Table 4.4-2. Inefficiency of Using Sample Weights when Unnecessary (Formula (4.4-3)) for Some Data Sets Analyzed in This Book**

| Survey$^a$ | Restrictions | Sample Size | Coefficient of Variation of the Weights | $\text{Inefficiency}_0$ |
| :--- | :--- | :---: | :---: | :---: |
| NHANES III | (a) Men ages 50+ years<br>(b) Medical examination | 3092 | 115% | 57% |
| 1988 NMIHS | Live births | 9953 | 98% | 49% |
| NHANES I Epidemiologic Followup Study | (a) Women ages 25–74 years<br>(b) 1971-74 NHANES I component | 5270 | 97% | 48% |
| NHANES II | Boys ages 2–18 years | 3667 | 71% | 34% |
| 1986 NMFS | Digestive cancer deaths | 785 | 60% | 26% |
| 1987 NHIS | (a) Men ages 18+ years<br>(b) Cancer control or epidemiology supplements | 16,008 | 53% | 22% |
| NHANES II | White men ages 40–59 years | 595 | 41% | 14% |
| HHANES | Ages 2–11 years | 2012 | 24% | 5% |
| LSOA (baseline weights) | Women | 4667 | 21% | 4% |

$^a$Brief descriptions of these surveys are given in Appendix A

**Definition of acronyms**
**NHANES** = National Health and Nutrition Examination Survey
**NMIHS** = National Maternal and Infant Health Survey
**NMFS** = National Mortality Followback Health Survey
**NHIS** = National Health Interview Survey
**HHANES** = Hispanic Health and Nutrition Examination Survey
**LSOA** = Longitudinal Study on Aging

15

<!-- page 16 -->

# Design weights vs. unweighted for estimation of means

* $Inefficiency_0 = 1 - \frac{Var(\bar{y}_u)}{Var(\bar{y}_w)} \approx \frac{CV^2}{CV^2 + 1}$ may not be accurate:
* Does not account for the actual sample design and adjustments to weights.
  Stratification and poststratification can reduce variance of $\bar{y}_w$.
  Additionally, sampling may lead to correlation between $y_i$ and $w_i$, e.g., if the selection probabilities are $\approx$ proportional to the $y_i$ and/or $y_i$ may be correlated if there is cluster sampling ($\rho$).
* Only accounts for analyses of single means, e.g., not differences in means or regression coefficients.
* General expression for one dimensional parameter

$$Inefficiency_0 = 1 - \frac{Var(\hat{\theta}_u)}{Var(\hat{\theta}_w)}$$

  estimated by

$$Inefficiency_0 = 1 - \frac{\widehat{var}(\hat{\theta}_u)}{\widehat{var}(\hat{\theta}_w)}$$

  "$\widehat{var}$" is an estimated variance incorporating the sample design, e.g., using Taylor linearization or a replication such as jackknife variance estimation.

16

<!-- page 17 -->

# Modeling sample weights, an alternative to sample weighted (HT) estimation:
# A frequentist approach

* Estimating a Population Mean

* Estimating a Population Mean Difference

* Estimating a General Parameter – Linear and Logistic Regression

17

<!-- page 18 -->

# Modeling sample weights, an alternative to sample weighted (HT) estimation: A frequentist approach

* Estimating a Population Mean
* Estimating a Population Mean Difference
* Estimating a General Parameter – Linear and Logistic Regression

18

<!-- page 19 -->

# Estimating a Population Mean

* When inefficiency of sample weighting (based on $Inefficiency_0$) is unacceptably large, one might consider alternative approaches.

* One approach is augmenting the analysis model with additional variables used for the survey design and then use unweighted estimation.

* Consider we want to estimate a population mean $\bar{Y} = \frac{1}{N} \sum_{i=1}^N Y_i$ for a variable $Y$ using a stratified random sample of size $n$ with sex as the sampling strata, where there is over sampling of women, i.e.,

$$n_{women}/N_{women} > n_{men}/N_{men}\text{, where } N = N_{men} + N_{women}, n = n_{women} + n_{men}.$$

* Suppose $Inefficiency_0$ of $\bar{y}_w$ relative to $\bar{y}_u$ is mostly from the oversampling of the women.

19

<!-- page 20 -->

# Estimating a Population Mean (Cont.)

* Consider first estimating stratified population $\bar{Y}_{women}$ and $\bar{Y}_{men}$ by $\bar{y}_{w,women}$ and $\bar{y}_{w,men}$, each of these two sex specific sample means have little inefficiency. But we want to estimate $\bar{Y}$. One way is putting these two estimators $\bar{y}_{w,women}, \bar{y}_{w,men}$ together as

$$
\bar{y}_{model} = (N_{women}\bar{y}_{w,women} + N_{men}\bar{y}_{w,men}) / (N_{men} + N_{women}),
$$

$\bar{y}_{model}$ is an unbiased estimator for $\bar{Y}$ (assume that the $N_{men}, N_{women}$ are known) because $\bar{y}_{w,women}, \bar{y}_{w,men}$ are unbiased for $\bar{Y}_{women}$ and $\bar{Y}_{men}$. This is modeling the mean using the variable sex. Is $\bar{y}_{model}$ more efficient than $\bar{y}_w$? Answer is No.

* BTW you can use sample weighted linear regression modeling to obtain $\bar{y}_{w,women}, \bar{y}_{w,men}$:

$$
y_i = \alpha + \gamma s_i + e_i
$$

$s_i = 1$ or $0$ for women or men, respectively. Then $\bar{y}_{w,women} = \hat{\alpha}_w + \hat{\gamma}_w$ and $\bar{y}_{w,men} = \hat{\alpha}_w$.

20

<!-- page 21 -->

# Modeling survey design sample weighting, an alternative to sample weighted (HT) estimation:
# A frequentist approach

* Estimating a Population Mean

* Estimating a Population Mean Difference

* Estimating a General Parameter – Linear and Logistic Regression

21

<!-- page 22 -->

# Estimating a Population Mean Difference

* Controlling for sample design variable (e.g., sex) is more complicated but potentially more useful for estimating association between variables.

* E.g., consider estimating population mean difference of a continous outcome $Y$ for individuals exposed to high (HI) and low (LO) levels of risk factor,

$$DIF = \bar{Y}_{HI} - \bar{Y}_{LO}$$

  with weighted mean estimated difference

$$dif = \bar{y}_{HI} - \bar{y}_{LO}$$

* Suppose $dif$ is highly inefficient estimator of $DIF$ due to highly variable sample weights (i.e., large CV of $w_i'$s for the HI, LO). If a large part of the variability is from oversampling women the sex-specific mean differences

$$dif_{men} = \bar{y}_{w,HI,men} - \bar{y}_{w,LO,men}$$

$$dif_{women} = \bar{y}_{w,HI,women} - \bar{y}_{w,LO,women}$$

  will not be so inefficient.

22

<!-- page 23 -->

# Estimating a Population Mean Difference (cont.)

* There may be substantive reasons why $dif_{men}, dif_{women}$ are of equal or of more importance than $dif$. Note that these sex-specific differences will have lower inefficiency.

* Returning to estimating $DIF$, there are two choices for the pop. parameter for the overall association of risk factor and $Y$

$$DIF = \bar{Y}_{HI} - \bar{Y}_{LO}$$

  and

$$DIF_{Strat} = \frac{N_{men}DIF_{men} + N_{women}DIF_{women}}{N_{men} + N_{women}}$$

* $DIF$ and $DIF_{Strat}$ can be quite different even when $DIF_{men} = DIF_{women}$; see Table 4.5-1 where $DIF_{Strat} = 0.2$ but $DIF = 0.34$. Why? Sex is related to High-risk vs. Low-risk membership and sex is related to population mean of Y (higher mean values of Y in Men than Women)

23

<!-- page 24 -->

# Estimating a Population Mean Difference (cont.)

**Table 4.5-1. Population Means (Population Sizes) for a Hypothetical Population by Sex and Risk Group**

| | Men | Women | Total |
| :--- | :--- | :--- | :--- |
| **Group 1 (high risk)** | $.8\ (2 \times 10^6)$ | $.4\ (10^6)$ | $.67\ (3 \times 10^6)$ |
| **Group 2 (low risk)** | $.6\ (10^6)$ | $.2\ (2 \times 10^6)$ | $.33\ (3 \times 10^6)$ |
| **Group difference** | $.2$ | $.2$ | $.34$ |

* 2 questions:
    (1) When is it appropriate to estimate $DIF_{Strat}$ instead of $DIF$? E.g., if the objective is to change people’s risk factor status from high to low then $DIF_{Strat}$ gets closer to the expected difference within individuals.
    (2) Are estimators of $DIF_{Strat}$ as variable as estimators of $DIF$? This will depend on how $DIF_{Strat}$ is estimated.

24

<!-- page 25 -->

# Estimating a Population Mean Difference (cont.)

* A natural estimator of $DIF_{Strat}$ is

$$dif_{Strat} = \frac{N_{men}dif_{men} + N_{women}dif_{women}}{N_{men} + N_{women}}$$

will tend to be as variable as $dif = \bar{y}_{HI} - \bar{y}_{LO}$.

* Instead of $dif_{Strat}$, we consider using linear regression modeling that includes sex as a covariate:

$$y_i = \alpha + \beta r_i + \gamma s_i + e_i$$

where for each sample person the binary variables $r = 0$ or $1$ according to low or high risk factor levels, $s = 0$ or $1$ according to sex and $e$ is the error. Estimate the parameters $\alpha, \beta, \gamma$ using unweighted (sample weights are all 1) ordinary-least-squares (OLS) estimation, then $\hat{\beta}_u$ is an estimate of the difference in HI and LO levels of risk factor adjusting the sampling strata of sex by including sex in the regression model.

* If $DIF_{men} = DIF_{women}$ , i.e., no $r$ by $s$ interaction in the finite population, then $\hat{\beta}_u$ will be approximately unbiased for $DIF_{Strat}$. If most of variability of the weights are due to over sampling women then $\hat{\beta}_u$ will be more efficient that the weighted estimator of $\beta$.

25

<!-- page 26 -->

# Summary - Estimating a Population Mean Difference

* If it can be substantively justified to control for a variable in an analysis, e.g., sex, then estimate risk/outcome differences separately by that variable.

* If an overall measure of association is of interest, e.g., mean difference of $Y$ for HI vs. LO risk factor is required, and if risk factor-by-sample design variables interactions are small then using an unweighted regression model including the sample design variables as main effects in the regression model, e.g., the sample design stratification variable sex as a (main effect) covariate, can result in more efficient estimation of risk factor/outcome association.

26

<!-- page 27 -->

# Modeling survey design sample weighting, an alternative to sample weighted (HT) estimation:
# A frequentist approach

* Estimating a Population Mean

* Estimating a Population Mean Difference

* Estimating a General Parameter – e. g., coefficients for linear or logistic regression

27

<!-- page 28 -->

# A data example modeling survey design to estimate an association

* What is the association between maternal smoking and education?

* The data from the 1988 National Maternal and Infant Health Survey (NMIHS)

* Logistic regression modeling

28

<!-- page 29 -->

# 1988 National Maternal and Infant Health Survey (NMIHS)

* Use the live birth component of the 1988 NMIHS. Stratified random sample of 13,415 birth certificates from a list frame of about 3.9 million live births.

* Higher sampling rates (oversampling) for black vs. nonblack babies and low-birthweight vs. normal birthweight babies .

* Mothers were queried (mail or phone or face-to-face) to obtain information not on the birth certificates, e.g., maternal smoking, 9,953 responded.

* Nonresponse adjustments to original sample weights were based on birthweight, race, marital status and maternal age.

* Poststratification adjustments of weights to vital statistics based on same variables as nonresponse adjustments.

29

<!-- page 30 -->

# Data example modeling survey design to estimate an association in NMIHS

**Table 4.2-1. Sampling Strata and Sampling Rates of 1988 NMIHS**

| Stratum Number | Strata: Race | Strata: Birthweight (grams) | Sampling Rate | Base Sample Weight |
| :---: | :---: | :---: | :---: | :---: |
| | **Black** | | | |
| 1 | | $< 1500$ | $1/14$ | $14$ |
| 2 | | $1500\text{–}2499$ | $1/55$ | $55$ |
| 3 | | $\ge 2500$ | $1/113$ | $113$ |
| | **Nonblack** | | | |
| 4 | | $< 1500$ | $1/29$ | $29$ |
| 5 | | $1500\text{–}2499$ | $1/160$ | $160$ |
| 6 | | $\ge 2500$ | $1/720$ | $720$ |

30

<!-- page 31 -->

# Data example modeling survey design to estimate an association in NMIHS

**Table 4.2-2. Percent Distribution of Live Births by Age of Mother, United States, 1988**

| Age of Mother (Years) (1) | Vital Statistics$^a$ (2) | NMIHS-Sampled Birth Certificates ($n = 13,415$) Weighted (3) | NMIHS-Sampled Birth Certificates ($n = 13,415$) Unweighted (4) | NMIHS-Interviewed Mothers Only ($n = 9953$) Fully Weighted$^b$ (5) | NMIHS-Interviewed Mothers Only ($n = 9953$) Partially Weighted$^c$ (6) | NMIHS-Interviewed Mothers Only ($n = 9953$) Partially Weighted$^d$ (7) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 15–19 | 12.3 | 12.3 | 17.5 | 12.3 | 12.2 | 10.9 |
| 20–24 | 27.4 | 27.6 | 29.9 | 27.4 | 27.6 | 26.4 |
| 25–29 | 31.8 | 31.5 | 28.0 | 31.7 | 31.5 | 32.5 |
| 30–34 | 20.6 | 20.6 | 17.6 | 20.6 | 20.6 | 22.0 |
| 35–39 | 6.9 | 6.9 | 6.1 | 6.9 | 6.9 | 7.1 |
| 40–44 | 1.0 | 1.0 | 0.9 | 1.1 | 1.1 | 1.1 |
| 45–49 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 |

$^a$Based on $N = 3,898,922$ birth certificates; $10,588$ births with mothers under the age of 15 have been excluded to be consistent with the sample frame of 1988 NMIHS. Data are from NCHS (1990, p. 97).
$^b$Sample weights incorporate differential probabilities of selection, nonresponse and poststratification adjustments.
$^c$Sample weights only incorporate differential probabilities of selection, and nonresponse adjustments.
$^d$Sample weights only incorporate differential probabilities of selection.

31

<!-- page 32 -->

# Data example modeling survey design to estimate an association in NMIHS

* Using logistic regression to study education association with maternal smoking:

$$log\left(\frac{\pi}{1 - \pi}\right) = \alpha + \beta_{race}I(Black) + \beta_{ed1}I(educ < 12) + \beta_{ed2}I(educ > 12)$$

$\pi$ is probability that mother smoked and $I(\cdot)$ are dummy indicator variables, $ed1$ and $ed2$ for $educ < 12$ and $educ > 12$. Note birthweight was not included to avoid over-adjustment since smoking reduces birthweight. However, marital status and maternal age could have been included.

**Table 4.3-4. Logistic Regression Analysis of the Probability of Smoking on Race and Mother's Education**

| Independent Variable | Weighted Coefficient $\pm$ SE | Unweighted Coefficient $\pm$ SE |
| :--- | :---: | :---: |
| Intercept | $-.45 \pm .06$ | $-.52 \pm .05$ |
| Race (black vs. nonblack) | $-.33 \pm .05$ | $-.33 \pm .04$ |
| Mother's education $< 12$ years vs. $12$ years | $-.26 \pm .07$ | $-.03 \pm .05$ |
| Mother's education $> 12$ years vs. $12$ years | $-.88 \pm .08$ | $-.63 \pm .06$ |

Data from the 1988 NMIHS.

32

<!-- page 33 -->

# Data example modeling survey design to estimate an association in NMIHS

- Using logistic regression:

$$
log\left(\frac{\pi}{1 - \pi}\right) = \alpha + \beta_{race}I(Black) + \beta_{ed1}I(educ < 12) + \beta_{ed2}I(educ > 12) + \beta_{race \times ed1}I(Black, ed1) + \beta_{race \times ed2}I(Black, ed2)
$$

where $\pi$ is probability maternal smoking.

**Table 4.3-5. Logistic Regression Analysis of the Probability of Smoking on Mother’s Education, Separately for Blacks and Nonblacks**

| Independent Variable | Blacks Weighted Coefficient $\pm$ SE | Blacks Unweighted Coefficient $\pm$ SE | Nonblacks Weighted Coefficient $\pm$ SE | Nonblacks Unweighted Coefficient $\pm$ SE |
| :--- | :---: | :---: | :---: | :---: |
| Intercept | $-1.12 \pm .06$ | $-1.03 \pm .05$ | $-.38 \pm .06$ | $-.30 \pm .05$ |
| Mother's education $< 12$ years vs. 12 years | $.24 \pm .08$ | $.24 \pm .07$ | $-.37 \pm .08$ | $-.33 \pm .07$ |
| Mother's education $> 12$ years vs. 12 years | $-.23 \pm .10$ | $-.26 \pm .09$ | $-.99 \pm .10$ | $-.97 \pm .08$ |

Data from the 1988 NMIHS.

33

<!-- page 34 -->

# Modeling survey design sample weighting: Estimating a general parameter

* Begin with a model for the analysis if you had a simple random sample, i.e., unweighted.

* Check the inefficiency of the estimator $\hat{\theta}$ of interest
$$Inefficiency_0 = 1 - \frac{\widehat{var}(\hat{\theta}_u)}{\widehat{var}(\hat{\theta}_w)}$$

* If $Inefficiency_0$ for $\hat{\theta}_w$ is unacceptably large then consider adding variables used in construction of the sample weights (sample design variables).

* These variables should not lessen the interpretability of $\theta$, e.g., in a regression $\theta$ is the coefficient for an independent variable $x$ and some of the added variables are mediators for the association of $x$ to $y$.

* Do unweighted regression estimation with added sample design variables as (main effects) covariates, i.e., $\hat{\theta}_u$, and compare to weighted estimation for $\hat{\theta}_w$ with same added design variables. You can test if the estimated $\hat{\theta}_u - \hat{\theta}_w$ is significant (this test has low power). Substantive evaluation of the difference is often needed. If difference is large then use weighted estimation. Can consider truncating weights to improve efficiency of weighted analyses (Korn and Graubard 1995)

34

<!-- page 35 -->

# Statistical Models

* The **Normal distribution** is a model we often use in linear regression to describe features of population
  – Mathematical representation of reality
  – Do design-based methods use normal theory?
    * There is argument about this (Hansen et al., 1983, on Canvas)
    * **Design-Based Methods :** Use large samples and rely on convergence of the sample distribution to normality across hypothetical repeated samples

35

<!-- page 36 -->

# Bayes Models

* Wikipedia: “**Bayesian probability** is an <u>interpretation of the concept of probability</u>, in which, instead of <u>frequency</u> or <u>propensity</u> of some phenomenon, probability is interpreted as reasonable expectation representing (incorporating) a state of knowledge or as quantification of a personal belief (subjectivity).”
* This in contrast to long run expectations defining the design-based (or frequentist) approach.
* Bayesian approach offers ways to build models and perform estimation and inference for complicated problems where frequentist are difficult and not obvious.
    - Hierarchical modeling as can be used small area estimation.
    - Missing data problems, e.g., multiple imputation

36

<!-- page 37 -->

# Bayes and Subjectivity

* Some Bayesian statisticians make a strong subjectivity assumption: probability is “quantification of a personal belief” as reflected in the extent of informativeness of the chosen prior distribution of the parameters to be estimated or inferred.
* Other Bayesians argue that prior knowledge is always employed to some extent, e.g., substantive knowledge could restrict the range of possible values the parameters can be. The Bayesian perspective is way to formalize this prior knowledge.
  * Prior distribution is explicit and needs careful justification
* May disagree about the nature of the prior:
  * Uninformative prior? (sometimes call a “diffuse prior” or “flat prior”)
    * Reflects a lack of knowledge of the parameters? What is a lack of knowledge?
  * Empirical Bayesian (construct priors based on (previous) data analyses)

37

<!-- page 38 -->

# Bayes Theorem

* Developed in the 18th Century
* For an event A and event B then the conditional probability of occurrence of event A given the occurrence of event B is written as $P(A|B) = \frac{P(A \cap B)}{P(B)}$
* Bayes Theorem says:
$$P(A|B) = \frac{P(B|A)P(A)}{P(B)} \text{ (because } P(B|A) = \frac{P(A \cap B)}{P(A)}\text{)}$$
* One application of Bayes Theorem: The probability that a patient has a disease given that they tested positive for that disease can be found using the probability that the test yields a positive result when the disease is present.

38

<!-- page 39 -->

# Application of Bayes Theorem

* An example:
  * COVID testing (made up)
  * Assuming 5% have COVID
  * COVID test has a true positive rate of 90% (If have COVID, 90% test positive)
  * COVID test has true negative rate of 80% (If not have COVID, 80% are false positive)
  * What is the Positive Predictive Value (PPV)? True Positives/Tested Positives
* $PPV = P(COVID | Positive\ Test) = \frac{P(Positive\ Test | COVID)P(COVID)}{P(Positive\ Test)}$

| | COVID | Not COVID | Total |
| :--- | :--- | :--- | :--- |
| Positive Test | | | |
| Negative Test | | | |
| Total | | | 1000 |

### Bayes Theorem

$$
P(A|B) = \frac{P(B|A)P(A)}{P(B)}
$$

39

<!-- page 40 -->

# Application of Bayes Theorem

* An example:
  - COVID testing (made up)
  - Assuming 5% have COVID
  - COVID test has a true positive rate of 90% (If have COVID, 90% test positive)
  - COVID test has true negative rate of 80% (If not have COVID, 80% are false positive)
  - What is the Positive Predictive Value (PPV)? True Positives/Tested Positives

* $PPV = P(COVID|Positive\ Test) = \frac{P(Positive\ Test|COVID)P(COVID)}{P(Positive\ Test)}$

| | COVID | Not COVID | Total |
| :--- | :---: | :---: | :---: |
| Positive Test | | | |
| Negative Test | | | |
| Total | 50 | | 1000 |

Bayes Theorem

$$P(A|B) = \frac{P(B|A)P(A)}{P(B)}$$

40

<!-- page 41 -->

# Application of Bayes Theorem

* An example:
  - COVID testing (made up)
  - Assuming 5% have COVID
  - COVID test has a true positive rate of 90% (If have COVID, 90% test positive)
  - COVID test has true negative rate of 80% (If not have COVID, 80% are false positive)
  - What is the Positive Predictive Value (PPV)? True Positives/Tested Positives

* $PPV = P(COVID | Positive\ Test) = \frac{P(Positive\ Test | COVID)P(COVID)}{P(Positive\ Test)}$

| | COVID | Not COVID | Total |
| :--- | :---: | :---: | :---: |
| Positive Test | 45 | | |
| Negative Test | 5 | | |
| Total | 50 | | 1000 |

### Bayes Theorem

$$P(A|B) = \frac{P(B|A)P(A)}{P(B)}$$

41

<!-- page 42 -->

# Application of Bayes Theorem

* An example:
  - COVID testing (made up)
  - Assuming 5% have COVID
  - COVID test has a true positive rate of 90% (If have COVID, 90% test positive)
  - COVID test has true negative rate of 80% (If not have COVID, 80% are false positive)
  - What is the Positive Predictive Value (PPV)? True Positives/Tested Positives
* $PPV = P(COVID | Positive\ Test) = \frac{P(Positive\ Test | COVID)P(COVID)}{P(Positive\ Test)}$

| | COVID | Not COVID | Total |
| :--- | :---: | :---: | :---: |
| Positive Test | 45 | 190 | |
| Negative Test | 5 | 760 | |
| Total | 50 | 950 | 1000 |

Bayes Theorem

$$P(A|B) = \frac{P(B|A)P(A)}{P(B)}$$

42

<!-- page 43 -->

# Application of Bayes Theorem

* An example:
  - COVID testing (made up)
  - Assuming 5% have COVID
  - COVID test has a true positive rate of 90% (If have COVID, 90% test positive)
  - COVID test has true negative rate of 80% (If not have COVID, 80% are false positive)
  - What is the Positive Predictive Value (PPV)? True Positives/Tested Positives

* $PPV = P(COVID | Positive\ Test) = \frac{P(Positive\ Test | COVID)P(COVID)}{P(Positive\ Test)}$

| | COVID | Not COVID | Total |
| :--- | :---: | :---: | :---: |
| Positive Test | 45 | 190 | 235 |
| Negative Test | 5 | 760 | 765 |
| Total | 50 | 950 | 1000 |

### Bayes Theorem

$$P(A|B) = \frac{P(B|A)P(A)}{P(B)}$$

43

<!-- page 44 -->

# Application of Bayes Theorem

* $PPV = P(COVID|Positive\ Test) = \frac{P(Positive\ Test|COVID)P(COVID)}{P(Positive\ Test)}$

$$= \frac{\frac{45}{50} \times \frac{50}{1000}}{\frac{235}{1000}} = \frac{45}{235} = 0.19$$

| | COVID | Not COVID | Total |
| :--- | :--- | :--- | :--- |
| Positive Test | 45 | 190 | 235 |
| Negative Test | 5 | 760 | 765 |
| Total | 50 | 950 | 1000 |

44

<!-- page 45 -->

# Bayes Theorem

* Start with selecting $P(\theta)$ the Prior Distribution of $\theta$ (based on prior belief) and the observed sample data $y = \{y_1, y_2, \dots, y_n\}$ then apply Bayes Theorem to obtain $P(\theta|y)$ Posterior Distribution of $\theta$ given observed data $y$:
  $P(\theta|y) = \frac{P(\theta)P(y|\theta)}{P(y)}$, $\theta$ are the parameters that are random quantities (unlike Design-Based and Frequentist approaches)
  $P(\theta|y)$ is an **update** of prior distribution of $\theta$ due to $y$
  $P(y|\theta) =$ Likelihood (of observed data, given $\theta$), which is a model/distribution that is chosen
  $P(y)$ called the marginal distribution of observed data $y$ is obtained from $P(\theta)$ and $P(y|\theta)$ (considered a normalizing constant of the posterior distribution, i.e., it makes sure $P(\theta|y)$ sums/integrates to 1), dropping it gives:
  $$P(\theta|y) \propto P(\theta)P(y|\theta), where \propto is\ symbol\ for\ proportional$$

45

<!-- page 46 -->

# Bayesian Analysis: Discrete Prior Distribution Example

* Study: Researchers screen for vision problems among children. Sample of $n=14$ children found 2 with vision problems. Want inference about the probability of having vision problems, $\theta$.

* The likelihood $P(y|\theta)$ is chosen to be the binomial distribution
$$P(y|\theta) = \binom{14}{y}\theta^y(1 - \theta)^{14-y} \text{ e.g., when } P(y = 2|\theta = 0.12) = \binom{14}{2}0.12^2(0.88)^{12} = 0.2827$$

* We assume the only possible values of $\theta \in \{.10, .12, .14, .16, .18, .20\}$ and researchers have prior beliefs about their probabilities. Table below gives computation for

| $\theta$ | $P(\theta)$ | $P(y|\theta)$ | $P(\theta) \times P(y|\theta)$ | $P(\theta|y)$ |
| :--- | :--- | :--- | :--- | :--- |
| 0.10 | 0.10 | 0.257 | 0.0257 | 0.103 |
| 0.12 | 0.15 | 0.2827 | 0.0424 | 0.170 |
| 0.14 | 0.20 | 0.2920 | 0.0584 | 0.233 |
| 0.16 | 0.20 | 0.2875 | 0.0576 | 0.230 |
| 0.18 | 0.15 | 0.2725 | 0.0410 | 0.164 |
| 0.20 | 0.10 | 0.2501 | 0.0250 | 0.100 |
| Total | 1.00 | | $P(y) = 0.2501$ | 1.000 |

Note that 5<sup>th</sup> column is Posterior Distribution

$$P(\theta|y) = \frac{P(\theta) \times P(y|\theta)}{P(y)} ,$$

where $P(y) = \sum_\theta P(\theta) \times P(y|\theta)$

$$= 0.2501 \text{ Total in 4}^\text{th}\text{ column}$$

46

<!-- page 47 -->

# Bayesian Analysis: Continous Prior Distribution Example

* **Beta-Binomial Model:** Want to make inference about a parameter, $\theta$, that is the probability of a binary event across trials(e.g., poor vision among children, $n = 14$).

* **Prior**: Specify a (subjective) continuous **prior** distribution for $\theta$, a $Beta(a, b)$ distribution with density:

$$f(\theta, a, b) = \frac{\theta^{a-1}(1-\theta)^{b-1}}{B(a, b)}, 0 \le \theta \le 1, B(a, b) = \Gamma(a)\Gamma(b)/\Gamma(a + b)$$

* If the $P(\theta)$ is $Beta(1, 1)$, then it is a non-informative prior, i.e., a flat prior equal to 1, with expected value of $\theta$ of $\frac{a}{a+b} = 0.5$
  * Bayes is **subjective**: you choose the prior you want

* **Likelihood** $P(y|\theta)$ is $\text{Binomial}(n, \theta)$, where $y$ is the number of successes

* **Posterior**, from Bayes Theorem: $P(\theta|y) \sim Beta(y + 1, n - y + 1)$
  * You **update the prior**, given new information!

47

<!-- page 48 -->

# Bayesian Analysis: Example

Prior: Beta(1,1)

Prior: Beta(5,15)

Prior: Beta(25,75)

Likelihood: Binomial(250, $\theta$)

48

<!-- page 49 -->

# Steps in Bayesian Data Analysis

- Set up a full probability model (subjective part)
  - A joint distribution for all observable and unobservable quantities
    i.e., $P(\theta) \times P(y|\theta)$
- Condition on observed data
  - Given prior information and observed data, calculate a posterior distribution $P(\theta|y)$ (either for a **parameter** or **observations not sampled**)
- Evaluate model fit
  - How sensitive are conclusions of you inference to the choice of models (for prior and likelihood)?

*Gelman et al. <u>Bayesian Data Analysis</u> (2013)*

49

<!-- page 50 -->

# Broadband Internet Example

* Goal is to evaluate the **proportion** of the population that has **broadband internet**

* We can’t visit every housing unit to measure this indicator

* Setting this up in a Bayesian fashion, our focus is now on determining a posterior distribution of the parameter predictions of values of the variable of interest for observations not sampled, i.e., **unobservable quantities** (**Bayesian Finite Population Inference**)

50

<!-- page 51 -->

# Broadband Internet Example (Cont.)

$N = \text{Finite Population Size}$

$$
Y_i = \begin{cases} 1, \text{ if household } i \text{ has a broadband} \\ 0, \text{ otherwise} \end{cases}
$$

$Q(Y) = \sum_{i=1}^N Y_i / N$ Proportion of households with broadband and is the Finite Population parameter (**this is the parameter**)

Question of Interest: **What is $\mathbf{P(Q(Y) \ge 0.3)}$?**

* We want to estimate the probability that $Q(Y)$ exceeds 0.3, i.e., meets criterion of “high internet penetration”
* Conduct a small-scale survey to answer the question of interest
* **Note: this question makes sense under Bayes paradigm as $Q(Y)$ is random (Under frequentist inference, $Q(Y)$ is assumed to be fixed but unknown. A frequentist approach could be to test the null $H_o Q(Y) < 0.3$ vs. alternative $\boldsymbol{H_A Q(Y)} \ge 0.3$ )**

51

<!-- page 52 -->

# General Setup Used for Survey Data Analysis

- Model for $I = (I_1, I_2, ..., I_N)$ for the Sample Design
- Model for $Y = (Y_1, Y_2, ..., Y_N)$
- Frame/Sample Design Variables: $Z$
- Joint distribution $P(Y, I|Z)$
- Observed Data $(Y_{inc}, I, Z)$, $Y_{inc}$ are $Y$’s included in the sample
- Missing or Unobserved Data, $Y_{exc}$
- Inference: $\Pr(Y_{exc}|Y_{inc}, I, Z)$
- We will use the Bayesian approach to generate posterior predictions of $Y$ for non-sampled units, $Y_{exc}$

| $I$ | $Z$ | $Y$ |
| :---: | :---: | :---: |
| 1<br>1<br>1 | | $Y_{inc}$ |
| 0<br>0<br>0<br>0<br>0 | | $Y_{exc}$ |

52

<!-- page 53 -->

# Under Simple Random Sampling Without Replacement

* No $Z$ for SRSWOR
* Ignorable probability sampling, i.e., $Pr(Y, I) = Pr(Y)Pr(I)$

53

<!-- page 54 -->

# Broadband Example

* SRSWOR of $n$, $Y_{inc} = \{Y_1, Y_2, \dots, Y_n\}, Y_{exc} = \{Y_{n+1}, Y_{n+2}, \dots, Y_N\}$
* 
* 
* 
* $n$
* $N$

54

<!-- page 55 -->

# Binomial Example

The posterior distribution $p(\theta|x)$ is:

$$p(\theta|x) = \frac{p(x|\theta)\pi(\theta)}{\int p(x|\theta)\pi(\theta)d\theta} \propto p(x|\theta)\pi(\theta)$$

$$p(\theta|x) = \frac{\binom{n}{x}\theta^x(1-\theta)^{n-x}\times 1}{\int_0^1 \binom{n}{x}\theta^x(1-\theta)^{n-x}d\theta} \text{ , since } \pi(\theta) = 1, 0 \le \theta \le 1$$

*The $p(\theta|x)$ is a $Beta(x + 1, n - x + 1)$ distribution.*

$Q(Y) = \left(x + \sum_{i=n+1}^N Y_i\right)/N,$ is the estimand

$$\left(\sum_{i=n+1}^N Y_i \middle| \theta, x\right) \sim \text{Bin}(N - n, \theta)$$

**The general idea use simulation** to get an approximate distribution of $Q(Y)$, **given a posterior distribution** of $\theta$:

1. Randomly draw a value of $\theta$ from the **posterior distribution** $p(\theta|x)$, $Beta(x + 1, n - x + 1)$, (which is informed by the observed $x$ and n.
2. Given that draw of $\theta$, randomly draw a value of the sum of the $Y$ values for the **non-selected units** from the stated Binomial distribution, $\text{Bin}(N - n, \theta)$, and compute the estimand $Q(Y)$
3. Repeat steps 1 and 2 many times, and look at the distribution of the “drawn” values of $Q(Y)$ for answering the research question, e.g., $\text{P}(Q(Y) \ge 0.3)$?

55

<!-- page 56 -->

# Inference for Population Parameter $\theta$

* Recall the Question of Interest: What is $\text{P}(Q(Y) \ge 0.3)$?, $Q(Y) = \bar{Y}_N$

* Since as $N \to \infty, \bar{Y}_N \to \theta$ then $\text{Pr}(\bar{Y}_N \ge 0.3|x) \approx \text{Pr}(\theta \ge 0.3|x)$

* Compute $\text{Pr}(\theta \ge 0.3|x)$ using cumulative posterior distribution, i.e., the cumulative distribution function (CDF) of the beta distribution, $Beta(x + 1, n - x + 1)$, which is a standard function in most software, such as R.

56

<!-- page 57 -->

# Numerical Example

* Finite population of $N = 270$ households
* SRS sample of size $n = 20$
* Suppose $x = 8$ out of sample of 20 had broadband
* *Simulation Steps:*
  (1) Randomly draw $\theta$ from posterior, $\theta \sim Beta(9,13)$, from $Beta(x + 1, n - x + 1)$, $x = 8$ and $n = 20$.
  (2) Randomly draw the sum $X_{N-n} \sim Bin(250, \theta)$ given the draw of $\theta$ in Step (1)
  (3) Compute a "draw" of the estimand, $\bar{Y}_N = (x + X_{N-n})/N$
  (4) Repeat many times (say 1,000) to get a simulated posterior distribution of $\bar{Y}_N$ then use that simulated distribution to obtain a credible interval of $\bar{Y}_N$.

57

<!-- page 58 -->

# Histogram of 2,500 Draws

Proportion of draws of $Q(Y) = \bar{Y}_N$ exceeding 0.3: 0.84 (the probability that $\bar{Y}_N$ exceeds 0.3 in this area is 0.84)

Posterior mean: 0.4051 (point estimate of $\bar{Y}_N$)

Posterior standard deviation: 0.1007 (measure of variance in estimate)

Use Normal Approximation to obtain 95% credible interval for population $\bar{Y}_N$:

$$
(0.2077, 0.6025) = 0.4051 \pm 1.96 \times 0.1007
$$

0.3

58

<!-- page 59 -->

# Point Estimates in Bayesian Analysis

* The point estimate is often a single summary “best” value for the unknown estimand $Q(Y)$
* Some choices are the mean, mode or the median of the **posterior distribution** of $Q(Y)$
* For symmetrical distributions, an intuitive choice is the center of symmetry
* For asymmetrical distributions, the choice less clear.

59

<!-- page 60 -->

# Credible Interval Estimation

* A credible interval is a used to summarize Bayesian inference, which is similar to confidence interval used in frequentist and design-based inference

* There are different methods to obtain credible intervals :

  (1) We just used normal distribution approximation for broadband example (Slide 58) to get an interval centering around the mean of the posterior distribution, i.e., $\text{mean} \pm 1.96 \times \text{std}$ of the posterior distribution.

  (2) Fix the coverage rate $1 - \alpha$, e.g., 95%, in advance and determine the *highest posterior density* (HPD) region, $C$, to include most likely values of $Q(Y)$ totaling 95% of the posterior probability. For <u>symmetric</u> unimodal posterior distributions, the $(1 - \alpha)$ HPD interval is $(q_{\alpha/2}, q_{(1-\alpha)/2})$ where $\Pr\bigl(Q(Y) \le q_{\alpha/2}\bigr) = \alpha/2$. For example, use the 2.5 and 97.5 percentiles of the simulated draws of the estimand, $Q(Y)$, to form a 95% credible interval.

* In the Broadband example with $Y_i \sim Bernoulli(\theta)$ , the beta density for the posterior can be used to determine the credible interval of $Q(Y)$.

60

<!-- page 61 -->

# Goal of Bayesian Approach for Complex Surveys

Derive (or simulate) the Posterior (predictive) distribution, conditional on the design variables $Z, I$ :

$$
\mathrm{P}(Y_{exc}|Y_{inc}, Z, I)
$$

Two-stage Construction (draws of parameters from posterior, then draws of values for excluded cases given drawn values of parameters, as in the broadband example):

$$
\pi(\theta|Y_{inc}, Z, I)
$$

$$
\mathrm{P}(Y_{exc}|\theta, Z)
$$

61

<!-- page 62 -->

# General Setup: Complex Samples

$$I : \text{Inclusion indicator}$$

$$Y : \text{Survey Variables}$$

$$Z : \text{Design Variables}$$

$$\text{Model} : \Pr(Y, I \mid Z) = \Pr(Y \mid Z) \Pr(I \mid Y, Z)$$

Prior

Sampling Mechanism

$$\Pr(Y \mid Z) = \int \Pr(Y \mid Z, \theta)\pi(\theta \mid Z)d\theta$$

Design variables Z include Weights, Clustering, Stratification.

There may be additional auxiliary variables not part of the design but predictive of Y and available for all subjects in the population

$$\text{Observed Data} : (Y_{inc}, I, Z)$$

62
