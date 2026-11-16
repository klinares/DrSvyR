---
id: "jpsm/applied_sampling_SURV625/midterm/midterm"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "assignment"
title: "Midterm Examination Corrections"
original: "applied_sampling_SURV625/midterm/midterm.qmd"
pages: 
sha256: "49fe44f19b2233e9b3e76fe3c2aa0cb37ed7ed89ad58e3f7e840c4756786cce5"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:47"
---


```r
Total <- 3790000 # total live births 
p <- 0.3 # proportion of births from fragile families
n <- 8000 # SRS size
moe <- 0.01 # desired error
```

*Note. The midterm.qmd file contains the r-code needed for the specific calculations that were programmed for every question on this midterm. Please reference the r-code for calculation specifics. Each question is labeled in the r-code the same way as it is in the midterm.*

### Researchers have been funded to select a random sample of US newborns in 2025 to study child well-being conditions and policy issues. One key study outcome of interest is the number of children born in fragile families with unmarried parents. The sampler regards `r scales::comma(Total)` live births in the US. In 2022 as the population, obtains birth records from a government agency as the sampling frame, and seeks to evaluate different sampling strategies for making population-based inferences.

**+ 4 points**

**1. Administrative records from ten years ago suggest that the proportion of births in fragile families is `r p`. The sampler believes this estimate and wants to start from a simple random sample size of `r scales::comma(n)`. Would this simple random sample yield a desired margin of error below `r moe`?**

```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)
library(knitr)
library(tidyverse)

options(scipen=999)

```

-   We need to calculate the sampling variance first to estimate whether the desired sample size achieves the desired MOE. We use the equation below with a z-value of 1.96 assuming a 95% CI. We note that to achieve the desired MOE, we would need a sample 8,067. The sample of `r scales::comma(n)` is not sufficient to achieve the desired MOE.

$$
\text{SRSWR } n_o = \frac{z^2_{a/2} \times \hat{s}^2}{e^2}, \\ 
\text{SRS } n = \frac{n_0}{1 +\frac{n_0}{N}}
$$

```r
project_SRS_sample_fun <- function(z, p, e){
# we take the proportion, divide by half to get e
# compute SRSWR
  n_0 = (z^2 * (p*(1-p)) ) / e^2
  n = n_0 / ( 1 + (n_0/Total))
# compute SRS
cat(str_c("The SRSWR sample size is "), round(n_0), 
    "\n and SRS is ",  round(n))
}

project_SRS_sample_fun(z = 1.96, # use 1.96 for 95% CI
  p = p, # estimated proportion
  e = moe)

```

\newpage

**2. The sampler now wants to consider a systematic sample of n = `r scales::comma(n)` births from the frame of `r scales::comma(Total)` birth records.**

**+ 2 points**

a). What is the sampling interval?
 
-   We use the equation $k = 1/f = N/n = 3,790,000 / 8,000 = 473.75$  for the sampling interval.

```r
k <- Total/n 
```

**-2 points**

b). Using the fractional interval method, what random starts will select the 500th record on the frame?

-   We take the record value and add decimal points to mimic the decimal places in the sampling interval 500.999, and we determine that a random start of from 25.125 to 26.124 will hit record number 500.

```r
record <- 500.999
lower_start_value <- as.integer(record) - k 
upper_start_value <- record - k 
```

```r
cat(str_c("The random starts are from ", lower_start_value, 
          " to ", upper_start_value))
```


**+ 4 points**

c). Recommend a procedure for computing the standard error of the mean under the fractional interval method. Justify your choice of procedure . What are the degrees of freedom of the recommended variance estimator?

-   The standard error of the mean can be achieved by estimating the sampling variance as:

$$
var_{srs}(p) = \frac{1-f}{n-1} p(1-p) 
$$

-   By squaring the SRS variance we can estiamte the standard error $se(p) = \sqrt{var_{srs}(p)}$ where $p = y/n$ and $f=n/N$ The degrees of freedom in this design is $df = n-1$.

\

**+ 4 points**

d). Identify one major potential problem with this frame for the a sample of birth records. Provide a remedy for the problem.

-   One potential problem is that not every birth record has an equal chance of being selected. It is still possible that some records have been lost or incorrectly recorded leading to inaccurracies in the master file list. We can use noncoverage weighting to correct for this issue. Another issue is duplicated records which we can determine how many duplicates are in the list and account for it during the design of weights.

\newpage

```r
nm <- 400 # new sample size
N <- 189500 # number of hospitals
M <- 20 # number of births at hospitals
n <- 20
m <- 20

NM <- N*M
```

**3. The sampler finds that the previous proportion estimate is not accurate and decides to implement a pilot study with an overall sample size of `r nm` under a two-stage cluster sampling design. Assume that the `r scales::comma(Total)` birth records for the newborns arise from a frame of N = `r scales::comma(N)` hospitals of M = `r M` births each. The sampler selects a simple random sample of n = `r n` different hospitals. The total number of children born in fragile families in the each cluster of `r m` births is shown below.**

```r

dat <- tibble(
  Block = seq(1, 20, 1), 
  # assign clustering by hand
  t = 
    c(10, 15, 5, 5, 16, 8, 8, 15, 9, 9, 9, 10, 4, 3, 11, 12, 8, 4, 8, 6)
  ) |> 
  mutate(p = t/m)

dat |> kable()
```

\newpage

**+ 12 points**

a). Compute the estimated proportion of births from fragile families, p, and its standard error, along with a 95% confidence interval for the proportion.

-   We start by computing the sampling fraction as $f = nm/NM = 400 / 3,790,000 $ which is small and can be ignored

```r
f <- (n*m) / (N*M) 
```

```r
cat(str_c("The sampling fraction is ", round(f, 5)))
```

-   The sample mean can be computed as:

$$
\bar{y} =   \sum_{j \in S_i} \frac{y_{ij}}{m_i}
$$

```r
y_bar <- dat |> reframe(sum(t) / nm) |> pull() 
```

```r
cat(str_c("The sample mean of births is ", y_bar))
```

-   The standard error is given as:

$$
se(\bar{y}) = \sqrt{(1-\frac{nm}{NM})\frac{s^2_B}{n}}
$$

```r
var_y <- (
  (1 - ((n*m)/(NM))) * (1/n) * (1 / (m^2 * (n-1) ))) *
  ( dat |> reframe(sum(t^2) - (sum(t)^2 / n)) |> pull() ) 

se <- sqrt(var_y) 
```

```r
cat(str_c("The standard error for the population mean is ", round(se, 4)))
```

-   We use the standard error to estimate 95% confidence intervals.

```r
qt_value <- .975
lower <- y_bar - qt(qt_value, n-1) * se
upper <- y_bar + qt(qt_value, n-1) * se
```

```r
cat(str_c("The 95% CI is [", round(lower, 4), ", ", round(upper, 4), "]"))
```

\

**-2 points**

b). Compute the estimated **total** number of births in fragile families and its standard error.

-   We can use $\bar{y}$ estimated in 3.a). and multiply it by the total population of births. To calculate the standard error we first calculate the sampling variance $\hat{s}^2_t$ as:

$$
\hat{s}^2_t = \frac{1}{n-1} \sum_{i \in S} (\hat{t}_i - \hat{t})^2
$$ - We can now use the sampling variance to calculate the standard error of the total estimate for births as:

$$
se(\hat{t}) = \frac{1}{M} \sqrt{(1 - \frac{n}{N}) \frac{s^2_t}{n}}
$$

```r
t_hat <- y_bar * Total # t_hat = N/n * sum(t_i)
# comput sampling variance of total
s_2_t <- (1 / (n-1)) * (dat |> summarise(sum((t - t_hat)^2)) |> pull())
se_t <- (1/(M)) * sqrt( ( 1- (n/N)) * (s_2_t/n) )
```

```r
cat(str_c("The estimated total number of births in fragile families is ",
         scales::comma(t_hat), " \nwith a standard error of ", scales::comma(se_t)))
```

**+ 10 points**

c). Based on the design in 3a), compute the design effect for the estimated proportion of births in fragile families, deff, as well as roh.

-   Based on $\hat{y}$ and the variance of the complex design estimated in 3.a). we use these values in addition to estimating the SRS variance as:

$$
var_{srs} = \frac{p(1-p)}{n-1}
$$

```r
var_srs <- (1 - f) * ((y_bar*(1-y_bar) / (n*m - 1)))
```

```r
cat(str_c("The SRS variance is ", round(var_srs, 4)))
```

-   We can now compute the design effect as:

$$
DEFF = \frac{var_{cluster}}{var_{srs}}
$$

```r
deff <- var_y / var_srs # var_y computed in 3.a)
```

```r
cat(str_c("The design effect is ", round(deff, 4)))
```

-   Finally, roh is computed as:

$$
roh = \frac{DEFF - 1}{var_{srs}}
$$

```r
roh <- (deff - 1) / (m - 1) 
```

```r
cat(str_c("Roh is ", round(roh, 4)))
```

\newpage

d). Consider the following three two-stage cluster sample designs for selecting births.

-   i n=189,500 clusters, selecting all M = 20 births in each.
-   ii n=379,000 clusters, subsampling m = 10 births from each.
-   iii n=758,000 clusters, subsampling m = 5 births from each.

\

**-2 points**

1.  Which design will have the smallest sampling variance? Explain.

-   Sampling variance is a function of the number of sampled clusters. Generally more clusters reduce the sampling variance. In the first design i, all the births are selected from the hospitals so there is no estimated within variance. Between variance is expected to be the largest compared to the other two designs. For design ii by increasing the number of clusters the between variance decreases; however, cluster size relates to within cluster variance and the smaller the number of elements the larger the within variance which impact the sampling variance estimate. In this case, design iii has a substantially larger number of clusters than ii and will have a smaller between cluster variance which will impact the sampling variance and we choose this design.

\

**-2 points**

2.  Which design will have the largest sampling variance/ Explain.

-   We believe that design i will have the largest sampling variance based on having a larger between cluster variance compared to designs ii and iii. This is especially true when a design has smaller clusters and they are heterogeneous resulting in more between cluster variability.

\

**-2 points**

3.  Which design should have the highest cost of data collection? Explain.

-   Although all three designs has a total sample size of 3,790,000, generally the more clusters a design has the higher the cost. This is because it costs more to get interviewers or survey materials to more places. Design iii would be more likely to have the highest cost for data collection.

\newpage

**-1 point**

-e). The sampler knows from prior studies that the costs associated with each hospital, $c_n$, are \$450, while the costs associated with each birth in the sample, $c_m$, are \$10. What is the optimum subsample size for the two-stage sample design?

-   We can compute the optimum subsample size $m_{opt}$ by using roh estimated in 3.c. as:

$$
m_{opt} = \sqrt{\frac{c_n}{c_m} \frac{1 - roh}{roh}}
$$

```r
c_n <- 450
c_m <- 10

m_opt <- sqrt((c_n/c_m) * ((1-roh)/roh))
```

```r
cat(str_c("The optimum subsample size is ", round(m_opt, 0)))
```

\

**-5 point**

f). With the two-stage cluster sample design and the $m_{opt}$ calculated in part 3.e), how many births does the sampler need to select in order to meet the precision objectives in question 1 above?

-   Recall that in Q1 we needed 8,050 births to meet the precision requirement. We use this as $n_{srs}$ to estimated how many births are needed and the design effect which is portable.

```r
project_SRS_sample_fun(z = 1.96, # use 1.96 for 95% CI
  p = p, # estimated proportion
  e = moe)
```

```r
n_srs <- 8050
n_births <- n_srs * (1 + (21-1) * roh)
```

```r
cat(str_c("The sampler needs ", scales::comma(round(n_births, 0)), " total number of births."))
```

\

**-5 point**

g). The total budget will allow the sampler to select a sample of 8,000 births with the $m_opt$ calculated in part 3.e). What is the expected sampling variance for this new design with the optimum subsample size from part 3.e)?

-   We calculate a new design effect as:

$$
deff_{new} = 1 + (m_{opt} -1) \times \hat{roh}
$$

```r
n_sample <- 8000 # total births sampled

# calculate the number of clusters with m_opt and the sample size
## round up
n <- round(n_sample / m_opt)
new_deff <- 1 +(m_opt-1) * roh
```

```r
cat(str_c("The new design effect is  ", round(new_deff, 4)))
```

-   We also calculate the new SRS variance as:

$$
var_{srs-new} = (1-f_{new}) \frac{p(1-p)}{nm_{new}-1}
$$

```r
# NM is the total birth pop 1.3 mil
# y_bar calculated earlier as .44 

f_new <- (n*m_opt) / NM
new_var_srs <- ( (1 - f_new) * ( (y_bar * (1 - y_bar))/(n * m_opt - 1) ) )
```

```r
cat(str_c("The new SRS variance is  ", round(new_var_srs, 5)))
```

-   We can now use the new SRS sample variance and new DEFF to estimate the new cluster design sampling variance as:

```r
new_var_y <- new_var_srs * new_deff
```

```r
cat(str_c("The sampling variance for the cluster design is ", 
          round(new_var_y, 7)))
```

\newpage

**-8 point**

**4. The frame of birth records is divided into four mutually exclusive strata based on welfare, policy, and economic factors. Based on findings from another study with the same stratification structure, the sampler obtained the proportion of births in fragile families for each stratum.**

```r
dat <- tibble(
  strata = seq(1, 4),
  N_h = c(2000000, 500000, 1000000, 290000),
  p_h = c(.6, .3, .5, .4))

dat |> kable()
```

-   Ignoring the clustered nature of the frame, provide the Neyman allocation of 8,000 sampled births, and estimate proportion of births in fragile families and the standard error under this allocation.

-   The Neyman's allocation method can be used when the costs in the strata are equal and also the aim is to minimize the variance of the estimated mean. This method over samples stratum that have higher variance $s^2_h$, reducing the variance $\bar{y}_h$. The Neyman allocation is given by multiplying the desired sample size by the strata size x it's standard deviation divided by the sum of the produces of strata size by standard deviation as:

-   The $s^2_h$ element variance is given as follows, which we use to estimate $s_h$.

$$
s^2_h = \frac{N}{N-1}p_h(1-p_h)
$$

-   We use $s_h$ to calculate $n_h$ as, which is the Neyman allocation.

$$
n_h = \frac{N_h, S_h}{\sum_l N_lS_l}
$$

-   Finally we calculate $W_h = N_h/N$

```r
N_pop <- dat |> tally(N_h) |> pull()

dat <- dat |> 
  mutate(
    # calculate the standard deviations 
   s_h =  sqrt(p_h * (1 - p_h)) ,
   Nh_Sh = N_h * s_h,
   n_h = n_sample * (Nh_Sh / sum(N_h*s_h)), # Neyman allocation,
   W_h = N_h / N_pop,
   n_h = round(n_h)) 
```

```r
cat("The following are the Neyman's allocation")
dat |> select(strata, n_h) |> kable()
```

-   The standard error is given as:

$$
se(\bar{y}) =  \sqrt{ \sum_{h=1}^H W_h^2 \frac{1-f_h}{n_h} s_h^2} 
$$

```r

se <- dat |> 
  mutate(f_h = n_h / N_h) |> 
  summarise(
    sqrt(
      sum(W_h^2 * (p_h * ((1-p_h)) / n_h))
    )
     # sum(W_h^2 * ((1-(n_h/N_h)) / n_h) * s_h^2 )
  ) |> 
  pull() 
```

```r
cat(str_c("The standard error under the Neyman allocation is ", round(se, 4)))
```

\newpage

**5. In reality, different hospitals have different number of births. The assumption of equal-sized cluster made above is not valid. The sampled decides to construct strata, select hospitals from each stratum, and then select births from hospitals.**

Indicate true or false

**-2 points**

-   a)  FALSE, We would always need weights if the 8,000 sampled births are selected under the stratified cluster sampling design.

    -   If the strata are allocated proportionally to their size, and within each stratum, the hospitals are of roughly equal size, simple random sampling is used within each strata, and the selection rate of the final stage units is the same across all strata, then we might not need weights.

**+ 2 points**

-  b)  TRUE, We only need hospital total of births for variance estimation under the stratified cluster sampling design.

**+ 2 points**

-  c)  TRUE, PPeS sampling of hospitals is an epsem procedure for hospitals with different total birth counts.

**+ 2 points**

-  d)  TRUE, Systematic PPeS sampling is not a measurable sampling technique.

**- 2 points**

-   e)  FALSE, When using proportionate allocation in a complex sample designs, hospitals as the primary sampling units (PSUs) should be allocated to different sampling strata based on the total counts of PSUs available in each of the strata.

    -   In proportionate allocation, the number of hospitals allocated to each stratum should be proportional to the total size of births of each stratum, not simply the count of PSUs.


\newpage

**-8 point**

**6. The sampler decides to select a two-stage sample of hospitals and births within the selected hospitals from one stratum. Below is a list of hospitals in this stratum, including 2022 birth counts in hospitals. The sample design calls for a minimum sufficient size of hospitals births of 50.**

```r
dat <- tibble(
  Hospital = seq(1, 19),
  births = 
    c(4, 14, 32, 19, 28, 20, 16, 0, 17, 56, 62, 136, 3, 2, 9, 1, 0, 4, 58)
) |> 
  mutate(c_sum = cumsum(births),
         c_sum_min = 1 + lag(c_sum, default = 0))

dat |> kable()
```

a). Select a systematic PPeS sample of two hospitals from the available list below based on a random start of 0412. Clearly identify how you will handle selections of undersized units.

-   First we calculate the sampling interval k as N/n where N is the total population elements and n is the number of clusters to be selected.

```r
RN <- 0412 # starting value
min_MOS <- 50 # min birth requirement
n <- 2 # how many hospitals to select
N <- dat |> tally(births) |> pull()  # total births
k <- N/n    # sampling interval
```

```r
cat(str_c("The sampling interval is ", k))
```

-   Since our random start is larger than k, we need to move the decimal points by multiplying k by 10. We now can get a vector of selection values.

```r
k <- k * 10 
RN_sample <- round(seq(RN, N*10, k)/10) 
```

```r

cat(str_c("We move decimals in k ", k, " and get selection numbers "))
RN_sample
```

-   We now select `r n` hospitals from the list and show the selected hospitals below. We also print the selection numbers based on the random start and k.

```r
dat_selected <- dat |>
  # add population elements
  add_column(RN_sample |> tibble() |> data.table::transpose()) |>
  # create flag for blocks that are selected
  mutate(selected =
           as.numeric(if_any(starts_with("V"), ~
                               between(.x, c_sum_min,
                                       c_sum)))) |>
  # drop select population elements
  select(-starts_with("V")) 

dat_selected |>
  filter(selected == 1) |>
  mutate(selection = RN_sample) |>
  select(Hospital, births, selection) |> 
  kable()

```

-   We can see that Hospital 3 does not meet the requirement of minimum births, and we will need to perform linnkage post selection. The linking is done by first selecting the two hospitals from the list. If the next hospitals do not meet the minimum requirement of births of 50 we move down in the list until the first unit that meets the minimum requirement is achieved. For all the units that did not meet the requirement they are cummulated backwards until a linked unit of minimum sufficient size is created. We do this process for all the hospitals initially selected.

```r
dat_clustered <- dat |> 
  filter(Hospital %in% c(3:9, 12:18)) |> 
  # next part is done by hand, terrible practice
  mutate(clusters = c(1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3)) 
```

```r
dat_clustered |> 
  kable()
```

-   We selected Hospital 3 and linked it with 4 and 5 to meet the linking method described above. Our second selection was Hospital 12, which we link with 13-18 given their small birth numbers.

\

**-2 point**

b.  Write the first-stage sampling fraction (or, the probability of selection) for the first (possibly linked) unit included in the systematic PPeS sample.

-   The first stage selection rate is given as, where n is the number of selected hospitals, $n_h$ is the total number of births in the cluster, and N is the total number of birhts. $$
    f_n = n* \frac{n_j}{N}
    $$

```r
p_h <- n * dat_clustered |> 
  # select first cluster
  filter(clusters == 1) |> 
  summarise(births = sum(births)) |> 
  pull() / N
```

```r
cat(str_c(
  "The first stage probability of selection for the first cluster is ", 
  round(p_h, 3)))
```

**-6 point**

\

c.  The overall target sampling fraction for the entire sample is f = 1/100. Compute the sampling rates necessary for the two (possibly linked) units in the sample to maintain epsem.

```r
f <- 1/100 # overall selection probability 
n <- 2 # how many hospitals to select
N <- dat |> tally(births) |> pull()  # total births

# _____________ handy functions _________________

# groups blocks into a long string
p <- function(v) {
  Reduce(f=paste, x = v)
 }

# _____________________________________________

# compute sampling rates
dat_clustered |> 
  # select clusters we selected
  filter(clusters %in% c(1, 3)) |> 
  mutate(Hospital = as.character(Hospital)) |> 
  group_by(clusters) |> 
  reframe(Hospital = p(Hospital),
          Birth_total = sum(births)) |> 
  mutate(f_h = f * (N / (n * Birth_total)),
         f_h = round(f_h, 4)) |> 
  kable()
  
```
