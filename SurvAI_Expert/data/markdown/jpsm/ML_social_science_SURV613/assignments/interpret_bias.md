---
id: "jpsm/ML_social_science_SURV613/assignments/interpret_bias"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "assignment"
title: "Assignment 4: Interpretation and Bias Considerations in ML"
original: "ML_social_science_SURV613/assignments/interpret_bias.qmd"
pages: 
sha256: "b8e9fbee03ae6665e7b96370aa8a949840739ab412b121701622249101167643"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:09"
---


## 

```r

knitr::opts_chunk$set(warning = FALSE, 
                      message = FALSE, error = FALSE, comment = FALSE)

# load packages
library(rsample)
library(caret)
library(randomForest)
library(ranger)
library(knitr)
library(viridis)
library(ggthemes)
library(iml)
library(DALEX)
library(PRROC)
library(pROC)
library(patchwork)
library(ConfusionTableR)
library(gridExtra)
library(mlforsocialscience)
library(pdp)
library(furrr)
library(tidyverse)

options(scipen=999)

# ________________________ Helpful functions _________________



 cm_metric_fun <- function(dat, gender_name){
   
   subset_dat <- dat |> 
     filter(Gender %in% gender_name) |> 
     # truth should go first, predicted 2nd
     select(outcome, predictions) |> 
     rename(predictor = 2)
   
  cm_ob = binary_class_cm(subset_dat$outcome, 
                        subset_dat$predictor,
                        positive="yes")
   
  result = cm_ob$record_level_cm |> 
   tibble() |> 
   select(contains(c("recall", "f1"))) |> 
   pivot_longer(everything()) |> 
   mutate(Gender = gender_name) |> 
   rename(score=value, metric=name)
  
  return(result)
 }
 
```

## Data

Here we use data from the UCI Machine Learning repository on drug consumption. The data contains records for 1885 respondents with personality measurements (e.g. Big-5), level of education, age, gender, country of residence and ethnicity as features. In addition, information on the usage of 18 drugs is included. [Source](https://archive.ics.uci.edu/ml/datasets/Drug+consumption+%28quantified%29)

-   Participants were questioned concerning their use of 18 legal and illegal drugs (alcohol, amphetamines, amyl nitrite, benzodiazepine, cannabis, chocolate, cocaine, caffeine, crack, ecstasy, heroin, ketamine, legal highs, LSD, methadone, mushrooms, nicotine and volatile substance abuse and one fictitious drug (Semeron) which was introduced to identify over-claimers.

-   For each drug they have to select one of the answers: never used the drug, used it over a decade ago, or in the last decade, year, month, week, or day.

 

We plot all of the illegal and non-illegal drug use.

```r
#| fig-width: 6
#| fig-height: 7
data(drugs) # laod data

# response categories for recoding
responses_recode <- c(CL0 = "never_used",
                      CL1 = "over_decade",
                      CL2 = "last_decade",
                      CL3 = "this_year",
                      CL4 = "this_month",
                      CL5 = "this_week",
                      CL6 = "this_day")

# recode only drug variables
drugs <- drugs |> 
  mutate(across(where(is.character), ~ recode(.x, !!!responses_recode))) |>  tibble()


drugs |> 
  select_if(is.character) |> 
  pivot_longer(everything()) |> 
  rename(drug=name, response=value) |>
  mutate(response = factor(response),
         response = fct_relevel(response, 
                                c("never_used",
                                  "over_decade",
                                  "last_decade",
                                  "this_year",
                                  "this_month",
                                  "this_week",
                                  "this_day"))
  ) |> 
  group_by(drug) |> 
  count(response) |> 
  mutate(Percent = (n/sum(n)) * 100) |> 
  ggplot(aes(x=drug, y=Percent, fill=response)) +
  geom_col(position="stack", stat="identity") +  
  coord_flip() +
  guides(fill=guide_legend(title="", reverse = FALSE)) +
  scale_fill_viridis_d(option="magma", direction = 1,
                       alpha=.85, end =.90, begin=.10) +
  ggthemes::theme_hc()
  
  
```

\newpage

#### 1) Predicting drug usage

**a) Prepare an outcome variable. For this you can choose from the variables on drug consumption and pick one drug (or a combination of drugs) as the prediction objective. The resulting variable should be of class `factor`, but it can have more than two categories if needed.**

-   We note that caffeine, and chocolate are very common, and on the opposite end semer, crack, heroin, ketamine, and VSA are uncommon. We can ignore these drugs as there is not much variability and would lead to serious class imbalances. We can see that cannabis and alcohol have a lot of variability in the response categories. As our target outcome we are interested in predicting **use of alcohol *and* cannabis within the past year** which we code as 1, and 0=other. Below we observe that in this sample 50 percent have used alcohol and cannabis in the past year and we have a nice class balance to proceed.\

```r
model_dat <- drugs |> 
  # prepare outcome variable
  mutate(outcome = ifelse(
    str_detect(Cannabis, "this") & str_detect(Alcohol, "this"),
    "yes", "no"),
    outcome = factor(outcome)) |> 
  # drop drugs
  select(Age:SS, outcome)

model_dat |> 
  count(outcome) |> 
  mutate(Percent = n/sum(n) * 100) |> 
  kable()
  
```

\newpage

**b) Next split the data into a training and a test part.**

-   We conduct an 80/20 split.

```r
set.seed(9574)

drugs_split <- initial_split(model_dat, prop = .80, breaks = 2)
drugs_train <- training(drugs_split) # train split
drugs_test <- testing(drugs_split) # test split
```

**c) Specify the evaluation method for the `train()` function of `caret` with 10-fold cross-validation.**

-   We will be using a 10-fold CV to tune our hyperparameter m_try and min node.

```r
set.seed(9574)

ctrl <- trainControl(method = "cv", # cross validation
                     number = 10, # how many folds
                     summaryFunction = twoClassSummary,
                     classProbs = TRUE,
                     verboseIter = FALSE, # no training log
                     allowParallel = TRUE) # parallel processing
```

**d) Specify a grid object for tuning a random forest model.**

```r
grid <- expand.grid(mtry = c(sqrt(ncol(drugs_train)),
                             log(ncol(drugs_train))),
                    splitrule = c("gini", "extratrees"),
                    min.node.size = seq(5, 10))

grid |> kable()
```

**e) Use `train()` from `caret` in order to grow the forest. Do not use any of the other drugs as predictors in this model. Determine the best model based on the tuning results.**

-   We use ranger to train the model and pass the tuning grid along with specifiying the performance metric.

```r
set.seed(9574)

rf <- train(outcome ~ .,
            data = drugs_train,
            method = "ranger",
            trControl = ctrl,
            tuneGrid = grid,
            metric = "ROC",
            importance = "impurity",
            num.trees = 1000)
```

\newpage

------------------------------------------------------------------------

#### 2) Interpreting the model

**a) Find and create a plot of the variable importances. What are you interpretations of this?**

-   We compute feature importance as the factor by which the model's prediction error increases when the feature is shuffled with 100 repetitions. Variables country, openness, sensation seeking, age, and education are ranked the highest, meaning that these features are most effective in reducing impurity while training the random forest model.

```r
X <- drugs_train[which(names(drugs_train) != "outcome")]

predictor <- Predictor$new(rf, data = X, 
                           y = drugs_train$outcome, 
                           type = "prob")
```

```r
#| fig-width: 6
#| fig-height: 5

future::plan(multisession, workers = 20)

imp <- FeatureImp$new(predictor, loss = "ce", n.repetitions = 80)

plot(imp) + theme_hc()
```

\

**b) Create some partial dependence plots. What are your interpretations of these plots?**

-   We compute the PDP for sensation seeking and can see a complex non-linear relationship between this feature and the outcome. Lower values of sensation seeking around -1 begin to climb thus predicting the outcome at higher values. When we plot sensation seeking by gender, we see that males at higher levels of sensation seeking are predictive of recently using alcohol and cannabis more so than for females.

```r
#| fig-width: 5
#| fig-height: 4
predictor <- Predictor$new(rf, data = X, 
                           y = drugs_train$outcome, 
                           type ="prob",
                          class = "yes")


# Compute the partial dependence for the first feature
pdp.obj <- Partial$new(predictor, 
                       feature = "SS", 
                       ice = FALSE)

# Plot the results directly
plot(pdp.obj) + 
  labs(title = 
         "PDP for sensation seeking") +
  theme_hc()



pdp.obj$set.feature(c("Gender", "SS"))

plot(pdp.obj)  + 
  labs(
    title = 
      "PDP for sensation seeking by Gender") +
  scale_color_viridis_d(option="D", direction = 1,
                       alpha=.85, end =.90, begin=.15) +
  theme_hc()



```

\

**c) Create some ICE plots. What are your interpretations of these plots?**

-   We display the ICE plots for the most important continuous features, and here we measure the flatness of each individual ICE curve and then aggregate the results. It appears that agreeableness and neuroticism aremostly flat, suggesting that the model predictions for changes in these features are not as sensitive. The relative parallel nature in sensation seeking and openness indicates that these features do influence the model's predictions (e.g., the curves likely aren't flat), and the direction and magnitude of this influence are similar across different individuals. If an increase in sensation seeking generally leads to a higher prediction, a similar increase will likely have a comparable effect for most data points, and the same holds for openness.

```r
#| fig-width: 8
#| fig-height: 9
feature_names <- c("SS", "Openness", "Conscientiousness",
                   "Neuroticism", "Impulsive", "Agreeableness")

plots <- map(feature_names, function(x){
  

pdp.obj = Partial$new(predictor, feature = x, ice = TRUE)

plot(pdp.obj)  + 
  labs(title = 
         str_c("ICE for ", x)) +
  theme_hc()  
  
})


patchwork::wrap_plots(plots)

```

**d) What are some possible actions that can be taken using the results of these interpretations?**

-   The interpretations of the ICE and PDP plots may suggest several potential actions; such as for agreeableness, given its flat ICE curves, we may want to consider its role in the model. For instance, we can decide to remove it from the model or categorize it and create an interaction feature with another variable. The PDP for sensation seeking reveals a complex, non-linear relationship, particularly influenced by gender, suggesting the need to account for this interaction, possibly through interaction terms or separate modeling for males and females. The parallel ICE curves for sensation seeking and openness reinforce their consistent influence highlighting their relevance and importance in the model. Overall, these insights can guide model refinement and improve explainability of fairness assessments between personality assessments and demographic variables such as gender, country, education, or age.

------------------------------------------------------------------------

\newpage

#### 3) Prediction and Bias

**a) Use `predict()` in order to predict class membership and probabilities in the test set.**

-   We print the best tuned model that we will be working with and predict the test set to evaluate the model.

```r
rf$bestTune
```

```r
# Performance, pick best model
update(rf, param = rf$bestTune)

drugs_test <- drugs_test |> 
  mutate(predictions = predict(rf, newdata = drugs_test) )
```

\

**b) Evaluate prediction performance based on two or three measures.**

-   We evaluate the prediction performance using F1-score and recall and observe a recall of .82, indicating that the model correctly identifies 82 percent of the actual 'yes' cases (recent use of alcohol and cannabis). This suggests that the final model has a good ability to capture the instances of target. The F1-score, which balances precision and recall, is 0.76. This value provides a harmonic mean of the model's ability to avoid false positives and false negatives. However, the F1-score indicates that when considering both the ability to find all positive cases and the accuracy of the positive predictions the model achieves a moderate balance. A higher F1-score highlights a better overall performance in binary classification tasks, particularly when the classes are imbalanced or when both false positives and false negatives are costly. In this case, while the model is quite sensitive, the F1-score suggests there might be room for improvement in the precision which is .71.

```r
cm_result <- binary_class_cm(drugs_test$outcome, 
                        drugs_test$predictions,
                        positive="yes")
   
cm_result
```

\

**c) Look at the differences in performance metrics by gender. Are there any possible biases in the predictions?**

-   We examine the same metrics below, recall and F1-score, across gender and the figure below reveals potential biases in the prediction of recent use of alcohol and cannabis. For females, the recall is 0.754 and the F1-score is 0.656. For males, the recall is significantly higher at 0..855, and the F1-score is also much better at 0.821. These differences suggest that the model performs differently for males and females. The lower recall among females indicates that the model is missing a large proportion of actual positive cases within females compared to males. The substantially lower F1-score among females also suggests that the model's ability to balance precision and recall is worse than for males. This could be due to a higher rate of false positives or false negatives, or a combination of both, for female predictions, which can lead to a less reliable overall performance for this group. We may want to reevaluate the model and address these biases to ensure fairness in how we apply the model towards females.

```r
# subset females from test set
 
female_result <- cm_metric_fun(dat = drugs_test, 
                                gender_name = "0.48246") |> 
   mutate(Gender = "Female") 
 
male_result <- cm_metric_fun(dat = drugs_test, 
                                gender_name = "-0.48246") |> 
   mutate(Gender = "Male") 

female_result |> 
  add_row(male_result) |> 
  ggplot(aes(x=metric, y=score, fill=Gender)) +
  geom_col(position="dodge") +  
  coord_flip() +
  guides(fill=guide_legend(title="", reverse = TRUE)) +
  scale_fill_viridis_d(option="F", direction = -1,
                       alpha=.85, end =.70, begin=.15) +
  labs(
    x = "Models",
    y = "Performance Scores"
  ) +
  theme_hc()
 
```
