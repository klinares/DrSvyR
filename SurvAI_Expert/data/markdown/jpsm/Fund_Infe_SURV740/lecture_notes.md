---
id: "jpsm/Fund_Infe_SURV740/lecture_notes"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "lecture_notes"
original: "Fund_Infe_SURV740/lecture_notes.pdf"
pages: 14
sha256: "d2653c99691ca6d2333490db8c2bcc312cb2094c6df18486bfc654a8a4794b8f"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:05"
---

<!-- page 1 -->

Fundamentals of Inference

Introduction to Causal Inference 8/29/25

* Simple cause and effect: One action causes immediate result.
* What if questions are used in causal inference.
    * If company raises prices, what would have happened?
    * It's about the inference of counterfactual.
* Correlation helps predict future
* causation lets us change the future.
* <u>Class is about how to estimate the causal effect quantitatively?</u>
* Individual causal effect $A \rightarrow Y$
    * $A$ can be an intervention ($1=\text{treated}$, $0=\text{not treated}$), $y$ is a potential outcome ($1 = \text{occurred}$, $0=\text{not occurred}$).
        * $Y\_i$ is the actual outcome based on assigned treatment.
    * Assumptions:
        * consistency. Only one version of treatment level for each unit, and has an observed treatmetn at a future time.
* Average causal effect
    * Assume we observe all units in the population of size $N$.
    * The estimate tau is the average of individual effects.
    * Measure of ACE, when to use these depends on RQ.
        * causal risk difference
        * causal relative risk
        * odds ratio
* Assumptions
    * **Consistency**, EPI, also called stable unit treatment values assumption (SUTVA) implies to interference between units.
        * Connecting potential outcome with observed outcome.
    * Ignorability, or **exchangeability** – no matter which assignment the potential outcome is the same.

### Assumptions to Make Connections between associational and causal effect

In order to identify Average Causal Effect:

* Recall: Stable-unit-treatment-value-assumption (**SUTVA**), also called **Consistency** (in Epidemiology):

$$
E(Y^a|A = a) = E(Y|A = a)
$$

* **Ignorability or Unconfoundedness or Exchangeability**

$$
E(Y^a|A = a) = E(Y^a|A \neq a) = E(Y^a)
$$

* If $a=0$, $E(Y^0|A = 0) = E(Y^0|A = 1) = E(Y^0)$: The mean potential outcome under <u>control</u>, $Y^0$, for those in the *control* group ($A=0$) is same as those in the treatment group ($A=1$).

* **Positivity** – has to be between 0 and 1.

<!-- page 2 -->

* DAG – directed and no cycle, causal relationship.
  * Marginal independence, without conditioning
    * If a dag shares a common cause than the effects are marginally dependent. If knowing one cause does not give us information on another cause it is marginally independent.
  * Conditional independence
    * Figure 5 slide 34 are conditional independent, if you remove B, there is no information flow from A to Y.
    * Figure 6, A and Y is independent because L is interrupted.
    * Figure 7, A and Y is dependent.
  * D-separation (dependence) of a path
    * Contains a chain and the middle part of the chain is in C
    * Contains a fork and the middle part of the fork (i.e. the confounder) is in C
    * Contains an inverted fork and the middle part of the fork (i.e. the collider or any descendants of it) is not in C
  * Back door criterion is a way to rule out confounding via conditioning.
    * Blocking means conditioning, restricts analysis to subgroup, to isolate effect.
  * Slide 44

**Randomized experiment 9/5/25**

* Random assignment leads to exchangeability and positivity holds.
* Randomization removes selection bias.
* Average treatment in the treated = ACE.
  * ACE is identified in a randomized experiment.
    * First equal is exchangability assumption, the second = is consistency, which can be estimated with sample data because it = expected observed Y.
      * average y in treated – untreated Y.

$$\text{Therefore, } \text{ACE} = E(Y^1 - Y^0) = E(Y^1 | A = 1) - E(Y^0 | A = 0) =$$

$$E(Y | A = 1) - E(Y | A = 0) \rightarrow \text{ACE is identified, estimated by}$$

$$\frac{1}{n_t} \sum_{i=1}^{n_t} Y_i - \frac{1}{n - n_t} \sum_{i=1}^{n - n_t} Y_i$$

*[Figure: The image contains a handwritten directed acyclic graph (DAG) with no axes, illustrating the causal relationships between five variables: Age, (A) Exercise, Heart Disease (Y), Smoking, and Gene. The main pattern shows directed arrows pointing from Exercise and Gene directly into Heart Disease, while Age and Smoking act as common causes (confounders) with arrows pointing into both Exercise and Heart Disease.]*

<!-- page 3 -->

* Causal risk ratio, it is an estimate if everyone in the sample received treatment vs if all did not receive treatment.
* Observational studies
  * assumptions are guaranteed in randomization, but in observation studies investigators observe intervention.
    * Researchers assume exchangeability holds but it is not guaranteed.
    * Observational study can be seen as a conditional randomized experiment.
      * Conditional on all confounders, we assume that Y is independent from treatment.
    * If we are missing confounders in the study, it will bias estimates in the treated and untreated.
    * The degree of the unbalance will determine the bias.
      * A challenge is to find a statistic appropriate for actual assignment mechanism.

review
$y|A=a$

$Y|A=a$ : actual outcome we observe after the trtment $a$ has been applied.

$Y^{A=a}$ : Potential Outcome if the trtment level $a$ had been applied.

2 Assumptions.
① Consistency
$$Y|A=a = Y^a.$$
$$\underline{\text{obs } Y} = \underline{\text{realized P.O.}} \text{ if trted by observed trtment } a$$

<!-- page 4 -->

② Exchangeability

$$
E(Y^a \mid A = a) = E(Y^a \mid A = a') = E(Y^a)
$$

$$
\iff Y^a \perp A \quad \text{for } \forall a
$$

③ Positivity

$$
0 < P(A = a) < 1
$$

Positive Prob. to be assigned to each of trtment grps $\forall a$.

2. R. E.

* Completely: $Y^a \perp A$ & $0 < P(A = a) < 1$
* Conditional: $Y^a \perp A \mid L$ & $0 < P(A = a) < 1$

$$
\tau = E(Y^1 - Y^0) \stackrel{\text{②,①}}{=} E(Y \mid A = 1) - E(Y \mid A = 0)
$$

$$
\tau = E(Y^1 - Y^0), \quad \text{where}
$$

$$
E(Y^1) = E_L E(Y^1 \mid L) = E \left[ E(Y^1 \mid L, A) \right]
$$

<!-- page 5 -->

$$
E(Y^1) = E_L E(Y^1 | L) = E \left[ E(Y^1 | L, A=1) \right]
$$

$$
= \underset{\substack{\uparrow \\ \text{identifiable !}}}{\underline{E \left[ E(Y | L, A=1) \right]}}
$$

$$
\downarrow
$$

$$
E(Y^0) = E \left[ E(Y | L, A=0) \right]
$$

$$
\Rightarrow \text{Estimation } \begin{cases} \text{Standardization} \\ \text{IPW.} \end{cases}
$$

L is a strata confounder like age.
For this design, we will have conditional strata approach.
Estimation methods – standardization and IPW inverse probability weigting.

3. Observational Studies (No Randomization)

Conditional Exchangeability can only be assumed (No guarantee)

$$
Y^a \perp A \mid \underset{\substack{\uparrow \\ \text{all confounders.}}}{\underset{\sim}{X}}
$$

Question: How to adjust for all $\underset{\sim}{X}$?

① Matching $\begin{cases} d(i, j) \begin{cases} \text{Exact} \\ \text{Eucliean} \end{cases} \end{cases}$

<!-- page 6 -->

* Matching
  * $d(i, j)$
    * Exact
    * Euclidean
    * Mahalanobis
    * P. S
      * $|e(x_i) - \dots|$
      * $|\text{logit } e(x_i) - \dots|$
  * Matching

* Distance metrics
  * euclidean distance, normallized distance sqrt distance of two values.

| | $X_1$ | $X_2$ |
| --- | --- | --- |
| $i$ | $0$ | $0$ |
| $A$ | $5$ | $5$ |
| $B$ | $-4$ | $0$ |

$$\sqrt{\sum_{k=1}^{2} \frac{(X_{ik} - X_{jk})^2}{\hat{\sigma}_k^2}} = \sqrt{\sum_{k=1}^{2} \frac{(0 - 5)^2}{1}}$$

| | $X_1$ | $X_2$ |
| --- | --- | --- |
| $i$ | $0$ | $0$ |
| $B$ | $-4$ | $0$ |

$$D(i, B) = \sqrt{\frac{(0 + 4)^2}{1} + \frac{(0 - 0)^2}{1}} = \sqrt{16} = 4$$

* ICE, difference between average for control and average for matched.

<!-- page 7 -->

**Propensity Score Method 9/12/25**

* Propensity score = probability of receiving treatment given X.
* if propensity score is categorical, it should add up to 1. If continuous, the Cochran approach divide in K strata.
* mahalanobis and euclidean distance for survey matching, difference is the key difference between Mahalanobis and Euclidean distance is that Mahalanobis accounts for the covariance and scale of your survey variables, while Euclidean does not. The choice depends on whether your survey variables are correlated and have different scales.
* Propensity score – reduce dimension of covariates to a scale from 0-1 probability.

Question: How to adjust for all $\underset{\sim}{X}$?

(1) Matching
* $d(i, j)$
  * Exact
  * Euclidean
  * Mahalanobis
  * P.S
    * $|e(x_i) - e(x_j)|$
    * $|\text{logit } e(x_i) - \text{logit } e(x_j)|$
* Matching method
  * greeding
    * smd
  * Optimal

<!-- page 8 -->

### 3. Observational Studies (No Randomization)

Conditional Exchangeability can only be assumed (No guarantee)

$$Y^a \perp A \mid X$$

($X$: all confounders)

Question: How to adjust for all $\underset{\sim}{x}$?
* Matching
  * $d(i, j)$
    * Exact
    * Euclidean

* We assume that conditional exchangability holds.

Question: How to adjust for all $\underset{\sim}{x}$? (all confounders)
* Matching
  * $d(i, j)$
    * Exact
    * Euclidean
    * Mahalanobis
    * P.S
      * $|e(x_i) - e(x_j)|$
      * $|\text{logit } e(x_i) - \text{logit } e(x_j)|$
  * Matching method

* We adjust for x, the confounder, with matching such as a distance measure (euclidean), propensity scores.
* For propensity we can take the logit transformation so linearity can be achieved.

<!-- page 9 -->

* Matching methods, standardized mean difference (SMD) greedy nearest neighbor and optimal methods.

P.S

Matching method

greedy

optimal

smd :

R-implementation

<!-- page 10 -->

Step 1: Matching on $|\text{logit } \hat{e}(x_i) - \text{logit } \hat{e}(x_j)|$

Step 2: Reestimate $\hat{e}_i$ for each of $\sim 6000$ matched sample

Step 3: Form Strata ($K$)

$$K = \begin{cases} 1 \\ 2 \\ \vdots \\ 10. \end{cases}$$

$$\text{Smd}_k = \frac{|\bar{x}_{k,S} - \bar{x}_{k,NS}|}{\sqrt{\frac{S_{k,S}^2 + S_{k,NS}^2}{2}}}$$

$$\text{Smd} = \frac{n_1 \text{Smd}_1 + n_2 \text{Smd}_2}{n_1 + n_2}$$

$K = 10$

Step 4:

*   From Rubins paper 2007, propensity matching with post stratification. Slide 6.

### Inverse PS weighting

*   Pseudo random based trial by rewieghting sample.
*   If conditional exchanagability holds, we can find expected Y value for treated and control conditional on confounder and standardized by population size for the statum.
*   LIE = law of iterative expectation
*   The goal after weighting is to see if the relationship still holds.
*   Stabilized weights give smaller variance. Weighted frequencies give you population size. Both weights give us the same result.
*   Disadvantages
    *   violation of positivity assumption if probability is small.
    *   Small changes to PS model leads to large variances in the weights.

<!-- page 11 -->

**Marginal structural models 9/19/25**

* requires regular assumptions. Has 4 steps.
  * It is marginal because it is not conditional on X, the confounder.
  * We do the weighting first to include confounders, and than model the cause and effect, marginal, which is no longer conditioned on confounders.

control units ($j = 1, 2$). Both covariates are predictive of the outcome of Income (in \$10k).

| | Age (in years) | Edu (=1 if Master+; 0 otherwise) | Income (=\$10k) |
| :--- | :--- | :--- | :--- |
| Treated i=1 | 25 | 1 | 15 |
| Treated i=2 | 30 | 1 | 22 |
| Control j=1 | 30 | 0 | 10 |
| Control j=2 | 40 | 1 | 15 |

The covariance matrix between age and education is given $\Sigma_{AGE,EDU} = \begin{pmatrix} 10 & 0.2 \\ 0.2 & 1 \end{pmatrix}$.

a) (10') Conduct **optimal** matching to find the matched unit $j$ to the treated unit $i$, denoted by $j(i)$, using Mahalanobis distance. Fill in the last column in the table below. (Hint, in R the function "*solve(matrix(c(a,b,c,d),2,2))*" to solve for $\begin{pmatrix} a & b \\ c & d \end{pmatrix}^{-1}$; For matrix multiplication in R, please use "*%\*%*"). Provide computation details.

| Matching Pair | Treated i | Control j(i) |
| :--- | :--- | :--- |
| 1 | $i = 1$ | |
| 2 | $i = 2$ | |

b) (5') Estimate ACE using the matched pair.

Propensity of being treated $e(x)$ for each unit is estimated and provided in the table below.

c) (10') Construct propensity score weights and fill in the last two columns in the table below.

When creating PS weights, the formula is different for treated and untreated.

9/26/25

Time dependent treatments.

<!-- page 12 -->

Step 1: propensity model ($p_1 = pr(A_1 = a | \emptyset); p_2 = pr(A_2 = a | Z = z)$)

$$pr(A_1 = 0 | \emptyset) = \frac{50}{100}; \; pr(A_1 = 1 | \emptyset) = \frac{50}{100};$$

$$pr(A_2 = 0 | Z = 0) = \frac{38}{50}; \; pr(A_2 = 1 | Z = 0) = \frac{12}{50};$$

$$pr(A_2 = 0 | Z = 1) = \frac{12}{50}; \; pr(A_2 = 1 | Z = 1) = \frac{38}{50};$$

Step 2: derive weights: ($w = 1/(p_1 p_2)$)

| N | Z | A1 | A2 | g(A) | Y | w |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 25 | 0 | 0 | 0 | 0 | 1.55 | 2.63 |
| 8 | 0 | 0 | 1 | .5 | 2.55 | 8.33 |
| 4 | 1 | 0 | 0 | 0 | 2.85 | 8.33 |
| 13 | 1 | 0 | 1 | .5 | 3.85 | 2.63 |
| 13 | 0 | 1 | 0 | .5 | 1.65 | 2.63 |
| 4 | 0 | 1 | 1 | 1 | 2.65 | 8.33 |
| 8 | 1 | 1 | 0 | .5 | 2.95 | 8.33 |
| 25 | 1 | 1 | 1 | 1 | 3.95 | 2.63 |

$$\frac{1}{P(A_1=0)P(A_2=0|Z=0)} = \frac{1}{0.5 \cdot \frac{38}{50}} = 2.63$$

11/14/25

Auxiliary variables

* Postsratification - the external information comes from the numerator, population size in the poststrata cell. The denominator is what you estimated in the current example.
  * Why would we want to poststratify. Gain precision by reducing variance in estimate. $S^2$ average deviations. We want between variance large as possible to achieve the largest gains in efficiency.
    * So we want an auxiliary variable to be predictive of the outcome.
  * Another use, reduction in nonresponse bias.

weights that account for unequal probability of s
nt (nr), compute the **poststratification adjustmen**

$$w_{ps,l,i} = \frac{N_l}{\sum_{i=1}^{n_l} (w_{sel,i} \times w_{nr,i})} = \frac{N_l}{\widehat{N}_l}$$

* The equation is for the third column.

<!-- page 13 -->

| Poststratum (age x educ) | Population Proportion | Est. Population Proportion | Poststratification Adjustment | Est. Proportion Supporting R |
| :---: | :---: | :---: | :---: | :---: |
| <= 50, No College | 0.30 | 0.15 | 0.30 / 0.15 = 2.00 | 0.45 |
| <= 50, College | 0.20 | 0.30 | 0.20 / 0.30 = 0.67 | 0.25 |
| > 50, No College | 0.35 | 0.25 | 0.35 / 0.25 = 1.40 | 0.65 |
| > 50, College | 0.15 | 0.30 | 0.15 / 0.30 = 0.50 | 0.35 |

  * The estimate proportion column is unbiased. Are interest is still the population proportion.
  * If we have an unmeasured confounder, this is missing not at random, and poststratification will not fix the bias.
* Raking
  * poststratification assumes information on the joint distribution.
  * Marginal distribution, raking ratio estimation.
  * Known as iterative proportional fitting (IPF) obtains joint distribution from marginal distributions.
  * When does it work?
    * No important interaction, margins are enough.
    * Variable leaves nonresponse bias that a second variable can reduce.
    * Practical convergence.
* Generalized regression estimation (GREG)
  * poststratification and raking combined, known as calibration estimation.
  * The adjustment factor is a function of the calibration variable.
    * We can recover poststratification weights.
* Nonprobability sample analysis
  * two bias in this sampling.
    * Undercoverage – such as opt-in web survey. What is covered is $F\_c$ a subset of $F\_{pc}$ (potentially covered).
      * This hurts positivity assumption
    * selection bias – when some groups more likely to volunteer.

Model Assisted Inference

* Random variable in design based, denoted by $I_i = \{1, 0\}$ unit I subset of S. Population values $y\_i$ are treated as fixed. M
  * hovitz thompson estimator is an example of probability sample.
* Model based requires statistical model, the outcome variable is random following some distribution.
* Model assisted uses design based but incorporates working model to achieve some efficiency.
  * Design based is the weighted sum of the constant y. We only reflect the number of population units.,
  * It is efficient if the model is approximately correct.
  * Example, GREG estimator.
    * GREG weight is $w\_i$ weighted total of sample outcome becomes the GREG estimator.
    * If we use different beta it is still design consistent because of the second derivation, and the first quantity is horvitz thompson which is always design consistent.

<!-- page 14 -->

* Doubly robust – either one of two models should be correct.
* Role of model in design based inference
  * If we are interested in beta, instead of predicting beta for population estimate, analytics statistics when relationships in variables are the main interest.
    * If model is correct and sampling is independent, ignore weights, if not consider the weights.
