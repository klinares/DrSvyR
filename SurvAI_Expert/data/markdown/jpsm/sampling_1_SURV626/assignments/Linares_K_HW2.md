---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW2"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 2"
original: "sampling_1_SURV626/assignments/Linares_K_HW2.qmd"
pages: 
sha256: "f8959db15c2db3126f014581b99cb3744f86496525bc959d7ca6c00eb4d0fc74"
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

1.  The Excel file ‘SURV 626 HW1 data fall 25.xls’ contains a list of a population of N = 9,300 young women. Draw an SRS of size n = 40 using the random number table in ‘SURV 626 Random Digits fall 25’. For the sake of replication, select the sample random numbers starting at the upper left corner, row 1, columns 1-4 (first number, 4901). Continue selecting numbers moving down columns 1-4. If more than 50 random numbers are needed to select the sample (that is, all 50 numbers in columns 1-4 have been used), continue with row 1, columns 6-9 (number 3404). Then answer the following questions about the sample: \[Hint: You can use the ‘Sample’ tab in the Excel file ‘SURV 626 HW1 data fall 25.xls’ to get the selected sample by inserting the selected random numbers in the ‘Sample ID’ column\]

```r
# read in HW 2 data
repo_path <- "d:/repos/UMD_classes_code/sampling_1_SURV626/"

pop_data <- read_excel(str_c(repo_path, 
                             "assignments/HW2_data.xls"), 
                       sheet = "Sampling frame") 

# read in random digits table
random_digits <- read_excel(str_c(repo_path, 
                                  "assignments/Random_Digits.xlsx"), sheet = 1)

# population and same size
N <- nrow(pop_data)
n <- 40 # SRS sample
```

-   \(a\) We use the random digits table to select 40 values from the first 4 columns. To do so, we needed to convert digits to 1,000s by dropping the last value. We then loop through the first four columns (column 1 first, followed by column 2, . . . , column 4) and select the first n=40 values that fall between 1 and N=9,300, this ensures sampling without replacement. Our SRS method is to select from the sampling frame the ids that correspond to the random digits we pulled from the table.

```r

# using the first four columns of the random digits table, 
# columns to keep
col_n <- 4

random_digit_vector <- random_digits |> 
  # keep needed columns
  select(1:col_n) |>
  # give columns new names
  rename_all(~str_c(rep("col", col_n), 1:4)) |> 
  # stack columns
  pivot_longer(everything()) |>
  # rearrange values
  arrange(name) |> 
  # remove last digit
  mutate(value = as.numeric(str_sub(value, end=-2)) ) |> 
  pull(value)

random_digit_to_keep <- map_dfr(random_digit_vector, 
                                function(x){
  
  if(between(x, 1, N)){
    dat = tibble(value=x)
  } else{
    dat = tibble(value=NA)
  }
  return(dat)
}) |> 
  # only keep values under N
  drop_na() |> 
  # keep n digits
  slice(1:n) |> 
  pull()

# apply SRS to the sampling frame and print table
sample_data <- pop_data |> 
  filter(ID %in% random_digit_to_keep)

sample_data |> 
  kable()

```

\newpage

-   \(b\) Estimate the mean Body Mass Index (BMI) and compare it to the population mean BMI. If they differ, give a brief explanation why.

    -   For a SRS of n=40, the mean BMI was 27.23 and for the population 27.87. When we draw a sample from the population, we are typically taking a subset of the population with some inherent randomness. Each sample are slightly different thus leading to variation in the estimate, and this is called sampling variation. Sampling error also contributes to this discrepancy, which is the difference between the sample mean and population mean, and it is unavoidable due to the random nature of sampling from a population. As the sample size increase, the distribution of the sample means approximates the population mean due to the central limit theorem, which states that more samples eventually converges to a normal distribution.

```r
y_bar <- sample_data |> 
  summarise(sum(BMI)/n()) |> 
  pull()

y_pop <- pop_data |> 
  summarise(sum(BMI)/n()) |> 
  pull()

tibble(Mean = c("Population", "Sample"),
       Estimate = c(y_pop, y_bar)) |> 
  kable()
  
```

-   \(c\) Estimate the element variance of the BMI, the sampling variance and standard error of the mean BMI using the sample data.

    -   We use the following formula to calculate the sampling element variance.

$$
s^2 = \frac{1}{n-1}\sum^n_{i=1}(y_i - \bar{y})
$$

```r
s_sqrd <- sample_data |> 
  summarise(
    (1 / (n() - 1) ) * (sum( (BMI - mean(BMI))^2))) |> 
  pull()

```

-   To estimate the element variance we first must calculate the finite population correction (FPC) factor for our population of 9,300 as $f = n/N = 40/9300$.

```r
f <- n/N
```

-   With $s^2$ and the FPC we can now calculate the estimated sampling variance and standard error, $\sqrt{var(\bar{y})}$.

$$
var(\bar{y}) = (1-f)\frac{s^2}{n}
$$

```r
var <- sample_data |> 
  summarise( (1-f) * (s_sqrd/n())) |> 
  pull()

se <- sqrt(var)

tibble(Estimates = c("Samp Element Var", "FPC",  "Sampling Var", "Stand. Error"),
       Value = c(s_sqrd, f, var, se)) |> 
  mutate(Value = round(Value, 4) ) |> 
  kable()
```

### 

-   \(d\) Compute a 95% confidence interval for the mean BMI using the sample data.

    -   We use the standard error to compute 95% confidence intervals, which indicate the accuracy of the BMI sampling mean estimate. If we were to take samples fromt eh same population and construct a confidence interval, we would expect 95% of the resulting intervals to include the true value of the population parameter. Out 95% CI is given as:

$$
\bar{y} \pm t_{1-\alpha / 2, n-1}\times se(\bar{y})
$$

```r
# use the standard error to compute 95% CI
qt_value <- .975 # quantile function to use
Mean_CI <- c(y_bar - qt(qt_value, n-1) * se, 
             y_bar + qt(qt_value, n-1) * se)

# add average age with CI
Mean_CI <- append(y_bar, Mean_CI) |> unlist() |> round(3)
# label CI
names(Mean_CI) <- c("mean", "lower", "upper")
print(Mean_CI |> round(3)) 
```

### 

-   \(e\) Estimate the proportion of women who have ever been pregnant (EVERPREG = 1), its standard error and 95% confidence interval using the sample data.

    -   The proportion of is calculated as $\hat{p}$ and the sampling variance is given in the following expression for $var(\hat{p})$ and the standard error is the square root of this variance.

$$
var(\hat{p}) = \frac{(1-f)}{n-1} p(1-p)
$$

```r
p_hat <- sample_data |> 
  summarise(mean(EVERPREG)) |> 
  pull()

var_p <- ((1-f) / (n-1)) * (p_hat*(1-p_hat))
se_p <- sqrt(var_p)


Mean_CI <- c(p_hat - qt(qt_value, n-1) * se_p, 
             p_hat + qt(qt_value, n-1) * se_p)

# add average age with CI
Mean_CI <- append(p_hat, Mean_CI) |> unlist() |> round(3)
# label CI
names(Mean_CI) <- c("mean", "lower", "upper")
print(Mean_CI |> round(3)) 

```

-   \(f\) If the sample size of an SRS from this population were increased from n = 40 to n = 100, what would be the estimated standard error of the mean BMI?

    -   If we increased the sample to n=100, the sampling variance gets smaller, and the standard error also gets smaller as it begins to approximate the population's representation. Furthermore, with more observations the impact of outliers are minimized, leading to more stable and reliable sample means, hence lower variability.

```r
n_new <- 100

se_new <- sqrt(((1-n_new/N) * s_sqrd) / n_new)
se_new
```

### 

-   \(g\) What sample size n for an SRS from this population is needed to achieve a coefficient of variation of at most 0.025 for both the mean BMI and the proportion of women who have ever been pregnant?

    -   To meet a cv of .025 fo the BMI sample mean, we need a sample size of 132, we calculate this by taking the cv x $\bar{y}$ and applying it in the following expression.

$$
n = \frac{s^2}{ (cv\times \bar{y})^2 + \frac{s^2}{N}}
$$

```r
cv <- .025
s_sqrd / ((y_bar * cv)^2 + (s_sqrd/N))

```

-   For $\hat{p}$ with a desired cv of .025, we would need a sample size of 274, therefore, we choose this sample size to meet or exceed the desired cv for both the bmi mean and proportion of ever pregnant.

```r
(p_hat*(1-p_hat)) / (
  (p_hat * cv)^2 + ( (p_hat*(1-p_hat)) /N))
```

### 

## Problem 2: Assignment Feedback

### (a) Time Spent

-   Approximately 4.5 hours to complete all parts mostly in getting working code to use the random digits table.

### (b) Difficulty Rating

-   **Rating: 6/10** - The assignment was moderately challenging. The concepts were straightforward from the lecture materials, but implementing the random number selection procedure and ensuring all calculations were correct required careful attention to detail. The formulas for sampling variance and confidence intervals required referencing the lecture notes and videos.
