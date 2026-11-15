---
id: "jpsm/fund_comp_data_display_SURV727/lectures/01-01-Introduction"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "Fundamentals of Computing and Data Display"
original: "fund_comp_data_display_SURV727/lectures/01-01-Introduction.pdf"
pages: 13
sha256: "b11468ba6ef861024387612ed733b642ae38b8f74f4a1a582435a69840f7bae2"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:56"
---

<!-- page 1 -->

# Fundamentals of Computing and Data Display

Brian Kim

[email]

<!-- page 2 -->

Introduction Instructor

# Instructor

**Brian Kim**

- Associate Research Professor, JPSM, University of Maryland
- Director, Social Data Science Major, University of Maryland
- Director of Graduate Studies, JPSM

**Research Interests**

- Network sampling, particularly respondent-driven sampling
- Machine learning for social science research
- Data Science Education, particularly cloud-based tools

Fundamentals of Computing and Data Display Introduction 2 / 13

<!-- page 3 -->

Introduction SURV727

# Fundamentals of Computation and Data Display

* Intro to computing tools for gathering, handling and exploring diverse (web) data
  * “Exploratory Data Science” with R
  * General web data tools, SQL, Markdown, git, ...
* Course structure follows data science pipeline
  * Obtaining data
  * Storing and managing data
  * Exploring and finding patterns in (non-standard) data
  * Focus on data visualization

Course Objectives
* Gain computational skills to gather and process data from the web
* Learn to extract and display information from these data
* Organize reproducible coding projects

Fundamentals of Computing and Data Display Introduction 3 / 13

<!-- page 4 -->

Introduction SURV727

# Course format

Flipped classroom
* Every week, **recorded video lectures** will be posted to Canvas
* Please watch the videos and post in the discussion forum **before** the live meeting
* During class time, we will go over questions and do a short overview of the lecture material, with more time dedicated to live examples.

Fundamentals of Computing and Data Display Introduction 4 / 13

<!-- page 5 -->

Introduction SURV727

# Course content

Motivating Example: Prevalence, perception, and socio-geographic structure of criminal incidents in Chicago, IL

1. Gather data from (various) web sources
2. Set up database
3. Combine and re-structure data sets
4. Data wrangling, transforming variables
5. Data exploration, data display
6. Communicate, document results

Fundamentals of Computing and Data Display Introduction 5 / 13

<!-- page 6 -->

Introduction SURV727

# Course content

Motivating Example: Prevalence, perception, and socio-geographic structure of criminal incidents in Chicago, IL

1. Gather data from (various) web sources
   * $\rightarrow$ Web scraping, APIs
2. Set up database
   * $\rightarrow$ SQL
3. Combine and re-structure data sets
   * $\rightarrow$ `tidyr`
4. Data wrangling, transforming variables
   * $\rightarrow$ `plyr`, `dplyr`
5. Data exploration, data display
   * $\rightarrow$ Clustering, PCA, `ggplot2`, `shiny`
6. Communicate, document results
   * $\rightarrow$ `rmarkdown`, `Quarto`

Fundamentals of Computing and Data Display Introduction 6 / 13

<!-- page 7 -->

Introduction SURV727

# Course content

Motivating Example: Prevalence, perception, and socio-geographic structure of criminal incidents in Chicago, IL

1. Gather data from (various) web sources
   * $\rightarrow$ Web scraping, APIs
2. Set up database
   * $\rightarrow$ SQL
3. Combine and re-structure data sets
   * $\rightarrow$ `tidyr`
4. Data wrangling, transforming variables
   * $\rightarrow$ `plyr`, `dplyr`
5. Data exploration, data display
   * $\rightarrow$ Clustering, PCA, `ggplot2`, `shiny`
6. Communicate, document results
   * $\rightarrow$ `rmarkdown`

git, GitHub

Fundamentals of Computing and Data Display Introduction 7 / 13

<!-- page 8 -->

Introduction Course outline

# Course outline

| Unit | Content |
| :---: | :--- |
| 01 | Introduction to git and GitHub |
| 02 | Data structures in R |
| 03 | Communicate with R Markdown and Quarto |
| 04 | Data Wrangling, dplyr |
| 05 | Collecting social media data |
| 06 | Web Scraping |
| 07 | Text Mining |
| 08 | Midterm Exam |
| 09 | Databases, SQL |
| 10 | Data display with ggplot2 |
| 11 | Interactive plots |
| 12 | Data exploration, Clustering, PCA |
| 13 | Big data processing |
| 14 | Final presentations |

Fundamentals of Computing and Data Display Introduction 8 / 13

<!-- page 9 -->

Introduction Course outline

# Course outline

**Recommended Textbooks & Literature:**

Amaya, A., Bach, R., Keusch, F., and Kreuter, F. (2019). New Data Sources in Social Science Research: Things to Know Before Working With Reddit Data. *Social Science Computer Review*, online first. `https://doi.org/10.1177/0894439319893305`

Baumer, B. S., Kaplan, D. T., and Horton, N. J. (2017). *Modern Data Science with R*. Boca Raton, FL: Chapman & Hall/CRC Press.

Foster, I., Ghani, R., Jarmin, R. S., Kreuter, F., and Lane, J. (Eds.). (2017). *Big Data and Social Science: A Practical Guide to Methods and Tools*. Boca Raton, FL: CRC Press Taylor & Francis Group. `https://textbook.coleridgeinitiative.org/`

Silge, J., and Robinson, D. (2017). *Text Mining with R: A Tidy Approach*. O'Reilly. `https://www.tidytextmining.com/`

Stephens-Davidowitz, S., and Varian, H. (2015). *A Hands-on Guide to Google Data*. `http://people.ischool.berkeley.edu/~hal/Papers/2015/primer.pdf`

Wickham, H. and Grolemund, G. (2017). *R for Data Science*. O'Reilly. `https://r4ds.had.co.nz/`

Wickham, H. (2015). *Advanced R*. 1st edition. Boca Raton, FL: CRC Press Taylor & Francis Group. `http://adv-r.had.co.nz/`

Fundamentals of Computing and Data Display Introduction 9 / 13

<!-- page 10 -->

Introduction Course outline

# Course outline

**Additional Literature:**
These books cover some of the topics of this course in much more detail, but are highly recommended for those who want to learn more.

Luraschi, J, Kuo, K., and Ruiz, E. (2019). *Mastering Spark with R. The Complete Guide to Large-Scale Analysis and Modeling.* O'Reilly. `https://therinspark.com/`

Salganik, M. J. (2017). *Bit By Bit: Social Research in the Digital Age.* Princeton University Press. `https://www.bitbybitbook.com/en/1st-ed/preface/`

Fundamentals of Computing and Data Display Introduction 10 / 13

<!-- page 11 -->

# Credit points

**Forum Posts:**

* Every week, graded on completion.

**Online Midterm Exam:**

* Multiple choice questions
* Open book, open notes, not open classmates

**R assignments:**

* Some individual, some in small groups

**Data project:** Using web data to tackle a social science research problem

* Project proposal: Outline research question, data sources, data gathering
* Final presentation: Present preliminary results
* Term paper: Write-up of project
  * Includes short motivation, data (sources, gathering steps), results (e.g. graphs)
  * Extended **Rmarkdown document** with code of project (.rmd $>$ .pdf, 5-10 pages)
  * Includes link to **GitHub repository**

<!-- page 12 -->

# Credit points

## Grade Distribution

* Each assignment, presentation and paper (per team) will be given a grade between 0 and 20
* A missing submission will be scored as zero
* A submitted term paper is a precondition for passing the course
* Final Grade:
  * 10% Forum posts
  * 30% Assignments (averaged, without lowest score)
  * 20% Online Midterm Exam
  * 40% Web Data Project (5% final paper proposal, 10% final presentation, 25% term paper)

<!-- page 13 -->

Introduction Credit points

# Credit points

**Project examples from previous courses**

* *‘Nowcasting Gentrification’ with Publicly Accessible Data – Toward Simpler Predictions of Neighborhood Change Using Yelp*
* *Pre- and Post-Debate Democratic Primary Data: Twitter, Google Trends, and Polls*
* *An Analysis of Residential Home Values After the Flint Water Crisis*
* *Exploring Factors Affecting Non-response in Self-administered Surveys Using Google Trends*
* *Emotional Changes throughout the Corona-Crisis: A Sentiment Analysis of German Tweets*

Fundamentals of Computing and Data Display Introduction 13 / 13
