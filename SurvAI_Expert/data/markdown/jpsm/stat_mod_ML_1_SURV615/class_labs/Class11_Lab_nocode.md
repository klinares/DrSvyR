---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class11_Lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 11 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class11_Lab_nocode.Rmd"
pages: 
sha256: "6f97ef188f0eea72a8512822b114f2cfcfc6d01772baec3d7a697f61366b8e40"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:13"
---



```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)
```

  
## 1. Problems with predictors 

### 1.A. Let's use cheddar data from faraway

* Description: In a study of cheddar cheese from the LaTrobe Valley of Victoria, Australia, samples of cheese were analyzed for their chemical composition and were subjected to taste tests. Overall taste scores were obtained by combining the scores from several tasters.

* Format: A data frame with 30 observations on the following 4 variables.
  + \texttt{taste}: a subjective taste score
  + \texttt{Acetic}: concentration of acetic acid (log scale)
  + \texttt{H2S}: concentration of hydrogen sulfice (log scale)
  + \texttt{Lactic}: concentration of lactic acid
  
* We will use \texttt{taste} as the outcome variable and the rest as predictors.

* On purpose, 
  + we will transform \texttt{H2S} back to the original scale; and
  + we will create another predictor \texttt{X4} as a function of \texttt{Lactic} and a random error. I.e., \texttt{X4} and \texttt{Lactic} are highly correlated (collinear). 

#### <br>


```r
library(faraway)
data(cheddar, package="faraway")

cheddar$H2S_OG<-exp(cheddar$H2S) # return H2S from log to original scale by exponentiating

set.seed(123)
X4_E<-rnorm(30,3,1) # creates error for X4 variable -- 30 draws from normal distribution with mean = 3 and sd = 1
summary(X4_E)
cheddar$X4<-10*cheddar$Lactic+X4_E # create X4 variable as function of Lactic and error so X4 and Lactic are collinear
cor(cheddar$X4,cheddar$Lactic) 

summary(cheddar)
```


### 1.B. Check collinearity 

* Fit the following 3 models:
  + taste as a function of Acetic, H2S_OG, and Lactic
  + taste as a function of Acetic, H2S_OG, and X4
  + taste as a function of Acetic, H2S_OG, Lactic, and X4}
  
* What do you conclude about collinearity of each model using eigenvalues, VIF and condition number and index?

```r
library(jtools)
mod1 <- lm(taste ~ Acetic + H2S_OG + Lactic, cheddar)
mod2 <- lm(taste ~ Acetic + H2S_OG + X4, cheddar)
mod3 <- lm(taste ~ Acetic + H2S_OG + Lactic + X4, cheddar)

export_summs(mod1, mod2, mod3)

```
##### <br> 

* Eigenvalues:Also used to calculate kappa below. 
-   Create model intercept w/o intercept, because we do not want to change what this parameter is.
-   Use eigen function to do matrix multiplication, multiply transpose of the model matrix. If in rows it changes to columns, pivoting, and multiply by itself and getting eigenvalues of the product. We have vectors and values. Get Values by e1$val
-   Big difference below, what it does to Kappa is that it will be large. 

```r


x_mod1<-model.matrix(mod1)[,-1] # want the model matrix, but without intercept as it's not helpful here
x_mod1
e1<-eigen(t(x_mod1)%*%x_mod1) # * is multiply in R %*% is matrix multiplication
e1
e1$val # Do you see a wide range in eigenvalues?

ols_eigen_cindex(mod1)



```
##### <br> 

* VIF
-   They look similar, but relative size is similar. We are thinking about how much it is going to inflate the variance. Taking the sqrt of 2 is not that much, cut off is around 5.
```r
library(olsrr)
library(tidyverse)
vif(mod1)
vif(mod2)
vif(mod3)

ols_vif_tol(mod3) 

models <- list(mod1, mod2, mod3)

map(models, function(x){
  ols_vif_tol(x) 
}) |> 
  set_names(str_c("Model ", rep(1:3)))
```
##### <br> 

* Condition number and index
-   First row is kappa, larger than 30.
-   condition number smallest is 1, largest is 65300
```r
kappa1<-sqrt(max(e1$val)/min(e1$val))
nu1<-sqrt(max(e1$val)/e1$val)
kappa1;nu1 
```
Are any of the condition indices large?
Is K $\ge$ 30?

##### <br> 
* For \texttt{mod2}
```r
x_mod2<-model.matrix(mod2)[,-1] # want the model matrix, but without intercept as it's not helpful here
e2<-eigen(t(x_mod2)%*%x_mod2) # * is multiply in R %*% is matrix multiplication

kappa1<-sqrt(max(e2$val)/min(e2$val))
nu1<-sqrt(max(e2$val)/e2$val)
kappa1;nu1 
```

##### <br> 
* For \texttt{mod3}
```r
olsrr::ols_vif_tol(mod2)
```


### 1.C. Rescaling of H2S_OG in mod1
-   Scaling is chaging the coefficient, it is centering data but also standardizing. 
```r
summary(cheddar$H2S_OG)
cheddar$H2S_N<-cheddar$H2S_OG/1000
cor(cheddar$H2S_OG,cheddar$H2S_N)

mod1<-lm(taste~Acetic+H2S_OG+Lactic,cheddar)
mod4<-lm(taste~Acetic+H2S_N+Lactic,cheddar)
mod5<-lm(taste~scale(Acetic)+scale(H2S_OG)+scale(Lactic),cheddar)

sumary(mod1);sumary(mod4);sumary(mod5)
```

```r
lapply(
  cheddar |> select(Acetic, H2S_OG, H2S_N, Lactic) |> mutate_all( scale), 
  summary)
```
What did the scale function do?


  
## 2. Checking assumptions about model errors 


### 2.A. We already know how to check zero mean, constant variance and normailty assumption from Class 8 lab session both graphically and numerically.


### 2.B. Focusing on the constant variance assumption

* We will intentionally create taste2 by adding a nonconstant (i.e., heteroscedastic) error term, E, to taste and fit the model  
taste2~ Acetic + H2S_N + Lactic.

```r
set.seed(521)
cheddar$E<-rnorm(30,0,sqrt(cheddar$H2S_OG))

cheddar$taste2<-mod4$coefficients[1]+
  mod4$coefficients[2]*cheddar$Acetic+
  mod4$coefficients[3]*cheddar$H2S_N+
  mod4$coefficients[4]*cheddar$Lactic+
  cheddar$E

summary(cheddar$taste);summary(cheddar$taste2)    
```

* First, fit the model described above and check the constant error variance assumption.
```r

``` 

##### <br> 

* We can address heteroscedasticity with heteroscedasticity-consistent variance with \texttt{vcovHC()} as follows:
```r
library(dplyr)
library(sandwich)# For vcovHC()

hetvar <- mod4 %>% 
  vcovHC() %>% # calculate Heteroscedasticity-consistent estimation of the covariance matrix for coefficients
  diag() %>% # gives variances as they are the diagonal of the covariance matrix
  sqrt() # gives standard error as it is square root of variance - this is what we're saving because we want to calculate a 95% CI

summary(mod4)

# Calculate 95% CI for Acetic using heteroscedasticity-consistent variance
mod4$coefficients[2]+c(-1,1)*qt(0.975,mod4$df.residual)*sqrt(hetvar[2])

# Construct 95% CI using heteroscedasticity-consistent variance for the other betas in mod6
```


##### <br> 

* We can also address heteroscedasticity through weighted least square estimation as follows: 

```r
cheddar$abresid<-abs(residuals(mod6))
cheddar$yhat<-fitted.values(mod6)
```

-   creating weights.
```r
mod_yhat<-lm(abresid~yhat,cheddar)

cheddar$wt1<-1/(fitted.values(mod_yhat)*fitted.values(mod_yhat))
```


```r
plot(cheddar$Acetic,resid(mod6))
plot(cheddar$H2S_N,resid(mod6))
plot(cheddar$Lactic,resid(mod6))

cheddar$wt2<-1/cheddar$H2S_N
```

-   using weighted least squares. 

```r
mod_w1<-lm(taste2~Acetic+H2S_N+Lactic,cheddar,weights=wt1)
mod_w2<-lm(taste2~Acetic+H2S_N+Lactic,cheddar,weights=wt2)
summary(mod6)
summary(mod_w1)
summary(mod_w2)
```

##### <br>
* Examine the residuals of \texttt{mod6}, \texttt{mod\_w1} and \texttt{mod\_w2} graphically: 
```r
plot(fitted(mod6),resid(mod6)); abline(h=0,col="red")
plot(fitted(mod_w1),resid(mod_w1)); abline(h=0,col="red")
plot(fitted(mod_w2),resid(mod_w2)); abline(h=0,col="red")
```

* We see some improvement on the constant error variance assumption with WLS. 
 
### 1.D. Lack of Fit

* We will use flock.dat (Available on Canvas)
* Description: from R.D. Cook, and J.O. Jacobsen (1978) 
* "Analysis of 1977 West Hudson Bay Snow Goose Surveys" by Canadian Wildlife Service.
* Snow Geese Flock Size
* Traditionally, estimates of flock size were obtained by observation from small aircraft. An experiment was conducted to determine how accurate the observations of flock size were. In addition to observer's estimation of the size of 45 flocks of snow geese (OBS), a photograph was taken to record the exact flock size (PHOTO) for each flock (ID).
```r
flock <- read.delim("~/UMD/classes/stat_mod_ML_1_SURV615/class_11/flock.dat",sep="")
names(flock)
dim(flock)

plot(flock$PHOTO,flock$OBS,pch=18,col="blue",cex=.7,
     main="flock size by observation vs. photo (n=45)");abline(lm(OBS~PHOTO,flock),col="red")
```

```r
mod_OBS<-lm(OBS~PHOTO, flock)
mod_OBS_a<-lm(resid(mod_OBS)~factor(PHOTO),flock) # fits model with beta for every unique value of PHOTO

summary(mod_OBS)
summary(mod_OBS_a)


anova(mod_OBS)
# gives you total RSS: 81675
anova(mod_OBS_a)
# gives you SS Pure Error: 740
# SS Lack of Fit = 81675 - 740 = 80935

# get df pure error and df lack of fit
length(unique(flock$PHOTO))
# df lack of fit = # of unique x values - 2 = 37 - 2
# 2 in the equation above corresponds to the number of betas in the simple linear model
length(flock$PHOTO)
# df pure error = # of obs - # of unique x values = 45 - 37 = 8

# Calculate F statistic for lack of fit test
(((81675 - 740)/35)/(740/8))

# Calculate p-value for lack of fit test
1 - pf(24.99923,df1=35,df2=8)

## use the olsrr package to conduct a lack of fit test
library(olsrr)
ols_pure_error_anova(mod_OBS)
# will likely be some small differences between the F statistic and p-value calculated manually

```
* There is evidence for lack of fit in this data or model.
* Had the p-value been >0.05 this would not necessarily mean we have the correct model. It may be a limitation of the data.

Notice the difference in $R^2$ values between mod_OBS and mod_OBS_a. The $R^2$ for mod_OBS_a is nearly (but not quite!) 1. This makes sense as a parameter is included for each unique data point because (why we had factor(PHOTO) in the model). However, since there are repeated values for X in the data the $R^2$ can never actually be 1. Here it is quite close, but with other data it may not be. This shows another reason not to rely too heavily on statistics like $R^2$.
