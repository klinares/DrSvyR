---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/11_Survival_analysis_In-Class_slides"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "In-Class Lecture 11. Survival Analysis"
original: "stat_mod_ML_2_SURV616/lectures/11 Survival analysis In-Class slides.pdf"
pages: 32
sha256: "e9c33e7f5bd649269b8c742af9996c124c28a336f7831f2d19f63c8d87b244f6"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:19"
---

<!-- page 1 -->

# In-Class Lecture 11. Survival Analysis

Suzer-Gurtekin

April 2025

<!-- page 2 -->

Life Tables
Kaplan-Meier Estimator

# Overview

1. Life Tables and Estimation of the Survivor Function

2. Kaplan-Meier Estimator

2/32 Suzer-Gurtekin Class 11

<!-- page 3 -->

Life Tables
Kaplan-Meier Estimator

# Notation

The basis of survival analysis is the survival function:

$$S(t) = Pr(T > t)$$

In this function, $T$ is the time of the “event.” Also called “failure” or “death”.

And $t$ is a specified time. So this is the probability that the time of death/failure ($T$) is later than the specified time ($t$).

For example, $S(2)$ is the $Pr(T > 2)$, or the probability that death occurs after time 2.

3 / 32
Suzer-Gurtekin
Class 11

<!-- page 4 -->

Life Tables
Kaplan-Meier Estimator

# Example 1

We have a sample size of 10. We have the following observed data:

Table: Example 1 Data

| Case ID | Time of Event ($T$) |
|---:|---:|
| 1 | 5 |
| 2 | 6 |
| 3 | 8 |
| 4 | 18 |
| 5 | 16 |
| 6 | 14 |
| 7 | 7 |
| 8 | 2 |
| 9 | 4 |
| 10 | 9 |

4/32

Suzer-Gurtekin

Class 11

<!-- page 5 -->

Life Tables
Kaplan-Meier Estimator

# Further Notation

The distribution of $T$ has the following **probability density function**:

$f_T(t) \geq 0$ for $t \geq 0$

In this form, we are talking about the probability of failure or death (that's the event which occurs at time $T$).

We assume $T \geq 0$. We also start from the assumption that $T$ is continuous.

5/32 Suzer-Gurtekin Class 11

<!-- page 6 -->

Life Tables
Kaplan-Meier Estimator

# Further Notation

We often look at the **cumulative** distribution function:

$$
F_T(t) = P(T \le t) = \int_0^t f_T(u)du
$$

Again, the is the cumulative probability that death occurs before time $t$.

6/32 Suzer-Gurtekin Class 11

<!-- page 7 -->

Life Tables
Kaplan-Meier Estimator

# Survival Function

Recall the survival function:

$$
S_T(t) = Pr(T > t)
$$

This is the probability that a person lives beyond time $t$.

This is the complement of the CDF we just looked at:

$$
S_T(t) = Pr(T > t) = 1 - Pr(T \leq t) = 1 - F_T(t)
$$

7 / 32 $\quad$ Suzer-Gurtekin $\quad$ Class 11

<!-- page 8 -->

Life Tables
Kaplan-Meier Estimator

# Further Notation

We often assume a parametric form for the CDF. This is denoted $F_T(t|\theta)$.

For example, we might assume that $T \sim N(\mu, \sigma^2)$. In this case, $\theta = (\mu, \sigma^2)$.

8 / 32

Suzer-Gurtekin

Class 11

<!-- page 9 -->

Life Tables
Kaplan-Meier Estimator

# Nonparametric

We will focus on **nonparametric** estimates.

Parametric models give us convenient summaries with few parameters.

But does the model with few parameters fit the data well?

9 / 32 Suzer-Gurtekin Class 11

<!-- page 10 -->

Life Tables
Kaplan-Meier Estimator

# Hazard Function

We can also look at conditional survival probabilities.

These are summarized by the hazard function.

The proportion of those alive at time $t$ that will die before time $t + 1$.

Since time is continuous, we can add any amount of time: $\Delta t$.

10 / 32 Suzer-Gurtekin Class 11

<!-- page 11 -->

Life Tables
Kaplan-Meier Estimator

# Hazard Function

In mathematical notation:$P \{t \le T < t + \Delta t | T \ge t \}$

Since time is continuous, we speak of a limiting hazard rate:

$$h_T (t) = \lim_{\Delta t \to 0} \frac{P \{t \le T < t + \Delta t | T \ge t \}}{\Delta t}$$

It can be shown that the former is equal to:

$$h_T (t) = \frac{f_T (t)}{S_T (t)} = \frac{f_T (t)}{1 - F_T (t)}$$

11 / 32 Suzer-Gurtekin Class 11

<!-- page 12 -->

Life Tables
Kaplan-Meier Estimator

# Summary of Functions

Each of these functions completely describe the distribution of $T$.

Any of these can be transformed into the other forms (see the notes).

12 / 32 Suzer-Gurtekin Class 11

<!-- page 13 -->

Life Tables
Kaplan-Meier Estimator

# Life Tables

Table: Typical Data for Life Table Analysis

| Time Interval (Months) | At Risk | Deaths |
| :---: | :---: | :---: |
| $[0, 2)$ | 300 | 195 |
| $[2, 4)$ | 105 (=300-195) | 27 |
| $[4, 6)$ | 78 | 15 |
| $[6, 8)$ | 63 | 12 |
| $[8, 10)$ | 51 | 9 |
| $[10, 12)$ | 42 | 12 |
| $[12, 14)$ | 30 | |

13 / 32

Suzer-Gurtekin

Class 11

<!-- page 14 -->

Life Tables
Kaplan-Meier Estimator

# Life Tables

In this example, data are broken up into discrete intervals (even though time is continuous).

This is quite common. Many studies only observe units at specified points in time (e.g. every 2 months).

This leads to some issues. If we observe death has occured by $t = 6$, we only know if occurred after $t = 4$ and some time before $t = 6$.

In some problems, the “time” dimension is actually discrete (e.g. calls).

14 / 32

Suzer-Gurtekin

Class 11

<!-- page 15 -->

Life Tables
Kaplan-Meier Estimator

# Life Table Notation

| Notation | Description |
| :--- | :--- |
| $x$ | time at beginning of interval |
| $O_x$ | number *at risk* at exact time $x$ |
| $n$ | length of interval |
| ${}_n d_x$ | number dying in interval $x$ to $x + n$ |
| ${}_n p_x$ | probability of surviving from time $x$ to time $x + n$ |
| ${}_n q_x$ | probability of dying during time $x$ to time $x + n$ |
| ${}_n P_x$ | probability of surviving during time $x$ to time $x + n$<br>(more than one interval) |

15 / 32
Suzer-Gurtekin
Class 11

<!-- page 16 -->

Life Tables
Kaplan-Meier Estimator

# Life Table Notation

Define the probabilities:

$${}_n\hat{q}_x = \frac{{}_nd_x}{O_x}$$

$${}_n\hat{p}_x = 1 - \frac{{}_nd_x}{O_x} = 1 - {}_n\hat{q}_x$$

Therefore ${}_n\hat{p}_x + {}_n\hat{q}_x = 1$. But ${}_n\hat{p}_x + {}_{n+1}\hat{q}_x \neq 1$.

16 / 32
Suzer-Gurtekin
Class 11

<!-- page 17 -->

Life Tables
Kaplan-Meier Estimator

# Life Table Notation

The following is the notation for the probability that a unit will survive one year:

$$
\begin{aligned}
{}_{12}P_{0} &= \prod_{i=0}^{5} {}_{2}p_{2i} = ({}_{2}p_{0})({}_{2}p_{2})({}_{2}p_{4})({}_{2}p_{6})({}_{2}p_{8})({}_{2}p_{10}) \\
&= Pr(\text{Survive to } 2|\text{alive at } 0) \cdot Pr(\text{Survive to } 4|\text{alive at } 2) \cdot \dots
\end{aligned}
$$

In our example, ${}_{4}P_{0} = \frac{300-195}{300} \cdot \frac{105-27}{105} = 0.35 \cdot 0.74 = 0.26$

17/32

Suzer-Gurtekin

Class 11

<!-- page 18 -->

Life Tables
Kaplan-Meier Estimator

# In-Class Example

Table: In-Class Example

| | | | | Probability | |
| :---: | :---: | :---: | :---: | :---: | :---: |
| | | | Dying in interval | Surviving given alive at start of interval | Surviving to end of interval given alive at t=0 |
| $x$ | $O_x$ | $_1d_x$ | $_1\hat{q}_x$ | $_1\hat{p}_x$ | $_{x+1}\hat{P}_0$ |
| 0 | 100 | 10 | | | |
| 1 | 90 | 9 | | | |
| 2 | 81 | 12 | | | |

18 / 32 Suzer-Gurtekin Class 11

<!-- page 19 -->

Life Tables
Kaplan-Meier Estimator

# In-Class Example

Table: In-Class Example

| | | | Probability | | |
| :---: | :---: | :---: | :---: | :---: | :---: |
| | | | Dying in interval | Surviving given alive at start of interval | Surviving to end of interval given alive at t=0 |
| $x$ | $O_x$ | $_1d_x$ | $_1\hat{q}_x$ | $_1\hat{p}_x$ | $_{x+1}\hat{P}_0$ |
| 0 | 100 | 10 | 0.1 | 0.9 | 0.9 |
| 1 | 90 | 9 | 0.1 | 0.9 | 0.81 |
| 2 | 81 | 12 | 0.148148 | 0.851852 | 0.69 |

19 / 32 Suzer-Gurtekin Class 11

<!-- page 20 -->

Life Tables
Kaplan-Meier Estimator

# Censoring

Define notation for withdrawals:

$$
{}_n w_x \qquad \text{number of withdrawals from time } x \text{ to time } x + n
$$

This creates an issue. We don't know when the withdrawal occurred. We can assume they withdrew at the beginning, the end, or in the middle somewhere.

20 / 32 $\qquad$ Suzer-Gurtekin $\qquad$ Class 11

<!-- page 21 -->

Life Tables
Kaplan-Meier Estimator

# Censoring

It matters since it changes the size of the risk set, $O_x$.

If we assume the withdrawals occurred at the *end* of the interval, then the following estimator is close:

$$
{}_2\hat{q}_x \approx \frac{{}_2d_x}{O_x}
$$

If we assume the withdrawals occurred at the *beginning* of the interval, then the following estimator is close:

$$
{}_2\hat{q}_x \approx \frac{{}_2d_x}{O_x - {}_2w_x}
$$

21/32
Suzer-Gurtekin
Class 11

<!-- page 22 -->

Life Tables
Kaplan-Meier Estimator

# Censoring

If we assume that withdrawals are uniformly distributed across the interval, then we might assume that the withdrawals faced half the risk as those who stayed the full interval.

Therefore, reduce the risk set by half the number of withdrawals.

$$
{}_{2}\hat{q}_{x} = \frac{{}_{2}d_{x}}{O_{x} - {}_{2}w_{x}/2}
$$

In the notes, the denominator is re-written as $O'_{x} = O_{x} - {}_{2}w_{x}/2$.

22/32 Suzer-Gurtekin Class 11

<!-- page 23 -->

Life Tables
Kaplan-Meier Estimator

# Variance Estimator

$$\hat{V}\left\{{}_{x+2}\hat{P}_0\right\} = {}_{x+2}\hat{P}_0^2 \sum_{i=1}^{x/2} \frac{{}_2\hat{q}_x}{O'_i - {}_2d_i}$$

Although this may not look like it, in the absence of withdrawals, this is a $\frac{pq}{n}$ kind of thing.

This variance estimator is known as Greenwood's formula.

23 / 32
Suzer-Gurtekin
Class 11

<!-- page 24 -->

Life Tables
Kaplan-Meier Estimator

# Variance Estimator

This uses our two-month interval scheme. A more general formulation denotes each interval $i = 1$ to $I$. Observation starts at time $0$, $i = 0$. Each time point where observations are taken is iterated, but the interval is arbitrary.

We can re-write our formulae using this more general notation for time:

$$\hat{p}_i = 1 - \frac{d_i}{O_i - w_i / 2}$$

$$\hat{P}_I = \prod_{i=1}^I \hat{p}_i$$

$$\hat{V}\left\{\hat{P}_I\right\} = \hat{P}_I^2 \sum_{i=1}^I \frac{\hat{q}_i}{O'_i - d_i}$$

24 / 32

Suzer-Gurtekin

Class 11

<!-- page 25 -->

Life Tables
Kaplan-Meier Estimator

# Kaplan-Meier Estimator

The nonparametric maximum likelihood estimator of the survivor function.

Exact when time of event and withdrawals are known, i.e. the risk set is known.

## Notation

* $i$=specific survival time
* $O_i$=number at risk at time $i$
* $d_i$=number of deaths at time $i$
* $_n\hat{P}_0$=survival function from time $0$ through time $n$

25 / 32
Suzer-Gurtekin
Class 11

<!-- page 26 -->

Life Tables
Kaplan-Meier Estimator

# Kaplan-Meier Estimator

Kaplan-Meier Estimator is:

$$
{}_{n}\hat{P}_{0} = \prod_{i \le n} \left( 1 - \frac{d_{i}}{O_{i}} \right)
$$

The variance estimator is:

$$
\hat{V}\left\{{}_{n}\hat{P}_{0}\right\} = {}_{n}\hat{P}_{0}^{2} \sum_{i=1}^{n} \frac{d_{i}}{O_{i}\left(O_{i} - d_{i}\right)}
$$

26 / 32
Suzer-Gurtekin
Class 11

<!-- page 27 -->

Life Tables
Kaplan-Meier Estimator

# Example 3

Two treatments for acute leukemia. The table lists times to event or censoring (the asterisk indicates cases that were censored).

| | Data for Example 3 |
| :--- | :--- |
| 6-MP | $6, 6, 6, 6^*, 7, 9^*, 10, 10^*, 11^*, 13, 16, 17^*, 19^*, 20^*, 22, 23, 25^*, 32^*, 32^*, 34^*, 35^*$ |
| Placebo | $1, 1, 2, 2, 3, 4, 4, 5, 5, 8, 8, 8, 8, 11, 11, 12, 12, 15, 17, 22, 23$ |

27 / 32 Suzer-Gurtekin Class 11

<!-- page 28 -->

Life Tables
Kaplan-Meier Estimator

# Example 3

Estimation of Survival Function for Example 3

| Drug 6-MP | | | | Placebo | | | |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Time | $O_i$ | $d_i$ | ${}_i\hat{P}_0$ | Time | $O_i$ | $d_i$ | ${}_i\hat{P}_0$ |
| 6 | 21 | 3 | 0.857 | 1 | 21 | 2 | 0.905 |
| 7 | 17 | 1 | 0.807 | 2 | 19 | 2 | 0.810 |
| 10 | 15 | 1 | 0.753 | 3 | 17 | 1 | 0.762 |
| 13 | 12 | 1 | 0.690 | 4 | 16 | 2 | 0.667 |
| 16 | 11 | 1 | 0.627 | 5 | 14 | 2 | 0.571 |
| 22 | 7 | 1 | 0.538 | 8 | 12 | 4 | 0.381 |
| 23 | 6 | 1 | 0.448 | 11 | 8 | 2 | 0.286 |
| | | | | 12 | 6 | 2 | 0.190 |
| | | | | 15 | 4 | 1 | 0.143 |
| | | | | 17 | 3 | 1 | 0.095 |
| | | | | 22 | 2 | 1 | 0.048 |
| | | | | 23 | 1 | 1 | 0.000 |

28 / 32 $\qquad$ Suzer-Gurtekin $\qquad$ Class 11

<!-- page 29 -->

Life Tables
Kaplan-Meier Estimator

# In-Class Problem: Example 3

Fill in the $Var(_i\hat{P}_0)$ column:

Table: Example 3 Data: Drug 6-MP

| Time | $O_i$ | $d_i$ | $_iP_0$ | $Var(_i\hat{P}_0)$ |
| ---: | ---: | ---: | ---: | ---: |
| 6 | 21 | 3 | 0.857 | |
| 7 | 17 | 1 | 0.807 | |
| 10 | 15 | 1 | 0.753 | |

29 / 32 Suzer-Gurtekin Class 11

<!-- page 30 -->

Life Tables
Kaplan-Meier Estimator

# In-Class Problem: Example 3

Fill in the $Var(_i\hat{P}_0)$ column:

Table: Add caption

| Time | $O_i$ | $d_i$ | $_iP_0$ | $Var(_i\hat{P}_0)$ |
| ---: | ---: | ---: | ---: | ---: |
| 6 | 21 | 3 | 0.857 | 0.005829 |
| 7 | 17 | 1 | 0.807 | 0.007563 |
| 10 | 15 | 1 | 0.753 | 0.009285 |

30 / 32
Suzer-Gurtekin
Class 11

<!-- page 31 -->

Life Tables
Kaplan-Meier Estimator

# Example 3

6-MP
Placebo

Survival Probability
0.0 0.2 0.4 0.6 0.8 1.0

Weeks
0 5 10 15 20 25 30 35

31 / 32 Suzer-Gurtekin Class 11

<!-- page 32 -->

Life Tables
Kaplan-Meier Estimator

# Example 3

R code to get the KM estimator and Survival Plot:

```r
#coding is for the event, 1=event, 0=censored
#The variable that I have is for censoring.
library(survival)
example3$event <-abs(example3$censored-1)

surv1 <- survfit(Surv(weeks, event)~ group,
    conf.type="none",data=example3)
surv1
summary(surv1)
plot(surv3, xlab="Weeks",
   ylab="Survival Probability",
   conf.int=FALSE,lty=2:3)
legend(20, .9, c("6-MP", "Placebo"),lty=2:3)
```

32 / 32

Suzer-Gurtekin

Class 11
