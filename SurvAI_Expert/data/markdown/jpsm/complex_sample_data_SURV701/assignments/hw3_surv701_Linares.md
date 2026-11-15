---
id: "jpsm/complex_sample_data_SURV701/assignments/hw3_surv701_Linares"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Assignment 3"
original: "complex_sample_data_SURV701/assignments/hw3_surv701_Linares.qmd"
pages: 
sha256: "b6f88a8d90537daacb2026f83c8b0b1f1c199a22c896534d76f643230d78dea4"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:48"
---


```r
#| include: false

pacman::p_load(knitr, survey, tidyverse)

# Set global options
options(scipen = 999, digits = 5)

data_path <- "d:/repos/UMD_classes_code/complex_sample_data_SURV701/assignments/"
```

## (1) (5 pts) For the release of the public use microdata file following the 2012 Commercial Buildings Energy Consumption Survey (CBECS), the administration team at the Energy Information Administration included replicate weights for the first time. Do a little detective work searching the Web for whatever documentation you can find to answer questions a – c.

Source: U.S. Energy Information Administration. (2016, August). [*User's Guide to the 2012 CBECS Public Use Microdata File* (Revised August 2016). U.S. Department of Energy](https://www.eia.gov/consumption/commercial/data/2012/pdf/user_guide_public_use_aug2016.pdf), [microdata](https://www.eia.gov/consumption/commercial/data/2012/index.php?view=microdata)

a.  \[What\] Was the replication procedure used to create the replicate weights JRR, BRR, or the bootstrap (pick just one)?

    -   The 2012 CBECS uses JRR for variance estimation. The User's Guide states: "CBECS uses the jackknife method for estimating standard errors. This method uses replicate weights to repeatedly estimate the statistic of interest and calculate the differences between these estimates and the full-sample estimate" (User's Guide, p. 1).

b.  How many replicate weights were produced, and how were they named?

-   There were 197 sets of replicate weights that are named FINALW1 through FINALWT197 found in the user's manual (p.3). The SAS examples reference these weights as `FINALWT1-FINALWT197` in `PROC SURVEYMEANS` and `PROC SURVEYFREQ` procedures with `varmethod=jackknife` and `jkcoefs=1` (User's Guide, p. 5-6).

c.  What is the name of the full-sample weight (i.e., the one that would be used to formulate point estimates)?

    -   The full-sample weight is named FINALWT. In the User's Guide, the full sample weight in the data file represents the final sampling weight, accounting for different probabilities of selection and rates of participation in the survey. The variance formula using the replicate weights is:

$$
\hat{V}(\hat{\theta}) = \sum_{r=1}^{R} \alpha_r (\hat{\theta}_r - \hat{\theta})^2
$$

-   where $R = 197$ and $\alpha_r = 1$ for all replicates.

\newpage

## (2) (5 pts) Suppose an individual logged the weight of each grocery bag he purchased over the course of a one-year period by writing its weight on a piece of paper and dropping into a fishbowl. At the end of the year, five pieces of paper were sampled from the fishbowl, which had weights of 10.2, 7.5, 6.8, 8.1, and 9.4 pounds, respectively. - Find the estimated variance of the sample mean weight in two ways without using survey software: (1) the traditional “textbook” formula, ; and (2) JRR. Show your calculations.

$$
\hat{V}(\bar{y}) = \frac{\sum_{i=1}^n(y_i - \bar{y}^2) }{n-1} \frac{1}{n}
$$

```r
# grocery bag weights
n <- 5
bags <- c(10.2, 7.5, 6.8, 8.1, 9.4)
y_bar <- mean(bags)
```

-   Method (a): Textbook formula

```r
var_srs <- (sum((bags - y_bar)^2) / (n - 1)) * 
  (1/n) # from formula

se_srs <- sqrt(var_srs)

tibble(
  y_bar = y_bar,
  var_y_bar = var_srs,
  se_y_bar = se_srs
  ) |> 
  kable()
```

-   Method (b): JRR Delete 1
    -   For a simple random sample, the JRR variance estimator uses $n$ replicates, each formed by deleting one observation and computing the mean of the remaining $n-1$ observations. Recall that we do not have stratum or cluster codes available so the equation simplifies from $(a_h-1)$ to $n-1$.

$$
\hat{V}_{JRR}(\bar{y}) = \frac{n-1}{n} \sum_{k=1}^{n} (\bar{y}_{(k)} - \bar{y})^2
$$

```r
# compute each jackknife replicate mean
jrr_means <- map_dbl(
  # for each element
  1:n, 
  # compute mean whle deleing 1
  ~mean(bags[-.]))

jrr_results <- tibble(
  # bags
  Replicate = 1:n,
  # deleted 1 obs at a time
  deleted = bags,
  # means from jrr_means
  replicate_mean = jrr_means,
  difference_mean = (jrr_means - y_bar)^2
)

jrr_results |> kable()
```

```r
var_jrr <- ((n - 1) / n) * sum((jrr_means - y_bar)^2)
se_jrr <- sqrt(var_jrr)
```

```r
#| echo: false
cat("Textbook variance:", var_srs, "\n")
cat("JRR variance:     ", var_jrr, "\n")
cat("Difference:       ", abs(var_srs - var_jrr), "\n\n")
cat("Both methods yield identical variance estimates of", var_srs,
    "(se =", round(se_srs, 4), "),\n",
    "confirming that the delete-one jackknife is algebraically equivalent\n",
    "to the textbook SRS variance estimator.")
```

\newpage

#### Sanity check with survey::svymean()

```r
# wrap the bag data in a simple SRS design
bag_data <- tibble(wt = bags)
srs_design <- svydesign(ids = ~1, data = bag_data)

# convert to JK1 jackknife unstratified
jk_design <- as.svrepdesign(srs_design, type = "JK1")

# verify mean and SE match manual calculation
svy_est <- svymean(~wt, jk_design)

SE(svy_est)^2  #  get the variance
```

\newpage

## (3) (5 pts) The estimated total of income $y_{ha}$ and number of households $x_{ha}$ in each enumeration area in a stratified cluster sample are presented as follows (i.e., the analysis weights are already factored into the two totals):

-   Using the first 4 rows and the first 4 columns of the following 8×8 Hadamard matrix, with rows representing the replicates and columns representing strata, estimate the variance of the mean income of households using the BRR procedure. Construct a 95% confidence interval for the mean.

```r
# generate data from Q3
strat_data <- tibble(
  stratum = rep(1:4, each = 2),
  psu = rep(1:2, times = 4),
  # income totals
  y = c(1500, 800, 270, 720, 500, 480, 450, 280), 
  # household counts
  x = c(30, 20, 27, 24, 25, 30, 30, 14)            
)

# use 1st 4 rows and cols from the hadamard matrix
# rows = replicates, cols = strata
H <- matrix(c(
  +1, +1, +1, -1,
  -1, +1, +1, +1,
  -1, -1, +1, +1,
  +1, -1, -1, +1), 
  nrow = 4, byrow = TRUE)

```

```r
#| echo: false
strat_data |> kable()

cat("Hadamard matrix (4x4):\n")
print(H)
cat("\n")
```

-   First we compute the mean income of households as a ratio estimator (total income divided by total household module 4 slide 16):

$$
\hat{R} = \frac{\sum^n_{i=1} y_{ha}}{\sum^n_{i=1}x_{ha}}
$$

```r
summary_table <- strat_data |> 
  reframe(y_total = sum(y),
          x_total = sum(x),
          r_hat = y_total / x_total
          )
```

```r
#| echo: false
cat("Full-sample estimate: r_hat =", 
    summary_table$r_hat, "\n")
cat("Total income:", 
    summary_table$y_total, "| Total households:", 
    summary_table$x_total, "\n\n")

R_hat <- summary_table |> pull(r_hat)
```

-   We use module 5 slides 19-23 to construct BRR replicate r by selecting for each estimate a PSU indicated by the Hadamard matrix, we then double the weights by a factor of 2 for paired selection design, and compute the ratio estimate.

```r
# loop through each to create a vector of BRR replicate estimates
brr_estimates <- map_dbl(1:nrow(H), function(r) {
  
  # which PSU is selected in each stratum for this replicate
  selected <- tibble(
    stratum = 1:4,
    # subset from matrix
    keep_psu = if_else(H[r, ] == 1, 1, 2)
  )
  
  strat_data |>
    # psu's already selected
    inner_join(selected, by = c("stratum", "psu" = "keep_psu")) |>
    summarise(q_hat = sum(y) / sum(x)) |>
    pull(q_hat)
})
```

```r
#| echo: false

cat("BRR replicate estimates:\n")
tibble(Replicate = 1:4, q_hat_r = brr_estimates) |> 
  kable()
cat("\n")

```

-   Now that we have the q_hat_r estimates, using slide 24 we can compute the variance as:

$$
var_{BRR}(\hat{q}) = \frac{1}{R}\sum^R_{r=1}(\hat{q}_r - \hat{q})^2
$$

```r
# where R = number of replicates, H = 4
R_reps <- length(brr_estimates)
var_brr <- (1 / R_reps) * sum((brr_estimates - R_hat)^2)
se_brr <- sqrt(var_brr)

```

```r
#| echo: false
cat("BRR variance estimation:\n")
cat("  var_BRR =", var_brr, "\n")
cat("  se_BRR  =", round(se_brr, 4), "\n\n")

```

-   Now that we have $var_{BRR}$ we can compute the SE and 95% CI using a critical t value given the degrees of freedom = 4.

```r

# 95% CI estimates
# df = H = 4 for BRR number of half-sample replicates
df_brr <- R_reps
t_crit <- qt(0.975, df = df_brr)
ci_lower <- R_hat - t_crit * se_brr
ci_upper <- R_hat + t_crit * se_brr

```

```r
#| echo: false


cat("95% CI (df =", df_brr, ", t =", round(t_crit, 4), "):\n")
cat("  (", round(ci_lower, 4), ",", round(ci_upper, 4), ")\n\n")

```

\newpage

## (4) (5 pts) For the two variables analyzed in Question 2 part e of Homework Assignment 2, estimate the standard error using JRR in the software of your choice. Is there much of a difference relative to the TSL estimated standard error?

```r
ess_data <- haven::read_dta(
  str_c(data_path, "chapter_exercises_ess6rf.dta")) |>
  rename_with(toupper)

# TSL design, from HW2
design_tsl <- svydesign(
  ids = ~PSU, strata = ~STRATIFY, weights = ~PSPWGHT,
  data = ess_data, nest = TRUE
)


# JRR, stratified delete-one jackknife 
design_jrr <- as.svrepdesign(design_tsl, type = "JKn")
```

```r
# put it together
map_dfr(c("STFLIFE", "TRSTPLC"), function(v) {
  fml <- as.formula(str_c("~", v))
  tsl <- svymean(fml, design_tsl, na.rm = TRUE)
  jrr <- svymean(fml, design_jrr, na.rm = TRUE)
  tibble(
    Variable = v, 
    Mean = coef(tsl),
    se_tsl = as.numeric(SE(tsl)),
    se_jrr = as.numeric(SE(jrr)),
    ratio  = as.numeric(SE(jrr) / SE(tsl)))
  }) |>
  mutate(across(where(is.numeric), ~ round(.x, 5))) |> kable() 

```

-   The JRR SE for STFLIFE and TRSTPLC are near identical to those obtained via TSL, with SE ratios of approximately 1.003 and 1.002. Both methods are asymptotically equivalent for smooth statistics like means under stratified multistage designs. The minor difference we detect is due to TSL relying on a first order Taylor approximation to linearize the estimator, and JRR seems to use a fully nonparametric resampling approach making no assumption about the smoothness.
