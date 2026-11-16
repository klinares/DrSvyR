---
id: "jpsm/ML_social_science_SURV613/lectures/02-02-BiasVarianceTradeoff"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Bias-Variance Tradeoff"
original: "ML_social_science_SURV613/lectures/02-02-BiasVarianceTradeoff.pdf"
pages: 14
sha256: "19022a2ca607eb387f5548660c02aae6298fb153384efeea1af4926636c51575"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:10"
---

<!-- page 1 -->

# Bias-Variance Tradeoff

## ML Basics

<!-- page 2 -->

# ML process

Machine Learning task
$\downarrow$
Get and integrate data
$\downarrow$
Explore and pre-process data
$\downarrow$
Features
$\downarrow$
Training and tuning
$\downarrow$
Evaluation
$\downarrow$
Deploy, maintain and update

Machine Learning for Social Science \hfill Bias-Variance Tradeoff \hfill 2 / 13

*[Figure: This vertical flowchart diagram illustrates the sequential stages of the machine learning process, without axes or group comparisons. It depicts a linear downward progression through seven steps, starting from defining the "Machine Learning task," moving through data preparation, feature engineering, model training, and evaluation, and concluding with "Deploy, maintain and update."]*

<!-- page 3 -->

# Training and test error

Training error

$$
\overline{\text{err}} = \frac{1}{N} \sum_{i=1}^{N} L(y_i, \hat{f}(x_i))
$$

- Prediction error based on **training data**
- with e.g. squared error loss $L$

Test error

$$
\text{Err}_{\mathcal{T}} = \text{E}(L(Y, \hat{f}(X)) | \mathcal{T})
$$

- Prediction error using **test data** (given training data $\mathcal{T}$)

<!-- page 4 -->

# Training and test error

Training error

$$\overline{\text{err}} = \frac{1}{N} \sum_{i=1}^{N} L(y_i, \hat{f}(x_i))$$

* Prediction error based on **training data**
* with e.g. squared error loss $L$

Test error

$$\text{Err}_{\mathcal{T}} = \text{E}(L(Y, \hat{f}(X))|\mathcal{T})$$

* Prediction error using **test data** (given training data $\mathcal{T}$)

<!-- page 5 -->

# Training and test error

Expected test error decomposition

$$\text{Err}(x_0) = \text{Bias}^2(\hat{f}(x_0)) + \text{Var}(\hat{f}(x_0)) + \text{Var}(\varepsilon)$$

* Minimizing the (expected) test error requires
    * Low bias ($[\text{E}\hat{f}(x_0) - f(x_0)]^2$) **and**
    * Low variance ($\text{E}[\hat{f}(x_0) - \text{E}\hat{f}(x_0)]^2$)

Figure: Bias and variance illustration

Low Variance

High Variance

High Bias

Low Bias

Domingos (2012)

Machine Learning for Social Science

Bias-Variance Tradeoff

*[Figure: The figure is a 2x2 grid of bullseye targets illustrating the concepts of bias and variance, organized with columns comparing "Low Variance" and "High Variance" and rows comparing "High Bias" and "Low Bias." The main pattern shows that low bias centers the 'x' marks on the bullseye while high bias shifts them to the upper right edge, and low variance tightly clusters the marks together whereas high variance scatters them widely.]*

<!-- page 6 -->

# Bias-Variance Trade-Off

Figure: High Variance in Trees

* High Variance = Different data would lead to a different function
* Overfitting = Poor generalization to new data

*[Figure: The line plot titled "Figure: High Variance in Trees" displays a single red step-function curve across a horizontal x-axis ranging from 0.0 to 10.0 and a vertical y-axis showing values around 2, 4, and 6. The main pattern shows three distinct horizontal plateaus (around y=2, y=5, and y=7) separated by sharp vertical jumps near x=2.8 and x=8.0, with erratic, jagged fluctuations within each plateau illustrating overfitting and high variance.]*

<!-- page 7 -->

# Bias-Variance Trade-Off

Figure: High Bias in Trees

* High Bias = Blue points are poorly predicted
* Underfitting = Function should adapt better to the data

*[Figure: The plot titled "Figure: High Bias in Trees" displays a piecewise constant step function in red across an x-axis ranging from 0.0 to 10.0 and a y-axis marked at 2, 4, and 6. The main pattern shows two distinct horizontal segments representing a simple tree split, with one segment held constant near $y = 2$ for $x$ between 0.0 and roughly 2.8, and a higher segment held constant near $y = 5.5$ for $x$ from roughly 2.8 to 10.0.]*

<!-- page 8 -->

# Bias-Variance Trade-Off

Figure: Optimal Solution

* Goal: Find optimal compromise between bias and variance

*[Figure: The plot, titled "Figure: Optimal Solution," displays a step function for a single group with $x$ on the horizontal axis (ranging from 0.0 to 10.0) and $y$ on the vertical axis (with tick marks at 2, 4, and 6). The main pattern consists of three disconnected horizontal red line segments that increase in steps as $x$ increases: $y=2$ from $x=0$ to roughly $2.8$, $y=5$ from roughly $x=2.8$ to $8.0$, and $y=7$ from $x=8.0$ to $10.0$.]*

<!-- page 9 -->

Bias-Variance Trade-Off

# Bias-Variance Trade-Off

Figure: Training error and test error by model complexity

Hastie et al. (2009)

Machine Learning for Social Science
Bias-Variance Tradeoff

*[Figure: The line plot illustrates the bias-variance trade-off by graphing "Prediction Error" on the y-axis (from 0.0 to 1.2) against "Model Complexity (df)" on the x-axis (from 0 to 35), comparing training error (in blue) and test error (in red) across multiple simulated datasets (faint lines) and their averages (bold lines). As model complexity increases from the "High Bias, Low Variance" region on the left to the "Low Bias, High Variance" region on the right, the training error steadily decreases toward zero, whereas the test error initially decreases to a minimum around 20–25 degrees of freedom before curving upward again.]*

<!-- page 10 -->

# Bias-Variance Trade-Off

FIGURE 2.9. Left: *Data simulated from $f$, shown in black. Three estimates of $f$ are shown: the linear regression line (orange curve), and two smoothing spline fits (blue and green curves).* Right: *Training MSE (grey curve), test MSE (red curve), and minimum possible test MSE over all methods (dashed line). Squares represent the training and test MSEs for the three fits shown in the left-hand panel.*

Introduction to Statistical Learning (James et al. 2013)

*[Figure: The figure consists of two side-by-side plots illustrating the bias-variance trade-off: the left plot shows simulated data points along axes $X$ (0 to 100) and $Y$ (2 to 12) comparing the true function (black curve) against a linear fit (orange line) and two smoothing splines of increasing flexibility (blue and green curves). The right plot displays Mean Squared Error (0.0 to 2.5) against Flexibility (2 to 20), comparing training MSE (grey curve) and test MSE (red curve) with squares matching the three fits from the left panel, demonstrating that while training error monotonically decreases with flexibility, test error follows a U-shaped curve that reaches a minimum at intermediate flexibility (the blue fit) before rising due to overfitting.]*

<!-- page 11 -->

# Bias-Variance Trade-Off

Goal of prediction (again): Minimal **test error**

$$
\arg \min_{f \in \mathcal{F}} \mathbb{E}(L(f(x), y))
$$

but we cannot simply minimize its empirical analogue in **training data**

$$
\arg \min_{f \in \mathcal{F}} \frac{1}{N} \sum_{i=1}^N L(f(x_i), y_i)
$$

because this would overfit if the capacity of $f$ is high enough.

<!-- page 12 -->

# Bias-Variance Trade-Off

Solution: Solve (as before)

$$
\arg \min_{f \in \mathcal{F}_K} \frac{1}{N} \sum_{i=1}^N L(f(x_i), y_i)
$$

but $f$ must come from a restricted hypothesis space (limited capacity)
* Tree with at most $K$ leaves
* Regression with $\sum |\beta_j| < K$
* General form: $\text{Penalty}(f) < K$

This is **regularization** – in general form:

$$
\arg \min_{f \in \mathcal{F}} \frac{1}{N} \sum_{i=1}^N L(f(x_i), y_i) + \lambda \cdot \text{Penalty}(f)
$$

<!-- page 13 -->

Bias-Variance Trade-Off

# Quiz

**If we have a high bias problem (underfitting), what can be done?**

* Add more predictors ($=$ collect more variables or transform existing ones)?
* Allow higher function capacity ($=$ reduce regularization parameter)?
* Use more flexible algorithms (e.g., a tree instead of linear regression)?

**If we have a high variance problem (overfitting), what can be done?**

* Add more predictors ($=$ collect more variables or transform existing ones)?
* Allow higher function capacity ($=$ reduce regularization parameter)?
* Use more flexible algorithms (e.g., a tree instead of linear regression)?
* Collect more training data?

Machine Learning for Social Science | Bias-Variance Tradeoff | 12 / 13

<!-- page 14 -->

# References

Buskirk, T. D., Kirchner, A., Eck, A., Signorino, C. S. (2018). An Introduction to Machine Learning Methods for Survey Researchers. *Survey Practice* *11*(1).

Domingos, P. (2012). A few useful things to know about machine learning. *Communications of the ACM* *55*(10), 78–87.

Hastie, T., Tibshirani, R., Friedman, J. (2009). *The Elements of Statistical Learning: Data Mining, Inference, and Prediction*. New York, NY: Springer.

James, G., Witten, D., Hastie, T., Tibshirani, R. (2013). *An Introduction to Statistical Learning*. New York, NY: Springer.
