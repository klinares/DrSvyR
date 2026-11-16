---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW1"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 1"
original: "sampling_1_SURV626/assignments/Linares_K_HW1.qmd"
pages: 
sha256: "d74648f4a79013c6144c6e1de072de74510a9dcb592b024a4fca8844dd96efc3"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:17"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(knitr, gt, tidyverse)

options(scipen=999)
```

1.  In a population with $N=5$ the values of the survey variable are $Y_1=5, Y_2=1, Y_3=4, Y_4=10, Y_5=7$.

```r
pop <- tibble(Element = str_c(rep("Y", length=5), seq(1,5)),
              Y_i = c(5, 1, 4, 10, 7) )

# print table
 pop |> 
   kable()
```

a\) Calculate the population mean $\overline{Y}$ and the population element variance $S^2$.

-   The population mean is given as:

$$
\overline{Y} = \frac{\sum_{i=1}^{N}y_i}{N}
$$

```r
Y_bar <- pop |> summarise(sum(Y_i)/n()) |> pull()
```

-   The population element variance $S^2$ of the population mean $\overline{Y}$ is given as:

$$
S^2 = (\frac{1}{N-1}) (\sum_{i=1}^{N} Y^2_i - Y^2 / N)
$$

```r
# create columns to calculate element variance
pop <- pop |> 
  mutate(Yi_minus_Ybar  = Y_i - mean(Y_i),
         Yi_minus_Ybar_squared  = Yi_minus_Ybar^2)

pop |> kable()

pop |> 
  gt() |> 
  cols_label(
    Element = "Element",
    Y_i = "Yᵢ",
    Yi_minus_Ybar = "Yᵢ - Ȳ",
    Yi_minus_Ybar_squared = "(Yᵢ - Ȳ)²"
  )

# get S^2
S_sqrd <- pop |> summarise(sum((Y_i - mean(Y_i))^2) / (n()-1) ) |> pull()
```

-   For this population of $N=5$, the population mean $\overline{Y} =$ `r Y_bar` with a population variance $S^2=$ `r S_sqrd`.

\

b\) List all possible samples of $n=3$ distinct elements that can be drawn from this population.

-   We first start with generating the number of unique simple random draws of size 3 without replacement from the population of size N=5 using the following formula.

\begin{align*}
\binom{N}{n} = \binom{5}{3} = \frac{5!}{3!(5-3)!} = 10
\end{align*}

```r
n <- 3
N <- 5

choose(N, n)
```

```r

all_samples <- 
  # Generate all combinations of n from the population Y
  combn(pop$Y_i, n) |> 
  # transpose matrix
  t() |> 
  # convert to tibble
  as_tibble() |> 
  # give proper names to columns
  rename(Y1=1, Y2=2, Y3=3) |> 
  # add sample ID
  mutate(sample_id = row_number()) |> 
  relocate(sample_id, .before = "Y1") 
  
  


all_samples |> 
  gt() |> 
  cols_label(
    sample_id = "Sample #"
  )

```

\

c\) Compute the sample mean $\bar{y}$ and the sample element variance $s^2$ for all samples listed in (b). Is any of the sample means or element variances equal to their corresponding population parameters?

-   The sample mean is given as : $$ \overline{y} = \frac{1}{n}\sum_{i=1}^{n} y_i $$

-   and the equation for the sample element variance is:

$$ s^2 = \frac{1}{n-1}\sum_{i=1}^{n} (y_i - \overline{y})^2 $$

```r
all_sample <- all_samples |> 
  pivot_longer(-sample_id) |> 
  group_by(sample_id) |> 
  # calculate the sample mean and element variance
  mutate(y_bar = mean(value),
          s_sqrd =  (1 / (n() - 1) ) * 
            (sum( (value - mean(value))^2))
  ) |> 
  ungroup() |> 
  pivot_wider(everything()) |> 
  select(sample_id, Y1, Y2, Y3, y_bar, s_sqrd)


all_sample |> 
  gt() |> 
  cols_label(
        sample_id = "Sample #",
        y_bar = "ȳ",
        s_sqrd = "s²"
    )

```

-   From the table above, we do not observe any of the sample means or element variance equal to the population mean or element variances. This is because samples from a population do not perfectly represent the population, but rather approximate its parameters which is why we depend on sampling distributions for making inferences.

\

d\) Compute the average of the sample means and element variances across all possible samples listed in (b). What do you observe?

-   Below we see that the sample averages and average of $s^2$ are equal to the population mean and element variance that we calculated in a). This highlights for us a crucial component of simple random sampling which is that both the sample means and element variances are unbiased estimators of their population parameters, despite that they may be off from the population estimate, but the process is correct on average.
    -   We plot a histogram of the sample means distributed around the population mean in the visual below to highlight this explanation.
-   With the sampling fraction $f$, which is the finite population correction to reduce the variance estimate, $f=n/N = 3/5=.6$ we can calculate the true variance of the sampling distribution of the mean to see how much the sample means vary from each other. The variance of $\bar{Y}$ is given as $(1 - f) / n) * S^2 = ((1-.6)/3) \times 11.3 = 1.51$, and this is equal to the empirical variance, which means that our theoretical formula of the sampling variance is describing perfectly the variation we observe across all possible samples.

```r
all_sample |> 
  summarise(pop_mean = mean(y_bar),
          pop_s_sqrd =  mean(s_sqrd)) |> 
  kable()


# We also plot these samples distributed around the Population mean 
all_sample |> 
  ggplot(aes(x = y_bar)) +
  geom_histogram(bins = 5, fill = "dodgerblue", alpha = 0.7) +
  geom_vline(xintercept = Y_bar, color = "red", linetype = "dashed") +
  labs(title = "Sampling Distribution of Sample Means",
       x = "Sample Mean", y = "Frequency") +
  ggthemes::theme_hc()


# empirical variance
empirical_var <- all_sample |> 
  summarise(mean((y_bar - mean(y_bar))^2)) |> 
  pull()

f <- n/N
  # theoretical variance
theoretical_var <-  ((1-f)/3) * S_sqrd

empirical_var
theoretical_var
```

\

2.  Please, in relation to this Homework 1, report:

<!-- -->

(a) How long did you spend (in HH:MM) on this assignment?

-   2.5 hours because of the coding of the equations, and learning the gt() package for table displays,

(b) On a scale of 1 to 10, where 1 is “very easy” and 10 is “very difficult”, how would you rate this assignment?

-   Score of 6, if it were easy I could recall these equation from memory but I had to look it up in the lecture notes, as well as the Lohr book on Sampling.
