---
id: "jpsm/total_survey_error_II_SURV721/project/Assignment_2_Linares_proposal"
source: "jpsm"
course: "SURV721"
course_title: "Total Survey Error and Data Quality II"
doc_type: "assignment"
title: "Assignment_2_Linares_proposal"
original: "total_survey_error_II_SURV721/project/Assignment_2_Linares_proposal.pdf"
pages: 3
sha256: "f231f51dc95a6aef86bea849fcd5e0e0ce6e6ba4832c734d0f979539532fe524"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:24"
---

<!-- page 1 -->

**Latent-to-Language (L2L) Framework: Adjusting for Item Nonresponse Using Psychometric Models and Large Language Models (LLMs)**

**Research Problem and Motivation**

Item nonresponse remains a persistent challenge in survey methodology, increasing variance in population estimates and potentially introducing bias when missingness mechanisms are not completely at random. In this study, I examine to what extent can psychometric model informed LLM prompting reduce variance of imputed survey estimates compared to traditional imputation methods under Missing at Random conditions? Traditional imputation methods like Multiple Imputation by Chained Equations (MICE) rely solely on observed covariates and may miss latent relationships that psychometric models are designed to capture.

I propose integrating three methodological approaches: First, missing data theory establishes that under Missing at Random (MAR) conditions, bias can be eliminated through proper conditioning on observed covariates (Little and Rubin, 2019). Second, psychometric measurement theory offers approaches for extracting latent information from observed items: Item Response Theory (IRT) captures continuous latent traits, while Latent Class Analysis (LCA) identifies discrete subpopulations with distinct response patterns. Third, emerging research on LLM-based survey inference (Holtdirk et al., 2025) demonstrates that these models can process complex contextual information to generate probabilistic predictions.

**Method**

I use survey data from the LAPOP Colombia 2021 AmericasBarometer ($N=2,993$), which provides a high-quality sampling environment for testing nonresponse frameworks. This dataset utilizes a stratified area probability design, providing the structural variables—specifically region and urban/rural status—necessary to induce and test Missing at Random (MAR) mechanisms within a realistic geographical hierarchy. Psychometric models will be fitted with household wealth items (i.e., 8 binary asset items: refrigerator, phone, washer, microwave, computer, TV, internet, cable) to predict 1) household food insecurity with a yes/no binary response, and separately 2) subjective economic trajectory with an ordinal response (e.g., better, same, worse). Imputing these two related constructs to relative wealth will allow us to examine under what conditions do LLMs outperform traditional imputation methods given differences in response levels.

For each respondent, the IRT model produces a theta estimate ($\theta$) expressed as a percentile rank (0–100%) and a standard error $\text{SE}(\theta)$. The LCA model produces class membership probabilities and conditional item response probabilities. Missing data will be induced in the outcome variables using the ampute function in R to create MAR missingness based on geographic stratification ($\text{region} \times \text{urban/rural}$) at rates of 5%, 15%, and 25%. Data will be split 70/30 for training and testing to examine the performance of each experimental design. The experimental designs will consist of several engineered

<!-- page 2 -->

prompt conditions (e.g., survey data only, IRT/LCA estimates, IRT/LCA + Chain to thought reasoning) which will be compared to MICE, logistic regression, Random Forest, XGBoost (see Figure 1 for a workflow diagram).

**Evaluation Framework**

Model performance will be assessed at three levels. Individual-level prediction accuracy will be measured through classification accuracy, Macro F1, AUC-ROC, and Brier scores. Aggregate-level survey estimation quality will be evaluated using survey-weighted estimates, measuring bias, standard error, and mean squared error (MSE) compared to known complete-data parameters.

This research makes three substantive contributions to survey methodology. First, it provides the first systematic evaluation of psychometric augmentation for LLM-based survey imputation. Second, it generates practical guidance on when psychometric models add value across different missingness rates, and outcome types. Third, it produces fully reproducible workflows documenting IRT/LCA model selection procedures, prompt engineering strategies with explicit handling of measurement uncertainty, and evaluation protocols for future methodological research.

### Latent-to-Language (L2L) Project Workflow: Core Processes

**1. INPUT DATA & PREP (LAPOP 2021)**
* **Data Source:** LAPOP 2021 ($N \approx 2,993$)
* Measurement Items (8 wealth, 6 legitimacy)
* Target Outcomes (Food Security, Trust)
* Demographics

**2. L2L AUGMENTATION & MISSINGNESS**
* **Psychometric Modeling (Items Only)**
  * IRT ($\theta$ percentile, SE) & LCA (Class Probs)
* **NO DATA LEAKAGE WALL**
* **Missingness Induction (MAR)**
  * Rates: 5%, 15%, 25%
* **Prompt Engineering**
  * Conditions: Observed, IRT, LCA, IRT+CoT, LCA+CoT

**3. PARALLEL MODELING (90 Runs)**
* **Traditional Baselines**
  * MICE, Logistic, RF, XGBoost
* **LLM Inference**
  * Gemma (Zero-shot & FT), Claude Sonnet

**4. TSE EVALUATION & TRADE-OFFS**
* **Metrics (Individual & Aggregate)**
  * Individual: F1, AUC, Brier
  * Aggregate: Bias, SE, MSE
* **Cost-Error Analysis**
  * Cost-Error Frontier (\$/Bias)
  * Computational Efficiency

**Optimal Method Selection for Survey Operations**

Figure 1: L2L Project Workflow

<!-- page 3 -->

### References

Holtdirk, F., Fetzer, M., & Hopp, F. (2025). Large language models for survey nonresponse: A new frontier in survey methodology. Journal of Survey Statistics and Methodology.

Little, R. J. A., & Rubin, D. B. (2019). Statistical analysis with missing data (3rd ed.). Wiley.
