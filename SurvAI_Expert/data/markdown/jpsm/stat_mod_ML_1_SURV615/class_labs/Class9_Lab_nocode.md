---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class9_Lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 9 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class9_Lab_nocode.Rmd"
pages: 
sha256: "24e8aa407cad9a0290d31a183843b3a44840d45eb4f9148eb39f4eced909c3be"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---



```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)
```

  
  
## 1. Checking assumptions about errors through residuals  

### 1.A. Let's use cheddar data from faraway

* Description: In a study of cheddar cheese from the LaTrobe Valley of Victoria, Australia, samples of cheese were analyzed for their chemical composition and were subjected to taste tests. Overall taste scores were obtained by combining the scores from several tasters.

* Format: A data frame with 30 observations on the following 4 variables.
  + \texttt{taste}: a subjective taste score
  + \texttt{Acetic}: concentration of acetic acid (log scale)
  + \texttt{H2S}: concentration of hydrogen sulfice (log scale)
  + \texttt{Lactic}: concentration of lactic acid
   


```r
library(faraway)
library(performance)
library(car)
data(cheddar)
summary(cheddar)
```

* Fit a linear regression model with taste as a function of Acetic, H2S, and Lactic.
```r
mod_cheddar <- lm(taste ~ Acetic + H2S + Lactic, cheddar)
summary(mod_cheddar)
```

### 1.B. Brief check on the distribution of residuals, $\hat{\epsilon}$.

* Think about mean, constant variance and normal distribution, are the mean of our residuals around 0?
```r
summary(resid(mod_cheddar))
```

```r
hist(resid(mod_cheddar))
plot(density(resid(mod_cheddar))) 
qqplot(resid(mod_cheddar), fitted(mod_cheddar))

```
 
* Graphically assess the zero mean error and constant variance assumptions using the code below.
```r
residualPlots(mod_cheddar,
                   pch=20, col="gray",
                   fitted = T, terms = ~ .,
                   tests = F, quadratic = F)

```



```r
check_model(mod_cheddar)
model_performance(mod_cheddar)
```


What do you conclude?

-   It seems that we have non-constant variance based on the residual vs fitted value plot.



* Assess numerically whether the constant variance assumption appears to be met.

-   No evidence of heteroscadasticity, above we do not see trend, correlation is small, 

```r
cor(fitted(mod_cheddar), resid(mod_cheddar))

summary(lm(resid(mod_cheddar) ~ fitted(mod_cheddar)))

var.test(resid(mod_cheddar)[fitted(mod_cheddar)<=20],
         resid(mod_cheddar)[fitted(mod_cheddar)>20])
```


* How is the graphical approach useful? How about numeric/statistical approaches?
```r
plot(fitted(mod_cheddar),sqrt(abs(resid(mod_cheddar))))
cor(fitted(mod_cheddar),sqrt(abs(resid(mod_cheddar))))

plot(cheddar$Acetic,resid(mod_cheddar))+
abline(h=0,col="blue")
cor(cheddar$Acetic,resid(mod_cheddar))

plot(cheddar$H2S,resid(mod_cheddar))+
abline(h=0,col="blue")
cor(cheddar$H2S,resid(mod_cheddar))

plot(cheddar$Lactic,resid(mod_cheddar))+
abline(h=0,col="blue")
cor(cheddar$Lactic,resid(mod_cheddar))
```



* Assess whether the residuals from the model are normally distributed graphically and statistically.

-   shapiro, is distribution normall, Null is normal, alt not normal. We failed to reject, might not be normal. 
```r
qqnorm(resid(mod_cheddar))
shapiro.test(resid(mod_cheddar))
```

* What do you conclude about the residuals?
 



## 2. Use \texttt{perfect\_add5} data and examine the existence of unusual observations

```r
id<-c(1:100)
set.seed(312)
x<-rnorm(100,15,5)
set.seed(135)
e<-rnorm(100,0,4)
y<-10+3*x+e

perfect<-as.data.frame(cbind(id,y,x))

d<-c("id","y","x")

add5<-as.data.frame(setNames(list(c(181:200),
                                  c(sample(c(45:60),20,rep=T)),
                                  c(sample(c(15:20),20,rep=T))),d))
perfect_add5<-rbind(perfect,add5)
```



### 2.A. Leverage through hat (and half normal plots) and standardized (i.e., internally studentized) residuals 

* Fit a linear regression model using the perfect_add5 data with y as a function of x and then assess leverage using hat, half normal plots, and internally studentized residuals.
```r
mod_perfect_add5<-lm(y~x,perfect_add5)
hat<-hatvalues(mod_perfect_add5)  # from faraway package, does specific obs is unsual 
hat
sum(hat)
mean(hat)

hat>2*mean(hat)
```


```r
halfnorm(hat) #halfnorm() from faraway package
```

How do the high leverage observations compare to the overall distribution of x and y?
```r
perfect_add5[32,]
perfect_add5[48,]
summary(perfect_add5)
```


* Standardized residuals (i.e., internally studentized residuals)
```r
r_it<-rstandard(mod_perfect_add5)
sort(r_it)[1:10]
sort(r_it,decreasing=T)[1:10]
abs(sort(r_it)[1:10])>qt(1-.05/120,120-2)
```
Why did we divide our alpha value by 120?

* Assess the normality of the internally studentized residuals using a qq plot.
```r
qqnorm(r_it)

```

### 2.B. Outlier detection through (externally) studentized residuals
```r
summary(mod_perfect_add5)
r_ex<-rstudent(mod_perfect_add5)
sort(r_ex)[1:10]
sort(r_ex,dec=T)[1:10]

# divide by 10, for the bonferoni correction test adjusting critical value
abs(r_ex)>abs(qt(.05/10,10-2)) # get a pvlalue, greater than 

abs(r_ex)[111]
```


### 2.C. Influential observations through Cook's distance
```r
cd<-cooks.distance(mod_perfect_add5)
summary(cd)
sort(cd,dec=T)[1:10]
```

```r
halfnorm(cd)
```

```r
perfect_add5[c(32,107,111,113,114),]
summary(perfect_add5)
```


```r
plot(mod_perfect_add5)
```

### 2.D. Given results from #2.A to #2.C, what do we conclude about the influential observations in \texttt{perfect\_add5}? 

-   32, 107, 113, and 114 are influential in a way that they may be altering the relationship of the majority on the observations. Warrants examining the relationship without these observations. 

-   Alter fitting model and plotting, these isn't much impact because the points are working against each other. 

```r
plot(perfect_add5$x,perfect_add5$y)+
abline(lm(y~x,perfect),col="red")+
abline(lm(y~x,perfect_add5),col="blue")
```

## 3. Checking relationship structures through partial regression plots and partial residual plots using \texttt{cheddar} data

### 3.A. Partial regression:

```r
rd_taste<-residuals(lm(taste~Acetic+Lactic,cheddar)) 
rd_H2S<-residuals(lm(H2S~Acetic+Lactic,cheddar)) 
```

* What would \texttt{rd\_taste} mean? 
  + \texttt{taste} without the effects of \texttt{Acetic} and \texttt{Lactic}
* What would \texttt{rd\_H2S} mean?
  + \texttt{H2S} without the effects of \texttt{Acetic} and \texttt{Lactic}


```r
plot(rd_H2S,rd_taste)+
abline(0,coef(mod_cheddar)['H2S'], col="red")  
```

* Is the relationship between \texttt{rd\_taste} and \texttt{rd\_H2S} linear?

-   Yes, taste and h2s have a linear relationship. 

### 3.B. Partial Residuals
```r
termplot(mod_cheddar, partial.resid=T, terms=1)
termplot(mod_cheddar, partial.resid=T, terms=2)
termplot(mod_cheddar, partial.resid=T, terms=3)
# termplot() is a function that plots regression terms against their predictors
```


### 3.C. Regression on subsetted data
```r
summary(cheddar)
mod1<-lm(taste~Acetic+H2S+Lactic,subset(cheddar,H2S<=5.3))
mod2<-lm(taste~Acetic+H2S+Lactic,subset(cheddar,H2S>5.3))
sumary(mod1); sumary(mod2)
confint(mod1); confint(mod2) 
```

* What do you observe in the estimated coefficients of \texttt{H2S} in these models?

 
