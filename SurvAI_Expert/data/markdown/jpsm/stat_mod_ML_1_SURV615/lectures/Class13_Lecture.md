---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class13_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class13_Lecture.pdf"
pages: 52
sha256: "bfcf33803a2c735cecfc2ab18ef972d72e0aabd6bc19866f5aad6a272e54ac92"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:16"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #13

John Kubale

November 26, 2024

<!-- page 2 -->

# Outline – Experimental Design and Analysis

* Exam 2
* Exam 3 and final class info
* Causal Inference
  * Experiments
  * Counterfactuals
* Randomized Experiment
  * Factorial Designs – One Factor
  * Analysis for Randomized One-Factor Experiments

<!-- page 3 -->

# Exam 2

* Grades should be posted today
* One thing I want to clarify:
  * If a question asks you to interpret the regression coefficients from a model you should interpret the regression coefficients from the model—**not just those where $p < 0.05$**

<!-- page 4 -->

# Exam 3

* Exam 3 will work largely the same as exams 1 and 2.
* It will become available at 12pm next Tuesday (12/3) after our final class.
* Will be **<u>due at 12pm</u>** the following Tuesday.
* Exam 3 will function the same as the prior exams:
  * On your own
  * Take home
  * Open note/open book
  * No AI or LLMs

<!-- page 5 -->

# Group evaluation

* Next week you will also be asked to submit group evals.
  * **<u>These are anonymous.</u>**
* It is a brief form that should be filled out for each of the 2 groups you completed homework assignments in.
* You must complete and submit this form for each group in order to receive full participation credit (5% of your grade).

<!-- page 6 -->

# Class next week

* We will have a little more material to go over—resampling and cross-validation methods.
* Will also have a final lab and quiz.
* Should also have time for a bit of review, so please let me know if there are any topics in particular you would like to discuss.

<!-- page 7 -->

# Causal Inference

<!-- page 8 -->

# Causal Relationship

* Cause: What produces an outcome (IV; Experimental factor [e.g., Treatment vs. Control; dosage)
* Effect: What is produced (DV; Outcome; [e.g., death, high blood pressure])
* **<u>Causation implies covariation AND causal mechanism</u>**
* **<u>Covariation alone is not enough to infer causation</u>**
* Spuriousness: Covariance without causation as causation
  * Waffle house density and divorce rate – confounded by age at marriage
  * Non-causal covariance: # of drownings $\xrightarrow{?}$ # of Nic Cage movies – covariance is common

<!-- page 9 -->

# Assessing causality

<!-- page 10 -->

# Counterfactual

* What would have happened if all exposed had been unexposed (and all unexposed had been exposed)?
* This is the counterfactual as it's counter to the fact of what actually happened
* Can we actually observe the counterfactual?

<!-- page 11 -->

# Counterfactual

* What would have happened if all exposed had been unexposed (and all unexposed had been exposed)?
* This is the counterfactual as it's counter to the fact of what actually happened
* Can we actually observe the counterfactual?

No, not without a time machine.

<!-- page 12 -->

So, what can we do to approximate a counterfactual?

<!-- page 13 -->

# Experiments

<!-- page 14 -->

# Logic of Causal Relationship and Logic of Experiments

* Causal relationship:
  * Cause must precede effect (i.e., temporality)
  * Cause is associated with the effect
  * No other plausible explanation for observed association
* Experiments:
  * Manipulate the exposure or treatment and observe what happens with outcome
  * Minimize possibility of other explanation(s) for effect
  * Variation in the cause is related to variation of effect

<!-- page 15 -->

# Logic of Causal Relationship and Logic of Experiments

* Causal relationship:
  * Cause must precede effect (i.e., temporality)
  * Cause is associated with the effect
  * No other plausible explanation for observed association
* Experiments:
  * Manipulate the exposure or treatment and observe what happens with outcome
  * **Minimize possibility of other explanation(s) for effect**
  * Variation in the cause is related to variation of effect

So, how do we do this without a time machine?

<!-- page 16 -->

# Exchangeability

* To minimize the potential for other explanations of the effect we ensure that the groups are “exchangeable”
* Differences between exposed and unexposed groups are only due to random error
* How do we accomplish this?
  * Design of study/experiment
  * Analytically (to a point)

<!-- page 17 -->

# Exchangeability

* To minimize the potential for other explanations of the effect we ensure that the groups are “exchangeable”
* Differences between exposed and unexposed groups are only due to random error
* How do we accomplish this?
  * **Design of study/experiment** $\longrightarrow$ Randomization is ideal if possible.
  * Analytically (to a point)

<!-- page 18 -->

# Structures in experimental design

* Treatment structure:
  * Set of treatments (or treatment combinations) to compare
  * How to structure treatments:
    * One-way vs. multi-way treatment structure
    * Interactions
    * Fixed vs. Random effects
    * Crossed vs. nested, etc.
* Design structure:
  * Grouping of experimental units into homogenous groups
  * How to assign experimental groups to treatments
    * Balanced vs. non-balanced
    * Randomization
    * Crossover, etc.

<!-- page 19 -->

# Structures in experimental design

* Treatment structure:
  * Set of treatments (or treatment combinations) to compare
  * How to structure treatments:
    * One-way vs. multi-way treatment structure
    * Interactions
    * Fixed vs. Random effects
    * Crossed vs. nested, etc.
* Design structure:
  * Grouping of experimental units into homogenous groups
  * How to assign experimental groups to treatments
    * Balanced vs. non-balanced
    * **Randomization**
    * Crossover, etc.

<!-- page 20 -->

# Experimental Designs – One factor

<!-- page 21 -->

# Types of one factor designs

Design 1: Basic Treatment vs. Control

| | | |
| :---: | :---: | :---: |
| R | $X$ | $O$ |
| R | | $O$ |

Design 2: Basic Comparing Multiple Treatment Conditions

| | | |
| :---: | :---: | :---: |
| R | $X_A$ | $O$ |
| R | $X_B$ | $O$ |
| R | $X_C$ | $O$ |

Design 3: Basic Comparing Multiple Treatments with Control

| | | |
| :---: | :---: | :---: |
| R | $X_A$ | $O$ |
| R | $X_B$ | $O$ |
| R | | $O$ |

Design 4: Pretest-Posttest Control Group

| | | | |
| :---: | :---: | :---: | :---: |
| R | $O_1$ | $X$ | $O_2$ |
| R | $O_1$ | | $O_2$ |

Design 5: Pretest-Posttest With Multiple Treatments

| | | | |
| :---: | :---: | :---: | :---: |
| R | $O_1$ | $X_A$ | $O_2$ |
| R | $O_1$ | $X_B$ | $O_2$ |
| R | $O_1$ | | $O_2$ |

<!-- page 22 -->

# Types of one factor designs

Randomization
Outcome observed
Treatment assigned

Design 1: Basic Treatment vs. Control

| | | |
|---|---|---|
| R | $X$ | $O$ |
| R | | $O$ |

Design 2: Basic Comparing Multiple Treatment Conditions

| | | |
|---|---|---|
| R | $X_A$ | $O$ |
| R | $X_B$ | $O$ |
| R | $X_C$ | $O$ |

Design 3: Basic Comparing Multiple Treatments with Control

| | | |
|---|---|---|
| R | $X_A$ | $O$ |
| R | $X_B$ | $O$ |
| R | | $O$ |

Design 4: Pretest-Posttest Control Group

| | | | |
|---|---|---|---|
| R | $O_1$ | $X$ | $O_2$ |
| R | $O_1$ | | $O_2$ |

Design 5: Pretest-Posttest With Multiple Treatments

| | | | |
|---|---|---|---|
| R | $O_1$ | $X_A$ | $O_2$ |
| R | $O_1$ | $X_B$ | $O_2$ |
| R | $O_1$ | | $O_2$ |

<!-- page 23 -->

# Common terminology in experiments

- Factorial design: every possible combination of treatment variables observed in the data
- Balanced design: the number in each treatment group is the same

<!-- page 24 -->

# Will often see these analyses discussed using ANOVA

<!-- page 25 -->

# What is ANOVA?

* ANOVA = analysis of variance
  * AKA regression model with categorical predictor(s)
  * In the lab you will fit models using lm(), aov(), and anova() showing that they are really doing the same thing
* ANOVA models make the same assumptions
  * Errors are Normal IID
  * Zero error mean
  * Constant error variance
  * Errors are normally distributed
* Diagnosis of assumption violations done in the same way
  * Scatterplots of residuals vs. fitted values, QQ-plots of residuals, etc.

<!-- page 26 -->

# One-way ANOVA

* Analyze $Y_{ij}$, the outcome for a unit $j$ assigned to condition $i$
  * for $i = 1, \dots, \alpha$ (i.e., there are $\alpha$ levels of treatment)
  * for $j = 1, \dots, n_i$ (i.e., there are $n_i$ units assigned to the $i^{th}$ treatment)
  * When $n_i = n \rightarrow$ “Balanced design”
* Cell means model: $Y_{ij} = \mu_i + \epsilon_{ij}$
  * $\mu_i$: Cell $i$ mean
* Effects model: $Y_{ij} = \mu + \alpha_i + \epsilon_{ij}$
  * $\mu$: Overall mean
  * $\alpha_i$: Treatment effects

<!-- page 27 -->

# One-way ANOVA

* Analyze $Y_{ij}$, the outcome for a unit $j$ assigned to condition $i$
  * for $i = 1, \dots, \alpha$ (i.e., there are $\alpha$ levels of treatment)
  * for $j = 1, \dots, n_i$ (i.e., there are $n_i$ units assigned to the $i^{th}$ treatment)
  * When $n_i = n \rightarrow$ “Balanced design”

* Cell means model: $Y_{ij} = \mu_i + \epsilon_{ij}$ $\longleftarrow$ Estimates mean for each treatment level, not overall mean
  * $\mu_i$: Cell $i$ mean

* Effects model: $Y_{ij} = \mu + \alpha_i + \epsilon_{ij}$ $\longleftarrow$ Estimates overall mean and the deviation each treatment from overall mean
  * $\mu$: Overall mean
  * $\alpha_i$: Treatment effects

<!-- page 28 -->

# One-way ANOVA

* One-way ANOVA tests the hypothesis:
  * $H_0: \alpha_1 = \alpha_2 = \dots = \alpha_a \text{ vs. } H_A: \text{At least one of the } a \text{ is different}$, or
  * $H_0: \mu_1 = \mu_2 = \dots = \mu_a \text{ vs. } H_A: \text{At least one of the } \mu \text{ is different}$

<!-- page 29 -->

# Pairwise Difference Tests

<!-- page 30 -->

# Pairwise difference tests with two-level treatment

* One factor (i.e., categorical predictor) with two levels
  * E.g., LDL cholesterol for no wine (*T*) vs. wine (*C*)
  * Hypothesis: ?

<!-- page 31 -->

# Pairwise difference tests with two-level treatment

* One factor (i.e., categorical predictor) with two levels
  * E.g., LDL cholesterol for no wine ($T$) vs. wine ($C$)
  * Hypothesis: $H_0: \mu_T = \mu_C \text{ vs. } H_A: \mu_T \neq \mu_C$
* How can we test this hypothesis?

<!-- page 32 -->

# Pairwise difference tests with two-level treatment

- One factor (i.e., categorical predictor) with two levels
  - E.g., LDL cholesterol for no wine ($T$) vs. wine ($C$)
  - Hypothesis: $H_0: \mu_T = \mu_C \text{ vs. } H_A: \mu_T \neq \mu_C$
- How can we test this hypothesis?
  - Series of tests covered in Class 2!
    - Known vs. unknown variance (Z vs. t tests)
    - Equal vs. unequal variance
    - Independent vs. dependent sample

<!-- page 33 -->

# Pairwise difference tests with >2 levels of treatment

* One factor with more than two levels
* E.g., LCL level for no wine ($A$), 2oz wine ($B$), and 4oz wine ($C$)
* Hypotheses: ?

<!-- page 34 -->

# Pairwise difference tests with >2 levels of treatment

* One factor with more than two levels
* E.g., LCL level for no wine (*A*), 2oz wine (*B*), and 4oz wine (*C*)
* Hypotheses:
  * $H_0: \mu_A = \mu_B \ vs. \ H_A: \mu_A \neq \mu_B$
  * $H_0: \mu_A = \mu_C \ vs. \ H_A: \mu_A \neq \mu_C$
  * $H_0: \mu_B = \mu_C \ vs. \ H_A: \mu_B \neq \mu_C$

<!-- page 35 -->

# Pairwise difference tests with >2 levels of treatment

* One factor with more than two levels
* E.g., LCL level for no wine (*A*), 2oz wine (*B*), and 4oz wine (*C*)
* Hypotheses:
  * $H_0: \mu_A = \mu_B \text{ vs. } H_A: \mu_A \neq \mu_B$
  * $H_0: \mu_A = \mu_C \text{ vs. } H_A: \mu_A \neq \mu_C$
  * $H_0: \mu_B = \mu_C \text{ vs. } H_A: \mu_B \neq \mu_C$

May also see written as:
$H_0: \mu_A - \mu_B = 0 \text{ vs. } H_A: \mu_A - \mu_B \neq 0$

<!-- page 36 -->

# Pairwise difference tests with >2 levels of treatment

* One factor with more than two levels
* E.g., LCL level for no wine (A), 2
* Hypotheses:
  * $H_0: \mu_A = \mu_B\ vs.\ H_A: \mu_A \neq \mu_B$
  * $H_0: \mu_A = \mu_C\ vs.\ H_A: \mu_A \neq \mu_C$
  * $H_0: \mu_B = \mu_C\ vs.\ H_A: \mu_B \neq \mu_C$

After seeing the hypotheses tested when the treatment has >2 levels, is there anything we need to consider?

<!-- page 37 -->

# Pairwise difference tests with >2 levels of treatment

* Multiple hypotheses!
  * Likelihood of erroneously rejecting correct null hypothesis ( Type 1 Error) increases
  * Have to account for this via correction:
    * Bonferroni correction
    * Tukey's honest significant difference test
    * False discovery rate

<!-- page 38 -->

# Randomized Multi-way Design Structure

<!-- page 39 -->

# Design Options with Multiple Factors - 1

Two treatment factors: $A$ and $B$

**Fully Crossed - $A \times B$**

| | | |
| :--- | :---: | :--- |
| R | $X_{A1B1}$ | $O$ |
| R | $X_{A1B2}$ | $O$ |
| R | $X_{A1B3}$ | $O$ |
| R | $X_{A2B1}$ | $O$ |
| R | $X_{A2B2}$ | $O$ |
| R | $X_{A2B3}$ | $O$ |

<!-- page 40 -->

# Design Options with Multiple Factors - 2

Three treatment factors: $A$, $B$, and $C$

### Fully Crossed - $A \times B \times C$

| | | |
|---|---|---|
| R | $X_{A1B1C1}$ | $O$ |
| R | $X_{A1B1C2}$ | $O$ |
| R | $X_{A1B2C1}$ | $O$ |
| R | $X_{A1B2C2}$ | $O$ |
| R | $X_{A2B1C1}$ | $O$ |
| R | $X_{A2B1C2}$ | $O$ |
| R | $X_{A2B2C1}$ | $O$ |
| R | $X_{A2B2C2}$ | $O$ |

<!-- page 41 -->

# Two-way Treatment Structure Models

<!-- page 42 -->

# Two-way ANOVA

Analysis of $Y_{ijk}$, where

$i = 1, \cdots, I$: levels in factor $A$

$j = 1, \cdots, J$: levels in factor $B$

$k = 1, \cdots, n_{ij}$: subjects assigned to the level $ij$ of combined factors $A$ and $B$

$\sum_{i=1}^I \sum_{j=1}^J n_{ij} = n_{\bullet\bullet}$: total sample size

$n_{ij} = n \to \text{Balanced design}$

$n_{ij} = 1 \to \text{No replication}$

$Y_{ijk}$ can be expressed with a cell means model and an effects model

<!-- page 43 -->

# Two-way ANOVA: Cell Means Model

Cell means model:

$$Y_{ijk} = \mu_{ij} + \epsilon_{ikk}$$

$\mu_{ij}$: Cell mean for $ij^\text{th}$ level of the combined factors $A$ and $B$

OLS estimator for $\mu_{ij}$:

$$\hat{\mu}_{ij} = \hat{\mu} + \hat{\alpha}_i + \hat{\beta}_j + \hat{\gamma}_{ij} = \frac{\sum_{k=1}^{n_{ij}} Y_{ijk}}{n_{ij}}$$

Assumes: $\epsilon_{ijk} \sim N(0, \sigma^2)$

<!-- page 44 -->

# Two-way ANOVA: Effects Model

Effects model:

* $Y_{ijk} = \mu + \alpha_i + \beta_j + \gamma_{ij}\epsilon_{ijk}$
  * $\mu$: Overall mean
  * $\alpha_i$: the main effect for $i^{th}$ level of factor A
    * $\sum_{i=1}^I \alpha_i = 0$
  * $\beta_j$: the main effect for $j^{th}$ level of factor B
    * $\sum_{j=1}^J \beta_j = 0$
  * $\gamma_{ij}$: the interaction effect between the $i^{th}$ level of factor A and the $j^{th}$ level of factor B
    * $\sum_{i=1}^I \gamma_{ij} = \sum_{j=1}^J \gamma_{ij} = 0$

<!-- page 45 -->

# Two-way ANOVA: Effects Model

* Assumes $\epsilon_{ijk} \sim N(0, \sigma^2)$
* If no interaction is expected, you can use:
  * $Y_{ijk} = \mu + \alpha_i + \beta_j + \epsilon_{ijk}$

Effects model:
* $Y_{ijk} = \mu + \alpha_i + \dots$
  * $\mu$: Overall me...
  * $\alpha_i$: the main ...
    * $\sum_{i=1}^I \alpha_i = 0$
  * $\beta_j$: the main effect for $j^{th}$ level of factor B
    * $\sum_{j=1}^J \beta_j = 0$
  * $\gamma_{ij}$: the interaction effect between the $i^{th}$ level of factor A and the $j^{th}$ level of factor B
    * $\sum_{i=1}^I \gamma_{ij} = \sum_{j=1}^J \gamma_{ij} = 0$

<!-- page 46 -->

# Fixed vs. random effects

<!-- page 47 -->

# Experimental Factor: Fixed vs. Random

* Fixed effect
  * $a$ fixed treatments specifically chosen by the experimenter
  * Conclusions apply only to the factor levels considered in the analysis
* Random effect
  * $a$ treatments randomly chosen from a larger populations of treatments
  * Conclusions extend to similar treatments not explicitly considered in the analysis

<!-- page 48 -->

# Fixed vs. Random Effects in One-Way Model

* $Y_{ij}$ with $i = 1, \dots, \alpha$ treatment levels and $j = 1, \dots, n_i$ subjects
* When the treatment levels in factor A include the entire population of all possible levels, or are selected purposely, A is a **fixed factor** (AKA fixed effect)
* When the treatment levels in factor A include a random sample from a population of all levels, A is a random factor (AKA random effect)
* These are different model specifications depending on the nature of A

<!-- page 49 -->

# Fixed vs. Random Effects Underlying Models

| $Y_{ij}$ under **fixed effects**: | $Y_{ij}$ under **random effects**: |
| :--- | :--- |
| $E(Y_{ij}) = \mu + \alpha_i$ | $E(Y_{ij}) = \mu \quad \because \alpha_i \sim N(0, \sigma_\alpha^2)$ |
| $V(Y_{ij}) = \sigma^2 = \sigma_\epsilon^2$ | $V(Y_{ij}) = \sigma^2 = \sigma_\alpha^2 + \sigma_\epsilon^2$ |
| $C(Y_{ij}, Y_{ij'}) = 0 \rightarrow \text{"Crossed"}$ | $C(Y_{ij}, Y_{ij'}) = \sigma_\alpha^2 \rightarrow \text{"Nested"}$ |
| $C(Y_{ij}, Y_{i'j'}) = 0$ | $C(Y_{ij}, Y_{i'j'}) = 0$ |
| $Cor(Y_{ij}, Y_{ij'}) = 0$ | $Cor(Y_{ij}, Y_{ij'}) = \frac{\sigma_\alpha^2}{\sigma_\alpha^2 + \sigma_\epsilon^2}$ |
| Interested in estimating $\alpha_i$ and/or differences in $\alpha_i$ | Interested in estimating variance components (i.e., contributions of $\sigma_\alpha^2$ and $\sigma_\epsilon^2$ in relation to $\sigma^2$) |

<!-- page 50 -->

# Fixed vs. Random Effects Underlying Models

| $Y_{ij}$ under **fixed effects**: | $Y_{ij}$ under **random effects**: |
| :--- | :--- |
| $E(Y_{ij}) = \mu + \alpha_i$ | $E(Y_{ij}) = \mu \quad \because \alpha_i \sim N(0, \sigma_\alpha^2)$ |
| $V(Y_{ij}) = \sigma^2 = \sigma_\epsilon^2$ | $V(Y_{ij}) = \sigma^2 = \sigma_\alpha^2 + \sigma_\epsilon^2$ |
| $C(Y_{ij}, Y_{ij'}) = 0 \rightarrow \text{"Crossed"}$ | $C(Y_{ij}, Y_{ij'}) = \sigma_\alpha^2 \rightarrow \text{"Nested"}$ |
| $C(Y_{ij}, Y_{i'j'}) = 0$ | $C(Y_{ij}, Y_{i'j'}) = 0$ |
| $Cor(Y_{ij}, Y_{ij'}) = 0$ | $Cor(Y_{ij}, Y_{ij'}) = \frac{\sigma_\alpha^2}{\sigma_\alpha^2 + \sigma_\epsilon^2}$ |
| Interested in estimating $\alpha_i$ and/or differences in $\alpha_i$ | Interested in estimating variance components (i.e., contributions of $\sigma_\alpha^2$ and $\sigma_\epsilon^2$ in relation to $\sigma^2$) |

This has important implications for the hypothesis being tested

<!-- page 51 -->

# Fixed vs. Random Effects ANOVA -1

ANOVA table with one-way treatment structure with balanced design:

**Fixed Effect**

| Source | $df$ | $E(MS)$ | $MS_{fixed}$ | $F$ |
| :--- | :---: | :---: | :---: | :---: |
| Treatments $A$ | $a - 1$ | $E(MS_A)$ | $\sigma_\epsilon^2 + \frac{1}{a-1} \sum_i n_i (\alpha_i - \bar{\alpha})$ | $\frac{MS_A}{MS_E}$ |
| Error | $na - a$ | $E(MS_E)$ | $\sigma_\epsilon^2$ | |
| Total | $na - 1$ | | | |

**Random Effect**

| Source | $df$ | $E(MS)$ | $MS_{random}$ | $F$ |
| :--- | :---: | :---: | :---: | :---: |
| Treatments $A$ | $a - 1$ | $E(MS_A)$ | $\sigma_\epsilon^2 + \frac{1}{a-1} (\sum_i n_i - \frac{\sum_i n_i^2}{\sum_i n_i}) \sigma_\alpha^2$ | $\frac{MS_A}{MS_E}$ |
| Error | $na - a$ | $E(MS_E)$ | $\sigma_\epsilon^2$ | |
| Total | $na - 1$ | | | |

<!-- page 52 -->

# Fixed vs. Random Effects ANOVA -2

ANOVA table with one-way treatment structure with balanced design:

**Fixed Effect**

Hypothesis tested with $F = \frac{MS_A}{MS_E}$

$H_0: \alpha_1 = \alpha_2 = \dots = \alpha_a$ vs. $H_A$: Not $H_0$

**Random Effect**

Hypothesis tested with $F = \frac{MS_A}{MS_E}$

$H_0: \sigma_\alpha^2 = 0$ (i.e., does $\sigma_\alpha^2$ play a role in $\sigma^2$?) vs. $H_A: \sigma_\alpha^2 > 0$
