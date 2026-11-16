---
id: "jpsm/Fund_Infe_SURV740/assignments/HW4"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Homework 4: Randomization Inference"
original: "Fund_Infe_SURV740/assignments/HW4.qmd"
pages: 
sha256: "4b995c180af67cbfa8c95e79a89d6f455bc49d73b97c32e2dba61870e8a39134"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:05"
---


```r
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)

pacman::p_load(knitr, viridis, patchwork, tidyverse)

options(digits=5, scipen=999)


# Set theme for plots
theme_set(theme_minimal())
```

### 1: Sampling Distributions. Using software of your choosing, generate a population of size $N=100,000$ with random draws from a normal distribution with mean=15 and variance=3. For your random draws, set a seed of 41279 in R to ensure replication.

-   \(a\) Give the finite target population mean and population variance. Is there superpopulation here, if so, what is it?

```r
set.seed(41279)
N <- 100000
Mu <- 15
Sigma <- sqrt(3)

# random draws
pop_df <- tibble(y = rnorm(N, mean = Mu, sd=Sigma)) 

pop_df |> 
  reframe(Mean = mean(y), Variance = var(y), N=n()) |> 
  mutate_all(round,3) |> kable(caption ="Finite Population Parameters")
```

\newpage

-   The finite population is the result of 100,000 random draws with the parameters of $\mu= 15$ and $\sigma^2=3$.\

<!-- -->

-   \(b\) Draw a single simple random sample, without replacement (SRSWOR), of size n=1,000. Calculate the estimated mean, the estimated standard error of the estimated mean, and a 95% CI for the population mean.

-   We use the following formula to calculate the sampling element variance.

$$
s^2 = \frac{1}{n-1}\sum^n_{i=1}(y_i - \bar{y})^2
$$

-   To estimate the element variance we first must calculate the finite population correction (FPC) factor for our population of 100,000 as $f = n/N$.

-   With $s^2$ and the FPC we can now calculate the estimated sampling variance and standard error, $\sqrt{var(\bar{y})}$.

$$
var(\bar{y}) = (1-f)\frac{s^2}{n}
$$

-   We use the standard error to compute 95% confidence intervals, which indicate the accuracy of the sampling mean estimate. If we were to take samples from the same population and construct a confidence interval, we would expect 95% of the resulting intervals to include the true value of the population parameter. Out 95% CI is given as:

$$
\bar{y} \pm t_{1-\alpha / 2}\times se(\bar{y})
$$

\newpage

```r
n <- 1000
f <- n/N

set.seed(41279)
sample_df <- pop_df |> 
  # slice function will randomly select rows WOR
  slice_sample(n=n, replace = FALSE) |> 
  # compute mean and standard error, and 95% CI
  reframe(
    y_bar = mean(y),
    s_sqr = (1 / (n() - 1) ) * (sum( (y - y_bar)^2)),
    y_var = (1-f) * (s_sqr/n()),
    se = sqrt(y_var),
    lower = y_bar - 1.96 * se,
    upper = y_bar + 1.96 * se
  )

sample_df |> 
  pivot_longer(everything(), names_to = "Statistic", values_to="Estimate") |> 
  mutate(Estimate = round(Estimate, 3)) |> 
  kable(caption ="Sampling Statistics from random sample of 1,000")
```

\newpage

\

-   \(c\) Draw a single simple random sample of size n=1,000. Store the estimated mean of the variable and the estimated variance of the variable calculated from this sample. Repeat this process 2,000 times. Although the estimates from this process will not yield the full sampling distributions, these should be a good approximations. Plot the approximation of the sampling distribution of the estimated mean. Plot the approximation of the sampling distribution of the estimated variance. Extract the 2.5 and 97.5 percentiles of the sampling distribution of the estimated mean.

```r
n_samples <- 2000

sampling_dist <- map_dfr(seq(1:n_samples), function(draw){
  
  # set moving seed to replicate
  set.seed(draw)
  
  pop_df |> 
  # slice function will randomly select rows WOR
  slice_sample(n=n, replace = FALSE) |> 
  # compute mean and variance
  reframe(
    sample_means = mean(y),
    sample_var  = (1 / (n() - 1) ) * (sum( (y - sample_means)^2))
  )
  
})

```

```r
#| fig-width: 7
#| fig-height: 7.5


p_1 <- sampling_dist |> 
  ggplot(aes(x=sample_means)) +
  geom_histogram(aes(y =after_stat(density)),bins =50,
                 fill = "dodgerblue", alpha=.7) +
  geom_density(color ="darkred",linewidth =1) +
  labs(title ="Sampling Distribution of Sample Mean",
       subtitle =paste("2000 samples of size n =", n),
       x ="Sample Mean",y ="Density")


p_2 <- sampling_dist |> 
  ggplot(aes(x=sample_var)) +
  geom_histogram(aes(y =after_stat(density)),bins =50,
                 fill = "orange", alpha=.7) +
  geom_density(color ="darkred",linewidth =1) +
  labs(title ="Sampling Distribution of Sample Variance",
       subtitle =paste("2000 samples of size n =", n),
       x ="Sample Mean",y ="Density")

p_1 / p_2
```

-   We plot the sampling distribution for the means and variances for 1000 draws without replacement. Below we extract the 2.5 and 97.5 percentiles for the sampling mean and print summary statistics.

```r
percentiles <- quantile(sampling_dist$sample_means,probs =c(0.025,0.975))

percentiles |> kable(caption ="2.5 and 97.5 percentiles")
```

\

-   \(d\) How do the 95% CI and the percentiles in **1b and 1c** compare? Explain the difference between these quantities in **1b and 1c.**

    -   We can see the the widths of these intervals are very close; however, when we plot them we see the confidence interval slightly shift to the right. Both intervals contain the population mean of 15. We do note here the at the 95% interval is based on one sample and uses the normal approximation, while the percentiles represents the actual distribution of sample means across 2,000 repeated samples. Moreover, the confidence intervals is an inference about the population parameter, and the percentiles describe the sampling distribution of the estimator mean.

```r
intervals <- sample_df |> select(lower, upper) |> 
  add_row(
    percentiles |> tibble() |> mutate(Estimate = c("lower", "upper")) |> 
      pivot_wider(names_from = Estimate, values_from=percentiles)
  ) |> 
  mutate(Method = c("Confidence Intervals", "Percentiles"),
         width = round(upper-lower, 4)) |> 
  relocate(Method) 

intervals |> kable(caption ="Comparing 95% CI with Percentiles")

# plot the intervals
intervals |> 
  ggplot(aes(x = lower, y = Method, color = Method)) +
  geom_segment(aes(xend = upper, yend = Method), colour = "black") +
  geom_point(size = 3) +
  geom_point(aes(x = upper), size = 3) +
  xlim(c(14.75,15.25)) +
  theme(legend.position = "none") +
  scale_color_viridis_d(begin=.2, end = .8, alpha=.8)
```

\newpage

-   \(e\) When evaluating alternative estimation and inferential procedures, we are often concerned with whether or not a computed confidence interval following a particular procedure has the stated level of coverage (i.e., 95% of the intervals computed in the same way across repeated samples cover the true population parameter). Compute the coverage rate of the 95% CI for the population mean, computed for each of the 2,000 repeated samples. Do these intervals have the stated level of coverage?

    -   We compute 95% confidence intervals for each draw of size 1,000 and find that 94.6% of these intervals contains the population mean of 15, which the coverage rate is very close to the nominal 95% level.

```r
#| fig-width: 6
#| fig-height: 2.5


sampling_dist <- sampling_dist |> 
  reframe(
    y_var = (1-f) * (sample_var/n),
    se = sqrt(y_var),
    lower = sample_means  - 1.96 * se,
    upper = sample_means  + 1.96 * se
  ) |> 
  mutate(pop_mean = Mu,
    "Contains Pop Mean" = ifelse(between(pop_mean, lower, upper), TRUE, FALSE) ) 

sampling_dist |> 
  count(`Contains Pop Mean`) |> 
  mutate(prop = n/sum(n)) |> 
  ggplot(aes(y=prop, x=`Contains Pop Mean`)) +
  geom_col(fill="dodgerblue", alpha=.5) +
  scale_y_continuous(labels = scales::percent) +
  labs(title ="Sampling Distribution of 95% Confidence Intervals", y ="Percent")
  
```

\newpage

2.  Confidence Interval for Transformation.

-   \(a\) Using the example for the mean no. of housing units renting in each block on slide 10 Module 8, compute the 95% confidence interval for the transformation logit (Q (Y ) ) using the results of slide 12.

-   \(b\) Using the results in a.) now compute the 95% confidence interval for Q (Y ).

```r
f_srs <- 20/270 # n/N

# sample proportion 
q_y <- 6 / 20

# variance estimation for sample proportion 
v_q_y <- (1-f_srs) * (q_y * (1 - q_y)) / (20 - 1)

results_2 <- tibble(q_y, v_q_y) |> 
  # compute 95% CI
  mutate(log_q_y = log(q_y / (1-q_y)),
         # variance on log scale
         log_v_q_y = v_q_y / (q_y * (1-q_y))^2,
         log_se = sqrt(log_v_q_y),
         lower = log_q_y - 1.96 * log_se,
         upper = log_q_y + 1.96 * log_se,
         Method = "Log Scale") |> 
    select(Method, log_q_y, lower, upper) |> 
  rename(q_y = log_q_y)

results_2 |> 
  add_row(Method = "Back Transformed", q_y,
          results_2 |> 
  mutate(# back transformation
         lower = exp(lower) / (1 + exp(lower)),
         upper = exp(upper) / (1 + exp(upper))) |> 
  select(lower, upper)) |> 
  kable(caption ="Estimates for Q_Y and 95% CI")
```

\newpage

3.  Design Effects and Effective Sample Sizes.

-   \(a\) Suppose that the data from Module 8, Slide 10 represent a two-stage cluster sample, rather than a simple random sample, where a simple random sample of 20 clusters (blocks) was selected at the first stage, and each of the exactly 60 housing units in each block, i.e., no subsampling within sampled blocks, was asked whether they own or rent at the second stage. We therefore have a sample of size n = 20 x 60 = 1,200 housing units, selected from a population of size N = 270 x 60 = 16,200 housing units. What is the estimated proportion, p , of housing units in this population that are rentals?

    -   We compute the sample proportion, $\hat{p} = \sum_{i=1}^n y_i/n$, below of housing units that are rentals.

```r
a <- 20
b <- 60
n <- a*b
A <- 60
B <- 270
N <- A*B
f <- n/N

block_data <- tibble(
  rentals = 
    c(3, 5, 5, 52, 21, 34, 3, 0, 0, 0, 17, 14, 0, 0, 2, 54, 11, 11, 0, 23)
) |> 
  mutate(b = b,
         cluster = row_number(),
  prop = rentals / b)

block_data |> 
   summarise(p_hat = mean(prop)) |> 
    kable(caption ="Sample Proportion")
```

\

-   \(b\) What is the estimated variance of this estimated proportion? Hint: for a two-stage cluster sample with equal-size clusters at the first stage. $var(p)=(1-f)\frac{s^2}{a}$, given this variance, compute 95% CI for this population.

```r
rental_results <- block_data |>  
  summarise(
    p_hat = mean(prop),
    p_s_sqrd = sum((prop - p_hat)^2) / (a-1),
    p_var = (1-f) * p_s_sqrd/a,
    p_se = sqrt(p_var),
    lower = p_hat - 1.96 * p_se,
    upper = p_hat + 1.96 * p_se )

rental_results |> kable(caption ="Estimated Sampling Statistics")
```

-   We compute the sampling proportion of rentals to be .21 (SE=.060, 95% CI\[.095, .330\]).

\

-   \(c\) Assume instead that this was a simple random sample of the same size (n = 1,200), and compute the estimated variance of the estimated proportion under this design. What is the design effect for this estimated proportion due to the two-stage cluster sampling? What is the effective sample size in the case of this two-stage cluster sample? Write a plain English definition of this effective sample size.

```r
p_hat <- rental_results |> pull(p_hat)
var_srs <- (1-f)*((p_hat * (1-p_hat)) / (n-1))

var_srs |>  kable(col.name = c("Variance"), caption ="SRS")
```

-   We estimate the SRS sampling variance to be `r round(var_srs, 4)`. With this we compute the design effect roh as:

$$
deff = \frac{var(\hat{p})}{var_{srs(}\hat{p})}
$$

-   To compute the effective sample size we use deff, $n_{eff} = n/deff$.

```r
deff <- rental_results |> pull(p_var) / var_srs
deff |> kable(col.name = c("Deff"), caption ="Design Effect")

n_eff <- ceiling(n / deff)
n_eff |> kable(col.name = c("n_eff"), caption ="Effective Sample Size")
```

-   The design effect is high and indicates severe clustering effects, moreover the variance of our complex design is 5.2 $\sqrt{deff}$ times higher than that of the SRS design. The effective sample size represents the size of a simple random sample that would provide the same precision as out complex design of size 1,200. In other words, our cluster sample of 1,200 units is as precise as a simple random sample of 44 units.

\newpage

-   \(d\) Which of the two sampling plans would you select (for a sample of size n = 1,200) based on the design effect and the comparison of these estimated variances? What would be the implication for the frequentist coverage rate of the 95% confidence intervals if you assumed a simple random sample of size n = 1,200, when in fact a two-stage cluster sample was selected?

    -   Based on the design effect that is greater than 1 means that the complex design increases variance. The standard error might be underestimated under the clustering design by a factor of 5 as mentioned in (c) which would impact the confidence intervals making them narrow and likely to commit a type I error for hypothesis testing. Therefore, I would choose the SRS design because it provides smaller variance, offers statistical efficiency, yet we may want to consider practical considerations favoring clustering sampling such as lower cost of data collection or easier fielding of operations. due to geographic dispersion.

\newpage

4.  Consider a population of size N=4 given by Y ={5 ,10 , 35 ,100}. Suppose the goal is to estimate the finite population mean $\bar{Y} = 1/4\sum_{i=1}^4 Y_i$ based on a simple random sample of size n=2. Consider three estimating procedures: 1) the arithmetic mean defined as $\frac{1}{2}\sum^2_{i=1} y_i, 2$ the harmonic mean defined as $(\frac{1}{2}\sum^2_{i=1} \frac{1}{y_i})^{-1}$ and 3) the geometric mean, defined as $(\prod_{i=1}^2 y_i)^{1/2}$.

```r
Y1 <- c(5, 10, 35, 100)
N <- 4
n <- 2

# true pop
pop_mu <- mean(Y1)


```

-   \(a\) For all 6 possible simple random samples of size n=2 (Hint: you can derive the entire sampling distribution based on all possible samples under this sampling plan!), compute the arithmetic, harmonic, and geometric means.

    -   We first start with generating the number of unique simple random draws of size 2 without replacement from the population of size 4 as:

\begin{align*}
\binom{N}{n} = \binom{4}{2} = \frac{4!}{2!(4-2)!} = 6
\end{align*}

```r
# How to determine how many sample combinations
n_samples <- choose(N, n)
```

-   Next we compute for each possible sample the arithmetric mean, harmonic mean, and geometric mean

```r
all_samples <-
  # Generate all combinations of n from the population Y
  combn(Y1, n) |>
  # transpose matrix
  t() |>
  # convert to tibble
  as_tibble() |>
  # give proper names to columns
  rename(y1=1, y2=2) |>
  # add sample ID
  mutate(sample_id = row_number()) |>
  relocate(sample_id)

all_samples <- all_samples |> 
  mutate(Arithmetric = (y1 + y2)/2,
          Harmonic = 2 / (1/y1 + 1/y2),
          Geometric = sqrt(y1 * y2)
  )

all_samples |>  kable(caption ="Sample Statistics")
```

\

-   \(b\) Compute the bias of each estimating procedure.

-   \(c\) Compute the variance of each estimating procedure.

    -   Results for (b) and (c) are captured in (d).

```r
means <- all_samples |> 
  reframe(arith_mean = mean(Arithmetric),
          harm_mean = mean(Harmonic),
          geom_mean = mean(Geometric))

biases <- all_samples |> 
  reframe(bias_arith = mean(Arithmetric) - pop_mu,
          bias_harm = mean(Harmonic) - pop_mu,
          bias_geom = mean(Geometric) - pop_mu)

variances <- all_samples |> 
  reframe( var_arith = sum((Arithmetric - mean(Arithmetric))^2)/n(),
    var_harm = sum((Harmonic - mean(Harmonic))^2)/n(), 
    var_geom = sum((Geometric - mean(Geometric))^2)/n())
```

-   \(d\) Compute the mean squared error of each estimating procedure.

```r
MSE <- biases^2 + variances |> 
  rename(MSE_arith=1, MSE_harm=2, MSE_geom=3)


# put the estimates in one table
tibble(Statistic = c('Artimetic', "Harmonic", "Geometric"),
       Means = means |> as.numeric(),
       Biases = biases |> as.numeric(),
       Variances = variances |> as.numeric(),
       MSE = MSE |> as.numeric()
       ) |> 
  kable(caption ="Statistics for Different Mean Estimators")
```

-   \(e\) Based on your results in a)-d), briefly comment on the strengths and weaknesses of each procedure.

    -   It appears from these results that the arithmetic mean is an unbiased estimator as the mean of these samples equals the population mean, however, the variance was much higher than the other methods. The harmonic mean had the lowest variance but a severe bias estimate and thus highest MSE. The geometric mean had moderate variance and the lowest MSE, meaning that it underestimates the population mean.

\newpage

-   \(f\) Repeat a)-d) for a different population Y ={5 ,10 ,16 ,18}. Briefly discuss how these results update your comments in e).

```r

Y1 <- c(5, 10, 16, 18)

# true pop
pop_mu <- mean(Y1)

all_samples <-
  # Generate all combinations of n from the population Y
  combn(Y1, n) |>
  # transpose matrix
  t() |>
  # convert to tibble
  as_tibble() |>
  # give proper names to columns
  rename(y1=1, y2=2) |>
  # add sample ID
  mutate(sample_id = row_number()) |>
  relocate(sample_id)



all_samples <- all_samples |> 
  mutate(Arithmetric = (y1 + y2)/2,
          Harmonic = 2 / (1/y1 + 1/y2),
          Geometric = sqrt(y1 * y2)
  )

all_samples |> 
  kable(caption ="Sample Statistics")


means <- all_samples |> 
  reframe(arith_mean = mean(Arithmetric),
          harm_mean = mean(Harmonic),
          geom_mean = mean(Geometric))


biases <- all_samples |> 
  reframe(bias_arith = mean(Arithmetric) - pop_mu,
          bias_harm = mean(Harmonic) - pop_mu,
          bias_geom = mean(Geometric) - pop_mu)

variances <- all_samples |> 
  reframe( var_arith = sum((Arithmetric - mean(Arithmetric))^2)/n(),
    var_harm = sum((Harmonic - mean(Harmonic))^2)/n(), 
    var_geom = sum((Geometric - mean(Geometric))^2)/n())

MSE <- biases^2 + variances |> 
  rename(MSE_arith=1, MSE_harm=2, MSE_geom=3)


# put the estimates in one table
tibble(Statistic = c('Artimetic', "Harmonic", "Geometric"),
       Means = means |> as.numeric(),
       Biases = biases |> as.numeric(),
       Variances = variances |> as.numeric(),
       MSE = MSE |> as.numeric()
       ) |> 
  kable(caption ="Statistics for Different Mean Estimators")
```

-   The arithmetic mean remains unbiased regardless of the population distribution. We see that with the lack of the outlier all three mean estimators have a similar MSE. The variance difference is much smaller with the exclusion of this outlier. Moreover, it seems that alternative means perform better with symmetric populations, but the arithmetic mean is still optimal.

\newpage

5.  Provide one important benefit (pro) and one important drawback (con) for inferences based on each of the two primary statistical viewpoints: Design-based and Bayesian.

| Viewpoints | Pro | Con |
|------------------------|------------------------|------------------------|
| Design-based | Objective and reproducible - Results depend only on the sampling design, not subjective assumptions. Valid inference regardless of the true data generating process. | Con: Limited to probability samples - Cannot handle non-probability samples well and assumes perfect response. May be inefficient when strong auxiliary information is available. |
|  |  |  |
| Bayesian | Incorporates prior knowledge - Can formally incorporate expert knowledge and previous studies through prior distributions, leading to more efficient inference when priors are reliable. | Subjective prior specification - Results can be sensitive to prior choice, especially with small samples. Different analysts might reach different conclusions based on their prior beliefs. |
