---
id: "jpsm/intro_ML_big_data_SURV751/assignments/SVY751_HW2"
source: "jpsm"
course: "SURV751"
course_title: "Introduction to Machine Learning and Big Data"
doc_type: "assignment"
title: "Homework Assignment 2"
original: "intro_ML_big_data_SURV751/assignments/SVY751_HW2.qmd"
pages: 
sha256: "fa1aeddd43324ffbd389b9108b0a274b9079b08990206d32a608ca3565460a89"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:09"
---


## The HW2datasets.Rdata is an R workspace that contains the data objects we will need to work with for this assignment. To load the workspace, choose “Load Workspace” from the File menu in the basic R console

```r
pacman::p_load(knitr, viridis, class, tidymodels, tidyverse)

options(scipen=999)

# load in the workspace
load("HW2datasets.RData")
```

### The basic data frames included in this workspace represent random splits of a larger random sample of residential addresses from across the United States along with appended census block group level information related to various covariates of interest.

-   The knntrain.x and knntest.x data frames in the workspace represent
    the x/predictors/covariates for the training and test sets,
    respectively.

-   The knntrain.y and knntest.y vectors also represent the Y/outcome of
    interest stored as a factor where 0 indicates no landline phone and
    1 indicates has landling phone.

```r
glimpse(knntrain.x)
glimpse(knntest.y)
```

### The goal is to determine the optimal value of “k” for a K-nearest neighbor model that can predict whether or not addresses from a new ABS sample will have a phone number available.

-   Typically appending a phone number to a sampled address has
    additional costs and time associated with gathering this extra
    information, so a prediction model like this acts as a first step to
    prioritizing those sampled addresses for which this extra
    expense/effort would be made. The phone number will then be used for
    a phone follow-up portion in an ABS mail survey.

    -   We recognize that the costs are negligible in terms of time and
        money, but we use this example to illustrate what might be done
        with similar information for slightly different target variables
        of interest including, for example, survey response.

| Variable Name | Description |
|-------------------|-----------------------------------------------------|
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

: Variables and description

### Task A (5 points): Using the knntrain.x and knntain.y dataframes, determine the optimal value of K to be used for k-nearest neighbors based on a 10 fold cross validation with possible values of k ranging from 1 to 21 (odd values only). Provide a plot illustrating the cross validation results (accuracy and error bars) and the final value of k

-   PLEASE USE THE set.seed(2016751) before you perform the 10-fold
    cross validation!

-   We use the training data to perform a 10-fold cross-validation over
    odd values of *k* from 1 to 21 to identify the optimal number of KNN
    classifier neighbors. Accuracy generally increased with k while
    standard errors shrink as k increases resulting in an optimal k
    = 21.

```r
set.seed(2016751)

# combine into a single data frame
train_df <- knntrain.x |>
  as_tibble() |>
  # merge the outcome
  mutate(hasphone = knntrain.y)

# create 10-fold CV assignments
n_fold <- 10
fold_id <- sample(rep(1:n_fold, length.out = nrow(train_df)))

# odd k values from 1 to 21
k_values <- seq(1, 21, by = 2)

# loop over k values, compute fold accuracy 
cv_results <- map_dfr(k_values, function(k) {
  # compute accuracy within each fold
  fold_acc <- map_dbl(1:n_fold, function(f) {
    train_idx = fold_id != f
    val_idx = fold_id == f
    pred = knn(knntrain.x[train_idx, ], knntrain.x[val_idx, ],
                knntrain.y[train_idx], k = k)
    mean(pred == knntrain.y[val_idx])
  })
  # return mean accuracy & sd across folds
  tibble(k = k, accuracy = mean(fold_acc), sd = sd(fold_acc))
})

# extract optimal k
best_k <- cv_results |> slice_max(accuracy, n = 1) |> pull(k)
best_acc <- cv_results |> slice_max(accuracy, n = 1) |> pull(accuracy)

# print optimal k
tibble(best_k, best_acc) |> kable()
```

```r

# plot k by accuracy with standard errors
cv_results |>
  ggplot(aes(x = k, y = accuracy)) +
  geom_line(color = viridis(3)[2], linewidth = 0.8) +
  geom_point() +
  geom_errorbar(aes(ymin = accuracy - sd, ymax = accuracy + sd),
                width = 0.5, color = viridis(3)[1], alpha = 0.7) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = k_values) +
  scale_color_viridis() +
  labs(title = "Ten Fold CV Accuracy by k",
       x = "Number of Neighbors (k)",
       y = "Accuracy") +
  theme_minimal(base_size = 12)
```

\newpage

### Task B (3 points): Now using the optimal value of k generate a knn model using the training data and then determine the overall accuracy of the model using the knntest.y data.

-   Please use the set.seed(751) before you generate the KNN model.

    -   Hint 1: predobject\<-knn(train.x, test.x, train.y, k=value from
        task A)

    -   Hint 2: overall accuracy computed as: mean(predobject==test.y)

-   We used the optimal k = 21 from Task A and applied the KNN model we
    developed to fit to the full training set. We then evaluated its
    predictive performance on the held-out test data. The model achieved
    an overall test accuracy of 0.568, correctly classifying roughly
    56.8% of the 500 test cases for landline phone availability.

```r
set.seed(751)

# predict test set using optimal k from Task A
pred_B <- knn(knntrain.x, knntest.x, knntrain.y, k = best_k)

# overall test accuracy
acc_B <- mean(pred_B == knntest.y)

tibble(best_k, acc_B) |> kable()
```

\newpage

### Task B2 (2 points): How does this model perform relative to the one that uses model prediction?

-   We assess whether the KNN model learned anything beyond the base
    rate by fitting a `null_model()` that predicts the modal class
    (e.g., mode). The modal class in the training data is "0" (No
    Phone), occurring in about 57% of cases. The null model achieved a
    test accuracy of .546 which the KNN model only marginally
    outpuerforms the modal baseline by 2.2 percentage points, suggesting
    that the KNN classifier effectively reduces to modal prediction by
    failing to extract useful signal from the features.

```r
# create test data frame
test_df <- knntest.x |>
  as_tibble() |>
  mutate(hasphone = knntest.y)

# set up a null model where the mode is used for prediction
null_spec <- null_model() |>
  # the parsnip package provides the null model
  set_engine("parsnip") |>
  set_mode("classification")

# recipe — no preprocessing needed for null model
null_recipe <- recipe(hasphone ~ ., data = train_df)

# add the model spec & recipe to the workflow
null_wf <- workflow() |>
  add_model(null_spec) |>
  add_recipe(null_recipe) |>
  # fit on training set
  fit(data = train_df)

# predict on test set
null_preds <- null_wf |>
  augment(new_data = test_df)

# calculate accuracy on predicted classification
null_preds |>
  accuracy(truth = hasphone, estimate = .pred_class) |>
  # print table
  kable()


```

\newpage

### Task C (2 points): Are the covariates (i.e. variables in knntrain.x) all on the same scale or have the same range? What variables have the widest ranges?

Below we generate a plot to show that covariates vary largely in their
numeric value range, with medhhincome having the largest range.
popnevmarried, numhhs, hsorless, popnotinif, huownerocc, famsasabovpoc,
and hhwithkids also have a wide range of values compared to other
covariates but not nearly as much as medhincome.

```r
#| fig-height: 5
#| fig-width: 7
#| 
# get the range for every variable in the training set
knntrain.x |> 
  summarise(across(where(is.numeric), ~max(.x) - min(.x)) ) |> 
  pivot_longer(everything(), names_to = "Covariates", values_to = "Range") |>
  mutate(Covariates = fct_reorder(factor(Covariates), Range, max) ) |> 
  # build plot
  ggplot(aes(y=Covariates, x=Range, fill=Covariates)) +
  geom_col(fill="dodgerblue", alpha=.7) +
  labs(title = "Covariates Vary in Scale Values",
       x = "Range",
       y = "Covariates") +
  theme_minimal(base_size = 12)


```

\newpage

### Task D (5 points): Repeat Task A using a set of covariates that have been standardized. How does your optimal value of k compare to Task A.

-   PLEASE USE set.seed(2016751) before you perform the 10-fold cross
    validation here!

    -   Hint 1: Note – you don’t need to standardize the y variables
        here! Why?

    -   Hint 2: to standardize the variables in the training/test sets
        use code like this: newx\<-scale(oldx)

-   We standardize the training and test covariates using `scale()` and
    repeat the 10-fold cross-validation process from task A. We do not
    standardize the outcome variable because it is a categorical factor
    (0/1) used as a class label, not as a numeric input to the distance
    calculation. The optimal k decreased from 21 (task A) to 17, and
    accuracy improved from 0.549 to 0.596 — a 4.7 percentage point gain.
    The lower optimal k indicates that when all variables contribute
    equally to the distance metric, fewer neighbors are needed to make
    accurate classifications. This confirms the importance of
    standardizing covariates when they are on different scales, as
    variables like `medhhincome` no longer dominate the distance
    calculation.

```r
set.seed(2016751)

# stand training & test covariates 
knntrain.x.std <- scale(knntrain.x)
knntest.x.std  <- scale(knntest.x)

# reuse same fold assignments from task A 

# loop over k values with standardized covariates
cv_results_std <- map_dfr(k_values, function(k) {
  # compute accuracy within each fold
  fold_acc <- map_dbl(1:n_fold, function(f) {
    train_idx = fold_id != f
    val_idx = fold_id == f
    pred = knn(knntrain.x.std[train_idx, ], knntrain.x.std[val_idx, ],
                knntrain.y[train_idx], k = k)
    mean(pred == knntrain.y[val_idx])
  })
  # return mean accuracy & sd across folds
  tibble(k = k, accuracy = mean(fold_acc), sd = sd(fold_acc))
})

# extract optimal k
best_k_std <- cv_results_std |> slice_max(accuracy, n = 1) |> pull(k)
best_acc_std <- cv_results_std |> slice_max(accuracy, n = 1) |> pull(accuracy)

# print optimal k
tibble(best_k_std, best_acc_std) |> kable()
```

```r

# plot k by accuracy with standard errors
cv_results_std |>
  ggplot(aes(x = k, y = accuracy)) +
  geom_line(color = viridis(3)[2], linewidth = 0.8) +
  geom_point() +
  geom_errorbar(aes(ymin = accuracy - sd, ymax = accuracy + sd),
                width = 0.5, color = viridis(3)[1], alpha = 0.7) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = k_values) +
  scale_color_viridis() +
  labs(title = "Ten Fold CV Accuracy by k",
       x = "Number of Neighbors (k)",
       y = "Accuracy") +
  theme_minimal(base_size = 12)
```

\newpage

### Task E (3 points): Repeat Task B using the standardize set of covariates (also use the seed of 751 here as well).

-   Using the optimal k = 17 from task D, we applied the KNN model with
    standardized covariates to predict the test set outcomes. The test
    accuracy of 0.576 improves on both the unstandardized test accuracy
    from task B (0.568) and the modal prediction baseline (0.546),
    confirming that standardization enables KNN to extract meaningful
    predictive signal from covariates for predicting landline phone
    availability**.**

```r
set.seed(751)

# predict test set using stand covariates & optimal k from task D
pred_E <- knn(knntrain.x.std, knntest.x.std, knntrain.y, k = best_k_std)

# overall test accuracy
acc_E <- mean(pred_E == knntest.y)

tibble(best_k_std, acc_E) |> kable()
```
