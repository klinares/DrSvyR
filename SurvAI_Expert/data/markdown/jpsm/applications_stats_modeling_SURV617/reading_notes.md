---
id: "jpsm/applications_stats_modeling_SURV617/reading_notes"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "reading_notes"
original: "applications_stats_modeling_SURV617/reading_notes.pdf"
pages: 50
sha256: "68f2eae55e6059a98cf0916c6540c4decb047dbb0692a0fe16fd23a2ec4555b2"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:43"
---

<!-- page 1 -->

**For each assigned reading, create a 1-page summary addressing these key points:**

### 1. Core Methodology/Model (2-3 sentences)

* What statistical model or technique is the primary focus?
* What class of models does it belong to (multilevel, marginal, SEM, machine learning)?

### 2. Research Context & Application (2-3 sentences)

* What substantive or methodological problem does this address?
* What type of data structure is involved (clustered, longitudinal, complex survey)?

### 3. Key Technical Contributions (3-4 bullet points)

* Main statistical innovations or insights
* How this differs from standard approaches
* Specific assumptions or requirements
* Handling of special features (e.g., missing data, complex samples, interviewer effects)

### 4. Software Implementation (1-2 sentences)

* What software packages/procedures are mentioned?
* Any specific code examples or computational considerations?

### 5. Practical Implications (2-3 bullet points)

* When should this method be used vs. alternatives?
* Limitations or cautions for practitioners
* Connection to survey methodology applications

### 6. Key Equations/Notation (if applicable)

* Note essential model specifications or formulas
* Define critical notation for class use

### 7. Connection to Course Topics

* How does this relate to other readings or lectures this week?
* Which homework or project component might use this?

**Skip:** Background literature review, detailed proofs, extensive simulation details **Focus on:** Practical applications, model interpretation, and methodological insights relevant to survey data analysis

<!-- page 2 -->

**Merlo et al. (2005)** Multilevel Analysis in Social Epidemiology: A Conceptual Tutorial

## Core Methodology/Model

The primary focus is the **empty multilevel regression analysis (MLRA) model**, which partitions variance in health outcomes between individual and neighborhood levels without including any explanatory variables. This belongs to the class of **multilevel/hierarchical linear models**, specifically designed to handle nested data structures where individuals are clustered within higher-level units.

## Key Technical Contributions

• **Intraclass Correlation Coefficient (ICC) or Variance partitioning coefficient (VPC)::** Quantifies the proportion of total variance occurring at the neighborhood level (8% in the example), measuring how similar individuals within the same neighborhood are compared to those from different neighborhoods, denoted as $\text{p} = \text{between variance} / \text{between variance} + \text{within variance}$.

• **Shrunken residuals vs. raw residuals:** MLRA produces "shrunken" neighborhood residuals accounting for sampling uncertainty, important when neighborhoods have different sample sizes

• **Contextual phenomena measurement:** Provides a statistical framework for quantifying the epidemiological concept that people from the same area share common health determinants

## Practical Implications

• **Use when:** Investigating whether geographical or organizational boundaries are relevant for understanding health outcomes; as a preliminary step before adding predictors.

• **Key insight:** An ICC of 0.08 indicates appreciable clustering - 8% of individual differences occur at neighborhood level, justifying multilevel analysis over single-level approaches

• **Caution:** Low ICC doesn't necessarily mean context is unimportant - geographical boundaries may not align with relevant environmental influences, and small ICCs can still detect of contextual effects

## Connection to Course Topics

This reading provides the foundational understanding of **variance components models** essential for survey data with complex sampling designs. The concept of clustering and ICC directly relates to design effects in complex surveys, where observations within PSUs are correlated.

<!-- page 3 -->

**Gill and Womack 2013 The multilevel model framework**

## Core Methodology/Model

The primary focus is the **multilevel/hierarchical linear model framework**, which accounts for nested data structures where observations are grouped at multiple levels (e.g., students within schools, patients within hospitals). This class of models extends beyond simple linear regression by incorporating random effects to handle correlation within groups and allowing both fixed and random coefficients.

## Research Context & Application

This chapter addresses the fundamental challenge of analyzing **hierarchically structured data** common in social, educational, and health sciences where individual observations are naturally nested within higher-level units. The data structures involve multiple levels of aggregation, from simple two-level nesting (individuals within groups) to complex multi-level hierarchies (students in classrooms).

## Key Technical Contributions

• **Variance decomposition**: Separates total variance into components at each hierarchical level, quantifying the proportion of variation attributable to different levels of the hierarchy

• **Random intercepts and slopes models**: Progresses from models with varying intercepts only to those allowing both intercepts and slopes to vary across groups, capturing heterogeneity in both baseline levels and treatment effects

• **Model spectrum concept**: Introduces a continuum from fully pooled (ignoring groups) to fully unpooled (separate models per group), with multilevel models providing optimal "partial pooling"

• **Shrinkage estimation**: Produces "shrunken" residuals that borrow strength across groups, particularly important for groups with small sample sizes

## Practical Implications

• **Use when**: Data has natural hierarchical structure; ignoring clustering would violate independence assumptions and produce incorrect standard errors • **Key insight**: The shrinkage factor demonstrates how group-level estimates are pulled toward the overall mean, with the degree of shrinkage depending on group size and within-group variance • **Computational considerations**: Multilevel models are more demanding than standard regression; maximum likelihood estimates require iterative procedures and can be sensitive to starting values

## Key Equations/Notation

**Basic two-level model**: $y_{ij} = \beta_{0j} + x_{ij}\beta_{1j} + \varepsilon_{ij}$

* Where $\beta_{0j} = \beta_0 + u_{0j}$ (random intercept)
* And $\beta_{1j} = \beta_1 + u_{1j}$ (random slope)

<!-- page 4 -->

* $\varepsilon_{ij} \sim N(0, \sigma^2)$ and $u_j \sim N(0, \Omega_u)$

**Model estimate formula:** $\hat{\beta}_{0j} = (n_j/\sigma^2 * \bar{y}_j + 1/\sigma_0^2 * \bar{y}) / (n_j/\sigma^2 + 1/\sigma_0^2)$

* Shows how group estimates are weighted averages of group mean and overall mean

## Connection to Course Topics

This framework is fundamental for **analyzing complex survey data** where observations are clustered within primary sampling units (PSUs). The variance decomposition methods directly relate to calculating design effects in complex surveys. The concepts of random effects and shrinkage estimation connect to handling interviewer effects and area-level covariates in survey methodology. This framework underpins modern approaches to small area estimation and the analysis of multi-stage survey designs.

<!-- page 5 -->

**West & Galecki (2011) - Software Overview for LMMs**

**Core Methodology/Model** Linear Mixed Models (LMMs) for continuous dependent variables with both fixed and random effects. These belong to the multilevel/hierarchical model class, allowing for modeling of correlation structures in clustered or longitudinal data through explicit random effects.

**Research Context & Application** Addresses the practical challenge of selecting appropriate software for fitting LMMs given the proliferation of available procedures. Focuses on clustered and longitudinal datasets with potentially unbalanced designs or missing data.

**Key Technical Contributions**

* Comprehensive comparison of 15+ software packages across 5 critical implementation aspects (model specification, estimation, hypothesis testing, diagnostics, output)
* Identifies gaps in variance component testing - most packages lack appropriate null distributions for testing variance components on boundary of parameter space
* Documents sparse matrix implementation availability (critical for large datasets with crossed random effects)
* Shows limited implementation of survey weight incorporation - only HLM, MLwiN, Mplus, xtmixed, and gllamm handle complex survey designs correctly

**Software Implementation** Covers SAS (PROC MIXED, GLIMMIX, HPMIXED), R (lme, lmer, hglm), Stata (xtmixed, gllamm), SPSS, HLM, MLwiN, Mplus, among others. Notes that only HLM and MLwiN offer graphical model specification interfaces.

**Practical Implications**

* Use procedures with sparse matrix algorithms (lmer, HPMIXED, GENLINMIXED) for large datasets
* For variance component testing, rely on exactLRT() in R or recognize that standard LR tests are conservative
* Choose HLM, MLwiN, or Stata's gllamm for survey-weighted multilevel models

**Key Equations/Notation** Standard LMM notation: $Y = X\beta + Zb + \varepsilon$, where $b \sim N(0,D)$ and $\varepsilon \sim N(0,R)$

**Connection to Course Topics** Directly relevant for any multilevel analysis of survey data, particularly when dealing with complex sample designs or interviewer effects modeling.

<!-- page 6 -->

**Galecki & West (2011) - Software Chapter**

**Core Methodology/Model** Comprehensive treatment of multilevel models progressing from basic LMMs through GLMMs to nonlinear mixed models. Emphasizes the two-stage formulation common in longitudinal analysis.

**Research Context & Application** Provides practical guidance for implementing multilevel models across different software platforms, with focus on longitudinal data analysis and repeated measures designs typical in biomedical and social science research.

**Key Technical Contributions**

* Systematic organization of software by model complexity (LMM $\rightarrow$ GLMM $\rightarrow$ NLMM)
* Detailed implementation examples showing identical analyses across multiple platforms
* Emphasis on data organization requirements (long vs. wide format)
* Clear delineation between general-purpose statistical packages and specialized multilevel software

**Software Implementation** Provides detailed code examples for R/nlme, SAS/PROC MIXED, and discusses specialized packages like HLM, MLwiN, and newer developments in WinBUGS for Bayesian approaches.

**Practical Implications**

* Data must be in "long" format for most procedures (except HLM which can handle multiple files)
* R/nlme offers most flexibility for covariance structures but requires more programming knowledge
* HLM and MLwiN better for pedagogical purposes with graphical interfaces
* Consider WinBUGS for complex variance structures not available in standard software

**Key Equations/Notation** Two-stage formulation: Stage 1 (within-subject): $Y\_i = X\_i\beta\_i + \varepsilon\_i$ Stage 2 (between-subject): $\beta\_i = W\_i\gamma + b\_i$

**Connection to Course Topics** Essential reference for implementing interviewer effects models, analyzing complex survey data with clustering, and handling the practical aspects of model specification in homework assignments. The software comparison directly supports choosing appropriate tools for different survey data structures.

<!-- page 7 -->

---

## 1. Confidence intervals for the variance component of random-effects linear models

Citation

Bottai, M., & Orsini, N. (2004). Confidence intervals for the variance component of random-effects linear models. The Stata Journal, 4(4), 429–435.

---

### Study Guide

Main Points

This article introduces the Stata command xtvc, a tool for calculating more accurate confidence intervals for the variance components of random-effects linear models.

* **The Problem:** Standard confidence intervals for the variance of the random effect (

  ), like those from Stata's xtreg, mle command, can be asymptotically incorrect1. This is especially true when testing the hypothesis that the variance is zero (

  ), a common test for homogeneity across units2. This is known as a "boundary problem" because variance cannot be negative, which violates the assumptions of standard tests3333.

* **The Solution:** The authors created a post-estimation command, xtvc, that must be used after running xtreg, mle4. This command provides asymptotically correct confidence intervals for the variance components.

* **Methodology:** The xtvc command is based on the **inversion of a score-based test**. This method performs better than the standard likelihood-ratio test, particularly in models with a small number of groups (i.e., small samples)5.

* **Key Findings from Simulations:**

  * The

    xtvc command produces reliable confidence intervals that hold their nominal level (e.g., 95%) even with a small number of groups (as few as 10)6.

  * In contrast, the likelihood-ratio test provided by

    xtreg performs poorly in small samples and only becomes reliable when the number of groups is very large (e.g., a thousand or more)7.

  * The Wald-type confidence intervals provided by

<!-- page 8 -->

xtreg are wrong in both small and large samples and can even include negative values, which are impossible for a variance parameter8.

How to Use xtvc in Stata

1. First, fit your random-effects model using maximum likelihood estimation:

   xtreg your_outcome your_predictors, mle

2. Then, run the xtvc command:

   xtvc, level(95)

* **Key Options for xtvc:**

  * level(#): Specifies the confidence level percentage. The default is 959.
  * ho(#): Performs a score-based test for the null hypothesis that the standard deviation of the random effect (          ) is equal to a specific value (#). The default is 010.
  * Example:

    xtvc, ho(0.25) tests if           11.

Main Takeaway

When you need to make inferences about the variance components of a random-effects linear model, especially when testing for zero variance or when you have a small number of groups, the default output from xtreg is unreliable. Use the

xtvc command to obtain asymptotically correct and more trustworthy confidence intervals and hypothesis tests12.

---

## 2. Fitting multilevel models in complex survey data with design weights: Recommendations

Citation

Carle, A. C. (2009). Fitting multilevel models in complex survey data with design weights: Recommendations. BMC Medical Research Methodology, 9(49), 1–13. https://doi.org/10.1186/1471-2288-9-49

---

### Study Guide

<!-- page 9 -->

Main Points

This article provides practical recommendations for analysts using multilevel models (MLMs) with complex survey data that include **design weights** to account for unequal probabilities of selection.

* **The Problem:** Standard MLMs assume equal probability of selection. Failing to account for design weights in complex survey data can lead to

  **biased parameter estimates**13. However, simply including the "raw" weights in MLM software is also incorrect and leads to biased results, especially with small cluster sizes1414.

* **The Solution:** Design weights must be **scaled** before they can be correctly used in a multilevel model estimation15. The article focuses on two primary scaling methods.

* **Two Key Scaling Methods:**

  * **Method A:** Scales the level-1 weights so that their new sum within each cluster equals the **cluster sample size (**         **)**16161616. Simulation studies suggest this method is often best for

    **point estimates** (e.g., regression coefficients, odds ratios)17.

  * **Method B:** Scales the level-1 weights so that their new sum within each cluster equals the **effective cluster size**18181818. This method may be better for estimating

    **variance components** (e.g., between-cluster variance)19.

* **Best Practice Recommendations:** Since no single scaling method is always superior, the author recommends a comparative approach20:

  * Fit the MLM with **unweighted data**.

  * Fit the MLM using **Method A** scaled weights.

  * Fit the MLM using **Method B** scaled weights.

  * **Compare the results.** If the inferential conclusions (i.e., what is statistically significant) are the same across all three models, you can have more confidence in the findings21. If the conclusions diverge, a more detailed analysis, potentially involving simulations, is required to determine the best approach22.

* **Software Requirements:** To implement this approach, analysts need software that allows them to include pre-scaled weights without automatic modification.

  * **Recommended:** **Mplus**, **MLwiN**, and **GLLAMM** (in Stata) are suitable23.

  * **Not Recommended:** HLM and SAS MLM procedures are generally not suitable because they either do not allow pre-scaled weights or treat weights as

<!-- page 10 -->

frequency weights instead of sampling weights24.

* **Empirical Findings:** Using data from the National Survey of Children with Special Health Care Needs (NS-CSHCN), the author found that the unweighted and scaled-weighted analyses produced very similar results252525. This was likely due to the large cluster sizes (approx. 750 individuals per state) and a small intraclass correlation coefficient (ICC) in the data26. However, the author stresses that this will not always be the case, especially if weights are highly "informative" (correlated with the outcome), reinforcing the need to always compare the different methods27.

Main Takeaway

When fitting an MLM with complex survey data, do not ignore the design weights, but do not use them "raw". The best practice is to scale the weights using both Method A and Method B, run the analysis with each set of scaled weights as well as with no weights, and compare the substantive conclusions.

---

### 3. Analyzing Longitudinal Data With the Linear Mixed Models Procedure in SPSS

Citation

West, B. T. (2009). Analyzing longitudinal data with the linear mixed models procedure in SPSS. Evaluation & the Health Professions, 32(3), 207–228. https://doi.org/10.1177/0163278709338554

---

**Study Guide**

Main Points

This article serves as a practical, step-by-step guide for using the **Linear Mixed Models (LMMs)** procedure in SPSS to analyze longitudinal (repeated measures) data with continuous outcomes.

* Why Use LMMs over Repeated Measures ANOVA (rmANOVA)?

  LMMs offer several key advantages that make them more flexible and powerful for real-world longitudinal data28:

  * **Handles Missing Data:** LMMs use all available data for a subject, even if some time points are missing. In contrast, rmANOVA uses listwise deletion, dropping a subject entirely if even one data point is missing.

  * **Accommodates Unbalanced Data:** LMMs do not require all subjects to be measured at the same time points or have the same number of observations.

  * **Includes Time-Varying Covariates:** LMMs can model predictors whose values change over time (e.g., age), which rmANOVA cannot.

<!-- page 11 -->

* **Flexible Covariance Structures:** LMMs allow the analyst to choose from various structures to model how errors are correlated over time (e.g., AR(1), Unstructured), providing a better fit to the data.

* **Key Terminology:**
    * **Fixed Effects:** Standard regression coefficients that are assumed to be constant for the entire population (e.g., the effect of a treatment group)29.
    * **Random Effects:** Coefficients that are allowed to vary randomly across subjects. This allows each subject to have their own individual trajectory (e.g., their own intercept or slope for time). The model estimates the variance of these effects across the population of subjects30.

* **Required Data Structure:**
    * Data must be in a
    
      **"long" or "vertical" format**31. This means there is one row for each measurement occasion for each subject, rather than one row per subject with repeated measures in different columns [see Figure 1, source: 256].

* **Running the Analysis in SPSS:**
    * **Menu Path:** Analyze -> Mixed Models -> Linear...32.
    * **Key Dialog Boxes:**
        1. **Subjects:** Identify the variable that groups repeated measures (e.g., SUBJECT ID)33.
        2. **Repeated:** Identify the variable that indexes the repeated measures (e.g., AGE or TIME). Here, you select the
        
           **Repeated Covariance Type** for the errors (e.g., AR(1))34.
        3. **Fixed...:** Specify the fixed effects in the model (e.g., AGE, GENDER, and their interaction)35.
        4. **Random...:** Specify the random effects (e.g., a random intercept and a random slope for AGE for each SUBJECT). Here, you select the
        
           **Covariance Type** for the random effects (e.g., Unstructured)36.

* **Testing Variance Components (A Crucial Point):**
    * The Wald tests provided in the SPSS output for covariance parameters can be unreliable37.
    * A more appropriate method is the **Likelihood Ratio Test (LRT)**. This involves comparing the

<!-- page 12 -->

**-2 Restricted Log-Likelihood (-2 REML LL)** values of two nested models: a "full" model and a "reduced" model where the parameter of interest is removed38.

* When testing if a single variance component is zero (a "boundary" hypothesis), the p-value for the LRT statistic should be calculated as

when removing a random slope (which also removes a covariance term)39393939.

Main Takeaway

SPSS MIXED is a powerful and flexible procedure for analyzing longitudinal data. This article demystifies the process by providing a clear walkthrough of the menus and output, and crucially, it explains how to correctly perform hypothesis tests for variance components using likelihood ratio tests, which is more reliable than relying on the default Wald tests in the output.

---

### 4. Software for Fitting Multilevel Models

Citation

Gałecki, A. T., & West, B. T. (2011). Software for fitting multilevel models. In A. P. D. Boeck & M. van der Heijden (Eds.), Handbook of multilevel analysis. Springer. (Note: This citation is reconstructed from context. The provided text is Chapter 26 of a handbook).

---

**Study Guide**

Main Points

This chapter provides a comprehensive historical overview and a contemporary survey of the statistical software available for fitting various types of multilevel models: Linear Mixed Models (LMMs), Generalized Linear Mixed Models (GLMMs), and Nonlinear Mixed Models (NLMMs).

* **Historical Evolution of Software:**
  * Early software for longitudinal/clustered data, like repeated measures ANOVA, was very restrictive, requiring balanced data and no missing values40.
  * In the 1980s and 1990s, dedicated software for multilevel analysis emerged, including

    **HLM** and **MLwiN**, which became very popular in social sciences and education41.
  * General-purpose statistical packages later incorporated powerful procedures, such as

<!-- page 13 -->

**SAS/PROC MIXED** (introduced in 1992), which diminished the popularity of older software like BMDP/5V42.

* **Key Computational Challenge (GLMMs & NLMMs):**
  * For

    **LMMs**, the marginal likelihood can be expressed in a closed form, allowing for direct optimization using standard algorithms like Newton-Raphson43.
  * For **GLMMs and NLMMs**, the integral in the marginal likelihood does not have a closed-form solution. This requires computational methods to approximate the likelihood before optimization44444444.

* **Common Likelihood Approximation Methods for GLMMs/NLMMs:**
  * **Quasi-likelihood (MQL and PQL):** Simple to implement but known to produce biased estimates, especially for binary outcomes with large random effects45. Implemented in early versions of SAS/PROC GLIMMIX, HLM, and MLwiN46.
  * **Laplace Approximation:** An alternative deterministic approximation47.
  * **Adaptive Gaussian Quadrature (AGQ):** A more accurate but computationally intensive method. It is considered a substantial improvement over older methods. Implemented in

    **SAS/PROC NLMIXED** and the **gllamm** command in Stata48484848.

* **Bayesian Approach:**
  * The hierarchical structure of multilevel models makes them a natural fit for the Bayesian framework49.
  * Estimation relies on

    **Markov Chain Monte Carlo (MCMC)** methods, typically using a Gibbs sampler, to simulate the posterior distribution of the parameters50.
  * The primary software for this approach is

    **WinBUGS** (and its successor, OpenBUGS)51.

* **Overview of Current Software (see Tables 26.1, 26.2, 26.3):**
  * **General-Purpose Packages:**
    * **SAS:** PROC MIXED (LMM), PROC GLIMMIX (GLMM), PROC NLMIXED (NLMM)52.
    * **SPSS:** MIXED / GENLINMIXED53.
    * **Stata:** xtmixed (now mixed), gllamm54.
    * **R:** Packages nlme (lme, nlme) and lme4 (lmer, glmer, nlmer)55.

<!-- page 14 -->

* **Dedicated/Specialized Software:**
    * **HLM** and **MLwiN:** Widely used, strong in educational/social science research, offer graphical interfaces56.
    * **NONMEM** and **Monolix:** Leading software for NLMMs in pharmaceutical (PK/PD) studies57.
* **Software for More General Models (e.g., Latent Variable, SEM):**
    * **Mplus, LatentGold, LISREL:** Originally designed for latent variable/structural equation modeling but have added capabilities for fitting multilevel models58.

Main Takeaway

The landscape of software for multilevel models is diverse, ranging from specialized programs to procedures within major statistical packages. The choice of software depends on the type of model (LMM, GLMM, NLMM), model complexity (e.g., crossed random effects), estimation framework (frequentist vs. Bayesian), and user preference for syntax versus a graphical interface. For GLMMs and NLMMs, it is crucial to be aware of the underlying likelihood approximation method used by the software, as this can impact the accuracy of the results.

---

### 5. The Multilevel Model Framework

Citation

Gill, J., & Womack, A. J. (2013). The multilevel model framework. In M. A. Scott, J. S. Simonoff, & B. D. Marx (Eds.), The SAGE handbook of multilevel modeling (pp. 3–20). SAGE Publications Ltd. (Note: This citation is reconstructed from context. The provided text is Chapter 1 of a handbook).

---

**Study Guide**

Main Points

This chapter provides a conceptual introduction to multilevel models (also known as hierarchical models), explaining what they are, why they are needed, and how they are structured.

* **What is a Multilevel Model?**
    * A powerful extension of standard regression that explicitly accounts for
    
      **hierarchical or nested data structures** (e.g., students nested in classrooms, which are nested in schools)59.
    * It addresses the issue that individuals within the same group are often more similar to each other than to individuals in other groups, which violates the

<!-- page 15 -->

independence assumption of standard regression60. Ignoring this structure can lead to biased standard errors and incorrect statistical inferences61.

* **How Does it Work? The Core Idea:**
  * A multilevel model starts with a standard regression equation at the individual level (Level 1)62.
  * The key innovation is that some of the coefficients (intercepts or slopes) from the Level-1 model are not treated as fixed points but are themselves modeled as having a distribution.
  * A second regression equation (Level 2) is created to explain the variation in these Level-1 coefficients, using predictors measured at the group level63.
  * This creates a hierarchy of regression equations. Models with both fixed (unmodeled) and random (modeled) coefficients are called
    **"mixed models"**64.

* **Fundamental Model Forms:**
  * **Varying-Intercept (or Random-Intercept) Model:** The intercept (                ) is

    allowed to differ for each group                , while the slope remains the same for everyone. This accounts for baseline differences between groups65.
    * Level 1:
    * Level 2:

  * **Varying-Slope (or Random-Slope) Model:** The slope (                ) is allowed to

    differ for each group                , while the intercept is the same. This accounts for situations where the relationship between a predictor and the outcome differs across groups66.
  * **Varying-Intercept, Varying-Slope Model:** Both the intercept and the slope are allowed to vary across groups. This is the most flexible approach, modeling complex differences between groups67.

* **The Model Spectrum: Partial Pooling:**
  * Multilevel models represent a compromise between two extremes68:
    * **Complete Pooling:** Ignoring the group structure entirely and running a single regression. This assumes all groups are the same.

<!-- page 16 -->

* **No Pooling:** Running a separate regression for each group. This assumes the groups are completely unrelated.
  * Multilevel modeling is considered **partial pooling**. It estimates group-specific effects but "shrinks" these estimates toward the overall average, borrowing strength across groups. Groups with less data or more internal variability are shrunk more toward the overall mean69.
* **Extensions:**
  * **Nested Groupings:** The framework easily extends to more than two levels (e.g., students in classrooms in schools) by adding more levels to the hierarchy of equations70.
  * **Non-Nested (Cross-Classified) Groupings:** Models can handle situations where individuals belong to multiple, non-nested groups simultaneously (e.g., students classified by both their neighborhood and their school)71.
  * **Generalized Linear Forms:** The framework applies to non-normal outcomes (e.g., binary, count) by using a link function, creating Generalized Linear Mixed Models (GLMMs)72.

Main Takeaway

Multilevel models are a flexible and powerful tool for analyzing data with a hierarchical structure. By modeling coefficients as random variables and explaining their variation with group-level predictors, these models properly account for data dependency, avoid biased inferences, and provide a more nuanced understanding of how context shapes individual-level outcomes.

---

## 6. Specification of random effects in multilevel models: a review

Citation

Grilli, L., & Rampichini, C. (2015). Specification of random effects in multilevel models: a review. Quality & Quantity, 49(3), 967–976. https://doi.org/10.1007/s11135-014-0060-5

---

### Study Guide

Main Points

This article reviews the critical importance of correctly specifying the distribution of **random effects** in multilevel models. It discusses the consequences of misspecification, diagnostic tools, and more flexible modeling alternatives.

* Standard Assumptions for Random Effects:

  The usual assumptions for random effects (

<!-- page 17 -->

) are that they are73:

1. Independent across level-2 units.
2. Identically distributed (i.i.d.), meaning they have a constant variance (**homoscedasticity**).
3. Normally distributed, typically with a mean of zero (

   )74.
4. Independent of the covariates (

   **exogeneity**)75.

* **Consequences of Misspecification:**

  1. **Linear Models (LMMs):**

     * Estimates of

       **fixed effects** and **variance components** are generally robust and consistent even if the normality assumption is violated76.
     * However, **Empirical Bayes (EB) predictions** of the random effects can be seriously biased. This is a major issue in fields like school effectiveness, where ranking schools is a primary goal77.

  2. **Generalized Linear Models (GLMMs):**

     * The consequences are

       **more severe**78.
     * Misspecification (e.g., assuming normality when the true distribution is skewed) can lead to

       **seriously biased regression coefficients**, especially for level-2 covariates when the random effect variance is large79.
     * Estimates can also be biased if the random effects are

       **heteroscedastic** (i.e., have non-constant variance)80.

* **Diagnostic Tools for Checking Assumptions:**

  1. A common method is to create a

     **normal probability plot** of the Empirical Bayes (EB) residuals81.
  2. **Warning:** This tool has limitations. EB predictions tend to look normally distributed even when the underlying random effects are not, making it difficult to detect deviations from normality82828282.

<!-- page 18 -->

3. A promising newer tool is the

      **gradient function**, which can help identify where the assumed distribution is locally misspecified83.

* **Alternatives to Standard Assumptions (Flexible Modeling):**

   1. **Relaxing Independence:** Models can incorporate spatially correlated random effects for geographically adjacent units (e.g., neighboring schools)84.

   2. **Relaxing Homoscedasticity (Modeling Heteroscedasticity):** If the variance of the random effects differs across groups (e.g., public vs. private schools), one can fit models with stratum-specific random effects or model the variance as a function of covariates85.

   3. **Relaxing Normality:**

      * **Parametric Non-Normal Distributions:** Use a different continuous distribution, like a Student's t-distribution (robust to outliers) or a skewed distribution86.

      * **Finite Mixtures:** Model the random effects as coming from a mixture of several Gaussian distributions. This can capture multi-modal or skewed patterns87.

      * **Nonparametric Maximum Likelihood (NPML):** Model the distribution as an arbitrary discrete distribution (a set of mass points and probabilities), which is a very flexible approach88.

* **Bayesian Framework Considerations:**

   1. In Bayesian models, a prior is placed on the variance component (e.g., a Gamma prior on the precision).

   2. A common choice of prior (e.g., Gamma(0.001, 0.001)) implies a marginal distribution for the random effects that is a Student's t-distribution with very heavy tails, which may not be justifiable89. The authors suggest choosing priors that lead to more reasonable marginal distributions90.

Main Takeaway

The standard assumption of i.i.d. normal random effects is a strong one. While fixed effects in LMMs are quite robust to violations, inferences in GLMMs and EB predictions of random effects are sensitive to misspecification. Analysts should use diagnostic tools to check these assumptions and consider more flexible modeling approaches (e.g., modeling heteroscedasticity or using mixture models) when there is doubt. A sensitivity analysis, comparing results from a standard model with those from a more flexible one, is recommended as good practice91.

---

<!-- page 19 -->

## 7. An Evaluation of Model-Dependent and Probability-Sampling Inferences in Sample Surveys

Citation

Hansen, M. H., Madow, W. G., & Tepping, B. J. (1983). An evaluation of model-dependent and probability-sampling inferences in sample surveys. Journal of the American Statistical Association, 78(384), 776–793.

---

### Study Guide

Main Points

This foundational paper contrasts two major approaches to inference in sample surveys of finite populations: the **probability-sampling** (or design-based) approach and the **model-dependent** (or model-based) approach. The authors strongly advocate for the probability-sampling framework, especially for large-scale surveys.

* **Two Philosophies of Inference:**
  1. **Probability-Sampling (Design-Based) Inference:**
     * Inference is based on the known probabilities of selection that are part of the sampling plan (e.g., stratification, clustering)92.
     * Randomization is deliberately introduced into the sample selection process.
     * The goal is to use estimators that are

       **randomization-consistent**, meaning the estimator gets closer to the true population value as the sample size increases, regardless of the population's underlying structure93.
     * For large enough samples, the validity of inferences (e.g., confidence intervals) does

       **not** depend on an assumed model about the data94.

  2. **Model-Dependent (Model-Based) Inference:**
     * Inference relies on an assumed statistical model (a "superpopulation" model) that is believed to have generated the finite population values95.
     * Randomization in sample selection is not considered essential for inference; the properties of the estimator are derived from the model, not the sampling design96.
     * The goal is to find the "best" estimator under the assumed model (e.g., Best Linear Unbiased Estimator - BLUE)97.

<!-- page 20 -->

* The validity of inferences

    **depends critically** on the correctness of the assumed model98.

* **The Core Argument and Debate:**
    1. **Model-based advocates** argue that once the sample is drawn, the selection probabilities are irrelevant. They believe assuming a model and using the "best" estimator for it is the most efficient approach99.
    2. **The authors (design-based advocates)** argue that relying on a model is risky. If the model is wrong (a "model failure"), the estimators can be severely biased, and the estimated variances can be misleadingly small, leading to incorrect confidence intervals100.
    3. They contend that modeling is an important tool for

        **designing** a probability sample (e.g., for optimal allocation), but **inference** should be based on the randomization of the design itself, providing protection against model failure101.

* **Illustrative Example (Retail Store Sales):**
    1. The authors create a hypothetical population of retail stores where sales ( ) are related to employment ( ), but the relationship is not a perfect straight line through the origin ( )102.
    2. A

        **probability-sampling approach** uses a stratified sample with higher sampling rates for larger stores and a weighted ratio estimator that accounts for these unequal probabilities103.

    3. A **model-dependent approach** might assume a simpler model (e.g., ) which looks plausible from the sample data. This leads to an unweighted ratio estimator104.
    4. **Results:**
        * The probability-sampling estimators have negligible bias, even in small samples105.
        * The model-dependent estimators are

            **substantially biased**, and this bias does not decrease as the sample size grows106.

<!-- page 21 -->

* The variance estimates from the model-dependent approach fail to account for this bias, leading to confidence intervals that have much lower coverage than the nominal level (e.g., much less than 95%)107.
* **The Problem with "Balanced" Samples:**
    1. Model-based proponents suggest using "balanced samples" (where the sample mean of an auxiliary variable equals the population mean) to achieve robustness.
    2. The authors show that while balancing can reduce bias for

        *some* model-based estimators, it can increase bias for others and prevents the use of more efficient designs like optimal allocation108.

Main Takeaway

For large-scale surveys, especially those used for public policy and general use, the probability-sampling approach is superior because it provides a safeguard against model failure. While model-dependent inference can be more efficient if the model is perfectly correct, the risk of substantial, unmeasured bias from even minor model misspecification is too great. The randomization inherent in a probability-sampling design provides the basis for objective and robust inferences.

---

## 8. Interpretation of fixed effects in linear mixed models and generalized linear mixed models

Citation

Zhu, M. (2018, October 5). Interpretation of fixed effects in linear mixed models and generalized linear mixed models [Lecture notes]. SurvMeth 687/Surv 617, University of Maryland.

---

**Study Guide**

Main Points

This document clarifies the interpretation of fixed-effect regression coefficients ( &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ) in two types of multilevel models: the Linear Mixed Model (LMM) and the Generalized Linear Mixed Model (GLMM), highlighting a critical difference between them.

* **Linear Mixed Models (LMMs) for Normal Outcomes:**

<!-- page 22 -->

* **Model Form:** A random intercept model is expressed as , where the random intercept is .

* **Key Idea:** In an LMM, the conditional expectation (given a specific individual's random effect ) and the marginal expectation (averaged over all individuals' random effects) have the same form for the fixed effects.
    * Conditional Mean:
    * Marginal Mean:

* **Interpretation of (Fixed Effects): Population-Averaged**
    * A coefficient like represents the change in the **average response** for a one-unit change in the corresponding covariate (age), holding other covariates constant.
    * This interpretation applies to **subgroups of the population.** For example, is the difference in the average outcome between men with a BMI of 22 who are $x+1$ years old and men with a BMI of 22 who are $x$ years old.
    * Because the conditional and marginal models have the same form, the interpretation is straightforward and analogous to ordinary linear regression. The effect is an average effect across the entire population.

* **Generalized Linear Mixed Models (GLMMs) for Non-Normal Outcomes (e.g., Logistic):**
    * Model Form: A random intercept logistic model is expressed on the log-odds scale:

      $$\text{logit}\{P(Y_{ij}=1|\beta_i, X_{ij})\}=\beta_i+\beta_1\text{gender}_i+\beta_2\text{age}_{ij}+\dots$$

    * **Key Idea:** Unlike LMMs, the presence of a **non-linear link function** (like the logit) means that the interpretation of the fixed effects is conditional on the random effects. Averaging over the random effects (marginalizing) changes the form of the model and attenuates the coefficients.
    * **Interpretation of (Fixed Effects): Subject-Specific**

<!-- page 23 -->

* A coefficient like represents the change in the **log-odds** of a positive response for a one-unit change in the corresponding covariate (age) for **one particular individual**, holding that individual's random effect ( ) constant.
* It is a **within-individual** comparison. For example, it compares the log-odds of success for *Individual i* when their age is x+1 versus when their age was x.
* This is fundamentally different from a standard logistic regression (without random effects), where the coefficient represents a population-averaged effect (comparing different groups of people).

The Crucial Distinction

* **LMM Coefficients ( ):** Have a **population-averaged** interpretation. They describe the average change in the outcome for a subgroup of the population.
* **GLMM Coefficients ( ):** Have a **subject-specific** (or cluster-specific) interpretation. They describe the expected change in the transformed outcome for a specific individual (or cluster) as their own covariates change, holding their unique random effect constant.

Main Takeaway

While the syntax for specifying fixed effects in LMMs and GLMMs is often identical, their interpretation is not. The coefficients in an LMM can be interpreted at the population level, just like in ordinary least squares regression. However, due to the non-linear link function in GLMMs, the fixed effects coefficients have a subject-specific interpretation, representing the effect of a predictor *within* a given subject or cluster. These are not population-averaged effects and should not be interpreted as such.

---

### 9. Sufficient Sample Sizes for Multilevel Modeling

Citation

Maas, C. J. M., & Hox, J. J. (2005). Sufficient sample sizes for multilevel modeling. Methodology: European Journal of Research Methods for the Behavioral and Social Sciences, 1(3), 86–92.

---

**Study Guide**

<!-- page 24 -->

Main Points

This article uses a simulation study to investigate what constitutes a sufficient sample size for obtaining accurate estimates in two-level multilevel regression models. It specifically examines the influence of the number of groups (level-2 sample size) and the group size (level-1 sample size).

* **The Research Question:** How many groups (e.g., schools) and how many individuals per group (e.g., students) are needed to get reliable results from a multilevel model? The primary concern in multilevel analysis is often the

  **number of groups**, which is typically smaller and more expensive to increase than the number of individuals within groups109.

* **Simulation Design:** The study simulated data for a two-level random-intercept, random-slope model under various conditions:

  * **Number of Groups (Level 2):** 30, 50, 100.
  * **Group Size (Level 1):** 5, 30, 50.
  * **Intraclass Correlation (ICC):** 0.1, 0.2, 0.3.

* **Key Findings:**

  * **Fixed Effects (Regression Coefficients):**

    * The estimates of the regression coefficients are generally

      **unbiased**, even with a small number of groups (e.g., 30)110.

    * The standard errors for the regression coefficients are also estimated accurately across all simulated conditions. The confidence interval coverage is close to the nominal 95% level111.

  * **Random Effects (Variance Components):**

    * The estimates of the variance components themselves are also generally

      **unbiased**112.

    * The **standard errors** of the second-level (group-level) variance components are the most problematic aspect. They tend to be

      **underestimated (biased downward)** when the number of groups is small113.

      * With **30 groups**, the standard errors for the level-2 variances were underestimated by about 15%. This resulted in a non-coverage rate for the 95% confidence interval of around 9%, instead of the nominal 5%114.
      * With

<!-- page 25 -->

**50 groups**, the underestimation was smaller (about 9%), with a non-coverage rate of around 7.3%115. This is still different from the nominal 5% but may be acceptable in practice.

        * With

          **100 groups**, the standard errors were accurate116.

    * **What if the Number of Groups is *Very* Small?**

        * An additional simulation with only **10 groups** showed poor results:

            * The regression coefficients were still unbiased.

            * However, the group-level variance components were severely

              **overestimated** (up to 25% bias)117.

            * The standard errors for both fixed and random effects were underestimated, leading to unacceptable confidence interval coverage118. The authors conclude that

              **10 groups is not enough**.

* **Influence of Other Factors:**

    * **Group Size (Level 1):** Increasing the number of individuals per group had a smaller effect on the accuracy of the estimates than increasing the number of groups119.

    * **ICC:** The size of the intraclass correlation did not have a significant effect on the accuracy of the estimates or their standard errors in this study120.

Recommendations and Main Takeaway

* For estimating **fixed effects** (regression coefficients), a small number of groups (e.g., 30) is often sufficient to obtain unbiased estimates and accurate standard errors.

* For accurately estimating the **standard errors of the variance components**, a larger number of groups is necessary. The authors' results suggest:

    * **30 groups:** Leads to downwardly biased standard errors for variances.

    * **50 groups:** The bias is smaller and may be acceptable.

    * **100 groups:** Provides accurate standard error estimates for variances.

* **The number of groups is generally more critical than the number of individuals per group.**

The main practical takeaway is that if your primary interest is in the fixed effects, you may be safe with 30-50 groups. However, if you need to make accurate inferences about the variance components themselves (e.g., testing if there is significant variation between schools), you should aim for a larger number of groups, ideally 100 or more.

<!-- page 26 -->

---

## 10. Misspecifying the Shape of a Random Effects Distribution: Why Getting It Wrong May Not Matter

Citation

McCulloch, C. E., & Neuhaus, J. M. (2011). Misspecifying the shape of a random effects distribution: Why getting it wrong may not matter. Statistical Science, 26(3), 388–402.

---

### Study Guide

Main Points

This article challenges the common concern that assuming a normal distribution for random effects in generalized linear mixed models (GLMMs) is a risky practice. The authors argue that for many common inferential goals, results are surprisingly **robust** to misspecification of the random effects distribution shape.

* **The Problem:** GLMMs typically assume that random effects follow a normal distribution for computational convenience. However, this assumption may be unrealistic. There is significant disagreement in the literature about how sensitive GLMM inferences are to this assumption121.
* **The Key Argument:** The importance of correctly specifying the random effects distribution **depends on the inferential goal**. The authors break down the analysis into several common goals and assess the impact of misspecification on each.
* **Impact of Misspecification on Different Inferential Goals:**
  1. **Estimating Effects of Within-Cluster Covariates:**
     * This is often the primary reason for using longitudinal or clustered data.
     * **Conclusion: Highly Robust.** Inferences about within-cluster covariates (e.g., the effect of time in a longitudinal study) are virtually unaffected by misspecifying the shape of the random effects distribution122. Both theoretical work and simulations show little to no bias or loss of efficiency123.
  2. **Estimating Effects of Between-Cluster Covariates:**
     * **Conclusion: Largely Robust.** While one might expect more sensitivity here, studies show that bias is generally not an issue124. Some loss of efficiency can occur, but typically only when the true distribution is extremely non-normal (e.g., a two-point discrete distribution)125. The degree of robustness is similar to that of a standard t-test to non-normality126.
  3. **Estimating the Intercept:**

<!-- page 27 -->

* **Conclusion: Sensitive.** Misspecifying the random effects distribution (e.g., assuming normality when it's skewed) can introduce moderate to large bias in the estimate of the intercept127. This also affects predictions of the mean outcome for a fixed set of covariates.

**4. Estimating the Random Effects Variance ( ):**

* **Conclusion: Relatively Robust.** Research shows little effect on the estimation of the random effects variance, with asymptotic relative bias typically being 15% or less128.

**5. Prediction of Random Effects ( ):**

* **Performance (Mean Squared Error of Prediction): Largely Robust.** The overall accuracy of the predicted random effects is not very sensitive to the assumed distribution, except in extreme cases129.
* **Shape of the Distribution of Predicted Values: Sensitive.** The distribution of the *predicted* random effects tends to mimic the *assumed* distribution, not the *true* underlying one130. This is a critical point:

  **you cannot use a histogram or Q-Q plot of the predicted random effects to diagnose the correctness of your distributional assumption.**

* **Simulation and Example Findings:**
  1. A simulation study using a highly skewed and heavy-tailed Tukey(g, h) distribution as the true random effects distribution confirmed the theoretical arguments. Fitting a model that incorrectly assumed normality resulted in:
     * Almost no bias for the within-cluster effect.
     * Modest bias (<5%) for the between-cluster effect.
     * Modest bias (<10%) for the intercept.
     * Very little loss of efficiency for all parameters131.
  2. An analysis of the HERS dataset showed that fitting logistic models with four very different random effects distributions (Normal, Exponential, Discrete, Tukey) produced very similar estimates for the regression coefficients, despite differences in model fit (log-likelihood)132.

Main Takeaway

Concerns about assuming a normal distribution for random effects in GLMMs are often overstated. For the most common goals—estimating covariate effects (especially within-cluster effects)—the results are highly robust. Significant sensitivity is primarily limited to

<!-- page 28 -->

estimating the intercept and assessing the shape of the random effects distribution itself. Therefore, while more flexible distributional assumptions are available, they may not be necessary for many standard analyses.

---

## 11. A brief conceptual tutorial of multilevel analysis in social epidemiology: linking the statistical concept of clustering to the idea of contextual phenomenon

### Citation

Merlo, J., Chaix, B., Yang, M., Lynch, J., & Råstam, L. (2005). A brief conceptual tutorial of multilevel analysis in social epidemiology: Linking the statistical concept of clustering to the idea of contextual phenomenon. Journal of Epidemiology & Community Health, 59(6), 443–449.

---

### **Study Guide**

#### Main Points

This article provides a conceptual, non-mathematical introduction to multilevel regression analysis (MLRA), with a special focus on its application in social epidemiology. It emphasizes the importance of **measures of variation** (like variances and the intraclass correlation) over traditional measures of association (like regression coefficients).

* **The Core Idea: Contextual Phenomenon and Clustering:**
  * **Contextual Phenomenon:** A core concept in social epidemiology, suggesting that the areas where people live (their context) influence their health, independent of their individual characteristics. People in the same neighborhood tend to be more similar to each other in health status than to people in other neighborhoods133.
  * **Clustering:** This is the statistical manifestation of a contextual phenomenon. If health outcomes are clustered within neighborhoods, it means that a portion of the total variation in health can be attributed to differences between neighborhoods134.
  * **Analogy:** The epidemiological concept of a **contextual phenomenon** is analogous to the statistical concept of **clustering**. Recognizing this link is key to using MLRA effectively in social epidemiology. Clustering is not just a statistical nuisance to be corrected; it is an important finding in itself135.
* **The "Empty" Multilevel Model:**
  * The simplest form of MLRA, this model contains **no explanatory variables**. Its sole purpose is to partition the total variance in an outcome into its different levels136.

<!-- page 29 -->

* For a two-level model (individuals in neighborhoods), the empty model separates the total variance into:

  1. **Between-Neighborhood Variance ( ):** How much the average health outcome varies from one neighborhood to another.

  2. **Within-Neighborhood Variance ( ):** How much individual health outcomes vary among people living in the same neighborhood.

* Equation: , where is the neighborhood-level residual

  (random effect) and is the individual-level residual. The variance of

  is and the variance of is .

* **The Intraclass Correlation Coefficient (ICC):**

  * The ICC (also called the Variance Partition Coefficient or VPC) is the most important output from an empty model137.

  * **Formula:**

  * **Interpretation:** The ICC quantifies the proportion of the total variance in the outcome that is found at the group (e.g., neighborhood) level. For example, an ICC of 0.08 means that

    **8% of the total individual differences** in the health outcome can be attributed to differences between neighborhoods138.

  * It also represents the correlation in the outcome for two randomly selected individuals from the same group. A high ICC indicates that neighborhoods are very important for understanding individual health differences.

* **"Shrunken" Residuals:**

  * MLRA produces "shrunken" residuals for each neighborhood. These are more reliable estimates of a neighborhood's true deviation from the overall mean than simple raw residuals (the difference between the neighborhood's sample mean and the overall sample mean)139.

  * **Shrinkage:** The model "shrinks" the raw residual towards zero, with the amount of shrinkage depending on the reliability of the neighborhood's sample mean. Neighborhoods with smaller sample sizes or high within-neighborhood variability are shrunk more140. These shrunken residuals are useful for ranking units like schools or hospitals.

<!-- page 30 -->

### Main Takeaway

Multilevel analysis is not just a statistical correction for dependent data; it's a powerful tool for quantifying the importance of context in social epidemiology. The **empty model** and the **ICC** are fundamental starting points for any multilevel analysis, as they directly measure the extent of the "contextual phenomenon" by showing how much of the total health variation in a population is attributable to group-level differences. This focus on variance decomposition provides unique insights that traditional measures of association cannot.

---

## 12. A simulation study of sample size for multilevel logistic regression models

### Citation

Moineddin, R., Matheson, F. I., & Glazier, R. H. (2007). A simulation study of sample size for multilevel logistic regression models. BMC Medical Research Methodology, 7(34), 1-10. https://doi.org/10.1186/1471-2288-7-34

---

### **Study Guide**

#### Main Points

This article uses simulation to investigate how sample size at both the individual (level 1) and group (level 2) levels affects the accuracy of estimates in **multilevel logistic regression models** (for binary outcomes). It extends previous work that focused mainly on linear models.

*   **Research Question:** What are the sufficient sample sizes (number of groups and individuals per group) needed to obtain reliable estimates in a two-level logistic regression model? The study also examines the influence of the **prevalence** of the outcome and the **intraclass correlation (ICC)**.
*   **Simulation Design:**
    *   A two-level logistic model with a random intercept and random slope was used.
    *   **Number of Groups:** 30, 50, 100.
    *   **Group Size:** 5, 30, 50.
    *   **ICC:** 0.04, 0.17, 0.38 (corresponding to random intercept variances of 0.13, 0.67, 2.0).
    *   **Outcome Prevalence:** Primarily ~30%, with additional simulations at 10% and 45%.
*   **Key Findings:**
    *   **Convergence:** The model was much more likely to fail to converge when the **group size was small ($n=5$)**, especially with only 30 groups141. Convergence

<!-- page 31 -->

improved significantly with larger group sizes and more groups142. Non-convergence was also a bigger problem with low (10%) prevalence143.

* **Bias in Fixed Effect Parameters (Regression Coefficients):**

    * Estimates were generally unbiased with

      **100 groups and a group size of 50 or more**144144144.

    * The bias was severe when the

      **group size was 5**, regardless of the number of groups145. For example, with 30 groups of size 5, biases for fixed effects reached up to 16%146.

    * Bias was worse for **low-prevalent outcomes (10%)**. This suggests low prevalence requires larger sample sizes to get accurate estimates147.

* **Bias in Random Effect Parameters (Variance Components):**

    * Estimates were slightly biased even with 100 groups and a group size of 50148148.

    * With a group size of 5, the variance components were

      **severely overestimated** (some biases exceeded 100%)149.

    * With group sizes of 30 or more, the variance components were consistently

      **underestimated**150, a finding similar to studies on linear models.

* **Accuracy of Standard Errors (Confidence Interval Coverage):**

    * For

      **fixed effects**, the standard errors were generally unbiased, with 95% confidence interval coverage rates close to the nominal 5% level across most conditions151.

    * For **variance components**, the standard errors were **underestimated**, leading to non-coverage rates of 7% to 11% (instead of 5%). This means confidence intervals for the variances were too narrow152.

Recommendations and Main Takeaway

* The sample size requirements for multilevel **logistic** models appear to be more demanding than for linear models.

* A minimum of

  **50 groups with at least 50 individuals per group** is recommended to produce valid and unbiased estimates for both fixed effects and variance components153153153.

<!-- page 32 -->

* Avoid very small group sizes (like 5), as this leads to severe bias, particularly in the variance component estimates, and frequent convergence failure.
* For **low-prevalence outcomes**, larger sample sizes are required. As a rule of thumb, the authors suggest adjusting the group size so that the

  **expected number of events in each group is greater than one**154.

* Even with adequate sample sizes, be cautious when interpreting inferences about the variance components, as their standard errors tend to be underestimated.

---

## 13. The relative impact of interviewer effects and sample design effects on survey precision

### Citation

O’Muircheartaigh, C., & Campanelli, P. (1998). The relative impact of interviewer effects and sample design effects on survey precision. Journal of the Royal Statistical Society: Series A (Statistics in Society), 161(1), 63–77.

---

### **Study Guide**

#### Main Points

This article empirically compares the magnitude of two major sources of variance in survey estimates: **interviewer variance** and **sampling variance** from complex sample designs (i.e., clustering). It analyzes data from an interpenetrated sampling unit-interviewer experiment.

* **Two Key Sources of Variance in Surveys:**
  1. **Interviewer Variance:** Arises because responses collected by the same interviewer tend to be more similar than responses from different interviewers. This is a form of **measurement error**. It is measured by the intra-interviewer

     correlation, $\rho_{int}$. The inflation in variance due to interviewers is the

     **interviewer effect ($deff_{int}$)**.

     * $deff_{int} = 1 + (\bar{m} - 1)\rho_{int}$, where $\bar{m}$ is the average interviewer workload.

  2. **Sampling Variance (from Clustering):** Arises because individuals living in the same geographic area (e.g., a primary sampling unit or PSU) are often more similar than individuals from different areas. This is a feature of the **sample**

<!-- page 33 -->

**design**. It is measured by the intra-cluster correlation, . The inflation in variance due to clustering is the **design effect ( )**.

* , where is the average number of respondents per cluster.

* **Research Question:** Which of these two effects has a larger impact on the precision of survey estimates? This is important for deciding where to allocate resources—on reducing interviewer workloads and improving training, or on designing less clustered samples.

* **Data and Design:**

  1. The study uses data from the second wave of the British Household Panel Study (BHPS).

  2. A special **interpenetrated PSU-interviewer experiment** was designed. In this design, interviewers are randomly assigned to respondents within different PSUs, which allows for the statistical separation of interviewer effects from PSU (area) effects. A cross-classified multilevel model is used for this analysis.

* **Key Findings:**

  1. Both interviewer correlations ( ) and sampling cluster correlations ( ) were generally small, but their impact on variance was substantial because the workload ( ) and cluster size ( ) can be large.

  2. **Relative Magnitude:** The study found that the values of and were **of the same order of magnitude** across a wide range of survey questions (attitudes, facts, behaviors)155.

  3. **Impact on Variance:** Because interviewer workloads and cluster sizes were also similar, the **interviewer effects ( )** and **design effects ( )** were found to be **comparable in magnitude**. The median effect across all variables was an 80% increase in variance from the combined effects.

  **4. Types of Questions:**

<!-- page 34 -->

* Attitudinal questions and items based on Likert scales were more susceptible to interviewer effects.
* Factual items and demographic variables tended to have lower interviewer effects.
* There was a **positive correlation between and** . This suggests that variables that are naturally clustered geographically (high ) also tend to be more sensitive to interviewer influence (high ).
* **Methodological Implications:**
  1. **Don't Ignore Interviewer Variance:** The findings show that interviewer variance can be as damaging to survey precision as the variance from cluster sampling. Traditional survey analysis often focuses on design effects while ignoring interviewer effects, which is a mistake.
  2. **Resource Allocation:** Since both effects are comparable, survey organizations need to balance efforts to control both. For example, if interviewer effects are found to be large for certain items, this suggests a need for better training or questionnaire design.
  3. **Recommendation:** Organizations should consider incorporating the measurement of interviewer effects into their survey designs. The authors suggest that reducing interviewer workloads might be a practical way to minimize interviewer variance, as current trends toward small, dedicated interviewer forces with large assignments could be a misguided policy.

Main Takeaway

Interviewer effects and design effects from clustering are two distinct but equally important sources of variance that reduce the precision of survey estimates. This study provides strong empirical evidence that their magnitudes are often comparable. Therefore, survey designers and analysts must account for both when planning studies, allocating resources, and calculating final estimates and their standard errors.

---

### 14. Weighting for unequal selection probabilities in multilevel models

Citation

Pfeffermann, D., Skinner, C. J., Holmes, D. J., Goldstein, H., & Rasbash, J. (1998). Weighting for unequal selection probabilities in multilevel models. Journal of the Royal Statistical Society: Series B (Statistical Methodology), 60(1), 23–40.

<!-- page 35 -->

---

**Study Guide**

Main Points

This seminal paper proposes and evaluates methods for incorporating **sampling weights** into two-level models to correct for bias caused by unequal selection probabilities, a common feature of complex survey data.

* **The Problem:** When multilevel models are applied to survey data from multistage sampling, standard estimators can be biased if the selection probabilities are related to the outcome variable, even after conditioning on covariates in the model (i.e., when the sampling design is **informative**)156. For example, if larger schools (sampled with higher probability) also have better outcomes, ignoring the weights will lead to biased estimates of school effects.

* **The Challenge with Multilevel Weighting:** Weighting in multilevel models is not a simple extension of weighting in single-level regression for two main reasons:

  1. The likelihood function is not a simple sum over individuals, so it cannot be estimated by simply weighting individual observations157.

  2. The overall inclusion probability for an individual is not sufficient. The probabilities of selection at

     **each stage of sampling** (e.g., level-2 probability and level-1 conditional probability) must be used separately158.

* **The Proposed Solution: Probability-Weighted Iterative Generalized Least Squares (PWIGLS)**

  1. The authors develop a weighting procedure based on the **pseudomaximum likelihood (PML)** approach.

  2. Their method adapts the standard

     **Iterative Generalized Least Squares (IGLS)** algorithm (which is equivalent to maximum likelihood for linear mixed models) by replacing population sums at each level with sample sums weighted by the inverse of the selection probabilities at that level159.

  3. This involves using separate weights for level-2 units ( ) and for level-1 units ( ).

* **The Issue of Scaling Level-1 Weights:**

  1. The PWIGLS estimators can still be biased when the number of level-1 units per cluster (

<!-- page 36 -->

) is small160. To reduce this small-sample bias, the authors propose **scaling** the level-1 weights.

2. Scaling does not affect the fixed effects ( ) but is crucial for improving the estimates of the **variance components**.

3. Two scaling methods are proposed and evaluated:

   1. **Method 1:** Scales the level-1 weights so their sum equals the **effective sample size**. This method is theoretically motivated to reduce bias in variance component estimation when level-1 sampling is non-informative161.

   2. **Method 2:** Scales the level-1 weights so their sum equals the **actual cluster sample size (** **)**. This is a simpler, more intuitive scaling162.

* **Simulation Findings:**

  1. Unweighted estimators can be severely biased when the sampling design is informative163.

  2. The **unscaled** PWIGLS estimator effectively removes bias for the fixed effects ( ) when cluster sizes are large, but remains biased for variance components when cluster sizes are small164.

  3. **Scaling the weights** significantly reduces the bias in the variance component estimates, especially for small sample sizes165.

  4. **Method 2** (scaling to the actual cluster size) performed better than Method 1 when sampling was informative at level 1166.

  5. Weighting leads to some loss of precision (i.e., larger standard errors), but this is a necessary trade-off to eliminate bias167.

Main Takeaway

When fitting multilevel models to data from complex surveys with unequal selection probabilities, it is crucial to use a weighted estimation procedure that incorporates weights from each level of the sampling design. The PWIGLS method proposed in this paper is an effective way to do this. Furthermore, to reduce small-sample bias in the variance component estimates, the level-1 weights should be scaled, with **scaling to the actual cluster size (Method 2)** often being the preferable approach.

<!-- page 37 -->

---

## 15. Multilevel modelling of complex survey data

### Citation

Rabe-Hesketh, S., & Skrondal, A. (2006). Multilevel modelling of complex survey data. Journal of the Royal Statistical Society: Series A (Statistics in Society), 169(4), 805–827.

---

### **Study Guide**

#### Main Points

This article provides a comprehensive framework for applying **generalized linear mixed models (GLMMs)**—particularly for dichotomous outcomes—to complex survey data. It extends the pseudolikelihood approach to handle sampling weights at multiple levels and discusses the crucial issue of scaling level-1 weights in non-linear models.

* **The Problem:** Applying standard multilevel models to complex survey data is problematic due to unequal selection probabilities, stratification, and clustering. While weighting methods exist for linear mixed models, their application to **GLMMs (e.g., logistic regression)** is more complex and less understood.

* **The Proposed Solution: Full Pseudo-Maximum-Likelihood (PML) Estimation:**

  * The authors implement a full PML estimation method that incorporates sampling weights at each level of the model hierarchy into the likelihood function168.

  * This is achieved using **adaptive quadrature** for numerical integration, which is more accurate for GLMMs than the quasi-likelihood methods used in some older software169.

  * The methodology is implemented in the Stata program **gllamm**, which can handle an arbitrary number of levels170.

  * For correct inference, **sandwich estimators** (robust standard errors) are used to account for stratification and clustering not explicitly modeled171.

* **A Critical Issue in GLMMs: Scaling Level-1 Weights Affects Fixed Effects:**

  * In linear mixed models, scaling the level-1 weights primarily affects the variance component estimates, but has little effect on the regression coefficients (fixed effects)172.

  * **This is NOT true for GLMMs.** In models with non-linear links (like the logit), the regression coefficients ( ) and the random-intercept variance (

<!-- page 38 -->

) are intrinsically linked. The magnitude of the (conditional) regression coefficients depends on the variance173.

* **Why?** The conditional effects ( ) are scaled relative to the total

  residual variance. In a logistic model, this is . If an incorrect scaling of weights leads to a biased estimate of the variance

  , it will also lead to a **biased estimate of the regression**

  **coefficients** 174. This problem had not been widely recognized before this paper.

* **Marginal vs. Conditional Effects:**

  * The regression coefficients ( ) in a GLMM have a **conditional** (or subject-specific) interpretation.

  * The

    **marginal** (or population-averaged) effects, which are often of interest, can be approximated by rescaling the conditional coefficients using the estimated

    variance (e.g., 175.

  * The authors conjecture that these

    **estimated marginal effects will be less biased** and less affected by weight scaling than the conditional coefficients176.

* **Simulation Findings:**

  * A simulation study for a two-level logistic model confirmed the authors' predictions.

  * Using unscaled ("raw") or incorrectly scaled weights led to biased estimates of both the

    **random-intercept variance** and the **conditional regression coefficients**, especially with small cluster sizes177.

  * However, the

    **estimated marginal effects** remained relatively unbiased across different weighting schemes and cluster sizes178.

<!-- page 39 -->

* This suggests that if level-1 weights are present and cluster sizes are small, interpretation should be focused on the more stable marginal effects rather than the conditional coefficients.

Main Takeaway

When fitting multilevel GLMMs to complex survey data, a full pseudo-maximum-likelihood approach using adaptive quadrature (as in gllamm) is recommended. Be extremely cautious when level-1 weights are present, as their scaling can severely bias not only the variance components but also the conditional regression coefficients, particularly with small clusters. In such cases, focusing on the more robust **marginal effects** is a safer analytic strategy.

---

### 16. Multilevel Modeling of Binary Outcomes with Three-Level Complex Health Survey Data

Citation

Rozi, S., Mahmud, S., Lancaster, G., Hadden, W., & Pappas, G. (2017). Multilevel modeling of binary outcomes with three-level complex health survey data. Open Journal of Epidemiology, 7, 27–43.

---

**Study Guide**

Main Points

This paper demonstrates the application of a **three-level weighted multilevel logistic regression model** to complex survey data from the National Health Survey of Pakistan (NHSP). It also includes a simulation study to assess the performance of the weighted estimation method under different conditions.

* **Research Context and Model:**
  * **Data:** The National Health Survey of Pakistan (NHSP), which has a three-level hierarchical structure: individuals (level 1) are nested within households (level 2), which are nested within primary sampling units (PSUs, level 3)179. The design involves unequal selection probabilities, requiring the use of sampling weights.
  * **Outcome:** Health care utilization (a binary outcome).
  * **Methodology:** The study employs a **Multilevel Pseudo Maximum Likelihood (MPML)** approach, which incorporates sampling weights at each level into the estimation process. The analysis is performed using the
    
    GLLAMM program in Stata180.
* **Weight Scaling Methods:**

<!-- page 40 -->

* The paper compares an un-weighted analysis with weighted analyses using two common scaling methods for the level-2 (household) and level-1 (individual) weights:
  1. **Scaling Method 1:** Scales weights so their sum equals the **effective cluster size**. This method is often recommended for obtaining less biased estimates of variance components181.
  2. **Scaling Method 2:** Scales weights so their sum equals the **actual cluster sample size**. This method is often recommended for obtaining less biased estimates of fixed effects (slopes, intercepts)182.
* **Findings from the NHSP Data Analysis:**
  * The results from the un-weighted analysis and the two scaled weighted analyses were

    **largely consistent**, with only a few exceptions183183183.
  * This convergence of results was likely due to the

    **large number of clusters** at level 3 (PSUs) and level 2 (households) in the NHSP data, as well as relatively **small intra-class correlation coefficients (ICCs)**184.
  * Despite the general agreement, some differences were observed. For instance, the significance of a PSU-level variable (province) was reduced after applying weights, and the standard errors for the weighted analyses were generally larger, leading to wider confidence intervals185.
  * The analysis found significant variance at both the household and PSU levels, indicating that both contexts are important for understanding health care utilization186.
* **Simulation Study:**
  * The authors conducted a simulation study to assess the performance of the weighted methods for a three-level binary outcome model. They varied:
    1. **Prevalence of the outcome:** Low (10%) vs. Mid-range (30%).
    2. **ICCs:** Low vs. High ICCs at both the household and PSU levels.
  * **Simulation Results:**
    1. Both scaling methods performed satisfactorily, producing estimates with acceptable bias and confidence interval coverage for the sample sizes considered (which mirrored the large NHSP sample)187187187187.
    2. The bias for the variance components was slightly larger in scenarios with low prevalence and high ICCs, particularly for scaling method 1188.

<!-- page 41 -->

3. Overall, the results confirm that with a sufficiently large number of clusters, the MPML approach provides reliable estimates.

Main Takeaway

This paper provides a practical application of a weighted three-level logistic model, a relatively uncommon analysis in the published literature. The analysis of the NHSP data shows that while weighted and un-weighted results can be similar in datasets with many clusters and low ICCs, weighting is still important as it can alter the significance of some predictors and provides more conservative (and likely more accurate) standard errors. The accompanying simulation study supports the reliability of the scaled weighted estimation methods for three-level binary data when sample sizes are large. Incorporating simulation into the analysis of complex survey data is recommended as good practice189.

---

### 17. Power and Sample Size in Multilevel Linear Models

Citation

Snijders, T. A. B. (2005). Power and sample size in multilevel linear models. In B. S. Everitt & D. C. Howell (Eds.), Encyclopedia of Statistics in Behavioral Science (Vol. 3, pp. 1570–1573). Wiley.

---

**Study Guide**

Main Points

This article provides a concise overview of the key principles for determining statistical **power and sample size** in multilevel linear models. It emphasizes that power is driven by sample sizes at *all* levels and provides formulae for basic two-level designs.

* **The Fundamental Principle of Power in Multilevel Models:**
  * Power depends on the sample size at the level where a variable is measured.
    * To test the effect of a **level-one variable** (e.g., student's study time), the **total number of level-one units** (total students) is most important.
    * To test the effect of a

      **level-two variable** (e.g., school's funding), the **total number of level-two units** (total schools) is most important190.
  * This means the

    **sample size at the highest level is often the main limiting factor** for power191. For example, a study with 60 schools is almost always more powerful than a study with 30 schools, even if the total number of students is the same.
  * Small cluster sizes (e.g., few students per school) are

<!-- page 42 -->

**not necessarily a problem** for testing fixed regression coefficients192. They mainly limit the power for testing random slope variances.

* **The Role of the Design Effect (deff):**

  * The design effect indicates how the multilevel design affects the variance of an estimate compared to a simple random sample (SRS) of the same total size.

    * $\text{deff} = (\text{variance in multilevel design}) / (\text{variance in SRS})$

  * If $\text{deff} > 1$, the design is less efficient than SRS (you need a larger sample).

  * If $\text{deff} < 1$, the design is more efficient than SRS (you need a smaller sample).

  * Required Sample Size (Multilevel) Required Sample Size (SRS) deff.

* Design Effects for Different Types of Variables (in a basic two-level model):

  Let $n = \text{cluster size}$ and $\rho I = \text{intraclass correlation}$.

  * **Estimating a Population Mean or the Effect of a Level-Two Variable:**

    * The design effect is 193.

    * Since is usually positive, deff is greater than 1. This means multilevel designs are **less efficient** for estimating grand means and effects of group-level predictors. The loss of efficiency is worse with larger cluster sizes ( ) and larger ICCs ( ).

  * **Estimating the Effect of a Purely Level-One Variable:**

    * This is a variable that has no between-group variation (e.g., a within-subjects experimental condition).

    * The design effect is 194.

    * deff is less than 1. This means multilevel designs (or repeated measures designs) are **more efficient** for estimating the effects of purely within-cluster predictors.

* **The Impact of Random Slopes:**

<!-- page 43 -->

* If a level-one variable has a random slope (i.e., its effect varies across groups), the formula for its standard error and design effect becomes more complex195.
* The presence of a random slope variance ( ) increases the standard error of the corresponding fixed effect, thus reducing power. It is crucial to account for potential random slopes when doing power calculations.

* **Available Software:** The article lists several specialized programs for power and sample size calculations in multilevel designs, such as **Optimal Design (OD)** and **PinT**196.

Main Takeaway

When planning a multilevel study, the most critical decision for ensuring adequate statistical power is to secure a sufficient number of units at the **highest level** of the hierarchy (e.g., schools, companies, neighborhoods). While the total number of individuals is important for within-group effects, power for detecting contextual effects is driven by the number of contexts. Use the design effect formulas as a guide and specialized software for more precise calculations.

---

## 18. Frequentist and Bayesian approaches for comparing interviewer variance components in two groups of survey interviewers

Citation

West, B. T., & Elliott, M. R. (2014). Frequentist and Bayesian approaches for comparing interviewer variance components in two groups of survey interviewers. Survey Methodology, 40(2), 163–188.

---

**Study Guide**

Main Points

This paper provides a detailed comparison of **frequentist** and **Bayesian** statistical approaches for a specific methodological question: determining if the amount of interviewer variance is different between two distinct groups of interviewers (e.g., experienced vs. new, CAPI vs. CATI).

* **Research Problem:** Survey organizations want to minimize interviewer variance. A key question is whether certain groups of interviewers contribute more variance than others. Answering this requires a statistical comparison of variance components (

) between groups197.

<!-- page 44 -->

* **Modeling Framework:** The comparison is based on a **Hierarchical Generalized Linear Model (HGLM)** that allows for separate variance components for each group of interviewers198.
  * 
  * Where and . The key hypothesis is whether .
* **Two Inferential Approaches Compared:**
  * **Frequentist Approach:**
    * **Estimation:** Uses methods like Residual Pseudo-Likelihood (RPL) or Restricted Maximum Likelihood (REML) to estimate the variance components ( and )199. The analysis is performed using `PROC GLIMMIX` in SAS.
    * **Inference:** Compares the variances using a **Likelihood Ratio Test (LRT)**. This involves fitting a constrained model (where ) and an unconstrained model (where they can differ) and comparing their -2 log-likelihoods. The difference is tested against a distribution with 1 degree of freedom200.
    * **Limitation:** This approach can produce an estimate of zero for a variance component if the true variance is very small. When this happens, a standard error cannot be computed, preventing the calculation of a Wald-type confidence interval for the difference201. The LRT is still possible but relies on asymptotic theory, which may be problematic with small numbers of interviewers.
  * **Bayesian Approach:**
    * **Estimation:** Uses **MCMC (Gibbs sampling)** to simulate thousands of draws from the joint posterior distribution of all model parameters, including and . The analysis is performed using WinBUGS called from R202.
    * **Inference:** For each draw from the simulation, the difference is calculated. The collection of these differences forms the marginal

<!-- page 45 -->

posterior distribution of the difference203. Inference is based on a

**95% Credible Set** (the 2.5th and 97.5th percentiles of this distribution). If the credible set contains zero, there is no strong evidence of a difference204.

* **Advantage:** This method naturally accounts for uncertainty in all parameters and does not rely on asymptotic assumptions. It always produces an interval for the difference, even when variances are close to zero205.

* **Simulation Study and Application Findings:**

  * **Simulation:** In moderate-to-large samples, both approaches performed well, yielding similar conclusions with low bias206. The frequentist approach was slightly more efficient (lower MSE), but often failed to compute a Wald confidence interval when variances were small. The Bayesian approach was more reliable for producing an interval207. In small samples, neither method performed well208.

  * **Application (NSFG data):** The two approaches led to very similar substantive conclusions when comparing variance components across different interviewer groups (e.g., by age, experience)209. In cases where the frequentist approach estimated a variance of zero for one group, the Bayesian estimate was also very small, and the LRT and the Bayesian credible set agreed on the statistical significance of the difference.

Main Takeaway

Both frequentist (via LRT in PROC GLIMMIX) and Bayesian (via MCMC in WinBUGS) methods are viable and generally lead to similar conclusions when comparing interviewer variance components between groups, especially with adequate sample sizes. The Bayesian approach offers a more natural form of inference (a credible set for the difference) and is more robust when one of the variance components is near zero, as it avoids the issue of zero-estimates that can plague the frequentist approach. Practitioners can choose either method, but the Bayesian approach may be preferable if an interval estimate of the difference is a key objective, especially with smaller samples or small variances.

---

### 19. “Interviewer” Effects in Face-to-Face Surveys: A Function of Sampling, Measurement Error, or Nonresponse?

Citation

West, B. T., Kreuter, F., & Jaenichen, U. (2013). “Interviewer” effects in face-to-face surveys: A function of sampling, measurement error, or nonresponse? Journal of Official Statistics, 29(2), 277–297.

---

<!-- page 46 -->

**Study Guide**

Main Points

This article investigates the sources of **interviewer variance** in a face-to-face survey setting. It tests the hypothesis that the observed similarity of responses within interviewers (the "interviewer effect") may not be solely due to measurement error, but also to interviewers systematically recruiting different types of respondents (**nonresponse error variance**).

* **The Core Hypothesis:**

  * **Traditional View (Measurement Error Variance):** Interviewer variance arises because interviewers influence how respondents answer questions, creating correlated response deviations210.

  * **Alternative Hypothesis (Nonresponse Error Variance):** Interviewer variance arises because different interviewers are successful at obtaining cooperation from different kinds of people. The respondents of one interviewer may be systematically different from the respondents of another, even if their initial sample assignments were identical211. Responses within an interviewer appear correlated because the

    *pools of respondents themselves* are different, not because of how the questions are asked.

* Decomposing Total Interviewer Variance:

  To separate these sources, total interviewer variance can be decomposed into two main components (plus a third component from the initial sample assignment):

  * **Variance in Sample Assignments:** Differences between interviewers' assigned caseloads. In a perfectly interpenetrated design, this should be zero.

  * **Nonresponse Error Variance:** Variance in the nonresponse biases across interviewers. Estimated by the variance across interviewers in the **true values** of the **respondents only**.

  * **Measurement Error Variance:** Variance in the mean response deviations across interviewers. Estimated as the difference between total variance and nonresponse error variance.

  * **Total Interviewer Variance:** The variance across interviewers in the **reported values** of their respondents. This is what is traditionally measured.

* **Data and Methodology:**

  * **Data Source:** The German Labour Market and Social Security (PASS) study, a face-to-face CAPI survey212. A key feature is the availability of

    **administrative records ("true" values)** for several variables for both respondents and nonrespondents in the unemployment benefit (UB) sample213.

<!-- page 47 -->

* **Challenge:** The PASS study does not have an interpenetrated design; interviewers are mostly assigned to work in specific geographic areas (PSUs). To address this, the authors control for PSU-level covariates in their models to statistically adjust for area differences214214214.

* **Analysis:** A three-step estimation process is used to estimate the different variance components for eleven variables215.

* **Key Findings:**

  * **Significant Interviewer Variance in Response Rates:** There was substantial variation in response rates among the 211 CAPI interviewers, confirming that some interviewers are more successful at gaining cooperation than others216. This is the necessary precondition for nonresponse error variance.

  * **Evidence of Both Error Sources:** For the variables that showed significant total interviewer variance, the study found evidence of both nonresponse and measurement error variance.

    * For

      **current receipt of unemployment benefits**, about 38% of the interviewer variance was due to nonresponse error (interviewers recruiting different types of people), while 62% was due to measurement error (interviewers eliciting different answers)217.

    * For **employment status**, the variance was primarily driven by **measurement error**. The pools of recruited respondents were similar across interviewers, but the

      *reported* employment statuses varied significantly218.

    * For

      **age**, the findings suggested that variance was driven by both differences in the initial sample assignments and differential nonresponse, with very little contribution from measurement error (as expected for a factual item)219.

  * **Importance of Adjusting for Area Effects:** The estimated interviewer variance components were substantially reduced after controlling for PSU-level covariates, highlighting the importance of accounting for area effects in non-interpenetrated designs220.

Main Takeaway

Interviewer variance is a complex phenomenon that is not solely a product of measurement error. This study provides the first empirical evidence from a face-to-face survey that a substantial portion of the "interviewer effect" can be attributed to **nonresponse error variance**—that is, systematic differences in the kinds of people that different interviewers

<!-- page 48 -->

successfully recruit. This implies that efforts to reduce interviewer effects should focus not only on standardized question administration but also on standardizing recruitment practices to minimize differential nonresponse across interviewers.

---

## 20. An Overview of Current Software Procedures for Fitting Linear Mixed Models

Citation

West, B. T., & Galecki, A. T. (2011). An overview of current software procedures for fitting linear mixed models. The American Statistician, 65(4), 274–282.

---

### Study Guide

Main Points

This article provides a comprehensive comparison and guide to the capabilities of various contemporary statistical software procedures for fitting **Linear Mixed Models (LMMs)**. It focuses on identifying which advanced features are available in which packages.

* **Purpose:** To serve as a practical guide for statisticians to help them select the most appropriate software for a given LMM analysis by comparing features across many popular packages (SAS, SPSS, R, Stata, HLM, MLwiN, Mplus, etc.).
* **Core LMM Capabilities (Common to Most Software):**
    * **Data Format:** Most procedures require data in a "long" or "vertical" format (one row per observation)221221.
    * **Estimation Methods:** Most offer both Maximum Likelihood (ML) and Restricted Maximum Likelihood (REML) estimation222.
    * **Basic Output:** Most provide estimates of fixed effects, variance components, and their standard errors223.
* Advanced Features (Where Software Packages Differ):

  The article systematically compares software on several key analytic aspects:

    * **Model Specification:**
        * **Graphical Interface vs. Syntax:** HLM and MLwiN offer a graphical, multilevel specification. Most others (SAS, R, Stata) are primarily syntax-driven, using a "single equation" format224224224224.
        * **Crossed Random Effects:** The ability to model non-nested hierarchies (e.g., students crossed by schools and neighborhoods) is increasingly supported but not universal. It is available in SAS (

          PROC MIXED), Stata (xtmixed/mixed), R (lmer), and HLM225225.

<!-- page 49 -->

* **Group-Specific Covariance Structures:** The flexibility to specify different random effect (D) or residual (R) covariance matrices for different subgroups is an important but not widely available feature. SAS

  MIXED, SPSS MIXED, and Stata xtmixed are noted for this capability226226226226.

* **Estimation and Likelihood Optimization:**

  * **Handling Survey Weights:** Correctly incorporating sampling weights for complex survey data is a major challenge. At the time of publication, HLM, MLwiN, Mplus, and Stata (gllamm, xtmixed) had established procedures for this. This is an active area of development227227227.

  * **Computational Speed:** Some newer procedures use **sparse matrix algorithms** for much faster computation with large datasets (e.g., R lmer, SAS HPMIXED, HLM, MLwiN)228.

* **Hypothesis Testing:**

  * **Degrees of Freedom (DF) for Fixed Effects:** Procedures vary in the methods used to approximate DF (e.g., Satterthwaite, Kenward-Roger). SAS

    MIXED and GLIMMIX are particularly flexible here229.

  * **Testing Variance Components:** This is a weak point for most software. Wald tests are common but unreliable. **Likelihood Ratio Tests (LRTs)** based on mixtures of chi-square distributions are more appropriate but rarely automated.

    * **SAS GLIMMIX** and **Stata xtmixed** are noted for implementing correct LRTs for single variance components230.

    * The

      **RLRsim** package in R provides an exact LRT231.

    * Bayesian methods (e.g., in MLwiN, WinBUGS, or via R packages) are a strong alternative for inference on variances232.

* **Model Diagnostics:**

  * Diagnostic tools for LMMs are generally underdeveloped in most software.

  * Most procedures can save residuals and predicted random effects (EBLUPs) for manual plotting.

  * **SAS PROC MIXED** is highlighted for its more advanced **influence diagnostics**233.

<!-- page 50 -->

Main Takeaway

While most modern statistical packages can fit basic LMMs, they differ significantly in their ability to handle more advanced and specialized analytic tasks. No single procedure is superior on all dimensions. Analysts should choose software based on the specific requirements of their research problem, paying close attention to whether the software supports features like crossed random effects, appropriate handling of survey weights, and, crucially, valid methods for hypothesis testing of variance components. This review serves as a valuable checklist for making that choice.
