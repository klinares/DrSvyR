---
id: "jpsm/applied_sampling_SURV625/lectures/Lecture12"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "lecture"
title: "Nonresponse Adjustment"
original: "applied_sampling_SURV625/lectures/Lecture12.pdf"
pages: 30
sha256: "449c0b770b575d57746d0fa061abb6b2628aa6b7b1c49c8632b3957335ed3835"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T14:17:41"
---

<!-- page 1 -->

# Nonresponse Adjustment

## SurvMeth/Surv 625: Applied Sampling

Yajuan Si

University of Michigan, Ann Arbor

4/9/25

<!-- page 2 -->

# Nonresponse types

* Unit nonresponse
    * Fail to observe anything about the unit
    * Recent theoretical development suggests that this is a complex phenomenon
    * Usually addressed with weights
* Item nonresponse
    * Fail to observe a question or questions
    * Recent theoretical development suggests that this is a failure of the response process
    * Usually addressed with imputation

<!-- page 3 -->

# Response rates

- What is a response rate?
  - The number of units that responded out of all eligible units
- Many ways to calculate a response rates
  - Response Rates, Cooperation Rates, Refusal Rates, Contact Rates
  - Mode specific (Phone, In-person, Mail)
  - Unweighted vs. Weighted Response Rates
- The American Association for Public Opinion Research Standard Definitions

<!-- page 4 -->

# Nonresponse bias

- Two theoretical approaches to nonresponse
  - Deterministic: classes of respondents and nonrespondents
  - Stochastic: everyone has a probability of being a respondent or nonrespondent
- Nonresponse Bias
  - Function of response rates and survey variables ($Y$)
  - Specific to a statistic, not a survey
  - Unadjusted estimate based only on the respondents is different from the estimate based on the entire sample
  - Nonresponse adjustments attempt to reduce (or eliminate) nonresponse bias

<!-- page 5 -->

# Deterministic model

* Nonresponse bias is a function of nonresponse rate and the difference between respondents and nonrespondents

$$
Bias(\bar{Y}_R) = \bar{Y}_R - \bar{Y} = \frac{N - R}{N}(\bar{Y}_R - \bar{Y}_M)
$$

<!-- page 6 -->

# Stochastic model

* Model response mechanism and propensities
* Nonresponse bias depends on the covariance between response propensity and survey variable and the average response propensity

$$Bias(\bar{Y}_R) = \frac{Cov(\phi, y)}{\bar{\phi}}$$

<!-- page 7 -->

# Missing data mechanisms

* MCAR: Missing Completely at Random; Respondents are a random subsample of the full sample (very strong assumption!)
* MAR: Missing at Random; Respondents are a random subsample of the full sample within particular subclasses defined by other observed variables (weaker assumption!)
* MNAR: Missing not at random; response depends on the values of the variable being observed, even when conditioning on other observed variables
* Foreshadowing: Variables used to develop weighting adjustments need to be predictive of response propensity and key variables

<!-- page 8 -->

# Weighting

* Sample-based weighting
  * Require information for your sample on your frame
    * Inverse of Response Rates Weighting
    * Response Propensity Weighting
* Population-based Weighting
  * Require information for your target population outside the frame
    * Poststratification
    * Raking

<!-- page 9 -->

# Weighting class adjustment

1. Divide units in the sample among $C$ weighting classes based on auxiliary information

2. Within each class $c$, adjust the weights for respondent $i$ as
   $$\tilde{w}_i = w_i * \frac{1}{\hat{\psi}_c} = w_i * \frac{\text{sum of weights for all samples in class c}}{\text{sum of weights for respondents in class c}}$$

3. Check the weight adjustment by verifying $\sum_{i \in R} \tilde{w}_i \sum_{i \in S} w_i$ and $\sum_{i \in R,c} \tilde{w}_i \sum_{i \in S,c} w_i$

<!-- page 10 -->

# Constructing weighting classes

* We want weight adjustments to reduce nonresponse bias as much as possible for estimates of key population quantities.

$$
\begin{aligned}
Bias(\bar{y}_R) = &\sum_h W_h(\bar{Y}_{Rh} - \bar{Y}_R)(\bar{R}_h - \bar{R})/\bar{R} + && (1) \\
&\sum_h W_h\bar{M}_h(\bar{Y}_{Rh} - \bar{Y}_{Mh}) && (2)
\end{aligned}
$$

* If at least one of the following situations occurs within each weighting class $c$
  1. Every sampled unit in the same class has the same response propensity
  2. All population members have the same $y$ value
  3. The response propensity is uncorrelated with the characteristic $y$
* Use auxiliary variables that are associated with both the response propensities and the key survey variables

<!-- page 11 -->

# What are good variables to use for weighting class adjustments?

* Traditionally, age/race/sex adjustment cells are created as poststratifiers
* Sample-based weighting approaches, including response propensity models, typically look for predictors of response propensity
* The best variables predict both the survey variables and response propensity
* Risk: Increase variance without reducing bias
* If you can only predict one, then aim for the survey variables

<!-- page 12 -->

# Response propensity weighting

- A model for the response propensity $P(R_i = 1)$
- The predictors can include dummy variables, interactions, or continuous variables
- Use a logistic regression to estimate the predicted probabilities
- Weights are computed as the inverse of the predicted probability.
- Response propensities may be grouped into classes and an average value used as the weight for the class
- Reduces variability of the weights, and variance increases

<!-- page 13 -->

# Poststratification

* Main idea: Make the full distribution of your respondents on certain characteristics look like the full distribution of those characteristics in the entire population
  * Example: Make your observed age and sex distributions of your respondents match that from the latest U.S. Census
  * Distributions match within each cell of the population table
    * E.g., the proportion of males between age 20 and 65
* The poststratification weight $w_{hi} = (N_h/N)/(r_h/r)$, where $r_h$ can be sum of weights in Stratum $h$

<!-- page 14 -->

# Poststratification estimator bias

* Poststratification gets rid of the first term in bias of (1)
* Bias of the poststratification estimator
  $$Bias(\bar{y}_{ps}) = \frac{1}{N} \sum_h N_h \frac{COV_h(\psi, Y)}{\psi_h}$$
* Bias disappears when:
  * Poststrata are homogeneous with respect to the target variable.
  * Poststrata are homogeneous with respect to the response probabilities.

<!-- page 15 -->

# Raking

- Main idea: Make the marginal distribution of your respondents on certain characteristics look like the marginal distribution of those characteristics in the entire population
  - Example: Make your observed age and sex distributions of your respondents match that from the latest U.S. Census on the margins, but not for each subgroup
  - Distributions match on the marginal cells of the population table
  - E.g., the proportion of males and those aged between age 20 and 65 match the marginal distribution from the latest CPS

<!-- page 16 -->

# Iterative proportional fitting

* You want to match the marginal distribution, but you can only do one margin at a time.
* Consider the 2-way table.
    * Create weights to match the distribution of one variable.
    * Recalculate the cell counts and create new totals.
    * Then, create weights to match the distribution of the other variable, using the new cell counts.
    * Iterate through this procedure, alternating between the two variables until weights and marginal counts stabilize.
* Also known as iterative proportional fitting or multiplicative weighting
    * A log-linear model in which you want the complete cross-classification and are given marginal distributions

<!-- page 17 -->

# When does raking work?

* Raking is beneficial
  * When there is no interaction effect between the variables used for raking
  * When adjustment by only one variable leaves enough residual nonresponse bias that the addition of another variable adds value
  * When convergence can occur quickly
* Raking estimator has complex mean square error; can lead to small cells

<!-- page 18 -->

# Poststratification vs. raking

* Poststratification assumes an interaction effect
* Raking assumes two marginal effects, but no interaction effect
* The stronger the interaction effect, the more the weights created by raking and by poststratification will differ

<!-- page 19 -->

# Computing Final Weights

1. First, weight for unequal probabilities of selection
2. Next, form weighting classes for nonresponse using available auxiliary information (preferably related to both the key variables and response propensity), and computing weighting adjustments
3. Next, we compute weighted estimated totals within population cells (e.g., post-strata), where known population totals are available for each cell. The final population-based adjustment is then the ratio of the known population total to the estimated population total within that class (e.g., post-stratum)
4. The final survey weight simultaneously incorporates sample-based adjustments for nonresponse and population-based adjustments for calibration
5. Check the sum of the final weights for characteristics with known population totals

<!-- page 20 -->

# Examples: National complex sample survey weighting methods

* ACS (Team Cochran)
* CPS (Team Groves)
* FoodAPS (Team Heeringa)
* GSS (Team Hess)
* HRS (Team Lepkowski)
* NHANES (Team Little)
* NHIS (Team Valliant)

<!-- page 21 -->

# Imputation

- Complete Case Analysis
- Mean value imputation
- Mean imputation with random residual
- Hot deck imputation
  - Sequential
  - Hierarchical
- Regression imputation
  - Deterministic and stochastic
- Sequential regression imputation

<!-- page 22 -->

# Multiple imputation

* Imputation adds variance to estimates
* May be viewed as two-phase sampling
* Under-estimate variances using imputed data sets, because of larger sample sizes
* Multiply impute
  * Create multiple data sets (at least 5), each imputed separately
  * This is a Bayesian procedure, so you select values from the posterior distribution
  * Imputing multiple times allows you to adequately account for the variance from imputation

<!-- page 23 -->

# Multiple imputation inference

- Compute estimated values for study variables as an average of values across multiple imputations
- Compute variance of estimates as sum: within and between imputed data set variances
- Degrees of freedom
- Fraction of missing information

<!-- page 24 -->

# Course summary

- Implementation
- Inference
- Projection

<!-- page 25 -->

# Topic 1: Design Effects and Sample Size

- How do you compute a required SRS sample size given study objectives? What information do you need?
- How do you compute a design effect given data from a sample with a complex design? What numbers do you need for the SRS variance?
- How do you compute roh for a cluster sample, given information about the sample design and the design effect?
- How do you compute a required sample size for a *complex* sample, using design effect and simple random sample size information?
- How do you estimate the variance of a new sample design given (possibly new) design effect information?
- How do you compute allocations for stratified cluster samples?

<!-- page 26 -->

# Topic 2: Variance Estimation

- We've spent a lot of time on how to estimate sampling variance correctly based on a complex sample design!
- Taylor Series Linearization for a ratio mean, given a stratified cluster sample (where the clusters are of unequal size, and strata have a specified number of clusters that were sampled)
- Is the Taylor Series approximation adequate?
- Balanced Repeated Replication: using a Hadamard matrix correctly, variance estimation based on half-sample estimates
- How should one form confidence intervals for parameters based on the complex sampling features? What are the degrees of freedom, based on the information used for variance estimation? What is the appropriate critical t-value?

<!-- page 27 -->

# Topic 3: Systematic PPeS Selection

* Computation of sampling fractions based on PPeS sampling (first-stage, second-stage, overall, etc.)
* After-selection linking procedures to deal with undersized units (remember: the MOS of the selected unit may actually change for calculation of sampling fractions!)
* Appropriate methods for computing selection intervals for systematic PPeS selection of clusters (using available MOS values)
* Implementation of systematic PPeS sampling, based on fractional intervals
* Required subsample sizes at the final stage to maintain epsem
* Expected sample size realizations based on required sampling rates and actual cluster sizes

<!-- page 28 -->

# Topic 4: Forming Sampling Frames and SECUs

- Building sampling frames from various materials
- Frame problems and possible solutions to frame problems
- Collapsing strata and combining strata
- Calculation of degrees of freedom based on a sampling error calculation model

<!-- page 29 -->

# Topic 5: Nonresponse adjustment

- Nonsampling error
- Nonresponse types and bias
- Missing data mechanisms
- Weighting
- Imputation

<!-- page 30 -->

# Questions?

* Thanks to everyone for a great class, and for all of the good questions!
* Please remember that all exercises, homework questions, exam questions, etc. were designed to give you realistic examples that you can refer back to in the future.
* Don't forget to fill out your evaluations!
