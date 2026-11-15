---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module1_Lecture6_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "**Applications of Statistical Modeling:**"
original: "applications_stats_modeling_SURV617/lectures/Module1_Lecture6_Fall2025.pdf"
pages: 48
sha256: "0b0358058b00613d93bc29192f05d73b9a1300e6d52a058774f364f3cf64e7ea"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:41"
---

<!-- page 1 -->

# **Applications of Statistical Modeling:**
## Module #1, Lecture #6

### Accounting for Complex Sample Designs When Fitting Multilevel and Marginal Models

Instructor: Brady T. West

Email: [[email]](mailto:[email])

1

<!-- page 2 -->

# Lecture Overview

* In this lecture (the final lecture for Module 1!), we’ll explore some recent methodological advances in multilevel and marginal modeling of complex sample survey data, starting with the analysis of longitudinal survey data
* In general, this is an area that is ripe for future work, but we will discuss the modeling alternatives that have been developed / proposed to date
* We will focus on how we can use multilevel/marginal models for analyzing data from complex sample surveys (e.g., NHANES, NHES, CPS, ACS, etc.)
* We will also discuss software alternatives and take-home points

2

<!-- page 3 -->

# Important: What is Your Objective?

* When considering approaches to the analysis of longitudinal survey data, it is quite important to make the objective of your analysis very clear:
  - Descriptive estimation at a single wave / time point?
  - Estimation of change across two waves?
  - Trajectory estimation based on three or more waves?

3

<!-- page 4 -->

# What is Your Objective?

* Given a clearly stated objective, one can then consider alternative analytic approaches
* Important considerations:
  - How should weights (baseline weights and time-varying weights) be incorporated?
  - What should we do about complex sampling features (stratification, cluster sampling)?
  - Multilevel or marginal?
  - Only analyze complete cases, or analyze all available information?

4

<!-- page 5 -->

# Thinking About Possible Approaches

* Should we:
  - Only analyze those panel respondents who have responded in *<u>every</u>* wave, and apply the base weights (Wave 1 weights) for each individual?
    * How many cases would we lose due to attrition? Are those cases unique? Should we adjust the weights?
  - Analyze panel respondents who have responded in *<u>every</u>* wave, use the base weights as Level 2 weights, and use weights adjusted for differential attrition at each wave (at Level 1)?
    * Do we need a multilevel modeling approach for this?

5

<!-- page 6 -->

# Thinking About Possible Approaches

* Should we:
  - Analyze *<u>all available reports</u>* from panel respondents, with initial base weights somehow adjusted for differential patterns of attrition?
  - Analyze *<u>all available reports</u>* from panel respondents, with wave-specific base weights somehow adjusted for differential patterns of attrition (**possibly optimal:** West et al., 2025, Canvas)?
    * Do we need a multilevel modeling approach for this?
    * How do we compute the different weights?

6

<!-- page 7 -->

# Thinking About Possible Approaches

* Should we:
  - Define different *patterns* of complete cases (e.g., W1, W2, W3; W1, W3, W5; etc.), and develop different *single* weights for each pattern, with initial base weights adjusted for the probability of providing complete data for that pattern?
  - This method is currently advocated in the longitudinal portion of the Army STARRS project, being conducted at the University of Michigan, and also by the Add Health program

7

<!-- page 8 -->

# Thinking About Possible Approaches

* Should we:
  - Ignore the weights (base weights or wave-specific weights) entirely, use all available observations (e.g., FIML), and rely on sound model specification?
  - Treat the weights as covariates at each level, so that we account for any sampling information contained in the weights that could relate to key variables and / or trends in those variables?
    * Again, do we need a multilevel modeling approach for this? And what do we do about stratum / cluster codes?

8

<!-- page 9 -->

# Thinking About Possible Approaches

* Should we:
  - Impute missing values at subsequent waves, and then perform a multiple imputation analysis of “complete” cases?
  - If so, what role should the weights play in these imputations?
  - What “complete” case analysis should be applied to each imputed data set? Should only the base weights be used once we have complete cases?

9

<!-- page 10 -->

# Key Premise

* When finding the best possible model for a set of data, features of a complex sample design may be <u>informative</u> about outcomes of interest, and these features need to be accounted for!

10

<!-- page 11 -->

# Design-based Modeling Approaches

* All based on the “randomization” (or “repeated-sampling”) inferential framework
* The data set in hand was collected from a random sample from some well-defined **finite population**, where each element in the population had some non-zero probability of being selected
* These probabilities drive all of the inference!

11

<!-- page 12 -->

# Design-based Modeling Approaches

* Unbiased, weighted estimates of finite population model parameters are computed
  - With large samples, these estimates serve as unbiased estimates of parameters in a **superpopulation model** that generates the finite populations of interest
* Estimated standard errors of the weighted estimates, describing their sampling variance, represent <u>estimates of the standard deviation of the sampling distribution</u> of estimates that would be generated from **hypothetical repeated samples** using the same sample design

12

<!-- page 13 -->

# Design-based Modeling Approaches

* **Common Estimation Approaches:**
  - Pseudo-Maximum Likelihood Estimation for Model Parameters (Binder, 1981, 1983)
  - Robust, Non-parametric, Design-consistent Variance Estimation Approaches:
    * Taylor Series Linearization (TSL)
      - Will focus on TSL in these slides
    * Jackknife / Balanced Repeated Replication (JRR / BRR)
    * Bootstrapping
  - Variances all estimated <u>with respect to the sample design</u>, rather than the model
* Intervals are then formed using approximate degrees of freedom based on the sample design for robust population inference

13

<!-- page 14 -->

# Design-based Modeling: Software

* R: `svyglm()` function in `survey` package
* Stata: `svy` suite of commands
* SAS:
  - `proc surveyreg`
  - `proc surveylogistic`
  - `proc surveyphreg`
* Many others (SPSS, Mplus, SUDAAN, etc.)

14

<!-- page 15 -->

# Model-based Approaches

* Specify the best possible probability model for a given set of data, and use the data in hand to estimate the parameters that define the model
* Estimate the variance of parameter estimates <u>with respect to the model</u>
* Generally ignorant of design-based approaches for weighted estimation and non-parametric variance estimation, **BUT:**
* Definitely acknowledge that “relevant” design information for outcome variables of interest should be accounted for when finding the best possible model!

15

<!-- page 16 -->

# Model-based Approaches

* A good overview article presenting the distinction between these two approaches, which still holds up perfectly well today:

Hansen, M.H., Madow, W.G., and Tepping, B.J. (1983). An evaluation of model-dependent and probability-sampling inferences in sample surveys. *Journal of the American Statistical Association*, 78(384), 776-793. [On Canvas]

16

<!-- page 17 -->

# Model-based Approaches

* In the model-based spirit, effects of <u>randomly sampled</u> clusters (possibly within strata) are generally treated as **random effects**
* Effects of strata (<u>fixed by design</u>, and not randomly sampled) are generally treated as **fixed effects**
* A multilevel model therefore seems quite appropriate!
* **BUT:** What should be done about those pesky sampling weights? And are they informative?

17

<!-- page 18 -->

# Weights in Model-based Approaches

* One possible approach to dealing with the weights is “purely” model-based: Include functions of the weight variable(s) as covariates in the model (DuMouchel and Duncan, 1983; Little, 1991; Korn and Graubard, 1999, Section 4.5; Fuller, 2009, Ch. 6)
* Simple to implement in practice; only requires standard multilevel modeling software
* Puts pressure on the analyst to make sure that covariates defining the weights (or appropriate functions of the weights themselves) are included in the model; good specification very important!

18

<!-- page 19 -->

# Weights in Model-based Approaches

* A second possible approach represents a “hybrid” of design- and model-based approaches: use the weights to estimate the parameters of a multilevel model, and compute appropriate standard errors of the weighted estimates
* Important paper: Pfeffermann et al. (1998)
* Some other critical papers: Rabe-Hesketh and Skrondal (2006), Carle (2009)

19

<!-- page 20 -->

# In Practice

* Survey agencies generally do not release the weight information necessary to implement “hybrid” multilevel modeling approaches (mainly the weights associated with sampled clusters)
* Analysts thus need to resort to the first modeling approach, which can be problematic if weights are informative and not accounted for
* **What is your analysis objective?**

20

<!-- page 21 -->

# Estimation at a Single Time Point

* Simple design-based descriptive techniques can be used, BUT:
  * How should the weights be adjusted for attrition?
* Alternatives:
  * Adjust the base weights for attrition (how?)
  * Impute missing values in the wave of interest
  * If an ignorable MAR mechanism does not seem to hold, consider methods for non-ignorable mechanisms (e.g., West and McCabe, 2017, AJE)

21

<!-- page 22 -->

# Estimation of Change using Two Waves

* The same design-based descriptive approaches can be applied to **measures of change**, with the same important considerations regarding the weights
* If change relative to the initial wave is the objective, the three approaches outlined on the slide above can be used
* If change between two arbitrary waves is the objective, multiple imputation generally best

22

<!-- page 23 -->

# Modeling Trajectories

* As we have discussed previously, another important consideration is whether you want to fit a **multilevel model**, and make inference about the variance in trajectories, or fit a **marginal model** that focuses on overall trends
* The choice of approach would dictate how you would handle the weights, as we discussed for multilevel modeling...

23

<!-- page 24 -->

# Multilevel vs. Marginal

* Remember that in the multilevel approach, we need to consider the possibility of alternative covariance structures for the errors as well
* How do we compute weighted estimates of these conditional residual covariance matrices?
* Veiga et al. (2014) were the first to really address this in detail!

24

<!-- page 25 -->

# Weighted GEE Approach

* **Idea**: Assign a single weight to each case that incorporates the probability of having a particular response pattern across the waves
* Does require some initial modeling of response propensities (conditional on prior patterns of response) and data management
* Incorporate the final adjusted weight into the estimating equations (see previous GEE notes)

25

<!-- page 26 -->

# Weighted GEE (ASDA Chapter 11)

**TABLE 11.1**

An Illustration of the Data Preparation Required to Compute Case-Specific Weights for the Weighted GEE Approach, Considering a Longitudinal Study with Four Waves

| Case ID | Wave | Response Indicator (Outcome) | Predicted Probability of Outcome | Cumulative Probability | Lagged Cumulative Probability | Response Pattern in Prior Waves$^{\text{a}}$ | Final Case-Specific Weight Adjustment |
| :--- | :--- | :---: | :--- | :--- | :--- | :--- | :--- |
| 1 | 2 | 1 | $p_{12}$ | $p_{12}$ | – | – | – |
| 1 | 3 | 1 | $p_{13}$ | $p_{12} \times p_{13}$ | $p_{12}$ | 1 | – |
| 1 | 4 | 1 | $p_{14}$ | $p_{12} \times p_{13} \times p_{14}$ | $p_{12} \times p_{13}$ | 1, 1 | $1/(p_{12} \times p_{13} \times p_{14})$ |
| 2 | 2 | 1 | $p_{22}$ | $p_{22}$ | – | – | – |
| 2 | 3 | 0 | $1 - p_{23}$ | $p_{22} \times (1 - p_{23})$ | $p_{22}$ | 1 | – |
| 2 | 4 | 0 | $1 - p_{24}$ | $p_{22} \times (1 - p_{23}) \times (1 - p_{24})$ | $p_{22} \times (1 - p_{23})$ | 1, 0 | $1/[p_{22} \times (1 - p_{23}) \times (1 - p_{24})]$ |
| 3 | 2 | 1 | $p_{32}$ | $p_{32}$ | – | – | – |
| 3 | 3 | 1 | $p_{33}$ | $p_{32} \times p_{33}$ | $p_{32}$ | 1 | – |
| 3 | 4 | 0 | $1 - p_{34}$ | $p_{32} \times p_{33} \times (1 - p_{34})$ | $p_{32} \times p_{33}$ | 1, 1 | $1/[p_{32} \times p_{33} \times (1 - p_{34})]$ |
| 4 | 2 | 1 | $p_{42}$ | $p_{42}$ | – | – | – |
| 4 | 3 | 0 | $(1 - p_{43})$ | $p_{42} \times (1 - p_{43})$ | $p_{42}$ | 1 | – |
| 4 | 4 | 1 | $p_{44}$ | $p_{42} \times (1 - p_{43}) \times p_{44}$ | $p_{42} \times (1 - p_{43})$ | 1, 0 | $1/[p_{42} \times (1 - p_{43}) \times p_{44}]$ |

$^{\text{a}}$ The response pattern in prior waves is used to define the subset of cases that will be used to fit the logistic regression model predicting the probability of responding in the current wave for this particular case. In Wave 2, all cases will be used to estimate the probability of responding.

26

<!-- page 27 -->

# Weighted Multilevel Modeling Approach

* Implementing this approach <u>**requires weights at each level of the hierarchical data structure**</u>
* **Level-1 weights:** inverses of conditional probabilities of selection, given that a Level-2 cluster was sampled
* **Level-2 weights:** generally inverses of probabilities of selection for sampling clusters; should be conditional weights if considering a three-level model
* **Also need cluster codes and stratum codes!**

27

<!-- page 28 -->

# Weighted Multilevel Modeling Approach

* **Key Point:** Don’t use the overall (adjusted) sampling weights that are typically provided in public-use data files; use conditional inverse-probability weights at each level
* Rabe-Hesketh and Skrondal (2006) clearly show how the weighted likelihood function (or **pseudo-likelihood**) for a multilevel model requires the inverse-probability weights at <u>each level</u> of the data hierarchy

28

<!-- page 29 -->

# Why do we need multiple weights?

* Separate “conditional” weights are needed at lower levels to specify the appropriate likelihood function, and compute unbiased estimates of <u>both fixed-effect and covariance parameters</u>
* We need to strip out the probability that a higher-level cluster was sampled from the overall weights that are usually provided for respondents; software can help with this step
* <u>The overall inclusion probabilities do not carry forward sufficient information for bias correction when estimating multilevel models</u>
* The simple design-based idea of pseudo-likelihood (weighting likelihood contributions by overall sampling weight, and assuming independent observations in finite population) is not sufficient, generally due to random effects in the model-based approach

29

<!-- page 30 -->

# Weight Scaling

* “Method 1” proposed by Pfeffermann et al. (1998) scales weights by “design effects” to yield effective sample sizes within clusters, rather than “naïve” (or nominal) sample sizes
  * Implemented in Stata: `pwscale(effective)`
* Pfeffermann et al. (1998) advocate their “Method 2”, which scales weights so that they sum to actual sample sizes rather than weighted sample sizes; good for <u>informative</u> weights
  * Implemented in Stata: `pwscale(size)`
* Nice feature of “Method 2”: makes the need for conditional weights at Level 1 of the data hierarchy <u>irrelevant</u>

30

<!-- page 31 -->

# Weight Scaling, cont’d

* An example of one cluster (with probability of selection $1/4$) with three sampled elements, using scaling Method 2:

| | Element 1 | Element 2 | Element 3 |
| :--- | :---: | :---: | :---: |
| P(selection\|cluster) | $1/2$ | $1/3$ | $1/4$ |
| Conditional weight | $2$ | $3$ | $4$ |
| P(cluster) | $1/4$ | $1/4$ | $1/4$ |
| Cluster weight | $4$ | $4$ | $4$ |
| Overall weight | $8$ | $12$ | $16$ |
| Scaled CW | $2/3$ | $1$ | $4/3$ |
| Scaled OW | $8/12 = 2/3$ | $12/12 = 1$ | $16/12 = 4/3$ |

* Note that the scaled overall survey weight is the same as the scaled conditional weight! Can use either as the new Level-1 weight, as long as scaling is performed (Carle, 2009)

31

<!-- page 32 -->

# Example: 2000 PISA Data

* Analyzed by Rabe-Hesketh and Skrondal (2006)
* Programme for International Student Assessment (PISA)
* Relevant variables for this example:
  - ISEI: Continuous DV measuring SES of student
  - COLLEGE: Indicator of whether the highest level of education for either parent is college
  - ID_SCHOOL: Code for randomly sampled school (cluster)
  - W_FSTUWT: **<u>Overall</u>** final student weight (not conditional, but that’s OK if using scaling Method 2!)
  - WNRSCHBW: Final school weight (*this is the weight that is rarely provided*)

32

<!-- page 33 -->

# Example: 2000 PISA Data

* Multilevel model of interest ($i = \text{student}$, $j = \text{school}$):

$$ISEI_{ij} = \beta_0 + \beta_1 COLLEGE_{ij} + u_{0j} + u_{1j} COLLEGE_{ij} + e_{ij}$$

$$\begin{pmatrix} u_{0j} \\ u_{1j} \end{pmatrix} \sim N \left( \begin{pmatrix} 0 \\ 0 \end{pmatrix}, \begin{pmatrix} \sigma_0^2 & 0 \\ 0 & \sigma_1^2 \end{pmatrix} \equiv D \right)$$

$$e_{ij} \sim N(0, \sigma^2)$$

33

<!-- page 34 -->

# Example: 2000 PISA Data

* **Possible Approach 1:** Ignore Weights

```
mixed isei college||id_school: college, ///
covariance(independent) variance
```

* Output:

```
                                                  Wald chi2(1)       =    195.93
Log likelihood = -8611.8768                       Prob > chi2        =    0.0000

--------------------------------------------------------------------------------
        isei |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+------------------------------------------------------------------
     college |   12.64623   .9034645    14.00   0.000     10.87548    14.41699
       _cons |   38.78531   .619744     62.58   0.000     37.57064    39.99999
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  Random-effects Parameters  |   Estimate   Std. Err.     [95% Conf. Interval]
-----------------------------+--------------------------------------------------
id_school: Independent       |
                var(college) |   43.11569   10.84527       26.3345    70.59041
                  var(_cons) |    16.1445   5.451408      8.329231    31.29279
-----------------------------+--------------------------------------------------
               var(Residual) |   219.3327   7.195403      205.6738    233.8987
--------------------------------------------------------------------------------
LR test vs. linear regression:       chi2(2) =   159.35   Prob > chi2 = 0.0000
```

34

<!-- page 35 -->

# Example: 2000 PISA Data

* **Possible Approach 2:** Final overall weights as covariates

`mixed isei college `**`w_fstuwt`**` || id_school: college, covariance(independent) variance`

* Output:

```text
                                                    Wald chi2(2)       =    203.31
Log likelihood = -8609.9137                         Prob > chi2        =    0.0000

----------------------------------------------------------------------------------
            isei |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
         college |   12.59723   .9003722    13.99   0.000     10.83254    14.36193
        w_fstuwt |   .0024003   .0011771     2.04   0.041     .0000933    .0047073
           _cons |   36.82151   1.135727    32.42   0.000     34.59553    39.04749
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
  Random-effects Parameters  |   Estimate   Std. Err.     [95% Conf. Interval]
-----------------------------+----------------------------------------------------
id_school: Independent       |
                var(college) |   42.26108   10.57867       25.8744     69.0257
                  var(_cons) |   13.93707   5.218505      6.690413    29.03286
-----------------------------+----------------------------------------------------
               var(Residual) |   219.9161   7.223948      206.2036    234.5405
----------------------------------------------------------------------------------
LR test vs. linear regression:       chi2(2) =   139.11   Prob > chi2 = 0.0000
```

35

<!-- page 36 -->

# Example: 2000 PISA Data

* **Possible Approach 3:** Weighted, scaling method 1 (“Effective”)

```stata
mixed isei college [pw = w_fstuwt] || id_school: college,
  covariance(independent) variance pweight(wnrschbw)
  pwscale(effective)
```

* Output:

```text
                                                Wald chi2(1)       =    100.84
Log pseudolikelihood = -1439307.8               Prob > chi2        =    0.0000

                               (Std. Err. adjusted for 148 clusters in id_school)
------------------------------------------------------------------------------
             |               Robust
        isei |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
     college |   14.28032   1.422044    10.04   0.000     11.49316    17.06747
       _cons |   35.88949   .9100379    39.44   0.000     34.10585    37.67313
------------------------------------------------------------------------------

------------------------------------------------------------------------------
                             |               Robust
  Random-effects Parameters  |   Estimate   Std. Err.     [95% Conf. Interval]
-----------------------------+------------------------------------------------
id_school: Independent       |
                var(college) |   41.03253   13.73849      21.28773      79.091
                  var(_cons) |   17.74315   6.429159      8.721705    36.09609
-----------------------------+------------------------------------------------
               var(Residual) |   214.9573    12.8191      191.2451    241.6096
------------------------------------------------------------------------------
```

36

<!-- page 37 -->

# Example: 2000 PISA Data

* **Possible Approach 4:** Weighted, scaling method 2 (“Size”)

```stata
mixed isei college [pw = w_fstuwt] || id_school: college,
  covariance(independent) variance pweight(wnrschbw)
  pwscale(size)
```

* Output:

```
                                                Wald chi2(1)       =    100.87
Log pseudolikelihood =  -1443258                Prob > chi2        =    0.0000

                                  (Std. Err. adjusted for 148 clusters in id_school)
------------------------------------------------------------------------------------
                   |               Robust
              isei |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------------+----------------------------------------------------------------
           college |   14.27681   1.421497    10.04   0.000     11.49073     17.0629
             _cons |   35.89078   .9099169    39.44   0.000     34.10738    37.67419
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
                                   |               Robust
         Random-effects Parameters |   Estimate   Std. Err.     [95% Conf. Interval]
-----------------------------------+------------------------------------------------
id_school: Independent             |
                      var(college) |   41.05972   13.72822      21.32155    79.07025
                        var(_cons) |   17.78522   6.426353      8.759787    36.10978
-----------------------------------+------------------------------------------------
                     var(Residual) |   214.9225   12.84382      191.1674    241.6294
------------------------------------------------------------------------------------
```

37

<!-- page 38 -->

# Example: 2000 PISA Data

* Summary of Estimates (SEs / Robust SEs):

| Parameter | No Weights | Covariate | Method 1 | Method 2 |
| :--- | :--- | :--- | :--- | :--- |
| **FIXED** | | | | |
| Intercept | 38.79 (0.62) | 36.82 (1.14) | 35.89 (0.91) | 35.89 (0.91) |
| COLLEGE | 12.65 (0.90) | 12.60 (0.90) | 14.28 (1.42) | 14.28 (1.42) |
| WEIGHT | | <0.01 (<0.01) | | |
| **RANDOM** | | | | |
| V(Intercept) | 16.14 (5.45) | 13.94 (5.22) | 17.74 (6.43) | 17.79 (6.43) |
| V(College) | 43.12 (10.85) | 42.26 (10.58) | 41.03 (13.74) | 41.06 (13.73) |
| V(Residuals) | 219.33 (7.20) | 219.92 (7.22) | 214.96 (12.82) | 214.92 (12.84) |
| **log-(P)Like** | -8611.88 | -8609.91 | -1439307.8 | -1443258.0 |

38

<!-- page 39 -->

# Summary of PISA Example Results

* Parental college education has a strong effect on SES, regardless of the method used
* Weighted estimates of fixed effects are different from unweighted estimates, especially the intercept (i.e., mean for students with non-college educated parents)
* Including the student-level weight as a covariate changes interpretations of parameters; be careful!

39

<!-- page 40 -->

# Summary of PISA Example Results

* Weighted estimates of variance components differ:
  - More evidence of variability across schools in means for students with non-college educated parents (i.e., the random intercepts) when computing weighted estimates
  - Less variability in college vs. non-college gaps (i.e., the random coefficients) across the sampled schools
* Weight scaling methods do not result in different estimates or conclusions; use "size" (Method 2)
* Robust standard errors for weighted estimates are generally larger, but do not change inferences

40

<!-- page 41 -->

# Alternative Software

* **R:** The brand new **svylme** package
* For examples (only continuous outcomes!):

https://cran.r-project.org/web//packages/svylme/svylme.pdf

```r
# note use of weights specified for each level in id argument
dpisa <- svydesign(id = ~id_school + id_student, weight =
~wnrschbw + w_condstuwt, data = pisa)

# fit multilevel model to continuous outcome
mod <- svy2lme(isei ~ (1|id_school) + female + high_school +
college + one_for + both_for + test_lang, design = dpisa)
```

41

<!-- page 42 -->

# Alternative Software

* **SAS PROC GLIMMIX**
  - Note the explicit specification of the two weight variables; otherwise, the syntax is quite similar

```sas
proc glimmix data = pisa2000;
   class id_school;
   model isei = college / solution obsweight=SC_L1weight;
   random int college / subject=id_school weight=wnrschbw;
   * covtest glm;
run;
```

42

<!-- page 43 -->

# Multilevel Analysis of Longitudinal Data

* **<u>Simple idea</u>:** use what we’ve already discussed for multilevel modeling, where Level 2 is the subject and Level 1 is the repeated measures
* The same issues with the weights apply: we need a base weight for each individual, and then *conditional* versions of the time-varying weights (which could be adjusted for non-response / attrition at each time point)

43

<!-- page 44 -->

# Multilevel Analysis of Longitudinal Data

* See Section 11.3.3 of Chapter 11 (ASDA, 2025) for an example of using this approach with waves 2006, 2008, 2010, and 2012 of HRS (Canvas)
* What’s nice is that we can use all available information from each subject, along with adjustments for nonresponse
* **However**: this approach discussed does not explicitly allow for additional variance-covariance structures for the conditional residuals (common to longitudinal data!)

44

<!-- page 45 -->

# Multilevel Analysis of Longitudinal Data

* There is where the work of Veiga et al. (2014) is quite important
* They outline the multilevel approach for estimating this additional covariance structure and making appropriate inferences given complex sampling features
* This approach has now been implemented in both R (the **pwlmm** package) and Stata

45

<!-- page 46 -->

# Take-home Points

* Always start from your model fitting objective!
* Important to account for the sample design features in both point estimation and variance estimation when fitting models
* Available tools: Weighted Multilevel Models / Weighted GEE
* Software currently available in Stata, R, SAS

46

<!-- page 47 -->

# References

* Carle, A.C. (2009). Fitting multilevel models in complex survey data with design weights: Recommendations. *BMC Medical Research Methodology*, 9:49.
* Dumouchel, W.H. and Duncan, G.J. (1983). Using sample survey weights in multiple regression analysis of stratified samples. *Journal of the American Statistical Association*, 78(383), 535-543.
* Fuller, W. (2009). *Sampling Statistics*. Wiley.
* Gelman, A. (2007). Struggles with survey weighting and regression modeling. *Statistical Science*, 22 (2), 153–164.
* Heeringa, S.G., West, B.T., and Berglund, P.A. (2017). *Applied Survey Data Analysis, Second Ed*. Chapman & Hall / CRC Press.
* Korn, E.L. and Graubard, B.G. (1999). *Analysis of Health Surveys*. Wiley.
* Little, R.J.A. (1991). Inference with survey weights. *Journal of Official Statistics*, 7, 405-424.
* Pfeffermann, D. (1993). The role of sampling weights when modelling survey data. *International Statistical Review*, 61, 317-337.

47

<!-- page 48 -->

# References

* Pfeffermann, D., Skinner, C.J., Holmes, D.J., Goldstein, H., and Rasbash, J. (1998). Weighting for unequal selection probabilities in multilevel models. *Journal of the Royal Statistical Society, Series B*, 60(1), 23-40.
* Rabe-Hesketh, S. and Skrondal, A. (2006). Multilevel modelling of complex survey data. *Journal of the Royal Statistical Society, Series A*, 169(4), 805-827.
* Si, Y., West, B. T., Veliz, P., Patrick, M. E., Schulenberg, J. E., Kloska, D. D., ... & McCabe, S. E. (2022). An empirical evaluation of alternative approaches to adjusting for attrition when analyzing longitudinal survey data on young adults' substance use trajectories. *International Journal of Methods in Psychiatric Research*, 31(3), e1916.
* Veiga, A., Smith, P. W., & Brown, J. J. (2014). The use of sample weights in multivariate multilevel models with an application to income data collected by using a rotating panel survey. *Journal of the Royal Statistical Society Series C: Applied Statistics*, 63(1), 65-84.
* West, B.T., Si, Y., Hu, Y., McCabe, S.E., and Veliz, P. (2025). The Role of Weighting Adjustment for Attrition in Longitudinal Trajectory Modeling: A Simulation Study. *Communications in Statistics: Simulation and Computation*, 54(3), 866-888.

48
