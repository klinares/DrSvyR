---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_6_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 6"
original: "PracTools_SURV745/assignments/SURV745_Assign_6_Linares.qmd"
pages: 
sha256: "cae88f192d39ac49aac8b8c0568b8787973f11c318aab2ba740551f8e085572d"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:13"
---


```r
#| echo: false
pacman::p_load(PracTools, knitr, kableExtra, ggthemes, tidyverse)
options(scipen = 999)
data(MDarea.popA)
```

# VDK Exercise 9.5

### Explore the effects of different sizes of $\delta_1$ and $\delta_2$ on the allocation of a three-stage sample with a total budget of \$500,000 and cost components $(C_1, C_2, C_3) = (1000, 200, 120)$. Assume that the $\pi$-estimator is used; that the number of sample PSUs is $m$, the same number of SSUs, $\bar{n}$, is allocated to each PSU, and that $\bar{\bar{q}}$ elements are selected from each SSU. Calculate optimum values of $m$, $\bar{n}$, and $\bar{\bar{q}}$ for all 9 combinations of $\delta_1 \in \{0.001, 0.01, 0.05\}$ and $\delta_2 \in \{0.05, 0.10, 0.25\}$. Compute the anticipated $CV$s for each combination assuming that the unit relvariance of the analysis variable is $\tilde{V} = 2$.

We can use the total variable-cost function for three-stage sampling (VDK eq. 9.27): $$C = c_0 + C_1 m + C_2 m\bar{n} + C_3 m\bar{n}\bar{\bar{q}}$$

and under a ppswr/srs/srs (or srswr at all stages using the $\pi$-estimator form), the approximate relvariance of the estimator is (VDK eq. 9.21): $$\frac{V(\hat{t}_{pwr})}{t^2_U} = \frac{\tilde{V}}{m\bar{n}\bar{\bar{q}}} \left\{ k_1 \delta_1 \bar{n}\bar{\bar{q}} + k_2\left[1 + \delta_2(\bar{\bar{q}} - 1)\right] \right\}$$

where optimal values minimizing variance based to the budget are (VDK eqs. 9.29–9.31): $$\bar{\bar{q}}_{\text{opt}} = \sqrt{\frac{1-\delta_2}{\delta_2} \cdot \frac{C_2}{C_3}}, \quad \bar{n}_{\text{opt}} = \frac{1}{\bar{\bar{q}}_{\text{opt}}} \sqrt{\frac{1-\delta_2}{\delta_1} \cdot \frac{C_1}{C_3} \cdot \frac{k_2}{k_1}}, \quad m_{\text{opt}} = \frac{C - C_0}{C_1 + C_2\bar{n}_{\text{opt}} + C_3\bar{n}_{\text{opt}}\bar{\bar{q}}_{\text{opt}}}$$

We use `clusOpt3()` with $k_1 = k_2 = 1$, $\tilde{V} = 2$, `cal.sw = 1` (fixed total budget), and $C_0 = 0$.

```r
# parameters given to us
C_total <- 500000 # total budget
c_unit <- c(1000, 200, 120) # cost components
unit_rv <- 2 # unit relvariance

# deltas
delta1 <- c(0.001, 0.01, 0.05) 
delta2 <- c(0.05, 0.10, 0.25)

# create different a delta grid (combinations)
delta_grid <- expand_grid(
  delta1 = delta1,
  delta2 = delta2
) 

delta_grid |> kable()

```

-   For each unique combination of deltas, we will use from the practools package the `clusOpt3()` with $k_1 = k_2 = 1$, $\tilde{V} = 2$, `cal.sw = 1` (fixed total budget), and $C_0 = 0$.

```r
opttimum_values <- delta_grid |> 
  rowwise() |>
  mutate(
    out = list(
      clusOpt3( # from practools
        unit.cost = c_unit, # pass the cost per unit
        delta1 = delta1,
        delta2 = delta2,
        unit.rv = unit_rv, # pass the unit relvariance
        k1 = 1, # ratio of B^2  + W^2 to unit rel
        k2 = 1, # ratio of W^2_2 + W^2_3 to unit rel 
        tot.cost = C_total, # total cost
        cal.sw = 1 #  1 = find optimal m.opt
      )
    ),
    # round results
    m_opt = round(out$m.opt, 1),
    nbar_opt = round(out$n.opt, 1),
    qbar_opt = round(out$q.opt, 1),
    CV = round(out$CV,   4)
  ) |>
  ungroup() |>
  select(-out)

opttimum_values |> kable()
```

-   We can see that with the increase of $\delta_1$, elements within PSUs become more homogeneous (e.g., PSU totals vary more). This makes allocating more PSUs and fewer SSUs per PSU more efficient, so $m_{\text{opt}}$ tends to increase while $\bar{n}_{\text{opt}}$ decreases. When $\delta_1$ is very small (e.g., 0.001), PSUs are nearly interchangeable, suggesting that the design concentrates resources inside selected PSUs ($\bar{n}$ is large). A large $\delta_1 = 0.05$ moves the optimal $\bar{n}$ downward because adding more SSUs per PSU yields diminishing returns once the within-PSU variance is largely captured. When $\delta_2$ increases, elements within SSUs become more homogeneous (SSU totals vary more), so that fewer elements per SSU are needed: $\bar{\bar{q}}_{\text{opt}}$ decreases. The freed-up budget is reallocated to selecting more SSUs as $\bar{n}$ grows, but fewer PSUs are selected. The CV increases with both $\delta_1$ and $\delta_2$, reflecting greater intracluster homogeneity reducing effective sample size. Under the same budget, larger intraclass correlations mean that any fixed allocation is less efficient. The CV is lowest in the corner $(\delta_1, \delta_2) = (0.001, 0.05)$ and highest at $(0.05, 0.25)$.

\newpage

# VDK Exercise 9.7

Use the full Maryland population (`MDarea.popA`) and `BW3stagePPS()` to answer the following:

-   \(a\) Compute $B^2$, $W^2$, $W^2_2$, $W^2_3$, $\delta_1$, and $\delta_2$ for the variables Hispanic, Gender, and Age. Recode Hispanic and Gender so that they are (0,1) variables (1=Hispanic, 0 if not; 1=male, 0=female). Treat Age as continuous for this exercise (even though it is coded into 23-ordered categories). Do the calculations assuming that three-stage sampling will be used with tracts as PSUs, block groups within tracts as SSUs, and persons as elements. The sample at all three stages will be selected using srswr.

```r

md_pop <- MDarea.popA |>
  # recode Hispanic & Gender
  mutate(
    Hispanic = if_else(Hispanic == 1, 1, 0),
    Gender =  if_else(Gender == 1, 1, 0),
    # Unique SSU identifier: 10*TRACT + BLKGROUP  
    trtBG = 10 * TRACT + BLKGROUP
  )

# generate plot to visualize recoding
md_pop |>
  mutate(
    Hispanic = factor(Hispanic, labels = c("Non-Hispanic", "Hispanic")),
    Gender = factor(Gender, labels = c("Female", "Male"))
  ) |>
  count(Hispanic, Gender) |>
  ggplot(aes(x = Hispanic, y = n, fill = Gender)) +
  geom_col(position = "dodge") +
  scale_fill_viridis_d(option = "C", end = .55, direction = -1, alpha = .65) +
  labs(y = "Count") +
  theme_minimal()

```

-   Under srswr, the one-draw probability for each PSU equals $p_i = 1/M$ for all $i$. We can use the `BW3stagePPS()` to calculate the variables needed.

```r
# number of unique PSUs
M_tract <- md_pop |> distinct(TRACT) |> nrow()

# One-draw probabilities: srswr 
pp_srs <- rep(1 / M_tract, M_tract)

bw_srs <- md_pop |>
  # select the variables needed
  select(Hispanic, Gender, Age) |>
  # loop through each variable using bw3stagepps()
  map(\(x)
      BW3stagePPS(
        X = x,
        pp = rep(1 / M_tract, M_tract),  # one draw probabilities
        psuID = md_pop$TRACT,
        ssuID = md_pop$trtBG)
  ) |>
  bind_rows(.id = "Variable")


# display results in table
bw_srs |>
  mutate(across(where(is.numeric), ~round(.x, 4))) |>
  kable()
```

-   \(b\) Repeat the calculations for a design in which PSUs are selected via ppswr rather than srswr.

    -   Under ppswr, the one-draw probability for PSU $i$ (TRACT) is $p_i = N_i / N$ where $N_i$ is the number of persons in tract $i$.

```r


# One draw probabilities for ppswr
pp_pps <- md_pop |>
  group_by(TRACT) |>
  summarise(n = n()) |>
  mutate(pp = n / sum(n)) |> # this is N_i / N
  pull(pp)

bw_pps <- md_pop |>
  select(Hispanic, Gender, Age) |>
  map(\(x)
      BW3stagePPS(
        X = x,
        pp = pp_pps,
        psuID = md_pop$TRACT,
        ssuID = md_pop$trtBG)
  ) |>
  bind_rows(.id = "Variable")

# display results in table
bw_pps |>
  mutate(across(where(is.numeric), ~round(.x, 4))) |> 
  kable()

```

\newpage

-   \(c\) Discuss the differences in results. In particular, comment on why the values of δ1 are different in the two designs.

    -   Both designs yield a similar $\hat{W}_2^2$, $\hat{W}_3^2$, $\tilde{V}$, and $k_2$ because these components depend on variation among SSU totals and element level variance within selected PSUs, which is unaffected by the first-stage inclusion probabilities. There is a key difference is in $\hat{B}^2$ and hence $\hat{\delta}_1$, such that under srswr, $\hat{B}^2 = M^2 S_{U1}^2 / t_U^2$ (VDP eq. 9.16)measures variation among the raw PSU totals $t_i$. Since tracts in Maryland vary in size ($N_i$), the totals $t_i$ also vary substantially even if per-capita values are similar across tracts and it inflates $\hat{B}^2$ and $\hat{\delta}_1$. Under ppswr, if per-capita means $\bar{y}_{Ui}$ are relatively homogeneous across tracts then $t_i/p_i$ is nearly constant, driving $S_{U1(\text{pwr})}^2$ (VDK eq. 9.17)toward zero. This explains why $\hat{\delta}_1$ under ppswr is much smaller than under srswr for all three variables. $\hat{\delta}_2$ is similar under both designs because the within-PSU, between-SSU component $W_2^2$ does not depend on how PSUs are selected.
