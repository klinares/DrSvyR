---
id: "jpsm/Fund_Infe_SURV740/lectures/Module11_Fall2025_auxl"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Fundamentals of Inference"
original: "Fund_Infe_SURV740/lectures/Module11_Fall2025 auxl.pdf"
pages: 56
sha256: "c0893c50bbcf8f0e9c8667458ba49144535c329127916e25e39f0e906f85fc6b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:03"
---

<!-- page 1 -->

# Fundamentals of Inference

Yan Li ([email])
SurvMeth / Surv 740
Module 11, Fall 2025

<!-- page 2 -->

# Use of Auxiliary Information

* **Auxiliary information** = information that is not the main focus in the analysis, but might play in role in helping to extract <u>extra</u> information for the analysis of interest
  * Sampling frame data
  * Published population totals for subgroups: age, race/ethnicity, education, income, type of employment
  * Geographic information, local area characteristics
    * e.g., Percent of population in Census Tract that rents
  * Known (more or less) for the entire population
    * This means that paradata, or auxiliary data about the <u>data collection process</u> (e.g., interviewer observations, keystroke data, etc.) is a <u>different</u> type of auxiliary information that may not be available for the full population

<!-- page 3 -->

# Poststratification

* We will largely focus on poststratification in the **<u>design-based inference context</u>**, as a tool for <u>adjusting</u> sampling weights that reflect known non-zero probabilities of selection
* Divide the <u>respondent</u> sample into subgroups based on variables collected in the survey that have the following properties:
  * They were **<u>not</u>** available on the original sampling frame, and hence could **<u>not</u>** be used to determine the original sampling strata
  * The variables are related to the key survey measures of interest
  * **Population totals** in the subgroups (based on **cross-classes** formed by the variables) are available from some **external data source** (e.g., population counts for cross-classes defined by age, gender, education, etc.)
* This external data source provides our auxiliary information!

<!-- page 4 -->

# Poststratification Weighting

* After computing survey weights that account for unequal probability of selection (sel) and possibly nonresponse adjustment (nr), compute the **poststratification adjustments** to the weights:

$$
w_{ps,l,i} = \frac{N_l}{\sum_{i=1}^{n_l}(w_{sel,i} \times w_{nr,i})} = \frac{N_l}{\widehat{N}_l}
$$

  Where

  $w_{ps,l,i}$: the post-stratification weight factor for cases in post-stratum $l=1, \dots, L$;

  $N_l$: population count in post-stratum $l$ obtained from a recent Census, administrative records, or a large survey with small sampling variance.

* Multiply the existing weights by this ratio of the known population total for a poststratum to the estimated population total for that poststratum.
* If poststratum identifiers and population totals in the poststrata are available for respondents in the data set, **gains in precision are possible** (but these variables need to be declared to the software!)

<!-- page 5 -->

# Original Goal: Variance Reduction

* Poststratification was originally developed as a method to reduce the variance of estimates (Holt and Smith, 1979, Canvas)
* Compare the variance of the poststratified mean, where the sample is obtained under simple random sampling and the sampling variance calculation ignores the poststrata, i.e., the SRS estimator of the mean:

$$
\bar{y} = \frac{1}{n} \sum_{l=1}^{L} \sum_{i=1}^{n_l} y_{li}
$$

* Ignoring finite population corrections, we know $V(\bar{y}) = S^2 / n$

$$
S^2 = \frac{1}{N-1} \sum_{l=1}^{L} \sum_{i=1}^{N_l} \left(Y_{li} - \bar{Y}\right)^2
$$

<!-- page 6 -->

# Original Goal: Variance Reduction

* For large sample sizes within poststrata indexed by $l$, one can show that
$$\bar{y}_{ps} = \frac{1}{N} \sum_{l=1}^{L} N_l \bar{y}_l = \sum_{l=1}^{L} \left(\frac{N_l}{N}\right) \bar{y}_l = \sum_{l=1}^{L} P_l \bar{y}_l \qquad V(\bar{y}_{ps}) \text{ B} \frac{1}{n} \sum_{l=1}^{L} P_l S_l^2$$

* Here, $P_l$ is the <u>proportion of the populati</u>on in poststratum $l$, based on the available auxiliary information.

* So how does this compare to $V(\bar{y}) = S^2 / n$ ? We can show that
$$V(\bar{y}) = \frac{1}{n} \sum_{h=1}^{H} P_h \left[ S_h^2 + \left(\bar{Y}_h - \bar{Y}\right)^2 \right] = \frac{1}{n} \sum_{h=1}^{H} P_h S_h^2 + \frac{1}{n} \sum_{h=1}^{H} P_h \left(\bar{Y}_h - \bar{Y}\right)^2 \text{ B}$$
$$V(\bar{y}_{ps}) + \frac{1}{n} \sum_{h=1}^{H} P_h \left(\bar{Y}_h - \bar{Y}\right)^2 > V(\bar{y}_{ps})$$

* So, when do we expect the biggest reductions in variance?

<!-- page 7 -->

# Original Goal: Variance Reduction

* Just the same as sample stratification at the sample design stage, we want the <u>between-poststratum variance</u> in the variable(s) of interest to be **<u>as large as possible</u>** to achieve the largest gains in efficiency

<!-- page 8 -->

# (Potential) Simultaneous Benefit: Reduction of Nonresponse Bias

* Though initially conceived for variance reduction, **poststratification** is also important for **bias reduction** in surveys with **nonresponse**.
* There is often a weighting adjustment applied specifically for nonresponse (weighting classes, response propensity, etc.), designed to make sure that the respondent sample is mapped back to the original sample...
* ...but what if “good” auxiliary variables (that predict both response propensity **<u>and</u>** the variables of interest) are not available in the sample microdata for this kind of adjustment? We need to leverage available auxiliary information via poststratification.

<!-- page 9 -->

# An Example

* Suppose we are working on a political survey in the U.S., where the binary variable of interest in support for the Republican candidate
  * For simplicity, we will ignore the issue of identifying likely voters...
* We have auxiliary information available in the form of population counts for four cross-classes defined by $\underline{\text{age}}$ ($> 50$ vs. $\le 50$) and $\underline{\text{education}}$ (college vs. less than college); no other auxiliary information is available
* We assume that age and education are both related to outcome (support for the Republican candidate); these were not available for original stratification of the sample, but measured in the survey

<!-- page 10 -->

# An Example

* Here are the (invented) population data, including the true proportions supporting the Republican (R) candidate in each poststratum (which we would <u>not</u> actually know...).

| Poststratum (age x educ) | Population Proportion | Proportion Supporting R |
| :---: | :---: | :---: |
| <= 50, No College | 0.30 | 0.45 |
| <= 50, College | 0.20 | 0.25 |
| > 50, No College | 0.35 | 0.65 |
| > 50, College | 0.15 | 0.35 |

<!-- page 11 -->

# An Example

* We collect the survey data. Suppose that the estimated proportions supporting the Republican candidate based on the survey respondents are similar to the known proportions supporting the candidate in the population (again, we would not know this).
* However, the estimated proportions of the population in each of the four cross-classes are **not** consistent with the known population proportions from the auxiliary information, due to differential nonresponse.
* What does this mean? The probability of responding to the survey is a function of other observable variables (age and education), but **NOT** the variable of interest (support for the Republican candidate)
* This is known as a **missing at random (MAR)** nonresponse mechanism, which is also referred to as an **ignorable** mechanism, and the post-stratification adjustment can correct for the bias introduced by it!

<!-- page 12 -->

# An Example

* Let’s see what this MAR scenario looks like, and what the poststratification adjustments to the weights would look like:

| Poststratum (age x educ) | Population Proportion | Est. Population Proportion | Poststratification Adjustment | Est. Proportion Supporting R |
| :---: | :---: | :---: | :---: | :---: |
| $\le 50$, No College | $0.30$ | $0.15$ | $0.30 / 0.15 = 2.00$ | $0.45$ |
| $\le 50$, College | $0.20$ | $0.30$ | $0.20 / 0.30 = 0.67$ | $0.25$ |
| $> 50$, No College | $0.35$ | $0.25$ | $0.35 / 0.25 = 1.40$ | $0.65$ |
| $> 50$, College | $0.15$ | $0.30$ | $0.15 / 0.30 = 0.50$ | $0.35$ |

* Note that, given the <u>estimated</u> population proportions, we would <u>underestimate</u> support for the Republican candidate in a weighted analysis.
* These adjustments would correct the estimated population proportions to match with the known proportions, and therefore remove the (negative) bias in the <u>overall estimate of the proportion</u> supporting the Republican candidate!

<!-- page 13 -->

# An Example

* Implication of the MAR mechanism is that when we condition on the observed variables (age and education), the respondents in each poststratum are a <u>simple random sample</u> of the full sample within that poststratum
* Suppose that there was an **unmeasured confounder**, closely related to the variable of interest, that was also a significant predictor of responding to the survey within each poststratum

<!-- page 14 -->

# An Example

* Now, suppose that we collect the survey data, and the MAR mechanism no longer holds; those who voted Democratic in the last election have much higher response rates within each poststratum
* But we did not measure this variable in the survey, and we have NO auxiliary information on the variable to help with the adjustment!
* This pattern suggests that the probability of responding to the survey is a function of our variable of interest, even after conditioning on age and education, and that estimates within each poststratum will therefore be biased
* This is a **missing not at random (MNAR) mechanism**, which is also known as a **non-ignorable** selection mechanism, and poststratification **<u>will not fix the bias that it introduces!</u>**

<!-- page 15 -->

# An Example

* Let’s look at what might happen under this type of MNAR mechanism:

| Poststratum (age x educ) | Population Proportion | Est. Population Proportion | Response Rates: Voted R / Voted D | Est. Proportion Supporting R |
| :---: | :---: | :---: | :---: | :---: |
| <= 50, No College | 0.30 | 0.15 | 0.15 / 0.25 | 0.25 |
| <= 50, College | 0.20 | 0.30 | 0.50 / 0.70 | 0.15 |
| > 50, No College | 0.35 | 0.25 | 0.20 / 0.40 | 0.50 |
| > 50, College | 0.15 | 0.30 | 0.75 / 0.90 | 0.30 |

* Note that the differential response rates among a strong (but unmeasured!) correlate of party preference are now changing the estimated proportions supporting the R candidate in a <u>negative direction</u>
* Poststratification would again serve to match the estimated population proportions in each poststratum with the known auxiliary information, but would **not** fix the negative bias introduced by this mechanism!

<!-- page 16 -->

# An Example

* *Ideally*, we would also have population information on the number of people that voted for each candidate in the last election, and we could use that information to form more poststrata (cross-classes) for the purpose of this adjustment
* A <u>major problem</u> with the persistence of current pollsters to adjust for nonresponse via standard weighting procedures assume MAR mechanisms.
* If an unmeasured confounder that is correlated with study variable of interest may also be predicting response propensity, poststratification adjustment methods may not help(e.g., West and Andridge, 2023)

<!-- page 17 -->

# Poststratification: Additional Concepts

* For <u>large enough sample sizes</u>, the variance of the poststratified mean will always be less than or equal to the variance of the unstratified (SRS) mean; but this is not necessarily the case for smaller samples
* Large differences between the means of the poststrata and the overall means will <u>increase the efficiency</u> (i.e., reduce the sampling variance) of the poststratified estimator
  * This is enhanced when the poststrata are associated with response propensity
* For bias caused by nonresponse, poststratification removes the bias arising from <u>differences in response rates across groups</u>. It usually produces a less biased estimate when the remaining bias within poststrata (due to NMAR nonresponse) is small.

<!-- page 18 -->

# Poststratification: Additional Concepts

* Larger <u>sample sizes</u> do not guarantee bias reduction, in the same way that variance reduction is expected! This has to do with the nature of the nonresponse mechanism (MAR or MNAR?)
* “All bets are off” if there is a MNAR mechanism, since the bias not reduced by poststratification can go in <u>different</u> directions
* In reality, selection mechanisms will not be 100% MAR or 100% MNAR; selection will likely be a function of some combination of observed variables and unobserved variables (West and Andridge, 2023)
* Remember that estimators are evaluated based on their **mean squared error**, which combines squared bias and variance; while variance may decrease, bias may be substantial!

<!-- page 19 -->

# Raking

* Poststratification assumes that all of the population counts (or equivalently their distributions) for the cells formed by the cross-classes of the variables used for poststratification are <u>known</u>.
* There is an alternative technique for use when only the **marginal** distribution of each of the auxiliary variables is known (as opposed to the distribution across cross-classes): **raking ratio estimation**.

<!-- page 20 -->

# Raking

* The technique known as **iterative proportional fitting (IPF)** is used to obtain the joint distribution from the known marginal distributions:

1) Adjust the weight factors for sex so that the weighted sample matches the population distribution of the first cross-classification term (i.e., post-stratify on margins of sex).

2) Repeat 1) for age. Generally, this will disturb the representativeness of sex.

3) Repeat 1) and 2) iteratively until weight factors remain unchanged at each iteration.

<!-- page 21 -->

# An Example

* Consider an example where the following marginal proportions are available for a population:

| Age | Male | Female | |
| :--- | :--- | :--- | :--- |
| 18-34 | | | 0.228 |
| 35-49 | | | 0.211 |
| 50-64 | | | 0.294 |
| 65+ | | | 0.267 |
| | 0.486 | 0.514 | |

* We then have a set of respondents with the following distribution of age/sex:

| Age | Male | Female | |
| :--- | :--- | :--- | :--- |
| 18-34 | 0.071 | 0.106 | 0.177 |
| 35-49 | 0.101 | 0.121 | 0.222 |
| 50-64 | 0.099 | 0.172 | 0.271 |
| 65+ | 0.137 | 0.193 | 0.330 |
| | 0.408 | 0.592 | |

<!-- page 22 -->

## Calibrate to sex:

| Age | Male | Female | |
| :--- | :--- | :--- | :--- |
| 18-34 | $0.071*(.486/.408)=0.085$ | $0.106*(.514/.592)=0.092$ | 0.177 |
| 35-49 | $0.101*(.486/.408)=0.120$ | $0.121*(.514/.592)=0.105$ | 0.225 |
| 50-64 | $0.099*(.486/.408)=0.118$ | $0.172*(.514/.592)=0.149$ | 0.267 |
| 65+ | $0.137*(.486/.408)=0.163$ | $0.193*(.514/.592)=0.168$ | 0.331 |
| | 0.486 | 0.514 | |

## Calibrate to age:

| Age | Male | Female | |
| :--- | :--- | :--- | :--- |
| 18-34 | $0.085*(.228/.177)=0.109$ | $0.092*(.228/.177)=0.119$ | 0.228 |
| 35-49 | $0.120*(.211/.225)=0.113$ | $0.105*(.211/.225)=0.098$ | 0.211 |
| 50-64 | $0.118*(.294/.267)=0.130$ | $0.149*(.294/.267)=0.164$ | 0.294 |
| 65+ | $0.163*(.267/.331)=0.131$ | $0.168*(.267/.331)=0.136$ | 0.267 |
| | 0.483 | 0.517 | |

### Population

| Age | Male | Female | |
| :--- | :--- | :--- | :--- |
| 18-34 | | | 0.228 |
| 35-49 | | | 0.211 |
| 50-64 | | | 0.294 |
| 65+ | | | 0.267 |
| | 0.486 | 0.514 | |

### Sample

| Age | Male | Female | |
| :--- | :--- | :--- | :--- |
| 18-34 | | | 0.177 |
| 35-49 | | | 0.222 |
| 50-64 | | | 0.271 |
| 65+ | | | 0.330 |
| | 0.408 | 0.592 | |

<!-- page 23 -->

Calibrate to sex:

| Age | Male | Female | |
| :--- | :--- | :--- | :--- |
| 18-34 | $0.109*(.486/.483)=0.110$ | $0.119*(.514/.517)=0.118$ | 0.228 |
| 35-49 | $0.113*(.486/.483)=0.113$ | $0.098*(.514/.517)=0.098$ | 0.211 |
| 50-64 | $0.130*(.486/.483)=0.131$ | $0.164*(.514/.517)=0.163$ | 0.294 |
| 65+ | $0.131*(.486/.483)=0.132$ | $0.136*(.514/.517)=0.135$ | 0.267 |
| | 0.486 | 0.514 | |

Age margins match population $\rightarrow$ algorithm has converged.

Raking-based weighting adjustments needed are given by:

| Age | Male | Female |
| :--- | :--- | :--- |
| 18-34 | $0.110/0.071=1.55$ | $0.118/0.105=1.12$ |
| 35-49 | $0.113/0.101=1.12$ | $0.098/0.122=0.81$ |
| 50-64 | $0.131/0.099=1.32$ | $0.163/0.172=0.95$ |
| 65+ | $0.132/0.137=0.97$ | $0.135/0.193=0.70$ |

<!-- page 24 -->

# When Does Raking Work?

* Raking is beneficial when:
  * **No important interactions:** The raking variables don't have meaningful interaction effects (margins capture the key structure).
  * **Incremental bias reduction:** Adjusting on one variable leaves residual nonresponse bias that a second variable can meaningfully reduce.
  * **Practical convergence:** The algorithm converges reliably and quickly (no extreme weights or instability).
* Raking estimator has a complex mean squared error; can lead to small cells

<!-- page 25 -->

# Generalized Regression (GREG) Estimation

* *Poststratification* and *raking* have been drawn together in a general framework known as <u>calibration estimation</u> (Deville and Sarndal, 1992).
* The idea is to recalibrate the survey weights $d_i$ to new values $w_i$, where the $w_i$ satisfy the constraint $\sum w_i \mathbf{x}_i = \mathbf{X}$, where $\mathbf{X}$ is a vector of known population totals for auxiliary variables $\mathbf{x}_i$, subject to minimizing a **distance criterion** between the $w_i$ and $d_i$ given by
$$D(d_i, w_i).$$

<!-- page 26 -->

# GREG Estimation

* The minimizing distance criterion $D(d_i, w_i) = \frac{1}{2} \sum_{i \in s} \frac{(w_i - d_i)^2}{d_i}$ yields the generalized regression estimator (GREG) weights.
* GREG estimator generalizes poststratification to create weights that match population totals of *continuous* variables, as well as cell counts of *categorical* variables.
* The resulting GREG weights are given by:

$$w_{i,GREG} = d_i \left\{ 1 + \left( \boldsymbol{X} - \widehat{\boldsymbol{X}} \right)^T \boldsymbol{T}^{-1} \boldsymbol{x}_i \right\}$$

where $\mathbf{T} = \sum_{i \in s} d_i \mathbf{x}_i \mathbf{x}_i^T$ and $\hat{\mathbf{X}} = \sum_{i \in S} d_i \mathbf{x}_i$.

<!-- page 27 -->

# GREG Estimation

* We can recover poststratification weights from this general GREG estimation approach!
* If there are $p$ categorical control variables, each of dimension $I_k$, and $\mathbf{X}$ is given by the $I_1 \times \dots \times I_p$ cell counts from a complete contingency table, then $w_{i,GREG}$ <u>are simply the poststratification weights</u>.

<!-- page 28 -->

# Nonprobability Sample Analysis

<!-- page 29 -->

Both *probability and nonprobability* samples aim to efficiently estimate the characteristics of a large finite population (FP) based on measurements of a small subset of the population.

<u>Probability samples (survey):</u>
* Each FP unit has a *known probability* to be selected

<u>nonprobability samples</u>

* Little or no control over sampling design mechanism
* Large and complex data structures
* Sample recruited for reasons unrelated to research focus
* Often large and ongoing longitudinal data collection
* Available data may change rapidly over time

<!-- page 30 -->

## Examples of Non-probability Samples

<u>Convenience sampling:</u> No formal sample design is used.

For example, *mall intercepts, volunteer samples, etc.*

* *Mall intercept sample* – interviewers try to recruit shoppers to take part in some study. Usually, neither the malls nor the people are probability samples.
* *Volunteer samples* – in social science, medicine, and market research. Volunteers participate in a single study or become part of a panel whose members may be recruited for different studies over the course of time.

<u>Sample matching:</u> Members are selected to match a set of important population characteristics. For example,

**Quota sampling** is an example of sample matching. The matching is intended to reduce selection biases as long as the covariates that predict *outcome variables of interest* can be used in matching.

<!-- page 31 -->

## Potential bias in nonprobability samples

### A. Undercoverage Bias

In nonprobability samples, Valliant and Dever (2011) defined three populations to describe <u>undercoverage bias</u>:

(1) Target population of interest for the study $U$;
(2) Potentially covered population $F_{pc}$; and
(3) Actually covered population, $F_c$, the portion of $F_{pc}$.

FIG. 1. *Illustration of potential and actual coverage of a target population.*

<!-- page 32 -->

For example, consider an opt-in *web survey* for a smoking cessation study

(1) The target population $U$ may be defined as US adults aged 18–29 who currently use cigarettes.

(2) The potentially covered population $F_{pc}$ would be those study eligible individuals with *Internet access* who *visit the sites*.

(3) The actually covered population $F_c$ would be the subset of the $F_{pc}$ who *participate* in the study.

Selecting a sample only from $Fc$ results in <u>undercoverage</u> bias.

<!-- page 33 -->

### B. Selection Bias

<u>***Selection* bias**</u> occurs when some groups are also more likely to volunteer for joining a nonprobability sample.

(1) No sampling frame – Unknown participation mechanism
(2) Vonk, van Ossenbruggen and Willems (2006) report that ethnic *minorities and immigrant* groups were systematically underrepresented in Dutch panels.
(3) Relative to the general population, the Dutch online panels contained *disproportionately more voters, more Socialist Party supporters, more heavy Internet users and fewer churchgoers*.

Despite all these potential biases, Nonprobability samples are now widely used, in combination with various statistical adjustments.

<!-- page 34 -->

## Empirical and Numerical Examples for potential selection bias in nonprobability samples

<u>Empirical Example</u>: SARS-Cov-2 Infection Prevalence Estimation

NIH SARS-CoV-2 seroprevalence study - Proportion of U.S. adults with COVID-19 antibodies from April 01 to August 04, 2020 <u>(Kalish et al., 2021)</u>

- More than 460,000 volunteers responding within weeks of the study announcement
- Select subset of volunteers based on quota variables *age, race, sex, ethnicity and region* – reflecting the US adults’ distributions
- A sample of 8058 subjects answered a questionnaire on medical, geographic, demographic, and socioeconomic information and provided blood samples

- **Recruitment: Quota Sampling**

<!-- page 35 -->

Quota Sample Design (Baker et al. 2013)
- Certain variables related to the outcome – reflect the distribution in the finite population (FP)
- The quota sample and the FP may differ on other important variables that predict the outcome

This is – Rapid data collection but suffer from **Selection Bias**

<u>Behavioral Risk Factor Surveillance System (BRFSS)–Probability sample</u>
* A national representative probability survey
* Adjust for potential selection bias by 11 variables related to seropositivity but were not used in the quota sampling
* A total of 367,165 participants, responded to the same clinical questionnaire, were included in the analysis
* 5 quota variables with additional 11 demographic or health related factors

<!-- page 36 -->

# Covariate distribution (%) in the weighted BRFSS (size=367,165) vs. Covid (size=8058)

| | Covid Survey | Weighted BRFSS | | Covid Survey | Weighted BRFSS | | Covid Survey | Weighted BRFSS |
| :--- | :---: | :---: | :--- | :---: | :---: | :--- | :---: | :---: |
| Age Group | | | Urban/Rural | | | Flu Vaccinated | | |
| 18-45 | 41.6 | 42.9 | Urban | 94.7 | 93.2 | Yes | 73.8 | 51.3 |
| 45-70 | 42.6 | 41.8 | Rural | 5.3 | 6.8 | No | 26.2 | 48.7 |
| 70-95 | 15.8 | 15.2 | Children present | | | Cardiovascular | | |
| Sex | | | Yes | 32.5 | 34.7 | Yes | 4.1 | 9.5 |
| Male | 47.4 | 47.8 | No | 67.5 | 65.3 | No | 95.9 | 90.5 |
| Female | 52.6 | 52.2 | **Educ3** | | | Pulmonary | | |
| Race | | | <=HS | 2.6 | 39.4 | Yes | 18.8 | 18.7 |
| White only | 77.5 | 74.8 | College | 13.8 | 31.5 | No | 81.2 | 81.3 |
| Black only | 9.4 | 12.6 | >=College | 83.6 | 29.1 | Immune | | |
| Others | 13.1 | 12.5 | Homeowner | | | Yes | 23.4 | 31.1 |
| Ethnicity | | | Own | 75.2 | 68.8 | No | 76.6 | 68.9 |
| Hispanic | 15.9 | 14.1 | Rent | 20.2 | 25.6 | Diabetes | | |
| Not Hispanic | 84.1 | 85.9 | Others | 4.7 | 5.6 | Yes | 5.5 | 11.9 |
| Region | | | Employment | | | No | 94.5 | 88.1 |
| Northeast | 16.7 | 17.1 | Employed | 71.2 | 57.4 | Health Insurance | | |
| Midwest | 15.8 | 17.6 | NLF | 23.8 | 32.2 | Yes | 97.4 | 89.0 |
| Mid-Atlantic | 20.8 | 17.3 | Unemployed | 5.0 | 10.4 | No | 2.6 | 11.0 |
| South/Central | 14.2 | 15.7 | | | | | | |
| Mountain/Southwest | 15.5 | 15.3 | | | | | | |
| West/Pacific | 17.0 | 16.9 | | | | | | |

<!-- page 37 -->

### Results:

**COVID quota sample mean (3.77%)** – We detected an undiagnosed seropositivity rate of 3.77%.

Questions:

* Potential **selection bias** of this estimate?
* How to mitigate the selection bias in nonprobability samples by using auxiliary information from probability sample?

<!-- page 38 -->

### Numerical Examples:

A. Simulation Study 1 – Fit for purpose
<u>Data generation</u>: _for $i = 1, 2, \dots, N$_

$$
X_i \sim UNIF(1, 10)
$$

$$
Y_i \sim N(\alpha + \beta X_i + \gamma X_i^2, 1)
$$

<u>Sampling mechanism</u> – PPS with measure of size $\text{MOS}(X_i)$

$$
P\left(\delta_i^{(np)} = 1 \Big| X_i\right) = \frac{nX_i}{\sum_{i=1}^N X_i},
$$

where $\delta_i^{(np)}$: selection indicator ($=1$ if selected; $0$ otherwise)
* Sample size _n=100_ and Population size _N=10,000_
* We generate 1,000 independent samples of each $n=100$

<!-- page 39 -->

### <u>Sample Analysis</u>

**Analysis** model: simple linear regression

$$
E(Y_i | X_i) = A + B X_i \qquad \text{(M1)}
$$

Our target of inference is regression coefficient $B$

$$
B = \frac{\sum_{i=1}^N (Y_i - \bar{Y})(X_i - \bar{X})}{\sum_{i=1}^N (X_i - \bar{X})^2}
$$

**Question**: Is there selection bias in estimating FP parameters such as population mean and population X-Y association?

<!-- page 40 -->

**Setup 1:** For population generation, specify $\alpha = 1, \beta = 1, \gamma = 0$ in

$$Y_i \sim N(1 + X_i, 1)$$

Therefore, analysis model (M1) is correctly specified.

**Nonprobability sample** unweighted estimator of the mean and the slope along with associated 95% confidence intervals

| | Bias | 95% Coverage |
|---|---|---|
| mean | 1.219 | 0.3% |
| slope | -0.004 | 96.1% |

**Mean is biased but slope (X-Y association) is unbiased**, this is because the X distribution in the sample different from that in FP (with more large X in the sample vs. FP) introduce selection bias in estimating population mean (but not in estimating the slope)

<!-- page 41 -->

**Setup 2:** Specify $\alpha = 1, \beta = 1, \gamma = 0.1,$

$$Y_i \sim N(1 + X_i + 0.1X_i^2, 1)$$

Therefore, the analysis model M1 is mis-specified.

**Nonprobability Sample** unweighted estimators of mean and slope

| | Bias | 95% Coverage |
|---|---|---|
| mean | 2.595 | 0% |
| slope | 0.127 | 32.7% |

Under the mis-specified analysis model M1,
* Unweighted Mean is biased due to biased selection of X
* Unweighted Slope is biased due to biased selection of X

The X distribution in the sample different from that in FP (units with larger X tend to be included the sample vs. FP) introduce selection bias in estimating *population mean* as well as the *association*

<!-- page 42 -->

# Can we leverage auxiliary variables outside the nonprobability sample help reduce selection bias?

1) Quasi-Randomization methods

    a. Propensity Score-PS Weighting
    b. Propensity Score-PS Matching

2) Revisit the Numerical Simulation and Covid Study

<!-- page 43 -->

<u>Notation</u>

Y: binary outcome variable with values 1 or 0

$$\bar{Y} = \frac{1}{N} \sum_{i=1}^N y_i$$

$FP = \{1, \dots, N\}$: finite population of interest
$\boldsymbol{X}$: a vector of variables that predicts the outcome Y

$s_{np}$: a nonprobability sample
$\delta_j^{(np)}$ ($= 1$ if $j \in s_{np}$; 0 otherwise): indicator of $s_{np}$ inclusion
$\pi_j^{(np)} = P\big(j \in s_{np} \mid j \in FP\big)$: underlying participation rate for FP unit $j$;
$w_j = 1/\pi_j^{(np)}$ for $j \in FP$: IMPLICIT nonprobability sample weight

$s_p$: a probability sample, a set of units $\{i = 1, 2, \dots, n_p\}$

$$\pi_i^{(p)} = P\big(i \in s_p \mid i \in FP\big)$$

$d_i = 1/\pi_i^{(p)}$, sample weight for the probability sample unit $i$

<!-- page 44 -->

### 1). Quasi-Randomization methods

$$
\bar{y} = \frac{\sum_{j \in s_{np}} \widehat{w}_j y_j}{\sum_{j \in s_{np}} \widehat{w}_j},
$$

a. Propensity Score (PS) Weighting
b. Propensity Score (PS) Matching

<!-- page 45 -->

* Assumptions by PS-based Methods

  A1 (**Conditional Exchangeability**). The nonprobability sample participation indicator $\delta^{(np)}$ is independent of the outcome variable $y$ given the covariates $x$, $\Pr\left(\delta^{(np)} = 1 \mid y, x\right) = \Pr\left(\delta^{(np)} = 1 \mid x\right)$, i.e.,

$$\delta^{(np)} \perp Y \mid X$$

  A2 (**Positivity**). All finite population units have a positive participation rate, i.e., $\pi_i^{(np)} > 0$ for $i \in FP$.

  A3 (**Independent**). The indicators of participation in the nonprobability sample are uncorrelated with each other given the self-selection variables, i.e., $cov\left(\delta_i^{(np)}, \delta_j^{(np)} \mid x_i, x_j\right) = 0$ for $i \neq j$.

  A4. Reference probability sample, through weighting, **properly represents** the target FP of interest.

  A5. Different PS methods assume different **propensity models** (parametric or nonparametric)

<!-- page 46 -->

### a) PS weighting methods

* **Adjusted logistic propensity method (ALP, Wang et al., 2021)**
* Rescaled design weight method (RDW, Valliant and Dever 2011)
* CLW method (Chen et al. 2019)
* Rubbins (2017) and Elliott & Valliant (2017)

<!-- page 47 -->

# In ALP, estimation of $w_j = 1/\pi_j^{(np)}$

- Assume logistic regression model

$$\log\left\{\frac{p(\boldsymbol{x}_i)}{1 - p(\boldsymbol{x}_i)}\right\} = \boldsymbol{B}^T g(\boldsymbol{x}_i), \qquad \text{for } i \in FP, \qquad (1)$$

  - $p(\boldsymbol{x}_i)$: likelihood of being units in $s_{np}$ vs. in $FP$, and

$$\boldsymbol{\pi_j^{(np)}} = \exp\big(\boldsymbol{B}^T g(\boldsymbol{x}_i)\big)$$

  - $g(\boldsymbol{x}_i)$ is a known function of observed covariates
  - $\boldsymbol{B}$ the unknown regression coefficients

- $\widehat{\boldsymbol{B}}_w$: Estimated by fitting (1) to combined $s_{np}$ and weighted $s_p$
- ALP weight $\boldsymbol{\widehat{w}_j^{ALP} = 1/\pi_j^{(np)}(\widehat{\boldsymbol{B}}_w)}$

<!-- page 48 -->

<u>ALP estimates of finite population mean:</u>

$$\bar{y}^{ALP} = \frac{\sum_{j \in s_{np}} \widehat{w}_j^{ALP} y_j}{\sum_{j \in s_{np}} \widehat{w}_j^{ALP}},$$

Under propensity model (1), ALP estimates are approximately unbiased.

In practice, using existing software, ALP estimator of the FP mean can be obtained in <u>three steps</u>:
* Step 1: Search for covariates $\boldsymbol{x}$ available in both the $s_{np}$ and the reference survey sample ($s_p$) and combine the two samples.
* Step 2: Fit a logistic regression model to the combined $s_{np}$ and weighted $s_p$, and obtain the estimated model parameters $\widehat{\boldsymbol{B}}_w$ and $\hat{p}_i$.
* Step 3: $\widehat{w}_j^{ALP} = \frac{1-\hat{p}_j}{\hat{p}_j}$ for $j \in s_{np}$, plugged in the formula above to estimate the finite population mean

<!-- page 49 -->

### b) PS matching methods

* Subclassification method (PSAS, by Lee 2006) - $\widehat{w}_j^{PSC}$
* Kernel Weighting estimator (KW, Wang et al., 2021) - $\widehat{w}_j^{kw}$

<!-- page 50 -->

* Subclassification method (PSC by Lee 2006)
  In 3 Steps:
  * Step1: Propensity scores are estimated by fitting model (1) to the combined ($s_{np}$ vs. *weighted* $s_p$) sample.
  * Step2: Estimated $\hat{p}_i$ are sorted in the combined sample and partitioned into subclasses $g=1,\dots,G$
  * Step3: Probability sample weight total evenly distributed to the nonprob. sample units within each subclass.

$$\widehat{w}_j^{PSC} = \frac{\sum_{k \in s_p(g)} d_k}{\sum_{k \in s_{np}(g)} 1} = \frac{\sum_{k \in s_p(g)} d_k}{n_{np}(g)} \text{ for } j \in s_{np}(g)$$

**Assumption**: Participants within subclasses represent the same number of population units – How to relax the assumption to reduce the bias?

<!-- page 51 -->

* Kernel Weighting (KW) estimator (Wang et al., 2021)
  In contrast to the PSC method, the KW method fractionally distributes prob. sample weights to nonprobability sample units according to the similarity of PS using kernel smoothing methods
  * Step1: Propensity scores are estimated by fitting model (1) to the combined ($s_{np}$ vs. *weighted* $s_p$) sample.
  * Step2: KW pseudo-weight for nonprob sample unit $j$ constructed by
    $$
    \widehat{w}_j^{KW} = \sum_{i \in s_p} \frac{K\left(\frac{p_i - p_j}{h}\right)}{\sum_{j \in s_{np}} K\left(\frac{p_i - p_j}{h}\right)} \cdot d_i, \qquad j \in s_{np},
    $$
    where $h$: bandwidth; K(): kernel function, such as standard normal.
    The closer of the two propensity scores between $p_i$ and $p_j$
    $\rightarrow$ The higher similarity in the X distribution.
    $\rightarrow$ Larger portion of the prob. sample weight assigned to the nonprobability sample unit $i$ who are similar to the unit $j$ in terms of X

<!-- page 52 -->

* Comparison between PS-matching vs PS-weighting methods

PS-weighting:
  Pros:
  * Correct bias under the true propensity score model
  Cons:
  * Sensitive to Model misspecification
  * Inflated variance due to potentially extreme pseudo-weights

PS-Matching:
  Pros:
  * More stable estimates without inflated variance
  Cons for PSC:
  * Biased by assuming equal representation of all units within classes
  * Number of classes? 2, 5, 8, or 10?

Both Cons in PSAS are not of concern in KW; Moreover, KW is robust to model misspecification with less variability of the mean estimates.

<!-- page 53 -->

## Revisit the Numerical Simulations and the Covid Study

Recall: Unweighted naïve sample means – Biased in quota samples

For selection bias reduction, construct pseudo-weights $\widehat{w}_j$ by PS-weighting or PS-matching methods.

ALP method fits the combined sample (i.e., the selected quota sample and the *weighted* probability sample) to the <u>logistic regression models that include covariates</u> of 5 quota variables only(x1), 11 covariates other than x1(x2), or all 16 covariates(x)?

<!-- page 54 -->

### PS-based Adjustments Methods

Assumptions:

1. Conditional on ALL 16 covariates, covid seropositivity ($Y$) has the same distribution in the covid sample as in the US adults, that is: There are no unmeasured covariates that are predictive of covid seropositivity (conditional exchangeability)
2. Each US adult has positive propensity of participating the Covid study (positivity)
3. etc (e.g., true propensity model; BRFSS represents FP, etc)

<!-- page 55 -->

| Propensity Model | est (%) | se.TL ($\times 10^{-2}$) |
| :--- | ---: | ---: |
| All variables $w(x)$ | 4.556 | 0.782 |
| Quota variables $w(x_1)$ | 3.850 | 0.235 |
| Health variables $w(x_2)$ | 3.922 | 0.553 |

* Estimate under $w(x_1)$ is closest to simple mean (3.77%) and has smallest se.TL. This is because the quota variables $x_1$ used in sampling have similar distributions in Covid and BRFSS, and hence the estimated KW pseudoweights are similar with least variability.
* Although more efficient than the full model $w(x)$, the propensity models based on $x_2$ only $w(x_2)$ can yield *biased* estimates.

<!-- page 56 -->

# Summary

1. Undercoverage bias, Selection bias, etc

2. Various assumptions for PS-based methods
   a. Conditional Exchangeability
   b. Positivity
   c. Independence
   d. Reference survey well representative

3. Reduce the selection bias under assumptions

4. Great demand for High-Quality Probability Samples
