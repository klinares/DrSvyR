---
id: "jpsm/fund_data_coll_1_SURV621/lectures/Lecture_3_Errors_of_representation_(continued)"
source: "jpsm"
course: "SURV621"
course_title: "Fundamentals of Data Collection I"
doc_type: "lecture"
title: "SURV 621/SURVMETH 621: REPRESENTATION ERROR IN NONPROBABILITY SURVEYS AND NON-SURVEY DATA"
original: "fund_data_coll_1_SURV621/lectures/Lecture 3 Errors of representation (continued).pdf"
pages: 38
sha256: "5c77e4800be08b4b5f8dc7934d290698d5be520e833c231bed618b520cf50e74"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:57"
---

<!-- page 1 -->

# SURV 621/SURVMETH 621: REPRESENTATION ERROR IN NONPROBABILITY SURVEYS AND NON-SURVEY DATA

September 16, 2024

<!-- page 2 -->

# Overview

* Survey nonresponse may mean that the data collected in a probability sample survey no longer are representative
  * Statistical methods to reduce bias in the presence of nonresponse include reweighting based on response propensities and calibration reweighting
* Similar methods have been used for analysis of data from nonprobability surveys
  * Effectiveness in this context less clear
* Research on using *found* data in early stages
  * Such data often have obvious limitations in their coverage of people, households or organizations

2

<!-- page 3 -->

# Post-survey weighting adjustments

* Sometimes the characteristics of survey respondents match the characteristics of the full population (without any statistical adjustments)
* But often they do not...
  * Because of sampling with unequal probabilities
  * Because of coverage error and nonresponse error
  * Or because the sample was self-selected (and not representative of the full population to begin with)
* **Post-survey weighting adjustments** are a statistical technique used to address this issue
  * What is a "survey weight“? It is a numerical value assigned to a respondent that adjusts the influence of their response on the overall analysis.
  * By giving more weight to underrepresented respondent groups and less weight to overrepresented respondent groups, you can correct for issues of sample representation

3

<!-- page 4 -->

# Methods of adjusting for nonresponse in a probability sample survey

* Imputation for missing units
  * Common for business surveys, less common for household surveys
* Nonresponse reweighting
  * Requires unit-level information on characteristics of both respondents and non-respondents
* Calibration
  * Does not require unit level information on characteristics of non-respondents.
  * May address other problems such as sample frame deficiencies in addition to nonresponse

4

<!-- page 5 -->

# Imputation

* Different approaches to unit imputation
  * If available, use administrative information for the unit
  * If available, use prior wave response, either as is or adjusted to reflect average growth for similar responding units
  * Substitute data for another randomly selected unit of similar size in the same industry and geographic area
* Best imputation method will depend on data available and sources of variation in variable(s) of interest

5

<!-- page 6 -->

# Nonresponse reweighting

* Cell-based reweighting
  * Respondents and nonrespondents are classified into adjustment cells based on unit characteristics
  * Weights for responding units in an adjustment cell inflated as necessary to account for nonresponse in that cell; Calculate weights as the inverse of the response rate in the cell
* Propensity score reweighting
  * Models relate unit response to unit characteristics; weights adjusted based on estimated response propensity
  * In a small survey, propensity score approach may allow a larger number of unit characteristics to be taken into account than is possible with a cell-based approach

6

<!-- page 7 -->

# Example: Cell-based nonresponse weighting adjustment in an establishment survey.

Let's start by thinking about sampling weights.

| Establishment employment | Number of establishments in population | Number of establishments in sample | Number of establishments that responded |
| :---: | :---: | :---: | :---: |
| 2,500 plus | 100 | 100 | 70 |
| 1,000-2,499 | 500 | 400 | 320 |
| 500-999 | 1,000 | 600 | 480 |
| 250-499 | 2,000 | 800 | 480 |
| 100-249 | 5,000 | 1,000 | 500 |
| 1-99 | 20,000 | 2,000 | 800 |

7

<!-- page 8 -->

# Example (cont’d) - Weights

Calculate sampling weights as the inverse of selection probability.

| Establishment employment | Selection Probability | Sampling Weight | Response Rate | Nonresponse Weight | Final Weight |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 2,500 plus | 1.0 | 1.00 | 0.70 | 1.42857 | 1.42857 |
| 1,000-2,499 | 0.8 | 1.25 | 0.80 | 1.25000 | 1.56250 |
| 500-999 | 0.6 | 1.66 | 0.80 | 1.25000 | 2.08333 |
| 250-499 | 0.4 | 2.50 | 0.60 | 1.66666 | 4.16666 |
| 100-249 | 0.2 | 5.00 | 0.50 | 2.00000 | 10.0000 |
| 1-99 | 0.1 | 10.00 | 0.40 | 2.50000 | 25.0000 |

8

<!-- page 9 -->

# Example (cont’d)

Let’s now think about nonresponse weights.

| Establishment employment | Number of establishments in population | Number of establishments in sample | Number of establishments that responded |
| :---: | :---: | :---: | :---: |
| 2,500 plus | 100 | 100 | 70 |
| 1,000-2,499 | 500 | 400 | 320 |
| 500-999 | 1,000 | 600 | 480 |
| 250-499 | 2,000 | 800 | 480 |
| 100-249 | 5,000 | 1,000 | 500 |
| 1-99 | 20,000 | 2,000 | 800 |

9

<!-- page 10 -->

# Example (cont’d) - Weights

Calculate nonresponse weights as the inverse of the response rate in the cell.

| Establishment employment | Selection Probability | Sampling Weight | Response Rate | Nonresponse Weight | Final Weight |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 2,500 plus | 1.0 | 1.00 | 0.70 | 1.42857 | 1.42857 |
| 1,000-2,499 | 0.8 | 1.25 | 0.80 | 1.25000 | 1.56250 |
| 500-999 | 0.6 | 1.66 | 0.80 | 1.25000 | 2.08333 |
| 250-499 | 0.4 | 2.50 | 0.60 | 1.66666 | 4.16666 |
| 100-249 | 0.2 | 5.00 | 0.50 | 2.00000 | 10.0000 |
| 1-99 | 0.1 | 10.00 | 0.40 | 2.50000 | 25.0000 |

Note that final estimation weight is equal to product of the sampling and nonresponse weights: $\omega_i^F = \omega_i^S \text{ x } \omega_i^{NR}$

10

<!-- page 11 -->

# Example (cont’d) - Weights

Calculate the final weight as the product of the sampling and nonresponse weights.

| Establishment employment | Selection Probability | Sampling Weight | Response Rate | Nonresponse Weight | Final Weight |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 2,500 plus | 1.0 | 1.00 | 0.70 | 1.42857 | 1.42857 |
| 1,000-2,499 | 0.8 | 1.25 | 0.80 | 1.25000 | 1.56250 |
| 500-999 | 0.6 | 1.66 | 0.80 | 1.25000 | 2.08333 |
| 250-499 | 0.4 | 2.50 | 0.60 | 1.66666 | 4.16666 |
| 100-249 | 0.2 | 5.00 | 0.50 | 2.00000 | 10.0000 |
| 1-99 | 0.1 | 10.00 | 0.40 | 2.50000 | 25.0000 |

11

<!-- page 12 -->

# Example: Microdata with weights

| Establishment ID | Establishment employment | ... | Final Weight |
| :---: | :---: | :---: | :---: |
| 10001 | 270 | | 4.16666 |
| 10002 | 403 | | 4.16666 |
| 10003 | 588 | | 2.08333 |
| 10004 | 1500 | | 1.56250 |
| 10005 | 10 | | 25.0000 |
| ... | | | |

12

<!-- page 13 -->

# Propensity score nonresponse weighting adjustment

* Define variable RESPONSE =1 if sample unit responds, =0 if not
* Fit a statistical model with RESPONSE as dependent variable and unit characteristics as independent variables
  * Observations for respondents and nonrespondents used to estimate the propensity model
  * Only characteristics available for all units in the sample may be included in the model
* Use regression coefficients to estimate for each responding unit the probability of response ($\pi_i$) for a unit with its characteristics
* Calculate nonresponse weight adjustment factor $\omega = 1/\pi_i$ for all responding units

13

<!-- page 14 -->

# Calibration

* Calibration methods use auxiliary information from some reliable external source (e.g., Current Population Survey, American Community Survey) to adjust the survey weights
* Common approaches
  * Post-stratification
  * Raking (iterative proportional fitting)
* Goal is for reweighted sample to represent population of interest on *observed* variables.

14

<!-- page 15 -->

# Post-stratification

* To construct post-stratification weighting factors, need to know:
  * Control totals (or shares) from external source
  * Weighted totals (or shares) from survey
  * Post-stratum identifier for each unit responding to the survey
* Steps in post-stratification as follows:
  * Define post-strata
  * Calculate control total for each post-stratification cell

15

<!-- page 16 -->

# Post-stratification (cont'd)

* Calculate post-stratification adjustment factor
$$\omega_i^{PS} = T_d / \sum_{i \varepsilon R_d} \omega_i^S$$
  where $\text{R}_\text{d}$ is the set of survey *Rs* and $\text{T}_\text{d}$ the control total for post stratification cell d

  That is: weighting adjustment factor equals ratio of the control cell total to the weighted survey cell total

* Example:
  * Suppose that weighted estimate from survey shows sample is 56% female and 44% male
  * American Community Survey indicates correct proportions are 52% female and 48% male
  * Post-stratification adjustment factors would be 52/56 and 48/44

16

<!-- page 17 -->

# Raking

* Raking (iterative proportional fitting) adjusts survey numbers in a two-way table to match marginal totals from an alternative source
  * Still need control totals; but don’t need detailed demographic data such as the breakdown of age, gender, and race.
* Procedure adjusts row totals, then column totals, then row totals and so on until convergence achieved
  * Multiply survey row shares by control row total
  * Multiply survey column shares by control column total
  * Repeat until survey marginals match control marginals sufficiently closely
* Weighting adjustment factor equals ratio of adjusted survey cell values to original survey cell values

17

<!-- page 18 -->

# Raking example

Start here ->

| INITIAL | Female | Male | Survey Total | Control Total |
| :--- | ---: | ---: | ---: | ---: |
| Rural | 20 | 17 | 37 | 57 |
| Urban | 39 | 24 | 63 | 43 |
| Survey Total | 59 | 41 | 100 | |
| Census Total | 49 | 51 | | 100 |

| RD1 | Female | Male | Survey Total | Control Total |
| :--- | ---: | ---: | ---: | ---: |
| Rural | 30.81 | 26.19 | 57 | 57 |
| Urban | 26.62 | 16.38 | 43 | 43 |
| Survey Total | 57.43 | 42.57 | 100 | |
| Census Total | 49 | 51 | | 100 |

1. Row totals are adjusted

| RD2 | Female | Male | Survey Total | Control Total |
| :--- | ---: | ---: | ---: | ---: |
| Rural | 26.29 | 31.38 | 57.66 | 57 |
| Urban | 22.71 | 19.62 | 42.34 | 43 |
| Survey Total | 49 | 51 | 100 | |
| Census Total | 49 | 51 | | 100 |

2. Column totals are adjusted

| RD3 | Female | Male | Survey Total | Control Total |
| :--- | ---: | ---: | ---: | ---: |
| Rural | 25.99 | 31.01 | 57 | 57 |
| Urban | 23.07 | 19.93 | 43 | 43 |
| Survey Total | 49.05 | 50.95 | 100 | |
| Census Total | 49 | 51 | | 100 |

3. Row totals are adjusted again...

18

<!-- page 19 -->

# Raking example (continued)

* If numbers from RD3 deemed to be acceptable (in practice likely would iterate further to get a closer match to control totals), weighting adjustment factors would be:
  * $25.99/20$ for rural females
  * $31.01/17$ for rural males
  * $23.07/39$ for urban females
  * $19.93/24$ for urban males

19

<!-- page 20 -->

# Which weighting variables are best?

* Most important features:
  * Predictive of outcome of interest
  * Predictive of participation in the survey
* Demographic variables often used
  * For example: household surveys are commonly calibrated to match characteristics of population by age, sex, race, education, presence/absence of children in household
  * Assumed to be correlated with a wide-range of outcomes
  * Often correlated with nonresponse (or non-coverage)
  * Control totals from external sources are available

20

<!-- page 21 -->

# Which weighting variables are best? Cont’d

* Choice of variables can matter
* Example: 2016 state-level election polls (Kennedy et al. 2017)
  * Standard nonresponse reweighting based on age and sex. Education was omitted.
  * But education was predictive of propensity to respond **and** vote intention
  * Result: several state-level estimates of support for Clinton were biased upward
* Example: American Time Use Survey (Abraham, Helms, & Presser 2009)
  * Standard nonresponse reweighting in the ATUS accounts for sex, age, race, education and presence of children
  * But volunteer activity is predictive of the propensity to respond **and** how people spend their time
  * Result: estimates of volunteer time are biased upward

21

<!-- page 22 -->

# Web panel surveys

* Web panel surveys are a response to increasing cost and decreasing response rates of traditional surveys, along with growing internet coverage
  * Pew estimates that internet usage among US adults grew from 52% in 2000 to 93% in 2021, though usage rates still lag among less-educated, lower income and older adults
  * No good general purpose frame of personal email addresses. Web panel members recruited through various means
  * Probability-based panels considerably less common than nonprobability/volunteer panels
    * Recruitment may start with RDD or ABS sampling
    * In some cases, individuals who lack them may be offered devices and internet service in exchange for participation
  * Nonprobability/volunteer panels may use co-registration agreements, reward program websites, display banners on various websites, and online advertisements tied to search terms

22

<!-- page 23 -->

# Web panel surveys (cont’d)

* Joining a nonprobability/volunteer panel a two-step process
  * Express interest and supply email address
  * Confirm interest and (often) complete a profiling survey
* Web panel used as frame for specific surveys
  * Active members commonly offered incentives to complete surveys to which they are invited
  * Panel may limit invitations to any individual panel member to avoid survey fatigue or survey conditioning effects
* Firms that operate Web panels often have considerable information about members
  * Responses may be reweighted based on observed characteristics to better match characteristics of the target population

23

<!-- page 24 -->

## Figure 1
## Volunteer Panel Web Survey Protocol

---

**Coverage** $\rightarrow$ **Recruitment** $\rightarrow$ **Sampling** $\rightarrow$ **Response**

* **Population**
* **Web Population**
* **Web Survey Panel**
* **Web Survey Sample**
* **Web Survey Respondent**

---

Source: Lee (2004).

24

<!-- page 25 -->

# Reweighting nonprobability Web panels

* Methods similar to those described for probability surveys have been suggested to reweight the data collected for nonprobability panels
* Calibration adjustments reweight observations in Web panel survey to match in characteristics in some reference data set, such as the CPS or ACS
* Propensity score reweighting requires data for the Web panel and a reference data set containing the set of weighting variables (usually demographics). Process as follows:
  * Create a combined data set consisting of the Web panel responses and the reference observations
  * Fit a propensity score model with 1=Web survey observation, 0=reference data set observation as the dependent variable, characteristics as explanatory variable

25

<!-- page 26 -->

# Reweighting nonprobability Web panels (cont’d)

* Sort the combined data set based on the predicted probability of being in the Web survey sample
* Divide the sorted list into groups of equal size (e.g., quintiles)
* Weighting adjustments for the Web responses calculated as ratio of the share of reference group responses in the group to the share of Web responses in the group
  * Example: 30 percent of Web responses and 10 percent of reference group responses in top quintile of combined data set. Weight adjustment for Web responses in that quintile would be 10/30

26

<!-- page 27 -->

# What can be concluded from estimates based on volunteer panels?

* If weighting variables (typically demographics) capture all of the survey respondent characteristics that affect selection into the sample, may be possible to draw population inferences. Easy to imagine this not being the case.
    * For example: respondents to a survey on political attitudes could be disproportionately those with strong views one way or the other, leading to political polarization being overstated
* Some conclusions may be more robust
    * relationships between characteristics
    * responses to differences in question wording or different attributes of potential new products
    * trends over time

27

<!-- page 28 -->

# Representation errors in non-survey data

- Many different types of non-survey data
  - Administrative data (e.g. unemployment insurance records, food stamp records, tax records, payroll records, price lists)
  - Commercial transaction data (e.g., scanner data, credit card data)
  - Data derived from individual interaction with the internet (e.g., Twitter, Facebook, Google searches)
- Hard to generalize about representation issues across diverse potential data sources
  - Will consider some examples

28

<!-- page 29 -->

# Statistical uses of administrative data

* Population covered by administrative data generally well defined
  * Federal tax data: All individuals for whom tax records exist or businesses on the IRS Business Master File
  * Medicare data: All people who are covered by Medicare
* Some uses involve administrative data on their own
  * Common simply to define population of interest to be the covered population
* Some uses involve linking survey data and administrative data
  * Usable cases may consist of survey respondents who have given their permission to link to the administrative data

29

<!-- page 30 -->

# Example: Using administrative data to augment survey responses

* Annual Social and Economic Supplement (ASEC) to the Current Population Survey (CPS) contains a Personal Identity Key (PIK) that can be used within the Census firewall to link CPS responses to UI and federal income tax records
* Issue: PIK missing for 20 to 30 percent of records
* Approach: Use propensity scores to reweight the ASEC records for which a PIK is available
  * Using full set of ASEC records, regress a 0/1 dummy variable for presence of a PIK on variables capturing age group, gender, race, education, marital status, foreign-born status, state of residence, and whether the person reported being employed
  * For sample of observations with a PIK, calculate estimated probability that person with those characteristics will have a PIK
  * Apply inverse of estimated probability as weight adjustment and carry out analysis using records with a PIK

Source: Abraham et al., “Measuring the Gig Economy,” 2018.

30

<!-- page 31 -->

# Statistical uses of commercial transactions data

* Various types of commercial transactions data have been identified as potentially valuable for replacing or augmenting survey data. Some examples:
  * Scanner and online price data used to track consumer prices
  * Credit card data used to extrapolate retail sales
  * Data for a customers of a bank used to construct measures of income and spending
  * Data for users of a financial aggregation and services app used to construct measures of income and spending
* Representation issues with all of these data sources
  * Scanner and online price data limited to certain stores and items
  * Credit card data exclude purchases by cash or check
  * Customers of any single bank unlikely to be representative of the population as a whole (and excludes the unbanked)
  * Users of financial aggregation apps may be less concerned about privacy, more tech savvy, or need more help with their financial affairs

31

<!-- page 32 -->

# Check users vs. American Community Survey

Percent distribution by sex, age, highest degree and region

Source: Gelman et al. (2014)

| | Check | ACS |
| :--- | ---: | ---: |
| *Sex* | | |
| Male | 59.93 | 48.59 |
| Female | 40.07 | 51.41 |
| *Age* | | |
| 18–20 | 0.59 | 5.72 |
| 21–24 | 5.26 | 7.36 |
| 25–34 | 37.85 | 17.48 |
| 35–44 | 30.06 | 17.03 |
| 45–54 | 15.00 | 18.39 |
| 55–64 | 7.76 | 16.06 |
| 65+ | 3.48 | 17.95 |
| *Highest degree* | | |
| Less than college | 69.95 | 62.86 |
| College | 24.07 | 26.22 |
| Graduate school | 5.98 | 10.92 |
| *Census Bureau region* | | |
| Northeast | 20.61 | 17.77 |
| Midwest | 14.62 | 21.45 |
| South | 36.66 | 37.36 |
| West | 28.11 | 23.43 |

32

<!-- page 33 -->

# Distribution of income: Check users versus American Community Survey

## Household income

## Paycheck and Social Security income

Source: Gelman et al (2014)

33

<!-- page 34 -->

# Statistical uses of commercial transactions data (continued)

* Statistical agencies exploring potential of commercial data to improve early estimates and/or support geographically disaggregated estimates of prices, sales and revenues
  * Even if data suffer from coverage limitations, short term movements for covered groups may parallel short term movements for the target population
    * Billion Prices Project
    * MasterCard on retail trade receipts
    * Anthem Health data on payments to physicians
  * Share of sales or revenue by geography may be suspect, but growth rates by geography may be more meaningful

34

<!-- page 35 -->

A: Price index

B: Annual inflation rate

C: Monthly inflation rate

Source: Cavallo and Rigabon (2016)

35

<!-- page 36 -->

# Monthly changes in credit card and total retail trade (less autos)

BEA
BUREAU OF ECONOMIC ANALYSIS
U.S. DEPARTMENT OF COMMERCE
www.bea.gov @BEA_News

12

36

<!-- page 37 -->

# Statistical uses of data derived from individual interaction with the internet

- Different types of data generated through interaction with the internet can be accessed
  - Tweets containing user-specified keywords
  - Public posts using the Facebook API
  - Google Trends allows users to track relative frequency of specified search terms over time, nationally or disaggregated by geography
- Tweeters, posters and Google searchers unlikely to be a representative group
  - May think of unit of observation as the Tweet, post or search rather than the person
  - Depending on intended use, appropriate way to conceive of representation for these data may be different than for traditional survey data
    - Possible that topics of Tweets, posts and searchers are representative of broader public conversation, even if posters and searchers are not representative (Schober et al 2016)
  - Characteristics of users vary by site (see next slide)

37

<!-- page 38 -->

# Use of Social Media Sites by Education in U.S.

Low Edu: high school or less
Mid Edu: some college
High Edu: college degree or more

Source: Hargittai (2018)

38
