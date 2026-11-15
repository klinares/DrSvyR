---
id: "jpsm/stat_mod_ML_2_SURV616/assignments/HW_4"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "assignment"
title: "SURV616, Homework 4"
original: "stat_mod_ML_2_SURV616/assignments/HW_4.qmd"
pages: 
sha256: "4b7f228ef3a4276abd0ce480d91cf2568c3f9600e946b4671ace3d1d2b2fc40d"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:19"
---


## ![](honor_hw4.png){width="427"}

```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(arm, lmtest, jtools, tidyverse)

options(scipen=999)
```

1.  Your client is a retail banking institution. Term deposits are a major source of income for a bank. A term deposit is a cash investment held at a financial institution. Your money is invested for an agreed rate of interest over a fixed amount of time, or term. The bank has various outreach plans to sell term deposits to their customers such as email marketing, advertisements, telephonic marketing and digital marketing. Telephonic marketing campaigns still remain one of the most effective way to reach out to people. However, they require huge investment as large call centers are hired to actually execute these campaigns. Hence, it is crucial to identify the customers most likely to convert beforehand so that they can be specifically targeted via call. You are provided with the client data such as: age of the client, their job type, their marital status, etc. Along with the client data, you are also provided with the information of the call such as the duration of the call, day and month of the call, etc. Given this information, your task is to predict if the client will subscribe to term deposit.

```r
# read in data
deposit <- read_csv(
  "~/repos/UMD_classes_code/stat_mod_ML_2_SURV616/homework/deposit-1.csv") |> 
  # create subscribe as a numeric vector
  mutate(subscribed_num = if_else(subscribed == "yes", 1, 0))
```

a\) Create an empirical logit plot with the response variable (y) `subscribed` by the predictor variable (x) `age`. You may want to convert subscribed to a numeric variable first.

-   We can check whether the assumption of linear relationship between the logit subscribed and the predictor age exist using an empirical logit plot by.

    -   step 1: calculating the probability in binned values of age.
    -   We can use the base cut() function to assign age bins evenly by a number of breaks.
    -   step 2: taking the logit of these probabilities
    -   step 3:plotting them.

```r

deposit <- deposit |> 
  # step 1: 
  # convert outcome to numeric
  mutate(# we can use the cut function to make 
         age_g = cut(age, 5) ) # number of breaks = 5

deposit |> distinct(age_g)

deposit |> 
  group_by(age_g) |> 
  reframe(
      # compute probabilities
    prob = mean(subscribed_num),
    # step 2, transform probabilities on the logit scale
    ## log(p / 1-p)
    subscribed_logit = log(prob / (1-prob))
  ) |> 
  # step 3, plot
  ggplot(aes(x=as.numeric(age_g), y=subscribed_logit)) +
  geom_point() +
  geom_line()


```

-   The relationship between age and subscribed_logit appears to be somewhat linear within the middle age groups but not at the extreme ends.

\

b\) Report the proportion (tabular format is fine) subscribed=”yes” for each of the categories for job, marital, education, default, housing, loan, and contact.

-   We compute for each variable the mean of subscribed when yes==1 and no=0, and report proportions below.

```r
# we subset variables needed
var_list <- deposit |> select(job:contact, -balance) |> colnames() ; var_list

# apply a loop through the variables in var_list & compute subscribe proportions
walk(var_list, function(x) {
  
  deposit |> 
    group_by_at(x) |> 
    reframe(prop = mean(subscribed_num))  
  })
```

\

c\) Plot the response variable, proportion subscribed=”yes”, for each of the following values of campaign: 1, 2, 3, 4, 5, 6+

-   We calculate the proportion of subscribed = yes for 6 levels of campaign and plot values below.

```r
deposit |> 
  # create new campaign variable with 6 categories
  arrange(campaign) |> 
  mutate(campaign_g = ifelse(campaign >=6, "6+", campaign)) |> 
  group_by(campaign_g) |> 
  reframe(prop = mean(subscribed_num)) |> 
  ggplot(aes(x=campaign_g, y=prop)) +
  geom_col()
  
```

\

d\) Next, we want to evaluate if campaign contacts are effective. Estimate a logistic regression model using the variable campaign as a predictor of subscribed=yes. Are more campaign contacts effective at producing subscriptions to term deposits?

-   We model the probability of y = 1 using a logit link function under the assumption that the outcome $y_i$ is independent given these probabilities.

$$
Pr(y_i=1) = logit^{-1}(X_i\beta)
$$

-   where $X\beta$ is the linear predictor, and therefore these model can be written as:

$$
Pr(y_i=1) = p_i \\
logit(p_i) X_i = \beta 
$$ - where $p_i$ is a vector of our probability of the outcome $i = 1,...,N$. We therefore fit the following logit link function to these data as:

$$
Pr(subscribed_i = 1) = \frac{1}{1 + e^ {-(\beta_o + campaign_1x_{i1})}}
$$

-   For every additional campaign contact, the log odds of subscribing decreases by .12; therefore, more campaign contacts are not effective at producing subscriptions.

```r
logitmod <- glm(subscribed_num ~ campaign, family=binomial, data=deposit)
summ(logitmod)
```

\

e\) What is the probability of a person with zero contacts (i.e. campaign=0) subscribing to a term deposit? What is the probability of a person with one contacts (i.e. campaign=1) subscribing to a term deposit? What is the probability of a person with two contacts (i.e. campaign=2) subscribing to a term deposit?

-   We take note below the probability of subscribing given the number of contacts decreases as campaign contacts increase. Here we use the fitted model to make predictions on one out of sample prediction {0}, and the rest are values in the sample {1, 2}.

```r
# create tibble with campaign values 
new_dat <- tibble(campaign = seq(0, 2)) 

# call the prediction function to compute probabilities for campaign values
new_dat |> 
  add_column(
    prediction = predict(logitmod, newdata = new_dat, type="response")
)

```

\

f\) Estimate a logistic regression model using the variable campaign as a predictor along with the following other variables: job, marital, education, default, housing, loan, contact, age, and campaign. Consider the form in which age should enter the model (i.e. categorical, continuous, transformed) and choose the best option for this model. Are more campaign contacts effective at producing subscriptions to term deposits conditional on the additional predictors?

-   The model we fit is similar to d) except there are many categorical variables included and it would be hard to look at the equation. Overall, there are 24 parameters estimated including an intercept in this model.

-   Campaign contacts in the new model with age as categorical and additional predictors does not increase subscriptions and we still see the same coefficient log odds estimate on campaign as in the simple model.

```r
logitmod_age_g <- glm(subscribed_num ~ campaign + job + marital + education + 
                    default + housing + loan + contact + factor(age_g), 
                  family=binomial, data=deposit)

summ(logitmod_age_g)
```

g\) For the model estimated in 1f, what is an interpretation of the coefficient for campaign?

-   Holding all other variables constant, a one-unit increase in campaign contacts is associated with a decrease of 0.12 in the log-odds of subscribing. If we exponentiate the coefficient $exp(-.12)=.89$ to get the odds ratio, meaning that for each additional contact, the odds of subscribing are multiplied by approximately .89, or each additional contact decreases the odds of subscribing by about 11% holding all other variables constant.

h\) Use the likelihood ratio test discussed in class to evaluate whether the model in 1f is a better fit than the model in 1d.

-   We use the likelihood ratio test to test model fit by first finding the likelihood for the full model, and the likelihood for the reduced model as:

$$
G_p = -2logL(\hat{\beta}) \\ 
G_k = -2logL(\hat{\beta})
$$

-   Where $G_p$ represents the full model, and $G_k$ represents the reduced model which we can than complete the equation as:

$$
-2log\frac{L(\hat{\beta_k})}{L(\hat{\beta_p})}
$$

-   Where the ratio has a $\chi^2$ distribution with $p-k$ degrees of freedom. In R we can do this by extracting the log likelihood and degrees of freedom for each model.

-   Below we simplify the formula by using $G_k - G_p \sim \chi^2_{p-k}$, which in R we can extract these coefficients and DFs from the model fit as:

```r
# compute -2loglikelihood
chi_square <- -2 * (logLik(logitmod) - logLik(logitmod_age_g))

# compute difference in df
df <- summary(logitmod_age_g)$df[1] - summary(logitmod)$df[1]

```

-   We estimate a chi-square of `r round(chi_square, 2)` with a DF of `r df`, and we can use the dchisq() function to get a p-value. We can also use the lrtest by passing the model fit objects directly and we see that the chi_sqr value is statistically significant at the .001 level, suggesting that the full model is a better fit to the data.

```r

chi_sqr_sig <- dchisq(chi_square[1], df)
chi_sqr_sig

lrtest(logitmod_age_g, logitmod)
```
