---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_9_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 9"
original: "PracTools_SURV745/assignments/SURV745_Assign_9_Linares.qmd"
pages: 
sha256: "1ace17d96c518ea14aae1e96a224302899755468f585a58f7e6859a3c8fd94b4"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:13"
---


```r
pacman::p_load(tidyverse, knitr, viridis, kableExtra, survey)
options(scipen = 999)

nhis <- read_csv(
  "D:/repos/UMD_classes_code/PracTools_SURV745/assignments/nhis2014_paradata.csv", 
                 show_col_types = FALSE)
```

## The National Health Interview Survey (NHIS) is an important source of information about the health of the civilian noninstitutionalized population of the United States by the Centers for Disease Control and Prevention (CDC). NHIS is conducted every year and provides its paradata apart from the survey data.

## For this homework, use [nhis2014_paradata.csv](https://umich.instructure.com/courses/830923/files/45785309?wrap=1). This dataset incudes a subset of variables illustrated in the codebook, [NHIS2014 paradata_freq](https://umich.instructure.com/courses/830923/files/45785311?wrap=1). [NHIS2014 paradata_description](https://umich.instructure.com/courses/830923/files/45785310?wrap=1) provides overall descriptions about the dataset.

## Assume that CTSTAT3 is the outcome variable. The sample is not an *epsem*, and variable, WTIA_PD is the base weights.

### 1. Use OUTCOME1 variable and re-classify outcome into four categories of “response”, “nonresponse”, “ineligible” and “unknown eligibility” [following VDK Ch 6 and provide your justification for this re-classification.]{.underline} Make this re-classification as a variable, OUTCOME. Show the crosswalk of categories between OUTCOME1 and OUTCOME by cross-tabulating them with OUTCOME1 as a row variable and OUTCOME as a column variable.

-   Following VDK Chapter 6, Table 6.2, each sample unit is mapped to one of seven AAPOR categories in the table below.: I (complete interview), P (partial interview), R (refusal/break-off), NC (noncontact), U (unknown eligibility), NE (not eligible), and O (other). These seven categories are then collapsed into four groups: **response** (I + P), **nonresponse** (R + NC + O), **ineligible** (NE), and **unknown eligibility** (U).

\newpage

-   The NHIS paradata OUTCOME1 codes are mapped as follows:
    -   **201 (Fully complete case) → I → response.** The household completed all modules (household composition, family, sample adult, and sample child if present). This satisfies the AAPOR definition of a complete interview.
    -   **203 (Sufficient partial case) → P → response.** At least a sufficient portion of the family module was completed. Per VDK Table 6.2, partially complete interviews with sufficient data for analysis objectives are classified as P (eligible respondents).
    -   **213 (Language problem) → O → nonresponse.** Contact was made but the interview could not be completed due to a language barrier. The household is known to be eligible (it was contacted and located), but data collection failed for a reason other than refusal or noncontact. Consistent with the ATUS concordance in VDK Table 6.3, where language barriers (codes 21, 121) are mapped to O.
    -   **215 (Insufficient partial) → R → nonresponse.** The family module was started but not completed to a sufficient degree. Per VDK Section 6.1, records with insufficient data (break-offs) are classified as R if the participants are verified to be eligible.
    -   **216 (No one home, repeated calls) → NC → nonresponse.** The household was never contacted despite repeated attempts. This is the definition of noncontact (VDK Table 6.2): sample members never contacted but known to be eligible based on the sampling frame.
    -   **217 (Temporarily absent, no follow-up) → NC → nonresponse.** The household was identified but the occupants were temporarily unavailable during the field period. Similar to code 216, contact was not achieved with the target respondent.
    -   **218 (Refusal) → R → nonresponse.** The household refused to participate. Refusals are classified as R per VDK Table 6.2, as these cases are verified eligible but declined.
    -   **219 (Other Type A) → O → nonresponse.** A catch-all for other in-scope nonresponse. Per VDK Table 6.2, eligible cases not fitting other categories go to O.
    -   **299 (Type B: Armed Forces, usual residence elsewhere, screened out by race/ethnicity) → NE → ineligible.** These cases are out of scope for the NHIS civilian noninstitutionalized population. Per the paradata description, Type B cases are ineligible for interview.
-   **Note on unknown eligibility:** The NHIS paradata description (p. 7) classifies all codes 213--219 as "in-scope cases / Type A cases (nonresponding)," which implies that the NHIS considers eligibility to be established for these cases. Under a strict reading of this convention, all Type A cases would be treated as known eligible and U = 0. However, code 219 is a heterogeneous residual category that may contain cases where eligibility was never fully established. For example, inaccessible units or cases with uncertain occupancy status. Following VDK Section 6.4, which emphasizes that the treatment of ambiguous cases should be justified and documented, I reclassify 219 as unknown eligibility (U). This provides a non-trivial $e \times U$ term in the RR3 calculation and a non-trivial unknown eligibility adjustment in Q3. We print the cross-tabulation of outcome1 by outcome below.

\newpage

```r
# classify outcomes as aapor codes
nhis <- nhis |>
  mutate(
    AAPOR = case_when(
      OUTCOME1 == 201 ~ "I",
      OUTCOME1 == 203 ~ "P",
      OUTCOME1 == 215 ~ "R",
      OUTCOME1 == 218 ~ "R",
      OUTCOME1 == 213 ~ "O",
      OUTCOME1 == 216 ~ "NC",
      OUTCOME1 == 217 ~ "NC",
      OUTCOME1 == 219 ~ "U",
      OUTCOME1 == 299 ~ "NE"),
    # create eligibility codes
    OUTCOME = case_when(
      AAPOR %in% c("I", "P") ~ "response",
      AAPOR %in% c("R", "NC", "O") ~ "nonresponse",
      AAPOR == "NE" ~ "ineligible",
      AAPOR == "U" ~ "unknown eligibility"),
    # save outcome as a factor w/ levels
    OUTCOME = factor(OUTCOME, 
                     levels = c("response", "nonresponse", 
                                "ineligible", "unknown eligibility")))

# build crosstab table
crosstab <- nhis |>
  # get counts
  count(OUTCOME1, OUTCOME) |>
  # restructure table
  pivot_wider(names_from = OUTCOME, values_from = n, values_fill = 0)

# print table
crosstab |> kable()
```

\newpage

### 2. What is the response rate using AAPOR RR3? Show both weighted and unweighted response rates.  	 

-   AAPOR RR3 uses only complete interviews (I) in the numerator and applies the eligibility rate adjustment $e$ to the unknown eligibility cases (U) in the denominator (VDK 6.2.5):

$$
\text{RR3} = \frac{I}{I + P + R + NC + O + (e \times U)}
$$

-   where the eligibility rate $e$ is estimated among cases with known eligibility status (VDK 6.2.3):

$$
e = \frac{I + P + R + NC + O}{I + P + R + NC + O + NE}
$$

```r
# comptutes counts for each code
counts <- nhis |>
  count(AAPOR) |>
  deframe()

I_n <- counts["I"]
P_n <- counts["P"]
R_n <- counts["R"]
NC_n <- counts["NC"]
O_n <- counts["O"]
U_n <- counts["U"]
NE_n <- counts["NE"]

# eligibility rate
e_uw <- (I_n + P_n + R_n + NC_n + O_n) / 
        (I_n + P_n + R_n + NC_n + O_n + NE_n)

# RR3 unweighted
rr3_uw <- I_n / (I_n + P_n + R_n + NC_n + O_n + (e_uw * U_n))

```

-   For the weighted rates, we replace counts with sums of base weights (WTIA_PD) within each AAPOR category, following VDK Section 6.5:

\newpage

```r
# weighted counts
wt_counts <- nhis |>
  group_by(AAPOR) |>
  reframe(wt = sum(WTIA_PD), .groups = "drop") |>
  deframe()

I_w <- wt_counts["I"]
P_w <- wt_counts["P"]
R_w <- wt_counts["R"]
NC_w <- wt_counts["NC"]
O_w <- wt_counts["O"]
U_w <- wt_counts["U"]
NE_w <- wt_counts["NE"]

# eligibility rate
e_wt <- (I_w + P_w + R_w + NC_w + O_w) / 
        (I_w + P_w + R_w + NC_w + O_w + NE_w)
# RR3 weighted
rr3_wt <- I_w / (I_w + P_w + R_w + NC_w + O_w + (e_wt * U_w))
```

```r
# put RRs together in a table
tibble(
  Metric = c("Eligibility rate (e)", "RR3"),
  Unweighted = c(round(e_uw, 4), round(rr3_uw, 4)),
  Weighted = c(round(e_wt, 4), round(rr3_wt, 4))) |>
  kable()
```

\newpage

### 3. Based on the re-classification	in #1, adjust for unknown eligibility. For doing so, use CENREG as a variable for adjustment classes. For cases whose eligibility is known, present a scatter plot between the base weights and the unknown eligibility adjusted weights.  	

-   Following VDK Chapter 13, Section 4, we adjust for unknown eligibility by forming adjustment classes based on CENREG (Census region). Within each class $b$, the adjustment factor is (VDK Ch. 13):

$$
a_{1b} = \frac{\sum_{i \in s_b} d_{0i}}{\sum_{i \in s_{b,KN}} d_{0i}}
$$

-   where $d_{0i}$ is the base weight (WTIA_PD), $s_b$ is the set of all sample units in class $b$, and $s_{b,KN}$ is the set of units with known eligibility status in class $b$. The unknown eligibility adjusted weight for unit $i$ in $s_{b,KN}$ is $d_{1i} = a_{1b} \times d_{0i}$, and weights for units with unknown eligibility are set to zero.

```r
# flag known eligibility: everyone except "unknown eligibility"
nhis <- nhis |>
  mutate(known_elig = OUTCOME != "unknown eligibility")

# compute adjustment factor by CENREG
ue_adj <- nhis |>
  group_by(CENREG) |>
  reframe(
    sum_d0_all  = sum(WTIA_PD),
    sum_d0_known = sum(WTIA_PD[known_elig]),
    n_all = n(),
    n_known = sum(known_elig),
    n_unknown = sum(!known_elig)) |>
  mutate(a1b = sum_d0_all / sum_d0_known)

```

-   Scatter plot of base weights ($d_{0i}$) vs. unknown eligibility adjusted weights ($d_{1i}$) for cases with known eligibility:

```r
#| fig-width: 6
#| fig-height: 5

nhis <- nhis |>
  left_join(ue_adj |> select(CENREG, a1b), by = "CENREG") |>
  mutate(d1 = if_else(known_elig, a1b * WTIA_PD, 0))

nhis |>
  filter(known_elig) |>
  ggplot(aes(x = WTIA_PD, y = d1)) +
  geom_point(alpha = .25, size = .5) +
  geom_abline(slope = 1, intercept = 0, color = "dodgerblue", linetype = "dashed") +
  labs(x = expression(paste("Base Weight (", d[0*i], ")")),
    y = expression(paste("UE-Adjusted Weight (", d[1*i], ")")),
    title = "Base Weights vs. Unknown Eligibility Adjusted Weights",
    subtitle = "Cases with known eligibility only; blue line is y = x") +
 theme_minimal()
```

-   The unknown eligibility adjusted weights are slightly larger than the base weights because the weight of the unknown cases is redistributed to the known cases within each Census region. The adjustment factors $a_{1b}$ are all close to 1 because only a small fraction of cases (code 219) are classified as unknown eligibility.

\newpage

### 4.  What is the mean of CTSTAT3 among nonrespondents without weights and using base weights? What do you observe? Why do you think you observe what you observe?

-   CTSTAT3 is the number of noncontacts for each case. We compute the mean among nonrespondents (OUTCOME = "nonresponse") both unweighted and using base weights.

```r

nr_data <- nhis |>
  filter(OUTCOME == "nonresponse")

mean_uw <- mean(nr_data$CTSTAT3, na.rm = TRUE)
mean_wt <- weighted.mean(nr_data$CTSTAT3, nr_data$WTIA_PD, na.rm = TRUE)

tibble(
  Estimate = c("Unweighted mean", "Weighted mean (base weights)"),
  Value = round(c(mean_uw, mean_wt), 4)) |>
  kable()
```

-   The weighted and unweighted means of CTSTAT3 among nonrespondents differ because the NHIS sample is not an epsem design. The base weights (WTIA_PD) reflect the differential selection probabilities across strata and PSUs. Cases with larger weights (i.e., those representing more population units) may have systematically different noncontact patterns than cases with smaller weights. For example, cases in regions or strata that are oversampled (i.e., lower weights) may be in harder-to-reach areas with higher noncontact counts. Moreover, cases with larger weights may come from areas where the survey is less dense and contact patterns differ. The divergence between the two means reflects the fact that the noncontact experience is not uniformly distributed across the sampling design, and weighting adjusts for the unequal probabilities of selection.

\newpage

### 5. Consider CENREG, STRAT_P and INTV_MON as covariates available for all sample cases and fit a weighted response propensity model. With the propensity weighting method that uses the estimated propensity score for individual cases directly, create nonresponse adjusted weights on the unknown eligibility adjusted weights.  	

-   Following VDK Chapter 13, Section 5.3 (lecture slides pp. 51--63), we fit a weighted logistic regression for response propensity among cases with known eligibility, using the covariates CENREG, STRAT_P, and INTV_MON. The response indicator $R_i = 1$ if the case is a respondent and 0 if a known eligible nonrespondent. Known ineligibles are excluded from the model.

    -   We use the propensity weighting method (VDK Ch. 13) that uses the estimated propensity score $\hat{\phi}_i$ for individual cases directly. The nonresponse adjusted weight is:

$$
d_{2i} = \frac{d_{1i}}{\hat{\phi}_i} \quad \text{for respondents}
$$

```r

# restrict to known eligible cases (exclude ineligible and unknown)
eligible <- nhis |>
  filter(OUTCOME %in% c("response", "nonresponse")) |>
  mutate(
    resp = as.integer(OUTCOME == "response"),
    CENREG = factor(CENREG),
    INTV_MON = factor(INTV_MON))
```

```r
#| echo: false

cat("Eligible cases:", nrow(eligible), "\n")
cat("Respondents:", sum(eligible$resp == 1), "\n")
cat("Nonrespondents:", sum(eligible$resp == 0), "\n")


```

```r

# Set up survey design with stratification and clustering
nhis_dsgn <- svydesign(ids = ~PSU_P,
                       strata = ~STRAT_P,
                       data = eligible,
                       nest = TRUE,
                       weights = ~d1)

# Fit weighted logistic regression using svyglm
glm_prop <- svyglm(
  resp ~ CENREG + STRAT_P + INTV_MON,
  family= binomial(link = "logit"),
  design = nhis_dsgn)

summary(glm_prop)

# Extract linear predictors and transform to probability scale
L_hat <- glm_prop$linear.predictors
eligible <- eligible |>
  mutate(phi_hat = exp(L_hat) / (1 + exp(L_hat)))

summary(eligible$phi_hat)
```

\newpage

#### a)  Compare the propensity scores between respondents and nonrespondents.

```r
#| fig-width: 7
#| fig-height: 5

eligible |>
  mutate(Response = if_else(resp == 1, "Respondent", "Nonrespondent")) |>
  ggplot(aes(x = phi_hat, fill = Response)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 50) +
  labs(x = expression(hat(phi)[i]),
    y = "Count",
    title = "Distribution of Estimated Propensity Scores",
    subtitle = "Respondents vs. Nonrespondents") +
  scale_fill_manual(values = c("Respondent" = "dodgerblue", 
                                "Nonrespondent" = "tomato")) +
  theme_minimal()
```

```r
eligible |>
  mutate(Response = if_else(resp == 1, "Respondent", "Nonrespondent")) |>
  group_by(Response) |>
  reframe(
    n = n(),
    mean_phi = round(mean(phi_hat), 4),
    median_phi = round(median(phi_hat), 4),
    sd_phi = round(sd(phi_hat), 4),
    min_phi = round(min(phi_hat), 4),
    max_phi = round(max(phi_hat), 4)) |>
  kable()
```

-   As expected, respondents have higher estimated propensity scores on average than nonrespondents. The overlap in distributions is consistent with the covariates providing some but not complete separation between respondents and nonrespondents.

#### b) Compare the sum of the unknown eligibility adjusted weights and the sum of the nonresponse adjusted weights.  		

-   The nonresponse adjusted weight for respondents is $d_{2i} = d_{1i} / \hat{\phi}_i$. Nonrespondents receive a weight of 0 after nonresponse adjustment.

```r
# apply propensity weighting to respondents only
eligible <- eligible |>
  mutate(d2 = if_else(resp == 1, d1 / phi_hat, 0))

sum_d1_eligible <- sum(eligible$d1)
sum_d1_resp <- sum(eligible$d1[eligible$resp == 1])
sum_d2_resp <- sum(eligible$d2[eligible$resp == 1])

tibble(
  Weight = c(
    "Sum of d1 (all eligible cases)",
    "Sum of d1 (respondents only)",
    "Sum of d2 (NR-adjusted, respondents only)"),
  Value = format(round(c(sum_d1_eligible, sum_d1_resp, sum_d2_resp), 1), 
                 big.mark = ",")) |>
  kable()
```

-   The sums are very close but not exactly identical. This is expected with individual propensity weighting (VDK Ch. 13): when using the individual $\hat{\phi}_i$ directly rather than forming propensity classes and applying a common within-class adjustment, the weight totals will not match exactly. If propensity stratification were used instead, the sums would be equal by construction.

#### c) For respondents, provide a scatter plot of the unknown eligibility adjusted weights and the nonresponse adjusted weights.  		

```r
#| fig-width: 6
#| fig-height: 5

eligible |>
  filter(resp == 1) |>
  ggplot(aes(x = d1, y = d2)) +
  geom_point(alpha = 0.15, size = 0.5) +
  geom_abline(slope = 1, intercept = 0, color = "tomato", linetype = "dashed") +
  labs(x = expression(paste("UE-Adjusted Weight (", d[1*i], ")")),
    y = expression(paste("NR-Adjusted Weight (", d[2*i], ")")),
    title = "UE-Adjusted vs. NR-Adjusted Weights (Respondents)",
    subtitle = "Red line is y = x") +
  theme_minimal()
```

-   All points lie above the $y = x$ line because the nonresponse adjustment inflates respondent weights ($d_{2i} = d_{1i} / \hat{\phi}_i > d_{1i}$ since $\hat{\phi}_i < 1$). Cases with lower estimated response propensities receive larger upward adjustments.

\newpage

### 6. Focus on the respondents only. Estimate the mean of CTSTAT3 1) without weights, 2) with base weights and 3) with unknown eligibility + nonresponse adjusted weights. Compare these estimates against the results in #4. Describe your observation.

-   We now estimate the mean of CTSTAT3 among respondents only, using three weighting schemes, and compare against the nonrespondent means from question 4.

```r

resp_data <- eligible |>
  filter(resp == 1)

mean_resp_uw <- mean(resp_data$CTSTAT3, na.rm = TRUE)
mean_resp_base <- weighted.mean(resp_data$CTSTAT3, resp_data$WTIA_PD, 
                                na.rm = TRUE)
mean_resp_d2 <- weighted.mean(resp_data$CTSTAT3, resp_data$d2, 
                                na.rm = TRUE)

tibble(
  Estimate = c(
    "Respondents: unweighted",
    "Respondents: base weights (d0)",
    "Respondents: NR-adjusted weights (d2)",
    "Nonrespondents: unweighted (from #4)",
    "Nonrespondents: base weights (from #4)"),
  Mean_CTSTAT3 = round(c(mean_resp_uw, mean_resp_base, mean_resp_d2,
                          mean_uw, mean_wt), 4)) |>
  kable()
```

-   The average number of noncontact attempts (CTSTAT3) is much higher for nonrespondents than for respondents. This is expected: cases that ultimately responded were probably easier to contact and required fewer noncontact attempts, while nonrespondents continued to accumulate contact attempts without completing an interview. Among the respondent estimates, the three means are similar but show a consistent ordering: the unweighted mean is the lowest, followed by the base-weighted mean, then the NR-adjusted ($d_{2i}$) mean is the highest. The NR-adjusted estimate is pulled slightly upward because propensity weighting inflates the weights of respondents who resemble nonrespondents (i.e., those with lower estimated response propensities and, presumably, more noncontact attempts). However, the adjustment is modest because the available covariates (CENREG, STRAT_P, INTV_MON) have limited ability to distinguish respondents from nonrespondents, and the NR-adjusted respondent mean remains well below the nonrespondent mean.
