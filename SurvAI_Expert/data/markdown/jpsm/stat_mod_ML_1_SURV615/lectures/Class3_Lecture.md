---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class3_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class3_Lecture.pdf"
pages: 73
sha256: "86df8a8c19937f5aa33fdb97d805e7ffb9e6bfc64447eb69532c696caf46dcf0"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:24"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #3

John Kubale

September 10, 2024

<!-- page 2 -->

# Outline

- Review

- Statistical Learning
  - E.g., Studying income

- Linear Models

<!-- page 3 -->

# Review – Population vs. Sample Variance

* Population variance: $\sigma^2 = \frac{\sum_{i=1}^{N}(y_i - \mu)^2}{N}$
* Sample variance: $s^2 = \frac{\sum_{i=1}^{n}(y - \hat{\bar{y}})^2}{n - 1}$

<!-- page 4 -->

# Review – Standard Deviation vs. Standard Error

* Population standard deviation: $\sigma = \sqrt{\sigma^2}$
* Population standard deviation: $s = \sqrt{s^2}$
* Standard error: $se = \frac{s}{\sqrt{n}}$

<!-- page 5 -->

# Review – hypothesis testing

* We are often interested in comparing quantities in 2 populations to assess for potential differences (or one population against some known quantity)
* These are generally samples which means there is a certain amount of variability.
  * So, how do we know if there are in fact differences? -> hypothesis testing

<!-- page 6 -->

# Review – Hypothesis testing

* Comparing means of 2 groups (x vs. y)
  * Two-sided test - $H_0: \mu_x = \mu_y$, $H_A: \mu_x \neq \mu_y$
  * One-sided test - $H_0: \mu_x \geq \mu_y$, $H_A: \mu_x < \mu_y$
* How do we know whether we can reject the null hypothesis ($H_0$)?
  * Look at our p-value -> if lower than our pre-set alpha value (usually 0.05) then we reject the null
  * How/why does this work?

<!-- page 7 -->

# Review – Hypothesis testing

* See "test_stats.pdf" on Canvas.

<!-- page 8 -->

# Review – Alpha and confidence intervals

* We often set $\alpha = 0.05$, but what does this mean?
  * Corresponds to the probability of seeing a value (e.g., mean) as extreme as the value observed if the null hypothesis is true.
* What about 95% confidence intervals (CI)?
  * If we were to calculate a sample mean repeatedly the range represented by our 95% CI would contain the true population mean 95% of the time.

<!-- page 9 -->

# Review – Test assumptions

* There is generally a trade-off between flexibility and interpretability.
* Some tests are more easily interpretable, but to facilitate this require some assumptions.
    * T-tests: Normality, independence\*, equal errors\*
    * Pearson correlation: Bivariate normality
* If concerned about assumption violation(s) consider using alternatives (e.g., Wilcoxon or Spearman)

<!-- page 10 -->

# Statistical Learning

<!-- page 11 -->

# Y as a function of X

* Y: Outcome, output, dependent, response variable
* X: Feature, input, independent, explanatory, predictor variable(s)
* Learning about Y as a function of X: $Y = f(X) + \in$

What is $f$?

What can we do with $f$?

*Explain Y with X*

*Predict $\hat{Y}$ for specific instances of X*

What is $\in$?

<!-- page 12 -->

# Statistical Learning - 2

How do we find $f$?

* Larger $P$ -> better $f$
  * *More parameters -> better fit to* ***data***
* Parametric vs. Non-parametric:
  * Model Interpretability vs. Flexibility

(JWHT Figure 2.7)

<!-- page 13 -->

# Example: Studying Income

<!-- page 14 -->

# One Predictor

$$
Income = f(Educ) + \epsilon
$$

(JWHT Figure 2.2)

<!-- page 15 -->

# Two Predictors - 1

$$
Income = f(Educ, Seniority) + \epsilon
$$

(JWHT Figure 2.3 - True $f$)

<!-- page 16 -->

# Two Predictors - 2

$$Income = f(Educ, Seniority) + \epsilon$$

(JWHT Figure 2.4, 2.5, 2.6 - Estimated $f$)

Which of the 3 figures represents the **<u>most interpretable</u>** modeling approach?
Which represents the **<u>most flexible</u>** approach?
Which would you choose? Why?

<!-- page 17 -->

# Linear Models

<!-- page 18 -->

# Linear Regression

* Linear regression models are one common approach for modeling $y$ as a function of $x$.

$$Y = \beta_0 + \beta_1 + \epsilon$$

<!-- page 19 -->

# Linear regression with no predictors

* Using the income2 data we’re going to start with the simplest linear regression model – the intercept only model (i.e., no predictors)
  * $E(Income) = \beta_0 + \epsilon$
* Often written as:
  * $E(Income) = \bar{Y} + \epsilon$

What is your best guess about

where the regression

line will be?

<!-- page 20 -->

# Linear regression with no predictors

- Let's look at what what this looks like graphically.
- What does the dotted line ($\beta_0$) represent?

<!-- page 21 -->

# Linear regression with no predictors

* Let's look at what what this looks like graphically.
* What does the dotted line ($\beta_0$) represent?

It's simply the mean of Income.

<!-- page 22 -->

# Linear regression with no predictors

* Let's look at what what this looks like graphically.
* What does the dotted line ($\beta_0$) represent?

It's simply the mean of Income.

Can we do better?

<!-- page 23 -->

# Simple Linear Regression

* Linear regression with one predictor is often referred to as “simple linear regression”.

$$Y_i = \beta_0 + \beta_1 X_i + \epsilon_i$$

Let’s look at income

as a function of age.

<!-- page 24 -->

# Linear regression notation

* Modeling the outcome variable, $Y$
  * With no predictors: $Y_i = \bar{Y} + \epsilon_i$
  * With 1 predictor: $Y_i = \beta_0 + \beta_1 X_{1i} + \epsilon_i$
  * With 2 predictors: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$
  * With 3 predictors: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \beta_3 X_{3i} + \epsilon_i$
  * Etc.
* As long as $f(X)$ is **<u>a linear combination</u>** of $X$ then it's a Linear Model
  * Linear models can be used to study non-linear relationships so long as predictors form a linear combination

<!-- page 25 -->

# Linear regression notation

* Modeling the outcome variable, $Y$
  * With no predictors: $Y_i = \bar{Y} + \epsilon_i$
  * With 1 predictor: $Y_i = \beta_0 + \beta_1 X_{1i} + \epsilon_i$
  * With 2 predict What does this look like in R?
  * With 3 predictors: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \beta_3 X_{3i} + \epsilon_i$
  * Etc.
* As long as $f(X)$ is **<u>a linear combination</u>** of $X$ then it’s a Linear Model
  * Linear models can be used to study non-linear relationships so long as predictors form a linear combination

<!-- page 26 -->

# Linear Models - 4

* Modeling the outcome variable, $Y$
  * With no predictors: $Y_i = \bar{Y} + \epsilon_i$
    ```r
    model_obj <- lm(y ~ 1, data)
    ```
  * With 1 predictor: $Y_i = \beta_0 + \beta_1 X_{1i} + \epsilon_i$
    ```r
    model_obj <- lm(y ~ var1, data)
    ```
  * With 2 predictors: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$
    ```r
    model_obj <- lm(y ~ var1 + var2, data)
    ```
  * With 3 predictors: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \beta_3 X_{3i} + \epsilon_i$
    ```r
    model_obj <- lm(y ~ var1 + var2 + var3, data)
    ```

<!-- page 27 -->

# From data to model

How does our dataset fit into a linear regression model?

| $Y$ (Income) | $X_1$ (Education) | $X_2$ (Senority) |
| :---: | :---: | :---: |
| $99.917$ | $21.586$ | $113.103$ |
| $92.579$ | $18.276$ | $119.310$ |
| $34.679$ | $12.069$ | $100.690$ |
| $\vdots$ | $\vdots$ | $\vdots$ |
| $74.611$ | $17.034$ | $106.897$ |

$$
\begin{pmatrix}
99.917 \\
92.579 \\
34.679 \\
\vdots \\
74.611
\end{pmatrix}
= \beta_0 + \beta_1 \times
\begin{pmatrix}
21.586 \\
18.276 \\
12.069 \\
\vdots \\
17.034
\end{pmatrix}
+ \beta_2 \times
\begin{pmatrix}
113.103 \\
119.310 \\
100.690 \\
\vdots \\
106.897
\end{pmatrix}
+
\begin{pmatrix}
\epsilon_1 \\
\epsilon_2 \\
\epsilon_3 \\
\vdots \\
\epsilon_N
\end{pmatrix}
$$

<!-- page 28 -->

# More notation!

$$
\begin{pmatrix} 99.917 \\ 92.579 \\ 34.679 \\ \vdots \\ 74.611 \end{pmatrix} = \beta_0 + \beta_1 \times \begin{pmatrix} 21.586 \\ 18.276 \\ 12.069 \\ \vdots \\ 17.034 \end{pmatrix} + \beta_2 \times \begin{pmatrix} 113.103 \\ 119.310 \\ 100.690 \\ \vdots \\ 106.897 \end{pmatrix} + \begin{pmatrix} \epsilon_1 \\ \epsilon_2 \\ \epsilon_3 \\ \vdots \\ \epsilon_N \end{pmatrix}
$$

$$
\begin{pmatrix} Y_1 \\ Y_2 \\ Y_3 \\ \vdots \\ Y_N \end{pmatrix} = \beta_0 + \beta_1 \times \begin{pmatrix} X_{11} \\ X_{12} \\ X_{13} \\ \vdots \\ X_{14} \end{pmatrix} + \beta_2 \times \begin{pmatrix} X_{21} \\ X_{22} \\ X_{23} \\ \vdots \\ X_{24} \end{pmatrix} + \begin{pmatrix} \epsilon_1 \\ \epsilon_2 \\ \epsilon_3 \\ \vdots \\ \epsilon_N \end{pmatrix}
$$

$$
Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{1i} + \epsilon_i
$$

$$
\boldsymbol{Y} = \beta_0 + \beta_1 \boldsymbol{X}_1 + \beta_2 \boldsymbol{X}_2 + \boldsymbol{\epsilon}
$$

$$
\boldsymbol{Y} = \boldsymbol{X\beta} + \boldsymbol{\epsilon}
$$

<!-- page 29 -->

# More notation!

$$
\begin{pmatrix} 99.917 \\ 92.579 \\ 34.679 \\ \vdots \\ 74.611 \end{pmatrix} = \beta_0 + \beta_1 \times \begin{pmatrix} 21.586 \\ 18.276 \\ 12.069 \\ \vdots \\ 19.373 \end{pmatrix} + \beta_2 \times \begin{pmatrix} 113.103 \\ 119.310 \\ 100.690 \\ \vdots \\ 126.742 \end{pmatrix} + \begin{pmatrix} \epsilon_1 \\ \epsilon_2 \\ \epsilon_3 \\ \vdots \\ \epsilon_N \end{pmatrix}
$$

$$
\boldsymbol{X} = \begin{pmatrix} X_{11} & X_{12} & \cdots & X_{1P} \\ X_{21} & X_{22} & \cdots & X_{2P} \\ & & \vdots & \\ X_{N1} & X_{N2} & \cdots & X_{NP} \end{pmatrix} = (\boldsymbol{X}_1 \ \boldsymbol{X}_2 \cdots \boldsymbol{X}_P) = \begin{pmatrix} \boldsymbol{X}_1 \\ \boldsymbol{X}_2 \\ \vdots \\ \boldsymbol{X}_N \end{pmatrix}
$$

$$
\begin{pmatrix} Y_1 \\ Y_2 \\ Y_3 \\ \vdots \\ Y_N \end{pmatrix} = \beta_0 + \beta_1 \times \begin{pmatrix} X_{11} \\ X_{12} \\ X_{13} \\ \vdots \\ X_{14} \end{pmatrix} + \beta_2 \times \begin{pmatrix} X_{21} \\ X_{22} \\ X_{23} \\ \vdots \\ X_{24} \end{pmatrix} + \begin{pmatrix} \epsilon_1 \\ \epsilon_2 \\ \epsilon_3 \\ \vdots \\ \epsilon_N \end{pmatrix}
$$

$$
Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{1i} + \epsilon_i
$$

$$
\boldsymbol{Y} = \beta_0 + \beta_1 \boldsymbol{X}_1 + \beta_2 \boldsymbol{X}_2 + \boldsymbol{\epsilon}
$$

$$
\boldsymbol{Y} = \boldsymbol{X}\boldsymbol{\beta} + \boldsymbol{\epsilon}
$$

<!-- page 30 -->

# Notation review

Given the model: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$

* Can also be written in matrix form as: $Y = X\beta + \epsilon$

What do we know?

What do we **not** know?

<!-- page 31 -->

# Notation review

Given the model: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$

* Can also be written in matrix form as: $Y = X\beta + \epsilon$

What do we know?

* We know our data ($Y_i$ and $X_i$)

What do we **not** know?

<!-- page 32 -->

# Notation review

Given the model: $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$

* Can also be written in matrix form as: $Y = X\beta + \epsilon$

What do we know?

* We know our data ($Y_i$ and $X_i$)

What do we **not** know?

* $\beta_0$, $\beta_1$, $\beta_2$ -- These are our parameters
* We also don't know $\epsilon$, but that's not considered a parameter

<!-- page 33 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What does $\beta_0$ mean?

<!-- page 34 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What does $\beta_0$ mean?
  * $\beta_0$ is the intercept, the expected value of the outcome, $Y$, when $X = 0$.
* Do we need $\beta_0$?

<!-- page 35 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What does $\beta_0$ mean?
* $\beta_0$ is the intercept, the expected value of the outcome, $Y$, when $X = 0$.
* Do we need $\beta_0$?
  * Only in rare circumstances can you reasonably remove $\beta_0$ from the model.

<!-- page 36 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What about $\beta_1$ and $\beta_2$? What do they represent?

<!-- page 37 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What about $\beta_1$ and $\beta_2$? What do they represent?
  * $\beta_1$ and $\beta_2$ represent the slope or the expected mean change in the outcome, $Y$, for every one unit increase of its respective $X$ while holding the other constant
* Do we need $\beta_1$ and $\beta_2$?

<!-- page 38 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What about $\beta_1$ and $\beta_2$? What do they represent?
  * $\beta_1$ and $\beta_2$ represent the slope or the expected mean change in the outcome, $Y$, for every one unit increase of its respective $X$ while holding the other constant
* Do we need $\beta_1$ and $\beta_2$?
  * This depends entirely on the research question(s) and purpose.
  * We'll talk more about this in Class 5!

<!-- page 39 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What does $\epsilon$ represent?
  * $\epsilon$ represents the error term also known as the residual $(y_i - \hat{y}_i)$
* Do we need it?

<!-- page 40 -->

# Decomposing the linear model

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$$

$$Y = X\beta + \epsilon$$

* What does $\epsilon$ represent?
  * $\epsilon$ represents the error term also known as the residual $(y_i - \hat{y}_i)$
* Do we need it?
  * Yes! $\epsilon$ plays a vital role in regression models as we will see throughout the semester.

<!-- page 41 -->

# Interpreting regression coefficients

<!-- page 42 -->

# Interpreting linear regression coefficients

* Let's fit a model using the income2 data where we model income as a function of education
* We can fit this in R as:

```r
model1 <- lm(Income ~ Education, income2)
```

<!-- page 43 -->

# Interpreting linear regression coefficients

```r
summary(lm(Income ~ Education, income2))
```

```
Call:
lm(formula = Income ~ Education, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

<!-- page 44 -->

# Interpreting linear regression coefficients

```r
Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The coefficient for Education is 6.4.

How would you interpret this?

<!-- page 45 -->

# Interpreting linear regression coefficients

```r
Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The coefficient for Education is 6.4.

How would you interpret this?

* For every one-unit increase in education we expect the mean income to increase by 6.4.

<!-- page 46 -->

# Interpreting linear regression coefficients

```r
Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The coefficient for the Intercept is -41.9.

How would you interpret this?

<!-- page 47 -->

# Interpreting linear regression coefficients

```r
Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The coefficient for the Intercept is -41.9.

How would you interpret this?
* The expected income for those where $\text{Education} = 0$ is -41.9.

Does this make sense?

<!-- page 48 -->

# How can we make the intercept more interpretable?

<!-- page 49 -->

# Interpretable intercept via centering

* Centering a numeric variable simply means that we subtract the mean of that variable from each observed value.
* We can create a new centered education variable and refit the model like below.

```r
income2$edu_cen <- income2$Education - mean(income2$Education)
summary(lm(Income ~ edu_cen, income2))
```

```
Call:
lm(formula = Income ~ edu_cen, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  62.7447     2.1774   28.82  < 2e-16 ***
edu_cen       6.3872     0.5812   10.99 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

<!-- page 50 -->

# Interpretable intercept via centering

* How would we interpret the intercept in each model?
* What about the slope?

### Uncentered

```r
Call:
lm(formula = Income ~ Education, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

### Centered

```r
Call:
lm(formula = Income ~ edu_cen, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  62.7447     2.1774   28.82  < 2e-16 ***
edu_cen       6.3872     0.5812   10.99 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

<!-- page 51 -->

# Interpretable intercept via centering

* How would we interpret the intercept in each model?
  * Hint: The intercept represents $Y$ when the $\text{predictor} = 0$. When does $\text{edu\_cen} = 0$?
* What about the slope?

### Uncentered

```r
Call:
lm(formula = Income ~ Education, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

### Centered

```r
Call:
lm(formula = Income ~ edu_cen, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  62.7447     2.1774   28.82  < 2e-16 ***
edu_cen       6.3872     0.5812   10.99 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

<!-- page 52 -->

# Interpretable intercept via centering

* How would we interpret the intercept in each model?
  * Hint: The intercept represents $Y$ when the $\text{predictor} = 0$. When does $\text{edu\_cen} = 0$?
* What about the slope?

The expected income for those where $\text{Education} = 0$ is -41.9.

**Uncentered**

```r
lm(formula = Income ~ Education, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

The expected income for those with mean level of Education is 62.7

**Centered**

```r
lm(formula = Income ~ edu_cen, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  62.7447     2.1774   28.82  < 2e-16 ***
edu_cen       6.3872     0.5812   10.99 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

<!-- page 53 -->

# Interpretable intercept via centering

* How would we interpret the intercept in each model?
    * Hint: The intercept represents $Y$ when the $\text{predictor} = 0$. When does $\text{edu\_cen} = 0$?
* What about the slope?

For every one-unit increase in education we expect the mean income to increase by 6.4.

### Uncentered

```r
Call:
lm(formula = Income ~ Education, data = in

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) -41.9166     9.7689  -4.291 0.000192 ***
Education     6.3872     0.5812  10.990 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

### Centered

```r
a = Income ~ edu_cen, data = income2)

Residuals:
    Min      1Q  Median      3Q     Max 
-19.568  -8.012   1.474   5.754  23.701 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  62.7447     2.1774   28.82  < 2e-16 ***
edu_cen       6.3872     0.5812   10.99 1.15e-11 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 11.93 on 28 degrees of freedom
Multiple R-squared:  0.8118,	Adjusted R-squared:  0.8051 
F-statistic: 120.8 on 1 and 28 DF,  p-value: 1.151e-11
```

<!-- page 54 -->

# Interpretable intercept via centering

Let's look at another example, this time graphically, to see what centering does.

* We'll fit a mode exploring weekly wages as a function of age using the Wage dataset from the ISLR2 package.
  * $E(wage) = \beta_0 + \beta_1(age) + \epsilon$
* How would you interpret the coefficients in the output below?

```r
Call:
lm(formula = wage ~ age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.265 -25.115  -6.063  16.601 205.748 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 81.70474    2.84624   28.71   <2e-16 ***
age          0.70728    0.06475   10.92   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 40.93 on 2998 degrees of freedom
Multiple R-squared:  0.03827,	Adjusted R-squared:  0.03795 
F-statistic: 119.3 on 1 and 2998 DF,  p-value: < 2.2e-16
```

<!-- page 55 -->

# Interpretable intercept via centering

Let's look at another example, this time graphically, to see what centering does.

* We'll fit a mode exploring weekly wages as a function of age using the Wage dataset from the ISLR2 package.
  * $E(wage) = \beta_0 + \beta_1(age) + \epsilon$
* How would you interpret the coefficients in the output below?

```r
Call:
lm(formula = wage ~ age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.265 -25.115  -6.063  16.601 205.748 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 81.70474    2.84624   28.71   <2e-16 ***
age          0.70728    0.06475   10.92   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 40.93 on 2998 degrees of freedom
Multiple R-squared:  0.03827,	Adjusted R-squared:  0.03795 
F-statistic: 119.3 on 1 and 2998 DF,  p-value: < 2.2e-16
```

Mean weekly wage for those where $\text{age} = 0$ is 81.7.

Every one-unit increase in age is associated with an increase in the mean expected wage of 0.71.

<!-- page 56 -->

# Interpretable intercept via centering

Let's look at another example, this time graphically, to see what centering does.

* We'll fit a mode exploring weekly wages as a function of age using the Wage dataset from the ISLR2 package.
  * $E(wage) = \beta_0 + \beta_1(age) + \epsilon$
* How would you interpret the coefficients in the output below?

```r
Call:
lm(formula = wage ~ age, data = Wage)

Residuals:
    Min      1Q
-100.265  -25.115

Coefficients:
            Estim
(Intercept) 81.70474   2.84624   28.71   <2e-16 ***
age          0.70728   0.06475   10.92   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 40.93 on 2998 degrees of freedom
Multiple R-squared:  0.03827,	Adjusted R-squared:  0.03795 
F-statistic: 119.3 on 1 and 2998 DF,  p-value: < 2.2e-16
```

Do these interpretations make sense?

Mean weekly wage for those where age = 0 is 81.7.

Every one-unit increase in age is associated with an increase in the mean expected wage of 0.71.

<!-- page 57 -->

# Interpretable intercept via centering

Let's look at this model graphically.

- The red line is the regression line, the blue points are the observed data, and the dashed black vertical line represents the model intercept.

<!-- page 58 -->

# Interpretable intercept via centering

Let’s look at this model graphically.

* The red line is the regression line, the blue points are the observed data, and the dashed black vertical line represents the model intercept.

See any potential problems?

<!-- page 59 -->

# Interpretable intercept via centering

Let's look at this model graphically.

* The red line is the regressio
  line, the blue points are the
  observed data, and the das
  black vertical line represen
  model intercept.

See any potential problems?

What do you think will happen if we center age and refit the model?

<!-- page 60 -->

# Interpretable intercept via centering

Let’s look at a model where age is centered.

What does the intercept represent here?

Is the slope of the regression line different than the uncentered model?

<!-- page 61 -->

# Interpretable intercept via centering

* Can help make intercept more interpretable.
* Doesn't change interpretation of the slope!
  * You're just shifting along the x-axis.

<!-- page 62 -->

# Population vs. Sample

Today we’ve been treating our data as if they represent the entire population rather than just a sample. This has implications for both the estimates themselves and their notation.
* $\beta_0, \beta_1, \dots, \beta_n \text{ and } V(\beta_0), V(\beta_1), \dots, V(\beta_n)$
* $\hat{\beta}_0, \hat{\beta}_1, \dots, \hat{\beta}_n \text{ and } V(\hat{\beta}_0), V(\hat{\beta}_1), \dots, V(\hat{\beta}_n)$

<!-- page 63 -->

# Goal of linear regression model estimation

* Which fit line (red or black) regression lines, do you think does a better job of modeling the relationship between `income` and in these data? `education`

<!-- page 64 -->

# Goal of linear regression model estimation

- The choice in the income and education example was pretty clear, but often it isn't.
- Need a standardized way of finding the regression line that best fits the data
- Our goal is to find unique solutions to $\beta_0, \beta_1, \dots, \beta_n$ that will make $\beta_0 + \beta_1 + \dots + \beta_n$ (i.e., $X\beta$) as close to $Y$ as possible.
  - Put another way – we want to find the smallest $\epsilon$.

We'll discuss how we do this next class!

<!-- page 65 -->

# Goal of Linear Regression Model Estimation-2

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

$$Y = X\beta + \epsilon$$

* Finding unique solutions to $\beta_0$, $\beta_1$, $\beta_2$ (i.e., $\beta$) that will make $\beta_0 + \beta_1 X_1 + \beta_2 X_2$ (i.e., $X\beta$) as close to $Y$ as possible.
  * Put another way – want to find smallest $\epsilon$ with respect to its mean and variance

Next class!

<!-- page 66 -->

# Common statistical tests are linear models in trench coats

<!-- page 67 -->

# Statistical tests as linear models

* Showing equivalent linear models
  * One sample t-test
  * Wilcoxon signed-rank

Many more examples in nice post below:

* Pearson correlation, two-sample tests, and many we didn’t cover
* [https://lindeloev.github.io/tests-as-linear/](https://lindeloev.github.io/tests-as-linear/)

<!-- page 68 -->

# Statistical tests as linear models

* One sample t-test

```r
# One sample t test
set.seed(894894)
y <- rnorm(50, 5,1)
t.test(y)
summary(lm(y ~ 1))
```

```
	One Sample t-test

data:  y
t = 37.294, df = 49, p-value < 2.2e-16
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 4.803264 5.350396
sample estimates:
mean of x 
  5.07683 
```

```
Call:
lm(formula = y ~ 1)

Residuals:
     Min       1Q   Median       3Q      Max 
-3.12402 -0.50299  0.06809  0.50362  2.02659 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)   5.0768     0.1361   37.29   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.9626 on 49 degrees of freedom
```

<!-- page 69 -->

# Statistical tests as linear models

* One sample t-test

```r
# One sample t test
set.seed(894894)
y <- rnorm(50, 5,1)
t.test(y)
summary(lm(y ~ 1))
```

```r
	One Sample t-test

data:  y
t = 37.294, df = 49, p-value < 2.2e-16
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 4.803264 5.350396
sample estimates:
mean of x 
  5.07683
```

```r
Call:
lm(formula = y ~ 1)

Residuals:
    Min      1Q  Median      3Q     Max 
-3.12402 -0.50299  0.06809  0.50362  2.02659 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)   5.0768     0.1361   37.29   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.9626 on 49 degrees of freedom
```

<!-- page 70 -->

# Statistical tests as linear models

* One sample t-test

```r
# One sample t test
set.seed(894894)
y <- rnorm(50, 5,1)
t.test(y)
summary(lm(y ~ 1))
```

```r
	One Sample t-test

data:  y
t = 37.294, df = 49, p-value < 2.2e-16
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 4.803264 5.350396
sample estimates:
mean of x 
  5.07683
```

```r
Call:
lm(formula = y ~ 1)

Residuals:
     Min       1Q   Median       3Q      Max 
-3.12402 -0.50299  0.06809  0.50362  2.02659 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)   5.0768     0.1361   37.29   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.9626 on 49 degrees of freedom
```

<!-- page 71 -->

# Statistical tests as linear models

* Wilcoxon signed-rank

```r
# Wilcoxon signed rank test
signed_rank = function(x) sign(x) * rank(abs(x))

set.seed(894894)
y = c(rnorm(15), exp(rnorm(15)), runif(20, min = -3, max = 0))
wilcox.test(y)
summary(lm(signed_rank(y) ~ 1))
t.test(signed_rank(y))
```

```r
        Wilcoxon signed rank test with continuity correction

data:  y
V = 1091, p-value = 0.3769
alternative hypothesis: true location is not equal to 0
```

```r
Call:
lm(formula = signed_rank(y) ~ 1)

Residuals:
    Min      1Q  Median      3Q     Max 
-61.671 -32.421  -5.171  33.829  74.329 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)   -4.329      4.890  -0.885    0.379

Residual standard error: 40.91 on 69 degrees of freedom
```

```r
        One Sample t-test

data:  signed_rank(y)
t = -0.88523, df = 69, p-value = 0.3791
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 -14.083348   5.426205
sample estimates:
mean of x 
-4.328571 
```

<!-- page 72 -->

# Statistical tests as linear models

* Wilcoxon signed-rank

```r
# Wilcoxon signed rank test
signed_rank = function(x) sign(x) * rank(abs(x))

set.seed(894894)
y = c(rnorm(15), exp(rnorm(15)), runif(20, min = -3, max = 0))
wilcox.test(y)
summary(lm(signed_rank(y) ~ 1))
t.test(signed_rank(y))
```

```r
	Wilcoxon signed rank test with continuity correction

data:  y
V = 1091, p-value = 0.3769
alternative hypothesis: true location is not equal to 0
```

```r
Call:
lm(formula = signed_rank(y) ~ 1)

Residuals:
    Min      1Q  Median      3Q     Max 
-61.671 -32.421  -5.171  33.829  74.329 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)   -4.329      4.890  -0.885    0.379

Residual standard error: 40.91 on 69 degrees of freedom
```

```r
	One Sample t-test

data:  signed_rank(y)
t = -0.88523, df = 69, p-value = 0.3791
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 -14.083348   5.426205
sample estimates:
mean of x 
-4.328571 
```

<!-- page 73 -->

# Statistical tests as linear models

* Wilcoxon signed-rank

```r
# Wilcoxon signed rank test
signed_rank = function(x) sign(x) * rank(abs(x))

set.seed(894894)
y = c(rnorm(15), exp(rnorm(15)), runif(20, min = -3, max = 0))
wilcox.test(y)
summary(lm(signed_rank(y) ~ 1))
t.test(signed_rank(y))
```

```r
	Wilcoxon signed rank test with continuity correction

data:  y
V = 1091, p-value = 0.3769
alternative hypothesis: true location is not equal to 0
```

```r
Call:
lm(formula = signed_rank(y) ~ 1)

Residuals:
    Min      1Q  Median      3Q     Max 
-61.671 -32.421  -5.171  33.829  74.329 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)   -4.329      4.890  -0.885    0.379

Residual standard error: 40.91 on 69 degrees of freedom
```

```r
	One Sample t-test

data:  signed_rank(y)
t = -0.88523, df = 69, p-value = 0.3791
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 -14.083348   5.426205
sample estimates:
mean of x 
-4.328571 
```
