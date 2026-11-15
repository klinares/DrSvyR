---
id: "jpsm/stat_mod_ML_1_SURV615/class_labs/Class4_lab_nocode"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lab"
title: "Class 4 Lab"
original: "stat_mod_ML_1_SURV615/class_labs/Class4_lab_nocode.Rmd"
pages: 
sha256: "db422c85621476fecdb918f48170c89db64a914e15aa18cb8a0a44a41d742829"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---



```r
knitr::opts_chunk$set(echo = TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

library(tidyverse)
```

  
###  <br> Use Income2.csv data and \texttt{Income} as the response variable
```r
inc <- read_csv("~/UMD/classes/stat_mod_ML_1_SURV615/class_3/Income2.csv")
```

### 1. Make a scatter plot (no regression) of \texttt{Income} as a function of \texttt{Education}. Remake the scatterplot, this time only including those where $Education > 11$

```r
inc |> 
  ggplot(aes(x=Education, y=Income)) +
  geom_point()

inc |> 
  filter(Education > 11) |> 
  ggplot(aes(x=Education, y=Income)) +
  geom_point()

```

### 1a. Fit a simple linear regression model with \texttt{Income} as a function of \texttt{Education}. Interpret the coefficients.

- For everyone 1 year increase in education, income goes up by 6.4, and for a person with no Education, we would expect an average mean income of -41.9.

```r
mod_income <- lm(Income ~ Education, inc)
summary(mod_income)
```

### 2. Use the code below to manually calculate sXY and sXX based on the formulas we saw in today's lecture.

* From Lecture 4 slides 20-24

$$
  \hat{\beta}_1=\dfrac{\sum(x_i-\bar{x})(y_i-\bar{y})}{\sum(x_i-\bar{x})^2}\equiv\dfrac{SS_{XY}(n-1)^{-1}}{SS_{X}(n-1)^{-1}}=\dfrac{s_{XY}}{s_{XX}}
$$

- where 

$$
s_{XY}=\dfrac{\sum(x_i-\bar{x})(y_i-\bar{y})}{n-1}
$$ 
-and 
$$
s_{XX}=\dfrac{\sum(x_i-\bar{x})^2}{n-1}
$$
$$
\hat{\beta}_0=\bar{y}-\hat{\beta}_1\bar{x}
$$


```r
SS_XY<-sum((inc$Education-mean(inc$Education))*(inc$Income-mean(inc$Income)))
SS_X<-sum((inc$Education-mean(inc$Education))^2)

SS_XY/(dim(inc)[1]-1)
SS_X/(dim(inc)[1]-1)

s_XY<-cov(inc$Education,inc$Income)
s_XX<-var(inc$Education)
s_XY
s_XX 
```

### 3. Use sXY and sXX to calculate $\hat{\beta_1}$ and then calcuate $\hat{\beta_0}$ based on the formulas above.

```r
"Beta_1"
SS_XY/SS_X

"Beta_0"
mean(inc$Income) - (mean(inc$Education) *  SS_XY/SS_X)
```



### 4. Compute $\hat{Y}$ based on the model saving as a new variable in inc called h_Income_edu. Compute $\hat{Y}$ using the predict() function saving as a new variable in inc called h_Income_edu2. Look at the estimates for each variable. How do they compare?

```r
beta0 <- coef(mod_income)[[1]]
beta1 <- coef(mod_income)[[2]]

inc$h_Income_edu <- beta0+beta1*inc$Education 
inc$h_Income_edu2 <- predict(mod_income)
```



### 4a. Use the predict() function to get the mean expected income for a person with 10 years of education (Education == 10). Hint: look at the newdata argument in ?predict.lm.

```r
new_dat <- data.frame(Education=10)
predict(mod_income, newdata = new_dat)
```


### 4b. Using the code below, plot a histogram of the observed data points overlayed with the fitted/predicted values based on the model. What did the melt() function do? How does the plot look to you?

```r
# install.packages("reshape") ## uncomment and run this code if reshape package not yet installed then re-comment it out
library(reshape2) 
inc_sub<-melt(inc%>%select(Income,h_Income_edu))
head(inc_sub)
tail(inc_sub)

inc_sub<-inc_sub%>%
  mutate(type=ifelse(variable=="Income","Observed","Predicted"),
         income=value)

ggplot(inc_sub, aes(x=income, color=type, fill=type)) +
   geom_histogram(position="identity", alpha=0.5)
```


### 5. How are the standard error of regression coefficients estimated?

* From lecture 4 slides 18-21, 

$$
\hat{V}(\hat{\beta}_1)=\dfrac{\hat{\sigma}^2}{SS_{X}}
$$

- , where 
$$
\hat{\sigma}^2
$$ 

- is estimated error variance (or residual variance) as 

$$
\hat{\sigma}^2=\dfrac{\sum{\hat{\epsilon}_i^2}}{n-2}
$$
$$
\hat{V}(\hat{\beta}_0)=\hat{\sigma}^2\left(\dfrac{1}{n}+\dfrac{\bar{x}^2}{SS_{X}}\right)
$$
  

```r
inc$residual_edu<-inc$Income-inc$h_Income_edu
resid(mod_income)
cor(inc$residual_edu, resid(mod_income))
h_sigma_sq_edu<-sum(inc$residual_edu^2)/(dim(inc)[1]-2)
h_sigma_sq_edu
summary(mod_income)
summary(mod_income)$sigma^2
```

```r
SS_X<-sum((inc$Education-mean(inc$Education))^2)
V_beta1<-h_sigma_sq_edu/SS_X
SE_beta1<-sqrt(V_beta1)
V_beta0<-h_sigma_sq_edu*(1/dim(inc)[1]+mean(inc$Education)^2/SS_X)
SE_beta0<-sqrt(V_beta0)
SE_beta0;SE_beta1
```

### 6. Extract the standard errors for model1's parameters from its model summary and compare to the values calculated manually above.
```r
summary(mod_income)$coefficients[1, 2]
summary(mod_income)$coefficients[2, 2]

```

### 7. Look at the distribution of the residuals from model1 using a histogram. Create a scatter plot of the residuals (y-axis) vs. income (x-axis).
```r

inc |> 
  ggplot(aes(x=residual_edu)) +
  geom_histogram()

```

```r

inc |> 
  ggplot(aes(x=Income, y=residual_edu)) +
  geom_point()
```




### Example code for customizing plots in ggplot2.----
* \texttt{Income} as a function of \texttt{Education}; no regression implied
```r
library(ggplot2)
ggplot(inc, aes(y=Income, x=Education))+
  geom_point()
```

* With aesthetic options added 
```r
ggplot(inc, aes(y=Income, x=Education))+
  geom_point(shape=0, color="blue", size=2)+
  labs(title="Scatter Plot of Income \n by Education",
        y ="Income ($,000)", x = "Education (Yrs)")+
  theme(plot.title = element_text(hjust = 0.5))
```

```r
m_edu<-lm(Income~Education,inc)
coef(m_edu)
m_edu_noint<-lm(Income~Education-1,inc)
coef(m_edu_noint)
```

```r
p_edu<-ggplot(inc, aes(y=Income, x=Education))+
  geom_point(color="blue")+
  geom_abline(intercept=coef(m_edu)[1],slope=coef(m_edu)[2],
              color="red")+
  geom_abline(intercept=0,slope=coef(m_edu_noint)[1],
              color="black", linetype="dashed", size=1) 
p_edu

# Expand axes so intercepts appear in plot and add vertical line at intercepts
p_edu<-ggplot(inc, aes(y=Income, x=Education))+
  geom_point(color="blue")+
  geom_abline(intercept=coef(m_edu)[1],slope=coef(m_edu)[2],
              color="red")+
  geom_abline(intercept=0,slope=coef(m_edu_noint)[1],
              color="black", linetype="dashed", size=1)+
  geom_vline(xintercept = 0, linetype="dotted", size=1)+
  xlim(-2,30)+
  ylim(-42,102)
  
p_edu
```

* \texttt{geom\_smooth(method='lm')} adds a regression line with an intercept 
```r
ggplot(inc, aes(y=Income, x=Education))+
  geom_point(color="blue")+
  geom_smooth(method='lm', color="red", se=FALSE)
```

C. \texttt{Income} as a function of \texttt{Seniority}
```r
p_sen<-ggplot(inc, aes(y=Income, x=Seniority))+
  geom_point(color="darkgreen")+
  geom_smooth(method='lm', color="purple", se=TRUE, size=1)
p_sen
```

D. Putting \texttt{p\_edu} and \texttt{p\_sen} together
```r
library(gridExtra)
library(grid)
grid.arrange(p_edu, p_sen, ncol = 2)
```


E. \texttt{Income} as a function of \texttt{Education} and \texttt{Seniority} 
```r
# install.packages("plot3D")
library(plot3D)
scatter3D(inc$Education, inc$Seniority, inc$Income, colvar=NULL,
          phi = 20, bty = "g", type="h", pch = 20, cex = 1, col="blue",
          xlab="Education", ylab="Seniority",zlab="Income")
```

* With the predicted surface
```r
x <- inc$Education
y <- inc$Seniority
z <- inc$Income

# Compute the linear regression (z = b0+b1x+b2y+e)
pred_both <- lm(z ~ x + y)

# predict values on regular xy grid
grid.lines <- dim(inc)[[1]]
x.pred <- seq(min(x), max(x), length.out = grid.lines)
y.pred <- seq(min(y), max(y), length.out = grid.lines)
xy <- expand.grid( x = x.pred, y = y.pred)
z.pred <- matrix(predict(pred_both, newdata = xy), 
                 nrow = grid.lines, ncol = grid.lines)
 
fitpoints <- predict(pred_both)
scatter3D(x, y, z, colvar=NULL,
          phi=20, theta=20, bty ="g", type="h", pch=20, cex=1, col="blue",
          xlab="Education", ylab="Seniority", zlab="Income",
          surf = list(x=x.pred, y=y.pred, z=z.pred,  
                 facets=NA, fit=fitpoints, col="red"))

```


