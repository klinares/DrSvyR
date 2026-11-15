---
id: "jpsm/Fund_Infe_SURV740/lectures/SurvMeth740_Module8_Fall2025"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Fundamentals of Inference"
original: "Fund_Infe_SURV740/lectures/SurvMeth740_Module8_Fall2025.pdf"
pages: 22
sha256: "6b1189802d27ff86852f005cfce08e0093b0fbe48742f637a97a88cb54ae8910"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:04"
---

<!-- page 1 -->

# Fundamentals of Inference

Barry Graubard([email])

SurvMeth / Surv 740

Module 8, Fall 2025

1

<!-- page 2 -->

# Overview

* Design-based framework
  * Some call “randomization inference”

* Inference under this approach
  * Depends on the characteristics of the sample design

* Questions about the framework

2

<!-- page 3 -->

# Review of Design-Based Framework

* Finite Population, Estimand, Design, and Estimation Procedures

$Finite\ Population: Y = \{Y_1, Y_2, \cdots, Y_N\}$

$Estimand: Q(Y_1, Y_2, \cdots, Y_N)$

$Design: \Pr(I_1, I_2, \cdots, I_N)\ is\ the\ joint\ distribution\ of$
$random\ binary\ variables\ (I_1, I_2, \cdots, I_N)$

$The\ sample\ is\ a\ specific\ realization\ of\ (I_1, I_2, \cdots, I_N):$

$i.e., the\ set\ n\ I'_js = 1\ and\ the\ rest\ of\ the\ I'_js = 0$
$corresponds\ to\ the\ sample\ of\ observed\ y = \{y_1, y_2, \cdots, y_n\} \subset Y.$

$Estimating\ Procedure\ (estimator): q(y)$

$Sampling\ distribution\ \text{of}\ q(y)\ is\ the\ distribution\ of$
$\text{the}\ values\ of\ q(y)\ across\ all\ possible\ samples.$

$E(q(y))\ is\ the\ mean\ and\ V(q(y))\ the\ variance\ of$
$the\ sampling\ distribution\ q(y).$

$Desirable\ q(y)\ is\ unbiased\ or\ consistent\ for\ Q(y)\ with\ small\ variance.$

* For a particular sample, apply the estimation procedure:

$$Estimator\ of\ Q(Y)\ is\ q(y)$$

$$Estimator\ V(q(y))\ \text{is}\ \widehat{V}$$

* If the procedure is “desirable”, then what is produced is “desirable”.

3

<!-- page 4 -->

# Large sample properties of the sampling distribution

- Assume that $N$ is **large** and $n$ is **large** but $n/N$ is **small**
  - The design-based approach relies on **asymptotics** (large sample, large population), from Module 7
- For many estimators $q(y)$, the sampling distribution can be approximated as a standard normal distribution

$$\frac{q(y) - E(q(y))}{\sqrt{V(q(y))}} \sim N(0, 1)$$

- A histogram of all possible estimates (collection of $q(y)$ across all possible <u>repeated samples</u> $y = \{y_1, y_2, \cdots, y_n\}$) can be approximated by the density function of a standard normal distribution $N(0, 1)$ (mean 0, variance 1)
- Above $\sim N(0, 1)$ comes from a Central Limit Theorem for sampling from large finite populations with **large** samples.

4

<!-- page 5 -->

# Improve Normal Approximation (Delta method)

* Sometimes the normal approximation can be improved by using a transformation of $q(y)$.

In general, consider a transformation $g(\cdot)$ of $q(y)$, $i.e., g(q(y))$. Need to obtain $Var\left[g\big(q(y)\big)\right]$.

* Taylor expansion of $g(q(y))$ about $q(y) = E[q(y)]$ to derive $Var\left[g\big(q(y)\big)\right]$ and its estimator:

$$
g\big(q(y)\big) = g(E[q(y)]) + \left.\left[\frac{dg(q)}{dq}\right]\right|_{q(y)=E[q(y)]} \times (q(y) - E[q(y)]) + \text{error}
$$

$$
g\big(q(y)\big) \approx g(E[q(y)]) + \left.\left[\frac{dg(q)}{dq}\right]\right|_{q(y)=E[q(y)]} \times (q(y) - E[q(y)])
$$

$$
\left[g\big(q(y)\big) - g(E[q(y)])\right]^2 \approx \left(\left.\left[\frac{dg(q)}{dq}\right]\right|_{q(y)=E[q(y)]}\right)^2 [(q(y) - E[q(y)])]^2
$$

$$
\left[g\big(q(y)\big) - E\big(g[q(y)]\big)\right]^2 \approx \left(\left.\left[\frac{dg(q)}{dq}\right]\right|_{q(y)=E[q(y)]}\right)^2 [(q(y) - E[q(y)])]^2 \text{ , using } E\big(g[q(y)]\big) \approx g(E[q(y)])
$$

$$
E\left[g\big(q(y)\big) - E(g[q(y)])\right]^2 \approx \left(\left.\left[\frac{dg(q)}{dq}\right]\right|_{q(y)=E[q(y)]}\right)^2 E\left[\big((q(y) - E[q(y)])\big]^2\right.
$$

Thus, the $Var\left[g\big(q(y)\big)\right] \approx \left(\left.\left[\frac{dg(q)}{dq}\right]\right|_{q(y)=E[q(y)]}\right)^2 Var\left[q(y)\right]$,

5

<!-- page 6 -->

# Improved Normal Approximation (Delta method) (cont.)

$$Var \left[ g(q(y)) \right] \approx \left( \left. \left[ \frac{dg(q(y))}{d(q(y))} \right] \right|_{q(y)=E[q(y)]} \right)^2 \times V(q(y)), \text{ where } V(q(y)) = Var(q(y))$$

$$\frac{g(q(y)) - g(E[q(y)])}{\left( \left. \left[ \frac{dg(q(y))}{d(q(y))} \right] \right|_{q(y)=E[q(y)]} \right) \times \sqrt{V(q(y))}} \sim N(0,1)$$

<u>*Example*: Consider natural log transformation:</u>

Let $g(q(y)) = log(q(y))$

Since $\left. \left[ \frac{dlog(q(y))}{d(q(y))} \right] \right|_{q(y)=E[q(y)]} = \left. \left[ \frac{1}{q(y)} \right] \right|_{q(y)=E[q(y)]} = \frac{1}{E[q(y)]}$

$$\text{Then } \frac{E(q) \left[ \log(q(y)) - \log(E(q(y))) \right]}{\sqrt{V(q(y))}} \sim N(0,1)$$

6

<!-- page 7 -->

# Interval Estimation

* So far we have focused on the procedures for **point estimation** (to produce a single estimate) of the unknown population quantity, $Q(Y)$
* Most times it might be useful to provide a **range for plausible values of $\boldsymbol{Q(Y)}$**, rather than a single estimate.
* Procedures for creating such intervals: Confidence intervals

  $$Sample: y = \{y_1, y_2, \cdots y_n\}$$

  $$procedure: (q_L(y), q_U(y)); \Pr(q_L(y) \le Q \le q_U(y)) = 1 - \alpha$$

  $$Apply\ to\ a\ particular\ sample: (q_L, q_U)\ is\ 100(1 - \alpha)\%\ confidence\ interval$$

* The procedure guarantees that $100(1-\alpha)\%$ of all possible intervals (across all possible samples) will include $Q(Y)$
* The most efficient interval construction procedure produce the shortest possible intervals

7

<!-- page 8 -->

# Large sample intervals

* Use the aforementioned **large sample** (standard normal) approximation of the sampling distribution
* Consider an unbiased estimation procedure:

$$E(q(y)) = Q(Y)$$

$$\frac{q(y) - Q(Y)}{\sqrt{V(q(y))}} \sim N(0,1)$$

$z$ is such that

$$\Pr\left( -z \le \frac{q(y) - Q(Y)}{\sqrt{V(q(y))}} \le z \right)$$

$$= 1 - \alpha$$

E.g.,
$1 - \alpha = 0.95, z = 1.96$
$1 - \alpha = 0.90, z = 1.64$

$$-z \le \frac{q(y) - Q(Y)}{\sqrt{V(q(y))}} \le z$$

$$\Rightarrow -z\sqrt{V(q(y))} \le q(y) - Q(Y) \le z\sqrt{V(q(y))}$$

$$\Rightarrow q(y) - z\sqrt{V(q(y))} \le Q(Y) \le q(y) + z\sqrt{V(q(y))}$$

$$\approx (q_L = q(y) - z\sqrt{\widehat{V}}, q_U = q(y) + z\sqrt{\widehat{V}})$$

**Interpretation:** For z = 1.96, 95% of the intervals from all possible samples will include the estimand of interest, $Q(Y)$.

<!-- page 9 -->

# For a particular sample

- Assume $z = 1.96$
- Get upper and lower 95% confidence limits: $(q_L, q_U)$
- This is **only one** of the possible confidence intervals as they change with differing samples. It could be one of the approximately 95% of the intervals that includes the estimand $Q(Y)$ or it could be one of the approximately 5% intervals that excludes the estimand $Q(Y)$
- Choose $z$ so that you have sufficient confidence that $(q_L, q_U)$ is a range of plausible values of the estimand $Q(Y)$.

9

<!-- page 10 -->

# Example

* A finite population of a geographical area of a city consists of $N=270$ blocks and a simple random sample (wor) of $n=20$ blocks is selected.
    * Goal: Estimate mean no. of housing units **renting** in each block for the finite population $Q(Y) = \bar{Y}$
    * Data for sampled blocks: 3, 5, 5, 52, 21, 34, 3, 0, 0, 0, 17, 14, 0, 0, 2, 54, 11, 11, 0, 23.
    * Sample mean, $q(y) = \bar{y} = 255/20 = 12.75$ rentals per block
* Unbiased estimate of the finite population variance, $S^2 = \sum_{i=1}^N (Y_i - \bar{Y})^2 / (N - 1)$ is:

$$s^2 = \sum_{i=1}^n (y_i - \bar{y})^2 / (n - 1) = 278.62$$

* Estimated sampling variance of $\bar{y}$ is

$$\hat{V} = (1-20/270) \times s^2/20 = 12.90$$

* Standard error of $\bar{y}$ is $\sqrt{\hat{V}} = \sqrt{12.90} = 3.59$
* 95% confidence interval: $(12.75 - 1.96 \times 3.59, 12.75 + 1.96 \times 3.59) = (5.71, 19.79)$
* **Inference:** For $\alpha = 0.05$ (a 95% confidence interval), you would “reject” any hypotheses suggesting that the mean is outside of the confidence interval $(5.71, 19.79)$

10

<!-- page 11 -->

# Inference about population proportions

* Suppose that the survey variable, $Y$, is a binary or “dummy” variable.
* Example (from previous slide): **Whether or not a block has <u>any</u> rental dwelling units**
* **Estimand:** Population proportion of blocks with **no** rental units

$Q(Y) = \sum_{j=1}^N Y_j / N$, where $Y_j = 1$ if block $j=1,2, \dots, N$ has no rental units, and $0$ otherwise

* **Design:** Simple random sample (wor) of size $n$

*Estimating Procedure:*

$$q(y) = \sum_{i=1}^n y_i / n$$

*Variance estimator of $q(y)$*

$$\hat{V} = (1 - f)q(y)(1 - q(y))/(n - 1),$$

$$f = n/N$$

95% Confidence interval:

$$(q - 1.96 \times \sqrt{\hat{V}}, q + 1.96 \times \sqrt{\hat{V}})$$

Computing 95% Confidence Interval:

$$q(y) = 6/20 = 0.3$$

$$\hat{V} = (1 - 20/270) \times (0.3 \times 0.7)/19 = 0.0102$$

$$SE = \sqrt{\hat{V}} = 0.1$$

95% Confidence Interval:

$$0.3 \pm 1.96 \times 0.1 = (0.1, 0.5)$$

11

<!-- page 12 -->

# Alternative approaches for constructing confidence intervals for proportions

* Transformation can improve the normal approximation
  Two popular transformations for proportions:

$Q(y) = Population\ proportion$

$q(y) = sample\ proportion$

$V = sampling\ variance\ of\ q(y)$

$n = sample\ size$

$N = population\ size$

$f = n/N$

### Arcsine-square root transformation

$$\sin^{-1}\sqrt{q(y)} \sim N(\sin^{-1}\sqrt{Q(y)}, (1 - f)/(4n))$$

### Logit transformation

$$\log \frac{q(y)}{1 - q(y)} \sim N(\log \frac{Q(y)}{1 - Q(y)}, \frac{V}{[Q(y)(1 - Q(y))]^2})$$

* Compute the confidence interval on the transformed scale, and then re-transform to the original scale
* See Franco et al. (2019) on Canvas for other methods

12

<!-- page 13 -->

# Example

* Proportion of blocks with no rental units

$$q(y) = 6/20 = 0.3$$

$$\sin^{-1}\sqrt{0.3} = 0.5796 \text{ radians}$$

$$\text{Estimated sampling variance } (1 - f)/(4n) = 0.9259/80 = 0.0116$$

$$95\% \text{ confidence interval for } \sin^{-1}\sqrt{Q(Y)}$$
$$(0.5796 - 1.96 \times \sqrt{0.0116}, 0.5796 + 1.96 \times \sqrt{0.0116})$$
$$= (0.3685, 0.7907)$$

$$95\% \text{ confidence interval for } Q(Y)$$
$$= ([\sin(0.3685)]^2, [\sin(0.7907)]^2)$$
$$= (0.13, 0.51)$$

**Homework Exercise:**

**Compute a 95% confidence interval for $Q(y)$ using the log-odds (logit) transformation.**

13

<!-- page 14 -->

# Statistical Significance

* **Restate the problem as a test of a hypothesis:** Municipality wants to know whether the average number of rentals per block $> 10$?
  * This is the cutoff for a government subsidy of rent
* Thus, the claim or hypothesis is that the average rental unit per block is $> 10$.
  * *How do we test this claim statistically?*
* Two approaches
  * Construct confidence interval with a specific level of confidence and check whether the hypothesized value is contained in the interval
    * In the example, 95% confidence interval (slide 10) is (5.71, 19.79) which includes 10.
  * Set it up as significance test of the null hypothesis: $H_0: \bar{Y} \le 10$ vs. alternative hypothesis $H_A: \bar{Y} > 10$

14

<!-- page 15 -->

# Significance Testing

* Example

$Testing\ H_0 : \bar{Y} \le 10\text{ vs. }H_A : \bar{Y} > 10$

$For\ the\ boundary\ point, \bar{Y} = 10\text{:}$

$$Z = \frac{q(y) - 10}{\sqrt{V(q(y))}} \approx \frac{q(y) - 10}{\sqrt{\widehat{V}}} \sim N(0,1)$$

$For\ the\ particular\ sample$

$$\frac{12.75 - 10}{\sqrt{12.90}} = 0.77$$

## Interpretation:

(1) Values of Z that are higher than 0.77 is favorable to $H_0 : \bar{Y} \le 10$.

(2) $\text{Pr(Z} > 0.77 | H_0) = 0.24$ (p-value)

(3) Since 0.24 is not that “small”, i.e., $< 0.05$ (cannot reject $H_0$).

15

<!-- page 16 -->

# Sample Size Determination for Proportions

* How many units should be sampled?
* One approach is to specify the acceptable sampling variance
* Consider inference about proportions:

$$
V = \frac{(1 - f)Q(Y)(1 - Q(Y))}{n - 1}
$$

$$
V_{\max} = Maximum(V) = \frac{(1 - f) \times \frac{1}{4}}{n - 1} \text{ (why the } \frac{1}{4}\text{?)}
$$

$$
Goal\ is\ to\ choose\ n\ so\ that\ V_{\max} \le c
$$

16

<!-- page 17 -->

# Sample Size Determination for Means

* Simple random sample, sampling variance:

$$V = (1 - f)\sigma^2/n$$

$$Let\ V \le c\ then$$

$$n \ge \frac{1}{\frac{1}{N} + \frac{c}{\sigma^2}} \approx \frac{\sigma^2}{c}, \sigma^2 \text{is population of } Y$$

* Need an estimate of $\sigma^2$ from a sample of a pilot or previous study.

17

<!-- page 18 -->

# Design Effects

* Often, sample designs are more complex than SRS, involving stratification, weighting, and clustering.
  * **Stratification**, generally, decreases the sampling variance
  * **Clustering** increases the sampling variance because of correlation of sampling indicators
  * **Weighting** may increase or decrease the sampling variance, depending upon correlation between weights and survey variables $y$

* The effect of a complex sample design on the variance of an estimate is measured using the **design effect** concept
* **Effective Sample Size:** size of an SRS that would give you the same precision

$$n = sample\ size$$

$$V_A = Actual\ Sampling\ variance$$
$$(under\ the\ complex\ sample\ design)$$

$$V_{SRS} = SRS\ sampling\ variance\ (the\ same$$
$$sample\ size)$$

$$deff = \frac{V_A}{V_{SRS}}$$

$$Effective\ sample\ size, n^* = n/deff$$

18

<!-- page 19 -->

# Design Effects (Contd.)

* Simple Approximations
  * For Clustering:

$$
c = \text{number of clusters sampled}
$$

$$
k = \text{Average number of units sampled per cluster}
$$

$$
n = ck, \text{ number of observations.}
$$

$$
\rho = \text{Intraclass correlation coefficient}
$$
$$
(\text{Correlation of variable } y \text{ between pairs of observations in the same cluster})
$$

$$
\frac{V_{cluster}}{V_{SRS}} = deff_{cluster} = 1 + (k - 1)\rho
$$

(Why $k - 1$?)

19

<!-- page 20 -->

# Design Effects (Contd.)

* Simple $deff$ approximation for sample weighting (a.k.a. “<u>U</u>nequal <u>W</u>eighting <u>E</u>ffect” or UWE)

$$\bar{w} = mean\ of\ weights, \frac{1}{n} \sum_{i=1}^{n} w_i$$

$$s_w = standard\ deviation\ of\ weights, \sqrt{\frac{1}{n-1} \sum_{i=1}^{n} (w_i - \bar{w})^2}$$

$$c = s_w / \bar{w} \ ,\ the\ coefficient\ of\ variation\ of\ the\ weights$$

$$deff_{weight} = 1 + c^2$$

* **NOTE:** UWE assumes stratified sampling, independence of weights and key variables, and is an **upper bound**

* For planning purposes:
  * Develop the sample size for a simple random sample design
  * Inflate it by the design effects (see the Effective Sample Size, $n^*$, definition):

$$n^* = deff_{weight} \times deff_{cluster} \times n_{SRS}$$

20

<!-- page 21 -->

# Questions to Ponder that relate Design-Based Inference

* What if an analyst is working with data from a complex sample, and **<u>ignores</u>** the weighting, stratification, and cluster sampling in the estimation procedures?
  * Will 95% confidence intervals have the level of coverage of the true population parameter that they claim?
* What role does **sample stratification** play in sample size calculations? These simple design effect approximations only speak for weighting and cluster sampling.
* Do all intervals need to be 95% confidence intervals when using the design-based approach?
* What if we don’t have large samples (or populations!) and we can’t rely on the central limit theorem?

21

<!-- page 22 -->

# Questions to Ponder that relate Bayesian Modeling

* Design-based approach uses the properties of estimation and inference procedures <u>across all possible samples</u> to select a procedure and then applies that procedure to a sample at hand.
  * If the procedure is “good” then does it imply the result from applying that procedure to one particular sample is also “good”?
* I only have one sample. Why is it important or even relevant to consider all possible samples that I could have observed, but did not, when drawing inferences based on the sample in hand?
* There are two parts of the finite population: The sample I observe is what I know and the rest of the finite population is what I don’t know.
  * Shouldn’t the inference be conditional probability statements like, $\textit{Pr(What I don't know} \mid \textit{What I know)}$?

22
