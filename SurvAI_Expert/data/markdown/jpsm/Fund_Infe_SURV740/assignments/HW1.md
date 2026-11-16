---
id: "jpsm/Fund_Infe_SURV740/assignments/HW1"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Homework 1: Introduction to Causal Inference"
original: "Fund_Infe_SURV740/assignments/HW1.qmd"
pages: 
sha256: "49d7be4615de143d760a26d11e93d0ecb4db73f84a16c2208ea088b64e73d428"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:04"
---


```r
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE, 
                      fig.width = 6, fig.height = 4, fig.align = 'center')


pacman::p_load(ggdag, dagitty, DiagrammeR, tidyverse)


# Set seed for reproducibility
set.seed(123)
```

1 (20’). Supposed that you have a random sample of size n from the population of interest. Answer the following questions that are designed to help you get familiar with potential outcomes. Try to keep your answers brief and your language precise. Throughout the problem, assume that the Stable Unit Treatment Value Assumption (SUTVA) holds.

a\. Contrast the meaning of $Y^0$ with the meaning of $Y$.

-   $Y^0$ is the potential outcome if the treatment were not applied (counterfactual), and $Y$ is the observed outcome after the intervention.


b\. Contrast the meaning of $E(Y^0)$ with the meaning of $E(Y|A=0)$.

-   $E(Y^0)$ the average potential outcome value had all of the population did not receive the treatment. $E(Y|A=0)$ is the average observed outcome value among those who did not actually receive any treatment.



c\. Contrast the meaning $E(Y^0|A=1)$ with the meaning of $E(Y^0|A=0)$.

-   $E(Y^0|A=1)$ is the average potential outcome value for the treated group if they had theoretically not received the treatment. $E(Y^0|A=0)$ is the average potential outcome value for the untreated group, if they had theoretically not received the treatment.



d\. Which of the following quantities can be identified from observed data, assuming SUTVA?

-   a\. $E(Y^0|A=1)$

-   b\. $E(Y^0)$

-   c\. $E(Y|A=0)$: Since $Y=Y^a$ under the SUTVA assumption, the average value can be observed for individuals not treated.

-   d\. $E(Y^0|A=0)$ Since $Y=Y^a$ under the SUTVA assumption D is also true, the average value can be observed for individuals not treated.


\

e\. Now, further assume that the units in this sample are randomly assigned to treatments, which means the assumption of exchangeability holds. Which of the above quantities can be identified from the observed data?

-   All of these answers, a, b, c, and d, under the assumption of exchangeability given random assignment assumes that the average potential outcome value would be the same regardless of assignment to the treated or control groups.

\

2.  (10’). Under the complete randomization of treatment assignment, the average treatment effect is identified because the randomization guarantees statistical independence between the treatment indicator 𝐴 and the observed outcome 𝑌.

a\. True

b\. False

Why? Justify your choice.

-   The statement is **False**, since randomization guarantees independence between $Y^0, y^1$ but not the observed outcome $Y$. The observed outcome depends on $A$.


\newpage


3.  (20’). Consider the following DGA.

```r
# Create the DAG using ggdag
dag <- dagify(
  Y ~ X + Z3,
  X ~ Z1 + Z4,
  Y ~ Z1 + Z2,
  Z1 ~ Z2 + Z4,
  Z3 ~ X,
  coords = list(
    x = c(X = 0, Y = 2, Z1 = 1, Z2 = 2, Z3 = 1, Z4 = 0),
    y = c(X = 0, Y = 0, Z1 = 1, Z2 = 2, Z3 = -1, Z4 = 2)
  )
)

ggdag(dag) +
  theme_dag() +
  labs(title = "Causal DAG for Problem 3")
```

a\. Enumerate all paths from X to Y.

-   direct path: $X \rightarrow Y$
-   $X \leftarrow Z1 \rightarrow Y$
-   $X \rightarrow Z3 \rightarrow Y$
-   $X \leftarrow Z1 \leftarrow Z2 \rightarrow Y$
-   $X \leftarrow Z4 \rightarrow Z1 \rightarrow Y$
-   $X \leftarrow Z4 \rightarrow Z1 \leftarrow Z2 \rightarrow Y$


\


b\. In the path $X \leftarrow Z_4 \rightarrow Z_1 \leftarrow Z_2 \rightarrow Y$, what type of node is $Z_1$? Does conditioning on $Z_1$ block or unblock this path from $X$ to $Y$?

-   $Z_1$ is a collider and conditioning it would **unblock** the path from $X$ to $Y$, as it opens the collider.


\


c\. In the path $X \leftarrow Z_1 \rightarrow Y$. In this path, what type of node is $Z_1$? Does conditioning on $Z_1$ here block or unblock this path?

-   $Z_1$ is a confounder, which is a common cause, in this path, and conditioning would block this path.


\


d\. Pearl’s back-door criterion is a way to rule out confounding via conditioning, thus identifying the effect of one variable on another. For identifying the effect of any $X$ on any $Y$, the backdoor criterion has two parts. First, the conditioning set $C$ may not include any descendant of $X$. That means, anything that $X$ affects cannot be conditioned on (c.f. post-treatment bias). Second, the conditioning set must block all back-door paths from $X$ to $Y$. That is, by conditioning on our set $C$, we should break any back-door paths that may simultaneously generate confounded covariance in $X$ and $Y$.

-   a\. Is $X \rightarrow Z_3 \rightarrow Y$ a back door path from $X$ to $Y$? Why?

-   It is not a back door path because it starts with an arrow going from X, and not into X.

-   b\. Based on your DAG, enumerate the minimum conditioning sets that satisfy the back door criterion for identifying the effect of X on Y?

-   $Z_1 \leftarrow Z_2$

-   $Z_1 \leftarrow Z_4$

-   These do not include descendants of $X$ and by conditioning we break any back-door paths.


\newpage


4.  Consider a randomized experiment with four observations, of which two units were randomly assigned to treatment via complete randomization. We use $A_i \in {0,1}$ and $Y_i$ to denote the treatment (1 for treatment and 0 for control) and the observed outcome for unit $i$, respectively.

a\. (4’) The table below shows the data observed from this experiment, augmented with columns for potential outcomes and the treatment effect for each unit. Fill in all the empty cells in the table based on the observed information, denoting unknown information with “?”.

|     |     |     |       |       |        |
|-----|-----|-----|-------|-------|--------|
| $i$ | $Y$ | $A$ | $Y^1$ | $Y^0$ | $\tau$ |
| 1   | 2   | 1   | 2     | ?     | ?      |
| 0   | 0   | 0   | ?     | 0     | ?      |
| 3   | 1   | 0   | ?     | 1     | ?      |
| 4   | 3   | 1   | 3     | ?     | ?      |

-   $\tau$ represents the difference which we cannot compute given that we do not know what the missing values are.


\


b\. (6’) Define the population average treatment effect for the treated (ATT) using the above notation and propose an unbiased estimator for this estimand. Then using the data in the table estimate this quantity.

$$
\text{ATT} = E[Y^1-Y^0 | A=1]
$$
-   Randomization eliminates selection bias, under the exchangeability assumption, $SB = E(Y^0|A=1) - E(Y^0|A=0) = E(Y^0) - E(Y^0)$ and thus $ATT =  E(Y^1|A=1) - E(Y^0|A=1) = E(Y^1) - E(Y^0)=ACE$ so ACE is identified and can be estimated by:

$$
\frac{1}{n_t}\sum^{n_t}_{i=1}Y_i-\frac{1}{n-n_t}\sum^{n-n_t}_{i=1}Y_i
$$
-   which the unbiased estimator for this estimand is the mean of the treated group minus mean of the control group: $2.5 - .5 = 2$.


\newpage

5. (10’) Researchers are studying the effect of **education level on income**. They believe higher education leads to better **job opportunities**, which in turn **increases income**. Additionally, they suspect that **family background** influences both education and income.

a\. Draw a DAG that includes the above variables?

```r
edu_dag <- dagify(
  Income ~ Edu_level + Job_Type + Fam_Background,
  Job_Type ~ Edu_level,
  Edu_level ~ Fam_Background
)

ggdag_status(edu_dag, text = FALSE, use_labels = "name") +
  theme_dag() +
  labs(title = "Education-Income Causal DAG")
```


b\. Is Job Type a mediator or confounder in this DAG?

  -   Job type is a mediator because it is in the causal path between education level and income. Additionally, in this DAG job type is accounting for causal effect between education level (IV) and income (DV). 
  
c\. How would you use the DAG to assess the causal effect of Education Level on Income?

-   To assess the total causal of effect of education level on income, we must also control for family background as a confounder.

\

6. (10’) You are tasked with investigating the causal effect of air pollution on asthma in children. Consider the following:

-   Parental Smoking increases the likelihood of both air pollution exposure and asthma in children.

-   Living in an urban area increases exposure to air pollution but is not directly related to asthma.

a\. Draw a DAG including the above variables.


```r
# Create the air pollution-asthma DAG
pollution_dag <- dagify(
  Asthma ~ AirPollution + Parent_Smoke,
  AirPollution ~ Parent_Smoke + Urban,
  coords = list(
    x = c(AirPollution = 0, Asthma = 2, Parent_Smoke = 1, Urban = -1),
    y = c(AirPollution = 0, Asthma = 0, Parent_Smoke = 1, Urban = 0)
  )
)

ggdag_status(pollution_dag, text = FALSE, use_labels = "name") +
  theme_dag() +
  labs(title = "Education-Income Causal DAG")
```


b\. What are the confounders you should adjust for?

-   We need to adjust for parental smoking as the counfounder in this DAG because it affects air pollution and asthma directly. 


c\. Should you adjust for Urban Living? Explain why or why not based on your
DAG.

-   Urban living only affects air pollution and not asthma directly, so we should not adjust for it as it would reduce statistical power without removing bias. There is also no backdoor path through urban living that needs be blocked. 






