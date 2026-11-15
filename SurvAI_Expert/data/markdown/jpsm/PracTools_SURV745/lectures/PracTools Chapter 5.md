---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_5"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 5.pdf"
pages: 25
sha256: "bdafe86622546bfca5b5e53ba6e653ac6a1a9244850910d8da0b9426ed9b3a7b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:10"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference
## Chapter 5: Mathematical Programming

Sunghee Lee

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 1 / 25

<!-- page 2 -->

# Outline

1. 1. Background

2. 2. Multi-Criteria Optimization

---
Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 5 $\qquad$ 2 / 25

<!-- page 3 -->

1. Background

# 1. Background

Sunghee Lee (U of Michigan)

Prac Tools Ch. 5

<!-- page 4 -->

1. Background

# Introduction

* Earlier chapters examined sample size determination and allocation to strata for a single variable.
* In reality, almost every survey of any size is multipurpose.
  * Data on a number of different variables are collected on each sample unit.
  * Estimates for the full population and for domains
  * Different types of estimates–means, totals, quantiles, and model parameters.
* Constraints
  * Minimum sample sizes may be set for domains
  * CV targets
  * Time schedule must be met, which dictates logistical decisions like mode of data collection and number of data collectors to hire.
  * Limited budget. Cost over-runs are common, but you can't count on getting a budget increase to cover them.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 4 / 25

<!-- page 5 -->

1. Background

# Background

* Multicriteria Optimization–find an efficient allocation of a sample that satisfies multiple goals and constraints
* Mathematical Programming–The term programming does not refer to computer programming. Instead, program refers to its use by the US military to refer to proposed training and logistics schedules (Freund 1994, Dantzig 1963).

  The term was coined by George Dantzig, who co-invented the area of linear programming (with Leonid Kantorovich).

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 5 / 25

<!-- page 6 -->

2. Multi-Criteria Optimization

# 2. Multi-Criteria Optimization

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 6 / 25

<!-- page 7 -->

2. Multi-Criteria Optimization

# Components of A Problem

1. Objective function: a function of one or several variables to be optimized;
2. Decision variables: the quantities that are adjusted in order to find a solution e.g., sample sizes;
3. Parameters: fixed inputs that are treated as constants, e.g., stratum population counts and variances; and
4. Constraints: restrictions on the decision variables or combinations of the decision variables, e.g., domain sizes and cost.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 7 / 25

<!-- page 8 -->

2. Multi-Criteria Optimization

# Formal Statement of An Optimization Problem - 1

* *stsrswor*. $\hat{\bar{y}}_j = \sum_{h=1}^H W_h \bar{y}_{j,sh}$: stratified mean for variable $j$ ($j = 1, 2, \cdots, J$)
* Stratum sample mean is $\bar{y}_{j,sh} = \sum_{i \in s_h} y_{jhi}/n_h$, $y_{jhi}$ is value of variable $j$ for sample unit $i$ in stratum $h$.
* Problem: Find the set of sample sizes $\{n_h\}_{h=1}^H$ to minimize the weighted sum of relvariances of estimated means,
  $\Phi = \sum_{j=1}^J \omega_j relvar(\hat{\bar{y}}_j)$, where $\omega_j$ is an importance weight
  $\rightarrow$ Objective function
* Subject to constraints:
  1. $n_h \le N_h$ for all $h$
  2. $n_h > n_{\min}$, a minimum sample size in every stratum
  3. $[CV(\bar{y}_{j,sh})]^2 \le (CV_{0jh})^2$ for certain strata and variables
  4. Budget: $C = C_0 + \sum_{h=1}^H c_h n_h$

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 5 $\qquad$ 8 / 25

<!-- page 9 -->

2. Multi-Criteria Optimization

# Formal Statement of An Optimization Problem - 2

- The decision variables to be adjusted in order to find a solution are $\{n_h\}_{h=1}^H$ in this case
- When there are multiple variables and estimates, some judgment needs to be made about the relative "importance" of each to the goals of the survey. Option used above is a weighted combination of the relvariances for different estimators as the objective function.
- Weights could be selected based on the importance of each estimate to the survey goals.
- Example: Objective is linear combination of the relvariance for 1) estimated proportion of employees who prefer flexible work hours and 2) estimated average number of sick days taken per employee. Importance weights could each be 0.5, assuming that these two estimates are equally important.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 9 / 25

<!-- page 10 -->

2. Multi-Criteria Optimization

# Relative Weights

* What the relative weights should be is a matter of opinion.
  * Assigning them will require conferring with the survey sponsor
  * Debate among the staff conducting the survey.
  * Some arbitrary assignments will probably be necessary.
  * Sensitivity analyses can be done using different sets of importance weights.
* Relvariances are convenient for forming the objective function since a relvariance is unitless
* Problem is nonlinear because sample sizes are in denominators of relvariances

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 10 / 25

<!-- page 11 -->

2. Multi-Criteria Optimization

# Example 5.2: Table 5.1

An artificial population of business establishments

**Table 5.1:** Stratum population means, standard deviations, and proportions for an artificial population of business establishments

| $h$ | Business sector | Establishments $N_h$ | $c_h$ | Population means Revenue (millions) | Population means employees | Population standard deviation Revenue (millions) | Population standard deviation employees | Population proportion Claimed research credit | Population proportion Had offshore affilates |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Manufacturing | 6,221 | 120 | 85 | 511 | 170.0 | 255.50 | 0.8 | 0.06 |
| 2 | Retail | 11,738 | 80 | 11 | 21 | 8.8 | 5.25 | 0.2 | 0.03 |
| 3 | Wholesale | 4,333 | 80 | 23 | 70 | 23.0 | 35.00 | 0.5 | 0.03 |
| 4 | Service | 22,809 | 90 | 17 | 32 | 25.5 | 32.00 | 0.3 | 0.21 |
| 5 | Finance | 5,467 | 150 | 126 | 157 | 315.0 | 471.00 | 0.9 | 0.77 |
| | Pop total | 50,568 | | 1,834,157 | 5,316,946 | | | 21,254 | 9,855 |

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 11 / 25

<!-- page 12 -->

2. Multi-Criteria Optimization

# Example 5.2: Optimize Sample of Establishments

* Find an allocation of an *stsrswor* to strata that will minimize the relvariance of estimated total revenue,
  $relvar(\hat{t}_{rev}) = t_U^{-2} \sum_h N_h \left( \frac{N_h}{n_h} - 1 \right) S_h^2$, where $\hat{t}_{rev} = \sum_h N_h \bar{y}_{sh}$,
  subject to these constraints:
  1. Budget on variable costs = $\$300,000$ U.S.;
  2. $CV \le 0.05$ on estimated total number of employees;
  3. At least 100 establishments are sampled in each sector, $n_h \ge 100$;
  4. The number sampled in each stratum is less than the population count, $n_h \le N_h$;
  5. $CV \le 0.03$ estimated total number of establishments claiming the research tax credit; and
  6. $CV \le 0.03$ on estimated total number of establishments with offshore affiliates.

**Switching to Excel**–Use VDK Example 5.2 Solver.xlsx We will look at briefly what solver looks like before switching to excel

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 12 / 25

<!-- page 13 -->

2. Multi-Criteria Optimization

| | A | B | C | D | E | F | G | H | I | J | K | L | M | N |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | | | | | Population means | | Population standard dev. | | Population proportion | | | | | |
| 2 | h | Sector | Establishments Nh | ch | Revenue (millions) | Employees | Revenue (millions) | Employees | Claimed research credit | Had offshore affiliates | nh | Revenue Nh*(Nh/nh - 1) * Sh^2 | Employees Nh*(Nh/nh - 1) * Sh^2 | Research Nh*(Nh/n * Sh |
| 3 | 1 | Manufacturing | 6,221 | 120 | 85 | 511 | 170.0 | 255.50 | 0.8 | 0.06 | 413 | 2,530,434,454 | 5,715,826,775 | 14,0 |
| 4 | 2 | Retail | 11,738 | 80 | 11 | 21 | 8.8 | 5.25 | 0.2 | 0.03 | 317 | 32,757,578 | 11,659,101 | 67,6 |
| 5 | 3 | Wholesale | 4,333 | 80 | 23 | 70 | 23.0 | 35.00 | 0.5 | 0.03 | 119 | 80,828,267 | 187,173,207 | 38,2 |
| 6 | 4 | Service | 22,809 | 90 | 17 | 32 | 25.5 | 32.00 | 0.3 | 0.21 | 1,399 | 227,005,461 | 357,483,417 | 73,3 |
| 7 | 5 | Finance | 5,467 | 150 | 126 | 157 | 315.0 | 471.00 | 0.9 | 0.77 | 598 | 4,418,511,483 | 9,878,629,437 | 4,0 |
| 8 | | | | | | | | | | | | | | |
| 9 | Pop Total | | 50,568 | | 1,834,157 | 5,316,946 | | | 21,253.90 | 9,854.87 | 2,846 | 7,289,537,243 | 16,150,771,937 | 19 |
| 10 | Pop Mean | | | | 36 | 105 | | | 0.420 | 0.195 | | | | |
| 11 | | | | | | | | | | relvariance of t.hat | | 0.00216684 | 0.000571 | 0.0 |
| 12 | Budget | | | $ 300,000 | | | | | | | CV of t.h | 0.04655 | 0.0239 | |
| 13 | Total sample cost | | | $ 300,000 | | | | | | | | | | |

Figure: 5.1 Excel spreadsheet set up for use with Solver.

Sunghee Lee (U of Michigan)
Prac Tools Ch. 5

<!-- page 14 -->

2. Multi-Criteria Optimization

Figure: 5.2 Screenshot of Excel Solver dialogue screen.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 14 / 25

<!-- page 15 -->

2. Multi-Criteria Optimization

Figure: 5.3 Screenshot of Change Constraint screen.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 15 / 25

<!-- page 16 -->

2. Multi-Criteria Optimization

Figure: 5.4 Screenshot of Solver Options screen.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 16 / 25

<!-- page 17 -->

## 2. Multi-Criteria Optimization

**Solver Engine**
Engine: GRG Nonlinear
Solution Time: 0.063 Seconds.
Iterations: 19 Subproblems: 0
**Solver Options**
Max Time 100 sec, Iterations 100, Precision 0.000001
Convergence 0.0001, Population Size 100, Random Seed 0, Derivatives Forward, Require Bounds
Max Subproblems Unlimited, Max Integer Sols Unlimited, Integer Tolerance 5%, Solve Without Integer Constraints

Objective Cell (Min)

| Cell | Name | Original Value | Final Value |
| :--- | :--- | ---: | ---: |
| \$L\$11 | relvariance of t.hat Revenue Nh\*(Nh/nh - 1) \* Sh^2 | 0.01298691 | 0.00216695 |

Variable Cells

| Cell | Name | Original Value | Final Value | Integer |
| :--- | :--- | ---: | ---: | :--- |
| \$K\$3 | Manufacturing nh | 100 | 413 | Contin |
| \$K\$4 | Retail nh | 100 | 317 | Contin |
| \$K\$5 | Wholesale nh | 100 | 119 | Contin |
| \$K\$6 | Service nh | 100 | 1,400 | Contin |
| \$K\$7 | Finance nh | 100 | 598 | Contin |

Constraints

| Cell | Name | Cell Value | Formula | Status | Slack |
| :--- | :--- | ---: | :--- | :--- | ---: |
| \$D\$13 | Total sample cost ch | \$ 300,000 | \$D\$13<=\$D\$12 | Binding | 0 |
| \$M\$11 | relvariance of t.hat Employees Nh\*(Nh/nh - 1) \* Sh^2 | 0.000571 | \$M\$11<=(0.05)^2 | Not Binding | 0.001928659 |
| \$N\$11 | relvariance of t.hat Research credit Nh\*(Nh/nh - 1) \* Sh^2 | 0.000437 | \$N\$11<=(0.03)^2 | Not Binding | 0.000462853 |
| \$O\$11 | relvariance of t.hat Offshore Nh\*(Nh/nh - 1) \* Sh^2 | 0.000901 | \$O\$11<=(0.03)^2 | Binding | 0 |
| \$K\$3 | Manufacturing nh | 413 | \$K\$3<=\$C\$3 | Not Binding | 5808.429995 |
| \$K\$4 | Retail nh | 317 | \$K\$4<=\$C\$4 | Not Binding | 11421.17068 |
| \$K\$5 | Wholesale nh | 119 | \$K\$5<=\$C\$5 | Not Binding | 4214.302446 |
| \$K\$6 | Service nh | 1,400 | \$K\$6<=\$C\$6 | Not Binding | 21409.37536 |
| \$K\$7 | Finance nh | 598 | \$K\$7<=\$C\$7 | Not Binding | 4869.111793 |
| \$K\$3 | Manufacturing nh | 413 | \$K\$3>=100 | Not Binding | 313 |
| \$K\$4 | Retail nh | 317 | \$K\$4>=100 | Not Binding | 217 |
| \$K\$5 | Wholesale nh | 119 | \$K\$5>=100 | Not Binding | 19 |
| \$K\$6 | Service nh | 1,400 | \$K\$6>=100 | Not Binding | 1,300 |
| \$K\$7 | Finance nh | 598 | \$K\$7>=100 | Not Binding | 498 |

Figure: 5.5 Solver Answer Report.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 17 / 25

<!-- page 18 -->

2. Multi-Criteria Optimization

# Accounting for Problem Variations

* Multicriteria optimization is an iterative process. Constraints can be set and then relaxed (or tightened) based on the initial allocation solution.
* Try a series of options for costs and precision of estimates to explore a problem. Good way of illustrating tradeoffs to clients. Maintain an accounting system to document:
  * Initial values set for the optimization problem;
  * Optimization results such as attained constraints and decision-variable values;
  * Reasons for changing the optimization components; and
  * New values set for the optimization problem.
* With Solver, you can
  * Save a different model in different tabs
  * Save more than one model in same tab
  * Select Load/Save button. Dialogue appears asking you to select a range of cells where model will be saved.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 18 / 25

<!-- page 19 -->

2. Multi-Criteria Optimization

# Example 5.3; Determining Subsample Sizes - 1

* Based on Encuesta de Actividades de Niños, Niñas y Adolescentes (EANNA) or Survey of Children and Adolescents – two-phase sample to measure gender equality and child labor in Chile.
* Initial sample of $27,400$ HHs. Numbers of children aged 5-11, 12-14, 15-17 recorded. (An HH can have multiple children in age groups.)
* In a second-phase sample, select 1000 age 5-11, 2000 age 12-14, 2000 age 15-17.
* HHs can have children in different age groups
* Select only 1 child per HH to limit burden but spread sample over all sizes of HHs

Sunghee Lee (U of Michigan)

Prac Tools Ch. 5

<!-- page 20 -->

2. Multi-Criteria Optimization

# Example 5.3; Determining Subsample Sizes - 2

| | Age group | Number of children in initial sample | Target sample size of children in subsample |
| :--- | :--- | :---: | :---: |
| 1 | 5–11 years | 6,229 | 1,000 |
| 2 | 12–14 year | 3,009 | 2,000 |
| 3 | 15–17 years | 3,159 | 2,000 |
| | Total | 12,397 | 5,000 |

Households can have more than 1 child. The children can be in different age groups.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 20 / 25

<!-- page 21 -->

2. Multi-Criteria Optimization

# Example 5.3; Determining Subsample Sizes - 3

**Notation**

* $h$ defined by which age groups a HH contains:
  $h = 1, 2, 3, 12, 13, 23, 123$
* $n_h$: number of first-phase sample HHs that are in stratum $h$
* $C_{hi(k)}$: number of children in HH $i$ stratum $h$ in age group $k$ ($k = 1, 2, 3$)
* $C_{hi(+)}$: number of children in HH $i$ stratum $h$ across all age groups
* $a_h$: sampling rate of HHs in stratum $h$ (to be determined using mathematical programming)

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 21 / 25

<!-- page 22 -->

2. Multi-Criteria Optimization

# Example 5.3; Determining Subsample Sizes - 4

* If one child is selected at random without regard to age group in a HH, selection probability within the HH is $1/C_{hi(+)}$.
* Expected number of children sampled from age group $k$ in HH $hi$ is the proportion of children in that age group in the HH:
  $p_{hi(k)} = \frac{C_{hi(k)}}{C_{hi(+)}}$
* Expected number of children selected from age group $k$ across all HHs is
  $$e_k = \sum_h a_h \sum_{i \in s_h} p_{hi(k)} = \sum_h a_h n_h \bar{p}_{i(k)}$$
  where $\bar{p}_{i(k)} = \frac{1}{n_h} \sum_{i \in s_h} p_{hi(k)}$ is the average proportion of children per HH in stratum $h$ that are in age group $k$ (known in advance).
* Expected total number of HHs subsampled is $E_{HH} = \sum_h a_h n_h$

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 22 / 25

<!-- page 23 -->

2. Multi-Criteria Optimization

# Example 5.3; Determining Subsample Sizes - 5

Subsampling problem formulation

* Find the set of rates $a_h$ that minimize the expected number of HHs, $E_{HH}$ , selected
* Subject to these constraints:
  1. $e_1 = 1000$; $e_2 = e_3 = 2000$
  2. $\min_a < a_h \le 1$ for all strata with $\min_a$ being the minimum sampling rate allowed for any stratum.

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 23 / 25

<!-- page 24 -->

2. Multi-Criteria Optimization

# Example 5.3; Determining Subsample Sizes - 6

| Stratum | Sampling rate for HHs | No. of HHs | Average proportion of children $\bar{p}_{h(k)}$ per HH that are in age group $k$ | | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| $h$ | $a_h$ | $n_h$ | $k = 1$ | $2$ | $3$ |
| $1$ | $a_1$ | $n_1$ | $1$ | $0$ | $0$ |
| $2$ | $a_2$ | $n_2$ | $0$ | $1$ | $0$ |
| $3$ | $a_3$ | $n_3$ | $0$ | $0$ | $1$ |
| $12$ | $a_{12}$ | $n_{12}$ | $\bar{p}_{12(1)}$ | $\bar{p}_{12(2)}$ | $0$ |
| $13$ | $a_{13}$ | $n_{13}$ | $\bar{p}_{13(1)}$ | $0$ | $\bar{p}_{13(3)}$ |
| $23$ | $a_{23}$ | $n_{23}$ | $0$ | $\bar{p}_{23(2)}$ | $\bar{p}_{23(3)}$ |
| $123$ | $a_{123}$ | $n_{123}$ | $\bar{p}_{123(1)}$ | $\bar{p}_{123(2)}$ | $\bar{p}_{123(3)}$ |

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 24 / 25

<!-- page 25 -->

2. Multi-Criteria Optimization

# Example 5.3; Determining Subsample Sizes - 7

| | A | B | C | D | E | F | G | H | I | J |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | | | | | | | | | | |
| **2** | Age group | Target subsample sizes | | | | | | | | |
| **3** | 5-11 | 1000 | | | | | | | | |
| **4** | 12-14 | 2000 | | | | | | | | |
| **5** | 15-17 | 2000 | | | | Age groups | | | | |
| **6** | | | | | Initial sample | | | Subsample | | |
| **7** | | | | 5-11 | 12-14 | 15-17 | 5-11 | 12-14 | 15-17 | |
| **8** | Stratum | Sampling rate for HH | Households | | ph(k) | | | Expected no. of children | | Expected no. of HHs |
| **9** | h | ah | nh | k=1 | 2 | 3 | ah\*nh\*ph(1) | ah\*nh\*ph(2) | ah\*nh\*ph(3) | ah\*nh |
| **10** | 0 | 0 | 15000 | 0 | 0 | 0 | | | | |
| **11** | 1 | 0.161 | 4700 | 1 | 0 | 0 | 758 | 0 | 0 | 758 |
| **12** | 2 | 0.947 | 1900 | 0 | 1 | 0 | 0 | 1800 | 0 | 1800 |
| **13** | 3 | 0.793 | 2300 | 0 | 0 | 1 | 0 | 0 | 1825 | 1825 |
| **14** | 12 | 0.10 | 1300 | 0.5 | 0.5 | 0 | 65 | 65 | 0 | 130 |
| **15** | 13 | 0.10 | 1300 | 0.6 | 0 | 0.4 | 78 | 0 | 52 | 130 |
| **16** | 23 | 0.10 | 600 | 0 | 0.6 | 0.4 | 0 | 36 | 24 | 60 |
| **17** | 123 | 1.00 | 300 | 0.33 | 0.33 | 0.33 | 99 | 99 | 99 | 300 |
| **18** | | Total children | | 6229 | 3009 | 3159 | | Total expected no. of HHs | | 5003 |
| **19** | | | | | | | | | | |
| **20** | | | | | | | | Expected no. of children in sample | | |
| **21** | | | | | | | k=1 | 2 | 3 | All ages |
| **22** | | Total HHs with children | 12400 | | | | 1000 | 2000 | 2000 | 5000 |

See **VDK Example 5.3 Subsampling age strata.xlsx**

Sunghee Lee (U of Michigan) Prac Tools Ch. 5 25 / 25
