---
id: "jpsm/ML_social_science_SURV613/assignments/cross_validation"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "assignment"
title: "Assignment 1"
original: "ML_social_science_SURV613/assignments/cross_validation.qmd"
pages: 
sha256: "8ede0d48760c602ef10f28eea89b43cbf1ee54ac055c6272a0462f7d98346a98"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:05"
---


## Setup

```r

pacman::p_load(titanic, caret, pROC, jtools, tidymodels)
options(scipen=999)
```

## Data

In this notebook we use the Titanic data that is used on Kaggle (<https://www.kaggle.com>) as an introductory competition for getting familiar with machine learning. It includes information on a set of Titanic passengers, such as age, sex, ticket class and whether he or she survived the Titanic tragedy. Source: <https://www.kaggle.com/c/titanic/data>

```r
titanic <- titanic_train |> as_tibble()
glimpse(titanic)
```


## We begin with some minor data preparations. The `lapply()` function is a handy tool if the task is to apply the same transformation (e.g. `as.factor()`) to multiple columns of a data frame.

```r
titanic <- titanic |> mutate_at(vars(2, 3, 5, 12), factor)
```

-   The `age` variable has some NAs, as a quick and dirty solution we can create a categorized age variable with NAs as an additional factor level.

```r
titanic <- 
  titanic |> 
  mutate(Age_c = cut(Age, 5), Age_c = addNA(Age_c))

# print summary of new age category variable with NA level
titanic |> pull(Age_c) |> summary()
```

## Train and test set

-   Next we split the data into a training (80%) and a test (20%) part. This can be done by random sampling with `sample()`.

```r
set.seed(9395)
# we use the rsample package to expand on this in later assignments.
titanic_split <- initial_split(titanic, prop = .80, breaks = 2)

# train split
titanic_train <- training(titanic_split)

# test split
titanic_test <- testing(titanic_split)
```

\

## Logistic regression

-   In this exercise we simply use logistic regression as our prediction method, since we want to focus on the evaluation part. Build a first logit model with `Survived` as the outcome and `Pclass`, `Sex`, `Age_c`, `Fare` and `Embarked` as features.

```r
m1 <- glm(Survived ~ Pclass + Sex + Age_c + Fare + Embarked, 
          data = titanic_train, family = "binomial")
```

-   A quick look at the coefficients of the first logit model.

```r
summ(m1)
```

-   Now, build an additional logit model that uses the same features, but includes at least one interaction or non-linear term.

```r
m2 <- glm(Survived ~ Pclass*Sex + Age_c + Fare + Embarked, 
          data = titanic_train, family = "binomial")
```

-   Again, summarize the resulting object.

```r
summ(m2)
```

\

##  Prediction in test set

-   Given both logit objects, we can generate predicted risk scores/ predicted probabilities of `Survived` in the test set.

```r
pred1 <- predict(m1, newdata = titanic_test, type="response")
pred2 <- predict(m2, newdata = titanic_test,  type="response")
```

-   It is often useful to first get an idea of prediction performance independent of specific classification thresholds. Use the `pROC` (or `PRROC`) package to create roc objects for both risk score vectors.

```r
# create roc object for m1
roc_m1 <- roc(titanic_test$Survived, pred1) 

# create roc object for m2
roc_m2 <- roc(titanic_test$Survived, pred2) 
```

-   Now, you can print and plot the resulting `roc` objects.

```r
# plot ROC curves
ggroc(list(roc_m1, roc_m2), aes = c("colour", "linetype"),
            legacy.axes = TRUE,
            linewidth = 0.4) +
  scale_linetype_manual("", values=c(2, 1),
                        labels = c("No Interaction", 
                                   "W/ interaction")) +
  scale_colour_manual("", 
                      labels = c("No Interaction", 
                                 "W/ interaction"), 
                      values = c("dodgerblue",
                                 "forestgreen")) +
  theme_bw() +
  ggtitle("ROC AUC for two Logit models")

roc_m1
roc_m2
```



## In your own words, how would you interpret these ROC curves? What do you think about the ROC-AUCs we observe here?

-   The Area Under the Receiver Operating Characteristic curve (AUC) helps us compare different predictive models by illustrating the trade-off between sensitivity (correctly identifying actual survivors) and specificity (correctly identifying those who did not survive). Our two models, one with and one without an interaction term between gender and passenger class, have similar AUCs of 0.817 and 0.825, respectively. A higher AUC indicates better performance in distinguishing survivors from non-survivors. Both models demonstrate the typical inverse relationship between sensitivity and specificity: high specificity corresponds to sensitivity around 0.5, and vice-versa, high sensitivity corresponds to specificity near 0.

-   Since our goal is to effectively allocate limited resources to passengers unlikely to survive, we should prioritize specificity. Accurately identifying non-survivors (true negatives) is crucial. While a high threshold may risk misclassifying some survivors (false negatives), this is less detrimental than misclassifying those unlikely to survive (false positives). Therefore, we aim for high specificity. A specificity threshold of 0.85 appears reasonable, and both models suggest this would yield a sensitivity of approximately 0.70. This means we'd correctly identify 85% of those who did not survive, while still correctly identifying 70% of actual survivors.



## As a next step, we want to predict class membership given the risk scores of our two models. Here we use the default classification threshold, 0.5.

```r
# build function to predict based on threshold, & produce confusionmatrix
pred_class_member_fun <- function(roc_object, threshold_level, 
                                  predictions, test_set) {
  # set threshold
  coords = coords(roc_object, threshold_level)
  threshold_used = coords$threshold
  
  message(cat("Optimal threshold based on ROC curve:", threshold_used, "\n"))
  
  # Predict classes based on threshold
  predicted_class = ifelse(predictions >= threshold_used, 1, 0)
  
  # Evaluate model performance
  confusion_matrix = table(test_set, predicted_class)
  return(confusionMatrix(confusion_matrix))
}

```

-   On this basis, we can use `confusionMatrix()` to get some performance measures for the predicted classes.

```r

# first model
m1_performance <- pred_class_member_fun(roc_object = roc_m1, 
                      threshold_level = .5,
                      predictions = pred1,
                      test_set = titanic_test |> pull(Survived))

print(m1_performance)


m2_performance <- pred_class_member_fun(roc_object = roc_m2, 
                      threshold_level = .50,
                      predictions = pred2,
                      test_set = titanic_test |> pull(Survived))

print(m2_performance)

```

\

## Briefly explain potential limitations when measuring prediction performance as carried out in the last two code chunks.

-   Perhaps the greatest risk or limitation to measuring prediction performance in this way is that a practitioner can manipulate the threshold value until a performance metric of interest is satisfied. This would be comparable to p-hacking in statistics. Other considerations are that if there is imbalance in the data, we have to closely consider which metric to use and report. For instance, we there is imbalance and our model has high accuracy, we may be able to predict correctly 100% of the time, but less so predicting the lower class which may be more important to the intervention. A third limitation is that confusionmatrices with threshold dependency treats errors equally, but in some instances a false negativemay be more problematic than a false positive such as in cancer diagnostics.
