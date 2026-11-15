---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW4"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 4"
original: "sampling_1_SURV626/assignments/Linares_K_HW4.qmd"
pages: 
sha256: "91ae3dcf59b4ee4c6f8ec0a4afdb10ddf0767d30f4980ffcf94f6e6aceb15631"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:17"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(knitr, readxl, tidyverse)

options(scipen=999)
```

1.  The Excel file 'SURV 626 HW4 data fall 25.xls' contains a list of a population of N = 9,300 young women sorted by their weight (in pounds). Draw a systematic sample of size n = 40. Select a random start using the random number table in 'SURV 626 Random Digits fall 22.pdf' in the same folder. For the sake of replication, select your random start number starting at the upper left corner, row 1, columns 1-4 (first number, 4901). Use a random start with only one decimal place. Then answer the following questions about the sample:

```r
# read in HW 4 data
repo_path <- "d:/repos/UMD_classes_code/sampling_1_SURV626/"

BMI <- read_excel(str_c(repo_path, 
                             "assignments/HW4_data.xls"), 
                       sheet = "Sampling frame systematic") 

# read in random digits table
random_digits <- read_excel(str_c(repo_path, 
                                  "assignments/Random_Digits.xlsx"), sheet = 1)

# using the first four columns of the random digits table, 
# columns to keep
col_n <- 4

random_digits <- random_digits |> 
  # keep needed columns
  select(1:col_n) |>
  # give columns new names
  rename_all(~str_c(rep("col", col_n), 1:4)) |> 
  # stack columns
  pivot_longer(everything()) |>
  # rearrange values
  arrange(name) |> 
  # remove last digit to get one decimal place
  mutate(value = as.numeric(str_sub(value, end = -2)))
```

-   \(a\) List the ID numbers (ID), weight (WEIGHT), and the two survey variables (BMI and EVERPREG) of the sampled elements.
    -   With our random start we can generate a sequence of selection points and convert them to integers in order to select the IDs from the data. The systematic sample consists of elements at positions $RS + (n-1)k$ where $RS$ is the random start and $k$ is the sampling interval.

```r
# pop size
N <- nrow(BMI)
n <- 40 # sample size

# sampling interval 
k <- N / n 

# random digits convert to decimal for last digit
random_digits <- random_digits |> 
  mutate(rd = value / 10)

# Find random start: first value between 0.1 and k (232.5)
rs <- random_digits |> 
  filter(rd >= 0.1, rd <= k) |> 
  slice(1) |> 
  pull(rd)

# Generate selection points using RS + (n-1)*k formula
# and round to nearest integer for ID selection
select_positions <- floor(rs + (0:(n-1)) * k)

BMI_sample <- BMI |>
  filter(ID %in% select_positions) 
```

\newpage

```r
BMI_sample |> kable()
```

\

-   \(b\) What was the sampling interval used to select this sample?

    -   For a systematic sample of size $n$ from a population of size $N$, the sampling interval is:

$$
k = F = \frac{1}{f} = \frac{N}{n}
$$

```r
cat("Sampling interval k = N/n =", N, "/", n, "=", k, "\n")
```

\

-   \(c\) What was the random start used to select this sample?

    -   We search through the random digits (converted to one decimal place) until we find a value between 0.1 and 232.5 (the sampling interval). The random start is 122.5.

```r
cat("The random start must be a number between 0.1 and", k, "\n")
cat("Random start RS =", rs)
```

\newpage

-   \(d\) Estimate the mean BMI and its standard error, using an appropriate variance estimation model. Give reasons why you chose the variance estimation model.

The mean BMI is:

$$
\bar{y} = \frac{\sum_{i=1}^{n} y_i}{n}
$$

We use the **successive differences model** because the list was ordered by weight, which is a numerical variable. The boundaries between implicit strata are not well-defined, so this model captures the gains in precision from systematic sampling with an ordered list. The successive differences variance estimator is:

$$
\text{var}(\bar{y}) = \frac{(1-f)}{2n(n-1)} \sum_{g=1}^{n-1} (y_g - y_{g+1})^2
$$

where $y_g$ is the value of the $g^{th}$ sampled element in its sorted order and $f = n/N$ is the sampling fraction.

```r
# Finite Population Correction (fpc)
f <- n / N

BMI_estimates <- BMI_sample |> 
  summarise(
    BMI_mean = mean(BMI),
    # Successive differences: sum of squared differences between consecutive elements
    sum_sq_diff = sum((BMI - lead(BMI))^2, na.rm = TRUE),
    var_y = ((1 - f) / (2 * n * (n - 1))) * sum_sq_diff,
    se_y = sqrt(var_y)
  ) |> 
  select(-sum_sq_diff)

BMI_estimates |> kable(digits = 3)
```

The successive differences model was chosen because the list was ordered by weight, which is a numerical variable and hence the "boundaries" between the zones are not very well defined. Using this model captures completely the gains in precision we are having by using systematic sampling with this ordered list.

**Alternative: Paired Selection Model**

Alternatively, a paired selection model could be used:

$$
\text{var}(\bar{y}) = \frac{(1-f)}{n^2} \sum_{h=1}^{n/2} (y_{h1} - y_{h2})^2
$$

```r
# Paired selection model
BMI_paired <- BMI_sample |> 
  mutate(pair = rep(1:(n/2), each = 2)) |> 
  group_by(pair) |> 
  summarise(diff_sq = diff(BMI)^2) |> 
  ungroup() |> 
  summarise(
    var_y_paired = ((1 - f) / n^2) * sum(diff_sq),
    se_y_paired = sqrt(var_y_paired)
  )

BMI_paired |> kable(digits = 3)
```

\newpage

-   \(e\) Do you expect that the design effect of the mean BMI under this design to be smaller or greater than 1? Explain.

    -   The design effect for the mean BMI under this design is expected to be **smaller than one**, because the variable used for ordering the frame (weight) is highly correlated with BMI. The implicit stratification created by this list order and systematic sampling provides gains in precision for the mean BMI.

```r
# Calculate correlation between BMI and WEIGHT
correlation <- cor(BMI_sample$BMI, BMI_sample$WEIGHT)
cat("Correlation between BMI and WEIGHT:", round(correlation, 3), "\n")

# SRS variance for comparison
var_srs <- BMI_sample |> 
  summarise(
    var_srs = (1 - f) * var(BMI) / n
  ) |> 
  pull()

# Design effect
deff <- BMI_estimates$var_y / var_srs

cat("SRS Variance:", round(var_srs, 3), "\n")
cat("Systematic Sample Variance:", round(BMI_estimates$var_y, 3), "\n")
cat("Design effect:", round(deff, 3), "\n")
```

Since the design effect is less than 1, systematic sampling with the ordered list is more efficient than SRS for estimating mean BMI.

\

-   \(f\) \[OPTIONAL\] Estimate the proportion of women who have ever been pregnant (EVERPREG = 1) and its standard error.

The sample proportion is:

$$
p = \frac{z}{n} = \frac{\sum_{i=1}^{n} z_i}{n}
$$

Using the successive differences model for the proportion:

$$
\text{var}(p) = \frac{(1-f)}{2n(n-1)} \sum_{g=1}^{n-1} (z_g - z_{g+1})^2
$$

```r
prop_estimates <- BMI_sample |> 
  summarise(
    p = mean(EVERPREG),
    sum_sq_diff = sum((EVERPREG - lead(EVERPREG))^2, na.rm = TRUE),
    var_p = ((1 - f) / (2 * n * (n - 1))) * sum_sq_diff,
    se_p = sqrt(var_p)
  ) |> 
  select(-sum_sq_diff)

prop_estimates |> kable(digits = 4)
```

While there is some association between having ever been pregnant and weight (the ordering variable), this association is likely not as strong as the correlation between BMI and weight. Therefore, the gains in precision for this proportion due to the implicit stratification by weight is probably not as large as for the mean BMI, and the design effect of the proportion is expected to be larger than the design effect of the mean BMI.

```r
# Compare mean BMI by pregnancy status
BMI_sample |> 
  group_by(EVERPREG) |> 
  summarise(
    n = n(),
    mean_BMI = mean(BMI),
    mean_WEIGHT = mean(WEIGHT)
  ) |> 
  kable(digits = 2)
```

\

## Problem 2: Assignment Feedback

### (a) Time Spent

-   Approximately 3.5 hours to complete all parts mostly understanding the stratified sorting approach.

### (b) Difficulty Rating

-   **Rating: 6/10** - The assignment was moderately challenging. The lecture notes and books were used to complete this assignment, but I did need to google how to take neighboring differences in BMI cases using the lag().
