---
id: "jpsm/stat_mod_ML_1_SURV615/lecture_notes"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "lecture_notes"
original: "stat_mod_ML_1_SURV615/lecture_notes.pdf"
pages: 14
sha256: "917e67884befd470014bffaf0bc15e887c745f73651c075fd05897963309b556"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:22"
---

<!-- page 1 -->

October 22, 2024

* Interaction terms vary slopes between predictors and outcomes based on values from another predictor.
* Prediction intervals increase with more samples because there is more variation introduced.
  * SE is calculated differently, there are two sources to account for when predicting a value.
  * Prediction intervals always wider than confidence intervals.
    * When not estimating a mean, there is more error to account for.
  * Interpreting predicting intervals – 95% confident that the next observation with these predictor values will fall in this interval.
  * Violation of assumptions will have a larger effect on prediction intervals.
* Causation
  * gold standard RCT, want to make control and treated group exchangeable, you can switch them and they would produce the same distributions because they are comparable.
    * Any difference is due to the treatment due to random error.
  * Natural experiment, comparing a natural disaster to places that did not experience it.
* Observational studies
  * cohorts, prospective or retrospective cohorts, longitudinal.
  * Case-control, identify people with the outcome and look back.
* Hill’s viewpoints things to consider to assess a causal relationship.
  * Strength, a strong relationship is likely to be causal. Smoking and lung cancer.
  * Consistency – see the relationship in other circumstances and population.
    * Publication bias, more papers published with $p < .05$.
  * Specificity – Cause leads to single effect, not multiple. No longer true.
  * Temporality – exposure came before outcome, otherwise there is a reverse causation.
  * Biological gradient – Monotonic relationship between exposure and outcome. No longer true since these can be non-linear.
  * Plausibility – No longer true, not limited by incorrect knowledge.
  * Coherence – We may not have sufficient knowledge, no longer true.
  * Experimental evidence – helpful if feasible.
  * Analogy – using proxy variables to get at constructs.
* The fork
  * if interested in lung cancer, we may not be able to establish a causal relationship by including whether someone carries a lighter. There is a confounding variable not accounting for it.
* The pipe – mediators, for accounting for indirect effects. If conditioning on mediators, it could remove the effects from variable X. X effects go away.
* The collider – X and Y are independent and influence Z. Backdoor path, the association is introduced though Z and the indirect effect goes away.
* The Descendant, if a new variable comes from the predictor, or is in between the path, the effect from the mediator goes away.

<!-- page 2 -->

October 29 2024

* Review
  * bias, efficiency, consistency
    * bias, do we get the correct answer on average, think reliability
    * efficiency, think accuracy
    * constant variance, homoscedastic, violation leads to inefficiency in the estimate. Less precision.
    * Dependence of errors, less information in your dataset, leads us to think that our estimates are more precise than they really are.
      * Larger dataset are more robust due to central limit theorem.
    * Violation of zero mean error, issues with error dependence, normality and non-constant variance
  * zero mean error assumption, looking at them graphically
    * fitting a scatterplot, looking for no
      * discernible pattern
      * equal spread above or below spread
    * homoscedasticity, there is a pattern or cone shape.
    * Qqplots and shipira wilk tests can be useful.
  * Uncorrelated errors
    * common in time series and cluster data.
  * Outlier – a point for which $y\_i$ is far from the value predicted by the model.
    * May or may not change the estimates.
  * Leverage - high leverage observations have an unusual value of $x\_i$. We can calculate h hats in a half normal plot.
  * Influential observations – removal results in drastic changes, we can look at cook’s distance D.

November 05 2024
* OLS IID assumptions
* zero mean error + homoscedasticity – residuals and fitted plot should show no pattern. Can also check by the mean of the residuals.
  * In hetero, as residuals increase or decrease the variance increases. Shows violation of constant variance, but is there a violation of zero mean error? If some points are above the line and some below, it can cancel each other out.
* Always look at non-constant error variance visually.
* Heteroscadasticity
  * What if the mean is 0, but borderline (funnel shape\_ `t-test(resid(model))` or `wilcox.test(resid(model))` if concern about normality. Compare distribution to 0 and get a p-value to see if assumption is met. Null is $\text{mean} = 0$, alt hyp mean not equal to 0.
* Homoscedasticity
  * partition, subset residuals and compare using F test, `var.test()`. This is when we are uncertain about whether variance is homo.
* Correlation between residuals and fitted to assess non constant error variance. Can show relationship between fitted values and residuals. Does not compare variance directly, it is indirectly, and it is testing whether the fitted values are related to the residuals and not is there non-constant variance.
  * Zero mean error better to assess statistically.
    * Levenes test, bartlett, etc.
* A better way looking for non-normallity is qqplot or shapiro wilk test, limitation with large sample size departs from normality.

<!-- page 3 -->

* Uncorrelated error, looking at the residuals by time, if there are patterns that is a clean sign of violation. If we know a residual value for a time frame, we can predict other residuals and that is a violation of correlated error. This can be a problem in repeated measures.
    * Violates the independent assumption of IID.
* Unusual observations
    * leverage how similar is the value of a particular observation in relation to other values for that variable. Specific to predictor.
        * Measured with hatvalues, examine if you sum all hatvalues they should sum to the parameters in the model. Anything that is greater than two times the mean, the greater the leverage and can look at through half-normal plots.
        * Stundentized values, larger values to assess.
    * Outliers takes into account the regression model and fit, how similar is the specific observation to the prediction, how far away is it from the regression line. Does not mean it is an influential point.
        * Studentized residual to standardize and we can conduct a t-test using the we just want to look at the top ones.
        * `sort(abs(r_ex), dec=T)[1:10] > abs(qt(.05/10), N - P))`, divide alpha by test number, bonferoni correction. $P = \text{number of parameters}$.
            * False discovery rate is another approach.
    * Influential point, how much would the model change with out the point.
        * Cooks distance. Looking at larger values, and can use half normal plot.

<!-- page 4 -->

* Multiple testing, Bonferroni, alpha we are ok that 5% is due to chance of observing our observed data or more extreme. Family wise error rate, what is the chance given a particular alpha value that we will see at least 1 false positive, reject the null when we shouldn't. This probability gets big really fast. Once you get to 50 tests, you will have at least one false positive. So we use qt() to get the critical value. By not dividing alpha value by number of tests, we allow large chances of false positive, by dividing we make alpha smaller.

**November 12, 2024 problems with model errors**

* Constant variance assumptions
  * weighted least squares estimators, low variability get high weight, high variability get low weight. When the variance of error is proportional to predictors, or using absolute squared residuals to correct.
* Normally assumption. Can't use the t-test if there is a violation of normality. Robust regression, or bootstrapping, not assuming a t-distribution for the errors, using distribution of data and resample. The estimate is pulling themselves up by the bootstrap.
* Problems with predictors
  * Collinearity – when some predictors are linear combinations of other predictors. Exact linear perdition of others in the model called exact collinearity.
    * How to handle collinearity, by removing one variable such as dummy coding in the reference level.
    * If collinearity is not exact, what are the factors to assess, variance inflation factor (VIF).

### Factor (VIF)

For a predictor $X_j$, $V(\hat{\beta}_j) = \sigma^2 \frac{1}{1-R_j^2} \frac{1}{(X_{ij}-\bar{X}_j)^2}$, where

$R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept

Variance Inflation Factor: $VIF_j = \frac{1}{1-R_j^2}$

When $X_j$ is orthogonal to other predictors

$\Leftrightarrow R_j^2 = 0 \Leftrightarrow VIF_j = 1$

When $X_j$ is highly correlated with other predictors

$\Leftrightarrow R_j^2 \to 1 \Leftrightarrow VIF_j \to \infty$

    * Regressing a predictor on other predictors. R-squared J when there is collinearity for at least one, closer to a value of 1. For the variance of the predictors

<!-- page 5 -->

For a predictor $X_j$, $V(\hat{\beta}_j) = \sigma^2 \frac{1}{1 - R_j^2} \frac{1}{(X_{ij} - \bar{X}_j)^2}$, where

$R_j^2$: $R^2$ from a model regressing $X_j$ on other $X$'s and the intercept

Variance Inflation Factor: $VIF_j = \frac{1}{1 - R_j^2}$

More collinearity $\rightarrow$ Larger $R_j^2$ $\rightarrow$ Smaller denominator $\rightarrow$ Larger VIF
Less collinearity $\rightarrow$ Smaller $R_j^2$ $\rightarrow$ Larger denominator $\rightarrow$ Smaller VIF

$\Leftrightarrow R_j^2 = 0 \Leftrightarrow VIF_j = 1$

*   If $r^2$ larger, variance is larger, which the smaller the denominator and a larger VIF.
*   So, what would we expect to see with high collinearity/large VIF? Inflated, larger than expected.
    *   Look at faraway example pg 108.
    *   pairwise correction is bivariate, but a variable can be multiple collinear with other predictors.
    *   Sqrt{VIF} approximate how much variation inflation there is, how inflated the stand error is with this collinearity than if no collinearity was present.
        *   Inflated SE affects our inferences, precision, and hyp testing. Maybe not event detect effect size.
        *   We cannot use VIF, the inflation, to correct, it just tells us how bad this is.
*   An eigenvalues of zero indicates exact collinearity.
    *   Kappa, squared root of max eigenvalue / min eigenvalue, tells us if at least one of the eigenvalue is small relative to the rest.
*   Summary, VIF is user friendly for multicollinierity. Useful to look at Kappa $> 30$.
    *   if $> 30$, only tells us that at least one our our eigenvalues is smaller than the largest.
    *   What to do: Remove predictors, but not always feasible. Look at ridge regression.
    *   VIF is the most useful as it tells us the counter-factual (had there not been collinierity).
*   Variable rescaling:
    *   reasons to rescale and interpretation.
        *   Range is small, coefficients too small or too large.
        *   Different measurement systems, interpretation estimated coeff may not be straight forward.
        *   Different relationship between Y and X depends on range of X, recode X as a categorical.
        *   Rescaling does not change Hyp testing, changes magnitudes of model parameter.
*   Lack of Fit
    *   ideally compare estimated $\text{sigma}^2$ to $\text{sigma}^2$. But we don't know the population variance.
    *   We need some model free estimate of $\text{sigma}^2$. We have to have independent repeated values.
        *   Pure error, model free estimate of our sum of squared.

<!-- page 6 -->

The pure error (model-free estimate of $\sigma^2$) is given by $\frac{SS_{pe}}{df_{pe}}$ and

$$
SS_{pe} = \sum_i \sum_j (y_{ij} - \bar{y}_j)^2
$$

* We take the mean of y at a given value where we have multiple data points.
* Df is the following.

$$
df_{pe} = \#replicates_j - 1 = n - \#\ groups
$$

* Wrap a continuous predictor and convert to factor, by treating it as categorical, each level has it's own parameter fit. We estimate the mean for each replicate group. The hat{sigma^2} from this model will be our pure error. We can than use the F-test to compare the model of interest, tells us the lack of fit. Looks at the variability within repeated groups of X.
* look at pg 120 of faraway

**November 19, 2024 variable transformation**

* Review for assessing collinearity
  * eigenvalues, problematic if close to 0, perfect collinearity.
  * Can use eigenvalue, or kappa to say there is definite collinearity. No, only tells us that at least one of our eigenvalues is much smaller than our largest value.
  * VIF, what is the potential collinearity doing to our variance. Tells us how much collinearity we have compared to when the variable is not in the model. Gives us an idea of how problematic the collinearity is.
    * Easy fix is drop the problematic variable.
* Variable transformation
  * Can improve linear relationship, prediction, remedy zero mean error or constant variance.
  * Will also change the scale of the variable. Do all calculation on the transformed scale, and back transform at the end.
    * There are also flexible tools that relax some of these assumptions.
  * Box-cox transformation, finding lambda, there are different types of transformations.

Seek a value of $\lambda$ such that $Y_i^{(\lambda)} = X\beta_i + \epsilon_i$ with $\epsilon_i \sim N(0, \sigma^2)$

Common in practice: $\lambda \in [-2, 2]$

$$
Y^{(\lambda)} = \begin{cases} \frac{Y^\lambda - 1}{\lambda} & \text{for } \lambda \neq 0 \\ \ln(Y) & \text{for } \lambda = 0 \end{cases}
$$

| | |
| --- | --- |
| $\lambda = 2$ | Squared Tranformation |
| $\lambda = 1$ | No Tranformation |
| $\lambda = 0.5$ | Square Root Tranformation |
| $\lambda = 0$ | Log Tranformation |
| $\lambda = -0.5$ | Inverse Square Root Tranformation |
| $\lambda = -1$ | Inverse Tranformation |
| $\lambda = -2$ | Inverse Squared Tranformation |

<!-- page 7 -->

* Why log transform, we take a non-linear relationship and make it linear.
  * Issues, values close or equal to zero causes issues. Can add small increments to all values to increase zero, called a constant.
  * Try to find alpha using MASS::logtrans()

$$y' = \log(y + \alpha) \rightarrow \text{want to find } \alpha$$

* Complicates goodness of fit, or loose interpretation for 0 values if meaningful.
* Plot shows us when using boxcox() we can use the following table to determine the type of transformation to take.

### Interpretation of transformed variable

| Common Box-Cox Transformations | |
| :--- | :--- |
| **Lambda value ($\lambda$)** | **Transformed data ($Y'$)** |
| -3 | $Y^{-3} = 1/Y^3$ |
| -2 | $Y^{-2} = 1/Y^2$ |
| -1 | $Y^{-1} = 1/Y^1$ |
| -0.5 | $Y^{-0.5} = 1/(\sqrt{Y})$ |
| 0 | $\log(Y)^{**}$ |
| 0.5 | $Y^{0.5} = \sqrt{Y}$ |
| 1 | $Y^1 = Y$ |
| 2 | $Y^2$ |
| 3 | $Y^3$ |

* Mgvc package https://www.maths.ed.ac.uk/~swood34/mgcv/ for GAM models and GAMM
* boxcox() function to see if any transformation might make sense. Gives us a plot
  * What falls into the middle vertical line, crude look at this problem. Look at 2<sup>nd</sup> plot above
* Polynomial regression can account for non-normal relationships to include quadratic transformation. It includes different order polynomials.

<!-- page 8 -->

* We can see clear non-linear relationships between each predictor and the outcome.
* The model in R looks like: Use I() so R does not interpret incorrectly. This is the insulate function.

Polynomial model 1:

```r
lm(y ~ x1 + x2 + I(x1^2) + I(x2^2), dat)
```

* If we continue to add higher order polynomials, very rarely will we encounter quadratic relationships. Useful for approximation, prone to overfitting.
* More on GAMs
  https://m-clark.github.io/generalized-additive-models/case_for_gam.html#polynomial-regression-1
* GAM, adding functions, breaking the model into different sections with each section fit using a function.

$$
Y = \beta_0 + f_1(X_1) + f_2(X_2) + \epsilon
$$

* Model selection
  * We want model parsimony to reduce noise, reduce data collection resources.
  * What do we want to do with the model? Explain phenomenon, predict future observations?
  * Don't use forward, backward or stepwise selection. There are drawbacks.
  * Criterion-based procedures
    * Likelihood function, maximizes probability of seeing the parameters. Find the values of the model parameters that maximize the likelihood function over the parameter space (i.e., the likelihood that the model produces the observed data)

<!-- page 9 -->

* We want a large log-likelihood, we are maximizing, increase the likelihood so we want a smaller absolute value.
    * AIC, BIC, we want smaller values, penalty on more parameters.
    * Mallow's C_p, we want smaller values as it takes RSS, which we want smaller residuals.
  * Forward, backward, stepwise selection drawbacks.
    * Forward selection, start with intercept only model and add predictors, evaluate on AIC/BIC to decide if model is not getting better.
    * Backward is the opposite
    * stepwise selection - combination of both.
    * Limitations
      * there is no correction for p-values. We may have some spurious significant results.
      * Summary of the problem from https://hbiostat.org/rmsc/multivar#sec-multivar-variable-selection
        * publication bias, what we find in literature review mostly represents what is significant. Same concept here, if we are estimating if hat_beta is significant, we will not be able to study other variables that are not significant.
      * Summary of the problem: $E(\hat{\beta}|\hat{\beta}\ is\ significant) \neq \beta$ (Chatfield, 1995)
      * Biased $R^2$, $\hat{\beta}$, standard errors, and p-values
      * $F$ and $\chi^2$ statistics do not have the claimed distribution$^2$ (Grambsch & O'Brien, 1991)
      * Will result in residual confounding if use variable selection to find confounders (Greenland, 2000)
      * Derksen & Keselman (1992) found that in stepwise analyses the final model represented noise 0.20-0.74 of time, final model usually contained <1/2 actual number of authentic predictors

November 26 2024 Causal inferences
* counterfactual, what would have happened if all exposed had been unexposed, and the inverse.
  * No other plausible explanation for observed association.
* Exchangeability, control and treated group should be comparable, difference should be due to chance.
  * Analytically, stratification, but gold standard is randomization.
* 5 common experimental designs

<!-- page 10 -->

**Design 1: Basic Treatment vs. Control**

| | | |
| :---: | :---: | :---: |
| $\text{R}$ | $X$ | $O$ |
| $\text{R}$ | | $O$ |

**Design 2: Basic Comparing Multiple Treatment Conditions**

| | | |
| :---: | :---: | :---: |
| $\text{R}$ | $X_A$ | $O$ |
| $\text{R}$ | $X_B$ | $O$ |
| $\text{R}$ | $X_C$ | $O$ |

**Design 3: Basic Comparing Multiple Treatments with Control**

| | | |
| :---: | :---: | :---: |
| $\text{R}$ | $X_A$ | $O$ |
| $\text{R}$ | $X_B$ | $O$ |
| $\text{R}$ | | $O$ |

**Design 4: Pretest-Posttest Control Group**

| | | | |
| :---: | :---: | :---: | :---: |
| $\text{R}$ | $O_1$ | $X$ | $O_2$ |
| $\text{R}$ | $O_1$ | | $O_2$ |

**Design 5: Pretest-Posttest With Multiple Treatments**

| | | | |
| :---: | :---: | :---: | :---: |
| $\text{R}$ | $O_1$ | $X_A$ | $O_2$ |
| $\text{R}$ | $O_1$ | $X_B$ | $O_2$ |
| $\text{R}$ | $O_1$ | | $O_2$ |

---

Randomization
Outcome observed
Treatment assigned

**Design 1: Basic Treatment vs. Control**

| | | |
| :---: | :---: | :---: |
| $\text{R}$ | $X$ | $O$ |
| $\text{R}$ | | $O$ |

**Design 2: Basic Comparing Multiple Treatment Conditions**

| | | |
| :---: | :---: | :---: |
| $\text{R}$ | $X_A$ | $O$ |
| $\text{R}$ | $X_B$ | $O$ |
| $\text{R}$ | $X_C$ | $O$ |

**Design 3: Basic Comparing Multiple Treatments with Control**

| | | |
| :---: | :---: | :---: |
| $\text{R}$ | $X_A$ | $O$ |
| $\text{R}$ | $X_B$ | $O$ |
| $\text{R}$ | | $O$ |

**Design 4: Pretest-Posttest Control Group**

| | | | |
| :---: | :---: | :---: | :---: |
| $\text{R}$ | $O_1$ | $X$ | $O_2$ |
| $\text{R}$ | $O_1$ | | $O_2$ |

**Design 5: Pretest-Posttest With Multiple Treatments**

| | | | |
| :---: | :---: | :---: | :---: |
| $\text{R}$ | $O_1$ | $X_A$ | $O_2$ |
| $\text{R}$ | $O_1$ | $X_B$ | $O_2$ |
| $\text{R}$ | $O_1$ | | $O_2$ |

---

* Factorial or fully cross design, every combination of treatment variables in the data.
* Balance design, each group is balanced.
* One way anova
  * Cell means model, mean for every level of factor of X, treatment group.
  * Effects model, deviation from the grand mean.

* Cell means model: $Y_{ij} = \mu_i + \epsilon_{ij}$
  * $\mu_i$: Cell $i$ mean
  * Estimates mean for each treatment level, not overall mean
* Effects model: $Y_{ij} = \mu + \alpha_i + \epsilon_{ij}$
  * $\mu$: Overall mean
  * $\alpha_i$: Treatment effects
  * Estimates overall mean and the deviation each treatment from overall mean

<!-- page 11 -->

* One-way ANOVA tests the hypothesis:
  * $H_0: \alpha_1 = \alpha_2 = \dots = \alpha_a \text{ vs. } H_A: \text{At least one of the } \alpha \text{ is different}$, or
  * $H_0: \mu_1 = \mu_2 = \dots = \mu_a \text{ vs. } H_A: \text{At least one of the } \mu \text{ is different}$

  * Null, At least one of the group means is different.
* Pairwise difference tests
  * [http://users.stat.umn.edu/~gary/book/RExamples/pairwise-comparisons.html](http://users.stat.umn.edu/~gary/book/RExamples/pairwise-comparisons.html)
  * https://statsandr.com/blog/two-way-anova-in-r/#pairwise-comparisons
* Two way anova -

### Two-way ANOVA

Analysis of $Y_{ijk}$, where
* $i = 1, \cdots, I$: levels in factor $A$
* $j = 1, \cdots, J$: levels in factor $B$
* $k = 1, \cdots, n_{ij}$: subjects assigned to the level $ij$ of combined factors $A$ and $B$
* $\sum_{i=1}^I \sum_{j=1}^J n_{ij} = n_{\bullet\bullet}$: total sample size
* $n_{ij} = n \rightarrow \text{Balanced design}$
* $n_{ij} = 1 \rightarrow \text{No replication}$

$Y_{ijk}$ can be expressed with a cell means model and an effects model

* fixed vs random effects
  * all levels included, fixed treatments, while if you can only take a sample of all the plausible treatments we can use random effects.
    * Fixed effect, making assumption that these are all the treatments
* $Y_{ij}$ with $i = 1, \dots, a$ treatment levels and $j = 1, \dots, n_i$ subjects
* When the treatment levels in factor A include the entire population of all possible levels, or are selected purposely, A is a **fixed factor** (AKA fixed effect)
* When the treatment levels in factor A include a random sample from a population of all levels, A is a random factor (AKA random effect)
* These are different model specifications depending on the nature of A

| | $\sigma_\alpha^2 + \sigma_\epsilon^2$ | |
| :--- | :--- | :--- |
| Interested in estimating $\alpha_i$ and/or differences in $\alpha_i$ | Interested in estimating variance components (i.e., contributions of $\sigma_\alpha^2$ and $\sigma_\epsilon^2$ in relation to $\sigma^2$) | This has important implications for the hypothesis being tested |

* random effects use partial pooling, shearing of the model.

<!-- page 12 -->

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

ANOVA table with one-way treatment structure with balanced design:

**Fixed Effect**

Hypothesis tested with $F = \frac{MS_A}{MS_E}$

$H_0 : \alpha_1 = \alpha_2 = \dots = \alpha_a$ vs. $H_A$: Not $H_0$

**Random Effect**

Hypothesis tested with $F = \frac{MS_A}{MS_E}$

$H_0 : \sigma_\alpha^2 = 0$ (i.e., does $\sigma_\alpha^2$ play a role in $\sigma^2$?) vs. $H_A$: $\sigma_\alpha^2 > 0$

December 3 2024 Resampling
* sampling from a training set, refit the model.
  * We can assess parameter estimate precision through cross validation: model assessment to determine model fit and performance, and model selection.
* Resampling methods
  * bootstrapping
    * Take draws from the data, with replacement, N times, combine and average results.
    * We never have the population, just a sample, so we attempt to take subsamples from a sample and combine to get a representation of the population.

<!-- page 13 -->

* Cross-validation
  * take total sample and split to examine test error.
  * Splitting the sample
    * validation set: split into training /test. Fit model on training set, test set to predict.
      * Limitation: Sample size gets smaller, reduces statistical power. It is likely that we are going to overestimate the error rate b/c statistical methods perform worse when trained on few observations.
    * LOO, leave one out
      * leave out one observation for each N iteration, average out model. Here we do not overestimate the test error.
      * Limitations: computationally costly.
    * K-fold, alternative to LOO, divide sample into K folds.
      * First fold would be validation set, calculate some MSE, and iterated over K times.
        * This is less computationally costly, 5-10 k-folds is good. Has more advantageous in bias-variance trade off vs LOO. The data is more correlated.
      * Limitations: more biased than LOO, smaller variance than LOO where training sets are almost identical (highly correlated).

<!-- page 14 -->

* Review for Final:
  * Variance Inflation Factor (VIF) to show collinearity, kappa and eigenvalues are ratios meaning that we can say with certainty there is collinearity b/c if we have large eigenvalues it can inflate the ratio. VIF tells us how inflated the variance is if we removed a variable. Avoid $\text{VIF} > 5$.
  * OLS assumption, constant error variance (Homoscedasticity), zero mean error, normally distributed, all assessed through our residuals by plotting.
    * If assumptions are violated, transform outcome, or apply more flexible models such as splines (GAM), polynomials, or include interactions.
    * Zero mean error violation, OLS estimators are not unbiased. Cannot guarantee $\text{beta\_hat} = \text{beta}$ in the population.
      * Split the residuals in half based on fitted values and re-calculate the mean for the residuals, after we can compare with a t-test.
        * T-test assumptions, equal variance or if the means are dependent on each other (use paired t-test).
    * Homoscedasticity, cannot guarantee that variance in beta\_hat is unbiased.
      * Assess through variance test with is an F test. If $< .05$, variances are not equal there is violation of homoscedasticity, reject the Null.
    * Normality of errors, increase sample, bootstrap, GAM, or transform the outcome.
  * Random effect model
    * We are interested in $\text{sd(Intercept)}|\text{group}$ confidence interval, whether the variance of the group contributes to the variance in the outcome. If CI does not include $0$, reject the Null that $\text{sigma\_a} = 0$.
