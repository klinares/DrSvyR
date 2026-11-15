---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module1_Lecture3_ess_2025_updated_notation."
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "Multilevel Modeling Application: Interviewer Effects in the European Social Survey"
original: "applications_stats_modeling_SURV617/lectures/Module1_Lecture3_ess_2025_updated_notation..pdf"
pages: 21
sha256: "a357797ee59691fad8495f865071414aa8622ec9dfc45b8c1e475aa33da29390"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:41"
---

<!-- page 1 -->

# Multilevel Modeling Application: Interviewer Effects in the European Social Survey

Brady West / John Kubale

9/16/2025

### Class Lecture before jumping into the practical R things.

Interviewer effects: Have those units (interviewers) been randomly sampled? Yes!

POTENTIAL EXAM QUESTION: Does it make sense to use region as a random effect? By definition, we'll have every region in the data set and we'll see all four in every data set, so region CANNOT be used as a random effect because they are not randomly sampled. The higher level must represent a random sample of that higher population, because they were randomly sampled. Conversely, let's say we have a country with 100 regions, and we randomly select 50 regions because we physically cannot go to all 100 regions. Because that second level is randomly selected, we could use these regions as a random effect.

For random effects, Level one units nested in level two units. Think about how this lecture can be translated to what our groups are working on.

Interviewer effects are classically viewed as a type of measurement error, specific to an interviewer. We can think of interviewers being clusters of observations. And we have a random sample of interviewers, so we think of their effects on the data as random. We're not looking at fixed effects of individual interviewers, but the random effect of TK. (dp note 8:50).

Determinants of Intra-Interviewer Correlations ("rho-int"); see West and Blom (2017, JSSAM) \* Computerization (ACASI/SAQs); correlations expected to be negligible \* Telephone (smaller) vs. Face-to-face (larger) \* Items? Open vs. closed, or Factual vs. attitudinal; not many differences. The harder and longer a question is, the more likely there is to be interviewer variance. \* Controlled feedback and probing... \* Interviewer experience / training? Interviewer behaviors / non-verbal signs? \* Demographics of interviewers and respondents \* Different recruitment of different types of cases (West and Olson, 2010); argument against measurement error hypothesis. E.G someone is better at recruiting older or younger respondents.

\^These are level TWO covariates. These are not characteristics of the respondent, but are interviewer characteristics. So if we're trying to explain interviewer variance, we'd add fixed effects of this at level two.

Variance inflation:

* As the sizes of workloads increase, effective sample size is reduced, even for small values of intra-interviewer correlations. B is the number of respondents within an interviewer. So the larger the B is, the larger the impact of the interviewer is.
* Workload could be reduced by hiring more interviewers, but... that is very difficult! it is hard to find good interviewers. Better to reduce by training, supervision, and good questionnaire design principles than to just hire more people.
* Wouldn't that cost more?
* Better to reduce rho-int as much as possible through training, supervision, and good questionnaire design principles

Multi-level modeling approaches:

1

<!-- page 2 -->

* In recent years, methodological studies have taken advantage of multilevel modeling techniques to study interviewer variance
* Effects of individual interviewers j (Mj) on survey measures y for respondent i are treated as random:

THE FORMULA (see slide): general outcome measure where Y\_ij i is the respondent and j is the interviewer. We write as some true value (X\_1) plus M\_j which is the random effect due to the interviewer. Ideally, we want M\_j to be 0. This is the random effect of the INTERVIEWER. plus some random error/respondent disturbance at the RESPONDENT level (e.g respondent is lying). So we're trying to model the disturbance due to the interviewer and the disturbance due to the respondent.

Sigma^2\_int... why is that variance non 0? why do different interviewers vary? No different than the random intercept model that we've been talking about.

The typical model that we'd write down which combines those..

$Y_{ij} = \beta_0 + M_j + \epsilon_{ij}$ -> this is a simple random intercept model with no predictors. How much variability is there arising to the interviewers? This is the STARTING POINT.

* In most applications, variance in the true values (Xi) and the random errors (eij) are combined into the error variance term, and a fixed intercept is used

Advantages of MLM when it comes to interviewer effects:

* Capable of handling unbalanced workloads across interviewers (some models require equal workloads!). This is a key feature - the lack of balance. You may have a superstar interviewer who does twice as many interviews as others.
* Capable of including interviewer-specific covariates in an effort to explain variance across interviewers. E.G you can split the model up into level one and level two, you could add interviewer characteristics and their fixed effects to level two. Is it their gender, their experience, the mode that they are working in?
* Capable of allowing interviewer variance to vary depending on the type of interviewer (e.g., CAPI vs. CATI). It could be that face to face interviewers have a much larger variance than CATI interviewers. Or that older interviewers have more variance than younger interviewers. That answers two different research questions - what explains the mean, and why do different sets of interviewers have different variances?
* Models with crossed random effects enable studies of the contributions of areas and interviewers to overall variance (e.g., O'Muircheartaigh and Campanelli, 1998). We could estimate a D matrix for the male interviewers and female interviewers. The softwear allows us to do that.
  - Example: interviewers work in multiple randomly sampled PSUs, and we wish to disentangle interviewer and PSU effects

Aliasing - if an interviewer is confined to only one geographic area (e.g one county), I could NOT fit a model that has a random effect for the interviewer and the area. (26.40) You're trying to estimate the same thing twice, so the model will freak out. We can't make the argument the variance isn't due to the area. But if interviewers work in multiple areas, we can fit a model with both random effects. That's often used in methodological studies trying to decompose that variance.

Assuming that interviewers were randomly sampled from some hypothetical super-population of interviewers (the assumption NEEDED to treat effects as random), we can compute "rho-int" (the intra-interviewer correlation) for a given survey measure as follows:

[SEE SLIDE]

-> same implied intra class correlation, but now attributing to the interviewer. If you're concerned about whether that correlation is 0 or not 0, you can simply test whether rho-int is zero by performing appropriate tests for the interviewer variance component $\sigma_{int}^2$.

### Setup

Required R packages!

<!-- page 3 -->

```r
library(lme4)
```

```
## Warning: package 'lme4' was built under R version 4.4.3
```

```
## Loading required package: Matrix
```

```r
library(nlme)
```

```
## 
## Attaching package: 'nlme'
```

```
## The following object is masked from 'package:lme4':
## 
##     lmList
```

```r
library(lmerTest)
```

```
## Warning: package 'lmerTest' was built under R version 4.4.3
```

```
## 
## Attaching package: 'lmerTest'
```

```
## The following object is masked from 'package:lme4':
## 
##     lmer
```

```
## The following object is masked from 'package:stats':
## 
##     step
```

```r
library(tidyverse)
```

```
## Warning: package 'ggplot2' was built under R version 4.4.3
```

```
## Warning: package 'lubridate' was built under R version 4.4.2
```

```
## -- Attaching core tidyverse packages ------------------------ tidyverse 2.0.0 --
## v dplyr     1.1.4     v readr     2.1.5
## v forcats   1.0.0     v stringr   1.5.1
## v ggplot2   3.5.2     v tibble    3.2.1
## v lubridate 1.9.4     v tidyr     1.3.1
## v purrr     1.0.2     
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::collapse() masks nlme::collapse()
## x tidyr::expand()   masks Matrix::expand()
## x dplyr::filter()   masks stats::filter()
## x dplyr::lag()      masks stats::lag()
## x tidyr::pack()     masks Matrix::pack()
## x tidyr::unpack()   masks Matrix::unpack()
## i Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
```

User-defined functions:

```r
# Function to calculate LRT p-values for variances of random effects
lrt.pvalue <- function(fit1, fit2) {
  lrtstat <-
    (-2 * as.numeric(summary(fit2)$logLik)) - (-2 * as.numeric(summary(fit1)$logLik))
  pvalue = 0.5 * (1 - pchisq(lrtstat, 2)) + 0.5 * (1 - pchisq(lrtstat, 1))
  return(pvalue)
}
```

3

<!-- page 4 -->

input data:

```r
load("D:/repos/UMD_classes_code/applications_stats_modeling_SURV617/data/ess_belgium.rdata")
```

### First step: exploratory data analysis

```r
# variable names
names(ess_belgium)
```

```
##  [1] "idno"    "intnum"  "pplfair" "pplhlp"  "trstprl" "trstlgl" "trstplc"
##  [8] "trstplt" "trstprt" "stfeco"  "stfgov"  "stfdem"  "stfedu"  "stfhlth"
## [15] "gincdif" "freehms" "prtyban" "scnsenv" "imsmetn" "imdfetn" "impcntr"
## [22] "imbgeco" "imueclt" "imwbcnt" "int_rr"  "weight"
```

```r
# missing data
apply(is.na(ess_belgium), 2, sum) #note various coding options for missing data
```

```
##    idno  intnum pplfair  pplhlp trstprl trstlgl trstplc trstplt trstprt  stfeco 
##       0       0       0       0       0       0       0       0       0       0 
##  stfgov  stfdem  stfedu stfhlth gincdif freehms prtyban scnsenv imsmetn imdfetn 
##       0       0       0       0       0       0       0       0       0       0 
## impcntr imbgeco imueclt imwbcnt  int_rr  weight 
##       0       0       0       0       0       0
```

```r
# look at the missing data by variable, e.g.,
table(ess_belgium$pplhlp, useNA = 'always')
```

```
## 
##    0    1    2    3    4    5    6    7    8    9   10 <NA> 
##   37   59  128  265  199  419  260  198  100   28   10    0
```

```r
summary(ess_belgium$intnum, useNA = 'always')
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##     345    1864    2840    3584    5113    7519
```

### Example: People’s Helpfulness.

```r
# histogram
hist(ess_belgium$pplhlp)
```

4

<!-- page 5 -->

Item is a 10-point scale, measuring the attitude of the respondent with regard to people being helpful (10) or looking out for themselves (0).

Spaghetti Plot: useful for longitudinal data. But what do we see here?

```r
#define base for the graphs and store in object 'p'
p <- ggplot(ess_belgium, aes(x = trstplc, y = pplhlp, group = intnum, color = intnum))
## just plotting points (a.k.a., scatterplot)
p + geom_point()
```

5

<!-- page 6 -->

```r
## simple spaghetti plot
p + geom_line()
```

6

*[Figure: The figure is a scatter plot showing `pplhlp` (from 0.0 to 10.0) on the vertical axis versus `trstplc` (from 0 to over 75) on the horizontal axis, with points shaded along a dark-to-light blue color gradient representing the `intnum` variable (ranging up to over 6000). The main pattern shows nearly all data points clustered in discrete horizontal rows between 0 and 10 on both axes, with only three isolated outlier points appearing on the far right near a `trstplc` value of 88.]*

<!-- page 7 -->

Interviewer Box Plots for a data subset with interviewer ID: intnum < 2000

```r
ess_sub=subset(ess_belgium,intnum < 2000)
plot(ess_sub$pplhlp ~ factor(ess_sub$intnum))
```

7

*[Figure: The figure is a line plot showing `pplhlp` (on the y-axis, ranging from 0.0 to 10.0) plotted against `trstplc` (on the x-axis, ranging from 0 to beyond 75), with lines colored according to a continuous scale for `intnum` (ranging from under 2000 to over 6000). The main pattern shows an extremely dense cluster of vertically oscillating blue lines concentrated between `trstplc` values of 0 and 10 across the entire y-axis range, along with two outlier lines extending far to the right to a `trstplc` value near 88.]*

<!-- page 8 -->

Unequal Interviewer Workloads

```r
ess_belgium %>%
  group_by(intnum) %>%
  summarise(n = n())
```

```
## # A tibble: 125 x 2
##    intnum     n
##     <int> <int>
##  1    345    22
##  2    559    12
##  3    599     2
##  4    695     4
##  5    724     2
##  6    741    27
##  7    766     4
##  8    824    11
##  9   1006    11
## 10   1076     2
## # i 115 more rows
```

We'll begin with the following “unconditional” multilevel model, to estimate the raw variance:

$$
y_{ij} = \beta_0 + \mu_{0j} + e_{ij}
$$

$$
\mu_{0j} \sim N(0, \sigma_0^2)
$$

$$
e_{ij} \sim N(0, \sigma^2).
$$

8

<!-- page 9 -->

We can calculate the intra-interviewer correlation (ICC) “rho-int”:

$$
\rho_{int} = \frac{\sigma_0^2}{\sigma_0^2 + \sigma^2}
$$

```r
mod1 = lmer(pplhlp ~ 1 + (1|intnum), REML = T, data = ess_belgium)
mod1
```

```
## Linear mixed model fit by REML ['lmerModLmerTest']
## Formula: pplhlp ~ 1 + (1 | intnum)
##    Data: ess_belgium
## REML criterion at convergence: 7173.609
## Random effects:
##  Groups   Name        Std.Dev.
##  intnum   (Intercept) 0.4835  
##  Residual             1.9463  
## Number of obs: 1703, groups:  intnum, 125
## Fixed Effects:
## (Intercept)  
##       4.746
```

```r
summary(mod1)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: pplhlp ~ 1 + (1 | intnum)
##    Data: ess_belgium
## 
## REML criterion at convergence: 7173.6
## 
## Scaled residuals: 
##      Min       1Q   Median       3Q      Max 
## -2.68928 -0.74121  0.03624  0.64950  2.93109 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  intnum   (Intercept) 0.2338   0.4835  
##  Residual             3.7883   1.9463  
## Number of obs: 1703, groups:  intnum, 125
## 
## Fixed effects:
##             Estimate Std. Error       df t value Pr(>|t|)    
## (Intercept)  4.74623    0.06813 98.42634   69.67   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
AIC(mod1)
```

```
## [1] 7179.609
```

```r
BIC(mod1)
```

```
## [1] 7195.929
```

```r
rand(mod1)
```

```
## ANOVA-like table for random-effects: Single term deletions
##
```

<!-- page 10 -->

```r
## Model:
## pplhlp ~ (1 | intnum)
##            npar  logLik    AIC    LRT Df Pr(>Chisq)
## <none>        3 -3586.8 7179.6
## (1 | intnum)  2 -3601.0 7206.1 28.459  1   9.57e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The DV comes first (pplhlp); no predictors aside from 1 indicates an intercept-only model;

The (1|intnum) term indicates a random effect for each interviewer, associated with the intercept;

REML = T: REML estimation (to ensure that estimates of the variance components are unbiased);

summary(mod1) yields the initial estimates. We can use AIC/BIC to compare different models, such as mod1 vs. mod2.

Initial Model: Interpretation

1. The estimated mean (intercept) is $\hat{\beta}_0 = 4.75$

2. The estimated variance of the random interviewer effects is $\hat{\sigma}_0^2 = 0.23$

3. The estimated residual variance is $\hat{\sigma}^2 = 3.79$

4. The estimated intra-interviewer correlation (or ICC) is
   $\hat{\rho} = 0.23 \ / \ (0.23 + 3.79) = 0.057$ (relatively high for normal variables in a face-to-face survey!)

5. Perform the appropriate mixture-based likelihood ratio test for the variance component using the lmerTest package: rand(mod1). $\text{p} < 0.0001$!

The model with the three estimated parameters is specified as

$$
y_{ij} = 4.75 + \mu_{0j} + e_{ij}
$$

$$
\mu_{0j} \sim N(0, 0.23)
$$

$$
e_{ij} \sim N(0, 3.79).
$$

## Initial Model: Diagnostics

First, we consider a plot of the EBLUPs for the random interviewer effects:

```r
qqnorm(ranef(mod1)$intnum[,1])
qqline(ranef(mod1)$intnum[,1])
```

10

<!-- page 11 -->

An assumption of normality for the random effects seems reasonable (not critical for inference), and we don't detect any extreme outliers (maybe some particularly low EBLUPs), but there is variance!

Next, we check residuals; we could also examine studentized residuals, but for now we look at the raw residuals.

```r
qqnorm(resid(mod1))
qqline(resid(mod1))
```

11

<!-- page 12 -->

The residuals certainly look normally distributed, with no outliers. Diagnostics look good so far!

### Explaining Interviewer Variance

This initial model could be fitted to other variables to generate a distribution of ICCs (e.g., Groves and Magilavy 1986).

An interesting question arises in studies of interviewer effects that can easily be answered using multilevel models: Why is there variance among interviewers? Could be due to sampling in this case.

We can add interviewer-level covariates to the model and monitor changes in the interviewer variance component (like computing R-squared).

In the ESS data set, we have the response rates for each interviewer (INT_RR).

Do interviewers who are better at securing cooperation also collect different values on the variable of interest? If so, nonresponse bias is likely present for the mean!

```r
mod2 = lmer(pplhlp ~ int_rr + (1|intnum), REML = T, data = ess_belgium)
summary(mod2)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: pplhlp ~ int_rr + (1 | intnum)
##    Data: ess_belgium
## 
## REML criterion at convergence: 7182.3
## 
## Scaled residuals:
```

<!-- page 13 -->

```r
##       Min        1Q    Median        3Q       Max
## -2.69192 -0.74336   0.03803   0.65257   2.93524
##
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  intnum   (Intercept) 0.2363   0.4861
##  Residual             3.7888   1.9465
## Number of obs: 1703, groups:  intnum, 125
##
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)
## (Intercept) 4.637e+00  2.413e-01 1.552e+02  19.217   <2e-16 ***
## int_rr      2.141e-03  4.522e-03 1.398e+02   0.473    0.637
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## Correlation of Fixed Effects:
##        (Intr)
## int_rr -0.959
```

```r
AIC(mod2)
```

```r
## [1] 7190.345
```

```r
BIC(mod2)
```

```r
## [1] 7212.106
```

When using lmerTest, you now see p-values based on the Satterthwaite approximation!

Note that the interviewer variance component has hardly changed, and actually increased!

The interviewer-specific response rate is not associated with PPLHLP; note that the fixed effect of INT\_RR is not different from zero.

We have added noise to the model, seemingly, but: Are we sure that we’ve specified the INT\_RR relationship correctly?

No apparent evidence of nonresponse bias due to the interviewer for this variable; but what about other variables?

Updated Diagnostics:

Revisiting the diagnostic plots reveals no additional concerns.

Diagnostics should be carefully examined after fitting each model!

Recall that this general approach is referred to as a “step-up” approach to model-building, where the objective is to explain variance.

### A Random Coefficients Example

Far less research on interviewer effects has examined the effects of interviewers on regression coefficients and other statistics quantifying relationships between variables.

What if we were interested in the relationship of trust in the police (TRSTPLC, X) with a person’s attitude about whether people generally try to help others (PPLHLP, Y)?

We might consider this model, for estimating the overall relationship and examining whether the coefficient of interest varies across interviewers:

13

<!-- page 14 -->

$$
y_{ij} = \beta_0 + \beta_1 x_{ij} + \mu_{0j} + \mu_{1j} x_{ij} + e_{ij}
$$

$$
\left( \begin{array}{c} \mu_{0j} \\ \mu_{1j} \end{array} \right) \sim N \left( \left( \begin{array}{c} 0 \\ 0 \end{array} \right), \left( \begin{array}{cc} \sigma_0^2 & \sigma_{01} \\ \sigma_{01} & \sigma_1^2 \end{array} \right) \equiv D \right)
$$

$$
e_{ij} \sim N(0, \sigma^2)
$$

We now include the TRSTPLC covariate, both after the dependent variable and in the random effects specification; this means that the effects of TRSTPLC are allowed to randomly vary across interviewers!

A fixed intercept and random interviewer intercepts are also included by default in this case. The default covariance structure (D) for the two random effects is unstructured (when using the lmer() function). Do we have convergence issues?

```r
mod3 = lmer(pplhlp ~ trstplc + (trstplc|intnum), REML = T, data = ess_belgium)
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## Model failed to converge with max|grad| = 0.018452 (tol = 0.002, component 1)
```

```r
summary(mod3)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: pplhlp ~ trstplc + (trstplc | intnum)
##    Data: ess_belgium
## 
## REML criterion at convergence: 7143.3
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.8238 -0.6849  0.0373  0.6401  3.2464 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr 
##  intnum   (Intercept) 0.68770  0.8293        
##           trstplc     0.01222  0.1105   -0.82
##  Residual             3.65278  1.9112        
## Number of obs: 1703, groups:  intnum, 125
## 
## Fixed effects:
##             Estimate Std. Error      df t value Pr(>|t|)    
## (Intercept)   3.8866     0.1660 60.7778  23.413  < 2e-16 ***
## trstplc       0.1429     0.0250 64.8230   5.713 3.02e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##         (Intr)
## trstplc -0.914
## optimizer (nloptwrap) convergence code: 0 (OK)
## Model failed to converge with max|grad| = 0.018452 (tol = 0.002, component 1)
```

```r
AIC(mod3)
```

```
## [1] 7155.316
```

14

<!-- page 15 -->

```r
BIC(mod3)
```

```
## [1] 7187.957
```

We see that the overall fixed effect of TRSTPLC is positive and significant: those with higher levels of trust in the police tend to have higher levels of faith in people helping others. However, R is warning us about convergence issues.

The lmer() function will only produce estimates of the variance components in the D matrix (along with their correlation, not the covariance).

Let's perform an appropriate likelihood ratio test, and test whether the variance of the random coefficients is significantly greater than zero:

```r
#Fit the model without the random coefficients:
mod3a = lmer(pplhlp ~ trstplc + (1|intnum), REML = T, data = ess_belgium)
summary(mod3a)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: pplhlp ~ trstplc + (1 | intnum)
##    Data: ess_belgium
## 
## REML criterion at convergence: 7166.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.67760 -0.72785  0.04779  0.64241  3.08138 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  intnum   (Intercept) 0.2379   0.4877  
##  Residual             3.7569   1.9383  
## Number of obs: 1703, groups:  intnum, 125
## 
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept) 4.473e+00  1.002e-01 4.093e+02   44.64  < 2e-16 ***
## trstplc     4.447e-02  1.192e-02 1.673e+03    3.73 0.000198 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##         (Intr)
## trstplc -0.732
```

```r
#Compute the positive difference in the -2 REML log-likelihood values ("REML criterion", -2 * summary(m
#Test Statistic = 7166.8 - 7143.3 = 23.5

#Refer the TS to a mixture of Chi-square distributions with 1 and 2 DF, and equal weight 0.5:

0.5*(1-pchisq(23.5,1)) + 0.5*(1-pchisq(23.5,2))
```

```
## [1] 4.569231e-06
```

```r
#p < 0.001 (strong evidence of variance in coefficients!)
```

15

<!-- page 16 -->

```r
#or use the defined function

# LRT of the variance of random slopes
lrt.pvalue(mod3, mod3a)
```

```
## [1] 4.663737e-06
```

The model with the six estimated parameters is specified as

$$
y_{ij} = 3.89 + 0.14x_{ij} + \mu_{0j} + \mu_{1j}x_{ij} + e_{ij}
$$

$$
\left( \begin{array}{c} \mu_{0j} \\ \mu_{1j} \end{array} \right) \sim N \left( \left( \begin{array}{c} 0 \\ 0 \end{array} \right), \left( \begin{array}{cc} 0.69 & -0.07 \\ -0.07 & 0.01 \end{array} \right) \equiv D \right)
$$

$$
e_{ij} \sim N(0, 3.65).
$$

Here the covariance estimate can be computed as: $\hat{\sigma}_{01} = \hat{r}\hat{\sigma}_0\hat{\sigma}_1 = (-0.82) * 0.83 * 0.11 = -0.07$

### Diagnostics

Let's examine plots of the residuals:

```r
qqnorm(resid(mod3))
qqline(resid(mod3))
```

**Normal Q-Q Plot**

16

<!-- page 17 -->

```r
plot(resid(mod3),fitted(mod3))
```

The plots show that assumptions of normality and constant variance for the residuals seem justified!

Now, let's look at plots of the EBLUPs for each random interviewer effect (based on the random coefficient model):

```r
# intercepts
qqnorm(ranef(mod3)$intnum[,1])
qqline(ranef(mod3)$intnum[,1])
```

17

<!-- page 18 -->

```r
# slopes
qqnorm(ranef(mod3)$intnum[,2])
qqline(ranef(mod3)$intnum[,2])
```

18

*[Figure: This "Normal Q–Q Plot" compares "Theoretical Quantiles" on the horizontal axis (ranging from -2 to 2) against "Sample Quantiles" on the vertical axis (ranging from -1.5 to 1.0) for a single set of data points. The plotted circles closely follow the upward-sloping diagonal reference line across the middle of the distribution, with slight deviations below the line at the lower tail and above the line at the upper tail.]*

<!-- page 19 -->

Both plots look good, except some outliers:

```r
ess_belgium[ess_belgium$intnum==4976,]
```

```
##        idno intnum pplfair pplhlp trstprl trstlgl trstplc trstplt trstprt
## 1156 101107   4976       5      0       0       1       6       0       0
## 1157 101109   4976       7      2       7       7       6       5       5
## 1158 110703   4976       8      5       8       7       7       5       5
## 1159 110704   4976       7      4       5       8       8       2       2
## 1160 110705   4976       7      0      88       5       5       3       3
## 1161 110708   4976       5      5       3       2       7       0       0
## 1162 110709   4976       2      2       0       2       6       2       1
## 1163 117009   4976       5      4       7       0       9       2       2
## 1164 122304   4976       4      4       0       0       4       0       0
## 1165 122305   4976       3      2       0       2       7       2       2
## 1166 122306   4976      10      1       1       5       5       1       1
## 1167 122307   4976       7      7       5       5       7       0       0
## 1168 122309   4976       9      8       7       8       8       7       6
## 1169 123301   4976       5      6       5       7       6       5       5
## 1170 123303   4976       4      2       7       5       7       5       6
## 1171 123304   4976       8      3       2       0       5       0       0
## 1172 123306   4976       7      8       6       8       8       6       6
## 1173 123308   4976       7      3       8       8       6       7       6
## 1174 132101   4976       7      3       8       8       6       7       7
## 1175 132102   4976       3      5       6       7       8       5       5
## 1176 132701   4976       5      3       3       5       7       2       3
## 1177 132703   4976       2      2       0       3       1       0       0
```

19

<!-- page 20 -->

```r
## 1178 132705   4976       2      1       1       3       3       0       0
## 1179 132707   4976       3      3       6       7       6       4       4
## 1180 132709   4976       8      2       0       0       3       0       0
##      stfeco stfgov stfdem stfedu stfhlth gincdif freehms prtyban scnsenv
## 1156      5      3      7      4       7       3       1       2       4
## 1157      3      6      6      7       8       1       1       5       4
## 1158      7      6      9      7       7       2       1       2       3
## 1159      6      5      4      3       8       1       1       1       3
## 1160     88     88      8      8       8       2       1       2       2
## 1161      6      8      6      6       8       2       2       2       3
## 1162      0      0      0      1       6       2       1       1       2
## 1163     88      5      7      5       8       1       1       1       2
## 1164      4      0      2      7       4       2       2       2       1
## 1165      7      3      6      3       8       1       3       5       1
## 1166      3      3      4      5       8       1       3       1       2
## 1167      7      1      5     88       7       1       1       1       1
## 1168      6      5      8      8       8       2       1       1       2
## 1169      5      4      6      7       7       2       1       3       2
## 1170      6      4      7      7       7       1       2       1       4
## 1171      2      0      2      6       5       2       2       2       2
## 1172      6      6      8      7       7       2       2       3       2
## 1173      7      7      6      6       8       4       2       1       2
## 1174      7      7      6      6       7       2       1       4       2
## 1175      7      5      7      8       5       5       3       3       2
## 1176      4      2      5      6       6       2       1       2       2
## 1177      1      0      0      6       4       2       1       2       3
## 1178      5      8      8      8      10       2       1       2       2
## 1179      7      5      6      6       6       1       1       1       2
## 1180      1      0      3      7       2       1       1       1       2
##      imsmetn imdfetn impcntr imbgeco imueclt imwbcnt   int_rr   weight
## 1156       2       4       4       2       2       2 51.06383 1.958333
## 1157       2       2       2       5       6       5 51.06383 1.958333
## 1158       2       3       3       6       7       5 51.06383 1.958333
## 1159       2       2       2       5       8       2 51.06383 1.958333
## 1160       2       2       2       5       5       2 51.06383 1.958333
## 1161       2       2       2       4       7       5 51.06383 1.958333
## 1162       2       2       2       3       4       3 51.06383 1.958333
## 1163       8       3       3       3       6       5 51.06383 1.958333
## 1164       2       2       2       5       7       6 51.06383 1.958333
## 1165       2       2       2       3       8       2 51.06383 1.958333
## 1166       3       4       3       0       4       2 51.06383 1.958333
## 1167       1       2       2      10       5       5 51.06383 1.958333
## 1168       2       2       1       7       8       5 51.06383 1.958333
## 1169       1       2       1       5       5       6 51.06383 1.958333
## 1170       1       2       4       8       8       7 51.06383 1.958333
## 1171       2       4       2       7       1       3 51.06383 1.958333
## 1172       2       2       1       6       7       7 51.06383 1.958333
## 1173       2       2       3       5       6       5 51.06383 1.958333
## 1174       2       2       2       5       7       8 51.06383 1.958333
## 1175       4       3       2      88       5       5 51.06383 1.958333
## 1176       2       2       2      88       6       5 51.06383 1.958333
## 1177       2       2       2       5       8       6 51.06383 1.958333
## 1178       3       3       2       4       8       5 51.06383 1.958333
## 1179       2       2       2       4       3       4 51.06383 1.958333
```

20

<!-- page 21 -->

```r
## 1180       2       2       3       1       2       2 51.06383 1.958333
```

```r
#trstprl=88
ess_belgium[ess_belgium$intnum==7519,]
```

```r
##        idno intnum pplfair pplhlp trstprl trstlgl trstplc trstplt trstprt
## 1692 107101   7519       6      6       5       5       5       4       5
## 1693 107105   7519       5      3       4       6       6       4       3
## 1694 107108   7519      10      5      88      88      88       2       2
## 1695 116303   7519       7      6       6       5       7       2       3
## 1696 116304   7519       7      6       5       3       3       2       0
## 1697 116308   7519       7      8      88       7       7       0       0
## 1698 116309   7519       5      2      88       4       5       5       5
## 1699 128002   7519       9      5       0       3       6       0       1
## 1700 128003   7519       5      4       1       1       6       1       1
## 1701 128004   7519       6      4       4       4       2       2       2
## 1702 128006   7519       8      6       7       6       6       5       7
## 1703 128008   7519       2      8       3       0       4       0       0
##      stfeco stfgov stfdem stfedu stfhlth gincdif freehms prtyban scnsenv
## 1692      6      4      6      6       7       2       3       3       4
## 1693      3      3      6      7       7       2       3       3       4
## 1694      5      2      5     88       9       1       5       3       3
## 1695      4      3      4      5       6       2       1       1       2
## 1696      2      5     88      0       0       1       1       1       3
## 1697     88      0      4     10      10       1       2       8       3
## 1698      2      0     88     88      10       1       2       5       3
## 1699      0      0      3      7       8       1       3       1       3
## 1700      5      0      7      8       9       2       4       1       1
## 1701      3      0      6      4       6       2       1       1       8
## 1702      6      5      7      6       7       1       2       5       3
## 1703      0      0      4      0       2       1       2       1       5
##      imsmetn imdfetn impcntr imbgeco imueclt imwbcnt   int_rr weight
## 1692       2       2       2       6       7       5 44.44444   2.25
## 1693       3       3       2       5       7       5 44.44444   2.25
## 1694       2       3       3       4      88      88 44.44444   2.25
## 1695       2       2       3       4       7      88 44.44444   2.25
## 1696       3       4       4       1       5       0 44.44444   2.25
## 1697       2       8       2      88       5       5 44.44444   2.25
## 1698       3       3       8       0       0       0 44.44444   2.25
## 1699       4       4       3       5       0       2 44.44444   2.25
## 1700       2       4       4       2       0       0 44.44444   2.25
## 1701       2       3       3       3       5       3 44.44444   2.25
## 1702       2       3       2       7       7       7 44.44444   2.25
## 1703       1       4       4       0       3       2 44.44444   2.25
```

Interviewers 4976 (many responses $< 4$!) and 7519 (88, missing data! need to rerun the analysis. . . ) seem unusual.

21
