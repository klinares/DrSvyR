---
id: "jpsm/Fund_Infe_SURV740/midterm/midterm_study_guide_740"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "SURVMETH 740: Causal Inference Midterm Study Guide"
original: "Fund_Infe_SURV740/midterm/midterm_study_guide_740.qmd"
pages: 
sha256: "e00520d7f6b579a3aa81433bec4bc6689e9b6ec62b0138148026e5fef0578075"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:09"
---


# 1. Fundamentals of Causal Inference

## Core Concepts

### Correlation vs. Causation
- **Correlation**: Relationship between two variables that appear related
- **Causation**: Direct cause-and-effect relationship
- **Key Principle**: "Correlation helps predict the future; causality lets you change the future!"

### Potential Outcomes Framework (Rubin Causal Model)
- **Treatment Indicator**: $A_i = \begin{cases} 1 & \text{if unit i received treatment} \\ 0 & \text{if unit i under control} \end{cases}$
- **Potential Outcomes**: 
  - $Y_i^1$: Potential outcome if treated
  - $Y_i^0$: Potential outcome if untreated
- **Observed Outcome**: $Y_i$ (only one potential outcome observable per person)
- **Fundamental Problem**: We can only observe one potential outcome for each person

### Individual Causal Effect (ICE)
$$\tau_i = Y_i^1 - Y_i^0$$

### Average Causal Effect (ACE)
$$\tau = E[Y^1 - Y^0] = \frac{1}{N}\sum_{i=1}^N[Y_i^1 - Y_i^0]$$

## Critical Assumptions

### 1. SUTVA/Consistency
- **Definition**: No interference between units; one version of each treatment level
- **Mathematical**: If $A_i = a$, then $Y_i = Y_i^a$
- **Meaning**: Observed outcome equals potential outcome under observed treatment

### 2. Exchangeability/Ignorability/Unconfoundedness
- **Definition**: $E(Y^a|A = a) = E(Y^a|A \neq a) = E(Y^a)$
- **Meaning**: Treatment and control groups would have same average outcome if given same treatment
- **Achieved by**: Random assignment in experiments

### 3. Positivity
- **Definition**: $0 < Pr(A = a) < 1$ for all $a$
- **Meaning**: Non-zero probability of receiving each treatment level

## Effect Measures

### Risk Difference (RD) - Additive Scale
$$RD = Pr[Y^{a=1} = 1] - Pr[Y^{a=0} = 1]$$

### Relative Risk (RR) - Multiplicative Scale
$$RR = \frac{Pr[Y^{a=1} = 1]}{Pr[Y^{a=0} = 1]}$$

### Odds Ratio (OR)
$$OR = \frac{Pr[Y^{a=1} = 1]/Pr[Y^{a=1} = 0]}{Pr[Y^{a=0} = 1]/Pr[Y^{a=0} = 0]}$$

### Selection Bias
$$\text{Selection Bias} = E(Y^0|A=1) - E(Y^0|A=0)$$
- Randomization eliminates selection bias

# 2. Directed Acyclic Graphs (DAGs)

## Basic Components
- **Nodes**: Variables in causal model
- **Directed edges (arrows)**: Possible causal effects
- **No cycles**: Variable cannot cause itself

## Path Types

### 1. Chain
```
A → B → Y
```
- A affects Y through mediator B
- Conditioning on B blocks the path

### 2. Fork (Common Cause/Confounder)
```
A ← L → Y
```
- L is a confounder
- Conditioning on L blocks the path

### 3. Inverted Fork (Collider)
```
A → L ← Y
```
- L is a collider
- Conditioning on L OPENS the path (creates spurious association)

## Independence Rules

### Marginal Independence
Two variables are marginally independent if:
- They don't cause each other
- They don't share common causes
- They may share common effects (still independent)

### Conditional Independence
- **Chains**: Condition on middle variable to block
- **Forks**: Condition on confounder to block
- **Colliders**: DO NOT condition (conditioning opens path)

## d-Separation Rules
A path is blocked by conditioning set C if:
1. Contains chain with middle part in C
2. Contains fork with confounder in C
3. Contains collider NOT in C (and no descendants in C)

## Pearl's Back-door Criterion
For identifying causal effect of X on Y:
1. Conditioning set C must NOT include descendants of X
2. Conditioning set C must block all back-door paths from X to Y

**Back-door path**: Path from X to Y that starts with arrow INTO X

# 3. Randomized Experiments

## Types of Randomization

### Completely Randomized Experiment
- Randomly select $n_1$ from $n$ units for treatment
- Equal selection probability: $n_1/n$
- Exchangeability holds: $A \perp (Y^0, Y^1)$
- ACE identified: $\hat{\tau} = \frac{1}{n_1}\sum Y_i - \frac{1}{n-n_1}\sum Y_i$

### Stratified/Conditional Randomized Experiment
- Form blocks based on covariates L
- Randomize within blocks
- Conditional exchangeability: $A \perp (Y^0, Y^1)|L$

### Pair Randomized Experiment
- Special case: blocks of size 2
- One unit per pair receives treatment

## Advantages & Disadvantages

**Advantages**:
- Strongest evidence for causality
- Internal validity
- Controls confounding

**Disadvantages**:
- Ethical issues
- Cost and feasibility
- External validity concerns

# 4. Observational Studies

## Key Concept
- Treatment not randomly assigned
- Must assume conditional exchangeability given observed covariates
- Risk of unmeasured confounding

## Estimation Methods

### Method 1: Standardization
$$E(Y^a) = \sum_l E(Y|A=a, L=l) \times Pr(L=l)$$

**Steps**:
1. Estimate stratum-specific effects
2. Weight by population distribution of L
3. Sum across strata

### Method 2: Inverse Probability Weighting (IPW)
$$w_i = \begin{cases} \frac{1}{e(X_i)} & \text{if } A_i = 1 \\ \frac{1}{1-e(X_i)} & \text{if } A_i = 0 \end{cases}$$

Where $e(X_i) = Pr(A=1|X_i)$ is propensity score

**Stabilized weights**: $w_i^s = w_i \times Pr(A_i = a)$
- Reduces variance
- Same balance properties

**IPW Estimator**:
$$\hat{\tau} = \frac{\sum w_i A_i Y_i}{\sum w_i A_i} - \frac{\sum w_i(1-A_i)Y_i}{\sum w_i(1-A_i)}$$

# 5. Matching Methods

## Distance Metrics

### 1. Exact Distance
$$d(i,j) = \begin{cases} 0 & \text{if } x_i = x_j \\ \infty & \text{if } x_i \neq x_j \end{cases}$$

### 2. Euclidean Distance
$$d(i,j) = \sqrt{\sum_{k=1}^K \frac{(x_{ik} - x_{jk})^2}{\sigma_k^2}}$$

### 3. Mahalanobis Distance
$$d(i,j) = \sqrt{(x_i - x_j)^T\Sigma^{-1}(x_i - x_j)}$$
- Accounts for covariance between variables
- Better for correlated covariates

### 4. Propensity Score Distance
$$d(i,j) = |e(X_i) - e(X_j)|$$
or
$$d(i,j) = |logit(e(X_i)) - logit(e(X_j))|$$

## Matching Algorithms

### Nearest Neighbor (NN) Matching
- Match each treated to closest control
- With/without replacement
- Order matters without replacement

### Optimal Matching
- Minimizes total distance across all matches

## Balance Assessment

### Standardized Mean Difference (SMD)
$$SMD = \frac{\bar{X}_{treated} - \bar{X}_{control}}{\sqrt{(s^2_{treated} + s^2_{control})/2}}$$

**Rules of thumb**:
- SMD < 0.1: adequate balance
- SMD 0.1-0.2: not too alarming
- SMD > 0.2: serious imbalance

## ACE Estimation After Matching
$$\hat{ACE} = \frac{1}{n}\sum_{i=1}^n(y_i - y_{j(i)})$$

# 6. Propensity Score Methods

## Propensity Score Definition
$$e(X) = Pr(A = 1|X)$$

## Key Properties

### Balance Property
$$X \perp A | e(X)$$
Among units with same PS, X is balanced between treated/control

### Dimension Reduction
Reduces matching from p-dimensional X to 1-dimensional e(X)

## PS Methods

### 1. PS Matching
- Use PS as distance metric
- 1:1 or 1:k matching
- With/without caliper (e.g., 0.2 SD)

### 2. PS Stratification
- Divide PS into strata (e.g., quintiles)
- Estimate effect within strata
- Average across strata:
$$\hat{\tau} = \sum_{k=1}^K \tau_k \times Pr(B_k = 1)$$

### 3. PS Weighting (Same as IPW)
- Weight by inverse of PS
- Creates pseudo-population with balanced covariates

# 7. Marginal Structural Models (MSM)

## Definition
Models marginal expectations of potential outcomes:
$$E(Y^a|V) = q(a, V)$$

Example: $E(Y^a|V) = expit(a\beta_1 + V\beta_2)$

## 4-Step Procedure

1. **Model treatment assignment**: $Pr(A = a|X)$
2. **Derive weights**: $w = 1/Pr(A = a|X)$
3. **Create pseudo-population**: Weights remove X-A association
4. **Estimate MSM parameters**: Weighted regression

## Time-Dependent Treatment
- Handles treatment that varies over time
- Addresses time-varying confounding
- Uses cumulative weights: $w = 1/(p_1 \times p_2)$

## MSM vs PS Weighting
**Similarities**:
- Both use propensity score weights
- Both create balance

**Differences**:
- MSM models potential outcomes explicitly
- MSM more flexible for complex treatments

# 8. Principal Stratification

## Core Concept
Define strata by potential values of intermediate variable

## Four Principal Strata (Binary Case)
For Z→A→Y:
1. **Never-takers (NT)**: $A^{Z=0} = 0, A^{Z=1} = 0$
2. **Always-takers (AT)**: $A^{Z=0} = 1, A^{Z=1} = 1$
3. **Compliers (C)**: $A^{Z=0} = 0, A^{Z=1} = 1$
4. **Defiers (D)**: $A^{Z=0} = 1, A^{Z=1} = 0$

## Key Features
- Principal strata are latent (unobserved)
- Membership is pre-treatment characteristic
- Can only compare within strata

## Key Assumptions

### Monotonicity (No Defiers)
$$A^{Z=1} \geq A^{Z=0}$$
- Rules out defiers
- Makes strata proportions identifiable

### Exclusion Restriction
$$Y^{(z,a)} = Y^{(z',a)} \text{ for all } z, z', a$$
- Z affects Y only through A
- For AT and NT: $PCE_{AT} = PCE_{NT} = 0$

## Principal Causal Effects (PCE)
$$PCE_s = E[Y^1_s] - E[Y^0_s]$$
Only meaningful for compliers when outcome defined

# 9. Instrumental Variables (IV)

## Definition
Variable Z that:
1. Affects treatment A
2. Does not directly affect outcome Y
3. Affects Y only through A

## IV Estimator (CACE)
$$CACE = \frac{E(Y|Z=1) - E(Y|Z=0)}{E(A|Z=1) - E(A|Z=0)}$$

**Interpretation**:
- Numerator: Effect of Z on Y
- Denominator: Effect of Z on A (proportion of compliers)
- Ratio: Complier Average Causal Effect

## Connection to Principal Stratification
Under monotonicity and exclusion restriction:
$$CACE = PCE_{compliers}$$

# 10. Key Formulas Quick Reference

## Observed vs Potential Outcomes
- $E(Y|A=1) - E(Y|A=0) = ATT + \text{Selection Bias}$
- Under randomization: Selection Bias = 0

## Weights
- **IPW**: $w_i = 1/Pr(A_i|X_i)$
- **Stabilized**: $w_i^s = w_i \times Pr(A_i)$
- **MSM time-varying**: $w = 1/(p_1 \times p_2 \times ... \times p_t)$

## Balance Check
- **SMD**: $\frac{\bar{X}_1 - \bar{X}_0}{\sqrt{(s_1^2 + s_0^2)/2}}$
- Target: |SMD| < 0.1

## Causal Effects Under Assumptions
- **Randomization**: $\hat{\tau} = \bar{Y}_1 - \bar{Y}_0$
- **Conditional exchangeability**: Use standardization or IPW
- **IV/Monotonicity**: $CACE = \frac{\Delta Y}{\Delta A}$

# 11. Common Exam Scenarios

## When to Use Each Method

### Use Randomization When:
- Treatment randomly assigned
- No selection into treatment

### Use Matching When:
- Few confounders
- Good overlap in covariates
- Want matched pairs for analysis

### Use Propensity Scores When:
- Many confounders
- Dimension reduction needed
- Good overlap in PS

### Use IPW/MSM When:
- Time-varying treatment
- Marginal effects needed
- Complex confounding

### Use Principal Stratification When:
- Post-treatment variable of interest
- Truncation by death
- Non-compliance

### Use IV When:
- Unmeasured confounding suspected
- Natural experiment available
- Interest in complier effects

## Common Pitfalls to Avoid

1. **Never condition on post-treatment variables** (except in principal stratification)
2. **Check positivity** - avoid extreme weights
3. **Assess balance** after matching/weighting
4. **Don't condition on colliders** in DAGs
5. **Remember fundamental problem** - can't observe both potential outcomes

## Key Distinctions

- **E(Y^0) vs E(Y|A=0)**: Potential outcome for all vs observed outcome for untreated
- **E(Y^1|A=1) vs E(Y^1|A=0)**: ATT component vs selection bias component
- **Marginal vs Conditional**: Population average vs stratum-specific
- **ATE vs ATT vs CACE**: All units vs treated only vs compliers only
