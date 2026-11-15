---
id: "jpsm/Fund_data_collection_SURV622/lectures/Lecture_#11_Evaluating_Measurement_Quality"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lecture"
title: "Evaluating Measurement Quality"
original: "Fund_data_collection_SURV622/lectures/Lecture #11 Evaluating Measurement Quality.pdf"
pages: 35
sha256: "e6cb5a46a3014638a8972c3cffa7692aebc0a8d3b2fbd3d61fe2b1439c38f751"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:00"
---

<!-- page 1 -->

# Evaluating Measurement Quality

Fundamentals of Data Collection II
Frederick Conrad
April 21, 2025

<!-- page 2 -->

# Why Evaluate Measurement Quality?

- Despite following best practices for research design, the data that are collected – the individual observations – are not necessarily accurate
- This is measurement error
  - usually defined as the difference between observed and true values
- True value is usually unknowable
  - if known, no reason to collect data
- but numerous proxies for the true value have been used creatively over the years

2

<!-- page 3 -->

# Outline

* Direct Measures/Gold Standards
  - Administrative Records
  - Passively Measured (e.g., Sensor) Data
  - Scenarios/Vignettes
* Indirect Measures
  - Response change between waves
  - Benchmark surveys (e.g., gov’t telephone surveys)
  - Response Distributions
* Correlational Measures $\Big\}$ aggregate measures
  - Concurrent/predictive validity
* Surveys as gold standard in evaluating organic data

❖ most examples presented previously in SM 621 or SM 622

3

<!-- page 4 -->

# Validating Responses with Administrative Records

* Records of *Rs'* attributes, behaviors, etc., may exist that can validate their self-reports in methodological studies
* Different in spirit from “record linkage”
  – which is usually done to avoid asking survey *Qs* if relevant data already exist or to expand set of analytic *Qs* that can be answered
* But involves many of same steps and challenges
  – e.g., identifying *Rs'* records despite imperfect name match

4

<!-- page 5 -->

# Administrative Records, Example 1

* More variation in responses between *Iwers* (higher $\rho_{\text{int}}$) is typically assumed to reflect differences in how *Iwers* conduct interviews
  * i.e., more variance between *Iwers* => more *measurement error*
* West and Olson (2010) point out that high $\rho_{\text{int}}$ might be due not only to measurement error but also to differential *nonresponse* error
  * i.e., different true values in the subsamples interviewed by different *Iwers* is possible (despite interpenetrated design) due to different <u>recruitment</u> approaches and outcomes
  * different types of *Rs* are selected – i.e., agree to be interviewed – by different *Iwers*, presumably due to differences in recruitment strategies and abilities
* West and Olson (2010) used administrative records to quantify relative contributions to $\rho_{\text{int}}$ of nonresponse (recruiting) and measurement (interviewing)

5

<!-- page 6 -->

# Admin. Records, Example 1 (cont’d)

* Wisconsin Divorce Study (WDS) sampled potential participants from frame of 733 divorce certificates from four counties in WI; design “approximates” interpenetration
* Divorce certificates included “official information” also collected in WDS
  - Divorce dates, marriage dates, birth dates, etc.
  - assumed to be error-free, although also self-reported
* Divorce records enable evaluation of error due to measurement <u>and</u> nonresponse
  - Measurement error: discrepancy between survey responses and values in records
  - Nonresponse error: differences between values in records for those who did and did not participate
  - Differences between *Iwers* in either type of error will be reflected in higher $\rho_{\text{int}}$
* Evidence of both types of error in different questions:
  - Two Qs produced interviewer effects ($\rho_{\text{int}}$ significantly $> 0$): *Age at Marriage* and *Age at Divorce*
  - Based on records, effect for *Age at Marriage* due to measurement error, but effect for *Age at Divorce* due to nonresponse error

6

<!-- page 7 -->

# Administrative Records, Example 2

* Debate over pros and cons of standardized interviewing (SI) concerns impact of misunderstanding *Qs* on response accuracy
  * Holding *Q* wording constant assumed to promote comparability of responses
  * but blocks *conversational grounding*, i.e., *Iwer* and *R* making sure on same page
* Conversational Interviewing (CI) proposed as method of improving response accuracy by improving – standardizing – *Rs'* <u>comprehension</u> of *Qs*
  * *Iwers* able to assure *R* understands *Q* as intended (to "ground meaning")
  * but could increase $\rho_{\text{int}}$ if CI implemented differently by different *Iwers*
* West et al. (2017) assessed these concerns by combining response accuracy and interviewer variance (IIC\*) in Mean Square Error (MSE)
  * calculated response accuracy – actually inaccuracy (bias) -- by computing discrepancy between responses and admin (employment) records

\* IIC = Intra-Interviewer Correlation; same as $\rho_{\text{int}}$

7

<!-- page 8 -->

# Admin. Records, Example 2 (cont’d)

* West et al. (2017) report that, based on admin records, CI led to significantly <u>higher accuracy</u> than SI for the one $Q$ for which admin data was available
* For this $Q$, <u>more *Iwer*-variance</u> (higher IIC) for CI than SI
* So more accurate answers but more *Iwer*-variance in CI – which really reflects data quality under CI?
* When combined into *MSE*,* increased IIC for CI was <u>outweighed</u> by higher response accuracy (match with records), suggesting greater overall quality for CI than SI

*MSE is squared bias (discrepancy between records and responses ) plus variance (including IIC)

8

<!-- page 9 -->

# Challenges Using Admin. Records for Validation

* Unless survey *Qs* are written with existing records in mind, unlikely that useful records will be available
* Data management and data manipulation
* Timeliness of admin. data
  – Available records may lag survey data by several years
* Consent bias
  – response accuracy may differ for consenters and non-consenters
* Inaccuracies exist in records
  – especially if records created from self-reports, e.g., tax records

9

<!-- page 10 -->

# Sensor Data

* Data passively collected with sensors native to smartphone or with wearable sensors (e.g., FitBits) are sometimes used to validate self-reports
  * Objective measures, e.g., steps or geo coordinates
  * no forgetting or lapse in attention by participant

* Scherpenzeel (2018) tracked participants’ travel behavior with app and asked them to self-report their trips
  * App tracked trips using GPS, cell tower triangulation, and Wi-Fi
  * App registered about 7% more trips per day than self-reported trips suggesting self-reports underestimate actual travel

* But sensor (GPS) data not always perfectly accurate
  * intermittent measurement in “urban canyons”
  * Participants deleted some passively detected trips from the list of passively measured trips suggesting some ”false alarms” in sensor data
    * 14% indicated “certainly not true” that app “detected my trips correctly”

10

<!-- page 11 -->

# Scenarios

* Instead of asking *Rs* to answer about their own lives, they can be asked to respond to fictional scenarios for which true value known
  – because researchers create the scenarios with the correct answer in mind
* This approach has been used to compare <u>response accuracy</u> in SI and CI
* In CI, *Iwers* can communicate intended interpretation to *Rs* based on official definitions
* But in SI, *Iwers* can only use neutral probes like “whatever it means to you” or “let me repeat the question”

11

<!-- page 12 -->

# Scenarios (2)

* Example:
  * *Q* asks about any purchases for household furniture
  * scenario is a receipt for purchase of a lamp
  * definition excludes lamps and lighting fixtures from “household furniture”
  * correct answer – true value – is “no”
* Schober & Conrad (1997) used this approach for 12 *Q*s, creating a straightforward and complicated (ambiguous) scenario for each
  * Main research question was can CI resolve ambiguity in complicated scenarios (like receipt for lamp purchase) and improve response accuracy

12

<!-- page 13 -->

# Response Accuracy (Agreement with Definition)

% Correct

* 100
* 90
* 80
* 70
* 60
* 50
* 40
* 30
* 20
* 10
* 0

* Straightforward
* Complicated

Standardized

Conversational

## Interview Type

13

13

<!-- page 14 -->

# Challenges Using Scenarios for Validation

* Ecological validity:
  - response processes may differ from those in actual interview so results may not generalize
  - although in SI-CI comparisons, results are consistent across other validation measures
* Mostly applied to comprehension processes; not typically used to validate measurement where recall, estimation, and response selection are at issue

14

<!-- page 15 -->

# Response Change Across Interviews

* In typical reinterview studies\* consistency or reliability across interviews is taken as evidence of high-quality responses
  - If administration is identical across first interview and re-interview, minimal change between waves indicates high quality data
  - Substantial change between interview and re-interview is a red flag
* <u>But</u> logic can be reversed for assessing measurement quality:
  - if experimental treatment is administered in reinterview that is intended to improve response quality, change in response (in expected direction) indicates improvement, all else being equal

\* e.g., McGovern & Bushery, 1999

15

<!-- page 16 -->

# Response Change, Example

* Conrad & Schober (2000) asked *Q*s via SI in Wave 1 but in second wave re-asked *Q*s via CI for half *R*s, SI for other half *R*s
* If CI improves comprehension (and, presumably, response accuracy) in second interview, we expect more response change between wave 1 answers (SI) and wave 2 answers when *Q*s re-asked in CI than SI
  – Second administration should repair wave 1 misconceptions

16

<!-- page 17 -->

# Results: Response Change

* More responses changed when second interview was conversational than standardized

**INTERVIEW 1**

**INTERVIEW 2**

Standardized (n=227)

11% $\longrightarrow$ Standardized (n=118)

22% $\longrightarrow$ Conversational (n=109)

17

<!-- page 18 -->

# Benchmarks

- Studies that evaluate impact of data collection mode and sample source on survey estimates sometimes treat estimates from trusted source as true value, i.e., benchmark
  - e.g., government surveys: high response rates and considerable expense and care is invested in their quality
- Accuracy (or its inverse, bias) is deviation between estimates (e.g., mean, %) based on a survey $Q$ and benchmark values
- Benchmarks are aggregate gold standards, i.e., do not provide validation for individual respondents’ answers

18

<!-- page 19 -->

# Benchmarks

* A Pew study (Kennedy, et al., 2016) compared 20 survey estimates from 9 non-probability online samples to benchmark population estimates
  * Benchmarks derived from “high quality federal sources [including] national surveys...” plus some admin records
  * Topics include smoking, health care coverage, income, participation in civic or recreational organizations, voting, household composition, internet usage
* Also compared American Trends Panel (ATP), Pew’s online probability panel to benchmarks

**Average % correctly classified in regressions**

How well regression models from online samples predict outcomes on benchmark samples (average across four outcomes)

| | |
|---|---|
| I | 76.2% |
| H | 73.6 |
| ATP | 71.7 |
| B | 71.1 |
| G | 70.5 |
| F | 70.4 |
| E | 70.3 |
| C | 68.9 |
| A | 66.4 |
| D | 66.4 |

<!-- page 20 -->

# Benchmark Surveys (2)

* Yeager et al. (2011) compared accuracy (% absolute error) for 7 non-probability web surveys, one probability web survey and a probability telephone survey
* “Error” was the deviation between responses from each survey and
  1. estimates from large US gov. surveys with response rates > 70%, and
  2. admin. data from US State Department (# passports), US Federal Highway Admin. (# drivers licenses)

* What is an example of a benchmark that does not rely on surveys or administrative records?
* What are some concerns/caveats about the use of benchmarks?

20

<!-- page 21 -->

# Response Distributions

* There may be theoretical reasons to expect responses from two experimental conditions to differ
  – e.g., a larger mean for a variable in one condition than the other
* To the extent the expected pattern is observed, this may be taken as support for the hypothesis
* Sometimes, the difference is not predicted to be in one direction or the other – just different
* In other cases, direction <u>is</u> predicted (e.g., Condition A > Condition B) and results in one direction assumed to be closer to the true value

21

<!-- page 22 -->

# Response Distributions, Example 1

* *Rs'* reports of behavioral frequency is influenced by the instances of the behavior that come to mind
* Couper, al. (2004) reasoned that content of images in web surveys can affect what comes to mind and, thus, the frequencies that *Rs* report
* Presented image of a relatively rare (low frequency) instance or a relatively common (high frequency) image of six behaviors
  * e.g., for *sporting events in past year,* low frequency (LF) image of a professional baseball stadium and high frequency (HF) image pictured an amateur (kids') game
  * Predicted pattern of reported frequency: LF < HF
  * Observed this pattern of mean reported frequencies for most of the six behaviors

22

<!-- page 23 -->

# Response Distributions, Example 2

* If *Rs* exposed to a definition that affects understanding of *Qs*, may lead to a more *inclusive* or more *exclusive* interpretation
  - Inclusive: "Income" defined to *include* overtime pay
  - Exclusive: "Moving expenses" defined to *exclude* buying food for friends who helped you move
* West et al., (2017) used this approach to compare accuracy of Conversational Interviews (CI) and Standardized Interviews (SI)
  - Reported that CI led to larger estimates than SI for 2 *Qs* with inclusive def's. and smaller estimates than SI for 4 *Qs* with exclusive def's. and
* Concluded CI estimates are more accurate because differences are in predicted direction

23

<!-- page 24 -->

# Disclosure

* Reporting sensitive or stigmatized info generally makes people uncomfortable
* So, more disclosure usually assumed to be more candid
  * Typically, no reason to intentionally overreport stigmatized behavior, placing oneself in a negative light
* Long tradition of attempting to increase disclosure of sensitive behavior through revised question wording (e.g., forgiving wording) but most successful method is self-administration
* To the extent that self-administered modes promote more disclosure, results are assumed to be more accurate
  * i.e., less driven by social desirability

24

<!-- page 25 -->

# Disclosure, Example 1

* Tourangeau & Smith (1996) compared disclosure between several *Iwer-* and self-administered modes
  * For number lifetime sex partners (excluding same sex), males assumed to overestimate and females to underestimate
  * Self-administration (CASI and ACASI) assumed to increase disclosure (honest responses)
    * Compared to in-person interviews, self-admin should lead to fewer partners reported by males, more partners reported by females
  * If observed, assumed to be higher quality data

25

<!-- page 26 -->

# Reported sex partners by gender and mode

## (Tourangeau & Smith, 1996)

Mean log (partners past year)
1.1
0.9
0.7
0.5
0.3
0.1
Males
Females
ACASI
CAPI
CASI
Data Collection Mode

26

<!-- page 27 -->

# Disclosure, Example 2 (Direct Measure)

* Very few studies have verified that patterns we characterize as indicating more disclosure do in fact represent more disclosure (honest responses)
* Best known study to do this is Kreuter, Presser & Tourangeau (2008)
  - UMD alums randomly assigned to telephone, IVR or web survey about undergraduate academic experience
  - Sensitive questions included *ever having received a D or F* or *GPA below 2.5*
  - Consistent with logic of most studies of mode and sensitive topics, *Rs* disclosed more sensitive info, e.g., “yes” responses, when they self administered *Qs* : Web > IVR > Phone
  - Compared to Registrar’s <u>records</u>, reverse for “False negatives:” Web < IVR < Phone
* “More is better\*” logic of disclosure supported by these results
* Of course, there are no records for most sensitive behaviors

\*more socially undesirable answers => higher quality data

27

<!-- page 28 -->

# Concurrent and Predictive Validity

* When no gold standard available, possible to assess response quality by correlating answers to target *Q*s with answers to other related *Q*s or events
  * Other *Q* in same interview: *concurrent validity*
  * Other *Q* in future interview or outcome of public event, e.g., election: *predictive validity*
* Chang & Krosnick (2009) used this approach to compare measurement quality between surveys conducted with (1) a probability sample interviewed by phone, (2) an online non-probability sample, and (3) an online probability sample
* Concurrent validity measured as the extent to which variables like Clinton job approval predict (correlated with) reported likelihood *R* will vote for Gore (then Clinton’s VP) than Bush (both responses collected in the pre-election survey)
* Predictive Validity measured extent to which Clinton job approval (pre-election) also predicted post-election reports of voting for Gore over Bush

28

<!-- page 29 -->

# Concurrent and Predictive Validity (Chang & Krosnick)

* Concurrent validity: online probability > telephone > online non-probability
* Predictive validity: online probability > telephone > online non-probability
* Leads to conclusion that, at least for political data, online probability panel produces best quality data

29

<!-- page 30 -->

# Organic Data: Survey Data as Gold Standard

* Social media posts as data for conducting social research
* Alignment with survey data, especially time series, considered evidence that data derived from social media are credible source of information about social phenomena
  - Social media created by non-probability sample of the public
  - Could easily not align with survey data, from either probability or non-probability sample
  - So, when the two data sources do align, may be worth taking seriously
* Yet, inaccuracies in survey data (TSE framework) well known

30

<!-- page 31 -->

# Measuring Consumer Sentiment With Tweets about Jobs

* *Sentiment* of tweets containing the word *jobs* on each day correlated with survey-based measures of consumer confidence in 2008-2009 (O’Connor et al., 2010)
    a. Sentiment (-1, 0, +1) assigned to each word by OpinionFinder; a tweet is positive if contains a positive word, negative if contains a negative word
    b. Daily sentiment = # positive tweets/ # negative tweets

* Compared daily sentiment ratio of tweets to two survey-based measures of consumer sentiment:
    1. Gallup’s Economic Confidence Index (2 questions)
    2. Index of Consumer Sentiment (ICS) from U. Michigan Surveys of Consumers (5 questions)
    * Both measure some version of “will economy get better, get worse, or stay same?”

31

<!-- page 32 -->

# O'Connor, et al. (2010):

* Social media-series (top) show dropping (less positive) sentiment (with a late spike) across 2008 and upturn across 2009 ... much like the two survey-based time-series (middle and bottom)
* Authors tested impact of different smoothing intervals and lags (or leads) on correlation between social media- and survey-series
* With 15-day smoothing and 20-day lead, Gallup-Twitter $r = .73$.
* With 30-day smoothing, and 50-day lead, ICS-Twitter $r = .64$

32

<!-- page 33 -->

# Conclusions

* True value is real but often not knowable
  - Most social scientists believe it is “out there”
  - But very hard to operationalize
* Administrative data are a straightforward proxy of true value
  - Not available for most survey variables
  - Sometimes only available in the aggregate, e.g., benchmark data
* Sensor data are objective but not free of measurement error
  - Not helpful in confirming accuracy of opinion measurement

33

<!-- page 34 -->

# Conclusions (2)

* Fictional scenarios afford researchers a high degree of control over true value, especially in conjunction with official definitions
  – Challenges include ecological validity
  – Better for assessing comprehension than other response difficulties
* Response change over time/waves, differences in response distributions, correlational measures reflect quality *indirectly*
  – But if consistent with theoretically-based predictions, can help establish data quality

34

<!-- page 35 -->

# Conclusions (3)

* Social desirability of answers seems to be effective measure of *Rs'* honesty, and varies with survey mode
  - Variation in socially desirable responding corresponds to administrative data in the few studies that have tested this
  - Supports the "more is better" assumption, so the fact that most sensitive behaviors are not recorded, may be okay
* Survey data as true value for organic data
  - Because it is *designed*, survey data is more likely accurate than data created for purposes other than measurement
  - But overlooks the error inherent in survey data that methodologists and researchers work hard to minimize

35
