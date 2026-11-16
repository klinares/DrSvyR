---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_12_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 12"
original: "PracTools_SURV745/assignments/SURV745_Assign_12_Linares.qmd"
pages: 
sha256: "f5fe0e8fd807c1dea87d1080e291def502199a47fe48b24e914342772a8862d0"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:12"
---


```r
# load packages
pacman::p_load(tidyverse, knitr, kableExtra, viridis, here,
               PracTools, survey, srvyr, sampling)
options(scipen = 999)

# anchor the working file
here::i_am("COVID.csv")
```

#### VDK Exercise 14.3 Use the model BEDS + SEENCNT + EOYCNT + as.factor(hosp. type) and the sample described in Sect. 14.3.2 to compute GREG weights. Recode all values of BEDS that are less than 5 to 5, and then take the square root to compute the measure of size. That is, select a sample with probabilities proportional to recoded square root of beds (using the random number seed 428274453 if you are using R). Restrict the population to facilities other than type 4.

```r
set.seed(428274453)

# load  from PracTools
data(smho.N874)

# restrict to non-type-4 facilities
smho <- smho.N874 |> 
  filter(hosp.type != 4)

# population size after the restriction
N <- smho |> nrow()

# build MOS floor BEDS at 5, then take sqrt
# floor prevents zero-bed hospitals from having a zero selection probability
smho <- smho |> 
  mutate(x = ifelse(BEDS <= 5, 5, BEDS),
         x = sqrt(x))

# systematic pps draw with n=80
n <- 80
pk <- smho |> reframe( n * x / sum(x)) |> pull() # selection probabilities
sam_dat <- UPrandomsystematic(pk) |>  # 0/1 indicator from UPrandomsystematic
  tibble() |> 
  rename(sam_selected = 1) |> 
  add_column(smho, pk) |>
  # keep selected sample
  filter(sam_selected == 1) |> 
  # base weight
  mutate(d = 1 / pk)

```

-   The calibration model is

$$
y_i = \beta_0 + \beta_1 BEDS_i + \beta_2 SEENCNT_i + \beta_3 EOYCNT_i + \beta_4 I(type_i = 2) + \beta_5 I(type_i = 3) + \beta_6 I(type_i = 5) + \varepsilon_i
$$

-   which has seven terms: an intercept, three continuous predictors, and three indicator columns for the non-reference hospital types. Every term needs a population total for calibration. The intercept maps to $N$, the continuous variables map to their population sums, and the indicators map to the population counts of types 2, 3, and 5. Type 1 is the reference level and is implied by the intercept.

```r
# survey design object with base weights
smho_dsgn <- svydesign(ids = ~0,
                       strata = NULL,
                       data = sam_dat,
                       weights = ~d)

# population counts by hosp.type. 
N.hosp <- table(smho$hosp.type)

# population totals in the exact order survey expects for 
# ~BEDS + SEENCNT + EOYCNT + as.factor(hosp.type). 
pop_tots <- c("(Intercept)" = N,
              BEDS = sum(smho$BEDS),
              SEENCNT = sum(smho$SEENCNT),
              EOYCNT = sum(smho$EOYCNT),
              "as.factor(hosp.type)2" = as.numeric(N.hosp["2"]),
              "as.factor(hosp.type)3" = as.numeric(N.hosp["3"]),
              "as.factor(hosp.type)5" = as.numeric(N.hosp["5"]))

```

```r
#| echo: false

pop_tots

```

```r
# linear-distance GREG, sum((w - d)^2 / d) VDK eq. 14.2
sam_lin <- calibrate(design = smho_dsgn,
                     formula = ~BEDS + SEENCNT + EOYCNT + 
                       as.factor(hosp.type),
                     population = pop_tots,
                     calfun = "linear") # creates calibration metric
```

#### (a) Verify that the weighs are calibrated, i.e., $\sum_sw_ix_i=t_x$ for the auxiliary variables in the calibration model.

Calibration means the weighted sample totals of the auxiliaries equal the known population totals. We verify by computing `svytotal` on the calibrated design and comparing to `pop_tots`. The standard errors on these totals will be zero (up to floating-point noise) because calibration forces exact agreement.

```r
# one svytotal gets all calibrated totals
cal_totals <- svytotal(~BEDS + SEENCNT + EOYCNT + as.factor(hosp.type),
                       sam_lin)

# pop_tots already has 7 entries: intercept + 6 auxiliaries 
calib_check <- tibble(
  auxiliary = c(names(pop_tots), "as.factor(hosp.type)1"),
  pop_total = c(as.numeric(pop_tots), 
                       as.numeric(N.hosp["1"])),
  wtd_sample_total = c(sum(weights(sam_lin)),
                       coef(cal_totals)["BEDS"],
                       coef(cal_totals)["SEENCNT"],
                       coef(cal_totals)["EOYCNT"],
                       coef(cal_totals)["as.factor(hosp.type)2"],
                       coef(cal_totals)["as.factor(hosp.type)3"],
                       coef(cal_totals)["as.factor(hosp.type)5"],
                       coef(cal_totals)["as.factor(hosp.type)1"])) |> 
  mutate(difference = wtd_sample_total - pop_total)


```

```r
#| echo: false


calib_check |> 
  kable(digits = 4, 
        caption = "Calibration check: weighted sample totals vs. population totals")
```

\newpage

-   Each row in the table above shows a difference near zero, which confirms that $\sum_{i \in s} w_i x_i = t_x$ for each auxiliary. The row for `hosp.type == 1` also matches its population count, even though this level is not a named column in the calibration formula and we add it to the table. The reason is arithmetic: once calibration forces the weights to reproduce $N$ (the intercept) and the counts of types 2, 3, and 5, the remaining weight has to land on type 1.

#### (b) What are the ranges of the base weights and the calibrated weights?

-   The base weights range from 2.19 to 33.68 and are strictly positive by construction ($d_i = 1/\pi_i > 0$). The GREG weights range from -0.23 to 41.2. A negative weight means the calibration adjustment $g_i$ went below zero for at least one unit, which is a known issue with unbounded linear-distance calibration. A negative weight is nonsensical for estimation since it means a sampled unit contributes negatively to the estimated total.

```r
# six-number summaries of base and GREG weights
base_summary <- summary(weights(smho_dsgn))
greg_summary <- summary(weights(sam_lin))

# stack both weight vectors into a long tibble, then summarise by type
weight_ranges <- tibble(
  type = c(rep("Base (d_i)", length(weights(smho_dsgn))),
           rep("GREG (w_i)", length(weights(sam_lin)))),
  wt = c(weights(smho_dsgn), weights(sam_lin))) |> 
  group_by(type) |> 
  reframe(Min = min(wt),
            Q1 = quantile(wt, 0.25),
            Median = median(wt),
            Mean = mean(wt),
            Q3 = quantile(wt, 0.75),
            Max = max(wt),
            Sum = sum(wt))

```

```r
#| echo: false

weight_ranges |> 
  kable(digits = 3,
        caption = "Range of base weights vs. GREG-calibrated weights")

# stack both weight sets into a long frame for plotting
tibble(
  type = c(rep("Base (d_i)", length(weights(smho_dsgn))),
           rep("GREG (w_i)", length(weights(sam_lin)))),
  wt   = c(weights(smho_dsgn), weights(sam_lin))) |> 
  ggplot(aes(x = type, y = wt, fill = type)) +
  geom_violin(alpha = 0.4, color = NA) +
  geom_boxplot(width = 0.15, outlier.shape = 21, outlier.size = 2) +
  stat_summary(fun = range, geom = "text",
               aes(label = after_stat(round(y, 2))),
               position = position_nudge(x = 0.25), size = 3) +
  scale_fill_viridis(discrete = TRUE, end = 0.7, guide = "none") +
  labs(x = NULL, y = "Weight",
       title = "Distribution of base vs. GREG-calibrated weights") +
  theme_minimal()


```

-   Any calibration with an intercept forces the weights to sum to $N$. The base weights have no such constraint, so their sum can differ from $N$. After calibration, the GREG weights sum to exactly 725 because the intercept is in the calibration formula. When the linear-distance GREG is unbounded, the $g_i$ values can pull some weights below zero or above the base-weight maximum.

```r
#| echo: false
# base-weight sum (systematic pps does not guarantee this equals N)
cat("Base weight total ", sum(weights(smho_dsgn)),
    "\nGREG weight total ", 
    # GREG-weight sum (must equal N by the intercept calibration constraint)
    sum(weights(sam_lin)),
    "\nPopulation size ", N)
```

\newpage

### 2. Use [COVID.csv](https://umich.instructure.com/courses/830923/files/46179015?wrap=1)[Download COVID.csv](https://umich.instructure.com/courses/830923/files/46179015/download?download_frd=1) as a nonprobability sample data and [GSS.csv](https://umich.instructure.com/courses/830923/files/46179021?wrap=1)[Download GSS.csv](https://umich.instructure.com/courses/830923/files/46179021/download?download_frd=1) as a reference probability sample data from Exercise Nonprob of Class 12 Lab.

The analysis goal is to estimate the relationship between the opinion about the influence of politics on the Covid vaccine development and political ideology through a linear regression model. These two characteristics are measured in variables VAC_POLITICS and POLVIEWS in the nonprobability sample dataset. Given the nonprobability nature of the sample on which COVID.csv were collected, an adjustment is needed.[^1]

[^1]: The nonprobability sample is COVID.csv (MTurk volunteers, ages 18 to 75). The probability reference sample is GSS.csv (2021 General Social Survey, same age range, with a survey weight FINWGT). The outcome is VAC_POLITICS, a 1 to 7 scale measuring agreement with the statement that politics influenced COVID vaccine development. The predictor of interest is POLVIEWS, a 1 to 7 scale where higher values are more conservative. Following the Class 12 lab, we recode MALE == 2 in COVID (a small "other" category) to 0 so MALE is comparable across datasets.

```r
# load the two samples 
COVID <- read_csv(here("COVID.csv"), show_col_types = FALSE) |> 
  mutate(MALE = if_else(MALE == 2, 0, MALE),
         FINWGT = 1) # nonprob sample has no design weight

GSS <- read_csv(here("GSS.csv"), show_col_types = FALSE)

```

```r
#| echo: false

cat("Covid sample size ", nrow(COVID),
    "\nGSS sample size", nrow(GSS))

```

#### (a) The model is to regress VAC_POLITICS on POLVIEWS controlling for variables AGE, MALE, HRACE and Report the estimated model. What does the slope of POLVIEWS suggest?

-   We regress VAC_POLITICS on POLVIEWS, controlling for AGE, MALE, and HRACE. HRACE enters as a factor since its codes represent categories (1 = Hispanic, 2 = non-Hispanic White, 3 = non-Hispanic Black, 4 = non-Hispanic Other).

```r
m1 <- lm(VAC_POLITICS ~ POLVIEWS + AGE + factor(MALE) + factor(HRACE),
         data = COVID)

```

-   The fitted model is

$$
\begin{aligned}
VAC\_POLITICS_i = \beta_0 &+ \beta_1 POLVIEWS_i + \beta_2 AGE_i + \beta_3 I(MALE_i = 1) \\
&+ \beta_4 I(HRACE_i = 2) + \beta_5 I(HRACE_i = 3) + \beta_6 I(HRACE_i = 4) + \varepsilon_i
\end{aligned}
$$

\newpage

```r
#| echo: false

jtools::summ(m1, digits = 4)

```

-   The slope on POLVIEWS is positive and statistically significantly different from zero. A one-point shift toward the conservative end of the scale is associated with roughly a `r round(coef(m1)["POLVIEWS"], 2)`-point increase in agreement that politics influenced vaccine development, after adjusting for age, sex, and race/ethnicity. More conservative MTurk respondents report stronger agreement that politics shaped COVID vaccine development.

\newpage

#### (b) Combine the probability and nonprobability sample data, and build a logistic regression model where the dependent variable is a binary (1. Nonprobability sample; 0. Probability sample) on AGE, MALE, HRACE, EDUC and PARTY. Apply weights in the model estimation. Report the estimated model.

-   We stack the two samples and fit a weighted logistic regression predicting sample membership. This is the quasi-randomization approach from VDK section 18.4.1. The response NONPROB equals 1 for COVID rows and 0 for GSS rows. The weight is FINWGT, which is 1 for COVID and the GSS design weight for GSS. Rows missing any predictor are dropped, since they would lack a predicted probability.

```r
# stack and drop cases with missing on any predictor
COMB <- COVID |>
  mutate(NONPROB = 1) |> 
  add_row(
    GSS |> mutate(NONPROB = 0)
    ) |> 
  select(NONPROB, AGE, MALE, HRACE, EDUC, PARTY, FINWGT, ID) |> 
  drop_na() 

# weighted logistic regression of sample membership on auxiliaries
prop <- glm(NONPROB ~ AGE + factor(MALE) + factor(HRACE) +
              factor(EDUC) + factor(PARTY),
            family = binomial(link = "logit"),
            weights = COMB$FINWGT,
            data = COMB)


```

-   The fitted linear predictor $\hat L_i = x_i^T \hat\beta$ gives the log-odds of being in the nonprobability sample given the auxiliaries. The inverse-logit transform produces $\hat p_i = \Pr(C_i = 1 \mid x_i)$, and the pseudo-weight is $w_i = 1 / \hat p_i$.

\newpage

```r
#| echo: false

jtools::summ(prop, digits=4)

```

```r
# predicted log-odds, probabilities, & pseudo-weights
COMB <- COMB |> 
  mutate(L_hat = prop$linear.predictors,
         pseudo_probs = exp(L_hat) / (1 + exp(L_hat)),
         pseudo_wt = 1 / pseudo_probs)
```

\newpage

#### (c) Report the estimated propensity scores of the nonprobability and reference samples, respectively, using boxplots. Describe your observation.

-   We look at the propensity distributions separately for both samples. Heavy overlap means the auxiliaries do not distinguish the samples, which supports the common support assumption behind the pseudo weights (VDK sec 18.4.1). A clean separation would signal model based rather than data based adjustment.

```r
prop_summary <- COMB |> 
  group_by(NONPROB) |> 
  reframe(n = n(),
            Min = min(pseudo_probs),
            Q1 = quantile(pseudo_probs, 0.25),
            Median = median(pseudo_probs),
            Mean = mean(pseudo_probs),
            Q3 = quantile(pseudo_probs, 0.75),
            Max = max(pseudo_probs)) |> 
  mutate(Sample = if_else(NONPROB == 1, "COVID (nonprob)", "GSS (prob)")) |> 
  select(Sample, n, Min, Q1, Median, Mean, Q3, Max)

```

```r
#| fig-width: 7
#| fig-height: 4
#| echo: false
prop_summary |> 
  kable(digits = 4, 
        caption = "Estimated propensity scores: COVID vs. GSS")

COMB |> 
  mutate(Sample = if_else(NONPROB == 1, "COVID (nonprob)", "GSS (prob)")) |> 
  ggplot(aes(x = Sample, y = pseudo_probs, fill = Sample)) +
  geom_violin(alpha = 0.4, color = NA) +
  geom_boxplot(width = 0.15, outlier.shape = 21, outlier.size = 2) +
  stat_summary(fun = range, geom = "text",
               aes(label = after_stat(round(y, 4))),
               position = position_nudge(x = 0.25), size = 3) +
  scale_fill_viridis(discrete = TRUE, end = 0.8, guide = "none") +
  labs(x = NULL,
       y = "Estimated propensity Pr(C = 1 | X)",
       title = "Propensity-score distributions by sample") +
  theme_minimal()
```

-   The COVID distribution sits higher than GSS, since the auxiliaries do carry information that distinguishes MTurk volunteers from the general population. The two distributions overlap substantially, so common support holds (VDK sec 18.4.1). The COVID distribution has a long left tail of low propensities, which will translate into a long right tail of large pseudo-weights (since $w_i = 1/\hat p_i$).

```r
# | echo: false
# pseudo-weight summary for COVID cases
COMB |> 
  filter(NONPROB == 1) |> 
  reframe(Min = min(pseudo_wt), 
          Q1 = quantile(pseudo_wt, 0.25),
          Median = median(pseudo_wt), 
          Mean = mean(pseudo_wt),
          Q3 = quantile(pseudo_wt, 0.75), 
          Max = max(pseudo_wt)) |> 
  kable(digits = 3, 
        caption = "Pseudo-weights for COVID (nonprob) cases")
```

-   The pseudo-weights for the COVID cases range from 1.58 to 144.31 with a mean of 8.59, confirming that a few cases with very low propensities receive disproportionately large weights.

\newpage

#### (d) Use the propensities estimated in #2 directly to create adjustment weights for the nonprobability Estimate the model in #1 with these weights. Report the regression slope of POLVIEWS with its standard error.

-   We keep the COVID rows from COMB, join VAC_POLITICS and POLVIEWS, and build a survey design with the pseudo-weights to refit the Part 2a model via `svyglm`.

```r
# keep COVID cases, drop missing
COVID_ADJ <- COMB |> 
  filter(NONPROB == 1) |> 
  left_join(
    COVID |> 
      select(ID, VAC_POLITICS, POLVIEWS), by = "ID") |> 
  drop_na(VAC_POLITICS, POLVIEWS)

# survey design with pseudo-weights
dCOVID_ADJ <- svydesign(ids = ~0, strata = NULL,
                        data = COVID_ADJ, weights = ~pseudo_wt)

# same regression as m1, now weighted
m4 <- svyglm(VAC_POLITICS ~ POLVIEWS + AGE + factor(MALE) + factor(HRACE),
             design = dCOVID_ADJ)

```

```r
#| echo: false
jtools::summ(m4, digits=4)
```

-   The pseudo-weighted slope on POLVIEWS is 0.277 (SE = 0.050, p \< 0.001). After adjusting for the nonprobability sample's demographic and political composition, a one-point shift toward the conservative end of the scale is associated with a 0.28-point increase in agreement that politics influenced vaccine development.

#### (e) Compare the results in part #1 and part #4 on the regression slopes of POLVIEWS. Explain the reason for any similarities and/or differences you see.

```r
# use the POLVIEWS slope and SE from both models 
m4_polviews <- tibble(
  Model = c("m1: unweighted (Part 2a)", "m4: pseudo-weighted (Part 2d)"),
  Slope = c(coef(m1)["POLVIEWS"], coef(m4)["POLVIEWS"]),
  SE = c(summary(m1)$coefficients["POLVIEWS", "Std. Error"],
            summary(m4)$coefficients["POLVIEWS", "Std. Error"]))

```

```r
#| echo: false


m4_polviews |> 
  kable(digits = 4,
        caption = "POLVIEWS slope: unweighted vs. pseudo-weighted")

```

-   Both models provide a positive slope of similar magnitude, yet the pseudo-weighted standard error is larger. The point estimates are close since POLVIEWS is not in the propensity model. Pseudo-weighting rebalances the sample on the predictors, but does not directly impact the conditional relationship between POLVIEWS and VAC_POLITICS. Therefore, it seems that reweighting slightly moves the slope. The SE increases due to the pseudo-weights having a wide range. Variance inflation from unequal weights takes the form $1 + \text{relvar}(w)$ (VDK sec 14.5), and a few COVID cases with very low $\hat p_i$ get very large weights. `svyglm` accounts for this through a Horvitz-Thompson sandwich variance, while `lm` assumes i.i.d. errors and treats all observations as equally informative. The `lm` SE therefore understates sampling uncertainty for this nonprobability sample, and the `svyglm` SE is the honest one to report. The unweighted slope can be biased when auxiliaries that predict selection also relate to the outcome. Under the MAR assumption (VDK ch 13 & 18), pseudo-weighting corrects this bias by trading some precision.
