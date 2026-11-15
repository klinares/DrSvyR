---
id: "jpsm/Fund_Infe_SURV740/lectures/Module_Causal_Inf5_YL-1"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "<u>Principal stratification</u>"
original: "Fund_Infe_SURV740/lectures/Module Causal Inf5 YL-1.pdf"
pages: 44
sha256: "4593c387034b1e0071dda68e8fd3b4a0a566023d63dd4a18aac17add87aa8a58"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:03"
---

<!-- page 1 -->

# <u>Principal stratification</u>

DB Rubin 2006 *Statistical Science* 3: 299-309

<!-- page 2 -->

## Example1: Truncation due to death

$Z$=treatment assignment

$A$=survival: Living (L) or Dead (D)

$Y$=quality of life (QOL, not available if Dead)

$\rightarrow Y$ defined only if $A=L$ (no quality of life for dead people)

* Two *potential* values for $A$, denoted by $A^1$ and $A^0$, $A$ is the observed version of the potential values for $A$
* Two *potential* values for $Y$, denoted by $Y^1$ and $Y^0$, $Y$ is the observed version of the potential outcomes

**Questions:** Can we estimate **causal effect of Z on Y** by comparing QOL ($Y$) between $Z=0$ vs. $Z=1$ among survivors ($A=L$) by $E[Y=1|Z=1, A=L] - E[Y=1|Z=0, A=L]$? Next 10 slides

<!-- page 3 -->

| | | Untreated group $Z=0$ | |
| :--- | :--- | :---: | :---: |
| | | Dead $A=D$ | Living $A=L$ |
| Treated group $Z=1$ | Dead $A=D$ | Always Dead (DD) | Living if not untreated; *Dead* if treated (LD) |
| | Living $A=L$ | *Dead* if not treated; Living if treated (DL) | Always Living (LL) |

* Four principal strata: DD, LD, DL, LL
* Observed group ($Z=0$ & $A=L$) $\leftrightarrow$ units in LL and LD
* Observed group ($Z=1$ & $A=L$) $\leftrightarrow$ units in LL and DL

---

* $Y$ is undefined for units in LD if treated ($Z=1$)
* $Y$ is undefined for units in DL if not treated ($Z=0$)
* $Y$ is defined for units in LL only

Casual effect of $Z$ on $Y$ is conceivable among units in stratum **LL** only.

<!-- page 4 -->

### Table 1. Principal strata among patients in the **population**

| Principal Stratum | % Population | Untreated $A^0$ | Untreated $Y^0$ | Treated $A^1$ | Treated $Y^1$ | Treatment effect on QOL |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| LL | 20 | L | 700 | L | 900 | 200 |
| DL | 40 | D | * | L | 600 | * |
| LD | 20 | L | 800 | D | * | * |
| DD | 20 | D | * | D | * | * |

* The DL units are those who would die if untreated but live if treated, and they comprise 40% of the population. If these units were all treated, their average QOL would be 600, which is poor, but if they were not treated, they would die. So, their QOL is undefined. The same for principal strata LD or DD.
* *Recall:* Causal effect must be a comparison of potential treated outcomes, $Y^1$, and potential control outcomes, $Y^0$, on the same subset of units, here the set of **LL** units.
* <u>For Quality of Life (QOL), the active treatment is better for LL units</u>. The survivor average causal effect is 200.

<!-- page 5 -->

Table 1 (cont.):

* <u>For overall survival, the active treatment is better than the control (untreated)</u> because 60% would survive when treated while 40% would survive when untreated.

  $\rightarrow$ Active treatment is preferable for the population.

<!-- page 6 -->

In reality, the entire population is unavailable.

* Suppose a **completely randomized experiment** to get a random **sample** from this population
* Within each stratum, *half* randomized to active treatment and *half* randomized to the control group.

Principal strata, each split by treatment assignment Z

| % **Sample** | Principal Stratum | Assignment Z | Untreated $A^0$ | Untreated $Y^0$ | Treated $A^1$ | Treated $Y^1$ | Treatment Effect on QOL |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 10 | LL | T | L | 700 | L | 900 | 200 |
| 10 | LL | C | L | 700 | L | 900 | 200 |
| 20 | DL | T | D | \* | L | 600 | \* |
| 20 | DL | C | D | \* | L | 600 | \* |
| 10 | LD | T | L | 800 | D | \* | \* |
| 10 | LD | C | L | 800 | D | \* | \* |
| 10 | DD | T | D | \* | D | \* | \* |
| 10 | DD | C | D | \* | D | \* | \* |

Q: what are observable potential values in A and Y in Table 2?

<!-- page 7 -->

### Table 2. Principal strata, each split by treatment assignment Z

| % Sample | Principal Stratum | Assignment Z | Untreated $A^0$ | Untreated $Y^0$ | Treated $A^1$ | Treated $Y^1$ | Treatment Effect on QOL |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 10 | LL | T | L | 700 | L | 900 | 200 |
| 10 | LL | C | L | 700 | L | 900 | 200 |
| 20 | DL | T | D | \* | L | 600 | \* |
| 20 | DL | C | D | \* | L | 600 | \* |
| 10 | LD | T | L | 800 | D | \* | \* |
| 10 | LD | C | L | 800 | D | \* | \* |
| 10 | DD | T | D | \* | D | \* | \* |
| 10 | DD | C | D | \* | D | \* | \* |

Rearrange so that rows that have the same observed values of treatment assignment (Z) and survival status (A) are adjacent

<!-- page 8 -->

Table 3. Permuted Table2 for principal strata among patients

| % Sample | Principal Stratum | Assignment Z | Untreated $A^0$ | Untreated $Y^0$ | Treated $A^1$ | Treated $Y^1$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 10 | LL | T | L | 700 | L | 900 |
| 20 | DL | T | D | * | L | 600 |
| 10 | LD | T | L | 800 | D | * |
| 10 | DD | T | D | * | D | * |
| 10 | LL | C | L | 700 | L | 900 |
| 10 | LD | C | L | 800 | D | * |
| 20 | DL | C | D | * | L | 600 |
| 10 | DD | C | D | * | D | * |

Q1: What is the survival rate in the treated group? In the control group?

Q2: What is the average of QOL for those who are (or not) treated and lived?

<!-- page 9 -->

* For the first pair of rows, i.e. people who got treated and lived comprise $30\%$ of the sample in the experiment. The average QOL for this group will be a mixture of LL ($10/30$) and DL ($20/30$), that is, so the observed average for those who got treated and lived will equal $\underline{700 \ (=1/3*900+2/3*600)}$.
* For the second pair of rows, we have that units who are treated and die, comprising $20\%$ of the population, and $40\%$ in the treated.
* For the third pair of rows, units are untreated and live, comprising $20\%$ of the population. The survival rate $40\%$ among the untreated. The average QOL is $\underline{750}$, which arises from $1/2+1/2$ mixture of LL and LD with means $700$ and $800$, respectively.
* The last pair of rows was untreated and die, comprising $30\%$ of the population and $60\%$ in the untreated.

<!-- page 10 -->

### Table 4. **Findings** from complete randomized experiment

| % **Sample** | Assignment $Z$ | Control $A^0$ | Control $Y^0$ | Treatment $A^1$ | Treatment $Y^1$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 30 | T | ? | ? | L | 700 |
| 20 | T | ? | ? | D | * |
| 20 | C | L | 750 | ? | ? |
| 30 | C | D | * | ? | ? |

* 60% survive when treated (=30/50) vs. 40% when untreated (=20/50), same as in the population (Table1)
* Observed average of QOL is 700 for treated survivors < observed average of 750 for untreated survivors, different from Table1
  $$E[Y=1|Z=1, A=L] - E[Y=1|Z=0, A=L] \text{ estimated by } -50$$

$\rightarrow$ Although the active treatment is good for survival, the QOL of the treated is not as good as QOL if not treated – Misleading!!

We know from Table 1 (population) that the causal effect of the active treatment vs. the control on QOL is positive +200 for the LL group, which is the only group for which QOL is well defined.

<!-- page 11 -->

* **What was wrong**? – NOT comparing the common subset of units
  * $\text{QOL}=700$ comes from mixture of LL ($1/3$) and DL ($2/3$)
  * $\text{QOL}=750$ comes from mixture of LL ($1/2$) and LD ($1/2$)

* **What should we do**?
  * If we know the people’s principal strata, simply analyze the data within each stratum
  * But we don’t know, as shown in Table 5 below, each observed group comprises mixture people from two latent principal strata

Table 5. Group classification based on observed treatment assignment and observed survival indicator OBS (Z, A)

| Observed group OBS(Z, A) | Assignment Z | Observed $A$ | Observed Y | Possible Latent Principal Strata | |
| :---: | :---: | :---: | :---: | :---: | :---: |
| OBS(Trt, L) | T | L | $\in \text{R}$ | LL | DL |
| OBS(Trt, D) | T | D | * | LD | DD |
| OBS(Cntl, L) | C | L | $\in \text{R}$ | LL | LD |
| OBS(Cntl, D) | C | D | * | DL | DD |

<!-- page 12 -->

## **<u>Principal Stratification Method:</u>**
### Basic set up in terms of data
* $Z$ = *randomization* to treatment (all pre-treatment variables are balanced among treatment groups)
* $A$ = Compliance or receipt of *assigned* treatment (intermediate variable: post-treatment variable is not balanced by randomization)
* $Y$ = Outcome of interest
* $X$ = Baseline covariates

**Randomization:** $Z \perp \{Y^1, Y^0, A^1, A^0\}$

**Question:** Can we estimate a causal effect of treatment assignment $Z$ on the outcome $Y$ by <u>controlling for the intermediate variable $A$</u>? NO

<!-- page 13 -->

# Post-treatment Bias

Why should we <u>not</u> condition on post-treatment covariate A?

Write:

$$
\tau = E(Y^1) - E(Y^0) = E_A[E(Y^1|A, Z = 1) - E(Y^0|A, Z = 0)],
$$

where $A$ is affected by Z. The observed $A$ is thus written as

$$
A = I\{Z = 1\}A^{Z=1} + I\{Z = 0\}A^{Z=0}
$$

Therefore,

$$
\tau' = E_{A^1}[E(Y^1|A^1, Z = 1)] - E_{A^0}[E(Y^0|A^0, Z = 0)]
$$

We have **mismatch** problem:

* $\tau'$ is unbiased only if $pr(A^{Z=1}) = pr(A^{Z=0})$, implies Z has no effect on $A$. This, however, is against the fact that A is affected by Z: "$Z \rightarrow A$." Since $pr(A^{Z=1}) \neq pr(A^{Z=0})$, $\tau'$ is biased of $\tau$.

<!-- page 14 -->

**Solution**: define strata by potential values of the post-treatment variable $A$ **<u>- Principal Strata</u>**

| | | $Z=0$: assigned to control treatment | |
| :--- | :--- | :---: | :---: |
| | | $A=0$: receive control treatment | $A=1$: receive active treatment |
| $Z=1$: assigned to active treatment | $A=0$: receive control treatment | Never-taker (NT) | Defier (D) |
| | $A=1$: receive active treatment | Complier (C) | Always-taker (AT) |

<!-- page 15 -->

**Four principal strata (compliance classes)** defined in above table:

* AT: those who always receive the active treatment regardless of which treatment they were assigned
* C: those who would receive the assigned treatment
* D: those who would receive the opposite of the assigned treatment
* NT: those who always receive the control treatment regardless of which group they were assigned

<!-- page 16 -->

### Key features:

* Principal strata are defined by the two potential values of the intermediate variable $A$ under $Z=0$ or $Z=1$ (i.e., $A^0 A^1$)
* Principal strata are latent classes since only **one** of potential values of the intermediate variable $A$ are observable.
* The observed values of $Z$ and $A$ don't identify the stratum. For example, those who are *assigned* to active treatment ($Z=1$) and *receive* active treatment ($A=1$) can be: AT or C
* Causal effects of $A$ on $Y$, conditional on observed value of $Z$, are *nonsense* since different strata of people are compared for $A=1$ vs. $A=0$.

*For example*, conditional on $Z=1$, that is, among those who are assigned to active treatment, compare $A=1$ (AT & C) vs. $A=0$ (NT & D).

* Causal effects of $Z$ on $Y$, conditional on observed value of $A$, are also *nonsense* since different strata of people are compared for $Z=1$ vs. $Z=0$.

*For example*, conditional on $A=1$, that is, among those who received the active treatment, compare $Z=1$ (AT & C) vs. $Z=0$ (AT & D).

---

<!-- page 17 -->

# Key features (cont.):

* The principal strata comprise units with the same values of $(A^0, A^1)$ - Frangakis and Rubin, 2002
  * The value of the $(A^0, A^1)$ is not affected by treatment assignment
  * Principal stratum membership only reflects subject’s characteristics: it is a **pre-treatment variable**
* <u>Randomization</u>: guarantees treatment assignment Z independent of pre-treatment variables, including principal stratum membership

$$Z \perp (Y^0, Y^1) | X, (A^0, A^1)$$

Treated and control units can be compared conditional on a principal stratum – average Principal Causal Effect (**PCE**).

<!-- page 18 -->

## Exercise:

$Z$: Job training program enrolled ($Z=1$) and not ($Z=0$)

$A$: Employment status – Intermediate variable,

Employed ($A=E$) or not ($A=N$)

$Y$: Wage (not available if $A=0$)

### Questions:

* Define the four latent principal strata
* You observe a group of person who enrolled in the job-training program and got employed. What are their principal strata memberships?
* For people in the principal stratum AT, what are their observed values of $(Z, A)$?

<!-- page 19 -->

# 4 Principal Strata

| | | Not Enrolled in the Job training program $Z=0$ | |
| :--- | :--- | :---: | :---: |
| | | **Not Employed**<br>$A=N$ | **Employed**<br>$A=E$ |
| **Enrolled in the Job training program** $Z=1$ | **Not Employed**<br>$A=N$ | Never<br>Employed (NN) | Employed if<br>not trained<br>(EN) |
| | **Employed**<br>$A=E$ | Employed if trained<br>(NE) | Always<br>Employed<br>(EE) |

<!-- page 20 -->

* The four principal strata are defined by the two potential values of the intermediate variable $A$ (employed or not):

$$
(A^0A^1) = (\text{NN}, \textbf{EN}, \text{NE}, \text{EE}).
$$

E.g. **EN** includes the units who become employed ($A^0 = \textbf{E}$) if NOT trained and unemployed ($A^1 = \textbf{N}$) if enrolled in the training program.

* Observed group, say the group with ($Z=1$ and $A=\text{E}$), are comprised of mixtures of principal strata **EE** and **NE**

* Units in EE are always employed, coming from the group with ($Z=1$ and $A=\text{E}$) or ($Z=0$ and $A=\text{E}$)

<!-- page 21 -->

# Example 2 – Calculation of PCE

In 2002, Mayor Bloomberg and NYC Schools Chancellor Joel Klein launched a series of inter-related high school reforms, which included:

* Closure of 31 low-performing large high schools
* Creation of more than 200 new small schools

Small schools of choice (SSCs)

* Created between 2002-2008 as part of a highly competitive proposal process
* Received ‘special supports’ during start up from the NYCDOE and philanthropic organizations
* Are available to students of all academic backgrounds
* Are small personalized and typically themed
* Are located mainly in poor communities where large, low-performing neighborhood high schools had been closed

<!-- page 22 -->

Study the effects of SSCs on students' performance using:

- A large sample (14,608 students from four annual cohorts, across 84 SSCs) –treated as *randomized clinical trial*
- A variety of student outcomes (smooth transition into high school, four-year graduation rates by diploma type, college readiness in math and English language arts and post-secondary enrollment)

Findings indicate that SSCs:

- Increase the proportion of students on track at <u>the end of 9<sup>th</sup> grade</u>
- Increase the proportion of students that graduate high school <u>after four years</u>, for a broad range of student subgroups

<!-- page 23 -->

# Research questions:

Are the impacts of SSCs on timely high school graduation largest for <u>those</u> <u>students who are induced by the SSC offer to be “on track” at the end of 9<sup>th</sup> grade</u>?

In another words,

Are <u>students</u> graduating from high school at higher rates because they were “on track” at higher rates at the end of 9<sup>th</sup> grade due to SSC offer?

<!-- page 24 -->

- $Z$: random assignment ($=0$ for control; $1$ for SSC offered)
- $A$: end of $9^{\text{th}}$ grade academic status ($=N$ for off track; $Y$ for on track)
- $Y$: high school graduation status
- $S$: principal stratum membership in stratum AT, C, NT, D

**Assume monotonicity, also called no-defier:**

$$A^{Z=1} \geq A^{Z=0}$$

  - Individuals are at least as likely to receive treatment when randomized to treatment $Z=1$, as compared to $Z=0$
  - No one consistently does the opposite of what they are told. This assumption rules out the possibility of ‘defiers’

$\rightarrow$ proportion share in each principal stratum estimable

The students are at least as likely to be on track at $9^{\text{th}}$ grade when offered SSC, compared to without SSC offer.

<!-- page 25 -->

Define:

* $\pi_S$: proportion of students in principal stratum S = {NN, YN, NY, or YY}, **latent**
* $p_{za}$: proportion of students of having $9^{\text{th}}$-grade status $a$ (=0 or 1) among those assigned to treatment group z (=0 or 1), **observed**

$$p_{10} + p_{11} = 1; p_{00} + p_{01} = 1;$$

$$p_{10} = .35; p_{11} = .65; p_{00} = .49; p_{01} = .51$$

| | | No SSC offer Z=0 | |
| :--- | :--- | :---: | :---: |
| | | Off track A=N: $p_{00} = .49$ | On track A=Y: $p_{01} = .51$ |
| SSC offer Z=1 | Off track A=N: $p_{10} = .35$ | Never on track (NN): $\pi_{NN}$ | Induced off track (YN): $\pi_{YN}$ |
| | On track A=Y: $p_{11} = .65$ | Induced on track (NY): $\pi_{NY}$ | Always On-track (YY): $\pi_{YY}$ |

<!-- page 26 -->

With the assumption of **monotonicity** $\pi_{YN} = 0$

$$\pi_{NN} + \pi_{NY} + \pi_{YY} = 1;$$

| | | No SSC offer<br>Z=0 | |
| :--- | :--- | :---: | :---: |
| | | Off track<br>A=N:<br>$p_{00}=.49$ | On track<br>A=Y:<br>$p_{01}=.51$ |
| SSC offer<br>Z=1 | Off track<br>A=N:<br>$p_{10}=.35$ | Never on<br>track<br>(NN): $\pi_{NN}$ | Induced off<br>track (YN):<br>$\pi_{YN} = 0$ |
| | On track<br>A=Y:<br>$p_{11}=.65$ | Induced on<br>track<br>(NY): $\pi_{NY}$ | Always<br>On-track<br>(YY): $\pi_{YY}$ |

$\rightarrow \pi_{NN} = .35; \;\; \pi_{YY} = .51; \;\; \pi_{NY} = .49 - .35 = .14$

<!-- page 27 -->

**Question**: What is the treatment ($Z=\text{SSC}$) effect on the outcome ($Y=\text{graduation status}$) in each stratum, *PCEs*?

Define:

$\theta_{za}$ is the $\text{pr}(Y=1)$ high school <u>graduation rate</u> among students who have treatment $Z=z$ and $9^{\text{th}}$ grade academic status $A=a$

- **observed** $\theta_{00} = .34; \theta_{01} = .86; \theta_{10} = .38; \theta_{11} = .89$

$\theta_s^z$ is the $\text{pr}(Y=1)$ high school <u>graduation rate</u> if students have treatment $Z=z$ in the principal stratum $s$ – **latent,** how to estimate?

<!-- page 28 -->

| | | No SSC offer: Z=0 | |
| :--- | :--- | :---: | :---: |
| | | Off track<br>A=N:<br>$p_{00}=.49$<br>$\theta_{00} = .34$ | On track<br>A=Y:<br>$p_{01}=.51$<br>$\theta_{01} = .86$ |
| SSC offer<br>Z=1 | Off track A=N:<br>$p_{10} = .35$<br>$\theta_{10} = .38$ | Never on track<br>(NN): $\pi_{NN} = .35$<br>$\theta_{NN}^1$ $\theta_{NN}^0$ | Induced off track<br>(YN): $\pi_{YN} = 0$ by<br>monotonicity |
| | On track A=Y:<br>$p_{11} = .65$<br>$\theta_{11} = .89$ | Induced on track<br>(NY): $\pi_{NY} = .14$<br>$\theta_{NY}^1$ $\theta_{NY}^0$ | Always On-track<br>(YY): $\pi_{YY} = .51$<br>$\boldsymbol{\theta}_{YY}^1$ $\boldsymbol{\theta}_{YY}^0$ |

Students who have no SSC offer (Z=0) but on track in 9-grade status (A=Y) are Always On-Trackers because there is no Defiers by monotonicity. Therefore, the observed group mean $\theta_{01} = .86$ is the graduation rate if no SSC offer, $\theta_{YY}^0$, that is, $\theta_{YY}^0 = .86$. What is $\theta_{YY}^1 = ?$

<!-- page 29 -->

The observed graduation rate for units with $Z=1$ & on track $A=Y$ is

$$0.89 = \theta_{11} = (1 - \phi_1)\theta_{NY}^1 + \phi_1\theta_{YY}^1 \text{ with}$$

$$\phi_1 = \frac{\pi_{YY}}{\pi_{YY} + \pi_{NY}} = \frac{.51}{.51 + .14} = .785; \ \theta_{11} = .89$$

$$\boxed{\rightarrow \theta_{YY}^1 = \frac{1}{\phi_1}\theta_{11} - \frac{(1 - \phi_1)}{\phi_1}\theta_{NY}^1 = 1.134 - .274\theta_{NY}^1}$$

There is a linear relationship between these two stratum-specific quantities $\theta_{YY}^1$ and $\theta_{NY}^1$. Therefore, we can investigate the values that they can take on.

* When $\theta_{NY}^1=0$, $\theta_{YY}^1=1.134$, truncated to $1$ since $0 < \theta_{YY}^1 < 1$
* When $\theta_{NY}^1=1$, $\theta_{YY}^1=.86$

$$\text{Therefore, } .86 \le \theta_{YY}^1 \le 1$$

<!-- page 30 -->

Similarly,

$$\rightarrow \boxed{\theta_{NY}^1 = \frac{1}{1 - \phi_1} \theta_{11} - \frac{\phi_1}{1 - \phi_1} \theta_{YY}^1 = 4.132 - 3.643\theta_{YY}^1}$$

- When $\theta_{YY}^1=0$, $\theta_{NY}^1=4.132$, truncated to 1 since $0 < \theta_{NY}^1 < 1$
- When $\theta_{YY}^1=1$, $\theta_{NY}^1=.49$

Therefore, $.49 \le \theta_{NY}^1 \le 1$

<!-- page 31 -->

| | | No SSC offer Z=0 | |
| :--- | :--- | :---: | :---: |
| | | Off track<br>A=N: $p_{00} = .49$<br>$\theta_{00} = .34$ | On track<br>A=Y: $p_{01} = .51$<br>$\theta_{01} = .86$ |
| SSC offer Z=1 | Off track<br>A=N:<br>$p_{10} = .35$<br>$\theta_{10} = .38$ | Never on track<br>(NN): $\pi_{NN} = .35$<br>$\theta_{NN}^1 = .38$<br>$\theta_{NN}^0 \in (.176, .476)$ | Induced off track (YN):<br>$\pi_{YN}$ |
| | On track<br>A=Y:<br>$p_{11} = .65$<br>$\theta_{11} = .89$ | Induced on track<br>(NY): $\pi_{NY} = .14$<br>$\theta_{NY}^1 \in (.49, 1)$<br>$\theta_{NY}^0 \in (0, 1)$ | Always<br>On-track (YY): $\pi_{YY} = .51$<br>$\theta_{YY}^1 \in (.86, 1)$<br>$\theta_{YY}^0 = .86$ |

Analogously, bounds for $\theta_{NN}^0$ and $\theta_{NY}^0$ are calculated (HW: validate the results in the table above)

<!-- page 32 -->

Solving for all stratum-specific treatment effects:

$$PCE_{NN} = \theta_{NN}^1 - \theta_{NN}^0 \in$$

$$(.38 - .476 = -.096, .38 - .176 = .204) = (-.096, .204)$$

$$PCE_{YY} = \theta_{YY}^1 - \theta_{YY}^0 \in$$

$$(.86 - .86 = 0, 1 - .86 = .14) = (0, .14)$$

$$PCE_{NY} = \theta_{NY}^1 - \theta_{NY}^0 \in$$

$$(.49 - 1, 1 - 0) = (-.51, 1)$$

<!-- page 33 -->

## Assuming monotonicity average potential outcomes:

$$\theta_{YY}^1 > \theta_{11} > \theta_{NY}^1; \; \theta_{NY}^0 > \theta_{00} > \theta_{NN}^0$$

That is, assuming

* ATs have higher graduation rate than Compliers among students who are offered SSC and $9^{\text{th}}$-grade on track (Z=1&A=1)
* Compliers have higher graduation rates than NTs among students who are not offered SSC and $9^{\text{th}}$ grade off track (Z=0&A=0)

Therefore,

$$\boxed{\theta_{NN}^0 \in (.176, .34); \; \theta_{NY}^0 \in (.34, 1); \theta_{NY}^1 \in (.49, .89); \; \theta_{YY}^1 \in (.89, 1)}$$

$$PCE_{NN} = \theta_{NN}^1 - \theta_{NN}^0 \in (.38 - .34, .38 - .176) = (.04, .204)$$

$$PCE_{YY} = \theta_{YY}^1 - \theta_{YY}^0 \in (.89 - .86, 1 - .86) = (.03, .14)$$

$$PCE_{NY} = \theta_{NY}^1 - \theta_{NY}^0 \in (.49 - 1, .89 - .34) = (-.51, .55)$$

<!-- page 34 -->

# Instrumental Variable Method

<!-- page 35 -->

## Instrumental Variables (IV)

* IV affect treatment, but does not (directly) affect the outcome

* Randomly assigned as part of the study or believed to be randomized in nature,
  For example,
  * Quarter of birth (affect education, but not Wages)
  * Rainfall (affect students’ attendance, but not Test Score)

<!-- page 36 -->

## Assumptions:

In addition to **Randomization** and **Monotonicity**, IV variable Z affects the outcome only through its effect on treatment (intermediate A); known as the [**exclusion restriction**](#)

$$
\begin{array}{ccccc}
Z & \longrightarrow & A & \longrightarrow & Y \\
& & \nwarrow & & \nearrow \\
& & & X &
\end{array}
$$

* IV variable Z must NOT directly affect Y
* IV variable Z must NOT indirectly affect Y through its effect on other unmeasured confounders U

Z must not affect unmeasured confounders

$$
\begin{array}{ccccc}
& & & U & \\
& \not\nearrow & \swarrow & & \searrow \\
Z & \longrightarrow & A & \longrightarrow & Y \\
& & \nwarrow & & \nearrow \\
& & & X &
\end{array}
$$

<!-- page 37 -->

### Under Exclusion Restriction Assumption:

Outcome values are same with different $Z$ levels. That is,

$$
Y_i^{(z,a)} = Y_i^{(z',a)} \text{ for all } z, z', a.
$$

For never takers (NT) or always takers (AT), whose assignment $Z$ value does not affect the receipt of the treatment $a$, and therefore doesn’t affect the outcome, that is,

$$
PCE_{NT} = PCE_{AT} = 0
$$

<!-- page 38 -->

IV method estimate the causal effect of <u>treatment **received** status $A$ on the outcome $Y$</u>

- e.g., $Z$ can be thought of as encouragement to receive the treatment
- It can be an Instrumental Variable if $Z$ doesn't affect $Y$
- IV methods do not focus on the average causal effect for the population, but focus on a *local* average causal effect
  - Known as *complier* average causal effect (CACE): in a subpopulation
  - No inference about defiers, always-takers, or never takers

<!-- page 39 -->

**Instrumental Variable Estimator:**

The IV estimator is a consistent estimator of *complier average causal effect* (CACE), with Z the IV, given by

$$\text{CACE} = \frac{E(Y|Z = 1) - E(Y|Z = 0)}{E(A|Z = 1) - E(A|Z = 0)}$$

$$= \frac{\text{causal effect of trtment assignment on Y}}{\text{causal effect of trtment assignment on A}}$$

Why?

<!-- page 40 -->

# Identification of causal effects:

$$E(Y|Z = 1) - E(Y|Z = 0)$$

$$= \sum_{s} [E(Y|Z = 1, s) - E(Y|Z = 0, s)]\pi_s$$

$$= PCE_{NT}\pi_{NT} + PCE_{AT}\pi_{AT} + CACE \times \pi_{compliers}$$

$$= CACE \times \pi_{compliers}$$

$$CACE = \frac{E(Y|Z = 1) - E(Y|Z = 0)}{\pi_{compliers}} = \frac{E(Y|Z = 1) - E(Y|Z = 0)}{E(A|Z = 1) - E(A|Z = 0)}$$

- $E(A|Z = 1)$: Proportion of people who are AT or Complier
- $E(A|Z = 0)$: Proportion of people who are AT

$P(compliers) = E(A|Z = 1) - E(A|Z = 0)$ the difference is the proportion of people who are compliers.

<!-- page 41 -->

# Connection between principal stratification (PS) and Instrumental Variable Methods

Back to our numerical example

| | | No SSC offer<br>$Z=0$ | |
| :--- | :--- | :---: | :---: |
| | | Off track<br>$A=N$: $p_{00}=.49$<br>$\theta_{00} = .34$ | On track<br>$A=Y$: $p_{01}=.51$<br>$\theta_{01} = .86$ |
| SSC offer<br>$Z=1$ | Off track<br>$A=N$:<br>$p_{10}=.35$<br>$\theta_{10} = .38$ | Never on track<br>(NN):<br>$\pi_{NN} = .35$<br>$\theta_{NN}^1, \theta_{NN}^0$ | Induced off<br>track (YN): $\pi_{YN}$ |
| | On track<br>$A=Y$:<br>$p_{11}=.65$<br>$\theta_{11} = .89$ | Induced on track<br>(NY):<br>$\pi_{NY} = .14$<br>$\theta_{NY}^1, \theta_{NY}^0$ | Always<br>On-track (YY):<br>$\pi_{YY} = .51$<br>$\theta_{YY}^1, \theta_{YY}^0$ |

<!-- page 42 -->

Assuming exclusion restriction:

$\theta_{NN}^1 = \theta_{NN}^0 = .38$ and $\theta_{YY}^1 = \theta_{YY}^0 = .86$.

| | | No SSC offer $Z=0$ | |
| :--- | :--- | :---: | :---: |
| | | Off track<br>$A=N$: $p_{00}=.49$<br>$\theta_{00} = .34$ | On track<br>$A=Y$: $p_{01}=.51$<br>$\theta_{01} = .86$ |
| **SSC offer**<br>$Z=1$ | Off track<br>$A=N$:<br>$p_{10}=.35$<br>$\theta_{10} = .38$ | Never on track<br>(NN):<br>$\pi_{NN} = .35$<br>$\theta_{NN}^1 = \theta_{NN}^0 = .38$ | Induced off<br>track (YN): $\pi_{YN}$ |
| | On track<br>$A=Y$:<br>$p_{11}=.65$<br>$\theta_{11} = .89$ | Induced on track<br>(NY):<br>$\pi_{NY} = .14$<br>$\theta_{NY}^1, \theta_{NY}^0$ | Always<br>On-track (YY):<br>$\pi_{YY} = .51$<br>$\theta_{YY}^1 = \theta_{YY}^0 = .86$ |

<!-- page 43 -->

Now we only need to estimate $\theta_{NY}^0$ and $\theta_{NY}^1$ in Compliers:

$$\theta_{11} = \phi_1 \theta_{YY}^1 + (1 - \phi_1)\theta_{NY}^1$$

with $\phi_1 = \frac{\pi_{YY}}{\pi_{YY} + \pi_{NY}} = \frac{.51}{.51 + .14}$; $\theta_{11} = .89$ and $\theta_{YY}^1 = .86$

$$\rightarrow \boxed{\theta_{NY}^1 = \frac{.89 - .86 \times .785}{1 - .785} = 1}$$

$$\theta_{00} = \phi_2 \theta_{NN}^0 + (1 - \phi_2)\theta_{NY}^0$$

with $\phi_2 = \frac{\pi_{NN}}{\pi_{NN} + \pi_{NY}} = \frac{.35}{.35 + .14}$; $\theta_{00} = .34$ and $\theta_{NN}^0 = 0.38$

$$\rightarrow \boxed{\theta_{NY}^0 = \frac{.34 - .38 \times .714}{1 - .714} = 0.24}$$

Therefore, $\underline{PCE_{NY} = \theta_{NY}^1 - \theta_{NY}^0 = 0.76}$

<!-- page 44 -->

### IV Estimator:

$$
CACE = \frac{E(Y|Z = 1) - E(Y|Z = 0)}{E(A|Z = 1) - E(A|Z = 0)}
$$

$$
\begin{aligned}
E[Y|Z = 1] &= \sum_{a} E(Y|A = a, Z = 1)p(A = a|Z = 1) \\
&= .38 \times .35 + .89 \times .65 = .7115
\end{aligned}
$$

$$
E[Y|Z = 0] = .34 \times .49 + .86 \times .51 = .6052
$$

$$
E(A|Z = 1) = p(A = 1|Z = 1) = .65
$$

$$
E(A|Z = 0) = p(A = 1|Z = 0) = .51
$$

$\rightarrow$ Complier average causal effect $CACE = \frac{.7115 - .6052}{.65 - .51} = 0.76$,
which matches the results by the principal stratification method assuming exclusion restriction.
