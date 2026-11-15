---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module2_Lecture1_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "Applications of Statistical Modeling:"
original: "applications_stats_modeling_SURV617/lectures/Module2_Lecture1_Fall2025.pdf"
pages: 39
sha256: "c9282cd31a718a4979f12fa2f82d539d48ff769bf7f903bafdb170d4a7303493"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:40"
---

<!-- page 1 -->

# Applications of Statistical Modeling:
## Module #2, Lecture #1

## Structural Equation Modeling:
## An Overview

Instructor: Brady T. West

Email: [[email]](mailto:[email])

1

<!-- page 2 -->

# What is a Structural Equation Model (SEM)?

* A statistical model used in many disciplines (especially the social sciences) to test hypotheses about causal relationships between many variables
* The models can include **observed variables** in a survey data set, in addition to **latent variables** that were not directly observed but rather *indicated* by other observed variables

2

<!-- page 3 -->

# What is a Structural Equation Model (SEM)?

* Full SEMs generally include two components:
  * A **measurement model**, where latent variables are indicated by multiple observed variables, and
  * A **structural model**, which describes the relationships between both latent and observed variables of interest
* There are many types of models that fit into the general SEM framework!

3

<!-- page 4 -->

# What is a Structural Equation Model (SEM)?

* Common examples of SEMs:
  - **<u>Path Models</u>**: specify causal relationships between observed variables (e.g., mediation models)
  - **<u>Confirmatory Factor Analysis (CFA) Models</u>**: The measurement portion(s) of an SEM
  - **<u>Multilevel Models</u>**: random coefficients are the latent variables (in a longitudinal framework)
  - **<u>Latent Class Models</u>**: Group cases into latent classes based on multiple indicator variables
  - **Many others!**

4

<!-- page 5 -->

# What do SEM equations look like?

* Consider this SEM (Wheaton et al. 1977):

5

<!-- page 6 -->

# The General SEM Model

* In general, an SEM model is written as follows:

Latent variable (structural) equation:

$$\eta = \alpha + B\eta + \Gamma\xi + \zeta$$

> A given vector of endogenous LVs is a parametric function of other LVs, plus errors

Measurement equations:

$$x = \nu_x + \Lambda_x\xi + \delta$$

$$y = \nu_y + \Lambda_y\eta_1 + \varepsilon$$

$$z = \nu_z + \Lambda_z\eta_2 + \gamma$$

> Vectors of observed variables are parametric functions of intercepts, the LVs, and errors

6

<!-- page 7 -->

# Back to the Example Model

- In our example two slides back, we have:

Structural Model:

$$Alien67 = \alpha_1 + \gamma_{11}SES66 + \varepsilon_3$$

$$Alien71 = \alpha_2 + \gamma_{21}SES66 + \gamma_{22}Alien67 + \varepsilon_6$$

Measurement Model:

$$educ66 = \nu_1 + \lambda_{11}SES66 + \varepsilon_1$$

$$occstat66 = \nu_2 + \lambda_{21}SES66 + \varepsilon_2$$

$$anomia67 = \nu_3 + \lambda_{31}Alien67 + \varepsilon_4$$

$$pwless67 = \nu_4 + \lambda_{41}Alien67 + \varepsilon_5$$

$$anomia71 = \nu_5 + \lambda_{51}Alien71 + \varepsilon_7$$

$$pwless71 = \nu_6 + \lambda_{61}Alien71 + \varepsilon_8$$

7

<!-- page 8 -->

# What is a Structural Equation Model (SEM)?

* SEMs use observed covariances (or correlations) in a data set to estimate the parameters of a hypothesized model
* SEMs should **not** be used for exploratory data analysis; **<u>always start with a theory</u>**!
* SEMs enable examinations of the **plausibility** of hypothesized models
* If a model fits well (i.e., the implied correlations match the observed correlations), it is **plausible**, but there may well be equivalent or better models

8

<!-- page 9 -->

# Terminology

* **Measured variables:** Those variables that are directly observed in the data set
* **Latent / factor variables:** Unobserved variables that are indicated by other variables in the data set (e.g., mathematics ability)
* **Endogenous variables:** Variables predicted by other variables (like dependent variables)
* **Exogenous variables:** Variables that only predict other variables

9

<!-- page 10 -->

# Conventions for Drawing SEMs

* **Squares or boxes:** observed variables available in the data set
* **Circles or ovals: <u>latent</u>** variables that might be indicated by other observed variables
* **Straight arrows:** indicate direct causal relationships where one variable predicts another
* **Two-sided curved arrows:** indicate covariances, generally between latent variables
* Predicted variables usually also have circles with straight arrows pointing to them, or **errors**

10

<!-- page 11 -->

# Conventions for Drawing SEMs

Structural Model

Measurement Model

F1
F2
F3
F4

$\varepsilon_1$
$\varepsilon_2$
$\varepsilon_3$
$\varepsilon_4$
$\varepsilon_5$
$\varepsilon_6$
$\varepsilon_7$
$\varepsilon_8$
$\varepsilon_9$
$\varepsilon_{10}$
$\varepsilon_{11}$
$\varepsilon_{12}$

11

<!-- page 12 -->

# Estimation of SEMs

* **Input information:** sample covariances (or correlations) between observed variables
* Sample means are also used if there are missing data in the data set
* The observed covariance matrix is a function of a set of parameters, which define the SEM
* The covariances are **decomposed** into the parameters that describe a given model

12

<!-- page 13 -->

# Scaling Latent Variables

* Because latent variables are unobserved, we need to place constraints on the model prior to estimation that define the scale of all latent variables, so that models are **identified**
* One of two options are generally employed:
  - Fix the path from the latent variable to one of its indicators to be equal to 1, with 0 intercept (see **Slide 26**)
  - Fix the variance of the latent variable to be 1 (we will see an example of this at the end of the lecture)

13

<!-- page 14 -->

# How are Estimates Computed?

* Taken together, the parameters of an SEM combine to ***imply*** a set of means and covariances for the observed variables (**we will see several examples**!)
* Given:
  - distributional assumptions for observed variables, and
  - ***implied*** means, variances and covariances for observed variables, based on the SEM parameters,
* We can define a likelihood function, and then use maximum likelihood estimation methods

14

<!-- page 15 -->

# How are Estimates Computed?

* General ML fitting function / log-likelihood (MVN):

$$F_{ML} = \ln |\Sigma(\theta)| + tr(S\Sigma^{-1}(\theta)) - \ln |S| - (p+q)$$
$$+(\bar{z} - \mu(\theta))'\Sigma^{-1}(\theta)(\bar{z} - \mu(\theta))\big\} \text{ if means estimated}$$

*where*

$\theta =$ vector of all parameters to be estimated

$\Sigma(\theta) =$ ***implied*** covariance matrix for variables

$S =$ sample covariance matrix for variables

$p+q =$ number of observed variables

$\bar{z} =$ vector of sample means for observed variables

$\mu(\theta) =$ vector of implied means based on model

15

<!-- page 16 -->

# How are Estimates Computed?

- We take the derivative of this function w.r.t. $\theta$, and find estimates that set the function equal to zero (iterative numerical algorithms)
- We seek estimates of the SEM parameters that **minimize** the differences between the implied and sample covariances (and means)!
- Exact forms of the fitting function will vary depending on distributional assumptions and the estimation method used; examples soon!

16

<!-- page 17 -->

# Additional Tools for Inference

* Overall Chi-square test of model fit:
  * Compute a Chi-square statistic, based on the differences between the sample covariance matrix and the implied covariance matrix
  * **Degrees of Freedom** (DF) are equal to the difference in the number of unique elements in the input covariance matrix [$k(k+1) / 2$, for $k$ observed variables] (plus the number of unique means, if applicable), and the number of parameters estimated
* Likelihood ratio tests (more shortly)

17

<!-- page 18 -->

# Model Fit Criteria

* **CFI:** Compare fitted model to null model assuming no relationships between variables; how much better is fitted model? Values greater than 0.9 or 0.95 desired
* **RMSEA:** Root mean squared error of approximation; a test statistic with a known sampling distribution, measuring closeness of implied covariances to sample covariances; can test null that $\text{RMSEA} < 0.05$ (“close” fit)

18

<!-- page 19 -->

# Model Fit Criteria

* **AIC / BIC:** Used to compare models with different counts of parameters, and no nesting relationship; not useful on their own; **smaller values indicate better fits**, with penalties applied for more parameters estimated
* **Likelihood ratio tests:** When ML estimation is used, standard LRTs can be used to compare the fits of nested models; good for simplifying model structures

19

<!-- page 20 -->

# Modification Indices

* If a model does not appear to fit well, most software can compute **modification indices**
* These provide a sense of how much the overall Chi-square statistic can be *reduced* by estimating additional parameters in the model
* These indices should **not** be used for exploratory analysis; they should only be used to make slight tweaks to a theoretically supported model

20

<!-- page 21 -->

# Alternative Estimation Methods

* **WLS/**Asymptotic Distribution Free (**ADF**); fitting function is written as follows:

$$
\begin{aligned}
F_{ADF} &= (s - \sigma(\theta))' W^{-1} (s - \sigma(\theta)) \\
where & \\
s &= \text{vector of non-duplicated elements of } S \\
\sigma(\theta) &= \text{vector of implied variances and covariances} \\
W &= \text{estimated variance-covariance matrix for elements of } S
\end{aligned}
$$

* W is a positive-definite "weight matrix"
* **Does not require multivariate normality**; W is based on "covariances of covariances"

21

<!-- page 22 -->

# Alternative Estimation Methods

* Categorical Variable Model (**CVM**); good for binary and ordinal variables; uses the general ADF function; uses *polychoric* correlations of underlying latent variables as inputs to ADF
* **Bootstrapping:** Another approach to dealing with non-normality; compute standard errors and correct Chi-square fit statistics based on many ($> 500$) bootstrap (with-replacement) samples from the observed data

22

<!-- page 23 -->

# Power and Sample Size

* In general, more cases are needed for:
  – Complex models (= many parameters)
  – Models with weak relationships in the population
  – Non-normal distributions
* At a minimum, one should use 100-150 cases
* Rule of thumb: 10-20 cases **per parameter estimated** (Kline, 2015, *Principles and Practice of SEM, Fourth Edition*)

23

<!-- page 24 -->

# Power and Sample Size

* More formal power calculations can be performed by simulation:
  - https://r-causal.github.io/ggdag/reference/simulate_data.html
  - https://robindenz1.github.io/simDAG/index.html
* Also, there are reference tables found in MacCallum et. al’s (1996) paper “Power analysis and determination of sample size for covariance structure modeling”
* The first step in performing a power analysis for an SEM is drawing the conceptual model and then calculating the degrees of freedom (see **Slide 17**)

24

<!-- page 25 -->

# Example: Confirmatory Factor Analysis (CFA)

- Suppose that we have three observed MVN variables, and theory suggests that they indicate one latent construct (LV1):

25

<!-- page 26 -->

# Example: Confirmatory Factor Analysis (CFA)

- We **scale** the latent factor to have the same measurement as the first observed variable by fixing the first path (coefficient) to 1
- Equations:

$$x_1 = v_1 + LV_1 + \varepsilon_1$$

$$x_2 = v_2 + \lambda_{21}LV_1 + \varepsilon_2$$

$$x_3 = v_3 + \lambda_{31}LV_1 + \varepsilon_3$$

26

<!-- page 27 -->

# Example: Confirmatory Factor Analysis (CFA)

* **Model-Implied Variances and Covariances:**

$$
\Sigma(\theta) = \begin{bmatrix}
Var(LV_1) + Var(\varepsilon_1) & & \\
\lambda_{21}Var(LV_1) & \lambda_{21}^2Var(LV_1) + Var(\varepsilon_2) & \\
\lambda_{31}Var(LV_1) & \lambda_{21}\lambda_{31}Var(LV_1) & \lambda_{31}^2Var(LV_1) + Var(\varepsilon_3)
\end{bmatrix}
$$

* **Model-implied Means:**

$$
\mu(\theta) = \begin{bmatrix}
\nu_1 + Mean(LV_1) \\
\nu_2 + \lambda_{21}Mean(LV_1) \\
\nu_3 + \lambda_{31}Mean(LV_1)
\end{bmatrix}, \text{ with } Mean(LV_1) \text{ known, given scaling}
$$

* These pieces are input to the fitting function (**Slide 15**) for ML estimation of the 9 unknown parameters (can you see the unknown parameters? v1, v2, v3, var(LV1), var(e1), var(e2), var(e3), lambda21, lambda31)
* 6 unique variance/covariance parameters + 3 means = 9 inputs; 9 parameters estimated $\rightarrow$ 0 DF (**saturated model:** we are exactly replicating the observed correlations, but our interest is in the estimated coefficients!)

27

<!-- page 28 -->

# Example: Path Model

* Suppose that we are interested in testing a **mediation model**
* An apparent **direct effect** of one observed variable (x1) on another (x2) may be due to the **indirect effect** of x1 on x2 through a third variable (a mediator, M)
* In a path model, **all variables are observed!**
* In mediation models, **<u>temporal ordering</u>** of variables in causal pathway is important!

28

<!-- page 29 -->

# Example: Path Model

* $\varepsilon_1$
* Time 2
* $M$
* Indirect effect of $x1$ on $x2$
* $x1$
* $x2$
* $\varepsilon_2$
* Time 1
* Direct effect of $x1$ on $x2$
* Time 3

Total Effect of $x1$ on $x2 = \text{direct effect} + \text{indirect effect}$

29

<!-- page 30 -->

# Example: Path Model

* **Equations:**

$$x_2 = v_2 + \beta_{21}x_1 + \beta_{2M}M + \varepsilon_2$$

$$M = v_M + \beta_{M1}x_1 + \varepsilon_1$$

* **Model-Implied Variances and Covariances:**

$$Var_\theta \begin{bmatrix} \begin{pmatrix} M \\ x_2 \end{pmatrix} \\ x_1 \end{bmatrix} = \Sigma(\theta) = \begin{bmatrix} \Sigma_{endo}(\theta) & \Sigma_{endo,exog}(\theta) \\ \Sigma_{endo,exog}(\theta) & \Sigma_{exog}(\theta) \end{bmatrix} = \begin{bmatrix} [\Gamma\Phi\Gamma' + \Psi] & \Gamma\Phi \\ \Phi\Gamma' & \Phi \end{bmatrix}$$

*where*

$\Gamma =$ vector of (5) coefficients in equations for endogenous variables ($M$ and $x_2$)

$\Phi =$ variance-covariance matrix of exogenous variables (1 element, known)

$\Psi =$ variance-covariance matrix of errors for endogenous variables (2 elements)

30

<!-- page 31 -->

# Example: Path Model

* **Model-Implied Means:**

$$
\mu(\theta) = \begin{bmatrix} v_M + \beta_{M1}\text{Mean}(x_1) \\ v_2 + \beta_{21}\text{Mean}(x_1) + \beta_{2M}\text{Mean}(M) \\ \text{Mean}(x_1) \end{bmatrix}
$$

* **Inputs:** 3 variances, 3 covariances, 1 *unique* mean (the means of the endogenous variables, x2 and M, are exactly defined by known information and other parameters in this model)
* **Parameters to be estimated:** 7
* **Degrees of Freedom:** 0 (a **saturated model**, meaning that this model <u>perfectly replicates the observed correlations</u>; that’s OK, because we can still generate our parameter estimates and their SEs!)

31

<!-- page 32 -->

# Example: Latent Growth Curve Model (LGCM)

* **Multilevel models <u>for longitudinal data</u> can also be fitted using an SEM framework**
* In this case, we treat random intercepts and slopes as latent variables, and estimate their means (**fixed effects!**) and (co)variances (**D!**)
* We have to initially fix paths from the latent intercepts and slopes to represent changes in units of time across the observed variables

32

<!-- page 33 -->

# Example: LGCM

* An example, with time points 0 (baseline), 1 unit later, and 2 units later (“intercepts” = 0):

* **Equation:** $\text{Y1\_i} = 0 + \text{Intercept\_i} + 0 \times \text{Slope\_i} + \text{e1\_i}$

33

<!-- page 34 -->

# Example: LGCM

* The fact that multilevel models can be fitted in the SEM framework opens up many interesting modeling possibilities
* One has to be careful to stick to theoretical considerations, however, as SEM models can become quite complicated!
* **Also important:** note that a **wide** data structure is required for fitting these SEMs

34

<!-- page 35 -->

# Visualizing SEM Fits

* See **Hallgren et al. (2018)** on Canvas
* Simple figures (e.g., path models / SEMs shown earlier) illustrating SEM models that were fitted don’t always convey the nature of the relationships modeled!

35

<!-- page 36 -->

# SEM Software Options

* R: The `sem` and `lavaan` packages
* SAS: `proc calis`
* Stata: `sem` / `gsem` commands
  - Models can be drawn or estimated using syntax (or both!)
* `gllamm` add-on command in Stata: syntax only
* AMOS (SPSS Add-On Module)
  - Models are drawn and then estimated
* Mplus: Syntax only
* RLISREL
* EQS
* We will consider examples in R, Stata and Mplus (mainly FYI)

36

<!-- page 37 -->

# Example R Code

* Recall the SEM on **Slide 5** (data on Canvas):

37

<!-- page 38 -->

# Example R Code

```r
install.packages("lavaan", dependencies=TRUE)
library(lavaan)
wheaton <- read.table("wheaton.dat", h=T) # if there is a header (DATA ON CANVAS)
model <- ' # CRITICAL: NOTE SINGLE QUOTES USED TO DEFINE MODEL OBJECT
# measurement model
   ses66 =~ educ66 + occstat66
   alien67 =~ anomia67 + pwless67
   alien71 =~ anomia71 + pwless71
# structural model
   # direct effect
      alien71 ~ c*ses66
   # mediator
      alien67 ~ a*ses66
      alien71 ~ b*alien67
   # indirect effect (a*b)
      ab := a*b
   # total effect
      total := c + (a*b)
'
fit <- sem(model, data=wheaton)
summary(fit)
```

**SEE TODAY’S HANDOUT FOR DETAILED OUTPUT**

38

<!-- page 39 -->

# Thinking Ahead

* In the next class, we will consider important extensions of the SEM framework:
  - Multiple Group Analysis (MGA)
  - Latent Class Analysis (LCA)
* LCA is often used for measurement error investigations in surveys; we’ll see an example
* Later, we will also consider how to account for complex sampling features when fitting SEMs and making inferences

39
