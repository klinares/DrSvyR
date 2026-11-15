---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class7_lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 7 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class7_lab_nocode.Rmd"
pages: 
sha256: "a0c7bf976e48a1c12e5901e1d8902dceeff3c583f12a4f9581a6781e61d4ee55"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:13"
---



```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)
```

  

```r
library(ISLR2)
library(dplyr)
library(gridExtra)
library(grid)
library(tidyverse)
```


##  <br> We'll start with the Wage data from the ISLR2 package. <br>

```r
data(Wage)
head(Wage)
```


### 1. What is the mean of \texttt{wage} by \texttt{jobclass}? What is the difference in the mean of \texttt{wage} by \texttt{jobclass}?
```r
Wage |> group_by(jobclass) |> summarise(mean_est = mean(wage)) |> mutate(diff = mean_est - lag(mean_est))
```

### 2. Fit a model with \texttt{wage} as a function of \texttt{jobclass} with and without an intercept. What do the coefficients mean? How are they related to the results from #1?
-   Industrial is the reference group
-   Model with intercept, the difference in wage by jobclass is 17.3, the expected average wage for jobclass = industrial is 103.3, while for information is (103.3 + 17.3) 120.6.

- It's more work to interpret the model with the intercept, except this will be problematic for models with more predictors.
```r
fit_no_int <- lm(wage ~ 0 + jobclass, Wage)

fit_int <- lm(wage ~ jobclass, Wage)

summary(fit_no_int) 
summary(fit_int)
```


### 3. Examine the ANOVA table of the two models from #2. What do you observe? 
-   The RSS for the models are the same the DFs are equal, despite different parameters being estimated. The F test is NA.
```r
anova(fit_no_int, fit_int)
```

### 4. Calculate the mean of \texttt{wage} by \texttt{race}; Fit a simple linear regression of \texttt{wage} as a function of \texttt{race}; Obtain ANOVA table of the regression model
- To make it easier for us, we need to dummy code race, or use the I function, reference group is white.
```r
Wage |> group_by(race) |> summarise(mean_est = mean(wage)) |> mutate(diff = mean_est - lag(mean_est))

fit_race <- lm(wage ~ race, Wage)

summary(fit_race)

anova(fit_race)
```

\newpage


### 6. How about \texttt{year}? Try \texttt{year} as a continuous predictor as well as a categorical predictor in a regression model. Observe $F$ values and $df$'s.
```r

fit_age <- lm(wage ~ year, Wage)
summary(fit_age)
```

```r

fit_age_c <- lm(wage ~ as.factor(year), Wage)
summary(fit_age_c)

```

### 7. \texttt{wage} as a function of \texttt{jobclass} and \texttt{year} (first as a categorical variable and then a continous variable), and their interaction.

A. \texttt{year} as a categorical variable.

\small
```r
fit_wage_job_year_c <- lm(wage ~ jobclass + factor(year), Wage)
summary(fit_wage_job_year_c)
```
\normalsize



B. \texttt{year} as a continous variable.
```r

fit_wage_job_year <- lm(wage ~ jobclass + year + jobclass*year, Wage)
summary(fit_wage_job_year)
```

$y_i=\gamma_0+\gamma_2d_{2i}+\gamma_3x_i+\gamma_4d_{2i}x_i+\epsilon_i$
* What are $\gamma_0$, etc.?

```r

```

### 8. \texttt{wage} as a function of \texttt{year} (as a continuous predictor), \texttt{race} and their interaction. Also, try to set \texttt{race}="3. Asian" as the reference category.
\small
```r

```

```r
```
\normalsize

### 9. Visual examination of #8 

A. Violin plot of \texttt{wage} ~ \texttt{year} with the subgroup means displayed on the violins
```r
violin_y<-ggplot(aes(x=as.factor(year), y=wage, 
                     color=as.factor(year)), data=Wage)+
  geom_violin(trim=T)+
  stat_summary(fun=mean, geom="point", size=2, color="black")+
  theme(legend.position="none")
violin_y
```

B. Violin plot of \texttt{wage} ~ \texttt{race} with the subgroup medians displayed on the violins
```r
violin_r<-ggplot(aes(x=race, y=wage, color=race),data=Wage)+
  geom_violin(trim=T)+
  stat_summary(fun=median, geom="point", size=2, color="red")+
  theme(legend.position="none")
violin_r
```


C. Regression lines of \texttt{wage} ~ \texttt{year} by \texttt{race}
```r
int<-ggplot(aes(x=year,y=wage),data=Wage)+
  facet_grid(~race)+
  geom_smooth(method="lm", se=FALSE)
int
```

D. Boxplot of \texttt{wage} ~ \texttt{race} by \texttt{year} 
```r
ggplot(aes(x=race,y=wage, color=race),data=Wage)+
  facet_grid(~year)+
  geom_boxplot()+
   stat_summary(fun=mean, geom="point", size=2, color="black")+
   theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

```

E. Putting plots into one
```r
layout <- rbind(c(1,2),
                c(3,3))

grid.arrange(violin_y, violin_r, 
             int, layout_matrix=layout)
```

