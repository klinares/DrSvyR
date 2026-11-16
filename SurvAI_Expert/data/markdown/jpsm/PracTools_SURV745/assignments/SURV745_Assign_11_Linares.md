---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_11_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 11"
original: "PracTools_SURV745/assignments/SURV745_Assign_11_Linares.qmd"
pages: 
sha256: "7999a25baaad9fac7444d34c6c3d12009943b31cb8c275c6efac2ab74d536cb1"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:12"
---


```r
pacman::p_load(tidyverse, knitr, kableExtra, PracTools, survey)
options(scipen = 999)
set.seed(-530049348)
```

### Exercise 14.1. Use the `smho.N874` dataset from the PracTools package to complete this exercise on poststratification. Select a simple random sample of size $n = 80$ without replacement. Set the random number seed to $-530049348$.

```r
# load dataset from practools
data(smho.N874)

# labels for the 5 hospital types (VDK p. 386)
hosp_labels <- c("Psychiatric", "Residential/Veterans",
                 "General", "Outpatient/Partial",
                 "Multiservice/Substance")

pop <- smho.N874 |>
  tibble() |> 
  # change labels
  mutate(hosp.lab = factor(hosp.type, labels = hosp_labels))

N <- nrow(pop)
n <- 80
```

```r
#| echo: false

cat("population size N =", N, "\n")
cat("sample size n =", n, "\n")
```

\newpage

#### (a) What are the means of expenditures in the five hospital types in the population? What should you look for in order for poststratification to be worth considering?

-   We compute the population mean of `EXPTOTAL` (i.e., total expenditures in 1998) within each of the five hospital types. The hospital types in `smho.N874` are: 1 = psychiatric, 2 = residential/veterans, 3 = general, 4 = outpatient/partial care, and 5 = multiservice/substance abuse (VDK p. 386).

```r
# population means by hospital type
pop_means <- pop |>
  group_by(hosp.lab) |>
  reframe(
    # pop count for poststrat gamma
    N_gamma = n(),
    mean_exp = mean(EXPTOTAL))

```

```r
#| echo: false

pop_means |>
  mutate(mean_exp = scales::comma(round(mean_exp))) |>
  kable(col.names = c("Hospital Type", "$N$", "Mean Expenditures"),
        escape = FALSE,
        align = c("l", "r", "r"))
```

-   For poststratification to be worth considering, we need the poststratum means to differ across groups. If the means of the outcome variable expenditures are about the same across all hospital types, then poststratification would provide little variance reduction. The key criterion is that the auxiliary variable hospital type should be a good predictor of the analysis variable, meaning that the between-group variation in expenditures is large relative to the within-group variation. In the table above, we can see that the mean expenditures do vary across hospital types, suggesting that poststratification has potential to improve precision.

\newpage

#### (b) Compute the population counts of facilities by hospital type, treating the `smho.N874` dataset as the full population. Compute the unweighted sample counts by hospital type to verify that each type is represented in the sample. If one of the hospital types was not represented in the sample, what would be the practical and theoretical implications? Discuss this in the context of design-based and model-based inference.

```r
# population counts by hospital type
pop_counts <- pop |>
  count(hosp.lab, name = "N_gamma")


# sample 80 observations from N
sam_idx <- sample(1:N, n)
samdat <- pop[sam_idx, ]

# unweighted sample counts by hospital type
sam_counts <- samdat |>
  count(hosp.lab, name = "n_gamma")

```

-   We can compare the sample composition to the population to see how well the srswor happened to represent each hospital type:

```r
#| echo: false


# side-by-side: population vs sample proportions
pop_counts |>
  left_join(sam_counts, by = "hosp.lab") |>
  mutate(pop_pct = round(N_gamma / sum(N_gamma), 3),
         sam_pct = round(n_gamma / sum(n_gamma), 3)) |>
  kable(col.names = c("Hospital Type", "$N$", "$n$",
                       "Pop. Proportion", "Sample Proportion"),
        escape = FALSE,
        caption = "Population vs. sample composition by hospital type")
```

-   All five hospital types are represented in the sample, which is a necessary condition for poststratification to work. Any discrepancies between the population and sample proportions will be corrected by the poststratification adjustment.

    -   If one hospital type were not represented in the sample, there would be both practical and theoretical problems. From a design-based perspective, the poststratified estimator $\hat{T}_{yPS} = \sum_{\gamma=1}^{G} N_\gamma (\hat{t}_{y\gamma} / \hat{N}_\gamma)$ (VDK p. 374) would be undefined for the missing poststratum because $\hat{N}_\gamma = 0$ makes the ratio $\hat{t}_{y\gamma}/\hat{N}_\gamma$ indeterminate. In practice, the weight adjustment factor $g_i = N_\gamma / \hat{N}_\gamma$ (VDK eq. 14.4) cannot be computed for that group. Poststrata would need to be collapsed to avoid this.

    -   From a model-based perspective, the poststratification model assumes $E_M(y_i) = \beta_\gamma$ with separate means in each poststratum (VDK eq. 14.5). If a poststratum has no sample cases, the model parameter $\beta_\gamma$ for that group cannot be estimated from the data. This is a more fundamental problem than the design-based one since we have no information from which to predict the analysis variable for units in that poststratum.

\newpage

#### (c) Calculate the set of poststratified weights for the sample using hospital type as the poststratification variable. What do the weights sum to before and after poststratification? Is this what you expect?

-   Using VDK Example 14.2, we create an SRSWOR design object with base weights $d_i = N/n$ and FPC specified as the sampling fraction $f = n/N$. We then use `postStratify()` from the `survey` package with hospital type as the poststratification variable.

```r
# base weights & FPC
d <- rep(N / n, n)
f <- rep(n / N, n)

# SRSWOR design object
srs_dsgn <- svydesign(ids = ~0,
                       strata = NULL,
                       fpc = ~f, # FPC
                       data = samdat,
                       weights = ~d) # d-weights

# population totals for poststrata
N_PS <- pop |>
  count(hosp.type, name = "Freq")

N_PS |> kable()

# poststratify
ps_dsgn <- postStratify(design = srs_dsgn,
                         strata = ~hosp.type,
                         population = N_PS)

# sum of weights before and after poststratification
sum_before <- sum(weights(srs_dsgn))
sum_after <- sum(weights(ps_dsgn))

```

```r
#| echo: false

cat("sum of base weights (before PS):", sum_before, "\n")
cat("sum of PS weights (after PS):   ", sum_after, "\n")


# compare weight distributions before and after PS
cat("base weight ", mean(weights(srs_dsgn)) )

cat("\nPS weight summary:\n")
summary(weights(ps_dsgn))


```

-   prior to poststratifying, the base weights sum to $N = `r N`$ because each of the $n = 80$ sampled units receives a weight of $N/n = `r N/n`$. After poststratification, the weights should also sum to $N = `r N`$ because the poststratified weights redistribute the total weight so that the weighted count in each poststratum matches the known population count $N_\gamma$. This is expected and the total weighted sample size equals the population size under both weighting schemes, but the distribution across poststrata changes.

\newpage

#### (d) Verify that the calibration controls are met by the set of poststratified weights.

-   The calibration in poststratification requires that the sum of the poststratified weights within each poststratum equals the known population count: $\sum_{i \in s_\gamma} w_i = N_\gamma$ for each $\gamma$. This follows directly from the weight definition $w_i = d_i N_\gamma / \hat{N}_\gamma$ in VDK Eq. 14.4, since $\sum_{i \in s_\gamma} w_i = (N_\gamma / \hat{N}_\gamma) \sum_{i \in s_\gamma} d_i = (N_\gamma / \hat{N}_\gamma) \hat{N}_\gamma = N_\gamma$. We verify this empirically by estimating the total of the hospital type indicator with `svytotal()`. The SEs should be exactly zero, since the weighted counts are forced to match the population controls (VDK p. 377).

```r
# verify calibration: weighted counts should equal population counts
svytotal(~as.factor(hosp.type), ps_dsgn)
```

-   The estimated totals match the population counts $N_\gamma$ exactly, and all standard errors are zero. This confirms that the poststratified weights satisfy the calibration constraints.

\newpage

#### (e) Estimate the population total of expenditures and its standard error for the expansion estimator under the srswor design and for the poststratified estimator. Be sure and incorporate a finite population correction factor into the variance estimates. Discuss any similarities or differences in the estimated totals and SEs.

-   The expansion (Horvitz-Thompson) estimator under srswor is $\hat{t}_0 = N \bar{y}_s$ (VDK Table 14.4). Its design-based variance includes the fpc $(1 - n/N)$ (VDK Eq. 3.1 applied to the total), which was incorporated when we specified `fpc = ~f` in the design object. The poststratified estimator is $\hat{T}_{yPS} = \sum_{\gamma=1}^{G} N_\gamma (\hat{t}_{y\gamma}/\hat{N}_\gamma)$ (VDK p. 374).

```r
# expansion estimator under srswor
srs_est <- svytotal(~EXPTOTAL, srs_dsgn)

# poststratified estimator
ps_est <- svytotal(~EXPTOTAL, ps_dsgn)

# compile results
results <- tibble(
  estimator = c("Expansion (srswor)", "Poststratified"),
  total = c(coef(srs_est), coef(ps_est)),
  se = c(SE(srs_est), SE(ps_est)),
  cv = c(cv(srs_est), cv(ps_est)))

```

```r
#| echo: false


results |>
  mutate(total = scales::comma(round(total)),
         se = scales::comma(round(se)),
         cv = round(cv, 4)) |>
  kable(col.names = c("Estimator", "Estimated Total", "SE", "CV"),
        align = c("l", "r", "r", "r"),
        caption = "Estimated total of expenditures with fpc")

# for reference: actual population total
pop_total <- sum(pop$EXPTOTAL)
cat("true population total:", scales::comma(pop_total), "\n")
```

-   Both estimators incorporate the finite population correction factor $(1 - n/N)$ in the variance estimates, as required. The two estimates differ by about $820$ million dollars. In this particular sample, Type 1 (psychiatric, the highest-mean hospital type at about \$21M) was oversampled ($0.288$ vs. a population proportion of $0.246$), while Type 3 (general, the lowest-mean type at about \$5M) was undersampled ($0.250$ vs. $0.288$). The expansion estimator does not correct for this imbalance, so it pulls the total upward. Poststratification adjusts the weights to match the known population counts, which pulls the estimate back down toward the true population total of about \$9.7 billion. Both $\pm 2 \cdot SE$ intervals contain the true total, but the PS point estimate is closer. The poststratified SE is expected to be smaller than, or at most equal to, the srswor SE when hospital type is a good predictor of expenditures. This is because poststratification removes the component of variability due to the random allocation of the sample across hospital types (similar to VDK examples 14.2). The PS SE is about $18\%$ smaller than the srswor SE here, and the CV drops from $0.19$ to $0.17$, confirming that hospital type is a useful auxiliary variable in this context.
