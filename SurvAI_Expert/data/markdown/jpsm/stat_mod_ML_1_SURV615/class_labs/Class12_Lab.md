---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class12_Lab"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 12 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class12_Lab.Rmd"
pages: 
sha256: "19d36076f8c3a95f5933a94f833a83809cd9e2154867ccfe38c4fce4acf574ab"
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
library(ggplot2)
library(gridExtra)
library(grid)
library(mgcv)
library(dplyr)
library(MASS)
library(faraway)
```

## 1. Variable tranformation

* From Class 12 lecture notes p.14-16
* We will use simulated data as follows.

```r
id<-c(1:1000)
set.seed(9); x<-rnorm(1000,7,4)
set.seed(123); e<-rnorm(1000,0,1)

y1<-1.5+0.3*x+e
y2<-1.5+5*log(x+6)+e
y3<-1.5+3*1/x+e
y4<-exp(1.5-0.3*x+e)-1
y5<-1/(1.5+3*x+e)
y6<-exp(1.5+3*log(x+6)+e)

dat<-as.data.frame(cbind(id,x,y1,y2,y3,y4,y5,y6))
```
 

### 1.A. Relationship between \texttt{x} and \texttt{y1}~\texttt{y6} without transformation

```r
p_y1<-ggplot(dat,aes(x, y1)) +  geom_point() +   
  geom_smooth(method='lm',formula= y1~x,color="red",se=F)
p_y2<-ggplot(dat,aes(x, y2)) +  geom_point() +   
  geom_smooth(method='lm',formula= y2~x,color="red",se=F)
p_y3<-ggplot(dat,aes(x, y3)) +  geom_point() +   
  geom_smooth(method='lm',formula= y3~x,color="red",se=F)
p_y4<-ggplot(dat,aes(x, y4)) +  geom_point() +   
  geom_smooth(method='lm',formula= y4~x,color="red",se=F)
p_y5<-ggplot(dat,aes(x, y5)) +  geom_point() +   
  geom_smooth(method='lm',formula= y5~x,color="red",se=F)
p_y6<-ggplot(dat,aes(x, y6)) +  geom_point() +   
  geom_smooth(method='lm',formula= y6~x,color="red",se=F)

grid.arrange(p_y1, p_y2, p_y3, p_y4, p_y5, p_y6, ncol=3)
```

### 1.B. Relationship between \texttt{x} and \texttt{y1}~\texttt{y6} with transformation

```r
p_ty2<-ggplot(dat,aes(log(x+6), y2)) +  geom_point() +   
  geom_smooth(method='lm',formula= y2~log(x+6),color="red",se=F)
p_ty3<-ggplot(dat,aes(I(1/x), y3)) +  geom_point() +   
  geom_abline(intercept=summary(lm(y3~I(1/x), dat))$coef[1],
              slope=summary(lm(y3~I(1/x), dat))$coef[2],color="red",size=1)
p_ty4<-ggplot(dat,aes(x, log(y4+1.01))) +  geom_point() +   
  geom_smooth(method='lm',formula= log(y4+1.01)~x,color="red",se=F)
p_ty5<-ggplot(dat,aes(x, I(1/y5))) +  geom_point() +   
  geom_smooth(method='lm',formula= I(1/y5)~x,color="red",se=F)
p_ty6<-ggplot(dat,aes(log(x+6), log(y6))) +  geom_point() +   
  geom_smooth(method='lm',formula= log(y6)~log(x+6),color="red",se=F)

grid.arrange(p_y1, p_ty2, p_ty3, p_ty4, p_ty5, p_ty6, ncol=3)
```

### 1.C. Box-Cox Transformation
-   Add 1 in boxcox in y4 to make values positive b/c negatives and zeros causes problems in log. Same for the other values. 
```r

#We already know
#y4<-exp(1.5-0.3*x+e)-1 
#   -->  y4+1<-exp(1.5-0.3*x+e) --> log(y4+1)<-1.5-0.3*x+e
#y5<-1/(1.5+3*x+e)
#y6<-exp(1.5+3*log(x+6)+e)

#boxcox(lm(y4~x,dat))
summary(y4) # what do you see from this that tells you why you add 1 in the model below?
boxcox(lm((y4+1)~x,dat))

#boxcox(lm(y5~x,dat))
summary(y5) # what do you see from this that tells you why you add 243 in the model below?
boxcox(lm((y5+243)~x,dat)) 

summary(y6)
boxcox(lm(y6~x,dat))

# find appropriate log transformation
summary(dat$y4) 
logtrans(lm(y4~x,dat), alpha = seq(1,4, len=10)) 
```

### 1.D. Box-Cox tranformation for a model using \texttt{diabetes} data in \texttt{faraway} 

* Description: 403 African Americans were interviewed in a study to understand the prevalence of obesity, diabetes,
and other cardiovascular risk factors in central Virginia.
* A data frame with 403 observations on the following 19 variables.
  + \texttt{id}: Subject ID
  + \texttt{chol}: Total Cholesterol
  + \texttt{stab.glu}: Stabilized Glucose
  + \texttt{hdl}: High Density Lipoprotein
  + \texttt{ratio}: Cholesterol/HDL Ratio
  + \texttt{glyhb}: Glycosolated Hemoglobin
  + \texttt{location}: County - a factor with levels Buckingham Louisa
  + \texttt{age}: age in years
  + \texttt{gender}: a factor with levels male female
  + \texttt{height}: height in inches
  + \texttt{weight}: weight in pounds
  + \texttt{frame}: a factor with levels small medium large
  + \texttt{bp.1s}: First Systolic Blood Pressure
  + \texttt{bp.1d}: First Diastolic Blood Pressure
  + \texttt{bp.2s}: Second Systolic Blood Pressure
  + \texttt{bp.2d}: Second Diastolic Blood Pressure
  + \texttt{waist}: waist in inches
  + \texttt{hip}: hip in inches
  + \texttt{time.ppn}: Postprandial Time (in minutes) when Labs were Drawn

* We are interested in \texttt{glyhb} as an outcome variable and \texttt{gender}, \texttt{age}, \texttt{chol} and \texttt{stab.glu} as independent variables

```r
data(diabetes,package = "faraway")
summary(diabetes)
diab<-na.omit(diabetes[,c("glyhb","gender","age","chol","stab.glu")]) # remove missing 
```

```r
mod<-lm(glyhb~.,diab)
sumary(mod)
plot(mod$fitted.values,mod$residuals); abline(h=0,col="red")

boxcox(mod)
```

```r
tmod<-lm(I(1/glyhb)~.,diab)
summary(mod)
summary(tmod)
plot(tmod$fitted.values,tmod$residuals); abline(h=0,col="red")
```
* Did transforming y help?

### 1.E. Polynomials



```r
id<-c(1:1000)
set.seed(9); x<-rnorm(1000,-3,5)
set.seed(123); e<-rnorm(1000,0,10)

y7<-1.5+3*x+3*x^2+e
y8<-1.5+3*x+3*x^2-3*x^3+e
dat2<-as.data.frame(cbind(id,x,y7,y8))
```

```r
ggplot(dat2,aes(x, y7)) + geom_point() +   
  geom_smooth(method='lm', formula= y7~x, color="red" ,se=F)

ggplot(dat2,aes(x, y8)) + geom_point() +   
  geom_smooth(method='lm', formula= y8~x, color="red" ,se=F)

ggplot(dat2,aes(x+x^2, y7)) + geom_point() +   
  geom_smooth(method='lm', formula= y7~x+x^2, color="red" ,se=F)

ggplot(dat2,aes(x+x^2+x^3, y8)) + geom_point() +   
  geom_smooth(method='lm', formula= y8~x+x^2+x^3, color="red" ,se=F)
```

* Fitting models with polynomials
```r
sumary(lm(y7~x,dat2))
sumary(lm(y7~x+(x^2),dat2)) # this is why we need to wrap x^2 in I
sumary(lm(y7~x+I(x^2),dat2))
```

```r
sumary(lm(y8~x,dat2))
sumary(lm(y8~x+I(x^3),dat2))
sumary(lm(y8~x+I(x^2)+I(x^3),dat2))
```


### 1.F. General Additive Models
```r

mod<-lm(glyhb~gender+age+chol+stab.glu,diab)
amod<-gam(glyhb~gender+s(age)+s(chol)+s(stab.glu),data=diab) # wrapping predictor in s() when using gam() instead of lm() tells R we want to model this predictor using a spline term
plot(amod)

pmod<-lm(glyhb~gender+age+chol+I(chol^2)+I(chol^3)+I(chol^4)+
                 stab.glu+I(stab.glu^2),diab)

summary(mod)
summary(amod) # find edf in the summary -- this is the terms effective degrees of freedom -- the larger the edf the more wiggly the spline
summary(pmod)
```

```r
#model fit comparison
summary(mod)$sigma^2; summary(amod)$sp.criterion; summary(pmod)$sigma^2 
summary(mod)$r.sq; summary(amod)$r.sq; summary(pmod)$r.sq
AIC(mod);AIC(amod);AIC(pmod)
```


## 2. Model Selection


### 2.A. Criterion-based selection

```r
names(diabetes)
diab<-subset(diabetes, 
             select=-c(id, location, gender, frame, bp.2s, bp.2d))%>%
        na.omit() #for stepAIC

mod<-lm(glyhb~.,diab)
sumary(mod)
```

* Using AIC 
```r
AIC(mod)
diabetes2 <- diabetes %>% 
  dplyr::select(-"bp.2s", -"bp.2d") %>% 
  na.omit()
library(leaps)
sub<-regsubsets(glyhb~.,diab)
regsubsets(glyhb~.,force.in=c(4), diab) ## force R to keep chol (4th column) in model 
names(diabetes)

rsub<-summary(sub)
names(rsub)

rsub$which # tells you which predictors included for each iteration of model

dim(diab)
n<-dim(diab)[1]
n

aic<-n*log(rsub$rss/n)+c(2:5)*2 # 2:5 because we are looking at 4 different models containing 2-5 parameters

plot(I(1:8), aic, ylab="AIC", xlab="# Predictors")
```

* Using Adjusted $R^2$ 
```r
plot(I(1:8), rsub$adjr2, ylab="R^2_adj", xlab="# Predictors")
```

* Using Mallow's $C_p$
```r
plot(I(1:8), rsub$cp, ylab="Mallow's Cp", xlab="# Predictors")
```
* Based on the plots above, how many predictors would you expect to be in the final model using this variable selection method?

* If you believe some predictors must be included in the model, you can specify them in regsubsets as follows: 
  
```r
test<-regsubsets(glyhb~.,force.in=c("chol","weight","hip"),
                 diabetes, method=c("exhaustive"))
```

  + This will ensure that regardless whatever predictor subsets are tested, they will include predictors.  

 
### 2.B. Backward elimination based on p-value
```r
mod <- lm(glyhb ~., diab)
sumary(mod)

sumary(update(mod,.~. -hdl)) # - in front of variable tells R we want to drop the variable(s) and refit
sumary(update(mod,.~. -hdl-bp.1d))
sumary(update(mod,.~. -hdl-bp.1d-bp.1s))
sumary(update(mod,.~. -hdl-bp.1d-bp.1s-hip))
sumary(update(mod,.~. -hdl-bp.1d-bp.1s-hip-height))
sumary(update(mod,.~. -hdl-bp.1d-bp.1s-hip-height-weight))
sumary(update(mod,.~. -hdl-bp.1d-bp.1s-hip-height-weight-waist))
```



### 2.C. Backward elimination, Forward elimination and Stepwise selection based on AIC
```r
library(MASS)
back.mod <- stepAIC(mod, direction = "backward") #from MASS package
sumary(back.mod)
back.mod$anova

for.mod <- stepAIC(mod, direction = "forward")
sumary(for.mod)
for.mod$anova

step.mod <- stepAIC(mod, direction = "both")
sumary(step.mod)
step.mod$anova
```
* How can you see the final model from the different selection methods?
* How can you see the progression of different models (leading to the final model) in each selection process?
 
### 2.D. Problem with technical model selection

* From Class 12 lecture note p. 
```r
set.seed(13)
dat <- data.frame(matrix(data = rnorm(2100, 0,1), 
                         nrow = 100, ncol = 21))
colnames(dat)<-c("x1","x2","x3","x4","x5",
                 "x6","x7","x8","x9","x10",
                 "x11","x12","x13","x14","x15",
                 "x16","x17","x18","x19","x20","y")

dat.mod<-lm(y~.,dat)
summary(dat.mod)
sumary(stepAIC(dat.mod,direction = "both"))
```

* What do you see in dat.mod? Is this what you expected? Why/why not?

* What do you see in the final model from step-wise selection? Do you think this is a good model? Why/why not?

