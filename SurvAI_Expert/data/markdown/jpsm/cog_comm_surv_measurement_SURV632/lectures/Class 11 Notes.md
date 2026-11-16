---
id: "jpsm/cog_comm_surv_measurement_SURV632/lectures/Class_11_Notes"
source: "jpsm"
course: "SURV632"
course_title: "Cognition, Communication, and Survey Measurement"
doc_type: "lecture"
title: "Survey Satisficing"
original: "cog_comm_surv_measurement_SURV632/lectures/Class 11 Notes.pdf"
pages: 35
sha256: "a2f472545d000a935d808078891827bc0eb004283ad58ec9402a9f0d8e3034b5"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:49"
---

<!-- page 1 -->

# Survey Satisficing

SurvMeth 632
November 13, 2024
Aaron Maitland

<!-- page 2 -->

# Outline

1. Survey Satisficing
   a. Distinguished from classic satisficing
   b. Primacy
   c. Least effort strategies
2. Speeding in web surveys
3. Straightlining
4. Mode and Satisficing
5. Reducing Satisficing (Speeding) with interactive prompting
6. Trait or state?

2

<!-- page 3 -->

# Survey Satisficing

* Krosnick (1991) observed *Rs* may provide acceptable but not optimal answers
  – *Primacy, Straightlining, DK, Acquiescence, Mental Coin-flipping*
* *Weak Satisficing*:
  – execute all steps in response process but superficially
* *Strong Satisficing*:
  – skip entire step(s) in response process
* Most likely when task is difficult, and/or ability and/or motivation low

$$p(\text{satisficing}) = \frac{a_1(\text{Task Difficulty})}{a_2(\text{Ability}) \times a_3(\text{Motivation})}$$

* Herbert Simon (1957) coined term “satisficing” to describe solutions to problems that are <u>satis</u>factory and that suf<u>fice</u> but are not optimal

3

<!-- page 4 -->

# Satisficing (Simon)

* When making decisions, either for themselves or in organizations, people (all of whom have limited cognitive abilities) rarely
    1. have access to all relevant information
    2. able to process all relevant information
* But people make decisions that are usually good enough for the current goals, i.e., they satisfice
    - Key component of “bounded rationality” notion: complexity of environment and constraints on people’s cognitive skills place bounds on their ability to make perfectly rational (optimal) decisions
    - Simon (1956) describes simple, hypothetical organism that needs to find food in environment to survive and can search only a limited number of “steps” in any direction
    - Under many plausible scenarios, organism can survive without optimal search capability

4

<!-- page 5 -->

# Primacy

* First few (visual) response options more likely to be endorsed irrespective of order
* Krosnick & Alwin (1987) observe this tendency despite reversing the order of 13 response options on a showcard
  * Argued that *Rs* tend to select first acceptable option that is read
  * Effect particularly strong for those with <u>lower cognitive ability</u> measured by level of education and vocabulary score
* Malhotra (2008) observed primacy effects most often for *Rs* low in education and who responded most quickly

5

<!-- page 6 -->

# Primacy (2)

| Quality | Standard order | Reversed order | Difference |
| :--- | :---: | :---: | :---: |
| | % | % | % |
| Manners | 26.4 | 10.1 | 16.3 |
| Success | 19.1 | 14.6 | 4.5 |
| Honest | 65.7 | 48.4 | 17.3 |
| . | . | . | . |
| . | . | . | . |
| . | . | . | . |
| Considerate | 24.9 | 39.5 | -14.6 |
| Interested | 17.9 | 24.9 | -7.0 |
| Studious | 6.5 | 16.4 | -9.9 |

[eye tracking example](#)

6

<!-- page 7 -->

# Primacy (3)

* K&A propose that *Rs’* minds become cluttered after reading and considering first few options, so later options cannot be processed deeply – if at all
* Likened to *satisficing* (Simon, e.g.,1957) in that primacy leads to answers that are acceptable – good enough – but not optimal

7

<!-- page 8 -->

# Least effort strategies in HCI

* Even minimal actions, like clicking, experienced as effortful so users may avoid
* Grey & Fu (2004) asked participants to program an on-screen implementation of a VCR (analog version of DVR) to record TV shows
* Info about time and channel of TV shows on same screen as VCR but in one condition a click is required to reveal the info
* Performance worse when click required because participants relied on memory rather than clicking
* even though on-screen info is perfectly accurate, and memory is not
* Eye tracking study indicated that participants avoid even moving their eyes to acquire perfect info, relying instead on imperfect recalled info
* Imperfect info in head preferred to perfect info in the world because less effort involved in recalling than searching visually

8

<!-- page 9 -->

# Ease of obtaining definitions (reminder)

(Conrad, Couper, Tourangeau & Peytchev, 2006)

* Manipulated ease of getting definition (1, 2 or 2+ clicks) and usefulness (counter-intuitiveness) of definition
  - intuitive (“beef” includes food products from cows)
  - counterintuitive (“vegetables” includes French fries)
* The fewer clicks required to get definition, the more *Rs* requested them
  - *Rs* accessed more definitions when one click required than two and more when more than two required
  - Useful definitions lead to more requests for definitions ... only if requests are low effort (1 click)
  - Roll-over requests lead to more many more requests than 1 click interface

9

<!-- page 10 -->

# Satisficing vs. Satisficing Indicators

* Some behaviors directly reflect survey satisficing, e.g., # of DK responses
* Others are indirect and are only evident with experimental manipulation, e.g., detecting primacy requires reversing order of options for some *R*s (or randomizing for each *R*)
* Some behaviors associated with satisficing co-occur, e.g., speeding and straightlining, suggesting that there may be a general tendency to take shortcuts
* In other cases, survey satisficing seems situational, e.g., more speeding when *R*s more fatigued

10

<!-- page 11 -->

# Speeding in Web Surveys

* Very fast responses – too fast for *Rs* to have read *Q*, let alone thought about the answer
* Although *R* provides answer, barely more effort invested than if item skipped entirely
  * – “throw-away responses”
* *Rs* probably engage in speeding in paper questionnaires but not observable by researchers
* In online surveys, we can measure response time

11

<!-- page 12 -->

# Speeding Prevalence

* Zhang & Conrad (2013) measured speeding in 54 questions in LISS Panel data
  – Speeding defined as $\text{RT} < 300\text{ msec}$ per word in question

| Mean | 25th Percentile | Median | 75th Percentile |
| :---: | :---: | :---: | :---: |
| 15.4 | 8 | 14 | 21 |

Number of questions (out of 54) on which *R*s sped

12

<!-- page 13 -->

# Speeding Across the Questionnaire

| | Speeding frequency in second part of questionnaire | | | |
| :--- | :---: | :---: | :---: | :---: |
| Speeding frequency in first part of questionnaire | $1^{\text{st}}$ Quartile | $2^{\text{nd}}$ Quartile | $3^{\text{rd}}$ Quartile | $4^{\text{th}}$ Quartile |
| $1^{\text{st}}$ Quartile | 66.9 | 28.7 | 4.3 | 0.2 |
| $2^{\text{nd}}$ Quartile | 23.0 | 50.3 | 23.1 | 3.6 |
| $3^{\text{rd}}$ Quartile | 4.4 | 26.8 | 45.2 | 23.7 |
| $4^{\text{th}}$ Quartile | 1.9 | 9.5 | 23.7 | 65.0 |

Percent in Speeding Quartile
Zhang & Conrad, 2013

* Those who speed the least ($1^{\text{st}}$ Quartile) in first half of q'aire speed the least in second part; those speed the most ($4^{\text{th}}$ Quartile) in first half of q'aire, speed the most in second part
* Suggests speeding is a stable characteristic
* Top (fourth) quartile in both parts of questionnaire considered "persistent speeders"

<!-- page 14 -->

# Speeders are younger

$\chi^2 = 762.76$, $p < 0.001$

*Figure 1.* Percentage of persistent speeders by age groups

Zhang & Conrad, 2013

14

*[Figure: This bar chart displays the percentage of persistent speeders (y-axis, ranging from 0 to 40) across five different age groups on the x-axis: 18–34, 35–44, 45–54, 55–64, and 65+. The plot shows a clear downward trend as age increases, with the 18–34 age group having the highest proportion of persistent speeders (over 40%) and the 65+ group having the lowest (near 2%).]*

<!-- page 15 -->

# Straightlining

* For a battery of items with the same response scale, selecting the same (or mostly the same) scale values is generally assumed to be a type of satisficing
  - "Non-differentiation"
  - While possible that after considerable thought *R* endorses same options throughout battery, it is unlikely, especially if reverse worded option included ("reverse straightlining")
* Straightlining more common among *Rs* with less education (e.g., Rogers and Herzog, 1984), and at end of questionnaire when presumably they are fatigued (Knowles, et al., 1981)
* Straightlining is like Acquiescent, Extreme, and Middle Response Style\* in that options chosen irrespective of content

\*all considered satisficing in some situations

15

<!-- page 16 -->

# Straightlining in a Grid (Matrix)

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

Reverse Coded

16

<!-- page 17 -->

# Straightlining and Speeding

* Zhang & Conrad (2013) report that straightlining is most likely for speeders
  – Especially if persistent speeder
  – Especially if low in education
* Conrad, Tourangeau, Couper & Zhang (2017) observed that the more *R*s sped on seven *Q*s requiring a numerical response the more they straightlined

17

<!-- page 18 -->

# Straightlining and Speeding (2)

Exper 1
Exper 1a
Exper 2
Exper 3

40%
35%
30%
25%
20%
15%
10%
5%
0%

% Rs Straightlined at Least Once

0 1 2 3 4 5 6 or 7

Number of Previous Questions on which Speeding Detected

Conrad et al. (2017)

18

*[Figure: This line graph shows the percentage of respondents who straightlined at least once (y-axis, from 0% to 40%) plotted against the number of previous questions on which speeding was detected (x-axis, from 0 to "6 or 7"). Comparing four experimental groups (Exper 1, Exper 1a, Exper 2, and Exper 3), all four lines demonstrate an upward trend where straightlining increases—most sharply after 4 or 5 instances of speeding—as the frequency of previous speeding increases.]*

<!-- page 19 -->

# Mode of Data Collection and Satisficing

* Primacy most common with visual presentation
  * perhaps due to “mental clutter” as *Rs* proceed through options, e.g., K&A (1987)
* Recency effects common in spoken presentation, i.e., in telephone interviews, e.g., Holbrook et al. (2007)
* Modes that create less time pressure and allow *Rs* to consider their answers more carefully, may reduce satisficing
  * e.g., text message interviewing

19

<!-- page 20 -->

# Rounding and straightlining in Voice and Text (SMS) interviews

* Schober et al. 2015
* 4 Modes:
  – Human Voice
  – Human Text (SMS)
  – Automated Voice
  – Automated Text (SMS)

HUMAN AUTOMATED

TEXT

VOICE

20

<!-- page 21 -->

# Texting as Survey Mode

* Texting is asynchronous; voice (phone) is synchronous
* Texting largely eliminates time pressure to respond, especially compared to voice interviews
* Compare amount of two satisficing behaviors: (1)rounded numerical responses, (2) straightlining

21

<!-- page 22 -->

# Rounding:
# *R*s rounded* on fewer *Q*s in **text** than **voice**

| | Voice | Text |
| :--- | :---: | :---: |
| **Human** | 2.8 | 2 |
| **Automated** | 2.9 | 2.2 |

**Number Rounded* Answers** (y-axis: 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5)

*answers divisible by 5

22

<!-- page 23 -->

# Straightlining:
# Few Rs straightlined in text than voice

| | Voice | Text |
| :--- | :--- | :--- |
| **Human** | ~6.9% | ~3.3% |
| **Automated** | ~9.2% | ~3.6% |

**% Rs Straigtlining\*** (0% to 10%)

\*same answer for $\ge$ 7 out of 8 statements

23

*[Figure: This grouped bar chart shows the percentage of respondents straightlining (y-axis, ranging from 0% to 10%) across "Human" and "Automated" administration methods (x-axis), comparing "Voice" (blue bars) and "Text" (orange bars) modes. The main pattern indicates that straightlining is more than twice as high in Voice mode (~7% Human, ~9% Automated) compared to Text mode (~3.3% Human, ~3.6% Automated), with slightly higher rates under Automated administration for both modes.]*

<!-- page 24 -->

# Reducing Satisficing (Speeding) with Interactive Prompting

* Prompting web survey *R*s who were caught speeding (RT < 300 msec per word) slows subsequent responses (Conrad et al. 2017)

  *You seem to have responded very quickly. Please be sure you have given the question sufficient thought to provide an accurate answer. Do you want to go back and reconsider your answer?*

* 7 *Q*s about autobiographical quantities
  – true value unknown
* 7 simple arithmetic/probability questions for which true value known; enables measurement of response accuracy

24

<!-- page 25 -->

# Effect of Interactive Interventions on Speeding

| 3 or More Speeding Episodes | Prompt (% Speeders) | No Prompt (% Speeders) |
|---|---|---|
| Exp 1 | 55% | 61% |
| Exp 2 | 57% | 62% |
| Exp 3 | 25% | 34% |
| Exp 4 | 33% | 45% |

29

25

<!-- page 26 -->

# Effect of Prompting on Response Accuracy

**Average Number of Correct Answers**

* $p=0.1911$ (HS or less)
* $p=0.0300$ (Some Coll & Asso)
* $p=0.7652$ (BA or more)

* Response accuracy directly measured for simple arithmetic and probability questions
* Prompts improve accuracy for *Rs* with intermediate levels of education (Some College or Associates Degree) -- possible that most educated Rs prompted when not speeding and least educated Rs struggle whether speeding or not
* Reduces straightlining in one experiment

26

<!-- page 27 -->

# Alternative Approach to Reducing Satisficing Behavior

* Because prompting has punitive character, Conrad et al. (2017) also tried <u>motivating</u> *Rs* to be conscientious
  – Appeal to their better nature
  – Inspired by Cannell, Oksenberg & Converse (1977)
* in Exp. 3, presented a statement about importance of careful responding and asked *Rs* to commit to this

27

<!-- page 28 -->

# Commitment Statement

*“It is very important that you read each question carefully and think about your answer before you give it. We rely on our respondents being thoughtful and taking this task seriously.”*

*“I commit to reading each question carefully and thinking about my answer before I give it.”*

*Yes*
*No, but I will participate anyway*

* 99% selected “Yes”
* Neutral (No Commitment statement)
  *“Thank you very much for participating in our study. We are grateful that you are willing to contribute to our project and hope you find it a stimulating and worthwhile experience.”*

28

<!-- page 29 -->

# Effects of Prompting & Commitment on Response Times

- Prompt - Committed
- No Prompt - Committed
- Prompt - Not Committed
- No prompt - Not Committed

Mean RT (sec)

35
30
25
20
15
10

q14 q15 q16 q17 q18 q19 q20

- Main effects of prompting ($p < .001$) and commitment ($p < .05$)
- Interaction of prompting and commitment, n.s.

29

*[Figure: This line plot displays the effects of prompting and commitment on mean response times in seconds (y-axis, ranging from 10 to 35) across seven questions from q14 to q20 (x-axis). It compares four groups—"Prompt - Committed", "No Prompt - Committed", "Prompt - Not Committed", and "No prompt - Not Committed"—showing that all groups peak sharply at q16, with the "Prompt - Committed" group generally exhibiting the longest response times and "No prompt - Not Committed" the shortest.]*

<!-- page 30 -->

# Straightlining

% Respondents

14
12
10
8
6
4
2
0

Prompt - Commitment

No Prompt - Commitment

Prompt - No Commitment

No Prompt - No Commitment

Prompt-Commitment vs. Others, $p < .001$

30

*[Figure: This bar chart titled "Straightlining" displays the percentage of respondents on the vertical axis (ranging from 0 to 14) across four experimental groups on the horizontal axis: "Prompt - Commitment," "No Prompt - Commitment," "Prompt - No Commitment," and "No Prompt - No Commitment." The main pattern shows that the "Prompt - Commitment" group has a significantly lower rate of straightlining (just over 6%) compared to the other three groups, which all have rates around 12% to 13%.]*

<!-- page 31 -->

# Satisficing: Trait or State

* Schwartz et al. (2002) distinguish “maximizers” and “satisficers”
  – Maximizers look for optimal solution and, because this is hard to obtain, are generally less satisfied
* Used 17-item maximization scale and 5-item regret scale, as well as depression scale
* Maximizers were less happy, less optimistic, and had lower self-esteem and life satisfaction than satisficers

31

<!-- page 32 -->

# Survey Satisficing: Trait

* Kaminska et al. (2010) asked if reluctant *Rs* might be more likely to satisfice once agree to participate
  * computed latent classes for satisficers and “optimizers” based on four indicators in European Social Survey (conducted FTF):
  * DK, straightlining, extreme + middle measures, inconsistent responses
* Observed relationship between reluctance to participate and satisficing
  * Reluctant *Rs* more likely to satisfice, but not due to low ability
  * suggested better to simplify task than try to motivate reluctant *Rs*
* Additional evidence for satisficing as trait
  * Those with lower education more likely to exhibit primacy (Krosnick & Alwin) and to straightline (Rogers & Hersog, 1984)
  * Younger *Rs* more likely to speed (Zhang & Conrad, 2013)
* Seems survey satisficing is stable disposition

32

<!-- page 33 -->

# Survey Satisficing: State (situational)

* Vandenplas et al. (2017) investigated whether interviewers who consistently ask *Qs* quickly promote straightlining
* Observed correlation between interview speed and straightlining for 9 of 15 questions and in 5 of 15 countries
* If interviewer performance can affect satisficing, then cannot be entirely due to *R*’s disposition (trait)
* And Knowles, et al. (‘81) observed more straightlining at end of Q’aire when, presumably, *Rs* more fatigued
* Seems survey satisficing is situational

33

<!-- page 34 -->

# Survey Satisficing: Trait vs. State?

$$
p(\text{satisficing}) = \frac{a_1(\text{Task Difficulty})}{a_2(\text{Ability}) \times a_3(\text{Motivation})}
$$

* Is *Difficulty* a fixed component of the task? What about when one is relatively fatigued? What about for *Rs* with different levels of ability?
* *Motivation* can be chronic (optimizer vs. satisficer), but one can be momentarily motivated, e.g., by an interviewer rather than when answering a self-administered questionnaire
* Is *Ability* a fixed attribute or can it vary, e.g.. is *R* well rested? Is *R* hungry?

* Trait or State? Maybe, both

34

<!-- page 35 -->

# Summary

* Survey satisficing can be prevalent
  * Especially for some types of *Rs* (e.g., young, less educated, lower in aptitude)
  * Especially in modes with time pressure (e.g., voice interviews)
* Satisficing is a source of measurement error
  * Primacy clearly involves reduced attention to later options
  * Reverse straightlining clearly reflects inattentive or low effort responding
* It may be possible to reduce/disrupt survey satisficing with interactive interventions (e.g., speeding prompts) and direct attempts to increase motivation (e.g., commitment request)
* But there may be chronic satisficers whose behavior is hard to change
* External factors like interviewer speed of delivery can superimpose additional satisficing on *Rs'* satisficing predisposition
* Seems likely there are both chronic and momentary contributions to survey satisficing

35
