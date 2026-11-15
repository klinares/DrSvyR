---
id: "jpsm/stat_mod_ML_1_SURV615/assignments/HW8"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "assignment"
title: "Homework 8"
original: "stat_mod_ML_1_SURV615/assignments/HW8.qmd"
pages: 
sha256: "4b489911bc2c36aeda71b9b9d7f4140cd95bf5e7d62afb3467b4e76bc932845d"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:20"
---


------------------------------------------------------------------------

```r
library(jtools)
library(faraway)
library(olsrr)
library(knitr)
library(gridExtra)
library(car)
library(performance)
library(sandwich)
library(corrplot)
library(tidyverse)

options(scipen=999)

#________________ handy functions __________________
kappa_fun <- function(mod_name){
  # model matrix w/o intercept
  x_mod = model.matrix(mod_name)[,-1] 
  #  matrix multiplication
  e=eigen(t(x_mod)%*%x_mod) 
  print("Inspect wide range in eigenvalues")
  print(e$val) 
  
  # calculate kappa values
  print("Inspect if Kappa conditional number value > 30")
  kappa_mod = sqrt(max(e$val)/min(e$val))
  print(kappa_mod)
  print("Inspect condition index, of at least one linear combination")
  nu = sqrt(max(e$val)/e$val)
  print(nu) }
```

## 1. Faraway Chapter 7. Exercise 5.

-   For the prostate data, fit a model with lpsa as the response and the other variables as predictors.

```r
data("prostate") 

summ(mod <- lm(lpsa ~ lcavol + lweight + age + 
              lbph + svi + lcp + gleason + pgg45, prostate))
```


{{< pagebreak >}}

## 1.A. Compute and comment on Kappa and the condition numbers.

-   We compute the conditional number kappa, which measures the relative sizes of the eigenvalues where $\kappa > 30$ is considered large. Our kappa value of 243 is 8 times larger than 30, but can only tell us that at least one of the eigenvalue is small relative to the rest. Therefore, we examine other conditional indices $\eta_j$ because they indicate whether more than just one independent linear combination is to blame. We see that 6 of 8 conditional indices are above 30, suggesting several independent linear combinations are present in this model.

```r
# pass the model object to this function
kappa_fun(mod)
```

\

## 1.B. Compute and comment on the correlations between the predictors. Round to 3 decimal places.

-   In the correlation matrix contour plot below we take note on the strong positive association between gleason and pgg45 (r=.75), lcp lcavol (r=.68), svi and lcp (r=.67), and pgg45 and lcp (r=.63). The top correlated predictors also seem to have higher VIFs shown in 1.c.

```r
#| fig.height = 7.5, fig.width = 7

testRes = cor.mtest(prostate |> select(-lpsa), 
                    conf.level = 0.95)

corrplot(cor(prostate |> select(-lpsa)), 
         p.mat = testRes$p, method = 'circle', 
         type = 'lower', insig='blank',
         order = 'AOE', diag = FALSE,
         number.cex=0.05)$corrPos -> p1
text(p1$x, p1$y, round(p1$corr, 3))
```

\

## 1.C. Compute the variance inflation factors. Comment on whether any appear problematic and why.

-   The variance inflation factor (VIF) assesses multicollinearity, which is the ratio of the variance of $\hat{\beta}_j$: when fitting the full model divided by the variance of $\hat{\beta}_j$ if fit on its own. The smallest possible value is 1 indicating absence of collinearity. A rule of thumb of a VIF of over 5 is an indication of a problematic amount of collinearity. VIF is expressed as:

$$
VIF_j = \frac{1}{1=R^2_j} 
$$

-   VIF ranged between 1.3 and 3.1. Of note, lcavol, lcp, gleason, and pgg45 have VIF\>2, yet all VIF values are less than 5 so there does not appear to be any issues of collinearity.

```r
ols_vif_tol(mod) |> select(Variables, VIF) |> arrange(desc(VIF))
```

{{< pagebreak >}}

## 2. Faraway Chapter 8. Exercise 4.


-   For the cars dataset, fit a linear model with distance as the response and speed as the predictor.

```r
data("cars")
?cars
glimpse(cars)
summ(mod_cars <- lm(dist ~ speed, cars))
```

{{< pagebreak >}}

## 2.A. Test the homoscedasticity assumption using both a scatter plot between the residuals and fitted values and an F-test of equal variance below and above the fitted value of 30. What do you conclude about whether the assumption is met?

-   There is a discernible pattern funnel-shape observed on the plot - more tightly clustered around the left half and more dispersed and spread apart on the right half of the plot. It is suggestive of non-constant variance or heteroscedasticity thus violating the constant variance assumption. The density and homogeneity of variance plots also show evidence of non-constant variance We can also see that lower fitted values have residuals higher than 0, while some mid point values are below 0. Therefore, we are seeing evidence for heteroscadasticity.

```r
 residualPlot(mod_cars, pch=20, col= "dodgerblue")

grid.arrange(
  # check for homogeneity: ref line is not flat
  plot(check_heteroskedasticity(mod_cars)), 
  # check for normallity of residuals,
  plot(check_normality(mod_cars), type="density")
)
```


-   We examine statistically equal variances for fitted values greater than 30 and values less than or equal to 30. The F-test for equal variances suggest suggests rejecting the null $(95\%[1.53, 9.42])$ that the true ratio of variances of the two groups (\>30 and \<=30) are equal in favor of the alternative hypothesis. This further supports the observed violation of the constant error variance assumption on the residuals vs. fitted plot and homogeneity of variance plot, thus we conclude that we have evidence for non-constant variance both graphically and statistically. Residual variance for full model = `r var(residuals(mod_cars))`, fitted values \>30 = `r var (resid(mod_cars)[fitted(mod_cars)>30])` fitted values \<=30 = `r var (resid(mod_cars)[fitted(mod_cars)<=30])`

```r
var.test(resid(mod_cars)[fitted(mod_cars)>30], 
         resid(mod_cars)[fitted(mod_cars)<=30])
```

{{< pagebreak >}}

## 2.B. Report the estimate of the heteroscedastic consistent variance for the regression slope.

-   The heteroscedastic consistent variance for the slope is .18.

```r
hetvar <- mod_cars |> 
  # calculate Heteroscedasticity-consistent estimation 
  ## of the covariance matrix for coefficients
  vcovHC()  |>  
  # gives variances as they are the diagonal 
  ## of the covariance matrix
  diag() 

hetvar
```

\

## 2.C. Construct 95% confidence interval of the regression slope assuming homoscedasticity and using the results in 2.B. How do they compare?

-   95% Confidence interval 1: assuming homoscedasticity \[`r confint(mod_cars)[2,1] |> as.vector() |> round(4)`, `r confint(mod_cars)[2,2] |> as.vector() |> round(4)`\]

```r
coef(mod_cars)[2]
```

```r
confint(mod_cars)[2,] 

hetvar_cars <- hetvar |> 
  # variances are the diagonal of the covariance matrix
  sqrt()

hetero_ci <- mod_cars$coefficients[2] + c(-1,1) * 
  qt(0.975,mod_cars$df.residual)*sqrt(hetvar_cars[2])

```

-   95% confidence interval 2: heteroscedasticity \[`r round(hetero_ci[1], 4)`, `r round(hetero_ci[2], 4)`\]

-   CI heteroscedasticity is much wider and less precise than CI assuming homoscedasticity. This is because CI 2 is estimated using biased and inflated standard error reducing its precision.


## 2.D. Check for the lack of fit of the model.

-   We use the function we created at the beginning of this rmarkdown and pass it two models, the original model and one where we convert the continuous variable into a factor.

```r
plot(cars$speed,cars$dist,pch=18,col="blue",cex=.7) +
  abline(lm(dist~speed, cars),col="red")

summ(mod_cars_a<-lm(resid(mod_cars) ~ factor(speed), cars))
```

\

-   The lack of fit F-test for the model’s p-value of 0.29 is > .05. We fail to reject the null which is suggestive that the model does not fit the data well thus is not the best representation of the data.

```r
## use the olsrr package to conduct a lack of fit test
ols_pure_error_anova(mod_cars)
```
