---
id: "jpsm/total_survey_error_II_SURV721/project/presentaitons/TSE_Proposal_Presentation_Linares"
source: "jpsm"
course: "SURV721"
course_title: "Total Survey Error and Data Quality II"
doc_type: "assignment"
title: "LLMs for Survey Nonresponse Bias"
original: "total_survey_error_II_SURV721/project/presentaitons/TSE_Proposal_Presentation_Linares.pdf"
pages: 3
sha256: "0262055ef9ec5fa69ceb9a86c22b9d21d009da4a914b0e83dd0500471f12f398"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:33"
---

<!-- page 1 -->

# LLMs for Survey Nonresponse Bias

Kevin Linares

Survey Methodology • University of Maryland

UNIVERSITY OF MARYLAND

FEARLESSLY FORWARD

TSE II Spring 2026

1

<!-- page 2 -->

# The MNAR Challenge: Bias in Colombia's Remote Regions

## **THEORY:** The Core Error (MNAR)

$$\text{Bias} \propto \text{Corr}(\text{Outcome}, \text{Response Propensity})$$

* **Total Population**
  * **Respondents**
  * **Nonrespondents**
  * **Outcome** (e.g., Wealth)

Traditional models fail when missingness is tied to the outcome.

## **CONTEXT:** Empirical Foundation (LAPOP Colombia)

**High Nonresponse Zones**

* $n = \mathbf{1,742}$ Households
* **8-Item** Wealth Index
* **30%** Rural Composition

Our "stress test": Can LLMs reconstruct profiles for these hard-to-reach populations?

<!-- page 3 -->

# Two-Pronged Framework for Addressing MNAR Bias

### Common Problem: MNAR Missingness
Induce Missingness (Region + Rural strata).

## Proposal 1: Latent-to-Language (L2L) Imputation

* **Latent Coaching** (Frequentist Estimates)
  * Latent Models
* **Imputation Engine** (Factorial Design)
  * Gemma3, Sonnet, Opus
  * LLM
* **Item-Level Evaluation**
  * Accuracy, Bias, MCC

Use psychometric estimates to “coach” LLMs for item-level imputation.

## Proposal 2: Silicon Sampling for Unit Nonresponse

* **Identify Low-Propensity Subgroups**
* **Constrained Generation** (“Silicon Samples”)
* **Distributional Evaluation**

Generate synthetic respondents to represent missing low-propensity subgroups.

### Goal: Restored Representativeness & Improved Inference
