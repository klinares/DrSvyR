---
id: "jpsm/Data_visualization_SURV752/assignments/Linares_k_hw1"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "assignment"
title: "Homework 1: Datasaurus"
original: "Data_visualization_SURV752/assignments/Linares_k_hw1.qmd"
pages: 
sha256: "2280598aff7f1be7f8f2845216b9ca5fd770baa2fc60f0c75ab35aa01c9f63db"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:51"
---


## Introduction

Here we document the lab exercise instructions to analyze the "[Datasaurus Dozen](https://jumpingrivers.github.io/datasauRus/)" dataset. We will select four distinct datasets from the collection and analyze them.

```r
#| message: false
#| warning: false

pacman::p_load(ggthemes, gt, corrr, jtools, tidyverse)
options(scipen=999)
```

### 

First, we load the `datasaurus-1.csv` data. The original file contains 13 datasets, identified by the `dataset` column. Alternatively we could use the package `datasauRus::datasaurus_dozen` to load the data.

-   We load the dataset.

```r
#| message: false
#| warning: false
#| 
repo_path <- "d:/repos/UMD_classes_code/Data_visualization_SURV752/"

# Read the data from the provided CSV file.
datasaurus_raw <- read_delim(str_c(
  repo_path, "assignments/datasaurus-1.csv") )
```

\

1.  Choose 4 datasets to work with.

-   We choose at random four datasets to work from.

```r
# select four at random without replacement
dataset_numbers <- datasaurus_raw |> 
  distinct(dataset) |> 
  arrange(dataset) |> 
  pull()

set.seed(909)
random_datasets <- sample(dataset_numbers, 4)

# subset data
datasaurus_raw <- datasaurus_raw |> 
  mutate(dataset = factor(dataset)) |> 
  filter(dataset %in% random_datasets)
```

\

2.  Explore those 4 datasets using only descriptive statistics (DO NOT PLOT THEM YET!). Summarize your findings.

-   We start by taking a glimpse at the dataset.
    -   We can see that we have 568 rows and 3 variables (dataset, x, and y)

```r
datasaurus_raw |> glimpse()
```

-   We compute 6 summary statistics, across all four datasets for the x and y variables.
    -   minimum value
    -   25% quantile
    -   mean
    -   standard deviation
    -   75% quantile
    -   max value
-   We note that the average for x ranges around 54 and for y around 47 regardless of dataset, however, the variation is much wider for y than x based on the standard deviation. There are no missing data nor negative values.

```r
datasaurus_raw |> 
  group_by(dataset) |> 
      summarise(across(everything(), list(min = min, 
                                          Q1 = ~quantile(., .25),
                                          Ave = mean,
                                          SD = sd,
                                          Q3 = ~quantile(., .75),
                                          max = max))) |> 
  pivot_longer(-dataset) |> 
  separate(name, into = c("Variable", "Statistic")) |> 
  pivot_wider(names_from = Statistic, values_from = value) |> 
  gt()
```

3.  Correlate the x and y variables and run simple regressions for each dataset. Summarize your findings.

-   We calculate correlations between x and y for each of the datasets using `corrr::correlate()` which uses a pearson method.
    -   The correlations are negative with a small association of around -.07 for all four datasets, suggesting that x and y does not have a linear relationship.

```r
#| message: false
#| 
datasaurus_raw |> 
  group_split(dataset) |> 
  map_dfr(function(x){
    dataset_num = x |> distinct(dataset) |> pull()
    cor_dat = x |> select(x, y)
    cor_estimate = correlate(cor_dat)[2,2] |> pull()
    
    tibble(dataset =dataset_num, Correlation = cor_estimate)
  }) |> gt()
```

-   Next we fit a simple linear regression model for each dataset $y \sim x$. We note that the intercept for y is close to the means we calculated in question 2. The coefficient for $\beta_1 \times x$ was not statistically significant, suggesting again a poor linear relationship with y regardless of dataset.

```r

dataset_4_mod <- lm(y~x, data = datasaurus_raw |> filter(dataset==4))
dataset_7_mod <- lm(y~x, data = datasaurus_raw |> filter(dataset==7))
dataset_9_mod <- lm(y~x, data = datasaurus_raw |> filter(dataset==9))
dataset_12_mod <- lm(y~x, data = datasaurus_raw |> filter(dataset==12))

jtools::export_summs(dataset_4_mod, dataset_7_mod, dataset_9_mod, dataset_12_mod,
                     model.names = c("dataset 4", "dataset
"))
```

\newpage

4.  Now plot the variables for each dataset. Summarize your findings.

-   Dataset 4 appears to be a tyronsaurs, while datasets 7, 9, and 12 are horizontal, diagonal, or verticle lines.

```r
datasaurus_raw |> 
  ggplot(aes(x, y)) +
  geom_point(size=.85, alpha=.6, fill="dodgerblue") +
  facet_wrap(~dataset) +
  theme_hc()
```

\

5.  If you have not chosen it yet, look at dataset 4.Summarize your findings.

-   dataset 4 apepars to be a dinosaur telling by the large head and small arms.
