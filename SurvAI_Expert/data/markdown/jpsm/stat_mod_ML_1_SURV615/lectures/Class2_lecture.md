---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class2_lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class2_lecture.pdf"
pages: 69
sha256: "9ff0fec273e4c8fb1dfc0f063dc5964df7bc4686759bdf6e43c9abcf330f9b80"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:24"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #2

John Kubale

September 3, 2024

<!-- page 2 -->

# Outline

* Population, sample, and sampling distribution
* Normal distribution and central limit theorem
* Hypothesis testing
* Assessing normality
* Lab

<!-- page 3 -->

# Population vs. sample

* Use statistics to make some inferences or predictions about a particular population of interest.
* However, we will rarely have data on the entire population, so what do we do?
    * We can take a sample.
* A sample is subset of your population of interest that data is gathered on.
* If done well, statistical analyses on this sample can be generalized to the population of interest with some uncertainty.
    * Probability distributions allow us to do this while quantifying this uncertainty when certain conditions are met.

<!-- page 4 -->

# Population vs. sample

* Can differentiate by parameter notation:
  * Population parameters: $Y, \beta, \mu, \sigma$
  * Sample parameters: $\hat{Y}, \hat{\beta}, \bar{x}, s$
* Most of the time we are working with a sample rather than full population.

<!-- page 5 -->

# Degrees of freedom

* When you answer the question "How many data points are required to estimate a parameter of interest (e.g., $\bar{Y}$)?" your degrees of freedom are what's left.
* Can calculate this using the formula n-p (sample size - # of parameters).
* In regression models this formula is often written as n-p-1 to distinguish between the intercept and other parameters.

<!-- page 6 -->

# Normal Distribution

* Often assumed for continuous variables
* Reasons:
  * Bell-curve shape
  * Central Limit Theorem (CLT)
  * Variables can be transformed to normal
  * Well-developed theories

<!-- page 7 -->

# Population Distribution: Probability Distribution of $Y_i$

* What are $Y_i$?
* How are $Y_i$ in the population distributed?

$$Y_i; \; i = 1, \dots, N$$

<!-- page 8 -->

# Sample Distribution: Probability Distribution of $y_i$

$Y_i; \ i = 1, \dots, N$

Sample 1
Frequency
$y_i$
$i = 1, \dots, n$

Sample 2
Frequency
$y_i$
$i = 1, \dots, n$

$\vdots$

Sample S
Frequency
$y_i$
$i = 1, \dots, n$

* What are $y_i$?
* How are $y_i$ in each sample distributed?

<!-- page 9 -->

# Sampling Distribution: Probability Distribution of $\bar{y}_s$

Sample 1
Frequency
$y_i$
$i = 1, ..., n$
Plot the mean, $\bar{y}_1$

Sample 2
Frequency
$y_i$
$i = 1, ..., n$
Plot the mean, $\bar{y}_2$

$\vdots$ $\vdots$

Sample $S$
Frequency
$y_i$
$i = 1, ..., n$
Plot the mean, $\bar{y}_S$

Sampling Distribution of Sample Means of Individual Samples
Frequency
$\bar{y}_s$
$s = 1, ..., S$

* What are $\bar{y}_s$?
* How are $\bar{y}_s$ distributed?

<!-- page 10 -->

# Example: Sampling Distribution - 1

* Now assume HLSK data is from an entire population. Draw a simple random sample of $n = 50$ from HLSK data; distributions of AGE_DIFF and LQ3_PUB appear as:

<!-- page 11 -->

# Example: Sampling Distribution - 2

* Draw another simple random sample of $n = 50$ from the HLSK data; distributions of AGE_DIFF and LQ3_PUB look like:

<!-- page 12 -->

# Example: Sampling Distribution - 3

* Draw another simple random sample of $n = 50$ from the HLSK data; distributions of AGE_DIFF and LQ3_PUB look like:

<!-- page 13 -->

# Example: Sampling Distribution - 4

* Repeat this 1000 times; take the mean of each sample and plot the means, $\bar{y}_S$, of all 1000 samples;
* Distributions of the sample means look like:

<!-- page 14 -->

# Example: Sampling Distribution - 5

* What about when $n = 5$?
* Repeat this 1000 times; take the mean of each sample and plot the means, $\bar{y}_{\mathcal{S}}$, of all 1000 samples
* Distributions of the sample means look like:

<!-- page 15 -->

# Probability vs. Sampling Distribution

* A random variable, $y$ (e.g., AGE_DIFF or LQ3_PUB), is subject to a probability distribution with expectation ($\mu$) and variance ($\sigma^2$)
  * E.g., If the shape of the distribution of a continuous random variable, $y$, is normal then $y \sim N(\mu, \sigma^2)$

* The mean estimated from a sample, $\bar{y}_S$, is also a random variable subject to a probability distribution with its own expectation and variance due to variability in sampling
* Probability distribution of $\bar{y}_S$ is **sampling distribution**
* When $n$ is sufficiently large, $\bar{y} \sim N(\mu, \frac{\sigma^2}{n})$ due to the **Central Limit Theorem**, <u>even if $y$ does not follow a normal distribution</u>

<!-- page 16 -->

# Hypothesis testing

<!-- page 17 -->

# Hypothesis testing

* Commonly want to make comparisons involving groups and/or quantities
* Can be comparison between multiple groups
  * Is the mean height of students in class 1 different from that in class 2?
* Can compare against a specified quantity
  * Is mean change different from 0?
* These are typically estimates, so there is some uncertainty
  * How do we decide if an estimate is likely to be different given this uncertainty?
  * **Hypothesis testing**

<!-- page 18 -->

# Hypothesis testing

* Null and alternative hypotheses
  * Two mutually exclusive hypotheses about a population, relationship, or quantity.
* A hypothesis test allows us to evaluate which hypothesis the data best support.
* Null hypothesis ($H_0$): there is no difference or effect in the population.
* Alternative hypothesis ($H_A$): there is a difference or effect in the population.
* If there is sufficient evidence supporting $H_A$ we reject the null hypothesis.
  * If there is not sufficient evidence supporting $H_A$ we **fail to reject the null hypothesis**.
  * How do we determine there is *sufficient* evidence?

<!-- page 19 -->

# Hypothesis testing

Can conduct one-sided or two-sided test

* One-sided means that we are testing whether the mean is **<u>either</u>** greater than or less than another quantity.
  * Less common and should always be supported by prior knowledge.
  * $H_0: \mu_1 \ge \mu_2; H_A: \mu_1 < \mu_2$
  * $H_0: \mu_1 \le \mu_2; H_A: \mu_1 > \mu_2$

* Two-sided means that we are testing whether the mean is simply not equal to another quantity.
  * More conservative, generally better practice unless prior evidence, and/or specific question where two-sided doesn't make sense.
  * $H_0: \mu_1 = \mu_2; H_A: \mu_1 \neq \mu_2$

<!-- page 20 -->

# Hypothesis testing

Setting alpha, $\alpha$, and calculating p-values

* $\alpha$ is a standard set by researcher that states how strongly the data must contradict the null hypothesis for it to be rejected.
* $\alpha = 0.05$ is most common, but **this is merely convention**
    * It’s saying we are ok with a 5% chance of identifying an effect (rejecting the null hypothesis) when, in reality, there is no effect.
* We calculate a p-value to assess whether this pre-specified threshold has been met.
    * Specifically, it’s the **<u>probability of seeing a value as or more extreme as what we see in the data</u>**.

<!-- page 21 -->

# P-values and their interpretation

- With $\alpha = 0.05$ p-values $< 0.05$ are often called "significant" – **use this approach with caution**
- How do we interpret p-values correctly?
- If we were to have $p = 0.01$ we would say that **assuming the null hypothesis is true** there is a 1% chance of seeing a value as or more extreme than the value (e.g., mean) from the data.
- It boils down to the probability that we **incorrectly** reject the null hypothesis if the null hypothesis is true.

<!-- page 22 -->

# Confidence intervals

* Related to p-values, but a bit more informative.
* Convention is to use 95% confidence intervals which corresponds to $\alpha = 0.05$, but again, this is arbitrary.
* Follow the general formula of: $\bar{y} - z_{\frac{\alpha}{2}}(\sqrt{\frac{\sigma^2}{n}}), \bar{y} + z_{\frac{\alpha}{2}}(\sqrt{\frac{\sigma^2}{n}})$
* Will be small tweaks to this formula depending on the situation as we will see.

<!-- page 23 -->

# Confidence intervals

* How to interpret 95% CI
* Ex. You estimate the mean wage (per hour) of a sample of employees to be \$25 (95% CI: 20, 30).
* How would you interpret this?

<!-- page 24 -->

# Confidence intervals

* How to interpret 95% CI
* Ex. You estimate the mean wage (per hour) of a sample of employees to be \$25 (95% CI: 20, 30). You would interpret the 95% CI to mean that if you were to take repeated samples of the employees (calculating the sample mean and 95% CI each time) the **true mean wage would be contained in the confidence interval 95% of the time.**

<!-- page 25 -->

# Hypothesis tests for different scenarios

* Single sample - Known $\sigma^2$
* Single sample - Unknown $\sigma^2$
* Two independent samples - Unknown and equal $\sigma^2$
* Two independent samples - Unknown and unequal $\sigma^2$
* Dependent/paired samples - Unknown, unequal $\sigma^2$

<!-- page 26 -->

# Single Sample – Known $\sigma^2$

<!-- page 27 -->

# Single sample known $\sigma^2$

- When we have a continuous variable, $Y$, where we know $\sigma^2$ and we want to compare the mean of $Y$ with specific quantity.
- Can use a one-sample Z test

| Type | $H_0$ | $H_A$ | Rejection Region | Observed $p$-value |
| :--- | :---: | :---: | :---: | :---: |
| Two-sided | $\mu = \mu_0$ | $\mu \neq \mu_0$ | $|z_{obs}| > z_{\alpha/2}$ | $2P(Z > |z_{obs}|)$ |
| One-sided | $\mu \leq \mu_0$ | $\mu > \mu_0$ | $z_{obs} > z_\alpha$ | $P(Z > z_{obs})$ |
| | $\mu \geq \mu_0$ | $\mu < \mu_0$ | $z_{obs} < -z_\alpha$ | $P(Z < z_{obs})$ |

<!-- page 28 -->

# Single Sample – Unknown $\sigma^2$

<!-- page 29 -->

# Hypothesis Testing and Confidence Interval for $\mu$

Since $\sigma^2$ is not known, use estimated variance, $s^2 = \frac{\sum_{i=1}^n (y_i - \hat{\bar{y}})^2}{n-1}$, from a sample instead. Leads to standardized version:

$$
t_{obs} = \frac{\hat{\bar{y}} - \mu}{\sqrt{s^2 n^{-1}}}
$$

which follows a Student’s t-distribution ($\approx$ normal dist.)

Hypothesis testing and confidence interval calculation follow those for variables from normal distribution with known $\sigma^2$.

Same procedures as with z test, but substitute $z_{obs}$ with $t_{obs}$ and $z_{\alpha/2}$ with $t_{(\alpha/2, n-1)}$

<!-- page 30 -->

# Sample variance, $s^2$

$s^2$ is estimated and subject to variance and has its own distribution with

$E(s^2) = \sigma^2$ and $V(s^2) = \frac{2\sigma^4}{n - 1}$, estimated by $\hat{V}(s^2) = \frac{2s^4}{n - 1}$

Under normaility, $(n - 1)\frac{s^2}{\sigma^2} \sim \chi^2_{n-1}$

$$
\Rightarrow 100 \times (1 - \alpha)\% \text{ CI for } \sigma^2 : \left[ \frac{(n - 1)s^2}{\chi^2_{(n-1), \frac{\alpha}{2}}}, \frac{(n - 1)s^2}{\chi^2_{(n-1), 1 - \frac{\alpha}{2}}} \right]
$$

<!-- page 31 -->

# Single sample – Unknown $\sigma^2$ example

* Class A consists of 35 students with an average height 60 inches. You want know whether this differs from the national average for this age group of 55 inches.
* Can use a one-sample t-test to answer this question

```r
dat <- rnorm(35, 60, 1)
t.test(dat, mu = 55)
```

```
    One Sample t-test

data:  dat
t = 36.613, df = 34, p-value < 2.2e-16
alternative hypothesis: true mean is not equal to 55
95 percent confidence interval:
 59.92068 60.49904
sample estimates:
mean of x 
 60.20986 
```

<!-- page 32 -->

# Two Independent Samples – Unknown, Equal Variance

<!-- page 33 -->

# Testing Differences with Unknown, Equal Variance - 1

$$
s_{pooled}^2 = \frac{(n_x - 1)s_x^2 + (n_y - 1)s_y^2}{n_x + n_y - 2}
$$

Under normaility, $(n_x + n_y - 2)\frac{s_{pooled}^2}{\sigma^2} \sim \chi_{n_x+n_y-2}^2$

$$
V(s_{pooled}^2) = \frac{2\sigma^4}{n_x + n_y - 2}
$$

Pooled $t$-statistic:

$$
t_{pooled} = \frac{\bar{x} - \bar{y} - (\mu_x - \mu_y)}{\sqrt{\left(\frac{1}{n_x} + \frac{1}{n_y}\right)s_{pooled}^2}} \sim t_{n_x+n_y-2}
$$

<!-- page 34 -->

# Testing Differences with Unknown Equal Variance - 2

* How do we check if variances are equal?

<!-- page 35 -->

# Testing Equal Variance with F test

**Hypothesis:** $H_0 : \sigma_x^2 = \sigma_y^2$ vs. $H_A : \sigma_x^2 \neq \sigma_y^2$

$$(n_x - 1)\frac{s_x^2}{\sigma_x^2} \sim \chi_{n_x - 1}^2 \text{ and } (n_y - 1)\frac{s_y^2}{\sigma_y^2} \sim \chi_{n_y - 1}^2$$

Test $F$-statistic:

$$F = \frac{s_x^2}{s_y^2} \sim F_{n_y - 1}^{n_x - 1}(\alpha/2)$$

<!-- page 36 -->

# Testing Equal Variance with F test

**Hypothesis:** $H_0: \sigma_x^2 = \sigma_y^2$ vs. $H_A: \sigma_x^2 \neq \sigma_y^2$

$$
(n_x - 1)\frac{s_x^2}{\sigma_x^2} \sim \chi_{n_x-1}^2 \text{ and } (n_y - 1)\frac{s_y^2}{\sigma_y^2} \sim \chi_{n_y-1}^2
$$

Test $F$-statistic: $F = \frac{s_x^2}{s_y^2} \sim F_{n_y-1}^{n_x-1}(\alpha/2)$

If we fail to reject null hypothesis can use pooled variance.

<!-- page 37 -->

# Testing Equal Variance with F test

- Want to compare mean birth weight (in pounds) of full-term babies born in two hospitals.
- Based on the results below, what do you conclude?

```r
hosp1 <- rnorm(200, 7, 2)
hosp2 <- rnorm(300, 6.5, 2)

# Test null hypothesis that variances are equal
var.test(hosp1, hosp2, alternative = "two.sided")
```

```
    F test to compare two variances

data:  hosp1 and hosp2
F = 1.1117, num df = 199, denom df = 299, p-value = 0.4071
alternative hypothesis: true ratio of variances is not
equal to 1
95 percent confidence interval:
 0.8650091 1.4382009
sample estimates:
ratio of variances
          1.111714
```

<!-- page 38 -->

# Testing Equal Variance with F test

* So how do we conduct the appropriate t-test in R?
* What would you conclude based on the results below?

```r
# Use pooled t-test to compare means
t.test(hosp1, hosp2, var.equal=T)
```

```
	Two Sample t-test

data:  hosp1 and hosp2
t = 1.1717, df = 498, p-value = 0.2419
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 -0.1439741  0.5694074
sample estimates:
mean of x mean of y 
 6.824642  6.611925 
```

<!-- page 39 -->

# Two Independent Samples – Unknown, Unequal Variance

<!-- page 40 -->

# Testing Differences with Unknown, Unequal Variance

* What do we do if the variances are not equal?

<!-- page 41 -->

# Testing Differences with Unknown, Unequal Variance

* What do we do if the variances are not equal?

```r
hosp1 <- rnorm(200, 7, 1)
hosp2 <- rnorm(300, 6.5, 2)

# Test null hypothesis that variances are equal
var.test(hosp1, hosp2, alternative = "two.sided")
```

```
    F test to compare two variances

data:  hosp1 and hosp2
F = 0.22174, num df = 199, denom df = 299, p-value < 2.2e-16
alternative hypothesis: true ratio of variances is not equal to 1
95 percent confidence interval:
 0.1725330 0.2868607
sample estimates:
ratio of variances 
         0.2217402
```

<!-- page 42 -->

# Testing Differences with Unknown, Unequal Variance

* What do we do if the variances are not equal?
* How would you interpret the results below?

```r
# Use t-test with var.equal = FALSE to compare means
t.test(hosp1, hosp2, var.equal=F)
```

```
	Welch Two Sample t-test

data:  hosp1 and hosp2
t = 3.5032, df = 455.3, p-value = 0.0005052
alternative hypothesis: true difference in means is not
equal to 0
95 percent confidence interval:
 0.1993302 0.7087255
sample estimates:
mean of x mean of y
 7.078040  6.624013
```

<!-- page 43 -->

# Dependent/Paired Samples – Unknown Unequal Variance

<!-- page 44 -->

# Testing Differences for Dependent Samples

So far, we've discussed comparisons of independent samples, what about dependent or paired (e.g., pre/post) samples?

* Ex. You're testing the impact of a behavioral intervention on depression as measured on a validated scale ranging from 1-20. Participants are evaluated pre and post intervention.

```r
set.seed(894894)
pre <- round(rnorm(30,14,3),0)
post <- round(rnorm(30,10,2),0)

t.test(pre,post, paired=T)
```

```
	Paired t-test

data:  pre and post
t = 7.6364, df = 29, p-value = 2.027e-08
alternative hypothesis: true mean difference is not equal to 0
95 percent confidence interval:
 3.099534 5.367132
sample estimates:
mean difference 
       4.233333 
```

<!-- page 45 -->

# Correlation

<!-- page 46 -->

# Correlation

* Often we are interested in whether 2 variables are linearly related.
* When $x$ increases what happens to $y$?
    * It increases.
    * It decreases.
    * Nothing
    * It varies with the value of $x$
* We can explore this by assessing correlation.
    * Correlation method used depends on assumptions.

<!-- page 47 -->

# Correlation methods and assumptions

* Pearson's correlation is one of the most commonly used correlation methods, but it has several important assumptions.
  * The data are continuous (i.e., not ordinal or categorical)
  * The data are linearly related
  * The data follow a bivariate normal distribution
* Spearman correlation is another commonly used method, but doesn't require the data to follow a bivariate normal distribution. It can also handle monotonic relationships and ordinal data.
* Kendall's tau is another non-parametric method (like Spearman), but is less commonly used and we will not cover it in this class.

<!-- page 48 -->

# Bivariate Normality

<!-- page 49 -->

# Bivariate normality and monotonic relationships

For bivariate normal random variables, $x$ and $y$,

$$
\begin{pmatrix} x \\ y \end{pmatrix} \sim N\left(\begin{pmatrix} \mu_x \\ \mu_y \end{pmatrix}, \begin{pmatrix} \sigma_{xx} & \sigma_{xy} \\ \sigma_{yx} & \sigma_{yy} \end{pmatrix}\right) \Rightarrow \begin{matrix} x \sim N(\mu_x, \sigma_{xx}) \\ y \sim N(\mu_y, \sigma_{yy}) \end{matrix}
$$

Often defined with the correlation coefficient, $\rho_{xy}$, ranging -1 to 1 rather than the covariance, $\sigma_{xy}$, as

$$
\rho_{xy} = \frac{\sigma_{xy}}{\sqrt{\sigma_{xx}\sigma_{yy}}} \text{, estimated with } r_{xy} = \frac{s_{xy}}{\sqrt{s_{xy}s_{yy}}}
$$

**Bivariate normal density, cor = 0**

**Bivariate normal density, cor = 0.75**

<!-- page 50 -->

# Monotonic relationships

Monotonic increasing

Monotonic decreasing

<!-- page 51 -->

# Non-monotonic relationship

Non-monotonic

<!-- page 52 -->

# Hypothesis Testing with Correlation Coefficients

$H_0 : \rho_{xy} = \rho_0$ vs. $H_A : \rho_{xy} \neq \rho_0$ (Usually, $\rho_0 = 0$)

$$
\text{Use } r_{xy} = \frac{s_{xy}}{\sqrt{s_{xx}s_{yy}}} \text{ with } \hat{V}(r_{xy}) \approx \frac{(1 - r_{xy}^2)^2}{n - 3} \text{ under normality}
$$

Fisher's Z-statistic, for the case of $\rho_{xy} \neq 0$:

$$
z_{xy} = \frac{1}{2} \ln \left[ \frac{1 + r_{xy}}{1 - r_{xy}} \right] \approx N \left( \frac{1}{2} \ln \left( \frac{1 + \rho_{xy}}{1 - \rho_{xy}} \right) , \frac{1}{n - 3} \right)
$$

$$
\rightarrow \text{Test-statistic} = \frac{Z_{xy} - z_0}{\frac{1}{\sqrt{n - 3}}}
$$

$$
\rightarrow 100(1 - \alpha)\% \text{CI:} \left[ Z_{xy} - \frac{z_{\alpha/2}}{\sqrt{n - 3}} , Z_{xy} + \frac{z_{\alpha/2}}{\sqrt{n - 3}} \right]
$$

<!-- page 53 -->

# Fisher’s Z and Correlation Coefficients

$$
Z_{xy} = \frac{1}{2} \ln \left[ \frac{1 + r_{xy}}{1 - r_{xy}} \right]
$$

$$
\rightarrow r_{xy} = \frac{e^{2Z_{xy}} - 1}{e^{2Z_{xy}} + 1}
$$

$$
100(1 - \alpha)\%\text{CI of } Z_{xy}\text{: } \left[ z_{xy} - \frac{z_{\alpha/2}}{\sqrt{n - 3}}, z_{xy} + \frac{z_{\alpha/2}}{\sqrt{n - 3}} \right]
$$

$$
\rightarrow 100(1 - \alpha)\%\text{CI of } \rho_{xy}\text{: } \left[ \frac{e^{2z_{xy,Lower}} - 1}{e^{2z_{xy,Lower}} + 1}, \frac{e^{2z_{xy,Upper}} - 1}{e^{2z_{xy,Upper}} + 1} \right]
$$

<!-- page 54 -->

# Test Statistics for Inferences

<!-- page 55 -->

# Test Statistics for Inferences

* When making inferences, are we interested in $y$ or $\mu$?
* What do we need to consider?

After standardization (or studentization), the test statistic for $\bar{y}$ or any linear combination of $\bar{y}$, noted as $f(\bar{y})$, follows:

* $test\ stat = \frac{f(\bar{y}) - a\ value\ tested\ against\ in\ hypothesis}{variability\ in\ f(\bar{y})}$

E.g., $t = \frac{\bar{y} - \mu_0}{SE(\bar{y})} \sim N(0,1)$ under a large $n$

<!-- page 56 -->

# Test Statistic Examples

1. One sample with known variance: $Z = \frac{\bar{y} - \mu_0}{\sqrt{\sigma^2 / n}}$
2. One sample with unknown variance: $t = \frac{\hat{\bar{y}} - \mu}{\sqrt{s^2 n^{-1}}}$
3. Two sample difference with unknown equal variance

$$t_{pooled} = \frac{\bar{x} - \bar{y} - (\mu_x - \mu_y)}{\sqrt{\left(\frac{1}{n_x} + \frac{1}{n_y}\right) s_{pooled}^2}}$$

4. Two sample difference with unknown unequal variance

$$t' = \frac{\bar{x} - \bar{y} - (\mu_x - \mu_y)}{\sqrt{\left(\frac{s_x^2}{n_x} + \frac{s_y^2}{n_y}\right)}}$$

5. Bivariate correlation coefficient
   Use $Z_{xy}$, transformed $r_{xy}$: $Z_{xy} = \frac{Z_{xy} - z_0}{\frac{1}{\sqrt{n - 3}}}$

<!-- page 57 -->

# Testing Normality

<!-- page 58 -->

# Testing Normality – 1

* Easier to assess univariate distribution which is what we will focus on.
* Should do so both statistically and graphically
* Two primary measures that we use:
  * Skewness: Departure from symmetry, $\frac{E(y-\mu)^3}{\sigma^3}$
  * Kurtosis: Peakedness of distribution, $\frac{E(y-\mu)^4}{\sigma^4}$
* Tested through:
  * Q-Q plots with Rankits
  * Shapiro-Wilk Statistic ($W$)

$$W = \frac{\sum_{i=1}^n [(y_{i:n} - \bar{y})(m_{i:n} - \bar{m})]}{\sqrt{\sum_{i=1}^n (y_{i:n} - \bar{y})^2 \sum_{i=1}^n (m_{i:n} - \bar{m})^2}}; \text{ range: } [0,1]$$

  * Tests $H_0$: Random variable $y$ follows a normal distribution
  * S-W test can be quite sensitive, particularly with large sample sizes
  * **<u>Should always include visualization (Q-Q) in normality assessment</u>**

<!-- page 59 -->

# Testing normality – 2

Shapiro-Wilk test of normality

* Tests $H_0$: random variable follows a normal distribution
* Can be quite sensitive, particularly with large sample sizes.
* **Should always assess graphically too**

```r
set.seed(894894)

shapiro.test(rnorm(50))
```

```
	Shapiro-Wilk normality test

data:  rnorm(50)
W = 0.97397, p-value = 0.333
```

```r
shapiro.test(runif(50))
```

```
	Shapiro-Wilk normality test

data:  runif(50)
W = 0.95883, p-value = 0.07944
```

<!-- page 60 -->

# Assessing normality graphically

* Quantile-Quantile (Q-Q) plots are a method we use to compare distributions.
* Here we are using them to assess the normality of a distribution.
* They work by comparing the quantile for each $y_i$ to the computed quantile of a hypothesized distribution (e.g., a normal distribution).
* Can then check whether the data follow this distribution.

<!-- page 61 -->

# Assessing normality graphically – Perfect Normal

<!-- page 62 -->

# Assessing normality graphically – Skewed

**Positive Skewness (n=1000)**

**Positive Skewness (n=1000)**

**Negative Skewness (n=1000)**

**Negative Skewness (n=1000)**

<!-- page 63 -->

# Q-Q/Rankit Plots – Skewness

* AKA “right skewed”
* Distribution has long tail to the right
* mean > median

* AKA “left skewed”
* Distribution has long tail to the left
* mean < median

<!-- page 64 -->

# Assessing normality graphically – Kurtosis

<!-- page 65 -->

# Q-Q/Rankit Plots – Kurtosis

Lighter tails, fewer and/or less extreme outliers

Heavier tails, many and/or more extreme outliers

<!-- page 66 -->

# More detail on Q-Q plots and their interpretation

* <u>Q-Q Plots and Worm Plots from Scratch</u>
    * Takes you through each step of making the plots
* <u>A Q-Q Plot Dissection Kit</u>
    * Q-Q plot examples and discussion of their interpretation

<!-- page 67 -->

# Why might departures from normality cause problems?

<!-- page 68 -->

# Lab session

<!-- page 69 -->

# How do these work when analyzing data?

* Let’s turn to R: “Class2_Lab_nocode.Rmd”
