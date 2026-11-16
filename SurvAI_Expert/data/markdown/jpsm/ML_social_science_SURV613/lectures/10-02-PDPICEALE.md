---
id: "jpsm/ML_social_science_SURV613/lectures/10-02-PDPICEALE"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Interpretable ML"
original: "ML_social_science_SURV613/lectures/10-02-PDPICEALE.pdf"
pages: 8
sha256: "aeb3eda6a0ce2354c58e90ff19eb385bfca28bf10a47479c29699ed960a162e7"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:11"
---

<!-- page 1 -->

# Interpretable ML
## PDP, ICE, ALE

<!-- page 2 -->

Interpretable ML   PDPs, ICE, ALE

# Partial Dependence Plots

Plotting feature effects in “black box” learning methods (Friedman 2001)

$$\tilde{f}(x) = \frac{1}{n} \sum_{i=1}^{n} f(x, x_{iC})$$

General idea
* Compute $\tilde{f}(x)$ over the range of $x$ while averaging the effects of the remaining predictors $x_C$
* Generate artificial datasets by fixing $x$-values for all cases
  * Regression: Averaging over $f(x, x_{iC})$ for each value of $x$
  * Classification: Averaging over $p$ or $\text{logit}(p)$ for each value of $x$

Machine Learning for Social Science   Interpretable ML   2 / 8

<!-- page 3 -->

# Partial Dependence Plots

Constructing PDPs

1. Choose a range of values $\{x_{11}, x_{12}, \dots, x_{1k}\}$ of $x_1$
2. For each $i \in \{1, 2, \dots, k\}$
   1. Generate an artificial dataset by fixing $x_1$ to $x_{1i}$ for all cases
   2. Compute predictions for all cases using the prediction model (e.g. RF)
   3. Average the predictions over all cases
3. Plot the obtained average predictions against $x_{1i}$ for $i = 1, 2, \dots, k$

<!-- page 4 -->

Interpretable ML PDPs, ICE, ALE

# Partial Dependence Plots

Figure: Partial dependence plots

(a) CART

(b) Random Forest

Machine Learning for Social Science Interpretable ML 4 / 8

*[Figure: The figure shows two side-by-side 3D partial dependence surface plots comparing a "(a) CART" model and a "(b) Random Forest" model, each plotting the response variable $y$ on the vertical axis against input features $x_1$ and $x_2$ on the horizontal base axes. Both surfaces rise from low values (dark purple) to high values (green/yellow) mainly along one horizontal axis, with the CART plot displaying sharp, discrete step-like jumps and the Random Forest plot showing a much smoother, more gradual transition across many smaller steps.]*

<!-- page 5 -->

# Individual Conditional Expectation

ICE plots (Goldstein et al. 2014)

- Individual PDPs for all cases w/o final averaging
- One line represents the predictions for one case over the range of $x$
- Can uncover heterogeneous effects that are driven by interactions

Centered ICE plots

- Adjusts for different individual baselines
- Shows differences in prediction relative to anchor (e.g., $x_{min}$)

<!-- page 6 -->

Interpretable ML PDPs, ICE, ALE

# Individual Conditional Expectation

Figure: Centered ICE plot

Machine Learning for Social Science Interpretable ML 6 / 8

*[Figure: The figure is a Centered Individual Conditional Expectation (ICE) plot with `x` on the horizontal axis (ranging from roughly 0 to 35, with blue rug marks along the bottom) and `yhat` on the vertical axis (ranging from -25 to 0). It compares numerous individual observation curves in black against a single average trajectory in red, all originating at `yhat = 0` and showing a general downward, step-like decrease that flattens out at different levels between -5 and -28 after `x = 20`.]*

<!-- page 7 -->

# Accumulated Local Effects

ALE plots (Apley 2016)

- With correlated features, PDPs can (artificially) construct very unlikely combinations
- ALE solution:
  1. Use only cases with (similar) $x$-values within a given interval
  2. Calculate differences in predictions between upper and lower limit of this interval

$$\hat{\tilde{f}}_{j,ALE}(x) = \sum_{k=1}^{k_j(x)} \frac{1}{n_j(k)} \sum_{i: x_j^{(i)} \in N_j(k)} \left[ f(z_{k,j}, x_{\setminus j}^{(i)}) - f(z_{k-1,j}, x_{\setminus j}^{(i)}) \right]$$

$\rightarrow$ Differences in predictions in interval $z_{k,j}, z_{k-1,j}$ for cases in neighborhood $N_j(k)$ accumulated up to interval $k_j$

<!-- page 8 -->

Interpretable ML PDPs, ICE, ALE

# Accumulated Local Effects

Figure: Comparison of feature effect plots

(a) ALE

(b) PDP

Machine Learning for Social Science Interpretable ML 8 / 8

*[Figure: The figure shows a side-by-side comparison of two line plots: an Accumulated Local Effects (ALE) plot on the left and a Partial Dependence Plot (PDP) on the right, both measuring the effect of the feature "lstat" (ranging from 0 to over 30 on the x-axis, with a rug plot at the bottom). The left y-axis displays "ALE of .y" (from about -5 to 6) and the right y-axis displays "Predicted .y" (from about 19 to 32), with both curves exhibiting a very similar pattern of steep decline between "lstat" values of 0 and 20 before flattening out at higher values.]*
