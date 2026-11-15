---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW7"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 7"
original: "sampling_1_SURV626/assignments/Linares_K_HW7.qmd"
pages: 
sha256: "2322b178a03ea2f592a9a63126f899a60665dce3741d69c06d7367837ec206cd"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:11"
---


```r
pacman::p_load(knitr, readxl, tidyverse)

options(scipen=999)

repo_path <- "d:/repos/UMD_classes_code/sampling_1_SURV626/"

BMI_data <- read_xls(str_c(repo_path, 
                           "assignments/HW7_data.xls")) 
```

1.  The Excel file 'SURV 626 HW7 data fall 25.xls' contains the data from a stratified clustered sample of size n = 40 with $a_h = 2$ clusters per stratum selected with simple random sampling with replacement and b = 4 elements per cluster selected with simple random sampling without replacement from a population of N = 9,300 young women in A = 151 unequal size clusters in H = 5 strata. Based on this stratified cluster sample answer the following questions:

```r
N <- 9300
n <- 40
a_h <- 2  # clusters per stratum
b <- 4    # elements per cluster
A <- 151
H <- 5

# summary of data
BMI_data |> 
  group_by(STRATUM) |> 
  reframe(cluster_n = n_distinct(CLUSTER_ID2), element_n = n()) |> 
  kable()
```

\newpage

### (a) Compute the sampling weight for each selected woman in your sample.

The sampling weights are computed as the inverse of the inclusion probabilities:

$$
w_{h\alpha\beta} = \left[ \Pr\{h\alpha\beta\} \right]^{-1}
$$

Since $a_h = 2$ clusters were selected from every stratum with SRS and $b = 4$ elements from every cluster with SRS, the inclusion probabilities are:

$$
\Pr\{h\alpha\beta\} = \Pr\{h\alpha\} \times \Pr\{\beta | h\alpha\} = \frac{a_h}{A_h} \times \frac{b}{B_{h\alpha}} = \frac{2}{A_h} \times \frac{4}{B_{h\alpha}}
$$

where $A_h$ is the number of clusters in stratum $h$ and $B_{h\alpha}$ is the number of elements in cluster $\alpha$ in stratum $h$.

```r
BMI_data <- BMI_data |> 
  mutate(weight = 1 / PROB)

# Display weights by cluster
BMI_data |> 
  group_by(STRATUM, CLUSTER_ID2) |> 
  reframe(weight = mean(weight)) |> 
  kable()
```

\newpage

### (b) What is the estimated increase in variance due to these weights? What is the assumption you have to rely on to compute this "weighting effect"?

The increase in variance due to the weights can be estimated as:

$$
1 + L = n \frac{\sum_{i=1}^{n} w_i^2}{\left(\sum_{i=1}^{n} w_i\right)^2}
$$

```r
results_b <- BMI_data |> 
  summarise(
    n = n(),
    sum_w = sum(weight),
    sum_w_sq = sum(weight^2),
    UWE = n * sum_w_sq / sum_w^2
  )

results_b |> 
  select(UWE) |> 
  mutate(across(everything(), ~round(.x, 3))) |> 
  kable()
```

Assuming that the sampling weights are unrelated to the survey variables, this indicates there is approximately a **25.1% increase** in the sampling variance of the survey estimates, compared to a corresponding epsem design, due to the variability of the weights.

We can verify using PracTools:

```r
PracTools::deffK(BMI_data$weight)
```

\newpage

### (c) Complete the following table using the weighted cluster totals

Where $w_{h\alpha}$ is the sum of the weights in the cluster, $u_{h\alpha}$ is the weighted cluster total for BMI, and $v_{h\alpha}$ is the weighted cluster total for EVERPREG:

$$
w_{h\alpha} = \sum_{\beta=1}^{b} w_{h\alpha\beta}, \quad u_{h\alpha} = \sum_{\beta=1}^{b} w_{h\alpha\beta} y_{h\alpha\beta}, \quad v_{h\alpha} = \sum_{\beta=1}^{b} w_{h\alpha\beta} z_{h\alpha\beta}
$$

```r
results_c <- BMI_data |> 
  group_by(STRATUM, CLUSTER_ID2) |> 
  summarise(
    w_ha = sum(weight),
    u_ha = sum(weight * BMI),
    v_ha = sum(weight * EVERPREG),
    .groups = "drop"
  ) |> 
  group_by(STRATUM) |> 
  mutate(alpha = row_number()) |> 
  ungroup() |> 
  relocate(alpha, .after = "STRATUM")

results_c |> 
  select(STRATUM, alpha, CLUSTER_ID2, w_ha, u_ha, v_ha) |>
  kable(digits = 2)

# Show totals
results_c |> 
  summarise(
    w_total = sum(w_ha),
    u_total = sum(u_ha),
    v_total = sum(v_ha)
  ) |> 
  kable(digits = 2, col.names = c("Total w_ha", "Total u_ha", "Total v_ha"))
```

\newpage

### (d) Estimate the mean BMI, its standard error and 99% confidence interval.

The mean BMI is estimated as a weighted ratio mean:

$$
\bar{y}_w = r_w = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b} w_{h\alpha\beta} y_{h\alpha\beta}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b} w_{h\alpha\beta}} = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} u_{h\alpha}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} w_{h\alpha}}
$$

Because the sample was selected with paired selection ($a_h = 2$ for all $h$), the sampling variance estimator (ignoring fpc) can be written as:

$$
\text{var}(\bar{y}_w) \approx \frac{1}{w^2} \left[ \sum_{h=1}^{H} (u_{h1} - u_{h2})^2 + r^2 \sum_{h=1}^{H} (w_{h1} - w_{h2})^2 - 2r \sum_{h=1}^{H} (u_{h1} - u_{h2})(w_{h1} - w_{h2}) \right]
$$

```r
alpha_level <- 0.01
df <- H * (a_h - 1)  # = 10 - 5 = 5
qt_value <- qt(1 - alpha_level/2, df)

# Calculate weighted totals
w_total <- sum(results_c$w_ha)
u_total <- sum(results_c$u_ha)
r_bmi <- u_total / w_total

# Calculate paired differences by stratum
paired_diff <- results_c |> 
  group_by(STRATUM) |> 
  summarise(
    u_h1 = first(u_ha),
    u_h2 = last(u_ha),
    w_h1 = first(w_ha),
    w_h2 = last(w_ha),
    .groups = "drop"
  ) |> 
  mutate(
    u_diff_sq = (u_h1 - u_h2)^2,
    w_diff_sq = (w_h1 - w_h2)^2,
    uw_cross = (u_h1 - u_h2) * (w_h1 - w_h2)
  )

# Calculate variance components
sum_u_diff_sq <- sum(paired_diff$u_diff_sq)
sum_w_diff_sq <- sum(paired_diff$w_diff_sq)
sum_uw_cross <- sum(paired_diff$uw_cross)

var_bmi <- (1 / w_total^2) * (sum_u_diff_sq + 
                                r_bmi^2 * sum_w_diff_sq - 2 * r_bmi * 
                                sum_uw_cross)
se_bmi <- sqrt(var_bmi)

# 99% CI
ci_lower <- r_bmi - qt_value * se_bmi
ci_upper <- r_bmi + qt_value * se_bmi

tibble(
  Mean_BMI = r_bmi,
  Variance = var_bmi,
  SE = se_bmi,
  CI_Lower = ci_lower,
  CI_Upper = ci_upper
) |> 
  mutate(across(everything(), ~round(.x, 3))) |> 
  kable()
```

\newpage

### (e) Compute the proportion of women who have ever been pregnant and its standard error.

The proportion is estimated as a weighted ratio mean:

$$
p_w = r_w = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} v_{h\alpha}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} w_{h\alpha}}
$$

The sampling variance using paired selection is:

$$
\text{var}(p_w) \approx \frac{1}{w^2} \left[ \sum_{h=1}^{H} (v_{h1} - v_{h2})^2 + r^2 \sum_{h=1}^{H} (w_{h1} - w_{h2})^2 - 2r \sum_{h=1}^{H} (v_{h1} - v_{h2})(w_{h1} - w_{h2}) \right]
$$

```r
v_total <- sum(results_c$v_ha)
r_prop <- v_total / w_total

# Calculate paired differences for proportion
paired_diff_p <- results_c |> 
  group_by(STRATUM) |> 
  summarise(
    v_h1 = first(v_ha),
    v_h2 = last(v_ha),
    w_h1 = first(w_ha),
    w_h2 = last(w_ha),
    .groups = "drop"
  ) |> 
  mutate(
    v_diff_sq = (v_h1 - v_h2)^2,
    w_diff_sq = (w_h1 - w_h2)^2,
    vw_cross = (v_h1 - v_h2) * (w_h1 - w_h2)
  )

# Calculate variance components
sum_v_diff_sq <- sum(paired_diff_p$v_diff_sq)
sum_w_diff_sq_p <- sum(paired_diff_p$w_diff_sq)
sum_vw_cross <- sum(paired_diff_p$vw_cross)

var_prop <- (1 / w_total^2) * (sum_v_diff_sq + 
                                 r_prop^2 * 
                                 sum_w_diff_sq_p - 2 * r_prop * sum_vw_cross)
se_prop <- sqrt(var_prop)

results_e <- tibble(
  Proportion = r_prop,
  Variance = var_prop,
  SE = se_prop
)

results_e |> 
  mutate(across(everything(), ~round(.x, 4))) |> 
  kable()
```

\newpage

### (f) Compute the design effect and roh for the proportion in (e).

The simple random sampling variance is:

$$
\text{var}_{SRS}(p) = \frac{p(1-p)}{n-1} = \frac{r(1-r)}{\bar{x} - 1}
$$

where $\bar{x} = \sum w_{h\alpha}$ is the estimated population size (sum of weights = 8,577.5, but for SRS variance we use the actual sample size n = 40).

```r
# SRS variance using actual sample size
var_srs <- (r_prop * (1 - r_prop)) / (n - 1)

# Design effect
deff <- var_prop / var_srs

# roh using average cluster size b = 4
roh <- (deff - 1) / (b - 1)

tibble(
  Var_SRS = var_srs,
  Var_Complex = var_prop,
  deff = deff,
  roh = roh
) |> 
  mutate(across(everything(), ~round(.x, 4))) |> 
  kable()
```

\newpage

### (g) Is the Taylor series approximation adequate for this problem?

The coefficient of variation of the denominator is:

$$
cv(w) = \frac{se(w)}{w} = \frac{\sqrt{\sum_{h=1}^{H} \frac{a_h}{a_h - 1} \left( \sum_{\alpha=1}^{a_h} w_{h\alpha}^2 - \frac{w_h^2}{a_h} \right)}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} w_{h\alpha}}
$$

For paired selection, this simplifies to:

$$
cv(w) = \frac{\sqrt{\sum_{h=1}^{H} (w_{h1} - w_{h2})^2}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} w_{h\alpha}}
$$

```r
cv_results <- paired_diff |> 
  summarise(
    var_w = sum(w_diff_sq),
    se_w = sqrt(var_w),
    sum_w = w_total,
    cv_w = se_w / sum_w
  )

cv_results |> 
  select(cv_w) |> 
  mutate(across(everything(), ~round(.x, 4))) |> 
  kable(col.names = c("CV(w)"))
```

Since $cv(w)$ is smaller than 0.20, the Taylor series approximation to the sampling variance estimation is **adequate**.

\newpage

### (h) \[OPTIONAL\] Estimate the expected variance if the sample size were doubled by doubling the number of primary selections.

Doubling the number of clusters from $a = 10$ to $a = 20$ doubles the overall sample size from $n = 40$ to $n = 80$, but does not alter the subsampling features. The expected sampling variance is based on the same design effect:

$$
\text{var}_{a=20}(p) = \text{var}_{SRS, n=80}(p) \times \text{deff}(p)
$$

```r
n_new <- 80
var_srs_new <- (r_prop * (1 - r_prop)) / (n_new - 1)
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
  kable()
```

### (i) \[OPTIONAL\] Estimate the expected variance if sample size were reduced by half using a within-cluster sampling rate half as large.

Reducing sample size from $n = 40$ to $n = 20$ by halving the within-cluster sampling rate changes the design effect:

$$
\text{deff}_{new}(p) = 1 + \rho(b_{new} - 1) = 1 + \rho\left(\frac{b}{2} - 1\right)
$$

```r
b_new <- b / 2  # = 2
n_new_i <- 20

deff_new <- 1 + roh * (b_new - 1)
var_srs_new_i <- (r_prop * (1 - r_prop)) / (n_new_i - 1)
var_new_i <- var_srs_new_i * deff_new

tibble(
  b_new = b_new,
  n_new = n_new_i,
  deff_new = deff_new,
  var_new = var_new_i
) |> 
  mutate(across(where(is.numeric), ~round(.x, 4))) |> 
  kable()
```

\newpage

## Problem 2: Assignment Feedback

### (a) Time Spent

-   Approximately 7 hours to complete all parts.

### (b) Difficulty Rating

-   **Rating: 8/10** - The assignment was challenging. To me it was confusing how to calculate roh for a clustering effect.

\newpage

# Appendix: Summary of Key Formulas

## Sampling Weights

$$
w_{h\alpha\beta} = \left[ \Pr\{h\alpha\beta\} \right]^{-1} = \left[ \frac{a_h}{A_h} \times \frac{b}{B_{h\alpha}} \right]^{-1}
$$

## Unequal Weighting Effect (UWE)

$$
1 + L = n \frac{\sum_{i=1}^{n} w_i^2}{\left(\sum_{i=1}^{n} w_i\right)^2}
$$

## Weighted Ratio Mean

$$
\bar{y}_w = r_w = \frac{\sum \sum \sum w_{h\alpha\beta} y_{h\alpha\beta}}{\sum \sum \sum w_{h\alpha\beta}}
$$

## Paired Selection Variance (ignoring fpc)

$$
\text{var}(\bar{y}_w) \approx \frac{1}{w^2} \left[ \sum_{h=1}^{H} (u_{h1} - u_{h2})^2 + r^2 \sum_{h=1}^{H} (w_{h1} - w_{h2})^2 - 2r \sum_{h=1}^{H} (u_{h1} - u_{h2})(w_{h1} - w_{h2}) \right]
$$

## Design Effect and roh

-   $\text{var}_{SRS}(p) = \frac{p(1-p)}{n-1}$
-   $\text{deff} = \frac{\text{var}(p)}{\text{var}_{SRS}(p)}$
-   $\rho = \frac{\text{deff} - 1}{b - 1}$

## CV Threshold for Taylor Series

Taylor series approximation is adequate when $cv(w) < 0.20$
