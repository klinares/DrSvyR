---
id: "jpsm/stat_mod_ML_2_SURV616/lecture_notes"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "lecture_notes"
original: "stat_mod_ML_2_SURV616/lecture_notes.pdf"
pages: 6
sha256: "2c7c844433fcc12f581d21368ec1b8abc3e84eaf50f2948f2835cf7338264095"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:27"
---

<!-- page 1 -->

1/13/25 Into:

Tasks:
* comment on the readings or provide questions.
* Show complete calculations on HW assignments.
* Do not use functions unless asked to do so, hard code work instead.
  * Annotate comments throughout script
  * Do not round until the end
  * reporting rule, standard error 2 significant digits, for any statistic report SE, and report the statistic with matching digits.
  * Every assignment will have an honor pledge, signed and dated hand written scanned!
* Project expectations
  * active in review question, data, method, code writing, spokesperson.

Categorical data
* This class is about when normal distribution of errors is violated or the data is not-normal, by using non-parametric distributions.
* Distributions
  * Expected value is the average
  * $X \sim \text{Bern}(p)$, $x = [0, 1]$, the expected value is $E[X] = p$, and variance is $V(X) = p(1-p)$
  * $Y\_i \sim \text{Bin}(n, p\_i)$, $x=[0,\dots,n]$, , variance is $V(p\_\text{hat}) = p(1-p)/n$.
    * This is a variance of an estimate, it depends on $p$ and not $p\_\text{hat}$. We say here that later we use the variance of the $p\_\text{hat}$ estimate.
    * $p\_\text{hat}$ is following a normal distribution
  * multinomial, more than 2 outcomes are possible. Parameter $p\_\text{hat}$, $V(p\_\text{hat})$ computed at the diagonal of $p$ in a matrix and the elements are the covariances

$$
3 \quad V(\hat{\boldsymbol{p}}) = n^{-1}[\text{diag}(\boldsymbol{p}) - \boldsymbol{p}\boldsymbol{p}'], \, V(\hat{p}_i) = \frac{p_i(1 - p_i)}{n}, \, C(\hat{p}_i, \hat{p}_j) = \frac{-p_i p_j}{n}
$$

    * Characterize by the binomial distribution.
  * Poisson distribution, $\text{Pois}(\hat{\lambda})$
* Goodness of fit
  * Chi-square $\chi^2$ follows $(\theta\_\text{hat} - \theta\_0)^2 / \text{var}(\theta\_\text{hat})$, wald test.
    * Pearson $\chi^2$ sum of the (observed count in the ith category minus expected count) / expected counts.
  * $G^2$ it is also a ratio between the observed and expected.

<!-- page 2 -->

**1/27/25 2 way tables, odds ratios**

* Define an index in statistics in HW and project.
  * Think about the assumptions, and if they are met.
  * Ex. Fisher exact test, marginal are fixed N. used for small samples.
  * Understand log linear models.
  * Write down every notation step.

Slide team work
* Total of the second row, number of females in the study. $20 + 50 = 50$
* Total number of males who have the disease, $10/100 = .10$. Joint prob.
* Probability of disease conditional on female. Probability of female who have the disease. $20/50 = .40$

* expected column counts, $\text{pie\_i\_j} = \text{pie\_i} + \text{pie} + \text{j}$, pie becomes p for proportion, we need sample size, and marginal.
* Pearson chi-square, $\text{df} = (r - 1)(c - 1)$.

slide 14 team
* I is gender (2), j are age groups (5)
* notation
* look at chi-square solution excel
  * we assume no missing data.

* Odds ratio:
  * Based on conditional probability.
  * Relative risk ratio between the response category 1 and category 2.
  * Variance is estimated on the log scale. The formula on slide 23, already on the log scale.

* Understand different between retrospective and prospective sampling.

**February 24 2025 GLM**

* Key assumptions
  * mean model is correctly specified, $\text{x\_i}$ can be polynomial to allow for linearity in the beta.
  * Error terms independent, equal variance and constant, and normally distributed.
  * For homeostatic data we can use properties of multivariate normal to model correction.
* Extend classical linear regression when assumptions are violated?
  * Using link functions for outcomes that are members of the exponential family.]
    * normal, binary, count for $\text{Y\_i}$.
    * Basically it puts a model in a paramaterization that allows a linear model.
      * We are estimating betas, on a different scale.
* Requirements
  * distribution of outcomes in the exponential family

Exponential Family is any distribution that can be written in the following form:

$$f(y|\theta, \phi) = exp\left[\frac{y\theta - b(\theta)}{a(\phi)} + c(y, \phi)\right]$$

In this setup, $\theta$ is a location parameter and $\phi$ is the scale or dispersion parameter.

<!-- page 3 -->

* link function
  We saw this with logistic regression:

$$\eta = \beta_0 + \beta_1 x_{i1} + \dots + \beta_q x_{iq}$$

$$\log\left(\frac{\mu}{1 - \mu}\right) = \beta_0 + \beta_1 x_{i1} + \dots + \beta_q x_{iq}$$

  In this case, the link function is $\eta = g(\mu) = \log \frac{\mu}{1-\mu}$

| Family | Link | Variance Function |
| :---: | :---: | :---: |
| Normal | $\eta = \mu$ | $1$ |
| Poisson | $\eta = \log \mu$ | $\mu$ |
| Binomial | $\eta = \log(\mu/(1 - \mu))$ | $\mu(1 - \mu)$ |

* For binary data, the logit link function works.
  * How you convert the scale back, depends on the link function.
  * ex. Normal distribution uses the identity link function.
  * For poisson, the link function is log link function.

**April 7 2025 Survival Analysis**

* Hazard function m need to know.
* Slide 11, life table, at risk are how many people start out, deaths is cumulative and subtract at risk column.

<!-- page 4 -->

*[No text on this page]*

<!-- page 5 -->

## Life Table Notation

| Notation | Description |
| :--- | :--- |
| $x$ | time at beginning of interval |
| $O_x$ | number *at risk* at exact time $x$ |
| $n$ | length of interval |
| $_n d_x$ | number dying in interval $x$ to $x + n$ |
| $_n p_x$ | probability of surviving from time $x$ to time $x + n$ |
| $_n q_x$ | probability of dying during time $x$ to time $x + n$ |
| $_n P_x$ | probability of surviving during time $x$ to time $x + n$ (more than one interval) |

**April 21, 2025 PCA**

**THE DECISION TREE:**
**QUESTIONS AND ANSWERS LEADING TO APPROPRIATE STATISTICS OR STATISTICAL TECHNIQUES**

**STARTING POINT**

*How many variables does the problem involve?*

* **One Variable** $\rightarrow$ *go to page 4*
* **Two Variables** $\rightarrow$ *How do you want to treat the variables with respect to scale of measurement?*
  * **Both Interval** $\rightarrow$ *go to page 6*
  * **Both Ordinal** $\rightarrow$ *go to page 8*
  * **Both Nominal** $\rightarrow$ *go to page 9*
  * **One Interval, One Ordinal** $\rightarrow$ *go to page 11*
  * **One Interval, One Nominal** $\rightarrow$ *go to page 12*
  * **One Ordinal, One Nominal** $\rightarrow$ *go to page 15*
* **More Than Two Variables** $\rightarrow$ *go to page 16*

* Linear algebra
  * know the definition on slide 5 from 13 factor analysis slides.
* PCA, data reduction technique to help us understand the relationship in the data.
* Slide 16, understand the property of principal component, which if true will explain the largest total variance. PC is a combination or ordinal variables.
* We don’t need microlevel data, only covarainces/variance matrix.

<!-- page 6 -->

* In a 3 by 3 matrix, we can only have 3 PCs.

## Principal Components

$$\lambda_1 + \lambda_2 + \lambda_3 = \sum \text{Var}(Y_i)$$

The eigenvalues and eigenvectors are:

$$\begin{aligned}
\lambda_1 = 5.83 \quad \boldsymbol{e}_1' &= [0.383, -0.924, 0] \\
\lambda_2 = 2.00 \quad \boldsymbol{e}_2' &= [0, 0, 1] \\
\lambda_3 = 0.17 \quad \boldsymbol{e}_3' &= [0.924, 0.383, 0]
\end{aligned}$$

$$Y_1 = 0.383 X_1 - 0.924 X_2 + 0 X_3$$

* If summing up lambdas we get the total variance explaine of Y_i. The proportion of variance explain by the first PC is lambda 1 / sum of lamda, in this case .73
  * we should not use 1 PC, in this case because the third variable does not correlate, as a result we would end up putting this variable in the first PC if we only have one. We assume there are overlap between these variables, so if there is no correlation that is a problem.
