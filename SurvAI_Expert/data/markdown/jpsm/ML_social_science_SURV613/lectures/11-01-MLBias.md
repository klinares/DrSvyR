---
id: "jpsm/ML_social_science_SURV613/lectures/11-01-MLBias"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Bias and Fairness in ML"
original: "ML_social_science_SURV613/lectures/11-01-MLBias.pdf"
pages: 5
sha256: "6059db54f906c8e097858c8cd2a453920e854054257f41c43accda83a1b36452"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:12"
---

<!-- page 1 -->

# Bias and Fairness in ML

## Bias in ML

<!-- page 2 -->

# Fair ML

Fairness and algorithmic decision making

* ML models are increasingly used in high-stakes decisions
  * Loan applications, hiring, court decisions, predictive policing
* ML systems increase effectiveness and consistency?
* Various forms of (data) biases can be fed into the system
  * Models trained on biased data learn to reproduce biases

*"In the context of decision-making, fairness is the absence of any prejudice or favoritism toward an individual or a group based on their inherent or acquired characteristics."* (Mehrabi et al. 2019)

$\rightarrow$ Protected attributes in US context: sex, race, age, marital status, ...

<!-- page 3 -->

# Bias in Data

Figure: Predictive policing example (Lum and Isaac 2016)

(a) Drug arrests (training data)

(b) Drug crimes

*[Figure: The figure consists of two side-by-side geographical heatmaps of Oakland, California, comparing the spatial distribution of (a) recorded drug arrests used as training data (scaled from 0 to 200 arrests) against (b) estimated actual drug crimes (scaled from 100 to 500 users). The main pattern shows that while estimated drug crimes are widely distributed across much of the city in map (b), recorded drug arrests in map (a) are heavily concentrated in a few specific neighborhoods (marked 1 and 2), illustrating spatial bias in the policing data.]*

<!-- page 4 -->

# Bias in Data

Figure: Predictive policing example (Lum and Isaac 2016)

(a) Areas targeted by PredPol

(b) Targeted policing and drug use by race

*[Figure: The figure consists of two parts: a map of Oakland (a) highlighting areas targeted by PredPol in red according to the number of days targeted, and two bar charts (b) comparing "white", "black", and "other" racial groups on the horizontal axis against the "Percent of population (%)" on the vertical axis. The main pattern shows that predictive policing concentrates heavily in specific neighborhoods and disproportionately targets Black and other non-white populations (top bar chart) compared to White populations, even though actual drug use rates (bottom bar chart) are roughly equal at around 15% across all three groups.]*

<!-- page 5 -->

# Bias in Data

Types of data biases (Mehrabi et al. 2019)

* Historical (Label) Bias
    * *"Historical bias is a normative concern with the world as it is; it is a fundamental, structural issue with the first step of the data generation process and can exist even given perfect sampling and feature selection"*
* Representation (Sample) Bias
    * Representation bias arises when defining and sampling from a population
* Measurement Bias
    * Measurement bias arises when choosing and measuring the particular features of interest
* Many more...
