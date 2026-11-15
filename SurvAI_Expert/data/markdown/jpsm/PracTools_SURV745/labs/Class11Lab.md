---
id: "jpsm/PracTools_SURV745/labs/Class11Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 11"
original: "PracTools_SURV745/labs/Class11Lab.pdf"
pages: 21
sha256: "b1f3fee4b0bc23932e1f806ec9de201c1b65d40a3363117fe4ffd0e21a649565"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:08"
---

<!-- page 1 -->

# PracTools Class 11

Sunghee Lee

4/12/2026

## VDK Example 14.2. Poststratified Estimator.

- Use `nhis.large` in `PracTools`. This includes the same variables as `nhis` but more cases.

A data frame with 21,588 observations on the following 18 variables.

`ID` Identification variable

`stratum` Sample design stratum

`psu` Primary sampling unit, numbered within each stratum (1,2)

`svywt` survey weight

`sex` Gender (1 = male; 2 = female)

`age.grp` Age group (1 = < 18 years; 2 = 18-24 years; 3 = 25-44 years; 4 = 45-64 years; 5 = 65+)

`hisp` Hispanic ethnicity (1 = Hispanic; 2 = Non-Hispanic White; 3 = Non-Hispanic Black; 4 = Non-Hispanic All other race groups)

`parents` Parents present in the household (1 = mother, father, or both present; 2 = neither present)

`educ` Highest level of education attained (1 = High school graduate, graduate equivalence degree, or less; 2 = Some college; 3 = Bachelor's or associate's degree; 4 = Master's degree or higher; NA = missing)

`race` Race (1 = White; 2 = Black; 3 = All other race groups)

`inc.grp` Family income group (1 = < \$20K; 2 = \$20000-\$24999; 3 = \$25000-\$34999; 4 = \$35000-\$44999; 5 = \$45000-\$54999; 6 = \$55000-\$64999; 7 = \$65000-\$74999; 8 = \$75K+; NA = missing)

`delay.med` Delayed medical care in last 12 months because of cost (1 = Yes; 2 = No; NA = missing)

`hosp.stay` Had an overnight hospital stay in last 12 months (1 = Yes; 2 = No; NA = missing)

`doc.visit` During 2 WEEKS before interview, did person see a doctor or other health care professional at a doctor's office, a clinic, an emergency room, or some other place? (excluding overnight hospital stay)? (1 = Yes; 2 = No)

`medicaid` Covered by medicaid, a governmental subsidy program for the poor (1 = Yes; 2 = No; NA = missing)

`notcov` Not covered by any type of health insurance (1 = Yes; 2 = No; NA = missing)

`doing.lw` What was person doing last week? (1 = Working for pay at a job or business; 2 = With a job or business but not at work; 3 = Looking for work; 4 = Working, but not for pay, at a job or business; 5 = Not working and not looking for work; NA = missing)

`limited` Is the person limited in any way in any activities because of physical, mental or emotional problems? (1 = Limited in some way; 2 = Not limited in any way; NA = missing)

1

<!-- page 2 -->

```r
data(nhis.large)
dim(nhis.large)
```

```
## [1] 21588    18
```

* The variable of interest is the total counts of persons covered by Medicaid.
* Poststrata are age group x Hispanic ethnicity (`hisp` recoded into 3 categories by collapsing categories 3 and 4).
* We will draw a sample from `nhis.large` and poststratify.

* Cross-tab shows that there is an interaction between age group and Hispanicity.

```r
hisp.r <- nhis.large$hisp
hisp.r[nhis.large$hisp == 4] <- 3
nhis.large1 <- data.frame(nhis.large, hisp.r)
t1 <- table(nhis.large1$medicaid,
            nhis.large1$age.grp,
            nhis.large1$hisp.r)
100 * round(prop.table(t1[,,1],2),3)
```

```
##
##          1    2    3    4    5
##   1 32.2 10.7  7.6 11.0 27.2
##   2 67.8 89.3 92.4 89.0 72.8
```

```r
100 * round(prop.table(t1[,,2],2),3)
```

```
##
##          1    2    3    4    5
##   1 12.6  6.6  3.8  3.1  3.7
##   2 87.4 93.4 96.2 96.9 96.3
```

```r
100 * round(prop.table(t1[,,3],2),3)
```

```
##
##          1    2    3    4    5
##   1 31.3 12.7  8.8  6.4 16.5
##   2 68.7 87.3 91.2 93.6 83.5
```

* Select srswor of size 250 from `nhis.large`.

2

<!-- page 3 -->

```r
# select srswor of size n
set.seed(-1570723087)
n <- 250
N <- nrow(nhis.large1)
sam <- sample(1:N, n)
samdat <- data.frame(nhis.large1[sam, ])

# compute srs weights and sampling fraction
d <- rep(N/n, n)
f1 <- rep(n/N, n)
```

* Poststratify using `postStratify` in `survey`.

```r
# srswor design object
nhis.dsgn <- svydesign(ids = ~0, # no clusters
                       strata = NULL, # no strata
                       fpc = ~f1,
                       data = samdat,
                       weights = ~d)

# use xtabs to get pop totals
N.PS <- xtabs(~age.grp + hisp.r, data = nhis.large1)

# poststratify
ps.dsgn <- postStratify(design = nhis.dsgn,
                        strata = ~age.grp + hisp.r,
                        population = N.PS)
```

```r
# Check that weights are calibrated for x's
# against pop totals
svytotal(~interaction(age.grp, hisp.r), ps.dsgn)
```

```
##                                  total SE
## interaction(age.grp, hisp.r)1.1   1952  0
## interaction(age.grp, hisp.r)2.1    581  0
## interaction(age.grp, hisp.r)3.1   1574  0
## interaction(age.grp, hisp.r)4.1    704  0
## interaction(age.grp, hisp.r)5.1    220  0
## interaction(age.grp, hisp.r)1.2   2870  0
## interaction(age.grp, hisp.r)2.2   1030  0
## interaction(age.grp, hisp.r)3.2   3424  0
## interaction(age.grp, hisp.r)4.2   3436  0
```

<!-- page 4 -->

```r
## interaction(age.grp, hisp.r)5.2  1877  0
## interaction(age.grp, hisp.r)1.3  1169  0
## interaction(age.grp, hisp.r)2.3   403  0
## interaction(age.grp, hisp.r)3.3  1126  0
## interaction(age.grp, hisp.r)4.3   871  0
## interaction(age.grp, hisp.r)5.3   351  0
```

```r
N.PS
```

```r
##          hisp.r
## age.grp     1    2    3
##       1  1952 2870 1169
##       2   581 1030  403
##       3  1574 3424 1126
##       4   704 3436  871
##       5   220 1877  351
```

```r
# PS est, standard errors and cv's
svytotal(~as.factor(medicaid), ps.dsgn, na.rm=TRUE)
```

```r
##                        total     SE
## as.factor(medicaid)1  2238.2 416.28
## as.factor(medicaid)2 19126.6 430.82
```

```r
cv(svytotal(~as.factor(medicaid), ps.dsgn, na.rm=TRUE))
```

```r
## as.factor(medicaid)1 as.factor(medicaid)2
##             0.1859912            0.0225246
```

```r
# srs est, standard error and cv's
svytotal(~as.factor(medicaid), nhis.dsgn, na.rm=TRUE)
```

```r
##                        total     SE
## as.factor(medicaid)1  1986.1 393.12
## as.factor(medicaid)2 19342.8 415.20
```

```r
cv(svytotal(~as.factor(medicaid), nhis.dsgn, na.rm=TRUE))
```

```r
## as.factor(medicaid)1 as.factor(medicaid)2
##            0.19793381           0.02146514
```

4

<!-- page 5 -->

```r
# Population value
table(nhis.large1$medicaid)
```

```
## 
##     1     2 
##  2281 19013
```

* Why is there a gap between `ps.dsgn` and `nhis.dsgn` and between the population and `nhis.dsgn` ?

```r
cbind(tabyl(nhis.large1$age.grp),tabyl(samdat$age.grp))
```

```
##   nhis.large1$age.grp    n   percent samdat$age.grp  n percent
## 1                   1 5991 0.27751529              1 63   0.252
## 2                   2 2014 0.09329257              2 25   0.100
## 3                   3 6124 0.28367612              3 67   0.268
## 4                   4 5011 0.23211970              4 66   0.264
## 5                   5 2448 0.11339633              5 29   0.116
```

```r
cbind(tabyl(nhis.large1$hisp.r),tabyl(samdat$hisp.r))
```

```
##   nhis.large1$hisp.r     n   percent samdat$hisp.r   n percent
## 1                  1  5031 0.2330461             1  54   0.216
## 2                  2 12637 0.5853715             2 160   0.640
## 3                  3  3920 0.1815824             3  36   0.144
```

5

<!-- page 6 -->

### VDK Example 14.3. Poststratified estimator as a way of correcting for undercoverage.

* Suppose that the sample frame `nhis.large` only covers 75% of the two population subgroups of (1) Hispanic and (2) non-Hispanic Blacks plus other race/ethnicities. Non-Hispanic whites are covered 100%.

```r
# create single variable to identify age.grp * hisp.r poststrata
m<-max(nhis.large1$hisp.r)
nhis.large1$PS <- (nhis.large1$age.grp-1)*m+nhis.large1$hisp.r
N.PS <- table(PS = nhis.large1$PS)
N.PS
```

```
## PS
##    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
## 1952 2870 1169  581 1030  403 1574 3424 1126  704 3436  871  220 1877  351
```

```r
# Create frame with undercoverage
# 75% coverage of Hispanics and non-Hispanic Black & Other.
# These correspond to poststrata
# 1,3,4,6,7,9,10,12,13, and 15.

PS.prob <- rep(c(0.75, 1, 0.75), 5)
cov.prob <- PS.prob[nhis.large1$PS]
N <- nrow(nhis.large1)
rn <- runif(N)
nhis.cov <- nhis.large1[rn <= cov.prob, ]
```

* This treats coverage as a random phenomenon in that every person has some chance of being in the frame.
  - May or may not be a realistic assumption, but is typical in the literature that analyzes the effects of undercoverage.
* Some linkage needed between the units in frame, sample selected from it, and rest of the universe in order to make inferences for the entire target population.
* Modeling coverage as a random occurrence is one way of doing this.

* Estimated totals of Medicaid recipients, their SEs, and CVs for Hispanics and non-Hispanics can be computed with:

6

<!-- page 7 -->

```r
# select srswor of size n
set.seed(610376119)
n <- 500
N.cov <- nrow(nhis.cov)
sam <- sample(1:N.cov, n)
samdat <- nhis.cov[sam, ]
n.PS <- table(samdat[, "age.grp"], samdat[, "hisp.r"])
n.PS
```

```
## 
##      1  2  3
##   1 14 75 32
##   2 12 30 14
##   3 29 93 26
##   4 15 89 17
##   5  5 43  6
```

```r
        # compute srs weights and sampling fraction
d <- rep(N.cov/n, n)
f1 <- rep(n/N.cov, n)
```

```r
# srswor design object
nhis.dsgn <- svydesign(ids = ~0, # no clusters
                       strata = NULL, # no strata
                       fpc = ~f1,
                       data = samdat,
                       weights = ~d)

# use xtabs to get pop totals
N.PS <- xtabs(~age.grp + hisp.r, data = nhis.large1)

# poststratify
ps.dsgn <- postStratify(design = nhis.dsgn,
                        strata = ~age.grp + hisp.r,
                        population = N.PS)
```

* Results for the population:

7

<!-- page 8 -->

```r
# pop totals
table(nhis.large1$medicaid)
```

```
##
##     1     2
##  2281 19013
```

```r
# srs standard error and cv's (pi-estimator)
svytotal(~ as.factor(medicaid), nhis.dsgn, na.rm=TRUE)
```

```
##                        total     SE
## as.factor(medicaid)1  2009.4 260.59
## as.factor(medicaid)2 17041.1 275.40
```

```r
cv(svytotal(~ as.factor(medicaid), nhis.dsgn, na.rm=TRUE))
```

```
## as.factor(medicaid)1 as.factor(medicaid)2
##            0.1296862            0.0161608
```

```r
# PS standard errors and cv's
svytotal(~ as.factor(medicaid), ps.dsgn, na.rm=TRUE)
```

```
##                      total     SE
## as.factor(medicaid)1  2473 343.15
## as.factor(medicaid)2 18844 352.10
```

```r
cv(svytotal(~ as.factor(medicaid), ps.dsgn, na.rm=TRUE))
```

```
## as.factor(medicaid)1 as.factor(medicaid)2
##           0.13875702           0.01868541
```

* Results for Hispanics:

```r
# pop totals
table(nhis.large1$medicaid[nhis.large1$hisp.r==1])
```

```
##
##    1    2
##  935 4020
```

8

<!-- page 9 -->

```r
# srs standard error and cv's (pi-estimator)
svytotal(~ as.factor(medicaid),
         subset(nhis.dsgn,hisp.r==1), na.rm=TRUE)
```

```
##                       total     SE
## as.factor(medicaid)1  386.42 119.51
## as.factor(medicaid)2 2473.09 285.20
```

```r
cv(svytotal(~ as.factor(medicaid),
            subset(nhis.dsgn,hisp.r==1), na.rm=TRUE))
```

```
## as.factor(medicaid)1 as.factor(medicaid)2
##             0.3092818            0.1153213
```

```r
# PS standard errors and cv's
svytotal(~ as.factor(medicaid),
         subset(ps.dsgn,hisp.r==1), na.rm=TRUE)
```

```
##                       total     SE
## as.factor(medicaid)1  858.41 259.20
## as.factor(medicaid)2 4118.32 263.38
```

```r
cv(svytotal(~ as.factor(medicaid), ps.dsgn, na.rm=TRUE))
```

```
## as.factor(medicaid)1 as.factor(medicaid)2
##             0.13875702           0.01868541
```

9

<!-- page 10 -->

**Table 14.2:** Comparison of $\pi$-estimates and poststratified estimates in Example 14.3 of totals and proportions of persons receiving Medicaid when the frame has undercoverage

| Statistic | Estimate | SE | $CV$ |
| :--- | :---: | :---: | :---: |
| Estimated totals | | | |
| Full population | | | |
| Actual population total | 2,281 | | |
| $\pi$-estimate | 2,009 | 260 | 0.130 |
| PS estimate | 2,473 | 343 | 0.139 |
| Hispanic | | | |
| Actual population total | 935 | | |
| $\pi$-estimate | 386 | 119 | 0.309 |
| PS estimate | 858 | 259 | 0.139 |
| | | | |
| Estimated proportions | | | |
| Full population | | | |
| Actual population proportion | 0.107 | | |
| $\pi$-estimate | 0.093 | 0.013 | 0.139 |
| PS estimate | 0.112 | 0.015 | 0.135 |
| Hispanic | | | |
| Actual population proportion | 0.189 | | |
| $\pi$-estimate | 0.184 | 0.041 | 0.223 |
| PS estimate | 0.190 | 0.042 | 0.219 |

10

<!-- page 11 -->

### VDK Example 14.4. Raking by age group and Hispanic Ethnicity.

* Rework Example 14.3 by raking to the age group and Hispanic ethnicity margins. Same srswor sample of 500 from covered pop used.
* `calibrate` function in `survey` does raking. `rake` is an alternative.

```r
# create marginal pop totals
N.age <- table(nhis.large1$age.grp)
N.hisp <- table(nhis.large1$hisp.r)
pop.totals <- c('(Intercept)' = N, N.age[-1], N.hisp[-1])
```

* Notice how vector of pop totals is defined!

```r
# create raked weights
rake.dsgn <- calibrate(design = nhis.dsgn,
                       formula = ~factor(age.grp) + factor(hisp.r),
                       calfun = "raking",
                       population = pop.totals)
```

```
## Sample: [1] "(Intercept)"      "factor(age.grp)2" "factor(age.grp)3" "factor(age.grp)
## [5] "factor(age.grp)5" "factor(hisp.r)2"  "factor(hisp.r)3"
## Popltn: [1] "(Intercept)" "2"           "3"           "4"           "5"
## [6] "2"           "3"
```

```r
# Check that weights are calibrated for x's
svytotal(~factor(age.grp), rake.dsgn)
```

```
##                    total SE
## factor(age.grp)1  5991  0
## factor(age.grp)2  2014  0
## factor(age.grp)3  6124  0
## factor(age.grp)4  5011  0
## factor(age.grp)5  2448  0
```

```r
table(nhis.large1$age.grp)
```

```
## 
##    1    2    3    4    5 
## 5991 2014 6124 5011 2448
```

11

<!-- page 12 -->

```r
svytotal(~factor(hisp.r), rake.dsgn)
```

```
##                 total SE
## factor(hisp.r)1  5031  0
## factor(hisp.r)2 12637  0
## factor(hisp.r)3  3920  0
```

```r
table(nhis.large1$hisp.r)
```

```
## 
##     1     2     3 
##  5031 12637  3920
```

* Raking results:

```r
#For the sample:
svytotal(~ as.factor(medicaid), rake.dsgn, na.rm=TRUE)
```

```
##                       total     SE
## as.factor(medicaid)1  2500.9 318.50
## as.factor(medicaid)2 18786.9 331.12
```

```r
cv(svytotal(~ as.factor(medicaid), rake.dsgn, na.rm=TRUE))
```

```
## as.factor(medicaid)1 as.factor(medicaid)2 
##           0.12735350           0.01762506
```

```r
#For Hispanics
svytotal(~ as.factor(medicaid),
         subset(rake.dsgn,hisp.r==1), na.rm=TRUE)
```

```
##                       total     SE
## as.factor(medicaid)1  725.08 208.03
## as.factor(medicaid)2 4241.95 214.54
```

```r
cv(svytotal(~ as.factor(medicaid),
         subset(rake.dsgn,hisp.r==1), na.rm=TRUE))
```

```
## as.factor(medicaid)1 as.factor(medicaid)2 
##           0.28690147           0.05057596
```

12

<!-- page 13 -->

### Example Quan Qual. Using both quantitative and qualitative auxiliaries.

* Survey of Mental Health Organizations population. `smho.N874`, a subset of `smho98`, in `PracTools`, contains 874 hospitals.

`EXPTOTAL` Total expenditures in 1998

`BEDS` Total inpatient beds

`SEENCNT` Unduplicated client/patient count seen during year

`EOYCNT` End of year count of patients on the role

`FINDIRCT` Hospital receives money from the state mental health agency ($1=\text{Yes}$; $2=\text{No}$)

`hosp.type` Hospital type ($1 = \text{Psychiatric}$; $2 = \text{Residential or veterans}$; $3 = \text{General}$; $4 = \text{Outpatient}$, partial care; $5 = \text{Multi-service, substance abuse}$)

* Goal is to estimate total of expenditures in some year after 1998, but we use the 1998 file to explore whether any of the covariates, `BEDS`, `SEENCNT`, `EOYCNT`, `FINDIRCT` and `hosp.type` would be useful predictors.
  * Drop the cases with `hosp.type`$= 4$. Outpatient units that do not have inpatient beds, making $\text{n=}725$.

```r
data(smho.N874)
smho <- smho.N874[smho.N874$hosp.type!=4,]
```

* Figure 14.2

```r
panel.cor <- function(x, y, digits=2, prefix="", cex.cor, ...)
{
    usr <- par("usr"); on.exit(par(usr))
    par(usr = c(0, 1, 0, 1))
    r <- abs(cor(x, y))
    txt <- format(c(r, 0.123456789), digits=digits)[1]
    txt <- paste(prefix, txt, sep="")
    if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
    text(0.5, 0.5, txt, cex = cex.cor)
}

pairs(smho[,1:5],
      lower.panel=panel.cor,
      cex.cor=2,
      cex.axis=1.4)
```

13

<!-- page 14 -->

* Figure 14.3

```r
par(mfrow=c(2,2),
    mar = c(4,4,2,1),
    mgp = c(2,1,0)
    )
hosp.labs <- c("psychiatric",
               "residential or veterans",
               "general",
               "partial care, outpatient",
               "multi-service, substance abuse"
               )

for (h in c(1,2,3,5)){
    pick <- smho$hosp.type == h
    x <- smho[pick, "BEDS"]
    y <- smho[pick, "EXPTOTAL"]/(10^6)
    if (h==1) {ylabel <- "Expenditures (millions)"}
    else {ylabel <- ""}
```

14

<!-- page 15 -->

```r
    plot(x, y ,pch = 16,
         ylim = range(smho[, "EXPTOTAL"]/(10^6)),
         xlab = "Beds",
         ylab = ylabel,
         cex.axis = 1.3,
         cex.lab = 1.3)
    grid(col = "grey40", lwd = 2)
    lines(lowess(x,y), col="gray70", lwd=2)
    title(main = hosp.labs[h])
}
```

```r
# Separate slope on beds in each hosp type
m2 <- glm(EXPTOTAL ~SEENCNT + EOYCNT +
            as.factor(FINDIRCT) + as.factor(hosp.type):BEDS,
          data = smho)
summary(m2)
```

```
##
## Call:
## glm(formula = EXPTOTAL ~ SEENCNT + EOYCNT + as.factor(FINDIRCT) +
```

15

<!-- page 16 -->

```r
##     as.factor(hosp.type):BEDS, data = smho)
## 
## Deviance Residuals: 
##      Min        1Q    Median        3Q       Max  
## -73055995  -3462503  -1823456   1416213 132000213  
## 
## Coefficients:
##                            Estimate Std. Error t value Pr(>|t|)    
## (Intercept)               1318589.1   912432.2   1.445 0.148856    
## SEENCNT                      1033.9      310.6   3.329 0.000918 ***
## EOYCNT                       2036.2      603.6   3.373 0.000782 ***
## as.factor(FINDIRCT)2        78026.1   965237.6   0.081 0.935595    
## as.factor(hosp.type)1:BEDS  98139.3     3318.8  29.570  < 2e-16 ***
## as.factor(hosp.type)2:BEDS  39489.4     5644.5   6.996 6.05e-12 ***
## as.factor(hosp.type)3:BEDS  77578.4    15082.2   5.144 3.48e-07 ***
## as.factor(hosp.type)5:BEDS  36855.8     8650.5   4.261 2.31e-05 ***
## ---
## Signif. codes:  0 ’***’ 0.001 ’**’ 0.01 ’*’ 0.05 ’.’ 0.1 ’ ’ 1
## 
## (Dispersion parameter for gaussian family taken to be 1.275171e+14)
## 
##     Null deviance: 2.3784e+17  on 724  degrees of freedom
## Residual deviance: 9.1430e+16  on 717  degrees of freedom
## AIC: 25615
## 
## Number of Fisher Scoring iterations: 2
```

* Figure 14.4

```r
par(mfrow=c(1,1))
plot(smho$BEDS, rstudent(m2),
     pch = 21,
     cex = 1.4,
     cex.lab = 1.3,
     cex.axis = 1.3,
     #     bg = c("red", "green3", "blue", "orange", 
     #  "yellow")[unclass(smho$hosp.type)],
     bg = c("gray0", "gray40", "gray80", "gray80", 
            "gray100")[unclass(smho$hosp.type)],
     xlab = "Beds",
     ylab = "Studentized residuals"
     )
abline(h = c(-3,3))
```

16

<!-- page 17 -->

```r
legend("topright",
       legend = hosp.labs[-4],
       #          pt.bg = c("red", "green3", "blue", "yellow"),
       pt.bg = c("gray0", "gray40", "gray80", "gray100"),
       pch=21,
       cex = 1.2
       )
```

* Large standardized residuals
  - Plot of expenditures versus beds was extremely diffuse for psychiatric hospitals. – If these large organizations could be recognized in advance of sampling, they might be selected with certainty
  - After sample is selected, it might be prudent to exclude such large units, whether they are certainties or not, from the process of computing calibration weights.
  - They can have a harmful effect on weights and resulting estimates since the implied slope in a GREG estimate can be affected by extreme points.
  - Note that residuals for variables other than total expenditures may not be extreme.

17

<!-- page 18 -->

* As a result, decision about whether to exclude particular units from computation of weights is not clear cut.

18

<!-- page 19 -->

### Example GREG.

* Select a sample of hospitals with $pp(\sqrt{beds})$ from `smho`

```r
require(sampling)
x <- smho[,"BEDS"]
# recode small hospitals to have a minimum MOS
x[x <= 5] <- 5
x <- sqrt(x)
n <- 80
set.seed(428274453)
pk <- n*x/sum(x)
sam <- UPrandomsystematic(pk)
sam <- sam==1
sam.dat <- smho[sam, ]
d <- 1/pk[sam]
```

* GREG on SEENCNT, EOYCNT and BEDS x hosp.type

```r
smho.dsgn <- svydesign(ids = ~0, # no clusters
                       strata = NULL, # no strata
                       data = sam.dat,
                       weights = ~d)

# Compute pop totals of auxiliaries
# Note these are the original not the recoded x's
x.beds <- by(smho$BEDS, smho$hosp.type, sum)
x.seen <- sum(smho$SEENCNT)
x.eoy <- sum(smho$EOYCNT)
N <- nrow(smho)

pop.tots <- c('(Intercept)' = N,
              SEENCNT = x.seen,
              EOYCNT = x.eoy,
              x.beds = x.beds)
sam.lin <- calibrate(design = smho.dsgn,
                     formula = ~SEENCNT + EOYCNT +
                       as.factor(hosp.type):BEDS,
                     population = pop.tots,
                     calfun="linear")
```

```
## Sample: [1] "(Intercept)"                "SEENCNT"
```

19

<!-- page 20 -->

```r
## [3] "EOYCNT"                      "as.factor(hosp.type)1:BEDS"
## [5] "as.factor(hosp.type)2:BEDS" "as.factor(hosp.type)3:BEDS"
## [7] "as.factor(hosp.type)5:BEDS"
## Popltn: [1] "(Intercept)" "SEENCNT"     "EOYCNT"      "x.beds.1"    "x.beds.2"
## [6] "x.beds.3"    "x.beds.5"
```

* Estimation using GREG-calibrated data

```r
svyby(~BEDS, by=~as.factor(hosp.type),
      design=sam.lin, FUN=svytotal)
```

```r
##   as.factor(hosp.type)  BEDS           se
## 1                    1 37978 3.236966e-12
## 2                    2 13066 1.803081e-12
## 3                    3  9573 9.856097e-13
## 5                    5 10077 3.074356e-12
```

```r
svytotal(~SEENCNT, sam.lin)
```

```r
##           total SE
## SEENCNT 1349241  0
```

```r
svytotal(~EOYCNT, sam.lin)
```

```r
##         total SE
## EOYCNT 505345  0
```

* Comparison of `EXPTOTAL` using base vs. GREG weights and from the population (`smho`)

```r
svytotal(~EXPTOTAL, smho.dsgn)
```

```r
##               total        SE
## EXPTOTAL 9192108954 955764623
```

```r
svytotal(~EXPTOTAL, sam.lin)
```

```r
##               total        SE
## EXPTOTAL 9386248820 917594832
```

20

<!-- page 21 -->

```r
sum(smho$EXPTOTAL)
```

```
## [1] 8774651373
```

* Comparison of base and GREG weights

```r
summary(weights(smho.dsgn))
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
##   2.187   5.472   7.747   9.216  10.875  33.679
```

```r
summary(weights(sam.lin))
```

```
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max.
##  0.02361  5.53896  7.84379  9.06250 10.80474 35.86041
```

* GREG with bounds

```r
sam.linBD <- calibrate(design = smho.dsgn,
                       formula = ~SEENCNT + EOYCNT +
                         as.factor(hosp.type):BEDS,
                       population = pop.tots,
                       bounds = c(0.4, 3), calfun = "linear")
```

```
## Sample: [1] "(Intercept)"                "SEENCNT"
## [3] "EOYCNT"                     "as.factor(hosp.type)1:BEDS"
## [5] "as.factor(hosp.type)2:BEDS" "as.factor(hosp.type)3:BEDS"
## [7] "as.factor(hosp.type)5:BEDS"
## Popltn: [1] "(Intercept)" "SEENCNT"     "EOYCNT"      "x.beds.1"    "x.beds.2"
## [6] "x.beds.3"    "x.beds.5"
```

```r
summary(weights(sam.linBD))
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
##   1.086   5.369   7.341   9.062  11.321  37.459
```
