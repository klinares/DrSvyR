---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_13"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 13.pdf"
pages: 85
sha256: "871d9beafad1e3c3459903802ec5f91f8496839b345e81f1b47a02d6c086078f"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:09"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference

## Chapter 13: Basic Steps in Weighting

Sunghee Lee

Sunghee Lee (U of Michigan)

Prac Tools Ch. 13

<!-- page 2 -->

# Outline

1. 1. Overview
2. 2. Theoretical Ideas
3. 3. Base Weights
4. 4. Unknown Eligibility
5. 5. Nonresponse
   - 5.1 Nonresponse Mechanism
   - 5.2 Weighting Class Adjustments
   - 5.3 Propensity Score Adjustments
   - 5.4 Weighting Class vs. Propensity Score Adjustments
   - 5.5 Classification Algorithm
6. 6. Collapsing Classes

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 2 / 85

<!-- page 3 -->

1. Overview

# 1. Overview

Sunghee Lee (U of Michigan)

Prac Tools Ch. 13

<!-- page 4 -->

1. Overview

# Introduction

* Survey weights are a key component to producing population estimates.
* For example, an estimated total has the form $\hat{t} = \sum_s w_i y_i$ where $y_i$ is a response provided by the sample member $i$ and $w_i$ is the corresponding analysis weight.
* Series of steps in weighting that are carried out in most surveys.
  1. computation of base weights (also known as design weights)
  2. adjustments for unknown eligibility
  3. nonresponse adjustments
  4. use of auxiliary data to reduce variances and, in some cases, correct for frame deficiencies.
* Steps #1-3 covered in this chapter.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 4 / 85

<!-- page 5 -->

1. Overview

# Uses of Weights

* General goal in weighting to find a set of weights, $w_i$ , that can be used in virtually all analyses to produce estimates.
  * An estimated total: $\hat{t} = \sum_s w_i y_i$
  * An estimated mean: $\hat{\bar{y}} = \sum_s w_i y_i / \sum_s w_i$
* Other statistics that can be written as combinations of estimated totals would use the same set of weights.
  * Some regression model analyses (linear and nonlinear) begin with estimating equations (types of estimated totals) used to derive parameter estimates.
  * Estimates of medians and other quantiles depend on the same weights used to estimate totals.
* Properly constructed, a set of weights can provide approximately unbiased and consistent estimates of many different population quantities.
* One set of weights can serve many purposes, which is a major practical advantage.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 5 / 85

<!-- page 6 -->

1. Overview

# Survey Attempt Results

* Sample $s$ $\rightarrow$ Know eligible
  * N $\rightarrow$ Eligiblity unknown $s_{UNK}$
  * Y $\rightarrow$ Eligibility known $s_{KN}$ $\rightarrow$ Eligible
    * N $\rightarrow$ Ineligible $s_{IN}$
    * Y $\rightarrow$ Eligible $s_E$ $\rightarrow$ Respond
      * N $\rightarrow$ Nonrespondent $s_{ENR}$
      * Y $\rightarrow$ Respondent $s_{ER}$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 6 / 85

<!-- page 7 -->

1. Overview

# Figure 13.1: General Steps in Weighting

* **1. Compute base weights for all sample units**
* **Units with unknown eligibility (UNK)**
  * **Y**:
    * **2. Adjust weights of KNs**
      * **2a. Store file of UNKs**
      * **2b. Store file of INs**
      * **2c. Store file of eligibles (ER+ENR)**
  * **N**: (proceeds to Nonresponding units (ENR))
* **Nonresponding units (ENR)**
  * **Y**:
    * **3. Adjust weights of ERs**
      * **3a. Store file of ENRs**
      * **3b. Store file of ERs**
  * **N**: (proceeds to Aux. data to adj. for coverage errors or reduce variances)
* **Aux. data to adj. for coverage errors or reduce variances**
  * **Y**:
    * **External control totals** $\rightarrow$ **4. Calibration estimation**
  * **N**: (proceeds to 5. Store analysis file of ERs)
* **5. Store analysis file of ERs**

Sunghee Lee (U of Michigan)

Prac Tools Ch. 13

<!-- page 8 -->

2. Theoretical Ideas

# 2. Theoretical Ideas

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 8 / 85

<!-- page 9 -->

2. Theoretical Ideas

# Methods of Evaluating Estimators

* Weights are used in constructing estimators
  – Key goal in weight construction should, thus, be to construct good estimators.
* To know whether an estimator is good or not, we have to evaluate its properties, like bias and variance, with respect to some statistical distribution.
* Three methods of generating the distribution used for inference:
  1. Design- or Randomization-based
  2. Model-based
  3. Model-assisted

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 9 / 85

<!-- page 10 -->

2. Theoretical Ideas

# Design-Based Inference - 1

* Properties of estimators, like bias and variance, are evaluated with respect to repeated sampling
* A probability sample must be selected to use this approach, i.e., a random mechanism is used to select units and, in principle, every unit has a known probability of selection (VDK Ch. 3).
* To compute expectation of an estimator, think of a conceptual experiment where samples are repeatedly selected using the same plan.
  * Estimate is computed for each sample.
  * If these values average out to the full finite population value, then the estimator is *design-unbiased*.
  * Other properties, like the *design-variance*, are computed similarly.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 10 / 85

<!-- page 11 -->

2. Theoretical Ideas

# Design-Based Inference - 2

- If a random mechanism is used in selection, conscious and unconscious biases are eliminated in selecting the sample.
- Random sampling is perceived as objective by the public and data users.
- Provides a mathematical foundation for computing properties of estimates.
- However, most samples that start out as probability samples do not end up that way because of nonresponse (NR) and other problems that result in the loss of some sample units.
  $\Rightarrow$ strictly design-based inference is usually not feasible.
  -- Models for nonresponse, undercoverage, and other nonsampling errors are needed to completely reflect the processes that produce a sample.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 11 / 85

<!-- page 12 -->

2. Theoretical Ideas

# Design-Based Inference - 3

* Having good design-based properties is comforting.
* It is reasonable for a practitioner to be able to say that, if he or she selects random samples over the course of a career, then the methods used will produce correct answers on average.
* However, the design-based approach does not provide a systematic way of constructing good estimators.
* The relationship of response variables to predictors is not formally considered in design-based inference.
* Thinking about models that describe the variables in a population provides some structure that can be used as a guide.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 12 / 85

<!-- page 13 -->

2. Theoretical Ideas

# Model-Based Inference - 1

* By contrast, a strictly *model-based* approach ignores the sample design and considers only the population structure (i.e., a model) in deciding on an estimator and the corresponding weights.
* This approach can be applied to either probability or non-probability samples.
  * Courses in mathematical statistics use estimators with the assumption that units are drawn from an infinite population.
  * Estimators may be unbiased under the model used to construct the estimators, but can be biased if the model is misspecified or the model that fits the sample is different from the one that describes the population as a whole.
* In some cases, model-based estimation is the only choice.
  * Internet survey of volunteer participants: not a probability sample design (VDK Ch. 18)
  * Estimators must be constructed using models
  * Whether the volunteers are so unlike the full population that estimation is impossible is a serious concern

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 13 / 85

<!-- page 14 -->

2. Theoretical Ideas

# Model-Based Inference - 2

* Problems with model-based inference:
  * Model may be wrong; diagnosing this may be hard
  * Same model may not fit every $y$
* Models inevitably need to be considered when developing weights, even in probability samples
* Any sample with some degree of nonresponse requires assumptions about nature of the analysis variables for the nonrespondents and about the response mechanism.
* When computing weights for a volunteer survey, assumptions may be made about the mechanism that describes how likely a person is to participate.
* These assumptions, whether explicit or implicit, are models.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 14 / 85

<!-- page 15 -->

2. Theoretical Ideas

# Model-Based Inference - 3

* There are good, though fairly technical, arguments for why the randomization distribution itself should not be the basis for inference, even in the absence of nonresponse.
* General line of reasoning is that averaging over a randomization distribution involves averaging over samples that can be much different from the one actually selected.
  * Design-based inference requires us to consider events that did not actually happen and are, therefore, irrelevant.
  * References for discussion of the fundamental issues: Royall (1976), Smith (1976, 1984, 1994), Valliant, Dorfman, Royall (2000).

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 15 / 85

<!-- page 16 -->

2. Theoretical Ideas

# Model-Assisted Inference

- Hybrid approach that uses both model-based and design-based thinking
- A probability sample is selected, weights calculated, and a model(s) guides the choice of the estimator.
- Inferences are made using distribution generated by the probability sampling plan—not a model.
  See Särndal, Swensson, Wretman (1992)
- Model-assisted is the approach in this chapter

Sunghee Lee (U of Michigan)

Prac Tools Ch. 13

<!-- page 17 -->

3. Base Weights

# 3. Base Weights

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 17 / 85

<!-- page 18 -->

3. Base Weights

# Probability Samples: A Review - 1

1. The set of all samples $\mathbf{S} = s_1, s_2, \cdots, s_M$ that can be selected from a finite population $\mathbf{U}$ can be defined given a specified sampling procedure.
2. A known probability of selection $p(s)$ is associated with each possible sample $s \in \mathbf{S}$.
3. Every element in the target population has a non-zero probability of selection with the specified random sampling procedure.
4. One sample $s^*$ is selected by a random mechanism under which each $s \in \mathbf{S}$ receives the probability $p(s)$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 18 / 85

<!-- page 19 -->

3. Base Weights

# Probability Samples: A Review - 2

* We only need selection probabilities of individual elements
  $\pi_i$: selection (or inclusion) probability of element $i$
* Base weights: $d_{0i} = 1/\pi_i$
* Selection probabilities may be computed as the product of conditional probabilities at different stages of selection.
  * Note that the size of the sample is not necessarily a fixed value and is also associated with the sampling procedure (see, e.g., Poisson sampling in VDK Ch. 3).
* Base weights should be created as soon as the sample is selected if possible.
  * Facilitates preliminary analyses, like performance rate calculations
  * Insures that items required for computation of base weights do not get lost

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 19 / 85

<!-- page 20 -->

3. Base Weights

# Quality Control Check

* Selection probabilities are all within the range $(0, 1]$
* Base weights should sum to the total number of elements in the population or to a reasonable estimate of the population size.
* Similar checks on the sums of weights should be made for major subgroups (sex, race/ethnicity, establishments in retail trade, etc.)

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 20 / 85

<!-- page 21 -->

3. Base Weights

# Example 13.1: *srswor*

- $n$ (fixed) units selected from population of size $N$
- Selection probability of each unit: $\pi_i = n/N$
- Base weight: $d_{0i} = \pi_i^{-1} = N/n$, the same for all units
- An *srswor* is called *self-weighting* or *epsem* (equal probability sampling and estimation method)

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 21 / 85

<!-- page 22 -->

3. Base Weights

# Example 13.2: *stsrswor*

- Population is divided into $h = 1, \cdots, H$ mutually exclusive strata that cover the whole population.
- *srswor* of size $n_h$ is selected in each stratum from a population of size $N_h$
- Selection probability of unit $i$ in stratum $h$: $\pi_h = n_h / N_h$
- Base weight: $d_{0hi} = \pi_{hi}^{-1} = N_h / n_h$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 22 / 85

<!-- page 23 -->

3. Base Weights

# Example 13.3: Two-stage sampling leading to *epsem*

- A sample of students is selected in two stages–schools at the first stage and students at the second stage.
- PSUs are schools. Assume that $m$ PSUs are selected with probabilities proportional to size (*pps*) of the student body and that an equal probability sample of $\bar{n}$ students is selected in each PSU.
- Schools are selected in such a way that the inclusion probabilities are $\pi_i = mN_i/N$
- Suppose equal probability sample of $\bar{n}$ students is selected in each sample school
- Overall probability of selection is: $\pi_{ij} = \pi_i \pi_{j|i} = \frac{mN_i}{N} \frac{\bar{n}}{N_i} = \frac{m\bar{n}}{N}$
- Base weight for student $j$ in school $i$ is $d_{0ij} = \pi_{ij}^{-1} = N/(m\bar{n})$
  - Self-weighting since each student has the same base weight.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 23 / 85

<!-- page 24 -->

4. Unknown Eligibility

# 4. Unknown Eligibility

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 24 / 85

<!-- page 25 -->

4. Unknown Eligibility

# Unknown Eligibility: Notation

* Frames and samples may contain units whose eligibility cannot be determined.
* Among eligible units, most surveys have nonresponse
* Weight adjustments for unknown eligibility and nonresponse usually made to allow respondents to weight up to the full eligible population.

$s$: initial set of all sample units ($s = s_{UNK} \cup s_{KN}$)
$s_{UNK}$: set of units whose eligibility is unknown
$s_{KN}$: set of units whose eligibility is known ($s_{KN} = s_{IN} \cup s_{E}$)
$s_{IN}$: set of units in $s$ that are known to be ineligible
$s_{E}$: set of units in $s$ that are eligible ($s_{E} = s_{ER} \cup s_{ENR}$)
$s_{ER}$: set of units in $s_{E}$ that are respondents
$s_{ENR}$: set of units in $s_{E}$ that are nonrespondents

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 25 / 85

<!-- page 26 -->

4. Unknown Eligibility

# Examples of Ineligibles

* Survey of current military members, the frame may be June personnel file with a plan to collect data in August.
  * By time the survey is fielded in August, some people will have left the military
  * ”Leavers” are ineligible, assuming target population is all members at the time of data collection.
* Telephone survey of households in which some telephone numbers turn out to be for businesses.
* In household survey of childhood immunizations, households that do not have children are ineligible.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 26 / 85

<!-- page 27 -->

4. Unknown Eligibility

# Examples of Unknown Eligibility

* It may not be possible to determine eligibility for all sample units.
* Cases whose eligibility for a household survey may remain unknown after data collection is finished:
  * Ring/no-answers in a telephone survey
  * Undeliverable addresses in a mail survey
  * Never at home in personal visit survey

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 27 / 85

<!-- page 28 -->

4. Unknown Eligibility

# Handling Unknown Eligibility

- Suppose that the final classification of sample units is
  - Known eligibility status
    - Eligible respondents
    - Eligible nonrespondents
    - Ineligibles
  - Unknown eligibility status
- Ineligible units in sample $\rightarrow$ there are probably other ineligibles in the unknown eligibility part of sample and also in the nonsample.
- Different decisions may be made in different surveys about how the unknowns are handled.
- For example, in an establishment survey done by mail, the unknowns may all be undeliverable addresses, in which case they all might be coded as out-of-business and, thus, ineligible.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 28 / 85

<!-- page 29 -->

4. Unknown Eligibility

# Adjusting for Unknown Eligibility

* Mechanics for adjusting for unknown eligibility usually kept fairly simple.
* One method is to distribute total sample weight of unknowns among those whose eligibility status is known.
* Simple methods usually used
  * Partly because little may be known about the cases with unknown eligibility
  * Partly because nonresponse is considered to be a more serious problem that should receive more attention.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 29 / 85

<!-- page 30 -->

4. Unknown Eligibility

# Steps in Adjusting for Unknown Eligibility - 1

General idea is to make adjustments to the weights of cases with known status:

1. Form $b = 1, \cdots, B$ classes based on frame information known for all cases. Classes may cut across design strata. In practice, eligibility adjustment and nonresponse adjustment classes may be the same.
2. Let $s_b$ be the set of sample units in class $b$, regardless of eligibility or response status, and $s_{b,KN} = s_b \cap s_{KN}$ be the set with known eligibility in class $b$. The symbol $\cap$ identifies the set of units in $s_b$ and in $s_{KN}$ (i.e., the intersection).
3. The unknown eligibility adjustment for sample units in class $b$ is $a_{1b} = \frac{\sum_{i \in s_b} d_{0i}}{\sum_{i \in s_{b,KN}} d_{0i}}$, where $d_{0i}$ is base weight.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 30 / 85

<!-- page 31 -->

4. Unknown Eligibility

# Steps in Adjusting for Unknown Eligibility - 2

4. The unknown eligibility adjusted weight for unit $i$ in $s_{b,KN}$ is $d_{1i} = a_{1b}d_{0i}$.

   The factor $1/a_{1b}$ functions as an estimate of the probability of having known status.

   The weights for the remaining units in class $b$, those with unknown eligibility, are set to zero, i.e., $a_{1b} = 0$ for $s_{b,UNK} = s_b \cup s_{UNK}$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 31 / 85

<!-- page 32 -->

4. Unknown Eligibility

# Example 13.5 Ineligibles in a Telephone Survey

- Telephone survey of the members of a campus student organization is conducted.
- List is somewhat out-of-date so that some phone numbers are incorrect.
- Some persons may have dropped out of school and are ineligible.
- A portion of these ineligibles can be identified; $9.1\%$ of the sample is never contacted so that their eligibility is uncertain.
- A single adjustment class is used

| Category | $\sum_{i \in s_b} d_{0i}$ | Percent dist. | Adjustment | Adj. sum of weights |
| :--- | ---: | ---: | :---: | ---: |
| Eligible respondents ($R$) | 50 | 45.5 | 1.1 | 55 |
| Eligible nonrespondents ($NR$) | 40 | 36.4 | 1.1 | 44 |
| Ineligible ($IN$) | 10 | 9.1 | 1.1 | 11 |
| Unknown eligibility ($UNK$) | 10 | 9.1 | | |
| Total | 110 | | | 110 |

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 32 / 85

<!-- page 33 -->

5. Nonresponse

# 5. Nonresponse

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 33 / 85

<!-- page 34 -->

5. Nonresponse

# Ways of Thinking of Nonresponse

- **Deterministic**: each eligible unit in the population will either respond or not if asked to participate. The choice is not random so that units could be sorted a *priori* into respondents and nonrespondents.
- **Stochastic**: each unit has some non-zero probability of responding. When asked to participate, a unit makes a random choice to cooperate or not.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 34 / 85

<!-- page 35 -->

5. Nonresponse

# Bias with Deterministic Response - 1

* The bias of a simple mean when there is deterministic response is
  $$NR.Bias(\hat{\bar{y}}_r) = M(\bar{Y}_r - \bar{Y}_m)/N \qquad (13.1)$$
  * $\hat{\bar{y}}$: the estimated respondent mean
  * $\bar{Y}_r$: the true mean for the respondent population
  * $\bar{Y}_m$: the true mean for the nonrespondents population
  * $M/N$: population nonresponse rate

* In the deterministic situation, there is a bias if the population mean for the respondents is different from that of the nonrespondents.

* The idea behind the weighting class adjustment method is to try and group units together in such a way that the class means for respondents and nonrespondents are equal, i.e., $\bar{Y}_{c,r} = \bar{Y}_{c,m}$.

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 13 $\qquad$ 35 / 85

<!-- page 36 -->

5. Nonresponse

# Bias with Deterministic Response - 2

* Conditioning on the response pattern exhibited in the sample, NR bias in (13.1) can be estimated using base weights (or base weights adjusted for unknown study eligibility), denoted as $d_i$ , as:

$$\textit{nr.bias}(\hat{\bar{y}}_r) = \bar{m}(\hat{\bar{y}}_r - \hat{\bar{y}}_m) \quad (13.2)$$

  * $\hat{\bar{y}}_r = \sum_{i \in s} r_i d_i y_i / \sum_{i \in s} r_i d_i$: estimated mean of $y$ for the respondent population
  * $r_i = 1$, if the $i^{th}$ sample element is a respondent; $r_i = 0$, otherwise
  * $\hat{\bar{y}}_m = \sum_{i \in s}(1 - r_i)d_i y_i / \sum_{i \in s}(1 - r_i)d_i$: estimated mean of $y$ for the nonrespondent population
  * $\bar{m} = \sum_{i \in s}(1 - r_i)d_i / \sum_{i \in s} d_i$: the weighted nonresponse rate

* Note that the $y$-values are needed for both respondents and nonrespondents to evaluate (13.2). This usually means that frame variables available for all units must be used.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 36 / 85

<!-- page 37 -->

5. Nonresponse

# Bias with Stochastic Response - 1

* Defiine two indicators for being in the sample and responding
$$I_i = \begin{cases} 1 & \text{if unit } i \text{ selected for sample} \\ 0 & \text{if not} \end{cases}$$
$$R_i = \begin{cases} 1 & \text{if unit } i \text{ responds given that it is in the sample} \\ 0 & \text{if unit } i \text{ does not respond} \end{cases}$$
* Probability of being in the sample: $Pr(I_i = 1) = \pi_i$
* Probability of responding given that unit $i$ is in the sample:
  $Pr(R_i = 1 | I_i = 1) = \phi_i$
* Rosenbaum & Rubin (1983) call $\phi_i$ the propensity score for unit $i$
* If $\phi = 0$ for some units, i.e., "hard-core" nonrespondents who would never participate in a survey, this could cause bias.
* If all units have some non-zero probability of responding, then it may be possible to produce estimates that are, in some statistical sense, unbiased.

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 13 $\qquad$ 37 / 85

<!-- page 38 -->

5. Nonresponse

# Bias with Stochastic Response - 2

* Suppose $d_{0i} = 1/\pi_i$ is the base weight for unit $i$ and consider this estimator of a mean:
  $$
  \hat{\bar{y}}_\pi = \sum_{i \in s_R} d_{0i} y_i / \sum_{i \in s_R} d_{0i}
  $$
* Under the "quasi-randomization" setup, where sampling and responding are both considered to be random, bias of $\hat{\bar{y}}_\pi$ is
  $$
  B(\hat{\bar{y}}_\pi) \doteq \frac{1}{N\bar{\phi}} \sum (y_i - \bar{Y}_U)(\phi_i - \bar{\phi}) \quad (13.3)
  $$
  where $\bar{\phi}$ is the average population probability of responding.
* Bias depends on the covariance of the response variable and its response propensity.
* If $y_i$ and $\phi_i$ are unrelated, there is no bias and nonresponse does not need to be corrected, at least when estimating a mean

Sunghee Lee (U of Michigan)
Prac Tools Ch. 13

<!-- page 39 -->

5. Nonresponse 5.1 Nonresponse Mechanism

# 5.1 Nonresponse Mechanism

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 39 / 85

<!-- page 40 -->

5. Nonresponse 5.1 Nonresponse Mechanism

# Adjusting for Nonresponse

- One type of unbiasedness that we could strive for is **design/response-mechanism unbiasedness**.
- Suppose $w_i^*$ is the weight we assign to unit $i$ after nonresponse adjustment and consider this simple estimator of a total:
  $$\hat{t} = \sum_{i \in s_R} w_i^* y_i \text{ where } s_R\text{: set of respondents}$$
- Average of this estimator over sampling and response:
  $$
  \begin{aligned}
  E_R E_I (\hat{t}) &= E_R E_I \left( \sum_{i \in U} R_i I_i w_i^* y_i \right) \\
  &= \sum_{i \in U} w_i^* y_i E_R E_I (R_i I_i)
  \end{aligned}
  $$
- If we can make $w_i^* = 1 / [E_R E_I (R_i I_i)]$, this reduces to the population total, $E_R E_I (\hat{t}) = \sum_{i \in U} y_i$
- Since $E_R E_I (R_i I_i) = E_I [I_i E_R (R_i | I_i)] = \pi_i \phi_i$, the weight would be $w_i^* = (\pi_i \phi_i)^{-1} \rightarrow$ Both $\pi_i$ and $\phi_i$ must be non-zero.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 40 / 85

<!-- page 41 -->

5. Nonresponse 5.1 Nonresponse Mechanism

# Nonresponse Mechanism

- missing completely at random (MCAR); missing at random (MAR); nonignorable nonresponse (NINR) (Little & Rubin, 2002)
- We need to think of a third distribution–one for an analysis variable $y$
- If $K$ analysis variables are collected on each unit, $\mathbf{y}_i = (y_{i1}, y_{i2}, \cdots, y_{iK})$ must be considered.
- Suppose there is a set of auxiliary variables $\mathbf{x}_i = (x_{i1}, x_{i2}, \cdots, x_{ip})$ available for each sample unit whether it responds or not.
- Auxiliaries
  - Age, race, and sex in household surveys
  - Type of business, # of employees in a business establishment survey.
  - Information used in the sample design, like region of the country and type of area (urban, suburban, or rural) or observations reported by interviewers about the condition of a neighborhood ("paradata")

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 41 / 85

<!-- page 42 -->

5. Nonresponse 5.1 Nonresponse Mechanism

# MCAR

* If probability of response $\phi_i$ does not depend on $\mathbf{y}_i$ or $\mathbf{x}_i$, then the missing data are MCAR.
* In the personnel survey in VDK Ch. 2, nonresponse would be MCAR if whether a person responded or not did not depend on business unit, salary grade, tenure, or any of the job satisfaction measures collected in the survey.
* If everyone has the same probability of responding, $\phi$, then any nonrespondents are MCAR.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 42 / 85

<!-- page 43 -->

5. Nonresponse 5.1 Nonresponse Mechanism

# MAR

* If probability of response does not depend on $y_i$ but does depend on some or all of the auxiliaries $\mathbf{x}_i$, then the missing data are MAR.
* A model for response can be formed that depends on $\mathbf{x}_i$, since we know the auxiliaries for both respondents and nonrespondents.
* In the personnel survey, response could depend on salary grade. Lower paid workers might want to sound-off about their complaints and respond at higher rates than others.
* Sometimes called ignorable nonresponse, meaning that if the response mechanism is modeled correctly and adjustments for nonresponse are made, then inferences to the population are possible.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 43 / 85

<!-- page 44 -->

5. Nonresponse 5.1 Nonresponse Mechanism

# NINR

* If the chances of responding depend on one or more analysis variables (i.e., the $y$’s), and this dependence cannot be eliminated by modeling response based on $\mathbf{x}$ that are known for both respondents and nonrespondents, then we have NINR.
* Suppose, in the personnel survey, we can model response as a function of business unit, pay grade, etc. plus an analysis variable that rates whether employees thought there was a clear link between performance rating and pay.
* If the coefficient on the rating variable was significant, this would be evidence of NINR.
* The practical problem with fitting this kind of model is that the rating for the nonrespondents will not be available.
* NINR is difficult or impossible to detect except through a nonresponse follow-up study.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 44 / 85

<!-- page 45 -->

5. Nonresponse 5.2 Weighting Class Adjustments

# 5.2 Weighting Class Adjustments

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 45 / 85

<!-- page 46 -->

5. Nonresponse 5.2 Weighting Class Adjustments

# Creating Weighting Classes for NR Adjustment - 1

* Recall simple bias formula under "quasi-randomization" setup, where sampling and responding are both considered to be random:
$$B(\hat{\bar{y}}_\pi) \doteq \frac{1}{N\bar{\phi}}\sum(y_i - \bar{Y}_U)(\phi_i - \bar{\phi}) \qquad (13.3)$$
* If we can create groups or classes where either all units have about the same probability of response or about the same $y$ values, then NR bias in (13.3) will be approximately eliminated.
* Ideal set of classes will be related to both $y$'s and $\phi$
* Practical difficulty:
  * $y$ variables are not available for nonrespondents.
  * A given set of classes will not be equally effective for all $y$'s
* Consequently, a set of classes is usually identified based on $\phi$'s. If $x$'s used to form the classes are also predictors of $y$, this is a bonus.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 46 / 85

<!-- page 47 -->

5. Nonresponse 5.2 Weighting Class Adjustments

# Creating Weighting Classes for NR Adjustment - 2

* Index classes by $c = 1, \cdots, C$
* If all units in a class have the same covariate values, $x_c$, and response propensity is a function of $x_c$, then $\phi_i = \phi(x_c)$ for all units in $c$.
* $s_c$: set of all sample cases in $c$
* $s_{ER}$: set of eligible respondents
* $s_{ENR}$: set of eligible nonrespondents
* $s_{c,E} = s_c \cap (s_{ER} \cup s_{ENR})$: cases that are known to be eligible in class $c$
* $s_{c,ER} = s_c \cap s_{ER}$: set of eligible respondents in class $c$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 47 / 85

<!-- page 48 -->

5. Nonresponse 5.2 Weighting Class Adjustments

# Weight Adjustments within Classes

* Nonresponse adjustment for units in class $c$ is computed using the unknown-eligibility adjusted weights, $d_{1i}$
$$a_{2c} = \frac{\sum_{i \in s_{c,E}} d_{1i}}{\sum_{i \in s_{c,ER}} d_{1i}}$$
* The adjustment $a_{2c}$ is applied only to the respondents in class $c$.
* The adjustment is set to 0 for the unknowns or known eligible nonrespondents (i.e., $s_{UNK} \cup s_{ENR}$) and to 1 for the cases known to be ineligible ($s_{IN}$).

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 48 / 85

<!-- page 49 -->

5. Nonresponse 5.2 Weighting Class Adjustments

# Weights after Weighting Class NR Adjustment

* The weight for unit $i$ in the initial sample, after the adjustments for unknown eligibility and nonresponse, is
$$
\begin{aligned}
d_{2i} &= \begin{cases}
d_{1i}a_{2c} & i \in s_{c,ER} \\
d_{1i} & i \in s_{IN} \\
0 & i \in s_{UNK} \cup s_{ENR}
\end{cases} \\
&= \begin{cases}
d_{0i}a_{1b}a_{2c} & i \in s_{b,KN} \cap s_{c,ER} \\
d_{0i}a_{1b} & i \in s_{b,KN} \cap s_{IN} \\
0 & i \in s_{UNK} \cup s_{ENR}
\end{cases}
\end{aligned}
$$
* Eligible respondents get both adjustment for unknown eligibility and nonresponse adjustment
* Known ineligibles ($s_{KN} \cap s_{IN}$) get only the unknown eligibility adjustment
* Unknowns ($s_{UNK}$) and eligible nonrespondents ($s_{ENR}$) drop out.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 49 / 85

<!-- page 50 -->

5. Nonresponse 5.2 Weighting Class Adjustments

# Creating Weighting Classes

* $a_{2c}$ adjustment does not necessarily have to use $d_{1i}$ weights.
* Little & Vartivarian (2003) note that if all units in a nonresponse adjustment class have the same response probability, then an unweighted adjustment, $a_{2c} = n_{c,E}/n_{c,ER}$, will be unbiased with respect to the response model and can give more stable NR adjustments.
  – This will be true even if the $d_{1i}$’s vary within each class.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 50 / 85

<!-- page 51 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# 5.3 Propensity Score Adjustments

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 51 / 85

<!-- page 52 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Estimating Propensities - 1

* If $\phi_i = \phi(x_i)$, we can try to model the response probabilities as long as we measure the covariates on all initial sample cases.
* Problems when units are not MAR or MCAR. If $\phi_i = \phi(y_i)$, we do not have $y$'s for nonrespondents ($R = 0$).
  – If the nonrespondents follow a different model from the respondents, we will not know it.
* Another problem case would be $\phi_i = \phi(U_i)$ where $U_i$ contains unmeasured covariates or measured covariates incorrectly omitted from model.
  * For example, response might depend on age, race/ethnicity, and sex but we omit race/ethnicity.
  * Common situation would be that response depends on a covariate that is not measured on either the respondents or the nonrespondents.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 52 / 85

<!-- page 53 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Estimating Propensities - 2

- We may fear that we are operating with inadequate information, but, in practice, model parameters must be estimated based on what is known for both respondents and nonrespondents.
- One approach is to fit a binary regression model for the response indicator, $R_i$. The expected value of the indicator is

$$E_R(R_i|I_i = 1) = Pr(R_i = 1|I_i = 1) = \phi(x_i).$$

  - This is the conditional probability of response given that a unit is selected for the sample.
  - This also has a bearing on whether to use base weights or not in fitting the model, as discussed later in this chapter.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 53 / 85

<!-- page 54 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Response as a Latent Variable Process

* Responding to a survey can be modeled as a realization of a latent variable process. This line of thought provides some motivation for the binary regression models often used to model response to a survey.
* The indicator $R_i$ is the manifest variable (the one we see).
* Suppose that there is a latent variable $R_i^*$, continuous but unobserved.
    * If the value of $R_i^*$ exceeds some threshold (say, bigger than some $\theta$), unit $i$ responds; otherwise, it does not.
    * The latent variable is a unit's "motivation" to participate.
* Other examples that can be modeled as latent variable processes are the decision to re-enlist in the military and the decision to vote for some candidate for political office.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 54 / 85

<!-- page 55 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Figure 13.2: Density of the Latent Variable for Survey Response

To frame this mathematically, suppose that $R_i^*$ is symmetrically distributed. If the unobservable $R_i^*$ exceeds a threshold, then the unit responds; otherwise, it is a nonrespondent.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 55 / 85

<!-- page 56 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Link Function - 1

* Suppose the latent variable follows a linear model, $R_i^* = x_i^T\beta + u_i$, where $u_i$ has distribution function $F$ (not necessarily normal).
* The probability of response, given selection for the sample, is
$$\phi(x_i) = Pr(R_i = 1 | I_i = 1) = Pr(R_i^* > \theta)$$
* Location of the $R_i^*$ distribution is arbitrary, so we can set $\theta = 0$ or think about $R_i^* - \theta$, which has the same variance as $R_i^*$. The response probability can then be written as
$$\begin{aligned}
\phi(x_i) &= Pr(R_i^* > 0) = Pr(x_i^T\beta + u_i > 0) \\
&= Pr(u_i > -x_i^T\beta) \\
&= 1 - F(-x_i^T\beta) = F(x_i^T\beta)
\end{aligned}$$
assuming a symmetric distribution $F$ for $u_i$. Using different $F$ distributions, leads to different binary regression models.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 56 / 85

<!-- page 57 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Link Function - 2

* The link function is a transformation that will turn the probability into a linear function of the covariates, $x_i$.
* The link is determined by $F^{-1}[\phi(x_i)] = x_i^T\beta$ ($\because \phi(x_i) = F(x_i^T\beta)$).
* Thus, the link gives a quantity, $F^{-1}[\phi(x_i)]$, that is modeled as a linear combination of covariates, $x_i^T\beta$.
* The following equation is called a generalized linear model:
$$\begin{aligned} F^{-1}[\phi(x_i)] &= F^{-1}[E_R(R_i|I_i = 1)] \\ &= x_i^T\beta \end{aligned}$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 57 / 85

<!-- page 58 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Alternative Models: Probit Model

- Probability of response is modeled as being equal to the value of the cumulative normal distribution function,
  $$
  \phi(x_i) = \Phi(x_i^T\beta)
  $$
- $\Phi = F$ is standard normal distribution function, i.e., $u_i \sim N(0, 1)$.
- The probit link is $\Phi^{-1}[\phi(x_i)] = x_i^T\beta$, i.e., the inverse Gaussian cumulative distribution function or Gaussian quantile function.
- The link values have a range of $(-\infty, \infty)$ because they are quantiles of the standard normal distribution.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 58 / 85

<!-- page 59 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Alternative Models: Logistic Regression

- Probability of response is $\phi(x_i) = \frac{exp(x_i^T \beta)}{1+exp(x_i^T \beta)}$ and the $F^{-1}$ link is the logit, defined as
$$log \left( \frac{\phi(x_i)}{1 - \phi(x_i)} \right) = x_i^T \beta$$
- Logits have a range of $(-\infty, \infty)$
- The shape of the logistic distribution, $F(u) = \frac{exp(u)}{[1 + exp(u)]}$, is similar to normal distribution but with heavier tails as $u$ ranges over $(-\infty, \infty)$
- The logistic distribution has mean $0$ and variance $\pi^2 / 3$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 59 / 85

<!-- page 60 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Alternative Models: Complementary Log-Log (c-log-log)

* Probability of response is $\phi(x_i) = 1 - exp[-exp(x_i^T \beta)]$. This is also called a log-Weibull distribution.
* The complementary log-log link is
$$log{-}log[1 - \phi(x_i)] = x_i^T \beta$$
* Using this model is equivalent to assuming that the error term in the latent variable model has what is called an "extreme value" distribution:
$$F(u_i) = e^{-e^{u_i}}$$
* The extreme value distribution has mean of about -0.577 (known as Euler's constant) and variance $\pi^2 / 6$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 60 / 85

<!-- page 61 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Comparison of the Distributions

- There are some differences in these distributions, but they are not extreme.
- Figure 13.3 next page shows probabilities on the vertical axis graphed versus standardized links on the horizontal axis.
- The standardized link for each distribution is defined as $[u - E(u)]/\sigma_u$.
- Probit and logit are almost identical while c-log-log has more probability at lower values of the link function.

**See VDK Examples 13.6 and 13.7 in Class9Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 61 / 85

<!-- page 62 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Figure 13.3: Probabilities vs. Standardized links for logit, probit, c-log-log models

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 62 / 85

<!-- page 63 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Estimated Propensities for Nonresponse Adjustment

* Response propensities can be used for nonresponse adjustments either individually or by grouping units into classes. The options are:
  * Propensity weighting: Adjust the weight for an individual responding unit by $1/\hat{\phi}_i$ with $\hat{\phi}_i$ computed from a binary regression.
  * Propensity stratification: Use the $\hat{\phi}_i$'s to create classes and make a common adjustment within each class to all respondents.
* Originate from remedies of observational studies where there may be a "treatment" and a "control" group (e.g., smokers vs. nonsmokers) but no randomization to groups is used. In this case, many differences between the compositions of the groups make inference difficult. Address through adjustments using propensity scores; propensity to be in the treatment group.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 63 / 85

<!-- page 64 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Propensity Stratification—Creating Classes - 1

* Fit binary regression model using covariates available for both respondents and nonrespondents.
  * Ideally, these covariates are related to both the propensity to respond and the $y$'s being measured.
* In practice, the set of available $x$'s can either be extensive or quite limited, depending on the type of survey.
  * In an employee satisfaction survey, you may know pay level, education, type of job.
  * Panel surveys may have data on nonrespondents in later waves if units responded in an early wave.
  * In a telephone survey, almost nothing may be known for the nonrespondents, other than, possibly, the geographic location of the phone number. This is not true in the U.S., where mobile phone users can retain the same phone number wherever they move.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 64 / 85

<!-- page 65 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Propensity Stratification—Creating Classes - 2

The general steps in strata formation are

1. Calculate $\hat{\phi}(x_i)$ for each unit in the sample used for modeling
2. Sort the file by $\hat{\phi}(x_i)$ — low to high
3. Form classes with about same number of initial (respondents + nonrespondents) sample units in each.

* 5 classes usually recommended based on some analyses in Cochran (1968)
* With a large sample, there is no reason not to create more classes. This can help make each more homogeneous on covariates and propensity scores.
* More classes may decrease bias due to nonresponse, but may increase variances by creating bigger spread in the weights.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 65 / 85

<!-- page 66 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Options for Within-Stratum Adjustment

1. $\hat{\phi}_c = \sum_{i \in s_c} \hat{\phi}(x_i)/n_c$, unweighted average estimated propensity where $n_c$ is the unweighted number of cases in class $c$

2. $\hat{\phi}_c = \sum_{i \in s_c} d_i \hat{\phi}(x_i)/\sum_{i \in s_c} d_i$, weighted average estimated propensity; where $d_i$ is the input weight to the NR step and $\sum_{i \in s_c} d_i = \hat{N}_c$, the estimated number of population units in class

3. $\hat{\phi}_c = n_{cR}/n_c$, unweighted response rate where $n_{cR}$ is the unweighted number of respondents in class $c$

4. $\hat{\phi}_c = \sum_{i \in s_{c,R}} d_i / \sum_{i \in s_c} d_i$, weighted estimate of response rate

5. $\hat{\phi}_c = median[\hat{\phi}(x_i)]_{i \in s_c}$, unweighted median estimated propensity

$$
a_{2c} = \frac{1}{\hat{\phi}_c}
$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 66 / 85

<!-- page 67 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Pros & Cons of Options

* If every unit in a stratum has the same probability of responding, i.e., the grouping is very effective, then (3) $\hat{\phi}_c = n_{cR}/n_c$ is best (see Little & Vartivarian, 2003).
* If $\hat{\phi}(x_i)$'s vary within a stratum, (1) or (2) can be used.
* Choice (4), $\hat{\phi}_c = \sum_{i \in s_{c,R}} d_i / \sum_{i \in s_c} d_i$, is an estimate of the population response rate in stratum $c$, assuming MAR.
    * Approximately unbiased with respect to compound sampling/response mechanism or with respect to a model with a common response probability within each class.
    * Can be inefficient if weights vary much within class and units have a common $\phi_i$
* Choice (5), the median, might be considered if response probabilities vary a lot within a class or distribution of estimated probabilities is skewed.
* In many applications, the options will give very similar answers.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 67 / 85

<!-- page 68 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Checking Balance on Covariates - 1

* D'Agostino (1998) gives a simple method for checking covariate balance within the classes formed in propensity stratification.
* After classes are formed, make a check on the extent of differences in the covariate means.
  * The covariate means should be different between the classes
  * Within a class, the means of the covariates should be the same for respondents and nonrespondents. This is consistent with the response propensity being the same for all units within a class.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 68 / 85

<!-- page 69 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Checking Balance on Covariates - 2

Suppose propensity score strata are formed based on quintiles of $\hat{\phi}(x_i)$ giving five strata.

1. Define a variable `p.class` with five values and treat it as a factor, i.e., `p.class <- as.factor(seq(1:5))`.
2. Define the indicator variable `resp`=1 if a unit is a respondent and 0 if an NR.
3. Fit models for the mean of each covariate using `p.class` and `resp` as predictors.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 69 / 85

<!-- page 70 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Checking Balance on Covariates - 3

* For quantitative $x$'s, fit an analysis of variance (ANOVA) model, `x=p.class resp p.class*resp`
* For dichotomous $x$'s, fit a logistic model, `logit(x) = p.class resp p.class*resp`
* Coefficients on `resp` and the interaction term `p.class*resp` should be non-significant if covariate means do not differ for R's and NR's within quintile class.
* Coefficients on `p.class` should be nonzero and different from each other since units with different values of the propensities, and, consequently, the covariates, go into the different classes.
* Another simple, descriptive step is to look at the covariate means in a `p.class*resp` table.

**See VDK Example 13.8 & Numerical Notes in Class9Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 70 / 85

<!-- page 71 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Special Case of Response Propensity Models

Main effect and interactions

* Suppose we have sex (male, female) and race/ethnicity (Hispanic, non-Hispanic White, non-Hispanic Black, non-Hispanic other) $\rightarrow$ $2 \times 4 = 8$ levels or classes;
* Latent variable model defined without an intercept term

$$R_i^* = \alpha_j + \beta_k + (\alpha\beta)_{jk} + u_i$$

  * $\alpha_j$: effect of $j^{th}$ level of sex (male or female)
  * $\beta_k$: effect of $k^{th}$ level of ethnicity (Hispanic, non-Hispanic White, non-Hispanic Black, non-Hispanic other)
  * $(\alpha\beta)_{jk}$: effect for the interaction of sex and ethnicity
  * $u_i$: an error term assumed to have a standard normal distribution, i.e., $u_i \sim N(0, 1)$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 71 / 85

<!-- page 72 -->

5. Nonresponse 5.3 Propensity Score Adjustments

# Main Effects & Interactions Propensity Models

* This is equivalent to a sex $\times$ race/ethnicity class adjustment model
* Suppose logistic regression is used to predict the response probability for a person with sex $j$ and race/ethnicity $k$:

$$\phi(x_i) = exp(\alpha_j + \beta_k + (\alpha\beta)_{jk})/[1 + exp(\alpha_j + \beta_k + (\alpha\beta)_{jk})]$$

* This probability is same for every unit $i$ in each $jk$ combination.
* The estimate of $\phi(x_i)$ is $n_{jk}^R/n_{jk}$ in the unweighted case.
  * Estimated probability for unit $jk$ is proportion of the sample in the class that are respondents, i.e., the unweighted response rate.
  * If survey weights used, we get $\sum_{i \in s_{jk}^R} d_i / \sum_{i \in s_{jk}} d_i$, weighted response rate.
* If appropriate model includes only main effects, this does not reduce to the class model, and the logistic predictions must still be used instead of a weighting class adjustment.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 72 / 85

<!-- page 73 -->

5. Nonresponse 5.4 Weighting Class vs. Propensity Score Adjustments

# 5.4 Weighting Class vs. Propensity Score Adjustments

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 73 / 85

<!-- page 74 -->

5. Nonresponse 5.4 Weighting Class vs. Propensity Score Adjustments

# Pros and Cons - 1

* Which is better?
  * Class adjustment with classes defined by cross-classifications of categorical variables or
  * Propensity modeling with adjustments based on either individual response propensities or classes formed by propensity scores.
* Propensity modeling can be more flexible than class-adjustment for several reasons, including
  * Categorical variables do not have to be completely interacted
  * Continuous $x$'s can be used either by themselves or in combination with categorical variables;
  * Explicit modeling can be done to decide what variables should be included.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 74 / 85

<!-- page 75 -->

5. Nonresponse 5.4 Weighting Class vs. Propensity Score Adjustments

# Pros and Cons - 2

- The modeling may lead to choosing class adjustment if the model includes only main effects for categorical variables and all interactions.
- If little is known about nonrespondents, propensity modeling will not gain much over class adjustment and may be equivalent.
- In household surveys, for example, few person or household-specific items may be available. Neighborhood data may be more common.
- At other extreme, if there are a number of variables available for respondents and nonrespondents, propensity models may give a wide range of estimated probabilities.
- In that case, grouping propensities into classes will lead to less spread in the weight adjustments.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 75 / 85

<!-- page 76 -->

5. Nonresponse 5.4 Weighting Class vs. Propensity Score Adjustments

# Eliminating Nonresponse Bias

* If model fits well, weight adjustments that are inverses of the individual propensities will eliminate bias while class adjustments may not.
* Class adjustment will eliminate bias if all units in the class have the same response probability.
  - But, if each unit has a distinctive response probability, a class adjustment may be too coarse to eliminate bias.
* Bias is evaluated over sampling and response distributions
  - Since the models are usually not trusted completely, using propensity stratification is more common in practice.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 76 / 85

<!-- page 77 -->

5. Nonresponse 5.4 Weighting Class vs. Propensity Score Adjustments

# Computational Point

* A factor and its levels can be simple or elaborate
* A simple factor is sex (male, female)
* The equivalent to crossing two categorical variables would be to create a single variable that could take all values in the cross
    sex with 2 levels (male, female) $\times$
    race/ethnicity with 4 levels (Hispanic, non-Hispanic White, non-Hispanic Black, non-Hispanic other)
    could be coded as a single variable with 8 levels.
* Allows some flexibility for variables that are partially interacted in a model.
    – We might have (sex $\times$ race/ethnicity) and (sex $\times$ education) as two factors in a propensity model.
* Consider the case of sex, race/ethnicity and education as adjustment variables for weighting class vs.propensity score adjustment. How would you handle them under each method?

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 77 / 85

<!-- page 78 -->

5. Nonresponse 5.5 Classification Algorithm

# 5.5 Classification Algorithm

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 78 / 85

<!-- page 79 -->

5. Nonresponse 5.5 Classification Algorithm

# Background

- Goal: Classify units as R or NR based on covariates
- Input: The same data as for propensity modeling
- Product: A tree is formed in which units are grouped based on values of covariates
  - Each group will have a different response rate
- Algorithms:
  - Classification and Regression Trees (CART)
  - Support vector machines
  - Chi-square Automatic Interaction Detection (CHAID)
  - Random Forests

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 79 / 85

<!-- page 80 -->

5. Nonresponse 5.5 Classification Algorithm

# Advantages of CART

Compared to propensity score modeling,

- Interactions of covariates are handled automatically.
- The way in which covariates enter the model does not have to be made explicit.
- Selection of which covariates and associated interactions should be included is done automatically.
- Variable values, whether categorical or continuous, are combined (grouped) automatically.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 80 / 85

<!-- page 81 -->

5. Nonresponse 5.5 Classification Algorithm

# Advantages of Bagging/Random Forests

- Common problem with CART or fitted models generally is that predictions for a new dataset are worse than for dataset used to fit model
- Improvement is to fit many trees by splitting the dataset into subsets and averaging predictions
- Bagging (bootstrap aggregation)
  - Method
    - Select an *srswr* of cases from the full sample
    - Fit a regression tree to each
    - Record results for each tree
    - Average predictions across all of the bootstrap samples
  - Create more stable predictions by averaging across many sets instead of using just one set
  - Reduced variance because an average has smaller variance than a single point

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 81 / 85

<!-- page 82 -->

5. Nonresponse 5.5 Classification Algorithm

# Random Forests

- Instead of using all available covariates for each tree, select a subsample of covariates
  - In datasets where there is one dominant predictor, bagged trees will tend to always split on that predictor first
  - Consequently, predictions from bagged trees will be highly correlated
- By selecting a subset of covariates, random forests "decorrelate" predictions across trees, producing lower variance average predictions
- Refine bagging by making small adjustment that reduces correlation between trees

**See VDK Example 13.9 in Class10Lab.pdf**

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 82 / 85

<!-- page 83 -->

6. Collapsing Classes

# 6. Collapsing Classes

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 83 / 85

<!-- page 84 -->

6. Collapsing Classes

# Collapsing Predefined Classes

* Designers of surveys often have a lengthy list of nonresponse adjustment classes in mind when they develop weighting systems.
* However, using classes with a small number of sample cases will lead to imprecise estimates of response propensities.
* If the sample size in a class is small, the class may be collapsed with an adjacent one.
* Conventional justification for collapsing is that possibility of creating extreme weights is reduced as are variances of estimates.
  – However, a poor choice of the method for collapsing may lead to estimates that are biased.
* Collapsing leads to bias when response rates and class means of the initial classes are correlated within a collapsed class.
* Classes should be collapsed based on similarity of response rates, population class means, or both in order to avoid bias.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 84 / 85

<!-- page 85 -->

6. Collapsing Classes

# Collapsing Predefined Classes: Practical Problems

Two practical issues with collapsing based on class means

1. Theory says collapse based on population means, but in a particular sample we will only have estimates for responding sample.
    * If NR is substantial, means of R and NR parts of sample may be much different, even within initial classes $\rightarrow$ NINR
    * In NINR, adjustment based only on the initial set of classes or combinations of them cannot correct NR bias.

2. Data on many items are collected in most surveys
    * Collapsing based on class means for one variable may not work well for other variables.
    * Little & Vartivarian (2005): collapse based on some weighted average of means of an important set of variables
    * We still only have means for the respondents. Whether and how much means of NRs differ cannot be checked in most surveys.

Sunghee Lee (U of Michigan) Prac Tools Ch. 13 85 / 85
