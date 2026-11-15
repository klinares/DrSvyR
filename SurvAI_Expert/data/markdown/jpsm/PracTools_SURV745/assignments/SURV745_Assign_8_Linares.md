---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_8_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 8"
original: "PracTools_SURV745/assignments/SURV745_Assign_8_Linares.qmd"
pages: 
sha256: "21c2211e5896979c06ed949c72baaff0b8ad42bd9a31963ef6474e4fd85c67dd"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:08"
---


```r
#| echo: false
pacman::p_load(PracTools, knitr, kableExtra, tidyverse)
options(scipen = 999)
```

# VDK Exercise 10.3

### A two-stage survey of persons is to be done in which 5% of persons age 35 and under and 15% of persons over 35 will be sampled. Four PSUs will be selected using the composite MOS defined in Sect. 10.5. A self-weighting sample is to be selected within each domain, and the workload should be the same in each selected PSU.

-   We are given a table of 10 PSUs with two age domains: $d=1$ ($\leq 35$) and $d=2$ ($> 35$), with desired sampling rates $f_1 = 0.05$ and $f_2 = 0.15$, and $m = 4$ PSUs to be sampled. The composite MOS technique from VDK 10.5.1 provides both a self-weighting sample within each domain, equal workload across selected PSUs, and PSU selection probabilities $\pi_i$.

```r
# build the PSU frame from the exercise table
psu_frame <- tibble(
  PSU = 1:10,
  N_d1 = c(80, 60, 50, 80, 50, 90, 50, 50, 55, 50),
  N_d2 = c(20, 20, 90, 10, 25, 20, 80, 65, 25, 50),
  N_i = N_d1 + N_d2) # number of elementary units
  
# desired sampling rates per domain
f1 <- 0.05 # 5%
f2 <- 0.15 # 15%
m <- 4 # PSUs to be sampled

# pop domain totals
totals <- psu_frame |> 
  select(-PSU) |> 
  summarise_all(sum) 

totals |> kable()
```

\newpage

## (a) Total expected sample sizes for the two domains and the total sample size across domains.

-   The expected total number of sample size for domain $d$ is $n_d = f_d N_d$ (VDK 10.5.1). Domain 1 contributes 30.75 and domain 2 60.75, for a total expected sample size of 91.5.

```r
# total expected sample sizes
n1 <- f1 * totals$N_d1
n2 <- f2 * totals$N_d2
n <- n1 + n2

tibble(
  # parameters given
  Domain = c("d=1 (≤35)", "d=2 (>35)", "Total"),
  N_d = totals |> as_vector(),
  f_d = c(f1, f2, NA),
  n_d = c(n1, n2, n)) |>
  kable()
```

\newpage

## (b) Composite MOS for each PSU and the total across PSUs. Verify that the grand total equals the total expected sample size.

-   The composite MOS for PSU $i$ is (VDK eq. 10.1): $$S_i = \sum_{d=1}^{D} f_d \, N_i(d)$$ and the total MOS across all PSUs equals the total expected sample size: $S = \sum_{i \in U} \sum^D_{d=1} f_d N_i(d)$.

```r
psu_frame <- psu_frame |>
  mutate(
    # equation 10.1
    S_i = f1 * N_d1 + f2 * N_d2)

psu_frame |> 
  mutate(PSU = as.character(PSU)) |> 
  # joining column totals with PSU frame
  add_row(
    # computing S_i
    psu_frame |> 
      summarise_if(is.double, sum) |> 
      tibble() |> 
      mutate(PSU="Total") |> 
      relocate(PSU)
    ) |> 
  kable()

```

-   The grand total $S_i = 91.5$ equals the total expected sample size in (a).

\newpage

## (c) Selection probability for each PSU.

-   PSUs are selected with probabilities proportional to the composite MOS (VDK 10.5.1), and $pi_i$ will equal $m=4$ which is given to us.\
    $$\pi_i = \frac{m \, S_i}{S}$$

```r

# sum of all S_i is S
S_total <- psu_frame |> reframe(sum(S_i)) |> pull()

psu_frame <- psu_frame |>
  mutate(
    # calculate selection probability, m is given to us as 4
    pi_i = m * S_i / S_total)


psu_frame |>
  select(PSU, S_i, pi_i) |>
  kable()
```

\newpage

## (d) Domain sampling rate and expected domain sample size within each PSU. Are the expected sample sizes integers? If not, what method can be used for sampling within a PSU that will achieve the desired rate?

-   The equal workload per PSU is $\bar{n} = n / m$. The within-PSU sampling rate for domain $d$ in PSU $i$ is (VDK eq. 10.2) $$\pi_{k|i}(d) = \frac{n^*_i(d)}{N_i}$$ and the expected domain sample size within PSU $i$ is: $$n^*_i(d) = \bar{n} \, f_d \, \frac{N_i(d)}{S_i}$$

```r
# equal workload per PSU
n_bar <- n / m  # total expected n / number of PSUs to sampled

psu_frame <- psu_frame |>
  mutate(
    # within PSU sampling rates
    pi_k_d1 = n_bar * f1 / S_i,
    pi_k_d2 = n_bar * f2 / S_i,
    # expected domain sample sizes within PSU
    # by domain
    n_star_d1 = n_bar * f1 * N_d1 / S_i,
    n_star_d2 = n_bar * f2 * N_d2 / S_i,
    # sum total
    n_star_total = n_star_d1 + n_star_d2
  )

psu_frame |>
  select(PSU, pi_k_d1, pi_k_d2, n_star_d1, n_star_d2, n_star_total) |>
  kable()
```

\newpage

-   The workload in every PSU is $\bar{n} = 22.875$ , confirming equal workload across all PSUs. The expected domain sample sizes within each PSU are generally not integers. As VDK notes following Example 10.1, it is important to sample domain units at the specified rates rather than rounding to fixed integer counts. This can be achieved by applying systematic sampling at the rate $\pi_{k\mid i}(d)$ within each domain in each selected PSU (VDK 3.3 pg 64).

-   We can also verify that the sample is self-weighting in each domain. The overall selection probability for a unit $k$ in domain $d$ is (VDK 10.5.1): $$\pi_i \pi_{k|i}(d) = m \frac{S_i}{S} \frac{n^*_i (d)}{N_i (d)} = m\frac{S_i}{S} \frac{\bar{n}} {S_i}f_d = f_d$$ since $m\bar{n} = n = S$.

```r
# verify self weighting
psu_frame |>
  mutate(
    overall_d1 = pi_i * pi_k_d1,
    overall_d2 = pi_i * pi_k_d2
  ) |>
  select(PSU, overall_d1, overall_d2) |> 
  kable()
```

-   Every PSU produces $\pi_i \cdot \pi_{k|i}(1) = 0.05 = f_1$ and $\pi_i \cdot \pi_{k|i}(2) = 0.15 = f_2$, confirming the self-weighting property.

\newpage

## (e) Verify that the expected sample sizes for any four of the PSUs sum to the total expected sample size.

-   SInce the composite MOS design guarantees equal workload $\bar{n} = n/m$ in every selected PSU, the expected total sample from any set of $m = 4$ PSUs is $4 \times \bar{n} = 4 \times 22.875 = 91.5 = n$. This follows from $\sum_d n^*_i(d) = \bar{n}$ for every PSU $i$. We combine all plausible four PSU combinations and compute the expected sample size. A random draw of 10 plausible combinations of four PSUs show that they all sum to $n = 91.5$ (see table below). This result holds for any four PSUs because each PSU contributes exactly $\bar{n} = 22.875$ to the total workload, so $4 \times \bar{n} = n$. Note that the domain-specific subtotals $\sum n^*_i(1)$ and $\sum n^*_i(2)$ depend on which PSUs are selected and will not generally equal $n_1$ and $n_2$ for a particular realized sample. However, the overall rates $f_1$ and $f_2$ are achieved in expectation over repeated PSU selections because the design is self-weighting.

```r
# there are 210 combinations of 4 PSUs (choose(10,4))
## create a grid of all possible combinations
psu_4_combos <- combn(1:10, m, simplify = FALSE) |>
  enframe(name = "combo_id", value = "combination") # convert list to tibble

# we map through each PSU combination & comptuer expected N
all_psu_combos <- map_dfr(psu_4_combos$combination, function(psu_combo){
  psu_frame |> 
    filter(PSU %in% psu_combo) |> 
    reframe(total_d1    = sum(n_star_d1),
      total_d2    = sum(n_star_d2),
      grand_total = sum(n_star_total)) |>
    mutate(PSUs = paste(psu_combo, collapse = ", "), .before = 1)
})

# print a random sample combination of 10 sets of 4 PSUs
all_psu_combos |> 
  slice_sample(n=10) |> 
  mutate_if(is.double, round, 2) |> 
  kable()
```
