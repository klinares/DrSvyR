---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_4_Linares_expanded"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "SURV 745 - Assignment 4"
original: "PracTools_SURV745/assignments/SURV745_Assign_4_Linares_expanded.qmd"
pages: 
sha256: "94b34afa7f849ff1c3c8fcb42c05027aeb13c12aeda15c4553d493a045b77acb"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:12"
---


```r

# the nloptr package is what replicates the excel solver
pacman::p_load(nloptr, knitr, scales, tidyverse)

options(scipen = 999, digits = 5)
```

```r
# ─── Statistical Building Blocks (VDK Ch. 5) ──────────────────────
# These three functions implement the core relvariance formulas for
# stratified SRS (stsr-swor). They are reused for every problem in
# this document. All three take S_h^2 (variance), never S_h.
#
# For continuous variables:  pass S_h^2 directly
# For proportions:           pass S_h^2 = P_h(1 - P_h) * N_h/(N_h-1)

# Variance component for stratum h
#   V_h = N_h * (N_h / n_h  -  1) * S_h^2
# This is the contribution of stratum h to the total variance.
var_component <- function(nh, Nh, S2) {
  Nh * (Nh / nh - 1) * S2
}

# Relative variance of an estimated population total
#   relvar(t_hat) = sum(V_h) / t_U^2
#                 = (1 / t_U^2) * sum[ N_h * (N_h/n_h - 1) * S_h^2 ]
# where t_U = sum(N_h * ybar_h) is the true population total.
relvar <- function(nh, Nh, S2, tU) {
  sum(var_component(nh, Nh, S2)) / tU^2
}

# Gradient of relvar with respect to n_h
#   d/d(n_h) relvar = -N_h^2 * S_h^2 / (n_h^2 * t_U^2)
# Needed by SLSQP for efficient convergence. Returns a vector of
# length H (one partial derivative per stratum).
grad_relvar <- function(nh, Nh, S2, tU) {
  -Nh^2 * S2 / (nh^2 * tU^2)
}

# ─── Multi-Start SLSQP Solver ─────────────────────────────────────
# SLSQP (Sequential Least Squares Quadratic Programming) is the
# open-source analogue of Excel Solver's GRG Nonlinear engine.
# Both are gradient-based, local optimizers — they find the nearest
# minimum from the starting point, which may not be the global one.
#
# To guard against local minima, we run the solver from many random
# starting points and keep the best result.
#
# Arguments:
#   eval_f / eval_grad_f    — objective and its gradient
#   eval_g_ineq / eval_jac  — constraints g(x) <= 0 and jacobian
#   lb / ub                 — box constraints (e.g. n_h >= 20)
#   restarts                — number of random starting points
solve_slsqp <- function(eval_f, eval_grad_f,
                         eval_g_ineq, eval_jac,
                         lb, ub,
                         restarts = 200, seed = 745) {
  set.seed(seed)
  best <- list(objective = Inf)

  for (i in seq_len(restarts)) {
    x0  <- runif(length(lb), min = lb, max = ub)
    res <- nloptr(
      x0 = x0,
      eval_f = eval_f, eval_grad_f = eval_grad_f,
      eval_g_ineq = eval_g_ineq, eval_jac_g_ineq = eval_jac,
      lb = lb, ub = ub,
      opts = list(algorithm   = "NLOPT_LD_SLSQP",
                  xtol_rel    = 1e-14,
                  maxeval     = 100000,
                  print_level = 0)
    )
    if (res$objective < best$objective) best <- res
  }
  best
}
```

#### 5.X Optimal Allocation for a Stratified Sample of Employees

-   A company has $N = 750$ employees across three strata: Managers ($N_1 = 100$), Technical ($N_2 = 500$), and Clerical ($N_3 = 150$). A stratified random sample of $n = 120$ employees is to be selected. The objective is to minimize the average relvariance of the estimated population proportions for two variables: (1) looked for a new job and (2) took all vacation earned, subject to constraints on total sample size, stratum-level CVs for "looked for job," and overall CVs for "applied for credit" and "own home."

-   The relvariance of the estimated total of a proportion under stratified SRS is:

$$
\operatorname{relvar}(\hat{t}_P) = \frac{1}{t_P^2}
  \sum_{h=1}^{H} N_h \left(\frac{N_h}{n_h} - 1\right) S_h^2,
  \quad S_h^2 = \frac{P_h(1 - P_h)\, N_h}{N_h - 1}
$$

-   The constraints are:

    -   

        (i) Total sample size: $\sum_h n_h \leq 120$

    -   

        (ii) Minimum per stratum: $n_h \geq 20$ for all $h$

    -   

        (iii) Stratum-level precision: $CV(\hat{P}_{job,h}) \leq 0.25$ for each $h$

    -   

        (iv) Overall precision on credit: $CV(\hat{t}_{credit}) \leq 0.10$

    -   

        (v) Overall precision on home: $CV(\hat{t}_{home}) \leq 0.10$

    -   

        (vi) Upper bound: $n_h \leq N_h$

**Step 1: Enter the stratum data.** Each row is one stratum. The `across()` call computes $S_h^2 = P_h(1-P_h)N_h/(N_h-1)$ for every proportion column at once.

```r
#| label: hw-data

strata <- tibble(
  job_type = c("Managers", "Technical", "Clerical"),
  Nh       = c(100, 500, 150),
  P_job    = c(0.20, 0.95, 0.40),
  P_vac    = c(0.40, 0.70, 0.90),
  P_credit = c(0.80, 0.20, 1.00),
  P_home   = c(0.70, 0.50, 0.10)
) |>
  mutate(
    across(starts_with("P_"),
           function(p) p * (1 - p) * Nh / (Nh - 1),
           .names = "S2_{str_remove(.col, 'P_')}")
  )

strata |>
  select(job_type, Nh, starts_with("P_")) |>
  kable(caption = "Stratum Parameters (Proportions)",
        col.names = c("Job Type", "Nh", "New Job", "Vacation",
                      "Credit Debt", "Own Home"))
```

**Step 2: Organize the survey variables.** We store each variable's $S_h^2$ vector and population total $t_U = \sum N_h P_h$ in one tibble. This avoids repeating `sum(strata$Nh * strata$P_xxx)` everywhere and makes it easy to loop over variables later.

```r
#| label: hw-variables

variables <- tibble(
  var_name = c("New Job", "Vacation", "Debt", "Own Home"),
  S2_col   = c("S2_job", "S2_vac", "S2_credit", "S2_home"),
  P_col    = c("P_job", "P_vac", "P_credit", "P_home")
) |>
  mutate(
    S2 = map(S2_col, function(col) strata[[col]]),
    tU = map_dbl(P_col, function(col) sum(strata$Nh * strata[[col]]))
  )
```

**Step 3: State the problem parameters.** Every constraint limit lives here — not buried inside a function body.

```r
#| label: hw-parameters

n_total  <- 120    # (i)   max total sample size
n_min    <- 20     # (ii)  min sample per stratum
cv_strat <- 0.25   # (iii) max CV for stratum-level job estimates
cv_pop   <- 0.10   # (iv-v) max CV for pop-level debt & home estimates
```

**Step 4: Formulate for `nloptr`.** The optimizer needs four functions. The comments map each piece back to the constraints (i)–(vi) listed above.

```r
#| label: hw-formulation

# ─── Objective ─────────────────────────────────────────────────────
# Minimize: (1/2) * [ relvar(t_job) + relvar(t_vac) ]
# i.e., the average relvariance of the two target proportions.
obj_vars <- variables |> filter(var_name %in% c("New Job", "Vacation"))

eval_f_hw <- function(nh) {
  obj_vars |>
    mutate(rv = map2_dbl(S2, tU,
                         function(s, t) relvar(nh, strata$Nh, s, t))) |>
    summarise(mean(rv)) |>
    pull()
}

# ─── Gradient of objective ─────────────────────────────────────────
# d/d(n_h) of the average = (1/K) * sum[ d/d(n_h) relvar_k ]
eval_grad_f_hw <- function(nh) {
  obj_vars |>
    mutate(gr = map2(S2, tU,
                     function(s, t) grad_relvar(nh, strata$Nh, s, t))) |>
    pull(gr) |>
    reduce(`+`) / nrow(obj_vars)
}

# ─── Inequality constraints: g(x) <= 0 ────────────────────────────
# nloptr expects ALL inequality constraints stacked in one vector.
# Box constraints (ii) and (vi) are handled by lb/ub instead.
#
# g_1:  sum(n_h) - 120              <= 0     ... (i)  total sample
# g_2:  relvar_strat(job,1) - 0.25² <= 0     ... (iii) CV stratum 1
# g_3:  relvar_strat(job,2) - 0.25² <= 0     ... (iii) CV stratum 2
# g_4:  relvar_strat(job,3) - 0.25² <= 0     ... (iii) CV stratum 3
# g_5:  relvar(debt) - 0.10²        <= 0     ... (iv)  CV pop debt
# g_6:  relvar(home) - 0.10²        <= 0     ... (v)   CV pop home
pop_vars <- variables |> filter(var_name %in% c("Debt", "Own Home"))

eval_g_hw <- function(nh) {
  # (iii) stratum-level: Var(P_hat_h) / P_h^2 <= cv_strat^2
  #   which simplifies to: (1/n_h - 1/N_h) * S2_job_h / P_job_h^2
  strat_cv2 <- (1/nh - 1/strata$Nh) * strata$S2_job / strata$P_job^2

  # (iv-v) population-level: relvar(t_hat) <= cv_pop^2
  pop_cv2 <- map2_dbl(pop_vars$S2, pop_vars$tU,
                      function(s, t) relvar(nh, strata$Nh, s, t))

  c(sum(nh) - n_total,            # (i)
    strat_cv2 - cv_strat^2,       # (iii) one per stratum
    pop_cv2 - cv_pop^2)           # (iv-v)
}

# ─── Jacobian of constraints ──────────────────────────────────────
# Each row = d(g_k)/d(n_h) for one constraint.
# Row 1:   d(sum n_h)/d(n_h) = [1, 1, 1]                  (linear)
# Rows 2-4: stratum CVs — diagonal (g_h depends only on n_h)
# Rows 5-6: population CVs — dense (each depends on all n_h)
eval_jac_hw <- function(nh) {
  strat_jac <- diag(-strata$S2_job / (nh^2 * strata$P_job^2))

  pop_jac <- map2(pop_vars$S2, pop_vars$tU,
                  function(s, t) grad_relvar(nh, strata$Nh, s, t)) |>
    do.call(rbind, args = _)

  rbind(rep(1, 3),     # (i)   total sample
        strat_jac,      # (iii) stratum CVs
        pop_jac)        # (iv-v) pop CVs
}
```

**Step 5: Solve.** The box constraints handle (ii) $n_h \geq 20$ and (vi) $n_h \leq N_h$.

```r
#| label: hw-solve

nh_cont <- solve_slsqp(
  eval_f_hw, eval_grad_f_hw, eval_g_hw, eval_jac_hw,
  lb = rep(n_min, 3),     # (ii)  n_h >= 20
  ub = strata$Nh           # (vi)  n_h <= N_h
)$solution
```

-   The continuous optimum is $\mathbf{n} = (`r paste(sprintf("%.2f", nh_cont), collapse = ", ")`)$.

**Exhaustive integer search.** With only 3 strata and $n = 120$, we can enumerate all feasible integer allocations to find the exact optimum without relying on rounding heuristics.

```r
#| label: hw-integer-search

grid_results <- crossing(
  n1 = n_min:strata$Nh[1],
  n3 = n_min:strata$Nh[3]
) |>
  mutate(n2 = n_total - n1 - n3) |>
  filter(n2 >= n_min, n2 <= strata$Nh[2]) |>
  # (iii) stratum-level CV(job) <= cv_strat
  mutate(
    cv_job_1 = sqrt((1/n1 - 1/strata$Nh[1]) * strata$S2_job[1]) / strata$P_job[1],
    cv_job_2 = sqrt((1/n2 - 1/strata$Nh[2]) * strata$S2_job[2]) / strata$P_job[2],
    cv_job_3 = sqrt((1/n3 - 1/strata$Nh[3]) * strata$S2_job[3]) / strata$P_job[3]
  ) |>
  filter(cv_job_1 <= cv_strat + 1e-8,
         cv_job_2 <= cv_strat + 1e-8,
         cv_job_3 <= cv_strat + 1e-8) |>
  # (iv-v) population-level CV constraints
  rowwise() |>
  mutate(
    nh      = list(c(n1, n2, n3)),
    cv_debt = sqrt(relvar(nh, strata$Nh, strata$S2_credit,
                          variables$tU[variables$var_name == "Debt"])),
    cv_home = sqrt(relvar(nh, strata$Nh, strata$S2_home,
                          variables$tU[variables$var_name == "Own Home"])),
    obj     = eval_f_hw(nh)
  ) |>
  ungroup() |>
  filter(cv_debt <= cv_pop + 1e-8,
         cv_home <= cv_pop + 1e-8)

nh_final <- grid_results |>
  slice_min(obj, n = 1) |>
  pull(nh) |>
  pluck(1)
```

-   The integer-optimal allocation is $\mathbf{n} = (`r paste(nh_final, collapse = ", ")`)$ with a total of $n = `r sum(nh_final)`$.

**Step 6: Full allocation table.** This replicates the Excel Solver spreadsheet. Each variable gets a variance component column $V_h = N_h(N_h/n_h - 1)S_h^2$, followed by stratum-level CVs for the job variable. The summary rows show $t_U$, relvars, and CVs.

```r
#| label: hw-allocation-table

# variance components via across() — one V_ column per S2_ column
alloc_table <- strata |>
  mutate(nh = nh_final) |>
  mutate(
    across(starts_with("S2_"),
           function(s2) var_component(nh, Nh, s2),
           .names = "V_{str_remove(.col, 'S2_')}")
  ) |>
  mutate(CV_job_strat = sqrt((1/nh - 1/Nh) * S2_job) / P_job)

# totals row
totals_row <- alloc_table |>
  summarise(
    job_type = "Total", Nh = sum(Nh),
    across(starts_with("P_"), function(p) sum(strata$Nh * p) / sum(strata$Nh)),
    nh = sum(nh),
    across(starts_with("V_"), sum),
    CV_job_strat = NA_real_
  )

bind_rows(alloc_table, totals_row) |>
  select(job_type, Nh, starts_with("P_"), nh,
         V_job, V_vac, V_credit, V_home, CV_job_strat) |>
  kable(caption = "Solver Allocation Table",
        col.names = c("Job Type", "Nh", "P(job)", "P(vac)", "P(debt)",
                      "P(home)", "nh", "V: Job", "V: Vacation",
                      "V: Debt", "V: Home", "CV stratum (job)"),
        digits = c(0, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 4))
```

```r
#| label: hw-summary

# summary statistics driven by the variables tibble
summary_stats <- variables |>
  mutate(
    V_total = map_dbl(S2, function(s) sum(var_component(nh_final, strata$Nh, s))),
    RELVAR  = map2_dbl(S2, tU, function(s, t) relvar(nh_final, strata$Nh, s, t)),
    CV      = sqrt(RELVAR)
  )

summary_stats |>
  select(var_name, tU, RELVAR, CV) |>
  kable(caption = "Population Totals, Relvars, and CVs",
        col.names = c("Variable", "tU", "RELVAR", "CV(pop estimate)"),
        digits = c(0, 0, 10, 7))
```

-   **Objective (avg relvar):** `r sprintf("%.7f", eval_f_hw(nh_final))`

**Constraint checks.** TRUE/FALSE matching the Excel Solver layout.

```r
#| label: hw-checks

cv_strat_vals <- sqrt((1/nh_final - 1/strata$Nh) * strata$S2_job) / strata$P_job
cv_debt_val   <- summary_stats |> filter(var_name == "Debt") |> pull(CV)
cv_home_val   <- summary_stats |> filter(var_name == "Own Home") |> pull(CV)

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
    cv_debt_val <= cv_pop + 1e-8,
    cv_home_val <= cv_pop + 1e-8,
    all(nh_final <= strata$Nh)
  )
) |> kable(caption = "Constraint Checks")
```

\newpage

#### 6.2 Classify the following RDD disposition codes into the seven AAPOR categories from Table 6.2: I (complete interview), P (partial interview), R (refusal/break-off), NC (noncontact), U (unknown eligibility), NE (not eligible), O (other). If unable to assign a code to a single category, specify what additional information is needed.

```r
#| label: ex6-2-classification

ex6_2 <- tibble(
  Code = 1:15,
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
  AAPOR = c("I", "P", "NC", "NE", "O", "O", "R",
             "NC", "R", "U", "O", "NE", "R", "NC", "O"),
  Ambiguous = c("No", "No", "Yes", "No", "Yes", "No", "Yes",
                "Yes", "No", "No", "Yes", "No", "No", "No", "No")
)

ex6_2 |> kable(caption = "AAPOR Classification of RDD Disposition Codes")
```

-   **Codes with unambiguous assignments:**

    -   *Code 1 — Completed interview → I.* Respondent completed all appropriate questions.

    -   *Code 2 — Partially completed interview → P.* Sufficient data collected but interview not finished.

    -   *Code 4 — Dataphone/fax number → NE.* Number reached a fax machine or data line, not a household. Clearly ineligible.

    -   *Code 6 — Language barrier → O.* Household contacted, respondent presumably eligible but unable to complete due to language. Consistent with ATUS concordance in Table 6.3 (codes 21, 121).

    -   *Code 9 — Soft refusal → R.* Despite the "soft" qualifier, the respondent declined participation. Consistent with AAPOR treatment of all refusal types.

    -   *Code 10 — Ring/no answer → U.* No contact was made, so eligibility could not be determined. The number could be a residence, nonworking, or business.

    -   *Code 12 — No eligible respondent in HH → NE.* Household screened; no member meets eligibility criteria.

    -   *Code 13 — Hard/hostile refusal → R.* Explicit refusal.

    -   *Code 14 — Callback, eligible respondent not available → NC.* Eligible respondent identified but never reached for the interview.

    -   *Code 15 — Other → O.* Catch-all by definition.

-   **Codes requiring additional information:**

    -   *Code 3 — Callback scheduled → NC (tentative).* Assigned NC because contact was made but the interview was not completed. **Need to know:** Was eligibility established during the initial call? If only a gatekeeper was reached and no screening occurred, U could be more appropriate.

    -   *Code 5 — Hospitalized → O (tentative).* The respondent is eligible but temporarily unable to participate. **Need to know:** Does the target population exclude institutionalized persons? If so, this would be NE rather than O.

    -   *Code 7 — Refusal → R (tentative).* Assigned R per AAPOR convention, which treats refusals from contacted numbers as eligible. **Need to know:** Did the refusal occur before or after the eligibility screener? If before screening (e.g., immediate hang-up), the case could be argued as U since eligibility was never verified.

    -   *Code 8 — Not available during data collection → NC (tentative).* The respondent was identified but could not be reached during the field period. **Need to know:** Was any household contact ever made? If no contact occurred and eligibility was only inferred from an external source, NC is appropriate. If the household was contacted and the respondent was identified but simply unavailable, O could apply instead.

    -   *Code 11 — Deployed member of U.S. military → O (tentative).* Respondent identified but deployed and unavailable. **Need to know:** Are deployed military members in the target population? If excluded, NE. Also: was the deployed person contacted directly, or was the information obtained secondhand from a household member? If the latter and no direct contact was made, NC could apply.

\newpage

## Appendix A: VDK Example 5.2 — Replicating Excel Solver's GRG Nonlinear in R

-   This appendix solves a harder version of the same type of problem. The `relvar()`, `grad_relvar()`, `var_component()`, and `solve_slsqp()` functions defined above are reused — demonstrating that the same building blocks handle both problems.

-   **What's different from 5.X:**

    -   5 strata instead of 3 (exhaustive integer search is no longer feasible)
    -   A linear budget constraint ($\sum c_h n_h \leq 300{,}000$) instead of a sample size constraint
    -   A mix of continuous variables (revenue, employees) and proportions (credit, offshore)

-   **Problem.** An artificial population of $N = 50{,}568$ business establishments is stratified into 5 sectors (Table 5.1 in VDK). Find an stsr-swor allocation $\mathbf{n} = (n_1, \ldots, n_5)$ that **minimizes the relvariance of estimated total revenue** subject to:

    (i) Budget: $\sum_h c_h n_h \leq 300{,}000$
    (ii) $CV(\hat{t}_{emp}) \leq 0.05$
    (iii) $n_h \geq 100$ for all $h$
    (iv) $n_h \leq N_h$ for all $h$
    (v) $CV(\hat{t}_{credit}) \leq 0.03$
    (vi) $CV(\hat{t}_{offshore}) \leq 0.03$

**Step 1: Enter the stratum data.**

```r
#| label: ex52-data

ex52 <- tibble(
  h          = 1:5,
  sector     = c("Manufacturing", "Retail", "Wholesale", "Service", "Finance"),
  Nh         = c(6221, 11738, 4333, 22809, 5467),
  ch         = c(120, 80, 80, 90, 150),
  ybar_rev   = c(85, 11, 23, 17, 126),
  ybar_emp   = c(511, 21, 70, 32, 157),
  S_rev      = c(2*85, 0.8*11, 1*23, 1.5*17, 2.5*126),
  S_emp      = c(0.5*511, 0.25*21, 0.5*70, 1*32, 3*157),
  P_credit   = c(0.80, 0.20, 0.50, 0.30, 0.90),
  P_offshore = c(0.06, 0.03, 0.03, 0.21, 0.77)
) |>
  mutate(
    # S2 for continuous: just S^2
    S2_rev = S_rev^2,
    S2_emp = S_emp^2,
    # S2 for proportions: P(1-P)*Nh/(Nh-1)
    across(c(P_credit, P_offshore),
           function(p) p * (1 - p) * Nh / (Nh - 1),
           .names = "S2_{str_remove(.col, 'P_')}")
  )

ex52 |>
  select(h, sector, Nh, ch, S_rev, S_emp, P_credit, P_offshore) |>
  kable(caption = "VDK Table 5.1: Stratum Parameters",
        format.args = list(big.mark = ","))
```

**Step 2: Organize the survey variables.**

```r
#| label: ex52-variables

variables_52 <- tibble(
  var_name = c("Revenue", "Employees", "Credit", "Offshore"),
  S2_col   = c("S2_rev", "S2_emp", "S2_credit", "S2_offshore")
) |>
  mutate(
    S2 = map(S2_col, function(col) ex52[[col]]),
    tU = c(sum(ex52$Nh * ex52$ybar_rev),
           sum(ex52$Nh * ex52$ybar_emp),
           sum(ex52$Nh * ex52$P_credit),
           sum(ex52$Nh * ex52$P_offshore))
  )
```

**Step 3: State the problem parameters.** The CV constraints are stored as a tibble — one row per constraint. Adding a new CV constraint = adding one row; you never touch the optimizer functions.

```r
#| label: ex52-parameters

budget   <- 300000   # (i)   max budget
n_min_52 <- 100      # (iii) min per stratum

# (ii, v, vi) CV constraints as data
cv_constraints <- tibble(
  name   = c("employees", "credit", "offshore"),
  S2     = list(ex52$S2_emp, ex52$S2_credit, ex52$S2_offshore),
  tU     = c(variables_52$tU[2], variables_52$tU[3], variables_52$tU[4]),
  cv_max = c(0.05, 0.03, 0.03)
)
```

**Step 4: Formulate for `nloptr`.** Same pattern as 5.X, but with a budget constraint instead of a sample size constraint, and the CV constraints built from the tibble via `map2`.

```r
#| label: ex52-formulation

# ─── Objective: minimize relvar(t_hat_rev) ─────────────────────────
obj_S2 <- ex52$S2_rev
obj_tU <- variables_52$tU[1]

eval_f_52      <- function(nh) relvar(nh, ex52$Nh, obj_S2, obj_tU)
eval_grad_f_52 <- function(nh) grad_relvar(nh, ex52$Nh, obj_S2, obj_tU)

# ─── Inequality constraints: g(x) <= 0 ────────────────────────────
# g_1:   sum(c_h * n_h) - budget        <= 0    ... (i)
# g_2+:  relvar_k - cv_max_k^2          <= 0    ... (ii), (v), (vi)
# Box constraints (iii) and (iv) handled by lb/ub.
eval_g_52 <- function(nh) {
  cv_vals <- map2_dbl(cv_constraints$S2, cv_constraints$tU,
                      function(s, t) relvar(nh, ex52$Nh, s, t))
  c(sum(ex52$ch * nh) - budget,       # (i)  budget
    cv_vals - cv_constraints$cv_max^2)  # (ii, v, vi) CVs
}

# ─── Jacobian ──────────────────────────────────────────────────────
# Row 1:  d(budget)/d(n_h) = c_h  (linear, constant)
# Rows 2+: d(relvar_k)/d(n_h) from grad_relvar()
eval_jac_52 <- function(nh) {
  cv_jac <- map2(cv_constraints$S2, cv_constraints$tU,
                 function(s, t) grad_relvar(nh, ex52$Nh, s, t)) |>
    do.call(rbind, args = _)
  rbind(ex52$ch, cv_jac)
}
```

**Step 5: Solve.**

```r
#| label: ex52-solve

result_52 <- solve_slsqp(
  eval_f_52, eval_grad_f_52, eval_g_52, eval_jac_52,
  lb = rep(n_min_52, 5),   # (iii) n_h >= 100
  ub = ex52$Nh,            # (iv)  n_h <= N_h
  restarts = 50
)

nh_52 <- result_52$solution
```

**Step 6: Results.** Compare with the professor's Excel Solver solution (GRG Nonlinear, Precision $10^{-6}$, Convergence $10^{-4}$, Central Derivatives).

```r
#| label: ex52-comparison

nh_excel <- c(412.89, 317.95, 123.76, 1396.98, 595.91)

tibble(
  Sector        = ex52$sector,
  `R (SLSQP)`   = sprintf("%.2f", nh_52),
  `Excel (GRG)` = sprintf("%.2f", nh_excel),
  Difference    = sprintf("%.2f", nh_52 - nh_excel)
) |>
  kable(caption = "Continuous Optimal Allocations: R vs Excel Solver")
```

-   The two solvers converge to effectively the same continuous optimum, confirming that R's `nloptr::SLSQP` replicates Excel Solver's GRG Nonlinear for this class of convex programs.

**Full allocation table.**

```r
#| label: ex52-allocation-table

alloc_52 <- ex52 |>
  mutate(nh = nh_52) |>
  mutate(
    across(starts_with("S2_"),
           function(s2) var_component(nh, Nh, s2),
           .names = "V_{str_remove(.col, 'S2_')}")
  )

totals_row_52 <- alloc_52 |>
  summarise(
    sector = "Total", Nh = sum(Nh), ch = NA_real_, nh = sum(nh),
    across(starts_with("V_"), sum)
  )

bind_rows(alloc_52, totals_row_52) |>
  select(sector, Nh, ch, nh, V_rev, V_emp, V_credit, V_offshore) |>
  kable(caption = "Solver Allocation Table (Continuous Solution)",
        col.names = c("Sector", "Nh", "ch", "nh",
                      "V: Revenue", "V: Employees", "V: Credit", "V: Offshore"),
        digits = c(0, 0, 0, 2, 0, 0, 4, 4),
        format.args = list(big.mark = ","))
```

```r
#| label: ex52-summary

summary_52 <- variables_52 |>
  mutate(
    V_total = map_dbl(S2, function(s) sum(var_component(nh_52, ex52$Nh, s))),
    RELVAR  = map2_dbl(S2, tU, function(s, t) relvar(nh_52, ex52$Nh, s, t)),
    CV      = sqrt(RELVAR)
  )

summary_52 |>
  select(var_name, tU, RELVAR, CV) |>
  kable(caption = "Population Totals, Relvars, and CVs",
        col.names = c("Variable", "tU", "RELVAR", "CV(pop estimate)"),
        digits = c(0, 0, 10, 7),
        format.args = list(big.mark = ","))
```

-   **Objective:** $\text{relvar}(\hat{t}_{rev}) = `r sprintf("%.10f", eval_f_52(nh_52))`$, i.e. $CV(\hat{t}_{rev}) = `r sprintf("%.5f", sqrt(eval_f_52(nh_52)))`$.

**Constraint checks.**

```r
#| label: ex52-checks

cost_52 <- sum(ex52$ch * nh_52)

cv_achieved_52 <- cv_constraints |>
  mutate(cv = map2_dbl(S2, tU,
                       function(s, t) sqrt(relvar(nh_52, ex52$Nh, s, t))))

tibble(
  Constraint = c(
    sprintf("(i)   Budget \u2264 %s", dollar(budget)),
    sprintf("(ii)  CV(employees) \u2264 %.2f", cv_constraints$cv_max[1]),
    sprintf("(iii) All nh \u2265 %d", n_min_52),
    "(iv)  All nh \u2264 Nh",
    sprintf("(v)   CV(credit) \u2264 %.2f", cv_constraints$cv_max[2]),
    sprintf("(vi)  CV(offshore) \u2264 %.2f", cv_constraints$cv_max[3])
  ),
  Status = c(
    cost_52 <= budget + 1,
    cv_achieved_52$cv[1] <= cv_constraints$cv_max[1] + 1e-8,
    all(nh_52 >= n_min_52 - 1e-8),
    all(nh_52 <= ex52$Nh + 1e-8),
    cv_achieved_52$cv[2] <= cv_constraints$cv_max[2] + 1e-8,
    cv_achieved_52$cv[3] <= cv_constraints$cv_max[3] + 1e-8
  )
) |> kable(caption = "Constraint Checks")
```

-   Two constraints are binding: the budget and $CV(\hat{t}_{offshore}) \leq 0.03$. This matches the Excel Solver Answer Report, where the Lagrange multiplier for the budget is $-2.06 \times 10^{-8}$ and for CV(offshore) is $-0.2375$, with the remaining constraints having zero multipliers.

-   **Note on integer solutions.** The Excel Solver was configured with "Solve Without Integer Constraints" per the Answer Report (Integer Tolerance 5%). If integer solutions are desired, rounding the continuous optimum yields $\mathbf{n} = (`r paste(round(nh_52), collapse = ", ")`)$, which satisfies all constraints within numerical tolerance.
