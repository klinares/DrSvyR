# Methodology

How the tool works, what it was built from, and how well it did when tested.

## What is in the library

The library is teaching material in four areas: applied sampling, survey
estimation, measurement error, and data science with survey and found data.
It holds lecture notes, slides, exercises and their solutions, a textbook on
sample design and weighting, and open books on survey analysis.

Each document was split into short passages. Every passage keeps the page it
came from, so an answer can point you back to the original.

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
3. The answer is written from what was found, and each statement points to
   the passage it came from.
4. The answer is checked before you see it: every source it points to must
   exist, every formula must come from the library, and any code must be
   valid.

<details><summary>More detail</summary>

- The search looks for the words of your question and of the search terms,
  giving more weight to rare words and to the topic labels. Your own wording
  is always part of the search, because it often matches the original
  document best.
- At most three passages are taken from any one document, so that one long
  document does not crowd out the others.
- Formulas are never retyped by the writer of the answer. It names the
  formula it wants, and the exact formula from the library is put in its
  place.
- A sentence that points to no passage is shown with a dotted underline.
  Anything added from outside the library is labelled "Not from the library".
- Each question uses two calls to the language model: one to plan the
  search and one to write the answer.

</details>

## How it was tested

- The tool was tested on 103 questions written from the course materials:
  100 were searched and 40 answered in full.
- 38 of the 40 answers (95%) were judged correct; none was judged incorrect.
- Every citation pointed to a real passage, and every formula shown came from
  the library rather than being typed by the model.
- For 87% of the questions, the document the question was written from was
  among the first 10 passages found.

<details><summary>More detail</summary>

- Each test question was written from one document in the library, so the
  right source was known in advance.
- The answers were graded by the same language model, comparing each answer
  with the passage the question came from: correct, partly correct or
  incorrect. The two answers judged partly correct left out part of what the
  passage said.
- The search results vary by a few points from run to run, because the
  search is planned afresh for each question.
- Questions asking for a formula were the hardest to search: for 26 of 34,
  a formula from the right document was among those found.

</details>

## Limits

- It does not see or run your data. Example code uses the column names you
  give it, and you run it yourself.
- It knows only what is in the library. When the passages found do not cover
  a point, it says so.
- It can be wrong. Read the passages it points to, especially before a
  decision that carries weight, and ask a methodologist when it matters.
- The Report reader reads the report you upload; it does not search the
  library, and a scanned report with no text layer cannot be read.
