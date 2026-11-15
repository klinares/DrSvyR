---
id: "jpsm/PracTools_SURV745/labs/Class2Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 2"
original: "PracTools_SURV745/labs/Class2Lab.pdf"
pages: 12
sha256: "6d9a6d19c18885593224cd98712c062906171324dde80176c4f4e7f7ba279a6e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:08"
---

<!-- page 1 -->

# PracTools Class 2

Sunghee Lee

1/26/2026

## VDK Example 3.11. Estimating power $\gamma$

- We will use `hospital` data:

```r
data(hospital)
```

**Description**

The `hospital` data file is a national sample of short-stay hospitals with fewer than 1000 beds.

**Usage**

```r
data(hospital)
```

**Format**

A data frame with 393 observations on the following 2 variables.

`y` Number of patients discharged by the hospital in January 1968

`x` Number of inpatient beds in the hospital

1

<!-- page 2 -->

* Fig 3.2: Scatter plot of an *srswor* of units 7, 17, 30, 33, 62, 111, 139, 247, 370 and 393 from `hospital` as a population.

```r
sam_hospital<-hospital[c(7,17,30,33,62,111,139,247,370,393),]
```

* Clearly, there is a positive relationship between $x$ and $y$. But the relationship is not a straight line.

* A model for $y$ that fits fairly well for the hospital population is:

$$
E_M(y_i) = \beta_1\sqrt{x_i} + \beta_2x_i
$$

and

$$
V_M(y_i) = v_i = \sigma^2x_i^\gamma
$$

* Here, per Godambe & Joshi (1965), $\gamma$ for the most efficient MOS would be:

$$
\sqrt{v_i} \propto \sqrt{x_i^\gamma}
$$

* Use `gammaFit` function to estimate $\gamma$, which leads to figuring out an efficient MOS.

```r
y=sam_hospital$y
x=sam_hospital$x
X=cbind(sqrt(x),x)
gammaFit(X=X, x=x, y=y, maxiter=100, tol=0.001)
```

<!-- page 3 -->

```r
## $g.hat
##        X
## 1.882531
##
## $converged
## [1] TRUE
##
## $steps
## [1] 9
```

* The most efficient MOS is $\sqrt{x^{1.88}}$. We can use $\sqrt{x^{1.75}}$ or $\sqrt{x^2}$ for simplicity.

<!-- page 4 -->

### VDK Example 3.13. Creating strata with equal total MOS

* Continue with Example 3.11 outcome but round $\gamma = 1.75$.

* Create $H = 10$ strata in the `hospital` population by accumulating the sorted list of $\sqrt{x^{1.75}}$ and forming strata that have about the same total value of $\sqrt{x^{1.75}}$. Select 2 units from each stratum.

```r
x <- hospital$x
g <- 1.75
H <- 10; nh <- 2
hosp.pop <- hospital[order(x), ]

# we are using sqrt(bed^1.75) as MOS
xg <- sqrt(x^g)
N <- nrow(hosp.pop)

# create H strata using cumulative sqrt(x^g) rule
cumxg <- cumsum(xg)
#smallest xg, sum of two smallest xg's, total xg's
cumxg[c(1,2,N)]
```

```
## [1]     7.498942    17.565060 51762.101974
```

```r
#stratum level MOS, made similar across 10 strata
size <- cumxg[N]/H
size
```

```
## [1] 5176.21
```

```r
#cut-off points between strata
brks <- (0:H)*size
brks
```

```
##  [1]     0.00  5176.21 10352.42 15528.63 20704.84 25881.05 31057.26 36233.47
##  [9] 41409.68 46585.89 51762.10
```

```r
#stratum membership
strata <- cut(cumxg, breaks = brks, labels = 1:H)
Nh <- table(strata)
Nh
```

```
## strata
##   1   2   3   4   5   6   7   8   9  10 
## 129  57  42  35  30  25  23  20  18  14
```

```r
str.selprobs <- rep(nh,H) / Nh
```

4

<!-- page 5 -->

```r
# selection probabilities for pp(sqrt(x^g))
pps.selprobs <- H*nh*xg / sum(xg)
round(cbind(Nh = Nh,
            stsrs = str.selprobs,
            pps.means = by(pps.selprobs,strata,mean)),
      4)
```

```
##      Nh stsrs pps.means
## 1  129 0.0155    0.0155
## 2   57 0.0351    0.0345
## 3   42 0.0476    0.0483
## 4   35 0.0571    0.0574
## 5   30 0.0667    0.0668
## 6   25 0.0800    0.0771
## 7   23 0.0870    0.0889
## 8   20 0.1000    0.0979
## 9   18 0.1111    0.1134
## 10  14 0.1429    0.1451
```

* Virtually the same selection probabilities between `stsrs` and `pps.means`. Why?

* Note $\pi_{hi} = \dfrac{2}{N_h} \doteq \dfrac{2}{N_h} \dfrac{z_{hi}}{\bar{z}_h}$

* With an optimal MOS, the efficiency gained from cluster sampling can be expected to be similar to the efficiency of stratified sampling.

5

<!-- page 6 -->

### VDK Example 3.14. Sample size calculation when using a model

* Use the 1998 Survey of Mental Health Organizations (SMHO) (dataset name `smho98`) as a population.

**Format**

A data frame with 875 observations on the following variables.

`STRATUM` Sample design stratum (1 = Psychiatric Hospital, private; 2 = Psychiatric Hospital, public; 3 = Residential, children; 4 = Residential, adults; 5 = General Hospital, public, inpatient or residential care; 6 = General Hospital, public, outpatient care only; 7 = General Hospital, private, inpatient or residential care; 8 = General Hospital, private, outpatient care only; 9 = Military Veterans, inpatient or residential care; 10 = Military Veterans, outpatient care only; 11 = Partial Care 12 = Outpatient care, private; 13 = Outpatient care, public; 14 = Multi-service, private; 15 = Multi-service, public; 16 = Substance Abuse)

`BEDS` Total inpatient beds

`EXPTOTAL` Total expenditures in 1998

`SEENCNT` Unduplicated client/patient count seen during year

`EOYCNT` End of year count of patients on the role

`Y_IP` Number of inpatient visits during year

`OPCSFRST` Number of outpatients on the rolls on the first day of the reporting year

`OPCSADDS` Number of outpatients admitted, readmitted, or transferred to the organization during the reporting year for less than a 24 hour period and not overnight

`OPCSVIST` Number of outpatient visits during the reporting year for less than a 24 hour period and not overnight

`EMGWALK` Number of emergency walk-ins during the reporting year

`PSYREHAB` Number of visits for psychiatric rehabilitation services

`IPCSADDS` Number of residential patients added during the reporting year or patients admitted for more than a 24 hour period

* Assume
  * Outcome variable: total expenditures (`EXPTOTAL`)
  * Correlate: number of beds (`BEDS`).

* We regress `EXPTOTAL` on `BEDS` and the square root of `BEDS` with the variance as specified in Eq (3.38):

$$E_M(y_i) = \beta_1 \sqrt{x_i} + \beta_2 x_i$$

$$V_M(y_i) = v_i = \sigma^2 x_i$$

The one large organization with $\text{BEDS} > 2000$ and all organizations with 0 beds are removed, leaving 670 as follows.

```r
data(smho98)
```

6

<!-- page 7 -->

```r
# Remove certainties and size=0
tmp <- smho98%>%
  filter(BEDS>0&BEDS<2000)

# Create model variables
x <- tmp[ , "BEDS"]
y <- tmp[ , "EXPTOTAL"]

# Object containing model results
# assumes 0 bed --> 0 expenditure
#WLS to deal with heteroscedasticity
m <- glm(y ~ 0 + sqrt(x) + x,
         weights = 1/x)

# Model results
summary(m)
```

```
##
## Call:
## glm(formula = y ~ 0 + sqrt(x) + x, weights = 1/x)
##
## Coefficients:
##         Estimate Std. Error t value Pr(>|t|)
## sqrt(x)  1044992      98955  10.560  < 2e-16 ***
## x          34677       9612   3.607 0.000332 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for gaussian family taken to be 1.723118e+12)
##
##     Null deviance: 2.3973e+15  on 670  degrees of freedom
## Residual deviance: 1.1510e+15  on 668  degrees of freedom
## AIC: 23495
##
## Number of Fisher Scoring iterations: 2
```

* The estimate of $\sigma^2$ is residual deviance divided by its degrees of freedom (i.e., MSE) or $(1.1510\text{e+}15)/668 = 1.7231\text{e+}12$. Using the same set of 670 units, the means of $x$, $\sqrt{x}$ and $y$ are 105.97, 8.84 and 12912191. If we want a CV of 0.15 as in Example 3.12:

$$
n = \frac{\left[\bar{v}_U^{(1/2)}\right]^2}{CV_0^2 \frac{[E_M(\bar{y}_U)]^2}{\sigma^2} + \frac{\bar{v}_U}{N}} = \frac{8.84^2}{0.15^2 \frac{12912191^2}{1.723118 \times 10^{12}} + \frac{105.97}{670}} \doteq 34 \qquad (3.37)
$$

7

<!-- page 8 -->

* 8.84 is used because $\sqrt{v_i} \propto \sqrt{x_i}$

```r
N <- nrow(tmp)
mean(y)
```

```
## [1] 12912191
```

```r
mean(x)
```

```
## [1] 105.9731
```

```r
mean(sqrt(x))
```

```
## [1] 8.839672
```

```r
# Estimate of sigma squared
sig2 <- m$deviance/m$df.residual

# Sample size n for CV = 0.15
n <- mean(sqrt(x))^2 / (0.15^2 * mean(y)^2 / sig2 + mean(x)/N)
ceiling(n)
```

```
## [1] 34
```

<!-- page 9 -->

### Example SRS Selection.

1. *srswr*

```r
sample(1:20, 4, replace=TRUE)
```

```
## [1]  7 16 14  3
```

```r
#sample() is a function in R base.
#default of sample() is replace=FALSE (i.e. wo replacement)
```

2. *srswor* 1

```r
sample(1e2, 4)
```

```
## [1] 49 97 65 48
```

3. *srswor* 2

```r
sample(1e2, 4)
```

```
## [1] 39 21 37  9
```

4. *srswor* - reproducible

```r
set.seed(12)
sample(1e2, 4)
```

```
## [1] 66 90 80 91
```

```r
set.seed(12)
sample(1e2, 4)
```

```
## [1] 66 90 80 91
```

9

<!-- page 10 -->

### VDK Example 3.18. Select a stratified sample ($stsrswor$)

* Select 10 mental health organizations from each of the six strata defined for `smho98` previously as below:
  1) Psychiatric hospital
  2) Residential
  3) General hospital
  4) Military veterans
  5) Partial/Outpatient
  6) Multiservice/Substance

* This stratification requires recoding of the variable `STRATUM` located in `smho98`.

`STRATUM` Sample design stratum (1 = Psychiatric Hospital, private; 2 = Psychiatric Hospital, public; 3 = Residential, children; 4 = Residential, adults; 5 = General Hospital, public, inpatient or residential care; 6 = General Hospital, public, outpatient care only; 7 = General Hospital, private, inpatient or residential care; 8 = General Hospital, private, outpatient care only; 9 = Military Veterans, inpatient or residential care; 10 = Military Veterans, outpatient care only; 11 = Partial Care 12 = Outpatient care, private; 13 = Outpatient care, public; 14 = Multi-service, private; 15 = Multi-service, public; 16 = Substance Abuse)

```r
data(smho98)
dim(smho98)
```

```
## [1] 875  12
```

```r
head(smho98)
```

```
##   STRATUM BEDS EXPTOTAL SEENCNT EOYCNT     Y_IP OPCSFRST OPCSADDS OPCSVIST
## 1       1   81  9066430    1791    184 9066.430       10      349     6321
## 2       1   80  9853392    1870    244 9853.392        3      411     6321
## 3       1   26  3906074    1273      0 3906.074       15      971    25604
## 4       1   90  9853392    1781    154 9853.392       15      803     6321
## 5       1   71  9853392    1839    206 9853.392       NA       NA       NA
## 6       1   81  9853392    1823    196 9853.392        6       73     6321
##   EMGWALK PSYREHAB IPCSADDS
## 1     919     5170     1523
## 2    1413       10     1523
## 3     138       NA      520
## 4    1117     5742     1523
## 5     974     5571     1523
## 6    1020     5633     1523
```

10

<!-- page 11 -->

```r
# Create a stratum variable with 6 levels and verify
smho98<-smho98%>%
  mutate(stratum6=case_when(STRATUM<=2 ~ 1,
                            STRATUM<=4 ~ 2,
                            STRATUM<=8 ~ 3,
                            STRATUM<=10 ~ 4,
                            STRATUM<=13 ~ 5,
                            STRATUM<=16 ~ 6,
                            TRUE        ~ NA_real_))
table(smho98$stratum6,smho98$STRATUM)
```

```
## 
##       1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
##   1 151  64   0   0   0   0   0   0   0   0   0   0   0   0   0   0
##   2   0   0  43  22   0   0   0   0   0   0   0   0   0   0   0   0
##   3   0   0   0   0 150  23  65  14   0   0   0   0   0   0   0   0
##   4   0   0   0   0   0   0   0   0  38  12   0   0   0   0   0   0
##   5   0   0   0   0   0   0   0   0   0   0  13  77  59   0   0   0
##   6   0   0   0   0   0   0   0   0   0   0   0   0   0  86  39  19
```

```r
table(smho98$stratum6)
```

```
## 
##   1   2   3   4   5   6 
## 215  65 252  50 149 144
```

* Onto sampling! Select 10 units by *srswor* per stratum.

```r
#detach(package:survival)

require(sampling)

set.seed(82841)

smp.IDs <- strata(data = smho98,
                  stratanames = "stratum6",
                  size = rep(10,6),
                  method = "srswor")

# Pull sampled records and verify sample counts
sample1 <- getdata(smho98,smp.IDs)
```

```r
tabyl(sample1$stratum6)
```

```
##  sample1$stratum6  n   percent
```

11

<!-- page 12 -->

```r
##                 1 10 0.1666667
##                 2 10 0.1666667
##                 3 10 0.1666667
##                 4 10 0.1666667
##                 5 10 0.1666667
##                 6 10 0.1666667
```

```r
tabyl(smho98$stratum6)
```

```r
##  smho98$stratum6   n    percent
##                1 215 0.24571429
##                2  65 0.07428571
##                3 252 0.28800000
##                4  50 0.05714286
##                5 149 0.17028571
##                6 144 0.16457143
```

12
