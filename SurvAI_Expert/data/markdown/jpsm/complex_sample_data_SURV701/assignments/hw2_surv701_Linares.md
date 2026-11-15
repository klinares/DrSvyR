---
id: "jpsm/complex_sample_data_SURV701/assignments/hw2_surv701_Linares"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/assignments/hw2_surv701_Linares.qmd"
pages: 
sha256: "ccf80c5c748af7d785a8ad40cc92623ebdd415cf6da27b0077fc3614925e737c"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:48"
---


```r
#| include: false

pacman::p_load(knitr, survey, patchwork, viridis, tidyverse)

# Set global options
options(scipen = 999, digits = 5)


data_path <- "d:/repos/UMD_classes_code/complex_sample_data_SURV701/assignments/"
```

### Please complete the following exercises:

1.  **(10 pts) Suppose data a random sample of size *n* = 13 individuals is collected by an EPSEM design, among which there are 9 respondents. Information on age (in years), gender (1 if male; 0 female), respondent (1 if respond; 0 otherwise), and annual income (in \$10,000 for respondents only) is listed in the table below.**

```r
# build the table
sample_data <- tibble(
  id = 1:13,
  age = c(23, 34, 18, 20, 21, 28, 33, 45, 53, 55, 66, 65, 87),
  gender = c(0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1),
  respondent = c(0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1),
  income = c(NA, 5.5, 7, NA, 8.2, NA, 5, 15, NA, 14, 5, 16, 5)
)

# print table
sample_data |> kable()
```

a\) Estimate the average annual income without any weight adjustments (i.e., assuming all respondents have a weight equal to 1).

```r
respondent <- sample_data |> 
  # filter respondents
  filter(respondent==1) |> 
  # calculate unweighted mean
  reframe(n_size = n(),
          unweighted_income_ave = mean(income, na.rm=TRUE))

respondent |> kable()
```

```r
#| echo: false
cat("The average annual income without adjustement is ", 
    scales::dollar(
    respondent |> 
      pull(unweighted_income_ave)   * 10000)
)
```

\

b\) Estimate the average annual income after using the weighting class method for nonresponse. To do so, create four classes based on the cross-classification of (1) gender and (2) whether or not the sampled individual is less than 40 years old.

-   For weighted class adjustment for nonresponse we can use the formula in module 2 slide 23:

$$
w_{nr, wc, i} = \frac{1}{rrate_c}
$$

-   where $rrate_c$ is the response rate for weighted class $c=1,...,C$

```r
#| echo: false
cat("Creating weighting class")
```

```r
results_1_b <- sample_data |> 
  mutate(
    # create age cut 
    age_g = if_else(age < 40, "under 40", "over 40"),
    # gender labels
    gender_label = if_else(gender==1, "male", "female"),
    # combine age group w/ gender label
    weighting_class = str_c(age_g, gender_label, sep=" ")
  )

results_1_b |> kable()
```

```r
#| echo: false
cat("Computing nonresponse weight adjustment")
```

```r

response_rates <- results_1_b |> 
  group_by(weighting_class) |> 
  reframe(
    # sum of respondent / class size
    rrate = sum(respondent) / n(), 
    # formula from mod 2 slide 23
    w_nr = 1 / rrate # nonresponse weight
  )

response_rates |> kable()
```

```r
#| echo: false
cat("Assigning nonresponse weight back to table")
```

```r
results_1_b <- results_1_b |> 
  # non respondents have NA for income
  filter(respondent==1) |> 
  left_join(
    response_rates |> select(weighting_class, w_nr)
  )
```

-   Using the weighted mean formula from module 3 slide 9, we compute the weighted mean:

$$
\bar{y}_w = \frac{\sum_i w_iy_i}{\sum_i w_i}
$$

```r
weighted_mean <- results_1_b |> 
  reframe(
    sum_wy = sum(w_nr * income),
    sum_w = sum(w_nr),
    weighte_mean = sum_wy / sum_w
  ) |> 
  pull(weighte_mean)
  
```

```r
#| echo: false

cat("The average annual income is ", weighted_mean," or",
    scales::dollar(weighted_mean* 10000),
    " \nwhen we use the weighting class method for nonresponse")

```

\

c\) Compare the mean estimate from Parts a and b. Did applying the weighting class method do much to change the estimated average annual income of respondents in this sample?

-   The weighting class adjustment reduced the average income estimate by \$4,282, an almost 5% difference. Using the weighting class method when adjusting for four nonresponse groups assumes MAR within classes, meanin that within each class respondent and nonrespondents have similar characteristics with respect to income. The adjustment seems to give more weight to respondents in classes with lower RR, thus representing the nonrespondents in their respective class. The overall change in average income is modest while reflecting the differential nonresponse patterns across classes.

```r
tibble(
  Method = c("Unweighted", "Weighted"),
  Estimate = c(
    # from part a
    respondent |> pull(unweighted_income_ave), 
    # from part b
    weighted_mean
  )
) |> 
  mutate(Estimate = scales::dollar(
    Estimate * 10000)
  ) |> 
  kable()
```

\newpage

2.  **(10 pts) This problem will use the data set named “chapter_exercises_ess6rf,” which has been posted to the Canvas site (and linked to this HW assignment) in both SAS and Stata formats. It contains data from the European Social Survey for individuals living in the Russian Federation. The analysis weight variable is PSPWGHT, the PSU identifier variable is PSU, and the stratum identifier variable is STRATIFY.**

```r
# read in data
ess_data <- haven::read_dta(str_c(data_path, 
                                  "chapter_exercises_ess6rf.dta")) |> 
  # use uppercase column names
  rename_with(toupper)


# show strata, psu, ssu
ess_data_aggregated <- ess_data |> 
  group_by(STRATIFY) |> 
  count(PSU) |> 
  reframe(n_psu = n(), n_ssu=sum(n))

ess_data_aggregated |> 
  kable()

```

a\) Prepare a weighted (if possible in your software of choice) histogram for each variable STFLIFE and TRSTPLC. What conclusions can be made based on the histograms?

-   For STFLIFE, the weighted distribution is roughly unimodal, but slightly left skewed with a majority of responses clustering around response levels 5 and 6. Few respondents report at the extreme dissatisfaction, suggesting that most Russian federation residents report moderate to good life satisfaction.

-   For TRSTPLC, the weighted distribution is more spread out and appearing bimodal with peaks around response levels 0 and 5. We can see more Russian federation residents distrusting the police, and the distribution suggests polarized views on police trust.

```r
#| fig-height: 4.5
#| fig-width: 7

p1 <- ess_data |> 
  filter(!is.na(STFLIFE)) |> 
  ggplot(aes(x = STFLIFE, weight = PSPWGHT)) +
  geom_histogram(binwidth = 1, fill = viridis(1), color = "white", 
                 boundary = -0.5) +
  scale_x_continuous(breaks = 0:10) +
  labs(title = "Life Satisfaction (STFLIFE)",
       x = "Life Satisfaction (0 = Extremely Dissatisfied, 10 = Very Satisfied)",
       y = "Weighted Count") +
  ggthemes::theme_hc()  

p2 <- ess_data |> 
  filter(!is.na(TRSTPLC)) |> 
  ggplot(aes(x = TRSTPLC, weight = PSPWGHT)) +
  geom_histogram(binwidth = 1, fill = viridis(1, begin = 0.5), color = "white",
                 boundary = -0.5) +
  scale_x_continuous(breaks = 0:10) +
  labs(title = "Trust in Police (TRSTPLC)",
       x = "Trust in Police (0 = No Trust At All, 10 = Complete Trust)",
       y = "Weighted Count") +
  ggthemes::theme_hc() 

p1 / p2
```

b\) Do you think it’s appropriate to treat each of these two variables in Part a as continuous? Why or why not?

-   It is reasonably appropriate to treat both variables as continues due to both having 11 point response scales which is enough granularity to approximate a normal distribution. It also helps with interpretability allowing for calculations of means and other measures of central tendency. Both histograms also shows some spread across the scale. However, the responses are technically ordinal, meaning that the intervals between responses may not be equal. We may wish to treat them as ordinal as well.

\

c)  Use statistical software of your choice, fill in the table below (treating the two variables as continuous). Assume the data was collected from a simple random sample with replacement. That is, ignore all complex survey sample features.

```r
# using the survey package
srs_design <- svydesign(ids = ~1, data = ess_data, weights = NULL)

vars <- c("STFLIFE", "TRSTPLC")

# pass the vars to the map function
srs_results <- tibble(
  Variable = vars,
  n = map_int(vars, ~sum(!is.na(ess_data[[.]]))),
  mean = map_dbl(vars, 
                 ~svymean(as.formula(paste0("~", .)), 
                          srs_design, na.rm = TRUE)),
  se = map_dbl(vars, 
               ~SE(svymean(as.formula(paste0("~", .)), 
                           srs_design, na.rm = TRUE))),
  min = map_dbl(vars, 
                ~min(ess_data[[.]], na.rm = TRUE)),
  max = map_dbl(vars, 
                ~max(ess_data[[.]], na.rm = TRUE))
)

srs_results |> kable()


```

\newpage

d)  Repeat Part c, only now accounting for the analysis weights. Continue to ignore the stratification and clustering in the sample design.

```r

# we need to add weights in the survey design first
design_weights_only <- svydesign(
  ids = ~1,
  weights = ~PSPWGHT,
  data = ess_data
)

# loop over both variables weighted


weighted_results <- map_dfr(vars, function(var) {
  formula <- as.formula(str_c("~", var))
  svy_mean <- svymean(formula, design_weights_only, na.rm = TRUE)
  tibble(
    Variable = var,
    N = sum(!is.na(ess_data[[var]])),
    Mean = coef(svy_mean),
    SE = SE(svy_mean),
    Min = min(ess_data[[var]], na.rm = TRUE),
    Max = max(ess_data[[var]], na.rm = TRUE)
  )
}) |> 
  mutate(SE = as.numeric(SE))


weighted_results |> kable()

```

\newpage

e)  Repeat the analysis in Part d accounting for all three complex survey sample features—the weights, stratification, and clustering.

```r
# add complete weights
design_full <- svydesign(
  ids = ~PSU,
  strata = ~STRATIFY,
  weights = ~PSPWGHT,
  data = ess_data,
  nest = TRUE
)

# again, loop throught the variables with complex weighting
complete_weighted_results <- map_dfr(vars, function(var) {
    tibble(
      Variable = var,
      N = sum(!is.na(ess_data[[var]])),
      Mean = coef(svymean(as.formula(paste0("~", var)), 
                          design_full, na.rm = TRUE)),
      SE = SE(svymean(as.formula(paste0("~", var)), 
                      design_full, na.rm = TRUE)),
      Min = min(ess_data[[var]], na.rm = TRUE),
      Max = max(ess_data[[var]], na.rm = TRUE)
    )
  }) |> 
  mutate(SE = as.numeric(SE))


complete_weighted_results |> kable()
  
```

\newpage

f\) Comment on how the standard errors differ across Parts c, d, and e. What impact do weights have on standard errors? What about stratification and clustering?

-   For variable STFLIFE, SE changed from the SRS design .047 to the weighted .056, and increased in the complex weighting to .085. TRSTPLC had an SRS SE of .052, and in the weighted design increased to .062, and .104 in the complex design. It is clear that weighting increases SE because it introduces variability, there is a loss in precision due to the weighting proportional to the squared CV of the weights, and the effective sample size is reduce when weights are unequal. Stratification typically decreases SE by reducing between strata variance while clustering typically increases SE due to the ICC. In this case, the clustering effect outweighs the stratification effects based on the increase of SE for both variables.

```r

tibble(
  Variable = srs_results$Variable,
  SRS_SE = srs_results$se,
  Weighted_SE = weighted_results$SE,
  Complete_Weighted_SE = complete_weighted_results$SE
) |> 
kable()

```

\

g)  Using results from Part e, calculate 95% confidence limits for both means manually, as well as design effects (relative to results in Part d). Use those findings to fill in the table below.

-   Formula for Confidence Interval (from Module 2, Slide 2): $$CI_{.95} = \hat{\theta} \pm t_{df, .975} \times se(\hat{\theta})$$

-   Design Effect Formula: $$d^2 = \frac{Var_{complex}}{Var_{SRS}}$$

    -   The DEFF tells us how much the variance is inflated due to the complex sample design relative to a simple weighted random sample. In this case, both DEFF estimates are over 1, indicating that the complex design increases variance compared to the weighted SRS design.

```r
# PSUs
n_psu <- ess_data_aggregated |> tally(n_psu) |> pull(n)
# strata
n_strata <- ess_data_aggregated |> count(STRATIFY) |> tally(n) |> pull(n)
df_design <- n_psu - n_strata
t_crit <- qt(0.975, df = df_design)

```

```r
#| echo: false
cat("Degrees of freedom:", df_design, "\n")
cat("t critical value (0.975, df =", df_design, "):", round(t_crit, 4), "\n\n")
```

```r

part_g_table <- complete_weighted_results |> 
  select(Variable:SE) |> 
  mutate(Var = SE^2,
         lower = Mean - t_crit * SE,
         upper = Mean + t_crit * SE) |> 
  # add deff
  left_join(
    weighted_results |> 
      mutate(Var_srs = SE^2) |> 
      select(Variable, Var_srs)
  ) |> 
  mutate(DEFF = Var / Var_srs) |> 
  select(-Var, -Var_srs)

part_g_table |> 
  kable()
```

\newpage

3.  **(5 pts) Using the same data set as Problem 2, with analysis weight PSPWGHT, PSU identifier PSU, and the stratum identifier STRATIFY, use the indicator variable VOTED_LASTELECTION to answer the following questions. What is the estimated proportion of people in the Russian Federation who voted in the last election? What is the standard error and 95% confidence limits for this proportion? Is this figure significantly different from a hypothesized proportion of 0.55?**

-   The estimated proportion who voted in the last election under a complex design is .629 (SE=.017 \[ 95%CI: .596, .663\] ). We test whether this proportion is significantly different from a hypothesized value of .55 using the `svyttest()` one sample t-test from the survey package. We estimate a t statistic of 4.7, p \< .001, and reject the null hypothesis, the estimated proportion is statistically significantly different from the hypothesized proportion. We also examine the confidence interval reported in the table below which does not contain the hypothesized proportion.

```r
# add the new variable into a complex survey design
voted_prop <- svymean(~VOTED_LASTELECTION, design_full, na.rm = TRUE)

# compute se, CI
results_3 <- tibble(
  p_hat = coef(voted_prop),
  se_p = SE(voted_prop),
  ci_lower = p_hat - t_crit * se_p,
  ci_upper = p_hat + t_crit * se_p)

results_3 |> kable()

design_full <- update(design_full, 
                      voted_shifted = VOTED_LASTELECTION - 0.55)

svyttest(voted_shifted ~ 0, design_full, na.rm = TRUE)

```
