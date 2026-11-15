---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_3_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "SURV 745 - Assignment 3"
original: "PracTools_SURV745/assignments/SURV745_Assign_3_Linares.qmd"
pages: 
sha256: "01551c2ad7a2dddb5ffe10b11ecfa7444b4176a16caad00c83ccbb243e75e5eb"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:07"
---


```r
#| label: setup
#| echo: false

pacman::p_load(paramtest, broom, knitr, furrr, PracTools, tidyverse)


options(scipen=999, digits=5)
```

#### 4.1 The average disposable employment income per worker in Mexico in 2002 was approximately \$6,100 U.S. dollars (USD). Suppose that a new survey is to be conducted in 2010 and you would like to determine the size of simple random sample that would permit you to detect that the average has risen to \$7,000. Assume that the unit relvariance of income in 2002 was 2.5 and that it will be about the same in 2010. Calculate a sample size for a 0.05-level test when the desired power is 0.80; treat the 2002 mean as a constant for this problem.

-   The power analysis is designed to detect an increase of at least $\delta = 900$ USD. The hypotheses encode this specific effect size, not merely any directional change:

$$
H_0: \delta < 900 \quad \text{vs.} \quad H_A: \delta \geq 900
$$

-   where $\delta = \mu_{2010} - \mu_{2002}$ is the true change in average disposable income per worker. Under $H_A$, the 2010 mean has risen to at least $\mu_A = 7{,}000$, so we are powering for a one-sided test with $\delta = 7{,}000 - 6{,}100 = 900$.

-   Using VDK Equation (4.5) for a one-sided test, we calculate sample size as:

$$
n = \left[\sigma_y \cdot \frac{z_{1-\alpha} + z_{1-\beta}}{\delta}\right]^2
$$

We first recover the unit standard deviation from the unit relvariance. The unit relvariance is $C^2 = \sigma_y^2 / \mu_0^2$, and we are given the relvariance in 2002 as 2.5.

```r
mu_0   <- 6100 # 2002 estimate
mu_a   <- 7000 # hyp
delta  <- mu_a - mu_0 # difference
relvar <- 2.5 # relvariance given
alpha  <- 0.05 # set alpha
power  <- 0.80 # set power

# derived quantities
sigma_y    <- mu_0 * sqrt(relvar)
z_1alpha  <- qnorm(1 - alpha)
z_1beta   <- qnorm(power)

# VDK 4.5 one-sided test
n_manual <- (sigma_y * (z_1alpha + z_1beta) / delta)^2

tibble(
  Parameter = c("mu_0", "mu_A", "delta", "sigma_y", 
                "z_{1-alpha}", "z_{1-beta}", "n"),
  Value = c(mu_0, mu_a, delta, round(sigma_y, 2), 
            round(z_1alpha, 4), round(z_1beta, 4), 
            ceiling(n_manual))
) |> kable()

# Verification with power.t.test
power.t.test(
  n = NULL,
  delta = delta,
  sd = sigma_y,
  sig.level = alpha,
  power = power,
  type = "one.sample",
  alternative = "one.sided"
)
```

-   A simple random sample of **`r ceiling(n_manual)`** workers is needed to detect an increase from \$6,100 to \$7,000 with 80% power at the 0.05 significance level using a one-sided test. The calculated sample size using the formula above is 710.04 and the discrepancy is because this power calculation assumes a normal approximation, while the r function uses a t-distribution. If we use the r-function estimate, than we select n=712.

\newpage

#### 4.2 Consider Example 4.6 where one-sided tests were used to determine sample sizes with 80% and 90% power to detect differences in estimates for males and females.

a\) How does the sample size change if $\sigma^2_d=200$?

b\) How does a $\sigma^2_d=800$ affect your previous calculation?

-   This exercise references Example 4.6, where we compare mean weights of males and females using a one-sided test to detect a difference of $\delta = 5$ kg. In Example 4.6, $\sigma_M^2 = \sigma_F^2 = 200$ and $\sigma_d^2 = 400$. We now examine how changes in $\sigma_d^2$ affect the required sample size. We use the same sample size formula from question 4.1. The key relationship between `power.t.test`'s `sd` parameter and $\sigma_d^2$ is: since `power.t.test` assumes $\sigma_d^2 = 2 \cdot \text{sd}^2$ for a two-sample test, we set `sd` $= \sqrt{\sigma_d^2 / 2}$.

c\) Compare results.

```r

# This is a modified function from Class 3 Lab
# adapted: sd_each parameterized (varies across conditions),
t_fun <- function(simN, sampsize, delta, sd_each, mu = 0) {
  # Step 1, Generate data under H_A
  tt <- t.test(
    rnorm(sampsize, mu, sd_each),
    rnorm(sampsize, mu + delta, sd_each),
    alternative = "less", var.equal = TRUE
  ) |>
    broom::tidy()
  
  c(t = tt$statistic, p = tt$p.value, sig = tt$p.value < 0.05)

}
```

```r

# prepare for parallel processing 
plan(multisession, workers = parallel::detectCores())
set.seed(909)

# Run 10,000 iterations per condition (parallelized)
sim_results <- tibble(
  sigma_d_sq   = c(200, 200, 800, 800),
  target_power = c(0.80, 0.90, 0.80, 0.90)
) |>
  mutate(
    n_per_group = map2_int(sigma_d_sq, target_power, \(s2d, pw) {
      ceiling(power.t.test(
        power = pw, delta = 5, sd = sqrt(s2d / 2),
        type = "two.sample", alt = "one.sided", sig.level = 0.05
      )$n)
    }),
    sd_each = sqrt(sigma_d_sq / 2),
    sim_power = future_map2_dbl(n_per_group, sd_each, \(n, sd) {
      run_test(t_fun, n.iter = 10000, output = "data.frame",
               sampsize = n, delta = 5, sd_each = sd) |>
        results() |>
        summarize(power = mean(sig)) |>
        pull(power)
    }, .options = furrr_options(seed = TRUE))
  )


plan(sequential)

sim_results |>
  select(`sigma_d^2` = sigma_d_sq, `Target Power` = target_power,
         `n per group` = n_per_group, `Simulated Power` = sim_power) |>
  kable()
```

-   The results demonstrate two key patterns. First, as $\sigma_d^2$ increases, the required sample size increases proportionally, and doubling the variance of the difference doubles the required $n$ per group. This follows directly from VDK Equation 4.11, where $n \propto \sigma_d^2$. Intuitively, greater variability in the difference makes it harder to detect a fixed effect, requiring more observations. Second, for any given $\sigma_d^2$, achieving 90% power requires approximately 38% more observations than 80% power, reflecting the ratio $(z_{0.95} + z_{0.90})^2 / (z_{0.95} + z_{0.80})^2 \approx 1.38$.

\newpage

#### 4.11 An organization surveys its employees in January and July to measure proficiency with the suite of data analytic software that the company supplies. Employees perform various tasks and receive an overall score between 0 and 100. Suppose that, based on past data, the average score is 72 and that the unit standard deviation of scores is 55 which is stable over time. The information technology department would like to know if the average score has changed 10% or more from January to July. A simple random sample is selected of the employees in January. The same employees will be tested in July, if possible, but because of turnover, absenteeism, and scheduling conflicts, you expect that only 60% of the initial sample will be retested in July. For cross-sectional analyses, the same size sample is desired at each time period. Assume that the correlation between individual scores at the two times is 0.76.

-   Key parameters:

    -   Average score: $\mu_0 = 72$

    -   Unit standard deviation: $\sigma_x = \sigma_y = 55$ (stable over time)

    -   Detectable change: $\delta = 0.10 \times 72 = 7.2$ points

    -   Overlap: $\gamma = 0.60$ (60% of January sample retested in July)

    -   Sample size ratio: $r = n_1/n_2 = 1$ (equal sizes desired)

    -   Correlation between individual scores: $\rho = 0.76$

    -   Two-sided test at $\alpha = 0.05$ with power $= 0.80$

    -   The hypotheses are:

$$
H_0: \mu_{\text{Jan}} = \mu_{\text{Jul}} \quad \text{vs.} \quad H_A: \mu_{\text{Jan}} \neq \mu_{\text{Jul}}
$$

-   The relevant sample size Eq 4.13, adapted for a two-sided test by replacing $z_{1-\alpha}$ with $z_{1-\alpha/2}$:

$$
n_1 = \frac{1}{\delta^2}\left[\sigma_x^2 + r\sigma_y^2 - 2\gamma r \rho \sigma_x \sigma_y\right](z_{1-\alpha/2} - z_\beta)^2
$$

-   When $\sigma_x = \sigma_y = \sigma$, this simplifies via Eq 4.14:

$$
n_1 = \frac{\sigma^2}{\delta^2}\left[1 + r(1 - 2\gamma\rho)\right](z_{1-\alpha/2} + z_{\beta})^2
$$

```r
mu_0    <- 72
sigma   <- 55
delta   <- 0.10 * mu_0   
rho     <- 0.76
gamma_o <- 0.60           # proportion of overlap
r       <- 1              # n1/n2
alpha   <- 0.05
power   <- 0.80
z_a2    <- qnorm(1 - alpha / 2)
z_1mb   <- qnorm(power)
```

a\) Compute the sample size required in January (which will equal the size in July) that will be needed to detect a change of 10% with power 0.80. Assume that all cases at each time period will be used to compute the difference and that the level of the test is 0.05.

-   When all cases at each time period are used to compute the difference, we have $\gamma = 0.60$ and $r = 1$.

```r

#  two-sided
factor_a <- 1 + r * (1 - 2 * gamma_o * rho)
n1_a     <- (sigma^2 / delta^2) * factor_a * (z_a2 + z_1mb)^2


```

-   A sample of **`r ceiling(n1_a)`** employees should be selected in January (and the same number in July) to detect a 10% change with 80% power when using all available cases at each time period.

-   We can verify using PracTools::`nDep2sam()`

```r

nDep2sam(
  S2x = sigma^2, S2y = sigma^2,
  g = gamma_o, r = r, rho = rho,
  alt = "two.sided", del = delta,
  sig.level = alpha, pow = power
)
```

\newpage

b\) Repeat part (a) but assume that only the overlapping cases between January and July will be used.

-   When only the overlapping cases are used to estimate the difference, we effectively have a completely overlapping design for the analysis sample. The overlap group has complete pairing, so we set $\gamma = 1$ and $r = 1$. The sample size formula gives us the number of **overlapping cases** needed ($n_{12}$):

$$
n_{12} = \frac{\sigma^2}{\delta^2}\left[1 + r(1 - 2 \cdot 1 \cdot \rho)\right](z_{1-\alpha/2} + z_{\beta})^2
$$

-   60% of the January sample expected to overlap, the required sample size is $n_1 = n_{12} / 0.60$.

```r
# compute number of overlaping cases
factor_b  <- 1 + r * (1 - 2 * 1 * rho)
n_overlap <- (sigma^2 / delta^2) * factor_b * (z_a2 + z_1mb)^2

# adjsut 60% retention
n1_b <- n_overlap / gamma_o
```

-   A sample of **`r ceiling(n1_b)`** employees must be selected in January to ensure approximately `r ceiling(n_overlap)` overlapping cases are available for analysis with 80% power.

-   Verifying with `nDep2sam` (complete overlap)

```r
nDep2sam(
  S2x = sigma^2, S2y = sigma^2,
  g = 1, r = r, rho = rho,
  alt = "two.sided", del = delta,
  sig.level = alpha, pow = power)
```

-   The `nDep2sam` output with $\gamma = 1$ gives $n_1 = `r ceiling(n_overlap)`$, which is the number of overlapping cases needed. Adjusting for 60% overlap: $n_1 = \lceil`r ceiling(n_overlap)` / 0.60\rceil = `r ceiling(n1_b)`$.

\newpage

c\) Calculate the variance of the estimated mean difference from parts (a) and (b) and discuss how this relates to the sample sizes you computed in parts (a) and (b).

```r
n1_a_used <- ceiling(n1_a)
n12_used  <- ceiling(n_overlap)

V_a <- (sigma^2 / n1_a_used) * factor_a
V_b <- (sigma^2 / n12_used) * factor_b

tibble(
  Approach = c("(a) All cases", "(b) Overlap only"),
  `Effective n` = c(n1_a_used, n12_used),
  `Variance factor` = c(factor_a, factor_b),
  `V(d-bar)` = round(c(V_a, V_b), 4)
) |> 
  kable()
```

-   The variances of the estimated mean difference are approximately equal ($V(\hat{\bar{d}})_a \approx `r round(V_a, 2)`$ vs. $V(\hat{\bar{d}})_b \approx `r round(V_b, 2)`$). Both sample sizes were calibrated to achieve the same power (0.80) for detecting the same effect ($\delta = 7.2$) at the same significance level ($\alpha = 0.05$). Since the power depends on the ratio $\delta / \sqrt{V(\hat{\bar{d}})}$, achieving equal power requires equal variances, which in turn determines the sample sizes.

-   The key tradeoff is between the variance factor and the effective sample size. Part (a) has a larger variance factor (`r factor_a`) but uses all $n_1 = `r n1_a_used`$ cases. Part (b) has a smaller variance factor (`r factor_b`) because full overlap exploits the positive correlation ($\rho = 0.76$) to reduce variance, but uses only $n_{12} = `r n12_used`$ overlapping cases. The ratio of variance factors (`r round(factor_a / factor_b, 2)`) is approximately equal to the ratio of effective sample sizes (`r round(n1_a_used / n12_used, 2)`), confirming that the two approaches are calibrated to the same precision.

## 

\newpage

d\) What assumption are you implicitly making to say that the difference in means estimated in (a) and (b) are the same? Are there any reasons to believe that this assumption is wrong? Explain your answer.

-   We implicitly assume that the population mean at each time period is the same regardless of whether an employee participates at both time periods or only one. Specifically, we assume that the January population mean is the same for employees who will be retested in July as for those who will not, and similarly for the July mean.

-   There are several reasons to question this assumption. For instance, selection bias from attrition, for employees who leave (turnover) or are absent in July may systematically differ from those who remain. For example, employees who struggle with the software may be more likely to leave the company, which would inflate the July mean among the overlap group relative to the full population. The additional employees selected in July to maintain the cross-sectional sample size may differ systematically from the original cohort; for example, they may include new hires with different baseline proficiency levels. These factors suggest that the missing-completely-at-random (MCAR) assumption required for the two estimators to target the same population quantity is unlikely to hold exactly in practice.
