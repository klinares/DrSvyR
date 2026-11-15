---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class4_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class4_Lecture.pdf"
pages: 69
sha256: "a2e4251716091981de5f6ce05b80d5406d941ff853d0bb658b99ccbc674e8cdc"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:25"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #4

John Kubale

September 17, 2024

<!-- page 2 -->

# Outline

* Review
* Goal of Linear Regression Estimation
* Ordinary Least Squares (OLS) Estimation
* OLS assumptions and model performance
* Bias-variance trade-off

<!-- page 3 -->

# Homework

* Turn them in on time!
    * Didn't take off for late submissions with HW1, but moving forward unexcused late submissions start at 50%.
    * One submission per group.
* Moving forward will start marking off for non-pdf submissions.
* Make sure you answer the question(s) and include all relevant code and output.
* Describing null/alternative hypotheses in plain text is generally fine unless an equation is specifically asked for, so make sure to read the question carefully.

<!-- page 4 -->

# Exams

<!-- page 5 -->

# How will exam 1 work?

* Exam 1 is just around the corner
* How will it work?
  * Take home
  * Assigned 10/1 at 12pm
  * Due 10/8 at 930am
  * Covers lectures 1-5
* Class on 10/1 will be brief review of key concepts covered in lectures 1-5
* The exam should be your work alone – no Chat GPT or similar, don’t discuss with fellow students.
* The exam is open note/open book (i.e., all class materials)

<!-- page 6 -->

# How will exam 1 work?

* Some questions will require R while others you will have to answer on your own.
* All work should be completed in an R Markdown file and the knitted pdf file submitted.
  * This is what you will be graded on so make sure any relevant code, text, output is included.

<!-- page 7 -->

# How will exam 2 work?

* Exam 2 will work just like Exam 1 (with different due dates and more material)
* How will it work?
  * Take home
  * Assigned 11/5 at 12pm
  * Due 11/12 at 930am
  * Covers lectures 1-8 (through October 29)

<!-- page 8 -->

# How will exam 3 work?

* Broadly the same format (will turn in knitted pdf), but you will turn it in on 12/10
* How will it work?
  * Take home
  * Assigned 12/3 at 12pm
  * Due 12/10 at 12pm
  * Covers all material from semester

<!-- page 9 -->

# Review

<!-- page 10 -->

# Review – Interpreting confidence intervals

* Remember the confidence interval, your sample mean, and standard error will change with the sample – the true population mean does not.
    * It tells you where the population parameter is likely to reside.
* If we were to repeatedly sample and calculate a mean and 95% CI for a quantity, we would expect the true mean to fall within the CI 95% of the time.
    * You could also say that you are 95% confident that the population mean falls within the confidence interval.

<!-- page 11 -->

# Review – Interpreting confidence intervals

* Example using Boston housing data from ISLR2
* Take 100 random samples ($n=50$) from the Boston housing dataset and calculate the sample mean of `medv` and 95% CI for each.
* Plot each sample mean and 95% CI against the “true population mean” (here the mean from the entire Boston dataset).

<!-- page 12 -->

# Review – Interpreting confidence intervals

<!-- page 13 -->

# Goal of Linear Regression Model Estimation

<!-- page 14 -->

# Goal of Linear Regression Model Estimation-1

* Compare the red and black regression lines.
  * Which is better?
  * What are the black lines?
* Comparing Education and Seniority, which describes the pattern in Income better? Why?

**Income=f(Education) (N=30)**

**Income=f(Seniority) (N=30)**

<!-- page 15 -->

# Goal of Linear Regression Model Estimation-2

$$
Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon
$$

$$
Y = X\beta + \epsilon
$$

* Finding unique solutions to $\beta_0, \beta_1, \beta_2$ (i.e., $\beta$) that will make $\beta_0 + \beta_1 X_1 + \beta_2 X_2$ (i.e., $X\beta$) as close to $Y$ as possible.
  * Put another way – want to find smallest $\epsilon$ with respect to its mean and variance (technically we want the smallest sum of squared residuals: $\sum_{i=1}^n \epsilon_i^2$ AKA the SSR, or RSS, or SSE)

How do we do that? $\rightarrow$ Ordinary Least Squares Estimation

<!-- page 16 -->

# Goal of Linear Regression Model Estimation-2

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \epsilon$$

$$Y = X\beta + \epsilon$$

* Finding unique solutions to $\beta_0, \beta_1, \beta_2$ (i.e., $\beta$) that will make $\beta_0 + \beta_1 X_1 + \beta_2 X_2$ (i.e., $X\beta$) as close to $Y$ as possible.
  * Put another way – want to find smallest $\epsilon$ with respect to its mean and variance (technically we want the smallest sum of squared residuals: $\sum_{i=1}^n \epsilon_i^2$ AKA the SSR, or RSS, or SSE)

Residual sum of squares

Sum of squared errors

How do we do that? $\rightarrow$ Ordinary Least Squares (OLS) Estimation

<!-- page 17 -->

# Ordinary Least Squares (OLS) Estimation

<!-- page 18 -->

# Ordinary Least Squares (OLS) Estimation - 1

How to estimate $\beta_0$ and $\beta_1$ for $Y_i = \beta_0 + \beta_1 X_{1i} + \epsilon_i$?

Assuming that there are observations of $n$ pairs of data points as

$(X_1, Y_1), \dots, (X_n, Y_n)$

we find $\beta_0$ and $\beta_1$ that makes $\widehat{Y}_i$ ($i.e., \beta_0 + \beta_1 X_{1i}$) as close to $Y_i$ as possible

Do this by minimizing

$$\begin{aligned}
\sum_{i=1}^n \epsilon_i^2 &= \sum_{i=1}^n (Y_i - \beta_0 - \beta_1 X_i)^2 \\
&= \boldsymbol{\epsilon}^T \boldsymbol{\epsilon} = (\boldsymbol{Y} - \boldsymbol{X}\boldsymbol{\beta})^T (\boldsymbol{Y} - \boldsymbol{X}\boldsymbol{\beta})
\end{aligned}$$

Ordinary Least Squares Estimation

<!-- page 19 -->

# Ordinary Least Squares (OLS) Estimation - 2

How to estimate $\beta_0$ and $\beta_1$ for $Y_i = \beta_0 + \beta_1 X_{1i} + \epsilon_i$?

Assuming that there are observations of $n$ pairs of data points as

$$(X_1, Y_1), \dots, (X_n, Y_n)$$

we find $\beta_0$ and $\beta_1$ that makes $\widehat{Y}_i$ ($i.e., \beta_0 + \beta_1 X_{1i}$) as close to $Y_i$ as possible

Do this by minimizing

$$\sum_{i=1}^n \epsilon_i^2 = \sum_{i=1}^n (Y_i - \widehat{Y}_i)^2$$

$$= \epsilon^T \epsilon = (Y - X\beta)^T (Y - X\beta)$$

Can also be written like this.

What is this the formula for?

Ordinary Least Squares Estimation

<!-- page 20 -->

# uares (OLS) Estimation - 3

$= \beta_0 + \beta_1 X_{1i} + \epsilon_i?$

ns of $n$ pairs of data points as

$e., \beta_0 + \beta_1 X_{1i})$ as close to $Y_i$ as possible

Do this by minimizing

$$\sum_{i=1}^n \epsilon_i^2 = \sum_{i=1}^n (Y_i - \hat{Y}_i)^2$$

$$= \epsilon^T \epsilon = (Y - X\beta)^T(Y - X\beta)$$

Can also be written like this.

What is this the formula for?

Ordinary Least Squares Estimation

<!-- page 21 -->

# Ordinary Least Squares (OLS) Estimation-4

* When assumptions are met (stay tuned), estimated error variance through residuals is unbiased as:

$$
E\left(\widehat{\sigma^2}\right) = \sigma^2, where\ \widehat{\sigma^2} = \frac{\sum_{i=1}^n \widehat{\epsilon_i^2}}{n-2}
$$

<!-- page 22 -->

# Ordinary Least Squares (OLS) Estimation - 5

Why do we minimize $\sum_{i=1}^{n} \epsilon_i^2$ and vs. $\epsilon_i$?

What does this look like graphically?

<!-- page 23 -->

# Ordinary Least Squares (OLS) Estimation - 6

* The black lines represent the residuals or the difference in estimated values (from the linear regression, $\hat{y}_i$) from the observed values ($y_i$).
* We need to consider all of these differences
  * What do you think would happen if we added them together?
  * Do you notice anything else in the figure?

<!-- page 24 -->

# Ordinary Least Squares (OLS) Estimation - 7

* Since we have data points that are both above and below the regression line, summing them would lead to them canceling out.
* To avoid this we sum the square of each residual and minimize that quantity to fit a regression line by OLS.

<!-- page 25 -->

# Ordinary Least Squares (OLS) Estimation - 8

* Since we have data points that are both above and below the regression line, summing them would lead to them canceling out.
* To avoid this we sum the square of each residual and minimize that quantity to fit a regression line by OLS.

OLS works by finding the regression line that minimizes the sum of the shaded squares (the residual sum of squares)

<!-- page 26 -->

# How does $\sum_{i=1}^n \epsilon_i^2$ compare between models?

<!-- page 27 -->

# OLS Estimators of Intercept and Slope

$$
\begin{aligned}
\hat{\beta}_1 &= \frac{\displaystyle\sum_{i=1}^n (X_i - \bar{X})(Y_i - \bar{Y})}{\displaystyle\sum_{i=1}^n (X_i - \bar{X})^2} \\
&\equiv \frac{SS_{XY}}{SS_X} = \frac{SS_{XY}(n - 1)^{-1}}{SS_X(n - 1)^{-1}} = \frac{s_{XY}}{s_{XX}}
\end{aligned}
$$

$$
\hat{\beta}_0 = \bar{Y} - \bar{X}\hat{\beta}_1
$$

<!-- page 28 -->

# OLS Estimators of Intercept and Slope

$$\hat{\beta}_1 = \frac{\sum_{i=1}^n (X_i - \bar{X})(Y_i - \bar{Y})}{\sum_{i=1}^n (X_i - \bar{X})^2}$$

$$\equiv \frac{SS_{XY}}{SS_X} = \frac{SS_{XY}(n - 1)^{-1}}{SS_X(n - 1)^{-1}} = \frac{s_{XY}}{s_{XX}}$$

$$\hat{\beta}_0 = \bar{Y} - \bar{X}\hat{\beta}_1$$

<!-- page 29 -->

# OLS Estimators of Intercept and Slope

$$
\begin{aligned}
\hat{\beta}_1 &= \frac{\sum_{i=1}^{n}(X_i - \bar{X})(Y_i - \bar{Y})}{\sum_{i=1}^{n}(X_i - \bar{X})^2} \\
&\equiv \frac{SS_{XY}}{SS_X} = \frac{SS_{XY}(n - 1)^{-1}}{SS_X(n - 1)^{-1}} = \frac{s_{XY}}{s_{XX}}
\end{aligned}
$$

$$
\hat{\beta}_0 = \bar{Y} - \bar{X}\hat{\beta}_1
$$

\*Sum of the product of the difference between each x and the mean of x and each y and the mean of y\*

<!-- page 30 -->

# OLS Estimators of Intercept and Slope

$$
\hat{\beta}_1 = \frac{\sum_{i=1}^{n} (X_i - \bar{X})(Y_i - \bar{Y})}{\sum_{i=1}^{n} (X_i - \bar{X})^2}
$$

$$
\equiv \frac{SS_{XY}}{SS_X} = \frac{SS_{XY}(n-1)^{-1}}{SS_X(n-1)^{-1}} = \frac{s_{XY}}{s_{XX}}
$$

$$
\hat{\beta}_0 = \bar{Y} - \bar{X}\hat{\beta}_1
$$

\*Sum of squared differences between each x and the mean of x\*

<!-- page 31 -->

# OLS Estimators of Intercept and Slope

$$\hat{\beta}_1 = \frac{\sum_{i=1}^n (X_i - \bar{X})(Y_i - \bar{Y})}{\sum_{i=1}^n (X_i - \bar{X})^2}$$

$$\equiv \frac{SS_{XY}}{SS_X} = \frac{SS_{XY}(n - 1)^{-1}}{SS_X(n - 1)^{-1}} = \frac{s_{XY}}{s_{XX}}$$

$$\hat{\beta}_0 = \bar{Y} - \bar{X}\hat{\beta}_1$$

\*Sum of squared differences between each $x_i$ and the mean of $x$\*

In the lab today you will use these formulas to calculate regression coefficients manually (or semi-manually since you will use R).

<!-- page 32 -->

# SSy, SSx, RSS, etc.

<!-- page 33 -->

# SSx

Measure of the overall variability in variable x (i.e., your predictor).

Remember that really SSx corresponds to the sum of squared differences:

$$\sum (x_i - \bar{x})^2$$

<!-- page 34 -->

# Ssy

Measure of the overall variability in variable y (i.e., your outcome).

Remember that really SSy corresponds to the sum of squared differences:

$$\sum (y_i - \bar{y})^2$$

Also known as SST.

<!-- page 35 -->

# SST, SSR, and RSS

SSy (or SST)

<!-- page 36 -->

# SST, SSR, and RSS

?

SSy (or SST)

Y

20

10

0

-10

-10

-5

0

5

X

<!-- page 37 -->

# SST, SSR, and RSS

RSS

SSy (or SST)

<!-- page 38 -->

# SST, SSR, and RSS

RSS

SSy (or SST)

?

<!-- page 39 -->

# SST, SSR, and RSS

RSS

SSR

SSy (or SST)

Y

X

<!-- page 40 -->

# SST, SSR, and RSS

**SSy/SST:** Total amount of variability in outcome, y

**SSR:** Amount of variability in outcome explained by regression model

**RSS:** Amount of variability in outcome **not explained** by regression model

RSS

SSR

SSy (or SST)

<!-- page 41 -->

# OLS assumptions

<!-- page 42 -->

# OLS Assumptions

Will see these assumptions presented a variety of ways (e.g., some are often combined), but they boil down to the following:

1. There is a linear relationship between the predictor(s) $X$ and the outcome $Y$. – Relatively simple assumption to relax as we will see.
2. Variable, $X_1, \dots, X_n$, are fixed constants such that $S_{XX} > 0$
3. Variable, $\epsilon_1, \dots, \epsilon_n$, are random variables
4. Zero Error Mean: $E(\epsilon_i) = 0$ for $i = 1, \dots, n$
5. Uncorrelated errors: $\epsilon_1, \epsilon_2, \dots, \epsilon_n$ are not correlated – i.e., knowing value of $\epsilon_1$ tells you nothing about $\epsilon_2, \dots, \epsilon_n$
6. Constant error variance: $\text{V}(\epsilon_i) = \sigma^2$ -- AKA homoscedasticity
7. Error normality: $\epsilon_i \sim N(0, \sigma^2)$ for $i = 1, \dots, n$

<!-- page 43 -->

# OLS Assumptions

Pay particular attention to assumptions 4-7
* Taken together they state that our errors are assumed to be normal, independent, and identically distributed (Normal I.I.D).

Jenkins-Smith, Ripberger, Copeland, et. al.

<!-- page 44 -->

# Why are these assumptions important?

* Have impact on how well OLS is able to estimate our parameters of interest.
* We’ll go over how to diagnose such violations in a later lecture.
* First, we need to define how we evaluate our models and parameters.
  * We’ll then look at what happens to our model and parameters when we violate some of these assumptions.

<!-- page 45 -->

# Evaluating estimators

<!-- page 46 -->

# Bias, efficiency, and Consistency

* Bias: Do we get the "correct answer" on average across many repeated samples?
  * An estimator is considered "unbiased" if its expected value equals the true value on average
* Efficiency: the variance around an estimate
  * Efficient -> little variability in estimate across samples
  * Inefficient -> large variability in estimate across samples
* Consistency: estimate gets closer to truth as sample size increases
  * Different from bias which implies that estimate is close to the truth on average even when sample size is small

<!-- page 47 -->

# Bias, efficiency, and Consistency

* Bias: Do we get the "correct answer" on average across many repeated samples?
  * An est... he true value
* Efficienc...
  * Efficie...
  * Ineffic...
* Consiste... creases
  * Differe... on average even when s...

> “...Given that nearly all social science research is conducted using just one sample of data (e.g., one survey sample), researchers should take efficiency just as seriously. As an estimator becomes less efficient, the likelihood that a singe estimate is close to the true parameter declines.”
>
> Carsey and Harden

<!-- page 48 -->

# Bias, efficiency, and Consistency

| | High efficiency | Low efficiency |
| :--- | :---: | :---: |
| **Low bias** | | |
| **High bias** | | |

<!-- page 49 -->

# Assessing measure performance in R

<!-- page 50 -->

# Why are assumptions important?

* Let’s look at how violating the constant variance assumption might impact our estimates.

<!-- page 51 -->

# Homoscedasticity AKA constant variance

* First, we'll fit a model many times (using simulated data so we have total control) where none of the OLS assumptions are violated.
* Then we'll fit the same model (again many times), but we'll break the constant variance assumption.
* We can then see whether this impacts the bias, efficiency, or consistency of our estimates.

<!-- page 52 -->

# How do we repeat the same thing in R?

* For loops!
* For loops are commonly used to streamline repetitive tasks
  * Part of good coding is DRY (“Don’t Repeat Yourself”)

```r
for(item in list_of_items){
  do_something(item)
}
```

* In words: For each item in a sequence or list of items (vector, dataframe, etc.), perform some operation (apply a function)

<!-- page 53 -->

# Let’s run our simulations

```r
# Heteroskedastic sim 2
sigma <- mean(sigma.est) # Assign mean sigma from initial heteroskedastic model to homoskedastic model

set.seed(894894)

reps <- 1000 # Set number of repetitions to run the simulations
par.est.ncv <- matrix(NA, nrow = reps, ncol = 6) # Create empty matrix to store results


b0 <- 0.2 # Set true value for intercept
b1 <- 0.5 # Set true value for slope
n <- 1000 # Set sample size
X <- runif(n, -1, 1) # Create a sample of n observations of independent variable X

gamma <- 1.5 # Set heteroskedasticity parameter

for(i in 1:reps){
  Y1 <- b0 + b1*X + rnorm(n, 0, exp(X*gamma)) #Y1: Heteroskedasticity
  Y2 <- b0 + b1*X + rnorm(n, 0, sigma) #Y2: Homoskedasticity w/same mean sigma


  model1 <- lm(Y1 ~ X) # Fit OLS model 1
  model2 <- lm(Y2 ~ X) # Fit OLS model 2

  vcv <- vcov(model1) # Get variance-covariance matrix for model1

  # sigma.est[i] <- summary(model)$sigma # Store sigma estimates

  par.est.ncv[i,1] <- model1$coef[1] # Save estimate for intercept in column 1 (model 1)
  par.est.ncv[i,2] <- model1$coef[2] # Save estimate for slope of X in column 2 (model 1)

  par.est.ncv[i,3] <- model2$coef[1] # Save estimate for intercept in column 1 (model 2)
  par.est.ncv[i,4] <- model2$coef[2] # Save estimate for slope of X in column 2 (model 2)

  par.est.ncv[i,5] <- sqrt(diag(vcv)[1]) # Save estimate for SE of intercept (model 1)
  par.est.ncv[i,6] <- sqrt(diag(vcv)[2]) # Save estimate for SE of slope (model 1)
}

models_df <- as.data.frame(par.est.ncv)
names(models_df) <- c("b0_mod1", "b1_mod1", "b0_mod2", "b1_mod2", "b0se_mod1", "b1se_mod1")
```

<!-- page 54 -->

# Let’s run our simulations

Fitting 2 models:
model1 with non-constant variance and model2 with constant variance

Saving the betas from both models.

```r
# Heteroskedastic sim 2
sigma <- mean(sigma.est) # Assign mean sigma from initial heteroskedastic model to homoskedastic model

set.seed(894894)

reps <- 1000 # Set number of repetitions to run the simulations
par.est.ncv <- matrix(NA, nrow = reps, ncol = 6) # Create empty matrix to store results

b0 <- 0.2 # Set true value for intercept
b1 <- 0.5 # Set true value for slope
n <- 1000 # Set sample size
X <- runif(n, -1, 1) # Create a sample of n observations of independent variable X

gamma <- 1.5 # Set heteroskedasticity parameter

for(i in 1:reps){
  Y1 <- b0 + b1*X + rnorm(n, 0, exp(X*gamma)) #Y1: Heteroskedasticity
  Y2 <- b0 + b1*X + rnorm(n, 0, sigma) #Y2: Homoskedasticity w/same mean sigma
  
  model1 <- lm(Y1 ~ X) # Fit OLS model 1
  model2 <- lm(Y2 ~ X) # Fit OLS model 2
  
  vcv <- vcov(model1) # Get variance-covariance matrix for model1
  
  # sigma.est[i] <- summary(model)$sigma # Store sigma estimates
  
  par.est.ncv[i,1] <- model1$coef[1] # Save estimate for intercept in column 1 (model 1)
  par.est.ncv[i,2] <- model1$coef[2] # Save estimate for slope of X in column 2 (model 1)
  
  par.est.ncv[i,3] <- model2$coef[1] # Save estimate for intercept in column 1 (model 2)
  par.est.ncv[i,4] <- model2$coef[2] # Save estimate for slope of X in column 2 (model 2)
  
  par.est.ncv[i,5] <- sqrt(diag(vcv)[1]) # Save estimate for SE of intercept (model 1)
  par.est.ncv[i,6] <- sqrt(diag(vcv)[2]) # Save estimate for SE of slope (model 1)
}

models_df <- as.data.frame(par.est.ncv)
names(models_df) <- c("b0_mod1", "b1_mod1", "b0_mod2", "b1_mod2", "b0se_mod1", "b1se_mod1")
```

<!-- page 55 -->

# Distribution of estimated parameters

Heteroscedastic Homoscedastic

Density

$\hat{\beta}_0$

Heteroscedastic Homoscedastic

Density

$\hat{\beta}_1$

<!-- page 56 -->

# Estimating parameters with non-constant variance

* The density of both estimates $\hat{\beta}_0$ and $\hat{\beta}_1$ are centered around the true values – they’re unbiased.
* The spread of estimates for $\hat{\beta}_0$ looks pretty similar for both the homoscedastic and the heteroscedastic models.
* What about for $\hat{\beta}_1$?

<!-- page 57 -->

# Estimating parameters with non-constant variance

* The density of both estimates $\hat{\beta}_0$ and $\hat{\beta}_1$ are centered around the true values – they’re unbiased.
* The spread of estimates for $\hat{\beta}_0$ looks pretty similar for both the homoscedastic and the heteroscedastic models.
* What about for $\hat{\beta}_1$?
  * Greater spread in heteroscedastic estimates from heteroscedastic model – less efficiency!
  * Standard errors for $\hat{\beta}_1$ using OLS when constant variance assumption violated will be too small on average.

<!-- page 58 -->

# Bias variance tradeoff

<!-- page 59 -->

# Flexibility vs. interpretability

<!-- page 60 -->

# Flexibility

* So far, we’ve largely talked about model flexibility with regards to what this means for interpretability.
* Also important to think about this in the context of model fit (i.e., error).
  * Important to distinguish between training and test data.

<!-- page 61 -->

# Training vs. test data

* Training data are the model used to fit (or train) your model
* Test data are data <u>not used</u> in fitting/training the model, but that the model is used on to make predictions or inferences
* Each has their own error (i.e., training error and test error)
* Which do you think is most important for assessing model fit?
  * Can you see any challenges in using it for assessing model fit?

<!-- page 62 -->

# Training vs. test

(JWHT Figure 2.4, 2.5, 2.6 - Estimated $f$)

What do the black bars between the red data points and the yellow plane represent?

Is this training or test data?

<!-- page 63 -->

# Training vs. test

What problems might we run into if we focus only on minimizing our training error?

(JWHT Figure 2.4, 2.5, 2.6 - Estimated $f$)

What do the black bars between the red data points and the yellow plane represent?

Is this training or test data?

<!-- page 64 -->

# Overfitting

* Focusing too much on minimizing training error can result in overfitting
* The model does a great job of representing the data in our sample, but a poor job of representing data in other samples or in the population of interest

<!-- page 65 -->

# Bias-variance trade-off-1

Among the yellow, blue, and green fit lines which is the least flexible? Most flexible?

<!-- page 66 -->

# Bias-variance trade-off-2

<!-- page 67 -->

# Bias-variance trade-off-3

* What do we mean by bias and variance here?
* **<u>Variance/efficiency</u>**: Amount our model would change if we were to fit it to another training dataset
* **<u>Bias</u>**: Error introduced by approximating real-world relationship with simple (or at least simpler) model

<!-- page 68 -->

# Bias-variance trade-off-4

* We want to balance variance and bias with our modeling approach so that we get consistent results (low variance) and do a decent job of representing reality (low bias).
* Which of the three modeling approaches would you choose?

<!-- page 69 -->

# Bias-variance trade-off-4

* We want to balance variance and bias with our modeling approach so that we get consistent results (low variance) and do a decent job of representing reality (low bias).
* Which of the three modeling approaches would you choose?

\*\*Will learn some tools to help with this in lecture 14 when we talk about cross-validation
