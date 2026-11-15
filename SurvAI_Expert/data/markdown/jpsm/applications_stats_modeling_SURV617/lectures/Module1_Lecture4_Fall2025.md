---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module1_Lecture4_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "**Applications of Statistical Modeling:**"
original: "applications_stats_modeling_SURV617/lectures/Module1_Lecture4_Fall2025.pdf"
pages: 46
sha256: "9b053e393ff5ebd5771b763b321d51bb8172d5d213bd14e1ac4c9496214cfe5a"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:41"
---

<!-- page 1 -->

# **Applications of Statistical Modeling:**
## Module #1, Lecture #4

### Alternative Statistical Models for Longitudinal Data: A Conceptual Overview

Instructor: Brady T. West

Email: [email]

1

<!-- page 2 -->

# Lecture Overview

- Definitions of Longitudinal and Repeated Measures Data, and Data Structure
- Hierarchical vs. Marginal Approaches
  - Multilevel Modeling
  - Marginal Linear Models for Normal Outcomes
  - Generalized Estimating Equations
- Non-Normal Outcomes
- **<u>Supplement</u>:** See software notes on Canvas
- Take-Home Points

2

<!-- page 3 -->

# Repeated Measures / Longitudinal Data

* **Repeated measures** in general refer to repeated measures of the same outcome collected from <u>the same units</u> of analysis
  - Could be repeated measures under different experimental conditions / treatments
  - Could be repeated measures over time
* **Longitudinal data** represent a *special case* of repeated measures data: repeated measures over **long periods of time** on the same units
  - Our focus in this portion of the class (panels)

3

<!-- page 4 -->

# Repeated Measures / Longitudinal Data

* The key point in thinking about statistical models for longitudinal data is that we need to estimate parameters that capture **correlations of the repeated measures**
* This can be done by fitting models with random effects, correlated errors, or both!
* We will talk about these different approaches today and next week

4

<!-- page 5 -->

# Traditional Approaches

* Traditional / classical approaches to the analysis of repeated measures data rely on **repeated measures analysis of variance (rmANOVA)**
* This is a **multivariate** analysis approach, where the repeated measures arise from a **balanced design** (same time points / conditions for all subjects, no missing data)

5

<!-- page 6 -->

# Traditional Approaches

* rmANOVA approaches have many **limitations**:
  - A wide data structure is needed, with complete data for all subjects in the variables containing the repeated measures
  - Generally relies on only one type of marginal covariance structure for the repeated measures (“spherical”, or compound symmetry)
  - Listwise deletion means that subjects with any missing data will be dropped from the analysis!
  - Non-normal outcomes are not easily handled
  - Time-varying covariates are not allowed!

6

<!-- page 7 -->

# “Modern” Approaches

* More flexible “modern” approaches have been enabled by rapid developments in statistical software over the past few decades
* These approaches can accommodate data that are <u>missing at random</u>, and enable analysts to consider a variety of covariance structures
* We will discuss three general classes of models, but we first need to consider the appropriate data structure for longitudinal modeling

7

<!-- page 8 -->

# Appropriate Data Structure

* In general, statistical software for fitting longitudinal models requires a vertical data structure:

| ID | Time | Group | DV | TVwgt | BASEwgt |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 1 | 1 | 180 | 15 | 10 |
| 1 | 2 | 1 | 185 | 18 | 10 |
| 1 | 3 | 1 | 195 | 22 | 10 |
| ... | ... | ... | ... | ... | ... |
| 2 | 1 | 0 | 176 | 23 | 20 |
| 2 | 2 | 0 | 167 | 25 | 20 |
| 2 | 3 | 0 | 168 | 31 | 20 |

8

<!-- page 9 -->

# Appropriate Data Structure

* Note the “vertical” or “long” structure, with multiple rows per subject / unit ID
* Sometimes referred to as a “unit-time” or “subject-time” data structure
* Contrast this with the “wide” structure, with one row per person and multiple variables containing the repeated measures
* This “univariate” structure takes full advantage of the available information

9

<!-- page 10 -->

# Appropriate Data Structure

* Note also the presence of a **baseline sampling weight**, representing a population weight at the time that a person entered a sample
* We also see a **time-varying weight**, representing an adjusted version of the baseline weight accounting for differential attrition at individual time points
* Original stratum and cluster variables would also be included in the data set (not shown in the previous data table)

10

<!-- page 11 -->

# Introducing the HRS Data

* On Canvas, you’ll find R, SAS, Stata, and Excel versions of a file containing data from four waves of the Health and Retirement Study (HRS); the file names are hrs_reduced2.xxx
* Waves: 2000, 2002, 2004, 2006
* Note the “long” format of the data file
* We see data on total household assets, and demographics for the head of the household
* We also note complex sampling features!

11

<!-- page 12 -->

# First Things First...

* Regardless of the modeling approach that you decide to use when analyzing longitudinal data, **<u>always</u> start with descriptive plots**
* “Spaghetti” plots are generally best, showing variation in trends among units based on the available information (or variation in means among subgroups); see the `ggplot` code from last week!
* These plots are easy to generate in various general-purpose software packages (see today’s **software supplement** on Canvas)

12

<!-- page 13 -->

# Example: Plotting the Data

* From West et al. (2022, *Linear Mixed Models*):

**Individual Data by SICD Group**

13

<!-- page 14 -->

# Example: Plotting the Data

14

<!-- page 15 -->

# Alternative Modeling Approaches

* We will talk about the following classes of models over the next two weeks:

| Outcome | Multilevel | Marginal | |
| :--- | :---: | :---: | :---: |
| Normal | HLM | GEE | Marginal LM |
| Non-Normal | HGLM | GEE | |

* Multilevel and marginal models are mainly distinguished by the presence or absence of **random effects**, which account for between-subject variance in coefficients of interest

15

<!-- page 16 -->

# Multilevel Modeling Approaches

* Recall the general specification of a multilevel model for a normal outcome, with $t = \text{time}$ point, and $i = \text{subject}$:

$$
y_{ti} = \beta_0 + \beta_1 x_{1ti} + u_{0i} + u_{1i} x_{1ti} + e_{ti}
$$

$$
\begin{pmatrix} u_{0i} \\ u_{1i} \end{pmatrix} \sim N\left( \begin{pmatrix} 0 \\ 0 \end{pmatrix}, \begin{pmatrix} \sigma_0^2 & \sigma_{01} \\ \sigma_{01} & \sigma_1^2 \end{pmatrix} \equiv D \right)
$$

$$
e_{ti} \sim N(0, \sigma^2)
$$

16

<!-- page 17 -->

# Multilevel Modeling Approaches

* Also recall the **matrix specification** of this model, both for the **conditional model** and the **implied marginal model** (what we fit!):

$$y_i | u_i \sim N(X_i\beta + Z_iu_i, R_i)$$

$$y_i \sim N(X_i\beta, Z_iDZ_i' + R_i \equiv V_i)$$

* When analyzing **longitudinal data**, we can consider more flexible structures for $R_i$, given that conditional errors may be correlated!

17

<!-- page 18 -->

# Multilevel Modeling Approaches

* The key here is that by using **explicit random effects**, we approximate subject-specific longitudinal profiles with unique linear regression functions
* The multilevel model thus has two levels:
  * **Level 1:** A model for <u>each subject</u>, relating time-varying predictor variables to the dependent variable
  * **Level 2:** A model for each subject-specific coefficient, explaining variance in the **random coefficients** with subject-level predictors

18

<!-- page 19 -->

# Multilevel Modeling Approaches

* Note that the fixed effects in these models **only appear at Level 2** of the model specification!

**Level 1:**
$$y_{ti} = \beta_{0i} + \beta_{1i}x_{1ti} + e_{ti}$$

Random coefficients (not parameters!)

**Level 2:**
$$\beta_{0i} = \beta_0 + u_{0i}$$
$$\beta_{1i} = \beta_1 + u_{1i}$$

We add subject-specific covariates and their fixed effects to the Level 2 equations to explain variance in the random effects!

19

<!-- page 20 -->

# Multilevel Modeling Approaches

* For example, suppose that we add fixed effects of a specialized treatment (a binary, time-invariant covariate), randomly assigned in a longitudinal clinical trial, to the Level 2 equations:

**Level 1:**

$$y_{ti} = \beta_{0i} + \beta_{1i}x_{1ti} + e_{ti}$$

**Level 2:**

$$\beta_{0i} = \beta_{00} + \beta_{01}T_i + u_{0i}$$

$$\beta_{1i} = \beta_{10} + \beta_{11}T_i + u_{1i}$$

Note that we would expect the variances of the random effects to be <u>reduced</u>. But how do we interpret the 4 parameters?

20

<!-- page 21 -->

# Multilevel Modeling Approaches

* As mentioned earlier, with longitudinal data, we can consider more general structures for the $R_i$ matrix, which captures the variances and covariances of conditional errors for the same subject $i$
* **<u>Some</u> Examples:**
  - **First-order auto-regressive** (for equally-spaced time points; constant variance, correlation that weakens as a power function of the time between different points)
  - **Simple diagonal/spherical** (constant variance, zero covariance)
  - **Compound symmetry** (constant variance, constant covariance)
  - **Heterogeneous variance** (error variance changes as a function of the time point, or as a function of different subgroups)

21

<!-- page 22 -->

# Multilevel Modeling Approaches

* Later, we’ll consider how multilevel models might change when outcomes are <u>not</u> normally distributed
* Now, we consider alternative approaches for fitting the **marginal model**, where random effects are <u>not</u> explicitly included (different parameterization of the $V_i$ matrix!)

22

<!-- page 23 -->

# Marginal Modeling Approaches

* A researcher may not care about estimating between-subject variability in slopes or intercepts; only fixed effects are of interest!
* They may only be interested in overall marginal trends, possibly for different groups
* Alternative methods exist for fitting these types of **marginal** models:
  – Marginal Linear Models (MLM)
  – Generalized Estimating Equations (GEE)

23

<!-- page 24 -->

# Marginal Modeling Approaches

* When fitting marginal models to normal dependent variables, we estimate parameters defined by the following model (no random effects, <u>just errors</u>):

$$y_{ti} = \beta_0 + \beta_1 x_{1ti} + \dots + e_{ti}$$

$$y_i \sim N(X_i \beta, V_i)$$

* Note that the variance-covariance matrix $V_i$ is completely general, and can take on many possible structures (e.g., unstructured, AR(1), etc.)
* **But we do not explicitly estimate the variances and covariances of random effects in the *D* matrix!**

24

<!-- page 25 -->

# Marginal Linear Models

* With normal outcomes, we can estimate marginal models using a two-step approach (same idea used for multilevel models):
  - Estimate the parameters defining the variance-covariance matrix $V_i$ using REML or ML
  - Use **Generalized Least Squares** to compute estimates of the fixed-effect parameters:

$$\hat{\beta} = \left( \sum_i X_i' \hat{V}_i^{-1} X_i \right)^{-1} \sum_i X_i' \hat{V}_i^{-1} y_i$$

25

<!-- page 26 -->

# Marginal Linear Models

* **Important:** If you fit a marginal linear model to a normal outcome ***using a multilevel (or mixed) modeling software procedure,*** you are <u>not</u> actually fitting a mixed (or multilevel) model (recall the special case only when they coincide)!
* **Why?** You aren’t including explicit random effects in the model; you are just allowing errors to correlate
* It is therefore important to refer to these models as *marginal linear models* (with correlated errors) in publications and reports, so that readers are not mislead about the methods used!

26

<!-- page 27 -->

# Generalized Estimating Equations

* When fitting models to longitudinal data using GEE, we seek estimates of parameters that solve the following **score function** (or **estimating equation**):

$$
S(\beta) = \sum_{i=1}^{n} D_{i}^{T} V_{i}^{-1} (y_{i} - \mu_{i}) = 0
$$

* $D_{i}^{T}$ is an $n_{i} \times p$ matrix with $(i,j)$th elements $\frac{\partial \mu_{ti}}{\partial \beta}$
* $V_{i}$ is the $n_{i} \times n_{i}$ variance-covariance matrix for the observations on subject $i$ (user-specified)

27

<!-- page 28 -->

# Generalized Estimating Equations

* $y_i$ is the vector of outcome measures collected for the $i$-th subject
* $\mu_i$ is the vector of expected means for the outcome measures **based on the specified model** (here is where the <u>betas</u> enter...)
* These equations are generally solved using either:
  * Iteratively weighted least squares, or
  * Fisher scoring algorithms (more common)

28

<!-- page 29 -->

# Generalized Estimating Equations

* The GEE methodology was first introduced by Liang and Zeger in a seminal 1986 paper (see Canvas)
* We seldom know the true variance-covariance matrix for the observations, so in practice we work with a **working correlation matrix** (a "plausible guess" for the true structure)
* We typically specify correlations and not covariances, because for non-normal outcomes the variances are defined by the mean structure of the model
* **This allows the methodology to be easily adapted to non-normal outcomes** (Poisson, Binomial, etc.)

29

<!-- page 30 -->

# Generalized Estimating Equations

* Variances of the parameter estimates are computed using what is known as a **sandwich estimator** (Liang and Zeger, 1986)
* This estimator is based on the specified working correlation matrix (e.g., exchangeable), and the variance-covariance matrix of the observations based on expected means from the fitted model
* Estimators of the beta parameters are **consistent** even if the specified working correlation matrix is incorrect; <u>bad choices affect the standard errors</u>

30

<!-- page 31 -->

# Generalized Estimating Equations

* Possible choices for the working correlation matrix in models fitted using GEE:
  - Independence (0 correlation, independent obs.)
  - Exchangeable (constant correlation)
  - AR(1) (first-order auto-regressive, decaying correlation over time)
  - Unstructured (completely general correlations)
* Estimators of the correlations were proposed by Liang and Zeger (1986)
* We generally focus on the betas, and do not make inferences about the “nuisance” correlations

31

<!-- page 32 -->

# Generalized Estimating Equations

* Inference that is “robust” to possible variance-covariance matrix misspecification is possible when using **Wald Tests** based on the sandwich estimates of the standard errors
* An adapted information criterion (QIC) can be used to compare the fits of competing models
* Good specification of the mean structure (interactions, non-linear terms, etc.) is important!
* With large data sets, alternative choices of the working correlation matrix do not make a large difference, but should still be considered

32

<!-- page 33 -->

# Generalized Estimating Equations

* Because poor choices of the working correlation matrix can affect standard errors (and thus inferences), it is worthwhile to try and choose a reasonable model based on information criteria
* The QIC, while popular and widely implemented, has been demonstrated to have important shortcomings in choosing the “correct” correlation structure
* Westgate and Burchett (2017; see Canvas) describe better alternatives for identifying the correct correlation structure, and provide R code to both fit GEE models and compute the advocated information criteria

33

<!-- page 34 -->

# Models for Non-Normal Outcomes

* In many longitudinal studies, outcome variables are not normally distributed
  - Binary indicators (drug use in past 3 months?)
  - Counts (frequency of drug use in past 3 months?)
  - Categorical outcomes (household income bracket)
  - Others?
* We therefore need to consider adaptations of the methods discussed so far for these types of outcome variables

34

<!-- page 35 -->

# Models for Non-Normal Outcomes

* GEE methods were specifically designed to readily accommodate non-normal outcome variables measured longitudinally
* The mean structure in the estimating equations is defined by a given type of generalized linear model
* **Example:** logistic regression for a binary DV

$$
\mu_i = \pi_i = E(y_i \mid X_i) = \frac{\exp(X_i\beta)}{1 + \exp(X_i\beta)}
$$

35

<!-- page 36 -->

# Models for Non-Normal Outcomes

* When considering multilevel models for non-normal outcomes (e.g., multilevel logistic regression), which include **explicit random effects**, the estimation methods are not as straightforward
* We will first describe the model, and then discuss alternative estimation procedures that are used in the software

36

<!-- page 37 -->

# Models for Non-Normal Outcomes

* We assume that given a vector of random effects for subject $i$, $\boldsymbol{u}_i$, all responses $y_{ti}$ on the dependent variable are independent, and follow a density function that belongs to the **exponential family**:

$$
f(y_{ti} \mid \theta_{ti}, \phi) = \exp\{\phi^{-1}[y_{ti}\theta_{ti} - \psi(\theta_{ti})] + c(y_{ti}, \phi)\}
$$

* The regression parameters and random effects enter as follows:

$$
\theta_{ti} = x'_{ti}\beta + z'_{ti}u_i, \text{ with } u_i \sim N(0, D)
$$

37

<!-- page 38 -->

# Models for Non-Normal Outcomes

* The marginal distribution of the vector of responses on subject $i$ is then found by integrating the product of the individual density contributions with respect to the random effects:

$$f_i(y_i \mid \beta, D, \phi) = \int \prod_{t=1}^{n_i} f(y_{ti} \mid u_i, \beta, \phi) f(u_i \mid D) du_i$$

* Given this marginal distribution, we can now write the likelihood function...

38

<!-- page 39 -->

# Models for Non-Normal Outcomes

* Likelihood function (in theory):

$$L(\beta, D, \phi) = \prod_{i=1}^{n} f_i(y_i \mid \beta, D, \phi)$$

* With a normal dependent variable, we can work out the necessary integral analytically
* With a non-normal dependent variable, good luck...=)
* We need to first **approximate** the likelihood!

39

<!-- page 40 -->

# Models for Non-Normal Outcomes

* We can approximate the likelihood using two possible approaches:
  – Approximation of the integrand
  – Approximation of the integral: also known as **numerical quadrature**
* The first approach basically requires approximating the inner product for a subject with a normal density; this requires a roughly continuous response, and many subjects!

40

<!-- page 41 -->

# Models for Non-Normal Outcomes

* More often in practice, we use **Gaussian Quadrature**, and replace the integral with a weighted sum of density functions
* The number of elements used in the sum is known as the number of **integration points**, where a higher number of points produces a more accurate approximation
* Algorithms are now available in software for determining these weighted sums

41

<!-- page 42 -->

# Models for Non-Normal Outcomes

* **Adaptive Gaussian Quadrature** is often used for this approximation, and needs fewer integration points than classical quadrature, but requires more computational time
* **Laplace Approximation** and **Penalized Quasi-Likelihood (PQL)** provide other options for approximating the integral (see Kim et al., 2013)
* Once we have approximated the likelihood, we can use standard maximization procedures

42

<!-- page 43 -->

# Models for Non-Normal Outcomes

* So which approximation method is best?
* Kim et al. (2013) simulations, on Canvas:
  - PQL estimates tend to be noticeably biased (this has also been found in other studies)
  - SAS PROC GLIMMIX – Laplace tended to perform well compared to other options
  - AGQ required substantial computational resources in most cases, but still works well
  - Use AGQ with smaller sample sizes or studies with fewer time points; Laplace superior with large samples

43

<!-- page 44 -->

# Take-away Points

* The difference between marginal and hierarchical (or multilevel) modeling approaches is extremely important when analyzing longitudinal data
* **Hierarchical:** include random effects, and inferences are <u>subject-specific</u> (i.e., you are “controlling” for random subject effects, and fixed effects represent what happens when a covariate changes <u>for a given subject</u>)
* **Marginal:** Population-averaged effects (what happens <u>across all subjects</u> in a study?)

44

<!-- page 45 -->

# Take-away Points

* For non-normal outcomes, GEE models are fairly straightforward to estimate, and do not involve the computational issues associated with random effects
* However, we are unable to make inferences about between-subject variability
* **Important question:** how should we model fixed time effects (Spline? Polynomial? Categorical?)? Stay tuned!

45

<!-- page 46 -->

# Thinking Ahead...

* Please review today’s **software supplement**, and start fitting some initial models to the data set that you want to work with!
* Next week, we will consider a case study involving analysis of the HRS data
* In the final lecture of this module (after the Midterm Exam), we will discuss recent research on handling complex sample designs in models for longitudinal data

46
