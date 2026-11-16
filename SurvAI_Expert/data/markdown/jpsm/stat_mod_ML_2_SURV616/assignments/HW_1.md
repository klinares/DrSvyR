---
id: "jpsm/stat_mod_ML_2_SURV616/assignments/HW_1"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "assignment"
title: "SURV616, Homework 1"
original: "stat_mod_ML_2_SURV616/assignments/HW_1.qmd"
pages: 
sha256: "8f738d91f15faecb6de1aab8a1b1be8e78483c3042e30c97f83a355c0528b2e0"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:27"
---


## ![](honor_hw1.png){width="182"}

1.  The following data are from Google Trends show the number of times that the term "film noir" was searched using Google.

```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)
library(knitr)
library(ggthemes)
library(tidyverse)

options(scipen=999)
```

```r
gtrends <- read_csv(
  "~/repos/UMD_classes_code/stat_mod_ML_2_SURV616/homework/hw1_google_trends.csv") |> 
  mutate(week = mdy(week))

kable(gtrends)

```

-   There is a belief that the number of searches each week changed over that period of time

\

1.  a\) Calculate maximum likelihood estimate of **p** (i.e. the proportion of all 781 searches that occurred in each week). Graph these 12 proportions.

-   The maximum likelihood estimation of a proportion p is given as, which is the success over trials:

$$
\theta = g(p), \text{ is } \hat\theta = g(\hat{p})
$$

```r
gtrends <- gtrends |> 
  mutate(p_hat = round(film_noir / sum(film_noir), 2))

kable(gtrends)
```

-   We visualize the proportions by week date.

```r
gtrends |> 
  ggplot(aes(x=week, y=p_hat)) +
  geom_line(color="dodgerblue", alpha=.7) +
  ylim(0, .15) +
  theme_hc()
```

\

1.  b\) Write the null hypothesis that the proportion of searches for "film noir" is the same each week. Also, write the alternative hypothesis (i.e., that there has been a change in the proportion of searches each week).

-   The null hypothesis, $H_0: p_1=p_2=p_3... = p_{12}$, is that the weekly proportion of web searches for "film_noir" is the same across weeks. The alternative hypothesis, $H_a:p_1 \ne p_2 \ne p_3... \ne p_{12}$, is that there is at least one proportion not equal to the other weekly proportions of web searches, in other words, there has been a change in the proportion of searches each week.

\

1.  c\) Compute the $\chi^2$ and $G^2$ statistics. What do these tell us?

-   The Pearson Chi-square test;

$$
\chi^2 = \sum_{i=1}^k \frac{(O_i - E_i)^2}{E_i}
$$

-   where $O_i = n_i$ is the observed count in the $i^{th}$ category, and $E_i = np_{0i}$ is the expected count in the $i^{th}$ category (from $H_0$).

-   We can compute the expected frequencies by dividing the cells over the sum of observed values.

```r
gtrends <- gtrends |> 
  # add new column with expected frequencies
  mutate(expected = sum(film_noir)/n()) 

# print data table
gtrends
```

```r
# calculate chi_square, than use function to check calculation
chi_square <- sum(((gtrends$film_noir - gtrends$expected)^2) / gtrends$expected)
print(chi_square)

# use function to double check hand calculation
chisq.test(gtrends$film_noir)
```

-   The $\chi^2$ goodness of fit test tells us how likely it is that our observed data is due to chance. The goodness of fit statistic is testing how well the observed distribution of the data fits with the distribution that is expected if the variables are independent. We observe a p\>.05 for this test statistic, meaning that we reject the Null hypothesis that at least some of our observed frequencies are not close to the expected frequencies.

-   The likelihood ratio statistic $G^2$ is a statistical method used to compare the goodness-of-fit of two competing statistical models. It approximates the $\chi^2$ test statistic, and is expressed as:

$$
G^2 = 2\sum_{i=1}^k O_i ln(\frac{O_i}{E_i})
$$

```r
# calculate LRT with formula above
LRT <- sum((2*gtrends$film_noir)*log(gtrends$film_noir/ (gtrends$expected)))
print(LRT)

```

-   We see that our $G^2=12.58$ approximates our $\chi^2=12.53$ closely. Overall our observations in each category does not fit our heuristic or theoretical expectations.

\newpage

2.  A graduate student decided to track the number of steps they took each day for a week. The student took a walk every afternoon. The student also walked to class and other places. The student wanted to know if they were walking about the same number of steps each day. Here are the data on steps tracked:

-   The student wants to be walking about the same number of steps each day. Hence, the null hypothesis is that the number of steps are equally likely to be walked on each day, or that the daily proportion of each weeks total steps is the same:

$$
H_0: p_1=p_2=p_3=p_4=p_5=p_6=p_7
$$

```r
# enter steps data
steps <- tibble(
  days = c("Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"),
  step_counts = c(3358, 2894, 2346, 2981, 2956, 2239, 3974)
) |> 
  # create days as factor, calculate daily proportions
  mutate(days = fct(days, 
                    levels = 
                      c("Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat")),
    step_prop = step_counts/sum(step_counts))

# print total, should be 20,748
steps |> tally(step_counts)

```

2.  a\) Graph the proportions of all steps taken on each day of the week.

```r
steps |> 
  ggplot(aes(x=days, y=step_prop)) +
  geom_col(fill="dodgerblue", alpha=.7) +
  theme_hc()
```

\

2.  b\) Calculate the maximum likelihood estimate of **p**, as well as the maximum likelihood estimate of $\hat{V}(\hat{p})$. Note that the latter $\hat{V}(\hat{p})$ is a matrix of variances and covariances.

```r
# MLE proportion
steps <-  steps |> 
  mutate(p_hat = step_counts/sum(step_counts))

# print columns of interest
steps |> 
  select(days, p_hat) |> 
  mutate(p_hat =  round(p_hat, 2))
```

\

-   The MLE variance estimate for a Binomial Distribution is given by:

$$
V(\hat{p}) =\frac{\hat{p_i}(1-\hat{p_i})}{n}
$$

\

```r

# extract p_hats from table
p_hat <- steps |> pull(p_hat)
total_steps <- steps |> tally(step_counts)

# calculate matrix of variances on the diagonal, and covariances
var_p <- (diag(p_hat) - p_hat %*% t(p_hat))/sum(total_steps)
print(var_p)

# add variances to datatable as a new column "var_p"
steps <- steps  |> 
  add_column(
  var_p = round(diag(var_p), 6)
)

steps 
```

-   We calculate MLE variances $\hat{V}(\hat{p})$ for each $\hat{p}$ and include it to our data table.

\

2.  c\) Calculate the maximum likelihood estimate of the proportion of steps taken on the weekend (Sunday and Saturday, p1+p7) and the maximum likelihood estimate of the variance of the proportion of steps taken on the weekend.

```r
 steps |> 
  # keep days needed
  filter(days %in% c("Sun", "Sat")) |> 
  summarise(
    # take sum of p_hats
    p_hat = sum(p_hat),
    # compute variance for p_hats
            var_p = (1-p_hat) * p_hat / sum(total_steps)
    ) 
```

-   The MLE proportion of steps was .35 with an estimated MLE variance of .00001.

\

2.  d\) Test the $H$ that, by computing both the $\chi^2$ and $G^2$ statistics. What do you conclude?

$$
H_0: (p_1=p_2=p_3=p_4=p_5=p_6=p_7) \text{ vs } 
H_A:(p_1 \ne p_2 \ne p_3 \ne p_4 \ne p_5 \ne p_6 \ne p_7)
$$

```r
# add expected frequencies to the dataframe
steps <- steps |> 
  mutate(expected = sum(step_counts) / n())

# calculate chi-square using the same forumla as before
chi_square <- sum(((steps$step_counts - steps$expected)^2) / steps$expected)
print(chi_square)

# check calculation that was done by hand
chisq.test(steps$step_counts)

# calculate LRT with formula introduced earlier
LRT <- sum((2*steps$step_counts)*log(steps$step_counts/ (steps$expected)))
print(LRT)

```

-   We calculate $\chi^2$ and $G^2$ goodness of fit statistics and we reject the Null hypothesis and state is no statistical difference between the observed distribution of steps versus the theoretical distribution we would expect.

\newpage

3.  The following table is based on a study of aspirin use and myocardial infarction. The data are similar to actual data.

```r

# construct 2x2 table
myo_table <- matrix(c(173, 83, 9879, 9970), nrow= 2, ncol = 2, byrow = FALSE)
rownames(myo_table) <- c("Placebo", "Aspirin") 
colnames(myo_table) <- c("Yes", "No")

# add marginal counts
myo_table <- addmargins(myo_table)

# calculate proportion of disease; disease=yes / N
disease_prop <- myo_table[[3, 1]] / myo_table[[3, 3]]

myo_table
```

\

3.  a\) About 1.27% (n11+n21)/(n11+n21+n12+22) had myocardial infarction. Since this was a designed experiment, 50% were assigned to take a placebo. If the use of aspirin or placebo was independent of risk of myocardial infarction (i.e. if the risk of myocardial infarction was no different whether you took placebo or aspirin), what would the expected counts be in each cell (n11, n12, n21, and n22)?

-   It appears that the overall probability of having a Myocardial Infarction is .0127 and the total sample is $N=20,105$ which the design experiment split the random sample evenly between the two conditions. We can assume that the risk of Myocardial infarction is the same regardless of condition.

<!-- -->

-   We calculate the expected frequencies for the expected frequencies for having disease by both conditions, and not having the disease by both conditions. The expected frequencies for having the disease regardless of condition is 128, and not having the disease in the placebo group the expected frequency is 9,924, and the expected frequency for not having the disease in the aspirin group is 9,925.

```r
# calculate placebo expectation, disease proportion * totaL placebo group
disease_placebo_expect <- disease_prop * myo_table[[1, 3]]

# calculate aspirin expectation, disease proportion * totaL aspirin group
disease_aspirin_expect <- disease_prop * myo_table[[2, 3]]

# calculate placebo expectation, no disease placebo counts - p(disease placebo)
no_disease_placebo_expect <-  myo_table[[1, 3]] - disease_placebo_expect

# calculate aspirin expectation, no disease aspirin counts - p(disease aspirin)
no_disease_aspirin_expect <-  myo_table[[2, 3]] - disease_aspirin_expect

# save expected freq in 2x2 table
expected_freq <- matrix(c(disease_placebo_expect, disease_aspirin_expect,
                        no_disease_placebo_expect, no_disease_aspirin_expect),
                        ncol=2, byrow=FALSE) |> 
  round(1)

rownames(expected_freq) <- c("Placebo", "Aspirin") 
colnames(expected_freq) <- c("Yes", "No")

addmargins(expected_freq)
```
