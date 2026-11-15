---
id: "jpsm/PracTools_SURV745/labs/Class6Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 6"
original: "PracTools_SURV745/labs/Class6Lab.pdf"
pages: 16
sha256: "1a5448899b8ecc14c8e6dcc4baf4ddca6d51c64bdb53db0f78c760f79165f737"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:08"
---

<!-- page 1 -->

# PracTools Class 6

Sunghee Lee

2/23/2026

## VDK Example 9.5 Between and within variance components in *srs/srs/srs* design

* `BW3stagePPS` provides variance components for 3-stage designs.

```r
BW3stagePPS(X,          # data vector
            pp,         # one-draw probabilities of the PSU
            psuID,      # PSU ID vector
            ssuID,      # SSU ID vector
            lonely.SSU, # Handling of singleton SSUs
            lonely.TSU  # Handling of singleton TSUs
)
# List objects: B, W, W2, W3, unit relvar, B2+W2,
#               k1, k2, delta1, delta2
```

* `MDarea.popA`

* Suppose that
  1) PSU and SSU variables define the first and second-stage units;
  2) persons are elements in a three-stage design; and
  3) simple random sampling at all 3 stages.

```r
data(MDarea.popA)

M <- length(unique(MDarea.popA$PSU))
pp.PSU <- rep(1/M,M) # = 1/M

round(rbind(y1=BW3stagePPS(X=MDarea.popA$y1, pp=pp.PSU,
                           psuID=MDarea.popA$PSU, ssuID=MDarea.popA$SSU),
      y2=BW3stagePPS(X=MDarea.popA$y2, pp=pp.PSU, psuID=MDarea.popA$PSU,
                     ssuID=MDarea.popA$SSU),
      y3=BW3stagePPS(X=MDarea.popA$y3, pp=pp.PSU, psuID=MDarea.popA$PSU,
                     ssuID=MDarea.popA$SSU),
```

<!-- page 2 -->

```r
      ins.cov=BW3stagePPS(X=MDarea.popA$ins.cov, pp=pp.PSU,
                          psuID=MDarea.popA$PSU, ssuID=MDarea.popA$SSU),
      hosp.stay=BW3stagePPS(X=MDarea.popA$hosp.stay, pp=pp.PSU,
                            psuID=MDarea.popA$PSU, ssuID=MDarea.popA$SSU)),
      digits=4)
```

```
##                B       W     W2      W3 unit relvar     k1     k2 delta1 delta2
## y1        0.0079  1.4556 0.0358  1.4282   1.4631 1.0002 1.0006 0.0054 0.0245
## y2        0.0069  1.0101 0.0129  1.0007   1.0168 1.0002 0.9968 0.0068 0.0128
## y3        0.0089  0.1047 0.0119  0.0953   0.1136 1.0002 0.9439 0.0780 0.1112
## ins.cov   0.0012  0.2601 0.0026  0.2583   0.2613 1.0002 0.9985 0.0047 0.0100
## hosp.stay 0.0188 12.9338 0.0504 12.9056  12.9497 1.0002 1.0005 0.0014 0.0039
```

* $k_1 = \frac{B^2 + W^2}{\tilde{V}}$, $k_2 = \frac{W_2^2 + W_3^2}{\tilde{V}}$, $\delta_1 = \frac{B^2}{B^2 + W^2}$, $\delta_2 = \frac{W_2^2}{W_2^2 + W_3^2}$

* In case of $srs/srs/srs$ using TRACT as PSU and BG as SSU:

```r
M <- length(unique(MDarea.popA$TRACT))
pp.trt <- rep(1/M,M) # = 1/M

MDarea.popA$trtBG <- 10*MDarea.popA$TRACT + MDarea.popA$BLKGROUP

round(rbind(y1=BW3stagePPS(X=MDarea.popA$y1, pp=pp.trt,
                           psuID=MDarea.popA$TRACT, ssuID=MDarea.popA$trtBG),
      y2=BW3stagePPS(X=MDarea.popA$y2, pp=pp.trt, psuID=MDarea.popA$TRACT,
                     ssuID=MDarea.popA$trtBG),
      y3=BW3stagePPS(X=MDarea.popA$y3, pp=pp.trt, psuID=MDarea.popA$TRACT,
                     ssuID=MDarea.popA$trtBG),
      ins.cov=BW3stagePPS(X=MDarea.popA$ins.cov, pp=pp.trt,
                          psuID=MDarea.popA$TRACT, ssuID=MDarea.popA$trtBG),
      hosp.stay=BW3stagePPS(X=MDarea.popA$hosp.stay, pp=pp.trt,
                            psuID=MDarea.popA$TRACT, ssuID=MDarea.popA$trtBG)),
      digits=4)
```

```
##                B       W     W2      W3 unit relvar     k1     k2 delta1 delta2
## y1        0.2576  1.8406 0.2714  2.1074   1.4631 1.4340 1.6259 0.1228 0.1141
## y2        0.2658  1.2678 0.2628  1.4445   1.0168 1.5083 1.6791 0.1733 0.1539
## y3        0.2679  0.1253 0.2619  0.1322   0.1136 3.4619 3.4699 0.6813 0.6645
## ins.cov   0.2602  0.3261 0.2595  0.3731   0.2613 2.2436 2.4207 0.4438 0.4102
## hosp.stay 0.3061 16.3760 0.3232 18.7241  12.9497 1.2882 1.4709 0.0184 0.0170
```

* Values of $\delta_1$ and $\delta_2$ are much larger when TRACTs and BGs are used for sampling units than when PSU and SSU variables used. This is due to the highly variable sizes of TRACTs and BGs (and probbly the nature of the 5 variables).

2

<!-- page 3 -->

### VDK Example 9.6 Three stages $ppswr/srs/srs$

* $ppswr/srs/srs$ using PSU and SSU variables:

```r
pp.PSU <- table(MDarea.popA$PSU) / nrow(MDarea.popA) # = Q_i/Q

round(rbind(y1=BW3stagePPS(X=MDarea.popA$y1, pp=pp.PSU,
                           psuID=MDarea.popA$PSU, ssuID=MDarea.popA$SSU),
      y2=BW3stagePPS(X=MDarea.popA$y2, pp=pp.PSU, psuID=MDarea.popA$PSU,
                     ssuID=MDarea.popA$SSU),
      y3=BW3stagePPS(X=MDarea.popA$y3, pp=pp.PSU, psuID=MDarea.popA$PSU,
                     ssuID=MDarea.popA$SSU),
      ins.cov=BW3stagePPS(X=MDarea.popA$ins.cov, pp=pp.PSU,
                          psuID=MDarea.popA$PSU, ssuID=MDarea.popA$SSU),
      hosp.stay=BW3stagePPS(X=MDarea.popA$hosp.stay, pp=pp.PSU,
                            psuID=MDarea.popA$PSU, ssuID=MDarea.popA$SSU)),
      digits=4)
```

```r
##                  B       W     W2      W3 unit relvar     k1     k2 delta1 delta2
## y1          0.0079  1.4556 0.0358  1.4282      1.4631 1.0002 1.0006 0.0054 0.0245
## y2          0.0069  1.0101 0.0129  1.0007      1.0168 1.0002 0.9968 0.0068 0.0128
## y3          0.0089  0.1047 0.0119  0.0953      0.1136 1.0002 0.9439 0.0780 0.1112
## ins.cov     0.0012  0.2601 0.0026  0.2583      0.2613 1.0002 0.9985 0.0047 0.0100
## hosp.stay   0.0188 12.9339 0.0504 12.9057     12.9497 1.0002 1.0005 0.0014 0.0039
```

* k1 and k2 are similar. The values of $\delta_1$ and $\delta_2$ are at most 0.0245 with the exception of y3 which has $\delta_1 = 0.0780$ and $\delta_2 = 0.1112$.

* $ppswr/srs/srs$ using TRACT as PSU and BG as SSU:

```r
pp.trt <- table(MDarea.popA$TRACT) / nrow(MDarea.popA) # = N_i/N

round(rbind(y1=BW3stagePPS(X=MDarea.popA$y1, pp=pp.trt,
                           psuID=MDarea.popA$TRACT, ssuID=MDarea.popA$trtBG),
      y2=BW3stagePPS(X=MDarea.popA$y2, pp=pp.trt, psuID=MDarea.popA$TRACT,
                     ssuID=MDarea.popA$trtBG),
      y3=BW3stagePPS(X=MDarea.popA$y3, pp=pp.trt, psuID=MDarea.popA$TRACT,
                     ssuID=MDarea.popA$trtBG),
      ins.cov=BW3stagePPS(X=MDarea.popA$ins.cov, pp=pp.trt,
                          psuID=MDarea.popA$TRACT, ssuID=MDarea.popA$trtBG),
      hosp.stay=BW3stagePPS(X=MDarea.popA$hosp.stay, pp=pp.trt,
                            psuID=MDarea.popA$TRACT, ssuID=MDarea.popA$trtBG)),
      digits=4)
```

3

<!-- page 4 -->

```r
##                B       W     W2      W3 unit relvar     k1     k2 delta1 delta2
## y1        0.0095  1.4541 0.2723  1.6852      1.4631 1.0003 1.3379 0.0065 0.1391
## y2        0.0109  1.0062 0.2593  1.1613      1.0168 1.0003 1.3971 0.0107 0.1825
## y3        0.0136  0.1000 0.2582  0.1071      0.1136 1.0002 3.2165 0.1200 0.7068
## ins.cov   0.0018  0.2595 0.2520  0.3013      0.2613 1.0003 2.1174 0.0070 0.4554
## hosp.stay 0.0240 12.9292 0.3045 14.9689     12.9497 1.0003 1.1794 0.0019 0.0199
```

* k1 is essentially 1, but $\text{k2} > 1$ for all variables. $\delta_2$'s are much larger than when TRACT was used as the first-stage unit and BG as the second-stage unit, ranging from 0.0199 to 0.7068. $\Rightarrow$ Varying unit size can have huge effect on measures of homogeneity.

<!-- page 5 -->

### VDK Example 9.7 Compute two-stage sample sizes

* `clusOpt2` computes $m_{opt}$ and $\bar{n}_{opt}$ that minimize the variance of $\hat{t}_{pwr}$ a two-stage sample.

```r
clusOpt2(C1,   # unit cost per PSU
         C2,   # unit cost per element
         delta,# measure of homogeneity
         unit.rv, # unit relvar
         k=1,  # ratio of (B2+W2)/unit.rv
         CV0=NULL, # target CV
         tot.cost=NULL,  # total budget for variable costs
         cal.sw # 1 for fixed tot.cost, 2 for target CV0
)
# List objects:
## C1: unit cost per PSU
## C2: unit cost per element
## delta, unit relvar, k
## k: ratio of B^2 + W^2 to unit relvariance
## cost: total budget for variable costs, C-C0, if cal.sw=1;
##       or for computed cost if cal.sw=2
## m.opt: optimum number of sample PSUs
## n.opt: optimum number of sample elements per PSU
## CV: computed CV if cal.sw=1; or target CV if cal.sw=2
```

* Compute optimal number of PSUs and elements per PSU assuming that C1 = 750, C2 = 100, $\delta = 0.05$, unit relvariance and k are 1, and the total budget for variable costs is \$100,000.

```r
out2<-clusOpt2(C1=750, C2=100, delta=0.05, unit.rv=1, k=1,
         tot.cost=100000, cal.sw=1)
out2
```

```
##
##
##
##               C1 = 750
##               C2 = 100
##            delta = 0.05
##      unit relvar = 1
##                k = 1
##             cost = 1e+05
##            m.opt = 51.4
##            n.opt = 11.9
##               CV = 0.0502
```

* $m_{opt}$=52; and $\bar{n}_{opt}$=12

5

<!-- page 6 -->

### VDK Example 9.8 Optimal 3-stage sample sizes

* Use `clusOpt3` to compute $m_{opt}$, $\bar{n}_{opt}$ and $\bar{\bar{q}}_{opt}$ that minimize the variance of $\hat{t}_{pwr}$ a three-stage sample.

```r
clusOpt3(unit.cost,   # vector of C1, C2 and C3
         delta1, # measure of homogeneity within PSUs
         delta2, # measure of homogeneity within SSUs
         unit.rv, # unit relvariance
         k1,  # ratio of (B+W)/unit.rv
         k2,  # ratio of (W2+W3)/unit.rv
         CV0, # target CV
         tot.cost,  # total budget for variable costs
         cal.sw # 1 for fixed tot.cost, 2 for target CV0
        )
# List objects
## C1: unit cost per PSU
## C2: unit cost per SSU
## C3: unit cost per element
## delta1, delta2, unit relvar, k1, k2
## cost: total budget for variable costs, C-C0, if cal.sw=1;
##       or for computed cost if cal.sw=2
## m.opt: optimum number of sample PSUs
## n.opt: optimum number of sample SSUs per PSU
## q.opt: optimum number of sample elements per SSU
## CV: computed CV if cal.sw=1; or target CV if cal.sw=2
```

* Suppose that $\text{C1} = 500$, $\text{C2} = 100$, $\text{C3} = 120$, $\delta_1 = 0.01$, $\delta_2 = 0.10$, the unit relvariance is 1, as are k1 and k2, and the total budget for variable costs is \$100,000.
* Find the optimal sample size for all 3 stages.

```r
out3<-clusOpt3(unit.cost=c(500, 100, 120), delta1=0.01,
              delta2=0.10, unit.rv=1, k1=1, k2=1,
              tot.cost=100000, cal.sw=1)
out3
```

```
## 
## 
## 
##              C1 = 500
##              C2 = 100
##              C3 = 120
##          delta1 = 0.01
##          delta2 = 0.1
##     unit relvar = 1
##              k1 = 1
```

6

<!-- page 7 -->

```r
##               k2 = 1
##             cost = 1e+05
##            m.opt = 28.3
##            n.opt = 7.1
##            q.opt = 2.7
##               CV = 0.0499
```

* $m_{opt}$=29; $\bar{n}_{opt}$=8; and $\bar{\bar{q}}_{opt}$=3

7

<!-- page 8 -->

### VDK Example 9.9 Elements per PSU for fixed PSUs, fixed cost

* Determines number of sample elements per PSU for unit costs of C1=500 and C2=100 when number of PSUs is fixed at m=100. Budgets of \$100,000, \$500,000, and 1 million dollars are used.
* Use `clusOpt2fixedPSU` as follows:

```r
clusOpt2fixedPSU(C1=500, C2=100, m=100, delta=0.05,
                 unit.rv=2, k=1, CV0=NULL,
                 tot.cost=c(100000, 500000, 10^6),
                 cal.sw=1)
```

```
##
##
##
##              C1 = 500
##              C2 = 100
##               m = 100
##           delta = 0.05
##     unit relvar = 2
##               k = 1
##            cost = 1e+05, 5e+05, 1e+06
##               n = 5, 45, 95
##              CV = 0.0693, 0.0377, 0.0346
```

* Compare the results under the budgets of \$100,000 and 1 million dollars. What would you suggest?

8

<!-- page 9 -->

### VDK Example 9.11 Variance component <u>estimates</u> in two-stage sampling

* `BW2stagePPSe` estimates variance components using (9.38) and (9.39) for a *ppswr/srswor* design.

```r
BW2stagePPSe(Ni, #number of elements in pop in PSU i
             ni, #number of elements in sample in PSU i
             X, #data vector
             psuID,
             w, #full sample weight
             m, # number of sample PSUs
             pp #1-draw PSU selection probabilities
             )
```

* We will select a two-stage sample from `MDarea.popA` with TRACTs for the first stage and persons for the second stage and then do calculations of variance components for y1.
* `sampling` package is used to systematically select a cluster sample of 20 TRACTs with probabilities proportional to count of persons in each tract (`Ni` in the code).
* This selection of PSUs is without-replacement, but standard practice of applying a with-replacement variance estimator used.
* Function `cluster` returns all units in sample clusters with cluster selection probabilities that will be stored in the field `Prob` in the code.
* `rename`, a function from the `reshape` package, renames `Prob` to be `pi1`.
* Then, sample tracts are treated as strata and an *srswor* of $\bar{n} = 50$ persons is selected from each tract.
* The conditional selection probability of persons within tracts is renamed from `Prob` to `pi2` in the code. $\rightarrow$ Full selection probability: `pi1`*`pi2`

```r
#require(sampling)
#require(reshape)

Ni <- table(MDarea.popA$TRACT)
m <- 20
probi <- m*Ni / sum(Ni)

# select sample of clusters
set.seed(-780087528)
sam <- cluster(data=MDarea.popA, clustername="TRACT",
               size=m, method="systematic",
               pik=probi, description=TRUE)
```

```
## Number of selected clusters: 20
## Number of units in the population and number of selected units: 343398 95427
```

9

<!-- page 10 -->

```r
# extract data for the sample clusters
samclus <- getdata(MDarea.popA, sam)
samclus <- rename(samclus, c(Prob = "pi1"))

# treat sample clusters as strata and select srswor from each
s <- strata(data = as.data.frame(samclus),
            stratanames = "TRACT",
            size = rep(50,m), method="srswor")

# extracts the sample element data from the sample clusters
samdat <- getdata(samclus,s)
samdat <- rename(samdat, c(Prob = "pi2"))

# extract population counts for TRACTs in sample
pick <- names(Ni) %in% sort(unique(samdat$TRACT))
Ni.sam <- Ni[pick]
pp <- Ni.sam / sum(Ni)
wt <- 1/(samdat$pi1*samdat$pi2)
round(rbind(y1=BW2stagePPSe(Ni=Ni.sam, ni=rep(50,20), X=samdat$y1,
             psuID=samdat$TRACT, w=wt, m=20, pp=pp),
            y2=BW2stagePPSe(Ni=Ni.sam, ni=rep(50,20), X=samdat$y2,
             psuID=samdat$TRACT, w=wt, m=20, pp=pp),
            y3=BW2stagePPSe(Ni=Ni.sam, ni=rep(50,20), X=samdat$y3,
             psuID=samdat$TRACT, w=wt, m=20, pp=pp),
            ins.cov=BW2stagePPSe(Ni=Ni.sam, ni=rep(50,20), X=samdat$ins.cov,
             psuID=samdat$TRACT, w=wt, m=20, pp=pp),
            hosp.stay=BW2stagePPSe(Ni=Ni.sam, ni=rep(50,20), X=samdat$hosp.stay,
             psuID=samdat$TRACT, w=wt, m=20, pp=pp)),
      4)
```

```
##                   Vpsu        Vssu       B       W      k   delta
## y1        -3.158939e+11 779660783315 -0.0116  1.4545 0.9998 -0.0081
## y2         1.348934e+09   6624649988  0.0041  1.0149 1.0004  0.0040
## y3         3.939804e+11  87421287209  0.0087  0.0978 1.0042  0.0818
## ins.cov    1.132058e+07     17576560  0.0029  0.2290 1.0009  0.0126
## hosp.stay -3.447129e+05      8189642 -0.0101 12.1827 1.0002 -0.0008
```

* Estimates are not the same as components calculated using the population data in VDK Example 9.2. When using estimated variance components in sample size calculation, do sensitivity analysis.

10

<!-- page 11 -->

### VDK Example 9.13 Anticipated variance components from a model in two-stage $srs/srs$ sampling

* In a clustered population, simplest model to consider is:
  $y_k = \mu + \alpha_i + \epsilon_{ik}$ (9.42)
  with $k \in U_i$, $\alpha_i \sim (0, \sigma_\alpha^2)$ and $\epsilon_{ik} \sim (0, \sigma_\epsilon^2)$ and the errors being independent.

* Two model-based options:

  1) Eq (9.43)
  $$
  E_M(\delta) \doteq \frac{(\sigma_\alpha^2 + \mu^2)\nu_N^2 + \sigma_\alpha^2 + \sigma_\epsilon^2 / \bar{N}^2}{(\sigma_\alpha^2 + \mu^2)\nu_N^2 + \sigma_\alpha^2 + \sigma_\epsilon^2(1 + (\nu_N^2 + \bar{N}^{-2}))}
  $$
  with $\nu^2 = S_N^2 / \bar{N}^2$

  2) Eq (9.44)
  $$
  E_M(\delta) \doteq \frac{\sigma_\alpha^2}{\sigma_\alpha^2 + \sigma_\epsilon^2}
  $$

* Package `lme4` will estimate variance components (i.e., $\sigma_\alpha^2$, $\sigma_\epsilon^2$) for a simple model (9.42) and for more elaborate models.

* Using the full Maryland population, the code to fit the model using the PSU and SSU variables as clusters for y1 is as follows:

```r
#require(lme4)
m.y1 <- lmer(y1 ~ (1 | PSU), data = MDarea.popA)
tt <- summary(m.y1)
tt
```

```
## Linear mixed model fit by REML ['lmerMod']
## Formula: y1 ~ (1 | PSU)
##    Data: MDarea.popA
## 
## REML criterion at convergence: 4017895
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -1.6636 -0.6054 -0.2263  0.4091 12.1803 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  PSU      (Intercept)   37.04   6.086  
##  Residual             7057.14  84.007  
## Number of obs: 343398, groups:  PSU, 80
## 
## Fixed effects:
##             Estimate Std. Error t value
```

11

<!-- page 12 -->

```
## (Intercept)  69.6301     0.6953   100.1
```

* From the output, we see `Random effects` with $\sigma_\alpha = 6.086 \quad \sigma_\epsilon = 84.007$
* Variance component estimates can be extracted with `VarCorr` and $\delta$ in Eq (4.44) can be computed as:

```r
vc <- as.data.frame(VarCorr(m.y1))
vc
```

```
##        grp        var1 var2       vcov     sdcor
## 1      PSU (Intercept) <NA>   37.03614  6.085733
## 2 Residual        <NA> <NA> 7057.14312 84.006804
```

```r
delta <- vc[1,4] / sum(vc[,4])
delta
```

```
## [1] 0.005220638
```

* $delta = \frac{\sigma_\alpha^2}{\sigma_\alpha^2 + \sigma_\epsilon^2}$
* $0.0052206$ is $E_M(\delta)$ from the model correlation.
* We repeat this for all outcome variables and both PSU vs TRACT as clusters and combine the results into an R object `moh` below.

```r
moh <- matrix(0, ncol=6, nrow=5)
dimnames(moh)[[1]] <- c("y1","y2","y3","ins.cov","hosp.stay")
dimnames(moh)[[2]] <- c("s2a_PSU", "s2e_PSU", "delta_PSU",
                        "s2a_TR", "s2e_TR", "delta_TR")

# PSUs as clusters
m.y1 <- lmer(y1 ~ (1 | PSU), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.y1))
moh[1,1:2] <- vc[,4]
moh[1,3] <- vc[1,4] / sum(vc[,4])   # intracluster correlation

m.y2 <- lmer(y2 ~ (1 | PSU), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.y2))
moh[2,1:2] <- vc[,4]
moh[2,3] <- vc[1,4] / sum(vc[,4])

m.y3 <- lmer(y3 ~ (1 | PSU), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.y3))
moh[3,1:2] <- vc[,4]
moh[3,3] <- vc[1,4] / sum(vc[,4])
```

12

<!-- page 13 -->

```r
m.inscov <- lmer(ins.cov ~ (1 | PSU), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.inscov))
moh[4,1:2] <- vc[,4]
moh[4,3] <- vc[1,4] / sum(vc[,4])

m.hospstay <- lmer(hosp.stay ~ (1 | PSU), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.hospstay))
moh[5,1:2] <- vc[,4]
moh[5,3] <- vc[1,4] / sum(vc[,4])

# TRACTs as clusters
m.y1 <- lmer(y1 ~ (1 | TRACT), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.y1))
moh[1,4:5] <- vc[,4]
moh[1,6] <- vc[1,4] / sum(vc[,4])

m.y2 <- lmer(y2 ~ (1 | TRACT), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.y2))
moh[2,4:5] <- vc[,4]
moh[2,6] <- vc[1,4] / sum(vc[,4])

m.y3 <- lmer(y3 ~ (1 | TRACT), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.y3))
moh[3,4:5] <- vc[,4]
moh[3,6] <- vc[1,4] / sum(vc[,4])

m.inscov <- lmer(ins.cov ~ (1|TRACT), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.inscov))
moh[4,4:5] <- vc[,4]
moh[4,6] <- vc[1,4] / sum(vc[,4])

m.hospstay <- lmer(hosp.stay ~ (1 | TRACT), data = MDarea.popA)
vc <- as.data.frame(VarCorr(m.hospstay))
moh[5,4:5] <- vc[,4]
moh[5,6] <- vc[1,4] / sum(vc[,4])

round(moh,4)
```

```
##           s2a_PSU   s2e_PSU delta_PSU   s2a_TR   s2e_TR delta_TR
## y1        37.0361 7057.1431    0.0052  60.1631 7049.8791   0.0085
## y2         0.3978   59.0987    0.0067   0.7824   58.8681   0.0131
## y3        68.5215  801.7883    0.0787 133.3506  765.3123   0.1484
## ins.cov    0.0007    0.1635    0.0045   0.0012    0.1631   0.0076
## hosp.stay  0.0001    0.0665    0.0012   0.0001    0.0664   0.0017
```

<!-- page 14 -->

* Evaluate $\delta$'s using VDK Eq (9.43) in srs/srs sampling.

```r
delta <- matrix(0, ncol=2, nrow=5)
dimnames(delta)[[1]] <- c("y1","y2","y3","ins.cov","hosp.stay")
dimnames(delta)[[2]] <- c("delta_PSU", "delta_TR")

# PSUs as clusters
N <- table(MDarea.popA$PSU)
Nbar.PSU <- mean(N)
Nbar <- Nbar.PSU
v2N <- var(N)/Nbar^2

mu <- mean(MDarea.popA$y1)
B <- (moh[1,1] + mu^2)*v2N + moh[1,1] + moh[1,2]/Nbar^2
      #numerator of Eq (9.43)
BW <- (moh[1,1] + mu^2)*v2N + moh[1,1] + moh[1,2]*(1 + v2N + 1/Nbar^2)
      #denominator of Eq (9.43)
delta[1,1] <- B / BW

mu <- mean(MDarea.popA$y2)
B <- (moh[2,1] + mu^2)*v2N + moh[2,1] + moh[2,2]/Nbar^2
BW <- (moh[2,1] + mu^2)*v2N + moh[2,1] + moh[2,2]*(1 + v2N + 1/Nbar^2)
delta[2,1] <- B / BW

mu <- mean(MDarea.popA$y3)
B <- (moh[3,1] + mu^2)*v2N + moh[3,1] + moh[3,2]/Nbar^2
BW <- (moh[3,1] + mu^2)*v2N + moh[3,1] + moh[3,2]*(1 + v2N + 1/Nbar^2)
delta[3,1] <- B / BW

mu <- mean(MDarea.popA$ins.cov)
B <- (moh[4,1] + mu^2)*v2N + moh[4,1] + moh[4,2]/Nbar^2
BW <- (moh[4,1] + mu^2)*v2N + moh[4,1] + moh[4,2]*(1 + v2N + 1/Nbar^2)
delta[4,1] <- B / BW

mu <- mean(MDarea.popA$hosp.stay)
B <- (moh[5,1] + mu^2)*v2N + moh[5,1] + moh[5,2]/Nbar^2
BW <- (moh[5,1] + mu^2)*v2N + moh[5,1] + moh[5,2]*(1 + v2N + 1/Nbar^2)
delta[5,1] <- B / BW

# TRACTs as clusters
N <- table(MDarea.popA$TRACT)
Nbar.trt <- mean(N)
v2N <- var(N)/Nbar.trt^2

mu <- mean(MDarea.popA$y1)
```

14

<!-- page 15 -->

```r
B <- (moh[1,4] + mu^2)*v2N + moh[1,4] + moh[1,5]/Nbar.trt^2
BW <- (moh[1,4] + mu^2)*v2N + moh[1,4] + moh[1,5]*(1 + v2N + 1/Nbar.trt^2)
delta[1,2] <- B / BW

mu <- mean(MDarea.popA$y2)
B <- (moh[2,4] + mu^2)*v2N + moh[2,4] + moh[2,5]/Nbar.trt^2
BW <- (moh[2,4] + mu^2)*v2N + moh[2,4] + moh[2,5]*(1 + v2N + 1/Nbar.trt^2)
delta[2,2] <- B / BW

mu <- mean(MDarea.popA$y3)
B <- (moh[3,4] + mu^2)*v2N + moh[3,4] + moh[3,5]/Nbar.trt^2
BW <- (moh[3,4] + mu^2)*v2N + moh[3,4] + moh[3,5]*(1 + v2N + 1/Nbar.trt^2)
delta[3,2] <- B / BW

mu <- mean(MDarea.popA$ins.cov)
B <- (moh[4,4] + mu^2)*v2N + moh[4,4] + moh[4,5]/Nbar.trt^2
BW <- (moh[4,4] + mu^2)*v2N + moh[4,4] + moh[4,5]*(1 + v2N + 1/Nbar.trt^2)
delta[4,2] <- B / BW

mu <- mean(MDarea.popA$hosp.stay)
B <- (moh[5,4] + mu^2)*v2N + moh[5,4] + moh[5,5]/Nbar.trt^2
BW <- (moh[5,4] + mu^2)*v2N + moh[5,4] + moh[5,5]*(1 + v2N + 1/Nbar.trt^2)
delta[5,2] <- B / BW

#Based on Eq (9.43)
round(delta, 4)
```

```
##           delta_PSU delta_TR
## y1           0.0052   0.1307
## y2           0.0067   0.1792
## y3           0.0787   0.6911
## ins.cov      0.0045   0.4451
## hosp.stay    0.0012   0.0173
```

```r
#Based on Eq (9.44)
round(moh[,c(3,6)],4)
```

```
##           delta_PSU delta_TR
## y1           0.0052   0.0085
## y2           0.0067   0.0131
## y3           0.0787   0.1484
## ins.cov      0.0045   0.0076
## hosp.stay    0.0012   0.0017
```

- $\delta$'s are similar for PSUs as clusters but not for TRACTs as clusters between VDK Eq.

15

<!-- page 16 -->

(9.43) and (9.44). Why?
* As seen in VDK Eq. (9.44), the formula for $B^2/(B^2 + W^2)$ will estimate the same thing as the model-based calculation, if the clusters have the same size ($N_i = \bar{N}$), but not otherwise.
* Thus, the big differences we see between results from VDK Eq. (9.43) and (9.44). The results from Example 9.2 and from VDK Eq. (9.43) are similar. This is due to the highly varying sizes (i.e., population counts) of TRACTs (i.e., $N_i$) in `MDarea.popA`.

* Try the model-based approach with the sample data generated in Example 9.11.

16
