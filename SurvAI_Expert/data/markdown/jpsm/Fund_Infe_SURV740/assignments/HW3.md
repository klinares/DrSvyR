---
id: "jpsm/Fund_Infe_SURV740/assignments/HW3"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Homework 3: Introduction to Causal Inference"
original: "Fund_Infe_SURV740/assignments/HW3.qmd"
pages: 
sha256: "dc0ee1058cca206592f4a2042f552c07c5ff0959de0634cfc46ba99041329662"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:01"
---


```r
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)

pacman::p_load(knitr, gtleExtra, tidyverse)

options(digits=5, scipen=999)
```

### Problem 1: Verify the bounds for the mean of potential outcome under control in never takers and compliers (NN and NY), that is $\theta^0_{NN}$ and $\theta^0_{NY}$, shown in the SSC Example (Note the results showing in the lecture slides might be (in)correct.

-   In this example of small schools of choices (SSC) study, we will examine the effect of SSC offers on the intermediate outcome (A):, being on track at the end of 9th grade, and the final outcome (Y), high school graduation.

-   Other notations include:

    -   Z, random assignment 0=control, 1=SSC offered).

    -   A, 9th grade status (N=not on track, Y=on track)

    -   Y, graduation status (0=not graduated, 1=graduated)

    -   $p_{za}$ , **proportion** of students with a status (N or Y) given assignment z (0 or 1).

    -   $\theta_{za}$ , probability of Y=1 high school **graduation rate** among students who have treatment Z=z and A=a.

-   We use the data from the slides to build a tables for $p_{za}$ proportions and $\theta_{za}$ rates.

    -   Observed proportions

        -   $p_{00} = p(A=N|Z=0) = 0.49$

        -   $p_{01} = p(A=Y|Z=0) = 0.51$

        -   $p_{10} = p(A=N|Z=1) = 0.35$

        -   $p_{11} = p(A=Y|Z=1) = 0.65$

    -   Observed graduation rates

        -   $\theta_{00} = p(Y=1|Z=0, A=N) = 0.34$
        -   $\theta_{10} = p(Y=1|Z=1, A=N) = 0.38$

-   With the **monotonicity assumption** (ruling out 'defiers', $A_1 \ge A_0$), we can figure out the proportion of students in each principal stratum:

    -   Never on track (NN): $\pi_{NN} = p_{10} = 0.35$
    -   Always on track (YY): $\pi_{YY} = p_{01} = 0.51$
    -   Compliers (NY): $\pi_{NY} = p_{00} - \pi_{NN} = 0.49 - 0.35 = 0.14$

```r
# Calculate strata proportions
pi_NN <- 0.35  # Never on track
pi_YY <- 0.51  # Always on track
pi_NY <- 0.14  # Compliers
p_00 <- pi_NN + pi_NY 
theta_00 <- .34

tibble(
  Stratum = c("Never-takers (NN)", "Always-takers (YY)", 
              "Compliers (NY)"),
  Proportion = c(pi_NN, pi_YY, pi_NY))|> 
  kable()
```

### 

-   We derive the bounds for $\theta^0_{NN}$. The observed group, Z=0, A=0 holds the NN and NY strata, and the observed outcome is:

$$
\theta_{00} = \phi_{NN} \times \theta^0_{NN} + \phi_{NY} \times \theta^0_{NY}
$$

-   the mixing proportions are:

$$
\phi_{NN} =  \frac{\pi_{Ny}}{\pi_{NN} +\pi_{NY}} = \frac{.35}{.35+.14} = .714
$$

$$
\phi_{NY} = \frac{\pi_{NY}}{\pi_{NY} + \pi_{NN}} = \frac{.14}{.14+.35} = .286
$$

-   We can now calculate bounds for $\theta^0_{NN}$.

$$
\theta^0_{NN} = \frac{\theta_{00} - \phi^0_{NY} \times \theta^0_{NY}}{\phi^0_{NN}} 
$$

-   If $\theta^0_{NY} = 1$, then $\theta^0_{NN} = \frac{.34 - .29 \times 1 }{.71}$, and if $\theta^0_{NY} = 0$, then $\theta^0_{NN} = \frac{.34 - .29 \times 0}{.71}$.

-   For $\theta^0_{NY}$,

$$
\theta^0_{NY} = \frac{\theta_{00} - \phi^0_{NN} \times \theta^0_{NN}}{\phi^0_{NY}} 
$$

-   If $\theta^0_{NN} = 1$, then $\theta^0_{NY} = \frac{.34 - .71 \times 1 }{.29}$, and if $\theta^0_{NN} = 0$, then $\theta^0_{NY} = \frac{.34 - .71 \times 0 }{.29}$.

```r
# Calculate mixing proportions
phi_NN <- pi_NN / p_00
phi_NY <- pi_NY / p_00

bounds_fun <- function(theta_value, phi_1, phi_2){
  lower = (theta_value - phi_1 * 1) / phi_2  # when theta_NY^0 = 1
  upper = (theta_value - phi_1 * 0) / phi_2  # when theta_NY^0 = 0
  # truncated to 1 since 0 < theta < 1
  # if lower < 0 = 0, it becomes 0, if upper > 1 = 1
  lower_trunc = max(0, lower)
  upper_trunc = min(1, upper)
  
  tibble(`Lower Bound` = lower_trunc, 
         `Upper Bound` = upper_trunc)
  
}

# pass thetas & phis to the function
bounds_NN <- bounds_fun(theta_00, phi_NY, phi_NN) # theta_NN^0 bounds
bounds_NY <- bounds_fun(theta_00, phi_NN, phi_NY) # theta_NY^0 bounds

# Summary table
bounds_NN |> 
  add_row(bounds_NY) |> 
  mutate(Stratum = c("Never takers (NN)", "Compliers (NY)")) |> 
  relocate(Stratum) |> 
  kable()
```

-   The never takers who do not receive the SSC offer have a graduation rate between 7.6% and 47.6%. However, without additional assumptions we are unable to compute graduation rates for compliers under control, and it could be anywhere from 0% to 100%.

\newpage

### **Problem 2:** We have

-   Z: Receipt of letter from physician to encourage flu shot (Z=1) or not (Z=0)

-   A: Patient decides to receive the flu shot (A=1) or not (A=0)

-   Y: Hospitalization (Y=1) or not (Y=0)

-   We observed that the probability of A=a given Z=z are $p_{za} = (p_{00}, p_{01}, p_{10}, p_{11})$ = (30%, 70%, 10%, 90%) and the probability of hospitalization (Y=1) for patients of A=a and Z=z are $\theta_{za} = (\theta_{00}, \theta_{01}, \theta_{10}, \theta_{11})$ = (.1, .08, .2, .15).

#### Research question: what are the impacts of the physician’s encouragement letter on hospitalization for those who are induced by the letter to take the flu shot (compliers)?

1.  Define the principal strata.

    -   The Always Takers (AT) are patients who get the flu shot regardless of letter.

    -   Defiers (D) are those that take the flu shot without letter encouragement, or refuse the flu shot with the letter encouragement.

    -   The Compliers (C) are patients who only get the flu shot if they get the letter.

    -   and the Never-Takers (NT) are patients who never get the flu shot, letter or not.

    -   We print below the four principal strata based on flu shot behavior, $A_0, A_1$.

```r
# build a table to show the latent strata
strata_definitions <- tibble(
  `Stratum` = c("Never-takers (NT)", 
                "Always-takers (AT)", 
                "Compliers (C)", 
                "Defiers (D)"),
  `Notation` = c("(A₀=0, A₁=0)", "(A₀=1, A₁=1)", 
                 "(A₀=0, A₁=1)", 
                 "(A₀=1, A₁=0)"),
  `Behavior` = c( # getting flu shot
    "Never get flu shot regardless of letter",
    "Always get flu shot regardless of letter",
    "Get flu shot only if receive letter",
    "Get flu shot only if no letter"))

# print table
strata_definitions |> kable()
```

\

2.  You observe a group of people who received the physician’s encouragement letter and received flu shot. What are their principal strata memberships?

    -   People who received the letter and got the flu shot (Z=1, A=1) could be always takers and compliers. Below, we print a table highlighting.

```r
# build membership table with plausable Z & A combinations
memberships <- tibble(
  `Observed Group` = c("(Z=1, A=1)", 
                       "(Z=1, A=0)", 
                       "(Z=0, A=1)", 
                       "(Z=0, A=0)"),
  Condition = c("Letter + Shot", "Letter + No Shot", 
                    "No Letter + Shot", "No Letter + No Shot"),
  `Possible Strata` = c("AT or C", "NT or D", "AT or D", "NT or C"),
  Description = c(
    "receive shot, letter sent",
    "does not receive shot, letter sent",
    "receive shot, no letter",
    "does not receive shot, no letter"))

# print strata memberships
memberships |>  kable()
```

3.  For patients in the principal stratum AT, what are possible observed values of (Z, A)?
    -   The always takers will always receive the flu shot regardless of letter encouragement and their possible observed value are as follows:

```r
AT_observable <- tibble(
  `Principal Stratum` = rep("Always-takers (AT)", 2),
  `Letter (Z)` = c(0, 1),
  `Flu Shot (A)` = c(1, 1),
  Description = c("receive shot without letter", 
                  "receive shot with letter")
)

AT_observable |> 
  kable()
```

\newpage

4.  State the assumption of monotonicity and exclusion restrictions. Are they plausible? Why or why not?

    -   The monotinicity assumption (no defier) is defined as:

$$
A^{Z=1} \ge A^{Z=0}
$$

-   Where individuals are at least as likely to receive the flu shot under letter encouragement as without letter encouragement. This implies that there are no defiers. In our case, $P(A=1| Z=1)=.90$ which is $>$ than $P(A=1|Z=0)=.70$.

    -   We would assume that a letter would likely encourage, rather than discourage flu vaccination.

-   Under the exclusion restriction assumption, outcome values are the same with different Z levels.

$$
Y_i^{(z, a)} = Y_i^{(z\prime, a)} \text{for all z,} z\prime \text{, a.} 
$$

-   For never takers or always takers, whose assignment Z value does not affect receiving the treatment $a$, and does not affect the outcome $\theta^1_{NT} = \theta^0_{NT} \text{ , } \theta^1_{AT} = \theta^0_{AT}$. Note, PCE is principle causal effect. PCEs must be 0:

$$
PCE_{NT} = E[Y^1_{NT}] - E[Y^0_{NT}] = 0 \text{ ; } PCE_{AT} = E[Y^1_{AT}] - E[Y^0_{AT}] = 0
$$

\newpage

5.  Use both principal stratification and instrumental variable estimation methods to answer the research question under assumptions of monotonicity and exclusion restriction.

    -   First we need to record the strata proportions, $p_{za}$ that are given to us.
        -   $p_{00} = p(A=N|Z=0) = 0.30$
        -   $p_{01} = p(A=Y|Z=0) = 0.70$
        -   $p_{10} = p(A=N|Z=1) = 0.10$
        -   $p_{11} = p(A=Y|Z=1) = 0.90$
    -   First, we find strata proportions $\pi_S$ using the data we are provided with.
        -   $\pi_{NT} = p_{10} = .1$
        -   $\pi_{AT} = p_{01}=.7$
        -   $\pi_C=p_{11} - p_{01} = .9 - .7 = .2$

```r
p_za <- c(p_00 = 0.30, p_01 = 0.70, p_10 = 0.10, p_11 = 0.90)

strat_probs <- tibble(
  Stratum = c("Never-takers (NT)", 
              "Always-takers (AT)", 
              "Compliers (C)", 
              "Defiers (D)"),
  Z = c(0, 0, 1, 1),
  A = c(0, 1, 0, 1),
  p_za = c(p_00 = 0.30, p_01 = 0.70, p_10 = 0.10, p_11 = 0.90),
  theta_za = c(theta_00 = 0.10, theta_01 = 0.08, 
               theta_10 = 0.20, theta_11 = 0.15),
  pi_za = c(p_za["p_10"], # P(A=0|Z=1)
            p_za["p_01"], # P(A=1|Z=0)
             p_za["p_11"] - p_za["p_01"],  # Compliers
            pi_D = 0  # No defiers 
            )
)

strat_probs |>
  kable()
```

-   Next we must solve the complier outcomes; $\theta^1_C$ and $\theta^0_C$ using the mixture equations and the exclusion restriction.

    -   We need $\theta_{11}$ to solve for $\theta^1_C$, and we are given as .15, which this group is a mix of AT and C. We set up the mixture equation as:

$$
\theta_{11} = (weight_{AT} \times \theta^1_{AT}) + (weight_C \times \theta^1_C)
$$

-   Before we solve for $\theta^1_C$, we must find all known values. The AT rate $\theta^1_{AT}$ is composed of only Z=0, A=1, so $\theta^1_{AT} = \theta_{01} = .08$. We next plug in the numbers for the

$$
weight_{AT} = \frac{\pi_{AT}}{\pi_{AT} + \pi_C} = \frac{.7}{.7+.2} 
$$

-   and for,

$$
weight_C = \frac{\pi_{C}}{\pi_{AT} + \pi_C} = \frac{.2}{.7+.2} 
$$

-   Which we can now plug in the values

$$
.15 = (\frac{.70}{.9}\times .08) + (\frac{.2}{.9} \times \theta^1_C ) 
$$

-   Multiply both sides by .90.

$$
.15 \times .90 = (.7 \times .08) + (.20 \times \theta^1_C) 
$$

$$
.135 = .056 + (.20 \times \theta^1_C) 
$$

-   Subtract both sides from .056

$$
.135 - .056 = .20 \times \theta^1_C
$$

$$
.079 = .20 \times \theta^1_C
$$

-   Divide by .20 to isolate $\theta^1_C$

$$
\theta^1_C = \frac{.079}{.20} = .395
$$

-   The calculated hospitalization rate for compliers who receive the letter is .395 or39.5%.

-   For $\theta^0_C$ (Z=0, A=1) is a mix of NT and C, and we are given $\theta_{00} = .10$, which again we find the unknown values:

$$
\theta_{00} = \frac{\pi_{NT}}{\pi_{NT} + \pi_C} \times \theta^0_{NT} + \frac{\pi_C}{\pi_{NT} + \pi_C} \times \theta^0_C
$$

-   $\theta^0_{NT}$, the potential hospitalization rate of NT under control, so the rate for the compliers using the exclusion restriction is $\theta^0-_{NT} = \theta^1_{NT} = .20$. Next we plug in the numbers again.

$$
.10 = \frac{.1}{.1 + .2} \times .2 + \frac{.2}{.1 +.2} \times \theta^0_C
$$

$$
.10 = \frac{.1}{.3} \times .2 + \frac{.2}{.3} \times \theta^0_C
$$

-   We multiply .3 by both sides.

$$
.10 \times .3 = .1 \times .2 + (.2 \times \theta^0_C)
$$

$$
.03 = .02 + (.2 \times \theta^0_C)
$$

-   Subtract .02 from both sides

$$
.03 - .02 =  .02 - .02 +  (.2 \times \theta^0_C)
$$

$$
.01 = .2 \times \theta^0_C
$$

-   Divide by .2 so isolate theta

$$
\theta^0_C = \frac{.01}{.2} = .05
$$

-   The calculated hospitalization rate for compliers who did not receive the letter is .05 or 5%.

-   Instrumental variable equation

-   The formula for the complier average causal effect (CACE) is shown as:

$$
CACE = \frac{E(Y|Z=1) - E(Y|Z=0) }{ E(A|Z=1) - E(A|Z=0)}
$$

-   Again we plug in the numbers we have been provided as:

    -   $E(Y|Z=1) = (\theta_{10} \times p_{10}) + (\theta_{11} \times p_{11} ) = (.2 \times .1) + (.15 \times .9) = .155$

    -   $E(Y|Z=0) = (\theta_{00} \times p_{00}) + (\theta_{01} \times p_{01} ) = (.1 \times .3) + (.08 \times .7) = .086$

    -   $E(A|Z=1) = p_{11} = .9$

    -   $E(A|Z=1) = p_{01} = .7$

$$
CACE = \frac{.155 - .086}{ .9 - .7 } = .345
$$

-   Finally, we calculate CACE, and we find that both methods ($\theta^1_C - \theta^0_C = .395 - .05 = .345$) agree. Therefore, the letter on hospitalization for compliers is an increase in the probability of hospitalization of 34.5 percentage points.
