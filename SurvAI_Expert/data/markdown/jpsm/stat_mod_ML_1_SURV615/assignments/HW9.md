---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/HW9"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "Homework 9"
original: "stat_mod_ML_1_SURV615/assignments/HW9.qmd"
pages: 
sha256: "2aa38af015fd4367b056c7cbcc27aee715425d3b41674ef89dd84c05bc4d76ff"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---


------------------------------------------------------------------------

```r
library(jtools)
library(leaps)
library(car)
library(gratia)
library(dplyr)
library(faraway)
library(huxtable)
library(MASS)
library(mgcv)
library(tidyverse)

options(scipen=999)

```

## 1. Faraway Chapter 9. Exercise 7. Use the cheddar data for this question.

```r
data("cheddar") 
summary(cheddar)
```

{{< pagebreak >}}

## 1.A. Fit a generalized additive model (GAM) for a response of taste with the other three variables as predictors. Do the predictors appear to have a non-linear relationship with the outcome?

-   Based on our plots for the predictors in the GAM we do not see evidence of non-linear relationship with Taste as the outcome variable.

```r
# fit a GAM to the data
summary(mod_taste_gam <- gam(taste ~ s(Acetic) + s(H2S) + s(Lactic), data=cheddar))
gratia::draw(mod_taste_gam)

```

## 1.B. Use the Box-Cox method to determine an optimal transformation of the response. Would it be reasonable to leave the response as is (i.e., no transformation)?

-   The Lambda value is between .50 and 1. We can either leave the outcome variable un-transformed or try a squared root transformation.

```r
mod_taste_lm <- lm(taste ~., data = cheddar)
boxcox(mod_taste_lm)

```

-   If we do decide to squared root transform the outcome response, our residual plot appears to show more evidence on non-constant variance than the residual plot before the transformation.

```r
mod_taste_lm_t <- lm(I(sqrt(taste)) ~ ., data = cheddar)

export_summs(mod_taste_lm, mod_taste_lm_t)


residualPlot(mod_taste_lm, pch=20, col= "dodgerblue", 
               main="Model w/o transformation")
residualPlot(mod_taste_lm_t, pch=20, col= "dodgerblue",
               main="Model w/ transformation")

```

## 2. Faraway Chapter 10. Exercise 2. Using the teengamb dataset with gamble as the response and the other variables. Implement the following variable selection methods to determine the "best" model.

```r
data("teengamb")
glimpse(teengamb)
```

{{< pagebreak >}}

## 2.A. Backward elimination (based on the significance of predictors)

-   The full model contains gamble as a function of sex, income, status, and verbal. Given our significance level, we remove status, and finally status and verbal together to refit the models.

```r
summ(mod_back <- lm(gamble ~., teengamb))

# drop status
summ(mod_back_status <- update(mod_back,.~. -status))

# drop status and verbal
summ(mod_back_status_verbal <- update(mod_back,.~. -status-verbal))

```

{{< pagebreak >}}

## 2.B. Now use AIC. Which is the "best" model?

-   The model with sex + income + verbal has the lower AIC, and we determine it is the "best" model for these data based on this criterion.

```r
back.mod <- stepAIC(mod_back, direction = "backward")
back.mod$anova
```

{{< pagebreak >}}

## 2.C. Now use adjusted R2. Which is the "best" model?

-   "Best" model is gamble \~ sex + income + verbal, the adjusted r-squared is close to the full model while dropping status or one less parameter to estimate.

```r
huxtable::huxreg(
  mod_back, mod_back_status, mod_back_status_verbal, 
  statistics=c( "adj.r.squared"))
```

\

## 2.D. Now use Mallows Cp. Which is the "best" model?

-   "Best" model is gamble \~ sex + income + verbal based on having the lowest Mllow $c_p$ value.

```r
sub1<-regsubsets(gamble ~.,teengamb)
rsub1<-summary(sub1)
plot(I(1:4), rsub1$cp, ylab="Mallow's Cp", xlab="# Predictors")
rsub1$which
```
