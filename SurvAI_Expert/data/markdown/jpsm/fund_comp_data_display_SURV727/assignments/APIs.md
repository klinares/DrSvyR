---
id: "jpsm/fund_comp_data_display_SURV727/assignments/APIs"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "assignment"
title: "Assignment 2"
original: "fund_comp_data_display_SURV727/assignments/APIs.qmd"
pages: 
sha256: "09c7e324f9dfcfd7b1e9d3ced332aff93333926eabbe7482d78522c86690f56e"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


You may work in pairs or individually for this assignment. Make sure you join a group in Canvas if you are working in pairs. Turn in this assignment as an HTML or PDF file to ELMS. Make sure to include the R Markdown or Quarto file that was used to generate it.

```r
library(tidyverse)
library(gtrendsR)
library(censusapi)
library(ggthemes)
library(knitr)
library(tidyverse)

# set a standard graphic theme for plots from the ggthemes package
theme_set(theme_hc())

options(scipen=999)

```

In this assignment, you will pull from APIs to get data from various data sources and use your data wrangling skills to use them all together. You should turn in a report in PDF or HTML format that addresses all of the questions in this assignment, and describes the data that you pulled and analyzed. You do not need to include full introduction and conclusion sections like a full report, but you should make sure to answer the questions in paragraph form, and include all relevant tables and graphics.

Whenever possible, use piping and `dplyr`. Avoid hard-coding any numbers within the report as much as possible.

## Pulling from APIs

Our first data source is the Google Trends API. Suppose we are interested in the search trends for `crime` and `loans` in Illinois in the year 2020. We could find this using the following code:

```r
res <- gtrends(c("crime", "loans"), 
               geo = "US-IL", 
               time = "2020-01-01 2020-12-31", 
               low_search_volume = TRUE)

plot(res)
```

Answer the following questions for the keywords "crime" and "loans".

-   Find the mean, median and variance of the search hits for the keywords.

    ```r
    res$interest_over_time |> 
      group_by(keyword) |> 
       # summary statistics 
      summarise(across(hits, list(mean, median, var))) |>  
      # rename outputs
      rename(mean_hits=2, median_hits=3, var_hits=4) 
      
    ```

-   Which cities (locations) have the highest search frequency for `loans`? Note that there might be multiple rows for each city if there were hits for both "crime" and "loans" in that city. It might be easier to answer this question if we had the search hits info for both search terms in two separate variables. That is, each row would represent a unique city.

    -   The following 6 cities below had the highest search frequency for ***loans*** during our query time period.

    ```r
    res$interest_by_city |> 
      filter(keyword == "loans") |> 
      arrange(desc(hits)) |> 
      select(location, keyword, hits) |> 
      head(6)  
    ```

-   Is there a relationship between the search intensities between the two keywords we used?

    -   Based on the timeseries plot above, it does not seem that crime and loans are tracking together across time, and therefore may not be associated. However, in April 2020 during the beginning of the pandemic, it appears that people in Illinois were searching more for loans, and searching less for crime.

Repeat the above for keywords related to covid. Make sure you use multiple keywords like we did above. Try several different combinations and think carefully about words that might make sense within this context.

```r


covid <- gtrends(c("covid", "coronavirus", "WHO", 
                   #"flu", "pandemic", "SARS", 
                   # "vaccine", "PPE
                   # "corona", "sanitizer", "covid-19".
                   "cases", "mask"), 
               geo = "US-IL", 
               time = "2020-01-01 2020-12-31", 
               low_search_volume = TRUE)

plot(covid)
```

## Google Trends + ACS

Now lets add another data set. The `censusapi` package provides a nice R interface for communicating with this API. However, before running queries we need an access key. This (easy) process can be completed here:

<https://api.census.gov/data/key_signup.html>

Once you have an access key, save it as a text file, then read this key in the `cs_key` object. We will use this object in all following API queries. Note that I called my text file `census-key.txt` – yours might be different!

```r
cs_key <- read_file(
  "~/UMD/classes/fund_comp_data_display_SURV727/assignments/census-key.txt")
```

In the following, we request basic socio-demographic information (population, median age, median household income, income per capita) for cities and villages in the state of Illinois. Documentation for the 5-year ACS API can be found here: <https://www.census.gov/data/developers/data-sets/acs-5year.html>. The information about the variables used here can be found here: <https://api.census.gov/data/2022/acs/acs5/variables.html>.

```r
acs_il <- getCensus(name = "acs/acs5",
                    vintage = 2020, 
                    vars = c("NAME", 
                             "B01001_001E", 
                             "B06002_001E", 
                             "B19013_001E", 
                             "B19301_001E"), 
                    region = "place:*", 
                    regionin = "state:17",
                    key = cs_key)
head(acs_il)
```

Convert values that represent missing to NAs.

```r
acs_il[acs_il == -666666666] <- NA
```

Now, it might be useful to rename the socio-demographic variables (`B01001_001E` etc.) in our data set and assign more meaningful names.

```r
acs_il <-
  acs_il %>%
  rename(pop = B01001_001E, 
         age = B06002_001E, 
         hh_income = B19013_001E, 
         income = B19301_001E) |> 
  as_tibble()
```

It seems like we could try to use this location information listed above to merge this data set with the Google Trends data. However, we first have to clean `NAME` so that it has the same structure as `location` in the search interest by city data. Add a new variable `location` to the ACS data that only includes city names.

```r
acs_il <- acs_il |> 
  mutate (location = str_extract(NAME, "[^,]+"),
        location = str_remove(location, "village|city|\\stown|CDP"),
        location = str_trim(location)) 

acs_covid <- 
  covid$interest_by_city |> as_tibble() |> 
  mutate(location = str_replace(location, "Saint\\s", "St. "), 
         location = str_replace(location, "Sainte\\s", "Ste. "),
         location = str_remove(location, "Fort ") ) |> 
  # join with ACS
  left_join(acs_il, relationship = "many-to-many")

glimpse(acs_covid)
  
```

Answer the following questions with the "crime" and "loans" Google trends data and the ACS data.

-   First, check how many cities don't appear in both data sets, i.e. cannot be matched. Then, create a new data set by joining the Google Trends and the ACS data. Keep only cities that appear in both data sets.
    -   There are 9

```r
asc_crime_loans <- res$interest_by_city |> as_tibble() |> 
  as_tibble() |> 
  mutate(location = str_replace(location, "Saint\\s", "St. "), 
         location = str_replace(location, "Sainte\\s", "Ste. "),
         location = str_remove(location, "Fort ") ) |> 
  # join with ACS
  left_join(acs_il, relationship = "many-to-many")

# unmatched cities
asc_crime_loans |> 
  filter(is.na(NAME)) |> 
  select(location) |> 
  kable()


```

-   Compute the mean of the search popularity for both keywords for cities that have an above average median household income and for those that have an below average median household income. When building your pipe, start with creating the grouping variable and then proceed with the remaining tasks. What conclusions might you draw from this?
    -   Cities with below average median household income tend to make more searches on crime and loans than cities with above average median household income.

```r
asc_crime_loans |> 
  mutate(hh_income_median = 
           ifelse(hh_income > mean(hh_income, na.rm=TRUE),
                  "Higher", "Lower")) |> 
  filter(!is.na(hh_income_median)) |> 
  group_by(hh_income_median, keyword) |> 
  reframe(mean_hits = mean(hits, na.rm=TRUE)) |> 
  pivot_wider(names_from = keyword, values_from = mean_hits)

```

-   Is there a relationship between the median household income and the search popularity of the Google trends terms? Describe the relationship and use a scatterplot with `qplot()`.
    -   At a glance, it does not appear that there is a linear relationship between median household income and search popularity. However, when we color code by search terms crime and loans, we begin to see that as median household income increases, the popularity in crime searches decreases, and to some extant same for the search term loans.

```r
asc_crime_loans |> 
  ggplot(aes(x=hh_income, y=hits, color=keyword)) +
  geom_point() 
```

Repeat the above steps using the covid data and the ACS data.

```r

acs_covid |> 
  filter(is.na(NAME)) |> 
  select(location) |> 
  kable()

acs_covid |> 
  mutate(hh_income_median = 
           ifelse(hh_income > mean(hh_income, na.rm=TRUE),
                  "Higher", "Lower")) |> 
  filter(!is.na(hh_income_median)) |> 
  group_by(hh_income_median, keyword) |> 
  reframe(mean_hits = mean(hits, na.rm=TRUE)) |> 
  pivot_wider(names_from = keyword, values_from = mean_hits)

acs_covid |> 
  ggplot(aes(x=hh_income, y=hits, color=keyword)) +
  geom_point() +
  facet_wrap(~keyword)
```
