---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class8_Lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "SMML Class 8 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class8_Lab_nocode.Rmd"
pages: 
sha256: "36a934b05269a209b22d0275836031d170a8f281dc110ff6950bcb695f5094dd"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:13"
---



```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

options(scipen=999)
```

  

```r
library(ISLR2)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(grid)
library(faraway)
```
 
##  <br> Use Wage data <br>
```r
data(Wage, package="ISLR") 
```
 
### 1. Fit 3 regression models using the Wage data from ISLR2. In model 1 fit a model with wage as a function of year. In model 2 fit a model with wage as a function of year and age. Finally, in model 3 fit a model with wage as a function of year, age, and jobclass. Interpret the coefficient for year in each model?

```r
mod_1 <- lm(wage ~ year, Wage)
mod_2 <- lm(wage ~ year + age, Wage)
mod_3 <- lm(wage ~ year + age + jobclass, Wage)

summary(mod_1)
summary(mod_2)
summary(mod_3)
```


### 2. Refit model 3, this time with log(wage) as the outcome. How does it compare to model 3 (wage as a function of year, age, and jobclass)?

```r
mod_3_log <- lm(log(wage) ~ year + age + jobclass, Wage)
summary(mod_3_log)
```


### 2.A. How do the coefficient estimates compare?


### 2.B. What do the coefficient estimates mean?
```r
coef(lm(wage~year+age+jobclass,Wage))
coef(lm(logwage~year+age+jobclass,Wage))
coef(lm(exp(logwage)~year+age+jobclass,Wage))
```


### 3. Check on the values of \texttt{year} and \texttt{age} variables.
```r
coef(lm(wage~year+age,Wage))
```

### 3.A. \texttt{year} in the data were from 2003 to 2009 and \texttt{age} from 18 to 80.  What would be our best guess for \texttt{wage} with the median value of \texttt{age} in 2015?

```r
mod1<-lm(wage~year+age, Wage)
summary(mod1)
mod1_x<-model.matrix(mod1) 
dim(mod1_x)
head(mod1_x)
# mod1_x is the matrix of predictors. In other words these are the data points being used to fit the model.

(mod1_x_star<-c(1,2015,apply(mod1_x,2,median)[3])) 
mod1_x_star2 <- data.frame("year" = 2015, "age" = median(Wage$age))

# This creates a vector with 1 (the intercept is always 1), year = 2015, and finds median of age which is the 3rd column in your model matrix, mod1_x.
test <- predict(mod1, newdata = mod1_x_star2, interval = "prediction")

(mod1_y_star<-sum(mod1_x_star*coef(mod1))) 
# this equates to 
# y_hat=beta0_hat+beta1_hat*median(year)+beta2_hat*median(age)

n <- length(Wage$wage)
y.fitted <- mod1$fitted.values
b0 <- mod1$coefficients[1]
b1 <- mod1$coefficients[2]
b2 <- mod1$coefficients[3]
mod_mat <- model.matrix(mod1)
x0 <- c(1, 2015, median(Wage$age))
# var(mod1)
pred.y <- (b0 + (b1*2015) + (b2*median(Wage$age)))
sse <- sum((Wage$wage - y.fitted)^2)
mse <- sse/(n-3)
t.val <- qt(0.975, n-3)

sigma2 <- sum(residuals(mod1)^2)/(nrow(Wage) - 3) # AKA MSE

p.se <- sqrt(mse*(1+t(x0)%*%(t(mod_mat)%*%mod_mat)^-1%*%x0))
p.se <- sqrt(mse*(1+t(x0)%*%(t(mod_mat)%*%mod_mat)^-1%*%x0))
test <- predict(mod1, newdata = mod1_x_star2, interval = "predict")

pred.y - (t.val*p.se)
pred.y + (t.val*p.se)

## another way to do this that's a bit more straight-forward
datnew <- data.frame("year" = 2015, "age" = median(Wage$age))

predictions <- predict(
  mod1,
  newdata = datnew,
  type='response',
  se=T
)

quant <- qt(0.025, nrow(Wage)-ncol(mod1_x), lower.tail = F)

sigma2 <- sum(residuals(mod1)^2)/(nrow(Wage) - 3) # AKA MSE

# Confidence interval -- for your reference
df_preds <- data.frame(datnew, predictions)%>%
  mutate(lower = fit - (quant*se.fit),
         upper = fit + (quant*se.fit))%>%
  summarise(mn_beta = mean(fit),
            lcl = mean(lower),
            ucl = mean(upper))

print(df_preds)
predict(mod1, newdata = datnew, interval = "confidence")

# Prediction interval
se.fit.pred <- sqrt(sigma2*(1+(predictions$se.fit^2/sigma2)))

df_preds_pred <- data.frame(datnew, predictions)%>%
  mutate(lower = fit - (quant*se.fit.pred),
         upper = fit + (quant*se.fit.pred))%>%
  summarise(mn_beta = mean(fit),
            lcl = mean(lower),
            ucl = mean(upper))

print(df_preds_pred)  
predict(mod1, newdata = datnew, interval = "prediction")
```

### 3.B. What is its 95% confidence interval?

```r
confint(mod1)
```


### 3.C. How would you evaluate its credibility of the prediction interval?
```r
predict(mod1, newdata = tibble(year=2015, age = 42), interval = 'prediction')
```

### 3.D. What do you observe between the confidence vs. prediction intervals? Why are there differences? 
```r

```



### 4. What if we want to predict \texttt{wage} for a 50 year old working in information jobclass in 2015?

### 4.A. Does the approach below work? Why or why not?
```r
mod2<-lm(wage~year+age+jobclass, Wage)
mod2_x<-model.matrix(mod2)
mod2_x[1:5,]

(mod2_x_new<-t(c(1,2015, 50, "1")))
colnames(mod2_x_new)<-c("(Intercept)","year","age","jobclass2. Information")
mod2_x_new


predict(mod2, new=data.frame(mod2_x_new))
predict(mod2, new=data.frame(mod2_x_new), interval="confidence")
predict(mod2, new=data.frame(mod2_x_new), interval="prediction")
table(Wage$jobclass) ## how the raw data appear (how predict looks for the data)
table(mod2_x[,4]) ## how jobclass appears in model matrix (how R fits the model)

```
* This does not work -- the issue of categorical variables. \texttt{lm()} in R automatically creates dummies for categorical variable in the background. It's trying to create dummy variables of a dummy variable which is why it's failing. 

### 4.B. What to do?

* Fit the model with dummies for categorical variables!
* E.g., for a categorical variable with $f$ categories, need $f-1$ dummies.

```r
Wage$information<-with(Wage,ifelse(jobclass=="2. Information",1,0))
# with() tells R which data or object you want the subsequent function to be applied to
# ifelse() follows the format (T/F condition to test, value if condition true, value if condition false)
# so this code creates a new variable in Wage called "information" that == 1 when jobclass == "2. Information" and 0 otherwise

mod3<-lm(wage~year+age+information, Wage)
mod3_x<-model.matrix(mod3)
mod3_x[1:5,]

(mod3_x_new<-t(c(1,2015, 50, 1)))
colnames(mod3_x_new)<-c("(Intercept)","year","age","information")
mod3_x_new

predict(mod3, new=data.frame(mod3_x_new))
predict(mod3, new=data.frame(mod3_x_new), interval="confidence")
predict(mod3, new=data.frame(mod3_x_new), interval="prediction")
```


### 5. Consider fitted values from simple regression ($\hat{y}_{simple}$) vs. multiple regression ($\hat{y}_{multiple}$) vs. observed values ($y$). 

```r
mod_simple <- lm(wage~age,Wage)
mod_multiple <- lm(wage~age+year*race+maritl+education+health,Wage)

# save fitted values from each model as new variables
Wage$wage_hat_simple <- fitted(mod_simple)
Wage$wage_hat_multiple <- fitted(mod_multiple)
```

### 5.A. Examine their distribution through \texttt{summary()}.
```r
Wage |> select(wage_hat_simple, wage_hat_multiple) |> 
  pivot_longer(everything()) |> 
  ggplot(aes(x=value, color=name)) +
  geom_density() +
  theme_dark()
```

### 5.B. Compare the two types of fitted values against the observed through correlation coefficients and scatterplots. 
```r

Wage |> select(wage_hat_simple, wage_hat_multiple, wage) |> 
  as.matrix() |> 
  cor()



Wage |> 
select(wage_hat_simple, wage_hat_multiple, wage) |> 
  pivot_longer(-wage, names_to="name", values_to="value") |> 
  ggplot(aes(x=value, y=wage, color=name))  +
  geom_point() +
  theme_dark()


```

```r
simple <- ggplot(Wage,aes(x=wage,y=wage_hat_simple))+
  geom_point(color="blue", size=0.5)+
  coord_cartesian(xlim = c(0, 320), ylim = c(0, 320)) 
multiple <- ggplot(Wage,aes(x=wage,y=wage_hat_multiple))+
  geom_point(color="red", size=0.5)+
  scale_x_continuous(limits = c(20, 320))+
  scale_y_continuous(limits = c(20, 320))

grid.arrange(simple,multiple, ncol=2)
```

### 5.C. Which model is better? Why?
```r

```
* Multiple linear regression model is better from all three tests.
 
