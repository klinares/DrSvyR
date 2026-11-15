---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_1_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 1 - SURV745"
original: "PracTools_SURV745/assignments/SURV745_Assign_1_Linares.qmd"
pages: 
sha256: "22b9fe58491d3aad1c5ed4f7412e13e04c8aa09bae62e14acda69b8d5c05e924"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:12"
---


```r
#| label: setup
#| include: false

pacman::p_load(PracTools, knitr, patchwork, tidyverse)

# Set global options
options(digits = 4, scipen = 999)
```

# VDK Exercises

### 3.1According to the U.S. Bureau of Labor Statistics, 71% of all workers in private industry had access to employer-sponsored medical care plans, 52% of all workers participated in medical care plans in March 2006, and 7% of part-time workers participated in a vision care program ([Tables 1 and 2](https://www.bls.gov/ebs/home.htm)).

-   Calculate the size of a simple random sample of employees that would be needed to estimate each of these proportions using the estimation targets in (a), (b), and (c).

```r
# create the table
table_3_1 <- tibble(
  Medical_plans = c("Access to Medical Care", "Participate in Medical Care",
                    "Part-time Vision Care"),
  # population proportion p_U
  p_U = c(.71, .52, .07)
)
```

-   a\) Coefficient of variation of 10%.
    -   For a $CV_0$ target of $.10$ assuming SRSWOR for a proportion we can calculate the sample size as $n=\frac{q_U/p_U}{CV^2_0}$ where $q_U$ is the complement of $p_U$. We use the `pracTools::nProp()` function to calculate this quantity.

```r
cv0 <- .10

table_3_1 <- table_3_1 |> 
  mutate(q_U = 1 - p_U,
         n_size_cv = nProp(CV0 = cv0, N=Inf, pU = p_U), 
         n_size_cv = round(n_size_cv)) 

table_3_1 |> 
  select(1, n_size_cv) |> 
  kable()

```

-   b\) Standard error of 3% points.

    -   From this SE we calculate the variance target as $V_0=SE^2 = .03^2 = .0009$ to use in our formula $n = \frac{p_Uq_U}{V_0}$.

```r
v0 <- .03^2

table_3_1 <- table_3_1 |> 
  mutate(n_size_se = nProp(V0 = v0, N=Inf, pU = p_U), 
         n_size_se = round(n_size_se)) 


table_3_1 |> 
  select(1, n_size_se)|> 
  kable()

```

-   c\) MOE of 3% points.

    -   For an MOE of $.03$ with an $\alpha=.05$, we have an $z=.975$ and our formula is $n= z^2_{1 -\alpha /2}  \frac{p_Uq_U}{e2}$ which we can use the `pracTools::nPropMoe()` function to calculate this quantity.

```r
moe <- .03
alpha <- .05

table_3_1 <- table_3_1 |> 
  mutate(n_size_moe = 
           nPropMoe(moe.sw = 1, e = moe, alpha = alpha, pU = p_U, N = Inf), 
         n_size_moe = round(n_size_moe)) 


table_3_1 |> 
  select(1, n_size_moe)|> 
  kable()

```

-   d\) For each of the sample sizes you computed in (a), (b), and (c), what are the anticipated half-widths of 95% confidence intervals? Use the normal approximation with a multiplier of 1.96.

    -   The half-width of the 95% confidence interval is $\text{Half-Width} = 1.96 \times \sqrt{\frac{p_U q_U}{n}}$ .

```r
z <- qnorm(0.975)

table_3_1_half_width <- table_3_1 |> 
  pivot_longer(-c("Medical_plans", "p_U", "q_U"),
               names_to = "type", values_to = "n_size") |> 
  mutate(half_width = z * sqrt( (p_U * q_U) / n_size),
         half_width = scales::percent(half_width, accuracy=.1)) |> 
  select(type, Medical_plans, half_width) |> 
  pivot_wider(names_from = type, values_from = half_width) 

table_3_1_half_width |> 
  kable()
```

-   e\) Comment on the differences in sample sizes that result from the three precision targets in (a), (b), and (c).

```r
table_3_1 |> select(-q_U) |> kable()
```

-   We note that in the CV target, in rare events such as part-time vision care, the sample size required to achieve a CV of .10 is very large relative to the other medical plans. However, when using an SE=.03, the sample size flips where part time vision care requires the smallest sample size compared to the other plans which means that proportions greater than .05 require much larger sizes. In the MOE target, sample sizes are much larger than the SE target since this involved dividing by z of 1.96. It seems that the SE target is more stable across different proportion levels where the CV and MOE vary.

\newpage

### 3.2 Explore the difference in setting a sample size based on a target for a coefficient of variation of an estimated proportion and setting it based on a target standard error. Assume that a simple random sample without replacement is selected but that the population size is large so that the fpc is negligible.

-   a\) Calculate CV($p_s$) and $\sqrt{V(p_s)}$ for a sample size of n = 100 for $p_U$ in (0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99).

    -   The $V(p_s) = \frac{p_Uq_U}{n}$ is used to calculate the $CV(p_s) = \frac{1}{n} \frac{q_U}{p_U}$ where $\frac{q_U}{p_U}$ is the relvariance for the proportion.

```r
n <- 100

table_3_2 <- tibble(
  p_U = c(0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99)
) |> 
  mutate(q_U = 1 - p_U,
        # calculate variance
        V = (p_U * q_U) / n,
        SE = sqrt(V),
        CV = SE / p_U)

table_3_2 |> 
  select(, p_U, SE, V, CV) |> 
  kable()

```

-   b\) Graph the values of $CV(p_s)$ and $\sqrt{V(p_s)}$ versus $p_U$.

```r
#| fig-width: 8
#| fig-height: 5


p1 <- table_3_2 |> 
  ggplot(aes(x=p_U, y=CV)) + 
  geom_line(color="dodgerblue") + 
  geom_point() +
  labs(title="CV vs Proportions") +
  ggthemes::theme_hc() 

p2 <- table_3_2 |> 
  ggplot(aes(x=p_U, y=SE)) + 
  geom_line(color="limegreen") + 
  geom_point() +
  labs(title="Variance vs Propotions") +
    ggthemes::theme_hc() 

p1 / p2

```

-   c\) Discuss the differences in the relationships.

    -   We note here that the two precision measures behave differently as a function of $p_U$. With the CV measure, we see a monotonic decrease as proportions approach 1, while with variance we see a symmetric parabola maximized at .50. For rare events, CV is larger up until around a proportion of .20 when it begins to decrease. Conversely, variance is highest at a proportion of .05. It is possible that rare events will need much larger sample sizes to achieve a certain CV target, while proportions near the middle when using a variance measure will need the largest sample sizes. Therefore, if estimating a rare event a CV target will require large samples, but for common characteristics, CV is preferred.

\newpage

### Table 3.2

```r
# table 3.2
smho <- tibble(
  stratum = 1:6,
  org = c(
    "Psychiatric hospital",
    "Residential",
    "General hospital",
    "Military veterans",
    "Partial/Outpatient",
    "Multiservice/Substance"
  ),
  y_U = c(21240408, 10024876, 4913008, 11927573, 6118415, 15567731), 
  N_h = c(215, 65, 252, 50, 149, 144),
  S_h = c(26787207, 10645109, 6909676, 11085034, 9817762, 44553355),
  cost_per_h = c(1400, 200, 300, 600, 450, 1000)
) |> 
  # calculate W_H
  mutate(W_h = N_h / sum(N_h))

smho |> kable()
```

\newpage

### Q4 What if no relative cost values are available? What are options for sample allocation across strata?

-   When we are missing cost values, there have three plausible allocating method options. Proportional allocation $n_h=n \times \frac{N_h}{N}$ which allocates sample proportional to stratum population sizes, and is a self-weighting design, that is equal selection probability. This however, ignores differences in variances. We can still use Neyman allocation but will require stratum SD estimates. The third allocation method is equal allocation $n_h = \frac{n}{H}$ which will allocate equal sample sizes to each stratum but this is inefficient for overall population estimates.

### Q5 What would the results be if we had chosen a proportional allocation instead with a fixed sample size of 100? What are the potential issues?

-   If we were to use proportional allocation for a fixed sample size of 100, the total cost would be \$72,350. Since proportional allocation ignores stratum variances we drop the $Sh$ argument in `strAlloc()`. Smaller strata such as 2 and 4 receive smaller units respectively, leading to imprecise stratum estimates. Stratum 6 has the largest variance but receives about 16% of the sample based on the population share.

```r
n_fixed <- 100

# pop mean
ybar_U <- smho |> summarise(mean(y_U)) |> pull()

smho_prop <- smho |> 
  mutate(
    result = list(strAlloc(n.tot = n_fixed, Nh = N_h, alloc = "prop")),
    n_h = round(result[[1]]$nh),
    `n_h/n` = result[[1]]$`nh/n`,
    var_cost = n_h * cost_per_h,
    f_h = n_h / N_h
  ) |> 
  select(-result)

# calculate SE(y_bar_st) using VDK 3.20
SE_yst_prop <- smho_prop |> 
  summarise(
    SE_yst = sqrt(sum(W_h^2 * (1 - f_h) * S_h^2 / n_h))
  ) |> 
  pull()

# print table
smho_prop |> 
  select(stratum, org, n_h, var_cost) |> kable()


cat("Total cost for proportional allocation:", 
    scales::dollar(sum(smho_prop$var_cost)), "\n")
cat("SE(y_bar_st):", scales::comma(SE_yst_prop))
```

### Q6 What would the results be if we had chosen a Neyman allocation with the same total sample size as the cost-strained (a total budget of \$100,000) allocation?

-   The cost constrtained allocation of a budget with \$100,000 yields a total sample size of 119 with a total cost of \$100,100 (rounding $n_h$). Using Neyman allocation with this sample size, the total cost increases substantially to \$114,900. Neyman allocation ignores cost differences and concentrates sample in high variance strata 1 and 6, which they also happen to be expensive per unit. The trade off is clear in that the budget is fixed at \$100k, Neyman allocation is infeasible as it exceeds the budget by nearly \$15k. However, if precision is the priority and budget is flexible, Neyman provides slightly better efficiency. When budget is hard constraint, cost constrained allocation is the practical choice as it achieves comparable precision while respecting the \$100k, at the cost of less precision for specific strata like 2 and 4.

```r

# Step 1, calculate the cost constrained for the budget of 100k

budget_100k <- 100000
ybar_U <- smho |> summarise(mean(y_U)) |> pull()


#  Cost-constrained allocation
smho_cost_100k <- smho |> 
  mutate(
    result = list(strAlloc(Nh = N_h, Sh = S_h, cost = budget_100k, 
                           ch = cost_per_h, alloc = "totcost")),
    n_h = round(result[[1]]$nh),
    `n_h/n` = n_h / sum(n_h),
    var_cost = n_h * cost_per_h,
    f_h = n_h / N_h
  ) |> 
  select(-result)

n_from_cost <- sum(smho_cost_100k$n_h)

# Neyman allocation with same n
smho_neyman_same_n <- smho |> 
  mutate(
    result = list(strAlloc(n.tot = n_from_cost, Nh = N_h, Sh = S_h, 
                           alloc = "neyman")),
    n_h = round(result[[1]]$nh),
    `n_h/n` = n_h / sum(n_h),
    var_cost = n_h * cost_per_h,
    f_h = n_h / N_h
  ) |> 
  select(-result)

# calculate SE for both allocations
SE_cost <- sqrt(sum(smho_cost_100k$W_h^2 * 
                      (1 - smho_cost_100k$f_h) * smho_cost_100k$S_h^2 / 
                      smho_cost_100k$n_h))

SE_neyman <- sqrt(sum(smho_neyman_same_n$W_h^2 * 
                        (1 - smho_neyman_same_n$f_h) * smho_neyman_same_n$S_h^2 / 
                        smho_neyman_same_n$n_h))

# compre this results
tibble(
  allocation = c("Cost-constrained ($100k)", paste0("Neyman (n=", n_from_cost, ")")),
  n_total = c(sum(smho_cost_100k$n_h), sum(smho_neyman_same_n$n_h)),
  total_cost = c(scales::dollar(sum(smho_cost_100k$var_cost)), 
                 scales::dollar(sum(smho_neyman_same_n$var_cost))),
  SE_yst = scales::comma(c(SE_cost, SE_neyman))
  ) |> 
  kable()

```
