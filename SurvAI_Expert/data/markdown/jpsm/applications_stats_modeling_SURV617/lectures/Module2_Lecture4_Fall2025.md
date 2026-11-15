---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module2_Lecture4_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "**Applications of Statistical Modeling:**"
original: "applications_stats_modeling_SURV617/lectures/Module2_Lecture4_Fall2025.pdf"
pages: 36
sha256: "4e313ad60521ebd205966777c7898b2a1275903c971e3b94261ba6d47f811205"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:42"
---

<!-- page 1 -->

# **Applications of Statistical Modeling:**
## Module #2, Lecture #4

### Accounting for Complex Sample Designs When Fitting Structural Equation Models

Instructor: Brady T. West

Email: [email]

1

<!-- page 2 -->

# Review: Complex Samples

* Recall from **Module 1** the notions of **complex sampling** and **design-based analysis**
* Use survey weights to compute design-unbiased estimates of parameters describing characteristics of a finite population
* Use either replicated variance estimation
  - requires replicate weights based on the sample design

  or Taylor Series Linearization approaches
  - requires variables describing stratum and cluster codes

  for **design-unbiased** variance estimation

2

<!-- page 3 -->

# Overview of Today’s Lecture

* How do we account for these sample design features when fitting structural equation models and performing latent class analysis?
* Review of the complex sample design features of the NESARC and available design variables
  – One cluster per stratum problem
* Revisit analyses of the NESARC data, now estimating SEMs that describe the finite target NESARC population, not just the sample

3

<!-- page 4 -->

# Overview of Today’s Lecture, cont’d

* Consider a second example of fitting an SEM using the ESS data
* Discuss software options for fitting SEMs and performing LCA with complex sample survey data sets (Preview: not many!)
* Discuss how to describe these kinds of analyses in scientific publications

4

<!-- page 5 -->

# Conceptual Background

* **Critical Paper in this area:** Muthen and Satorra (1995); available on Canvas
* These authors described the conceptual and theoretical basis for fitting SEMs to complex sample survey data sets
* They established an estimation and inference framework for this setting: how should weighted estimates and design-adjusted SEs be computed?
* Stapleton (2006) provides a good overview of the conceptual background, and includes practical advice

5

<!-- page 6 -->

# Estimation of SEM Parameters

* “Conventional” SEM assumes that observations in a data set are independent and identically distributed (i.i.d., e.g., MVN)
* These assumptions seldom hold for complex samples; observations tend to be correlated
* Furthermore, ignoring **informative** survey weights (w.r.t. **variables** <u>or</u> **paths**) can lead to biased estimates of the parameters in an SEM, and misleading inferences

6

<!-- page 7 -->

# Estimation of SEM Parameters

* Recall the **fitting function** from **SEM Lecture #1**
* **Basic Idea (also applies to LCA):**
  * Compute **<u>weighted</u>** estimates of all of the distinct (sample) variances and covariances for variables in the model
  * When defining the overall likelihood function, apply the **final survey weight** to each individual’s contribution
  * Given the weighted (population estimate!) of the overall likelihood function, find estimates of the parameters in the SEM that minimize the function
* See Stapleton (2006), page 36, for details

7

<!-- page 8 -->

# Estimation of SEM Parameters, cont’d

* Once parameters have been estimated, standard likelihood-based computations of standard errors (e.g., OIM, or observed information matrix in Stata) are **not** performed
  – These ignore the sample design features!
* Given the estimates, we then apply some form of Taylor Series Linearization or replication to compute design-based estimates of the variances
* Remember that variability in the weights also needs to be accounted for in estimation of standard errors!

8

<!-- page 9 -->

# Variance Estimation

* Muthen and Satorra (1995) develop a TSL solution for SEM models, and demonstrate its superiority over standard approaches to variance estimation when fitting SEMs to complex sample survey data
* Variance estimates for estimated parameters in SEMs can be <u>extremely biased</u> when assuming that the data arise from a simple random sample
* Stapleton (2006) performed a series of simulation studies to examine design effects when fitting SEMs to complex samples

9

<!-- page 10 -->

# Variance Estimation

* Collectively, this method (estimation based on a weighted likelihood function, followed by non-parametric design-based variance estimation) is also referred to as **pseudo-maximum likelihood (PML) estimation**; the best approach in Stapleton (2006)
* This is no different from other design-based methods that you will learn about!
* Replication methods **not** widely available (yet)

10

<!-- page 11 -->

# Variance Estimation, cont’d

* What about simply multiplying estimated standard errors (assuming SRS) by average design effects prepared by a data producer?
  - May be OK if weights are uninformative, but ignorance of weights can lead to biased estimates
* What about adjusting weights by average design effects, and normalizing weights?
  - What estimates should be used to compute the average design effects? Path coefficients? Variances?
  - Approach has worked well in previous studies, but Stapleton (2006) shows that it does not work well for SEM

11

<!-- page 12 -->

# Adjustments to Fit Statistics

* The standard Chi-square test statistic for goodness of fit (based on **weighted** parameter estimates) needs to be **adjusted** to account for the complex sampling features
* The basic idea is similar to the Rao-Scott adjustment for design effects you will learn about in other analysis courses (e.g., 701)
* See Stapleton (2006, page 37) for details

12

<!-- page 13 -->

# Adjustments to Fit Statistics, cont’d

* Other commonly used measures of fit can also be easily adapted to the complex sample setting, by replacing unweighted quantities used to compute the measures of fit with the corresponding weighted quantities
  – RMSEA
  – CFI
* Everything is just extended to the finite population inference framework!

13

<!-- page 14 -->

# Alternative Model-Based Approach

* Also discussed in Muthen and Satorra (1995)
* **Basic idea:** fit a structural equation model using <u>random effects</u> to account for clustering (similar to multilevel modeling)
* Muthen and Satorra refer to this as a “disaggregated” approach to the analysis
* This approach would be best if there are specific questions related to between-cluster variance in relationships of interest

14

<!-- page 15 -->

# Available Software

* What software procedures can be used to fit SEMs to complex sample survey data?
  - Mplus (Recommended)
  - The `lavaan.survey` package in R (Oberski, 2014; see article on Canvas; recently dropped from CRAN?)
  - PROC LCA (LCA only) or IVEware + CALIS in SAS
  - Stata: `svy: sem/gsem` after running `svyset`
  - Latent GOLD
  - LISREL (see Appendix example in Stapleton, 2006)
  - *Nothing else (as of this class)!*

15

<!-- page 16 -->

# Revisiting the NESARC Design

* Recall that a complex sample design was used for the NESARC, involving stratified multi-stage sampling of U.S. households
* Unfortunately, the design information provided in the public-use data set prohibits straightforward variance estimation!
* Why? Consider the output on the next slide from Stata's `svydes` command...

16

<!-- page 17 -->

# Available NESARC Design Variables

```
Survey: Describing stage 1 sampling units

      pweight: w2weight
          VCE: linearized
  Single unit: missing
     Strata 1: w2stratum
         SU 1: w2psu
        FPC 1: <zero>
                                      #Obs per Unit
                              ----------------------------
Stratum    #Units     #Obs      min       mean      max
--------  --------  --------  --------  --------  --------
     101         2       257       101     128.5       156
     103         1*      131       131     131.0       131
     104         1*       73        73      73.0        73
     105         1*       50        50      50.0        50
     106         1*       59        59      59.0        59
     107         1*       25        25      25.0        25
     108         1*       27        27      27.0        27
     109         1*       20        20      20.0        20
     110         1*       16        16      16.0        16
     111         1*       20        20      20.0        20
     201         2        32        14      16.0        18
     203         1*       38        38      38.0        38
```

**Note that there are several strata with only one cluster!**

17

<!-- page 18 -->

# Dealing with “Singletons”

* We have a “singleton” problem, prohibiting the use of linearization
* Recall that TSL requires two clusters per stratum for variance estimation!
* We need to split singleton PSUs into two **random groups** (Muthen and Satorra, 1995)
  – Procedure does not bias variance estimates
* Within a PSU: even-numbered observations join one “cluster”, odd-numbered a second...

18

<!-- page 19 -->

# Dealing with “Singletons”

* **Note:** some random groups might be small, complicating subgroup analyses
* Another option would be to collapse “similar” strata, forming new pseudo-strata with multiple (2?) clusters present per pseudo-stratum
* But how do we know which strata are “similar”? May need to work with NESARC support staff...
* Some software provides “ad-hoc” options...e.g., see `help svyset` and `singleunit()` in Stata

19

<!-- page 20 -->

# Revisiting the NESARC LCA

* Given a fix for the variance estimation problem, let’s revisit the LCA that we performed last week
* Recall that we would like to examine possible latent classes defined by heavy drinking and the nonmedical use of four classes of prescription drugs in the past year
* But now, we want to estimate the probability of falling into each class in the **target NESARC population**, using the survey weights!

20

<!-- page 21 -->

# Revisiting the NESARC LCA

* Revised Mplus Syntax:

> **New cluster variable containing random groups for each stratum with a "singleton" PSU**

```
TITLE:        NESARC LCA Example, Complex Sampling Features
DATA:         FILE = M:\nesarc_w1w2_red_wts.dat;
VARIABLE:     NAMES = idnum anysedy anytrqy anyopiy anystmy hd w2weight w2psu
               w2stratum anyduda w2_psu_new;
          AUXILIARY = idnum anyduda;
              USEVARIABLES = anysedy anytrqy anyopiy anystmy hd w2weight
               w2stratum w2_psu_new;
              CATEGORICAL = anysedy anytrqy anyopiy anystmy hd;
          WEIGHT = w2weight;
          CLUSTER = w2_psu_new;
          STRATIFICATION = w2stratum;
          MISSING = anysedy (999) anytrqy (999) anyopiy (999) anystmy (999) hd (999);
              CLASSES = c(3);
ANALYSIS:     TYPE = MIXTURE;
          TYPE = COMPLEX;
PLOT:         TYPE = PLOT3;
              SERIES = anysedy anytrqy anyopiy anystmy hd(*);
OUTPUT:       TECH11;   !TECH14 (BOOTSTRAP LRT) NOT AVAILABLE WHEN TYPE = COMPLEX
SAVEDATA:     FILE IS M:\cprobs.dat;
              SAVE IS CPROB;
```

21

<!-- page 22 -->

# Revisiting the NESARC LCA

* Selected output (“SRS” results in parentheses)

Information Criteria

| | |
| :--- | :--- |
| Akaike (AIC) | 52232.822 |
| **Bayesian (BIC)** | **52376.525** |
| Sample-Size Adjusted BIC<br>$(n^* = (n + 2) / 24)$ | 52322.500 |

Chi-Square Test of Model Fit for the Binary and Ordered Categorical
(Ordinal) Outcomes**

Pearson Chi-Square

| | |
| :--- | :--- |
| **Value** | **38.138 (32.784; Less evidence of a good fit)** |
| Degrees of Freedom | 13 |
| **P-Value** | **0.0003 (0.0018)** |

Likelihood Ratio Chi-Square

| | |
| :--- | :--- |
| Value | 36.551 (37.433) |
| Degrees of Freedom | 13 |
| P-Value | 0.0005 (0.0004) |

22

<!-- page 23 -->

# Revisiting the NESARC LCA

FINAL CLASS COUNTS AND PROPORTIONS FOR THE LATENT CLASS PATTERNS  
**BASED ON ESTIMATED POSTERIOR PROBABILITIES**

| Latent Classes | | |
|---|---|---|
| 1 | 1342.04871 | 0.03873 (0.03181) |
| 2 | 302.56308 | 0.00873 (0.00885) |
| 3 | 33008.38821 | 0.95254 (0.95935) |

CLASSIFICATION QUALITY

| | |
|---|---|
| **Entropy** | **0.892 (0.904)** |

23

<!-- page 24 -->

# Revisiting the NESARC LCA

RESULTS IN PROBABILITY SCALE

**Latent Class 1**

ANYSEDY

Category 1 0.919 0.054 17.162 0.000

**Category 2 0.081 0.054 1.505 0.132 (NOTE: No longer evidence of this probability > 0!)**

ANYTRQY

Category 1 0.936 0.055 17.102 0.000

**Category 2 0.064 0.055 1.179 0.238 (SAME CHANGE: SEs Increase!)**

ANYOPIY

Category 1 0.791 0.111 7.132 0.000

**Category 2 0.209 0.111 1.879 0.060 (MARGINAL EVIDENCE)**

ANYSTMY

Category 1 0.929 0.029 32.011 0.000

Category 2 0.071 0.029 2.439 0.015

HD

Category 1 0.201 0.096 2.095 0.036

Category 2 0.799 0.096 8.324 0.000 **(STILL THE HEAVY DRINKING CLASS...)**

24

<!-- page 25 -->

# Revisiting the NESARC LCA

VUONG-LO-MENDELL-RUBIN LIKELIHOOD RATIO TEST FOR 2 (H0) VERSUS 3 CLASSES

| | |
| :--- | :--- |
| H0 Loglikelihood Value | -26142.789 |
| 2 Times the Loglikelihood Difference | 86.756 |
| Difference in the Number of Parameters | 6 |
| Mean | 21.930 |
| Standard Deviation | 28.162 |
| **P-Value** | **0.0263** |

LO-MENDELL-RUBIN ADJUSTED LRT TEST

| | |
| :--- | :--- |
| Value | 85.395 (82.177) |
| **P-Value** | **0.0279 (0.0000)** |

**We still reject the null hypothesis of two classes, but the evidence is not as strong when accounting for the complex sampling features!**

25

<!-- page 26 -->

# Revisiting the NESARC LCA

* Predicted plots look essentially the same, BUT:
  * Predicted probabilities have higher standard error associated with them, due to the stratified cluster sampling
* Use of weights did not make a big difference in the estimated probabilities (for classes or items); this will not always be the case!

26

<!-- page 27 -->

# An Example using the ESS Data

* We’ll now consider a second example of SEM for complex samples, analyzing the ESS-Belgium data
* One of the latent factors will be defined by the following variables:
  * IMSMETN: The country should allow many/few immigrants of the same race / ethnicity as the majority (1 = Many, 4 = Few)
  * IMDFETN: “ “ of different race / ethnicity “ “
  * IMPCNTR: “ “ from poorer countries outside Europe
* **Possible latent factor:** general attitude toward immigration

27

<!-- page 28 -->

# An Example using the ESS Data

* We will then predict the latent immigration factor with a second latent factor, indicated by five variables measuring **trust in authorities**:
  – TRSTPRL (parliament, range 0 to 10, 88 missing)
  – TRSTLGL (legal system)
  – TRSTPLC (police)
  – TRSTPLT (politicians)
  – TRSTPRT (political parties)

28

<!-- page 29 -->

# An Example using the ESS Data

* Is this a complex sample?
  - Typically, one interviewer is assigned to work in one PSU (Interviewer $\Leftrightarrow$ PSU)
  - We will use the inverse of the response rate within a PSU (interviewer) as the final weight, for illustration purposes
* Note that values of 8 on the immigration variables represent missing data; always important to check when prepping for Mplus!

29

<!-- page 30 -->

# SEM for the ESS Example

30

*[Figure: This path diagram illustrates a structural equation model (SEM) with no coordinate axes, comparing two latent variables represented as ovals: "Trust" and "Immigration." The main pattern shows "Trust" measured by five observed indicator rectangles (top row) and having a direct causal arrow pointing to "Immigration," which is measured by three observed indicator rectangles (bottom row), with all endogenous variables connected to respective circular error terms ($\varepsilon_1$ through $\varepsilon_9$).]*

<!-- page 31 -->

# ESS Example: Mplus Syntax

TITLE: ESS CFA Example, Complex Sampling Features
DATA: FILE = M:\ess_belgium_red.dat;
VARIABLE: NAMES = intnum trst1 trst2 trst3 trst4 trst5
imm1 imm2 imm3 weight;
USEVARIABLES = intnum trst1 trst2 trst3 trst4 trst5
imm1 imm2 imm3 weight;
**WEIGHT = weight;**
**CLUSTER = intnum;**
MISSING = trst1 (88) trst2 (88) trst3 (88) trst4 (88) trst5 (88)
imm1 (8) imm2 (8) imm3 (8);
ANALYSIS: **TYPE = COMPLEX;**
**MODEL: F1 BY imm1 imm2 imm3;**
**F2 BY trst1 trst2 trst3 trst4 trst5;**
**F1 ON F2;**
OUTPUT: STANDARDIZED SAMPSTAT;

31

<!-- page 32 -->

# ESS Example: R Syntax

```r
library(survey)
library(lavaan)
library(lavaan.survey)

# Create a survey design object specifying the clusters and weights
svydes <- svydesign(ids=~intnum, prob=~weight, data=ess.belgium)

# Fit model using lavaan()
belg.model <- ‘ model specification goes here in single quotes ‘
model.fit <- lavaan(belg.model, data=ess.belgium, …)

# Given a model fit object generated by lavaan(), submit it as the
# lavaan.fit argument to lavaan.survey()
survey.fit <- lavaan.survey(lavaan.fit=model.fit, survey.design=svydes)
summary(survey.fit)
```

32

<!-- page 33 -->

# ESS Example: Mplus Output

RMSEA (Root Mean Square Error Of Approximation)

| | | |
| :--- | :--- | :--- |
| Estimate | | 0.103 |
| 90 Percent C.I. | 0.094 | 0.112 |
| **Probability RMSEA <= .05** | | **0.000 (fit not great...)** |

CFI/TLI

| | |
| :--- | :--- |
| **CFI** | **0.917** |
| TLI | 0.878 |

33

<!-- page 34 -->

# ESS Example: Mplus Output

```text
MODEL RESULTS
                                                    Two-Tailed
                    Estimate       S.E.  Est./S.E.    P-Value

 F1       BY
    IMM1               1.000      0.000    999.000    999.000
    IMM2               1.315      0.053     24.621      0.000
    IMM3               1.122      0.047     23.938      0.000

 F2       BY
    TRST1              1.000      0.000    999.000    999.000
    TRST2              0.877      0.032     27.088      0.000
    TRST3              0.667      0.033     20.129      0.000
    TRST4              1.234      0.043     28.907      0.000
    TRST5              1.205      0.045     26.807      0.000

 F1       ON
    F2                -0.099      0.013     -7.796      0.000
```

**With higher trust, more immigration desired!**

34

<!-- page 35 -->

# ESS Example: Mplus Output

R-SQUARE **(Note possible reasons for the poor fit!)**

| Observed Variable | Estimate | S.E. | Est./S.E. | Two-Tailed P-Value |
| :--- | :--- | :--- | :--- | :--- |
| TRST1 | 0.528 | 0.027 | 19.784 | 0.000 |
| **TRST2** | **0.374** | **0.027** | **13.664** | **0.000** |
| **TRST3** | **0.270** | **0.025** | **10.944** | **0.000** |
| TRST4 | 0.847 | 0.019 | 43.838 | 0.000 |
| TRST5 | 0.817 | 0.019 | 42.526 | 0.000 |
| IMM1 | 0.590 | 0.033 | 17.783 | 0.000 |
| IMM2 | 0.872 | 0.026 | 34.060 | 0.000 |
| IMM3 | 0.685 | 0.032 | 21.597 | 0.000 |

| Latent Variable | Estimate | S.E. | Est./S.E. | Two-Tailed P-Value |
| :--- | :--- | :--- | :--- | :--- |
| **F1** | **0.068** | **0.017** | **3.966** | **0.000** |

35

<!-- page 36 -->

# Some Final Thoughts

* The same output is obtained using R / Stata / SAS / etc., but Mplus does a better job of providing common design-adjusted measures of fit
* The aforementioned software can fit design-adjusted SEMs to continuous and categorical variables
* Important to assess whether weights are informative about key estimates; if they are not, using them in estimation may inflate standard errors artificially (just as in simpler regression models!)

36
