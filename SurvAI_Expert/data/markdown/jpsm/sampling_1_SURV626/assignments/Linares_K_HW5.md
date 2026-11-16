---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW5"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 5"
original: "sampling_1_SURV626/assignments/Linares_K_HW5.qmd"
pages: 
sha256: "e0d2061d6d18819fd4ae1552910a56b9359fb7b08308b4300c1767314b57c9d1"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:17"
---


```r
pacman::p_load(knitr, readxl, tidyverse)

options(scipen=999)
```

## Part I: Single-Stage Cluster Sampling

The sheet 'Single-stage cluster sample' in the Excel file 'SURV 626 HW5 data fall 25.xls' contains the data from a single-stage cluster sample of size n = 930 with a = 10 clusters randomly selected with replacement and B = 93 women each from a clustered population of N = 9,300 women in A = 100 equal size clusters. The columns 'Cluster total of BMI' and 'Cluster total EVERPREG' corresponds to cluster totals of each variable, that is, the sum of the values across all elements in the cluster.

```r
# read in HW 5 data
repo_path <- "d:/repos/UMD_classes_code/sampling_1_SURV626/"

BMI_1_stage <- read_excel(str_c(repo_path, 
                             "assignments/HW5_data.xls"), 
                       sheet = "Single-stage cluster sample") |> 
  rename(cluster_id = 1, total_BMI = 2, total_preg = 3)

BMI_2_stage <- read_excel(str_c(repo_path, 
                             "assignments/HW5_data.xls"), 
                       sheet = "Two-stage cluster sample") 

# Population parameters
N <- 9300 # total population
A <- 100  # total clusters in population
B <- 93   # women in each cluster (population)

# Sample parameters for single-stage
a <- 10   # sampled clusters
n <- a * B  # total sample size = 930

BMI_1_stage |> kable()
```

### (a) Compute the mean Body Mass Index (BMI), its standard error and 95% confidence interval.

For this cluster sample, the mean BMI is given by:

$$
\bar{y} = \frac{\sum_{\alpha=1}^{a} \sum_{\beta=1}^{B} y_{\alpha\beta}}{aB} = \frac{\sum_{\alpha=1}^{a} y_{\alpha}}{aB}
$$

The sampling variance is given by:

$$
\text{var}(\bar{y}) = \frac{s_a^2}{a}
$$

where:

$$
s_a^2 = \frac{\sum_{\alpha=1}^{a} y_{\alpha}^2 - \frac{\left(\sum_{\alpha=1}^{a} y_{\alpha}\right)^2}{a}}{B^2(a-1)}
$$

The 95% confidence interval is:

$$
\bar{y} \pm t_{(a-1; 1-\alpha/2)} \times se(\bar{y})
$$

```r
# Use t-distribution with (a-1) degrees of freedom
qt_value <- qt(0.975, a - 1)

# Compute results for single-stage cluster sample
BMI_results_1 <- BMI_1_stage |>
  summarise(
    # Sum of cluster totals
    sum_y = sum(total_BMI),
    # Sum of squared cluster totals
    sum_y_sq = sum(total_BMI^2),
    # Mean
    y_bar = sum_y / (a * B),
    # Between-cluster variance (s_a^2)
    s_a_sq = (sum_y_sq - (sum_y^2 / a)) / (B^2 * (a - 1)),
    # Variance of mean
    var_y = s_a_sq / a,
    # Standard error
    se_y = sqrt(var_y),
    # 95% CI
    ci_lower = y_bar - qt_value * se_y,
    ci_upper = y_bar + qt_value * se_y
  ) |> 
  select(y_bar, s_a_sq, var_y, se_y, ci_lower, ci_upper)

BMI_results_1 |> 
  mutate(across(everything(), ~round(.x, 3))) |> 
  kable(col.names = c("Mean", "s_a^2", "Variance", "SE", "CI Lower", "CI Upper"))
```

### (b) Estimate the standard error of the mean BMI if the sample consisted of a = 5 clusters of B = 93 each.

Because we are only changing the number of clusters from $a = 10$ to $a = 5$, we can re-use $s_a^2$ from part (a):

$$
se(\bar{y}) = \sqrt{\text{var}(\bar{y})} = \sqrt{\frac{s_a^2}{a}}
$$

```r
a_new <- 5
s_a_sq <- BMI_results_1$s_a_sq

var_y_new <- s_a_sq / a_new
se_y_new <- sqrt(var_y_new)

cat("With a = 5 clusters:\n")
cat("Variance:", round(var_y_new, 3), "\n")
cat("Standard Error:", round(se_y_new, 3), "\n")
```

### (c) \[OPTIONAL\] Estimate the proportion of women who have ever been pregnant (EVERPREG = 1) from the selected sample, its standard error, design effect deff, and roh.

The proportion is:

$$
p = \frac{\sum_{\alpha=1}^{a} \sum_{\beta=1}^{B} z_{\alpha\beta}}{aB} = \frac{\sum_{\alpha=1}^{a} z_{\alpha}}{aB}
$$

```r
# Reset a to 10 for this calculation
a <- 10
n <- a * B

# Compute proportion results
prop_results_1 <- BMI_1_stage |>
  summarise(
    sum_z = sum(total_preg),
    sum_z_sq = sum(total_preg^2),
    p = sum_z / (a * B),
    s_a_sq = (sum_z_sq - (sum_z^2 / a)) / (B^2 * (a - 1)),
    var_p = s_a_sq / a,
    se_p = sqrt(var_p)
  )

# SRS variance for design effect
p_hat <- prop_results_1$p
var_srs <- (1 - n/N) * (p_hat * (1 - p_hat)) / (n - 1)

# Design effect and roh
deff <- prop_results_1$var_p / var_srs
roh <- (deff - 1) / (B - 1)

cat("Proportion:", round(p_hat, 4), "\n")
cat("SE(p):", round(prop_results_1$se_p, 5), "\n")
cat("Var(p):", round(prop_results_1$var_p, 5), "\n")
cat("Var_SRS(p):", round(var_srs, 5), "\n")
cat("Design Effect:", round(deff, 3), "\n")
cat("roh:", round(roh, 3), "\n")
```

\newpage

## Part II: Two-Stage Cluster Sampling

The sheet 'Two-stage cluster sample' in the Excel file 'SURV 626 HW5 data fall 25.xls' contains the data from a two-stage cluster sample of size n = 40 with a = 10 clusters randomly selected with replacement and b = 4 women randomly selected without replacement each from a clustered population of N = 9,300 women in A = 100 equal size clusters of B = 93 women each.

```r
# Reset parameters for two-stage sampling
a <- 10  # sampled clusters
b <- 4   # sampled elements per cluster
n <- a * b  # total sample size = 40
f <- n / N  # sampling fraction

BMI_2_stage |> head(15) |> kable()
```

### (d) Compute the mean Body Mass Index (BMI), its standard error and 95% confidence interval.

For this two-stage cluster sample, the mean BMI is:

$$
\bar{y} = \frac{\sum_{\alpha=1}^{a} \sum_{\beta=1}^{b} y_{\alpha\beta}}{ab} = \frac{\sum_{\alpha=1}^{a} y_{\alpha}}{ab}
$$

Because clusters were selected with replacement and elements without, the sampling variance estimate is:

$$
\text{var}(\bar{y}) = (1-f) \frac{s_a^2}{a}
$$

where:

$$
s_a^2 = \frac{\sum_{\alpha=1}^{a} y_{\alpha}^2 - \frac{\left(\sum_{\alpha=1}^{a} y_{\alpha}\right)^2}{a}}{b^2(a-1)}
$$

```r
qt_value <- qt(0.975, a - 1)

# Compute cluster totals first
cluster_stats <- BMI_2_stage |>
  group_by(CLUSTER) |>
  summarise(
    y_alpha = sum(BMI),
    y_alpha_sq = y_alpha^2
  )

# Compute results for two-stage cluster sample
BMI_results_2 <- cluster_stats |>
  summarise(
    sum_y = sum(y_alpha),
    sum_y_sq = sum(y_alpha_sq),
    y_bar = sum_y / (a * b),
    s_a_sq = (sum_y_sq - (sum_y^2 / a)) / (b^2 * (a - 1)),
    var_y = (1 - f) * s_a_sq / a,
    se_y = sqrt(var_y),
    ci_lower = y_bar - qt_value * se_y,
    ci_upper = y_bar + qt_value * se_y
  ) |> 
  select(y_bar, s_a_sq, var_y, se_y, ci_lower, ci_upper)

BMI_results_2 |> 
  mutate(across(everything(), ~round(.x, 3))) |> 
  kable(col.names = c("Mean", "s_a^2", "Variance", "SE", "CI Lower", "CI Upper"))
```

### (e) Estimate the standard error of the mean BMI if the sample consisted of a = 5 clusters of b = 4 each.

Because we are only changing the number of clusters from $a = 10$ to $a = 5$, and not the subsample size, we can re-use $s_a^2$ from part (d):

$$
se(\bar{y}) = \sqrt{\text{var}(\bar{y})} = \sqrt{(1-f)\frac{s_a^2}{a}}
$$

```r
a_new <- 5
b_new <- 4
n_new <- a_new * b_new
f_new <- n_new / N

s_a_sq_2 <- BMI_results_2$s_a_sq
var_y_new_2 <- (1 - f_new) * s_a_sq_2 / a_new
se_y_new_2 <- sqrt(var_y_new_2)

cat("With a = 5 clusters, b = 4:\n")
cat("Variance:", round(var_y_new_2, 3), "\n")
cat("Standard Error:", round(se_y_new_2, 3), "\n")
```

### (f) If clusters had been selected without replacement, what would be the consequence of using the with-replacement variance formula?

If clusters had been selected **without replacement**, and the variance estimation formula $\text{var}(\bar{y}) = (1-f)\frac{s_a^2}{a}$ had been used, this with-replacement formula would **over-estimate** the true variance slightly.

The unbiased, but more complicated, estimate would be:

$$
\text{var}(\bar{y}) = (1-f)\frac{s_a^2}{a} + \left(\frac{a}{A}\right)\left(1 - \frac{b}{B}\right)\frac{s_b^2}{ab}
$$

### (g) Estimate the proportion of women who have ever been pregnant (EVERPREG = 1), its standard error, design effect deff, and roh.

```r
# Reset parameters
a <- 10
b <- 4
n <- a * b
f <- n / N
```

The proportion is:

$$
p = \frac{\sum_{\alpha=1}^{a} \sum_{\beta=1}^{b} z_{\alpha\beta}}{ab} = \frac{\sum_{\alpha=1}^{a} z_{\alpha}}{ab}
$$

```r
# Compute cluster totals for EVERPREG
cluster_stats_p <- BMI_2_stage |>
  group_by(CLUSTER) |>
  summarise(
    z_alpha = sum(EVERPREG),
    z_alpha_sq = z_alpha^2
  )

cluster_stats_p |> 
  mutate(p_alpha = z_alpha / b) |> 
  kable(col.names = c("Cluster", "z_alpha", "z_alpha^2", "p_alpha"))
```

```r
# Compute proportion results
prop_results_2 <- cluster_stats_p |>
  summarise(
    sum_z = sum(z_alpha),
    sum_z_sq = sum(z_alpha_sq),
    p = sum_z / (a * b),
    s_a_sq = (sum_z_sq - (sum_z^2 / a)) / (b^2 * (a - 1)),
    var_p = (1 - f) * s_a_sq / a,
    se_p = sqrt(var_p)
  )

prop_results_2 |> 
  select(p, s_a_sq, var_p, se_p) |>
  mutate(across(everything(), ~round(.x, 5))) |> 
  kable(col.names = c("Proportion", "s_a^2", "Variance", "SE"))
```

To compute the design effect, we first estimate the SRS sampling variance:

$$
\text{var}_{SRS}(p) = (1-f)\frac{s^2}{n} = (1-f)\frac{p(1-p)}{n-1}
$$

```r
p_hat_2 <- prop_results_2$p
var_srs_2 <- (1 - f) * (p_hat_2 * (1 - p_hat_2)) / (n - 1)

cat("Var_SRS(p):", round(var_srs_2, 5), "\n")
```

The design effect is:

$$
\text{deff} = \frac{\text{var}(p)}{\text{var}_{SRS}(p)}
$$

```r
deff_2 <- prop_results_2$var_p / var_srs_2
cat("Design Effect:", round(deff_2, 3), "\n")
```

The intracluster correlation (roh) is:

$$
\rho = \frac{\text{deff} - 1}{b - 1}
$$

```r
roh_2 <- (deff_2 - 1) / (b - 1)
cat("roh:", round(roh_2, 3), "\n")
```

### (h) Compute the optimum cluster size for the proportion of women who have ever been pregnant.

Given $c_a = \$100$ (cost per cluster) and $c_b = \$10$ (cost per observation within cluster), the optimum cluster size is:

$$
b_{opt} = \sqrt{\frac{c_a}{c_b} \cdot \frac{1-\rho}{\rho}}
$$

```r
c_a <- 100  # cost per cluster
c_b <- 10   # cost per observation

b_opt <- sqrt((c_a / c_b) * ((1 - roh_2) / roh_2))

cat("Optimum cluster size b_opt:", round(b_opt, 3), "\n")
```

### (i) \[OPTIONAL\] Estimate the variance and standard error of the proportion if the design consisted of a = 20 clusters of b = 2 each.

The overall sample size is still $n = a \times b = 20 \times 2 = 40$, so we have the same SRS variance as in part (g), but the design effect will change as the subsample size changes from $b = 4$ to $b = 2$:

$$
\text{deff} = 1 + \rho(b-1)
$$

```r
b_new <- 2
a_new <- 20
n_new <- a_new * b_new  # still 40

# New design effect with b = 2
deff_new <- 1 + roh_2 * (b_new - 1)

# Variance under new design
var_p_new <- deff_new * var_srs_2
se_p_new <- sqrt(var_p_new)

cat("With a = 20 clusters, b = 2:\n")
cat("New deff:", round(deff_new, 4), "\n")
cat("Variance:", round(var_p_new, 5), "\n")
cat("Standard Error:", round(se_p_new, 4), "\n")
```

\

## Problem 2: Assignment Feedback

### (a) Time Spent

-   Approximately 4.5 hours to complete all parts mostly understanding portability of roh.

### (b) Difficulty Rating

-   **Rating: 7/10** - The assignment was moderately challenging. The lecture notes and books were used to complete this assignment.

\newpage

# Appendix: Summary of Key Formulas

## Single-Stage Cluster Sampling (clusters selected with replacement)

-   Mean: $\bar{y} = \frac{\sum_{\alpha=1}^{a} y_{\alpha}}{aB}$
-   Variance: $\text{var}(\bar{y}) = \frac{s_a^2}{a}$
-   $s_a^2 = \frac{\sum_{\alpha=1}^{a} y_{\alpha}^2 - \frac{(\sum_{\alpha=1}^{a} y_{\alpha})^2}{a}}{B^2(a-1)}$

## Two-Stage Cluster Sampling (clusters with replacement, elements without)

-   Mean: $\bar{y} = \frac{\sum_{\alpha=1}^{a}\sum_{\beta=1}^{b} y_{\alpha\beta}}{ab}$
-   Variance: $\text{var}(\bar{y}) = (1-f)\frac{s_a^2}{a}$
-   $s_a^2 = \frac{\sum_{\alpha=1}^{a} y_{\alpha}^2 - \frac{(\sum_{\alpha=1}^{a} y_{\alpha})^2}{a}}{b^2(a-1)}$

## Design Effect and Intracluster Correlation

-   Design effect: $\text{deff} = \frac{\text{var}(\bar{y})}{\text{var}_{SRS}(\bar{y})}$
-   Intracluster correlation: $\rho = \frac{\text{deff} - 1}{b - 1}$
-   Relationship: $\text{deff} = 1 + (b-1)\rho$

## Optimum Cluster Size

-   $b_{opt} = \sqrt{\frac{c_a}{c_b} \cdot \frac{1-\rho}{\rho}}$

where $c_a$ is cost per cluster and $c_b$ is cost per observation within cluster.
