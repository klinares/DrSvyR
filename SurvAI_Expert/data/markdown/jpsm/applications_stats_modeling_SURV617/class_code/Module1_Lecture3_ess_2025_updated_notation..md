---
id: "jpsm/applications_stats_modeling_SURV617/class_code/Module1_Lecture3_ess_2025_updated_notation."
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lab"
title: "Multilevel Modeling Application: Interviewer Effects in the European Social Survey"
original: "applications_stats_modeling_SURV617/class_code/Module1_Lecture3_ess_2025_updated_notation..Rmd"
pages: 
sha256: "27390fdde8c770b9f7aeb0bf9f443f092a7c7d3be2bdbee56b6c1a15876aa507"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:39"
---


## Class Lecture before jumping into the practical R things.

Interviewer effects: Have those units (interviewers) been randomly
sampled? Yes!

POTENTIAL EXAM QUESTION: Does it make sense to use region as a random
effect? By definition, we'll have every region in the data set and we'll
see all four in every data set, so region CANNOT be used as a random
effect because they are not randomly sampled. The higher level must
represent a random sample of that higher population, because they were
randomly sampled. Conversely, let's say we have a country with 100
regions, and we randomly select 50 regions because we physically cannot
go to all 100 regions. Because that second level is randomly selected,
we could use these regions as a random effect.

For random effects, Level one units nested in level two units. Think
about how this lecture can be translated to what our groups are working
on.

Interviewer effects are classically viewed as a type of measurement
error, specific to an interviewer. We can think of interviewers being
clusters of observations. And we have a random sample of interviewers,
so we think of their effects on the data as random. We're not looking at
fixed effects of individual interviewers, but the random effect of TK.
(dp note 8:50).

Determinants of Intra-Interviewer Correlations (“rho-int”); see West and
Blom (2017, JSSAM) \* Computerization (ACASI/SAQs); correlations
expected to be negligible \* Telephone (smaller) vs. Face-to-face
(larger) \* Items? Open vs. closed, or Factual vs. attitudinal; not many
differences. The harder and longer a question is, the more likely there
is to be interviewer variance. \* Controlled feedback and probing… \*
Interviewer experience / training? Interviewer behaviors / non-verbal
signs? \* Demographics of interviewers and respondents \* Different
recruitment of different types of cases (West and Olson, 2010); argument
against measurement error hypothesis. E.G someone is better at
recruiting older or younger respondents.

\^These are level TWO covariates. These are not characteristics of the
respondent, but are interviewer characteristics. So if we're trying to
explain interviewer variance, we'd add fixed effects of this at level
two.

Variance inflation:

-   As the sizes of workloads increase, effective sample size is
    reduced, even for small values of intra-interviewer correlations. B
    is the number of respondents within an interviewer. So the larger
    the B is, the larger the impact of the interviewer is.
-   Workload could be reduced by hiring more interviewers, but… that is
    very difficult! it is hard to find good interviewers. Better to
    reduce by training, supervision, and good questionnaire design
    principles than to just hire more people.
-   Wouldn’t that cost more?
-   Better to reduce rho-int as much as possible through training,
    supervision, and good questionnaire design principles

Multi-level modeling approaches:

-   In recent years, methodological studies have taken advantage of
    multilevel modeling techniques to study interviewer variance
-   Effects of individual interviewers j (Mj) on survey measures y for
    respondent i are treated as random:

THE FORMULA (see slide): general outcome measure where Y_ij i is the
respondent and j is the interviewer. We write as some true value (X_1)
plus M_j which is the random effect due to the interviewer. Ideally, we
want M_j to be 0. This is the random effect of the INTERVIEWER. plus
some random error/respondent disturbance at the RESPONDENT level (e.g
respondent is lying). So we're trying to model the disturbance due to
the interviewer and the disturbance due to the respondent.

Sigma\^2_int... why is that variance non 0? why do different
interviewers vary? No different than the random intercept model that
we've been talking about.

The typical model that we'd write down which combines those..

$Y_{ij} = \beta_0 + M_j + \epsilon_{ij}$ -\> this is a simple random
intercept model with no predictors. How much variability is there
arising to the interviewers? This is the STARTING POINT.

-   In most applications, variance in the true values (Xi) and the
    random errors (eij) are combined into the error variance term, and a
    fixed intercept is used

Advantages of MLM when it comes to interviewer effects:

-   Capable of handling unbalanced workloads across interviewers (some
    models require equal workloads!). This is a key feature - the lack
    of balance. You may have a superstar interviewer who does twice as
    many interviews as others.
-   Capable of including interviewer-specific covariates in an effort to
    explain variance across interviewers. E.G you can split the model up
    into level one and level two, you could add interviewer
    characteristics and their fixed effects to level two. Is it their
    gender, their experience, the mode that they are working in?
-   Capable of allowing interviewer variance to vary depending on the
    type of interviewer (e.g., CAPI vs. CATI). It could be that face to
    face interviewers have a much larger variance than CATI
    interviewers. Or that older interviewers have more variance than
    younger interviewers. That answers two different research
    questions - what explains the mean, and why do different sets of
    interviewers have different variances?
-   Models with crossed random effects enable studies of the
    contributions of areas and interviewers to overall variance (e.g.,
    O’Muircheartaigh and Campanelli, 1998). We could estimate a D matrix
    for the male interviewers and female interviewers. The softwear
    allows us to do that.
    -   Example: interviewers work in multiple randomly sampled PSUs,
        and we wish to disentangle interviewer and PSU effects

Aliasing - if an interviewer is confined to only one geographic area
(e.g one county), I could NOT fit a model that has a random effect for
the interviewer and the area. (26.40) You're trying to estimate the same
thing twice, so the model will freak out. We can't make the argument the
variance isn't due to the area. But if interviewers work in multiple
areas, we can fit a model with both random effects. That's often used in
methodological studies trying to decompose that variance.

Assuming that interviewers were randomly sampled from some hypothetical
super-population of interviewers (the assumption NEEDED to treat effects
as random), we can compute “rho-int” (the intra-interviewer correlation)
for a given survey measure as follows:

[SEE SLIDE]

-\> same implied intra class correlation, but now attributing to the
interviewer. If you're concerned about whether that correlation is 0 or
not 0, you can simply test whether rho-int is zero by performing
appropriate tests for the interviewer variance component
$\sigma_{int}^2$.

```r
knitr::opts_chunk$set(echo = TRUE)
```

## Setup

Required R packages!

```r
library(lme4)
library(nlme)
library(lmerTest)
library(tidyverse)
```

User-defined functions:

```r
# Function to calculate LRT p-values for variances of random effects
lrt.pvalue <- function(fit1, fit2) {
  lrtstat <-
    (-2 * as.numeric(summary(fit2)$logLik)) - (-2 * as.numeric(summary(fit1)$logLik))
  pvalue = 0.5 * (1 - pchisq(lrtstat, 2)) + 0.5 * (1 - pchisq(lrtstat, 1))
  return(pvalue)
}
```

input data:

```r
load("D:/repos/UMD_classes_code/applications_stats_modeling_SURV617/data/ess_belgium.rdata")
```

## First step: exploratory data analysis

```r
# variable names
names(ess_belgium) 

# missing data
apply(is.na(ess_belgium), 2, sum) #note various coding options for missing data
# look at the missing data by variable, e.g.,
table(ess_belgium$pplhlp, useNA = 'always')
summary(ess_belgium$intnum, useNA = 'always')
```

## Example: People’s Helpfulness.

```r
# histogram
hist(ess_belgium$pplhlp)
```

Item is a 10-point scale, measuring the attitude of the respondent with
regard to people being helpful (10) or looking out for themselves (0).

Spaghetti Plot: useful for longitudinal data. But what do we see here?

```r

#define base for the graphs and store in object 'p’ 
p <- ggplot(ess_belgium, aes(x = trstplc, y = pplhlp, group = intnum, color = intnum))
## just plotting points (a.k.a., scatterplot) 
p + geom_point()
## simple spaghetti plot 
p + geom_line()
```

Interviewer Box Plots for a data subset with interviewer ID: intnum \<
2000

```r
ess_sub=subset(ess_belgium,intnum < 2000)
plot(ess_sub$pplhlp ~ factor(ess_sub$intnum)) 
```

Unequal Interviewer Workloads

```r
ess_belgium %>%
  group_by(intnum) %>%
  summarise(n = n())

```

We’ll begin with the following “unconditional” multilevel model, to
estimate the raw variance: $$y_{ij}=\beta_0+\mu_{0j} + e_{ij}$$
$$\mu_{0j} \sim N(0, \sigma_0^2)$$ $$e_{ij} \sim N(0, \sigma^2).$$ We
can calculate the intra-interviewer correlation (ICC) “rho-int”:
$$\rho_{int}=\frac{\sigma_0^2}{\sigma_0^2 + \sigma^2}$$

```r
mod1 = lmer(pplhlp ~ 1 + (1|intnum), REML = T, data = ess_belgium) 
mod1
summary(mod1)
AIC(mod1)
BIC(mod1)
rand(mod1)
```

The DV comes first (pplhlp); no predictors aside from 1 indicates an
intercept-only model;

The (1\|intnum) term indicates a random effect for each interviewer,
associated with the intercept;

REML = T: REML estimation (to ensure that estimates of the variance
components are unbiased);

summary(mod1) yields the initial estimates. We can use AIC/BIC to
compare different models, such as mod1 vs. mod2.

Initial Model: Interpretation

1.  The estimated mean (intercept) is $\hat{\beta}_0$= 4.75

2.  The estimated variance of the random interviewer effects is
    $\hat{\sigma}_0^2$ = 0.23

3.  The estimated residual variance is $\hat{\sigma}^2$ = 3.79

4.  The estimated intra-interviewer correlation (or ICC) is\
    $\hat{\rho}$ = 0.23 / (0.23 + 3.79) = 0.057 (relatively high for
    normal variables in a face-to-face survey!)

5.  Perform the appropriate mixture-based likelihood ratio test for the
    variance component using the lmerTest package: rand(mod1). p \<
    0.0001!

The model with the three estimated parameters is specified as

$$y_{ij}=4.75+\mu_{0j} + e_{ij}$$ $$\mu_{0j} \sim N(0, 0.23)$$
$$e_{ij} \sim N(0, 3.79).$$

## Initial Model: Diagnostics

First, we consider a plot of the EBLUPs for the random interviewer
effects:

```r
qqnorm(ranef(mod1)$intnum[,1])
qqline(ranef(mod1)$intnum[,1]) 
```

An assumption of normality for the random effects seems reasonable (not
critical for inference), and we don’t detect any extreme outliers (maybe
some particularly low EBLUPs), but there is variance!

Next, we check residuals; we could also examine studentized residuals,
but for now we look at the raw residuals.

```r
	qqnorm(resid(mod1))
	qqline(resid(mod1)) 
```

The residuals certainly look normally distributed, with no outliers.
Diagnostics look good so far!

## Explaining Interviewer Variance

This initial model could be fitted to other variables to generate a
distribution of ICCs (e.g., Groves and Magilavy 1986).

An interesting question arises in studies of interviewer effects that
can easily be answered using multilevel models: Why is there variance
among interviewers? Could be due to sampling in this case.

We can add interviewer-level covariates to the model and monitor changes
in the interviewer variance component (like computing R-squared).

In the ESS data set, we have the response rates for each interviewer
(INT_RR).

Do interviewers who are better at securing cooperation also collect
different values on the variable of interest? If so, nonresponse bias is
likely present for the mean!

```r
mod2 = lmer(pplhlp ~ int_rr + (1|intnum), REML = T, data = ess_belgium) 
summary(mod2)
AIC(mod2)
BIC(mod2)
```

When using lmerTest, you now see p-values based on the Satterthwaite
approximation!

Note that the interviewer variance component has hardly changed, and
actually increased!

The interviewer-specific response rate is not associated with PPLHLP;
note that the fixed effect of INT_RR is not different from zero.

We have added noise to the model, seemingly, but: Are we sure that we’ve
specified the INT_RR relationship correctly?

No apparent evidence of nonresponse bias due to the interviewer for this
variable; but what about other variables?

Updated Diagnostics:

Revisiting the diagnostic plots reveals no additional concerns.

Diagnostics should be carefully examined after fitting each model!

Recall that this general approach is referred to as a “step-up” approach
to model-building, where the objective is to explain variance.

## A Random Coefficients Example

Far less research on interviewer effects has examined the effects of
interviewers on regression coefficients and other statistics quantifying
relationships between variables.

What if we were interested in the relationship of trust in the police
(TRSTPLC, X) with a person’s attitude about whether people generally try
to help others (PPLHLP, Y)?

We might consider this model, for estimating the overall relationship
and examining whether the coefficient of interest varies across
interviewers:

$$y_{ij}=\beta_0+\beta_1x_{ij}+\mu_{0j}+\mu_{1j}x_{ij}+e_{ij}$$

$$ \left(
\begin{array}{c}
    \mu_{0j}\\
    \mu_{1j}
\end{array} \right) \sim N\left(
\left(
\begin{array}{c}
    0\\
    0
\end{array} \right), 
\left(
\begin{array}{cc}
    \sigma_0^2&\sigma_{01}\\\
    \sigma_{01}&\sigma_1^2
\end{array} \right) \equiv D
\right)
$$

$$e_{ij}\sim N(0, \sigma^2)$$

We now include the TRSTPLC covariate, both after the dependent variable
and in the random effects specification; this means that the effects of
TRSTPLC are allowed to randomly vary across interviewers!

A fixed intercept and random interviewer intercepts are also included by
default in this case. The default covariance structure (D) for the two
random effects is unstructured (when using the lmer() function). Do we
have convergence issues?

```r
mod3 = lmer(pplhlp ~ trstplc + (trstplc|intnum), REML = T, data = ess_belgium) 
summary(mod3)
AIC(mod3)
BIC(mod3)
```

We see that the overall fixed effect of TRSTPLC is positive and
significant: those with higher levels of trust in the police tend to
have higher levels of faith in people helping others. However, R is
warning us about convergence issues.

The lmer() function will only produce estimates of the variance
components in the D matrix (along with their correlation, not the
covariance).

Let’s perform an appropriate likelihood ratio test, and test whether the
variance of the random coefficients is significantly greater than zero:

```r
#Fit the model without the random coefficients:
mod3a = lmer(pplhlp ~ trstplc + (1|intnum), REML = T, data = ess_belgium)
summary(mod3a)

#Compute the positive difference in the -2 REML log-likelihood values (“REML criterion”, -2 * summary(mod3a)$logLik) for the models:
#Test Statistic = 7166.8 – 7143.3 = 23.5

#Refer the TS to a mixture of Chi-square distributions with 1 and 2 DF, and equal weight 0.5: 

0.5*(1-pchisq(23.5,1)) + 0.5*(1-pchisq(23.5,2))

#p < 0.001 (strong evidence of variance in coefficients!)

#or use the defined function

# LRT of the variance of random slopes
lrt.pvalue(mod3, mod3a)
```

The model with the six estimated parameters is specified as
$$y_{ij}=3.89+0.14x_{ij}+\mu_{0j}+\mu_{1j}x_{ij}+e_{ij}$$

$$ \left(
\begin{array}{c}
    \mu_{0j}\\
    \mu_{1j}
\end{array} \right) \sim N\left(
\left(
\begin{array}{c}
    0\\
    0
\end{array} \right), 
\left(
\begin{array}{cc}
    0.69&-0.07\\\
    -0.07&0.01
\end{array} \right) \equiv D
\right)
$$

$$e_{ij}\sim N(0, 3.65).$$

Here the covariance estimate can be computed as:
$\hat{\sigma}_{01}=\hat{r}\hat{\sigma_0}\hat{\sigma_1}=(-0.82)*0.83*0.11=-0.07$

## Diagnostics

Let’s examine plots of the residuals:

```r
	qqnorm(resid(mod3))
	qqline(resid(mod3)) 
	plot(resid(mod3),fitted(mod3))
```

The plots show that assumptions of normality and constant variance for
the residuals seem justified!

Now, let’s look at plots of the EBLUPs for each random interviewer
effect (based on the random coefficient model):

```r
	# intercepts
	qqnorm(ranef(mod3)$intnum[,1])
	qqline(ranef(mod3)$intnum[,1])
	# slopes
	qqnorm(ranef(mod3)$intnum[,2])
	qqline(ranef(mod3)$intnum[,2])  
```

Both plots look good, except some outliers:

```r
ess_belgium[ess_belgium$intnum==4976,]
#trstprl=88
ess_belgium[ess_belgium$intnum==7519,]
```

Interviewers 4976 (many responses \< 4!) and 7519 (88, missing data!
need to rerun the analysis...) seem unusual.
