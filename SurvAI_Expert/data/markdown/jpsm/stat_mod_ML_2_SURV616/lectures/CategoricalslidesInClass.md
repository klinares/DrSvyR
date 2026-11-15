---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/CategoricalslidesInClass"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "In-Class 2. Categorical Data Analysis"
original: "stat_mod_ML_2_SURV616/lectures/CategoricalslidesInClass.pdf"
pages: 28
sha256: "6747b9a5443f76870bc4b053a6d9203504501f1b3c34b97cb12c2038ba304725"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:21"
---

<!-- page 1 -->

# In-Class 2. Categorical Data Analysis

Nishimura/Suzer-Gurtekin

January 2024

<!-- page 2 -->

# Group Assignments for Today's In-class Exercises

| | |
| :--- | :--- |
| Maryland1 | Maryland2 |
| Kangrui Liu | Da'Sauni E Singleton |
| Katherine Pistner | Lindsey Ann English |
| Lucy Robles | Mathew Hill |
| Matthew Cowles | Michael Joseph Muldoon |
| Ximiao Zhao | Willian Hopkins |
| | |
| Michigan1 | Michigan2 |
| Avery Muhl | Ang Li |
| Chloe Chen | Aria LU |
| Keqing Lu | Qichuan Zhou |
| Nia Holland | Qiyu Yang |
| Sol Rabine | Wen Chen |
| | |
| Michigan3 | Michigan4 |
| Akari Oya | Peter Tan |
| Leng Seong Che | Rona Hu |
| Saujanya Acharya | Yuya Okubo |
| Yesdi Christian Calvin | Zhuoer Wang |
| Zeyu Lou | |
| | |
| Zoom | |
| Angelo Cozzubo | |
| Elizabeth Seravello | |
| Eric Ohemeng | |
| Francis Lavoe | |
| Joshua Turnbull | |
| Queen Alicia Sampson | |
| Sean Johnson | |
| Srijeeta Mitra | |
| Tavril Saint Jean | |

* I will create breakout rooms for the zoom participants during the class

* Identify your group members and sit at close proximity
* Take time to introduce yourself if you don't know each other before
* Select a spokesperson for each exercise to summarize your discussion back to the class

<!-- page 3 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Overview

1. Analysis of Two-Way Tables

2. Odds Ratios and Relative Risk

3 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 4 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Two-Way Tables

Rows=I
Columns=J

| | | | Columns | | | |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Rows** | **1** | **2** | **3** | **4** | **5** | |
| 1 | $n_{11}$ | $n_{12}$ | $n_{13}$ | $n_{14}$ | $n_{15}$ | $n_{1+}$ |
| 2 | $n_{21}$ | $n_{22}$ | $n_{23}$ | $n_{24}$ | $n_{25}$ | $n_{2+}$ |
| 3 | $n_{31}$ | $n_{32}$ | $n_{33}$ | $n_{34}$ | $n_{35}$ | $n_{3+}$ |
| 4 | $n_{41}$ | $n_{42}$ | $n_{43}$ | $n_{44}$ | $n_{45}$ | $n_{4+}$ |
| | $n_{+1}$ | $n_{+2}$ | $n_{+3}$ | $n_{+4}$ | $n_{+5}$ | $n$ |

4 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 5 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Two-Way Tables

In this notation, each cell is $n_{ij}$ where $i$ is the *row* and $j$ is the *column*.

The plus sign denotes marginal totals:

$$n_{i+} = \sum_{j=1}^J n_{ij}$$

$$n_{+j} = \sum_{i=1}^I n_{ij}$$

$$n = \sum_{i=1}^I n_{i+} = \sum_{j=1}^J n_{+j} = \sum_{i=1}^I \sum_{j=1}^J n_{ij}$$

5 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 6 -->

Two-Way Tables
Odds Ratios and Relative Risk

# $2 \times 2$ Tables

| | | Table | |
| ---: | ---: | ---: | :---: |
| Condition | Present | Absent | Row Total |
| Yes | $n_{11}$ | $n_{12}$ | $n_{1+}$ |
| No | $n_{21}$ | $n_{22}$ | $n_{2+}$ |
| Column Total | $n_{+1}$ | $n_{+2}$ | $n$ |

6 / 27
Nishimura/Suzer-Gurtekin
in-Class 2

<!-- page 7 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 1

Disease

| | Yes | No | Row Total |
| :---: | ---: | ---: | ---: |
| Male | 10 | 40 | 50 |
| Female | 20 | 30 | 50 |
| Column Total | 30 | 70 | 100 |

What is $n_{+1}$?
What is $n_{2+}$?
What is $Pr(M, D)$?
What is $Pr(D|F)$?

7 / 27 $\qquad$ Nishimura/Suzer-Gurtekin $\qquad$ in-Class 2

<!-- page 8 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 1

Disease

| | Yes | No | Row Total |
| :--- | :---: | :---: | :---: |
| Male | 10 | 40 | 50 |
| Female | 20 | 30 | 50 |
| Column Total | 30 | 70 | 100 |

What is $n_{+1}$? 30
What is $N_{2+}$? 50
What is $Pr(M, D)$? 0.10
What is $Pr(D|F)$? 0.40

8 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 9 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Two-Way Tables

If the two variables are unrelated, then any cell proportion is the product of the marginal proportions. Using the notation from last time: $\pi_{ij} = \pi_{i+}\pi_{+j}$.

This gives us a method for creating **Expected** counts if we want to test for independence.

Another way to write it, using our notation:

$$
e_{ij} = np_{i+}p_{+j} = \frac{n_{i+}n_{+j}}{n}
$$

9 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 10 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 2

**The FREQ Procedure**

**Table of gender by age**

| gender<br><br>Frequency<br>Expected<br>Cell Chi-Square | age<br><br><br><br>0-29 | <br><br><br><br>30-39 | <br><br><br><br>40-49 | <br><br><br><br>50-59 | <br><br><br><br>>=60 | <br><br><br><br>Total |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: |
| **males** | 185<br>180.22<br>0.1269 | 207<br>209.78<br>0.0368 | 260<br>257.46<br>0.0252 | 180<br>178.31<br>0.016 | 71<br>77.237<br>0.5036 | 903 |
| **females** | 4<br>8.7814<br>2.6034 | 13<br>10.222<br>0.7551 | 10<br>12.545<br>0.5163 | 7<br>8.6885<br>0.3281 | 10<br>3.7635<br>10.335 | 44 |
| **Total** | 189 | 220 | 270 | 187 | 81 | 947 |

**Statistics for Table of gender by age**

| Statistic | DF | Value | Prob |
| :--- | ---: | ---: | ---: |
| **Chi-Square** | 4 | 15.2461 | 0.0042 |
| **Likelihood Ratio Chi-Square** | 4 | 12.6670 | 0.0130 |
| **Mantel-Haenszel Chi-Square** | 1 | 4.8961 | 0.0269 |
| **Phi Coefficient** | | 0.1269 | |
| **Contingency Coefficient** | | 0.1259 | |
| **Cramer's V** | | 0.1269 | |

**Sample Size = 947**

10 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 11 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 2

Please use the table on the previous page and calculate a $X^2$ test of association by hand (or in a spreadsheet), that is, not using R.

11 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 12 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 2

Now let's look at the solution in R. The following code:

```r
chisq.test(data.matrix(drunk))
```

Produces the following output:

```r
Pearson's Chi-squared test

data:  data.matrix(drunk)
X-squared = 15.2461, df = 4, p-value = 0.004217

Warning message:
In chisq.test(data.matrix(drunk)) :
  Chi-squared approximation may be incorrect
```

12 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 13 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Example 1

We can also produce a graphic of the chi-square deviations:

**chi deviations for drunk.dat**

males
females
chi
3
2
1
0
-1
X0.29
X30.39
X40.49
X50.59
X..60
age

13 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 14 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Example 2

Now let's look at the example in R. We have a *matrix* with our data:

```r
> glasses
           delinq non.del
glasses         1       5
no.glasses      8       2
```

14 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 15 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Example 2

We can request Fisher’s exact test with the following code:

```r
fisher.test(glasses)
```

Which produces the following output:

```r
Fisher’s Exact Test for Count Data

data:  glasses
p-value = 0.03497
alternative hypothesis: true odds ratio is not equal t
95 percent confidence interval:
 0.0009525702 0.9912282442
sample estimates:
odds ratio
0.06464255
```

15 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 16 -->

Two-Way Tables
Odds Ratios and Relative Risk

# OR and RR

| | Disease Yes | Disease No |
| :---: | :---: | :---: |
| Male | 0.15 | 0.35 |
| Female | 0.10 | 0.40 |

We want the conditional probability that you have disease given that you are male: $PR(D|M) = \pi_{1|1} = \frac{\pi_{11}}{\pi_{11}+\pi_{12}}$.

$PR(D|M) = \pi_{1|1} = \frac{0.15}{0.15+0.35} = 0.3$

16 / 27
Nishimura/Suzer-Gurtekin
in-Class 2

<!-- page 17 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Relative Risk

Now, define the relative risk.

$$\text{Relative Risk}(\text{Response Category } 1) = \frac{\pi_{1|1}}{\pi_{1|2}}$$

For example:

$$\frac{\pi_{1|1}}{\pi_{1|2}} = \frac{\Pr(D|M)}{\Pr(D|F)} = \frac{.3}{.2} = 1.5$$

17 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 18 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Relative Risk

An easy way to estimate the relative risk is:

$$\frac{n_{11}/n_{1+}}{n_{21}/n_{2+}}$$

The distribution of the relative risk is highly skewed. Therefore, it is better to estimate the variance on the log scale.

$$\hat{V}\left\{\ln\left(\frac{n_{11}/n_{1+}}{n_{21}/n_{2+}}\right)\right\} = \frac{1 - \frac{n_{11}}{n_{1+}}}{n_{11}} + \frac{1 - \frac{n_{21}}{n_{2+}}}{n_{21}} = \frac{\Pr(\bar{D}|M)}{n_{11}} + \frac{\Pr(\bar{D}|F)}{n_{21}}$$

This is the variance of the logarithm of the Relative Risk(Response Category 1).

18 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 19 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 3

| | Disease | |
| :---: | :---: | :---: |
| | Yes | No |
| Male | 20 | 40 |
| Female | 30 | 30 |

What is the relative risk for men relative to women?
What is the variance of this estimate? Leave it on the log scale, $\hat{V}\left(\ln(\hat{RR})\right)$.

19 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 20 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 3

| | Disease | |
| :---: | :---: | :---: |
| | Yes | No |
| Male | 20 | 40 |
| Female | 30 | 30 |

What is the relative risk for men relative to women? $\frac{20/60}{30/60} = \frac{.33}{.5} = 0.67$

What is the variance of this estimate? $\hat{V}\left(\ln(\hat{RR})\right) = \frac{3}{60}$

20 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 21 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Odds Ratio

Within row 1 the *odds* (*not* odds ratio) that the response is in column 1 instead of column 2 is defined as:

$$
Odds_1 = \frac{\pi_{1|1}}{\pi_{2|1}} = \frac{\pi_{11}}{\pi_{12}}
$$

From our example, this could be written:

$$
\frac{\Pr(D|M)}{\Pr(\bar{D}|M)} = \frac{\Pr(D|M)}{1 - \Pr(D|M)}
$$

Continuing the example, the odds that a man will have the disease are $\frac{.3}{1-.3} = .43$. For women, this odds are $\frac{.2}{1-.2} = .25$

21 / 27
Nishimura/Suzer-Gurtekin
in-Class 2

<!-- page 22 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Odds Ratio

Those are the odds. The ratio of the odds is called the *odds ratio*.

$$\theta = \frac{\pi_{1|1}/\pi_{2|1}}{\pi_{1|2}/\pi_{2|2}}$$

Remember that $\pi_{1|1} = \frac{\pi_{11}}{\pi_{11}+\pi_{12}}$. So we can also write it in the following manner:

$$\theta = \frac{\frac{\pi_{11}}{\pi_{11}+\pi_{12}}/\frac{\pi_{12}}{\pi_{11}+\pi_{12}}}{\frac{\pi_{21}}{\pi_{21}+\pi_{22}}/\frac{\pi_{22}}{\pi_{21}+\pi_{22}}} = \frac{\pi_{11}/\pi_{12}}{\pi_{21}/\pi_{22}} = \frac{\pi_{11}\pi_{22}}{\pi_{21}\pi_{12}}$$

Hence the name *cross-product ratio*.

22 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 23 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Odds Ratio

We estimate the odds ratio using:

$$\hat{\theta} = \frac{n_{11}n_{22}}{n_{21}n_{12}}$$

The variance of $\ln(\hat{\theta})$ can be estimated as:

$$\hat{V}\left\{\ln\left(\hat{\theta}\right)\right\} = \frac{1}{n_{11}} + \frac{1}{n_{12}} + \frac{1}{n_{21}} + \frac{1}{n_{22}}$$

23 / 27
Nishimura/Suzer-Gurtekin
in-Class 2

<!-- page 24 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 4

**Leg Healing Trial Callum et al. 1992**

| | Leg Wound Healing | | | |
| :--- | :---: | :---: | :---: | :---: |
| | Healed | Not Healed | Total | $P_{i+}$ |
| Elastic | 35 | 30 | 65 | 0.538 |
| Inelastic | 19 | 48 | 67 | 0.284 |

Please calculate the relative risk and odds ratio of healing comparing elastic to inelastic bandages.
Please calculate the variance of the odds ratio estimate.

24 / 27
Nishimura/Suzer-Gurtekin
in-Class 2

<!-- page 25 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 4

$\hat{\theta} = \frac{35 \times 48}{19 \times 30} = 2.9474$

The variance is determined for $\ln(\hat{\theta}) = 1.0809$.

$$
\hat{V}\left\{\ln\left(\hat{\theta}\right)\right\} = \frac{1}{35} + \frac{1}{30} + \frac{1}{48} + \frac{1}{19} = 0.13537
$$

25 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 26 -->

Two-Way Tables
Odds Ratios and Relative Risk

# In-Class Problem 4

Form the confidence interval:

1. $\sqrt{V\left\{\ln \left(\hat{\theta}\right)\right\}} = 0.36793.$
2. $1.96 * 0.36793 = 0.72114.$
3. $1.0809 - 0.72114 = 0.359777398$ and $1.0809 + 0.72114 = 1.802048025.$ This is the 95% confidence interval on the logarithmic scale.
4. Exponentiate to get back to the scale of $\hat{\theta}.$ Therefore, $(e^{0.359777398}, e^{1.802048025}) = (1.443, 6.062).$

26 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 27 -->

Two-Way Tables
Odds Ratios and Relative Risk

# R Code

We can do this work in R. Here I'm using the *epiR* package:

```r
library(epiR)

bandage<-matrix(data=c(35,19,30,48),nrow=2)
bandage<-as.table(bandage)

epi.2by2(bandage)
```

27 / 27 Nishimura/Suzer-Gurtekin in-Class 2

<!-- page 28 -->

Two-Way Tables
Odds Ratios and Relative Risk

# Example 4

Which produces the following output:

```r
> epi.2by2(bandage)
             Outcome +    Outcome -      Total                 Inc risk *
Exposed +           35           30         65     53.85 (41.03 to 66.30)
Exposed -           19           48         67     28.36 (18.01 to 40.69)
Total               54           78        132     40.91 (32.43 to 49.80)

Point estimates and 95% CIs:
-------------------------------------------------------------------
Inc risk ratio                                 1.90 (1.22, 2.95)
Inc odds ratio                                 2.95 (1.43, 6.06)
Attrib risk in the exposed *                   25.49 (9.26, 41.72)
Attrib fraction in the exposed (%)            47.33 (18.05, 66.15)
Attrib risk in the population *                12.55 (-1.12, 26.22)
Attrib fraction in the population (%)         30.68 (7.22, 48.21)
-------------------------------------------------------------------
Uncorrected chi2 test that OR = 1: chi2(1) = 8.866 Pr>chi2 = 0.003
Fisher exact test that OR = 1: Pr>chi2 = 0.004
 Wald confidence limits
 CI: confidence interval
 * Outcomes per 100 population units
```

28 / 27
Nishimura/Suzer-Gurtekin
in-Class 2
