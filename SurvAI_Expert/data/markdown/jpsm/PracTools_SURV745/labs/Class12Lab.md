---
id: "jpsm/PracTools_SURV745/labs/Class12Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 12"
original: "PracTools_SURV745/labs/Class12Lab.pdf"
pages: 24
sha256: "1a8ec2bcd5f6229f07953d6483c795ca9bd4008979b809857416e1d74eded4c5"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:13"
---

<!-- page 1 -->

# PracTools Class 12

Sunghee Lee

4/20/2026

## VDK Example 14.7. Constrain weights using quadratic programming.

* The same sample drawn from `smho.N874` after excluding hosp.type=4 in Example GREG in Class12Lab.pdf.
* Select a sample of hospitals with $pp(\sqrt{beds})$ for n=80.
* The range of the base weights was 2.19 to 33.68.
* Suppose that we want to constrain the weights to be in the range $[L, U] = [2, 18]$.
* The calibration model is the same as the one in the earlier section and includes the auxiliaries: `SEENCNT`, `EOYCNT`, and `as.factor(hosp.type):BEDS`.
* Use function `solve.QP` in `quadprog` package to solve general quadratic programming problems. We will use this for GREG generating bounded weights.

```r
# Same sampling process as Example GREG of Class12Lab

data(smho.N874)
smho<-smho.N874%>%
  filter(hosp.type!=4)

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

1

<!-- page 2 -->

* GREG on `SEENCNT`, `EOYCNT` and `BEDS` x `hosp.type`; Note we do not use `calibrate` here. Instead, `solve.QP` will be used.
* This process finds the GREG weight $\mathbf{w}$ from $\mathbf{C}^T\mathbf{w} \ge \mathbf{c}_0$.
* First, create $\mathbf{C} = \begin{pmatrix} \mathbf{X_S} \\ \mathbf{I_n} \\ -\mathbf{I_n} \end{pmatrix}$ noted as `Cmat` in below.
  - Here, $\mathbf{X_S}$ includes auxiliary data of the sample.
    * Because we use a linear regression for GREG, we include the regression intercept ("1") as one of the auxiliary variables (`one` in the code).
    * For `SEENCNT` and `EOYCNT`, we simply get these variables from the sample. For the interaction of `BEDS` x `hosp.type`, we create a variable, `X.hosp` that interacts the two. `SEENCNT`, `EOYCNT` and `X.hosp` are combined into `X` in the code.
  - $\mathbf{I}$ is an $n \times n$ identity matrix that has 1 on the diagonal, noted as `In` in the code.
  - `Cmat` combines `one`, `X`, `In` and `-In`.

```r
X.hosp <- model.matrix(~0 + as.factor(hosp.type):BEDS,
                       data = sam.dat)

X <- rbind(sam.dat[, "SEENCNT"], sam.dat[, "EOYCNT"],
           t(X.hosp))

one <- rep(1, n)
In <- diag(nrow = n)
Cmat <- rbind(one, X, In, -In)
```

* We then need to create $\mathbf{c}_0 = (\mathbf{t_X}, L\mathbf{1_n}, -U\mathbf{1_n}$.
  - For this, we have lower and upper weight bounds set already as follows:

```r
L <- 2
U <- 18
```

* $\mathbf{t_X}$ is the population total of the auxiliaries. Because the GREG model has an intercept, we include that in the population total, `N`. `c0a` combines `N` and population totals of `SEENCNT`, `EOYCNT` and `BEDS` x `hosp.type`.

```r
N <- nrow(smho)
x.seen <- sum(smho$SEENCNT)
x.eoy <- sum(smho$EOYCNT)
x.beds <- by(smho$BEDS, smho$hosp.type, sum)

c0a <- c(N, x.seen, x.eoy, x.beds)
c0a
```

<!-- page 3 -->

```r
##                                1       2       3       5
##     725 1349241  505345   37978   13066    9573   10077
```

* $L\mathbf{1}_{\mathbf{n}}$ and $-U\mathbf{1}_{\mathbf{n}}$ are combined into `c0b`.

```r
c0b <- c(L * one, -U * one)
```

* Compute full sample weights via QP

```r
fs.wts <- solve.QP(Dmat = diag(1/d),
                   dvec = 2 * one,
                   Amat = t(Cmat),
                   bvec = c(c0a, c0b),
                   meq = 7 # first 7 constraints
                           # are equality constraints
                   )
```

* Compare constrained (i.e., with bounds) and unconstrained weights via QP
* Notice large weights with unconstrained solution

```r
cbind(fs.wts$solution,fs.wts$unconstrained.solution)
```

```r
##            [,1]     [,2]
##  [1,] 10.638388 17.750471
##  [2,]  6.081294 10.468657
##  [3,]  8.214914 13.807106
##  [4,]  8.255851 13.365164
##  [5,] 10.562849 17.391839
##  [6,]  9.566395 15.453055
##  [7,]  6.878836 11.289277
##  [8,]  9.676794 15.789030
##  [9,]  4.177610 10.201121
## [10,]  8.079635 13.365164
## [11,]  9.661268 15.535034
## [12,]  9.880111 18.265084
## [13,]  6.419484 10.108801
## [14,]  9.629741 15.702985
## [15,]  8.633017 14.560767
## [16,]  7.370847 12.465213
## [17,]  8.215240 12.059071
## [18,]  8.272407 13.580745
```

3

<!-- page 4 -->

```r
## [19,] 12.631562 16.945820
## [20,]  2.352246  4.693075
## [21,]  2.000000  4.373547
## [22,]  3.989852  6.185129
## [23,]  6.801536 11.385631
## [24,]  6.207143  8.844579
## [25,] 10.059682 14.296004
## [26,]  6.068981  7.578401
## [27,]  3.146516  6.185129
## [28,]  4.375145  6.676014
## [29,]  8.256685 12.297887
## [30,] 14.640006 22.452768
## [31,] 18.000000 30.744718
## [32,]  8.997131 15.061774
## [33,]  9.604584 15.137653
## [34,] 16.440024 25.102957
## [35,]  9.195292 67.358303
## [36,] 11.696623 18.539763
## [37,]  2.000000  6.232607
## [38,] 18.000000 61.489437
## [39,]  9.483107 16.055906
## [40,]  3.568331 19.949808
## [41,] 12.091937 19.608760
## [42,]  6.203995 11.103687
## [43,]  9.412105 17.054101
## [44,] 13.979368 21.300566
## [45,] 14.180167 22.452768
## [46,] 18.000000 35.500943
## [47,] 18.000000 30.744718
## [48,] 18.000000 47.629513
## [49,] 12.343009 18.400886
## [50,]  5.053059  9.234966
## [51,]  7.342237 13.060215
## [52,] 17.509978 27.498912
## [53,] 15.635487 23.814757
## [54,]  3.825471  9.049743
## [55,] 10.391385 16.839576
## [56,]  2.208434  7.475033
## [57,] 10.440208 12.963112
## [58,]  6.040989  8.341945
## [59,] 14.143151 21.516821
## [60,] 18.000000 67.358303
## [61,]  2.000000 12.020605
## [62,]  2.000000  5.427887
## [63,]  2.000000 12.059071
```

4

<!-- page 5 -->

```r
## [64,]  9.996504 23.522540
## [65,] 18.000000 29.538570
## [66,]  7.413925 20.886923
## [67,]  2.000000  9.269881
## [68,] 17.296803 30.744718
## [69,] 11.478066 22.968991
## [70,]  2.000000  7.883693
## [71,] 18.000000 40.254286
## [72,]  3.281035 15.876504
## [73,] 16.334863 30.123549
## [74,]  2.000000  8.829369
## [75,]  9.544358 21.300566
## [76,]  9.048195 18.400886
## [77,] 16.076141 30.744718
## [78,]  2.000000  6.164374
## [79,]  2.000000 23.814757
## [80,]  2.000000 15.061774
```

- A Limitation of `solve.QP`
  - `solve.QP` can run out of memory when the sample size is large.
  - `Dmat` must be input as an $n \times n$ matrix even though it is diagonal and more compact methods of storage are available.
  - Increasing the amount of memory available to R may help.
  - In Windows, do this with the command: `memory.limit(size=4095)`
- Notice the changes in estimates and their variability depending on the weights applied in Table 14.8.

5

<!-- page 6 -->

**Table 14.8:** Estimated total expenditures and proportions of hospitals receiving direct financing, standard errors, and coefficients of variation for the $\pi$-estimate, GREG estimates, and bounded quadratic program weights in a *pps* sample from a subset of the Survey of Mental Health Organizations population

| Estimator (design object) | Estimate or population value | SE | $CV$ (%) |
| :--- | ---: | ---: | ---: |
| Total expenditures (000s) | | | |
| Population | 8,774,651 | | |
| $\pi$-estimate (smho.dsgn) | 9,322,854 | 915,126 | 9.82 |
| GREG (sam.lin) | 9,563,683 | 748,596 | 7.83 |
| Bounded-GREG (sam.linBD) | 9,612,035 | 744,746 | 7.75 |
| Bounded QP (qp.dsgn) | 9,509,333 | 800,769 | 8.42 |
| | | | |
| Mean expenditures (000s) | | | |
| Population | 12,103 | | |
| $\pi$-estimate (smho.dsgn) | 13,299 | 1,712 | 12.88 |
| GREG (sam.lin) | 13,191 | 1,033 | 7.83 |
| Bounded-GREG (sam.linBD) | 13,258 | 1,027 | 7.75 |
| Bounded QP (qp.dsgn) | 13,116 | 1,105 | 8.42 |
| | | | |
| Proportion with financing from state mental health agency | | | |
| Population | 0.336 | | |
| $\pi$-estimate (smho.dsgn) | 0.323 | 0.059 | 18.16 |
| GREG (sam.lin) | 0.303 | 0.051 | 16.92 |
| Bounded-GREG (sam.linBD) | 0.302 | 0.051 | 16.87 |
| Bounded QP (qp.dsgn) | 0.306 | 0.053 | 17.39 |

6

<!-- page 7 -->

### VDK Example 14.9. Trim and redistribute weights.

* We repeat Example GREG in Class11Lab.pdf (also used in VDK Example 14.7) in which a *pps* sample of hospitals is selected from smho.N874 after dropping type-4 facilities.
* The goal is to estimate the total expenditure of mental health organizations.
* Calibrate with the model `SEENCNT + EOYCNT + as.factor(hosp.type):BEDS`
* Use `trimWeights` in `survey` package and set bounds of weights at 2 and 18.

```r
smho.dsgn <- svydesign(ids = ~0, # no clusters
                       strata = NULL, # no strata
                       data = data.frame(sam.dat),
                       weights = ~d)

pop.tots <- c('(Intercept)' = N,
              SEENCNT = x.seen,
              EOYCNT = x.eoy,
              x.beds = x.beds)

smho.lin <- calibrate(design = smho.dsgn,
                      formula = ~SEENCNT + EOYCNT +
                        as.factor(hosp.type):BEDS,
                      population = pop.tots,
                      calfun="linear")
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
smho.lin.tr <- trimWeights(design = smho.lin,
                           lower = 2,
                           upper = 18,
                           strict = TRUE)
summary(weights(smho.lin.tr))
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   2.000   6.087   8.392   9.062  11.353  18.000
```

7

<!-- page 8 -->

```r
summary(weights(smho.lin))
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
## 0.02361 5.53896 7.84379 9.06250 10.80474 35.86041
```

* Comparison of an auxiliary variable, `SEENCNT`

```r
sum(smho$SEENCNT) # Population total
```

```
## [1] 1349241
```

```r
svytotal(~SEENCNT, smho.dsgn) # Sample w design weights
```

```
##           total     SE
## SEENCNT 1810500 424691
```

```r
svytotal(~SEENCNT, smho.lin) # Sample w GREG weights
```

```
##           total SE
## SEENCNT 1349241  0
```

```r
svytotal(~SEENCNT, smho.lin.tr) # Sample w trimmed GREG weights
```

```
##           total     SE
## SEENCNT 1470385 666944
```

* Comparison of the total expenditure, `EXPTOTAL`

```r
sum(smho$EXPTOTAL)
```

```
## [1] 8774651373
```

```r
svytotal(~EXPTOTAL, smho.dsgn)
```

```
##               total        SE
## EXPTOTAL 9192108954 955764623
```

8

<!-- page 9 -->

```r
svytotal(~EXPTOTAL, smho.lin)
```

```
##              total       SE
## EXPTOTAL 9386248820 917594832
```

```r
svytotal(~EXPTOTAL, smho.lin.tr)
```

```
##              total        SE
## EXPTOTAL 1.0187e+10 4538940993
```

9

<!-- page 10 -->

### Exercise Nonprob.

* We have three data sets: COVID.csv (a nonprobability sample dataset); GSS.csv (a probability sample dataset); ACS.csv (a population dataset) prepared for this exercise. Notice that, for the convenience of this exercise, data subsetting and variable recoding/renaming has been done on the original data sets. Each dataset is described as follows:

* COVID.csv
  - COVID-19 vaccination and people with disabilities on https://www.openicpsr.org/openicpsr/project/161502/version/V1/view?path=/openicpsr/161502/fcr:versions/V1&type=project
  - Nonprobability sample from Amazon Mechanical Turk (MTurk); Ages 18-75 years old
  - Variables included:
    * ID: ID variable, Renamed from code
    * AGE: Age in years, Renamed from age
    * MALE: Sex (1.Male, 0.Female), Recoded from gender
    * HRACE: Hispanic ethnicity & Race (1.Hispanic, 2.Non-Hispanic White, 3.Non-Hispanic Black, 4.Non-Hispanic Other), Recoded race_construct.4cat
    * EDUC: Educational Attainment (1.<Highschool, 2.Highschool/GED, 3.Some college, 4.>=BA/BS), Recoded from education
    * INCOME: Family income, (1.<\$30000, 2.<\$50000, 3.<\$90000, 4.>=\$90000), Recoded from income
    * EMPLOYED: Employment Status (1.Employed, 0.Other), Recoded from employment
    * DIFF_HEAR: Hearing Difficulty (1.Yes, 0.No), Renamed from wgss_hearing_dummy
    * DIFF_VISION: Vision Difficulty (1.Yes, 0.No), Renamed from wgss_vision_dummy
    * DIFF_WALK: Walking Difficulty (1.Yes, 0.No), Renamed from wgss_mobility_dummy
    * DIFF_SELFCARE: Self-care Difficulty (1.Yes, 0.No), Renamed from wgss_selfcare_dummy
    * DIFF_COG: Cognitive Difficulty (1.Yes, 0.No), Renamed from wgss_cognitive_dummy
    * HINSCOV: Covered by health insurance (1.Yes, 0.No), Renamed from ins_none
    * PARTY: Party id (1.Democrat, 2.Independent, 3.Republican), Recoded from political_party
    * POLVIEWS: Political views (1.Extremely liberal – 7. Extremely conservative), Renamed from political_views
    * VAC_POLITICS: Rate on “I think politics influenced the development of the COVID-19 vaccines.” (1.Strongly disagree – 7. Strongly agree), Renamed from vaccine_politics
    * VAC_TRUST: Rate on “I trust vaccines in general.” (1.Strongly disagree – 7. Strongly agree), Renamed from vaccine_generaltrust

10

<!-- page 11 -->

* VAC\_EFFECTIVE: Rate on “I think the COVID-19 vaccines will be effective.” (1.Strongly disagree – 7. Strongly agree), Renamed from vaccine\_effective
    * LONELY: Loneliness (3-9); Sum of responses (1.Hardly ever, 2.Sometimes, 3.Often) to 1) feeling lacking companionship, 2) feeling left out and 3) feeling isolated from others, Recoded from compart\_8, compart\_9, compart\_10

    * See “2021 COVID-19 Vaccine Survey\_codebook.xlsx” for source variables

* GSS.csv
  - General Social Survey from 2021
  - Uses a probability sample
  - For this exercise, only those aged 18 to 75 years old are included.
  - Variables included:
    * ID: ID variable
    * FINWGT: Final adjustment weight, Renames from WTSSNRPS
    * AGE: Age in years
    * MALE: Sex (1.Male, 0.Female), Recoded from SEX
    * HRACE: Hispanic ethnicity & Race (1.Hispanic, 2.Non-Hispanic White, 3.Non-Hispanic Black, 4.Non-Hispanic Other), Recoded from HISPANIC and RACEACS1 to RACEACS16
    * EDUC: Educational Attainment (1.$<$Highschool, 2.Highschool/GED, 3.Some college, 4.$>=$BA/BS), Recoded from DEGREE
    * INCOME: Family income, (1.$<$\$30000, 2.$<$\$50000, 3.$<$\$90000, 4.$>=$\$90000), Recoded from INCOME16
    * PARTY: Party id (1.Democrat, 2.Independent, 3.Republican), Recoded from PARTYID
    * POLVIEWS: Political views (1.Extremely liberal – 7. Extremely conservative)

    * See “GSS 2021 Codebook R1b.pdf” for source variables

* ACS.csv
  - American Community Survey 2019 1-Year PUMS
  - For this exercise, only those aged 18 to 75 years old are included, subsampled 20,000 cases, and normalized the final weight to reflect subsampling.
  - Variables included:
    * ID: ID variable, Renamed from SERIALNO
    * FINWGT: Final adjustment weight, Renames from PWGTP
    * AGE: Age in years, Renamed from AGEP
    * MALE: Sex (1.Male, 0.Female), Recoded from SEX
    * HRACE: Hispanic ethnicity & Race (1.Hispanic, 2.Non-Hispanic White, 3.Non-Hispanic Black, 4.Non-Hispanic Other), Recoded from HISP and RAC1P

11

<!-- page 12 -->

* EDUC: Educational Attainment (1.<Highschool, 2.Highschool/GED., 3.Some college, 4.>=BA/BS), Recoded from SCHL
    * EMPLOYED: Employment Status (1.Employed, 0.Other), Recoded from ESR
    * DIFF_HEAR: Hearing Difficulty (1.Yes, 0.No), Recoded from DEAR
    * DIFF_VISION: Vision Difficulty (1.Yes, 0.No), Recoded from DEYE
    * DIFF_WALK: Walking Difficulty (1.Yes, 0.No), Recoded from DPHY
    * DIFF_SELFCARE: Self-care Difficulty (1.Yes, 0.No), Recoded from DDRS
    * DIFF_COG: Cognitive Difficulty (1.Yes, 0.No), Recoded from DREM
    * HINSCOV: Covered by health insurance (1.Yes, 0.No), Recoded from HICOV

    * See "PUMS_Data_Dictionary_2019.pdf" for source variables

* Analysis Goal: Estimating the proportion of the population agreeing on VAC_POLITICS (Responses 6 and 7) in COVID.csv

    1. No adjustment – using the nonprobability sample as is
    2. Pseudo inclusion probability using GSS data

        – Explore auxiliaries and build a model
            * Consider the politicized nature of COVID
            * Consider missing in auxiliaries
        – Explore options in using inclusion probabilities

    3. #2 and raking using ACS data

        – Explore auxiliaries

    4. Compare estimates (and corresponding standard errors) from #1-#3.
    5. What reservations do you have in reporting the estimates from #1-#3?

* Data import

```r
COVID<-read.csv("COVID.csv")
GSS<-read.csv("GSS.csv")
ACS<-read.csv("ACS.csv")
```

### 1. No adjustment

```r
summary(COVID)
```

12

<!-- page 13 -->

```
##        ID              AGE             MALE            HRACE      
##  Min.   :  1.0   Min.   :18.00   Min.   :0.0000   Min.   :1.000  
##  1st Qu.:110.5   1st Qu.:29.00   1st Qu.:0.0000   1st Qu.:2.000  
##  Median :220.0   Median :35.00   Median :1.0000   Median :2.000  
##  Mean   :220.0   Mean   :38.07   Mean   :0.5274   Mean   :2.131  
##  3rd Qu.:329.5   3rd Qu.:44.50   3rd Qu.:1.0000   3rd Qu.:2.000  
##  Max.   :439.0   Max.   :75.00   Max.   :2.0000   Max.   :4.000  
##                                  NA's   :1        NA's   :4      
##       EDUC           INCOME         EMPLOYED       DIFF_HEAR     
##  Min.   :1.000   Min.   :1.000   Min.   :0.0000   Min.   :0.0000  
##  1st Qu.:3.000   1st Qu.:1.000   1st Qu.:0.0000   1st Qu.:0.0000  
##  Median :4.000   Median :2.000   Median :1.0000   Median :0.0000  
##  Mean   :3.363   Mean   :2.189   Mean   :0.6598   Mean   :0.2281  
##  3rd Qu.:4.000   3rd Qu.:3.000   3rd Qu.:1.0000   3rd Qu.:0.0000  
##  Max.   :4.000   Max.   :4.000   Max.   :1.0000   Max.   :1.0000  
##  NA's   :1                       NA's   :1        NA's   :5      
##   DIFF_VISION      DIFF_WALK      DIFF_SELFCARE       DIFF_COG     
##  Min.   :0.0000   Min.   :0.0000   Min.   :0.0000   Min.   :0.0000  
##  1st Qu.:0.0000   1st Qu.:0.0000   1st Qu.:0.0000   1st Qu.:0.0000  
##  Median :0.0000   Median :1.0000   Median :0.0000   Median :1.0000  
##  Mean   :0.4305   Mean   :0.5011   Mean   :0.3112   Mean   :0.5721  
##  3rd Qu.:1.0000   3rd Qu.:1.0000   3rd Qu.:1.0000   3rd Qu.:1.0000  
##  Max.   :1.0000   Max.   :1.0000   Max.   :1.0000   Max.   :1.0000  
##                                    NA's   :2        NA's   :2      
##     HINSCOV        VAC_POLITICS     VAC_TRUST     VAC_EFFECTIVE  
##  Min.   :0.0000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
##  1st Qu.:0.0000   1st Qu.:4.000   1st Qu.:5.000   1st Qu.:5.000  
##  Median :0.0000   Median :5.000   Median :6.000   Median :6.000  
##  Mean   :0.1002   Mean   :4.906   Mean   :5.584   Mean   :5.302  
##  3rd Qu.:0.0000   3rd Qu.:6.000   3rd Qu.:7.000   3rd Qu.:6.000  
##  Max.   :1.0000   Max.   :7.000   Max.   :7.000   Max.   :7.000  
##                   NA's   :2       NA's   :4       NA's   :2      
##      PARTY         POLVIEWS         LONELY     
##  Min.   :1.00   Min.   :1.000   Min.   :3.000  
##  1st Qu.:1.00   1st Qu.:2.000   1st Qu.:5.000  
##  Median :2.00   Median :4.000   Median :6.000  
##  Mean   :1.82   Mean   :3.744   Mean   :6.349  
##  3rd Qu.:3.00   3rd Qu.:6.000   3rd Qu.:8.000  
##  Max.   :3.00   Max.   :7.000   Max.   :9.000  
##                 NA's   :1       NA's   :9
```

```r
COVID<-COVID%>%
  mutate(VAC_POLITICS_AGREE=ifelse(is.na(VAC_POLITICS),NA,ifelse(
    VAC_POLITICS>5,1,0)),
    FINWGT=1,
```

13

<!-- page 14 -->

```r
    MALE=ifelse(MALE==2,0,MALE))# Recoding MALE=2 (Other) into 0 (Female)
                                # so that MALE can be used when combined with GSS

dCOVID<-svydesign(ids = ~0, strata = NULL,
                      data = COVID,
                      weights = ~FINWGT)

svymean(~VAC_POLITICS_AGREE,dCOVID,na.rm=T)
```

```
##                       mean     SE
## VAC_POLITICS_AGREE 0.45309 0.0238
```

* 45.3% (SE:2.4%) reported agreeing on VAC_POLITICS.

**2. Pseudo inclusion probability using GSS data**

* First, exploring auxiliaries by examining the relationship between the outcome and auxiliaries common between COVID and GSS.

```r
svyby(~AGE,~VAC_POLITICS_AGREE, dCOVID, svymean,na.rm=T)
```

```
##   VAC_POLITICS_AGREE      AGE        se
## 0                  0 37.90377 0.8486041
## 1                  1 38.30808 0.8579907
```

```r
svyby(~VAC_POLITICS_AGREE, ~MALE, dCOVID, svymean,na.rm=T)
```

```
##   MALE VAC_POLITICS_AGREE         se
## 0    0          0.5000000 0.03390291
## 1    1          0.4082569 0.03332731
```

```r
svyby(~VAC_POLITICS_AGREE, ~HRACE, dCOVID, svymean,na.rm=T)
```

```
##   HRACE VAC_POLITICS_AGREE         se
## 1     1          0.5348837 0.07615027
## 2     2          0.4444444 0.02763727
## 3     3          0.4687500 0.08831619
## 4     4          0.4117647 0.08449983
```

14

<!-- page 15 -->

```r
svyby(~VAC_POLITICS_AGREE, ~EDUC, dCOVID, svymean,na.rm=T)
```

```
##   EDUC VAC_POLITICS_AGREE         se
## 1    1           0.6250000 0.17135858
## 2    2           0.4727273 0.06739642
## 3    3           0.4436620 0.04173943
## 4    4           0.4502165 0.03277146
```

```r
svyby(~VAC_POLITICS_AGREE, ~INCOME, dCOVID, svymean,na.rm=T)
```

```
##   INCOME VAC_POLITICS_AGREE         se
## 1      1           0.4640523 0.04036400
## 2      2           0.4519231 0.04885754
## 3      3           0.4720000 0.04470212
## 4      4           0.3818182 0.06558436
```

```r
svyby(~VAC_POLITICS_AGREE, ~PARTY, dCOVID, svymean,na.rm=T)
```

```
##   PARTY VAC_POLITICS_AGREE         se
## 1     1           0.3782383 0.03494711
## 2     2           0.4573643 0.04391225
## 3     3           0.5739130 0.04616560
```

```r
svyby(~POLVIEWS,~VAC_POLITICS_AGREE, dCOVID, svymean,na.rm=T)
```

```
##   VAC_POLITICS_AGREE POLVIEWS         se
## 0                  0 3.251046 0.1155505
## 1                  1 4.350254 0.1466587
```

* Large differences in the outcome observed by MALE, HRACE, EDUC, INCOME, PARTY and POLVIEWS in that a higher agreement on VAC\_POLITICS\_AGREE is observed (without statistical testing):
  - among females (+other) than males
  - among Hispanics than non-Hispanics
  - with higher education
  - with higher income
  - with republicans
  - with more politically conservatives
* Second, comparing auxiliaries between COVID and GSS

15

<!-- page 16 -->

```r
summary(GSS)
```

```
##        ID           FINWGT            AGE             MALE       
##  Min.   :   1   Min.   :0.1724   Min.   :18.00   Min.   :0.0000  
##  1st Qu.:1124   1st Qu.:0.5487   1st Qu.:36.00   1st Qu.:0.0000  
##  Median :2230   Median :0.8389   Median :50.00   Median :0.0000  
##  Mean   :2234   Mean   :1.0211   Mean   :49.38   Mean   :0.4356  
##  3rd Qu.:3341   3rd Qu.:1.2328   3rd Qu.:63.00   3rd Qu.:1.0000  
##  Max.   :4471   Max.   :7.5570   Max.   :75.00   Max.   :1.0000  
##                                                  NA's   :12      
##      HRACE            EDUC           INCOME          PARTY      
##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
##  1st Qu.:2.000   1st Qu.:2.000   1st Qu.:2.000   1st Qu.:1.000  
##  Median :2.000   Median :3.000   Median :3.000   Median :2.000  
##  Mean   :2.163   Mean   :2.954   Mean   :2.725   Mean   :1.861  
##  3rd Qu.:2.000   3rd Qu.:4.000   3rd Qu.:4.000   3rd Qu.:3.000  
##  Max.   :4.000   Max.   :4.000   Max.   :4.000   Max.   :3.000  
##  NA's   :25      NA's   :12      NA's   :315     NA's   :12     
##     POLVIEWS    
##  Min.   :1.000  
##  1st Qu.:3.000  
##  Median :4.000  
##  Mean   :3.922  
##  3rd Qu.:5.000  
##  Max.   :7.000  
##  NA's   :37
```

```r
dGSS<-svydesign(ids = ~0, strata = NULL,
                data = GSS,
                weights = ~FINWGT)

svymean(~AGE,dCOVID,na.rm=T)
```

```
##       mean     SE
## AGE 38.073 0.6028
```

```r
svymean(~AGE,dGSS,na.rm=T)
```

```
##       mean     SE
## AGE 45.623 0.3705
```

16

<!-- page 17 -->

```r
svymean(~factor(MALE),dCOVID,na.rm=T)
```

```
##                 mean     SE
## factor(MALE)0    0.5 0.0239
## factor(MALE)1    0.5 0.0239
```

```r
svymean(~factor(MALE),dGSS,na.rm=T)
```

```
##                 mean     SE
## factor(MALE)0 0.51624 0.0107
## factor(MALE)1 0.48376 0.0107
```

```r
svymean(~factor(HRACE),dCOVID,na.rm=T)
```

```
##                   mean     SE
## factor(HRACE)1 0.098851 0.0143
## factor(HRACE)2 0.749425 0.0208
## factor(HRACE)3 0.073563 0.0125
## factor(HRACE)4 0.078161 0.0129
```

```r
svymean(~factor(HRACE),dGSS,na.rm=T)
```

```
##                  mean     SE
## factor(HRACE)1 0.15677 0.0089
## factor(HRACE)2 0.62966 0.0108
## factor(HRACE)3 0.10944 0.0067
## factor(HRACE)4 0.10413 0.0070
```

```r
svymean(~factor(EDUC),dCOVID,na.rm=T)
```

```
##                  mean     SE
## factor(EDUC)1 0.018265 0.0064
## factor(EDUC)2 0.127854 0.0160
## factor(EDUC)3 0.326484 0.0224
## factor(EDUC)4 0.527397 0.0239
```

```r
svymean(~factor(EDUC),dGSS,na.rm=T)
```

17

<!-- page 18 -->

```
##                   mean     SE
## factor(EDUC)1 0.099566 0.0084
## factor(EDUC)2 0.479964 0.0107
## factor(EDUC)3 0.120595 0.0071
## factor(EDUC)4 0.299875 0.0085
```

```r
svymean(~factor(INCOME),dCOVID,na.rm=T)
```

```
##                    mean     SE
## factor(INCOME)1 0.34852 0.0228
## factor(INCOME)2 0.23918 0.0204
## factor(INCOME)3 0.28702 0.0216
## factor(INCOME)4 0.12528 0.0158
```

```r
svymean(~factor(INCOME),dGSS,na.rm=T)
```

```
##                    mean     SE
## factor(INCOME)1 0.24921 0.0098
## factor(INCOME)2 0.16122 0.0085
## factor(INCOME)3 0.26550 0.0096
## factor(INCOME)4 0.32408 0.0101
```

```r
svymean(~factor(PARTY),dCOVID,na.rm=T)
```

```
##                   mean     SE
## factor(PARTY)1 0.44191 0.0237
## factor(PARTY)2 0.29613 0.0218
## factor(PARTY)3 0.26196 0.0210
```

```r
svymean(~factor(PARTY),dGSS,na.rm=T)
```

```
##                   mean     SE
## factor(PARTY)1 0.44697 0.0106
## factor(PARTY)2 0.23331 0.0094
## factor(PARTY)3 0.31972 0.0097
```

```r
svymean(~POLVIEWS,dCOVID,na.rm=T)
```

```
##            mean    SE
## POLVIEWS 3.7443 0.095
```

18

<!-- page 19 -->

```r
svymean(~POLVIEWS,dGSS,na.rm=T)
```

```
##             mean    SE
## POLVIEWS 3.9651 0.031
```

* Between GSS and COVID, differences (without statistical testing) emerge on
  - AGE: younger in COVID than GSS
  - HRACE: lower proportions of minorities in COVID than GSS
  - EDUC: higher education in COVID than GSS
  - INCOME: lower income in COVID than GSS
  - PARTY: lower proportion of republicans in COVID than GSS
  - POLVIEW: more liberal in COVID than GSS
* Given the observations above, a high missing rate on INCOME and a close relationship between PARTY and POLVIEW, we choose AGE, MALE, HRACE, EDUC and PARTY as auxiliaries.

```r
COMB<-bind_rows(COVID%>%mutate(NONPROB=1),
                GSS%>%mutate(NONPROB=0))%>%
  select(NONPROB,AGE,MALE,HRACE,EDUC,PARTY,FINWGT,ID)%>%
  drop_na() # Because any case with missing on auxiliaries will be
            # excluded from the analysis and will not have
            # predicted pr(s*_i)
            # In the real world, these missing will need to be imputed

# Refer to VDK Example 18.1
prop<-glm(NONPROB~AGE+factor(MALE)+factor(HRACE)+
            factor(EDUC)+factor(PARTY),
          family = binomial(link="logit"),
          weights = COMB$FINWGT,
          data = COMB)

# Obtaining pesudo inclusion probabilities and weights
COMB$L.hat <- prop$linear.predictors
COMB$pseudo.probs <- exp(COMB$L.hat) / (1+exp(COMB$L.hat))
COMB$pseudo.wt <- 1/COMB$pseudo.probs
sum(COMB$pseudo.wt[COMB$NONPROB==1])
```

```
## [1] 3720.304
```

```r
sum(COMB$FINWGT[COMB$NONPROB==1])
```

```
## [1] 433
```

19

<!-- page 20 -->

```r
summary(COMB$pseudo.wt[COMB$NONPROB==1])
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
##   1.582   3.042   4.455   8.592   7.851 144.307
```

```r
# Retaining the COVID sample cases from the combined sample as
# the outcome variable is available only for the COVID sample
COVID_ADJ <- COMB%>%
    filter(NONPROB==1)%>%
    left_join(COVID%>%select(ID,VAC_POLITICS_AGREE),by="ID")


dCOVID_ADJ <- svydesign(ids = ~0, strata = NULL,
                     data = COVID_ADJ,
                     weights = ~pseudo.wt)

svymean(~VAC_POLITICS_AGREE, design=dCOVID_ADJ, na.rm=T)
```

```
##                       mean     SE
## VAC_POLITICS_AGREE 0.49209 0.0444
```

```r
svymean(~VAC_POLITICS_AGREE,dCOVID,na.rm=T)
```

```
##                       mean     SE
## VAC_POLITICS_AGREE 0.45309 0.0238
```

* The estimate with the pseudo weights is 49.2% (SE: 4.4%), an increase from 45.3% (SE: 2.4%) without the adjustment.

**3. #2 and raking using ACS data**

* First, explore auxiliaries.
  * Because the common variables between COVID and ACS are not the same as those between COVID and GSS, one may expand the list of auxiliaries to explore. In particular, there are EMPLOYED, DIFF_ series variables and HISCOV, in addition to AGE, MALE, HRACE and EDUC. Here, for the brevity sake, we choose AGE, MALE, HRACE, EDUC and EMPLOYED.
  * Because raking requires qualitative variable, AGE requires recoding. This recoding can be informed by the relationship between a range of years and VAC_POLITICS_AGREE. Here, we arbitrarily choose categories of 18-34 years old, 35-50 years old, 50-64 years old and 65+ years old.

20

<!-- page 21 -->

```r
COVID_ADJ2<-COVID_ADJ%>%
  mutate(AGEC=ifelse(is.na(AGE),NA,ifelse(AGE<35,1,ifelse(
    AGE<51,2,ifelse(AGE<65,3,4)))))%>%
  left_join(COVID%>%select(ID,EMPLOYED),by="ID")%>%
  drop_na() # No missing on the auxiliaries
            # In the real world, imputation will be needed
            # for auxiliaries to be used in raking

dCOVID_ADJ2 <- svydesign(ids = ~0, strata = NULL,
                         data = COVID_ADJ2,
                         weights = ~pseudo.wt)

ACS<-ACS%>%
  mutate(AGEC=ifelse(is.na(AGE),NA,ifelse(AGE<35,1,ifelse(
    AGE<51,2,ifelse(AGE<65,3,4)))))

dACS<-svydesign(ids = ~0, strata = NULL,
                data = ACS,
                weights = ~FINWGT)

svymean(~factor(AGEC),dCOVID_ADJ2,na.rm=T)
```

```
##                   mean     SE
## factor(AGEC)1 0.35135 0.0384
## factor(AGEC)2 0.34674 0.0397
## factor(AGEC)3 0.19872 0.0420
## factor(AGEC)4 0.10319 0.0384
```

```r
svymean(~factor(AGEC),dACS,na.rm=T)
```

```
##                   mean     SE
## factor(AGEC)1 0.32221 0.0046
## factor(AGEC)2 0.28493 0.0044
## factor(AGEC)3 0.24913 0.0039
## factor(AGEC)4 0.14373 0.0029
```

```r
svymean(~factor(MALE),dCOVID_ADJ2,na.rm=T)
```

```
##                   mean    SE
## factor(MALE)0 0.51812 0.044
## factor(MALE)1 0.48188 0.044
```

21

<!-- page 22 -->

```r
svymean(~factor(MALE),dACS,na.rm=T)
```

```
##                     mean     SE
## factor(MALE)0 0.50383 0.0048
## factor(MALE)1 0.49617 0.0048
```

```r
svymean(~factor(HRACE),dCOVID_ADJ2,na.rm=T)
```

```
##                      mean     SE
## factor(HRACE)1 0.16324 0.0350
## factor(HRACE)2 0.61517 0.0456
## factor(HRACE)3 0.10449 0.0265
## factor(HRACE)4 0.11710 0.0372
```

```r
svymean(~factor(HRACE),dACS,na.rm=T)
```

```
##                       mean     SE
## factor(HRACE)1 0.175741 0.0039
## factor(HRACE)2 0.611121 0.0048
## factor(HRACE)3 0.124536 0.0037
## factor(HRACE)4 0.088602 0.0027
```

```r
svymean(~factor(EDUC),dCOVID_ADJ2,na.rm=T)
```

```
##                     mean     SE
## factor(EDUC)1 0.10441 0.0442
## factor(EDUC)2 0.41234 0.0465
## factor(EDUC)3 0.13649 0.0164
## factor(EDUC)4 0.34677 0.0340
```

```r
svymean(~factor(EDUC),dACS,na.rm=T)
```

```
##                     mean     SE
## factor(EDUC)1 0.10641 0.0031
## factor(EDUC)2 0.27186 0.0043
## factor(EDUC)3 0.31254 0.0044
## factor(EDUC)4 0.30919 0.0042
```

22

<!-- page 23 -->

```r
svymean(~factor(EMPLOYED),dCOVID_ADJ2,na.rm=T)
```

```
##                     mean     SE
## factor(EMPLOYED)0 0.4306 0.0465
## factor(EMPLOYED)1 0.5694 0.0465
```

```r
svymean(~factor(EMPLOYED),dACS,na.rm=T)
```

```
##                      mean     SE
## factor(EMPLOYED)0 0.34329 0.0044
## factor(EMPLOYED)1 0.65671 0.0044
```

* Between COVID_ADJ2 and ACS:
  - AGEC: younger in COVID_ADJ2 than ACS
  - MALE: no noticeable difference
  - HRACE: Slighly lower proportion of non-Hispanic others in COVID_ADJ2 than ACS
  - EDUC: Higher proportion of HS/GED and lower proportion of some college in COVID_ADJ2 than ACS
  - EMPLOYED: lower employment rate in COVID_ADJ2 than ACS
* We rake on AGEC, MALE, HRACE, EDUC and EMPLOYED

```r
N<-sum(ACS$FINWGT)
N.AGEC<-svytotal(~factor(AGEC),dACS,na.rm=T)
N.MALE<-svytotal(~factor(MALE),dACS,na.rm=T)
N.HRACE<-svytotal(~factor(HRACE),dACS,na.rm=T)
N.EDUC<-svytotal(~factor(EDUC),dACS,na.rm=T)
N.EMPLOYED<-svytotal(~factor(EMPLOYED),dACS,na.rm=T)

ACS.TOT <- c('(Intercept)' = N, N.AGEC[-1],N.MALE[-1],
             N.HRACE[-1],N.EDUC[-1],N.EMPLOYED[-1])

dCOVID_RAKE <- calibrate(design = dCOVID_ADJ2,
                         formula = ~factor(AGEC)+factor(MALE)+
                           factor(HRACE)+factor(EDUC)+
                           factor(EMPLOYED),
                         calfun = "raking",
                         population = ACS.TOT)


svymean(~VAC_POLITICS_AGREE,dCOVID_RAKE, na.rm=T)
```

23

<!-- page 24 -->

```
##                       mean     SE
## VAC_POLITICS_AGREE 0.48436 0.0381
```

```r
svymean(~VAC_POLITICS_AGREE,dCOVID_ADJ, na.rm=T)
```

```
##                       mean     SE
## VAC_POLITICS_AGREE 0.49209 0.0444
```

```r
svymean(~VAC_POLITICS_AGREE,dCOVID,na.rm=T)
```

```
##                       mean     SE
## VAC_POLITICS_AGREE 0.45309 0.0238
```

* Estimates change based on the weights. It is difficult to know which one is the right one to report at the end. A few things to consider in this decision making.
  - Unobserved and unobservable auxiliaries: Our adjustment in #2 and #3 are bounded by what is available. There could be other characteristics that may perfectly explain who responds to MTurk surveys. Often times, whether the observed auxiliaries do that or not cannot be known. This is an inherent problem when making any adjustments under the assumption of MAR.
  - Measurement comparability in auxiliaries: Measurement of auxiliaries of INCOME, EDUC and EMPLOY is not necessarily standardized. It would be wise to check the source documents to see whether the measurement on these variables across 3 data sources are comparable or not. If not comparable, it would be advisable to check whether to remove from the list of auxiliaries.

24
