---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_2_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 2 - SURV745"
original: "PracTools_SURV745/assignments/SURV745_Assign_2_Linares.qmd"
pages: 
sha256: "74bcd9b4c4b82b9fe1da52cf8dd60b5068a673b6ac8434a11416a9ddf1fed3de"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:07"
---


```r
#| label: setup
#| include: false

pacman::p_load(PracTools, knitr, survey, tidyverse)

# Set global options
options(digits = 4, scipen = 999)

PracTools::hospital

data(smho98)
```

# VDK Exercises

### 3.7. An investigator wants to estimate the prevalence of a characteristic that is speculated to be rare. The investigator’s best guess is that the prevalence is 2%. She would like to estimate the prevalence with a MOE of 0.005.

### (a) What sample size is required?

-   We assume an infinite population and drop $\frac{N}{N-1}$ from the equation below to estiamte the required sample size for a tolerable MOE of 0.005 from standard normal approximation corresponding to a 95% CI half-width. From VDK Equation 3.14:

$$n = \frac{z_{1-\alpha/2}^2 \cdot p_U \cdot q_U}{e^2}$$

```r

pU <- 0.02 # expected proportion
e <- 0.005 # MOE given
alpha <- 0.05

n_required <- nPropMoe(moe.sw = 1, e = e, alpha = alpha, pU = pU)
cat("Required sample size = ", n_required)
```

-   Using the `nPropMoe()` function from PracTools with `moe.sw = 1` (indicating MOE on the proportion scale), the required sample size is n =3,012. This calculation assumes an infinite population (no finite population correction) and uses the standard normal approximation for a 95% confidence interval. With a rare prevalence of 2%, the product $p_U \cdot q_U = 0.02 \times 0.98 = 0.0196$ is relatively small, which helps keep the required sample size manageable despite the tight margin of error.

### (b) Since the investigator seems very uncertain about the actual prevalence, what alternative calculations could you do to illustrate the effects of dif- ferent sample sizes?

```r
prevalence_values <- seq(.005, .2, length.out=10)


results_3.7b <- tibble(
  pU = prevalence_values,
  n_required = map_dbl(prevalence_values, 
                       ~ceiling(nPropMoe(moe.sw = 1, e = e, 
                                         alpha = alpha, pU = .x)))
)


ggplot(results_3.7b, aes(x = pU, y = n_required)) +
  geom_line() +
  geom_point() +
  geom_text(aes(label = scales::percent(pU, accuracy = 0.1)), 
            vjust = -0.5, size = 3) +
  labs(x = "Prevalence (pU)", 
       y = "Required Sample Size (n)",
       title = "Required sample sizes for different prevalence assumptions",
       subtitle = "MOE = 0.005, 95% CI") +
  scale_x_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal()

```

We explore prevalence rates below and above .02 in the table above to reveal important patterns. First, the investigator's best guess of $p_U = 0.02$, requires a sample size of 3,012; however if the true prevalence is more than twice that, the required sample size needed for $p_U=.049$ is 7,068. This represents the most conservative approach, guaranteeing the desired precision regardless of the true prevalence. For planning purposes, if there is substantial uncertainty about the prevalence, the investigator might consider using exploring the minimum and maximum prevalence they expect to see, and calculate expected sample sizes for each.

### 3.8 Compute the unit relvariances of:

### (b) The variables total expenditures (EXPTOTAL), number of inpatient beds (BEDS), number of patients seen during 1998 (SEENCNT), the number of clients on the roles at the end of 1998 (EOYCNT), and number of in patient visits (Y IP) in the smho98 population.

-   The unit relvariance, or squared CV, is defined in VDK 3.3 as:

$$
CV^2_U = \frac{_U^2}{\bar{y}^2_U}
$$

-   where the population unit variance is:

$$
S^2_U = \frac{\sum^N_{i=1}(y_i-\bar{y}_i)^2}{N-1}
$$

-   and $\bar{y}_U = \frac{1}{N} \sum^N_{i=1}y_i$ is the population mean.

```r
vars_of_interest <- c("EXPTOTAL", "BEDS", "SEENCNT", "EOYCNT", "Y_IP")

results_3.8b <- smho98 |> 
  select(all_of(vars_of_interest)) |> 
  pivot_longer(everything(), names_to = "Variable", values_to = "Counts") |> 
  group_by(Variable) |> 
  reframe(
    N = n()-1,
    ybar_U = mean(Counts), # pop mean
    S2_U = sum((Counts - ybar_U)^2, na.rm = TRUE) / N, # pop variance
    CV = sqrt(S2_U) / ybar_U,
    Relvariance = S2_U / ybar_U^2
  )

results_3.8b |> kable()
  
```

\

### 3.12 Researchers at a health organization are interested in estimating the number of discharges within the last 12 months from hospitals specializing in a new medical procedure (N = 393). The project budget was sufficient to allow data collection at (n =) 50 hospitals. Based on prior research, the project statistician selected a pps sample of size 50 using the number of hospital beds as the MOS. The total number of beds tabulated from the list sampling frame was 107,956. Data from all 50 sample hospitals is located in the text file hosp50.csv. Data for number of beds for all 393 hospitals in the frame are in the hospital population in the PracTools package.

```r
hosp_sample <- read_csv(
  "D:/repos/UMD_classes_code/PracTools_SURV745/assignments/Hospital_50.txt",
  show_col_types = FALSE) |> 
  mutate_all(as.numeric)


N <- 393
n <- 50
total_beds <- 107956
```

### (a) Calculate the design weights for the 50 sample hospitals. How might you verify that the weights were calculated correctly? Show the verification.

-   For PPS sampling without replacement, $\pi ps$, the relative size of $i$ is $p_i$, and $x_i$ is the number of beds in a hospital.

$$
p_i = \frac{x_i}{\sum_U x_i}
$$

-   and for a sample of size $n$ selected WOR, the selection probability is $\pi_i=n \times p_i$ so that the design weight is the inverse of the selection probability.

$$
w_i = \frac{1}{\pi_i} = \frac{1}{n p_i}
$$

```r

hosp_sample <- hosp_sample |>
  mutate(
    p_i = BEDS / total_beds,# relative size
    pi_i = n *  p_i, # selection prob
    w_i = 1 / pi_i # design weight
  )

# plot the correlation between weights & beds 
hosp_sample |>
  ggplot(aes(x = BEDS, y = w_i)) +
  geom_point(color = "dodgerblue", size = 2) +
  geom_smooth(method = "lm", se = FALSE, 
              color = "firebrick", linetype = "dashed") +
  labs(x = "Number of Beds", 
       y = "Design Weight (wᵢ)",
       title = paste0("Correlation: r = ", 
                      # compute corr
                      round(cor(hosp_sample$BEDS, hosp_sample$w_i), 4))) +
  theme_minimal()


# we can confirm using the survey package
hosp_design <- svydesign(
  ids = ~1,
  weights = ~w_i,
  data = hosp_sample,
  pps = "brewer"  # or use pps = ppsmat(matrix) for exact pps
)


# π-estimator of mean
svymean(~BEDS, design = hosp_design)

# π-estimator of total
svytotal(~BEDS, design = hosp_design)

```

-   The design weights range from 2.19 to 4.39, and with larger hospitals receicing smaller weights given the higher selection probabilities. The sum of the weights equal 176 which does not equal N=393. We expect this for any single realized PPS sample. We show in the figure above, the correlation between weights and beds is r=-.98, suggesting a strong inverse relationship between hospitals with more beds having smaller weights since they are more likely to be selected.

### (b) Estimate the average number of discharges based on the sample using the π-estimator of the mean. Assume that the population count, N = 393, is known.

-   The Horvitz-Thompson estimator for the population total is $\hat{t}_\pi = \sum_s y_i/\pi_i$ and is used for the population mean when N is known as $\hat{y}_\pi=\frac{\hat{t}\pi} {N}$ (3.28).

```r
t_hat_pi <- sum(hosp_sample$w_i * hosp_sample$DISCHARGE) # HT total estimator
ybar_pi <- t_hat_pi / N # pop mean

cat("Average number of discharges ", ybar_pi)
```

-   The estimated population total of discharges is 291,776. When we divide by N=393, this yields the estimated mean of 742.4 discharges per hospiotal in a 12 month period. The weighted estimator adjusts for this unequal probability selection to produce an unbiased estimate of the population mean.

### (c) Estimate the sample variance for your estimate in (b) using the formula for with-replacement sampling.

-   For PPS WR sampling, the variance of the estimated mean is given by 3.32 and 3.41 as:

$$
V(\hat{\bar{y}}_{pwr}) = \frac{1}{N^2 n} \sum_U p_i \left(\frac{y_i}{p_i} - t_U\right)^2 \equiv \frac{V_1}{N^2 n}
$$

-   where the estimator of $V_1$ is:

$$
\hat{V}_1 = \frac{1}{n-1} \sum_{i \in s} \left(\frac{y_i}{p_i} - \frac{1}{n}\sum_{j \in s}\frac{y_j}{p_j}\right)^2
$$

```r
Qe_results <- hosp_sample |>
  mutate(y_over_p = DISCHARGE / p_i) |> 
  reframe(
    t_hat_pwr = mean(y_over_p),
    V1_hat = sum((y_over_p - t_hat_pwr)^2) / (n - 1),
    var_ybar = V1_hat / (N^2 * n),
    se_ybar = sqrt(var_ybar),
    cv_ybar = se_ybar / ybar_pi
  ) 

Qe_results |> 
  select(var_ybar:cv_ybar) |> 
  kable()
```

-   The sampling variance is 593.1, and the with replacement formula is conservative when sampling is actually conducted without replacement since it ignores the FPC. However, the with replacement has practical advantages in that it is simpler to compute and does not require joint selection probabilities $\pi _{ij}$ which are needed for the HT variance estimator under without replacement sampling.

### (e) Suppose you want to select a new sample with probabilities proportional to the square root of beds. Estimate the appropriate V1 for this design. How many sample hospitals would be needed to meet the target $CV(\hat{y}_{\pi})$ = 0.15 with this design?

```r
CV0 <- 0.15 # cv target

# get the TRUE population total for sqrt(BEDS)
# the new design (q_i) is based on the frame, not a sample estimate
total_sqrt_beds_pop <- sum(sqrt(hospital$x))

# Calculate q_i using the TRUE total
hosp_sample <- hosp_sample |>
  mutate(
    sqrt_beds = sqrt(BEDS),
    q_i_new = sqrt_beds / total_sqrt_beds_pop,
    y2_over_q = DISCHARGE^2 / q_i_new
  )

# Calculate V1 w/ the variance correction Term
## V1_hat = [Sum(y^2/q*p)] - [Sum(y/p)]^2 + v(t_hat)
### estimate sum_U(y^2/q) using pi-estimator
est_sum_y2_over_q <- sum(hosp_sample$w_i * hosp_sample$y2_over_q)

# V1 for new design (Eq. 3.42): V1 = sum(y^2/q) - t_U^2
V1_new <- est_sum_y2_over_q - # term 1
  (t_hat_pi^2) + # term 2
  (N^2 * Qe_results$var_ybar) # term 3


# we need the true pop mean
ybar_U_true <- mean(hospital$y)

# sample size (3.33)
n_new <- V1_new / (N^2 * ybar_U_true^2 * CV0^2)
```

-   Using the population frame to obtain the total of $\sqrt{\text{beds}}$, we have $\sum_U \sqrt{x_i} =$ `r round(total_sqrt_beds_pop, 2)`. The estimated $\sum_U \frac{y_i^2}{q_i} =$ `r format(est_sum_y2_over_q, scientific = TRUE, digits = 4)`, and subtracting $\hat{t}_\pi^2 =$ `r format(t_hat_pi^2, scientific = TRUE, digits = 4)` gives $\hat{V}_1 =$ `r format(V1_new, scientific = TRUE, digits = 4)`.

-   Applying (3.33) with $CV_0 = 0.15$:

$$ n = \frac{\hat{V}_1}{N^2 \hat{\bar{y}}_\pi^2 CV_0^2}  $$

-   The required sample size is approximately **n = `r ceiling(n_new)` hospitals**, and this sample size results from the high efficiency of PPS sampling for this population. The current sample of n = 50 achieves a CV of only `r round(Qe_results$cv_ybar * 100, 1)`%, which far exceeds the precision target of 15%. Most likely, discharges are strongly correlated with beds, and PPS sampling with either beds or $\sqrt{\text{beds}}$ as the MOS produces very precise estimates. In order to achieve a CV = 15%, only `r ceiling(n_new)` hospitals need to be sampled.
