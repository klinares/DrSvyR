---
id: "jpsm/complex_sample_data_SURV701/lectures/Module_2"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "Analysis of Complex Sample Survey Data"
original: "complex_sample_data_SURV701/lectures/Module_2.pdf"
pages: 48
sha256: "baaaba43ce49fd38a4360484747f8232e1c44de10d86c9f62635bafd3698b4de"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:50"
---

<!-- page 1 -->

# Analysis of Complex Sample Survey Data

### SURV/SURVMETH 701

### Lecture Notes: Module 2

## Complex Sample Weighting, Survey Estimation and Inference

### Instructor: YAN LI

#### e-mail: [email]

1

<!-- page 2 -->

# Three Elements of Design-Based Inference (CIs)

*"....The form of this solution consists in determining certain intervals which I propose to call confidence intervals...." [Jerzy Neyman, 1934]*

$$
\begin{array}{ccccc}
(1) & & (2) & & (3) \\
\hat{\theta} & \pm & t_{df, 1-\alpha/2} & \cdot & se(\hat{\theta})
\end{array}
$$

$where:$

$$
\begin{aligned}
\hat{\theta} &= \text{survey weighted estimate of } \theta; \\
t_{df, 1-\alpha/2} &= \text{critical value from Student t with df;} \\
se(\hat{\theta}) &= \text{robust, design corrected estimate of } \text{SE}(\hat{\theta}).
\end{aligned}
$$

2

<!-- page 3 -->

# Weighting in Survey Analysis

Weighting is used to compensate for:

* Unequal probabilities of selection
* Nonresponse (typically, a unit that fails to respond)
* In post-stratification or calibration, to adjust weighted sample distributions for certain variables (e.g., age and sex) to make them conform to the known population distribution.

It is used to improve the accuracy (minimize bias) of sample estimates and to compensate for noncoverage and nonresponse.

3

<!-- page 4 -->

# Survey Weights

Weighting may simultaneously incorporate all three components: unequal probabilities of selection, nonresponse, and post-stratification

1) Weight for unequal probabilities of selection: $w_{sel}$;

2) Weight for sample nonresponse: $w_{nr}$;

3) Poststratification weight for population noncoverage and sampling variance reduction: $w_{ps}$.

Then compute the overall weight as:

$$w = w_{sel} \times w_{nr} \times w_{ps}$$

*See:* 
1. *Valliant, R., The Effect of Multiple Weighting Steps on Variance Estimation, Journal of Official Statistics, Vol. 20, No. 1, 2004, pp. 1–18.*
2. *Haziza, D. and Beaumont, J-F., Construction of Weights in Surveys: A Review, Statistical Science, Vol. 32, No. 2, 2017, pp. 206-226.*

4

<!-- page 5 -->

# Sample Selection Weighting

* Sample selection weights “map” the probability sample to the population that it represents.

* Suppose sample element $i$ was selected with probability $\text{f}_\text{i}$. Then sample element $i$ represents $(1 / \text{f}_i)$ elements in the population. That is, count the element $\text{i}$ in the analysis by giving it a weight of:

$$
w_{\text{sel},i} = (1 / f_i).
$$

* For example, a sample element selected with probability $1/10$ may be interpreted as “representing” $10$ elements in the population.

5

<!-- page 6 -->

# Health and Retirement Study (HRS): Sample Selection Weight

| Description of Sample Case | | | | | | |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Sample ID** | **Race/ Ethnicity of Respondent** | **Eligible Rs/ Household** | **$W_{sel,hh}$** | **$W_{sel,over}$** | **$W_{sel,elig}$** | **$W_{sel}$** |
| A | Black | 2 | 2000 | 1 | 2 | 4000 |
| B | Black | 1 | 2000 | 1 | 1 | 2000 |
| C | Hispanic | 2 | 2000 | 2 | 2 | 8000 |
| D | White | 1 | 2000 | 2 | 1 | 4000 |

6

<!-- page 7 -->

Sampling Procedure: for example, $SRS$ design

$$
\pi_i = n / N
$$

**n**

$$
w_i = \frac{1}{\pi_i}
$$

**Sample**

**N**

$\hat{N}$

**Population**

**Weighted Sample**

7

<!-- page 8 -->

# *epsem* design

* epsem design: each population unit will have the same probability to be selected into the sample.
* Estimation under epsem design
  * Population mean:

$$\overline{Y} = \frac{1}{N} \sum_{i=1}^{N} y_i = \frac{y_1 + y_2 + \cdots + y_N}{N}$$

  * Sample mean:

$$\overline{y} = \frac{\sum y_i}{n} = \frac{y_1 + y_2 + \cdots + y_n}{1 + 1 + \cdots 1}$$

8

<!-- page 9 -->

# Non-*epsem* design

* But the selection probability may not be equal for every element

* Estimation: weighted estimator is required:

$$\bar{y}_w = \frac{\sum_i w_i y_i}{\sum_i w_i}$$

9

<!-- page 10 -->

# Example

* Suppose a sample of 20 households are selected from 2000 households in the population
* Within each selected household, <u>one</u> adult is selected
  - For 8 households, there was 1 adult – 3 of 8 adults reported recycling in the past month
  - For 6 households, 2 adults – 3 of 6 adults recycled
  - For 4 households, 3 adults – 3 of 4 adults recycled
  - For 2 households, 4 adults – 2 of 2 adults recycled

10

<!-- page 11 -->

| No. of households | No. of adults | Recycling |
| :---: | :---: | :---: |
| 8 | 1 | 3 out of 8 adults |
| 6 | 2 | 3 out of 6 adults |
| 4 | 3 | 3 out of 4 adults |
| 2 | 4 | 2 out of 2 adults |

QUESTION: ONE ADULT SELECTED WITHIN EACH HH,
1.WHAT IS THE PROB. OF SELECTING ADULTS? IS THIS DESIGN <u>EPSEM</u>?
2.WHAT IS THE <u>PROP.</u> OF ADULTS WHO RECYCLE?

11

<!-- page 12 -->

# Answer to Q1: Probability of selecting adults

* When 1 adult in the household, two stages of selection and
$$f_{sel,i} = (20/2000)(1/1) = 1/100 \quad w_{sel,i} = 100$$
* When 2 adults in the household,
$$f_{sel,i} = (20/2000)(1/2) = 1/200 \quad w_{sel,i} = 200$$
* When 3 adults in the household,
$$f_{sel,i} = (20/2000)(1/3) = 1/300 \quad w_{sel,i} = 300$$
* When 4 adults in the household,
$$f_{sel,i} = (20/2000)(1/4) = 1/400 \quad w_{sel,i} = 400$$

THIS DESIGN IS NOT EPSEM!

12

<!-- page 13 -->

| IDs | HH adult size | Recycling? ($y=1/0$) | Sampling Weight |
| :---: | :---: | :---: | :---: |
| 1 | 1 | 1 | 100 |
| 2 | 1 | 1 | 100 |
| 3 | 1 | 1 | 100 |
| 4 | 1 | 0 | 100 |
| 5 | 1 | 0 | 100 |
| 6 | 1 | 0 | 100 |
| 7 | 1 | 0 | 100 |
| 8 | 1 | 0 | 100 |
| 9 | 2 | 1 | 200 |
| 10 | 2 | 1 | 200 |

13

<!-- page 14 -->

| IDs | HH adult size | Recycling? ($y=1/0$) | Sampling Weight |
| :---: | :---: | :---: | :---: |
| 11 | 2 | 1 | 200 |
| 12 | 2 | 0 | 200 |
| 13 | 2 | 0 | 200 |
| 14 | 2 | 0 | 200 |
| 15 | 3 | 1 | 300 |
| 16 | 3 | 1 | 300 |
| 17 | 3 | 1 | 300 |
| 18 | 3 | 0 | 300 |
| 19 | 4 | 1 | 400 |
| 20 | 4 | 1 | 400 |

14

<!-- page 15 -->

# Answer to Q2: Weighted Estimation

* This can be represented in the weighted mean (proportion of adults who recycle) as

$$\bar{y}_w = \frac{\sum_i w_i y_i}{\sum_i w_i} = \frac{w_1 \cdot y_1 + w_2 \cdot y_2 + \cdots + w_n \cdot y_n}{w_1 + w_2 + \cdots + w_n} = \frac{\hat{Y}}{\hat{N}}$$

$$\bar{y}_w = \frac{100 \cdot 3 + 200 \cdot 3 + 300 \cdot 3 + 400 \cdot 2}{100 \cdot 8 + 200 \cdot 6 + 300 \cdot 4 + 400 \cdot 2} = 0.65$$

* The corresponding unweighted mean is

$$\bar{y} = \frac{\sum_i y_i}{n} = \frac{1 + 1 + 1 + 0 + 0 + \cdots + 1}{20} = 0.55$$

15

<!-- page 16 -->

# Exercise

* Suppose we draw a sample of 20 HHs from the list of 2000 HHs and 1 adult from each selected HH

16

<!-- page 17 -->

| Number of households | No. of adults | Response on Recycling? |
| :---: | :---: | :--- |
| 6 | 1 | 1,1,0,0,0,0 |
| 6 | 2 | 1,1,0,0,1,0 |
| 6 | 3 | 0,1,0,1,1,1 |
| 2 | 4 | 1,1 |

Question: What is the proportion of the adults who recycle?

$$\bar{y}_w = \frac{\sum_i w_i y_i}{\sum_i w_i}$$

17

<!-- page 18 -->

| IDs | HH adult size | Response (y) | Sampling Weight |
| :---: | :---: | :---: | :---: |
| 1 | 1 | | |
| 2 | 1 | | |
| 3 | 1 | | |
| 4 | 1 | | |
| 5 | 1 | | |
| 6 | 1 | | |
| 7 | 2 | | |
| 8 | 2 | | |
| 9 | 2 | | |
| 10 | 2 | | |

18

<!-- page 19 -->

| IDs | HH adult size | Response ($y$) | Sampling Weight |
| :---: | :---: | :---: | :---: |
| 11 | 2 | | |
| 12 | 2 | | |
| 13 | 3 | | |
| 14 | 3 | | |
| 15 | 3 | | |
| 16 | 3 | | |
| 17 | 3 | | |
| 18 | 3 | | |
| 19 | 4 | | |
| 20 | 4 | | |

19

<!-- page 20 -->

| Number of households | No. of adults | Response on Recycling? |
| :---: | :---: | :--- |
| 6 | 1 | 1,1,0,0,0,0 |
| 6 | 2 | 1,1,0,0,1,0 |
| 6 | 3 | 0,1,0,1,1,1 |
| 2 | 4 | 1,1 |

Question: What is the proportion of the adults who recycle?

20

<!-- page 21 -->

**What if not all the 20 adults in the sample responded?**

21

<!-- page 22 -->

# Adjusting Weights for Nonresponse

* Not all selected sample elements will respond to the survey

* Even when observations are weighted to account for selection probabilities, differential nonresponse may result in biased estimates:

$$Bias(\bar{Y}_R) = \bar{Y}_R - \bar{Y} = (1 - RR) \times (\bar{Y}_R - \bar{Y}_{NR})$$

  - RR is the expected population response rate

* Two common methods of developing adjustments for nonresponse:
  - Weighting class adjustment methods
  - Response propensity weighting adjustments

22

<!-- page 23 -->

# Weighting Class Adjustment for Nonresponse

* Form cells by cross-classifying respondents and nonrespondents based on known <u>categorical variables</u> that predict nonresponse and are <u>associated</u> with the variables of interest ($c = 1, \dots, C$ “weighting classes”).
* Assume probability of response within the cell is the empirical value of the response rate ($\text{rrate}_c$) for sample cases in cell $c$ (per Kott, 2012, *Survey Methodology*, should be weighted!).
* Compute the nonresponse adjustment as the reciprocal of the response rate within each weighting class.

$$
w_{nr,wc,i} = \frac{1}{rrate_c}
$$

$$
where : rrate_c = \text{ the response rate for weighting class } c=1,\dots, C
$$

23

<!-- page 24 -->

# Example

* Suppose that **<u>not</u>** everyone in the sample of $n=1,000$ people responded

24

<!-- page 25 -->

| Class | $w_{sel,i}$ | Sample size | Respondents | Income ($y$) |
| :--- | :---: | :---: | :---: | :---: |
| Education $\le 12$ yrs | 1.00 | 500 | 400 | \$60,000 |
| Education $> 12$ yrs | 1.00 | 500 | 450 | \$80,000 |
| **Total** | | **1,000** | **850** | **\$70,588**<br>**(v. \$70,000)** |

Question:
a) Estimated Population Size=?
b) Average Income=? Biased if ignore nonRspt’s
c) What are answers to a) and b) if base weight $= 4.88$ for edu$>12$ yrs?

25

<!-- page 26 -->

# Remedy: Weighting for Nonresponse - Weighting Class Methods

Step 1: Form the weighting class (done in the table)

Step 2: Compute response rate in each class

Step 3: Nonresponse weights are the inverse of <u>the response rate in each class</u>

* Assumption: data is missing at random (MAR) within classes

26

<!-- page 27 -->

| Weighting Classes | Respondents | $rrate_h$ | $1/rrate_h$ |
| :--- | ---: | ---: | ---: |
| Education $\le 12$ yrs | 400 | 0.80 | 1.25 |
| Education $> 12$ yrs | 450 | 0.90 | 1.11 |
| **Total** | **850** | **0.85** | |

- Response rate in class $h$: $rrate_h$
- Nonresponse adjustment factor:

$$w_{nr,wc,i} = 1 / rrate_h$$

27

<!-- page 28 -->

If all sample units respond (unbiased):

$$
\bar{y}_s = \frac{\sum_{i \in s} y_i}{n} = \frac{60000 * 500 + 80000 * 500}{1000} = 70000
$$

If nonrespondents are ignored (biased):

$$
\bar{y}_r = \frac{\sum_{i \in r} y_i}{n_r} = \frac{60,000 * 400 + 80,000 * 450}{850} = 70,588
$$

If nonrespondent adjusted (unbiased):

$$
\bar{y}_r^w = \frac{\sum_{i \in r} w_{nr,i} y_i}{\sum_{i \in r} w_{nr,i}} = \frac{60,000 * 1.25 * 400 + 80,000 * 1.11 * 450}{1.25 * 400 + 1.11 * 450} = 70,000
$$

28

<!-- page 29 -->

# Propensity Adjustment for Nonresponse

* Using variables that are known for respondents and nonrespondents, identify variables that predict nonresponse and are associated with the variables of interest.
* Model the propensity of response.
* Compute the nonresponse adjustment: 1) the reciprocal of the estimated propensity score; or 2) create weighting classes based on deciles of estimated propensity scores.

$$
W_{nr,pro,i} = \left( \hat{p}_{resp,i} \right)^{-1} = \left\{ prob(respondent = yes \mid X_i) \right\}^{-1} = \left( \frac{e^{X_i \hat{\beta}}}{1 + e^{X_i \hat{\beta}}} \right)^{-1}
$$

29

<!-- page 30 -->

# Therefore, we have Nonresponse Adjusted Weights:

$$w_{sel} \times w_{nr}$$

**What if**
**weighted sample distribution**
**$\neq$**
**population distribution?**

30

<!-- page 31 -->

# Post-stratification Weighting

* The final step in survey weight development involves post-stratification of nonresponse adjusted weights to population controls:

$$w_{ps,l,i} = \frac{N_l}{\sum_{i=1}^{n_l} (w_{sel,i} \times w_{nr,i})} = \frac{N_l}{\hat{N}_l}$$

$where:$

$w_{ps,l,i} =$ the post-stratification weight factor for cases in post-stratum $l=1,...,L$; and

$N_l =$ the population count in post-stratum $l$ obtained from a recent Census, administrative records, or a large survey with small sampling variance.

* Some survey programs use more complex forms of post-survey adjustment to sample weights such as calibration, raking, etc.

31

<!-- page 32 -->

## Weighting for Noncoverage

- **Poststratification** is used to make the weighted sample distribution conform to a known population distribution

<u>Example</u>  
Suppose that the sample distribution of  
*whether a household has children present*  
does not agree with the known distribution in the population

32

<!-- page 33 -->

| **Children?** | $\sum w_{sel,i} \times w_{nr,i}$ | $p_g$ | $N_g$ | $P_g$ |
| :--- | :--- | :--- | :--- | :--- |
| Yes | 35,000,000 | 0.35 | 40,000,000 | 0.4 |
| No | 65,000,000 | 0.65 | 60,000,000 | 0.6 |
| **Total** | 100,000,000 | **1.00** | **100,000,000** | **1.0** |

33

<!-- page 34 -->

# Remedy: Weighting for Noncoverage - Weighting Class Methods

Step 1: Form the weighting class $g$ (done in the table)

Step 2: Weighted sample distribution in each class $p_g$

Step 3: Population distribution in each class $P_g$

NOT EQUIVALENT

Step 4: Compute Poststratification adjustment factor

$$
f_g = P_g / p_g
$$

34

<!-- page 35 -->

| Children? | $\sum w_{sel,i} \times w_{nr,i}$ | $p_g$ | $N_g$ | $P_g$ | $f_g = P_g / p_g$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| Yes | 35M | 0.35 | 40M | 0.4 | 1.143 |
| No | 65M | 0.65 | 60M | 0.6 | 0.923 |
| **Total** | 100M | **1.00** | 100M | **1.0** | **1,000** |

In poststratification, the weights for the individuals in groups are adjusted <u>up or down</u> to obtain the distribution of the sum of weights that corresponds to the population distribution

35

<!-- page 36 -->

# A final weight

* The final weight is obtained after <u>adjustments of the baseline weight for nonresponse and poststratification</u>
* *Example (cont.):*

36

<!-- page 37 -->

| **Education** <br> &emsp; **Children?** | size of <br> respondents | Final weight |
| :--- | :---: | ---: |
| Education $\le 12$ yrs <br> &emsp; Yes <br> &emsp; No | <br> 140 <br> 260 | <br> $1 \times 1.25 \times 1.143 = 1.429$ <br> $1 \times 1.25 \times 0.923 = 1.154$ |
| Education $> 12$ yrs <br> &emsp; Yes <br> &emsp; No | <br> 158 <br> 292 | <br> $4.88 \times 1.11 \times 1.143 = 6.195$ <br> $4.88 \times 1.11 \times 0.923 = 5.003$ |
| **Total** | **850** | **Estimated** <br> **popsize=(2,940)** |

37

<!-- page 38 -->

# HRS Final Weight

| Sample ID | Nonresponse Adjustment Cell | Post-stratum | $W_{sel}$ | $W_{nr}$ | $W_{ps}$ | $W_{final}$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| A | Black, Northeast, Urban | Age 50-54, Male, Married | 4000 | 1.3 | 1.04 | 5408 |
| B | Black, South, Rural | Age 55-61 Female, Single | 2000 | 1.15 | .96 | 2208 |
| C | Hispanic, West, Urban | Age 50-54, Male, Married | 8000 | 1.25 | 1.06 | 10,600 |
| D | White, Midwest, Rural | Age 55-61, Female, Single | 4000 | 1.18 | .97 | 4578 |

38

<!-- page 39 -->

# Regression Models of log-transformed Household Income for the HRS Black Subpopulation ($n = 2,465$).

| Independent Variable | Regression Parameter Estimate [Standard Error, $p$-value]<br>Unweighted | Regression Parameter Estimate [Standard Error, $p$-value]<br>Weighted (Design-based SE) |
| :--- | :--- | :--- |
| ***Age (continuous)*** | $0.0026$ ($0.0058$, $p = 0.66$) | $0.0056$ ($0.0093$, $p = 0.54$) |
| ***Gender*** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Female**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Male** | $-0.4629$ ($0.1246$, $p < 0.001$)<br>Reference category | $\underline{-0.3034 \ (0.2199, \ p = 0.17)}$<br>Reference Category |
| ***Education*** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Grade 0-11**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Grade 12**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Grade 13-15**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Grade 16+** | $-1.5585$ ($0.1991$, $p < 0.0001$)<br>$-1.0304$ ($0.2011$, $p < 0.0001$)<br>$-0.5145$ ($0.2152$, $p < 0.0001$)<br>Reference category | $-1.9016$ ($0.2610$, $p < 0.0001$)<br>$-1.5177$ ($0.2871$, $p < 0.0001$)<br>$-0.7114$ ($0.1330$, $p < 0.0001$)<br>Reference Category |
| ***Region*** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Northeast**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Midwest**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **South**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **West** | $0.0804$ ($0.2743$, $p = 0.77$)<br>$-0.3331$ ($0.2635$, $p = 0.21$)<br>$-0.2525$ ($0.2476$, $p = 0.31$)<br>Reference Category | $0.1462$ ($0.1680$, $p = 0.38$)<br>$-0.2423$ ($0.2614$, $p = 0.36$)<br>$-0.3519$ ($0.2405$, $p = 0.15$)<br>Reference Category |
| ***Urbanicity*** &nbsp;&nbsp; **Urban**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Suburban**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Rural** | $-0.0697$ ($0.1690$, $p = 0.68$)<br>$0.5878$ ($0.1965$, $p = 0.76$)<br>Reference Category | $-0.0553$ ($0.3751$, $p = 0.88$)<br>$-0.0262$ ($0.4764$, $p = 0.58$)<br>Reference Category |

39

<!-- page 40 -->

# A Simple Model for Losses In Precision due to Weighting

$L_W =$ Loss due to weighting $=$ Proportionate Increase in Variance of a Mean

$$
\sim CV^2(W_i) = \left[ \frac{\sum_1^n W_i^2}{\left(\sum_1^n W_i\right)^2} \right] \cdot n - 1
$$

Subgroups:

$$
L_{W,sub} \sim \left[ \frac{\sum_1^m W_i^2}{\left(\sum_1^m W_i\right)^2} \right] \cdot m - 1
$$

Generally, oversampling for subgroups: $\quad L_{W,SUB} < L_W$ (see Kish, 1965)

40

<!-- page 41 -->

# Example of Weighting Loss in Disproportionate Sampling

| Stratum | Weight | % of Hispanic Sample | Sample size |
| :---: | :---: | :---: | :---: |
| 1 | 4 | 7% | 70 |
| 2 | 2 | 17% | 170 |
| 3 | 1.33 | 26% | 260 |
| 4 | 1 | 50% | 500 |
| | | 100% | 1000 |

For $n = 1000$,

$$
\mathrm{L}_{\mathrm{w}} = \frac{\sum_{i=1}^{n} W_{i}^{2}}{\left(\sum_{i=1}^{n} W_{i}\right)^{2}} \times n - 1
$$

$$
= \frac{2759.9}{2,148,569} \times 1000 - 1
$$

$$
= .284
$$

41

<!-- page 42 -->

# Survey Weighted Estimates (1)

$$\bar{y}_w = \frac{\sum_{i=1}^n W_i \cdot y_i}{\sum_{i=1}^n W_i} \text{ estimates } \bar{Y};$$

$$s_w^2 = \frac{\sum_{i=1}^n W_i \cdot (y_i - \bar{y}_w)^2}{\sum_{i=1}^n W_i - 1} \text{ estimates } S^2 \text{ ;}$$

$$b_{1,w} = \frac{\sum_{i=1}^n W_i \cdot y_i \cdot x_i}{\sum_{i=1}^n W_i \cdot x_i^2} \text{ estimates the simple linear regression coefficient, } B_1.$$

42

<!-- page 43 -->

# Survey Weighted Estimation: More Complex Pseudo-Maximum Likelihood for Logistic Regression

Pseudo $\ln(\text{likelihood})$:

$$= \sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i} y_{h\alpha i} \ln(\pi(x_{h\alpha i}))$$

$$+ \sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i} (1 - y_{h\alpha i}) \ln(1 - \pi(x_{h\alpha i})),$$

where

$$\pi(\text{x}_\text{i}) = \frac{e^{x_i B}}{1 + e^{x_i B}}, \hat{\pi}(\text{x}_\text{i}) = \frac{e^{x_i b}}{1 + e^{x_i b}}$$

and $\text{b}=$ the vector of coefficient estimates that solves

$$U(B) = \left. \frac{\partial \ln L(B)}{\partial B} \right|_{B=b} = 0$$

$$= \sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i} x'_{h\alpha i} y_{h\alpha i} - \sum_{h=1}^{H} \sum_{\alpha=1}^{a_h} \sum_{i=1}^{n_\alpha} w_{h\alpha i} x'_{h\alpha i} \hat{\pi}(x_{h\alpha i})$$

43

<!-- page 44 -->

# Scaling of Survey Analysis Weights

* Survey weights are generally released on a “population scale”:

$$
\sum_{i=1}^{n} W_i \approx N \text{ (the population total)}
$$

* Historically, many data producers scaled the survey analysis weights to sum to the sample size for the survey (NCS-R example above):

$$
W_i^* = W_i \cdot \frac{n}{\sum_{i=1}^{n} W_i} \implies \sum_{i=1}^{n} W_i^* = n
$$

* Weighted analyses, with the exception of estimates of population totals, are invariant to any linear scaling of the weights:

$$
e.g.\ W_i^* = a \cdot W_i \ \text{ or } W_i^* = W_i / b
$$

44

<!-- page 45 -->

# Examples of Survey Weight Distributions

| | NCS-R: NCSRWTLG | NCS-R: NCSRWTSH | NHANES: WTMEC2YR | NHANES: WTINT2YR | HRS: KWGTR | HRS: KWGTHH |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $n$ | 5,692 | 9,282 | 5,563 | 5,563 | 18,467 | 18,467 |
| Sum | 5,692 | 9,282 | 217,700,496 | 217,761,911 | 75,540,674 | 82,249,285 |
| Mean | 1.00* | 1.00* | 39,133.65 | 39,144.69 | 4,144.73 | 4,453.85 |
| SD | 0.96 | 0.52 | 31,965.69 | 30,461.53 | 2,973.48 | 3,002.06 |
| Min | 0.11 | 0.17 | 0** | 1,339.05 | 0** | 0** |
| Max | 10.10 | 7.14 | 156,152.20 | 152,162.40 | 16,532 | 15,691 |
| Pctls. | | | | | | |
| 1% | 0.24 | 0.36 | 0 | 2,922.37 | 0 | 0 |
| 5% | 0.32 | 0.49 | 2,939.33 | 4,981.73 | 0 | 1,029 |
| 25% | 0.46 | 0.69 | 14,461.86 | 16,485.70 | 2,085 | 2,287 |
| 50% | 0.64 | 0.87 | 27,825.71 | 28,040.22 | 3,575 | 3,755 |
| 75% | 1.08 | 1.16 | 63,171.48 | 62,731.71 | 5,075 | 5,419 |
| 95% | 2.95 | 1.85 | 100,391.70 | 96,707.20 | 10,226 | 10,847 |
| 99% | 4.71 | 3.17 | 116,640.90 | 113,196.20 | 12,951 | 14,126 |

45

<!-- page 46 -->

# Constructing Design-based Confidence Intervals: Degrees of freedom for the reference distribution

* Degrees of freedom are the number of independent comparisons (generally squared differences) which can be made between the elements of the sample.

* For test statistics ($t$, $X^2$, $F$) that require estimates of variation in the data, df are related to the number of independent contrasts available to estimate the required variance(s)

* Consider:

$$
t_{n-1, SRS} = \frac{(\bar{y} - \bar{Y}_0)}{se(\bar{y})} = \frac{(\bar{y} - \bar{Y}_0)}{\sqrt{s^2 / n}} = \frac{(\bar{y} - \bar{Y}_0)}{\sqrt{\sum_{i=1}^n [(y_i - \bar{y})^2 / (n - 1)] / n}}
$$

*note*: that for an independent sample of size $n$, there are $n-1$ independent contrasts to estimate $s^2$, the unknown component of $se(\bar{y})$. $\therefore \text{df}=n-1$

46

<!-- page 47 -->

# Degrees of Freedom in Variance Estimation for Complex Sample Data

<u>Leads to simple Rule:</u>

$$\text{degrees of freedom} = \text{\# of clusters} - \text{\# of strata}$$

$$= \sum_{h=1}^{H} a_h - H$$

ex: Two cluster per stratum design.

$$\text{d.f.} = 2 \cdot H - H = H$$

See: *Valliant, R. and Rust, K.F., Degrees of Freedom Approximations and Rules-of-Thumb, Journal of Official Statistics, Vol. 26, No. 4, 2010, pp. 585–602.* (They propose a simple estimator of degrees of freedom that leads to improved confidence interval coverage relative to the simple rule above, which is currently used by most software packages.)

47

<!-- page 48 -->

# Degrees of Freedom in Confidence Interval Construction

$$
\begin{aligned}
CI_{.95} &= \hat{\theta} \pm t_{.975,df}^* \, se(\hat{\theta}) \\[1em]
t_{.975,1} &= 12.706 \\
t_{.975,5} &= 2.5706 \\
t_{.975,10} &= 2.2281 \\
t_{.975,20} &= 2.0860 \\
t_{.975,30} &= 2.0423 \\
t_{.975,40} &= 2.0211 \\
t_{.975,\infty} &= 1.9600 \\[1em]
Z_{.975} &= 1.9600
\end{aligned}
$$

48
