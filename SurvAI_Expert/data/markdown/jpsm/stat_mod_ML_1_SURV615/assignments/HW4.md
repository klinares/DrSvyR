---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/HW4"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "Homework 6"
original: "stat_mod_ML_1_SURV615/assignments/HW4.qmd"
pages: 
sha256: "15acf6d58b8c6faec5eaebbb8690dda53dc5c6517f1de76ed1178adcea07fb4f"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---


<br> <br>

------------------------------------------------------------------------

```r
require(ISLR2)
library(faraway)
library(ggthemes)
library(viridis)
library(knitr)
library(tidyverse)

# set a standard graphic theme for plots from ggthemes package
theme_set(theme_hc())

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
mod <- lm(gamble ~ sex + status + income + verbal, teengamb)
summary(mod)
```

-   A. Predict the amount that a male with average values (given these data) for status,
income, and verbal would spend on gambling along with an appropriate 95% interval.

  -   We would expect a male with average SES status, income, and verbal scores to spend 28.2 pounds per week on gambling, with a predictive interval between -18.5 and 75.0 pounds per week. 

```r
male_pred <- teengamb |> 
  summarise(
    status = mean(status), 
    income = mean(income), 
    verbal = mean(verbal)) |> 
  mutate(sex = 0) |> relocate(sex)

male_pred |> kable()

predict(mod,  newdata = male_pred, interval = "prediction") |> 
  kable()
  
```


<br>

-   


### B) List the null and alternative hypotheses tested in 1A and your conclusions.

-   For multiple parameters, $\beta$, the null we are testing in model 1A is:

$$
H_0 : \beta_1 = \beta_2 = ... \beta_p = 0, \space \\
and \space each \space \beta_p = 0 
$$

-   meaning that our null hypothesis is that each $\beta$ coefficient is equal to each other and to $0$.

-   Our alternative hypothesis: is that at least one of the three $\beta$ coefficients are not equal to $0$.

-   We reject the null hypothesis, and there is a useful linear relationship between median home value and one of the three predictors in the model.

$$
H_a : \beta_i \ne 0 \space (i = 1,...,p)
$$

<br> <br>

### C) Interpret each of the regression coefficients as if it were the primary exposure of interest.

-   Do they make sense?

    -   $\beta_0$: When crime rate, the proportion of residential land zone, and the proportion of non-retail business acres all equal $0$, the expected average income is $\$27,395$ USD.

    -   In this case, the intercept without centering predictors makes sense since there can be a suburb with 0 crime rate or 0 proportions.

    -   $\beta_{crim}$: For every additional crime rate per capita, we expect the median home value to drop $.25$ or $\$250$ USD, while holding other predictors variables constant.

    -   $\beta_{zn}$: For every one unit change in the proportion of residential land zoned for lots over 25,000 sq.ft., we expect the median home value to increase by $.06$ or $\$60$ USD, while holding other predictor variables constant.

    -   $\beta_{indus}$: For every one unit increase in the proportion of non-retail business acres per town, we expect the median home value to drop $.42$ or $\$420$ USD, while holding other predictor variables constant.

<br> <br>

### D) It's generally not good practice to interpret all predictors as if they were the exposure of interest.

-   Why do you think doing so could be problematic?

    -   When creating these models the researcher typically has a hypothesis in mind guided by previous research and theory. Therefore, if we report every explanatory variable included in the model, we run the risk of capitalizing on spurious correlations, when two variables appear to be related by they are not (they are through a confounding variable). Furthermore, interpreting all predictors could be problematic because of the complexity of interpretation and making inferences. Also, multicollinearity and confounding issues may mask individual effects of each predictor.

<br> <br>

### E) Construct and interpret 95% confidence intervals

-   For $\hat{\beta_{crim}}$, $\hat{\beta_{zn}}$, and $\hat{\beta_{inuds}}$. (you do not need to calculate them "by hand").

-   How does the confidence intervals correspond to the hypotheses tested in 1A and 1B?

    -   From the graphic we can quickly see whether any of the predictor's 95% confidence intervals capture 0, denoted by the blue line, which we do not observe to be the case for any of the predictors and we continue to reject the Null hypothesis $\beta_p=0$.

    -   If we were to draw 100 samples with size $n$ from the same target population, we would expect 95% of these samples to contain the true value of our $\beta$ coefficients.

```r

confint(m_medv, level=.95) 

confint(m_medv, level=.95) |> 
  as.data.frame() |> 
  rownames_to_column() |> 
  as_tibble() |> 
  mutate(est = coef(m_medv)) |> 
  rename(predictors = 1, lower = 2, upper = 3, est = 4)  |> 
  slice(-1) |>  # remove intercept
  ggplot(aes(x=est, y=predictors)) +
  geom_point(size=1.2) +
  geom_errorbar(aes(xmin = lower, xmax=upper), width=0) +
  geom_vline(xintercept = 0, color="dodgerblue") 

```

<br> <br>

### F) Calculate $R^2$ and $R^2_{adj}$ "by hand."

-   (you can use helper functions from R to get the components needed for the formula, but do not simply extract it from the model object).

-   What do they mean?

$$
R^2=\dfrac{SS_{Reg}}{SS_Y}=1-\dfrac{RSS}{SS_Y}
$$

$$
R^2_{adj}=1-\dfrac{(1-R^2)(n-1)}{n-p}
$$

```         
-   Our explanatory variables crime rate, zn, and indus explain about $29.4\%$ (adjusted $r^2 = 28.9\%$) of variation in median home values across suburbs.
```

```r

broom::augment(m_medv) |> # adds residuals & predictions
  mutate(SS_Y = (medv - mean(medv))^2, # deviations of Y
         RSS = .resid^2) |> # squared residuals
  summarise(
    
    # calculate r_squared v
    r_squared = 1 - (sum(RSS) / sum(SS_Y)),
    
    # adjusted r_squared
    adj_r_squared = 1 - ( 
      (1 - r_squared) * (n() - 1) ) /
      (n() - length(m_medv$coefficients)) # sample size - # of parameters
    
  )

```

<br> <br>

## 2. Fit a simple linear regression model with medv as a function of zn and compare it to the model from question 1 using the global F test and one other method.

-   Which model do you prefer based on the results of the comparison?

    -   We use a General F test to examine which model to keep by testing the Null hypothesis that $H_0 = RSS_{reduced} = RSS_{full}$ and we reject the Null hypothesis suggesting that the Residual Sum of Squares for the simple linear model is higher than the less parsimonious model with three predictors. Therefore, the more complex model minimizes the residuals at the expense of more predictors included in the model.

    -   We also examine the r_squared of the simple model, and the adjusted r-square of the three predictor model and find that our simple model leaves a lot of unexplained variability in median home values. The model with more predictors, (predictors = crim, zn, and indus), explains $29\%$ of the variance in median home value, while the reduced model (predictor = zn) explains $13\%$ of the variance in median home value. The adjusted R-squared adjusts for multiple predictors in the model, therefore, we report the adjusted $adj \space R^2$ when interpreting the model with more predictor.

    -   With a higher R-squared and lower sigma-squared (i.e variance), the full model is a better fit to the data and minimizes the residuals more so than the simple 1-predictor model.

```r
m_simple <- lm(medv ~ zn, data = Boston)

summary(m_simple)

anova(m_simple, m_medv)

message(
  str_c(cat(
    "The R-squared for the simple model is ", 
        round(summary(m_simple)$r.squared, 3), 
        " (adjusted R-squared ", 
        round(summary(m_simple)$r.squared, 3), ").\n"
    ), 
        cat(
          " The adjusted R-squared for the model with 3 predictors is ",
        round(summary(m_medv)$adj.r.squared, 3) 
        )
    )
)
```
