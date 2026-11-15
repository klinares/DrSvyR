---
id: "jpsm/Fund_Infe_SURV740/final/linares_final"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Kevin Linares Final"
original: "Fund_Infe_SURV740/final/linares_final.qmd"
pages: 
sha256: "ab97b58a9a8b58352c335b84bf8f673d44b664f0c069850e2bf37f007acc8760"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:05"
---


```r
#| echo: false
#| message: false
#| warning: false

library(tidyverse)
library(knitr)

```


## Question 2 a.

**Weight Calculations:**

*Design 1 & 3:* weights 1(1/2), 3(1/2)

-   $\bar{w} = 0.5(1) + 0.5(3) = 2$ 	

-   $s_w^2 = 0.5(1-2)^2 + 0.5(3-2)^2 = 	1$ 	

-   $CV_w = 1/2 = 0.5$ 	

-   $DEFF_{weight} = 1 + 0.25 = 1.25$ 	

*Design 2 & 4:* weights 1(1/2), 5(1/2)

-   $\bar{w} = 0.5(1) + 0.5(5) = 3$ 	

-   $s_w^2 = 0.5(1-3)^2 + 0.5(5-3)^2 = 	4$ 	

-   $CV_w = 2/3 = 0.667$ 	

-   $DEFF\_{weight} = 1 + 0.444 = 1.444$ 	

```r

q2_dat <- tibble(
  design = 1:4,
  weights = list(
    c(1, 3),
    c(1, 5),
    c(1, 3),
    c(1, 5)
  ),
  props = list(
    c(0.5, 0.5),
    c(0.5, 0.5),
    c(0.5, 0.5),
    c(0.5, 0.5)
  ),
  rho = c(.10, .10, .20, .20),
  b = c(10, 15, 10, 15)
) |>
  mutate(
    # weight calculations
    w_bar = map2_dbl(weights, props, ~ sum(.x * .y)),
    s_w_sq = map2_dbl(weights, props, ~ sum(.y * (.x - sum(.x * .y))^2)),
    cv_w = sqrt(s_w_sq) / w_bar,
    
    # design effects
    deff_weight = 1 + cv_w^2,
    deff_cluster = 1 + (b - 1) * rho,
    deff_total = deff_weight * deff_cluster
  ) |>
  select(design, rho, b, deff_weight, deff_cluster, deff_total)
```

## Question 2 a 3, n_eff

```r
n<- 1000 # sampel size

q2_dat <- q2_dat |> 
  mutate(n_eff = ceiling(n/deff_total))

q2_dat |> kable()
```

\newpage

## Q3

```r
q3_dat <- tibble(y = c(1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 
                       0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1)
)

q3_dat |> kable()

y_sum <- q3_dat |> tally(y)
y_sum |> kable()

alpha <- 8+15; alpha
beta <- 12 + 30-15; beta
```

## Q3.2 We observe 15/30 successes

```r
N <- 200
n <- 30
y <- 15 # success
n_sims <- 3000
set.seed(57321)
# set parameters for a beta distribution
alpha_param <- 23
beta_param <- 27
# simulate from the posterior
draws <- rbeta(n_sims, alpha_param, beta_param)
# we need to simulate count for the non-sampled
non_sampled <- N - n

count_non_sampled <- rbinom(n_sims, non_sampled, draws)
# we can now get the total count in the population
total_counts <- count_non_sampled + y

# population prorportion with insurance
prop <- total_counts / N

prop |>
  tibble() |>
  reframe(Theta = mean(prop),
          lower = quantile(prop, .025),
          upper = quantile(prop, .975)) |>
  mutate_all(round, 3) |> 
  kable()
```

## Q3.b.3

```r
prob_value <- .500

tibble(
  Probability = mean(prop >= prob_value),
  Draws = sum(prop >= prob_value)
) |> 
  kable()
```

\newpage

## Q4. compute estimated slope

a.1
$$\hat{\beta}1 = \frac{s{xy}}{s_x^2} = \frac{18}{25} = 0.72$$

a.2
$$\bar{y}_{GREG} = \bar{y} + \hat{\beta}_1(\bar{X} - \bar{x}) = 4.2 + 0.72(46.0 - 44.5) = 4.2 + 1.08 = 5.28$$
a.3
$$r^2 = \left(\frac{s_{xy}}{s_y \cdot s_x}\right)^2 = \left(\frac{18}{6 \times 5}\right)^2 = (0.6)^2 = 0.36$$
$$Var(\bar{y}_{GREG}) = \frac{s_y^2}{n}(1 - r^2) = \frac{36}{300}(1 - 0.36) = 0.12 \times 0.64 = 0.0768$$

a.4

$$CI = \bar{y}_{GREG} \pm 1.96 \times SE = 5.28 \pm 1.96(0.277) = 5.28 \pm 0.543$$

$$CI = [4.74, 5.82]$$

4.b
Formula:
$$Var(\bar{y}_{SRS}) = \frac{s_y^2}{n}$$
Calculation:
$$Var(\bar{y}_{SRS}) = \frac{36}{300} = 0.12$$
$$SE(\bar{y}_{SRS}) = \sqrt{0.12} = 0.346$$



