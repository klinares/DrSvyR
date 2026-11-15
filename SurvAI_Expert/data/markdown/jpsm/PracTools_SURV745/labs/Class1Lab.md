---
id: "jpsm/PracTools_SURV745/labs/Class1Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 1"
original: "PracTools_SURV745/labs/Class1Lab.pdf"
pages: 6
sha256: "28d798a29832eca9fd4275a4d6b97036282dada8d931cbcf9d976bb77b4dfe37"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:08"
---

<!-- page 1 -->

# PracTools Class 1

Sunghee Lee

1/12/2026

```r
library(PracTools)
```

### VDK Example 3.1. Sample size for a target CV

* Suppose that we estimate from a previous survey that the population CV of some variable is 2.0.
* Sample size for the target CV (CV0) is set to 0.05 for 1) an extremely large population and 2) $N = 500$

* R function, `nCont`, will compute a sample size using either $CV_0$ or $V_0$ as input for continuous variables. Parameters used by the function are:

```r
nCont(CV0=NULL, V0=NULL, S2=NULL,
      ybarU=NULL, N=Inf, CVpop=NULL)
```

* Sample size for $N = \infty$

```r
nCont(CV0=0.05, CVpop=2)
```

```
## [1] 1600
```

* Sample size for $N = 500$

```r
nCont(CV0=0.05, CVpop=2, N=500)
```

```
## [1] 380.9524
```

1

<!-- page 2 -->

### VDK Example 3.4. Sample size for rare characteristics

* Consider the case of a rare characteristic in the population with $p_U = 0.01$.
* If we require $CV_0 = 0.05$, this means that the standard error of the proportion would be $0.0005 (= 0.01 \times 0.05)$. (Note $SE(\hat{\theta}) = CV_0 \times \hat{\theta}$)

* Corresponding sample size

```r
nProp(V0=0.0005^2, N=Inf, pU=0.01)
```

```
## [1] 39600
```

```r
nProp(CV0=0.05, N=Inf, pU=0.01)
```

```
## [1] 39600
```

* What if $N = 300$? Need to consider the effect of fpc.

```r
nProp(CV0=0.05, N=300, pU=0.01)
```

```
## [1] 297.7518
```

* It may be substantively interesting if we were able to estimate the proportion $\pm 1/2$ of 1%, because this would confirm any suspicion about the proportion being small. This means that a 95% CI should have a half-width of $0.005$ or $1.96 \sqrt{\frac{p_U(1 - p_U)}{n}} = 0.005$, because
  * $CI(\hat{\theta}) = \hat{\theta} \pm SE(\hat{\theta}) \times z$
  * $HalfWidth = SE(\hat{\theta}) \times z$
  * $V(\hat{\theta}) = (\frac{HalfWidth}{z})^2$

```r
nProp(V0=(0.005/1.96)^2,pU=0.01)
```

```
## [1] 1521.274
```

2

<!-- page 3 -->

### VDK Example 3.6. Sample size based on MOE

* Suppose that we want to estimate a proportion for a characteristic where $p_U = 0.5$ with a MOE of $e$ when $\alpha = 0.05$. In other words, the sample should be large enough that a normal approximation $95\%$ confidence interval should be $0.50 \pm e$.
* The sample size is highly dependent on the width of the confidence interval as seen in the following table. Sample sizes were evaluated using the formula given in Eq. (3.14) with $p_U = 0.5$ and $z_{0.975} = 1.96$.

* Sample sizes are computed for a range of $e$ ($0.01$ to $0.08$ by an increment of $0.01$):

```r
cbind(seq(0.01,0.08,0.01),
      nPropMoe(moe.sw=1, e=seq(0.01,0.08,0.01), alpha=0.05, pU=0.5))
```

```
##      [,1]      [,2]
## [1,] 0.01 9603.6471
## [2,] 0.02 2400.9118
## [3,] 0.03 1067.0719
## [4,] 0.04  600.2279
## [5,] 0.05  384.1459
## [6,] 0.06  266.7680
## [7,] 0.07  195.9928
## [8,] 0.08  150.0570
```

* `moe.sw=1` $\rightarrow$ set MOE equal to CI half-width; to implement (3.10) and (3.12)

* `moe.sw=2` $\rightarrow$ set MOE equal to CI half-width divided by $p_U$ (i.e., MOE relative to the population mean); to implement (3.11) and (3.13)

3

<!-- page 4 -->

### VDK Example 3.9. Neyman and cost allocation

* `strAlloc`: Computes proportional, Neyman, cost-constrained, and variance-constrained allocations in a stratified simple random sample

```r
strAlloc(n.tot = NULL,
         Nh = NULL,
         Sh = NULL,
         cost = NULL,
         ch = NULL,
         V0 = NULL,
         CV0 = NULL,
         ybarU = NULL,
         alloc=c("prop", "neyman", "totcost", "totvar"))
```

| | |
| :--- | :--- |
| `n.tot` | fixed total sample size |
| `Nh` | vector of pop stratum sizes ($N_h$) or pop stratum proportions ($W_h$), required |
| `Sh` | stratum unit standard deviations ($S_{Uh}$), required unless `alloc = "prop"` |
| `cost` | total variable cost ($C - c_0$) |
| `ch` | vector of cost per unit in stratum $h$ ($c_h$) |
| `V0` | fixed variance target for estimated mean |
| `CV0` | fixed $CV$ target for estimated mean |
| `ybarU` | pop mean of y ($\bar{y}_U$) |
| `alloc` | type of allocation, must be one of `"prop"`, `"neyman"`, `"totcost"`, `"totvar"` |

* Interested in total expenditure during a calendar year for individual mental health organization (mho).
* Given the nature of mho's, it makes sense to stratify mho's in the design. For this, we treat the 1998 Survey of Mental Health Organizations (SMHO) (dataset name `smho98`) as a population data source.

* From SMHO, stratum definition, stratum population counts, standard deviations of total expenditures and unit-level costs are as follows.

| Stratum $h$ | Org type | $N_h$ | $S_h$ | Cost $c_h$ |
| ---: | :--- | ---: | ---: | ---: |
| 1 | Psychiatric hospital | 215 | 26787207 | 1400 |
| 2 | Residential | 65 | 10645109 | 200 |
| 3 | General hospital | 252 | 6909676 | 300 |
| 4 | Military veterans | 50 | 11085034 | 600 |
| 5 | Partial/Outpatient | 149 | 9817762 | 450 |
| 6 | Multiservice/Substance | 144 | 44553355 | 1000 |

4

<!-- page 5 -->

1. Find Neyman allocation to minimize variance of mean for a sample size of $n = 100$.

```r
n=100
Nh=c(215, 65, 252, 50, 149, 144)
Sh=c(26787207, 10645109, 6909676, 11085034, 9817762, 44553355)
ney=strAlloc(n.tot=100, Nh=Nh, Sh=Sh, alloc="neyman")
ney$allocation
```

```
## [1] "neyman"
```

```r
ney$nh
```

```
## [1] 34.641683  4.161947 10.473487  3.333804  8.798970 38.590108
```

* How would you present this result to your clients?

```r
ney$'nh/n'
```

```
## [1] 0.34641683 0.04161947 0.10473487 0.03333804 0.08798970 0.38590108
```

* What does this tell you?

2. Find allocation to minimize variance of mean for a total budget of \$100,000 after the fixed costs (i.e., $(C - c_0)$).

```r
budget=100000
ch=c(1400, 200, 300, 600, 450, 1000)
cost=strAlloc(Nh=Nh, Sh=Sh, cost=budget, ch=ch, alloc="totcost")
cost$allocation
```

```
## [1] "totcost"
```

```r
cost$nh; sum(cost$nh)
```

```
## [1] 30.605403  9.728474 19.989127  4.499121 13.711619 40.340301
```

```
## [1] 118.874
```

```r
cost$'nh/n'
```

```
## [1] 0.2574608 0.0818385 0.1681538 0.0378478 0.1153458 0.3393533
```

5

<!-- page 6 -->

3. Comparison of Neyman and cost allocations

```r
round(cbind(ney$'nh/n',cost$'nh/n'),2)
```

```
##      [,1] [,2]
## [1,] 0.35 0.26
## [2,] 0.04 0.08
## [3,] 0.10 0.17
## [4,] 0.03 0.04
## [5,] 0.09 0.12
## [6,] 0.39 0.34
```

* For $h = 1$: Why a larger share under Neyman allocation and a smaller share under cost allocation?
* For $h = 1$ and $h = 3$, similar $N_h$s but very different allocations. Why?

4. Why are Neyman allocations for strata 1 and 6 similar despite larger $S_h$ for $h = 6$?

6
