---
id: "jpsm/fund_data_coll_1_SURV621/lectures/Lecture_2_Errors_of_representation"
source: "jpsm"
course: "SURV621"
course_title: "Fundamentals of Data Collection I"
doc_type: "lecture"
title: "SURV 621/SURVMETH 621: COVERAGE AND NONRESPONSE ERROR IN PROBABILITY SURVEYS"
original: "fund_data_coll_1_SURV621/lectures/Lecture 2 Errors of representation.pdf"
pages: 32
sha256: "6506eba64b905d51a0fb356070657a263e91d1522f7eeba54045d5ea2043d96d"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:00"
---

<!-- page 1 -->

# SURV 621/SURVMETH 621: COVERAGE AND NONRESPONSE ERROR IN PROBABILITY SURVEYS

September 9, 2024

<!-- page 2 -->

# What is meant by “probability sample”?

* Refers to any method of sampling that utilizes some form of random selection
  * Every unit has a known nonzero chance of selection into the sample
* By contrast, non-probability sampling does *not* involve random selection
  * Example: all units that volunteer to participate are included in the sample

2

<!-- page 3 -->

# Errors of representation in survey data

* *Coverage error* – Error that arises because some members of the target population are not represented on the sample frame
* *Sampling error* – Error that arises because only a portion of the frame population is sampled
* *Nonresponse error* – Error that arises because some sampled units do not respond
* *Adjustment error* – Error that arises because of errors in post-survey reweighting

3

<!-- page 4 -->

* Coverage error

* Sampling error

* Nonresponse error

* Adjustment error

4

<!-- page 5 -->

# What is the target population?

* First step in thinking about coverage error: Defining the population of interest
* What must be specified?
  * Desired population units
    * Examples: People, households, business establishments, website visits
  * Eligibility criteria
    * Examples: Civilian non-institutionalized population of the 50 states and the District of Columbia age 18 and older. Non-farm businesses with U.S. operations that employ three or more people
  * Reference point or period
    * Examples: People resident in the United States as of April 1, 2020. Businesses that generated gross revenue during the first quarter of 2019.

5

<!-- page 6 -->

# Frames for probability surveys of households and organizations

* A frame is the set of materials used to identify the elements of the population of interest
* Types of frames include:
  * Area frames
  * RDD frames
  * Address-based frames
  * Other list frames

6

<!-- page 7 -->

# Potential survey frame issues

* Missing units (under-coverage)
* Inclusion of ineligible units (over-coverage)
* Clustering of target population elements within frame elements. Examples:
  * Multiple people in each household
  * Multiple establishments in each enterprise
* Duplication of target population elements. Examples:
  * Individuals may have multiple residences
  * Individuals may have both a landline and a cell phone

7

<!-- page 8 -->

# Under- and over-coverage in a sample frame

Target Population

Ineligible Units

Undercoverage

Covered Population

Ineligible Units

Undercoverage

Frame Population

8

*[Figure: This conceptual Venn-style diagram uses two overlapping rectangles (without axes) to compare the "Target Population" (shaded rectangle) and the "Frame Population" (unshaded rectangle). The overlapping area represents the "Covered Population," while the non-overlapping sections illustrate "Undercoverage" (within the target population only) and "Ineligible Units" or over-coverage (within the frame population only).]*

<!-- page 9 -->

# Coverage bias

* Coverage bias in a mean: $\bar{Y}$

$$= \bar{Y}_C - \bar{Y}$$

$$= \frac{U}{N} (\bar{Y}_C - \bar{Y}_U)$$

  * U = number of uncovered units
  * N = total number of units in target population
  * Subscripts c and u refer to covered and uncovered populations, respectively

* The magnitude of *coverage bias* depends both on the share of target population units that are not covered <u>and</u> on how different these units are from the units that are covered
* Having units on the frame that do not belong there reduces efficiency, but need not cause bias

Coverage bias a characteristic of the *estimate* rather than the *survey*.

9

<!-- page 10 -->

# Illustration: Coverage bias

* Suppose that you are doing an RDD survey to assess attitudes towards the governor in your state in which you will dial blocks of landline numbers
* The share of individuals with a landline varies by age, as do attitudes towards the governor:

| Age | Percent with landline | Percent with favorable view of governor |
| :--- | :---: | :---: |
| 18-39 years | 50% | $X\%$ |
| 40 plus years | 100% | $(X+30)\%$ |

* Half of the adult population in your state is age 18-39 years and half is age 40 plus years.
* Given these facts, what is the coverage bias in your estimate?

10

<!-- page 11 -->

# Illustration: Coverage bias (continued)

- Overall favorability towards the governor would be a weighted average of favorability among younger and older adults

$$y = (1/2)X + (1/2)(X + 30) = X + 15$$

- Favorability among those covered by the RDD frame would be

$$y_c = (1/3)X + (2/3)(X + 30) = X + 20$$

- Coverage bias would be

$$y_c - y = (X + 20) - (X + 15) = 5$$

What would happen if no young people had landlines?

11

<!-- page 12 -->

# Areas frames

* Area frame consists of geographical units.
* Basic procedure for a survey targeting people:
  * Select subset of areas
  * List housing units within those areas
  * Select subset of housing units
  * Create roster of individuals resident in selected housing units created
* Area frame requires a residence rule for deciding where a person lives. Want a rule that counts people *once* and *only once*. Can be complicated.
  * Where are people who have multiple residences counted?
  * Where are college students away at school counted?
  * Where are people who do not have a usual residence counted?

12

<!-- page 13 -->

# Area frames (continued)

* Household rostering is not a trivial exercise
  * Some non-reporting by households may be deliberate (Tourangeau, Kreuter, & Eckman 2012)
    * If people are able to ascertain what kind of people the interviewer is looking for, may be less likely to report that there is that kind of person in the household
  * Reporting also may reflect a lack of clarity about whether a person should be counted (Martin 1999)
    * Some evidence, for example, that whether a person is currently present or absent affects reporting, independent of actual status

13

<!-- page 14 -->

# RDD frames

* Consists of landline telephone numbers
  * Landline phone exchanges (area code plus first three digits) are assigned to distinct geographies
* Basic procedure:
  * Define banks of 100 landline phone numbers with the same area code and next 5 digits (e.g., 301-405-15<u>00</u> through 301-405-15<u>99</u>)
  * Identify banks with some minimum number of listed residential phone numbers (e.g., one or more, three or more)
  * Randomly call phone numbers from the banks containing the required minimum number of listed residential numbers
  * When an adult answers the phone at a residential address, use some specified procedure to select the desired survey respondent, such as rostering (and random selection) or the most recent birthday method
* Landline-only samples increasingly problematic, given large share of cell-phone-only households
  * In 2023, 75.2% of U.S. adults were cell-phone only (Blumberg and Luke 2024)

14

<!-- page 15 -->

# RDD frames (cont’d)

* Incorporating cell phones into an RDD survey (“dual-frame survey”)
  * Cell phone numbers are portable, so provide less accurate information about where the respondent lives
  * By law, cell phone numbers must be dialed manually rather than autodialed (more expensive)
  * Varying selection probabilities
    * Cell phones are generally individual, whereas landlines generally serve an entire household
    * Some people may have both a landline and a cell phone
    * For each respondent, need to know number of landlines, number of cell phones (generally assumed to be no more than one), and household size
  * Under-coverage of individuals who have no phone (very small share of population)

15

<!-- page 16 -->

# Address-based sampling frames

* U.S. Postal Service Delivery Sequence File (DSF) is increasingly used as a household survey sampling frame
  * Initial studies show ABS coverage rates for general population surveys may be 97 percent or more
* Potential issues with ABS frames
  * Better coverage in urban than rural areas
  * Households may have multiple mailing addresses (e.g., P.O. Box and a street address, summer and winter homes)
  * Multiple households may pick up their mail from a single drop point (concentrated in New York and Chicago)
  * Potential delivery units may be vacant
  * Some listed addresses may be businesses not residences

16

<!-- page 17 -->

# Other lists as sample frames

* List of known members of a group, usually compiled for some other purpose, often with email addresses. Examples:
  * Employee lists from company
  * Students lists from university
  * Members of professional association
  * Administrative records
  * Pre-recruited panels or past studies
* Good quality *if* the organization that maintains the list devotes substantial effort to:
  * Introducing “births”
  * Removing “deaths”
  * Updating names and supporting information
  * Removing duplicates
  * Documenting links between units

17

<!-- page 18 -->

* Coverage error

* Sampling error

* Nonresponse error

* Adjustment error

18

<!-- page 19 -->

# Response rate

* The share of the eligible sample that participates
* Response rate formulas from AAPOR are widely used
* These formulas use six mutually exclusive categories:
  * Completed cases
  * Partial cases
  * Eligible refused cases (i.e., refusals)
  * Noncontacted sample units known to be eligible (i.e., noncontacts)
  * Eligible sample units not responding for reasons other than refusal
  * Sample units of unknown eligibility, not completed

Cases that are known to be “not eligible” are excluded from response rate calculations.

19

<!-- page 20 -->

# Some useful notation for calculating standard response rates

I = number of completed cases

P = number of partial cases

R = number of eligible refused cases

NC = number of noncontacted sample units known to be eligible

O = number of eligible sample units not responding for reasons other than refusal

U = number of sample units of unknown eligibility, not completed

20

<!-- page 21 -->

# Unweighted AAPOR unit response rates

$$
RR1 = \frac{I}{(I + P) + (R + NC + O) + U}
$$

$$
RR2 = \frac{I + P}{(I + P) + (R + NC + O) + U}
$$

$$
RR3 = \frac{I}{(I + P) + (R + NC + O) + eU}
$$

$$
RR4 = \frac{I + P}{(I + P) + (R + NC + O) + eU}
$$

$e$ is a "guess" about the share of cases with unknown eligibility that would have been eligible.

The value used for $e$ is typically the eligibility rate among those who were actually screened.

21

<!-- page 22 -->

# Unweighted AAPOR unit response rates (continued)

$$
RR5 = \frac{I}{(I + P) + (R + NC + O)}
$$

$$
RR6 = \frac{I + P}{(I + P) + (R + NC + O)}
$$

22

<!-- page 23 -->

# Weighted unit response rates

Weighted unit response rate:

$$RRW1 = \frac{\sum \omega_i I_i}{\sum \omega_i (\text{I}_i + P_i + R_i + NC_i + O_i + U_i)}$$

Measure-of-size weighted response rate

$$RRMOSW1 = \frac{\sum \omega_i y_i I_i}{\sum \omega_i y_i (\text{I}_i + P_i + R_i + NC_i + O_i + U_i)}$$

where $\omega_i$ is the inverse of the selection probability for the unit in question and $y_i$ is its measure of size

23

<!-- page 24 -->

# Cumulating survey nonresponse

In hierarchical surveys, need to account for nonresponse at multiple levels:

$$
RRO_c = \prod_{i=1}^{K} RRU_i
$$

where $\text{RRU}_i$ is the response rate for the ith stage and K is the number of stages

In panel surveys, need to account for nonresponse over multiple time periods
* For a longitudinal analyses, responses for all of the periods included in the analysis required
* Denominator of effective response rate is the set of all cases sampled in the first wave of the survey

In probability-based internet panels, nonresponse occurs at several stages:
* Initial recruitment -> Profile survey -> Particular survey of interest

24

<!-- page 25 -->

# Categorizing contact attempts

* Common to make multiple contact attempts for a case
  * E.g., 5 phone calls
* Contact attempts can also be categorized into different categories
  * Appropriate procedures for categorizing cases will vary depending on type of survey (e.g., in-person household survey, telephone survey, mail survey addressed)
  * See AAPOR Disposition Codes (2016)

25

<!-- page 26 -->

# Unit response rates, selected household surveys

**Response Rate**
- 1
- 0.95
- 0.9
- 0.85
- 0.8
- 0.75
- 0.7
- 0.65
- 0.6
- 0.55
- 0.5

**Survey Year**
- 1984
- 1988
- 1992
- 1996
- 2000
- 2004
- 2008
- 2012
- 2016

- CPS-ASEC
- SIPP (Wave 1)
- NHIS
- CE Survey

Source: Meyer, Mok and Sullivan (2015), adapted and updated

26

<!-- page 27 -->

# Nonresponse in selected BLS establishment surveys

27

<!-- page 28 -->

# Nonresponse bias

Nonresponse bias depends on (1) level of nonresponse and (2) differences between respondents and nonrespondents:

$$
B(\bar{y}_r) = \bar{y}_r - \bar{y}_t = (\frac{n_{nr}}{n})(\bar{y}_r - \bar{y}_{nr})
$$

where $\bar{y}$ represents the mean and n the number of cases for respondents (subscript r), nonrespondents (subscript nr) or total (subscript t).

Nonresponse bias a characteristic of the *estimate* rather than the *survey*.

28

<!-- page 29 -->

# Methods for assessing nonresponse bias

* Compare estimates obtained to estimates from other sources (benchmarking)
* Compare characteristics of responders and nonresponders
  * Information on sampling frame
  * Responses to screener interviews
  * Responses to other survey waves
* Compare responses given by different groups of respondents
  * Early vs. late responders
  * Nonresponse follow-up studies

29

<!-- page 30 -->

# Survey response rates and nonresponse error

(Groves and Peytcheva 2008)

**Figure 2.** Percentage Absolute Relative Nonresponse Bias of 959 Respondent Means by Nonresponse Rate of the 59 Surveys in Which They Were Estimated.

30

*[Figure: This scatter plot shows the "Percentage Absolute Relative Bias of Respondent Mean" on the vertical axis (ranging from 0 to 100) plotted against the "Nonresponse Rate" on the horizontal axis (ranging from 0 to 80) for 959 estimates across 59 surveys. The data points form vertical clusters between nonresponse rates of roughly 14 and 72, demonstrating no clear correlation between a survey's nonresponse rate and the magnitude of nonresponse bias, as most bias estimates remain below 20% regardless of the nonresponse rate.]*

<!-- page 31 -->

# Survey response rates and study-level nonresponse error (Brick and Tourangeau 2017)

The bubble sizes are proportional to the number of bias estimates from the study.

Mean absolute relbias
50
40
30
20
10
0
–10

Study response rate
20 30 40 50 60 70 80 90 100

*“Response rates may not be very good predictors of nonresponse bias, but they are far from irrelevant.”*

31

<!-- page 32 -->

# Increasing survey response rates

* Offering incentives for survey response
    * Pre-paid and/or post-paid
* Front-end techniques
    * Advance notification
    * Personalization of correspondence
    * Describing to respondent how data are used
* Follow-up techniques
    * Reminder cards, emails, or phone calls
* Changing interviewer conditions
    * Interviewer training (e.g., to match their response to reasons for refusal)
    * Interviewer evaluations based on response rates

32
