---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class5_lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 5 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class5_lab_nocode.Rmd"
pages: 
sha256: "2e88cae6226c0ca8be85f81e7dc95875a298ebe71afc13ade43bb4ffe3c9eecc"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---



```r
knitr::opts_chunk$set(echo = TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

library(tidyverse)
options(scipen = 999)
```

  

##  <br> Use Income2.csv data with \texttt{Income} as the response variable. <br>
```r
inc <-read.csv("~/UMD/classes/stat_mod_ML_1_SURV615/class_3/Income2.csv")
```



### <br> 1. Consider the following three linear regression models (with an intercept). Interpret the coefficient estimates from each model. How do coefficients from models A and B compare to the ones from model C?
A. Income ~ Education
  - For every one year attained education, income is expected to increase by 6.4. When Education equals 0, we expect the average income to be -41.9

B. Income ~ Seniority
  - For every one year increase in seniority, income is expected to increase by .3. When Seniority equals 0, we expect the average income to be 39.2.

C. Income ~ Education + Seniority
- The coefficient on education from model A is slightly higher than model C, by about .50 income. 
- The coefficient on seniority from model B is slightly lower than model C, by about .08 income.
- The intercept in Model C is lower than both models A and B.
- F test, null predictors = to each other and  = 0. In one variable, compares predictor with intercept only.

```r
m_edu <- lm(Income ~ Education, inc)
summary(m_edu)

m_sen <- lm(Income ~ Seniority, inc)
summary(m_sen)

m_both <- lm(Income ~ Education + Seniority, inc)
summary(m_both)

```

## 2. Compute the residual, $\hat{\epsilon}_i$, from a simple linear regression model \texttt{Education~Seniority}. Regress \texttt{Income} on this residual (i.e., fit a model with Income as your outcome and the residuals you calculated as the predictor. What is the estimated slope coefficient? How does this compare to the coefficient estimate from the model #1.C? Given this, what is the meaning of this residual?
  - The estimated slope of the residual is 1, which is almost 2 units higher than model C. 
  - Meaning, 

```r
inc <- inc |> mutate(res =  resid(m_both))

m_resid <- lm(Income ~ res, inc)
summary(m_resid)
```
 
### NOTE. Useful functions related to \texttt{lm}
```r
summary(m_both)
summary.lm(m_both)
library(faraway)
sumary(m_both) # sumary() is from faraway package

coef(m_both)
m_both$coefficients
summary(m_both)$coeff
vcov(m_both)

fitted(m_both)
m_both$fitted.values
predict(m_both)

residuals(m_both)
m_both$residuals
summary(m_both)$resid

anova(m_both)
aov(m_both)

deviance(m_both) # -2 loglik
sum((inc$Income-predict(m_both))^2)

summary(m_both)$fstatistic
df.residual(m_both)
summary(m_both)$df

summary(m_both)$r.squared
summary(m_both)$adj.r.squared
```

### 3. Focus on the multiple linear regression model in #1.C. Examine the output.
 
```r
summary(m_both)
```

A. Use the code below to calculate t-values and p-values of the slope coefficients "by hand"? What do they allow you to do? Do they match what you get from summary(m_both)?

```r
df_both<-df.residual(m_both)

t_edu<-coef(m_both)[2]/sqrt(vcov(m_both)[2,2]) 
t_edu
p_edu<-2*pt(-abs(t_edu),df_both)
p_edu

t_sen<-coef(m_both)[3]/sqrt(vcov(m_both)[3,3]) 
t_sen
p_sen<-2*pt(-abs(t_sen),df_both)
p_sen

summary(m_both)
```
B. Construct 95% confidence interval of $\beta_1$.

```r
confint(m_both, 'Education', level=0.95)
```

C. How are the residual standard error and its degrees of freedom computed?

* We know $\hat{\sigma}=\sqrt{\dfrac{RSS}{df}}$.

```r
# computes RSS
sqrt(deviance(m_both)/df.residual(m_both))
summary(m_both)$sigma
```

D. How is $R^2$ calculated? How about adjusted $R^2$? What do they mean?

* From lecture note p. 54, $R^2=\dfrac{SS_{Reg}}{SS_Y}=1-\dfrac{RSS}{SS_Y}$ and  $R^2_{adj}=1-\dfrac{(1-R^2)(n-1)}{n-p}$

```r
1 - (sum(inc$res) /
       ( sum( (inc$Income - mean(inc$Income) )^2))
) 

```


E. What is the F-statistic here? How is this computed? What does it mean?

* From lecture note p. 49, $F=\dfrac{(SS_Y-RSS)/(p-1)}{RSS/(n-p)}$
```r
anova(m_both)
F_both<-((sum(anova(m_both)[,2])-anova(m_both)[3,2])/(3-1))/
  (anova(m_both)[3,2]/df.residual(m_both))
F_both
summary(m_both)
```
 
F. What does the anova table tell us?
  - 
```r
anova(m_both)
```
 
 
### 4. Test the following for the multiple regression model in #1.3.

A.  Are the effects of Education and Seniority the same? I.e., $H_0: \beta_1=\beta_2$. What do you think the I() in the formula is doing? 
```r
m_both1<-lm(Income~I(Education+Seniority), inc)
summary(m_both1)
anova(m_both1)
anova(m_both1,m_both)
```


B. Is the slope of Education 6? I.e., $H_0: \beta_1=6$. What do you think the offset() function in the formula is doing?
```r
m_both2<-lm(Income~offset(6*Education)+Seniority, inc)
summary(m_both2)
anova(m_both2)
anova(m_both2,m_both)
```

### 5. Is Income ~ Education + Seniority better than Income ~ Education? Use the code below to justify your answer. 

* We can examine this with $R^2$, $R^2_{adj}$, MSE and General F-test.
* From lecture note p. 51 and 54, General $F=\dfrac{(RSS_{Reduced}-RSS_{Full})/(p-q)}{RSS_{Full}/(n-p)}$ evaluated against  $F^{p-q}_{n-p}$. 
```r
summary(m_edu)$r.squared; summary(m_both)$r.squared

summary(m_edu)$adj.r.squared; summary(m_both)$adj.r.squared

summary(m_edu)$sigma^2; summary(m_both)$sigma^2
```

```r
GenF<-((deviance(m_edu)-deviance(m_both))/(3-2))/
  (deviance(m_both)/df.residual(m_both))
GenF

qf(0.05,3-2,df.residual(m_both), lower.tail = F)

pf(GenF,3-2,df.residual(m_both), lower.tail = F)
```

```r
anova(m_edu, m_both)
```


 
