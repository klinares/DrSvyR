---
id: "jpsm/applications_stats_modeling_SURV617/midterm/midterm_study_guide"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "assignment"
title: "Comprehensive Study Guide: Multilevel, Marginal, and GEE Models"
original: "applications_stats_modeling_SURV617/midterm/midterm_study_guide.qmd"
pages: 
sha256: "fa17d679b90ae4fe0c8ed7da0e9ea94b145d823e76d92cdcc3f56bcc0961488c"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:43"
---



# Introduction and Course Scope

This study guide covers **Module 1, Lectures 1-5** of SURV 617/SURVMETH 687:

- **Lecture 1**: Course Overview & Multilevel Modeling Concepts
- **Lecture 2**: Software for Fitting Multilevel Models
- **Lecture 3**: Application - Interviewer Effects in the European Social Survey
- **Lecture 4**: Alternative Statistical Models for Longitudinal Data (Conceptual Overview)
- **Lecture 5**: Case Study - Growth Curve Models with HRS Data

**Key Topics**: Multilevel models (LMMs, GLMMs), marginal models, GEE, interviewer effects, longitudinal data analysis, model estimation, hypothesis testing, and diagnostics.

## Critical Exam Preparation Strategy

::: {.callout-important}
## Working Code is Essential

**Have working code for fitting and evaluating various models ready to go, so that you can adapt that code to the data analysis problem. You should NOT be writing code from scratch for the data analysis problems.**

**What This Means**:

1. **Create a personal code library** with working examples of:
   - Random intercept models (LMM, GLMM)
   - Random slope models
   - Marginal models (GLS, GEE)
   - Model diagnostics
   - Hypothesis tests (LRT, Wald tests)
   - Plotting functions

2. **Test your code** on practice datasets (ESS, HRS, Autism data)

3. **During the exam**: Copy and adapt your working code to the new problem
   - Change variable names
   - Adjust model specifications
   - Modify for the specific research question

4. **Sections 7 and 8 of this guide** provide comprehensive, tested code templates that you should:
   - Run on your computer before the exam
   - Save in an easily accessible location
   - Be prepared to copy/paste and modify during the exam
:::

\newpage

# Foundational Concepts

## The "Why": Handling Correlated Data

At the core of this course is the management of **non-independent data**. This typically arises from:

### Types of Correlated Data Structures

1. **Hierarchical/Clustered Data**: 
   - Students nested within schools
   - Patients within hospitals
   - Respondents within interviewers
   - Observations from the same cluster are more similar to each other than to observations from different clusters

2. **Longitudinal/Repeated Measures Data**: 
   - The same subject measured at multiple time points
   - A person's measurement at time 2 is correlated with their measurement at time 1
   - Can be balanced (same time points for all) or unbalanced (missing data, different schedules)

3. **Crossed Random Effects**:
   - Interviewers working in multiple PSUs
   - Students having multiple teachers
   - Need to disentangle multiple sources of clustering

## The Core Problem: Violation of Independence

Standard regression models (like OLS) assume that all observations are **independent**. When this assumption is violated:

1. **Standard Errors are Incorrect**: Typically underestimated (too small)
2. **Inflated Type I Error**: Because SEs are too small, p-values are artificially low, leading to false positive findings
3. **Inefficient Coefficient Estimates**: While coefficients may be unbiased, they are no longer the most precise (don't have minimum variance)
4. **Reduced Effective Sample Size**: With clustering, effective sample size is smaller than actual sample size

### Variance Inflation

The **Design Effect** quantifies how clustering reduces effective sample size:

$$\text{DEFF} = 1 + (n-1)\rho$$

Where:

- $n$ = average cluster size
- $\rho$ = intraclass correlation

**Example**: With ICC = 0.05 and cluster size = 30:

- DEFF = 1 + (30-1)(0.05) = 2.45
- A sample of 1,000 effectively acts like a sample of 1,000/2.45 = 408

## Key Model Families

Two primary approaches exist to handle correlated structure:

### 1. Conditional Models (Mixed-Effects Models)

These models explicitly partition variance into different levels using **random effects** to model cluster-specific deviations.

- **Examples**: Linear Mixed Models (LMMs), Generalized Linear Mixed Models (GLMMs)
- **Interpretation**: **Subject-specific** or **cluster-specific**
  - "For a given school, a one-unit increase in X is associated with a $\beta$ change in Y"
  - We are conditioning on (controlling for) the random effect
- **Key Feature**: Explicitly models between-cluster variation
- **Parameters**: Fixed effects ($\beta$) AND variance components ($\sigma^2_{u0}$, $\sigma^2_{u1}$, etc.)

### 2. Marginal Models

These models focus on the **population-average** relationship between predictors and outcome, specifying a "working" correlation structure for residuals.

- **Examples**: Generalized Estimating Equations (GEE), Marginal Linear Models
- **Interpretation**: **Population-averaged**
  - "Averaged across all schools, a one-unit increase in X is associated with a $\beta$ change in Y"
- **Key Feature**: Does not explicitly model cluster-specific variation
- **Parameters**: Fixed effects ($\beta$) AND correlation parameters

### When to Choose Which Approach?

| **Research Question** | **Appropriate Approach** |
|----------------------|-------------------------|
| How do individuals change over time? | Conditional (MLM) |
| What explains variation between clusters? | Conditional (MLM) |
| What is the population-average effect? | Marginal (GEE) |
| Need subject-specific predictions? | Conditional (MLM) |
| Concerned about random effects distribution? | Marginal (GEE) |
| Want robust inference with complex correlation? | Marginal (GEE) |

## Decomposing Variance: The Intraclass Correlation Coefficient (ICC)

The ICC tells us what **proportion of the total variance** in the outcome is attributable to differences **between** clusters.

### Calculation

For a simple random intercept model:

$$\text{ICC} = \rho = \frac{\sigma^2_{u0}}{\sigma^2_{u0} + \sigma^2_e}$$

Where:

- $\sigma^2_{u0}$ = between-cluster (random intercept) variance
- $\sigma^2_e$ = within-cluster (residual) variance

### Interpretation

- **ICC = 0**: No clustering effect; all variance is within clusters (standard regression is fine)
- **ICC close to 1**: Observations within a cluster are highly similar; most variance is between clusters
- **ICC quantifies non-independence**: A non-zero ICC confirms the need for multilevel or marginal models

### Example Calculation

From model output:
```
Random effects:
 Groups Name        Variance Std.Dev.
 school (Intercept) 49.9     7.064
 Residual           125.1    11.183
```

$$\text{ICC} = \frac{49.9}{49.9 + 125.1} = \frac{49.9}{175.0} = 0.285$$

**Interpretation**: 28.5% of the total variance in the outcome is due to differences between schools.

### Three-Level Models

For three-level models (e.g., students in classrooms in schools):

$$\text{ICC}_{\text{Level 2}} = \frac{\sigma^2_{u0,2}}{\sigma^2_{u0,2} + \sigma^2_{u0,3} + \sigma^2_e}$$

$$\text{ICC}_{\text{Level 3}} = \frac{\sigma^2_{u0,3}}{\sigma^2_{u0,2} + \sigma^2_{u0,3} + \sigma^2_e}$$

### Interviewer Effects Application

The ICC is particularly important in survey research for measuring **interviewer effects**:

- **Intra-interviewer correlation** ($\rho_{int}$): Correlation of responses within an interviewer's workload
- Sources of interviewer effects:
  - Measurement error (probing, recording)
  - Respondent recruitment patterns (who agrees to interview)
  - Interviewer characteristics (demographics, experience)
  
**Variance Inflation in Surveys**:

- Even small $\rho_{int}$ (e.g., 0.01-0.05) can substantially inflate variance with large workloads
- Trade-off: Hire more interviewers (smaller workloads) vs. reduce $\rho_{int}$ through training

## Data Structure Requirements

Most multilevel and marginal modeling software requires a **"long" or "vertical"** data structure:

```
ID    Time    Group    Outcome    Predictor    Weight
1     1       1        180        15           10
1     2       1        185        18           10
1     3       1        195        22           10
2     1       0        176        23           20
2     2       0        167        25           20
```

**Key features**:

- Multiple rows per subject/cluster
- One row per observation
- ID variable to identify clusters
- Time variable for longitudinal data
- Contrast with "wide" format (one row per subject, multiple columns for repeated measures)

\newpage

# Models for Continuous Outcomes

## Linear Mixed-Effects Models (LMMs)

LMMs are an extension of linear regression that include **random effects**. They are a **conditional modeling approach**.

### The Random Intercept Model

This is the simplest LMM, allowing each cluster to have its own baseline (intercept).

#### Hierarchical Specification

**Level 1 (Within-Cluster)**:
$$Y_{ij} = \beta_{0j} + \beta_1 X_{ij} + e_{ij}$$

**Level 2 (Between-Cluster)**:
$$\beta_{0j} = \gamma_{00} + u_{0j}$$

#### Combined Specification

$$Y_{ij} = (\gamma_{00} + u_{0j}) + \gamma_{10}X_{ij} + e_{ij}$$

Or more simply:

$$Y_{ij} = \beta_0 + u_{0j} + \beta_1 X_{ij} + e_{ij}$$

**Where**:

- $Y_{ij}$ = Outcome for observation $i$ in cluster $j$
- $\gamma_{00}$ (or $\beta_0$) = Fixed intercept (population average intercept)
- $u_{0j}$ = Random intercept for cluster $j$ (deviation from population average)
  - Assumption: $u_{0j} \sim N(0, \sigma^2_{u0})$
- $\gamma_{10}$ (or $\beta_1$) = Fixed slope for predictor $X$
- $e_{ij}$ = Residual for observation $i$ in cluster $j$
  - Assumption: $e_{ij} \sim N(0, \sigma^2_e)$
- **Key assumption**: $u_{0j}$ and $e_{ij}$ are independent

#### Interpretation

- **Fixed Intercept** ($\beta_0$): Expected value of $Y$ when $X=0$ and $u_{0j}=0$ (i.e., for an "average" cluster)
- **Fixed Slope** ($\beta_1$): Expected change in $Y$ for a one-unit increase in $X$, **within a given cluster**
- **Random Intercept Variance** ($\sigma^2_{u0}$): Variability in intercepts across clusters
- **Residual Variance** ($\sigma^2_e$): Variability within clusters (unexplained by model)

#### Practical Interpretation Example

Consider a model of student test scores (written) with student gender (female) and school type (type) as predictors:

```
Fixed effects:
                Estimate
(Intercept)     49.33
type            -0.28
female          -2.52
type:female      0.13

Random effects:
 Groups Name        Variance
 school (Intercept) 49.9
 Residual           125.1
```

**Model equation**:
$$\text{written}_{ij} = 49.33 - 0.28 \times \text{type}_j - 2.52 \times \text{female}_{ij} + 0.13 \times \text{type}_j \times \text{female}_{ij} + u_{0j} + e_{ij}$$

**Interpretations**:

1. **Intercept (49.33)**: The expected written score for male students (female=0) in private schools (type=0), for an average school (u₀ⱼ=0), is 49.33 points.

2. **Coefficient for type (-0.28)**: For male students, the average written score in public schools (type=1) is 0.28 points lower than in private schools (type=0).
   - Alternative: "For male students enrolled in public schools, their average writing score is 0.28 lower than those in private schools."

3. **Coefficient for female (-2.52)**: In private schools (type=0), female students score on average 2.52 points lower than male students.
   - Alternative: "In private schools, the average writing score of female students is 2.52 lower than that of male students."

4. **Interaction term (0.13)**: The gender gap in writing scores in public schools is 0.13 points smaller than in private schools.
   - Calculating the gender gap in public schools: -2.52 + 0.13 = -2.39
   - Alternative: "In public schools, the average writing score of female students is 2.39 lower than that of male students."

5. **ICC**: $\text{ICC} = \frac{49.9}{49.9 + 125.1} = 0.285$
   - 28.5% of the total variance in written scores is due to differences between schools.

### The Random Slope and Intercept Model

This model allows both the intercept and the slope of a predictor to vary across clusters.

#### Combined Specification

$$Y_{ij} = (\gamma_{00} + u_{0j}) + (\gamma_{10} + u_{1j})X_{ij} + e_{ij}$$

Or:

$$Y_{ij} = \beta_0 + u_{0j} + (\beta_1 + u_{1j})X_{ij} + e_{ij}$$

**Where**:

- $u_{1j}$ = Random slope for cluster $j$ (deviation of cluster $j$'s slope from population average $\gamma_{10}$)
  - Assumption: $u_{1j} \sim N(0, \sigma^2_{u1})$
- The random effects $(u_{0j}, u_{1j})$ follow a **bivariate normal distribution**, which allows for covariance $\sigma_{u01}$

#### Variance-Covariance Matrix of Random Effects (D matrix)

$$\mathbf{D} = \begin{pmatrix} \sigma^2_{u0} & \sigma_{u01} \\ \sigma_{u01} & \sigma^2_{u1} \end{pmatrix}$$

- $\sigma^2_{u0}$ = Variance of random intercepts
- $\sigma^2_{u1}$ = Variance of random slopes
- $\sigma_{u01}$ = Covariance between random intercepts and slopes
  - Positive: Clusters with higher intercepts tend to have steeper slopes
  - Negative: Clusters with higher intercepts tend to have flatter slopes

#### Interpretation

- **Fixed Slope** ($\beta_1$): Average slope across all clusters
- **Random Slope Variance** ($\sigma^2_{u1}$): How much slopes vary across clusters
- If $\sigma^2_{u1}$ is significant, the effect of $X$ on $Y$ **differs meaningfully across clusters**

#### Practical Example with Random Slopes

```
Fixed effects:
                Estimate
(Intercept)     49.36
type            -0.29
female          -2.59
type:female      0.17

Random effects:
 Groups Name        Variance Std.Dev. Corr
 school (Intercept) 52.58    7.25
        female       3.90    1.97    -0.24
 Residual           124.19   11.14
```

**Interpretation**:

1. The variance of the random slopes for female ($\sigma^2_{u1} = 3.90$) indicates that the gender gap in writing scores varies across schools.

2. The negative correlation (-0.24) suggests that schools with higher average scores tend to have slightly smaller gender gaps.

3. For a specific school $j$, the gender effect is: $-2.59 + u_{1j}$ where $u_{1j} \sim N(0, 3.90)$

### Matrix Specification

Understanding the matrix form is important for understanding estimation and implied covariances.

#### Conditional Model (Given Random Effects)

$$\mathbf{y}_j | \mathbf{u}_j \sim N(\mathbf{X}_j\boldsymbol{\beta} + \mathbf{Z}_j\mathbf{u}_j, \mathbf{R}_j)$$

Where:

- $\mathbf{y}_j$ = Vector of outcomes for cluster $j$
- $\mathbf{X}_j$ = Design matrix for fixed effects
- $\boldsymbol{\beta}$ = Vector of fixed effects
- $\mathbf{Z}_j$ = Design matrix for random effects
- $\mathbf{u}_j$ = Vector of random effects for cluster $j$
- $\mathbf{R}_j$ = Variance-covariance matrix of residuals

#### Marginal Model (Averaging Over Random Effects)

$$\mathbf{y}_j \sim N(\mathbf{X}_j\boldsymbol{\beta}, \mathbf{V}_j)$$

Where:

$$\mathbf{V}_j = \mathbf{Z}_j\mathbf{D}\mathbf{Z}_j' + \mathbf{R}_j$$

- $\mathbf{V}_j$ = **Marginal variance-covariance matrix** for cluster $j$
- This shows how random effects induce correlation among observations within a cluster

**Key Insight**: The multilevel model (with explicit random effects) **implies** a specific marginal covariance structure. We could fit this marginal model directly without random effects, but then we couldn't make inferences about cluster-specific effects.

### Adding Level-2 (Between-Cluster) Predictors

We can explain variance in random effects by adding Level-2 covariates.

**Example**: Explaining random intercepts and slopes with a treatment variable

**Level 1**:
$$Y_{ij} = \beta_{0j} + \beta_{1j}X_{ij} + e_{ij}$$

**Level 2**:
$$\beta_{0j} = \gamma_{00} + \gamma_{01}T_j + u_{0j}$$
$$\beta_{1j} = \gamma_{10} + \gamma_{11}T_j + u_{1j}$$

**Combined**:
$$Y_{ij} = \gamma_{00} + \gamma_{01}T_j + \gamma_{10}X_{ij} + \gamma_{11}T_j X_{ij} + u_{0j} + u_{1j}X_{ij} + e_{ij}$$

**Interpretation**:

- $\gamma_{00}$ = Expected outcome when $X=0$ and $T=0$
- $\gamma_{01}$ = Difference in intercepts between treatment groups
- $\gamma_{10}$ = Slope of $X$ when $T=0$ (control group)
- $\gamma_{11}$ = **Cross-level interaction**: How much the slope of $X$ differs between treatment groups

**Expectation**: After adding $T_j$ as a predictor, $\sigma^2_{u0}$ and $\sigma^2_{u1}$ should decrease (we've explained some of the between-cluster variance).

**Calculating Variance Explained**:

$$\text{Proportion Explained} = \frac{\sigma^2_{u0,\text{empty}} - \sigma^2_{u0,\text{with predictors}}}{\sigma^2_{u0,\text{empty}}}$$

### Covariance Structures for Longitudinal Data

For longitudinal data, we can specify more complex structures for $\mathbf{R}_j$ (the conditional error covariance).

#### Common Structures

1. **Simple Diagonal (Independence)**
   - Assumes constant variance, zero covariance
   - Usually too restrictive for longitudinal data
   - $$\mathbf{R}_j = \sigma^2_e \mathbf{I}$$

2. **Compound Symmetry (Exchangeable)**
   $$\mathbf{R}_j = \sigma^2_e \begin{pmatrix} 1 & \rho & \rho & \rho \\ \rho & 1 & \rho & \rho \\ \rho & \rho & 1 & \rho \\ \rho & \rho & \rho & 1 \end{pmatrix}$$
   - Constant variance, constant covariance
   - Equivalent to random intercept only model when $\mathbf{D}$ has only intercept

3. **First-Order Autoregressive (AR-1)**
   $$\mathbf{R}_j = \sigma^2_e \begin{pmatrix} 1 & \phi & \phi^2 & \phi^3 \\ \phi & 1 & \phi & \phi^2 \\ \phi^2 & \phi & 1 & \phi \\ \phi^3 & \phi^2 & \phi & 1 \end{pmatrix}$$
   - Correlation decays exponentially with time
   - Best for equally-spaced time points
   - $|\phi| < 1$

4. **Unstructured**
   - Each variance and covariance estimated separately
   - Most flexible, requires many parameters
   - Good for small number of time points

5. **Heterogeneous Variance**
   - Allows variance to change over time or across groups
   - Can be combined with other structures

#### Warning: Aliasing

**Do not over-specify!** You cannot include:

- Random intercepts AND compound symmetry errors (modeling same covariance twice)
- This leads to non-identifiable parameters
- Software will complain or produce nonsensical results

### Centering Continuous Covariates

**Why Center?**

- The intercept is the expected value when all predictors = 0
- If predictors are never 0, the intercept is not meaningful
- With random intercepts, centering makes interpretation clearer

**Two Types of Centering**:

1. **Grand-Mean Centering**: Subtract the overall mean
   - $X_{ij}^{GMC} = X_{ij} - \bar{X}_{..}$
   - Intercept = expected outcome for a unit with average $X$

2. **Group-Mean Centering**: Subtract the cluster mean
   - $X_{ij}^{CMC} = X_{ij} - \bar{X}_{.j}$
   - Separates within-cluster and between-cluster effects
   - Can include cluster mean as Level-2 predictor

## Marginal Models for Continuous Data

This approach models the **population-average effect** and specifies a variance-covariance structure for the errors. **No random effects** are explicitly estimated.

### Model Specification

$$Y_{ij} = \beta_0 + \beta_1 X_{ij} + \epsilon_{ij}$$

**Key difference**: We assume $\epsilon_{ij}$ are **correlated within cluster** $j$. We must specify the structure of this correlation in the marginal variance-covariance matrix $\mathbf{V}_j$.

### Relationship to Multilevel Models

- A marginal linear model is **equivalent** to a multilevel model if:
  - We specify the **same** variance-covariance structure
  - Example: Marginal model with compound symmetry = multilevel model with random intercepts only
  
- **Important**: When you fit a marginal model (no random effects), **do not call it a mixed model**!

### Equivalence Example

**Marginal Model (GLS) with Compound Symmetry**:
```r
gls(written ~ type + female + type*female,
    correlation = corCompSymm(form = ~ 1 | school))
```

Produces:
- Rho = 0.2852
- Residual SE = 13.23
- Diagonal elements of V: 13.23² = 174.97
- Off-diagonal elements of V: 13.23² × 0.2852 = 49.90

**Multilevel Model with Random Intercepts**:
```r
lmer(written ~ type + female + type*female + (1 | school))
```

Produces:
- School variance: 49.9
- Residual variance: 125.1
- ICC = 49.9/(49.9+125.1) = 0.285

**They are equivalent!**
- Marginal covariance = 49.9 ≈ 49.90
- Marginal variance = 49.9 + 125.1 = 175.0 ≈ 174.97

### Common Working Correlation Structures

Same structures as described for $\mathbf{R}_j$ in multilevel models:

1. **Compound Symmetry (Exchangeable)**
2. **Autoregressive (AR-1)**
3. **Unstructured**

### Estimation

Uses **Generalized Least Squares (GLS)**:

1. Estimate variance-covariance parameters first (using REML or ML)
2. Use estimated $\hat{\mathbf{V}}_j$ to compute fixed effects:

$$\hat{\boldsymbol{\beta}} = \left(\sum_j \mathbf{X}_j'\hat{\mathbf{V}}_j^{-1}\mathbf{X}_j\right)^{-1} \left(\sum_j \mathbf{X}_j'\hat{\mathbf{V}}_j^{-1}\mathbf{y}_j\right)$$

### When to Use Marginal Models?

- **Large datasets** where estimation is slow with random effects
- **Only care about population-average effects**, not cluster-specific variation
- Want to **avoid assumptions** about distribution of random effects
- Need **flexible correlation structures** not easily specified with random effects

### Interpreting Variance-Covariance Matrix

From marginal model output, we can construct the variance-covariance matrix:

If Rho = 0.2852 and Residual SE = 13.23:

$$\mathbf{V} = \begin{pmatrix} 174.97 & 49.90 & 49.90 & 49.90 \\ 49.90 & 174.97 & 49.90 & 49.90 \\ 49.90 & 49.90 & 174.97 & 49.90 \\ 49.90 & 49.90 & 49.90 & 174.97 \end{pmatrix}$$

- **Diagonal elements**: Variance of each observation = $\sigma^2_e = 13.23^2 = 174.97$
- **Off-diagonal elements**: Covariance between observations in same cluster = $\sigma^2_e \times \rho = 174.97 \times 0.2852 = 49.90$

\newpage

# Models for Non-Continuous Outcomes

## Generalized Linear Mixed Models (GLMMs)

GLMMs extend LMMs to handle **non-normal outcomes** (binary, count, categorical) by using a **link function** and specifying an appropriate **distribution family**.

### General Structure

$$g(\mu_{ij}) = \mathbf{X}_{ij}\boldsymbol{\beta} + \mathbf{Z}_{ij}\mathbf{u}_j$$

Where:

- $g(\cdot)$ = Link function
- $\mu_{ij} = E(Y_{ij}|\mathbf{u}_j)$ = Expected value conditional on random effects
- Distribution of $Y_{ij}|\mathbf{u}_j$ belongs to exponential family

### Logistic GLMM (Binary Outcome)

**Model with Random Intercept**:

$$\log\left(\frac{\pi_{ij}}{1-\pi_{ij}}\right) = (\gamma_{00} + u_{0j}) + \gamma_{10}X_{ij}$$

Or equivalently:

$$\text{logit}(\pi_{ij}) = \beta_0 + u_{0j} + \beta_1 X_{ij}$$

Where:

- $\pi_{ij} = P(Y_{ij}=1|\mathbf{u}_j)$ = Probability of success for observation $i$ in cluster $j$, conditional on random effect $u_{0j}$
- $u_{0j} \sim N(0, \sigma^2_{u0})$

**Interpretation**:

- Coefficients are **subject-specific** (or cluster-specific) **log-odds ratios**
- They represent the effect on **a given cluster's** log-odds
- "For a given cluster, a one-unit increase in $X$ changes the log-odds by $\beta_1$"
- These are **larger in magnitude** than population-averaged effects for non-linear models

#### Practical Interpretation Example

Consider a logistic GLMM for passing an exam (result):

```
Fixed effects:
              Estimate  Std. Error
(Intercept)    0.27      0.21
type          -0.13      0.19
female         0.83      0.18
type:female    0.13      0.25

Random effects:
 Groups Name        Variance
 school (Intercept) 1.67
```

**Model equation**:
$$\log\left(\frac{P(\text{result}_{ij}=1)}{P(\text{result}_{ij}=0)}\right) = 0.27 - 0.13 \times \text{type}_j + 0.83 \times \text{female}_{ij} + 0.13 \times \text{type}_j \times \text{female}_{ij} + u_{0j}$$

**Interpretations**:

1. **Intercept (0.27)**: 
   - For male students in a given private school (where the school-level random effect = 0), the log-odds of passing is 0.27.
   - If $u_{0j} = 0$, the probability of passing is $\frac{e^{0.27}}{1+e^{0.27}} = 0.567$
   - If $u_{0j} = 0.13$, the probability increases to $\frac{e^{0.27+0.13}}{1+e^{0.27+0.13}} = 0.599$

2. **Coefficient for type (-0.13)**: 
   - For male students in a given school, switching from private to public school multiplies the odds of passing by $e^{-0.13} = 0.878$
   - The odds are reduced by 12.2% $(1 - 0.878 = 0.122)$

3. **Coefficient for female (0.83)**: 
   - In a given private school, female students have $e^{0.83} = 2.29$ times the odds of passing compared to male students
   - "In a given private school, the odds of obtaining satisfactory science reports for female students are 2.29 times those for males."

4. **Interaction term (0.13)**: 
   - The gender effect in public schools is $0.83 + 0.13 = 0.96$
   - In public schools, female students have $e^{0.96} = 2.61$ times the odds of passing compared to males
   - "In a given public school, the odds of obtaining satisfactory science reports for female students are 2.61 times those for males."

5. **Random Intercept Variance (1.67)**:
   - There is substantial variation in baseline pass rates across schools
   - The standard deviation is $\sqrt{1.67} = 1.29$ on the log-odds scale
   - Schools can differ considerably in their baseline pass rates, even after accounting for gender and school type

### Poisson GLMM (Count Outcome)

$$\log(\lambda_{ij}) = \beta_0 + u_{0j} + \beta_1 X_{ij}$$

Where:

- $\lambda_{ij} = E(Y_{ij}|\mathbf{u}_j)$ = Expected count conditional on random effects
- $Y_{ij}|\mathbf{u}_j \sim \text{Poisson}(\lambda_{ij})$

### The Challenge: Estimation

For normal outcomes, we can write the marginal likelihood analytically. For non-normal outcomes, the marginal likelihood involves an **intractable integral**:

$$f(\mathbf{y}_j|\mathbf{X}_j, \boldsymbol{\beta}, \mathbf{D}) = \int f(\mathbf{y}_j|\mathbf{u}_j, \mathbf{X}_j, \boldsymbol{\beta}) f(\mathbf{u}_j|\mathbf{D}) d\mathbf{u}_j$$

**Solution**: We must **approximate** this integral.

### Approximation Methods

#### 1. Penalized Quasi-Likelihood (PQL)
- Fastest
- **Often biased**, especially for binary data with small cluster sizes
- **Not recommended** based on simulation studies (Kim et al. 2013)

#### 2. Laplace Approximation
- Approximates integral using second-order Taylor series
- Equivalent to Adaptive Gaussian Quadrature with 1 integration point (`nAGQ = 1`)
- **Good performance** for large sample sizes
- Can be **biased** for small sample sizes or extreme probabilities
- **Recommended** for large datasets
- **Default in R's glmer()**

#### 3. Adaptive Gaussian Quadrature (AGQ)
- Approximates integral with weighted sum
- More integration points (`nAGQ > 1`) = more accurate but slower
- **Better for smaller sample sizes** or longitudinal data with few time points
- Can be computationally intensive for complex random effects structures

#### 4. Maximum Likelihood (ML) via Integration
- Some software (e.g., SAS PROC GLIMMIX) offers various integration methods
- Can specify number and type of integration points

### Recommendations (from Kim et al. 2013)

- **Large sample sizes** (many clusters): Use Laplace (`nAGQ = 1`)
- **Small sample sizes or few time points**: Use AGQ with higher integration points (7-10)
- **Avoid PQL** due to potential bias

## Generalized Estimating Equations (GEE)

GEE is the **marginal counterpart** to GLMMs. It estimates **population-averaged effects** for non-normal outcomes.

### Model Structure

For a logistic model:

$$\log\left(\frac{\pi_{ij}}{1-\pi_{ij}}\right) = \beta_0 + \beta_1 X_{ij}$$

- Looks like a standard GLM
- But estimation accounts for within-cluster correlation via a **"working" correlation matrix** $\mathbf{R}(\alpha)$
- **No explicit random effects**

### Key Distinction from GLMMs

| Feature | GLMM | GEE |
|---------|------|-----|
| **Random Effects** | Yes, $u_{0j}$ explicitly modeled | No |
| **Interpretation** | Subject-specific | Population-averaged |
| **Coefficients** | Larger magnitude (non-linear) | Smaller magnitude (closer to 0) |
| **Distribution Assumption** | Must be correct | More robust |
| **Correlation** | Modeled via random effects | Specified as "working" structure |
| **Research Question** | Effect within a specific cluster | Average effect across population |

### Comparing GLMM and GEE Coefficients

**Example from exam data**:

**GLMM (Subject-Specific)**:
```
female: 0.83 (log-odds ratio)
```
Interpretation: Within a given school, female students have $e^{0.83} = 2.29$ times the odds of passing.

**GEE (Population-Averaged)**:
```
female: 0.63 (log-odds ratio)
```
Interpretation: Averaged across all schools, female students have $e^{0.63} = 1.88$ times the odds of passing.

**Why the difference?**
- GLMM conditions on (controls for) the random school effect
- GEE averages across all schools, including their variation
- For non-linear models (logistic, Poisson), averaging across a non-linear transformation produces different results
- **Population-averaged effects are attenuated** (closer to 0) compared to subject-specific effects

### The Estimating Equation

GEE solves:

$$\sum_{j=1}^n \mathbf{D}_j' \mathbf{V}_j^{-1}(\mathbf{y}_j - \boldsymbol{\mu}_j) = \mathbf{0}$$

Where:

- $\mathbf{D}_j = \frac{\partial \boldsymbol{\mu}_j}{\partial \boldsymbol{\beta}}$
- $\mathbf{V}_j = \phi \mathbf{A}_j^{1/2} \mathbf{R}(\alpha) \mathbf{A}_j^{1/2}$
  - $\mathbf{A}_j$ = Diagonal matrix of variances (depends on $\boldsymbol{\mu}_j$)
  - $\mathbf{R}(\alpha)$ = Working correlation matrix
  - $\phi$ = Dispersion parameter

### Key Features of GEE

#### 1. Robustness

**Coefficient estimates** ($\hat{\boldsymbol{\beta}}$) are **consistent** even if the working correlation structure is **misspecified**.

- You can be "wrong" about the correlation and still get valid estimates
- But: efficiency decreases with poor correlation choice
- Standard errors may be affected by misspecification

#### 2. Sandwich Estimator

Standard errors are calculated using a **robust "sandwich" estimator**:

$$\text{Var}(\hat{\boldsymbol{\beta}}) = \mathbf{M}_0^{-1} \mathbf{M}_1 \mathbf{M}_0^{-1}$$

Where:

- $\mathbf{M}_0$ = "Model-based" variance (assumes working correlation is correct)
- $\mathbf{M}_1$ = "Empirical" variance (based on observed residuals)

This makes standard errors **valid even with misspecified correlation** (given large sample size).

#### 3. Model Selection

- Use **QIC** (Quasi-Information Criterion) to compare models with different working correlations
- Lower QIC = better fit
- **Note**: Recent research (Westgate & Burchett, 2017) suggests QIC has limitations; better alternatives exist

### Common Working Correlation Structures

1. **Independence**: 
   - Assumes no correlation (conservative)
   - $\mathbf{R} = \mathbf{I}$
   
2. **Exchangeable**: 
   - Constant correlation (like compound symmetry)
   - $\rho_{ij} = \alpha$ for all $i \neq j$
   
3. **AR(1)**: 
   - Autoregressive correlation
   - $\rho_{ij} = \alpha^{|i-j|}$
   
4. **Unstructured**: 
   - Estimate all correlations (data-hungry)
   - Requires many parameters

### Practical GEE Interpretation Example

Consider GEE output for passing an exam:

```
Coefficients:
              Estimate  Std.err
(Intercept)    0.21      0.17
type          -0.11      0.13
female         0.63      0.17
type:female    0.10      0.19

Estimated Correlation Parameters:
       Estimate
alpha  0.248
```

**Interpretations**:

1. **Intercept (0.21)**: 
   - Averaged across all private schools, the log-odds of passing for male students is 0.21
   - Probability: $\frac{e^{0.21}}{1+e^{0.21}} = 0.55$

2. **Coefficient for female (0.63)**: 
   - **Population-averaged interpretation**: "Averaged across all schools, female students have $e^{0.63} = 1.88$ times the odds of passing compared to male students"
   - This is the **average effect** across the population, not within any specific school

3. **Alpha (0.248)**: 
   - The estimated within-school correlation of pass/fail outcomes is 0.248
   - Students within the same school have somewhat similar pass rates

4. **Comparing to GLMM**: 
   - The GEE female coefficient (0.63) is smaller than the GLMM coefficient (0.83)
   - This is expected: population-averaged effects are attenuated compared to subject-specific effects

### When to Use GEE vs GLMM?

**Use GEE when**:
- Research question is about population-average effects
- Want robust inference without strong distributional assumptions
- Large sample sizes
- Concerned about random effects distribution assumptions
- Primary interest is in fixed effects, not variance components

**Use GLMM when**:
- Research question is about subject-specific effects
- Want to estimate and explain between-cluster variance
- Need predictions for specific clusters
- Interested in how effects vary across clusters
- Smaller sample sizes (where GEE asymptotic properties may not hold)

\newpage

# Model Estimation and Hypothesis Testing

## Estimation Methods

### Maximum Likelihood (ML) vs. REML

**Restricted Maximum Likelihood (REML)**:

- Accounts for loss of degrees of freedom from estimating fixed effects
- Provides **unbiased** estimates of variance components
- **Default for continuous outcomes** in most software
- **Cannot be used** to compare models with different fixed effects
- Uses REML criterion = -2 × restricted log-likelihood

**Maximum Likelihood (ML)**:

- Does not account for DF loss
- Provides **biased** (downward) estimates of variance components
- **Better for testing fixed effects** using likelihood ratio tests
- **Can compare models** with different fixed effects
- Uses -2 × log-likelihood

**When to use which**:

- **REML**: 
  - Final model reporting
  - Testing variance components
  - When only variance components differ between models
  
- **ML**: 
  - Comparing models with different fixed effects
  - Testing fixed effects using LRT
  - Computing AIC/BIC for model selection

### Estimation in R

```r
# REML (default for lmer)
model_reml <- lmer(outcome ~ predictor + (1 | cluster), 
                   data = mydata, REML = TRUE)

# ML
model_ml <- lmer(outcome ~ predictor + (1 | cluster), 
                 data = mydata, REML = FALSE)

# For GLMMs, ML is default (no REML option)
glmm_model <- glmer(binary_outcome ~ predictor + (1 | cluster),
                    family = binomial, data = mydata)
```

## Hypothesis Testing

### Likelihood Ratio Tests (LRT)

**Basic Idea**: Compare nested models. Does the more complex model fit significantly better?

**Test Statistic**:

$$\text{LRT} = -2\log\left(\frac{L_{\text{reduced}}}{L_{\text{full}}}\right) = -2(\ell_{\text{reduced}} - \ell_{\text{full}})$$

Or equivalently:

$$\text{LRT} = (-2\ell_{\text{reduced}}) - (-2\ell_{\text{full}})$$

#### Testing Fixed Effects

**Procedure**:

1. Fit both models using **ML** (not REML)
2. Calculate difference in -2 log-likelihoods
3. Refer to $\chi^2$ distribution with $df = $ difference in number of parameters

**Example in R**:

```r
# Fit with ML
model_full <- lmer(outcome ~ pred1 + pred2 + (1 | cluster), 
                   data = mydata, REML = FALSE)
model_reduced <- lmer(outcome ~ pred1 + (1 | cluster), 
                      data = mydata, REML = FALSE)

# LRT
anova(model_reduced, model_full)

# Output interpretation:
# Model 1: outcome ~ pred1 + (1|cluster)
# Model 2: outcome ~ pred1 + pred2 + (1|cluster)
#         npar    AIC    BIC  logLik deviance  Chisq Df Pr(>Chisq)    
# Model1     4 11825  11849 -5908.5    11817                         
# Model2     5 11820  11850 -5905.0    11810  7.00  1    0.0082 **

# Interpretation: Adding pred2 significantly improves fit (p = 0.0082)
```

#### Testing Variance Components

**Special Case**: Testing if a variance = 0 (e.g., $H_0: \sigma^2_{u1} = 0$)

- Standard $\chi^2$ test is **conservative** (variances can't be negative)
- Use **mixture distribution**: $0.5 \times \chi^2(0) + 0.5 \times \chi^2(1)$
- Equivalently: $p = 0.5 \times P(\chi^2_1 > \text{LRT})$

**Procedure**:

1. Fit both models using **REML**
2. Calculate difference in REML criterion values
3. Compute p-value using mixture distribution

**Example in R**:

```r
# Model with random slopes
model_rs <- lmer(outcome ~ time + treatment + (1 + time | subject),
                 data = mydata, REML = TRUE)

# Model without random slopes
model_ri <- lmer(outcome ~ time + treatment + (1 | subject),
                 data = mydata, REML = TRUE)

# Manual LRT calculation
lrt_stat <- -2*(logLik(model_ri) - logLik(model_rs))

# P-value using mixture distribution
p_value <- 0.5 * (1 - pchisq(lrt_stat, df = 1)) + 
           0.5 * (1 - pchisq(lrt_stat, df = 2))

# Or use lmerTest package
library(lmerTest)
rand(model_rs)  # Mixture-based LRT

# Example output:
# REML criterion at convergence: 11811 (model with slopes)
# REML criterion at convergence: 11811 (model without slopes)
# LRT = 0, p-value = 1.0
# Conclusion: Do not include random slopes
```

**Interpretation from exam**:

If REML criteria are identical (both = 11811):
- LRT = 11811 - 11811 = 0
- p-value = 1.0
- **Cannot reject** null hypothesis that variance of random slopes = 0
- **Recommendation**: Do not include random slopes in the model

### Approximate t-tests

For testing individual fixed effects:

$$t = \frac{\hat{\beta}}{SE(\hat{\beta})}$$

**Challenges**:
- Degrees of freedom are approximate
- Several methods exist (Satterthwaite, Kenward-Roger)
- `lmerTest` package provides these automatically

**Example**:

```r
library(lmerTest)
model <- lmer(outcome ~ pred1 + pred2 + (1 | cluster), data = mydata)
summary(model)

# Output shows:
# Fixed effects:
#             Estimate Std. Error      df t value Pr(>|t|)    
# (Intercept)  49.327      1.099  71.000  44.883  < 2e-16 ***
# pred1        -0.278      0.920  71.000  -0.302    0.763    
# pred2        -2.518      0.876 1448.000  -2.876    0.004 ** 
```

### Approximate F-tests

For testing multiple parameters simultaneously (e.g., categorical predictor with multiple levels):

```r
library(lmerTest)
model <- lmer(outcome ~ factor(group) + (1 | cluster), data = mydata)

# Test overall effect of group
anova(model, type = "marginal")

# Output:
# Analysis of Variance Table of type marginal with Satterthwaite 
# approximation for degrees of freedom
#              Sum Sq Mean Sq NumDF DenDF F.value    Pr(>F)    
# factor(group)  1250   625.0     2    70  15.234 3.45e-06 ***
```

### Wald Tests (for GEE)

Since GEE doesn't have a likelihood, use **Wald tests**:

$$\text{Wald} = \frac{\hat{\beta}^2}{SE(\hat{\beta})^2}$$

For multiple parameters:

$$\text{Wald} = \hat{\boldsymbol{\beta}}' \text{Var}(\hat{\boldsymbol{\beta}})^{-1} \hat{\boldsymbol{\beta}}$$

**In R**:

```r
library(geepack)
gee_model <- geeglm(result ~ type + female + type*female,
                    id = school, family = binomial,
                    data = mydata, corstr = "exchangeable")

# Test overall effect of terms
anova(gee_model)

# Output:
# Analysis of 'Wald statistic' Table
#              Df  X2 P(>|Chi|)
# type          1  0.666  0.414
# female        1 14.388  0.000 ***
# type:female   1  0.285  0.593
```

## Information Criteria

Used to compare non-nested models or models with different correlation structures.

### AIC (Akaike Information Criterion)

$$\text{AIC} = -2\ell + 2p$$

Where:
- $\ell$ = log-likelihood
- $p$ = number of parameters

### BIC (Bayesian Information Criterion)

$$\text{BIC} = -2\ell + p \log(n)$$

Where:
- $n$ = sample size

**Properties**:
- BIC penalizes complexity more heavily than AIC
- Lower values indicate better fit
- Can compare models with different fixed effects or correlation structures
- Differences of 2-3 are considered meaningful

### QIC (Quasi-Information Criterion for GEE)

$$\text{QIC} = -2Q(\hat{\boldsymbol{\beta}}) + 2p$$

Where $Q$ is the quasi-likelihood.

**Usage**:
- Compare GEE models with different working correlation structures
- Lower QIC = better
- Note: Recent research suggests limitations

**Example**:

```r
# Compare models
model1 <- lmer(outcome ~ pred1 + (1|cluster), data = mydata, REML = FALSE)
model2 <- lmer(outcome ~ pred1 + pred2 + (1|cluster), data = mydata, REML = FALSE)

AIC(model1, model2)
BIC(model1, model2)

# Output:
#        df      AIC      BIC
# model1  4 11824.03 11848.77
# model2  5 11817.45 11847.62

# Model2 has lower AIC and BIC, suggesting better fit
```

\newpage

# Model Diagnostics

Model diagnostics are **critical** before interpreting results. Violations of assumptions can invalidate inference.

## Why Diagnostics Matter

- Tests and confidence intervals rely on distributional assumptions
- If assumptions are violated, p-values and CIs may be invalid
- Diagnostics can reveal:
  - Outliers
  - Non-normality
  - Heteroscedasticity
  - Model misspecification
  - Influential observations

## Key Diagnostic Checks

### 1. Residual Diagnostics

Check assumptions about $e_{ij} \sim N(0, \sigma^2_e)$

**What to examine**:
- Normality of residuals (Q-Q plot)
- Constant variance (residual vs. fitted plot)
- No patterns in residuals

**R Code**:

```r
# Fit model
model <- lmer(outcome ~ predictor + (1 | cluster), data = mydata)

# Extract residuals and fitted values
mydata$resid <- resid(model)
mydata$fitted <- fitted(model)

# Q-Q plot for normality
qqnorm(resid(model))
qqline(resid(model))

# Residual vs. fitted plot
plot(fitted(model), resid(model), 
     xlab = "Fitted Values", ylab = "Residuals",
     main = "Residual vs. Fitted Plot")
abline(h = 0, lty = 2)

# Using ggplot2
library(ggplot2)
ggplot(mydata, aes(x = fitted, y = resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(x = "Fitted Values", y = "Residuals",
       title = "Residual Diagnostic Plot")
```

**What to look for**:
- **Q-Q plot**: Points should fall on the line (indicates normality)
- **Residual plot**: 
  - Points should scatter randomly around zero
  - No funnel shape (would indicate heteroscedasticity)
  - No patterns or curves (would indicate model misspecification)

### 2. Random Effects Diagnostics

Check assumptions about $u_{0j} \sim N(0, \sigma^2_{u0})$

**Extract and plot EBLUPs** (Empirical Best Linear Unbiased Predictors):

```r
# Extract random effects (EBLUPs)
random_effects <- ranef(model)$cluster
names(random_effects) <- "intercept"

# Q-Q plot for random intercepts
qqnorm(random_effects$intercept, 
       main = "Q-Q Plot for Random Intercepts")
qqline(random_effects$intercept)

# Histogram
hist(random_effects$intercept, 
     main = "Distribution of Random Intercepts",
     xlab = "Random Intercept Values")

# Check for outliers
dotchart(random_effects$intercept, 
         labels = row.names(random_effects),
         main = "Random Intercepts by Cluster")
```

**What to look for**:
- Q-Q plot should show approximate normality
- Identify outlier clusters (extreme EBLUP values)
- These clusters may have undue influence on results

### 3. Checking for Influential Observations

**Influence diagnostics** identify observations or clusters that strongly affect results.

**For individual observations**:

```r
# Cook's distance (requires influence.ME package)
library(influence.ME)
infl <- influence(model, obs = TRUE)
plot(infl, which = "cook")
```

**For clusters**:

```r
# Cluster-level influence
infl_cluster <- influence(model, group = "cluster")
plot(infl_cluster, which = "cook")

# Identify influential clusters
influential <- which(infl_cluster$cook.d > 4/length(unique(mydata$cluster)))
```

### 4. Model Specification Checks

**Check linearity** of continuous predictors:

```r
# Component + residual plot
library(car)
crPlots(model)

# Or manually for MLMs
# Plot predictor vs. residuals + partial fit
mydata$partial <- resid(model) + coef(model)$predictor * mydata$predictor
plot(mydata$predictor, mydata$partial)
```

**Check for interactions**:

```r
# Interaction plots
interaction.plot(mydata$factor1, mydata$factor2, mydata$outcome)

# Or with ggplot2
ggplot(mydata, aes(x = continuous_pred, y = outcome, 
                   color = factor(categorical_pred))) +
  geom_smooth(method = "lm") +
  labs(title = "Checking for Interaction")
```

## Complete Diagnostic Workflow

```r
library(lme4)
library(ggplot2)
library(gridExtra)

# Fit model
model <- lmer(outcome ~ pred1 + pred2 + (1 | cluster), data = mydata)

# 1. Extract diagnostics
mydata$fitted <- fitted(model)
mydata$resid <- resid(model)
ranef_df <- as.data.frame(ranef(model)$cluster)
names(ranef_df) <- "intercept"

# 2. Create diagnostic plots
p1 <- ggplot(mydata, aes(sample = resid)) +
  stat_qq() + stat_qq_line() +
  labs(title = "Q-Q Plot: Residuals")

p2 <- ggplot(mydata, aes(x = fitted, y = resid)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted", x = "Fitted", y = "Residuals")

p3 <- ggplot(ranef_df, aes(sample = intercept)) +
  stat_qq() + stat_qq_line() +
  labs(title = "Q-Q Plot: Random Intercepts")

p4 <- ggplot(mydata, aes(x = fitted, y = sqrt(abs(resid)))) +
  geom_point(alpha = 0.5) +
  geom_smooth(se = FALSE) +
  labs(title = "Scale-Location Plot", x = "Fitted", y = "√|Residuals|")

# 3. Display all plots
grid.arrange(p1, p2, p3, p4, ncol = 2)

# 4. Summary statistics
cat("Residual Diagnostics:\n")
cat("Shapiro-Wilk test p-value:", shapiro.test(sample(resid(model), 5000))$p.value, "\n")
cat("\nRandom Effects Diagnostics:\n")
cat("Number of clusters:", nrow(ranef_df), "\n")
cat("Range of random intercepts:", range(ranef_df$intercept), "\n")
```

## What to Do When Assumptions Are Violated

1. **Non-normal residuals**:
   - Consider transformation of outcome (log, sqrt)
   - Use robust standard errors
   - Consider different distribution family (GLMM)

2. **Heteroscedasticity**:
   - Allow heterogeneous variance structure
   - Use `weights` argument in `lme()`

3. **Non-normal random effects**:
   - Less critical than residual normality
   - Consider removing outlier clusters
   - Perform sensitivity analysis

4. **Outliers/Influential observations**:
   - Investigate why they're outliers
   - Consider removing and refitting
   - Report sensitivity to outliers

\newpage

# Interpreting Interaction Terms

Interactions are when the effect of one predictor depends on the level of another predictor.

## Two Categorical Predictors

**Model**: `Y ~ X_cat * Z_cat`

**Equation**:
$$Y = \beta_0 + \beta_1 X + \beta_2 Z + \beta_3 (X \times Z) + error$$

**Interpretation**:

- $\beta_0$ = Mean of $Y$ when both $X=0$ and $Z=0$ (reference groups)
- $\beta_1$ = Effect of $X$ when $Z=0$ (reference level)
- $\beta_2$ = Effect of $Z$ when $X=0$ (reference level)
- $\beta_3$ = **Interaction**: Additional effect of $X$ when $Z=1$ (vs. $Z=0$)

**Example**: 

```
Outcome: written score
X = type (0=Private, 1=Public)
Z = female (0=Male, 1=Female)

Coefficients:
(Intercept)  49.33
type         -0.28
female       -2.52
type:female   0.13
```

**Four group means**:

1. Male, Private: $49.33$
2. Male, Public: $49.33 - 0.28 = 49.05$
3. Female, Private: $49.33 - 2.52 = 46.81$
4. Female, Public: $49.33 - 0.28 - 2.52 + 0.13 = 46.66$

**Gender gap**:
- In private schools: $-2.52$ points
- In public schools: $-2.52 + 0.13 = -2.39$ points
- The interaction (0.13) tells us the gender gap is 0.13 points smaller in public schools

## One Continuous and One Categorical Predictor

**Model**: `Y ~ X_cont * Z_cat`

**Interpretation**:

- **Intercept**: Value of $Y$ when $X_{cont}=0$ and $Z$ is at reference level
- **$X_{cont}$ coefficient**: Slope of $X_{cont}$ when $Z$ is at reference level
- **$Z_{cat}$ coefficient**: Difference in intercept between levels of $Z$, when $X_{cont}=0$
- **Interaction**: Difference in slope of $X_{cont}$ between levels of $Z$

**Visual representation**: Different slopes for different groups

## Two Continuous Predictors

**Model**: `Y ~ X_cont * Z_cont`

**Equation**:
$$Y = \beta_0 + \beta_1 X + \beta_2 Z + \beta_3 (X \times Z)$$

**Rearranging**:
$$Y = \beta_0 + (\beta_1 + \beta_3 Z) X + \beta_2 Z$$

**Key insight**: The slope of $X$ is now $(\beta_1 + \beta_3 Z)$, which depends on $Z$!

**Interpretation**:
- $\beta_3$ = For every one-unit increase in $Z$, the slope of $X$ changes by $\beta_3$
- The effect of $X$ on $Y$ is not constant—it depends on the level of $Z$

\newpage

# Ready-to-Use R Code Templates

## Template 1: Random Intercept Model for Continuous Outcome

```r
# ============================================
# RANDOM INTERCEPT MODEL - CONTINUOUS OUTCOME
# ============================================

# Load required packages
library(lme4)
library(lmerTest)  # For p-values
library(performance) # For ICC

# Load and prepare data
# mydata <- read.csv("your_data.csv")
# Check structure: str(mydata)
# Ensure cluster variable is factor: mydata$cluster <- factor(mydata$cluster)

# ----------------
# FIT MODEL
# ----------------
model1 <- lmer(outcome_var ~ predictor1 + predictor2 + 
               (1 | cluster_var),
               data = mydata,
               REML = TRUE)

# ----------------
# VIEW RESULTS
# ----------------
summary(model1)

# Extract variance components
VarCorr(model1)

# Calculate ICC
icc(model1)

# Or manually:
vc <- as.data.frame(VarCorr(model1))
icc_manual <- vc$vcov[1] / (vc$vcov[1] + vc$vcov[2])
cat("ICC =", icc_manual, "\n")

# ----------------
# HYPOTHESIS TESTS
# ----------------
# Test fixed effects
anova(model1, type = "marginal")

# ----------------
# MODEL DIAGNOSTICS
# ----------------
# Q-Q plot for residuals
qqnorm(resid(model1))
qqline(resid(model1))

# Residual vs. fitted plot
plot(fitted(model1), resid(model1))
abline(h = 0, lty = 2)


```
```r
qq_data <- ranef(model1)$cluster_var
qqnorm(qq_data[,1], main = "Q-Q Plot: Random Intercepts")
qqline(qq_data[,1])

# ----------------
# INTERPRETATION
# ----------------
# Extract fixed effects
fixef(model1)

# Extract random effects (EBLUPs)
head(ranef(model1)$cluster_var)

# Confidence intervals
confint(model1, method = "Wald")

# ----------------
# WRITE MODEL EQUATION
# ----------------
# Example output format:
# Y_ij = β0 + β1*X1_ij + β2*X2_ij + u_0j + e_ij
# where u_0j ~ N(0, σ²_u0) and e_ij ~ N(0, σ²_e)

# Get values for equation:
fe <- fixef(model1)
vc <- as.data.frame(VarCorr(model1))
cat("Y_ij =", fe[1], "+", fe[2], "* X1 +", fe[3], "* X2 + u_0j + e_ij\n")
cat("u_0j ~ N(0,", vc$vcov[1], ")\n")
cat("e_ij ~ N(0,", vc$vcov[2], ")\n")
```

## Template 2: Random Slope Model for Continuous Outcome

```r
# ============================================
# RANDOM SLOPE MODEL - CONTINUOUS OUTCOME
# ============================================

library(lme4)
library(lmerTest)

# ----------------
# FIT MODEL WITH RANDOM SLOPES
# ----------------
model2 <- lmer(outcome_var ~ time + treatment + time:treatment + 
               (1 + time | subject_id),
               data = mydata,
               REML = TRUE)

summary(model2)

# ----------------
# TEST IF RANDOM SLOPES ARE NEEDED
# ----------------
# Fit model without random slopes
model2_no_slope <- lmer(outcome_var ~ time + treatment + time:treatment + 
                        (1 | subject_id),
                        data = mydata,
                        REML = TRUE)

# Likelihood ratio test with mixture distribution
library(lmerTest)
rand(model2)  # Automatic mixture-based LRT

# OR manual calculation:
lrt_stat <- as.numeric(-2 * (logLik(model2_no_slope) - logLik(model2)))
p_value <- 0.5 * (1 - pchisq(lrt_stat, df = 1)) + 
           0.5 * (1 - pchisq(lrt_stat, df = 2))
cat("LRT statistic:", lrt_stat, "\n")
cat("P-value:", p_value, "\n")

# ----------------
# EXTRACT VARIANCE COMPONENTS
# ----------------
vc <- as.data.frame(VarCorr(model2))
print(vc)

# Variance of random intercepts
var_intercept <- vc$vcov[vc$grp == "subject_id" & vc$var1 == "(Intercept)"]
cat("Variance of random intercepts:", var_intercept, "\n")

# Variance of random slopes
var_slope <- vc$vcov[vc$grp == "subject_id" & vc$var1 == "time"]
cat("Variance of random slopes:", var_slope, "\n")

# Covariance between intercepts and slopes
cov_int_slope <- vc$vcov[vc$grp == "subject_id" & !is.na(vc$var2)]
cat("Covariance:", cov_int_slope, "\n")

# Correlation between intercepts and slopes
cor_int_slope <- vc$sdcor[vc$grp == "subject_id" & !is.na(vc$var2)]
cat("Correlation:", cor_int_slope, "\n")

# ----------------
# CALCULATE VARIANCE EXPLAINED
# ----------------
# Compare to model without Level-2 predictors
model2_empty <- lmer(outcome_var ~ time + (1 + time | subject_id),
                     data = mydata, REML = TRUE)

vc_empty <- as.data.frame(VarCorr(model2_empty))
vc_full <- as.data.frame(VarCorr(model2))

var_u0_empty <- vc_empty$vcov[1]
var_u0_full <- vc_full$vcov[1]

prop_explained <- (var_u0_empty - var_u0_full) / var_u0_empty
cat("Proportion of variance in intercepts explained:", prop_explained, "\n")

# ----------------
# DIAGNOSTICS
# ----------------
# Extract random effects
re <- ranef(model2)$subject_id

# Q-Q plot for random intercepts
qqnorm(re[,1], main = "Q-Q: Random Intercepts")
qqline(re[,1])

# Q-Q plot for random slopes
qqnorm(re[,2], main = "Q-Q: Random Slopes")
qqline(re[,2])

# Scatterplot of random intercepts vs slopes
plot(re[,1], re[,2], 
     xlab = "Random Intercepts", 
     ylab = "Random Slopes",
     main = "Random Effects")
abline(lm(re[,2] ~ re[,1]), col = "red")
```

## Template 3: Marginal Linear Model (GLS)

```r
# ============================================
# MARGINAL LINEAR MODEL - CONTINUOUS OUTCOME
# ============================================

library(nlme)

# ----------------
# FIT MARGINAL MODEL WITH COMPOUND SYMMETRY
# ----------------
marginal_cs <- gls(outcome_var ~ predictor1 + predictor2 + predictor1:predictor2,
                   correlation = corCompSymm(form = ~ 1 | cluster_var),
                   data = mydata,
                   method = "REML")

summary(marginal_cs)

# ----------------
# EXTRACT CORRELATION PARAMETER
# ----------------
# Get estimated correlation (rho)
rho <- coef(marginal_cs$modelStruct$corStruct, unconstrained = FALSE)
cat("Estimated correlation (rho):", rho, "\n")

# Get residual standard error
sigma <- marginal_cs$sigma
cat("Residual standard error:", sigma, "\n")

# ----------------
# CONSTRUCT VARIANCE-COVARIANCE MATRIX
# ----------------
# Diagonal elements (variance)
variance <- sigma^2
cat("Diagonal elements (variance):", variance, "\n")

# Off-diagonal elements (covariance)
covariance <- variance * rho
cat("Off-diagonal elements (covariance):", covariance, "\n")

# Example 4x4 V matrix
V_matrix <- matrix(c(variance, covariance, covariance, covariance,
                     covariance, variance, covariance, covariance,
                     covariance, covariance, variance, covariance,
                     covariance, covariance, covariance, variance),
                   nrow = 4, ncol = 4)
print(V_matrix)

# ----------------
# TRY DIFFERENT CORRELATION STRUCTURES
# ----------------
# AR(1) correlation
marginal_ar1 <- gls(outcome_var ~ predictor1 + predictor2 + predictor1:predictor2,
                    correlation = corAR1(form = ~ time | subject_id),
                    data = mydata,
                    method = "REML")

# Unstructured correlation
marginal_un <- gls(outcome_var ~ predictor1 + predictor2 + predictor1:predictor2,
                   correlation = corSymm(form = ~ 1 | cluster_var),
                   weights = varIdent(form = ~ 1 | time),
                   data = mydata,
                   method = "REML")

# ----------------
# COMPARE MODELS
# ----------------
AIC(marginal_cs, marginal_ar1, marginal_un)
BIC(marginal_cs, marginal_ar1, marginal_un)

# ----------------
# EQUIVALENCE CHECK WITH MLM
# ----------------
# Fit equivalent multilevel model
mlm_equivalent <- lmer(outcome_var ~ predictor1 + predictor2 + predictor1:predictor2 +
                       (1 | cluster_var),
                       data = mydata,
                       REML = TRUE)

# Compare coefficients
cat("\nMarginal model coefficients:\n")
print(coef(marginal_cs))

cat("\nMLM fixed effects:\n")
print(fixef(mlm_equivalent))

# Compare ICC
vc_mlm <- as.data.frame(VarCorr(mlm_equivalent))
icc_mlm <- vc_mlm$vcov[1] / sum(vc_mlm$vcov)
cat("\nICC from MLM:", icc_mlm, "\n")
cat("Rho from marginal model:", rho, "\n")
cat("These should be approximately equal!\n")

# ----------------
# DIAGNOSTICS
# ----------------
# Extract residuals
mydata$marginal_resid <- resid(marginal_cs, type = "normalized")
mydata$marginal_fitted <- fitted(marginal_cs)

# Q-Q plot
qqnorm(mydata$marginal_resid)
qqline(mydata$marginal_resid)

# Residual vs fitted
plot(mydata$marginal_fitted, mydata$marginal_resid)
abline(h = 0, lty = 2)
```

## Template 4: Logistic GLMM (Binary Outcome)

```r
# ============================================
# LOGISTIC GLMM - BINARY OUTCOME
# ============================================

library(lme4)
library(lmerTest)

# ----------------
# FIT LOGISTIC GLMM
# ----------------
glmm_logit <- glmer(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2 + 
                    (1 | cluster_var),
                    data = mydata,
                    family = binomial(link = "logit"),
                    nAGQ = 1)  # Laplace approximation (default)

# For better approximation with smaller samples:
glmm_logit_agq <- glmer(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2 + 
                        (1 | cluster_var),
                        data = mydata,
                        family = binomial(link = "logit"),
                        nAGQ = 7)  # More integration points

summary(glmm_logit)

# ----------------
# EXTRACT AND INTERPRET COEFFICIENTS
# ----------------
# Fixed effects (log-odds scale)
fe <- fixef(glmm_logit)
print(fe)

# Convert to odds ratios
odds_ratios <- exp(fe)
cat("\nOdds Ratios:\n")
print(odds_ratios)

# Confidence intervals
ci_log_odds <- confint(glmm_logit, method = "Wald")
ci_odds_ratios <- exp(ci_log_odds)
cat("\n95% CI for Odds Ratios:\n")
print(ci_odds_ratios)

# ----------------
# EXTRACT VARIANCE COMPONENT
# ----------------
vc <- as.data.frame(VarCorr(glmm_logit))
var_u0 <- vc$vcov[1]
cat("\nVariance of random intercepts:", var_u0, "\n")
cat("SD of random intercepts:", sqrt(var_u0), "\n")

# ----------------
# INTERPRET SPECIFIC COEFFICIENTS
# ----------------
# Example: For female coefficient = 0.83
female_coef <- fe["female"]
cat("\nInterpretation of 'female' coefficient:\n")
cat("Log-odds ratio:", female_coef, "\n")
cat("Odds ratio:", exp(female_coef), "\n")
cat("Interpretation: In a given cluster, females have", 
    round(exp(female_coef), 2), 
    "times the odds of success compared to males.\n")

# Example: Computing predicted probability
# For male in private school with u_0j = 0:
intercept <- fe["(Intercept)"]
log_odds <- intercept  # All other predictors = 0
prob <- exp(log_odds) / (1 + exp(log_odds))
cat("\nPredicted probability (baseline):", prob, "\n")

# With random effect u_0j = 0.13:
u0_example <- 0.13
log_odds_with_re <- intercept + u0_example
prob_with_re <- exp(log_odds_with_re) / (1 + exp(log_odds_with_re))
cat("Predicted probability (with u_0j = 0.13):", prob_with_re, "\n")

# ----------------
# TEST RANDOM EFFECTS
# ----------------
# Fit model without random effects (for comparison)
glm_no_re <- glm(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2,
                 data = mydata,
                 family = binomial)

# Compare using AIC
cat("\nAIC comparison:\n")
cat("GLMM with random effects:", AIC(glmm_logit), "\n")
cat("GLM without random effects:", AIC(glm_no_re), "\n")

# ----------------
# DIAGNOSTICS
# ----------------
# Extract random effects
re <- ranef(glmm_logit)$cluster_var
qqnorm(re[,1], main = "Q-Q Plot: Random Intercepts")
qqline(re[,1])

# Identify outlier clusters
outliers <- which(abs(re[,1]) > 2 * sd(re[,1]))
cat("\nOutlier clusters (|u_0j| > 2 SD):\n")
print(outliers)

# ----------------
# WRITE MODEL EQUATION
# ----------------
cat("\nModel Equation:\n")
cat("logit(P(Y_ij = 1)) = log(π_ij / (1-π_ij)) = \n")
cat("  ", fe[1], " + ", fe[2], "*X1 + ", fe[3], "*X2 + ", 
    fe[4], "*X1*X2 + u_0j\n")
cat("where u_0j ~ N(0,", var_u0, ")\n")

# ----------------
# SUBJECT-SPECIFIC INTERPRETATION NOTE
# ----------------
cat("\nIMPORTANT: These are SUBJECT-SPECIFIC (cluster-specific) effects.\n")
cat("They describe effects WITHIN a given cluster, controlling for the random effect.\n")
cat("For population-averaged effects, use GEE instead.\n")
```

## Template 5: GEE (Binary Outcome)

```r
# ============================================
# GEE - BINARY OUTCOME
# ============================================

library(geepack)

# ----------------
# FIT GEE MODEL
# ----------------
gee_logit <- geeglm(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2,
                    id = cluster_var,
                    family = binomial(link = "logit"),
                    data = mydata,
                    corstr = "exchangeable")

summary(gee_logit)

# ----------------
# TRY DIFFERENT CORRELATION STRUCTURES
# ----------------
# Independence
gee_indep <- geeglm(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2,
                    id = cluster_var,
                    family = binomial(link = "logit"),
                    data = mydata,
                    corstr = "independence")

# AR(1) - need time variable
gee_ar1 <- geeglm(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2,
                  id = cluster_var,
                  waves = time_var,
                  family = binomial(link = "logit"),
                  data = mydata,
                  corstr = "ar1")

# Unstructured
gee_unstr <- geeglm(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2,
                    id = cluster_var,
                    family = binomial(link = "logit"),
                    data = mydata,
                    corstr = "unstructured")

# ----------------
# COMPARE MODELS USING QIC
# ----------------
library(MESS)
qic_exch <- QIC(gee_logit)
qic_indep <- QIC(gee_indep)
qic_ar1 <- QIC(gee_ar1)

cat("QIC Comparison:\n")
cat("Exchangeable:", qic_exch, "\n")
cat("Independence:", qic_indep, "\n")
cat("AR(1):", qic_ar1, "\n")
cat("Lower QIC is better\n")

# ----------------
# EXTRACT AND INTERPRET COEFFICIENTS
# ----------------
# Fixed effects (log-odds scale)
coefs <- coef(summary(gee_logit))
print(coefs)

# Convert to odds ratios
odds_ratios <- exp(coefs[,1])
cat("\nOdds Ratios (Population-Averaged):\n")
print(odds_ratios)

# 95% CI for odds ratios
ci_lower <- exp(coefs[,1] - 1.96 * coefs[,2])
ci_upper <- exp(coefs[,1] + 1.96 * coefs[,2])
ci_table <- data.frame(
  Coefficient = rownames(coefs),
  OR = odds_ratios,
  CI_lower = ci_lower,
  CI_upper = ci_upper
)
print(ci_table)

# ----------------
# EXTRACT CORRELATION PARAMETER
# ----------------
alpha <- summary(gee_logit)$corr[1]
cat("\nEstimated within-cluster correlation (alpha):", alpha, "\n")

# ----------------
# HYPOTHESIS TESTS (WALD TESTS)
# ----------------
# Overall test for each term
anova(gee_logit)

# ----------------
# INTERPRETATION EXAMPLE
# ----------------
female_coef <- coefs["female", "Estimate"]
cat("\nPopulation-Averaged Interpretation:\n")
cat("Log-odds ratio for female:", female_coef, "\n")
cat("Odds ratio for female:", exp(female_coef), "\n")
cat("Interpretation: Averaged across all clusters,\n")
cat("  females have", round(exp(female_coef), 2), 
    "times the odds of success compared to males.\n")

# ----------------
# COMPARE TO GLMM
# ----------------
cat("\n=== COMPARING GEE TO GLMM ===\n")
cat("GEE coefficients are POPULATION-AVERAGED\n")
cat("GLMM coefficients are SUBJECT-SPECIFIC\n")
cat("\nFor non-linear models (logistic, Poisson):\n")
cat("- GLMM coefficients are LARGER in magnitude\n")
cat("- GEE coefficients are attenuated (closer to 0)\n")
cat("- This is expected and not an error!\n")

# Example comparison:
# Fit corresponding GLMM
glmm_compare <- glmer(binary_outcome ~ predictor1 + predictor2 + predictor1:predictor2 + 
                      (1 | cluster_var),
                      data = mydata,
                      family = binomial)

cat("\nFemale coefficient comparison:\n")
cat("GEE (population-averaged):", coefs["female", "Estimate"], "\n")
cat("GLMM (subject-specific):", fixef(glmm_compare)["female"], "\n")

# ----------------
# RESEARCH QUESTION GUIDANCE
# ----------------
cat("\n=== WHICH MODEL TO USE? ===\n")
cat("Use GEE when:\n")
cat("- Research question is about population-average effects\n")
cat("- 'What is the average effect across all clusters?'\n")
cat("- Want robust inference without distributional assumptions\n")
cat("\nUse GLMM when:\n")
cat("- Research question is about cluster-specific effects\n")
cat("- 'What happens within a given cluster?'\n")
cat("- Want to estimate between-cluster variance\n")
cat("- Need cluster-specific predictions\n")
```

## Template 6: Complete Analysis Workflow

```r
# ============================================
# COMPLETE ANALYSIS WORKFLOW
# ============================================

# ----------------
# STEP 0: SETUP
# ----------------
# Load all packages
library(lme4)
library(lmerTest)
library(nlme)
library(geepack)
library(performance)
library(ggplot2)

# Load data
# mydata <- read.csv("your_data.csv")

# Check data structure
str(mydata)
summary(mydata)

# Ensure proper variable types
mydata$cluster_var <- factor(mydata$cluster_var)
mydata$subject_var <- factor(mydata$subject_var)

# ----------------
# STEP 1: EXPLORATORY ANALYSIS
# ----------------
# Descriptive statistics by group
library(dplyr)
mydata %>%
  group_by(predictor1, predictor2) %>%
  summarise(
    n = n(),
    mean = mean(outcome, na.rm = TRUE),
    sd = sd(outcome, na.rm = TRUE)
  )

# Check clustering
table(mydata$cluster_var)
cluster_sizes <- mydata %>%
  group_by(cluster_var) %>%
  summarise(n = n())
summary(cluster_sizes$n)

# Visualize data
# For continuous outcome
ggplot(mydata, aes(x = predictor1, y = outcome, color = factor(predictor2))) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  facet_wrap(~ cluster_var) +
  labs(title = "Outcome by Predictors Across Clusters")

# For binary outcome
library(tidyr)
prop_data <- mydata %>%
  group_by(predictor1, predictor2) %>%
  summarise(prop = mean(binary_outcome, na.rm = TRUE))

ggplot(prop_data, aes(x = predictor1, y = prop, fill = factor(predictor2))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Proportion of Success by Predictors")

# ----------------
# STEP 2: FIT UNCONDITIONAL MODEL
# ----------------
# No predictors, just random intercept
model_empty <- lmer(outcome ~ 1 + (1 | cluster_var),
                    data = mydata,
                    REML = TRUE)

# Calculate ICC
icc(model_empty)

# Interpretation
cat("ICC indicates that", 
    round(icc(model_empty)$ICC_adjusted * 100, 1),
    "% of variance is between clusters\n")

# ----------------
# STEP 3: ADD LEVEL-1 PREDICTORS
# ----------------
model_level1 <- lmer(outcome ~ predictor1 + predictor2 + (1 | cluster_var),
                     data = mydata,
                     REML = TRUE)

# Compare to empty model
anova(model_empty, model_level1)

# How much variance explained?
vc_empty <- as.data.frame(VarCorr(model_empty))
vc_level1 <- as.data.frame(VarCorr(model_level1))

var_explained_within <- 1 - (vc_level1$vcov[2] / vc_empty$vcov[2])
cat("Level-1 predictors explain", 
    round(var_explained_within * 100, 1),
    "% of within-cluster variance\n")

# ----------------
# STEP 4: ADD LEVEL-2 PREDICTORS (if applicable)
# ----------------
model_level2 <- lmer(outcome ~ predictor1 + predictor2 + cluster_predictor + 
                     (1 | cluster_var),
                     data = mydata,
                     REML = TRUE)

var_explained_between <- 1 - (vc_level2$vcov[1] / vc_empty$vcov[1])
cat("Level-2 predictors explain", 
    round(var_explained_between * 100, 1),
    "% of between-cluster variance\n")

# ----------------
# STEP 5: ADD INTERACTIONS
# ----------------
model_interact <- lmer(outcome ~ predictor1 * predictor2 + (1 | cluster_var),
                       data = mydata,
                       REML = TRUE)

summary(model_interact)

# Test interaction
model_no_interact <- lmer(outcome ~ predictor1 + predictor2 + (1 | cluster_var),
                          data = mydata,
                          REML = FALSE)

model_interact_ml <- lmer(outcome ~ predictor1 * predictor2 + (1 | cluster_var),
                          data = mydata,
                          REML = FALSE)

anova(model_no_interact, model_interact_ml)

# ----------------
# STEP 6: CONSIDER RANDOM SLOPES
# ----------------
model_rs <- lmer(outcome ~ predictor1 * predictor2 + (1 + predictor1 | cluster_var),
                 data = mydata,
                 REML = TRUE)

# Test if random slopes needed
rand(model_rs)

# ----------------
# STEP 7: MODEL DIAGNOSTICS
# ----------------
# Choose final model
final_model <- model_interact  # Or whichever performed best

# Comprehensive diagnostics
par(mfrow = c(2, 2))

# 1. Q-Q plot for residuals
qqnorm(resid(final_model), main = "Q-Q: Residuals")
qqline(resid(final_model))

# 2. Residuals vs fitted
plot(fitted(final_model), resid(final_model),
     xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs Fitted")
abline(h = 0, lty = 2)

# 3. Q-Q plot for random effects
re <- ranef(final_model)$cluster_var
qqnorm(re[,1], main = "Q-Q: Random Effects")
qqline(re[,1])

# 4. Scale-location plot
plot(fitted(final_model), sqrt(abs(resid(final_model))),
     xlab = "Fitted", ylab = "√|Residuals|",
     main = "Scale-Location")

par(mfrow = c(1, 1))

# ----------------
# STEP 8: FINAL INTERPRETATION
# ----------------
summary(final_model)

# Extract key results
fe <- fixef(final_model)
vc <- as.data.frame(VarCorr(final_model))

cat("\n=== FINAL MODEL RESULTS ===\n")
cat("\nFixed Effects:\n")
print(fe)

cat("\nVariance Components:\n")
print(vc)

cat("\nICC:", icc(final_model)$ICC_adjusted, "\n")

# Write model equation
cat("\n=== MODEL EQUATION ===\n")
cat("Y_ij =", fe[1], "+", fe[2], "*X1 +", fe[3], "*X2 +",
    fe[4], "*X1*X2 + u_0j + e_ij\n")
cat("u_0j ~ N(0,", vc$vcov[1], ")\n")
cat("e_ij ~ N(0,", vc$vcov[2], ")\n")

# ----------------
# STEP 9: VISUALIZE RESULTS
# ----------------
# Predicted values with confidence intervals
newdata <- expand.grid(
  predictor1 = seq(min(mydata$predictor1), max(mydata$predictor1), length = 100),
  predictor2 = unique(mydata$predictor2)
)

newdata$predicted <- predict(final_model, newdata, re.form = NA)

ggplot(newdata, aes(x = predictor1, y = predicted, color = factor(predictor2))) +
  geom_line(size = 1) +
  labs(title = "Predicted Values from Final Model",
       y = "Predicted Outcome",
       color = "Predictor 2")

# ----------------
# STEP 10: REPORT RESULTS
# ----------------
# Create results table
library(broom.mixed)
results_table <- tidy(final_model, effects = "fixed")
print(results_table)

# Export results
# write.csv(results_table, "model_results.csv", row.names = FALSE)
```


