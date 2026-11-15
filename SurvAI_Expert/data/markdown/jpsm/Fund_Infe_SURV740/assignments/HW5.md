---
id: "jpsm/Fund_Infe_SURV740/assignments/HW5"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Homework 5: Model Based Inference"
original: "Fund_Infe_SURV740/assignments/HW5.qmd"
pages: 
sha256: "892765db9b12a5e3e529108b9d3ef9d82034732315c1337ebd04a7cbc695ed1b"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:01"
---


```r
pacman::p_load(knitr, viridis, brms, ggdist, bayesplot, tidybayes, tidyverse)

options(digits=5, scipen=999)

# Set theme for plots
theme_set(theme_minimal())
```

### **1: \[25 points\] Basu’s elephant. The following are the data presented in class for the description of “Basu’s elephants,” as the problem has become known. As a reminder,there are 11 elephants. The circus needs to know the total weight of the elephants. This information is used for planning the purchase of food for the elephants. It is also used for planning transportation of the elephants. The elephant manager would weigh the middle-sized elephant and multiply that weight by 11. Recall that the statistician proposed a probability design that was based on the manager’s design. The middle elephant had a high probability of selection while the other elephants had a small probability (but non-zero, thus meeting the definition of probability sampling) of being selected.**

```r
# Define the elephant data
elephants <- tibble(
  elephant = 1:11,
  weight = c(9000, 9500, 10000, 10100, 10500, 11000, 
             11100, 11600, 11700, 12800, 13500),
  pi_i = c(rep(0.01, 5), 0.90, rep(0.01, 5))
)

Total <- elephants |> tally(weight, name="Weight") 

Total |> kable(col.names = "Total Weight")
```

\newpage

-   **(a) Using the statistician’s design, identify all 11 possible samples given this design. Using the estimator** $\hat{Y} = \frac{Y_i}{\pi_i}$ **calculate the estimate of the total weight of the elephants for each sample. Make a histogram of these estimates. Report the mean and standard deviation of these 11 estimates (Hint: are all samples of size 1 equally likely? See Module 7, Slides 41-43).**
    -   We use the Horvitz-Thompson estimator $\hat{Y} = \frac{Y_i}{\pi_i}$ with the middle elephant weight of 11,000 and $\pi_i=.90$, and this creates a bimodal distribution of estimates as we can see in Figure 1, which the purple dashed line represents the expected value (our estimated mean) of 120,800 (SD=328,585). Since samples are not equally likely, we needed weight them by their probabilities.

```r
elephants <- elephants |> 
  mutate(estimate = weight / pi_i)

elephants |> kable()

elephants |> 
  reframe(Mean = sum(estimate*pi_i), # mean of estimates
          SD= sqrt(sum(pi_i*(estimate-Mean)^2)) #SD of estimates
  ) |> 
  kable()


elephants |> 
  ggplot(aes(x =estimate, weight = pi_i)) +
  geom_histogram(bins = 10, fill ="dodgerblue", alpha = .6, color="black") +
  geom_vline(xintercept = sum(elephants$estimate * elephants$pi_i), 
             color ="purple", 
             linetype ="dashed", linewidth = 1.1, alpha=.75) +
  scale_x_continuous(labels =scales::comma)+theme_minimal() +
  labs(title ="Figure 1. Histogram of Estimates, Statistician's Design",
       x ="Estimated Total Weight",
       y ="Probability") 
```

\newpage

-   **(b) \[5 points\] Basu’s point is that the “long-run” properties may not be a good standard for judging estimators. Nevertheless, please examine an alternative sample design that assigns equal probability of selection to every elephant (1/11). With a sample size of 1, there are 11 possible samples. Using the estimator**$\hat{Y} = \frac{Y_i}{\pi_i}$**, calculate the total weight of the elephants for each sample. Make a histogram of these estimates. Report the mean and standard deviation of these 11 estimates.**

    -   We use an alternative SRS design with equal probability selection of 1/11 = .091. With all samples equally likely, our estimated mean is 120,800 with SD of 15,025, which is a lot less than our SD in 1.a, as seen in Figure 2.

```r
elephants <- elephants |> 
  mutate(pi_i_equal = 1/11,
         estimate_equal = weight / pi_i_equal)

elephants |> 
  select(elephant, weight, estimate, estimate_equal) |> 
  kable()

elephants |> 
  reframe(Mean = mean(estimate_equal), 
          SD = sqrt(sum(pi_i_equal * (estimate_equal - Mean)^2))) |>  kable()

elephants |> 
  ggplot(aes(x =estimate_equal)) +
  geom_histogram(bins = 10, fill ="dodgerblue", 
                 color = "black", alpha = .6) +
  geom_vline(xintercept = mean(elephants$estimate_equal), color ="purple", 
             linetype ="dashed", linewidth = 1.1, alpha=.75) +
  scale_x_continuous(labels =scales::comma)+theme_minimal() +
  labs(title ="Figure 2. Histogram of Estimates, equal Probability",
       x ="Estimated Total Weight",
       y ="Probability") 
  
```

\newpage

-   **(c) 10 points\] We have three designs – the manager’s design (take the middle elephant), the statistician’s design (part 1a), and the alternative probability sample design from part 1b. Describe the strengths and weaknesses of each of the three designs. Which of these designs is the best approach to the problem, and why?**
    -   The manager's design, where the middle elephant is always selected, is indeed the simplest method, resulting in a deterministic estimate of 121,000 (11,000 × 11) with zero variance. While this approach offers perfect consistency and minimal cost, it fundamentally violates probability sampling principles since only one elephant can ever be selected. Without a probabilistic foundation, no valid confidence intervals can be constructed, and the estimate is biased by 200 pounds. Most critically, this design provides no measure of uncertainty and cannot support formal statistical inference, making it scientifically inadequate despite its practical appeal.
    -   The statistician's design maintains an unbiased estimate and preserves the probability sample requirement, with about 90% of the time producing excellent estimates close to the true value. This design cleverly incorporates the manager's intuition about the middle elephant being typical by assigning it a 90% selection probability. However, the extreme variability represents a critical weakness - while the design is unbiased in the long run, any single sample has a substantial risk of being catastrophically wrong, potentially undermining credibility with stakeholders.
    -   The equal probability design achieves an unbiased estimate of the mean with the smallest variance (SD = 15,025) and maintains the simplicity of standard random sampling, making it the superior design. However, this design does ignore potentially useful information that the statistician's design includes - namely, the prior knowledge that the middle elephant's weight is likely representative. Despite this limitation, the dramatic reduction in variance (22-fold compared to the statistician's design) and the elimination of catastrophic estimation risk make the equal probability design the clear choice for balancing statistical rigor with practical reliability.

```r
tibble(Design = c("Manager", "Statistician", "Equal Prob."),
    "Expected Value" = c("121,000", "120,800", "120,800"),
         SD = c("0", "328,585", "15,024"),
    Bias = c(200, 0, 0) ) |> kable()
```

\newpage

2.  **10 points\] This problem uses Table 4.5-1 on Slide 24 Module 9.**

**(a) Unlike as in Table 4.5-1, show that if half the population is women for each risk group so that** $DIF = DIF_{strat}$**, regardless of whether** $DIF_{men} = DIF_{women}$ **.**

-   When half of the population is women in each risk group, the design based difference is:

$$
DIF = \frac{\sum w_i \times y_i women high}{\sum w_i womenhigh} - \frac{\sum w_i \times y_i womenlow}{\sum w_i womenlow}
$$When the population is balanced within risk group, than weights are equal within strata assuming SRS. The weighted means equal the simple means within strata, so $DIF = mean(women_{high}) - mean(women_{low})$. Finally, when the population are balanced within each risk group women and men will have the same population size assuming similar means for mean and women within each of these risk groups, so that $DIF_{strat}$ is:

$$
DIF_{strat} = \frac{
Pr_{high} \times (\bar{y}_{women_{high}} - \bar{y}_{women_{low}}) 
+ Pr_{low} \times (\bar{y}_{men_{high}} - \bar{y}_{men_{low}})}
{Pr_{high} + Pr_{low}}
$$

\

\

-   **(b) With the setup of part 2a above, where that half the population is women for each risk group so that** $DIF = DIF_{strat}$ **is** $DIF = DIF_{strat}$**? Show your work. Note dif is designed based and** $DIF_{strat}$ **is model-based. Define:**

$$
dif =  \frac{\sum_{i \in high} w_i y_i}{\sum_{i \in high} w_i} - 
\frac{\sum_{i \in low} w_i y_i}{\sum_{i \in low} w_i}
$$

-   **where** $w_i = \frac{N_{women}}{n_{women}}$ **and** $w_i = \frac{N_{men}}{n_{men}}$ **and**

$$
dif_{strat} = \frac{N_{women}(\bar{y}_{women_{high}} - \bar{y}_{women_{low}}) +
N_{men}(\bar{y}_{men_{high}} - \bar{y}_{men_{low}})}
{N_{women} + N_{men}}
$$

-   **where** $\bar{y}_g$ **is a simple mean of the sample for** $g \in \{men_{high}, women_{high}, men_{low}, women_{low}\}$**.**

    -   Even with a balanced population dif is not equal to dif_strat because theyb estimate different parameters, focuses only on women's differences, and dif_strat includes both genders weighted by risk proportions. Design-based uses actual sample weights while model-based uses model assumptions.
    -   Suppose in a population of 200 total (100 high risk, 100 low risk) each risk group is split by 50 men and 50 women and the means are women high 10, women low 6, men high 8, men low 7; Then dif_women 10 - 6 = 4, and true dif_men is 8-7=1, so that the dif estimates is 4 for women's difference only. On the other hand, dif_strat = (100 x 4 + 100x1) / 200 = 2.5. These are not equal results, 4 and 2.5, because they differ for women only. Dif_strat estimates a weighted average of men and women differences. In this case, equal population sizes do not make these equal unless diff for men = dif women. Moreover, having balanced populations does not grantee dif = dif_strat, but rather they would be equal if the treatment effect is identical for mean and women.

\

3.  **In Slide 46, the Discrete Prior Distribution example computes the posterior distribution of parameter θ using a binomial likelihood (p(y\| θ)) and a prior with six possible θ values. Now, researchers have updated their beliefs: there are only four possible values, (θ in {0.10, 0.12, 0.14, 0.16}), with corresponding prior probabilities (P(θ) = {0.2, 0.3, 0.25, 0.25}). Derive the posterior distribution of θ based on the binomial likelihood (to model the sample of 14 children found 2 with vision problems) and these updated prior probabilities.**

```r
n_children <- 14
n_vision_problem <- 2

# prior update
results_3 <- tibble(
  theta = c(.10, .12, .14, .16),
  prior = c(.2, .3, .25, .25)
) |> 
  mutate(
    # calculate likelihood for theta using a binomial distribution
    likelihood  = dbinom(n_vision_problem, n_children, theta),
    # calculate posteriors using bayes theorem
    posterior_probs = likelihood * prior,
    # normalized posteior by the sum of probs
    posterior = posterior_probs / sum(posterior_probs)
  )

results_3 |> kable()

```

-   We derive the posterior distribution with our updated priors and find a shift in the probability of of vision problem in children towards lower theta values because observing only 2/14 children suggests the true rate is likely closer to .12 than .16. Below we plot these distributions and see that the likelihood of theta .12 is higher than other values.

```r
# calculate posteior mean
results_3 |> 
  reframe(Posteior_mean = sum(theta* posterior)) |> 
  kable()

results_3 |> 
  select(theta, prior, posterior) |> 
  pivot_longer(-theta, names_to = "Distribution", values_to="Probability") |> 
  mutate(theta = factor(theta)) |> 
  ggplot(aes(x=theta, y=Probability, fill=Distribution)) +
  geom_bar(stat ="identity",position ="dodge") +
  scale_fill_viridis_d(option="D", alpha=.75, begin=.2, end=.8) +
  labs(title = "Prior vs Posterior Distribution")

```

\

\newpage

4.  **On slides 51-59 of Module 9, there is a numerical example. A population of N = 270 households; a simple random sample of size n = 20; and 8 households are found to have broadband internet. The numerical example shows a method for simulating the posterior distribution of the number of households with internet, conditional on the observed data. The simulation starts with a draw of the 𝜃 value from the posterior Beta distribution for 𝜃, given the data. Then, the simulation generates a count of households with broadband internet for the remaining 250 households, using a Binomial distribution with n = 250 and the 𝜃 drawn from the posterior Beta distribution. The graph on Slide 29 shows the simulated proportions of households with broadband internet (given the draws of the counts, the sample data, and the population size) across 2,500 repetitions of this model-based inferential process.**
    4.  Using R or statistical software of your choosing, create a similar graph using the following information. We are focused on a target finite population of N = 1,000 persons. We draw a simple random sample of size n = 50. The variable of interest in the survey is whether or not the person has medical insurance. We find that a total of 38 of the n = 50 sampled individuals have medical insurance. Use a seed value of 41279 for the simulations.

a\. **\[5 points\] Simulate a posterior distribution for the count of non-sampled individuals with medical insurance using the same approach outlined on slide 28. Use 2,500 simulated draws.**

-   After observing 38/50 our posterior for the population proportion of being insured is a beta(39, 13), and for each draw of theta we simulate the remaining 950 people in the finite population.

```r
N <- 1000
n <- 50
y <- 38 # have insurance
n_sims <- 2500

set.seed(41279)

# set parameters for a beta distribution 
alpha_param <- y + 1
beta_param <- (n-y) + 1

# simulate from the posterior
draws <- rbeta(n_sims, alpha_param, beta_param)

# we need to simulate count for the non-sampled
non_sampled <- N - n
count_non_sampled <- rbinom(n_sims, non_sampled, draws)

# we can now get the total count in the population
total_counts <- count_non_sampled + y

# population prorportion with insurance
prop_insured <- total_counts / N


prop_insured |> 
  tibble() |> 
  reframe(Theta = mean(prop_insured),
          lower = quantile(prop_insured, .025),
          upper = quantile(prop_insured, .975)) |>
  mutate_all(round, 3) |> 
  kable()
```

\newpage

\

-   **b. \[5 points\] Create a histogram for the estimated proportion of individuals with medical insurance like the one on slide 29. Using a Normal approximation, what is a 95% credible interval for this proportion?**

    -   Below we plot the posterior distribution of the estimated population proportion of insured, .75, represented by the purple dash line. 95% credible intervals \[.64, .86\] are captured with the green vertical lines.

```r
tibble(prop_insured) |> 
  ggplot(aes(x = prop_insured)) +
  geom_histogram(bins =50, fill ="dodgerblue", 
                 color ="gray", alpha =.75) +
  geom_vline(xintercept = mean(prop_insured), 
             color ="purple", linetype ="dashed", linewidth =1.1) +
  geom_vline(aes(xintercept = mean(prop_insured) - 1.96 * sd(prop_insured)), 
             color = "darkgreen") +
  geom_vline(aes(xintercept = mean(prop_insured) + 1.96 * sd(prop_insured)), 
             color = "darkgreen") +
  labs(
    title = 
      "Posterior Distribution of Population Proportion Insured, with 2,500 draws",)
```

-   **c. \[5 points\] Using these simulated draws, what is the probability that at least 66.7% of the population has insurance?**

    -   We estimate that the probability in the population of at least 66.7% of the population being insured is very probable at .92 representing 2,301/2,500 draws .

```r
prob_value <- .667

tibble(
  Probability = mean(prop_insured >= prob_value),
  Draws = sum(prop_insured >= prob_value)
) |> 
  kable()
```

\

-   **d. Using the same population of N = 1,000, now change the sample size to 25. We find that 18 have insurance. Simulate a posterior distribution for the count of non- sampled individuals with medical insurance using the same approach as outlined on slide 28. Use 2,500 simulated draws and a seed of 41279. Using a Normal approximation, what is a 95% credible interval for this proportion of individuals in the population with medical insurance?**

    -   With a smaller sample size our posterior mean increases and the credible interval widens, meaning that there is higher uncertainty.

```r
n <- 25
y <- 18 # have insurance

set.seed(41279)


# set parameters for a beta distribution 
alpha_param <- y + 1
beta_param <- (n-y) + 1

# simulate from the posterior
draws <- rbeta(n_sims, alpha_param, beta_param)

# we need to simulate count for the non-sampled
non_sampled <- N - n
count_non_sampled <- rbinom(n_sims, non_sampled, draws)

# we can now get the total count in the population
total_counts <- count_non_sampled + y

# population prorportion with insurance
prop_insured <- total_counts / N

# calculate theta and credible intervals


prop_insured |> 
  tibble() |> 
  reframe(Theta = mean(prop_insured),
          lower = quantile(prop_insured, .025),
          upper = quantile(prop_insured, .975)) |>
  mutate_all(round, 3) |> 
  kable()
```

\newpage

-   e\. Using these simulated draws, what is the probability that at least 66.7% of the population has medical insurance?

    -   We estimate that the probability in the population of at least 66.7% of the population being insured is moderetly probable at .70 representing 1,745/2,500 draws .

```r

tibble(
  Probability = mean(prop_insured >= prob_value),
  Draws = sum(prop_insured >= prob_value)
) |> 
  kable()
```

\

-   **f. How does the smaller sample size in part 3e impact the inference?**

    -   With the smaller sample size of 25 we see a wider credible interval width of .32 vs with the sample size of 50, .22. This suggests that the smaller sample size has higher variance in the posterior standard deviation which in turn affects our credible intervals. Both samples produce similar posterior means of .75 for n=50, and .70 for n=25. Moreover, the probability of 66.7% insured changes drastically from .92 for the larger sample to . 70 to the smaller sample, signifying that with smaller samples it leads to less precise inferences on the population parameter.

\newpage

5.  **\[25 points\] On Canvas, you will find selected data from the 2011-2012 NHANES in R and Stata formats (e.g., nhanes1112.rdata). This problem concerns implementation of Bayesian approaches to making inference about the parameters in a multilevel model, and the effects of accounting for survey weights on inference when using a model-based approach.**

```r
load("D:/repos/UMD_classes_code/Fund_Infe_SURV740/homework/nhanes1112.rdata")
```

-   **a. \[5 points\] A researcher wishes to fit a multilevel model to the NHANES data, treating systolic blood pressure (BPXSY1) as the continuous dependent variable and age as the predictor variable of interest (AGE), while estimating between-PSU variance in the mean SBP (i.e., including random effects of the PSUs, indicated by combinations of the variables SDMVSTRA and SDMVPSU). Import these data into R, only keep sampled individuals who are aged 18+, with complete data on the four variables of interest and the final survey weight (WTMEC2YR), and visualize the distributions of systolic blood pressure across the unique PSUs (ignoring the weights for now). Is there evidence of between-PSU variance in these means?**

    -   After keeping data from adults and dropping missing cases we are left with a sample size of 5,132 across 31 PSUs. Below we plot the mean sbp and 95% confidence interval for each PSU and we can see that average SBP values vary between PSUs; however, we also can see that there is a lot of within PSU variability.

```r
nhanes <- nhanes1112 |> 
  tibble() |> 
  # keep adults only
  filter(age >= 18) |> 
  rename(sbp = bpxsy1) |> 
  select(sbp, age, sdmvstra, sdmvpsu, wtmec2yr) |> 
  drop_na() |> 
  # create unique combinations of PSU
  group_by(sdmvstra, sdmvpsu) |> 
  mutate(PSU_id = cur_group_id()) |> 
  select(sbp, age, PSU_id, wtmec2yr) |> 
  ungroup() |> 
  mutate(age_c = age - mean(age), # center age
         wtmec2yr_c = (wtmec2yr - mean(wtmec2yr))/10000)

nhanes |> 
  mutate(PSU_id = fct_reorder(factor(PSU_id), sbp, median)) |> 
  ggplot(aes(x=PSU_id, y=sbp, group=PSU_id)) +
  stat_pointinterval() 
```

\

-   **b. \[5 points\] Given the multilevel model of interest, write down the statistical model for the dependent variable, including the assumed distribution, its mean, and its variance. How many parameters need to be estimated when fitting this model?**

$$
\text{Level 1:}
$$

$$ SBP_{ij} = \beta_{0j} + \beta_{1j} (age{ij}) + \epsilon_{ij}   $$

$$  \text{Level 2: } $$

$$ \beta_{oj} = \gamma_{oo} + u_{0j} $$

$$
\text{Assumption: } u_{0j} \sim N(0, \tau^2_{00})
$$

$$ \epsilon_{ij} \sim N(0, \sigma^2) $$

-   We are estimating four parameters where,

    -   $SBP_{ij}$ is the systolic blood pressure for individual $i$ , $i=1,...,N$ , for psu $j$, $j=1,...,J$.
    -   $\gamma_{00}$ is the fixed effect for the intercept of mean SBP levels across PSUs.
    -   $\epsilon_{ij}$ is the within PSU residual error normally distributed centered at $0$ with variance of $\sigma^2$.
    -   The variance-covarariance vector, $D$, has one unique parameters:
        -   $\tau^2_{00}$ is the variance of the true SBP levels, and larger values means more heterogeneity in PSU's SBP average levels.

-   This distribution assumption describes our probability distribution, which defines how we expect the data to behave random.

    -   On the left side are the random intercept $u_{0j}$ for PSU $j$, and is normally distributed with a mean vector centered at 0 since we are modeling deviations from the population average, and variances cannot be less than 0 but covariances can be less than 0.

\

-   **c. Using the brms package illustrated in Module 4, fit the multilevel model of interest to the SBP dependent variable. You can use the same priors for the fixed effects and the variance components that were specified on slide 16, and there is no need to set any priors for correlation parameters (given only one random effect). You can also use the same tuning parameters for the posterior simulations from slide 16. Given the post- burn-in posterior draws of the parameters in this model, interpret the resulting 95% credible intervals for the fixed effect of age and the variance of the random PSU effects. Is there evidence of both of these parameters being non-zero?**

```r
# priors from lecture slides
priors <- c(
  prior(normal(0,10), class ="b"),
  prior(cauchy(0,2), class ="sd"))

# Fit the multilevel model
mod_1 <- brm(sbp ~ age_c + (1|PSU_id), data = nhanes,
             prior =priors,  family = gaussian("identity"), 
             chains =8, iter = 2500, warmup =2000, 
             cores = getOption("mc.cores", 8), seed =41279,  silent = 2,
              backend = "cmdstanr")
```

-   We fit a multilevel model to sbp values with a fixed effect of age mean centered and note that the model fits the data well with an $\hat{R}=1$, meaning that the 8 chains have mixed well as we also show traceplots of the parameters. Below we also plot the posterior mean and 95% credible intervals for the fixed effect of age and the variance of the random effect on PSU and note that these intervals do not contain 0. For the fixed effect of age, the 95% credible interval (.45, .50) excludes 0, which provides strong evidence that age is positively associated with SBP. The probability of age fixed effect lies between .45 and .50 is .95. For each year increase in age, sbp increases by .48 mmHg. For the random effect PSU, the 95% credible interval (2.13, 3.87) excludes 0 and also suggests that the between PSU variance in sbp is meaningful after accounting for age. The probability that the PSU standard deviation lies between 2.13 and 3.87 is .95.

```r
summary(mod_1)

mcmc_trace(mod_1, 
           pars = c("b_Intercept",  "b_age_c", "sd_PSU_id__Intercept", "sigma"))

posterior <- as.matrix(mod_1)
mcmc_areas(posterior, pars = "b_age_c" , prob = .95)
mcmc_areas(posterior, pars = "sd_PSU_id__Intercept", prob = .95)
```

\

-   **d. \[5 points\] Suppose that a prior analysis of NHANES data suggests that the fixed effect of age follows an approximately normal distribution with mean 0.4 and standard deviation 0.1. (Hint: Review the documentation for the brm() function to see how you can set priors for specific coefficients.) Refit the model incorporating this updated prior information, using the default prior for the intercept. How does this change the 95% credible interval for the fixed effect of age?**

```r
priors <- c(
  prior(normal(.4, .1), class = b, coef = "age_c"),
  prior(cauchy(0, 5), class ="sd"))


# Fit the multilevel model
mod_2 <- brm(sbp ~ age_c + wtmec2yr_c + wtmec2yr_c:age_c + (1|PSU_id), 
             data = nhanes, family = gaussian("identity"),
             prior =priors,  chains =8, 
             iter = 2500, warmup =2000, 
             cores = getOption("mc.cores", 8), seed =41279,  silent = 2,
              backend = "cmdstanr")
```

-   The mean of the posterior draws of the age fixed effect is 0.47, with 95% credible interval (0.44, 0.49). For someone with the mean survey weight, age has a positive relationship with SBP.

-   The mean of the posterior draws of the weight fixed effect is 0.14, with 95% credible interval (-0.25, 0.52). For someone with AGE = 0, the survey weight does not seem to be correlated with SBP.

-   The mean of the posterior draws of the interaction fixed effect is -0.01, with 95% credible interval (-0.02,-0.00), which means that zero was not included in the interval. This suggests that as the weight increases in value, the age effect decreases in value. Put differently, those with higher weight values have lower age slopes, meaning that the weights do seem to be informative about the age effect.

-   At this point, we would need to understand what it means to have a higher weight value in the context of the NHANES sample design.

```r
summary(mod_2)
```
