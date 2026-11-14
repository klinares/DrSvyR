---
id: "jpsm/applied_sampling_SURV625/lab/stratified_example"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "lab"
title: "Proposal: stratified_estimates"
original: "applied_sampling_SURV625/lab/stratified_example.qmd"
pages: 
sha256: "f29cde7c3dfe79c9e1e8b01a778132aa92be23ce56a0061a941cfc5b5e95a345"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T14:15:59"
---


```r
library(viridis)
library(survey)
library(tidyverse)

options(scipen=999)
```

## ![](stratified_data_example.png){width="527"}

\

## Provide proposal for point estimate by gender alongside standard errors.

We are interested in estimating a proportion of female and male students whom are planning to pursue academic careers in a population of 4,000 (Female=2,700, Males=1300) from a sample of students n=400 (Female=240, Males=160)

```r
# population
N <- 4000
N_male <- 1300
N_female <- 2700

# sample
n <- 400
n_male <- 160
n_female <- 240

# yes to academia
y_male <- 40
y_female <- 84
```

### We can explore whether our samples of females and males approximates the proportion of females and males in the population they come from.

```r
# put counts together
dat <- tibble(Gender = rep(c("Female", "Males"), each=2),
       type = rep(c("Population", "Sample"), 2),
       size = c(N_female, n_female, N_male, n_male),
       total = rep(c(N, n), 2 ) 
) |> 
  mutate(prop = round(size/total, 2))

dat |> 
  ggplot(aes(x=Gender, y=prop, fill=type)) +
  geom_col(position = 'dodge') +
  geom_text(aes(label = prop), vjust=2, color="red",
            position = position_dodge(width = .9), size = 4) +
    guides(fill=guide_legend(title="")) +
  scale_fill_viridis_d(option="cividis") +
  theme_bw()

```

### We can see that we may need to up sample females, and down sample males to match our population proportions.

\

## Calculating point estimates 

-   In our sample there are 84 females and 40 males planning to pursue academic careers. If we compute an inference for the population proportion these will still need to be calibrated to correct for sampling variability.

```r
p_hat_females <- y_female/n_female ; p_hat_females
p_hat_males <- y_male/n_male ; p_hat_males

```

## Estimating variance and standard error

-   We calculate the element variance estimate for a proportion for Females and Males as:

$$
\hat{s}^2_h = \frac{n_h}{n_h-1}p_h(1-p_h)
$$

```r
s_squared_female <- (n_female / (n_female - 1) ) * 
  (p_hat_females *  (1 - p_hat_females)) ; s_squared_female

s_squared_male <- (n_male / (n_male - 1) ) * 
  (p_hat_males *  (1 - p_hat_males)) ; s_squared_male
```

-   and we can use the element variance estimate for each stratum to calculate the sampling variance estimate as;

$$
var(\hat{p}_h) = (1-f_h)\frac{\hat{s}^2_h}{n_h}
$$

```r
var_female <- (1 - (n_female / N_female)) * 
  (s_squared_female / n_female) ; var_female

var_male <- (1 - (n_male / N_male)) * 
  (s_squared_male / n_male) ; var_male
```

-   which we can than use to estimate standard error by taking the square root of the variance $se(\hat{p}_h) = \sqrt{var(\hat{p}_h)}$.

```r
se_female <- sqrt(var_female) ; se_female
se_male <- sqrt(var_male) ; se_male
```

## We put all estimates together in a table and estimate total count by gender alongside 95% CI.

```r

dat |> 
  filter(type == "Population") |> 
  select(Gender, size) |> 
  add_column(
  Pnt_est = c(p_hat_females, p_hat_males),
  elem_var = c(s_squared_female, s_squared_male),
  samp_var = c(var_female, var_male),
  SE = c(se_female, se_male)
  ) |> 
  mutate_if(is.double, round, 4) |> 
  # calculate counts
  mutate(Total = Pnt_est * size, 
         # calculate 95% CI to check work
         lower = round((Pnt_est - qt(.975, n-1) * SE) * size),
         upper = round((Pnt_est + qt(.975, n-1) * SE) * size)
         ) |> 
  knitr::kable()
```

\

# We propose that the population estimate from our sample to be 945 (SE=.029, \[95% CI: 789, 1,101\]) female and 325 (SE=.032, \[95% CI: 243, 407\]) male students are planing to pursue academic careers.

\newpage

## We check our work with the survey package:

```r


# disaggregate stratified counts into dataframe
survey_data <- data.frame(
  gender = rep(c("Women", "Men"), c(n_female, n_male)),
  academia = c(rep(1, 84), rep(0, 240 - 84), rep(1, 40), rep(0, 160 - 40))
)

# created survey design object with sample and pop counts
d <- svydesign(id = ~1, data = survey_data,
               strata = ~gender, 
               fpc = rep(c(N_female, N_male), c(n_female, n_male)))

# Estimate total number of students planning for academia
total_academia <- svytotal(~academia, d)

total_academia_women <- svytotal(~academia, subset(d, gender == "Women"))
# Domain estimation for men
total_academia_men <- svytotal(~academia, subset(d, gender == "Men"))
# Compute degrees of freedom for each domain
df_women <- degf(subset(d, gender == "Women"))
df_men <- degf(subset(d, gender == "Men"))
#CI
print("Point estimate for females with 95% CI = ")
total_academia_women
confint(total_academia_women, level=.95, df=df_women)


```

```r

print("Point estimate for males with 95% CI = ")
total_academia_men
confint(total_academia_men, level=.95, df=df_men)

```

-   We estimate the same 95% CI and point estimate for males and females. Our variance and SE is based on working with proportions instead of counts.
