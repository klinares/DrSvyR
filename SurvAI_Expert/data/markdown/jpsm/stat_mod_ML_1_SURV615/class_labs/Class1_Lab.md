---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class1_Lab"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 1 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class1_Lab.Rmd"
pages: 
sha256: "4671fae7fe0cec1a2b4d86193c6ae26d0bd158eb404a52d7342ff209f3c35995"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---



```r
knitr::opts_chunk$set(echo = TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE)

library(readxl)


```



## I. Made-up income data 1
```r
income1<-data.frame("id"=c(1:20),
                          "income_usd"=rnorm(20, mean = 10000, 
                                             sd = 10000/3), 
                          "educ_yr"=rep(12,20))
head(income1)
summary(income1)
```
1. How do income and education look? Looks like income ranges from 4678 to 144114 with a mean of 10386. Education has no variation.
2. Can you study the relationship between income and education? Why or why not? No, education does not vary at all.


## II. Made-up income data 2
```r
income2 <- data.frame("id"=c(101:120),
                          "income_usd"=rep(10000, 20), 
                          "educ_yr"=sample(0:16,20,replace=T) )
head(income2)
summary(income2)
```
1. How do income and education look? Income does not vary, education varies from 0 to 16 with a mean of 8.15
2. Can you study the relationship between income and education? Why or why not? No, income does not vary and all values are set at 10000.


## III. Wage data in R package ISLR2
```r
library(ISLR2)

```


```r
data("Wage")
# run ?Wage in your console to see data description in help
# Can also see p.13 of R manual_ISLR.pdf for data description
dim(Wage)
names(Wage)
head(Wage)
summary(Wage)
```
1. What do you observe? Yearly data for health status by jobclass,lowage, wage, region, and demographic variables such as race, education, age, and marital status.
  + What is the variable type for each variable? int, int, fct, fct, fct, fct, fct, fct, dbl, dbl.
2. What stories would you like to study using this data? The incremental change in health status across regional, occupational, and demographic varaibles.
3. How would you express those stories with formulas? health ~ age + marital + race + education + region + jobclass + year


## IV. psid data in R package faraway
```r
library(faraway)

```

```r
data("psid")
# Run ?psid in console to see data description in help
# Can also see p.78 of R manual_faraway.pdf for data description
head(psid)
summary(psid)
```
1. What do you observe? Respondent level data, repeated measures for yearly income as well as the individual's  age education and sex. 
+ What is the variable type for each variable? int, int, fct, int, int, int
2. What stories would you like to study using this data? How an individual's income bracket changes over time as a function of education.
3. How would you express those stories with formulas? Income ~ sex + educ + age +(year | person)


## V. Fictitious data 
```r
fic_dat7 <- read_excel(
  # "~/Dropbox (University of Michigan)/MPSDS 685/data/Fictitious Data.xlsx",
  "~/UMD/classes/survmeth_615/class_1/Fictitious Data.xlsx",
  sheet=7)
head(fic_dat7)

```
- The filepath that has been commented out (line 92) will also work to import the data (assuming that's where the file is located). Why might we prefer to use one way of writing the filepath over the other?


1. Compute the average of Distress_2019 and Distress_2021
```r
mean(fic_dat7$Distress_2019)
mean(fic_dat7$Distress_2021)
```
- Can you say that there is a difference in Distress between 2019 and 2022? Why or why not? There is a difference of .95 points, but we do not know if this is a statistical difference yet. 

2. Compute the average of Distress_2019 and Distress_2021 by Sex
```r
cbind(aggregate(Distress_2019~Sex,fic_dat7,FUN=mean),
      aggregate(Distress_2021~Sex,fic_dat7,FUN=mean))

library(tidyverse)
fic_dat7 |> group_by(Sex) |> reframe(mean(Distress_2019), mean(Distress_2021))
```
- Can you say that there is a difference in Distress between Male and Female in 2019? How about in 2022? Why or why not? There is a difference in distress by Sex, yet we cannot determine statistical significance yet. 


