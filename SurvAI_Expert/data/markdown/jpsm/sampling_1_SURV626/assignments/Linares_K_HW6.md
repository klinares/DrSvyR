---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW6"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 6"
original: "sampling_1_SURV626/assignments/Linares_K_HW6.qmd"
pages: 
sha256: "93142b5e520caa57acc57b8e41e14e5577e38a4eed590dc8e24b129ebd8c6b56"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:11"
---


```r
pacman::p_load(knitr, tidyverse)

options(scipen=999)
```

1.  The following data are from an epsem two-stage sample of a = 10 clusters selected with SRS from a population of N = 9,300 young women in A = 151 unequal size clusters, where $y_\alpha$ is the cluster total for Body Mass Index (BMI), $z_\alpha$ is the number of women who have ever been pregnant among the $x_\alpha$ women selected in each cluster in the sample.

```r
N <- 9300
a <- 10
A <- 151

BMI_data <- tibble(
  cluster = seq(1, a),
  y = c(57, 74, 133, 72, 47, 113, 322, 47, 63, 111), # total BMI
  z = c(2, 1, 5, 1, 2, 2, 6, 2, 2, 2), # number of women pregnant
  x = c(2, 3, 5, 3, 2, 5, 10, 2, 2, 4)) # cluster sizes

BMI_data |> kable()
```

### Based on this sample answer the following questions:

-   **(a) Compute the mean Body Mass Index (BMI), its standard error and 95% confidence interval.**

Since the cluster sizes are unequal, the mean BMI is estimated as a ratio mean:

$$
\bar{y} = r = \frac{\sum_{\alpha} y_{\alpha}}{\sum_{\alpha} x_{\alpha}}
$$

Ignoring the finite population correction, the sampling variance is estimated as:

$$
\text{var}(\bar{y}) \approx \frac{1}{\bar{x}^2} \left[ \text{var}(y) + r^2 \text{var}(x) - 2r \times \text{cov}(y, x) \right]
$$

where:

$$
\text{var}(y) = \frac{a}{a-1} \left[ \sum_{\alpha=1}^{a} y_{\alpha}^2 - \frac{\left(\sum_{\alpha=1}^{a} y_{\alpha}\right)^2}{a} \right]
$$

$$
\text{var}(x) = \frac{a}{a-1} \left[ \sum_{\alpha=1}^{a} x_{\alpha}^2 - \frac{\left(\sum_{\alpha=1}^{a} x_{\alpha}\right)^2}{a} \right]
$$

$$
\text{cov}(y, x) = \frac{a}{a-1} \left[ \sum_{\alpha=1}^{a} y_{\alpha} x_{\alpha} - \frac{\left(\sum_{\alpha=1}^{a} y_{\alpha}\right)\left(\sum_{\alpha=1}^{a} x_{\alpha}\right)}{a} \right]
$$

```r
df <- a - 1
qt_value <- qt(0.975, df)

results_a <- BMI_data |>
  summarise(
    # Sums
    sum_y = sum(y),
    sum_x = sum(x),
    sum_y_sq = sum(y^2),
    sum_x_sq = sum(x^2),
    sum_yx = sum(y * x),
    # Ratio mean
    r = sum_y / sum_x,
    # Variance components (ignoring fpc)
    var_y = (a / (a - 1)) * (sum_y_sq - sum_y^2 / a),
    var_x = (a / (a - 1)) * (sum_x_sq - sum_x^2 / a),
    cov_yx = (a / (a - 1)) * (sum_yx - (sum_y * sum_x) / a),
    # Variance of ratio
    var_r = (1 / sum_x^2) * (var_y + r^2 * var_x - 2 * r * cov_yx),
    se_r = sqrt(var_r),
    # 95% CI
    ci_lower = r - qt_value * se_r,
    ci_upper = r + qt_value * se_r
  )

results_a |> 
  select(r, var_r, se_r, ci_lower, ci_upper) |> 
  mutate(across(everything(), ~round(.x, 3))) |> 
  kable(col.names = c("Mean BMI", "Variance", "SE", "CI Lower", "CI Upper"))
```

\newpage

-   **(b) Estimate the proportion of women who have ever been pregnant and its standard error.**

The proportion is estimated as a ratio:

$$
p = r = \frac{\sum_{\alpha} z_{\alpha}}{\sum_{\alpha} x_{\alpha}}
$$

The variance is:

$$
\text{var}(p) \approx \frac{1}{\bar{x}^2} \left[ \text{var}(z) + r^2 \text{var}(x) - 2r \times \text{cov}(z, x) \right]
$$

```r
results_b <- BMI_data |> 
  summarise(
    # Sums
    sum_z = sum(z),
    sum_x = sum(x),
    sum_z_sq = sum(z^2),
    sum_x_sq = sum(x^2),
    sum_zx = sum(z * x),
    # Ratio (proportion)
    p = sum_z / sum_x,
    # Variance components (ignoring fpc)
    var_z = (a / (a - 1)) * (sum_z_sq - sum_z^2 / a),
    var_x = (a / (a - 1)) * (sum_x_sq - sum_x^2 / a),
    cov_zx = (a / (a - 1)) * (sum_zx - (sum_z * sum_x) / a),
    # Variance of proportion
    var_p = (1 / sum_x^2) * (var_z + p^2 * var_x - 2 * p * cov_zx),
    se_p = sqrt(var_p)
  )

results_b |> 
  select(p, var_p, se_p) |> 
  mutate(across(everything(), ~round(.x, 4))) |> 
  kable(col.names = c("Proportion", "Variance", "SE"))
```

\newpage

-   **(c) Is the Taylor Series approximation adequate for the standard errors computed in (a) and (b)?**

The Taylor series approximation is adequate when the coefficient of variation of the denominator is less than 0.20. The CV is:

$$
cv(x) = \frac{se(x)}{\sum_{\alpha} x_{\alpha}} = \frac{\sqrt{\text{var}(x)}}{\sum_{\alpha} x_{\alpha}}
$$

```r
cv_results <- BMI_data |> 
  summarise(
    sum_x = sum(x),
    var_x = (a / (a - 1)) * (sum(x^2) - sum(x)^2 / a),
    se_x = sqrt(var_x),
    cv_x = se_x / sum_x
  )

cv_results |> 
  select(cv_x) |> 
  mutate(across(everything(), ~round(.x, 3))) |> 
  kable(col.names = c("CV(x)"))
```

Since $cv(x)$ is larger than 0.20, the Taylor series approximation to the sampling variance estimation is **not adequate**.

\

-   **(d) Compute the design effect and roh for the proportion in (b).**

The simple random sampling variance is:

$$
\text{var}_{SRS}(p) = \frac{p(1-p)}{n-1} = \frac{r(1-r)}{\bar{x} - 1}
$$

where $\bar{x} = \sum_{\alpha} x_{\alpha}$ is the total sample size.

The design effect is:

$$
\text{deff}(p) = \frac{\text{var}(p)}{\text{var}_{SRS}(p)}
$$

The intracluster correlation (roh) is:

$$
\rho = \frac{\text{deff}(p) - 1}{\bar{b} - 1} = \frac{\text{deff}(p) - 1}{\frac{\bar{x}}{a} - 1}
$$

```r
results_d <- BMI_data |> 
  summarise(
    sum_x = sum(x),
    b_bar = sum_x / a,  # average cluster size
    p = results_b$p,
    var_p = results_b$var_p,
    var_srs = (p * (1 - p)) / (sum_x - 1),
    deff = var_p / var_srs,
    roh = (deff - 1) / (b_bar - 1)
  )

results_d |> 
  select(var_srs, deff, roh) |> 
  mutate(across(everything(), ~round(.x, 4))) |> 
  kable(col.names = c("Var_SRS", "deff", "roh"))
```

\newpage

-   **(e) Estimate the expected variance of this proportion if the sample size were doubled by doubling the number of primary selections from 10 to 20, while keeping the same average cluster size.**

Doubling the number of clusters from $a = 10$ to $a = 20$ doubles the overall sample size from $n = 38$ to $n = 76$, but it does not alter the subsampling features of the design. Therefore, the expected sampling variance is based on the same design effect.

$$
\text{var}_{a=20}(p) = \text{var}_{SRS, n=76}(p) \times \text{deff}(p) = \frac{p(1-p)}{n_{new}-1} \times \text{deff}(p)
$$

```r
n_old <- sum(BMI_data$x)  # 38
n_new <- 2 * n_old  # 76

p_hat <- results_d$p
deff <- results_d$deff

var_srs_new <- (p_hat * (1 - p_hat)) / (n_new - 1)
var_new <- var_srs_new * deff
se_new <- sqrt(var_new)

tibble(
  n_new = n_new,
  var_srs_new = var_srs_new,
  deff = deff,
  var_new = var_new,
  se_new = se_new
) |> 
  mutate(across(where(is.numeric), ~round(.x, 4))) |> 
  kable(col.names = c("n_new", "Var_SRS(n=76)", "deff", "Var_new", "SE_new"))
```

\

-   **(f) Estimate the expected variance of this proportion if the sample size were reduced by one-half by using a within cluster sampling rate one-half as large as that used to select the original sample, while keeping 10 clusters.**

Reducing the sample size by one-half from $n = 38$ to $n = 19$ by using a within-cluster sampling rate one-half as large changes the design effect:

$$
\text{deff}_{new}(p) = 1 + \rho(\bar{b}_{new} - 1) = 1 + \rho\left(\frac{\bar{b}_{old}}{2} - 1\right)
$$

Then the expected sampling variance under this new design is:

$$
\text{var}_{new}(p) = \text{var}_{SRS, n=19}(p) \times \text{deff}_{new}(p)
$$

```r
b_bar_old <- results_d$b_bar  # 38/10 = 3.8
b_bar_new <- b_bar_old / 2    # 1.9
n_new_f <- n_old / 2          # 19

roh <- results_d$roh

deff_new <- 1 + roh * (b_bar_new - 1)
var_srs_new_f <- (p_hat * (1 - p_hat)) / (n_new_f - 1)
var_new_f <- var_srs_new_f * deff_new

tibble(
  b_bar_new = b_bar_new,
  n_new = n_new_f,
  deff_new = deff_new,
  var_srs_new = var_srs_new_f,
  var_new = var_new_f
) |> 
  mutate(across(where(is.numeric), ~round(.x, 4))) |> 
  kable(col.names = c("b_bar_new", "n_new", "deff_new", "Var_SRS(n=19)", "Var_new"))
```

## Problem 2: Assignment Feedback

### (a) Time Spent

-   Approximately 5 hours to complete all parts.

### (b) Difficulty Rating

-   **Rating: 7/10** - The assignment was moderately challenging. To me it was confusing at first how to update sampling variances by re-estimating roh and deff.

\newpage

# Appendix: Summary of Key Formulas

## Ratio Estimation for Unequal Cluster Sizes

For epsem two-stage samples with unequal cluster sizes, estimates are computed as ratios:

-   Mean: $\bar{y} = r = \frac{\sum_{\alpha} y_{\alpha}}{\sum_{\alpha} x_{\alpha}}$

-   Proportion: $p = r = \frac{\sum_{\alpha} z_{\alpha}}{\sum_{\alpha} x_{\alpha}}$

## Variance Estimation (Taylor Series / Ultimate Cluster)

$$
\text{var}(r) \approx \frac{1}{\bar{x}^2} \left[ \text{var}(y) + r^2 \text{var}(x) - 2r \times \text{cov}(y, x) \right]
$$

where (ignoring fpc):

$$
\text{var}(y) = \frac{a}{a-1} \left[ \sum y_{\alpha}^2 - \frac{(\sum y_{\alpha})^2}{a} \right]
$$

## Coefficient of Variation Check

Taylor series approximation is adequate when $cv(x) < 0.20$:

$$
cv(x) = \frac{\sqrt{\text{var}(x)}}{\sum_{\alpha} x_{\alpha}}
$$

## Design Effect and Intracluster Correlation

-   $\text{var}_{SRS}(p) = \frac{p(1-p)}{n-1}$
-   $\text{deff} = \frac{\text{var}(p)}{\text{var}_{SRS}(p)}$
-   $\rho = \frac{\text{deff} - 1}{\bar{b} - 1}$ where $\bar{b} = \frac{\sum x_{\alpha}}{a}$

## Projected Variances Under Design Changes

-   Doubling clusters (same $\bar{b}$): $\text{var}_{new} = \text{var}_{SRS,n_{new}} \times \text{deff}_{old}$
-   Halving within-cluster rate: $\text{deff}_{new} = 1 + \rho(\bar{b}_{new} - 1)$, then $\text{var}_{new} = \text{var}_{SRS,n_{new}} \times \text{deff}_{new}$
