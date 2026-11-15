---
id: "jpsm/complex_sample_data_SURV701/labs/Module_5_SAS_supplement"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lab"
title: "Module #7: Replication Variance Estimation"
original: "complex_sample_data_SURV701/labs/Module_5_SAS_supplement.pdf"
pages: 30
sha256: "bb2077a7e9f32d1596e7bcc2e31f5a61dc92841c7b82624101a500a4c362e77c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:48"
---

<!-- page 1 -->

# Module #7: Replication Variance Estimation

All analyses up to this point in the course have employed the Taylor series linearization (TSL) approach for variance estimation, the default in most software (including SAS). In this module, we introduce the increasingly popular class of alternative variance estimators known as *replication techniques*. The basic idea is to treat the survey data set as if it were the population and repeatedly sample from it in some systematic fashion. From each sample, or replicate, the quantity of interest is estimated. The variance of the full-sample point estimate is then estimated as a simple function of the variability amongst replicate-specific estimates.

Perhaps the most appealing feature is that there is generally only one variance formula (per method), regardless of the point estimate. Certain other advantages relative to Taylor series linearization (TSL) will be noted as well.

STAT674 – GMU – Lewis

1

<!-- page 2 -->

# More Background on TSL

As we have seen in a few different contexts, for a weighted mean of the form

$$\hat{\bar{y}} = \frac{\sum_{i=1}^{n} w_i y_i}{\sum_{i=1}^{n} w_i} = \frac{\hat{Y}}{\hat{N}}$$

the TSL variance estimate can be found by

$$\text{var}\left(\frac{\hat{Y}}{\hat{N}}\right) \approx \frac{1}{\hat{N}^2} \left[ \text{var}(\hat{Y}) + \left(\frac{\hat{Y}}{\hat{N}}\right)^2 \text{var}(\hat{N}) - 2\left(\frac{\hat{Y}}{\hat{N}}\right) \text{cov}(\hat{Y}, \hat{N}) \right]$$

If you consult the SAS documentation, however, you will find a different formula. That’s because SAS (as with most other software) uses a simplifying algorithm proposed by Woodruff (1971)…

STAT674 – GMU – Lewis

2

<!-- page 3 -->

# The Woodruff TSL Algorithm

In a brief, yet very influential, paper, Woodruff proved that the variance of any point estimate that can be expressed as a differentiable function of totals can be sufficiently approximated by estimating the variance of the sum of a new variate $u_i$, often referred to as a *linear substitute*, defined as the sum of the function's partial derivatives times the given PSU-level total.

Considering the weighted mean:

$$
\hat{\bar{y}} = \frac{\hat{Y}}{\hat{N}} = \frac{\hat{T}_1}{\hat{T}_2} \longrightarrow \begin{cases}
\frac{\partial \hat{\bar{y}}}{\partial \hat{T}_1} = \frac{1}{\hat{T}_2} & ; \quad \frac{\partial \hat{\bar{y}}}{\partial \hat{T}_2} = -\frac{\hat{T}_1}{\hat{T}_2^2} \\
\\
\hat{t}_{1i} = w_i y_i & ; \quad \hat{t}_{2i} = w_i
\end{cases}
$$

and so the linear substitute is $u_i = \left(\frac{1}{\hat{T}_2}\right) \left(w_i y_i - \left(\frac{\hat{T}_1}{\hat{T}_2}\right) w_i\right)$ . (See Program 9.1 in text)

STAT674 – GMU – Lewis
3

<!-- page 4 -->

# Advantages/Disadvantages of the Woodruff TSL Algorithm

The primary advantage of the Woodruff TSL approach is that it converts a (potentially complex) variance estimation task into a simple one.

Two disadvantages:

1. Must derive (or have software developers pre-program) the linear substitutes for any point estimate functional form. Easy to do for some of the obvious ones, but what if we wanted to find the variance of the difference of two intensity ratios in CBECS?
2. Not all functions can be expressed in a differentiable, closed form. Binder (1983) developed a generalization for implicitly defined functions, which is used for logistic regression and certain survival analysis modeling techniques, but what about quantiles?

Note that replication techniques are not subject to these two disadvantages.

---

STAT674 – GMU – Lewis

4

<!-- page 5 -->

# Balanced Repeated Replication

The first replication technique we will consider is *balanced repeated replication* (BRR), which was originally developed in the mid-1960s to estimate variances in two-PSU-per-stratum sample designs.

The strategy is to select one of the two PSUs from each of the $H$ strata and double the weights of all units therein while setting the weights of all units in the unselected PSU to 0. The new weight is called a *replicate weight*.

The process is repeated a number of times, with the replicate weights getting appended to the analysis file. The variability amongst point estimates calculated using each replicate weight, in turn, serves as the estimate of variability for the full-sample point estimate.

STAT674 – GMU – Lewis

5

<!-- page 6 -->

# Balanced Repeated Replication (2)

So how many replicates do we need? And how do we know which PSU from each stratum to select for each? To achieve a desirable property called *full orthogonal balance*, we assign the number of replicates to be the first multiple of four strictly greater than the number of strata. So, if we denote $R$ to be the number of replicates (or replicate weights), we require $H < R \le H + 4$.

To answer the second question, we make use of *Hadamard* matrices from the field of experimental design. A Hadamard matrix, typically denoted $\mathbf{H}$, is a square matrix of $+1$s and $-1$s where columns correspond to strata and rows to replicates. (Columns and rows are technically interchangeable.) You can ascribe, say, a value of $+1$ for a Hadamard matrix entry to mean that the first PSU is selected, and a value of $-1$ to mean the second PSU is selected.

The “balanced” or “orthogonal” qualifiers are attributable to the fact that the dot product of any two columns/rows is 0.

---
STAT674 – GMU – Lewis 6

<!-- page 7 -->

# Balanced Repeated Replication (3)

To put everything together, note that we will have the full-sample point estimate $\hat{\theta}$ as well as $R$ replicate-specific point estimates, $\hat{\theta}_r$

The BRR variance estimate is just the mean squared error of the replicate-specific point estimates from the full-sample point estimate:

$$\text{var}_{BRR}(\hat{\theta}) = \frac{1}{R}\sum_{r=1}^{R}(\hat{\theta}_r - \hat{\theta})^2$$

Again, this is the same formula one would use regardless of the definition of $\theta$.

STAT674 – GMU – Lewis

7

<!-- page 8 -->

# BRR Example Using Mathematics Aptitude Survey Data Set

```sas
data test;
  input class class_type $ homeroom grade1 tutor $ grade2 weight;
datalines;
12 upper 1 87 Y 94 49.5
12 upper 1 89 N 89 49.5
12 upper 2 91 Y 94 48
12 upper 2 84 Y 92 48
11 upper 1 82 N 84 47.5
11 upper 1 94 N 95 47.5
11 upper 2 93 N 95 48
11 upper 2 94 Y 97 48
10 under 1 78 N 81 39
10 under 1 84 N 84 39
10 under 2 90 N 87 37.5
10 under 2 82 N 85 37.5
 9 under 1 88 N 88 40
 9 under 1 93 Y 91 40
 9 under 2 77 Y 85 48
 9 under 2 81 N 84 48
;
run;
```

STAT674 – GMU – Lewis

8

<!-- page 9 -->

# BRR Example Using Mathematics Aptitude Survey Data Set (2)

VARMETHOD=BRR overrides the default VARMETHOD=TAYLOR.
Notice that $R = 8$ is the first multiple of 4 strictly greater than $H = 4$.

```sas
proc surveymeans data=test varmethod=BRR (outweights=test_BRR) mean var stderr;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight;
run;
```

### The SURVEYMEANS Procedure

#### Data Summary

| | |
| :--- | ---: |
| Number of Strata | 4 |
| Number of Clusters | 8 |
| Number of Observations | 16 |
| Sum of Weights | 715 |

#### Variance Estimation

| | |
| :--- | ---: |
| Method | BRR |
| Number of Replicates | 8 |

#### Statistics

| Variable | Mean | Std Error of Mean | Var of Mean |
| :--- | ---: | ---: | ---: |
| grade2 | 89.317483 | 1.201095 | 1.442630 |

---
STAT674 – GMU – Lewis

9

<!-- page 10 -->

# Partial View of the TEST_BRR Data Set

Outputting the replicate weights to a new data set is technically optional, but it can make subsequent analyses more efficient. Although they share a common label, the replicate weights are named RepWt_1, RepWt_2,….

| | class | homeroom | grade2 | weight | Replicate Weight | Replicate Weight | Replicate Weight | Replicate Weight |
|---|---|---|---|---|---|---|---|---|
| 1 | 12 | 1 | 94 | 49.5 | 99 | 99 | 99 | 99 |
| 2 | 12 | 1 | 89 | 49.5 | 99 | 99 | 99 | 99 |
| 3 | 12 | 2 | 94 | 48 | 0 | 0 | 0 | 0 |
| 4 | 12 | 2 | 92 | 48 | 0 | 0 | 0 | 0 |
| 5 | 11 | 1 | 84 | 47.5 | 95 | 0 | 0 | 95 |
| 6 | 11 | 1 | 95 | 47.5 | 95 | 0 | 0 | 95 |
| 7 | 11 | 2 | 95 | 48 | 0 | 96 | 96 | 0 |
| 8 | 11 | 2 | 97 | 48 | 0 | 96 | 96 | 0 |
| 9 | 10 | 1 | 81 | 39 | 78 | 78 | 0 | 0 |
| 10 | 10 | 1 | 84 | 39 | 78 | 78 | 0 | 0 |
| 11 | 10 | 2 | 87 | 37.5 | 0 | 0 | 75 | 75 |
| 12 | 10 | 2 | 85 | 37.5 | 0 | 0 | 75 | 75 |
| 13 | 9 | 1 | 88 | 40 | 80 | 0 | 80 | 0 |
| 14 | 9 | 1 | 91 | 40 | 80 | 0 | 80 | 0 |
| 15 | 9 | 2 | 85 | 48 | 0 | 96 | 0 | 96 |
| 16 | 9 | 2 | 84 | 48 | 0 | 96 | 0 | 96 |

STAT674 – GMU – Lewis

10

<!-- page 11 -->

# BRR Example on Data Set with Replicate Weights Appended

For complex survey data sets with the replicate weights already appended, you can identify the proper method in the VARMETHOD= option and list the replicate weight variables in the REPWEIGHTS statement. Technically, the STRATA/CLUSTER statements are no longer necessary (the SURVEY procedure will ignore them if detected). However, you still need to identify the full-sample weight in the WEIGHT statement.

For example, the output from the syntax below matches what we found moments ago.

```sas
*** Program 9.4;
proc surveymeans data=test_BRR varmethod=BRR mean var stderr;
  var grade2;
weight weight;
repweights RepWt_1-RepWt_8;
run;
```

STAT674 – GMU – Lewis 11

<!-- page 12 -->

# Fay’s Variant to BRR

Judkins (1990) discusses a variant to the traditional BRR method, originally proposed by Robert Fay in an unpublished manuscript, whereby instead of doubling the weights of units in the “selected” PSU, weights are inflated by a factor of $2 - \varepsilon$, where $0 \le \varepsilon < 1$, while the weights of units in the “unselected” PSU are inflated by a factor of $\varepsilon$. Hence, all PSUs are represented in every replicate, which is believed to foster more stability in variance estimates.

The term $\varepsilon$ is called *Fay’s coefficient*, and a typical value used is 0.5, although Lee and Forthofer (2006) cite simulation results suggesting $\varepsilon = 0.3$ yields some desirable properties.

The Fay variant to BRR results in a slightly modified formula:

$$
\text{var}_{BRR-Fay}(\hat{\theta}) = \frac{1}{R(1 - \varepsilon)^2} \sum_{r=1}^{R} (\hat{\theta}_r - \hat{\theta})^2
$$

STAT674 – GMU – Lewis

12

<!-- page 13 -->

# Fay’s BRR with the Mathematics Aptitude Survey Data Set

Although there is no VARMETHOD=BRR_FAY, you can think of “regular” BRR as the special case of Fay’s BRR where $\varepsilon = 0$. So specifying something other than 0 via the FAY= option in parentheses kicks things into gear.

```sas
*** Program 9.5;
proc surveymeans data=test varmethod=BRR
                          (outweights=test_BRR_Fay fay=.3)
  mean stderr;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight;
run;
```

### Variance Estimation

| | |
| :--- | ---: |
| **Method** | **BRR** |
| **Number of Replicates** | **8** |
| **Fay Coefficient** | **0.3** |

### Statistics

| Variable | Mean | Std Error of Mean |
| :--- | ---: | ---: |
| **grade2** | **89.317483** | **1.195644** |

---
STAT674 – GMU – Lewis

13

<!-- page 14 -->

# Partial View of the TEST_BRR_FAY Data Set

Notice how none of the replicate weights are set to zero (only the first four are shown here). Units from the “selected” PSU have their weights multiplied by 1.7, whereas the “unselected” PSU’s units have weights multiplied by 0.3.

| | class | homeroom | grade2 | weight | Replicate Weight | Replicate Weight | Replicate Weight | Replicate Weight |
| :---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 12 | 1 | 94 | 49.5 | 84.15 | 84.15 | 84.15 | 84.15 |
| 2 | 12 | 1 | 89 | 49.5 | 84.15 | 84.15 | 84.15 | 84.15 |
| 3 | 12 | 2 | 94 | 48 | 14.4 | 14.4 | 14.4 | 14.4 |
| 4 | 12 | 2 | 92 | 48 | 14.4 | 14.4 | 14.4 | 14.4 |
| 5 | 11 | 1 | 84 | 47.5 | 80.75 | 14.25 | 14.25 | 80.75 |
| 6 | 11 | 1 | 95 | 47.5 | 80.75 | 14.25 | 14.25 | 80.75 |
| 7 | 11 | 2 | 95 | 48 | 14.4 | 81.6 | 81.6 | 14.4 |
| 8 | 11 | 2 | 97 | 48 | 14.4 | 81.6 | 81.6 | 14.4 |
| 9 | 10 | 1 | 81 | 39 | 66.3 | 66.3 | 11.7 | 11.7 |
| 10 | 10 | 1 | 84 | 39 | 66.3 | 66.3 | 11.7 | 11.7 |
| 11 | 10 | 2 | 87 | 37.5 | 11.25 | 11.25 | 63.75 | 63.75 |
| 12 | 10 | 2 | 85 | 37.5 | 11.25 | 11.25 | 63.75 | 63.75 |
| 13 | 9 | 1 | 88 | 40 | 68 | 12 | 68 | 12 |
| 14 | 9 | 1 | 91 | 40 | 68 | 12 | 68 | 12 |
| 15 | 9 | 2 | 85 | 48 | 14.4 | 81.6 | 14.4 | 81.6 |
| 16 | 9 | 2 | 84 | 48 | 14.4 | 81.6 | 14.4 | 81.6 |

STAT674 – GMU – Lewis

14

<!-- page 15 -->

# The Jackknife

Another popular replication procedure is the *jackknife*. There are actually several closely related forms used in practice, but the one we will illustrate here is the traditional method, what Valliant et al. (2008) refer to as the “delete-one” version.

The strategy is to delete each PSU, in turn, and weight up the remaining PSUs. Hence, the number of replicate weights equals the number of PSUs, and the approach is amenable to any kind of sample design, not strictly two-PSU-per stratum sample designs. (Although we will not consider them here, there are strategies to combine PSUs to reduce the number of replicate weights necessary.)

As before, the variance estimate of the full-sample point estimate is found by a universal function of variation amongst the replicate-specific estimates.

---
STAT674 – GMU – Lewis 15

<!-- page 16 -->

# The Jackknife (2)

Process for creating jackknife replicate weights:

1. For units in the dropped PSU, set all weights to 0.
2. For units in the same stratum as the dropped PSU, inflate the weights by a factor of $n_h/(n_h - 1)$, where $n_h$ is the number of PSUs in the donor stratum.
3. For units outside the donor stratum, the replicate weight takes on the same value as the original weight. (If there is no stratification in the sample design, you can skip this step.)

Given the $R$ replicate-specific point estimates, the jackknife variance estimate is

$$\text{var}_{JK}(\hat{\theta}) = \sum_{r=1}^R \frac{n_h - 1}{n_h} (\hat{\theta}_r - \hat{\theta})^2$$

where the term $(n_h - 1)/n_h$ is called the *jackknife coefficient*.

STAT674 – GMU – Lewis

16

<!-- page 17 -->

# Jackknife Example Using Mathematics Aptitude Survey Data Set

VARMETHOD=JK requests jackknife variance estimation. Notice how the jackknife coefficients are stored in a separate data set.

```sas
*** Program 9.7;
proc surveymeans data=test varmethod=JK
 (outweights=test_JK outjkcoefs=test_JK_coefs) mean stderr;
  stratum class;
  cluster homeroom;
  var grade2;
weight weight;
run;
```

### Variance Estimation

| | |
| :--- | ---: |
| **Method** | **Jackknife** |
| **Number of Replicates** | **8** |

### Statistics

| Variable | Mean | Std Error of Mean |
| :--- | ---: | ---: |
| **grade2** | **89.317483** | **1.183876** |

---

STAT674 – GMU – Lewis

17

<!-- page 18 -->

# Partial View of the TEST_JK Data Set

Because there are 8 PSUs, there are 8 replicate weights produced, named RepWt_1,…,RepWt_8 (only the first 4 are shown here). Notice how the replicate weight is same as original weight for units outside of dropped PSU's stratum.

| | class | homeroom | grade2 | weight | Replicate Weight | Replicate Weight | Replicate Weight | Replicate Weight |
|---|---|---|---|---|---|---|---|---|
| 1 | 12 | 1 | 94 | 49.5 | 49.5 | 49.5 | 49.5 | 49.5 |
| 2 | 12 | 1 | 89 | 49.5 | 49.5 | 49.5 | 49.5 | 49.5 |
| 3 | 12 | 2 | 94 | 48 | 48 | 48 | 48 | 48 |
| 4 | 12 | 2 | 92 | 48 | 48 | 48 | 48 | 48 |
| 5 | 11 | 1 | 84 | 47.5 | 47.5 | 47.5 | 47.5 | 47.5 |
| 6 | 11 | 1 | 95 | 47.5 | 47.5 | 47.5 | 47.5 | 47.5 |
| 7 | 11 | 2 | 95 | 48 | 48 | 48 | 48 | 48 |
| 8 | 11 | 2 | 97 | 48 | 48 | 48 | 48 | 48 |
| 9 | 10 | 1 | 81 | 39 | 39 | 39 | 0 | 78 |
| 10 | 10 | 1 | 84 | 39 | 39 | 39 | 0 | 78 |
| 11 | 10 | 2 | 87 | 37.5 | 37.5 | 37.5 | 75 | 0 |
| 12 | 10 | 2 | 85 | 37.5 | 37.5 | 37.5 | 75 | 0 |
| 13 | 9 | 1 | 88 | 40 | 0 | 80 | 40 | 40 |
| 14 | 9 | 1 | 91 | 40 | 0 | 80 | 40 | 40 |
| 15 | 9 | 2 | 85 | 48 | 96 | 0 | 48 | 48 |
| 16 | 9 | 2 | 84 | 48 | 96 | 0 | 48 | 48 |

STAT674 – GMU – Lewis

18

<!-- page 19 -->

# Partial View of the TEST_JK_COEFS Data Set

Because $n_h = 2$ for each of the $H$ strata, the jackknife coefficients are $(2 - 1)/2 = 0.5$ for all $R$ replicate weights. As we will see, we must inform the SURVEY procedure about the jackknife coefficients whenever we analyze a complex survey data set with replicate weights already appended. The SURVEY procedure will be looking for the variables REPLICATE and JKCOEFFICIENT, which are the default names assigned, even though the labels are slightly different.

| | Replicate Number | Donor Stratum | Jackknife Coefficient |
|---|---|---|---|
| 1 | 1 | 1 | 0.5 |
| 2 | 2 | 1 | 0.5 |
| 3 | 3 | 2 | 0.5 |
| 4 | 4 | 2 | 0.5 |
| 5 | 5 | 3 | 0.5 |
| 6 | 6 | 3 | 0.5 |
| 7 | 7 | 4 | 0.5 |
| 8 | 8 | 4 | 0.5 |

STAT674 – GMU – Lewis

19

<!-- page 20 -->

# Jackknife Example on Data Set with Replicate Weights Appended

Note that the output produced after executing the syntax below matches what we found moments ago.

Again, the STRATA/CLUSTER statements are no longer necessary (the SURVEY procedure will ignore them if detected). However, you still need to identify the full-sample weight in the WEIGHT statement. Note how the JKCOEFS= option after the slash in the REPWEIGHTS statement points the SURVEY procedure to a supplemental data set of jackknife coefficients.

```sas
*** Program 9.8;
proc surveymeans data=test_JK varmethod=JK mean stderr;
  var grade2;
weight weight;
repweights RepWt_1-RepWt_8 / jkcoefs=test_JK_coefs;
run;
```

---

STAT674 – GMU – Lewis

20

<!-- page 21 -->

# The JK2

In the presence of a two-PSU-per-stratum sample design, a noteworthy simplification to the jackknife procedure can be employed. Westat (2007, Appendix A) refers to this as the “JK2” approach.

For linear estimators such as totals, retaining only one of the two replicates from each stratum and setting the jackknife coefficient to 1 is algebraically equivalent to the variance estimate obtained via the full jackknife procedure. For non-linear estimators such as weighted means, the variance is not necessarily the same, but still unbiased. Thus, we can cut our workload in half by randomly selecting one of the two replicates from all $H$ strata and employing the following modified formula:

$$\text{var}_{JK2}(\hat{\theta}) = \sum_{\tilde{r}=1}^{R/2} (\hat{\theta}_{\tilde{r}} - \hat{\theta})^2$$

where $\tilde{r}$ indexes the replicate randomly chosen within each stratum.

STAT674 – GMU – Lewis 21

<!-- page 22 -->

# JK2 Example Using the Mathematics Aptitude Survey Data Set

Suppose we used some random mechanism to determine we could retain replicates 2, 3, 5, and 8. At the time of textbook publication, SAS required each jackknife coefficient to be strictly between 0 and 1, so a proposed work-around was to assign a value like 0.99999. (When all coefficients are equivalent, we can input a value in lieu of a data set for the JKCOEFS= option after the slash in the REPWEIGHTS statement.)

```sas
*** Program 9.9;
proc surveymeans data=test_JK varmethod=JK mean stderr;
  var grade2;
weight weight;
repweights RepWt_2 RepWt_3 RepWt_5 RepWt_8 / jkcoefs=0.99999;
run;
```

**Variance Estimation**

| | |
| :--- | ---: |
| **Method** | **Jackknife** |
| **Replicate Weights** | **TEST_JK** |
| **Number of Replicates** | **4** |

**Statistics**

| Variable | Mean | Std Error of Mean |
| :--- | ---: | ---: |
| **grade2** | **89.317483** | **1.191791** |

---

STAT674 – GMU – Lewis  22

<!-- page 23 -->

# The Bootstrap

The third and final replication technique we will consider is the *bootstrap*. Perhaps the most popular form of the bootstrap in the analysis of complex survey data is the *nonparametric* bootstrap.

The first step is to select $n_h - 1$ PSUs *with replacement* from each stratum. Next, the weights of units in selected PSUs are multiplied by $n_h / (n_h - 1)$ times the number of times the PSU was selected. (If the PSU was not selected, all units therein are assigned a weight of 0.)

The idea is to repeat the process independently $B$ times, where $B$ is often 200 or more, and then use the following formula to estimate the variance of the full-sample point estimate $\theta$:

$$
\text{var}_{boot}(\hat{\theta}) = \frac{1}{B-1} \sum_{b=1}^{B} (\hat{\theta}_b - \hat{\theta})^2
$$

STAT674 – GMU – Lewis

23

<!-- page 24 -->

# The Bootstrap (2)

Although the technique is not explicitly offered in the SURVEY procedures at the moment (but is coming in SAS/STAT 14.3), Lohr (2012) wrote a macro called %BOOTWT that can be used to create bootstrap replicate weights.

The %BOOTWT macro has the following (positional) macro parameters:

1. fulldata – name of input data set
2. wt – the original survey weight
3. stratvar – stratum identifier variable on input data set
4. psuvar – PSU identifier variable
5. numboot – number of bootstrap replicates to create
6. fullrep – names the output data set (original with replicate weights appended)
7. repwt – prefix of replicate weight variable names
8. seed – random number seed (added for the version appearing in text)

STAT674 – GMU – Lewis

24

<!-- page 25 -->

# Bootstrap Example Using Mathematics Aptitude Survey Data Set

The syntax below creates 200 bootstrap replicate weights using the %BOOTWT macro and stores the result in a data set called TEST_BOOT.

```sas
*** Program 9.10;
%bootwt (test,weight,class,homeroom,200,test_boot,RepWt_,399448);
```

View of the first five replicate weights in the TEST_BOOT data set:

| | RepWt_1 | RepWt_2 | RepWt_3 | RepWt_4 | RepWt_5 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 0 | 80 | 0 | 80 | 0 |
| 2 | 0 | 80 | 0 | 80 | 0 |
| 3 | 96 | 0 | 96 | 0 | 96 |
| 4 | 96 | 0 | 96 | 0 | 96 |
| 5 | 78 | 78 | 78 | 0 | 0 |
| 6 | 78 | 78 | 78 | 0 | 0 |
| 7 | 0 | 0 | 0 | 75 | 75 |
| 8 | 0 | 0 | 0 | 75 | 75 |
| 9 | 0 | 0 | 95 | 95 | 95 |
| 10 | 0 | 0 | 95 | 95 | 95 |
| 11 | 96 | 96 | 0 | 0 | 0 |
| 12 | 96 | 96 | 0 | 0 | 0 |
| 13 | 99 | 99 | 99 | 99 | 0 |
| 14 | 99 | 99 | 99 | 99 | 0 |
| 15 | 0 | 0 | 0 | 0 | 96 |
| 16 | 0 | 0 | 0 | 0 | 96 |

STAT674 – GMU – Lewis

25

<!-- page 26 -->

# Bootstrap Example Using Mathematics Aptitude Survey Data Set (2)

Even with the replicate weights now created, we still need to loop over all of them, computing the point estimate. Although there is no VARMETHOD=BOOT option we can specify in the SURVEY procedure, Lohr (2012) notes how we could move the $1/(B - 1)$ term inside the summation of the bootstrap variance formula and arrive at something very similar to the jackknife:

$$
\text{var}_{boot}(\hat{\theta}) = \frac{1}{B-1} \sum_{b=1}^{B} (\hat{\theta}_b - \hat{\theta})^2 \qquad \text{vs.} \qquad \text{var}_{JK}(\hat{\theta}) = \sum_{r=1}^{R} \frac{n_h - 1}{n_h} (\hat{\theta}_r - \hat{\theta})^2
$$

So the prescribed work-around is to specify VARMETHOD=JK but assign the jackknife coefficient as $1/(B - 1)$.

---

STAT674 – GMU – Lewis

26

<!-- page 27 -->

# Bootstrap Example Using Mathematics Aptitude Survey Data Set (3)

The syntax below estimates the standard error of the mean year-end mathematics examination grade via the nonparametric bootstrap.

```sas
*** Program 9.11;
proc surveymeans data=test_boot varmethod=JK mean stderr;
  var grade2;
weight weight;
repweights RepWt_1-RepWt_200 / jkcoef=0.005025;
run;
```

### Variance Estimation

| | |
| :--- | ---: |
| Method | Jackknife |
| Replicate Weights | TEST_BOOT |
| Number of Replicates | 200 |

### Statistics

| Variable | Mean | Std Error of Mean |
| :--- | ---: | ---: |
| grade2 | 89.317483 | 1.156067 |

---
STAT674 – GMU – Lewis

27

<!-- page 28 -->

# Replication Techniques for Linear Models

Any of the replication techniques discussed here can be extended to multivariate contexts, such as linear models. For example, rather than employing the complex TSL matrix algebra needed to find the model parameter covariance matrix, we could fit the model with the full-sample weight, and then independently using each replicate weight and consolidate the results.

For BRR, this would involve matrix notation, and would look something like:

$$\text{cov}_{BRR}(\hat{\mathbf{B}}) = \frac{1}{R} \sum_{r=1}^R (\hat{\mathbf{B}}_r - \hat{\mathbf{B}})(\hat{\mathbf{B}}_r - \hat{\mathbf{B}})^\text{T}$$

Similar expressions exist for other replication techniques. While the syntax to create and/or utilize replicate weights is equivalent across all SURVEY procedures, including those capable of fitting linear models, it is useful to see a brief example of the computations...

---

STAT674 – GMU – Lewis

28

<!-- page 29 -->

# Replication Techniques for Linear Models (2)

Suppose a simple linear model was fit using the survey weights and estimates an intercept and slope as 87.4394 and 4.7701, respectively. The estimates based on 8 BRR replicate weights are summarized in the table below.

| Replicate | Intercept | Slope |
| :---: | :--- | :--- |
| 1 | 87.0971 | 5.5621 |
| 2 | 86.9463 | 5.0743 |
| 3 | 89.1082 | 5.0663 |
| 4 | 87.4393 | 2.1300 |
| 5 | 86.6549 | 5.7568 |
| 6 | 86.3621 | 5.6379 |
| 7 | 89.1411 | 4.4676 |
| 8 | 87.0849 | 3.2485 |

Two example components of the model parameter covariance matrix:

$$
\text{var}_{BRR}(\hat{B}_0) = \frac{1}{8} \left[ (87.0971 - 87.4394)^2 + \dots + (87.0849 - 87.4394)^2 \right]
$$

$$
\text{cov}_{BRR}(\hat{B}_0, \hat{B}_1) = \frac{1}{8} \left[ (87.0971 - 87.4394)(5.5621 - 4.7701) + \dots + (87.0849 - 87.4394)(3.2485 - 4.7701) \right]
$$

STAT674 – GMU – Lewis

29

<!-- page 30 -->

# Concluding Remarks

There is no universally accepted “best” replication method – all provide an unbiased variance approximations (except that results from Kovar et al. (1988) suggest the jackknife should be avoided for variance estimation of quantiles).

In the event you are conducting an analysis not yet supported by one of the SURVEY procedures, you can whip up a quick macro to ascertain/coalesce the replicate-specific estimates (see Program 9.14 for an example).

It turns out that the nuances of when it is and is not OK to subset a complex survey data set apply only to Taylor series variance estimation. You are free to subset a complex survey data set that has replicate weights appended for variance estimation purposes.

---
STAT674 – GMU – Lewis 30
