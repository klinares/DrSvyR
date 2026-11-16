---
id: "jpsm/fund_comp_data_display_SURV727/code/08_text_classification"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Introduction to Supervised Text Classification"
original: "fund_comp_data_display_SURV727/code/08_text_classification.Rmd"
pages: 
sha256: "3fe94cb6f08b4a2d04036915890b1cece039f82016ee23b76e43787d074c0e07"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


```r
library(tidyverse)
library(quanteda)
library(quanteda.textmodels)

library(caret)
library(glmnet)
```

## 1. Manual classification
```r
browseURL("https://docs.google.com/spreadsheets/d/1UzkKJt_glOjI5hWxznH3vLglUypT052Hp4crYtcGDOE/edit?usp=sharing")
```


## Import dataset

Source: tweets about Brexit from 2019-09-06
```r
BTD = read_csv("BTD_classified_new.csv")
BTD
```

Do not run this:
```r
BTD$label = sample(c("L","R","N",NA), nrow(BTD), replace = TRUE)
```


## Separate training, test, virgin set

```r
set.seed(30)
ids_labeled = BTD %>% filter(!is.na(label)) %>% select(tweet_id) %>% unlist
ids_train = sample(ids_labeled, round(0.7*length(ids_labeled)))
ids_test = setdiff(ids_labeled, ids_train)
length(ids_labeled)
length(ids_train)
length(ids_test)
```

```r
BTD = BTD %>% mutate(label = factor(label),
                     labeled = tweet_id %in% ids_labeled,
                     train = tweet_id %in% ids_train,
                     test = tweet_id %in% ids_test)
summary(BTD)
```


## Pre-processing / text cleaning

```r
BTD_labeled = BTD %>% filter(labeled == T)
bx_corpus = corpus(BTD_labeled, 
                   docid_field = "tweet_id",
                   text_field = "text")
bx_corpus
```

```r
bx_tokens = tokens(bx_corpus,
                   remove_punct = TRUE,
                     remove_numbers = TRUE,
                     remove_separators = TRUE) %>%
                   tokens_tolower() %>%
                   tokens_remove( stopwords("en") ) %>%
                   tokens_wordstem(language = "en")
bx_tokens[1:5]
```

```r
bx_dfm = dfm(bx_tokens) %>%
            dfm_trim(min_docfreq = 0.01, docfreq_type = "prop")
bx_dfm
```


Explore dataset
```r
topfeatures(bx_dfm, n = 100)
```

```r
bx_dfm[1:10,1:10]
```


### Apply Naive Bayes

Select DFM only from training set
```r
bx_dfm_train = dfm_subset(bx_dfm, train == T)
bx_dfm_test = dfm_subset(bx_dfm, test == T)
bx_dfm_train
bx_dfm_test
```

Run NB model
```r
library(quanteda)
bx_mod_nb <- textmodel_nb(x = bx_dfm_train, 
                          y = docvars(bx_dfm_train, "label"))
summary(bx_mod_nb)
```

### Prediction diagnostics

Manually create confusion matrix.
```r
## Actual class is the labels in the test set
actual_class = 
  docvars(bx_dfm_test, "label")
## Prediction

predicted_class = 
  predict(bx_mod_nb, newdata = bx_dfm_test)

### Check predictions
table(actual_class)
table(predicted_class)
      
## Confusion matrix
table(predicted_class,actual_class)
```

What is the accuracy of prediction?


```r
confusionMatrix(data = predicted_class,
                reference = actual_class, 
                mode = "prec_recall")
```

What is the precision for predicting Leavers?
What about the recall for Leavers?
Which one is the biggest problem? False positives or false negatives?


### Predict on virgin set
```r
BTD_virg = BTD %>% filter(labeled == F)
bx_corpus_virg = corpus(BTD_virg, 
                        docid_field = "tweet_id",
                        text_field = "text")
bx_corpus_virg
```

```r
bx_tokens_virg = tokens(bx_corpus_virg,
                        remove_punct = TRUE,
                         remove_numbers = TRUE,
                         remove_separators = TRUE) %>%
                        tokens_tolower() %>%
                        tokens_remove( stopwords("en") ) %>%
                        tokens_wordstem(language = "en")
```

```r
bx_dfm_virg = dfm(bx_tokens_virg) %>% dfm_match(featnames(bx_dfm))
bx_dfm_virg
```

```r
BTD_virg$prd =  predict(bx_mod_nb, 
                                    newdata = bx_dfm_virg)
### How many predicted in each class?
table(BTD_virg$prd)
```

Check out predicted values. Do they have face validity?
How many fit, how many do not fit?
```r
BTD_virg %>% 
  select(prd, text) %>% 
  group_by(prd) %>% 
  arrange(prd) %>%
  slice(1:10) %>%
  View
```



# Create Supervised Learning Pipeline

We will use the package 'caret'. 
Extensive documentation available here:
```r
browseURL("http://topepo.github.io/caret/index.html")
```

# Define training and test sets 
```r
X_train = bx_dfm_train %>% 
          dfm_replace(featnames(X_train), 
                      make.names(featnames(X_train), unique = TRUE)) %>% 
          convert(to= "data.frame")
Y_train = docvars(bx_dfm_train, "label")
###
X_test = bx_dfm_test %>% 
          dfm_replace(featnames(X_train), 
                      make.names(featnames(X_train), unique = TRUE)) %>% 
          convert(to= "data.frame")
Y_test = docvars(bx_dfm_train, "label")
###
X_train
X_test
```

### Train model

```r
bx_ctrl_0 <- trainControl(method = "none",
                          classProbs = TRUE, 
                          summaryFunction = multiClassSummary)
```

```r
bx_train <- train(x = bx_dfm_train, 
                  y = docvars(bx_dfm_train, "label"), 
                  method = "glmnet",
                  metric = "Accuracy",
                  trControl = bx_ctrl_0)
bx_train
```


### Predict on test set

```r
bx_pred_test <- predict(bx_train, 
                        newx = bx_dfm_test) %>% 
                factor
table(bx_pred_test)
```

```r
sx_cfm = confusionMatrix(bx_pred_test, 
                         docvars(bx_dfm_train, "label"), 
                         mode = "prec_recall")
sx_cfm
```


# Cross-validation

```r
bx_ctrl_cv = trainControl(method = "cv", number = 5,
                           classProbs = TRUE, 
                           summaryFunction = multiClassSummary)
```

Train model with cross-validation.

```r
bx_train_cv = 
```

Now predict on test set. 
Any differences?

```r

```


# Exercise


