---
id: "jpsm/stat_mod_ML_2_SURV616/project/project_paper"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "assignment"
title: "Decoding Coronary Risk: Machine Learning Unveils Key Predictors"
original: "stat_mod_ML_2_SURV616/project/project_paper.qmd"
pages: 
sha256: "d2a1eb77ebbaae0c5ce7ed529eccc463a10ebb56e89757d2778fa2bba6400a29"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:33"
---


```r
knitr::opts_chunk$set(echo=FALSE,cache=FALSE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(tidymodels, skimr, viridis, knitr, ggthemes, vip, tidyverse)

options(scipen=999) 

# read in data
chd_dat <- read_csv(  
  "D://repos/UMD_classes_code/stat_mod_ML_2_SURV616/project/chd.csv") |> 
  filter(age >=18)
```

## Introduction {#sec-intro}

Coronary heart disease (CHD) emerges from the buildup of plaque within the coronary arteries and obstructing blood flow to the heart muscle, and increases the risk of a heart attack.
The CDC reported that in 2022, 1 in 5 deaths were related to heart disease among adults, thus making this disease a leading cause of mortality.
Data analysis enables the identification of key risk factors, such as age, gender, and behavioral factors.
By analyzing large datasets, researchers can discern trends, understand the interplay of genetic and lifestyle factors, and refine public health strategies, ultimately aiming to reduce the burden of this pervasive disease.
The aim of this study is to propose a predictive model of CHD among adults.
A central research question of this study is to what extent do lifestyle factors, such as drinking or smoking, and biological and psychological factors contribute to CHD among adults?

```r

# This code is for exploring the data, but does not print into the final paper
# print data structure
summary(chd_dat)


# age, smoking and alcohol are not normally distruted 
## tried log, sqrt, exp, and 
var_not_norm <- c("age", "tobacco", "alcohol")

map(var_not_norm, function(x){
  chd_dat |> 
    select(all_of(x)) |> 
    rename(outcome=1) |> 
    ggplot(aes(x=outcome)) +
  geom_histogram() +
  ggtitle(x)
})


## tried log, sqrt, exp, and 
# create empirical logit plot
dat_split <- chd_dat |>
  mutate( 
    age_g = cut(age, 3),
    tobacco_g = cut(tobacco, 2),
    alcohol_g = cut(alcohol, 3)
  ) 

# plot age
dat_split |> 
  group_by(age_g) |> 
  reframe(prob = mean(chd),
          chd_logit = log(prob / (1-prob)) ) |> 
  ggplot(aes(x=age_g, y=chd_logit)) +
  geom_point() 


# plot age
dat_split |> 
  group_by(tobacco_g) |> 
  reframe(prob = mean(chd),
          chd_logit = log(prob / (1-prob)) ) |> 
  ggplot(aes(x=tobacco_g, y=chd_logit)) +
  geom_point() 


# plot age
dat_split |> 
  group_by(alcohol_g) |> 
  reframe(prob = mean(chd),
          chd_logit = log(prob / (1-prob)) ) |> 
  ggplot(aes(x=alcohol_g, y=chd_logit)) +
  geom_point() 


# plot BMI with adiposity
chd_dat |> 
  ggplot(aes(adiposity, obesity, color=chd)) + 
  geom_point()

cor.test(chd_dat$adiposity, chd_dat$obesity)


```

## Methods

*Data*.
We leverage data on the presence of CHD, which in this sample was 37 percent (*N*=386, mean age 43.1 \[*SD* 14.5\]) among adults (under 18 excluded for ethical reasons) collected from a retroactive study with no missingness.
This dataset contains BMI information, which we used CDC guidelines to recode into an obese status (\>30).
Adiposity is the amount of body fat in percentage, and the greater the number, the more body fat was measured.
A Pearson’s correlation between BMI and adiposity shows a statistically significant positive association (*r*(418) = .71).
Low-Density Lipoprotein (LDL), or bad cholesterol, and higher values indicate higher levels of fat buildup in the arteries.
Systolic blood pressure (SBP) measures the heart’s pumping strength, with high values indicating hypertension (known as the silent killer).
Family history of heart diseases is coded as yes or no.
Cigarettes smoked per day and alcohol daily consumption (in ounces) were highly skewed based on our preliminary analysis.
Additionally, we used empirical logit plots to explore the relationship between these two variables and our outcome.
For tobacco use, we binned values into “does not smoke” and “smokes,” and for alcohol, we binned values into “does not drink,” “occasional” (1-10 ounces), and “heavy drinker” (\>10 ounces).
Age in years was also not normally distributed, and an empirical logit plot assisted us in binning age into “young” (18-32), “middle age” (33-49), and “old” (\>49).
All three of these variables were plotted with different transformations (e.g., exponential, squared root, and log) but resulted in less than ideal distributions.
Type A personality is a continuous variable where higher scores indicate more of this trait and was left unchanged for analysis.

Figure 1 presents the distribution of CHD across age, family history, and obesity status.
We see that among older adults, CHD becomes more common.
Having CHD does not seem to vary by obesity status, while having a family history of heart disease seems to be associated with the outcome.

```r

# transform data into categorical
chd_dat_mod <- chd_dat |> 
  mutate(
  obesity = ifelse( obesity >= 30, "obese", "not obese"),
   age = case_when(
     age < 33 ~ "young",
     between(age, 33, 49) ~ "middle",
     age > 49 ~ "old"),
   tobacco = ifelse(tobacco==0, "not smoker", "smoker"),
   alcohol = case_when(
     alcohol == 0 ~ "none",
     between(alcohol, .01, 10) ~ "occasional",
     alcohol > 10 ~ "heavy"),
    chd = ifelse(chd==0, "no", "yes"),
    # create reference groups
    obesity = relevel(factor(obesity), ref="not obese"),
    chd = relevel(factor(chd), ref = "no"),
    tobacco = relevel(factor(tobacco), ref = "not smoker"),
    age = fct_relevel(age, c("young", "middle", "old")),
    alcohol = fct_relevel(alcohol, c("none", "occasional", "heavy")),
   famhist = relevel(factor(famhist), ref="Absent")
  )
```

```r
#| fig-width: 6
#| fig-height: 3
#| 
# visualize outcome ~ age + tobacco + obesity
chd_dat_mod |>
  count(age, obesity, famhist, chd) |>
  group_by(age, obesity, famhist) |>
  mutate(prop = n / sum(n)) |>
  ungroup() |>
  ggplot(aes(x = famhist, y = chd, fill = chd,
             alpha = prop)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = ifelse(prop >= 0.05,
                               scales::percent(prop, accuracy = 1),
                               "")),
            size = 3.5, fontface = "bold", color = "white") +
  facet_grid(rows = vars(obesity), cols = vars(age)) +
  scale_fill_viridis_d(option = "rocket", begin = 0.50, end = 0.85,
                       direction = -1, alpha = 0.85) +
  scale_alpha_continuous(range = c(0.4, 1), guide = "none") +
  guides(fill = guide_legend(reverse = TRUE)) +
  labs(
    title = "Figure 1. Risk for CHD increases with age, relationship moderated 
    by family history.",
    x = "Family History",
    y = "CHD"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold", size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )



```

```r
#| fig-width: 7
#| fig-height: 5
#| 
# plot outcome ~ smoking + ldl
chd_dat_mod |> 
  ggplot(aes(x=adiposity , y=ldl , color=chd)) +
  geom_point(size=2) +
  geom_smooth( method="lm") +
  facet_grid(~tobacco) +
  guides(color=guide_legend( reverse = TRUE)) +
  scale_color_viridis_d(option="rocket", begin =.50, end = .85, 
                       alpha=.80, direction=-1) +
  scale_fill_viridis_d(option="inferno", begin =.50, end = .85, 
                       alpha=.85, direction=-1) +
  theme_hc() + 
  labs(title=
  "Figure 2. Adioposity has a relationship with LDL regardless of smoking 
  status, CHD more prevalent among smokers.")
```

\newpage

*Analytic Plan*.
We built a logistic regression model to classify adults as having CHD or not by leveraging Lasso penalized regression within a machine learning (ML) predictive modeling framework.
For a classification model, we specify a penalized logistic regression model that employs a penalty, and in turn, the model conducts feature selection, where predictor coefficients that are not relevant are driven closer to 0.
This penalty parameter, also known as lambda, is what we will tune using a train-test (i.e., 80/20) split.
Moreover, given the smaller sample size, we further split the training set into 80% to train on and 20% as a validation set, and this is for the purpose of measuring performance.
The validation set allows us to fine tune our model penalty parameter, and we evaluate a penalty grid search of candidates between .001 and .10 to train 60 penalized logistic regression models.
We use the area under the receiver operating characteristic curve (AUC-ROC) to evaluate penalty values which represents the true positive rate over the false positive rate.
This will allow us to visualize model performance at every penalty value to show how our trained models can distinguish between having CHD or not.

## Results {#sec-conc}

```r
#| fig-width: 5
#| fig-height: 3
#| 
# What is the maximum likelihood estimation of a proportion 
chd_dat_mod |> 
  count(chd) |> 
  mutate(prop = n/sum(n))# proportion with disease

# spit into train/test
set.seed(909)
chd_split <- initial_split(chd_dat_mod, prop=.80)

chd_other <- training(chd_split) # we use to split again
chd_test  <- testing(chd_split)

# validation split
set.seed(909)
chd_validation <- validation_split(chd_other, 
                            prop = 0.80)

#______ Preprocess modeling steps _________

# step 1, build the model w/ penalized parameter
lr_mod <- 
  logistic_reg(penalty = tune(), # let tune be set automatically to tune later
               mixture = 1) |> # 1 means remove irrelevant predictors
  set_mode("classification")  |> # for binary outcomes
  set_engine("glmnet") # the algorithm

# step 2, define preprocessing steps
lr_rec <- recipe(chd~., data=chd_other) |> 
  step_dummy(all_nominal_predictors())  |>  # create binary terms for categories
  step_normalize(all_predictors()) # scale and center continuous predictors


# step 3, create work flow
lr_wf <- workflow() |> 
  add_model(lr_mod) |> 
  add_recipe(lr_rec) 


#_____________ create tuning grid, and train & tune model  ______________

# we set how many candidates of the penalty parameter to evaluate on
penalty_grid <- grid_regular(penalty(), levels = 300) |> filter(between(penalty, .001, .1))


lr_res <- lr_wf |> 
  tune_grid(
    resamples = chd_validation, 
    grid = penalty_grid, # pass penalty candidates
    control = control_grid(save_pred=TRUE), # save predictions
    metrics = metric_set(roc_auc))



```

The AUC-ROC visual in Figure 2 shows better model performance with smaller penalty values, suggesting that most of the variables are relevant to predicting CHD.
The drop in the area under the curve associated with higher penalty values means that too much penalty will remove all variables from the model to the point where the model does not perform better than random chance.
The vertical blue dashed line represents the penalty value with the best performance.
Upon examining penalty candidates, we choose the optimal value of .0106 as our tuning parameter.

```r
#| fig-width: 6
#| fig-height: 4


#__________________ finalize model ______________________
# select best model
optimal_penalty <- lr_res |> 
  select_best( metric="roc_auc") 
  


lr_res |> 
  collect_metrics() |> 
  ggplot(aes(x = penalty, y = mean)) + 
  geom_point() + 
  geom_line() + 
  geom_vline(xintercept=optimal_penalty$penalty, 
             color="dodgerblue", linetype="dotdash") +
  ylab("Area under the ROC Curve") +
  scale_x_log10(labels = scales::label_number()) +
  theme_hc() +
  labs(title="Figure 2. Tuning ROC-Curve evaluation of trained models.")


```

In Figure 3, we examine the most important variables and show coefficient estimates for our tuned-trained model.
Holding all other variables constant, being older increases the log-odds of having CHD by .62 compared to those that are younger.
Moreover, older adults are 85 percent (*OR*=1.85) more likely than younger adults to have CHD.
Having a family history of heart disease increases one’s chances of having CHD by 53 percent (*OR*=1.53), while smoking tobacco increases the likelihood of having CHD by 45 percent (*OR*=1.45).
Type A personality increases the likelihood of CHD by 41 percent (*OR*=1.41), and LDL by 36 percent (*OR*=1.36).
Surprisingly, drinking alcohol and being obese decreases the likelihood of having CHD, yet these are not strong predictors of CHD.

```r
#| fig-width: 6
#| fig-height: 4
#| 
# to view coefficient estimates, take best tuned model and train on the 
## full training set
lr_final <- finalize_workflow(lr_wf, optimal_penalty) |> 
  last_fit(chd_split)

# view variable importance
lr_final |> 
  extract_fit_parsnip() |>
  vi()|> 
  mutate(
    Importance = abs(Importance),
    Variable = fct_reorder(Variable, Importance)
  ) |> 
  ggplot(aes(x = Importance, y = Variable, fill = Sign)) +
  geom_col() +
  geom_text(aes(label=round(Importance, 3)), hjust=1) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = NULL) +
  scale_fill_viridis_d(option="mako", begin =.50, end = .85, 
                       alpha=.85, direction=-1) +
  theme_hc() + 
  labs(title="Figure 3. Most important predictors in whether 
       an individual has CHD or not.")
  
```

The performance metric we selected is the AUC-ROC for its ability to discriminate between having CHD or not, and visualizing the trade-off between sensitivity and specificity across various thresholds.
High sensitivity indicated that a model can detect individuals with CHD, while high specificity means that a model is good at finding non CHD cases.
In Figure 4 we plot the AUC-ROC for both the validation set, which we used to fine tune our trained model, and the final test set.
Additionally, we plot thresholds (dotted colored lines) to show various sensitivity and specificity values.
We print mean area under the curve values for both in the title, and consistent values suggest that the model is not sensitive to new data.
Moreover, model performance here indicates a moderate discrimination between positive and negative CHD cases.
For this model we select a threshold of .51 (solid vertical blue line) as it gives us an expected sensitivity of .89 and specificity of .52.
We weight sensitivity more in this decision since optimizing a model to correctly identify CHD cases is important for medical intervention.

```r
#| fig-width: 7
#| fig-height: 4.5
#| 
# save performance metric for validation
performance_validation <- lr_res |> 
  collect_metrics() |> 
  filter(penalty %in% optimal_penalty$penalty,
    .metric == "roc_auc") |> 
  mutate(mean = round(mean, 3)) |> 
  pull(mean)

# print metric estimate for test
performance_test <- lr_final |> 
  collect_metrics() |> 
  filter(.metric == "roc_auc") |> 
  mutate(.estimate = round(.estimate, 3)) |> 
  pull(.estimate)

# predict on validation set
lr_res |> 
  collect_predictions(parameters = optimal_penalty) |> 
    roc_curve(truth=chd, .pred_no) |> 
  mutate(model = "Validation") |> 
# predict on test set and plot
  full_join(
    lr_final |> 
  collect_predictions() |> 
  roc_curve(truth=chd, .pred_no) |> 
  mutate(model="test")
  ) |> 
  # plot both
  ggplot(aes(x = 1 - specificity, y = sensitivity, color=model)) + 
  geom_path(lwd = 1.5, alpha = 0.8) +
  #geom_abline(lty = 3) + 
  geom_line(aes(x=.threshold), linetype="dotted") +
  geom_vline(xintercept = .51, color="dodgerblue") +
  coord_equal() + 
  scale_color_viridis_d(option = "plasma", end = .6) +
  labs(title = str_c("Figure 4. Comparing model performance between\n validation fit (AUC = ", performance_validation, "), final fit (AUC = ", performance_test, ")")
       ) +
  theme_hc() +
  labs(title="Figure 4. Variable importance in tuned-trained model.")
  
```

## Discussion

Given that these data come from a retrospective study, we can only determine correlation between these variables and not causation.
Furthermore, we make the assumption that these individuals were selected at random from the population, yet we are not confident in this assessment given the high values of LDL and adiposity.
Surprisingly, obesity and adiposity were not important predictors in the model as we hypothesized; however, age, family history of heart disease, smoking, and high LDL levels were significant, aligning with established medical research.
It is possible that confounding variables, such as gender or race/ethnicity, might mediate the relationship between body fat and CHD.
Future research should explore the underlying mechanisms linking Type A personality to CHD, as this was a significant predictor in our model.

Our machine learning model, utilizing penalized logistic regression, is appropriate for these data.
While we acknowledge that tree-based methods are also viable, we argue that these methods are prone to overfitting, particularly with this dataset.
Our decision to prioritize sensitivity as the evaluation metric for our final model highlights the critical importance of minimizing false negatives.
