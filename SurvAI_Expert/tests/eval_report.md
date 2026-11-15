# SurvAI_Expert evaluation, 2026-11-15

Profile **home**, model `claude-sonnet-5-5`. Store receipt: identical to data/catalog/receipt.csv.

Gold: 108 questions; 3 unmapped (R scripts not in the store) and 2 that are not questions were dropped, leaving 103. 100 were planned and 39 answered (stratified by type).

## Retrieval: raw question vs planned search

Hit@k: the gold document is among the first k passages. Raw = the question text alone (part 1); planned = the model's plan, fused, at most 3 passages per document.

| type | n | raw_hit5 | raw_hit10 | planned_hit5 | planned_hit10 |
| --- | --- | --- | --- | --- | --- |
| all | 100 | 0.810 | 0.920 | 0.820 | 0.880 |
| code | 26 | 0.885 | 0.962 | 0.962 | 0.962 |
| concept | 40 | 0.850 | 0.950 | 0.825 | 0.900 |
| equation | 34 | 0.706 | 0.853 | 0.706 | 0.794 |

Equation questions: a formula from the gold document (or its formula group) was among those found for 20 of 34.

## Answer checks (no model)

| type | n | citations_valid | formula_tokens_valid | no_display_math | with_code | code_parses | unverified_functions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| all | 39 | 1 | 0.897 | 1 | 28 | 1 | 1 |
| code | 12 | 1 | 0.667 | 1 | 12 | 1 | 0 |
| concept | 14 | 1 | 1.000 | 1 | 6 | 1 | 1 |
| equation | 13 | 1 | 1.000 | 1 | 10 | 1 | 0 |

## Judge (the same model)

| type | n | correct | partly | incorrect | unsupported_claims | wrongly_said_missing |
| --- | --- | --- | --- | --- | --- | --- |
| all | 39 | 38 | 1 | 0 | 90 | 1 |
| code | 12 | 12 | 0 | 0 | 36 | 1 |
| concept | 14 | 14 | 0 | 0 | 25 | 0 |
| equation | 13 | 12 | 1 | 0 | 29 | 0 |

## Cost and time

178 model calls, about $2.09 (from token counts at the profile's prices).

| step | median_seconds |
| --- | --- |
| plan | 2.441 |
| search | 0.149 |
| answer | 8.514 |

## Five worst answers

- **How is the variance of the population mean calculated in a stratified sampling design?** (partly correct, 2 unsupported claims): The core formula (sum of W_h^2 (1-f_h) s_h^2/n_h with independent strata) is correct and supported, but the answer's note that W_h must come from true population counts N_h 'only under proportionate allocation, where the two coincide' is a muddled and wrong claim, and the statement that proportionate allocation's design effect is below 1 is stated loosely (it is at most 1), so some content is unsupported or flawed.
- **Under what conditions is raking an effective method for weighting?** (correct, 4 unsupported claims): The answer correctly identifies the core conditions (only margins known, no important interaction, margins capture the key structure, convergence without extreme weights), matching the passage and sources, but it adds some unsupported claims such as the truncation trade-off, reliable control totals carrying errors into the weights, the R code arguments, and the 'targets adjustment error' framing.
- **How can I retrieve socio-demographic data for census tracts in Illinois from the ACS 5-Year dataset using R?** (correct, 4 unsupported claims): The answer matches the course passage's getCensus call (acs/acs5, region tract:*, regionin state:17, key) and adds supported extras such as the missing-value recode, tidycensus, and metadata helpers, but it also makes several unsupported claims, such as variable code meanings, that no source states.
- **How do I fit a linear mixed-effects model that includes a random slope for the minority predictor for each school?** (correct, 4 unsupported claims): The answer gives the course's lmer call with (minority | schoolid), the random-slope model equation, the D matrix and the 0.5*chi2(1)+0.5*chi2(2) LRT, all matching the passage, but it adds several unsourced claims (singular-fit advice, lmer ignoring survey weights, few-minority-student identifiability, and the jtools assumption it flags itself).
- **How can I check if a variable follows a normal distribution using both graphical and statistical methods in R?** (correct, 4 unsupported claims): The answer correctly recommends a histogram/density plot and Q-Q plot plus shapiro.test, with working R code, consistent with the lab passage; it adds a few claims not in the sources (Shapiro-Wilk's 3-5000 limit, large samples flagging trivial departures, the null/non-rejection caveat, and the design-based caveats) and does not wrongly claim the sources lack material."}
