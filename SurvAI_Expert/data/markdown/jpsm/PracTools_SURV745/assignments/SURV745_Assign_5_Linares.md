---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_5_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 5"
original: "PracTools_SURV745/assignments/SURV745_Assign_5_Linares.qmd"
pages: 
sha256: "3c299ef9f5b53e0ed487aa355c0e18504c3e90a54cfb82c4062e01484d5a97a3"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:08"
---


```r
pacman::p_load(PracTools, knitr, ggthemes, tidyverse)
options(scipen = 999)

# read in data
data(MDarea.popA)
```

# Exercise 9.1

## Using the Maryland population, plot the PSU totals (y-axis) versus PSU population counts. Do this for PSUs defined as (a) tracts and (b) block groups. Do the plots for the five variables in the Maryland dataset: y1, y2, y3, ins.cov, and hosp.stay. Discuss whether simple random sampling of PSUs or pps sampling will be more efficient. Explain your reasoning.

### Tracts

-   If PSU totals are *proportional* to PSU size $N_i$ (i.e., the plots
    show a strong positive linear relationship passing near the origin),
    then $\bar{y}_{Ui}$ is roughly constant across PSUs, $B^2$ (the unit
    relavariance amongPSU totals) under PPS will be near zero, and PPS
    is substantially more efficient than SRS.

```r
# create unique tract ID & get totals + counts
tract_summary <- MDarea.popA |>
  group_by(TRACT) |>
  reframe(
    N_i      = n(), # number of elements in the pop for PSU i
    # total for vriables
    y1_t     = sum(y1),
    y2_t     = sum(y2),
    y3_t     = sum(y3),
    ins_cov_t    = sum(ins.cov),
    hosp_stay_t   = sum(hosp.stay),
  ) |> 
  # stack data for plot
  pivot_longer(-c("TRACT", "N_i"),
    names_to  = "variable", values_to = "psu_total"
  ) 

# print table
tract_summary |> head() |> kable()

# plot table
tract_summary |> 
  ggplot(aes(x = N_i, y = psu_total)) +
  geom_point(size = 1.5, alpha=.7, color = "dodgerblue") +
  geom_smooth(method = "lm", linewidth=.75, color = "orange") +
  facet_wrap(~ variable, scales = "free_y", ncol = 2) +
  labs(title = "Tract PSU Totals by Tract Population Counts",
    x = expression(N[i] ~ "(Tract Population Count)"),
    y  = expression(t[i] ~ "(Tract Total)")) +
  theme_hc() 


```

\newpage

### Blocks

-   We need to convert block ids to unique ids into a separate column.

```r

# create unique tract ID & get totals + counts
block_summary <- MDarea.popA |>
  # Create unique block group ID ( as in VDK)
  mutate(trtBG = 10 * TRACT + BLKGROUP) |> 
  group_by(trtBG) |>
  reframe(
    N_i      = n(), # number of elements in the pop for PSU i
    # total for vriables
    y1_t     = sum(y1),
    y2_t     = sum(y2),
    y3_t     = sum(y3),
    ins_cov_t    = sum(ins.cov),
    hosp_stay_t   = sum(hosp.stay),
  ) |> 
  # stack data for plot
  pivot_longer(-c("trtBG", "N_i"),
    names_to  = "variable", values_to = "psu_total"
  ) 

# print table
block_summary |> head() |> kable()

# plot table
block_summary |> 
  ggplot(aes(x = N_i, y = psu_total)) +
  geom_point(size = 1.5, alpha=.7, color = "forestgreen") +
  geom_smooth(method = "lm", linewidth=.75, color = "orange") +
  facet_wrap(~ variable, scales = "free_y", ncol = 2) +
  labs(title = "Block group PSU Totals by Block Group Population Counts",
    x = expression(N[i] ~ "(Block Group Population Count)"),
    y  = expression(t[i] ~ "(Block Group Total)")) +
  theme_hc() 
```

\newpage

### Discussion

Tracts. The plots show a clear positive linear relationship between
tract totals $t_i$ and tract population counts $N_i$ for all five
variables, indicating that PSU totals scale is roughly proportionate to
PSU size (i.e., the within-PSU means $\bar{y}_{Ui}$ are relatively
stable across tracts). Under PPS sampling with $p_i \propto N_i$, the
one-PSU estimate is $t_i/p_i = N\bar{y}_{Ui}$, and if $\bar{y}_{Ui}$ is
approximately constant, this quantity is nearly identical across all
PSUs, making $S^2_{U1(\text{pwr})}$ and hence $B^2$ very small (see VDK
9.2.3). PPS sampling of tracts is therefore potentially more efficient
than SRS, as the between-PSU variance component is greatly reduced.
Block groups. The same proportional pattern holds for block groups, but
with even wider size variability based on the plots. As with tracts, PPS
will greatly reduce $B^2$ relative to SRS. PPS is again the preferred
design for block groups. Across both PSU definitions and all five
variables, the near-linear relationship between PSU totals and PSU
population counts supports PPS sampling as the more efficient design. A
plausible caveat is that PPS requires accurate measures of size $N_i$;
when these are unavailable or poorly correlated with the actual PSU
sizes, the efficiency gains may not be realized.
