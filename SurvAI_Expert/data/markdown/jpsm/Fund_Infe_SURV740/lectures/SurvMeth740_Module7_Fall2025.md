---
id: "jpsm/Fund_Infe_SURV740/lectures/SurvMeth740_Module7_Fall2025"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "lecture"
title: "Fundamentals of Inference"
original: "Fund_Infe_SURV740/lectures/SurvMeth740_Module7_Fall2025.pdf"
pages: 53
sha256: "3b05f98c811b7bcd7cadd532b1eabc23575beab17e0d8a801f666424bed46efc"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:04"
---

<!-- page 1 -->

# Fundamentals of Inference

Barry Graubard([email])
SurvMeth / Surv 740
Module 7, Fall 2025

1

<!-- page 2 -->

# Agenda for Today

* Course content overview
* **Module 7:** An Overview of Different Methods for Conducting Statistical Inference (primarily with survey data)

2

<!-- page 3 -->

# Readings

* Available via Canvas
* In general, these are **foundational** articles
* Some are difficult...
  - Read get sense of the ideas
  - Discuss with other students
  - Ask questions in class

3

<!-- page 4 -->

# Grading

* Homework:
  - Assignments **available** via Canvas
  - Please **submit** via Canvas

4

<!-- page 5 -->

# OVERVIEW

5

<!-- page 6 -->

# Topics in Inference

* **Methods for Making Finite Population Inference**

  * **Design-Based**
    * **Random Sample Surveys**
    * Randomized Experiments
  * vs.
  * **Model-Based**
    * **Frequentist**
    * **Bayesian**

* **Add Superpopulation Model to Finite Population**

  * **Superpopulation**
    * **Design-Based**
      * **Random Sample Surveys**
      * Randomized Experiments
    * vs.
    * **Model-Based**
      * **Frequentist**
      * **Bayesian**

6

<!-- page 7 -->

# Overview: Modes of Inference

* Each method makes different assumptions
  - **Design-based** inference **(nonparametric)**
  - Adding superpopulation inference (**model-based**)
  - Frequentist and Bayesian finite population inference (**model-based**)
* These differences are important to understand and appreciate conceptually

7

<!-- page 8 -->

# Overview: Use of Auxiliary Data

* How do we make use of information that we have about the population or full sample?
* How can we improve statistical inference using auxiliary data?
* Covered in Weeks 10-12

8

<!-- page 9 -->

# METHODS OF INFERENCE

9

<!-- page 10 -->

# Basic Concepts: Agenda

* Inference
* Inductive vs. Deductive Reasoning
* Design-Based vs. Model-Based Approaches

10

<!-- page 11 -->

# Basic Concepts: Inference

* **Inference (one definition):**

*“The process of deducing properties of the underlying distribution by analysis of data.”*
  – <u>A Dictionary of Statistics</u>, Upton and Cook, 2008

* Usually accomplished using a sample from a population (Finite or Infinite (superpopulation) or Both)

* ***What is an “underlying distribution”?***

11

<!-- page 12 -->

# Basic Concepts: Inference

* **Inference**:

*"Statistical inference is the process of drawing conclusions about an underlying population based on a sample or subset of the data."*

  – <u>An Introduction to Environmental Forensics</u>, Gauthier and Hawley, 2015

* ***What is the difference between a “sample” and a “subset”?*** *Is a sample a type of subset?*

12

<!-- page 13 -->

# Basic Concepts: Inductive/Deductive

* Goal of any statistical analysis: Infer, including estimating, about a quantity of interest (usually a **unknown parameter**, such as a proportion or a regression parameter) based on a sample of observations
* Two reasoning or logical approaches:
  - **Inductive** reasoning: Use the particular (sample) and draw conclusions about the general population (**Bayesian**)
  - **Deductive** reasoning: Theory is used to develop a set of hypotheses, predict data that would be observed under the theory, and compare the prediction with the actual sample observations (**Fequentist**)
* **Probability methods** play several roles including planning of the study, sample selection and inferential statements

13

<!-- page 14 -->

# Basic Concepts: Inductive/Deductive

* Consider tossing a fair coin
* We want to know the probability of observing a “head”
* Inductive reasoning: *What would we do?*
* Deductive reasoning: *What would we do?*

14

<!-- page 15 -->

# Basic Concepts: Inductive/Deductive

* We want to know the probability of observing a “head” (**parameter** = proportion of heads)
* **Inductive:** flip a coin “n” times, count the number of heads (generate sample of data first!)
  * Example: Flip a coin 5 times, 3 heads, $\text{Pr}(\text{“Heads”})=0.6$
  * Example: Flip a coin 1000 times, 499 heads, $\text{Pr}(\text{“Heads”})=0.499$ (<u>infer</u> what the **parameter** is!)
* **Deductive:** Theory implies neither side is more likely. Expect $\text{Pr}(\text{“Heads”})=\text{Pr}(\text{“Tails”})=1/2=0.5$.
  * Now, flip a coin 1000 times, 499 heads.
  * What do I conclude about my theory? Compare the specific data to what the theory predicted/expected.

15

<!-- page 16 -->

# Design-Based and Model-Based Inference

* **Design-based inference**:
  - Values for survey variables of interest in a clearly defined finite population are **fixed**
  - Inference is based on probability distribution of a sample selection indicator (the **random** variable)
  - Assumes that we have a **probability sample** (or “quasi-randomization”, where we usually estimate probabilities, using a model)
* **Model-based inference:**
  - Values for survey variables of interest are assumed to come from a statistical model (e.g., linear regression model with dependent variable normally distributed)
  - Probability sampling can be used to obtain the sample and taken into account in the modeling.

16

<!-- page 17 -->

# Design-Based and Frequentist Inference

* Probability of an event, A (flipping a head), is the limit of the relative frequency of the number times the event A occurs among all possible events (flipping a head or tail), in the infinite number of identical replications / trials of the experiment (flipping a coin).
  - To what relative frequency do we converge after infinity trials? (assuming a fair coin)
* Any “event” has to be a result of an experiment, or we must construct some thought experiment to develop the construct “probability”
* No probability statement can be made if an “event” cannot be construed as a result of a (repeatable) experiment.

17

<!-- page 18 -->

# Design-Based and Frequentist Inference

* What is a <u>confidence interval</u> in this view?
  - The population parameter, e.g., $\mu$, is **fixed**
  - The interval bounds are **random** (varying across samples), and a function of the sample size
  - Interpretation of a 95% CI: “In 95% of samples I could draw under this specific design, the true mean $\mu$ would be within the confidence interval.”
  - An admittedly awkward interpretation for one sample! (Do you agree? Not me)

18

<!-- page 19 -->

# Design-Based and Frequentist View on Inference

* Design-Based & Frequentist inference uses this view of probability in constructing inferences
* Repeated sampling $\rightarrow$ many “experiments”, where with a large number of repeated random samples, the distribution of what we are trying to estimate becomes clearer. **Some key concepts:**
  – Unbiased
  – Sampling Variance
  – Mean squared error
  – P-value
  – Consistency

19

<!-- page 20 -->

# Bayesian View on (Probability) Inference

* Bayesian inference is quite subjective
  * Given **prior beliefs** about the distribution of some parameter of interest, **data**, and a **model** for those data, what is the **updated probability** that the parameter of interest falls within certain values?
  * Two individuals with the same information could arrive at different probabilities for the same event
  * Very subjective (“I have my prior beliefs and my model, and you have yours”)

* Much broader view
  * An experiment could be used to come up with the probability, but it is **not necessary** that the event should be a result of repeated, replicable experiments; (valid inference (under the model assumptions) without assuming repeated sampling)

* Any unknown implies uncertainty about the unknown, e.g. model/population parameters like regression coefficients, and hence is subject to a probabilistic statement.

* Prior knowledge about the population parameter of interest is updated by the sample data (not the case for Design-Based and Frequentist methods).

20

<!-- page 21 -->

# Bayesian <u>Credible</u> Interval

* Once a **model** has been specified, then statements about probability are possible
* For Bayesians, the parameter, e.g., $\mu$, is **random**, and the bounds are **fixed**
* Interpretation of 95% credible interval: “The true value of the parameter, e.g. $\mu$, falls within these bounds with probability $0.95$.”

21

<!-- page 22 -->

# Superpopulation Theory

* In **Design-Based** approach interest is in the finite population parameters (finite population means , variances), which are are fixed.
  * The **random selection** of the sample according to a sample design provides the sampling error.
  * Inductive inference is used for going from the sample to the target finite population

* **Superpopulation**: We imagine it as an infinite population (IF) or stochastic process (SP), e.g., an assumed normal distribution, that generates the “fixed” finite population as a finite random sample from IF or SP. In both cases the superpopulation is based on a model.
  * Under a superpopulation the Census values for a finite population have variance/sampling error, i.e., NOT fixed values.
  * Cochran: “...it is far removed from reality to regard the population as a fixed batch of known numbers.”
  * Superpopulation model can address variability in estimates due to the finite population being a sample (not fixed) from the superpopulation. E.g., this can account for changes in finite population over time such as occurs for annual surveys.
  * Can use a **statistical model (a.k.a. a superpopulation model)** method to account for the additional variability:

↓ Variability

↓ Variability

**Superpopulation**

22

<!-- page 23 -->

# Summary

* Model-based approaches
  * Bayesian
  * Frequentist

* Design-based (**Randomization Inference** ) and Frequentist approaches
  * Adding superpopulation component to the inference adds additional model assumptions.

* Different views on probability basis of the inference.

* These views (can) acknowledge the importance of the sample design

23

<!-- page 24 -->

# HOW DOES INFERENCE FIT INTO RESEARCH?

24

<!-- page 25 -->

# Steps in Research Investigations

* What are the research questions and what needs to be estimated and are the hypotheses to be tested?
  * Often it is a “general purpose” study is designed for many estimates and hypotheses to be tested

* Design (including cross-sectional, longitudinal, case-control [choice-base sample], etc.) and conduct the study/data collection/survey and to obtain sample of observations

* Consider probabilistic frameworks to draw **inference** about the hypotheses based on the data collected (i.e., sample size, degrees of freedom for variance estimation, expected power, sophistication of investigators, etc.)

25

<!-- page 26 -->

# Research Investigations

* Address the scientific question given the study design
  - Objective is analytic vs. descriptive? Both can use models with parameters, if so, need to formulate statistical models
    e.g., analytic linear regression model : $y_i = \beta_0 + x_i\beta_1 + \epsilon_i$;
    changing $X$ will change $Y$ or descriptive to estimate the mean of Y for different X’s.
  - The research hypotheses can be formulated as parameters or features of the model (e.g., in a regression is $\beta_1 > 0$)
  - Probabilistic inference about the parameter becomes the goal (Design-based or Model-based? Using modeling in Frequentist or Bayesian? Accounting for Superpopulation in Design based?)

26

<!-- page 27 -->

# Research Investigations (Contd.)

* Study features of a **finite population**
  * A finite, well-defined population consists of N units
  * A survey variable of interest, Y, on these N units are
    $$Y_1, Y_2, \cdots, Y_N$$
  * The goals is to draw inference about some function of these N values,
    $$Q(Y) = Q(Y_1, Y_2, \cdots, Y_N)$$
  * $Q(Y)$ could be a mean, mode, quartile, proportion,..., etc. for the finite population.
  * Note that $Q(Y)$ is a computable quantity, if all N values are known (from a Census).

27

<!-- page 28 -->

# Surveys

* Surveys are a particular type of **research investigation**

* Surveys are often used to estimate **characteristics** of a population

* Surveys are also used for analytically studying associations and relationships often with regression.

* For special studies involving randomized **experiments** can be conducted within surveys
  - *For example, do differences in wording lead to different response distributions and associations?*

28

<!-- page 29 -->

# Survey Inference

* Survey inference **depends upon the design**
  - **Design-based framework**: what will the sampling distribution look like under <u>repeated sampling</u> following the same randomized design? Cluster sampling, stratification, etc.
  - **Model-based framework**: Is the design ignorable or should it included in the model?
* Let’s start with an overview of survey inference
  - Accounting for sample design, nonresponse

29

<!-- page 30 -->

# Survey Inference

* Draw a sample of size $n$ from the population of size $N$ to obtain the values of $Y$ on the $n$ sampled units.

* Use these values to infer about some quantity of interest $Q(Y)$ *(e.g., a proportion)*.

* General principle in drawing sample:
  - **Probability sample**: Every subject/unit in the target population should have a positive and <u>known</u> probability of being included in the sample.
  - **Non-probability sample**: Some/all subjects have an <u>unknown</u> probability of being included in the sample.

30

<!-- page 31 -->

# Survey Sample Design

* EPSEM: <u>E</u>qual <u>P</u>robability of <u>Se</u>lection <u>M</u>ethod from a population of size $N$ with the same sample size $n$.
  - Every subject/unit in the population has the same probability of being included in the sample, $n/N$.

  - Example 1: A simple random sample without replacement (srswor)
    * Every sample of size n from the population has the same chance of being selected. What is the chance? $1/\binom{N}{n}$
      How do you get $n/N$ above for srswor? $\binom{N-1}{n-1}/\binom{N}{n} = n/N$.

  - Example 2: For stratified srswor divide the population of $N$ units into $H$ strata with $N_h$ units in stratum $h = 1, 2, \dots, H$. Select a srswor of size $n_h = n \times N_h/N$ from stratum $h$, i.e., proportional stratified srswor. For each subject/unit in stratum $h$ its probability of selection but $\frac{n_h}{N_h} = \frac{n \times N_h/N}{N_h} = \frac{n}{N} \implies EPSEM$

31

<!-- page 32 -->

# Survey Sample Design (Cont.)

* Non-EPSEM designs are common (varying probabilities of selection)
  - Introduces weights vary for sampled units
* Clustering is also very common (especially in the face-to-face household surveys) for reducing the costs, e.g., interviewer travel
  - Example: Two-stage cluster sample
    * Population is divided into clusters
    * A random sample of clusters is first selected, and then units within the sampled clusters are randomly subsampled
  - Multistage cluster sampling is common, e.g., household surveys
* **Complex Sample Design:** Stratification, Cluster Sampling, and Weighting
* **Sampling error:** Error because only a sample is observed instead of the entire population (Census)

32

<!-- page 33 -->

# Sample selection

* **Target population:** Population for which inference is needed
* **Sampling Frame:** A listing, e.g., addresses or records like birth certificates, used to select the sample from the target population
* Ideally, the sampling frame will include the entire target population, but sometimes it may not
    * This introduces coverage error
    * Sampling frame: A telephone survey uses a cellular RDD frame to select a sample of adults (18 years of age or older)
    * Target population: All adults living in the United States
    * Not covered: Those adults who do not have a working cellular phone
    * Assumption: Adults with and without cellular phones are similar on variables of interest (if not, coverage error!)

33

<!-- page 34 -->

# Nonresponse Error

* Not all units selected will cooperate in providing the survey variables of interest
* This introduces, potentially, a bias in the sample when responding and non-responding units are systematically (not randomly!) different.
* **Assumption:** The differences between respondents and non-respondents can be removed via adjustment using all available variables
* Both coverage and nonresponse error adjustments make unverifiable assumptions $\rightarrow$ "quasi-randomization" and MAR (missing at random)
* There are other types of errors such as measurement error, processing error, etc. ("Total Survey Error")
* For now, we focus only on <u>sampling error</u> (that is, uncertainty due to observing a sample rather than the population) and assume there are no other errors.

34

<!-- page 35 -->

# Design-Based Framework

* Also called “Randomization Inference”
* Focus on randomization
  – Inference accounts for all features of randomization, e.g., sampling probabilities, cluster sampling, etc.

35

<!-- page 36 -->

# Design- vs. Model-Based Inference

* Design-based inference
  * Seek estimators with good repeated sampling properties, either unbiased or consistent
  * We will review those properties
  * However, it can be shown many estimators have an implicit model
    * For example, ratio or regression estimation
* Limitations
  * Theory starts from probability sampling with 100% response rate
  * Relies on asymptotics $\rightarrow$ statistical properties, e.g., consistency of the estimators with increasingly large samples

36

<!-- page 37 -->

# Design-Based Framework

- Basic structure
  - Finite population is a collection of $N$ <u>constants</u>, $Y_1, Y_2, \cdots, Y_N$
  - Estimand of interest: $Q(Y) = Q(Y_1, Y_2, \cdots, Y_N)$
    - Examples: population mean, population total, population variance, population regression coefficient, etc.
  - <u>Randomness</u> comes from which elements are selected to form a sample
  - Define a sampling indicator $I_j$ for $j = 1, 2, \dots, N$:
    $I_j = 1$ if finite population unit $j$ is included in the sample
    $I_j = 0$ otherwise

37

<!-- page 38 -->

# Sample Design

* Distribution of the sampling indicators
* Start from inclusion probabilities of being in the sample:

$$\pi_j = Pr(I_j = 1)$$

* More generally, this joint probability distribution:

$$Pr(I_1, I_2, \dots, I_N)$$

* These sampling indicators $I_j$ may be correlated
  - Examples
    * Selection without replacement
    * Cluster sampling

38

<!-- page 39 -->

# Inference

* A procedure is developed for estimating finite population parameter $Q(Y_1, Y_2, \cdots, Y_N) = Q(Y)$, which when applied to the sample data gives us an estimate, $q(y_1, y_2, \cdots, y_n) = q(y)$.
* One can come up with lots of procedures.
  - For example, taking the case nearest the middle of the sorted list is the estimator of the sample mean
  - Or even nonsensical: take the first five cases from the sorted list, sum their values, add 6, divide by 10, and call that the estimator of the sample mean
* *How do we judge the desirability of these procedures?*

39

<!-- page 40 -->

# Inference

* Consider the design-based approach first
* Repeated sampling concept:
  - Many samples are possible, as specified by the distribution of the sampling indicator
  - Each sample includes different elements of $Y$ (from finite population) and can gives us a different estimate.
  - The many estimates $q(y)$ form a **sampling distribution.**
  - Study the properties of estimates across all possible samples (e.g., what is the standard deviation of the sampling distribution? Sampling variability?)

40

<!-- page 41 -->

# Sampling Distribution

* Hypothetical **sampling distribution** reflects the distribution of estimates that could be achieved under repeated sampling using the same sample design

* **Example:**
  * $N=100,000$, Population mean $=2$
  * Draw 1,000 simple random samples wor
  * Estimate mean of each sample
  * Plot the distribution of these 1,000 means
  * Three different sample sizes:
    * $n=5$
    * $n=10$
    * $n=20$
* In general, larger sample size $=$ smaller sampling error / less sampling variance
* **Design-based inference** based on the shape of sampling distribution drives the inference, e.g., 95%CI, p-value

41

<!-- page 42 -->

# Design-based Inference

* A repeated sampling procedure is “desirable” if estimates across samples satisfy certain properties
* If the procedure is desirable, then the particular estimate (for the sample in hand), **computed appropriately (with respect to the design)**, is treated as “desirable” and is used for inference
* *What are these “desirable” properties?*
  – Unbiased
  – Minimum (or small) sampling variance
  – Consistency

42

<!-- page 43 -->

# “Desirable” properties: Unbiased

$Q(Y)$: Population estimand of interest

The set of possible samples are $\{s_1, s_2, \dots, s_{\mathcal{S}}\}, \mathcal{S}$ (script S) is number of samples.

Let the observation values for sample $s_i$ be denoted by $y^{(i)}$.
(Assume the samples are equally likely to be selected)

*The values of the estimator $q(y)$, over the possible sample are $q(y^{(1)}), q(y^{(2)}), \dots, q(y^{(\mathcal{S})})$ then*

$$
E(q(y)) \equiv \frac{1}{\mathcal{S}} \sum_{i=1}^{\mathcal{S}} q(y^{(i)}) = Q(Y)
$$

Defines expectation of $E(q(y))$

Generalized definition of $E(q(s))$ :

$p(s_i) = \text{Probability of choosing the sample } s_i, i = 1, 2, \dots, \mathcal{S}$

$$
E(q(s)) = \sum_{i=1}^{\mathcal{S}} p(s_i)q(y^{(i)}) = Q(Y)
$$

43

<!-- page 44 -->

# “Desirable” properties (Cont.)

* Minimum sampling variance
  * Assume unbiased estimation procedure (often not the case)
  * Choose the sampling procedure that produces the smallest sample to sample variability.
* The variance of the estimator $q(y)$:

$$
V(q(y)) = \frac{1}{\mathcal{S}} \sum_{i=1}^{\mathcal{S}} \left( q(y^{(i)}) - E[q(y)] \right)^2
$$

Each possible sample is equally likely

$$
V(q(y)) = \sum_{i=1}^{\mathcal{S}} p(s_i) \left( q(y^{(i)}) - E[q(y)] \right)^2
$$

Each possible sample $s_i$ has probability $p(s_i)$

* A “desirable” procedure (<u>combining sampling and estimation</u>) is on average close to the target population parameter $Q(Y)$ with the highest possible reliability, i.e., smallest variance.

44

<!-- page 45 -->

# Bias-Variance Trade-off

* A: (Unbiased + large variance) vs. B: (Small bias + Small variance)
* Two views
  * If unbiased is a must and will be willing to live with large variance the always go with A
  * Willing to consider B, if there is considerable benefit
* Mean Squared Error ($MSE$) :

$$Bias\ of\ q(y): E(q(y)) - Q(Y)$$

$$Variance\ of\ q(y):$$

$$V(q(y)) = \sum_{i=1}^{\mathcal{S}} p(s_i) \left( q(y^{(i)}) - E[q(y)] \right)^2$$

$$MSE = Bias^2 + Variance$$

45

<!-- page 46 -->

# What is Design Consistency?

* The heuristic idea:
  - As the sample size, $n$ , increases, the estimates $q(y)$ should get closer to the target estimand $Q(Y)$.
    (allow $N$ target finite population size to also increase)

  - Also, with fixed $N$ as the $n$ increases and gets closer to $N$, the $q(y)$ should also get closer to $Q(Y)$.

* The stated mathematically:

$$
|q(y) - Q(Y)| \to 0 \text{ as } n \to N \text{ even if } N \to \infty
$$

46

<!-- page 47 -->

# Example: Simple Random Sampling Without Replacement (SRSWOR)

- SRSWOR of size $n$ from the finite population $\{Y_1, \dots, Y_N\}$
- $Q(Y) = \bar{Y} = \frac{1}{N} \sum_{i=1}^N Y_i$, the Population mean
- Procedure: compute the sample mean, $q(y) = \bar{y} = \frac{1}{n} \sum_{i=1}^n y_i$
  - Unbiased
  - Minimum sampling variance. Compute the (sampling) variance of $q(y) = \bar{y}$?

$$V(\bar{y}) = \frac{1}{\mathcal{S}} \sum_{i=1}^{\mathcal{S}} \left( q(\bar{y}^{(i)}) - Q(Y) \right)^2 \text{, for SRSWOR; recall } \bar{y}^{(i)} \text{ is}$$

$$\text{sample mean for each sample } s_i$$

$$= (1 - f) S^2 / n \text{ , } f = n/N \text{ the finite population sampling fraction}$$

$$S^2 = \frac{1}{(N - 1)} \sum_{i=1}^N \left( Y_i - Q(Y) \right)^2 \text{, population variance of the } Y_i\text{'s}$$

47

<!-- page 48 -->

# Sampling Variance Estimation

* Note that the sampling variance for $q(y) = \bar{y} = \frac{1}{n}\sum_{i=1}^n y_i$ is not known, $V(\bar{y}) = (1 - f)S^2/n$ because $S^2$ is unknown. Need to estimate $S^2$.

* Example for SRSWOR:

  Use $s^2 = \frac{1}{n-1}\sum_{i=1}^n (y_i - \bar{y})^2$ to estimate $S^2$.

  Can show that: $E(s^2) = S^2$, i.e., $s^2$ is unbiased estimator of $S^2$.

  Good estimator of $V(\bar{y})$ is $\widehat{V}(\bar{y}) = (1 - f)s^2/n$ since $\widehat{V}(\bar{y})$ is unbiased estimator of $V(\bar{y})$, i.e., $E\left[\widehat{V}(\bar{y})\right] = V(\bar{y})$.

48

<!-- page 49 -->

# Example: Inference for a Superpopulation Mean with SRSWOR

* Let the target finite population values be $\{Y_1, Y_2, \cdots, Y_N\}$ be generated from a superpopulation model:
  - $Y_i$ are independent and identically distributed random variables with mean $\mu$ and variance $\sigma^2$.

  - The finite population mean is $\bar{Y}$ and the superpopulation mean is $\mu$.

  - Let $\{y_1, y_2, \dots, y_n\}$ be SRSWOR from the finite population with $\bar{y}$ and $s^2 = \frac{1}{n-1}\sum_{i=1}^n (y_i - \bar{y})^2$ the sample mean and sample variance estimators of $\bar{Y}$ and $S^2$, respectively.

  - Let $E_{MF}$ and $V_{MF}$ represent the expectation and variance with respect to the superpopulation model/process ($M$) and respect to to sampling ($F$) of the finite population, respectively.

49

<!-- page 50 -->

# Example: Inference for a Superpopulation Mean with SRSWOR(cont.)

* - It can be shown that $\bar{y}$ is an unbiased estimator of the superpopulation mean, $\mu$:
    $$E_{MF}(\bar{y}) = E_M[E_F(\bar{y}|Y_i's)] = E_M[\bar{Y}] = \mu.$$

    Similarly, it can be shown that $E_{MF}\left(\frac{1}{n}s^2\right) = \frac{1}{n}\sigma^2 = V_{MF}(\bar{y})$, i.e., $\frac{1}{n}s^2$ is an unbiased estimator variance of $\bar{y}$ accounting for both the superpopulation process for obtaining $\{Y_1, Y_2, \cdots, Y_N\}$ and the SRSWOR of $\{y_1, y_2, \cdots, y_n\}$.

  - The unbiased estimator for the variance of $\bar{y}$ (accounting for only the SRSWOR sampling from the finite population) is $\left(1 - \frac{n}{N}\right)\frac{1}{n}s^2 < \frac{1}{n}s^2$ the unbiased estimator variance of $\bar{y}$ incorporating both the generation of the finite population from the superpopulation and the SRSWOR.
    When we account for the generation of the finite population from the superpopulation, we obtain a larger variance for $\bar{y}$.
    Because $E_F\left[\left(1 - \frac{n}{N}\right)\frac{1}{n}s^2\right] < E_{MF}\left(\frac{1}{n}s^2\right)$ implies $V_F(\bar{y}) < V_{MF}(\bar{y})$.

50

<!-- page 51 -->

# Module 7 Summary

* **Statistical inference**: drawing conclusions about a population based upon a sample/subset of data
* Design-based vs. Model-Based Inference
  * **Design-based inference**:
    * Population values are fixed
    * Inference is based on the sample design, i.e., the probability distribution of sample selection
  * **Model-based inference:**
    * Survey variables realizations/outcomes from a <u>random process</u> defined by a statistical model
    * Inference is based on the selected <u>outcome</u> model

51

<!-- page 52 -->

# Module 7 Summary

* Design-based viewpoints
  - **Random Survey Samples**
    * Evaluate properties over the “long run” (i.e., theoretical repeated sampling and estimation operation)
    * Select estimators with good “long run” properties
  - **Superpopulation**
    * Can use a model, e.g., Normal Distribution $\text{N}(\mu, \sigma^2)$ with mean $\mu$ and variance $\sigma^2$, that generates $Y$ values in the finite population $\{Y_1, Y_2, \cdots, Y_N\}$. Can be less model dependent; see slide 49. This allows for identifying superpopulation parameters , e.g., $\mu, \sigma^2$, that may be of more interest than just the finite population $\bar{Y}, S^2$ and this allows for including extra variability in the inference about $Q(Y) = \bar{Y}$ based on the estimator, e.g., $q(y)$, from the random sample.
* Model-based viewpoints
  - **Bayesian**
    * Probability statements don’t rely upon repeated operations
    * Select a (subjective) statistical model for the data including a model for the parameters, which is based on prior beliefs about the parameters.
    * Update (subjective) prior beliefs about the parameters based on observed data.
  - **Frequentist**
    * Probability statements rely upon repeated operations
    * Select a model for generation the data where model has parameters that are not updated by the observed data
  - **Superpopulation**
    * Population parameters are drawn from a distribution of possible parameters
    * Select a model to represent the superpopulation

52

<!-- page 53 -->

# Module 7 Summary

* Sample surveys are a particular process for gathering data
* Specific approaches to doing inference are needed
* We will continue our discussion of randomization (design-based) inference next week, and then turn to model-based inference

53
