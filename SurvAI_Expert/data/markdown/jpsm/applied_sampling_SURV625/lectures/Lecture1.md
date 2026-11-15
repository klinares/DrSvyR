---
id: "jpsm/applied_sampling_SURV625/lectures/Lecture1"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "lecture"
title: "SurvMeth/Surv 625: Applied Sampling"
original: "applied_sampling_SURV625/lectures/Lecture1.pdf"
pages: 60
sha256: "440a10f346aa33e417c643551c390ab40d9ddbab119fd0e2537f425eeb3abadf"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:42"
---

<!-- page 1 -->

# SurvMeth/Surv 625: Applied Sampling

Yajuan Si

Research Associate Professor
Survey Research Center
Institute for Social Research
University of Michigan, Ann Arbor

1/8/25

<!-- page 2 -->

Course introduction

# Section 1

## Course introduction

<!-- page 3 -->

Course introduction

# SurvMeth/Surv 625: Applied sampling

* *Lohr: The design is by far the most important aspect of any survey: No amount of statistical analysis can compensate for a badly designed survey.*

<!-- page 4 -->

Course introduction

# SurvMeth/Surv 625: Applied sampling

* *Lohr: The design is by far the most important aspect of any survey: No amount of statistical analysis can compensate for a badly designed survey.*
* *Deming: Sampling is not mere substitution of a partial coverage for a total coverage. Sampling is the science and art of controlling and measuring the reliability of useful statistical information through the theory of probability.*

<!-- page 5 -->

Course introduction

# SurvMeth/Surv 625: Applied sampling

- *Lohr: The design is by far the most important aspect of any survey: No amount of statistical analysis can compensate for a badly designed survey.*

- *Deming: Sampling is not mere substitution of a partial coverage for a total coverage. Sampling is the science and art of controlling and measuring the reliability of useful statistical information through the theory of probability.*

- Applied Sampling is an applied statistical methods course concerned almost exclusively with the design of data collection. This course will cover the main techniques used in sampling practice.

<!-- page 6 -->

Course introduction

# SurvMeth/Surv 625: Applied sampling

* *Lohr: The design is by far the most important aspect of any survey: No amount of statistical analysis can compensate for a badly designed survey.*

* *Deming: Sampling is not mere substitution of a partial coverage for a total coverage. Sampling is the science and art of controlling and measuring the reliability of useful statistical information through the theory of probability.*

* Applied Sampling is an applied statistical methods course concerned almost exclusively with the design of data collection. This course will cover the main techniques used in sampling practice.

* The course syllabus:
  Syllabus_SurvMeth625_Winter2025_YajuanSi.pdf

<!-- page 7 -->

Course introduction

# Design

* Research design
  * Experiments: Control of confounders or randomization of intervention
  * Quasi-experimental: Observational
  * Survey samples: Observational

<!-- page 8 -->

Course introduction

# Design

* Research design
    * Experiments: Control of confounders or randomization of intervention
    * Quasi-experimental: Observational
    * Survey samples: Observational
* Design characteristics
    * Realism
    * Randomization
    * Representation
* Example studies with good or bad designs

<!-- page 9 -->

Course introduction

# Design vs. analysis

* Sampling techniques (simple random sample, stratified, cluster sampling. etc.)
* Complex design: Multistage, area sampling
* Sampling error: sampling variance estimation
* Nonsampling errors
* Sampling **implementation, inference, and projection**

<!-- page 10 -->

Course introduction

# Sample surveys

Define problem & population

Design instrument --> Specify procedures --> Recruit, hire, train staff

Design sample ----> Develop sampling frame -> Select sample

Collect data ---> Process data --> Analyze & Report

<!-- page 11 -->

Course introduction

# Finite population: Valliant (2020)

- $U$ = target population
- $F_{pc}$ = potentially covered; $F_c$ = actually covered
- $U - F_{pc}$ = not covered at all
- $s$ = sample

<!-- page 12 -->

Course introduction

# Vocabulary

* Observation unit/element
* Target population
* Census
* Sample
* Sampled population
* Sampling unit
* Sampling frame
* Coverage: under/over-coverage
* Response: nonresponse

<!-- page 13 -->

Course introduction

# Vocabulary

* Observation unit/element
* Target population
* Census
* Sample
* Sampled population
* Sampling unit
* Sampling frame
* Coverage: under/over-coverage
* Response: nonresponse
* Inclusion: selected and responded
* Non-probability sampling
* Sampling error: resulting from taking one random sample instread of examining the whole population
  * Margin of error
* Nonsampling error: any errors that cannot be attributed to the sample-to-sample variability
  * Selection bias
  * Measurement error

<!-- page 14 -->

Course introduction

# Statistics

* Statistics: <u>population quantity of interest</u> $t$, e.g., population total, mean, percentiles, regression coefficient, etc.

<!-- page 15 -->

Course introduction

# Statistics

* Statistics: <u>population quantity of interest</u> $t$, e.g., population total, mean, percentiles, regression coefficient, etc.
* **Sampling distribution**: the distribution of different values of the statistics $\hat{t}$ obtained by the process of taking all possible samples from the population, i.e,, repeated sampling

<!-- page 16 -->

Course introduction

# Statistics

* Statistics: <u>population quantity of interest</u> $t$, e.g., population total, mean, percentiles, regression coefficient, etc.
* **Sampling distribution**: the distribution of different values of the statistics $\hat{t}$ obtained by the process of taking all possible samples from the population, i.e,, repeated sampling
* (Design-based) Randomization theory: *the population data are fixed, and the sampling inclusion indicators are random variables.*

<!-- page 17 -->

Course introduction

# Statistics

* Statistics: <u>population quantity of interest</u> $t$, e.g., population total, mean, percentiles, regression coefficient, etc.
* **Sampling distribution**: the distribution of different values of the statistics $\hat{t}$ obtained by the process of taking all possible samples from the population, i.e,, repeated sampling
* (Design-based) Randomization theory: *the population data are fixed, and the sampling inclusion indicators are random variables.*
    * The probabilities of selection for units in the samples give the sampling distribution of the statistics $\hat{t}$

<!-- page 18 -->

Course introduction

# Statistics

* Statistics: <u>population quantity of interest</u> $t$, e.g., population total, mean, percentiles, regression coefficient, etc.
* **Sampling distribution**: the distribution of different values of the statistics $\hat{t}$ obtained by the process of taking all possible samples from the population, i.e,, repeated sampling
* (Design-based) Randomization theory: *the population data are fixed, and the sampling inclusion indicators are random variables.*
  * The probabilities of selection for units in the samples give the sampling distribution of the statistics $\hat{t}$
* Model-based sampling inference: the population is a set of random variables following some probability distribution, and the actual sample values are realizations of these random variables. *The sample data are fixed, and the population distribution is unknown..*

<!-- page 19 -->

Course introduction

# Probability: Review

1. A random variable $Y$ takes on different values in different samples

<!-- page 20 -->

Course introduction

# Probability: Review

1. A random variable $Y$ takes on different values in different samples

2. The probability distribution of $Y$ depicts the set of possible values $y$ and the probability of each value occurring $P(Y = y)$, where the quantity $y$ is called a realization of $Y$

<!-- page 21 -->

Course introduction

# Probability: Review

1. A random variable $Y$ takes on different values in different samples
2. The probability distribution of $Y$ depicts the set of possible values $y$ and the probability of each value occurring $P(Y = y)$, where the quantity $y$ is called a realization of $Y$
3. The expectation of $Y$ is defined as $E(Y) = \sum_{y} y * P(Y = y)$

<!-- page 22 -->

Course introduction

# Probability: Review

1. A random variable $Y$ takes on different values in different samples

2. The probability distribution of $Y$ depicts the set of possible values $y$ and the probability of each value occurring $P(Y = y)$, where the quantity $y$ is called a realization of $Y$

3. The expectation of $Y$ is defined as $E(Y) = \sum_y y * P(Y = y)$

4. The variance of $Y$ is: $V(Y) = E[\{Y - E(Y)\}^2] = E(Y^2) - [E(Y)]^2$

<!-- page 23 -->

Course introduction

# Probability: Review

1. A random variable $Y$ takes on different values in different samples
2. The probability distribution of $Y$ depicts the set of possible values $y$ and the probability of each value occurring $P(Y = y)$, where the quantity $y$ is called a realization of $Y$
3. The expectation of $Y$ is defined as $E(Y) = \sum_y y * P(Y = y)$
4. The variance of $Y$ is: $V(Y) = E[\{Y - E(Y)\}^2] = E(Y^2) - [E(Y)]^2$
5. The covariance of two random variables $X$ and $Y$:
   $Cov(X, Y) = E[\{X - E(X)\}\{Y - E(Y)\}] = E(XY) - E(X)E(Y)$

<!-- page 24 -->

Course introduction

# Probability: Review

1. A random variable $Y$ takes on different values in different samples
2. The probability distribution of $Y$ depicts the set of possible values $y$ and the probability of each value occurring $P(Y = y)$, where the quantity $y$ is called a realization of $Y$
3. The expectation of $Y$ is defined as $E(Y) = \sum_{y} y * P(Y = y)$
4. The variance of $Y$ is: $V(Y) = E[\{Y - E(Y)\}^2] = E(Y^2) - [E(Y)]^2$
5. The covariance of two random variables $X$ and $Y$:
   $Cov(X, Y) = E[\{X - E(X)\}\{Y - E(Y)\}] = E(XY) - E(X)E(Y)$
6. The correlation of two random variables $X$ and $Y$:
   $Corr(X, Y) = \frac{Cov(X, Y)}{\sqrt{V(X)V(Y)}}$

<!-- page 25 -->

Course introduction

# Probability: Review

1. A random variable $Y$ takes on different values in different samples
2. The probability distribution of $Y$ depicts the set of possible values $y$ and the probability of each value occurring $P(Y = y)$, where the quantity $y$ is called a realization of $Y$
3. The expectation of $Y$ is defined as $E(Y) = \sum_y y * P(Y = y)$
4. The variance of $Y$ is: $V(Y) = E[\{Y - E(Y)\}^2] = E(Y^2) - [E(Y)]^2$
5. The covariance of two random variables $X$ and $Y$:
   $Cov(X, Y) = E[\{X - E(X)\}\{Y - E(Y)\}] = E(XY) - E(X)E(Y)$
6. The correlation of two random variables $X$ and $Y$:
   $Corr(X, Y) = \frac{Cov(X, Y)}{\sqrt{V(X)V(Y)}}$
7. The coefficient of variation is defined as $CV(Y) = \frac{V(Y)}{E(Y)}$, for $E(Y) \neq 0$.

<!-- page 26 -->

Course introduction

# Probability: Review cont.

8. The joint probability of two occurring event: $P(X = x, Y = y)$

<!-- page 27 -->

Course introduction

# Probability: Review cont.

8. The joint probability of two occurring event: $P(X = x, Y = y)$

9. Conditional probability adjusts the event probability given a related event occurred: $P(Y = y \mid X = x) = \frac{P(X=x, Y=y)}{P(X=x)}$

<!-- page 28 -->

Course introduction

# Probability: Review cont.

8. The joint probability of two occurring event: $P(X = x, Y = y)$

9. Conditional probability adjusts the event probability given a related event occurred: $P(Y = y \mid X = x) = \frac{P(X=x, Y=y)}{P(X=x)}$

10. The conditional expectation of $Y$ given $X = x$ is $E(Y \mid X = x) = \sum_y y * P(Y = y \mid X = x)$

<!-- page 29 -->

Course introduction

# Probability: Review cont.

8. The joint probability of two occurring event: $P(X = x, Y = y)$

9. Conditional probability adjusts the event probability given a related event occurred: $P(Y = y \mid X = x) = \frac{P(X=x, Y=y)}{P(X=x)}$

10. The conditional expectation of $Y$ given $X = x$ is
$E(Y \mid X = x) = \sum_y y * P(Y = y \mid X = x)$

11. The conditional variance of $Y$ given $X = x$ is
$V(Y \mid X = x) = \sum_y [y - E(Y \mid X = x)]^2 * P(Y = y \mid X = x)$

<!-- page 30 -->

Course introduction

# Probability: Review cont.

8. The joint probability of two occurring event: $P(X = x, Y = y)$

9. Conditional probability adjusts the event probability given a related event occurred: $P(Y = y \mid X = x) = \frac{P(X = x, Y = y)}{P(X = x)}$

10. The conditional expectation of $Y$ given $X = x$ is $E(Y \mid X = x) = \sum_y y * P(Y = y \mid X = x)$

11. The conditional variance of $Y$ given $X = x$ is $V(Y \mid X = x) = \sum_y [y - E(Y \mid X = x)]^2 * P(Y = y \mid X = x)$

12. Successive conditioning: $E(Y) = E[E(Y \mid X)]$

<!-- page 31 -->

Course introduction

# Probability: Review cont.

8. The joint probability of two occurring event: $P(X = x, Y = y)$

9. Conditional probability adjusts the event probability given a related event occurred: $P(Y = y \mid X = x) = \frac{P(X=x, Y=y)}{P(X=x)}$

10. The conditional expectation of $Y$ given $X = x$ is $E(Y \mid X = x) = \sum_y y * P(Y = y \mid X = x)$

11. The conditional variance of $Y$ given $X = x$ is $V(Y \mid X = x) = \sum_y [y - E(Y \mid X = x)]^2 * P(Y = y \mid X = x)$

12. Successive conditioning: $E(Y) = E[E(Y \mid X)]$

13. Total variability $V(Y) = V[E(Y \mid X)] + E[V(Y \mid X)] = \text{between.ave} + \text{ave.within}$

<!-- page 32 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, \dots, Y_N$

<!-- page 33 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, \dots, Y_N$
- Population total: $t = Y = Y_1 + Y_2 + \dots + Y_N$

<!-- page 34 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, \dots, Y_N$
- Population total: $t = Y = Y_1 + Y_2 + \dots + Y_N$
- Population mean: $\bar{Y} = t / N$

<!-- page 35 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, \dots, Y_N$
- Population total: $t = Y = Y_1 + Y_2 + \dots + Y_N$
- Population mean: $\bar{Y} = t/N$
- Population element variance:

$$
S^2 = \frac{1}{N} \sum_{i=1}^N (Y_i - \bar{Y})^2 = \frac{1}{N} (\sum_{i=1}^N Y_i^2 - t^2/N) \tag{1}
$$

<!-- page 36 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, \dots, Y_N$
- Population total: $t = Y = Y_1 + Y_2 + \dots + Y_N$
- Population mean: $\bar{Y} = t/N$
- Population element variance:
$$
S^2 = \frac{1}{N} \sum_{i=1}^N (Y_i - \bar{Y})^2 = \frac{1}{N} (\sum_{i=1}^N Y_i^2 - t^2/N) \tag{1}
$$
- Standard deviation: S

<!-- page 37 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, \dots, Y_N$
- Population total: $t = Y = Y_1 + Y_2 + \dots + Y_N$
- Population mean: $\bar{Y} = t/N$
- Population element variance:

$$
S^2 = \frac{1}{N} \sum_{i=1}^N (Y_i - \bar{Y})^2 = \frac{1}{N} (\sum_{i=1}^N Y_i^2 - t^2/N) \tag{1}
$$

- Standard deviation: S
- For a binary $Y_i$

<!-- page 38 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, ..., Y_N$
- Population total: $t = Y = Y_1 + Y_2 + \cdots + Y_N$
- Population mean: $\bar{Y} = t/N$
- Population element variance:

$$
S^2 = \frac{1}{N} \sum_{i=1}^N (Y_i - \bar{Y})^2 = \frac{1}{N} (\sum_{i=1}^N Y_i^2 - t^2/N) \tag{1}
$$

- Standard deviation: S
- For a binary $Y_i$
  - Population proportional: $P = t/N$

<!-- page 39 -->

Course introduction

# Notation: Population

- A population of $N$ elements: $Y_1, ..., Y_N$
- Population total: $t = Y = Y_1 + Y_2 + \cdots + Y_N$
- Population mean: $\bar{Y} = t/N$
- Population element variance:

$$
S^2 = \frac{1}{N} \sum_{i=1}^N (Y_i - \bar{Y})^2 = \frac{1}{N} (\sum_{i=1}^N Y_i^2 - t^2/N) \tag{1}
$$

- Standard deviation: S
- For a binary $Y_i$
  - Population proportional: $P = t/N$
  - Population element variance

$$
S^2 = \frac{N}{N-1} P(1-P) \tag{2}
$$

<!-- page 40 -->

Course introduction

# Notation: Population

* A population of $N$ elements: $Y_1, ..., Y_N$
* Population total: $t = Y = Y_1 + Y_2 + \dots + Y_N$
* Population mean: $\bar{Y} = t/N$
* Population element variance:

$$
S^2 = \frac{1}{N} \sum_{i=1}^N (Y_i - \bar{Y})^2 = \frac{1}{N} (\sum_{i=1}^N Y_i^2 - t^2/N) \tag{1}
$$

* Standard deviation: S
* For a binary $Y_i$
  * Population proportional: $P = t/N$
  * Population element variance

$$
S^2 = \frac{N}{N - 1} P(1 - P) \tag{2}
$$

<!-- page 41 -->

Course introduction

# Notation: Sample

* **One** sample of $n$ elements: $y_1, y_2, \ldots, y_n$

<!-- page 42 -->

Course introduction

# Notation: Sample

* **One** sample of $n$ elements: $y_1, y_2, \ldots, y_n$
* Sample total: $t = y_1 + y_2 + \cdots + y_n$

<!-- page 43 -->

Course introduction

# Notation: Sample

* **One** sample of $n$ elements: $y_1, y_2, \ldots, y_n$
* Sample total: $t = y_1 + y_2 + \cdots + y_n$
* Sample mean: $\bar{y} = t/n$

<!-- page 44 -->

Course introduction

# Notation: Sample

* **One** sample of $n$ elements: $y_1, y_2, \ldots, y_n$
* Sample total: $t = y_1 + y_2 + \cdots + y_n$
* Sample mean: $\bar{y} = t / n$
* Sample element variance: $s^2 = \frac{1}{n-1} \sum_{i=1}^n (y_i - \bar{y})^2 \doteq \widehat{S}^2$

<!-- page 45 -->

Course introduction

# Notation: Sample

* **One** sample of $n$ elements: $y_1, y_2, \ldots, y_n$
* Sample total: $t = y_1 + y_2 + \cdots + y_n$
* Sample mean: $\bar{y} = t / n$
* Sample element variance: $s^2 = \frac{1}{n-1} \sum_{i=1}^n (y_i - \bar{y})^2 \doteq \widehat{S}^2$
* Sample fraction: $f = n / N$

<!-- page 46 -->

Course introduction

# Notation: Sample

* **One** sample of $n$ elements: $y_1, y_2, \ldots, y_n$
* Sample total: $t = y_1 + y_2 + \cdots + y_n$
* Sample mean: $\bar{y} = t / n$
* Sample element variance: $s^2 = \frac{1}{n - 1} \sum_{i=1}^n (y_i - \bar{y})^2 \doteq \widehat{S}^2$
* Sample fraction: $f = n / N$
* Finite population coeffection factor: $fpc = 1 - f$

<!-- page 47 -->

Course introduction

# Notation: Sample

* **One** sample of $n$ elements: $y_1, y_2, \ldots, y_n$
* Sample total: $t = y_1 + y_2 + \cdots + y_n$
* Sample mean: $\bar{y} = t/n$
* Sample element variance: $s^2 = \frac{1}{n-1} \sum_{i=1}^n (y_i - \bar{y})^2 \doteq \widehat{S}^2$
* Sample fraction: $f = n/N$
* Finite population coeffection factor: $fpc = 1 - f$
* These are the calculated/observed summary statistics based on the one sample dataset

<!-- page 48 -->

Course introduction

# Sampling inference

* Denote the selection probability for one sample $s$ as $P(s)$ and obtain the sample estimate $\widehat{t}_s$

<!-- page 49 -->

Course introduction

# Sampling inference

* Denote the selection probability for one sample $s$ as $P(s)$ and obtain the sample estimate $\widehat{t}_s$

* Expectation: the mean of the sampling distribution of $\widehat{t}$: $E(\widehat{t}) = \sum_{all\ possible\ samples\ s} \widehat{t}_s P(s)$.

<!-- page 50 -->

Course introduction

# Sampling inference

- Denote the selection probability for one sample $s$ as $P(s)$ and obtain the sample estimate $\hat{t}_s$

- Expectation: the mean of the sampling distribution of $\hat{t}$: $E(\hat{t}) = \sum_{all\ possible\ samples\ s} \hat{t}_s P(s).$

- Variance: $V(\hat{t}) = E[(\hat{t} - E(\hat{t}))^2] = \sum_s (\hat{t}_s - E(\hat{t}))^2 P(s)$

<!-- page 51 -->

Course introduction

# Sampling inference

- Denote the selection probability for one sample $s$ as $P(s)$ and obtain the sample estimate $\hat{t}_s$

- Expectation: the mean of the sampling distribution of $\hat{t}$: $E(\hat{t}) = \sum_{\text{all possible samples } s} \hat{t}_s P(s)$.

- Variance: $V(\hat{t}) = E[(\hat{t} - E(\hat{t}))^2] = \sum_s (\hat{t}_s - E(\hat{t}))^2 P(s)$

- Standard error: $SE(\hat{t}) = \sqrt{V(\hat{t})}$, i.e., the standard deviation of the sampling distribution of $\hat{t}$

<!-- page 52 -->

Course introduction

# Sampling inference

- Denote the selection probability for one sample $s$ as $P(s)$ and obtain the sample estimate $\hat{t}_s$
- Expectation: the mean of the sampling distribution of $\hat{t}$: $E(\hat{t}) = \sum_{all\ possible\ samples\ s} \hat{t}_s P(s)$.
- Variance: $V(\hat{t}) = E[(\hat{t} - E(\hat{t}))^2] = \sum_s (\hat{t}_s - E(\hat{t}))^2 P(s)$
- Standard error: $SE(\hat{t}) = \sqrt{V(\hat{t})}$, i.e., the standard deviation of the sampling distribution of $\hat{t}$
- Confidence interval: $CI(s) = [low_s, up_s]$, if we repeatedly take samples from the population, construct a 95% CI for each possible sample, we expect 95% of the resulting intervals to include the true value, i.e., a 95% chance that the sample containing the true value

<!-- page 53 -->

Course introduction

# Quality measure

* Bias: the difference between the expectation and the true value $Bias(\widehat{t}) = E(\widehat{t}) - t$.

<!-- page 54 -->

Course introduction

# Quality measure

- Bias: the difference between the expectation and the true value
  $Bias(\hat{t}) = E(\hat{t}) - t$.

- Mean squared error:
  $MSE(\hat{t}) = E[(\hat{t} - t)^2] = E[(\hat{t} - E(\hat{t}) + E(\hat{t}) - t)^2] = V(\hat{t}) + Bias^2(\hat{t})$
  standard deviation

<!-- page 55 -->

Course introduction

# Quality measure

* Bias: the difference between the expectation and the true value $Bias(\hat{t}) = E(\hat{t}) - t$.

* Mean squared error:
  $MSE(\hat{t}) = E[(\hat{t}-t)^2] = E[(\hat{t}-E(\hat{t})+E(\hat{t})-t)^2] = V(\hat{t}) + Bias^2(\hat{t})$
  standard deviation

* An estimator $\hat{t}$ of $t$ is **unbiased** if $E(\hat{t}) = t$, **precise** if $V(\hat{t})$ is small, and **accurate** if $MSE(\hat{t})$ is small and the CI coverage probability is close to the nominal level.

<!-- page 56 -->

Course introduction

# Quality measure

* Bias: the difference between the expectation and the true value $Bias(\hat{t}) = E(\hat{t}) - t$.

* Mean squared error:
  $MSE(\hat{t}) = E[(\hat{t}-t)^2] = E[(\hat{t}-E(\hat{t})+E(\hat{t})-t)^2] = V(\hat{t}) + Bias^2(\hat{t})$
  standard deviation

* An estimator $\hat{t}$ of $t$ is **unbiased** if $E(\hat{t}) = t$, **precise** if $V(\hat{t})$ is small, and **accurate** if $MSE(\hat{t})$ is small and the CI coverage probability is close to the nominal level.

* Statistical inference validity assessment calculates bias, variance, MSE and CI.

<!-- page 57 -->

Course introduction

# Lohr Example 2.6

```r
library(survey)
library(sampling)
library(SDAResources)
library(tidyverse)
data(agpop)  ## Load the data set agpop
N <- nrow(agpop)
N  ## 3078 observations
```

```
[1] 3078
```

```r
## Select an SRS of size n=300 from agpop
set.seed(8126834)
index <- srswor(300,N)
## each unit k is associated with index 1 or 0, with 1 indicating selection
index[1:10]
```

```
 [1] 0 0 0 1 0 0 0 0 0 0
```

```r
## agsrs is an SRS with size 300 selected from agpop
## extract the sampled units from the data frame containing the population
agsrs<- getdata(agpop,index)
```

<!-- page 58 -->

Course introduction

# Population distribution

Population data distribution

Sample data distribution

<!-- page 59 -->

Course introduction

# Sampling distribution

**Central limit theorem**!!!

<!-- page 60 -->

Course introduction

# References

Valliant, Richard. 2020. "Comparing Alternatives for Estimation from Nonprobability Samples." *Journal of Survey Statistics and Methodology* 8 (2): 231–63.
