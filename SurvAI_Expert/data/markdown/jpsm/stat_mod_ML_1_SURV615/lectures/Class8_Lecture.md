---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class8_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class8_Lecture.pdf"
pages: 83
sha256: "98e133b33b7a7fa2b09c576ee38482bb5c7368923b211361aac9368b90fa3f30"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:18"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #8

John Kubale

October 22, 2024

<!-- page 2 -->

# Outline

* Review
* Prediction
* Inference
    * Causation
    * Hill's Viewpoints
    * DAGs
    * Confounders, mediators, colliders, and descendents

<!-- page 3 -->

# Review

<!-- page 4 -->

# Binary Predictor Variables

```r
Call:
lm(formula = wage ~ indus + info, data = wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.507 -25.362  -6.117  15.697 197.750 

Coefficients: (1 not defined because of singularities)
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  120.593      1.070  112.69   <2e-16 ***
indus        -17.272      1.492  -11.58   <2e-16 ***
info              NA         NA      NA       NA    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

<!-- page 5 -->

# Binary Predictor Variables

```r
> head(model.matrix(mod_j1))
       (Intercept) indus info
231655           1     1    0
86582            1     0    1
161300           1     1    0
155159           1     0    1
11443            1     0    1
376662           1     0    1
```

Both of our predictors are dummy/indicator variables derived from the `jobclass` variable.

They’re simply the inverse of each other. No additional information is provided by one that’s not already provided by the other. We’re trying to use 3 parameters to model only 2 groups. Matrix is not of full rank.

<!-- page 6 -->

# Identifiability

$$
\begin{aligned}
y_i &= \mu_1 d_{1i} + \mu_2 d_{2i} + \epsilon_i \\
&= (\mu_1 + \delta - \delta) d_{1i} + (\mu_2 + \delta - \delta) d_{2i} + \epsilon_i \\
&= -\delta(d_{1i} + d_{2i}) + (\mu_1 + \delta) d_{1i} + (\mu_2 + \delta) d_{2i} + \epsilon_i \\
&\equiv \beta_0 + \beta_1 d_{1i} + \beta_2 d_{2i} + \epsilon_i \text{ with } \epsilon_i \sim N(0, \sigma^2)
\end{aligned}
$$

$\rightarrow \beta_0, \beta_1, \beta_2$ not estimable; Why?

$$
\text{e.g.) }
\begin{pmatrix}
y_1 \\
y_2 \\
y_3 \\
y_4 \\
y_5 \\
y_6 \\
y_7 \\
y_8 \\
y_9 \\
y_{10}
\end{pmatrix}
=
\begin{pmatrix}
1 & 1 & 0 \\
1 & 1 & 0 \\
1 & 1 & 0 \\
1 & 1 & 0 \\
1 & 1 & 0 \\
1 & 1 & 0 \\
1 & 0 & 1 \\
1 & 0 & 1 \\
1 & 0 & 1 \\
1 & 0 & 1
\end{pmatrix}
\begin{pmatrix}
\beta_0 \\
\beta_1 \\
\beta_2
\end{pmatrix}
+
\begin{pmatrix}
\epsilon_1 \\
\epsilon_2 \\
\epsilon_3 \\
\epsilon_4 \\
\epsilon_5 \\
\epsilon_6 \\
\epsilon_7 \\
\epsilon_8 \\
\epsilon_9 \\
\epsilon_{10}
\end{pmatrix}
$$

<!-- page 7 -->

# Identifiability

To put it another way, a model is said to be *nonidentifiable* if it contains parameters that cannot be estimated uniquely—or, to put it another way, that have standard errors of infinity. The offending parameters are called *nonidentified*. The most familiar and important example of nonidentifiability arises from *collinearity* (also called multicollinearity) of regression predictors. A set of predictors is collinear if there is a linear combination of them that equals 0 for all the data. We discuss this problem in the context of indicator variables at the end of Section 12.5.

A simple example of collinearity is a model predicting family outcomes given the number of boys in the family, the number of girls, and the total number of children. Labeling these predictors as $x_{2i}$, $x_{3i}$, and $x_{4i}$, respectively, for family $i$ (with $x_{1i} = 1$ being reserved for the constant term in the regression), we have $x_{4i} = x_{2i} + x_{3i}$, thus $-x_{2i} - x_{3i} + x_{4i} = 0$ and the set of predictors is collinear.

There can also be problems with *near*-collinearity, which leads to poor identification. For example, suppose you try to predict people's heights from the lengths of their left and right feet. These two predictors are nearly (but not exactly) collinear, and as a result it will be difficult to untangle the two coefficients, and we can characterize the fitted regression as unstable, in the sense that if it were re-fitted with new data, a new sample from the same population, we could see much different results. This instability should be reflected in large standard errors for the estimated coefficients.

Gelman, Hill, and Vehtari, ROS, 2022

<!-- page 8 -->

# Parameters and data

In the following linear regression model what are our parameters (i.e., what are we estimating)?

- $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$

<!-- page 9 -->

# Parameters and data

In the following linear regression model what are our parameters (i.e., what are we estimating)?

* $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$
    * $\beta_0, \beta_1, \beta_2$

<!-- page 10 -->

# Parameters and data

In the following linear regression model what are our parameters (i.e., what are we estimating)?

* $Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \epsilon_i$
  * $\beta_0, \beta_1, \beta_2$

**<u>These parameters are what our hypothesis tests are concerned with, not $X_1$ or $X_2$ as those are our observed data.</u>**

<!-- page 11 -->

# Interaction terms

* Interaction terms allow us to vary the slope of an association between a predictor and the outcome based on the value of another predictor(s).
* Interaction terms should nearly always be accompanied in the model by its component main effects.

<!-- page 12 -->

# Interaction terms

* Interaction terms allow us to vary the slope of an association between a predictor and the outcome based on the value of another predictor(s).
* Interaction terms should nearly always be accompanied in the model by its component main effects.
  * $Y = \beta_0 + \underbrace{\beta_1 X_1 + \beta_2 X_2}_{\text{Main effects}} + \beta_3(X_1 * X_2) + \epsilon$

<!-- page 13 -->

# Inference vs. Prediction

* **Population: Parameter**
  (e.g., $\mu$: average income ($y$); $\beta$: effect of education ($x$) on income ($y$), $y_i = \beta x_i + \epsilon_i$ from $y_i$ and $x_i$, $i = 1, ..., N$ )

* **Sample: Statistic**
  (e.g., $\hat{\mu}$ ; $\hat{\beta}$ from $y_i$ and $x_i$, $i = 1, ..., n$ )
  * $\rightarrow$ **Inference** $\rightarrow$ Population: Parameter
  * $\rightarrow$ **Prediction** $\rightarrow$ Hypothetical Scenario

* **Hypothetical Scenario**
  (e.g., $\hat{y}_0$: income of an individual $0$ with $x_0$)

<!-- page 14 -->

# Inference vs. Prediction

Population: Parameter
(e.g., $\mu$: average income ($y$);
$\beta$: effect of education ($x$) on
income ($y$), $y_i = \beta x_i + \epsilon_i$
from $y_i$ and $x_i$, $i = 1, ..., N$ )

**Inference**

Sample: Statistic
(e.g., $\hat{\mu}$ ; $\hat{\beta}$
from $y_i$ and $x_i$,
$i = 1, ..., n$ )

**Prediction**

Hypothetical Scenario
(e.g., $\hat{y}_0$: income of an
individual $0$ with $x_0$)

<!-- page 15 -->

# Prediction

<!-- page 16 -->

# Prediction example

* Let's make some data
* We'll use these to fit 5 simple linear regression models with different sample size (n), estimate/predict $\beta_1$, and calculate its 95% confidence and prediction intervals.
* What do you think will happen to each interval as sample size increases?

```r
set.seed(894894)
n = 1000

df <- tibble(
  id = 1:n,
  x = rnorm(1000, 3.5, 1.75)
)

df_subsets = tibble(
  n = c(5,20,80,160,1000),
  data = map(k, ~ filter(df, id <= .x))
) %>%
  unnest(data)

e <- rnorm(1265, 0, 1)
df_subsets$y <- 1.5 + 2*df_subsets$x + e
```

<!-- page 17 -->

# Prediction example

<!-- page 18 -->

# Prediction example

Why is the prediction interval so much larger even when sample size increases?

<!-- page 19 -->

# Estimation of Mean/Expected Response

Best estimate of $Y$ for a given $X$

From $\hat{Y}_* \sim N(\beta_0 + \beta_1 X_*, \sigma^2 (n^{-1} + S_{XX}^{-1} (X_* - \bar{X})^2))$

Inference for $Y_*$ estimation is the same as any normal distribution random variables:

$(1 - \alpha)\%$ CI of $Y_*$ estimation: $\hat{Y}_* \pm t_{(n-2), \alpha/2} SE(\hat{Y}_*)$

Where $SE(\hat{Y}_*) = \sqrt{\sigma^2 (n^{-1} + S_{XX}^{-1} (X_* - \bar{X})^2)}$

<!-- page 20 -->

# Prediction of Response

Prediction of $Y$ for a given $X$

From $(Y_* - \hat{Y}_*) \sim \text{N}(0, \sigma^2(1 + n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2))$

Inferences for $Y_*$ prediction involves error variance, unlike the inferences for $Y_*$ estimation:

$(1 - \alpha)\%$ CI of $Y_*$ prediction: $\hat{Y}_* \pm t_{(n-2), \alpha/2} SE(Y_* - \hat{Y}_*)$

where $SE(Y_* - \hat{Y}_*) = \sqrt{\sigma^2(1 + n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

<!-- page 21 -->

# Estimation vs. Prediction of Response

* Best estimate of $Y_*$ for a given $X$

  $(1 - \alpha)\%$ CI of $Y_*$:

  $$\hat{Y}_* \pm t_{(n-2),\alpha/2}SE(\hat{Y}_*),$$

  where $SE(\hat{Y}_*) = \sqrt{\sigma^2(n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

* Prediction of $Y_*$ for a given $X$

  $(1 - \alpha)\%$ CI (or Prediction Interval)of $Y_*$:

  $$\hat{Y}_* \pm t_{(n-2),\alpha/2}SE(Y_* - \hat{Y}_*),$$

  Where $SE(Y_* - \hat{Y}_*) = \sqrt{\sigma^2(1 + n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

* Prediction intervals are wider or narrower than confidence intervals? Why?

<!-- page 22 -->

# Estimation vs. Prediction of Response

* Best estimate of $Y_*$ for a given $X$

  $(1 - \alpha)\%$ CI of $Y_*$:

  $$\hat{Y}_* \pm t_{(n-2),\alpha/2}SE(\hat{Y}_*),$$

  where $SE(\hat{Y}_*) = \sqrt{\sigma^2(n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

* Prediction of $Y_*$ for a given $X$

  $(1 - \alpha)\%$ CI (or Prediction Interval)of $Y_*$:

  $$\hat{Y}_* \pm t_{(n-2),\alpha/2}SE(Y_* - \hat{Y}_*),$$

  Where $SE(Y_* - \hat{Y}_*) = \sqrt{\sigma^2(1 + n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

* Prediction intervals are wider or narrower than confidence intervals? Why?

Formula for the confidence interval and the prediction interval follow same pattern general formula:
Sample estimate $\pm$ ($t$-multiplier $\times$ standard error)

<!-- page 23 -->

# Estimation vs. Prediction of Response

* Best estimate of $Y_*$ for a given $X$

  $(1 - \alpha)\%$ CI of $Y_*$:

  $$\hat{Y}_* \pm t_{(n-2), \alpha/2} SE(\hat{Y}_*),$$

  where $SE(\hat{Y}_*) = \sqrt{\sigma^2(n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

  Difference is in their standard errors as the prediction interval has to account for both error in the estimate of the model (i.e., f(x)) and the uncertainty regarding how much an individual point differs from the regression plane

* Prediction of $Y_*$ for a given $X$

  $(1 - \alpha)\%$ CI (or Prediction Interval) of $Y_*$:

  $$\hat{Y}_* \pm t_{(n-2), \alpha/2} SE(Y_* - \hat{Y}_*),$$

  Where $SE(Y_* - \hat{Y}_*) = \sqrt{\sigma^2(1 + n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

* Prediction intervals are wider or narrower than confidence intervals? Why?

<!-- page 24 -->

# Estimation vs. Prediction of Response

* Best estimate of $Y_*$ for a given $X$

With confidence intervals we're assessing variability/uncertainty around the mean of an estimated quantity $x$. which as a summary measure itself, has already reduced the variability in $x$ in becoming $\bar{x}$. With prediction intervals we're looking at a single new observation rather than the average, so we have to take the variability of $x$ into account, not just the variability of our estimate of its mean.

Where $SE(Y_* - \hat{Y}_*) = \sqrt{\sigma^2(1 + n^{-1} + S_{XX}^{-1}(X_* - \bar{X})^2)}$

* Prediction intervals are wider or narrower than confidence intervals? Why?

<!-- page 25 -->

# Interpreting different intervals

* Confidence interval: A range of values for the estimated mean response. If we were to take repeated samples we would expect the 95% CIs of the samples to contain the true mean 95% of the time
  * "We are 95% confident the true population value falls within the interval."
* Prediction interval: A range of values that is likely to contain a single new observation given a specified subset of predictor values.
  * "We are 95% confident that the next observation with these predictor values will fall in this interval."

<!-- page 26 -->

# How best to predict?

* **<u>GOOD MODEL</u>**
* Parsimony; Overfitting; Collinearity; Assumptions
* Now consider Wage data:
* Are the predictor values realistic? (e.g., age=190?)
* Are populations comparable?
  * Does the model, `wage ~ year + jobclass + race`, work for northwest region?
  * How about `wage ~ year + jobclass + race`, for 2010?
  * How about for `wage ~ factor(year) + jobclass + race`, for 2010?
* Extreme values and error distribution

<!-- page 27 -->

# Inference

<!-- page 28 -->

# Simple vs. Multiple Regression

$$Y = \beta_0 + \beta_1 X_1 + \epsilon$$

Vs.

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

* How does $\beta_1$ differ in simple vs. multiple regression?

<!-- page 29 -->

# Simple vs. Multiple Regression

$$Y = \beta_0 + \beta_1 X_1 + \epsilon$$

Vs.

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

* How does $\beta_1$ differ in simple vs. multiple regression?
* What do we mean when we say “controlling for x” or “holding x constant”?
* Why do we do this?

<!-- page 30 -->

# Prediction vs. Inference

**“Prediction is not simple, but it is conceptually easier than explanation.”**
(Faraway, p. 59)

* Inference
  * Description
  * Explanation: Causation

<!-- page 31 -->

# Causation

<!-- page 32 -->

# Causation?

McElreath, 2023

<!-- page 33 -->

# Causation?

## Does Waffle House cause divorce?

McElreath, 2023

<!-- page 34 -->

# Correlation is common

## Milk consumption
correlates with
## Burglary rates in the US

- Per capita consumption of Fluid beverage milk in the US $\cdot$ Source: USDA
- The burglary rate per 100,000 residents in United States $\cdot$ Source: FBI Criminal Justice Information Services

1990-2021, $r=0.968$, $r^2=0.936$, $p<0.01$ $\cdot$ tylervigen.com/spurious/correlation/1036

<!-- page 35 -->

# Correlation is common

### **AI explanation**

As people stopped crying over spilled milk, they had more time to focus on home security, udderly baffling the burglars. Without moo-ving targets, the thieves were simply milking the clock elsewhere. It seems that dairy deprivation led to a downturn in dairy-ly deeds!

<!-- page 36 -->

# What do we mean by causation

* “An antecedent event, condition or characteristic that was necessary for the occurrence of the disease at the moment it occurred, given that other characteristics are fixed.” (Rothman, 2008)

* “We may define a cause to be an object, followed by another...where, if the first object had not been, the second never had existed” (Hume, An Enquiry Concerning Human Understanding, 1748)

<!-- page 37 -->

# How do we assess causation?

* The ideal or “gold-standard” would be to conduct a randomized experiment
* Participants are screened for inclusion and then randomly assigned to receive or not receive the treatment/exposure
* They are then observed to see if they develop the outcome of interest

<!-- page 38 -->

# How do we assess causation?

* The primary goal of randomization is to ensure that the 2 groups (i.e., exposed/unexposed, treated/untreated) are “exchangeable”
* Exchangeable means that if those assigned to the unexposed group were instead assigned to the exposed group, we would expect them to have a very similar response as the actual exposed group
* Put another way, any differences between the 2 groups in their response to the exposure/treatment should only be due to random error

<!-- page 39 -->

# Types of Experiments

* Types of Experiments
  * Randomized experiments: An experiment in which units are assigned to receive the treatment by a random process
  * Quasi-experiments: An experiment without random treatment assignment
  * Natural experiments: Not really an experiment; the cause cannot be manipulated; a study that contrasts a naturally occurring event (e.g., natural disaster) with a comparison population
* Why is randomization beneficial?
* Why not always use randomization?

<!-- page 40 -->

# Why don’t we only use random experiments?

* Not possible: Some things can’t be randomized (e.g., genetics)
* Not ethical: Can’t purposely expose people to something harmful
* Expensive
* Challenging with rare outcomes

<!-- page 41 -->

# Observational studies

* Cohort studies
* Case-control studies
* Cross-sectional studies
* Ecological studies
* Among others...

<!-- page 42 -->

# Causal inference with observational data

* How do we try to ensure that our models are not simply capturing spurious correlations?

Does Waffle House cause divorce?

<!-- page 43 -->

# Hill's Viewpoints

<!-- page 44 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

Proposed in 1965 by English statistician Sir Austin Bradford Hill, Hill's viewpoints represent an early effort to formalize how we approach establishing whether an observed relationship is causal.

Not all have held up to scrutiny in all situations.

<!-- page 45 -->

# Hill’s Viewpoints

1. Strength of association $\longleftarrow$ A weak association doesn’t mean that a relationship is not causal, but a strong relationship is more likely to be causal.
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

Doll and Hill’s study on cigarette smoking and lung cancer.

<!-- page 46 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

An association is repeatedly observed in different populations and under different circumstances.

Subject to publication bias (i.e., non-null results more likely to be published). Can also be impacted by confounding or other biases.

<!-- page 47 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity $\longleftarrow$ Cause leads to a single effect, not multiple.
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

<!-- page 48 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity **\*\*This point is invalid\*\*** effect, not
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

<!-- page 49 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality $\longleftarrow$ Exposure must precede outcome.
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

<!-- page 50 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

A monotonic relationship between level of exposure and outcome is considered evidence of causality.

<!-- page 51 -->

# Hill’s Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

Not always the case, however, as many other shapes possible.

Disease risk

Exposure level
a. Monotonic throughout range of exposure levels (e.g., smoking and lung cancer)

Exposure level
b. J-shaped (e.g., alcohol and cardiovascular disease)

Exposure level
c. Threshold pattern (e.g., weight and coronary disease sudden death)

<!-- page 52 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility $\longleftarrow$ Must be consistent with our understanding of biology
7. Coherence
8. Experimental evidence
9. Analogy

<!-- page 53 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporali
5. Biological
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

Our understanding of biology and other sciences is constantly growing. A relationship may not be consistent with our current understanding, but can still be accurate.

<!-- page 54 -->

# Hill’s Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence $\longleftarrow$ “...the cause-and-effect story should make sense with all knowledge available to the researcher...” Fedak et al., 2015
8. Experimental evidence
9. Analogy

<!-- page 55 -->

# Hill’s Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological grad
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy

Cannot rule out causal relationship as it relies on the knowledge currently available which might not be sufficient.

ry
knowledge available to the researcher...” Fedak et al., 2015

<!-- page 56 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence $\longleftarrow$ Presence of experimental evidence extremely helpful.
9. Analogy

<!-- page 57 -->

# Hill's Viewpoints

1. Strength of association
2. Consistency
3. Specificity
4. Temporality
5. Biological gradient
6. Plausibility
7. Coherence
8. Experimental evidence
9. Analogy $\longleftarrow$ The effect of similar factors may be considered.

<!-- page 58 -->

# DAGs

<!-- page 59 -->

# Directed Acyclic Graphs (DAGs)

* DAGs are another tool that is commonly used by researchers to conceptualize the relationship being modeled
* The presence of an arrow indicates the possibility/assumption of a relationship, not that it absolutely exists
  * This assumption should be based on prior evidence!

Time flows north to south

Transit strike $\longrightarrow$ Bike to work $\longrightarrow$ Bike crash

Transit strike $\xrightarrow{?}$ Bike crash

Time flows left to right

Bustos Carillo, 2019

<!-- page 60 -->

# What can DAGs tell us?

## *Ye Olde Causal Alchemy*
### The Four Elemental Confounds

| | |
| :---: | :---: |
| ***The Fork***<br>$$X \leftarrow Z \rightarrow Y$$ | ***The Pipe***<br>$$X \rightarrow Z \rightarrow Y$$ |
| ***The Collider***<br>$$X \rightarrow Z \leftarrow Y$$ | ***The Descendant***<br>$$\begin{array}{c} X \rightarrow Z \rightarrow Y \\ \downarrow \\ A \end{array}$$ |

McElreath, 2023

<!-- page 61 -->

# Confounders, mediators, colliders, and descendents

<!-- page 62 -->

# The Fork (AKA confounding)

* Suppose we were interested in whether carrying matches placed you at greater risk of lung cancer.

$$
\text{Carrying lighter} \xrightarrow{\quad ? \quad} \text{Lung cancer}
$$

<!-- page 63 -->

# The Fork (AKA confounding)

* Suppose we were interested in whether carrying matches placed you at greater risk of lung cancer.
* What might be missing from this DAG?

$$\text{Carrying lighter} \xrightarrow{\quad ? \quad} \text{Lung cancer}$$

<!-- page 64 -->

# The Fork (AKA confounding)

* Suppose we were interested in whether carrying matches placed you at greater risk of lung cancer.
* Cigarette smoking is a confounder of the “relationship” between carrying a lighter and lung cancer

Smokes cigarettes

?

Carrying lighter

Lung cancer

<!-- page 65 -->

# What to do?

- Multiple regression
  - Can control for potential confounders

Smokes cigarettes

Carrying lighter

Lung cancer

<!-- page 66 -->

# Addressing confounding example

* Why do regions of the US with higher rates of marriage also have higher rates of divorce?
* We will use the “WaffleDivorce.csv” dataset (posted on Canvas) to explore the divorce rate as a function of the marriage rate.
  * Note this file used “;” as a delimiter so you need to use the following code to import to R:
    ```r
    read.csv2("C:/Users/jkubale
    /Downloads/WaffleDivorce.cs
    v", sep=";")
    ```

McElreath, 2023

<!-- page 67 -->

# Addressing confounding example

* Let's fit a model (starting simple):

```r
mod1 <- lm(Divorce ~ as.numeric(Marriage), waffle)
```

```r
> summary(mod1)

Call:
lm(formula = Divorce ~ as.numeric(Marriage), data = waffle)

Residuals:
    Min      1Q  Median      3Q     Max 
-3.0068 -1.2173  0.1214  1.1805  4.4971 

Coefficients:
                     Estimate Std. Error t value Pr(>|t|)    
(Intercept)           6.08404    1.31337   4.632 2.78e-05 ***
as.numeric(Marriage)  0.17918    0.06418   2.792  0.00751 ** 
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.706 on 48 degrees of freedom
Multiple R-squared:  0.1397,	Adjusted R-squared:  0.1218 
F-statistic: 7.793 on 1 and 48 DF,  p-value: 0.007507

> 
```

<!-- page 68 -->

# Addressing confounding example

* Let's fit a model (starting simple):

```r
mod1 <- lm(Divorce ~ as.numeric(Marriage), waffle)
```

Suggests that with higher marriage rates we would expect higher rates of divorce.

But is that the whole story?

```r
> summary(mod1)

Call:
lm(formula = Divorce ~ as.numeric(Marriage), data = waffle)

Residuals:
    Min      1Q  Median      3Q     Max 
-3.0068 -1.2173  0.1214  1.1805  4.4971 

Coefficients:
                     Estimate Std. Error t value Pr(>|t|)    
(Intercept)           6.08404    1.31337   4.632 2.78e-05 ***
as.numeric(Marriage)  0.17918    0.06418   2.792  0.00751 ** 
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.706 on 48 degrees of freedom
Multiple R-squared:  0.1397,	Adjusted R-squared:  0.1218 
F-statistic: 7.793 on 1 and 48 DF,  p-value: 0.007507

> 
```

<!-- page 69 -->

# Addressing confounding example

* Let’s fit a model (starting simple):

```r
mod1 <- lm(Divorce ~ as.numeric(Marriage), waffle)
```

Might the age at which people tend to get married impact their likelihood of divorce?

Suggests that wi higher marriage rates we would expect higher rates of divorce.

But is that the whole story?

```r
Residuals:
    Min      1Q  Median      3Q     Max 
-3.0068 -1.2173  0.1214  1.1805  4.4971 

Coefficients:
                     Estimate Std. Error t value Pr(>|t|)    
(Intercept)           6.08404    1.31337   4.632 2.78e-05 ***
as.numeric(Marriage)  0.17918    0.06418   2.792  0.00751 ** 
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.706 on 48 degrees of freedom
Multiple R-squared:  0.1397,	Adjusted R-squared:  0.1218 
F-statistic: 7.793 on 1 and 48 DF,  p-value: 0.007507

> 
```

<!-- page 70 -->

# Addressing confounding example

* Let’s fit another model this time with both Marriage and MedianAgeMarriage as predictors

```r
mod2 <- lm(Divorce ~ as.numeric(Marriage)
as.numeric(MedianAgeMarriage), waffle)
```

```r
> summary(mod2)

Call:
lm(formula = Divorce ~ as.numeric(Marriage) + as.numeric(MedianAgeMarriage), 
    data = waffle)

Residuals:
    Min      1Q  Median      3Q     Max 
-4.5177 -0.9828 -0.0458  0.9224  3.2818 

Coefficients:
                              Estimate Std. Error t value Pr(>|t|)    
(Intercept)                    36.87665    7.66104   4.814 1.58e-05 ***
as.numeric(Marriage)           -0.05686    0.08053  -0.706 0.483594    
as.numeric(MedianAgeMarriage)  -0.99965    0.24593  -4.065 0.000182 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.483 on 47 degrees of freedom
Multiple R-squared:  0.3634,	Adjusted R-squared:  0.3364 
F-statistic: 13.42 on 2 and 47 DF,  p-value: 2.455e-05

> 
```

<!-- page 71 -->

# Addressing confounding example

* Let's fit another model this time with both Marriage and MedianAgeMarriage as predictors

```r
mod2 <- lm(Divorce ~ as.numeric(Marriage)
as.numeric(MedianAgeMarriage), waffle)
```

As median age at marriage increases the divorce rate decreases.

What happened to the coefficient for `Marriage`?

```r
> summary(mod2)

Call:
lm(formula = Divorce ~ as.numeric(Marriage) + as.numeric(MedianAgeMarriage), 
    data = waffle)

Residuals:
    Min      1Q  Median      3Q     Max 
-4.5177 -0.9828 -0.0458  0.9224  3.2818 

Coefficients:
                              Estimate Std. Error t value Pr(>|t|)    
(Intercept)                    36.87665    7.66104   4.814 1.58e-05 ***
as.numeric(Marriage)           -0.05686    0.08053  -0.706 0.483594    
as.numeric(MedianAgeMarriage)  -0.99965    0.24593  -4.065 0.000182 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.483 on 47 degrees of freedom
Multiple R-squared:  0.3634,	Adjusted R-squared:  0.3364 
F-statistic: 13.42 on 2 and 47 DF,  p-value: 2.455e-05

> 
```

<!-- page 72 -->

# Times we don’t want to include covariates

<!-- page 73 -->

# When we don't want to include covariates

## *Ye Olde Causal Alchemy*
### The Four Elemental Confounds

| | |
| :---: | :---: |
| *The Fork*<br>$$X \leftarrow Z \rightarrow Y$$ | *The Pipe*<br>$$X \rightarrow Z \rightarrow Y$$ |
| *The Collider*<br>$$X \rightarrow Z \leftarrow Y$$ | *The Descendant*<br>$$\begin{array}{ccccc} X & \rightarrow & Z & \rightarrow & Y \\ & & \downarrow & & \\ & & A & & \end{array}$$ |

McElreath, 2023

<!-- page 74 -->

# When we don’t want to include covariates

## *Ye Olde Causal Alchemy*
### The Four Elemental Confounds

Some exceptions with the pipe (i.e., interested in direct vs. total effect) though even these cases can be problematic.

*The Collider*

$$
X \rightarrow Z \leftarrow Y
$$

*The Descendant*

$$
\begin{array}{ccccc}
X & \rightarrow & Z & \rightarrow & Y \\
& & \downarrow & & \\
& & A & &
\end{array}
$$

McElreath, 2023

<!-- page 75 -->

# The Pipe (AKA mediation)

## *The Pipe*

$$X \rightarrow Z \rightarrow Y$$

$Z$ is a "mediator"

$X$ and $Y$ are associated

$$Y \not\perp\!\!\!\perp X$$

Influence of $X$ on $Y$ transmitted through $Z$

Once stratified by $Z$, no association

$$Y \perp\!\!\!\perp X \mid Z$$

McElreath, 2023

<!-- page 76 -->

# The Pipe (AKA mediation)

$$X \rightarrow Z \rightarrow Y$$

```r
n <- 1000
X <- rbern( n , 0.5)
Z <- rbern( n , (1-X)*0.1 + X*0.9 )
Y <- rbern( n , (1-Z)*0.1 + Z*0.9 )
```

```r
     Y
X     0   1
  0 430  87
  1  93 390
```

$$Y \not\perp\!\!\!\perp X$$

```r
> cor(X,Y)
[1] 0.64
```

McElreath, 2023

<!-- page 77 -->

# The Pipe (AKA mediation)

$$X \rightarrow Z \rightarrow Y$$

```r
n <- 1000
X <- rbern( n , 0.5)
Z <- rbern( n , (1-X)*0.1 + X*0.9 )
Y <- rbern( n , (1-Z)*0.1 + Z*0.9 )
```

```r
     Y
X      0   1
  0  430  87
  1   93 390
```

$$Y \not\perp\!\!\!\perp X$$

```r
> cor(X,Y)
[1] 0.64
```

```r
Z = 0
     Y
X      0   1
  0  422  39
  1   53   5

Z = 1
     Y
X      0   1
  0    8  48
  1   40 385
```

$$Y \perp\!\!\!\perp X \mid Z$$

```r
> cor(X[Z==0],Y[Z==0])
[1] 0.002
> cor(X[Z==1],Y[Z==1])
[1] 0.052
```

McElreath, 2023

<!-- page 78 -->

# The Pipe (AKA mediation)

$$X \rightarrow Z \rightarrow Y$$

```r
cols <- c(4,2)

N <- 300
X <- rnorm(N)
Z <- rbern(N,inv_logit(X))
Y <- rnorm(N,(2*Z-1))

plot( X , Y , col=cols[Z+1] , lwd=3 )

abline(lm(Y[Z==1]~X[Z==1]),col=2,lwd=3)

abline(lm(Y[Z==0]~X[Z==0]),col=4,lwd=3)

abline(lm(Y~X),lwd=3)
```

$Z = 0$ $Z = 1$

McElreath, 2023

<!-- page 79 -->

# The Collider

## *The Collider*

$$X \rightarrow Z \leftarrow Y$$

$Z$ is a "collider"

$X$ and $Y$ are not associated (share no causes) $\quad Y \perp\!\!\!\perp X$

$X$ and $Y$ both influence $Z$

Once stratified by $Z$, $X$ and $Y$ associated $\quad Y \not\!\perp\!\!\!\perp X \mid Z$

McElreath, 2023

<!-- page 80 -->

# The Collider

$$
X \rightarrow Z \leftarrow Y
$$

```r
n <- 1000
X <- rbern( n , 0.5 )
Y <- rbern( n , 0.5 )
Z <- rbern( n , ifelse(X+Y>0,0.9,0.2) )
```

```r
        Y
  X     0   1
    0 243 236
    1 250 271
```

$$
Y \perp\!\!\!\perp X
$$

```r
> cor(X,Y)
[1] 0.027
```

McElreath, 2023

<!-- page 81 -->

# The Collider

$$
X \rightarrow Z \leftarrow Y
$$

```r
n <- 1000
X <- rbern( n , 0.5 )
Y <- rbern( n , 0.5 )
Z <- rbern( n , ifelse(X+Y>0,0.9,0.2) )
```

```r
     Y
X      0   1
  0  243 236
  1  250 271
```

$$
Y \perp\!\!\!\perp X
$$

```r
> cor(X,Y)
[1] 0.027
```

```r
Z = 0
     Y
X      0   1
  0  200  19
  1   32  29

Z = 1
     Y
X      0   1
  0   43 217
  1  218 242
```

$$
Y \not\!\perp\!\!\!\perp X \mid Z
$$

```r
> cor(X[Z==0],Y[Z==0])
[1] 0.43
> cor(X[Z==1],Y[Z==1])
[1] -0.31
```

McElreath, 2023

<!-- page 82 -->

# The Collider

$$
X \rightarrow Z \leftarrow Y
$$

$Z = 0$ $\quad$ $Z = 1$

```r
cols <- c(4,2)

N <- 300
X <- rnorm(N)
Y <- rnorm(N)
Z <- rbern(N,inv_logit(2*X+2*Y-2))

plot( X , Y , col=cols[Z+1] , lwd=3 )

abline(lm(Y[Z==1]~X[Z==1]),col=2,lwd=3)

abline(lm(Y[Z==0]~X[Z==0]),col=4,lwd=3)

abline(lm(Y~X),lwd=3)
```

McElreath, 2023

<!-- page 83 -->

# The Descendent

*The Descendant*

$$
\begin{array}{ccccc}
X & \rightarrow & Z & \rightarrow & Y \\
& & \downarrow & & \\
& & A & &
\end{array}
$$

$A$ is a “descendant”

- Depends on what it descends from.
  - E.g., If it descends from a mediator, controlling for it in the model will result in similar behavior as if you included the mediator itself.

McElreath, 2023
