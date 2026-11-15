---
id: "jpsm/Fund_Infe_SURV740/midterm/handnotes_for_PS_methods_v1"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "handnotes for PS methods v1"
original: "Fund_Infe_SURV740/midterm/handnotes for PS methods v1.pdf"
pages: 5
sha256: "b922358eea1c70d20df92f2bec119430193d759bd8a8ed50dbe69b486cc5a94b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:04"
---

<!-- page 1 -->

1. Outcome

$Y|A=a$: actual outcome we observe after the trtment $a$ has been applied.

$Y^{A=a}$: Potential Outcome if the trtment level $a$ had been applied.

2 Assumptions.

① Consistency

$$Y|A=a = Y^a.$$

$$\underline{\text{obs } Y} = \underline{\text{realized P.O.}} \text{ if trted by observed trtment } a$$

② Exchangeability

$$E(Y^a|A=a) = E(Y^a|A=a') = E(Y^a)$$

$$\iff Y^a \perp A \text{ for } \forall a$$

③ Positivity

$$0 < P(A=a) < 1$$

Positive Prob. to be assigned to each of trtment grps $\forall a$.

<!-- page 2 -->

2. R.E. (2)

$$
\begin{cases}
\text{Completely}: & Y^a \perp A \ \& \ 0 < P(A = a) < 1 \\
\text{Conditional}: & \boxed{Y^a \perp A \mid L} \ \& \ 0 < P(A = a) < 1
\end{cases}
$$

$$\rightarrow \tau = E(Y^1 - Y^0) \stackrel{\boxed{2, 1}}{=} \underbrace{E(Y \mid A = 1) - E(Y \mid A = 0)}$$

$\tau = E(Y^1 - Y^0)$, where

$$
\begin{aligned}
E(Y^1) &= E_L E(Y^1 \mid L) = E\left[ E(Y^1 \mid L, A = 1) \right] \\
&= \underline{E\left[ E(Y \mid L, A = 1) \right]}
\end{aligned}
$$

$\downarrow$ $\uparrow$ identifiable!

$$E(Y^0) = E\left[ E(Y \mid L, A = 0) \right]$$

$$
\text{Estimation}
\begin{cases}
\text{Standardization} \\
\text{IPW.}
\end{cases}
$$

<!-- page 3 -->

(3)

## 3. Observational Studies (No Randomization)

Conditional Exchangeability can only be assumed (No Guarantee)

$$Y^a \perp A \mid \underset{\substack{\uparrow \\ \text{all confounders}}}{\underline{X}}$$

Question: How to adjust for all $\underline{X}$?

* **Matching**
  * $d(i, j)$
    * Exact
    * Euclidean
    * Mahalanobis
    * P.S.
      * $|e(x_i) - e(x_j)|$
      * $|\text{logit } e(x_i) - \text{logit } e(x_j)|$
  * Matching method
    * greedy
    * **optimal**
  * **SMD**
  * **R-implementation**

<!-- page 4 -->

# 2 Propensity Score method 4

$$\left. \begin{array}{l} \text{-- Matching} \\ \text{-- Stratification} \end{array} \right\} \Rightarrow \underline{\text{Robin (2007)}}$$

- weighting

Step 1: Matching on $|\text{logit}\hat{e}(x_i) - \text{logit}\hat{e}(x_j)|$

Step 2: Reestimate $\underline{\hat{e}_i}$ for each of ~6000 matched sample

Step 3: $\underline{\text{Form Strata (k)}}$

$$k = \left\{ \begin{array}{c} 1 \\ 2 \\ \vdots \\ 10. \end{array} \right.$$

$$\underline{\underline{\text{smd}_k}} = \frac{|\bar{x}_{k,s} - \bar{x}_{k,Ns}|}{\sqrt{\frac{S_{k,s}^2 + S_{k,Nk}^2}{2}}}$$

$$\underline{\text{smd}} = \frac{n_1\text{smd}_1 + n_2\text{smd}_2}{n_1 + n_2}$$

$k = 10$

Step 4:

$$\hat{\tau} = \sum_{b=1}^{10} (\bar{y}_{b,s} - \bar{y}_{b,Ns}) \frac{N_b}{N}$$

<!-- page 5 -->

5

$$
\begin{aligned}
w_i &= \frac{1}{P(A_i=0 \mid X_i)} \\
&= \frac{1}{1 - e(X_i)}
\end{aligned}
$$

$$
\begin{aligned}
& E(w_i(1-A_i)Y_i) \\
=& E\left( \frac{1-A_i}{1-e(X_i)} Y_i \right) \\
=& E_X E\left[ \frac{1-A_i}{1-e(X_i)} Y_i \;\middle|\; X \right] \quad \text{by L.I.E.} \\
=& E_X \left[ \frac{E[(1-A_i)Y_i \mid X]}{1-e(X_i)} \right] \\
=& E_X \left[ \frac{1}{1-e(X_i)} E(1-A_i \mid X_i) E(Y_i \mid X_i, 1-A_i=1) \right] \\
=& E_X \left[ \frac{1}{1-e(X_i)} (1-e(X_i)) E(Y_i \mid X_i, A_i=0) \right] \\
=& E_X \left[ E(Y_i \mid X_i, A_i=0) \right] \\
=& E_X E(Y_i^0 \mid X_i) \quad \text{cond. exchangeability.} \\
=& E(Y_i^0) \quad \text{by L.I.E.}
\end{aligned}
$$
