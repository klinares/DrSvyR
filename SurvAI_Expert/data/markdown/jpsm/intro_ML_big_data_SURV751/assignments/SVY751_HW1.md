---
id: "jpsm/intro_ML_big_data_SURV751/assignments/SVY751_HW1"
source: "jpsm"
course: "SURV751"
course_title: "Introduction to Machine Learning and Big Data"
doc_type: "assignment"
title: "SURV751: Assignment 1"
original: "intro_ML_big_data_SURV751/assignments/SVY751_HW1.qmd"
pages: 
sha256: "aadb9b4b36548b917c6c65a5544c85f3577467f06e7e724a159ea4b3107c83c3"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:09"
---


## The FLCounties2010.xlsx data file contains county level information on various demographic information complied at the county level by the 2010 U.S. Census or by MSG based on block group/county level information.

### A client is interested in recruiting Hispanics in Florida from both Urban and Suburban areas of Florida and wants to create sampling strata that are comprised of FL Counties that have high/moderate percentages of Hispanic residents from both suburban and urban areas.

```r
#| echo: true

# load packages
pacman::p_load(tidyclust, knitr, readxl, tidymodels, viridis, tidyverse)

# read in florida counties
data_path <- 
  "D:/repos/UMD_classes_code/intro_ML_big_data_SURV751/assignments/"

fl <- read_xls(str_c(data_path, "FLCounties2010.xls"))

# view first data
fl |> glimpse()

```

### Task A. Using the FLCounties2010 data create two possible three cluster solutions based on random seeds of 10 and 99. The variables you will want to consider for clustering include the three most relevant to the studies objectives previously stated. Save these solutions as fl3cluster_10 and fl3cluster_99. You will also want to retain the cluster assignments

-   We generate two 3-cluster solutions using using relevant variables `PCTHispanic`, `PCTUrban_MSG`, and `PCTSuburban_MSG`. We set the seeds to 10 and 99, deploy the algorithm on the Florida counties data, and use the model objects to assign clusters to counties.

    -   First we normalize (i.e., scale the three features).

    -   Second, we specify the model and engine we want to use, `tidyclust::k_means()`

    -   Third, we put these components in a `workflow()`.

```r
# We preprocess the data using the recipes package 
km_rec <- recipe(
  # select variables needed
  ~ PCTHispanic + PCTUrban_MSG + PCTSuburban_MSG, data = fl) |>
  # scale featuers
  step_normalize(all_predictors())

km_rec

num_clusters <- 3
# specify the model and engine needed
km3_spec <- k_means(num_clusters = num_clusters) |>
  set_engine("stats")

km3_spec

# combine recipe and model in one workflow

km3_wf <- workflow() |>
  add_recipe(km_rec) |>
  add_model(km3_spec)

km3_wf
```

-   We are now able to deploy the algorithm on the data using both seeds.

    -   For each model we examine the centroids on each feature.

    -   We then assign counties to a cluster and save these new variables onto the fl dataframe.

```r
# seed = 10
set.seed(10)
km3_fit_10 <- km3_wf |> fit(data = fl)


# cluster centroids (scaled)
extract_centroids(km3_fit_10) |> kable()


# Augment the df attach cluster assignments
fl <- fl |>
  mutate(
    cluster_10 = extract_cluster_assignment(km3_fit_10)$.cluster,
  )
```

```r
# seed = 99
set.seed(99)
km3_fit_99 <- km3_wf |> fit(data = fl)

# cluster centroids (scaled)
extract_centroids(km3_fit_99) |> kable()

# Augment: attach cluster assignments
fl <- fl |>
  mutate(
    cluster_99 = extract_cluster_assignment(km3_fit_99)$.cluster
  )
```

-   Now that we have the cluster assignment we can visualize it in a scatterplot.

```r

# we need to stack the data for visualizing
fl |> 
  pivot_longer(cols = c(cluster_10, cluster_99),
               names_to = "solution", values_to = "cluster") |>
  mutate(solution = if_else(solution == "cluster_10",
                            # titles for plots
                            "Seed = 10", "Seed = 99")) |> 
  ggplot(aes(x = PCTUrban_MSG, y = PCTSuburban_MSG,
             color = cluster, size = PCTHispanic*100)) +
  geom_point(alpha = 0.75) +
  scale_color_viridis_d(option = "D", begin = 0.15, end = 0.85,
                        name = "Cluster") +
  scale_size_continuous(name = "% Hispanic", range = c(1.5, 8)) +
  facet_wrap(~solution) +
  labs(title = "3-Cluster Solutions: Seed 10 vs Seed 99",
    x = "Percent Urban", y = "Percent Suburban") +
  theme_minimal() +
  theme(legend.position = "bottom")
```

-   The plot above reveals a near identical cluster partitioning. One thing to note is that cluster numbers labels are redundant. That is, in one experiment row 1 can be assigned to cluster 1, and at other times the same row can be assigned to cluster 3, so the cluster labels can differ.

\newpage

### Task B (2 points) Ordering the clusters in each of the two solutions by their within cluster SS, for how many of the 3 clusters in the seed=10 solution is the respective within cluster SS smaller compared to the within cluster SS for the seed=99 solution?

-   We can use `tidyclust::sse_within()` to extract within cluster SS from each fitted workflow, then order and compare cluster assignments.

```r
# within sum of squares comparison
wss_comparison <- bind_rows(
  # give each seed a group name
  sse_within(km3_fit_10) |> mutate(solution = "seed_10"),
  sse_within(km3_fit_99) |> mutate(solution = "seed_99")
  ) |>
  group_by(solution) |>
  arrange(wss, .by_group = TRUE) |>
  # create a random id number for each group
  mutate(rank = row_number()) |>
  ungroup() |>
  # widen the data frame
  pivot_wider(id_cols = rank, names_from = solution,
              values_from = wss) |>
  # create a new column that flags smaller cluster condition
  mutate(seed10_smaller = seed_10 < seed_99)

wss_comparison |> kable()
```

-   Only 1 of the 3 ordered clusters has a smaller within-SS in the seed = 10 solution.

\newpage

### Task C (2 points). How many of the 67 counties were assigned to a different cluster across the two 3 cluster solutions. Note – the cluster numbers are nominal variables and can differ naturally from one run to the other (i.e. cluster named “1” for the first solution can refer to the cluster named “3” in the second).

-   Normally if say cluster 1 in one run is the same or similar to cluster 2 in another run than we would want to correct for label switching. In this case, both runs match labels, making it easier for us to find which counties were labeled differently which we print below. We find that for counties 12087 and 120093, they were assigned to cluster 3 in the first run, and cluster 1 in the second.

```r
fl |> 
  filter( cluster_10 != cluster_99) |> 
  select(ID, cluster_10, cluster_99) |> 
  kable()

# also create a cross-tabulation due to label switching
## these are plausable cluster combinations
perms <- crossing(a = 1:3, b = 1:3, c = 1:3) |>
  filter(a != b, a != c, b != c) |>
  pmap(c)

# loop through each cluster combination
best_match <- tibble(perm = perms) |>
  mutate(
    matches = map_dbl(perm, function(p) {
      # build a named lookup vector, Cluster_1 -> Cluster_p[1], & so on
      lookup <- set_names(
        paste0("Cluster_", p),
        paste0("Cluster_", 1:3)
      )
      # remap cluster_99 using the lookup
      remapped <- lookup[as.character(fl$cluster_99)]
      sum(fl$cluster_10 == remapped)
    })) |>
  # keep highest matches
  slice_max(matches, n = 1)

cat("Counties assigned differently ", fl |> nrow() - best_match$matches )

```

\newpage

### Task D (4 points). Using the FLCounties2010 data, assign a random seed of 2016 and generate a scree type plot for a series of cluster solutions ranging from 1 to 10 possible clusters. Use set.seed(2016) before you institute a for loop.

#### Hint: For this task also use the option nstart=20 inside your kmeans statement. This option requests multiple starting points to be used with the best of the 20 being saved as the particular solution (i.e. the one with the smallest total within sums of squares).

-   We iterate over $k = 1, \dots, 10$, specifying each model with `k_means(num_clusters = k)` and `nstart = 20` via `set_engine()`. After fitting each workflow, we extract the total within-SS by summing `sse_within()`.

```r

# set to 2016
set.seed(2016)

# frist we loop through each proposed cluster solution and fit the the data
cluster_fit <- map(seq(1, 10), function(k){
  
 # combine recipe and model in one workflow
  workflow() |>
    add_recipe(km_rec) |>
  add_model(k_means(num_clusters = k) |> 
              # impose the nstart to 20
              set_engine("stats", nstart=20)) |> 
    fit(data = fl)

} )

# we can than extract information as needed from this list
cluster_fit_df <- map_dfr(seq(1:10), function(k){
  
  # subset fit from list
  cluster_result = cluster_fit[[k]]
  
  tibble(
    # assign cluster
    cluster=k, 
    # keep only within SS (summ of SS)
    tot_wss = sse_within_total(cluster_fit[[k]]) |> 
      pull(.estimate)
  )
  })

# build the scree plot
cluster_fit_df |> 
  ggplot(aes(x = cluster, y = tot_wss)) +
  geom_line(color = "dodgerblue") +
  geom_point(size = 3.5, color = "dodgerblue") +
  # add an asthetic to show optimal cluster structure
  geom_vline(xintercept = 4, linetype = "dashed", color = "black",
             linewidth = 0.5) +
  # call out the optimal clsuter
  annotate("text", x = 4.4, y = 150,
           label = "k = 4", color = "black", size = 3.5) +
  scale_x_continuous(breaks = 1:10) +
  labs(x = "Number of k Clusters",
       y = "Total Within Cluster SS",
       title = "Scree Plot for K-Means Clustering") +
  theme_minimal() 
```

-   The sharpest decline in within cluster SS occurs between $k = 1$ and $k = 4$. After $k = 4$, reductions are more gradual, suggesting diminishing returns. We determine that a 4-cluster solution is optimal.

\newpage

### Task E. Using a random seed of 4 and an nstart=20 option, generate a 4 cluster solution for the FLCounties2010 data based on the three main variables of interest for this particular study.

-   As before, we fit a 4 cluster solution with the requirements.

```r
# requirements
set.seed(4)
# number of clusters
k <- 4
# number of nstart
nstart_n <- 20

km_4_fit <-  workflow() |>
  add_recipe(km_rec) |>
  add_model(k_means(num_clusters = k) |> 
              set_engine("stats", nstart=nstart_n)) |> 
    fit(data = fl)

# Augment df by attaching cluster assignments
fl <- fl |>
  mutate(cluster_4 = extract_cluster_assignment(km_4_fit)$.cluster)
```

\

### Task E-1 (4 points): Report the average PCTHispanic in each of your clusters (round answers to the nearest whole number and express your answers as whole numbers (e.g. 10%, 12% etc).

-   Below we print average Hispanic shares by cluster.

```r

fl |> 
  group_by(cluster_4) |>
  # compute mean for each cluster
  reframe(ave_hispanic = mean(PCTHispanic),
          # convert proportions to percent
          ave_hispanic = scales::percent(ave_hispanic)) |> 
  kable()
```

### Task E-2: (3 points) How would you characterize the fourth cluster in terms of Hispanics, urban and suburban populations?

-   We plot below each cluster by average percent of Hispanic, urban, rural and suburb. Cluster 4 Has the highest percent of Hispanics (52%), and interestingly it seems that the first three clusters split by urban, rural, and suburb, yet cluster 4 are counties composed of mostly suburbs and urban areas with a decent share of rural areas.

```r
#| fig-height: 4
#| fig-width: 5

cluster_profiles <- fl |>
  mutate(PCTHispanic_pct = PCTHispanic * 100) |>
  group_by(cluster_4) |>
  reframe(
    Hispanic  = mean(PCTHispanic_pct),
    Urban     = mean(PCTUrban_MSG),
    Suburban  = mean(PCTSuburban_MSG),
    Rural     = mean(PCTRural_MSG)  ) |>
  pivot_longer(-cluster_4,
               names_to = "variable", values_to = "mean_pct") |>
  mutate(
    variable = fct_relevel(variable,
                           # titles for columns
      "Hispanic", "Urban", "Suburban", "Rural"),
    cluster_label = str_c("Cluster ", cluster_4))

ggplot(cluster_profiles,
       aes(x = variable, y = mean_pct, fill = cluster_4)) +
  geom_col(width = 0.7, show.legend = FALSE) +
  geom_text(aes(label = paste0(round(mean_pct), "%")),
            vjust = -0.4, size = 3, fontface = "bold") +
  facet_wrap(~cluster_label, nrow = 1) +
  scale_fill_viridis_d(option = "E", begin = 0.1, end = 0.9, alpha=.7) +
  labs(x = NULL, y = "Average Percentage",
       title = "Cluster Profiles with Demographic Composition") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 35, hjust = 1, size = 8))
```

### Task E-3: (2 points) Rounding to a whole number, what is the median percentage in Rural areas for counties that are in the FIRST cluster of your 4 cluster solution?

-   The median percentage of rural areas in cluster 1 is 17%.

```r
fl |> 
  filter(cluster_4 == "Cluster_1") |> 
  reframe(Median_Rural_per = 
    round(median(PCTRural_MSG)) 
  ) |>  kable()
```

### Task E-4: (3 points) If you had to prioritize your sampling efforts in an attempt to cover Hispanics in both heavy Urban and heavy Suburban areas, which two clusters would you first target for these efforts?

-   We would prioritize cluster 4 since this is the cluster with a majority of Hispanics with a moderate share of urban areas, followed by the 3rd as two-thirds of these countries are labeled suburban. Together, these two clusters capture the highest Hispanic counties and the most urbanized counties, fulfilling the dual objective of reaching Hispanics in both Urban and Suburban settings.
