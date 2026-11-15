---
id: "jpsm/complex_sample_data_SURV701/assignments/hw5_surv701_Linares"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Assignment 5"
original: "complex_sample_data_SURV701/assignments/hw5_surv701_Linares.qmd"
pages: 
sha256: "2c79e44b6aac127a3a9a777f3c1104bfd2c1c657dffb4a2d4a4f90ae395a3949"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:48"
---


```r
#| include: false

pacman::p_load(knitr, survey, tidyverse)

# Set global options
options(scipen = 999, digits = 5)

data_path <- "D:/repos/UMD_classes_code/complex_sample_data_SURV701/assignments/"
```

## 1. (15 pts) In this problem, you will fit and interpret a logistic regression model using the ESS6 Russian Federation data, where we are interested in modeling the probability of having voted in the last election based on gender and marital status, among the subpopulation of those aged 25 – 35.

```r
# read the ESS Russian Federation data
ess_data <- haven::read_sas(
  str_c(data_path, "chapter_exercises_ess6rf.sas7bdat")) |>
  rename_with(toupper) |>
  mutate(
    MARCAT = factor(
      MARCAT, levels = 1:3,
      labels = c("Married", "Previously Married", "Never Married")),
    VOTED_LASTELECTION = factor(VOTED_LASTELECTION, levels = 0:1,
                                labels = c("No", "Yes")),
    GNDR = factor(GNDR, levels = 1:2, labels = c("Male", "Female"))
  )

```

## 

### a) Create a subpopulation indicator called AGE25_35 that is equal to 1 if 25 \<= AGEA \<= 35, and 0 otherwise (if AGEA is not missing). Perform a cross-tabulation to ensure the variable is correctly set to 0/1. What is the unweighted subpopulation sample size, and what percentage of respondents fall into this subpopulation?

-   The unweighted subpopulation sample size of 25-35 year olds is 480 (19.4%) in this dataset out of 2,481 and two cases that had missing data which we dropped.

```r
#| fig-width: 7
# create AGE25_35 indicator: 1 if 25 <= AGEA <= 35, 0 otherwise
ess_data <- ess_data |>
  filter(!is.na(AGEA)) |> 
  mutate(AGE25_35 = if_else(between(AGEA, 25, 35), 1, 0))

ess_data |> count(AGE25_35) |> kable()

# cross-tabulation plot to verify
ess_data |>
  count(AGEA, AGE25_35) |>
  ggplot(aes(x = AGEA, y = n, fill = factor(AGE25_35))) +
  geom_col() +
  scale_fill_manual(values = c("0" = "grey70", "1" = "dodgerblue"),
                    labels = c("0" = "Outside 25–35", "1" = "Age 25–35")) +
  labs(x = "Age", y = "Count", fill = "AGE25_35") +
  theme_minimal()


```

### b) Fit a logistic model with having voted in last election (variable VOTED_LASTELECTION) as the binary outcome (modeling the event of interest as VOTED_LASTELECTION = 1 = voted) using the unconditional approach with subpopulation indicator created in part a in the subpop(), DOMAIN statement, or the like. Set values MARCAT = 1 and GNDR = 2 as the reference categories.

-   We fit a logistic regression predicting VOTED_LASTELECTION (1 = voted) from GNDR and MARCAT within the subpopulation of those aged 25--35 setting MARCAT = "Married" and GNDR = "Female" as the reference categories. The model uses the logit link function (Module 10, Slide 11):

$$
\text{logit}[\Pr(Y = 1 \mid \mathbf{X})] = \log\left(\frac{\Pr(Y=1 \mid \mathbf{X})}{1 - \Pr(Y=1 \mid \mathbf{X})}\right) = \beta_0 + \beta_1 X_1 + \cdots + \beta_p X_p
$$

-   Parameter estimation uses the iterative pseudo-maximum likelihood method which incorporates the survey weights, and variance estimation uses Taylor series linearization appropriate for the stratified cluster design (Module 10, Slide 22).

```r
# set reference categories
ess_data <- ess_data |> 
  mutate(MARCAT = relevel(MARCAT, ref = "Married"),
         GNDR = relevel(GNDR, ref = "Female") )

# define the complex survey design
design_full <- svydesign(
  ids = ~PSU, strata = ~STRATIFY, weights = ~PSPWGHT,
  data = ess_data, nest = TRUE
)

# fit logistic model using unconditional subpopulation approach
logit_model <- svyglm(
  VOTED_LASTELECTION ~ GNDR + MARCAT,
  design = subset(design_full, AGE25_35 == 1),
  family = quasibinomial(link = "logit")
)


summary(logit_model)


# Design df for the subsetted survey design (Module 9, Slide 14)
sub_design <- subset(design_full, AGE25_35 == 1)
design_df <- degf(sub_design)
```

### c) Why is the unconditional approach important for correct subpopulation estimation? What is the risk of the subsetting approach?

-   The unconditional approach (Module 6, Slides 9--11) treats the stratum subpopulation sizes as random variables rather than fixed. This is important because the distribution of subpopulation cases across strata is itself random and the number of 25--35 year olds in each stratum is not fixed. When we subset the data we risk losing PSUs or even entire strata from the analysis, which distorts the variance estimation, compute standard errors that do not account for the variability in subpopulation sizes across design, and potentially encounter strata with only one PSU, which would prevent variance estimation entirely (Module 6, Slide 11). We can use the `subset()` function on the full survey design object (e.g., which R's `survey` package handles as the unconditional approach), and preserve the full design structure and correctly estimate standard errors.

### d) Are gender and marital status significant predictors of having voted within the subpopulation of interest? Test them separately, one overall “effect” at a time.

-   We test each predictor's overall significance using the Wald $F$-test (Module 10, Slides 26–28), which tests whether all parameters associated with a given predictor are simultaneously zero. Following Module 9 (Slide 14), we reference the design $df = \text{\#clusters} - H$ rather than the OLS-style residual $df$ that `regTermTest()` uses by default; the design df for the subsetted survey design (accounting for cases dropped to the 25–35 subpopulation) is `r design_df`.



```r

# Wald test for GNDR (using design df, not residual df)
wald_gndr <- regTermTest(logit_model, ~GNDR, df = design_df)
wald_gndr

# Wald test for MARCAT  
wald_marcat <- regTermTest(logit_model, ~MARCAT, df = design_df)
wald_marcat
```

```r
#| include: false
wald_gndr_F <- round(as.numeric(wald_gndr$Ftest), 4)
wald_gndr_p <- round(wald_gndr$p, 4)
wald_marcat_F <- round(as.numeric(wald_marcat$Ftest), 4)
wald_marcat_p <- round(wald_marcat$p, 4)
```

-   Gender is a statistically significant predictor of having voted ($F = 7.15$, $df = 1$ and 151, $p = 0.0083$). Marital status is also a statistically significant predictor ($F = 4.58$, $df = 2$ and 151, $p = 0.0117$). Both predictors contribute significantly to the model at $\alpha = .05$.


\newpage

### e) In a few sentences or a short paragraph, interpret your findings (e.g., odds ratios of predictor variables) from this model within the context of the data set / problem.

```r
# odds ratios with 95% CIs (Module 10, Slide 15)
or_table <- exp(cbind(OR = coef(logit_model), confint(logit_model)))

or_table |>
  as_tibble(rownames = "Parameter") |>
  mutate(across(where(is.numeric), ~round(.x, 4))) |>
  # clean names for columns
  kable(col.names = c("Parameter", "OR", "95% Lower", "95% Upper"))
```

```r
#| include: false
or_male <- round(exp(coef(logit_model)["GNDRMale"]), 3)
or_prev <- round(exp(coef(logit_model)["MARCATPreviously Married"]), 3)
or_never <- round(exp(coef(logit_model)["MARCATNever Married"]), 3)
```

-   The intercept corresponds to the baseline group: married females aged 25--35. The estimated odds of having voted for this group are $e^{0.908}$ = `r round(exp(coef(logit_model)["(Intercept)"]), 3)`, meaning they are about 2.5 times more likely to have voted than not, with a baseline probability of approximately `r round(plogis(coef(logit_model)["(Intercept)"]) * 100, 1)`%.Among Russian Federation residents aged 25--35, the estimated odds of having voted in the last election for males are `r or_male` times the odds for females, holding marital status constant. This means males in this age group have roughly 44% lower odds of voting than females. Regarding marital status, never married individuals have `r or_never` times the odds of voting compared to married individuals (approximately 49% lower odds), controlling for gender. Previously married individuals show `r or_prev` times the odds of voting relative to married individuals, though this difference is not statistically significant. The pattern suggests that within this young adult subpopulation, being female and being married are both independently associated with higher likelihood of having voted.

\newpage

## 2. (5 pts) Item nonresponse occurs when a survey respondent is unable or unwilling to provide an answer to a survey question. For a demographic question regarding an individual’s sexual orientation fielded in the 2017 administration of the Federal Employee Viewpoint Survey, 10% of respondents chose the response option “I prefer not to say,” or simply refused to choose any of the response options and moved on to the next question. In an effort to investigate factors related to an individual’s likelihood of not answering this question, a researcher fit a logistic regression model where the dependent variable was a 0/1 indicator of item nonresponse and the independent variables were gender (variable DSEX: A=Male and B=Female), whether the employee works in the field office or at the headquarters office of the agency (variable DLOC: A=Headquarters and B=Field), and whether or not the employee identified as having a disability (variable DDIS: A=Yes and B=No).

### Parameter estimates generated from PROC SURVEYLOGISTIC are given below. Note that the reference categories were assigned as follows: (1) DSEX=B; (2) DLOC=B; and (3) DDIS=A. Use the information below to answer parts a, b, and c.

-   We are given the following parameter estimates from a logistic model predicting item nonresponse to a sexual orientation question, with reference categories DSEX = B (Female), DLOC = B (Field), DDIS = A (Yes, has disability):

| Parameter              | Estimate  |
|------------------------|-----------|
| Intercept              | $-3.3076$ |
| DSEX A (Male)          | $-0.4459$ |
| DLOC A (Headquarters)  | $-0.1148$ |
| DDIS B (No disability) | $0.5154$  |

-   The logistic regression model (Module 10, Slide 11) is:

$$
\text{logit}[\Pr(\text{NR} = 1)] = \beta_0 + \beta_1 \cdot \text{DSEX}_A + \beta_2 \cdot \text{DLOC}_A + \beta_3 \cdot \text{DDIS}_B
$$

### a) What is the odds ratio of a respondent with a disability not answering the sexual orientation item relative to a respondent without a disability?

-   Since DDIS = A (has disability) is the reference category, the coefficient for DDIS = B (no disability) is $\hat{\beta}_3 = 0.5154$, and $e^{0.5154} = `r round(exp(0.5154), 4)`$ represents the odds ratio of no disability relative to disability. The question asks for the reverse: the odds ratio of a respondent **with** a disability relative to one without. This is the reciprocal (Module 10, Slide 17):

$$
OR = e^{-\hat{\beta}_3} = e^{-0.5154} = `r round(exp(-0.5154), 4)`
$$

-   A respondent with a disability has approximately `r round(exp(-0.5154), 2)` times the odds of not answering the sexual orientation item compared to a respondent without a disability. Moreover, respondents with a disability are less likely to refuse the sexual orientation question and their odds of nonresponse are about 40% lower than those without a disability.

### b) What is the probability that a male in the field office with a disability did not answer the sexual orientation item?

-   For a male (DSEX = A) in the field office (DLOC = B, reference) with a disability (DDIS = A, reference), the predicted logit is:

$$
\hat{\eta} = -3.3076 + (-0.4459)(1) + (-0.1148)(0) + (0.5154)(0) = -3.7535
$$

-   Converting to a probability using the inverse logit function (Module 10, Slide 11):

$$
\hat{p} = \frac{e^{\hat{\eta}}}{1 + e^{\hat{\eta}}} = \frac{e^{-3.7535}}{1 + e^{-3.7535}} = `r round(exp(-3.7535) / (1 + exp(-3.7535)), 4)`
$$

-   The estimated probability that a male in the field office with a disability did not answer the sexual orientation item is approximately `r round(exp(-3.7535) / (1 + exp(-3.7535)) * 100, 2)`%.

### c) What is the difference in logits between a female in the field office without a disability and a male at the headquarters office with a disability? What is the odds ratio associated with this logit difference?

-   Female, field office, no disability (DSEX = B ref, DLOC = B ref, DDIS = B):

$$
\hat{\eta}_1 = -3.3076 + 0.5154 = -2.7922
$$

-   Male, headquarters, disability (DSEX = A, DLOC = A, DDIS = A ref):

$$
\hat{\eta}_2 = -3.3076 + (-0.4459) + (-0.1148) = -3.8683
$$

-   The difference in logits is:

$$
\hat{\eta}_1 - \hat{\eta}_2 = -2.7922 - (-3.8683) = 1.0761
$$

-   The associated odds ratio (Module 10, Slide 8):

$$
OR = e^{1.0761} = `r round(exp(1.0761), 4)`
$$

-   The odds of item nonresponse for a female in the field office without a disability are approximately `r round(exp(1.0761), 2)` times the odds for a male at headquarters with a disability. Moreover, female field office employee without a disability has nearly 3 times the odds of not answering the sexual orientation question.
