---
id: "jpsm/Fund_Infe_SURV740/assignments/HW2"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Homework 2: Introduction to Causal Inference"
original: "Fund_Infe_SURV740/assignments/HW2.qmd"
pages: 
sha256: "40aa1088b871966fb6281424f631a1b095d9214dacb87f17e231ac6194d04a26"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:01"
---


```r
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)

pacman::p_load(tableone, Matching, knitr, survey, ipw, jtools, tidyverse)

options(scipen=999)
```

### Problem 1: Age and Education for a small sample are provided below for 2 treated units (I = 1, 2) and 2 control units (j = 1, 2). Both covariates are predictive of the outcome of Income (in \$10k).

## Given Data

```r
# Create the data frame with given values
q1_dat <- tibble(
  unit = c("T1", "T2", "C1", "C2"),
  treatment = c(1, 1, 0, 0), # 1 = treated
  age = c(25, 30, 30, 40),
  edu = c(1, 1, 0, 1),  # 1 if Master+; 0 otherwise
  income = c(15, 22, 10, 15)  # in $10k
)

# print the table
q1_dat |> kable()
```

The covariance matrix between age and education is given as $\sum_{AGE, EDU}$:

```r
# Given covariance matrix
cov_matrix <- matrix(c(10, 0.2, 0.2, 1), nrow = 2, byrow = TRUE)
colnames(cov_matrix) <- rownames(cov_matrix) <- c("Age", "Edu")
print(cov_matrix)
```

\

### a) Conduct optimal matching to find the matched unit j to the treated unit i, denoted by $j_i$, using Mahalanobis distance. Fill in the last column in the table below. (Hint, in R the function "`solve(matrix(a,b,c,d),2,2))`" to solve for:

\begin{align*}
\begin{pmatrix} 
  a & b \\ 
  c & d  
\end{pmatrix}^{-1}
\end{align*}

### ; For matrix multiplication in R, please use “`%*%`”). Provide computation details.

-   The equationfor the mahalanobis distance is as follows:

$$
d(i, j) = \sqrt{(x_i - x_j)^T \hat\sum^{-1}(x_i-x_j)},
$$

-   where $x_i$ and $x_j$ are values of the matching variables for treated subject $i$ and untreated subject $j$. $\hat\sum$ is the sample covariance matrix for the observations.

    -   We first calculate the inverse covariance matrix that we are given above for age and education.

```r
cov_inv <- solve(cov_matrix)
print(cov_inv, 4)

```

-   We create a function that takes $x_i, x_j$ and the covariance inverse matrix to calculate the mahalanobis distance.

```r
mahal_dist_fun <- function(xi, xj, cov_inv) {
  diff = xi - xj # take the difference from 
  dist = sqrt(t(diff) %*% cov_inv %*% diff) # t() is transpose
  dist = as.numeric(dist)
  
  return(dist)
}
```

-   Next, we apply this function to the treated groups, treated i =1 and i=2, against the control j=1, and j=2 groups.

    -   We add the mahalanobis distance values for the treated rows by control j1 and j2 back to the dataframe below.

```r
# treatment group
x_i1 <- q1_dat |> filter(unit=="T1") |> select(age, edu) |> as.double()
x_i2 <- q1_dat |> filter(unit=="T2") |> select(age, edu) |> as.double()

# control group
x_j1 <- q1_dat |> filter(unit=="C1") |> select(age, edu) |> as.double()
x_j2 <- q1_dat |> filter(unit=="C2") |> select(age, edu) |> as.double()

# apply the function for optimal matching for treaed  i=1
d_i1_j1 <- mahal_dist_fun(x_i1, x_j1, cov_inv) 
d_i1_j2 <- mahal_dist_fun(x_i1, x_j2, cov_inv)

# apply the function for optimal matching for treaed  i=1
d_i2_j1 <- mahal_dist_fun(x_i2, x_j1, cov_inv)
d_i2_j2 <- mahal_dist_fun(x_i2, x_j2, cov_inv)

# add these to the dataframe
q1_dat_dist <- q1_dat |> 
  filter(str_detect(unit, "T")) |> 
  mutate(j1 = c(d_i1_j1, d_i2_j1), 
         j2 = c(d_i1_j2, d_i2_j2))

q1_dat_dist |> kable()

```

-   We are interested in optimal matching as it minimizes the total distance. Therefore, we compare two possible pairings.

    -   The first paring is $(i=1, j=1) \& (i=2, j=2) = 1.927+ 3.169 = 5.096$ , and the second pairing is $(i=1, j=2) \&(i=2, j=1) = 1.002 + 4.753 = 5.755$. The optimal pairing $(i=1, j=1) \& (i=2, j=2)$ has the lowest total distance.

```r

tibble(
  Matching_Pairs = c(1, 2),
  Treated_i = c("i=1", "i=2"),
  control_j_i = c("j=1", "j=2")
) |> kable()
  
```

##  

### b) Estimate ACE using matched pair.

-   Estimation of ACE after matching is a three step process where we first find a match, check on the outcome of the treated and matched controls, and estimate the individual causal effect (ICE) as:

$$
\widehat{ICE}(x_i) = (y_i - y_{j(i)} ) 
$$

-   We can use ICE to estimate the average causal effect (ACE) as:

$$
\widehat{ACE} = \frac{1}{n}\sum \widehat{ICE}(x_i)
$$

-   We use these equations to estimate ACE below for the matched pairs after estimating ICE for each individual pair, and find that the estimate is $ACE = \widehat{8.5}$.

    -   The ACE represents the average difference in income between matched pairs, providing a causal estimate under the assumption that all confounders are captured by the observed covariates. We see that the estimated ACE of the treatment on income is \$60,000.

```r
ice_pair1 <- 15 - 10  # i1 - j1
ice_pair2 <- 22 - 15  # i2 - j2

ace_matched <- mean(c(ice_pair1, ice_pair2))

ace_matched
```

##  

### c) Construct propensity score weights and fill in the last two columns in the table below.

-   We are given the model propensity scores for each subject in the e_x column. To calculate the propensity score weights, we apply to the treated individuals 1 / by their propensity score, and for the control group 1 / (1 - propensity score), or the inverse of their score. We than estimate the weighted income outcome in column income_x_w.

```r
# modify dataframe 1

q1_dat_2 <- q1_dat |> 
  select(unit, income) |> 
  mutate(treated = c(1, 1, 0, 0),
    e_x = c(0.25, 0.4, 0.33, 0.5),  # given propensity scores
  ps_weight = ifelse(treated == 1, 1/e_x, 1/(1-e_x)), 
  income_x_w = income * ps_weight) 

q1_dat_2 |> kable()

```

\

### d) Estimate the average causal effect using the measure of risk difference (RD).

-   First, we compute the weighted means for the treatment and control groups separetly. We use the propensity weights and the weighted income that we computed in c).

    -   The weighted mean for treated is given as $E[Y|A=1] = \frac{\sum w_iY_i}{\sum w_i}$ and for the control $E[Y|A=1] = \frac{\sum w_jY_j}{\sum w_j}$ .

```r
weighted_mean <- q1_dat_2 |>
  group_by(treated) |> 
  reframe(
    total_weight = sum(ps_weight),
    weighted_sum = sum(income_x_w),
    weighted_mean = weighted_sum / total_weight
  )

weighted_mean |> kable()
```

-   Next, we can now calculate the risk difference AC as $RD = E[Y|A=1] - E[Y|A=0] = 4.83$. We can use this risk difference to estimate the average income difference as $4.83 \times 10000$ = \$48,300

```r
 weighted_mean |> 
  arrange(desc(treated)) |>  # start with treated group
  mutate(risk_diff = lag(weighted_mean) - weighted_mean) |> 
   slice(2) |> 
   select(risk_diff) |> 
   kable()
```

\

## Problem 2

### Apply propensity score methods to assess the causal effect of a treatment (New_Medication) on an outcome (Heart_Disease_Incident) using both propensity score matching and inverse probability weighting (IPW) methods. This problem reinforces concepts like confounding adjustment, balance assessment, and interpretation of causal effects. A sample of an observational study on cardiovascular disease for 500 patients, including several covariates (Age, Sex, BMI, Blood Pressure (BP), and Diabetes), along with a binary treatment variable (New_Medication) and outcome variable (Heart_Disease_Incident), is collected and saved under File on CANVAS. Ensure you have these R packages installed and loaded, including tableone, Matching, survey, ipw.

```r
# load data in
dat <- read_csv( 
  "D:/repos/UMD_classes_code/Fund_Infe_SURV740/homework/hw2Data.csv") |> 
  select(-1, -Smoker, -Cholesterol) # drop unused variables 
  
```

### a) Descriptive Statistics and Covariate Balance.

1.  Create a Table 1 for all covariates by New_Medication status, report both unadjusted means and standardized mean differences (SMDs).

    1.  We report below a table with adjusted means for 5 covariates, and the SMD.

```r
# covariates list
cov_names <- dat |> 
  select(-New_Medication:-Heart_Disease_Incident) |> 
  colnames()

# create table 1
table_1_unmatched <- CreateTableOne(vars=cov_names, 
                          strata="New_Medication", 
                          data=dat, 
                          test=FALSE)

table_df <- print(table_1_unmatched, smd=TRUE, printToggle=FALSE) 

table_df |> kable()
```

\

2.  Identify covariates with SMD \> 0.2 (indicating imbalance) and comment on how covariate imbalances could bias the treatment effect estimate.
    2.  Below we print below covariates with SMD \> .2 indicating imbalance indicating that the treatment and control groups may differ systematically on gender. Moreover, this can violate the exchangeabillity assumption which we need for causal inference.

```r
# extract SMD values from table_1_unadjust
## filter out values under .2
smd_values <- ExtractSmd(table_1_unmatched) 
  
smd_values |> 
  as.data.frame() |> 
  rownames_to_column() |> 
  rename(smd=2) |> 
  filter(smd > 0.2) |> 
  kable()

```

\newpage

### b) Propensity Score Matching

1.  Run logistic regression to estimate the propensity score (probability of receiving New_Medication given all five covariates).

    1.  Each of these coefficients in the logit model represents how the covariates influence treatment assignment. We save out predictions for each individual using the predict function to merge back into the data. Here we use 1:1 nearest-neighbor matching on the propensity score to create a balanced dataset.

```r
psmodel <- glm(New_Medication  ~ . -Heart_Disease_Incident, 
               data=dat, family = binomial())

summ(psmodel)

# save out predictions 
dat <- dat |> 
  mutate(ps = predict(psmodel, type="response"))
```

\

2.  Match each treated unit to a control unit with a similar propensity score using 1:1 nearest-neighbor matching without replacement.
    2.  We first transform propensity scores to a logit scale using a helper function, this essentially linearizes the matching distance. The caliper of .2 standard deviations will help us keep good matches. Controls in this case are only used once which we specify in the `repalace = FALSE` argument of the `Match()` function. We observe only 1 match dropped due to the caliper value.

```r
# helper function for logit transformation
logit <- function(p) {log(p) - log(1 - p)}

# greedy mathcing on logit(PS)
ps_match <- Match(
  Tr = dat$New_Medication,
  M = 1,
  X = logit(dat$ps),
  replace = FALSE,
  caliper = 0.2
)

# print how many matched paris dripped due to caliper
ps_match$ndrops

# Extract matched data
matched_data <- dat[unlist(ps_match[c("index.treated", "index.control")]), ]

# print he first few matched pairs. 
matched_data |> head() |> kable()
```

\

3.  Generate a new Table 1 after matching to examine covariate balance
    3.  We can now see that there is balance in the covariates and that the treated and control groups are comparable. The standardized differences are all below 0.2.

```r
table_matched <- CreateTableOne(vars=cov_names, 
                            strata ="New_Medication", 
                            data=matched_data, test = FALSE)

print(table_matched, smd = TRUE)


```

\

4.  Compare Heart_Disease_Incident between matched treatment and control groups using a paired t-test. Interpret the results.
    4.  We use a paired t-test since it accounts for the matching structure and see that the mean difference is .19 (t(127=5.16; p\<.0001) between the treated and control groups. That is, the new medication actually increases heart disease in this matched sample.

```r
# analysis on outcome
y_trt <- matched_data$Heart_Disease_Incident[
  matched_data$New_Medication==1]

y_con <- matched_data$Heart_Disease_Incident[
  matched_data$New_Medication==0]

# paired t-test
t.test( y_trt - y_con) # pairwise difference
```

### c. Inverse Probability Weighting (IPW)

1.  Construct IPW for each unit based on the estimated propensity scores obtained in Part b1) (Hint: Weight treated units by 1/PS and control units by 1/(1 - PS)).

    1.  We use IPW as an alternative method to control for confounding. Here we construct weights based on the propensity scores.

```r
# calculate the ips, save back to data
dat <- dat |> 
  mutate(ipw = ifelse(New_Medication == 1, 1/ps, (1/(1-ps))))
```

\

2.  Using the survey package, assess covariate balance in the weighted dataset by creating a Table 1 with SMD
    2.  We output a survey weighted table below to assess balance in the dataset, and find SMD values to all be \< 0.2.

```r

# create survey design with weights
weighted_data <- svydesign(ids = ~1, data = dat, weights = ~ipw)


# Create weighted Table 1
table1_weighted <- svyCreateTableOne(
  vars = cov_names, 
  strata = "New_Medication", 
  data = weighted_data, test = FALSE)

print(table1_weighted, smd = TRUE)
```

\

3.  Compare Heart_Disease_Incident between weighted treatment and weighted control groups by using a weighted regression model to estimate the effect of New_Medication. Interpret the results.
    3.  We build a weighted regression model to estimate the effect of new_medication on heart_disease_incident.
    4.  We estimate the causal risk difference between the control and treatment group at .1850, slightly smaller compared to the matching analysis. This analysis reveals that for the control group their risk for heart disease incidence increases by 3.3 percentage points; however, for the group treated with the new mediation their risk increases by 21.8 percentage points. After adjusting for confounding variables (like age, sex, BMI, etc.), the **odds** of having a heart disease incident are **8.27 times higher** for patients taking the new medication compared to the odds for patients in the control group, $OR=\frac{odds_{treated}}{odds_{control}}$.

```r
# Weighted regression model to estimate risk difference
weighted_glm <- svyglm(Heart_Disease_Incident ~ New_Medication, 
                       design = weighted_data, 
                       family = quasibinomial(link = "identity"))

summ(weighted_glm, digits=4,  confint = TRUE)

# get coefficients and convert to odds
control_coef <-  weighted_glm$coefficients[[1]]
treated_coef <- control_coef + weighted_glm$coefficients[[2]]

control_odds <- control_coef / (1-control_coef)
treated_odds <- treated_coef / (1-treated_coef)

# calculate odds ratio
OR <- treated_odds / control_odds
cat(str_c("The odds ratio is ", OR))

```

\newpage

## Problem 3

### The crude RD, RR and OR can be expressed in terms of the parameters of the following linear, log linear and linear logistic models for the observed outcome Y:

$$ 
pr(Y=1|A=a) = \psi^{\prime}_0 + \psi^{\prime_1}_a 
$$

$$ 
\text{log pr}(Y = 1|A=a) = \theta^{\prime}_0 +\theta^{\prime}_1a 
$$

$$ 
\text{logit pr}(Y = 1 | A=a) = \beta^{\prime}_0 + \beta^{\prime}_1a
$$

### The crude associational RD equals $\psi^{\prime}_1$ , RR equals $e^{\theta{\prime}_1}$ and OR equals $e^{\beta^{\prime}_1}$. Assuming treatment is unconfounded, these same estiamtes will also be unbiased for the corresponding causal parameters of the following MSMs.

$$
pr(Y=1|A=a) = \psi_0 + \psi_a
$$

$$
\text{log pr}(Y^a = a) = \theta_0 +\theta_1a
$$

$$
\text{logit pr}(Y^a = 1) = \beta_0 + \beta_1a
$$ Using the data below

```r
# Create the 2x2x2 contingency table data
data_p3 <- tibble(
  L = c(rep(1, 4), rep(0, 4)),
  A = c(1, 1, 0, 0, 1, 1, 0, 0),
  Y = c(1, 0, 1, 0, 1, 0, 1, 0),
  N = c(108, 252, 24, 16, 20, 30, 40, 10)
) |> 
  # compute column totals for each stratum
  group_by(L, A) |> 
  mutate(total = sum(N)) |> 
  ungroup()

data_p3 |> kable()

```

## 

### a) Estimate the causal RD, RR and OR by standardization method.

-   First we dis aggregate the data into where 1 row is one individual. We print 5 rows at random.

```r

df <- data_p3 |> select(-total) |> uncount(weights = N)

df |> slice_sample(n=5) |> kable()
```

-   First we start by calculating the stratum probabilities for L=1 and L2.

```r
stratum_prob <- df |> 
  group_by(L) |>
  count() |> 
  ungroup() |> 
  mutate(Pr = n/sum(n)) |> 
  select(L, Pr)

stratum_prob |> kable()
```

-   Next we compute stratum specific probabilities for A.

```r
stratum_prob_y_1  <- df |> 
  group_by(L, A, Y) |>
  count() |> 
  ungroup() |> 
  group_by(L, A) |> 
  mutate(Pr = n/sum(n)) |> 
  filter(Y==1) |> 
  select(L, A, Pr)

stratum_prob_y_1 |> kable()
```

-   We now need to apply the standardization formula to get marginal potential outcomes using:

$$
E[Y^a] = \sum[p(Y=1 | A=a, L=1) \times P(L=1)]
$$

```r
expected_stand_margins <- stratum_prob_y_1 |> 
  left_join(stratum_prob |> rename(strat_Pr=Pr)) |>
  ungroup() |> 
  mutate(Pr_multiply = Pr*strat_Pr) |> 
  group_by(A) |> 
  reframe(E_Y = sum(Pr_multiply))

expected_stand_margins |> kable()
```

-   We can now calculate causal effects.

    -   For the causal risk difference.$E[Y^{a=1}] - E[Y^{a=0}] = -.32$, therefore, the treatment is estimated to cause a 32% point decrease in the probability of outcome $Y=1$ compared to not having the treatment.

    -   For the causal risk ratio $E[Y^{a=1}] / E[Y^{a=0}] = 0.50$, the risk of this outcome for those receiving the treatment is .50 times the risk of the outcome for not receiving the treatment. This treatment seems to cut the risk in half.

    -   For the causal odds ratio, $\frac{E[Y^{a=1} / (1 - E[Y^{a=1}] } {E[Y^{a=0} / (1 - E[Y^{a=0}]} = .265$, that is the odds of having the outcome for those reeving the treatment are .265 times the odds of the not receiving the treatment, indicating a $1 - .265 = .735$ 73.5% reduction in the odds of this outcome caused by the treatment.

```r
# function takes the standardized marginal potential outcomes
## calculates 
causal_effect_fun <- function(e_y_a1, e_y_a0) {
  # causal risk difference
  causal_rd = e_y_a1 - e_y_a0
  # causal risk ratio
  causal_rr =  e_y_a1 / e_y_a0
  # causal odds ratio
  causal_or = (e_y_a1 / (1 - e_y_a1)) / 
    (e_y_a0 / (1 - e_y_a0))
  
  dat = tibble(causal_rd, causal_rr, causal_or)
  return(dat)
}


causal_effect_fun(expected_stand_margins[[2, 2]],
                  expected_stand_margins[[1, 2]]) |> kable()

```

\

### b) MSM estimation involves creation of weights. Create weights and stabilized weights using the data above.

-   We use the formula for the weights as $W = \frac{1}{P(A|L)}$ and report them below in column "w."

```r
unstable_weights <- df |> 
  group_by(L, A) |> 
  count() |> group_by(L) |> 
  mutate(Pr = n/sum(n)) |> 
  mutate(w = 1/Pr)

unstable_weights |> kable()


```

-   To calculate the stabilized weights we use $SW = \frac{P(A)}{P(A|L)}$. First we calculate the probability of A.

```r
# calculate stabalized weights, probability of A
Pr_A <- df |> 
  group_by(A) |> 
  count() |> 
  ungroup() |> 
  mutate(Pr_a=n/sum(n)) |> 
  select(A, Pr_a)

Pr_A |> kable()
```

-   We can now calculate the stabilized weights by merging these two tables together.

```r
weights <- unstable_weights |> 
  left_join(Pr_A) |> 
  mutate(SW = Pr_a / Pr) |> 
  select(L, A, w, SW)

weights |> kable()
```

```r

```

\

### c) Estimate the causal RD, RR and OR by R (or SAS and STATA if you preferred) using MSM method with the model $Y \sim A$ where the outcome $Y$ is specified as a binary variable. To estimate $\psi^{\prime}_1$ , one would specify the identity link; to estimate $\theta^{\prime}_1$ , the log link; and for $\beta^{\prime}_1$ , the logit link.

-   Assign weights to the data frame.

```r
df <- df |> 
  # join weights
  left_join(weights)

df |> slice_sample(n=5) |> kable()
```

-   We fit weighted regression models of the outcome as a function of treatment. We see in the estimates below that all three causal effect measures estimated through MSM are identical to when we calculated them using standardization method. Our risk difference was -.32, the risk ratio was .50, and the odds ratio was .27, and both methods show that the treatment has a strong, statistically significant (see appendix) protective effect, and substantially reduces the risk and odds of the outcome.

```r
# Note the formula is now Y ~ A + L
# risk difference
rd_mod <- glm(Y ~ A, data = df, weights = SW,
                   family = quasibinomial(link = 'identity'))

# transform the treatment coefficient 
rd_msm <- coef(rd_mod)["A"]

# risk ratio
rr_mod <- glm(Y ~ A, data = df, weights = SW,
                   family = quasibinomial(link = 'log'))

# transform the treatment coefficient 
rr_msm <- exp(coef(rr_mod)["A"])

# odds ratio
or_mod <- glm(Y ~ A, data = df,  weights = SW,
                   family = quasibinomial(link = 'logit'))

# transform the treatment coefficient 
or_msm <- exp(coef(or_mod)["A"])

# put estimates into a table
tibble(
  causal_effect_measure = 
    c("Risk Difference", "Risk Ratio", "Odds Ratio"),
  MSM_estimate = c(rd_msm, rr_msm, or_msm),
  link_function = c("identity" ,"log", "logit")
) |> kable()
```

\newpage

## Appendix: Model results:

```r
export_summs(rd_mod, rr_mod, or_mod,  r.squared=FALSE, 
             confint = TRUE,  ci_level = 0.95,
             error_format = "{conf.low}, {conf.high}",
                     model.names = c('RD', "RR", "OR"))
```
