---
id: "jpsm/PracTools_SURV745/labs/Class5Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 5"
original: "PracTools_SURV745/labs/Class5Lab.pdf"
pages: 10
sha256: "a2c0cfd4716de07f470e3c911ab940dd853b65f16430edaa84af2b43f463750e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:13"
---

<!-- page 1 -->

# PracTools Class 5

Sunghee Lee

2/16/2026

## VDK Example 9.2 Between and within variance components in $srs/srs$ design

* MDarea.popA
* An artificial population of census tracts, block groups, and persons

**Format**

A data frame with 343,398 persons on the following variables:

`PSU` A grouping of block groups (`BLKGROUP`) which has about 4290 persons

`SSU` A grouping of block groups which has about 858 persons

`TRACT` A geographic area defined by the Census Bureau. Tracts generally have between 1,500 and 8,000 people but have a much wider range in Anne Arundel county.

`BLKGROUP` Block group. A geographic area defined by the Census Bureau. Block groups generally have between 600 and 3,000 people.

`Hispanic` Hispanic ethnicity (1=Hispanic; 2=Non-Hispanic)

`Gender` Gender (1=Male; 2=Female)

`Age` 23 level age category (1 = Under 5 years; 2 = 5 to 9 years; 3 = 10 to 14 years; 4 = 15 to 17 years; 5 = 18 and 19 years; 6 = 20 years; 7 = 21 years; 8 = 22 to 24 years; 9 = 25 to 29 years; 10 = 30 to 34 years; 11 = 35 to 39 years; 12 = 40 to 44 years; 13 = 45 to 49 years; 14 = 50 to 54 years; 15 = 55 to 59 years; 16 = 60 and 61 years; 17 = 62 to 64 years; 18 = 65 and 66 years; 19 = 67 to 69 years; 20 = 70 to 74 years; 21 = 75 to 79 years; 22 = 80 to 84 years; 23 = 85 years and over)

`person` Counter for person within tract/block group/Hispanic/Gender/Age combination

`y1` Artificial continuous variable

`y2` Artificial continuous variable

`y3` Artificial continuous variable

`ins.cov` Medical coverage (0 = person does not have medical insurance coverage; 1 = person has medical insurance coverage)

`hosp.stay` Overnight hospital stay (0 = person did not have an overnight hospital stay in last 12 months; 1 = person did have an overnight hospital stay in last 12 months)

* An artificial dataset of 343,398 persons based on the 2000 decennial U.S. Census for

1

<!-- page 2 -->

Anne Arundel County in the state of Maryland. Person records were generated based on counts from the 2000 census. Individual values for each person were generated using models. Groupings to form the variables PSU and SSU were done after sorting the census file by tract and block group within tract.

* Tracts and BGs vary a lot in size. Two other artificial geographic units created
  - PSU has about 4290 persons
  - SSU has about 858 persons
  - These let us illustrate the effects of having different sized sampling units.

```r
data(MDarea.popA)
head(MDarea.popA)
```

```
##      PSU SSU  TRACT BLKGROUP Hispanic Gender Age person    y1   y2    y3
## 4923   1   1 701101        1        1      1  11      1 219.0 18.6 128.8
## 4924   1   1 701101        1        1      1  11      2  44.2  2.2  77.0
## 4925   1   1 701101        1        1      1  11      3 176.9 14.6 116.3
## 4926   1   1 701101        1        1      1  11      4  63.2  4.0  82.7
## 4927   1   1 701101        1        1      1  11      5  46.1  2.4  77.6
## 4928   1   1 701101        1        1      1  11      6  64.6  4.1  83.1
##      ins.cov hosp.stay
## 4923       0         0
## 4924       0         0
## 4925       1         0
## 4926       1         0
## 4927       1         0
## 4928       0         0
```

* Assume an *srs*/*srs* design. Examine variance components with PSU and SSU variables as clusters for y1, y2, y3, ins.cov and hosp.stay. We can do so with `BW2stageSRS`.

```r
MDarea.popA%>%
  group_by(PSU)%>%
  summarise(N=n())%>%
  summary(N)
```

```
##       PSU              N       
##  Min.   : 1.00   Min.   :4291  
##  1st Qu.:20.75   1st Qu.:4292  
##  Median :40.50   Median :4292  
##  Mean   :40.50   Mean   :4292  
##  3rd Qu.:60.25   3rd Qu.:4293  
##  Max.   :80.00   Max.   :4293
```

2

<!-- page 3 -->

```r
MDarea.popA%>%
  group_by(SSU)%>%
  summarise(N=n())%>%
  summary(N)
```

```
##       SSU              N        
##  Min.   :  1.0   Min.   :858.0  
##  1st Qu.:100.8   1st Qu.:858.0  
##  Median :200.5   Median :858.0  
##  Mean   :200.5   Mean   :858.5  
##  3rd Qu.:300.2   3rd Qu.:859.0  
##  Max.   :400.0   Max.   :859.0
```

* `BW2stageSRS` computes variance components.

```r
BW2stageSRS(X,          # data vector
            psuID,      # PSU ID vector
            lonely.SSU # Handling of singleton SSUs
)
# List objects: B2, W2, unit relvar, B2+W2, k, delta
```

* With PSU as clusters:

```r
round(rbind(y1=BW2stageSRS(MDarea.popA$y1, psuID=MDarea.popA$PSU),
      y2=BW2stageSRS(MDarea.popA$y2, psuID=MDarea.popA$PSU),
      y3=BW2stageSRS(MDarea.popA$y3, psuID=MDarea.popA$PSU),
      ins.cov=BW2stageSRS(MDarea.popA$ins.cov, psuID=MDarea.popA$PSU),
      hosp.stay=BW2stageSRS(MDarea.popA$hosp.stay, psuID=MDarea.popA$PSU)),
      5)
```

```
##                B2       W2 unit relvar    B2+W2       k   delta
## y1        0.00798  1.45558     1.46312  1.46355 1.00030 0.00545
## y2        0.00704  1.01009     1.01681  1.01713 1.00032 0.00692
## y3        0.00898  0.10474     0.11357  0.11371 1.00123 0.07896
## ins.cov   0.00124  0.26013     0.26130  0.26137 1.00028 0.00475
## hosp.stay 0.01901 12.93384    12.94967 12.95286 1.00025 0.00147
```

* With SSU as clusters:

```r
round(rbind(y1=BW2stageSRS(MDarea.popA$y1, psuID=MDarea.popA$SSU),
      y2=BW2stageSRS(MDarea.popA$y2, psuID=MDarea.popA$SSU),
      y3=BW2stageSRS(MDarea.popA$y3, psuID=MDarea.popA$SSU),
      ins.cov=BW2stageSRS(MDarea.popA$ins.cov, psuID=MDarea.popA$SSU),
      hosp.stay=BW2stageSRS(MDarea.popA$hosp.stay, psuID=MDarea.popA$SSU)),
      5)
```

3

<!-- page 4 -->

```r
##                   B2       W2 unit relvar    B2+W2       k   delta
## y1           0.03661  1.42825     1.46312  1.46486 1.00119 0.02499
## y2           0.01733  1.00068     1.01681  1.01801 1.00118 0.01703
## y3           0.01845  0.09528     0.11357  0.11373 1.00140 0.16225
## ins.cov      0.00332  0.25829     0.26130  0.26161 1.00119 0.01268
## hosp.stay    0.05926 12.90564    12.94967 12.96490 1.00118 0.00457
```

* Values of $\delta$ range from 0.00147 to 0.07896 when PSUs identify the clusters.
* The $\delta$'s are somewhat larger when SSUs are clusters, reflecting the common phenomenon that smaller geographic areas are somewhat more homogeneous than large ones in household populations.
* Unit relvar $(S_U^2 / y_U^2)$ is close to B2+W2, implying that setting $\text{k} = 1$ in Eq. (9.5) is accurate.

* Assume an *srs/srs* design. Examine variance components with TRACT and BLKGROUP variables as clusters for y1, y2, y3, ins.cov and hosp.stay. We can do so with `BW2stageSRS`.

```r
MDarea.popA%>%
  group_by(TRACT)%>%
  summarise(N=n())%>%
  summary(N)
```

```r
##      TRACT              N       
##  Min.   :701101   Min.   :   74  
##  1st Qu.:706851   1st Qu.: 2318  
##  Median :731103   Median : 3512  
##  Mean   :728613   Mean   : 3615  
##  3rd Qu.:740602   3rd Qu.: 4832  
##  Max.   :751103   Max.   :11542
```

```r
MDarea.popA$trtBG <- 10*MDarea.popA$TRACT + MDarea.popA$BLKGROUP

MDarea.popA%>%
  group_by(trtBG)%>%
  summarise(N=n())%>%
  summary(N)
```

```r
##      trtBG               N         
##  Min.   :7011011   Min.   :  44.0  
##  1st Qu.:7066004   1st Qu.: 663.5  
##  Median :7311012   Median :1054.0  
##  Mean   :7277551   Mean   :1118.6  
##  3rd Qu.:7405002   3rd Qu.:1471.0  
##  Max.   :7511034   Max.   :4033.0
```

4

<!-- page 5 -->

* Variance components with TRACT as clusters:

```r
round(rbind(y1=BW2stageSRS(MDarea.popA$y1, psuID=MDarea.popA$TRACT),
      y2=BW2stageSRS(MDarea.popA$y2, psuID=MDarea.popA$TRACT),
      y3=BW2stageSRS(MDarea.popA$y3, psuID=MDarea.popA$TRACT),
      ins.cov=BW2stageSRS(MDarea.popA$ins.cov, psuID=MDarea.popA$TRACT),
      hosp.stay=BW2stageSRS(MDarea.popA$hosp.stay, psuID=MDarea.popA$TRACT)),
      5)
```

```
##                B2       W2 unit relvar    B2+W2       k   delta
## y1        0.26034  1.84058     1.46312  2.10092 1.43592 0.12392
## y2        0.26863  1.26783     1.01681  1.53645 1.51106 0.17484
## y3        0.27071  0.12533     0.11357  0.39604 3.48702 0.68355
## ins.cov   0.26294  0.32607     0.26130  0.58901 2.25417 0.44641
## hosp.stay 0.30939 16.37595    12.94967 16.68534 1.28848 0.01854
```

* Variance components with trtBG as clusters:

```r
round(rbind(y1=BW2stageSRS(MDarea.popA$y1, psuID=MDarea.popA$trtBG),
      y2=BW2stageSRS(MDarea.popA$y2, psuID=MDarea.popA$trtBG),
      y3=BW2stageSRS(MDarea.popA$y3, psuID=MDarea.popA$trtBG),
      ins.cov=BW2stageSRS(MDarea.popA$ins.cov, psuID=MDarea.popA$trtBG),
      hosp.stay=BW2stageSRS(MDarea.popA$hosp.stay, psuID=MDarea.popA$trtBG)),
      5)
```

```
##                B2       W2 unit relvar    B2+W2       k   delta
## y1        0.34954  1.94883     1.46312  2.29837 1.57087 0.15208
## y2        0.34950  1.33443     1.01681  1.68393 1.65610 0.20755
## y3        0.34948  0.12195     0.11357  0.47143 4.15086 0.74131
## ins.cov   0.34144  0.34268     0.26130  0.68413 2.61820 0.49909
## hosp.stay 0.43640 17.38159    12.94967 17.81800 1.37594 0.02449
```

* Values of $\delta$ range from 0.01854 to 0.68355 when TRACTs are clusters. When trtBGs are clusters, the $\delta$'s range from 0.02449 to 0.74131. The measures of homogeneity increase substantially when tracts or BGs are clusters compared to the PSU and SSU analyses.
* There is a large increase in $B^2$ when using TRACT and trtBG over PSU and SSU.
* For y3 and ins.cov, B2 +W2 is much larger than the unit relvar ($S_U^2 / y_U^2$), implying that setting k = 1 in Eq. (9.5) may not be very accurate for some variables if clusters vary in size.

5

<!-- page 6 -->

## VDK Example 9.3 Ratio of two totals

* Suppose we estimate proportion of Hispanics with insurance coverage, $\theta$, in MDarea.popA
* Define
  * $y_{2k} = 1$ if person $k$ is Hispanic; and $y_{2k} = 0$ if not Hispanic.
  * $\alpha_{1k} = 1$ if person $k$ has insurance coverage and $\alpha_{1k} = 0$ if not.
  * $y_{1k} = \alpha_{1k}y_{2k} = 1$ if person $k$ has insurance and is Hispanic and $y_{1k} = 0$ otherwise.
  * NOTE: $y1$ and $y2$ in this example are NOT the same as $y1$ and $y2$ in MDarea.popA!!!
  * $\hat{\theta} = \frac{\sum_k y_{1k}}{\sum_k y_{2k}} \rightarrow$ Ratio means; Nonlinear
  * Linear substitute of ratio means under $srs$ both stages is $z_k = y_{1k} - \theta y_{2k}$. (See p. 26 of the lecture notes.)
  * $z_k$ can take only three values: $-\theta$, $0$, and $1 - \theta$ as $z_k = y_{1k} - \theta y_{2k} = \alpha_{1k}y_{2k} - \theta y_{2k} = (\alpha_{1k} - \theta)y_{2k}$ with $\alpha_{1k} = 1, 0$ and $y_{2k} = 1, 0$.
* If a simple random sample of clusters and persons within clusters is selected, `BW2stageSRS` will compute B2, W2, and $\delta$ using the linear substitutes as inputs.

```r
# recode Hispanic to be 1=Hispanic, 0 if not
y2 <- abs(MDarea.popA$Hispanic - 2)
y1 <- y2*MDarea.popA$ins.cov
# proportion of Hispanics with insurance
theta <- sum(y1)/sum(y2)
# linear sub
z <- y1 - theta*y2
table(z)
```

```
## z
## -0.66143977191732                 0  0.33856022808268
##              3800            332174              7424
```

```r
BW2stageSRS(z, psuID=MDarea.popA$TRACT)
```

```
##           B2           W2  unit relvar        B2+W2            k        delta
## 5.574805e+30 6.517176e+33 5.136769e+33 6.522751e+33 1.269816e+00 8.546708e-04
```

```r
BW2stageSRS(z, psuID=MDarea.popA$trtBG)
```

```
##           B2           W2  unit relvar        B2+W2            k        delta
## 2.028148e+31 7.426149e+33 5.136769e+33 7.446430e+33 1.449633e+00 2.723651e-03
```

* Results are $\delta = 0.00085$ for TRACTs and $\delta = 0.00272$ for trtBGs.$\Rightarrow$ effect of clustering on this estimated proportion is inconsequential—a two-stage sample will estimate the proportion almost as precisely as an srs would.

6

<!-- page 7 -->

* In contrast, if estimate is total number of Hispanics with insurance:

```r
BW2stageSRS(y1, psuID=MDarea.popA$TRACT)
```

```
##           B2          W2 unit relvar       B2+W2           k       delta
##   1.20562847 51.38944228 45.25525032 52.59507075  1.16218716  0.02292284
```

```r
BW2stageSRS(y1, psuID=MDarea.popA$trtBG)
```

```
##           B2          W2 unit relvar       B2+W2           k       delta
##   2.40455313 56.20333422 45.25525032 58.60788736  1.29505167  0.04102781
```

* Results are $\delta = 0.02292$ for tracts and $\delta = 0.04103$ for BGs.
  - These are still far less than the $\delta$'s in Example 9.2 which also uses tracts and BGs as clusters.
  - This means that the effect of clustering can be quite different depending on the variable.
  - I.e., Counts of Hispanics with health insurance may differ across TRACTs and trtBGs more than proportions of Hispanics with health insurance.

7

<!-- page 8 -->

## VDK Example 9.4 $ppswr/srs$

* Use MDarea.popA from Example 9.2
* Assume that clusters will be selected proportional to the count of persons in each cluster.
* `BW2stagePPS` computes the population values of B2, W2, and $\delta$ in (9.10)-(9.12), which are appropriate for *ppswr* sampling of clusters.
* Need the 1-draw probabilities $p_i$.
* Variance components using PSU, SSU, TRACT and BG as clusters across y1, y2, y3, ins.cov and hosp.stay
* `BW2stagePPS`

```r
BW2stagePPS(X,
            pp,    # one-draw probabilities of PSU
            psuID,
            lonely.SSU = "mean")
# List objects: B2, W2, unit relvar, B2+W2, k, delta
```

* PSU as clusters:

```r
pp.PSU <- table(MDarea.popA$PSU) / nrow(MDarea.popA)

round(rbind(y1=BW2stagePPS(MDarea.popA$y1, pp=pp.PSU, psuID=MDarea.popA$PSU),
      y2=BW2stagePPS(MDarea.popA$y2, pp=pp.PSU, psuID=MDarea.popA$PSU),
      y3=BW2stagePPS(MDarea.popA$y3, pp=pp.PSU, psuID=MDarea.popA$PSU),
      ins.cov=BW2stagePPS(MDarea.popA$ins.cov, pp=pp.PSU, psuID=MDarea.popA$PSU),
      hosp.stay=BW2stagePPS(MDarea.popA$hosp.stay, pp=pp.PSU, psuID=MDarea.popA$PSU)),
      5)
```

```
##                B2       W2 unit relvar    B2+W2       k   delta
## y1        0.00788  1.45557     1.46312  1.46345 1.00023 0.00538
## y2        0.00695  1.01009     1.01681  1.01704 1.00023 0.00683
## y3        0.00886  0.10474     0.11357  0.11360 1.00021 0.07802
## ins.cov   0.00123  0.26013     0.26130  0.26136 1.00023 0.00469
## hosp.stay 0.01878 12.93386    12.94967 12.95264 1.00023 0.00145
```

* How does this compare to the result from `BW2stageSRS` on page 3?
* SSU as clusters:

```r
pp.SSU <- table(MDarea.popA$SSU) / nrow(MDarea.popA)

round(rbind(y1=BW2stagePPS(MDarea.popA$y1, pp=pp.SSU, psuID=MDarea.popA$SSU),
```

8

<!-- page 9 -->

```r
      y2=BW2stagePPS(MDarea.popA$y2, pp=pp.SSU, psuID=MDarea.popA$SSU),
      y3=BW2stagePPS(MDarea.popA$y3, pp=pp.SSU, psuID=MDarea.popA$SSU),
      ins.cov=BW2stagePPS(MDarea.popA$ins.cov, pp=pp.SSU, psuID=MDarea.popA$SSU),
      hosp.stay=BW2stagePPS(MDarea.popA$hosp.stay, pp=pp.SSU, psuID=MDarea.popA$SSU)),
      5)
```

```
##                 B2       W2 unit relvar    B2+W2       k   delta
## y1         0.03652  1.42825     1.46312  1.46478 1.00113 0.02493
## y2         0.01729  1.00068     1.01681  1.01797 1.00114 0.01698
## y3         0.01840  0.09528     0.11357  0.11369 1.00097 0.16189
## ins.cov    0.00330  0.25829     0.26130  0.26160 1.00115 0.01263
## hosp.stay  0.05909 12.90557    12.94967 12.96466 1.00116 0.00456
```

* How does this compare to the result from `BW2stageSRS` on page 4?

* TRACT as clusters:

```r
pp.TRACT <- table(MDarea.popA$TRACT) / nrow(MDarea.popA)

round(rbind(y1=BW2stagePPS(MDarea.popA$y1, pp=pp.TRACT, psuID=MDarea.popA$TRACT),
      y2=BW2stagePPS(MDarea.popA$y2, pp=pp.TRACT, psuID=MDarea.popA$TRACT),
      y3=BW2stagePPS(MDarea.popA$y3, pp=pp.TRACT, psuID=MDarea.popA$TRACT),
      ins.cov=BW2stagePPS(MDarea.popA$ins.cov, pp=pp.TRACT, psuID=MDarea.popA$TRACT),
      hosp.stay=BW2stagePPS(MDarea.popA$hosp.stay, pp=pp.TRACT, psuID=MDarea.popA$TRACT)),
      5)
```

```
##                 B2       W2 unit relvar    B2+W2       k   delta
## y1         0.00946  1.45406     1.46312  1.46352 1.00027 0.00646
## y2         0.01093  1.00615     1.01681  1.01708 1.00027 0.01075
## y3         0.01363  0.09997     0.11357  0.11360 1.00024 0.11999
## ins.cov    0.00183  0.25954     0.26130  0.26137 1.00027 0.00698
## hosp.stay  0.02402 12.92916    12.94967 12.95318 1.00027 0.00185
```

* How does this compare to the result from `BW2stageSRS` on page 5?

* Last, trtBG as clusters:

```r
pp.trtBG <- table(MDarea.popA$trtBG) / nrow(MDarea.popA)

round(rbind(y1=BW2stagePPS(MDarea.popA$y1, pp=pp.trtBG, psuID=MDarea.popA$trtBG),
      y2=BW2stagePPS(MDarea.popA$y2, pp=pp.trtBG, psuID=MDarea.popA$trtBG),
      y3=BW2stagePPS(MDarea.popA$y3, pp=pp.trtBG, psuID=MDarea.popA$trtBG),
      ins.cov=BW2stagePPS(MDarea.popA$ins.cov, pp=pp.trtBG, psuID=MDarea.popA$trtBG),
      hosp.stay=BW2stagePPS(MDarea.popA$hosp.stay, pp=pp.trtBG, psuID=MDarea.popA$trtBG)),
      5)
```

9

<!-- page 10 -->

```r
##                  B2       W2 unit relvar    B2+W2       k   delta
## y1          0.01643  1.44797     1.46312  1.46441 1.00088 0.01122
## y2          0.01793  0.99977     1.01681  1.01770 1.00088 0.01762
## y3          0.02115  0.09250     0.11357  0.11366 1.00074 0.18611
## ins.cov     0.00393  0.25760     0.26130  0.26153 1.00088 0.01502
## hosp.stay   0.05345 12.90763    12.94967 12.96108 1.00088 0.00412
```

- How does this compare to the result from `BW2stageSRS` on page 5?

- With $ppswr/srs$, if TRACTs or trtBG are used as clusters, $B^2$ is much smaller than $W^2$ leading to smaller $B^2 + W^2$, $k$ and $\delta$, compared to $srs/srs$ design in Example 9.2.
  - We don't observe this when using PSU and SSU as clusters.
- When clusters are selected by $srs$, $S_{U1}^2$ is the variance of the cluster totals around the average cluster total.
- When clusters are selected by $pps$, $S_{U1(pwr)}^2$ is the variance of the estimated population totals ($\dfrac{t_i}{p_i}$) around the population total, $t_U$.
- When clusters are selected with $pp(N_i)$, $\dfrac{t_i}{p_i} = \dfrac{N_i \bar{y}_{Ui}}{N_i / N} = N \bar{y}_{Ui}$.
  - If these 1-cluster estimates of the population total are fairly accurate, $B^2$ can be quite small.
  - This leads to much smaller values of $\delta$ in $pps$ sampling of clusters, implying that the effect of clustering is less important in this population for a design that selects clusters with probabilities proportional to their population counts.
- C.f., with $srs$, selection probabilities: $\dfrac{t_i}{p_i} = \dfrac{M}{m} t_i$; Likely to vary much more than $pps$ $\rightarrow$ Larger $B^2$
- Practitioners habitually gravitate toward $pps$ of clusters over $srs$.
  - Example makes it clear why this choice is often a good one.
  - Accurate $N_i$'s are needed for effective $pps$, but they are not always available.

10
