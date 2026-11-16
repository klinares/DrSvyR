---
id: "jpsm/sampling_1_SURV626/Design_summary_-_Sampling_Cheat_Sheet"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "lecture"
title: "Design summary - Sampling Cheat Sheet"
original: "sampling_1_SURV626/Design summary - Sampling Cheat Sheet.pdf"
pages: 4
sha256: "bc5d7f757fba5d87e8f4c558e602c669b27a5fa4b91de87054bd439b684ccf77"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:17"
---

<!-- page 1 -->

**SURVEY 625**
Applied Sampling

**SURVMETH 612**
Methods of Survey Sampling

### Design Summary

| Design | Estimated mean | Estimated sampling variance | Design effect |
| :--- | :--- | :--- | :---: |
| **SRS (without replacement)**<br>• **f = n/N** | $\bar{y} = \frac{y}{n} = p$<br><br>$= \left(\frac{1}{n}\right) \sum_{i=1}^{n} y_i$ | $\text{var}_{srs}(\bar{y}) = \frac{1 - f}{n} s^2$<br><br>$s^2 = \frac{1}{n - 1} \left( \sum_{i=1}^{n} y_i^2 - \frac{y^2}{n} \right)$<br><br>$\text{var}_{srs}(p) = \frac{1 - f}{n - 1} p(1 - p)$ | **1.0** |
| **Stratified random sampling**<br>• **f = n/N**<br>• **H strata**<br>• $n = \sum n_h$<br>• $N = \sum N_h$<br>• $f_h = n_h / N_h$<br>• $W_h = N_h / N$<br>• $\bar{y}_h = (1 / n_h) \sum_{i} y_{hi}$ | $\bar{y}_w = \sum_{h=1}^{H} W_h \bar{y}_h$<br><br>$p_w = \sum_{h=1}^{H} W_h p_h$ | $\text{var}(\bar{y}) = \sum_{h=1}^{H} W_h^2 \frac{1 - f_h}{n_h} s_h^2$<br><br>$s_h^2 = \frac{1}{n_h - 1} \left( \sum_{i=1}^{n_h} y_{hi}^2 - \frac{y_h^2}{n_h} \right)$<br><br>$\text{var}(p) = \sum_{h=1}^{H} W_h^2 \left( \frac{1 - f_h}{n_h - 1} \right) p_h (1 - p_h)$ | $\frac{\text{var}(\bar{y}_w)}{\text{var}_{srs}(\bar{y})}$ |
| **Proportionately allocated**<br>**stratified random sampling**<br>• $f_h = f$<br>• $n_h / n = N_h / N$ | $\bar{y} = \frac{y}{n} = p$<br><br>$= \left(\frac{1}{n}\right) \sum_{i=1}^{n} y_i$ | $\text{var}(\bar{y}) = \frac{1 - f}{n} \sum_{h=1}^{H} W_h s_h^2 = \frac{1 - f}{n} s_w^2$<br><br>$\text{var}(p) = \frac{1 - f}{n} \sum_{h=1}^{H} W_h \left( \frac{n_h}{n_h - 1} \right) p_h (1 - p_h)$ | $\frac{s_w^2}{s^2} < 1.0$ |

1

<!-- page 2 -->

| | | | |
| :--- | :--- | :--- | :---: |
| **Other allocations**<br>• **Equal:**<br>  $n_h = n/H$<br>• **Neyman:**<br>  $n_h = \frac{W_h S_h}{\sum W_h S_h} \bullet n$ | $\bar{y}_w = \sum_{h=1}^H W_h \bar{y}_h$<br><br>$p_w = \sum_{h=1}^H W_h p_h$ | $\text{var}(\bar{y}) = \sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} s_h^2$<br><br>$\text{var}(p) = \sum_{h=1}^H W_h^2 \frac{1 - f_h}{n_h} \left(\frac{n_h}{n_h - 1}\right) p_h(1 - p_h)$ | $\frac{\text{var}(\bar{y}_w)}{\text{var}_{srs}(\bar{y})}$ |
| **Systematic sampling**<br>• $k = N/n$<br>• **Random start from 1 to k**<br>• **Fractional intervals**<br>• **Proportionate allocation**<br>  **across zones so that**<br>  $W_h = 1/k$<br>• **Not measurable unless**<br>  **more than one random start**<br>  **is used** | $\bar{y} = \frac{y}{n} = p$<br><br>$= \left(\frac{1}{n}\right) \sum_{i=1}^n y_i$ | $\text{var}_{(1)}(\bar{y}) = \frac{1 - f}{n} s^2$<br><br>$\text{var}_{(2)}(\bar{y}) = \frac{1 - f}{n} \sum_{h=1}^H W_h s_h^2$<br><br>$\text{var}_{(3)}(\bar{y}) = \frac{1 - f}{n^2} \sum_{h=1}^{n/2} (y_{h1} - y_{h2})^2$<br><br>$\text{var}_{(4)}(\bar{y}) = \frac{1 - f}{2n(n - 1)} \sum_{g=1}^{n-1} (y_{hg} - y_{h,g+1})^2$<br><br>**[Degrees of freedom: (1) SRS, (n-1); (2) Stratified random, (n-H); (3) Paired differences, (n/2); (4) Successive differences, from (n/2) to (n-1).]** | **1.0**<br><br><br>$\frac{s_w^2}{s^2} < 1.0$<br><br><br>**< 1.0**<br><br><br>**< 1.0** |
| **Cluster sampling**<br>**(equal-sized "take all"**<br>**selection)**<br>• $f = \frac{a}{A} \bullet \frac{B}{B} = \frac{a}{A}$<br>• $n = a \bullet B$ | $\bar{y} = \left(\frac{1}{n}\right) \sum_{\alpha=1}^a \sum_{\beta=1}^B y_{\alpha\beta}$ | $\text{var}(\bar{y}) = \frac{1 - f}{a} s_a^2$<br><br>$s_a^2 = \frac{1}{B^2(a - 1)} \left(\sum_{\alpha=1}^a y_\alpha^2 - \frac{y^2}{a}\right)$<br><br>$= \frac{1}{(a - 1)} \left(\sum_{\alpha=1}^a \bar{y}_\alpha^2 - a\bar{y}^2\right) = \frac{1}{(a - 1)} \left(\sum_{\alpha=1}^a p_\alpha^2 - ap^2\right)$ | $1 + (B - 1)roh$ |

2

<!-- page 3 -->

| | | | |
| :--- | :--- | :--- | :--- |
| **Cluster sampling**<br>**(equal-sized subsamples)**<br>• **First stage: with**<br>&nbsp;&nbsp;&nbsp;**replacement**<br>• **Second stage: without**<br>&nbsp;&nbsp;&nbsp;**replacement**<br>• $f = \frac{a}{A} \bullet \frac{b}{B} = \frac{n}{N}$ | $$\bar{y} = \left(\frac{1}{n}\right) \sum_{\alpha=1}^a \sum_{\beta=1}^b y_{\alpha\beta}$$ | $$\begin{aligned} \text{var}(\bar{y}) &= \frac{1-f}{a} s_a^2 \\ s_a^2 &= \frac{1}{b^2(a-1)} \left( \sum_{\alpha=1}^a y_a^2 - \frac{y^2}{a} \right) \\ &= \frac{1}{(a-1)} \left( \sum_{\alpha=1}^a \bar{y}_a^2 - a\bar{y}^2 \right) = \frac{1}{(a-1)} \left( \sum_{\alpha=1}^a p_a^2 - ap^2 \right) \end{aligned}$$ | $1 + (b - 1)roh$ |
| **Cluster sampling**<br>**(unequal-sized clusters)**<br>• **PPeS selection**<br>• **First and second stages**<br>&nbsp;&nbsp;&nbsp;**with and without**<br>&nbsp;&nbsp;&nbsp;**replacement,**<br>&nbsp;&nbsp;&nbsp;**respectively**<br>• $f = \frac{aM_\alpha}{\sum M_\alpha} \bullet \frac{b^*}{M_\alpha}$<br>• **$x =$ sample size**<br>• $\bar{b} = x / a$ | $$\bar{y} = r = \frac{\sum_{\alpha=1}^a \sum_{\beta=1}^{b_\alpha} y_{\alpha\beta}}{\sum_{\alpha=1}^a \sum_{\beta=1}^{b_\alpha} x_{\alpha\beta}}$$ | **<u>Taylor Series approximation:</u>**<br>$$\text{var}(r) \approx \frac{1}{x^2} \left[ \text{var}(y) + r^2\text{var}(x) - 2r\text{cov}(y, x) \right]$$<br>**<u>With replacement selection of clusters:</u>**<br>$$\text{var}(r) \approx \left(\frac{1}{x^2}\right) \left(\frac{a}{a-1}\right) \left[ \sum_{\alpha=1}^a y_a^2 + r^2 \sum_{\alpha=1}^a x_a^2 - 2r \sum_{\alpha=1}^a y_\alpha x_\alpha \right]$$<br>**<u>Systematic selection of clusters:</u>**<br>$$\text{var}(r) \approx \left(\frac{1}{x^2}\right) \left(\frac{a}{2(a-1)}\right) \left[ \begin{aligned} &\sum_{g=1}^{a-1} (y_g - y_{g+1})^2 + r^2 \sum_{\alpha=1}^{a-1} (x_g - x_{g+1})^2 \\ &- 2r \sum_{\alpha=1}^{a-1} (y_g - y_{g+1})(x_g - x_{g+1}) \end{aligned} \right]$$ | $1 + (\bar{b} - 1)roh$ |

3

<!-- page 4 -->

| | | | |
| :--- | :--- | :--- | :--- |
| **Stratified cluster sampling**<br>• **Ultimate cluster sampling**<br>• **Implicitly weighted quantities** $y_{h\alpha}, x_{h\alpha}$ | $$r = \frac{\sum_{h=1}^{H} \sum_{\alpha=1}^{a} \sum_{\beta=1}^{b_\alpha} y_{h\alpha\beta}}{\sum_{h=1}^{H} \sum_{\alpha=1}^{a} \sum_{\beta=1}^{b_\alpha} x_{h\alpha\beta}}$$ | **<u>Multiple selections:</u>** $$\operatorname{var}(r) \approx \left(\frac{1}{x^2}\right) \left[ \begin{aligned} &\sum_{h=1}^{H} \left(\frac{a_h}{a_h - 1}\right) \left(\sum_{\alpha=1}^{a} y_{h\alpha}^2 - \frac{y_h^2}{a_h}\right) \\ &+ r^2 \sum_{h=1}^{H} \left(\frac{a_h}{a_h - 1}\right) \left(\sum_{\alpha=1}^{a} x_{h\alpha}^2 - \frac{x_h^2}{a_h}\right) \\ &- 2r \sum_{h=1}^{H} \left(\frac{a_h}{a_h - 1}\right) \left(\sum_{\alpha=1}^{a} y_{h\alpha} x_{h\alpha} - \frac{y_h x_h}{a_h}\right) \end{aligned} \right]$$ **<u>Paired selections:</u>** $$\operatorname{var}(r) \approx \left(\frac{1}{x^2}\right) \left[ \begin{aligned} &\sum_{h=1}^{H} \left(y_{h1} - y_{h2}\right)^2 \\ &+ r^2 \sum_{h=1}^{H} \left(x_{h1} - x_{h2}\right)^2 \\ &- 2r \sum_{h=1}^{H} \left(y_{h1} - y_{h2}\right) \left(x_{h1} - x_{h2}\right) \end{aligned} \right]$$ **<u>Successive differences:</u>** $$\operatorname{var}(r) \approx \left(\frac{1}{x^2}\right) \left[ \begin{aligned} &\sum_{h=1}^{H} \left(\frac{a_h}{2(a_h - 1)}\right) \sum_{g=1}^{a_h - 1} \left(y_{hg} - y_{h,g+1}\right)^2 \\ &+ r^2 \sum_{h=1}^{H} \left(\frac{a_h}{2(a_h - 1)}\right) \sum_{g=1}^{a_h - 1} \left(x_{hg} - x_{h,g+1}\right)^2 \\ &- 2r \sum_{h=1}^{H} \left(\frac{a_h}{2(a_h - 1)}\right) \sum_{g=1}^{a_h - 1} \left(y_{hg} - y_{h,g+1}\right) \left(x_{hg} - x_{h,g+1}\right) \end{aligned} \right]$$ | $1 + (\bar{b} - 1)roh$ |

4
