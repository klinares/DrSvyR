# SurvAI_Expert evaluation, 2026-11-15

## In short

- The tool was tested on 103 questions written from the course materials: 100 were searched and 40 answered in full.
- 38 of the 40 answers (95%) were judged correct; none was judged incorrect.
- Every citation pointed to a real source, and every formula shown came from the store rather than being typed by the model.
- For 87% of the questions, the document the question was written from was among the first 10 sources found.
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
| all | 100 | 0.810 | 0.920 | 0.760 | 0.870 |
| code | 26 | 0.885 | 0.962 | 0.885 | 0.962 |
| concept | 40 | 0.850 | 0.950 | 0.775 | 0.900 |
| equation | 34 | 0.706 | 0.853 | 0.647 | 0.765 |

Equation questions: a formula from the gold document (or its formula group) was among those found for 26 of 34.

## Answer checks (no model)

| type | n | citations_valid | formula_tokens_valid | no_display_math | with_code | code_parses | unverified_functions | uncited_per_answer | median_words |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 1 | 1 | 1 | 20 | 1 | 0 | 6.500 | 250.5 |
| code | 13 | 1 | 1 | 1 | 12 | 1 | 0 | 6.462 | 255.0 |
| concept | 14 | 1 | 1 | 1 | 0 | 1 | 0 | 6.357 | 253.5 |
| equation | 13 | 1 | 1 | 1 | 8 | 1 | 0 | 6.692 | 248.0 |

## Judge (the same model)

| type | n | correct | partly | incorrect | unsupported_claims | wrongly_said_missing |
| --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 38 | 2 | 0 | 57 | 1 |
| code | 13 | 11 | 2 | 0 | 25 | 0 |
| concept | 14 | 14 | 0 | 0 | 18 | 0 |
| equation | 13 | 13 | 0 | 0 | 14 | 1 |

## Cost and time

180 model calls, about $2.04 (from token counts at the profile's prices).

| step | median_seconds |
| --- | --- |
| plan | 2.478 |
| search | 0.167 |
| answer | 6.004 |

## Five worst answers

- **How can I use R to calculate the expected number of housing units to be selected and the associated probabilities for the possible achiev...** (partly correct, 2 unsupported claims): The answer correctly gives the floor/ceiling rule with probabilities from the fractional part (18.425 gives 18 w.p. 0.575, 19 w.p. 0.425) and the R workflow, but it labels the course's S1 formula as wrong without acknowledging that this is the course's own R solution, and it adds unsupported claims about the rate formula and systematic sampling.
- **How can I use R to calculate the design effects for weighting and clustering across different survey designs?** (partly correct, 2 unsupported claims): The answer correctly gives the core method (deff_weight = 1 + CV², deff_cluster = 1 + (b-1)ρ, total = product) and ties it to survey-package code, but it never shows the passage's direct R computation across several designs (the tibble of rho and b), and it adds unsupported claims such as the TSE framing with adjustment error and the fpc advice.
- **How can I calculate the common relative risk and odds ratio for a two-way table using SAS?** (correct, 3 unsupported claims): The answer correctly gives the PROC FREQ ... / CMH code and reads the output values accurately against the passage, but it adds a few claims no source supports, such as order=data fixing the numerator row, the table orientation advice, and the study-design advice.
- **How can I retrieve socio-demographic data for census tracts in Illinois from the ACS 5-Year dataset using R?** (correct, 3 unsupported claims): The answer correctly uses getCensus with region 'tract:*' and regionin 'state:17' (as in the course passage), plus a tidycensus alternative and the -666666666 missing recode, though a few details (free key, FIPS 17 meaning, vintage as end year, 'nonresponse' framing) go beyond the sources.
- **How can I load the hprice dataset from the faraway package and view its summary statistics and documentation in R?** (correct, 3 unsupported claims): The answer gives the correct code (data("hprice"), summary(), ?faraway::hprice) matching the course passage, but it adds a few claims no source supports: that summary() ignores clustering and uses no strata, weights or FPC; that plain summary relates to coverage and sampling error; and that back-transforming narsp limits measurement and processing error."}
