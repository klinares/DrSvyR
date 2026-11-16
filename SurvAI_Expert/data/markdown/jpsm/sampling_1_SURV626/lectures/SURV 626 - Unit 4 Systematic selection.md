---
id: "jpsm/sampling_1_SURV626/lectures/SURV_626_-_Unit_4_Systematic_selection"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "Unit 4: Systematic Selection"
original: "sampling_1_SURV626/lectures/SURV 626 - Unit 4 Systematic selection.pdf"
pages: 34
sha256: "be5e13fe48742af4bba2f57a20c462f7ea6139b32f2766bf1137563976f48ce7"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:18"
---

<!-- page 1 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

164

<!-- page 2 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

165

<!-- page 3 -->

# A. Principles

* SRS is difficult to implement and check
  - Without replacement selection

* Systematic sampling is clerically easy to do
  - There are problems in implementation

* Consider systematic sampling from a numbered list with $N$ population elements, $n$ sample elements, and $f = n/N$

166

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 4 -->

# Sample selection

* The sampling interval is $I = \frac{N}{n} = \frac{1}{f} = F = k$

* Selection starts with choosing a random start RS from $1$ to $k$
  * Select population elements RS, $\text{RS}+k, \text{RS}+2k, \text{RS}+3k, \dots, \text{RS}+(n-1)k$

* This selection process conceptually arrange population values as follows:

167

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 5 -->

# Conceptual framework

* $Y_1$
* $Y_2$
* . (k units)
* $Y_k$
* $Y_{k+1}$
* . (k units)
* $Y_{2k}$
* $Y_{2k+1}$
* . (etc.)
* $Y_{nk}$

| | $1$ | $2$ | ... | $i$ | ... | $k$ |
|---|---|---|---|---|---|---|
| $1$ | $Y_1$ | $Y_2$ | ... | $Y_i$ | ... | $Y_k$ |
| $2$ | $Y_{k+1}$ | $Y_{k+2}$ | ... | $Y_{k+i}$ | ... | $Y_{2k}$ |
| $3$ | $Y_{2k+1}$ | $Y_{2k+2}$ | ... | $Y_{2k+i}$ | ... | $Y_{3k}$ |
| . | . | . | | . | | . |
| $n$ | $Y_{(n-1)k+1}$ | $Y_{(n-1)k+2}$ | ... | $Y_{(n-1)k+i}$ | ... | $Y_{nk}$ |
| | $\bar{y}_1$ | $\bar{y}_2$ | ... | $\bar{y}_i$ | ... | $\bar{y}_k$ |

168

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 6 -->

# Illustration

| | 1 | 2 | 3 | 4 | 5 | 6 |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | 1 | 2 | 3 | 4 | 5 | 6 |
| **2** | 7 | 8 | 9 | 10 | 11 | 12 |
| **3** | 13 | 14 | 15 | 16 | 17 | 18 |
| **4** | 19 | 20 | 21 | 22 | 23 | 24 |
| **5** | 25 | 26 | 27 | 28 | 29 | 30 |
| **6** | 31 | 32 | 33 | 34 | 35 | 36 |
| **7** | 37 | 38 | 39 | 40 | 41 | 42 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 7 -->

# Clusters or strata?

* Order of the list achieves stratification
  - Combination of list order and systematic selection
  - Group similar elements together in list
  - Zones in selection similar to strata: contain elements similar to one another
  - Stratified proportionate allocation
* Systematic sampling is not a measurable design:
  - Stratified sample with $n_h=1$
  - Cluster sample with $a = 1$

Cluster?

| | $1$ | $2$ | $\dots$ | $i$ | $\dots$ | $k$ |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| $1$ | $Y_1$ | $Y_2$ | $\dots$ | $Y_i$ | $\dots$ | $Y_k$ |
| $2$ | $Y_{k+1}$ | $Y_{k+2}$ | $\dots$ | $Y_{k+i}$ | $\dots$ | $Y_{2k}$ |
| $3$ | $Y_{2k+1}$ | $Y_{2k+2}$ | $\dots$ | $Y_{2k+i}$ | $\dots$ | $Y_{3k}$ |
| $\cdot$ | $\cdot$ | $\cdot$ | | $\cdot$ | | $\cdot$ |
| $n$ | $Y_{(n-1)k+1}$ | $Y_{(n-1)k+2}$ | $\dots$ | $Y_{(n-1)k+i}$ | $\dots$ | $Y_{nk}$ |
| | $\bar{y}_1$ | $\bar{y}_2$ | $\dots$ | $\bar{y}_i$ | $\dots$ | $\bar{y}_k$ |

Stratum?

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

170

<!-- page 8 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

171

<!-- page 9 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

172

<!-- page 10 -->

# B. Fractional intervals

* Interval $k = N/n$ may not be an integer
  * Suppose that $N = 23$ and $n = 5$, so that $k = 23/5 = 4.6$
* If $k = 5$ is applied, $n = 4$ or $5$ will be random

| | 1 | 2 | 3 | 4 | 5 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | 1 | 2 | 3 | 4 | 5 |
| **2** | 6 | 7 | 8 | 9 | 10 |
| **3** | 11 | 12 | 13 | 14 | 15 |
| **4** | 16 | 17 | 18 | 19 | 20 |
| **5** | 21 | 22 | 23 | | |

173

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 11 -->

# Solutions for fractional intervals (1)

* What to do?
* Adjust $N$ or $n$ to make $k$ an integer.
* If the achieved sample size is $n+1$, delete a case at random from the sample
  - Unfortunately, this is not *epsem*
* Instead eliminate $N-nk$ listings at random, and then sample systematically

$$f = \left( 1 - \frac{N - nk}{N} \right) \times \frac{n}{nk} = \frac{n}{N}$$

* Duplicating $n(k+1)-N$ elements at random also works

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

174

<!-- page 12 -->

# Solutions for fractional intervals (2)

* Consider the list to be circular
  - Select a RS from $1$ to $N=23$ and continue selection until $n=5$
  - Example: RS=$\mathbf{17}$
  - Add integer closest to $k$ ($k=4.6$, so use $5$)
  - Select $17+5=\mathbf{22}$
  - $22+5=27$ , but $27>23$
    * Go to the beginning of the list and select $\mathbf{4}$
  - $4+5=\mathbf{9}$, $9+5=\mathbf{14}$

175

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 13 -->

# Solutions for fractional intervals (3)

* Use the fractional interval
  - Choose a random start from 01 to 46 (implied one decimal place)
    * Truncate the decimal to make the selection
  - Add the interval 46 to the random start
    * Truncate the decimal . . . Continue to $n = 5$
    * If the random start is 01-09, the first selection will be obtained after the interval is added
  - Example: $\text{RS}=35$:
    * 35, $35+46=81$, $81+46=127$, $127+46=173$, $173+46=219$
    * Choose 3, 8, 12, 17, 21

176

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 14 -->

# Fractional interval summary

| RS | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 | 58 | 59 | 60 | 61 |
| | 93 | 94 | 95 | 96 | 97 | 98 | 99 | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107 |
| | 139 | 140 | 141 | 142 | 143 | 144 | 145 | 146 | 147 | 148 | 149 | 150 | 151 | 152 | 153 |
| | 185 | 186 | 187 | 188 | 189 | 190 | 191 | 192 | 193 | 194 | 195 | 196 | 197 | 198 | 199 |
| | 231 | 232 | 233 | 234 | 235 | 236 | 237 | 238 | 239 | | | | | | |

$$... \quad ...$$

| RS | 32 | 33 | 34 | 35 | 36 | 37 | 38 | 39 | 40 | 41 | 42 | 43 | 44 | 45 | 46 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| | 78 | 79 | 80 | 81 | 82 | 83 | 84 | 85 | 86 | 87 | 88 | 89 | 90 | 91 | 92 |
| | 124 | 125 | 126 | 127 | 128 | 129 | 130 | 131 | 132 | 133 | 134 | 135 | 136 | 137 | 138 |
| | 170 | 171 | 172 | 173 | 174 | 175 | 176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 |
| | 216 | 217 | 218 | 219 | 220 | 221 | 222 | 223 | 224 | 225 | 226 | 227 | 228 | 229 | 230 |

177

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 15 -->

# Fractional interval probabilities

| Element | Random start | No. of RS's | $f$ |
| :---: | :---: | :---: | :---: |
| 1 | 10-19 | 10 | 1/4.6 |
| 2 | 20-29 | 10 | 1/4.6 |
| 3 | 30-39 | 10 | 1/4.6 |
| 4 | 40-46,01-03 | 10 | 1/4.6 |
| 5 | 04-13 | 10 | 1/4.6 |
| ... | ... | ... | ... |
| 23 | 01-09,46 | 10 | 1/4.6 |

178

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 16 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

179

<!-- page 17 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

180

<!-- page 18 -->

# C. Implicit stratification

* List order combined with systematic selection can improve the efficiency (in terms of variance) of systematic sample designs
  - Arrange the list order in advance
  - Determines which samples selected
    * Random order: SRS
    * Stratified order
    * Serpentine order

181

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 19 -->

# City blocks

| 1 | 2 | 3 |
| :---: | :---: | :---: |
| 6 | 5 | **4** |
| 7 | 8 | 9 |
| 12 | **11** | 10 |
| 13 | 14 | 15 |
| **18** | 17 | 16 |
| 19 | 20 | 21 |
| 24 | 23 | 22 |
| **25** | 26 | 27 |

34
35
33
**32**
31
30
29
28

$n = 5$
$k = 35/5 = 7$
$\text{RS} = 4$

182
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

*[Figure: The diagram illustrates a map of 35 numbered city blocks divided into two contrasting layouts: a regular 3-by-9 rectangular grid on the left (blocks 1–27) and eight irregularly shaped, curved regions on the right (blocks 28–35). The blocks are numbered sequentially in a serpentine pattern, with every seventh block starting from 4 (blocks 4, 11, 18, 25, and 32) highlighted in bold red text to demonstrate systematic sampling.]*

<!-- page 20 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

183

<!-- page 21 -->

# Unit 4: Systematic Selection

---

A. Principles
B. Fractional Intervals
C. Implicit Stratification
D. Variance Estimation

184

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 22 -->

# D. Variance estimation

* Estimation of the sample mean: $\bar{y} = \frac{\sum y_i}{n}$
* Sampling variance cannot be estimated using only survey data
  - Only a single random start used
  - Two approaches to dealing with the problem
    * Use additional random starts
    * Model the variance
  - Use $c$ random starts and $\bar{y} = \frac{\sum \sum y_{ji}}{cn} = \frac{1}{c} \sum_\gamma \bar{y}_\gamma$

$$\text{var}(\bar{y}) = \frac{1}{c} \sum_\gamma (\bar{y}_\gamma - \bar{y})^2$$

185

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 23 -->

# Model assisted variance estimation

* Model the population (sample selection process):
* SRS model -- elements in the list are ordered at random.

$$
\text{var}(\bar{y}) = (1 - f) \frac{s^2}{n}
$$

186

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 24 -->

# Stratified random model

* Assumes homogeneity and random ordering within zones
* Proportionately allocated selection with $n_h = 1$ selected per zone
* Collapse neighboring zones to create "pseudo strata" that have more than one selection

$$
\text{var}(\bar{y}) = \frac{1 - f}{n} \sum W_h s_h^2
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

187

<!-- page 25 -->

# Paired selection model

* Special case of stratified random model which pairs successive zones
* Simple variance estimation expression
* Simplicity can be disrupted by nonresponse or estimation for a subclass

$$\text{var}(\bar{y}) = \frac{1 - f}{n^2} \sum_{h=1}^{n/2} (y_{h1} - y_{h2})^2$$

188

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 26 -->

# Successive differences model

* Correlation between the $i^\text{th}$ and $(i+1)^\text{th}$ element larger than the correlation between the $i^\text{th}$ and $(i+2)^\text{th}$ or the $i^\text{th}$ and $(i+3)^\text{th}$, etc.
* $(n-1)$ differences each weighted by $1/2$ (except the first and last)
  - Not unbiased variance estimate, but consistent
  - Bias is small for large $n$.

$$\text{var}(\bar{y}) = \frac{1-f}{2n(n-1)} \sum_{g=1}^{n-1} (y_g - y_{g+1})^2$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

189

<!-- page 27 -->

# Variance estimation example

* Take a systematic sample of $n=6$ from the first 60 blocks of the 270 blocks in Kish (p. 625)
  - How many systematic samples of $n=6$ are possible from the first 60 blocks?
  - What is the interval?
* Random start = 3
* What are the 6 selected blocks?

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

190

<!-- page 28 -->

# Selected blocks

| RS+k | Block | # Rental | # HUs | g |
| :---: | :---: | :---: | :---: | :---: |
| 4 | 242 | 79 | 90 | 1 |
| 14 | 279 | 84 | 89 | 2 |
| 24 | 289 | 36 | 45 | 3 |
| 34 | 378 | 19 | 29 | 4 |
| 44 | 389 | 21 | 32 | 5 |
| 54 | 399 | 12 | 18 | 6 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

191

<!-- page 29 -->

# Calculating means

* *Epsem* sample

$$\bar{y}_{\#rental} = \frac{\sum_{i=1}^{n} y_i}{n}$$

$$= (79 + 84 + 36 + 19 + 21 + 12) / 6 = 41.83$$

192

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 30 -->

# Calculating variances (1)

* SRS model

$$\begin{aligned}
\text{var}(\bar{y}) &= (1 - f)\frac{s^2}{n} = (1 - \frac{6}{60})(\frac{1}{6})\frac{(15,539 - 6 * 41.83^2)}{6 - 1} \\
&= (0.90)(0.1667)(1,007.77) = 151.17
\end{aligned}$$

193

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 31 -->

# Calculating variances (2)

* Paired selection model, even # elements

$$\text{var}(\bar{y}) = \frac{(1 - f)}{n^2} \sum_{h}^{n/2} (y_{ha} - y_{hb})^2$$

$$= \left(1 - \frac{6}{60}\right)\left(\frac{1}{6^2}\right) [(79 - 84)^2 + (36 - 19)^2 + (21 - 12)^2]$$

$$= (.9)(0.0278)(25 + 289 + 81) = 9.875$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

194

<!-- page 32 -->

# Calculating variances (3)

* Successive differences model

$$\operatorname{var}(\bar{y}) = \frac{1-f}{2n(n-1)}\sum_{g}^{n-1}(y_g - y_{g+1})^2$$

$$= \frac{1-6/60}{2*6(6-1)}[(79-84)^2 + (84-36)^2 + (36-19)^2$$

$$+ (19-21)^2 + (21-12)^2]$$

$$= \frac{.9}{60}[25 + 2,304 + 289 + 4 + 81] = 40.55$$

195

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 33 -->

# Choosing among models

* Criteria for selecting an appropriate model include
  - List order
    * random (or "effectively random")
    * ordered deliberately to achieve stratification
  - Degrees of freedom
  - SRS: $n-1$
  - Successive differences: between $n/2$ & $n-1$
    * Use the more conservative $n/2$ in CIs
  - Stratified random: $n-H$
  - Paired differences: $n/2$

196

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 34 -->

# Bias considerations

* Variance estimates may be biased
  - Model fails to "capture" stratification represented by systematic selection
  - SRS: no stratification effects are accounted for
  - Stratified selection: captures stratification
    * Collapses across stratum boundaries
    * Paired selection: two per stratum
    * Successive differences: deepest stratification possible

197

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS
