---
id: "jpsm/total_survey_error_SURV720/lecture_notes"
source: "jpsm"
course: "SURV720"
course_title: "Total Survey Error and Data Quality I"
doc_type: "lecture"
title: "lecture_notes"
original: "total_survey_error_SURV720/lecture_notes.pdf"
pages: 25
sha256: "fe1755170f9aac4de5680576430327851a33bbba7820cdd9c11f540bd275af62"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:24"
---

<!-- page 1 -->

TOTAL SURVEY ERROR AND DATA QUALITY I NOTES

Syllabus

You are a graduate student at UMD JPSM studying total survey error and data quality. For each article, examine:
What is the cause of the error?
What techniques can be used to reduce the error in practice?
What statistical models can be used to measure the error source? For papers.
Does it tell me how to reduce the error?
Task: Write a study guide for each article no more than a page long answering the questions above.

**TSE and Data quality Lecture 8/25/25**

* There are difference perspectives in survey research. Describers or modelers.
  * Different goals, measure (design nonresponse bias study) error or reduce error (improve response rate).
* What do you mean by data quality?
  * If we need to estimate population $\theta$ and the parameter is unknown. We need a metric that tells us how far the estimate is from the true estimate.
  * $\text{MSE} =$ expected squared difference between the population parameter and survey estimator.
    * $\text{MSE} = E(\theta_{\text{pop}} - \theta_{\text{surv}})^2 = \text{Bias}^2(\theta_{\text{samp}}) + \text{Var}(\theta_{\text{samp}})$
    * $\text{Bias} =$ error that tends to agree
    * $\text{variance} =$ spread of error that tend to disagree.
  * Accuracy is the inverse of MSE (bias and variance).
    * Precision is applied to variance.
    * MSE cannot be $0$, we still have sampling variance.
  * That survey was really accurate?
    * Is it based on MSE? MSE will vary by question and demographics.
  * The MOE of the survey is?
    * It is still estimate specific.
* If we want to minimize MSE, we want to decompose error into components parts to target sources of error.
* Total Survey Error
  * The sum of all ways a survey measurement can go wrong (Smith, 2005).

<!-- page 2 -->

# TSE Diagram

| **Measurement** | **Representation** |
| :---: | :---: |
| Construct<br>$\downarrow$<br>Measurement<br>$\downarrow$<br>Response<br>$\downarrow$<br>Edited Response | Target Population<br>$\downarrow$<br>Sampling Frame<br>$\downarrow$<br>Sample<br>$\downarrow$<br>Respondents<br>$\downarrow$<br>Post-survey Adjustments |
| $\searrow$ | $\swarrow$ |
| **Survey Statistic** | |

Groves et al. (2004) 29

* Representation arm, the who, measurement arm is the what.
  * Coverage error: failure to include all elements of the target population in the sampling frame.
    * Deviation from the true population value from the survey results (when talking to the public)
  * sampling error: failure to include all elements of the target population.

Nonresponse bias can it be associated with other sources of error, such as measurement error.
No. bias is systematic error, and variable error is random, it can arise from the same sources,

### Can all sources of error that are normally associated with bias also be associated with variable error?

No, sources of error associated with bias are not also associated with variable error. Bias (also known as systematic error) and variable error (also known as random error) are fundamentally different types of errors, though both can arise from the same general sources. The key distinction is in their nature and effect on the results.

<!-- page 3 -->

Indicate whether each statement describes variance or bias.

1. Processing error that occurs when procedures randomly vary in their implementation (e.g., coders interpret written answers differently) Variance, errors will tend to disagree.
    1. This type of processing error is a classic example of **variable or random error**. When coders interpret answers differently, the error introduced is not consistent or systematic across all measurements. Instead, it's a random fluctuation. Some coders may err on the high side, and others on the low side. The errors tend to disagree, meaning they are non-directional and will, on average, cancel each other out over a large number of observations.
2. Processing error occurs when procedures consistently change values, yielding the same set of deviations from recorded values : Bias, errors will tend to agree.
    1. The key phrase is "consistently change values, yielding the same set of deviations." This points directly to a **systematic error**, or **bias**. Bias is a consistent, directional error that affects all measurements in the same way. The errors "tend to agree" because they are all being pushed in the same direction by a flawed process.

<!-- page 4 -->

### Lecture 2 9/8/2025

| Dimension | Description |
| :--- | :--- |
| Accuracy | Degree to which error is minimized |
| Relevance | Degree to which it meets the real needs of users |
| Timeliness | Delay between the reference point and the date it becomes available |
| Coherence | Degree to which it is consistent over time and can be successfully brought together with other information |
| Accessibility | Ease with which it can be obtained |
| Interpretability | Availability of metadata and other supplemental information necessary to interpret and utilize it |

*Brackstone (1999)*

* ASPIRE, system for product improvement, review and evaluation.
* TSE limitations
    * timeliness, exclusion of key quality concepts,
    * errors are not independent of each other.
    * Estimation of errors is hard to achieved
        * effect generalizability, learn from other studies
    * does not define error threshold
* TSE strenths
    * decomposition of error
    * separation of error sources that affect statistics
    * conceptual foundation
* survey cost:
    * constraints are the budget
        * total costs = fixed costs + variable costs
            * variable example number of interviewers, etc.
    * survey costs are nonlinear, cost per case is nonlinear
    * there is variability in costs across cases.
    * Cost structure can change.
    * Steps for generating cost error model
        * specify error model as a function of a design feature, such as strata.
        * Specify cost model on features
        * combine equations to minimize cost/error.
            * Determine the sample size and allocation by strata.

<!-- page 5 -->

*   Limitation of this cost-error model
    *   single estimates, based on variable.
    *   Error must be measurable
*   correlation between cost and millage or number of contacts can point to cost issues.
*   Coverage error: three questions we should always ask.
    *   Why is this error happening?
    *   How do we measure this?
    *   How do I reduce this error?
    *   Coverage error: failure to include all elements of the target population in the sampling frame.
        *   Arises because some members of the target population are not represented on the sample frame.
        *   Example, there was sampling bias because we only sampled online. This is actually coverage error.
            *   Don’t confuse coverage with sampling error.
        *   “If my sample representative” hasn’t been defined. Are we talking about proportion allocation sampling.
        *   The population is of interest to survey methodologist, so we must clearly define target population.
        *   Example of defining sample
            *   Finite population defined in terms of:
                *   1. Content
                    *   “all civilians”
                *   2. Units
                    *   “in family units”
                *   3. Extent
                    *   “in the lower 48 states and District of Columbia in the U.S.”
                *   4. Time
                    *   “in 2024”
        *   population can also be defined in a process, say all cars that were in an accident in 2024. This is an example of an abstract population.
            *   Before study
                *   Inferential population – results from sample to be generalized to this population.
                    *   Example homeless youth
                *   Target population, elements to be studied. These are time restrictive and observable.
                    *   Example, homeless youth in MD between 16-19 in urban areas
            *   In the field
                *   Frame population – set of target population members that have a chance to be selected in the sample
                    *   example, homeless youth at 6 shelter locations
                *   this is were coverage error happens.
            *   After sample is collected
                *   Survey population – at this step it is more of sampling bias.
        *   Sample frame – used to identify units in a target population
            *   it doesn’t have to be a list, it can be a procedure like random digit dialing, or random address sampling.
            *   Mapping frame to target population

<!-- page 6 -->

* ideal, one to one correspondence if in frame also in target.
* Undercoverage – frame does not reach people, for instance people that live in garages that do not have an address.

| Frame | Target Population | |
| :---: | :---: | :--- |
| F | T | Correspondence |
| **.** | **T** | **Undercoverage** |
| F | . | Foreign elements/Ineligibles |
| F, F | T | Multiplicity (many-to-one) |
| F | T, T | Clustering (one-to-many) |

* Coverage Bias
  * for a mean Y, error due to undercoverage can be decomposed in sample N
    * U is not covered
    * C is covered
      * bias is a function of U and Y difference.

$$\bar{Y}_C - \bar{Y} = \frac{U}{N}(\bar{Y}_C - \bar{Y}_U)$$

* Measuring undercoverage
  * But U is not in the sample, so how do we get an idea of their Y_bar.
    * Compare to external data, like census
  * Another strategy analyze data from a large survey where membership on a frame is measured.

<!-- page 7 -->

**Lecture 3, repairs for undercoverage. 9/15/25**

* Coverage check studies
    * some respondents may not agree to endorse information about their community.
    * Coverage rate is not = to coverage bias.
        * Amaya et al 2021,
            * assess coverage rate within each segment against the ACS.
            * Step 2, use one of three frames.
                * ABS = addressed based sampling.
                * Enhanced listing
                * field listing
            * takes data, simulates to determine probability of inclusion.
* Reducing errors
    * redefine the target population
        * redefine the scope of the target population. making it more specific.
        * Redefine the population units, visitors to a museum in a specific season.
        * Limitations
            * relevance, tradeoff such as accuracy.
    * Enhanced the sampling frame.
        * Multiple frames
            * determine whether each sampled unit is a member of another frame.
                * Household that has landline and cell phone, more likely to be selected.
            * Compute selection probabilities based on information membership.
            * Lachan and Dennis 1993,
                * what is the target population?
                * Characteristics
                * location-time sampling
                * adjust for multiplicity
            * limitations, determining selection probabilities.
        * Linking methods

<!-- page 8 -->

* adding missing units to an existing frame by linking to selected units.
* Hard to reach populations
  * multiplicity – reports about events among personal networks.
  * What is hard to reach, low numbers, unknown boundaries, no sampling frame. Hard to identify or members that do not want to disclose identify.
  * Can we make RDS, respondent driven sampling, more probabilistic.
    * Recruit seeds to recruit within networks. The seed is the recruiter, and they must known each other.
      * Trace those that are recruited to collect information of the size of each network.
    * How do we know that the person recruited is a member of the population?
    * Statistical adjustment, develop weights and adjust.

**Nonresponse error 9/22/25**

* nonresponse, when sampled units do not respond.

* Other can be people that recently died, or the interview recording has too much background noise.
* Response rate - proportion of estimated sample who completed the survey.

<!-- page 9 -->

# AAPOR Dispositions for Response Rate Calculations

I = number of completed cases
P = number of partial cases

NC = number of noncontacted sample units known to be eligible
R = number of eligible refused cases
O = number of eligible sample units not responding for reasons other than refusal

U = number of sample units of unknown eligibility, not completed
e = estimated proportion of sample units of unknown eligibility that are eligible

# AAPOR Response Rates

$$\text{RR1} = \frac{I}{(I + P) + (NC + R + O) + U}$$

$$\text{RR2} = \frac{I + P}{(I + P) + (NC + R + O) + U}$$

$$\text{RR3} = \frac{I}{(I + P) + (NC + R + O) + eU}$$

$$\text{RR4} = \frac{I + P}{(I + P) + (NC + R + O) + eU}$$

<!-- page 10 -->

* RR1 most conservative, RR4 most liberal because of partials and adjusting for eUs.
  * There should be a minimum set of questions that are completed.
  * At least 50% response rate is adequate Grooves 2006.
    * it is not about the response rate, but the bias in the data.
  * Potential reasons for non-response.
    * Barriers – depend on survey mode, gated communities, spam filters.
    * busyness – increase in labor force, commute is farther, longer work schedules.
    * Less trust in government or organization
    * survey fatigue Eggleston 2024.
  * social exchange theory – people respond to survey if perceived benefits outweigh cost.
    * Incentive, but can also be having voice heard.
    * Cost – loss of privacy or time
    * provide small rewards, enhance importance, express appreciation, making questionnaire appear interesting.
  * Social integration theory
    * Individuals who are integrated in society more likely to respond. Greater sense of belonging and wants to contribute. This is more about cost benefits.
      * Nonresponse associated with decrease with civic participation.
      * Amaya and Harrig 2017 different dimensions of integration.
  * Leverage salience theory
    * people more likely to respond if features of the study are emphasized, these are leverages. Different aspects of the survey will be of interest to different people.

**Figure 6.4 Two sample persons with different leverages for attributes of a survey request.**

<!-- page 11 -->

* Limitations of these theory
  * focus on cooperation but not contact itself. Assumes people make rational choices based on features of the study, but people use heuristics (quick judgments).
* Measure non-response error
  * it has a bias and variance component. Bias is the difference between the target population that responded and the full target population.
  * It can also be, the nonresponse response rate $M/N * (\text{mean for sample} - \text{full target population}$.
    * This is a deterministic view, members never respond or always respond.
    * A stochastic view, propensity to respond $p\_i$.
      * Non-response bias $(y\_r) = \text{sigma}*Y*P/ P\_\text{bar}$. $P\_\text{bar}$ is average population propensity. These are samples from the population, and each has an average. $P\_\text{bar}$ is our response rate .
    * Grooves article, there was no association with response rate and nonresponse bias.
      * The risk of nonresponse bias is higher when we have low response rates. We can also reduce sampling variance.
      * We could increase different sources of error by increasing response rates because we may be amplifying an issue, say less representation for unrepresented people.

<!-- page 12 -->

### Groves, R.M. et al. 2008. Issues Facing the Field: Alternative Practical Measures of Representativeness of Survey Respondent Pools. Survey Practice, 1 (3)

Nonresponse bias stems from correlation between response propensities and survey variables. Key insight: bias varies **across estimates within a survey**, not at survey level. Response rates alone are poor quality indicators.

**Reduction Techniques**

**Prevention (Table 8.1):**

* High-priority/registered mail
* More call attempts, clearer interviewer materials
* Follow-up reminders, lead letters
* Incentives, endorsements
* Female interviewers (certain populations)
* Refusal conversion strategies
* Special tracing efforts

**Identification Studies:**

* Compare subgroup response rates
* Compare respondents vs. nonrespondents on auxiliary variables
* Wave analysis (early vs. late respondents in mail surveys)

**Compensation:**

* Nonrespondent subsampling
* Weighting adjustments
* Extrapolation methods

**Statistical Models**

**Survey-Level Indicators:**

* Coefficient of variation of nonresponse/poststratification weights
* Coefficient of variation of subgroup response rates
* Goodness-of-fit statistics on propensity models (logistic regression)
* R-indexes (Schouten) - marginal R-index using standardized regression coefficients
* **Limitation:** No direct linkage to survey variables

**Estimate-Level Indicators:**

* Compare respondents/nonrespondents on auxiliary variables
* Correlation between adjustment weights and Y (among respondents)
* Means of Y within weight deciles
* Fraction of missing information (multiple imputation framework)

**Sets of Estimates:**

* Group survey variables by correlation with auxiliary variables
* Provide separate indicators for each group

<!-- page 13 -->

**Does It Reduce Error?**

**Yes, but with caveats:**

* Provides comprehensive taxonomy (prevention, identification, compensation)
* Shows bias-variance tradeoffs
* Emphasizes prevention over compensation
* **Key limitation:** No single indicator adequately characterizes error across all estimates
* Advocates incorporating auxiliary information about respondents and nonrespondents.

9/29/25 Dealing with non-response

* work status at home, may be a z variable that drives cost of heat at home and propensity to respond. These z can explain propensity to respond and Y outcome.
* Can a higher response rate ever lead to higher nonresponse bias?
  * The reason is that survey bias is driven by the **composition** of your respondents, not just the number. If your efforts to get more responses only attract people who are similar to those who have already answered, you are amplifying the existing imbalance and making your sample *less* representative.
  * Therefore, the primary goal should not be maximizing the response rate. The modern priority is **minimizing bias by achieving a representative sample**, where all subgroups are properly reflected. A balanced sample with a 40% response rate is often better than a skewed sample with a 60% response rate.
* Do you think you should prioritize achieving a high response rate?
  * Your primary goal should be to **minimize nonresponse bias** by achieving a **representative sample**. This means ensuring the final group of respondents accurately reflects the characteristics of the overall population you're studying. A well-balanced sample with a lower response rate is far more valuable and accurate than a skewed sample with a high response rate.
* R indicator (representativeness), goes from 0 – 1, depends on a good response propensity model.
* Response rate does not tell us about our Y variables, the auxiliary variables do.
* FMI = fraction of missing information, multiple imputation procedure.

<!-- page 14 -->

**Lessler, J. and Kalsbeek, W. (1992). Nonsampling Errors in Surveys, John Wiley and Sons, Chapter 8, Sections 8.0 - 8.1.5.**

Nonresponse bias occurs when respondents differ from nonrespondents on $Y$. $\text{Bias} = (1 - \text{response\_rate})(\text{mean\_respondents} - \text{mean\_nonrespondents})$. High response rates don't guarantee low bias if correlation between $Y$ and response propensity is strong.

**Reduction Techniques**

**Prevention:**

* Match topic/population/mode to expected rates
* Current addresses, special tracing
* Follow-ups, incentives, endorsements, lead letters
* Brief questionnaires, avoid sensitive topics
* Optimize call attempts using cost models

**Identification:**

* Subgroup response rate analysis
* Compare respondents/nonrespondents on frame data
* Wave analysis with extrapolation models (log-linear, linear, hyperbolic)

**Example:** NAEP study showed respondents had better grades, attendance, test scores than nonrespondents (Table 8.2)

**Statistical Models**

**1. Nonrespondent Subsampling (Hansen-Hurwitz):**

* Estimator: weighted average of respondent mean and subsampled nonrespondent mean
* Variance increases with subsampling rate $g$
* Optimal $g \approx$ inversely proportional to cost ratio
* Extensions: Bayesian approaches (Erickson, Rao & Ghangurde, Singh & Sedransk)

**2. Weighting Class Adjustment:**

* Partition into $H$ cells with homogeneous response probabilities
* Unbiased if: $\text{respondent\_mean} = \text{nonrespondent\_mean}$ within all cells
* Variance has 3 components: element, adjustment, between-cell
* Cell criteria: correlated with $Y$ and response; $n \geq 20$; balance $H$ vs. cell size
* Bias reduced when cells homogeneous; variance increases unless cells identical

**3. Poststratification:**

* Uses external population totals $N\_h$
* Bias equivalent to weighting class under homogeneity
* Variance generally smaller than weighting class
* Sequential: apply weighting class first, then poststratification
* Example: NHIS uses 60 age-race-sex cells with census totals

**4. Politz-Simmons:**

* $\text{Response probability} = (\text{days\_available} + 1)/6$
* Assumes $\text{availability} = \text{response}$ (ignores refusals)

<!-- page 15 -->

* Doesn't handle hard-core nonrespondents
* High variance when availability uncorrelated with $Y$

**5. Randomized Reweighting:**

* Match subsampled respondents to nonrespondents as "donors"
* $\text{Variance increase} = (1 - \text{rate})(2 \times \text{rate} - 1)$, max $12.5\%$ at $\text{rate}=0.75$
* Lower variance than standard weighting class

**6. Raking-Ratio:**

* Maintains marginals without joint distribution
* Iterative adjustment to known marginals
* Requires only marginal frequencies (practical advantage)
* Convergence not always assured

**Weight Controls:**

* Truncate at bounds (e.g., $0.5$ to $2.0$)
* Pool exceptional cells
* Smooth extreme weights

**7. Substitution:**

* Replace nonrespondents with similar units
* **Does NOT eliminate bias** (Cohen 1955, Williams & Folsom 1977)
* May reduce interviewer effort
* Discouraged as primary strategy

**Does It Reduce Error?**

**Yes, with extensive guidance:**

**Decision framework:**

* Prevention most effective when base rate $<50\%$
* Cost of $80\text{-}90\%$ may exceed value for some surveys
* Balance prevention costs vs. compensation costs

**Key recommendations:**

* Poststratification + weighting class better than either alone
* Cell homogeneity critical for bias reduction
* Nonrespondent subsampling expensive but directly measures bias
* Auxiliary variable quality paramount

**Critical insight:** No method eliminates all bias. Effectiveness depends on correlation between auxiliary and survey variables. Careful auxiliary variable selection is essential.

<!-- page 16 -->

**Weighting and adjustments 10/6/25**

* Weighting is a statistical adjustment procedure for survey data after collection where observed element is assigned a weight.
  * This is to correct for unequal probabilities of selection, and to help compensate for frame deficiencies.
  * Methods
    * nonresponse weighting - weighting up respondents to account for nonresponse.
      * Adjustment - assumption is that there are similar characteristics and MCAR.
        * If missing at random, this is a realistic assumption on the account of some variable.
        * In practice, cell collapse when cells are small.
          * **Question:** Do they look at response rate for each cell, or cell size? The $y$ values, can be combined to reduce bias, based on response rate.
      * Propensity score weighting
        * Define response indicator, $r=1$ response, $r=0$ no response.
          * **Question:** Does it matter if it is reverse coded, probabilities are for non-response, no taking of inverse of the probabilities. $1/(1-p)$? This is correct.
        * Fit a regression model with $r$ as outcome and get predicted response probabilities.
        * Use reciprocal as the weight, inverse of the probability.
        * Advantage: adjustment cell approach.
    * Auxiliary variables
      * available for all units, respondent and non-respondent. This can be external sources. Alternative data can be or paradata, called nriched sampling frame information.
      * Low response rate is different from non-response bias. Class example on low response rate for younger respondents.
        * We assume that $y$ values are different for younger and older respondents. Think about the $y$ values. Two things are happening here, seniors and youngsters are different, and/or younger respondents are different from younger non-respondent.
      * The below table
        * the association is between the outcome and auxiliary variable. When we use weights, variance increases and bias may go down, this is the trade-off.
        * If axuliary variable is low associated with outcome and nonresponse, bias and variance does not get affected.
        * If auxiliary variable is highly correlated with outcome, and has low correlation with nonresponse variance goes down. Think of stratification, the strata is a auxiliary variable, homogeniety, so people are more alike, and the auxiliary variable or the grouping explains more of the $Y$ variance.

<!-- page 17 -->

* High association with nonresponse and low with outcome, variance goes up, the auxiliary variable does not group respondents well and tends to create more heterogeneity in the outcome.
  * Example – GPA ~ gender, we find that females respond at a higher rate (50%, 25% for males) than males. When we apply the weights, we upweight males 4 times higher, we now introduced variability across gender.
* \*High correlation with outcome and nonresponse, low bias and low variance (Target for all weighting).

## Which adjustment variables should I choose? The choice has important implications.

### Association with outcome

| Association with nonresponse | Low | High |
| :--- | :--- | :--- |
| **Low** | Cell 1<br>Bias: ---<br>Var: --- | Cell 2<br>Bias: ---<br>Var: $\downarrow$ |
| **High** | Cell 3<br>Bias: ---<br>Var: $\uparrow$ | Cell 4<br>Bias: $\downarrow$<br>Var: $\downarrow$ |

Little and Vartivarian (2005)

* Interview bias on paradata. Agreement is around 70-80%. When Z has measurement error, the correlation is weaken.
* Post stratification and calibration
  * does not require unit level information of non-respondents. N_h population totals for each stratum and n_h is the sample in each stratum.
  * Calibration, raking, it is an iterative process to match the population.
  * Poststratificaiton, in some cases the strata can create more variance.
  * When someone says weighting, what do they mean? What did they do, nonresponse adjustment, postratification, just used base weights?

<!-- page 18 -->

* Potential sources of bias
  * mismatch between auxiliary variables and outcomes.
  * ML approaches for weighting, the algorithm is less important than the variables used.
* Analytic errors - the failure of the survey data user to employ appropriate estimation methods when analyzing the collected survey data.
  * Examples, appropriate use of weights for estimation.
    * In West 2017, about 50% of studies in metadata did not use weights.
* Imputation – item non response, if we only use analysis with complete cases, we are likely to have bias in our analysis.
  * Instead, we can use deductive imputation say a 12 year old with missing marital status, we can impute unmarried.

Midterm, write responses as if you were explaining to a client. Review all readings.

<!-- page 19 -->

**Measurement error 10/27/25**

* Construct validity – refers to how well you translate an abstract concept into a functioning measurement reality. The central question is: "How useful/appropriate are the answers to my question in telling me about what I am trying to measure?
    * Constructs are uni or multidimensional.
    * Validity requires measures to be appropriate and comprehensive of the construct.
        * **Reaction**: How do we handle constructs that may have different validity requirements across cultural contexts?
* Assessing validity
    * cognitive interviewing, expert review to identify potential problems or mismatch.
    * Quantitative methods, empirical methods, correlation between the observed and true score.
        * Group comparisons that should be different in their construct ability.
            * **Reaction**: this assumes that the questions at hand are equivalent across the groups?
        * Split ballot experiments to compare question wording.
        * Criterion validity checks against external standards.
            * **Reaction**: An example for me to remember this concept is, cancer screening tool and actually cancer diagnose.
        * Research examples:
            * Sudman & Bradburn (1982): Alcohol consumption questions with different response scales dramatically affected reporting of heavy drinking
            * Wood & Williams (2007): Gambling expenditure questions - wording variations produced 5-fold differences in reported spending
            * Tourangeau et al. (2018): PATH tobacco study - validated self-reports against saliva samples (87.5% agreement)
* measurement error any deviation of the observed value from the true value.
    * Two levels, respondent level and estimate level.
        * Respondent level $y\_i$, $y\_i = \mu\_i + \varepsilon\_i$ ($\text{observed} = \text{true} + \text{error}$)
            * concept of trials, distribution of $y$ values, error cancels each other out and the mean is the true value. This is reliability.
                * **Reaction**: I need to understand more, slide 28.
            * Includes concepts of bias (non-zero expected error) and simple response variance
* Pick up on 11/3/235
    * Effect of random measurement error, when variance increases it expands standard error, less chance of detecting effect.

<!-- page 20 -->

* In regression models, measurement variance will flatten slope. The mean of the variance will also shift.
  * Beta for the true parameter \* lambda (true variance / total variance) = beta for falsification.
  * **Reaction:** If there are measurement error in the outcome, it will shift the intercept, the delta (difference in true value)

inferences when there are mea

$$y_i = \beta_0 + \beta_1 x_i + (\epsilon_i - \delta_i)$$

  * it won't affect slope coefficients.
* Platonic true score
  * construct is theoretical objective (election polls) but can be derived from external sources such as behaviors and characteristics.
    * The true score is objective, bias in quantifiable.
* Classical true score
  * latent constructs, bias for true score is the expected value over a large number of trials.

$$y_{it} = \mu_i^* + \varepsilon_{it}$$

  * mu_i is the average for an individual on the same repeated variable.
    * True score is the mean, distribution, across trials.
    * *Random* errors across trials are deviations from true score. Random here because they are not systematic.
  * Validity is about correlations. How do we measure theoretical validity, correlation of y and Mu.
    * Empirical validity – correlation of the measure's outcome and another outcome.
    * Concurrent validity – example, depression scale, also measuring related variables they should correlate.
    * Convergent validity - correlation in the same directional
    * divergent validity - opposing correlations.
  * Reliability - how stable are the responses over trials.
  * **Reaction:** This was talk about in the context of classical true score, but what about platonic?

<!-- page 21 -->

* A reliable measure is not a valid one, but a valid measure is also a reliable.
  * From Bohrnstededt 1983, empirical validity $<=$ to theoretical validity $=$ sqrt(reliability). All of them use x in the subscript
* Grooves, if a measure is reliable, it is valid. They are slightly talking about different things here.
* In the spreadsheet:
  * if the trial scores are close to eachother, the correlation in tau (true score) and mean(y) is high, if there is variation in trials, the correlation suffers.
  * Reaction: What if the trails are bias, correlation is off, but is it in a specific direction?

| **Psychometric perspective** | **Survey research perspective** |
| :--- | :--- |
| • Classical true score | • Platonic true score |
| • No concept of measurement bias | • Bias is an important concept |
| • Correlations, variances, covariances | • Correlations, etc. but also means and totals |
| • Psychological/Attitudinal | • Factual, Behavioral |
| • Validity and Reliability | • Bias and Variance |

* In the psychometric perspective, no concept of bias because there is an assumption that measurement error epsilon cancels out over N trials.
* Relationship between validity and bias-variance
  * closely linked, not the same.
  * A valid measure can still generate a bias estimate (the weight scale example that is off by 5lbs).
  * Slide 28, discuss further.
  * Do you smoke example? There is a true value out there, so this is a bias case. There are probably reasons why the question resulted in bias responses based on measurement bias.
  * The job satisfaction example, validity issue because there is no other trial and there is a weak criterion validity correlation.

<!-- page 22 -->

* Methods for measurement error:
    * cognitive interviews such as think out loud, vignette.
        * **Reaction:** The census mortgage question. In the cross cultural context, this should lead to measurement bias?
        * Behavior coding. Respondent behavior questions for interviewers. Helps identify problems with the questions or interviewer.
        * Challenges, they do not tell us the quantified error, maybe just the source.
        * Record checks to compare self report and records, assumption is that records are free of error.
            * Two types of studies
                * Reverse, retrospect, check. Check records first and than conduct survey.
                    * This can be done at the person or event level.
                * Forward check, survey first than going to records. Limitation is that if the event does not get initially reported, the researcher may fail to look for the record.
                    * **Reaction:** Depending on how long ago the events were, there may be telescoping effects reporting events as more recent, or excluding events in the time frame being asked. Can this lead to measurement variance?

<!-- page 23 -->

**11/10/25**

* Common indicators of measurement bias:
    * satisficing, straightlining, reducing grids.
    * Measurement model: $y_{ij} = x_i + m_j + e_{ij}$. **Slide 6**
        * $J$ is a method such as question wording.
            * **REACTION**: Wouldn't we want $J$ to also be a covariate?
            * $X$ is the true value, $M$ is the error associated with the method. , $e$ is the deviation.
    * Limitations of randomize design.
        * Experimental groups not equivalent. Limited external validity.
        * Re-interview studies, ask respondents the same questions after a certain time. This is trying to study variance.
            * Assumption, there is no change in the true values over trials, or no memory effects. Also assumes that survey conditions are the same.
* Different sources of measurement error, how do we tackle it.
    * Interviewers effects (West and Bloom article) as a source of measurement error.
        * Ways that interviewers can affect measurement error
            * 1. falsification, interviewers answering surveys.
            * 2. Incorrect inclusion/exclusion of persons in the roster. For instance, adding household members that should not be added, such as a son that is studying and living elsewhere.
            * 3. Misunderstanding concepts, This can be due to the set of rules in the protocol, and if they are too complicated the interviewers may misinterpret.
            * 4. Reading issues, rephrasing questions by the interviewer.
            * 5. probing issues, not probing enough. If it is a common issue, you may need to retrain interviewers.
            * 6. Not clarifying the respondent's question adequately.
            * 7. inappropriate feedback. When interviewers provide feedback that is not neutral.
            * 8. data entry errors, adding an extra 0.
        * what is the impact of these differential behaviors? Variance, unless all interviewers are behaving the same way.
            * There is a correlation in the $y$ values and interviewers.
            * The hansen hurwitz-bershad model has a similar equation but they add the subscript of $t$, which is trial.
            * Kish model, $Y_{ijt} = X_{ijt} + M_j$, $X_{ijt} = X_i + e_{ijt}$.
                * Intraclass coefficient, variance of $M_j$ (error assoc)

<!-- page 24 -->

* deff, inflating the variance due to interviewers, m in **slide 33** is the average workload.
  * **REACTION**, as m (workload) goes up, and roh increases, deff goes up, even when intraclass is small.
    * Reducing the workload implies bringing more interviewers, more between variance?
* Determinants of rho
  * REACTION: Example of features of survey questions, is acquiescence that what spoke about in the book, is a feature of the survey and thus contributes to the variance in Y?
    * Ambiguous questions can also contribute to this.
  * Demographics produce affects when they correlated with the outcome variable.
    * **REACTION Slide 40**, social caste system, can we tie this to also what the book described as communication (response) stage in the components of response formation process, this seems like there is response editing happening by the respondent as a function of the interviewer and measure.
  * Summary: many determinants.
* Respondents as source of measurement error:
  * memory
    * failing to encode events, also events that are emotional can be suppressed.
    * Telescoping, backwards or forward, effects, events outside the reference period brought into the reference period.
  * Motivation – satisficing, respondents may not be motivated to evaluate an answer.
    * Krosnick 1991, satisficing = task difficulty / respondent ability * motivation.
  * Communication, social desirability.
    * Conversational interviewing, interviewer and respondent work together to understand question.
  * Knowledge, DK responses may backfire. For some questions, remove DK, or change the response from binary to scale.
* Questionnaire
  * wording issues, comprehension.
  * Tool usability, small font, scrolling ability, etc. Programming errors.

<!-- page 25 -->

**Processing issues in surveys**

* Question order leading to error.
  * Assimilation effects, judgment of a current question shifts based on a previous question.
  * contrast effect, judgment shifts in the opposite direction.
* Processing error - how to compute error rates.
* Editing, accountant's view: search for errors. These are like consistency checks.
  * Apply edit rules.
* Detection rules – apply edit rules.
  * Identify and manually review influential values.

Multiple sources of survey error

* Using AI for coding open-ended responses.
  * Sturgis 2025, 80% agreement
  * few shot are better than zero shot, proving both positive and negative examples.

Total survey error for found data:
