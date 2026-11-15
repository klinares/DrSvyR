---
id: "jpsm/ML_social_science_SURV613/assignments/lasso"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "assignment"
title: "Assignment 2"
original: "ML_social_science_SURV613/assignments/lasso.qmd"
pages: 
sha256: "ddff57902b7a6c39673d86de55576c6baa2cda45fe018c9fa4d3a940d5565b8f"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:09"
---


## Setup

```r

pacman::p_load(glmnet, caret, tidymodels, tidyverse)
options(scipen=999)
```

## Data

For this exercise we use the Communities and Crime data from the UCI ML repository, which includes information about communities in the US. "The data combines socio-economic data from the 1990 US Census, law enforcement data from the 1990 US LEMAS survey, and crime data from the 1995 FBI UCR"

Source: https://archive.ics.uci.edu/ml/datasets/Communities+and+Crime

First, some data prep.

-   Read column names into a character vector and assign it as column names to the data frame.

-   Remove columns with missing values.

```r
file_path <- "~/repos/UMD_classes_code/ML_social_science_SURV613/assignments/"

varnames <- read_delim(str_c(file_path, "communities.txt"),
                       col_names = FALSE) |> 
  pull(2)

crime <- read_csv( str_c(file_path, "communities.data"), 
                         na = "?", col_names = varnames) |> 
  select_if(~ !any(is.na(.))) |> 
  # remove features
  select(-state, -communityname, -fold)
```

Check whats left.

```r
skimr::skim(crime)
```

\

## Train and test set

Next, we want to split the data into a training (75%) and a test (25%) part. This can be done by random sampling with `sample`. Note that there is a `fold` variable in the data set, but here we want to follow our own train/test procedure.

```r
set.seed(3940)

crime_split <- initial_split(crime, 
                             prop = .75, breaks = 2)
# train split
crime_train <- training(crime_split)
# test split
crime_test <- testing(crime_split)

```

Now, prepare the training data for running regularized regression models via `glmnet`. Our prediction outcome is `ViolentCrimesPerPop`. As X, use all variables except `state`, `communityname`, and `fold`.

```r
X <-  model.matrix(ViolentCrimesPerPop ~ .,crime_train)
y <- crime_train |> pull(ViolentCrimesPerPop)
```

Check whether X looks ok.

```r
dim(X)
```

\

\newpage

### Lasso

Estimate a sequence of Lasso models using `glmnet`. You can stick with the defaults for choosing a range of lambdas.

```r
m1 <-  glmnet(X, y, alpha = 1)
```

Here we want to display lambda and the coefficients of the first and last Lasso model.

```r
# lambda value
cat(str_c(
  "Lambda for the first LASSO model is ", round(m1$lambda[1], 6), 
  "\nand Lambda for the last LASSO model is ", 
  round(tail(m1$lambda, n=1), 6)
) )

# coefficients
m1$beta |>   
  as.matrix() |> 
  as.data.frame() |> 
  rownames_to_column() |>
  select(1:2, last_col(0)) |> 
  rename(first_LASSO = 2, last_LASSO = 3) |> 
  mutate_at(vars(2, 3), round, 6)
```

Now, plot the coefficient paths.

```r
plot(m1, label=T,  xvar = "lambda")
```

\newpage

### Cross-validation (CV), tuning the Lambda grid to find best models

Next, we need to decide which Lasso model to pick for prediction. Use CV for this.

```r
m1_cv <- cv.glmnet(X, y, alpha = 1)
```

And plot the Cross-validation results.

```r
plot(m1_cv)
```

In your own words, briefly describe the CV plot. (1) What is plotted here, (2) what can you infer about the relation between the number of variables and prediction accuracy?

-   Here we plot the CV curve denoted by the red dotted line along with error bars across the lambda values, also known as the lambda grid. The dotted vertical lines represent the lowest lambda value which gives us the minimum mean CV error, and the second provides us the lambda value that gives the most regularized model resulting in a CV error within one standard error from the minimum lambda value. Consequently, these two proposed lambda values are reasonable tuning parameters for choosing a trained model to estimate testing errors and compare. The numbers above represents non-zero coefficient estimates. We can infer that having more features does not improve training accuracy as we would expect a U-shape. Instead, we suggest that only a proportion of features contribute to the training accuracy here to a certain point as after decreasing features after 10 we observe an increase in the training MSE.

Now, store the lambda value of the model with the smallest CV error as `bestlam1`.

```r
bestlam1 <- m1_cv$lambda.min
```

Create `bestlam2` as the lambda according to the 1-standard error rule.

```r
bestlam2 <- m1_cv$lambda.1se
```

### Prediction in test set

Finally, we investigate the performance of our models in the test set. For this task, construct a X matrix from the test set.

```r
Xt <- model.matrix(ViolentCrimesPerPop ~ ., crime_test)
```

Use the `predict` function to generate predicted values for both models (i.e., both lambdas stored earlier).

```r
p_lasso_min <- predict(m1, s = bestlam1, newx = Xt) 
p_lasso_1se <- predict(m1, s = bestlam2, newx = Xt) 
```

Compute the test MSE of our models.

```r
mean((p_lasso_min - crime_test$ViolentCrimesPerPop)^2)
mean((p_lasso_1se - crime_test$ViolentCrimesPerPop)^2)
```

In addition, use another performance metric and compute the corresponding values for both models.

```r
postResample(p_lasso_min, crime_test$ViolentCrimesPerPop)
postResample(p_lasso_1se, crime_test$ViolentCrimesPerPop)
```

Which model is better? Does it depend on the performance measure that is used?

-   We compare two models, the model with the minimum CV error and the model with the CV error within one standard error fromo the minimum error value. We determine that the smallest CV error LASSO model had a slightly lower (R)MSE than the 1SE model at the cost of having 43 more features making it the more complicated model. Additionally, we used a second performance measures $R^2$ and also observe that the smallest CV error model had a slightly higher r-squared value of .65, compared to the second model, .63. These models are similar on performance measures, yet we are inclined to pick the model with the lowest test error (minimum CV error) based on these two performance measures which corroborate each other. However, given that these model performance measures are almost similar, we would not be wrong to pick the 1SE model on the basis that it is more parsimonious, less features.

\newpage

# Tidy Remix: Using the tidy-workflow for LASSO

\

### We begin our workflow by loading the tidymodels suite of packges and create a recipe of our model.

-   We can scale and center features, but for the sake of matching the example above we will comment out these arguments.

```r

# define the model with recipes 
crime_rec <- recipe(ViolentCrimesPerPop ~ ., 
                     # specify trainig data from before
                    data = crime_train) |>
  # assign all features as numeric
  step_zv(all_numeric(), -all_outcomes()) #|> 
  # center & scale
  #step_normalize(all_numeric(), -all_outcomes())

crime_rec # prints information about the data

```

\

Next we define the type of model we want to fit to our data, in this case LASSO and set the engine to glmnet which we used earlier. By assigning mixture =1, we specify a LASSO model where mixture=0 would be a ridge model.

```r
# build spec
lasso_spec <-  linear_reg(penalty = tune(), mixture = 1) |> 
  set_mode("regression") |> 
  set_engine("glmnet") 

lasso_spec 
```

\

We now create our modeling workflow. This will allow us to store modeling information, fit, and use to make predictions on the test set.

```r
# convinience function set up workflow
## can add a model to it, used for setting up modular analyis
wf <- workflow() |> 
  add_recipe(crime_rec)

wf # prints information to be used in modeling
```

\newpage

## Once we have our workflow, we can now begin training the model on data.

```r
# we can train the model with our workflow
lasso_fit <- wf |> 
  add_model(lasso_spec) |> 
  fit(data=crime_train)

```

As before, we want to print the first last model's lambda values which we can use the parsnip::extract_fit_engine() to get these values out of the fit object, and than pass it through the yardstick::tidy() to allow us to work with these values.

```r
lasso_fit |> 
  extract_fit_engine() |> 
  tidy() |> 
  select(lambda) |> 
  filter(row_number() %in% c(1, n())) |> 
  mutate_all( round, 6)
  
```

\

We can also subset coefficient beta values for any LASSO model using the parsnip::extract_fit_engine(). Here we show the first and last LASSO beta coefficients to match the previous process above.

```r
lasso_fit |> 
    extract_fit_engine() |> 
    tidy() |> 
  select(term, step, estimate) |> 
  pivot_wider(names_from = step, values_from = estimate) |> 
  select(1:2, last_col(0)) |> 
  # convert NA to 0s
  mutate_at(vars(2, 3), replace_na, 0) |> 
  # drop intercept
  filter(term != "(Intercept)") |> 
  rename(first_LASSO = 2, last_LASSO = 3) |> 
  mutate_at(vars(2, 3), round, 6)

  
```

#### We plot the coefficient paths as before, the only difference is that workflowsets::autoplot() transforms lambda from the natural log for us. 

```r
lasso_fit |>
  extract_fit_parsnip() |> 
  autoplot()
```

\newpage

## Tuning the penalty term to find optimal lambda using cross validation.

#### We start by taking a 10 fold of our training set using the rsample::vfold_cv().

```r
crime_cv <- rsample::vfold_cv(crime_train, v=10)
```

We want to set the spacing for lambda using dials::grid_regular(). The levels argument is the number of parameters to use in the grid.

```r
lamda_grid <- grid_regular(penalty(), levels=100)
```

Now we can tune the lambda grid with our cross validation approach while doing this in parallel.

```r

doParallel::registerDoParallel()

# tune the lambda grid
lasso_grid <- tune_grid(
  wf |> add_model(lasso_spec),
  resamples=crime_cv,
  grid=lamda_grid
)

```

Finally in this step, we want to visualize training error performance as before. The only difference is that instead of plotting log(lambda) we can plot RMSE and the bottom plot shows the amount of regularization affecting the performance metric.

-   The tune::collect_metrics() will give us a table with performance training measures for 100 model candidates.

-   We can see the impact of different values of regularization on the MSE below.

```r

# visualize model training
lasso_grid |> 
  tune::collect_metrics() |> 
  ggplot(aes(penalty, mean, color=.metric)) +
  geom_ribbon(aes(ymin = mean - std_err, ymax = mean + std_err, 
                  fill=.metric), alpha=.2) +
  geom_line(size=1.5) +
  facet_wrap(~.metric, scales="free", nrow=2) +
  scale_x_log10() +
  theme(legend.position = "none")

```

\newpage

## Test error, following optimal tuning parameter

### We are now ready to calculate MSE as before, by first finding the minimal lambda value and 1SE from minimal.

```r
tidy_bestlam1 <- select_best(lasso_grid, metric="rmse")
```

#### We can now finalize our workflow. 

```r
lasso_final <- finalize_workflow(wf |> add_model(lasso_spec), tidy_bestlam1)
lasso_final_fit <- fit(lasso_final, data = crime_train)

```

#### We finalize the first model and show below that we get a near identical MSE as before, and RMSE. Additionally we print r-square and observe a near identical value as before. 

```r
augment(lasso_final_fit, new_data = crime_test) |> 
  rmse(truth = ViolentCrimesPerPop, estimate = .pred) |> 
  mutate(MSE = .estimate^2)

augment(lasso_final_fit, new_data = crime_test) |> 
  rsq(truth = ViolentCrimesPerPop, estimate = .pred) 
```

\

We can also take the same process to show how the second model, 1SE performs.

-   Again we see a similar MSE value as before along with a similar RMSE, but not exact. Same for the r-square.

```r
tidy_bestlam2 <- select_by_one_std_err(lasso_grid, metric = "rmse", desc(penalty))


lasso_final <- finalize_workflow(wf |> add_model(lasso_spec), tidy_bestlam2)
lasso_final_fit <- fit(lasso_final, data = crime_train)

augment(lasso_final_fit, new_data = crime_test) |> 
  rmse(truth = ViolentCrimesPerPop, estimate = .pred) |> 
  mutate(MSE = .estimate^2)

augment(lasso_final_fit, new_data = crime_test) |> 
  rsq(truth = ViolentCrimesPerPop, estimate = .pred) 
```

\newpage

## Bonus round, we can also examine feature importance using the vip package. 

-   Here we use the 1SE model, most parsimonious, and see the top features the model elected for us.

    -   We only print below important features to the model.

```r


library(vip)


# variance selection, feature importance
lasso_final_fit |> 
  pull_workflow_fit() |> 
  vip::vi(lambda = tidy_bestlam2$penalty) |> 
  mutate(Imporatnce = abs(Importance),
         Variable = fct_reorder(Variable, Importance)) |> 
  filter(Importance >=.0001) |> 
  ggplot(aes(x=Importance, y=Variable, fill=Sign)) +
  geom_col(show.legend = FALSE) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = NULL)

```
