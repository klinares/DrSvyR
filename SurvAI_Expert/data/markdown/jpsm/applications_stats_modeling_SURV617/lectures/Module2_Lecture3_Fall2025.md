---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module2_Lecture3_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "**Applications of Statistical Modeling:**"
original: "applications_stats_modeling_SURV617/lectures/Module2_Lecture3_Fall2025.pdf"
pages: 39
sha256: "f4243e6a0359d6f8f07753e3022d7daca4a4e32939ba37d717ca81225687cf33"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:42"
---

<!-- page 1 -->

# **Applications of Statistical Modeling:**
## Module #2, Lecture #3

Applying LCA to Data from the National Epidemiologic Survey on Alcohol and Related Conditions (NESARC)

Instructor: Brady T. West

Email: [email]

1

<!-- page 2 -->

# Nonmedical Use of Prescription Medication (NMUPM)

* Nonmedical use of prescription medications has become a critical public health problem in the United States, with serious health implications (addiction, illness, co-ingestion)
* **Brief Definition:** The use of prescription medications not actually prescribed to a person by a doctor, or in a manner not intended by the prescribing clinician

2

<!-- page 3 -->

# Research Question

* The longitudinal nature of the NESARC design allows us to address causal questions!
* **Primary Research Question:** Does past-year NMUPM in 2001-2002 predict the probability of developing substance use disorders three years later, in 2004-2005?

3

<!-- page 4 -->

# Measurement Error?

* NESARC respondents indicate whether they have engaged in NMUPM to a live human interviewer in the FTF interviews
* Because this is a sensitive behavior, these reports may be subject to measurement error
* We will use LCA to identify possible classes of individuals based on (error-prone?) indicators of past-year nonmedical use of 4 prescription medications, and heavy drinking (in ‘01-’02)

4

<!-- page 5 -->

# Measurement Error?

* The four prescription medication classes:
  - Opioids / Analgesics
  - Stimulants
  - Tranquilizers
  - Sedatives
* Allowing for possible measurement error, we will use these four indicators and the indicator of heavy drinking to determine classes of individuals based on their reported behaviors

5

<!-- page 6 -->

# Analytic Approach

* Identify <u>and profile</u> classes of individuals (LCA)
* In a separate step, use the predicted latent classes in 2001-2002 to predict the probability of developing any type of substance use disorder in 2004-2005
* For details regarding this type of multi-step approach to using latent classes for predicting a **distal outcome**, see Asparouhov and Muthen (2014a, 2014b) on Canvas

6

<!-- page 7 -->

# Overall SEM

* Note how this model combines a latent class analysis (LCA), for **measurement**, and a logistic regression model, for **structure**
* We need a multi-step approach to the analysis (LCA, *then* predicting the **distal outcome**); otherwise, our DV is just another indicator!

7

<!-- page 8 -->

# Analytic Approach

* Ultimately, do the identified classes in 2001-2002 vary in terms of the probability of developing any SUD in 2004-2005?
* We will begin with simple descriptive statistics, continue with the LCA (including profiles), and then fit the overall model
* Next class, we will consider how to account for the complex sample design features of the NESARC when performing the analysis

8

<!-- page 9 -->

# The NESARC Data Set

* Available on Canvas (nesarc_w1w2_red.XXX)
* $n = 34,653$
* Variables of interest for this illustration:
  - HD: Heavy drinking in past year (01-02)
  - ANYSEDY: Any NM use of sedatives in past year
  - ANYTRQY: Any NM use of tranquilizers in past year
  - ANYOPIY: Any NM use of opioids in past year
  - ANYSTMY: Any NM use of stimulants in past year
  - ANYDUDA: Any drug use disorder in past year (04-05); diagnosis based on a series of survey questions related to alcohol, prescription drugs, and illicit drugs

9

<!-- page 10 -->

# Descriptive Statistics

* Normally, we should be computing weighted estimates (to describe the population) and design-based standard errors for the estimates; we will revisit this next class!
* For now, we will simply compute descriptive statistics for the sample, to get a sense of the data with which we are working

10

<!-- page 11 -->

# Descriptive Statistics

* Here are the percentages of cases having a 1 on each observed indicator variable (note that there is some missing data!):
  - Any Sedative Use: $397 / 34,643 = 1.15\%$
  - Any Tranquilizer Use: $273 / 34,652 = 0.79\%$
  - Any Opioid Use: $547 / 34,649 = 1.58\%$
  - Any Stimulant Use: $151 / 34,652 = 0.44\%$
  - Heavy Drinking: $7,960 / 34,540 = 23.05\%$

11

<!-- page 12 -->

# Latent Class Analysis (Mplus)

* Now, let’s perform the Latent Class Analysis (LCA) of these data in Mplus
* We choose Mplus because it provides “automatic” procedures for implementing the theoretically correct multi-step analysis; this approach is not readily implemented in other software
* Estimation of the model using “standard” LCA, treating the distal outcome like any other indicator, could lead to biased estimates of the relationships of interest

12

<!-- page 13 -->

# Latent Class Analysis (Mplus)

* Start $\rightarrow$ All Programs $\rightarrow$ Advanced Statistics $\rightarrow$ Mplus X.X $\rightarrow$ Mplus Editor
* File $\rightarrow$ New (Open New Program Editor)
* Enter the syntax on the following slide
* Save the program as a .inp (input) file
* Mplus $\rightarrow$ Run Mplus (or Alt + R); **any errors?**
* Examine and Interpret Output (.out file)
* Graphs $\rightarrow$ View Graphs $\rightarrow$ Select Graph

13

<!-- page 14 -->

# Syntax for <u>Initial</u> NESARC LCA

```
TITLE:            NESARC Latent Class Analysis Example
DATA:             FILE = M:\nesarc_w1w2_red.dat;
VARIABLE: NAMES = idnum anysedy anytrqy anyopiy anystmy hd
                  anyduda;
                  AUXILIARY = idnum anyduda; ! for saved data file
                  USEVARIABLES = anysedy anytrqy anyopiy anystmy
   hd;
                  CATEGORICAL = anysedy anytrqy anyopiy anystmy
   hd;
                  MISSING = anysedy (999) anytrqy (999) anyopiy
   (999) anystmy (999) hd (999);
                  CLASSES = c(3);
ANALYSIS: TYPE = MIXTURE;
PLOT:             TYPE = PLOT3;
                  SERIES = anysedy anytrqy anyopiy anystmy hd(*);
OUTPUT:   TECH11 TECH14;
SAVEDATA: FILE IS M:\cprobs.dat;
                  SAVE IS CPROB; ! save predicted class membership
```

14

<!-- page 15 -->

# LCA Output

* Always best to start with plots of the LCA solution first; the Mplus output can be extensive and difficult to process
* Default graphs can be edited; you’ll usually want to edit the X-axis (Graphs $\rightarrow$ View Graphs $\rightarrow$ Estimated Probabilities, Right-click on X-axis, Axis Properties, Edit)
* These graphs enable you to **profile** the three estimated latent classes

15

<!-- page 16 -->

# Initial Plot of Three-Class Solution

1
0.9
0.8
0.7
0.6
0.5
0.4
0.3
0.2
0.1
0

* Class 1, 3.2%
* Class 2, 0.9%
* Class 3, 95.9%

AnySedY
AnyTrqY
AnyOpiY
AnyStmY
HD

16

<!-- page 17 -->

# Initial Plot of Three-Class Solution

* We see evidence of three distinct classes, with Class 3 being the most common class
* Class 3 (green) seems to be the “non-users” who occasionally drink heavily
* Class 1 (red) seems to be the “occasional users” who dabble in NMUPM and drink heavily (highest estimated probability)
* Class 2 (blue) are the rare problematic cases with high probabilities of NMUPM **and** HD

17

<!-- page 18 -->

# Three-Class Solution?

* This may not be the only solution! What about four classes? Five classes? Let’s take a closer look at the output...

18

<!-- page 19 -->

# Model Fit: Three-Class Solution

Information Criteria

| | |
| :--- | :--- |
| Akaike (AIC) | 49852.105 |
| Bayesian (BIC) | **49995.809** |
| Sample-Size Adjusted BIC | 49941.783 |
| $(n^* = (n + 2) / 24)$ | |

Chi-Square Test of Model Fit for the Binary and Ordered Categorical
(Ordinal) Outcomes\*\*

Pearson Chi-Square

| | |
| :--- | :--- |
| Value | 32.784 |
| Degrees of Freedom | 13 |
| **P-Value** | **0.0018** |

Likelihood Ratio Chi-Square

| | |
| :--- | :--- |
| Value | 37.433 |
| Degrees of Freedom | 13 |
| **P-Value** | **0.0004** |

19

<!-- page 20 -->

# Estimated Class Probabilities

FINAL CLASS COUNTS AND PROPORTIONS FOR THE LATENT CLASS PATTERNS  
**BASED ON ESTIMATED POSTERIOR PROBABILITIES**

| Latent Classes | | |
| :---: | :--- | :--- |
| 1 | 1102.21969 | 0.03181 |
| 2 | 306.55037 | 0.00885 |
| 3 | 33244.22994 | 0.95935 |

CLASSIFICATION QUALITY

**Entropy 0.904**

20

<!-- page 21 -->

# Predicting Individual Classes

CLASSIFICATION OF INDIVIDUALS **BASED ON THEIR MOST LIKELY LATENT CLASS MEMBERSHIP**

Class Counts and Proportions

| Latent Classes | | |
| :---: | :---: | :---: |
| 1 | 429 | 0.01238 |
| 2 | 232 | 0.00669 |
| 3 | 33992 | 0.98093 |

Average Latent Class Probabilities for Most Likely Latent Class Membership (Row) by Latent Class (Column)

| | 1 | 2 | 3 |
| :---: | :---: | :---: | :---: |
| 1 | 0.701 | 0.140 | 0.159 |
| 2 | 0.121 | 0.874 | 0.005 |
| 3 | 0.023 | 0.001 | 0.976 |

21

<!-- page 22 -->

# Estimated Indicator Probabilities

RESULTS IN PROBABILITY SCALE

**Latent Class 1**

| | | | | |
| :--- | :---: | :---: | :---: | :---: |
| ANYSEDY | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 1 | 0.932 | 0.024 | 38.410 | 0.000 |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 2 | 0.068 | 0.024 | 2.812 | 0.005 |
| ANYTRQY | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 1 | 0.947 | 0.028 | 34.266 | 0.000 |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 2 | 0.053 | 0.028 | 1.930 | 0.054 |
| ANYOPIY | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 1 | 0.813 | 0.059 | 13.725 | 0.000 |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 2 | 0.187 | 0.059 | 3.154 | 0.002 |
| ANYSTMY | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 1 | 0.914 | 0.029 | 31.820 | 0.000 |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 2 | 0.086 | 0.029 | 2.979 | 0.003 |
| HD | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;Category 1 | 0.194 | 0.050 | 3.903 | 0.000 |
| &nbsp;&nbsp;&nbsp;&nbsp;**Category 2** | **0.806** | **0.050** | **16.232** | **0.000** |

22

<!-- page 23 -->

# VLMR Likelihood Ratio Test (TECH11)

VUONG-LO-MENDELL-RUBIN LIKELIHOOD RATIO TEST FOR 2 (H0) VERSUS 3 CLASSES

| | |
| :--- | :---: |
| H0 Loglikelihood Value | -24950.796 |
| 2 Times the Loglikelihood Difference | 83.488 |
| Difference in the Number of Parameters | 6 |
| Mean | 4.891 |
| Standard Deviation | 4.697 |
| **P-Value** | **0.0000** |

LO-MENDELL-RUBIN ADJUSTED LRT TEST

| | |
| :--- | :---: |
| Value | 82.177 |
| **P-Value** | **0.0000** |

**We strongly reject the null hypothesis of a two-class solution.**

23

<!-- page 24 -->

# Bootstrap Likelihood Ratio Test (TECH14)

PARAMETRIC BOOTSTRAPPED LIKELIHOOD RATIO TEST FOR 2 (H0) VERSUS 3 CLASSES

| | |
| :--- | :--- |
| H0 Loglikelihood Value | -24950.796 |
| 2 Times the Loglikelihood Difference | 83.488 |
| Difference in the Number of Parameters | 6 |
| **Approximate P-Value** | **0.0000** |
| Successful Bootstrap Draws | 10 |

**We reach the same result here.**

24

<!-- page 25 -->

# Output Data File

SAVEDATA INFORMATION

Order and format of variables

| | |
| :--- | :--- |
| ANYSEDY | F10.3 |
| ANYTRQY | F10.3 |
| ANYOPIY | F10.3 |
| ANYSTMY | F10.3 |
| HD | F10.3 |
| **IDNUM** | **F10.3** |
| **ANYDUDA** | **F10.3** |
| CPROB1 | F10.3 |
| CPROB2 | F10.3 |
| CPROB3 | F10.3 |
| C | F10.3 |

Save file
M:\cprobs.dat **(USEFUL FOR ADDITIONAL ANALYSIS AND EXPLORATION!)**

25

<!-- page 26 -->

# What About Four Classes?

* Now, we consider a four-class solution
* Only one part of the previous syntax needs to be modified in this case:
  `CLASSES = c(4);`
* After re-running this syntax, we re-consider a plot of the solution, along with the model fit statistics and likelihood ratio tests
* **Note:** this will take longer to run!

26

<!-- page 27 -->

# Plot of Four-Class Solution

27

<!-- page 28 -->

# Plot of Four-Class Solution

* We see that the four-class solution splits the most problematic group into even smaller groups (red and **black**), which are distinguished in terms of probability of use
* Class 1 appears to be particularly problematic
* Keeping future analysis in mind, this may or may not be ideal; one group may be too small, but could still warrant additional investigation

28

<!-- page 29 -->

# Model Fit: Four-Class Solution

Information Criteria

| | |
| :--- | :--- |
| Akaike (AIC) | 49836.896 |
| **Bayesian (BIC)** | **50031.318** |
| Sample-Size Adjusted BIC<br>$(n^* = (n + 2) / 24)$ | 49958.224 |

Chi-Square Test of Model Fit for the Binary and Ordered Categorical
(Ordinal) Outcomes**

Pearson Chi-Square

| | |
| :--- | :--- |
| Value | 7.105 |
| Degrees of Freedom | 7 |
| **P-Value** | **0.4181** |

Likelihood Ratio Chi-Square

| | |
| :--- | :--- |
| Value | 10.269 |
| Degrees of Freedom | 7 |
| **P-Value** | **0.1739** |

**Evidence of a better fit, although the BIC is slightly larger!**

29

<!-- page 30 -->

# VLMR Likelihood Ratio Test (TECH11)

VUONG-LO-MENDELL-RUBIN LIKELIHOOD RATIO TEST FOR 3 (H0) VERSUS 4 CLASSES

| | |
| :--- | :--- |
| H0 Loglikelihood Value | -24908.984 |
| 2 Times the Loglikelihood Difference | 27.073 |
| Difference in the Number of Parameters | 6 |
| Mean | 7.624 |
| Standard Deviation | 10.463 |
| **P-Value** | **0.0511** |

LO-MENDELL-RUBIN ADJUSTED LRT TEST

| | |
| :--- | :--- |
| Value | 26.648 |
| **P-Value** | **0.0532** |

**We would fail to reject the null hypothesis of a three-class solution (using p = 0.05 strictly!).**

30

<!-- page 31 -->

# Bootstrap Likelihood Ratio Test (TECH14)

PARAMETRIC BOOTSTRAPPED LIKELIHOOD RATIO TEST FOR 3 (H0) VERSUS 4 CLASSES

| | |
| :--- | :--- |
| H0 Loglikelihood Value | -24908.984 |
| 2 Times the Loglikelihood Difference | 27.073 |
| Difference in the Number of Parameters | 6 |
| Approximate P-Value | 0.0000 |
| Successful Bootstrap Draws | 20 |

**We see more evidence against the null here...slightly mixed results!**

31

<!-- page 32 -->

# Four-Class Solution: Summary

- Collectively, we do not have strong evidence in favor of the four-class solution (BIC, VLMR)
- Given the mixed results, we could go either way, but we choose to consider the three-class solution with our ultimate analysis in mind
  - Larger sample sizes for comparative purposes
- We proceed with the three-class solution, and now turn to predicting the 2004-2005 outcome indicating any drug use disorders

32

<!-- page 33 -->

# Modeling the Dependent Variable

* Per Asparouhov and Muthen (2014a, 2014b; see Canvas), trying to model the distal outcome and the latent classes simultaneously has many disadvantages
* Multi-step methods for independent modeling of the distal outcome given information from the LCA have been proposed
* We consider a simple two-step method here, using the **modal predicted class** from our LCA

33

<!-- page 34 -->

# Step 2: Logistic Regression

* We import the data set saved from Mplus back into Stata (or any other package)
* Then, we regress ANYDUDA on the predicted modal class, using standard logistic regression modeling techniques:

  `logit anyduda ib3.c, or`
* We could include covariates as well...

34

<!-- page 35 -->

# Interpretation of Estimates

```
Logistic regression                               Number of obs   =      34653
                                                  LR chi2(2)      =     558.72
                                                  Prob > chi2     =     0.0000
Log likelihood = -11018.003                       Pseudo R2       =     0.0247

------------------------------------------------------------------------------
      anyduda | Odds Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
--------------+---------------------------------------------------------------
            C |
            1 |   8.071624   .796949    21.15   0.000     6.651473    9.794991
            2 |   7.869833   1.04922    15.47   0.000     6.060128    10.21996
              |
        _cons |   .1032423   .0019227  -121.93   0.000     .0995419    .1070804
------------------------------------------------------------------------------
```

**Classes 1 and 2 have substantially increased odds of developing a substance use disorder three years from now, and do not appear to be different from each other. (Would accounting for class prediction uncertainty using a multi-step approach make a difference???)**

**Would be interesting to examine the same analysis for the four-class solution!**

35

<!-- page 36 -->

# Choosing Software...

* Any of the software discussed last week can be used to implement the “naïve” two-step approach...
  * See the worked R example referenced last week!
* Mplus offers nice graphing capabilities and is especially good at handling complex sampling features
* Mplus makes multi-step modeling approaches, accounting for the uncertainty in class predictions, “automatic”
  * See also Lanza et al. (2013), on Canvas, for implementation in SAS via PROC LCA

36

<!-- page 37 -->

# Multi-Step Alternatives

* Note that the two-step approach illustrated here does not recognize the possibility of <u>error</u> in the modal classes (i.e., cases did not have 100% probability of falling into their assigned classes)
* **One approach:** impute the class for each person multiple times based on referring random uniform draws to the posterior class probabilities based on the LCA, and perform multiple imputation analysis
* **Other approaches:** see Asparouhov and Muthen (2014a), or Lanza et al. (2013)

37

<!-- page 38 -->

# “Automatic” Multi-Step Approaches in Mplus

* If you wish to include predictors of latent class membership, include this line in the VARIABLE section of the syntax (**poLCA can also do this**):

AUXILIARY = MALE(R3STEP) BLACK(R3STEP) HISPANIC(R3STEP) OTHRACE(R3STEP);

* If you wish to predict continuous distal outcomes using your latent classes (Asparouhov and Muthen, 2014b):

AUXILIARY = DOUTCOME(BCH);

* Nothing “canned” yet in R, but see the presentation on Canvas from Tompsett and De Stavola (2022) about an approach that combines R and Stata to implement these approaches

38

<!-- page 39 -->

# Thinking Ahead

* These analyses have all ignored the complex sample design features of the NESARC
* Mplus offers the tremendous capability of computing weighted, design-based estimates of these types of complex models
* Next class, we will review the conceptual background of accounting for complex samples when fitting these models, and then revisit this example

39
