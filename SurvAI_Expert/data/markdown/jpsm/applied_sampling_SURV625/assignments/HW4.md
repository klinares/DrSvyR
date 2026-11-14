---
id: "jpsm/applied_sampling_SURV625/assignments/HW4"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "assignment"
title: "Homework 4"
original: "applied_sampling_SURV625/assignments/HW4.qmd"
pages: 
sha256: "60d51bca25ee8490c42d6eac7911d6abd33fb58e379f6887d32f6e14bc790d56"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T14:15:59"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(knitr, tidyverse)

options(scipen=999)
```

## 1. The following data were collected from a sample of n = 10 clusters that was selected from a large population (assume that the sampling fractions are negligible):

```r
# build the table
dat <- tibble(
  i = seq(1, 10, 1),
  t_y = c(5, 1, 2, 4, 2, 2, 3, 3, 4, 6),
  t_x = c(13, 11, 7, 11, 6, 11, 5, 11, 9, 10)
)

dat |> kable()
```

a). Compute the ratio mean $r = y/x$ where $y=\sum_it_{y,i}$ is the total outcome and $x=\sum_it_{x,i}$ is the realized sample size, and its standard error. Note that this is an example of simple random sampling of unequal-sized clusters. Use the ultimate cluster idea for variance estimation purposes (i.e., we don’t really care how many stages of cluster sampling led to the realized sample sizes in each cluster; we assume a one-stage selection of ultimate clusters, where all units were sampled within them).

```r
# ratio mean 
r <- dat |> summarise(sum(t_y)/sum(t_x)) |> pull() ; r

results_a <- dat |> 
  # calculate ratio for each cluster
  mutate(r_i = t_y / t_x) |> 
  # variance calculation 
  summarise(
    # VAR(R)
    VAR_R =  (1/sum(t_x)^2) * 
      (n() / (n()-1)) * 
      (sum(t_y^2) + r^2 * sum(t_x^2) - (2*r) * sum(t_y*t_x)),  
    # SE(R))
    SE_R = sqrt(VAR_R)
  ) 

results_a |> kable()
```

-   The ratio mean is `r round(r, 2)` with a standard error of `r round(results_a |> pull(SE_R), 2)`.

\

b)  The mean is actually the proportion of individuals with a particular attitude (meaning that the Y variable is a binary indicator of whether a person has that attitude). Given this information, compute the simple random sampling variance, design effect, and roh. (Hint: Remember that when computing the design effect for these designs, the average sample size per cluster should be used.)

$$
var(r) = \frac{1}{\hat{t}^2_x} \frac{n}{n-1}(\sum_i \hat{t}^2_{y, i} + r^2 \sum_i \hat{t}^2_{x, i} - 2r \sum_i \hat{t}_{y, i} \hat{t}_{x,i})
$$

-   We estimate the variance for an SRS, a design effect using the previously calculated variance and use the deff estimate to calculate roh.

```r
results_b <- dat |> 
  summarise(
    # compute sampling variance as p(1-p) / X
    var_srs = (r *(1-r)) / (sum(t_x)-1) ,
    # Deff we use the cluster variance calculated above
    deff = results_a$VAR_R / var_srs,
    # roh/ICC calculate with average cluster size
    roh = (deff - 1) / (mean(t_x)-1)
  )

results_b |> kable()
```

\

c)  Estimate the variance if the sample size were tripled by tripling the number of primary stage cluster selections from 10 to 30.

-   We can compute a new design effect (DEFF = 1 + (n–1) ∗ 𝑟𝑜ℎ), We then multiply the new SRS variance (given portable estimates and total sample size 𝑛 ∗ 𝑚) by the new deff to get the new expected sampling variance.

```r

results_a |> 
  summarise(VAR_R / 3) |> 
  kable()

```

\

d)  Estimate the sampling variance if the sample size were tripled by tripling the subsampling rate in each cluster.

```r
new_m <- 3
dat |> 
  summarise(
    # compute new deff
    deff_new = 1 + ( ((new_m*sum(t_x) / n())) - 1) * results_b$roh,
    var_srs_new = (r *(1-r)) / ((new_m*sum(t_x))-1) * deff_new
  ) |> 
  kable()

```

\

e)  Compute the coefficient of variation of the denominator based on the current design \[from part (a)\]. Remember to account for the cluster sampling design in your calculation. Is the Taylor series approximation adequate?

-   We use $cv(\hat{t_x}) = \frac{se(\hat{t}_x)}{t_x}$ to compute the CV based on the current design.

```r
CV <- dat |> 
  summarise(
    CV = sqrt(
      (n() / (n() - 1)) * (sum(t_x^2) - sum(t_x)^2 / n()) 
    ) / sum(t_x)
  )

CV |> kable()

```

-   The coefficient of variation is less than .1 `r round(CV$CV, 3)`, the approximation is reasonably accurate.

\newpage

2.  The following are cluster totals from five strata, with two primary stage selections per stratum, for a binary variable named “total cholesterol greater than 200” $(t_{y,h,i})$:

```r

cholesterol <- tibble(
  h = rep(1:5, each=2),
  i = rep(1:2, 5),
  t_y = c(16, 15, 9, 5, 8, 10, 6, 10, 10, 7),
  t_x = c(23, 25, 17, 15, 20, 21, 16, 19, 12, 16)
)
  
cholesterol |> kable()
```

\

a)  Compute an estimate of the proportion with total cholesterol greater than 200, and its standard error (you can ignore the finite population corrections again in this case). Make sure that you are carefully accounting for this specific type of cluster sampling design in your variance estimation.

-   We calculate an estimate of the proportion with total cholesterol greater than 200 and standard error as:

$$
r = \frac{\sum_h \sum_\alpha y_{h \alpha}}{\sum_h \sum_\alpha x_{h \alpha}}
$$

$$
se(r) = \sqrt{ \frac{1}{x^2} [var(y) + r^2 var(x) - 2r cov(y,x) ] } 
$$

```r
 
results_a <- cholesterol |> 
  group_by(h) |> 
  mutate(t_y_diff =  (lag(t_y) - t_y), 
         t_x_diff =  (lag(t_x) - t_x)) |>
  ungroup() |> 
  mutate_all(replace_na, 0) |> 
  summarise(r = sum(t_y) / sum(t_x),
            var_r =  
              (1 / sum(t_x)^2) * (
              (sum(t_y_diff^2)) + 
              ((r^2) * sum(t_x_diff^2)) - 
              ((2*r) * sum(t_y_diff * t_x_diff))
              ),  
            se_r =  sqrt(var_r)
) 

results_a |> mutate_all(round, 4) |> kable()

```

-   The estimate of the proportion with total cholesterol greater than 200 is `r round(results_a$r, 2)` with an estimated standard error of `r round(results_a$se_r, 2)`.

\

b)  Give a 95% confidence interval for the proportion, making sure to use the correct degrees of freedom according to this design.

```r
qt_value <- .975
df <- 10-5 # a-h

results_a |> 
  summarise(
    lower = r - qt(qt_value, df) * se_r,
    upper = r + qt(qt_value, df) * se_r
  ) |> 
  mutate_all(round, 4) |> 
  kable()

```

c). Compute the design effect and roh for the proportion in (a).

```r
results_c <- cholesterol |> 
  summarise(
    r = sum(t_y) / sum(t_x),
    # compute sampling variance as p(1-p) / X
    var_srs =(r*(1-r))/(sum(t_x)-1),
    # Deff we use the cluster variance calculated above
    deff = results_a$var_r/var_srs,
    # roh/ICC calculate with average cluster size
    roh =(deff-1)/(mean(t_x)-1))

results_c |> mutate_all(round, 4) |> select(deff, roh) |>  kable()
```

d)  Estimate the standard error expected if the sample size were doubled by doubling the number of primary selections from two to four in each stratum.

```r
new_n <- 2 * 2 # double PSUs
  
cholesterol |> 
  summarise(
     r = sum(t_y) / sum(t_x),
    # compute new deff
    var = ((r * (1-r)) / ((sum(t_x)*2) - 1)) * results_c$deff,
    se_new = sqrt(var)) |>
  kable()

```

e)  Compute the coefficient of variation of the denominator. Remember to account for the stratified cluster sampling design in your calculation. Is the Taylor series approximation adequate?

-   The coefficient of variation is less than .1, the approximation is reasonably accurate.

```r
cholesterol |>
 group_by(h) |>
  # compute standard error for each stratum
  reframe(
    var = (n() / (n() - 1)) * (sum(t_x^2) - sum(t_x)^2 / n()),
    t_x = sum(t_x)
  ) |> 
  summarise(CV = sqrt(sum(var)) / sum(t_x)) |> 
  kable()
```
