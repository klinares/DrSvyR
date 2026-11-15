---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/HW6"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "Homework 6"
original: "stat_mod_ML_1_SURV615/assignments/HW6.qmd"
pages: 
sha256: "9b042b9b56a07ba0b35011afcf846f073a0e4a2107ac2781f41d0dd7af7a3a04"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:13"
---


<br> <br>

------------------------------------------------------------------------

```r
require(ISLR2)
library(faraway)
library(knitr)
library(tidyverse)

options(scipen=999)
```

<br> <br>

## 1.Faraway Chapter 4. Exercise 2. Using the teengamb dataset from the faraway package Fit a linear regression model with gamble as the outcome and the other variables

-   We model gamble, expenditure on gambling in pounds per year, as a function on sex (male, female), status score based on parents' occupation), income (in pounds per week), and verbal scores (in words out of 12 correctly defined).

```r
data("teengamb")
?teengamb
glimpse(teengamb) 
```

<br>

```r
summary(
  mod <- lm(gamble ~ sex + status + income + verbal, teengamb))
```

-   A. Predict the amount that a male with average values (given these data) for status, income, and verbal would spend on gambling along with an appropriate 95% interval.

    -   We would expect a male with average SES status, income, and verbal scores to spend on average 28.24 pounds per week on gambling, and we are 95% confident taht the next observation with these predictor values will fall between -18.52 to 75.00 pounds per week. 

```r
male_mean_pred <- teengamb |> 
  summarise(
    status = mean(status), 
    income = mean(income), 
    verbal = mean(verbal)) |> 
  mutate(sex = 0) |> relocate(sex)

male_mean_pred |> kable()

predict(mod,  
        newdata = male_mean_pred, interval = "prediction") |> 
  kable()
  
```

<br>

-   B. Repeat the prediction for a male with maximal values (for these data) of status, income, and verbal. Which interval is wider and why is this result expected?

    -   For a male with max values of status, income, and verbal scores we would expect to spend on average 71.3 pounds per week on gambling, with a 95% prediction interval between 17.1 and 125.6.

    -   Among a male with max scores, the difference between the upper and lower 95% prediction interval is 16% wider (108.5) versus a male with average scores (93.5), suggesting that the the wider interval for males with max scores corresponds with more uncertainty in the model's prediction of these individuals due to the variability (random error) in the data. It is likely that our data does not contain many observations near the max scores, and thus our predictions become more uncertain as we move away from the mean of scores.

```r

male_max_pred <- teengamb |> 
  summarise(
    status = max(status), 
    income = max(income), 
    verbal = max(verbal)) |> 
  mutate(sex = 0) |> relocate(sex)

male_max_pred |> kable()

predict(mod,  
        newdata = male_max_pred, interval = "prediction") |> 
  kable()
```

-   C. Fit a model with sqrt (gamble) as the outcome but with the same predictors. Now predict the response and estimate the appropriate 95% interval for the individual in #A. Take care to give your answer on the original scale of the response (i.e., gamble not sqrt (gamble).
    
    -   We would expect a male with average SES status, income, and verbal scores to spend on average 16.40 pounds per week on gambling, and we are 95% confident taht the next observation with these predictor values will fall between 0.06 and 69.62 pounds per week.

```r
summary(
  mod2 <- lm(sqrt(gamble) ~ sex + status + income + verbal, teengamb))
```

```r
predict(mod2,  
        newdata = male_mean_pred, interval = "prediction")^2 |> 
  kable()
```

-   D. Repeat the prediction for the model in #C for a female with status=20, income=1, verbal=10. Give your answer on the original scale of the response and comment on the credibility of the result.

    -   We would expect a female with status of 20, income of 1, and verbal score of 10 to spend on average 4.35 pounds per week on gambling, and we are 95% confident taht the next observation with these predictor values will fall between 47.73 and 7.49 pounds per week. The prediction falls outside of the prediction interval after transforming back from the square root scale. Additionally, the lower bound is much higher than the upper band and we conclude that predictions for some people are not trustworthy and perhaps modeling the square root of the outcome is not feasible.

```r

female_pred <- teengamb |> 
  summarise(
    status = 20, 
    income = 1, 
    verbal = 10) |> 
  mutate(sex = 1) |> relocate(sex)

predict(mod2,  
        newdata = female_pred, interval = "prediction")^2 |> 
  kable()
```

-   E. Now, go back to #A. Consider how much males with average values (given these data) for status, income, and verbal would spend on gambling along with an appropriate 95% interval. How does this interval compare to the interval in #A? Explain whether this is expected and why.

    -   We construct a confidence interval for male with average scores, to suggest that if we were to take repeated samples we would expect the 95% CIs of the samples to contain the true mean 95% of the time. Our confidence interval is different from the prediction interval reported in question A., given that a prediction interval is a range of values that is likely to contain a single new observation based on a specified subset of predictor values. Our confidence interval is much more narrower than the prediction value. The difference is that with confidence intervals we assess variability around the mean in an estimated quantity on the predictor, while the prediction interval looks at a single new observation, not the average, so we have to account for the variability of the predictor in addition to the variability of our estimate of the mean.

```r

predict(mod,  
        newdata = male_mean_pred, interval = "confidence") |> 
  kable()
  
```

## 2. Assess the following DAG. You want to get an unbiased estimate for the association between HIV and Stroke. What covariate(s) would you want to include in your model and why?

-   In our model to get an unbiased estimate between HIV and Stroke we would not include any covariate as it may introduce post-treatment bias, concluding that HIV does not have an effect on stroke. In the DAG we have a pipe covariate from age -> smoking -> HIV -> stroke. Therefore, we would be stratifying HIV by smoking, and smoking by age thus blocking the path between HIV and stroke and thus statistically removed from the results.  


