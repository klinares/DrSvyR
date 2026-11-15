---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Class7_Lecture"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Statistical Methods & Machine Learning 1"
original: "stat_mod_ML_1_SURV615/lectures/Class7_Lecture.pdf"
pages: 65
sha256: "1a929b4147117f1fcc0eed1d2673a15e6a86ad06147027a96fe58fe7e60e2e61"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:18"
---

<!-- page 1 -->

# Statistical Methods & Machine Learning 1

Class #7

John Kubale

October 8, 2024

<!-- page 2 -->

# Outline

* A couple quick items
* Categorical Predictor Variables
    * Binary Predictor Variables
    * Linear Regression Intercepts
    * Predictors with More than 2 Categories
* Interactions of Predictor Variables

<!-- page 3 -->

# Exam 1

* Folks are still working on the exam this week due to different situations so please do not discuss it!
* We will start working on grading this week to try and get it turned around soon.

<!-- page 4 -->

# No class next week

* It will be fall break for UM next Monday/Tuesday so there will be **<u>no class for anyone on October 15</u>**.
* This means you will have an extra week to complete HW5.
    * Due by 9:30am on October 22
* Homework groups will change starting with HW 6

<!-- page 5 -->

# Interpreting regression coefficients

<!-- page 6 -->

# Linear regression with continuous predictor(s)

* Without any predictor

$$y_i = \beta_0 + \epsilon_i$$

* One continuous predictor

$$y_i = \beta_0 + \beta_1 x_1 + \epsilon_i$$

* Multiple continuous predictors

$$y_i = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \epsilon_i$$

<!-- page 7 -->

# Categorical Predictor Variables

<!-- page 8 -->

# Predictor Variable Types

* Quantitative
  * Continuous (e.g., Income in \$)
  * Ordinal (e.g., Strongly Agree – Agree – Neither – Disagree – Strongly Disagree)
    * Likert Scale (pronounced Lick-ert)
* Qualitative
  * Two categories (e.g., Yes, No); Binary; Dichotomous; Bernoulli
  * More than two categories (e.g., Race: Black, White, American Indian, Asian, Other); Categorical; Multinomial

<!-- page 9 -->

# Let's look at some data: Wage in ISLR - 1

A data frame with 3000 observations on the following 11 variables.

`year` Year that wage information was recorded

`age` Age of worker

`maritl` A factor with levels `1. Never Married` `2. Married` `3. Widowed` `4. Divorced` and `5. Separated` indicating marital status

`race` A factor with levels `1. White` `2. Black` `3. Asian` and `4. Other` indicating race

`education` A factor with levels `1. < HS Grad` `2. HS Grad` `3. Some College` `4. College Grad` and `5. Advanced Degree` indicating education level

`region` Region of the country (mid-atlantic only)

`jobclass` A factor with levels `1. Industrial` and `2. Information` indicating type of job

`health` A factor with levels `1. <=Good` and `2. >=Very Good` indicating health level of worker

`health_ins` A factor with levels `1. Yes` and `2. No` indicating whether worker has health insurance

`logwage` Log of workers wage

`wage` Workers raw wage

<!-- page 10 -->

# Let’s look at some data: Wage in ISLR - 1

A data frame with 3000 observations on the following 11 variables.

`year` Year that wage information was recorded

`age` Age of worker

`maritl` A factor with levels `1. Never Married` `2. Married` `3. Widowed` `4. Divorced` and `5. Separated` indicating marital status

`race` A factor with levels `1. White` `2. Black` `3. Asian` and `4. Other` indicating race

`education` A factor with levels `1. < HS Grad` `2. HS Grad` `3. Some College` `4. College Grad` and `5. Advanced Degree` indicating education level

`region` Region of the country (mid-atlantic only)

`jobclass` A factor with levels `1. Industrial` and `2. Information` indicating type of job

`health` A factor with levels `1. <=Good` and `2. >=Very Good` indicating health level of worker

`health_ins` A factor with levels `1. Yes` and `2. No` indicating whether worker has health insurance

`logwage` Log of workers wage

`wage` Workers raw wage

<!-- page 11 -->

# Let’s look at some data: Wage in ISLR - 1

A data frame with 3000 observations on the following 11 variables.

`year` Year that wage information was recorded

`age` Age of worker

`maritl` A factor with ... `4. Divorced` and `5. Separated` in...

`race` A factor with lev... ...ing race

`education` A factor w... ... `4. College Grad` and `5. Advanced`...

> Allows us to explore questions like:
> “how does the expected mean
> wage change with a one-year
> change in age.

`region` Region of the country (mid-atlantic only)

`jobclass` A factor with levels `1. Industrial` and `2. Information` indicating type of job

`health` A factor with levels `1. <=Good` and `2. >=Very Good` indicating health level of worker

`health_ins` A factor with levels `1. Yes` and `2. No` indicating whether worker has health insurance

`logwage` Log of workers wage

`wage` Workers raw wage

<!-- page 12 -->

# Let's look at some data: Wage in ISLR - 1

A data frame with 3000 observations on the following 11 variables.

`year` Year that wage information was recorded

`age` Age of worker

`maritl` A factor with ... `4. Divorced` and `5. Separated` in...

`race` A factor with lev... ...ing race

`education` A factor wi... ...`4. College Grad` and `5. Advanced`...

`region` Region of the country (mid-atlantic only)

`jobclass` A factor with levels `1. Industrial` and `2. Information` indicating type of job

`health` A factor with...

`health_ins` A factor...

`logwage` Log of wor...

`wage` Workers raw w...

What about if we wanted to explore the association between wage and a non-continuous predictor like "jobclass"?

How does that impact the way we interpret our model?

What if we wanted to look at a categorical predictor with $>2$ categories like "education"?

<!-- page 13 -->

# Binary Predictor Variables

<!-- page 14 -->

# Binary Predictor Variables

$y_1, \dots, y_n$ from the combined sample of 2 levels (e.g., wage from industrial vs. information job classes)

Two dummy variables $(d_{1i}, d_{2i})$ defined as:

$$
d_{1i} = \begin{cases} 1 & \text{If } i^{th} \text{ unit is in level 1 (e.g., male); treatment} \\ 0 & \text{otherwise; reference} \end{cases}
$$

$$
d_{2i} = \begin{cases} 1 & \text{If } i^{th} \text{ unit is in level 2 (e.g., female); treatment} \\ 0 & \text{otherwise; reference} \end{cases}
$$

Hence, $d_{1i} + d_{2i} = 1$

<!-- page 15 -->

# Binary Predictor Variables

Let's look at an example using the `Wage` dataset from the `ISLR2` package. We'll fit a simple linear regression model with `wage` as a function of `jobclass`.

We'll create our dummy variables manually in this case. Specifically:

* indus: 1 = industrial; 0 = non-industrial
* info: 1 = information; 0 = non-information

```r
lm(wage ~ indus + info, Wage)
```

<!-- page 16 -->

# Binary Predictor Variables

```r
Call:
lm(formula = wage ~ indus + info, data = wage)

Residuals:
     Min       1Q   Median       3Q      Max 
-100.507  -25.362   -6.117   15.697  197.750 

Coefficients: (1 not defined because of singularities)
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  120.593      1.070  112.69   <2e-16 ***
indus        -17.272      1.492  -11.58   <2e-16 ***
info              NA         NA      NA       NA    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

What happened here?

<!-- page 17 -->

# Binary Predictor Variables

```r
Call:
lm(formula = wage ~ indus + info, data = wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.507 -25.362  -6.117  15.697 197.750 

Coefficients: (1 not defined because of singularities)
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  120.593      1.070  112.69   <2e-16 ***
indus        -17.272      1.492  -11.58   <2e-16 ***
info              NA         NA      NA       NA    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1

Residual standard error: 40.83 on 2998 degrees of freedo
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.0
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

What happened here?

The model.matrix() function can give us a clue.

<!-- page 18 -->

# Binary Predictor Variables

| $Y (\texttt{Income})$ | $X_1 (\texttt{Education})$ | $X_2 (\texttt{Senority})$ |
| :---: | :---: | :---: |
| 99.917 | 21.586 | 113.103 |
| 92.579 | 18.276 | 119.310 |
| 34.679 | 12.069 | 100.690 |
| $\vdots$ | $\vdots$ | $\vdots$ |
| 74.611 | 17.034 | 106.897 |

`model.matrix()` gives us the observed values used in the model which multiplied by their respective betas and added together give us the fitted values

$$
\begin{pmatrix}
99.917 \\
92.579 \\
34.679 \\
\vdots \\
74.611
\end{pmatrix}
= \beta_0 + \beta_1 \times
\begin{pmatrix}
21.586 \\
18.276 \\
12.069 \\
\vdots \\
17.034
\end{pmatrix}
+ \beta_2 \times
\begin{pmatrix}
113.103 \\
119.310 \\
100.690 \\
\vdots \\
106.897
\end{pmatrix}
+
\begin{pmatrix}
\\
\epsilon_2 \\
\epsilon_3 \\
\vdots \\
\epsilon_N
\end{pmatrix}
$$

Gives a vector of 1's for the intercept as $\beta_0 * 1 = \beta_0$

<!-- page 19 -->

# Binary Predictor Variables

```r
> head(model.matrix(mod_j1))
       (Intercept) indus info
231655           1     1    0
86582            1     0    1
161300           1     1    0
155159           1     0    1
11443            1     0    1
376662           1     0    1
```

Both of our predictors are dummy/indicator variables derived from the `jobclass` variable.

Does anything stand out?

<!-- page 20 -->

# Binary Predictor Variables

```r
> head(model.matrix(mod_j1))
       (Intercept) indus info
231655           1     1    0
86582            1     0    1
161300           1     1    0
155159           1     0    1
11443            1     0    1
376662           1     0    1
```

Both of our predictors are dummy/indicator variables derived from the `jobclass` variable.

Does anything stand out?

They're simply the inverse of each other. No additional information is provided by one that's not already provided by the other. We're trying to use 3 parameters to model only 2 groups.

<!-- page 21 -->

# Binary Predictor Variables

```r
> head(model.matrix(mod_j1))
       (Intercept) indus info
231655           1     1    0
86582            1     0    1
161300           1     1    0
155              1     0    1
11443            1     0    1
376662           1     0    1
```

We would say that this matrix is “not of full rank”

Both of our predictors are dummy/indicator variables derived from the `jobclass` variable.

Does anything stand out?

They’re simply the inverse of each other. No additional information is provided by one that’s not already provided by the other. We’re trying to use 3 parameters to model only 2 groups.

<!-- page 22 -->

# Dummy Variables in Regression - 3

Non-estimable model: $y_i = \beta_0 + \beta_1 d_{1i} + \beta_2 d_{2i} + \epsilon_i$

Two ways to make the model estimable:

1. Drop the intercept
2. Drop one of the dummy variables
   * Also viewed through linear transformation

$$
\begin{aligned}
y_i &= \mu_1 d_{1i} + \mu_2 d_{2i} + \epsilon_i \\
&= \mu_1 (1 - d_{2i}) + \mu_2 d_{2i} + \epsilon_i \\
&= \mu_1 + (\mu_2 - \mu_1) d_{2i} + \epsilon_i \\
&= \gamma_0 + \gamma_2 d_{2i} + \epsilon_i
\end{aligned}
$$

   * Inferences about $\gamma_2$ allows hypothesis test as
   $H_0: \gamma_2 = 0 (\rightarrow \mu_1 = \mu_2) \text{ vs. } H_A: \gamma_2 \neq 0 (\rightarrow \mu_1 \neq \mu_2)$

What does $\gamma_2$ mean?
What about $\gamma_0$?
How about $\gamma_0 + \gamma_2$?

<!-- page 23 -->

# Dummy Variables in Regression - 4

Non-estimable model: $y_i = \beta_0 + \beta_1 d_{1i} + \beta_2 d_{2i} + \epsilon_i$

Two ways to make the model estimable:

1. Drop the intercept
2. Drop one of the dummy variables
   * Also viewed through linear transformation

$$
\begin{aligned}
y_i &= \mu_1 d_{1i} + \mu_2 d_{2i} + \epsilon_i \\
&= \mu_1(1 - d_{2i}) + \mu_2 d_{2i} + \epsilon_i \\
&= \mu_1 + (\mu_2 - \mu_1)d_{2i} + \epsilon_i \\
&= \gamma_0 + \gamma_2 d_{2i} + \epsilon_i
\end{aligned}
$$

   * Inferences about $\gamma_2$ allows hypothesis test as
     $H_0: \gamma_2 = 0 (\rightarrow \mu_1 = \mu_2) \text{ vs. } H_A: \gamma_2 \neq 0 (\rightarrow \mu_1 \neq \mu_2)$

R will do this automatically when you fit a model with a “factor” predictor. This becomes your reference group.

What does $\gamma_2$ mean?
What about $\gamma_0$?
How about $\gamma_0 + \gamma_2$?

<!-- page 24 -->

# Let’s look again at Wage in ISLR2 - 1

| | year | age | maritl | race | education | region | jobclass | health | health_ins | logwage | wage |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **231655** | 2006 | 18 | 1. Never Married | 1. White | 1. < HS Grad | 2. Middle Atlantic | 1. Industrial | 1. <=Good | 2. No | 4.318063 | 75.04315 |
| **86582** | 2004 | 24 | 1. Never Married | 1. White | 4. College Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 2. No | 4.255273 | 70.47602 |
| **161300** | 2003 | 45 | 2. Married | 1. White | 3. Some College | 2. Middle Atlantic | 1. Industrial | 1. <=Good | 1. Yes | 4.875061 | 130.98218 |
| **155159** | 2003 | 43 | 2. Married | 3. Asian | 4. College Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 1. Yes | 5.041393 | 154.68529 |
| **11443** | 2005 | 50 | 4. Divorced | 1. White | 2. HS Grad | 2. Middle Atlantic | 2. Information | 1. <=Good | 1. Yes | 4.318063 | 75.04315 |
| **376662** | 2008 | 54 | 2. Married | 1. White | 4. College Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 1. Yes | 4.845098 | 127.11574 |
| **450601** | 2009 | 44 | 2. Married | 4. Other | 3. Some College | 2. Middle Atlantic | 1. Industrial | 2. >=Very Good | 1. Yes | 5.133021 | 169.52854 |
| **377954** | 2008 | 30 | 1. Never Married | 3. Asian | 3. Some College | 2. Middle Atlantic | 2. Information | 1. <=Good | 1. Yes | 4.716003 | 111.72085 |
| **228963** | 2006 | 41 | 1. Never Married | 2. Black | 3. Some College | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 1. Yes | 4.778151 | 118.88436 |
| **81404** | 2004 | 52 | 2. Married | 1. White | 2. HS Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 1. Yes | 4.857332 | 128.68049 |
| **302778** | 2007 | 45 | 4. Divorced | 1. White | 3. Some College | 2. Middle Atlantic | 2. Information | 1. <=Good | 1. Yes | 4.763428 | 117.14682 |
| **305706** | 2007 | 34 | 2. Married | 1. White | 2. HS Grad | 2. Middle Atlantic | 1. Industrial | 2. >=Very Good | 2. No | 4.397940 | 81.28325 |
| **8690** | 2005 | 35 | 1. Never Married | 1. White | 2. HS Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 1. Yes | 4.494155 | 89.49248 |
| **153561** | 2003 | 39 | 2. Married | 1. White | 4. College Grad | 2. Middle Atlantic | 1. Industrial | 2. >=Very Good | 1. Yes | 4.903090 | 134.70538 |
| **449654** | 2009 | 54 | 2. Married | 1. White | 2. HS Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 1. Yes | 4.903090 | 134.70538 |
| **447660** | 2009 | 51 | 2. Married | 1. White | 3. Some College | 2. Middle Atlantic | 1. Industrial | 2. >=Very Good | 1. Yes | 4.505150 | 90.48191 |
| **160191** | 2003 | 37 | 1. Never Married | 3. Asian | 4. College Grad | 2. Middle Atlantic | 1. Industrial | 2. >=Very Good | 2. No | 4.414973 | 82.67964 |
| **230312** | 2006 | 50 | 2. Married | 1. White | 5. Advanced Degree | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 2. No | 5.360552 | 212.84235 |
| **301585** | 2007 | 56 | 2. Married | 1. White | 4. College Grad | 2. Middle Atlantic | 1. Industrial | 1. <=Good | 1. Yes | 4.861026 | 129.15669 |
| **153682** | 2003 | 37 | 1. Never Married | 1. White | 3. Some College | 2. Middle Atlantic | 1. Industrial | 2. >=Very Good | 1. Yes | 4.591065 | 98.59934 |
| **158226** | 2003 | 38 | 2. Married | 3. Asian | 4. College Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 2. No | 5.301030 | 200.54326 |
| **11141** | 2005 | 40 | 4. Divorced | 1. White | 2. HS Grad | 2. Middle Atlantic | 2. Information | 2. >=Very Good | 2. No | 3.920123 | 50.40666 |

<!-- page 25 -->

# Let’s look again at Wage in ISLR2 - 2

<!-- page 26 -->

# Model 1 – Wage and jobclass

- Can write this model as:

```r
mod_job <- lm(wage ~ jobclass, Wage)
```

```r
> summary(mod_job)

Call:
lm(formula = wage ~ jobclass, data = Wage)

Residuals:
     Min       1Q   Median       3Q      Max 
-100.507  -25.362   -6.117   15.697  197.750 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             103.321      1.039   99.43   <2e-16 ***
jobclass2. Information   17.272      1.492   11.58   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

What do you notice?

<!-- page 27 -->

# Model 1 – Wage and jobclass

* Can write this model as:

```r
mod_job <- lm(wage ~ jobclass, Wage)
```

```r
> summary(mod_job)

Call:
lm(formula = wage ~ jobclass, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.507 -25.362  -6.117  15.697 197.750 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             103.321      1.039   99.43   <2e-16 ***
jobclass2. Information   17.272      1.492   11.58   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

How would you interpret the coefficients?

<!-- page 28 -->

# Model 1 – Wage and jobclass

* Can write this model as:

```r
mod_job <- lm(wage ~ jobclass, Wage)
```

```r
> summary(mod_job)

Call:
lm(formula = wage ~ jobclass, data = Wage)

Residuals:
     Min       1Q   Median       3Q      Max 
-100.507  -25.362   -6.117   15.697  197.750 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             103.321      1.039   99.43   <2e-16 ***
jobclass2. Information   17.272      1.492   11.58   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

Mean expected raw wage for workers whose `jobclass = 1. Industrial`

<!-- page 29 -->

# Model 1 – Wage and jobclass

* Can write this model as:

```r
mod_job <- lm(wage ~ jobclass, Wage)
```

```r
> summary(mod_job)

Call:
lm(formula = wage ~ jobclass, data = Wage)

Residuals:
    Min      1Q  Median      3Q      Ma
-100.507 -25.362  -6.117  15.697 197.750

Coefficients:
                      Estimate Std. Error t value Pr(>|t|)    
(Intercept)            103.321      1.039   99.43   <2e-16 ***
jobclass2. Information  17.272      1.492   11.58   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

Difference in mean expected raw wage for workers with Information jobclass vs. industrial jobclass.

<!-- page 30 -->

# Model 1 – Wage and jobclass

- Can write this model as:

```r
mod_job <- lm(wage ~ jobclass, Wage)
```

```r
> summary(mod_job)

Call:
lm(formula = wage ~ jobclass, data = Wage)

Residuals:
     Min       1Q   Median       3Q      Max 
-100.507  -25.362   -6.117   15.697  197.750 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             103.321      1.039   99.43   <2e-16 ***
jobclass2. Information   17.272      1.492   11.58   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

How would we get the mean expected raw wage for information workers?

<!-- page 31 -->

# Model 1 – Wage and jobclass

- Can write this model as:

```r
mod_job <- lm(wage ~ jobclass, Wage)
```

```r
> summary(mod_job)

Call:
lm(formula = wage ~ jobclass, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Ma
-100.507 -25.362  -6.117  15.697 197.75

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             103.321      1.039   99.43   <2e-16 ***
jobclass2. Information   17.272      1.492   11.58   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

How would we get the mean expected raw wage for information workers?

$$\beta_0 + \beta_1 = 103.32 + 17.27 = 120.59$$

<!-- page 32 -->

# Model 1 – Wage and jobclass

- Can write this model as:

```r
mod_job <- lm(wage ~ jobclass, Wage)
```

```r
> summary(mod_job)

Call:
lm(formula = wage ~ jobclass, data = Wage)

Residuals:
     Min       1Q   Median       3Q      Max 
-100.507  -25.362   -6.117   15.697  197.750 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             103.321      1.039   99.43   <2e-16 ***
jobclass2. Information   17.272      1.492   11.58   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.83 on 2998 degrees of freedom
Multiple R-squared:  0.04281,	Adjusted R-squared:  0.04249 
F-statistic: 134.1 on 1 and 2998 DF,  p-value: < 2.2e-16
```

What does this look like graphically?

<!-- page 33 -->

# Model 1 – Wage and jobclass

$\beta_0 + \beta_1$: Mean Wage for those in information jobs

$\beta_0$: Mean Wage for those in industrial jobs

<!-- page 34 -->

# Model with categorical and continuous predictors

<!-- page 35 -->

# Model 2 – Wage, jobclass, and age

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + age, Wage)
```

```r
> summary(mod_jobage)

Call:
lm(formula = wage ~ jobclass + age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-107.234 -24.751  -6.311  16.308 197.278 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             76.6298     2.8320   27.06   <2e-16 ***
jobclass2. Information  15.9214     1.4732   10.81   <2e-16 ***
age                      0.6447     0.0638   10.11   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.16 on 2997 degrees of freedom
Multiple R-squared:  0.07435,	Adjusted R-squared:  0.07373 
F-statistic: 120.4 on 2 and 2997 DF,  p-value: < 2.2e-16
```

<!-- page 36 -->

# Model 2 – Wage, jobclass, and age

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + age, Wage)
```

```r
> summary(mod_jobage)

Call:
lm(formula = wage ~ jobclass + age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-107.234 -24.751  -6.311  16.308 197.278 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             76.6298     2.8320   27.06   <2e-16 ***
jobclass2. Information  15.9214     1.4732   10.81   <2e-16 ***
age                      0.6447     0.0638   10.11   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.16 on 2997 degrees of freedom
Multiple R-squared:  0.07435,	Adjusted R-squared:  0.07373 
F-statistic: 120.4 on 2 and 2997 DF,  p-value: < 2.2e-16
```

How would you interpret the coefficients?

<!-- page 37 -->

# Model 2 – Wage, jobclass, and age

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + age, Wage)
```

```r
> summary(mod_jobage)

Call:
lm(formula = wage ~ jobclass + age, data = Wa

Residuals:
    Min      1Q  Median      3Q     Max 
-107.234 -24.751  -6.311  16.308 197.278 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             76.6298     2.8320   27.06   <2e-16 ***
jobclass2. Information  15.9214     1.4732   10.81   <2e-16 ***
age                      0.6447     0.0638   10.11   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.16 on 2997 degrees of freedom
Multiple R-squared:  0.07435,	Adjusted R-squared:  0.07373 
F-statistic: 120.4 on 2 and 2997 DF,  p-value: < 2.2e-16
```

Mean expected raw wage for workers aged 0 and industrial jobclass.

<!-- page 38 -->

# Model 2 – Wage, jobclass, and age

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + age, Wage)
```

```r
> summary(mod_jobage)

Call:
lm(formula = wage ~ jobclass + age, data = Wa

Residuals:
    Min      1Q  Median      3Q     Max 
-107.234 -24.751  -6.311  16.308 197.278 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             76.6298     2.8320   27.06   <2e-16 ***
jobclass2. Information  15.9214     1.4732   10.81   <2e-16 ***
age                      0.6447     0.0638   10.11   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.16 on 2997 degrees of freedom
Multiple R-squared:  0.07435,	Adjusted R-squared:  0.07373 
F-statistic: 120.4 on 2 and 2997 DF,  p-value: < 2.2e-16
```

Difference in mean expected raw wage for Information workers vs industrial workers while holding age constant.

<!-- page 39 -->

# Model 2 – Wage, jobclass, and age

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + age, Wage)
```

```r
> summary(mod_jobage)

Call:
lm(formula = wage ~ jobclass + age, data = Wa

Residuals:
     Min       1Q   Median       3Q      Max
-107.234  -24.751   -6.311   16.308  197.278

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)
(Intercept)             76.6298     2.8320   27.06   <2e-16 ***
jobclass2. Information  15.9214     1.4732   10.81   <2e-16 ***
age                      0.6447     0.0638   10.11   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.16 on 2997 degrees of freedom
Multiple R-squared:  0.07435,	Adjusted R-squared:  0.07373
F-statistic: 120.4 on 2 and 2997 DF,  p-value: < 2.2e-16
```

One unit increase in age is associated with 0.65 increase in expected mean wage while keeping jobclass constant.

<!-- page 40 -->

# Model 2 – Wage, jobclass, and age

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + age, Wage)
```

```r
> summary(mod_jobage)

Call:
lm(formula = wage ~ jobclass + age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-107.234 -24.751  -6.311  16.308 197.278 

Coefficients:
                      Estimate Std. Error t value Pr(>|t|)    
(Intercept)            76.6298     2.8320   27.06   <2e-16 ***
jobclass2. Information 15.9214     1.4732   10.81   <2e-16 ***
age                     0.6447     0.0638   10.11   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.16 on 2997 degrees of freedom
Multiple R-squared:  0.07435,	Adjusted R-squared:  0.07373 
F-statistic: 120.4 on 2 and 2997 DF,  p-value: < 2.2e-16
```

What does this look like graphically?

<!-- page 41 -->

# Model 2 – Wage, jobclass, and age

Mean Wage for those in information jobs by age

Mean Wage for those in industrial jobs by age

<!-- page 42 -->

# Multiple categorical predictors

<!-- page 43 -->

# Model 2 – Wage, jobclass, and health_ins

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + health_ins, Wage)
```

```r
Call:
lm(formula = wage ~ jobclass + health_ins, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-94.263 -24.797  -6.858  15.915 208.798 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             112.891      1.154  97.802   <2e-16 ***
jobclass2. Information   13.738      1.445   9.504   <2e-16 ***
health_ins2. No         -25.698      1.568 -16.389   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 39.12 on 2997 degrees of freedom
Multiple R-squared:  0.1215,	Adjusted R-squared:  0.1209 
F-statistic: 207.3 on 2 and 2997 DF,  p-value: < 2.2e-16
```

How would you interpret the coefficients?

<!-- page 44 -->

# Model 2 – Wage, jobclass, and health_ins

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + health_ins, Wage)
```

```r
Call:
lm(formula = wage ~ jobclass + health_ins,

Residuals:
    Min      1Q  Median      3Q     Max 
-94.263 -24.797  -6.858  15.915 208.798 

Coefficients:
                       Estimate Std. Error
(Intercept)             112.891      1.154  97.802  <2e-16 ***
jobclass2. Information   13.738      1.445   9.504  <2e-16 ***
health_ins2. No         -25.698      1.568 -16.389  <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 39.12 on 2997 degrees of freedom
Multiple R-squared:  0.1215,	Adjusted R-squared:  0.1209 
F-statistic: 207.3 on 2 and 2997 DF,  p-value: < 2.2e-16
```

Expected mean raw wage for industrial workers with health insurance (i.e., when both predictors equal their reference group)

<!-- page 45 -->

# Model 2 – Wage, jobclass, and health_ins

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + health_ins, Wage)
```

```r
Call:
lm(formula = wage ~ jobclass + health_ins,

Residuals:
    Min      1Q  Median      3Q     Max 
-94.263 -24.797  -6.858  15.915 208.798 

Coefficients:
                      Estimate Std. Error t value Pr(>|t|)    
(Intercept)            112.891      1.154  97.802   <2e-16 ***
jobclass2. Information  13.738      1.445   9.504   <2e-16 ***
health_ins2. No        -25.698      1.568 -16.389   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 39.12 on 2997 degrees of freedom
Multiple R-squared:  0.1215,	Adjusted R-squared:  0.1209 
F-statistic: 207.3 on 2 and 2997 DF,  p-value: < 2.2e-16
```

Difference in expected mean raw wage for information vs. industrial workers while holding health_ins constant.

<!-- page 46 -->

# Model 2 – Wage, jobclass, and health\_ins

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + health_ins, Wage)
```

```r
Call:
lm(formula = wage ~ jobclass + health_ins,

Residuals:
    Min      1Q  Median      3Q     Max
-94.263 -24.797  -6.858  15.915 208.798

Coefficients:
                       Estimate Std Error
(Intercept)             112.891     1.154  97.802  <2e-16 ***
jobclass2. Information   13.738     1.445   9.504  <2e-16 ***
health_ins2. No         -25.698     1.568 -16.389  <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 39.12 on 2997 degrees of freedom
Multiple R-squared:  0.1215,	Adjusted R-squared:  0.1209
F-statistic: 207.3 on 2 and 2997 DF,  p-value: < 2.2e-16
```

Difference in expected mean raw wage for those with no health insurance vs. those with health insurance while holding jobclass constant.

<!-- page 47 -->

# Model 2 – Wage, jobclass, and health_ins

* Can write this model as:

```r
mod_jobage <- lm(wage ~ jobclass + health_ins, Wage)
```

```r
Call:
lm(formula = wage ~ jobclass + health_ins, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-94.263 -24.797  -6.858  15.915 208.798 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)             112.891      1.154  97.802   <2e-16 ***
jobclass2. Information   13.738      1.445   9.504   <2e-16 ***
health_ins2. No         -25.698      1.568 -16.389   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 39.12 on 2997 degrees of freedom
Multiple R-squared:  0.1215,	Adjusted R-squared:  0.1209 
F-statistic: 207.3 on 2 and 2997 DF,  p-value: < 2.2e-16
```

$\beta_0$

$\beta_1$

$\beta_2$

What does this look like graphically?

<!-- page 48 -->

# Model 2 – Wage, jobclass, and health_ins

* **Information w/health insurance**: $\beta_0 + \beta_1$
* 120
* **Industrial w/health insurance**: $\beta_0$
* 110
* **Wage**
* **Information no health insurance**: $\beta_0 + \beta_1 + \beta_2$
* 100
* 90
* **Industrial no health insurance**: $\beta_0 + \beta_2$

<!-- page 49 -->

# Model 2 – Wage, jobclass, and health_ins

* **Information w/health insurance**: $112.9 + 13.7 = \underline{\mathbf{126.6}}$
* **Industrial w/health insurance**: $\underline{\mathbf{112.9}}$
* **Information no health insurance**: $112.9 + 13.7 - 25.7 = \underline{\mathbf{100.9}}$
* **Industrial no health insurance**: $112.9 - 25.7 = \underline{\mathbf{87.2}}$

**Wage** (y-axis labels):
* 120
* 110
* 100
* 90

<!-- page 50 -->

# Predictors with More than 2 Categories

<!-- page 51 -->

# Categorical Predictors (> 2 Categories)

For a categorical predictor with $f$ levels, consider $f$-1 dummy variables, $d_{2i}, \dots, d_{fi}$ as

* $d_{ji} = \begin{cases} \text{if } i^{th}\text{ unit is in level } j \\ \text{if } i^{th}\text{ unit is not in level } j \end{cases}$
* Level one is the reference level (i.e., other levels are compared to it)
* $y_i = \gamma_0 + \gamma_2 d_{2i} + \dots + \gamma_f d_{fi} + \epsilon_i$
* What do $\gamma_0, \gamma_2$, etc. mean?

<!-- page 52 -->

# Model 3 – Wage, marital status, and age

* Can write this model as:

```r
mod_maritlage <- lm(wage ~ maritl + age, Wage)
```

```r
> summary(mod_maritlage)

Call:
lm(formula = wage ~ maritl + age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.97  -24.41   -5.56   15.65  219.25 

Coefficients:
                  Estimate Std. Error t value Pr(>|t|)    
(Intercept)       78.65466    2.79883  28.103  < 2e-16 ***
maritl2. Married  20.81989    2.00197  10.400  < 2e-16 ***
maritl3. Widowed  -1.06328    9.40852  -0.113    0.910    
maritl4. Divorced  3.93218    3.38700   1.161    0.246    
maritl5. Separated 3.62631    5.67963   0.638    0.523    
age                0.43212    0.07105   6.082 1.34e-09 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.04 on 2994 degrees of freedom
Multiple R-squared:  0.0809,	Adjusted R-squared:  0.07936 
F-statistic:  52.7 on 5 and 2994 DF,  p-value: < 2.2e-16
```

<!-- page 53 -->

# Model 3 – Wage, marital status, and age

* Can write this model as:

```r
mod_maritlage <- lm(wage ~ maritl + age, Wage)
```

```r
> summary(mod_maritlage)

Call:
lm(formula = wage ~ maritl + age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.97  -24.41   -5.56   15.65  219.25 

Coefficients:
                  Estimate Std. Error t value Pr(>|t|)    
(Intercept)       78.65466    2.79883  28.103  < 2e-16 ***
maritl2. Married  20.81989    2.00197  10.400  < 2e-16 ***
maritl3. Widowed  -1.06328    9.40852  -0.113    0.910    
maritl4. Divorced  3.93218    3.38700   1.161    0.246    
maritl5. Separated 3.62631    5.67963   0.638    0.523    
age                0.43212    0.07105   6.082 1.34e-09 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.04 on 2994 degrees of freedom
Multiple R-squared:  0.0809,	Adjusted R-squared:  0.07936 
F-statistic: 52.7 on 5 and 2994 DF,  p-value: < 2.2e-16
```

How would you interpret the coefficients?

<!-- page 54 -->

# Model 3 – Wage, marital status, and age

* Can write this model as:

```r
mod_maritlage <- lm(wage ~ maritl + age, Wage)
```

```r
> summary(mod_maritlage)

Call:
lm(formula = wage ~ maritl + age, data = Wage)

Residuals:
    Min      1Q  Median      3Q     Max 
-100.97  -24.41   -5.56   15.65  219.25 

Coefficients:
                  Estimate Std. Error t value Pr(>|t|)    
(Intercept)       78.65466    2.79883  28.103  < 2e-16 ***
maritl2. Married  20.81989    2.00197  10.400  < 2e-16 ***
maritl3. Widowed  -1.06328    9.40852  -0.113    0.910    
maritl4. Divorced  3.93218    3.38700   1.161    0.246    
maritl5. Separated 3.62631    5.67963   0.638    0.523    
age                0.43212    0.07105   6.082 1.34e-09 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 40.04 on 2994 degrees of freedom
Multiple R-squared:  0.0809,	Adjusted R-squared:  0.07936 
F-statistic:  52.7 on 5 and 2994 DF,  p-value: < 2.2e-16
```

How would you interpret the coefficients?

What does this look like graphically?

<!-- page 55 -->

# Model 3 – Wage, marital status, and age

Mean Wage for married participants by age

Mean Wage for those never married participants by age

<!-- page 56 -->

# Model 3 – Wage, marital status, and age

Mean Wage for those never married participants by age

Mean Wage for widowed participants by age

<!-- page 57 -->

# Model 3 – Wage, marital status, and age

Mean Wage for divorced participants by age

Mean Wage for those never married participants by age

<!-- page 58 -->

# Models with categorical predictors

Notice anything about the regression lines from the models we've fit so far?

<!-- page 59 -->

# Models with categorical predictors

The intercept shifts (up or down) by the value of the coefficient ($\beta$ or $\gamma$), but the slope stays constant.

<!-- page 60 -->

# Models with categorical predictors

What if we don’t want the slope to be constant across levels of the variable?

The intercept shifts up by the value of the coefficient $(\beta \text{ or } \gamma)$, but the slope stays constant.

<!-- page 61 -->

# Interactions of Predictor Variables

<!-- page 62 -->

# Interactions of predictor variables

* Say we want to model `wage` as a function of `year` and `jobclass`, but don't want to assume that the slopes are the same?
* Can write this model as:

```r
mod_jobyrvar <- lm(wage ~ year*jobclass, Wage)
```

<!-- page 63 -->

# Interactions of predictor variables

* Say we want to model `wage` as a function of `year` and `jobclass`, but don't want to assume that the slopes are the same?
* Can write this model as:

```r
mod_jobyrvar <- lm(wage ~ year*jobclass, Wage)
```

Why did we include year as “as.factor(year)” in the plots, but not the model?

<!-- page 64 -->

# Interactions of predictor variables

* R often makes assumptions about variables in your datasets which may or may not be accurate.
* Can check how R is classifying your variable by running
  `class(Wage$year)`

```r
> class(Wage$year)
[1] "integer"
>
```

We will see in lab how changing the class of a variable can impact your model.

<!-- page 65 -->

# What is an interaction? - 1
