---
id: "jpsm/complex_sample_data_SURV701/final/final_surv701_Linares"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Final Exam - SURV701"
original: "complex_sample_data_SURV701/final/final_surv701_Linares.qmd"
pages: 
sha256: "9f816c7de555f8b6eeb846686238cec2f76556de685934f7bfd66c9f73de1347"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:50"
---


```r
#| label: setup
#| include: false

pacman::p_load(knitr, survey, srvyr, Practools, viridis, 
               mice, broom, haven, tidyverse)

# set global options
options(scipen = 999, digits = 5)

data_path <- "D:/repos/UMD_classes_code/complex_sample_data_SURV701/final/"
```

### [Instructions]{.underline}: This is an open book, open notes test. Clearly label your final answer(s). Where applicable, show your work, so that you may earn partial credit. All work should be your own. You may ask the instructor questions, but do not discuss with your classmates.

### 1. Any reputable survey releasing data to the public will also provide sufficient user documentation about the survey (e.g., details on the questionnaire, description of data collection methods) and the data set(s) made available for analysis (e.g., codebook, SAS/R/Stata input statements, example code for common analyses). Prior to analyzing survey data you are not already accustomed to, it is imperative to peruse the available documentation to gain a better understanding of the file structures and whether complex survey data features are present. The purpose of this first exercise is to give you some experience doing that.

\newpage

**1a. (1 pt) A colleague asks for your assistance analyzing health indicators of the U.S. general population using the Sample Adult File of the 2015 National Health Interview Survey (<https://archive.cdc.gov/#/details?url=https://www.cdc.gov/nchs/nhis/nhis_2015_data_release.htm>). Based on the documentation and whatever else you can find on the website or by searching the Internet, does this data set include any complex survey features she should account for? If so, what are the variable names associated with those features? Provide just one variable name for each feature.**

-   The 2015 NHIS Sample Adult File has all three complex survey features. NCHS masks the true design variables for confidentiality and releases pseudo-versions for public use, as described in the 2015 NHIS Survey Description. From the Sample Adult file layout (samadult_layout.pdf). Stratification variable `STRAT_P` (pseudo-stratum for public use file variance estimation), clustering variable `PSU_P` (pseudo-PSU for public use file variance estimation), and unequal weights `WTFA_SA` (Final Annual Sample Adult Weight) are all complex survey features that are important to account for.

\

**1b. (1 pt) The same colleague asks for your assistance estimating vaccination rates (excluding U.S. Territories) from the 2014 National Immunization Survey (<https://www.cdc.gov/nchs/nis/data_files.htm>). Based on the documentation and whatever else you can find on the website or by searching the Internet, does this data set include any complex survey features she should account for? If so, what are the variable names associated with those features? Provide just one variable name for each feature. NOTE: vaccination rates come from the records of medical providers during a second stage of data collection, conditional upon parent/guardian consent at the end of the first stage of data collection.**

-   From the 2014 NIS Data User's Guide, we determine that there are three complex survey features; stratification `STRATUM` (combination of estimation area and sampling frame, landline vs cell), clustering `SEQNUMHH` (coded household identifier, which the Guide names alongside STRATUM as a key variable for obtaining standard errors), Unequal weights: `PROVWT_D` (provider-phase weight for the U.S. excluding Puerto Rico, for children with adequate provider data, PDAT=1). The `PROVWT_D` weight is the right choice for vaccination rates because it has already been adjusted for provider phase nonresponse, which is the conditional second stage consent step the question mentions.

\newpage

#### **2. (1 pt) The Federal Employee Viewpoint Survey (<https://www.opm.gov/fevs/about/>) is an organizational climate survey of United States government employees administered annually by the U.S. Office of Personnel Management. The sample design results in three features of complex survey data: stratification, finite population corrections, and unequal weights. Due to concerns over respondent confidentiality, however, the analysis file released to the public omits the stratum identifier and the stratum totals (i.e.,** $N_h$'s) needed to account for the finite population corrections. Only the weight variable (POSTWT) is included.

**Suppose a researcher is using the public file to formulate government wide estimates. Would you expect point estimates to differ relative to what would be found using the non-public version accounting for the two omitted features? What about measures of variability? Explain in a sentence or two.**

-   Point estimates will be identical. Weighted means, totals, and proportions are fully determined by the weight POSTWT, which the public file retains, and do not depend on the stratum identifier or the $N_h$ totals. Variability estimates will differ. Dropping the stratum identifier will force the software to treat the sample as a single stratum and lose the variance reduction from stratification, since the between stratum component drops out only when strata are declared. Dropping the $N_h$ totals means no FPC so the variance estimator omits the ($1 - n_h/N_h$) factor and behaves as the with replacement approximation. Both omissions push the variance estimate upward, so standard errors from the public file are conservative relative to what the non public file would produce.

\newpage

**3. In this problem, you will analyze data from the 2015-2016 National Health and Nutrition Examination Survey (NHANES). A subset of columns from the publicly released data has been posted to Canvas as CSV/SAS data sets called NHANES_2015_2016. For each question below, copy/paste your code and the pertinent output. Be sure to account for the three complex survey features of the data, which are stratification (variable SDMVSTRA), clustering (variable SDMVPSU), and unequal weights (variable WTMEC2YR). Other variables are given below.**

```r
#| echo: false
tibble(
  Variable = c("LBXTC", "RIAGENDR", "DMDCITZN", "RIDRETH3", "DMDMARTL", "RIDAGEYR", "DMDHHSZE"),
  Description = c(
    "Total cholesterol reading",
    "Respondent gender",
    "U.S. Citizenship status",
    "Respondent race/ethnicity",
    "Respondent marital status",
    "Respondent age",
    "Household size"
  ),
  `Coding Structure` = c(
    "Continuous, in mg/DL",
    "1 = Male, 2 = Female (reference)",
    "1 = Citizen by birth or naturalization, 2 = Not a citizen of the U.S. (reference)",
    "1 = Mexican American, 2 = Other Hispanic, 3 = Non-Hispanic White, 4 = Non-Hispanic Black, 6 = Non-Hispanic Asian, 7 = Other Race - Including Multi-Racial (reference)",
    "1 = Married, 2 = Widowed, 3 = Divorced, 4 = Separated, 5 = Never married, 6 = Living with partner (reference)",
    "Integer, number of years old",
    "Integer, number of individuals living in the household"
  )
) |>
  kable(booktabs = TRUE) |>
  kableExtra::column_spec(1, width = "1in") |>
  kableExtra::column_spec(2, width = "1.5in") |>
  kableExtra::column_spec(3, width = "3in")
```

**3a. (1 pt) Conduct two recodes in the data set: (1) if DMDMARTL is missing or NOT between 1 and 6, reset the value of DMDMARTL to 5; and (2) if DMDCITZN is not a 1 or 2, reset the value of DMDCITZN to missing.**

```r
#| label: load-nhanes

# read NHANES, apply Q3a recodes in the same mutate, set reference factor levels
nhanes <- read_csv(
  str_c(data_path, "NHANES_2015_2016.csv"),
  show_col_types = FALSE) |>
  mutate(
    # 3a recode (1) + factor with reference category first: 
    # if DMDMARTL is missing or not 1-6, reset to 5
    DMDMARTL = factor(
      if_else(is.na(DMDMARTL) | !between(DMDMARTL, 1, 6), 5, DMDMARTL),
      levels = c(6, 1, 2, 3, 4, 5),
      labels = c("Living w/ partner", "Married", "Widowed",
                 "Divorced", "Separated", "Never married")),
    # 3a recode (2) + factor: if DMDCITZN is not 1 or 2, reset to missing
    DMDCITZN = factor(
      if_else(!between(DMDCITZN, 1, 2), NA_real_, DMDCITZN),
      levels = c(2, 1),
      labels = c("Not a citizen", "Citizen")),
    # these two just need factor conversion, no recoding
    RIAGENDR = factor(RIAGENDR, levels = c(2, 1),
                      labels = c("Female", "Male")),
    RIDRETH3 = factor(RIDRETH3, levels = c(7, 1, 2, 3, 4, 6),
                      labels = c("Other/Multi", "Mex Am", "Other Hispanic",
                                 "NH White", "NH Black", "NH Asian"))
  )
```

-   Both recodes were applied during data load. The resulting distributions:

```r
#| label: q3a-checks
#| echo: false


nhanes |> count(DMDMARTL) |> 
  kable(caption = "DMDMARTL after recode (5 = Never married absorbs missings and out-of-range)")

nhanes |> count(DMDCITZN) |>
  kable(caption = "DMDCITZN after recode (non-1/2 values set to NA)")
```

## 

\newpage

**3b. (2 pts) Find the mean value of LBXTC for citizens and non-citizens. Carry out a two-sided hypothesis for whether the difference between those two means is statistically significant. What is your conclusion?**

```r
#| label: q3b-design

# complex survey design using srvyr
design_nhanes <- nhanes |>
  as_survey_design(ids = SDMVPSU, strata = SDMVSTRA,
                   weights = WTMEC2YR, nest = TRUE)

# mean LBXTC by citizenship
means_by_cit <- design_nhanes |>
  filter(!is.na(LBXTC), !is.na(DMDCITZN)) |>
  group_by(DMDCITZN) |>
  summarize(
    n_unw = unweighted(n()),
    mean_LBXTC = survey_mean(LBXTC, na.rm = TRUE, vartype = "ci")
  )


```

```r
#| echo: false
means_by_cit |> kable(caption = "Mean total cholesterol by citizenship status")

```

-   The LBXTC, or cholesterol means for non citizens and citizens are 189.3 and 185.6 respectively.

```r

# two-sided svyttest for the difference in means
ttest_cit <- svyttest(LBXTC ~ DMDCITZN, design = design_nhanes)
ttest_cit

design_df <- degf(design_nhanes)
```

```r
#| include: false

# pre-compute values so inline R works in the PDF parser
t_stat <- as.numeric(ttest_cit$statistic)
t_df   <- as.numeric(ttest_cit$parameter)
t_p    <- as.numeric(ttest_cit$p.value)
mean_diff <- as.numeric(ttest_cit$estimate)
```

-   The design based two-sided t-test yields t = `r round(t_stat, 3)` on `r round(t_df, 0)` df (p = `r format.pval(t_p, digits=4)`), with an estimated mean difference of `r round(mean_diff, 3)` between citizens and non-citizens. At $\alpha = 0.05$ we fail to reject the null hypothesis of no statistical difference. The p-value is borderline and the non-citizen group has a slightly higher sample mean cholesterol, but the evidence is not strong enough at conventional levels to conclude the two citizenship groups differ in mean total cholesterol.

\newpage

**3c. (2 pts) Using the software of your choice, fit a linear regression model accounting for the complex survey sample predicting LBXTC as a function of the respondent's age, household size, gender, marital status, citizenship status, and race/ethnicity. Treat all variables except for age and household size as categorical variables and set the reference category based on the code in table above with reference given in parentheses next to it. Produce a table of the parameters, standard errors, and results of the parameter-specific significance tests.**

-   Reference categories are set as RIAGENDR = Female, DMDCITZN = Not a citizen, RIDRETH3 = Other/Multi (code 7), DMDMARTL = Living with partner (code 6). The table below shows parameter estimates, standard errors, the t-statistic, and two p-value columns. The "p (svyglm default)" column uses R's internal residual df, which collapses to approximately `r design_df - 14` for this 15-coefficient model, producing inflated p-values that understate significance. The "p (design df)" column recomputes the reference t-distribution against $df = n_{\text{PSU}} - H =$ `r design_df`, which matches how PROC SURVEYREG reports coefficient level p-values natively. Significance at $\alpha = 0.05$ should be judged from the design df column.

```r
#| label: q3c-svyglm

svy_lm_tsl <- svyglm(
  # outome ~ predictors
  LBXTC ~ RIDAGEYR + DMDHHSZE + RIAGENDR + DMDMARTL + DMDCITZN + RIDRETH3,
  design = design_nhanes
)


# broom::tidy() gives the svyglm default p-values against residual df
# we add a column with p-values recomputed against design df 

q3c_tbl <- broom::tidy(svy_lm_tsl) |>
  rename(p_value_svyglm = p.value) |>
  mutate(
    p_value_design_df = 2 * pt(abs(statistic), 
                               df = design_df, lower.tail = FALSE),
    across(where(is.numeric), ~round(.x, 4)))

```

\newpage

```r
#| echo: false

q3c_tbl |>
  kable(
    caption = "Survey-weighted linear regression, Taylor linearization",
    col.names = c("Term", "Estimate", "Std. Error", "t statistic",
                  "p (svyglm default)", "p (design df)")
  )
```

\newpage

**3d. (1 pt) Using the balanced repeated replication approach, refit the model in 3c and recreate the table. Are point estimates equivalent with the two approaches? What about standard errors and the significance test results? Is this what you would expect? Explain your reasoning in a sentence or two.**

NHANES is released with Taylor-linearization design variables only (SDMVSTRA, SDMVPSU). Since NHANES has exactly 2 PSUs per stratum, we can construct BRR replicate weights from the Taylor design using a Hadamard-balanced half-sample assignment.

```r
#| label: q3d-brr

design_brr <- as.svrepdesign(design_nhanes, type = "BRR")

svy_lm_brr <- svyglm(
  LBXTC ~ RIDAGEYR + DMDHHSZE + RIAGENDR + DMDMARTL + DMDCITZN + RIDRETH3,
  design = design_brr
)

design_df_brr <- degf(design_brr)


# recompute p-values against the same design df as in 3c 
q3d_tbl <- broom::tidy(svy_lm_brr) |>
  rename(p_value_svyglm = p.value) |>
  mutate(
    p_value_design_df = 2 * pt(abs(statistic), 
                               df = design_df_brr, lower.tail = FALSE),
    across(where(is.numeric), ~round(.x, 4)))
```

\newpage

```r
#| echo: false

q3d_tbl |>
  kable(
    caption = "Survey-weighted linear regression, BRR",
    col.names = c("Term", "Estimate", "Std. Error", "t statistic",
                  "p (svyglm default)", "p (design df)")
  )

```

```r
#| echo: false

# comparison for commentary
comparison <- tibble(
  term    = q3c_tbl$term,
  est_TSL = q3c_tbl$estimate,
  est_BRR = q3d_tbl$estimate,
  se_TSL  = q3c_tbl$std.error,
  se_BRR  = q3d_tbl$std.error,
  p_TSL   = q3c_tbl$p_value_design_df,
  p_BRR   = q3d_tbl$p_value_design_df
)

comparison |> 
  kable(caption = "TSL vs BRR: estimates, SEs, and p-values")

```

-   Point estimates are identical for both approaches and only the variance estimator changes. Standard error ratios across the 15 coefficients are near 1.0, and significance conclusions agree exactly as both flag RIDAGEYR, DMDHHSZE, RIAGENDR, DMDMARTL (Widowed and Never married), and DMDCITZN as significant at $\alpha = 0.05$. This is expected since TSL and BRR are asymptotically equivalent under stratified two PSU per-stratum designs.

\newpage

**3e. (1 pt) Suppose someone reviewing your work and the model you fit asked you to evaluate whether the effect of RIDEAGEYR was non-linear on the predicted value of LBXTC. How would you respond and/or what steps would you take? Only looking for a few sentences here about how you would approach that problem.**

-   I would take the following three steps. First, I would plot residuals from the current model against RIDAGEYR and overlay a LOESS smoother to look for systematic curvature. Residual versus predictor plots are the standard diagnostic for detecting non-linearity. Second, I would refit the model with a quadratic term in RIDAGEYR, and use `regTermTest()` to conduct the partial Wald F-test on the quadratic coefficient to see whether it adds anything beyond the linear fit. Third, I would compare predicted versus age curves between the two specifications. If the quadratic is jointly significant and the curves meaningfully diverge, I would report the non-linear version.

\

**3f. (2 pts) Using the model from 3c, test whether all coefficients representing the effect of RIDRETH3 are simultaneously equal to 0. What is the conclusion of this test?**

-   The partial Wald F-test for a subset of coefficients $\boldsymbol{\beta}_2 = \mathbf{0}$ is:

$$F_{W,partial} = \frac{\hat{\boldsymbol{\beta}}_2^T \, \widehat{\Sigma}(\hat{\boldsymbol{\beta}}_2)^{-1} \, \hat{\boldsymbol{\beta}}_2}{p_2}$$

```r
#| label: q3f-wald

# use design df = #PSUs - #strata
design_df <- degf(design_nhanes)

wald_race <- regTermTest(svy_lm_tsl, ~RIDRETH3, df = design_df)
wald_race
```

```r
#| include: false

wald_F <- as.numeric(wald_race$Ftest)
wald_p <- as.numeric(wald_race$p)
```

-   The joint Wald F-test for the five RIDRETH3 contrast parameters, evaluated against design df = `r design_df` (#PSUs - #strata), yields F = `r round(wald_F, 3)` with p = `r format.pval(wald_p, digits=4)`. At $\alpha = 0.05$ we reject the null that all five race/ethnicity contrasts are simultaneously zero, so race/ethnicity is a significant predictor of total cholesterol in this model.

\newpage

**3g. (1 pt) Using the model from 3c, find the expected total cholesterol for a 50-year-old, non-Hispanic Black, married female, who is a U.S. citizen living in a household with a total of 2 individuals.**

```r
#| label: q3g-predict

# create respondent
profile_3g <- tibble(
  RIDAGEYR = 50,
  DMDHHSZE = 2,
  RIAGENDR = factor("Female", levels = levels(nhanes$RIAGENDR)),
  DMDMARTL = factor("Married", levels = levels(nhanes$DMDMARTL)),
  DMDCITZN = factor("Citizen", levels = levels(nhanes$DMDCITZN)),
  RIDRETH3 = factor("NH Black", levels = levels(nhanes$RIDRETH3))
)

# make prediction on new respondent
pred_3g <- predict(svy_lm_tsl, newdata = profile_3g, type = "response")


```

```r
#| echo: false

tibble(
  profile = "50yo, NH Black, married, female, citizen, HH size 2",
  predicted = as.numeric(pred_3g),
  SE= as.numeric(SE(pred_3g))) |>
  kable(caption = "Predicted total cholesterol (mg/dL)")

```

-   For this repondent, the expected total cholestoral is 181.41 (SE=2.86).

\newpage

#### **4. In this problem, a logistic regression model was fit to data from the 2015 National Health Interview Survey (NHIS). The likelihood of having been diagnosed with hypertension (HYPTSN) was modeled as a function of continuous variables respondent age in years (AGE_P), annual income in thousands of dollars (INCM), body mass index (BMI1), smoking status (SMK_ST1, treated as continuous even though technically ordinal), and average sleep time in hours/day (SLP_TM), and categorical variables sex (SEX), region (REGION), and race/ethnicity (RACE_ETH). The table below summarizes codes and reference categories of the categorical variables. A table of model parameters is given thereafter.**

+---------------------------------------------------------------------------------------------------------------------------------+
| Coding                                                                                                                          |
+=================================================================================================================================+
| SEX: 0 = Male, 1 = Female (**reference**)                                                                                       |
+---------------------------------------------------------------------------------------------------------------------------------+
| RACE_ETH (Race/ethnicity): 1 = Non-Hispanic White (**reference**), 2 = Non-Hispanic Black, 3 = Non-Hispanic Other, 4 = Hispanic |
+---------------------------------------------------------------------------------------------------------------------------------+
| REGION: 1 = Northeast, 2 = Midwest, 3 = South, 4 = West (**reference**)                                                         |
+---------------------------------------------------------------------------------------------------------------------------------+
| SMK_ST1 (Smoking level): 0 = Non-smoker, 1 = Former smoker, 2 = Smoker, 3 = Heavy smoker                                        |
+---------------------------------------------------------------------------------------------------------------------------------+
| HYPTSN: 1 = Yes, 2 = No (**reference**)                                                                                         |
+---------------------------------------------------------------------------------------------------------------------------------+

![](images/clipboard-1169930829.png){width="528"}

\newpage

**4a. (1 pt) Fill in the blanks using one of the four choices provided. From the table of estimated model parameters above, the effect of average sleep time on the likelihood of a hypertension diagnosis is \_\_\_\_\_ and the effect of race/ethnicity on the likelihood of a hypertension diagnosis is \_\_\_\_\_.**

-   A. Significant; Significant
-   B. Significant; Insignificant
-   C. **Significant; Cannot be determined from table**
-   D. Cannot be determined from table; Cannot be determined from table

**C:** SLP_TM has a single coefficient (t = -3.00, p = .0029), so the significance of the sleep-time effect can be read directly from its individual t-test, and it is significant at $\alpha = 0.05$. RACE_ETH is a three-level categorical contrast against the reference. The individual t-tests tell us about each contrast separately (level 2 vs White is significant, levels 3 and 4 vs White are not), but a statement about the overall effect of race/ethnicity requires a joint Wald or F-test that all three contrast coefficients equal zero simultaneously. That joint test is not shown in the table, so we cannot determine the overall significance from the table alone.

\

**4b. (1 pt) Based on information contained in the table of estimated model parameters above, if the number of respondent records in the NHIS data set is 16,571 and the number of unique PSU codes is 322, then the number of unique stratum codes in the data set must be:**

-   A. **22**
-   B. 300
-   C. 322
-   D. Cannot be determined

**A:** The design degrees of freedom for t-tests of individual coefficients under a stratified multi-stage design is $df = \#\text{PSUs} - \#\text{strata}$. The note below the table states df = 300, and the problem gives 322 PSUs. Solving $322 - H = 300$ gives $H = 22$ strata.

\newpage

**4c. (2 pts) If all other variables are held constant, what is the estimated odds ratio for a hypertension diagnosis associated with two individuals, one who is 10 years older than the other? Using 1.96 as the critical value, compute a 95% CI for this odds ratio.**

-   The odds ratio for a c-unit change in a continuous predictor is $\exp(c \cdot \hat{\beta})$, with 95% CI $\exp(c \cdot \hat{\beta} \pm 1.96 \cdot c \cdot \widehat{SE}(\hat{\beta}))$.

```r
#| label: q4c-or

beta_age <- .0661
se_age <- .00210
c_val <- 10

log_or <- c_val * beta_age
se_log_or <- c_val * se_age

or_10yr <- exp(log_or)
or_ci_lo <- exp(log_or - 1.96 * se_log_or)
or_ci_hi <- exp(log_or + 1.96 * se_log_or)

```

```r
#| echo: false

tibble(
  quantity = c("log-OR (10 yr)", "SE(log-OR)",
               "OR (10 yr)", "95% CI lower", "95% CI upper"),
  value    = c(log_or, se_log_or, or_10yr, or_ci_lo, or_ci_hi)
) |>
  mutate(value = round(value, 4)) |>
  kable(caption = "Odds ratio for a 10-year age increment")

```

-   Holding everything else constant, the estimated odds of a hypertension diagnosis for an individuals 10 years older are approximetly `r round(or_10yr, 2)` times the odds for the younger individual (95% CI: `r round(or_ci_lo, 2)`, `r round(or_ci_hi, 2)`).

\newpage

#### 5. Between December 9, 2015 and January 15, 2016, the U.S. Office of Personnel Management administered the Federal Employee Benefits Survey (FEBS) to a simple random sample (SRS) of $n = 40{,}000$ of the $N = 1{,}820{,}483$ full-time, permanent, civilian employees on board as of the end of July 2015. The survey contained a variety of behavioral and attitudinal items regarding participation and satisfaction with various benefit plans, such as the Federal Employee Health Benefits Program (FEHBP, the array of health insurance offerings) and the Thrift Savings Plan (TSP, the government equivalent to a 401(k) plan).

At survey close, a total of $r = 9{,}089$ responses were obtained, corresponding to a response rate of $9{,}089 / 40{,}000 = 22.7\%$. However, for purposes of developing the final report (<https://www.opm.gov/policy-data-oversight/data-analysis-documentation/employee-surveys/2016-federal-employee-benefits-survey-results.pdf>) no nonresponse adjustment methods were undertaken. That is, the implicit assumption was that data were missing completely at random (MCAR). The aim of this final question is to retroactively assess whether that assumption was appropriate or not.

The table below summarizes the variables in the data set FEBS, which has been posted to the “Final Exam” folder on Canvas. Note that this is data for the sample of *n* = 40,000 employees. You can think of the auxiliary variables to be those numbered 2 – 7. The outcome variable of interest subject to missingness is variable 10.

+------------+--------------+------------------------------+-----------------------------------------+
| **No.**    | **Variable** | **Description**              | **Coding Structure**                    |
+============+==============+==============================+=========================================+
| 1          | EMPID        | Unique Employee Identifier   | Seven digits beginning around 1000000   |
+------------+--------------+------------------------------+-----------------------------------------+
| 2          | AGENCY       | Two-Digit Agency Identifier  | AG = Agriculture                        |
|            |              |                              |                                         |
|            |              |                              | DD = Defense                            |
|            |              |                              |                                         |
|            |              |                              | DJ = Justice                            |
|            |              |                              |                                         |
|            |              |                              | HE = Health and Human Services          |
|            |              |                              |                                         |
|            |              |                              | HS = Homeland Security                  |
|            |              |                              |                                         |
|            |              |                              | TR = Treasury                           |
|            |              |                              |                                         |
|            |              |                              | VA = Veterans Affairs                   |
|            |              |                              |                                         |
|            |              |                              | XX = All Other Agencies                 |
+------------+--------------+------------------------------+-----------------------------------------+
| 3          | SUPER        | Supervisory Status Indicator | N = Non-supervisor, Y = Supervisor      |
+------------+--------------+------------------------------+-----------------------------------------+
| 4          | SALARY_GROUP | Salary Grouping              | 1=\<50k, 2=50-100k, 3=100-150k, 4=150k+ |
+------------+--------------+------------------------------+-----------------------------------------+
| 5          | AGE_GROUP    | Age Grouping                 | 1=\<40, 2=40-49, 3=50-59, 4=60+         |
+------------+--------------+------------------------------+-----------------------------------------+
| 6          | SEX          | Gender                       | M = Male, F = Female                    |
+------------+--------------+------------------------------+-----------------------------------------+
| 7          | MINORITY     | Minority Indicator           | N = No, Y = Yes                         |
+------------+--------------+------------------------------+-----------------------------------------+
| 8          | RESPONDED    | Response Indicator           | 0 = Nonrespondent, 1 = Respondent       |
+------------+--------------+------------------------------+-----------------------------------------+
| 9          | WEIGHT       | Base Weight, $N/n$           | $1{,}820{,}483 / 40{,}000 = 45.512$     |
+------------+--------------+------------------------------+-----------------------------------------+
| 10         | Q4           | FEHBP Enrollment Indicator   | 1 = Yes, 2 = No                         |
+------------+--------------+------------------------------+-----------------------------------------+

\newpage

```r
#| label: load-febs
# read in the febs dataset and recode variables to factors w/ labels
febs <- read_csv(str_c(data_path, "febs.csv"), show_col_types = FALSE) |>
  mutate(
    agency = factor(agency),
    super = factor(super, levels = c("N", "Y"),
                          labels = c("Non-supervisor", "Supervisor")),
    salary_group = factor(salary_group, levels = 1:4,
                          labels = c("<50k", "50-100k", "100-150k", "150k+")),
    age_group = factor(age_group, levels = 1:4,
                          labels = c("<40", "40-49", "50-59", "60+")),
    sex = factor(sex, levels = c("M", "F"),
                          labels = c("Male", "Female")),
    Minority = factor(Minority, levels = c("N", "Y"),
                          labels = c("Non-minority", "Minority")))

N_pop <- 1820483 # given to us
n_samp <- febs |> nrow() # sample size
r_resp <- febs |> filter(responded==1) |> nrow() # respondents
overall_rr <- r_resp / n_samp
```

**5a. (1 pts) The first step in assessing whether the MCAR assumption is plausible is to compare and contrast response rates by the various categories of variables in X (e.g., males vs. females, non-supervisors vs. supervisors). Using the 0/1 RESPONDED variable, create a table summarizing the marginal response rates of the categories of each auxiliary variable.**

```r
#| label: q5a-rr

# variables we will use as x
aux_vars <- c("agency", "super", "salary_group", "age_group", "sex", "Minority")

# create function to loop through variables of interest
rr_table <- map_dfr(aux_vars, function(v) {
  febs |>
    # group by variable & compute RR
    group_by(.data[[v]]) |>
    reframe(
      n = n(),
      respondents = sum(responded),
      response_rate = mean(responded)
    ) |>
    # build columns for table
    transmute(
      variable = v,
      category = as.character(.data[[v]]),
      n = n,
      respondents = respondents,
      response_rate = round(response_rate, 4))
})
```

-   We generate a table of response rates by auxiliary variables as well as plot them with the overall RR represendted by a red vertical dash line.

```r
#| echo: false
#| fig-width: 10
#| fig-height: 5.25

rr_table |> kable(caption = "Marginal response rates by auxiliary variable")

rr_table |>
  ggplot(aes(x = response_rate, y = fct_reorder(category, response_rate),
             fill = variable)) +
  geom_col() +
  geom_text(aes(label = scales::percent(response_rate, accuracy = 0.1)),
            hjust = -0.1, size = 3) +
  geom_vline(xintercept = overall_rr, linetype = "dashed", color = "red") +
  facet_wrap(~variable, scales = "free_y") +
  scale_x_continuous(labels = scales::percent,
                     expand = expansion(mult = c(0, 0.15))) +
  scale_fill_viridis_d(option = "D") +
  labs(
    title = str_c("Response rates by auxiliary variable (overall RR = ",
                  round(overall_rr * 100, 1), "%)"),
    x = "response rate", y = NULL) +
  theme_minimal() +
  theme(legend.position = "none")
```

\newpage

**5b. (1 pt) Based on the table produced in Question 1, do you think the MCAR assumption is plausible or not? Which variables are of most concern?**

-   MCAR is not plausible here. The marginal response rates vary substantially across categories of several auxiliary variables, which is exactly what MCAR would rule out. AGE_GROUP shows the widest spread (15% among the youngest employees rising to roughly 29% among those 60 and over), followed by AGENCY (16% at DD to roughly 36% at TR). SALARY_GROUP, SUPER, SEX, and MINORITY also all show meaningful between category differences (roughly 5 percentage points each) that go well beyond what sampling noise around the 22.7% overall rate would produce. Under MCAR, we would expect these cross category response rates to differ only by sampling noise around the overall 22.7%, so essentially all of these auxiliary variables are candidates for an imputation model.

**5c. (2 pts) Suppose a parameter of interest in this survey is the total number of FEHBP enrollees. One crude estimator of this quantity, which would be unbiased if data were MCAR, is** $N\hat{p}$, where $N$ is the total number of employees in the population (1,820,483) and $\hat{p}$ is the estimated proportion of survey respondents indicating they are enrolled in FEHBP (i.e., Q4=1). Note that the estimated variance for this estimator is $N^2 var(\hat{p})$, and its standard error is the square root of that quantity. Find $\hat{p}$ and $var(\hat{p})$, and then find $N\hat{p}$ and its standard error to formulate a 95% confidence interval, using 1.96 as the critical value. NOTE: because this is a simple random sample with a common base weight, you technically do not need to specify any complex survey features with specialized software.

-   Under SRS of $r = 9{,}089$ respondents with a binary outcome gives:

$$\hat{p} = \frac{1}{r}\sum_{i=1}^{r} y_i, \qquad {var}(\hat{p}) = \frac{\hat{p}(1-\hat{p})}{r-1}.$$

-   The total estimator and its variance follow from the scaling identity:

$$\hat{T} = N\hat{p}, \qquad var(\hat{T}) = N^2 \cdot var(\hat{p}), \qquad SE(\hat{T}) = N \cdot \sqrt{var(\hat{p})}.$$

```r
#| label: q5c-mcar

# restrict to respondents, compute proportion enrolled (Q4 == 1)
q5c_results <- febs |>
  filter(responded == 1) |>
  reframe(
    r_resp = n(), # RR
    p_hat = mean(Q4 == 1),
    var_p = p_hat * (1 - p_hat) / (r_resp - 1), # variance of p_hat
    se_p = sqrt(var_p),
    T_hat = N_pop * p_hat,
    var_T = N_pop^2 * var_p,
    se_T = sqrt(var_T),
    # 95% CI
    ci_lo_T = T_hat - 1.96 * se_T,
    ci_hi_T = T_hat + 1.96 * se_T)

```

```r
#| echo: false


q5c_results |>
  pivot_longer(everything(), names_to = "Quantity", values_to = "Value") |>
  mutate(Value = if_else(
    Quantity == "r_resp",
    formatC(Value, format = "d", big.mark = ","),
    formatC(Value, format = "fg", digits = 6, big.mark = ",")
  )) |>
  kable(caption = "MCAR (respondents-only) estimator of FEHBP total")
```

-   The MCAR-based point estimate of the total number of FEHBP enrollees is about $\hat{T} \approx$ `r formatC(q5c_results$T_hat, format="d", big.mark=",")`, with 95% CI of (`r formatC(q5c_results$ci_lo_T, format="d", big.mark=",")`, `r formatC(q5c_results$ci_hi_T, format="d", big.mark=",")`). This estimator is unbiased only if respondents and nonrespondents have the same true enrollment rate, which 5b suggests is unlikely.

\newpage

**5d. (2 pts) Using one or more variable identified in 5b (use at least one even if you were not concerned by anything), multiply impute M = 5 times the FEHBP enrollment indicator (Q4) using the method of your choice (e.g., hot-deck, logistic regression).**

-   Logistic regression imputation of Q4 using the 5b auxiliary variables as predictors, via the `mice` package with `method = "logreg"`. Q4 is binary (Yes/No), so logistic regression is the natural parametric choice, and the imputation model predicts Pr(Q4 = Yes) as a function of the auxiliary covariates. Each imputation draws a new set of values from that predictive distribution. Nonrespondents have `Q4_enrolled = NA`, which is the signal to `mice` that those cells need to be imputed. Respondents' Yes/No values are held fixed across all M imputations, and we draw M = 5 imputations.

```r
#| label: q5d-impute

# code Q4 as a Yes/No factor 
febs_mi <- febs |> 
  mutate(
    Q4_enrolled = case_when(
      responded == 0 ~ NA_character_,
      Q4 == 1 ~ "Yes",
      Q4 == 2 ~ "No"),
    Q4_enrolled = factor(Q4_enrolled, levels = c("No", "Yes"))
  )

#  six 5b auxiliary variables
mi_input <- febs_mi |>
  select(agency, super, salary_group, age_group, sex, Minority, Q4_enrolled)

# M = 5 imputations via logistic regression
set.seed(701)

imputed <- mice(mi_input, m = 5, method = "logreg", printFlag = FALSE)
```

-   The sanity check below confirms every previously missing cell received an imputed value (`n_na_remain = 0` across all five imputations, and that the Yes counts vary. A constant `n_yes` across imputations would indicate something had gone wrong (e.g., single imputation replicated M times rather than M independent draws).

```r
#| label: q5d-sanity
#| echo: false

orig_missing <- sum(is.na(febs_mi$Q4_enrolled))

tibble(
  imputation  = 1:5,
  n_yes = map_int(1:5, ~sum(complete(imputed, .)$Q4_enrolled == "Yes")),
  n_na_remain = map_int(
    1:5, ~sum(is.na(complete(imputed, .)$Q4_enrolled)))
  ) |>
  kable(caption = str_c(
    "Imputation sanity check: ",
    formatC(orig_missing, format = "d", big.mark = ","),
    " cells were NA before mice; n_na_remain should be 0 in every imputation."
  ))
```

\newpage

**5e. (2 pts) Re-estimate the quantity in 5c independently for each of the M = 5 completed data sets, and pool the results to produce an overall estimated total number of FEHBP and associated 95% confidence interval, again using 1.96 as the critical value. Show your intermediate code and/or calculations so that I can verify you are applying Rubin's combination rule correctly. In a sentence or two, do you feel there any harm in using MCAR estimator in 5c, or do you think the MAR estimator you produced here would be preferred?**

-   Rubin's combination rule for $M$ scalar estimates $Q_m$ with within-imputation variances $U_m$ is:

    -   Pooled point estimate: $\bar{Q} = \frac{1}{M}\sum_{m=1}^{M} Q_m$

    -   Within-imputation variance: $\bar{U} = \frac{1}{M}\sum_{m=1}^{M} U_m$

    -   Between-imputation variance: $B = \frac{1}{M-1}\sum_{m=1}^{M}(Q_m - \bar{Q})^2$

    -   Total variance: $T_{MI} = \bar{U} + (1 + 1/M) B$

    -   95% CI: $\bar{Q} \pm 1.96 \sqrt{T_{MI}}$

-   Step one of per-imputation $Q_m$ and $U_m$, each completed data set has $n = 40{,}000$ cases (e.g., respondents plus imputed nonrespondents), so we compute $\hat{p}_m$, then apply the same scaling identity from 5c $\hat{T} = N\hat{p}$ and $\widehat{\text{var}}(\hat{T}) = N^2 \widehat{\text{var}}(\hat{p})$ to get $Q_m = \hat{T}_m$ and $U_m$.

```r
#| label: q5e-per-imp

M <- 5 # complete data sets

per_imp <- map_dfr(1:M, function(m) {
  
  # for each imputated data set
  comp = complete(imputed, m)
  
  # compute proportion of Yes across the full n = 40,000 sample
  p_m = mean(comp$Q4_enrolled == "Yes")
  
  # n_full = 40,000 for every imputation since mice fills every NA cell
  n_full = nrow(comp)
  
  # generate table for results
  tibble(
    m  = m,
    p_m  = p_m,
    # Q_m = T_m is the total enrollees
    T_m  = N_pop * p_m,
    # var(p_m) using the SRS variance formula from 5c
    var_p_m = p_m * (1 - p_m) / (n_full - 1),
    # U_m is within-imputation variance of T_m
    U_m = N_pop^2 * p_m * (1 - p_m) / (n_full - 1)
  )
})

```

```r
#| echo: false

per_imp |>
  mutate(
    p_m = round(p_m, 6),
    var_p_m = formatC(var_p_m, format = "e", digits = 3),
    across(c(T_m, U_m), ~formatC(.x, format = "fg", digits = 6, big.mark = ","))
  ) |>
  kable(caption = "Per-imputation point estimates and within-imputation variances")

```

-   The second step is to pool via Rubin's rules. Pooling combines the $M = 5$ per-imputation estimates into a single estimate accounting for sampling variability within each completed data set ($\bar{U}$) and additional uncertainty from the imputation itself ($B$). The $(1 + 1/M)$ multiplier on $B$ is Rubin's finite-$M$ correction that inflates the between component to compensate for using $M = 5$ rather than infinitely many imputations.

```r
#| label: q5e-pool
q5e_pool <- per_imp |>
  reframe(
    # pooled point estimate
    Q_bar = mean(T_m),      
    # within-imputation variance
    U_bar = mean(U_m),                      
    # between-imp: sum((T_m - Q_bar)^2) / (M-1)
    B = var(T_m),                           
    # total variance with Rubin finite-M correction
    T_MI = U_bar + (1 + 1/M) * B,              
    se_MI = sqrt(T_MI),
    ci_lo_MI = Q_bar - 1.96 * se_MI,
    ci_hi_MI = Q_bar + 1.96 * se_MI
  )

```

```r
#| echo: false

tibble(
  Quantity = c("Point estimate", "SE",
               "95% CI lower", "95% CI upper",
               "CI width"),
  MCAR = c(
    q5c_results$T_hat,
    q5c_results$se_T,
    q5c_results$ci_lo_T,
    q5c_results$ci_hi_T,
    q5c_results$ci_hi_T - q5c_results$ci_lo_T
  ),
  MAR = c(
    q5e_pool$Q_bar,
    q5e_pool$se_MI,
    q5e_pool$ci_lo_MI,
    q5e_pool$ci_hi_MI,
    q5e_pool$ci_hi_MI - q5e_pool$ci_lo_MI
  )
) |>
  mutate(
    Difference = MAR - MCAR,
    across(c(MCAR, MAR, Difference), 
           ~formatC(.x, format = "d", big.mark = ","))
  ) |>
  kable(caption = "MCAR (5c) vs MAR (5e) estimators of FEHBP enrollment total")

# store both estimates as plain scalars for the inline prose below
mcar_est <- q5c_results$T_hat
mcar_lo  <- q5c_results$ci_lo_T
mcar_hi  <- q5c_results$ci_hi_T
mar_est  <- q5e_pool$Q_bar
mar_lo   <- q5e_pool$ci_lo_MI
mar_hi   <- q5e_pool$ci_hi_MI
diff_est <- mar_est - mcar_est
```

\newpage

-   The MCAR estimator from 5c gives about `r formatC(mcar_est, format="d", big.mark=",")` FEHBP enrollees (95% CI `r formatC(mcar_lo, format="d", big.mark=",")`, `r formatC(mcar_hi, format="d", big.mark=",")`), while the MAR (imputed) estimator gives about `r formatC(mar_est, format="d", big.mark=",")` (95% CI `r formatC(mar_lo, format="d", big.mark=",")`, `r formatC(mar_hi, format="d", big.mark=",")`). Given the differential response rates we saw in 5a the MCAR estimator is very likely biased because respondents are not an unbiased subset of the sample frame with respect to FEHBP enrollment. The MAR estimator uses the auxiliary variables to reduce that bias, and the CI reflects the additional uncertainty from imputation via the between-imputation variance component $B$. I would prefer the MAR estimator for a reporting context.
