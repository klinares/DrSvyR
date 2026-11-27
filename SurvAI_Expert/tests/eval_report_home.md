# SurvAI_Expert evaluation, 2026-11-27

## In short

- The tool was tested on 103 questions written from the course materials: 100 were searched and 40 answered in full.
- 39 of the 40 answers (98%) were judged correct; 1 were judged incorrect.
- Every citation pointed to a real source, and every formula shown came from the store rather than being typed by the model.
- For 90% of the questions, the document the question was written from was among the first 10 sources found.
- The search figures vary by a few points from run to run, because the model plans each search afresh.

## How to read this

- **hit@5, hit@10**: the share of questions whose source document is among the first 5 (or 10) passages found.
- **judge**: the same model, asked to grade each answer against the course passage the question came from: correct, partly correct or incorrect.
- **unsupported claim**: a statement of fact in an answer that none of the sources given to it supports, as counted by the judge.

Profile **home**, model `claude-sonnet-5-5`. Store receipt: identical to data/catalog/receipt.csv.

Gold: 108 questions; 3 unmapped (R scripts not in the store) and 2 that are not questions were dropped, leaving 103. 100 were planned and 40 answered (stratified by type).

## Retrieval: raw question vs planned search

Hit@k: the gold document is among the first k passages. Raw = the question text alone (part 1); planned = the model's plan, fused, at most 2 passages per document.

| type | n | raw_hit5 | raw_hit10 | planned_hit5 | planned_hit10 |
| --- | --- | --- | --- | --- | --- |
| all | 100 | 0.810 | 0.920 | 0.810 | 0.900 |
| code | 26 | 0.885 | 0.962 | 0.923 | 0.962 |
| concept | 40 | 0.850 | 0.950 | 0.825 | 0.950 |
| equation | 34 | 0.706 | 0.853 | 0.706 | 0.794 |

Equation questions: a formula from the gold document (or its formula group) was among those found for 23 of 34.

## Answer checks (no model)

| type | n | citations_valid | formula_tokens_valid | no_display_math | with_code | code_parses | unverified_functions | uncited_per_answer | median_words |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 1 | 1 | 1 | 35 | 1 | 1 | 4.650 | 178 |
| code | 13 | 1 | 1 | 1 | 13 | 1 | 0 | 3.692 | 171 |
| concept | 14 | 1 | 1 | 1 | 9 | 1 | 1 | 4.786 | 228 |
| equation | 13 | 1 | 1 | 1 | 13 | 1 | 0 | 5.462 | 159 |

## Judge (the same model)

| type | n | correct | partly | incorrect | unsupported_claims | wrongly_said_missing |
| --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 39 | 0 | 1 | 91 | 0 |
| code | 13 | 13 | 0 | 0 | 33 | 0 |
| concept | 14 | 14 | 0 | 0 | 30 | 0 |
| equation | 13 | 12 | 0 | 1 | 28 | 0 |

## Cost and time

180 model calls, about $2.33 (from token counts at the profile's prices).

| step | median_seconds |
| --- | --- |
| plan | 2.513 |
| search | 0.218 |
| answer | 6.542 |

## Five worst answers

- **What is the formula for calculating weights using propensity score subclassification?** (incorrect, 3 unsupported claims): The course passage defines propensity subclassification (PSC) for a non-probability sample, with weight w_j = sum of probability-sample weights d_k in subclass g divided by n_np(g), but the answer gives the nonresponse-adjustment formula a_2c = 1/phi_c, which is a different method; its extra claims (the R code details, the svydesign/fpc advice, and the high-variance warning) go beyond the sources or are not tied to them.}
- **What should I keep consistent when using multiple graphs to make comparisons?** (correct, 4 unsupported claims): The answer correctly gives the passage's three principles (common size, common scales, helpful alignment) plus colour/shape for groups, but it adds unsupported elaborations such as the claim that equal sizes let readers compare lengths and slopes, the 'same colour means same group in every panel' rule, and the claim that the sources do not cover enforcing shared scales in code, while the S3, S5 and S7 examples are loosely tied to the principles.
- **How do I perform ridge regression and find the optimal lambda using cross-validation in R?** (correct, 4 unsupported claims): The answer matches the course passage on using glmnet with alpha = 0, cv.glmnet, lambda.min and lambda.1se, and the formula and predict steps are supported; it adds a few unsupported points (seed advice, survey-weight caveats, the `predict(..., s = bestlam1)` detail, and the claim about numeric matrices), while the 10-fold default is labelled as not from the library.
- **How can I compare a reduced model containing only the 'chas' variable to a full model containing both 'chas' and 'indus' to see if the mo...** (correct, 4 unsupported claims): The answer correctly prescribes the general F test via anova() on the nested models and reports the course's R², F=170.85 and df results, but it adds several claims no source supports (that Boston is not a simple random sample, that measurement error cannot be assessed, the residual-assumption checklist, and the claim that the F-test 'treats observations as SRS'), and it also misstates that p and q count parameters rather than predictors including intercept only loosely.
- **What is the formula for calculating the required sample size for each domain when testing the difference in means?** (correct, 3 unsupported claims): The answer gives the correct formula n = [σ_d(z_{1-α} − z_β)/δ]² with the right definitions and the 'each domain' note, but it adds some claims no source supports: that the result is a minimum because coverage, nonresponse or measurement error are not covered, that power.t.test gives a slightly larger n because it is t-based, and that the formula assumes SRS or stratified SRS citing S12 (S12 supports SRS only).
