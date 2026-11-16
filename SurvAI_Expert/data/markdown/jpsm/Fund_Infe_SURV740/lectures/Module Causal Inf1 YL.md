---
id: "jpsm/Fund_Infe_SURV740/lectures/Module_Causal_Inf1_YL"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Introduction to Causal Inference"
original: "Fund_Infe_SURV740/lectures/Module Causal Inf1 YL.pdf"
pages: 48
sha256: "91891a5f10044b6c8087c627d0508461ba6ed8d2efa5022e1078ff71608d5770"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:05"
---

<!-- page 1 -->

# Introduction to Causal Inference

**Yan Li**

**SURV/SURVMETH 740**

[**[email]**](mailto:[email])

1

<!-- page 2 -->

# OUTLINE

## Introduction to Causal Inference
* Correlations vs. Causation
* Individual causal effects
* Average causal effects (ACE)
* Measures of causal effects
* Measures of Association
* Causal Assumptions to Make Connections

## Directed Acyclic Graphs (DAGs)
* Marginal independence
* Conditional independence
* Rules for d-separation (d: dependence)

2

<!-- page 3 -->

# Introduction to Causal Inference

3

<!-- page 4 -->

**Simple cause and effect:**

One action directly causes one immediate result

E.g. Alarm $\rightarrow$ wake up on time; pour milk $\rightarrow$ milk comes out

**More complex causality:**

Multiple cases over time with delayed and unclear effect

E.g. eat healthy + exercises + genes... $\rightarrow$ longevity

**Causal questions (What If questions):**

* If a firm wants to raise price of produces, what *would* have happened?
* If the congress passes a law, what *would* have happened?
* What would have been the election outcome if the candidate had not been an incumbent?
* Would the two countries have fought each other if they had been both autocratic?
* How many more disadvantaged youths would get employed under the new job-training program?

4

<!-- page 5 -->

Therefore,

Causal inference is about the inference of counterfactuals: “If I intervene or change something, some specific outcome will happen?”

5

<!-- page 6 -->

## Correlations vs. Causation

- A **correlation** is a relationship that you observe between two variables that appear to be related.
- If you see a correlation between two variables in the data that does not mean there is a *casual* relationship!
- Causally unrelated variables might happen to be highly correlated with each other over some period of time.

6

<!-- page 7 -->

# E.g. divorce rate in Maine correlated per capita consumption of margarine (https://www.bbc.com/news/magazine-27537142)

## Divorce rate in Maine
correlates with
## Per capita consumption of margarine (US)

Upload this image to imgur

| | 2000 | 2001 | 2002 | 2003 | 2004 | 2005 | 2006 | 2007 | 2008 | 2009 |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| *Divorce rate in Maine*<br>*Divorces per 1000 people (US Census)* | 5 | 4.7 | 4.6 | 4.4 | 4.3 | 4.1 | 4.2 | 4.2 | 4.2 | 4.1 |
| *Per capita consumption of margarine (US)*<br>*Pounds (USDA)* | 8.2 | 7 | 6.5 | 5.3 | 5.2 | 4 | 4.6 | 4.5 | 4.2 | 3.7 |
| **Correlation: 0.992558** | | | | | | | | | | |

7

<!-- page 8 -->

# Examples of Correlations:

**1. Subway \$ vs. Pizza \$ (Inflation)**

<u>Correlation</u>: the price of a ride on the subway tends to fall and rise with the price of a slice of pizza

The prices that pizza vendors choose to set for their pizza do not actually influence the pricing that the MTA sets for the subway

**2. Bad Smells vs. Disease (Germs)**

<u>Correlation</u>: The sick tended to smell unpleasant, appear together, so the two phenomena were correlated

Both were caused by a third variable Germs

8

<!-- page 9 -->

The **difference** between correlation and causation

“Correlation helps you predict the future, because it gives you an indication of what’s going to happen. Causality lets you change the future!”

**How to estimate the causal effect quantitatively?**

9

<!-- page 10 -->

# Individual causal effects

<u>Rubin causal model:</u>

$$
A \rightarrow Y
$$

A: Intervention, exposure or treatment

Y: Outcome variable

* <u>Indicator of treatment</u> for unit $i$, where $i = 1, \dots, N$
  $$
  A_i = \begin{cases} 1 \text{ if unit } i \text{ received the treatment or under treatment} \\ 0 \text{ if unit } i \text{ did not reveive the treatment or under control} \end{cases}
  $$
* <u>Potential or Counterfactual outcome:</u> Outcome that *would* have been realized if unit $i$ received the treatment $a$ ($=0$ or $1$), denoted by
  $$
  Y_i^a = \begin{cases} Y_i^0 \text{ Potential outcome for unit } i \text{ if untreated} \\ Y_i^1 \text{ Potential outcome for unit } i \text{ if treated} \end{cases}
  $$
* <u>Actual outcome</u>: outcome actually observed based on the assigned treatment, denoted by $Y_i$.

10

<!-- page 11 -->

Example:

$$A \rightarrow Y$$

A = no heart transplant or heart transplant (0/1);

Y = alive or death (0/1)

**Data**: Zeus: heart transplant $\rightarrow$ death

* Actual outcome for Zeus is $Y_i$=death
* Potential outcome for Zeus is $Y_i^{a=0}$ and $Y_i^{a=1}$
* **Individual Causal Effect** (ICE): causal effect of the treatment on the outcome for unit $i$ is the difference between its two potential outcomes for individual $i$:

$$\tau_i = Y_i^1 - Y_i^0$$

11

<!-- page 12 -->

* <u>How potential outcomes ($Y_i^0 \text{ and } Y_i^1$) relate to observed outcome $Y_i$?</u>

  **Assumption** of **Consistency** (EPI), also called stable unit treatment value assumption (**SUTVA**) (ECON), implies no interference b/t units, one version of each treatment level:

  A subject $i$ with observed treatment level $A_i = a$ has observed outcome $Y_i$ and $Y_i = Y_i^a$. That is, observed outcome is the potential outcome of the observed treatment $a$.

  e.g. For Zeus: $Y_i^1 = 1$ is equal to his observed outcome Y=1.
  Zeus and Alice NOT influence each other and receive same version of medicine.

**Fundamental problem of causal inference: we only can observe one potential outcome for each person (No $Y_i^0$ from Zeus)**

12

<!-- page 13 -->

# Average causal effects (ACE)

Individual causal effects are fundamentally impossible

We instead focus on averages.

Assume we observe all units in the population of size $N$.

<u>Definition</u>: An average causal effect of treatment A on outcome Y is present if $E[Y^{a=1}] \neq E[Y^{a=0}]$ in the population of interest, that is “average outcome if all population units take the treatment ($a=1$) $\neq$ average outcome if all population units take no treatment ($a=0$),” can be measured by

$$
\tau = E(Y^1 - Y^0) = \frac{1}{N} \sum_{i=1}^N [Y_i^1 - Y_i^0]
$$

* Average of individual causal effect over the entire population

13

<!-- page 14 -->

For example:

$$\tau = \frac{1}{N} \sum_{i=1}^{N} [Y_i^1 - Y_i^0]$$

$Y$: systolic blood pressure (BP)

$A$: Medicaid or no Medicaid

<u>Interpretation of $\tau = \text{-20mm Hg}$</u>

In the population of hypertensive patients, if all had Medicaid, their average systolic blood pressure would be 20 mmHg lower than if they all had no Medicaid.

**The fundamental problem of causal inference still there!**

**How to identify ACE $\tau$?**

14

<!-- page 15 -->

*Example:* Zeus extended family (hypothetically)

Table 1.1

| | $Y^{a=0}$ | $Y^{a=1}$ |
| :--- | :---: | :---: |
| Rheia | 0 | 1 |
| Kronos | 1 | 0 |
| Demeter | 0 | 0 |
| Hades | 0 | 0 |
| Hestia | 0 | 0 |
| Poseidon | 1 | 0 |
| Hera | 0 | 0 |
| Zeus | 0 | 1 |
| Artemis | 1 | 1 |
| Apollo | 1 | 0 |
| Leto | 0 | 1 |
| Ares | 1 | 1 |
| Athena | 1 | 1 |
| Hephaestus | 0 | 1 |
| Aphrodite | 0 | 1 |
| Cyclope | 0 | 1 |
| Persephone | 1 | 1 |
| Hermes | 1 | 0 |
| Hebe | 1 | 0 |
| Dionysus | 1 | 0 |

**Q: What is Average Causal Effect?**

1) The proportion of individuals that would have developed the outcome had all population subjects received treatment $a = 1$ is $E(Y^1) = Pr[Y^{a=1} = 1] = \frac{10}{20} = 0.5$;

2) The proportion of individuals to develop outcome had all population subjects did not receive treatment $a = 0$ is
$E(Y^0) = Pr[Y^{a=0} = 1] = \frac{10}{20} = 0.5$.

Therefore, it does not matter whether all or none of the individuals receive a heart transplant: half of them would die in either case.

15

<!-- page 16 -->

# Measures of causal effects

## <u>Effect measures:</u>

* Causal risk difference (RD, additive scale): compute the <u>absolute number</u> of cases of a disease attributable to the treatment

$$E(Y^1 - Y^0) = \Pr[Y^{a=1} = 1] - \Pr[Y^{a=0} = 1]$$

* Causal relative risk (RR, multiplicative scale): compute how many times the risk of disease increases with treatment, compared to no treatment $\frac{E(Y^1)}{E(Y^0)} = \frac{\Pr[Y^{a=1}=1]}{\Pr[Y^{a=0}=1]}$

* Causal Odds ratio (OR): compute how many...odds of disease.....

$$\frac{\text{E}[Y^1]}{1-\text{E}[Y^1]} \bigg/ \frac{\text{E}[Y^0]}{1-\text{E}[Y^0]} \text{ or } \frac{\Pr[Y^{a=1}=1]}{\Pr[Y^{a=1}=0]} \bigg/ \frac{\Pr[Y^{a=0}=1]}{\Pr[Y^{a=0}=0]}$$

16

<!-- page 17 -->

<u>For example</u>: Imagine a large population in which 3 in a million individuals would develop the outcome if treated, and 1 in a million individuals would develop the outcome if untreated.

<u>Compute the causal RD, RR</u>
The causal risk ratio is 3 (*Having the treatment, relative to no treatment, increase disease risk by 3 times*), and the causal risk difference is 0.000002 (*2 in a million cases of the disease attributable to the treatment*)

The causal **RR** highlights how much more likely the outcome is in the treatment group, while the causal **RD** emphasizes the real-world implications of the treatment in terms of additional cases. The choice between them depends on the context and the audience for which you are presenting the findings.

17

<!-- page 18 -->

# Measures of Association

In the real world, we only get to observe one of potential outcomes

Table 1.2

| | $A$ | $Y$ |
| :--- | :---: | :---: |
| Rheia | 0 | 0 |
| Kronos | 0 | 1 |
| Demeter | 0 | 0 |
| Hades | 0 | 0 |
| Hestia | 1 | 0 |
| Poseidon | 1 | 0 |
| Hera | 1 | 0 |
| Zeus | 1 | 1 |
| Artemis | 0 | 1 |
| Apollo | 0 | 1 |
| Leto | 0 | 0 |
| Ares | 1 | 1 |
| Athena | 1 | 1 |
| Hephaestus | 1 | 1 |
| Aphrodite | 1 | 1 |
| Cyclope | 1 | 1 |
| Persephone | 1 | 1 |
| Hermes | 1 | 0 |
| Hebe | 1 | 0 |
| Dionysus | 1 | 0 |

Y: observed outcome

Using data in Table 1.2,

$\rightarrow$ Proportion of subjects that developed the outcome $Y=1$ among those subjects who happened to receive treatment value $a$ in the population

$$Pr[\text{Y} = 1|A = 1] = \frac{7}{13}; Pr[\text{Y} = 1|A = 0] = \frac{3}{7}$$

18

<!-- page 19 -->

**Associational** risk difference, risk ratio, and odds ratio are:

1) $Pr[\mathrm{Y} = 1|A = 1] - Pr[\mathrm{Y} = 1|A = 0]$

2) $\frac{Pr[\mathrm{Y}=1|A=1]}{Pr[\mathrm{Y}=1|A=0]}$

3) $\frac{Pr[\mathrm{Y}=1|A=1]/\mathrm{Pr}\,[\mathrm{Y}=0|A=1]}{Pr[\mathrm{Y}=1|A=0]/\mathrm{Pr}\,[\mathrm{Y}=0|A=0]}$

* By definition: Independent $\mathrm{Y} \perp A$ if

$$Pr[\mathrm{Y} = 1|A = 1] = Pr[\mathrm{Y} = 1|A = 0];$$

Otherwise, Y and A are associated

* Associational RD, RR and OR (association measure) quantify the strength of the association

* In our example, tables 1.1 and 1.2 show NO causal effect from A$\rightarrow$Y, but there IS an association between A and Y

19

<!-- page 20 -->

In general, $ACE = E(Y^1 - Y^0) \neq E(Y|A = 1) - E(Y|A = 0)$

*Right side: for example,*

$E(Y|A = 1)$: Expected value of $Y$ given $A=1$

* This is restricting to the subpopulation of people of actually had $A=1$. They might differ from the whole population in important ways.

  *For example*, people at higher risk for flu ($Y=1$) might be more likely to get a flu shot ($A=1$), average difference in $Y$ between the treatment group and the control group would have **selection bias** to estimate the ACE

*Left side:*

* $E(Y^1)$: mean of $Y$ if the whole population was treated
* $E(Y^0)$: mean of $Y$ if NO one in the whole population was treated

20

<!-- page 21 -->

# Assumptions to Make Connections between associational and causal effect

In order to identify Average Causal Effect:

- Recall: Stable-unit-treatment-value-assumption (**SUTVA**), also called **Consistency** (in Epidemiology):

$$
E(Y^a|A = a) = E(Y|A = a)
$$

- **Ignorability or Unconfoundedness or Exchangeability**

$$
E(Y^a|A = a) = E(Y^a|A \neq a) = E(Y^a)
$$

  - If $a=0$, $E(Y^0|A = 0) = E(Y^0|A = 1) = E(Y^0)$: The mean potential outcome under <u>control</u>, $Y^0$, for those in the *control* group ($A=0$) is same as those in the treatment group ($A=1$).

21

<!-- page 22 -->

* If $a=1$, $E(Y^1|A = 1) = E(Y^1|A = 0) = E(Y^1)$: The mean potential outcome under <u>treatment</u>, $Y^1$, for those in the *treatment* group ($A=1$) is same as those in the *control* group ($A=0$).

In summary, treated and the untreated would have experienced the same risk of outcome if they had received the same treatment level (either $A = 0$ or $A = 1$). This means that the individuals in the treatment and control groups are ***exchangeable***. We have:

$$
ACE = E(Y^1) - E(Y^0) = E(Y^1|A = 1) - E(Y^0|A = 0)
$$

This assumption can be achieved by **random assignment** of individuals to treated and untreated group (in a randomized experiment).

22

<!-- page 23 -->

* **Positivity**

  There is a probability greater than zero–a **positive** probability–of being assigned to each of the treatment levels.

$$1 > \Pr(A = a) > 0 \text{ for all } a$$

  There are no certain individuals (groups) are always treated or never treated.

**Example**:

a) Assuming positivity assumption hold, use the hypothetical data provided (next slide) to assess the two assumptions: Consistency, Exchangeability.

b) If all three assumptions (Consistency, Exchangeability, and Positivity) hold, can the causal risk difference (RD) be estimated using the associational RD?

23

<!-- page 24 -->

| id | **A** | $Y^1$ | $Y^0$ | **Y** |
|---:|---:|---:|---:|---:|
| 1 | **1** | 10 | 3 | **10** |
| 2 | **1** | 16 | 5 | **16** |
| 3 | **1** | 14 | 7 | **14** |
| 4 | **1** | 12 | 10 | **12** |
| 5 | **1** | 16 | 9 | **16** |
| 6 | **1** | 10 | 11 | **10** |
| 7 | **1** | 8 | 13 | **8** |
| 8 | **1** | 9 | 5 | **9** |
| 9 | **1** | 13 | 7 | **13** |
| 10 | **1** | 13 | 10 | **13** |
| 11 | **1** | 19 | 9 | **19** |
| 12 | **1** | 17 | 11 | **17** |
| 13 | **1** | 12 | 4 | **12** |
| 14 | **0** | 10 | 6 | **6** |
| 15 | **0** | 8 | 8 | **8** |
| 16 | **0** | 13 | 10 | **10** |
| 17 | **0** | 16 | 5 | **5** |
| 18 | **0** | 9 | 6 | **6** |
| 19 | **0** | 15 | 13 | **13** |
| 20 | **0** | 20 | 8 | **8** |

24

<!-- page 25 -->

**Consistency**: observed outcome under the actual treatment a subject received $Y|A=a$ is equal to the potential outcome under that treatment $Y^a$. In other words, for a subject who received treatment ($A = 1$), their observed outcome ($Y$) should equal their potential outcome $Y^1$ (outcome if treated). Similarly, for a subject who did not receive treatment ($A = 0$), their observed outcome should equal $Y^0$ (outcome if untreated): Check if the observed outcome $Y$ matches the corresponding potential outcome ($Y^1$ for treated, $Y^0$ for untreated) for each individual.

To assess **Exchangeability** using the provided data, we need to check whether the potential outcome distributions are comparable between the treated ($A=1$) and untreated ($A=0$) groups: you would typically visualize the distributions of $Y^1$ and $Y^0$ in each group using histograms or summary statistics or some statistical testing.

25

<!-- page 26 -->

# Directed Acyclic Graphs (DAGs)

26

<!-- page 27 -->

# Directed Acyclic Graphs (DAGs)

We can describe the assumed causal relationships by DAGs.

“**Directed**” because each arrow implies a direction: because the arrow from A to B is into B, A may cause B, but not the other way around.

“**Acyclic**” because there are no cycles: a variable cannot cause itself, either directly or through another variables.

DAG composed of:
* Nodes: representing variables in the causal model
* Directed edges or arrows: representing possible causal effect

27

<!-- page 28 -->

* $A \rightarrow Y$

  This is a directed graph with two nodes $A$ and $Y$ and 1 edge from $A$ to $Y$ ($A \rightarrow Y$)

* $A - Y$

  This is an undirected graph

In summary:

Directed acyclic graphs (DAGs)
1. No undirected paths
2. No cycles

28

<!-- page 29 -->

# Causal diagrams and marginal independence

Figure 1: $\text{A} \longrightarrow \text{Y}$

- Causal effect from A to Y.
- $\Pr[Y^{a=1} = 1] - \Pr[Y^{a=0} = 1] = E(Y^1 - Y^0) \neq 0$
- Individuals are randomly assigned to heart transplant (A) with the same probability to study causal effect from A to Y (death)
- Suppose individuals are randomly assigned to heart transplant ($A$) with a probability that depends on their *disease severity* ($L$).

29

*[Figure: The page contains a simple causal diagram labeled "Figure 1" that shows a directed arrow pointing from variable A to variable Y, representing a direct causal effect of A on Y without any other variables or axes.]*

<!-- page 30 -->

Figure 2: $L \longrightarrow A \longrightarrow Y$

* Information from L flows to both A and Y (<u>Fork</u>)
* E.g., $L$ (disease severity) is a common cause of A (Heart Transplant) and Y (Death), $L$ is called confounder.

* Information also flows from $L \rightarrow A \rightarrow Y$ (<u>Chain</u>).
* Effect of L on Y is not direct but occurs through A, and A is a mediator between L and Y

30

*[Figure: Figure 2 shows a directed acyclic graph (DAG) with three nodes—L, A, and Y—and no axes. The diagram illustrates causal relationships with straight arrows pointing from L to A and from A to Y, as well as a curved arrow pointing directly from L to Y, representing both a fork (confounding by L) and a chain (mediation through A).]*

<!-- page 31 -->

Figure 3

$L \longrightarrow A \quad Y$

* Information flow from L to A and from L to Y, but there is no information flow from A to Y

* E.g. Cigarette smoking (L) has a causal effect on both carrying a lighter (A) and lung cancer (Y). However, carrying a lighter has NO causal effect on anyone’s risk of lung cancer, i.e., $\Pr[Y^{a=1} = 1] = \Pr[Y^{a=0} = 1]$

**Question: Are A and Y marginally independent (no statistical association), i.e., $\Pr[Y = 1 | A = 1] = \Pr[Y = 1 | A = 0]$ in Figures 1 - 3?**

31

*[Figure: Figure 3 is a directed acyclic graph (causal diagram) with no axes that shows the relationships among three horizontally aligned variables: L, A, and Y. It displays a straight arrow pointing from L to A and a curved arrow arching over A from L to Y, with no arrow connecting A directly to Y, illustrating that L is a common cause of both A and Y while A has no causal effect on Y.]*

<!-- page 32 -->

Figure 4

$$\text{A} \quad \text{Y} \longrightarrow \text{L}$$

* Both A and Y affects L (collider), no information flow from L to either A or Y (<u>Inverted forks</u>). No information can be reached from A to Y or Y to A (collision).
* E.g. A is "getting the flu" and Y is "getting hit by a bus," with L "being in the hospital." Getting the flu doesn't cause someone to get hit by a bus, so no causal effect of A on Y.
* E.g. Haplotype A does not have a causal effect on air pollution (Y); however, both haplotype A and air pollution (Y) do have causal effects on lung cancer (L).

**Q: A and Y are marginally independent in Figure 4?**

32

*[Figure: The figure is a simple directed acyclic graph (DAG) labeled "Figure 4" showing three horizontally aligned nodes: A, Y, and L. It illustrates a collider structure where both node A (via a curved top arrow) and node Y (via a straight horizontal arrow) point directly into node L, with no arrow connecting A and Y directly.]*

<!-- page 33 -->

### **<u>In Summary from Figures 1-4</u>**

Two variables are (marginally) associated/correlated if one causes the other, or if they share common causes. Otherwise, they will be (marginally) independent (e.g. if they have common effect).

33

<!-- page 34 -->

# Causal diagrams and <u>conditional</u> independence

Figure 5: $\text{A} \longrightarrow \boxed{\text{B}} \longrightarrow \text{Y}$

* The box placed around the node B: Restrict the analysis to the subset of individuals with specified level of B

* In the subset of individuals, say B = 0, treatment A and outcome Y are independent: $\Pr[Y = 1 | A = 1, B = 0] = \Pr[Y = 1 | A = 0, B = 0]$

**<u>Question:</u> is there an A-Y association within levels of B (conditional independent)?**

E.g., parental involvement $\rightarrow \boxed{\text{study time}} \rightarrow$ academic performance

Graphically, a box placed around variable B blocks the flow of information through the chain path $\text{A} \rightarrow \text{B} \rightarrow \text{Y}$.

34

*[Figure: The page shows a causal diagram ("Figure 5") consisting of three nodes labeled A, B, and Y arranged in a linear chain with no axes. Directed arrows point from A to B and from B to Y, with a three-sided rectangular box enclosing node B to indicate conditioning on that variable, which blocks the causal flow between A and Y.]*

<!-- page 35 -->

Figure 6

**<u>Question:</u> is there A - Y association conditional on L?**

* Even though A and Y are marginally associated, A and Y are conditionally independent given L
* E.g. Given a specified smoking level (L), the risk of lung cancer (Y) is the same for people with and without lighters (A): $P[cancer = 1|ligher = 1, smk = l] = P[cancer = 1|lighter = 0, smk = l]$ for all $l$

Graphically, the flow of information between A and Y is interrupted because the fork path is $\text{A} \leftarrow \text{L} \rightarrow \text{Y}$ is blocked by the box round L.

35

*[Figure: Figure 6 is a causal directed acyclic graph (DAG) with no axes, comparing the causal relationships among three variables labeled L, A, and Y. It shows variable L enclosed in a square box (indicating conditioning), with directed arrows pointing from L to both A and Y, and no direct arrow between A and Y, illustrating that conditioning on the common cause L blocks the path between A and Y.]*

<!-- page 36 -->

Figure 7

$$A \quad Y \longrightarrow \boxed{L}$$

**<u>Question</u>: is there an A - Y association conditional on L?**

* Back to haplotype/air pollution example: <u>Given a subject with lung cancer (L),</u> the absence of haplotype A provides insight into her air quality. Without haplotype A, it is more likely that another cause of lung cancer, air pollution, is contributing to the outcome
* Back to flu/bus example: conditional on <u>being in the hospital (L),</u> there is negative relationship between the flu and getting hit by bus (A and Y).

Graphically, A and Y are conditionally and inversely associated within levels of their common effect L.

36

*[Figure: Figure 7 is a directed acyclic graph showing three variables: A, Y, and L, where L is enclosed in a square box to indicate conditioning. A curved arrow points from A to L and a straight arrow points from Y to L, illustrating that L is a conditioned common effect (collider) of two independent variables A and Y.]*

<!-- page 37 -->

Figure 8

$$A \quad Y \longrightarrow L \longrightarrow \boxed{C}$$

- A and Y are conditionally and inversely associated within levels of C because C is a common effect of A and Y.
- E.g. back to haplotype/air pollution example

  C: Steroids medication, whose use is a consequence of a diagnosis of lung cancer.

37

*[Figure: Figure 8 is a directed acyclic graph (DAG) with no axes, showing four horizontally aligned nodes labeled A, Y, L, and C (with C enclosed in a square box to indicate conditioning). The diagram illustrates a collider pattern where both A (via a curved top arrow) and Y (via a straight arrow) point directly into L, which in turn points via a straight arrow into the boxed node C.]*

<!-- page 38 -->

### **<u>In summary</u>**

Three structural reasons why two variables may be *associated* (information flow from one to the other variable):

* One causes the other (chains)
* They share common causes (fork)s, or
* They share a common effect but the analysis is restricted to certain level of that common effect (conditional on colliders or their descendants).

38

<!-- page 39 -->

# Blocking information to achieve independence

- $\text{A}\rightarrow\text{G}\rightarrow\text{B}$: Condition on G in <u>Chains</u>, we block the path A to B, For example: Outside temp. $\rightarrow$ Whether or not sidewalks are icy $\rightarrow$ whether or not someone falls.
- Conditional on the confounders in <u>Forks</u>
- Unconditional on <u>Colliders or their descendants</u>
  1. A is the state of an on/off switch
  2. B is the state of a different on/off switch
  3. G is whether the lightbulb is lit up

  A and B are *independent*: If I tell you that B is on, it tells you nothing about A; A and B are *dependent*: Given G, if I tell you that the light is off (G), then A must be off if B is on, and vice versa. You open a path by blocking G.

39

<!-- page 40 -->

## Rules for d-separation of a path

- Control for a set of notes (C) that separate two variables on given paths to achieve independence between variables:

  - Contains a <u>chain</u> and the middle part of the chain is in C
  - Contains a <u>fork</u> and the middle part of the fork (i.e. the confounder) is in C
  - Contains an <u>inverted fork</u> and the middle part of the fork (i.e. the collider or any descendants of it) is **<u>not</u>** in C

Two nodes, A and B, are <u>d-separated</u> by a set of nodes C if C blocks every path from A to B, denoted by $A \perp B | C$.

40

<!-- page 41 -->

## Example:

Identify all nodes: X, Y, $Z_1, Z_2, Z_3$

Identify all paths from X to Y:

$$X \leftarrow Z_3 \rightarrow Y$$

$$X \leftarrow Z_1 \rightarrow Z_3 \rightarrow Y$$

$$X \leftarrow Z_3 \leftarrow Z_2 \rightarrow Y$$

$$X \leftarrow Z_1 \rightarrow Z_3 \leftarrow Z_2 \rightarrow Y$$

Figure 9

$Z_1$ is parent of X and $Z_3$; X and $Z_3$ are children of $Z_1$

$Z_1$ is ancestor of Y. Y is a descendant of $Z_1$

* $X$ and $Y$ are d-separated by set $\text{C}=\{Z_1, Z_2, Z_3\}$. How about $\{Z_3\}$ or $(Z_2, Z_3)$ or $(Z_1, Z_3)$ or $(Z_1, Z_2)$?
* List C variables to d-separate $Z_1$ and $Z_2$?

41

*[Figure: Figure 9 shows a directed acyclic graph (DAG) with no axes, comparing the causal or conditional relationships among five nodes labeled $X$, $Y$, $Z_1$, $Z_2$, and $Z_3$. The main pattern illustrates $Z_3$ as a central node receiving arrows from parent nodes $Z_1$ and $Z_2$ while sending arrows to child nodes $X$ and $Y$, alongside direct arrows from $Z_1$ to $X$ and from $Z_2$ to $Y$.]*

<!-- page 42 -->

Pearl’s back-door criterion is a way to <u>rule out</u> confounding via conditioning, thus identifying the causal effect of one variable on another. For identifying the causal effect of X on Y, the backdoor criterion has two parts:

<u>First</u>, the conditioning set C may not include any descendent of X. That means, anything that X affects cannot be conditioned on (c.f. post-treatment bias).

<u>Second</u>, the conditioning set C must block all back-door paths from X to Y. That is, by conditioning on our set C, we should break any back-door paths that may simultaneously generate confounded covariance in X and Y.

42

<!-- page 43 -->

* Which of the following are NOT back door paths from $X$ to $Y$?
1. $X \leftarrow Z_3 \rightarrow Y$
2. $X \rightarrow W_3 \rightarrow Y$
3. $X \leftarrow W_1 \leftarrow Z_1 \rightarrow Z_3 \rightarrow Y$
4. $X \leftarrow Z_3 \leftarrow Z_2 \rightarrow W_2 \rightarrow Y$
5. $X \leftarrow W_1 \leftarrow Z_1 \rightarrow Z_3 \leftarrow Z_2 \rightarrow W_2 \rightarrow Y$

Figure 10

* Which set of variables should be controlled for in order to identify the causal effect from $X$ to $Y$?
  a) $\{W_1, W_2\}$; b) $\{Z_1, Z_2\}$; c) $\{Z_1, Z_3\}$; d) $\{Z_3, W_3\}$; e) $\{Z_3\}$

43

*[Figure: The image contains a directed acyclic graph (DAG) labeled "Figure 10" that has no coordinate axes and illustrates causal pathways among eight nodes: $X, Y, W_1, W_2, W_3, Z_1, Z_2,$ and $Z_3$. The diagram shows a direct causal path from $X$ to $Y$ through $W_3$ ($X \to W_3 \to Y$), alongside several confounding back-door paths connecting $X$ and $Y$ via the upper nodes $Z_1, Z_2, Z_3, W_1,$ and $W_2$.]*

<!-- page 44 -->

**In-class practices:**

1. Researchers are studying the relationship between **physical activity** and **heart disease**. They believe the following factors are relevant:
    * **Age** (Older people tend to exercise less and are more prone to heart disease.)
    * **Smoking** (Smoking is associated with lower levels of physical activity and increased risk of heart disease.)
    * **Genetic Predisposition** (Some individuals are genetically predisposed to heart disease, regardless of their physical activity level.)

1) Draw a DAG that represents the relationships above.
2) What are the potential confounders? Should you adjust for them?

44

<!-- page 45 -->

2. In a study on the effects of **diet** on **diabetes**, researchers collect data from individuals attending a specialized clinic. They believe the following relationships exist:

   - **Exercise** reduces the risk of diabetes.
   - **Diet** and **Exercise** are related (people who exercise are more likely to maintain a healthy diet).
   - **Clinic Attendance** is influenced by both **Exercise** and **Diabetes** (people who exercise less and have diabetes are more likely to attend the clinic).

1) Draw a DAG for this scenario, including the above variables.
2) What is the variable **Clinic Attendance** called in DAG?
3) What impact would adjusting for **Clinic Attendance** have on the analysis of the relationship between **Diet** and **Diabetes**?

45

<!-- page 46 -->

3. Researchers are studying the effect of **education level** on **income**. They believe that **job type** is a mediator (i.e., higher education leads to better job opportunities, which in turn increases income). Additionally, they suspect that **family background** influences both **education** and **income**.

**Questions:**

1) Draw a DAG that includes the above variables.
2) Is **Job Type** a mediator or confounder in this DAG?
3) To measure direct causal effect from education on income, what are the variables you need to control?

46

<!-- page 47 -->

4. You are tasked with investigating the relationship between **air pollution** and **asthma** in children. Consider the following:

* **Parental Smoking** increases the likelihood of both **air pollution exposure** and **asthma** in children.
* **Living in an urban area** increases exposure to **air pollution** but is not directly related to **asthma**.

**Questions:**

1) Draw a DAG including the above variables.

2) What are the confounders you should adjust for?

3) Should you adjust for **Urban Living**? Explain why or why not based on your DAG.

47

<!-- page 48 -->

## R package to draw DAG

```r
# Install the packages if not already installed
install.packages("ggdag")
install.packages("dagitty")
install.packages("ggplot2")

library(ggdag)
library(dagitty)
library(ggplot2)

####-----Example
dag = dagify(y.HrtDis ~ x.Phy.Act + Age + Smoking + Gene,
            x.Phy.Act ~ Age + Smoking,
            exposure = "x.Phy.Act",
            outcome = "y.HrtDis")

ggdag(dag, node_size=20, text_size=3.5, edge_type="link",label_size = 4)
 + theme_dag_blank()
```

48
