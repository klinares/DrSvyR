---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class3_Lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 3 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class3_Lab_nocode.Rmd"
pages: 
sha256: "b6fc458e21ada7d25300f0edf72c2ba1c1fda9d7ddbef4f35c3af6a61734484a"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---


```r
knitr::opts_chunk$set(echo = TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE)

library(tidyverse)
```

## Import Income2.csv using either the read.csv() or read_csv() function (available on Canvas as well as JWHT Website) and explore the data.

```r
dat <- read_csv("~/UMD/classes/stat_mod_ML_1_SURV615/class_3/Income2.csv")
glimpse(dat)
```

## Treat \texttt{Income} as $Y$ and work on the following questions.<br>

### 1. What is the mean of \texttt{Income}?

- The mean of income is 62.7.

```r
dat |> summarise(mean(Income), sd(Income))
```



### 2. Examine \texttt{Income} in linear regression with no predictor and save the model as an object called "no_pred". Use the summary function to examine the model.

```r
no_pred <- lm(Income~1, data=dat)
summary(no_pred)
```

A. What parameter are you estimating in the model? How would you interpret the estimate? How would you put these into a formula?

- We are estimating the Intercept denoted as $\beta_0$, and we estimate the expected average value of Income as `r coef(no_pred)[[1]]` and we can write it as $\overline{Income_i} = \beta_0 + \epsilon_i$.



B. What are the residuals and what do they represent? How can you extract the estimates below "Coefficients" when you run summary(no_pred)?

- The residuals are the differences between the observed and expected value, unexplained error not explained by our model. Residuals are centered at zero and have a range of $-.45 \space and \space .37$ in this model. 


C. How does results from the regression model compare to the mean in #1?

- When there are no explanatory variables in the model, our intercept is our expected value and in this case the observed mean is our best "guess" for predictions.


### 3. Examine \texttt{Income} as a fuction of \texttt{Education} in linear regression. Explore the results using the summary() function and by extracting the regression coefficients (together and separately).

```r
mod_edu <- lm(Income ~ Education, data = dat)
summary(mod_edu)
```


A. What is this type of linear regression model called? How would you put this into a formula?

- This is a simple linear regression model with one explanatory variable and we would express this as $\overline{Income_I} = \beta_0 + \beta_1\times Education_i + \epsilon_i$

B. Is the result the same as the one from #2?

- They are not the same as we now specify that income is a function of education and thus have a slope in our model. 


### 4. Examine \texttt{Income} as a fuction of \texttt{Education} with no intercept in linear regression.

```r
mod_edu_no_int <- lm(Income ~ Education + 0, data = dat)
summary(mod_edu_no_int)
```

A. How would you put this into a formula?

- We would express this model as $\overline{Income_i} =  \beta_1\times Education_i + \epsilon_i$ as we drop the intercept parameter. 


B. Is the result the same as the one from #3? Do you have concerns about this modeling approach?

- The results are not the same as we dropped the intercept and kept the parameter for education. I am concerned about dropping the intercept in this case as the interpretability of this model is reduced and offers us no value.

### 5. Examine \texttt{Income} as a function of \texttt{Seniority} in linear regression

```r
mod_sen <- lm(Income ~ Seniority, data = dat)
summary(mod_sen)
```

A. How would you put this into a formula?

- We would express this model as $\overline{Income_i} = \beta_0 + \beta_1\times Seniority_i + \epsilon_i$


B. How does this compare to the result in #3? How would you interpret the coefficient for seniority?

- The model with education has a lower residual sum of squares, thus reduces residuals more so than the model with seniority. We interpret the slope of seniority as for every one month increase of seniority income is expected to increase by .25. When seniority is 0, the expected mean of income is 39.


### 6. Examine \texttt{Income} as a function of \texttt{Education} and \texttt{Seniority} in linear regression


```r
mod_edu_sen <- lm(Income ~ Education + Seniority, data=dat)
summary(mod_edu_sen)
```

A. How would you put this into a formula?

$\overline{Income_i} = \beta_0 + \beta_1\times Education_i +\beta_2\times Seniority_i + \epsilon_i$


### 7. Do #2-6 seem to make sense?

- Models with education and seniority makes sense since they have a positive relationship with income. However, having both in the model also makes sense, yet in our sample we do not have have anyone with 0 education and 0 seniority realistically.


### 8. Can you use results from #2-6? Why and why not?

- We may need to center both of these variables and remodel again. We cannot infer on a causal outcome.



