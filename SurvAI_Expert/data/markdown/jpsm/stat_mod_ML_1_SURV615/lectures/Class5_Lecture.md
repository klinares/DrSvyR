---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class5_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class5_Lecture.pdf"
pages: 57
sha256: "5617c23be16b02be517cc3a30beefe411d408cea4a19f1bdc757456b2307acd6"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:17"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #5

John Kubale

September 24, 2024

<!-- page 2 -->

# Outline

* Review
* Multiple Linear Regression
  * Why we do it
  * DAGs
  * Multiple Linear Regression Estimation
* Interpretation of Regression Coefficients
* Inference about Regression Coefficients
* Analysis of Variance in Linear Regression
* Model Comparison
* Goodness of Model Fit

<!-- page 3 -->

# Review

<!-- page 4 -->

# “As a function of”

* HW3 included question: “Analyze the crime rates (`crim`) as a function of median home values (`medv`) in a simple linear regression…”
  * Which is the dependent variable (i.e., your outcome)?
  * Which is the independent variable (i.e., your predictor)?

<!-- page 5 -->

# “As a function of”

* HW included question: “Analyze the crime rates (`crim`) as a function of median home values (`medv`) in a simple linear regression…”
  * Which is the dependent variable (i.e., your outcome)?
  * Which is the independent variable (i.e., your predictor)?
* ```r
  lm(crim ~ medv, Boston)
  ```
* Put another way: $E(crim) = f(medv) \rightarrow$ here the “function” is the linear model

<!-- page 6 -->

# Training vs. test data

* Training data are the model used to fit (or train) your model
* Test data are data <u>not used</u> in fitting/training the model, but that the model is used on to make predictions or inferences (<u>**i.e., they're previously unseen**</u>)
* Each has their own error (i.e., training error and test error)
* Which do you think is most important for assessing model fit?

<!-- page 7 -->

# Training vs. test data

* Training data are the model used to fit (or train) your model
* Test data are data <u>not used</u> in fitting/training the model, but that the model is used on to make predictions or inferences
* Each has their own error (i.e., training error and test error)
* Which do you think is most important for assessing model fit?
  * Can you see any challenges in using it for assessing model fit?

<!-- page 8 -->

# Why do we sometimes include multiple predictors?

<!-- page 9 -->

# Why we sometimes include multiple predictors

* Allows us to test for a given association between a predictor/outcome while accounting for influence of other variables.
* Allows us to predict what will happen to an outcome when a predictor changes, while keeping other variables constant.

<!-- page 10 -->

# Why we sometimes include multiple predictors

* Allows us to test for a given association between a predictor/outcome while accounting for influence of other variables.
* Allows us to predict what will happen to an outcome when a predictor changes, while keeping other variables constant.
* Let’s look at an example to see why this is useful in practice.

<!-- page 11 -->

# Heavy metal happiness

```r
Call:
lm(formula = Happiness ~ log(bands_pm), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.79612 -0.45529  0.04414  0.48408  1.67410 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)    5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm)  0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676 
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

Adapted from McElreath 2023

<!-- page 12 -->

# Heavy metal happiness

How would you interpret the slope for the predictor?

```r
Call:
lm(formula = Happiness ~ log(bands_pm), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.79612 -0.45529  0.04414  0.48408  1.67410 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)    5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm)  0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676 
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

Adapted from McElreath 2023

<!-- page 13 -->

# Heavy metal happiness

How would you interpret the slope for the predictor?

* A one-unit increase in log metal bands per million is associated with an increase of 0.3 in mean expected happiness score.
* A 10% increase in bands per million is associated with an increase in mean expected happiness of $0.30607 * \log(1.1) = 0.03$.

```r
Call:
lm(formula = Happiness ~ log(bands_pm), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.79612 -0.45529  0.04414  0.48408  1.67410 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)    5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm)  0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676 
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

Adapted from McElreath 2023

<!-- page 14 -->

# Heavy metal happiness

Is heavy metal really the secret to happiness?

```r
Call:
                         log(bands_pm), data = metal_bands2)

    Min      1Q  Median      3Q     Max
-2.79612 -0.45529  0.04414  0.48408  1.67410

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)   5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm) 0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

Adapted from McElreath 2023

<!-- page 15 -->

# Heavy metal happiness

What might be happening here?

```r
Call:
rmula = Happiness ~ log(bands_pm), data = metal_bands2)

duals:
     Min       1Q   Median       3Q      Max 
-2.79612 -0.45529  0.04414  0.48408  1.67410 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept)   5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm) 0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676 
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

Adapted from McElreath 2023

<!-- page 16 -->

# Heavy metal happiness

Does this give you any ideas?

Adapted from McElreath 2023

<!-- page 17 -->

# Heavy metal happiness

* What happens if we add a measure of relative affluence like GDP per capita to the model?

```r
Call:
lm(formula = Happiness ~ log(bands_pm) + log(gdp_pc_2021), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.37413 -0.24014  0.01006  0.34185  1.35327 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)       0.73622    0.57267   1.286   0.2016    
log(bands_pm)     0.08171    0.03775   2.165   0.0328 *  
log(gdp_pc_2021)  0.53624    0.06708   7.994 2.34e-12 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.6006 on 100 degrees of freedom
  (19 observations deleted due to missingness)
Multiple R-squared:  0.6784,	Adjusted R-squared:  0.6719 
F-statistic: 105.5 on 2 and 100 DF,  p-value: < 2.2e-16
```

<!-- page 18 -->

# Heavy metal happiness

* What happens if we add a measure of relative affluence like GDP per capita from the World Bank to the model?

```r
Call:
lm(formula = Happiness ~ log(bands_pm), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.79612 -0.45529  0.04414  0.48408  1.67410 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)    5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm)  0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676 
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

```r
Call:
lm(formula = Happiness ~ log(bands_pm) + log(gdp_pc_2021), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.37413 -0.24014  0.01006  0.34185  1.35327 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)       0.73622    0.57267   1.286   0.2016    
log(bands_pm)     0.08171    0.03775   2.165   0.0328 *  
log(gdp_pc_2021)  0.53624    0.06708   7.994 2.34e-12 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.6006 on 100 degrees of freedom
  (19 observations deleted due to missingness)
Multiple R-squared:  0.6784,	Adjusted R-squared:  0.6719 
F-statistic: 105.5 on 2 and 100 DF,  p-value: < 2.2e-16
```

<!-- page 19 -->

# Heavy metal happiness

* What happens if we add a measure of relative affluence like GDP per capita from the World Bank to the model?

```r
Call:
lm(formula = Happiness ~ log(bands_pm), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.79612 -0.45529  0.04414  0.48408  1.67410 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept)   5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm) 0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676 
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

A 10% increase of metal bands per million is associated with an increase in mean expected happiness of 0.03.

```r
Call:
lm(formula = Happiness ~ log(bands_pm) + log(gdp_pc_2021), data = metal_bands2)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.37413 -0.24014  0.01006  0.34185  1.35327 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)       0.73622    0.57267   1.286   0.2016    
log(bands_pm)     0.08171    0.03775   2.165   0.0328 *  
log(gdp_pc_2021)  0.53624    0.06708   7.994 2.34e-12 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.6006 on 100 degrees of freedom
  (19 observations deleted due to missingness)
Multiple R-squared:  0.6784,	Adjusted R-squared:  0.6719 
F-statistic: 105.5 on 2 and 100 DF,  p-value: < 2.2e-16
```

A 10% increase of metal bands per million is associated with an increase in mean expected happiness of 0.008 after adjusting for GDP per capita.

<!-- page 20 -->

# Heavy metal happiness

* What happens if we add a measure of relative affluence like GDP per capita to the model?

```r
Call:
lm(formula = Happiness ~ log(bands_pm), data = metal_bands2)

Residuals:
    Min      1Q  Median      3Q     Max 
-2.79612 -0.45529  0.04414  0.48408  1.6

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  5.27412    0.09646  54.678  < 2e-16 ***
log(bands_pm)  0.30607    0.03216   9.518 1.04e-15 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7652 on 101 degrees of freedom
  (44 observations deleted due to missingness)
Multiple R-squared:  0.4728,	Adjusted R-squared:  0.4676 
F-statistic: 90.58 on 1 and 101 DF,  p-value: 1.037e-15
```

```r
Call:
lm(formula = Happiness ~ log(bands_pm) + log(gdp_pc_2021), data = metal_bands2)

Residuals:
    Min      1Q  Median      3Q     Max 
                                   5327

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)       0.73622    0.57267   1.286   0.2016    
log(bands_pm)     0.08171    0.03775   2.165   0.0328 *  
log(gdp_pc_2021)  0.53624    0.06708   7.994 2.34e-12 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.6006 on 100 degrees of freedom
  (19 observations deleted due to missingness)
Multiple R-squared:  0.6784,	Adjusted R-squared:  0.6719 
F-statistic: 105.5 on 2 and 100 DF,  p-value: < 2.2e-16
```

What do you think this means?

A 10% increase of metal bands per million is associated with an increase in mean expected happiness of 0.03.

A 10% increase of metal bands per million is associated with an increase in mean expected happiness of 0.008 after adjusting for GDP per capita.

<!-- page 21 -->

# DAGs a very brief intro

<!-- page 22 -->

# Directed Acyclic Graphs (DAGs)

* DAGS = **<u>D</u>**irected **<u>A</u>**cyclic **<u>G</u>**raphs
* DAGs are a tool commonly used by researchers to conceptualize the relationship being modeled
* Directed: $\rightarrow$
* Acyclic:

<!-- page 23 -->

# Directed Acyclic Graphs (DAGs)

* The presence of an **<u>arrow indicates the possibility/assumption of a relationship, not that it absolutely exists</u>**
  * This assumption should be based on prior evidence!

Time flows north to south
Transit strike
Bike to work
Bike crash
?
Time flows left to right

Bustos Carillo, 2019

<!-- page 24 -->

# Directed Acyclic Graphs (DAGs)

* How might we represent the heavy metal/happiness model in a DAG?

<!-- page 25 -->

# Directed Acyclic Graphs (DAGs)

- How might we represent the heavy metal/happiness model in a DAG?

Support for music/art

GDP per capita

Social services

Metal bands

?

Happiness

<!-- page 26 -->

# Directed Acyclic Graphs (DAGs)

* How might we represent the heavy metal/happiness model in a DAG?
  * Open “backdoor path” from the exposure (metal bands) through support for music/art, GDP per capita, and social services to the outcome (happiness).
  * What happens when we “control” for GDP per capita by including it as a predictor?

$$\begin{array}{ccccc}
\text{Support} & & \text{GDP per capita} & & \text{Social} \\
\text{for} & \swarrow & & \searrow & \text{services} \\
\text{music/art} & & & & \\
\downarrow & & & & \downarrow \\
\text{Metal bands} & & \xrightarrow{\quad\quad ? \quad\quad} & & \text{Happiness}
\end{array}$$

<!-- page 27 -->

# Directed Acyclic Graphs (DAGs)

* How might we represent the heavy metal/happiness model in a DAG?
  * Controlling for GDP per capita by including it in the model closes the backdoor path allowing us to assess whether the concentration of metal bands in a country is associated with the average happiness of its citizens.

$$\begin{array}{ccc}
\begin{array}{c} \text{Support} \\ \text{for} \\ \text{music/art} \end{array} & \xleftarrow{\quad} \boxed{\text{GDP per capita}} \xrightarrow{\quad} & \begin{array}{c} \text{Social} \\ \text{services} \end{array} \\
\downarrow & & \downarrow \\
\text{Metal bands} & \xrightarrow[\qquad\qquad\qquad]{?} & \text{Happiness}
\end{array}$$

We will talk more about DAGs in a few weeks.

<!-- page 28 -->

# Multiple Linear Regression

<!-- page 29 -->

# Multiple Linear Regression

| $Y$ (`Income`) | $X_1$ (`Education`) | $X_2$ (`Senority`) |
| :---: | :---: | :---: |
| 99.917 | 21.586 | 113.103 |
| 92.579 | 18.276 | 119.310 |
| 34.679 | 12.069 | 100.690 |
| $\vdots$ | $\vdots$ | $\vdots$ |
| 74.611 | 17.034 | 106.897 |

$$
\begin{pmatrix} 99.917 \\ 92.579 \\ 34.679 \\ \vdots \\ 74.611 \end{pmatrix} = \beta_0 + \beta_1 \times \begin{pmatrix} 21.586 \\ 18.276 \\ 12.069 \\ \vdots \\ 17.034 \end{pmatrix} + \beta_2 \times \begin{pmatrix} 113.103 \\ 119.310 \\ 100.690 \\ \vdots \\ 106.897 \end{pmatrix} + \begin{pmatrix} \epsilon_1 \\ \epsilon_2 \\ \epsilon_3 \\ \vdots \\ \epsilon_N \end{pmatrix}
$$

$$
\boldsymbol{Y} = \beta_0 + \beta_1 \boldsymbol{X}_1 + \beta_2 \boldsymbol{X}_2 + \boldsymbol{\epsilon}
$$

<!-- page 30 -->

# Multiple Linear Regression Model

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

$$Y = X\beta + \epsilon$$

* What does $\beta_0$ mean? Do we need $\beta_0$?
* What about $\beta_1$ and $\beta_2$? Do we need $\beta_1$ and $\beta_2$?
* What does $\epsilon$ mean? Do we need $\epsilon$?

<!-- page 31 -->

# Multiple Linear Regression Model

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

$$Y = X\beta + \epsilon$$

> In multiple linear regression the intercept can be interpreted as the expected mean of $y$ when **<u>all predictors equal 0 or their reference group.</u>**

* What does $\beta_0$ mean? Do we need $\beta_0$?
* What about $\beta_1$ and $\beta_2$? Do we need $\beta_1$ and $\beta_2$?
* What does $\epsilon$ mean? Do we need $\epsilon$?

<!-- page 32 -->

# Multiple Linear Regression Model

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

$$Y = X\beta + \epsilon$$

* What does $\beta_0$ mean? Do we need $\beta_0$?
* What about $\beta_1$ and $\beta_2$? Do we need $\beta_1$ and $\beta_2$?
* What does $\epsilon$ mean? Do we need $\epsilon$?

In multiple linear regression each beta coefficient represents the expected change in $y$ for every one unit change in $x$ while holding the other predictors constant.

<!-- page 33 -->

# Refresher from Simple Linear Regression

<!-- page 34 -->

# OLS Estimators of Intercept and Slope; Error variance

$$\hat{\beta}_1 = \frac{\sum_{i=1}^n (X_i - \bar{X})(Y_i - \bar{Y})}{\sum_{i=1}^n (X_i - \bar{X})^2} \equiv \frac{SS_{XY}}{SS_X} = \frac{SS_{XY}(n-1)^{-1}}{SS_X(n-1)^{-1}} = \frac{s_{XY}}{s_{XX}}$$

$$\hat{\beta}_0 = \bar{Y} - \bar{X}\hat{\beta}_1$$

(From property 2)

$$\hat{\sigma}^2 = \frac{\sum_{i=1}^n \hat{\epsilon}_i^2}{n-2} = \frac{RSS}{n-2}, \text{ where}$$

Residual: $\hat{\epsilon}_i = Y_i - \hat{\beta}_0 - \hat{\beta}_1 X_i$,

RSS(Residual Sum of Squares): $\sum_{i=1}^n \hat{\epsilon}_i^2 = SS_Y - \frac{SS_{XY}^2}{SS_X}$

<!-- page 35 -->

# OLS Assumptions

Will see these assumptions presented a variety of ways (e.g., some are often combined), but they boil down to the following:

1. There is a linear relationship between the predictor(s) $X$ and the outcome $Y$. – Relatively simple assumption to relax as we will see.
2. Variable, $X_1, \dots, X_n$, are fixed constants such that $S_{XX} > 0$
3. Variable, $\epsilon_1, \dots, \epsilon_n$, are random variables
4. Zero Error Mean: $E(\epsilon_i) = 0$ for $i = 1, \dots, n$
5. Uncorrelated errors: $\epsilon_1, \epsilon_2, \dots, \epsilon_n$ are not correlated – i.e., knowing value of $\epsilon_1$ tells you nothing about $\epsilon_2, \dots, \epsilon_n$
6. Constant error variance: $\text{V}(\epsilon_i) = \sigma^2$ -- AKA homoscedasticity
7. Error normality: $\epsilon_i \sim N(0, \sigma^2)$ $for\ i = 1, \dots, n$

<!-- page 36 -->

# Properties of OLS

1. OLS estimators are unbiased as $E(\hat{\beta}_0, \hat{\beta}_1) = (\beta_0, \beta_1)$
2. Estimated error variance through residuals is unbiased as $E(\hat{\sigma}^2) = \sigma^2$
3. We can express variance-covariance of OLS estimates
4. We can derive unbiased estimators of OLS variance-covariance
5. OLS Estimators=Best Linear Unbiased Estimators
6. Regression coefficients follow a bivariate normal distribution
7. Estimated error variance, $\hat{\sigma}^2$, follows a $\chi^2$ distribution

<!-- page 37 -->

# Multiple Linear Regression Estimation

<!-- page 38 -->

# OLS Estimation for Multiple Regression Model

$$
\text{OLS minimizes } \sum_{i=1}^n \epsilon_i^2 = \sum_{i=1}^n (Y_i - \beta_0 - \beta_1 X_i)^2
$$

$$
\Leftrightarrow \boldsymbol{\epsilon}^T \boldsymbol{\epsilon} = (\boldsymbol{Y} - \boldsymbol{X}\boldsymbol{\beta})^T(\boldsymbol{Y} - \boldsymbol{X}\boldsymbol{\beta}) \ (\because \boldsymbol{Y} = \boldsymbol{X}\boldsymbol{\beta} + \boldsymbol{\epsilon})
$$

Remember that for simple linear regression:

$$
\text{OLS minimizes } \boldsymbol{\epsilon}^T \boldsymbol{\epsilon} = (\boldsymbol{Y} - \boldsymbol{X}\boldsymbol{\beta})^T(\boldsymbol{Y} - \boldsymbol{X}\boldsymbol{\beta})
$$

We find $\hat{\boldsymbol{\beta}}$ that satisfies $\boldsymbol{X}^T\boldsymbol{X}\hat{\boldsymbol{\beta}} = \boldsymbol{X}^T\boldsymbol{Y}$

$$
\Rightarrow \hat{\boldsymbol{\beta}} = (\boldsymbol{X}^T\boldsymbol{X})^{-1}\boldsymbol{X}^T\boldsymbol{Y}
$$

<!-- page 39 -->

# Interpretation of Regression Coefficients

<!-- page 40 -->

# Interpretation of $\beta_j, j = 1, \dots, p$

**<u>Interpretation 1:</u>** Marginal effect of a unit change in the $j^{th}$ predictor variable on the outcome variable while keeping other predictor variables constant.

**<u>Interpretation 2:</u>** Marginal effect of a unit change in the jth predictor variable on the outcome variable after removing the effect of all other predictor variables from the jth predictor variable.

**<u>Interpretation 3:</u>** Marginal effect of a unit change in the jth predictor variable on the outcome variable after removing the effect of all other predictor variables from both the jth predictor variable and the outcome variable.

<!-- page 41 -->

# Interpretation of $\beta_j, j = 1, \dots, p$

**<u>Interpretation 1:</u>** Marginal effect of a unit change in the $j^{th}$ predictor variable on the outcome variable while keeping other predictor variables constant.

**<u>Interpretation 2:</u>** Marginal effect of a unit change in the jth predictor variable on the outcome variable after removing the effect of all other predictor variables from the jth predictor variable.

**<u>Interpretation 3:</u>** Marginal effect of a unit change in the jth predictor variable on the outcome variable after removing the effect of all other predictor variables from both the jth predictor variable and the outcome variable.

<!-- page 42 -->

# Interpretation of $\beta_j, j = 1, \dots, p$

**Interpretation 1:** Marginal effect of a unit change in the $j^{th}$ predictor variable on the outcome ... stant.

> Put another way – With a numeric predictor it can be interpreted just as in a simple linear regression model and adding the statement “while holding other predictors constant”.

**Interpretatio** ... r variable on the outcon ... tor variables fron ...

**Interpretation 3:** Marginal effect of a unit change in the jth predictor variable on the outcome variable after removing the effect of all other predictor variables from both the jth predictor variable and the outcome variable.

<!-- page 43 -->

# Inference about Regression Coefficients

<!-- page 44 -->

# Testing Predictors - 1

* How do we test predictors?

e.g., $H_0: \beta_1 = 0$

* How about a subset of predictors?

e.g., $H_0: \beta_1 = \beta_2 = 0$

* How about whether the effect of two predictors is the same?

e.g., $H_0: \beta_1 = \beta_2$

* How about a preset effect?

e.g., $H_0: \beta_1 = 2$

#2-4 in “Class5_Lab.rmd”

<!-- page 45 -->

# Testing Predictors - 2

Property 6 - $\hat{\beta} \sim N_p(\sigma^2(X^T X)^{-1})$

* Each $\hat{\beta}_j$ follows a normal distribution

**<u>For a single parameter,</u>** $\beta_j$:

* Studentized t-tests with: $t = \frac{\hat{\beta}_j}{SE(\hat{\beta}_j)}$
* Test $H_0: \beta_j = 0$
* $100(1 - \alpha)$ confidence interval of $\beta: \hat{\beta}_j \pm t_{n-p}^{\frac{\alpha}{2}} SE(\hat{\beta}_j)$

<!-- page 46 -->

# Testing predictors - 3

For multiple parameters, $\beta$:

* Test $H_0: \beta_1 = \beta_2 = \cdots = \beta_p = 0$ and each $\beta_j = 0$

<!-- page 47 -->

# Bootstrap Confidence Intervals

Without **<u>Assumption 5</u>**. $\epsilon_i \sim N(0, \sigma^2) \text{ for } i = 1, \dots, n$

**<u>Bootstrap</u>**:

* Generate $\epsilon^*$ from $\hat{\epsilon}_1, \dots, \hat{\epsilon}_n$
* Generate $y^* = X\hat{\beta} + \epsilon^*$
* Estimate $\hat{\beta}^*$ by modeling $y^*$ on $X$
* Repeat and observe $\hat{\beta}^*$

**\*We will come back to this in Class 14**

<!-- page 48 -->

# Analysis of Variance in Linear Regression

<!-- page 49 -->

# Analysis of Variance Table

| Source | DF | Sum of Sq | Mean Sq | F |
| :--- | :---: | :---: | :---: | :---: |
| $\boldsymbol{X}$ (Model) | $p - 1$ | $SS_{Reg}$ | $MS_{Reg} = SS_{Reg} / (p - 1)$ | $MS_{Reg} / MSE$ |
| Error | $n - p$ | $RSS$ | $MSE = RSS / (n - p)$ | |
| Total | $n - 1$ | $SS_Y$ | | |

* $SS_Y = \sum(Y_i - \bar{Y})^2 = \sum(Y_i - \hat{Y}_i + \hat{Y}_i - \bar{Y})^2 = RSS + SS_{Reg} \rightarrow SS_Y \geq RSS$
* $RSS = \sum_{i=1}^n \hat{\epsilon}_i^2 = \sum(Y_i - \hat{Y}_i)^2 = SS_{YY} - SS_{Reg}$
* $SS_{Reg} = \sum(\hat{Y}_i - \bar{Y})^2 = SS_Y - RSS$
* $MSE = \hat{\sigma}^2 = \frac{(n - 1)s_{\hat{\epsilon}}^2}{(n - p)} : \quad E(MSE) = \sigma^2 \quad \text{due to } \epsilon_i \sim N(0, \sigma^2)$
* $F = \frac{(SS_Y - RSS) / (p - 1)}{RSS / (n - p)} = \frac{MS_{Reg}}{MSE} \sim F_{n-p}^{p-1}$
  $\rightarrow$ We can test $H_0$: $\beta_0 = \beta_1 = ... = \beta_p = 0$ with $F$

<!-- page 50 -->

# Model Comparison

<!-- page 51 -->

# General $F$ Test

* The more predictors in a model, the better the model “explains” the outcome variable in the data (unless $Y \perp\!\!\!\perp X$ )
* However, **we want parsimony** in model
* How do we know which model is better? $\rightarrow$ General $F$ Test

Consider a full model with $p$ predictors (including an intercept) and a reduced model with $q$ predictors.

$$
\begin{aligned}
F &= \frac{(RSS_{Reduced} - RSS_{Full}) / (df_{Reduced} - df_{Full})}{RSS_{Full} / df_{Full}} \\
&= \frac{(RSS_{Reduced} - RSS_{Full}) / (p - q)}{RSS_{Full} / (n - p)} \sim F_{n-p}^{p-q}
\end{aligned}
$$

$$
\rightarrow \text{We can test } H_0 : RSS_{Reduced} = RSS_{Full} \text{ with } F
$$

<!-- page 52 -->

# Goodness of Model Fit

<!-- page 53 -->

# Model Fit

Which of the 3 lines explains the pattern in Income the best?

<!-- page 54 -->

# $R^2$ - 1

* $R^2 = \frac{SS_{Reg}}{SS_Y} = \frac{SS_Y - RSS}{SS_Y} 1 - \frac{RSS}{SS_Y}$

* $0 < R^2 < 1$

* $F = \frac{SS_Y - RSS}{RSS} \frac{n-p}{p-1} = \frac{R^2}{1-R^2} \frac{n-p}{p-1}$

by using $\frac{SS_Y - RSS}{RSS} = \frac{SS_Y - RSS}{RSS} \frac{1}{RSS / SS_Y} = R^2 \frac{1}{RSS / SS_Y}$ and

$$
\frac{RSS}{SS_Y} = \frac{SS_Y}{SS_Y} + \frac{RSS}{SS_Y} - \frac{SS_Y}{SS_Y} = 1 - \frac{SS_Y - RSS}{SS_Y} = 1 - R^2
$$

* Think about $R^2$ for simple and multiple linear regression: is parsimony considered?

<!-- page 55 -->

# $R^2$ - 2

* Adjusted $R^2 = 1 - \frac{(1-R^2)(n-1)}{(n-p)}$
  * Considers parsimony by accounting for the sample size, $n$, and number of parameters, $p$
  * What does n-p represent?

<!-- page 56 -->

# $R^2$ - 3

* Popular for use as goodness of fit measure
* Be careful for regression through the origin (e.g., model with no intercept) – will not be interpretable in the same way!
* Use $R^2$ in conjunction with the residual distribution (esp. $\hat{\sigma}^2: \text{MSE}$) for assessing model fit

<!-- page 57 -->

# Summing up

* Multiple linear regression provides us a valuable approach to explore relationships while accounting for other variables.
* This combined with prior knowledge and tools like DAGs we can be more intentional about the specific potential effect/relationship we’re trying to model.
* Tools like the general F test, R2, and MSE can be useful in assessing whether one model fits the data better than another, but should be used carefully.
  * On their own, they can’t tell us whether a causal effect exists.
