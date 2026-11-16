---
id: "jpsm/PracTools_SURV745/labs/Class3Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 3"
original: "PracTools_SURV745/labs/Class3Lab.pdf"
pages: 16
sha256: "5e4b7d1dbfb4cde7bbd5af1d33d6346a6af43d2afde94ff28de0a575e26d283d"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:13"
---

<!-- page 1 -->

# PracTools Class 3

Sunghee Lee

2/2/2026

## VDK Example 4.1 Power for a previous survey

* Plan is to select a sample of households ($n = 1000$) from a Canadian province and measure mean household income for married-couple households, $\hat{\bar{y}}$.

* Based on earlier surveys of the same design and size ($n = 1000$), you anticipate that the mean is about $\$55,000$ CAD and will be estimated with a $6\%$ CV.
  $\Rightarrow$ anticipated $SE(\hat{\bar{y}}) = \sqrt{V(\hat{\bar{y}})} = 0.06 \times 55000 = 3300$, because $CV(\hat{\bar{y}}) = \frac{SE(\hat{\bar{y}})}{\hat{\bar{y}}}$.

* Hypothesis to test: $H_0 : \mu = \$55,000$ vs $H_A : \mu > \$55,000$ at $\alpha = 0.05$ level.

* We would like to know the power we have to be able to detect $\mu + \delta = 60,000$. Substituting in VDK Eq. (4.4) and using the normal approximation, the anticipated power is
  $$Pr\left(Z > z_{1-\alpha} - \frac{\delta}{\sqrt{v(\hat{\bar{y}})}}\right)$$
  $$= Pr\left(Z > 1.645 - \frac{60000 - 55000}{3300}\right)$$
  $= 1 - pnorm(1.645 - \frac{60000 - 55000}{3300}) = 0.448$, which is pretty small.

* (Note: `pnorm()` is a function in R `stats` package for cumulative normal distribution probabilities.)

* Assume that a survey was actually conducted to test this hypothesis. From that survey, we learn $\hat{\bar{y}} = 59000$ with a $7.5\%$ CV.
  $\Rightarrow$ anticipated $SE(\hat{\bar{y}}) = \sqrt{V(\hat{\bar{y}})} = 0.075 \times 59000 = 4425$.

* t-statistic for testing $H_0 : \mu = \$55,000$: $t_{obs} = \frac{59000 - 55000}{4425} = 0.9040$
  * Corresponding p-value: $Pr(t > 0.9040 | \mu = 55000) = 1 - pnorm(0.9040) = 0.183$.
  * Consequently, whether $H_A : \mu > \$55,000$ seems doubtful.

1

<!-- page 2 -->

- A check on this conclusion is to calculate a confidence interval for $\mu$. In this case, a one-sided 95% interval is $\hat{\bar{y}} - z_{1-\alpha} \times SE(\hat{\bar{y}}) = 59000 - 1.645 \times 4425 = 51721$, which is less than the hypothesized $\$55,000$ (from $H_A: \mu > \$55,000$). Therefore, $H_A$ does not hold. We do not reject $H_0$.

2

<!-- page 3 -->

### VDK Example 4.4 Continuation of Example 4.1

* You can do power analysis for t-tests using `power.t.test` in R `stats` package. (Other options exists, e.g., `pwr` package – expressed with effect sizes).

```r
power.t.test(n = NULL, delta = NULL, sd = 1,
             sig.level = 0.05, power = NULL,
             type = c("two.sample", "one.sample", "paired"),
             alternative = c("two.sided", "one.sided"),
             strict = FALSE)
```

* `power.t.test` can be used for one and two sample tests.
* Use the set-up in Example 4.1 as follows. Power to detect $\mu + \delta = 60000$.

```r
# because SE=sd/sqrt(n)
sd<-3300*sqrt(1000)
power.t.test(n = 1000, delta = 60000-55000,
             sd = sd,
             type = c("one.sample"),
             alternative = c("one.sided"))
```

```
## 
##      One-sample t test power calculation 
## 
##               n = 1000
##           delta = 5000
##              sd = 104355.2
##       sig.level = 0.05
##           power = 0.4479952
##     alternative = one.sided
```

* This corresponds to results from Example 4.1.

* What if $n = 2000$? What do we do for sd?

```r
power.t.test(n = 2000, delta = 60000-55000,
             #no change to sd. Why?
             sd = sd,
             type = c("one.sample"),
             alternative = c("one.sided"))
```

```
## 
##      One-sample t test power calculation 
## 
##               n = 2000
##           delta = 5000
```

3

<!-- page 4 -->

```r
##              sd = 104355.2
##       sig.level = 0.05
##           power = 0.6904651
##     alternative = one.sided
```

* What do you observe in the power between $n = 1000$ and $n = 2000$?

4

<!-- page 5 -->

### VDK Example 4.7 Two-sample test on means with partially overlapping samples

* A study on the effect of yoga in weight management.
* Sample women of a large company who participate in a weekly yoga program. The women will be weighed at the beginning and the end of the year. The correlation between weights at the beginning and end of the year is expected to be 0.9.
* 25% in initial sample will drop out by the end of the year. Suppose their weights cannot be measured at that time. Additional women would be sampled at the end of the year to make up for the ones who dropped out, but weights of these women are not available from the beginning of the year.
* $n_1 = n_2$, $r = 1$, $\gamma = 0.75$, $\rho = 0.9$ applicable for

$$n_1 = \frac{1}{\delta^2} \left[\sigma_x^2 + r\sigma_y^2 - 2\gamma r \rho \sigma_x \sigma_y\right] (z_{1-\alpha} - z_\beta)^2 \qquad (4.13)$$

* Assume that $\sigma^2 = 200$ at both time periods.
* Determine a sample that will allow detecting a 5kg difference in average weight with 80% power.

```r
nDep2sam(S2x=200, S2y=200, g=0.75, r=1, rho=0.9,
         alt="one.sided", del=5, sig.level=0.05, pow=0.80)
```

```
## 
##      Two-sample comparison of means
## Sample size calculation for overlapping samples
## 
##              n1 = 33
##              n2 = 33
##         S2x.S2y = 200, 200
##           delta = 5
##           gamma = 0.75
##               r = 1
##             rho = 0.9
##             alt = one.sided
##       sig.level = 0.05
##           power = 0.8
```

* How should you answer if this is a homework question?

5

<!-- page 6 -->

## VDK Example 4.8 Test on proportions with independent samples

* A standard question on the Defense Manpower Data Center’s surveys of military personnel is:
  * “Taking all things into consideration, how satisfied are you, in general, with each of the following aspects of being in the (branch of service here, e.g., National Guard/Reserve)?”
* Assume we are interested in comparing the proportions of Army and Marine personnel who say that they are “very dissatisfied” or “dissatisfied” with total compensation that includes base pay, allowances, and bonuses with 80% power.

* We were provided with these proportions from a previous survey, where the proportions were .15 and .18 for Army and Marine personnel respectively. Given this, we decide to test $H_0 : P_A \geq P_M$ vs. $H_A : P_A < P_M$?

* For a one-sided test:

```r
#power.prop.test() from stats package

a<-power.prop.test(power = 0.8, p1 = 0.15, p2 = 0.18,
                   alt = "one.sided", sig.level = 0.05)
a
```

```
## 
##      Two-sample comparison of proportions power calculation 
## 
##               n = 1891.846
##              p1 = 0.15
##              p2 = 0.18
##       sig.level = 0.05
##           power = 0.8
##     alternative = one.sided
## 
## NOTE: n is number in *each* group
```

* $n$ from the output above indicates a sample size for each group being tested, hence requiring a total $n = 3784$
* If $n = 1000$ from each service have already been selected and the observed proportions are 0.15 and 0.18, then the power of detecting a 3 percentage point difference is calculated as:

```r
power.prop.test(n = 1000, p1 = 0.15, p2 = 0.18,
                alt = "one.sided",sig.level = 0.05)
```

```
## 
##      Two-sample comparison of proportions power calculation 
```

6

<!-- page 7 -->

```r
## 
##               n = 1000
##              p1 = 0.15
##              p2 = 0.18
##       sig.level = 0.05
##           power = 0.56456
##     alternative = one.sided
## 
## NOTE: n is number in *each* group
```

* How does this power compare to the power above?
  - Power $(1 - \beta)$ for $n = 1891$:
  - Power $(1 - \beta)$ for $n = 1000$:

* What if the hypothesis is: $H_0 : p_A = p_M$ vs. $H_A : p_A \neq p_M$? What is the power?

```r
power.prop.test(n = 1000, p1 = 0.15, p2 = 0.18,
                alt = "two.sided",sig.level = 0.05)
```

```r
## 
##      Two-sample comparison of proportions power calculation 
## 
##               n = 1000
##              p1 = 0.15
##              p2 = 0.18
##       sig.level = 0.05
##           power = 0.4392673
##     alternative = two.sided
## 
## NOTE: n is number in *each* group
```

7

<!-- page 8 -->

### VDK Example 4.10 Difference in proportions with overlapping samples

* Assume that the voter choice toward an election is of interest.

* Suppose that a baseline measurement of proportion of registered voters who plan to vote for the incumbent in the next election which is six months away is to be made. A follow-up sample of voters is asked three months later for whom they plan to vote.

* Advance estimates of the proportions of voters who will vote for the incumbent are $p_x = 0.5$ at the baseline and $p_y = 0.55$ for the follow-up. The proportion who favor the incumbent say at both times is estimated as $p_{xy} = 0.45$.

* You anticipate selecting the same size sample at each time period but that only half of the baseline sample will respond to the follow-up. $\Rightarrow r = 1$ and $\gamma = 0.5$

* How would you construct the hypothesis?

* For a two-sided, $\alpha = 0.05$-level test for detecting $\delta = 0.05$ with 80% power is:

```r
nProp2sam(px=0.5, py=0.55, pxy=0.45, g=0.5,
          r=1, alt="two.sided")
```

```r
## 
##      Two-sample comparison of proportions
##  Sample size calculation for overlapping samples
## 
##              n1 = 1013
##              n2 = 1013
##       px.py.pxy = 0.50, 0.55, 0.45
##           gamma = 0.5
##               r = 1
##             alt = two.sided
##       sig.level = 0.05
##           power = 0.8
```

8

<!-- page 9 -->

### Example. Simulation 1 - Two Sample t-test Power

* Need **paramtest** package for the work in this and next example.
* We know we can use `t.test` for t-tests of means. We are building simulations around this to see how this works against the existing package.
* Pay attention to Steps 1-5 noted below.
* First, set up a function that allows varying inputs to `t.test` parameters and retaining what we need for power analysis: t statistics, p-value and significance.

```r
t_fun<-function(simN,sampsize,delta){

# Step 1. Generate data
  # Sample 1
  x1<-rnorm(sampsize,3,2)   # You can change this based on some previous data
                            # or consultation with subject matter researchers
  # Sample 2
  x2<-rnorm(sampsize,3+delta,2)

# Step 2. Hypothesis test
  t<-t.test(x1,x2,var.equal=T) # You can change "var.equal" value based
                               # on how you specify x1 and x2

# Step 3. Gathering information related to p-value
  tstat<-t$statistic # actual t statistic
  p<-t$p.value       # actual p-value
  sig<-p<0.05        # 1/0 values
  return(c(t=tstat,p=p,sig=sig))
}
```

* Simulation 5 times for the case when the sample size is 50 and the difference in the two group means is 0.2; save the simulation outcome as an object and check the object.

```r
# Step 4. Repeat Steps 1 - 3 n.iter times
set.seed(971)
t_power_one<-run_test(t_fun, n.iter=5, output='data.frame',
                      sampsize=50, delta=0.2)
```

```
## Running 5 tests...
```

```r
t_power_one
```

```
## $results
##   iter        t.t        p sig
## 1    1  0.34886046 0.7279425   0
```

<!-- page 10 -->

```
## 2    2  0.09044827 0.9281156   0
## 3    3 -1.17779200 0.2417318   0
## 4    4 -0.18574242 0.8530307   0
## 5    5  1.01202564 0.3140180   0
## 
## $tests
## NULL
## 
## $n.iter
## [1] 5
## 
## $timing
##    user  system elapsed 
##    0.01    0.00    0.00 
## 
## attr(,"class")
## [1] "paramtest"
```

```r
attributes(t_power_one)
```

```
## $names
## [1] "results" "tests"   "n.iter"  "timing" 
## 
## $class
## [1] "paramtest"
```

* Increase the simulation size to 10,000 and calculate the power

```r
set.seed(23)
t_power_one<-run_test(t_fun, n.iter=10000, output='data.frame', 
                      sampsize=50, d=0.2)
```

```
## Running 10,000 tests...
```

```r
# Step 5. Power=Proportion of p-value < alpha 
#         (i.e., recorded as significant) out of the repeats
results(t_power_one)%>%
  summarize(power=mean(sig))
```

```
##    power
## 1 0.0753
```

* How would you evaluate this power?

* Compare the simulation-based power with power from `power.t.test`

10

<!-- page 11 -->

```r
power.t.test(n = 50, delta = 0.2, sd =2,
             sig.level = 0.05,
             type = c("two.sample"),
             alternative = c("two.sided"))
```

```
## 
##      Two-sample t test power calculation 
## 
##               n = 50
##           delta = 0.2
##              sd = 2
##       sig.level = 0.05
##           power = 0.07148172
##     alternative = two.sided
## 
## NOTE: n is number in *each* group
```

* Comparison of the simulation-based power with power from `power.t.test`.
  * `power.t.test` power:
  * Simulation-based power:

* What is the benefit of doing simulation?

* What if you want to try various sample sizes and various $\delta$? Try `grid_search` in `paramtest`. One example of varying $n$'s and $\delta$'s:

```r
set.seed(176)
t_power<-grid_search(t_fun,
                     params=list(sampsize=c(50, 100, 200),
                                 delta=seq(0.1, 0.5, 0.1)),
                     n.iter=1000,output='data.frame')
```

```
## Running 15,000 tests...
```

```r
#t_power  Check the object created above on your own
results(t_power)%>%
  group_by(sampsize.test, delta.test)%>%
  summarize(power=mean(sig))
```

```
## # A tibble: 15 x 3
## # Groups:   sampsize.test [3]
##    sampsize.test delta.test power
##            <dbl>      <dbl> <dbl>
##  1            50        0.1 0.064
##  2            50        0.2 0.083
```

<!-- page 12 -->

```r
##  3            50        0.3 0.124
##  4            50        0.4 0.159
##  5            50        0.5 0.253
##  6           100        0.1 0.057
##  7           100        0.2 0.101
##  8           100        0.3 0.159
##  9           100        0.4 0.283
## 10           100        0.5 0.413
## 11           200        0.1 0.081
## 12           200        0.2 0.149
## 13           200        0.3 0.348
## 14           200        0.4 0.524
## 15           200        0.5 0.729
```

* What do you observe from the summary above?

* Remember $n$ is for each group.

12

<!-- page 13 -->

### Example. Simulation 2 - Multiple Regression Power

* Assume we are interested in the power of detecting the significance of model coefficients in a linear regression model as follows:
  $y = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \epsilon$
  (Note. Some may be interested in model's $R^2$ and the associated power. This can be answered by `pwr` package.)
* You need to know the underlying distribution of $x_1$ and $x_2$ and their relationships to $y$ (i.e., $\beta_0$, $\beta_1$ and $\beta_2$) to be able to generate the data.
* Build the function to use in the simulation around `lm`
* Recall elements in `lm` output – we gather information related to p-values from there

```r
reg_one<-function(simN, sampsize, beta0, beta1, beta2,
                  x1m, x1sd, x2m, x2sd, esd)
  {

#Step 1. Generate data
  x1<-rnorm(sampsize,x1m,x1sd)
  x2<-rnorm(sampsize,x2m,x2sd)
  error<-rnorm(sampsize,0,esd)

  # Generating y based on x1, x2 and error
  y<-beta0+beta1*x1+beta2*x2+error

#Step 2. Estimate the model
  model<-lm(y~x1+x2)
  m<-summary(model)

#Step 3. Check the p-values of the parameters of interest
  b0<-coef(m)['(Intercept)','Estimate']
  p_b0<-coef(m)['(Intercept)','Pr(>|t|)']
  sig_b0<-p_b0<0.05  # 1/0 value
  b1<-coef(m)['x1','Estimate']
  p_b1<-coef(m)['x1','Pr(>|t|)']
  sig_b1<-p_b1<0.05  # 1/0 value
  b2<-coef(m)['x2','Estimate']
  p_b2<-coef(m)['x2','Pr(>|t|)']
  sig_b2<-p_b2<0.05  # 1/0 value
  return(c(b0=b0, p_b0=p_b0, sig_b0=sig_b0,
           b1=b1, p_b1=p_b1, sig_b1=sig_b1,
           b2=b2, p_b2=p_b2, sig_b2=sig_b2))
}
```

13

<!-- page 14 -->

```r
#Step 4. Repeat Steps 1-3 n.iter times
set.seed(638)
reg_power_one<-run_test(reg_one, n.iter=5, output='data.frame',
                        sampsize=50,
                        beta0=0, beta1=.15, beta2=.15,
                        x1m=0, x1sd=10, x2m=0, x2sd=0.1,
                        esd=5)
```

```
## Running 5 tests...
```

```r
reg_power_one
```

```
## $results
##   iter          b0     p_b0 sig_b0         b1     p_b1 sig_b1        b2
## 1    1  0.94670763 0.2246150      0 0.06589058 0.44158290      0 -1.103748
## 2    2  0.01540676 0.9841888      0 0.26112044 0.00158721      1 -8.860003
## 3    3  0.44053284 0.5492763      0 0.14099578 0.05510702      0 10.362265
## 4    4 -0.10127928 0.8990744      0 0.09013091 0.21515510      0 -2.234258
## 5    5  0.34184200 0.6614283      0 0.16049154 0.06944984      0 -6.218426
##       p_b2 sig_b2
## 1 0.8974941      0
## 2 0.2639914      0
## 3 0.1648602      0
## 4 0.7575240      0
## 5 0.4764195      0
## 
## $tests
## NULL
## 
## $n.iter
## [1] 5
## 
## $timing
##    user  system elapsed 
##    0.01    0.00    0.02 
## 
## attr(,"class")
## [1] "paramtest"
```

```r
set.seed(638)
reg_power_one<-run_test(reg_one, n.iter=10000, output='data.frame',
                        sampsize=50,
                        beta0=0, beta1=.15, beta2=.15,
                        x1m=0, x1sd=10, x2m=0, x2sd=0.1,
                        esd=5)
```

<!-- page 15 -->

```
## Running 10,000 tests...
```

```r
# Step 5. Power=Proportion of p-value < alpha out of the repeats
results(reg_power_one)%>%
    summarize(power_b0=mean(sig_b0),
              power_b1=mean(sig_b1),
              power_b2=mean(sig_b2))
```

```
##   power_b0 power_b1 power_b2
## 1   0.0508   0.5175   0.0489
```

* Why is the power of $\beta_1$ and $\beta_2$ so different despite their estimates being assumed the same at 0.15 and $\bar{x}_1 = \bar{x}_2 = 0$?

* If to using various sample sizes, $\beta_2$ and $\sigma_{x1}$:

```r
set.seed(81)
reg_power <-grid_search(
  reg_one,
  params=list(sampsize=c(50, 100),    # 2 sample sizes
              beta2=c(.1, .15, .20),  # 3 beta2 values
              x1sd=c(1, 10)),         # 2 x1sd values
  n.iter=1000, output='data.frame',
  beta0=0, beta1=.15,
  x1m=0, x2m=0, x2sd=0.1, esd=5)
```

```
## Running 12,000 tests...
```

```r
results(reg_power)%>%
  group_by(sampsize.test, x1sd.test, beta2.test)%>%
    summarize(power_b1=mean(sig_b1),
              power_b2=mean(sig_b2))
```

```
## # A tibble: 12 x 5
## # Groups:   sampsize.test, x1sd.test [4]
##    sampsize.test x1sd.test beta2.test power_b1 power_b2
##            <dbl>     <dbl>      <dbl>    <dbl>    <dbl>
##  1            50         1       0.1     0.056    0.042
##  2            50         1       0.15    0.058    0.052
##  3            50         1       0.2     0.054    0.043
##  4            50        10       0.1     0.544    0.049
##  5            50        10       0.15    0.51     0.058
##  6            50        10       0.2     0.536    0.053
##  7           100         1       0.1     0.058    0.044
##  8           100         1       0.15    0.059    0.054
##  9           100         1       0.2     0.057    0.044
```

15

<!-- page 16 -->

```r
## 10           100        10       0.1     0.828    0.064
## 11           100        10       0.15    0.84     0.038
## 12           100        10       0.2     0.829    0.051
```

- What do you observe in the power as the sample size, $\sigma_{x1}$ and $\beta_2$ change?
  - $n$ changes $\rightarrow$
  - $\sigma_{x1}$ changes $\rightarrow$
  - $\beta_2$ changes $\rightarrow$

16
