---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module2_Lecture2_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "**Applications of Statistical Modeling:**"
original: "applications_stats_modeling_SURV617/lectures/Module2_Lecture2_Fall2025.pdf"
pages: 41
sha256: "2442a4ab0935e21a735b094b75864cc60ca9e38a6a54a67ed99311ab69415da8"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:41"
---

<!-- page 1 -->

# **Applications of Statistical Modeling:**
## Module #2, Lecture #2

### Multiple Group Analysis (MGA) and
### Latent Class Analysis (LCA)

Instructor: Brady T. West

Email: [email]

1

<!-- page 2 -->

# Review of Structural Equation Models

* Full SEMs generally include:
  - Observed variables and latent variables
  - A measurement model and a structural model
* SEMs use sample covariances/means to estimate the parameters of a hypothesized model, and we can examine the model <u>plausibility</u>
* SEM estimation: MLE, ADF, CVM, Bootstrapping SE
* Model fit criteria: Chi-square test, CFI, RMSEA, AIC / BIC, LRT
* Modification indices
* SEM examples: CFA, path models, multilevel models, LGCM, and others

2

<!-- page 3 -->

# Lecture Overview

* In this lecture, we will test **measurement invariance** in SEMs via **multiple group analysis**, and implement **latent class analysis** when the latent variables in SEMs are categorical
* In general, model specification depends on your hypothesis, and model diagnostics are necessary for model comparison and goodness of fit assessment
* We’ll give examples and discuss software options

3

<!-- page 4 -->

# The NESARC: Background

* Prospective longitudinal study of a national probability sample of adults (age 18+) in the United States
* Two Waves: 2001-2002 and 2004-2005; $n = 34,653$, 31 variables (PY = past-year drug use indicator variables at Wave 2)
* Available on Canvas (nesarc_w1w2.XXX); codebooks for W1 and W2 are also available
* FTF Household Interviews administered by Census Bureau Interviewers, using CAPI; one respondent per household

4

<!-- page 5 -->

# The NESARC: Background

* **A complex sample design was used:** the data set combining W1 and W2 responses includes weight, stratum, and cluster variables
* Weights for W2 respondents are adjusted to account for attrition from W1 to W2
  - W1 Response Rate: 81.0%
  - W2 Response Rate: 86.7% (Overall: 70.2%)
* Questions are included on mood, anxiety, alcohol use, and drug use (see Canvas)

5

<!-- page 6 -->

# What is Multiple Group Analysis?

* SEMs can accommodate interaction terms by treating them just like any other (observed) exogenous variables
* What happens when there are many interactions, such that a given SEM may have very different coefficients in different groups defined by a moderating <u>factor</u> (e.g., sex)?
* In this case we might consider MGA, and test whether particular paths vary across groups

6

<!-- page 7 -->

# What is Multiple Group Analysis?

* Multiple Group Analysis (MGA) can handle:
  – Interactions between **latent factors** and the moderating categorical variable
  – Any number of groups defined by the moderating categorical variable (given large sample sizes)
  – Randomized designs, where the coefficients of an SEM might vary across treatment and control groups
* Most SEM software provides MGA options

7

<!-- page 8 -->

# Steps in MGA

* We want to understand if selected groups differ in terms of the coefficients in a <u>plausible</u> structural equation model
* Doing this correctly requires following a fairly standardized testing approach
* **Basic idea:** Start with the same model but different coefficients in each group, and then start constraining coefficients to be equal across the groups; does the fit become worse?

8

<!-- page 9 -->

# Steps in MGA: CFA
(a.k.a. testing for **measurement invariance**)

* Make sure to input raw data or covariance matrices (not correlation matrices; need variances!)

1. Estimate the SEM for all groups with no equality constraints for any parameters
2. Perform a global test of whether there are any differences across the groups; if there are any differences, the MGA begins
3. <u>Depending on your theory</u>, constrain one, multiple, or all factor loadings to be equal across the groups

9

<!-- page 10 -->

# Steps in MGA: CFA (cont’d)

4. If significant differences exist between the constrained and unconstrained models, STOP (the factors are measuring different concepts!)
5. Consider testing equal intercepts, equal means, and equal error variances between the groups (the difference between **strong** and **weak invariance**)
6. Ideally, the same factor structure holds in both groups, and there are no differences in fit between the fully unconstrained and fully constrained models; report the results either way

10

<!-- page 11 -->

# Steps in MGA: Path Models

* Make sure to input raw data or covariance matrices (not correlation matrices; need variances!)
1. Simultaneously estimate the model for all groups, with no equality constraints
2. Constrain one, multiple, or all path coefficients to be equal across the groups, <u>depending on theory</u>
3. Test for significant differences, choosing the simpler (constrained) model if there are none
4. Report the findings

11

<!-- page 12 -->

# Steps in MGA: Full SEM

* Make sure to input raw data or covariance matrices (not correlation matrices; need variances!)

1. Simultaneously estimate the model for all groups with no equality constraints
2. Evaluate the <u>measurement</u> part of the model (e.g., CFA) by constraining these parameters to be equal across groups; if there are differences, STOP
3. If there are no differences, consider constraining some coefficients defining the <u>structural</u> part of the model to be equal; report the results

12

<!-- page 13 -->

# Tests for Comparing Models in MGA

* When comparing two nested models according to the steps discussed above, we use a general fitting function that sums fitting functions defined for each group (see Lec. 1):

$$F = \sum_{g=1}^{G} \left( \frac{N_g}{N} \right) F_g (S_g, \Sigma_g(\theta))$$

*where*

$N_g =$ sample size in g-th group

$$N = N_1 + N_2 + \dots + N_g$$

13

<!-- page 14 -->

# Tests for Comparing Models in MGA

* Estimation then minimizes the overall fitting function, across all groups and constraints
* We then compute the overall chi-square statistic for assessing model fit
* Subsequent models with constraints introduced can refer the ***difference*** in chi-square statistics for the two nested models to a chi-square distribution, with DF = the difference in DF values for the two models
* This type of test should sound familiar (LRT)!

14

<!-- page 15 -->

# MGA Example in R

* MGA is possible using the `lavaan` package in R; we will consider an example using ESS data
* Specific, standardized tests of measurement invariance in the CFA context are possible using the `measurementInvariance()` function in the R package `semTools`
* Visit this site for details: [http://lavaan.ugent.be/tutorial/groups.html](http://lavaan.ugent.be/tutorial/groups.html)

15

<!-- page 16 -->

# MGA Example in R

* **Data:** ESS Belgium Data
* **Problem:** Is there measurement invariance in the way that a latent construct of “trust in leadership” is measured across groups of respondents defined by whether the response rates of their interviewers are above 50%?
* Observed indicators of latent construct:
  – Trust in politicians
  – Trust in political parties
  – Trust in Parliament

16

<!-- page 17 -->

# MGA Example in R

* First, some data management:

```r
load("ess_belgium.rdata")

ess_belgium$int50[ess_belgium$int_rr <= 50] <- 1
ess_belgium$int50[ess_belgium$int_rr > 50] <- 0

summary(ess_belgium$int50)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
 0.0000  0.0000  0.0000  0.4756  1.0000  1.0000

ess.red <- ess_belgium[ess_belgium$trstplt != 88 &
   ess_belgium$trstprt != 88 & ess_belgium$trstprl != 88,]

dim(ess.red) # 1,674 cases for analysis
```

17

<!-- page 18 -->

# MGA Example in R

* Next, we fit the unconstrained model using the `cfa()` function, with the same factor structure but different parameters by group:

```r
library(lavaan)

trst.model <- '  trstlead =~ trstplt + trstprt + trstprl '

fit <- cfa(trst.model,
           data = ess.red,
           group = "int50")

summary(fit)
```

18

<!-- page 19 -->

# MGA Example in R

* In the summary, we will see estimated loadings, in addition to estimated variances and covariances of latent variables (errors too)
* By default, one loading for each factor will be fixed to 1 (for scaling)
* These results yield an initial look at invariance
* Next, **constrain** the factor loadings to be equal, and test the difference in model fit

19

<!-- page 20 -->

# MGA Example in R

```r
fit.loads <- cfa(trst.model,
            data = ess.red,
              group.equal = c("loadings"),
            group = "int50")

summary(fit.loads)

# See the handout from Lecture 1 for the resulting output
```

20

<!-- page 21 -->

# MGA Example in R

* The significant likelihood ratio test suggests that the fit of the constrained model is significantly worse than that of the saturated (unconstrained) model
* We would therefore stop, and conclude that we do not even have evidence of weak measurement invariance
* The two groups of interviewers appear to be measuring different constructs, based on the observed values on these three variables!
* The correlation seems weaker in the high RR group...

21

<!-- page 22 -->

# MGA Example in R

* Some additional thoughts:
  – The same approach can be used when using the `sem()` function in `lavaan` for MGA
  – See the aforementioned web page for examples of additional constraints that can be tested, following the steps discussed earlier...
  – Remember to STOP if the likelihood ratio test is significant at a given step! The fit of the constrained model is significantly worse...

22

<!-- page 23 -->

# Latent Class Analysis (LCA)

* In latent class analyses, the latent variables in an SEM are assumed to be **categorical**, and indicated by a number of binary indicators
* This approach is quite useful when a variety of error-prone binary indicators are thought to represent the behaviors / features of different classes of individuals
* **For example:** various motives for nonmedical use of prescription drugs (pain? recreation?)

23

<!-- page 24 -->

# Latent Class Analysis (LCA)

* Objectives of LCA:
  – Identify binary items (variables) in the data set that are correlated and indicate classes
  – Estimate class probabilities for each case
  – Relate class probabilities to covariates
  – Classify individuals into classes based on posterior probabilities according to the model

24

<!-- page 25 -->

# LCA Example

* Consider four indicators of motives for nonmedical use of prescription opioids: pain relief, sleep aid, get high, experiment
* A latent class model for these data <u>might</u> look like this:

25

<!-- page 26 -->

# LCA Example

* We could then add observed covariates to the model, possibly predicting membership in the latent classes (e.g., gender)
* **Possible classes in theory (do they exist?):**
  - <u>recreational users</u> (high probabilities of getting high and experimenting)
  - “<u>medical” users</u> (high probabilities of pain relief and using as a sleep aid)
  - <u>non-users</u> (low probabilities of all indicators)

26

<!-- page 27 -->

# LCA: Estimation

* First, we can write the **marginal probability** of one item $j$ being equal to 1 as ($K = \text{\# classes}$):

$$P(x_j = 1) = \sum_{k=1}^K \underbrace{P(c = k) \times}_{\text{latent class parameter (structure)}} \underbrace{P(x_j = 1 | c = k)}_{\text{item parameter (measurement)}}$$

* We can also write the **joint probability** for all $p$ items, <u>assuming conditional independence</u>, as follows: $P(x_1, x_2, \dots, x_p) = Likelihood =$

$$= \sum_{k=1}^K P(c = k)P(x_1 | c = k)P(x_2 | c = k)\dots P(x_p | c = k)$$

27

<!-- page 28 -->

# LCA: Estimation

* The question is how many classes are we hypothesizing? We might increase the number of classes (K) until finding a reasonable fit...
* We now have the essential ingredients for computing **posterior probabilities**, which are used to compute the probability of being in a class, given data (Bayes' rule):

$$P(c = k \mid x_1, x_2, \dots, x_p) = \frac{P(c = k)P(x_1 \mid c = k)P(x_2 \mid c = k)\dots P(x_p \mid c = k)}{P(x_1, x_2, \dots, x_p)}$$

28

<!-- page 29 -->

# LCA: Estimation

* So how do we estimate the parameters that enable these posterior classifications?
* We use maximum likelihood estimation, either directly or via the **Expectation Maximization (EM) algorithm**
* **Idea:** maximize the expectation of the complete-data log-likelihood, given the input indicator variables, with respect to the parameters
* We treat $c$ as missing data (we don’t know the latent classes); we compute *expectations* (E) of $c$, and then iteratively maximize (M) the likelihood, given these

29

<!-- page 30 -->

# LCA: Estimation

* The probabilities of class membership can also depend on **covariates** (multinomial logistic regression models), which introduces additional parameters; see Lanza et al. (2007)
* Cases in the data set can be assigned to classes based on the modal probability, according to the model, or by using a stochastic method
* See Biemer and Wiesen (2002) or Lanza et al. (2007) for additional technical details

30

<!-- page 31 -->

# LCA: Assessing Model Fit

* After computing final parameter estimates (and standard errors), we examine how well the model fits the observed data
* Depending on the number of classes chosen, there can be a **large number of parameters**
* **How well does the model replicate the observed joint probabilities (slide 27)?**
* We use similar Chi-square tests of goodness of fit, to start with, for different class solutions

31

<!-- page 32 -->

# LCA: Assessing Model Fit

* We compare competing class solutions using the **Bayesian Information Criterion (BIC):**

$$
\begin{aligned}
&BIC = -2 \log L + h \times \ln(n) \\
&where \\
&h = \text{ number of parameters estimated} \\
&n = \text{ sample size} \\
&L = \text{ model likelihood}
\end{aligned}
$$

* We choose the model with the **smallest** BIC value as the preferred solution

32

<!-- page 33 -->

# LCA: Assessing Model Fit

* Alternative likelihood ratio tests are also possible for comparing models with $K$ and $K-1$ classes, and implemented in Mplus:
  - Vuong-Lo-Mendell-Rubin LRT (TECH11 in Mplus)
  - Bootstrapped LRT (TECH14 in Mplus); **preferred**
  - The standard LRT statistic does not have a chi-square distribution in this case, due to parameters being on the boundary of their parameter space
  - Simulate the empirical distribution of the LRT statistic via many (~100) bootstrapped samples, which are generated based on estimates from the $K-1$ (null) model

33

<!-- page 34 -->

# LCA: Assessing Model Fit

* Another criterion for assessing the quality of classifications based on the model is the **Entropy** statistic
* For this statistic, a value close to 1 indicates good classification, in that many cases have posterior class probabilities that are close to 1 or 0 (0.8 is considered a “good” fit)

34

<!-- page 35 -->

# LCA: Additional Notes

* LCA is sometimes referred to as “person-centered” analysis, given that classification of cases based on observed categorical data is the ultimate goal (rather than identifying a reasonable correlation structure among vars)
* LCA is popular in survey settings because it allows for measurement error in the categorical indicators, and class probabilities are based on *multiple* categorical variables

35

<!-- page 36 -->

# LCA: Additional Notes

* At least 3 binary indicators are needed for estimating a two-class model
* With only 2 binary indicators, additional assumptions are needed to make parameters of interest identifiable:
  * **Hui-Walter** assumptions: Assume equal error probabilities among groups defined by a covariate (e.g., gender)
* Note that LCA enables estimation of error probabilities in general (e.g., two classes, drug users vs. non-drug users, can estimate the probability that indicator of marijuana use is 1 for non-users)

36

<!-- page 37 -->

# LCA: Additional Notes

* LCA can also be used when the observed variables are ordinal or multinomial
* **Available Software:**
  * Mplus (**Recommended**)
  * R: poLCA ([https://www.r-bloggers.com/example-8-21-latent-class-analysis/](https://www.r-bloggers.com/example-8-21-latent-class-analysis/)); NPBayesImpute for multiple imputation
  * Stata: `gsem` command with `lclass` option
  * PROC LCA in SAS (Lanza et al. 2007)
  * Latent GOLD
  * Some others, but these are the most popular choices

37

<!-- page 38 -->

# Example R Code for LCA

```r
library(poLCA)
lca.fit <- poLCA(cbind(x1, x2,
  x3, x4, x5) ~ 1,
  maxiter=50000, nclass=3,
  nrep=10, data=ds)
lca.fit
```

\# See this web page for a really cool example:
[http://statistics.ohlsen-web.de/latent-class-analysis-polca/](http://statistics.ohlsen-web.de/latent-class-analysis-polca/)

38

<!-- page 39 -->

# Example Mplus Code for LCA

```
TITLE: Latent Class Analysis Example
DATA: FILE = c:\temp\lca.dat;
VARIABLE:NAMES = x1-x5;             ! 5 binary vars.
                USEVARIABLES = x1-x5 male;
                CATEGORICAL = x1-x5;
                CLASSES = c(3);            ! 3 class sol’n
ANALYSIS:TYPE = MIXTURE;            ! Requests LCA
MODEL:   %OVERALL%
                c#1-c#2 ON male;           ! Only if
  covars.
PLOT:           TYPE = PLOT3;              ! Profile plots
                SERIES = x1-x5(*);
OUTPUT:  TECH11 TECH14;             ! Special LRTs
SAVEDATA:FILE IS cprobs.dat;        ! Save data
                SAVE IS CPROB;
```

39

<!-- page 40 -->

# Take-home Points

* Multiple group analysis can handle interaction terms and test whether particular paths vary across groups
  - Has a fairly standardized testing approach: starting from strong invariance to weak invariance or from measurement model to structural model
* Latent class analysis groups individuals into classes based on posterior probabilities according to the model of observed indicator variables
  - Assumes conditional independence
  - The class allocation probabilities can depend on covariates

40

<!-- page 41 -->

# Thinking Ahead

* In next week's class, we'll consider a full example of a latent class analysis using real survey data on drug use
* In two weeks, we'll discuss how complex sampling features are incorporated into structural equation model analyses
* Keep making progress with your final project!
* **Suggestions:** keep your analysis plan **simple**, focus on **carefully motivating and describing your model**, and make sure your results are **consistent** with your modeling approach!

41
