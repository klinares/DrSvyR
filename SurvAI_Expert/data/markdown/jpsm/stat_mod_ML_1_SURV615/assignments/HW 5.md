---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/HW_5"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "Homework 5"
original: "stat_mod_ML_1_SURV615/assignments/HW 5.Rmd"
pages: 
sha256: "ae0bbb8d092477df0505119392e65b2f59542cecef78779dbabf44315c5f4fad"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:13"
---


```r
knitr::opts_chunk$set(echo = TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)
```

# This exercise involves the Boston housing dataset in ISLR2. Assume that we are interested in median home values, medv.

```r
library(ISLR2)
library(dplyr)
library(gridExtra)
library(grid)
library(ggeffects)
library(ggplot2)
library(knitr)
library(tidyverse)

data(Boston) 
```

```r
head(Boston, 4) |> kable()
```

```r
tail(Boston, 4) |> kable()
```

```r
glimpse(Boston) 

# convert chas into a factor variable, chas=0 as the reference group
Boston$chas_f <- factor(Boston$chas, levels=c("0", "1"))

class(Boston$chas_f)
levels(Boston$chas_f)
```

\newpage

## 1. Examine medv as a function of chas in a simple linear regression model with an intercept. Notice the nature of chas for its use in this and following models. What hypothesis are you testing with each coefficient in lay terms? Given the results of the hypothesis testing, what do the coefficients mean?

-   Intercept ($\beta_0$)

    -   $H{_0}$: $\beta_0 = 0$, The mean expected median home value for owner occupied homes in suburbs not bounding the Charles River equals zero.

    -   $H{_A}$: $\beta_0 \ne 0$. The mean expected median home value for owner occupied homes in suburbs not bounding the Charles River does not equal zero.  
        
        - Reject the null (p-value\<0.05), the mean expected median home value of \$22,094 for owner occupied homes in suburbs not bounding Charles River does not equal zero. 

-   Slope ($\beta_1$)

    -   $H{_0}$: $\beta_1 = 0$ the expected mean difference in median home values for owner occupied homes in suburbs not bounding Charles River (reference group), and suburbs bounding the Charles River is equal to zero.

    -   $H{_A}$: $\beta_1 \ne 0$ the expected mean difference in median home values for owner occupied homes in suburbs that bound or do not bound the charles river is not equal to 0.

        -   Reject the null (p-value<0.05) the difference in the mean expected median home value for owner occupied homes in suburbs that bound or do not bound the Charles River is not equal to zero. Owner occupied homes in suburbs that bound the Charles River have on average an expected median value of \$6,346 more than owner occupied homes in suburbs that do not bound the Charles River. The mean expected median home value for owner occupied homes that bound the Charles River $= \beta_0 + \beta_1 = \$28,440$.

\newpage
 
```r
Boston$chas_f <- as.factor(Boston$chas)

# median home value as a function of Charles River bounds
model_medv_chas <- lm(formula=medv ~ chas_f, Boston) 
summary(model_medv_chas)

```

\newpage

## 2. Examine medv as a function of chas and indus in a multiple linear regression. What do the coefficients mean?

-   $\beta_0$: \$29,432 is the mean expected median value for owner-occupied homes in suburbs that do not bound the Charles River and whose proportion of non-retail business acres per town is zero.

-   $\beta_1$: \$7,478 is the expected mean difference in median value of owner-occupied homes in suburbs that that do not bound (reference group) versus bound the Charles River while holding indus (proportion of non-retail business aces per town) constant. 

    -   Therefore, $\beta_0 + \beta_1) = \$36,910$ is the mean expected median value of owner-occupied homes in suburbs that bound the Charles River for suburbs with zero proportion of non-retail business acres per town.

-   $\beta_2$: one unit increase in proportion of non-retail business acres per town is associated with $666 decrease in the mean expected median value of owner-occupied homes while holding indus (proportion of non-retail business aces per town) constant. 

\

```r
model_medv_chas_indus <- lm(formula=medv ~ chas_f + indus, Boston) 
summary(model_medv_chas_indus)
class(Boston$indus)
```

\newpage

## 3. Given the results from #1 and #2, what do you conclude about chas and indus in relation to medv? Support your conclusion with a visualization.

-   The full model (with chas and indus) has an $R^2 = 0.2765$, meaning that this set of predictors explain 27.7% of the variability in our outcome's values, while the reduced model (with chas only) has an $R^2 = 0.03072$ and explains only 3.1% of the variability in our outcome's values. The full model with 503 degrees of freedom reduces the residual sum of squares by 10,498 (F-test=170.85, p<.05) compared to the reduced model with 504 degrees of freedom. Taken together, the more complicated model is a better fit and explains more variation in our $Y$ variable and significantly minimizes the least squares, and we conclude that variables chas and indus has a linear relationship with to median home values. 


```r
anova(model_medv_chas, model_medv_chas_indus)
```

```r
# Relationship between median home value, river bounds, & industrial acres
ggpredict(model_medv_chas_indus, terms = c("indus","chas_f")) %>% 
  plot(add.data=TRUE, ci=TRUE)  
```
\newpage

##  4. You think that the proportion of non-retail business acres may have a different impact on the expected average median home values in towns bordering the Charles River vs. those that don’t. Fit a linear regression model with an interaction term to assess this. What do you observe? Support your observations with a visualization.

-   The proportion of non-retail business acres does have a different impact (higher rate of change) on the expected average median home values for owner occupied homes in suburbs bordering the Charles River as proportion of non-retail business acres increase as indicated on the graphs below.

```r
model_chas_indus <- lm(medv ~ chas_f*indus, Boston) 
summary(model_chas_indus)
```

```r
# violin_y<-ggplot(aes(x=as.factor(chas), y=medv, 
#                      color=as.factor(chas)), data=Boston)+
#   geom_violin(trim=T)+
#   stat_summary(fun=mean, geom="point", size=1, color="brown")+
#   theme(legend.position="none")
# violin_y
```

```r
 #interaction of medv, river boundary, and industrial acres
ggpredict (model_chas_indus, terms = c("indus", "chas_f")) %>% 
  plot(add.data=TRUE, ci=FALSE)        
```

```r
# 
# indus<-ggplot(aes(x=indus,y=medv),data=Boston)+
#   geom_smooth(method="lm", se=FALSE)
# 
# chas<-ggplot(aes(x=chas, y=medv, color=chas),data=Boston)+
#   geom_violin(trim=T)+
#   stat_summary(fun=mean, geom="point", size=3, color="purple")+
#   theme(legend.position="none")
# 
# int<-ggplot(aes(x=indus,y=medv),data=Boston)+
#   facet_grid(~chas)+
#   geom_smooth(method="lm", se=FALSE) 
# grid.arrange(indus,chas,int, layout_matrix=rbind(c(1,2),c(3,3)))
# int
```
