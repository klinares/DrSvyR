---
id: "jpsm/complex_sample_data_SURV701/assignments/hw1_surv701_Linares"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Assignment 1 - SURV701"
original: "complex_sample_data_SURV701/assignments/hw1_surv701_Linares.qmd"
pages: 
sha256: "4145555954167bf6a95e2498c2e95012be27ed81951f9d5fce039c4f9a18b188"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:50"
---


```r
#| label: setup
#| include: false


pacman::p_load(knitr, tidyverse)

# Set global options
options(scipen = 999)
```

# Introduction

The next page lists values for an equal probability (self-weighting, or epsem) sample of $n=36$ observations, in addition to formulas for estimating the variances of sample means under avariety of epsem sample designs. Use the sample data set to perform the following calculationsand answer all related questions. This exercise serves to illustrate the design effects that oftenarise due to stratification and cluster sampling in sample selection.

```r
#| include: false

# Load the data
hw1_data <- read_csv(
  "D:/repos/UMD_classes_code/complex_sample_data_SURV701/assignments/hw1data.csv")

# View the structure
hw1_data |> head(10) |> kable()
```

The dataset contains:

-   2 strata (stratum 1 and stratum 2)

-   12 clusters (6 per stratum)

-   3 observations per cluster

-   Total of $n = 36$ observations

-   1\) Assume the sample of $n = 36$ observations is a simple random sample from some population. Estimate the population mean, the standard error of the estimated mean, and a 95% confidence interval for the population mean. (Ignore the $fpc$, stratification, and apparent cluster sampling when computing the standard error.)

-   Under SRS, the sample mean $\bar{y}_{srs}$ is given as:

$$ 
\bar{y}_{srs} = \frac{1}{n}\sum^n_{i=1}y_i 
$$

-   The estimated variance of the sample mean is:

$$
\widehat{\text{var}}(\bar{y}_{srs}) = \frac{s^2}{n}
$$

-   where the sample element variance is:

$$
s^2 = \frac{1}{n-1} \sum_{i=1}^{n} (y_i - \bar{y})^2
$$

-   The 95% confidence interval is constructed as:

$$
\bar{y} \pm t_{1-\alpha/2, n-1} \times se(\bar{y})
$$

```r
n <- 36
qt_value <- .975 # quantile function to use

Q1_results <- hw1_data |> 
  reframe(
    # mean
    y_bar = mean(observation ),
    # s^2
    s_sqrd = (1 / (n() - 1) ) * (sum ( (observation - y_bar)^2)),
    # variance
    Var_y = s_sqrd / n(),
    # standard error
    se = sqrt(Var_y),
    # 95% CI
    lower = y_bar - qt(qt_value, n-1) * se,
    upper = y_bar + qt(qt_value, n-1) * se
    )

Q1_results |> 
  select(y_bar, se, lower, upper) |> 
  kable(
    col.names = c(
      "Population Mean", "Standard Error", "95% Lower Bound", "95% Upper Bound")
    )

```

-   Under the assumption of simple random sampling, the estimated sample mean is 8.19 (SE=.331, \[95% CI: 7.52, 8.86\]).

\newpage

-   2\) Assume that the $n = 36$ observations are selected as a stratified random sample of 18 observations from each of two strata. Assume that the population sizes in each of the two strata are equal (i.e., $W_h = 0.5$ for $h = 1, 2$). Estimate the population mean, the standard error of the estimated mean, and a 95% confidence interval for the population mean. (Ignore the fpc and the cluster sampling in computing the standard error.) What is the estimated $D^2(\bar{y})$ for the estimated mean? How would you describe this design effect in plain English?

-   For stratified random sampling, the estimated population meanis:

$$
\bar{y}_{st} = \sum_{h=1}^{H} W_h \bar{y}_h
$$

-   The estimated variance of the stratified mean (ignoring fpc) is:

$$
\widehat{\text{var}}(\bar{y}_{st}) = \sum_{h=1}^{H} W_h^2 \frac{s_h^2}{n_h}
$$

-   The design effect is defined as the ratio of the variance under the complex design to the variance under SRS:

$$
D^2(\bar{y}) = \frac{\widehat{\text{var}}(\bar{y}_{st})}{\widehat{\text{var}}(\bar{y}_{srs})}
$$

-   Under stratified random sampling with equal startum weights of $W_h=.5$, the estimated population mean is 8.19 (SE=.30, \[95% CI: 7.57, 8.81\]). The design effect of .84 suggests that the complex design has lower variance relative to SRS, meaning that the stratified design provides gains in precision.

```r
W_h <- .5 
H <- 2 # strata


n <- 36
qt_value <- .975 # quantile function to use

# calcualte degrees of freedom
df <- n - H

Q2_results <- hw1_data |> 
  group_by(stratum) |>
  reframe(
    # stratum size
    n_h = n(),
    # sample mean
    y_bar_h = mean(observation), 
    # s^2
    s_h_squared = var(observation),
    # variance
    var_y_h = s_h_squared / n_h
    ) |> 
  reframe(
    # pop mean
    y_bar_st = sum(W_h * y_bar_h),
    # pop variance
    var_y_st = sum(W_h^2 * var_y_h),
    # standard error
    se = sqrt(var_y_st),
    lower = y_bar_st - qt(qt_value, df) * se,
    upper = y_bar_st + qt(qt_value, df) * se,
    # design effect
    deff = var_y_st / Q1_results$Var_y 
    )

Q2_results |> 
  select(y_bar_st, se, lower, upper, deff) |> 
  kable(
    col.names = c(
      "Population Mean", "Standard Error", "95% Lower Bound", 
      "95% Upper Bound", "Design Effect")
    )

```

\newpage

-   3\) Now, assume that the $n = 36$ observations are selected as an equal probability sample of 12 clusters with exactly 3 observations from each cluster. Estimate the population mean, the standard error of the estimated mean, a 95% confidence interval for the population mean, and $D^2(\bar{y})$. (Ignore the fpc and the stratification when computing the standard error.) Use the simple model of the design effect for sample means to derive an estimate of roh, the synthetic intraclass correlation.

-   For cluster sampling with $a$ clusters and $b$ observations per cluster, the cluster mean is:

$$
\bar{y}_\alpha = \frac{1}{b} \sum_{i=1}^{b} y_{\alpha i}
$$

-   The overall mean is given by:

$$
\bar{y}_{cl} = \frac{1}{a} \sum_{\alpha=1}^{a} \bar{y}_\alpha
$$

-   The estimated variance of the cluster sample mean is:

$$
\widehat{\text{var}}(\bar{y}_{cl}) = \frac{\sum_{\alpha=1}^{a} (\bar{y}_\alpha - \bar{y}_{cl})^2}{a(a-1)}
$$

-   The simple model for the design effect relates to the intraclass correlation $\rho$ (roh):

$$
D^2(\bar{y}) \approx 1 + (b - 1)\rho
$$

-   Solving for $\rho$:

$$
\rho = \frac{D^2(\bar{y}) - 1}{b - 1}
$$

```r
a <- 12  # number of clusters
b <- 3   # observations per cluster
n <- a * b
df <- a - 1 


# Step 2: Calculate Cluster Sampling results
Q3_results <- hw1_data |>
  
  # calculate mean of each cluster
  group_by(cluster) |>
  reframe(y_bar_alpha = mean(observation)) |>
  
  # sum to the population
  reframe(
    y_bar_cl = mean(y_bar_alpha),  # pop mean
    s_a_sq   = var(y_bar_alpha),   # cluster between variance
    var_y_cl = s_a_sq / a,         # population variance
    se    = sqrt(var_y_cl)         # se
  ) |>
  mutate(
    # design effect ratio of clusters
    deff = var_y_cl / Q1_results$Var_y, # SRS variance
    # compute roh
    roh = (deff - 1) / (b - 1),
    # 95% CI using a-1 df
    lower = y_bar_cl - qt(0.975, df) * se,
    upper = y_bar_cl + qt(0.975, df) * se
  )
  
Q3_results |> 
  select(y_bar_cl, se, lower, upper, deff, roh) |> 
  kable(
    col.names = c(
      "Population Mean", "Standard Error", "95% Lower Bound", 
      "95% Upper Bound", "Design Effect", "Roh")
    )
```

-   Under a cluster sampling design with 12 clusters of size 3 each, the estimated population mean is 8.19 (SE = .424 \[95% CI: 7.26, 9.13\]). The design effect of 1.64 indicates that the complex design result in higher variance, or lower precision, relative to SRS, suggesting that the cluster design is less efficient. A roh value of .32 represents the degree of homogeneity within clusters, and when roh \> 0, it indicates that observations within clusters tend to be more similar to each other than observations between clusters. When roh \< 0 , it indicates small within cluster homogeneity. Are value suggests that in this sample observations within clusters are more similar than between clusters.

\newpage

-   4\) Assume that the $n = 36$ observations are selected as an equal probability, stratified cluster sample of observations (2 strata, 6 clusters per stratum, 3 observations per cluster). Estimate the population mean, the standard error of the estimated mean, a 95% confidence interval for the population mean, and $D^2(\bar{y})$. Compare and contrast the design effects from problems 2) through 4), and comment about what the results mean for the relative efficiency of the alternative sample designs.

## Formulas

-   For stratified cluster sampling, let $y_{h\alpha}$, the total sum of of observations in cluster $\alpha$ in stratum $h$:

$$
\bar{y}_h = \frac{1}{a_h b_h} \sum_{\alpha=1}^{a_h} y_{h\alpha}
$$

-   The overall mean of stratum $h$:

$$
\bar{y}_h = \sum_{\alpha=1}^{a_h} y_{h\alpha}
$$

-   The estimated variance of the stratified cluster sample mean is:

$$
\widehat{\text{var}}(\bar{y}_{st,cl}) = \sum_{h=1}^{H} W_h^2 \cdot \frac{1}{a_h(a_h-1)b_h^2} \left[ \sum_{\alpha=1}^{a_h} y_{h\alpha}^2 - \frac{(\sum_{\alpha=1}^{a_h} y_{h\alpha})^2}{a_h} \right]
$$

-   This simplifies to computing the variance of cluster means within each stratum:

$$
\widehat{\text{var}}(\bar{y}_{st,cl}) = \sum_{h=1}^{H} W_h^2 \cdot \frac{\sum_{\alpha=1}^{a_h}(\bar{y}_{h\alpha} - \bar{y}_h)^2}{a_h(a_h - 1)}
$$

-   where $\bar{y}_{h\alpha}$ is the mean of cluster $\alpha$ in stratum $h$, $\bar{y}_h$ is the mean of all observations in stratum $h$, $\alpha_h$ is the number of clusters in stratum $h$, and $b_h$ is the number of observations per cluster.

\newpage

```r
# Design parameters
h <- 2
a_h <- 6  # clusters per stratum
b_h <- 3  # observations per cluster
W_h <- 0.5  # stratum weight
n_total <- 36 
W_h <- 0.5    # weight per stratum 
df <- (a_h - 1) * h # df = sum(a_h - 1) = 5 + 5 = 10

# stratified cluster Calculations
Q4_results <- hw1_data |>
  # calculate means for each individual cluster
  group_by(stratum, cluster) |>
  reframe(y_bar_h_alpha = mean(observation)) |>
  
  # calculate variance between cluster means within each stratum
  group_by(stratum) |>
  summarize(
    y_bar_h = mean(y_bar_h_alpha),
    s_h_cl_sq = var(y_bar_h_alpha) # this is sum(y_ha - y_h)^2 / (a_h - 1)
  ) |>
  
  # aggregate strata using weights
  summarize(
    overall_mean = sum(W_h * y_bar_h),
    # var = sum( W_h^2 * (s_h_cl_sq / a_h) )
    var_st_cl = sum((W_h^2 * s_h_cl_sq) / a_h),
    se = sqrt(var_st_cl)
  ) |>
  
  # deff & 95% CI
  mutate(
    deff = var_st_cl / Q1_results$Var_y, # SRS variance
    lower = overall_mean - qt(0.975, df) * se,
    upper = overall_mean + qt(0.975, df) * se
  )

Q4_results |> 
  select(overall_mean, se, lower, upper, deff) |> 
  kable(col.names = c(
      "Population Mean", "Standard Error", "95% Lower Bound", 
      "95% Upper Bound", "Design Effect"))
```

## 

```r
comparison <- tibble(
  Design = c("Stratified Random","Cluster Sample", "Stratified Cluster"),
  Deff = c(Q2_results |> pull(deff),
           Q3_results |> pull(deff),
           Q4_results |> pull(deff)
           ),
  'Relative Frequency' = c(
    "Most Efficient, smaller variance",
    "Least Efficient, high variance",
    "Compromise, moderate variance"
  )
)

comparison |> kable()
```

-   The stratification SRS improves precision by removing between-strata variation from the error term while at the same time ensuring the sample is balanced across subgroups, and thus more stable than just SRS. Conversely, clustering reduces precision because observations within a cluster tend to be more similar. This homogeneity creates "redundancy," meaning n=36 clustered observations provide less unique information than 36 independent ones. Stratified clustering appears to act as a middle ground where the precision gains of stratification partially offset the losses of clustering. However, this design is less efficient than SRS, but significantly more precise than simple clustering. Ultimately, stratified cluster sampling seems to balance the logistical cost-savings of clustering with the statistical rigor provided by stratification.

\newpage

## Appendix: Bonus, using the survey package to confirm answers.

```r

library(survey)

#| label: survey-designs

# Q1: SRS
srs_design <- svydesign(ids = ~1, data = hw1_data)

# Q2: Stratified (ignoring clusters)
strat_design <- svydesign(ids = ~1, strata = ~stratum, data = hw1_data)

# Q3: Cluster (ignoring strata)
cluster_design <- svydesign(ids = ~cluster, data = hw1_data)

# Q4: Stratified Cluster
strat_cl_design <- svydesign(ids = ~cluster, strata = ~stratum, data = hw1_data)
```

```r
#| label: results-comparison

# Extract results
get_results <- function(design, label) {
  m <- svymean(~observation, design)
  tibble(Design = label, Mean = coef(m), SE = SE(m))
}

bind_rows(
  get_results(srs_design, "1. SRS"),
  get_results(strat_design, "2. Stratified"),
  get_results(cluster_design, "3. Cluster"),
  get_results(strat_cl_design, "4. Strat-Cluster")
) |> kable(digits = 4)
```

```r
#| label: design-effects

# Design effects (compare to SRS variance)
var_srs <- vcov(svymean(~observation, srs_design))[1,1]

tibble(
  Design = c("2. Stratified", "3. Cluster", "4. Strat-Cluster"),
  Deff = c(
    vcov(svymean(~observation, strat_design))[1,1] / var_srs,
    vcov(svymean(~observation, cluster_design))[1,1] / var_srs,
    vcov(svymean(~observation, strat_cl_design))[1,1] / var_srs
  )
) |> kable(digits = 4)
```

**Note:** Results should match manual calculations. Minor differences may occur due to df conventions and default weighting.
