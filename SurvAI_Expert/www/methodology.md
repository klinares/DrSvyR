# Methodology

How the tool works, what it was built from, and how well it did when tested.

## The sources of error

| Source of error | The question to ask |
|---|---|
| Coverage | Could everyone in the population have been reached? |
| Sampling | How were people selected, and how much would the result change with a different sample? |
| Nonresponse | Who did not answer, and are they different from those who did? |
| Validity | Does the question measure what you mean to measure? |
| Measurement | Did people answer accurately, and did the interviewer or the mode affect them? |
| Processing | Were answers coded, edited and cleaned without changing them? |
| Adjustment | Do the weights correct the problems above, or add new ones? |

For data that was not collected by a survey, such as administrative records
or data from apps and websites, it asks the matching questions: who ends up
in the data, how records were linked, and how the system that produced the
data shaped it.

## What is in the library

The library is teaching material in four areas: applied sampling, survey
estimation, measurement error, and data science with survey and found data.
It holds lecture notes, slides, exercises and their solutions, a textbook on
sample design and weighting, and open books on survey analysis.

Each document was split into short passages. Every passage keeps the page it
came from, so that each statement in an answer can be traced to the original.

<details><summary>More detail</summary>

{{LIBRARY_TABLE}}

- **Passages** are short sections of text, usually a few paragraphs.
- **Formulas** were taken from the documents as written, with the meaning of
  each symbol where the text gives it. A formula that appears in several
  documents is listed once, with every place it occurs.
- **Code examples** are worked examples in R, the statistics language used in
  the courses.
- Each passage was labelled by topic (for example weighting, variance
  estimation or nonresponse) and by the part of the survey process it
  concerns. The labels help the search find the right material.

</details>

## How an answer is produced

1. Your question is turned into a search: the key terms, other ways of saying
   them, and the topics it concerns. A message with several questions is split
   into parts, and each part is searched on its own.
2. The library is searched, and the passages, formulas and examples that
   match best are kept.
3. The answer is written from what was found, and each statement is tied to
   the passage it came from.
4. The answer is checked before you see it: every source it points to must
   exist, every formula must come from the library, and any code must be
   valid.

<details><summary>More detail</summary>

- The search looks for the words of your question and of the search terms,
  giving more weight to rare words and to the topic labels. Your own wording
  is always part of the search, because it often matches the original
  document best.
- At most two passages are taken from any one document, so that one long
  document does not crowd out the others.
- Formulas are never retyped by the writer of the answer. It names the
  formula it wants, and the exact formula from the library is put in its
  place.
- When a formula is shown, a short example in R that computes it follows,
  built from the worked examples in the library.
- Each question uses two calls to the language model: one to plan the
  search and one to write the answer.

</details>

## How it keeps answers accurate

- It answers from the library: each statement comes from a passage it found.
- Formulas are copied from the library exactly. They are never retyped.
- If the library does not cover your question, it says so.
- Anything it adds from outside the library is labelled
  "Not from the library".

## Advice

When you describe a situation or ask what to do, the tool answers as an adviser instead of
looking one thing up. It searches the library for each side of the decision, then lays out two
or three options, what each does to the sources of error and to cost, what it would do and
why, how to carry it out, and what to check.

Two kinds of statement appear in advice, and they are kept apart:

- **What the library says.** Statements about methods come from the library, as in any other
  answer.
- **The tool's judgment.** Sentences that begin "My assessment" are the tool's own reasoning
  about your survey. They are not from the library. Treat them as a colleague's opinion.

The tool recommends; you decide. If it lacks a fact that would change its advice, it gives the
advice for each case and asks. Fill in "My survey" on the Ask tab and it will not need to.

## How it was tested

- The tool was tested on 103 questions written from the course materials:
  100 were searched and 40 answered in full.
- 39 of the 40 answers (98%) were judged correct and 1 incorrect.
- Every citation pointed to a real passage, and every formula shown came from
  the library rather than being typed by the model.
- For 90% of the questions, the document the question was written from was
  among the first 10 passages found.
- Advice was tested on 12 situations of the kind analysts bring. It passed
  11: it raised at least three quarters of the points a survey methodologist
  would raise, and gave none of the advice marked as wrong.

<details><summary>More detail</summary>

- Each test question was written from one document in the library, so the
  right source was known in advance.
- The answers were graded by the same language model, comparing each answer
  with the passage the question came from: correct, partly correct or
  incorrect. The answer judged incorrect was asked for the weights from
  propensity score subclassification and gave a nonresponse adjustment
  formula instead.
- Advice was graded the same way, against a list of points written for each
  situation in advance. Across the 12 it raised 41 of 47 points (87%). The
  one that failed did not mention that subgroups have fewer degrees of
  freedom.
- The search results vary by a few points from run to run, because the
  search is planned afresh for each question.
- Questions asking for a formula were the hardest to search: for 23 of 34,
  a formula from the right document was among those found.

</details>

## Limits

- It does not see or run your data. Example code uses the column names you
  give it, and you run it yourself.
- It knows only what is in the library. When the passages found do not cover
  a point, it says so.
- It can be wrong. Check what matters against a textbook or a methodologist,
  especially before a decision that carries weight.
- The Report reader reads the report you upload; it does not search the
  library, and a scanned report with no text layer cannot be read.
