# SurvAI_Expert evaluation, 2026-11-15

Profile **home**, model `claude-sonnet-5-5`. Store receipt: identical to data/catalog/receipt.csv.

Gold: 108 questions; 3 unmapped (R scripts not in the store) and 2 that are not questions were dropped, leaving 103. 100 were planned and 40 answered (stratified by type).

## Retrieval: raw question vs planned search

Hit@k: the gold document is among the first k passages. Raw = the question text alone (part 1); planned = the model's plan, fused, at most 3 passages per document.

| type | n | raw_hit5 | raw_hit10 | planned_hit5 | planned_hit10 |
| --- | --- | --- | --- | --- | --- |
| all | 100 | 0.810 | 0.920 | 0.680 | 0.790 |
| code | 26 | 0.885 | 0.962 | 0.769 | 0.846 |
| concept | 40 | 0.850 | 0.950 | 0.700 | 0.775 |
| equation | 34 | 0.706 | 0.853 | 0.588 | 0.765 |

Equation questions: a formula from the gold document (or its formula group) was among those found for 23 of 34.

## Answer checks (no model)

| type | n | citations_valid | formula_tokens_valid | no_display_math | with_code | code_parses | unverified_functions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 1 | 0.925 | 1 | 30 | 1 | 0 |
| code | 13 | 1 | 0.846 | 1 | 13 | 1 | 0 |
| concept | 14 | 1 | 0.929 | 1 | 6 | 1 | 0 |
| equation | 13 | 1 | 1.000 | 1 | 11 | 1 | 0 |

## Judge (the same model)

| type | n | correct | partly | incorrect | unsupported_claims | wrongly_said_missing |
| --- | --- | --- | --- | --- | --- | --- |
| all | 40 | 38 | 2 | 0 | 93 | 2 |
| code | 13 | 13 | 0 | 0 | 38 | 0 |
| concept | 14 | 13 | 1 | 0 | 21 | 0 |
| equation | 13 | 12 | 1 | 0 | 34 | 2 |

## Cost and time

180 model calls, about $2.13 (from token counts at the profile's prices).

| step | median_seconds |
| --- | --- |
| plan | 2.460 |
| search | 0.132 |
| answer | 8.638 |

## Five worst answers

- **What are some ways to handle variation in sample size, and how does this affect the choice of estimator for the mean?** (partly correct, 3 unsupported claims): The answer correctly says the ratio mean is appropriate when sample size is random, but it omits the passage's listed ways to handle variation (depart from epsem with weighting, create equal-size clusters, stratify by size, PPS), and it adds unsupported claims such as the bias-for-stability tradeoff, the Total Survey Error section, and the strata/fpc claims.
- **What is the formula for calculating weights using propensity score subclassification?** (partly correct, 2 unsupported claims): The answer gives the course's PSC formula (sum of probability-sample design weights over the number of nonprobability units in subclass g) correctly as context 2, but it presents the nonresponse adjustment 1/phi_c as the 'usual meaning' of the question and leads with it, whereas the passage defines propensity score subclassification weights as the PSC formula; it also adds a few unsupported details (e.g., the final weight is the base weight divided by phi_c for respondents only, and that strata/clusters/FPC are not used in this step).
- **How is the test statistic for a Likelihood Ratio Test calculated when comparing two nested models?** (correct, 4 unsupported claims): The answer gives the course's statistic, -2 times the difference in log-likelihoods (reduced minus full), referred to a chi-square with df equal to the parameter difference, but it adds several claims no source supports: the survey-package advice, glm/lrtest ignoring the design, the same-cases nesting check, and the length(coef()) df code.
- **What is the formula for the relative variance of the estimated total of a proportion when using stratified simple random sampling?** (correct, 4 unsupported claims): The answer gives the correct formula, relvar(t_P) = t_P^-2 * sum_h N_h(N_h/n_h - 1)S_h^2 with S_h^2 = P_h(1-P_h)N_h/(N_h-1), matching the passage and S12, but it adds several unsourced claims about the design checks, such as the clustering and nonresponse caveats and the n_h >= 2 requirement.
- **How do I perform ridge regression and find the optimal lambda using cross-validation in R?** (correct, 4 unsupported claims): The answer matches the course passage: it builds X and y with model.matrix, runs cv.glmnet with alpha = 0, and picks lambda.min or lambda.1se, but it adds a few claims no source supports, such as the 10-fold default, the optimism of random folds with clustered data, and the point about ridge coefficients being biased.
