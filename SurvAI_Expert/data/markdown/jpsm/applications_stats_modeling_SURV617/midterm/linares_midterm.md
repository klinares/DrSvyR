---
id: "jpsm/applications_stats_modeling_SURV617/midterm/linares_midterm"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "assignment"
title: "SURV617, Midterm"
original: "applications_stats_modeling_SURV617/midterm/linares_midterm.qmd"
pages: 
sha256: "d1cb887a40e24c4463e21f5dbf85716b22467bf229efcf5002cb08ba664de88e"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:43"
---


## 

```r

pacman::p_load(jtools, gt, viridis, ggResidpanel, LearnVizLMM, patchwork,
                ggResidpanel, lme4, lmerTest, ggthemes, tidyverse)

options(digits=4, scipen=999)
theme_set(theme_minimal(base_size = 12))

# read in data

repo_path <- 
  "D:/repos/UMD_classes_code/applications_stats_modeling_SURV617/midterm"

load(str_c(repo_path, "/sust_eff.rdata"))


```

### True / False (Circle either TRUE or FALSE for each question). Provide written justification only if you feel that it is necessary.

1.  TRUE / FALSE: In a multilevel model, level 1 is always the level at which the outcome is measured. \[2 points\].
    1.  TRUE
2.  TRUE / FALSE: You are fitting a multilevel model to a longitudinal dataset where participants are surveyed multiple times over the course of the study. In this case the individual participants would define level 1 of your model. \[2 points\]
    1.  FALSE: The individual has repeated measures, and the repeated measures are on level 1, the individual covaraite on level 2.
3.  TRUE / FALSE: You are fitting a multilevel model to study the trajectories of revenue over time for all four divisions of a large company. You should include a random effect for division. \[2 points\]
    1.  FALSE
4.  TRUE / FALSE: In multilevel models for normal outcomes, the use of REML for estimation will produce biased estimates of the variance components in the specified model. \[2 points\]
    1.  FALSE: provides unbiased estimates of variance components.
5.  TRUE / FALSE: The following model contains 5 parameters.
    1.  FALSE: 6 parameters
6.  TRUE / FALSE: Random effects in multilevel models are not parameters. \[2 points\]
    1.  TRUE, they are random variables.
7.  TRUE / FALSE: You fit a multilevel model and obtain an AIC value of 7173.6. This allows you to conclude that the model fits the data well. \[2 points\]
    1.  FALSE
8.  TRUE / FALSE: The “missing at random” assumption means that we are assuming the missingness of a variable is random after conditioning on observed covariates. 1. TRUE
9.  TRUE / FALSE: A poor choice of the working correlation matrix in a marginal model fit using GEE will negatively impact your beta estimates, but not standard errors. \[2 points\]
    1.  FALSE
10. TRUE / FALSE: When fitting a GEE model to longitudinal data where you believe that the correlations of observations on the dependent variable within a subject will decrease over time
    1.  FALSE

### Multiple Choice Problems (Circle the best option for each question)

11. Circle the option that best represents the method(s) you can use to compare the fits of the following two models.
    11. e\. AIC and BIC because these are not nested models.
12. What is the appropriate approach for testing the null hypothesis that the covariance of two random effects in a multilevel model is equal to zero?
    11. d\. Fit two models with and without the covariance using REML, and use a standard likelihood ratio test.

### Data Analysis

-   The data will include the following variables.

| Variable   | Coding                                        |
|------------|-----------------------------------------------|
| schoolid   | school id                                     |
| math       | continous measure                             |
| Female     | 1= female, 0=male                             |
| minority   | 1=minority, 0=otherwise                       |
| grade      | students grade                                |
| lowinc_cen | centered % of low income students in a school |

```r
# examine the data
glimpse(sust_eff)
```

13. Fit a multilevel model with math as the dependent variable, a fixed intercept, fixed effects for female, grade, lowinc_cen, and minority, along with a random intercept for schoolid. You can assume that the residual errors are independent and normally distributed with constant variance. Show your code and the output; you do not need to prepare a custom table. What is the plain English interpretation of the five estimated fixed effects?

```r
mod_1 <- lmer(math ~ female + grade + lowinc_cen + minority + 
                   (1|schoolid),
                 data = sust_eff, REML = TRUE)

summ(mod_1)
```

-   Intercept: is the estimated average math score for all schools of -1.69 for males in grade zero of non-minority status from average low-income schools (since this variable is centered).

    -   for minority male of grade 0 from average low-income schools, therir expected average math score is -2.09.

-   Female: Females had an expected average math score of -1.66, an average change of .03 compared to males while holding all other predictors constant, yet this difference was not statistically significantly different.

-   Grade: For every 1 grade increase, the expected math score increases by .80 while holding all other predictors constant. This was statistically significant.

-   lowinc_cen: For schools with average low income student percent, their expected math score is -1.68, meaning that for every percent increase in low income student body the we would expect math scores to decrease by .01 scores, while holding all other predictors constant. This was statistically significant.

-   Minority: The expected difference in math scores between non-minority and minority students is -.40 while holding all other predictors constant, and it was statistically significant.

14. Refit the model from Q13, this time including a random coefficient for each school for the minority predictor. Test the null hypothesis that the variance of the random coefficients is equal to zero. What decision do you make about this null hypothesis? Show your code and your output.

```r
mod_2 <- lmer(math ~ female + grade + lowinc_cen + minority + 
                   (minority|schoolid),
                 data = sust_eff, REML = TRUE)

summ(mod_2)
```

-   We fit a reduced model (with seven parameters) without the random slope on minority and test whether $H_0: \tau_{11}=0$, so that there is no school variation in math scores. The alternative hypothesis, $H_A=\tau_{11} > 0$ since variance should be larger than 0. To test this hypothesis we use the likelihood ratio test (LRT) simply by $-2[\text{log likelihood}_{reduced} - \text{log likelihood}_{full}]$ to examine the difference. We use a mixture of $\chi^2$ 1 and 2 distributions to compare the full model with two random effects against a reduced model with one random effect.

-   Below we use a helper function to print the p-value for the LRT difference, and find a p-value $<.00001$ and we reject the Null, (with $.5 \times \chi^2(1) + .5 \times \chi^2$ (2 mixture) and conclude that there is strong evidence for school variation in math scores es and therefore we should keep this random slope of minority status in the model.

```r


#________________ helpful function for loglikelihood _____________________
# function to save out loglikelihood from model
log_like_pluck_fun <- function(mod_fit) {
  mod_fit |> summary() |> pluck("logLik") |> as.numeric()
}
# function for how many random effects
random_effects_num_fun <- function(mod_fit){
  mod_fit |> ranef() |> as_tibble() |> distinct(term) |> nrow()
}
# Function to calculate LRT p-values for variances of random effects
# Implements a likelihood ratio test comparing 2 nested mixed-effects models
# (full_model = w/ random effect, restricted_model = w/o RE)
calculate_lrt_pvalue_fun <- function(full_model, reduced_model) {
  # restricted_model (fewer parameters)
  # full_model (more parameters)
  # Extract log-likelihoods from both models
  # Calculate LRT statistic
  lrt_statistic <- -2 * (log_like_pluck_fun(reduced_model) -
                           log_like_pluck_fun(full_model))
  # Calculate p-value using mixture of chi-square distributions
  # 50:50 mixture for boundary testing of variance components
  mixed_p_value <- 0.5 * pchisq(lrt_statistic,
                                df = random_effects_num_fun(reduced_model),
                                lower.tail = FALSE) +
    0.5 * pchisq(lrt_statistic,
                 df = random_effects_num_fun(full_model),
                 lower.tail = FALSE)
  return(str_c("LRT p-values for variances of random effects = ",
               mixed_p_value)
  )
}
#______________________________________________________________________
calculate_lrt_pvalue_fun(mod_2, mod_1)
```

15. Refit the best model from Q13 or Q14 (based on your answer to Q14), but this time remove the fixed effect of female from the model. Which model has the better fit, and why? Show your code and output. For the model you believe is the better fit, examine some simple model diagnostics for the random effects and residuals and discuss whether the model assumptions seem justified. Provide your code and plots to support your conclusion.

```r
mod_3 <- lmer(math ~  grade + lowinc_cen + minority + 
                   (minority|schoolid),
                 data = sust_eff, REML = TRUE)

summ(mod_3)

```

-   We examine both models: model with and without gender. Here we have a nested model which we will compare in different phases. First, we examine model diagnostic for both starting with the zero mean error assumption.

```r
summary(resid(mod_2))
summary(resid(mod_3))
```

-   For the model with the fixed effect of female (top plots) we plot the residuals and QQ-plot, and the below plots correspond to the model removing female. Both models show that the residual means are centered at 0. In the residual plots we do tend to see that as predicted values increase, the spread of residual values decrease. The qqplots shows few schools are are outside of what we expect in both models, particularly on the higher end, but overall it the residuals appear to be normally distributed.

```r
resid_panel(mod_2, plots = c("resid", "qq"), qqbands = TRUE) /
  resid_panel(mod_3, plots = c("resid", "qq"), qqbands = TRUE)
```

-   The ICC for the model with female is .17, and without this fixed effect it stays at .17. This suggest that both models with or without the fixed effect of female, the school clustering explains 17% of the variance in math scores.

-   Next, we compare fit which we print below in the ANOVA table, the Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC) for both models. The model with gender has a slightly larger AIC and BIC, but this is very minimal. We next conduct a likelihood ratio test (LRT), which here we can use the anova function since these models are nested, $\chi^2$ (1) = 1.88, p > = .05. Both models seem to be equivalent and have near identical fits, if we are to choose a model we would choose the one without female because it is the most parsimonious without hurting model fit.

```r
anova(mod_3, mod_2) |> gt()
```

16. Refit the model you selected from Q15, and this time assess whether the percentage of low- income students in a school (lowinc_cen) explains the variance in the minority coefficients across schools by including the fixed effect of the interaction between lowinc_cen and minority. Is the interaction term significant? Regardless of whether the interaction is significant, interpret the interaction in plain English.

```r
mod_4 <- lmer(math ~  grade + lowinc_cen*minority + 
                   (minority|schoolid),
                 data = sust_eff, REML = TRUE)

summ(mod_4)
```

-   The cross-level interaction term of the average low income student percentage for schools interacted with minority status reveals a non-significant coefficient of 0. The minority coefficient of =.40, the main effect, in average percent of low income students the estimated average math score for a minority student is .40 points lower than a non-minority students. The coefficient for the interaction term was 0, meaning that for every one percentage increase in a school's low income student body, the math score gap between minority and non-minority students is estimated to change by 0 points.

### Model Specification

17. When fitting a multilevel model, what components shape the V matrix in the implied marginal model? How does this differ from the V matrix in a marginal model (e.g., GEE)?

-   In a multilevel model, the V matrix is the implication of specifying the random effects D matrix as well as the residual covaraince structure called the R matrix. We know that in a marginal model such as GEE, we do not include random effects, but instead the $V_j$ matrix is directly specified through a correlation structure that we assume represents the data dependencies, and include common structures such as independence, exchangeable, or AR-1 for longitudinal marginal models.

18. Express the model fit to a hypothetical longitudinal data set (with time points nested within individuals) using the following R code in mathematical notation. Be sure to also include any random effects and the D matrix. You should treat x1 and x2 as time-varying level 1 predictors, while x3 is a level 2 (individual-level) predictor. How many parameters are estimated in the model? \[10 points\]
    -   lmer(y \~ x1 + x2 + x3 + x2:x3 + (x3\|id), REML=T, data=dat)

![](images/clipboard-2450356467.png)

-   The model estimates a total of 9 parameters (5 fixed effects, 4 random effects)
