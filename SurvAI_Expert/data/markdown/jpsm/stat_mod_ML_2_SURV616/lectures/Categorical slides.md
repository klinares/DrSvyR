---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/Categorical_slides"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "Lecture 2. Categorical Data Analysis"
original: "stat_mod_ML_2_SURV616/lectures/Categorical slides.pdf"
pages: 71
sha256: "abb5f3b68de0a6b3378cce5c731e2f7d7e279b37464d8aeff78591fa5bfd714d"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:21"
---

<!-- page 1 -->

# Lecture 2. Categorical Data Analysis

James Wagner

January 2022

<!-- page 2 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Overview

1. Analysis of Two-Way Tables

2. Odds Ratios and Relative Risk

3. Introduction to Log-Linear Models

2/70

James Wagner

Class 2

<!-- page 3 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Two-way tables are a very common way to view categorical data. We need a notation for them.

Rows=I
Columns=J

| | | | Columns | | | |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Rows | 1 | 2 | 3 | 4 | 5 | |
| 1 | $n_{11}$ | $n_{12}$ | $n_{13}$ | $n_{14}$ | $n_{15}$ | $n_{1+}$ |
| 2 | $n_{21}$ | $n_{22}$ | $n_{23}$ | $n_{24}$ | $n_{25}$ | $n_{2+}$ |
| 3 | $n_{31}$ | $n_{32}$ | $n_{33}$ | $n_{34}$ | $n_{35}$ | $n_{3+}$ |
| 4 | $n_{41}$ | $n_{42}$ | $n_{43}$ | $n_{44}$ | $n_{45}$ | $n_{4+}$ |
| | $n_{+1}$ | $n_{+2}$ | $n_{+3}$ | $n_{+4}$ | $n_{+5}$ | $n$ |

3 / 70
James Wagner
Class 2

<!-- page 4 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

In this notation, each cell is $n_{ij}$ where $i$ is the *row* and $j$ is the *column*.

The plus sign denotes marginal totals:

$$
n_{i+} = \sum_{j=1}^{J} n_{ij}
$$

$$
n_{+j} = \sum_{i=1}^{I} n_{ij}
$$

$$
n = \sum_{i=1}^{I} n_{i+} = \sum_{j=1}^{J} n_{+j} = \sum_{i=1}^{I} \sum_{j=1}^{J} n_{ij}
$$

4 / 70

James Wagner

Class 2

<!-- page 5 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

The data in the table can be collected in different ways:

1. Sample and classify into $i$ and $j$, $n$ fixed
2. Sample each $j$, classify into row $i$, e.g. $n_{+1}$ is fixed
3. Each cell $(i, j)$ in the table is an independent Poisson random variable

5/70 James Wagner Class 2

<!-- page 6 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Further, in two-way tables (especially in epidemiology), we set the table up such that the columns are the response variable and the rows are the independent variable.

## Prospective Sampling
If the sampling is done within the rows/independent variable, then this is a prospective study. The response variable may not be observed.

## Retrospective Sampling
If the sampling is done within the columns/dependent variable, then this is a retrospective study. Stratify on the response variable.

6 / 70

James Wagner

Class 2

<!-- page 7 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

## Prospective Sampling Example

Exposure to dioxin may lead to cancer. Two comparable cities, but one has a dioxin-emitting plant. Sample in each city.

## Retrospective Sampling Example

Draw samples of persons with cancer and a sample of persons without. Find out how much fresh fish they ate as children.

7/70 James Wagner Class 2

<!-- page 8 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 2

| | Result of Crash | |
| ---: | ---: | ---: |
| Seat-Belt Use | Fatality | Nonfatality |
| Yes | $n_{11}$ | $n_{12}$ |
| No | $n_{21}$ | $n_{22}$ |

* Poisson: Catalog all accidents for a year and classify each on both dimensions, $n$ is random
* Multinomial: Sample 100 police records and classify each, $n$ is fixed
* Independent Multinomial: Sample 50 fatalities and 50 nonfatalities, $n_{+1}, n_{+2}$ are fixed

NOTE: The last is an example of retrospective sampling. How would prospective sampling work in this setting?

8 / 70
James Wagner
Class 2

<!-- page 9 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# $2 \times 2$ Tables

| | | Table | |
| ---: | ---: | ---: | ---: |
| Condition | Present | Absent | Row Total |
| Yes | $n_{11}$ | $n_{12}$ | $n_{1+}$ |
| No | $n_{21}$ | $n_{22}$ | $n_{2+}$ |
| Column Total | $n_{+1}$ | $n_{+2}$ | $n$ |

9/70 James Wagner Class 2

<!-- page 10 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Often the goal with data that can be presented in a two-way table is to see if there is an association between the two variables.

Consider the following $2 \times 2$ example.

| | Yes | No | Row Total |
| :---: | ---: | ---: | ---: |
| **Disease** | | | |
| Male | 30 | 70 | 100 |
| Female | 20 | 80 | 100 |
| Column Total | 50 | 150 | 200 |

It seems as if there is an association between sex and disease.

10 / 70 | James Wagner | Class 2

<!-- page 11 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Another way to describe that association is to say that the percentages vary across the columns within the rows, or across the rows within the columns.

Here are the percentages in each column.

| | **Disease** | | |
| :---: | :---: | :---: | :---: |
| | Yes | No | Row Total |
| Male | 0.3 | 0.7 | |
| Female | 0.2 | 0.8 | |
| Column Total | 0.25 | 0.75 | |

11 / 70

James Wagner

Class 2

<!-- page 12 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Here are the percentages in each row.

Disease

| | Yes | No | Row Total |
| :---: | :---: | :---: | :---: |
| Male | 0.6 | 0.47 | 0.5 |
| Female | 0.4 | 0.53 | 0.5 |
| Column Total | | | |

12 / 70

James Wagner

Class 2

<!-- page 13 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Disease

| | Yes | No | Row Total |
| :---: | ---: | ---: | ---: |
| Male | 30 | 70 | 100 |
| Female | 20 | 80 | 100 |
| Column Total | 50 | 150 | 200 |

What is $n_{+1}$?
What is $n_{2+}$?
What is $Pr(M, D)$?
What is $Pr(D|F)$?

13 / 70

James Wagner

Class 2

<!-- page 14 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Disease

| | Yes | No | Row Total |
| :---: | ---: | ---: | ---: |
| Male | 30 | 70 | 100 |
| Female | 20 | 80 | 100 |
| Column Total | 50 | 150 | 200 |

What is $n_{+1}$? 50
What is $n_{2+}$? 100
What is $Pr(M, D)$?0.15
What is $Pr(D|F)$?0.20

14 / 70

James Wagner

Class 2

<!-- page 15 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

If the two variables are associated, then the marginal proportions won't be equal to the internal proportions. $H_0$ is that they are independent.

Recall our notation:
$n_{ij}$ is the observed frequency in the cell in row $i$ and column $j$.
$n_{i+}$ is the row total
$n_{+j}$ is the column total

If the two variables are unrelated, then any cell proportion is the product of the marginal proportions. Using the notation from last time:
$\pi_{ij} = \pi_{i+}\pi_{+j}$.

15 / 70
James Wagner
Class 2

<!-- page 16 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

Using our example, under independence, $Pr(D|M) = Pr(D)$.

We could also say, given only two categories (M & F),
$Pr(D|M) = Pr(D|F)$.

Or, in words, $Pr(D)$ does not depend upon sex.

16 / 70

James Wagner

Class 2

<!-- page 17 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

This gives us a method for creating **Expected** counts if we want to test for independence.

Given these expected counts, we can use the Pearson $X^2$ and Likelihood Ratio Statistic $G^2$ to test the hypothesis.

Another way to write it, using our notation:

$$e_{ij} = np_{i+}p_{+j} = \frac{n_{i+}n_{+j}}{n}$$

17 / 70
James Wagner
Class 2

<!-- page 18 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

We can compare the statistic ($X^2$) estimated using these expected counts to a $\chi^2$ distribution with $(I - 1)(J - 1)$ degrees of freedom.

Since the last value in any row or column is fixed. In the $2 \times 2$ case that means 1 df.

18 / 70

James Wagner

Class 2

<!-- page 19 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Degrees of Freedom

In the multinomial case, we have $k - 1$ degrees of freedom.

For example, when $k = 4$, once I know $\hat{p}_i$ for 3 of the categories, then the $\hat{p}_i$ for the fourth category is fixed (1 - sum of the other 3 categories).

19 / 70

James Wagner

Class 2

<!-- page 20 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Degrees of Freedom

In two-way tables, the degrees of freedom is a function of the null hypothesis.

For example, if the hypothesis fixes one margin, then once the the first three cells in each row are known, the fourth is also known.

| 1 | 2 | 3 | | $n_{+1}$ |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 2 | 3 | | $n_{+2}$ |

20 / 70 James Wagner Class 2

<!-- page 21 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Degrees of Freedom

If both margins are fixed, then once any cell is specified, the expected values are all set. Therefore, there is one degree of freedom.

| 16 | | 20 |
| :--- | :--- | :--- |
| | | 30 |
| 40 | 10 | 50 |

Another way to express the $H_0$ given by fixing both margins is to say that the $H_0$ is no association between the two factors.

21/70
James Wagner
Class 2

<!-- page 22 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

It is also possible to look at the individual deviations from a Pearson $X^2$.

$$
X^2 = \sum_{i=1}^I \sum_{j=1}^J \frac{(O_{ij} - E_{ij})^2}{E_{ij}} = \frac{(O_{11} - E_{11})^2}{E_{11}} + \ldots + \frac{(O_{IJ} - E_{IJ})^2}{E_{IJ}}
$$

So, any cell has a deviation:

$$
\frac{(O_{ij} - E_{ij})^2}{E_{ij}}
$$

22 / 70
James Wagner
Class 2

<!-- page 23 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 1

Let's look at an example. Counts of persons convicted of drunkeness in 2 London courts in first 6 months of 1970. SAS code:

```sas
proc freq order=data;
  weight n;
  tables gender*age / chisq nopercent nocol
      norow expected cellchi2;
run;
```

Taken from Heiberger and Holland, p. 487.

23 / 70
James Wagner
Class 2

<!-- page 24 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 1

The FREQ Procedure

Table of gender by age

| gender<br>Frequency<br>Expected<br>Cell Chi-Square | age<br>0-29 | 30-39 | 40-49 | 50-59 | >=60 | Total |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: |
| **males** | 185<br>180.22<br>0.1269 | 207<br>209.78<br>0.0368 | 260<br>257.46<br>0.0252 | 180<br>178.31<br>0.016 | 71<br>77.237<br>0.5036 | 903 |
| **females** | 4<br>8.7814<br>2.6034 | 13<br>10.222<br>0.7551 | 10<br>12.545<br>0.5163 | 7<br>8.6885<br>0.3281 | 10<br>3.7635<br>10.335 | 44 |
| **Total** | 189 | 220 | 270 | 187 | 81 | 947 |

Statistics for Table of gender by age

| Statistic | DF | Value | Prob |
| :--- | ---: | ---: | ---: |
| Chi-Square | 4 | 15.2461 | 0.0042 |
| Likelihood Ratio Chi-Square | 4 | 12.6670 | 0.0130 |
| Mantel-Haenszel Chi-Square | 1 | 4.8961 | 0.0269 |
| Phi Coefficient | | 0.1269 | |
| Contingency Coefficient | | 0.1259 | |
| Cramer's V | | 0.1269 | |

Sample Size = 947

24/70

James Wagner

Class 2

<!-- page 25 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 1

Now let’s look at the example in R. The following code:

```r
chisq.test(data.matrix(drunk))
```

Produces the following output:

```r
Pearson’s Chi-squared test

data: data.matrix(drunk)
X-squared = 15.2461, df = 4, p-value = 0.004217

Warning message:
In chisq.test(data.matrix(drunk)) :
  Chi-squared approximation may be incorrect
```

25 / 70
James Wagner
Class 2

<!-- page 26 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 1

We can also produce a graphic of the chi-square deviations:

**chi deviations for drunk.dat**

26 / 70 | James Wagner | Class 2

<!-- page 27 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Two-Way Tables

This test relies upon the assumption that if the null hypothesis is true, then this statistic has a $\chi^2$ distribution.

This can break down for tables with small cell sizes.

What is small? 5? 3?

27/70

James Wagner

Class 2

<!-- page 28 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Fisher's Exact Test

Pearson's $X^2$ relies on an approximation which can break down with small cell sizes.

An alternative is Fisher's Exact Test. It uses a hypergeometric distribution to determine the exact probability of the observed data occurring when the null hypothesis is true.

The hypergeometric distribution is a discrete distribution that describes the probability of $k$ successes in $n$ trials *without* replacement. $\frac{m}{N}$ is the probability of a success.

$$P(X = k) = \frac{\binom{m}{k}\binom{N-m}{n-k}}{\binom{N}{n}}$$

28 / 70

James Wagner

Class 2

<!-- page 29 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Fisher's Exact Test

Let's look at an example table.

Disease

| | Yes | No | Row Total |
| :--- | :---: | :---: | :---: |
| Male | a | b | a+b |
| Female | c | d | c+d |
| Column Total | a+c | b+d | n |

In this case, we want to calculate the probability of the observed data or more extreme values occuring under the null hypothesis.

29 / 70
James Wagner
Class 2

<!-- page 30 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Fisher's Exact Test

If we fix the margins at $a+c$ and $a+b$, then what is the probability that if we selected $a+c$ persons they would be distributed as $a$ and $c$. We can use the hypergeometric distribution to calculate these probabilities.

$$
p = \frac{\binom{a+b}{a} \binom{c+d}{c}}{\binom{n}{a+c}} = \frac{(a+b)!(c+d)!(a+c)!(b+d)!}{a!b!c!d!n!}
$$

We look at the probability of the observed data and any other possible tables with stronger associations. This can be either one- or two-tailed.

30 / 70

James Wagner

Class 2

<!-- page 31 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Fisher's Exact Test

Let's look at a simple $2 \times 2$ case (from Heiberger and Holland).

| | Juvenile Delinquent | |
| :---: | :---: | :---: |
| | Yes | No |
| Glasses | 1 | 5 |
| No Glasses | 8 | 2 |

What is the probability that the table would be this lopsided if wearing glasses was unrelated to delinquency?

31 / 70
James Wagner
Class 2

<!-- page 32 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Fisher's Exact Test

The probability of this configuration of the data under the null hypothesis [what is $H_0$?] is:

$$
\frac{\binom{9}{1}\binom{7}{5}}{\binom{16}{6}} = 0.0236
$$

There are a few tables that are less likely under the null hypothesis.

For example, 9 persons without glasses are delinquents and 0 without glasses are.

32/70 $\quad$ James Wagner $\quad$ Class 2

<!-- page 33 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Fisher's Exact Test

These are all the possible tables. Why?

| glasses | 0 | | 1 | | 2 | | 3 | | 4 | | 5 | | 6 | |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| | del | no.del | del | no.del | del | no.del | del | no.del | del | no.del | del | no.del | del | no.del |
| glasses | 0 | 6 | 1 | 5 | 2 | 4 | 3 | 3 | 4 | 2 | 5 | 1 | 6 | 0 |
| no.glasses | 9 | 1 | 8 | 2 | 7 | 3 | 6 | 4 | 5 | 5 | 4 | 6 | 3 | 7 |

The tables have probability: 0.0009, 0.0236, 0.1573, 0.3671, 0.3304, 0.1101, 0.0105

Therefore, the total probability of the observed data or data even further from the null hypothesis if that hypothesis is true is $0.0236 + 0.0009 + 0.0105 = 0.0350$.

Therefore, we fail to accept the null hypothesis.

33 / 70
James Wagner
Class 2

<!-- page 34 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 2

Now let's look at the example in R. We have a *matrix* with our data:

```r
> glasses
           delinq non.del
glasses         1       5
no.glasses      8       2
```

34 / 70
James Wagner
Class 2

<!-- page 35 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 2

We can request Fisher's exact test with the following code:

```r
fisher.test(glasses)
```

Which produces the following output:

```
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

35 / 70  James Wagner  Class 2

<!-- page 36 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 2

Now let’s look at the example in SAS. We can request Fisher’s Exact test with the following code:

```sas
proc freq data=glasses order=data;
tables glasses*delinq /fisher ;
weight count;
run;
```

36 / 70

James Wagner

Class 2

<!-- page 37 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 2

Which produces the following output:

```
       Fisher’s Exact Test
----------------------------------
Cell (1,1) Frequency (F)         1
Left-sided Pr <= F          0.0245
Right-sided Pr >= F         0.9991

Table Probability (P)       0.0236
Two-sided Pr <= P           0.0350

         Sample Size = 16
```

37 / 70

James Wagner

Class 2

<!-- page 38 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 2

Another approach is to adopt a Bayesian perspective. Beta-binomial:

```r
# DATA
n1 <- 6  # glasses
y1 <- 1  # delinquents with glasses
n2 <- 10 # no glasses
y2 <- 8  # delingquents with no glasses

# SIMULATION
i <- 10000 # simulations
theta1 = rbeta(i, y1+1, (n1-y1)+1)
theta2 = rbeta(i, y2+1, (n2-y2)+1)
diff = theta1-theta2  # simulated diffs

# OUTPUT
print("Probability higher % delinquent with glasses than without:")
> print(mean(theta1>theta2))
[1] 0.0094
```

38 / 70
James Wagner
Class 2

<!-- page 39 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# OR and RR: Setup

| | Column | |
| :---: | :---: | :---: |
| **Row** | **1** | **2** |
| 1 | $n_{11}$ | $n_{12}$ |
| 2 | $n_{21}$ | $n_{22}$ |

39/70
James Wagner
Class 2

<!-- page 40 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Setup

| | Column | |
| :---: | :---: | :---: |
| **Row** | **1** | **2** |
| 1 | $\pi_{11}$ | $\pi_{12}$ |
| 2 | $\pi_{21}$ | $\pi_{22}$ |

In these tables, the columns are the response variable, and the rows are the independent variable.

40 / 70

James Wagner

Class 2

<!-- page 41 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Setup

Now, define a conditional probability based on the latter table:

$$\pi_{j|i} = \frac{\pi_{ij}}{\pi_{i+}} = \frac{\pi_{ij}}{\pi_{i1} + \pi_{i2}}$$

In words, conditional on being in row $i$, the proportion in column $j$ is $\pi_{j|i}$.

For example:

$$\pi_{1|2} = \frac{\pi_{21}}{\pi_{21} + \pi_{22}}$$

41 / 70
James Wagner
Class 2

<!-- page 42 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Setup: Example 3

| | Disease (Yes) | Disease (No) |
| :--- | :---: | :---: |
| **Male** | 0.15 | 0.35 |
| **Female** | 0.10 | 0.40 |

We want the conditional probability that you have disease given that you are male: $PR(D|M) = \pi_{1|1} = \frac{\pi_{11}}{\pi_{11}+\pi_{12}}.$

$$
PR(D|M) = \pi_{1|1} = \frac{0.15}{0.15+0.35} = 0.3
$$

42 / 70

James Wagner

Class 2

<!-- page 43 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Relative Risk

Now, define the relative risk.

$$\text{Relative Risk (Response Category 1)} = \frac{\pi_{1|1}}{\pi_{1|2}}$$

For example:

$$\frac{\pi_{1|1}}{\pi_{1|2}} = \frac{\Pr(D|M)}{\Pr(D|F)} = \frac{.3}{.2} = 1.5$$

43 / 70

James Wagner

Class 2

<!-- page 44 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Relative Risk

$$\text{Relative Risk (Response Category 2)} = \frac{\pi_{2|1}}{\pi_{2|2}}$$

For example:

$$\frac{\pi_{2|1}}{\pi_{2|2}} = \frac{\Pr(\bar{D}|M)}{\Pr(\bar{D}|F)} = \frac{.7}{.8} = 0.875$$

44 / 70

James Wagner

Class 2

<!-- page 45 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Relative Risk

An easy way to estimate the relative risk is:

$$\frac{n_{11}/n_{1+}}{n_{21}/n_{2+}}$$

The distribution of the relative risk is highly skewed. Therefore, it is better to estimate the variance on the log scale.

$$\hat{V}\left\{\ln\left(\frac{n_{11}/n_{1+}}{n_{21}/n_{2+}}\right)\right\} = \frac{1 - \frac{n_{11}}{n_{1+}}}{n_{11}} + \frac{1 - \frac{n_{21}}{n_{2+}}}{n_{21}} = \frac{\Pr(\bar{D}|M)}{n_{11}} + \frac{\Pr(\bar{D}|F)}{n_{21}}$$

This is the variance of the logarithm of the Relative Risk(Response Category 1).

45 / 70
James Wagner
Class 2

<!-- page 46 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# In-Class Problem

| | Disease | |
| :---: | :---: | :---: |
| | Yes | No |
| Male | 20 | 40 |
| Female | 30 | 30 |

What is the relative risk for men relative to women?
What is the variance of this estimate? Leave it on the log scale, $\hat{V}\left(\ln(\hat{RR})\right)$.

46 / 70
James Wagner
Class 2

<!-- page 47 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# In-Class Problem

| | Disease Yes | Disease No |
| :---: | :---: | :---: |
| Male | 20 | 40 |
| Female | 30 | 30 |

What is the relative risk for men relative to women? $\frac{20/60}{30/60} = \frac{.33}{.5} = 0.67$

What is the variance of this estimate? $\hat{V}\left(\ln(\hat{RR})\right) = \frac{3}{60}$

47/70

James Wagner

Class 2

<!-- page 48 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Odds Ratio

Within row 1 the *odds* (*not* odds ratio) that the response is in column 1 instead of column 2 is defined as:

$$Odds_1 = \frac{\pi_{1|1}}{\pi_{2|1}} = \frac{\pi_{11}}{\pi_{12}}$$

From our example, this could be written:

$$\frac{\Pr(D|M)}{\Pr(\bar{D}|M)} = \frac{\Pr(D|M)}{1 - \Pr(D|M)}$$

Continuing the example, the odds that a man will have the disease are $\frac{.3}{1-.3} = .43$. For women, this odds are $\frac{.2}{1-.2} = .25$

48 / 70
James Wagner
Class 2

<!-- page 49 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Odds Ratio

Those are the odds. The ratio of the odds is called the *odds ratio*.

$$\theta = \frac{\pi_{1|1}/\pi_{2|1}}{\pi_{1|2}/\pi_{2|2}}$$

Remember that $\pi_{1|1} = \frac{\pi_{11}}{\pi_{11}+\pi_{12}}$. So we can also write it in the following manner:

$$\theta = \frac{\frac{\pi_{11}}{\pi_{11}+\pi_{12}}/\frac{\pi_{12}}{\pi_{11}+\pi_{12}}}{\frac{\pi_{21}}{\pi_{21}+\pi_{22}}/\frac{\pi_{22}}{\pi_{21}+\pi_{22}}} = \frac{\pi_{11}/\pi_{12}}{\pi_{21}/\pi_{22}} = \frac{\pi_{11}\pi_{22}}{\pi_{21}\pi_{12}}$$

Hence the name *cross-product ratio*.

49 / 70
James Wagner
Class 2

<!-- page 50 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Odds Ratio Misinterpretation Example

Take care with interpretation. Here is a headline from a newspaper in the UK:

# Mail Online

**Home | News | U.S. | Sport | TV&Showbiz | Femail | Health | Science | Money | RightMind**

*Health Home* | Health Directory | Health Boards | Diets | MyDish Recipe Finder

## Statins can weaken muscles and joints: Cholesterol drug raises risk of problems by up to 20 per cent

* **Statins are the most widely prescribed drugs in Britain**
* **However, many complain of muscle pain and joint weakness**

By JENNY HOPE

**PUBLISHED:** 22:42, 3 June 2013 | **UPDATED:** 00:00, 4 June 2013

50 / 70

James Wagner

Class 2

<!-- page 51 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Odds Ratio Misinterpretation Example

David Spiegelhalter:
"Unfortunately, the ‘20%’ is factually incorrect - the study on which this story is based claims that taking statins increased the risk of muscle problems from 85% to 87%."

Odds without statins: $\frac{0.85}{0.15} = 5.67$
Odds with statins: $\frac{0.87}{0.13} = 6.69$
Odds ratio: $\frac{6.69}{5.67} = 1.18$

Odds ratio misinterpreted as increase in probability.

51 / 70 | James Wagner | Class 2

<!-- page 52 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Odds Ratio

Characteristics of the Odds Ratio

1. $\theta = 1$ is independence
2. $\theta > 1$ subjects in row 1 are more likely to have the response
3. $\theta < 1$ subjects in row 2 are more likely to have the response
4. Values farther away from 1 indicate a stronger relationship
5. $ln(\theta) = 0$ is independence since $ln(1) = 0$
6. $ln(\theta)$ is symmetric around 0

52/70

James Wagner

Class 2

<!-- page 53 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Odds Ratio

We estimate the odds ratio using:

$$
\hat{\theta} = \frac{n_{11}n_{22}}{n_{21}n_{12}}
$$

The variance of $\ln(\hat{\theta})$ can be estimated as:

$$
\hat{V}\left\{\ln\left(\hat{\theta}\right)\right\} = \frac{1}{n_{11}} + \frac{1}{n_{12}} + \frac{1}{n_{21}} + \frac{1}{n_{22}}
$$

53 / 70
James Wagner
Class 2

<!-- page 54 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 4

| | | Physicians Health Study Data | | |
| :--- | :---: | :---: | :---: | :---: |
| | | Myocardial Infarction | | |
| | Heart Attack | No Attack | Total | $P_{i+}$ |
| Placebo | 189 | 10845 | 11034 | 0.017 |
| Aspirin | 104 | 10933 | 11037 | 0.009 |

The relative risk of heart attack is $\frac{189/11034}{104/11037} = \frac{0.017}{0.009} = 1.82$.

The odds ratio is:

$$\hat{\theta} = \frac{(189)(10933)}{(104)(10845)} = 1.83$$

54 / 70
James Wagner
Class 2

<!-- page 55 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 4

The variance is determined for $\ln(\hat{\theta}) = 0.60543771$.

$$\hat{V} \left\{ \ln \left( \hat{\theta} \right) \right\} = \frac{1}{189} + \frac{1}{104} + \frac{1}{10845} + \frac{1}{10933} = 0.01509006$$

55 / 70

James Wagner

Class 2

<!-- page 56 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 4

Form the confidence interval with care. Do all the work on the logarithmic scale!

1. $\sqrt{V \left\{ \ln \left( \hat{\theta} \right) \right\}} = 0.12284.$
2. $1.96 * 0.12284 = .2408.$
3. $0.6054 - 0.2408 = .3646$ and $0.6054 + 0.2408 = 0.8462$. This is the 95% confidence interval on the logarithmic scale.
4. Exponentiate to get back to the scale of $\hat{\theta}$. Therefore, $\left( e^{0.365}, e^{0.846} \right) = (1.440, 2.331)$.

56 / 70

James Wagner

Class 2

<!-- page 57 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 4

We can do this work in R. Here I'm using the *epiR* package:

```r
library(epiR)

myocard<-matrix(data=c(189,104,10845,10933),nrow=2)
myocard<-as.table(myocard)

epi.2by2(myocard)
```

57 / 70

James Wagner

Class 2

<!-- page 58 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 4

Which produces the following output:

```r
             Disease +    Disease -      Total    Inc risk *        Odds
Exposed +          189        10845      11034         1.713     0.01743
Exposed -          104        10933      11037         0.942     0.00951
Total              293        21778      22071         1.328     0.01345

Point estimates and 95 % CIs:
---------------------------------------------------------
Inc risk ratio                         1.82 (1.43, 2.31)
Odds ratio                             1.83 (1.44, 2.33)
Attrib risk *                          0.77 (0.47, 1.07)
Attrib risk in population *            0.39 (0.15, 0.62)
Attrib fraction in exposed (%)         44.99 (30.22, 56.63)
Attrib fraction in population (%)      29.02 (17.25, 39.12)
---------------------------------------------------------
 * Cases per 100 population units
```

58 / 70
James Wagner
Class 2

<!-- page 59 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 4

We can do the same thing in SAS using `PROC FREQ`:

```sas
proc freq data=myocard order=data;
tables aspirin*myocard / cmh;
weight count;
run;
```

59 / 70

James Wagner

Class 2

<!-- page 60 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Example 4

Which produces the following output:

```text
            Estimates of the Common Relative Risk (Row1/Row2)

Type of Study     Method                  Value     95% Confidence Limits
-------------------------------------------------------------------------
Case-Control      Mantel-Haenszel        1.8321       1.4400       2.3308
  (Odds Ratio)    Logit                  1.8321       1.4400       2.3308

Cohort            Mantel-Haenszel        1.8178       1.4330       2.3059
  (Col1 Risk)     Logit                  1.8178       1.4330       2.3059

Cohort            Mantel-Haenszel        0.9922       0.9892       0.9953
  (Col2 Risk)     Logit                  0.9922       0.9892       0.9953

                        Total Sample Size = 22071
```

60 / 70
James Wagner
Class 2

<!-- page 61 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Relationship between Relative Risk and Odds Ratio

Remember the table from earlier:

Disease

| | Yes | No | Row Total |
| :---: | ---: | ---: | ---: |
| Male | a | b | a+b |
| Female | c | d | c+d |
| Column Total | a+c | b+d | n |

61 / 70 James Wagner Class 2

<!-- page 62 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Relationship between Relative Risk and Odds Ratio

We can write the relative risk as:

$$RR = \frac{a/(a + b)}{c/(c + d)}$$

If $a$ is small, then $a/(a + b)$ is approximately $a/b$. The same applies to the denominator.

$$RR = \frac{a/(a + b)}{c/(c + d)} \approx \frac{a/b}{c/d} = \frac{ad}{bc} = OR$$

But only if the condition is rare!

62 / 70

James Wagner

Class 2

<!-- page 63 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Ordinal Variables

We have been ignoring any possible ordering of the categories.

The methods here assume nominal categorical variables.

Some variables contain information about order: ordinal variables.

The tests we have described may be helpful in determining independence for ordinal variables.

Still, ignoring the ordering in the data is a loss of information. Decrease of efficiency. There are tests that use knowledge of the ordering.

63 / 70

James Wagner

Class 2

<!-- page 64 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

Log-linear models are a useful tool for analyzing data in contingency tables.

Possible to explore relationships as was done with Pearsons $X^2$. But more flexible!

Today, we will just look at how these models relate to other methods we have seen for discrete data.

64 / 70
James Wagner
Class 2

<!-- page 65 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

Recall that for a Two-Way Table, we wrote the probability mass function in this way:

$$P(\mathbf{n}; \pi) = \frac{n!}{\prod_{i=1}^I \prod_{j=1}^J n_{ij}!} \prod_{i=1}^I \prod_{j=1}^J \pi_{ij}^{n_{ij}}$$

65 / 70

James Wagner

Class 2

<!-- page 66 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

We could rewrite this such that the cell probabilities are modeled as counts:

$$
\begin{aligned}
P(\mathbf{n}; \pi) &= \frac{n!}{\prod_{i=1}^{I} \prod_{j=1}^{J} n_{ij}!} \prod_{i=1}^{I} \prod_{j=1}^{J} \left(\frac{m_{ij}}{n}\right)^{n_{ij}} = \frac{n!}{\prod_{i=1}^{I} \prod_{j=1}^{J} n_{ij}!} \prod_{i=1}^{I} \prod_{j=1}^{J} m_{ij}^{n_{ij}} n^{-n_{ij}} \\
&= \frac{n! n^{-n}}{\prod_{i=1}^{I} \prod_{j=1}^{J} n_{ij}!} \prod_{i=1}^{I} \prod_{j=1}^{J} m_{ij}^{n_{ij}}
\end{aligned}
$$

66 / 70

James Wagner

Class 2

<!-- page 67 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

Under the independence hypothesis, we can write the *expected* counts as:

$$m_{ij} = n\pi_{i+}\pi_{+j} = n \left( \frac{m_{i+}}{n} \right) \left( \frac{m_{+j}}{n} \right) = n^{-1}m_{i+}m_{+j}$$

This says that the expected cell counts are proportional to the product of the marginal counts. With a little algebra, we can take logarithms of the RHS:

$$\ln(m_{ij}) = -\ln(n) + \ln(m_{i+}) + \ln(m_{+j})$$

67/70
James Wagner
Class 2

<!-- page 68 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

The latter equation looks like a regression model with main effects and no interaction terms.

Again, under *independence*, that model is correct. An interaction term implies lack of independence. Please explain why?

Typically, these models are written in this form:

$$
\ln(m_{ij}) = \lambda + \lambda_i^X + \lambda_j^Y
$$

68 / 70

James Wagner

Class 2

<!-- page 69 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

They are subject to the constraint that they are deviations around a grand mean which must sum to 0 (effect coding – -1 1):

$$\ln \left( n \prod_{i=1}^I \pi_{i+} \right) = \sum_{i=1}^I \lambda_i^X = 0$$

There are $1 + (I - 1) + (J - 1) = I + J - 1$ free parameters.

69 / 70
James Wagner
Class 2

<!-- page 70 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

That is the model under the assumption of independence. We can add interactions. This model will have perfect prediction (Expected=Observed in every cell) and is called the *saturated* model.

$$
\ln(m_{ij}) = \lambda + \lambda_i^X + \lambda_j^Y + \lambda_{ij}^{XY}
$$

There is an additional restriction imposed:

$$
\sum_{i=1}^I \lambda_{ij}^{XY} = \sum_{j=1}^J \lambda_{ij}^{XY} = 0
$$

The saturated model has 1 free parameter for $\lambda$, $I - 1$ free parameters for row main effects, $J - 1$ free parameters for column main effects, and $(I - 1)(J - 1)$ free parameters for interactions. For example, 1 interaction term in a $2 \times 2$ table.

$$
I + J - 1 + (I - 1)(J - 1) = IJ.
$$

70 / 70
James Wagner
Class 2

<!-- page 71 -->

Two-Way Tables
Odds Ratios and Relative Risk
Log-Linear Models

# Log-Linear

The general approach for log-linear model is to fit the saturated model and then eliminate terms to see if the model still fits.

For example, eliminating the $XY$ interaction term in the model above implies independence.

More on this in the future.

71/70
James Wagner
Class 2
