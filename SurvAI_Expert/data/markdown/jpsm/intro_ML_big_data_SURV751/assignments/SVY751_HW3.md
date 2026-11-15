---
id: "jpsm/intro_ML_big_data_SURV751/assignments/SVY751_HW3"
source: "jpsm"
course: "SURV751"
course_title: "Introduction to Machine Learning and Big Data"
doc_type: "assignment"
title: "Homework Assignment 3"
original: "intro_ML_big_data_SURV751/assignments/SVY751_HW3.qmd"
pages: 
sha256: "9bb5220eb3d1217634a3b3ea9e0ff3005b3a4e751bd4d1b38056f55da89121df"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:05"
---


## The HW3datasets.Rdata is an R workspace that contains two data frames you will need to complete the tasks of this homework assignment: treetrain and treetest. To load the workspace, choose “Load Workspace” from the File menu in the basic R console. Once loaded, you can see these two data frames by typing \> objects() at the R prompt in the console window.

```r
pacman::p_load(knitr, viridis, rpart, rattle, randomForest,
               tidymodels, tidyverse)

options(scipen = 999)
```

## These data are the same you used for HW 2 except that we combined the X and Y variables into a single data frame for both the Training and Testing samples.

-   The Y outcome of interest appears as the first variable “hasphone” in these data frames. This variable has already been stored as a factor with values 0 indicating “no landline phone” and 1 indicating has “landline phone.”

```r
load("HW3datasets.RData")
```

## **The goal** is to develop a tree model that can be used to predict whether or not an address has a landline phone.

-   Figure 1 verifies that the outcome has a similar distribution across both split sets, with slightly more people not having a land line phone.

```r

bind_rows(
  treetrain |> mutate(dataset = "treetrain"),
  treetest |> mutate(dataset = "treetest")
) |>
  group_by(dataset) |> 
  count(dataset, hasphone) |> 
  mutate(hasphone = ifelse(
    hasphone == 1, "Has Landline Phone", "No Landline Phone"),
    prop = n/sum(n)) |>
  ungroup() |> 
  ggplot(aes(x = dataset, y = prop, fill = hasphone)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_viridis_d(alpha=.7) +
  labs(title = 
         "Figure 1. Percent of Landline Phone Distribution Across\n
       Training (n=1,000) and Test (n=500) split.", y = "Percent") +
  theme_minimal() +
  theme(legend.position = "bottom")

```

| Variable Name | Description |
|--------------------|----------------------------------------------------|
| hasphone | Has Landline Telephone (0="No Phone"; 1="Phone") (the outcome) |
| numhhs | Current Year Households |
| landsqmile | Land Area in Square Miles |
| medagehhder | Current Year Median Age, Householder |
| huownerocc | Current Year Housing Units, Owner-Occupied |
| avghhsize | Current Year Average Household Size |
| hhwithkids | Current Year Households, With People \< 18 Years Old |
| medlenresidence | Current Year Median Householder Years of Residence |
| avgnumvehicles | Current Year Average Number of Vehicles Available |
| medhhincome | Current Year Median Household Income |
| famsaabovpov | Current Year Families At or Above Poverty |
| popnotinlf | Current Year Population 16+, Not in Labor Force |
| popnevmarried | Current Year Population Not Currently Married |
| hsorless | Current Year Population (25+) that have HS or Less Education |
| pctfemale | Percent of total population who are FEMALE |

\newpage

## Note for this assignment you will need the packages rpart, randomForest, rattle and caret installed in your version of R. To get them: Choose Packages...install package(s) from the menu prompt in the R console window. Then navigate to a CRAN near you then navigate the LONG package list to find "rpart" then click OK. Repeat for randomForest!

### Task A (2 points): Using the rpart function, create a tree with maximum depth of 2 data frame. Be sure to store this object as say tree1. Provide the R code used to create your tree. (so we can have a root node and at most two sets of subsequent banches) to predict hasphone from the rest of the variables in the “treetrain”

-   Note before you run rpart, please be sure to run this code to set the initial seed to 2016. \>set.seed(2016).

-   We fit a classification tree with `maxdepth = 2`, to the training set. This allows a root node and at most two subsequent levels of branching to grow, using the rpart as the engine (i.e., algorithm).

```r
set.seed(2016)

# put together the recipe
tree_recipe <- recipe(hasphone ~ ., data = treetrain)

# model spec with max depth of 2
tree_spec <- decision_tree(tree_depth = 2) |>
  set_engine("rpart") |> # set rpart as the engine
  set_mode("classification") # classification task

# combine recipe with model spec in a workflow
tree_wf <- workflow() |>
  add_model(tree_spec) |>
  add_recipe(tree_recipe)

tree_wf
# fit the model to training set, save in workflow
tree1_tidy <- tree_wf |>
  fit(data = treetrain)

# extract the underlying rpart object for inspection
tree1_rpart <- tree1_tidy |>
  extract_fit_engine()

tree1_rpart
```

\newpage

### Task B (2 points): Plot the tree1 object you created in Task A using the fancyRpartPlot function from the rattle package.

-   We extract the native `rpart` object from the tidymodels workflow to use with `fancyRpartPlot`. The `workflowsets::extract_fit_engine()` allows us to extract the rpart object for plotting the tree.

```r
#| fig-width: 7.5
#| fig-height: 5

tree1_tidy |>
  extract_fit_engine() |>
  fancyRpartPlot(sub = "")

```

\newpage

### Task C (4 points): Using the plot answer these questions:

1.  On which variable is the first split in the tree based?

    -   The first split is based on `medlenresidence` (Current Year Median Householder Years of Residence) at a threshold of 11.85, meaning addresses with shorter residency (\< 11.85 years) are classified as "No Landline Phone."

2.  On which variable is the second split in the tree based?

    -   The second split is based on `medhhincome` (Median Household Income) at a threshold of 62,236, or \$62,236. Conditional on addresses with longer residency (\>= 11.85), those in higher income areas are more likely to be classified as having a landline.

3.  How many final nodes does your tree have?

    -   The tree has 3 final terminal nodes.

4.  Describe in words the final node that has the highest percentage of addresses with landline phone numbers.

    -   The node with the highest percentage of landline phones corresponds to addresses where the median householder years of residence is \>= 11.85 and the median household income is \>= \$62,236. This node contains 155 observations with approximately 68% classified as having a landline phone.

\newpage

### Task D (4 points): Use your tree1 model to obtain predicted “hasphone” status of the treetest data. Then use the predicted values you obtain along with the “hasphone” status in the treetest data to obtain a confusion matrix. From this confusion matrix what is the accuracy of your tree algorithm (that is the percent of the 500 cases in treetest that are correctly classified by the tree1 model)?

-   Note before you run the predict function, please be sure to run this code to set the initial seed to 2016. \>set.seed(2016)

-   We use the tree1 depth 2 tree algorithm to predict the test set and compile a confusion matrix with `yardstick::conf_mat()`. The `workflowsets` package, which gets loaded in with tidyalgorithms, has the `autoplot()` function that plots confusion matrix tables and we see that the majority of cases are in the has no landline phone and correctly predicted as no landline cell. The yardstick package has helpful function, such as `accuracy(),` that allows us to compute performance measures. We calculate accuracy to be .588, or 59%, However, we also calculate sensitivity to be .189, or 19%, suggesting that the algorithm correctly identities fewer than 1 in 5 addresses that actually have a landline phone possibly due to the class imbalance.

```r
set.seed(2016)

# predict test set using tidymodels workflow
test_preds_tree1 <- tree1_tidy |>
  augment(new_data = treetest) # bring in test set

# plot a confusion matrix
test_preds_tree1 |>
  conf_mat(truth = hasphone, estimate = .pred_class) |>
  autoplot(type = "heatmap") +
  # give it some color
  scale_fill_viridis_c(option = "rocket", direction = -1, alpha = 0.9, begin=.8) +
  labs(title = "Confusion Matrix for Maximum Depth of 2")
```

#### Note. For these algorithms we will be examing accuracy and sensitivity which we can set using the yardstick package which gets loaded by tidymodels. 

```r
class_metrics <- metric_set(accuracy, sensitivity)

metric_fun <- function(mod){
  
# accuracy and sensitivity
mod |> # test predictions
  # collect metrics
  class_metrics(truth = hasphone, estimate = .pred_class, 
                event_level = "second") |>
  select(.metric, .estimate) |> 
  kable(digits = 3)
}
```

```r
# accuracy and sensitivity via yardstick
test_preds_tree1 |>
  metric_fun()

```

\newpage

### Task E. (4 points) Repeat Tasks A and D using a maximum depth of 10.

-   Note before you run the predict function, please be sure to run this code to set the initial seed to 2016. \>set.seed(2016).

-   How does the sensitivity for the second tree compare to that of the first?

-   The larger tree with maximum depth of 10 provides an accuracy of .580, or 58%, which is slightly lower than the algorithm with maximum depth of 2. It also classifies more addresses as correctly having landlines (85 compared to the previous algorithm of 43). Moreover, sensitivity nearly doubles; .374, or 37%, which trades some specificity for improved sensitivity by classifying more addresses as having a landline (i.e., true positives) at the cost of additional false positives. This highlights the bias-variance trade off discussed in module 2 as the larger tree fits more complex patterns in the training set, thus helping identify addresses that the shallower tree missed before.

```r
#| fig-width: 8
#| fig-height: 10
#| 

set.seed(2016)

# algorithm spec with max depth of 10
tree_spec_deep <- decision_tree(tree_depth = 10) |>
  set_engine("rpart") |> # rpart algorithm
  set_mode("classification")

# workflow setup
tree_wf_deep <- workflow() |>
  add_model(tree_spec_deep) |>
  add_recipe(tree_recipe) # same recipe

# fit algorithm
tree2_tidy <- tree_wf_deep |>
  fit(data = treetrain)

# plot using extracted rpart object
tree2_tidy |>
  extract_fit_engine() |>
  # use rpart to contorl the visual elements for readabiltiy 
    rpart.plot::rpart.plot(type = 4, extra = 2, under = TRUE,
                           fallen.leaves = TRUE, cex = 0.9,
                           tweak = 1.0, box.palette = "auto"
  )

```

```r
set.seed(2016)

# predict test set
test_preds_tree2 <- tree2_tidy |>augment(new_data = treetest)

# confusion matrix
test_preds_tree2 |>
  conf_mat(truth = hasphone, estimate = .pred_class) |>
  autoplot(type = "heatmap") +
  # give it some color
  scale_fill_viridis_c(
    option = "rocket", direction = -1, alpha = 0.9, begin=.8) +
  labs(title = "Confusion Matrix for Maximum Depth of 10") 
```

```r
# accuracy and sensitivity via yardstick
test_preds_tree2 |> metric_fun()

```

\newpage

### Task F (4 points): Using the treetrain data compute a random forest object called forest1 using ntree=1000 and the default value for mtry. Use this object to:

-   Identify the top two most important variables for the forest based on the mean decrease in accuracy index.

-   The accuracy of applying the forest to predict the has phone status of the treetest data.

    -   NOTE: use \>set.seed(2016) before you run the forest model and again before you run the predict code.

        -   HINT: use data=treetrain in the randomForest call. Also, you don’t need to specify any value for mtry (that is just leave it out completely from the function call) since we are interested in using the built in defaults.

-   The top two most important variables based on the mean decrease in accuracy index are **`avgnumvehicles`** (Average Number of Vehicles Available) and **`medlenresidence`** (Median Householder Years of Residence). This is consistent with the CART results where `medlenresidence` was the primary split variable. The importance of `avgnumvehicles` suggests it captures neighborhood-level socioeconomic information relevant to landline phone availability that the tree algorithms did not fully leverage. The random forest algorithm had an accuracy of .572, or 57%, on the test set. This is slightly lower compared to the tree algorithms. However, it had a sensitivity of .374, or 37%. This suggests that the random forest algorithm maintains the improved sensitivity of the larger tree by aggregating predictions across 1000 trees. The ensemble approach reduces variance relative to any individual tree, providing more stable predictions.

```r
set.seed(2016)

# build the recipe for rf
rf_recipe <- recipe(hasphone ~ ., data = treetrain)

# parameters are given to us
# ntree = 1000
# mtry = sqrt(p) for classification
# pass importance = TRUE to the engine for MeanDecreaseAccuracy
rf_spec <- rand_forest(trees = 1000) |> # if no mtry is set, default is used
  set_engine("randomForest", importance = TRUE) |> # use randomForest package as the engine
  set_mode("classification") # classify

# build the rf workflow
rf_wf <- workflow() |>
  add_model(rf_spec) |>
  add_recipe(rf_recipe)

# fit the rf algorithm to training set
forest1_tidy <- rf_wf |>
  fit(data = treetrain)

# extract the rf object
forest1_rf <- forest1_tidy |>
  extract_fit_engine()

# print algorithm information and rf object
rf_wf
forest1_rf
```

```r
forest1_rf |> 
  # use the VIP package for nicer plots
  vip::vip(num_features = 20, geom = "col", aesthetics = list(fill = "dodgerblue", alpha=.7)) +
  ggtitle("Variable Importance Plot") +
  theme_minimal() 

```

```r
# subset top 2 by MeanDecreaseAccuracy
importance(forest1_rf) |>
  as_tibble(rownames = "Features") |>
  arrange(desc(MeanDecreaseAccuracy)) |>
  select(Features, MeanDecreaseAccuracy) |>
  slice_head(n = 2) |>
  kable(digits = 3)
```

```r
set.seed(2016)

# predict on test set
test_preds_forest <- forest1_tidy |>
  augment(new_data = treetest)

# confusion matrix
test_preds_forest |>
  conf_mat(truth = hasphone, estimate = .pred_class) |>
  autoplot(type = "heatmap") +
  # give it some color
  scale_fill_viridis_c(option = "rocket", direction = -1, alpha = 0.9, begin=.8) +
  labs(title = "Confusion Matrix for Random Forest algorithm") 
```

```r
# accuracy and sensitivity via yardstick
test_preds_forest |> metric_fun()
```
