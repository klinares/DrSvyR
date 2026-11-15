---
id: "jpsm/applications_stats_modeling_SURV617/assignments/hw2"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "assignment"
title: "SURV617, Homework 2"
original: "applications_stats_modeling_SURV617/assignments/hw2.qmd"
pages: 
sha256: "d1acb0b052f3ceaea12ccaffe683b50d0e9df12b4a060013a92d55b265550cac"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:39"
---


## Overview of data

### In a subset of data from the Health and Retirement Study, 311 participants from the “War Babies” cohort (born 1942-1947) had their systolic blood pressure checked every 4 years. This subset was taken from the RAND HRS Longitudinal File 2022. The dataset contains the following variables

```r

pacman::p_load(jtools, knitr, viridis, geepack, nlme, lme4, patchwork, tidyverse)

options(digits=4, scipen=999)
```

| Variable | Definition |
|------------------------------------|------------------------------------|
| HHIDPN | Six character person ID, combining HRS Household ID and HRS person number |
| bp_sys | Systolic blood pressure (mmHg) |
| wave | HRS wave |
| age_y | Age in years at a given wave |
| year | Numeric measure of years since first blood pressure measurement |
| RAGENDER | 1 = male, 2 = female |

### Study objectives

1.  On average, how does systolic blood pressure change over time as people get older?
2.  Are there differences in systolic blood pressure trajectories by sex?

```r
# read in the data

dat_path <- 
  "D:/repos/UMD_classes_code/applications_stats_modeling_SURV617/assignments"

load(str_c(dat_path, "/hrs_wbbp_long.rda"))
  
hrs_wbbp_long <- hrs_wbbp_long |> 
   # recode ID as a factor
  mutate(HHIDPN = factor(HHIDPN))

hrs_wbbp_long |>
  filter(year==0) |>
  reframe( "Sample Size" = n(),
           "Percent Female" = scales::percent(mean(RAGENDER)-1),
           "Average Age, SD" =
             str_c( round(mean(age_y), 2),
                    " ( ", round(sd(age_y), 2), ")"),
           "Age Range" = str_c(min(age_y), " - ", max(age_y))
  ) |> kable()

hrs_wbbp_long <- hrs_wbbp_long |> 
  mutate(
   # recode gender into a factor for visualization
   RAGENDER = factor(RAGENDER, labels = c("Male", "Female")))

```

-   At baseline, the sample size consisted of 311 individuals (56% female) with a mean age of 58.8 (*S.D.* = 4.8). Age ranged from 30 to 76 years old. There was no missingness in the data. Each individual had exactly 5 measurements of Systolic Blood Pressure (SBP) levels for each year of the study. year in this dataset is measured at baseline year 0, year 4, year 8, year 12, and finally year 16.

\newpage

## Questions

1.  **Explore the trajectory of systolic blood pressure over time (both individually and on average) by creating data visualizations. Do you observe evidence of non-linear trends over time? Do you observe evidence that trajectories (i.e., the slopes) differ by sex?**

```r
#| fig-width: 8
#| fig-height: 8.5

x_title <- "Years since baseline"
y_title <- "Systolic Blood Pressure (mmHg)"

p_1 <- hrs_wbbp_long |> 
  ggplot(aes(x = year, y = bp_sys, group=HHIDPN)) +
  geom_point(alpha=.5,  size=.3) +
  geom_line(linewidth =.05, alpha=.1) +
  geom_smooth(aes(group=NULL), linewidth=1.5, 
              method="loess", se=FALSE, color="dodgerblue") +
  labs(title = "Figure 1.a.Individual Systolic Blood Preasure (SBP) Trajectopries",
       subtitle = "Blue line: Average time point SBP level.",
       x = x_title, y = y_title) +
  ggthemes::theme_hc()

p_2 <- hrs_wbbp_long |> 
  ggplot(aes(x = year, y = bp_sys, group=HHIDPN)) +
  geom_smooth(aes(group=NULL), linewidth=1.5, 
              method="loess", se=TRUE, color="dodgerblue") +
  labs(title = "Figure 1.b.Sample Average Systolic Blood Preasure (SBP) Trajectopries",
       x = x_title, y = y_title) +
  ggthemes::theme_hc()

p_1 / p_2
```

-   In Figure 1.a, SBP yearly average levels (blue line) appears to be stable across time, although baseline levels tended to be the lowest. SBP average yearly levels ranged from 124 to 128 (captured in Figure 1.b), with an SD range of about 17 to 19, suggesting large yearly variability. From this plot we can see how individuals vary across each other in terms of SBP levels. While the overall average trajectory appears to be linear, the individual trajectories do not while some fluctuate a lot across data collection years.

```r
#| fig-width: 7
#| fig-height: 5
#| 


hrs_wbbp_long |> 
  ggplot(aes(x=year, y=bp_sys, 
             fill=RAGENDER, color=RAGENDER)) +
  geom_smooth() +
  labs(title = "Figure 2. Average SBP Trajectory by Gender",
       x = x_title, y = y_title) +
  scale_fill_viridis_d( option="magma", alpha=.9, begin=.2, end=.8) +
  scale_color_viridis_d(option="magma", alpha=.9, begin=.2, end=.8) +
  theme(legend.position = "bottom") +
  ggthemes::theme_hc() 
```

-   In Figure 2, we plot average SBP trajectories and its standard error by gender and note that overall females may have a different trajectory despite also starting with lower levels, with both of these trajectories being non-linear. Additionally, at year 16 SBP levels by gender seem to be less different. Both genders also have a similar increase by year 4, but females seem to have a lower dip by year 8 than males.

\newpage

2.  **Create a variable for age of each participant at baseline (make sure that your intercept is interpretable) and fit a marginal linear model with bp_sys as the dependent variable and fixed effects for age at baseline, RAGENDER, and year. Then fit the same model, but add a quadratic polynomial for year in one model, poly(year, 2), and a cubic polynomial for year in another, poly(year, 3). Use an exchangeable correlation structure for all models. Which model best fits the data?**

```r
#| fig-width: 7
#| fig-height: 4

hrs_wbbp_long <- hrs_wbbp_long |> group_by(HHIDPN) |>
  mutate(baseline_age = first(age_y)) |> ungroup() |>
  mutate(baseline_age_c = baseline_age - mean(baseline_age))

hrs_wbbp_long |> filter(year==0) |>
  ggplot(aes(x = baseline_age_c, y = bp_sys, color = RAGENDER)) +
  geom_point( alpha = 0.55) +
  geom_smooth(method = "lm", se = FALSE, alpha=.7, linewidth = .75) +
  scale_color_viridis_d(option="magma", alpha=.9, begin=.2, end=.8) +
  labs(title = "Figure 3. SBP Levels at Baseline by Age-Centered",
       x = "Age, Centered at Baseline", y = y_title) +
  theme(plot.title = element_text(face = "bold", size = 12)) +
  ggthemes::theme_hc()
```

-   After we center age at baseline we plot in Figure 3 SBP levels be age centered for males and females. We also plot linear growth change of SBP levels, and see a positive slope for both genders, suggesting that SBP levels at baseline increase as people get older, slightly more so for males.

```r
gls_mod_1 <- gls(bp_sys ~ baseline_age_c + RAGENDER + year, 
               correlation = corCompSymm(form = ~ 1 | HHIDPN),
               method="ML",
               data=hrs_wbbp_long)

gls_mod_2 <- gls(bp_sys ~ baseline_age_c + RAGENDER + poly(year, 2), 
                                method="ML",
               correlation = corCompSymm(form = ~ 1 | HHIDPN),
               data=hrs_wbbp_long)

gls_mod_3 <- gls(bp_sys ~ baseline_age_c + RAGENDER + poly(year, 3), 
                                method="ML",
               correlation = corCompSymm(form = ~ 1 | HHIDPN),
               data=hrs_wbbp_long)

anova(gls_mod_1, gls_mod_2)
anova(gls_mod_1, gls_mod_3)
```

-   We estimate each model using ML for these nested marginal linear models and compare them via AIC, BIC, and a sequential likelihood ratio test (LRT). M estimation allows us to compare models with difference fixed effects, while estimating with REML provides us with unbiased estimates of variance components. Once we select our model, we will re-estimate using REML. We find that the cubic model has the lowest AIC and BIC values, but these differences are marginal at best so we turn our attention to LRT for comparisons.
-   The linear model when compared to the quadratic model results in a non statistically significant LRT of 1.47, indicating that the quadratic term does not provide better fit to the data. Next, we compare the linear model versus the cubic model and find a statictically significant LRT value of 6.13, suggesting that the cubic term improves fit beyond the linear model. **We choose the cubic model based on the lowest AIC, BIC, and LRT as the model that fits the data best.**

\newpage

3.  **For the model you selected in Q2, interpret all non-polynomial regression coefficients (regardless of whether they are significant) from the model fit in Q1 in plain English. Also, given the estimated polynomial coefficients, what do these suggest about the nature of the overall trajectory in blood pressure over time?**

```r
# refit model with REML
gls_mod_3 <- gls(bp_sys ~ baseline_age_c + RAGENDER + poly(year, 3), 
               correlation = corCompSymm(form = ~ 1 | HHIDPN),
               data=hrs_wbbp_long)
```

-   Intercept: The expected SBP for a male participant with average age at baseline was estimated as 128.74 mmHg. This fixed effect is statistically significant, p \< .05.

-   Baseline Age Centered: For each year older a participant is from baseline, their SBP is expected to increase by .72 mmHg holding all other predictors constant. These are the cross sectional differences at baseline. This fixed effect is statistically significant, p \< .05.

-   Gender: On average females have an estimated 3.99 mmHg lower SBP levels than males holding all other predictors constant. This fixed effect is statistically significant, p \< .05.

-   Polynomial terms:

    -   The estimated polynomial coefficients describe the non-linear trajectory in SBP levels over time. The we see a statistically significant positive cubic term (p\<.05), combined with the other polynomial terms, confirming that the trajectory is not a line trend. This statistical finding is consistent with the *S* shaped trajectory we observed in Figure 2 among males and females, suggesting that SBP rises initially, flattens out during the middle years of the study, and rises again closer to the end of the study as participants also age.

```r
export_summs(gls_mod_3, error_format = "[{conf.low}, {conf.high}]")
```

\clearpage

4.  **Refit the model you chose in Q2, this time using an AR1 working correlation structure in one model, and unstructured (general) in another. Use appropriate methods to compare these models against each other and the model with an exchangeable correlation structure and identify which appears to fit the data best. (Hint: See ?gls or help(gls) to view available correlation structures and how to specify them.) Examine the estimated variance-covariance matrices for each of the three models and briefly comment on what you observe.**

-   We again fit the chosen cubic model to the data with a an AR1 correlation and an unstructured correlation. We observe the unstructured model had the lowest AIC value, but also the highest BIC value. This is probably the case because the unstructured model fits the data best at the cost of complexity from additional parameters, there therefore the BIC is penalizing for this complexity. The AR1 and exchangeable models have very similar AIC and BIC values, with the AR1 model having slightly better fit to the data.

```r
# first model is the AR1
ar_mod_1 <- gls(bp_sys ~ baseline_age_c + RAGENDER + poly(year, 3), 
               correlation = corAR1(form = ~ 1 | HHIDPN),
               data=hrs_wbbp_long)

# second model is the unstructured correlation
mod_unstructure <- gls(bp_sys ~ baseline_age_c + RAGENDER + poly(year, 3), 
               correlation = corSymm(form = ~ as.numeric(factor(year)) | HHIDPN),
               weights = varIdent(form = ~ 1 | as.numeric(factor(year))),
               data=hrs_wbbp_long)

AIC(gls_mod_3, ar_mod_1, mod_unstructure) |> 
    as.data.frame() |> 
  rownames_to_column() |> 
  rename(Model=1) |> 
  add_column(
    BIC(gls_mod_3, ar_mod_1, mod_unstructure) |> tibble() |> select(BIC)
    ) |> 
  kable()
```

-   The exchangeable correlation parameter was .40, which is assumed to be a constant correlation between all measurement pairs despite time separation. This is the most simple model but perhaps unrealistic for longitudinal data.

```r
cat("Rho for exchangeable model:",
    coef(gls_mod_3$modelStruct$corStruct, unconstrained = FALSE))
```

-   Below we print the AR1 correlation parameter phi .49, and it assumes that correlation decreases exponentially with time separation with measurements closer in time should have be more strongly correlated than further away measurements. This model is perhaps more realistic for longitudinal data.

```r
cat("Phi AR1 model:",
    coef(ar_mod_1$modelStruct$corStruct, unconstrained = FALSE)
)
```

-   We print the correlation matrix for the unstructured model, which makes no assumption about any correlation patterns thus allows each time point pair to have their own correlation. Despite the flexibility of this approach, it estimates many more parameters than than other models.

```r
unstruc_cor <- mod_unstructure$modelStruct$corStruct
unstruc_cor

```

\newpage

5.  **Individuals can be diagnosed with hypertension (high blood pressure) when their systolic blood pressure is greater than or equal to 140. Create a variable called htn that equals 1 when bp_sys ≥ 140 and 0 otherwise. Then fit a multilevel logistic regression model with htn as your dependent variable and year as your predictor (not as a polynomial). Include a random intercept and a random year slope for each individual. Interpret the fixed effects on both the log-odds and odds ratio scales.**

-   Log odds

    -   Intercept: The log odds of having hypertension at baseline is estimated at -1.87.

    -   Year: For each additional year since baseline, the log-odds of having hypertension decreases by .01, yet this was not statistically significant. .

-   Odds ratios:

    -   Intercept: Represents the predicted odds estimated at .15 of having hypertension at baseline.

    -   Year: For each additional year following baseline, the odds are multiplied by .994 or a ((OR-1 )\*100) .6% decreases in odds per year, this again was not statistically different from 0.

```r
hrs_wbbp_long <- hrs_wbbp_long |> 
  # create hypertension binary variable
  mutate(htn = ifelse(bp_sys >= 140, 1, 0))

mlm_logit_1 <- glmer(htn ~ year + (year | HHIDPN),
                     family = binomial(link="logit"),
                     data = hrs_wbbp_long)

summ(mlm_logit_1, digits=3, r.squared=FALSE, confint = TRUE,
     re.variance=getOption("summ-re.variance", c("var")))

# transform log odds to odds ratios
exp(fixef(mlm_logit_1)) |> kable(col.names = "Odds Ratio")
```

\newpage

6.  **Refit your model from Q5, this time adding RAGENDER and baseline age as fixed effects.**

-   We add two additional fixed effects to the model and print the log odds below.

```r
mlm_logit_2 <- glmer(htn ~ year + RAGENDER + baseline_age_c + (year | HHIDPN),
                     family = binomial(link="logit"), 
                     data = hrs_wbbp_long)

summ(mlm_logit_2, digits=3, r.squared=FALSE, confint = TRUE, 
     re.variance=getOption("summ-re.variance", c("var")))
```

7.  **Interpret the model parameters estimated in Q6, including any estimated variance components. Be sure to interpret all fixed effects (regardless of significance) on both the log-odds and odds ratio scales.**

-   Below we print the odds ratio for the model summary.

-   Fixed effects

    -   Intercept: The estimated log odds was -1.60 (OR=.20) for hypertension among males and with average age at baseline. The odds for this reference group at baseline are about ((1-OR)\*100) 80% lower than the odds of not having hypertension.

    -   Year: Each additional year is associated with a decrease in the log odds of .020 (OR = .98) for hypertension, holding all other predictors constant. For any individual, their odds of having hypertension is multiplied by .98 each year, or an almost 2% decrease in odds per year. However, this fixed effect was not statistically significant.

    -   Gender: Holding year constant, female log odds of hypertension are .33 (OR = .72) lower than males holding all other predictors constant. Among females, the odds of having hypertension are roughly ((1-OR)\*100) 28% lower compared to males with the same baseline average age at the same wave point. However, this fixed effect was not statistically significant.

    -   Baseline Average Age: For each additional year in age at baseline, an individual's log odds of having hypertension increases by .08 (OR = 1.09) . For every one year increase in average age at baseline, the odds of having hypertension are 9% higher holding gender and year constant. The fixed effect of baseline age centered was statistically significant, and the 95% confidence intervals for the odds ratio was between 1.02 and 1.15, suggesting that being older at baseline is associated with higher odds of hypertension.

-   Variances

    -   Random intercept: We estimate a variance of 1.91 in SBP baseline levels, suggesting substantial variability between individuals' log odds of hypertension.

    -   Random slope: The estimate of .005 quantifies the rate of change in years varying between individuals. However, this is very small, suggesting that the trajectories in the log odds of hypertension risk over time is almost similar for most individuals in the sample.

    -   Not shown, but the correlation between an individual's baseline risk and rate of change was estimated at .11 which is a very weak correlation, suggesting that individual baseline risk for hypertension does not necessarily mean that the log odds will continue to grow more so than individuals with lower risk at baseline.

```r
export_summs(mlm_logit_2,
               error_format = "[{conf.low}, {conf.high}]", # Displays CIs
              exp = TRUE) # log odds
```

\newpage

8.  **Fit a marginal logistic regression model with htn as the dependent variable and year, RAGENDER, and baseline age as fixed effects. Use an exchangeable working correlation structure. Interpret the regression coefficients on either the log-odds or odds ratio scale. Compare your estimates and interpretations to the multilevel model fit in Q6.**

```r
gee_logit <- geeglm(htn ~ year + RAGENDER + baseline_age_c,
                    id = HHIDPN,
                    family = binomial(link="logit"),
                    corstr ="exchangeable",
                    data = hrs_wbbp_long)

summary(gee_logit)
```

\newpage

-   Odds Ratios

    -   Intercept: At baseline, the population average odds of having hypertension among males with average baseline age is estimated to be .31, meaning that for an average age male at baseline their odds of having hypertension are roughly 69% lower than the odds of having it.

    -   Year: For each additional year in the study, the average odds of hypertension are multiplied by 1 holding all other predictors constant; however, this fixed effect was not statistically significant.

    -   Gender: Among females, the odds of having hypertension was estimated at .77 times the odds for males holding all other predictors constant. However, this different was not statistically significant.

    -   Baseline Average Age: For each year of age from baseline the average odds of having hypertension increases by 1.06, or a 6% increase, holding all other predictors constant. This fixed effect was statistically significant, p\<.05, and the 95% confidence intervals for the odds ratio was between 1.01 and 1.11, suggesting that being older at baseline is associated with higher odds of hypertension.

-   Model Comparison

    -   The generalized estimating equation (GEE) model makes inferences on population average effects, meaning that they describe average trends across the entire sample, compared to the multilevel exchangeable model which describes within cluster variation. In other words, in the multilevel model, we are controlling for within person effects with longitudinal data and covariate fixed effects within cluster. Moreover, the multilevel model assumes a constant correlation between all measurements for each person, where as the GEE model does not make this assumption in the correlation structure. Regarding the fixed effects, odds are somewhat comparable as shown in the table below but not equal.

```r
export_summs(mlm_logit_2, gee_logit, exp=TRUE,
             digits=3, r.squared=FALSE, confint = TRUE,
             error_format = "[{conf.low}, {conf.high}]",
             model.names = c("MLM", "GEE"))
```

\newpage

\clearpage

9.  **In \~1/2 page, describe the models fit in Q6 and Q8. How are they similar and how are they different? In what situations would you choose one over the other?**

The primary difference between the multilevel model (MLM) fit and the marginal GEE model fit is their inferential interpretation, which is why we cannot easily compared them using AIC or BIC. The MLM is a subject-specific (or conditional) model. In an MLM, including random effects explicitly models the variability between individuals and provides estimates that represent the change in odds for a specific person, while holding their unique baseline risk constant. The GEE model on the other hand is a population-averaged (or marginal) model that estimates the average trend for the entire population, thus not explicitly estimating the variances and covariances. This conceptual difference explains the practical difference in the results. The MLM coefficients are larger in magnitude (e.g., baseline age OR of 1.09) because they are conditional, while the GEE coefficients are averaged across all individuals (e.g., baseline age OR of 1.06). In terms of similarities, both models handle longitudinal data with binary outcomes, using the same logit link function with the same fixed effects. Interestingly enough, they both come to a similar conclusion in terms of which covariates were statistical significant and which were not.

The choice of model depends entirely on the research question at hand. The MLM model would be chosen if the goal was to understand individual-level risk trajectories or to make predictions for a specific person since it estimates between-subject heterogeneity for intervention or treatment. However, the GEE model is the more appropriate choice for answering objective 1, of how SBP on average changes over time as people get older, which we provide the odds in question 8. We also find that differences in average trajectories by gender in SBP levels were insignificant. Nonetheless, ff the goal is to understand population level trends, for instance in public health planning, the marginal model seems to be an appropriate choice over the MLM.

\newpage

## **Appendix**

AI Disclaimer: For this assignment I had issues rendering to a PDF, probably due to the additional formatting packaged used for summary tables. I relied on Google's AI overview to help me troubleshoot formatting issues (see below) and found that `\clearpage` is following `\pagebreak` fixes the issue when a new page is not being rendered. I also used this AI to troubleshoot the error I could not get rid off in question 8 "Error in eval" but could not find a good solution or keep from printing.

![](images/clipboard-3414356049.png){width="420"}
