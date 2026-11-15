---
id: "jpsm/complex_sample_data_SURV701/assignments/hw4_surv701_Linares"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Assignment 4"
original: "complex_sample_data_SURV701/assignments/hw4_surv701_Linares.qmd"
pages: 
sha256: "88eecb75d8822425ea09e9aafcd161d007dee2688006c1e5c1c3fc47b4c0b118"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:48"
---


```r
#| label: setup
#| include: false

pacman::p_load(knitr, survey, sjlabelled, tidyverse)

# set global options
options(scipen = 999, digits = 5)

data_path <- "D:/repos/UMD_classes_code/complex_sample_data_SURV701/assignments/"
```

## (1) (5 pts) Using the software of your choice, analyze the ESS-Russian Federation data set (“chapter_exercises_ess6rf”) to estimate the cross-classification of marital status (variable MARCAT, with 1 = “Married”, 2 = “Previously Married”, 3 = “Never Married”) as the row variable and voted in last election (variable VOTED_LASTELECTION, where 1 = yes and 0 = no) as the column variable. Make sure to correctly specify the same cluster variable, stratum variable, and analysis weight variable as has been used in prior assignments.

-   NOTE: I do not care which of the three test statistics you use and reference (Rao-Scott, Likelihood Ratio, or *F*) when accounting for the complex survey features, nor do I care about whether you use first-order or second-order corrections. The answer should be approximately the same for any choices.

```r

# read the ESS Russian Federation data, recode factors as needed
ess_data <- haven::read_sas(
  str_c(data_path, "chapter_exercises_ess6rf.sas7bdat")) |>
  rename_with(toupper) |> 
  mutate(
    MARCAT = factor(MARCAT, levels = 1:3,
                    labels = c("Married", "Previously Married", "Never Married")),
    VOTED_LASTELECTION = factor(VOTED_LASTELECTION, levels = 0:1,
                                labels = c("No", "Yes")),
    GNDR = factor(GNDR, levels = 1:2,
                  labels = c("Male", "Female")),
    LR3CAT = factor(LR3CAT, levels = 1:3,
                    labels = c("Left", "Moderate", "Right")),
    HEALTH = factor(HEALTH, levels = 1:5,
                    labels = c("Very Good", "Good", "Fair", "Bad", "Very Bad"))
  )
  

# Define the complex survey design (same as prior assignments)
design_full <- svydesign(
  ids = ~PSU, strata = ~STRATIFY, weights = ~PSPWGHT,
  data = ess_data, nest = TRUE
)
```

-   \(a\) What is the value of the test statistic for the overall test of the null hypothesis that marital status and voting behavior are not associated with one another? What are the degrees of freedom for this design-adjusted test statistic?

    -   We use the ESS-Russian Federation data to estimate the cross classification of marital status (MARCAT) by voted in last election (VOTED_LASTELECTION), accounting for complex survey features (PSU, STRATIFY, PSPWGHT). The Rao-Scott method (Module 7, Slide 30) adjusts the Pearson chi-square by dividing by the average design effect (GDEFF), which is the mean of the eigenvalues of a matrix formed from the design-based and SRS covariance matrices (Module 7, Slide 31):

$$
X^2_{RS} = X^2_{Pearson} / GDEFF
$$

-   The result is then converted to an approximate $F$-statistic with adjusted degrees of freedom. We plot the weighted cross tabulation for both variables.

```r
# Weighted cross-tabulation
xtab_q1 <- svytable(~MARCAT + VOTED_LASTELECTION, design_full)
```

```r
#| fig-width: 8
#| fig-height: 5
#| 
# plot the results
xtab_q1 |>
  prop.table(margin = 1) |>
  as.data.frame() |>
  ggplot(aes(x = MARCAT, y = Freq, fill = VOTED_LASTELECTION)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = scales::percent(Freq, accuracy = .1)),
            position = position_dodge(width = 0.9), vjust = -0.5) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_viridis_d(alpha = .7) +
  labs(title = "Voting Rate by Marital Status",
       x = "Marital Status", y = "Proportion", fill = "Voted") +
  theme_bw() +
  theme(legend.position = "bottom")
```

```r
# Rao-Scott F test for independence
chisq_q1 <- svychisq(~MARCAT + VOTED_LASTELECTION, design_full, statistic = "F")
chisq_q1
```

-   The Rao-Scott $F$ statistic is `r round(chisq_q1$statistic, 2)` with numerator df $\approx$ `r round(chisq_q1$parameter[1], 2)` and denominator df $\approx$ `r round(chisq_q1$parameter[2], 2)`.

-   \(b\) Under this null hypothesis, what is the *p*-value for the test statistics?

    -   The $p$-value is $< .0001$.

-   \(c\) Based on this test, what is your statistical decision regarding the association between marital status and voting behavior?

    -   We reject the null hypothesis of no association. There is strong evidence that marital status and voting behavior are significantly associated in the Russian Federation ESS population. This is consistent with expectations; for instance, married individuals may have higher voter participation than never married individuals, as suggested by the weighted proportions.

\newpage

## (2) (5 pts) Repeat all three parts of Question 1, only performing separate subpopulation/domain estimates for males/females separately, using the variable GNDR where a 1 indicates a male and 2 indicates a female.

-   NOTE: I do not care which of the three test statistics you use and reference (Rao-Scott, Likelihood Ratio, or *F*) when accounting for the complex survey features, nor do I care about whether you use first-order or second-order corrections. The answer should be approximately the same for any choices.

    -   Following Module 6 (Slide 12), we perform subpopulation analyses by gender using the `subset()` approach with the full survey design, which correctly accounts for the variance contribution of the entire sample design even when analyzing a subgroup.

```r
#| fig-width: 8
#| fig-height: 4
#| 
# run chi-square tests and build plot data in one pass
q2_results <- map(set_names(c("Male", "Female")), function(g) {
  # subset complete design by domain
  design_sub = subset(design_full, GNDR == g)
  design_sub$variables = droplevels(design_sub$variables)
  # create survey design table by domains
  xtab = svytable(~MARCAT + VOTED_LASTELECTION, design_sub)
  # fit statistic to each domain design
  list(test = svychisq(~MARCAT + VOTED_LASTELECTION, design_sub, statistic = "F"),
    props = as_tibble(prop.table(xtab, margin = 1)) |> mutate(Gender = g))
})


# plot weighted tables
map_dfr(q2_results, "props") |>
  ggplot(aes(x = MARCAT, y = n, fill = VOTED_LASTELECTION)) +
  geom_col(position = "dodge") +
  facet_wrap(~Gender) +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_viridis_d(alpha = .7) +
  labs(title = "Voting by Marital Status and Gender",
       x = "Marital Status", y = "Weighted Proportion", fill = "Voted") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "bottom")
```

```r
# print test results
walk(names(q2_results), ~{ cat("\n", .x, ":\n"); print(q2_results[[.x]]$test) })
```

```r
#| include: false
q2_male_F  <- as.numeric(q2_results$Male$test$statistic)
q2_male_ndf <- as.numeric(q2_results$Male$test$parameter[1])
q2_male_ddf <- as.numeric(q2_results$Male$test$parameter[2])
q2_fem_F   <- as.numeric(q2_results$Female$test$statistic)
q2_fem_ndf <- as.numeric(q2_results$Female$test$parameter[1])
q2_fem_ddf <- as.numeric(q2_results$Female$test$parameter[2])
```

a\) For males, the Rao-Scott $F$ = `r round(q2_male_F, 2)` with ndf $\approx$ `r round(q2_male_ndf, 2)` and ddf $\approx$ `r round(q2_male_ddf, 2)`. For females, the Rao-Scott $F$ = `r round(q2_fem_F, 2)` with ndf $\approx$ `r round(q2_fem_ndf, 2)` and ddf $\approx$ `r round(q2_fem_ddf, 2)`.

b\) Both $p$-values are $< .0001$.

c\) We reject the null hypothesis for both genders. Marital status and voting behavior are significantly associated among both males and females, with the $F$ statistic being larger for females than males, suggesting a potentially stronger association among women.

\newpage

## (3) (5 pts) Create an indicator variable of high satisfaction with life called HIGH_SAT using the STFLIFE variable, coded such that HIGH_SAT is a 1 if STFLIFE = 9 or 10, and a 0 if STFLIFE is between 0 and 8, inclusive. Any values with missing values in STFLIFE should have missing values for HIGH_SAT as well.

-   We create the indicator HIGH_SAT where 1 indicates STFLIFE = 9 or 10, and 0 otherwise. Missing values in STFLIFE are preserved as missing.

```r
# create HIGH_SAT indicator
ess_data <- ess_data |>
  mutate(HIGH_SAT = case_when(
      STFLIFE >= 9 & STFLIFE <= 10 ~ 1,
      STFLIFE >= 0 & STFLIFE <= 8  ~ 0,
      TRUE ~ NA_real_))

# rebuild design with new variable
design_full <- svydesign(
  ids = ~PSU, strata = ~STRATIFY, weights = ~PSPWGHT,
  data = ess_data, nest = TRUE)
```

-   \(a\) What proportions of the total population, males, and females in the ESS-RF survey population are estimated to have high satisfaction with life?

    -   An estimated 12.1% of the total population (13.3% males, 11.1% females) report high life satisfaction. We compute the weighted proportions using the `svyby()` function across domains taking into account the complex design.

```r
# Proportions by gender in one call
q3_by_gender <- svyby(~HIGH_SAT, ~GNDR, design_full, svymean, na.rm = TRUE, 
                      vartype = c("se", "ci"))

# Total population proportion
q3_total <- svymean(~HIGH_SAT, design_full, na.rm = TRUE)

# print results
bind_rows(
  tibble(
    Group = "Total",
    Proportion = coef(q3_total),
    SE = as.numeric(SE(q3_total)),
    Lower = confint(q3_total)[1],
    Upper = confint(q3_total)[2]),
  q3_by_gender |>
    as_tibble() |>
    rename(Group=GNDR, Proportion=HIGH_SAT, Lower=ci_l, Upper=ci_u) |>
    select(Group, Proportion, SE = se, Lower, Upper)) |>
  mutate(across(where(is.numeric), ~round(.x, 4))) |> kable()
```

-   \(b\) Compute design-based 95% CIs for each of the three proportions estimated in part a.

    -   The design-based 95% CIs for the proportion with high life satisfaction are \[.103, .140\] for the total population, \[.108, .159\] for males, and \[.091, .132\] for females. All three intervals are relatively narrow, reflecting reasonable precision. The male and female CIs overlap substantially, which is consistent with the non-significant chi-square result in part (2c). Moreover, all three intervals exclude trivially small values, indicating that roughly 10--16% of the ESS-RF population reports high life satisfaction regardless of gender.

-   \(c\) Is there a significant association between gender and high satisfaction with life?

    -   NOTE: there is more than one acceptable test statistic you can reference to base your answer to part c. For a given significance level, any of these should lead to same conclusion.
        -   We test whether gender and high life satisfaction are associated using a design-adjusted Rao-Scott $F$ test.

```r
chisq_q3c <- svychisq(~GNDR + HIGH_SAT, design_full, statistic = "F")
chisq_q3c
```

-   The Rao-Scott $F$ = `r round(chisq_q3c$statistic, 2)` with $p$ = `r round(chisq_q3c$p.value, 3)`. At $\alpha = .05$, we fail to reject the null hypothesis. There is not sufficient evidence to conclude that gender and high life satisfaction are significantly associated in the ESS-RF population.

\newpage

## (4) (5 pts) In this problem, using the software of your choice, you will use the same Russian Federation ESS data set to fit a model predicting satisfaction with government STFGOV (scaled 0 to 10, with larger values indicating higher levels of satisfaction, treated as a continuous random variable) as a function of three independent variables: (1) political leaning \[LR3CAT (1 = left to moderately left; 2 = moderate; 3 = moderately right to right\]); (2) respondent sex \[GNDR (1 = male; 2 = female)\]; and (3) self-rating of health \[HEALTH (1 = Very Good; 2 = Good; 3 = Fair; 4 = Bad; 5 = Very Bad)\]. Treat all three independent variables as categorical predictors.

-   \(a\) Fit the linear regression model as a naïve analyst would, ignoring the complex survey data features, then refit the model accounting for the complex survey data features. Fill in the table below, modifying the rows as necessary (will depend on how you or the software defaults parameterize the independent variables).

    -  From Module 9 (Slide 14), the $t$-test for individual coefficients in the design-based setting uses $df = \text{\#clusters} - H$, where $H$ is the number of strata. This design df is a property of the sample design, not the fitted model — unlike the OLS $n - p$ convention, no further subtraction is made for the number of estimated parameters. The full ESS-RF design has 184 PSUs across 8 strata (design $df = 176$), but listwise deletion of missing values (primarily from LR3CAT) drops one cluster from the variance estimation, leaving 183 PSUs across 8 strata for the complete cases. The reference $t$-distribution for the test of the GNDR coefficient therefore has $df = 183 - 8 = 175$.


```r
# Rebuild design
design_full <- svydesign(
  ids = ~PSU, strata = ~STRATIFY, weights = ~PSPWGHT,
  data = ess_data, nest = TRUE)

# naive OLS model ignoring survey features
naive_model <- lm(STFGOV ~ LR3CAT + GNDR + HEALTH, data = ess_data)

# complex survey model
svy_model <- svyglm(STFGOV ~ LR3CAT + GNDR + HEALTH, design = design_full)

# extract coefficients and SEs
naive_coef <- coef(summary(naive_model))
svy_coef <- coef(summary(svy_model))

# fill in table
comparison_table <- tibble(
  Parameter = rownames(naive_coef),
  Est_Naive = naive_coef[, "Estimate"],
  SE_Naive = naive_coef[, "Std. Error"],
  Est_Complex = svy_coef[, "Estimate"],
  SE_Complex = svy_coef[, "Std. Error"],
  SE_Ratio_Sq = (svy_coef[, "Std. Error"] / naive_coef[, "Std. Error"])^2)

comparison_table |>
  mutate(across(where(is.numeric), ~round(.x, 4))) |>
  kable(col.names = c(
    "Parameter", "Est (Naive)", "SE (Naive)",
    "Est (Complex)", "SE (Complex)", "[SE(Complex)/SE(Naive)]^2"))
```

-   \(b\) Using the complex survey version of the model, plot a distribution of the residuals and comment on whether or not it appears to follow a normal distribution.

    -   The residual distribution appears approximately normal, with a slight tendency toward symmetry centered near zero. The overlay of the normal density curve (red) suggests that the normality assumption is not severely violated. This is adequate for the large sample sizes involved.

```r
#| fig-height: 4
#| fig-width: 6

resids <- residuals(svy_model)

tibble(residual = resids) |>
  ggplot(aes(x = residual)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40,
                 fill = "dodgerblue", color = "white", alpha = .7) +
  stat_function(fun = dnorm,
                args = list(mean = mean(resids), sd = sd(resids)),
                color = "red", linewidth = 1) +
  labs(title = "Distribution of Residuals from Complex Survey Design",
       x = "residual", y = "density") +
  theme_bw()
```

-   \(c\) Under the complex survey version of the model, what is the degrees of freedom for the reference *t* distribution in the test of whether the one non-reference parameter for GNDR is significantly different from 0?

    -   From Module 9 (Slide 14), the t-test for individual coefficients uses $df = \text{\#clusters} - H$, where $H$ is the number of strata. Due to listwise deletion of missing values (e.g., primarily from LR3CAT), the model uses `r nobs(svy_model)` complete cases across 183 PSUs and 8 strata. The design $df$ for complete cases is $183 - 8 = 175$. The model has $p - 1 = 7$ non-intercept parameters, so the residual $df = 175 - 7 = 168$. This is the degrees of freedom for the reference $t$-distribution used in the test of whether the GNDR parameter is significantly different from 0.

```r
cat("Design df:", degf(svy_model$survey.design), "\n")
```

-   \(d\) Using the complex survey version of the model, test whether the model can be reduced by simultaneously eliminating all terms related to both GNDR and HEALTH.

    -   Module 9 (Slide 15) describes the partial Wald $F$-test for simultaneously testing whether a subset of coefficients $\boldsymbol{\beta}_2 = \mathbf{0}$:

$$
F_{W, \text{partial}} = \frac{\hat{B}_2^T \hat{\Sigma}(\hat{B}_2)^{-1} \hat{B}_2}{p_2}
$$

-   We test $H_0$: all GNDR and HEALTH parameters are simultaneously zero (i.e., the model can be reduced to only LR3CAT).

```r
wald_q4d <- regTermTest(svy_model, ~ GNDR + HEALTH)
wald_q4d
```

-   The Wald $F$ = `r round(wald_q4d$Ftest, 4)` on `r wald_q4d$df` and `r wald_q4d$ddf` $df$, with $p$ = `r round(wald_q4d$p, 3)`. At $\alpha = .05$ we fail to reject $H_0$, suggesting that the model can be reduced by simultaneously removing GNDR and HEALTH. The combined contribution of gender and health status to predicting government satisfaction is not statistically significant under the complex survey design, leaving political leaning as the primary significant predictor.
