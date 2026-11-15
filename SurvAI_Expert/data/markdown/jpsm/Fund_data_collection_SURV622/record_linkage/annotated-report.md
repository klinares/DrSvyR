---
id: "jpsm/Fund_data_collection_SURV622/record_linkage/annotated-report"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lab"
title: "SURV622 Record Linkage Project Report, Matching Administrative and Survey Data"
original: "Fund_data_collection_SURV622/record_linkage/annotated-report.pdf"
pages: 8
sha256: "80cafa19308a3dac5be76e01d23a3947cc24b1bab72cfb65ecf2b51481a83076"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:04"
---

<!-- page 1 -->

# SURV622 Record Linkage Project Report, Matching Administrative and Survey Data

Kevin Linares

2025-02-21

**This report details the process and results of a record linkage project using the RecordLinkage package in R. The goal was to match records between an administrative dataset (admindata.csv) and a survey dataset (surveydata.csv) by testing various linking strategies and evaluating their effectiveness. All code used in this file is saved in report.qmd, when possible code is masked from this pdf to focus more on the workflow of this project.**

### 1. Preprocessing and setting up our data for linkage.

We first confirm that Marital Status, Race, and City labels match across data sets.

| survey | admin | same_spelling |
| :--- | :--- | :--- |
| Divorced | Divorced | TRUE |
| Married | Married | TRUE |
| Never Married | Never Married | TRUE |
| Widowed | Widowed | TRUE |
| American Indian-Alaska Native | American Indian-Alaska Native | TRUE |
| Asian | Asian | TRUE |
| Black | Black | TRUE |
| Hispanic | Hispanic | TRUE |
| Others | Others | TRUE |
| White | White | TRUE |
| Austin | Austin | TRUE |
| Chicago | Chicago | TRUE |
| Los Angeles | Los Angeles | TRUE |
| New York City | New York City | TRUE |
| Washington DC | Washington DC | TRUE |

1

<!-- page 2 -->

### Modifying Name Variables

A quick glance at the survey data did not reveal any lower case first or last names, and we leave names unmodified. However, we did notice some names had numerical values in the survey data.

* For instance the following record has a zero, but perhaps it was mistyped and should be an o.

```r
surveydata |> slice(1504) |> select(`First Name`, `Last Name`) |> kable()
```

| First Name | Last Name |
| :--- | :--- |
| Pace | Bish0p |

We look more carefully at the names with numbers (58 records) and determine that there is a pattern in these names.

* We correct each name with the following re-coding schema. Although they are not a perfect match, changing numbers to character will help in the overall match later on.

  - `0 = o`
  - `4 = e`
  - `5 = s`
  - `6 = t`
  - `7 = u`
  - `8 = i`
  - `9 = b`

We confirm that names with numbers have been re-coded for all 58 records.

```r
surveydata |> slice(1504) |> select(`First Name`, `Last Name`) |> kable()
```

| First Name | Last Name |
| :--- | :--- |
| Pace | Bishop |

2

<!-- page 3 -->

### Modifying Numeric Variables

We want to now turn our attention to the numerical values and preprocess when necessary. We first confirm that Zip codes are all 5 numeric digits. Currently phone and credit card numbers are character strings because of the dashes, and we modify these variables in the following way:

* Credit card numbers: Sometimes there is an extra number and other times there is no space in between sets of 4. To give our process the best chance of matching, we will split credit card numbers into 4 columns so if there is a partial match we are able to use all available information.
* Phone numbers can also be split into area code, first three, and last four. This will help in case there is a mis-typed number in one of these three sets.
* We can do the same for SSN and split into three parts.
* DOB, we will separate into year, month and day
* We convert income to an integer to drop decimal points.
* Finally, we convert all numerical values to numerical vectors from their current character status.

| birth\_year | birth\_month | birth\_day | ssn\_1 | ssn\_2 | ssn\_3 | Income | ZIP Code |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1954 | 6 | 24 | 176 | 3 | 9379 | 166134 | 20018 |
| 1957 | 2 | 21 | 305 | 22 | 947 | 49913 | 20005 |
| 1974 | 1 | 6 | 655 | 87 | 523 | 33234 | 20017 |
| 1952 | 11 | 6 | 124 | 68 | 9529 | 15420 | 20013 |
| 1948 | 5 | 27 | 566 | 33 | 9955 | 41779 | 20006 |
| 1994 | 6 | 6 | 661 | 44 | 7209 | 63022 | 20010 |

| cc\_1 | cc\_2 | cc\_3 | cc\_4 | area\_code | first\_phone\_num | last\_phone\_num |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 4029 | 4369 | 6201 | 727 | 313 | 519 | 3459 |
| 1116 | 6409 | 941 | 9097 | 360 | 672 | 5947 |
| 9772 | 9935 | 9524 | 1541 | 203 | 624 | 7611 |
| 2108 | 4575 | 5599 | 74 | 952 | 429 | 387 |
| 7512 | 2616 | 1227 | 2381 | 570 | 630 | 8003 |
| 5030 | 9746 | 7605 | 8299 | 540 | 291 | 6196 |

3

<!-- page 4 -->

As a sanity check we confirm that DOB is still within realistic bounds by examining the min and max values for each of these columns We first print the minimum and then print the maximum values.

| birth_year | birth_month | birth_day |
| ---: | ---: | ---: |
| 1947 | 1 | 1 |

| birth_year | birth_month | birth_day |
| ---: | ---: | ---: |
| 1997 | 12 | 30 |

Finally, we need to clean the variable names in both datasets as some have spacing in between, and we can use the janitor pacakge for this task.

| old_col_names | new_col_names | index_number |
| :--- | :--- | ---: |
| ID | id | 1 |
| DUP | dup | 2 |
| First Name | first_name | 3 |
| Last Name | last_name | 4 |
| Marital Status | marital_status | 5 |
| Race | race | 6 |
| birth_year | birth_year | 7 |
| birth_month | birth_month | 8 |
| birth_day | birth_day | 9 |
| ssn_1 | ssn_1 | 10 |
| ssn_2 | ssn_2 | 11 |
| ssn_3 | ssn_3 | 12 |
| Income | income | 13 |
| cc_1 | cc_1 | 14 |
| cc_2 | cc_2 | 15 |
| cc_3 | cc_3 | 16 |
| cc_4 | cc_4 | 17 |
| area_code | area_code | 18 |
| first_phone_num | first_phone_num | 19 |
| last_phone_num | last_phone_num | 20 |
| ZIP Code | zip_code | 21 |
| City | city | 22 |

4

<!-- page 5 -->

## 2 Deterministic Linking (Baseline):

A baseline deterministic linking approach was implemented using compare.link() for core linking variables: first name, last name, and race with no blocking variable. We depend on optimizing the threshold using the optimalThreshold() since we will later compare several linking approaches and must do so programmatically. Finally we use the emClassify() to classify all pairs as either links or non-links. This initial approach served as a benchmark for subsequent experiments. The precision and sensitivity were calculated using the common record identifier, and we use these two performance metrics to optimize our linking method.

We start by creating identity vectors

```r
identity_survey <- surveydata |> pull(id)
identity_admin <- admindata |> pull(id)
```

```r
deter_link <- compare.linkage(
  surveydata, admindata,
  identity1=identity_survey, identity2 = identity_admin,
  # jarowink is the default
  exclude = c(1:2, 5, 7:21))

rpairs <- emWeights(deter_link, cutoff = 0.95)
```

```r
classify_links <- emClassify(rpairs, threshold.upper = optimalThreshold(rpairs))
metric_result <- getErrorMeasures(classify_links)
metric_result$precision # precision
```

```
[1] 0.1738264
```

```r
metric_result$sensitivity # sensitivity
```

```
[1] 0.6418844
```

We note that precision is at around 17/%, meaning that of the 3,000 records, about 521 are correctly linked using a deterministic approach with core variables. Sensitivity is at .64.

5

<!-- page 6 -->

### 3. Discussion, Systematic Variation of Linking Specifications

This section of the report describes a systematic exploration of different linking strategies, comparing their performance against a baseline deterministic approach. The key metrics used for evaluation are precision and sensitivity. The focus is on finding a balance between correctly identifying true links (high sensitivity) while minimizing incorrect links (high precision). Precision is prioritized due to the higher cost associated with false positives in this specific scenario.

The exploration involves testing various combinations of linking variables, incorporating blocking with city or zip code (which did not have missing values), and applying string comparison methods like Jaro-Winkler and Levenshtein distance. The specific code used for this analysis is available in the accompanying report.qmd file.

The baseline deterministic linkage, using first name, last name, and race, yielded the lowest precision and sensitivity. Using only names with city or zip code blocking improved precision to approximately 0.60, but this was still considered insufficient.

Adding marital status and race to the name variables, regardless of the blocking variable or link method, resulted in a significant increase in precision but a substantial drop in sensitivity. Conversely, using only biographic variables (date of birth and SSN) produced the highest precision and sensitivity scores. Within this biographic variable approach, zip code blocking performed better than city blocking, while the choice of link method (Jaro-Winkler or Levenshtein) had minimal impact. A similar trend was observed when using only credit card and phone number for linking.

The proposed approach, based on these findings, is to not use first name, last name, or demographic variables. Instead, the recommended specification utilizes date of birth, SSN, credit card, and phone number as linking variables, combined with zip code blocking. The choice between Jaro-Winkler and Levenshtein distance appears to be inconsequential. Specifically, the combination of credit card and phone number linking variables, zip code blocking, and the Levenshtein distance method correctly linked 2997 out of 3000 records. The high success rate is likely attributed, in part, to the preprocessing steps performed on the data. These findings our consistent with our at random sampling or records for clerical review that we undertook to provide validity to these findigns.

6

<!-- page 7 -->

| Specification | Link | Block | Precision | Sensitivity | Links |
| :--- | :--- | :--- | ---: | ---: | ---: |
| Baseline | JaroWink | None | 0.17 | 0.64 | 521 |
| name | JaroWink | city | 0.92 | 0.78 | 2769 |
| name\_demo | JaroWink | city | 0.92 | 0.78 | 2769 |
| bio | JaroWink | city | 1.00 | 0.85 | 2990 |
| credit\_phone | JaroWink | city | 1.00 | 1.00 | 2990 |
| name | JaroWink | zip | 0.59 | 0.89 | 1761 |
| name\_demo | JaroWink | zip | 0.99 | 0.78 | 2976 |
| bio | JaroWink | zip | 0.98 | 1.00 | 2932 |
| credit\_phone | JaroWink | zip | 1.00 | 1.00 | 2998 |
| name | Leven | city | 0.93 | 0.70 | 2796 |
| name\_demo | Leven | city | 0.95 | 0.68 | 2850 |
| bio | Leven | city | 1.00 | 0.85 | 2996 |
| credit\_phone | Leven | city | 1.00 | 1.00 | 2997 |
| name | Leven | zip | 0.59 | 0.82 | 1782 |
| name\_demo | Leven | zip | 0.99 | 0.70 | 2975 |
| bio | Leven | zip | 0.98 | 1.00 | 2944 |
| credit\_phone | Leven | zip | 1.00 | 1.00 | 2997 |

| Linking\_variables |
| :--- |
| Names |
| first\_name\_last\_name\_city |
| first\_name\_last\_name\_marital\_status\_race\_city |
| birth\_year\_birth\_month\_birth\_day\_ssn\_1\_ssn\_2\_ssn\_3\_city |
| income\_cc\_1\_cc\_2\_cc\_3\_cc\_4\_area\_code\_first\_phone\_num\_last\_phone\_num\_city |
| first\_name\_last\_name |
| first\_name\_last\_name\_marital\_status\_race |
| birth\_year\_birth\_month\_birth\_day\_ssn\_1\_ssn\_2\_ssn\_3 |
| income\_cc\_1\_cc\_2\_cc\_3\_cc\_4\_area\_code\_first\_phone\_num\_last\_phone\_num |
| first\_name\_last\_name\_city |
| first\_name\_last\_name\_marital\_status\_race\_city |
| birth\_year\_birth\_month\_birth\_day\_ssn\_1\_ssn\_2\_ssn\_3\_city |
| income\_cc\_1\_cc\_2\_cc\_3\_cc\_4\_area\_code\_first\_phone\_num\_last\_phone\_num\_city |
| first\_name\_last\_name |
| first\_name\_last\_name\_marital\_status\_race |
| birth\_year\_birth\_month\_birth\_day\_ssn\_1\_ssn\_2\_ssn\_3 |
| income\_cc\_1\_cc\_2\_cc\_3\_cc\_4\_area\_code\_first\_phone\_num\_last\_phone\_num |

7

<!-- page 8 -->

8

*[Figure: This faceted bar chart displays "Estimate" values (from 0.00 to 1.00 on the y-axis) across "Block" types ("city" and "zip" on the x-axis), comparing two metrics ("Precision" in blue and "Sensitivity" in green) arranged in columns for "JaroWink" and "Leven" and rows for "bio", "credit_phone", "name", and "name_demo". Overall, both precision and sensitivity remain near 1.00 for the "bio" and "credit_phone" categories, whereas the "name" and "name_demo" rows exhibit more variability and lower estimates, especially a notable drop in precision for the "zip" block under "name".]*
