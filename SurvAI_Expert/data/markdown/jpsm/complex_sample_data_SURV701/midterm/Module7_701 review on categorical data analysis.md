---
id: "jpsm/complex_sample_data_SURV701/midterm/Module7_701_review_on_categorical_data_analysis"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "assignment"
title: "Review of Module 7"
original: "complex_sample_data_SURV701/midterm/Module7_701 review on categorical data analysis.pdf"
pages: 6
sha256: "86d01f5a364b7c18b528efa0246f7ffe5c1de48f5552295683c29780e1fc1a0e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:54"
---

<!-- page 1 -->

# Review of Module 7

## Categorical Data Analysis

### Univariate
* Graphical display
  * Bar chart
  * Pie chart
  * Histogram

* Estimation of Proportions, SE and CI
  * $p_k = \frac{\sum_{h=1}^H \sum_{a=1}^{\alpha_h} \sum_{k=1}^{n_{ha}} w_{hai} I_{i \in k}}{\sum_{h=1}^H \sum_{a=1}^{\alpha_h} \sum_{k=1}^{n_{ha}} w_{hai}} = \frac{\widehat{N}_k}{\widehat{N}}$
  * $Var_{TSL}(p_k) = \frac{Var(\widehat{N}_k) + p_k^2 Var(\widehat{N}) - 2 p_k Cov(\widehat{N}_k, \widehat{N})}{\widehat{N}^2}$
  * Estimation of CI:
    * Assuming normality assumption
      $$
      CI(\pi_k) = p_k \mp t_{.975, df} se(p_k)
      $$
      Out of boundary with
    * Logit transform method
      $$
      \begin{aligned}
      & CI\big(logit(\pi_k)\big) \\
      & = \left\{ \begin{aligned} A &= \log \left( \frac{p_k}{1 - p_k} \right) - \frac{t_{.975, df} se(p_k)}{(1 - p_k) p_k}, \\ B &= \log \left( \frac{p_k}{1 - p_k} \right) + \frac{t_{.975, df} se(p_k)}{(1 - p_k) p_k} \end{aligned} \right\}
      \end{aligned}
      $$
      $$
      CI(\pi_k) = \{ \frac{e^A}{1 + e^A}, \frac{e^B}{1 + e^B} \}
      $$

Question: If SAS output is provided on $p_k$ and $se(p_k)$, you are expected to solve for $CI(\pi_k)$

* Goodness of fit tests

1

<!-- page 2 -->

* Recode bp_cat (1=.5) (2=.3) (3=.15) (4=.05), generate (pi)
  mgof bp_cat=pi, svy
* Proc surveyfreq data=;
  Strata;
  Cluster;
  Weight;
  Table bp_cat/chisq lrchisq testp=(.5 .3 .15 .05);

### Bivariate
* Contingency table (total proportions; row/column proportions):
  * Q: Total proportion is:

| | MDE=NO (0) | MDE=YES (1) |
| :--- | :--- | :--- |
| MEN (A) | $p_{A0}=0.406$ | $p_{A1}=0.072$ |
| WOMEN (B) | $p_{B0}=0.402$ | $p_{B1}=0.120$ |

Fill in row/column proportions

* proc surveyfreq;
  tables factor.var\*response.var/row cl deff;
* svy:tab factor.var response.var, row se ci deff

2

<!-- page 3 -->

### Tests and measure of association

* Rao-Scott Chi-Square
  * First order design-adjusted
    * Generalized design effect (mean of eigenvalues of D matrix Variance under true complex design / Variance under SRS)

    * Chi-square statistics:

$$X^2_{R-S} = X^2_{Pearson} / GDEFF$$

$$G^2_{R-S} = G^2 / GDEFF$$

Both statistics follow chisq distribution with degrees of freedom df=(R-1)(C-1), $\sim \chi^2_{(R-1)(C-1)}$.

    * F statistics:

$$\frac{X^2_{R-S}}{df} = \frac{X^2_{R-S}}{(R - 1)(C - 1)}$$

$$\frac{G^2_{R-S}}{df} = \frac{G^2_{R-S}}{(R - 1)(C - 1)}$$

Both statistics, under null hypothesis of independence between the two cat variables, follow F distribution with degrees of freedom num.df = (R-1)(C-1) and den.df = (R-1)(C-1)s $\sim F^{(R-1)(C-1)}_{(R-1)(C-1)s}$ and s=#clusters - #strata in complex design

3

<!-- page 4 -->

E.g. Using the software procedure of your choice and the NCS-R data set, estimate the row proportions in a two-way table where race/ethnicity (RACECAT (1=Asian/Other 2=Hispanic 3=Black 4=White) is the factor variable (or row variable) and Major Depressive Episode (MDE) is the response variable (or column variable). Recall from the Chapter 5 exercises that the sampling error stratum, sampling error cluster, and final sampling weight variables in the NCS-R Data set are SESTRAT, SECLUSTR, and NCSRWTSH (Part 1 weight), respectively. **a)** What is the value of the Rao-Scott $F$-statistic for the overall test of the null hypothesis that race category and hypertension status are not associated?

**SAS CODE AND OUTPUT**

```sas
proc surveyfreq data=data.Chapter_exercises_ncsr ;
stratum sestrat;
cluster seclustr;
weight ncsrwtsh;
tables racecat*mde /nocellpercent row deff chisq;
run;
```

| **Rao-Scott Chi-Square Test** | |
| :--- | ---: |
| **Pearson Chi-Square** | 29.1814 |
| **Design Correction** | 1.1517 |
| | |
| **Rao-Scott Chi-Square** | 25.3367 |
| **DF** | |
| **Pr > ChiSq** | <.0001 |
| | |
| **F Value** | 8.4456 |
| **Num DF** | |
| **Den DF** | |
| **Pr > F** | <.0001 |
| **Sample Size = 9282** | |

4

<!-- page 5 -->

* Second order design-adjusted
  * Chi-square statistics:
    $$X_{R-S}^2 = X_{Pearson}^2 / GDEFF / (1 + a^2)$$
    $$G_{R-S}^2 = G^2 / GDEFF / (1 + a^2)$$
    where:
    $a =$ coefficient of variation of eigenvalues of D matrix.

    Both statistics follow chisq distribution with degrees of freedom $\text{df}=(R-1)(C-1)/(1+a^2)$, that is

    $$X_{R-S}^2 \sim \chi_{(R-1)(C-1)/(1+a^2)}^2$$
    $$G_{R-S}^2 \sim \chi_{(R-1)(C-1)/(1+a^2)}^2$$

  * F statistics:
    $$\frac{X_{R-S}^2}{df} = \frac{X_{R-S}^2}{(R-1)(C-1)} \sim F_{\frac{(R-1)(C-1)s}{1+a^2}}^{\frac{(R-1)(C-1)}{1+a^2}}$$
    $$\frac{G_{R-S}^2}{df} = \frac{G_{R-S}^2}{(R-1)(C-1)} \sim F_{\frac{(R-1)(C-1)s}{1+a^2}}^{\frac{(R-1)(C-1)}{1+a^2}}$$

    Both statistics follow F distribution with degrees of freedom
    $$\text{num. df} = (R-1)(C-1)/(1 + a^2)$$
    $$\text{den. df} = (R-1)(C-1)s/(1 + a^2)$$
    $s=$#clusters - #strata in complex design.

5

<!-- page 6 -->

```sas
proc surveyfreq;
    strata; cluster; weight;
    tables age29*ed4cat*ald/row deff
           chisq (secondorder);
run;
```

```stata
svy, subpop(if 18<=age<29): tab ed4cat ald, row se ci
deff
```

### Odds ratio and relative Risk and logit regression

$$\psi = \frac{\frac{Odds(y = 1|x = A)}{Odds(y = 0|x = A)}}{\frac{Odds(y = 1|x = B)}{Odds(y = 0|x = B)}} = \frac{p_{1|A}/p_{0|A}}{p_{1|B}/p_{0|B}}$$

$$RR = \frac{p_{1|A}}{p_{1|B}}$$

Q1: When OR ($\psi$) is close to RR?

Given each level of x, the prob of y =1 close to zero

Q2: How to obtain the estimate of $\psi$ and its CI?

Step 1: Estimate $\beta_1$ under the logit regression model of $logit\left(p_{1|x}\right) = \beta_0 + \beta_1 x$ and then

$$\hat{\psi} = \exp(\widehat{\beta_1})$$

Step 2:

$$\widehat{\psi}_L = \exp(\widehat{\beta_1} - t_{df}se(\widehat{\beta_1}))$$

$$\widehat{\psi}_U = \exp(\widehat{\beta_1} + t_{df}se(\widehat{\beta_1}))$$

6
