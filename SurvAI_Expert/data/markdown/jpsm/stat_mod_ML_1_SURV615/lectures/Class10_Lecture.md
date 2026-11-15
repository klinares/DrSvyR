---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class10_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class10_Lecture.pdf"
pages: 43
sha256: "64ee6791d98b4f1f74df633a79e5bd8a0a13b253860ae51f711e3111483ad2c1"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:15"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #10

John Kubale

November 5, 2024

<!-- page 2 -->

# Outline

* Review
  * Regression assumptions
  * Unusual observations
  * Multiple testing

<!-- page 3 -->

# Regression assumptions

<!-- page 4 -->

# OLS Assumptions

Will see these assumptions presented a variety of ways (e.g., some are often combined), but they boil down to the following:

1. There is a linear relationship between the predictor(s) $X$ and the outcome $Y$. – Relatively simple assumption to relax as we will see.
2. Variable, $X_1, \dots, X_n$, are fixed constants such that $S_{XX} > 0$
3. Variable, $\epsilon_1, \dots, \epsilon_n$, are random variables
4. Zero Error Mean: $E(\epsilon_i) = 0$ for $i = 1, \dots, n$
5. Uncorrelated errors: $\epsilon_1, \epsilon_2, \dots, \epsilon_n$ are not correlated – i.e., knowing value of $\epsilon_1$ tells you nothing about $\epsilon_2, \dots, \epsilon_n$
6. Constant error variance: $\text{V}(\epsilon_i) = \sigma^2$ -- AKA homoscedasticity
7. Error normality: $\epsilon_i \sim N(0, \sigma^2)$ for $i = 1, \dots, n$

<!-- page 5 -->

# OLS Assumptions

Will see these assumptions presented a variety of ways (e.g., some are often combined), but they boil down to the following:

1. There is a linear relationship between the predictor(s) $X$ and the outcome $Y$. – Relatively simple assumption to relax as we will see.
2. Variable, $X_1, \dots, X_n$, are fixed constants such that $S_{XX} > 0$
3. Variable, $\epsilon_1, \dots, \epsilon_n$, are random variables
4. Zero Error Mean: $E(\epsilon_i) = 0$ for $i = 1, \dots, n$
5. Uncorrelated errors: $\epsilon_1, \epsilon_2, \dots, \epsilon_n$ are not correlated – i.e., knowing value of $\epsilon_1$ tells you nothing about $\epsilon_2, \dots, \epsilon_n$
6. Constant error variance: $\text{V}(\epsilon_i) = \sigma^2$ -- AKA homoscedasticity
7. Error normality: $\epsilon_i \sim N(0, \sigma^2)$ $for$ $i = 1, \dots, n$

<!-- page 6 -->

# OLS Assumptions

Pay particular attention to assumptions 4-7
* Taken together they state that our errors are assumed to be normal, independent, and identically distributed (Normal I.I.D).

Jenkins-Smith, Ripberger, Copeland, et. al.

<!-- page 7 -->

# Impact of assumption violations

* Dependence of errors can cause problems as it means there is less information in your dataset than sample size would lead you to believe.
  * Think your estimates are more precise than they are.
* Non-constant error variance can cause problems with inaccurate inferences due to poorly quantified precision.
  * Prediction uncertainty particularly susceptible.
* Non-normal errors can also lead to inaccurate inferences, but for larger datasets inferences will be more robust to moderate violations due to the central limit theorem.
* Violation of zero mean error assumption can indicate issues with error dependence, error normality, and/or non constant error variance.

<!-- page 8 -->

# Zero mean error + homoscedasticity

* Let’s look at a few different scenarios to see what these violations might look like graphically.
* To do this we will fit a scatter plot with our fitted values for a given model on the x axis and the residuals from the same model on y axis

<!-- page 9 -->

# Zero mean error + homoscedasticity

What do you see?

<!-- page 10 -->

# Zero mean error + homoscedasticity

* No discernable pattern.
* Relatively equal spread above and below the line.
* No <u>**apparent**</u> violation.

<!-- page 11 -->

# Zero mean error

* What else should we do to check this assumption?

<!-- page 12 -->

# Zero mean error

Estimate the mean of the residuals!

```r
mean(resid(model))
```

<!-- page 13 -->

# Zero mean error + Homoscedasticity

What do you see?

<!-- page 14 -->

# Zero mean error + Homoscedasticity

* Telltale funnel shape.
* Suggests strong non-constant error variance.
* Violation of zero mean error?

<!-- page 15 -->

# Zero mean error + homoscedasticity

* Telltale funnel shape.
* Suggests strong non-constant error variance.
* Violation of zero mean error – **harder to say**.

<!-- page 16 -->

# Zero mean error + homoscedasticity

* Let’s look at another example.
* This time we’ll assess the zero mean error and homoscedasticity assumptions both graphically and numerically.

<!-- page 17 -->

# Zero mean error + homoscedasticity

* What do you see?

<!-- page 18 -->

# Zero mean error + homoscedasticity

* Telltale funnel shape.
* Suggests strong non-constant error variance.
* Violation of zero mean error?

<!-- page 19 -->

# Zero mean error + homoscedasticity

* Telltale funnel shape.
* Suggests strong non-constant variance.
* Violation of zero mean error?

Let’s look at this numerically.

<!-- page 20 -->

# Zero mean error - numerically

How can we assess whether the mean of our errors is 0?
* `mean(resid(model))`

What if we wanted a p-value test whether the mean is different from 0?
* `t.test(resid(model))`
* `wilcox.test(resid(model))`

<!-- page 21 -->

# Zero mean error - numerically

How can we assess whether the mean of our errors is 0?
* `mean(resid(model))`

```r
> mean(resid(m1))
[1] 1.145134e-17
```

What if we wanted a p-value test whether the mean is different from 0?
* `t.test(resid(model))`
* `wilcox.test(resid(model))`

```r
> t.test(resid(m1))

	One Sample t-test

data:  resid(m1)
t = 1.6177e-16, df = 49, p-value = 1
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 -0.1422525  0.1422525
sample estimates:
   mean of x 
1.145134e-17 
```

```r
> wilcox.test(resid(m1))

	Wilcoxon signed rank test with continuity correction

data:  resid(m1)
V = 632, p-value = 0.9615
alternative hypothesis: true location is not equal to 0
```

<!-- page 22 -->

# Homoscedasticity - numerically

How can we assess whether the variance of our errors is constant?
* Partition/subset residuals and compare using F test
  * ```r
    var.test(dat$residuals[dat$fitted <0.4],
    dat$residuals[dat$fitted >=0.4])
    ```

What else might we do?
* Examine for correlation between residuals and fitted values.
  * ```r
    cor(dat$residuals, dat$fitted)
    ```
* Fit linear model comparing residuals and fitted values.
  * ```r
    summary(lm(residuals ~ fitted, dat))
    ```

<!-- page 23 -->

# Homoscedasticity - numerically

How can we assess whether the variance of our errors is constant?

* Partition/subset residuals and compare using F test
  * ```r
    var.test(dat$residuals[dat$fitted <0.4], dat$residu
    ```

What do you expect to see with each of these tests?

What else might we do?

* Examine for correlation between residuals and fitted values.
  * ```r
    cor(dat$residuals, dat$fitted)
    ```
* Fit linear model comparing residuals and fitted values.
  * ```r
    summary(lm(residuals ~ fitted, dat))
    ```

<!-- page 24 -->

# Zero mean error + homoscedasticity

* Telltale funnel shape.
* Suggests strong non-constant error variance.
* No violation of zero mean error already confirmed.

<!-- page 25 -->

# Homoscedasticity - numerically

How can we assess whether the variance of our errors is constant?

* Partition/subset residuals and compare using F test
  * ```r
    var.test(dat$residuals[dat$fitted <0.4], dat$residuals[dat$fitted >=0.4])
    ```

```r
> var.test(dat$residuals[dat$fitted <0.4], dat$residuals[dat$fitted >=0.4])

	F test to compare two variances

data:  dat$residuals[dat$fitted < 0.4] and dat$residuals[dat$fitted >= 0.4]
F = 0.13192, num df = 25, denom df = 23, p-value = 3.744e-06
alternative hypothesis: true ratio of variances is not equal to 1
95 percent confidence interval:
 0.05768073 0.29749247
sample estimates:
ratio of variances 
         0.1319215
```

<!-- page 26 -->

# Homoscedasticity - numerically

How can we assess whether the variance of our errors is constant?

* Examine for correlation between residuals and fitted values.
  * `cor(dat$residuals, dat$fitted)`

```r
> cor(dat$fitted, dat$residuals)
[1] 0.02424518
```

* Fit linear model comparing residuals and fitted values.
  * `summary(lm(residuals ~`

```r
> summary(lm(residuals ~ fitted, dat))

Call:
lm(formula = residuals ~ fitted, data = dat)

Residuals:
     Min       1Q   Median       3Q      Max 
-1.36993 -0.21725 -0.02996  0.26965  1.35893 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)  0.01052    0.13442   0.078    0.938
fitted       0.04313    0.25668   0.168    0.867

Residual standard error: 0.5057 on 48 degrees of freedom
Multiple R-squared:  0.0005878, Adjusted R-squared:  -0.02023 
F-statistic: 0.02823 on 1 and 48 DF,  p-value: 0.8673
```

<!-- page 27 -->

# Zero mean error + homoscedasticity

## Zero mean error
* Can be difficult to assess graphically.
* Better to assess by taking mean of the residuals $\rightarrow$ can get p-value if needed.

## Homoscedasticity
* Should **always** assess graphically.
* For less obvious cases can stratify errors and compare variance of strata using F test.
* Checking correlation/association between residuals and fitted values generally insufficient.

<!-- page 28 -->

# Zero mean error + homoscedasticity

There are a number of other tests that you may come across which aim to assess homoscedasticity (e.g., Levene, Brown-Forsythe, Breusch-Pagan, Bartlett).

**\*\*Do not use these in this class. Each has its own limitations which we will not go into, so stick with the approaches we've discussed.\*\***

<!-- page 29 -->

# Zero mean error + error normality

Can clearly see that the residuals are not normally distributed.

ISLR Figure 3.9

<!-- page 30 -->

# How else might we assess error normality?

* Graphically?
* Statistically?

<!-- page 31 -->

# How else might we assess error normality?

* Graphically?
  * QQ plot
* Statistically?
  * Shapiro-Wilk test
  * Should not be relied on as it may suggest departures from normality when there really are none—particularly with large sample sizes.

<!-- page 32 -->

# Uncorrelated errors

* One of the most important assumptions to assess, but unfortunately also difficult to assess given the numerous patterns correlation can take.
* Some common examples when errors may be correlated:
  * Time series data: (e.g., temperature over time, cases of influenza over time, etc.)
  * Clustered data: (e.g., geographic proximity, repeated measures, etc.)
* Serial correlation like that seen in time series data can sometimes be identified using residual plots.
  * Often, the potential for correlated errors is something you need to consider when assessing the type of data you’re using.

<!-- page 33 -->

# Uncorrelated errors

<!-- page 34 -->

# Unusual observations

<!-- page 35 -->

# Unusual observations

Leverage
* How similar the value of an observation is in relation to the majority of values for that variable.

Outliers
* How similar is an observation compared to what the regression estimates for that value.

Influential points
* Removal of an influential observation from the data results in a large change in the model fit.

<!-- page 36 -->

# Unusual observations

Leverage

* Measured with hat and internally studentized residuals
  * `hatvalues(model)` $\rightarrow$ should sum to number of parameters in model
    * Want to examine hat values > 2(mean(hatvalues(model)))
    * Larger hat value $\rightarrow$ greater leverage (often examined using half normal plot)
  * `rstandard(model)`

Outliers

* Measured through externally studentized residuals – `rstudent()`
  * Can assess whether largest residuals are greater than the critical value by:
  * ```r
    sort(abs(r_ex),dec=T)[1:10]>abs(qt(.05/(10),120-2))
    ```

Influential points

* Measured with Cook’s Distance – `cooks.distance(model)`

<!-- page 37 -->

# Unusual observations

Leverage

* Measured with hat and internally studentized residuals
  * `hatvalues(model)` $\rightarrow$ should sum to number of parameters in model
    * Want to examine hat values > 2(mean(hatvalues(model)))
    * Larger hat value $\rightarrow$ greater leverage (often examined using half normal plot)
  * `rstandard(model)`

Outliers

* Measured through externally studentized residuals – `rstudent()`
  * Can assess whether largest residuals are greater than the critical value by:
  * 
```r
sort(abs(r_ex),dec=T)[1:10]>abs(qt(.05/(10),120-2))
```

Influential points

* Measured with Cook's Distance – `cooks.distance(model)`

<!-- page 38 -->

# Perfect_add2-perfect_add5 Models

What do you points do you think have high leverage?

Are outliers?

Are influential?

<!-- page 39 -->

# Multiple testing

<!-- page 40 -->

# Multiple testing

* We saw the code below a few slides ago. Where is the correction for multiple testing?
  * 
```r
sort(abs(r_ex),dec=T)[1:10]>abs(qt(.05/(10),120-2))
```

<!-- page 41 -->

# Multiple testing

* We saw the code below a few slides ago. Where is the correction for multiple testing?
  * 
```r
sort(abs(r_ex),dec=T)[1:10]>abs(qt(.05/(10),120-2))
```

* We're making 10 comparisons, so under the Bonferroni correction we divide alpha by 10.

<!-- page 42 -->

# Multiple testing

* We saw the code below a few slides ago. Where is the correction for multiple testing?
  * ```r
    sort(abs(r_ex),dec=T)[1:10]>abs(qt(.05/(10),120-2))
    ```

* We’re making 10 comparisons, so under the Bonferroni correction we divide alpha by 10.

What does this do?

<!-- page 43 -->

# Multiple testing

ISLR Figure 13.2
