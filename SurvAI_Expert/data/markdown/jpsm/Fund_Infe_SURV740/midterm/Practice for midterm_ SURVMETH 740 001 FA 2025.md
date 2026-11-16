---
id: "jpsm/Fund_Infe_SURV740/midterm/Practice_for_midterm__SURVMETH_740_001_FA_2025"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Practice for midterm"
original: "Fund_Infe_SURV740/midterm/Practice for midterm_ SURVMETH 740 001 FA 2025.pdf"
pages: 5
sha256: "eadc625207e5e94f24606f4e0f28ea0417db6670454ecc25800ba0e71d79657b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:09"
---

<!-- page 1 -->

# Practice for midterm

* Due Dec 5 at 1pm
* Points 10
* Questions 10
* Available after Oct 3 at 2:30pm
* Time Limit None
* Allowed Attempts Unlimited

# Instructions

1. **Practice Exercise**
   This practice exercise is designed to help you prepare for the mid exam. It includes:
   * True/False questions
   * Multiple Choice questions
   * A set of open-ended questions

   ---

   **Midterm Details**
   * **Date/Time:** 10/10, 1:00–3:30 PM
   * **Format:**
     * 10 True/False questions
     * 10 Multiple Choice questions
     * 2 sets of open-ended questions (each with sub-questions)

   ---

   **Important Notes**
   * Closed book and closed notes
   * One page of formula sheet allowed
   * Simple calculator permitted (no matrix or integration functions)
   * For computation questions, show detailed steps to receive partial credit

Best regards,
Dr. Li

**<u>Take the Quiz Again</u>**

## Attempt History

<!-- page 2 -->

| | Attempt | Time | Score |
| :--- | :--- | :--- | :--- |
| **LATEST** | [Attempt 1](#) | 27 minutes | 9 out of 10 \* |

\* Some questions not yet graded

\* Some questions not yet graded
Submitted Oct 3 at 10:01pm
Correct answer

Question 1
1 / 1 pts
In observational studies, randomization ensures the conditional exchangeability assumption holds.

- [ ] True
- [x] False

Correct answer

Question 2
1 / 1 pts

The backdoor criterion ensures that variables used for adjustment blocks all backdoor paths.

- [x] True
- [ ] False

Correct answer

Question 3
1 / 1 pts

Causal inference methods, such as propensity score matching, can eliminate all bias due to confounding in observational studies.

- [ ] True
- [x] False

Correct answer

Question 4
1 / 1 pts
If the exchangeability assumption holds, the observed outcome for a treated subject is equal to their potential outcome under that treatment.

- [ ] True
- [x] False

Correct answer

Question 5

<!-- page 3 -->

1 / 1 pts

The propensity score is:

- [x] The probability of being treated given covariates
- [ ] The risk of the outcome among controls
- [ ] The risk of the outcome among the treated

Correct answer

Question 6

1 / 1 pts

Trimming the tails of the propensity scores involves:

- [x] excluding subjects who have extreme values of the propensity score
- [ ] using a logit transformation of the propensity score before matching
- [ ] not including highly skewed variables in the propensity score model

Correct answer

Question 7

1 / 1 pts

Which of the following is true about a Directed Acyclic Graph (DAG)?

- [ ] It contains cycles if there is feedback in the system.
- [x] It represents causal relationships between variables using directed edges.
- [ ] It requires every variable to have an outgoing edge.
- [ ] It assumes all variables have been measured.

Correct answer

Question 8

1 / 1 pts

Someone who was likely to be treated, given their covariates, but wasn't:

- [ ] will have a small propensity weight
- [x] will have a large propensity weight
- [ ] not sure

Consider an observational study with 8 observations, of which four were treated. We use to denote the treatment (1 for treatment and 0 for control) and the observed outcome for unit $i$. We use X to denote an observed covariate.

Correct answer

Question 9

1 / 1 pts

The observed data is presented in the Table below. By using one-to-one, nearest-neighbor matching (<u>WITHOUT</u> replacement) on the covariate X, choose the matched counterfactuals $Y^0$ for observations 1-4 (in order).

<!-- page 4 -->

| $i$ | A | Y | $Y^1$ | $Y^0$ | X | $\tau$ |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 1 | 4 | 4 | | 1 | |
| 2 | 1 | 10 | 10 | | 7 | |
| 3 | 1 | 8 | 8 | | 6 | |
| 4 | 1 | 6 | 6 | | 12 | |
| 5 | 0 | 3 | | 3 | 9 | |
| 6 | 0 | 5 | | 5 | 6 | |
| 7 | 0 | 8 | | 8 | 10 | |
| 8 | 0 | 2 | | 2 | 11 | |
| 9 | 0 | 9 | | 9 | 100 | |

- [ ] 5, 2, 8, 3
- [ ] 3, 5, 8, 2
- [ ] 2, 3, 5, 8
- [x] 5, 3, 8, 2

Question 10
Not yet graded / 1 pts

Using the data above,

1. Estimate the **Average Treatment Effect on the Treated (ATT)** and state the assumptions required.

2. Based on these assumptions, is your estimate of ATT also an estimate of the **Average Causal Effect (ACE)**? Provide justification.

Your Answer:

We start with 4 individuals with A=1.

For Y_1 unit, Y_1 - Y_0 = 4 - 5 = -1

For Y_2 unit , Y_1 - Y_0 = 10 - 3 = 7

<!-- page 5 -->

For $Y\_3$ unit, $Y\_1 - Y\_0 = 8 - 8 = 0$

For $Y\_4$ unit , $Y\_1 - Y\_0 = 6 - 2 = 4$

$\text{ATT} = (-1 + 7 + 0 + 4) / 4 = 2.5$

There are there assumptions. The conditional exchangability assumption states that the assignment of treatment is independent from the potential outcome, and this is why both groups are comparable. The second assumption, positivity, there is a non-zero probability of being in the treatment or control group. The third assumption, consistency, the observed outcome is also the potential outcome based on treatment received.

Our ATT is not an estimate of ACE. This is because the ATT is only for the group that received the treatment, $A=1$, while ACE is for the overall population. This matching procedure tells us what could have happened to the treated group if they had not been treated, hence potential outcome, but this is theoretical, and it does not tell us about what would happen if the control group had been treated.

**1. Estimate ATT and assumptions required**

* **ATT definition:** $\text{ATT} = \mathbb{E}[Y^1 - Y^0 \mid T = 1]$.
* **Assumptions required:**
  * **Consistency/SUTVA:** observed outcome equals the correct potential outcome.
  * **Exchangeability of treatment effect and treatment assignment:** $(Y^1 - Y^0) \perp T$ (ensures treated group represents population treatment effect distribution).

**2. Is ATT also ACE under these assumptions?**

* **ACE:** $\mathbb{E}[Y^1 - Y^0]$.
* Under exchangeability, $\mathbb{E}[Y^1 - Y^0 \mid T = 1] = \mathbb{E}[Y^1 - Y^0]$.
* **Justification:** This means the average effect among treated equals the average effect in the population, so $\text{ATT} = \text{ACE}$.
