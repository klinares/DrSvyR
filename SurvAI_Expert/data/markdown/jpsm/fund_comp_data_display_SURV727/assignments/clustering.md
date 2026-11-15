---
id: "jpsm/fund_comp_data_display_SURV727/assignments/clustering"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "assignment"
title: "Assignment 5"
original: "fund_comp_data_display_SURV727/assignments/clustering.qmd"
pages: 
sha256: "d6731e4a97692cab0258de51a2fcfb7ab20d953c0c78b832322e77f31ea5412d"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


You may work in pairs or individually for this assignment. Make sure you join a group in Canvas if you are working in pairs. Turn in this assignment as an HTML or PDF file to ELMS. Make sure to include the R Markdown or Quarto file that was used to generate it. Include the GitHub link for the repository containing these files.

-   Our github page can be found [here](https://github.com/klinares/UMD_classes_code/blob/main/fund_comp_data_display_SURV727/assignments/assignment5.qmd).

```r
library(censusapi)
library(tidyverse)
library(viridis)
library(knitr)
library(tidycensus)
library(ggthemes)
library(factoextra)

options(scipen=999)
```

## Exploring ACS Data

In this notebook, we use the Census API to gather data from the American Community Survey (ACS). This requires an access key, which can be obtained here:

https://api.census.gov/data/key_signup.html

```r
# pass my census api key
cs_key <- read_csv("~/repos/api-keys.csv") |> 
  filter(key_id == "Census_key") |> 
  pull(key)

# read in the necessary fields, save to table
acs_il_c <- getCensus(name = "acs/acs5",
                    vintage = 2016,
                    vars = c("NAME", "B01003_001E", 
                             "B19013_001E", "B19301_001E"),
                    region = "county:*",
                    regionin = "state:17",
                    key = cs_key) %>%
            rename(pop = B01003_001E,
                   hh_income = B19013_001E,
                   income = B19301_001E)

head(acs_il_c) |> kable()
```

\

Pull map data for Illinois into a data frame.

```r
il_map <- map_data("county", region = "illinois")

head(il_map) |> kable()
```

\

Join the ACS data with the map data. Note that `il_map` has a column `subregion` which includes county names. We need a corresponding variable in the ACS data to join both data sets. This needs some transformations, among which the function `tolower()` might be useful. Call the joined data `acs_map`.

After you do this, plot a map of Illinois with Counties colored by per capita income.

-   We join the ACS and census tables for Illinois together and plot a heatmap of per capita income by counties.

```r
#| fig.height = 6, fig.width = 4.5

# join asc_il_c to il_map that contains lat long for counties
acs_map <- il_map |> 
  left_join(
    acs_il_c |> 
      # in NAME, remove part of string not needed
      mutate(subregion = str_remove(NAME, " County, Illinois"),
             subregion = str_to_lower(subregion)) |> 
      arrange(subregion), by="subregion"
)

# plot counties by income
 ggplot(acs_map) + 
   geom_polygon(aes(x = long, y = lat, group = group, 
                    fill = income)) +
   scale_fill_viridis(option="mako", direction = -1) + 
   ggthemes::theme_map() 
```

\

\

## Hierarchical Clustering

We want to find clusters of counties that are similar in their population, average household income and per capita income. First, clean the data so that you have the appropriate variables to use for clustering. Next, create the distance matrix of the cleaned data. This distance matrix can be used to cluster counties, e.g. using the ward method.

-   We fit a hierarchical clustering model to our three variables (population, average household income and per capita income) and find that 7 clusters fit the data well based on the dendrogram plot below.

```r
# drop NA, select variables of interest and scale
hclust_data <- acs_map |> 
  select(pop, hh_income, income) |> 
  drop_na() |> 
  mutate_all(scale)

# create distance matrix
hclust_d <- dist(hclust_data)

# conduct clusterign
hc_ward <- hclust(hclust_d, method = "ward.D2")

```

\

Plot the dendrogram to find a reasonable number of clusters. Draw boxes around the clusters of your cluster solution.

```r
plot(hc_ward, main = "Complete Linkage", xlab = "", sub = "")

rect.hclust(hc_ward, 
            k = 7, border = 2:7) 

```

Visualize the county clusters on a map. For this task, create a new `acs_map` object that now also includes cluster membership as a new column. This column should be called `cluster`.

-   We can see that the clustering by the three variables distinguishes the counties just by looking at the barplot. We see that cluster 6 contains counties with most of the Illinois population with an average household income of almost \$60,000 and average per capita income of roughly 33,000, with a concentration around Chicago city.

```r
#| fig.height = 6, fig.width = 7

# join clustering assignment back to the dataframe
acs_map_cluster <- acs_map |> 
  drop_na() |> 
  mutate(cluster = factor(cutree(hc_ward, 7)))

# visualizing average indicators by cluster
gridExtra::grid.arrange(
acs_map_cluster |> 
  group_by(cluster) |> 
  reframe(pop=mean(pop), hh_income =mean(hh_income), 
          income=mean(income)) |> 
  pivot_longer(-cluster) |> 
  ggplot(aes(x=cluster, y=value, fill=cluster)) +
  geom_bar(stat="identity", width=.5, position = "dodge") +
  facet_wrap(~name, scales = "free") +
   guides(fill="none") +
  theme_hc() +
  ylab("") +
  scale_fill_viridis_d(option="cividis", 
                       direction = -1, end=.90, alpha=.7), 

# plot counties by cluster
 ggplot(acs_map_cluster) + 
   geom_polygon(aes(x = long, y = lat, group = group, 
                    fill = cluster)) +
   scale_fill_viridis_d(option="cividis", 
                        direction = -1, end=.90) + 
   ggthemes::theme_map(), ncol=2
)
 
```

\

\

## Census Tracts

For the next section we need ACS data on a census tract level. We use the same variables as before.

```r
# read in census table and recode mising as NA, 
##than drop these rows before analysis
acs_il_t <- getCensus(name = "acs/acs5",
                      vintage = 2016,
                      vars = c("NAME", "B01003_001E", 
                               "B19013_001E", "B19301_001E"),
                      region = "tract:*",
                      regionin = "state:17",
                      key = cs_key) |> 
  mutate(across(where(is.double), ~ 
                  na_if(.x, -666666666) )) %>%
  rename(pop = B01003_001E,
         hh_income = B19013_001E,
         income = B19301_001E) |> 
  # drop the NA to perform analysis later
  drop_na()

head(acs_il_t) |> 
  kable()
```

\

## k-Means

As before, clean our data for clustering census tracts based on population, average household income and per capita income.

-   Create subset of dataframe with just the variables for the kmeans model input.

```r
acs_il_t_kmeans_dat <- acs_il_t |> 
  select(pop, hh_income, income) 
```

\

Since we want to use K Means in this section, we start by determining the optimal number of K that results in Clusters with low within but high between variation. Plot within cluster sums of squares for a range of K (e.g. up to 20).

-   We can see from the screeplot that after 4 clusters there is not much gain with respect to within cluster sums of squares. Therefore, we will estimate the k-means model with k=4.

```r
fviz_nbclust(acs_il_t_kmeans_dat, #data set we want to use
             kmeans, #cluster method
             #method for estimating the optimal number of clusters
             method = "wss", 
             k.max = 20, iter.max=200)
```

\

Run `kmeans()` for the optimal number of clusters based on the plot above.

```r
km_1 <- kmeans(acs_il_t_kmeans_dat, 4, nstart = 20)
km_1
```

\

Find the mean population, household income and per capita income grouped by clusters. In addition, display the most frequent county that can be observed within each cluster.

-   First, we add the clustering assignment to our tracts within counties in Illinois. and join back to the original table.

```r
# add cluster to the dataset
acs_il_t_kmeans_dat <- acs_il_t_kmeans_dat |> 
  # add the cluster assignment
  mutate(cluster = factor(km_1$cluster)) |> 
  # we do not have to do much processign to join b/c
  ## missing values were on the variables we used for clustering
  ### so they are accounted for before the join
  left_join(acs_il_t)

```

-   we compute average estimates of the indicators we used in the K-means model, and again plot them to visualize the results, which shows cluster variation in average household income and average per capita income.

```r
acs_il_t_kmeans_dat |> 
  group_by(cluster) |> 
  summarise(mean(pop), mean(hh_income), mean(income)) |> 
  kable()

# visualizing average indicators by cluster
acs_il_t_kmeans_dat |> 
  group_by(cluster) |> 
  reframe(mean(pop), mean(hh_income), mean(income)) |> 
  pivot_longer(-cluster) |> 
  ggplot(aes(x=cluster, y=value, fill=cluster)) +
  geom_bar(stat="identity", width=.5, position = "dodge") +
  facet_wrap(~name, scales = "free") +
  theme_hc() +
  ylab("") +
  scale_fill_viridis_d(option="rocket", 
                       direction = -1, end=.90, alpha=.75) 

```

-   Cook county is the most frequent, or popular, county across all four clusters. This is not surprising considering that 42% of tracts (about 1,315 of 3,109 total tracks) in this dataset falls in Cook county. Below we observe the proportion of tracts by cook county across the four clusters.

```r
acs_il_t_kmeans_dat |> 
  group_by(cluster) |> 
  count(county) |> 
  mutate(total_tracts = sum(n)) |> 
  filter(n==max(n)) |> 
  mutate(prop_of_tracts = round(n/total_tracts, 2)) |> 
  rename(county_tracts = n) |> 
  kable()
```

\

\

\

## K-means function

As you might have seen earlier, it's not always clear which number of clusters is the optimal choice. To automate K Means clustering, program a function based on `kmeans()` that takes K as an argument. You can fix the other arguments, e.g. such that a specific dataset is always used when calling the function.

-   We build a function that will take a dataframe of input indicators and K clusters to model K-means on the data and output clustering assignment.

```r
k_means_fun <- function(dat, num_k){
  
  # what to name the new variable
  cluster_name = str_c("Cluster_", num_k)
  
  # apply the kmeans model to the data
  kmean_result = kmeans(dat, num_k , nstart = 20)
  
  # save cluster assignment
  cluster = factor(kmean_result$cluster)
  
  # save out new variable with cluster name
  dat = cluster |> as_tibble() |> rename_at(1, ~cluster_name)
  return(dat)
  }

```

\

We want to utilize this function to iterate over multiple Ks (e.g., K = 2, ..., 10) and -- each time -- add the resulting cluster membership as a new variable to our (cleaned) original data frame (`acs_il_t`). There are multiple solutions for this task, e.g. think about the `apply` family or `for` loops.

-   We fit the K-means model with 2 to 10 K clusters and add each model's clustering assignment back to the original ACS table.

```r
# subset out variables for the k-means model
acs_il_t_subset <- acs_il_t |> 
  select(pop, hh_income, income)

# Add cluster assignments as new variables
acs_il_t_clusters <- acs_il_t_subset |> 
  add_column(
    # compute kmeans on K clusters
    map(2:10, function(x){
      k_means_fun(acs_il_t_subset, x)
  }) |> 
  bind_cols()
  ) |> 
  # Join back to original dataset 
  left_join(acs_il_t)

```

\

Finally, display the first rows of the updated data set (with multiple cluster columns).

-   We plot the first 5 rows with the added clustering assignments for k-means k clusters between 2 and 10.

```r
acs_il_t_clusters |> 
  slice(1:5) |> 
  DT::datatable()
```

\

-   We are able to get census tract shape files using the tidycensus package and merge this information to our kmeans cluster dataframe to plot each model result.

```r

census_api_key(cs_key)

il_tracts_clusters <- get_acs(
  geography = "tract",
  variables = c("B19013_001"),
  state = "IL",
  year = 2016,
  geometry = TRUE
) |>
   right_join(acs_il_t_clusters)
```

```r
 kmeans_models <- acs_il_t_clusters |> 
  select(starts_with("Cluster")) |> colnames()
 
 map(kmeans_models, function(x){
   
   dat = il_tracts_clusters |> 
     select(geometry, all_of(x))
 
   cluster_number = dat |> as_tibble() |> 
     select(-geometry) |>  distinct() |> nrow() 
   
  plot(dat, col=viridis(cluster_number, option="viridis"))
 }) 

```
