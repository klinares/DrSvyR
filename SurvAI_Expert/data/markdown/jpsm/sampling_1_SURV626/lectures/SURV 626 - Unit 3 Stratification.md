---
id: "jpsm/sampling_1_SURV626/lectures/SURV_626_-_Unit_3_Stratification"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "Unit 3: Stratification"
original: "sampling_1_SURV626/lectures/SURV 626 - Unit 3 Stratification.pdf"
pages: 82
sha256: "8e93a2c8753fb0501ffd51eab4d311fb4f9ee39fcebc3dad394c062377206523"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:12"
---

<!-- page 1 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

82

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 2 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

83

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 3 -->

# A. Purpose of stratification

- Example: Estimate the mean energy consumption of commercial buildings in a state (no. of kW-h)
- Frame with $N = 5,318$ commercial buildings

| Building ID | Location | Size | ... |
| :---: | :---: | :---: | :---: |
| 1 | Area 1 | 580,200 | |
| 2 | Area 1 | 45,630 | |
| $\vdots$ | $\vdots$ | $\vdots$ | |
| 5,318 | Area 23 | 360,380 | |

- Objectives:
  - Control the distribution of sample buildings by size (square footage)
  - Improve the precision over SRS

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

84

<!-- page 4 -->

# SRS review

* Objective, randomized selection
* Every element has an equal chance of selection
* Every possible sample has the same probability of being drawn
* Even "bad" samples have an equal chance of being selected
  - “Bad samples”: a break down of the randomization principle
* Further, other sample designs can achieve smaller sampling error for the same cost
* Or same sampling error for lower cost

85
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 5 -->

# Stratified sampling

* Objective:
  - Can we sample to avoid, or even eliminate, "bad" samples?
  - Can we achieve smaller sampling error for the same cost or same sampling error for lower cost?
* Stratification uses information other than labels (i.e., $i = 1, 2, \dots, N$)
  - "Auxiliary information" used to create strata
  - Group elements into $H$ mutually exclusive and exhaustive groups (strata)
  - Select samples from each stratum
  - Compute estimates for each stratum, and combine

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

86

<!-- page 6 -->

# Stratified sampling: Example

* Control distribution of the sample buildings by size (square footage):

| Stratum | Group | Count |
| :--- | :--- | ---: |
| 1 | $< 50\text{K sq. ft.}$ | 1,182 |
| 2 | $50 - 250\text{K}$ | 1,846 |
| 3 | $250 - 4,000\text{K}$ | 1,395 |
| 4 | $>= 4,000\text{K}$ | 895 |
| Total | | 5,318 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

87

<!-- page 7 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

88

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 8 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

89

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 9 -->

# B. Notation

* Notation for stratified sampling is same as that for SRS, with a subscript to denote strata
* For the population $N$ elements in $H$ strata with $N_h$ elements in stratum $h$:
  - $\sum_{h=1}^{H} N_h = N_1 + N_2 + \dots + N_H = N$
  - $Y_{h1}, Y_{h2}, \dots, Y_{hN_h}, h = 1, \dots, H$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

90

<!-- page 10 -->

# Population level

* For each stratum $h$:

$$Y_h = \sum_{i=1}^{N_h} Y_{hi}$$

$$\bar{Y}_h = \frac{Y_h}{N_h} = \frac{1}{N_h} \sum_{i=1}^{N_h} Y_{hi}$$

$$S_h^2 = \frac{1}{N_h - 1} \sum_{i=1}^{N_h} \left( Y_{hi} - \bar{Y}_h \right)^2$$

* For dichotomous variables:

$$\bar{Y}_h = P_h \qquad S_h^2 = \frac{N_h}{N_h - 1} P_h \left( 1 - P_h \right)$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

91

<!-- page 11 -->

# Sample level

- Sample sizes $n_h$ and sample elements $y_{h1}, y_{h2}, \dots, y_{hn_h}$:

$$y_h = \sum_{i=1}^{n_h} y_{hi}$$

$$\bar{y}_h = \frac{y_h}{n_h} = \frac{1}{n_h} \sum_{i=1}^{n_h} y_{hi}$$

$$\sum_{h=1}^H n_h = n_1 + n_2 + \dots + n_H = n$$

$$s_h^2 = \frac{1}{n_h - 1} \sum_{i=1}^{n_h} \left(y_{hi} - \bar{y}_h\right)^2$$

- For dichotomous variables:

$$\bar{y}_h = p_h \qquad s_h^2 = \frac{n_h}{n_h - 1} p_h (1 - p_h)$$

92

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 12 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $n_h$ | $\bar{y}_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 100 | 72.7 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 200 | 336.1 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 120 | 1,690.2 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 80 | 11,659.0 | 183,039,437.2 |
| Total | | 5,318 | 500 | | |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

93

<!-- page 13 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

94

<!-- page 14 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

95

<!-- page 15 -->

# C. Inference

* At population level,

$$
\bar{Y} = \frac{\sum_{h=1}^{H} \sum_{i=1}^{N_h} Y_{hi}}{N} = \frac{\sum_{h=1}^{H} Y_h}{N} = \frac{\sum_{h=1}^{H} \left(\frac{N_h}{N_h}\right) Y_h}{N} = \frac{\sum_{h=1}^{H} N_h \left(\frac{Y_h}{N_h}\right)}{N} =
$$

$$
\sum_{h=1}^{H} \frac{N_h}{N} \bar{Y}_h = \sum_{h=1}^{H} W_h \bar{Y}_h
$$

* At sample level,

$$
\bar{y}_w = \sum_{h=1}^{H} W_h \bar{y}_h
$$

96

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 16 -->

# Element level weighting

* The stratum level weighted mean can be expressed with element level weights:

$$
\bar{y}_w = \sum_{h=1}^H W_h \bar{y}_h = \sum_{h=1}^H \left(\frac{N_h}{N}\right) \bar{y}_h = \frac{1}{N} \sum_{h=1}^H N_h \frac{y_h}{n_h} = \frac{1}{N} \sum_{h=1}^H \frac{N_h}{n_h} \sum_{i=1}^{n_h} y_{hi} =
$$

$$
= \frac{1}{N} \sum_{h=1}^H \sum_{i=1}^{n_h} \left(\frac{N_h}{n_h}\right) y_{hi} = \frac{1}{N} \sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} y_{hi} = \frac{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} y_{hi}}{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi}}
$$

* Here,

$$
\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} = \sum_{h=1}^H \sum_{i=1}^{n_h} \left(\frac{N_h}{n_h}\right) = \sum_{h=1}^H n_h \left(\frac{N_h}{n_h}\right) = \sum_{h=1}^H N_h = N
$$

97

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 17 -->

# Sampling variance

* Variances are combines across strata

$$
\begin{aligned}
\text{Var}(\bar{y}_w) &= \text{Var}\left(\sum_{h=1}^H W_h \bar{y}_h\right) \\
&= \text{Var}(W_1 \bar{y}_1 + W_2 \bar{y}_2 + \cdots + W_H \bar{y}_H) \\
&= \text{Var}(W_1 \bar{y}_1) + \text{Var}(W_2 \bar{y}_2) + \cdots + \text{Var}(W_H \bar{y}_H) \\
&= W_1^2 \text{Var}(\bar{y}_1) + W_2^2 \text{Var}(\bar{y}_2) + \cdots + W_H^2 \text{Var}(\bar{y}_H) \\
&= \sum_{h=1}^H W_h^2 \text{Var}(\bar{y}_h)
\end{aligned}
$$

* Estimate this sampling variance with $\text{var}(\bar{y}_w) = \sum_{h=1}^H W_h^2 \text{var}(\bar{y}_h)$

98

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 18 -->

# SRS within strata: Stratified Random Sampling

* Adding strata subscript, $\text{var}(\bar{y}_h) = \frac{1-f_h}{n_h}s_h^2$
* And combining across strata:

$$
\text{var}(\bar{y}_w) = \sum_{h=1}^{H} W_h^2 \text{var}(\bar{y}_h) = \sum_{h=1}^{H} W_h^2 \frac{1-f_h}{n_h} s_h^2
$$

* For proportions,

$$
\text{var}(p_w) = \sum_{h=1}^{H} W_h^2 \left( \frac{1-f_h}{n_h - 1} \right) p_h(1-p_h)
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

99

<!-- page 19 -->

# Confidence Intervals

* Confidence intervals:

$$\bar{y}_w \pm t_{1-\alpha/2, df} \sqrt{\text{var}(\bar{y}_w)} = \bar{y}_w \pm t_{1-\alpha/2, df} \sqrt{\sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} s_h^2}$$

$$p_w \pm t_{1-\alpha/2, df} \sqrt{\text{var}(p_w)} = p_w \pm t_{1-\alpha/2, df} \sqrt{\sum_{h=1}^H W_h^2 \left(\frac{1 - f_h}{n_h - 1}\right) p_h(1 - p_h)}$$

$$\text{where } df = \sum_{h=1}^H (n_h - 1) = n - H$$

100

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 20 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $n_h$ | $\bar{y}_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 100 | 72.7 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 200 | 336.1 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 120 | 1,690.2 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 80 | 11,659.0 | 183,039,437.2 |
| Total | | 5,318 | 500 | | |

$$\bar{y}_w = \sum_{h=1}^H W_h \bar{y}_h = W_1 \bar{y}_1 + W_2 \bar{y}_2 + W_3 \bar{y}_3 + W_4 \bar{y}_4 =$$

$$= \frac{1,182}{5,318} \times 72.7 + \frac{1,846}{5,318} \times 336.1 + \frac{1,395}{5,318} \times 1,690.2 + \frac{895}{5,318} \times 11,659.0 = 2,538.4$$

101

©2017, Raphael Nishimura and James M. Lepkowski @ IPSDS

<!-- page 21 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $n_h$ | $\bar{y}_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 100 | 72.7 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 200 | 336.1 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 120 | 1,690.2 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 80 | 11,659.0 | 183,039,437.2 |
| Total | | 5,318 | 500 | | |

$$
\text{var}(\bar{y}_w) = \sum_{h=1}^H W_h^2 \text{var}(\bar{y}_h) = \sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} s_h^2 =
$$

$$
= \left[ \left( \frac{1,182}{5,318} \right)^2 \times \frac{1 - \frac{100}{1,182}}{100} \times 11,783.6 \right] + ... + \left[ \left( \frac{895}{5,318} \right)^2 \times \frac{1 - \frac{80}{895}}{80} \times 183,039,437.2 \right] = 60,998.0
$$

102

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 22 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $n_h$ | $\bar{y}_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 100 | 72.7 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 200 | 336.1 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 120 | 1,690.2 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 80 | 11,659.0 | 183,039,437.2 |
| Total | | 5,318 | 500 | | |

$$
\begin{aligned}
\bar{y}_w \pm t_{1-0.05/2, n-H} \sqrt{\text{var}(\bar{y}_w)} &= 2,538.4 \pm 1.96 \sqrt{60,998.0} = \\
&= [2,053.1 \, ; \, 3,023.6]
\end{aligned}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

103

<!-- page 23 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

104

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 24 -->

# Unit 3: Stratification
# Stratified Random Sampling

---

A. Purpose of stratification
B. Notation
C. Inference
D. Precision & design effect

105

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 25 -->

# D. Precision & design effect

* What can we gain from this more complicated method of sample selection and estimation?
  - Better control, administrative convenience
  - Reduced variance – in some allocations
* How can we measure such potential gains in precision?
  - Compare sampling variance of the stratified estimate against its corresponding SRS sampling variance – Design effect
* Total variance in the population:

$$
(N - 1)S^2 = \sum_{h=1}^{H} \sum_{i=1}^{N_h} (Y_{hi} - \bar{Y})^2
$$

106

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 26 -->

# Analysis of variance

* Expanding the total variance

$$\sum_{h=1}^{H} \sum_{i=1}^{N_h} \left( Y_{hi} - \bar{Y} \right)^2 = \sum_{h=1}^{H} \sum_{i=1}^{N_h} \left( Y_{hi} - \bar{Y}_h + \bar{Y}_h - \bar{Y} \right)^2$$

$$= \sum_{h=1}^{H} \sum_{i=1}^{N_h} \left[ \left( Y_{hi} - \bar{Y}_h \right) + \left( \bar{Y}_h - \bar{Y} \right) \right]^2$$

$$= \sum_{h=1}^{H} \sum_{i=1}^{N_h} \left[ \left( Y_{hi} - \bar{Y}_h \right) \right]^2 + \sum_{h=1}^{H} \sum_{i=1}^{N_h} \left[ \left( \bar{Y}_h - \bar{Y} \right) \right]^2$$

$$+ 2 \sum_{h=1}^{H} \sum_{i=1}^{N_h} \left[ \left( Y_{hi} - \bar{Y}_h \right) \left( \bar{Y}_h - \bar{Y} \right) \right]$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

107

<!-- page 27 -->

# Components of variance

* Further simplification leads to...

$$\begin{aligned}
&\sum_{h=1}^{H} \sum_{i=1}^{N_h} \left( \frac{N_h - 1}{N_h - 1} \right) \left( Y_{hi} - \bar{Y}_h \right)^2 + \sum_{h=1}^{H} N_h \left( \bar{Y}_h - \bar{Y} \right)^2 \\
&= \sum_{h=1}^{H} \left( N_h - 1 \right) S_h^2 + \sum_{h=1}^{H} N_h \left( \bar{Y}_h - \bar{Y} \right)^2 \\
S^2 &= \sum_{h=1}^{H} \frac{\left( N_h - 1 \right)}{\left( N - 1 \right)} S_h^2 + \sum_{h=1}^{H} \left( \frac{N_h}{N - 1} \right) \left( \bar{Y}_h - \bar{Y} \right)^2 \\
&\approx \sum_{h=1}^{H} W_h S_h^2 + \sum_{h=1}^{H} W_h \left( \bar{Y}_h - \bar{Y} \right)^2 \\
&= \text{\textit{Within Variance}} + \text{\textit{Between Variance}}
\end{aligned}$$

108

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 28 -->

# Designing stratified samples

* The sampling variance for the mean of a stratified sample is based on the within component only
  - Between stratum variance is ignored completely
* Decrease the sampling variance of the mean by making strata heterogeneous between and homogeneous within
* Use auxiliary $X$ correlated with $Y$, since $Y$ unknown
* Gains are not guaranteed
  - Depends on allocation of sample to strata - values of $n_h$

109

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 29 -->

# Design effect

* Gains (or losses) in precision can be measured through the design effect (*deff*):

$$
deff = \frac{\text{var}(\bar{y}_w)}{\text{var}_{SRS}(\bar{y})} = \frac{\sum_{h=1}^H W_h^2 \left( \frac{1 - f_h}{n_h} \right) s_h^2}{\left( \frac{1 - f}{n} \right) s^2}
$$

* Gain in precision if $deff < 1$
* Losses in precision $deff > 1$

110

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 30 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $n_h$ | $\bar{y}_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 100 | 72.7 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 200 | 336.1 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 120 | 1,690.2 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 80 | 11,659.0 | 183,039,437.2 |
| Total | | 5,318 | 500 | | |

$$
deff = \frac{\text{var}(\bar{y}_w)}{\text{var}_{SRS}(\bar{y})} = \frac{\sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} s_h^2}{\frac{1 - f}{n} s^2} = \frac{60,988.0}{\frac{1 - \frac{500}{5,318}}{500} \times 49,038,472.8} = 0.6865
$$

$$
s^2 \approx \sum_{h=1}^H W_h s_h^2 + \sum_{h=1}^H W_h (\bar{y}_h - \bar{y})^2 = \left[ \frac{1,182}{5,318} \times 11,783.6 + ... \right] + \left[ \frac{1,182}{5,318} \times (72.7 - 2,583.4)^2 + ... \right] = 49,038,472.8
$$

111

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 31 -->

# Unit 3: Stratification
# Allocations

---

A. Proportionate
B. Equal
C. Neyman
D. Optimum

112

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 32 -->

# Unit 3: Stratification
# Allocations

---

A. Proportionate
B. Equal
C. Neyman
D. Optimum

113
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 33 -->

# A. Proportionate

* Considering

$$\sum_{h=1}^{H} n_h = n \qquad f_h = n_h / N_h \qquad f = n / N$$

* If $f_h = f$ for all strata, *epsem* sampling results

* Hence,

$$\frac{n_h}{N_h} = \frac{n}{N} \Rightarrow n_h = n \times \frac{N_h}{N} = n \times W_h$$

* Self-weighting design: No weighting needed for the mean

* Sampling variance is simplified:

$$\text{var}(\bar{y}_w) = \left(\frac{1 - f}{n}\right) \sum_{h=1}^{H} W_h s_h^2 = \left(\frac{1 - f}{n}\right) s_w^2$$

114

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 34 -->

# Design effect

* Deff can be expresses as

$$deff = \frac{\text{var}(\bar{y}_w)}{\text{var}_{SRS}(\bar{y})} = \frac{\left(\frac{1 - f}{n}\right)s_w^2}{\left(\frac{1 - f}{n}\right)s^2} = \frac{s_w^2}{s^2}$$

* An alternate expression shows how gains can be obtained:

$$deff = 1 - \frac{\sum_{h=1}^{H} W_h(\bar{y}_h - \bar{y}_w)^2}{s^2}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

115

<!-- page 35 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $W_h$ | $n_h$ |
| :--- | :--- | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 0.2223 | 111 |
| 2 | 50 - 250K | 1,846 | 0.3471 | 174 |
| 3 | 250 - 4,000K | 1,395 | 0.2623 | 131 |
| 4 | >= 4,000K | 895 | 0.1683 | 84 |
| Total | | 5,318 | | 500 |

$$
W_1 = \frac{N_1}{N} = \frac{1,182}{5,318} = 0.2223
$$

$$
n_1 = n \times \frac{N_1}{N} = 500 \times 0.2223 = 111.132 \approx 111
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

116

<!-- page 36 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $W_h$ | $n_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 0.2223 | 111 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 0.3471 | 174 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 0.2623 | 131 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 0.1683 | 84 | 183,039,437.2 |
| Total | | 5,318 | | 500 | |

$$
\text{var}(\bar{y}_w) = \left(\frac{1 - f}{n}\right) s_w^2 = \left(\frac{1 - \dfrac{500}{5,318}}{500}\right) \times [0.2223 \times 11,783.6 + \dots] = 57,758.2
$$

$$
deff = \frac{\text{var}(\bar{y}_w)}{\text{var}_{SRS}(\bar{y})} = \frac{57,758.2}{\left(1 - \dfrac{500}{5,318}\right) \dfrac{49,038,472.8}{500}} = 0.65
$$

117

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 37 -->

# Unit 3: Stratification
# Allocations

---

A. Proportionate
B. Equal
C. Neyman
D. Optimum

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

118

<!-- page 38 -->

# Unit 3: Stratification
# Allocations

---

A. Proportionate
B. Equal
C. Neyman
D. Optimum

119

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 39 -->

# B. Equal

* Consider $n_h = \frac{n}{H}$ and $f_h = (n / H) / N_h$
* Not *epsem* unless strata are the same size
* Estimation requires the full weighted expressions
* *deff* may actually be greater than 1
* Why use it?
  - Suppose $S_h = S_{h'}$ for two different strata $h \neq h'$
  - Equal allocation minimizes the sampling variance $\text{var}(\bar{y}_h - \bar{y}_{h'})$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 120

<!-- page 40 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $W_h$ | $n_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 0.2223 | 125 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 0.3471 | 125 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 0.2623 | 125 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 0.1683 | 125 | 183,039,437.2 |
| Total | | 5,318 | | 500 | |

$$
\text{var}(\bar{y}_w) = \sum_{h=1}^H W_h^2 \text{var}(\bar{y}_h) = \sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} s_h^2
$$

$$
= \left[ 0.2223^2 \times \frac{1 - \dfrac{125}{1,182}}{125} \times 11,783.6 \right] + ... + \left[ 0.1683^2 \times \frac{1 - \dfrac{125}{895}}{125} \times 183,039,437.2 \right] = 49,038,472.8
$$

121

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 41 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $W_h$ | $n_h$ | $s_h^2$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 0.2223 | 125 | 11,783.6 |
| 2 | 50 - 250K | 1,846 | 0.3471 | 125 | 205,657.8 |
| 3 | 250 - 4,000K | 1,395 | 0.2623 | 125 | 3,568,970.7 |
| 4 | >= 4,000K | 895 | 0.1683 | 125 | 183,039,437.2 |
| Total | | 5,318 | | 500 | |

$$
deff = \frac{\text{var}(\bar{y}_w)}{\text{var}_{SRS}(\bar{y})} = \frac{49,038,472.8}{\left(1 - \frac{500}{5,318}\right) \frac{49,038,472.8}{500}} = 0.4238
$$

122

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 42 -->

# Unit 3: Stratification
# Allocations

---

A. Proportionate
B. Equal
C. Neyman
D. Optimum

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

123

<!-- page 43 -->

# Unit 3: Stratification Allocations

A. Proportionate
B. Equal
C. Neyman
D. Optimum

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

124

<!-- page 44 -->

# C. Neyman

* Consider $n_h = n \times W_h S_h / \sum_{h=1}^H W_h S_h$
* Smallest variance for $\bar{y}_w$
* Gains in precision greater than proportionate
* Need estimates of $S_h$
  - In practice, use reasonable estimates
  - Large gains require variation among $S_h$
  - Large gains unlikely for proportions
  - Values specific to $Y$
  - For multipurpose surveys, allocations will vary as $S_h$ vary across characteristics

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

125

<!-- page 45 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $W_h$ | $s_h^2$ | $n_h$ |
| :--- | :--- | :---: | :---: | :---: | :---: |
| 1 | < 50K sq. ft. | 1,182 | 0.2223 | 11,783.6 | 4 |
| 2 | 50 - 250K | 1,846 | 0.3471 | 205,657.8 | 27 |
| 3 | 250 - 4,000K | 1,395 | 0.2623 | 3,568,970.7 | 84 |
| 4 | >= 4,000K | 895 | 0.1683 | 183,039,437.2 | 385 |
| Total | | 5,318 | | | 500 |

$$
n_1 = n \times \frac{W_1 s_1}{\sum_{h=1}^4 W_h s_h} = 500 \times \frac{0.2223 \times \sqrt{11,783.6}}{0.2223 \times \sqrt{11,783.6} + \dots + 0.1683 \times \sqrt{183,039,437.2}} = 4.084 \approx 4
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

126

<!-- page 46 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $W_h$ | $s_h^2$ | $n_h$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 0.2223 | 11,783.6 | 4 |
| 2 | 50 - 250K | 1,846 | 0.3471 | 205,657.8 | 27 |
| 3 | 250 - 4,000K | 1,395 | 0.2623 | 3,568,970.7 | 84 |
| 4 | >= 4,000K | 895 | 0.1683 | 183,039,437.2 | 385 |
| Total | | 5,318 | | | 500 |

$$\text{var}(\bar{y}_w) = \sum_{h=1}^H W_h^2 \text{var}(\bar{y}_h) = \sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} s_h^2$$

$$= \left[ 0.2223^2 \times \frac{1 - \frac{4}{1,182}}{4} \times 11,783.6 \right] + \dots + \left[ 0.1683^2 \times \frac{1 - \frac{385}{895}}{385} \times 183,039,437.2 \right] = 11,470.2$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

127

<!-- page 47 -->

# Example: Stratified sample data, $n = 500$

| Stratum $h$ | Group | $N_h$ | $W_h$ | $s_h^2$ | $n_h$ |
| :--- | :--- | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 1,182 | 0.2223 | 11,783.6 | 4 |
| 2 | 50 - 250K | 1,846 | 0.3471 | 205,657.8 | 27 |
| 3 | 250 - 4,000K | 1,395 | 0.2623 | 3,568,970.7 | 84 |
| 4 | >= 4,000K | 895 | 0.1683 | 183,039,437.2 | 385 |
| Total | | 5,318 | | | 500 |

$$
\text{deff} = \frac{\text{var}(\bar{y}_w)}{\text{var}_{\text{SRS}}(\bar{y})} = \frac{11,470.2}{\left(1 - \frac{500}{5,318}\right) \frac{49,038,472.8}{500}} = 0.1291
$$

128

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 48 -->

# Unit 3: Stratification Allocations

---

A. Proportionate
B. Equal
C. Neyman
D. Optimum

129

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 49 -->

# Unit 3: Stratification
# Allocations

---

A. Proportionate
B. Equal
C. Neyman
D. Optimum

130

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 50 -->

# D. Optimum

* Consider total fixed cost $C = \sum_{h=1}^{H} n_h J_h$
* Objective:
  - Minimize sampling variance for $\bar{y}_w$ subjected to total fixed cost $C$, **OR**
  - Minimize cost subjected to a specified sampling variance for $\bar{y}_w$
* Allocate $n_h = k W_h S_h / \sqrt{J_h}$
  - $k$ is a constant of proportionality
* Neyman allocation is a special case where costs are the same across strata

131

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 51 -->

# Optimum allocation - Steps

* For a total fixed cost $C$:
  - Compute preliminary allocation with $n_h^* = W_h S_h / \sqrt{J_h}$
  - Calculate preliminary cost under that allocation: $C^* = \sum_{h=1}^H n_h^* J_h$
  - Compute constant of proportionality as $k = C / C^*$
  - Adjust preliminary allocation $n_h = k \times n_h^*$
* Similar process for fixed sampling variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

132

<!-- page 52 -->

# Example: $C = \$150,000$ for Optimum allocation

| Stratum $h$ | Group | $W_h$ | $s_h^2$ | $J_h$ | $n_h^*$ | $n_h$ |
| :--- | :--- | :---: | ---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 0.2223 | 11,783.6 | 100 | 2.413 | 7 |
| 2 | 50 - 250K | 0.3471 | 205,657.8 | 100 | 15.742 | 43 |
| 3 | 250 - 4,000K | 0.2623 | 3,568,970.7 | 200 | 35.041 | 97 |
| 4 | >= 4,000K | 0.1683 | 183,039,437.2 | 400 | 113.846 | 314 |
| Total | | | | | | 461 |

$$
n_1^* = W_1 s_1 / \sqrt{J_1} = 0.2223 \times \sqrt{11,783.6} / \sqrt{100} = 2.413
$$

$$
C^* = \sum_{h=1}^H n_h^* J_h = 2.413 \times 100 + 15.742 \times 100 + 35.041 \times 200 + 113.846 \times 400 = 54,362.08
$$

$$
k = C / C^* = 150,000 / 54,362.08 = 2.759
$$

$$
n_1 = k \times n_1^* = 2.759 \times 2.413 = 6.657 \approx 7
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

133

<!-- page 53 -->

# Example: $C = \$150,000$ for Optimum allocation

| Stratum $h$ | Group | $W_h$ | $s_h^2$ | $J_h$ | $n_h$ |
| :--- | :--- | :---: | :---: | :---: | :---: |
| 1 | < 50K sq. ft. | 0.2223 | 11,783.6 | 100 | 7 |
| 2 | 50 - 250K | 0.3471 | 205,657.8 | 100 | 43 |
| 3 | 250 - 4,000K | 0.2623 | 3,568,970.7 | 200 | 97 |
| 4 | >= 4,000K | 0.1683 | 183,039,437.2 | 400 | 314 |
| Total | | | | | 461 |

$$\text{var}(\bar{y}_w) = \sum_{h=1}^H W_h^2 \text{var}(\bar{y}_h) = \sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} s_h^2$$

$$= \left[ 0.2223^2 \times \frac{1 - \frac{7}{1,182}}{7} \times 11,783.6 \right] + \dots + \left[ 0.1683^2 \times \frac{1 - \frac{314}{895}}{314} \times 183,039,437.2 \right] = 13,719.3$$

134

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 54 -->

# Example: $C = \$150,000$ for Optimum allocation

| Stratum $h$ | Group | $W_h$ | $s_h^2$ | $J_h$ | $n_h$ |
| :--- | :--- | :---: | ---: | ---: | ---: |
| 1 | < 50K sq. ft. | 0.2223 | 11,783.6 | 100 | 7 |
| 2 | 50 - 250K | 0.3471 | 205,657.8 | 100 | 43 |
| 3 | 250 - 4,000K | 0.2623 | 3,568,970.7 | 200 | 97 |
| 4 | >= 4,000K | 0.1683 | 183,039,437.2 | 400 | 314 |
| Total | | | | | 461 |

$$
deff = \frac{\text{var}(\bar{y}_w)}{\text{var}_{SRS}(\bar{y})} = \frac{13,719.3}{\left(1 - \frac{461}{5,318}\right)\frac{49,038,472.8}{461}} = 0.1412
$$

135

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 55 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 136

<!-- page 56 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

137

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 57 -->

# A. Number of strata

* Stratification requires discrete categories
  – Stratifying variables may be discrete
  – Continuous stratifying variables divided into categories

* How many categories to capture gains possible?
  – Generally 3-6 strata adequate
  – When more than one stratifier, "coarser" cuts on more variables preferred to "finer" cuts
  – "Deepest" stratification for $n_h = 2$ (or $H = n/2$)
  – "Even deeper" stratification: 1 per stratum

138

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 58 -->

# Unit 3: Stratification
## Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 139

<!-- page 59 -->

# Unit 3: Stratification
## Stratification Topics

---

A. Number of strata
B. **Paired selection**
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

140

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 60 -->

# B. Paired selection

* Paired selections $n_h = 2$ useful in practice
  - “Deepest” stratification possible that allows sampling variances to be estimated without assumptions
  - Paired selection is *epsem* when: $N_h = N/H$
  - Attraction of paired selection is the simplification in variance estimation
  - When the design is *epsem*, proportionately allocated

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

141

<!-- page 61 -->

# Paired selection estimation

$$\bar{y} = \frac{\sum_{h=1}^{H} \sum_{i=1}^{n_h} y_{hi}}{n} = \frac{\sum_{h=1}^{H} (y_{h1} + y_{h2})}{n}$$

$$\begin{aligned}
\text{var}(\bar{y}) &= \left( \frac{1-f}{n} \right) \sum_{h=1}^{H} W_h s_h^2 \quad \left( \text{where } W_h = \frac{N_h}{N} = \frac{n_h}{n} = \frac{2}{n} \right) \\
&= \left( \frac{1-f}{n} \right) \sum_{h=1}^{H} \frac{2}{n} \left[ \left( y_{h1} - \frac{y_{h1} + y_{h2}}{2} \right)^2 + \left( y_{h2} - \frac{y_{h1} + y_{h2}}{2} \right)^2 \right] \\
&= 2 \left( \frac{1-f}{n^2} \right) \sum_{h=1}^{H} \left[ \left( \frac{y_{h1} - y_{h2}}{2} \right)^2 + \left( \frac{y_{h2} - y_{h1}}{2} \right)^2 \right] \\
&= \left( \frac{1-f}{n^2} \right) \sum_{h=1}^{H} (y_{h1} - y_{h2})^2
\end{aligned}$$

142

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 62 -->

# Paired selection features

* For element sampling, the symmetry of the selection and variance estimation disrupted by
  - Blanks in the list, non-responding elements
  - Analysis of subclasses
* Remedy: collapse strata
  - Increases the number of selections within "collapsed" or "pseudo" strata
  - Sampling variances are estimated as though the stratum boundary(ies) do not exist
  - “Deeper” stratification, which can increase the precision of estimates, is ignored
  - Sampling variance is over-estimated.

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

143

<!-- page 63 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

144

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 64 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

145
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 65 -->

# C. Collapsed strata

| Stratum | Elements | Collapsed stratum | Elements |
| :--- | :--- | :---: | :--- |
| 1 | $y_{11}, y_{12}$ | 1 | $y_{11}, y_{12}, y_{21}, y_{22}$ |
| 2 | $y_{21}, y_{22}$ | | |
| 3 | $y_{31}, y_{32}$ | 2 | $y_{31}, y_{32}, y_{41}, y_{42}$ |
| 4 | $y_{41}, y_{42}$ | | |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

146

<!-- page 66 -->

# Collapsed strata properties

* Used to simplify more complicated designs
* Reduced number of strata in estimation
* Increased degrees of freedom ($n - H$)
* Variance estimate based on collapsed strata biased for variance for original strata
  - Over-estimates variance by factor proportionate to between stratum difference

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

147

<!-- page 67 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

148
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 68 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

149

<!-- page 69 -->

# D. Poststratification

* Poststratification: variables to be used to create strata are not available at the time of selection
  - Stratify after selection using variables collected during the survey
  - Gains in precision are possible, with suitable modification to variance estimation
  - Population control adjustment
  - Poststratification requires
    * Poststrata known for each element
    * Poststratum weights $W_g$ for each poststratum

150

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 70 -->

# Poststratified estimator

* Sort the sample into poststrata
* Compute poststratum means
* Compute poststratified mean as $\bar{y}_{ps} = \sum_{g=1}^{G} W_g \bar{y}_g$
* For the variance,

$$Var(\bar{y}_{ps}) \approx \left(\frac{1 - f}{n}\right)\left[\sum_{g=1}^{G} W_g S_g^2 + \sum_{g=1}^{G} W_g(1 - W_g)\frac{S_g^2}{n_g}\right]$$

151

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 71 -->

# Poststratification illustration

* Sample $n=2,000$ SRS from $N=20,000$ libraries
  - $g=1$: ordered last year and prior years
  - $g=2$: ordered last year only
  - $g=3$: never ordered

| $g$ | $W_g$ | $n_g$ | $n_g/n$ | $\bar{y}_g$ | $s_g^2$ |
| :--- | :---: | :---: | :---: | :---: | :---: |
| 1 | 0.20 | 410 | 0.205 | 1250 | $3.2 \times 10^6$ |
| 2 | 0.25 | 493 | 0.247 | 750 | $3.0 \times 10^6$ |
| 3 | $\underline{0.55}$ | $\underline{1097}$ | $\underline{0.548}$ | $\underline{140}$ | $\underline{1.5 \times 10^6}$ |
| | | 2000 | 1.000 | | $(s^2 = 2.4 \times 10^6)$ |

152

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 72 -->

# Estimation

* The mean and variance are respectively

$$
\bar{y}_{ps} = (0.2)(1250) + (0.25)(750) + (0.55)(140) = 514.5
$$

$$
\text{var}(\bar{y}_{ps}) = \left(\frac{1 - 0.1}{2000}\right) \left[ (0.2)(3.2 \times 10^6) + (0.2)(1 - 0.2)\frac{3.2 \times 10^6}{410} + \cdots \right] = 998.0
$$

* Under proportionate allocation

$$
\text{var}(\bar{y}) = \left(\frac{1 - f}{n}\right) \sum_{g=1}^G W_g s_g^2 = 996.8
$$

* Under SRS

$$
\text{var}_{SRS}(\bar{y}) = \left(\frac{1 - f}{n}\right) s^2 = 1086.4
$$

153

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 73 -->

# Poststratification gains in precision

* The design effects are ...

$$\mathit{deff}_1 = \frac{\text{var}\left(\bar{y}_{ps}\right)}{\text{var}_{SRS}\left(\bar{y}\right)} = 0.9575 \qquad \mathit{deff}_2 = \frac{\text{var}\left(\bar{y}\right)}{\text{var}_{SRS}\left(\bar{y}\right)} = 0.9563$$

* $W_g$ may be approximate
* Use of the $W_g$ and poststratified estimators are a bias reduction technique
* Multipurpose poststratification limits choice of $W_g$
* Variance estimate: Taylor series approximation

154

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 74 -->

# Unit 3: Stratification
## Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

155

<!-- page 75 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

156

<!-- page 76 -->

# E. Sub-classes

- Stratification gains diminish for subclasses
- Let $M =$ total number of subclass elements in the population
- $M_h$ denotes the number for stratum $h$
- $m =$ subclass sample size (not "controlled“)
- $m_h$ is the size for stratum $h$
- The relative size of the subclass is given by

$$\bar{M} = \frac{M}{N} \text{ and } \bar{m} = \frac{m}{n}$$

157

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 77 -->

# Stratified sub-class estimator

* Consider the subclass mean for stratified random sampling
* The individual $M_h$ will not be known
* Estimate $M_h$ from the sample as : $\hat{M}_h = F_h m_h = \frac{N_h}{n_h} m_h$

158

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 78 -->

# Losses in gains in precision

* Subclass mean "loses" gains in precision
* For large subclasses, $1 - \bar{m}_h$ small, gains retained
* For small subclasses, $1 - \bar{m}_h = 1$, gains lost
* Resulting estimate no more precise than an SRS of the subclass
* Loss is approximately

$$\left(1 - m'_h\right) \sum_{h=1}^{H} \left(W'_h\right)^2 \left(\bar{y}_h - \bar{y}_w\right)^2$$

159

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 79 -->

# Unit 3: Stratification
# Stratification Topics

***

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

160

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 80 -->

# Unit 3: Stratification
# Stratification Topics

---

A. Number of strata
B. Paired selection
C. Collapsed strata
D. Poststratification
E. Sub-classes
F. Step-by-step selection

161

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 81 -->

# F. Step-by-step

* The "steps" in stratified sampling are as follows:
  - Identify stratifying variables correlated with the measure(s) of interest
  - Choose "cuts" on the stratifying variables
  - Divide the population into strata
  - $S_h$, $deff$, and $S^2$ are known, at least approximately, and that $fpc$'s within strata can be ignored
  - Compute an SRS sample size $n = n_{SRS} \times deff$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

162

<!-- page 82 -->

# Finishing the design

* Determine an allocation for the desired n
  – Proportionate
  – Neyman or optimum
  – Equal
* Adjust SRS $n$ based on expected *deff* & allocate
* Select sample and compute estimates taking the stratified sample selection into account
  – Mean
  – Variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

163
