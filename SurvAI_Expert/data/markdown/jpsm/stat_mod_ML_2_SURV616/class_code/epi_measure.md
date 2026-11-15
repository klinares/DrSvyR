---
id: "jpsm/stat_mod_ML_2_SURV616/class_code/epi_measure"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lab"
title: "epidemiology measures"
original: "stat_mod_ML_2_SURV616/class_code/epi_measure.qmd"
pages: 
sha256: "966f6fd7f956e558e3ce233a145c52e174decdd6f0ae323853a9eeac89ad32a7"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:19"
---


## Example from class:

![](epi_example.png)

### We enter the data as separate vectors to facilitate calculations.

```r
library(tidyverse)
library(epiR)
a <- 171
b <- 3264
c <- 117
d <- 4320

# total
t <- sum(a, b, c, d)
```

Calculate incidence among smokers and non-smokers using;

$$
I_{Exposed} = \frac{A}{A+B}
$$

$$
I_{Un-exposed} = \frac{C}{C+D}
$$

```r
ir_exp <- a / (a+b) ; ir_exp
ir_unexp <- c / (c+d) ; ir_unexp
```

-   About 5% of smokers had a stroke, almost twice as many as the non-smokers.

### Calculate relative risk:

$$
RR = \frac{I_{Exposed}} {I_{Un-exposed}}
$$

\$\$

\$\$

```r
RR <- round(ir_exp / ir_unexp, 4) 
```

-   Smokers are 1.88 times more at risk of having a stroke compared to non-smokers.

### Calculate Odds Ratio

$$
\hat{OR} = \frac{AD}{BC}
$$

```r
OR <- (a*d) / (b*c)
```

-   Our odds ratio is close to our relative risk estimate.

### Calculate Variances for OR and RR, to estimate 95% CI.

$$
Var(\ln \hat{R}) = \frac{b}{a(a+b)} + \frac{d}{c(c+d)}
$$

$$
Var(\ln \hat{O}) = \frac{1}{a} + \frac{1}{b} + \frac{1}{c} + \frac{1}{d} 
$$

```r
var_RR <- (b / (a*(a+b))) + (d / (c*(c+d))) ; var_RR
var_OR <- (1/a) + (1/b) + (1/c) + (1/d) ; var_OR



lower <- round(exp(log(RR) - 1.96 * sqrt(var_RR)) , 4)
upper <- round(exp(log(RR) + 1.96 * sqrt(var_RR)) , 4)

print(str_c("Printing 95% CI for relative risk . . . ", RR, 
            " [", lower, ", ",  upper, "]"))


lower <- round(exp(log(OR) - 1.96 * sqrt(var_OR)), 4)
upper <- round(exp(log(OR) + 1.96 * sqrt(var_OR)), 4)

print(str_c("Printing 95% CI for odds ratio. . . ", RR, 
            " [", lower, ", ", upper, "]"))


```

-   The intervals do not contains 1, so they are statistically significant and reject the Null hypothesis that the odds are equal across smokers and non-smokers.

\

## Prospective study:

```r

a <- 23
b <- 125
c <- 13 
d <- 150
t <- sum(a, b, c, d) 
# check attrition
attrition <- sum(a/t, b/t, c/t, d/t) ; attrition
```

### Calculate relative risk, and odds ratio from formula from before.

$$
\hat{R} = \frac{a(c+d)}{c(a+b)}
$$

```r
R_hat <- (a*(c+d)) / (c*(a+b)) ; R_hat
OR <- (a*d)/(b*c) ;  OR
```

-   The odds ratio is slightly larger than the relative risk.

Calculate the attributed risk percent in the exposed group.

$$
\hat{ARP}_{Exposed} \frac{\hat{R}-1}{\hat{R}}
$$

```r
ARP_exposed <-  (R_hat - 1) / R_hat ; ARP_exposed # fraction
```

-   The amount of disease incidence is 49% which can be attributed to an exposure in a prospective study.
-   This is also refereed to ARP, attributable risk percent when converting to a percent.

The attributable risk (ratio) of the exposed is calculated as incidence of the exposed - incidence of the non-exposed.

```r
ir_exp <- a / (a+b) 
ir_unexp <- c / (c+d) 
AR_exposed <- ir_exp - ir_unexp ; AR_exposed 

```

To calculate 95% CI we would need to calculate the standard error as:

$$
SE_{AR} = \sqrt{ \frac{a+c}{N} (1 - \frac{a+c}{N} )
(\frac{1}{a+b} + \frac{1}{c+d} })
$$

```r
SE_AR <- sqrt(
  ((a+c)/t)*(1-((a+c)/t )) * ( (1/(a+b)) + (1/(c+d)) )
)

(AR_exposed - 1.97*SE_AR) * 100 # lower
(AR_exposed + 1.97*SE_AR) * 100 # Upper
```

When we use the `epiR::epi.2by2()`we can see these results under "Attrib prev in the exposed."

\

### Calculate the attributable risk in the population

$$
\hat{A}_{pop} = \frac{ad-bc}{(a+c)(c+d)}
$$

```r


# reduction in incidence in the population that would
# occur in the absence of the risk factor
A_hat_pop <- (a*d - b*c) / ((a+c)* (c+d)) ; A_hat_pop # fraction

```

-   This is the reduction in incidence of 31% if the whole population were unexposed, comparing with actual exposure.
-   This is known as PARP, population attributable risk when converting to percent.

## Calculate the variance of the attributable risk in the population.

$$
V(\ln(1-\hat{A}_{pop}) = \frac{b + \hat{A}_{pop}(a+d)}{tc}
$$

```r
V <- (b + A_hat_pop* (a+d)) / (t*c) ;  V
```

###  

## In a retrospective study we use the OR instead of or relative risk, and calculate the attributable risk in the exposed group and population.

```r
R_hat <- (a*d)/(b*c) ; R_hat
A_exposed <-  (R_hat - 1) / R_hat ; A_exposed # fraction
```

## 

### For the population we change the denominator.

$$
\hat{A}_{pop} = \frac{ad-bc}{d(a+c)}
$$

```r
A_hat_pop <- (a*d - b*c) / ( d * (a+c)) ; A_hat_pop # fraction
```

### The variance is also computed differently

$$
V(\ln(1-\hat{A}_{pop}) = \frac{a}{c(a+c)}+\frac{b}{d(b+d)}
$$

### 

```r
V <- (a / (c * (a + c))) +
  (b / (d*(b+d)));  V
```

### We can now calculate 95% CI.

$$
LCL = 1-\exp{(
\ln(1-\hat{A}_{pop}) + 1.96
\sqrt{V(\ln(1-\hat{A}_{pop}))  }
})
$$

$$
UCL = 1-\exp{(
\ln(1-\hat{A}_{pop}) - 1.96
\sqrt{V(\ln(1-\hat{A}_{pop}))  }
})
$$

```r
LCL <- 1 - exp( A_hat_pop + 1.96 * sqrt(V) ) ; LCL
UCL <- 1 - exp( A_hat_pop - 1.96 * sqrt(V) ) ; UCL
```

\

### We can also use the r package epiR

```r
# create table for later
bp <- matrix(c(a, b, c, d), ncol = 2, byrow = TRUE)
epi.2by2(bp, method="cross.sectional")
```

# 
