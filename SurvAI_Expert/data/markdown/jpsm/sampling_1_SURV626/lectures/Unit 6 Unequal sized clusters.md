---
id: "jpsm/sampling_1_SURV626/lectures/Unit_6_Unequal_sized_clusters"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "Unit 6: Unequal Sized Clusters"
original: "sampling_1_SURV626/lectures/Unit 6 Unequal sized clusters.pdf"
pages: 106
sha256: "bb7f1faad0bcdff10fa38aeb752ccaac69b677d393e956cf5e1ccc0cf424eaf4"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:20"
---

<!-- page 1 -->

# Unit 6: Unequal Sized Clusters
# Unequal Sized Cluster Sampling

---

A. Unequal sized clusters
B. Ratio means
C. Illustration

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

252

<!-- page 2 -->

# Unit 6: Unequal Sized Clusters
# Unequal Sized Cluster Sampling

***

A. Unequal sized clusters
B. Ratio means
C. Illustration

253

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 3 -->

# A. Unequal sized clusters

* Unequal-sized clusters (with subsampling) pose problems for sample selection and estimation
* Fixed two-stage sampling rates $f_a=1/2$ and $f_b=1/10$ (i.e., $f=1/20$) for the following population of $A = 10$ unequal sized clusters with $N=1850$:

$$
f = f_a \times f_b = \frac{1}{2} \times \frac{1}{10} = \frac{1}{20} \text{ and } f \times N = \frac{1}{20} \times 1850 = 92.5
$$

254

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 4 -->

# Two unequal cluster samples, $f=1/20$

| Cluster | Size | Sample 1 | | | Sample 2 | | |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $\alpha$ | $B_\alpha$ | $\alpha$ | $B_\alpha$ | $x_\alpha = f_b B_\alpha$ | $\alpha$ | $B_\alpha$ | $x_\alpha = f_b B_\alpha$ |
| 1 | 400 | 1 | 400 | 40 | | | |
| 2 | 310 | | | | 2 | 310 | 31 |
| 3 | 40 | 3 | 40 | 4 | | | |
| 4 | 150 | | | | 4 | 150 | 15 |
| 5 | 250 | 5 | 250 | 25 | | | |
| 6 | 220 | | | | 6 | 220 | 22 |
| 7 | 50 | 7 | 50 | 5 | | | |
| 8 | 130 | | | | 8 | 130 | 13 |
| 9 | 90 | 9 | 90 | 9 | | | |
| 10 | 210 | | | | 10 | 210 | 21 |
| Total | 1850 | 5 | 830 | 83 | 5 | 1020 | 102 |

255

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 5 -->

# Variation in sample size

* Sample size is a random variable
  – $y/n$ is no longer appropriate
  – Ratio mean $r=y/x$ is appropriate
* Alternatives to variation in sample size:
  – Depart from *epsem*
    * Leads to weighting
    * Increase in variance due to weights
  – Create new clusters of equal size
  – Stratify by size
  – Probability proportional to size selection (PPS) [We’ll come back to this later]

256

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 6 -->

# Unit 6: Unequal Sized Clusters
# Unequal Sized Cluster Sampling

---

A. Unequal sized clusters
B. Ratio means
C. Illustration

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 257

<!-- page 7 -->

# Unit 6: Unequal Sized Clusters
# Unequal Sized Cluster Sampling

---

A. Unequal sized clusters
B. Ratio means
C. Illustration

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 258

<!-- page 8 -->

# B. Ratio means

* Two principle problems with ratio means:
  - Biased for the overall population mean
  - The sampling variance of the ratio mean is not known exactly (except for some special sample designs)
  - Estimate sampling variance using Taylor Series Linearization:

$$
r = \frac{y}{x} = \frac{\displaystyle\sum_{\alpha=1}^a y_\alpha}{\displaystyle\sum_{\alpha=1}^a x_\alpha} = \frac{\displaystyle\sum_{\alpha=1}^a \sum_{\beta=1}^{x_\alpha} y_{\alpha\beta}}{\displaystyle\sum_{\alpha=1}^a x_\alpha}
$$

$$
\text{var}(r) \approx \frac{1}{x^2} \left[ \text{var}(y) + r^2 \text{var}(x) - 2r \text{cov}(y, x) \right]
$$

259

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 9 -->

# Variance for sample total

* Recall from equal size one-stage cluster sampling,

$$\text{var}(\bar{y}) = \frac{1-f}{aB^2(a-1)} \left( \sum_{\alpha=1}^a y_\alpha^2 - \frac{\left( \sum_{\alpha=1}^a y_\alpha \right)^2}{a} \right)$$

* For sample total,

$$\begin{aligned}
\text{var}(y) &= \text{var}(aB \times \bar{y}) = (aB)^2 \text{var}(\bar{y}) \\
&= a \frac{1-f}{a-1} \left( \sum_{\alpha=1}^a y_\alpha^2 - \frac{y^2}{a} \right)
\end{aligned}$$

260

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 10 -->

# Estimating sample total variances

* For an SRS of $a$ clusters

$$\text{var}(y) = a \frac{(1 - f)}{a - 1} \left( \sum_{\alpha=1}^a y_\alpha^2 - \frac{\left( \sum_{\alpha=1}^a y_\alpha \right)^2}{a} \right)$$

$$\text{var}(x) = a \frac{(1 - f)}{a - 1} \left( \sum_{\alpha=1}^a x_\alpha^2 - \frac{\left( \sum_{\alpha=1}^a x_\alpha \right)^2}{a} \right)$$

$$\text{cov}(y, x) = a \frac{(1 - f)}{a - 1} \left( \sum_{\alpha=1}^a y_\alpha x_\alpha - \frac{\left( \sum_{\alpha=1}^a y_\alpha \right) \left( \sum_{\alpha=1}^a x_\alpha \right)}{a} \right)$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

261

<!-- page 11 -->

# Estimating $\operatorname{var}(r)$

* Substituting into $\operatorname{var}(r)$, and simplifying,

$$\operatorname{var}(r) \approx \frac{1}{x^2} \left[ \operatorname{var}(y) + r^2 \operatorname{var}(x) - 2r \operatorname{cov}(y, x) \right] =$$

$$= \left( \frac{1}{x^2} \right) a \frac{(1 - f)}{(a - 1)} \left[ \left( \sum_{\alpha=1}^a y_\alpha^2 - \frac{y^2}{a} \right) + r^2 \left( \sum_{\alpha=1}^a x_\alpha^2 - \frac{x^2}{a} \right) - 2r \left( \sum_{\alpha=1}^a y_\alpha x_\alpha - \frac{yx}{a} \right) \right]$$

$$= \left( \frac{1}{x^2} \right) a \frac{(1 - f)}{(a - 1)} \left[ \sum_{\alpha=1}^a y_\alpha^2 + r^2 \sum_{\alpha=1}^a x_\alpha^2 - 2r \sum_{\alpha=1}^a y_\alpha x_\alpha \right]$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

262

<!-- page 12 -->

# Adequacy of approximation

* Since $\text{var}(r)$ is an approximation, it would be useful to an indication of when it might fail
* Examination of the Taylor series shows the adequacy of the approximation depends on the coefficient of variation of the sample size:

$$cv(x) = \frac{se(x)}{x} = \frac{\sqrt{\text{var}(x)}}{x} = \frac{\sqrt{a \frac{(1-f)}{a-1} \left( \sum_{\alpha=1}^a x_\alpha^2 - \frac{\left( \sum_{\alpha=1}^a x_\alpha \right)^2}{a} \right)}}{\sum_{\alpha=1}^a x_\alpha}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

263

<!-- page 13 -->

# Rule of thumb for adequacy and bias

* As long as $\text{cv}(x) < 0.15$, the approximation is reasonably accurate
  - Values of $\text{cv}(x)$ as large as $0.20$ may also be acceptable
* The bias of $r$ also depends on the coefficient of variation of the denominator:

$$\left| \frac{Bias(r)}{se(r)} \right| < cv(x)$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

264

<!-- page 14 -->

# Unit 6: Unequal Sized Clusters
# Unequal Sized Cluster Sampling

---

A. Unequal sized clusters
B. Ratio means
C. Illustration

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

265

<!-- page 15 -->

# Unit 6: Unequal Sized Clusters
# Unequal Sized Cluster Sampling

---

A. Unequal sized clusters
B. Ratio means
C. Illustration

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

266

<!-- page 16 -->

# C. Illustration: Ratio mean

* In a hospital authority of 5 hospitals, estimate the proportion of outpatient visits due to trauma
  - Element: outpatient visits
  - Estimate: proportion of visits due to trauma
* Select outpatient records in 2 stages:
  - First hospital-days ($A = 5 \times 365 = 1825$)
    * Clusters: days across hospitals
    * Sample of $a = 10$ hospital days
  - Second, select all records on a selected day

$$
f = \frac{10}{1825} \cdot 1 = \frac{10}{1825}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

267

<!-- page 17 -->

# Hospital-days

| Sample hospital-day $\alpha$ | Total visits $x_\alpha$ | Trauma visits $y_\alpha$ |
| :---: | :---: | :---: |
| 1 | 58 | 40 |
| 2 | 47 | 16 |
| 3 | 37 | 8 |
| 4 | 69 | 27 |
| 5 | 40 | 10 |
| 6 | 27 | 18 |
| 7 | 34 | 17 |
| 8 | 30 | 12 |
| 9 | 26 | 16 |
| 10 | 32 | 16 |

$$
\sum_{\alpha=1}^{a} x_\alpha = 400 \quad \sum_{\alpha=1}^{a} y_\alpha = 180 \quad \sum_{\alpha=1}^{a} x_\alpha^2 = 17778 \quad \sum_{\alpha=1}^{a} y_\alpha^2 = 4018 \quad \sum_{\alpha=1}^{a} x_\alpha y_\alpha = 7983
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

268

<!-- page 18 -->

# Inference

* For $r = 0.45$, estimate $\text{var}(r)$, ignoring the fpc:

$$\text{var}(r) \approx \frac{1}{x^2} \frac{a}{a - 1} \left[ \sum_{\alpha=1}^a y_\alpha^2 + r^2 \sum_{\alpha=1}^a x_\alpha^2 - 2r \sum_{\alpha=1}^a y_\alpha x_\alpha \right] =$$

$$= \frac{1}{400^2} \frac{10}{10 - 1} \left[ 4018 + 0.45^2 \times 17788 - 2 \times 0.45 \times 7983 \right] = 0.003023$$

* For $t_{(0.975, 9)} = 2.262$, 95% C.I. $(0.3256, 0.5744)$

* Adequacy of the approximation:

$$cv(x) = \frac{\sqrt{\frac{a}{a - 1} \left( \sum_{\alpha=1}^a x_\alpha^2 - \frac{x^2}{a} \right)}}{\sum_{\alpha=1}^a x_\alpha} = \frac{\sqrt{\frac{10}{10 - 1} \left( 17788 - \frac{400^2}{a} \right)}}{400} = 0.1114$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

269

<!-- page 19 -->

# Design of new sample

* *deff* and *roh*:

$$\text{var}_{srs}(r) = \frac{r(1-r)}{n-1} = \frac{(0.45)(0.55)}{399} = 0.0006203$$

$$deff = \frac{\text{var}(r)}{\text{var}_{SRS}(r)} = \frac{0.003023}{0.0006203} = 4.874$$

$$roh = \frac{deff - 1}{\bar{b} - 1} = \frac{4.874 - 1}{40 - 1} = 0.09934$$

$$\text{where } \bar{b} = \frac{400}{10} = 40 \left( = \frac{x}{a} \right)$$

* What would happen if $a = 10$ and $\bar{b} = 20$?
  - Compute new *deff*, and multiply by SRS sampling variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

270

<!-- page 20 -->

# Unit 6: Unequal Sized Clusters
# Stratified Unequal Sized Cluster Sampling

---

A. Principles of selection
B. Variance estimation

271

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 21 -->

# Unit 6: Unequal Sized Clusters Stratified Unequal Sized Cluster Sampling

---

A. Principles of selection
B. Variance estimation

272

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 22 -->

# A. Principles of selection

* Cluster sample stratification similar to elements
  - Use cluster characteristics
  - Homogeneous, mutually exclusive, exhaustive
  - Control the distribution of the sample
  - Decrease sampling variance
  - Selection of stratifying variables, boundaries, etc., discussed for element sampling applies to clusters
* Allocation of sample clusters across strata:
  - Proportionate allocation
  - Paired selection
  - Other allocations

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

273

<!-- page 23 -->

# Notation

* Add subscript to denote cluster stratification
* Population of $N$ elements, $B_{h\alpha}$ per cluster
* $A_h$ clusters per stratum
* Population mean: $\bar{Y} = \sum_{h=1}^H \sum_{\alpha=1}^{A_h} \sum_{\beta=1}^{B_{h\alpha}} Y_{h\alpha\beta} \Bigg/ N$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

274

<!-- page 24 -->

# Sample estimation

* At the sample level, $y_{h\alpha\beta}$ denotes survey variable values
* Selection of $a_h$ from $A_h$ clusters (with or without replacement)
* Selection of $b_{h\alpha}$ elements from $(h\alpha)^{th}$ cluster
* Simple replicated subsampling, or ultimate cluster sampling, within each stratum

$$r = \frac{y}{x} = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b_{h\alpha}} y_{h\alpha\beta}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b_{h\alpha}} x_{h\alpha\beta}} = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} y_{h\alpha}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} x_{h\alpha}} = \frac{\sum_{h=1}^{H} y_h}{\sum_{h=1}^{H} x_h}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

275

<!-- page 25 -->

# Weighted estimation

* The quantities $y_{h\alpha}$ and $x_{h\alpha}$ can be weighted, if not *epsem*
  - $r$ implicitly uses $y_{h\alpha\beta}^* = w_{h\alpha\beta} y_{h\alpha\beta}$
  - $w_{h\alpha\beta}$ is the weight for the $(h\alpha\beta)^{th}$ element
  - $y_{h\alpha} = \sum_{\beta=1}^{b_{h\alpha}} w_{h\alpha\beta} y_{h\alpha\beta} = \sum_{\beta=1}^{b_{h\alpha}} y_{h\alpha\beta}^*$ is the weighted estimate for the primary selection in stratum $h$
* “Best" estimate of the total $Y_{h\alpha}$
* Similarly, $x_{h\alpha\beta}^* = w_{h\alpha\beta} x_{h\alpha\beta}$ and $x_{h\alpha} = \sum_{\beta=1}^{b_{h\alpha}} w_{h\alpha\beta} x_{h\alpha\beta} = \sum_{\beta=1}^{b_{h\alpha}} x_{h\alpha\beta}^*$

276

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 26 -->

# Unit 6: Unequal Sized Clusters
# Stratified Unequal Sized Cluster Sampling

---

A. Principles of selection
B. Variance estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

277

<!-- page 27 -->

# Unit 6: Unequal Sized Clusters
# Stratified Unequal Sized Cluster Sampling

---

A. Principles of selection
B. Variance estimation

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

278

<!-- page 28 -->

# B. Variance estimation

* Sampling variance estimation depends on the methods used to select the clusters within each stratum
  * Based on ultimate cluster sampling theory
  * Under disproportionate allocation, $(1 - f_h)$ appears in each stratum
* Three different methods
  * Multiple differences
  * Paired selection
  * Successive differences

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

279

<!-- page 29 -->

# Multiple differences

$$
\begin{aligned}
\text{var}(r) &\approx \frac{1}{x^2} \left[ \text{var}(y) + r^2 \text{var}(x) - 2r \text{cov}(y,x) \right] \\
&= \frac{1}{x^2} \left[ \sum_{h=1}^{H} \text{var}(y_h) + r^2 \sum_{h=1}^{H} \text{var}(x_h) - 2r \sum_{h=1}^{H} \text{cov}(y_h, x_h) \right] \\
&= \frac{1}{x^2} \left[ \begin{aligned}
&\sum_{h=1}^{H} \frac{a_h(1-f_h)}{a_h-1} \left( \sum_{\alpha=1}^{a_h} y_{h\alpha}^2 - \frac{y_h^2}{a_h} \right) \\
&+ r^2 \sum_{h=1}^{H} \frac{a_h(1-f_h)}{a_h-1} \left( \sum_{\alpha=1}^{a_h} x_{h\alpha}^2 - \frac{x_h^2}{a_h} \right) \\
&- 2r \sum_{h=1}^{H} \frac{a_h(1-f_h)}{a_h-1} \left( \sum_{\alpha=1}^{a_h} y_{h\alpha} x_{h\alpha} - \frac{y_h x_h}{a_h} \right)
\end{aligned} \right]
\end{aligned}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

280

<!-- page 30 -->

# Paired selection

* $a_h = 2$ for all $h$

$$
\text{var}(r) \approx \frac{1}{x^2} \left[
\begin{aligned}
&\sum_{h=1}^{H} (1 - f_h)(y_{h1} - y_{h2})^2 + r^2 \sum_{h=1}^{H} (1 - f_h)(x_{h1} - x_{h2})^2 \\
&- 2r \sum_{h=1}^{H} (1 - f_h)(y_{h1} - y_{h2})(x_{h1} - x_{h2})
\end{aligned}
\right]
$$

* Selection may be
  - Paired selection design
  - Systematic selection collapsed to paired differences
  - One selection per stratum collapsed to pairs

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

281

<!-- page 31 -->

# Successive differences

- Systematic selection from ordered list
- Successive differences ($a_h > 2$ for all $h$):

$$
\text{var}(r) \approx \frac{1}{x^2} \left[
\begin{aligned}
& \sum_{h=1}^{H} \frac{a_h(1 - f_h)}{2(a_h - 1)} \sum_{g=1}^{a_h-1} (y_{hg} - y_{h,g+1})^2 \\
+ & r^2 \sum_{h=1}^{H} \frac{a_h(1 - f_h)}{2(a_h - 1)} \sum_{g=1}^{a_h-1} (x_{hg} - x_{h,g+1})^2 \\
- & 2r \sum_{h=1}^{H} \frac{a_h(1 - f_h)}{2(a_h - 1)} \sum_{g=1}^{a_h-1} (y_{hg} - y_{h,g+1})(x_{hg} - x_{h,g+1})
\end{aligned}
\right]
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

282

<!-- page 32 -->

# Alternative formulation

* These formulas can also be expressed in terms of $z_{h\alpha}$
* Reflect an underlying bivariate regression of $y$ on $x$ through the origin
* $z_{h\alpha} = y_{h\alpha} - rx_{h\alpha}$

©2017, Raphael Nishimura and James M. Lepkowski @ IPSDS

283

<!-- page 33 -->

# Hospital example revisited

| Sample hospital-day $\alpha$ | Total visits $x_{\alpha}$ | Trauma visits $y_{\alpha}$ | $z_{\alpha} = y_{\alpha} - r x_{\alpha}$ |
| :---: | :---: | :---: | :---: |
| 1 | 58 | 40 | 13.9 |
| 2 | 47 | 16 | -5.2 |
| 3 | 37 | 8 | -8.7 |
| 4 | 69 | 27 | -4.1 |
| 5 | 40 | 10 | -8.0 |
| 6 | 27 | 18 | 5.9 |
| 7 | 34 | 17 | 1.7 |
| 8 | 30 | 12 | -1.5 |
| 9 | 26 | 16 | 4.3 |
| 10 | 32 | 16 | 1.6 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

284

<!-- page 34 -->

# Three formulas revisited

$$
\text{var}(r) \approx \frac{1}{x^2} \left[ \sum_{h=1}^H \frac{a_h(1 - f_h)}{a_h - 1} \left( \sum_{\alpha=1}^{a_h} z_{h\alpha}^2 - \frac{z_h^2}{a_h} \right) \right]
$$

$$
\text{var}(r) \approx \frac{1}{x^2} \left[ \sum_{h=1}^H (1 - f_h) (z_{h1} - z_{h2})^2 \right]
$$

$$
\text{var}(r) \approx \frac{1}{x^2} \left[ \sum_{h=1}^H \frac{a_h(1 - f_h)}{2(a_h - 1)} \sum_{g=1}^{a_h-1} (z_{hg} - z_{h,g+1})^2 \right]
$$

285

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 35 -->

# Unit 6: Unequal Sized Clusters
# Complex Designs

---

A. Illustration
B. Probabilities of selection
C. Weighted mean
D. Increase in variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS
286

<!-- page 36 -->

# Unit 6: Unequal Sized Clusters
# Complex Designs

---

A. Illustration
B. Probabilities of selection
C. Weighted mean
D. Increase in variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS
287

<!-- page 37 -->

# A. Illustration

- Select adults in public housing apartments
- Study problem of crime victimization among public housing residents
- Select a sample of $a = 10$ apartments from master list provided by the public housing authority
  - Among $A_1 = 300$ apartments east of the expressway, select $a_1 = 5$ apartments and adults
  - Among $A_2 = 100$ apartments west of the expressway, select $a_2 = 5$ apartments and adults
- Within apartments, list adults, select 1 at random
- Obtain a report of the number of times selected adult was victimized in the last 12 months

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

288

<!-- page 38 -->

# Sample data

| Stratum $h$ | Apt. $\alpha$ | No. adults $B_{h\alpha}$ | Resp. $y_{h\alpha\beta}$ | Weight $w_{h\alpha\beta}$ | Wgtd. Resp. $w_{h\alpha\beta}y_{h\alpha\beta}$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| East | 1 | 2 | 2 | 120 | 240 |
| | 2 | 1 | 0 | 60 | 0 |
| | 3 | 3 | 1 | 180 | 180 |
| | 4 | 2 | 4 | 120 | 480 |
| | 5 | 1 | 2 | 60 | 120 |
| West | 1 | 1 | 0 | 20 | 0 |
| | 2 | 2 | 1 | 40 | 40 |
| | 3 | 2 | 1 | 40 | 40 |
| | 4 | 3 | 5 | 60 | 300 |
| | 5 | 2 | 2 | 40 | 80 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

289

<!-- page 39 -->

# Unit 6: Unequal Sized Clusters
# Complex Designs

A. Illustration
B. Probabilities of selection
C. Weighted mean
D. Increase in variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

290

<!-- page 40 -->

# Unit 6: Unequal Sized Clusters Complex Designs

---

A. Illustration
B. **Probabilities of selection**
C. Weighted mean
D. Increase in variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

291

<!-- page 41 -->

# B. Probabilities of selection

* Probabilities of selection vary by strata and apartments:

$$\Pr\{h\alpha\beta\} = \Pr\{h\alpha\} \times \Pr\{\beta \mid h\alpha\}$$

  – $h$ denotes the "side" of the expressway
  – $\alpha$ denotes the apartment
  – $\beta$ denotes the adult within the apartment

* Alternatively,

$$\Pr\{\text{selecting adult}\} = \Pr\{\text{selecting apartment}\} \times \Pr\{\text{selecting adult} \mid \text{apartment selected}\}$$

* Compensatory weight the inverse: $w_{h\alpha\beta} = 1/\Pr\{h\alpha\beta\}$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

292

<!-- page 42 -->

# Sample data

| Stratum $h$ | Apt. $\alpha$ | No. adults $B_{h\alpha}$ | Resp. $y_{h\alpha\beta}$ | Weight $w_{h\alpha\beta}$ | Wgtd. Resp. $w_{h\alpha\beta} y_{h\alpha\beta}$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| East | 1 | 2 | 2 | 120 | 240 |
| | 2 | 1 | 0 | 60 | 0 |
| | 3 | 3 | 1 | 180 | 180 |
| | 4 | 2 | 4 | 120 | 480 |
| | 5 | 1 | 2 | 60 | 120 |
| West | 1 | 1 | 0 | 20 | 0 |
| | 2 | 2 | 1 | 40 | 40 |
| | 3 | 2 | 1 | 40 | 40 |
| | 4 | 3 | 5 | 60 | 300 |
| | 5 | 2 | 2 | 40 | 80 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

293

<!-- page 43 -->

# Two apartments

* For an east-side apartment, $\Pr \{11\beta\} = \Pr \{11\} \times \Pr \{\beta | 11\} = \frac{5}{300} \times \frac{1}{B_{11}}$
  - $B_{11} =$ number of adults in apartment $\{11\} = 2$
  - $\Pr \{11\beta\} = \frac{5}{300} \times \frac{1}{2} = \frac{1}{120}$
  - Weight
$$w_{11\beta} = (1/120)^{-1} = 120$$

* Similarly, $\Pr \{21\beta\} = \Pr \{21\} \times \Pr \{\beta | 21\} = \frac{5}{100} \times \frac{1}{B_{21}}$
* Weight $w_{21\beta} = (1/20)^{-1} = 20$

294

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 44 -->

# Unit 6: Unequal Sized Clusters Complex Designs

A. Illustration
B. Probabilities of selection
C. Weighted mean
D. Increase in variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

295

<!-- page 45 -->

# Unit 6: Unequal Sized Clusters
# Complex Designs

---

A. Illustration
B. Probabilities of selection
C. Weighted mean
D. Increase in variance

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

296

<!-- page 46 -->

# C. Weighted mean

- The weighted estimator of the mean is

$$\bar{y}_w = \frac{\sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b_{h\alpha}} w_{h\alpha\beta} y_{h\alpha\beta}}{\sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b_{h\alpha}} w_{h\alpha\beta}} = \frac{1480}{740} = 2.0$$

- In contrast, the unweighted estimate is

$$\bar{y} = \frac{\sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b_{h\alpha}} y_{h\alpha\beta}}{n} = \frac{18}{10} = 1.8$$

297

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 47 -->

# Variance estimation

* Variance estimation takes into account the fact that the denominator varies
* Depends on which sample of apartments selected
* Weighted mean is a ratio of random variables:

$$
\bar{y}_w = \frac{\sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b_{h\alpha}} w_{h\alpha\beta} y_{h\alpha\beta}}{\sum_{h=1}^H \sum_{\alpha=1}^{a_h} \sum_{\beta=1}^{b_{h\alpha}} w_{h\alpha\beta}} = \frac{\sum_{h=1}^H \sum_{\alpha=1}^{a_h} u_{h\alpha}}{\sum_{h=1}^H \sum_{\alpha=1}^{a_h} w_{h\alpha}} = \frac{u}{w}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

298

<!-- page 48 -->

# Taylor series approximation

* The approximation is

$$\text{var}(\bar{y}_w) \approx \frac{1}{w^2} \left[ \text{var}(u) + r^2 \text{var}(w) - 2r\text{cov}(u, w) \right]$$

* For stratified clusters, ignoring the fpc,

$$\text{var}(u) = \sum_{h=1}^H \left(\frac{a_h}{a_h - 1}\right) \left(\sum_{\alpha=1}^{a_h} u_{h\alpha}^2 - \frac{u_h^2}{a_h}\right)$$

$$\text{var}(w) = \sum_{h=1}^H \left(\frac{a_h}{a_h - 1}\right) \left(\sum_{\alpha=1}^{a_h} w_{h\alpha}^2 - \frac{w_h^2}{a_h}\right)$$

$$\text{cov}(w, u) = \sum_{h=1}^H \left(\frac{a_h}{a_h - 1}\right) \left(\sum_{\alpha=1}^{a_h} w_{h\alpha} u_{h\alpha} - \frac{w_h u_h}{a_h}\right)$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS 299

<!-- page 49 -->

# Sample data

| Stratum | Apt. $\alpha$ | Wght. $w_{h\alpha}$ | $u_{h\alpha}$ | $w_{h\alpha}^2$ | $u_{h\alpha}^2$ | $w_{h\alpha}u_{h\alpha}$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| East | 1 | 120 | 240 | 14400 | 57600 | 28800 |
| | 2 | 60 | 0 | 3600 | 0 | 0 |
| | 3 | 180 | 180 | 32400 | 32400 | 32400 |
| | 4 | 120 | 480 | 14400 | 230400 | 57600 |
| | 5 | 60 | 120 | 3600 | 14400 | 7200 |
| Subtotal | | 540 | 1020 | 68400 | 334800 | 126000 |
| West | 1 | 20 | 0 | 400 | 0 | 0 |
| | 2 | 40 | 40 | 1600 | 1600 | 1600 |
| | 3 | 40 | 40 | 1600 | 1600 | 1600 |
| | 4 | 60 | 300 | 3600 | 90000 | 18000 |
| | 5 | 40 | 80 | 1600 | 6400 | 3200 |
| Subtotal | | 200 | 460 | 8800 | 99600 | 24400 |
| Total | 10 | 740 | 1480 | 77200 | 434400 | 150400 |

300

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 50 -->

# Variance of sample totals

$$\begin{aligned}
\text{var}(u) &= \sum_{h=1}^{H} \left( \frac{a_h}{a_h - 1} \right) \left( \sum_{\alpha=1}^{a_h} u_{h\alpha}^2 - \frac{u_h^2}{a_h} \right) \\
&= \left( \frac{5}{4} \right) \left( 334800 - \frac{1020^2}{5} \right) + \left( \frac{5}{4} \right) \left( 99600 - \frac{460^2}{5} \right) = 230,000
\end{aligned}$$

$$\begin{aligned}
\text{var}(w) &= \sum_{h=1}^{H} \left( \frac{a_h}{a_h - 1} \right) \left( \sum_{\alpha=1}^{a_h} w_{h\alpha}^2 - \frac{w_h^2}{a_h} \right) \\
&= \left( \frac{5}{4} \right) \left( 68400 - \frac{540^2}{5} \right) + \left( \frac{5}{4} \right) \left( 8800 - \frac{200^2}{5} \right) = 13,600
\end{aligned}$$

$$\begin{aligned}
\text{cov}(u, w) &= \sum_{h=1}^{H} \left( \frac{a_h}{a_h - 1} \right) \left( \sum_{\alpha=1}^{a_h} u_{h\alpha} w_{h\alpha} - \frac{u_h w_h}{a_h} \right) \\
&= \left( \frac{5}{4} \right) \left( 126000 - \frac{540 \times 1020}{5} \right) + \left( \frac{5}{4} \right) \left( 24400 - \frac{200 \times 460}{5} \right) = 27,300
\end{aligned}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

301

<!-- page 51 -->

# Ratio mean estimated variance

* Combining these estimates,

$$
\begin{aligned}
\text{var}(\bar{y}_w) &\approx \frac{1}{740^2}\left[230,000 + (2.0)^2(13,600) - 2(2.0)(27,300)\right] \\
&= 0.3199 \\
se(\bar{y}_w) &= 0.5656
\end{aligned}
$$

* For confidence intervals, $df = a - H$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

302

<!-- page 52 -->

# Unit 6: Unequal Sized Clusters Complex Designs

---

A. Illustration
B. Probabilities of selection
C. Weighted mean
D. Increase in variance

303

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 53 -->

# Unit 6: Unequal Sized Clusters
# Complex Designs

---

A. Illustration
B. Probabilities of selection
C. Weighted mean
D. Increase in variance

304

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 54 -->

# D. Increase in variance

* Weighting can increase sampling variance of estimates
* Assuming “arbitrary” weighting
* Potential increase in variance due to weighting:

$$1 + L = \frac{n\left(\sum_{i=1}^{n} w_i^2\right)}{\left(\sum_{i=1}^{n} w_i\right)^2} = \frac{10(77200)}{(740)^2} = 1.410$$

* Increase depends on variability of weights.

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

305

<!-- page 55 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

306

<!-- page 56 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

307

<!-- page 57 -->

# A. Controlling sample size

* Potentially large variation in sample size
  - A ratio mean for design-consistent estimation
* More control over sample size. Why?
  - Bias of $r$
  - Variance of $r$
* Equalize workloads controlling survey costs

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

308

<!-- page 58 -->

# Example: Two-stage selection

* A sample of $n = 36$ employees from $N = 2,160$
  - $f = 36/2160 = 1/60$

| Unit | No. | Unit | No. |
| :---: | :---: | :---: | :---: |
| 1 | 443 | 6 | 291 |
| 2 | 162 | 7 | 64 |
| 3 | 127 | 8 | 70 |
| 4 | 554 | 9 | 232 |
| 5 | 115 | 10 | 102 |

309
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 59 -->

# Sample size control

* Redefine clusters
* Stratification by size, varying sampling rates by size of cluster stratum
* Give up *epsem* for equal size subsamples
* Probabilities proportionate to size (PPS)

310

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 60 -->

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

311

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 61 -->

# Stratify by size

| Stratum I Unit | Stratum I No. | Stratum II Unit | Stratum II No. |
| :---: | :---: | :---: | :---: |
| 2 | 162 | 1 | 443 |
| 3 | 127 | 4 | 554 |
| 5 | 115 | 6 | 291 |
| 7 | 64 | 9 | $\underline{232}$ |
| 8 | 70 | | 1520 |
| 10 | $\underline{102}$ | | |
| | 640 | | |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

312

<!-- page 62 -->

# Varying sampling rates

* Obtain *epsem* by choice of first and second stage rates:
* Use in stratum I: $f_{Ia} = \frac{1}{6} \quad f_{Ib} = \frac{1}{10}$
* Use in stratum II: $f_{IIa} = \frac{1}{4} \quad f_{IIb} = \frac{1}{15}$
* Sample size in stratum I ranges from 6 to 17, stratum II from 15 to 37
* $\text{cv}(x)$ has been reduced within strata.

313

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 63 -->

# Equal subsample size

- Select clusters with equal rates but take equal size subsamples
- Non-*epsem* design

$$f = f_a f_{b|a} = \left(\frac{a}{A}\right)\left(\frac{b}{B_\alpha}\right) = \left(\frac{2}{10}\right)\left(\frac{18}{B_\alpha}\right) = \frac{16}{10 \times B_\alpha} = f_\alpha$$

- Knowing $B_\alpha$ for each selected cluster, create weights $w_{\alpha\beta} = f_\alpha^{-1}$
- Constant overall workloads at the price of weighting and increases in sampling variances relative to *epsem* designs

314

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 64 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

315

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 65 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

316

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 66 -->

# PPS, or how to achieve *epsem* and equal subsample sizes at the same time

* Goal: Select a two stage sample such that there are equal subsample sizes in each cluster with *epsem*
* We want an overall *epsem* rate $f = n/N$ such that the sampling rate in the second stage is $b/B_\alpha$

$$f = f_\alpha f_{\beta|\alpha} = (f_\alpha) \left( \frac{b}{B_\alpha} \right) = \left( \frac{n}{N} \right)$$

* Solving $f_\alpha = \frac{n}{N} \times \frac{B_\alpha}{b} = \frac{ab}{\sum_{\alpha=1}^A B_\alpha} \times \frac{B_\alpha}{b} = \frac{a B_\alpha}{\sum_{\alpha=1}^A B_\alpha}$

317

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 67 -->

# PPS implications

* Select clusters with probabilities proportionate to their size, $B_\alpha$
  - Overall the selection becomes $f = \frac{a B_\alpha}{\sum_{\alpha=1}^A B_\alpha} \times \frac{b}{B_\alpha}$

* Selection probability varies at both first & second stages
  - Overall, *epsem*
  - Large <u>clusters</u> selected with high probabilities, *subsampled* at low rate
  - Small <u>clusters</u> selected with low probabilities, *subsampled* at high rate

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

318

<!-- page 68 -->

# Selecting clusters with PPS

---

* Two approaches
  - Simple replicated subsampling – at random and with replacement
  - Systematic sample and without replacement
* For both approaches, need to cumulate (sequentially add up) the size of the clusters

319

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 69 -->

# Selecting clusters with PPS

| Unit | $\text{B}_\alpha$ | Cum. $\text{B}_\alpha$ | Unit | $\text{B}_\alpha$ | Cum. $\text{B}_\alpha$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 443 | 443 | 6 | 291 | 1692 |
| 2 | 162 | 605 | 7 | 64 | 1756 |
| 3 | 127 | 732 | 8 | 70 | 1826 |
| 4 | 554 | 1286 | 9 | 232 | 2058 |
| 5 | 115 | 1401 | 10 | 102 | 2160 |

320
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 70 -->

# Using cumulative counts

* Simple replicated subsampling for $a=2$:
  - Select *RN* from 1 to 2160 with replacement
  - Find the cluster (Unit) with cumulative sum first exceeding *RN*
  - Select
  - Repeat
  - Subsampling rate $b/B_\alpha$ requires exactly $b$
* If cluster selected $k$ times, take $k \times b$ elements
* Subsampling: SRS, systematic, stratified element, even cluster sampling

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

321

<!-- page 71 -->

# Calculating subsampling rates

* For example, $RN_1=702$ and $RN_2 = 1744$ select Units 3 and 7

* For Unit 3, $\frac{aB_\alpha}{N} = \frac{2 \times 127}{2160} = \frac{1}{8.504}$

* Yields within $\frac{b}{B_\alpha} = \frac{18}{127} = \frac{1}{7.056}$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

322

<!-- page 72 -->

# Variance estimation

* For PPS, $n=ab$ is fixed. Hence,

$$\bar{y} = \frac{\sum_{\alpha=1}^a \sum_{\beta=1}^b y_{\alpha\beta}}{ab}$$

$$\text{var}(\bar{y}) = \frac{(1-f)}{a} s_a^2$$

323

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 73 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

324

<!-- page 74 -->

# Unit 6: Unequal Sized Clusters
# PPS

---

A. Controlling sample size
B. PPS
C. Systematic PPS

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

325

<!-- page 75 -->

# C. Systematic PPS

* Compute zone size: $N/a = 2160/2 = 1080$
  * Select one subsample from each zone size 1080
  * Zone boundary falls 348 "elements" (measure units) through Unit 4; falls in 2 zones
* Select Units by selecting $RS$ from 1 to 1080
  * Identify selection from cumulative counts
  * Add the interval $k = 1080$ to the $RS$
  * Identify next selected cluster
  * Select one subsample from each at the rate $b/B_\alpha$

326

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 76 -->

# Selecting clusters with PPS

| Unit | $B_\alpha$ | Cum. $B_\alpha$ | Unit | $B_\alpha$ | Cum. $B_\alpha$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 443 | 443 | 6 | 291 | 1692 |
| 2 | 162 | 605 | 7 | 64 | 1756 |
| 3 | 127 | 732 | 8 | 70 | 1826 |
| 4 | 554 | 1286 | 9 | 232 | 2058 |
| 5 | 115 | 1401 | 10 | 102 | 2160 |

327

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 77 -->

# Within sampling rates

* For example, suppose $RN = 804$
  - Select $\alpha = 4$
  - $RN + I = 804 + 1080 = 1884$ selects $\alpha = 9$

* For $\alpha = 4$, $\frac{aB_\alpha}{N} = \frac{B_\alpha}{N/a} = \frac{554}{2160/2} = \frac{554}{1080} = \frac{1}{1.950}$

* Subsample $\frac{b}{B_4} = \frac{18}{554} = \frac{1}{30.78}$

328

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 78 -->

# PPS without replacement

* Large literature on without replacement PPS selection procedures
* Alternatives lead to variance estimation expressions that require knowledge about the joint probabilities of selection
* Horvitz-Thompson estimator and the Yates-Grundy estimator of variance
* Unfortunately, the Yates-Grundy estimator can be negative
* Literature proposes wide variety of designs to overcome this problem

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

329

<!-- page 79 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

330

<!-- page 80 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

331
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 81 -->

# A. Estimated size measures

* Suppose that the exact count of elements -- $B_\alpha$ -- in each cluster is unknown
* But measure that approximates the number of units (that is, the size) in each cluster -- Measure of Size -- $Mos_\alpha$
* Example: Do not know the current exact count of employees for each Unit
  * Do know the number counted for each Unit at the last payroll one month ago

332

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 82 -->

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

<!-- page 83 -->

# PPeS

* Probabilities proportionate to <u>estimated</u> size: *epsem* design in two stages
* Over-sample large clusters relative to small
* Select clusters with the rate $\frac{aMos_\alpha}{\sum_{\alpha=1}^A Mos_\alpha}$
* Then subsample elements at rate $\frac{b^*}{Mos_\alpha}$
* Why $b^*$?
  - The actual number of second stage units selected is unknown; it’s a target subsample size
  - If $Mos_\alpha = B_\alpha$, then $b^*=b$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

334

<!-- page 84 -->

# Selecting units with PPeS

* Returning to employees example, suppose $b^*=18$, $a=2$, and
* $a = 2$ clusters are selected $\sum_{\alpha=1}^{10} Mos_\alpha = 2160$
* One subsample of expected size $b^* = 18$ each

$$
f = \frac{2 Mos_\alpha}{\sum Mos_\alpha} \times \frac{18}{Mos_\alpha} = \frac{36}{2160} = \frac{1}{60}
$$

* With PPeS sampling, subsampling at a specified rate and <u>not</u> selecting a <u>fixed</u> number of elements from each selected cluster

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

335

<!-- page 85 -->

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

<!-- page 86 -->

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

<!-- page 87 -->

# Sample size variation returns

- But here $Mos_\alpha \cong B_\alpha$
- For Unit 3, $B_\alpha = 130$ , and $\frac{b}{Mos_3} = \frac{1}{7.056}$ yields

$$
x_a = \frac{b}{Mos_\alpha} \times B_\alpha = \frac{1}{7.056} \times 130 = 18.425
$$

- For interval 7.056, select a sample of 18 employees with probability 0.575
- Or a sample of 19 with probability 0.425

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

338

<!-- page 88 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

339

<!-- page 89 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

340

<!-- page 90 -->

# B. Stratification

---

* $Mos$, $a$, $b^*$, etc., are specified within strata

$$
f = f_h = \frac{a_h Mos_{h\alpha}}{\sum_{\alpha=1}^{A_h} Mos_{h\alpha}} \times \frac{b_h^*}{Mos_{h\alpha}} = \frac{a_h b_h^*}{\sum_{\alpha=1}^{A_h} Mos_{h\alpha}}
$$

* Retain *epsem* for stratified PPeS sampling across strata: $f = f_h$ for all $h$.

341

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 91 -->

# Implicit stratification

* Systematic PPeS sampling implicitly stratifies by selecting within each zone one subsample size $b^*$
* Stratification notation not necessary with this design
* Zone size (or sampling interval) is

$$
\frac{\sum_{\alpha=1}^{A_h} Mos_{h\alpha}}{a_h}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

342

<!-- page 92 -->

# Select $a = 4$ units

* $a = 4$ subsamples of size $b^* = 18$ from $Mos_t = 2160$
* Then

$$f = \frac{ab^*}{\sum Mos_\alpha} = \frac{4 \times 18}{2160} = \frac{1}{30}$$

* Zone size is $2160/4 = 540$

343

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 93 -->

# Explicit stratification

| Stratum I | | Stratum II | |
| :---: | ---: | :---: | ---: |
| Unit | Mos | Unit | Mos |
| 1 | 443 | 5 | 115 |
| 2 | 162 | 6 | 291 |
| 3 | 127 | 7 | 64 |
| 4 | 554 | 8 | 70 |
| | | 9 | 232 |
| | | 10 | 102 |
| Total | 1286 | | 874 |

344

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 94 -->

# Paired selection

$$
f_1 = \frac{1}{30} \neq \frac{2Mos_{1\alpha}}{\sum_{\alpha=1}^{A_1} Mos_{1\alpha}} \frac{18}{Mos_{1\alpha}} = \frac{36}{1286}
$$

$$
f_2 = \frac{1}{30} \neq \frac{2Mos_{2\alpha}}{\sum_{\alpha=1}^{A_2} Mos_{2\alpha}} \frac{18}{Mos_{2\alpha}} = \frac{36}{874}
$$

* Can manipulate $a_h, b_h^*, \sum_{\alpha=1}^{A_h} Mos_{h\alpha}$
* Uncommon to vary $a_h$

345

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 95 -->

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

<!-- page 96 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

347

<!-- page 97 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

348
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 98 -->

# C. Oversize units

* Oversize units are clusters for which $Mos_{h\alpha}$ is so large that the unit has a certain chance of selection
  - Often so large that they will be selected multiple times in systematic PPeS
* For example, Unit 4 has $Mos_4 = 554 > 540$
  - Selected twice with probability

$$\frac{Mos_4}{540} = 1.0259$$

349

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 99 -->

# Solutions

* If there are few such clusters and chances of multiple selections small leave them in the list
  - If one selected $k$ times, select $k$ subsamples
* If there are many such clusters comprising a large share of the population, place in separate strata
  - Each such cluster is now a stratum, a cluster selected with certainty
  - Sampling rate(s) are applied directly within clusters
  - Self-representing units (SRU)

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

350

<!-- page 100 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

351
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 101 -->

# Unit 6: Unequal Sized Clusters PPeS

---

A. Estimated size measures
B. Stratification
C. Oversize units
D. Undersize units

352

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 102 -->

# D. Undersize units

---

* Undersize units are clusters for which $Mos_{h\alpha} < cb^*$
* $Mos_{h\alpha} < b^*$ implies sampling within cluster at rate $> 1$
* All elements must be selected in the cluster, and

$$
f = \frac{a_h Mos_{h\alpha}}{\sum Mos_{h\alpha}} \times 1
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

353

<!-- page 103 -->

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

<!-- page 104 -->

# Linking after (during) selection

(1) Identify selected unit (block). If the selected unit and next on the list are minimum sufficient size, STOP

(2) If selected unit or next are not of minimum sufficient size,
    a) Move forward in list until first unit of minimum sufficient size is encountered
    b) Cumulate units backwards until a linked unit of minimum sufficient size is created
    c) Continue process until the selected unit is linked

355

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 105 -->

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

356

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 106 -->

# Example

| Tract | Block | HU's |
| :--- | :--- | :--- |
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

Link 101-113, 212-213, size = 38

e = 2

Link 105-113, size = 1

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

357

*[Figure: The diagram shows an annotated table with columns for "Tract", "Block", and "HU's", comparing housing unit counts across blocks in tracts 28 and 29. Red circles, brackets, curved arrows, and callout boxes illustrate a linking procedure that merges blocks with zero or very small housing unit counts (such as blocks 101–113 and 213) into neighboring blocks to reach a combined cluster size of 38.]*
