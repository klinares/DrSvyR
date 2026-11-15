---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class14_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class14_Lecture.pdf"
pages: 53
sha256: "35106884bd8a9d9346fb718f4b804bd369d42b69e75ad4283e7ee9c7fcd70859"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:16"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #14

John Kubale

December 3, 2024

<!-- page 2 -->

# Outline

* Resampling
  * Bootstrap
  * Cross-validation
* Review
* Lab

<!-- page 3 -->

# Resampling

<!-- page 4 -->

# Resampling

* What is resampling?
  * Repeatedly sampling from a (training) dataset and refitting a model on each sample
* Why resampling?
  * Assessing parameter estimate precision: e.g., standard error, confidence interval
  * Cross-validation
    * Model assessment: model fit and performance (e.g., MSE)
    * Model selection: e.g., model flexibility
* Resampling methods
  * Bootstrap
  * Cross-validation: Validation set approach, leave-one-out (LOO), $k$-fold cross-validation

<!-- page 5 -->

# Bootstrap

<!-- page 6 -->

# Bootstrap - 1

* Why?
  * What if the OLS assumptions in linear regression are violated and the remedies we have learned so far do not resolve the problem(s)?
* How?
  * Say that we are interested in a parameter $\theta$
  * Draw a sample of $n$ **<u>with replacement</u>** from the original sample of $n$ repeatedly, say $B$ times
  * Observe the estimate in each sample, e.g., $\hat{\theta}_r$, where $r = 1, ..., B$
  * Combine the results $\hat{\theta}_1, ..., \hat{\theta}_B$ as follows:

$$SE_B\hat{\theta} = \sqrt{\frac{1}{B - 1} \sum_{r=1}^B (\hat{\theta}_r - \frac{1}{B} \sum_{r=1}^B \hat{\theta}_r)^2}$$

<!-- page 7 -->

# Bootstrap - 2

POPULATION

SAMPLE

Bootstrap Sample

Bootstrap Sample

Bootstrap Sample

Bootstrap Sample

Bootstrap Sample

Allison Horst

<!-- page 8 -->

# Bootstrap - 3

* Alternatively for linear regression (in Faraway)
  1. Generate $\epsilon^*$ from $\hat{\epsilon}_1, \dots, \hat{\epsilon}_n$
  2. Generate $y^* = X\hat{\beta} + \epsilon^*$
  3. Estimate $\hat{\beta}^*$ by modeling $y^*$ on $X$
  4. Repeat and observe $\hat{\beta}^*$
  5. Compute $SE(\beta)$ by summarizing $\hat{\beta}^*$

<!-- page 9 -->

# Cross-validation

<!-- page 10 -->

Total Sample

Training Set $\longrightarrow$ Validation Set

Fit the model $\longrightarrow$ Predict
Compare $y$ and $\hat{y}$

**How to split the sample?**

1. Validation set approach
2. Leave-one-out
3. $k$-fold

<!-- page 11 -->

# Cross-validation: Validation Set Approach

* Conceptually and operationally simple
* Split the sample randomly in half (or into 2 groups with different proportions)
  * Use one as a training set
  * The other as a validation set and observe the test error rate
  (recall, $\epsilon = y - \hat{y}$)
* Weaknesses
  * High variability in validation estimates (depending on the single random split)
  * Overestimation of error rates (because statistical methods perform worse when trained on fewer observations)

<!-- page 12 -->

# Cross-validation: Leave-One-Out (LOO)

* Addresses weaknesses in the validation set approach
* Start from the 1$^{\text{st}}$ observation in the sample
  * $\rightarrow$ Validation set
  * Remaining observations in the original sample $\rightarrow$ Training set
  * Observe the test error in the validation set
* Repeat steps above for all $n$ observations and summarize the test error rates (e.g., average)
* Strengths over validation set approach
  * Trained on more observations $\rightarrow$ less bias
  * No randomness in sample split
* Weaknesses
  * Depending on the model and sample size can be very computationally intensive

<!-- page 13 -->

# Cross-validation: Leave-One-Out (LOO)

* Addr
* Start
  * $\rightarrow$
  * R
  * O
* Repe error rates (e.g.,
* Stren
  * Tr
  * N
* Weaknesses
  * Depending on the model and sample size can be very computationally intensive

1 2 3 n
1 2 3 n
1 2 3 n
1 2 3 n
.
.
.
1 2 3 n

ISLR Figure 5.3

<!-- page 14 -->

# Cross-validation: $k$-Fold

* Alternative to Leave-One-Out
* Divide the sample into $k$ folds (i.e., subsets)
  * $\rightarrow$ $1^{\text{st}}$ fold is a validation set
  * Remaining folds in the original sample $\rightarrow$ training set
* Repeat steps above over $k$ folds
* $k$ is usually 5-10
* Strengths
  * Less computationally intensive
  * Advantageous in bias-variance trade off vs. LOO
    * Slightly more biased than LOO
    * Smaller variance than LOO where training sets are almost identical ($\rightarrow$Highly correlated fitted models $\rightarrow$ Adds to variability)

<!-- page 15 -->

# Cross-validation: $k$-Fold

* Alternative to Leave-One-Out

```
1 2 3                                                           n

                                ↓

11 76 5                                                        47
11 76 5                                                        47
11 76 5                                                        47
11 76 5                                                        47
11 76 5                                                        47
```

ISLR Figure 5.5

* Smaller variance than LOO where training sets are almost identical (highly correlated fitted models $\rightarrow$ Adds to variability)

<!-- page 16 -->

# Review – Regression terminology

* The model `lm(y ~ x + z, data)` can be described as:
  * Regress y on x and z
  * Fit a linear model of y as a function of x and z

<!-- page 17 -->

# Review - Assessing collinearity

* Eigenvalues
* Condition number
* Kappa
* Variance Inflation Factor

<!-- page 18 -->

# Review - Assessing collinearity

* Eigenvalues
* Condition number
* Kappa
* **<u>Variance Inflation Factor</u>**

<!-- page 19 -->

# Review - Assessing collinearity

* Eigenvalues $\rightarrow$ eigenvalue of $0$ means perfect collinearity
* Condition number $\rightarrow \sqrt{\max(eigenvalue)/eigenvalue_i}$
* Kappa $\rightarrow \sqrt{\max(eigenvalue)/\min(eigenvalue)}$
* Variance Inflation Factor $\rightarrow$ want to avoid VIF $> 5$ or $10$ in social sciences

<!-- page 20 -->

# Review - Assessing collinearity

\*\*High condition numbers or kappa do not mean there is definitely collinearity\*\*

* Eigenvalues $\rightarrow$ eigenvalue of 0 means perfect collinearity
* Condition number $\rightarrow \sqrt{\max(eigenvalue) / eigenvalue_i}$
* Kappa $\rightarrow \sqrt{\max(eigenvalue) / \min(eigenvalue)}$
* Variance Inflation Factor $\rightarrow$ want to avoid VIF > 5 or 10 in social sciences

<!-- page 21 -->

# Review

* What are our linear regression assumptions?
* How do we assess whether these assumptions are met?
* What can we do if the assumptions are not met?

<!-- page 22 -->

# Zero Mean Error

$E(\epsilon_i) \neq 0$

What is the problem?

* OLS estimators are not unbiased

  (e.g., Cannot guarantee $E(\hat{\beta}_{OLS}) = \beta$

What to do?

* Include other predictors: e.g., splines, polynomials, interactions
* Variable transformation

<!-- page 23 -->

# Assessing Zero Mean Error

```r
plot(mod2$fitted.value,mod2$residuals);abline(h=0,col="red")
```

What do you see?

<!-- page 24 -->

# Assessing Zero Mean Error

```r
mean(resid(mod2));mean(resid(mod2)[fitted(mod2)<=-5]);mean(resid(mod2)[fitted(mod2)>-5]

## [1] 2.678447e-16

## [1] 0.009675334

## [1] -0.01612556
```

<!-- page 25 -->

# Assessing Zero Mean Error

```r
mean(resid(mod2));mean(resid(mod2)[fitted(mod2)<=-5]);mean(resid(mod2)[fitted(mod2)>-5]
```

```
## [1] 2.678447e-16

## [1] 0.009675334

## [1] -0.01612556
```

What assumption(s) should we check prior to conducting a t test?

```r
t.test(resid(mod2)[fitted(mod2)<=-5],resid(mod2)[fitted(mod2)>-5])
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  resid(mod2)[fitted(mod2) <= -5] and resid(mod2)[fitted(mod2) > -5]
## t = 0.018077, df = 373.92, p-value = 0.9856
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -2.780756  2.832358
## sample estimates:
##    mean of x    mean of y 
##  0.009675334 -0.016125557
```

<!-- page 26 -->

# Homoscedasticity (i.e., Constant Variance)

$V(\epsilon_i) = \sigma^2 \text{ vs. } V(\epsilon_i) = \sigma_i^2$

What is the problem?

* Cannot guarantee that $\hat{V}(\hat{\beta})$ is unbiased of $V(\hat{\beta})$

What to do?

* Heteroscedastic consistent variance estimator
* Weighted least squares estimation
* Variable transformation

<!-- page 27 -->

# Assessing Homoscedasticity

```r
plot(mod2$fitted.value,mod2$residuals);abline(h=0,col="red")
```

What do you see?

<!-- page 28 -->

# Assessing Homoscedasticity

```r
var(resid(mod2));var(resid(mod2)[fitted(mod2)<=-5]);var(resid(mod2)[fitted(mod2)>-5])

## [1] 216.9507

## [1] 251.3609

## [1] 160.8764

var.test(resid(mod2)[fitted(mod2)<=-5],resid(mod2)[fitted(mod2)>-5])

## 
##  F test to compare two variances
## 
## data:  resid(mod2)[fitted(mod2) <= -5] and resid(mod2)[fitted(mod2) > -5]
## F = 1.5624, num df = 254, denom df = 152, p-value = 0.002756
## alternative hypothesis: true ratio of variances is not equal to 1
## 95 percent confidence interval:
##  1.168766 2.067245
## sample estimates:
## ratio of variances 
##           1.562447
```

<!-- page 29 -->

# Normality of Errors

```r
qqnorm(tmod$residual)
qqline(tmod$residual, col = "red", lwd = 2)
```

<!-- page 30 -->

# Normality of Errors

How might we address violations of this assumption?

<!-- page 31 -->

# Normality of Errors

How might we address violations of this assumption?

* Transformation
* GAMs or polynomial regression models
* Bootstrapping our standard errors

<!-- page 32 -->

# Random effects models

```r
library(lme4)
rmod<-lmer(time~(1|treat), rats)
summary(rmod)
```

```
## Linear mixed model fit by REML ['lmerMod']
## Formula: time ~ (1 | treat)
##    Data: rats
##
## REML criterion at convergence: -0.5
##
## Scaled residuals:
##     Min      1Q  Median      3Q     Max
## -1.6369 -0.7218 -0.1514  0.5186  2.7284
##
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  treat    (Intercept) 0.02164  0.1471
##  Residual             0.04736  0.2176
## Number of obs: 48, groups:  treat, 4
##
## Fixed effects:
##             Estimate Std. Error t value
## (Intercept)  0.47937    0.07998   5.993
```

Can we make any conclusions about the hypothesis being tested from the summary() output?

<!-- page 33 -->

# Random effects models

```r
confint(rmod, oldNames = FALSE)

##                          2.5 %    97.5 %
## sd_(Intercept)|treat 0.04474072 0.3338817
## sigma                0.17900826 0.2724161
## (Intercept)          0.30345222 0.6552976
```

No, we need to look at the confidence interval.

<!-- page 34 -->

# Random effects models

```r
confint(rmod, oldNames = FALSE)

##                         2.5 %    97.5 %
## sd_(Intercept)|treat 0.04474072 0.3338817
## sigma                0.17900826 0.2724161
## (Intercept)          0.30345222 0.6552976
```

No, we need to look at the confidence interval.

* sd_(Intercept)|treat we can see that the 95% CI does not include $0$. This suggests that we can reject our null hypothesis that $\sigma_a = 0$. (Lecture 13)

<!-- page 35 -->

# Lab Session

<!-- page 36 -->

# For loops

* **For loops** are commonly used to help streamline repetitive tasks when coding
* Structure of for loop:

```r
for (item in list of items){
   do_something(item)
}
```

<!-- page 37 -->

# For loops

* **For loops** are commonly used to help streamline repetitive tasks when coding
* Structure of for loop:

```r
for (item in list of items){
   do_something(item)
}
```

* **<u>In words:</u>** For each item in a sequence or list of items (vector, dataframe, etc.), perform some operation (apply a function)

<!-- page 38 -->

# For loops

monster

`parade = c( , , , , )`

```r
for (monster in parade) {

    if (shape(monster) == triangle) {
        monster_style = monster + sunglasses
    }

    else {
        monster_style = monster + hat
    }

    print(monster_style)

}
```

Artwork by @allison_horst

<!-- page 39 -->

# For loops

monster

parade = c( , , , , )

There are 5 elements in parade, so R will iterate the commands in the for loop 5 times, once for each element in parade.

```r
for (monster in parade) {

        if (shape(monster) == triangle) {
                monster_style = monster + sunglasses
        }

        else {
                monster_style = monster + hat
        }

        print(monster_style)

}
```

Artwork by @allison_horst

<!-- page 40 -->

# For loops

monster

```r
parade = c( , , , , )
```

```r
for (monster in parade) {

  if (shape(monster) == triangle) {
    monster_style = monster + sunglasses
  }

  else {
    monster_style = monster + hat
  }

  print(monster_style)

}
```

There are 5 elements in parade, so R will iterate the commands in the for loop 5 times, once for each element in parade.

Uses a conditional statement (IF/ELSE) to determine the values of monster_style depending on the values in monster

Artwork by @allison_horst

<!-- page 41 -->

# For loops

monster

parade = c( , , , , )

```r
for (monster in parade) {

    if (shape(monster) == triangle) {
        monster_style = monster + sunglasses
    }

    else {
        monster_style = monster + hat
    }

    print(monster_style)

}
```

There are 5 elements in parade, so R will iterate the commands in the for loop 5 times, once for each element in parade.

Uses a conditional statement (IF/ELSE) to determine the values of monster_style depending on the values in monster

Tells R to print monster_style.

Artwork by @allison_horst

<!-- page 42 -->

# For loops

What does this code do?

```r
mean_gamble<-rep(0,5)

for(i in 1:5){
  samp_gamble<-sample(gamble,5,replace=T)
  mean_gamble[i]<-mean(samp_gamble)
  }
```

<!-- page 43 -->

# For loops

What does this code do?

Creates vector called "mean_gamble" consisting of 0 repeated five times.

```r
mean_gamble<-rep(0,5)

for(i in 1:5){
  samp_gamble<-sample(gamble,5,replace=T)
  mean_gamble[i]<-mean(samp_gamble)
  }
```

<!-- page 44 -->

# For loops

What does this code do?

Creates vector called "mean_gamble" consisting of 0 repeated five times.

```r
mean_gamble<-rep(0,5)

for(i in 1:5){
  samp_gamble<-sample(gamble,5,replace=T)
  mean_gamble[i]<-mean(samp_gamble)
  }
```

For each item i in a list from 1:5 do the operations inside the curly braces.

<!-- page 45 -->

# For loops

What does this code do?

```r
mean_gamble<-rep(0,5)

for(i in 1:5){
  samp_gamble<-sample(gamble,5,replace=T)
  mean_gamble[i]<-mean(samp_gamble)
  }
```

Creates vector called "mean_gamble" consisting of 0 repeated five times.

For each item i in a list from 1:5 do the operations inside the curly braces.

Take 5 samples from "gamble" (with replacement) and store in vector called "samp_gamble".

<!-- page 46 -->

# For loops

What does this code do?

```r
mean_gamble<-rep(0,5)

for(i in 1:5){
  samp_gamble<-sample(gamble,5,replace=T)
  mean_gamble[i]<-mean(samp_gamble)
  }
```

Creates vector called “mean_gamble” consisting of 0 repeated five times.

For each item i in a list from 1:5 do the operations inside the curly braces.

Take 5 samples from “gamble” (with replacement) and store in vector called “samp_gamble”.

Take mean of “samp_gamble” and store in position corresponding to iteration number (1-5)

<!-- page 47 -->

# For loops

Creates vector called “mean_gamble” consisting of 0 repeated

What does this

You end up with the 0’s in mean_gamble being replaced by the mean of each of the 5 samples drawn.

```r
```{r}
mean_gamble

for(i in 1:
  samp_gamb
  mean_gamb
}
```
```

```r
> mean_gamble
[1] 30.98  9.56  2.82 42.30  4.94
> 
```

Take 5 samples from “gamble” (with
nd store in
“samp_gamble”.

For each item i in a list from 1:5 do the operations inside the curly braces.

Take mean of “samp_gamble” and store in position corresponding to iteration number (1-5)

<!-- page 48 -->

# Functions

* Have used existing functions all semester long (e.g., mean(), lm(), confint())
* Can also define our own functions to improve efficiency of our code using `function() { }`

<!-- page 49 -->

# Functions

## How to create a custom function in R

* Function name
* "function" & curly brackets
* arguments
* Function body

```r
add_three <- function(arg){
    output <- arg + 3
    return(output)
}
```

R for Ecology

<!-- page 50 -->

# Functions

## How to create a custom function in R

```r
> add_three <- function(arg){
+   output = arg + 3
+   return(output)
+ }
> add_three(3)
[1] 6
> 
```

Function body

arguments

R for Ecology

<!-- page 51 -->

# Functions

## How to create a custom function in R

Where we define/create the function "add_three".

```r
> add_three <- function(arg){
+   output = arg + 3
+   return(output)
+ }
> add_three(3)
[1] 6
> 
```

Function body

arguments

R for Ecology

<!-- page 52 -->

# Functions

## How to create a custom function in R

```r
> add_three <- function(arg){
+    output = arg + 3
+    return(output)
+ }
> add_three(3)
[1] 6
> 
```

Where we call/use the function “add_three”.

Function body

arguments

R for Ecology

<!-- page 53 -->

# Lab Session

- Use diabetes from faraway
- Focus on glyhb as a random variable and a model glyhb ~ chol
- Bootstrap
  - Mean of a random variable and its standard error and confidence interval
  - Simple linear regression: Standard error and confidence interval of regression coefficient
- Cross-validation in linear regression
  - Validation set approach
  - LOO
  - $k$-fold
