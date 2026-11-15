---
id: "jpsm/sampling_1_SURV626/lectures/SURV_626_-_Unit_1_Course_Perspectives"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "SURV 626: Sampling"
original: "sampling_1_SURV626/lectures/SURV 626 - Unit 1 Course Perspectives.pdf"
pages: 23
sha256: "cea3aaffbf33f24c63754df412ccbd15503824dc1558be0bcdeae09be7cfee96"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:11"
---

<!-- page 1 -->

# SURV 626: Sampling

---

Raphael Nishimura

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

1

<!-- page 2 -->

# Table of contents

---

* **Unit 1: Preliminaries**
  - Course Description
  - Course Perspectives
* **Unit 2: Elements**
  - Simple Random Sampling
  - Frame Problems
* **Unit 3: Stratification**
  - Stratified Random Sampling
  - Allocations
  - Stratification Topics
* **Unit 4: Systematic selection**
  - Systematic Sampling
  - Sampling Variance Estimation
* **Unit 5 Clusters**
  - Cluster Sampling
  - Two-Stage Cluster Sampling
  - Sub-sample Size
* **Unit 6: Unequal Sized Clusters**
  - Unequal Sized Cluster Sampling
  - Stratified Unequal Sized Cluster
  - Complex Designs
  - PPS/PPeS
* **Unit 7: Sampling Variance Estimation**
  - Forming Computing Units
  - Replicated Sampling
  - Balanced Repeated Replication
  - Jacknife Repeated Replication

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

2

<!-- page 3 -->

# Unit 1: Preliminaries
# Course Description

---

3

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 4 -->

# Content

* Design vs. Analysis
  - Techniques (SRS, stratification, clustering, etc.)
  - Sampling variance estimation
* Finite population
* Design-based vs. Model-based inference
* Descriptive vs. Analytic
* Statistics
  - Means, proportions, totals
  - Variances
  - Correlations, regression coefficients

4
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 5 -->

# Unit 1: Preliminaries
# Course Perspectives

---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

5

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 6 -->

# Unit 1: Preliminaries
# Course Perspectives

---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

6

<!-- page 7 -->

# A. Design

---

* Research design
  - Experiments
    * Dependent variables
    * Factors
    * Control or randomization of disturbing variables
  - Quasi-experimental: observational
  - Survey samples: observational

* Design characteristics
  - Realism
  - Randomization
  - “Representation”

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

7

<!-- page 8 -->

# Sampling designs

* Probability sampling designs
  - Simple random sampling
  - Stratified sampling
  - Cluster sampling
  - Stratified cluster sampling, stratified multistage sampling
* Non-probability sampling designs
  - Convenience, haphazard
  - Snowball, Respondent Driven Sampling (RDS)
  - Volunteer
  - Quota sampling

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

8

<!-- page 9 -->

# Sample Surveys

* Define problem & population
  * Design instrument $\rightarrow$ Specify procedures $\rightarrow$ Recruit, hire, train staff
  * Design sample $\rightarrow$ Develop sampling frame $\rightarrow$ Select sample
* Collect data $\rightarrow$ Process data $\rightarrow$ Analyze & report

9

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 10 -->

# Unit 1: Preliminaries
# Course Perspectives

---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

10

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 11 -->

# Unit 1: Preliminaries
## Course Perspectives

---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

11

<!-- page 12 -->

# B. Typology & vocabulary

---

* Finite population
* Large population & sample
* Randomization
* “Representative”
* Efficient (precision per unit cost)

12

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 13 -->

# Population

Target

Survey

Frame

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

13

<!-- page 14 -->

# Survey Sampling Design Typology

| **Control** | **Unit** | **Chance** | |
| :--- | :--- | :---: | :---: |
| | | *Equal* | *Unequal* |
| *None* | *Element* | SRS or systematic | Non-epsem element |
| | *Cluster* | Cluster | Non-epsem cluster |
| *Grouped* | *Element* | Proportionate stratified random | Disproportionate stratified random |
| | *Cluster* | Proportionate stratified cluster | Disproportionate stratified cluster |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

14

<!-- page 15 -->

# Additional vocabulary

* Observation
  - Coverage
  - Response
* Quality
  - Reliability, variance
  - Validity, bias
* Properties
  - Unbiasedness
  - Precision
  - Accuracy (mean square error)
* Sampling distribution
  - Expectation
  - Standard error
* Inference
  - Central limit theorem
  - Confidence interval
  - Normal & t distributions
* Non-probability sampling
  - Volunteer
  - Purposive, judgment
  - Quota
* Measurability
* Sample design
  - Plan
  - Estimation

15

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 16 -->

# Unit 1: Preliminaries
# Course Perspectives

---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

16

<!-- page 17 -->

# Unit 1: Preliminaries
# Course Perspectives

---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

17

<!-- page 18 -->

# C. Notation: Population

* $N$ elements labels $i = 1, 2, ..., N$
* Characteristics denoted $Y_1, Y_2, ..., Y_N$

$$Y = Y_1 + Y_2 + ... + Y_N$$

$$\bar{Y} = Y / N$$

$$P = Y / N$$

$$S^2 = \frac{1}{N-1}\sum_{i=1}^N (Y_i - \bar{Y})^2$$

$$S^2 = \left(\frac{1}{N-1}\right)\left(\sum_{i=1}^N Y_i^2 - Y^2 / N\right)$$

$$S^2 = \left(\frac{N}{N-1}\right)P(1-P)$$

18

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 19 -->

# Sample

* Sample $n$ elements from $N$, $i = 1, 2, ..., n$
* Values denoted as $y_1, y_2, ..., y_n$

$$y = y_1 + y_2 + ... + y_n$$

$$\bar{y} = y / n$$

$$p = y / n$$

$$s^2 = \frac{1}{n - 1} \sum_{i=1}^n (y_i - \bar{y})^2$$

$$s^2 = \left( \frac{1}{n - 1} \right) \left( \sum_{i=1}^n y_i^2 - y^2 / n \right)$$

$$s^2 = \left( \frac{n}{n - 1} \right) p(1 - p) \approx p(1 - p)$$

$$f = n / N \text{ and } F = f^{-1} = N / n$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

19

<!-- page 20 -->

# Unit 1: Preliminaries
# Course Perspectives

---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

20

<!-- page 21 -->

# Unit 1: Preliminaries
# Course Perspectives
---

A. Design
B. Typology & vocabulary
C. Notation
D. Sampling distribution

21
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 22 -->

# D. Population distribution

Frequency (elements)

$\bar{Y}$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

22

<!-- page 23 -->

# Sampling distribution

## Sampling Distribution of Sample Means of Individual Samples

* **Sample realizaton 1**
* **Sample realization 2**
* **Sample realization S**

$\bar{y}$

(variance called $V(\bar{y})$)

(variance of each sample realization called $s^2$)

**Figure 4.2 Distributions of $y$ Variable from Sample Realizations Samples and the Sampling Distribution of the Mean**

23

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS
