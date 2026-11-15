---
id: "jpsm/ML_social_science_SURV613/assignments/assignment4-1"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "assignment"
title: "Assignment 4: Interpretation and Bias Considerations in ML"
original: "ML_social_science_SURV613/assignments/assignment4-1.Rmd"
pages: 
sha256: "88d0c10c1817e8dae673126e55d6818b94cb67f936d600ba4152c95d5a40598e"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:05"
---


## Setup

```r
library(caret)
library(randomForest)
library(partykit)
library(pdp)
library(iml)
```

## Data

Here we use data from the UCI Machine Learning repository on drug consumption. The data contains records for 1885 respondents with personality measurements (e.g. Big-5), level of education, age, gender, country of residence and ethnicity as features. In addition, information on the usage of 18 drugs is included.

Source: https://archive.ics.uci.edu/ml/datasets/Drug+consumption+%28quantified%29

```r
library(mlforsocialscience)
data(drugs)
```

---

#### 1) Predicting drug usage

**a) Prepare an outcome variable. For this you can choose from the variables on drug consumption and pick one drug (or a combination of drugs) as the prediction objective. The resulting variable should be of class `factor`, but it can have more than two categories if needed.**

```r

```

**b) Next split the data into a training and a test part.**

```r
set.seed(9574)

#inTrain <- createDataPartition(..., 
#                               p = .8, 
#                               list = FALSE, 
#                               times = 1)

# drugs_train <- drugs[inTrain,]
# drugs_test <- drugs[-inTrain,]
```

**c) Specify the evaluation method for the `train()` function of `caret` with 10-fold cross-validation.**

```r

```

**d) Specify a grid object for tuning a random forest model.**

```r

```

**e) Use `train()` from `caret` in order to grow the forest. Do not use any of the other drugs as predictors in this model. Determine the best model based on the tuning results.**

```r

```

---

#### 2) Interpreting the model

**a) Find and create a plot of the variable importances. What are you interpretations of this?**

**b) Create some partial dependence plots. What are your interpretations of these plots?**

```r

```

**c) Create some ICE plots. What are your interpretations of these plots?**

```r

```

**d) What are some possible actions that can be taken using the results of these interpretations?**

---

#### 3) Prediction and Bias

**a) Use `predict()` in order to predict class membership and probabilities in the test set.**

```r

```

**b) Evaluate prediction performance based on two or three measures.**

```r

```

**c) Look at the differences in performance metrics by gender. Are there any possible biases in the predictions?**

```r

```

