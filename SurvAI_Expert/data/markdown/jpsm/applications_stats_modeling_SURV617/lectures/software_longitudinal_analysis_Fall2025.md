---
id: "jpsm/applications_stats_modeling_SURV617/lectures/software_longitudinal_analysis_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "**Applications of Statistical Modeling:**"
original: "applications_stats_modeling_SURV617/lectures/software_longitudinal_analysis_Fall2025.pdf"
pages: 18
sha256: "f409965187ac39e4763218b644bacb43accc3e6e3b63342bac729611c3dfa40f"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:43"
---

<!-- page 1 -->

# **Applications of Statistical Modeling:**
## Supplement to Module #1, Lecture #4

Software for Fitting Models to Longitudinal Data

Fall 2025

1

<!-- page 2 -->

# Overview

* Available software procedures in R for fitting multilevel models to normally distributed outcomes
* Software procedures in R for fitting marginal linear models to normally distributed outcomes
* Software procedures in R for fitting models to non-normal outcomes:
  * Multilevel Modeling Approaches
  * GEE Approaches
* Take-Home Points

2

<!-- page 3 -->

# The Autism Data Set

* An example data set created for the illustrations in presented here is available on Canvas (autism.XXX)
* This data set has socialization (i.e., VSAE) data collected over time (ages 2, 3, 5, 9, and 13) during childhood for several children diagnosed with autism
* We also have information on expressive language groups for the children at baseline
* See West et al. (2014, *Linear Mixed Models*) for additional details on this data set

3

<!-- page 4 -->

# Always Start with Spaghetti Plots!

* **R:** see Lecture 3 notes, use ggplot with group = ID
* For binary outcomes, it’s more helpful to generate plots of proportions over time for different groups of cases using an aggregate data set of proportions for each time/group combination, and similar methods

4

<!-- page 5 -->

# Multilevel Models for Normal Outcomes: lme() in R nlme package

* Example syntax:

```r
library(nlme)
model.fit <- lme(vsae ~ age +
  factor(sicdegp) + age:factor(sicdegp),
  random = ~ age - 1 | childid,
  method = "REML", na.action = "na.omit",
  data = autism)
summary(model.fit)
```

5

<!-- page 6 -->

# Multilevel Models for Normal Outcomes: lme() in R nlme package

* Notes on the syntax:
  * Note the use of (-1) in the random argument to omit the random intercepts, which would be included by default
  * An unstructured variance-covariance matrix for the random effects is also included by default
  * The lme() function is one of the few multilevel modeling functions in R that allows for correlated errors, potentially with non-constant variance across groups; see umich.edu/~bwest/chapter3_R_final.txt
  * R also uses different reference categories for categorical factors by default (see output on next slide)

6

<!-- page 7 -->

# Multilevel Models for Normal Outcomes: lme() in R nlme package

```r
Random effects:
 Formula: ~age - 1 | childid
            age Residual
StdDev: 2.863204 9.194127

Fixed effects: vsae ~ age + factor(sicdegp) + age:factor(sicdegp)
                        Value Std.Error  DF   t-value p-value
(Intercept)          2.481581 1.2710970 449  1.952314  0.0515
age                  2.821922 0.4698435 449  6.006090  0.0000
factor(sicdegp)2    -1.293389 1.6732326 155 -0.772988  0.4407
factor(sicdegp)3    -4.230069 1.8620681 155 -2.271705  0.0245
age:factor(sicdegp)2 0.984540 0.6194261 449  1.589439  0.1127
age:factor(sicdegp)3 4.462789 0.6884915 449  6.481981  0.0000
```

7

<!-- page 8 -->

# Fitting Marginal Models to Normally Distributed Outcomes

* In most general-purpose statistical packages, marginal linear models can be fitted to normal outcomes by using (for the most part) the same multilevel modeling procedures
* We simply leave out the explicitly specified random effects, and use appropriate syntax to specify a covariance structure for the random errors
* **Remember: These are NOT mixed-effects models**
* We’ll now consider the same examples with an **unstructured** covariance structure for the errors

8

<!-- page 9 -->

# Fitting the Marginal Model: R

* We use the gls() function in the nlme ibrary:

```r
# make ordering of observations clear
autism$index <- autism$age
autism$index[autism$age==2] <- 1
autism$index[autism$age==3] <- 2
autism$index[autism$age==5] <- 3
autism$index[autism$age==9] <- 4
autism$index[autism$age==13] <- 5

# use unstructured variance-covariance matrix for errors
marg.model.fit <- gls(vsae ~ age + factor(sicdegp) +
   age:factor(sicdegp), na.action = "na.omit",
   correlation = corSymm(form = ~index | childid),
   weights = varIdent(form = ~1 | age), autism)
summary(marg.model.fit)
getVarCov(marg.model.fit)
```

9

<!-- page 10 -->

# Fitting the Marginal Model: R

```r
Coefficients:
                        Value Std.Error   t-value p-value
(Intercept)          1.087562 1.1258657  0.965978  0.3344
age                  3.015190 0.5303880  5.684876  0.0000
factor(sicdegp)2     0.708811 1.4922022  0.475010  0.6350
factor(sicdegp)3    -3.302054 1.6563710 -1.993547  0.0467
age:factor(sicdegp)2 0.463266 0.7030202  0.658965  0.5102
age:factor(sicdegp)3 4.332499 0.7781059  5.568006  0.0000

Marginal variance covariance matrix
        [,1]     [,2]     [,3]     [,4]     [,5]
[1,] 10.8080   8.8481   8.3421   24.575   43.036
[2,]  8.8481  54.5610  55.0130   94.118  187.270
[3,]  8.3421  55.0130 140.2800  193.460  368.330
[4,] 24.5750  94.1180 193.4600  811.050 1158.900
[5,] 43.0360 187.2700 368.3300 1158.900 2183.500
  Standard Deviations: 3.2876 7.3865 11.844 28.479 46.728
```

10

<!-- page 11 -->

# Software for Fitting Longitudinal Models to Non-Normal Outcomes

* We’ll now consider logistic models for a binary indicator of whether a child’s VSAE score is above the overall median score (14)
* We’ll consider multilevel (hierarchical) and GEE (marginal) approaches to fitting the logistic models
* Recall that there are many alternatives for estimation when considering the multilevel modeling approaches!

11

<!-- page 12 -->

# Multilevel Logistic Model: R

* Syntax:

```r
# glmmPQL() in the nlme package uses PQL;
# glmer() in the lme4 package uses AGQ (recommended…)
library(lme4)
autism$vsae_high[autism$vsae > 14] <- 1
autism$vsae_high[autism$vsae <= 14] <- 0
mlm <- glmer(vsae_high ~ age + factor(sicdegp) +
  age:factor(sicdegp) + (age - 1|childid),
  family = binomial, nAGQ = 7, data = autism)
```

12

<!-- page 13 -->

# Multilevel Logistic Model: R

```r
Random effects:
 Groups  Name Variance Std.Dev.
 childid age  0.2096   0.4578  
Number of obs: 610, groups:  childid, 158

Fixed effects:
                     Estimate Std. Error z value Pr(>|z|)    
(Intercept)           -4.4657     0.6936  -6.439 1.20e-10 ***
age                    0.5768     0.1325   4.353 1.34e-05 ***
factor(sicdegp)2       1.0618     0.7197   1.475 0.140085    
factor(sicdegp)3      -0.7242     1.2420  -0.583 0.559810    
age:factor(sicdegp)2   0.1514     0.1618   0.936 0.349380    
age:factor(sicdegp)3   1.6591     0.4680   3.545 0.000393 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

13

<!-- page 14 -->

# Logistic Model using GEE: R

* Syntax:

```r
# make sure data are sorted by ID and age!
library(geepack)
autism$sicdegp <- factor(autism$sicdegp)
autism$sicdegp <- relevel(autism$sicdegp, ref="3")
# for some reason, using an unstructured working
  correlation matrix causes R to crash in this case...
bingee <- geeglm(vsae_high ~ age + sicdegp + age:sicdegp,
  id=childid, waves=age, family=binomial("logit"),
  data=autism, corstr="exchangeable")
# geepack makes the anova() function available, which is
  nice for overall tests of factors / terms in the model
summary(bingee)
anova(bingee)
```

14

<!-- page 15 -->

# Logistic Model using GEE: R

```r
Coefficients:
             Estimate Std.err  Wald Pr(>|W|)   
(Intercept)    -3.888   1.317  8.71   0.0032 **
age             1.663   0.510 10.62   0.0011 **
sicdegp1        1.155   1.355  0.73   0.3943   
sicdegp2        1.925   1.345  2.05   0.1522   
age:sicdegp1   -1.374   0.512  7.20   0.0073 **
age:sicdegp2   -1.327   0.513  6.70   0.0096 **
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Estimated Correlation Parameters:
      Estimate Std.err
alpha    0.153   0.244
```

15

<!-- page 16 -->

# Logistic Model using GEE: R

```r
Analysis of 'Wald statistic' Table
Model: binomial, link: logit
Response: vsae_high
Terms added sequentially (first to last)

            Df   X2 P(>|Chi|)    
age          1 93.0    <2e-16 ***
sicdegp      2 75.7    <2e-16 ***
age:sicdegp  2  7.5     0.023 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

16

<!-- page 17 -->

# Take-away Points

* Remember the difference in possible inferences between multilevel and marginal models:
  – **Hierarchical / Multilevel:** include <u>explicit</u> random effects, and inferences are <u>subject-specific</u> (i.e., you are “controlling” for random subject effects, and fixed effects represent what happens when a covariate changes <u>for a given subject</u>)
  – **Marginal:** Population-averaged effects (what happens, on average, <u>across all subjects</u> in a study?)
* Also, remember that inferences are valid under a MAR assumption; include relevant covariates!

17

<!-- page 18 -->

# Take-away Points

* Software for fitting longitudinal models to normally distributed outcomes is fairly well-established
* Software for fitting longitudinal models to non-normal outcomes is relatively newer, and many different estimation options are possible
* Examine the sensitivity of your results to different estimation methods!
* **This supplement has provided you with “how-to” knowledge; specifying the appropriate model for a given data set is up to you!**

18
