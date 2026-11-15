---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/Categorical_slides_InClass"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "In-Class 1. Categorical Data Analysis"
original: "stat_mod_ML_2_SURV616/lectures/Categorical slides InClass.pdf"
pages: 29
sha256: "a6f1c8e14b9002bb0b6060826f00595a6753b4bcad6a32dc63be3809274d2190"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:20"
---

<!-- page 1 -->

# In-Class 1. Categorical Data Analysis

Suzer-Gurtekin

January 2025

<!-- page 2 -->

Review
Goodness of Fit Tests

# Overview

1. Review of Distributions
2. Testing Goodness of Fit

2 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 3 -->

Review
Goodness of Fit Tests

# Distributions

* Most of 615/685 built upon normal distribution
* This course focuses on what happens when this assumption is violated
* Non-normal distributions for categorical and count data
  * Bernoulli
  * Binomial
  * Multinomial
  * Poisson

3 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 4 -->

Review
Goodness of Fit Tests

# Bernoulli

Let the random variable $X$ take on two values, $0$ and $1$, with the following distribution:

$P(X = 1) = p$
$P(X = 0) = 1 - p$

This is called a *Bernoulli* random variable. It is denoted $X \sim Ber(p)$.

4 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 5 -->

Review
Goodness of Fit Tests

# Bernoulli

Bernoulli distribution expected value and variance:

$E[X] = p$
$V(X) = p(1 - p)$

5 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 6 -->

Review
Goodness of Fit Tests

# Binomial

### Properties of $\hat{p}$ from a Binomial Distribution

1. $\hat{p}$ is a random variable
2. $\hat{p}$ is unbiased
3. $V(\hat{p}) = \frac{p(1-p)}{n}$
4. For large $n$, $\sqrt{n}(\hat{p} - p) \rightarrow N[0, p(1 - p)]$
5. The MLE for any one-to-one function of $p$, $\theta = g(p)$ is $\hat{\theta} = g(\hat{p})$

6 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 7 -->

Review
Goodness of Fit Tests

# Multinomial

Let $\mathbf{X}$ be a $k \times 1$ dimensional random vector which has all its components equal to zero, except for one which is equal to 1.

Further, we assume that:

$$\mathbf{X}' = (X_1, \dots, X_k)$$

$P(X_j = 1) = p_j$ for $j = 1, \dots, k$

$$\sum_{i=1}^k p_i = 1$$

7 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 8 -->

Review
Goodness of Fit Tests

# Multinomial

Example of a variable with a multinomial distribution ($k = 5$):

Overall Health Status
1=Excellent
2=Very Good
3=Good
4=Fair
5=Poor

8 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 9 -->

Review
Goodness of Fit Tests

# Multinomial

## Properties of $\hat{\boldsymbol{p}}$ from a Multinomial Distribution

1. $\hat{\boldsymbol{p}}$ is a random vector
2. $\hat{\boldsymbol{p}}$ is unbiased
3. $V(\hat{\boldsymbol{p}}) = n^{-1}[diag(\boldsymbol{p}) - \boldsymbol{p}\boldsymbol{p}']$, $V(\hat{p}_i) = \frac{p_i(1-p_i)}{n}$, $C(\hat{p}_i, \hat{p}_j) = \frac{-p_ip_j}{n}$
4. For large $n$, $\sqrt{n}(\hat{\boldsymbol{p}} - \boldsymbol{p}) \to N_k(\mathbf{0}, diag(\boldsymbol{p}) - \boldsymbol{p}\boldsymbol{p}')$
5. The MLE for any one-to-one function $\boldsymbol{\theta} = g(\boldsymbol{p})$ is $\hat{\boldsymbol{\theta}} = g(\hat{\boldsymbol{p}})$

9 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 10 -->

Review
Goodness of Fit Tests

# Multinomial

We can characterize any element of a multinomial distribution as a binomial of the form:

$$Y_i \sim \text{Bin}(n, p_i)$$

$$E[Y_i] = np_i$$

$$V(Y_i) = np_i(1 - p_i)$$

10 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 11 -->

Review
Goodness of Fit Tests

# Example 1

We have 1301 plants from a plant-breeding experiment. The question is, how often does each variety result from this particular combination of plants. The following are the observed counts of each variety:

| Variety | Count |
| ---: | ---: |
| Green | 773 |
| Golden | 231 |
| Green-Striped | 238 |
| Golden-Green-Striped | 59 |
| Sum | 1301 |

Genetics predicts 9/16, 3/16, 3/16 and 1/16 as the distribution of varieties. We will use these predictions as our $H_0$.

11 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 12 -->

Review
Goodness of Fit Tests

# In-Class Problem

| Variety | Count |
| ---: | ---: |
| Green | 773 |
| Golden | 231 |
| Green-Striped | 238 |
| Golden-Green-Striped | 59 |
| Sum | 1301 |

What is the probability that a “Green” variety will result?
What is the variance of this estimate?
What is the probability that a “Golden” or “Golden-Green-Striped” will result?
What is the variance of this estimate?

12 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 13 -->

Review
Goodness of Fit Tests

# In-Class Problem

What is the probability that a “Green” variety will result?
$$Pr(Green) = \hat{p}_1 = \frac{773}{1301} = 0.59$$

What is the variance of this estimate?
$$V(\hat{p}_1) = \frac{\hat{p}_1(1 - \hat{p}_1)}{n} = \frac{.59(1 - .59)}{1301} = 0.000185345$$

13 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 14 -->

Review
Goodness of Fit Tests

# In-Class Problem

What is the probability that a “Golden” or “Golden-Green-Striped” will result?

$\text{Pr}(\text{Golden or Golden-Green-Striped}) = \hat{p}_2 + \hat{p}_4 = \frac{231+59}{1301} = 0.223$

What is the variance of this estimate?

$$
\begin{aligned}
\hat{V}(\hat{p}_2 + \hat{p}_4) &= \hat{V}(\hat{p}_2) + \hat{V}(\hat{p}_4) + 2C(\hat{p}_2, \hat{p}_4) \\
&= \frac{\hat{p}_2(1 - \hat{p}_2)}{n} + \frac{\hat{p}_4(1 - \hat{p}_4)}{n} + 2[\frac{-(\hat{p}_2\hat{p}_4)}{n}] \\
&= \frac{.1776(1 - .1776)}{1301} + \frac{.0453(1 - .0453)}{1301} + 2[\frac{-(.1776[.0453])}{1301} \\
&= 0.000133143
\end{aligned}
$$

14 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 15 -->

Review
Goodness of Fit Tests

# In-Class Problem

The following R code can also be used to create a solution:

```r
## Example 1
varieties<-c(773,231,238,59)

p1<-varieties[1]/sum(varieties)
var_p1<-(1-p1)*p1/sum(varieties)

p2_4<-sum(varieties[c(2,4)])/sum(varieties)
var_p2_4<-(1-p2_4)*p2_4/sum(varieties)
```

15 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 16 -->

Review
Goodness of Fit Tests

# Poisson

Let $Y_i$ be a Poisson random variable with parameter $m_i$ for $i = 1, \dots, k$. We write $Y_i \sim Poisson(m_i)$. Define $\mathbf{Y}' = (Y_1, \dots, Y_k)$.

We can write the pmf of $Y_i$ as:

$$
Pr(Y_i = y_i) = \frac{e^{-m_i}m_i^{y_i}}{y_i!}
$$

for $y_i = 0, 1, \dots, \infty$.

16 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 17 -->

Review
Goodness of Fit Tests

# Poisson

The mean and variance of the Poisson distribution are:

$E[Y_i] = m_i$
$V(Y_i) = m_i$

17 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 18 -->

Review
Goodness of Fit Tests

# Poisson

## Properties of $\hat{\boldsymbol{m}}$ from Poisson Sampling

1. $\hat{\boldsymbol{m}}$ is a random vector
2. $\hat{\boldsymbol{m}}$ is unbiased
3. $V(\hat{\boldsymbol{m}}) = diag(\boldsymbol{m})$
4. The MLE for any one-to-one function $\boldsymbol{\theta} = g(\boldsymbol{m})$ is $\hat{\boldsymbol{\theta}} = g(\hat{\boldsymbol{m}})$

18 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 19 -->

Review
Goodness of Fit Tests

# Tests of Goodness of Fit

Let $(n_1, \dots, n_k)$ denote the observed responses on a multinomial random vector with parameters $n$ and $\mathbf{p}' = (p_1, \dots, p_k)$, where $\sum_{i=1}^k n_i = n$.

We want to test the hypothesis: $H_0:\mathbf{p} = \mathbf{p_0}$ versus $H_A:\mathbf{p} \neq \mathbf{p_0}$

where we specify the vector $\mathbf{p_0}$.

19 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 20 -->

Review
Goodness of Fit Tests

# Tests of Goodness of Fit

We looked two tests of this hypothesis:

1. Pearson Chi-Square Statistic ($X^2$)
2. Likelihood Ratio Statistic ($G^2$)

20 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 21 -->

Review
Goodness of Fit Tests

# $\chi^2$ Distribution

These statistics (and many others) follow a $\chi^2$ distribution.

They follow this form:

$$
\frac{(\hat{\theta} - \theta_0)^2}{\text{var}(\hat{\theta})} \tag{1}
$$

This class of tests are sometimes called *Wald tests*

21 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 22 -->

Review
Goodness of Fit Tests

# Pearson Chi-Square Statistic

$$
X^2 = \sum_{i=1}^{k} \frac{(O_i - E_i)^2}{E_i}
$$

where $O_i = n_i$ is the observed count in the $i^{th}$ category, and $E_i = np_{0i}$ is the expected count in the $i^{th}$ category (from $H_0$).

22 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 23 -->

Review
Goodness of Fit Tests

# Likelihood Ratio Statistic

Using the notation from the likelihood:

$$G^2 = 2 \sum_{i=1}^{k} n_i \ln \left( \frac{n_i}{np_{0i}} \right)$$

Or, we can write using the “observed” versus “expected” notation from above:

$$G^2 = 2 \sum_{i=1}^{k} O_i \ln \left( \frac{O_i}{E_i} \right)$$

23 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 24 -->

Review
Goodness of Fit Tests

# Likelihood Ratio Statistic

In practice, $X^2$ and $G^2$ are quite close, which makes sense as they both have the same asymptotic distribution.

We can show this by rewriting $G^2$ in the form of $X^2$:

$$G^2 = \sum_{i=1}^k \frac{(O_i - E_i)^2}{E_i} - 2 \sum_{i=1}^k O_i R\left(\frac{E_i}{O_i}\right) \approx X^2$$

If we assume that $O_i \approx E_i$, then the last part drops out and the two are the same.

24 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 25 -->

Review
Goodness of Fit Tests

# Example 2

- We have the 1301 plants from the plant-breeding experiment.
- Genetics gives us expected counts $H_0$ of each variety. (9/16, 3/16, 3/16, 1/16)
  - $\frac{9}{16} \times 1301 = 731.815$
  - $\frac{3}{16} \times 1301 = 243.938$
  - $\frac{1}{16} \times 1301 = 81.313$

25 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 26 -->

Review
Goodness of Fit Tests

# Example 2

Complete the table and interpret the result:

| Variety ($i$) | Observed | Expected | $\frac{(O_i - E_i)^2}{E_i}$ | $2O_i\ln\left(\frac{O_i}{E_i}\right)$ |
| ---: | ---: | ---: | ---: | ---: |
| Green | 773 | 731.815 | ? | ? |
| Golden | 231 | 243.9375 | ? | ? |
| Green-Striped | 238 | 243.9375 | ? | ? |
| Golden-Green-Striped | 59 | 81.3125 | ? | ? |
| Sum | | | ? | ? |

26 / 29 Suzer-Gurtekin In-Class 1

<!-- page 27 -->

Review
Goodness of Fit Tests

# Example 2

The following are the observed and expected quantities:

| Variety ($i$) | Observed | Expected | $\frac{(O_i - E_i)^2}{E_i}$ | $2O_i \ln\left(\frac{O_i}{E_i}\right)$ |
| ---: | ---: | ---: | ---: | ---: |
| Green | 773 | 731.815 | 2.317805 | 84.64551 |
| Golden | 231 | 243.9375 | 0.686155 | -25.17638 |
| Green-Striped | 238 | 243.9375 | 0.14452 | -11.72929 |
| Golden-Green-Striped | 59 | 81.3125 | 6.122646 | -37.84995 |
| Sum | | | 9.271126 | 9.88988 |

Compare these values to a $\chi^2_3$ with specified $\alpha$. These values exceed the cutoff value for $\alpha = 0.05$ ($7.815$) but not for $\alpha = 0.01$ ($11.34$).

27 / 29
Suzer-Gurtekin
In-Class 1

<!-- page 28 -->

Review
Goodness of Fit Tests

# Example 2

R Demonstration:

```r
## Probabilities, Variance Est
varieties<-c(773,231,238,59)

p1<-varieties[1]/sum(varieties)
var_p1<-(1-p1)*p1/sum(varieties)

p2_4<-sum(varieties[c(2,4)])/sum(varieties)
var_p2_4<-(1-p2_4)*p2_4/sum(varieties)
```

28 / 29

Suzer-Gurtekin

In-Class 1

<!-- page 29 -->

Review
Goodness of Fit Tests

# Example 2

R Demonstration (cont.):

```r
## Hypothesis Test
exp_p<-c(0.5625,0.1875,0.1875,0.0625)

#Pearson chi-sq
test1<-chisq.test(varieties,p=exp_p)

#Likelihood ratio test
sum<-0
for (i in 1:4) sum<-sum+2*(varieties[i]*
log(varieties[i]/(exp_p[i]*1301)))

1-pchisq(sum,3)
1-pchisq(test1$statistic,3)
```

29 / 29

Suzer-Gurtekin

In-Class 1
