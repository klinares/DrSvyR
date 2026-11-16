---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class13_Lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "Class 13 lab - no code"
original: "stat_mod_ML_1_SURV615/class_labs/Class13_Lab_nocode.Rmd"
pages: 
sha256: "9e7fb5b6b4f2b940514e0b10d23262a1b049935c39b362789883797a2859822f"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---




```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)
```


```r
library(dplyr)
library(ggplot2)
library(janitor)
library(faraway)
library(MASS)
```

## Data Set-Up

* We will \texttt{warpbreaks} data in R. 
* Description: The number of breaks in yarn during Weaving
  + This data set gives the number of warp breaks per loom, where a loom corresponds to a fixed length of yarn.
  + The type of wool and the level of weaving tension were randomly assigned to examine warp breaks.
* Format: A data frame with 54 observations on 3 variables.
  + \texttt{break}: numeric, The number of breaks
  + \texttt{wool}: factor, The type of wool (A or B)
  + \texttt{tension}: factor,	The level of tension (L, M, H)
* See https://rdrr.io/r/datasets/warpbreaks.html for detail of \texttt{warpbreak}
  

## 1. What design structure do you see?
- It is a balance design.
```r
data(warpbreaks)
summary(warpbreaks)
warpbreaks%>%
  tabyl(wool,tension) # tabyl() is from the janitor package
```

## 2. We will focus on \texttt{tension} as an experimental factor for \texttt{breaks} in this lab session.

### 2.A. Examine the pattern of \texttt{break} by \texttt{tension} using plots
-   Boxplot relatively linear association. The group means scatter plot included in the center, and the violin plot shows more clearly where data lies. The breaks + 3, if lower the means will go down. 
```r
ggplot(warpbreaks, aes(x=tension, y=breaks))+geom_boxplot()

ggplot(warpbreaks, aes(x=tension, y=breaks))+geom_point()
 
(means <- aggregate(breaks~tension,warpbreaks, mean)) # aggregate works similarly to group_by() and summarise() in dplyr. here we're calculating the mean of breaks with in each category of tension

ggplot(warpbreaks,aes(x=tension, y=breaks))+
  geom_point(position=position_jitter(width=0.1))+
  stat_summary(fun="mean",colour = "red")+
  geom_text(data = means, aes(label = breaks, y = breaks + 2))

# way too many digits after the decimal point so will round to 2 
ggplot(warpbreaks,aes(x=tension, y=breaks))+
  geom_violin()+
  stat_summary(fun="mean", colour = "red")+
  geom_text(data = means, aes(label = round(breaks,2), y = breaks + 3),color="red")
```
What is the stat_summary() function doing in each plot?
What happens if you change the number added to breaks in the last line of code?

### 2.B. One-way ANOVA of \texttt{breaks}
```r
summary(aov(breaks~tension,warpbreaks))
anova(lm(breaks~tension,warpbreaks))
summary(lm(breaks~tension,warpbreaks))
```
How do anova(), summary(aov()), and summary(lm()) compare?
-   aov() is equivalent to the OLS simple model. 


### 2.C. Tukey's honest significance difference test
```r
TukeyHSD(aov(breaks~tension,warpbreaks))
t.test(breaks~tension,subset(warpbreaks,tension!="H"))$p.value
t.test(breaks~tension,subset(warpbreaks,tension!="M"))$p.value
t.test(breaks~tension,subset(warpbreaks,tension!="L"))$p.value
```
How do the p values from TukeyHSD() compare to those from t.test()?
-   We can see the CI for each difference and adjusted p-value because we have multiple comparisons. 

### 2.D. Diagnostics for the error assumptions
```r
one<-lm(breaks~tension,warpbreaks)
summary(one)
anova(one)
qqnorm(one$resid);qqline(one$resid)
plot(jitter(one$fitted),jitter(one$resid));abline(h=0)
boxcox(lm(breaks~tension,warpbreaks))
```
What does the jitter function do?
-   spreads the data so they do not overlap.

What (if any) transformation of the outcome is suggested?
-   Transformation suggested log function.

### 2.E. One-way ANOVA of \texttt{breaks} with transformed \texttt{break}  

Fit a linear regression model with breaks as a function of tension. Transform breaks according to what you found in the previous question. Reassess OLS assumptions and conduct pairwise comparisons using TukeyHSD(). 
```r
one_t <- lm(log(breaks)~tension,warpbreaks)
summary(one_t)
qqnorm(one_t$resid);qqline(one_t$resid)
anova(one_t)
plot(jitter(one_t$fitted),jitter(one_t$resid));abline(h=0)

```
How do the OLS assumptions appear in the transformed model?
-   

How do the pairwise comparisons for each model compare? Any differences?
-   

## 3. Two-way ANOVA of \texttt{breaks} with both \texttt{tension} and \texttt{wool} without an interaction 

```r
summary(aov(breaks~tension+wool,warpbreaks))
summary(lm(breaks~tension+wool,warpbreaks))
```


## 4. Two-way ANOVA of \texttt{breaks} with both \texttt{tension} and \texttt{wool} with an interaction 

### 4.A. Graphical understanding
```r
ggplot(warpbreaks,aes(x=tension,y=breaks))+
  geom_point(position=position_jitter(width=0.2))+
  stat_summary(fun=mean, geom="point", color="red",size=2)+
  stat_summary(fun=mean, geom="line", 
               aes(group=wool, linetype=wool)) 
```

-   When more than 3 categories, it gets hard to read. We still see a decreasing trend from a to b for L and H
```r
ggplot(warpbreaks,aes(x=wool,y=breaks))+
  geom_point(position=position_jitter(width=0.2))+
  stat_summary(fun=mean, geom="point", color="blue",size=2)+
  stat_summary(fun=mean, geom="line", 
               aes(group=tension, linetype=tension)) 
```


### 4.B. Through modeling, add interaction term. : removes main effects, * adds interaction and main effects. 
```r
aov(breaks~tension*wool,warpbreaks)
aov(breaks~tension+wool+tension*wool,warpbreaks)
aov(breaks~tension+wool+tension:wool,warpbreaks)

summary(lm(breaks~tension*wool,warpbreaks))
aov(breaks~tension:wool,warpbreaks)
summary(lm(breaks~tension:wool,warpbreaks))
```
What is the difference between tension*wool and tension:wool?

### 4.C. Calculate the mean number of breaks by wool and tension.
```r
warpbreaks |>  group_by(wool, tension)  |>  summarise(m = mean(breaks))


```
Which combination has the lowest mean(breaks)?

Does this give you enough information to say whether the combination with the lowest number of breaks is significantly better than the others?

### 4.D. Pairwise comparison through Tukey's honest significance difference test
```r
# To assess whether one combination is significantly better than another we can conduct pairwise comparisons--making sure to account for multiple comparisons!
TukeyHSD(aov(breaks~tension*wool,warpbreaks))
# the notation of the pairwise comparisons or contrasts can be confusing, you can read it as follows. For M:A-L:A this is comparing the expected mean number of breaks using yarn A with medium tension (M:A) to the expected mean number of breaks using yarn A with low tension (L:A). H0 in this case would be that the difference between them = 0.

```


### 4.E. One-way ANOVA of \texttt{breaks} with \texttt{tension} as a random factor 
- lmer pacakge adds a random effect for tension, breaks vary by tension. we are interested in the variance of random effect, we are testing if the variance in the grouping contribute to the model. In this case, the CI does not contain 0, the variance from tension does contribute to the variability in the outcome. 
```r
library(lme4)
rmod_fixed <- lm(breaks ~ tension, warpbreaks)
summary(rmod_fixed)
rmod<-lmer(breaks~(1|tension), warpbreaks)
# (1|tension) means we are fitting as random effect 
summary(rmod)

confint(rmod, oldNames = FALSE) # oldnames = F tells R to use newer, more informative names for variance-covariance parameters
```
