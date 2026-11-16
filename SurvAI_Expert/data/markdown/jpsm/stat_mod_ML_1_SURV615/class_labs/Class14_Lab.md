---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class14_Lab"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 14 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class14_Lab.Rmd"
pages: 
sha256: "034a76522acf4e5073c6a60a9155a31ffb07eb89317003b98bf536ec66847da7"
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
library(faraway)
library(boot)
library(mgcv)
library(sandwich)
```

```r
data(teengamb,package="faraway")
dim(teengamb)
summary(teengamb)
```

## 1. Try the code given in each chunk and make observations for each question.

### 1.A. What are \texttt{gamble}, \texttt{samp\_gamble} and \texttt{mean\_gamble} in the chunk below? Compare the results with a student next to you.

```r
gamble<-teengamb$gamble
gamble
samp_gamble<-sample(gamble,10,replace=T)
samp_gamble
mean_gamble<-mean(samp_gamble)
mean_gamble
```

### 1.B. What does mean_gamble look like before and after \textcolor{blue} {\texttt{for{}}}? What role does \texttt{i} play?   

```r
mean_gamble<-rep(0,5)

for(i in 1:5){
  samp_gamble<-sample(gamble,5,replace=T)
  mean_gamble[i]<-mean(samp_gamble)
  }
```

### 1.C. What is the value you obtain under \texttt{mean(mean\_gamble)}? Check your results of mean_gamble after \textcolor{blue}{\texttt{for{}}} and \texttt{mean(mean\_gamble)} with the student next to you. 

```r
mean_gamble

mean(mean_gamble)
```

### 1.D. Check your results of \texttt{mean\_gamble} after  \textcolor{blue}{\texttt{for{}}} and \texttt{mean(mean\_gamble)} against the results of the student next to you. 

```r
set.seed(22)

for(i in 1:5){
  samp_gamble<-sample(gamble,47,replace=T)
  mean_gamble[i]<-mean(samp_gamble)
  }

mean_gamble

mean(mean_gamble)
```


### 1.E. What did we just do? How could this exercise be helpful?


## 2. Bootstrap

### 2.A. We will use \texttt{diabetes} data from \texttt{faraway}. Our interest is to construct a 95% confidence interval of $\mu_{glyhb}$ through the following steps:

a. Explore the data. 
b. Draw 1000 bootstrap samples from \texttt{diabetes} (after properly dealing with any missing) using \texttt{set.seed(9)}.
c. For each bootstrap sample, compute $\hat{\mu}_{glyhb,r}$, where $r$ indicates a bootstrap sample ($r=1,\cdots,1000$).
d. Observe the mean and standard deviation of $\hat{\mu}_{glyhb,r}$.
e. Using the results from d, construct a 95% confidence interval.
f. On the ranking of $\hat{\mu}_{glyhb,r}$, find the 25th and 975th value of $\hat{\mu}_{glyhb,r}$.
g. Compare $\hat{\mu}_{glyhb}$, $SE(\hat{\mu}_{glyhb})$ and the 95% CI of $\mu_{glyhb}$ from parametric estimation with the equivalents from bootstrapping. Consider CI's from bootstrapping both in e and f. What do you observe?

### Step a. Explore the data 
```r
data(diabetes,package = "faraway")
summary(diabetes)
names(diabetes)

glyhb<-diabetes%>%
  select(glyhb)%>%
  na.omit()

dim(diabetes)
dim(glyhb)
```

### Step b. Draw 1000 bootstrap samples from \texttt{diabetes} (after properly dealing with any missing) using \texttt{set.seed(9)}.
### Step c. For each bootstrap sample, compute $\hat{\mu}_{glyhb,r}$, where $r$ indicates a bootstrap sample ($r=1,\cdots,1000$). 
```r
n_boot<-1000
set.seed(9)
n_glyhb<-dim(glyhb)[1]

mean_glyhb<-rep(0,n_boot)

for(i in 1:n_boot){
  samp_glyhb<-glyhb%>%
    sample_n(n_glyhb,replace=T)
  mean_glyhb[i]<-mean(samp_glyhb$glyhb)
  }

head(mean_glyhb)
```

### Step d. Observe the mean and standard deviation of $\hat{\mu}_{glyhb,r}$.
```r
mean(mean_glyhb)
sd(mean_glyhb)
```
### Step e. Using the results from d, construct a 95% confidence interval.

```r
t.score<-qt(p=.05/2, df=dim(glyhb)[1]-1, lower.tail=F)

Lci<-mean(mean_glyhb)-t.score*sd(mean_glyhb)
Uci<-mean(mean_glyhb)+t.score*sd(mean_glyhb)

print(c(Lci,Uci))
```

### Step f. On the ranking of $\hat{\mu}_{glyhb,r}$, find the 25th and 975th value of $\hat{\mu}_{glyhb,r}$.

```r
quantile(mean_glyhb,c(0.025,0.975))
```

### Step g. Compare $\hat{\mu}_{glyhb}$, $SE(\hat{\mu}_{glyhb})$ and the 95% CI of $\mu_{glyhb}$ from parametric estimation with the equivalents from bootstrapping. Consider CI's from bootstrapping both in e and f. What do you observe?

```r
mean(glyhb$glyhb); mean(mean_glyhb)

sd(glyhb$glyhb)/sqrt(dim(glyhb)[1]); sd(mean_glyhb)

t.test(glyhb$glyhb)$"conf.int"; 
print(c(Lci,Uci)); 
quantile(mean_glyhb,c(0.025,0.975))
```





### 2.B. Continue with \texttt{diabetes} data from \texttt{faraway}. The interest is estimating a slope coefficient of a linear regression model \texttt{glybh}~\texttt{chol} through the following steps. 

a. Examine the model with respect to OLS assumptions. What does the conclusion tell you?
b. Focus on $\beta_{chol}$ from the model. Compute its bootstrap standard error as well as the 95% confidence interval. Use 1000 bootstrap samples.
c. Bootstrap confidence interval using R functions \texttt{boot()} and \texttt{boot.ci()}.
d. Compare the estimate for $\beta_{chol}$ using OLS and bootstrapping (in b).
e. Compare the 95% confidence interval for $\beta_{chol}$ using OLS, bootstrapping (in b) and heteroscedacity consistent variance estimator.

### Step a. Examine the model with respect to OLS assumptions. What does the conclusion tell you?
```r
summary(diabetes)

diab<-diabetes%>%
  select(glyhb,chol)%>%
  na.omit() # drops missing observations

mod<-lm(glyhb~chol,diab)
summary(mod)
coef(mod)
plot(mod$fitted,mod$resid);abline(h=0,col="red")
qqnorm(mod$resid);qqline(mod$resid)
# What do these plots suggest about our linear regression assumptions? Do they appear to be met?
```

### Step b. Focus on $\beta_{chol}$ from the model. Compute its bootstrap standard error as well as the 95% confidence interval. Use 1000 bootstrap samples.

```r
n_boot<-1000
set.seed(21)
n_diab<-dim(diab)[1] # get dimensions of first column of diab

beta_chol<-rep(0,n_boot) # create vector the length of n_boot to give something for for loop to store values in

# this code might take a second to run
for(i in 1:n_boot){
samp_diab<-diab%>%
  sample_n(n_diab,replace=T)
bmod<-lm(glyhb~chol,samp_diab)
beta_chol[i]<-coef(bmod)[2]
  }

mean(beta_chol)
sd(beta_chol)

t.score<-qt(p=.05/2, df=n_diab-1, lower.tail=F)

Lci<-mean(beta_chol)-t.score*sd(beta_chol)
Uci<-mean(beta_chol)+t.score*sd(beta_chol)

print(c(Lci,Uci))

quantile(beta_chol,c(0.025,0.975))
```

### Step c. Bootstrap confidence interval using R functions \texttt{boot()} and \texttt{boot.ci()}.
```r
boot.fn<-function(dat,i){
  return(coef(lm(glyhb~chol,data=dat,subset=i))[2])  
  }

set.seed(29)
boot.fn(diab,sample(n_diab,n_diab,replace=T))
boot.fn(diab,sample(n_diab,n_diab,replace=T)) #why is the result different between these two (hint: look at line 22 and what is used as the 2nd argument when calling boot.fn())?

# Try running the following lines of code. What do you see?
set.seed(29)
boot.fn(diab,sample(n_diab,n_diab,replace=T))
set.seed(29)
boot.fn(diab,sample(n_diab,n_diab,replace=T)) 

a<-boot(diab,boot.fn,1000) #boot() from boot package
a
attributes(a)
head(a)
quantile(a$t[,1],c(0.025,0.975))

attributes(boot.ci(a))
boot.ci(a)
```

### Step d. Compare the estimate for $\beta_{chol}$ using OLS and bootstrapping (in b).
```r
coef(mod)[2]; mean(beta_chol)
```

### Step e. Compare the 95% confidence interval for $\beta_{chol}$ using OLS, bootstrapping (in b) and heteroscedacity consistent variance estimator.
```r
confint(mod)[2,]; 
print(c(Lci,Uci)); 
quantile(beta_chol,c(0.025,0.975))

HCse<-mod %>%
  vcovHC() %>% #from sandwich package
  diag() %>%
  sqrt() # taking the square root here changes it to standard error (from variance)

t.score<-qt(p=.05/2, df=n_diab-1, lower.tail=F)

LHCci<-coef(mod)[2]-t.score*HCse[2]
UHCci<-coef(mod)[2]+t.score*HCse[2]

print(c(LHCci,UHCci))

```


## 3. Cross-Validation

### 3.A. Continue with the linear regression of \texttt{glyhb}~\texttt{chol} of diabetes. Try its general additive model and explore whether polynomials would be helpful.

```r
modA<-gam(glyhb~s(chol),data=diab) #gam() from mgcv package
plot(modA)
attributes(modA)

mod1<-glm(glyhb~chol,data=diab)
mod2<-glm(glyhb~poly(chol,2),data=diab)
mod3<-glm(glyhb~poly(chol,3),data=diab)
mod4<-glm(glyhb~poly(chol,4),data=diab)
 
mod1$df.residual;mod2$df.residual;mod3$df.residual;mod4$df.residual;modA$df.residual

mse<-function(obj){
  sum(obj$residuals^2)/obj$df.residual
  }

mse(mod1);mse(mod2);mse(mod3);mse(mod4);mse(modA)
```

### 3.B. Using the validation set approach:

### Try the validation set approach and observe the error rates. What does this mean?
```r
set.seed(31)

train_i<-sample(n_diab,round(n_diab/2,0))

train<-diab[train_i,]
val<-diab[-train_i,]

mod1.train<-glm(glyhb~chol,data=train)
mod2.train<-glm(glyhb~poly(chol,2),data=train)
mod3.train<-glm(glyhb~poly(chol,3),data=train)
mod4.train<-glm(glyhb~poly(chol,4),data=train)

# compare observed values in treatment set to predicted values using model fit on training data
mean((val$glyhb-predict(mod1.train,val))^2)
mean((val$glyhb-predict(mod2.train,val))^2)
mean((val$glyhb-predict(mod3.train,val))^2)
mean((val$glyhb-predict(mod4.train,val))^2)
```

### 3.C. Use leave-one-out and cross-validate.
```r
mod1.cv.err<-cv.glm(diab,mod1)
attributes(mod1.cv.err)
mod1.cv.err$delta
mod2.cv.err<-cv.glm(diab,mod2)
mod3.cv.err<-cv.glm(diab,mod3)
mod4.cv.err<-cv.glm(diab,mod4)
   
mod1.cv.err$delta;mod2.cv.err$delta;mod3.cv.err$delta;mod4.cv.err$delta 
```

### 3.D. Use $k$-fold cross-validation with $k=10$.
```r
set.seed(6)
mod1.cv.err.kfold<-cv.glm(diab,mod1,K=10)
mod2.cv.err.kfold<-cv.glm(diab,mod2,K=10)
mod3.cv.err.kfold<-cv.glm(diab,mod3,K=10)
mod4.cv.err.kfold<-cv.glm(diab,mod4,K=10)
   
mod1.cv.err.kfold$delta
mod2.cv.err.kfold$delta
mod3.cv.err.kfold$delta
mod4.cv.err.kfold$delta 

rbind(mod1.cv.err.kfold$delta[1],
      mod2.cv.err.kfold$delta[1],
      mod3.cv.err.kfold$delta[1],
      mod4.cv.err.kfold$delta[1])
```


### 3.E. Given the results so far, which of the models 1 through 4 would you recommend?
