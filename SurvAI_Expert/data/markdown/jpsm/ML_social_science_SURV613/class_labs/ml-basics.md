---
id: "jpsm/ML_social_science_SURV613/class_labs/ml-basics"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lab"
title: "ML Basics"
original: "ML_social_science_SURV613/class_labs/ml-basics.Rmd"
pages: 
sha256: "de1c84919de4ec257cb315f5fa18fd92e5a8fb3568eb8866fdaacc3dabf91831"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:09"
---


## Setup

### 

Load needed packages.

```r
library(mlbench)
library(boot)
library(tidymodels)
```

### Data

In this notebook, we use the Boston Housing data set. "This dataset contains information collected by the U.S Census Service concerning housing in the area of Boston Mass. It was obtained from the StatLib archive (<http://lib.stat.cmu.edu/datasets/boston>), and has been used extensively throughout the literature to benchmark algorithms."

Source: <https://www.cs.toronto.edu/~delve/data/boston/bostonDetail.html>

```r
data(BostonHousing2)
boston <- BostonHousing2
head(boston)
```

## Regression in R

### 

In this section, we begin with estimating a fairly simple regression model using the median home value as the outcome and four variables as predictors.

```r
m1 <- glm(medv ~ crim + chas + age + lstat, data = boston)
summary(m1)
```

### 

Some more information about our first model.

```r
anova(m1)
plot(m1)
```

We can use `predict` to compute predicted home values based on our regression model.

```r
boston$pred1 <- predict(m1)
head(boston[,c(5,20)])
```

### 

Next, we fit an extended model that includes `lstat` squared as an additional predictor variable.

```r
m2 <- glm(medv ~ crim + chas + age + lstat + I(lstat^2), data = boston)
summary(m2)
```

### 

Both models were fitted using the full data set. Evaluating the prediction performance of these models on the same data gives us their training error. Here, we compute the training MSE.

```r
mean((predict(m1) - boston$medv)^2)
mean((predict(m2) - boston$medv)^2)
```

## Train and test set

### 

However, to get an estimate of the test error we have to proceed differently. A simple option is to split the data into a train and test set by random. Here we use `sample` to prepare and 80 to 20 percent split.

```r
set.seed(7345)
Boston_split <- initial_split(BostonHousing2, prop = .80, strata = NULL, breaks = 2, pool = 0.1)

```

The resulting object gives us the row positions of the sampled elements. We use these positions to split the data into two pieces.

```r
boston_train <- training(Boston_split)
boston_test <- testing(Boston_split)
```

### 

Now, refit the previous regression model using the training set only.

```r
m3 <- glm(medv ~ crim + chas + age + lstat, data = boston_train)
m4 <- glm(medv ~ crim + chas + age + lstat + I(lstat^2), data = boston_train)
```

On this basis, we use these models to predict home values in the hold-out test set.

```r
pred3 <- predict(m3, newdata = boston_test)
pred4 <- predict(m4, newdata = boston_test)
```

### 

And evaluate the prediction performance in the test set.

```r
mean((pred3 - boston_test$medv)^2)
mean((pred4 - boston_test$medv)^2)
```

## Regression and CV

### 

Another (better) evaluation approach is to use cross-validation. To demonstrate how cross-validation works, we will build our own CV loop by hand. We start by shuffling the data with `sample()` and then create 10 random `folds` (groups).

```r
set.seed(7346)
boston <- boston[sample(nrow(boston)),]
folds <- cut(seq(1, nrow(boston)), breaks = 10, labels = FALSE)
table(folds)

set.seed(7346)
folds_2 <- vfold_cv(boston, v = 10)
```

### 

In the following loop, each group is used as a hold-out fold once per iteration (`test_data`). The other groups (`train_data`) are used to fit the regression model, which is then evaluated on the hold-out fold. This results in 10 test MSEs, one for each iteration.

```r
pred <- rep(NA, nrow(boston))

for(i in 1:10){
    holdout <- which(folds==i)
    test_data <- boston[holdout, ]
    train_data <- boston[-holdout, ]
    
    m <- glm(medv ~ crim + chas + age + lstat, data = train_data)
    pred[holdout] <- predict(m, newdata = test_data)
    print(mean((pred[holdout] - boston$medv[holdout])^2))
}

# experimental for tidymodels
rf_mod <- 
  linear_reg() %>% 
  set_engine("glm", family = stats::gaussian()) %>% 
  translate()

rf_wf <- 
  workflow() %>%
  add_model(rf_mod) %>%
  add_formula(medv ~ crim + chas + age + lstat)

rf_fit_rs <- 
  rf_wf %>% 
  fit_resamples(folds_2)



# Define the recipe
rec <- recipe(qsec ~ hp, data = mtcars)

# Specify the linear regression model
lm_spec <- linear_reg()

# Combine recipe and model specification into a workflow
workflow <- workflow() %>%
  add_recipe(rec) %>%
  add_model(lm_spec)

```

### 

Computing the MSE over all hold-out observations gives us the cross-validated MSE.

```r
mean((pred - boston$medv)^2)
```

### 

Cross-validation is implemented in many R packages, which typically allow more flexibility. For regression, we could e.g. use `cv.glm()` from the `boot` package. The default setting is to run leave-one-out cross-validation. For more information see `?cv.glm`.

```r
cv.err <- cv.glm(boston, m1)
cv.err$delta
```

### 

We could also do 5-fold...

```r
cv.err5 <- cv.glm(boston, m1, K = 5)
cv.err5$delta
```

### 

...or 10-fold CV.

```r
cv.err10 <- cv.glm(boston, m1, K = 10)
cv.err10$delta
```

### 

On this basis, we can now check whether the extended model does not only yield a lower training error, but also performs better when using hold-out sets for model evaluation.

```r
cv.err10.2 <- cv.glm(boston, m2, K = 10)
cv.err10.2$delta
```
