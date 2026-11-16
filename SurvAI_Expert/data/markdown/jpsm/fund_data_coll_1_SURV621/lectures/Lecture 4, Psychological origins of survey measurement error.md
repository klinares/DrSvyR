---
id: "jpsm/fund_data_coll_1_SURV621/lectures/Lecture_4,_Psychological_origins_of_survey_measurement_error"
source: "jpsm"
course: "SURV621"
course_title: "Fundamentals of Data Collection I"
doc_type: "lecture"
title: "Psychological Origins of Survey Measurement Error"
original: "fund_data_coll_1_SURV621/lectures/Lecture 4, Psychological origins of survey measurement error.pdf"
pages: 49
sha256: "b577d11d2a5923e52dd0607a2c5ed9af830445a58a83a8b39c86a13e5037823a"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:00"
---

<!-- page 1 -->

# Psychological Origins of Survey Measurement Error

September 23, 2024

SurvMeth 621
Fundamentals of Data Collection I

Lecture notes: Frederick Conrad

<!-- page 2 -->

# Self-report and Measurement Error

* Quality of survey estimates cannot be any better than the information provided by survey respondents (*R*s)
  - Info typically *self-reported*, i.e., *R*s answer questions about themselves and their circumstances
  - Alternatives: records, diaries, sensors, biomarkers
* Platonic vs. Classical True Scores (Bohrnstedt, 1983)
  * Distinction is important in modeling assumptions for measurement error
  * The difference between the classical true and platonic true score assumptions lies in the difference in whether it is assumed that there is an actual true score or not.
  * Psychologists mostly think of “classical true score” that is, the true score is a function of values of $x$: $E\_p (x)=\tau\_p$ . This expectation depends on the conceptual repetition of measurement of $x$’s.
  * In survey research, behavioral responses are in principle verifiable hence the measurement model introduced in the next slide.

2

<!-- page 3 -->

# Self-report and Measurement Error

* Quality of survey estimates cannot be any better than the information provided by survey respondents (*R*s)
  – Info typically *self-reported*, i.e., *R*s answer questions about themselves and their circumstances
  – Alternatives: records, diaries, sensors, biomarkers
* Self-reported answers don’t always match “true value” due to limits of human cognition and impact of social processes

$$y_{jt} = X_j + \varepsilon_{jt}$$

3

<!-- page 4 -->

# Self-report and Measurement Error

* Psychologists mostly think of “classical true score” that is, the true score is a function of values of $y$: $E\_p (y)=X$ . This expectation depends on the conceptual repetition of measurement of $y$’s.
* In survey research, behavioral responses are in principle verifiable hence $Xj$ is platonic “true” variable and there is no assumption about $E\_p (y)=X$. The mean of the measurement error $\varepsilon_{jt}$ may or may not be zero.

4

<!-- page 5 -->

# Value of understanding how *R*s answer *Q*s

* Knowing how *R*s produce answers helps us understand where things can go wrong
  – i.e., where measurement error can enter the response process
* Can help explain patterns in existing data
  – e.g., question order effects
* And reduce measurement error by writing better questions

5

<!-- page 6 -->

# Types of questions

1. Behaviors and facts vs. attitudes (objective vs. subjective)

   “Have you ever been a ‘regular’ cigarette smoker, that is, at least one pack a week?”

   “To reduce cigarette smoking some states have increased tax on the purchase of cigarettes. Do you favor or oppose this kind of tax?”

2. Sensitive (or threatening or stigmatized) vs. non-sensitive topics

   “In the past 30 days, how often have you visited a website for sexually explicit material?”

   “How many fluid ounces of plain drinking water did you drink yesterday from the tap or water fountain?

3. Closed vs. open questions

   “What political party do you identify with: Republican party, Democratic party, Independent or something else?”

   “Why do you identify with that party?”

6

<!-- page 7 -->

# Total Survey Error Perspective

## *Measurement*
* Construct $\rightarrow$
* Measurement $\rightarrow$
* Response $\rightarrow$
* Edited Response $\rightarrow$ Survey Statistic

## *Representation*
* Target Population $\rightarrow$
* Sampling Frame $\rightarrow$
* Sample $\rightarrow$
* Respondents (also points to *Measurement* block) $\rightarrow$
* Post-survey Adjustments $\rightarrow$ Survey Statistic

7

<!-- page 8 -->

# Outline

1. Psychological processes in answering questions
   a. Comprehension
   b. Retrieval
   c. Estimation/Judgment
   d. Reporting/Response Selection
2. Sub-optimal responding (survey satisficing)

8

<!-- page 9 -->

# Simple Model of the Response Process

Comprehension of the question $\rightarrow$ Retrieval of information $\rightarrow$ Judgment and estimation $\rightarrow$ Reporting an answer

Souce: Tourangeau, Rips & Rasinski (2000)

* Model of <u>ideal</u> performance, but in practice:
  - *R*s may misunderstand question
  - Event(s) may not be recorded (“encoded”) in *R*’s memory
  - *R*s may forget relevant events
  - *R*s may intentionally misreport, producing answers that are more socially desirable
  - *R*s may take mental shortcuts: satisficing

9

<!-- page 10 -->

# 1. Comprehension Processes

* Comprehension assumed to involve analysis at various levels:
  * sensory: segment speech stream into words, recognize printed characters
  * lexical: retrieve meaning(s), pronunciation, part of speech, etc.
  * syntactic: string words into a grammatical sequence
  * semantic: determine overall sentence (question) meaning
  * pragmatic: infer speakers' intentions
* Measurement error present at all levels
* Survey methods research mostly concerned with Lexical, Semantic and Pragmatic levels

10

<!-- page 11 -->

# Lexical Level: Conceptual Variability

Do you think children suffer any ill effects from watching programmes with violence in them, other than ordinary Westerns?

* Belson (1981) determined that *R*s interpreted *children*, *ill effects* and *violence* in numerous ways
  - e.g., “children” interpreted as people < 8 years, < 19 - 20 years; students
  - only 8% interpreted question as intended

* Additional words can clarify intended meaning, but this may lead to unwieldy questions
  - tradeoff between clarity and complexity

11

<!-- page 12 -->

# Conceptual Variability (2)

* Words have many meanings (senses)
* Schober, Suessbrick, & Conrad (2018) administered CPS tobacco use supplement followed by post-test about *R*'s interpretation:
  – most frequent interpretation held by only 54%

| | |
|---|---|
| 23% | **Only cigarettes you finished** |
| 23% | **Cigarettes you finished or partly smoked** |
| 54% | **Even just one puff** |

Interpretation of “smoked a cigarette”

12

<!-- page 13 -->

# Conceptual Variability (3)

* Schober et al. (con’t)
  - Differences in interpretation do affect responses and their quality
  - After interview and interpretation q’aire, *Rs* re-answer original items
  - Half *Rs* also given a standard definition
  - More *Rs* change answer when given definitions than not, presumably correcting initial misconceptions that would have led to incorrect response
  - 10% changed on filter questions suggesting misconception might have led them down wrong path

**Response Change**

| | Behavioral | Opinion |
| :--- | :---: | :---: |
| **No Definitions** | 5 | 6.5 |
| **Definitions** | 10.2 | 16.2 |

13

<!-- page 14 -->

# Comprehension: Semantic Processes

* The key issue for the *R* is determining how survey concepts correspond – or map – to their concepts

“Have you purchased or had expenses for household furniture?”
“I purchased a floor lamp. Does that count as household furniture?”

* The problem is not lexical – *R*s know what “floor lamp” and “household furniture” mean – but not what does and doesn’t count
* In Standardized Interviewing (SI), it would not be possible for *I* to directly answer *R*’s question
* In Conversational Interviewing (CI), interviewer can clarify mappings

14

<!-- page 15 -->

# CI vs. SI: Response Accuracy*
## (Schober & Conrad, 1997)

* **% Correct** (y-axis): 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
* **Categories** (x-axis): Standardized, Conversational
* **Legend**:
  * Straightforward
  * Complicated

*Response accuracy based on fictional scenarios (e.g., receipts for purchases) for which correct and incorrect answers depends on fit with definitions, e.g., “Household furniture does not include floor lamps.”

15

<!-- page 16 -->

# Comprehension: Pragmatic Level Processes

* Grice’s cooperative principle (CP) allows listeners (including *R*s) to infer meaning:
  - Speaker (interviewer/question author) would not say something if he did not intend to inform me, so I will include that information in my interpretation
  - Based on four principles (called “maxims”):
    * Quantity: say as much, but no more, than necessary
    * Quality: do not say what you believe to be false
    * Relation: be relevant
    * Manner: avoid obscurity and ambiguity
* Listeners assume speaker is following CP so will try to make sense of utterance in light of CP

16

<!-- page 17 -->

# Comprehension: Pragmatic Level Processes

* Schwarz, Knäuper, Hippler, Noelle-Neuman and Clark (1991) asked

“How successful would you say you have been in life?”

```
    |---|---|---|---|- -|---|---|---|---|---|
not at all                                extremely
successful                                successful
   -5                                        +5
```

  - 34% of 0 to 10 group responded in lower half (0 to 5)
  - 13% of -5 to +5 group responded in lower half (-5 to 0)
  - zero scale anchor combined with label to mean “absence of success”
  - negative scale values combined with label to mean “presence of failure”

17

<!-- page 18 -->

# Response Process Exercise 1.1

<!-- page 19 -->

# 2. Retrieval Processes

Comprehension of the question $\rightarrow$ Retrieval of information $\rightarrow$ Judgment and estimation $\rightarrow$ Reporting an answer

19

<!-- page 20 -->

# 2. Retrieval Processes

* Answering almost any survey questions, whether about behaviors or opinions, requires retrieval
* Long Term Memory
  - Episodic Memory
    * Memory for events
  - Semantic Memory
    * Knowledge about the world
  - Procedural Memory
    * Mental routines
* Working Memory
  - Short term, limited capacity, “mental scratch pad”

20

<!-- page 21 -->

# Failure to encode detail

* Before recall (forgetting) is possible, one must encode events
* Lee et al. (1999) demonstrated that parents remember little about their children’s vaccinations because *do not encode* them
  - compared parents’ reports to medical records
  - reported “up-to-date” for 80% of children who are not up-to-date
    * recall is not improved by calendars or show cards
    * recall is poor immediately after injection and no worse after 10 weeks
    * recognition is no better than recall
  - childhood injections are frequent, not particularly distinctive, occur in batches and involve esoteric terms
  - Parents may simply have not encoded enough information to accurately recall and report the events

21

<!-- page 22 -->

# Encoding Specificity (Cont’d)

* Match between encoding and recall contexts affects memory performance
  * Physical context
    * Godden & Baddeley (1975) asked divers to study words on shore or 20 feet under
    * Tested them in either same or different context
    * Divers showed vastly superior memory when recalled in same context as studied
  * Mental state (“state dependent learning”)
    * Eich, Weingartner, Stillman & Gillin (1975) had subjects smoke either a marijuana or tobacco cigarette before studying words and smoke either one or the other before testing
    * *Ps* showed superior memory when smoked same substance before study and test
    * Eich (1980) showed only effective for recall; with recognition, no need to reinstate context
* Implications for improving recall?

22

<!-- page 23 -->

# More events encoded during life periods of great change: the Reminiscence Bump\*

\*Observed by many researchers, e.g., Rubin & Schulkind (1997)

20

<!-- page 24 -->

# Retrieval Failure

* Interference
  - The longer the time period in question (e.g., 1 year vs. 1 month) the more likely other similar events will have occurred
  - Hard to distinguish details of one event from others
  - Tend to blend into single generic memory
* Decay
  - The more time that has passed since events occurred, the weaker the memory
  - Forgetting most rapid in period immediately after event experienced
  - Forgetting continues after as many as 50 years(!)

21

<!-- page 25 -->

Percent Correct Recall
100
90
80
70
60
50
40
30
20
10
0

Classmate names
Teacher names
Street names
Grades

0 100 200 300 400 500 600
Months

Source: Tourangeau, Rips & Rasinski (2000)

22

*[Figure: This scatter plot with fitted trend lines displays "Percent Correct Recall" (y-axis, from 0 to 100) over time in "Months" (x-axis, from 0 to 600). It compares memory retention across four categories—Classmate names, Teacher names, Street names, and Grades—showing that while recall declines over time for all groups, classmate and teacher names are retained much longer and more gradually than street names and grades, which drop sharply within the first 100 months.]*

<!-- page 26 -->

# Improving Recall

* Recall cues can remind people of events:
  – NCVS item on shopping includes: “drug, clothing, grocery, hardware and convenience stores.”
* Giving *R*s more time to answer
  – Cannell et al. (1981) used longer *Q*s (without additional content); slowed interviews and increased # reports
* Conduct forensic cognitive interview (not the pretest method)
  – Fisher & Quigley (1992) improved recall of food consumption (compared to control group) by encouraging participants to (1) reinstate context, (2) recall in different orders, (3) recall from someone else’s perspective, (4) think about different points in time, (5) try hard

26

<!-- page 27 -->

# Improving Recall (Cont’d)

* Decomposing recall task
  – Means et al. (1994) asked about *cigarette smoking* at particular times of day and in particular situations
  – more smoking reported when decomposed than when *Rs* asked to give a “gut reaction” or use whatever strategy they chose
  – But decomposition can lead to to overreporting (Belli, et al, 2000)
* Event History Calendars (EHCs)
  – *Rs* asked to report about events in different life themes, e.g., employment, residence, marriage and family, health, etc.
  – Can help recall because makes clear to *R* the *sequential* relations between events within themes and *parallel* relations between events across themes

27

<!-- page 28 -->

# Memory for Dates

* Memory for dates is poor compared to other features of events
  * Dates are not good retrieval cues (e.g., Wagenaar, 1986)
* Format in which date requested can affect accuracy
  * Janssen et al. (2006) asked participants to date personal and news events using absolute (e.g., “July 2004”) or relative (“3 weeks ago”) formats or to choose format
  * Absolute date assumed to require reconstruction, e.g., from context
  * Relative date assumed to require clarity or familiarity of memory
* Events dated in absolute format more accurate than relative format
* When given choice, *P*s preferred to date
  1. news events in relative format and personal events in absolute format
  2. remote (older) events in relative format, recent events in absolute format

28

<!-- page 29 -->

# Telescoping

* In answering survey questions with time periods
  * (Forward) Telescoping: tendency to report events that occurred *before* the reference period as having occurred *within* it
  * Backward Telescoping: tendency to report events that occurred *after* reference period as having occurred *within* it
    * Only possible if reference period does not “touch” the present
  * Forward displacement more common and usually larger than backward displacement
    * Cannot displace future events (i.e., haven’t occurred) into reference period
* Displacement is greater for older than newer events because memory is worse – date info more likely to be forgotten

29

<!-- page 30 -->

# Response Process Exercise 1.3

<!-- page 31 -->

# 3. Judgment and Estimation

* Comprehension of the question
* Retrieval of information
* Judgment and estimation
* Reporting an answer

31

<!-- page 32 -->

# 3a. Estimation Processes

*During the past 12 months, from [DATE] through today, how many times have you donated blood?*

* At least three broad strategies, each leading to different types of error
    1. *recall and count =>* underestimation
        * more likely to forget than invent an event
        * telescoping inflates estimate but less than forgetting lowers it
    2. *rate-based estimation =>* overestimation
        * for regularly occurring events, rates (e.g., “I donate every 8 weeks so 6 times”) can be quite accurate except when *R*s fail to consider exceptions (e.g., not doing the behavior)
    3. *impression-based estimation =>* overestimation
        * “I do that a lot, so I’ll say 10 times”
        * translation of impression to number cannot be lower than 0 but unbounded on high end

32

<!-- page 33 -->

# Heuristics in Estimation

* Heuristics are informal rules that provide “close enough” estimates
* But sometimes lead to systematic error
* Tversky & Kahneman’s (1974) availability heuristic:
  - People sometimes use the ease with which examples come to mind as an indication of their frequency or probability of occurrence
  - Example of evidence for availability:
    * Easier to retrieve words starting with *r* than words whose 3rd letter is *r*; former judged more frequent even though latter actually is more frequent
    * Easier to recall famous than less famous names; when list had more famous females than males, females judged more frequent even though equal numbers males and females

33

<!-- page 34 -->

# Availability Heuristic in Survey Responding

* Schwarz, et al., (1991):
  * Asked one group to list 6 situations in which assertive and another group to list 12
  * Then asked to rate own assertiveness
  * *R*s who listed 6, rated selves more assertive than *R*s who listed 12 instances
  * Presumably, easier to bring a few instances to mind so *R*s conclude more likely
* Belli, Singer, Schwarz & Tallarico (2000)
  * Found that people overestimated frequency of phone calls when question decomposed calls by region and time
  * They attributed this to people being misled by the availability heuristic: the relative ease of recalling events in smaller (decomposed) categories led to higher estimates within each
    * lots of small overestimates which add up to significant overestimates

34

<!-- page 35 -->

# 3b: Judgment -- Context Effects

* Opinions are context sensitive
  - same *R* can answer *Q* about a subjective topic differently in different contexts
* The *context* can include
  - recent media consumption, conversations, recent thoughts
  - questionnaire context, i.e., prior questions
* Info on which *Qa* based may be available to *R when* answers *Qb*
* If info automatically considered (included) when answering *Qb* can promote correlated responses to *Qa* and *Qb* -- *assimilation* effect
* If explicitly excluded to avoid redundancy, answers to *Qa* and *Qb* not correlated – *subtraction-based contrast* effect

35

<!-- page 36 -->

# Assimilation and Contrast Effects (Cont'd)

## Schwarz, Strack & Mai, 1991

assimilation

Subtraction-based contrast

| Condition | Correlation |
| :--- | :---: |
| General-specific | .32* |
| Specific-general | .67* |
| Specific-general, with joint lead-in | .18 |
| Specific-general, explicit inclusion | .61* |
| Specific-general, explicit exclusion | .20 |

$r$ (satisfaction with life in general and with marriage) $* p < .05$

General: “How satisfied are you currently with your life-as-a-whole?”
Specific: “How satisfied are you currently with your relationship?”

36

<!-- page 37 -->

# Response Process Exercise 1.2

<!-- page 38 -->

# 4. Response Selection/Reporting an Answer

Comprehension of the question $\rightarrow$ Retrieval of information $\rightarrow$ Judgment and estimation $\rightarrow$ Reporting an answer

38

<!-- page 39 -->

# 4. Reporting an Answer

* Even after comprehension, retrieval, and estimation & judgment are complete, *Rs* must select a response option
* One phenomenon that can occur when choosing an answer is choosing an answer that enhances one’s standing: *social desirability*
* For *Qs* on “sensitive” topics, (e.g., income, religion, partisan affiliation) selecting <u>any</u> response can feel intrusive
* For some topics, certain options feel more personal than others:
  - “Yes” vs. “No” when asked “Have you ever injected an opioid drug?”
  - “Never” vs. “> 3 times a week” when asked “How often do you exercise?”
* *Rs* more likely to shade truth if truth is embarrassing or illegal

39

<!-- page 40 -->

# Socially Desirable Responding

* *R*s underreport sensitive behaviors and opinions (“motivated misreporting”)
* especially when *Q* asked by a live *I’wer* vs. self-administered
  * Self-admin: mail, online, CASI (*I’wer* gives computer to *R* for sensitive Qs)

| | **Time Frame** | | |
| :--- | :---: | :---: | :---: |
| | Past Month | Past Year | Lifetime |
| Cocaine | 1.74 | 2.84 | 1.81 |
| Marijuana | 1.66 | 1.61 | 1.48 |

Ratios of Estimated Prevalence under Self-administration (ACASI\*) and Interviewer-administration (CAPI\*\*)
Source: Tourangeau & Smith, 1996

\*Audio recorded interviewer asks sensitive Qs &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \*\*In-person interview for all Qs &nbsp;&nbsp;&nbsp; 35

<!-- page 41 -->

# Response Order Effects

* *Recency* effect: When response options read aloud by *I’wer*, *R*s show preference for options presented most recently
  – Knäuper (1998, 1999) attributes to limits of working memory (WM) capacity because more common among older than younger *R*s
    * WM capacity shrinks as people age
* *Primacy* effect: When responses presented visually, *R*s show preference for options presented earlier
  – Krosnick and Alwin (1987) interpret as evidence of “survey satisficing” – choosing the first acceptable option

41

<!-- page 42 -->

# Primacy

* Krosnick & Alwin (1987) computed percent *Rs* who endorse each of 13 attributes they would most like their children to have
  - Presented in forward order to $\frac{1}{2}$ *Rs* and reverse order to other $\frac{1}{2}$ so that preferences for early vs. late options cannot be due to their content
  - K&A found that first few response options (in textual list) more likely to be endorsed, irrespective of order
  - Propose that *Rs* answer as soon as an acceptable option encountered
    * sub-optimal but good enough to accomplish *R*'s goals
  - Primacy particularly strong for *Rs* with lower cognitive ability

42

<!-- page 43 -->

# Primacy (Cont'd)

| Quality | Standard order | | Reversed order | Difference |
| :--- | :---: | :---: | :---: | :---: |
| | % | | % | % |
| Manners | 26.4 | | 10.1 | 16.3 |
| Success | 19.1 | $>$ | 14.6 | 4.5 |
| Honest | 65.7 | | 48.4 | 17.3 |
| . | . | | . | . |
| . | . | | . | . |
| . | . | | . | . |
| Considerate | 24.9 | | 39.5 | -14.6 |
| Interested | 17.9 | $<$ | 24.9 | -7.0 |
| Studious | 6.5 | | 16.4 | -9.9 |

Source: Krosnick & Alwin, 1987

43

<!-- page 44 -->

# Optimal vs. Acceptable Responding

* Our discussion so far has mostly concerned ideal performance
* Measurement error occurs despite good faith effort by *R*
  * Limits of human cognition and impact of social processes
* Exceptions include “motivated misreporting” and primacy
  * Not (entirely) clear if social desirability leads to lying
  * Primacy likely due to effort reduction – survey *satisficing*
* Survey satisficing has been identified across a range of *R* behavior

44

<!-- page 45 -->

# Survey Satisficing

* Krosnick (1991) suggested that *Rs* may provide acceptable but not optimal answers
  - *Primacy, Straightlining, DK, Acquiescence, Mental Coin-flipping*
  - *Weak Satisficing*: execute all steps in response process but superficially
  - *Strong Satisficing*: skip entire steps in response process

$$p(\text{satisficing}) = \frac{a_1(\text{Task Difficulty})}{a_2(\text{Ability}) \times a_3(\text{Motivation})}$$

  - Allows for interactions between ability and motivation
    * e.g., if *R* is low in ability and low in motivation, especially likely to satisfice
  - Herbert Simon (1957) coined term “satisficing” to reflect solutions to problems\* that are <u>satis</u>factory and that suf<u>fice</u> but are not optimal

\*Not necessarily involving answering survey questions

45

<!-- page 46 -->

# Speeding in Web Surveys

* A type of strong satisficing is *speeding* – responding so fast that cannot give answers much, if any, thought
* Speeders tend to be young

$\chi^2 = 762.76, p < 0.001$

*Figure 1.* Percentage of persistent speeders by age groups

Zhang & Conrad, 2013

41

*[Figure: A bar chart titled "Figure 1. Percentage of persistent speeders by age groups" plots the "% of Persistent Speeders" on the y-axis (from 0 to 40) against five age groups on the x-axis (18–34, 35–44, 45–54, 55–64, and 65+). The chart shows a clear, steady decline in the percentage of persistent speeders as age increases, dropping from over 40% in the youngest group (18–34) to just above 0% in the oldest group (65+).]*

<!-- page 47 -->

# Straightlining

* Another type of strong satisficing is *Straightlining**, selecting the same response option for all or most statements in a battery

**For each of the following statements, please rate how much it characterizes you.**

| | Extremely uncharacteristic | Somewhat uncharacteristic | Uncertain | Somewhat characteristic | Extremely characteristic |
| :--- | :---: | :---: | :---: | :---: | :---: |
| I prefer to avoid taking extreme positions | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |
| I want to know exactly what is good and bad about everything | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |
| If something does not affect me, I do not usually determine if it is good or bad | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |
| There are many things for which I do not have a preference | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |
| I like to have strong opinions even when I am not personally involved | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |
| I would rather have a strong opinion than no opinion at all | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |
| I only form strong opinions when I have to | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |
| I am pretty much indifferent to many important issues | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\odot$ | $\bigcirc$ |

*also called “non-differentiation”

47

<!-- page 48 -->

# Survey Satisificing: Implications

- Some *Rs* may be satisficers, some may be optimizers, but many probably take shortcuts on some occasions and not others
- Important to take this into account when designing *Qs*
  - Task difficulty, *Rs'* ability, and *Rs'* motivation
  - Prevalence of satisficing may vary by mode of data collection, e.g., whether *I'wer* present to keep *R* on track, or when mode creates time pressure (leading to fast responses)

48

<!-- page 49 -->

# Psychological Origins of Measurement Error

* Self-reports always have the potential to be inaccurate or erroneous in other ways because of
  - limits inherent in people’s ability to carry out the response task
  - unwillingness to invest the effort we expect them to
* Other sources of data, e.g., records, sensor measures, social media posts, may also include measurement error
* Methodologists’ challenge is to understand when measurement error is more and less likely and to use available tools to reduce it

49
