---
id: "jpsm/sampling_1_SURV626/lectures/SURV_626_-_Unit_2_Elements-1"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "Unit 2: Elements"
original: "sampling_1_SURV626/lectures/SURV 626 - Unit 2 Elements-1.pdf"
pages: 58
sha256: "411909230e40a8007a0e6f076136f8976dfc22323a9c36d8724d67593076d7f0"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:12"
---

<!-- page 1 -->

# Unit 2: Elements
# Simple Random Sampling

---

A. Implementation
B. Precision & inference
C. Sample size

24

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 2 -->

# Unit 2: Elements
# Simple Random Sampling

---

A. Implementation
B. Precision & inference
C. Sample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

25

<!-- page 3 -->

# A. Implementation

* Population of $N$, sample of $n$: $\binom{N}{n} = \frac{N!}{n!(N-n)!}$

* Create all samples of size $n$ from $N$, select one at random

* Alternatively, random selection using mechanical device
  – Table of random numbers, using labels $i$ to identify selected units

26

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 4 -->

| Seq. No. | Division | Sex | Ran | Salary | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Eng&Prof | m | 3 | \$88 | 53 | Eng&Prof | m | 3 | \$57 |
| 2 | Medicine | f | 3 | \$45 | 54 | Medicine | m | 1 | \$118 |
| 3 | Medicine | m | 3 | \$57 | 55 | Medicine | m | 3 | \$84 |
| 4 | Medicine | m | 1 | \$133 | 56 | Eng&Prof | m | 3 | \$52 |
| 5 | Eng&Prof | f | 2 | \$71 | 57 | Medicine | m | 3 | \$64 |
| 6 | Lit&SocSci | m | 1 | \$113 | 58 | Eng&Prof | m | 1 | \$75 |
| 7 | Medicine | f | 3 | \$65 | 59 | Medicine | f | 1 | \$87 |
| 8 | Biol&Sci | m | 3 | \$47 | 60 | Eng&Prof | m | 3 | \$58 |
| 9 | Medicine | f | 3 | \$39 | 61 | Medicine | f | 3 | \$39 |
| 10 | Lit&SocSci | m | 1 | \$74 | 62 | Medicine | m | 3 | \$69 |
| 11 | Medicine | m | 1 | \$88 | 63 | Medicine | f | 2 | \$46 |
| 12 | Lit&SocSci | m | 1 | \$62 | 64 | Eng&Prof | f | 1 | \$86 |
| 13 | Lit&SocSci | m | 1 | \$49 | 65 | Medicine | m | 3 | \$87 |
| 14 | Medicine | m | 3 | \$88 | 66 | Medicine | m | 3 | \$59 |
| 15 | Medicine | m | 1 | \$181 | 67 | Eng&Prof | f | 3 | \$44 |
| 16 | Eng&Prof | m | 3 | \$63 | 68 | Medicine | m | 2 | \$123 |
| 17 | Medicine | m | 2 | \$94 | 69 | Lit&SocSci | f | 3 | \$37 |
| 18 | Eng&Prof | m | 1 | \$91 | 70 | Lit&SocSci | m | 1 | \$106 |
| 19 | Medicine | m | 1 | \$60 | 71 | Lit&SocSci | m | 1 | \$91 |
| 20 | Eng&Prof | m | 3 | \$55 | 72 | Lit&SocSci | m | 1 | \$78 |
| 21 | Biol&Sci | m | 2 | \$55 | 73 | Biol&Sci | m | 1 | \$77 |
| 22 | Medicine | f | 1 | \$106 | 74 | Medicine | m | 1 | \$90 |
| 23 | Medicine | m | 1 | \$116 | 75 | Eng&Prof | m | 2 | \$71 |
| 24 | Medicine | m | 3 | \$79 | 76 | Medicine | f | 3 | \$42 |
| 25 | Lit&SocSci | m | 1 | \$61 | 77 | Medicine | f | 2 | \$59 |
| 26 | Lit&SocSci | f | 3 | \$37 | 78 | Eng&Prof | m | 2 | \$49 |
| 27 | Medicine | m | 2 | \$72 | 79 | Biol&Sci | m | 1 | \$83 |
| 28 | Eng&Prof | m | 1 | \$105 | 80 | Lit&SocSci | m | 1 | \$34 |
| 29 | Medicine | m | 2 | \$79 | 81 | Medicine | f | 3 | \$42 |
| 30 | Medicine | m | 1 | \$61 | 82 | Medicine | m | 2 | \$97 |
| 31 | Medicine | m | 1 | \$86 | 83 | Medicine | m | 1 | \$109 |
| 32 | Biol&Sci | m | 1 | \$103 | 84 | Lit&SocSci | f | 2 | \$48 |
| 33 | Lit&SocSci | m | 1 | \$48 | 85 | Medicine | m | 1 | \$47 |
| 34 | Eng&Prof | m | 2 | \$64 | 86 | Eng&Prof | m | 2 | \$45 |
| 35 | Eng&Prof | m | 1 | \$78 | 87 | Medicine | m | 3 | \$83 |
| 36 | Medicine | f | 2 | \$53 | 88 | Medicine | m | 2 | \$51 |
| 37 | Biol&Sci | m | 1 | \$85 | 89 | Biol&Sci | m | 1 | \$78 |
| 38 | Eng&Prof | m | 1 | \$61 | 90 | Lit&SocSci | m | 1 | \$70 |
| 39 | Medicine | m | 1 | \$106 | 91 | Eng&Prof | f | 2 | \$46 |
| 40 | Lit&SocSci | m | 2 | \$60 | 92 | Eng&Prof | m | 1 | \$85 |
| 41 | Biol&Sci | f | 1 | \$73 | 93 | Lit&SocSci | m | 1 | \$53 |
| 42 | Medicine | m | 1 | \$70 | 94 | Medicine | f | 3 | \$40 |
| 43 | Medicine | f | 3 | \$32 | 95 | Eng&Prof | m | 1 | \$87 |
| 44 | Lit&SocSci | m | 2 | \$49 | 96 | Lit&SocSci | m | 1 | \$71 |
| 45 | Eng&Prof | m | 3 | \$43 | 97 | Medicine | m | 1 | \$75 |
| 46 | Medicine | m | 1 | \$75 | 98 | Biol&Sci | m | 1 | \$85 |
| 47 | Lit&SocSci | m | 1 | \$92 | 99 | Lit&SocSci | m | 2 | \$50 |
| 48 | Medicine | m | 2 | \$107 | 100 | Medicine | m | 3 | \$118 |
| 49 | Biol&Sci | m | 2 | \$57 | 101 | Lit&SocSci | m | 2 | \$55 |
| 50 | Medicine | m | 2 | \$114 | 102 | Medicine | m | 3 | \$80 |
| 51 | Eng&Prof | m | 3 | \$55 | 103 | Eng&Prof | m | 1 | \$114 |
| 52 | Biol&Sci | m | 1 | \$49 | 104 | Lit&SocSci | m | 1 | \$63 |
| | | | | | 105 | Medicine | m | 1 | \$112 |

### Table of Random Numbers

| | 1-5 | 6-10 | 11-15 | 16-20 | 21-25 | 26-30 | 31-35 | 36-40 | 41-45 | 46-50 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 57982 | 03250 | 09488 | 12085 | 38325 | 01091 | 03826 | 77648 | 57881 | 04677 |
| 2 | 34104 | 88576 | 32549 | 09603 | 73860 | 43758 | 05470 | 38344 | 04492 | 10730 |
| 3 | 01943 | 29119 | 72315 | 70334 | 98029 | 80936 | 37792 | 45017 | 18819 | 84787 |
| 4 | 25329 | 02138 | 52670 | 11692 | 03654 | 91109 | 17357 | 27013 | 32767 | 38642 |
| 5 | 23869 | 85541 | 29993 | 57693 | 84597 | 43545 | 23014 | 06089 | 52569 | 93160 |
| 6 | 69419 | 03843 | 33691 | 19541 | 80307 | 96350 | 62760 | 07467 | 12970 | 83870 |
| 7 | 14078 | 76539 | 08538 | 17888 | 65481 | 03995 | 63362 | 29308 | 23196 | 51186 |
| 8 | 14339 | 07381 | 13958 | 46562 | 75860 | 66994 | 97734 | 83135 | 77941 | 39411 |
| 9 | 97670 | 49015 | 97498 | 01260 | 63189 | 29044 | 11089 | 81803 | 87889 | 81923 |
| 10 | 15279 | 11006 | 82780 | 74184 | 34105 | 09246 | 31268 | 91081 | 99324 | 68381 |
| 11 | 97947 | 01993 | 12603 | 63485 | 16937 | 06190 | 77536 | 18598 | 92322 | 21257 |
| 12 | 00631 | 55073 | 73183 | 05961 | 16402 | 39801 | 96560 | 88053 | 70254 | 73836 |
| 13 | 30246 | 12514 | 24792 | 46736 | 61024 | 87174 | 63045 | 35815 | 57531 | 41129 |
| 14 | 74016 | 75832 | 78113 | 18374 | 78851 | 46324 | 78629 | 54165 | 73712 | 08415 |
| 15 | 53669 | 78559 | 66231 | 29085 | 78506 | 80934 | 88520 | 86912 | 17774 | 29711 |
| 16 | 98280 | 13316 | 23734 | 63720 | 50355 | 74201 | 17325 | 69300 | 28342 | 91793 |
| 17 | 32396 | 30527 | 10030 | 69065 | 87877 | 81658 | 23343 | 87272 | 74683 | 86065 |
| 18 | 05708 | 99540 | 11289 | 09030 | 94001 | 05587 | 41643 | 40782 | 25630 | 48366 |
| 19 | 04004 | 49911 | 47941 | 81165 | 14505 | 07432 | 79939 | 01309 | 79165 | 57871 |
| 20 | 84424 | 61863 | 81655 | 87420 | 76149 | 74712 | 81555 | 82645 | 05850 | 54779 |
| 21 | 84546 | 16063 | 09051 | 31787 | 57235 | 27302 | 83322 | 48361 | 11630 | 80174 |
| 22 | 76882 | 00300 | 45868 | 17098 | 53385 | 83121 | 70986 | 70598 | 91543 | 44137 |
| 23 | 98169 | 25789 | 99043 | 73890 | 35327 | 91723 | 77932 | 77971 | 41355 | 19562 |
| 24 | 33621 | 78638 | 27009 | 29610 | 20171 | 74951 | 34482 | 89391 | 81210 | 86209 |
| 25 | 61507 | 79038 | 38331 | 70320 | 73347 | 57565 | 19920 | 41574 | 68935 | 79233 |
| 26 | 20920 | 81284 | 01289 | 66936 | 60782 | 71442 | 63257 | 45294 | 11141 | 15333 |
| 27 | 78861 | 84019 | 31418 | 64943 | 42169 | 88995 | 48423 | 95960 | 27581 | 11679 |
| 28 | 08307 | 99947 | 51173 | 87234 | 60693 | 06143 | 13459 | 59514 | 79507 | 38

<!-- page 5 -->

# A. Implementation

* Population of $N$, sample of $n$: $\binom{N}{n} = \frac{N!}{n!(N-n)!}$
* Create all samples of size $n$ from $N$, select one at random
* Alternatively, random selection using mechanical device
  – Table of random numbers, using labels $i$ to identify selected units
  – Software using pseudo-random numbers
  – Not haphazard
* Base procedure
  – SRS – without replacement
  – SRS seldom used in practice, even from a simple frame
  – All samples of $n$ distinct elements equally likely

28

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 6 -->

# Probabilities of selection

* Draw by draw ...
* With replacement (Unrestricted Random, URS):
  - $p_{ij} = 1/N$, for draw $j$ and element $i = 1, \dots, N$
* For SRS, across all draws, $\pi_i = f = n/N$ :

$$p_1 = \frac{1}{N}$$

$$p_2 = (1 - p_1) \left[ \frac{1}{N - 1} \right] = \left[ \frac{N - 1}{N} \right] \left[ \frac{1}{N - 1} \right] = \frac{1}{N}$$

$$p_3 = (1 - p_1)(1 - p_2) \left[ \frac{1}{N - 2} \right] = \frac{1}{N}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

29

<!-- page 7 -->

# Sample estimates

$$y_1, y_2, ..., y_n \quad y_1 + y_2 + ... + y_n = \sum_{i=1}^{n} y_i = y$$

$$\bar{y} = \sum_{i=1}^{n} y_i / n = y / n$$

$$\begin{aligned}
s^2 &= \left[ (y_1 - \bar{y})^2 + ... + (y_n - \bar{y})^2 \right] / (n - 1) \\
&= \sum_{i=1}^{n} (y_i - \bar{y})^2 \bigg/ (n - 1) \\
&= \left( \sum_{i=1}^{n} y_i^2 - \frac{y^2}{n} \right) \bigg/ (n - 1)
\end{aligned}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

30

<!-- page 8 -->

# Unit 2: Elements
# Simple Random Sampling

---

A. Implementation
B. Precision & inference
C. Sample size

31

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 9 -->

# Unit 2: Elements
# Simple Random Sampling

---

A. Implementation
B. Precision & inference
C. Sample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

32

<!-- page 10 -->

# B. Precision & inference

$$
\bar{y} = y / n
$$

$$
Var(\bar{y}) = \frac{1}{\binom{N}{n}} \sum_{s=1}^{\binom{N}{n}} \left( \bar{y}_s - \bar{Y} \right)^2 = \frac{(1 - f)}{n} S^2
$$

$$
\operatorname{var}(\bar{y}) = \frac{(1 - f)}{n} s^2 =
$$

$$
= \frac{(1 - f)}{n} \frac{\sum_{i=1}^{n} \left( y_i - \bar{y} \right)^2}{(n - 1)} = \frac{\left( 1 - \frac{n}{N} \right)}{n} \frac{\left( \sum_{i=1}^{n} y_i^2 - \frac{y^2}{n} \right)}{(n - 1)}
$$

$$
se(\bar{y}) = \sqrt{\operatorname{var}(\bar{y})}
$$

33

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 11 -->

# Other estimates: Population Total

$$\hat{Y} = Fy = \left(\frac{N}{n}\right)y = N\bar{y}$$

$$Var(\hat{Y}) = F^2 Var(y) = N^2 Var(\bar{y})$$

$$var(\hat{Y}) = N^2 var(\bar{y}) = N^2 \frac{(1-f)}{n} s^2$$

$$se(\hat{Y}) = N\sqrt{var(\bar{y})}$$

34

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 12 -->

# Other estimates: Proportions

* Values of Y are zero or 1:

$$p = \bar{y}$$

$$Var(p) = \frac{(1-f)}{n} S^2 = \frac{(1-f)}{n} \left( \frac{N}{N-1} \right) P(1-P)$$

$$var(p) = \frac{(1-f)}{n} s^2 = \frac{(1-f)}{n} \left( \frac{n}{n-1} \right) p(1-p) = \frac{(1-f)}{n-1} p(1-p)$$

35

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 13 -->

# Inference

- Standard deviation & element variance

$$s = \sqrt{s^2}$$

- Standard error & sampling variance

$$se(\bar{y}) = \sqrt{\text{var}(\bar{y})} = \sqrt{\frac{(1 - f)}{n} s^2} = s \sqrt{\frac{(1 - f)}{n}}$$

- Confidence interval

$$\bar{y} \pm t_{1-\alpha/2, n-1} \sqrt{\text{var}(\bar{y})} = \bar{y} \pm t_{1-\alpha/2, n-1} \sqrt{\frac{(1 - f)}{n} s^2}$$

$$p \pm t_{1-\alpha/2, n-1} \sqrt{\text{var}(p)} = p \pm t_{1-\alpha/2, n-1} \sqrt{\frac{(1 - f)}{n - 1} p(1 - p)}$$

36

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 14 -->

# Without Replacement Sampling

* Population of $N = 5$, without replacement selection of $n = 3$:

$$
\begin{aligned}
(1) & \; Y_1, Y_2, Y_3 \quad \bar{y}_1 \\
(2) & \; Y_1, Y_2, Y_4 \quad \bar{y}_2 \\
& \cdot \\
& \cdot \\
& \cdot \\
(10) & \; Y_3, Y_4, Y_5 \quad \bar{y}_{10}
\end{aligned}
$$

$$
Var(\bar{y}) = \frac{1}{10} \sum_{s=1}^{10} \left( \bar{y}_{(s)} - \bar{Y} \right)^2 = \frac{(1-f)}{n} S^2
$$

37

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 15 -->

# With Replacement Sampling

* Population of $N = 5$, with replacement selection of $n = 3$:

$$
\begin{aligned}
&(1) \, Y_1, Y_1, Y_1 & \bar{y}_1 \\
&(2) \, Y_1, Y_1, Y_2 & \bar{y}_2 \\
&. \\
&. \\
&. \\
&(125) \, Y_5, Y_5, Y_5 & \bar{y}_{125}
\end{aligned}
$$

$$
Var(\bar{y}) = \frac{1}{125} \sum_{s=1}^{125} \left(\bar{y}_{(s)} - \bar{Y}\right)^2 = \frac{1}{n} S^2
$$

38

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 16 -->

# Without or With?

* Population of $N = 5$, without and with replacement selection of $n = 3$:

(1) $Y_1, Y_2, Y_3$

(2) $Y_1, Y_2, Y_4$

.

.

.

(10) $Y_3, Y_4, Y_5$

$$Var(\bar{y}) = \frac{(1 - f)}{n} S^2$$

(1) $Y_1, Y_1, Y_1$

(2) $Y_1, Y_1, Y_2$

.

.

.

(125) $Y_5, Y_5, Y_5$

$$Var_{URS}(\bar{y}) = \frac{1}{n} S^2$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

39

<!-- page 17 -->

# Proportions: useful properties

$$s^2 = \left( \frac{n}{n-1} \right) p(1-p) \approx p(1-p)$$

$$\text{var}(p) = \frac{(1-f)}{(n-1)} p(1-p)$$

| $P$ | $S^2 \approx P \times Q$ | $S \approx \sqrt{P \times Q}$ |
| :---: | :---: | :---: |
| 0.50 | 0.250 | 0.500 |
| 0.60 | 0.240 | 0.490 |
| 0.70 | 0.210 | 0.458 |
| 0.95 | 0.048 | 0.218 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

40

<!-- page 18 -->

# Proportions: useful properties

* What does this mean for us?

* Projection: estimating standard errors before we draw a sample
  - For proportions, $p$ can project $s$ without large error

| $p$ | $s^2 \approx p \times q$ | $s \approx \sqrt{p \times q}$ |
| :---: | :---: | :---: |
| 0.50 | 0.250 | 0.500 |
| 0.60 | 0.240 | 0.490 |
| 0.70 | 0.210 | 0.458 |
| 0.95 | 0.048 | 0.218 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

41

<!-- page 19 -->

# Unit 2: Elements
# Simple Random Sampling

---

A. Implementation
B. Precision & inference
C. Sample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

42

<!-- page 20 -->

# Unit 2: Elements
# Simple Random Sampling

---

A. Implementation
B. Precision & inference
C. Sample size

43

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 21 -->

# C. Sample size

* Sampling error depends very little on $N$
  - Unless $f$ greater than $0.05$
  - (Approximately) Same precision for $n = 1,000$ in Ann Arbor or the People's Republic of China
* Sample size determination in SRS
  - Specify desired level of precision
  - Obtain value for element variance
  - Solve for $n$

44
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 22 -->

# Computation

* Desired precision: $\hat{V}^2 = \left(1 - \frac{n}{N}\right)\frac{S^2}{n}$

* Solve algebraically for $n$: $n = \frac{\hat{S}^2}{\hat{V}^2 + \frac{\hat{S}^2}{N}}$

* Ignoring the *fpc*: $n = \frac{\hat{S}^2}{\hat{V}^2}$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

45

<!-- page 23 -->

# Desired precision: confidence interval or margin of error (e)

- The desired level of precision can also be specified by the width of a confidence interval:

$$(L, U) = \left(\bar{y} - t_{1-\alpha/2, n-1}\sqrt{\text{var}(\bar{y})}, \bar{y} + t_{1-\alpha/2, n-1}\sqrt{\text{var}(\bar{y})}\right)$$

- Then

$$t_{1-\alpha/2, n-1}\sqrt{\text{var}(\bar{y})} = \left(\frac{U - L}{2}\right) = e$$

$$\hat{V} = \sqrt{\text{var}(\bar{y})} = \frac{U - L}{2t_{1-\alpha/2, n-1}} = \frac{e}{z_{1-\alpha/2}}$$

46

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 24 -->

# Alternatively...

* Desired precision: $\hat{V}^2 = \left(\frac{e}{z_{1-\alpha/2}}\right)^2 = \left(1 - \frac{n}{N}\right)\frac{S^2}{n}$

* Solve algebraically for $n$: $n = \frac{\hat{S}^2}{\left(\frac{e}{z_{1-\alpha/2}}\right)^2 + \frac{\hat{S}^2}{N}}$

* Ignoring the *fpc*: $n = \frac{s^2}{\left(\frac{e}{z_{1-\alpha/2}}\right)^2}$

47

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 25 -->

# Relative Precision Alternative

* $cv(\bar{y}) = \frac{se(\bar{y})}{\bar{y}} = \frac{\hat{V}}{\bar{y}}$

* For example, supposed that we want $cv(\bar{y}) = 0.05$ for $\bar{y} = p = 0.1$

$$\hat{V} = se(\bar{y}) = \bar{y} \times cv(\bar{y}) = 0.1 \times 0.5 = 0.005$$

* Then, calculate sample size as on previous slide:

$$n = \frac{\hat{S}^2}{\hat{V}^2 + \frac{\hat{S}^2}{N}}$$

48

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 26 -->

# Example: adjusting a preliminary $n$

$$
\boxed{n = \frac{\hat{S}^2}{\hat{V}^2 + \frac{\hat{S}^2}{N}}}
$$

$$
\hat{S}^2 = 6,250, \hat{V} = 2.5
$$

$$
N = 100,000
$$

$$
n = \frac{6,250}{2.5^2 + \frac{6,250}{100,000}} = 991
$$

$$
\boxed{n' = \frac{\hat{S}^2}{\hat{V}^2}, \quad n = \frac{n'}{1 + \frac{n'}{N}}}
$$

$$
\hat{S}^2 = 6,250, \hat{V} = 2.5
$$

$$
n' = \frac{\hat{S}^2}{\hat{V}^2} = \frac{6,250}{2.5^2} = 1,000
$$

$$
N = 100,000
$$

$$
n = \frac{n'}{1 + \frac{n'}{N}} = \frac{1,000}{1 + 0.1} = 991
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

49

<!-- page 27 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

50

<!-- page 28 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

51

<!-- page 29 -->

# A. Frames

* Frame: **set of materials and/or procedures** used to designate a sample of units
* Rule links frame elements to population elements
* Accurate and up-to-date frames located in one location preferred
* Numbered, computerized lists are best.

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

52

<!-- page 30 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

53

<!-- page 31 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

54

<!-- page 32 -->

# B. Non-coverage

* Some population elements are not on the frame
  – Have zero chance of selection.

* Solution: use supplemental frames that cover non-covered elements
* Solution: use non-coverage weighting adjustments
  – Considered under post-stratification

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 55

<!-- page 33 -->

# B. Non-coverage

| Target Population Elements | | Frame Population Elements |
| :--- | :---: | :--- |
| 425 Kingsley St. | $\longleftarrow$ | 314-555-9124 |
| 3737 Geddes Rd. | | |
| 45 S. Main, Apt. 2 | $\longleftarrow$ | 314-555-9156 |
| 551 Seventh St. | $\longleftarrow$ | 314-555-8847 |
| 1845 W. Liberty | $\longleftarrow$ | 314-555-9173 |
| 968 Hill St. | $\longleftarrow$ | 314-555-9222 |
| 399 N. Fourth Ave. | $\longleftarrow$ | 314-555-9274 |
| . | | . |
| . | | . |
| . | | . |

**Target Population Element Without**
**a Sampling Frame Element**

56

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 34 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

57

<!-- page 35 -->

# Unit 2: Elements Frame Problems

---

A. Frames
B. Non-coverage
C. **Blanks**
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 58

<!-- page 36 -->

# C. Blanks

* Frame elements do not have corresponding population elements:
* Know frame element is blank after selection
* Screening to find eligible list elements
* One solution to **avoid**: substitute the next listing

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

59

<!-- page 37 -->

# C. Blanks

| Target Population Elements | | Frame Population Elements |
| :--- | :---: | :--- |
| 425 Kingsley St. | $\longleftarrow$ | 314-555-9124 |
| (Not in service) | $\dashleftarrow$ | 314-555-1433 |
| 45 S. Main, Apt. 2 | $\longleftarrow$ | 314-555-9156 |
| 551 Seventh St. | $\longleftarrow$ | 314-555-8847 |
| 1845 W. Liberty | $\longleftarrow$ | 314-555-9173 |
| 968 Hill St. | $\longleftarrow$ | 314-555-9222 |
| 399 N. Fourth Ave. | $\longleftarrow$ | 314-555-9274 |
| . | | . |
| . | | . |
| . | | . |

**No Target Population Element for**
**a Sampling Frame Element**

60

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 38 -->

# Rejecting Foreign Elements

* Solution: reject blank
  - Leads to smaller sample size than desired
  - Adjust the sampling rate (increase number of listings):
    * Let $p_b$ denoted estimated proportion blank elements
    * $n$ is the desired final sample size of elements (and not list elements)
    * $m$ is the number of frame elements to select.

$$m = \frac{n}{(1 - p_b)}$$

61

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 39 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

62

<!-- page 40 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. **Duplicates**
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

63

<!-- page 41 -->

# D. Duplicates

* Occur when a single population element is linked to two or more frame elements

* If only a few readily identified, remove from the list before selection
* Eliminating duplicates from the sample still leaves unequal probabilities of selection

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

64

<!-- page 42 -->

# D. Duplicates

| Target Population Elements | | Frame Population Elements |
| :--- | :---: | :--- |
| Tom Clarke | $\longleftarrow$ | 314-555-9123 |
| | $\longleftarrow$ | 314-555-9124 |
| Henry Thomas | $\longleftarrow$ | 314-555-9156 |
| Zack Horowitz | $\longleftarrow$ | 314-555-9173 |
| Jill Horowitz | $\longleftarrow$ | 314-555-9222 |
| Amelia Miller | $\longleftarrow$ | 314-555-9274 |
| . | | . |
| . | | . |
| . | | . |

**Duplication of Target Population Elements**
**By More Than One Sampling Frame Element**

65

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 43 -->

# Other solutions

* Choose unique listing
  - First, last, largest, or randomly chosen frame listing
* Determine how many duplicates for a given selected element
  - Say $d_i$.
* Weight observation for that selection with probability $1/d_i$.

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

66

<!-- page 44 -->

# Duplicate Weighting Illustration

* *Epsem*: $f = n/N$ for $i = 1, 2, \dots, N$
* The unweighted mean is appropriate:

$$
\bar{y} = \frac{\sum_{i=1}^{n} y_i}{n} = \frac{y_1 + y_2 + \dots + y_n}{1 + 1 + \dots + 1}
$$

* For example, from $N = 2,000$ families select $n = 25$ with *epsem*

$$
f = \frac{25}{2000} = \frac{1}{80} \longrightarrow w_i = f^{-1} = 80
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

67

<!-- page 45 -->

# Weighted Means

* *Epsem*: $f = n/N = 1/80$ for $i = 1, 2, \dots, N$
  – The weighted mean is

$$\bar{y} = \bar{y}_w = \frac{\sum_{i=1}^n w_i y_i}{\sum_{i=1}^n w_i} = \frac{80 y_1 + 80 y_2 + \dots + 80 y_n}{80 + 80 + \dots + 80} = \frac{\sum_{i=1}^n y_i}{n}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

68

<!-- page 46 -->

# Duplicates: Non-*epsem* Ilustration

* Non-*epsem* sampling has different selection probability for elements
* For example, suppose that $n = 25$ children are selected from a list of $N = 4,000$ children enrolled in school
  * Estimating family characteristics
* For families with one child enrolled $d_i=1$

$$\pi_i = \frac{25}{4000} = \frac{1}{160} \longrightarrow w_i = \pi_i^{-1} = 160$$

69

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 47 -->

# Unequal Chances: Over-representation

* For families with two children enrolled $d_i=2$ and

$$\pi_i = 2 \times \frac{25}{4000} = \frac{1}{80} \longrightarrow w_i = \pi_i^{-1} = 80$$

* For families with three children enrolled $d_i=3$ and

$$\pi_i = 3 \times \frac{25}{4000} = \frac{1}{53.33} \longrightarrow w_i = \pi_i^{-1} = 53.33$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

70

<!-- page 48 -->

# Weighted Mean, Revisited

* Compensate for varying probabilities using the weighted estimator

$$\bar{y} = \bar{y}_w = \frac{\sum_{i=1}^n w_i y_i}{\sum_{i=1}^n w_i} = \frac{(160)y_1 + (53.33)y_2 + \dots + (80)y_n}{160 + 53.33 + \dots + 80} \neq \frac{\sum_{i=1}^n y_i}{n}$$

71

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 49 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

72

<!-- page 50 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. **Clustering**
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

73

<!-- page 51 -->

# E. Clustering

* Occurs when more than one population element can be selected by a single frame element

* Take all elements within selected clusters
  - Clusters unequal size: sample size varies
  - Probabilities of selection remain equal, and unweighted estimates remain unbiased

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

74

<!-- page 52 -->

# E. Clustering

| Target Population Elements | | Frame Population Elements |
| :--- | :---: | :--- |
| Leonard Schmidt | $\longleftarrow$ | 403-555-5919 |
| Alice Schmidt | $\longleftarrow$ | |
| Virginia Schmidt | $\longleftarrow$ | |
| Paul Lehmann | $\longleftarrow$ | |
| Justin Lehmann | $\longleftarrow$ | 403-555-5917 |
| Theresa Placht | $\longleftarrow$ | 403-555-5922 |
| Janet Ferguson | $\longleftarrow$ | 403-555-5927 |
| . | | . |
| . | | . |
| . | | . |

**Clustering Target Population**
**Elements Relative to Sampling Frame Elements**

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

75

<!-- page 53 -->

# Other solutions

* Take all elements in selected clusters, adjust the sample size in advance
* $m = n \times \bar{b}$
* If clustering is frequent, use cluster sampling techniques with subsampling
  - If the clusters selected with equal chances (i.e., *epsem*), subsampled elements are not
  - Weight to compensate for unequal probabilities

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

76

<!-- page 54 -->

# Objective Respondent Selection

* In the social sciences, sampling a single element from small clusters of unequal size occurs often
  - Sampling individuals from households
  - Often randomized selections are carried out by computer
* Techniques for households:
  - Objective Respondent Selection proposed by Kish
  - Rizzo method
  - Troldahl-Carter method
    * *(1) How many people (18 or older) live in your household... counting yourself?*
    * *(2) How many of them are men?*
  - Nearest birthday method

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

77

<!-- page 55 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

78
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 56 -->

# Unit 2: Elements
# Frame Problems

---

A. Frames
B. Non-coverage
C. Blanks
D. Duplicates
E. Clustering
F. Many-to-many matching

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 79

<!-- page 57 -->

# F. Many-to-Many Matching

* Occurs when more than one population element can be selected by more than one frame element

* Solution: combinations of weighting and subsampling often used

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

80

<!-- page 58 -->

# F. Many-to-Many Matching

| Target Population Elements | Frame Population Elements |
| :--- | :--- |
| Leonard Schmidt | 403-555-5919 |
| Alice Schmidt | 403-555-5988 |
| Virginia Schmidt | |
| Paul Lehmann | |
| Justin Lehmann | 403-555-5917 |
| Theresa Placht | 403-555-5922 |
| Janet Ferguson | 403-555-5927 |
| . | . |
| . | . |
| . | . |

**Clustering & Duplicates**

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

81
