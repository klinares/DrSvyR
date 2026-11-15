# SurvAI_Expert evaluation, 2026-11-15

## In short

- The tool was tested on 103 questions written from the course materials: 100 were searched and 40 answered in full.
- 38 of the 40 answers (95%) were judged correct; none was judged incorrect.
- Every citation pointed to a real source, and every formula shown came from the store rather than being typed by the model.
- For 89% of the questions, the document the question was written from was among the first 10 sources found.
- The search figures vary by a few points from run to run, because the model plans each search afresh.

## How to read this

- **hit@5, hit@10**: the share of questions whose source document is among the first 5 (or 10) passages found.
- **judge**: the same model, asked to grade each answer against the course passage the question came from: correct, partly correct or incorrect.
- **unsupported claim**: a statement of fact in an answer that none of the sources given to it supports, as counted by the judge.

Profile **home**, model `claude-sonnet-5-5`. Store receipt: identical to data/catalog/receipt.csv.

Gold: 108 questions; 3 unmapped (R scripts not in the store) and 2 that are not questions were dropped, leaving 103. 100 were planned and 40 answered (stratified by type).

## Retrieval: raw question vs planned search

Hit@k: the gold document is among the first k passages. Raw = the question text alone (part 1); planned = the model's plan, fused, at most 3 passages per document.

| type | n | raw_hit5 | raw_hit10 | planned_hit5 | planned_hit10 |
| --- | --- | --- | --- | --- | --- |
| all | 100 | 0.810 | 0.920 | 0.790 | 0.890 |
| code | 26 | 0.885 | 0.962 | 0.885 | 0.962 |
| concept | 40 | 0.850 | 0.950 | 0.800 | 0.900 |
| equation | 34 | 0.706 | 0.853 | 0.706 | 0.824 |

Equation questions: a formula from the gold document (or its formula group) was among those found for 24 of 34.

## Answer checks (no model)

| type | n | citations_valid | formula_tokens_valid | no_display_math | with_code | code_parses | unverified_functions | uncited_per_answer | median_words |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 1 | 1 | 1 | 33 | 1 | 1 | 4.600 | 173.5 |
| code | 13 | 1 | 1 | 1 | 13 | 1 | 0 | 5.615 | 180.0 |
| concept | 14 | 1 | 1 | 1 | 7 | 1 | 1 | 4.786 | 193.0 |
| equation | 13 | 1 | 1 | 1 | 13 | 1 | 0 | 3.385 | 153.0 |

## Judge (the same model)

| type | n | correct | partly | incorrect | unsupported_claims | wrongly_said_missing |
| --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 38 | 2 | 0 | 80 | 0 |
| code | 13 | 11 | 2 | 0 | 25 | 0 |
| concept | 14 | 14 | 0 | 0 | 27 | 0 |
| equation | 13 | 13 | 0 | 0 | 28 | 0 |

## Cost and time

180 model calls, about $2.24 (from token counts at the profile's prices).

| step | median_seconds |
| --- | --- |
| plan | 2.596 |
| search | 0.178 |
| answer | 6.365 |

## Five worst answers

- **How can I use R to calculate the expected number of housing units to be selected and the associated probabilities for the possible achiev...** (partly correct, 3 unsupported claims): The answer gives the right approach (expected size = f_h × housing units, with floor and ceiling as the two achieved sizes), and its own code and probabilities are statistically sound. It then misdescribes the course code as 'the same two probabilities', although that code's weights are mathematically wrong (it gives the lower value the weight 5E+6(1−E) rather than 6−E), and it adds several claims the sources do not support.
- **What is the formula for calculating the effective sample size when accounting for design inflation?** (partly correct, 3 unsupported claims): The core formula n_eff = n/deff is correct and matches the passage, but the answer adds a wrong F1 formula (multiplying deffs times n_SRS, which is the planning inverse and mislabelled as n*), plus unsupported claims such as weights feeding adjustment error and the FPC check.
- **How can I calculate the common relative risk and odds ratio for a two-way table using SAS?** (correct, 4 unsupported claims): The answer matches the course passage on the PROC FREQ cmh code and output, but it adds several claims no source supports, including the survey-weight and simple-random-sampling caveat, the Mantel-Haenszel/Logit equivalence for a single table, the column-ordering advice, and the design guidance for Case-Control versus Cohort rows.
- **What is the formula for calculating the required sample size for each domain when testing the difference in means?** (correct, 4 unsupported claims): The answer gives formula 4.11, n = [σ_d (z_{1-α} − z_β)/δ]^2, per domain with the correct conditions, matching the passage, but adds some unsupported extras (e.g., the design-effect and finite-population-correction caveats, the statement that the choice does not address nonresponse or coverage error, and the specific power.t.test two-sample/one.sided usage claims).
- **How do I perform ridge regression and find the optimal lambda using cross-validation in R?** (correct, 4 unsupported claims): The answer matches the course workflow (glmnet with alpha=0, cv.glmnet, lambda.min and lambda.1se, coef and bestlam), but some added details are not in the sources: 10 folds by default, the random fold seed advice, the edge-of-grid check, and the test-set evaluation advice.[S1] does not support the refit at the chosen lambda claim in the form given, which adds a further gap.
