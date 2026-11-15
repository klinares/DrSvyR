---
id: "jpsm/stat_mod_ML_1_SURV615/exams/R__California_Test_Score_Data"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "California Test Score Data"
original: "stat_mod_ML_1_SURV615/exams/R_ California Test Score Data.pdf"
pages: 2
sha256: "f1dadfbd6c3e97f55941f273aa098076049e33403ed465bb0e0588f5f0630120"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:14"
---

<!-- page 1 -->

CASchools R Documentation

# California Test Score Data

## Description

The dataset contains data on test performance, school characteristics and student demographic backgrounds for school districts in California.

## Usage

```r
data("CASchools")
```

## Format

A data frame containing 420 observations on 14 variables.

district

character. District code.

school

character. School name.

county

factor indicating county.

grades

factor indicating grade span of district.

students

Total enrollment.

teachers

Number of teachers.

calworks

Percent qualifying for CalWorks (income assistance).

<!-- page 2 -->

lunch

Percent qualifying for reduced-price lunch.

computer

Number of computers.

expenditure

Expenditure per student.

income

District average income (in USD 1,000).

english

Percent of English learners.

read

Average reading score.

math

Average math score.

### Details

The data used here are from all 420 K-6 and K-8 districts in California with data available for 1998 and 1999. Test scores are on the Stanford 9 standardized test administered to 5th grade students. School characteristics (averaged across the district) include enrollment, number of teachers (measured as “full-time equivalents”, number of computers per classroom, and expenditures per student. Demographic variables for the students are averaged across the district. The demographic variables include the percentage of students in the public assistance program CalWorks (formerly AFDC), the percentage of students that qualify for a reduced price lunch, and the percentage of students that are English learners (that is, students for whom English is a second language).

### Source

Online complements to Stock and Watson (2007).

### References

Stock, J. H. and Watson, M. W. (2007). *Introduction to Econometrics*, 2nd ed. Boston: Addison Wesley.

### See Also
