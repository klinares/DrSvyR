---
id: "jpsm/PracTools_SURV745/lecture_notes"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "lecture_notes"
original: "PracTools_SURV745/lecture_notes.pdf"
pages: 8
sha256: "36b3ba4f5e4c6fc8aea6258caba219f60c01165a69a3e3cc588e31c9b1429178"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:09"
---

<!-- page 1 -->

Practical Tools for Study Design and Inference

1/12/26

* Sample size calculations
    * How big of a sample do we need? Based on desired precision for an estimate.
        * More precise with smaller SE, or confidence interval (CI).
        * Margin of error – MOE, has to do with precision or half of CI.
    * Allocation in stratified sampling
        * Neyman, proportional allocation. Which strata gets what sample size?
    * Cluster sampling – expect less precision.
        * Sample size inflation, we use the design effect.
        * Also think about nonresponse and compensate
    * power calculations, have enough power to detect differences.
* 4 requirements of probability sample look at slide 5 in lecture 1.
    * 1. sample can be defined and possible to obtain
    * 2. each sample has a known probability of being selected
    * 3. every element in the target population has a zero probability of selection
    * 4. weights can be computed from sampling unit towards the target population
* Design based inference assumes there is a repeated sampling done.
    * We say the estimator is unbiased, the distribution of the estimate is determined by the sampling variance since we have a repeated sample.
        * This is different from model-based inference
* Notation
    * $U =$ population of size $N$
    * Population mean $\bar{y}_U$
    * Element variance $= S^2$
        * If a lot of deviations, the numerator is large.
        * Element variance (or Population Variance) measures the spread of individual data points within an entire dataset (population).
    * Population relvariance $= CV^2_U$
        * This is relative to the mean $S^2 / \bar{y}^2_U$
    * Population $CV = CV_U$.
    * Sample estimates
    * $\hat{\theta}$ an estimate of the population, which captures how $\theta$ varies, not $y_i$.
    * Variance $V(\theta)$ with respect to a sample design, and is different from $S^2$. This is the sampling variance, how it varies from sample to sample.
        * Sampling Variance (or Variance of the Estimator) measures how much a statistic (like the sample mean) would vary if you took many different samples from that population,
* Criteria for determining sample size
    * Standard error, coefficient of variation (CV), MOE, $SE(\theta)$.
* Simple random sample without replacement (SRSWOR) is a self-weighting design or selection probability. Inverse weighting.
* CV target
    * solve for $n$:

<!-- page 2 -->

## Sample for $CV$ target

* Estimated mean and total in *srs*
  $$\bar{y}_s = \frac{\sum_{i \in s} y_i}{n}; \qquad \hat{t} = N \bar{y}_s \qquad (3.2)$$
  $V(\hat{t}) = N^2 V(\bar{y}_s)$
  $V(\bar{y}_s) \doteq \frac{S_U^2}{n}$
* Variance of a total in an *srs*
  $$V(\hat{t}) = N^2 \left(1 - \frac{n}{N}\right) \frac{S_U^2}{n} = N \left(\frac{N}{n} - 1\right) S_U^2$$
* Square of the coefficient of variation for $\bar{y}_s$ and $\hat{t}$
  $$CV^2(\bar{y}_s) = \frac{V(\bar{y}_s)}{\bar{y}_s^2} = \left(\frac{1}{n} - \frac{1}{N}\right) \frac{S_U^2}{\bar{y}_s^2} \qquad (3.3)$$
  $\frac{1}{n} \frac{S_U^2}{\bar{y}_s^2} = CV^2 + \frac{1}{N} \frac{S_U^2}{\bar{y}_s^2}$
* Set $CV^2$ (i.e. relvariance) to some desirable value, say $CV_0^2$ (like 0.05), and solve for required sample $n$:
  $$n = \frac{\frac{S_U^2}{\bar{y}_U^2}}{CV_0^2 + \frac{S_U^2}{N \bar{y}_U^2}} \qquad (3.4)$$

* Above t\_hat is the total estimate and variance of a total is N^2 V(\bar{y\_s}
* The CV of any estimate looks like the variance of a squared relvariance, and it has to be known.
* Numerator of n 3.4 is the population relvariance.
  * The larger the population relvariance, n get larger.
  * If CV\_0 get's small, n gets larger.
  * If we want smaller variance, or precision, increase sample size.
  * If denominator gets large, n gets large.

* Set $CV^2$ (i.e. relvariance) to some desirable value, say $CV_0^2$ (like 0.05), and solve for required sample $n$:
  $$n = \frac{\frac{S_U^2}{\bar{y}_U^2}}{CV_0^2 + \frac{S_U^2}{N \bar{y}_U^2}} \qquad (3.4)$$
  * $CV_U^2 \uparrow \longrightarrow n \uparrow$
  * $CV_0^2 \downarrow \longrightarrow n \uparrow$
  * $N \uparrow \longrightarrow n \uparrow$

* If we want to express with variance target.

* Set $CV^2$ (i.e. relvariance) to some desirable value, say $CV_0^2$ (like 0.05), and solve for required sample $n$:
  $$n = \frac{\frac{S_U^2}{\bar{y}_U^2}}{CV_0^2 + \frac{S_U^2}{N \bar{y}_U^2}} \qquad (3.4)$$
  $V_0$
  $CV_0^2 = V_0 / \bar{y}_U^2$

<!-- page 3 -->

* CV^2 and V_0 are related and we can rewrite.
    * Element variance of a proportion is N/N-1 * p(1-p).
* MOE target size denoted as 3

    * Margin of error (MOE). Suppose goal is to be within $e$ of the population mean with probability $1 - \alpha$. Assuming that $\bar{y}_s$ can be treated as being normally distributed, set the half-width of a $100(1 - \alpha)\%$ two-sided CI to $e = z_{1-\alpha/2}\sqrt{V(\bar{y}_s)}$. This translates to
    $$Pr(|\bar{y}_s - \bar{y}_U| \le e) = 1 - \alpha \quad (3.10)$$
    $e = z \times CV \times \bar{y}_s$
    * If we set (i.e., target) the margin of error to $e_0$ above (3.10), then the required sample size is:
    $CV = \frac{e}{z\bar{y}_s}$
    $$n = \frac{z_{1-\alpha/2}^2 S^2}{e_0^2 + z_{1-\alpha/2}^2 S^2 / N} \quad (3.12)$$

* MOE relative to population mean.

    * Margin of error relative to population mean. Assuming that $\bar{y}_s$ can be treated as being normally distributed, set the half-width of a $100(1 - \alpha)\%$ two-sided CI to $e = z_{1-\alpha/2}CV(\bar{y}_s)$. This translates to
    $$Pr\left(\left|\frac{\bar{y}_s - \bar{y}_U}{\bar{y}_U}\right| \le e\right) = 1 - \alpha \quad (3.11)$$
    * If we set the margin of error in (3.11) to $e_0$, then the required sample size is:
    $$n = \frac{z_{1-\alpha/2}^2 S^2 / \bar{y}_U^2}{e_0^2 + z_{1-\alpha/2}^2 S^2 / (N\bar{y}_U^2)} \quad (3.13)$$

* Sample size, stratified simple random sample
    * Divide sample into strata that are mutually exclusive and collectively exhaustive.

        * The estimated mean in a *stsrswor* for the population with $H$ strata is
        $$\bar{y}_{st} = \sum_{h=1}^H W_h \bar{y}_{s_h} \quad (3.18)$$
        * The variance estimator of the stratified sampling is
        $$V(\bar{y}_{st}) = \sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} S_h^2 \quad (3.20),$$
        where $W_h = \frac{N_h}{N}$

* Types of stratum allocation
    * optimal allocation, cost constrained allocation minimizes V(\bar{y}) to a fixed total cost.
        * If we do not have flexibility in the budget.

<!-- page 4 -->

* Minimizing $V(\bar{y}_{st})$ subject to a specified total budget leads to:

$$n_h = (C - c_0) \frac{W_h S_h / \sqrt{c_h}}{\sum_{h=1}^H (W_h S_h \sqrt{c_h})} \qquad (3.21)$$

* C is cost, when you sum all $n_h$ it is the total sample size.
* variance optimal allocation. Minimize total cost subject to fixed target $V(\bar{y})$ or CV.
    * If more flexible on budget and constrained precision.

* If $V(\bar{y}_{st})$ is fixed at $V_0$ and total cost is minimized, allocation to stratum $h$ is

$$n_h = (W_h S_h / \sqrt{c_h}) \frac{\sum_{h=1}^H W_h S_h \sqrt{c_h}}{V_0 + N^{-1} \sum_{h=1}^H W_h S_h^2} \qquad (3.24)$$

* $V_0$ is the CV.

Class 2, Sample sizes: Sampling with Varying Probabilities
* Smaller sampling variance, more efficient estimate. If we use external information that is related to outcome, measure of size (MOS) is extremely efficient in single stage estimates.
    * $p_i$ is the relative size of unit i, MOS is $x_i$, so i is $p_i = x_i / \text{sum}(x_i)$.
    * The selection probability is $\pi_i = n * p_i$
    * The inverse of a sampling probability is the weight.
    * How to find MOS, we use OLS, calculate $\text{residuals}^2$, slope of log is an approximate estimate, all this to estimate gamma and minimize sampling variance.
        * In `practools::gammaFit()`

### Calculations for With-Replacement Sampling - 2

* The variance of $\hat{y}_{pwr}$ in *ppswr* sampling is

$$n = \frac{V_1}{N^2 V(\bar{y}_{pwr})}$$

$$V(\hat{y}_{pwr}) = \frac{1}{N^2 n} \sum_{i \in U} p_i \left( \frac{y_i}{p_i} - t_U \right)^2 \equiv \frac{V_1}{N^2 n} \qquad (3.32)$$

$$CV^2 = \frac{V(\bar{y})}{\bar{y}^2}$$

* We have $n$ in (3.32). So we can solve for this.
* Advantage when computing a sample size is that $n$ is clearly separated from the other terms, unlike in $V(\hat{y}_\pi)$
* If desired coefficient of variation is $CV_0$, solve to give the sample size as

$$\Rightarrow \quad n = \frac{V_1}{N^2} \frac{1}{\bar{y}_U^2 CV_0^2} \qquad (3.33)$$

$$CV^2 = \frac{V(\hat{y}_{pwr})}{\hat{y}_{pwr}} = \frac{1}{}$$

$$\text{20pt } pwr \frac{V_1}{N^2 n} \quad \text{Solve for } n \text{ to get to (3.33)}$$

<!-- page 5 -->

4. Sample Sizes: Sampling with Varying Probabilities $\quad$ 4.2. Accounting for Large Units

### Sample Size with Certainties

$$CV^2 = \frac{V(\bar{y})}{\bar{y}^2}$$

* But the $CV$ of $\hat{\bar{y}}_\pi$ is still computed by dividing by $\bar{y}_U$:

$$CV(\hat{\bar{y}}_\pi) = \frac{N - n_t}{N} \frac{\sqrt{V(\hat{\bar{y}}_{\pi, nt})}}{\bar{y}_U}$$

* To calculate sample size, approximate $V(\hat{\bar{y}}_{\pi, nt})$ by the $pwr$ variance

$$V(\hat{\bar{y}}_{\pi, nt}) \doteq \frac{V_1}{(N - n_t)^2 n}$$

$$(3.32) \text{ p.36} \quad V(\hat{\bar{y}}_{pwr}) = \frac{V_1}{N^2 n}$$

$V_1$ refers only to subuniverse of $N - n_t$ non-(take-alls). The result is $V_1 = 9.53703e + 19$. Sample size formula is

$$n = \frac{V_1}{N^2} \frac{1}{\bar{y}_U^2 CV_0^2} = \frac{9.53703e + 19}{671^2 \times 13,667,706^2 CV_0^2}$$

with $\bar{y}_U = 13,667,706$. For $CV_0 = 0.15$, we get $n = 51$ for the non-(take-alls).

Power analysis and sample size
* alpha we set to .05.
* Power of a test, H_0 Null. Hypothesis testing common in medical studies.
  * Usually at 80%
  * what does power look like if we reduce it
  * Type 1, Null is true, and was rejected (false positive)
    * we find new drug is effective, but it is not
  * Type 2, Null is false, and we did not reject (false negative)
    * new drug is better (but study finds no effect), if sick type 2 might make worse.
* One-sample tests
  * if hypothesis contains one value, mu=3, it is a simple hypothesis.
  * One sided test H_A = mu <3, and two sided, mu \ne 3.

$$H_0 : \mu = \mu_0 \text{ versus } H_A : \mu = \mu_0 + \delta$$

* t statistic inolves difference in mean / variance of y. We use this t to test hypothesis.
* z_1-alpha, critical value, , and z_1-alpha/2 if two sided test.
  * Studentized t, n > 30, approximates normal distribution.
  * Alpha is aP(z_obs > z_1-alpha | H_0=TRUE)
  * type 2, Beta, p(z_obs < z_1-alpha | H_A)

<!-- page 6 -->

$\alpha = Pr(Z_{obs} > z_{1-\alpha} | H_0 \text{ is true})$

$1-\beta : \text{power}$

$\beta = Pr(Z_{obs} \le z_{1-\alpha} | H_A)$

$H_0$

$H_A$

$\mu = \mu_0$

$\mu = \mu_0 + \delta$

$\beta$

$\alpha$

$z_{1-\alpha}$

$Z_{obs}$ in $H_0$ non-rejection region

$Z$

$Z_{obs}$ in $H_0$ rejection region

**Fig. 4.1:** Normal densities of test statistics under $H_0$ and $H_A$, $\delta / \sqrt{V(\hat{\theta})}$ is set equal

* power is 1-beta. What if delta, difference, get’s larger, power goes up.
  * If expected differences are larger, you get greater power.
  * What if two sided, critical value z gets larger, beta gets larger, power goes down.
  * What if variance is flatter, beta gets larger power goes down.
  * Beta and alpha, thus are related.
  * 1 – type 2 error is our power, since 1-beta is power.
  * Requirements for computing power in 1 sample tests
    * power depends on how far away alternative value is from null.
      * 1. value of delta, different
      * desired probability, 1-beta, what is the probability that I can make correct conclusion when hypothesis is true
    * significant level alpha 1 or 2 sided
    * estimate variance of mean (sigma^2 / n) * deff, this is the element variance
  * Effect size, delta / sigma, what does large effect size mean?
  * For n calculation, if variance is large we need larger sample size
    * for type 1 error, smaller alpha means critical value larger, larger n,
    * type 2 error, larger n.
      * smaller delta, larger n.
* differences in mean
  * The sample test statistic is $t_d = \frac{\hat{\bar{d}}}{\sqrt{v(\hat{\bar{d}})}}$
    with $\hat{\bar{d}} = \hat{\bar{y}} - \hat{\bar{x}}$ and $v(\hat{\bar{d}}) = v(\hat{\bar{x}}) + v(\hat{\bar{y}}) - 2\text{cov}(\hat{\bar{x}}, \hat{\bar{y}})$.
* we need to estimate delta
  * if covariance is positive, what happens to the varaince?
    * positive correlation, variance is smaller
    * cov is negative, variance is larger
    * if dependent more efficiency.
* Partially overlapping samples

<!-- page 7 -->

* we can expect these in longitudinal study.
* Differences in proportions
    * assuming independent samples, for power
        * same as means just with proportions.
* Power for complex analysis
    * 1 Simulate data
    * 2 estimate the model
    * 3 check the p values and parameter values
    * 4 iterated over step 1 through 3, and observe p-values
    * 5 power, proportion of p\_calue $< .05$.

Multistage samples
* Variance components – variances coming from different stages.
* PPS probability proportionate to size used a lot in multistage.
    * When the PSUs are similar in size, we can use SRS and not PPS.
* Multistage can be practical and cost efficient when a list of elements is not available. If we have a population registry, we do not need this.
* Cluster sampling selected at the first stage sampling such as schools, geographic regions, but on its own it is not a multistage.
    * PSU (primary sampling unit) first stage unit would be the cluster.
        * Our goal is to sample elements.

1. Introduction

## Notation: Super important!

$srs / srs$

$\pi_i = m / M$

$\pi$

* $U$: universe of PSUs
* $M$: number of PSUs in universe
* $U_i$: universe of elements in PSU $i$
* $N_i$: number of elements in the population for PSU $i$
* $N = \sum_{i \in U} N_i$: total number of elements in the population
* $\pi_i$: selection probability of PSU $i$
* $\pi_{ij}$: joint selection probability of PSUs $i$ and $j$
* $m$: number of sample PSUs
* $n_i$: number of sample elements in PSU $i$
* $s$: set of sample PSUs
* $s_i$: set of sample elements in PSU $i$
* $y_{ik}$: analysis variable for element $k$ in PSU $i$
* $\bar{y}_U$: mean per element in the population
* $\bar{y}_{Ui}$: mean per element in the population in PSU $i$

<!-- page 8 -->

* When does PPS does not make sense, when they are similar in size.

Area sampling - composite measure of size
* 

Composite MOS
- Measure of size
