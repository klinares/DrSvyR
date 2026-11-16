---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/Logistic_slides-1"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "Lecture 4. Logistic Regression"
original: "stat_mod_ML_2_SURV616/lectures/Logistic slides-1.pdf"
pages: 68
sha256: "56be0edb8c24ef35bb5284479ff5dbdd39df31c7e24cd72f4f58799094fcd8da"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:31"
---

<!-- page 1 -->

# Lecture 4. Logistic Regression

James Wagner

January 2023

<!-- page 2 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Overview

1. Logistic Regression

2. Interpretation of Coefficients

3. Inference

2/68

James Wagner

Class 4

<!-- page 3 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 1: O-rings on the Space Shuttle

- O-rings fail at higher rates in colder temperatures
- There are 6 O-rings on each shuttle
- There were 23 missions prior to Challenger
- Could the Challenger explosion have been predicted?

3 / 68 $\qquad$ James Wagner $\qquad$ Class 4

<!-- page 4 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 1: O-rings on the Space Shuttle

First, plot the failure rates by temperature:

Probability of Damage
1.00
0.75
0.50
0.25
0.00
20
40
60
80
Temperature

4 / 68
James Wagner
Class 4

<!-- page 5 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 1: O-rings on the Space Shuttle

It looks like there might be a relationship. Let's regress failure rate on temperature. Here's the resulting regression line:

Prob of Damage
1.0
0.8
0.6
0.4
0.2
0.0

30 40 50 60 70 80
Temperature

5 / 68

James Wagner

Class 4

*[Figure: The image shows a line plot of a linear regression model with "Temperature" (ranging from 30 to 80) on the x-axis and "Prob of Damage" (ranging from 0.0 to 1.0) on the y-axis. It displays a single straight line for the dataset, illustrating a strong negative linear relationship where the predicted probability of damage steadily decreases from above 0.8 at low temperatures to below 0.0 around a temperature of 77.]*

<!-- page 6 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Linear Model and Binary Outcome

In some cases, the linear model might not produce a bad fit, but there are some issues.

1. Linear regression assumes residuals are normally distributed.
2. Linear regression also assumes constant variance.
3. Linear model can produce predicted values outside the restricted range of a probability $(0, 1)$.

Violations of assumptions mean linear model won't always/usually be appropriate.

6 / 68

James Wagner

Class 4

<!-- page 7 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Linear Model and Binary Outcome

Assume that residuals are normally distributed. These are the residuals from a linear model $\textit{DAMAGE} = \beta_0 + \beta_1 \times \textit{TEMP}$:

7/68

James Wagner

Class 4

<!-- page 8 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Linear Model and Binary Outcome

Recall the binomial distribution:

$$
P(Y_i = y_i) = \frac{n_i!}{y_i!(n_i - y_i)!} p_i^{y_i}(1 - p_i)^{n_i - y_i} \tag{1}
$$

This distribution has mean $n_i p_i$ and variance $n_i p_i(1 - p_i)$. The mean and the variance are linked in this case – nonconstant. Violation of second assumption.

8 / 68
James Wagner
Class 4

<!-- page 9 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Linear Model and Binary Outcome

Let's say we also have $q$ predictors $(x_{i1}, \ldots, x_{iq})$. We want to use these to predict $p_i$.

For the reasons described earlier, that may not work.

### Question:
Is it possible to define a function, $g(p_i)$ for which the linear regression model will work?

9 / 68
James Wagner
Class 4

<!-- page 10 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

This is the basic idea behind logistic regression (and many methods under the heading of generalized linear models [GLMs]).

We need some function $\eta_i = g(p_i)$ such that $\eta_i$ can be predicted in a linear model.

It must also satisfy $0 \le g^{-1}(\eta) \le 1$.

The most common function is called the logit function: $\eta = log\left(\frac{p}{1-p}\right)$.

10 / 68
James Wagner
Class 4

<!-- page 11 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

Table: Relationship of Odds and Log-odds to Probabilities

| Probability | Odds | Log-Odds |
| :---: | :---: | :---: |
| 0 | 0 | $-\infty$ |
| 0.1 | 0.111 | -2.197 |
| 0.2 | 0.25 | -1.386 |
| 0.3 | 0.429 | -0.847 |
| 0.4 | 0.667 | -0.405 |
| 0.5 | 1 | 0 |
| 0.6 | 1.5 | 0.405 |
| 0.7 | 2.333 | 0.847 |
| 0.8 | 4 | 1.386 |
| 0.9 | 9 | 2.197 |
| 1 | $\infty$ | $\infty$ |

11 / 68

James Wagner

Class 4

<!-- page 12 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

Logistic regression fits the following model:

$$\eta = \beta_0 + \beta_1 x_{i1} + \dots + \beta_q x_{iq}$$

$$\log\left(\frac{p}{1 - p}\right) = \beta_0 + \beta_1 x_{i1} + \dots + \beta_q x_{iq}$$

$$\Pr(Y_i = 1) = \text{logit}^{-1} \left(\beta_0 + \beta_1 x_{i1} + \dots + \beta_q x_{iq}\right)$$

$$\Pr(Y_i = 1) = \frac{1}{1 + e^{-\left(\beta_0 + \beta_1 x_{i1} + \dots + \beta_q x_{iq}\right)}}$$

12 / 68
James Wagner
Class 4

<!-- page 13 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

The R code is straightforward. We'll start with the basics and add to this as we go:

```r
logitmod<-glm(damage ~temp, family=binomial,
data=spacshu)
```

13 / 68

James Wagner

Class 4

<!-- page 14 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

If we fit the model $\eta = \beta_0 + \beta_1 x_{i1}$, where $\eta = \log\left(\frac{p}{1-p}\right)$ and $x$ is the temperature, we get the following:

```r
Coefficients:
(Intercept)         temp
5.0850              -0.1156
```

In this case $\eta = 5.0850 - 0.1156 * TEMP$.

14 / 68

James Wagner

Class 4

<!-- page 15 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

Let's plot the predicted values from this model.

15 / 68

James Wagner

Class 4

*[Figure: This scatter plot displays the predicted values from a logistic regression model, plotting "Log Odds" on the vertical axis (ranging from -4.0 to -1.0) against "Temperature" on the horizontal axis (ranging from 55 to 80) for a single group of data points. The main pattern shows a strict, negative linear relationship where the predicted log odds steadily decrease as temperature increases.]*

<!-- page 16 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

We could also convert this to the probability scale:

Probability of Damage
1.0
0.8
0.6
0.4
0.2
0.0
20
30
40
50
60
70
80
Temperature

16 / 68
James Wagner
Class 4

*[Figure: The plot shows a logistic regression curve and observed data points (open circles) comparing the "Probability of Damage" on the y-axis (ranging from 0.0 to 1.0) against "Temperature" on the x-axis (ranging from 20 to 80). The main pattern demonstrates an S-shaped downward trend where the probability of damage starts near 1.0 at low temperatures and steadily decreases toward 0.0 as the temperature rises above 50, where all the observed data points are clustered.]*

<!-- page 17 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Logistic Regression

It is possible to use many of the techniques that you learned last semester to predict the logit in this setup.

* Transformations
* Dummy variables
* Interactions

17 / 68

James Wagner

Class 4

<!-- page 18 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

But, we are working on the scale of the logit. This means that the results need careful interpretation.

Recall the $\frac{p}{1-p}$ is called the odds. So $\eta$ is actually a log of the odds.

We can write our model:

$$log(odds) = \beta_0 + \beta_1 x_{i1} + \dots + \beta_q x_{iq}$$

18 / 68

James Wagner

Class 4

<!-- page 19 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

$$log(odds) = \beta_0 + \beta_1 x_{i1} + \ldots + \beta_q x_{iq}$$

$$odds = exp\{\beta_0 + \beta_1 x_{i1} + \ldots + \beta_q x_{iq}\}$$

In this case, $\beta_1$ can be interpreted as meaning a 1-unit increase in $x_{i1}$ with all other $x$'s being held constant increases the log-odds of success by $\beta_1$.

Therefore, $e^{\beta_1}$ can be interpreted as the increase in the odds-ratio that would result from a 1-unit increase in $x_{i1}$ with all other $x$'s being held constant.

19 / 68

James Wagner

Class 4

<!-- page 20 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

One issue is that people want to interpret results on the probability scale. This won't work very easily with logistic regression.

Recall that the inverse-logistic function is curved:

20 / 68

James Wagner

Class 4

*[Figure: The plot displays an inverse-logistic curve and data points relating "Temperature" on the horizontal axis (ranging from 20 to 80) to "Probability of Damage" on the vertical axis (ranging from 0.0 to 1.0). The main pattern is a downward-sloping S-shaped curve where the probability of damage starts near 1.0 at low temperatures and decreases nonlinearly toward 0.0 as temperature increases, with individual data points clustered at higher temperatures near the bottom.]*

<!-- page 21 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

The steepest change occurs at the middle of the curve.

21 / 68

James Wagner

Class 4

*[Figure: The figure is a logistic regression plot with "Temperature" on the horizontal axis (ranging from 20 to 80) and "Probability of Damage" on the vertical axis (ranging from 0.0 to 1.0). It displays a single dataset of scatter points between temperatures of 50 and 80 alongside a fitted S-shaped curve that decreases from a probability near 1.0 at low temperatures to near 0.0 at high temperatures.]*

<!-- page 22 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

### Example Points

- $\text{logit}(0.50)=0$ and $\text{logit}(0.60)=0.4$. At this point, adding 0.4 on the logit scale increases the probability 10%.
- $\text{logit}(0.90)=2.2$ and $\text{logit}(0.93)=2.6$. At this point, adding 0.4 on the logit scale increases the probability 3%.

22 / 68

James Wagner

Class 4

<!-- page 23 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

One method is to evaluate at the mean of the predictor variable of interest.

In the O-ring example, the mean temperature is 69.57. Therefore, the probability of O-ring failure at that temperature is $\frac{1}{1 + e^{-(5.0850 - 0.1156 * 69.57)}} = 0.05$.

23 / 68

James Wagner

Class 4

<!-- page 24 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

Another method is to evaluate at several points. This assumes that all the values of all other predictors are held constant (if we had more $x$'s).

Table: Pr(Failure) at Different Temperatures

| Temperature | Logit | Pr(Failure) | Increase |
| ---: | ---: | ---: | ---: |
| 69.57 | -2.96 | 0.05 | |
| 59.57 | -1.80 | 0.17 | 0.11 |
| 49.57 | -0.65 | 0.52 | 0.36 |

24 / 68

James Wagner

Class 4

<!-- page 25 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

The ‘divide by 4 rule’.

The slope of the curve is steepest at its center point. At this point, $\beta_0 + \beta_1 x_{i1} = 0$ so that $logit^{-1}(0) = 0.5$. The slope of the curve at that point is $\beta_1 / 4$.

Therefore, the maximum difference in probability corresponding to a 1-unit increase in $x$ is $\beta_1 / 4$. This maximum occurs where the probabilities are close to 0.5. In our example $-0.1156 / 4 = -0.0289$.

25 / 68  James Wagner  Class 4

<!-- page 26 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

Why does the 'divide by 4 rule' work?

The slope of the curve reaches its maximum at $\beta_0 + \beta_1 * x_{i1} = 0$. At this point, $logit^{-1}(\beta_0 + \beta_1 * x_{i1}) = 0.5$.

You can use the first derivative of the logit function with respect to $\beta_1$ to get an estimate of the maximum slope:

$$
\beta \frac{e^0}{(1 + e^0)^2} = \beta \frac{1}{(1 + 1)^2} = \frac{\beta}{4} \tag{2}
$$

26 / 68

James Wagner

Class 4

<!-- page 27 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interpretation of Coefficients

Another already mentioned interpretation of the coefficients in a logistic regression model is as odds ratios.

Recall that the log of the odds ratio has a symmetric distribution.

```r
> exp(cbind(coef(logitmod), confint(logitmod)))
Waiting for profiling to be done...
                              2.5 %      97.5 %
(Intercept) 161.5762606 0.3641231 7.207593e+04
temp          0.8908304 0.8087817 9.758269e-01
```

27/68 James Wagner Class 4

<!-- page 28 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interactions

It is possible to include interactions in logistic regression models.

These interactions need careful interpretation.

28 / 68  James Wagner  Class 4

<!-- page 29 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interactions

Example from Chen (2003).

| Variable (Reference) | OR |
| :--- | :---: |
| Age, y(<30) | 2.5 |
| Married | 1.1 |
| No. of children (>=3) | 0.8 |
| Contraceptive use | 0.1 |
| Aware of vertical transmission | 1.7 |
| Planned pregnancy | 1.7 |
| HIV infected | 3.0 |
| No. of HIV-related symptoms (>=2) | 0.9 |
| Intention x infected | 0.1 |
| Frequency of sexual activity | 0.9 |
| Treatment group | 1.6 |

29 / 68
James Wagner
Class 4

<!-- page 30 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interactions

Calculating odds ratios in the presence of interactions. For women who were not planning a pregnancy, the OR for those with HIV infection vs. those without:

$$
\begin{aligned}
\hat{OR}_1 &= \frac{\text{Odds for } (I_{planned} = 0 \text{ and } I_{infected} = 1)}{\text{Odds for } (I_{planned} = 0 \text{ and } I_{infected} = 0)} \\
&= exp(\hat{\beta}_{infected}) \\
&= exp(1.0986) = 3.0
\end{aligned}
$$

30 / 68

James Wagner

Class 4

<!-- page 31 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Interactions

For women with a planned pregnancy, the OR for those with HIV infection vs. those without:

$$\begin{aligned}
\hat{OR}_1 &= \frac{\text{Odds for }(I_{planned} = 1\text{ and }I_{infected} = 1)}{\text{Odds for }(I_{planned} = 1\text{ and }I_{infected} = 0)} \\
&= exp(\hat{\beta}_{infected} + \hat{\beta}_{plannedxinfected}) \\
&= exp(1.0986 - 2.3026) = 0.3
\end{aligned}$$

**Summary**: Write out the OR of interest in this including both of the interacted variables and derive the OR appropriately.

31 / 68

James Wagner

Class 4

<!-- page 32 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Reference vs Effect/Sum Coding

There are alternative **parameterizations** for categorical predictors when used in logistic regression (and elsewhere).

These parameteriziations don't change predicted values, but the estimated coefficients are different and, therefore, require different interpretations.

Two different paramterizations we will look at:

1. Reference coding
2. Effect or sum coding

32 / 68

James Wagner

Class 4

<!-- page 33 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Reference vs Effect/Sum Coding

The different codings are based on different **contrasts**.

**Reference coding** treats one category as a reference group.

This group's probability is estimated via the intercept.

Other groups have coefficients representing differences from the reference group.

33 / 68
James Wagner
Class 4

<!-- page 34 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Reference vs Effect/Sum Coding

Let's consider an example. The probability of a low birth weight baby.

Using `RACE` with three categories as a predictor.

The reference coding for this:

```r
> contrasts(lowbwt$RACE)
  2 3
1 0 0
2 1 0
3 0 1
```

34 / 68 $\qquad$ James Wagner $\qquad$ Class 4

<!-- page 35 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Reference vs Effect/Sum Coding

**Sum** or **Effect Coding** uses a contrast that compares each group to a “grand mean”.

The constraint is that the coefficients <u>must sum to 0</u>.

35 / 68

James Wagner

Class 4

<!-- page 36 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Reference vs Effect/Sum Coding

Back to the same example.

Using `RACE` with three categories as a predictor.

The sum or effect coding for this:

```r
> contrasts(lowbwt$RACE)
  [,1] [,2]
1    1    0
2    0    1
3   -1   -1
```

36 / 68  James Wagner  Class 4

<!-- page 37 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Reference vs Effect/Sum Coding

The estimates from the example:

| Reference Coding | | | | | | Effect/Sum Coding | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| RACE | RACE2 | RACE3 | | | | RACE | RACE1 | RACE2 | | |
| 1 | 0 | 0 | | | | 1 | 1 | 0 | | |
| 2 | 1 | 0 | | | | 2 | 0 | 1 | | |
| 3 | 0 | 1 | | | | 3 | -1 | -1 | | |
| | | | | | | | | | | |
| | **Estimate** | **Std. Error** | **z value** | **Pr(>\|z\|)** | | | **Estimate** | **Std. Error** | **z value** | **Pr(>\|z\|)** |
| **(Intercept)** | -1.155 | 0.2391 | -4.83 | 1.36E-06 | \*\*\* | **(Intercept)** | -0.6613 | 0.1759 | -3.759 | 0.000171 |
| **RACE1** | 0 | | | | | **RACE1** | -0.4937 | 0.2236 | -2.207 | 0.02728 |
| **RACE2** | 0.8448 | 0.4634 | 1.823 | 0.0683 | . | **RACE2** | 0.3511 | 0.2889 | 1.215 | 0.224223 |
| **RACE3** | 0.6362 | 0.3478 | 1.829 | 0.0674 | | **RACE3** | 0.1426 | | | |
| | | | | | | | | | | |
| **Logit** | | | | | | **Logit** | | | | |
| **RACE=1** | -1.155 | | -1.155 | 0.239577 | | **RACE=1** | -0.6613+(-0.4937) | | -1.155 | 0.239577 |
| **RACE=2** | -1.155+0.8448 | | -0.3102 | 0.423066 | | **RACE=2** | -0.6613 -0.3511 | | -0.3102 | 0.423066 |
| **RACE=3** | -1.155+0.6362 | | -0.5188 | 0.373133 | | **RACE=3** | -0.6613 - (-0.4937) - 0.3511 | | -0.5187 | 0.373156 |
| | | | | | | ***OR* RACE=3** | -0.6613+0.1426 | | -0.5187 | |

37 / 68

James Wagner

Class 4

<!-- page 38 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

For two-way tables we considered the deviance, $G^2$, which was a measure of how far the observed data departed from the expected data.

The saturated model has 0 for the deviance.

38 / 68

James Wagner

Class 4

<!-- page 39 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

Recall that $G^2$ is based on the ratio of the likelihoods for the observed and expected data.

To apply that idea here, we need to start from the likelihood.

39 / 68

James Wagner

Class 4

<!-- page 40 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

$$L(\beta) = \prod_{i=1}^n \pi_i^{Y_i} (1 - \pi_i)^{1-Y_i}$$

$$\log L(\beta) = \sum_{i=1}^n \left[ Y_i \log \pi_i + (1 - Y_i) \log (1 - \pi_i) \right]$$

$$\log L(\beta) = \sum_{i=1}^n \left[ Y_i \{ \log \pi_i - \log(1 - \pi_i) \} + \log (1 - \pi_i) \right]$$

$$\log L(\beta) = \sum_{i=1}^n \left[ Y_i \log \left( \frac{\pi_i}{1 - \pi_i} \right) + \log (1 - \pi_i) \right]$$

$$\log L(\beta) = \sum_{i=1}^n \left[ Y_i \mathbf{X}'_i \beta + \log (1 - \pi_i) \right]$$

40 / 68

James Wagner

Class 4

<!-- page 41 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

We can use this likelihood to test model fit.

First define $G_p = -2logL(\hat{\beta})$ as the likelihood for the model with $p$ coefficients.

Then define $G_k = -2logL(\hat{\beta})$ as a reduced model with $k$ coefficients.

Then the likelihood ratio test can be written as $-2log\frac{L(\hat{\beta}_k)}{L(\hat{\beta}_p)}$.

This ratio has a $\chi^2$ distribution with $p - k$ degrees of freedom.

41 / 68
James Wagner
Class 4

<!-- page 42 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

This can also be written as $G_k - G_p \sim \chi_{p-k}^2$.

This should allow us test a model vs an alternative.

The conclusion will be whether the full model contains additional information beyond the reduced model.

42 / 68
James Wagner
Class 4

<!-- page 43 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

We can use this method to compare our hypothesized model to a null model.

The null model has only the intercept (the mean).

Do our covariates add anything to our knowledge of the probabilities?

We could also ask, can we successfully differentiate cases in our sample into those with different probabilities?

43 / 68
James Wagner
Class 4

<!-- page 44 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

Let’s go back to our O-ring example.

```r
> anova(logitmod,test='LRT')
Analysis of Deviance Table

Model: binomial, link: logit

Response: damage

Terms added sequentially (first to last)


Df Deviance Resid. Df Resid. Dev Pr(>Chi)
NULL                   137     66.540
temp  1    6.144       136     60.396  0.01319 *
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

It appears that temperature adds to our understanding of the failure of O-rings.

44 / 68
James Wagner
Class 4

<!-- page 45 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

Similar output directly from `glm` :

```r
> logitmod

Call:  glm(formula = damage ~ temp, family = binomial,

Coefficients:
(Intercept)          temp
     5.0850       -0.1156

Degrees of Freedom: 137 Total (i.e. Null);  136 Residu
Null Deviance:	    66.54
Residual Deviance: 60.4 	AIC: 64.4
```

45 / 68

James Wagner

Class 4

<!-- page 46 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

This gives us a means to assess model fit and compare alternative models. We may also want to assess each coefficient in the model.

Fortunately, we can use some approximations here.

46 / 68

James Wagner

Class 4

<!-- page 47 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

$\hat{\beta}$ is approximately distributed as $N_p \left( \beta, (\mathbf{X}'\mathbf{V}\mathbf{X})^{-1} \right)$, where

$\boldsymbol{V} = diag[\pi_1(1 - \pi_1), \pi_2(1 - \pi_2), \dots, \pi_n(1 - \pi_n)]$

$$\mathbf{X} = \begin{pmatrix} \mathbf{X}_1' \\ \mathbf{X}_2' \\ \vdots \\ \mathbf{X}_n' \end{pmatrix}$$

47 / 68

James Wagner

Class 4

<!-- page 48 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

```r
> Anova(logitmod, type="II", test="Wald")
Analysis of Deviance Table (Type II tests)

Response: damage
     Df  Chisq    Pr(>Chisq)
temp  1 6.0435    0.01396 *
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0
```

48 / 68

James Wagner

Class 4

<!-- page 49 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

There is an assumed linear relationship between continuous predictors and the logit.

This assumption can be checked by reviewing *empirical logit plots*.

1. Calculate probability in binned values of the predictor.
2. Take the logit of these probabilities
3. Plot them. Is the relationship linear?

49 / 68 James Wagner Class 4

<!-- page 50 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

```r
orings2<-orings
orings2$temp.grp[orings2$temp< 60] <- 55
orings2$temp.grp[orings2$temp >= 60 & orings2$temp <65 ] <- 60
orings2$temp.grp[orings2$temp >= 65 & orings2$temp <70 ] <- 65
orings2$temp.grp[orings2$temp >= 70 & orings2$temp <75 ] <- 70
orings2$temp.grp[orings2$temp>=75] <- 75

orings3<-summaryBy(damage ~ temp.grp, data = orings2,
          FUN = function(x) { c(sum = sum(x), cnt=length(x)) } )
orings3$p<-orings3$damage.sum/(orings3$damage.cnt*6)
orings3$emp.logit<-log(orings3$p/(1-orings3$p))
orings3<-orings3[-3,]
```

50 / 68

James Wagner

Class 4

<!-- page 51 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

```r
> orings3
  temp.grp damage.sum damage.cnt          p  emp.logit
1       55          7          3 0.38888889 -0.4519851
2       60          1          1 0.16666667 -1.6094379
4       70          2          6 0.05555556 -2.8332133
5       75          1          7 0.02380952 -3.7135721
```

51 / 68

James Wagner

Class 4

<!-- page 52 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

52 / 68
James Wagner
Class 4

<!-- page 53 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

We can also look at the residuals. Here are the residuals plotted against the fitted values:

53 / 68

James Wagner

Class 4

<!-- page 54 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Model Fit

This is not very helpful as any given predicted value can only take on two values for the residual.

One method around this is to group cases, average their residuals and fitted values, and plot those. “Binned residual plot:”

54 / 68

James Wagner

Class 4

<!-- page 55 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

Table: Variables Available for Birth Weight Analysis

| Variable | Description |
| :--- | :--- |
| ID | Identification Code |
| LOW | Low Birth Weight (0=Birth Weight greater than or equal to 2500g, 1=Birth Weight less than 2500g.) |
| AGE | Age of Mother in years |
| LWT | Weight in pounds at the last Menstrual Period |
| RACE | Race (1=White, 2=Black, 3=Other) |
| SMOKE | Smoking status During Pregnancy (1=Yes, 0=No) |
| PTL | History of Premature Labor (0=None, 1=One, etc.) |
| HT | History of Hypertension (1=Yes, 0=No) |
| UI | Presence of Uterine Irritability (1=Yes, 0=No) |
| FTV | Number of Physician Visits During the First Trimester (0=None, 1=One, 2=Two, etc.) |
| BWT | Birth Weight in grams. |

55 / 68
James Wagner
Class 4

<!-- page 56 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

```r
lowbwt.mod<-glm(LOW ~ AGE + LWT + factor(RACE) +
    SMOKE +   PTL + HT + UI + FTV,data=lowbwt)
```

56 / 68

James Wagner

Class 4

<!-- page 57 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

```r
> lrtest(lowbwt.mod)
Likelihood ratio test

Model 1: LOW ~ AGE + LWT + factor(RACE) + SMOKE + PTL
Model 2: LOW ~ 1
#Df  LogLik Df Chisq Pr(>Chisq)
1  11 -105.89
2   2 -122.80 -9 33.81  9.643e-05 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0
```

57/68 James Wagner Class 4

<!-- page 58 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

```r
> roc(factor(lowbwt$LOW),lowbwt$phat,plot=TRUE,auc.print=TRUE)
Setting levels: control = 0, case = 1
Setting direction: controls < cases

Call:
roc.default(response = factor(lowbwt$LOW), predictor = lowbwt$phat,     pl

Data: lowbwt$phat in 130 controls (factor(lowbwt$LOW) 0) < 59 cases (facto
Area under the curve: 0.7469
```

58 / 68

James Wagner

Class 4

<!-- page 59 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

```r
> PseudoR2(lowbwt.mod,which="all")
McFadden     McFaddenAdj        CoxSnell      Nagelkerke
0.1376655       0.0562313       0.1638022       0.2252136
AldrichNelson VeallZimmermann           Efron McKelveyZavoina
0.1517445       0.2685201       0.1638022              NA
Tjur             AIC             BIC          logLik
NA     233.7867436     269.4459608    -105.8933718
logLik0              G2
-122.7984909      33.8102383
```

These are various Pseudo-$R^2$. It might be thought of as a standardized measure of improvement over the null model.

Not proportion of variance that is explained.

59 / 68
James Wagner
Class 4

<!-- page 60 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

$$
\text{Nagelkerke Pseudo } R^2 = \frac{1 - \exp\left[-\frac{2}{n} \left\{LL(M_{Full}) - LL(M_{Intercept})\right\}\right]}{1 - \exp\left[-\frac{2}{n} LL(M_{Intercept}\right]}
$$

For example, in example 5, we have the estimated log-likelihoods (full and intercept-only):

$$
\text{Pseudo } R^2 = \frac{1 - \exp\left[-\frac{2}{189} \left\{-105.893 - -122.798\right\}\right]}{1 - \exp\left[-\frac{2}{189} \times -122.798\right]} = 0.2252
$$

We might say that the covariates add about 23% more information beyond knowledge of the mean.

60 / 68
James Wagner
Class 4

<!-- page 61 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

Let's reduce the model. See R.

61 / 68  James Wagner  Class 4

<!-- page 62 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

```r
> Anova(lowbwt.mod, type="II", test="Wald")
Analysis of Deviance Table (Type II tests)

Response: LOW
Df Chisq Pr(>Chisq)
AGE           1 0.3296   0.565877
LWT           1 4.8142   0.028227 *
factor(RACE)  2 6.5050   0.038678 *
SMOKE         1 5.0295   0.024919 *
PTL           1 2.8770   0.089854 .
HT            1 7.3151   0.006838 **
UI            1 2.8347   0.092249 .
FTV           1 0.0413   0.838906
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

62 / 68  James Wagner  Class 4

<!-- page 63 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

Is the relationship between `AGE` and `LOW` nonlinear?

Check the empirical logit plot:

63 / 68

James Wagner

Class 4

<!-- page 64 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

Try `AGE` and `AGE*AGE`:

```r
> Anova(lowbwt.mod2, type="II", test="Wald")
Analysis of Deviance Table (Type II tests)

Response: LOW
Df  Chisq Pr(>Chisq)
AGE       1 0.0280   0.867011
I(AGE^2)  1 0.0904   0.763636
LWT       1 3.4647   0.062692 .
RACE      1 3.9631   0.046509 *
SMOKE     1 5.1114   0.023769 *
PTL       1 2.8061   0.093906 .
HT        1 7.2650   0.007031 **
UI        1 2.7043   0.100078
FTV       1 0.0489   0.824986
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

64 / 68
James Wagner
Class 4

<!-- page 65 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

Reduce the model:

```r
> Anova(lowbwt.mod3, type="II", test="Wald")
Analysis of Deviance Table (Type II tests)

Response: LOW
Df Chisq Pr(>Chisq)
LWT    1 4.7244   0.029738 *
RACE   1 5.0322   0.024881 *
SMOKE  1 7.3263   0.006795 **
HT     1 7.8663   0.005036 **
UI     1 4.3101   0.037887 *
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

65 / 68  James Wagner  Class 4

<!-- page 66 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

Table: Comparing Two Models

| Statistic | Model 2 | Model 3 |
| :---: | :---: | :---: |
| Log(L) | -107.110 | -108.869 |
| AIC | 236.220 | 231.737 |
| N-Pseudo $R^2$ | 0.210 | 0.188 |
| AUC | 0.746 | 0.728 |
| $p$ | 9+Intercept | 5+Intercept |

66 / 68

James Wagner

Class 4

<!-- page 67 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

We can apply a test to the difference in the likelihoods, which will have a $\chi^2$ distribution.

$G_6 - G_{10} = -2(-107.110 - -105.893) = 2.434$ with $9 - 5 = 4$ df. This is not significant at the $0.01$ level since $\chi^2_{4,.01} = 13.2$.

67 / 68
James Wagner
Class 4

<!-- page 68 -->

Logistic Regression
Interpretation of Coefficients
Inference

# Example 5

Same type of test can be used to test interactions in the model.

```r
>lowbwt.mod3<-glm(LOW ~ LWT + RACE + SMOKE + HT + UI,data=lowbwt)
>lowbwt.mod4<-glm(LOW ~ LWT + RACE + SMOKE + HT + UI + SMOKE*LWT,
 data=lowbwt)
> lrtest(lowbwt.mod4,lowbwt.mod3)
Likelihood ratio test

Model 1: LOW ~ LWT + RACE + SMOKE + HT + UI + SMOKE * LWT
Model 2: LOW ~ LWT + RACE + SMOKE + HT + UI
#Df LogLik Df Chisq Pr(>Chisq)
1   8 -108.81
2   7 -108.87 -1 0.1202     0.7288
```

68 / 68

James Wagner

Class 4
