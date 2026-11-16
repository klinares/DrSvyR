---
id: "jpsm/ML_social_science_SURV613/assignments/xgboost"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "assignment"
title: "Assignment 3"
original: "ML_social_science_SURV613/assignments/xgboost.qmd"
pages: 
sha256: "d9f5a42b847f4e9e33fff8d651ebaaaa5125b76111c8262e8d35c387857fdac9"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:09"
---


## Setup

```r

pacman::p_load(knitr, randomForest, caret, caretEnsemble, rpart, tictoc, 
              mlbench, partykit, xgboost, finetune, tidymodels, baguette,
              doFuture, parallel, tidyverse )

```

## Data

In this notebook, we use the Boston Housing data set (again). "This dataset contains information collected by the U.S Census Service concerning housing in the area of Boston Mass. It was obtained from the StatLib archive (<http://lib.stat.cmu.edu/datasets/boston>), and has been used extensively throughout the literature to benchmark algorithms."

Source: <https://www.cs.toronto.edu/~delve/data/boston/bostonDetail.html>

```r
data(BostonHousing2) 
names(BostonHousing2) |> kable()
```

First, we drop some variables that we will not use in the next sections.

```r
BostonHousing2 <- BostonHousing2 |> 
  tibble() |> 
  select(-town, -tract, -cmedv) 
```

Next, we start by splitting the data into a train and test set.

```r
set.seed(1293)

boston_split <- initial_split(BostonHousing2, prop = .80, breaks = 2)
boston_train <- training(boston_split) # train split
boston_test <- testing(boston_split) # test split
```

------------------------------------------------------------------------

#### 1) Bagging with Trees

**a) Build a Bagging model using a `foreach` loop. Use the `maxdepth` control option to grow very small trees. These don't have to be stumps, but should not be much larger than a few splits.**

-   We grow 100 trees with a maxdepth of 2 and fit random samples of the training set.

```r
set.seed(1293)

# build 100 trees
y_tbag <- map(1:100, ~
   rpart(medv ~ .,
               data = boston_train |> 
           # sample N length from data set
                sample_n(size = n(), replace = TRUE ),
               method = "anova",
               # controls
               control=rpart.control(
                 cp = 0.001,
                 maxdepth=2)) 
)

```

**b) Plot the last tree of the ensemble to check tree size.**

-   We plot the last tree using the party package and see that the tree depth size is 2 as we specified.

```r
plot.party(as.party(last(y_tbag)), gp = gpar(fontsize = 8))
```

**c) Compare the performance of the last tree in the bagging process with the ensemble. That is, look at the performance of the last tree in the loop and compare it with the performance in the overall averaged bagging model.**

-   We observe an RMSE of more than 5.0 for a tree of a max tree-depth of 2, and an RMSE of a little over 4.0 for the ensemble. 

```r
# last tree
results_bag_last <- postResample(predict(last(y_tbag), newdata = boston_test), 
                                  boston_test$medv)

results_bag_last

```

------------------------------------------------------------------------


```r

ensemble_prediction <- map(1:100, function(m_tree){
  predict(y_tbag[m_tree], newdata=boston_test)
}) |> 
  bind_rows() |> 
  colMeans()

results_bag_small <- postResample(ensemble_prediction, boston_test$medv)

results_bag_small
```



\newpage

#### 2) Bagging with Bigger Trees

**a) In the first loop we've grown small trees. Now, build a new loop and adjust `maxdepth` such that very large trees are grown as individual pieces of the Bagging model.**

-   We try a maxdepth of 8, 4 times larger than the last ensemble.
```r
set.seed(1293)

y_tbag_big <- map(1:100, ~
   rpart(medv ~ .,
               data = boston_train |> 
                sample_n(size = n(), replace = TRUE ),
               method = "anova",
               # controls
               control=rpart.control(
                 cp = 0.001,
                 maxdepth=8)) 
)
```

**b) Confirm that these trees are larger by plotting the last tree.**

```r
#| fig-width: 8
#| fig-height: 4
#| 
plot.party(as.party(last(y_tbag_big)), gp = gpar(fontsize = 8))
```

**c) Show how this ensemble model performs.**

```r
ensemble_prediction_big <- map(1:100, function(m_tree){
  predict(y_tbag_big[m_tree], newdata=boston_test)
}) |> 
  bind_rows() |> 
  colMeans()

results_bag_big <- postResample(ensemble_prediction_big, boston_test$medv)

results_bag_big
```


\ 

**d) In summary, which setting of `maxdepth` did you expect to work better? Why?**

-   Using a bigger tree, maxdepth of 8, provided us with a smaller RMSE difference of `r results_bag_small[[1]] - results_bag_big[[1]]` between the smaller ensemble with a maxdepth of 2. The $R^2$ in the larger tree ensemble was `r scales::percent(results_bag_big[[2]] - results_bag_small[[2]])` higher. We had expected the deeper interactions to have better performance given that it allows for more complex relationships to interact which here it made a difference. Recall that bagging minimizes variance in the model, and deeper trees should essentially smooth out predictions. However, too deep trees risks overfitting the model to the data and more complex models. 




\newpage

------------------------------------------------------------------------

#### 3) Building a Boosting Model with XGBoost

**a) Now let's try using a boosting model using trees as the base learner. Here, we will use the XGBoost model. First, set up the `trainControl` parameters.**

```r
set.seed(1293)

ctrl <- trainControl(method = "cv", # cross validation
                     number = 5, # how many folds
                     verboseIter = FALSE, # no training log
                     allowParallel = TRUE) # parallel processing
```

**b) Next, set up the tuning parameters by creating a grid of parameters to try.**

```r
grid <- expand.grid(# Number of iterations (trees for classification
  nrounds = seq(500, 3000, 1000),
  max_depth = seq(3, 6, 1), # max tree depth
  eta = seq(.001, .04, .01), # learning rate
  min_child_weight = seq(5, 15, 5), # min leaf weight
  subsample = 1,# row sampling 
  gamma = 0, # tuning regularization, default 0
  # linear gradient boosting, we can control regularization tuning 
  #lambda =0, # contols L2 regularization, ridge
  #alpha = 1, # controls L1 regularization, lasso
  colsample_bytree = 1)

```

**c) Using CV to tune, fit an XGBoost model.**


```r
tic()
set.seed(8303)

xgb <- train(medv ~ .,
             verbose=FALSE,
             verbosity = 0,
             data = boston_train,
             method = "xgbTree",
             trControl = ctrl,
             tuneGrid = grid,
             metric = "RMSE")
toc()
```

-   Here we plot the tuning results for the xgboost ensemble model. RMSE is on the y axis, and iterations on the x-axis.

    -   We do not observe much reduction in RMSE from maxdepth 3-6.

    -   Shrinkage seems to be similar, except for .001 which does not catch up until closer to 2500 iterations.

    -   Between 1500-2000 iterations is sufficient.

```r
#| fig-width: 6
#| fig-height: 8
#| 
plot(xgb)
```

**d) Compare the performance of the boosting model with the models run previously in this assignment. How does it compare?**


```r
results_boost <- postResample(predict(xgb, newdata = boston_test),
                                    boston_test$medv)

results_boost
```


-   We compare our xgboost model against our bagging with a maxdepth of 8 (the better of the two bagging models) and observe that the xgboost model reduces the RMSE by almost `r results_bag_big[[1]] - results_boost[[1]]`, and increases the $R^2$ = `r scales::percent(results_boost[[2]] - results_bag_big[[2]])`.


```r
best_tune <- xgb$bestTune ; best_tune
```


-   We see that our best performing trained model had a maxdepth of `r best_tune[[2]]` and an eta of `r best_tune[[3]]`, with `r best_tune[[1]]` iterations.


------------------------------------------------------------------------

\newpage 

#### 4) Comparing Models with `caretList`

**a) Use `caretList` to run a Bagging model, a Random Forest model, and an XGBoost model using the same CV splits with 5-fold CV. Plot the performance by RMSE. How do the models compare?**

Putting the models together.

-   We use tighter tuning parameters informed by the previous boosting model for the new boost model.

```r
# use the same CV across models
set.seed(1293)
cv_folds <- createFolds(boston_train$medv, k=5, returnTrain = TRUE)


ctrl <- trainControl(method = "cv",
                     number = 5,
                     allowParallel = TRUE,
                     index = cv_folds)


ncols <- ncol(boston_train)
mtrys <- expand.grid(mtry = c(sqrt(ncols)-2,sqrt(ncols),sqrt(ncols)+2))

grid <- expand.grid(
  nrounds = xgb$bestTune$nrounds,
  max_depth =xgb$bestTune$max_depth, 
  eta = xgb$bestTune$eta,
  min_child_weight = xgb$bestTune$min_child_weight, 
  subsample = 1,
  gamma = 0, 
  colsample_bytree = 1)

```

```r

rbagmod <- caretModelSpec('treebag', nbagg = 100)
rfmod <- caretModelSpec('rf', tuneGrid = mtrys) # default n_trees 500
xgbmod <- caretModelSpec('xgbTree', tuneGrid = grid) # default n_trees 500

models_and_parameters <- list(rbagmod, rfmod, xgbmod)

set.seed(909)
tic()

model_list <- caretList(medv ~ .,
                        data = boston_train,
                        trControl = ctrl,
                        metric = 'RMSE',
                        tuneList = models_and_parameters,
                        verbosity=0)

dotplot(resamples(model_list), metric = 'RMSE')

toc()

model_list 
```

```r

postResample(predict(model_list$treebag, newdata = boston_test), boston_test$medv)
postResample(predict(model_list$rf, newdata = boston_test), boston_test$medv)
postResample(predict(model_list$xgb, newdata = boston_test), boston_test$medv)

```

- We see that the radom forest model has the lowest RMSE and highest  $R^2$, in other words better performance than the bagging and boosting models. 





\newpage


## __Bonus: using tidymodels for bagging, random forest, and xgboosting__

Let's create a CV of 5 using the same seed as before.

```r
set.seed(1293)

cv_split <- vfold_cv(boston_train, v=5)
```

\

__Bagging Model__

Recall that bagging is similar to random forest and we can set the mtrys to = p, number of predictors, which we can specific with parsnip::.cols(). 

-   Specify the regression model for the data with 100 iterations.

-   Create a workflow along with the regression formula.

-   Resample with cross validation and save the metrics to use next.


```r
# model
bag_mod <- rand_forest(mtry = .cols()) |> 
  set_engine("randomForest", trees = 500) |> 
  set_mode("regression")

# workflow
bag_wf <- workflow() |> 
  add_model(bag_mod) |> 
  add_formula(medv ~ .)

# resample
set.seed(1293)
tic()
bag_res <- bag_wf |> fit_resamples(cv_split, 
                                   metrics = metric_set(rmse, rsq),
              control = control_grid(save_pred = TRUE))
toc()
```


\ 

Now we can evaluate the performance of the trained model based on the RMSE and $R^2$. The workflowsets::collect_metrics collects the RMSE across the folds. 

```r
collect_metrics(bag_res)
```

\

Finally, we use the trained bagging model to predict the test set and observe the test error. For bagging models we aggregate predictions usign the collect_predictions, and use the rmse() and rsq() from the tune package to estiamte the test error. 

```r
collect_predictions(bag_res) |> rmse(truth = medv, estimate = .pred) |> 
  add_row(
    collect_predictions(bag_res) |> rsq(truth = medv, estimate = .pred)
  )

```


\

We can also plot the predicted values against the observed. 
```r
collect_predictions(bag_res) |> 
  ggplot(aes(medv, .pred)) +
  geom_abline(color = "dodgerblue") +
  geom_point(alpha = 0.5) +
  ggthemes::theme_hc()
```


\newpage

__Random Forest Model__

We use the previous workflow only this time we take mtrys = $\frac{p}{3} \pm 1$. The difference here is that we create a tuning grid and tune the model with multiple mtrys and minimum node samples. 


```r
p <- boston_train |> select(-medv) |> ncol()/3 # num of predictors

mtrys <- seq(p-1, p+1, 1) # provide range of predictors to tune


# model
rf_mod <- rand_forest(mtry = tune(), min_n = tune()) |> 
  set_engine("randomForest", trees = 500) |> 
  set_mode("regression")

# workflow
rf_wf <- workflow() |> 
  add_model(rf_mod) |> 
  add_formula(medv ~ .)

# create tuning grid
rf_grid <- grid_regular(
  mtry(range = c(min(mtrys), max(mtrys))), # how many mtryes
  min_n(range = c(5, 10)) # min observations to split node
) 

set.seed(1293)
tic()

registerDoFuture()
cl <- parallel::makeCluster(detectCores() - 1)
plan(cluster, workers = cl)

# tune model
rf_res <- tune_grid(
  rf_wf,
  resamples = cv_split,
  grid = rf_grid,
  control = control_grid(parallel_over = "resamples", save_pred = TRUE)
)

#stopCluster(cl)

toc()
```


\

We evaluate the tuning parameters.

```r
collect_metrics(rf_res)
```

Which we can extract the best tuning parameters that reduce the training error.
```r
rf_best_train <- show_best(rf_res, metric="rmse") |> 
  slice(1)

rf_best_train
```

We can now take our best tuned random forest training model and predict the test set to observe the test error. 
```r
rf_pred <- collect_predictions(rf_res) |> 
  filter(mtry %in% rf_best_train$mtry,
         min_n %in% rf_best_train$min_n)

rf_pred |> rmse(truth = medv, estimate = .pred) |> 
  add_row(
    rf_pred |> rsq(truth = medv, estimate = .pred)
  )
```

```r
rf_pred |> 
  ggplot(aes(medv, .pred)) +
  geom_abline(color = "dodgerblue") +
  geom_point(alpha = 0.5) +
  ggthemes::theme_hc()
```






\newpage

__XGBOOST Modeling__

We build an xgb model to tune on the training sets, and tidymodels allows us to use optimial tuning parameters from the tune package.

```r


# create a recipe
xgb_rec <-
 recipe(medv ~ ., data = boston_train) |>
  step_dummy(all_nominal_predictors(), one_hot=TRUE)



# define parmeters to tune in the xgb
xgb_mod <-
   boost_tree(# create tuning grid
     tree_depth = tune(), # number of splits 
     mtry = tune(),#tune(),
     learn_rate = tune(), # shrinkage
     loss_reduction = tune(), # reduction in the loss function required to split
     trees = tune(), # trees contained in ensemble
     min_n = tune()) |> # classification for binary data
   set_engine("xgboost"#,
            # tree_method = 'gpu_hist' # for computing w/ GPU
              ) |> 
  set_mode("regression")




tic()

registerDoFuture()
cl <- parallel::makeCluster(detectCores() - 1)
plan(cluster, workers = cl)

set.seed(1293)
 
# tune model
xgb_res <- tune_grid(
  xgb_mod,
  xgb_rec,
  resamples = cv_split,
 metrics=metric_set(rmse, rsq),
 grid=60,
  control = control_grid(allow_par = TRUE,
                         parallel_over = "resamples",
                         save_pred = TRUE)
)


toc()
```


```r

xgb_best <- show_best(xgb_res, metric="rmse")
xgb_best

```

We print the top models and observe the RMSE. We are looking for a model that minimizes the training error but is as parsimonious as possible. Here we choose the third model as it has good tuning parameters such as a max tree depth of `r xgb_best[[3,4]]`, and a shrinkage of `r xgb_best[[3,5]]`, a minimum node sample of `r xgb_best[[3,3]]`, and finally an RMSE of `r xgb_best[[3,9]]`.


We can further tune these parameters using a Bayesian optimization approach, but first we need to re-train using specific tuning values.
```r

# change parameter estimates based on previous model results
# define parmeters to tune in the xgb
xgb_mod <-
   boost_tree(# create tuning grid
     tree_depth = 6, # number of splits 
     mtry = 5,# change to reflect last model tuning parameter
     learn_rate = tune(), # shrinkage
     loss_reduction = tune(), # reduction in the loss function required to split
     trees = tune(), # trees contained in ensemble
     min_n = tune()) |> # classification for binary data
   set_engine("xgboost") |> 
  set_mode("regression")


# bayes tuning on 4 parameters with fixed mtry and tree_depth
tic()
registerDoFuture()
cl <- parallel::makeCluster(detectCores() - 1)
plan(cluster, workers = cl)

set.seed(1293)

# initial value should be > than tuning parameters being optimized
xgb_init <- tune_bayes(xgb_mod, xgb_rec, cv_split, initial = 6,
                        control = control_bayes(allow_par = TRUE,
                         parallel_over = "resamples",
                         save_pred = TRUE))

toc()
xgb_best_final <- show_best(xgb_init, metric = "rmse")
xgb_best_final

```


We finalize the xgboost model and observe the test error. 
```r
# choose final model
xgb_best_final <- xgb_best_final |> slice(1)

xgb_pred <- collect_predictions(xgb_init) |> 
  filter(trees %in% xgb_best_final$trees,
         min_n %in% xgb_best_final$min_n,
         learn_rate %in% xgb_best_final$learn_rate,
         loss_reduction %in% xgb_best_final$loss_reduction
           )

xgb_pred |> rmse(truth = medv, estimate = .pred) |> 
  add_row(
    xgb_pred |> rsq(truth = medv, estimate = .pred)
  )
```


Finally we plot the test predictions vs observed. 
```r
xgb_pred |> 
  ggplot(aes(medv, .pred)) +
  geom_abline(color = "dodgerblue") +
  geom_point(alpha = 0.5) +
  ggthemes::theme_hc()
```
