---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_4_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "SURV 745 - Assignment 4"
original: "PracTools_SURV745/assignments/SURV745_Assign_4_Linares.qmd"
pages: 
sha256: "1906ee34a8fd0f35884cf27041e096710d865a0b23720e9dc61782feb22c7777"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:08"
---


```r
#| label: setup
#| echo: false

pacman::p_load(nloptr, knitr, tidyverse)

options(scipen = 999, digits = 5)
```

#### Optimal Allocation for a Stratified Sample of Employees

-   A company has $N = 750$ employees across three strata: Managers ($N_1 = 100$), Technical ($N_2 = 500$), and Clerical ($N_3 = 150$). We are to select a stratified random sample of $n = 120$ employees. The objective is to minimize the average relvariance of the estimated population proportions for two variables:

    -   \(1\) looked for a new job

    -   \(2\) took all vacation earned, subject to constraints on total sample size, stratum-level CVs for "looked for job," and overall CVs for "applied for credit" and "own home."

-   The relvariance of the estimated total of a proportion under stratified SRS is (VDK eq 5.3):

$$
\operatorname{relvar}(\hat{t}_P) = \frac{1}{t_P^2}
  \sum_{h=1}^{H} N_h \left(\frac{N_h}{n_h} - 1\right) S_h^2,
  \quad S_h^2 = \frac{P_h(1 - P_h)\, N_h}{N_h - 1}
$$

-   The constraints from HW4_Solver_allocation are:

    -   Total sample size: $\sum_h n_h \leq 120$

    -   Minimum per stratum: $n_h \geq 20$ for all $h$

    -   Stratum-level precision on "looked for job": $CV(\hat{P}_{job,h}) \leq 0.25$ for each $h$

    -   Overall precision on "applied for credit": $CV(\hat{t}_{credit}) \leq 0.10$

    -   Overall precision on "own home": $CV(\hat{t}_{home}) \leq 0.10$

    -   Upper bound: $n_h \leq N_h$

```r
#| label: data

# build the table with NH and proportions for variables
strata <- tibble(
  job_type = c("Managers", "Technical", "Clerical"),
  Nh       = c(100, 500, 150),
  P_job    = c(0.20, 0.95, 0.40),
  P_vac    = c(0.40, 0.70, 0.90),
  P_credit = c(0.80, 0.20, 1.00),
  P_home   = c(0.70, 0.50, 0.10)
) |>
  mutate(
    # compute s^2_h with formula above
    across(starts_with("P_"),
           function(p) p * (1 - p) * Nh / (Nh - 1),
           .names = "S2_{str_remove(.col, 'P_')}")
  )

# survey variables metadata include name, S2, P column, pop total
variables <- tibble(
  var_name = c("New Job", "Vacation", "Debt", "Own Home"),
  S2_col   = c("S2_job", "S2_vac", "S2_credit", "S2_home"),
  P_col    = c("P_job", "P_vac", "P_credit", "P_home")
) |>
  mutate(
    # loop through strata df for each s^2 column
    S2 = map(S2_col, function(col) strata[[col]]),
    # loop through strata df to compute a proportional allocation 
    tU = map_dbl(P_col, function(col) sum(strata$Nh * strata[[col]]))
  )

# constraints 
n_total  <- 120
n_min    <- 20
cv_strat <- 0.25   # max CV for stratum-level job estimates
cv_pop   <- 0.10   # max CV for population-level debt & home estimates

# print proportions table
strata |>
  select(job_type, Nh, starts_with("P_")) |>
  kable()
```

\newpage

-   **Helper functions.** The variance component for stratum $h$ is $V_h = N_h(N_h / n_h - 1) S_h^2$, and the relvariance is $\sum V_h / t_U^2$, (equations from VDK on p. 163) .

```r
# variance component per stratum, Nh * (Nh/nh - 1) * S2
var_component <- function(nh, Nh, S2) {
  Nh * (Nh / nh - 1) * S2
}

# relvar(t_hat) = sum(var_components) / tU^2
relvar <- function(nh, Nh, S2, tU) {
  sum(var_component(nh, Nh, S2)) / tU^2
}

# gradient, d/d(nh) relvar = -Nh^2 * S2 / (nh^2 * tU^2)
grad_relvar <- function(nh, Nh, S2, tU) {
  -Nh^2 * S2 / (nh^2 * tU^2)
}
```

-   **Optimization via SLSQP**

```r

# objective, average relvar of job + vacation
obj_vars <- variables |> filter(var_name %in% c("New Job", "Vacation"))

eval_f <- function(nh) {
  obj_vars |>
    mutate(rv = map2_dbl(S2, tU, function(s, t) relvar(nh, strata$Nh, s, t))) |>
    summarise(mean(rv)) |>
    pull()
}

eval_grad_f <- function(nh) {
  obj_vars |>
    mutate(gr = map2(S2, tU, function(s, t) grad_relvar(nh, strata$Nh, s, t))) |>
    pull(gr) |>
    reduce(`+`) / nrow(obj_vars)
}

# CV constraints, stratum-level for job, population-level for debt & home
eval_g_ineq <- function(nh) {
  # stratum-level: (1/nh - 1/Nh) * S2_job / P_job^2 <= cv_strat^2
  cv_strat_vals <- (1/nh - 1/strata$Nh) * strata$S2_job / strata$P_job^2

  # population-level: relvar <= cv_pop^2 for debt and home
  pop_vars <- variables |> filter(var_name %in% c("Debt", "Own Home"))
  cv_pop_vals <- map2_dbl(pop_vars$S2, pop_vars$tU,
                          function(s, t) relvar(nh, strata$Nh, s, t))

  c(sum(nh) - n_total,
    cv_strat_vals - cv_strat^2,
    cv_pop_vals - cv_pop^2)
}

eval_jac_g_ineq <- function(nh) {
  # stratum CV jacobian: diagonal since each constraint depends on one nh
  strat_jac <- diag(-strata$S2_job / (nh^2 * strata$P_job^2))

  # population CV jacobian: each constraint depends on all nh
  pop_vars <- variables |> filter(var_name %in% c("Debt", "Own Home"))
  pop_jac  <- map2(pop_vars$S2, pop_vars$tU,
                   function(s, t) grad_relvar(nh, strata$Nh, s, t)) |>
    do.call(rbind, args = _)

  rbind(rep(1, 3), strat_jac, pop_jac)
}
```

-   After optimizing with constraints we can solve.

```r

# multi-start SLSQP via reusable wrapper 
# box constraints enforce (ii) nh >= 20 and (vi) nh <= Nh
solve_slsqp <- function(eval_f, eval_grad_f,
                         eval_g_ineq, eval_jac_g_ineq,
                         lb, ub,
                         restarts = 200, seed = 745) {
  set.seed(seed)
  
  map(seq_len(restarts), function(i) {
    x0 <- runif(length(lb), min = lb, max = ub)
    nloptr(x0 = x0, eval_f = eval_f, eval_grad_f = eval_grad_f,
           eval_g_ineq = eval_g_ineq, eval_jac_g_ineq = eval_jac_g_ineq,
           lb = lb, ub = ub,
           opts = list(algorithm = "NLOPT_LD_SLSQP",
                       xtol_rel = 1e-14, maxeval = 100000, print_level = 0))
  }) |>
    keep(function(res) is.finite(res$objective)) |>
    reduce(function(a, b) if (a$objective <= b$objective) a else b)
}
```

-    With only 3 strata and $n = 120$, we can enumerate all feasible integer allocations to find the exact optimum without relying on rounding heuristics.

```r
# we conduct an integer search
grid_results <- crossing(
  n1 = n_min:strata$Nh[1],
  n3 = n_min:strata$Nh[3]
) |>
  mutate(n2 = n_total - n1 - n3) |>
  filter(n2 >= n_min, n2 <= strata$Nh[2]) |>
  # stratum-level CV(job) <= cv_strat for each h
  mutate(
    cv_job_1 = sqrt((1/n1 - 1/strata$Nh[1]) * strata$S2_job[1]) / strata$P_job[1],
    cv_job_2 = sqrt((1/n2 - 1/strata$Nh[2]) * strata$S2_job[2]) / strata$P_job[2],
    cv_job_3 = sqrt((1/n3 - 1/strata$Nh[3]) * strata$S2_job[3]) / strata$P_job[3]
  ) |>
  filter(cv_job_1 <= cv_strat + 1e-8,
         cv_job_2 <= cv_strat + 1e-8,
         cv_job_3 <= cv_strat + 1e-8) |>
  # overall CV constraints
  rowwise() |>
  mutate(
    nh      = list(c(n1, n2, n3)),
    cv_cred = sqrt(relvar(nh, strata$Nh, strata$S2_credit,
                          variables$tU[variables$var_name == "Debt"])),
    cv_home = sqrt(relvar(nh, strata$Nh, strata$S2_home,
                          variables$tU[variables$var_name == "Own Home"])),
    obj     = eval_f(nh)
  ) |>
  ungroup() |>
  filter(cv_cred <= cv_pop + 1e-8,
         cv_home <= cv_pop + 1e-8)

nh_final <- grid_results |>
  slice_min(obj, n = 1) |>
  pull(nh) |>
  pluck(1)
```

-   This replicates the Excel Solver spreadsheet layout. Each variable gets a variance component column $V_h = N_h(N_h/n_h - 1)S_h^2$, followed by stratum-level CVs for the job variable. The summary rows show population totals ($t_U$), relvars, and CVs.

```r
# allocation table
# compute variance components for all 4 variables (one column per variable)
alloc_table <- strata |>
  mutate(nh = nh_final) |>
  mutate(
    across(starts_with("S2_"),
           function(s2) var_component(nh, Nh, s2),
           .names = "V_{str_remove(.col, 'S2_')}")
  ) |>
  mutate(
    CV_job_strat = sqrt((1/nh - 1/Nh) * S2_job) / P_job
  )

# totals row
totals_row <- alloc_table |>
  summarise(
    job_type = "Total", Nh = sum(Nh),
    across(starts_with("P_"), function(p) sum(strata$Nh * p) / sum(strata$Nh)),
    nh = sum(nh),
    across(starts_with("V_"), sum),
    CV_job_strat = NA_real_
  )

# main table display
bind_rows(alloc_table, totals_row) |>
  select(job_type, nh:CV_job_strat) |>
  kable()
```

```r
# summary statistics, tU, RELVAR, CV for each variable — driven by the variables tibble
summary_stats <- variables |>
  mutate(
    V_total = map_dbl(S2, function(s) sum(var_component(nh_final, strata$Nh, s))),
    RELVAR  = map2_dbl(S2, tU, function(s, t) relvar(nh_final, strata$Nh, s, t)),
    CV      = sqrt(RELVAR)
  )

summary_stats |>
  select(var_name, tU, RELVAR, CV) |>
  kable()
```

```r
# objective value
obj_val <- eval_f(nh_final)
```

-   **Objective (avg relvar):** `r sprintf("%.7f", obj_val)`
-   **Constraint checks.** These match the TRUE/FALSE block in the Excel spreadsheet.

```r

cv_strat_vals <- sqrt((1/nh_final - 1/strata$Nh) * strata$S2_job) / strata$P_job
cv_debt <- summary_stats |> filter(var_name == "Debt") |> pull(CV)
cv_home <- summary_stats |> filter(var_name == "Own Home") |> pull(CV)

tibble(
  Constraint = c(
    sprintf("(i)   Total sample size \u2264 %d", n_total),
    sprintf("(ii)  Min per job \u2265 %d", n_min),
    sprintf("(iii) CV stratum (new job) \u2264 %.2f", cv_strat),
    sprintf("(iv)  CV overall (debt) \u2264 %.2f", cv_pop),
    sprintf("(v)   CV overall (own home) \u2264 %.2f", cv_pop),
    "(vi)  nh \u2264 Nh"
  ),
  Status = c(
    sum(nh_final) <= n_total,
    all(nh_final >= n_min),
    all(cv_strat_vals <= cv_strat + 1e-8),
    cv_debt <= cv_pop + 1e-8,
    cv_home <= cv_pop + 1e-8,
    all(nh_final <= strata$Nh)
  )
) |> 
  kable()
```

\newpage

#### 6.2 The following table on the next page contains an excerpt from a complete list of disposition codes developed for an RDD survey. Classify the following codes into the seven disposition code categories shown in Table 6.2. If you are unable to assign the disposition code to a single category with the description provided below, what additional information would need to be specified for you to choose among the categories?

| Symbol in study rates | Category                     | Study eligibility |
|-----------------------|------------------------------|-------------------|
| I                     | Complete interview           | Eligible          |
| P                     | Partially complete interview | Eligible          |
| R                     | Refusal/break-off            | Eligible          |
| NC                    | Noncontact                   | Eligible          |
| U                     | Unknown study eligibility    | Unknown           |
| NE                    | Not eligible                 | Ineligible        |
| O                     | Other                        | Eligible          |

: Table 6.2: Disposition code categories used in performance rate calculation

```r

ex6_2 <- tibble(
  Code = seq(1, 15),
  Description = c(
    "Completed interview",
    "Partially completed interview",
    "Callback scheduled",
    "Dataphone/fax number",
    "Hospitalized",
    "Language barrier",
    "Refusal",
    "Not available during data collection",
    "Soft refusal\u2014callback to be assigned",
    "Ring/no answer",
    "Deployed member of U.S. military",
    "No eligible respondent in HH",
    "Hard/hostile refusal",
    "Callback\u2014eligible respondent not available, no interview",
    "Other"
  ),
  # apply hand coding. 
  AAPOR = c("I", "P", "NC", "NE", "O", "O", "R",
             "NC", "R", "U", "O", "NE", "R", "NC", "O"),
  Ambiguous = c("No", "No", "Yes", "No", "Yes", "No", "Yes",
                "Yes", "No", "No", "Yes", "No", "No", "No", "No")
)

```

\newpage

```r
#| echo: false
ex6_2 |> kable()
```

-   **Codes with unambiguous assignments:**

    -   *Code 1.* Respondent completed all appropriate questions.

    -   *Code 2.* Sufficient data collected but interview not completed.

    -   *Code 4.* Number reached a fax machine or data line, not a HH.

    -   *Code 6.* HH contacted, respondent eligible due to language.

    -   *Code 9.* Despite the "soft" refusal, respondent declined participation.

    -   *Code 10.* No contact was made, so eligibility could not be determined. The number could be a residence, nonworking, or business.

    -   *Code 12.* HH screened; no member meets eligibility criteria.

    -   *Code 13.* Explicit refusal.

    -   *Code 14.* Eligible respondent identified but never reached for interview.

    -   *Code 15.* Catch-all code.

-   **Codes requiring additional information, ambiguity:**

    -   *Code 3.* Assigned NC because contact was made but interview was incompleted. Was eligibility established during the initial call? If only a gatekeeper was reached and no screening occurred, U could be appropriate.

    -   *Code 5.* The respondent is eligible but temporarily unable to participate. Does the target population exclude institutionalized persons? If so, this would be NE.

    -   *Code 7.* Assigned R per AAPOR convention, which treats refusals from contacted numbers as eligible. Did the refusal occur before or after the eligibility screener? If before screening, the case could be argued as U since eligibility was never verified.

    -   *Code 8.* The respondent was identified but unreachable during the field period. Was any HH contact made? If no contact occurred and eligibility was only inferred from an external source, NC is appropriate. If the household was contacted and the respondent was identified but unavailable, O could apply instead.

    -   *Code 11.* Respondent identified but unavailable. Are deployed military members in the target population? If excluded, than NE.
