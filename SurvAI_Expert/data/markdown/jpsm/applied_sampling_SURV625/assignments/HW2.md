---
id: "jpsm/applied_sampling_SURV625/assignments/HW2"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "assignment"
title: "Homework 2"
original: "applied_sampling_SURV625/assignments/HW2.qmd"
pages: 
sha256: "0a8ed1998bd3acbed55fe060e9c980960451f0e1086f6c8fabd93a17fdd31d15"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T14:15:59"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

library(tidyverse)

options(scipen=999)
```

## A stratified random sample of graduates from the academic departments at a small university is to be selected to estimate the mean starting salary of graduates from that university. The university has five academic departments, and preliminary data are obtained from an attempted census in a recent year:

```r
# build the table
dat <- read_csv(
  "~/repos/UMD_classes_code/applied_sampling_SURV625/homework/hw2_q1_table.csv")

dat
```

a). What is the mean starting salary per graduate across all departments in the population, based on the data collected from this previous attempted census?

-   The overall population mean is given by:

$$
\bar{Y} = \sum_h
\frac{N_h}{N}\bar{Y}_h = \sum_hW_h\bar{Y}h
$$

-   where the population mean is a weighted sum of the population means for each stratum, where $W_h$ is the relative proportion of the population within each stratum.

```r
# compute relative proportion W_h
dat <- dat |> mutate(W_h = N_h / sum(N_h)) 

Y_bar <- dat |> summarise(Y_bar = sum(W_h*Y_bar_h)) |> pull(); Y_bar
```

-   The population mean for starting salary per graduate across all departments is `r scales::dollar(Y_bar)`.

\

b). What is the average within-stratum element variance $S^2_w = \sum^5_{h=1}W_hS^2_h$?

-   The element variance estimate $s^2$ is given as:

$$
s^2_h = \frac{1}{n_h-1}\sum^{n_h}_{i=1}(y_{ho}-\bar{y}_h)^2
$$

-   Which we can than use to calculate the within stratum element variance as:

$$
s^2_w = \sum^5_{h=1}W_hS^2_h
$$

```r
# compute S^2_w
s_sqr_w <- dat |>
  # calculate element variance for each stratum
  mutate(s_2_h = (1 / (N_h - 1))  * ((Y_bar_h - mean(Y_bar_h))^2 )) |> 
  # calculate mean within statum variance
  summarise(mean(W_h*s_2_h)) |> pull()

```

-   The average within stratum element variance is given by multiplying the relative proportion and the squared standard deviation for each stratum and we estimate it to be `r scales::comma(s_sqr_w)`.

\newpage

c). For a sample of n = 100, what is the proportionate allocation?

-   Answer combined with question d).

d). For a sample of n = 100, what is the Neyman allocation?

-   We provide the allocation estimates for a proposed sample of n=100 for the proportionate allocation and Neyman's allocation method in the table below to compare.

    -   We compute the proportionate allocation below as the number of sampled units in each stratum is proportional to the size of the stratum, the inclusion probability for unit $j$ in stratum $h$ is given as $\pi_{hj} = n+h / N_h$, and label it n_h_prop. This method is a good choice when we want our sample to mimic the population.

    -   The Neymnan's allocation can be used when the costs in the strata are equal and also the aim is to minimize the variance of the estimated mean. This method oversamples stratums that have higher variance $S^2_h$, reducing the variance $\bar{y}_h$. They Neyman allocation is given by multiplying the desired sample size by the strata size \* it's standard deviation divided by the sum of the products of strata size by standard deviation as $n_h = \frac{N_hs_h}{\sum_l N_l s_l}$, and we label it below as n_h_ney.

```r
n <- 100 # sample size

dat <- dat |> 
  mutate(
    # proportionate allocation
    n_h_prop = round ( (N_h/sum(N_h)) * n),
    # Neyman allocation
    n_h_ney = round( n * (N_h* S_h) / sum(N_h*S_h))
    ) 

dat |> 
  select(Department, N_h, n_h_prop, n_h_ney) 
```

e). Estimate the sampling variance of the mean for the proportionate c) and Neyman d) allocations.

-   We use the stratum element variance formula in b). and than calculate the sampling variance as:

$$
var(\bar{y}_h) = (1-f_h)\frac{s^2_h}{n_h}
$$ - We have to combine the stratum sampling variances as:

$$
var(\bar{y}_w) = \sum_h W^2_h(1-f_h)\frac{s^2_h}{n_h}
$$

-   Sampling variance of the mean for the proportionate allocation is:

```r
var_prop <- dat |> mutate(s_2_h = (1 / (n_h_prop - 1))  * 
                            ((Y_bar_h - mean(Y_bar_h))^2 ),
              v_h = (1 - (n_h_prop/N_h)) * (s_2_h/n_h_prop),
              W_h_prop = n_h_prop / sum(n_h_prop)) |> 
  summarise(sum(W_h_prop^2* v_h)) |> pull()

var_prop
```

-   Sampling variance of the mean for the Neyman allocation is:

```r
var_ney <- dat |> mutate(s_2_h = (1 / (n_h_ney - 1))  * 
                           ((Y_bar_h - mean(Y_bar_h))^2 ),
              v_h = (1 - (n_h_ney/N_h)) * (s_2_h/n_h_ney),
              W_h_ney = n_h_ney / sum(n_h_ney)) |> 
  summarise(sum(W_h_ney^2* v_h)) |> pull()

var_ney
```

\newpage

f). Estimate the total element variance $S^2$ using:

$$
S^2 = \sum^H_{h=1} \frac{N_h-1}{N-1} S^2_h + \sum^H_{h-1}  \frac{N_h-1}{N-1} (\bar{Y}_h-\bar{Y})^2 
= \sum^H_{h=1}W_hS^2_h + \sum^H_{h=1}W_h(\bar{Y}_h-\bar{Y})^2 
$$

-   The overall $S^2$ is fixed and is a summation of the within stratum variance plus the between stratum variance.

```r
S_2 <- dat |> 
  # calculate S^2_h, within stratum variance
  mutate(s_2_h = (1 / (N_h - 1))  * ((Y_bar_h - mean(Y_bar_h))^2 )) |> 
  # summarize within variances + between variances
  summarise(sum( W_h * s_2_h) + sum(W_h * (Y_bar_h - mean(Y_bar_h))^2 )) |> 
  pull()

S_2
```

\

g). What are the design effects of the proportionate and Neyman allocations?

-   We first calculate the SRS variance below to use for our deff calculations.

```r
V_srs <- dat |> 
  summarise(f = sum(n_h_prop) / sum(N_h),
            S_2 = (1 / (sum(n_h_prop) - 1)) * 
              (sum((Y_bar_h - mean(Y_bar_h))^2 )),
            V = (1-f) * (S_2 / n())) |> pull(V)

V_srs
```

-   The design effect, $deff$ can be calculated by $var(\bar{y}_2w) / var_{srs}(\bar{y})$ which we previously calculated in e) and f). We expect a $deff < 1$ which it is below.

```r
var_prop / V_srs
```

-   For Neyman allocation we use the same $deff$ fomula an calculate a value of:

```r
var_ney / V_srs
```

-   Overall, these design effects are small, less than 1, indicating that both stratified sampling methods are more efficient than simple random sampling for this data set.

\

h). Suppose that the cost-per-element was not the same in each stratum C_1 = C_2 = C_3 = \$30, and C_4 = C_5\$40.

-   

    1.  The client requesting a stratified sample design has indicated that the total available data collection budget is 𝐶 = \$5,000, with the stratum-specific costs per element listed above. What allocation will minimize the sampling variance of the mean under these cost constraints?

    -   We can calculate the proposed stratified sample $n_h$ under the cost optimal allocation design as;

$$
n_h = kW_hS_h \sqrt{C_h} \text{ with } k=\frac{\sum_h n_h C_h}{\sum_h W_h S_h \sqrt{C_h}}
$$

-   We apply the stratum cost in a new vector called $c_h$ along with the \$5,000 constrain and estimate $n_h$ below in a new column. We also estimate the new cost to be slightly over $\$5,000$ due to some rounding error.

```r
dat <- dat |> 
  mutate(
    # add cost as a new vector
    c_h = c(30, 30, 30, 40, 40),
    # calculate k with total constraint of $5,000
    k = 5000 / sum(W_h * S_h * sqrt(c_h)),
    # budget constraint to find n
    n_h = round(k * W_h * S_h / sqrt(c_h)),
    new_cost = n_h * c_h
    ) 
  
  
dat |>  select(N_h, W_h, n_h, new_cost)
```

\

2.  Estimate the expected sampling variance and design effect of the mean starting salary under this allocation. (Hint: Think carefully about the definition of a design effect)

-   We are still working with the cost optimal allocation design, and we can use the same formula for e) for calculating the expected sampling variance with our proposed stratified sample.

```r
V <- dat  |> 
  mutate(s_2_h = (1 / (n_h - 1))  * ((Y_bar_h - mean(Y_bar_h))^2 ),
              v_h = (1 - (n_h/N_h)) * (s_2_h/n_h),
              W_h = n_h / sum(n_h)) |> 
  summarise(sum(W_h^2* v_h)) |> pull()

V
```

-   We calculate the design effect like we did in g) and show below that the design effect of the stratified proposed sample is still more efficient than a SRS approach for these data.

```r
V / V_srs
```
