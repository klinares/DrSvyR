---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/HW7"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "Homework 7"
original: "stat_mod_ML_1_SURV615/assignments/HW7.qmd"
pages: 
sha256: "ff4522e3529214723ea33d473582c3e48203b6482e7ba5f2de7b35a38e6369e1"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:13"
---


<br> <br>

------------------------------------------------------------------------

```r
library(car)
library(gridExtra)
library(performance)
library(faraway)
library(knitr)
library(tidyverse)

options(scipen=999)
```

<br> <br>

## 1.Faraway Chapter 4. Exercise 2. Using the teengamb dataset from the faraway package Fit a linear regression model with gamble as the outcome and the other variables as the predictors.

-   We model gamble, expenditure on gambling in pounds per year, as a function on sex (male, female), status score based on parents' occupation), income (in pounds per week), and verbal scores (in words out of 12 correctly defined).

```r
data("teengamb")
```

<br>

```r
summary(
  mod <- lm(gamble ~ sex + status + income + verbal, teengamb))
```

-   Perform regression diagnostics on the model to answer the questions 1.A to 1.G. Display any plots that are relevant. Do not provide plots about which you have nothing to say. Suggest possible improvements or corrections to the model where appropriate.

<br>

-   1.A. Check the zero mean error assumption using residual plots. What do you conclude about whether the assumption is met?

    -   We compute summary statistics of our model residuals and show that they are centered around 0. However, in examining the residuals against fitted values we see that the reference line in green is not flat and horizontal. We see that for low and high fitted values the line is above 0, and for average fitted values the green reference line is below 0, suggesting that the residual errors don't always have a mean value of 0.

```r
summary(resid(mod))
residualPlots(mod, pch=20, col="dodgerblue", terms = ~ 1)
  
```

<br>

-   1.B. Check the constant error variance assumption using both residual plots and a formal statistical test. What do you conclude?

    -   We further examine the constant variance assumption by plotting squared root of the residuals against fitted values and it seems that we have non-constant variance based on the plot below. Numerically we take note of a weak correlation between the residuals and predictors, but when we model these values we see that for every one unit increase in fitted values residuals increase by about .03, suggesting that there is evidence for non-constant variance, or heteroscedasticity
        -   Note. in a F-test for equal variances, for fitted values equal to or below 30 versus above 30 we see that the variances in the residuals are not equal based on that the confidence intervals (95% \[.052, .414\]) does not contain 0.

```r
plot(check_heteroskedasticity(mod))
```

```r
cor(fitted(mod), resid(mod))

summary(lm(sqrt(abs(residuals(mod))) ~ fitted(mod)))

var.test(resid(mod)[fitted(mod)<=30],
+          resid(mod)[fitted(mod)>30])
```

<br>

-   1.C. Check the error normality assumption both graphically and statistically. What do you conclude? Which method do you think is preferable?

    -   Our visuals show that the distribution of residuals are not normally distributed. In the density plot we see a bump emerging at the right tail, while our qq-plot shows several observations outside of what is expected.
    -   Additionally, we used the Shapiro-Wilk normality test and failed to reject the null hypothesis that the residuals are normally distributed in favor of the alternative hypothesis that they are probably not normal. We conclude that both graphically and statistically the assumption of error normality is violated and place more weight on the statistical test over our graphics.

```r
grid.arrange(
  plot(check_normality(mod), type="density"), 
  plot(check_normality(mod), type="qq")
)

shapiro.test(resid(mod))
```

<br>

-   1.D. Check for observations with large leverage. Which observations have large leverage?

    -   We assess the leverage H statistic using the `hatvalues()` function as well as plot these statistics using the `halfnorm()` function and find that for observations 31, 33, 35, and 42 we may want to further investigate how these observations influence the model estimates.
    -   Recommendation: We recommend removing each one of these observations one by one and fitting the model, compare, residuals to determine how much the prediction line moves upon removing a high leveraged observation.

```r
hat <- hatvalues(mod) |> 
  as.data.frame() |> 
  rowid_to_column() |> 
  rename(hat=2) |> 
  mutate(high_leverage = ifelse(hat  > 2*mean(hat), 1, 0)) 

hat |> summarise(mean(hat))

hat |> filter(high_leverage==1) |> select(-high_leverage)

```

```r
halfnorm(hatvalues(mod))
```

-   1.E. Check for outliers. List any potential outliers.

    -   Using studentized residuals, any residual divided by its error if greater than 3, we determine that observation 24 is an outlier. We further examine a boxplot for raw gambling scores and take note that observation 24 is far away from the mean.
        -   Note. Given that we test every observation, we make a Bonferroni correction test by adjusting the critical value.
    -   Recommendation: We recommend removing observation 24 as it is a potential outlier and refitting the model.

```r

r_it <- rstandard(mod) |> 
  as.data.frame() |> 
  rowid_to_column() |> 
  rename(stud_resid = 2) |> 
  mutate(outlier = ifelse(
    abs(stud_resid) > qt(1-.05/ n(),n()-2), 1, 0))

r_it |> filter(outlier == 1) |> select(-outlier)

Boxplot(teengamb$gamble)
```

<br>

-   1.F. Check for influential points. List any potential influential points.

    -   We use Cooks statistic to identify any influential observations and again find observation 24 to be problematic as seen in the halfnorm plot.
    -   Recommendation: We recommend removing observation 24 as it is a potential outlier and influential value and refitting the model.

```r
cd<-cooks.distance(mod)

summary(cd)

halfnorm(cd)
```

-   We can also use the car package to see how well our assessment of high leverage, outliers, and influential observations we did. We find that we overlap in identifying 24, 42, and 35, but not 31 or 33 due to high hat values. In the car assessment we also see that 39 gets flagged; however, we did not identify this as a problem given a low studentized residual.
    -   Note. in the plot below we take note that observation 24 has a high cook statistic as well as a high studentized residual despite having a low hat value.

```r
influencePlot(mod)
```

-   1.G. Check the structure of relationship between the predictors and the response. What do you observe?
    -   We perform partial regression subsetting by sex. We observe that the model subset by males has an adjusted r-squared of .50 while for females it was .07, although there are almost twice as many males in the sample.
        -   talk about the differences in coefficients and confidence intervals.

```r
mod_male<-lm(gamble ~ status + income + verbal,
             subset(teengamb, sex == 0))

mod_female<-lm(gamble ~ status + income + verbal,
               subset(teengamb, sex == 1))

summary(mod_male); summary(mod_female)

confint(mod_male); confint(mod_female) 

```
