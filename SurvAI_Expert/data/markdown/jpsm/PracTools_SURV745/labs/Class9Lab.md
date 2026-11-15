---
id: "jpsm/PracTools_SURV745/labs/Class9Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 9"
original: "PracTools_SURV745/labs/Class9Lab.pdf"
pages: 20
sha256: "500675cbfd2cb4811a6247277a91166102c72c0265ef58cd87b9c92528d5d613"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:13"
---

<!-- page 1 -->

# PracTools Class 9

Sunghee Lee

3/30/2026

## VDK Example 13.6. Unweighted Response Propensity Models

* Nonresponse in the 2003 National Health Interview Survey (NHIS) data, (`nhis`)
  * 3,911 cases with 16 variables

A data frame with 3,911 observations on the following 16 variables.

`ID` Identification variable

`stratum` Sample design stratum

`psu` Primary sampling unit, numbered within each stratum (1,2)

`svywt` survey weight

`sex` Gender (1 = male; 2 = female)

`age` Age, continuous

`age_r` Recoded age (3 = 18-24 years; 4 = 25-44 years; 5 = 45-64 years; 6 = 65-69 years; 7 = 70-74 years; 8 = 75 years and older)

`hisp` Hispanic ethnicity (1 = Hispanic; 2 = Non-Hispanic)

`marital` Marital status (1 = Separated; 2 = Divorced; 3 = Married; 4 = Single/never married; 5 = Widowed; 9 = Unknown marital status)

`parents` Parent(s) of sample person present in the family (1 = Mother, no father; 2 = Father, no mother; 3 = Mother and father; 4 = Neither mother nor father)

`parents_r` Parent(s) of sample person present in the family recode (1 = Yes; 2 = No)

`educ` Education (1 = 8th grade or less; 2 = 9-12th grade, no high school diploma; 3 = High school graduate; 4 = General education development (GED) degree recipient; 5 = Some college, no degree; 6 = Associate’s degree, technical or vocational; 7 = Associate’s degree, academic program; 8 = Bachelor’s degree (BA, BS, AB, BBA); 9 = Master’s, professional, or doctoral degree)

`educ_r` Education recode (1 = High school, general education development degree (GED), or less; 2 = Some college; 3 = Bachelor’s or associate’s degree; 4 = Master’s degree & higher)

`race` Race (1 = White; 2 = Black; 3 = Other)

`resp` Respondent (0 = nonrespondent; 1 = respondent)

1

<!-- page 2 -->

* We identified nonrespondents as persons who answered the question on personal income as Refused, Not Ascertained, and Don't Know or who reported their income only as above or below \$20K. The `resp` variable has values of 0 for nonrespondents and 1 for respondents. About 31% are nonrespondents by this criterion.

```r
data(nhis)
dim(nhis)
```

```
## [1] 3911   15
```

```r
names(nhis)
```

```
##  [1] "ID"      "stratum" "psu"     "svywt"   "sex"     "age"
##  [7] "age_r"   "hisp"    "marital" "parents" "parents_r" "educ"
## [13] "educ_r"  "race"    "resp"
```

```r
tabyl(nhis$resp)
```

```
##  nhis$resp    n  percent
##          0 1212 0.3098952
##          1 2699 0.6901048
```

* We fit logit, probit, and c-log-log models using the following covariates:
  * `age`
  * `educ_r`
  * `hisp`
  * `parents_r`
  * `race`

### A. Fitting a (unweighted) logistic model

```r
glm.logit <- glm(resp ~ age + as.factor(hisp) + as.factor(race) +
                 as.factor(parents_r) + as.factor(educ_r),
                 family=binomial(link = "logit"),
                 data = nhis)
summary(glm.logit)
```

2

<!-- page 3 -->

```r
##
## Call:
## glm(formula = resp ~ age + as.factor(hisp) + as.factor(race) +
##     as.factor(parents_r) + as.factor(educ_r), family = binomial(link = "logit"),
##     data = nhis)
##
## Coefficients:
##                      Estimate Std. Error z value Pr(>|z|)
## (Intercept)          0.582741   0.125881   4.629 3.67e-06 ***
## age                 -0.012667   0.002205  -5.744 9.23e-09 ***
## as.factor(hisp)2     0.306054   0.091193   3.356 0.000790 ***
## as.factor(race)2    -0.159552   0.099416  -1.605 0.108519
## as.factor(race)3    -0.373946   0.161728  -2.312 0.020768 *
## as.factor(parents_r)2 0.522474  0.110278   4.738 2.16e-06 ***
## as.factor(educ_r)2   0.248940   0.097923   2.542 0.011016 *
## as.factor(educ_r)3   0.346231   0.091434   3.787 0.000153 ***
## as.factor(educ_r)4   0.275616   0.141884   1.943 0.052072 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for binomial family taken to be 1)
##
##     Null deviance: 4841.9  on 3910  degrees of freedom
## Residual deviance: 4759.2  on 3902  degrees of freedom
## AIC: 4777.2
##
## Number of Fisher Scoring iterations: 4
```

```r
# extract link values
L.hat.logit <- glm.logit$linear.predictors
# transform link values to probability scale
pred.logit <- exp(L.hat.logit) / (1 + exp(L.hat.logit) )
```

### B. Fitting a (unweighted) probit model

```r
glm.probit <- glm(resp ~ age + as.factor(hisp) + as.factor(race) +
                    as.factor(parents_r) + as.factor(educ_r),
                  family=binomial(link = "probit"),
                  data = nhis)
summary(glm.probit)
```

```r
##
```

3

<!-- page 4 -->

```r
## Call:
## glm(formula = resp ~ age + as.factor(hisp) + as.factor(race) + 
##     as.factor(parents_r) + as.factor(educ_r), family = binomial(link = "probit"), 
##     data = nhis)
## 
## Coefficients:
##                      Estimate Std. Error z value Pr(>|z|)    
## (Intercept)          0.359405   0.077330   4.648 3.36e-06 ***
## age                 -0.007650   0.001336  -5.726 1.03e-08 ***
## as.factor(hisp)2     0.186271   0.055588   3.351 0.000805 ***
## as.factor(race)2    -0.095795   0.060272  -1.589 0.111973    
## as.factor(race)3    -0.229527   0.099051  -2.317 0.020489 *  
## as.factor(parents_r)2  0.317423   0.067503   4.702 2.57e-06 ***
## as.factor(educ_r)2   0.151468   0.058913   2.571 0.010139 *  
## as.factor(educ_r)3   0.209045   0.054749   3.818 0.000134 ***
## as.factor(educ_r)4   0.166483   0.084954   1.960 0.050033 .  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 4841.9  on 3910  degrees of freedom
## Residual deviance: 4759.1  on 3902  degrees of freedom
## AIC: 4777.1
## 
## Number of Fisher Scoring iterations: 4
```

```r
# extract link values
L.hat.probit <- glm.probit$linear.predictors
# transform link values to probability scale
pred.probit <- pnorm(L.hat.probit)
```

**C. Fitting a (unweighted) c-log-log model**

```r
glm.cloglog <- glm(resp ~ age + as.factor(hisp) + as.factor(race) + 
                  as.factor(parents_r) + as.factor(educ_r), 
                  family=binomial(link = "cloglog"), 
                  data = nhis)
summary(glm.cloglog)
```

```r
## 
## Call:
```

4

<!-- page 5 -->

```r
## glm(formula = resp ~ age + as.factor(hisp) + as.factor(race) + 
##     as.factor(parents_r) + as.factor(educ_r), family = binomial(link = "cloglog"), 
##     data = nhis)
## 
## Coefficients:
##                       Estimate Std. Error z value Pr(>|z|)    
## (Intercept)           0.010868   0.078876   0.138 0.890412    
## age                  -0.007385   0.001314  -5.621 1.90e-08 ***
## as.factor(hisp)2      0.184589   0.055409   3.331 0.000864 ***
## as.factor(race)2     -0.090749   0.058951  -1.539 0.123708    
## as.factor(race)3     -0.234704   0.100468  -2.336 0.019485 *  
## as.factor(parents_r)2 0.313163   0.068424   4.577 4.72e-06 ***
## as.factor(educ_r)2    0.148949   0.056511   2.636 0.008395 ** 
## as.factor(educ_r)3    0.201420   0.052087   3.867 0.000110 ***
## as.factor(educ_r)4    0.160153   0.080600   1.987 0.046920 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 4841.9  on 3910  degrees of freedom
## Residual deviance: 4759.1  on 3902  degrees of freedom
## AIC: 4777.1
## 
## Number of Fisher Scoring iterations: 5
```

```r
# extract link values
L.hat.cloglog <- glm.cloglog$linear.predictors
# transform link values to probability scale
pred.cloglog <- 1 - exp(-exp(L.hat.cloglog))
```

**D. Putting all predicted probabilities into one dataset and comparing them**

```r
pred<-rbind(
  data.frame(prob=pred.logit,
             type=factor(rep(c("logit"),length(pred.logit)))),
  data.frame(prob=pred.probit,
             type=factor(rep(c("probit"),length(pred.probit)))),
  data.frame(prob=pred.cloglog,
             type=factor(rep(c("cloglog"),length(pred.cloglog)))))

means<-pred%>%
  group_by(type)%>%
```

5

<!-- page 6 -->

```r
  summarise(m=mean(prob))
means
```

```
## # A tibble: 3 x 2
##   type        m
##   <fct>   <dbl>
## 1 logit   0.690
## 2 probit  0.690
## 3 cloglog 0.690
```

```r
pred %>%
  ggplot(aes(x=prob, fill=type)) +
  geom_density(alpha=0.3, position="identity")+
    geom_vline(data = means, aes(xintercept = m, colour = type),
               linetype = "longdash", size=1)
```

6

<!-- page 7 -->

### VDK Example 13.7. Repeating 13.6 with weighted models.

```r
nhis.dsgn <- svydesign(ids = ~psu, strata = ~stratum, data = nhis,
                       nest = TRUE, weights =~svywt) # Note: base wt should
                                                     # be used if available
svytable(~resp,design=nhis.dsgn)
```

```
## resp
##       0       1
## 3658521 8727998
```

```r
svymean(~resp,design=nhis.dsgn)
```

```
##         mean     SE
## resp 0.70464 0.0095
```

#### A. Fitting a weighted logitic model

```r
glm.svylogit <- svyglm(resp ~ age + as.factor(hisp) + as.factor(race) +
                         as.factor(parents_r) + as.factor(educ_r),
                       family = binomial(link = "logit"),
                       design = nhis.dsgn)
```

#### B. Comparing unweighted and weighted logitic models

```r
summary(glm.svylogit)
```

```
## 
## Call:
## svyglm(formula = resp ~ age + as.factor(hisp) + as.factor(race) +
##     as.factor(parents_r) + as.factor(educ_r), design = nhis.dsgn,
##     family = binomial(link = "logit"))
## 
## Survey design:
## svydesign(ids = ~psu, strata = ~stratum, data = nhis, nest = TRUE,
##     weights = ~svywt)
## 
## Coefficients:
```

7

<!-- page 8 -->

```r
##                     Estimate Std. Error t value Pr(>|t|)
## (Intercept)          0.666748   0.166775   3.998 0.000143 ***
## age                 -0.012807   0.002232  -5.738 1.70e-07 ***
## as.factor(hisp)2     0.219660   0.124981   1.758 0.082699 .
## as.factor(race)2    -0.214038   0.132952  -1.610 0.111412
## as.factor(race)3    -0.448533   0.200909  -2.233 0.028413 *
## as.factor(parents_r)2  0.547079   0.112967   4.843 6.25e-06 ***
## as.factor(educ_r)2   0.340685   0.110937   3.071 0.002925 **
## as.factor(educ_r)3   0.383197   0.095990   3.992 0.000146 ***
## as.factor(educ_r)4   0.310259   0.144433   2.148 0.034768 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for binomial family taken to be 0.9999605)
##
## Number of Fisher Scoring iterations: 4
```

```r
summary(glm.logit)
```

```r
##
## Call:
## glm(formula = resp ~ age + as.factor(hisp) + as.factor(race) +
##     as.factor(parents_r) + as.factor(educ_r), family = binomial(link = "logit"),
##     data = nhis)
##
## Coefficients:
##                       Estimate Std. Error z value Pr(>|z|)
## (Intercept)            0.582741   0.125881   4.629 3.67e-06 ***
## age                   -0.012667   0.002205  -5.744 9.23e-09 ***
## as.factor(hisp)2       0.306054   0.091193   3.356 0.000790 ***
## as.factor(race)2      -0.159552   0.099416  -1.605 0.108519
## as.factor(race)3      -0.373946   0.161728  -2.312 0.020768 *
## as.factor(parents_r)2  0.522474   0.110278   4.738 2.16e-06 ***
## as.factor(educ_r)2     0.248940   0.097923   2.542 0.011016 *
## as.factor(educ_r)3     0.346231   0.091434   3.787 0.000153 ***
## as.factor(educ_r)4     0.275616   0.141884   1.943 0.052072 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for binomial family taken to be 1)
##
##     Null deviance: 4841.9  on 3910  degrees of freedom
## Residual deviance: 4759.2  on 3902  degrees of freedom
## AIC: 4777.2
```

8

<!-- page 9 -->

```r
## 
## Number of Fisher Scoring iterations: 4
```

### C. Comparing all unweighted predicted probabilities and weighted logistic model predicted probabilities

```r
# extract link values
L.hat.svylogit <- glm.svylogit$linear.predictors
# transform link values to probability scale
pred.svylogit <- exp(L.hat.svylogit) / (1 + exp(L.hat.svylogit) )

pred<-rbind(pred,
            data.frame(prob=pred.svylogit,
                       type=factor(rep(c("svylogit"),length(pred.svylogit)))))
means<-pred%>%
  group_by(type)%>%
  summarise(m=mean(prob))
means
```

```r
## # A tibble: 4 x 2
##   type        m
##   <fct>   <dbl>
## 1 logit   0.690
## 2 probit  0.690
## 3 cloglog 0.690
## 4 svylogit 0.699
```

```r
pred %>%
  ggplot(aes(x=prob, fill=type)) +
  geom_density(alpha=0.3, position="identity")+
    geom_vline(data = means, aes(xintercept = m, colour = type),
               linetype = "longdash", size=1)
```

9

<!-- page 10 -->

10

*[Figure: The figure is an overlapping kernel density plot showing "density" on the vertical axis (ranging from 0 to above 5) against probability ("prob") on the horizontal axis (ranging from about 0.45 to 0.83) for four model types: logit, probit, cloglog, and svylogit. All four groups exhibit very similar, slightly left-skewed distributions that closely overlap and peak near a probability of 0.70, where vertical dashed lines indicate their nearly identical central tendencies.]*

<!-- page 11 -->

### VDK Example 13.8. Forming Class With Estimated Propensities & Checking Balance on Covariates

* Continuing with the NHIS analyses given in Example 13.6, we divide the predicted probabilities into five classes and check the count of persons per class. The function `pclass` in `PracTools` will fit logistic, probit, or c-log-log binary regressions and divide the predicted propensities into classes. The function allows the model to be specified and runs either a weighted or unweighted regression.

---
`pclass` *Form nonresponse adjustment classes based on propensity scores*

---

**Description**

Fit a binary regression model for response probabilities and divide units into a specified number of classes.

**Usage**

```r
pclass(formula, data, link="logit", numcl=5, type, design=NULL)
```

**Arguments**

| | |
| :--- | :--- |
| `formula` | symbolic description of the binary regression model to be fitted as used in `glm` |
| `data` | an optional data frame; must be specified if `type="unwtd"` |
| `link` | a specification for the model link function; allowable values are `"logit"`, `"probit"`, or `"cloglog"` |
| `numcl` | number of classes into which units are split based on estimated propensities |
| `type` | whether an unweighted or weighted binary regression should be fit; allowable values are `"unwtd"` or `"wtd"` |
| `design` | sample design object; required if `type="wtd"` |

**Value**

A list with components:

| | |
| :--- | :--- |
| `p.class` | propensity class for each unit |
| `propensities` | estimated response probability for each unit |

#### A. Unweighted model

11

<!-- page 12 -->

```r
out.uw <- pclass(formula = resp ~ age + as.factor(hisp) + as.factor(race) +
                         as.factor(parents_r) + as.factor(educ_r),
                  type = "unwtd", data = nhis, link="logit", numcl=5)
table(out.uw$p.class, useNA="always")
```

```
## 
## [0.453,0.631] (0.631,0.677] (0.677,0.714] (0.714,0.752] (0.752,0.818] 
##           783           782           782           782           782 
##          <NA> 
##             0
```

```r
summary(out.uw$propensities)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  0.4527  0.6451  0.6965  0.6901  0.7418  0.8182
```

* Distribution of propensity scores by class

```r
boxplot(propensities~p.class, data=out.uw)
```

12

<!-- page 13 -->

### B. Weighted model

```r
out.wt <- pclass(formula = resp ~ age + as.factor(hisp) + as.factor(race) +
                         as.factor(parents_r) + as.factor(educ_r),
              type = "wtd", design = nhis.dsgn, link="logit", numcl=5)

table(out.wt$p.class, useNA="always")
```

```
##
## [0.447,0.637] (0.637,0.688] (0.688,0.724] (0.724,0.764] (0.764,0.826]
##           783           782           782           782           782
##          <NA>
##             0
```

```r
summary(out.wt$propensities)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
##  0.4474  0.6517  0.7072  0.6994  0.7538  0.8264
```

* Distribution of propensity scores by class

```r
boxplot(propensities~p.class, data=out.wt)
```

13

<!-- page 14 -->

**C. Different ways to create propensity score classes**

(1) Unweighted avg response propensity
(2) Weighted response propensity
(3) Unweighted response rate
(4) Weighted response rate
(5) Median response propensity

* We can use `NRadjClass` in `PracTools` for all methods

14

<!-- page 15 -->

### Description

Compute separate nonresponse adjustments in a set of classes.

### Usage

```r
NRadjClass(ID, NRclass, resp, preds=NULL, wts=NULL, type)
```

### Arguments

| | |
| :--- | :--- |
| `ID` | identification value for a unit |
| `NRclass` | vector of classes to use for nonresponse adjustment. Length is number of respondents plus nonrespondents |
| `resp` | indicator for whether unit is a nonrespondent (must be coded 0) or respondent (must be coded 1) |
| `preds` | response probabilities, typically estimated from a binary regression model as in `pclass` |
| `wts` | vector of survey weights, typically base weights or base weights adjusted for unknown eligibility |
| `type` | type of adjustment computed within each value of `NRclass`. Allowable codes are 1, 2, 3, 4, or 5. (1 = unweighted average of response propensities, i.e., `preds`; 2 = weighted average response propensity; 3 = unweighted response rate; 4 = weighted response rate; 5 = median response propensity) |

### Value

A data frame of respondents only with four columns:

| | |
| :--- | :--- |
| `NRcl.no` | number of the nonresponse adjustment class for each unit |
| `ID` | identification value for a unit |
| `resp` | value of the `resp` variable (always 1) |
| `RR` | nonresponse adjustment for each unit |

(1) Unweighted avg response propensity - with `out.uw`

```r
class1<-NRadjClass(ID=nhis[,"ID"],
          NRclass = as.numeric(out.uw$p.class),
          resp=nhis[,"resp"],
          preds=out.uw$propensities,
          wts=NULL,
          type=1)
table(class1$NRcl.no,useNA="always")
```

15

<!-- page 16 -->

```r
## 
##   1   2   3   4   5 <NA>
## 460 519 543 554 623    0
```

(2) Weighted response propensity - with `out.wt`

```r
class2<-NRadjClass(ID=nhis[,"ID"],
           NRclass = as.numeric(out.wt$p.class),
           resp=nhis[,"resp"],
           preds=out.wt$propensities,
           wts=nhis[,"svywt"],
           type=2)
table(class2$NRcl.no,useNA="always")
```

```r
## 
##   1   2   3   4   5 <NA>
## 463 522 530 574 610    0
```

* Putting all 5 methods together

**Table 13.2:** Five methods of estimating response propensities within classes based on fitting a logistic model to the NHIS data

| | | | (1) | (2) | (3) | (4) | (5) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Class | Boundaries | Count of persons | Unweighted avg. propensity | Weighted avg. propensity | Unweighted RR | Weighted RR | Median |
| 1 | [0.453,0.631] | 790 | 0.589 | 0.592 | 0.587 | 0.590 | 0.595 |
| 2 | (0.631,0.677] | 784 | 0.656 | 0.656 | 0.666 | 0.682 | 0.657 |
| 3 | (0.677,0.714] | 775 | 0.697 | 0.697 | 0.694 | 0.702 | 0.697 |
| 4 | (0.714,0.752] | 780 | 0.733 | 0.733 | 0.708 | 0.717 | 0.733 |
| 5 | (0.752,0.818] | 782 | 0.777 | 0.778 | 0.797 | 0.804 | 0.775 |

* What is the NR adjustment factor? How about NR adjusted weights?

**D. Checking Balance on Covariates - `age` as an example**

16

<!-- page 17 -->

```r
p.class <- out.uw$p.class
chk1 <- glm(age ~ p.class + resp + p.class*resp, data = nhis)
summary(chk1)
```

```
## 
## Call:
## glm(formula = age ~ p.class + resp + p.class * resp, data = nhis)
## 
## Coefficients:
##                         Estimate Std. Error t value Pr(>|t|)    
## (Intercept)             56.01548    0.88723  63.135  < 2e-16 ***
## p.class(0.631,0.677]    -7.97746    1.32437  -6.024 1.86e-09 ***
## p.class(0.677,0.714]   -10.87322    1.36052  -7.992 1.73e-15 ***
## p.class(0.714,0.752]   -13.14706    1.37926  -9.532  < 2e-16 ***
## p.class(0.752,0.818]   -22.95888    1.54476 -14.862  < 2e-16 ***
## resp                    -0.02852    1.15755  -0.025    0.980    
## p.class(0.631,0.677]:resp -0.06345  1.67230  -0.038    0.970    
## p.class(0.677,0.714]:resp -1.33105  1.69470  -0.785    0.432    
## p.class(0.714,0.752]:resp  0.22328  1.70706   0.131    0.896    
## p.class(0.752,0.818]:resp  1.53051  1.82952   0.837    0.403    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for gaussian family taken to be 254.2593)
## 
##     Null deviance: 1188013  on 3910  degrees of freedom
## Residual deviance:  991865  on 3901  degrees of freedom
## AIC: 32771
## 
## Number of Fisher Scoring iterations: 2
```

* `p.class` factors all have coefficients that are significant while the `p.class*resp` interactions are not; indicating that the mean age differs between classes but is the same for respondents and nonrespondents within a class.

```r
chk2 <- glm(age ~ p.class, data = nhis)
anova(chk2, chk1, test="F")
```

```
## Analysis of Deviance Table
## 
## Model 1: age ~ p.class
```

17

<!-- page 18 -->

```r
## Model 2: age ~ p.class + resp + p.class * resp
##   Resid. Df Resid. Dev Df Deviance      F Pr(>F)
## 1      3906     992466
## 2      3901     991865  5   600.28 0.4722 0.7973
```

* The F-statistic is 0.473 with 3,906 and 3,901 df and has p=0.7964. Thus, the model without `resp` is judged to be adequate.

18

<!-- page 19 -->

### Numerical Notes

* The logistic model for checking covariate balance on `parents_r` has anomalous results that seem to occur fairly often in practice.

```r
new.par <- abs(nhis$parents_r-2)
chk <- glm(new.par ~ p.class + resp + p.class*resp,
           family = binomial(link = "logit"),
           data = nhis)
summary(chk)
```

```
## 
## Call:
## glm(formula = new.par ~ p.class + resp + p.class * resp, family = binomial(link = "lo
##     data = nhis)
## 
## Coefficients:
##                         Estimate Std. Error z value Pr(>|z|)    
## (Intercept)              -0.5523     0.1156  -4.780 1.75e-06 ***
## p.class(0.631,0.677]     -1.1082     0.2042  -5.428 5.71e-08 ***
## p.class(0.677,0.714]     -1.7876     0.2560  -6.982 2.91e-12 ***
## p.class(0.714,0.752]     -3.2454     0.4667  -6.954 3.56e-12 ***
## p.class(0.752,0.818]    -18.0137   517.2789  -0.035   0.9722    
## resp                     -0.2034     0.1528  -1.331   0.1831    
## p.class(0.631,0.677]:resp 0.4312     0.2531   1.704   0.0884 .  
## p.class(0.677,0.714]:resp 0.3604     0.3095   1.165   0.2442    
## p.class(0.714,0.752]:resp-1.2119     0.7503  -1.615   0.1063    
## p.class(0.752,0.818]:resp 0.2034   579.5409   0.000   0.9997    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 2955.4  on 3910  degrees of freedom
## Residual deviance: 2323.9  on 3901  degrees of freedom
## AIC: 2343.9
## 
## Number of Fisher Scoring iterations: 17
```

* An extremely large standard error on `p.class(0.752,0.818]` and the interaction term `p.class(0.752,0.818]:resp`.
* This is a symptom of “quasi-complete” separation in the data set, i.e., there are one or more observations with a predicted probability equal to or near 1.

19

<!-- page 20 -->

– Parameter estimate will diverge to infinity.

* In the NHIS example, there are no cases in class 5 where the parents of the sample person live in the home (`parents_r`=1).

  – This does not have any bad effects on the formation of propensity classes themselves.
  – Since the value of the `parents_r` covariate is the same for everyone assigned to that class, goal of equalizing the covariate values was accomplished.
  – If this problem cropped up in logistic analysis where the goal is to find covariates related to the occurrence of some characteristic, it would have to be addressed.

20
