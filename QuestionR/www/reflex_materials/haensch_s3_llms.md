# Large Language Models in Questionnaire Development

Source: Haensch, Anna-Carolina. Large Language Models in Questionnaire Development. IASS/WSS Webinar, Session 3. LMU Munich.

File: `haensch_s3_llms.pdf` (30 slides). This text was extracted from the PDF by program. Figures, tables and layout are not carried over; open the PDF for those.

## Slide 1

Large Language Models in
Questionnaire
Development

IASS/WSS Webinar Session 3
Anna-Carolina Haensch, LMU Munich

## Slide 2

Where Sessions 1 and 2 left us

2

Session 1

Questions can fail at every stage of the response process: comprehension, retrieval, judgment/estimation,
reporting.

Session 1

Eight general guidelines for writing survey questions, plus specific rules for behavioral, attitudinal and
sensitive questions.

Session 2

Testing methods differ and do not always converge: use at least one, and several when possible.

## Slide 3

Outline

Exercise

3

1

Why LLMs, and where they enter questionnaire design

2

LLMs for writing survey questions

3

LLMs for evaluating, testing and translating questions

4

What we do not know yet
LLM Question Lab: write and evaluate questions with LLMs

## Slide 4

1. Why LLMs, and where they
enter questionnaire design

## Slide 5

Writing new questions is hard, and LLMs add a fourth route

Generate survey questions
with an LLM

5

Yan, Session 1

## Slide 6

Already in use

6

Microsoft (2026); Google (2025); Qualtrics (2026)

## Slide 7

The users who gain most can check least

High gain,
low scrutiny

Ability to verify
item quality

Gain most

Users without methodological
training

Least able to verify
Benefit from
LLM-generated items
low

7

Methodological training

high

when a generated question
violates established design
standards

## Slide 8

LLMs now reach nearly
every stage of the survey
lifecycle

8

Diagram adapted from Groves et al. (2009)

## Slide 9

Two research strands, one argument
Our argument

Strand 1: writing questions
1

2

9

LLMs draft single questions
and complete questionnaires

1

Existing work establishes
plausibility rather than
measurement quality.

2

It focuses on single questions
rather than on questionnaires as
a whole.

Strand 2: evaluating,
testing and translating
LLMs review, test and
translate questions before
fielding

## Slide 10

2. LLMs for writing survey questions

## Slide 11

General guidelines from session 1
Use simple, familiar words (avoid technical terms,
jargon and slang)

Plus question-specific rules

Use simple syntax
Avoid words with ambiguous meanings

Behavioral: short reference
periods, open answers for
numbers

Strive for wording that is specific and concrete
Make response options exhaustive and mutually
exclusive

Attitudinal: construct-specific
instead of agree-disagree,
balanced wording, filters

Avoid leading or loaded questions

11

Ask about one thing at a time (avoid double-barreled
questions)
Avoid questions with single or double negations

11

Sensitive: forgiving wording,
open or high-frequency
formats

## Slide 12

Survey studies find plausible, relevant items

Fielded with respondents

Two studies

Behzad et al. 2026; Martini, Scagnelli and
Trujillo Medina 2026 (n = 140 students)

Ratings or SQP predictions

et al. 2025; Maiorino et al. 2023;
Four studies Adhikari
Padgett et al. 2024; Fuchs, Haensch and Weber
2026

GPT-generated surveys recovered the
dominant attitudinal divisions; unedited AI
scales largely matched established ones as
whole scales.

Raters find items largely relevant and clear;
SurveyMonkey’s checklist reviews of its own
tool agree. SQP-predicted quality varies with
model and prompt.

Finer structure diverged (respondent
groups, subscales).
Only the left-hand evidence comes from real respondents; the right-hand rests on ratings and predictions.
12

## Slide 13

Generation is already a product feature
Tool

What it does

SurveyMonkey Build with AI

Full survey from a brief prompt; OpenAI-based, free
(2023)

Microsoft Copilot in Forms

Drafts title, questions and options; advertised to avoid
leading and double-barreled items

Google Forms with Gemini

Comparable prompt-based generation (2025)

Qualtrics

Question suggestions (Delighted, 2024); ExpertReview
flags draft errors; AI follow-ups during fielding

One vendor has checked its own tool against checklist criteria; we know of no published evaluation of the
measurement quality of these items.
13

## Slide 14

Documented weaknesses appear at three levels

Prompt and model

Wording

Questionnaire

Usable items need technically precise

Recurring flaws, even with prompts

Too many open-ended questions and

prompts, not generic instructions

that build in best practices

yes/no answer scales

The sensitivity holds across

Double-barreled and two-part

Difficulty keeping a logical question

domains and model families: a

questions

order

reproducibility concern

14

## Slide 15

Every default is a design decision

“Public transport in my city is reliable.”

How many points?

Every point
labeled?

A neutral midpoint?

A don’t-know
option?

Agree-disagree or
construct-specific?

With a one-line prompt, the model makes these choices for you!
Build survey methodology into the generation process, and judge the
output by empirical measurement criteria.
15

## Slide 16

3. LLMs for evaluating, testing
and translating questions

## Slide 17

Where LLMs fit into the testing methods from Session 2
Class of methods

Pros and cons (Session 2)

Where LLMs come in

Expert methods: Expert review,
QAS, QUAID, SQP

Quick and inexpensive; no actual
respondents

LLM as expert reviewer

Lab-based methods: Focus groups,
cognitive interviews, eye-tracking

Actual respondents; expensive

LLM as simulated respondent in
think-aloud interviews

Field-based methods: Web
probing, experiments, behavior
coding, reliability and validity

Large data collection from actual
participants; resource heavy

Simulation attempted (synthetic splitballots), but no substitute for real
respondents

As in Session 2: methods find partly different problems, so combine several when possible.

17

## Slide 18

As expert reviewers, LLMs are a useful but noisy first pass
What LLMs do well
Olivos and Liu (2025)
Use LLM feedback before human pretesting to
streamline revision and need fewer pretest rounds
Tao et al. (2024)
Example questions improved detection, most with
flawed and flawless examples; repeated ratings
raised precision but cost recall.
Slowinski et al. (2026); Session 2
Two-stage workflow: the LLM screens first, then
methodologists decide which flags need revision.

Where human review remains essential
Slowinski et al. (2026); Session 2
More flags than methodologists, not all defects;
overreports sensitivity and burden; misses
nuanced comprehension, cultural framing, implicit
assumptions.
Metheney and Yehle (2025), pre-registered,
262 items
Feedback depends on model version and
persona. Many problems a human expert did
not flag: genuine insights mixed with
spurious alerts.

LLMs are a useful first filter, but not a substitute for expert human review.
18

## Slide 19

As simulated respondents in cognitive interviews, LLMs catch other
problems
What LLMs do well

Where human review remains essential

Sturgis, Roberts and Robinson (2026)

Adhikari et al. (2025)

Synthetic think-aloud transcripts, coded for
problems by a second LLM

LLM personas answered and commented on
generated items; the pipeline flagged problems.

Different problem types than LLM expert review;
highly sensitive to prompt and model

Experts rated the revised items as worse than the
originals.

75% of deliberately embedded flaws were detected
by the best configuration

LLMs are a useful first filter, but not a substitute for test respondents
19

## Slide 20

A key limit of synthetic respondents (so far)

LLM-generated responses do not consistently reproduce
human sensitivity to question wording.
One response: ground the LLM in evidence from human respondents
Slowinski et al. (2026) built a pipeline from real cognitive-interview findings. It anticipated structural and
wording problems, recall and computation difficulties, and ambiguous terms, but missed comprehension
problems and questions that did not apply to all respondents.

20

Tjuatja et al. (2024); Slowinski et al. (2026)

## Slide 21

In translation, LLMs are a useful drafter but not the committee
What LLMs do well

Where human input remains essential

Zavala-Rojas et al. (2024)
Replacing one human translation with neural
machine translation (not an LLM) plus postediting: review outputs of hardly distinguishable
quality (ESS, EVS).

Adhikari et al. (2025)
Adapting a U.S. climate opinion survey for South
Africa: participants rated the adapted items only
slightly clearer and less biased (p < .10).

Haavisto and Welsch (2024)
Help assess whether translated questions keep
their meaning.
Metheney and Yehle (2024)
Flag features of the source question likely to
cause translation problems.

LLMs are a useful first drafter, but not a substitute for translators
21

## Slide 22

The 2026 GSS started its Spanish translation from an LLM draft

For the new and
revised 2026 GSS
items, a Gemini draft
replaced the
independent human
draft translations; the
rest of TRAPD,
including human
review and
adjudication, was
unchanged.

22

## Slide 23

4. What we do not know yet

## Slide 24

What we do not know yet
Whether LLM-generated instruments yield reliable, valid data and the
same conclusions with real respondents
How well findings hold across models, prompts and populations
When LLM assistance helps and when it introduces measurement error
Whether synthetic respondents mirror how real respondents understand
questions, especially minority subgroups
How LLMs perform for low-resource languages and in cultural adaptation
How LLMs handle whole questionnaires: order, routing, scale consistency

## Slide 25

5. Exercise

## Slide 26

Exercise

Write a survey question with an LLM, then evaluate it as a methodologist would.
• Go to your Zoom breakout room, open the LLM Question Lab and choose a behavioral,
attitudinal or sensitive question.
• Run the basic prompt, then the informed prompt with the Session 1 guidelines, each in a new
chat.
• Enter each answer and code it: format, number of options, labels, midpoint, don’t know,
reference period, problems, verdict.
• Debrief: Which defaults did the LLMs choose? Did the guidelines help? Would you field the
question?

26

## Slide 27

6. Closing

## Slide 28

Writing questions with LLMs: recommendations
1.

Start with existing questions
•

2.

Prompt for a design, not a topic
•

3.

Above all the number of response categories and yes/no formats the model picks on its own

Check the questionnaire as a whole
•

28

Session 1 guidelines or a structured appraisal such as QAS-99; well-formed is not the same as valid

Scrutinize the defaults
•

5.

State construct, target population, mode and intended response format

Check every draft against the guidelines
•

4.

Previously evaluated questions first; check they transfer to your population, language and mode

Order, routing and consistent scales, using Session 2’s grouping advice and final checklist

## Slide 29

Evaluating and translating with LLMs: recommendations
6.

Use LLM review as first-pass triage
•

7.

Keep testing with real respondents
•

8.

An LLM draft can replace initial human translations within team-based review and adjudication (2026 GSS)

Document AI use
•

29

LLM review complements, not replaces, pretesting with human respondents; test key questions before fielding

Keep the translation committee
•

9.

An inexpensive extra screen for large item sets; methodologists decide which flags need revision

Model, version, date and prompts, and which questions were generated or revised with AI (cf. AAPOR Task Force
report 2026)

## Slide 30

Thank you!
Questions and discussion

Anna-Carolina Haensch
LMU Munich · C.Haensch@lmu.de
Fuchs, Haensch and Yan, The Survey Statistician (forthcoming)
