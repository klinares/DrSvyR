---
id: "jpsm/applied_sampling_SURV625/assignments/HW3"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "assignment"
title: "Homework 3"
original: "applied_sampling_SURV625/assignments/HW3.qmd"
pages: 
sha256: "47f2024c20635d349cf50e7e6c1fc0257c2ac465cee27fbee1a3ce5d31ae928c"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:42"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

pacman::p_load(knitr, tidyverse)

options(scipen=999)
```

## 1. The following are cluster totals $y_a$ from a = 20 clusters of exactly b = 10 women (between the ages of 15 and 24) each. These clusters and the young women were sampled from the population frame used for Homework 1. The cluster totals $y_a$ are the number of women who have ever been pregnant. Assume that the clusters were selected at random and with replacement, and the students were selected with epsem and without replacement. The sampling fraction is f = ab/AB = n/N = 200/2,920 = 1 / 14.6, meaning that the finite population correction (fpc) should not be ignored in this case.

```r
# build the table
preg_data <- tibble(
  a = seq(1, 20, 1),
  b = c(4, 4, 3, 6, 4, 6, 3, 4, 4, 1, 1, 8, 3, 3, 5, 6, 4, 5, 8, 5)
)

preg_data |> kable()
```

a). Compute an estimate of the mean $\bar{y}$ its standard error, and a 95% confidence interval for the population mean. (Hint: the degrees of freedom used in computing this confidence interval should not be 199.)

-   The sample mean per ssu in psu $i$ under a two-stage cluster sampling is given as:

$$
\bar{y}_i = \sum_{j \in S_i} \frac{y{ij}}{m_i}
$$

-   Where $m_i$ is the number of ssus in the sample from psu $i$.

```r
m <- 10 # clusters of equal size
  
y_bar <- preg_data |> 
  reframe( sum(b) / ( m * n()) )   |> 
  pull(); y_bar
```

-   The standard error is given as:

$$
se(\bar{y}) = \sqrt{(1 - \frac{nm}{NM}\frac{s^2_B}{n} }
$$

-   Where n is the number of clusters.

```r
NM <- 2920
n <- 20
  
var_y <-  (
  (1 - ((n*m)/(NM))) * (1/n) * (1 / (m^2 * (n-1) ))
  ) * 
    ( 
      preg_data |> 
        reframe(sum(b^2) - (sum(b)^2 / n)) |>  pull() )


se <- sqrt(var_y); se
```

-   The 95% is given as:

$$
95\% \text{ CI: } \bar{y} \pm t_{0.975, n - 1}) se{\bar{y}} 
$$

```r
qt_value <- .975

lower <- y_bar -  qt(qt_value, n-1) * se
upper <- y_bar +  qt(qt_value, n-1) * se

lower
upper
```
- The estimated number of pregnancies in the female population between the ages of 15 - 24 is `r y_bar` (se=`r se`), `r str_c("95% CI: ", upper, ", ", lower)`.


\

b). Estimate the standard error of the mean that you would expect if the sample consisted of a = 40 clusters of b = 10 each. (Hint: What about this design has not changed, and what quantity needed to answer this question could therefore be considered portable?

- We need to first calculate the SRS sampling variance to use in the new projection as:

$$
var_{srs}(\bar{y}) = (1 - f)\frac{p(1-p)}{nm-1}
$$


```r
f <- (n*m)/NM

var_srs <- (1 -  f) * ((y_bar*(1-y_bar) / (n*m - 1))); var_srs
```

- From here were can calculate the design effect as:
$$
deff = \frac{var(\bar{y})}{var_{srs}(\bar{y})}
$$
```r
deff <- var_y / var_srs; deff
```

- Now that we have our design effect we can calculate row, or the ICC, as:
$$
\hat{roh} = \frac{deff - 1}{b - 1}
$$
```r
roh <- (deff - 1) / (m - 1) ; roh
```


- We now have the design effect and roh quantities that are needed to estimate the standard error under a different design. Our new design effect is given as:

$$
deff_{new} = 1 + (m_{new}-1) \times \hat{roh}
$$

```r
m_new <- m # new number of cluster size, does not change
deff_new <- 1 + (m_new -1) * roh ; deff_new
```

- Here we see that the new size of cluster m is portable as it is the same as in our last design. This also means that the design effect is the same. However, our number of clusters changes to n=40 and we calculate the new SRS as:


$$
var_{srs-new}(\bar{y}) = (1 - f_{new}) \frac{p(1-p)}{nm_{new} - 1}
$$

```r
n_new <- 40
nm_new <- n_new * m_new
f_new <- nm_new / NM

var_srs_new <- (1 - f_new) * ( (y_bar*(1-y_bar)) / (nm_new -1) ); var_srs_new

```

- We can use the new SRS variance and the new design effect to compute the new cluster design sampling variance and standard error as:
$$
se_{cluster-new}(\bar{y}) = \sqrt{ var_{srs-new} \times deff_{new} }
$$

```r
se_new <- sqrt(var_srs_new * deff_new) ;  se_new
```

- We can see that under the new cluster design, our estimated sampling standard error goes down to `r se_new`.



\

c). Note that the mean $\bar{y}$ is a proportion. Based on the sample of 20 clusters [and ignoring the ratio n / (n – 1)], compute the design effect $deff$, as well as roh. How would you interpret the design effect for a colleague in plain English?

- We calculated for the cluster sampling design the design effect and roh earlier in question b) and report the values here as $deff = `r deff`$ and $roh = `r roh`$. Ideally, we would employ SRS, where every woman in the population has an equal chance of being selected, regardless of location. However, practical considerations often necessitate cluster sampling. In this approach, we divide the population into natural clusters—such as neighborhoods—and then randomly select a subset of these clusters. In our case, we selected 20 clusters, each containing 10 women. A key aspect of cluster sampling is that individuals within a cluster tend to be more similar to each other than to individuals in other clusters. This similarity, often driven by factors like SES differences, impacts the precision of our estimates. The $deff$ quantifies this impact, telling us how much larger the variance of our estimate is due to using cluster sampling instead of SRS. We see that our complex design effect has a variance almost 1.5 times larger than that from the SRS. Our $roh$, or ICC, does tell us that about 5% of the variability in our the outcome variable is explained by the clustering in the design. A high $roh$ value indicates that there is a large amount of variability between clusters compared to the variability within clusters. This indicates that using cluster sampling has a large impact on the variance of the estimate. In essence, our cluster sampling design, while practical, results in a less precise estimate than an equivalent SRS would have provided. To achieve the same level of precision, we would require a significantly larger sample size.

\

d). Now, using the computed value of roh from part (c), estimate the standard error that you would expect from a sample of a = 40 clusters of b = 5 women each.

- We use the same equations as above only this time reducing the clustering size from 10 to 5. We observe a slightly higher standard error when there are 40 clusters with 5 women each. Under the new design, the standard error is estimated to slightly drop compared to the standard error we observed in a).

```r
n_new <- 40
m_new <- 5
nm_new <- n_new * m_new
f_new <- nm_new / NM
deff_new <- 1 + (m_new -1) * roh ; deff_new
var_srs_new <- (1 - f_new) * ( (y_bar*(1-y_bar)) / (nm_new -1) ); var_srs_new
se_new <- sqrt(var_srs_new * deff_new) ;  se_new

```



\

2. The data set, cherry.csv, contains measurements of diameter (inches), height (feet), and timber volume (cubic feet) for a sample of 31 black cherry trees. Diameter and height of trees are easily measured, but volume is more difficult to measure.

```r
cherry <- read_csv(
  "~/repos/UMD_classes_code/applied_sampling_SURV625/homework/cherry.csv")

cherry |> glimpse()
```



a). Plot volume vs. diameter for the 31 trees.
```r
cherry |> 
  ggplot(aes(x=diameter, y=volume)) +
  geom_line(color="dodgerblue", alpha=.75) +
  scale_fill_viridis_d(option="B") +
  ggthemes::theme_solarized() +
  ggtitle("Volume (cubic feet) vs diameter (in inches)\n of black cherry trees")

```


b). Suppose that these trees are an SRS from a forest of N = 2967 trees and that the sum of the diameters for all trees in the forest is 41,835 inches. Use ratio estimation to estimate the total volume for all trees in the forest. Give a 95% CI.

- The ratio estimator for $\hat{B}$ is given as:

$$
\hat{B} = \frac{\hat{t}_y}{\hat{t}_x} = \frac{\bar{y}}{\bar{x}} \text{, and } \hat{\bar{y}_r} = \hat{B}\bar{X}
$$
- The estimated ratio or volume to diameter in the sampling data is:
```r
N <- 2967 # population total trees
T_diam <- 41835 # population total diameter of trees

B_hat <- cherry |> 
  reframe(sum(volume)/sum(diameter)) |> 
  pull() ; B_hat

```

- To get a point estimate for total volume we compute our $\hat{B}$ estimate times the total volume in the population.
```r
t_yr <- B_hat * T_diam; t_yr
```

- We will need to calculate the standard error to get the 95% CI as:

$$
SE(\hat{t}_{yr}) = N \sqrt{1-\frac{n}{N}}(\frac{t_x/N}{\sum{x_i}})(\frac{\sigma(y_i-\hat{B}x_i)}{\sqrt{n}})
$$

$$
\hat{t}_{yr} \pm 1.96 \times SE(\hat{t}_{yr})
$$

```r
se <- cherry |> 
  mutate(resids =  volume - (B_hat * diameter)) |> 
  summarise( N * sqrt(1 - (n()/N)) *
               ((T_diam/N) / sum(diameter) ) *
               (sd(resids) / sqrt(n())) ) |> 
  pull()


ci_lower <- t_yr - 1.96*se; ci_lower 
ci_upper <- t_yr + 1.96*se; ci_upper 

```





c). Use regression estimation to estimate the total volume for all trees in the forest. Give a 95% CI.

- We can compute $B_1$ slope as:
$$
\hat{B}_1 = \frac{\sum_{i\in s} (x_i - \bar{x}) (y_i - \bar{y}) }
{\sum_{i \in s} (x_i - \bar{x}^2)} = \frac{rs_y}{s_x}
$$



```r
beta_1 <- cherry |> 
  summarise(
    rs_y = sum( (diameter - mean(diameter)) * (volume - mean(volume) )),
    s_x = sum( (diameter - mean(diameter))^2 ),
    beta_1 = rs_y / s_x
  ) |> 
  select(beta_1) |> 
  pull() ; beta_1
```

- We next compute the intercept as:
$$
\hat{B}_0 = \bar{y}_u - \hat{B}_1\bar{x}_u
$$

```r
beta_0 <- cherry  |> 
  summarise(
    mean(volume) - (beta_1*mean(diameter))
  ) |> 
  pull() ; beta_0
```

- We get the same beta coefficients using the lm function
```r
jtools::summ(lm(volume ~ diameter, data=cherry))
```
- We estimate the total volume by multiplying the population number of trees times $\beta_0+\beta_1(\bar{X})$.
```r
y_reg <- beta_0 + beta_1*mean(cherry$diameter); y_reg
t_yreg <- N * y_reg ; t_yreg
```

- We can now estimate the standard error for the total volume as:
$$
SE[\hat{y}_{reg}] = \sqrt{(1 - \frac{n}{N}) \frac{s^2_e}{n}}
$$
- where $s^2_e$ is calculated by calculating the residuals $e_i = y_i - \hat{\beta_0} + \hat{\beta_1} x_i$ as:

$$
s^2_e = \sum_{i \in s}^2 \frac{e_i}{n-2} 
$$

- We can now compute the 95% CI.

```r
se_y <- cherry |> 
  # calculate residuals
  mutate(resids =  volume - (beta_0 + beta_1*diameter)) |> 
  # calculate SE
  summarise(
    sqrt(
      (1 - (n()/N)) * ( sum(resids^2 / (n()-2) ) / n() )
    )
  ) |> pull()


# calculate the confidence interval
n <- cherry |> nrow()
ci_lower <- y_reg - qt(qt_value, n-2) * se_y; ci_lower* N
ci_upper <- y_reg + qt(qt_value, n-2) * se_y; ci_upper*N
```






