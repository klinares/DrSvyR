---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/12_MVN_In-Class_Slides"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "In-Class Lecture 12. Multivariate Analysis"
original: "stat_mod_ML_2_SURV616/lectures/12 MVN In-Class Slides.pdf"
pages: 48
sha256: "1780df19e9164504aa130404baf8fa385ecd0050e3de2c93286e7fd4be456e28"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:20"
---

<!-- page 1 -->

# In-Class Lecture 12. Multivariate Analysis

James Wagner

April 2023

<!-- page 2 -->

MVN Distribution
Estimation
Hypothesis Testing

# Overview

1. Multivariate Normal Distribution

2. Estimation of the Mean and Covariance Matrix

3. Hypothesis Testing

2 / 48 James Wagner In-Class 12

<!-- page 3 -->

MVN Distribution
Estimation
Hypothesis Testing

# Multivariate Normal

The $p$-dimensional random variable $\mathbf{X}$ with $p$ components $(X_1, X_2, \ldots, X_p)$ with distribution $N(\boldsymbol{\mu}, \boldsymbol{\Sigma^2})$ has the following probability density function:

$$f(\mathbf{x}) = \frac{1}{(2\pi)^{\frac{p}{2}} |\boldsymbol{\Sigma}|^{\frac{1}{2}}} e^{-\frac{1}{2}(\mathbf{x}-\boldsymbol{\mu})'\boldsymbol{\Sigma}^{-1}(\mathbf{x}-\boldsymbol{\mu})}$$

3 / 48  James Wagner  In-Class 12

<!-- page 4 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 1

Let $\boldsymbol{X} \sim N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$, then each component $X_t$ for $i = 1, \dots, p$ has a univariate normal distribution $X_i \sim N(\mu_i, \sigma_{ii})$.

4 / 48

James Wagner

In-Class 12

<!-- page 5 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 2

Let $\boldsymbol{X} \sim N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$, then any distinct subset of the components (say $k$) has a $k$-dimensional multivariate normal distribution.

Example. The following is a 5-dimensional multivariate normal distribution:

$$
\left(\begin{array}{c}
X_1 \\
X_2 \\
X_3 \\
X_4 \\
X_5
\end{array}\right) \sim N_5 \left( \left(\begin{array}{c}
\mu_1 \\
\mu_2 \\
\mu_3 \\
\mu_4 \\
\mu_5
\end{array}\right) , \left(\begin{array}{ccccc}
\sigma_{11} & \sigma_{12} & \sigma_{13} & \sigma_{14} & \sigma_{15} \\
\sigma_{21} & \sigma_{22} & \sigma_{23} & \sigma_{24} & \sigma_{25} \\
\sigma_{31} & \sigma_{32} & \sigma_{33} & \sigma_{34} & \sigma_{35} \\
\sigma_{41} & \sigma_{42} & \sigma_{43} & \sigma_{44} & \sigma_{45} \\
\sigma_{51} & \sigma_{52} & \sigma_{53} & \sigma_{54} & \sigma_{55}
\end{array}\right) \right)
$$

Then, the following subset is a 3-dimensional MVN distribution:

$$
\left(\begin{array}{c}
X_4 \\
X_1 \\
X_5
\end{array}\right) \sim N_3 \left( \left(\begin{array}{c}
\mu_4 \\
\mu_1 \\
\mu_5
\end{array}\right) , \left(\begin{array}{ccc}
\sigma_{44} & \sigma_{41} & \sigma_{45} \\
\sigma_{14} & \sigma_{11} & \sigma_{15} \\
\sigma_{54} & \sigma_{51} & \sigma_{55}
\end{array}\right) \right)
$$

5 / 48

James Wagner

In-Class 12

<!-- page 6 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 3

Recall the univariate normal property: if $X \sim N(\mu, \sigma^2)$, then $cX$, where $c$ is some constant, is distributed $N(c\mu, c^2\sigma^2)$.

Let $\boldsymbol{X} \sim N_p(\boldsymbol{\mu}, \Sigma)$, and let $\boldsymbol{c}' = (c_1, c_2, \ldots, c_p)$ be a fixed vector of constants, then

$$\boldsymbol{c}'\boldsymbol{X} \sim N_p(\boldsymbol{c}'\boldsymbol{\mu}, \boldsymbol{c}'\Sigma\boldsymbol{c}).$$

6 / 48  James Wagner  In-Class 12

<!-- page 7 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 4

Let $\boldsymbol{X} \sim N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$, and let $\boldsymbol{A}$ be a $k \times p$ matrix of fixed constants where $k \le p$, then

$$\boldsymbol{AX} \sim N_k(\boldsymbol{A\mu}, \boldsymbol{A\Sigma A}').$$

7 / 48

James Wagner

In-Class 12

<!-- page 8 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 5

Let $\boldsymbol{X} \sim N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$, then

$$(\boldsymbol{X} - \boldsymbol{\mu})'\boldsymbol{\Sigma}^{-1}(\boldsymbol{X} - \boldsymbol{\mu}) \sim \chi_p^2.$$

8 / 48  James Wagner  In-Class 12

<!-- page 9 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 6

Let $\mathbf{X} \sim N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$, where we partition $\mathbf{X}$ as

$$\mathbf{X} = \begin{pmatrix} \mathbf{X_1} \\ \mathbf{X_2} \end{pmatrix}$$

where $\mathbf{X_1}$ is $k \times 1$ and $\mathbf{X_2}$ is $(p - k) \times 1$, and write

$$\begin{pmatrix} \mathbf{X_1} \\ \mathbf{X_2} \end{pmatrix} \sim N_p \left( \begin{pmatrix} \boldsymbol{\mu_1} \\ \boldsymbol{\mu_2} \end{pmatrix}, \begin{pmatrix} \boldsymbol{\Sigma_{11}} & \boldsymbol{\Sigma_{12}} \\ \boldsymbol{\Sigma_{21}} & \boldsymbol{\Sigma_{22}} \end{pmatrix} \right)$$

where $\boldsymbol{\Sigma_{12}}$ is $k \times (p - k)$.

9 / 48

James Wagner

In-Class 12

<!-- page 10 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 6

Then the conditional distribution of $\boldsymbol{X}_{\mathbf{1}}$ given $\boldsymbol{X}_{\mathbf{2}} = \boldsymbol{x}_{\mathbf{2}}$, written as $(\boldsymbol{X}_{\mathbf{1}} | \boldsymbol{X}_{\mathbf{2}} = \boldsymbol{x}_{\mathbf{2}})$, is given by:

$$
(\boldsymbol{X}_1 \, | \, \boldsymbol{X}_2 = \boldsymbol{x}_2) \sim N_k \left( \boldsymbol{\mu}_{1|2} (\boldsymbol{x}_2) , \boldsymbol{\Sigma}_{1|2} \right)
$$

$$
\boldsymbol{\mu}_{1|2} (\boldsymbol{x}_2) = \boldsymbol{\mu}_1 + \boldsymbol{\Sigma}_{12} \boldsymbol{\Sigma}_{22}^{-1} (\boldsymbol{x}_2 - \boldsymbol{\mu}_2)
$$

$$
\boldsymbol{\Sigma}_{1|2} = \boldsymbol{\Sigma}_{11} - \boldsymbol{\Sigma}_{12} \boldsymbol{\Sigma}_{22}^{-1} \boldsymbol{\Sigma}_{21}
$$

10 / 48

James Wagner

In-Class 12

<!-- page 11 -->

MVN Distribution
Estimation
Hypothesis Testing

# Property 6 Example

Let's look at the bivariate normal example.

$$\mathbf{X} = \left( \begin{array}{c} X_1 \\ X_2 \end{array} \right) , Cov(\mathbf{X}) = \left( \begin{array}{cc} \sigma_{11} & \sigma_{12} \\ \sigma_{21} & \sigma_{22} \end{array} \right)$$

$$E(X_1|X_2 = x_2) = \mu_1 + \frac{\sigma_{12}}{\sigma_{22}} (x_2 - \mu_2)$$

$$Var(X_1|X_2 = x_2) = \sigma_{11} - \frac{{\sigma^2}_{12}}{\sigma_{22}}$$

If there are covariances between $X_1$ and $X_2$, then the conditional variance is *less*.

11 / 48  James Wagner  In-Class 12

<!-- page 12 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 2

Data taken from the NLSY.

Three test scores:
1. $X_1$=AFQT Percentile Score
2. $X_2$=SAT Math Score
3. $X_3$=SAT Verbal Score

And it looks like this:

$$\begin{pmatrix} X_1 \\ X_2 \\ X_3 \end{pmatrix} \sim N_3 \left( \begin{pmatrix} 67 \\ 448 \\ 409 \end{pmatrix}, \begin{pmatrix} 652 & 2485 & 2418 \\ 2485 & 14755 & 11031 \\ 2418 & 11031 & 14666 \end{pmatrix} \right)$$

12/48 James Wagner In-Class 12

<!-- page 13 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 2

By Property 2, we can partition these matrices:

$$
\left( \begin{array}{c} X_2 \\ X_3 \end{array} \right) \sim N_2 \left( \left( \begin{array}{c} 448 \\ 409 \end{array} \right), \left( \begin{array}{cc} 14755 & 11031 \\ 11031 & 14666 \end{array} \right) \right)
$$

Now, we can calculate the correlation:

$$
Corr(X_2, X_3) = \frac{\sigma_{23}}{\sqrt{(\sigma_{22})(\sigma_{33})}} = \frac{11031}{\sqrt{(14755)(14666)}} \approx 0.7499
$$

13 / 48

James Wagner

In-Class 12

<!-- page 14 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 2

Now, let's look at an example conditional mean and conditional variance.

$$
\left( \left( \begin{array}{c} X_2 \\ X_3 \end{array} \right) | X_1 = 30 \right) = \left( \left( \begin{array}{c} \textit{SATMath} \\ \textit{SATVerbal} \end{array} \right) | \textit{AFQT} = 30 \right)
$$

We want to know $E(X_2|X_1 = 30)$. Recall that $\mu_{2|1} = \mu_2 + \frac{\sigma_{12}}{\sigma_{11}}(x_1 - \mu_1)$. In this case, we have:

$448 + \frac{2485}{652}(30 - 67) = 308$.

14 / 48

James Wagner

In-Class 12

<!-- page 15 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 2

Recall the formula for conditional variance: $\sigma_{2|1} = \sigma_{22} - \frac{\sigma_{12} \cdot \sigma_{21}}{\sigma_{11}}$. In this case, we have

$$\sigma_{2|1} = 14755 - \frac{2485 \cdot 2485}{652} = 5277$$

See R script for conditional covariance calculation.

15 / 48  James Wagner  In-Class 12

<!-- page 16 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 2

R code.

Matrix calculations are a function in base R.

16 / 48

James Wagner

In-Class 12

<!-- page 17 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 2

It is interesting to note that:

$$Corr(SATMath, SATVerbal|AFQT) = \frac{1809}{\sqrt{(5277)(5693)}} \approx 0.3300$$

Again, this is true independent of the specific value taken on by AFQT ($X_1$).

17 / 48

James Wagner

In-Class 12

<!-- page 18 -->

MVN Distribution
Estimation
Hypothesis Testing

# In-Class Exercise

Continuing with Example 2, calculate the following quantities:

$E(X_3|X_1 = 30)$.

$\sigma_{3|1}$.

18 / 48  James Wagner  In-Class 12

<!-- page 19 -->

MVN Distribution
Estimation
Hypothesis Testing

# In-Class Exercise

Continuing with Example 2, calculate the following quantities:

$$E(X_3|X_1 = 30) = 409 + \frac{2418}{652}(30 - 67) = 271.8$$

$$\sigma_{3|1} = 14666 - \frac{2418^2}{652} = 5698.6.$$

19 / 48

James Wagner

In-Class 12

<!-- page 20 -->

MVN Distribution
Estimation
Hypothesis Testing

# Estimation and Inference

Assume $X_1, X_2, \ldots, X_n$ are normal random variables from $N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$. Then the sample mean vector and sample covariance matrix are:

$$
\bar{\boldsymbol{X}} = n^{-1} \sum_{i=1}^n \boldsymbol{X_i}
$$

$$
\boldsymbol{S} = (n - 1)^{-1} \sum_{i=1}^n (\boldsymbol{X_i} - \bar{\boldsymbol{X}})(\boldsymbol{X_i} - \bar{\boldsymbol{X}})'
$$

This looks like the univariate results. These are unbiased estimators of population values (i.e. $E[\bar{\boldsymbol{X}}] = \boldsymbol{\mu}$).

20 / 48

James Wagner

In-Class 12

<!-- page 21 -->

MVN Distribution
Estimation
Hypothesis Testing

# Result 1

Let $X_1, X_2, \dots, X_n$ be a random sample from a $N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$ distribution.
Then the following will hold:

1. $\bar{\boldsymbol{X}}$ is distributed as $N_p(\boldsymbol{\mu}, n^{-1}\boldsymbol{\Sigma})$.
2. $(n - 1)\boldsymbol{S}$ is distributed as a Wishart random matrix with parameter $\boldsymbol{\Sigma}$ and degrees of freedom $n - 1$.
3. $\bar{\boldsymbol{X}}$ and $\boldsymbol{S}$ are independent.

Also note that $\hat{V}(\bar{\boldsymbol{X}}) = n^{-1}\boldsymbol{S}$.

21 / 48  James Wagner  In-Class 12

<!-- page 22 -->

MVN Distribution
Estimation
Hypothesis Testing

# Result 2

Let $X_1, X_2, \ldots, X_n$ be a random sample from a $N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$ distribution, and assume that $\boldsymbol{\Sigma}$ is known and we want to test the hypothesis $H_0:\boldsymbol{\mu} = \boldsymbol{\mu}_0$.

Then the best test rejects $H_0$ at the $\alpha$ level when

$$(\bar{\boldsymbol{X}} - \boldsymbol{\mu}_0)'\left(\frac{1}{n}\boldsymbol{\Sigma}\right)^{-1}(\bar{\boldsymbol{X}} - \boldsymbol{\mu}_0) \ge \chi^2_{p,\alpha}$$

We can use this fact to create confidence ellipsoids.

22 / 48

James Wagner

In-Class 12

<!-- page 23 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 3

Returning to the SAT Math and Verbal scores. From the 917 cases in NLSY, we estimate:

$$\bar{\mathbf{X}} = \begin{pmatrix} 448 \\ 409 \end{pmatrix}$$

$$\mathbf{S} = \begin{pmatrix} 14755 & 11031 \\ 11031 & 14666 \end{pmatrix}$$

23 / 48

James Wagner

In-Class 12

<!-- page 24 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 3

$$
n^{-1}\mathbf{S} = \left( \begin{array}{cc} 16.0905 & 12.0294 \\ 12.0294 & 15.9935 \end{array} \right)
$$

We want to test the hypothesis:

$$
H_0 : \left( \begin{array}{c} \mu_{Math} \\ \mu_{Verbal} \end{array} \right) = \left( \begin{array}{c} 450 \\ 400 \end{array} \right) \text{ versus}
$$

$$
H_A : \left( \begin{array}{c} \mu_{Math} \\ \mu_{Verbal} \end{array} \right) \neq \left( \begin{array}{c} 450 \\ 400 \end{array} \right).
$$

24 / 48  James Wagner  In-Class 12

<!-- page 25 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 3

$$
\left( \begin{pmatrix} 448 \\ 409 \end{pmatrix} - \begin{pmatrix} 450 \\ 400 \end{pmatrix} \right)' \begin{pmatrix} 16.091 & 12.029 \\ 12.029 & 15.994 \end{pmatrix}^{-1} \left( \begin{pmatrix} 448 \\ 409 \end{pmatrix} - \begin{pmatrix} 450 \\ 400 \end{pmatrix} \right) = ?
$$

Solve for the unknown value, which has a $\chi^2$ distribution.

25 / 48  James Wagner  In-Class 12

<!-- page 26 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 3

$$
\left( \begin{pmatrix} 448 \\ 409 \end{pmatrix} - \begin{pmatrix} 450 \\ 400 \end{pmatrix} \right)' \begin{pmatrix} 16.091 & 12.029 \\ 12.029 & 15.994 \end{pmatrix}^{-1} \left( \begin{pmatrix} 448 \\ 409 \end{pmatrix} - \begin{pmatrix} 450 \\ 400 \end{pmatrix} \right) = 15.98
$$

Now check the $\chi^2$ distribution. We see that $\chi^2_{2, 0.05} = 5.99$. Our value is much greater than that, so we reject $H_0$.

26 / 48
James Wagner
In-Class 12

<!-- page 27 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 3

Now let's invert that procedure. We have a $\chi^2$ value and want to see which $\boldsymbol{\mu_0}$ values are implied by this value.

$$
\left( \begin{pmatrix} 448 \\ 409 \end{pmatrix} - \begin{pmatrix} \mu_{Math} \\ \mu_{Verbal} \end{pmatrix} \right)' \begin{pmatrix} 16.0905 & 12.0294 \\ 12.0294 & 15.9935 \end{pmatrix}^{-1} \left( \begin{pmatrix} 448 \\ 409 \end{pmatrix} - \begin{pmatrix} \mu_{Math} \\ \mu_{Verbal} \end{pmatrix} \right) = 5.99
$$

Now, solve for the missing $\boldsymbol{\mu_0}$ values. The solution creates an ellipse.

27 / 48

James Wagner

In-Class 12

<!-- page 28 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 3

**Figure 1**
**Confidence Regions for SAT Scores**

Verbal (420, 415, 410, 405, 400, 395)
Math (435, 440, 445, 450, 455, 460)

28 / 48  James Wagner  In-Class 12

<!-- page 29 -->

MVN Distribution
Estimation
Hypothesis Testing

# Problem

Recall the univariate situation. When we replaced a known variance in the denominator of the $Z$ statistic with a sample estimate, we had a random variable with a $t$-distribution.

The same thing happens when looking at the multivariate situation. When we use the sample estimate of a covariance matrix, then the earlier test is inappropriate (result 2).

29 / 48  James Wagner  In-Class 12

<!-- page 30 -->

MVN Distribution
Estimation
Hypothesis Testing

# Result 3

Let $X_1, X_2, \ldots, X_n$ be a random sample from a $N_p(\boldsymbol{\mu}, \Sigma)$ distribution, and assume that $\boldsymbol{\mu}$ and $\Sigma$ are both unknown and we want to test the hypothesis $H_0: \boldsymbol{\mu} = \boldsymbol{\mu_0}$.

Hotelling's $T^2$ Statistic:

$$
T^2 = (\bar{\boldsymbol{X}} - \boldsymbol{\mu}_0)' \left(\frac{1}{n}\boldsymbol{S}\right)^{-1} (\bar{\boldsymbol{X}} - \boldsymbol{\mu}_0)
$$

Then reject $H_0$ when:

$$
T^2 > \frac{(n-1)p}{(n-p)} F^p_{n-p}(\alpha)
$$

30 / 48  James Wagner  In-Class 12

<!-- page 31 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 4

Recall our hypothesis:

$$H_0 : \left( \begin{array}{c} \mu_{\text{Math}} \\ \mu_{\text{Verbal}} \end{array} \right) = \left( \begin{array}{c} 450 \\ 400 \end{array} \right) \text{ versus}$$

$$H_A : \left( \begin{array}{c} \mu_{\text{Math}} \\ \mu_{\text{Verbal}} \end{array} \right) \neq \left( \begin{array}{c} 450 \\ 400 \end{array} \right).$$

31 / 48

James Wagner

In-Class 12

<!-- page 32 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 4

Calculate Hotelling's $T^2$:

$$T^2 = \left(\bar{\mathbf{X}} - \boldsymbol{\mu}_0\right)' \left(\frac{1}{n}\mathbf{S}\right)^{-1} \left(\bar{\mathbf{X}} - \boldsymbol{\mu}_0\right)$$

$$T^2 = (917) \left( \left( \begin{array}{c} 448 \\ 409 \end{array} \right) - \left( \begin{array}{c} 450 \\ 400 \end{array} \right) \right)' \left( \begin{array}{cc} 14755 & 11031 \\ 11031 & 14666 \end{array} \right)^{-1} \left( \left( \begin{array}{c} 448 \\ 409 \end{array} \right) - \left( \begin{array}{c} 450 \\ 400 \end{array} \right) \right) = 15.98$$

Now compare that to the appropriate value from the reference distribution:

$$\frac{(n - 1)p}{(n - p)} F_{n-p}^p (0.05) = \frac{(916)2}{915} (3.00) = 6.01$$

$15.98 > 6.01$. Therefore, reject $H_0$.

32 / 48

James Wagner

In-Class 12

<!-- page 33 -->

MVN Distribution
Estimation
Hypothesis Testing

# Convergence

Now, you might be thinking that it looks a lot like the prior example.

This is because there is an asymptotic convergence: $\frac{(n-1)p}{(n-p)} F_{n-p}^p \rightarrow \chi_p^2$ as $n \rightarrow \infty$.

33 / 48

James Wagner

In-Class 12

<!-- page 34 -->

MVN Distribution
Estimation
Hypothesis Testing

# Alternative Motivation

First, if we multiply our multivariate normal by a vector of constants, we have:

$$\mathbf{c}'\bar{\mathbf{X}} = \sum_{i=1}^p c_i\bar{X}_i.$$

From the properties of expected value and variance we know:

$$E\left\{\mathbf{c}'\bar{\mathbf{X}}\right\} = \mathbf{c}'\boldsymbol{\mu}$$

$$\hat{V}\left\{\mathbf{c}'\bar{\mathbf{X}}\right\} = n^{-1}\mathbf{c}'\mathbf{S}\mathbf{c}$$

34 / 48

James Wagner

In-Class 12

<!-- page 35 -->

MVN Distribution
Estimation
Hypothesis Testing

# Alternative Motivation

Now form the univariate $t$-statistic:

$$t_c = \frac{\boldsymbol{c}'(\bar{\boldsymbol{X}} - \boldsymbol{\mu})}{\sqrt{n^{-1}\boldsymbol{c}'\boldsymbol{S}\boldsymbol{c}}}$$

Square both sides of the equation:

$$t_c^2 = \frac{\boldsymbol{c}'(\bar{\boldsymbol{X}} - \boldsymbol{\mu})'(\bar{\boldsymbol{X}} - \boldsymbol{\mu})\boldsymbol{c}}{n^{-1}\boldsymbol{c}'\boldsymbol{S}\boldsymbol{c}}$$

Then it can be shown that:

$$\max_{\boldsymbol{c} \in \Re^p} \left(t_c^2\right) = T^2 = n(\bar{\boldsymbol{X}} - \boldsymbol{\mu})'\boldsymbol{S}^{-1}(\bar{\boldsymbol{X}} - \boldsymbol{\mu})$$

In words, the Hotelling $T^2$ is the largest squared univariate $t$-statistic that can be constructed from the data.

35 / 48 James Wagner In-Class 12

<!-- page 36 -->

MVN Distribution
Estimation
Hypothesis Testing

# Result 4

Let $X_1, X_2, \dots, X_n$ be a random sample from a $N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$ distribution, and assume that $\boldsymbol{\mu}$ and $\boldsymbol{\Sigma}$ are both unknown, and let $\boldsymbol{c}$ be any $p$-dimensional column vector. Then simultaneously for all values of $c$ in $\Re^p$, the confidence interval:

$$
\left[\boldsymbol{c}'\bar{\boldsymbol{X}} - \sqrt{\frac{(n-1)p}{(n-p)} F_{n-p}^p(\alpha)}\sqrt{n^{-1}\boldsymbol{c}'\boldsymbol{S}\boldsymbol{c}}, \boldsymbol{c}'\bar{\boldsymbol{X}} + \sqrt{\frac{(n-1)p}{(n-1)} F_{n-p}^p(\alpha)}\sqrt{n^{-1}\boldsymbol{c}'\boldsymbol{S}\boldsymbol{c}}\right]
$$

will contain $\boldsymbol{c}'\boldsymbol{\mu}$ with probability $1 - \alpha$. These are called simultaneous $T^2$ confidence intervals.

36 / 48

James Wagner

In-Class 12

<!-- page 37 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 5

Back to the same data:

$$
\begin{aligned}
\bar{X}_{math} &= 448 \\
\bar{X}_{verbal} &= 409 \\
\hat{V}(\bar{X}_{math}) &= 16.0905 \\
\hat{V}(\bar{X}_{verbal}) &= 15.9935
\end{aligned}
$$

For these data we can easily construct univariate 95% confidence intervals.

For $\mu_{math}$ the interval is $[440.138, 455.862]$.
For $\mu_{verbal}$ the interval is $[401.162, 416.838]$.

37 / 48  James Wagner  In-Class 12

<!-- page 38 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 5

But we know that these variables are related (bivariate normal). Let's estimate the simultaneous $T^2$ confidence intervals using:

$$
\left[\boldsymbol{c}'\bar{\boldsymbol{X}} - \sqrt{\frac{(n-1)p}{(n-p)}F_{n-p}^p(\alpha)}\sqrt{n^{-1}\boldsymbol{c}'\boldsymbol{S}\boldsymbol{c}}, \boldsymbol{c}'\bar{\boldsymbol{X}} + \sqrt{\frac{(n-1)p}{(n-1)}F_{n-p}^p(\alpha)}\sqrt{n^{-1}\boldsymbol{c}'\boldsymbol{S}\boldsymbol{c}}\right]
$$

For $\mu_{math}$ the interval is $[438.1825, 457.8174]$.
For $\mu_{verbal}$ the interval is $[399.2122, 418.7878]$.

These intervals are slightly wider.

38 / 48  James Wagner  In-Class 12

<!-- page 39 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 5

**Figure 2**
**Simultaneous Confidence Regions for SAT Scores**

39 / 48

James Wagner

In-Class 12

<!-- page 40 -->

MVN Distribution
Estimation
Hypothesis Testing

# Pooled Tests

We may want to test the difference in mean vectors ($\boldsymbol{\mu}_1 - \boldsymbol{\mu}_2$) between two multivariate normal distributions.

Let $X_1, X_2, \ldots, X_{n1}$ be a random sample of size $n_1$ drawn from a $N_p(\boldsymbol{\mu}_1, \Sigma)$ distribution.

Let $Y_1, Y_2, \ldots, Y_{n2}$ be a random sample of size $n_2$ drawn from a $N_p(\boldsymbol{\mu}_2, \Sigma)$ distribution.

NOTE: The covariance matrices are the same in the two distributions. We need this to be true for this to work!

40 / 48

James Wagner

In-Class 12

<!-- page 41 -->

MVN Distribution
Estimation
Hypothesis Testing

# Pooled Tests

Our hypothesis is $H_0\text{:}\boldsymbol{\mu_1} - \boldsymbol{\mu_2} = \boldsymbol{\delta}$.

Recall that $\boldsymbol{S_2} = (n_2 - 1) \sum_{i=1}^{n_2} (\boldsymbol{Y_i} - \bar{\boldsymbol{Y}})((\boldsymbol{Y_i} - \bar{\boldsymbol{Y}})'$.

If we can assume that $\boldsymbol{S_1}$ and $\boldsymbol{S_2}$ come from the same distribution, then we can “pool” them to increase the power of our test:

$$\boldsymbol{S}_{Pooled} = \frac{(n_1 - 1)\boldsymbol{S}_1 + (n_2 - 1)\boldsymbol{S}_2}{(n_1 + n_2 - 2)}$$

41 / 48  James Wagner  In-Class 12

<!-- page 42 -->

MVN Distribution
Estimation
Hypothesis Testing

# Pooled Tests

Now we can calculate the $T^2$ statistic:

$$
T^2 = (\bar{\boldsymbol{X}} - \bar{\boldsymbol{Y}} - \boldsymbol{\delta})'\left[\left(\frac{1}{n_1} + \frac{1}{n_2}\right)\boldsymbol{S}_{Pooled}\right]^{-1}(\bar{\boldsymbol{X}} - \bar{\boldsymbol{Y}} - \boldsymbol{\delta})
$$

We reject $H_0$ if:

$$
T^2 > \frac{(n_1 + n_2 - 2)p}{(n_1 + n_2 - p - 1)}F_{n_1+n_2-p-1}^p(\alpha)
$$

42 / 48  James Wagner  In-Class 12

<!-- page 43 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 6

Back to the same data.

$X_1, X_2, \dots, X_{407}$ is a random sample of 407 men with a $N_3(\boldsymbol{\mu}_1, \Sigma)$ distribution.

$Y_1, Y_2, \dots, Y_{510}$ is a random sample of 510 women with a $N_3(\boldsymbol{\mu}_2, \Sigma)$ distribution.

Test the null hypothesis: $H_0: \boldsymbol{\mu}_1 = \boldsymbol{\mu}_2$.

43 / 48
James Wagner
In-Class 12

<!-- page 44 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 6

$$
\bar{\boldsymbol{X}} = \left( \begin{array}{c} 72.412776 \\ 484.69287 \\ 425.40541 \end{array} \right)
$$

$$
\bar{\boldsymbol{Y}} = \left( \begin{array}{c} 62.186275 \\ 418.80392 \\ 396.45098 \end{array} \right)
$$

44 / 48

James Wagner

In-Class 12

<!-- page 45 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 6

$$
\boldsymbol{S}_1 = \left( \begin{array}{ccc}
570.58782 & 2331.9744 & 2298.0835 \\
2331.9744 & 15281.125 & 11725.802 \\
2298.0835 & 11725.802 & 15422.434
\end{array} \right)
$$

$$
\boldsymbol{S}_2 = \left( \begin{array}{ccc}
671.18134 & 2312.8558 & 2387.185 \\
2312.8558 & 12433.341 & 9650.1672 \\
2387.185 & 9650.1672 & 13718.421
\end{array} \right)
$$

$$
\boldsymbol{S}_{Pooled} = \left( \begin{array}{ccc}
626.5464 & 2321.339 & 2347.6492 \\
2321.339 & 13696.948 & 10571.159 \\
2347.649 & 10571.159 & 14474.518
\end{array} \right)
$$

45 / 48  James Wagner  In-Class 12

<!-- page 46 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 6

$$
T^2 = 90.13.
$$

$$
\frac{(n_1 + n_2 - 2)p}{(n_1 + n_2 - p - 1)} F_{n_1 + n_2 - p - 1}^p (0.05) = \frac{(915)3}{(913)} (2.61) = 7.85
$$

46 / 48

James Wagner

In-Class 12

<!-- page 47 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 6

See R program (work from mean vectors, covariance matrices).

Just as with a two-sample t-test, we should test for equality of variances.

47 / 48

James Wagner

In-Class 12

<!-- page 48 -->

MVN Distribution
Estimation
Hypothesis Testing

# Example 6

In R, use the `DescTools` package.

```r
library(DescTools)
HotellingsT2Test(xscores, y = yscores)
```

48 / 48

James Wagner

In-Class 12
