---
id: "jpsm/Fund_data_collection_SURV622/record_linkage/report"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lab"
title: "SURV622 Record Linkage Project Report, Matching Administrative and Survey Data"
original: "Fund_data_collection_SURV622/record_linkage/report.qmd"
pages: 
sha256: "edb6dc3fbeda080067c76a9e11646c30061e7d0d326e37218bf5ebedb63daaf3"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:04"
---


## This report details the process and results of a record linkage project using the RecordLinkage package in R. The goal was to match records between an administrative dataset (admindata.csv) and a survey dataset (surveydata.csv) by testing various linking strategies and evaluating their effectiveness. All code used in this file is saved in report.qmd, when possible code is masked from this pdf to focus more on the workflow of this project. 



```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      cache.lazy = FALSE,
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(knitr, janitor, ggthemes, viridis, furrr, RecordLinkage, tidyverse)

file_path <- "~/repos/UMD_classes_code/fund_data_coll_2_SURV622/assignment_1/"

# read in data
surveydata <- read_csv(str_c(file_path, "surveydata.csv"))

admindata <- read_csv(str_c(file_path, "admindata.csv"))


```


## 1. Preprocessing and setting up our data for linkage.

We first confirm that Marital Status, Race, and City labels match across data sets. 

```r
# here we check if these variable levels are spelled the same way
variables_to_check <- c("Marital Status", "Race", "City")

map_dfr(variables_to_check, function(x){
  
  survey = surveydata |> 
    drop_na() |> 
    select(x) |> 
    distinct() |> 
    rename(survey=1) |> 
    arrange(survey)
  
  admin = admindata |> 
    select(x) |> 
    distinct() |> 
    rename(admin=1) |> 
    arrange(admin)
  
  dat = survey |> 
    add_column(admin) |> 
    mutate(same_spelling = survey == admin)
  
  return(dat) 
})  |> kable()

```

### Modifying Name Variables

A quick glance at the survey data did not reveal any lower case first or last names, and we leave names unmodified. However, we did notice some names had numerical values in the survey data. 

-   For instance the following record has a zero, but perhaps it was mistyped and should be an o.
```r
surveydata |> slice(1504) |> select(`First Name`, `Last Name`) |> kable()
```


We look more carefully at the names with numbers (58 records) and determine that there is a pattern in these names. 

- We correct each name with the following re-coding schema.  Although they are not a perfect match, changing numbers to character will help in the overall match later on. 
      
      - 0 = o
      - 4 = e
      - 5 = s
      - 6 = t
      - 7 = u
      - 8 = i
      - 9 = b

    
```r
# next we identify names with numbers, create a separate table for now
surveydata_numbers <- surveydata |> 
  # if a name has a number, flag it with a "1" in two new columns
  mutate(first_name_number = ifelse(str_detect(`First Name`, "[:digit:]"), 1, 0),
         last_name_number = ifelse(str_detect(`Last Name`, "[:digit:]"), 1, 0) ) 


replace_with <- c(
  "0" = "o",
  "4" = "e",
  "5" = "s",
  "6" = "t",
  "7" = "u",
  "8" = "i",
  "9" = "g")

# recode names with numbers to characters
surveydata_numbers <- surveydata_numbers |> 
  # for each name, replace a number with the character defined in "replace_with"
  mutate_at(vars("First Name", "Last Name"), str_replace_all, replace_with)


# we can now save our new table as surveydata, drop column no longer needed 
surveydata <- surveydata_numbers |> 
  select(-first_name_number, -last_name_number)

```


We confirm that names with numbers have been re-coded for all 58 records.
```r
surveydata |> slice(1504) |> select(`First Name`, `Last Name`) |> kable()
```



\newpage

### Modifying Numeric Variables


We want to now turn our attention to the numerical values and preprocess when necessary. We first confirm that Zip codes are all 5 numeric digits. Currently phone and credit card numbers are character strings because of the dashes, and we modify these variables in the following way: 

- Credit card numbers: Sometimes there is an extra number and other times there is no space in between sets of 4. To give our process the best chance of matching, we will split credit card numbers into 4 columns so if there is a partial match we are able to use all available information.

- Phone numbers can also be split into area code, first three, and last four. This will help in case there is a mis-typed number in one of these three sets.

- We can do the same for SSN and split into three parts.

- DOB, we will separate into year, month and day

- We convert income to an integer to drop decimal points.

- Finally, we convert all numerical values to numerical vectors from their current character status.
```r
surveydata <- surveydata |> 
  separate(`Telephone Number`, 
           c("area_code", "first_phone_num", "last_phone_num"), sep="-") |> 
  separate(`Credit Card Number`, 
           c("cc_1", "cc_2", "cc_3", "cc_4"), sep = " ") |> 
  separate(SSN, c("ssn_1", "ssn_2", "ssn_3"), sep = "-") |> 
  mutate(DOB = mdy(DOB) ,
         Income = as.integer(Income)) |> 
  separate(DOB, c("birth_year", "birth_month", "birth_day")) |> 
  # move city and zip-code to the last column places
  relocate(c(`ZIP Code`, City), .after = last_col()) |> 
  # convert to numeric values
  mutate_at(vars(birth_year:`ZIP Code`), as.double)

surveydata |> 
  drop_na() |> 
  select(birth_year:Income, `ZIP Code`) |> 
  head() |> 
  kable()

surveydata |> 
  drop_na() |> 
  select(cc_1:last_phone_num) |> 
  head() |> 
  kable()
```
\

As a sanity check we confirm that DOB is still within realistic bounds by examining the min and max values for each of these columns We first print the minimum and then print the maximum values.

```r
surveydata |> 
    select(starts_with("birth")) |> 
  drop_na() |> 
    mutate_all(as.double) |> 
    summarise_all(list(min)) |> 
  kable()


```

```r
surveydata |> 
    select(starts_with("birth")) |> 
  drop_na() |> 
    mutate_all(as.double) |> 
    summarise_all(list(max)) |> 
  kable()
```



```r

admindata <- admindata |> 
  separate(`Telephone Number`, 
           c("area_code", "first_phone_num", "last_phone_num"), sep="-") |> 
  separate(`Credit Card Number`, 
           c("cc_1", "cc_2", "cc_3", "cc_4"), sep = " ") |> 
  separate(SSN, c("ssn_1", "ssn_2", "ssn_3"), sep = "-") |> 
  mutate(DOB = mdy(DOB),
         Income = as.integer(Income)) |> 
  separate(DOB, c("birth_year", "birth_month", "birth_day")) |> 
  # move city and zip-code to the last column places
  relocate(c(`ZIP Code`, City), .after = last_col()) |> 
  # convert to numeric values
  mutate_at(vars(birth_year:`ZIP Code`), as.double)

```



Finally, we need to clean the variable names in both datasets as some have spacing in between, and we can use the janitor pacakge for this task.
```r
tibble(old_col_names = surveydata |> colnames(),
       new_col_names = surveydata |> clean_names() |> colnames()) |> 
  mutate(index_number = row_number()) |> 
  kable()

surveydata <- surveydata |> clean_names()
admindata <- admindata |> clean_names()

```



\newpage

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
classify_links <- emClassify(rpairs, threshold.upper = optimalThreshold(rpairs))
metric_result <- getErrorMeasures(classify_links) 
metric_result$precision # precision
metric_result$sensitivity # sensitivity

```



We note that precision is at around 17/%, meaning that of the 3,000 records, about 521 are correctly linked using a deterministic approach with core variables. Sensitivity is at .64. 


\newpage


## 3. Discussion, Systematic Variation of Linking Specifications

This section of the report describes a systematic exploration of different linking strategies, comparing their performance against a baseline deterministic approach. The key metrics used for evaluation are precision and sensitivity. The focus is on finding a balance between correctly identifying true links (high sensitivity) while minimizing incorrect links (high precision). Precision is prioritized due to the higher cost associated with false positives in this specific scenario.

The exploration involves testing various combinations of linking variables, incorporating blocking with city or zip code (which did not have missing values), and applying string comparison methods like Jaro-Winkler and Levenshtein distance.  The specific code used for this analysis is available in the accompanying report.qmd file.

The baseline deterministic linkage, using first name, last name, and race, yielded the lowest precision and sensitivity. Using only names with city or zip code blocking improved precision to approximately 0.60, but this was still considered insufficient.

Adding marital status and race to the name variables, regardless of the blocking variable or link method, resulted in a significant increase in precision but a substantial drop in sensitivity. Conversely, using only biographic variables (date of birth and SSN) produced the highest precision and sensitivity scores. Within this biographic variable approach, zip code blocking performed better than city blocking, while the choice of link method (Jaro-Winkler or Levenshtein) had minimal impact. A similar trend was observed when using only credit card and phone number for linking.

The proposed approach, based on these findings, is to not use first name, last name, or demographic variables. Instead, the recommended specification utilizes date of birth, SSN, credit card, and phone number as linking variables, combined with zip code blocking. The choice between Jaro-Winkler and Levenshtein distance appears to be inconsequential. Specifically, the combination of credit card and phone number linking variables, zip code blocking, and the Levenshtein distance method correctly linked 2997 out of 3000 records. The high success rate is likely attributed, in part, to the preprocessing steps performed on the data. These findings our consistent with our at random sampling or records for clerical review that we undertook to provide validity to these findigns.



```r

# create list with different combinations of variable extractions, to propose
## linking variables when not excluded.

variable_list <- list(
  name_city = c(1:2, 5:21),
  name_demo_city = c(1:2, 7:21),
  bio_city = c(1:6, 13:21),
  credit_phone_city = c(1:12, 21),
  # change blocking to zip code
  name_zip = c(1:2, 5:20, 22),
  name_demo_zip = c(1:2, 7:20, 22),
  bio_zip = c(1:6, 13:20, 22),
  credit_phone_zip = c(1:12, 22)
)

# create type of blocking to use
blocking_use <- rep( c("city", "zip_code"),  each=4)

```




```r

# create 8 links under the jaro method
jaro_list <- map(seq(1, length(variable_list)), function(x){

  RLBigDataLinkage(surveydata, admindata,
                          identity1=identity_survey, identity2 = identity_admin,
                          blockfld = c(blocking_use[x]), strcmp=T,
                          strcmpfun="jarowinkler",
                          exclude=variable_list[[x]])
})


plan(multisession, workers = length(jaro_list))

result_df_jaro <- future_map_dfr(seq(1, length(jaro_list)), function(x){

  # pass linkage object
  rpairs = emWeights(jaro_list[[x]], cutoff = 0.95)
  threshold = optimalThreshold(rpairs)
  classify_links = emClassify(rpairs, threshold.upper = threshold)
  metric_result = getErrorMeasures(classify_links)

  dat = tibble(precision = metric_result$precision,
               sensitivity = metric_result$sensitivity,
               number_matches = round(precision * nrow(surveydata)),
               linkage_variables = names(variable_list[x])
                )

    return(dat)
    }
)

```




```r

# create 8 links under the Leven method
leven_list <- map(seq(1, length(variable_list)),  function(x){

  RLBigDataLinkage(surveydata, admindata,
                          identity1=identity_survey, identity2 = identity_admin,
                          blockfld = c(blocking_use[x]), strcmp=T,
                          strcmpfun="levenshtein",
                          exclude=variable_list[[x]])
})

plan(multisession, workers = length(leven_list))

result_df_lev <- future_map_dfr(seq(1, length(leven_list)), function(x){

  # pass linkage object
  rpairs = emWeights(leven_list[[x]], cutoff = 0.95)
  threshold = optimalThreshold(rpairs)
  classify_links = emClassify(rpairs, threshold.upper = threshold)
  metric_result = getErrorMeasures(classify_links)

  dat = tibble(precision = metric_result$precision,
               sensitivity = metric_result$sensitivity,
               number_matches = round(precision * nrow(surveydata)),
               linkage_variables = names(variable_list[x])
                )

    return(dat)
    }
)

```


\newpage

```r
# combine baseline and results into one table
results_baseline = tibble(
  Specification = "Baseline",
  Link = "JaroWink",
  Linking_variables = "Names",
  Block = "None",
  Precision = metric_result$precision,
  Sensitivity =  metric_result$sensitivity,
  Links = round(Precision* 3000)
)

# create strings of variables used for link
linkage <- map_dfr(seq(1,length(variable_list)), function(x){

  surveydata|>
    select(!all_of(variable_list[[x]]))|>
    colnames() |>
    str_flatten(collapse ="_") |>
    tibble()

  }) |>
  rename(variables=1)

# join tables together with baseline

result_df <- results_baseline |>
  full_join(
  tibble(
  Specification = c(result_df_jaro$linkage_variables, result_df_lev$linkage_variables),
  Link = rep(c("JaroWink", "Leven"), each=8),
  Linking_variables = rep(linkage$variables, 2),
  Block = word(str_replace_all(Specification, "_", " "), -1),
  Precision = c(result_df_jaro$precision, result_df_lev$precision),
  Sensitivity = c(result_df_jaro$sensitivity, result_df_lev$sensitivity),
  Links = c(result_df_jaro$number_matches, result_df_lev$number_matches),
)  |>
  mutate(Specification = str_remove(Specification, "_city|_zip"),
    Linking_variables = str_remove(Linking_variables, "-city|_zip_code"))
) |> 
  mutate_at(vars(Precision, Sensitivity), round, 2)

result_df |> select(1, 2, 4:7) |> kable()
result_df |> select(3) |> kable()


```





```r
#| echo: FALSE
#| fig-width: 6
#| fig-height: 7


result_df |>
  filter(Specification != "Baseline") |> 
  select(Link, Specification , Block, Precision, Sensitivity) |>
  pivot_longer(-c("Link", "Specification", "Block"),
               values_to="Estimate", names_to="Metric") |>
  ggplot(aes(x=Block , y=Estimate, fill=Metric)) +
  geom_col( position = "dodge") +
  facet_grid(rows = vars(Specification ), cols = vars(Link)) +
  theme_hc() +
  guides(color=guide_legend(title="", reverse = TRUE)) +
  scale_fill_viridis_d(option="D", direction = 1,
                        alpha=.99, end =.90, begin=.35)

```



