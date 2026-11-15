---
id: "jpsm/applications_stats_modeling_SURV617/assignments/hw1"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "assignment"
title: "SURV617, Homework 1"
original: "applications_stats_modeling_SURV617/assignments/hw1.qmd"
pages: 
sha256: "4811e895bc4b8fbeb7a826c2ae9c28d9b7bde27fbb78c2570699334ce30b8f33"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:39"
---


## 

## Overview of data

### In a subset of data from the Health and Retirement Study, 311 participants from the “War Babies” cohort (born 1942-1947) had their systolic blood pressure checked every 4 years. This subset was taken from the RAND HRS Longitudinal File 2022. The dataset contains the following variables

```r

pacman::p_load(jtools, knitr, viridis, ggResidpanel, 
               ggcorrplot, corrplot, patchwork,
                lme4, lmerTest, performance,
               infer, ggthemes, tidyverse)

options(digits=4, scipen=999)
theme_set(theme_minimal(base_size = 12))

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

1.  On average, how does systolic blood pressure change over time as people get older
2.  How much variance among participants is there in the trajectories of systolic blood pressure, and can this variance be explained by sex and age?

\

**Project Workflow:**

-   Read in data into our global environment and recode individual id codes `HHIDPN` into a factor as it is easier to work with for plots.

    -   Exploratory data analysis with outcome variable and explanatory variables relevant to the study objectives.

    -   Explore between and within variation.

-   Propose and build multilevel models to account for dependency in the data.

    -   Hypothesize several competing and nested models.

        -   Interpret results.

        -   Compare models on fit statistics and diagnostics.

-   Recommend a final model.

    -   Synthesize the modeling process.

```r
# read in the data

dat_path <- 
  "D:/repos/UMD_classes_code/applications_stats_modeling_SURV617/assignments"

load(str_c(dat_path, "/hrs_wbbp_long.rda"))
  
hrs_wbbp_long <- hrs_wbbp_long |> 
   # recode ID as a factor
  mutate(HHIDPN = factor(HHIDPN))


```

### Questions

### Complete an analysis as described below to address the study objectives using your judgement in order to keep things as simple as possible.

1.  Describe the sample in a reasonable way, i.e., construct a table or a graph of descriptive statistics as you may do for a publication. Be sure to remember that there is more than one observation per subject. Comment briefly on the general characteristics of the observations. Keep the study objectives in mind with your descriptive presentation.

```r
# at baseline, how many participants, 
## what is the gender breakdown 
### what is the average, sd, & range of age

hrs_wbbp_long |> 
  filter(year==0) |> 
  reframe( "Sample Size" = n(),
             "Percent Female" = scales::percent(mean(RAGENDER)-1),
             "Average Age, SD" = 
               str_c( round(mean(age_y), 2), 
                      " ( ", round(sd(age_y), 2), ")"
                      ),
             "Age Range" = str_c(min(age_y), " - ", max(age_y))
  ) |> 
  kable()
```

-   At baseline, the sample size consisted of 311 individuals (56% female) with a mean age of 58.8 (*S.D.* = 4.8). Age ranged from 30 to 76 years old. There was no missingness in the data. Each individual had exactly 5 measurements of Systolic Blood Pressure (SBP) levels for each year of the study. year in this dataset is measured at baseline year 0, year 4, year 8, year 12, and finally year 16.

*Exploratory Data Analysis*

-   First, we example the between person variability of the outcome variable systolic blood pressure (SBP) in mmHg across wave points.

```r
#| fig-width: 6
#| fig-height: 5

x_title <- "Years since baseline"
y_title <- "Systolic Blood Pressure (mmHg)"

hrs_wbbp_long |> 
  ggplot(aes(x = year, y = bp_sys)) +
  geom_jitter( alpha = 0.75, width = .60, size = .50) +
  stat_summary(fun = mean, geom = "line", alpha=.8,
              linewidth = 1.5, color="dodgerblue") + 
  labs(title = "Figure 1. Within Individual SBP Levels Vary Across Time",
       subtitle = 
         "Blue line: Average time point SBP level.",
       x = x_title, y = y_title) +
  theme_hc()

  
  
```

\

-   In Figure 1, SBP yearly average levels (blue line) appears to be stable across time, although baseline levels tended to be the lowest. SBP average yearly levels ranged from 124 to 128, with an SD range of about 17 to 19, suggesting large within year variability. We see the within year individual variability around SBP levels captured by the black dots, these represents our outcome of interest that varies by individual and by time. Next, we explore individual trajectories in SBP scores to examine linearity and change over time.

```r
#| fig-width: 6
#| fig-height: 6

# randomly select N individuals
set.seed(909)
random_ids <- hrs_wbbp_long |> distinct(HHIDPN) |> slice_sample(n=16) 

# plot their age against Y
hrs_wbbp_long |> 
  filter(HHIDPN %in% random_ids$HHIDPN) |> 
  ggplot(aes(x = year, y = bp_sys)) +
  geom_line( alpha = 0.75, linewidth = 1.25, linetype=2, color = "black") +
  geom_smooth(method = "lm", se = FALSE, alpha=.7,
              size = .5, color="dodgerblue") +
  labs(title = "Figure 2. For Randomly Selected Individuals,\n 
       SBP Trajectories are Generally Not Linear",
              subtitle = 
         "Black Dash line: SBP Level; Blue line: Linear change",
              x = x_title, y = y_title) +
  theme(plot.title = element_text(face = "bold", size = 12)) +
  facet_wrap(~HHIDPN) +
  theme_hc()
```

-   In Figure 2, we randomly select 16 individuals and plotted their SBP level trajectories (black dashed line) and note that most of these individuals' growth change deviate from a linear change (i.e., blue line). In this case, we may want to model individuals as a random cluster to allow each to have their own random intercept since we see that some individuals' SBP levels increase over time, while others decrease. Next, we move towards examining the outcome variable across other covariates that may help explain variability within individuals. We first convert `RAGENDER` into a factor variable for ease of generating plots below.

```r
#| fig-width: 6
#| fig-height: 4.25

hrs_wbbp_long <- hrs_wbbp_long |> 
 mutate(
   # recode gender into a factor for visualization
   RAGENDER = factor(RAGENDER, labels = c("Male", "Female")))

# plot baseline age distribution by gender
hrs_wbbp_long |> 
  filter(year==0) |> 
  ggplot(aes(x=RAGENDER, y = age_y, fill=RAGENDER)) +
  geom_violin( alpha = 0.7) +
  geom_jitter(color="black", size=0.4, alpha=0.9, 
              width=.3, show.legend = FALSE) +
  labs(title = "Figure 3. Distribution of Age at baseline by Gender",
       x = x_title, y = "Age", fill = "Gender") +
  scale_fill_viridis_d(option="magma", alpha=.9, begin=.2, end=.8) +
  theme(legend.position = "bottom") +
  ylim(22, 80) +
  theme_hc()

hrs_wbbp_long |> 
  t_test(age_y ~ RAGENDER,  conf_int = FALSE,
      alternative = "two-sided") |> 
  kable()
```

-   At baseline, the mean age for female was 57.5 and ranged from 30 to 66, and for males the average age was 60.4 and ranged from 48 to 76. (see Figure 3) Overall, males were older than females at baseline and a two-sample t-test provided evidence that these two age means were statistically significantly different from each other. This mean difference could be due to a few female outliers that tend to be much younger on average.

```r
#| fig-width: 6
#| fig-height: 6

# plot their age against Y
hrs_wbbp_long |> 
  filter(HHIDPN %in% random_ids$HHIDPN) |> 
  ggplot(aes(x = age_y, y = bp_sys)) +
  geom_line( alpha = 0.75, linewidth = 1.25, linetype=2, color = "black") +
  geom_smooth(method = "lm", se = FALSE, alpha=.7,
              size = .5, color="dodgerblue") +
  labs(title = "Figure 4. SBP Trajectories by age are Generally not Linear",
              subtitle = 
         "Black Dash line: Average SBP Levels; Blue line: Linear change",
              x = x_title, y = y_title) +
  theme(plot.title = element_text(face = "bold", size = 12)) +
  facet_wrap(~HHIDPN) +
  theme_hc()
```

-   We note that in Figure 4, plotting for a random set of individuals' SBP levels as they get older we do not see a linear growth change. Similarly, these are the same results as we saw in Figure 2, which implies that age and years are correlated and we may need to be careful when modeling these variables together. Moreover, we may want to have several competing models with these variables. Age has a strong positive association with year (.72), and here we decided to center age at baseline as $age_{baseline_{i}} - mean(age_{baseline})$ as this will give us a way interpret the intercept.

```r
hrs_wbbp_long <- hrs_wbbp_long |> 
  group_by(HHIDPN) |>
  # save baseline age for each person
  mutate(baseline_age = first(age_y)) |> 
  ungroup() |> 
  # add centered basdeline age + year
  mutate(baseline_age_c = baseline_age - mean(baseline_age)) 
```

```r
#| fig-width: 6
#| fig-height: 4.25
#| 
hrs_wbbp_long |>
  filter(year==0) |> 
  ggplot(aes(x = baseline_age_c, y = bp_sys, color = RAGENDER)) +
  geom_point( alpha = 0.55) +
  geom_smooth(method = "lm", se = FALSE, alpha=.7, linewidth = .75) +
  scale_color_viridis_d(option="magma", alpha=.9, begin=.2, end=.8) +
  labs(title = "Figure 5. SBP Levels at Baseline by Age-Centered",
              x = "Age, Centered at Baseline", y = y_title) +
  theme(plot.title = element_text(face = "bold", size = 12)) +
  theme_hc()
```

-   After we center age at baseline we plot in Figure 5 SBP levels be age centered for males and females. We also plot linear growth change of SBP levels, and see a positive slope for both genders, suggesting that SBP levels at baseline increase as people get older, slightly more so for males. We will further explore this relationship in a competing model.\

\newpage

2.  Fit a multilevel model with systolic blood pressure as the dependent variable and time (year) as the independent variable to explore how systolic blood pressure may have changed over time. Make sure to account for the within-subject correlation in observations on the dependent variable in the multilevel model that you are fitting. Be sure to clearly describe your reasoning.

```r
year_mod <-  lmer(bp_sys ~ 1 + year + (year|HHIDPN), 
                  data= hrs_wbbp_long, REML = TRUE)

summ(year_mod, digits=3, r.squared=FALSE, confint = TRUE,
     re.variance=getOption("summ-re.variance", c("var")))
```

\newpage

-   The key challenge with this dataset is the **violation of independence** since we have repeated measures of SBP for participant. Traditional OLS regression assumes that observations are independent, but measurements from the same person tend to be correlated. If we ignore this dependence in the data we may underestimate standard errors and inherently have invalid p-values and confidence intervals. When we model varying regression coefficients at the measurement level (level 1) we than have growth curves that vary by individuals (level 2).
-   We fit a multilevel model on SBP \~ year and allow within person correlation through random effects by allowing individual trajectories to vary, this is achieved through random slopes. We use REML for unbiased variance estimates, which accounts for the loss of degrees of freedom from estimating fixed effects.

\newpage

3.  Write out the model that you fit in question 2 using mathematical notation.

-   We can express this model as:

\begin{align*}
  \text{Level 1:} \quad & SBP_{ij} = \beta_{0j} + \beta_{1j} (year_{ij}) + \epsilon_{ij} \\\\ 
  \text{Level 2:} \quad & \beta_{oj} = \gamma_{oo} + u_{0j} \\ 
  & \beta_{1j} = \gamma_{10} + u_{1j} \\\\
  \text{Combined Model:} \quad & SBP_{ij} = \gamma_{00} + \gamma_{10}(year_{ij}) + u_{0j} + u_{1j}(year_{ij}) + \epsilon_{ij} \\\\ 
  \text{Assumptions:} \quad &
  \begin{pmatrix} 
    u_{0j} \\ 
    u_{1j} 
  \end{pmatrix} 
  \sim \mathcal{N}\left(
  \begin{pmatrix} 
    0 \\ 
    0 
  \end{pmatrix}, 
  \begin{pmatrix} 
    \tau_{00}^2 & \tau_{01} \\ 
    \tau_{01} & \tau_{11}^2 
  \end{pmatrix}
  \right) \\\\
  \quad & \epsilon_{ij} \sim N(0, \sigma^2)
\end{align*}

-   We are estimating six parameters where,

    -   $SBP_{ij}$ is the systolic blood pressure for individual $j$ , $j=1,...,311$ , at time $i$, $i=1,...,N$.
    -   $\gamma_{00}$ is the fixed effect for the intercept of mean SBP levels at baseline across individuals.
    -   $\gamma_{10}$ is the fixed effect for year on SBP levels.
    -   $\epsilon_{ij}$ is the within person residual error normally distributed centered at $0$ with variance of $\sigma^2$, so $\sigma^2$ is a random effect variance of individual's SBP levels around their own average SBP level.
    -   The variance-covarariance matrix, $D$, has three unique parameters:
        -   $\tau^2_{00}$ is the variance of the true baseline SBP levels, and larger values means more heterogeneity in individuals' SBP average levels.
        -   $\tau^2_{11}$ is the variance of the change rate in $\beta_{1j}$ of the true SBP levels, and larger values means that for some respondents their SBP levels grow at a faster rate and for others at a slower rate.
        -   $\tau_{01}$ is the covariance between the random intercept and random slope.

-   This distribution assumption describes our probability distribution, which defines how we expect the data to behave random.

    -   On the left side are the random intercept $u_{0j}$ and random slope $u_{1j}$ for person $j$, and is normally distributed with a mean vector $[0,0]$ centered at 0 since we are modeling deviations from the population average, and variances cannot be less than 0 but covariances can be less than 0.

4.  Interpret the model parameters estimated in part 2, including any estimated variance components. Frame your interpretations with respect to addressing the two research objectives.

-   $\gamma_{00}$ is the estimated average SBP levels mmHg at baseline fofr125.58 (95% CI: 123.65, 127.51) mmHg with a standard error of .98 .

-   $\gamma_{10}$ is the estimated slope for year representing the change rate of SBP levels, and it tells us how these levels change on average across waves points. The estimated slope of .12 (95% CI: -.02, .25: S.E. = .07) is the average change in SBP levels for every one unit increase in year, which is p\>.05, suggesting that SBP levels do not statistically significantly increase over time.

-   $\tau^2_{00}$ is the estimated variance of 203.76 for the intercept which is the spread of individuals' average SBP levels around the intercept.

-   $\tau^2_{11}$ is the estimated variance for the slope of .51 which is the spread of individual's change rate in SBP levels around the grand average slope.

-   $\sigma^2$ is the within person residual variance of 162.38 that the model does not explain.

-   $\tau_{01}$ is the covariance of `r round(attr(VarCorr(year_mod)$HHIDPN, "corr")[2], 2)` between the random intercept $\gamma_{00}$ and random slope $\gamma_{10}$.

-   The intraclass correlation in longitudinal models is the proportion of variance between individuals, or in other words how between people are different versus how different are within measurements of SBP. ICC is given as $ICC= \frac{\tau^2_0}{\tau^2_0+\sigma^2}$. The ICC was .56, or 56% of the variance in SBP is attributed to between person differences.

\newpage

5.  Briefly describe the steps that one would use to test the null hypothesis that the variance of random year effects is equal to zero, including the computation of the p-value for this test. What is the conclusion of this test as it applies to the model fit in question 2 with respect to the research objectives?

-   We fit a reduced model (with four parameters) without the random slope on year and test whether $H_0: \tau_{11}=0$, so that there is no individual variation in SBP trajectories. The alternative hypothesis, $H_A=\tau_{11} > 0$ since variance should be larger than 0. To test this hypothesis we use the likelihood ratio test (LRT) simply by $-2[\text{log likelihood}_{reduced} - \text{log likelihood}_{full}]$ to examine the difference. We use a mixture of $\chi^2$ 1 and 2 distributions to compare the full model with two random effects against a reduced model with one random effect.

```r
intercept_only <- lmer(bp_sys ~ 1  + year + (1|HHIDPN), 
                  data= hrs_wbbp_long, REML = TRUE)
```

-   Below we use a helper function to print the p-value for the LRT difference, and find a p-value \<.0001 and we reject the Null, (with $.5 \times \chi^2(1) + .5 \times \chi^2(2$ mixture) and conclude that there is strong evidence for individual variation in SBP trajectories and therefore we should keep this random slope in the model.

```r


#__________________________ helpful functions _________________________

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
               round(mixed_p_value, 7))
  )
}

#______________________________________________________________________

calculate_lrt_pvalue_fun(year_mod, intercept_only)
```

\newpage

6.  Modify the model to account for the sex and age effect on systolic blood pressure.

-   We fit the following model with centered baseline age + gender + year, and year as a random slope (with 8 parameters). This model investigates the cross sectional age effect and longitudinal age effect on SBP, and the change of SBP levels associated with gender.

```r
gender_age_year_mod <- lmer(bp_sys ~ 1  + baseline_age_c  + RAGENDER + year + 
                              (year|HHIDPN), data= hrs_wbbp_long, REML = TRUE)

summ(gender_age_year_mod, digits=3, r.squared=FALSE, confint = TRUE, 
     re.variance=getOption("summ-re.variance", c("var")))
```

\newpage

$$
\text{Level 1:}
$$

$$
SBP_{ij} = \beta_{0j} + \beta_{1j} (year_{ij}) + \epsilon_{ij}  
$$

$$
 \text{Level 2: }
$$

$$
\beta_{oj} = \gamma_{oo} + \gamma_{01}(age_{j}) + \gamma_{02}(gender_{j}) + u_{0j}
$$

$$
 \beta_{1j} = \gamma_{10} + u_{1j}
$$

$$
 \text{Combined Model}
$$

$$
SBP_{ij} = \gamma_{00} +\gamma_{01}(age_{j}) + \gamma_{02}(gender_j) + \gamma_{10}(year_{ij}) + u_{0j} + u_{ij}(year_{1j}) + \epsilon_{ij} 
$$

\newpage

7.  Interpret the fitted multilevel model from question 6 in practical terms.

-   Intercept: The mean SBP at baseline was estimated at 127.76 (95% CI: 125.31, 130.20): S.E. = 1.25) mmHg. This intercept is for male individuals at baseline age which is the reference group in this model.

-   Gender: Among females it was lower estimated at 123.90 mmHg, that is, women on average have 3.89 (S.E. = 1.49) mmHg lower levels than males while holding all other predictors constant.

-   Centered_age: The coefficient for centered age is .70 (95% CI: .39, 1.00: S.E. = .15) is the change in average SBP levels for every one unit increase in age while holding all other predictors constant.

-   Gender: The coefficient for gender

-   The longitudinal aging effect highlights SBP increases by .12 mmHg (95% CI: -.02, .25: S.E. = .07) per every one unit increase in year following baseline while holding other predictors constant. Although this was not statistically significant, p \>.05. The small effect suggest a relative stable SBP levels over time, which means that in the 16 year time frame SBP on averaged increased by 1.92 mmHg (16 years X .12).

-   The estimated between person variance in the intercepts of 171.93 (S.D. = 13.11) indicates a lot of heterogeneity across individual SBP means. The estimated variation in the SBP trajectories of .51 (S.D. = .72) is small, suggesting a similar trajectory across individuals. The correlation between baseline SBP and the rate of change was negative, -.54, suggesting that individuals with higher SBP levels tend to slightly decline over the course of the study. The estimated within person variance of 162.38 (S.D. = 12.74) around individual trajectories signals short term SBP fluctuations, and also known as measurement error.

-   The ICC was .51, or 51% of the variance in SBP is attributed to between person differences.

\

8.  How might one recode the age variable to make the parameters more interpretable? How would this recode change the interpretation of the parameters from 7? Should age and year both be included in the model (be sure to describe your reasoning)?

-   We can center age at baseline to include in the model by subtracting their age by the average age at baseline. In doing this centering, our fixed intercept can be interpreted as the value of the average age. Age and year are collinear, meaning that knowing one's age at baseline we would know their age at $t$ time point. That is, age changes with time in years, and including both time varying age and year would create perfect collinearity.

\newpage

9.  Which model (question 2 or 6) appears to have a better fit? Make use of some simple model diagnostics to help justify your choice.

-   We examine both models: model with year only which we label as the reduced model, and the second model adding gender and baseline age centered and we label as the extended model. Here we have a nested model which we will compare in different phases. First, we examine model diagnostic for both starting with the zero mean error assumption

```r
cat("The residual mean for the reduced model is . . .\n ")
summary(resid(year_mod))
cat("and for the extended model . . .\n")
summary(resid(gender_age_year_mod))
```

-   For the model with just year (top plots) we plot the residuals and QQ-plot, and the below plots correspond to the model adding age and gender. Both models show that the residual means are centered at 0. In the residual plots we do tend to see that as predicted values increase, so do the residuals. The qqplots shows several observations are outside of what we expect in both models, particularly on the higher end.

```r
#| fig-width: 6
#| fig-height: 7
#| 
resid_panel(year_mod, plots = c("resid", "qq"),   qqbands = TRUE) /
  resid_panel(gender_age_year_mod, plots = c("resid", "qq"),   qqbands = TRUE)
```

\newpage

-   The ICC as pointed out earlier are close; the reduced model was 56% and for the extended model 51%. We do note that in this case the reduced model does better at explaining the variability in SBP between persons, but only marginally. Typically, adding more variables to the model reduces $\tau_{00}$, leading to a higher ICC which we see across these two models. However, we do see that adding gender and baseline age left unexplained within variability, but the difference in ICC is still marginal at best.

-   Next, we compare fit which we print below in the ANOVA table, the Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC) for both models. The extended model has a lower AIC (e.g., slightly) and BIC than the reduced model with only year, indicating better fit when accounting for model complexity.

-   We next conduct a likelihood ratio test (LRT), which here we can use the anova function since these models are nested, $\chi^2(2) = 35.1, p<.001$. Adding gender and centered age statistically significantly improves model fit.

```r
anova(year_mod, gender_age_year_mod)
```

-   Finally, we decide that the extended model is our chosen final model based on the LRT rejecting the reduced model, and lower AIC and BIC which is desirable. We note here that the reduced model had a slightly higher ICC value.

\newpage

10. Write a ½ page summary of the methods and results of the above analyses regarding the study objectives.

We analyzed longitudinal systolic blood pressure (SBP) data from 311 participants in the Health and Retirement Study War Babies cohort , comprising 1,555 observations across 5 waves points (i.e., every 4 years) with an average of five repeated measures of SBP per individual. Given the dependency in the data due to measurements from the same individuals (e.g., repeated measures) a general linear mixed models with random intercepts and slopes was appropriate for these data and we proceeded with fitting models using restricted maximum likelihood (REML) to account for the hierarchical structure of repeated measurements within individuals. We first, proposed a simple random intercepts and slopes model with year (i.e., years since baseline measure in intervals of four years) as the only predictor in the model (e.g, fixed effects) as well as the random slope. Our final model incorporated additional cross sectional information, baseline age (i.e., centered at the mean of 58.8 years) and a level 2 fixed effect–gender. Model selection was based on likelihood ratio tests (LRT), AIC/BIC comparisons, and residual diagnostics. The final model included fixed effects for year, centered baseline age, and gender, with random intercepts and slopes for year to account for individual specific trajectories.

In the results section of the final model, we note that SBP levels showed minimal average change over time, increasing by only 0.12 mmHg per year (95% CI: -0.02, 0.25; p = 0.098), which was not statistically significant. This suggests remarkably stable population average SBP levels as participants aged over the 16-year follow-up period. Furthermore, we also observed substantial between person variance. The variance at baseline SBP $\tau^2_{00} = 171.93$ indicated considerable heterogeneity in individual baseline levels. Moreover, this represents the spread of individuals' baseline SBP levels around the population mean of 127.76 mmHg, meaning that at baseline there is considerable amount of heterogeneity among individuals. The variance in trajectories $\tau^2_{11} = 0.51$ was relatively small, suggesting similar rates of change across individuals. The within person residuals suggest fluctuation in individual's SBP measurements through their trajectories. This variation is likely due to differences in exercise levels, nutrition, medication, or stress related events that impact SBP and vary across time. The intraclass correlation of 0.51 indicated that 51% of total variance was attributable to between person differences, and gender and baseline age partially explained this variance. Women had significantly lower baseline SBP than men (3.89 mmHg lower, p = 0.009). In this model we cannot address whether this gender difference holds over time as we did not include an interaction term between gender and year. Each year of baseline age was associated with 0.70 mmHg higher SBP (p \< 0.001), highlighting a clear cross sectional age effect despite minimal longitudinal change within individuals. Our findings suggest that SBP does not necessarily increase with age. Interventions at baseline are important while identifying at risk individuals since we see from these results that maintaining a healthier SBP during midlife may have lasting benefits.
