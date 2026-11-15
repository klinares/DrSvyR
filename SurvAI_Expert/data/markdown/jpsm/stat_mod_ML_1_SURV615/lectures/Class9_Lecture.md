---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class9_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class9_Lecture.pdf"
pages: 65
sha256: "661e0ee98370f0f48c57f6f0e4ba2a69ddb03ea178f70fd01e7de2f754b4f276"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:19"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #9

John Kubale

October 29, 2024

<!-- page 2 -->

# Outline

* Review
* Model Diagnostics
  * Model Error Assumptions
  * Assessing Model Error Assumptions
* Unusual Observations
  * Leverage
  * Outliers
  * Influential Observations
* Structure of Relationship
* Lab

<!-- page 3 -->

# Review

<!-- page 4 -->

# Choosing the appropriate interval

Which number is asking for a prediction interval?

1. Predict the amount that a male with average values for each of the predictors would spend on gambling along with an appropriate 95% interval.

2. Predict the amount that males with average values for each of the predictors would spend on gambling along with an appropriate 95% interval.

<!-- page 5 -->

# Choosing the appropriate interval

1. Predict the amount that a male with average values for each of the predictors would spend on gambling along with an appropriate 95% interval.

2. Predict the amount that males with average values for each of the predictors would spend on gambling along with an appropriate 95% interval.

<!-- page 6 -->

# Choosing the appropriate interval

Prediction intervals used when we want to describe the uncertainty around a single new observation of the outcome given specific predictor values.

1. Predict the amount that a male with average values for each of the predictors would spend on gambling along with an appropriate 95% interval.

2. Predict the amount that males with average values for each of the predictors would spend on gambling along with an appropriate 95% interval.

Confidence intervals used when we want to describe the uncertainty around the estimated mean outcome for a group with specific predictor values.

<!-- page 7 -->

# Prediction example

Greater uncertainty in predicting single new values (compared to mean), so prediction intervals are always wider.

<!-- page 8 -->

# When to include/exclude covariates?

## *Ye Olde Causal Alchemy*
### The Four Elemental Confounds

| | |
| :---: | :---: |
| *The Fork*<br>$$X \leftarrow Z \rightarrow Y$$ | *The Pipe*<br>$$X \rightarrow Z \rightarrow Y$$ |
| *The Collider*<br>$$X \rightarrow Z \leftarrow Y$$ | *The Descendant*<br>$$\begin{array}{c} X \rightarrow Z \rightarrow Y \\ \downarrow \\ A \end{array}$$ |

McElreath, 2023

<!-- page 9 -->

# When we don't want to include covariates

## *Ye Olde Causal Alchemy*
### The Four Elemental Confounds

| | |
| :---: | :---: |
| *The Fork*<br>$$X \leftarrow Z \rightarrow Y$$ | *The Pipe*<br>$$X \rightarrow Z \rightarrow Y$$ |
| *The Collider*<br>$$X \rightarrow Z \leftarrow Y$$ | *The Descendant*<br>$$\begin{array}{ccccc} X & \rightarrow & Z & \rightarrow & Y \\ & & \downarrow & & \\ & & A & & \end{array}$$ |

McElreath, 2023

<!-- page 10 -->

# Model Diagnostics

<!-- page 11 -->

# Model diagnostics

* Have discussed some means of assessing model fit
  * $R^2$, adjusted $R^2$, RSS, general F test, etc.
* How would we assess whether the assumptions made in fitting the model are reasonable?

<!-- page 12 -->

# OLS Assumptions

Will see these assumptions presented a variety of ways (e.g., some are often combined), but they boil down to the following:

1. There is a linear relationship between the predictor(s) $X$ and the outcome $Y$. – Relatively simple assumption to relax as we will see.
2. Variable, $X_1, \dots, X_n$, are fixed constants such that $S_{XX} > 0$
3. Variable, $\epsilon_1, \dots, \epsilon_n$, are random variables
4. Zero Error Mean: $E(\epsilon_i) = 0$ for $i = 1, \dots, n$
5. Uncorrelated errors: $\epsilon_1, \epsilon_2, \dots, \epsilon_n$ are not correlated – i.e., knowing value of $\epsilon_1$ tells you nothing about $\epsilon_2, \dots, \epsilon_n$
6. Constant error variance: $\text{V}(\epsilon_i) = \sigma^2$ -- AKA homoscedasticity
7. Error normality: $\epsilon_i \sim N(0, \sigma^2)$ for $i = 1, \dots, n$

<!-- page 13 -->

# OLS Assumptions

Will see these assumptions presented a variety of ways (e.g., some are often combined), but they boil down to the following:

1. There is a linear relationship between the predictor(s) $X$ and the outcome $Y$. – Relatively simple assumption to relax as we will see.
2. Variable, $X_1, \dots, X_n$, are fixed constants such that $S_{XX} > 0$
3. Variable, $\epsilon_1, \dots, \epsilon_n$, are random variables
4. Zero Error Mean: $E(\epsilon_i) = 0$ for $i = 1, \dots, n$
5. Uncorrelated errors: $\epsilon_1, \epsilon_2, \dots, \epsilon_n$ are not correlated – i.e., knowing value of $\epsilon_1$ tells you nothing about $\epsilon_2, \dots, \epsilon_n$
6. Constant error variance: $\text{V}(\epsilon_i) = \sigma^2$ -- AKA homoscedasticity
7. Error normality: $\epsilon_i \sim N(0, \sigma^2) \text{ for } i = 1, \dots, n$

<!-- page 14 -->

# OLS Assumptions

Pay particular attention to assumptions 4-7
* Taken together they state that our errors are assumed to be normal, independent, and identically distributed (Normal I.I.D).

Jenkins-Smith, Ripberger, Copeland, et. al.

<!-- page 15 -->

# Why is it important to assess whether these assumptions are met?

<!-- page 16 -->

# Bias, efficiency, and Consistency

* Bias: Do we get the "correct answer" on average across many repeated samples?
  * An estimator is considered "unbiased" if its expected value equals the true value on average
* Efficiency: the variance around an estimate
  * Efficient -> little variability in estimate across samples
  * Inefficient -> large variability in estimate across samples
* Consistency: estimate gets closer to truth as sample size increases
  * Different from bias which implies that estimate is close to the truth on average even when sample size is small

<!-- page 17 -->

# Bias, efficiency, and Consistency

* Bias: Do we get the "correct answer" on average across many repeated samples?
  * An est... ...he true value
* Efficienc...
  * Efficie...
  * Ineffic...
* Consiste... ...creases
  * Differe... ...on average even when...

> "...Given that nearly all social science research is conducted using just one sample of data (e.g., one survey sample), researchers should take efficiency just as seriously. As an estimator becomes less efficient, the likelihood that a singe estimate is close to the true parameter declines."
>
> Carsey and Harden

<!-- page 18 -->

# Bias, efficiency, and Consistency

| | High efficiency | Low efficiency |
| :--- | :---: | :---: |
| **Low bias** | | |
| **High bias** | | |

<!-- page 19 -->

# Distribution of estimated parameters

<!-- page 20 -->

# Distribution of estimated parameters

Violation of constant error variance assumption leads to inefficiency

Heteroscedastic Homoscedastic

Density $\hat{\beta}_0$ $\hat{\beta}_1$

<!-- page 21 -->

# Impact of assumption violations

* Dependence of errors can cause problems as it means there is less information in your dataset than sample size would lead you to believe.
  * Think your estimates are more precise than they are.
* Non-constant error variance can cause problems with inaccurate inferences due to poorly quantified precision.
  * Prediction uncertainty particularly susceptible.
* Non-normal errors can also lead to inaccurate inferences, but for larger datasets inferences will be more robust to moderate violations due to the central limit theorem.
* Violation of zero mean error assumption can indicate issues with error dependence, error normality, and/or non constant error variance.

<!-- page 22 -->

# How can we check whether these assumptions are met?

<!-- page 23 -->

# Checking Residuals

- Model Diagnostics!
- Zero mean
  - Graphical Display
  - Numeric: Statistical Tests
- Constant variance; independence of other variables
  - Graphical display
  - Numeric: Statistical Tests
- Normal Distribution
  - Graphical Display
  - Numeric: Statistical Tests

<!-- page 24 -->

# Checking Residuals

* Model Diagnostics!
* Zero mean
  * **<u>Graphical Display</u>**
  * Numeric: Statistical Tests
* Constant variance; independence of
  * **<u>Graphical display</u>**
  * Numeric: Statistical Tests
* Normal Distribution
  * **Graphical Display**
  * Numeric: Statistical Tests

> \*\*While there are statistical tests we can use (some of which we've already learned like the Shapiro-Wilk test of normality) they can be misleading.\*\*

<!-- page 25 -->

# Zero mean error

* Let’s look at a few different scenarios to see what these violations might look like graphically.
* To do this we will fit a scatter plot with our fitted values for a given model on the x axis and the residuals from the same model on y axis

<!-- page 26 -->

# Zero mean error + homoscedasticity

What do you see?

<!-- page 27 -->

# Zero mean error + homoscedasticity

* No discernable pattern.
* Relatively equal spread above and below the line.
* No apparent violation.

<!-- page 28 -->

# Zero mean error + homoscedasticity

What do you see?

<!-- page 29 -->

# Zero mean error + homoscedasticity

* Telltale funnel shape.
* Suggests strong non-constant error variance.
* Violation of zero mean error.

<!-- page 30 -->

# Zero mean error + homoscedasticity

What do you see?

<!-- page 31 -->

# Zero mean error + homoscedasticity

* Slight funnel shape.
* Mild non-constant error variance.
* May not be very impactful.

<!-- page 32 -->

# Zero mean error + error normality

Can clearly see that the residuals are not normally distributed.

ISLR Figure 3.9

<!-- page 33 -->

# How else might we assess error normality?

* Graphically?
* Statistically?

<!-- page 34 -->

# How else might we assess error normality?

* Graphically?
  * QQ plot
* Statistically?
  * Shapiro-Wilk test
  * Should not be relied on as it may suggest departures from normality when there really are none—particularly with large sample sizes.

<!-- page 35 -->

# How else might we assess homoscedasticity?

What do you notice about this plot?

<!-- page 36 -->

# How else might we assess homoscedasticity?

Seem to be 2 clusters with different error variance.

Could stratify based on values of x (e.g., $\pm 35$) and use var.test() to compare variance of residuals.

<!-- page 37 -->

# Uncorrelated errors

* One of the most important assumptions to assess, but unfortunately also difficult to assess given the numerous patterns correlation can take.
* Some common examples when errors may be correlated:
  * Time series data: (e.g., temperature over time, cases of influenza over time, etc.)
  * Clustered data: (e.g., geographic proximity, repeated measures, etc.)
* Serial correlation like that seen in time series data can sometimes be identified using residual plots.
  * Often, the potential for correlated errors is something you need to consider when assessing the type of data you’re using.

<!-- page 38 -->

# Linear Regression and OLS Estimator

Estimate $Y = X\beta + \epsilon$ with sample data

* Used to describe, predict, and explain $Y$
* Parameters?
* What is the approach for parameter estimation we’ve focused on?
* Hypotheses
* Inferences
* Assumptions for inferences and hypothesis testing
* How do we know if the model is “good”?
* What are important features for **valid** inferences?

<!-- page 39 -->

# Hypothetical “Perfect” Linear Regression Model-1

```r
#A perfect simple linear regression model for n=100 sample data

id<-c(1:100)
set.seed(312)
x<-rnorm(100,15,5)
set.seed(135)
e<-rnorm(100,0,4)
y<-10+3*x+e

perfect<-as.data.frame(cbind(id,y,x))

mod_perfect<-lm(y~x,perfect)
```

What kind of relationship do you expect between $x$ and $y$?

<!-- page 40 -->

# Hypothetical “Perfect” Linear

What do you observe?

<!-- page 41 -->

# Unusual Observations

<!-- page 42 -->

# Unusual Observations: Changes to perfect - 1

Reminder of what we're starting with

<!-- page 43 -->

# Unusual Observations: Changes to perfect - 2

* Let’s add some additional data points using the following code:

```r
d <- c("id","y","x")
add1 <- as.data.frame(setNames(
  list(c(101:120),
  c(sample(c(56:60),10,rep=T),sample(c(41:45),10, rep=T)),
  c(sample(c(5:10),10,rep=T),sample(c(25:30),10, rep=T))),
  d))
```

<!-- page 44 -->

# Unusual Observations: Changes to perfect - 3

perfect

perfect + add1

<!-- page 45 -->

# Unusual Observations: Changes to perfect - 4

What do you think the new data points from “add1” will do to the regression line?

<!-- page 46 -->

# Unusual Observations: Changes to perfect - 5

What do you observe?

<!-- page 47 -->

# Unusual Observations: Change to perfect - 2

```r
add2<-as.data.frame(setNames(list(c(121:140),
                                  c(sample(c(180:200),20,rep=T)),
                                  c(sample(c(40:50),20,rep=T))),d))
perfect_add2<-rbind(perfect,add2)

add3<-as.data.frame(setNames(list(c(141:160),
                                  c(sample(c(180:200),20,rep=T)),
                                  c(sample(c(10:20),20,rep=T))),d))
perfect_add3<-rbind(perfect,add3)

add4<-as.data.frame(setNames(list(c(161:180),
                                  c(sample(c(40:60),20,rep=T)),
                                  c(sample(c(40:50),20,rep=T))),d))
perfect_add4<-rbind(perfect,add4)

add5<-as.data.frame(setNames(list(c(181:200),
                                  c(sample(c(45:60),20,rep=T)),
                                  c(sample(c(15:20),20,rep=T))),d))
perfect_add5<-rbind(perfect,add5)
```

What is different about the dataset perfect vs. perfect\_add2 to perfect\_add5?

<!-- page 48 -->

# Perfect_add2-perfect_add5 Models

What do you observe?

<!-- page 49 -->

# Outliers

<!-- page 50 -->

# Outliers

- Observations that do not fit the model like the rest of observations
- More specifically a point is considered an outlier if $y_i$ is far from the value predicted by the regression model

<!-- page 51 -->

# Outliers

* **<u>May or may not change the model estimates</u>**
* Sometimes need to remove outliers from data

$Y_i = X_i\beta + \delta_i\gamma + \epsilon_i$ for all $i = 1, \dots, n$

where $\delta_i$ is a 1/0 indicator of the outlier candidate

$\gamma = Y - X\beta - \epsilon \text{ when } \delta_i = 1$

* When all obs follow the same model, $Y = X\beta + \epsilon$ and $\gamma = 0$
* When $\gamma \neq 0$ for $i$, unit $i$ doesn't fit the same model as the rest of the sample $\rightarrow i$ is an outlier

<!-- page 52 -->

# Outliers – How to detect?

$H_o: \gamma = 0 \text{ (not outlier) } vs. H_A: \gamma \neq 0 \text{ (an outlier)}$

Test statistic: $t_i = \frac{\hat{\gamma}}{se(\hat{\gamma})}$

Use (Externally) Studentized Residuals

$t_i = r_i \sqrt{\frac{n-p-1}{n-p-r_i^2}} = \frac{\hat{\epsilon}_i}{\sqrt{\hat{\sigma}_{(i)}^2(1-h_{ii})}}$ where

$\hat{\sigma}_{(i)}^2$: MSE from the regression with the unit $i$ removed from data

$t_i$: Externally studentized residuals, following standard normal

<!-- page 53 -->

# Leverage

<!-- page 54 -->

# Leverage - 1

* Leverage assesses how similar specific, observed values of a predictor, $x_i$, are to the majority of the observed values of that predictor

<!-- page 55 -->

# Leverage - 2

For an individual observation, $i$,

$$
V(\hat{\epsilon}_i) = \sigma^2(1 - h_i)
$$

$h_i$: the $i^{th}$ diagonal element of $H$ (Hat/Projection matrix);

* Leverage or potential of the $i^{th}$ observation on the model estimation
* $\sum h_i = p$; $\bar{h} = \frac{\sum h_i}{n} = \frac{p}{n}$
* $h_i > \frac{2p}{n}$ needs closer look – half normal plot can be useful

<!-- page 56 -->

# Leverage - 3

Internally studentized (or standardized) residuals:

$$r_i = \frac{\hat{\epsilon}_i}{\hat{\sigma}\sqrt{1 - h_i}} \text{ for all } i = 1, \dots, n$$

Approximately standard normal (a mean of 0 and a constant var of 1)

* For the same residual values, large $h_i \rightarrow$ large $r_i$
* Q-Q plot
* (Also, $r_i$ can be used instead of residuals in the diagnostics plots)

<!-- page 57 -->

# Influential Observations

<!-- page 58 -->

# Influential Observations

* Removal from the data results in a large change in the fit
* May be an outlier, have a large leverage, or both
* Recall plots on slides #44, #46, and #48
* How do you measure influence? Cook’s distance!

<!-- page 59 -->

# Influential Observations: Cook’s Distance

Cook’s Distance: $D_i = \frac{(\hat{\beta}_{(i)} - \hat{\beta})^T(X^TX)(\hat{\beta}_{(i)} - \hat{\beta})}{p\hat{\sigma}^2}$, where

* $\hat{\beta} = (X^TX)^{-1}X^TY$
* $\hat{\beta}_{(i)} = (X_{(i)}^TX_{(i)})^{-1}X_{(i)}^TY_{(i)}$
  * $(i)$: the deletion of the unit $i$ from the data
* $D_i$: indicates the level of unit $i's$ influence on the overall analysis
* $p$ is the number of regression coefficients (or dimension of $\beta$)
* Test hypothesis: $H_0: \hat{\beta} = \hat{\beta}_{(i)} \text{ vs. } H_A: \hat{\beta} \neq \hat{\beta}_{(i)}$

Also, $D_i = \frac{r_i^2}{p} \frac{h_i}{(1-h_i)}$, where $r_i$: Standardized residual; $h_i$: Leverage

<!-- page 60 -->

# Structure of Relationship

<!-- page 61 -->

# How to check structure between $y$ and $x$?

* LINEAR relationship
* Simple linear regression: Straight-forward with scatter plot
* Multiple linear regression: Not as easy
  * Partial regression plots:
  
    i.e., controlling for the effect of other predictors
  * Partial residual plots
  
    i.e., ($y_i$ - effect of other predictors) against $x_i$

<!-- page 62 -->

# How to check structure between $y$ and $x$?

* Partial residual plots:
    * Fit model with all predictors (e.g., `mod1 <- lm(outcome ~ age + x2 + x3, data)`
    * Fit the model again, but removing one of the predictors each time and save the residuals indicating which variable was removed (e.g., `data$rd_age_y`).
    * Fit a model with each predictor as the outcome as a function of the other covariates and save the residuals again indicating in the name which variable was the outcome (e.g., `data$rd_age`).
    * Create a scatter plot predictor using the saved residuals and the coefficient from the original model
        * ```r
          plot(data$rd_age, data$rd_age_y); abline(0, coef(mod1)['age'], col="red")
          ```

<!-- page 63 -->

# How to check structure between $y$ and $x$?

Alternatively, can simply use
```r
termplot(mod1, partial.resid=T)
```
.

Will also correctly manage categorical predictors.

* Partial residual plots:
    * Fit mod...
    * Fit the ... residual...
    * Fit a mo... ates and sav... ome (e.g., data\$rd_age).
    * Create a scatter plot predictor using the saved residuals and the coefficient from the original model
        * ```r
          plot(data$rd_age, data$rd_age_y); abline(0, coef(mod1)['age'], col="red")
          ```

<!-- page 64 -->

# Lab Session

<!-- page 65 -->

# What should you expect in today's Lab?

1. Checking assumptions about errors through residuals: using cheddar data from faraway package
2. Leverage through hat (and half normal plots) and standardized (i.e., internally studentized) residuals: With perfect_add5 data
3. Outlier detection through (externally) studentized residuals: With perfect_add5 data
4. Influential observations through Cook's distance: With perfect_add5 data
5. Checking relationship structures through partial regression plots, partial residual plots and analysis on the subsetted data: With cheddar data
