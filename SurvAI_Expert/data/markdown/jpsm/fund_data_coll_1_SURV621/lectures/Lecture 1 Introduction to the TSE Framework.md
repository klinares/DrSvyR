---
id: "jpsm/fund_data_coll_1_SURV621/lectures/Lecture_1_Introduction_to_the_TSE_Framework"
source: "jpsm"
course: "SURV621"
course_title: "Fundamentals of Data Collection I"
doc_type: "lecture"
title: "SURV 621/SURVMETH 621: INTRODUCTION TO DATA QUALITY AND THE TSE FRAMEWORK"
original: "fund_data_coll_1_SURV621/lectures/Lecture 1 Introduction to the TSE Framework.pdf"
pages: 27
sha256: "0751d8e6186075767b43b9881646ba527466aa1d3cb39967cf3ebca360050e65"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:59"
---

<!-- page 1 -->

# SURV 621/SURVMETH 621: INTRODUCTION TO DATA QUALITY AND THE TSE FRAMEWORK

August 26, 2024

<!-- page 2 -->

# Many different types of users of social science data...

* Policymakers and government officials
* Economic forecasters
* Business community
* Social science researchers
* News media
* Members of the general public

<!-- page 3 -->

# ... with a wide variety of data needs

* Measures of social conditions (e.g., educational attainment, health status, crime)
* Measures of economic conditions (e.g., output, employment, wages, prices)
* Measures of consumer sentiment and consumer behavior (e.g., TV viewership, consumer spending)
* Measures of public attitudes (e.g., views about gun control, voting intentions)

<!-- page 4 -->

# Dimensions of data quality

* Brackstone (1999) an early example of a framework for data quality
* Identifies six dimensions that determine the “fitness for use” of a statistic
  * Relevance
  * Accuracy
  * Timeliness
  * Accessibility
  * Interpretability
  * Coherence

<!-- page 5 -->

# Relevance

* Relevance reflects the degree to which statistical information meets the real needs of users
* Nature of information provided is important
  * Topics of interest?
  * Definitions and classifications that are meaningful in the current context?
  * Level of detail that is appropriate for desired uses?
* Information that is not accurate, timely, and coherent also may not be relevant
* An effective statistical organization will have ongoing mechanisms to assess client needs in relation to their data programs

<!-- page 6 -->

# Accuracy

* Accuracy of statistical information reflects the degree to which the information correctly describes the phenomena it was designed to measure
* May be described in different ways
  * Bias and variance
  * Major sources of error (the TSE framework)
* Important activities for an effective statistical organization include
  * Routine assessments of sources of error
  * Prioritization of ongoing efforts to reduce error given applicable budget constraints

<!-- page 7 -->

# Timeliness

* Timeliness of statistical information refers to the delay between the reference point (or end of the reference period) and the date information becomes available
* Potential tradeoff between accuracy and timeliness
  * Especially for economic statistics, common to produce preliminary estimates followed by revised and final estimates
* Good practices for an effective statistical organization include
  * Announcing release dates in advance
  * Seeking where possible to streamline data production processes in order to release data more quickly

<!-- page 8 -->

# Accessibility

- Accessibility of statistical information refers to the ease with which it can be obtained from the statistical organization
- Developing tools for data users to discover what data are available can be challenging
- Variety of delivery modes may be needed to satisfy wide range of data users
  - Press releases and pre-formatted tables
  - Excel files or APIs for accessing data base of published estimates
  - Research data centers for accessing microdata

<!-- page 9 -->

# Interpretability

* Interpretability of statistical information reflects the availability of supplemental information and metadata necessary to interpret and utilize it appropriately
* Users of statistical information should be provided with materials detailing
  * Concepts and classifications underlying the data
  * Methodology used to collect and compile the data
  * Measures of accuracy of the data

<!-- page 10 -->

# Coherence

* Coherence of statistical information refers to the degree to which it is consistent over time and can be successfully brought together with other statistical information
* Tradeoff between relevance (updating statistics to reflect changes in the society) and consistency over time
  * Good practice to provide data users with information about impact of changes on measures of interest
* Use of standard frameworks promotes coherence across statistical data series. Some examples:
  * UN working groups develop international guidelines such as the System of National Accounts
  * OMB issues classification standards for race, industry, occupation, geographic units

<!-- page 11 -->

# Total survey error

* Total survey error is a framework for thinking about the *accuracy* of statistical information
  * Originally developed for thinking about designed data (especially survey data)
  * Scholars are beginning to think about how framework should be modified to apply to found data
* In its original form, TSE framework rests on a model of the survey life cycle
  * Focus on sources of error that may arise at each step in the survey process
  * Conceptual break between: collecting answers to questions by a respondent (**measurement**) AND combining answers of respondents to construct statistics (**representation**)

<!-- page 12 -->

# What is a survey?

* Describes a systematic method of gathering information
* This class concerns surveys that...
    ... aim to produce **quantitative descriptions** about some aspects of the study population
    ... gather information by **asking people questions using standardized procedures**
    ... gather information from a **sample**, not from every member of the population

12

<!-- page 13 -->

# The survey life cycle

**Measurement**
* Construct
* $\downarrow$
* Measurement
* $\downarrow$
* Response
* $\downarrow$
* Edited Response
* $\downarrow$
* Survey Statistic

**Representation**
* Target Population
* $\downarrow$
* Sampling Frame
* $\downarrow$
* Sample
* $\downarrow$
* Respondents
* $\downarrow$
* Post-survey Adjustments
* $\downarrow$
* Survey Statistic

<!-- page 14 -->

# The survey life cycle: Representation

* Target Population
  * Coverage Error
* Sampling Frame
  * Sampling Error
* Sample
  * Nonresponse Error
* Respondents
  * Adjustment Error
* Post-survey Adjustments
* Survey Statistic

<!-- page 15 -->

# Representation: Coverage error

* *Coverage error* may arise if some members of the target population are not represented on the sample frame.
  * Incomplete coverage is a problem to the extent that covered units differ from units that are not covered
* Examples:
  * Random digit dialing (RDD) sample for a household survey may underrepresent certain types of households and their characteristics may differ from those of included households
  * Young establishments may be underrepresented on a business survey list frame and their characteristics may differ from those of older establishments

<!-- page 16 -->

# Representation: Sampling error

* *Sampling error* arises because only a portion of the frame population is sampled
  * Assuming a sample design that is statistically sound, error is variance not bias
* Magnitude of sampling error depends on
  * Variability of the measure of interest in the underlying population
  * Size of survey sample
  * Share of the population sampled

<!-- page 17 -->

# Representation: Nonresponse error

* *Nonresponse error* may arise if some sampled units do not respond
    * Nonresponse is a problem to the extent that responding units differ from units that do not respond
* Examples:
    * Young men may be less likely to respond to household surveys than older men or women, and their behavior may differ systematically from that of the groups that are more likely to respond
    * Active volunteers may be more likely to respond to household surveys than those who do not volunteer, distorting measurements related to volunteering
    * Failing enterprises may be less likely to respond to business surveys than successful enterprises, distorting measurements of business activity

<!-- page 18 -->

# Representation: Adjustment error

* *Adjustment error* may arise because of errors in post-survey weighting
* Possible sources of adjustment error
  * Control totals for numbers of people with different characteristics may themselves be measured with noise
  * Weighting can increase sampling variance

<!-- page 19 -->

# The survey life cycle: Measurement

* Construct
  * $\leftarrow$ Validity
* $\downarrow$
* Measurement
  * $\leftarrow$ Measurement Error
* $\downarrow$
* Response
  * $\leftarrow$ Processing Error
* $\downarrow$
* Edited Response
* $\downarrow$
* Survey Statistic $\leftarrow$

<!-- page 20 -->

# Measurement: Validity

* *Validity* relates to whether the information requested is consistent with the construct the survey researcher seeks to measure
* Examples:
  * Want to know about employee compensation, but measure of compensation that is defined excludes stock options and meals provided by the employer
  * Want to know about mathematical ability and have a score on a mathematical reasoning test, but students could perform differently on test in repeated trials

<!-- page 21 -->

# Measurement: Measurement error

* *Measurement error* reflects gaps between the information requested and the information actually reported. Sources of measurement error include:
  * Not understanding the question
  * Not knowing the answer to the question
  * Not being willing to make the effort required to report accurately
  * Desire to present self in a favorable light
* Examples:
  * Asked a question about household income from all sources, a household survey respondent may not know other household members’ earnings
  * In a business survey, respondents asked to report total production worker employment may not have that information in their records and have to guess
  * Asked a question about their college GPA, a household respondent may report a higher GPA than they actually earned

<!-- page 22 -->

# Measurement: Processing error

- *Processing error* reflects problems with keying, coding of open responses, editing, imputation, or tabulation
- Examples:
  - Keying errors by interviewers
  - Incorrect coding of occupation based on an individual’s description of work duties or incorrect coding of time use activities based on an individual’s descriptions of how they spent their day
  - Editing of values that may seem implausible but are correct

<!-- page 23 -->

# Pressures on the survey model for data collection

* Growing cost of conducting surveys, especially in-person and telephone household surveys
* Steady and ongoing decline in household survey response rates
* Increasing demand for data that are more timely and more detailed than existing surveys can produce

<!-- page 24 -->

# Responses to the challenges facing the survey model of data collection

- Increased use of “probability-based” panels (e.g., Ipsos KnowledgePanel, NORC Amerispeak panel)
- Increased use of volunteer nonprobability samples
- Increased use of administrative data (e.g. records from entitlement programs, tax records, payroll records)
- Increased use of (other types of) found data
  - Commercial transaction data (e.g., scanner data, credit card data)
  - Data derived from individual interaction with the internet (e.g., social media, Google searches, web browsing data)
  - Sensor data (e.g., physical activity data, GPS location data)

<!-- page 25 -->

# Characteristics of survey and naturally occurring data

## Survey data

* Small but representative share of target population observed directly
* Data elements selected to meet statistical needs
* Data records may include unit identifiers that facilitate linkage

## Naturally occurring data

* Large but not necessarily representative set of records; private data sets typically convenience samples
* Data records reflect administrative or business purposes
* Data records may not be linkable

<!-- page 26 -->

# Characteristics of survey and naturally occurring data (cont’d)

## Survey data
* Quality control central to survey process, though errors in measurement may arise
* Comparability of data over time controlled by survey statistician
* Data often reasonably timely

## Naturally occurring data
* Data elements relevant to administrative determinations or business processes most likely to be accurate; unclear how to interpret self-presentations on social media
* Comparability of data over time may be disrupted by changes in administrative or business requirements, changes in Web interface
* Timing depends on source; administrative data may lag, business and Web interface data may be available very quickly

<!-- page 27 -->

# Characteristics of survey and naturally occurring data (cont’d)

## Survey data

* Data “owned” by statistical agency, typically collected from respondents under a pledge of confidentiality

## Naturally occurring data

* Data “owned” by administrative agency or business where it was generated; obtaining data may be expensive or raise legal, business or other concerns
