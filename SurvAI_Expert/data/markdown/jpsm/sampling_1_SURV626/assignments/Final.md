---
id: "jpsm/sampling_1_SURV626/assignments/Final"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Final, Sampling"
original: "sampling_1_SURV626/assignments/Final.qmd"
pages: 
sha256: "76ddc1d3c544a7657e8ca225de76593b2a82b87d2f4f3360ca6dab77a7263af2"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:11"
---


```r
pacman::p_load(knitr, kableExtra, MESS, tidyverse)

options(scipen=999)
```

*This is an open-book and open-notes exam. This is an individual exam; please do not consult anyone while solving these problems. If you have any questions about the problems, please send me a direct message on Canvas.*

*You have 48 hours to return your solution from the time you open the final exam link in the course website. Please, return your solution in the same format as the homework assignments.*

*Points for each problem/part of problem are in bold square brackets. Please, show formulas and steps in calculations.*

1.  **A large corporation with 20,000 employees is interested in estimating the proportion of employees that have completed high school. The proportion is believed to be between 0.7 and 0.9. What size simple random sample should be selected so that the total length of a 95% confidence interval for the proportion is less than 0.05?**
    1.  For simple random sampling, the confidence interval for a proportion is:

$$CI = \hat{p} \pm z_{\alpha/2} \sqrt{\frac{\hat{p}(1-\hat{p})}{n}  \frac{N-n}{N}}$$

-   The total length of the CI = $2 \cdot z_{\alpha/2} \sqrt{\frac{p(1-p)}{n}}$ We need this to be less than 0.05.

-   We use the conservative prior $p=.7$ to maximize variance within the belief ranges, or $P=.5$ for absolute conservatism. The required sample size of 1,428 (w/o FPC 1,537) under the conservative *p* of .5 to ensure precision requirement is met regardless of true proportion. However, if we only use *p* of .7, we would need 1,213 sample size, which would save us 215 interviews with the trade off of loss in precision.

```r
# parameters
N <- 20000
e <- 0.025
z <- 1.96
p <- 0.5  # sonservative assumption

# infinite population sample size (n0)
n0 <- (z^2 * p * (1 - p)) / e^2

# apply FPC
n_final <- n0 / (1 + (n0 / N))

tibble(
  Method = c("Infinite Formula (n0)", "With FPC (n_final)"),
  Size = c(ceiling(n0), ceiling(n_final))) |> 
  kable()
```

\newpage

2.  **TRUE/FALSE. In simple random sampling from a large population, doubling the number of elements selected will decrease the sampling variance of a mean by one-half. Explain your answer.**
    2.  **TRUE.** For a SRS, the variance of the sample mean is $var(\bar{y}) = s^2/n \times (N-n)/(N-1)$. For a large population, the variance is then $var(\bar{y}) = s^2/n$ and if we double the sample size from n to $2n$, new $s^2/(2n) = (1/2) \times (s^2/n) = (1/2) \times var(\bar{y})$. The sampling variance is inversely proportional to $n$, so doubling $n$ reduces the variances by half. Below when we double n reduces the variance by a factor of exactly 2.

```r
# empirical proof
S2 <- 100
n1 <- 100
n2 <- 200

var1 <- S2 / n1
var2 <- S2 / n2
ratio <- var1 / var2

cat(str_c("Reduction Factor:", ratio))
```

\newpage

3.  **The following data comes from an unequal sized cluster sample drawn from a very large city. The total number of hours per sleep on an average night are summed up for each cluster** $(y_{\alpha})$ **as are the total number of persons in each cluster (**$x_{\alpha}$**).**

```r
cluster_data <- tibble(
  cluster = seq(1:10),
  y = c(325,105,95,165,110,255,155,225,165,225), # total hours
  x =c(40,15,15,25,15,30,25,30,20,30) # number of persons
  )

cluster_data |> kable()
```

-   **(a) Estimate the mean hours of sleep on an average night for the city and its standard error.**

    -   For unequal cluster sizes, we use the **combined ratio estimator**:

        $$\hat{\bar{y}}_r = \frac{\sum_{α=1}^{a} y_α}{\sum_{α=1}^{a} x_α} = \frac{\bar{y}}{\bar{x}}$$

        The variance using Taylor linearization:

        $$\text{Var}(\hat{\bar{y}}_r) = \frac{1}{a\bar{x}^2}\left[s_y^2 + \hat{r}^2 s_x^2 - 2\hat{r}s_{yx}\right]$$

    -   Mean hours of sleep per night is 7.5 (SE=.26).

```r
cluster_data |> 
  reframe(Mean = sum(y) / sum(x),
            s2_d = sum((y -  (Mean*x) )^2) / (n() - 1),
            Var = s2_d / (n() * mean(x)^2),
            SE = sqrt(Var)
            ) |> 
  mutate_all(round, 3) |> 
  kable()
```

\

-   **(b) In the previous problem, what is the** $cv(x)$ **, and is it satisfactory?**
    -   The coefficient of variation of cluster sizes determines the stability of the ratio estimator:

        $$CV(x) = \frac{s_x}{\bar{x}}$$

    -   The $cv(x)=.34$ is greater than 0.20, which means the Taylor Series approximation is not adequate.

```r
cluster_data |> 
  reframe(
    Mean = mean(x),
    s2_d = sd(x),
    CV = s2_d / Mean) |> 
  mutate_all(round, 3) |> 
  kable()
```

\newpage

-   **(c) If** $s^2=12$ **in part (a), what is deff** $\bar{y}$ **and the intra-cluster homogeneity** $roh$**?**
    -   The design effect quantifies efficiency loss due to clustering:

        $$
        \text{deff} = \frac{\text{Var}_{cluster}(\bar{y})}
        {\text{Var}_{SRS}(\bar{y})}
        $$

    -   For equal-sized clusters (approximation):

        $$\text{deff} = 1 + (b-1)\rho$$

    -   Solving for the intra-cluster correlation, roh:

        $$\rho = \frac{\text{deff} - 1}{b - 1}$$

    -   The deff of 1.4 suggests that the complex design is not more precise than the SRS design, so that the clustering increases variance by a factor of 1.4. The positive value of roh .02 indicates positive clustering in that elements within cluster are more similar than between clusters meaning that clusters are fairly heterogeneous.

```r
s_2 <- 12

results_c <- cluster_data |> 
  reframe(
    b_bar = mean(x),
    Mean = sum(y) / sum(x),
    var_srs = s_2 / sum(x),
    s2_d = sum((y -  (Mean*x) )^2) / (n() - 1),
    Var = s2_d / (n() * b_bar^2),
    deff = Var / var_srs,
    roh = (deff - 1) / (b_bar - 1)
  ) 

results_c |> 
  select(deff, roh) |> 
  mutate_all(round, 3) |> 
  kable()
```

\

-   **(d) We are going to design a new survey that will be based on a cluster sample with subsampling of elements. The variable we will be collecting is the number of hours of sleep on an average night. We know from prior studies that the costs associated with each cluster,** $c_a$ **, are \$40, while the costs associated with each element in the sample,** $c_b$ **, are \$8. What is the optimal cluster size for this new design?**
    -   We use the optimal cluster size $b_{opt} = \sqrt{c_a \times (1 - p) / (c_b \times roh}$ and determine that 17 (16.7) elements per cluster is optimal to minimize the total cost for a given variance.

```r
c_a <- 40  # cost per cluster
c_b <- 8   # cost per element
s2 <- 12   # within-cluster variance

roh <- results_c |> pull(roh)

b_opt <- round(
  sqrt( (c_a / c_b) * ( (1-roh)/roh) ), 2
) 

b_opt |> tibble() |> kable()
```

\newpage

-   **(e) Recall that** $s^2=12$**. You have a total budget that will allow you to select a sample of 10 clusters with the** $b_{opt}$ **you calculated in part (d). What is the expected sampling variance for the new design with your optimal cluster size from part (d)?**

    -   We calculate the expected variance as $var(\bar{y}) = s^2/n \times (1 + (b_{opt}- 1)roh$ as .09 (SE = .30) with a total sample size of 170 for 10 clusters with size 17.

```r
a_new <- 10 # clusters
b_new <- round(b_opt)
n_total <- a_new * b_new

var_opt <- (s2 / n_total) * (1 + (b_new - 1) * roh)

# Standard error
se_opt <- sqrt(var_opt)

tibble(
  n_total, var_opt, se_opt
) |> 
  mutate_all(round,4) |> 
  kable()
```

\newpage

4.  **Consider two equal sized cluster sample designs for a sample from the same, large population:**

-   \(a\) n = 500 elements selected in clusters of size b = 11, and
-   \(b\) n = 300 elements selected in clusters of size b = 6.
-   If roh = 0.1 is expected, which design will have smaller sampling variance of a mean? Explain.
    -   For cluster sampling with equal-sized clusters:

        $$\text{Var}(\bar{y}) = \frac{S^2}{n} \cdot [1 + (b-1)\rho] = \frac{S^2 \cdot \text{deff}}{n}$$

    -   The relative efficiency is: $$RE(A, B) = \frac{\text{Var}_B(\bar{y})}{\text{Var}_A(\bar{y})} = \frac{\text{deff}_B/n_B}{\text{deff}_A/n_A}$$

    -   Design A has smaller variance despite higher deff. The larger sample size compensates for clustering penalty. Design A is 1.25 time more efficient than design B.

```r
# design parameters
n_a <- 500
b_a <- 11
a_a <- ceiling(n_a / b_a)

n_b <- 300
b_b <- 6
a_b <- n_b / b_b

roh <- 0.1

# calculate design effects
deff_a <- 1 + (b_a - 1) * roh
deff_b <- 1 + (b_b - 1) * roh

# variance comparison 
var_ratio_a <- deff_a / n_a
var_ratio_b <- deff_b / n_b

tibble(
  Design = c("A", "B"),
  Design_N = c(n_a, n_b),
  clusters = c(b_a, b_b),
  cluster_size = c(a_a, a_b),
  deff = c(deff_a, deff_b),
  Var = c(var_ratio_a, var_ratio_b)) |> 
  kable()
```

\newpage

5.  **In a population of size N = 1,000,000, what is the largest number of strata that can be created so that a stratified random sample of size n = 800 is measurable? Explain your answer.**
    -   For measurability, the ability to estimate variance, each stratum needs $n_h \geq 2$ - Variance within stratum: $s^2_h = \frac{\sum(y_{hi} - \bar{y}_h)^2}{n_h - 1}$ - With $n_h = 1$ there is undefined variance (division by zero).
    -   With n=800, we can have at most 800/2 = 400 strata.

```r
N <- 1000000
n <- 800

min_per_stratum <- 2

# maximum number of strata
H_max <- floor(n / min_per_stratum)

H_max |> tibble() |> kable()
```

\

6.  **TRUE/FALSE. Stratified samples always have a design effect smaller than one. Explain your answer.**
    -   The design effect for stratified sampling:

        $$\text{deff}_{strat} = \frac{\text{Var}_{strat}(\bar{y}_{st})}{\text{Var}_{SRS}(\bar{y})}$$

        -   With proportional allocation: $$\text{deff}_{prop} = \frac{\sum W_h S_h^2}{S^2} \leq 1 \text{ (usually)}$$

    -   **FALSE**. The design effect for stratified sampling depends on the allocation method, with proportional allocation deff \< 1 when strata are homogenous (within stratum variances are small), making stratification beneficial. With disproportional allocation, deff can be \> 1 if allocation is poor (sampling more from high variance stata), which happens with purposive oversampling of certain groups. With poor stratification auxiliary variables, if strata are formed on variables unrelated to the outcome, deff of 1 with no gains or loss.

\

7.  **The following table has the population sizes (**$N_h$**), and sample element variances (**$s^2_h$**) and means (**$\bar{y}_h$**) for each of the 3 strata. These results were estimated from an epsem stratified random sample of size** $n = 40$**:**

```r
# stratified sample data
strata_data <- tibble(
  h = 1:3,
  N_h = c(1000, 600, 400),
  y_bar_h = c(40, 30, 50),
  s2_h = c(36, 64, 100)) |> 
  mutate(
    s_h = sqrt(s2_h),
    W_h = N_h / sum(N_h),
    Stratum = str_c("Stratum ", h)) |> 
  relocate(Stratum) |> 
  select(-h)

N <- strata_data |> reframe(sum(N_h)) |> pull()
n_target <- 100

strata_data |> kable()
```

-   **(a) What would be the expected standard error of the overall mean if this same stratified sample design was repeated with a sample of size n = 100?**

    -   The estimated population stratified mean $\bar{y}_{st} = \sum W_h \times \bar{y}_h = 39$ with variance $var(\bar{y}_{st}) = \sum W^2 \times (S^2_h / n_h) \times (1-f_h) = .54, SE=.73$ with proportionate allocation $n_h = n \times W_h$.

```r
# proportional allocation
strata_prop <- strata_data |> 
  mutate(
    n_h_prop = round(n_target * W_h),
    f_h = n_h_prop / N_h,
    var_contribution = W_h^2 * s2_h / n_h_prop * (1 - f_h)
  ) |>  
  reframe(
    y_bar_st = sum(W_h * y_bar_h),
    var_prop = sum(var_contribution),
    se_prop =  sqrt(var_prop)
  )

strata_prop |> mutate_all(round, 4) |> kable()
```

\

-   **(b) Find the allocation which will minimize the sampling variance of the overall mean for a sample of size n = 100. What would be the design effect under this allocation?**

    -   For Neyman allocation, the optimal allocation $n_h = n \times (N_h \times S_h) / \sum N_i \times S_i$ minimized variance for fixed n=100. Our deff of .52 suggests that the complex design is more effective than the SRS design using Neyman allocation of 41, 32, 27.

```r
# Neyman allocation
strata_neyman <- strata_data |>
  mutate(
    N_h_s_h = N_h * s_h,
    allocation_weight = N_h_s_h / sum(N_h_s_h),
    n_h_opt = round(n_target * allocation_weight),
    f_h_opt = n_h_opt / N_h,
    var_contribution_opt = W_h^2 * s2_h / n_h_opt * (1 - f_h_opt)
  ) 

strata_neyman |> 
  select(Stratum, allocation_weight, n_h_opt) |> 
  rename(Allocation = n_h_opt) |> 
  kable()


neyman_results <- strata_neyman |>  
  reframe(
    y_bar_st = sum(W_h * y_bar_h),
    var_opt = sum(var_contribution_opt),
    se_prop =  sqrt(var_opt),
    # calculate srs variance
    S2_pop = sum(W_h * s2_h) + sum(W_h * (y_bar_h - y_bar_st)^2),
    var_srs = S2_pop / n_target * (1 - n_target/N),
    # calculate deff 
    deff = var_opt / var_srs
  )

neyman_results |> select(deff) |> kable()
```

\

8.  **Give one advantage and one disadvantage of using systematic sampling instead of simple random sampling.**
    -   Systematic sampling is optimally simple as it only needs one random number, yet it has the disadvantage of not having an unbiased variance estimator and potential periodicity issues. Therefore, systematic sampling trades statistical rigor for operational simplicity.

\newpage

9.  **Consider the following population of 58 elements. If we were to select a systematic sample using an interval of k = 10 with a random start between 1 and 10, what is the probability that we would select a sample with 5 elements?**
    -   $N=58, k=10$ possabilities include samples of size 5 starting with random start 9, 10. (2 starts) with a probability $n=5$ is 2/10 = 0.2.

```r
N <- 58
k <- 10

# Calculate sample sizes for each random start
sample_analysis <- tibble(
  random_start = 1:k) |>
  mutate(
    # use the map functions to loop through data
    elements = map(random_start, ~ seq(.x, N, by = k)),
    sample_size = map_int(elements, length),
    first_element = random_start,
    last_element = map_int(elements, ~max(.x))
  )

sample_analysis |>
  #select(-elements) |>
  kable(caption = "Sample Sizes by Random Start") 

# summary
size_distribution <- sample_analysis |>
  count(sample_size, name = "frequency") |>
  mutate(probability = frequency / k)

size_distribution |>
  kable(caption = "Sample Size Distribution") 

cat(str_c("Answer = ", 
          size_distribution |> filter(sample_size==5) |> 
            pull(probability)))

```

\newpage

10. **Suppose that we want to use the fractional interval method to select a systematic sample of size n = 5 from the population in question 9. Given a random start of 2.4, list the elements that would be selected using this technique?**
    -   With fractional interval $k = N/n$: - Selection points: $r, r+k, r+2k, ..., r+(n-1)k$ - Standard convention truncate to get element number shown under "Selected_Element" in the table below.

```r
n <- 5
k <- N / n 
start <- 2.4

# calculate exact selection points
points <- start + (0:(n-1)) * k

# apply floor truncation to get element index
selected_elements <- floor(points)

tibble(
  Point = points,
  Selected_Element = selected_elements) |>
  kable() 
```

\newpage

11. **Give another solution to deal with the fractional sampling interval in problem 10 that maintains the sample epsem and briefly explain how you would implement it.**
    -   **Lahiri's Method** (or Random Interval method). Select integer $k$ as either $\lfloor N/n \rfloor$ or $\lceil N/n \rceil$ with specific probabilities $p$ and $1-p$ such that the overall probability for every element remains $n/N$.

```r
k_min <- floor(N/n)   
k_max <- ceiling(N/n)  

# probabilities for Lahiri's method
prob_k_min <- k_max - N/n
prob_k_max <- N/n - k_min

lahiri_details <- tibble(
  Interval = c(k_min, k_max),
  Prob = c(prob_k_min, prob_k_max),
  N_size = c(ceiling(N/k_min), floor(N/k_max)),
  Selection_Prob = c(paste0("1/", k_min), paste0("1/", k_max)))

lahiri_details |> kable(caption = "Lahiri's Random Systematic Sampling")

# cerify epsem property
prob_element <- prob_k_min/k_min + prob_k_max/k_max

# P(element selected) = 0.4 / 11 + 0.6 / 12  # = 0.0864 = n/N = 5 / 58 = 0.0862

prob_element |> tibble() |> mutate_all(round, 4) |> kable()
```

\newpage

12. **A stratified sample of unequal sized blocks was selected from all blocks in a large city with the goal of estimating the proportion of smokers. The blocks were stratified into** $H=6$ **strata. The weighted number of smokers per block** $u_{h\alpha}$ **and the weighted total number of elements in the block** $w_{h\alpha}$ **are as follows:**

```r
strat_data <- tibble(
  h = rep(1:6, each=2),
  u = c(20, 10, 5, 15, 3, 25, 5, 15, 6, 10, 11, 20), # smokers
  w = c(100, 20, 20, 50, 5, 75, 50, 70, 30, 70, 20, 70) # total
)

strat_data |> tibble() |> kable()
```

-   **(a) Give the estimated proportion of the population in the city that are smokers and its standard error using the Taylor series approximation.**

    -   Variance must be calculated within strata first, then summed. The formula for paired selection ($n_h=2$) is $\sum (z_{h1} - z_{h2})^2$ which gives us a proportion of smokers of .25 with a $SE=.024$.

```r
# overall ratio
r <- sum(strat_data$u) / sum(strat_data$w)

# calculate linearized z at cluster level
strat_data <- strat_data |> mutate(z = u - r * w)

# calculate variance contribution per statrum

stratum_variance <- strat_data |>
  group_by(h) |>
  reframe(
    # difference between the 2 clusters in the stratum
    diff_sq = (z[1] - z)^2)

# sum across strata and normalize
X_total <- sum(strat_data$w)
var_r <- (1 / X_total^2) * sum(stratum_variance$diff_sq)
se_r <- sqrt(var_r)

cat(str_c("Proportion:", round(r, 4)))
cat(str_c("Standard Error ", round(se_r, 4)))
```

\

-   **(b) Is the Taylor series approximation adequate in this case? Why?**

    -   The cv of .61 is \> .30, suggesting that Taylor series might be unstable and perhaps a sampling method like bootstraping is recommended for variance estimation.

```r
# calculate cv
strat_data |> 
  reframe(
    var_w = 1 / n()^2 * sum(w - mean(w)^2), # var calculation
    cv = sd(w) / mean(w) # cv calculation
  ) |> 
  select(cv) |> 
  mutate(cv = round(cv, 3)) |> 
  kable()
```

\

13. **TRUE/FALSE. In a probability sample, all elements of the population must have the same chance of being selected. Explain your answer.**
    -   **FALSE**. Probability sampling requires that every element has a known probability of selection, a non-zero probability ($\pi_i > 0$), and that these probabilities need not be equal.

\

14. **The following table is the list of a population of clusters and their measures of size (MOS).**

```r

clusters_pps <- tibble(
  cluster = seq(1,10),
  MOS = c(50, 65, 20, 30, 85, 80, 65, 35, 10, 65)
) |>
  mutate(
    cumulative_MOS = cumsum(MOS),
    range_start = lag(cumulative_MOS, default = 0) + .001,
    range_end = cumulative_MOS
  )

clusters_pps |> kable()
```

\newpage

-   **(a) Write down the sampling interval, k, and then select a = 2 clusters with PPeS, using a minimum size of 50. If linking is necessary, identify the linked units in the appropriate column. Use systematic selections with a random start of 80.1.**

    -   We select the sampling interval $k = \frac{\sum MOS}{a} = 505/2 = 252.5$ and with a random number of 80.1 we use selection points 80.1 and 332.6. We make an adjustment to the MOS by moving the range start to two decimal places since our sampling interval and selection points have decimal places in them. We select from the list cluster 2 and 7 with $MOS > b^*$ of 50 minimum; therefore, linking is not necessary. However, because cluster 8 and 9 both have an MOS below our set minimum we must link them to our selected cluster 7. Clusters 8 (MOS=35) and 9 (MOS=10) are undersized (\< 50). Following the linking protocol, these undersized clusters are linked backward to the nearest sufficient-sized cluster, which is cluster 7. This creates a linked PSU: 7+8+9 with combined MOS=110.

    -   The linking is done by first selecting the 10 clusters from the overall list. When the next units on the list do not meet the sufficient size (undersized units) required MOS of 50, we move forward in the list until the first unit that meets the minimum requirement is achieved. For all the units that did not meet the requirement they are cumulated backwards until a linked unit of minimum sufficient size is created. We do this process for all the clusters initially selected. Overall we had a total MOS across both clusters of 175.

```r
b_star <- 50 # min cluster size
a <- 2 # how many clusters to select
N <- clusters_pps |> reframe(sum(MOS)) |> pull()
k <- N / a 
k |> tibble() |> kable()
```

```r
RN  <- 80.1 
RN_sample <- seq(RN, N, k)
RN_sample |> tibble() |> kable()
```

-   Below we print the two linked clusters, total MOS, and selection number.

```r
dat_selected <- clusters_pps |>
  add_column(RN_sample |> tibble() |> data.table::transpose()) |>
  # create flag for blocks that are selected
  mutate(selected =
           as.numeric(if_any(starts_with("V"), ~
                               between(.x, range_start,
                                       cumulative_MOS)))) |>
  # drop select population elements
  select(-starts_with("V"))

dat_selected |>
  filter(selected == 1) |>
  mutate(selection = RN_sample,
         Total = sum(MOS)) |>
  select(-selected) |>
  kable()



# _____________ handy functions _________________

# groups blocks into a long string
p <- function(v) {
  Reduce(f=paste, x = v)
 }


n <- a # number of blocks to select
min_MOS <- b_star # minimim MOS in cell needed

# we link the selected blocks
dat_linked <- dat_selected |>
  mutate(
    ID = row_number(),
    # flag if minimum MOS not met
    min_n_req = ifelse(MOS >= min_MOS, 1 , 0),
    # create links and convert to clusters
    linking = lead(min_n_req, default=1),
    # assign clustering
    cluster = cumsum(lag(linking, default=1))
  )

# create a vector with linkage
linkage <- dat_linked |>
  filter(selected == 1) |>
  select(cluster) |>
  mutate(Selection = RN_sample)


# show cluster of blocks selected, total HUs
dat_clustered <- dat_linked |>
  filter(cluster %in% linkage$cluster) |>
  # now we link blocks within clusters
  group_by(cluster) |>
  # start clusters at 1
  mutate(cluster = cur_group_id()) |>
  # start with last id to link backwards
  arrange(desc(ID)) |>
  # sum values and reset when min is achieved
  group_by(blocks =
             cumsumbinning(MOS, min_MOS-1, TRUE) -0) |>
  ungroup() |>
  arrange(ID) |>
  mutate(blocks = abs(blocks - max(blocks)) + 1 )


# create a vector with linkage
block_filter <- dat_clustered |>
  filter(selected==1) |>
  pull(blocks)

# show cluster of blocks selected, total HUs
dat_linked_final <- dat_clustered |>
  filter(blocks %in% block_filter) |>
  select(ID, MOS, blocks) |>
  mutate(ID=as.character(ID)) |>
  group_by(blocks) |>
  reframe(ID= p(ID),
          blocks = cur_group_id(),
          MOS = sum(MOS)) |>
  # add RN values
  mutate(SN = linkage$Selection) |> 
  rename(cluster=blocks)

dat_linked_final|>
  kable()
```

\

-   **(b) Give the probability of selection for the primary selections (i.e., the linked clusters) made in problem (a).**

    -   The primary selection probability is in the below table under f1.

```r

f_h <- dat_linked_final |>
  mutate( # 1st stage sampling rate
    f1 = a * MOS / N,  # PPS selection probability
    f1 = pmin(f1,1) )
    

f_h |> 
  select(cluster:f1) |> 
  mutate_at(.vars = c("f1"), round, 3) |> 
  kable()
```

\

-   **(c) The desired overall probability of selection is f = 0.05. Give the within-cluster selection rate for each cluster selected in (a) that will result in an epsem sample of elements.**

    -   We use the desired probability of .05 and f1 to compute the secondary selection probabilities labeled as f2 in the table below.

```r
f <- .05 # desired prob

f_h <- f_h |>
  mutate( # 1st stage sampling rate
    # 2nd stage sampling rate, to maintain epsem
    f2 = f/f1)
    

f_h |> 
  select(cluster:f2) |> 
  mutate_at(.vars = c("f1", "f2"), round, 3) |> 
  kable()
```

\

-   **(d) After selecting clusters, field staff are sent to selected clusters to count the number of elements that are actually there. Below are counts for all the clusters. (We give all clusters to avoid revealing which were to be selected in (a), even though in practice, only counts for the selected clusters would be available).**

    -   Calculate the expected number of elements to be selected in each of the two (linked) units selected in (a) given these actual counts.

    -   Below we calculated the expected number of elements for each linked cluster. We expect for PSU 1 12 and for PSU 2 13.

        -   Note: Selection probabilities (π1​) are calculated using the original Frame MOS, while the final expected sample size is applied to the Actual Counts found in the field.

```r
# expected sample sizes with actual counts
actual_B <- c(63, 61, 26, 33, 81, 93, 70, 36, 10, 62)

f_h <- tibble(
  PSU = c("2", "7+8+9"),
  MOS_frame = c(65, 110), # frame MOS 
  Actual_count = c(61, 116)# actual field counts
  ) |> 
  mutate(
    # selection probabilities based on frame
    pi_1 = (a * MOS_frame) / sum(clusters_pps$MOS),
    
    # within-cluster rates to achieve epsem
    f2_given_1 = 0.05 / pi_1,
    
    # expected sample sizes
    Expected_n = Actual_count * f2_given_1
  )

f_h |> kable()
```

\

### This exam took me approximetly 12 hours to complete given all of the formulas that I had to manually write through latex. The difficulty I would rate 9/10 with 10 being extremely difficult. 
