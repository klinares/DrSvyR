---
id: "sampling/02-Probability-and-Distributions"
source: "sampling"
course: ""
course_title: ""
doc_type: "book"
title: "2  Probability Distributions"
original: "02-Probability-and-Distributions.md"
pages: 
sha256: "67b2bbaad8897fc9b395a300bbde7cc26967a37fadd2fcee733104373c5ca3f0"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:46"
---

<!-- source: https://bookdown.org/dsciencelabs/sampling_and_survey_techniques/02-Probability-and-Distributions.html -->

# 2  Probability Distributions

## 2.1 Probability in Sampling

Sampling is the process of selecting a subset of individuals from a population to make inferences about the entire population. It is widely used in statistics, surveys, and research studies to obtain insights without having to analyze every member of the population.

# An error occurred.

Unable to execute JavaScript.

The two primary categories of sampling methods are **probability sampling** and **non-probability sampling**.

## 2.2 Probability vs. Non-Probability

In research and data collection, sampling methods are broadly categorized into probability sampling and non-probability sampling. The choice between these methods depends on the research goals, available resources, and the level of accuracy needed.

# An error occurred.

Unable to execute JavaScript.

### 2.2.1 Probability Sampling

Probability sampling ensures that every element in the population has a known, non-zero chance of being selected. It allows for statistical inference and generalization to the entire population. Common probability sampling methods include:

- ✅ **Simple Random Sampling (SRS)**: Each element in the population has an equal chance of being selected. This can be done using random number generators or lottery methods.
- ✅ **Stratified Sampling**: The population is divided into strata (subgroups) based on certain characteristics (e.g., age, income), and random samples are drawn from each stratum proportionally.
- ✅ **Cluster Sampling**: The population is divided into clusters (e.g., geographic regions), and entire clusters are randomly selected. This is useful for large populations.
- ✅ **Systematic Sampling**: A starting point is randomly chosen, and subsequent selections follow a fixed interval (e.g., selecting every 10th person).

### 2.2.2 Non-Probability Sampling

Non-probability sampling does not guarantee every individual in the population has a chance of being selected. It is often used when probability sampling is impractical or too expensive. Common non-probability sampling methods include:

- ✅ **Convenience Sampling**: Selecting individuals based on availability or accessibility.
- ✅ **Judgmental (Purposive) Sampling**: Selecting individuals based on researcher judgment and expertise.
- ✅ **Quota Sampling**: Ensuring specific subgroups are represented in the sample based on predetermined quotas.
- ✅ **Snowball Sampling**: Participants recruit other participants, often used in hard-to-reach populations.

## 2.3 Types of Sampling Distributions

A **sampling distribution** refers to the probability distribution of a statistic (such as the mean, proportion, variance, or standard deviation) obtained from multiple random samples of the same size from a population. These distributions are essential in inferential statistics, as they help estimate population parameters and test hypotheses.

### 2.3.1 Mean

This distribution consists of the means of all possible random samples of a given size from a population.

**Key Properties:**

- ✅ The mean of the sampling distribution ($\mu_{\bar{x}}$) is equal to the population mean ($\mu$).
- ✅ The standard deviation of the sampling distribution (Standard Error of the Mean, **SEM**) is given by:

$$\sigma_{\bar{x}} = \frac{\sigma}{\sqrt{n}}$$

where $\sigma$ is the population standard deviation and $n$ is the sample size.

- ✅ If the population is normally distributed, the sampling distribution is also normal for any $n$.
- ✅ If the population is not normal, the **Central Limit Theorem (CLT)** states that the sampling distribution of the mean will be approximately normal if $n \geq 30$.

**Example:** A population has a mean of 100 and a standard deviation of 15. If we take random samples of size 36, the standard error of the mean will be:

$$\sigma_{\bar{x}} = \frac{15}{\sqrt{36}} = \frac{15}{6} = 2.5$$

If the population follows a normal distribution, the sample means will also follow a normal distribution with a mean of 100 and a standard deviation of 2.5.

### 2.3.2 Proportion

This distribution describes the possible values of sample proportions from a population.

**Key Properties:**

- ✅ The mean of the sampling distribution of proportions is equal to the population proportion ($p$).
- ✅ The standard deviation (Standard Error of the Proportion, **SEP**) is:

$$\sigma_{\hat{p}} = \sqrt{\frac{p(1 - p)}{n}}$$

- ✅ If $np \geq 5$ and $n(1 - p) \geq 5$, the sampling distribution of the proportion is approximately normal (by the normal approximation to the binomial).

**Example:** If 40% ($p = 0.4$) of a population supports a certain policy, and a random sample of 100 is taken:

$$\sigma_{\hat{p}} = \sqrt{\frac{0.4(1 - 0.4)}{100}} = \sqrt{\frac{0.24}{100}} = \sqrt{0.0024} \approx 0.049$$

The sample proportions will follow an approximately normal distribution with a mean of 0.4 and a standard deviation of 0.049.

### 2.3.3 Variance

This distribution describes the variability of sample variances.

**Key Properties:**

- ✅ The mean of the sampling distribution of variance is equal to the population variance ($\sigma^2$).
- ✅ The sampling distribution follows a **chi-square distribution** with $(n - 1)$ degrees of freedom.
- ✅ The formula for the sample variance is:

$$s^2 = \frac{\sum (x_i - \bar{x})^2}{n - 1}$$

**Example:** If a population has a variance of 25 and a sample size of 10, the sample variances will follow a chi-square distribution with 9 degrees of freedom.

### 2.3.4 Standard Deviation

Since the sample variance follows a chi-square distribution, the standard deviation is derived from it.

**Key Properties:**

- ✅ The sampling distribution of standard deviation does not follow a normal distribution.
- ✅ It is often estimated using the chi-square distribution.

### 2.3.5 Difference Between Two Means

Used when comparing two independent sample means.

**Key Properties:**

- ✅ If $\bar{x}_1$ and $\bar{x}_2$ are the means from two independent samples, the mean of their sampling distribution is:

$$\mu_{\bar{x}_1 - \bar{x}_2} = \mu_1 - \mu_2$$

- ✅ he standard deviation (Standard Error) is:

$$\sigma_{\bar{x}_1 - \bar{x}_2} = \sqrt{\frac{\sigma_1^2}{n_1} + \frac{\sigma_2^2}{n_2}}$$

- ✅ If both populations are normal or the sample sizes are large, the distribution of $\bar{x}_1 - \bar{x}_2$ is approximately normal.

**Example:** If two populations have means of 50 and 55 with variances of 16 and 25, and sample sizes of 30 each:

$$\sigma_{\bar{x}_1 - \bar{x}_2} = \sqrt{\frac{16}{30} + \frac{25}{30}} = \sqrt{0.533 + 0.833} = \sqrt{1.366} \approx 1.17$$

### 2.3.6 Difference Between Two Proportions

Used when comparing proportions from two independent samples.

**Key Properties:**

- ✅ The mean of the sampling distribution is:

$$\mu_{\hat{p}_1 - \hat{p}_2} = p_1 - p_2$$

- ✅ The standard deviation (Standard Error) is:

$$\sigma_{\hat{p}_1 - \hat{p}_2} = \sqrt{\frac{p_1(1 - p_1)}{n_1} + \frac{p_2(1 - p_2)}{n_2}}$$

- ✅ If sample sizes are large, the distribution is approximately normal.

**Example:** If $p_1 = 0.6$ and $p_2 = 0.5$ with sample sizes of 100 each:

$$\sigma_{\hat{p}_1 - \hat{p}_2} = \sqrt{\frac{0.6(0.4)}{100} + \frac{0.5(0.5)}{100}} = \sqrt{0.0024 + 0.0025} = \sqrt{0.0049} = 0.07$$

### 2.3.7 Student’s t-Distribution

Used when estimating the mean of a normally distributed population with an unknown variance, especially for small samples ($n < 30$).

**Key Properties:**

- ✅ The shape is similar to a normal distribution but has heavier tails (greater variability for small samples).
- ✅ The formula for the **t-statistic** is:

$$t = \frac{\bar{x} - \mu}{\frac{s}{\sqrt{n}}}$$

- ✅ Follows a **t-distribution** with $n - 1$ degrees of freedom.

**Example:** If $\bar{x} = 52$, $\mu = 50$, $s = 10$, and $n = 9$, the t-score is:

$$t = \frac{52 - 50}{\frac{10}{\sqrt{9}}} = \frac{2}{\frac{10}{3}} = \frac{2}{3.33} = 0.6$$

Each type of sampling distribution serves a specific purpose in statistical inference, from estimating means and proportions to comparing groups. Understanding these distributions is crucial for hypothesis testing, constructing confidence intervals, and making data-driven decisions.

## 2.4 Standard Normal Distribution

The **Z-distribution** (or **standard normal distribution**) is a normal distribution with a mean of **0** and a standard deviation of **1**. It is used for standardizing data, hypothesis testing, and confidence intervals.

**Key Properties:**

- ✅ The **mean** ($\mu$) is **0** and the **standard deviation** ($\sigma$) is **1**.

- ✅ The **total area** under the curve is **1**.

- ✅ The **Z-score formula** converts raw values into standard normal values:

  

$$Z = \frac{X - \mu}{\sigma}$$

where:

- $X$ = observed value  
- $\mu$ = population mean  
- $\sigma$ = population standard deviation

**Empirical Rule (68-95-99.7 Rule)**:

- About **68%** of values fall within **$\pm 1$ standard deviation**.
- About **95%** of values fall within **$\pm 2$ standard deviations**.
- About **99.7%** of values fall within **$\pm 3$ standard deviations**.

**Example:** If a test score is $X = 85$, the population mean is $\mu = 75$, and the standard deviation is $\sigma = 10$, then:

$$Z = \frac{85 - 75}{10} = \frac{10}{10} = 1.0$$

This means the test score is **1 standard deviation above the mean**.

The Z-distribution is widely used in **Z-tests**, probability calculations, and constructing **confidence intervals** for population parameters. 🚀

## 2.5 Central Limit Theorem (CLT)

The **Central Limit Theorem (CLT)** states that for a sufficiently large sample size (typically $n > 30$), the sampling distribution of the mean will be approximately normal, regardless of the original population distribution.

# An error occurred.

Unable to execute JavaScript.

Implications of CLT:

- ✅ Allows normal approximation even for skewed population distributions.
- ✅ Enables hypothesis testing and confidence interval estimation using normal-based methods.

## 2.6 Law of Large Numbers

The **Law of Large Numbers (LLN)** states that as the sample size increases, the sample mean approaches the population mean.

- ✅ **Weak Law of Large Numbers**: The probability that the sample mean deviates significantly from the population mean decreases as sample size increases.
- ✅ **Strong Law of Large Numbers**: The sample mean converges almost surely to the population mean as the sample size grows.

## 2.7 Confidence Intervals

A **Confidence Interval (CI)** provides a range of values that likely contain the true population parameter. The formula for a confidence interval for a population mean is:

$$CI = \bar{X} \pm Z_{\alpha/2} \times \frac{\sigma}{\sqrt{n}}$$

where:

- $Z_{\alpha/2}$ is the critical value from the standard normal table.
- $\sigma$ is the population standard deviation.
- $n$ is the sample size.

Common confidence levels:

- **90% CI**: $Z = 1.645$
- **95% CI**: $Z = 1.96$
- **99% CI**: $Z = 2.576$

## 2.8 Hypothesis Testing in Surveys

Hypothesis testing is used to make inferences about population parameters based on sample data. The general steps include:

- ✅ **Define Hypotheses:**
  - Null Hypothesis ($H_0$): Assumes no effect or no difference.
  - Alternative Hypothesis ($H_1$): Assumes an effect or difference exists.
- ✅ **Select a Significance Level ($\alpha$)**
  - Common choices: 0.05, 0.01, or 0.10.
- ✅ **Compute the Test Statistic**
  - For mean: $Z = \frac{\bar{X} - \mu}{\sigma/\sqrt{n}}$
  - For proportion: $Z = \frac{\hat{p} - p_0}{\sqrt{p_0(1-p_0)/n}}$
- ✅ **Determine the p-value**
  - If $p < \alpha$, reject $H_0$; otherwise, fail to reject $H_0$.
- ✅ **Draw a Conclusion**
  - If $H_0$ is rejected, there is sufficient evidence to support $H_1$.
  - If $H_0$ is not rejected, there is insufficient evidence to support $H_1$.

Understanding these fundamental statistical concepts allows researchers to design better experiments, analyze survey data effectively, and make informed conclusions based on sampled data.
