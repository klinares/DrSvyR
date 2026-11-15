---
id: "jpsm/Fund_Infe_SURV740/lectures/SurvMeth740_Module10_Fall2025"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Fundamentals of Inference"
original: "Fund_Infe_SURV740/lectures/SurvMeth740_Module10_Fall2025.pdf"
pages: 26
sha256: "fdbf8e4380b9b70122903607de1a424fc0ecdf14d0229701cddc6ae00e6e0a11"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:04"
---

<!-- page 1 -->

# Fundamentals of Inference

Yan Li ([email])
SurvMeth / Surv 740
Module 10, Fall 2025

1

<!-- page 2 -->

# Module 10 Overview

* More on Bayesian modeling
* Examples using the R Software
* Calibrated Bayes for Checking
* Superpopulation Modeling

2

<!-- page 3 -->

# Some Standard Univariate Models

- Setup:

$$
Population : Y = \{Y_1, Y_2, \cdots, Y_N\}
$$

$$
Sample : y_{inc} = \{y_1, y_2, \cdots, y_n\} \subset Y
$$

$$
Design : \Pr(I_j = 1) = \pi_j, j = 1, 2, \cdots, N
$$

$$
Model : \Pr(Y) = \Pr(Y_1, Y_2, \cdots, Y_N)
$$

$$
Y_{exc} = Y \cap y_{inc}^c
$$

$$
Inference : \Pr(Y_{exc} \mid y_{inc})
$$

3

<!-- page 4 -->

* Normal **Continuous** Variables:

$$Y_i \mid \mu, \sigma^2 : \text{ iid } N(\mu, \sigma^2)$$

Prior Distribution: $\pi(\mu, \sigma)$

* Bayesian Inference:
  * Simulate draws (posterior, then excluded cases):

$$(\mu, \sigma) \mid y_{inc}$$

$$Y_{exc} \mid \mu, \sigma$$

  * Create # of R potential populations, compute estimands of interest for each, then combine

$$Y^{(r)} = (y_{inc}, Y_{exc}^{(r)}), r = 1, 2, \cdots, R$$

$$Q^{(r)} = Q(Y^{(r)})$$

4

<!-- page 5 -->

* Non-Normal **Continuous** Variables:
  - Consider <u>transformation</u> to normality
  - For example, income, $Y^{1/3}\ or\ \log Y$
  - Generate draws on the transformed scale and transform back to the original scale
* Box-Cox Transformations:

$$g_\lambda(y) = \frac{Y^\lambda - 1}{\lambda}$$

* Consider Non-Normal continuous distributions
  - Gamma, Weibull, t, chi-square, etc.

5

<!-- page 6 -->

* **Count** Variables:

  $$Y_i | \lambda : iid\ Poisson(\lambda)$$

  $$\text{Prior: } \pi(\lambda)$$

  $$Y_i | \lambda : iid\ Negative-Binomial(\lambda)$$

  $$\text{Prior: } \pi(\lambda)$$

* **Polytomous** Variables:
  - Multinomial model
  - Ordered categorical model

6

<!-- page 7 -->

# Justification of Design-Based Confidence Intervals as Bayesian Credible intervals

* Consider the Simple Random Sample case...
* It is possible to identify priors such that the resulting credible interval will be equal to a confidence interval (although interpretations are different)
* Binomial Example: $Y \mid \theta : \text{Ber}(1, \theta)$

$$\pi(\theta) \propto \theta^{-1}(1 - \theta)^{-1}$$

$$\text{Improper Prior: } \int_0^1 \pi(\theta)d\theta = \infty$$

* Normal Example: $Y \mid \mu, \sigma \sim N(\mu, \sigma^2)$

$$\pi(\mu, \sigma) \propto \sigma^{-1}$$

Again, Improper Prior; but use of an improper prior can still lead to acceptable posteriors, which are just based on diffuse priors

7

<!-- page 8 -->

- Poisson Example

$$Y | \lambda \sim Poisson(\lambda)$$

$$\pi(\lambda) \propto \lambda^{-1}$$

- Most general (**<u>Jeffreys Prior</u>**)

$$Density : f(y | \theta)$$

$$I(\theta) = -E\left(\frac{\partial^2 \log f(y | \theta)}{\partial \theta \partial \theta^T}\right)$$

$$\pi(\theta) = \sqrt{\det I(\theta)}$$

8

<!-- page 9 -->

# Model-Based Justification of the Horvitz-Thompson Estimator

$$HT - Estimator :$$

$$q = \sum_{i} y_{i} / \pi_{i}$$

$$y_{i} \sim (E(y_{i}) = \beta\pi_{i}, V(y_{i}) = \sigma^{2}\pi_{i}^{2})$$

$q =$ Weighted Least Squares Estimate

of $\beta$ (an alternative model-based approach

to estimating a total given a complex sample design)

9

<!-- page 10 -->

# A General Approach to Bayesian Inference

* Log-likelihood (applies to any model for $y$):

$$f(y | \theta) = \text{Probability Density Function (Normal, Poisson, Bernoulli, etc.)}$$

$$l(\theta | y_{inc}) = \sum_i \log f(y_i | \theta)$$

* Maximum Likelihood Estimate (general):

$$Maximize: l(\theta | y_{inc})$$

$$Maxima: \hat{\theta}_{MLE}$$

* Information Matrix and Variance of Estimates:

$$I(\hat{\theta}) = -\left.\frac{\partial^2 l(\theta | y_{inc})}{\partial\theta\partial\theta^T}\right|_{\theta=\hat{\theta}} \quad \hat{V} = I^{-1}(\hat{\theta})$$

10

<!-- page 11 -->

* Assume any prior distribution, characterized by:

$$
prior\ mean = \theta_P
$$

$$
prior\ variance = V_P
$$

* The posterior distribution then has these characteristics:

$$
posterior\ mean:
$$

$$
E(\theta | y_{inc}) \approx (\hat{V}^{-1} + V_P^{-1})^{-1}(\hat{V}^{-1}\hat{\theta} + V_P^{-1}\theta_P)
$$

$$
posterior\ Variance:
$$

$$
V(\theta | y_{inc}) \approx (\hat{V}^{-1} + V_P^{-1})^{-1}
$$

11

<!-- page 12 -->

* Given a large sample, we can assume that the posterior distribution is approximately **normal**:

$$\theta | y_{inc} \sim N[E(\theta | y_{inc}), V(\theta | y_{inc})]$$

* **Simulating Populations:** draw theta from posterior given data, then draw values of Y for excluded cases:

$$\theta \sim N[E(\theta | y_{inc}), V(\theta | y_{inc})]$$

$$Y_j | \theta \sim f(y | \theta), j = n + 1, n + 2, \dots, N$$

12

<!-- page 13 -->

* When posteriors have a known form, point estimation and inference can be based directly on the posterior distribution:

$$\theta = (\mu, \sigma)$$

$$\pi(\theta | y_{inc}) \approx N(\hat{\theta}, \hat{V})$$

$$\hat{\theta} = \text{Mode of } \pi(\theta | y_{inc})$$

$$\hat{V}^{-1} = \text{Second derivative of}$$

$$\text{the logarithm of } \pi(\theta | y_{inc})$$

* For more general cases, with complex priors and likelihoods, hard (if not impossible) to write down the posterior
* Need Iterative simulation techniques such as **Gibbs Sampling** and **Markov Chain Monte Carlo (MCMC)** methods; we’ll see examples shortly

13

<!-- page 14 -->

# Examples of Bayesian Analysis in R

* Fit a multilevel model using the `MCMCglmm` package:

```r
library(MCMCglmm)

model3.3.bayes <- MCMCglmm(weight ~ sex1 + litsize + treatment, random = ~litter, data = ratpup, rcov = ~idh(treatment):units)
```

* By default, MCMCglmm uses 13,000 MCMC iterations, resulting in several thousand (10,000) simulated draws of the parameters from their posterior distribution based on the specified model and **non-informative** prior distributions. A default of 3,000 burn-in draws are used for the MCMC algorithm (**burn-ins** are used to help stabilize convergence of simulated draws from the posterior; initial draws may be highly unreliable). We can plot the post burn-in draws of these parameters using a simple plot function:

```r
plot(model3.3.bayes)
```

* Users can hit ENTER to cycle through the plots, which show the sequence of draws for each parameter (which should stabilize over iterations, indicating convergence of the sequence to random draws around an overall mean) and the density function defined by all of the posterior draws of each parameter. The density functions provide an initial sense of whether the distribution of the draws of a given parameter from the posterior distribution for all of the parameters in the model includes 0 as a plausible value.

14

<!-- page 15 -->

# Examples of Bayesian Analysis in R

* To generate inferences, we can apply the `summary()` function to the object generated by `MCMCglmm()`:

```r
summary(model3.3.bayes)

Iterations = 3001:12991
Thinning interval = 10
Sample size = 1000

DIC: 313.9606

G-structure: ~litter

       post.mean l-95% CI u-95% CI eff.samp
litter    0.1066  0.04921   0.1813      884

R-structure: ~idh(treatment):units

              post.mean l-95% CI u-95% CI eff.samp
Control.units    0.2694  0.20757   0.3388     1000
High.units       0.1116  0.07475   0.1586     1000
Low.units        0.0861  0.06453   0.1080     1000

Location effects: weight ~ sex1 + litsize + treatment

              post.mean l-95% CI u-95% CI eff.samp  pMCMC    
(Intercept)     8.32723  7.78502  8.91543     1000 <0.001 ***
sex1           -0.34294 -0.43046 -0.26315     1000 <0.001 ***
litsize        -0.13026 -0.16666 -0.09339     1000 <0.001 ***
treatmentHigh  -0.85954 -1.23652 -0.47429     1000 <0.001 ***
treatmentLow   -0.43554 -0.72088 -0.12940     1000  0.006 ** 
---
Signif. codes:  0  ***  0.001  **  0.01  *  0.05  .  0.1     1
```

* The DIC criterion can be used to compare competing models, similar to the AIC and BIC criteria. We see means of the 1,000 draws of each parameter from the posterior distribution, along with 95% credible intervals for the parameters in the model.

15

<!-- page 16 -->

# Examples of Bayesian Analysis in R

* Now, fit a multilevel model using the `brms` package:

```r
library(brms)

fit1 <- brm(vsae ~ age.2 + I(age.2^2) + sicdegp2.f + age.2 * sicdegp2.f +
I(age.2^2) * sicdegp2.f + (age.2 + I(age.2^2) | childid),
data = autism.updated, family = gaussian("identity"),
prior = c(set_prior("normal(0,10)", class = "b"), set_prior("cauchy(0,2)", class =
"sd"), set_prior("lkj(2)", class = "cor")),
warmup = 500, iter = 2000, chains = 2)
```

* Note: clearly-specified distribution for the dependent variable, VSAE (Normal, or Gaussian)
* Clearly-specified prior (mostly non-informative) distributions, for the fixed effects [N(0,10)], variance components [Cauchy(0,2)], and correlations of the random effects [LKJ(2)]; **subjective!!! As informative as you want, given your prior knowledge! But these choices set up for a joint posterior that cannot be specified analytically. Use MCMC.**
* **500** burn-in draws, followed by 1,500 additional draws, with **2** concurrent chains of draws to assess convergence of the draws to some stable distribution

16

<!-- page 17 -->

# Examples of Bayesian Analysis in R

```r
summary(fit1, waic=T)

Family: gaussian
Links: mu = identity; sigma = identity
Formula: vsae ~ age.2 + I(age.2^2) + sicdegp2.f + age.2 * sicdegp2.f + I(age.2^2) * sicdegp2.f + (age.2 + I(age.2^2) | childid)
Data: autism.updated (Number of observations: 610)
Samples: 2 chains, each with iter = 2000; warmup = 500; thin = 1;
total post-warmup samples = 3000
ICs: LOO = NA; WAIC = 4219.42; R2 = NA

Group-Level Effects:
~childid (Number of levels: 158)
                       Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
sd(Intercept)              0.90      0.52     0.05     1.95        172 1.01
sd(age.2)                  3.75      0.36     3.07     4.49        835 1.00
sd(Iage.2E2)               0.38      0.04     0.30     0.45        810 1.00
cor(Intercept,age.2)       0.05      0.30    -0.49     0.65        101 1.01
cor(Intercept,Iage.2E2)    0.44      0.35    -0.46     0.88         35 1.03
cor(age.2,Iage.2E2)       -0.31      0.12    -0.52    -0.07        744 1.00

Population-Level Effects:
                   Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
Intercept             13.74      0.83    12.12    15.41       2025 1.00
age.2                  5.59      0.77     4.11     7.04        952 1.00
Iage.2E2               0.20      0.08     0.05     0.36        952 1.00
sicdegp2.f1           -5.36      1.11    -7.53    -3.23       3000 1.00
sicdegp2.f2           -3.99      1.09    -6.19    -1.91       3000 1.00
age.2:sicdegp2.f1     -3.31      1.07    -5.38    -1.24       1067 1.00
age.2:sicdegp2.f2     -2.71      1.02    -4.70    -0.67       1131 1.00
Iage.2E2:sicdegp2.f1  -0.13      0.12    -0.36     0.10        977 1.00
Iage.2E2:sicdegp2.f2  -0.13      0.10    -0.34     0.07       1022 1.00

Family Specific Parameters:
      Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
sigma     6.21      0.25     5.76     6.74       1140 1.00
```

* Note: much more natural inference about variance components and unusual parameters (e.g., correlations of random effects) than is possible in frequentist approaches, which rely on likelihood ratio tests, mixtures of chi-square distributions as null distributions, controversial Wald tests, etc.
* Just simulate draws of the parameters from their posterior distributions, and form 95% credible intervals! The probability that the parameter lies between these values is 0.95.
* **Key question: is model correct?**

17

<!-- page 18 -->

# Calibrated Bayes (Little, 2006)

* Survey Design is very important
  - Probability Sample Design provides ethically justifiable study of population
  - Stratification improves representation
* Model-Based inference provides the right framework for defining the unknown quantity (source of our <u>uncertainty</u>) and drawing inference about the unknown quantity
* “Good” properties of <mark>repeated</mark> <mark>sampling</mark>, such as unbiasedness, minimum variance, design consistency, etc., are desirable

18

<!-- page 19 -->

* A balanced view is to develop the best possible design, best possible Bayesian inference, and check using the repeated sampling framework
* Idea:

$$\text{Draw}$$

$$\{ \underbrace{y_1^{(r)}, y_2^{(r)}, \cdots, y_n^{(r)}}_{\text{Used for model checking}}, \quad \underbrace{Y_{n+1}^{(r)}, Y_{n+2}^{(r)}, \cdots, Y_N^{(r)}}_{\text{Used for inference}} \}$$

$$r = 1, 2, \cdots, R$$

$$\text{Compare:}$$

$$\{ y_1, y_2, \cdots, y_n \} \text{ with } \{ y_1^{(r)}, y_2^{(r)}, \cdots, y_n^{(r)} \}$$

* Are the observed data consistent with the data from repeated simulations under the specified model?

19

<!-- page 20 -->

# Calibrated Bayes: Example

* **Goal:** Are the observed data consistent with repeated simulations from the fitted model? Idea of **posterior predictive checking**
* Example from Little (2006):
  SRS of i.i.d. Normal values, $n = 7$, sample mean $= 1$, sample SD $= 1$
  – Freq. 95% CI using sample estimates: $1 \text{ +/- } 2.447 \times (1 / \text{sqrt}(7)) = 1 \text{ +/- } 0.92$
  Identical Bayes Credible Interval: Jeffreys prior with $p(\text{mean}, \text{SD}) \sim 1/\text{SD}$ (**Slide 7**)
  – What if we are told that SD is <u>known</u> to be $1.5$ (not estimated)? No uncertainty in estimation of the sample SD, and 95% CI is $1 \text{ +/- } 1.96 \times (1.5 / \text{sqrt}(7)) = 1 \text{ +/- } 1.11$
  – Now, we learn that known SD is something greater than $1.5$. We could use one of the intervals above, <u>or</u> a credible interval with the prior updated: $1 \text{ +/- } 1.45$

20

<!-- page 21 -->

# Calibrated Bayes: Example

* Example from Little (2006), cont’d:
  - What do we choose? First interval provides exact 95% frequentist coverage of true mean, assumes that SD is not known, but how can this be <u>narrower</u> than an interval that actually incorporates known information about the SD?
  - Second interval is an asymptotic frequentist approximation, given that the SD is no longer estimated (but our sample is only $n = 7$!!!). Wouldn’t coverage of second interval be less than 95% if we know that SD is greater than 1.5?
  - Third (Bayesian credible) interval incorporates the prior constraint and is thus wider, but depends entirely on the prior information being correct.
  - How can we marry these ideas for reasonable inference?

21

<!-- page 22 -->

# Calibrated Bayes: Example

* Note the **posterior predictive distribution** (simulate <u>repeated samples</u> under the Bayesian model, compute the sample variance for each) for the sample variance under the Normal model for the variable of interest, with a Jeffreys prior
* The posterior probability of observing a sample variance of $1$ or lower is about $0.065$, which is low but not unusually low, so the Bayesian model used seems reasonable

$$\Pr(s^{*2} < s_{\text{obs}}^2 \mid \text{data}, \sigma > 1.5) \approx 0.065$$

<!-- page 23 -->

# Superpopulation Inferences

* Consider FinitePopulation as a sample from a superpopulation (Model is interpreted as this “first stage” sampling of a finite population)
* Designed Sample as the “second stage” sampling from the realized finite population
* Use both stages of sampling to evaluate the properties of the procedures
* Apply the procedure to the data in hand

23

<!-- page 24 -->

# Superpopulation Inferences

* Two expectations:
  * One with respect to the repeated sampling distribution over the indicator $I$ (second stage)
  * One with respect to the repeated draws of the finite population from the superpopulation (repeated sampling with respect to model $M$)

$$
E(q) = E_M(E_I(q))
$$

24

<!-- page 25 -->

# Superpopulation Variance

- Variance is also computed using two stages of sampling:

$$
Var(q) = E_M(V_I(q)) + V_M(E_I(q))
$$

$$
\textit{Usually}, V_M(E_I(q)) \approx O(1/N),
$$

$$
\textit{can be ignored}
$$

- Example:

$$
Y_i \mid \mu, \sigma^2 \sim iid \; (\mu = E(Y), \sigma^2 = Var(Y))
$$

$$
\textit{Simple random sample}
$$

$$
Var(\bar{y}) = (1 - f)E_M(S^2)/n + \sigma^2/N
$$

$$
S^2 = \sum_{j=1}^N (Y_j - \bar{Y})^2 / (N - 1)
$$

25

<!-- page 26 -->

*Under normality* :

$$E_M(S^2) = \sigma^2$$

$$Var(\bar{y}) = \sigma^2 / n$$

$$Est.Var(\bar{y}) = s^2 / n$$

$$s^2 = \sum_i (y_i - \bar{y})^2 / (n - 1)$$

*Confidence Interval*

$$\bar{y} \pm z_{\alpha/2}\sqrt{s^2 / n}$$

Repeated sampling interpretation involves both stages or phases of sampling

26
