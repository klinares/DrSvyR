---
id: "jpsm/applied_sampling_SURV625/midterm/practice"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "assignment"
title: "Midterm Practice"
original: "applied_sampling_SURV625/midterm/practice.qmd"
pages: 
sha256: "52f0bae0502337a8dc828cf6957a886dd2ec6d6dc3808a655bcef3cce0e1df4b"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:45"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

library(knitr)
library(tidyverse)

options(scipen=999)

# _______________ handy functions _____________________

# the function returns a selection flag for block
selected_block_fun <- function(vec, A, B) {
  vec[A <= vec & vec <= B]
}
```

## 1. A Probability Proportionate to estimated Size (PPeS) selection of clusters from the following list of blocks is needed. The measure of size (MOS) is the number of housing units in the block at the last Census. The “Cumulative” column is the cumulated sum of measures of size.

```r

dat <- tibble(
  Block = seq(1, 10, 1), 
  # assign clustering by hand
  cluster = c(1, 2, 2, 3, 4, 5, 6, 7, 8, 9),
  MOS = c(50, 20, 25, 70, 100, 80, 55, 50, 40, 60),
) |> 
  mutate(Cumulative = cumsum(MOS))

dat |> kable()

```

a\. Ensure that each cluster has a minimum Measure of Size (MOS) of at least 35. Fill in the “Cluster Number” column to show how you have formed linked clusters.

-   We linked blocks 2:3 and have a total of 9 clusters.

\

b\. What is the selection interval (k)? What range of numbers is valid for a random start in this case? Select 3 clusters using a random start of 12. Which three clusters did you select?

-   K is calculated as N/n where N is the total population elements and n is the number of clusters to be selected.

```r
# We need to know how many clusters to select and the random start
## the code after this chunk is automated if we pass it the data table above.
n <- 3 # number of clusters to select
RN <- 12 # random start
```

-   If we calculate k, the sampling interval, and use a random start of 12, we select the following clusters of MOS size:

```r
# calculate selection interval
k <- dat |> summarise(sum(MOS) / n) |> pull(); k

N <- dat |> summarise(sum(MOS)) |> pull() # total sample size

RN_sample <- seq(RN, N, k) ; RN_sample # will help us pick blocks
```

-   Values between 1 to `r k` are valid random start values.

```r
dat_linked <- dat |> 
  group_by(cluster) |> 
  reframe(MOS = sum(MOS)) |> 
    mutate(Cumulative = cumsum(MOS),
           # create cumulative min value to create range 
           Cumulative_min = 1 + lag(Cumulative, default = 0)) |> 
  rowwise() |> 
  # create column with RN values
  mutate(RN_value = list(
    selected_block_fun(RN_sample, Cumulative_min, Cumulative))) |> 
  ungroup() |> 
  mutate(
    RN_value = as.numeric(RN_value),
    # create selected flag
    Selected = ifelse(is.na(RN_value), 0, 1)) |> 
  select(cluster, MOS, Cumulative, RN_value, Selected)

dat_linked |> filter(Selected == 1) |> select(cluster, MOS) |>  kable()  
```

\

c.  Calculate the probability of selection for each of the three selected clusters.

-   We calculate the first stage probability of selection using $n \times MOS_i/ \sum MOS_i$ which we take the sum of MOS in each linkage times n, the number of clusters to be selected, divided by the total MOS.

```r

dat_linked |> 
  filter(Selected == 1) |> 
  summarise(cluster=cluster,
            prob_select = (n * MOS) / N) |> 
  
  kable()
```

\

d.  The desired overall sampling rate (f) is 48/550. Calculate the required subsampling rate for each of the selected clusters that will produce an epsem sample of housing units.

-   The overall selection probability is equal to the first stage probability times the second stage probability $f = f_1 \times f_2 = n\times MOS_i/ \sum MOS_i \times M / MOS_i$, we cancel terms and keep $n/\sum MOS_i \times M$ and we get M by:

$$
m = f \times \frac{\sum{MOS_i}}{n}= .09 * \frac{550}{3} = 16
$$

-   We calculate the second stage selection probability for each cluster.

```r
# Provide the desired overall sampling rate
f <- 48/550; f

# ____________ automated code ________________
m <- (f * (N/n)) ; m


f_2 <- dat_linked |> 
  filter(Selected == 1) |> 
  summarise(cluster=cluster,
            f_2 = m / MOS,
            n_size = f_2 * MOS)

f_2 |> kable()

```

\newpage

## 2. Consider the following frame of blocks

a\. Select 2 blocks with probabilities proportionate to size, using a minimum size of 50. Use systematic selections with a random start of 75.0. If linking is necessary, identify the linked units in the appropriate column.

```r
# build the table, input MOS, cumulative will be automated
dat <- tibble(
  Block = seq(1, 10, 1), 
  MOS = c(50, 10, 63, 0, 22, 52, 0, 28, 100, 75),
) |> 
  mutate(Cumulative = cumsum(MOS))

dat |> kable()
```

-   We need to identify the proper links, first let's find the sampling interval which we know we have to select 2 blocks to sample from, so the sampling interval is $k=N/n$.
    -   Variables needed besides data.

```r
n <- 2 # number of blocks to select
RN <- 75 # random start
min_MOS <- 50 # minimim MOS in cell needed
```

```r
# ____________________ automated code below ____________________________
N <- dat |> summarise(sum(MOS)) |> pull(); N
k <- N / n ; k
RN_sample <- seq(RN, N, k) # will help us pick blocks

```

-   We are given a random start of 75. Now we can select blocks and check our minimum size requirement.

    -   However, we must verify if the block after meets the minimum requirement and if not, we must combine.

    -   Linking blocks to form selected clusters **after selection**. Linking after selection is cheaper.

```r


# ____________________________________________________

dat_linked <- dat |> 
  mutate(
    # create cumulative min value to create range 
    Cumulative_min = 1 + lag(Cumulative, default = 0)) |> 
  rowwise() |> 
      # create column with RN values
  mutate(RN_value = list(
    selected_block_fun(RN_sample, Cumulative_min, Cumulative))) |> 
  ungroup() |> 
  mutate(
    RN_value = as.numeric(RN_value),
    # create selected flag
    Selected = ifelse(is.na(RN_value), 0, 1),
    # flag if minimum MOS not met
    min_n_req = ifelse(MOS >= min_MOS, 1 , 0),
    # create links and convert to clusters
    linking = lead(min_n_req, default=1),
    cluster = cumsum(lag(linking, default=1))) |> 
  # now we can sum MOS by cluster for our selection
  group_by(cluster) |> 
  reframe(MOS = sum(MOS), RN_value=RN_value) |> 
  filter(!is.na(RN_value)) |>    # selected clusters
  select(-RN_value)


dat_linked |> kable()
```

-   We declare blocks 3, 4, 5, as our first block selected with linkage and block 9.

\

b\. Give the probability of selection for the primary selections (i.e., the clusters formed from the blocks) made in problem (i).

-   We compute the first stage probability of selection using $n \times MOS_i/ \sum MOS_i$ which we take the sum of MOS in each linkage times n, the number of clusters to be selected, divided by the total MOS.

```r
dat_linked |> 
  summarise(cluster=cluster,
            prob_select = (n * MOS) / N) |> 
  kable()
```

\

c\. The overall probability of selection is f = 0.05. Give the within-cluster selection rate for each cluster selected in Part 2a that will result in an epsem sample of housing units.

-   The overall selection probability is equal to the first stage probability times the second stage probability $f = f_1 \times f_2 = n\times MOS_i/ \sum MOS_i \times M / MOS_i$, we cancel terms and keep $n/\sum MOS_i \times M$ and we get M by:

$$
m = f \times \frac{\sum{MOS_i}}{n}= .05 * \frac{400}{2} = 10
$$

-   We still need to get the second stage selection probability $f_2 = m/MOS_i$ for each cluster and we print below for both selected cluster.

```r
f <- .05 # overall selection probability
m <- (f * (N/n)) ; m

f_2 <- dat_linked |> 
  summarise(cluster=cluster,
            f_2 = m / MOS,
            n_size = f_2 * MOS)

f_2 |> kable()
```

\

d\. After selecting clusters, field staff are sent to selected blocks to count the number of housing units that are actually there. Suppose the (potentially linked) cluster 2 is selected and the real \# of housing units is 95, calculate the expected number of housing units to be selected in cluster 2 given the actual counts.

-   We now use PPS (probability proportion size), and using the $f_2$ calculated above, we now need to estimate the number elements that will be selected if the housing units are of size 95.

    ```r
    housing_units = 95

    expected_hu <- f_2 |> 
      # select cluster
      slice(1) |> 
      summarise(
        f_2 * housing_units
      ) |> 
      pull()

    expected_hu

    ```

-   The expected number of housing units to be selected is between 11 and 12, which we can calculated the expected probabilities.

    ```r
    # lower estimate
    lower <- 11
    # upper estimate
    upper <- 12

    lower_expected <- (lower * expected_hu) + (upper * (1-expected_hu))
    upper_expected <- 1 - lower_expected
      
    tibble(expected_values = c(lower, upper),
           expected_prob = c(lower_expected, upper_expected)) |> 
      mutate(expected_prob = round(expected_prob, 2)) |> 
             kable()
    ```

    -   We pick the highest expected probability from the two choices we have.

\newpage

## 3. Tables in Question 1 and Question 2 are the sample frame from two strata.

-   For Stratum 1: three clusters were selected, i.e., $n_1 = 3$.

-   For Stratum 2: two clusters were selected, i.e., $n_2 = 2$.

a.  What are stratum-specific zone size?

-   Zone size is defined as.

$$
\frac{\sum _{i \in h} MOS_hi} {n_h}
$$

```r
N_h1 <- 550
n_h1 <- 3
N_h2 <- 400
n_h2 <- 2

h1_size <- N_h1 / n_h1 ; h1_size
h2_size <- N_h2 / n_h2 ; h2_size

```

-   The zone size for stratum 1 is `r round(h1_size, 1)` and for stratum 2 `r h2_size`.

\

b.  To retain epsem with the desired overall sampling rate (f = 0.1), what is the targeted subsample size for each cluster in Stratum 1?
c.  To retain epsem with the desired overall sampling rate (f = 0.1), what is the targeted subsample size for each cluster in Stratum 2?

-   Paired selection from strata is given as:

$$
f_i = \frac{n_i \times m_i}{\sum_{i \in h}^H MOS_{hi}}
$$

-   Where n is the number of clusters to be selected in each stratum *h*, and *m* is the desired subsample size we need to solve. MOS_hi is the total subsample in stratum *h*.

```r

f <- .10 # overall sampling rate

f_1 <- (N_h1 * f) / n_h1 ; f_1
f_2 <- (N_h2 * f) / n_h2 ; f_2
```

-   The targetd subsample size for each cluster in stratum 1 is `r round(f_1, 0)` and for stratum 2 is `r round(f_2, 0)`.

\newpage

4.  Please indicate whether each of the following statements are TRUE or FALSE by circling what you believe to be the correct answer.

<!-- -->

a.  (TRUE / **FALSE**) The Taylor Series Linearization method for estimating the sampling variance of an estimated mean is necessary when selecting a simple random sample of n clusters from a total population of N clusters, and a simple random sample of m elements from the M population elements in each of the n randomly sampled clusters.
    a.  Linearization is a method for estimating variance of a statistic that is a differentiable function of estimated population totals by using Taylor series. Moreover, Taylor series linearization applies when using complex designs of two-stage cluster sampling with unequal sizes when standard variance methods, and the MSE and variance are equal.
b.  (**TRUE** / FALSE) The use of weights in analyses (whatever introduced the need to use them) will generally tend to increase the sampling variance of estimates, and the more variable the weights are, the higher the increase.
    a.  Weights can increase sampling variance of weighted estimates.
c.  (**TRUE** / FALSE) Under certain assumptions, one can compute the size of a simple random sample needed to achieve a certain level of sampling variance for a given estimated mean if the only two pieces of information provided are 1) the desired level of sampling variance and 2) an estimate of the element variance.
    a.  Desired sample size depends on the population element variance and knowing what the desired sampling variance is.
d.  (TRUE / **FALSE**) With unequal-sized clusters and a fixed subsample size b within each cluster, the simple unweighted mean can still be used as an unbiased estimate of the population mean.
    a.  Our sample size is a random variable.
e.  (TRUE / **FALSE**) The approximation of the variance when using Taylor Series Linearization is adequate for inference if the coefficient of variation of the sample size is 0.8.
    a.  CV should be less than 0.1, up to 0.2. are adequate.
f.  (**TRUE** / FALSE) In determining the number of clusters selected in stratified cluster sampling, allocation proportionate to the number of elements in a stratum in the population facilitates self-weighting element selection
    a.  Proportionate allocation usually refers to elements and not clusters; This kind of allocation allows us to maintain epsem for the elements.
g.  (TRUE / **FALSE**) If the elements in a list are approximately continuously ordered and an odd number of units is selected using systematic random sampling, the paired selection model can be used for variance estimation.
    a.  Paired selection model for even sample $df=n/2$ odd sample size user successive differences model, df is between $n/2$ and $n-1$.
h.  (TRUE / **FALSE**) If one selects all possible elements within a cluster that has been selected using simple random sampling (i.e., clusters were selected with equal probability), but the clusters are of unequal sizes, selection probabilities will vary for different population elements.
    a.  The selection probability of each population element is the product of the selection probability of the cluster and the conditional selection probability of the element in the selected cluster. With SRS of clusters, the selection probability of the cluster is equal. When selecting all possible elements, the conditional selection probability of the element in the selected cluster is 1.
i.  (TRUE / **FALSE**) The sampling variance under “ultimate cluster” sampling mimics the sampling variance under with replacement selection of primary stage clusters and without replacement subsampling of elements within the clusters.
    a.  When ultimate clusters are selected without replacement, the variance estimation process can be more complex compared to with-replacement sampling due to the dependencies introduced among clusters.
j.  (TRUE / **FALSE**) Varying the subsample size m in two-stage cluster sampling by design will impact the rate of homogeneity, design effects and thus effective sample sizes.
    a.  Changing subsample size $m$ for fixed $𝑚 ∗ 𝑛$ will change the number of clusters, the design effect, and the effective sample size, but not $roh$. As $𝑚$ increases, $𝑑𝑒𝑓𝑓$ increases (roh fixed), and the effective sample size decreases.
k.  (**TRUE** / FALSE) In theory, the estimate of sampling variance in two-stage cluster sampling includes the between-cluster and within-cluster sampling.
    a.  Variance estimation: involves both between- and within-cluster variance; ultimate clusters
l.  (**TRUE** / FALSE) A proportionate allocation design is epsem (ignoring rounding error)
    a.  Proportionate allocation: Representative sampling where the sample reflects the population with respect to the stratification variable, epsem.

\newpage

5.  The Michigan Department of Health has hired you to evaluate design alternatives for a new sample of housing units in the state of Michigan. The objective of the larger study is to estimate the proportion of adults between the ages of 18 and 29 with private health insurance. A two-stage cluster sample is under consideration, featuring the selection of housing units within Census block groups.

a\. Compute the size of a simple random sample of housing units (assuming one respondent per housing unit) needed to obtain a 99% confidence interval with half-width 0.025 for an expected proportion of 0.5. Assume that the degrees of freedom will be larger than 30 for this calculation, and ignore the FPC.

-   We will need to use a two stage cluster design.

$$
\text{SRSWR } n_o = \frac{z^2_{a/2} \times \hat{s}^2}{e^2} \\ 
\text{SRS } n = \frac{n_0}{1 +\frac{n_0}{N}}
$$

```r

# function will take 
project_SRS_sample_fun <- function(z, p, e){
  
  # we take the proportion, divide by half to get e
  # compute SRSWR
  n_0 = (z^2 *  (p*(1-p)) ) / e^2
  
  # compute SRS
  cat(str_c("The SRS sample size is "), round(n_0, 0))
}

#______________ run function _________________

# pass the desired z-score, estimated proportion, error
project_SRS_sample_fun(z = 2.576, # use 1.96 for 95% CI
                       p = 0.5, # estimated proportion
                       e = 0.025) # error

```

\

b\. Assuming the ultimate cluster model for a previous sample of 1,000 housing units selected from a sample of 15 block groups, the estimated between-cluster variance in proportions was 0.01. For a proportion estimated to be 0.5, what was the design effect associated with this previous design? What is the estimated value of roh for this indicator of having private health insurance?

-   We use the information provided to calculated a design effect and roh printed below, where a m is the total number of elements, and n is the total number of clusters. $\bar{m} = m/n$.

$$
var_{clsuter} = \frac{s^2_b}{m} 
$$ $$
var_{srs} = \frac{p(1-p)}{n-1} 
$$ $$
DEFF = \frac{var_{clsuter}}{var_{srs}} 
$$ $$
\hat{roh} = \frac{DEFF - 1}{\bar{m} - 1}
$$

```r
m <- 1000 # total elements
n <- 15 # total clusters
between_var<- .01 # given to us 
p_hat <- .50 # given to us

# _________________ automated code below __________________
var_SRS <- (p_hat *(1-p_hat)) / (m-1) # variance for SRS
var_cluster <- between_var / n # variance for complex design

# estimate DEFF with variances
m_bar <- m / n 
DEFF <- var_cluster / var_SRS
ROH <- (DEFF - 1) / (m_bar - 1) 

tibble(m_bar, DEFF, ROH) |> 
  mutate_all(round, 3) |> 
  kable()

```

\

c\. Assuming that this design effect will also apply to the new cluster sample design under consideration, how many housing units would you need to select overall in the new cluster sample to meet the same precision objectives from part 5a?

-   We use the estimate from 5.a. and multiply it by the design effect in 5.b to get the new cluster sample to meet the same precision.

```r
n_srs <- 2654
n_cluster <- n_srs * DEFF ; n_cluster
```

\

d\. The Department of Health suggests that it will cost \$5000 per sampled block group and \$100 per housing unit for data collection. What would the optimum subsample size per block group be? Given this information and the result in part c), how many block groups would you need to sample to produce an overall sample size that meets the stated precision objectives?

-   To compute the optimum $m$ size we use the following equation:

$$ 
m_{opt} = \sqrt{\frac{c_n}{c_m} \frac{1-roh}{roh}} 
$$

```r
c_n = 5000 # cost per cluster
c_m = 100 # cost per element within cluster


m_opt <- sqrt(
  (c_n / c_m) * ((1-ROH) / ROH )
)

round(n_cluster / # from 5.c
      m_opt, 0)

```

\

e\. Assume that you have the budget to purchase a commercial list of addresses within each selected block group. List two potential problems with the overall sampling frame that you can construct based on the list of block groups and the purchased commercial data. What could you do to solve these problems?

-   One potential problem that may arise in a list of the frame is an incomplete or inaccurate list leading to noncoverage, meaning that some elements of the population have a zero probability of being selected. A potential solution in noncoverage weighting adjustments.

-   A second potential problem is that the list may contain blanks, which in this case we can reject blanks by adjusting the sampling rate and size or substitute with the next element on the list.

-   Duplicates can also be present in the list, which occur when a single population element is linked to two or more frame elements. We can remove duplicates if there are only a few, but may leave unequal probabilities of selection. Therefore, we may wish to determine how many duplicates for a given selected element exist and weight them accordingly.

\

f\. The vendor of the commercial data advertises the ability to purchase additional auxiliary variables for the addresses in each selected block group, and you have the budget to do this. What auxiliary information should you request? For what might you use this auxiliary information?

-   When selecting auxiliary information we will want to choose variables that correlate with the study outcome (health insurance coverage among 18-29 year olds) to help improve efficiency and accuracy of the sampling estimates. For instance, if we could purchase information on race/ethnicity we may be able to use the auxiliary information to formulate stratas that are mutually exclusive and collectively exhaustive subgroups.

\

g\. For the overall sample, there is budget available for the selection of 30 block groups. Proportionately allocate the block groups to be sampled from each of the five counties (strata) defining the target population below. You should round your answers in a way that maintains the total sample size of 30 block groups.

```r
n <- 30 # sample block units to be selected

dat <- tibble(
  County = c("Wayne", "Washtenaw", "Oakland", "Livingston", "Genesse"),
  cluster_units = c(250, 50, 150, 25, 45),
  element_units = c(900000, 180000, 600000, 90000, 200000)
  )  |> 
  # add proportionate allocation
  mutate(weight = cluster_units / sum(cluster_units),
         weight = round(weight, 3),
         units_selected = round(weight * n)) 

# print data
dat |> kable()
```

\

h\. What is your proposed sampling error estimation plan for data analysts based on this allocation in Part g?

-   The proposed sampling error estimation will require using an appropriate variance estimation that accounts for the stratified cluster sampling design. We may wish to use the Taylor series linerization to account for the stratification and clustering effects. Additionally, we will also estimate the design effect to account for the within clustering correlation, which is likely to increase the sampling variance compared to the SRS variance.

\

6.  An analyst computes the standard deviation of the final survey weights in a given survey data set as 40, and the mean of those final weights as 100. What is the expected increase in the sampling variance of an estimated mean if these weights are to be used in estimation? Write the correct interpretation of this expected increase in plain English, keeping in mind the assumptions underlying this calculation.

-   We use $cv(\hat {t}_x) = \frac{se(\hat{t}_x)}{t_x}$ to calculate the coefficient of variation (CV) of the weights. The expected increase in the sampling variance is approximately , $cv^2$.

```r
std_dev <- 40
m <- 100

CV <- (std_dev / m) ; CV

1 + CV^2
```

-   The expected increase in the sampling variance of an estimated mean, if these weights are used, is `r scales::percent(CV^2)`. That is, if these weights are used in the estimation of population quantities, we should expect the sampling variance of an estimated quantity to be 16% larger than it would have been if all the weights were equal.
