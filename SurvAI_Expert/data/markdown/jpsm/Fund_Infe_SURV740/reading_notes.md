---
id: "jpsm/Fund_Infe_SURV740/reading_notes"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "reading_notes"
original: "Fund_Infe_SURV740/reading_notes.pdf"
pages: 14
sha256: "0667bec6617400f65fce56fcba4a1efb37c35d4d6d968350425678763d5f2aa8"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:04"
---

<!-- page 1 -->

**Hernán M.A., Robins J.M. (2017). Causal Inference. Boca Raton: Chapman & Hall/CRC, forthcoming. Preprint available at http://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/. Last accessed Jan. 29, 2018 (Chapters 1-2)**

## Chapter Overview

These chapters introduce fundamental concepts for causal inference through randomized experiments, focusing on how to estimate causal effects when randomization is conditional on certain variables. The text uses a hypothetical heart transplant study as a running example, where treatment assignment depends on patients' critical condition status.

## Key Concepts in Randomization and Exchangeability

The chapters establish that in randomized experiments, **exchangeability** between treated and untreated groups allows researchers to interpret observed associations as causal effects. When randomization is unconditional, the treated and untreated are directly exchangeable, making the associational risk ratio equal to the causal risk ratio. However, many real experiments involve conditional randomization, where treatment probability varies based on certain characteristics (like critical condition status in the heart transplant example). In these cases, conditional exchangeability holds within strata of the conditioning variable, but marginal exchangeability may not hold in the overall population.

An important distinction emerges between marginal and conditional randomization. While marginal randomization ensures that treatment groups are balanced overall, conditional randomization creates balance within specific subgroups but may result in imbalance in the aggregate population. This distinction becomes crucial when computing population-level causal effects from conditionally randomized experiments.

## Standardization Method

Standardization provides a method to compute marginal causal effects from conditionally randomized experiments. The approach works by calculating stratum-specific risks within each level of the conditioning variable, then combining these risks using weights proportional to the size of each stratum in the population. Under conditional exchangeability, the counterfactual risk for a given treatment level equals a weighted average of the observed risks in each stratum among those who actually received that treatment.

The mathematical formulation shows that the marginal counterfactual risk $\Pr[Y^a = 1]$ equals the sum over all strata of $\Pr[Y = 1 | L = l, A = a] \times \Pr[L = l]$, where $L$ represents the conditioning variable. This method effectively answers the question: "What would happen if everyone in the population received treatment $a$?" by leveraging the conditional exchangeability within each stratum. The standardized risks can then be used to compute causal risk ratios or risk differences.

<!-- page 2 -->

## Inverse Probability Weighting

Inverse probability (IP) weighting offers an alternative approach that creates a pseudo-population where treatment is independent of the conditioning variables. Each individual receives a weight equal to the inverse of their probability of receiving their actual treatment, given their covariate values. For instance, if someone with characteristics $L$ had a $0.75$ probability of being treated and was indeed treated, they would receive a weight of $1/0.75 = 1.33$.

The method effectively creates a hypothetical population where every individual appears twice - once as treated and once as untreated. In this pseudo-population, the conditioning variable $L$ becomes independent of treatment $A$, allowing the associational risk ratio in the pseudo-population to equal the causal risk ratio in the original population. The IP weights are formally defined as $W^A = 1/f[A|L]$, where $f[A|L]$ represents the conditional probability density of treatment given covariates.

## Mathematical Equivalence and Practical Considerations

A crucial insight is that standardization and IP weighting are mathematically equivalent under the positivity condition (that all individuals have a non-zero probability of receiving each treatment level). Both methods "adjust for" or "control for" the conditioning variable $L$, though this analytical control differs fundamentally from the physical control achieved through randomization. The equivalence proof demonstrates that both the standardized mean and the IP weighted mean equal the counterfactual mean $E[Y^a]$ under conditional exchangeability and positivity.

The text emphasizes important practical considerations, particularly regarding risk periods. The causal effect of a treatment on mortality, for example, depends critically on the time frame considered - a treatment might show a strong protective effect at one year but no effect at 100 years (when everyone has died). This highlights that treatments delay rather than prevent death, making the specification of the risk period essential for meaningful interpretation.

## Limitations and Real-World Applications

The chapters conclude by acknowledging that while randomized experiments provide the gold standard for causal inference, they often face ethical, practical, or temporal constraints. The heart transplant example illustrates these challenges: random allocation of scarce organs raises ethical concerns, double-blinding is impossible, and participants may not comply with their assigned treatment. Additionally, the time required to complete such studies may be prohibitive when urgent decisions are needed. These limitations often make observational studies the only feasible option, despite their additional complexities for causal inference.

The framework presented in these chapters - using either standardization or IP weighting to handle conditional randomization - provides the foundation for understanding how these same methods can be applied to observational data under additional assumptions, which subsequent chapters presumably address.

<!-- page 3 -->

**Jackson, M., Cox D.R. (2013). The principles of experimental design and their application in sociology, Annual Review of Sociology, 39:27–49.**

## Core Concepts from the Causal Inference Text

**Exchangeability** is the fundamental assumption that allows causal interpretation. In randomized experiments, treated and untreated groups are exchangeable - any differences in outcomes can be attributed to treatment rather than pre-existing differences. When randomization is conditional on some variable L (like critical condition status in the heart transplant example), we have conditional exchangeability within strata of L.

**Two key methods for handling conditional randomization:**

1. **Standardization** - Calculate stratum-specific risks, then take a weighted average using the population distribution of L as weights. This answers "what would happen if everyone received treatment?"
2. **Inverse Probability (IP) Weighting** - Create a pseudo-population where each person is weighted by 1/(probability of receiving their actual treatment). This makes treatment independent of L in the weighted population.

These methods are mathematically equivalent under the positivity condition (everyone has a non-zero probability of receiving each treatment level).

## Key Points from the Jackson & Cox Article

The article provides a comprehensive framework for experimental design in sociology, emphasizing four fundamental principles from Fisher:

1. **Eliminate systematic errors** through randomization at every stage where variability might enter
2. **Enhance precision** by comparing like with like (blocking)
3. **Enable replication** for reliability assessment
4. **Use factorial designs** to efficiently test multiple factors and their interactions

The authors distinguish three types of experiments in social science:

* **Laboratory experiments** offer high internal validity but face external validity challenges
* **Field experiments** provide better external validity but less control
* **Survey experiments** can achieve both representative samples and controlled treatments

## Main Takeaway

Both documents emphasize that experimental design is about more than just random assignment. The key insight is that proper causal inference requires careful attention to:

* How randomization is implemented (marginal vs. conditional)

<!-- page 4 -->

* How to properly analyze data when randomization is conditional
* The trade-offs between internal validity (can we identify causal effects?) and external validity (do findings generalize?)

The Jackson & Cox article particularly stresses that experimental methods should be integrated with theory and subject to replication - a single experiment rarely provides definitive evidence. They also note the concerning lack of replication in social sciences and the disciplinary boundaries that limit cumulative knowledge building.

The technical material on standardization and IP weighting is crucial for understanding how to properly analyze experiments where treatment assignment probabilities vary across subgroups - a common situation in real-world studies where simple randomization isn't feasible or ethical.

<!-- page 5 -->

**Rubin, D.B. (2007). The Design versus the analysis of observation studies for causal effects: Parallels with the design of randomized trials. Statistics in Medicine, 26, 20-36.**

This 2007 article by Donald Rubin advocates for designing observational studies to closely approximate randomized experiments, emphasizing the critical importance of the design phase over analysis methods.

## Key Points:

**Core Argument:**

* Observational studies should be conceptualized as "broken randomized experiments" where the assignment mechanism has been lost and must be reconstructed
* Design phase must occur without access to outcome data to maintain objectivity
* The design of observational studies deserves at least as much attention as the analysis phase ("design trumps analysis")

**The Rubin Causal Model Framework:**

1. **Potential outcomes:** Define causal effects as comparisons between what would happen under different treatments for the same units
2. **Assignment mechanism:** The process determining which units receive which treatment - critical for valid causal inference
3. **Bayesian inference** (optional): Model for the science to enable posterior inference

**Propensity Score Methods:**

* Propensity scores (probability of receiving treatment given covariates) are central to creating balanced comparison groups
* Within subgroups with similar propensity scores, treated and control units should have similar covariate distributions
* These methods can eliminate bias from observed covariates but not unobserved ones

**Tobacco Litigation Example:**

* Demonstrated matching male current smokers to "similar" never-smokers using NMES data
* Initial imbalance was too large for reliable regression adjustment
* Through iterative matching and subclassification on propensity scores, achieved excellent balance
* Created 10 subclasses with nearly identical covariate distributions between groups

**Critique of Common Practice:**

* Most observational studies repeatedly analyze outcome data looking for publishable results
* This "data mining" approach undermines objectivity and inflates false discovery rates
* Parallel drawn to drug approval: Would you trust a drug approved based on cherry-picked analyses?

<!-- page 6 -->

**Key Recommendations:**

* Conduct all covariate balancing and design decisions before examining outcomes
* Pre-specify the primary analysis plan
* Use diagnostics to assess covariate balance (e.g., standardized differences, variance ratios)
* Consider discarding control units with no comparable treated units rather than relying on model extrapolation

The article emphasizes that objective observational study design, while more challenging than in randomized experiments, is both possible and essential for credible causal inference.

<!-- page 7 -->

**Hernán M.A., Robins J.M. (2017). Causal Inference. Boca Raton: Chapman & Hall/CRC, forthcoming. Preprint available at http://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/. Last accessed Jan. 29, 2018 (Chapters 1-2)**

This document discusses key concepts in causal inference, particularly focusing on the consistency assumption and the target trial framework for observational studies.

## Key Points:

**Consistency Assumption:**

* Consists of two components: (1) well-defined counterfactual outcomes $Y^a$ with no meaningful vagueness, and (2) linkage between counterfactuals and observed outcomes ($Y^a = Y$ for individuals with $A = a$)
* Requires interventions to be sufficiently well-defined, meaning experts agree no meaningful vagueness remains for practical purposes
* What counts as "sufficiently well-defined" depends on available knowledge and expert consensus at a given time

**Challenges with States and Factors:**

* Biological states (blood pressure, weight) or social factors (socioeconomic status) cannot be directly intervened upon - only changed through interventions on their causes
* This creates problems for defining causal effects of obesity, blood pressure, etc.
* One resolution: interpret statements like "blood pressure causes stroke" as implying existence of interventions $D$ that affect blood pressure $A$ but have no direct effect on outcome $Y$ except through $A$

**The Target Trial Framework:**

* When using observational data for causal inference, researchers should specify the hypothetical randomized experiment (target trial) they wish to emulate
* Key protocol components: eligibility criteria, interventions, assignment procedures, outcomes, follow-up period, and causal contrasts
* Makes causal questions precise and actionable for decision-makers
* Helps identify when implied interventions are unrealistic or impossible

**Practical Implications:**

* In observational studies, the choice of interventions depends on available data
* Just because a variable is measured doesn't mean its causal effect is meaningful
* When interventions are ill-defined, options include:
  * Shifting from causal inference to prediction/association
  * Working to make interventions less ill-defined through careful specification
  * Acknowledging limitations while being as precise as possible about timing and magnitude

**Attributable Fraction:**

<!-- page 8 -->

* Compares observed risk with counterfactual risk to determine proportion of cases attributable to treatment
* Excess fraction $= [\Pr(Y=1) - \Pr(Y^{a=0}=1)] / \Pr(Y=1)$
* Different from etiologic fraction (proportion mechanistically caused by exposure)

The document emphasizes that transparency about consistency assumptions and explicit specification of target trials can prevent investigators from making unrealistic causal claims and help produce more credible causal inferences from observational data.

<!-- page 9 -->

D'Agostino, R. B., Jr. (1998). Propensity score methods for bias reduction in the comparison of a treatment to a non-randomized control group. *Statistics in Medicine*, 17(19), 2265-2281.

Definition and theoretical basis of propensity scores

* Three main implementation methods: matching, stratification, and regression adjustment
* Practical examples including March of Dimes study and ACT trial
* Balance diagnostics and assessment methods
* Variance estimation considerations
* SAS code examples in appendix

<!-- page 10 -->

Joffe, M.M. Ten Have, T.R., Feldman, H.I., Kimmel, S.E. (2004). model selection, confounder control, and marginal structural models, The American Statistician, 58:272-279.

**2. Cause of the Error:** The primary error source is **confounding bias** that occurs when using traditional regression approaches. The error arises because:

* Traditional regression requires including confounding variables in the structural part of the model to control for them
* This creates problems when confounders are nuisance variables of little interest
* In multicenter studies, cluster/center effects can confound treatment effects
* Standard approaches (GEE, mixed effects models) may not appropriately control for confounding by cluster
* The observed treatment effect estimates can represent different combinations of within-center effects and between-center associations rather than true causal effects

**3. Techniques to Reduce Error in Practice:** The paper presents **Marginal Structural Models (MSMs)** with weighted estimation:

* **Weighting approach:** Use inverse probability of treatment weights (IPTW) based on propensity scores
* **Four-step process:** (1) Model treatment assignment probability, (2) Derive weights, (3) Create artificial population where covariates aren't associated with treatment, (4) Estimate MSM parameters using weighted methods
* **Separation principle:** Allows separation of model selection from confounder control, keeping nuisance variables out of the structural model while still controlling for confounding

**4. Statistical Models to Measure Error:**

* **Propensity score models:** Logistic regression to model $\text{Pr}(A=1|X) = \text{expit}(X\beta)$
* **Inverse probability weights:** $w = A/p + (1-A)/(1-p)$ where $p$ is propensity score
* **Weighted generalized estimating equations:** For clustered data with working independence correlation matrix
* **Robust variance estimators:** Using estimating equation methods for proper variance estimation

**5. Error Reduction Guidance:** Yes, the paper provides comprehensive guidance. MSMs allow more flexibility in covariate selection for the structural model since confounding control is achieved through weighting rather than model inclusion. The approach is particularly useful for multicenter studies where conditional inference methods may be impractical. However, the method has limitations: assumptions like strong ignorability must hold, estimated probabilities near 0 or 1 can cause instability, and treatment must be discrete. The paper emphasizes that MSMs provide a useful addition to standard regression methods, particularly when nuisance variables would otherwise clutter the structural model.

<!-- page 11 -->

**Rubin, D.B. (2006). Causal inference through potential outcomes and principal stratification: Application to studies with “censoring” due to death, Statistical Science, 21: 299-309.**

**What is the cause of the error?** The fundamental source of error in this paper is **truncation or censoring due to death** (or other intermediate outcomes) that occurs between treatment assignment and measurement of the primary outcome. When studying quality of life (QOL) at 2 years post-randomization, some patients die before this endpoint can be measured, creating undefined outcomes rather than missing data.

The key insight is that death creates **principal strata** - subgroups defined by their survival status under both treatment conditions: LL (live under both), DD (die under both), LD (live if treated, die if control), and DL (die if treated, live if control). The error arises because we cannot directly observe which stratum individuals belong to - we only see their outcome under their actual treatment assignment. Simply comparing QOL among survivors in treatment vs. control groups produces biased estimates because these groups contain different mixtures of principal strata.

**What techniques can be used to reduce the error in practice?** Rubin identifies several practical approaches:

* **Collect predictive covariates:** The most successful approach is gathering baseline covariates that predict both survival and QOL outcomes. In the AMGEN example, baseline forced vital capacity (FVC) measurements and deterioration rates were highly predictive of both outcomes, enabling better stratification.
* **Use distributional information:** When outcomes follow known distributions (e.g., normal), mixture modeling techniques can help disentangle the principal strata even when they cannot be directly observed.
* **Apply bounds under assumptions:** When certain assumptions hold (monotonicity, stochastic dominance), researchers can establish bounds on causal effects even without point identification.

**What statistical models can be used to measure the error source?** The paper discusses several modeling approaches:

* **Principal stratification framework:** The core model that explicitly defines causal effects within survival strata
* **Mixture models** using EM algorithm or MCMC methods when distributional assumptions are reasonable
* **Sensitivity analyses** to assess how results change under different assumptions about the unobservable joint distribution of potential outcomes
* **Large-sample bounds** derived under various assumptions (though these proved less useful in the extreme example presented)

**Does it tell me how to reduce the error?** The paper provides concrete guidance. The primary recommendation is to **proactively collect baseline covariates** that predict both intermediate and final outcomes before randomization. This was successfully implemented in the actual AMGEN trial. Additionally, researchers should:

<!-- page 12 -->

* Consider the distributional properties of their outcomes to enable mixture modeling
* Be transparent about untestable assumptions
* Avoid inappropriate methods like simple imputation or treating death as "missing data"
* Use sensitivity analyses to understand the robustness of conclusions

The paper emphasizes that proper conceptual framing using potential outcomes is essential before attempting any mathematical analysis - as Picasso said, "computers are worthless; they only give answers."

<!-- page 13 -->

*[No text on this page]*

<!-- page 14 -->

Stuart, E. A. (2010). Matching methods for causal inference: A review and a look forward. *Statistical Science*, *25*(1), 1-21.

**Comprehensive review including:**

* Various distance measures (exact, Mahalanobis, propensity score)
* Matching methods spectrum (nearest neighbor, optimal, full matching, weighting)
* Diagnostic approaches for assessing match quality
* Outcome analysis strategies after matching
* Software implementations across R, Stata, and SAS
* Practical guidance for method selection based on estimand of interest (ATE vs ATT)
