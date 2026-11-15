---
id: "jpsm/sampling_1_SURV626/lectures/Unit_6_Unequal_sized_clusters_PPS"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "Unit 6: Unequal Sized Clusters"
original: "sampling_1_SURV626/lectures/Unit 6 Unequal sized clusters PPS.pdf"
pages: 52
sha256: "af1b0f2df137ef66c091f588aa2984571544c4664dc89a81c4c357e99d800741"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:13"
---

<!-- page 1 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

306

<!-- page 2 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

307

<!-- page 3 -->

# A. Controlling sample size

* Potentially large variation in sample size
  - A ratio mean for design-consistent estimation
* More control over sample size. Why?
  - Bias of $r$
  - Variance of $r$
* Equalize workloads controlling survey costs

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

308

<!-- page 4 -->

# Example: Two-stage selection

* A sample of $n = 36$ employees from $N = 2,160$
  - $f = 36/2160 = 1/60$

| Unit | No. | Unit | No. |
| :---: | :---: | :---: | ---: |
| 1 | 443 | 6 | 291 |
| 2 | 162 | 7 | 64 |
| 3 | 127 | 8 | 70 |
| 4 | 554 | 9 | 232 |
| 5 | 115 | 10 | 102 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

309

<!-- page 5 -->

# Sample size control

* Redefine clusters
* Stratification by size, varying sampling rates by size of cluster stratum
* Give up *epsem* for equal size subsamples
* Probabilities proportionate to size (PPS)

310

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 6 -->

# Redefine clusters

* Create 10 clusters of approximately $N/10 = 216$ employees each
* Variation above and below desired cluster size
* Once clusters created, select the sample with uniform sampling fractions

$$
f = f_a f_b = \left(\frac{a}{A}\right)\left(\frac{b}{B}\right)
$$

$$
fN = \left(\frac{1}{60}\right)(2160) = 36
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

311

<!-- page 7 -->

# Stratify by size

| Stratum I | | Stratum II | |
| :---: | :---: | :---: | :---: |
| **Unit** | **No.** | **Unit** | **No.** |
| 2 | 162 | 1 | 443 |
| 3 | 127 | 4 | 554 |
| 5 | 115 | 6 | 291 |
| 7 | 64 | 9 | $\underline{232}$ |
| 8 | 70 | | 1520 |
| 10 | $\underline{102}$ | | |
| | 640 | | |

312

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 8 -->

# Varying sampling rates

* Obtain *epsem* by choice of first and second stage rates:
* Use in stratum I: $f_{Ia} = \frac{1}{6} \quad f_{Ib} = \frac{1}{10}$
* Use in stratum II: $f_{IIa} = \frac{1}{4} \quad f_{IIb} = \frac{1}{15}$
* Sample size in stratum I ranges from 6 to 17, stratum II from 15 to 37
* $\text{cv}(x)$ has been reduced within strata.

313

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 9 -->

# Equal subsample size

- Select clusters with equal rates but take equal size subsamples
- Non-*epsem* design

$$
f = f_a f_{b|a} = \left(\frac{a}{A}\right)\left(\frac{b}{B_\alpha}\right) = \left(\frac{2}{10}\right)\left(\frac{18}{B_\alpha}\right) = \frac{16^{\text{ This should be 36, not 16.}}}{10 \times B_\alpha} = f_\alpha
$$

- Knowing $B_\alpha$ for each selected cluster, create weights $w_{\alpha\beta} = f_\alpha^{-1}$
- Constant overall workloads at the price of weighting and increases in sampling variances relative to *epsem* designs

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

314

<!-- page 10 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

315

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 11 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

316

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 12 -->

# PPS, or how to achieve *epsem* and equal subsample sizes at the same time

* Goal: Select a two stage sample such that there are equal subsample sizes in each cluster with *epsem*
* We want an overall *epsem* rate $f = n/N$ such that the sampling rate in the second stage is $b/B_\alpha$

$$f = f_\alpha f_{\beta|\alpha} = (f_\alpha) \left( \frac{b}{B_\alpha} \right) = \left( \frac{n}{N} \right)$$

* Solving $f_\alpha = \frac{n}{N} \times \frac{B_\alpha}{b} = \frac{ab}{\displaystyle\sum_{\alpha=1}^A B_\alpha} \times \frac{B_\alpha}{b} = \frac{aB_\alpha}{\displaystyle\sum_{\alpha=1}^A B_\alpha}$

317

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 13 -->

# PPS implications

- Select clusters with probabilities proportionate to their size, $B_\alpha$
  - Overall the selection becomes $f = \frac{aB_\alpha}{\sum_{\alpha=1}^A B_\alpha} \times \frac{b}{B_\alpha}$

- Selection probability varies at both first & second stages
  - Overall, *epsem*
  - Large <u>clusters</u> selected with high probabilities, *subsampled* at low rate
  - Small <u>clusters</u> selected with low probabilities, *subsampled* at high rate

318

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 14 -->

# Selecting clusters with PPS

---

* Two approaches
  – Simple replicated subsampling – at random and with replacement
  – Systematic sample and without replacement
* For both approaches, need to cumulate (sequentially add up) the size of the clusters

319

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 15 -->

# Selecting clusters with PPS

| Unit | $B_\alpha$ | Cum. $B_\alpha$ | Unit | $B_\alpha$ | Cum. $B_\alpha$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 443 | 443 | 6 | 291 | 1692 |
| 2 | 162 | 605 | 7 | 64 | 1756 |
| 3 | 127 | 732 | 8 | 70 | 1826 |
| 4 | 554 | 1286 | 9 | 232 | 2058 |
| 5 | 115 | 1401 | 10 | 102 | 2160 |

320

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 16 -->

# Using cumulative counts

* Simple replicated subsampling for $a=2$:
  - Select *RN* from 1 to 2160 with replacement
  - Find the cluster (Unit) with cumulative sum first exceeding *RN*
  - Select
  - Repeat
  - Subsampling rate $b / B_{\alpha}$ requires exactly $b$
* If cluster selected $k$ times, take $k \times b$ elements
* Subsampling: SRS, systematic, stratified element, even cluster sampling

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

321

<!-- page 17 -->

# Calculating subsampling rates

* For example, $RN_1=702$ and $RN_2 = 1744$ select Units 3 and 7

* For Unit 3, $\dfrac{aB_\alpha}{N} = \dfrac{2 \times 127}{2160} = \dfrac{1}{8.504}$

* Yields within $\dfrac{b}{B_\alpha} = \dfrac{18}{127} = \dfrac{1}{7.056}$

322

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 18 -->

# Variance estimation

* For PPS, $n=ab$ is fixed. Hence,

$$\bar{y} = \frac{\sum_{\alpha=1}^a \sum_{\beta=1}^b y_{\alpha\beta}}{ab}$$

$$\text{var}(\bar{y}) = \frac{(1 - f)}{a} s_a^2$$

323

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 19 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

324

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 20 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

325
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 21 -->

# C. Systematic PPS

---

* Compute zone size: $N/a = 2160/2 = 1080$
  - Select one subsample from each zone size 1080
  - Zone boundary falls 348 "elements" (measure units) through Unit 4; falls in 2 zones

* Select Units by selecting $RS$ from 1 to 1080
  - Identify selection from cumulative counts
  - Add the interval $k = 1080$ to the $RS$
  - Identify next selected cluster
  - Select one subsample from each at the rate $b/B_{\alpha}$

326

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 22 -->

# Selecting clusters with PPS

| Unit | $B_\alpha$ | Cum. $B_\alpha$ | | Unit | $B_\alpha$ | Cum. $B_\alpha$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 443 | 443 | | 6 | 291 | 1692 |
| 2 | 162 | 605 | | 7 | 64 | 1756 |
| 3 | 127 | 732 | | 8 | 70 | 1826 |
| 4 | 554 | 1286 | | 9 | 232 | 2058 |
| 5 | 115 | 1401 | | 10 | 102 | 2160 |

327

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 23 -->

# Within sampling rates

* For example, suppose $RN = 804$
  - Select $\alpha = 4$
  - $RN + I = 804 + 1080 = 1884$ selects $\alpha = 9$

* For $\alpha = 4$, $\frac{aB_\alpha}{N} = \frac{B_\alpha}{N/a} = \frac{554}{2160/2} = \frac{554}{1080} = \frac{1}{1.950}$

* Subsample $\frac{b}{B_4} = \frac{18}{554} = \frac{1}{30.78}$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

328

<!-- page 24 -->

# PPS without replacement

* Large literature on without replacement PPS selection procedures
* Alternatives lead to variance estimation expressions that require knowledge about the joint probabilities of selection
* Horvitz-Thompson estimator and the Yates-Grundy estimator of variance
* Unfortunately, the Yates-Grundy estimator can be negative
* Literature proposes wide variety of designs to overcome this problem

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

329

<!-- page 25 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

330
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 26 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

331

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 27 -->

# A. Estimated size measures

* Suppose that the exact count of elements -- $B_\alpha$ -- in each cluster is unknown
* But measure that approximates the number of units (that is, the size) in each cluster -- Measure of Size -- $Mos_\alpha$
* Example: Do not know the current exact count of employees for each Unit
  - Do know the number counted for each Unit at the last payroll one month ago

332

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 28 -->

# Example

| Unit | Last payroll | Now |
| :--- | ---: | ---: |
| 1 | 443 | 460 |
| 2 | 162 | 172 |
| 3 | 127 | 130 |
| 4 | 554 | 554 |
| 5 | 115 | 125 |
| 6 | 291 | 310 |
| 7 | 64 | 68 |
| 8 | 70 | 74 |
| 9 | 232 | 246 |
| 10 | 102 | 141 |
| Total | 2160 | 2280 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

333

<!-- page 29 -->

# PPeS

* Probabilities proportionate to <u>estimated</u> size: *epsem* design in two stages
* Over-sample large clusters relative to small
* Select clusters with the rate $\frac{aMos_\alpha}{\sum_{\alpha=1}^A Mos_\alpha}$
* Then subsample elements at rate $\frac{b^*}{Mos_\alpha}$
* Why $b^*$?
  * The actual number of second stage units selected is unknown; it's a target subsample size
  * If $Mos_\alpha = B_\alpha$, then $b^* = b$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

334

<!-- page 30 -->

# Selecting units with PPeS

* Returning to employees example, suppose $b^*=18$, $a=2$, and
* $a = 2$ clusters are selected $\sum_{\alpha=1}^{10} Mos_\alpha = 2160$
* One subsample of expected size $b^* = 18$ each

$$
f = \frac{2Mos_\alpha}{\sum Mos_\alpha} \times \frac{18}{Mos_\alpha} = \frac{36}{2160} = \frac{1}{60}
$$

* With PPeS sampling, subsampling at a specified rate and <u>not</u> selecting a <u>fixed</u> number of elements from each selected cluster

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

335

<!-- page 31 -->

# Example

| Unit | Last payroll | Now |
| :--- | ---: | ---: |
| 1 | 443 | 460 |
| 2 | 162 | 172 |
| 3 | 127 | 130 |
| 4 | 554 | 554 |
| 5 | 115 | 125 |
| 6 | 291 | 310 |
| 7 | 64 | 68 |
| 8 | 70 | 74 |
| 9 | 232 | 246 |
| 10 | 102 | 141 |
| Total | 2160 | 2280 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

336

<!-- page 32 -->

# PPeS illustration

---

* Suppose $RN_1 = 702 \quad RN_2 = 1744$
* Select Units 3 and 7
* For Unit 3,

$$
\frac{b}{Mos_3} = \frac{18}{127} = \frac{1}{7.056}
$$

* For Unit 7,

$$
\frac{b}{Mos_7} = \frac{18}{64} = \frac{1}{3.556}
$$

* If $Mos_\alpha = B_\alpha$ , a sample of exactly size 36 will be selected

337

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 33 -->

# Sample size variation returns

- But here $Mos_\alpha \cong B_\alpha$
- For Unit 3, $B_\alpha = 130$ , and $\frac{b}{Mos_3} = \frac{1}{7.056}$ yields

$$x_a = \frac{b}{Mos_\alpha} \times B_\alpha = \frac{1}{7.056} \times 130 = 18.425$$

- For interval 7.056, select a sample of 18 employees with probability 0.575
- Or a sample of 19 with probability 0.425

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

338

<!-- page 34 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

339

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 35 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

340

<!-- page 36 -->

# B. Stratification

* $Mos$, $a$, $b^*$, etc., are specified within strata

$$
f = f_h = \frac{a_h Mos_{h\alpha}}{\sum_{\alpha=1}^{A_h} Mos_{h\alpha}} \times \frac{b_h^*}{Mos_{h\alpha}} = \frac{a_h b_h^*}{\sum_{\alpha=1}^{A_h} Mos_{h\alpha}}
$$

* Retain *epsem* for stratified PPeS sampling across strata: $f = f_h$ for all $h$.

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

341

<!-- page 37 -->

# Implicit stratification

* Systematic PPeS sampling implicitly stratifies by selecting within each zone one subsample size $b^*$
* Stratification notation not necessary with this design
* Zone size (or sampling interval) is

$$
\frac{\sum_{\alpha=1}^{A_h} Mos_{h\alpha}}{a_h}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

342

<!-- page 38 -->

# Select $a = 4$ units

* $a = 4$ subsamples of size $b^* = 18$ from $Mos_t = 2160$
* Then

$$f = \frac{ab^*}{\sum Mos_\alpha} = \frac{4 \times 18}{2160} = \frac{1}{30}$$

* Zone size is $2160/4 = 540$

343

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 39 -->

# Explicit stratification

| Stratum I | | Stratum II | |
| :---: | :---: | :---: | :---: |
| **Unit** | **Mos** | **Unit** | **Mos** |
| 1 | 443 | 5 | 115 |
| 2 | 162 | 6 | 291 |
| 3 | 127 | 7 | 64 |
| 4 | 554 | 8 | 70 |
| | | 9 | 232 |
| | | 10 | 102 |
| **Total** | 1286 | | 874 |

344

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 40 -->

# Paired selection

$$
f_1 = \frac{1}{30} \neq \frac{2Mos_{1\alpha}}{\sum_{\alpha=1}^{A_1} Mos_{1\alpha}} \frac{18}{Mos_{1\alpha}} = \frac{36}{1286}
$$

$$
f_2 = \frac{1}{30} \neq \frac{2Mos_{2\alpha}}{\sum_{\alpha=1}^{A_2} Mos_{2\alpha}} \frac{18}{Mos_{2\alpha}} = \frac{36}{874}
$$

- Can manipulate $a_h, b_h^*, \sum_{\alpha=1}^{A_h} Mos_{h\alpha}$
- Uncommon to vary $a_h$

<!-- page 41 -->

# Vary subsample size

* For paired selections,

$$
f_h = \frac{2Mos_{h\alpha}}{\sum_{\alpha=1}^{A_h} Mos_{h\alpha}} \frac{b_h^*}{Mos_{h\alpha}}
$$

* Adjusting the subsample sizes across strata,

$$
f_1 = \frac{2Mos_{1\alpha}}{\sum_{\alpha=1}^{A_1} Mos_{1\alpha}} \frac{b_1^*}{Mos_{1\alpha}} = \frac{1}{30}
$$

$$
b_1^* = 21.43
$$

$$
b_2^* = 14.57
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

346

<!-- page 42 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

347

<!-- page 43 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

348

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 44 -->

# C. Oversize units

* Oversize units are clusters for which $Mos_{h\alpha}$ is so large that the unit has a certain chance of selection
  * Often so large that they will be selected multiple times in systematic PPeS
* For example, Unit 4 has $Mos_4 = 554 > 540$
  * Selected twice with probability

$$\frac{Mos_4}{540} = 1.0259$$

349

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 45 -->

# Solutions

* If there are few such clusters and chances of multiple selections small leave them in the list
  - If one selected $k$ times, select $k$ subsamples
* If there are many such clusters comprising a large share of the population, place in separate strata
  - Each such cluster is now a stratum, a cluster selected with certainty
  - Sampling rate(s) are applied directly within clusters
  - Self-representing units (SRU)

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

350

<!-- page 46 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

351

<!-- page 47 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

352
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 48 -->

# D. Undersize units

* Undersize units are clusters for which $Mos_{h\alpha} < cb^*$
* $Mos_{h\alpha} < b^*$ implies sampling within cluster at rate $> 1$
* All elements must be selected in the cluster, and

$$f = \frac{a_h Mos_{h\alpha}}{\sum Mos_{h\alpha}} \times 1$$

353

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 49 -->

# Solutions

* Link undersize units to form linked units of minimum sufficient size
  - Link before selection for the entire frame, especially if the frame is a computerized list
  - Can create clusters with greater heterogeneity
  - In area sampling, link geographically contiguous units
* Linking after selection
* If numerous, place in separate stratum
* Undersize units can include zero measure clusters

354

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 50 -->

# Linking after (during) selection

(1) Identify selected unit (block). If the selected unit and next on the list are minimum sufficient size, STOP

(2) If selected unit or next are not of minimum sufficient size,
  a) Move forward in list until first unit of minimum sufficient size is encountered
  b) Cumulate units backwards until a linked unit of minimum sufficient size is created
  c) Continue process until the selected unit is linked

355

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 51 -->

# Example

| Tract | Block | HU's |
| :--- | ---: | ---: |
| 28 | 210 | 23 |
| | 211 | 17 |
| | 212 | 36 |
| | 213 | 1 |
| 29 | 101 | 0 |
| | 102 | 0 |
| | 103 | 0 |
| | 104 | 0 |
| | 105 | 1 |
| | 106 | 0 |
| | 107 | 0 |
| | 108 | 0 |
| | 109 | 0 |
| | 110 | 0 |
| | 111 | 0 |
| | 112 | 0 |
| | 113 | 0 |
| | 114 | 60 |
| | 115 | 9 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

356

<!-- page 52 -->

# Example

| Tract | Block | HU's |
| :--- | ---: | ---: |
| 28 | 210 | 23 |
| | 211 | 17 |
| | 212 | 36 |
| | 213 | 1 |
| 29 | 101 | 0 |
| | 102 | 0 |
| | 103 | 0 |
| | 104 | 0 |
| | 105 | 1 |
| | 106 | 0 |
| | 107 | 0 |
| | 108 | 0 |
| | 109 | 0 |
| | 110 | 0 |
| | 111 | 0 |
| | 112 | 0 |
| | 113 | 0 |
| | 114 | 60 |
| | 115 | 9 |

Link 101-113, 212-213,
size = 38

e = 2

Link 105-113, size = 1

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 357
