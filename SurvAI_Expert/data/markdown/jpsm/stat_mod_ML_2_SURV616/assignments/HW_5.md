---
id: "jpsm/stat_mod_ML_2_SURV616/assignments/HW_5"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "assignment"
title: "SURV616, Homework 5"
original: "stat_mod_ML_2_SURV616/assignments/HW_5.qmd"
pages: 
sha256: "80ba2c1ca9f689195b962ad67af7b4d64f67c3ae18f9b2bcc9bc1547d287eda6"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:27"
---


## ![](honor_hw5.png){width="300"}

## Problem Statement

### Your client is a wholesale distributor of food, beverages, and cleaning supplies. The firm is located in Portugal. The task is to identify groups of customers that may share common patterns of spending on goods from the distributor. This will aid the firm in planning its marketing. You will use K-means to identify these groups of customers.

```r

pacman::p_load( readxl, jtools, skimr, knitr, viridis,
                ggthemes, ConfusionTableR, 
                tidymodels, tidyverse)

options(scipen=999)

# read in data
wholesale <- read_xlsx(
  "~/work/d/UMD_classes_code/stat_mod_ML_2_SURV616/homework/Wholesale_customers_data.xlsx") 
```

\newpage

### Data

### You are provided with following file: “Wholesale customers data.csv”. The data dictionary is given below.

| Variable | Definition |
|----------------------|--------------------------------------------------|
| Fresh | Annual spending (m.u.) on fresh products (Continuous) |
| Milk | Annual spending (m.u.) on milk products (Continuous) |
| Grocery | Annual spending (m.u.) on grocery products (Continuous) |
| Frozen | Annual spending (m.u.) on frozen products (Continuous) |
| Detergents_Paper | Annual spending (m.u.) on detergents and paper products (Continuous) |
| Delicatessen | Annual spending (m.u.) on delicatessen products (Continuous) |
| Channel | Channel - Horeca (Hotel/Restaurant/Cafe) or Retail channel (Nominal) |
| Region | Customer’s Region -- Lisbon, Oporto or Other (Nominal) |

1.a. Exploratory Analysis. Read the data into R. Report on each variable using a summary, a figure, or a table as appropriate. You can ignore the channel (CHANNEL) and region (REGION) for this exercise.

-   The boxplot below presents annual spending for each product and we can see some outliers and skewness particularly for milk, grocery, and fresh products. We may wish to transform these variables and re-plot the data.

```r
#| fig-width: 6
#| fig-height: 4

# print summary table
wholesale |> 
  select(Fresh:Delicatessen) |> 
  skim() |> 
  select(1:6) 

# boxplot
wholesale |> 
  # remove region and channel
  select(Fresh:Delicatessen) |> 
  pivot_longer(everything()) |> 
  rename(Product = 1, Spending = 2) |> 
  # reorder variables
  mutate(Product = fct_reorder(Product, Spending, mean)) |> 
  ggplot(aes( y=Spending, fill=Product)) +
  geom_boxplot() +
  scale_fill_viridis_d(option="rocket", begin =.20, end = .90, 
                       alpha=.80, direction=-1) + 
  theme_hc()
  
```

\

1 b. Feature Engineering. What pre-processing steps are necessary before applying K-means? Are there any transformations of the data to consider for this problem? Explain your choices.

-   Since k-means is sensitive to the scale of features we will be centering and scaling features so that larger scale features do not disproportionately influence the distance calculations leading to cluster driven by these variables. Additionally, because these variables are highly skewed and k-means is sensitive to this, we may wish to transform them on the log scale before centering. Log transformations are useful for right skewed data. We can see from the boxplot below that the scales of these features are now comparable to each other after being log transformed, scaled, and centered.

```r
#| fig-width: 6
#| fig-height: 4

# create model data and transform features
wholesale_model_dat <- wholesale |> 
  select(Fresh:Delicatessen) |> 
  mutate(across(where(is.double), ~ scale(log(.x), center=TRUE, scale=TRUE)))

# create boxplot with transformed features
wholesale_model_dat |> 
  pivot_longer(everything()) |> 
  rename(Product = 1, Spending = 2) |> 
  mutate(Product = fct_reorder(Product, Spending, mean)) |> 
  ggplot(aes( y=Spending, fill=Product)) +
  geom_boxplot() +
  scale_fill_viridis_d(option="rocket", begin =.20, end = .90, 
                       alpha=.80, direction=-1) + 
  theme_hc()
```

\newpage

\

2.  The first task will be to create groups using the variables FROZEN and FRESH only. For this task, ignore the other variables in the dataset.

-   We cluster two features Fresh and Frozen.

```r
#| fig-width: 6
#| fig-height: 4

set.seed(909)

# build k-means model
kclusts_1 <- 
  # pass range of K to try
  tibble(k = 1:9) |> 
  mutate(
    # generate models for each k value
    kclust = map(k, ~kmeans(select(
      wholesale_model_dat, Fresh, Frozen), .x)),
    glanced = map(kclust, glance)) # extracts summaries

```

\

a\. Hyperparameter Selection. What is the K you choose for this problem? How do you justify that choice?

-   We selected `k = 3`, and tried values of k between one to nine for our hyperparameter. Below we plot each k value we tested and the corresponding total within-cluster sum of squares, and we determine that between 2 and 3 clusters is sufficient for this data to also maintain parsimony. Furthermore, what we are looking for is the bend, known as the elbow in the graphic, yet also a lower error rate.

```r
#| fig-width: 6
#| fig-height: 4
#| 

kclusts_1 |> 
  unnest(cols = c(glanced)) |> 
  ggplot(aes(k, tot.withinss)) +
  geom_line(alpha = .75, size = 1, color = "dodgerblue") +
  scale_x_binned() +
  geom_point(size = 2, color = "midnightblue") +
  theme_hc()
```

\

b\. Graph the K-means clustering of the cases based upon the FROZEN and FRESH variables.

-   We plot three clusters against Fresh and Frozen below. There tends to be good distinction between these clusters.

```r
#| fig-width: 6
#| fig-height: 4

k <- 3 # choose final k value

# merge cluster assignment with data
augment(kclusts_1$kclust[[k]], wholesale_model_dat) |> 
  ggplot(aes(Frozen, Fresh, color = .cluster)) +
  geom_point() +
  scale_color_viridis_d(option="A", begin =.20, end = .90, 
                       alpha=.80, direction=-1) + 
  theme_hc()

```

\

\newpage

3.  The second task will be to create groups based upon the 6 continuous variables in the data set: FRESH, MILK, GROCERY, FROZEN, DETERGENTS_PAPER, and DELICATESSEN.

-   Again, we try k values between one and nine for all six features.

```r

set.seed(909)

kclusts_2 <- 
  # k values to try
  tibble(k = 1:9) |> 
  mutate(
    # build each model
    kclust = map(k, ~kmeans(wholesale_model_dat, .x)),
    # tidy results for plotting
    tidied = map(kclust, tidy),
    # extract summaries
    glanced = map(kclust, glance),
    # save model results with data
    augmented = map(kclust, augment, wholesale_model_dat)
  )

# seperate results into datasets for further exploration
clusters <- 
  kclusts_2 %>%
  unnest(cols = c(tidied))

assignments <- 
  kclusts_2 %>% 
  unnest(cols = c(augmented))

clusterings <- 
  kclusts_2 %>%
  unnest(cols = c(glanced))

```

\newpage

a\. Hyperparameter Selection. What is the K you choose for this problem? How do you justify that choice?

-   We plot k values with total within sum of squared and identify that the elbow is at k=2, although k=3 would also be sufficient. Therefore, we decide to plot these results for further exploration. In looking at the scatterplots using a red `*` to signify the center of the cluster, we do not see much separation beyond three clusters; therefore, we use k=3 as our final model.

```r
#| fig-width: 6
#| fig-height: 4


clusterings |> 
  ggplot(aes(k, tot.withinss)) +
  geom_line(alpha = .75, size = 1, color = "dodgerblue") +
  scale_x_binned() +
  geom_point(size = 2, color = "midnightblue") +
  theme_hc()

```

```r
#| fig-width: 7
#| fig-height: 9

# build grid of plots
ggplot(assignments, aes(x = Frozen, y = Fresh)) +
  geom_point(aes(color = .cluster), size=.85) + 
  geom_point(data = clusters, color="darkred",  size = 8, shape = "*") +
  facet_wrap(~ k) +
  scale_color_viridis_d(option="viridis", begin =.05, end = .99, 
                       alpha=.80, direction=-1) + 
  theme_hc()

```

b\. List the values of the 6 variables at each center. Write a one sentence description of each group. How is each unique?

-   Below we print center means for each feature. Cluster 1 contains 48 percent of the sample share. This group may be shoppers without families that spend mostly on fresh produce and frozen foods, and less so on milk and groceries. Cluster two is 18 percent of the sample, and these may be shoppers with families as they spend mostly on milk, groceries, and cleaning supplies. Cluster 3, 33 percent, are shoppers that spend on all 6 products.

```r
# print center values for each feature
 kclusts_2$tidied[[k]] |> select(-withinss, -cluster) |> kable()
```

c\. Create a two-way table showing how the groups from Question #2 and #3 intersect. Give a brief description of how the two sets of clusters relate.

-   We build a contingency table below and show the cluster membership assignment for the first and second models. The highest agreement is for the first model at 27 percent, for the second cluster 10 percent, and 15 percent for the third cluster. Cohen's kappa cohen's kappa is at .21 agreement, which is not entirely great. This suggest that different features can have significant impact on how the clusterings are formed.

```r
# extract clustering information from both models
contin_table <- tibble(
  mod_1_clustering = kclusts_1$kclust[[k]]$cluster,
  mod_2_clustering = kclusts_2$kclust[[k]]$cluster) |> 
  mutate_all(factor)

# calculate kappa using the confusionmatrix pacakge
cm_results <- multi_class_cm(contin_table$mod_1_clustering, 
                              contin_table$mod_2_clustering)

coh_kappa <-  cm_results$record_level_cm |> 
  pull(contains("Kappa"))
  
cm_results$cm_tbl |> prop.table() |> round(3) |> 
    kable(caption=str_c("Aggreement between LLMs, Cohens Kappa, ", 
                        round(coh_kappa, 3))) 
```
