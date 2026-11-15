---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_3"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_3.pdf"
pages: 17
sha256: "75eeef4cac3dd94d57390fa81dc2766a20f28607c0481986e14d0cc1a8a3ab7c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:50"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

SURV/SURVMETH 701

Lecture Notes: Module 3

## Sampling Error Calculation Models

Instructor: Yan Li

e-mail: [email]

1

<!-- page 2 -->

# Brief Review

* Concepts
  - Complex sample designs
  - Design-based inference
  - Design effects
* Survey weighting
  - Sample selection weights
  - Nonresponse weighting adjustments
  - Poststratification / Calibration

2

<!-- page 3 -->

# Sampling Error Calculation Model: National Comorbidity Survey (NCS)

**Features:**

1. Best <u>approximation</u> to the original sample design
2. Compatible with computational methods!

<u>NCS Sampling Error Calculation Model</u>:

| <u>Design</u> | <u>SE Model</u> |
| :--- | :--- |
| 1. Stratified | 1. Stratified |
| 2. Multi-stage | 2. Ultimate clusters |
| 3. 1 PSU / stratum | 3. 2 UCs / stratum |
| 4. PSUs WOR | 4. UCs WR |

Effect on Sampling Error Estimates:

TSL, BRR, and JRR estimates of SEs will tend to be <u>overestimates</u> of true sampling errors under complex sample designs.

3

<!-- page 4 -->

# Sampling Error Calculation Models

## Ultimate Cluster Concept

Ultimate Cluster of Size $n_a = 4$:

| PSU | SSU | HU |
| :---: | :---: | :---: |
| 1 | 1 | 2 |
| 1 | 1 | 5 |
| 1 | 2 | 1 |
| 1 | 2 | 4 |

4

<!-- page 5 -->

# Ultimate Cluster Concepts

* Typically, one ultimate cluster is selected from each PSU, based on multiple stages of selection. Variance estimation assumes PSUs are sampled with replacement. Sampling without replacement is assumed for all other stages.

* Ultimate clusters are then considered the clusters for variance estimation: we assume a single-stage, with-replacement selection of ultimate clusters, where all elements within each ultimate cluster are selected.

* These assumptions greatly simplify formulas used for variance estimation! Assumptions will generally result in slight over-estimates of variance (see Kish, 1965, Section 5.3).

5

<!-- page 6 -->

# Ultimate Cluster Concepts

* Variance estimation is based on ultimate clusters of units; some sampling error calculation models will collapse or combine the ultimate clusters, resulting in sampling error computation units (SECUs); see ASDA, Section 4.3.

6

<!-- page 7 -->

# Sampling Error Calculation: <u>Collapsing</u> Strata

* Generally used when one PSU is selected from each sample design stratum. Not common, but used by UM Survey Research Center since 1960.

* Collapsing strata for variance estimation produces a **positive** bias in the estimated variance.

* Pairs of design strata that are collapsed to form a single SE calculation stratum should be approximately equal in size (Kish 8.6B).

7

<!-- page 8 -->

# Sampling Error Calculation: <u>Collapsing</u> Strata

| | Sample <u>Design</u> | $\longrightarrow$ | Variance <u>Estimate</u> |
| :--- | :--- | :---: | :--- |
| Strata | $h = 1,\dots,H$ | | $l = 1,\dots,L=H/2$ |
| <u>Stratum</u> | | | |
| 1 | PSU A | $\longrightarrow$ | PSU A |
| 2 | PSU B | | PSU B |
| | | | Note: 1 stratum with two PSUs! |

8

<!-- page 9 -->

# Sampling Error Calculation: <u>Combined</u> Strata

* Typically used when the sample design contains many strata and the data producer wishes to simplify “stratum” coding for secondary users

* Also used when the data producer is concerned about disclosure protection (e.g., PSU sample sizes are relatively small)

* Combining selections from two strata results in no bias for the variance estimator, unlike collapsing

* However, the precision of the variance estimate is reduced (fewer degrees of freedom); remember that variance estimates are themselves estimates!

9

<!-- page 10 -->

# Sampling Error Calculation: <u>Combined</u> Strata

<u>**Example 1**</u>

| Stratum | Sample Design | Variance Estimation |
| :--- | :--- | :--- |
| $h$ | PSU A<br>PSU B | SECU $1 = (\text{A,C})$ |
| $h'$ | PSU C<br>PSU D | SECU $2 = (\text{B,D})$ |

Note: Two strata with two PSUs each are combined to form one stratum with two SECUs (sampling error computation units). Larger, more heterogeneous clusters for subgroup variance estimation!

10

<!-- page 11 -->

# Sampling Error Calculation: <u>Combined</u> Strata

$$
var(y) = \sum_{c} (y_{c1} - y_{c2})^2
$$

where: $c$ denotes the combined stratum from design strata h & h'

$$
E \, var(y) = E \sum_{h} (y_{h1} - y_{h2})^2 + E \sum_{h \neq h'} (y_{h1} - y_{h2})(y_{h'1} - y_{h'2})
$$

* Covariance term is zero if selections from strata $h$ and $h'$ are independent.
* Combining selections from two strata results in NO bias for variance estimator.
* Precision of variance estimate is reduced (fewer degrees of freedom).

11

<!-- page 12 -->

# Sampling Error Calculation: Random Groups

* Typically used when the sample design strata contain many PSUs and the data producer wishes to simplify "SECU" coding or limit disclosure risk

* The random groups method is similar to combining strata

* The random groups method is commonly used to build SECUs in self-representing PSUs where area segments are the first units actually sampled

* Variance estimates under the random groups method are not biased

12

<!-- page 13 -->

# Sampling Error Calculation: Random Groups

| | Sample Design | Variance Estimation |
| :--- | :--- | :--- |
| Stratum 1 | PSU A | SECU 1 (A,C,F,H)\* |
| | PSU B | |
| | PSU C | |
| | PSU D | SECU 2 (B,D,E,G)\* |
| | PSU E | |
| | PSU F | |
| | PSU G | |
| | PSU H | |

\*Randomly assigned. This idea also applies in the case where a single cluster in a stratum needs to be randomly divided into two clusters for variance estimation (in that case, the PSUs above might be respondents from the single cluster).

13

<!-- page 14 -->

# National Comorbidity Survey (Kessler, 1990)

| Stratum | Secu | PSU | Segment Numbers |
| :--- | :--- | :--- | :--- |
| 1 | 1 | 1 | 4 9 14 19 25 29 34 39 45 |
| | 2 | 1 | 1 5 10 15 20 26 31 35 40 46 |
| 2 | 1 | 1 | 2 7 11 16 22 27 32 37 41 47 |
| | 2 | 1 | 3 8 13 17 23 28 33 38 43 49 |
| 3 | 1 | 2 | 3 8 13 18 22 28 33 38 |
| | 2 | 2 | 4 9 14 19 24 30 34 |
| 4 | 1 | 2 | 1 6 10 15 20 25 31 36 |
| | 2 | 2 | 2 7 12 16 21 26 32 37 |
| 5 | 1 | 3 | 1 6 11 15 20 25 31 |
| | 2 | 3 | 2 7 12 17 21 26 32 |
| 6 | 1 | 3 | 3 8 13 18 23 27 33 |
| | 2 | 3 | 5 9 14 18 24 30 35 |
| 7 | 1 | 4 | 1 3 7 9 11 14 16 18 20 22 |
| | 2 | 4 | 2 5 8 10 13 15 17 19 21 23 |
| 8 | 1 | 5 | 2 4 6 8 10 12 15 17 20 |
| | 2 | 5 | 1 3 5 7 9 11 14 16 18 21 |
| 9 | 1 | 6 | 1 3 6 8 11 13 15 18 |
| | 2 | 6 | 2 5 7 9 12 14 17 |
| 10 | 1 | 7 | 2 4 6 8 10 12 14 16 |
| | 2 | 7 | 1 3 5 7 9 11 13 15 |
| 11 | 1 | 8 | 1 3 5 7 9 11 13 15 |
| | 2 | 8 | 2 4 6 8 10 12 14 16 |
| 12 | 1 | 9 | 2 4 6 8 10 12 14 |
| | 2 | 9 | 1 3 5 7 9 11 13 15 |
| 13 | 1 | 10 | 1 3 5 7 9 11 |
| | 2 | 10 | 2 4 6 8 10 12 |
| 14 | 1 | 11 | 1 3 5 7 9 11 |
| | 2 | 11 | 2 4 6 8 10 12 |
| 15 | 1 | 12 | 2 4 6 8 10 12 |
| | 2 | 12 | 1 3 5 7 9 11 |
| 16 | 1 | 13 | 1 3 5 7 9 11 |
| | 2 | 13 | 2 4 6 8 10 12 |
| 17 | 1 | 14 | 2 4 6 8 10 12 |
| | 2 | 14 | 1 3 5 7 9 11 |
| 18 | 1 | 15 | 1 3 5 7 9 11 |
| | 2 | 15 | 2 4 6 8 10 12 |
| 19 | 1 | 16 | 2 4 6 8 10 12 |
| | 2 | 16 | 1 3 5 7 9 11 |
| 20 | 1 | 17 | All Segments (Nonself-representing) |
| | 2 | 18 | |
| 21 | 1 | 21 | |
| | 2 | 23 | |

14

<!-- page 15 -->

| Stratum | Secu | PSU | Segment Numbers |
| :--- | :--- | :--- | :--- |
| 22 | 1<br>2 | 24<br>34 | All Segments (Nonself-representing)<br>$\downarrow \quad \downarrow$ |
| 23 | 1<br>2 | 26<br>27 | $\downarrow \quad \downarrow$ |
| 24 | 1<br>2 | 28<br>29 | $\downarrow \quad \downarrow$ |
| 25 | 1<br>2 | 31<br>32 | $\downarrow \quad \downarrow$ |
| 26 | 1<br>2 | 33<br>47 | $\downarrow \quad \downarrow$ |
| 27 | 1<br>2 | 36<br>39 | $\downarrow \quad \downarrow$ |
| 28 | 1<br>2 | 40<br>42 | $\downarrow \quad \downarrow$ |
| 29 | 1<br>2 | 43<br>45 | $\downarrow \quad \downarrow$ |
| 30 | 1<br>2 | 44<br>76 | $\downarrow \quad \downarrow$ |
| 31 | 1<br>2 | 49<br>50 | $\downarrow \quad \downarrow$ |
| 32 | 1<br>2 | 53<br>55 | $\downarrow \quad \downarrow$ |
| 33 | 1<br>2 | 56<br>56 | $\downarrow \quad \downarrow$ |
| 34 | 1<br>2 | 57<br>60 | $\downarrow \quad \downarrow$ |
| 35 | 1<br>2 | 58<br>59 | $\downarrow \quad \downarrow$ |
| 36 | 1<br>2 | 63<br>64 | $\downarrow \quad \downarrow$ |
| 37 | 1<br>2 | 65<br>66 | $\downarrow \quad \downarrow$ |
| 38 | 1<br>2 | 68<br>70 | $\downarrow \quad \downarrow$ |
| 39 | 1<br>2 | 73<br>74 | $\downarrow \quad \downarrow$ |
| 40 | 1<br>2 | 77<br>78 | $\downarrow \quad \downarrow$ |
| 41 | 1<br>2 | 80<br>81 | $\downarrow \quad \downarrow$ |
| 42 | 1<br>2 | 82<br>84 | All Segments (Nonself-representing) |

15

<!-- page 16 -->

# Notes on NCS Sampling Error Calculation Model

* Self-representing (SR) PSUs (1-19) are included in the NCS sample with certainty, and second stage sampling of area segments is really the first random selection that is performed
* Ultimate clusters are selected from each area segment
* In SR PSUs 1-19, randomly selected segments at the second stage (or their ultimate clusters) are randomly combined (or grouped) into two SECUs within each sampling error stratum

16

<!-- page 17 -->

# Notes on NCS Sampling Error Calculation Model

* Larger SR PSUs (1-3), dubbed “Super” PSUs at SRC (e.g., New York, Los Angeles), define multiple strata for SE calculations
* Smaller SR PSUs (4-19) define their own strata
* Non-self-representing (NSR) PSUs (20+) are randomly selected, with one ultimate cluster selected from each NSR PSU
* Two adjacent NSR PSUs (or their ultimate clusters) are “collapsed” into one SE stratum, with two ultimate clusters
* The SE codes in the first two columns are often randomly scrambled (or masked) to prevent identification of original PSUs

17
