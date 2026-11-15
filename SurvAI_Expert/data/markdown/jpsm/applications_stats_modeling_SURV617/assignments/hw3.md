---
id: "jpsm/applications_stats_modeling_SURV617/assignments/hw3"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "assignment"
title: "SURV617, Homework 3"
original: "applications_stats_modeling_SURV617/assignments/hw3.qmd"
pages: 
sha256: "87a145d317f1e5c487b07d2010c5d4d8d72a249f02535de760f12af514796404"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:39"
---


## Overview of data

### The European Social Survey (ESS) is an academically-driven cross-national survey that has been conducted across Europe since its establishment in 2001. For this assignment, we will analyze the ESS-Belgium data collected in 2010. Various formats of the ESS-Belgium data set and the codebook (ESS5_appendix_a6_e03_1.pdf) are all available on Canvas.

```r
pacman::p_load(viridis, semPlot, performance, lavaan, knitr, lavaanExtra, tidyverse)

options(digits=4, scipen=999)
theme_set(theme_minimal())
```

### There are four variables measuring the respondent’s trust in leadership:

| Variable | Definition                    |
|----------|-------------------------------|
| TRSTPRL  | Trust in country’s parliament |
| TRSTLGL  | Trust in the legal system     |
| TRSTPLT  | Trust in politicians          |
| TRSTPRT  | Trust in political parties    |
| TRSTPLC  | Trust in the police           |

\newpage

### There are three variables measuring attitudes toward immigrants:

| Variable | Definition |
|------------------------|------------------------------------------------|
| IMSMETN | Allow many/few immigrants of same race/ethnic group as majority |
| IMDFETN | Allow many/few immigrants of different race/ethnic group from majority |
| IMPCNTR | Allow many/few immigrants from poorer countries outside Europe |

### And there is one variable measuring the satisfaction with the national government:

| Variable | Definition                                 |
|----------|--------------------------------------------|
| STFGOV   | How satisfied with the national government |

```r
dat_path <- 
  "D:/repos/UMD_classes_code/applications_stats_modeling_SURV617/assignments"

load(str_c(dat_path, "/ess_belgium2.rda"))

ess_belgium <- ess_belgium |> 
  select(idno, gndr, starts_with("trs"), stfgov, imsmetn, imdfetn, impcntr) |> 
  mutate(idno = as.character(idno),
         gndr = ifelse(gndr == 1, "Male", "Female")) |> 
  # convert NA-values to NA
  mutate(across(starts_with(c("trs", "stf")),~ na_if(., 88)),
         across(starts_with("im"),~ na_if(., 8))) 

ess_belgium |> head() |> knitr::kable()
```

\newpage

1.  **Examine the SEM diagram below and answer the following six questions.**

-   a\. How many parameters are you estimating?

    -   In this model we have **38 total parameters**; however, since we are scaling one indicator constrained to 1 for identifying each latent variable we are actually estimating **34 parameters** since four of these are known, or fixed, in our model. We also fix the covariance from V1 to V2 to 0 and do not count this parameter towards what we are estimating. We fit this model to simulated data found in the Appendix and confirm that we are estimating 34/38 parameters.

        -   6 factor loadings (4 are fixed to 1)

        -   10 intercepts due to assumed missingness in dataset

        -   4 structural paths: V4 \<- V1, V3; V3 \<- V2, V1

        -   10 error variances for X1:X10

        -   2 Disturbance varainces for V3 and V4

        -   2 Exogenous variances for V1 and V2



-   b\. Which variables are latent?

    -   There are 4 latent (unobserved) variables v1-v4 represented by the ovals.



-   c\. How many variables are observed?

    -   There are 10 total indicators observed represented by the squares.



-   d\. Which latent variables are exogenous?

    -   V1 and V2 are both latent exogenous variable.



-   e\. How can you tell whether a latent variable is exogenous using the diagram?

    -   We can tell by seeing that there are no arrows pointing towards them, but rather they have arrows pointing outwards.



-   f\. Suppose that we wanted to add covariance between two latent variables. What would we add to the diagram to indicate this?

    -   We would add a two arrow curve line connecting two latent variables.

\newpage

2.  **Write out the structural and measurement model equations based on the SEM diagram.**

| Structural Model | Measurement Model |
|------------------------------------|------------------------------------|
| $V4 = \alpha_1 + \gamma_{11}V1 + \gamma_{12}V3 + \epsilon_{12}$ | $x1 = v_1 + \lambda_{11}V1 + \epsilon_1$ |
| $V3 = \alpha_2 + \gamma_{22}V1 + \gamma_{21}V2 + \epsilon_{11}$ | $x2 = v_2 + \lambda_{21}V1 + \epsilon_2$ |
|  | $x3 = v_3 + \lambda_{31}V1 + \epsilon_3$ |
|  | $x4 = v_4 + \lambda_{41}V3 + \epsilon_4$ |
|  | $x5 = v_5 + \lambda_{51}V3 + \epsilon_5$ |
|  | $x6 = v_6 + \lambda_{61}V2 + \epsilon_6$ |
|  | $x7 = v_7 + \lambda_{71}V2 + \epsilon_7$ |
|  | $x8 = v_8 + \lambda_{81}V4 + \epsilon_8$ |
|  | $x9 = v_9 + \lambda_{91}V4 + \epsilon_9$ |
|  | $x10 = v_{10, 1} + \lambda_{10}V4 + \epsilon_{10}$ |

\

\

\

3.  **Briefly discuss why it is not advisable to conduct a path analysis on cross-sectional data (i.e., data from a single time point).**
    -   In path analysis we assume a causal relationship between variables. Hox and Bechger 1998 captures this best in their quote "nothing in structural equation modeling . . . magically transforms correlational data into causal conclusions." With temporal data, for X to cause Y, X would need to happen before Y but in cross sectional data these variables are observed in the same time frame.

\

\newpage

4.  **Using the ESS dataset, conduct a confirmatory factor analysis (CFA) using the observed variables IMSMETN, IMDFETN, and IMPCNTR as indicators of the latent overall attitude towards immigra- tion. Don’t forget to recode missing values (missing = 8) for these observed variables as NA! Answer the following three questions:**
    -   There were missing data in each item with the highest percent missing of 1% for trstprl. These were dropped from the analysis as we require responses for all variables resulting in a sample size of 1,686. We plot item response distribution in percentages for items with 11 response levels and items with four levels, and observe a good amount of variability around responses, suggesting responses are not concentrated on one value. We may wish to consider a power analysis since; however, we do seem to have more than 30 cases per parameter which this is an ambiguous rule of thumb.

```r
#| echo: false
#| fig-width: 8
#| fig-height: 7
#| 

library(patchwork)

# Check the structure
p1 <- ess_belgium |> 
  drop_na() |> 
  select(starts_with(c("idno", "tr", "st"))) |> 
  pivot_longer(-idno, names_to="items", values_to="response") |> 
  group_by(items) |> 
  count(response) |> 
  mutate(prop = n/sum(n),
         response = fct_reorder(factor(response), response, .desc = TRUE)) |> 
  ungroup() |> 
  ggplot(aes(x=items, y=prop, fill=response)) +
  geom_bar(stat = "identity", position = "stack") +
  coord_flip() +
  scale_fill_viridis_d(option="B", alpha=.7) + 
  scale_y_continuous(labels = scales::percent) +
  labs(title="Figure 1.a. Items tend to have variability in responses.",
    y = "Percent Response Distribution") +
  guides(fill = guide_legend(reverse = TRUE))


# Check the structure
p2 <- ess_belgium |> 
  drop_na() |> 
  select(idno, starts_with("im")) |> 
  pivot_longer(-idno, names_to="items", values_to="response") |> 
  group_by(items) |> 
  count(response) |> 
  mutate(prop = n/sum(n),
         response = fct_reorder(factor(response), response, .desc = TRUE)) |> 
  ungroup() |> 
  ggplot(aes(x=items, y=prop, fill=response)) +
  geom_bar(stat = "identity", position = "stack") +
  coord_flip() +
  scale_fill_viridis_d(option="B", alpha=.7) + 
  scale_y_continuous(labels = scales::percent) +
  labs(title="Figure 1.b. Items tend to have variability in responses.",
    y = "Percent Response Distribution") +
  guides(fill = guide_legend(reverse = TRUE))

p1 / p2

```

```r
cfa_mod <- 'immigration =~ imsmetn + imdfetn + impcntr'
cfa_fit <- cfa(cfa_mod, data=ess_belgium)

bruceR::lavaan_summary(cfa_fit)
```

```r
#| echo: false
#| fig-width: 8
#| fig-height: 4.25
nice_tidySEM(cfa_fit, est_std = TRUE, hide_var = FALSE)
```

-   a\. How is the latent variable being scaled?
    -   We can plot the unstandarized estimates for the CFA model and note that the factor loading for `imsmetn` is constrained to 1. We set this constrain because it allows the latent variable to be scaled so that we identify the model. Alternatively, we can set the variance in the latent variable to be equal to 1 for identification.

\

-   b\. Do the estimated loadings seem different from zero, and do they suggest that the observed variables are all a significant function of the latent construct?
    -   We estimate indicators and find their loadings to be significantly different from zero, p \<.05, with all three of the indicators having standardized positive factor loadings above .777, and these are the correlations between the manifested indicators and the latent variable, immigration attitude. The positive value indicator that as the latent variable increases, so does the manifestation or endorsement of the indicators, with a strong association magnitude.

        -   Moreover, as an example the standardized factor loading for imsmetn of $.777^2$ if we square it, we estimate that about 60% of the proportion of variance in this indicator can be explained by the latent variable. The standardized residual variance for this indicator is than $1-loading^2=.396$ which is the variance for this indicator that is not explained by the latent variable.
-   c\. Conduct a multiple group analysis to test whether there is measurement invariance by gender (gndr: 1 = male, 2 = female).
    -   Below we fit three models to establish evidence for measurement equivalence across gender, and this is called configural invariance to test if the same factor structure of attitudes towards immigration is imposed on males and females. Below we print a diagram of the unstandardized factor loadings and confirm that these are similar across groups when freely estimated.

    -   Our second model, the metric invariance, constrains factor loadings to be equal across groups. We print the model diagram and note that they have similar factor loadings given the constraint in the model across groups.

    -   Next we constrain in our scalar model both loadings and intercepts to be equal across groups.

    -   Our $\chi^2$ difference between model 1 and 2 (constrained loadings) is not statistically significant, p \> .05, suggesting that there is weak invariance (equal factor loadings). Our second model comparison $\chi^2$ also reveals that model 2 and 3 (constrained factor loadings and intercepts) are not statistically significantly different, p \> .05; suggesting that we are safe to compare model values in the latent means across gender.

```r
#| fig-width: 8
#| fig-height: 4
# configural invariance
mcfa_config_fit <- cfa(cfa_mod, group = "gndr", data=ess_belgium)
nice_tidySEM(mcfa_config_fit, est_std = FALSE, hide_var = TRUE)

# scalar invariance
mcfa_metric_fit <- cfa(cfa_mod, group = "gndr",
                      # equal loadings
                      group.equal = c("loadings"),
                      data=ess_belgium)

nice_tidySEM(mcfa_metric_fit, est_std = FALSE, hide_var = TRUE)

mcfa_scalar_fit <- cfa(cfa_mod, group = "gndr",
                      # equal loadings & intercepts
                      group.equal =c("loadings","intercepts"),
                      data=ess_belgium)

# compare model fit
invariance_comparison <- lavTestLRT(
  mcfa_config_fit, mcfa_metric_fit, mcfa_scalar_fit)

invariance_comparison |> kable()

```

\newpage

5.  **Using the ESS dataset, fit a structural equation model to predict latent immigration attitude (as indicated by the 3 variables in Q4) with a latent measure of trust in authority. The latent measure of trust in authority is indicated by the 5 following observed variables: TRSTPRL, TRSTLGL, TRSTPLC, TRSTPLT, and TRSTPRT. Don’t forget to recode missing values (missing = 88) for these observed variables as NA!**
    -   We fit an SEM model to the data and estimate 17 parameters.

```r
# specifiying the structure and measurement model
sem_model <-'
  # Measurement Model
  trust =~ trstprl + trstlgl + trstplc + trstplt + trstprt
  immigration =~ imsmetn + imdfetn + impcntr

  # Structural Model
  immigration ~ trust
'

# estimate the sem model
sem_fit <- sem(sem_model, data = ess_belgium)

```

\newpage

```r
bruceR::lavaan_summary(sem_fit)
```

\

\newpage

6.  **Draw the SEM diagram for Q5.**

```r
#| fig-width: 8
#| fig-height: 8
semPaths(sem_fit, layout="tree", sizeMan=8, sizeInt = 12, 
                style="lisrel", residuals=TRUE, rotation=1, 
                intAtSide = FALSE, whatLabels = "est")
```

\newpage

\

7.  **How would you characterize the fit of the SEM from Q5? Acceptable? Poor? Examine modification indices for this model. How could the model be modified to improve fit?**
    -   Below we print performance metrics for this model and the$\chi^2(df=19)=500.80, p <.05$ suggesting a poor fit to the data and we reject the null hypothesis and the predicted covariances perfectly match the observed data. However, the CFI and NNFI (also known as TLI) have values $\ge .91$, suggesting that this model fits the data adequately, values \>.95 indicated good model fit. The RMSEA is \> .08 indicating poor fit. The SRMR is \< .08 suggesting a good fit. These model fit indices are mixed, and we conclude that this model has acceptable fit to the data, but could benefit from model improvements.

```r
model_performance(sem_fit, 
                  metrics = c("Chi2", "Chi2_df", "p_Chi2", "CFI", "TLI", "NNFI",
                              "RMSEA", "RMSEA_CI_low", "RMSEA_CI_high", "SRMR"))
```

-   Furthermore, we can examine modification indices (MI), which are a type of model diagnostic used in assessing improvements in model fit. The MI table below shows that by adding a correlated error between trstplt and trstprt could reduce the $\chi^2$ statistic by $mi=401$. These indicators, trust in politicians and trust in political parties are likely strongly correlated.

\newpage

```r
nice_modindices(sem_fit) |> kable()
```

\newpage

-   When we include a correlated error between the indicators suggested by the MI table, our $\chi^2$ value drops, yet it is still statistically significant. We do note that both CFI and NNFI (TLI) are now above .95 and RMSEA is below .08, indicating a much better fit to the data. However, we must take caution in using the modification indices since this is more exploratory in nature and we risk creating a complicated model that is unlikely to be reproducible with new data.

```r
sem_model_2 <-'
  # Measurement Model
  trust =~ trstprl + trstlgl + trstplc + trstplt + trstprt
  immigration =~ imsmetn + imdfetn + impcntr

  # Structural Model
  immigration ~ trust
  
  # correlated error
  trstplt ~~ trstprt
'

# estimate the sem model
sem_fit_2 <- sem(sem_model_2, data = ess_belgium)

model_performance(sem_fit_2, 
                  metrics = c("Chi2", "Chi2_df", "p_Chi2", "CFI", "TLI", "NNFI",
                              "RMSEA", "RMSEA_CI_low", "RMSEA_CI_high", "SRMR"))
```

\newpage

8.  **In \~1/2 a page, describe what the model from Q5 tells you about the relationship between trust in authority and immigration attitudes. Are there conclusions you are not able to make (using only this model and these data)?**

We regress the latent variable immigration attitudes onto trust in leadership, and as the latent mean of trust increases, the latent mean of immigration attitudes decreases by .10 points (p\<.05). The standardized path coefficient shows a moderate negative association of -.26 between these two latent variables. Individuals with higher levels of trust in leadership tend to have lower levels of views on immigration, yet this relationship is weak to moderate at best. We also presented performance metrics and found adequate evidence for model fit. When we explore modification indices we find that a few correlation errors significantly improves model fit at the cost of a more complicated model. Of note, is that there may be non-normality in the indicators we used in our model and we may wish to consider a different estimator such as weighted least squares.

We also address several critical limitations in our findings. The first limitation is that we cannot assert causality since our data is cross sectional; therefore, we cannot determine if higher trust in leadership causes negative views on immigration, or if a counfounder variable causes both of these latent variable. Despite our multiple group analysis on the measurement of immigration attitudes we did not also examine measurement invariance in gender for the trust in leadership measurement model. Finally, because we used a conventional SEM instead of one that accounts for the complex survey design of the ESS, our standard errors might be biased, meaning we could be overconfident in the statistical significance of our results.

\newpage

## Appendix (Simulating Data for Question 1)

We can start by defining the population model with some arbitrary parameter values. We will sample N size from this model for our simulation.

```r

sem_mod_param <- '
  # Measurement Model 
    V1 =~ 0.7*X1 + 0.8*X2 + 0.7*X3
    V2 =~ 0.8*X6 + 0.7*X7
    V3 =~ 0.7*X4 + 0.8*X5
    V4 =~ 0.7*X8 + 0.6*X9 + 0.8*X10

  # Structural Model 
    V3 ~ 0.4*V1 + 0.3*V2
    V4 ~ 0.2*V1 + 0.5*V3
'
```

We can use the `simulateData()` function from lavaan to simulate from our theoretical population parameters.

```r

set.seed(909)
n_obs <- 500
sim_data <- simulateData(sem_mod_param, 
                                   sample.nobs = n_obs)

sim_data |> glimpse()
```

![](images/clipboard-3178682415.png){width="568"}

We fit the following model to the simulated data, but note that lavaan imposes a covariance on our exogenous variable V1 and V2. We can fix the covariance to 0 to block it and this does not get counted towards parameters estimated.

-   We set the meanstructure to TRUE to estimate mean intercepts which add an additional 10 parameters. We now have

```r

sem_model <- '
  # Measurement Model
    V1 =~ X1 + X2 + X3
    V2 =~ X6 + X7
    V3 =~ X4 + X5
    V4 =~ X8 + X9 + X10

  # Structural Model
    V3 ~ V1 + V2
    V4 ~ V1 + V3

  # covariance block
  V1 ~~ 0*V2
'

fit_sem <- sem(sem_model, data = sim_data, meanstructure=TRUE)

fit_sem |> summary()
```

Finally, we plot our model.

```r
semPaths(fit_sem, layout="tree", sizeMan=8, sizeInt = 12,
         style="OpenMx", residuals=FALSE, rotation=2,
         intAtSide = FALSE, whatLabels = "est")
```

However, when we print all of the parameters in the model, we are seeing 29 total parameters because there are 24 unknown parameters estimated from the data, and 5 known fixed parameters as these are constrained to 1 in this model. We see these in the summary, as well as in the following table as SE = 0.

\newpage

```r
parameterestimates(fit_sem) |> tibble() |> filter(est!=0.000) |> kable()
```
