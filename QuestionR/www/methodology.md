# How QuestionR works and what stands behind it

## What it is built on

The rules QuestionR applies are standard questionnaire design practice, not
the opinions of an AI model. They were drawn from:

- **The Total Survey Error framework** and the model of how people answer
  survey questions: they have to understand the question, recall what is
  needed, form a judgment, and report an answer. Each rule protects one of
  those steps.
- **A webinar series on questionnaire design** given for the International
  Association of Survey Statisticians and the Washington Statistical Society
  by Ting Yan (NORC) and Anna-Carolina Haensch (LMU Munich): general wording
  rules; rules for behavioral, attitudinal and sensitive questions; survey
  mode; putting a questionnaire together; surveys in more than one country
  or language; and the use of AI in questionnaire work.
- **Recent academic studies** of how well AI models write and review survey
  questions, and where they go wrong.
- **Graduate course material** on cognition and survey measurement.

## How it keeps the AI in check

- **The rules are written down.** Every model gets the same rules, and the
  tool shows you the instructions before anything is sent.
- **Several models draft; one reviews.** The reviewing model checks every
  draft against a fixed checklist without knowing which model wrote it. It
  recommends questions exactly as drafted and tells you what it still
  doubts.
- **It does not invent facts about a country.** Local terms, units and
  sensitivities are flagged for someone who knows the setting.
- **Other languages.** A version in another language is a first draft only.
  It still needs review by fluent speakers, a decision on disagreements,
  testing with respondents, and a record of what was decided.
- **Everything is recorded.** Each output states the models used, the date
  and the instructions, so the work can be explained and repeated.

## How it was tested

The review step was run on a published test set: 20 questions with 48
planted faults and 7 well-tested questions from the European Social Survey.
It found 36 of the 48 faults (75 percent) and raised fewer than one concern
for every two well-tested questions. It was strongest on questions that ask
two things at once, recall problems and vague wording, and weakest on
sensitivity. This was one run with one AI model on planted faults, which are
clearer than real ones, so treat it as a guide, not a guarantee.

## What it cannot do

- It is an expert review and a first draft by AI models. It is not a
  pretest and does not show how respondents will understand a question.
- It can miss faults and can raise concerns that do not matter. Use your
  judgment, and look at the minor concerns as well.
- Test key questions with real respondents before fielding, and keep the
  record of AI use with the questionnaire.
