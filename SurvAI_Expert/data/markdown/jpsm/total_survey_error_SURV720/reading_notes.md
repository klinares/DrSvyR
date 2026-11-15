---
id: "jpsm/total_survey_error_SURV720/reading_notes"
source: "jpsm"
course: "SURV720"
course_title: "Total Survey Error and Data Quality I"
doc_type: "lecture"
title: "reading_notes"
original: "total_survey_error_SURV720/reading_notes.pdf"
pages: 34
sha256: "dd10ede04491dbd34c13837233139a30723e94f09414e4b910ebadc410d2eb63"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:27"
---

<!-- page 1 -->

For each article, summarize the key take away points from the following article in a few paragraphs and no more than a page. Ignore the abstract, and answer these questions:
What is the cause of the error?
What techniques can be used to reduce the error in practice?
What statistical models can be used to measure the error source? For papers.
Does it tell me how to reduce the error.

<!-- page 2 -->

**Biemer and Lyberg ch2**

# Chapter 2: Survey Process and Data Quality - Study Guide

## I. FUNDAMENTAL EQUATION

The central concept in survey quality measurement is the Mean Squared Error (MSE), which decomposes into two fundamental components: $\mathbf{MSE = Bias^2 + Variance}$.

Using Table 2.5 as a guide, we can write an expanded version of the MSE equation in (2.1). The squared-bias component can be expanded to include bias components for all the sources of error in the table that have a high risk of systematic error (i.e., specification bias, $\mathrm{B_{SPEC}}$; nonresponse bias, $\mathrm{B_{NR}}$; frame bias, $\mathrm{B_{FR}}$; measurement bias, $\mathrm{B_{MEAS}}$; and data processing bias, $\mathrm{B_{DP}}$). Note that these components of bias sum to produce the total bias component, called *bias*. Similarly, the variance component is the sum of the components for the major sources of variance in the table (i.e., sampling variance, $\mathrm{Var_{SAMP}}$; measurement variance, $\mathrm{Var_{MEAS}}$; and data processing variance, $\mathrm{Var_{DP}}$. Thus, the expanded version of the MSE formula showing components for all the major sources of bias and variance is as follows:

$$
\begin{aligned}
\mathrm{MSE} &= \mathrm{Bias}^2 + \mathrm{Variance} \\
&= (\mathrm{B_{SPEC}} + \mathrm{B_{NR}} + \mathrm{B_{FR}} + \mathrm{B_{MEAS}} + \mathrm{B_{DP}})^2 \\
&\quad + \mathrm{Var_{SAMP}} + \mathrm{Var_{MEAS}} + \mathrm{Var_{DP}} \qquad (2.2)
\end{aligned}
$$

## II. KEY DEFINITIONS

**Total survey error** represents the difference between a survey estimate and the true population parameter value. This total error consists of two main components: sampling error and nonsampling error.

**Sampling error** arises solely from observing a sample rather than conducting a complete census. This error type is controllable through sample size adjustments and primarily affects the variance component of MSE. As sample size increases, sampling error decreases predictably, reaching zero when the sample equals the population.

**Nonsampling error** encompasses all other error sources in the survey process, including mistakes in data collection, processing, and measurement. Unlike sampling error, nonsampling error is often

<!-- page 3 -->

unpredictable and may actually increase with larger sample sizes due to operational complexity and quality control challenges.

**Variable errors** are random, omnidirectional errors that tend to cancel out when averaged across observations. These errors create "noise" in the data and primarily affect the variance component of MSE. In linear estimates like means and totals, variable errors tend to be non-biasing because positive and negative errors offset each other.

**Systematic errors** consistently push estimates in one direction, creating bias in survey results. These errors do not cancel out regardless of sample size and can be more damaging than variable errors for descriptive statistics. Systematic errors arise from consistent problems in the survey process, such as poorly worded questions or frame coverage issues.

## III. THE SURVEY PROCESS

The survey process consists of eight interconnected stages that proceed sequentially but often require iteration. The process begins with **determining research objectives**, where key questions and parameters are clearly defined in collaboration with stakeholders. This leads to **defining the target population**, specifying exact inclusion and exclusion criteria for the study.

The **mode of administration selection** involves choosing between face-to-face, telephone, mail, or web data collection, considering cost, quality, and timing trade-offs. **Questionnaire development** operationalizes research concepts into specific questions, ensuring alignment with research objectives. The **sampling design** stage specifies the frame, selection method, and sample size needed to achieve desired precision.

**Data collection and processing planning** establishes protocols, quality control procedures, and workflows for fielding the survey and handling the data. The actual **data collection and processing** implements these plans, including interviewer training, respondent contact, and data entry. Finally, **estimation and analysis** produces survey estimates and assesses their quality through variance estimation and bias evaluation.

This process is inherently iterative. Constraints discovered at later stages often necessitate revisiting earlier decisions. For example, budget limitations identified during sampling design might require reconsidering the mode of administration or reducing questionnaire length.

## IV. ERROR SOURCE TAXONOMY

Survey errors arise from five major sources, each with different risk profiles for systematic and variable error. **Specification error** occurs when survey questions fail to measure intended concepts, posing high systematic error risk but low variable error risk. This typically results from poor communication between researchers and questionnaire designers, leading to consistent measurement of the wrong construct.

**Frame error** involves problems with the sampling frame including omissions, duplications, and erroneous inclusions. Like specification error, frame problems primarily create systematic error through

<!-- page 4 -->

coverage bias, with minimal variable error impact. Noncoverage of specific population segments consistently biases estimates in predictable directions.

**Nonresponse error** encompasses unit nonresponse (entire questionnaire), item nonresponse (specific questions), and incomplete responses. This source primarily generates systematic error through selection bias, as respondents and nonrespondents typically differ on key characteristics. The bias magnitude depends on both the response rate and the difference between respondent and nonrespondent characteristics.

**Measurement error** arises from multiple sources including respondents, interviewers, questionnaires, and data collection settings. Uniquely, measurement error poses high risk for both systematic and variable error. Systematic measurement error might arise from leading questions, while variable measurement error could result from inconsistent interviewer behavior.

**Processing error** includes mistakes in editing, coding, data entry, weighting, and tabulation. Like measurement error, processing errors can be both systematic (consistent coding mistakes) and variable (random data entry errors). The dual nature of these error sources complicates their control and assessment.

**Sampling error**, unlike the nonsampling sources above, primarily affects variance rather than bias when proper probability sampling methods are used. This error source is well-understood theoretically and controllable through sample size, making it fundamentally different from nonsampling errors.

## V. MODE EFFECTS ON ERROR

Different data collection modes create distinct error profiles that must be considered in survey design. **Face-to-face interviewing** typically achieves the highest response rates, minimizing nonresponse bias. However, this mode introduces substantial interviewer variance through interviewer effects on responses. The high cost per interview necessitates smaller sample sizes, increasing sampling variance. Additionally, interviewer presence may increase social desirability bias for sensitive topics.

**Telephone interviewing** represents a middle ground with moderate nonresponse rates and interviewer effects. Frame coverage issues arise from households without telephones or with only cellular phones (depending on the frame used). Costs are lower than face-to-face interviewing, allowing larger samples, but visual aids cannot be used and interview length is constrained.

**Mail and self-administered modes** eliminate interviewer effects entirely, removing interviewer variance and reducing social desirability bias. The low cost per response allows maximum sample sizes, minimizing sampling variance. However, these modes typically suffer from high nonresponse rates creating substantial bias risk. Additionally, there's no interviewer assistance for complex questions, potentially increasing measurement error from misunderstanding.

## VI. CRITICAL MEASUREMENT CONCEPTS

The **reliability ratio** quantifies the impact of variable error on data quality, calculated as the ratio of true value variance to observed value variance. This ratio ranges from 0 (completely unreliable) to 1

<!-- page 5 -->

(perfectly reliable), with values below 0.5 indicating that variable error variance exceeds true variance in the population. Reliability assessment typically requires special studies such as reinterviews or repeated measurements.

**Specification error** manifests in various ways that compromise data validity. Common examples include asking about "selling price" when the concept of interest is "market value," or failing to specify exclusions like capital improvements when measuring land values. These errors occur when the survey question's implied concept differs from the research concept, often due to inadequate communication during questionnaire development.

**Frame errors** take three primary forms that affect coverage and selection probabilities. Omissions occur when population members are absent from the frame, creating undercoverage bias. Duplications list some members multiple times, affecting selection probabilities unless properly handled. Erroneous inclusions add non-target population members to the frame, requiring screening during data collection or creating contamination in estimates.

## VII. SURVEY DESIGN PRINCIPLES

The fundamental objective of survey design is minimizing MSE subject to resource constraints including budget, timeline, and available expertise. This requires balancing multiple error sources rather than minimizing any single source, as reducing one error type often increases others given fixed resources.

For descriptive statistics (means, totals, proportions), systematic error generally takes priority over variable error because bias doesn't decrease with sample size while variance does. This principle guides resource allocation decisions, suggesting investment in reducing frame coverage problems, nonresponse, and measurement bias before addressing variable error sources.

Survey design inherently involves trade-offs among competing quality dimensions. Increasing sample size reduces sampling variance but may compromise data quality through reduced interviewer training or supervision. Improving response rates through intensive follow-up may delay results beyond usefulness. Higher measurement quality through face-to-face interviewing may necessitate smaller samples due to cost. These trade-offs must be explicitly considered and balanced based on survey objectives and constraints.

A critical fallacy in survey design is choosing based solely on sampling error or variance, ignoring nonsampling error contributions. This approach often leads to suboptimal designs that minimize the most visible error component while allowing larger errors from other sources.

## VIII. PRACTICAL APPLICATIONS

Comparing alternative survey designs requires systematic assessment of all error components. First, estimate bias contributions from each error source based on previous studies, literature, or pilot tests. Second, estimate variance components including both sampling and nonsampling variance. Third, calculate total MSE by summing squared biases and variances. Finally, select the design minimizing total MSE within resource constraints.

<!-- page 6 -->

Error assessment methods vary by error type and feasibility. **Reinterview studies** measure reliability by repeating interviews with a subsample, revealing variable error magnitude. **Record checks** compare survey responses to administrative records or other gold-standard sources, quantifying measurement bias. **Postenumeration surveys** following censuses assess coverage error through independent enumeration. **Behavior coding** of interviews identifies problematic questions causing measurement error. **Response analysis** compares respondent and nonrespondent characteristics using frame data or follow-up studies.

## IX. KEY COMPUTATIONAL METHODS

MSE can be computed two equivalent ways that provide different insights. **Method 1** directly calculates MSE as the average squared difference between estimates and true values across survey replications: $\text{MSE} = \text{Average}[(\text{Estimate} - \text{True Value})^2]$. This method requires knowing true values and having multiple survey replications, making it primarily conceptual.

**Method 2** decomposes MSE into interpretable components: $\text{MSE} = \text{Bias}^2 + \text{Variance}$, where $\text{Bias} = \text{Average}(\text{Estimates}) - \text{True Value}$ and $\text{Variance} = \text{Average}[(\text{Estimate} - \text{Average}(\text{Estimates}))^2]$. This decomposition enables separate assessment of systematic and variable error contributions, facilitating targeted error reduction strategies. The variance component can be estimated without knowing true values, while bias estimation requires external validation data.

## X. ESSENTIAL TAKEAWAYS

Understanding that nonsampling error often exceeds sampling error in impact fundamentally changes survey design priorities. While sampling error is well-understood and easily calculated, nonsampling errors are complex, interrelated, and often dominant in determining data quality. This reality necessitates comprehensive error assessment beyond traditional sampling variance calculations.

The total error approach is essential for optimal survey design because focusing on individual error sources in isolation leads to suboptimal decisions. The interconnected nature of error sources means reducing one type often increases others, requiring holistic optimization rather than sequential minimization.

The behavior of different error types with increasing sample size has critical implications. Systematic errors don't average out with larger samples and may actually increase due to operational challenges. Variable errors do average out in linear estimates, following predictable patterns. This differential behavior means that simply increasing sample size may not improve, and could worsen, total survey error.

The MSE framework provides a unified metric combining both systematic and variable error into a single quality measure, enabling rational comparison of design alternatives. Survey design fundamentally involves managing trade-offs across multiple error sources within resource constraints, requiring careful consideration of how design decisions affect each error component and their collective impact on data quality.

<!-- page 7 -->

**Iannacchione, V. G. (2011). The changing role of address-based sampling in survey research.**

**Public Opinion Quarterly, 75, 3, 556-575.**

### 1. Error Causes

The primary source of undercoverage in Address-Based Sampling (ABS) stems from two issues. First, unlocatable mailing addresses create gaps in coverage, particularly P.O. boxes, rural route boxes, and simplified addresses that lack physical location information. Rural areas face disproportionate challenges, with 1.68 million households receiving mail only through P.O. boxes as of 2010. Second, geocoding errors occur when converting addresses to geographic coordinates, causing both undercoverage (missing addresses inside targeted segments) and overcoverage (including addresses outside segments). These errors are more prevalent in rural areas. For mail surveys, overcoverage becomes the dominant problem due to households maintaining multiple mail delivery points (averaging 1.24 ways to receive mail for P.O. box holders).

### 2. Error Reduction Techniques

The article details several practical approaches to reduce coverage errors. The Check for Housing Units Missed (CHUM) procedure has interviewers systematically identify missed units using predetermined paths, achieving a 5.1 percentage point coverage increase in the 2008 American National Election Study. Modified Half-Open Interval procedures leverage postal delivery routes to locate missed units. Dependent listing involves pre-survey canvassing, though the article notes this suffers from enumerator failure-to-add and failure-to-delete errors. Hybrid approaches combine ABS with area sampling or property tax records for problematic segments. Operationally, researchers should purchase addresses from CDS-licensed vendors rather than DSF2-only vendors, explicitly request inclusion of do-not-mail addresses, and use postal geography instead of Census geography when geocoding accuracy is questionable.

### 3. Statistical Measurement Models

The article provides limited detail on statistical modeling approaches. It references validation studies that estimate net undercoverage rates and correlation analyses between vendor-appended demographics and survey responses (reporting Pearson correlations of 0.608-0.675 for variables like homeownership). However, the article does not present specific statistical models for quantifying error sources, focusing instead on empirical coverage comparisons across geographic areas and data collection modes.

### 4. Error Reduction Guidance

Yes, the article extensively describes practical error reduction methods with documented effectiveness. The cost-benefit analysis is particularly compelling: ABS frames cost approximately 10% of traditional area sampling while achieving comparable coverage when supplementation procedures are applied. The article emphasizes that technique selection should align with survey mode, target population, and available resources. Urban areas achieve nearly complete coverage with basic ABS, while rural areas require hybrid approaches. The declining prevalence of problematic address types (rural route boxes decreased from 4.2 million to 380,000 between 2002-2010) suggests coverage will continue improving, though the article acknowledges rural areas remain challenging despite these trends.

<!-- page 8 -->

**Harter, R., & English, N. (2018). Overview of three field methods for improving coverage of address-based samples for in-person interviews. *Journal of Survey Statistics and Methodology*, 6(3), 360-375.**

**Cause of the Error:** The primary error source is **coverage error** in address-based sampling (ABS) frames used for in-person surveys. This occurs because:

* Address frames based on US Postal Service lists have shortcomings in areas with non-locatable addresses (PO Boxes, Rural Route Boxes, simplified addresses)
* ABS frames suffer from undercoverage in rural areas where many addresses cannot be physically located
* Housing units may be erroneously geocoded to wrong census blocks/segments
* New construction and missed housing units during initial frame creation
* Some addresses don't exist or aren't part of the selected area

**Techniques to Reduce Error in Practice:** The paper presents three main field methods:

* **Enhanced Listing**: Complete frame updating prior to sample selection by field personnel traversing all blocks in sample segments
* **CHUM (Check for Housing Units Missed)**: Post-sampling procedure with two components - searching intervals after selected housing units and searching sample blocks
* **ACE (Address Coverage Enhancement)**: Area-linkage approach that subsamples segments for field review, performed when first housing unit in frame order is selected

**Statistical Models to Measure Error:** The paper focuses primarily on operational methods rather than statistical models for measuring coverage error. It references the **Generalized Weight Share Method (GWSM)** for calculating appropriate weights to account for unequal probabilities of selection, but doesn't elaborate on specific statistical models for quantifying coverage error rates.

**Error Reduction Guidance:** Yes, the paper provides practical guidance for reducing coverage error. It recommends dividing selected area segments into groups based on expected coverage rates and applying different methods for different coverage levels. For segments with high coverage, no supplementation may be needed; for extremely low coverage areas, traditional field enumeration might be necessary. The choice between methods depends on study requirements for coverage, timeliness, ease of implementation, control over sample size, and available resources. The paper emphasizes that adequate training is essential for success with any of these methods.

<!-- page 9 -->

**Marpsat, M., & Razafindratsima, N. (2010). Survey methods for hard-to-reach populations: introduction to the special issue. *Methodological Innovations Online*, 5(2), 3-16.**

**Cause of the Error:** The primary error source is **coverage error** and **selection bias** in hard-to-reach populations due to:

* Populations having relatively low numbers, making general population surveys expensive
* Members being hard to identify or reluctant to disclose membership
* No sampling frame or incomplete frames yielding biased results
* Populations engaging in stigmatized, illicit, or sensitive behaviors
* Unknown behavioral patterns leading to poor choice of contact locations
* Traditional sampling methods failing to reach hidden or marginalized groups

**Techniques to Reduce Error in Practice:** The paper presents three main methods for hard-to-reach populations:

* **Time-Location Sampling (TLS):** Sample places where target population visits at specific times, using exhaustive lists of locations and the Generalized Weight Share Method (GWSM) for weighting
* **Respondent Driven Sampling (RDS):** Chain-referral method where initial participants recruit others using coupons, with payment incentives and weighting based on network size
* **Capture-Recapture:** Multiple independent observations to estimate population size using the formula $N = (n \times m)/M$, where individuals are identified across different "captures"

**Statistical Models to Measure Error:**

* **Generalized Weight Share Method (GWSM)** for TLS to account for unequal attendance patterns
* **Network size weighting** for RDS to control for varying recruitment probabilities
* **Log-linear modeling** for capture-recapture to address violations of basic model assumptions
* **Post-stratification methods** to control for homophilia effects in RDS

**Error Reduction Guidance:** Yes, the paper provides comprehensive guidance for reducing coverage error. It emphasizes that method selection depends on population characteristics (whether they frequent specific places) and study objectives. For TLS, establish exhaustive location lists and proper weighting. For RDS, ensure traceability of recruitment chains, limit recruitments per person, and collect network size data. For capture-recapture, ensure independence of observations and population stability. The paper also recommends preliminary qualitative investigations to understand the target population and choose appropriate methods, and notes that methods can be combined (e.g., using TLS or RDS as sources in capture-recapture studies).

<!-- page 10 -->

**Groves, R. M. (2006). “Nonresponse rates and Nonresponse Bias in Household Surveys,” Public Opinion Quarterly, 70:5, 646-675.**

**Cause of the Error:** The fundamental cause of nonresponse bias is the correlation between response propensity (likelihood of responding) and the survey variables being measured. The bias occurs when certain types of people systematically fail to respond, and these non-respondents differ from respondents on key survey measures. The paper identifies this mathematically as $\sigma y\rho$ - the covariance between the survey variable ($y$) and response propensity ($\rho$). Importantly, nonresponse bias varies across different statistics within the same survey, depending on how correlated each variable is with the propensity to respond.

**Techniques to Reduce the Error in Practice:** The paper emphasizes "informed pursuit of high response rates" rather than blind maximization. Key practical approaches include:

* Collecting auxiliary variables on both respondents and nonrespondents to guide targeted efforts at balancing response rates across key subgroups
* Using postsurvey adjustments (weighting class adjustments, raking, calibration methods, propensity models) to compensate for differential nonresponse
* Employing multiple nonresponse bias assessment methods simultaneously since each has limitations
* Identifying groups with low base response propensities and targeting them with appropriate incentives or design features
* Being strategic about which nonresponse to reduce - reducing nonresponse among groups distinctive on survey variables can actually increase bias

**Statistical Models to Measure the Error:** The paper presents several expressions for nonresponse bias. The basic model shows bias as: $\text{Bias} = (M/N)(\bar{Y}r - \bar{Y}m)$, where $M/N$ is the nonresponse rate and $(\bar{Y}r - \bar{Y}m)$ is the difference between respondent and nonrespondent means. A more sophisticated stochastic model approximates bias as $\sigma y\rho/\bar{\rho}$. The paper also provides a meta-analysis of 30 studies showing the mean absolute relative bias is about 9% of the full sample estimate, with a correlation of only 0.33 between nonresponse rates and bias magnitude.

**Does it tell how to reduce the error?** Yes, but with important caveats. The paper demonstrates that simply reducing nonresponse rates doesn't necessarily reduce bias - it depends on who is brought into the respondent pool. The most effective bias reduction requires: (1) identifying which groups are underrepresented using auxiliary data, (2) targeting these specific groups with tailored approaches, and (3) using appropriate postsurvey adjustments based on variables correlated with both response propensity and survey outcomes. The paper warns that some methods of increasing response rates (like certain incentives) can actually increase bias if they disproportionately attract people with unusual values on survey variables.

<!-- page 11 -->

**Curtin, R., Presser, S., and Singer, E. (2000). “The Effects of Response Rate Changes on the Index of Consumer Sentiment.” Public Opinion Quarterly, 64:4, 413-428.**

**Cause of the Error:** The error stems from differential nonresponse patterns between easier and harder-to-reach respondents. The study finds that respondents requiring more calls to complete interviews tend to be younger and more affluent (and thus more optimistic about the economy), while those requiring refusal conversion tend to be older and less educated (and thus less optimistic). These systematic differences create potential bias because the response propensity is correlated with the survey variables of interest—in this case, consumer sentiment about the economy.

**Techniques to Reduce the Error in Practice:** The paper provides several practical insights:

* Making multiple call attempts (the study shows calls increased from 3.9 in 1979 to 7.9 in 1996)
* Converting initial refusals through specially trained interviewers (refusal conversions increased from 7.4% to 14.6% over the study period)
* Strategic scheduling of calls during productive times, especially for limited-call designs
* Using poststratification weights to adjust for demographic differences between respondents and nonrespondents
* Recognizing that for time series analysis (tracking changes over time), nonresponse bias may be less problematic if it remains constant over time

**Statistical Models to Measure the Error:** The study employs several measurement approaches:

* Direct comparison of Index of Consumer Sentiment (ICS) values between initial cooperators vs. refusal conversions and between early vs. late call respondents
* OLS regression models controlling for demographic characteristics (income, age, education, sex, race) and time trends
* Correlation analyses between full-sample and truncated-sample estimates
* Significance testing of differences at various aggregation levels (monthly, quarterly, yearly)
* Simulation of lower response rates by systematically excluding harder-to-reach cases

**Does it tell how to reduce the error?** The paper provides indirect guidance on error reduction. While it doesn't offer a prescriptive framework, it demonstrates that:

1. **For cross-sectional estimates:** The impact of excluding difficult cases is generally small for typical monthly samples (hundreds of cases) but becomes more visible with larger samples. This suggests that maintaining higher response rates becomes more important as sample sizes increase.
2. **For time series analysis:** The paper shows that estimates of change over time are remarkably robust to nonresponse bias, even when absolute levels differ. This is because harder and easier respondents tend to change at similar rates over time.
3. **Practical tradeoff:** The findings suggest that for many applications, especially time series analysis with moderate sample sizes, the extensive effort to achieve very high response rates (70% vs. 50%) may not substantially improve estimate quality. However, this conclusion is specific to consumer sentiment measures and may not generalize to all survey topics.

<!-- page 12 -->

The key insight is that the relationship between response rate and bias is not straightforward—it depends on sample size, whether you're measuring levels or changes, and the specific variables being studied.

<!-- page 13 -->

**Amaya, A., and Presser, S. (2016). “Nonresponse bias for univariate and multivariate estimates of social activities and roles.” Public opinion quarterly, 81(1), 1-36.**

**Cause of the Error:** The error stems from the social integration hypothesis - individuals who are more socially integrated (participating in various social activities and relationships) are more likely to respond to surveys. This creates systematic bias because survey estimates of social activities become upwardly biased when socially isolated individuals don't respond. The paper identifies three mechanisms: (1) socially integrated individuals perceive survey participation as consistent with group expectations, (2) they've internalized social norms including cooperation, and (3) they perceive greater benefits from survey participation.

**Techniques to Reduce the Error in Practice:** While the paper focuses primarily on measuring rather than reducing bias, it implies several practical approaches:

* Recognize that bias varies across different social activity measures within the same survey
* Consider that political/civic activities may suffer from higher bias than other social activities
* Understand that multivariate models may be less affected than univariate estimates
* Use rich frame data when available to identify and target less socially integrated individuals
* Apply appropriate statistical adjustments knowing that the bias direction is generally predictable (overestimation of social activities)

**Statistical Models to Measure the Error:** The paper employs several measurement approaches:

* Direct comparison of full sample vs. respondent estimates using replication methods to account for covariance
* T-tests adjusted for dependent samples using replicate weights
* Chi-squared tests for categorical variables with variance adjustments
* Logit models comparing coefficients between full sample and respondent models
* False Discovery Rate (FDR) adjustments for multiple testing The analysis found 24 of 30 univariate estimates showed upward bias as predicted, with relative bias up to 23.6%.

**Does it tell how to reduce the error?** The paper provides limited direct guidance on error reduction, focusing instead on measurement and documentation of bias patterns. However, it suggests that understanding which variables are most susceptible to bias (civic/political activities showed trends toward higher bias) could inform targeted data collection strategies. The finding that multivariate models often maintain similar significance levels despite coefficient bias suggests that some analytical uses may be more robust to this type of nonresponse bias. The authors call for developing both better data collection methods targeting less integrated individuals and improved adjustment methods incorporating factors beyond standard demographics.

<!-- page 14 -->

**Kreuter, F., Olson, K., Wagner, J., Yan, T., Ezzati-Rice, T. M., Casas-Cordero, C., ... and Raghunathan, T. E. (2010). Using proxy measures and other correlates of survey outcomes to adjust for non-response: examples from multiple surveys. Journal of the Royal Statistical Society: Series A (Statistics in Society), 173(2), 389-407.**

* Non-response weighting depends on variable used in constructing the non-respoonse weight and have two properties that these variables should be predictive of:
    * an individual’s probability of responding to a survey request.
    * And, predictive of the outcome variable.
        * Example of external variables, geographic or neighborhood variables.
* Z variables to be used for nonresponse weighting include:
    * paradata from field such as interviewer observations and contact record data.
        * i.e., type of housing, or presence of door intercoms.
* For the 5 surveys in the study, auxiliary variables at best showed modest usefulness for non-response adjustment.
    * In other words, it is very difficult to find a single effective auxiliary variable Z for non-response adjustment.
    * **Reaction**: For some of the surveys where these auxiliary variables depend on interviewers’ evaluation of the context, for instance properly recording the house dwelling type or recognize door intercoms, how much does measurement error in the Z variables are related to interviewer observations and account for some of the weak correlations? Alternatively, public records may exist on the home dwelling type that can be used to validate interviewer observations, yet this is not the case for every auxiliary variable.
* Non-response adjustment weighting.
    * **Reaction**: These weights compensate for the differential probability of participating in the survey. The weighting class adjustment is the weight inverse of the response rate within a subgroup and response propensity weighting. There is a logistic regression model that predicts the probability of responding, and the inverse of the predicted probability becomes the weight. These weights are hoping to reduce non-response bias in the survey estimates by up-weighting respondents who share characteristics with non-respondents, not taking Y value into account. .
    * Effects on estimates: adding z variables to existing weighting models changed the final survey estimates, and the change size was correlated between the new weights and outcome.
    * Effects on bias and variance:

<!-- page 15 -->

* bias reduction, the new weights reduced non-response bias, moving estimates closer to true values. This includes increasing estimation of socially undesirable behaviors.
* Variance reduction: variance increased slightly with the inclusion of new variables, this is a trade-off between bias and variance.
    * **Reaction**: This is the most encouraging part of the paper for me. Seeing a tangible reduction in non-response bias in the MEPS and UMTRI studies—without a major variance penalty—provides strong empirical support for the search for these kinds of auxiliary variables. However, it also highlights a critical dilemma for practitioners: these two surveys were special cases where bias could actually be assessed. In most surveys, we don't have a gold-standard benchmark to validate our adjustments against, particularly in developing countries. What should be the process for adopting a new weighting scheme in the more common scenario where bias reduction cannot be directly measured? Zero in on a few key Y variables. Look at auxiliary variables, a mixture of paradata and maybe external, alongside key Y variables, think matrix. Look at correlations of Z variables with Y.
* Key take away from the discussion section:
    * In practice, it is challenging to find auxiliary variables that are strongly correlated with both the probability of responding and the survey's key outcome variables; the observed correlations are often weak.
    * Despite these weak correlations, including these variables in weighting adjustments can successfully change estimates and lead to a tangible reduction in non-response bias without a large penalty in variance.
    * A single adjustment variable's effectiveness can vary greatly across different survey items, so relying on only a few may not improve all estimates.
    * Therefore, the authors recommend that researchers shift their focus from finding only predictors of survey participation to deliberately identifying and including auxiliary variables that are good proxies for the key survey outcomes themselves.

<!-- page 16 -->

**West, B. T., Sakshaug, J. W., & Aurelien, G. A. S. (2016). How big of a problem is analytic error in secondary analyses of survey data?. PLoS One, 11(6), e0158120.**

This study finds that **analytic error**—the misuse of statistical methods when analyzing complex survey data—is a widespread and serious problem. Researchers frequently fail to account for design features like sampling weights and stratification, which can lead to substantially biased results and incorrect scientific conclusions. The prevalence of these errors, the authors note, has not improved over time.

---

## What is the cause of the error?

The primary cause is that many secondary data analysts **lack the specialized training** required for complex survey data. They incorrectly apply standard statistical methods intended for simple random samples, leading them to ignore crucial design elements. This results in flawed estimates of population characteristics and invalid tests of significance.

---

## How can the error be reduced?

Yes, the article provides clear guidance on reducing this error.

* **Analytically:** Researchers must use appropriate methods that account for the survey's design. This includes the **design-based approach** (using sampling weights and specialized variance estimation) or a properly specified **model-based approach** (including design features as predictors in the model).
* **Procedurally:** The authors advocate for systemic changes, such as having journals use **expert statistical reviewers**, establish **clearer submission guidelines** for survey analysis, and encourage better **education on survey statistics** in applied fields.

---

## How can the error be measured?

The paper doesn't model the cause of the error but instead quantifies its **prevalence and impact**. It uses logistic regression to show how common analytic errors are in published research. To demonstrate the impact, it compares results from a correct analysis to incorrect ones, measuring the resulting **bias in estimates** and the **distortion of standard errors** (misspecification effects).

<!-- page 17 -->

**Brick, J. M., and Kalton, G. (1996). Handling missing data in survey research. Statistical Methods in Medical Research, 5, 215 – 238.**

This paper reviews the primary methods survey researchers use to handle missing data: **weighting adjustments** and **imputation**. The authors explain that while the best solution is to minimize missing data during collection, these statistical techniques are essential for reducing the bias that missing data can introduce into survey results.

---

## What causes the error?

The "error" caused by missing data is **bias in survey estimates**. This bias arises when the people with missing data are systematically different from those who provided complete data. Simply ignoring missing records is not a neutral act; it implicitly assumes the data are **Missing Completely at Random (MCAR)**, meaning the missingness is just a fluke. This is rarely a safe assumption.

The paper identifies three main sources of missing data:

1. **Noncoverage**: People in the target population who were never on the list to be sampled in the first place.
2. **Total (Unit) Nonresponse**: A sampled person who provides no information at all (e.g., refuses the survey).
3. **Item Nonresponse**: A person who participates in the survey but skips some questions.

---

## What techniques can reduce the error?

Yes, the paper details two main families of techniques to compensate for missing data and reduce bias. The choice depends on the type of missing data.

### Weighting Adjustments

Weighting is the standard method for handling **total nonresponse** and **noncoverage**. The basic idea is to give more influence (a higher weight) to the respondents who are similar to the people with missing data. Key methods include:

* **Weighting Class Adjustments**: The sample is divided into groups based on known characteristics (e.g., age, region). The weights for respondents within each group are increased to account for the nonrespondents in that same group.
* **Poststratification**: The weights are adjusted so that the sample distribution for certain variables (e.g., age, sex, race) matches known totals from an external, reliable source like a census. This is particularly effective for correcting noncoverage.

<!-- page 18 -->

* **Raking**: An iterative method that adjusts weights to match multiple marginal population totals when the fully cross-classified totals are unavailable.

### Imputation

Imputation is the standard method for handling **item nonresponse**. It involves filling in a plausible value for each missing answer. This creates a complete, rectangular dataset that is easier to analyze.

* **Hot-Deck Imputation**: A missing value for a "recipient" is replaced with an actual value from a similar responding unit, known as the "donor."

* **Regression Imputation**: A statistical model is built to predict the missing value based on other variables the person did answer. To avoid distorting the data's natural variability, **stochastic** methods that add a random error component to the prediction are generally preferred over deterministic ones.

* **Multiple Imputation**: This is a more advanced technique where the imputation process is repeated several times (e.g., 3-5 times) to create multiple "complete" datasets. Analyzing these datasets together provides more accurate estimates and, crucially, allows for valid calculation of standard errors that account for the uncertainty of the imputation.

---

## What statistical models are used?

The techniques described above are justified by underlying statistical models about the nature of the missing data.

1. **Models for the Missing Data Mechanism**: The key assumption behind most modern adjustment techniques is that the data are **Missing at Random (MAR)**. This means that the probability of a value being missing can be explained by other *observed* data, but not by the missing value itself. For example, if older people are less likely to report their income, the missingness is MAR as long as you account for age in your adjustment. This is a much weaker and more realistic assumption than MCAR.

2. **Models for Adjustment and Imputation**: The techniques themselves often use explicit statistical models. For instance, **response propensity modeling** uses logistic regression to predict the probability that a person will respond, and the inverse of this probability can be used as a weight. Similarly, regression imputation uses a model to predict the missing values.

<!-- page 19 -->

Little, R. J., and Vartivarian, S. L. (2005). "Does Weighting for Nonresponse Increase the Variance of Survey Means?" Survey Methodology, 31, 161-168.

This paper challenges the common wisdom that nonresponse weighting is a simple **bias-variance trade-off**. The authors argue that the belief that weighting always increases variance is an oversimplification. Their key finding is that when adjustment variables are chosen correctly, weighting can **reduce both bias and variance**, leading to more accurate survey estimates.

---

## What is the cause of the error?

The initial error is **nonresponse bias**, which happens when the people who don't respond to a survey are different from those who do. The standard technique to fix this is weighting. However, this fix is often thought to introduce a new "error": a significant **increase in variance**. This idea comes from the fact that giving some people much larger weights than others can make the final estimates less stable. The authors argue this is only true when the variables used for weighting are poor predictors of the survey outcome.

---

## How can the error be reduced effectively?

The article provides a very clear and practical recommendation for reducing error. The key is in the selection of variables used to create the weighting adjustments (the "adjustment cells").

The single most important characteristic of an adjustment variable is that it must be **highly predictive of the survey outcomes**. While it's also helpful if the variable predicts the likelihood of responding (the "response propensity"), this is a secondary goal.

In short, you get the biggest improvement in your data when your weighting variables are strongly correlated with the questions you are actually asking in the survey. When this is true, weighting not only corrects for bias but can also *decrease* the variance of the estimate, contrary to the conventional wisdom.

---

## How is the error modeled and measured?

The authors use the **Mean Squared Error (MSE)** as their primary tool for evaluation, since it combines both bias and variance into a single measure of an estimator's total error.

They derive and analyze mathematical formulas for the MSE of both the weighted and unweighted means. Their analysis shows precisely how the variance of a weighted mean is affected by the adjustment variables. They demonstrate that when an adjustment variable is strongly related to the survey outcome, it reduces a key component of the total variance, often by more than enough to offset the increase in variance from the unequal weights.

<!-- page 20 -->

They also propose a sample-based formula that researchers can use to **estimate the MSE** of both the weighted and unweighted means from their own data. This allows an analyst to empirically check whether weighting is likely to improve the overall accuracy for any specific variable in their survey.

<!-- page 21 -->

**Bohrnstedt, George W. (1983). “Measurement.” In Rossi, P. H., Wright, J. D., and Anderson, A. B. (eds.), Handbook of Survey Research. New York: Academic Press. Sections 3.0-3.5 (pp. 69- 79)**

* Measurement is the assignment of numbers to observed phenomena according to certain rules.
    * Measurement error is the difference between the observed and true value.
        * Psychologists do not view t true score as actually true, but latent.
        * Survey researchers view t as a behavioral response (platonic true score), and physiological states inferred indirectly, in this case the relationship between a true score and the observed variable.
    * The errors of measurement for classical true score t are assumed to be uncorrelated with the true score.
    * The observed variance is the sum of the true score and error variances.
    * Socially desirable responses are a classic example for measurement error and bias.
* Reliability (consistency) refers to the extent to which the variance of an observed x is due to random sources or to noise, defined as a ratio variance in x such as p_x = sigma_sqr_r / sigma_sqr_x, and the square root is the correlation.
    * This correlation is also called the theoretical validity of a measure x because it is a measure of how well an observed item correlates with some latent construct.
        * Theoretical validity (accuracy) is different from empirical validity where this is the correlation between x and a second observed variable y, and only assessed in relation to an observed measure.
    * A biased measure can still be reliable. For example, a scale that weighs everything 5 pounds heavier than it really is, it generates the same values over but it is 5 pounds biased.
    * Errors in the dependent variable do not affect the true regression coefficient.
    * With the increase in related variables, our confidence in the true value increases under the assumption that the errors in measurement with be random.
* Measures of stability, historically the common method was test-retest correlating responses across time.

<!-- page 22 -->

**Ghiselli, B. E., Campbell, J. P., & Zedeck, S. (1981). Measurement theory for the behavioral sciences. Chapter 10 – pp. 265 - 267 (ending at “Criterion-related Validity”) and 280 (starting with “Construct Validity”) – 287.**

* Validity not as a property of a test, but as the "appropriateness of inferences from test scores.
* Criterion-Related Validity assesses a "predictor" against an external "criterion" (e.g., job performance).
* Content Validity relies on *expert judgment* to determine if the test is a representative sample* of the content domain.
* Construct Validity is used when no single criterion exists (e.g., "anxiety"). It involves accumulating a wide range of evidence to show the measure behaves as the underlying theory predicts.
* A key takeaway is that reliability sets the upper limit for validity. Validity can also be underestimated due to restriction of range.
* invalidity, which is a form of systematic error or bias.
* Systematic error is caused by the measure failing to capture the intended concept. This happens through:
  * Poor Domain Sampling (Content Invalidity):
  * The test items are not a representative sample of the entire domain.
  * Construct Contamination (Construct Invalidity): The test's scores are influenced by other constructs, such as "social desirability" or "vocabulary proficiency," that are irrelevant to the intended construct.
* The primary techniques for reducing systematic error (improving validity) are:
  * Using multiple expert judges to define the domain and vet items for content validity.
  * Improving the reliability (reducing random error) of both the predictor and the criterion measures.
* Validity Coefficient (Pearsonian $r_{xy}$). The main model to measure the degree of criterion-related validity.
* Multitrait-Multimethod Matrix (MTMM): A key model for diagnosing construct invalidity. It statistically separates variance due to the *construct* (convergent validity) from variance due to the measurement method (divergent validity).

<!-- page 23 -->

**Groves, Robert M. (2004). Survey Errors and Survey Costs, Chapter 1, Section 1.5**

* Classical true score (classical test theory) theory – all observational errors are viewed as joint characteristics of a related measure for $y\_i$.
  * Error terms are defined assuming certain characteristics of the measurement.
    * Assumption, If indicators were repeatedly administered, the mean of the errors would be 0 as they cancel each other out, so that the indicator is an unbiased measure of a characteristic.
  * Theoretical validity the correlation between the true score and the observed.
  * Reliability the ratio of the true score variance to the observed variance.
    * Assumption are that errors are uncorrelated.
    * The theoretical validity is the squared root of the reliability.
    * No measure can be valid without being reliable.
  * Validity can be estimated through multiple indicators called empirical validity.
    * Predictive validity refers to the correlation between one measure of a construct and another at a later time point.
    * Concurrent validity is the correlation between some criterion measured at the same time point.

<!-- page 24 -->

**Parry, H. J. & Crossley, H. M. (1950). Validity of responses to survey questions. Public Opinion Quarterly, 14(1), 61-80.**

* Discussion on validity, mainly predictive validity.
    * Attitudinal scales considered valid if they predict reasonable certainty.
    * Argues that criterion validity

<!-- page 25 -->

**West, B. T. & Blom, A. G. (2016). Explaining interviewer effects: A research synthesis. Journal of Survey Statistics and Methodology, 5(2), 175-211.**

### What Causes the Errors?

**1.** Coverage Errors:
* Inconsistent address listing methods in face-to-face surveys
* Variability in rostering procedures and household member definitions
* Some interviewers falsely reporting difficult households as ineligible to avoid work

**2.** Nonresponse Errors:
* Differences in interviewer persistence and calling strategies
* Variability in tailoring skills and maintaining interaction with respondents
* Interviewer attitudes, personalities, and self-confidence affecting cooperation rates
* Speech characteristics (speaking too fast/slow) during introductions

**3.** Measurement Errors:
* Race/ethnicity and gender of interviewer effects (respondents providing socially desirable answers)
* Variation in probing behaviors and interviewing styles
* Physical appearance and socioeconomic status cues from interviewers
* Excessive rapport-building attempts negatively affecting data quality

**4.** Processing Errors:
* Variability in coding open-ended responses during interviews
* Mishearing, mistyping, or entering wrong information
* Differential error rates in "live" field coding

### Techniques to Reduce Errors in Practice

**1.** Training and Standardization:
* Standardized interviewing techniques to minimize variance
* Improved training on address listing procedures
* Clear protocols for household rostering
* Training on optimal speech characteristics (moderate pace)

**2.** Recruitment and Retention:
* Tailoring training to address reluctance effectively
* Teaching persistence strategies for contact attempts
* Using "graceful exits" for refusals to improve conversion
* Evening calling strategies for better contact rates

**3.** Matching Strategies:
* Sociodemographic matching can improve response rates but may harm measurement quality
* Race/ethnicity matching shows mixed results depending on question sensitivity

<!-- page 26 -->

4. Behavioral Interventions:
   * Maintaining interaction without excessive rapport-building
   * Using concise introductions
   * Flexible interviewing for complex factual questions (but not attitudinal items)
   * Avoiding excessive probing that may introduce variance

### Statistical Models to Measure Error Sources

1. Multilevel Models:
   * Random interviewer effects (random intercepts) accounting for within-interviewer clustering
   * Intraclass correlation coefficients (ICC) to quantify interviewer variance
   * Formula: Variance inflation $\approx 1 + \rho_{\text{int}}(m - 1)$, where $m =$ average interviews per interviewer
2. Interpenetrated Designs:
   * Fully interpenetrated: random assignment of cases to interviewers
   * Quasi-interpenetrated: algorithm-based random assignment in telephone surveys
   * Partially interpenetrated: pooling adjacent areas with multiple interviewers randomly assigned
3. Cross-classified Models:
   * Separating interviewer effects from area effects in face-to-face surveys
   * Including both interviewer and area random effects
4. Mediation Analysis:
   * Testing whether skills/behaviors mediate relationships between interviewer characteristics and outcomes
   * Example: Experience $\rightarrow$ Tailoring skills $\rightarrow$ Response rates

### Does It Tell How to Reduce Errors?

1. Direct Interventions:
   * Focus on modifiable mediators (attitudes, skills, behaviors) rather than fixed characteristics
   * Target training on identified skill gaps (tailoring, maintaining interaction)
   * Implement continuous quality monitoring using paradata
2. Survey Design Approaches:
   * Use interpenetrated designs when feasible to separate interviewer from area effects
   * Consider trade-offs between bias reduction and variance when choosing interviewing techniques
   * Design questions to minimize opportunities for interviewer intervention
3. Organizational Strategies:
   * Balance evaluation metrics (not just response rates)

<!-- page 27 -->

* Manage workload to prevent shortcuts from experienced interviewers
* Select and retain interviewers with favorable characteristics (optimism, persistence)

4. Key Recommendations:
   * Identify and train on specific mediating factors rather than relying on demographic characteristics
   * Recognize potential negative covariances (e.g., techniques that increase response rates may harm measurement quality)
   * Use the organizing model to systematically identify intervention points

The authors emphasize that explaining interviewer effects requires understanding the complex interplay of background characteristics, mediating factors (attitudes, skills, behaviors), and moderating influences (question features, respondent characteristics). Their organizing model provides a framework for developing targeted interventions to minimize interviewer-introduced errors across all stages of the survey process.

<!-- page 28 -->

**Federal Committee on Statistical Methodology. (2001). Measuring and Reporting Sources of Error in Surveys. Chapter 6, Sections 6.1-6.2 (p 1-12).**

The document identifies **five primary sources of error** in surveys:

1. **Sampling Error**: Variability that occurs by chance because a sample rather than the entire population is surveyed. This is the most well-known and frequently reported error source.
2. **Nonresponse Error**: Error from unsuccessful attempts to obtain information from eligible units. Causes include failure to contact respondents, refusals to participate, and inability to provide information. This reduces sample size, increases variance, and introduces potential bias.
3. **Coverage Error**: Failure to include some population units in the sampling frame (undercoverage) or including units more than once (overcoverage). The primary cause is inadequate or incomplete sampling frames that don't properly represent the target population.
4. **Measurement Error**: Differences between observed and true values, stemming from four sources:
   - Questionnaire design issues
   - Data collection method effects
   - Interviewer effects
   - Respondent effects (misunderstanding, recall errors, incorrect response construction)
5. **Processing Error**: Errors occurring after data collection during conversion to published estimates, including data entry errors, coding mistakes, editing errors, and imputation errors.

The document identifies several practical approaches:

- **For Sampling Error**: Use of appropriate software that accounts for complex sample designs, proper variance estimation methods
- **For Nonresponse**: Weighting adjustments, imputation procedures, and intensive follow-up efforts for nonrespondents
- **For Coverage Error**: Dual frame approaches, post-stratification adjustments, and comprehensive frame development
- **For Measurement Error**: Cognitive testing, questionnaire pretesting, interviewer training, reinterview programs, and behavior coding
- **For Processing Error**: Quality control samples, continuous quality management practices, and systematic verification procedures

Several measurement approaches and models are discussed:

1. **Sampling Error**:
   - Variance estimation methods (linearization, replication techniques)
   - Standard error calculations using specialized software
2. **Nonresponse Error**:
   - Response rate calculations (weighted and unweighted)
   - Nonresponse bias studies comparing respondents to nonrespondents

<!-- page 29 -->

* Statistical adjustments through weighting and imputation models

3. **Coverage Error:**
   * Dual system estimation
   * Case-by-case matching between independent sources
   * Coverage ratio calculations comparing survey estimates to external benchmarks

4. **Measurement Error:**
   * Reinterview reliability studies
   * Record check studies comparing survey responses to administrative records
   * Interviewer variance studies
   * Randomized experiments to test questionnaire effects

5. **Processing Error:**
   * Error rate calculations from quality control samples
   * Verification studies on coding and data entry accuracy

1. **Policy Implementation:** Establishes principles of "openness" in reporting data quality and provides standards/guidelines for survey processes

2. **Reporting Recommendations:**
   * Short-format reports should include basic error information, response rates, and references to detailed methodology
   * Analytic reports should provide comprehensive documentation of all error sources
   * Technical reports should include detailed methodological studies and quantitative error assessments

3. **Quality Management:** Advocates for continuous quality improvement practices throughout the survey lifecycle, from design through dissemination

4. **Documentation Standards:** Recommends comprehensive documentation of survey procedures, error measurement results, and limitations to help users properly interpret data

* The document emphasizes that while complete elimination of errors is impossible, systematic measurement, reporting, and quality control procedures can minimize their impact and ensure users understand data limitations. The authors stress that transparency about error sources is essential for maintaining the credibility and usefulness of federal statistical data.

<!-- page 30 -->

# Summary: Statistical Disclosure Limitation and Survey Data Quality (Reiter, 2012)

## Key Takeaways

**What is the cause of the error?**

The errors stem from Statistical Disclosure Limitation (SDL) techniques that agencies use to protect respondent confidentiality when releasing microdata to the public. Organizations alter collected data before release to prevent identification of individuals or disclosure of sensitive attributes. These alterations—including recoding, data swapping, adding noise, and creating partially synthetic data—inherently distort the relationships among variables in the dataset. The fundamental tension is between protecting privacy and maintaining data usefulness for secondary analysis.

**What techniques can be used to reduce the error in practice?**

The paper discusses several approaches to mitigate the impact of SDL on data quality:

1. **For Recoding:** Analysts can use multiple imputation to account for missing fine detail (e.g., imputing exact ages within five-year intervals). For top-coded values, analysts can treat them as nonignorable missing data using appropriate missing data techniques, though finding suitable models is challenging.

2. **For Added Noise:** Analysts can apply measurement error models if they know the noise distribution. However, agencies typically don't release sufficient details about noise infusion parameters, limiting analysts' ability to make proper adjustments.

3. **For Partially Synthetic Data:** When replacement imputations are generated effectively, analysts can obtain valid inferences by: (a) estimating quantities of interest in each synthetic dataset and computing variance estimates, and (b) combining estimates across datasets using combination rules similar to multiple imputation. This approach automatically propagates uncertainty from the disclosure treatment.

4. **General Best Practices:** Agencies should scale SDL intensity appropriately—using minimal alteration when disclosure risks are manageable. The paper advocates for tiered access systems: highly trusted users get access via licensing or secure enclaves, while others receive strongly protected microdata with verification servers to assess analysis quality.

**What statistical models can be used to measure the error source?**

The paper describes several frameworks for assessing both disclosure risk and data utility:

*Disclosure Risk Assessment:*

* Matching-based approaches that link released files with external databases to estimate identification probabilities

<!-- page 31 -->

* Model-based conditional probability models that account for intruder knowledge and released information about SDL methods
* Poisson regression variants to estimate the probability that sample unique records are population unique records

*Data Utility Assessment:*

* Broad difference measures that quantify statistical distance between original and released data distributions (e.g., Kullback-Leibler or Hellinger distances)
* Comparison of specific analytical results (means, variances, correlations, regression coefficients) between original and altered data
* Propensity score-based discrimination methods that assess how well one can distinguish between original and altered data

**Does it tell me how to reduce the error?**

Yes, but with important caveats. The paper emphasizes that reducing error depends heavily on agencies providing adequate documentation of SDL methods. Key recommendations include:

* Agencies should release detailed information about SDL procedures, including parameters like swap rates, noise distributions, and synthesis models
* When using partially synthetic data, agencies should release information about synthesis models (potentially code without parameter estimates) to help analysts assess reliability for their specific analyses
* Future data access may require verification servers that allow analysts to assess quality of inferences from protected data without direct access to confidential data
* The paper advocates strongly for transparency and replicability, noting that poorly documented SDL procedures prevent analysts from making appropriate adjustments

The fundamental message is that error reduction requires collaboration: agencies must document their methods transparently, and analysts must understand these methods to determine whether and how to adjust their inferences. Without such transparency, analysts have "little choice but to ignore the measurement errors and trust that their analysis has not been unduly compromised."

---

<!-- page 32 -->

# Summary: Improving Coding for Open-Ended Survey Data (Lupia, 2018)

## Key Takeaways

**What is the cause of the error?**

The errors in open-ended survey response coding arise from multiple sources related to poor methodological practices and inadequate documentation:

1. **Inappropriate coding decisions:** For example, ANES coders marked responses about William Rehnquist as "incorrect" unless respondents specified both "Chief Justice" AND "Supreme Court"—coding as wrong the 30% who correctly identified him as a Supreme Court justice but didn't specify "Chief."
2. **Flawed coding instructions:** The Tony Blair question instructed coders that "United Kingdom is *NOT* acceptable" and required specifically "Great Britain" or "England"—even though Blair was actually Prime Minister of the United Kingdom.
3. **Lack of inter-coder reliability assessment:** Different coders may apply subjective judgments inconsistently, but reliability statistics were rarely calculated or reported.
4. **Poor documentation:** There were few or no records of instructions given to coders, no documentation of decision-making processes, and no systematic way for data users to understand how responses were converted to numerical codes.
5. **Conceptual ambiguity:** Previous coding schemes failed to clearly distinguish between "partial knowledge" about a person versus "partial knowledge with respect to the specific question asked."

**What techniques can be used to reduce the error in practice?**

The ANES implemented several concrete improvements after 2008:

1. **Question-focused coding framework:** Rather than making subjective judgments about "partial knowledge," coders now assess whether respondents answered the specific question asked. For political office questions, this means three distinct codes:
    * Did the respondent correctly name the political office?
    * Did they correctly describe the job/responsibilities?
    * Did they say something else (coded as "other" without judgment)?
2. **Mutually exclusive and collectively exhaustive categories:** New coding schemes ensure every response can be classified into exactly one category without ambiguity.
3. **Expert committee development:** Subject matter experts developed coding schemes through collaborative discussion, ensuring theoretical defensibility and consistency with question wording.

<!-- page 33 -->

4. **Multiple coder implementation**: Responses are coded by multiple trained coders to enable reliability assessment.

5. **Comprehensive documentation**: All decisions, coder instructions, conversations with coding vendors, and sources of confusion are documented in writing and made publicly available.

6. **Release of redacted transcripts**: When privacy protections allow, actual response text is made available so users can evaluate coding decisions.

**What statistical models can be used to measure the error source?**

The paper focuses more on procedural quality control than statistical modeling, but it emphasizes:

1. **Inter-coder reliability statistics**: Calculating agreement rates between multiple coders to quantify consistency of coding application. High inter-coder reliability is presented as a key indicator of coding quality.

2. **Comparison of coding schemes**: By releasing documentation and (when possible) redacted transcripts, researchers can compare different coding approaches and quantify how coding decisions affect substantive conclusions. For example, Gibson and Caldeira (2009) found that using a more appropriate coding scheme increased "correct" responses about Rehnquist from 12% to 71%.

The paper doesn't present formal statistical models for measurement error in coded responses, but instead advocates for transparent documentation that would enable other researchers to develop such models.

**Does it tell me how to reduce the error?**

Yes, very explicitly. The paper provides clear guidance through both specific examples and general principles:

*Specific practices:*

* Return to the actual question wording when developing coding schemes
* Focus on whether respondents answered the question that was asked, not on evaluating their overall knowledge
* Accept responses that are substantively correct even if not worded precisely as expected (e.g., "Supreme Court justice, head" should be coded as correct for Rehnquist)
* Create mutually exclusive, collectively exhaustive coding categories
* Use multiple coders and calculate reliability statistics
* Maintain written documentation at every stage

*General principles for best practices:*

* Increased documentation at all stages
* Evaluation at many stages
* Increased procedural transparency
* High inter-coder reliability as a measurable goal

<!-- page 34 -->

* Making documentation publicly accessible so users can assess validity for their specific research questions

The paper explicitly argues that "the scientific credibility of survey-based research depends on transparency and replicability of analysis" and therefore "data be manufactured and distributed in ways that facilitate transparency and replicability." It concludes by identifying areas for future research, including effective approaches to increasing coding transparency, developing shared coding schemes across survey organizations asking similar questions, and specifying best practices for documentation production and dissemination.
