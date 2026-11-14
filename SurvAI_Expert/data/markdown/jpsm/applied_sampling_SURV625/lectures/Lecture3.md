---
id: "jpsm/applied_sampling_SURV625/lectures/Lecture3"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "lecture"
title: "Stratified Sampling"
original: "applied_sampling_SURV625/lectures/Lecture3.pdf"
pages: 76
sha256: "85b07a515d695f1eb38425798e6d5d9e31fceffddcba4dc6606a0199d7f6bfa0"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T16:06:31"
---

<!-- page 1 -->

# Stratified Sampling

## SurvMeth/Surv 625: Applied Sampling

Yajuan Si

University of Michigan, Ann Arbor

1/22/25

<!-- page 2 -->

# Stratified sampling

* Implementation
* Inference
* Projection

<!-- page 3 -->

# Implementation

* Dividing our population of elements into subgroups (strata) using auxiliary information that is available *prior* to drawing the sample

* Simple random sampling of elements WITHIN each of the strata (or population subgroups): **Independent** across strata

* Need the auxiliary information on the frame to create mutually exclusive and exhaustive subgroups (strata)

1. Avoid selecting a really bad SRS sample

<!-- page 4 -->

# Implementation

- Dividing our population of elements into subgroups (strata) using auxiliary information that is available *prior* to drawing the sample

- Simple random sampling of elements WITHIN each of the strata (or population subgroups): **Independent** across strata

- Need the auxiliary information on the frame to create mutually exclusive and exhaustive subgroups (strata)

1. Avoid selecting a really bad SRS sample

2. Desire precision for subgroups

<!-- page 5 -->

# Implementation

* Dividing our population of elements into subgroups (strata) using auxiliary information that is available *prior* to drawing the sample
* Simple random sampling of elements WITHIN each of the strata (or population subgroups): **Independent** across strata
* Need the auxiliary information on the frame to create mutually exclusive and exhaustive subgroups (strata)

1. Avoid selecting a really bad SRS sample
2. Desire precision for subgroups
3. More convenient to administer and may results in a lower survey cost

<!-- page 6 -->

# Implementation

* Dividing our population of elements into subgroups (strata) using auxiliary information that is available *prior* to drawing the sample

* Simple random sampling of elements WITHIN each of the strata (or population subgroups): **Independent** across strata

* Need the auxiliary information on the frame to create mutually exclusive and exhaustive subgroups (strata)

1. Avoid selecting a really bad SRS sample

2. Desire precision for subgroups

3. More convenient to administer and may results in a lower survey cost

4. Often gives more precise estimates for population means and totals

<!-- page 7 -->

# Inference

- We can apply everything that we've learned about for SRS within each of the strata
- Stratum index: $h = 1, ..., H$
- Denote the variable of interest for $i$-th element in stratum $h$ as $Y_{hi}$
- For each population stratum, population mean $\bar{Y}_h = \sum_{i=1}^{N_h} Y_{hi} / N_h$ and element variance $S_h^2 = \frac{1}{N_h - 1} \sum_{i=1}^{N_h} (Y_{hi} - \bar{Y}_h)^2$
- For each stratum in the sample, we can compute $\bar{y}_h, s_h^2, t_h, N_h, n_h,$ etc., in addition to sampling variances, etc.; **all specific to** $h$!

<!-- page 8 -->

# Inference: Population mean

* We can rewrite the population mean as a weighted sum of the population means for each stratum, where the weight $W_h$ is the relative proportion of the population within each stratum

$$
\bar{Y} = \sum_h \frac{N_h}{N}\bar{Y}_h \doteq \sum_h W_h \bar{Y}_h
$$

<!-- page 9 -->

# Inference: Population mean

* We can rewrite the population mean as a weighted sum of the population means for each stratum, where the weight $W_h$ is the relative proportion of the population within each stratum

$$
\bar{Y} = \sum_h \frac{N_h}{N}\bar{Y}_h \doteq \sum_h W_h \bar{Y}_h
$$

* We can write the sample mean in the same way, assuming that we have good (unbiased) estimates of the means in each stratum

$$
\bar{y}_w = \sum_h W_h \bar{y}_h
$$

<!-- page 10 -->

# Inference: Sampling weight

* Element-level weighting:

$$\bar{y}_w = \frac{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} y_{hi}}{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi}}$$

<!-- page 11 -->

# Inference: Sampling weight

* Element-level weighting:

$$\bar{y}_w = \frac{\sum_{h=1}^{H} \sum_{i=1}^{n_h} w_{hi} y_{hi}}{\sum_{h=1}^{H} \sum_{i=1}^{n_h} w_{hi}}$$

* Here we have introduced survey weight $w_{hi}$, the sampling weight for unit $i$ in stratum $h$

<!-- page 12 -->

# Inference: Sampling weight

* Element-level weighting:
$$\bar{y}_w = \frac{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} y_{hi}}{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi}}$$

* Here we have introduced survey weight $w_{hi}$, the sampling weight for unit $i$ in stratum $h$

* **The sampling weight in often the reciprocal of the inclusion probability**: $w_{hi} = \frac{1}{\pi_{hi}}$, where $\pi_{hi}$ is the inclusion probability of unit $i$ in stratum $h$.

<!-- page 13 -->

# Inference: Sampling weight

* Element-level weighting:
$$\bar{y}_w = \frac{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} y_{hi}}{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi}}$$

* Here we have introduced survey weight $w_{hi}$, the sampling weight for unit $i$ in stratum $h$

* **The sampling weight in often the reciprocal of the inclusion probability**: $w_{hi} = \frac{1}{\pi_{hi}}$, where $\pi_{hi}$ is the inclusion probability of unit $i$ in stratum $h$.

* For stratified sampling, $\pi_{hi} = n_h / N_h$, so we have $w_{hi} = N_h / n_h$ and $\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} = N$.

<!-- page 14 -->

# Inference: Sampling weight

* Element-level weighting:

$$\bar{y}_w = \frac{\sum_{h=1}^{H} \sum_{i=1}^{n_h} w_{hi} y_{hi}}{\sum_{h=1}^{H} \sum_{i=1}^{n_h} w_{hi}}$$

* Here we have introduced survey weight $w_{hi}$, the sampling weight for unit $i$ in stratum $h$

* **The sampling weight in often the reciprocal of the inclusion probability**: $w_{hi} = \frac{1}{\pi_{hi}}$, where $\pi_{hi}$ is the inclusion probability of unit $i$ in stratum $h$.

* For stratified sampling, $\pi_{hi} = n_h / N_h$, so we have $w_{hi} = N_h / n_h$ and $\sum_{h=1}^{H} \sum_{i=1}^{n_h} w_{hi} = N$.

* A stratified sample is self-weighting is the sampling fraction $n_h / N_h$ is the same across strata, where the sampling weight for each observation is $N/n$, exactly the same as in SRS.

<!-- page 15 -->

# Inference: Population mean cont.

**Within stratum** $h$: SRS

* Sampling fraction: $f_h = n_h / N_h$

<!-- page 16 -->

# Inference: Population mean cont.

**Within stratum** $h$: SRS

* Sampling fraction: $f_h = n_h / N_h$
* Mean estimate: $\bar{y}_h$ [or $p_h$ if proportion]

<!-- page 17 -->

# Inference: Population mean cont.

**Within stratum** $h$: SRS

* Sampling fraction: $f_h = n_h / N_h$
* Mean estimate: $\bar{y}_h$ [or $p_h$ if proportion]
* Element variance estimate: $s_h^2 = \frac{1}{n_h - 1} \sum_{i=1}^{n_h} (y_{hi} - \bar{y}_h)^2$ [or $s_h^2 = \frac{n_h}{n_h - 1} p_h (1 - p_h)$ if proportion]

<!-- page 18 -->

# Inference: Population mean cont.

**Within stratum** $h$: SRS

* Sampling fraction: $f_h = n_h / N_h$
* Mean estimate: $\bar{y}_h$ [or $p_h$ if proportion]
* Element variance estimate: $s_h^2 = \frac{1}{n_h - 1} \sum_{i=1}^{n_h} (y_{hi} - \bar{y}_h)^2$ [or $s_h^2 = \frac{n_h}{n_h - 1} p_h (1 - p_h)$ if proportion]
* Sampling variance estimate: $var(\bar{y}_h) = (1 - f_h)\frac{s_h^2}{n_h}$

<!-- page 19 -->

# Inference: Population mean cont.

**Within stratum** $h$: SRS

* Sampling fraction: $f_h = n_h / N_h$
* Mean estimate: $\bar{y}_h$ [or $p_h$ if proportion]
* Element variance estimate: $s_h^2 = \frac{1}{n_h - 1} \sum_{i=1}^{n_h} (y_{hi} - \bar{y}_h)^2$ [or $s_h^2 = \frac{n_h}{n_h - 1} p_h (1 - p_h)$ if proportion]
* Sampling variance estimate: $var(\bar{y}_h) = (1 - f_h) \frac{s_h^2}{n_h}$
* Standard error: $se(\bar{y}_h) = \sqrt{var(\bar{y}_h)}$

<!-- page 20 -->

# Inference: Population mean cont.

**Combine across strata**

The sampling variance of the overall estimated mean is entirely a function of the within-stratum sampling variances only!

$$
\begin{aligned}
var(\bar{y}_w) &= var(\sum_h W_h \bar{Y}_h) = \sum_h var(W_h \bar{Y}_h) \\
&= \sum_h W_h^2 var(\bar{y}_h) = \sum_h W_h^2 (1 - f_h) \frac{s_h^2}{n_h} \qquad (1)
\end{aligned}
$$

<!-- page 21 -->

# Example: Estimating the average number of farm acres per county

Use four U.S. census regions as strata to select counties

| Region | # Counties in population | # Counties in sample | Sample mean in region | Sample variance in region |
| :--- | :---: | :---: | :---: | :---: |
| Northest | 220 | 21 | ? | ? |
| North Central | 1054 | 103 | ? | ? |
| South | 1382 | 135 | ? | ? |
| West | 422 | 41 | ? | ? |
| **Total** | 3178 | 300 | | |

<!-- page 22 -->

# R code: Lu-Lohr-ch03.R

```r
########## Selecting a Stratified Random Sample ##########

##### Example 3.2, Select a stratified sample from agpop

### Use the sample function with each stratum
popsize <- table(agpop$region)
# Select an SRS without replacement from each region with pre-set allocation
# with total size n=300
regionname <- c("NC","NE","S","W")
# Make sure sampsize has same ordering as regionname
sampsize <- c(103,21,135,41)
# Set the seed for random number generation
set.seed(108742)
index <- NULL
for (i in 1:length(sampsize)) {
  index <- c(index,sample((1:N)[agpop$region==regionname[i]],
                          size=sampsize[i],replace=F))
}
strsample<-agpop[index,]
# Check that we have the correct stratum sample sizes
table(strsample$region)
```

```
 NC  NE   S   W
103  21 135  41
```

```r
# Print the first six rows of the sample to see
#strsample[1:6,]
```

<!-- page 23 -->

# R code cont.

```r
### Use the strata function from the sampling package

# Sort the population by stratum
agpop2<-agpop[order(agpop$region),]
# Use the strata function to select the units for the sample
# Make sure size argument has same ordering as the stratification variable
index2<-strata(agpop2,stratanames=c("region"),size=c(103,21,135,41),
               method="srswor")
table(index2$region) # look at number of counties selected within each region
```

```
 NC  NE   S   W 
103  21 135  41 
```

```r
#head(index2)
strsample2<-getdata(agpop2,index2) # extract the sample
#head(strsample2)
```

<!-- page 24 -->

# R code cont.

```r
# Calculate the sampling weights
# First check that no probabilities are 0
sum(strsample2$Prob<=0)
```

```
[1] 0
```

```r
strsample2$sampwt<-1/strsample2$Prob
# Check that the sampling weights sum to the population sizes for each stratum
tapply(strsample2$sampwt,strsample2$region,sum)
```

```
  NC   NE    S    W
1054  220 1382  422
```

```r
########## Computing Statistics from a Stratified Random Sample ##########

##### Example 3.2 and 3.6

data(agstrat)
#names(agstrat) # list the variable names
#agstrat[1:6,1:8] # take a look at the first 6 obsns from columns 1 to 8
#nrow(agstrat) # number of rows, 300
#unique(agstrat$region) # take a look at the four regions, NC, NE, S, W
table(agstrat$region) # number of counties in each stratum
```

```
 NC  NE   S   W
103  21 135  41
```

```r
# check that the sum of the weights equals the population size
sum(agstrat$strwt) #3078
```

```
[1] 3078
```

<!-- page 25 -->

# R code cont.

```r
### Draw a boxplot of the stratified random sample

#boxplot(acres92/10^6 ~ region, xlab = "Region", ylab = "Millions of Acres",
#        data = agstrat)
# notice the large variability in western region
```

<!-- page 26 -->

# R code: *survey* package

```r
### Set up information for the survey design

# create a variable containing population stratum sizes, for use in fpc (optional)
# popsize_recode gives popsize for each stratum
popsize_recode <- c('NC' = 1054, 'NE' = 220, 'S' = 1382, 'W' = 422)
# next statement substitutes 1054 for each 'NC', 220 for 'NE', etc.
agstrat$popsize <- popsize_recode[agstrat$region]
table(agstrat$popsize)  #check the new variable
```

```
 220  422 1054 1382
  21   41  103  135
```

```r
# input design information for agstrat
dstr <- svydesign(id = ~1, strata = ~region, weights = ~strwt, fpc = ~popsize,
                  data = agstrat)
#dstr

### Calculate the statistics using the design object

# calculate mean, SE and confidence interval
smean<-svymean(~acres92, dstr);smean
```

```
          mean    SE
acres92 295561 16380
```

```r
confint(smean, level=.95, df=degf(dstr)) # note that df = n-H = 300-4
```

```
         2.5 %   97.5 %
acres92 263325 327796.5
```

```r
# calculate total, SE and CI
stotal<-svytotal(~acres92, dstr); stotal
```

<!-- page 27 -->

# R code: *survey* package cont.

```r
### Alternative design specifications

# Get same result if omit weights argument since weight = popsize/n_h
dstrfpc <- svydesign(id = ~1, strata = ~region, fpc = ~popsize, data = agstrat)
svymean(~acres92, dstrfpc)
```

```
          mean    SE
acres92 295561 16380
```

```r
# If you include weights but not fpc, get SE without fpc factor
dstrwt <- svydesign(id = ~1, strata = ~region, weights = ~strwt, data = agstrat)
svymean(~acres92, dstrwt)
```

```
          mean    SE
acres92 295561 17241
```

```r
### Calculating stratum means and variances

# calculate mean and se of acres92 by regions
svyby(~acres92, by=~region, dstr, svymean, keep.var = TRUE)
```

```
   region   acres92       se
NC     NC 300504.16 16107.59
NE     NE  97629.81 18149.49
S       S 211315.04 18925.35
W       W 662295.51 93403.65
```

```r
# calculate total and se of acres92 by regions
svyby(~acres92, ~region, dstr, svytotal, keep.var = TRUE)
```

```
   region   acres92       se
NC     NC 316731380 16977399
NE     NE  21478558  3992889
S       S 292037391 26154840
```

<!-- page 28 -->

# R code: *survey* package cont.

```r
### Estimating proportions from a stratified random sample

# Option 1: Use a 0-1 variable and find its mean
# Create variable lt200k
agstrat$lt200k <- rep(0,nrow(agstrat))
agstrat$lt200k[agstrat$acres92 < 200000] <- 1
# Rerun svydesign because the data set now has a new variable
dstr <- svydesign(id = ~1, strata = ~region, fpc = ~popsize,
  weights = ~strwt, data = agstrat)
# calculate proportion, SE and confidence interval
smeanp<-svymean(~lt200k, dstr); smeanp
```

```
         mean     SE
lt200k 0.51391 0.0248
```

```r
confint(smeanp, level=.95,df=degf(dstr))
```

```
           2.5 %    97.5 %
lt200k 0.4651188 0.5627107
```

```r
# calculate total, SE and CI
stotalp<-svytotal(~lt200k, dstr); stotalp
```

```
        total     SE
lt200k 1581.8 76.318
```

```r
confint(stotalp, level=.95,df=degf(dstr))
```

```
          2.5 %   97.5 %
lt200k 1431.636 1732.024
```

```r
# Option 3: Construct asymmetric confidence intervals
# calculate proportion and confidence interval with svyciprop
svyciprop(~I(lt200k==1), dstr, method="beta")
```

<!-- page 29 -->

# Analysis of variance (ANOVA)

The sum of squares

$$
\begin{aligned}
\sum_{h=1}^{H} \sum_{i=1}^{N_h} (Y_{hi} - \bar{Y})^2 &= (N - 1)S^2 \\
&= \sum_{h=1}^{H} \sum_{i=1}^{N_h} (Y_{hi} - \bar{Y}_h + \bar{Y}_h - \bar{Y})^2 \\
&= \sum_{h=1}^{H} \sum_{i=1}^{N_h} (Y_{hi} - \bar{Y}_h)^2 + \sum_{h=1}^{H} \sum_{i=1}^{N_h} (\bar{Y}_h - \bar{Y})^2 \\
&= \sum_{h=1}^{H} (N_h - 1)S_h^2 + \sum_{h=1}^{H} N_h(\bar{Y}_h - \bar{Y})^2 \\
SSTO &\doteq SSW + SSB
\end{aligned}
$$

<!-- page 30 -->

# ANOVA cont.

We have the simplification as

$$
\begin{aligned}
S^2 &= \sum_{h=1}^{H} \frac{N_h - 1}{N - 1} S_h^2 + \sum_{h=1}^{H} \frac{N_h - 1}{N - 1} (\bar{Y}_h - \bar{Y})^2 \\
&\approx \sum_{h=1}^{H} W_h S_h^2 + \sum_{h=1}^{H} W_h (\bar{Y}_h - \bar{Y})^2 \qquad (2) \\
&= \text{Within-stratum variance} + \text{Between-stratum variance}
\end{aligned}
$$

* The overall $S^2$ is fixed; if we define strata such that the between-stratum variance component becomes large, the within-stratum variance will necessarily become smaller

<!-- page 31 -->

# ANOVA cont.

We have the simplification as

$$
\begin{aligned}
S^2 &= \sum_{h=1}^{H} \frac{N_h - 1}{N - 1} S_h^2 + \sum_{h=1}^{H} \frac{N_h - 1}{N - 1} (\bar{Y}_h - \bar{Y})^2 \\
&\approx \sum_{h=1}^{H} W_h S_h^2 + \sum_{h=1}^{H} W_h (\bar{Y}_h - \bar{Y})^2 \qquad (2) \\
&= \text{Within-stratum variance} + \text{Between-stratum variance}
\end{aligned}
$$

* The overall $S^2$ is fixed; if we define strata such that the between-stratum variance component becomes large, the within-stratum variance will necessarily become smaller
* Hence the sampling variance will go down based on Equation (1), which only depends on the within-stratum variance

<!-- page 32 -->

# ANOVA cont.

We have the simplification as

$$
\begin{aligned}
S^2 &= \sum_{h=1}^{H} \frac{N_h - 1}{N - 1} S_h^2 + \sum_{h=1}^{H} \frac{N_h - 1}{N - 1} (\bar{Y}_h - \bar{Y})^2 \\
&\approx \sum_{h=1}^{H} W_h S_h^2 + \sum_{h=1}^{H} W_h (\bar{Y}_h - \bar{Y})^2 \qquad (2) \\
&= \text{Within-stratum variance} + \text{Between-stratum variance}
\end{aligned}
$$

* The overall $S^2$ is fixed; if we define strata such that the between-stratum variance component becomes large, the within-stratum variance will necessarily become smaller
* Hence the sampling variance will go down based on Equation (1), which only depends on the within-stratum variance
* Decrease the sampling variance of the mean by **making strata heterogeneous between and homogeneous within**

<!-- page 33 -->

# Projection

* Always stratify! We give ourselves the potential to reduce the variance of estimates (the same strata will be used in every sample, reducing variance in the estimates across hypothetical samples)
* Expect gains in precision over designs that include the between variance as well
* But gains are not guaranteed. The reductions in the variance of estimates depend on the allocation.
* How do we determine how many elements to sample from each stratum?

<!-- page 34 -->

# Allocation

1. Proportionate allocation: Representative sampling where the sample reflects the population with respect to the stratification variable, $n_h/n = N_h/N = W_h$. We have $\pi_{hi} = n_h/N_h = n/N$, i.e., epsem

<!-- page 35 -->

# Allocation

1. Proportionate allocation: Representative sampling where the sample reflects the population with respect to the stratification variable, $n_h/n = N_h/N = W_h$. We have $\pi_{hi} = n_h/N_h = n/N$, i.e., epsem
2. Equal allocation: $n_h = n/H$, the same sample size across strata; minimize the sampling variance for comparisons $var(\bar{y}_h - \bar{y}_{h'})$

<!-- page 36 -->

# Allocation

1. Proportionate allocation: Representative sampling where the sample reflects the population with respect to the stratification variable, $n_h/n = N_h/N = W_h$. We have $\pi_{hi} = n_h/N_h = n/N$, i.e., epsem
2. Equal allocation: $n_h = n/H$, the same sample size across strata; minimize the sampling variance for comparisons $var(\bar{y}_h - \bar{y}_{h'})$
3. Neyman allocation: $n_h \propto W_h S_h$, giving the smallest ]]89sampling variance for $\bar{y}_w$

<!-- page 37 -->

# Allocation

1. Proportionate allocation: Representative sampling where the sample reflects the population with respect to the stratification variable, $n_h/n = N_h/N = W_h$. We have $\pi_{hi} = n_h/N_h = n/N$, i.e., epsem

2. Equal allocation: $n_h = n/H$, the same sample size across strata; minimize the sampling variance for comparisons $var(\bar{y}_h - \bar{y}_{h'})$

3. Neyman allocation: $n_h \propto W_h S_h$, giving the smallest ]]89sampling variance for $\bar{y}_w$

4. Optimum allocation: $n_h \propto W_h S_h / \sqrt{J_h}$, where $J_h$ is the cost related to stratum $h$

<!-- page 38 -->

# Proportionate allocation

* epsem: $f_h = n_h / N_h = n / N$ and $n_h = n W_h$

<!-- page 39 -->

# Proportionate allocation

* epsem: $f_h = n_h / N_h = n / N$ and $n_h = n W_h$
* No weighting is needed for the mean $\bar{y}_w = t / n$

<!-- page 40 -->

# Proportionate allocation

* epsem: $f_h = n_h / N_h = n / N$ and $n_h = nW_h$
* No weighting is needed for the mean $\bar{y}_w = t / n$
* Simplified sampling variance estimate:
  $var(\bar{y}_w) = \sum_h W_h^2 \frac{1-f_h}{n_h} s_h^2 = \frac{1-f}{n} \sum_h W_h s_h^2 = \frac{1-f}{n} s_w^2$

<!-- page 41 -->

# Proportionate allocation

* epsem: $f_h = n_h / N_h = n / N$ and $n_h = n W_h$
* No weighting is needed for the mean $\bar{y}_w = t / n$
* Simplified sampling variance estimate:
  $var(\bar{y}_w) = \sum_h W_h^2 \frac{1 - f_h}{n_h} s_h^2 = \frac{1 - f}{n} \sum_h W_h s_h^2 = \frac{1 - f}{n} s_w^2$
* Design effect:

$$deff = \frac{var(\bar{y}_w)}{var_{SRS}(\bar{y})} = \frac{\frac{1 - f}{n} s_w^2}{\frac{1 - f}{n} s^2} = \frac{s_w^2}{s^2} = 1 - \frac{\sum_h W_h (\bar{y}_h - \bar{y}_w)^2}{s^2}$$

<!-- page 42 -->

# Proportionate allocation

* epsem: $f_h = n_h / N_h = n / N$ and $n_h = n W_h$

* No weighting is needed for the mean $\bar{y}_w = t / n$

* Simplified sampling variance estimate:
  $var(\bar{y}_w) = \sum_h W_h^2 \frac{1-f_h}{n_h} s_h^2 = \frac{1-f}{n} \sum_h W_h s_h^2 = \frac{1-f}{n} s_w^2$

* Design effect:

$$deff = \frac{var(\bar{y}_w)}{var_{SRS}(\bar{y})} = \frac{\frac{1-f}{n} s_w^2}{\frac{1-f}{n} s^2} = \frac{s_w^2}{s^2} = 1 - \frac{\sum_h W_h (\bar{y}_h - \bar{y}_w)^2}{s^2}$$

* In general deff$<$1

<!-- page 43 -->

# Equal allocation

* Consider $n_h = n/H$ and $f_h = \frac{n/H}{N_h}$, not epsem unless strata are the same size

<!-- page 44 -->

# Equal allocation

* Consider $n_h = n/H$ and $f_h = \frac{n/H}{N_h}$, not epsem unless strata are the same size
* Need weighted estimates

<!-- page 45 -->

# Equal allocation

* Consider $n_h = n/H$ and $f_h = \frac{n/H}{N_h}$, not epsem unless strata are the same size
* Need weighted estimates
* Deff may actually be greater than 1

<!-- page 46 -->

# Equal allocation

* Consider $n_h = n/H$ and $f_h = \frac{n/H}{N_h}$, not epsem unless strata are the same size
* Need weighted estimates
* Deff may actually be greater than 1
* Why use it?

<!-- page 47 -->

# Equal allocation

* Consider $n_h = n/H$ and $f_h = \frac{n/H}{N_h}$, not epsem unless strata are the same size
* Need weighted estimates
* Deff may actually be greater than 1
* Why use it?
    * Suppose $S_h = S_{h'}$ for two different strata $h \neq h'$

<!-- page 48 -->

# Equal allocation

* Consider $n_h = n/H$ and $f_h = \frac{n/H}{N_h}$, not epsem unless strata are the same size
* Need weighted estimates
* Deff may actually be greater than 1
* Why use it?
  * Suppose $S_h = S_{h'}$ for two different strata $h \neq h'$
  * Equal allocation minimized the sampling variance $var(\bar{y}_h - \bar{y}_{h'})$

<!-- page 49 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$

<!-- page 50 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$
* Smallest sampling variance $var(\bar{y}_w)$

<!-- page 51 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$
* Smallest sampling variance $var(\bar{y}_w)$
* Gains in precison greater than proportionate allocation

<!-- page 52 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$
* Smallest sampling variance $var(\bar{y}_w)$
* Gains in precison greater than proportionate allocation
* Need estimates of $S_h$

<!-- page 53 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$
* Smallest sampling variance $var(\bar{y}_w)$
* Gains in precison greater than proportionate allocation
* Need estimates of $S_h$
    * In practice, use reasonable estimates

<!-- page 54 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$
* Smallest sampling variance $var(\bar{y}_w)$
* Gains in precison greater than proportionate allocation
* Need estimates of $S_h$
    * In practice, use reasonable estimates
    * Large gains require variation among $S_h$

<!-- page 55 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$
* Smallest sampling variance $var(\bar{y}_w)$
* Gains in precison greater than proportionate allocation
* Need estimates of $S_h$
  * In practice, use reasonable estimates
  * Large gains require variation among $S_h$
  * Large gains unlikely for proportions

<!-- page 56 -->

# Neyman allocation

* Consider $n_h = k W_h S_h$ with $k = n / \sum_h W_h S_h$
* Smallest sampling variance $var(\bar{y}_w)$
* Gains in precison greater than proportionate allocation
* Need estimates of $S_h$
  * In practice, use reasonable estimates
  * Large gains require variation among $S_h$
  * Large gains unlikely for proportions
  * Values specific to $Y$

<!-- page 57 -->

# Neyman allocation

* Consider $n_h = kW_hS_h$ with $k = n / \sum_h W_hS_h$
* Smallest sampling variance $var(\bar{y}_w)$
* Gains in precison greater than proportionate allocation
* Need estimates of $S_h$
    * In practice, use reasonable estimates
    * Large gains require variation among $S_h$
    * Large gains unlikely for proportions
    * Values specific to $Y$
    * For multipurpose surveys, allocations will vary as $S_h$'s vary across characteristics

<!-- page 58 -->

# Optimum allocation

* Consider a total fixed cost: $C = \sum_h n_h C_h$

<!-- page 59 -->

# Optimum allocation

- Consider a total fixed cost: $C = \sum_h n_h C_h$
- Minimize the sampling variance under total fixed cost

<!-- page 60 -->

# Optimum allocation

* Consider a total fixed cost: $C = \sum_h n_h C_h$
* Minimize the sampling variance under total fixed cost
* Allocate $n_h = k W_h S_h / \sqrt{C_h}$ with $k = \frac{C}{\sum_h W_h S_h \sqrt{C_h}}$

<!-- page 61 -->

# Optimum allocation

* Consider a total fixed cost: $C = \sum_h n_h C_h$
* Minimize the sampling variance under total fixed cost
* Allocate $n_h = k W_h S_h / \sqrt{C_h}$ with $k = \frac{C}{\sum_h W_h S_h \sqrt{C_h}}$
* Neyman allocation is a special case where costs are the same across strata

<!-- page 62 -->

# Optimum allocation

- Consider a total fixed cost: $C = \sum_h n_h C_h$

- Minimize the sampling variance under total fixed cost

- Allocate $n_h = k W_h S_h / \sqrt{C_h}$ with $k = \frac{C}{\sum_h W_h S_h \sqrt{C_h}}$

- Neyman allocation is a special case where costs are the same across strata

- Can result in higher precision or lower costs with variation among $S_h$

<!-- page 63 -->

# Optimum allocation

* Consider a total fixed cost: $C = \sum_h n_h C_h$
* Minimize the sampling variance under total fixed cost
* Allocate $n_h = k W_h S_h / \sqrt{C_h}$ with $k = \frac{C}{\sum_h W_h S_h \sqrt{C_h}}$
* Neyman allocation is a special case where costs are the same across strata
* Can result in higher precision or lower costs with variation among $S_h$
* Resulting $n_h$ can be larger than $N_h$, use $N_h$

<!-- page 64 -->

# Optimum allocation

* Consider a total fixed cost: $C = \sum_h n_h C_h$
* Minimize the sampling variance under total fixed cost
* Allocate $n_h = k W_h S_h / \sqrt{C_h}$ with $k = \frac{C}{\sum_h W_h S_h \sqrt{C_h}}$
* Neyman allocation is a special case where costs are the same across strata
* Can result in higher precision or lower costs with variation among $S_h$
* Resulting $n_h$ can be larger than $N_h$, use $N_h$
* Values specific to $Y$

<!-- page 65 -->

# Allocation: Summary

| | Proportionate | Equal | Neyman | Optimum |
| :--- | :---: | ---: | ---: | ---: |
| Goal | Representative | minimize the sampling variance for comparisons $var(\bar{y}_h - \bar{y}_{h'})$ | Minimize the sampling variance $var(\bar{y}_w)$ | Minimize the sampling variance under total fixed cost |
| $n_h$ | $nW_h$ | $n/H$ | $kW_hS_h$ | $kW_hS_h/\sqrt{C_h}$ |
| epsem? | Yes | No | No | No |
| deff | $< 1$ | unsure | $< 1$ | $< 1$ |
| Multi-purpose | All variables | All variables | Per variable | Per variable |

<!-- page 66 -->

# Example R code

```r
### Proportional allocation

popsize <- table(agpop$region)
propalloc <- 300*popsize/sum(popsize); propalloc
```

```
      NC       NE        S        W 
102.7290  21.4425 134.6979  41.1306 
```

```r
# Round to nearest integer
propalloc_int <- round(propalloc); propalloc_int
```

```
 NC  NE   S   W 
103  21 135  41 
```

```r
sum(propalloc_int) # check that stratum sample sizes sum to 300
```

```
[1] 300
```

```r
### Neyman allocation

stratvar <- c(1.1,0.8,1.0,2.0)
# Make sure the stratum variances in stratvar are in same
#  order as the table in popsize
neymanalloc <- 300*(popsize*sqrt(stratvar))/sum(popsize*sqrt(stratvar)); neymanalloc
```

```
       NC        NE         S         W 
101.07640  17.99204 126.36327  54.56828 
```

<!-- page 67 -->

# Example cont.

```r
neymanalloc_int <- round(neymanalloc); neymanalloc_int
```

```
 NC  NE   S   W 
101  18 126  55 
```

```r
sum(neymanalloc_int)
```

```
[1] 300
```

```r
### Optimal allocation

relcost <- c(1.4,1.0,1.0,1.8)
# Make sure the relative costs in relcost are in same
# order as the table in popsize
optalloc <- 300*(popsize*sqrt(stratvar/relcost))/sum(popsize*sqrt(stratvar/relcost)); optalloc
```

```
      NC       NE        S        W 
94.75776 19.95766 140.16833 45.11626 
```

```r
optalloc_int <- round(optalloc); optalloc_int
```

```
 NC  NE   S   W 
 95  20 140  45 
```

```r
sum(optalloc_int)
```

```
[1] 300
```

<!-- page 68 -->

# Determining the total sample size

* Define a quantity $v = \sum_h \frac{n}{n_h} (\frac{N_h S_h}{N})^2$ as an "average" variability per unit in a stratified random sample with the specified allocation, similar to $S^2$ as the variability per unit in an SRS

<!-- page 69 -->

# Determining the total sample size

* Define a quantity $v = \sum_h \frac{n}{n_h} (\frac{N_h S_h}{N})^2$ as an "average" variability per unit in a stratified random sample with the specified allocation, similar to $S^2$ as the variability per unit in an SRS
* Ignoring all stratum fpcs, $n_0 = z_{\alpha/2}^2 v / e^2$ is the required sample size to give the margin of error $e$

<!-- page 70 -->

# Determining the total sample size

* Define a quantity $v = \sum_h \frac{n}{n_h} (\frac{N_h S_h}{N})^2$ as an "average" variability per unit in a stratified random sample with the specified allocation, similar to $S^2$ as the variability per unit in an SRS
* Ignoring all stratum fpcs, $n_0 = z_{\alpha/2}^2 v / e^2$ is the required sample size to give the margin of error $e$
* It can also be calculated as $n_{SRS} v / S^2$, with $n_{SRS}$ being the required SRS sample size

<!-- page 71 -->

# Determining the total sample size

* Define a quantity $v = \sum_h \frac{n}{n_h} \left( \frac{N_h S_h}{N} \right)^2$ as an “average” variability per unit in a stratified random sample with the specified allocation, similar to $S^2$ as the variability per unit in an SRS
* Ignoring all stratum fpcs, $n_0 = z_{\alpha/2}^2 v / e^2$ is the required sample size to give the margin of error $e$
* It can also be calculated as $n_{SRS} v / S^2$, with $n_{SRS}$ being the required SRS sample size
* If $v < S^2$, as in proportional allocation, stratified sampling allows a desired precision with a smaller sample size than SRS

<!-- page 72 -->

# Number of strata

* Stratification requires discrete categories
    * Stratifying variables may be discrete
    * Continuous stratifying variables divided into categories
* How many categories to capture gains possible?
    * Generally 3-6 strata adequate for a single predictor
    * When more than one stratifier, “coarser” cuts on more variables preferred to “finer” cuts
    * “Deepest” stratification for $n_h = 2$ (or $H = n/2$)
    * “Even deeper” stratification: 1 per stratum, a singleton problem

<!-- page 73 -->

# Paired selection

* Paired selections $n_h = 2$ useful in practice
* “Deepest” stratification possible that allows sampling variances to be estimated without assumptions
* Paired selection is epsem: $N_h = N / H$
* Attraction of paired selection is the simplification in variance estimation
* When the design is epsem, proportionately allocated

<!-- page 74 -->

# Paired selection estimation

* The mean is unweighted, and estimate variance under the proportionate allocation: $\bar{y} = \sum_h \sum_i y_{hi}/n = \frac{\sum_h (y_{h1}+y_{h2})}{n}$

$$
\begin{aligned}
var(\bar{y}) &= \frac{1-f}{n} \sum_h W_h s_h^2 (\text{ where } W_h = 2/n) \\
&= \frac{1-f}{n} \sum_h \frac{2}{n} [(y_{h1} - \frac{y_{h1} + y_{h2}}{2})^2 + (y_{h2} - \frac{y_{h1} + y_{h2}}{2})^2] \\
&= \frac{1-f}{n^2} \sum_h (y_{h1} - y_{h2})^2,
\end{aligned}
$$

as the sum of squares of the differences

* For element sampling, the symmetry of the selection and variance estimation disrupted by 1) Blanks in the list, non-responding elements or 2) Analysis of subclasses, Remedy: collapse strata but with overestimated variance

<!-- page 75 -->

# Poststratification

* Poststratification: variables to be used to create strata are not available at the time of selection
* Stratify after selection using variables collected during the survey
* Gains in precision are possible, with suitable modification to variance estimation
* Population control adjustment
* Poststratification requires
  * Poststrata known for each element
  * Poststratum weights $W_h$ for each poststratum
  * New (approximate) variance estimator

<!-- page 76 -->

# Summary

1. Identify stratifying variables correlated with the measure(s) of interest
2. Choose “cuts” on the stratifying variables and divide the population into strata
3. $S_h$, $deff$, and $S^2$ are known, at least approximately, and known that fpc’s within strata can be ignored
4. Compute an stratified sample size $n = n_{SRS} * deff$
5. Determine an allocation for the desired $n$
6. Adjust $n$ based on expected $deff$ & allocate
7. Select sample and compute estimates taking the stratified sample selection into account
