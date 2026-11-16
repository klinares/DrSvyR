---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_9"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 9.pdf"
pages: 71
sha256: "d1a968c2dba508b6c7698b1df68290e0d8095e4f5966e9ed610d0feb2186e003"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:17"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference
## Chapter 9: Designing Multistage Samples

Sunghee Lee

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 1 / 71

<!-- page 2 -->

# Outline

1. 1. Introduction
2. 2. Basic Variance Results - 2-Stage
3. 3. Measure of Homogeneity
4. 4. Nonlinear Estimators in 2-Stage Sampling
5. 5. 2-Stage Sampling: $pps/srs$
6. 6. General 2-Stage Designs
7. 7. 3-Stage Sampling
   * 7.1 $srs$ at All 3 Stages
   * 7.2 Varying Probabilities at First Stages
8. 8. Allocation in 2- and 3-Stage Sampling
   * 8.1 Allocation in 2-Stage Sampling
   * 8.2 Allocation in 3-Stage Sampling
9. 9. Allocation with Fixed Sample of PSUs
10. 10. Estimating Variance Components
11. 11. Models for Anticipated Variance Components

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 2 / 71

<!-- page 3 -->

1. Introduction

# 1. Introduction

Sunghee Lee (U of Michigan)

Prac Tools Ch. 9

<!-- page 4 -->

1. Introduction

# Introduction

* Multistage samples: can be practical and cost-efficient solution in situations where a list of elementary (or analytic) units is not available for direct sampling.
  * A list of elementary units can be compiled within just the selected clusters rather than for the whole frame.
  * Especially useful in household samples if a list of every household in a country, state, county, etc., is not available.
  * Permission for a survey may have to be obtained at the cluster level.
  * If the goal is to administer a standardized test to a sample of students, administrators in the school district or in the school may have to grant permission to do the survey.
* Mode of data collection also affects decision to use cluster sampling.
  * For personal interview, cluster sampling can save travel costs.
  * For telephone or web surveys, cluster sampling may be unnecessary and statistically inefficient.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 4 / 71

<!-- page 5 -->

1. Introduction

# Terminology

* Cluster sampling: a group of units (clusters) is selected at the first stage of sampling; Clusters can be geographic areas, establishments, schools, or some other aggregates.
* Primary sampling unit (PSU) or first-stage unit—synonymous with cluster in this class.
* Within a selected cluster, elementary units are sampled.
* Some texts reserve term "cluster sample" for a single-stage sample.
    * In this class, a cluster sample will include both the cases of complete enumeration of a cluster and of subsampling in a cluster.
* Subsampling within a cluster $\rightarrow$ multistage sampling.
* Ultimate cluster denotes the aggregate of the elementary units across the stages of selection within a sample PSU.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 5 / 71

<!-- page 6 -->

1. Introduction

# Two Situations to Consider in Multistage Design

* First is designing a PSU sample from scratch. Issues are:
  1. How to form the PSUs
  2. How they should be stratified
  3. Number of sample PSUs
  4. How sample is allocated to strata
  5. Method of sampling the PSUs
  6. How sampling is to be done within the selected PSUs
* Second case is using an existing PSU sample.
  1. Focus is on how to efficiently select secondary sampling units (SSUs) (and, for a three stage design, elements within SSUs).
  2. Sample size and method of sampling SSUs
  3. Number of elements to select within each PSU and SSU
  4. Sample allocation determined conditional on the sample of PSUs.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 6 / 71

<!-- page 7 -->

1. Introduction

# Notation: Super important!

* $U$: universe of PSUs
* $M$: number of PSUs in universe
* $U_i$: universe of elements in PSU $i$
* $N_i$: number of elements in the population for PSU $i$
* $N = \sum_{i \in U} N_i$: total number of elements in the population
* $\pi_i$: selection probability of PSU $i$
* $\pi_{ij}$: joint selection probability of PSUs $i$ and $j$
* $m$: number of sample PSUs
* $n_i$: number of sample elements in PSU $i$
* $s$: set of sample PSUs
* $s_i$: set of sample elements in PSU $i$
* $y_{ik}$: analysis variable for element $k$ in PSU $i$
* $\bar{y}_U$: mean per element in the population
* $\bar{y}_{Ui}$: mean per element in the population in PSU $i$

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 7 / 71

<!-- page 8 -->

2. Basic Variance Results - 2-Stage

# 2. Basic Variance Results - 2-Stage

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 8 / 71

<!-- page 9 -->

2. Basic Variance Results - 2-Stage

# $\pi$-Estimator in $\pi ps/srswor$

* Sample design: PSUs selected with varying probabilites; elements selected by $srswor$
* Population total:

$$t_U = \sum_{i \in U} t_i = \sum_{i \in U} \sum_{k \in U_i} y_{ik}$$

* $\pi$-estimator of $t_U$:

$$\hat{t}_\pi = \sum_{i \in s} \frac{\hat{t}_i}{\pi_i} = \sum_{i \in s} \frac{1}{\pi_i} \frac{N_i}{n_i} \sum_{k \in s_i} y_{ik}$$

  where $\hat{t}_i$ is an expansion estimator of the total for PSU $i$ with an $srs$, calculated as

$$\hat{t}_i = \frac{N_i}{n_i} \sum_{k \in s_i} y_{ik}$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 9 / 71

<!-- page 10 -->

2. Basic Variance Results - 2-Stage

# Variance of $\pi$-Estimator

- Design variance of $\hat{t}_{\pi}$:
$$
V(\hat{t}_{\pi}) = \sum_{i \in U} \sum_{j \in U} (\pi_{ij} - \pi_i \pi_j) \frac{t_i}{\pi_i} \frac{t_j}{\pi_j} + \sum_{i \in U} \frac{N_i^2}{\pi_i n_i} \left(1 - \frac{n_i}{N_i}\right) S_{U2i}^2 \quad (9.1),
$$
where $S_{U2i}^2 = \frac{\sum_{k \in U_i} (y_{ik} - \bar{y}_{U_i})^2}{N_i - 1}$: unit variance of $Y$ among the elements in PSU $i$

- Formula (9.1) is hard to use for sample size calculations, because number of sample PSUs, $m$, is not exposed. Could use *srswor/srswor* or work with *ppswr* variance formula for PSU sampling.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 10 / 71

<!-- page 11 -->

2. Basic Variance Results - 2-Stage

# Example 9.1: Variance in $srswor/srswor$ - 1

* $\pi$-estimator of $t_U$:
$$\hat{t}_\pi = \frac{M}{m} \sum_{i \in s} \frac{N_i}{n_i} \sum_{k \in s_i} y_{ik}$$

* Its design variance:
$$V(\hat{t}_\pi) = \frac{M^2}{m} \frac{M - m}{M} S_{U1}^2 + \frac{M}{m} \sum_{i \in U} \frac{N_i^2}{n_i} \frac{N_i - n_i}{N_i} S_{U2i}^2,$$
where $S_{U1}^2 = \frac{\sum_{i \in U} (t_i - \bar{t}_U)^2}{M - 1}$ with
  * $t_i = \sum_{k \in U_i} y_{ik}$: the population total of $Y$ in PSU $i$, and
  * $\bar{t}_U = \frac{\sum_{i \in U} t_i}{M}$: the mean total per PSU

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 11 / 71

<!-- page 12 -->

2. Basic Variance Results - 2-Stage

# Example 9.1: Variance in $srswor / srswor$ -2

* $relvar(\hat{t}_\pi) = \frac{V(\hat{t}_\pi)}{t_U^2}$

$$
= \frac{1}{m}\frac{M - m}{M}B^2 + \frac{1}{t_U^2}\frac{M}{m}\sum_{i \in U}\frac{N_i^2}{n_i}\frac{N_i - n_i}{N_i}S_{U2i}^2 \qquad (9.2)
$$

where $B^2 = \frac{S_{U1}^2}{\bar{t}_U^2} = \frac{M^2 S_{U1}^2}{t_U^2}$: unit relvariance among PSU totals

* If $\bar{n}$ elements are selected in each PSU and the sampling fractions of PSUs, $m/M$, and elements within PSUs, $\bar{n}/N_i$, are all small, then (9.2) can be written as:

$$
relvar(\hat{t}_\pi) = \frac{V(\hat{t}_\pi)}{t_U^2} = \frac{B^2}{m} + \frac{W^2}{m\bar{n}} \qquad (9.3)
$$

where $W^2 = \frac{M \sum_{i \in U} N_i^2 S_{U2i}^2}{t_U^2}$

* Expression (9.3) is the form used in `BW2stageSRS`.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 12 / 71

<!-- page 13 -->

3. Measure of Homogeneity

# 3. Measure of Homogeneity

Sunghee Lee (U of Michigan)

Prac Tools Ch. 9

<!-- page 14 -->

3. Measure of Homogeneity

# Measure of Homogeneity Form of Relvariance

* Assuming $\bar{n}$ are selected in each sample PSU, and $m/M$ and $\bar{n}/N_i$ are small, (9.3) can be written with a measure of homogeneity $\delta$:
$$relvar(\hat{t}_\pi) = \frac{V(\hat{t}_\pi)}{t_U^2} \doteq \frac{\tilde{V}}{m\bar{n}} k[1 + \delta(\bar{n} - 1)] \quad (9.5)$$
where $\tilde{V} = S_U^2 / \bar{y}_U^2$, $k = (B^2 + W^2) / \tilde{V}$, and $\delta = \frac{B^2}{B^2 + W^2} \quad (9.6)$
* When $N_i = \bar{N}$ and both $M$ and $\bar{N}$ are large,
$$\tilde{V} = \frac{S_U^2}{\bar{y}_U^2} = \frac{1}{\bar{y}_U^2} \frac{\sum_{i \in U} \sum_{k \in U_i} (y_{ik} - \bar{y}_U)^2}{N - 1} \doteq B^2 + W^2$$
i.e., the population relvariance can be written as the sum of between and within relvariances.
* If so, then $k \doteq 1$ and (9.5) is the expression found in most books (e.g., Kish). But, when population count of elements per cluster varies, $k$ may be far from 1 and (9.5) may not be proper (to be illustrated in VDK Example 9.2)

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 14 / 71

<!-- page 15 -->

3. Measure of Homogeneity

# Additional Points about Eq. (9.5) - 1

* With single-stage *srs* sampling of clusters, $\delta$ is an intraclass correlation; but not with 2-stage sampling.
* Practitioners habitually refer to $\delta$ as an intraclass correlation regardless of design but measure of homogeneity is better description.
* An ad hoc *fpc*, $1 - m\bar{n}/M\bar{N}$, is sometimes inserted in (9.5), although this does not follow directly from rewriting (9.2).
* Expression (9.5) is useful for sample size calculation, since number of sample PSUs and sample units per PSU are explicitly in formula.

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 9 $\qquad$ 15 / 71

<!-- page 16 -->

3. Measure of Homogeneity

# Additional Points about (9.5) - 2

- Expression (9.5) also connects variance of the estimated total to the variance that would be obtained from an *srs*, since $\tilde{V} / m\bar{n}$ is relvariance of estimated total in an *srswor* of size $m\bar{n}$ when the sampling fraction is small.
  - $k[1 + \delta(\bar{n} - 1)]$ is a type of design effect. When $k = 1$, $[1 + \delta(\bar{n} - 1)]$ is the approximate design effect found in many textbooks.
  - Expression (9.5) with $k = 1$ is often treated as if it applies regardless of sampling methods of PSUs and of elements within PSUs and without regard to the kind of estimator used.
  - If, e.g., a *pps* sample of PSUs is selected and a poststratified estimator of a total is used, (9.5) reflects neither of those features.
  - (9.5) is a specialized formula that does not apply well when methods of sampling other than *srs* are used at different stages.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 16 / 71

<!-- page 17 -->

3. Measure of Homogeneity

# Effect of $\delta$ on Precision

* Even when the measure of homogeneity is small, effect on variance can be substantial if many elements are sampled per cluster.
* Intuition: increasing the sample within each cluster is adding correlated (i.e., more of the same) information, less effective than adding uncorrelated (new) information from different clusters.

Table: 9.1 Approximate design effects for different sizes of homogeneity measure $\delta$ and number of sample elements per cluster.

| | | $1 + \delta(\bar{n} - 1)$ | |
| :--- | :--- | :--- | :--- |
| $\bar{n}$ | $\delta=0.01$ | $\delta=0.05$ | $\delta=0.20$ |
| 5 | 1.04 | 1.20 | 1.80 |
| 10 | 1.09 | 1.45 | 2.80 |
| 25 | 1.24 | 2.20 | 5.80 |
| 50 | 1.49 | 3.45 | 10.80 |
| 100 | 1.99 | 5.95 | 20.80 |

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 17 / 71

<!-- page 18 -->

3. Measure of Homogeneity

# Size of $\delta$

* Size of $\delta$ is affected by the size of a cluster. Although this is not always true, the elements in a cluster may be more alike when the cluster size is small.
    * Especially true when clusters are based on geographic areas.
    * Example of $\delta$ from Hansen, Hurwitz and Meadow (1953a):

| No. of HHs per cluster | 3 | 9 | 27 | 62 |
| :--- | :--- | :--- | :--- | :--- |
| No. persons in HH | 0.430 | 0.439 | 0.243 | 0.112 |
| Unemployed male (0-1) | 0.060 | 0.070 | 0.045 | 0.034 |

* For agricultural variables, like whether a farm reports raising a specific crop (e.g., barley, potatoes, or wheat), $\delta$'s of 0.4 or larger may be common as long as cluster sizes are 4 or 5 nearby farms.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 18 / 71

<!-- page 19 -->

3. Measure of Homogeneity

# Two Extreme Cases

Indicator for whether a person has a college degree or not. PSUs are city blocks.

1. High intraclass correlation: All persons on any given PSU either have a college degree or not. Within-PSU variance component is near $0$. Between-PSU variance component is approximately equal to the total variance $\quad \Rightarrow \quad \delta \doteq B^2 / (B^2 + W^2) \doteq 1$
   Sampling more than $1$ person/PSU would be inefficient because the people in a PSU all tend to have the same education level.

2. Zero intraclass correlation: Suppose PSUs are same size; proportion with college degrees is same, $\bar{p}$, in every PSU in the population. Total of persons with degrees in each PSU is $t_i = \bar{N}\bar{p}$, a constant. Between variance is $0 \quad \Rightarrow \quad \delta = 0$.
   Only $1$ block needs to be sampled.

   (Notice that if the $N_i$'s vary, $\delta$ would not be zero, even if $\bar{p}$ was the same in every block.)

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 9 $\qquad$ 19 / 71

<!-- page 20 -->

3. Measure of Homogeneity

# Example 9.2: Between and Within Variance Components in $srs/srs$ Design

* Based on Maryland Area Population, `MDarea.pop`, in `PracTools`
* See US Census Geography Diagram (more in later chapters)
* **See VDK Example 9.2 in Class5Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 20 / 71

<!-- page 21 -->

3. Measure of Homogeneity

# Cluster Sizes - 1

* Create clusters with equal sizes if possible
* Variation of tract sizes in the Maryland population is large—more than practitioners would prefer when defining PSUs.
  * Range of the number of persons per tract: 86 to 13,579.
  * Having such large variation in PSU sizes,
    * leads to large differences in the cluster sizes ($N_i$'s) and totals ($t_i$'s)
    * causes between variance component $B^2$ to be large
    * leads to high measures of homogeneity seen above and inefficiencies if a clustered sample is selected.
    * Also the reason that the approximation $\tilde{V} = \frac{S_U^2}{\bar{y}_U^2} \doteq B^2 + W^2$ is poor in VDK Example 9.2.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 21 / 71

<!-- page 22 -->

3. Measure of Homogeneity

# Cluster Sizes - 2

- Standard practice would be to **combine** small tracts or block groups so that all PSUs have some prescribed minimum number of persons.
  - `GeoMinMOS` can help identify and link units that do not meet a minimum number of people (or measure of size).
- If sample designer has flexibility in forming the clusters, as would usually be the case in a household survey, clusters with nearly equal numbers of elements should be created.
  - In some surveys, clusters are naturally occurring units, like schools, classrooms, or establishments. In those cases, you may have to live with the pre-defined units.
  - But considering the variation in cluster size will be important when determining sample sizes.

Sunghee Lee (U of Michigan)

Prac Tools Ch. 9

<!-- page 23 -->

4. Nonlinear Estimators in 2-Stage Sampling

# 4. Nonlinear Estimators in 2-Stage Sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 23 / 71

<!-- page 24 -->

4. Nonlinear Estimators in 2-Stage Sampling

# Handling Nonlinear Estimators - 1

* General approach is to write down linear approximation to estimator, then compute component form of variance of approximation.
  * A mean estimated as $\frac{(\text{est pop total})}{(\text{est no. of elements in pop})}$ is nonlinear
* Example: ratio of two estimated means: $\hat{\theta} = \hat{\bar{y}}_1 / \hat{\bar{y}}_2$, where
  * $\hat{\bar{y}}_j = \hat{t}_{j\pi} / \hat{N}_\pi$ ($j = 1, 2$)
  * $\hat{t}_{j\pi} = \sum_{i \in s} \sum_{k \in s_i} d_k y_{jk}$
  * $d_k$: the inverse of the selection probability of element $k$
  * $\hat{N}_\pi = \sum_{i \in s} \sum_{k \in s_i} d_k$
  * Due to cancellation of $\hat{N}_\pi$, $\hat{\theta} = \hat{t}_{1\pi} / \hat{t}_{2\pi}$, a function of two estimated totals.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 24 / 71

<!-- page 25 -->

4. Nonlinear Estimators in 2-Stage Sampling

# Handling Nonlinear Estimators - 2

- Linear approximation of $\hat{\theta}$ is:
$$\hat{\theta} - \theta \doteq \sum_{i \in s} \sum_{k \in s_i} d_k z_k + \text{constants, where}$$
  - $\theta$ is the population ratio to be estimated
  - $z_k = \sum_{j=1}^2 \frac{\partial f(\hat{t})}{\partial \hat{t}_{j\pi}} y_{jk}$ with
    - $k \in s_i$, $\hat{t} = (\hat{t}_{1\pi}, \hat{t}_{2\pi})$
    - $\frac{\partial f(\hat{t})}{\partial \hat{t}_{j\pi}}$ is the partial derivative of $\hat{t}$ with respect to the $j^{\text{th}}$ estimated total.
  - $z_k$ is referred to as a linear substitute
  - The "constants" do not enter into the variance calculation. The variance of $\hat{\theta}$ can be approximated by computing the variance of $\sum_{i \in s} \sum_{k \in s_i} d_k z_k$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 25 / 71

<!-- page 26 -->

4. Nonlinear Estimators in 2-Stage Sampling

# Ratio Means: $srs/srs$

* If $srs$ at both stages, $d_k = \frac{M}{m} \frac{N_i}{n_i}$ and $z_k = y_{1k} - \theta y_{2k}$.
* The ratio estimator: $\hat{\theta} \doteq \frac{M}{m} \sum_{i \in s} \hat{t}_{zi}$, where $\hat{t}_{zi} = \frac{N_i}{n_i} \sum_{k \in s_i} z_k$
  $\Rightarrow \quad \hat{\theta}$ can be written in the same way as the $\pi$-estimator in Example 9.1.
* $relvar(\hat{\theta})$ can be expressed as (9.5), assuming $n_i = \bar{n}$:
  $$relvar(\hat{\theta}) = \frac{V(\hat{\theta})}{\theta^2} \doteq \frac{\tilde{V}}{m\bar{n}} k [1 + \delta(\bar{n} - 1)]$$
  where $\tilde{V}$ is the unit relvariance of the $z_k$'s, $k = (B^2 + W^2)/\tilde{V}$, and $\delta = B^2 / (B^2 + W^2)$.
* The between and within relvariance components are written in terms of the $z_k$ rather than $y_k$.

**See VDK Example 9.3 in Class5Lab.pdf**

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 9 $\qquad$ 26 / 71

<!-- page 27 -->

5. 2-Stage Sampling: $pps/srs$

# 5. 2-Stage Sampling: $pps/srs$

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 27 / 71

<!-- page 28 -->

5. 2-Stage Sampling: $pps/srs$

# $pps/srs$ Design - 1

* Variance formulas in two-stage sampling with PSUs selected with varying probabilities are not good for finding sample sizes
* A more useful formulation is the case where PSUs are selected with varying probabilities but with replacement (i.e., $pwr$), and the sample within each PSU is selected by $srswor$. As noted in VDK Ch. 3, with-replacement designs may not often be used in practice but have simple variance formulae.
* $pwr$ estimator of a total is:
$$\hat{t}_{pwr} = \frac{1}{m} \sum_{i \in s} \frac{\hat{t}_i}{p_i}, \text{ where}$$
  * $\hat{t}_i = \frac{N_i}{n_i} \sum_{k \in s_i} y_{ik}$: estimated total for PSU $i$ from an $srs$
  * $p_i$: the 1-draw selection probability of PSU $i$
  * $\frac{\hat{t}_i}{p_i}$: est total based on 1 sample PSU

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 28 / 71

<!-- page 29 -->

5. 2-Stage Sampling: $pps/srs$

# $pps/srs$ Design - 2

* The variance of $\hat{t}_{pwr}$ is

$$
V(\hat{t}_{pwr}) = \frac{1}{m} \sum_{i \in U} p_i \left( \frac{t_i}{p_i} - t_U \right)^2 + \sum_{i \in U} \frac{N_i^2}{m p_i n_i} \left( 1 - \frac{n_i}{N_i} \right) S_{U2i}^2 \quad (9.8)
$$

$$
\equiv V_{PSU} + V_{SSU} \quad (9.13)
$$

* If $\bar{n}$ elements are selected in each PSU, (9.8) reduces to

$$
V(\hat{t}_{pwr}) = \frac{S_{U1(pwr)}^2}{m} + \frac{1}{m \bar{n}} \sum_{i \in U} \left( 1 - \frac{\bar{n}}{N_i} \right) \frac{N_i^2 S_{U2i}^2}{p_i}
$$

where $S_{U1(pwr)}^2 = \sum_{i \in U} p_i \left( \frac{t_i}{p_i} - t_U \right)^2$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 29 / 71

<!-- page 30 -->

5. 2-Stage Sampling: $pps/srs$

# $pps/srs$ Design - 3

* Assuming a negligible within-PSU sampling fraction $(\frac{\bar{n}}{N_i})$,

$$relvar(\hat{t}_{pwr}) = \frac{V(\hat{t}_{pwr})}{t_U^2} = \frac{B^2}{m} + \frac{W^2}{m\bar{n}} = \frac{\tilde{V}}{m\bar{n}} k[1 + \delta(\bar{n} - 1)] \quad (9.9)$$

with $\tilde{V} = S_U^2 / \bar{y}_U^2$

$$k = (B^2 + W^2) / \tilde{V}$$

$$B^2 = \frac{S_{U1(pwr)}^2}{t_U^2} \quad (9.10)$$

$$W^2 = \frac{1}{t_U^2} \sum_{i \in U} N^2 \frac{S_{U2i}^2}{p_i} \quad (9.11)$$

$$\delta = B^2 / (B^2 + W^2) \quad (9.12)$$

Sunghee Lee (U of Michigan) | Prac Tools Ch. 9 | 30 / 71

<!-- page 31 -->

6. General 2-Stage Designs

# 6. General 2-Stage Designs

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 31 / 71

<!-- page 32 -->

6. General 2-Stage Designs

# $ppswr/srs$ Design

**See VDK Example 9.4 in Class5Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 32 / 71

<!-- page 33 -->

7. 3-Stage Sampling

# 7. 3-Stage Sampling

Sunghee Lee (U of Michigan)

Prac Tools Ch. 9

<!-- page 34 -->

7. 3-Stage Sampling

# Introduction

- A common design in household surveys is to select PSUs, SSUs within PSUs, and households within SSUs.
- In the US, SSUs are typically sub-county geographic areas like census tracts, block groups or groups or blocks.
- Three variance components in a three-stage design
- We will examine two variations: $srs/srs/srs$ and $pps(wr)/srs/srs$

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 34 / 71

<!-- page 35 -->

7. 3-Stage Sampling

# Additional Notation

$U_i$: universe (population) of SSUs in PSU $i$

$N_i$: population number of SSUs in PSU $i$

$s_i$: set of sample SSUs in PSU $i$

$n_i$: number of SSUs selected in PSU $i$

$N = \sum_{i \in U} N_i$: total number of SSUs in the population

$U_{ij}$: population of elements in SSU $j$ within PSU $i$

$Q_{ij}$: population number of elements in SSU $j$ within PSU $i$

$s_{ij}$: set of sample elements in SSU $j$ within PSU $i$

$q_{ij}$: number of elements selected in SSU $j$ within PSU $i$

$Q_i$: population number of elements in PSU $i$

$Q$: number of elements in population

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 35 / 71

<!-- page 36 -->

7. 3-Stage Sampling
7.1 $srs$ at All 3 Stages

# 7.1 $srs$ at All 3 Stages

Sunghee Lee (U of Michigan)
Prac Tools Ch. 9

<!-- page 37 -->

7. 3-Stage Sampling $\quad$ 7.1 $srs$ at All 3 Stages

# $srs$ at All 3 Stages - 1

- Selection probabilities
  - PSUs: $m/M$
  - SSUs: $n_i/N_i$
  - Elements: $q_{ij}/Q_{ij}$
- $\pi$-estimator of the total is:
$$
\hat{t}_\pi = \frac{M}{m} \sum_{i \in s} \frac{N_i}{n_i} \sum_{j \in s_i} \frac{Q_{ij}}{q_{ij}} \sum_{k \in s_{ij}} y_k
$$

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 37 / 71

<!-- page 38 -->

7. 3-Stage Sampling $\quad$ 7.1 $srs$ at All 3 Stages

# $srs$ at All 3 Stages - 2

* $relvar$ of the $\pi$-estimator of the total is:

$$relvar(\hat{t}_\pi) = \frac{V(\hat{t}_\pi)}{t_U^2} = \frac{1}{t_U^2} \left[ \frac{M^2}{m} \frac{M-m}{M} S_{U1}^2 + \frac{M}{m} \sum_{i \in U} \frac{N_i^2}{n_i} \frac{N_i - n_i}{N_i} S_{U2i}^2 + \right.$$

$$\left. \frac{M}{m} \sum_{i \in U} \frac{N_i}{n_i} \sum_{j \in U_i} \frac{Q_{ij}^2}{q_{ij}} \frac{Q_{ij} - q_{ij}}{Q_{ij}} S_{U3ij}^2 \right] \quad (9.14)$$

$S_{U1}^2 = \frac{\sum_{i \in U} (t_i - \bar{t}_U)^2}{M-1}$: Unit variance of PSU totals

$S_{U2i}^2 = \frac{1}{N_i - 1} \sum_{j \in U_i} (t_{ij} - \bar{t}_{Ui})^2$: Unit var of SSU totals in PSU $i$

$t_{ij} = \sum_{k \in U_{ij}} y_k$: population total for PSU/SSU $ij$

$\bar{t}_{Ui} = \sum_{j \in U_i} t_{ij} / N_i$: average total per SSU in PSU $i$

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 38 / 71

<!-- page 39 -->

7. 3-Stage Sampling
7.1 $srs$ at All 3 Stages

# $srs$ at All 3 Stages - 3

$S_{U3ij}^2 = \frac{1}{Q_{ij}-1} \sum_{k \in U_{ij}} (y_k - \bar{y}_{U_{ij}})^2$: unit var of elements in PSU/SSU $ij$

$\bar{y}_{U_{ij}} = \sum_{k \in U_{ij}} y_k / Q_{ij}$

To write (9.14) in a form more useful for sample size calculation, assume

* Same number of SSUs, $\bar{n}$, is selected from each PSU
* Same number of elements, $\bar{\bar{q}}$, is selected from each SSU
* A special case (Cochran 1977, eqn (10.26), $m_{opt} = \frac{S^2}{\sqrt{S_1^2 - S_2^2 / \bar{M}}} \sqrt{\frac{C_1}{C_2}}$) follows from assuming that each PSU has same population number of SSUs, and that each SSU has the same population number of elements. This is too restrictive.

Sunghee Lee (U of Michigan)
Prac Tools Ch. 9

<!-- page 40 -->

7. 3-Stage Sampling
7.1 $srs$ at All 3 Stages

# $srs$ at All 3 Stages - 4

Assuming that the sampling fractions of PSUs, SSUs within PSUs, and elements within SSUs are all small, a more general relvariance formula that does allow for varying population sizes and still requires that $\bar{n}$ SSUs and $\bar{\bar{q}}$ elements be selected, is

$$
relvar(\hat{t}_\pi) = \frac{V(\hat{t}_\pi)}{t_U^2} \doteq \frac{B^2}{m} + \frac{W_2^2}{m\bar{n}} + \frac{W_3^2}{m\bar{n}\bar{\bar{q}}} \tag{9.16}
$$

$B^2 = M^2 S_{U1}^2 / t_U^2$

$W_2^2 = M \sum_{i \in U} N_i^2 S_{U2i}^2 / t_U^2$

$W_3^2 = M \sum_{i \in U} N_i \sum_{j \in U_i} Q_{ij}^2 S_{U3ij}^2 / t_U^2$

(9.16) is a generalized version of (9.14)

Sunghee Lee (U of Michigan)
Prac Tools Ch. 9

<!-- page 41 -->

7. 3-Stage Sampling
7.2 Varying Probabilities at First Stages

# 7.2 Varying Probabilities at First Stages

Sunghee Lee (U of Michigan)
Prac Tools Ch. 9

<!-- page 42 -->

7. 3-Stage Sampling $\quad$ 7.2 Varying Probabilities at First Stages

# $ppswr/srs/srs$

The relvariance of the $pwr$-estimator of a total is

$$
\begin{aligned}
relvar(\hat{t}_{pwr}) = \frac{V(\hat{t}_{pwr})}{t_U^2} &= \frac{1}{t_U^2} \left[ \frac{S_{U1(pwr)}^2}{m} + \frac{1}{m} \sum_{i \in U} \frac{1}{p_i} \frac{N_i^2}{n_i} \frac{N_i - n_i}{N_i} S_{U2i}^2 + \right. \\
&\quad \left. \frac{1}{m} \sum_{i \in U} \frac{1}{p_i} \frac{N_i}{n_i} \sum_{j \in U_i} \frac{Q_{ij}^2}{q_{ij}} \frac{Q_{ij} - q_{ij}}{Q_{ij}} S_{U3ij}^2 \right] \\
&\equiv \frac{1}{t_U^2} [V_{PSU} + V_{SSU} + V_{TSU}] \qquad (9.17)
\end{aligned}
$$

where $S_{U1(pwr)}^2 = \sum_{i \in U} p_i (\frac{t_i}{p_i} - t_U)^2$

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 42 / 71

<!-- page 43 -->

7. 3-Stage Sampling $\quad$ 7.2 Varying Probabilities at First Stages

# Simplified $ppswr/srs/srs$ Relvariance

* Expression (9.17) is complex and not useful for sample size planning.
* To obtain a simpler formula, assume
  * $\bar{n}$ SSUs are sampled in each sample PSU
  * sampling fractions of SSUs in each PSU, $\bar{n}/N_i$ , are small
  * $\bar{\bar{q}}$ elements are selected in each sample SSU.

Specializing (9.17), the relvariance of the $pwr$-estimator of a total is:

$$
relvar(\hat{t}_{pwr}) = \frac{V(\hat{t}_{pwr})}{t_U^2} = \frac{B^2}{m} + \frac{W_2^2}{m\bar{n}} + \frac{W_3^2}{m\bar{n}\bar{\bar{q}}} \qquad (9.18)
$$

$$
B^2 = S_{U1(pwr)}^2 / t_U^2
$$

$W_2^2$ and $W_3^2$ are defined the same as in (9.16) for $srs/srs/srs$

(9.18) looks the same as (9.16) but $B^2$ is computed differently

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 43 / 71

<!-- page 44 -->

7. 3-Stage Sampling $\quad$ 7.2 Varying Probabilities at First Stages

# Relvariance with Measures of Homogeniety - 1

* The relvariance in (9.18) can also be written in terms of two measures of homogeneity (*moh*'s):

$$relvar(\hat{t}_{pwr}) = \frac{V(\hat{t}_{pwr})}{t_U^2} = \frac{\tilde{V}}{m\bar{n}\bar{\bar{q}}} \{ k_1 \delta_1 \bar{n}\bar{\bar{q}} + k_2 [1 + \delta_2 (\bar{\bar{q}} - 1)] \} \ (9.21)$$

$\tilde{V} = \frac{1}{Q - 1} \sum_{i \in U} \sum_{j \in U_i} \sum_{k \in U_{ij}} (y_k - \bar{y}_U)^2 / \bar{y}_U^2$: unit relvariance of $y$ in the population

$k_1 = (B^2 + W^2) / \tilde{V}$

$k_2 = (W_2^2 + W_3^2) / \tilde{V}$

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 44 / 71

<!-- page 45 -->

7. 3-Stage Sampling
7.2 Varying Probabilities at First Stages

# Relvariance with Measures of Homogeniety - 2

- $\delta_1 = B^2 / (B^2 + W^2)$
- $W^2 = \frac{1}{t_U^2} \sum_{i \in U} Q_i^2 S_{U3i}^2 / p_i$ with

  $S_{U3i}^2 = \frac{1}{Q_i - 1} \sum_{j \in U_i} \sum_{k \in U_{ij}} (y_k - \bar{y}_{Ui})^2$: element level variance among all elements in PSU $i$; and

  $\bar{y}_{Ui} = \sum_{j \in U_i} \sum_{k \in U_{ij}} y_k / Q_i$
- $\delta_1$ measures degree of homogeneity of elements within PSUs. Easier to think of this as measuring how much PSU totals $t_i$ vary. If PSU totals vary a lot, then $\delta_1$ will be large.
- $W^2$ in $\delta_1$ does not enter variance in (9.18) but is defined by analogy to the term in two-stage sampling in (9.11). If elements were selected directly from the sample PSUs (instead of first sampling SSUs), then $W^2$ would be the within-PSU component.

Sunghee Lee (U of Michigan)
Prac Tools Ch. 9

<!-- page 46 -->

7. 3-Stage Sampling $\quad$ 7.2 Varying Probabilities at First Stages

# Relvariance with Measures of Homogeniety - 3

* $\delta_2 = W_2^2 / (W_2^2 + W_3^2)$
* $\delta_2$ measures the homogeneity of elements within SSUs or variation of SSU totals, $t_{ij}$. If the SSU totals vary a lot then $\delta_2$ will be large.
* Household samples are often designed to have SSUs with about the same numbers of elements, $Q_{ij}$, which helps keep the $t_{ij}$'s from varying.

**See VDK Examples 9.5 and 9.6 in Class6Lab.pdf**

---

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 46 / 71

<!-- page 47 -->

8. Allocation in 2- and 3-Stage Sampling

# 8. Allocation in 2- and 3-Stage Sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 47 / 71

<!-- page 48 -->

8. Allocation in 2- and 3-Stage Sampling 8.1 Allocation in 2-Stage Sampling

# 8.1 Allocation in 2-Stage Sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 48 / 71

<!-- page 49 -->

8. Allocation in 2- and 3-Stage Sampling 8.1 Allocation in 2-Stage Sampling

# Cost Function for 2-Stage Sampling

* We model the total cost as

$$C = C_0 + C_1 m + C_2 m\bar{n}$$

$C_0$: costs that do not depend on the number of sample PSUs and elements

$C_1$: cost per sample PSU

$C_2$: cost per element

* Groves (1989) is good source for the many facets of surveys that contribute to costs.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 49 / 71

<!-- page 50 -->

8. Allocation in 2- and 3-Stage Sampling 8.1 Allocation in 2-Stage Sampling

# 2-Stage Sampling

- Per-PSU costs $C_1$ in a household survey can include recruiting and training interviewers, paying field supervisors, and field listing costs.
- Per-element costs $C_2$ could include personnel time for conducting an interview, printing costs if paper questionnaires are used, and clerical staff time to review special problems with completed or partially completed questionnaires.
- $C_0$ can include personnel time for central office staff, e.g. project manager, computer scientists to program the instrument if CAPI is used, programmers to edit the data, and statisticians to design sample, devise nonresponse follow-up procedures, and develop weighting schemes.
- *Tracking costs is difficult and often does not mesh well with survey accounting practices $\Rightarrow$ you may have to be satisfied with fairly rough unit cost estimates.*

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 50 / 71

<!-- page 51 -->

8. Allocation in 2- and 3-Stage Sampling 8.1 Allocation in 2-Stage Sampling

# Optimal Allocation for 2-Stage Sampling - 1

* $relvar(\hat{t}_{pwr})$ is the same when $srs/srs$ or $ppswr/srs$ and $\bar{n}$ elements are selected in each sample PSU (see (9.5) and (9.9)):

$$
\frac{V(\hat{t}_{pwr})}{t_U^2} \doteq \frac{\tilde{V}}{m\bar{n}} k[1 + \delta(\bar{n} - 1)] \qquad (9.23)
$$

Formulas (9.24), (9.25) and (9.26) apply to both $srs/srs$ or $ppswr/srs$ as long as $B^2$ and $W^2$ are appropriately defined.

* Optimal number of units to select per PSU, i.e., the number that minimizes the approximate relvariance, is

$$
\bar{n}_{opt} = \sqrt{\frac{C_1}{C_2} \frac{1 - \delta}{\delta}} \qquad (9.24)
$$

  * Note that only ratio of unit costs needs to be known in order to compute $\bar{n}_{opt}$ . The more a PSU costs, the more elements should be selected within each PSU. On the other hand, the larger $\delta$ is, the fewer elements should be selected per PSU.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 51 / 71

<!-- page 52 -->

8. Allocation in 2- and 3-Stage Sampling 8.1 Allocation in 2-Stage Sampling

# Optimal Allocation for 2-Stage Sampling - 2

* To find optimal $m$ for a fixed total cost, we substitute $\bar{n}_{opt}$ into the cost function to obtain

$$m_{opt} = \frac{C - C_0}{C_1 + C_2 \bar{n}_{opt}} \tag{9.25}$$

* Alternatively, to find optimal $m$ for a fixed relvariance, $CV_0^2$, we substitute $\bar{n}_{opt}$ into the relvariance formula to obtain

$$m_{opt} = \frac{\tilde{V}k}{\bar{n}_{opt} CV_0^2} [1 + \delta(\bar{n}_{opt} - 1)] \tag{9.26}$$

* In either the case of finding sample sizes for a fixed total cost or for a target $CV$, the total sample size is $m_{opt}\bar{n}_{opt}$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 52 / 71

<!-- page 53 -->

8. Allocation in 2- and 3-Stage Sampling $\quad$ 8.1 Allocation in 2-Stage Sampling

# Figure 9.1: Sensitivity of Optimal $n$ to $\delta$ - 1

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 53 / 71

*[Figure: The figure consists of a 2x2 grid of line plots showing the relationship between CV (vertical axis) and nbar, or sample units per PSU (horizontal axis, from 0 to 30), across four different values of delta (0.01, 0.05, 0.1, and 0.2). Each plot compares three curves representing cost ratios C1/C2 of 1, 2, and 3, demonstrating that as delta increases, the minimum CV (marked by a black dot) shifts toward smaller nbar values and the subsequent upward slope becomes much steeper.]*

<!-- page 54 -->

8. Allocation in 2- and 3-Stage Sampling 8.1 Allocation in 2-Stage Sampling

# Figure 9.1: Sensitivity of Optimal $n$ to $\delta$ - 2

* Figure 9.1 graphs CV based on (9.23), assuming that $k = 1$, of an estimated total versus a range of values of $\bar{n}$ for $\delta = 0.01, 0.05, 0.10$, and $0.20$.
* A dot is placed on each curve where CV is a minimum.
* Conventional wisdom: "optimum is flat" in the sense that a range of sample sizes will give a CV that is near the minimum value. Often true in stratified sampling where the allocation to the strata can depart from optimal allocation and still be reasonably efficient.
* Fig. 9.1 illustrates that "flatness" depends $\delta$. If $\delta = 0.01$, sampling anywhere from about 7 to 30 elements per PSU is fairly efficient. When $\delta = 0.20$, $\bar{n}$ of 2, 3, or 4 gives CV near optimum, but allocating more than that to each PSU quickly becomes inefficient.

**See VDK Example 9.7 in Class6Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 54 / 71

<!-- page 55 -->

8. Allocation in 2- and 3-Stage Sampling 8.2 Allocation in 3-Stage Sampling

# 8.2 Allocation in 3-Stage Sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 55 / 71

<!-- page 56 -->

8. Allocation in 2- and 3-Stage Sampling $\quad$ 8.2 Allocation in 3-Stage Sampling

# Cost Function for 3-Stage Sampling

* We model the total cost as

$$C = C_0 + C_1m + C_2m\bar{n} + C_3m\bar{n}\bar{\bar{q}}$$

$C_0$: costs that do not depend on the number of sample PSUs and elements

$C_1$: cost per sample PSU

$C_2$: cost per sample SSU

$C_3$: cost per element

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 56 / 71

<!-- page 57 -->

8. Allocation in 2- and 3-Stage Sampling 8.2 Allocation in 3-Stage Sampling

# Optimal Sample Sizes

* Minimizing $ppswr/srs/srs$ relvariance in (9.21) subject to a fixed total cost gives the following optima:

$$\bar{\bar{q}}_{opt} = \sqrt{\frac{1-\delta_2}{\delta_2}\frac{C_2}{C_3}} \qquad (9.29)$$

$$\bar{n}_{opt} = \frac{1}{\bar{\bar{q}}_{opt}}\sqrt{\frac{1-\delta_2}{\delta_1}\frac{C_1}{C_3}\frac{k_2}{k_1}} \qquad (9.30)$$

$$m_{opt} = \frac{C - C_0}{C_1 + C_2\bar{n} + C_3\bar{n}_{opt}\bar{\bar{q}}_{opt}} \qquad (9.31)$$

* If a target relvariance is set at $CV_0^2$, then the optima for $\bar{\bar{q}}_{opt}$ and $\bar{n}_{opt}$ are the same as above but $m_{opt}$ is:

$$m_{opt} = \frac{\tilde{V}}{CV_0^2\bar{n}_{opt}\bar{\bar{q}}_{opt}}\{k_1\delta_1\bar{n}_{opt}\bar{\bar{q}}_{opt} + k_2[1 + \delta_2(\bar{\bar{q}}_{opt} - 1)]\} \ (9.32)$$

* Total sample size is $m_{opt}\bar{n}_{opt}\bar{\bar{q}}_{opt}$.

**See VDK Example 9.8 in Class6Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 57 / 71

<!-- page 58 -->

9. Allocation with Fixed Sample of PSUs

# 9. Allocation with Fixed Sample of PSUs

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 58 / 71

<!-- page 59 -->

9. Allocation with Fixed Sample of PSUs

# Introduction

* In some applications, a fixed set of PSUs is used for multiple surveys and the main flexibility in the design is deciding how many elements to select from those PSUs or SSUs within PSU and then elements.
* Often the case for household samples where an organization may have a "master" sample of PSUs that it uses for different household surveys.
* Reusing a given sample of PSUs saves the cost of recreating a frame of PSUs, designing the sample, and making the selections.
* Having a master sample of PSUs may also allow the same set of trained and trusted field personnel to be employed for data collection.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 59 / 71

<!-- page 60 -->

9. Allocation with Fixed Sample of PSUs

# Optimal $\bar{n}$: Fixed Cost, 2 Stages

* If the total cost, $C = C_0 + C_1 m + C_2 m\bar{n}$, is fixed along with the set of sample PSUs, the number of elements per PSU is determined by the cost constraint only:

$$
\bar{n}_{opt} = \frac{C - C_0 - C_1 m}{C_2 m} \quad \quad \quad (9.33)
$$

* If this sample size is not large enough to achieve the desired $CV$ targets (i.e., if precision target is not met), then choices are
  * Be satisfied with lower precision than desired
  * Increase the number of sample PSUs: Add $m$ and decrease $\bar{n}$ in a way to stay within the budget. May or may not be possible.
  * Increase budget and total sample size: Depends on the sponsor.

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 60 / 71

<!-- page 61 -->

9. Allocation with Fixed Sample of PSUs

# Optimal $\bar{n}$: Fixed $CV$

* If target $CV$ is set and we minimize the cost, then find number of elements to sample per PSU by solving for $\bar{n}$ in the approximate relvariance formula as

$$CV_0^2 = \frac{V(\hat{t}_\pi)}{t_U^2} = \frac{1}{m\bar{n}} \tilde{V}k[1 + \delta(\bar{n} - 1)]$$

* Resulting in

$$\bar{n}_{opt} = \frac{1 - \delta}{CV_0^2 m / \tilde{V}k - \delta} \quad (9.34)$$

**See VDK Example 9.9 in Class6Lab.pdf**

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 9 $\quad$ 61 / 71

<!-- page 62 -->

10. Estimating Variance Components

# 10. Estimating Variance Components

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 62 / 71

<!-- page 63 -->

10. Estimating Variance Components

# 2-Stage Sampling - 1

* Given an estimate of variance from a prior survey, solve for $\delta$ in the relvariance formulas (9.5) or (9.9)
* Suppose that $v(\hat{t}_\pi)$ is an estimate of the variance of the $\pi$-estimator appropriate for the sample design that was used. (In the case of *ppswr* sampling at the first stage, we use $v(\hat{t}_{pwr})$).
* Dividing $v(\hat{t}_\pi)$ by an estimate of the variance of a $\pi$-estimator from a simple random sample of the same size gives the design effect, $\text{deff}(\hat{t}_\pi) = v(\hat{t}_\pi)/v_{srs}$.
* Setting $\text{deff}(\hat{t}_\pi) = k(1 + \delta(\bar{n} - 1))$ and solving for $\delta$ gives

$$\hat{\delta} = \frac{1}{\bar{n} - 1} \left[ \frac{1}{k} \frac{v(\hat{t}_\pi)}{v_{srs}} - 1 \right] = \frac{k^{-1}\text{deff}(\hat{t}_\pi) - 1}{\bar{n} - 1} \qquad (9.37)$$

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 9 $\qquad$ 63 / 71

<!-- page 64 -->

10. Estimating Variance Components

# 2-Stage Sampling - 2

* Direct estimates of components can be made in special cases.
* We specialize *ppswr/srs*.
* $V(\hat{t}_{pwr}) = V_{PSU} + V_{SSU}$ as shown in (9.13). Estimators are:
  $$v_{PSU} = \frac{1}{m(m - 1)} \sum_{i \in s} \left(\frac{\hat{t}_{i\pi}}{p_i} - \hat{t}_{pwr}\right)^2 - \frac{1}{m^2} \sum_{i \in s} \frac{\hat{V}_i}{p_i^2}$$
  $$v_{SSU} = \sum_{i \in s} \frac{\hat{V}_i}{(mp_i)^2} \text{ with}$$
  * $\hat{V}_i = \frac{N_i^2}{n_i}(1 - f_i)\hat{S}_{2i}^2$
  * $\hat{S}_{2i}^2 = (n_i - 1)^{-1} \sum_{k \in S_i} (y_k - \bar{y}_{si})^2$; and
  * $\bar{y}_{si} = \sum_{k \in s_i} y_k / n_i$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 64 / 71

<!-- page 65 -->

10. Estimating Variance Components

# 2-Stage Sampling - 3

* $v_{PSU}$ is an estimator of the variance of $\hat{t}_{pwr}$ and is called the *ultimate cluster* variance estimator.
* If $w_k = (mp_i\pi_{k|i})^{-1}$ is full sample weight for element $k$ in PSU $i$, the first component of $v_{PSU}$ can also be written as

$$\frac{1}{m(m - 1)} \sum_{i \in s} \left(\frac{\hat{t}_{i\pi}}{p_i} - \hat{t}_{pwr}\right)^2$$

$$= \frac{m}{(m - 1)} \sum_{i \in s} \left( \sum_{k \in s_i} w_k y_k - \frac{\sum_{i \in s} \sum_{k \in s_i} w_k y_k}{m} \right)^2$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 65 / 71

<!-- page 66 -->

10. Estimating Variance Components

# 2-Stage Sampling - 4

* If same number of elements, $n_i = \bar{n}$, is sampled in each PSU and $\bar{n}/N_i$, estimators of $B^2$ and $W^2$ in (9.10) and (9.11) are:

$$
\hat{B}^2 = \frac{1}{\hat{t}_{pwr}^2} \left[ \frac{1}{m-1} \sum_{i \in s} \left( \frac{\hat{t}_{i\pi}}{p_i} - \hat{t}_{pwr} \right)^2 - \sum_{i \in s} \frac{\hat{V}_i}{mp_i^2} \right] = \frac{mv_{PSU}}{\hat{t}_{pwr}^2} \quad (9.40)
$$

$$
\hat{W}^2 = \frac{1}{\hat{t}_{pwr}^2} \sum_{i \in s} \frac{N_i^2 \hat{S}_{2i}}{mp_i^2} \quad (9.41)
$$

* Implied estimator of $\delta$ is: $\quad \hat{\delta} = \hat{B}^2 / (\hat{B}^2 + \hat{W}^2)$
* A practical difficulty with estimator for $B^2$ is that it involves a subtraction. There is no guarantee that $\hat{B}^2$ will be positive.

**See VDK Example 9.11 in Class6Lab.pdf**

---
Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 9 $\qquad$ 66 / 71

<!-- page 67 -->

11. Models for Anticipated Variance Components

# 11. Models for Anticipated Variance Components

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 67 / 71

<!-- page 68 -->

11. Models for Anticipated Variance Components

# 2-Stage Sampling - 1

* Design-based variance component analysis can be numerically unstable and give negative estimates.
* Software (like R, SAS, Stata, etc.) have algorithms that are better
* To incorporate a variance component model, use anticipated variance
$$AV(\hat{t}) = E_M \left\{ E_\pi \left[ (\hat{t} - t_U)^2 \right] \right\} - \left[ E_M \left\{ E_\pi (\hat{t} - t_U) \right\} \right]^2$$
* If $\hat{t}$ is design-unbiased or approximately so (i.e., $E_\pi(\hat{t}) \doteq t_U$),
$$AV(\hat{t}) = E_M \left[ var_\pi(\hat{t} - t_U) \right]$$
* Compute model expectation of a formula like (9.8), giving model variance components that can be estimated using standard software.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 68 / 71

<!-- page 69 -->

11. Models for Anticipated Variance Components

# 2-Stage Sampling - 2

* In a clustered population, simplest model to consider is:

$$y_k = \mu + \alpha_i + \epsilon_{ik}, k \in U_i \quad (9.42)$$

with cluster random effect $\alpha_i \sim (0, \sigma_\alpha^2)$, random error $\epsilon_{ik} \sim (0, \sigma_\epsilon^2)$, and independent errors.

* The model-expectation of the design-variance can be computed under this model, but for sample size calculation, only the approximate expectations of $B^2$ and $W^2$ for two-stage sampling are needed.

Sunghee Lee (U of Michigan) | Prac Tools Ch. 9 | 69 / 71

<!-- page 70 -->

11. Models for Anticipated Variance Components

# 2-Stage Sampling - 3

* Consider the variance components in $srs/srs$ sampling for a two-stage design. The model-expectations of $S_{U1}^2$ and $S_{U2i}^2$ from (9.2) are:

$$E_M(S_{U1}^2) = (\sigma_\alpha^2 + \mu^2)S_N^2 + \bar{N}^2\sigma_\alpha^2 + \sigma_\epsilon^2$$

$$E_M(S_{U2i}^2) = \sigma_\epsilon^2 \text{, where}$$

  * $\bar{N} = \sum_{i \in U} N_i/M$: the average number of elements per cluster
  * $S_N^2 = \sum_{i \in U} (N_i - \bar{N})^2/(M - 1)$; and
  * $M$ is assumed to be large.

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 70 / 71

<!-- page 71 -->

11. Models for Anticipated Variance Components

# 2-Stage Sampling - 4

- The anticipated *moh* is then

$$
E_M(\delta) \doteq \frac{(\sigma_\alpha^2 + \mu^2)\nu_N^2 + \sigma_\alpha^2 + \sigma_\epsilon^2/\bar{N}^2}{(\sigma_\alpha^2 + \mu^2)\nu_N^2 + \sigma_\alpha^2 + \sigma_\epsilon^2[1 + (\nu_N^2 + \bar{N}^{-2})]} \tag{9.43}
$$

  where $\nu_N^2 = S_N^2/\bar{N}^2$ is the relvariance of the PSU sizes.

- If $N_i = \bar{N}$, then $\nu_N^2 = 0$. In that case, if $\bar{N}$ is large

$$
E_M(\delta) \doteq \frac{\sigma_\alpha^2 + \sigma_\epsilon^2/\bar{N}^2}{\sigma_\alpha^2 + \sigma_\epsilon^2(1 + 1/\bar{N}^2)} \doteq \frac{\sigma_\alpha^2}{\sigma_\alpha^2 + \sigma_\epsilon^2} \tag{9.44}
$$

- Expression (9.44) is the correlation under model (9.42) of any two elements in the same cluster.

**See VDK Example 9.13 in Class6Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 9 71 / 71
