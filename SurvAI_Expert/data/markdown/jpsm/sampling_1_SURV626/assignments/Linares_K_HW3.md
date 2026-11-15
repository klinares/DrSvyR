---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW3"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 3"
original: "sampling_1_SURV626/assignments/Linares_K_HW3.qmd"
pages: 
sha256: "1c7670ae53a6e865e4d582836f7461fb752a375d80b250e92d95458f158c3d60"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:11"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(knitr, readxl, tidyverse)

options(scipen=999)
```

1.  The Excel file 'SURV 626 HW3 data fall 25.xls' contains the data from a stratified random sample of size n = 40 from the N = 9,300 individuals. The population sizes of each stratum are the following:

```r
# read in HW 3 data
repo_path <- "d:/repos/UMD_classes_code/sampling_1_SURV626/"

BMI <- read_excel(str_c(repo_path, 
                             "assignments/HW3_data.xlsx"), 
                       sheet = "Stratified sample") 
```

| Stratum     | $N_h$ |
|-------------|-------|
| 1           | 2,319 |
| 2           | 2,583 |
| 3           | 2,265 |
| 4           | 1,284 |
| 5           | 849   |
| Grand Total | 9,300 |

-   We calculate the stratum weights as $W_h = N_h/N$, the proportion of the population in stratum $h$.

```r
strata <- tibble(STRATUM = seq(1, 5),
              N_h = c(2319, 2583, 2265, 1284, 849)) |>
  mutate(W_h = N_h / sum(N_h))
```

-   \(a\) Estimate the mean Body Mass Index (BMI), its standard error and 95% confidence interval.
    -   We will calculate the sampling mean for each stratum as $\bar{y}_h = \frac{1}{n_h}\sum_{i=1}^{n_h}y_{hi}$ and combine the population parameters. Additionally, we will compute the sampling element variance of each stratum as $s^2_h = \frac{1}{n_h - 1} \sum_{i=1}^{n_h} (y_{hi} - \bar{y}_h)^2$. We then use the sampling element variance to compute the variance of the population mean as:

$$
\text{var}(\bar{y}_w) = \sum_{h=1}^H W_h^2 \text{var}(\bar{y}_h) = \sum_{h=1}^H W_h^2 (1-f_h) \frac{s_h^2}{n_h}
$$

```r
BMI_stratum <- BMI |> 
  group_by(STRATUM) |> 
  summarise(
    n_h = n(),
    y_h_bar = mean(BMI), 
    s_2_h = var(BMI),
    # proportion of being pregnant for Q b
    p_h = mean(EVERPREG),
    s_h = sd(BMI)
    ) |> 
  left_join(strata, by = "STRATUM") |> 
  mutate(f_h = n_h / N_h,
         var_y_h = (1 - f_h) * s_2_h / n_h)

BMI_stratum |> kable()
```

-   The overall population mean is the sum of the weighted stratum means:

$$
\bar{y}_w = \sum_{h=1}^H W_h \bar{y}_h 
$$

```r
Y_bar <- BMI_stratum |> 
  summarise(y_bar_w = sum(W_h * y_h_bar)) |> 
  pull()
Y_bar
```

-   The population mean for women's BMI is `r round(Y_bar, 3)`, which falls in the overweight category.

```r
var_Y <- BMI_stratum |> 
  summarise(var_y_w = sum(W_h^2 * var_y_h)) |>
  pull()
var_Y

se_w <- sqrt(var_Y)
```

-   The variance of the mean BMI is `r round(var_Y, 3)` with an estimated standard error of $se(\bar{y}_w) = \sqrt{\text{var}(\bar{y}_w)}$ = `r round(se_w, 3)`.

-   With the population mean and standard error we can calculate 95% confidence intervals as $\bar{y}_w \pm t_{1-\alpha/2; n-H} \cdot se(\bar{y}_w)$ where the degrees of freedom is $df = n - H$.

```r
df <- 40 - 5 # sample size - number of strata

# use the standard error to compute 95% CI
qt_value <- .975 # quantile function to use
Mean_CI <- c(Y_bar - qt(qt_value, df) * se_w, 
             Y_bar + qt(qt_value, df) * se_w)

# add average age with CI
Mean_CI <- append(Y_bar, Mean_CI) |> unlist() |> round(3)
# label CI
names(Mean_CI) <- c("mean", "lower", "upper")
print(Mean_CI |> round(3)) 
```

\

-   \(b\) Estimate the proportion of women who have ever been pregnant (EVERPREG = 1) and its standard error.

    -   We calculated the proportion of being pregnant in each stratum in question a. The weighted proportion is:

$$
p_w = \sum_{h=1}^H W_h p_h
$$

The variance of the population proportion estimate is:

$$
\text{var}(p_w) = \sum_{h=1}^H W_h^2 \text{var}(\bar{y}_h) = \sum_{h=1}^H W_h^2 \frac{(1-f_h)}{n_h-1} p_h(1-p_h)
$$

-   The standard error is $se(p_w) = \sqrt{\text{var}(p_w)}$.

```r
Pregnant <- BMI_stratum |> 
  summarise(
    P = sum(W_h * p_h),
    var_P = sum(W_h^2 * ((1 - f_h) / (n_h - 1)) * p_h * (1 - p_h))
  ) |> 
  mutate(se_p = sqrt(var_P))

Pregnant |> 
  mutate(across(everything(), ~round(.x, 4))) |> 
  kable()
```

-   The proportion of women ever being pregnant in the population is `r round(Pregnant$P, 2)` (se = `r round(Pregnant$se_p, 4)`).

\

-   \(c\) Compute the design effects for the mean BMI and the proportion of women who have ever been pregnant. Discuss their difference.

    -   To compute the design effects, a measure that quantifies how much the complex design changes variance compared to SRS, we first must compute the variance under SRS. We estimate $S^2$ using:

$$
S^2 \approx \sum_{h=1}^H W_h S_h^2 + \sum_{h=1}^H W_h (\bar{Y}_h - \bar{Y})^2
$$

We estimate this as:

$$
s^2 \approx \sum_{h=1}^H W_h s_h^2 + \sum_{h=1}^H W_h (\bar{y}_h - \bar{y}_w)^2
$$

The sampling variance for the mean BMI under SRS is:

$$
\text{var}_{SRS}(\bar{y}) = \frac{1-f}{n} s^2
$$

The design effect is:

$$
\text{deff}(\bar{y}_w) = \frac{\text{var}(\bar{y}_w)}{\text{var}_{SRS}(\bar{y})}
$$

```r
f <- 40 / 9300
n <- 40

var_y_srs <- BMI_stratum |> 
  summarise(
    y_bar_w = sum(W_h * y_h_bar),
    s_sqrd = sum(W_h * s_2_h) + sum(W_h * (y_h_bar - y_bar_w)^2),
    var_y_srs = ((1 - f) / n) * s_sqrd
  ) |> 
  pull(var_y_srs)

var_y_srs

deff_bmi <- var_Y / var_y_srs
deff_bmi
```

-   For the mean BMI, the design effect is `r round(deff_bmi, 3)`, indicating the stratified design has slightly higher variance than SRS would have with this equal allocation.

An estimate for $S^2$ of the proportion of women who have ever been pregnant can be estimated as:

$$
s^2 \approx \sum_{h=1}^{H} W_h \frac{n_h}{n_h - 1} p_h(1 - p_h) + \sum_{h=1}^{H} W_h (p_h - p_w)^2
$$

Hence, the sampling variance for the proportion of women who have ever been pregnant under SRS is:

$$
\text{var}_{SRS}(p) = \frac{1 - f}{n} s^2 
$$

Therefore, the design effect for the proportion of women who have ever been pregnant for this stratified sample is:

$$
\text{deff}(p_w) = \frac{\text{var}(p_w)}{\text{var}_{SRS}(p)} 
$$

```r
var_p_srs <- BMI_stratum |> 
  summarise(
    p_w = sum(W_h * p_h),
    s_sqrd = sum(W_h * (n_h / (n_h - 1)) * p_h * (1 - p_h)) + 
             sum(W_h * (p_h - p_w)^2),
    var_p_srs = ((1 - f) / n) * s_sqrd
  ) |> 
  pull(var_p_srs)

var_p_srs

deff_pregnant <- Pregnant$var_P / var_p_srs
deff_pregnant
```

-   For the proportion of ever pregnant, the design effect is `r round(deff_pregnant, 4)`. The design effect for the proportion is slightly smaller than for BMI, reflecting that stratification with equal allocation is slightly more effective for the proportion than for mean BMI.

\

-   \(d\) Based on the estimates from the sample, what is the proportionate allocation across the strata, the standard error of the mean BMI under that allocation, and the design effect of the mean of the proportionately allocated sample?

-   The proportionate allocation is given by $n_h = W_h \times n$. Under proportionate allocation, the sampling variance of the mean is:

$$
\text{var}(\bar{y}_{prop}) = \frac{1-f}{n} \sum_{h=1}^{H} W_h s_h^2
$$

```r
BMI_stratum <- BMI_stratum |>
  mutate(
    # proportionate allocation
    n_h_prop = round(W_h * n)
  )

# Display proportionate allocation
BMI_stratum |> select(STRATUM, W_h, n_h_prop) |> kable()

# Calculate variance under proportionate allocation
var_prop <- BMI_stratum |> 
  summarise(
    var_prop = ((1 - f) / n) * sum(W_h * s_2_h)
  ) |> 
  pull()

se_prop <- sqrt(var_prop)

deff_prop <- var_prop / var_y_srs

tibble(var_prop, se_prop, deff_prop) |> kable()
```

-   With proportionate allocation the design effect is `r round(deff_prop, 3)`, which is less than 1, indicating the proportionate allocation is more efficient than SRS.

\

-   \(e\) Based on the estimates from the sample, what is the Neyman allocation across the strata, the standard error of the mean BMI under that allocation, and the design effect of the mean of the Neyman allocation?

    -   The Neyman allocation minimizes the variance of the estimated mean when costs are equal across strata. It oversamples strata with higher variance. The Neyman allocation is given by:

$$
n_h = n \frac{W_h s_h}{\sum_{l=1}^H W_l s_l}
$$

Under Neyman allocation, the sampling variance is:

$$
\text{var}(\bar{y}_N) = \sum_{h=1}^H W_h^2 (1-f_h) \frac{s_h^2}{n_h}
$$

```r
BMI_stratum <- BMI_stratum |> 
  mutate(
    # Neyman allocation
    n_h_ney = round(n * (W_h * s_h) / sum(W_h * s_h))
  )

# Display Neyman allocation
BMI_stratum |> select(STRATUM, W_h, s_h, n_h_ney) |> kable()

# Calculate variance under Neyman allocation
var_ney <- BMI_stratum |> 
  mutate(
    f_h_ney = n_h_ney / N_h,
    var_h_ney = W_h^2 * (1 - f_h_ney) * s_2_h / n_h_ney
  ) |> 
  summarise(var_ney = sum(var_h_ney)) |> 
  pull()
            
se_ney <- sqrt(var_ney)

# Design effect
deff_ney <- var_ney / var_y_srs

tibble(var_ney, se_ney, deff_ney) |> kable()
```

-   The design effect of `r round(deff_ney, 3)` under Neyman allocation shows it is more efficient than both SRS and proportionate allocation, as expected since Neyman allocation is optimal for minimizing variance.

## Problem 2: Assignment Feedback

### (a) Time Spent

-   Approximately 5.5 hours to complete all parts mostly converting equations to r-code.

### (b) Difficulty Rating

-   **Rating: 7/10** - The assignment was moderately challenging. The lecture notes and books were used to complete this assignment, but I did need to google how to interpret certain estimates.
