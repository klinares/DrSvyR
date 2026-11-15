---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_4"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 4.pdf"
pages: 35
sha256: "0d273a760c82493b68142a69b749c34f15188558f60b85ba3ba6525853a1ed5a"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:16"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference
## Chapter 4. Power Calculations and Sample Size Determination

Sunghee Lee

---

Sunghee Lee (U of Michigan) &emsp;&emsp; Prac Tools Ch. 4 &emsp;&emsp; 1 / 35

<!-- page 2 -->

# Outline

1. 1. Background Ideas
2. 2. One-Sample Tests
3. 3. Differences in Means
   - 3.1 Independent or Overlapping Samples
   - 3.2 Partially Overlapping Samples
4. 4. Differences in Proportions
   - 4.1 Independent Sample
   - 4.2 Overlapping Samples
5. Special: Simulation-Based Power Analysis

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 2 / 35

<!-- page 3 -->

1. Background Ideas

# 1. Background Ideas

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 3 / 35

<!-- page 4 -->

1. Background Ideas

# Power of a Test

- Power is relevant to hypothesis testing
  How likely is an alternative value or a difference to be detected?
- E.g., $H_0 : \mu = 1000$; $H_0 : \mu_F = \mu_M$; $H_0 : \beta_1 = 0$
- Common in medical and health studies. Setting desired power = $0.80$ or $0.90$ is typical.

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 4 $\quad$ 4 / 35

<!-- page 5 -->

1. Background Ideas

# Table 4.1: Terminology - Size and Power of a Test

**Table 4.1:** Terminology: size and power of a test

Decision

| State of nature | | Do not reject $H_0$ | Reject $H_0$ |
| :--- | :---: | :--- | :--- |
| | $H_0$ is true | Correct decision with probability $1 - \alpha$ | Type I error—incorrect decision with probability $\alpha$ (*level* or *size* of test) |
| | $H_0$ is false ($H_A$ is true) | Type II error—incorrect decision with probability $\beta$ (at a specific alternative value) | Correct decision with probability $1 - \beta$ (*power* of test at a specific alternative value) |

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 5 / 35

<!-- page 6 -->

2. One-Sample Tests

# 2. One-Sample Tests

Sunghee Lee (U of Michigan)

Prac Tools Ch. 4

<!-- page 7 -->

2. One-Sample Tests

# Characterizing Hypotheses and Tests

* Hypotheses can be simple or composite.
* Tests can be characterized as one-sided or two-sided.
* When a hypothesis contains only one value, it is called simple (e.g., $H_0 : \mu = 3$)
* A hypothesis that contains more than one value is composite (e.g., $H_0 : \mu \le 3$)
* Whether a test is one- or two-sided depends on the alternative. If the null hypothesis is $H_0 : \mu = 3$, a one-sided alternative is $H_A : \mu < 3$ or $H_A : \mu > 3$, because the alternative values of interest are only in one direction from the null value.

  A two-sided alternative would be $H_A : \mu \ne 3$ since the alternatives can be either greater or less than $H_0 : \mu = 3$. The alternative, $H_A : \mu \ne 3$, is also composite, because it involves many values.

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 7 / 35

<!-- page 8 -->

2. One-Sample Tests

# One-Sample Tests

* A single mean is tested against some hypothesized value(s) as

  $H_0 : \mu = \mu_0$ versus $H_A : \mu = \mu_0 + \delta$

  at level $\alpha$ for some $\delta$ that can be positive or negative.

* Usually, we think of testing the simple $H_0$ vs the composite $H_A$:

  $H_0 : \mu = \mu_0$ versus $H_A : \mu \neq \mu_0$

* The standard test statistic:

  $$t = \frac{\hat{\bar{y}} - \mu_0}{\sqrt{v(\hat{\bar{y}})}}, \text{ where } \hat{\bar{y}} = \frac{\sum_{i \in s} w_i y_i}{\sum_{i \in s} w_i} \text{ and } w_i \text{ is the survey weight.}$$

* The $t$-statistic is referred to a normal distribution (or $t$). Validity depends on large sample approximation.

* The estimator of the variance of the mean needs to be consistent.

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 8 / 35

<!-- page 9 -->

2. One-Sample Tests

# Figure 4.1: Size and Power of a One-sided Test

**Fig. 4.1:** Normal densities of test statistics under $H_0$ and $H_A$. $\delta \Big/ \sqrt{V(\hat{y})}$ is set equal to 3 in this illustration so that $E\{t|H_A \text{ is true}\} = 3$. A 1-sided test is conducted at the 0.05 level

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 9 / 35

*[Figure: The plot illustrates the size and power of a one-sided statistical test by comparing two overlapping normal distribution curves representing the null hypothesis ($H_0$, centered at 0) and the alternative hypothesis ($H_A$, centered at 3), with test statistic $Z$ on the horizontal axis (ranging from -2 to 6) and probability density on the vertical axis (ranging from 0.0 to 0.4). A critical value $Z_{1-\alpha}$ divides the horizontal axis into non-rejection and rejection regions, with shaded areas under the curves indicating the Type I error rate ($\alpha$, red horizontal stripes), Type II error rate ($\beta$, blue vertical stripes), and statistical power (solid gray shading under $H_A$).]*

<!-- page 10 -->

2. One-Sample Tests

# Sample Size Calculations for Specified Power

* For a 1-sided test of $H_0 : \mu = \mu_0$ versus $H_A : \mu = \mu_0 + \delta$, the Type II error rate is $Pr(t \le t_{1-\alpha}(df)|H_A \text{ is true}) = \beta$.
  To actually compute $\beta$, we must think of a specific value within the possibilities spanned by $H_A$.
* Power is $1 - \beta$ (i.e., 1-Type II error rate):
  $Pr(t > t_{1-\alpha}(df)|H_A \text{ is true})$, the probability of correctly rejecting $H_0$ when it actually is false. The power and Type II error rate vary depending on the particular value of the alternative.
* For a 1-sided test of $H_0 : \mu = \mu_0$ versus $H_A : \mu > \mu_0$, the power is $Pr(t > t_{1-\alpha}(df)|\mu = \mu_0 + \delta) = 1 - \beta$.
* For a 2-sided test of $H_0 : \mu = \mu_0$ versus $H_A : \mu \ne \mu_0$, the power is $Pr(|t| > t_{1-\alpha/2}(df)|\mu = \mu_0 + \delta) = 1 - \beta$
  i.e., the chance that the test statistic is in the rejectin region when $\mu = \mu_0 + \delta$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 10 / 35

<!-- page 11 -->

2. One-Sample Tests

# Requirements for Computing Power for One Sample Tests

* The power for a given sample size depends on how far away the alternative value, $\mu_0 + \delta$, is from the null value, $\mu_0$. Four things are needed for a sample size calculation based on power:
  1. Value of $\delta$
  2. Desired probability $1 - \beta$ (i.e., the power; $Pr(t > t_{1-\alpha}(df) | H_A : \mu = \mu_0 + \delta)$) of obtaining a significant test result when the true difference is $\delta$; and
  3. Significance level $\alpha$ of the test, which can be either 1-sided or 2-sided.
  4. Estimate of variance of the estimated mean. Translation may be needed to go from $v(\hat{\bar{y}})$ to $(\sigma^2/n) \times \text{deff}$ so that $n$ is exposed.

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 11 / 35

<!-- page 12 -->

2. One-Sample Tests

# Sample Size Calculation - 1

- One-sided test

$$
\begin{aligned}
Pr(t > t_{1-\alpha}(df) | \mu = \mu_0 + \delta) \\
&= Pr\left(t - \frac{\delta}{\sqrt{V(\hat{\bar{y}})}} > t_{1-\alpha}(df) - \frac{\delta}{\sqrt{V(\hat{\bar{y}})}} \middle| \mu = \mu_0 + \delta\right) \\
&= Pr\left(\frac{\hat{\bar{y}} - \mu_0}{\sqrt{v(\hat{\bar{y}})}} - \frac{\delta}{\sqrt{V(\hat{\bar{y}})}} > t_{1-\alpha}(df) - \frac{\delta}{\sqrt{V(\hat{\bar{y}})}} \middle| \mu = \mu_0 + \delta\right) \\
&\doteq Pr\left(Z_{obs} > z_{1-\alpha} - \frac{\delta}{\sqrt{V(\hat{\bar{y}})}}\right) = 1 - \beta \qquad (4.4)
\end{aligned}
$$

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 4 $\qquad$ 12 / 35

<!-- page 13 -->

2. One-Sample Tests

# Sample Size Calculation - 2

* By setting $z_{1-\alpha} - \frac{\delta}{\sqrt{V(\hat{\bar{y}})}} = z_\beta$ with $V(\hat{\bar{y}}) = \frac{\sigma_y^2}{n}$,
  we solve for $n$:

$$n = \left[ \sigma_y \frac{z_{1-\alpha} - z_\beta}{\delta} \right]^2 = \left[ \sigma_y \frac{z_{1-\alpha} + z_{1-\beta}}{\delta} \right]^2 \qquad (4.5)$$

through $z_{1-\alpha} - \frac{\delta\sqrt{n}}{\sigma_y} = z_\beta$

$$\frac{\delta\sqrt{n}}{\sigma_y} = z_{1-\alpha} - z_\beta$$

and $z_\beta = -z_{1-\beta}$

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 13 / 35

<!-- page 14 -->

2. One-Sample Tests

# Sample Size Calculation - 3

* One-sided test

$$
n = \left[ \sigma_y \frac{z_{1-\alpha} - z_\beta}{\delta} \right]^2 = \left[ \sigma_y \frac{z_{1-\alpha} + z_{1-\beta}}{\delta} \right]^2 \qquad (4.5)
$$

* Two-sided test

$$
n = \left[ \sigma_y \frac{z_{1-\alpha/2} - z_\beta}{\delta} \right]^2 = \left[ \sigma_y \frac{z_{1-\alpha/2} + z_{1-\beta}}{\delta} \right]^2 \qquad (4.9)
$$

* $\dfrac{\delta}{\sigma}$ is also known as Effect Size (in one-sample test)
* What does a large effect size mean?

**See VDK Examples 4.1 and 4.4 in Class3Lab.pdf**

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 4 $\qquad$ 14 / 35

<!-- page 15 -->

3. Differences in Means

# 3. Differences in Means

Sunghee Lee (U of Michigan)

Prac Tools Ch. 4

<!-- page 16 -->

3. Differences in Means 3.1 Independent or Overlapping Samples

# 3.1 Independent or Overlapping Samples

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 16 / 35

<!-- page 17 -->

3. Differences in Means 3.1 Independent or Overlapping Samples

# Differences in Means

- Compare means of two different groups of units. The term "two sample" test stems from the aim of comparing parameters for two separate groups or populations with a sample being selected from each.
- For a two-sample case (groups $X$ and $Y$), we may want to test
$$H_0 : \mu_X \le \mu_Y \text{ versus } H_A : \mu_X > \mu_Y$$
at level $\alpha$.
- The sample test statistic is $t_d = \frac{\hat{\bar{d}}}{\sqrt{v(\hat{\bar{d}})}}$
with $\hat{\bar{d}} = \hat{\bar{y}} - \hat{\bar{x}}$ and $v(\hat{\bar{d}}) = v(\hat{\bar{x}}) + v(\hat{\bar{y}}) - 2\text{cov}(\hat{\bar{x}}, \hat{\bar{y}})$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 17 / 35

<!-- page 18 -->

3. Differences in Means 3.1 Independent or Overlapping Samples

# Differences in Means: Power

The null hypothesis that the mean of $Y$ is larger than or equal to the mean of $X$ ($H_0 : \mu_X \le \mu_Y$) will be rejected in large samples if $t_d > z_{1-\alpha}$. If the true mean difference is $|\delta| > 0$, then the mean of $t_d$ is $\frac{\delta}{\sqrt{V(\hat{\bar{d}})}}$ instead of 0.

Letting $\mu_D = \mu_X - \mu_Y$, the probability of $t_d$ in the rejection region is:

$$
\begin{aligned}
Pr\{t_d > z_{1-\alpha} | \mu_D = \delta\} &= Pr\left(t_d - \frac{\delta}{\sqrt{V(\hat{\bar{d}})}} > z_{1-\alpha} - \frac{\delta}{\sqrt{V(\hat{\bar{d}})}} \bigg| \mu_D = \delta\right) \\
&\doteq Pr\left(Z > z_{1-\alpha} - \frac{\delta}{\sqrt{V(\hat{\bar{d}})}}\right) \\
&= 1 - \beta \qquad (4.10)
\end{aligned}
$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 18 / 35

<!-- page 19 -->

3. Differences in Means 3.1 Independent or Overlapping Samples

# Differences in Means: Variance

* Suppose sample size in each domain is the same and that the variance of the difference can be written as $V(\hat{\bar{d}}) = \frac{\sigma_d^2}{n}$ where $\sigma_d^2$ is some population unit variance of the difference.
* With $srswor$, if the domain estimates are independent and their variances can be written as
$$V(\hat{\bar{d}}) = \frac{\sigma_d^2}{n} = \frac{\sigma_x^2}{n} + \frac{\sigma_y^2}{n} = \frac{1}{n} [\sigma_x^2 + \sigma_y^2].$$
* If the domain estimates are correlated, then $\sigma_d^2 = \sigma_x^2 + \sigma_y^2 - 2\sigma_{xy}$
$$V(\hat{\bar{d}}) = \frac{\sigma_d^2}{n} = \frac{1}{n} [\sigma_x^2 + \sigma_y^2 - 2\sigma_{xy}].$$
* If $\sigma_x^2 = \sigma_y^2 \equiv \sigma_0^2$, then the unit-level correlation between $y$ and $x$ is $\rho = \sigma_{xy} / \sigma_0^2$ and $\sigma_d^2 = 2\sigma_0^2(1 - \rho)$ leading to
$$V(\hat{\bar{d}}) = \frac{\sigma_d^2}{n} = \frac{2\sigma_0^2(1 - \rho)}{n}.$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 19 / 35

<!-- page 20 -->

3. Differences in Means 3.1 Independent or Overlapping Samples

# Sample Sizes for Testing Difference in Means

* To find the required sample size, we set $z_\beta$ equal to $z_{1-\alpha} - \frac{\delta}{\sqrt{\sigma_d^2 / n}}$ and solve for the sample size $n$ to obtain
$$n = \left[ \sigma_d \frac{(z_{1-\alpha} - z_\beta)}{\delta} \right]^2 \quad (4.11)$$
* Note that this is the sample size in **each** domain.
* If $\sigma_x^2 = \sigma_y^2 \equiv \sigma_0^2$ and $\rho = 0$ then $\sigma_d^2 = 2\sigma_0^2$.
* Compare (4.11) with (4.5)
* How about $n$ for two-sided tests (i.e., $H_0 : \mu_X = \mu_Y$ versus $H_A : \mu_X \neq \mu_Y$)?
10pt]
* Use `power.t.test` with `type=c("two.sample")`

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 20 / 35

<!-- page 21 -->

3. Differences in Means 3.1 Independent or Overlapping Samples

# Two-Sided Test; Fig 4.4

**Fig. 4.4:** Power for sample sizes of $n = 10, 25, 50, 100$ in a two-sided test of $H_0 : \mu_D = 0$ versus $H_A : |\mu_D| = \delta$ ($\alpha = 0.05, \sigma_d = 3$)

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 21 / 35

*[Figure: The line graph displays the statistical power (on the vertical axis, ranging from 0.2 to 1.0) of a two-sided test plotted against the effect size, Delta (on the horizontal axis, ranging from -4 to 4), comparing four different sample sizes ($n = 10, 25, 50,$ and $100$). All four curves form symmetrical U-shapes centered at a minimum power of 0.05 when Delta is 0, showing that power increases toward 1.0 as the absolute value of Delta increases, and rises much more steeply for larger sample sizes.]*

<!-- page 22 -->

3. Differences in Means 3.2 Partially Overlapping Samples

# 3.2 Partially Overlapping Samples

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 22 / 35

<!-- page 23 -->

3. Differences in Means 3.2 Partially Overlapping Samples

# Partially Overlapping Samples

- Persons may be surveyed at baseline and then followed-up at a later time.
- Example: initial sample of $n_1$ is selected, a portion of these respond at time 2, and additional units are selected to obtain a total sample of $n_2$ for time 2.
- An estimate of the difference in population means may be desired, but the samples do not overlap completely because of dropouts, planned sample rotation, or nonresponse.
- Suppose $s_1$ and $s_2$ are sets of sample units with data collected only at times 1 and 2, and $s_{12}$ denotes the overlap. Thus, the full samples at times 1 and 2 are $s_1 \cup s_{12}$ and $s_2 \cup s_{12}$.
- Assume that the samples at the two time periods are $srs$.
- Also assume that samples at times 1 and 2 are not necessarily the same size as $n_1 = rn_2$. The samples might be different sizes because of survey goal or data collection budget changes.

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 23 / 35

<!-- page 24 -->

3. Differences in Means 3.2 Partially Overlapping Samples

# Difference and Its Variance

- Under $srs$, difference in means can be written as
  $$\hat{\bar{d}} = \hat{\bar{x}} - \hat{\bar{y}} = \frac{1}{n_1} \sum_{s_1} x_i - \frac{1}{n_2} \sum_{s_2} y_i + \sum_{s_{12}} \left( \frac{x_i}{n_1} - \frac{y_i}{n_2} \right)$$
- The variance can be expressed as
  $$V(\hat{\bar{d}}) = \frac{\sigma_x^2}{n_1} + \frac{\sigma_y^2}{n_2} - 2\sigma_{xy}\frac{n_{12}}{n_1 n_2} \qquad (4.12)$$
  With $n_{12} = \gamma n_1$ (i.e., $\gamma$: the proportion of overlap) and $r = n_1/n_2$,
  $$V(\hat{\bar{d}}) = \frac{1}{n_1} \left[ \sigma_x^2 + r\sigma_y^2 - 2\gamma r \sigma_{xy} \right]$$
- For a 1-sided test of $H_0 : \mu_D = 0$ versus $H_A : \mu_D = \delta$, $\alpha$ level test, power$= 1 - \beta$, the sample size $n_1$ is
  $$n_1 = \frac{1}{\delta^2} \left[ \sigma_x^2 + r\sigma_y^2 - 2\gamma r \rho \sigma_x \sigma_y \right] (z_{1-\alpha} - z_\beta)^2 \qquad (4.13)$$
- No specific functions for partially overlapping sample tests in power analysis packages. Instead, use `nDep2sam` in `PracTools`.

**See VDK Example 4.7 in Class3Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 24 / 35

<!-- page 25 -->

4. Differences in Proportions

# 4. Differences in Proportions

Sunghee Lee (U of Michigan)
Prac Tools Ch. 4

<!-- page 26 -->

4. Differences in Proportions   4.1 Independent Sample

# 4.1 Independent Sample

Sunghee Lee (U of Michigan)   Prac Tools Ch. 4   26 / 35

<!-- page 27 -->

4. Differences in Proportions
4.1 Independent Sample

# Test Statistic - 1

* Test hypothesis $H_0 : P_1 = P_2$ where $P_k$ is the population proportion in domain $k$.
* Assume independent *srs*'s are selected from each domain at $n_1$ and $n_2$; estimated proportions are $p_1$ and $p_2$.
* If $H_0$ is true, $P_1 = P_2 = \bar{P}$. Variance of the difference is $V(p_1 - p_2) = \bar{P}(1 - \bar{P}) \left( \frac{1}{n_1} + \frac{1}{n_2} \right)$
* Test statistic is then:
  $$t_{\Delta p} = \frac{p_1 - p_2}{\sqrt{v(p_1 - p_2)}} \quad (4.16),$$
  where $v(p_1 - p_2) = \bar{p}(1 - \bar{p}) \left( \frac{1}{n_1} + \frac{1}{n_2} \right)$ and $\bar{p} = \frac{n_1 p_1 + n_2 p_2}{n_1 + n_2}$ is a 'pooled' estimate of $\bar{P}$
* In large samples, $t_{\Delta p}$ is approximately normally distributed.

Sunghee Lee (U of Michigan)
Prac Tools Ch. 4

<!-- page 28 -->

4. Differences in Proportions 4.1 Independent Sample

# Test Statistic - 2

- Because variance of estimated proportions depends on their means, the arithmetic needed to get a power formula is a little different. Cover only the case of the same sample size $n$ in each group (i.e., $n_1 = n_2 = n$).
- If the null hypothesis of equal proportions is true (i.e., $P_1 = P_2 = \bar{P}$), then

$$v(p_1 - p_2) = 2\bar{p}(1 - \bar{p})/n$$

- But, if $H_A : P_2 = P_1 + \delta$ is correct, $v(p_1 - p_2)$ does not depend on a pooled $\bar{p}$ but instead $v(p_1 - p_2) = (p_1q_1 + p_2q_2)/n$, where $q_1 = 1 - p_1$ and $q_2 = 1 - p_2$. This is an estimate of the theoretical variance,

$$V(p_1 - p_2) = (P_1Q_1 + P_2Q_2)/n$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 28 / 35

<!-- page 29 -->

4. Differences in Proportions $\quad$ 4.1 Independent Sample

# Power

* The power of this test for a 1-sided alternative $H_A : P_2 = P_1 + \delta$ is

$$Pr(t_{\Delta p} > z_{1-\alpha}|P_2 - P_1 = \delta) \ (Note : t_{\Delta p} = \frac{p_1 - p_2}{\sqrt{v(p_1 - p_2)}})$$

$$= Pr\left(p_1 - p_2 > z_{1-\alpha}\sqrt{2\bar{P}(1 - \bar{P})/n}\Big|P_2 - P_1 = \delta\right)$$

$$\dot{=} Pr\left(\frac{p_1 - p_2}{\sqrt{(P_1 Q_1 + P_2 Q_2)/n}} - \frac{\delta}{\sqrt{(P_1 Q_1 + P_2 Q_2)/n}} > \right.$$

$$\left.\frac{z_{1-\alpha}\sqrt{2\bar{P}(1 - \bar{P})/n} - \delta}{\sqrt{(P_1 Q_1 + P_2 Q_2)/n}}\Bigg|P_2 - P_1 = \delta\right)$$

$$= Pr\left(Z > \frac{z_{1-\alpha}\sqrt{2\bar{P}(1 - \bar{P})/n} - \delta}{\sqrt{(P_1 Q_1 + P_2 Q_2)/n}}\right) = 1 - \beta \qquad (4.17)$$

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 4 $\qquad$ 29 / 35

<!-- page 30 -->

4. Differences in Proportions
4.1 Independent Sample

# Sample Sizes

* The sample size in each group needed to detect a difference of $\delta$ is found by setting the right-hand side of the inequality in the last line of (4.17) equal to $z_\beta$ and solving for $n$ to give

$$
n = \left[ \frac{z_{1-\alpha}\Delta_1 - z_\beta\Delta_2}{\delta} \right]^2 \qquad (4.18)
$$

  where $\Delta_1 = \sqrt{2\bar{P}(1 - \bar{P})}$ and $\Delta_2 = \sqrt{P_1 Q_1 + P_2 Q_2}$ (i.e., sqrt of the element variance under $H_0$ vs. $H_A$)

* Advance estimates of $P_1$, $P_2$, and $\bar{P}$ are needed to evaluate (4.18). The R function `power.prop.test` in `stats` package uses a search algorithm to solve for $n$ which will give a similar answer to (4.18).

Sunghee Lee (U of Michigan)
Prac Tools Ch. 4

<!-- page 31 -->

4. Differences in Proportions 4.2 Overlapping Samples

# 4.2 Overlapping Samples

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 31 / 35

<!-- page 32 -->

4. Differences in Proportions   4.2 Overlapping Samples

# Differences in Proportions: Overlapping Samples

* Suppose $X$ and $Y$ are equal to 1 with probabilities $P_x$ and $P_y$
* The event that $Y = 1$ given that $X = 0$ could mean that a unit had a characteristic at time 2 given that it did not at time 1.
* Further suppose $XY$ is equal to 1 with probability $P_{xy}$. The event, $XY = 1$, might correspond to a unit having some characteristic at both times 1 and 2. The conditional distribution of $Y$ given $X$ is $P_{y|x} = P_{xy}/P_x$; $P_{x|y}$ is defined similarly.
* With these definitions,

$$\sigma_x^2 = P_x(1 - P_x),$$

$$\sigma_y^2 = P_y(1 - P_y),$$

$$\sigma_{xy} = P_{xy} - P_x P_y, \text{ and}$$

$$\rho = \frac{P_{xy} - P_x P_y}{\sqrt{P_x(1 - P_x)P_y(1 - P_y)}}.$$

Sunghee Lee (U of Michigan)   Prac Tools Ch. 4   32 / 35

<!-- page 33 -->

4. Differences in Proportions $\quad$ 4.2 Overlapping Samples

# Differences in Proportions: Overlapping Samples

* When the sample sizes in the two groups are $n_1$ and $n_2$, $n_1$ is found using (4.13)

$$n_1 = \frac{1}{\delta^2} \left[ \sigma_x^2 + r \sigma_y^2 - 2 \gamma r \rho \sigma_x \sigma_y \right] (z_{1-\alpha} - z_{\beta})^2 \quad (4.13)$$

* Estimates (or educated guesses) are required for the proportions at the two time periods, $P_x$ and $P_y$, and the proportion, $P_{xy}$, that retains the characteristic from the first time to the second.
* Use `nProp2sam` in `PracTools`. Two constraints on $P_{xy}$:
  1. Since $P_{xy} = P_{y|x}Px \le P_x$ and $P_{xy} = P_{x|y}P_y \le P_y$, it must be true that $P_{xy} \le \min(P_x, P_y)$.
  2. Since correlation must be in $[-1, 1]$, we must have

$$P_x P_y - \Delta \le P_{xy} \le P_x P_y + \Delta,$$

  where $\Delta = \sqrt{P_x(1 - P_x)P_y(1 - P_y)}$

**See VDK Examples 4.8 and 4.10 in Class3Lab.pdf**

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 4 $\quad$ 33 / 35

<!-- page 34 -->

Special: Simulation-Based Power Analysis

# Special: Simulation-Based Power Analysis

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 34 / 35

<!-- page 35 -->

Special: Simulation-Based Power Analysis

# Power for Complex Analysis

* Power is specific to a particular statistical test (e.g., $t$-tests of means, regression coefficients, etc.)
* For complex analysis (e.g., model coefficients), we may not have closed-form formulas for power analysis. Instead, simulate your data generating process and compute power as follows
    1. Generate random data using the underlying model: specified design (e.g., sample/study design and sample size); values of covariates; parameter values that generate $Y$ under the alternative hypothesis being tested; values of model random errors
    2. Estimate the model (Or conduct the hypothesis tests)
    3. Check the $p$-values of the parameters of interest
    4. Repeat Steps 1-3 many times and observe the $p$-values
    5. Power=Proportion of $p\text{-value} < \alpha$ out of the repeats

**See Example Simulation 1 and 2 in Class3Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 4 35 / 35
