---
id: "jpsm/total_survey_error_II_SURV721/project/Assignment_1_Linares_proposal"
source: "jpsm"
course: "SURV721"
course_title: "Total Survey Error and Data Quality II"
doc_type: "assignment"
title: "Assignment_1_Linares_proposal"
original: "total_survey_error_II_SURV721/project/Assignment_1_Linares_proposal.pdf"
pages: 3
sha256: "9ab3783cc1e8f54a198cbcde07ee55333b805be6aaf8f60e378223896fb45449"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:24"
---

<!-- page 1 -->

**Proposal 1 (my top choice): Latent-to-Language (L2L) Imputation for Item Nonresponse**

Item nonresponse represents a persistent threat to the quality of survey data inferences, particularly under Missing Not at Random (MNAR) conditions. Multiple imputation by chained equations (MICE) is the standard method for imputing missingness assuming missing at random (MAR), producing biased estimates under MNAR. In this study, I propose to address item nonresponse bias by integrating Bayesian psychometric models with large language models (LLMs) to improve imputations under MNAR conditions. Specifically, I aim to answer how does integrating latent measurement model estimates (IRT and LCA) into LLM prompts affect imputation accuracy for wealth items under Missing Not at Random (MNAR) conditions?

This experiment will be a factorial design to test two LLMs (local Llama, and API Claude) versus MICE and machine learning benchmarks. Additionally, I will explore different types of LLM prompts to compare zero-shot, few-shot with observed assets, and psychometric-informed prompts that include Bayesian posterior estimates with credible intervals. Only LLMs will receive the psychometric estimates and few-shot examples from similar households. While prior work has used convenience samples to fine-tune LLMs for predicting survey nonresponse (Holtdirk et al., 2025), no systematic investigation has examined whether LLM-based imputation informed by psychometric models can outperform established methods under the realistic MNAR conditions that plague sensitive survey items. A key limitation is that our MNAR mechanism is experimentally controlled; real-world missingness patterns may be more complex.

**Proposal 2: Silicon Sampling for Unit Nonresponse Bias Reduction**

Unit nonresponse threatens survey representativeness when the correlation between response propensity and outcomes introduces bias (Groves, 2006), and traditional weighting adjustments assume auxiliary variables predict both propensity and outcomes (Little & Vartivarian, 2005). Building on Argyle et al. (2023), who demonstrated LLMs can simulate human survey responses, this study proposes using LLMs to generate synthetic respondents ("silicon samples") for low-propensity subgroups, directly estimating the nonrespondent mean rather than relying on auxiliary variables. Using LAPOP data, I leverage documented differential nonresponse among rural households in remote regions to simulate unit nonresponse, asking: how effectively can LLM-generated synthetic respondents represent low-propensity subgroups in terms of response distributions? This targeted approach may mitigate concerns raised by Bisbee et al. (2024) regarding systematic biases in LLM-generated data by constraining generation to empirically-defined population segments. A key limitation is the untestable assumption that synthetic responses reflect true nonrespondent behavior.

<!-- page 2 -->

**Data Source:**

Both proposals utilize the **2021 <u>LAPOP AmericasBarometer</u>** survey for Colombia. I have already gained full access to this dataset, which includes 2,022 raw observations. This sample includes eight binary wealth items (e.g., refrigerator, computer, internet), as well as critical geographic and urban/rural covariates.

**Table 1. LAPOP Colombia 2021 Data Summary**

| Characteristic | Value |
| :--- | :--- |
| Total Observations | 2,022 |
| Complete Cases (analysis sample) | 1,742 |
| Training Set | 60% ($n \approx 1,045$) |
| Validation Set | 20% ($n \approx 348$) |
| Test Set | 20% ($n \approx 349$) |
| Urban Households | ~70% |
| Rural Households | ~30% |
| Wealth Items | 8 binary indicators |
| Regions | 6 (including Pacific, Former Territories) |

*Note: Wealth items include refrigerator, landline phone, washing machine, microwave, computer, flat-screen TV, internet service, and cable/satellite TV.*

<!-- page 3 -->

**References**

Argyle, L. P., Busby, E. C., Fulda, N., Gubler, J. R., Rytting, C., & Wingate, D. (2023). Out of one, many: Using language models to simulate human samples. \*Political Analysis, 31\*(3), 337-351.

Bisbee, J., Clinton, J. D., Dorff, C., Kenkel, B., & Larson, J. M. (2024). Synthetic replacements for human survey data? The perils of large language models. \*Political Analysis, 32\*(1), 1-16.

Groves, R. M. (2006). Nonresponse rates and nonresponse bias in household surveys. \*Public Opinion Quarterly, 70\*(5), 646-675.

Holtdirk, T., Assenmacher, D., Bleier, A., & Wagner, C. (2025). Learning from Convenience Samples: A Case Study on Fine-Tuning LLMs for Survey Non-response in the German Longitudinal Election Study. *arXiv preprint arXiv:2509.25063*.

Little, R. J., & Vartivarian, S. L. (2005). Does weighting for nonresponse increase the variance of survey means? \*Survey Methodology, 31\*, 161-168.
