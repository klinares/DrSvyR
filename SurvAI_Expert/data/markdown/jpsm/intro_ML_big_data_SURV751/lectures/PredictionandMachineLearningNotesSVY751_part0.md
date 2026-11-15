---
id: "jpsm/intro_ML_big_data_SURV751/lectures/PredictionandMachineLearningNotesSVY751_part0"
source: "jpsm"
course: "SURV751"
course_title: "Introduction to Machine Learning and Big Data"
doc_type: "lecture"
title: "An Intro to Big Data and Machine Learning for Survey Researchers and Social Scientists"
original: "intro_ML_big_data_SURV751/lectures/PredictionandMachineLearningNotesSVY751_part0.pdf"
pages: 29
sha256: "5cc6c2205d26953bcb0e236644ba6e9a5d04e4ded09d17645a0c39eaa5ef887f"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:05"
---

<!-- page 1 -->

# An Intro to Big Data and Machine Learning for Survey Researchers and Social Scientists

## Trent D. Buskirk, Ph.D. (Bowling Green State University)

## Frauke Kreuter, Ph.D. (University of Maryland)

## SVY 751, Notes Part 0

<!-- page 2 -->

# Course Objectives

* This course will offer participants:
  * an overview of key Big Data terminology and concepts
  * an introduction to common data generating processes
  * a discussion of some primary issues with linking Big Data with Survey Data
  * issues of coverage and measurement errors within the Big Data context
  * a discussion of information extraction and signal detection in the context of Big Data
  * a discussion of the similarities and differences in model building for inference versus prediction
  * an overview of general concepts from machine learning as they apply to processing Big Data
  * a discussion of signal detection and information extraction
  * a discussion of the potential pitfalls for inference from Big Data
  * an introduction to a small set of key analytic techniques (e.g. classification trees, random forests, conditional forests) to process Big Data using R with example code provided

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

<!-- page 3 -->

# Outline for the Course

* Overview of Big Data
  * What is Big Data?
  * Why does it matter?
  * What’s in this for Survey Researchers?
* Working with Big Data
  * Compilation
    * **Sources/Data Bases**
  * Computing Structures/Infrastructure
    * **Cloud Computing, Parallel Processing**
  * Cautions and Limitations
    * **Total Survey Error for Big Data**
    * **Sources of error (e.g. merging, compiling, measurement)**
    * **Analytic limitations – projectability…Does Big=Better?!**

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 4 -->

# Outline for the Course, Cont.

* Analyses of Big Data
  * Classical Statistical Approaches versus Statistical Machine Learning
  * Model Evaluation/Validation
  * Popular machine learning techniques
    * **Clustering**
      * K-means
      * Hierarchical
    * **K Nearest Neighbors**
    * **CARTS**
    * **Random Forests**

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 5 -->

# Overview of Big Data

What is Big Data?
Why does it matter?
What’s in this for Survey Researchers?

<!-- page 6 -->

# Until Recently: Three main sources

## Administrative Data

2

3 **Steuernummer**

4 eTIN lt. Lohnsteuerbescheinigung(en), sofern vorhanden | eTIN lt. weiterer Lohnsteuerbeschei

**Einkünfte aus nichtselbständiger Arbeit**

**Angaben zum Arbeitslohn** | Lohnsteuerbescheinigung(en) Steuerklasse 1 - 5

5 **Steuerklasse** 168 EUR Ct

6 Bruttoarbeitslohn 110 ,

7 Lohnsteuer 140

8 Solidaritätszuschlag 150

## Survey Data

## Experiments

V

L

S

---

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 7 -->

# Now

2005

Luca Bruno / AP

2013

NBC NEWS

Michael Sohn / AP

01000001010000010101000001

<!-- page 8 -->

# MIT Billion Prices Projects, PriceStats

*US Aggregated Inflation Series, Monthly Rate, PriceStats Index vs. Official CPI.*
*Accessed January 18, 2015 from the PriceStats website.*

“prices collected daily from hundreds of online retailers around the world to conduct economic research ”

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

<!-- page 9 -->

# Google Flue Trend http://dx.doi.org/10.1038/nature07634

Figure 2: A comparison of model estimates for the Mid-Atlantic Region (black) against CDC-reported ILI percentages (red), including points over which the model was fit and validated. A correlation of 0.85 was obtained over 128 points from this region to which the model was fit, while a correlation of 0.96 was obtained over 42 validation points. 95% prediction intervals are indicated.

Notes

<!-- page 10 -->

# Types of Big Data

There are many different types of Big Data sources:

* Social media data
* Personal data (e.g. data from tracking devices)
* Sensor data
* Transactional data
* Administrative data

They share features ...

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

<!-- page 11 -->

# Big Data - Features

| Volume | Velocity | Variety |
| :---: | :---: | :---: |
| **Data at Rest** | **Data in Motion** | **Data in Many Forms** |
| Terabytes to exabytes of existing data to process | Streaming data, milliseconds to seconds to respond | Structured, unstructured, text, multimedia |

http://www.rosebt.com/blog/data-veracity

0100000101000001010100000100111101010010 SVY751 Notes Big Data

<!-- page 12 -->

# Hope

Expensive data collections can be replaced

More (= better) data for decision making

Information available in (nearly) real time

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 13 -->

# But (at least) one more V

| Volume | Velocity | Variety | Veracity\* |
| :---: | :---: | :---: | :---: |
| **Data at Rest** | **Data in Motion** | **Data in Many Forms** | **Data in Doubt** |
| Terabytes to exabytes of existing data to process | Streaming data, milliseconds to seconds to respond | Structured, unstructured, text, multimedia | Uncertainty due to data inconsistency & incompleteness, ambiguities, latency, deception, model approximations |

http://www.rosebt.com/blog/data-veracity

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 14 -->

# Veracity

Who? What? Why?

Who is missing? Who is counted repeatedly?
What is not said / measured? ..and why?

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 15 -->

# Tensions

* Privacy vs. Public Good
* Convenience vs. Accusation

"Your recent Amazon purchases, Tweet score and location history makes you 23.5% welcome here."

<!-- page 16 -->

# Tensions

* Privacy vs. Public Good
* Convenience vs. Accusation
* Identifiable vs. Reachable
* “Tyranny of Minority”

Hey! What about my privacy??

They say that people who worry about their privacy have something to hide ...

Grea
sangrea.net

<!-- page 17 -->

# Tensions

* Privacy vs. Public Good
* Convenience vs. Accusation

* Identifiable vs. Reachable
* “Tyranny of Minority”

* Consent vs. Confusion
* Privacy vs. Data quality

* Europe vs. USA
* “Big Brother” vs. “Big Mother”

<!-- page 18 -->

# Good Discussion

**Privacy, Big Data, and the Public Good**
Frameworks for Engagement
Edited by Julia Lane, Victoria Stodden, Stefan Bender, Helen Nissenbaum

* What are the legal requirements?
* What are the rules of engagement?
* What are the best ways to provide access while also protecting confidentiality?
* Are there reasonable mechanisms to compensate citizens for privacy loss?
* How can we built trustworthy curators?
* What do we (need to) know about the data generating process?
* How can we increase linkage without increasing risks?

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 19 -->

# ‘Big Data’ – you already know

- Paradata (ideally)
  - real time, longitudinal, “everybody”
- Useful for survey researchers to monitor
  - inactive interviewer
  - coverage composition
- Allows action while it happens to save cost
- Even more opportunity in web surveys
  - mouse movements
  - response times
  - missing data

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 20 -->

# Working with Big Data

* Compilation: Sources/Data Bases
* Cautions and Limitations: Total Error for Big Data
    * Sources of error (e.g. merging, compiling, measurement)
    * Analytic limitations – projectability…Does Big=Better?! (Reach versus Relevance)
* Computing Structures/Infrastructure: Cloud Computing, Parallel Processing

<!-- page 21 -->

# Key Ingredients for Valid Inference

1. Data generating process needs to be known

2. Error framework already available for small data .. expand!

3. Data access and linkage is essential part

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

<!-- page 22 -->

# 1. Data Generating Process

What makes working with Big Data different is the found nature of the data

Organic vs. Design

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

<!-- page 23 -->

# 2. Error Framework for Surveys

### Measurement

* Construct $\mu_i$
  * Validity
* Measurement $Y_i$
  * Measurement Error
* Response $y_i$
  * Processing Error
* Response $y_{ip}$

### Representation

* Population Mean $\overline{Y}$
  * Coverage Error
* Sampling Frame $\overline{Y}_c$
  * Sampling Error
* Sample $\overline{Y}_s$
  * Nonresponse Error
* Respondents $\overline{Y}_r$
  * Adjustment Error
* Postsurvey Adjusted Data $\overline{Y}_{rw}$

**Survey Statistic**

---
0100000101000001010100000100111101010010 Small Course **Big Data**

<!-- page 24 -->

# 2. cnt’d Extended Error Model (Biemer 2014)

| **Generation** | **ETL** | **Analyze** |
| :---: | :---: | :---: |
| Source 1 | Extract | Filter/Reduction (Sampling) |
| Source 2 | $\downarrow$ | $\downarrow$ |
| $\bullet$<br>$\bullet$<br>$\bullet$ | Transform (Cleanse) | Computation/Analysis (Visualization) |
| Source K | $\downarrow$<br>Load (Store) | |

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 25 -->

# 3. Access and Linkage

Essential to understand data quality and break-downs

Challenged by ... different privacy requirements

- Open issues of ownership
- Lack of trusted third parties
- Ill-defined legal space
  consent: either comprehensive or comprehensible

However .... likely leads to good data documentation

+ Reproducible research
+ Transparency

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 26 -->

# Paradigm Shift

## Science Paradigms

* Thousand years ago:
  science was **empirical**
  *describing natural phenomena*
* Last few hundred years:
  **theoretical** branch
  *using models, generalizations*

$$\left(\frac{\dot{a}}{a}\right)^2 = \frac{4\pi Gp}{3} - K\frac{c^2}{a^2}$$

* Last few decades:
  a **computational** branch
  *simulating complex phenomena*
* Today: **data exploration** (eScience)
  *unify theory, experiment, and simulation*
  * Data captured by instruments
    or generated by simulator
  * Processed by software
  * Information/knowledge stored in computer
  * Scientist analyzes database/files
    using data management and statistics

*Hey et al. (2009).*

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 27 -->

# Skills

### DOMAIN EXPERT
User, analyst, or leaders with deep subject matter expertise related to the data, its appropriate use, and its limitations

### SYS ADMIN
Team member responsible for defining and maintaining a computation infrastructure that enalbes large scale computation

### RESEARCHER
Team member with experience applying formal research methods, including survey methodology and statistics

### COMPUTER SCIENTIST

---

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 28 -->

# Computing Environment

* Apache Hadoop. A system for maintaining a distributed file system that supports the storage of large-scale (Terabytes or Petabytes of content), and the parallel processing of algorithms against large data collections. Requires a programming language such as Java or Python.
* Apache Spark. A fast and general purpose engine for large-scale data processing that works in support of Hadoop or in-memory databases. Requires a programming language such as Java or Python.
* Java programming language. A general purpose systems engineering language that supports the creation of efficient algorithms for data analysis.
* Python programming language. A general purpose systems engineering language that supports rapid prototyping and efficient algorithms for data analysis.

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

<!-- page 29 -->

# Example: *Amazon Elastic MapReduce (EMR)*

AWS

Amazon CloudWatch

Metrics

The Amazon EMR job flow runs on a cluster of Amazon EC2 Instances

Input data

Output results

Amazon Simple Storage Service (S3)

Amazon EC2 Instance

Amazon EMR Job Flow

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**
