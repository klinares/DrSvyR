---
id: "jpsm/Fund_data_collection_SURV622/lectures/Lecture_11__Evaluation_Methods_for_Surveys"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lecture"
title: "SURV622/SURVMETH622: Scientific Research and Evaluation Methods"
original: "Fund_data_collection_SURV622/lectures/Lecture 11_ Evaluation Methods for Surveys.pdf"
pages: 51
sha256: "9ddc226fc9f216444ce97a5e534b727cbc7111c4de32e75213399c788181d4cc"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:03"
---

<!-- page 1 -->

# SURV622/SURVMETH622: Scientific Research and Evaluation Methods

April 14, 2025

1

<!-- page 2 -->

# Survey Methodology Research

* Focus for much of the course: What is known about the effects of different aspects of survey design on survey outcomes
    * Aspects of design include survey mode and question wording, among other things
    * Outcomes of interest include response rates and response quality
* Evidence on the effects of survey design choices comes from this research
* Focus for today: Process of designing a scientific research study to address a question of interest

2

<!-- page 3 -->

# Logic of Causal Inference

3

<!-- page 4 -->

# What is a Hypothesis?

* A hypothesis is a prediction about the relationship between an **independent variable** and a **dependent variable**
* A **dependent variable** is an outcome that you are interested in explaining
* An **independent variable** is a factor that you believe may explain the outcome of interest
    * Independent variable must be **predetermined** with respect to the dependent variable

4

<!-- page 5 -->

# Is there a causal relationship between $X_f$ and $Y$?

$$
\boxed{\mathbf{X_f}} \longrightarrow \boxed{\mathbf{Y}}
$$

| Independent Variable | Dependent Variable |
| :---: | :---: |

5

<!-- page 6 -->

Is there some other factor that explains both $\text{X}_\text{f}$ and $\text{Y}$?

$$\begin{array}{ccc}
 & & \boxed{\mathbf{Y}} \\
 & \nearrow & \updownarrow \\
\boxed{\mathbf{X_c}} & & \\
\text{Control} & \searrow & \boxed{\mathbf{X_f}} \\
\text{Variable} & & 
\end{array}$$

6

<!-- page 7 -->

# Is there some other factor that happens to be correlated with $X_f$ and explains $Y$?

$$
\begin{array}{ccc}
\boxed{\mathbf{X_f}} & & \\
\updownarrow & & \\
\boxed{\mathbf{X_c}} & \longrightarrow & \boxed{\mathbf{Y}}
\end{array}
$$

7

<!-- page 8 -->

# What is the causal process whereby $X_f$ influences $Y$?

$$\boxed{X_f} \longrightarrow \underset{\substack{\text{Mediating} \\ \text{Variable}}}{\boxed{Z}} \longrightarrow \boxed{Y}$$

8

<!-- page 9 -->

# Testing a Hypothesis: Step 1

* Step 1 is to look at whether there is an association of the expected sign between the independent variable and dependent variable
* Testing a hypothesis requires that the independent and dependent variables be operationalized and measured
  * If the hypothesis specifies different outcomes for members of different groups, the process of categorizing observations into groups also must be specified.
* An observed relationship could be due to chance
  * Tests of statistical significance help to identify which observed relationships are meaningful

9

<!-- page 10 -->

# Testing a hypothesis: Step 2

* Step 2 is to attempt to rule out other explanations for the observed association.
  * Both $X_f$ and $Y$ caused by a 3rd factor
  * Another factor that happens to be correlated with $X_f$ may cause $Y$
* In *non-experimental* data, operational measures of other factors must be developed to rule out alternative explanations
  * Confidence in conclusions directly related to adequacy with which other factors taken into account
  * Have you missed anything (observed or unobserved)?
* In *experimental* data, the experimental design may reduce or eliminate the need to control directly for other factors
  * Randomization should equalize treatment groups with respect to other variables

10

<!-- page 11 -->

# Testing a hypothesis: Step 3

* Step 3 is to attempt to understand the observed relationship by identifying the intervening variables that mediate between the independent and dependent variables
  * Controlling for mediating variables may reduce the direct association between the independent variable of interest and the dependent variable
  * Observing such an outcome may lend further credibility to the theory being tested

11

<!-- page 12 -->

# Observational vs. Experimental Studies

* **Observational** studies draw conclusions based on associations among variables in the real-world data
    * Researchers attempt to control for observable factors other than the independent variables of interest that might explain an association
    * There may be relevant factors that are not observable and cannot be controlled
* Essence of an **experiment**: Random assignment of subjects to treatments
    * Under random assignment, those assigned to different treatment arms should have the same expected value with respect to both observed and unobserved characteristics
    * Experimental designs help researchers to rule out other explanations for an association between the independent and dependent variable(s)

12

<!-- page 13 -->

# Is my study “valid”?

* **Internal validity**: Do any differences observed (across treatment groups) represent the causal impact of the independent variable of interest?
  * Because the characteristics of those in different treatment groups have same expected value, experiments have a major advantage
* **External validity**: Can the results of the study be generalized to the broader population?
  * Experiments may occur under different conditions and/or draw on different populations that real-word surveys, raising questions about external validity
* **Construct validity**: Do the variables adequately capture the theoretical constructs of interest?
  * Both observational and experimental studies must address
* **Statistical validity**: Are the differences across treatment groups greater than would be expected by chance?

13

<!-- page 14 -->

# Observational Studies

14

<!-- page 15 -->

# Central challenge of observational research:
# Holding all else constant

* Consider the following hypothetical study design:
    * Collect data for a larger number of surveys on response rates and whether respondents offered an incentive to participate
    * Estimate relationship between response rates and whether an incentive was offered
* Suppose that you find no relationship
    * Is it reasonable to conclude that incentives do not affect response rates? If not, why not?
    * How could this observational study be improved?

15

<!-- page 16 -->

# Example: McBride and Dixon (2016)

* Study examines effect of bounding interview on resorts of expenditures in the quarterly Consumer Expenditure Survey
  * Through 2014, survey included a bounding interview, followed by 4 production interviews
  * Staggered introduction beginning in 2015 of new design with no bounding interview
  * April 2015 interviews included both subjects who had an had not previously participated in a bounding interview
  * Study compares reported expenditures for the two groups
* Subjects not randomized to treatments and observable characteristics of the two groups were different
  * Subjects who received a bounding interview had higher incomes and were less likely to live in rural areas
* Initial comparison of reported expenditures showed large differences in reported expenditures on furniture and major appliances (consistent with forward telescoping), but only furniture result holds up with controls for observable characteristics
* Questions you might ask authors about findings?

16

<!-- page 17 -->

# Example: Conrad et al (2013)

* Authors coded recordings of 1,380 telephone survey invitations issued by interviewers in five surveys conducted by the University of Michigan Survey Research Center
  * Coding captured disfluencies, interruptions, and other aspects of the verbal interaction
  * Outcomes include agree, refuse, scheduled callback
* Relationship between disfluency and agreement in U-shaped, with lowest agreement rates for low and high interviewer disfluency
* Questions you might as authors about findings?

17

<!-- page 18 -->

# Experimental Studies

18

<!-- page 19 -->

# Post-test Only Design

* Simplest possible experimental design compare outcomes for treatments to outcomes for controls
* Can be represented schematically
  * Pick a sample with $2n$ cases
  * Randomly assign $n$ cases to treatment and $n$ cases to control (R represents random assignment)
  * Compare outcomes O1 and O2
* Can use similar approach to compare two treatments to two treatments plus a control group

19

<!-- page 20 -->

# Pre-test, Post-test Design

* Common in social science research to obtain a pre-test measure; less common in survey research
* Like post-test only design, can be adapted to compare two treatments or two treatments plus control
* Advantages of collecting a pre-test measure:
  * Better able to account for (random) differences between treatment and control groups. For example: dependent variable can be defined as difference between the final and initial observation (O2-O1 or O4-O3)
  * Provides a basis for assessing effects of different attrition among treatments versus control
* Disadvantage of collecting a pre-test measure: may be a source of conditioning effects

20

<!-- page 21 -->

# Example: Kreuter, Presser, and Tourangeau (2008)

* Research sought to assess the effect of survey mode on reporting of socially undesirable behaviors
  * Sample of University of Maryland alumni for whom phone numbers available in alumni database
    * Selected 20,000 graduates; phone numbers listed for 7,591 (not all valid); 1,501 subjects completed short screener interview
  * After completing screener, randomly assigned to one of three treatments: telephone (94.7% completes), web (56.8% completes), or IVR (61.1% completes)
  * Higher reports of ever having received a D or F or of GPA below 2.5 in web than in telephone interview
    * Web reports more accurate than telephone reports
* Questions you might ask authors about findings?

21

<!-- page 22 -->

# Example: Link, Schober, Conrad, and Reichert (2013)

* Research sought to assess effects of four types of interviewing agents of disclosure and satisfaction
  * Lab experiment with 235 subjects from the New York City area recruited via ads on Craigslist or in the Village Voice; man age of 31 years
  * Four treatments: human interviewer; virtual interviewer with low-fidelity animation; virtual interviewer with high fidelity animation; ACASI (voice-only) interview
    * Same interviewer who conducted face-to-face interviews provided facial movements and voice for virtual interviews and ACASI interview
  * Main finding that modes with a face, whether digital or biological, tended to produce more socially desirable responses than ACASI
    * Behaviors for which this was the case included number of sex partners since age 18 (-), have credit cards (+), read newspaper every day (+), give food or money to a homeless person at least once a week (+)
* Questions you might as authors about findings?

22

<!-- page 23 -->

# Factorial Designs

* In a simple two-way factorial design, subjects receive one version of treatment A and one version of treatment B
* Advantages of a factorial design include:
    * Less expensive to test for main effects of treatments than if two separate experiments conducted
    * Allows for testing of combinations of treatments and interactions between the treatments

23

<!-- page 24 -->

# Factorial Designs

| | CAPI | ACASI |
| :--- | :--- | :--- |
| Forgiving wording | S1<br>S2<br>S3<br>S4 | S5<br>S6<br>S7<br>S8 |
| Standard wording | S9<br>S10<br>S11<br>S12 | S13<br>S14<br>S15<br>S16 |

24

<!-- page 25 -->

# Factorial Design: Try it!

* Imagine an experiment with \$0, \$2, and \$5 and then whether or not the incentive is shown.
  * How would you design this as a factorial design?
  * We have 10,000 cases in the sample. How would you allocate these to your design?

25

<!-- page 26 -->

# Example: Abraham, Filiz-Ozbay, and Turner (2017)

* Survey experiment designed to examine factors affecting stated preferences regarding student loan repayment plan
  * Invitation to participate in a web survey about student loan debt sent to University of Maryland undergraduates
  * Students presented with scenarios in which they had a certain amount of student loan debt, then asked to state preferences between repaying debt under standard mortgage-type plan or under an income-driven repayment plan (IDR)
  * Randomized framing of options (neutral, emphasizing insurance aspect of IDR, or emphasing potential for higher cumulative payments under IDR), loan amount (\$30,000 or \$60,000), and whether more or less generous IDR plan offered first
  * Find strong effect of framing on share who state a preference for IDR (insurance framing > neutral framing > cost framing); IDR preferred more often in scenarios with larger loan amounts
    * Former finding suggests that current framing of real-world IDR plans, which emphasizes costs of IDR, may discourage participation
* Questions you might ask authors about findings?

26

<!-- page 27 -->

# Example: McGonagle, Couper, and Schoeni (2011)

* Experiment tested alternative approaches to contact with PSID respondents between waves
  * Fully factorial design tested traditional versus color return postcard, \$10 incentive prepaid versus postpaid, three mailing schedules (July only, October only, July and October), and whether study newsletter included
    * Total of 24 treatments
  * Outcomes of interest are whether respondent returned postcard, whether respondent provided a new telephone number and number of calls required to reach final disposition in the subsequent survey wave
  * Findings suggest use of traditional postcard, prepaid incentive, and mailing schedule that includes a July mailing all have modest positive effect on at least some outcomes
* Questions you might ask authors about findings?

27

<!-- page 28 -->

# Full vs Fractional Factorial Design

* Full=all possible combinations
* Even a few treatments can lead to a large number of conditions
* $2^5=32$ cells
* The **advantage** of this design is that all interactions are included
* The **disadvantage** is that it is complex and possibly expensive
* A fractional factorial design looks at a subset of the 32 cells
  * Designed to infer main effects
  * Possibly some but not all interactions

28

<!-- page 29 -->

# Fractional Factorial Design

* Assume 5 treatments
* “Quarter design”: $2^5=32$, $\frac{1}{4}=2^{-2}$; $2^5 \times \frac{1}{4} = 2^{5-2}=2^3=8$

| | Treatment | | | | |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Group** | **A** | **B** | **C** | **D** | **E** |
| 1 | - | - | - | + | - |
| 2 | + | - | - | + | + |
| 3 | - | + | - | - | + |
| 4 | + | + | - | - | - |
| 5 | - | - | + | - | + |
| 6 | + | - | + | - | - |
| 7 | - | + | + | + | - |
| 8 | + | + | + | + | + |

| Outcomes | | | | | |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **Hazy?** | **Adheres?** | **Grease on top of film?** | **Grease under film?** | **Dull adjusted ph** | **Dull original ph** |
| No | No | Yes | No | Slightly | Yes |
| No | Yes | Yes | Yes | Slightly | Yes |
| No | No | No | Yes | No | No |
| No | Yes | No | No | No | No |
| Yes | No | No | Yes | No | Sligh |
| Yes | Yes | No | No | No | No |
| Yes | No | Yes | No | Slightly | Yes |
| Yes | Yes | Yes | Yes | Slightly | Yes |

29

<!-- page 30 -->

# Within-Subject Design

* Administering all treatments in sequence to the same set of subjects controls more fully for differences in characteristics
* Conditioning effects a potential concern
  * Cannot be sure to what extent response to Treatment B has been affected by previous receipt of Treatment A
  * Break in time can be added between treatments

$$X_1 \text{ Treatment A } \quad O_1 \quad X_1 \text{ Treatment B } \quad O_2$$

30

<!-- page 31 -->

# Crossover Design

* Within-subject design that randomizes order in which subjects receive treatments
* If conditioning effects are important, might expect O2-O1 to differ from O3-O4
  * Reassuring if these two differences are statistically indistinguishable

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| R | $X_1$ (Treatment A) | $O_1$ | $X_1$ (Treatment B) | $O_2$ |
| R | $X_2$ (Treatment B) | $O_3$ | $X_2$ (Treatment A) | $O_4$ |

31

<!-- page 32 -->

# Example: Antoun, Couper, and Conrad (2017)

* Experiment sought to learn about quality of responses to a web survey on a smartphone versus a personal computer (PC)
  * Respondents in a probability web panel (n=1,390) invited to answer a 46-question survey in one mode and then, one month later, in the other mode
  * Outcome measures included indicators of response effect (e.g., lack of differentiation in responses regarding political attitudes, very short answers to open-ended questions), indicators of socially desirable reporting, and errors in input of age and birth year (know to researchers)
  * Among those in web panel who agreed to participate (~40% of total panel members), response rates ~70-75% if received smartphone invitation and ~80-85% if received a PC invitation
    * Included answers from those responding to only 1 of 2 surveys, but results little affected if sample restricted to both surveys
  * Find no evidence of differences in satisficing behavior across modes, no differences in disclosure across modes, and a somewhat higher incidence of input errors on smartphones
* Questions you might ask authors?

32

<!-- page 33 -->

# When are experiments not feasible/desirable?

* Limited time or resources for research
* Need for a precise answer is low
* Subjects are unwilling to follow protocols
* Variables cannot be manipulated (fixed characteristics, events that occurred in the past) or would cause harm if manipulated
* Hypothesis is weak. For example:
  * Proposed improvement is already of clear value
  * Other research could provide the necessary data to clarify the question
  * Results will not inform practice
* Goal is to *explain* impact of treatment (rather than *measure* it)

33

<!-- page 34 -->

# Small Group Discussion

Consider the previous example of varying incentives (\$0, \$2, and \$5) and whether the incentive is show. As you do so, consider the following questions:

* What if your independent variable of interest?
* What is your dependent variable?
* What is your prediction about the relationship between the independent variable of interest and dependent variable?
* Is it an experimental study or observational study?
* What can you say about the validity of your study? Focus on interval validity, external validity, and construct validity.

34

<!-- page 35 -->

# Power Calculations

35

<!-- page 36 -->

# Testing Hypotheses About Differences in Means Across Two Samples

* Suppose you are testing the difference in the means of a continuous variable Y across two independent samples:

$$H_0: \mu_1 = \mu_2$$

$$H_A: \mu_1 \neq \mu_2$$

  * Analysis similar if testing for a difference in proportions
* Two things can go wrong:
  * Type I error: Reject null hypothesis when it is true
  * Type II error: Fail to reject the null hypothesis when there is an effect to be found

36

<!-- page 37 -->

# Testing Hypotheses About Differences in Means Across Two Samples

* To illustrate, assume:
  * Size of two samples the same ($n_1=n_2=n$)
  * Variance of $Y$ in the two populations the same ($S_1^2=S_2^2=S^2$)
* Stated assumptions imply that sample variance of estimate of $Y$ in each of the two populations is (approximately) $S^2/n$ and that, under the null hypothesis, the sample variance of the difference between the estimated means is (approximately) $2*S^2/n$
* Test statistic for statistical significance of difference between the two estimated mean is a Student’s $T$:

$$T = \frac{\bar{Y}_1 - \bar{Y}_2}{\sqrt{2s^2 / n}}$$

37

<!-- page 38 -->

# Testing Hypotheses About Differences in Means Across Two Samples

* For large $n$, distribution of $T$ is close to normal with mean 0 and standard deviation 1
  * $\alpha$ is desired significance levels (probability of Type I error); usually 0.05
  * This means that the rejection region comprises 5% of the $t$ distribution; can be allocated on one side (one-sided test) or two sides (two-sided test)
  
  -1.96 1.96

  * For one-tailed test, compare test statistic value to $t_{(\alpha, 2n-2)}$
  * For two-tailed test, compare test statistic value to $t_{(\alpha/2, 2n-2)}$
  * If correct about direction of difference, more likely to reject null hypothesis with a one-tailed test. Put another way, power of a one-sided test always higher than the power of a two-sided test, other things being equal.

38

<!-- page 39 -->

# Testing Hypotheses About Differences in Means Across Two Samples

* The *power* of a test is $1 - \text{Pr}(\text{Type II error})$
  * That is, the power is the probability that you will detect a significant effect (i.e., reject the null hypothesis) if there is an effect to be found
* Power depends on:
  * True difference in means across samples (+)
  * Desired significance level for rejecting null hypothesis (+ for higher p-value)
  * Population variance in variable of interest (-)
  * Sample size (+)

39

<!-- page 40 -->

# Testing Hypotheses About Differences in Means Across Two Samples

**A**
* $.95$
* $.025$, $.025$
* $\mu_{\text{diff}} = 0$
* $\alpha = .05$
* Axis: $-20, -10, 0, 10, 20, 30, 40$

**B**
* $.83$, $.17$
* $\mu_{\text{diff}} = 10$
* $\beta = .83$
* Axis: $-20, -10, 0, 10, 20, 30, 40$

**C**
* $.48$, $.52$
* $\mu_{\text{diff}} = 20$
* $\beta = .48$
* Axis: $-20, -10, 0, 10, 20, 30, 40, 50$

**D**
* $.15$, $.85$
* $\mu_{\text{diff}} = 30$
* $\beta = .15$
* Axis: $-20, -10, 0, 10, 20, 30, 40, 50, 60$
* $M$

---

* $p > .05$
* $.05 \ge p > .01$
* $p < .01$

* $\mu_{\text{diff}} = 10$
  * Axis: $-20, -10, 0, 10, 20, 30, 40, 50, 60$

* $\mu_{\text{diff}} = 20$
  * Axis: $-20, -10, 0, 10, 20, 30, 40, 50, 60$

* $\mu_{\text{diff}} = 30$
  * Axis: $-20, -10, 0, 10, 20, 30, 40, 50, 60$

40

<!-- page 41 -->

# Power Calculations

* Many online power calculators
  * One example of a simple power calculator for differences in means
    https://www.stat.ubc.ca/~rollin/stats/ssize/n2.html
  * One example of a simple power calculator for differences in proportions
    https://www.stat.ubc.ca/~rollin/stats/ssize/b2.html
* Can use calculators to determine required sample size or to determine power for a given sample size
* In R, multiple packages available (e.g. `pwr` package)

41

<!-- page 42 -->

# Example: Reporting of Hours Last Week Among Those Engaging in “Gig Work”

* $\text{H}_0$: Asking a single question about hours spent on gig employment last week yields the same answer as asking a more detailed sequence of questions
* $\text{H}_A$: More detailed question sequence yields higher reported hours in gig employment
* Additional information needed for calculations
  * Assume time spent on gig work last week has a mean of ~20 hours and a standard deviation of ~15 hours
    * Based on back-of-envelope calculations using information on Uber drivers (Hall and Krueger 2015)
  * Assume that 20% of adults have gig employment

42

<!-- page 43 -->

# Example: Reporting of Hours Last Week Among Those Engaging in “Gig Work”

| True Expected Difference in Mean Reported Hours Across Treatments | Power for Two-Sided Test: $n=500$ ($n_{\text{gig}}=100$) | Power for Two-Sided Test: $n=1000$ ($n_{\text{gig}}=200$) |
| :--- | :---: | :---: |
| 1 | 0.07 | 0.10 |
| 2 | 0.15 | 0.27 |
| 3 | 0.29 | 0.52 |
| 4 | 0.47 | 0.76 |
| 5 | 0.65 | 0.92 |

*Note: n is sample size for each treatment arm; number of cases in each arm with gig employment assumed to be 0.2\*n.*

43

<!-- page 44 -->

# Minimum Detectable Effect Sizes

* A power analysis is typically used to estimate the smallest sample size needed for an experiment (given a specified significance level, statistical power, and effect size)
* But sometimes the sample size if fixed. In this case, you can think of a power analysis in terms of the minimum effect size that the sample allows you to detect (given a specified significance level, statistical power, and sample size)
* Run these calculations before looking at the data
  * Post hoc power not valid
  * Important to scale power for important and achievable results

44

<!-- page 45 -->

# Activity

Try to replicate the power calculation from slide 43

https://www.stat.ubc.ca/~rollin/stats/ssize/n2.html

45

<!-- page 46 -->

# Testing Hypotheses About Differences in Proportions Across Two Samples

* Now suppose that you are interested in testing the difference in the proportion with a given characteristic in two independent samples:

$$H_0: \pi_1 = \pi_2$$

$$H_1: \pi_1 \neq \pi_2$$

* To illustrate, again assume $n1=n2=n$
* Under this assumption, variance of the estimated individual proportions is $\pi_i(1-\pi_i)/n$ and, under the null hypothesis, the approximate variance of the difference between the two estimated proportions is $2\pi(1-\pi)/n$

46

<!-- page 47 -->

# Testing Hypotheses About Differences in Proportions Across Two Samples

* For "sufficiently large" $n$, the difference between the two estimated proportions has a distribution that is approximately normal, implying the test statistic

$$z = \frac{p_1 - p_2}{\sqrt{p_1(1 - p_1) / n + p_2(1 - p_2) / n}}$$

  * For a two-tailed test, compare value of the test statistic to $z_{\alpha/2}$
  * For a one-tailed test, compare value of the test statistic to $z_\alpha$

47

<!-- page 48 -->

# Example: Share of Respondents Reporting use of Illegal Drugs in the Past Year

* $H_0$: Respondents are equally likely to report having used illegal drugs in the past year whether questioned by an interviewer or asked to fill out a self-administered questionnaire
* $H_A$: The probability that a respondent reports having used illegal drugs in the past year is different across the two modes of administration
* Assume that ~10% of the population has used illegal drugs in the past year; $\alpha=0.05$
* Power calculations provided by https://www.stat.ubc.ca/~rollin/stats/ssize/b2.html

48

<!-- page 49 -->

# Example: Share of Respondents Reporting use of Illegal Drugs in the Past Year

| True Expected Difference in Reported Proportions | Power for Two-Sided Test ($n=500$) | Power for Two-Sided Test ($n=1000$) |
| :--- | :---: | :---: |
| 0.01 | 0.07 | 0.11 |
| 0.02 | 0.17 | 0.30 |
| 0.03 | 0.32 | 0.56 |
| 0.04 | 0.49 | 0.79 |
| 0.05 | 0.67 | 0.92 |

*Note: $n$ is sample size for each treatment arm.*

49

<!-- page 50 -->

# References

* Abraham, Filiz-Ozbay, Ozbay and Turner. 2017. “Framing Effects, Earnings Expectations, and the Design of Student Loan Repayment Schemes,” unpublished working paper.

* Antoun, Couper and Conrad. 2017. “Effects of Mobile versus PC Web on Survey Response Quality: A Crossover Experiment in a Probability Web Panel,” *Public Opinion Quarterly* 81(S1), 280-306.

* Conrad et al. 2013. “Interviewer Speech and the Success of Survey Invitations,” *J. R. Statist. Soc.* A 176 (1),191–210.

* Kreuter, Presser and Tourangeau. 2008. “Social Desirability Bias in CATI, IVR and Web Surveys: The Effects of Mode and Question Sensitivity,” *Public Opinion Quarterly*, 72(5) 847-865.

50

<!-- page 51 -->

# References (continued)

* Lind, Schober, Conrad and Reichert. 2013. “Why Do Survey Respondents Disclose More when Computers Ask the Questions,” *Public Opinion Quarterly*, 77(4) 888–935.

* McBride and Dixon. 2017. “Estimating the Impact of Eliminating a Bounding Interview,” presented at annual meeting of the American Association for Public Opinion Research.

* McGonagle, Couper and Schoeni. 2011. “Keeping Track of Panel Members: An Experimental Test of a Between-Wave Contact Strategy,” *Journal of Official Statistics*, 27(2): 319–338.

51
