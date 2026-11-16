---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/Overview_slides"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "Lecture 0. Course Overview"
original: "stat_mod_ML_2_SURV616/lectures/Overview slides.pdf"
pages: 13
sha256: "585450cadb1613a9604896c90bd1795521f92634e0ba9f1859081107734f148a"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:32"
---

<!-- page 1 -->

# Lecture 0. Course Overview

Suzer-Gurtekin

January 2025

<!-- page 2 -->

Overview

# Today

* Talk about the syllabus and course structure
* Assignment details
* Brief review of material from recorded first lecture
* Additional lecture with small-group problem solving

2/13 Suzer-Gurtekin Class 1

<!-- page 3 -->

Overview

# SM615/685 - SM616/686

- This is a two-semester sequence
- How does part one relate to part two?

3/13 Suzer-Gurtekin Class 1

<!-- page 4 -->

Overview

# SM615/685 - SM616/686

## SM615/685

* Linear Regression
* Assumptions

4/13 Suzer-Gurtekin Class 1

<!-- page 5 -->

Overview

# SM615/685 - SM616/686

## SM616/686
- Assumptions: What happens when these break?

5/13 Suzer-Gurtekin Class 1

<!-- page 6 -->

Overview

# SM615/685 - SM616/686

For example, a key assumption of linear regression is normality:

$e_i \sim N(0, \sigma^2)$

What happens when this doesn't work?

For example, when the dependent variable is binary?

6 / 13

Suzer-Gurtekin

Class 1

<!-- page 7 -->

Overview

# SM615/685 - SM616/686

Another assumption is:

$Cov(e_i, e_j) = 0$ for all $i \neq j$

This is often not true. For example, in an education study which surveys classes of students.

Or when we study a time series, where observations are correlated from one time to the next.

7/13 Suzer-Gurtekin Class 1

<!-- page 8 -->

Overview

# Prediction vs. Inference

**Inference**: describe the population, use model coefficients to explain the world.

**Prediction**: predict the value of *future* observations, model coefficients are not of direct interest, predicted values are.

8 / 13 Suzer-Gurtekin Class 1

<!-- page 9 -->

Overview

# Prediction vs. Inference

## Inference Example
* What factors influence the decision to participate in a survey?
* Logistic regression coefficients are interpreted.

## Prediction Example
* Given the observed characteristics of this person and the survey design, are they likely to participate in our survey?
* The prediction is a probability.

9 / 13

Suzer-Gurtekin

Class 1

<!-- page 10 -->

Overview

# Syllabus

* Class starts at 9:30am
* Canvas chat is always available
* Available by appointment as well. Please contact me !

10 / 13

Suzer-Gurtekin

Class 1

<!-- page 11 -->

Overview

# Tools

* Course materials are adapted from James Wagner's work
* Recorded Lectures Available on Canvas
  * Watch before class meeting!
* Class Meetings in Person
  * Meetings focus on questions, small-group problem solving

11 / 13

Suzer-Gurtekin

Class 1

<!-- page 12 -->

Overview

# Readings

- Faraway, *Extensions of the Linear Model in R*
- James et al. *An Introduction to Statistical Learning*
- "Class Notes" written by Steve Miller and Rick Valliant
- Other references as noted
- Find something that works for YOU

12 / 13

Suzer-Gurtekin

Class 1

<!-- page 13 -->

Overview

# Grading

- Homework 50%
  - R is the software we will use (If you plan to use another software, please let me know in advance)
  - Not more than week late
  - Submit via Canvas
- One Paper 20%
  - Paper 1: 4 pages
  - Paper *cannot* be late without prior permission (2 weeks prior to due date)
- Final Exam 20%
- Participation (Add notes/questions in the discussion) 10%

13 / 13 Suzer-Gurtekin Class 1
