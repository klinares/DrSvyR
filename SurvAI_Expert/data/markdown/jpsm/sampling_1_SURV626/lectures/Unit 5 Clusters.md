---
id: "jpsm/sampling_1_SURV626/lectures/Unit_5_Clusters"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "Unit 5: Clusters"
original: "sampling_1_SURV626/lectures/Unit 5 Clusters.pdf"
pages: 54
sha256: "6e5d6ae04aaa45a9130df2f75af7e462d4247b2eecb9601e6fdbddc4ae467d50"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:12"
---

<!-- page 1 -->

# Unit 5: Clusters
# Cluster Sampling

---

A. Clusters and survey costs
B. Variance of the mean
C. Design effect

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

198

<!-- page 2 -->

# Unit 5: Clusters
# Cluster Sampling

---

A. Clusters and survey costs
B. Variance of the mean
C. Design effect

199

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 3 -->

# A. Cluster and survey costs

* Populations often distributed geographically
  - Cannot afford to visit $n$ units drawn randomly from the entire area
  - Cannot afford to create an element frame
* Cluster selections are used to reduce costs
  - Select clusters and list elements only for selected clusters
* Clusters naturally occurring units:
  - Seldom equal size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

200

<!-- page 4 -->

# Unit 5: Clusters
# Cluster Sampling

---

A. Clusters and survey costs
B. Variance of the mean
C. Design effect

201

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 5 -->

# Unit 5: Clusters
# Cluster Sampling

---

A. Clusters and survey costs
B. Variance of the mean
C. Design effect

202

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 6 -->

# B. Variance of the mean

Target Population Elements:

101 Main St.
104 Main St.
107 Main St.
112 Main St.
115 Main St.
122 Main St.
129 Main St.
132 Main St.
201 Main St.
206 Main St.
.   .
.   .
.

$$\bar{Y} = \left. \sum_{i=1}^{N} Y_i \right/ N$$

$$S^2 = \left. \sum_{i=1}^{N} \left( Y_i - \bar{Y} \right)^2 \right/ (N - 1)$$

203

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 7 -->

# Notation

* $\text{A} =$ the number of clusters in the population
* $\text{a} =$ the number of clusters in the sample
* $\text{B} =$ the number of elements in each cluster
* $\frac{\text{a}}{\text{A}}$ is the rate at which clusters are selected
* If we select all elements within a cluster, the rate is $\frac{\text{B}}{\text{B}} = 1$
* $\frac{\text{a}}{\text{A}} \times \frac{\text{B}}{\text{B}} = \frac{n}{N}$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

204

<!-- page 8 -->

# Clustered population

$$
\bar{Y}_\alpha = \sum_{\beta=1}^{B} Y_{\alpha\beta} \bigg/ B
$$

$$
\bar{Y} = \sum_{i=1}^{N} Y_i \bigg/ N
$$

$$
S_\alpha^2 = \sum_{\beta=1}^{B} \left( Y_{\alpha\beta} - \bar{Y}_\alpha \right)^2 \bigg/ (B - 1)
$$

$$
S^2 = \sum_{i=1}^{N} \left( Y_i - \bar{Y} \right)^2 \bigg/ (N - 1)
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

205

<!-- page 9 -->

# Element sample

$$
\bar{y} = \sum_{i=1}^{n} y_i \bigg/ n
$$

$$
\bar{Y} = \sum_{i=1}^{N} Y_i \bigg/ N
$$

| | | | | | | | | | | |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | | 2 | | 7 | | 8 | | 13 | | 14 |
| | | Second St. | | | | | | | | |
| 3 | Main St. | 4 | Elm St. | 9 | Oak St. | 10 | Maple St. | 15 | Ash St. | 16 |
| | | First St. | | | | | | | | |
| 5 | | 6 | | 11 | | 12 | | 17 | | 18 |

$$
s^2 = \sum_{i=1}^{n} (y_i - \bar{y})^2 \bigg/ (n-1)
$$

$$
Var(\bar{y}) = \frac{(1-f)}{n} S^2
$$

$$
S^2 = \sum_{i=1}^{N} (Y_i - \bar{Y})^2 \bigg/ (N-1)
$$

206

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 10 -->

# Cluster sample

$$\bar{y} = \left. \sum_{\alpha=1}^a \sum_{\beta=1}^B y_{\alpha\beta} \right/ aB$$

$$s_\alpha^2 = \left. \sum_{\beta=1}^B \left(y_{\alpha\beta} - \bar{y}_\alpha\right)^2 \right/ (B-1)$$

$$\bar{Y} = \left. \sum_{i=1}^N Y_i \right/ N$$

| 1 | 2 | 7 | 8 | 13 | 14 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| | **Second St.** | | | | |
| 3 | **Main St.** 4 | **Elm St.** 9 | **Oak St.** 10 | **Maple St.** 15 | **Ash St.** 16 |
| | **First St.** | | | | |
| 5 | 6 | 11 | 12 | 17 | 18 |

$$s_a^2 = \left. \sum_{\alpha=1}^a \left(\bar{y}_\alpha - \bar{y}\right)^2 \right/ (a-1)$$

$$Var(\bar{y}) = \frac{(1-f)}{a} S_a^2$$

$$S^2 = \left. \sum_{i=1}^N \left(Y_i - \bar{Y}\right)^2 \right/ (N-1)$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

207

<!-- page 11 -->

# Computing formulas

* Here we estimate

$$\text{var}(\bar{y}) = \frac{1-f}{a} s_a^2 = \frac{1-f}{a} \frac{\sum_{\alpha=1}^a (\bar{y}_\alpha - \bar{y})^2}{a-1}$$

* But there is an algebraic expansion...

$$\text{var}(\bar{y}) = \frac{1-f}{a} \frac{\left[ \sum_{\alpha=1}^a \bar{y}_\alpha^2 - \frac{\left( \sum_{\alpha=1}^a \bar{y}_\alpha \right)^2}{a} \right]}{a-1}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

208

<!-- page 12 -->

# Computing formulas

* And that algebraic expansion is converted into one involving cluster totals:

$$
\begin{aligned}
\text{var}\left(\bar{y}\right) &= \frac{1-f}{a} \frac{\left[ \sum_{\alpha=1}^a \bar{y}_\alpha^2 - \frac{\left(\sum_{\alpha=1}^a \bar{y}_\alpha\right)^2}{a} \right]}{a-1} = \frac{1-f}{a\left(a-1\right)} \left[ \sum_{a=1}^a \left(\frac{y_\alpha}{B}\right)^2 - \frac{\left(\sum_{\alpha=1}^a \frac{y_\alpha}{B}\right)^2}{a} \right] \\
&= \frac{1-f}{aB^2\left(a-1\right)} \left[ \sum_{\alpha=1}^a y_\alpha^2 - \frac{\left(\sum_{\alpha=1}^a y_\alpha\right)^2}{a} \right]
\end{aligned}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

209

<!-- page 13 -->

# Computing formulas

* So, for taking complete clusters (simple cluster sampling),

$$
\begin{aligned}
\text{var}(\bar{y}) &= \frac{1 - f}{a} s_a^2 \\
&= \frac{1 - f}{a} \frac{\sum_{\alpha=1}^a (\bar{y}_\alpha - \bar{y})^2}{a - 1} \\
&= \frac{1 - f}{a B^2 (a - 1)} \left[ \sum_{\alpha=1}^a y_\alpha^2 - \frac{\left(\sum_{\alpha=1}^a y_\alpha\right)^2}{a} \right]
\end{aligned}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

210

<!-- page 14 -->

# Unit 5: Clusters
# Cluster Sampling

---

A. Clusters and survey costs
B. Variance of the mean
C. Design effect

211

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 15 -->

# Unit 5: Clusters
# Cluster Sampling

---

A. Clusters and survey costs
B. Variance of the mean
C. Design effect

212

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 16 -->

# C. Design effect

* There is no particular reason $\text{var}(\bar{y}) \neq \text{var}_{SRS}(\bar{y})$

* For cluster sampling:

$$deff = \frac{Var(\bar{y})}{Var_{srs}(\bar{y})} = \frac{\frac{1-f}{a}S_a^2}{\frac{1-f}{n}S^2} = \frac{S_a^2 / a}{S^2 / n} > 1.0$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

213

<!-- page 17 -->

# Design effect: Alternate form

$$
\begin{aligned}
Var(\bar{y}) &= Var\left(\frac{1}{n} \sum_{\alpha} \sum_{\beta} y_{\alpha\beta}\right) \\
&= \frac{1}{n^2} \left[ \sum_{\alpha} \sum_{\beta} Var(y_{\alpha\beta}) + \sum_{\alpha,\alpha'} \sum_{\beta,\beta'} Cov(y_{\alpha\beta}, y_{\alpha'\beta'}) \right] \\
&= \frac{1}{n^2} \left[ \sum_{\alpha} \sum_{\beta} Var(y_{\alpha\beta}) + \sum_{\alpha \neq \alpha'} \sum_{\beta} \sum_{\beta'} Cov(y_{\alpha\beta}, y_{\alpha'\beta'}) + \sum_{\alpha} \sum_{\beta \neq \beta'} Cov(y_{\alpha\beta}, y_{\alpha\beta'}) \right] = \\
&\quad \frac{1}{n^2} \left[ \sum_{\alpha} \sum_{\beta} S^2 + \sum_{\alpha \neq \alpha'} \sum_{\beta} \sum_{\beta'} 0 + \sum_{\alpha} \sum_{\beta \neq \beta'} \rho S^2 \right] \\
&= \frac{1}{n^2} \left[ nS^2 + a \cdot B(B - 1)\rho S^2 \right] = \frac{S^2}{n} \left[ 1 + (B - 1)\rho \right]
\end{aligned}
$$

214

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 18 -->

# Design effect: Intra-cluster homogeneity

* Hence

$$
\begin{aligned}
Deff &= \frac{Var(\bar{y})}{Var_{srs}(\bar{y})} \\
&= \frac{\frac{S^2}{n}[1 + (B - 1)\rho]}{\frac{S^2}{n}} \\
&= [1 + (B - 1)\rho]
\end{aligned}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

215

<!-- page 19 -->

# Features of $\rho$

* $-\frac{1}{(B-1)} < \rho < 1$ (although $\rho > 0$ generally)

* If $\rho = 0, Deff = 1.0$
  * The cluster sample is the equivalent of SRS of size $n = a \times B$

* If $\rho = 1, Deff = B$ and $Var(\bar{y}) = B \times Var_{srs}(\bar{y})$
  * The cluster sample is equivalent to an SRS of $a$ elements

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

216

<!-- page 20 -->

# Source and nature of $\rho$

* For human populations in naturally occurring clusters, factors include
  - Environment (exposure to infectious disease)
  - Self-selection (poor households in same block)
  - Interaction (shared attitudes among neighbors)
* The size depends on
  - Characteristic Y (disease status, age)
  - Nature of clusters (naturally formed)
  - Size of cluster (blocks, census tracts, counties)

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

217

<!-- page 21 -->

# Estimation of $\rho$

* Proper estimation, especially for multistage stratified samples, is cumbersome
* It is useful for design to estimate $\rho$ in a straightforward fashion
* Synthetic estimate:

$$roh = \frac{deff - 1}{B - 1}$$

218

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 22 -->

# Sample size considerations

* Implications of $\rho > 0$ for sample size:
  – Compute an SRS sample size ($n_{srs}$)
  – For B and $\rho$ (“guesstimate?”), compute $n = [1 + (B - 1)\rho)]n_{srs}$

* Design effect and confidence intervals:
  – With ($a$-1) d.f.: $\bar{y} \pm \left(t_{(1-\alpha/2;a-1)}\right)se(\bar{y})$
  or

$$
\bar{y} \pm \left(t_{(1-\alpha/2;a-1)}\right)\sqrt{[1 + (B - 1)roh]\frac{s^2}{n}}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

219

<!-- page 23 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

220

<!-- page 24 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

221

<!-- page 25 -->

# A. Subsampling clusters

* Select $b < B$ elements from a clusters *epsem* :

$$f = \frac{a}{A} \times \frac{b}{B} = \frac{a \times b}{A \times B} = \frac{n}{N}$$

  – SRS of clusters and SRS of elements within
* Define the average within cluster variance as $S_b^2 = \frac{1}{A} \sum_{\alpha=1}^A S_\alpha^2$
* Sampling variance changes:

$$Var(\bar{y}) = \left(1 - \frac{a}{A}\right) \frac{S_a^2}{a} + \left(1 - \frac{b}{B}\right) \frac{S_b^2}{ab}$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

222

<!-- page 26 -->

# Clustered population

$$
\bar{Y}_\alpha = \left. \sum_{\beta=1}^{B} Y_{\alpha\beta} \right/ B
$$

$$
\bar{Y} = \left. \sum_{i=1}^{N} Y_i \right/ N
$$

$$
S_\alpha^2 = \left. \sum_{\beta=1}^{B} \left( Y_{\alpha\beta} - \bar{Y}_\alpha \right)^2 \right/ (B - 1)
$$

$$
S^2 = \left. \sum_{i=1}^{N} \left( Y_i - \bar{Y} \right)^2 \right/ (N - 1)
$$

223

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 27 -->

# Two-stage cluster sample: 1st stage

| 1 | | 2 | | 7 | | 8 | | 13 | | 14 |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| | | **Second St.** | | | | | | | | |
| 3 | **Main St.** | 4 | **Elm St.** | 9 | **Oak St.** | 10 | **Maple St.** | 15 | **Ash St.** | 16 |
| | | **First St.** | | | | | | | | |
| 5 | | 6 | | 11 | | 12 | | 17 | | 18 |

224

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 28 -->

# Two-stage cluster sample: 1$^{\text{st}}$ and 2$^{\text{nd}}$ stage

$$
\bar{y} = \sum_{\alpha=1}^a \sum_{\beta=1}^b y_{\alpha\beta} \bigg/ ab
$$

$$
Var(\bar{y}) = \left(1 - \frac{a}{A}\right) \frac{S_a^2}{a} + \left(1 - \frac{b}{B}\right) \frac{S_b^2}{ab}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

225

<!-- page 29 -->

# Estimation of sampling variance

* Estimation of $Var(\bar{y})$ is complicated by the estimation of $S_a^2$

$$
E\left(s_b^2\right) = S_b^2
$$

$$
E\left(s_a^2\right) = S_a^2 + \left(1 - \frac{b}{B}\right)\frac{S_b^2}{b}
$$

$$
\text{var}\left(\bar{y}\right) = \left(1 - \frac{a}{A}\right)\frac{s_a^2}{a} + \frac{a}{A}\left(1 - \frac{b}{B}\right)\frac{s_b^2}{ab}
$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

226

<!-- page 30 -->

# Approximation

* If $a/A$ is negligible, then $var(\bar{y})$ reduces to

$$\text{var}(\bar{y}) = \frac{1}{a} s_a^2$$

* This approximation avoids the need to compute $s_b^2$
* There is an alternative conceptual explanation for using a reduced or simplified variance estimate ...
* Ultimate clusters
* Leads to yet a second approximation: $\text{var}(\bar{y}) = \frac{(1 - f)}{a} s_a^2$

227

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 31 -->

# Practical sampling variance estimation

- If clusters are selected with replacement and elements without, use the unbiased estimate:

$$\text{var}(\bar{y}) = \frac{(1 - f)}{a} s_a^2$$

- If clusters are selected without replacement and element without, use a slightly biased estimate:

$$\text{var}(\bar{y}) \approx \frac{(1 - f)}{a} s_a^2$$

instead of the more complicated

$$var(\bar{y}) = \left(1 - \frac{a}{A}\right)\frac{s_a^2}{a} + \left(\frac{a}{A}\right)\left(1 - \frac{b}{B}\right)\frac{s_b^2}{ab}$$

228

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 32 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

229

<!-- page 33 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

230

<!-- page 34 -->

# B. Sample size and *roh*

* **<u>Effective sample size</u>**: size of SRS that would give the same precision as the cluster sample

* $n_{eff} = n / deff$
  – $deff = 2.0$ and $n = 1500$ then $n_{eff} = 1500 / 2 = 750$

* Varying subsample size for fixed *n* changes the number of clusters, *deff*, and the effective sample size
* For two-stage cluster sample: $deff = 1 + (b - 1) roh$

231

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 35 -->

# Effective sample size

* Cluster sample with $n = 2000$, and $roh = 0.03$:
* For $b = 10, deff = 1 + (10 - 1)0.03 = 1.27$
  - $n_{eff} = 2000 / 1.27 = 1574.80$
* For $b = 20, deff = 1 + (20 - 1)0.03 = 1.57$
  - $n_{eff} = 2000 / 1.57 = 1273.89$
* For $b = 50, deff = 1 + (50 - 1)0.03 = 2.47$
  - $n_{eff} = 2000 / 2.47 = 809.72$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

232

<!-- page 36 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

233

<!-- page 37 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

234

<!-- page 38 -->

# C. Homogeneity and *roh*

* Sample 10 school classrooms from 1,000
  - Each classroom has exactly 24 children
* Alternative 1: sample characteristic is dichotomy

$$\frac{9}{24}, \frac{11}{24}, \frac{13}{24}, \frac{15}{24}, \frac{16}{24}, \frac{17}{24}, \frac{18}{24}, \frac{20}{24}, \frac{20}{24}, \frac{21}{24}$$

* Here the intra-class correlation $roh = 0.088$
* Moderate amount of homogeneity within clusters
* $deff = 1 + (24 - 1)0.088 = 3.024$
* Actual sample size $n = 240$
* Effective sample size $n_{eff} = 240 / 3.024 = 79.37$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

235

<!-- page 39 -->

# Perfect homogeneity

* Homogeneity within, heterogeneity among:

$$\frac{0}{24}, \frac{0}{24}, \frac{0}{24}, \frac{16}{24}, \frac{24}{24}, \frac{24}{24}, \frac{24}{24}, \frac{24}{24}, \frac{24}{24}, \frac{24}{24}$$

$$deff = 23.90$$

$$roh = \frac{23.90 - 1}{24 - 1} = 0.996$$

$$n_{eff} = 240 / 23.9 = 10.04$$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

236

<!-- page 40 -->

# Perfect heterogeneity

* Heterogeneity within, homogeneity among:

$$\frac{16}{24}, \frac{16}{24}, \frac{16}{24}, \frac{16}{24}, \frac{16}{24}, \frac{16}{24}, \frac{16}{24}, \frac{16}{24}, \frac{16}{24}, \frac{16}{24}$$

$$deff = 0$$

$$roh = \frac{0 - 1}{24 - 1} = -0.04348$$

$$n_{eff} = 240 / 0 = \text{undefined (total population)}$$

237

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 41 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

238

<!-- page 42 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

239

<!-- page 43 -->

# D. Portability of *roh*

* Estimation (1)

$$\text{var}_{(1)}(p) = \frac{(1-f)}{a} s_a^2$$

$$\text{var}_{(1), SRS}(\bar{y}) = \frac{p(1-p)}{n_{(1)}}$$

$$deff_{(1)} = \frac{\text{var}_{(1)}(p)}{\text{var}_{(1), SRS}(p)}$$

$$roh = \frac{deff_{(1)} - 1}{b_{(1)} - 1}$$

* Design (2)

$$\text{var}_{(2)}(p) = deff_{(2)} \times \text{var}_{(2), SRS}(p)$$

$$\text{var}_{(2), SRS}(\bar{y}) = \frac{p(1-p)}{n_{(2)}}$$

$$deff_{(2)} = 1 + (b_{(2)} - 1)roh$$

$$\boxed{roh}$$

240

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 44 -->

# Illustration

* Crime victimization survey in a large public housing project
* Sample apartments
* Responsible adult interviewed about victimizations occurring to any member of the household
* $A = 400$ floors with exactly $B = 15$ apartments
* $a = 10$ floors selected with replacement
* $b = 5$ apartments selected without replacement

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

241

<!-- page 45 -->

# Sample results

$$f = \frac{a}{A} \times \frac{b}{B} = \frac{10}{400} \times \frac{5}{15} = \frac{50}{6000} = \frac{1}{120}$$

| Sample floor | HH’s experienced any crime ($y_\alpha$) |
| :---: | :---: |
| 1 | 4 |
| 2 | 4 |
| 3 | 5 |
| 4 | 5 |
| 5 | 3 |
| 6 | 1 |
| 7 | 0 |
| 8 | 1 |
| 9 | 2 |
| 10 | 1 |

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

242

<!-- page 46 -->

# Estimation

$$
p = \bar{y} = \sum_{\alpha=1}^a \sum_{\beta=1}^b y_{\alpha\beta} / n = 26 / 50 = 0.52
$$

$$
\text{var}(\bar{y}) = \frac{1 - f}{a} s_a^2
$$

$$
s_a^2 = \frac{1}{b^2(a-1)} \left[ \sum_{\alpha=1}^a y_\alpha^2 - \frac{\left(\sum_{\alpha=1}^a y_\alpha\right)^2}{a} \right] = \frac{1}{(5)^2(9)} \left[ 98 - \frac{(26)^2}{10} \right] = 0.13511
$$

$$
\text{var}(p) = \frac{1 - \frac{1}{120}}{10} (0.13511) = 0.013399
$$

$$
se(p) = 0.11575
$$

243

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 47 -->

# Confidence interval, *deff* and *roh*

$$t_{(0.975, a-1)} = t_{(0.975, 9)} = 2.262$$

$$p \pm t_{(0.975, 9)} se(p) = (0.25815, 0.78185)$$

$$\begin{aligned}
\text{var}_{srs}(p) &= (1 - f) \frac{p(1 - p)}{n - 1} = \\
&= \left(1 - \frac{1}{120}\right) \frac{(0.52)(0.48)}{49} = 0.005051
\end{aligned}$$

$$deff = \frac{\text{var}(p)}{\text{var}_{srs}(p)} = \frac{0.013399}{0.0050514} = 2.6524$$

$$roh = \frac{deff - 1}{b - 1} = \frac{2.6524 - 1}{5 - 1} = 0.41311$$

244

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 48 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

245

<!-- page 49 -->

# Unit 5: Clusters
# Two-Stage Cluster Sampling

---

A. Subsampling clusters
B. Sample size and *roh*
C. Homogeneity and *roh*
D. Portability of *roh*
E. Subsample size

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

246

<!-- page 50 -->

# E. Subsample size

- Precision of estimates depends on $a$ and $b$
- Optimum choice for $a$ and $b$ can be obtained by minimizing the sampling variance for fixed cost (or vice versa)
- Cost model for two stage sampling:
  - $C - C_0 = a \times c_a + a \times (b \times c_b)$
  - $c_a$ is the cost per cluster and $c_b$ is the cost per observation within a cluster
- $c_b$ is dominated by interviewing costs
- $c_a$ is dominated by travel and preparation costs

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

247

<!-- page 51 -->

# Optimization

* Optimum subsample size for fixed cost $C - C_0$ can be found using a Lagrange multiplier or the Cauchy-Schwartz inequality
* Find $a$ (or $b$) to minimize the sampling variance

$$Var(\bar{y}) = \frac{S_a^2}{a} + \frac{S_b^2}{ab}$$

* The optimum $b$ is

$$b_{opt} = \sqrt{\frac{c_a}{c_b} \cdot \frac{1 - roh}{roh}}$$

248

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 52 -->

# Illustration

* Large national personal visit interview survey
* Interviews conducted within respondent homes by locally hired interviewers
* $roh$ values near $0.05$
* $n = 1,000$ is fixed
* 1 hour interview requires 2 hours interviewer time
  - Interviewer travels to the cluster, locating households, making callbacks, etc.
  - At $\$12.50$ per interviewer hour, $c_b = 2 \times \$12.50 = \$25$

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

249

<!-- page 53 -->

# Cost per cluster

* Household clusters (segments) an average 1/2 hour drive from interviewer homes
* Require an average of 3 visits each
* $3 \times \$12.50 = \$37.50$ required to pay interviewers for travel time
* Travel averages 30 m.p.h.
* At $\$0.31$ per mile, 6 trips of one half hour (15 miles) requires travel reimbursement of $(6 \times 15)(0.31) = \$27.90$
* $c_a = 37.50 + 27.90 = \$65.40$

250
©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS

<!-- page 54 -->

# Optimum $b$

* The optimum subsample size will be

$$b_{opt} = \sqrt{\frac{65.40}{25} \cdot \frac{1 - 0.05}{0.05}} = 7.05$$

251

©2017, Raphael Nishimura and James M. Lepkoswki @ IPSDS
