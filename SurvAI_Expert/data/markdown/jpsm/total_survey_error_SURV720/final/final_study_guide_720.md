---
id: "jpsm/total_survey_error_SURV720/final/final_study_guide_720"
source: "jpsm"
course: "SURV720"
course_title: "Total Survey Error and Data Quality I"
doc_type: "assignment"
title: "SURVMETH 720 - Final Study Guide"
original: "total_survey_error_SURV720/final/final_study_guide_720.qmd"
pages: 
sha256: "59f7c68aba41ba3fba29189ca0f4d78fbc5521b7934397d20469e55df91b0bef"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:24"
---


# Foundational Concepts

## The Population Cascade

Understanding survey error begins with clarifying what population is being discussed:

1. **Inferential Population**: The broad, conceptual group to which a researcher wishes to generalize (e.g., "all homeless youth in the U.S.")

2. **Target Population**: The specific, operational set defined by content, units, extent, and time (e.g., "homeless youth in Maryland aged 16-19 during 2024")

3. **Frame Population**: Members with a chance of selection because they are on the sampling frame

4. **Survey Population**: Frame members who are ultimately accessible and could become respondents

## Mean Squared Error (MSE)

The mathematical core of survey accuracy:

$$MSE = Bias^2 + Variance$$

- **Bias**: Systematic, non-compensating errors that push estimates in one direction (errors that "tend to agree")
- **Variance**: Random, compensating errors creating spread around an expected value (errors that "tend to disagree")
- **Key Insight**: MSE cannot be zero even in a census due to nonsampling errors

## Total Survey Error Framework

TSE deconstructs the survey process to identify all error sources with two main arms:

### Representation Arm (the "who")

Errors from discrepancies between target population and final respondents:

$$\text{Target Pop} \rightarrow \text{Coverage Error} \rightarrow \text{Frame} \rightarrow \text{Sampling Error} \rightarrow \text{Sample} \rightarrow \text{Nonresponse Error} \rightarrow \text{Respondents}$$

### Measurement Arm (the "what")

Errors from deviation between true values and recorded data:

$$\text{Construct} \rightarrow \text{Validity Error} \rightarrow \text{Measurement} \rightarrow \text{Measurement Error} \rightarrow \text{Response} \rightarrow \text{Processing Error}$$

## TSE Framework Strengths & Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Comprehensive nomenclature | Excludes key quality concepts (timeliness, relevance) |
| Error decomposition for targeting | Implied independence (errors are often correlated) |
| Conceptual foundation for field | Lack of routine measurement (bias rarely quantified) |
| Evaluates trade-offs | Organizations still only report sampling error |

## Data Quality Dimensions ("Fitness for Use")

Beyond accuracy: **Relevance**, **Timeliness**, **Coherence**, **Accessibility**, **Interpretability**

\newpage

# Errors of Representation

## Coverage Error

**Definition**: Mismatch between Target Population and Frame Population—members have zero probability of selection.

### Coverage Bias Formula

$$\text{Coverage Bias} = \left(\frac{U}{N}\right)(\bar{Y}_C - \bar{Y}_U)$$

Where:

- $U/N$ = proportion of population uncovered
- $\bar{Y}_C - \bar{Y}_U$ = difference in means between covered and uncovered populations

### Frame Types and Issues

| Frame Type | Issues |
|------------|--------|
| **Area Frames** | High coverage but expensive; subject to lister errors |
| **ABS (Address-Based)** | High coverage; misses new construction, P.O. box issues |
| **RDD Frames** | Challenged by cell-phone-only households |
| **Register Frames** | Quality depends on maintenance |

### Reduction Methods

1. **Redefine Target Population**: Make compatible with frame (reduces relevance)
2. **Enhance Frame**: Multiple frames, linking methods (Half-Open Interval), network sampling (RDS)
3. **Statistical Adjustments**: Post-stratification, calibration to known totals

## Nonresponse Error

### Response Rate Formulas (AAPOR)

- **RR1 (Minimum)**: $\frac{I}{(I+P)+(R+NC+O)+U}$
- **RR2**: $\frac{I+P}{(I+P)+(R+NC+O)+U}$
- **RR3**: $\frac{I}{(I+P)+(R+NC+O)+e(U)}$
- **RR4 (Maximum)**: $\frac{I+P}{(I+P)+(R+NC+O)+e(U)}$

Where: I=Complete, P=Partial, R=Refusal, NC=Noncontact, O=Other, U=Unknown eligibility

### Nonresponse Bias Formula

$$\text{Bias} \approx \left(\frac{M}{N}\right)(\bar{Y}_r - \bar{Y}_m)$$

Or in stochastic form:
$$\text{Bias} \approx \frac{\sigma_{Y\rho}}{\bar{\rho}}$$

Where $\rho$ is response propensity and $\bar{\rho}$ is average response rate.

### Theories of Nonresponse

| Theory | Core Idea |
|--------|-----------|
| **Social Exchange** | Respond if perceived benefits outweigh costs |
| **Social Integration** | More socially integrated → more likely to respond |
| **Leverage-Salience** | Response depends on which features are emphasized |

**Key Finding (Groves 2006)**: Weak correlation ($r \approx 0.2$) between response rates and nonresponse bias. High response rate reduces *risk* but doesn't guarantee absence of bias.

\newpage

# Nonresponse Reduction and Adjustment

## Reduction Strategies

### Front-End Techniques

- Advance notification, personalization, incentives
- Multiple contact attempts, reducing perceived burden
- Interviewer training

### Responsive/Adaptive Design

- **Responsive Design**: Phased approach; monitor data to inform protocol changes
- **Phase Capacity**: Point where additional effort yields minimal estimate changes
- **Adaptive Design**: Tailor protocols to specific subgroups within phases
- **R-indicators**: Monitor representativeness during collection

## Weighting Adjustments

### Nonresponse Weighting vs. Calibration

| Nonresponse Weighting | Calibration |
|-----------------------|-------------|
| Uses info known for all sampled units | Uses external population totals |
| Assumes MAR within adjustment cells | Corrects for multiple error sources |

### Auxiliary Variable Selection (Little & Vartivarian, 2005)

**Critical insight**: Conventional wisdom that weighting = "lower bias for higher variance" is oversimplified.

**Optimal variables are**:

1. **Primary**: Highly predictive of survey outcomes (Y)
2. **Secondary**: Predictive of response propensity

When both conditions met, weighting can reduce **both** bias and variance!

### 2016 Election Polling Example

Many polls failed to weight by education. Education was correlated with both:

- Propensity to respond
- Vote choice

Result: Systematic bias in final estimates.

\newpage

# Measurement Error

## Definitions and Concepts

**Measurement Error**: Any deviation of reported value from "true" value (systematic or random)

### Two Levels of Meaning

1. **Respondent Level**: $y_i = \mu_i + \epsilon_i$ (observed = true + error)
2. **Estimate Level**: Aggregated impact on survey statistics

### Two Conceptions of "Truth"

| Platonic True Score | Classical True Score |
|---------------------|----------------------|
| Verifiable from external source | No existing real-world measure |
| Applies to behaviors, characteristics | Applies to psychological traits, attitudes |
| Example: vote in 2024, household size | Example: extraversion, job satisfaction |
| Survey researchers use this | True score = expected value over many trials |

### Classical True Score Model

$$y_{it} = \tau_i + \epsilon_{it}$$

Where $\tau_i$ = true score (mean over trials), $\epsilon_{it}$ = random error for trial $t$

**Simple Response Variance**: Variance of responses over repeated trials

### Effect of Random Measurement Error

- **On variance of estimates**: Increases variance
- **On means/proportions**: Not affected (errors average out)
- **On correlations/regression**: **Attenuated** (biased toward zero)

$$\beta_{observed} = \beta_{true} \times \lambda$$

Where $\lambda = \frac{\sigma^2_{true}}{\sigma^2_{observed}}$ (reliability ratio)

## Construct Validity

**Definition**: How well you translated a concept into a functioning measurement

### Assessing Validity

**Qualitative**: Cognitive interviewing, expert review

**Quantitative (Empirical validity)**:

- Correlation with other variables that should (or shouldn't) associate
- Group comparisons
- Split-ballot experiments

## Reliability and Validity Relationship

$$\text{Empirical Validity} \leq \text{Theoretical Validity} = \sqrt{\text{Reliability}}$$

- High reliability is **necessary** but not **sufficient** for high validity
- A valid measure is reliable, but a reliable measure can be biased

\newpage

# Methods to Study Measurement Error

## 1. Question Evaluation Methods

| Method | Purpose |
|--------|---------|
| **Cognitive Interviewing** | Think-aloud, probes, vignettes |
| **Behavior Coding** | Observe interviews, record correlates |
| **Paradata** | Timestamps, keystroke data |
| **Expert Review** | Identify problems qualitatively |

## 2. External Measures

### Record Check Studies

- **Reverse/Backward**: Sample from records → obtain self-reports → compare
- **Forward**: Obtain self-reports → confirm with records
- **Full Design**: Sample from frame with all members → obtain all records

**Limitations**: Assumes records error-free; matching problems; consent issues

### Aggregate Benchmarks

Compare survey estimate to external aggregate data

**Limitation**: Discrepancies could be from other error sources (coverage, nonresponse)

## 3. Randomized Assignment

**Split-ballot experiments**: Random assignment to measurement conditions

$$y_{ij} = X_i + M_j + \epsilon_{ij}$$

Where: $X_i$ = true value, $M_j$ = method effect, $\epsilon_{ij}$ = random deviation

**Common indicators of measurement bias**:

- Socially desirable responding
- Satisficing behaviors (missing data, straightlining, rounding)

## 4. Repeated Measures (Reinterview Studies)

Studies reliability (response variance) rather than bias

**Assumptions**:

- No change in true values over trials
- No memory effect between trials
- Same essential survey conditions

\newpage

# Sources of Measurement Error

## Interviewer Effects

### Types of Interviewer Errors

- Falsification
- Incorrect roster inclusion/exclusion
- Misunderstanding concepts
- Reading/probing issues
- Data entry errors

### Interviewer Variance Model (Kish 1962)

$$y_{ijt} = X_{ijt} + M_j$$

**Intraclass correlation**:
$$\rho_{int} = \frac{\sigma^2_{M}}{\sigma^2_{total}}$$

### Design Effect for Interviewers

$$deff_{int} = 1 + \rho_{int}(m - 1)$$

Where $m$ = average interviewer workload

**Key insight**: High workload can exacerbate even small intra-interviewer correlations

### Determinants of ρ

- **Mode**: Lower in telephone than face-to-face
- **Question type**: Higher for attitudinal, sensitive, open-ended
- **Demographics**: When related to measured characteristics
- **Behavior**: Probing, standardization

## Respondent Factors

| Factor | Issue |
|--------|-------|
| **Memory** | Encoding failure, forgetting, telescoping |
| **Motivation** | Satisficing (Krosnick 1991) |
| **Communication** | Social desirability, comprehension |
| **Knowledge** | "Nonattitudes," DK responses |

### Satisficing Formula

$$\text{Satisficing} = \frac{\text{Task Difficulty}}{\text{Respondent Ability} \times \text{Motivation}}$$

## Questionnaire Issues

- **Wording**: Framing effects (e.g., "forbid" vs. "allow")
- **Response options**: Number, scale type, frequency anchors
- **Question order**: Assimilation and contrast effects
- **Usability**: Font size, navigation, programming errors

\newpage

# Processing Error

## Definition

Errors during conversion from raw data to cleaned, analyzed state

## Three Main Sources

### 1. Data Entry/Capture

- Human keying errors
- Scanning errors
- Generally small error rates

### 2. Editing

**Two approaches**:

- Accountant's view: Exhaustive search for errors
- Significance/Selective editing: Focus on influential errors

**Detection**: Range checks, ratio edits, consistency checks

**Correction**: Manual correction (recontact), imputation

**Risks**: Wrong value identified as erroneous; overediting; imputation error

**Disclosure Avoidance Techniques**:

- Microdata: Remove PII, top-coding, noise addition, synthetic data
- Macrodata: Cell suppression, rounding

**Partially Synthetic Data (Reiter 2012)**:

- Sensitive variables blanked and replaced with imputed values
- When generated effectively, allows **valid inference** by:
  1. Estimating quantities of interest in each synthetic dataset
  2. Computing variance estimates for each
  3. Combining estimates using rules similar to multiple imputation
- Automatically propagates uncertainty from disclosure treatment
- **Key limitation**: Analysts often ignore measurement errors from SDL and "trust that their analysis has not been unduly compromised"

### 3. Coding Open Responses

**Types**:

- Unconstrained answers (require category development)
- Constrained answers (occupation, medications)

**Intercoder Reliability**: Key measure of coding quality

$$deff_{coder} = 1 + \rho_c(m - 1)$$

**Reasons for disagreement**: Ambiguous responses, conflicting rules, coder interpretation

**AI/NLP approaches for coding**:

- Few-shot prompting > zero-shot prompting
- Fine-tuning/pre-training is essential
- **BERT** (Gweon & Schonlau 2024): 
  - Fine-tuning the model is essential for good performance
  - With only 100 manually coded observations, BERT barely beats non-pretrained ML
  - Advantage rapidly increases with 200-400+ coded observations
- Prompt design matters: provide both positive and negative examples
- Performance varies across different LLM/NLP models

\newpage

# Multiple Sources of Survey Error

## Key Principles

### Error Interactions

- Errors are often **not independent**
- Design features may affect multiple error sources
- Since bias is directional, errors can:
  - **Accentuate** each other
  - Be **independent**
  - **Cancel** each other out

### Common Cause Model

Example: Low motivation may cause both nonresponse AND measurement error

**Evidence** (Fricker & Tourangeau 2010): Converted refusers show higher item nonresponse

### Correlation Between Nonresponse and Measurement Error

- **Independence model**: Errors generated independently
- **Common cause model**: Shared underlying factor (e.g., motivation)

**Key findings**:

- Reluctant respondents may be poorer respondents (Cannell & Fowler 1963)
- But results are mixed (Olson 2006: limited support for systematic relationship)
- Efforts to increase response rates can actually **increase** overall error

### Practical Implications

- Base design decisions on **overall** effects, not single error source
- Higher response rate may not reduce total error
- Need targeted approaches to reducing nonresponse

\newpage

# TSE and Found Data

## Designed vs. Found Data (Groves 2011)

| Designed Data | Found Data |
|---------------|------------|
| Produced by researchers | By-product of something else |
| Surveys, experiments | Administrative records, digital traces |
| "Custommade" (Salganik) | "Readymade" |

## Found Data: Strengths & Limitations

### Strengths

- Huge volume (rare events, small groups)
- High velocity (real-time, unexpected events)
- Nonreactivity (unaware of measurement)
- Unobtrusive, relatively cheap

### Limitations

- Nonrepresentative (coverage issues)
- Algorithmic confounding
- Volatility (constantly changing systems)
- Incomplete data (few variables)

## Error Frameworks for Found Data

### Big Data Total Error (BDTE) Framework (Amaya, Biemer, Kinyon 2020)

- **Row Error**: Omission, duplication, erroneous inclusion
- **Column Error**: Misspecified variables
- **Cell Error**: Content error, missing data

### TED-On Framework (Sen et al. 2021)

Total Error Framework for Digital Traces of Human Behavior on Online Platforms:

- Uses "traces" and "users" rather than "responses" or "respondents"
- **Platform affordances error**: Behaviors influenced by platform norms, design, technical capability
- Changes over time create "behavioral drifts" impacting reliability
- Key question: Are platform-driven behaviors different from independent behaviors?

### Non-Probability Panels (Tourangeau 2020)

Three forms of error:

1. **Coverage bias**: Internet vs. target population
2. **Selection bias**: Panelists selected vs. Internet population
3. **Nonresponse bias**: Those asked vs. those completing

### Google Flu Trends Example (Lazer et al. 2014)

**Why it failed**:

- "Big Data hubris"
- Algorithm changes (suggested search terms)
- Overfitting
- Increased media coverage

**Lesson**: Quantity doesn't compensate for measurement/validity issues

### Total Twitter Error (Hsieh & Murphy 2017)

- Coverage error (who's on platform vs. population)
- Query error (keywords miss relevant content)
- Interpretation error (what does content mean?)

\newpage

# Weighting and Adjustment

## Types of Weighting

### Base Weights

Inverse of selection probability

### Nonresponse Adjustment

**Weighting Class Adjustment**:

- Divide into cells with homogeneous response probabilities
- Weight respondents up within cells
- Assumes respondent mean ≈ nonrespondent mean within cells

**Propensity Score Weighting**:

1. Model response indicator: $P(R=1|Z)$
2. Use reciprocal as weight: $w = 1/\hat{p}$

### Calibration/Poststratification

Adjust to external population totals (e.g., Census)

- Corrects for multiple error sources simultaneously
- Raking: Iterative adjustment to marginal totals

## Auxiliary Variable Selection

| Correlation with Outcome | Correlation with Response | Effect on Bias | Effect on Variance |
|--------------------------|---------------------------|----------------|-------------------|
| Low | Low | None | None |
| High | Low | None | **Decrease** |
| Low | High | None | **Increase** |
| **High** | **High** | **Decrease** | **Decrease** |

**Target**: Variables correlated with BOTH outcome and response propensity

## Analytic Error (West et al. 2017)

**Definition**: Failure to use appropriate estimation methods for complex survey data

**Common issues**:

- Ignoring survey weights → biased estimates
- Ignoring clustering → underestimated standard errors
- About 50% of published studies failed to use proper methods

\newpage

# Imputation for Item Nonresponse

## Purpose

Fill in missing values to create complete dataset

## Missing Data Assumptions

- **MCAR**: Missing Completely at Random (pure fluke)
- **MAR**: Missing at Random (explainable by observed variables)
- **MNAR**: Missing Not at Random (depends on unobserved values)

Most methods assume **MAR**—more realistic than MCAR

## Methods

| Method | Description |
|--------|-------------|
| **Mean Imputation** | Replace with subgroup mean |
| **Hot-Deck** | Use value from similar "donor" record |
| **Regression** | Predict from other variables |
| **Multiple Imputation** | Create multiple complete datasets |

**Multiple Imputation Advantage**: Correctly accounts for uncertainty from imputation → valid standard errors

\newpage

# Key Formulas Summary

## Error Components

$$MSE = Bias^2 + Variance$$

## Coverage Bias

$$Bias_{coverage} = \left(\frac{U}{N}\right)(\bar{Y}_C - \bar{Y}_U)$$

## Nonresponse Bias

$$Bias_{NR} \approx \left(\frac{M}{N}\right)(\bar{Y}_r - \bar{Y}_m) \approx \frac{\sigma_{Y\rho}}{\bar{\rho}}$$

## Design Effect (Interviewers/Coders)

$$deff = 1 + \rho(m - 1)$$

## Effective Sample Size

$$n_{eff} = \frac{n}{deff}$$

## Measurement Error Model

$$y_{ij} = X_i + M_j + \epsilon_{ij}$$

## Reliability

$$\rho_x = \frac{\sigma^2_{\tau}}{\sigma^2_x} = \frac{\text{True Score Variance}}{\text{Observed Variance}}$$

## Validity-Reliability Relationship

$$\text{Theoretical Validity} = \sqrt{\text{Reliability}}$$

## Attenuation in Regression

$$\beta_{observed} = \beta_{true} \times \lambda$$

Where $\lambda = \sigma^2_{true} / \sigma^2_{observed}$

\newpage

# Key Studies to Remember

| Study | Key Finding |
|-------|-------------|
| **Groves 2006** | Weak correlation ($r \approx 0.2$) between response rates and bias |
| **Little & Vartivarian 2005** | Optimal weighting variables predict outcomes, not just response |
| **West et al. 2017** | ~50% of analyses ignore survey design features |
| **Curtin et al. 2000** | Time series robust to nonresponse; levels more affected |
| **2016 Election Polls** | Education weighting failure led to systematic bias |
| **Lazer et al. 2014** | Google Flu Trends: "Big Data hubris" |
| **Kreuter et al. 2010** | Auxiliary variables showed modest usefulness for adjustment |

