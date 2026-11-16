---
id: "jpsm/complex_sample_data_SURV701/midterm/Module1_701_review_on_complex_designs"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Review of module 1"
original: "complex_sample_data_SURV701/midterm/Module1_701 review on complex designs.pdf"
pages: 3
sha256: "c715e942394626a17861e0913c373607ce5e4a655290bd4dc53bb663ef7f2800"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:54"
---

<!-- page 1 -->

# Review of module 1

1. Multistage designs
2. Stratification

    <u>Q: To improve the efficiency of survey estimates of outcome $Y$, we should form the strata such that</u>

    a) $Y$ are homogeneous within strata but different across strata
    b) $Y$ are heterogeneous within strata but similar across strata

3. Cluster sampling

    <u>Q: cluster sampling is conducted in the consideration of</u>

    a) Cost reduction of data collection
    b) Improvement of the efficiency of survey estimates

<!-- page 2 -->

c) Unavailability of sampling frame lists of elements

<u>Q: validate that $\text{var}(p_c) = .00276$ under cluster sampling on slide 41 of module 1</u>

$$
p_c = \frac{1}{a} \sum_{\alpha=1}^a p_\alpha = \frac{1}{10} \left( \frac{9}{24} + \cdots + \frac{21}{24} \right) = .667
$$

$$
var(p_c) = (1 - f_\alpha) \frac{s_{p_\alpha}^2}{a}
$$

$$
= \left( 1 - \frac{10}{500} \right) \frac{\sum_{\alpha=1}^a (p_\alpha - p_c)^2}{(a - 1)a}
$$

$$
= \frac{1}{10} \frac{\left( \frac{9}{24} - .667 \right)^2 + \cdots + \left( \frac{21}{24} - .667 \right)^2}{10 \times 9}
$$

$$
= .00276
$$

4. Design effects

$$
d^2(\bar{y}) = \frac{var_{complex}(\bar{y})}{var_{srs}(\bar{y})}
$$

<!-- page 3 -->

5. Effective sample size

$$
n_{eff} = \frac{n}{d^2(\bar{y})}
$$

For example, in cluster sampling example,

$$
n_{eff} = \frac{n}{d^2(\bar{y})} = \frac{240}{3.029} = 79
$$

<u>Q: interpretation?</u>

79 sample units need to be selected with SRS in order to achieve the same precision as the given cluster sampling
