---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module1_Lecture5_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "**Applications of Statistical Modeling:**"
original: "applications_stats_modeling_SURV617/lectures/Module1_Lecture5_Fall2025.pdf"
pages: 51
sha256: "e2268d94202b5499430be72ef1d7d9db98490fb0f01b3ef7a0faff566adba22c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:40"
---

<!-- page 1 -->

# **Applications of Statistical Modeling:**
# Module #1, Lecture #5

## Case Study: Fitting Growth Curve Models to the Health and Retirement Study (HRS) Data

Instructor: Brady T. West

Email: [email]

1

<!-- page 2 -->

# Lecture Overview

- In this lecture, we’ll consider a variety of examples of fitting growth curve models to data from the HRS
- We will fit various models to the HRS data using R, and compare inferences based on the modeling procedures used
- Finally, we’ll discuss take-home points

2

<!-- page 3 -->

# Review: the HRS Data

* On Canvas, you’ll find R, SAS, Stata, and Excel versions of a file containing data from four waves of the Health and Retirement Study (HRS); the file names are hrs_reduced2.xxx
* Waves: 2000, 2002, 2004, 2006
* Note the “long” format of the data file
* We see data on total household assets, and demographics for the head of the household
* We also note complex sampling features!

3

<!-- page 4 -->

# Analysis Objectives

* **Objective 1:** Estimate <u>variance</u> among households in terms of growth in total household assets as a function of demographic characteristics
  * **Model:** A multilevel model for a normal outcome
  * **Aside:** Latent Class Growth Analysis
* **Objective 2:** Find the best model for the <u>overall marginal growth</u> in total assets for each educ. level
  * **Model:** A marginal linear model for a normal outcome
  * **Aside:** Penalized Splines for functional forms
* **Note the difference in the research objectives!**

4

<!-- page 5 -->

# Analysis Objectives

* **Objective 3:** Estimate <u>variance</u> among households in terms of changes in the probability of being in the Top 25% of households in total assets over time
  - **Model:** A multilevel model for a non-normal outcome (multilevel logistic regression/generalized linear mixed effect model)
* **Objective 4:** Estimate whether the <u>overall marginal differences</u> in the probability of being in the Top 25% between demographic groups are changing over time
  - **Model:** A marginal model for a binary outcome (GEE)
  - **No interest in variance between individuals**

5

<!-- page 6 -->

# First Step (Always): **Look at the Data!**

* Check the variables (time-invariant or varying), data structure (balanced or not), and missing data (coding, percentage, pattern)
* Always begin longitudinal analyses by looking at plots of means (or actual values) for the outcomes of interest over time, to get an initial sense of patterns that might be evident in the data!
* We’ll look at line plots of the actual total asset values for a sample of households, along with plots of the probability of being in the Top 25% for different demographic subgroups

6

<!-- page 7 -->

# Spaghetti Plot: Total Assets

* R Code:

```r
apply(is.na(hrs_reduced2),2,sum) #NA's

hrs3 <- subset(hrs_reduced2,hhidpn < 10060000)
# Note: only a small subsample

library(ggplot2)

ggplot(data=hrs3, aes(x=year, y=totassets000, group
  = hhidpn, colour = hhidpn)) + geom_line() +
  geom_point(size=4, shape=21, fill="white") +
  ylab("Total Assets (Thousands)") +
  theme(legend.position = "none")
```

7

<!-- page 8 -->

# Spaghetti Plot: Total Assets

8

<!-- page 9 -->

# Spaghetti Plot: Total Assets

* Most households seem relatively stable during this time period, with some (wild) exceptions
* Slopes and intercepts seem to vary...
* Important to look at similar plots for different subgroups of interest, etc.
* Overall trend not clear (could look at bigger subsample): but why is there variance in the intercepts and slopes?

9

<!-- page 10 -->

# Plotting Subgroup Proportions

* R Code:

```r
# 75th percentile = $384,000
hrs_reduced2$top25[hrs_reduced2$totassets000 > 384] <- 1
hrs_reduced2$top25[hrs_reduced2$totassets000 <= 384] <- 0

# create aggregate data set
aggdata <- aggregate(hrs_reduced2$top25,
   by=list(hrs_reduced2$edcat,hrs_reduced2$year), FUN=mean, na.rm=TRUE)
colnames(aggdata) <- c("edcat","year","prop")

ggplot(data=aggdata, aes(x=year, y=prop, group=factor(edcat),
    colour=factor(edcat, labels=c("0-11","12","13-15","16+")))) +
    geom_line() + geom_point(size=4, shape=21, fill="white") +
    ylab("Proportion of HHs in Top Quartile") +
    labs(color = "Years of Education")
```

10

<!-- page 11 -->

# Plotting Subgroup Proportions

11

<!-- page 12 -->

# Plotting Subgroup Proportions

* Based on this plot, a “main effect” of education is clear; constant gaps between the groups
* This type of plot gives us a sense of **marginal** effects, and does not indicate between-individual variation; but spaghetti plots aren’t realistic for binary data
* Clearly the intercepts for different groups would vary, due to the educational gaps!

12

<!-- page 13 -->

# Second Step (Very Important!)

* Make sure that you did not skip that first step!

13

<!-- page 14 -->

# Fitting the Models

* Now, we’ll consider fitting each of the models to this subset of the overall HRS data in R, examining the output, and interpreting the results (**see last week’s software supplement for analogous code and output**)
* **Important:** Trying to fit a <u>multilevel</u> model to all 12,558 households may lead to memory problems!
* For the multilevel models, we’ll use the step-up approach, starting with an unconditional model, and adding fixed effects of household characteristics to explain variance among the HRS households

14

<!-- page 15 -->

# Objective 1 Analysis

* We first fit a multilevel model with random intercepts and random slopes, and allow for errors within a HH to have an AR(1) structure:

```r
temphrs <- subset(hrs, hhidpn < 12000000)

Obj1.fit.1 <- lme(
totassets000 ~ yrssince00,
random = ~ 1 + yrssince00 | hhidpn,
correlation = corAR1(form = ~ 1 | hhidpn),
method = "REML",
na.action = "na.omit",
control = list(opt = "optim"),
data = temphrs
)
```

15

<!-- page 16 -->

# AR(1) Correlation Structure

* For four measurements with a correlation $\rho$
$$\begin{pmatrix} 1 & \rho & \rho^2 & \rho^3 \\ \rho & 1 & \rho & \rho^2 \\ \rho^2 & \rho & 1 & \rho \\ \rho^3 & \rho^2 & \rho & 1 \end{pmatrix}$$
* If the estimated $\hat{\rho} = 0.1$
$$\begin{pmatrix} 1 & 0.1 & 0.01 & 0.001 \\ 0.1 & 1 & 0.1 & 0.01 \\ 0.01 & 0.1 & 1 & 0.1 \\ 0.001 & 0.01 & 0.1 & 1 \end{pmatrix}$$

16

<!-- page 17 -->

# Other Common Correlation Structures

- Compound Symmetry / Exchangeable

$$
\begin{bmatrix}
\sigma^2 + \sigma_0^2 & \sigma_0^2 & \sigma_0^2 & \sigma_0^2 \\
\sigma_0^2 & \sigma^2 + \sigma_0^2 & \sigma_0^2 & \sigma_0^2 \\
\sigma_0^2 & \sigma_0^2 & \sigma^2 + \sigma_0^2 & \sigma_0^2 \\
\sigma_0^2 & \sigma_0^2 & \sigma_0^2 & \sigma^2 + \sigma_0^2
\end{bmatrix}
$$

- Unstructured

$$
\begin{bmatrix}
\sigma_1^2 & \sigma_{12} & \sigma_{13} & \sigma_{14} \\
\sigma_{12} & \sigma_2^2 & \sigma_{23} & \sigma_{24} \\
\sigma_{13} & \sigma_{23} & \sigma_3^2 & \sigma_{34} \\
\sigma_{14} & \sigma_{24} & \sigma_{34} & \sigma_4^2
\end{bmatrix}
$$

17

<!-- page 18 -->

# Objective 1 Analysis

* Partial output:

```r
Random effects:
         StdDev    Corr
(Intercept) 1105.1503 (Intr)
yrssince00   141.3069 0.283
Residual     740.2163
Correlation Structure: AR(1)
 Formula: ~1 | hhidpn

 Parameter estimate(s):
       Phi
-0.6473533

Fixed effects: totassets000 ~ yrssince00
               Value Std.Error  DF  t-value p-value
(Intercept) 424.9493  99.41417 397 4.274535  0.0000
yrssince00   35.1565  15.39007 397 2.284365  0.0229
```

18

<!-- page 19 -->

# Objective 1 Analysis

* Fitting the model with only random intercepts:

```r
Obj1.fit.2 <- lme(
  totassets000 ~ yrssince00,
  random = ~ 1 | hhidpn,
  correlation = corAR1(form = ~ 1 | hhidpn),
  method = "REML",
  na.action = "na.omit",
  control = list(opt = "optim"),
  data = temphrs
)
```

19

<!-- page 20 -->

# Objective 1 Analysis

* Now, perform an appropriate LRT for the variance of the random slopes:

```r
lrt.pvalue <- function(fit1, fit2) {
  lrtstat <-
    (-2 * as.numeric(summary(fit2)$logLik)) - (-2 *
    as.numeric(summary(fit1)$logLik))
  pvalue = 0.5 * (1 - pchisq(lrtstat, 2)) + 0.5 * (1 -
    pchisq(lrtstat, 1))
  return(pvalue)
}

lrt.pvalue(Obj1.fit.1, Obj1.fit.2)
```

20

<!-- page 21 -->

# Objective 1 Analysis

* Based on the extremely small p-value, we retain the random slopes, concluding that they vary significantly
* Next, we try to explain variance in the intercepts **and** slopes using HH education (as a Level 2 covariate):

```r
Obj1.fit.3 <-lme(totassets000 ~ yrssince00 + factor(edcat) +
yrssince00:factor(edcat),
 random = ~ 1 + yrssince00 | hhidpn,
 correlation = corAR1(form = ~ 1 | hhidpn),
 method = "REML",
 na.action = "na.omit",
 control = list(opt = "optim"),
 data = temphrs)
```

21

<!-- page 22 -->

# Objective 1 Analysis

* We compute the percentages of variance explained in the intercepts and slopes
* $(1221400 - 1110400) / 1221400 = 0.091$
* $(19968-19631)/19968=0.017$

```r
> getVarCov(Obj1.fit.1)
            (Intercept) yrssince00
(Intercept)     1221400      44212
yrssince00        44212      19968
> getVarCov(Obj1.fit.3)
            (Intercept) yrssince00
(Intercept)     1110400      40399
yrssince00        40399      19631
```

22

<!-- page 23 -->

# Objective 1 Analysis

* We see that there are significant main effects of education, but not a significant interaction (this goes with the %s of variance explained):

```r
> anova.lme(Obj1.fit.3, type = "marginal", adjustSigma = F)
                          numDF denDF  F-value p-value
(Intercept)                   1   394 0.980534  0.3227
yrssince00                    1   394 0.000142  0.9905
factor(edcat)                 3   138 4.991577  0.0026
yrssince00:factor(edcat)      3   394 1.338981  0.2613
```

* Looking at the actual fixed effect estimates, the four groups have the same general (positive) slopes, with gaps due to education

23

<!-- page 24 -->

# Objective 1 Analysis

* So, there is still more work to be done (**including diagnostics!!!**). Look at the EBLUPs:

24

<!-- page 25 -->

# Objective 1 Analysis

* What happens when we refit the model removing this one case (see the data!) with an extreme slope?
  – totassets000 = 10129.13 in 2006
* This one case is responsible for about 37.5% of the variance in the slopes!!!
* $(19631-12265)/19631=0.375$

```r
Random effects variance covariance matrix
            (Intercept) yrssince00
(Intercept)     1098000      54532
yrssince00        54532      12265
```

25

<!-- page 26 -->

# Objective 1 Analysis

* So, what’s wrong with this model?
  – Are we sure that there are linear trends? Should we use a categorical version of year instead?
  – If we use a categorical of year, how do we handle the random year effects?
  – Is AR(1) the best covariance structure for the errors? Examine the AIC and BIC values for different structures...
* **Subject-specific Interpretation:** What change in total assets is expected *for a given household* as time increases? (We condition on, or control for, the random household effects!)

26

<!-- page 27 -->

# **Aside:** Latent Class Growth Analysis

* **Idea:** We believe that there are certain groups of people defined by their trajectories in total household assets (e.g., constantly wealthy, gaining, declining, constantly poor)
* We don’t actually know whether these groups exist (they are “latent classes” defined by having similar intercepts and slopes); we want to see if we have support for this theory
* See Kreuter and Muthen (2008), Canvas

27

<!-- page 28 -->

# **Aside:** Latent Class Growth Analysis

* Not a lot of software implements this approach, unfortunately; Mplus is the best option!
* Other popular choices (albeit user-written) are KML in R, PROC TRAJ in SAS and TRAJ in Stata (http://www.andrew.cmu.edu/user/bjones/)
* **General approach:** fit models with different counts of classes (each possibly with different functional forms), consider predictors of class membership, and compare BIC values

28

<!-- page 29 -->

# Objective 2 Analysis

* Now, we fit a **marginal linear model** with correlated errors (unstructured marginal variance-covariance matrix) to the total asset data using the **gls()** function in R
* **Recall Objective:** Find the best possible overall model for the trend in growth for each group
* No interest in making inference about random effects; we only care about the overall marginal trend, and modeling the covariance

29

<!-- page 30 -->

# Objective 2 Analysis

* Note that the syntax does not include the specification of random effects
* Further, we treat time since Year 2000 as a continuous fixed factor:

```r
Obj2.fit.1 <- gls(
    totassets000 ~ yrssince00 + factor(edcat) +
   yrssince00:factor(edcat),
    correlation = corSymm(form = ~ year | hhidpn),
    weights = varIdent(form = ~ 1 | year),
    na.action = "na.omit",
    method = "REML",
    data = temphrs)
```

30

<!-- page 31 -->

# Objective 2 Analysis

* Selected Output:
  – Higher error variance in years 3 and 4
  – No significant interaction; marginal time trend

```r
Marginal variance covariance matrix
        [,1]    [,2]    [,3]    [,4]
[1,] 1581900 1010800 2135100 1075000
[2,] 1010800  912240 1281100 1082000
[3,] 2135100 1281100 3416300 1449500
[4,] 1075000 1082000 1449500 2448500
> anova(Obj2.fit.1, type = "marginal", adjustSigma = F)
                             numDF  F-value p-value
yrssince00                       1 0.377161  0.5394
factor(edcat)                    3 8.926895  <.0001
yrssince00:factor(edcat)         3 0.765412  0.5138
```

31

<!-- page 32 -->

# Objective 2 Analysis

* **Key Points:**
  - No explicit random effects; not a mixed model
  - We are estimating the overall trend **across all households**, not for a given household
  - We are allowing the errors to have a completely general variance-covariance structure; we might choose a simpler structure requiring estimation of fewer parameters if the fit does not change noticeably (AIC, BIC, ...)
  - Better for huge data sets!

32

<!-- page 33 -->

# **Aside:** Models using Penalized Splines

* Given rich longitudinal data (many time points, continuous outcome measures), simple parametric models specifying polynomial functional forms (e.g., linear trend, quadratic trend, etc.) may not always provide the best fit to a data set
* In this setting (and in regression settings more generally), *smoothing splines* provide a strong alternative worth considering that “smooths” the fit of a parametric model to data that do not fit nicely into a defined polynomial relationship

33

<!-- page 34 -->

# **Aside:** Models using Penalized Splines

* Spline functions are essentially defined by a series of linked line segments or curves (where the segments themselves are defined by model parameters)
* The segments are linked at what are called *knots* (where knots are determined by the data analyst)
* In the longitudinal context, knots would be determined based on observed (graphical) trends in the outcome, and times where the functional relationship of time with the outcome appears to change substantially

34

<!-- page 35 -->

# **Aside:** Models using Penalized Splines

* *Penalized splines* add a penalty to the likelihood function based on how “rough” the fit of a spline to a given data set is when using standard linear regression techniques (Ruppert et al., 2003, *Semiparametric Regression*, Cambridge)
* These models can be fitted using standard mixed-effects modeling techniques, including a fixed time parameter and treating the unique segments / curves as *random* time slopes
* See Gutierrez (2008), pages 27-34, for an example (Canvas)
* The user-written -pspline- command in Stata implements this methodology (type -findit pspline- in Stata)
* Splines will be more effective given many time points (HRS?)

35

<!-- page 36 -->

# **Aside:** Models using Penalized Splines

* Some additional resources on splines:

<u>A Review of Spline Function Procedures in R</u>

<u>A nice demo of the connection between penalized splines and random effects</u>

36

<!-- page 37 -->

# Objective 3 Analysis

* Now, we consider fitting a multilevel logistic regression model to the binary indicator of being in the Top 25% of all households in terms of total household assets
* Again, we try to estimate variance in intercepts and “slopes,” and then explain that variance using fixed effects associated with education categories

37

<!-- page 38 -->

# Objective 3 Analysis

* Initial Syntax:

```r
Obj3.fit.1 <- glmer(top25 ~ yrssince00 + (1 + yrssince00 |
   hhidpn), family = binomial, data = temphrs)
```

* Refit the model without random “slopes” to perform the approximate LRT

```r
Obj3.fit.2 <- glmer(top25 ~ yrssince00 + (1 | hhidpn),
   family = binomial, nAGQ = 7,data = temphrs)
```

* Likelihood ratio test provides evidence in support of retaining the random “slopes”, with an extremely small p-value

```r
lrt.pvalue(Obj3.fit.1, Obj3.fit.2)
```

38

<!-- page 39 -->

# Objective 3 Analysis

* We then try to add fixed effects of education category to explain the two variance components:

```r
Obj3.fit.3 <- glmer(top25 ~ yrssince00 + factor(edcat) +
yrssince00:factor(edcat) +
        (1 + yrssince00 | hhidpn),
       family = binomial,
       data = temphrs
       )
```

NOTE: The optimization of the approximate likelihood cannot be completed; sparse solution!

39

<!-- page 40 -->

# Objective 3 Analysis

* We can see from the estimates at the last iteration of the optimization procedure that the variance of the “slopes” is now tiny and the correlation of the two random effects is high:

```r
Random effects:
 Groups Name        Variance Std.Dev. Corr
 hhidpn (Intercept) 33.2213  5.764        
        yrssince00   0.4583  0.677    0.99
Number of obs: 540, groups:  hhidpn, 142
```

* We therefore try to refit removing the slopes...perhaps they are well-explained!

40

<!-- page 41 -->

# Objective 3 Analysis

* We take out the random slopes:

```r
Obj3.fit.4 <-glmer(top25 ~ yrssince00 + factor(edcat) +
   yrssince00:factor(edcat) +
           (1 | hhidpn),
           na.action = "na.omit",
           nAGQ = 0,
           family = binomial,
           data = temphrs)
```

* Now the estimation goes quite quickly with nAGQ = 0, but still cannot converge with nAGQ >0
* We find evidence of complete separation problems; extremely large main effects of education!

41

<!-- page 42 -->

# Objective 3 Analysis

* Once again, this model would yield a **subject-specific** interpretation
* We condition on the random household effects, or control for the household effects
* R, SAS and Stata use different estimation methods, so may result in different convergence behaviors; recheck the data
* Alternatively, we could look at marginal effects across all households; for this, we can use GEE (Objective 4)

42

<!-- page 43 -->

# Objective 4 Analysis

* Here is the syntax that we would use to fit a marginal logistic model with correlated observations using **geeglm** in R (geepack pkg):

```r
Obj4.fit.1 <- geeglm(
  top25 ~ yrssince00 + factor(edcat) +
yrssince00:factor(edcat),
  id = hhidpn,
  waves = year,
  family = binomial("logit"),
  data = temphrs,
  corstr = "exchangeable"
)
```

43

<!-- page 44 -->

# Objective 4 Analysis

```r
 Coefficients:
                          Estimate Std.err  Wald Pr(>|W|)
(Intercept)                 0.3646  0.3293  1.23  0.26812
yrssince00                  0.0725  0.0367  3.90  0.04839 *
factor(edcat)1             -2.5769  0.5928 18.90  1.4e-05 ***
factor(edcat)2             -1.6935  0.4839 12.25  0.00047 ***
factor(edcat)3             -3.6446  0.8800 17.15  3.5e-05 ***
yrssince00:factor(edcat)1  -0.0354  0.0493  0.52  0.47279
yrssince00:factor(edcat)2   0.0447  0.0591  0.57  0.44897
yrssince00:factor(edcat)3   0.3316  0.1168  8.06  0.00451 **
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

44

<!-- page 45 -->

# Objective 4 Analysis

```r
> anova(Obj4.fit.1)
Analysis of 'Wald statistic' Table
Model: binomial, link: logit
Response: top25
Terms added sequentially (first to last)

                         Df   X2 P(>|Chi|)    
yrssince00                1 18.6   1.6e-05 ***
factor(edcat)             3 31.9   5.4e-07 ***
yrssince00:factor(edcat)  3 10.9     0.012 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘
  ’ 1
```

45

<!-- page 46 -->

# Objective 4 Analysis

* Among **all households** with EDCAT = 4, a one-year increase during this time period resulted in an expected increase of 0.0725 in the log-odds of being in the Top 25% of all households in total assets
* Compare this to an estimated fixed effect of 0.2956 in the **household-specific** analysis (random effect only), controlling for household effects
* Important difference in interpretation!

46

<!-- page 47 -->

# Additional Resources for R Users

* Here are some good web links for examples using various functions in R:
  * HLMs (using the Autism data):
    http://www-personal.umich.edu/~bwest/chapter6_R_final.txt
  * HGLMs:
    https://stats.idre.ucla.edu/r/dae/mixed-effects-logistic-regression/
  * GEE:
    https://cran.r-project.org/web/packages/geepack/vignettes/geepack-manual.pdf
    See Hojsgaard et al. (2006) on Canvas!

47

<!-- page 48 -->

# Don't Forget About Model Diagnostics!

* Examine residual distributions as a function of:
  - Fitted values
  - Predictor variables
  - Make sure there are not patterns, and that the variance seems constant (keep in mind that some structures allow the variance to change!)
* Examine assumptions of normality for the residuals (if applicable, and possibly within subgroups)
* Examine EBLUPs for the random effects: any outliers?

48

<!-- page 49 -->

# Thinking Ahead...

* Once again, we’ve been ignoring complex sampling features in these case studies
* In the lecture after the Midterm Exam and Fall break, we will explore the recent literature on approaches to accommodating complex sampling features (especially time-varying weights) when fitting multilevel models and marginal models to longitudinal data

49

<!-- page 50 -->

# Midterm Exam Notes

* Scope:
  - Multilevel modeling (linear, logistic)
  - Marginal modeling (linear, logistic)
  - Software syntax / output interpretation
  - Everything up through and including today’s lecture (Lectures 1-5 in Module 1)
  - Nothing about complex sampling!
* Logistics: Two hours, open notes, open book, open laptops; <u>**no electronic communication**</u>

50

<!-- page 51 -->

# Midterm Exam Notes

* T/F and MC questions covering important concepts, short-answer questions, model specification, execution of data analysis, interpretation of example output
* Practice Exam
  – Available on Canvas in **Midterm Exam** folder
  – Please study this carefully, and <u>make sure that you are prepared to perform real data analysis</u>
* Questions?

51
