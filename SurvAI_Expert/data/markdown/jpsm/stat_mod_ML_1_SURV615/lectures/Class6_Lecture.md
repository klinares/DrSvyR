---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class6_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class6_Lecture.pdf"
pages: 36
sha256: "875712cf3ee47bb643b11339a602c706791d7e118a698e9bc0976b8f7d505e48"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:25"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #6

John Kubale

October 1, 2024

<!-- page 2 -->

# Outline

* Miscellaneous points
* Review from previous lecture and HW4
* Review

<!-- page 3 -->

# Exam 1

* All materials will be available via the Class 6 module starting at 12pm today and will be due by the start of class next Tuesday (930am).
* The exam will follow a similar layout to your homeworks.
  * Complete and submit a knitted pdf that contains your name at the top, the numbered questions, and your answers (this includes all relevant code and output).
  * **<u>Please check and remove any unnecessary output before submission.</u>**
* Must complete the exam on your own.
  * Discussion of the exam with others and use of AI/LLMs is not allowed.
  * Use of notes, class materials, and the internet (within reason) is permitted
    * i.e., you may not post exam questions on forums to solicit help

<!-- page 4 -->

# Exam 1

* The first question largely requires you to correctly interpret output as you will not have access to the data.
  * While you won’t have access to the data, you will have all the information needed to answer the question.
  * R can be helpful with some of the calculations required.
  * You will need to include your answers in R so they’re in the knitted pdf anyway.
* The second question will involve actually working with a dataset.

<!-- page 5 -->

# Tips on knitting to a pdf

```r
---
title: "Homework 4 Solution"
author: "John Kubale"
date: "2024-09-23"
output: pdf_document
number_sections: yes
fontsize: 12pt
fig_width: 7
fig_height: 6
---
```

* Put your name at the top using the author field in the header
* Avoid copy/pasting from other documents!

<!-- page 6 -->

# Review – Lecture 5

* Ambiguous quiz question from last week:

1 Multiple Choice 1 point

For a given linear regression model $y_i = \beta_0 + \beta_1 x_i + \epsilon_i$, what is true about $\epsilon_i$?

* $\epsilon_i$ increases as the outcome variable increases.
* $\epsilon_i$ contains information about how well the model represents the data.
* $\epsilon_i$ is known because of OLS.
* OLS attempts to minimize $\epsilon_i$.

Credit given for either of these answers

<!-- page 7 -->

# Review – Lecture 5

* Ambiguous quiz question from last week:

For a given linear regression model $y_i = \beta_0 + \beta_1 x_i + \epsilon_i$, what is true about $\epsilon_i$?

* [ ] $\epsilon_i$ increases as the outcome variable increases.
* [x] $\epsilon_i$ contains information about how well the model represents the data.

Correct Answer: **OLS attempts to minimize $\epsilon_i$.** $\longleftarrow$ Not the correct answer

* [ ] $\epsilon_i$ is known because of OLS.
* [ ] OLS attempts to minimize $\epsilon_i$.

<!-- page 8 -->

# Review – Lecture 5

* F tests and the null hypotheses being tested:
  * summary(model)
  * anova(model)
  * anova(model1, model2)

<!-- page 9 -->

# Review – Lecture 5

* Let’s fit a simple linear regression model using the `mtcars` dataset in R. Specifically we’ll model `mpg` as a function of `hp`.

```r
data("mtcars")

m1 <- lm(mpg ~ hp, mtcars)
summary(m1)
```

```
## 
## Call:
## lm(formula = mpg ~ hp, data = mtcars)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -5.7121 -2.1122 -0.8854  1.5819  8.2360 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 30.09886    1.63392  18.421  < 2e-16 ***
## hp          -0.06823    0.01012  -6.742 1.79e-07 ***
## ---
## Signif. codes:  0 ’***’ 0.001 ’**’ 0.01 ’*’ 0.05 ’.’ 0.1 ’ ’ 1
## 
## Residual standard error: 3.863 on 30 degrees of freedom
## Multiple R-squared:  0.6024, Adjusted R-squared:  0.5892 
## F-statistic: 45.46 on 1 and 30 DF,  p-value: 1.788e-07
```

What is the null hypothesis for the F statistic here?

<!-- page 10 -->

# Review – Lecture 5

* What about when we use the `anova()` function on the same model object?

```r
anova(m1)
```

```
## Analysis of Variance Table
## 
## Response: mpg
##           Df Sum Sq Mean Sq F value    Pr(>F)    
## hp         1 678.37  678.37   45.46 1.788e-07 ***
## Residuals 30 447.67   14.92                      
## ---
## Signif. codes:  0 ’***’ 0.001 ’**’ 0.01 ’*’ 0.05 ’.’ 0.1 ’ ’ 1
```

What is the null hypothesis for the F statistic here?

<!-- page 11 -->

# Review – Lecture 5

* What about when we use the `anova()` function on the same model object?

```r
anova(m1)
```

```
## Analysis of Variance Table
## 
## Response: mpg
##           Df Sum Sq Mean Sq F value    Pr(>F)
## hp         1 678.37  678.37   45.46 1.788e-07 ***
## Residuals 30 447.67   14.92
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 '
```

```r
data("mtcars")

m1 <- lm(mpg ~ hp, mtcars)
summary(m1)
```

```
## 
## Call:
## lm(formula = mpg ~ hp, data = mtcars)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -5.7121 -2.1122 -0.8854  1.5819  8.2360 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 30.09886    1.63392  18.421  < 2e-16 ***
## hp          -0.06823    0.01012  -6.742 1.79e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 3.863 on 30 degrees of freedom
## Multiple R-squared:  0.6024, Adjusted R-squared:  0.5892 
## F-statistic: 45.46 on 1 and 30 DF,  p-value: 1.788e-07
```

<!-- page 12 -->

# Review – Lecture 5

* What about when we use the `anova()` function on the same model object?

They’re the same test. You’re comparing your fit model (m1), which here has 1 predictor to that of the intercept only model (0 predictors). When you don’t specify the model to compare to R assumes that you want to compare to the intercept only model.

```r
anova(m1)
```

```
## Analysis of Variance Table
##
## Response: mpg
##           Df Sum Sq Mean Sq F value
## hp         1 678.37  678.37   45.46 1.7
## Residuals 30 447.67   14.92
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
data("mtcars")
```

```
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept) 30.09886    1.63392  18.421  < 2e-16 ***
## hp          -0.06823    0.01012  -6.742 1.79e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## Residual standard error: 3.863 on 30 degrees of freedom
## Multiple R-squared:  0.6024, Adjusted R-squared:  0.5892
## F-statistic: 45.46 on 1 and 30 DF,  p-value: 1.788e-07
```

<!-- page 13 -->

# Review – Lecture 5

How would we write this out?

* $H_0: \beta_1 = \beta_2 = \beta_3 = 0$
* $H_0: RSS_{Full} = RSS_{Reduced}$
* Here our reduced model is the intercept only model.

* What would you conclude based on this test?

<!-- page 14 -->

# Review – Lecture 5

Let’s now add a second predictor to our model and compare it to our simple linear regression model using an F test.

```r
m2 <- lm(mpg ~ hp + wt, mtcars)
anova(m1, m2)

## Analysis of Variance Table
##
## Model 1: mpg ~ hp
## Model 2: mpg ~ hp + wt
##   Res.Df    RSS Df Sum of Sq      F    Pr(>F)
## 1     30 447.67
## 2     29 195.05  1    252.63 37.561 1.12e-06 ***
## ---
## Signif. codes:  0 ’***’ 0.001 ’**’ 0.01 ’*’ 0.05 ’.’ 0.1 ’ ’ 1
```

What is the null hypothesis for the F statistic here?

<!-- page 15 -->

# Review – Lecture 5

Let’s now add a second predictor to our model and compare it to our simple linear regression model using an F test.

> The null hypothesis here is nearly the same as the one we saw in the previous example. It still states that the RSS of the full model is equal to that of the reduced model—the difference is what reduced model is being used. Before it was an intercept only model, while here it is a simple linear regression model.

```r
m2 <- lm(mp
anova(m1, m

## Analysis
## 
## Model 1:
## Model 2:
##   Res.Df
## 1     30 447.67
## 2     29 195.05  1   252.63 37.561 1.12e-06 ***
## ---
## Signif. codes:  0 ’***’ 0.001 ’**’ 0.01 ’*’ 0.05 ’.’ 0.1 ’ ’ 1
```

<!-- page 16 -->

# Review – Lecture 5

How would we write this out?

* $H_0: RSS_{Full} = RSS_{Reduced}$
* Here our reduced model is the simple linear regression model.

* What would you conclude based on this test?

<!-- page 17 -->

# HW4

- Let's look at questions from the homework you just turned in.

<!-- page 18 -->

# Exam Review

<!-- page 19 -->

# Review – Regression terminology

* The model `lm(y ~ x + z, data)` can be described as:
  * Regress y on x and z
  * Fit a linear model of y as a function of x and z

<!-- page 20 -->

# Review – Degrees of freedom

* Can be calculated using the formula $n-p$
  * $n = sample\ size$
  * $p = number\ of\ parameters\ being\ estimated$
* With regression models sometimes will sometimes see it written as $n-p-1$ with $1$ representing the intercept $\rightarrow$ since the intercept is a parameter too this is accounted for by $p$

<!-- page 21 -->

# Review – Degrees of freedom

* You have a dataset ($n=50$) with 3 variables ($y$, $x$, and $z$).
* How many degrees of freedom do you have in each of the following models?
  * ```r
    lm(y ~ 1, data)
    ```
  * ```r
    lm(y ~ x, data)
    ```
  * ```r
    lm(y ~ z, data)
    ```
  * ```r
    lm(y ~ x + z, data)
    ```

<!-- page 22 -->

# Interpretations

<!-- page 23 -->

# Review – Intercept Only Regression Interpretations

* Given the intercept only linear regression model, $Y = \beta_0 + \epsilon$
  * The coefficient for $\beta_0$ represents the expected mean value of the outcome, $Y$.
  * As there are no predictors this should be equivalent to the arithmetic mean.

<!-- page 24 -->

# Review – Simple Linear Regression Interpretations

* Given the simple linear regression model, $Y = \beta_0 + \beta_1 x_1 + \epsilon$
    * The coefficient for $\beta_0$ represents the expected mean value of the outcome, $Y$, when $x = 0$ (or its reference group).
    * The coefficient for $\beta_1$ represents the change in the expected mean value of the outcome, $Y$, for a one-unit increase in $X$.

<!-- page 25 -->

# Review – Multiple Linear Regression Interpretations

* Given the multiple linear regression model, $Y = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \epsilon$
  * The coefficient for $\beta_0$ represents the expected mean value of the outcome, $Y$, when both $x_1$ *and* $x_2$ *equal* $0$ (or their reference group).
  * The coefficient for $\beta_1$ represents the change in the expected mean value of the outcome, $Y$, for a one-unit increase in $x_1$ while holding $x_2$ constant.
  * The coefficient for $\beta_1$ represents the change in the expected mean value of the outcome, $Y$, for a one-unit increase in $x_2$ while holding $x_1$ constant.

<!-- page 26 -->

# Review – 95% CI Interpretation

* Given the following 95% CI for a regression coefficient (i.e., beta), how would you interpret it?
  * 95% CI $(1.2, 2.4)$

<!-- page 27 -->

# Review – 95% CI Interpretation

* Given the following 95% CI for a regression coefficient (i.e., beta), how would you interpret it?
  * 95% CI (1.2, 2.4)

1. If we were to take repeated samples from the population, fit the model on each, and estimate 95% CI we would expect the true population beta to fall within the interval 95% of the time.

<!-- page 28 -->

# Review – 95% CI Interpretation

True mean out of interval True mean within interval

Mean median value in \$1000
27.5-
25.0-
22.5-
20.0-
17.5-

<!-- page 29 -->

# Review – 95% CI Interpretation

* Given the following 95% CI for a regression coefficient (i.e., beta), how would you interpret it?
  * 95% CI (1.2, 2.4)

1. If we were to take repeated samples from the population, fit the model on each, and estimate 95% CI we would expect the true population beta to fall within the interval 95% of the time.
2. We are 95% confident that the true population beta is between 1.2 and 2.4.

<!-- page 30 -->

# Calculating “by hand”

<!-- page 31 -->

# Review – Calculating “by hand”

* You may be asked to calculate things “by hand” on this or other exams.

Confidence intervals

* You might have the data to work with in R in which case you would need to manually obtain the appropriate test statistic (e.g., using the qt() function), but could use R functions to obtain other key components like the SE.
* You might not have access to the data (e.g., you only have the output).
  * Then you would need to identify the necessary output from the information given and use it to get the needed quantities to estimate the 95% confidence interval

<!-- page 32 -->

# Review – Calculating “by hand”

Confidence intervals

* What information do you need to calculate a confidence interval?
    * Quantity the interval corresponds to (mean, beta, etc.).
    * Standard error of the quantity
    * Test statistic

<!-- page 33 -->

# Review – Calculating “by hand”

Confidence intervals

* What information do you need to calculate a confidence interval?
  * Quantity the interval corresponds to (mean, beta, etc.).
  * Standard error of the quantity
  * Test statistic (be careful you’re using the correct one)
* Where might you look for these in output?
* How could you obtain them if you have access to the data?

<!-- page 34 -->

# Review – Calculating “by hand”

* Could be asked to calculate other quantities “by hand”.
  * All will be things you’ve already seen! $\rightarrow$ look at your labs and homeworks

<!-- page 35 -->

# Review – Comparing models

* You may be asked to compare models and state (with justification) which you would prefer.
  * This could be when you have access to the data, or only some output.
* What might you use?

<!-- page 36 -->

# Review – Comparing models

* You may be asked to compare models and state (with justification) which you would prefer.
  * This could be when you have access to the data, or only some output.
* What might you use?
* What are some potential limitations of these methods that we’ve discussed?
