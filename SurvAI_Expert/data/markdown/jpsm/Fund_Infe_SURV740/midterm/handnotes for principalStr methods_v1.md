---
id: "jpsm/Fund_Infe_SURV740/midterm/handnotes_for_principalStr_methods_v1"
source: "jpsm"
course: "SURV740"
course_title: "Fundamentals of Inference"
doc_type: "assignment"
title: "Truncation Due to Death"
original: "Fund_Infe_SURV740/midterm/handnotes for principalStr methods_v1.pdf"
pages: 6
sha256: "2e97b71ecb5e61c75e1f61515c0f3b8ee96574e9ce9311c066a0ec97be9b19f1"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:04"
---

<!-- page 1 -->

# Truncation Due to Death

1/6

$$Z \longrightarrow A \longrightarrow Y$$

$$Q: \quad E(Y^1 - Y^0) \neq E(Y \mid \underline{Z=1, A=L}) - E(Y \mid \underline{Z=0, A=L})$$

## Table 1. (Hypothetical Pop'n)

$$\text{trtment} \begin{cases} \uparrow \text{ survival Rate} \\ \uparrow \text{ QOL in LL} \end{cases}$$

## Table 2 C.R.E. (sample)

$$50\% \text{ assigned } \begin{cases} Z=1 \\ Z=0 \end{cases}$$

$$\underline{\text{Report}} \quad (Z, A = A^{Z_i}, Y = Y^{Z_i})$$

## Table 3 & 4 Compute

$$E(A \mid Z)$$

$$E(Y \mid Z, A=L)$$

$$\Rightarrow \text{trtment} \begin{cases} \uparrow \text{ survival Rate} \\ \downarrow \text{ QOL} \quad \longleftarrow \begin{array}{l} \text{Misleading} \\ \text{False Finding} \end{array} \end{cases}$$

Q: What is WRONG?

Not comparing common units.

<!-- page 2 -->

$Z=0 \quad Z=1$ 2/6

$(Z=T, A=L)$ from $LL$ and $DL$ stratum

$(Z=C, A=L)$ from $LL$ and $LD$ stratum

# Principal Stratification Method

AT

$$\underset{\text{trt assigned}}{Z} \longrightarrow \underset{\text{trt received}}{A} \longrightarrow \underset{\text{Outcome}}{Y}$$

## What are the 4 Principal Strata?

$$\underset{\substack{\uparrow \\ \underline{\text{Latent}}}}{\underline{\text{4. Strata}}} \begin{cases} \underline{AT}: & A^0 A^1 = (1, 1): \underset{(A=1)}{\text{active}} \perp \underset{(Z=0, Z=1)}{\underline{\text{assigned}}}. \\ \underline{NT}: & A^0 A^1 = (0, 0) \quad \text{control} \perp \text{assigned} \\ \underline{C}: & A^0 A^1 = (0, 1) \quad \text{receive assigned trtment} \\ \underline{D}: & A^0 A^1 = (1, 0) \quad \begin{array}{l} \text{receive opposite of assigned} \\ \text{trtment.} \end{array} \end{cases}$$

\underline{within Principal Stratum},
compare trted vs. controls.

$$\underline{E(Y^1 - Y^0 \mid S)} = E(Y \mid Z=1, S) - E(Y \mid Z=0, S)$$

<!-- page 3 -->

3/6

$$
\theta_{11} = \underbrace{(Z=1, A=1)}_{\downarrow} \in (YY \text{ and } NY)
$$

$$
= \theta_{11} = \underset{\uparrow}{\boxed{\theta_1}} \theta_{YY}^1 + \underset{\uparrow}{\boxed{\theta_2}} \theta_{NY}^1
$$

$$
\frac{0.51}{0.14+0.51} \quad \frac{0.14}{0.14+0.51}
$$

$$
(*) \quad 0.89 = \frac{0.51}{0.14+0.51} \theta_{YY}^1 + \frac{0.14}{0.14+0.51} \theta_{NY}^1
$$

Question: what range of $\underset{\downarrow}{\theta_{NY}^1}$ ? $(0, 1)$

Solve $(*)$ for $\theta_{YY}^1$ when

$$
\theta_{NY}^1 = \begin{cases} 0 & \Rightarrow \theta_{YY}^1 = 1.134 \\ 1 & \Rightarrow \theta_{YY}^1 = 0.86 \end{cases}
$$

$$
\Rightarrow \theta_{NY}^1 \in (0.86, \cancel{1.134}) 1
$$

Solve $(*)$ for $\theta_{NY}^1$ when

$$
\theta_{YY}^1 = \begin{cases} 0 & \Rightarrow \theta_{NY}^1 = 4.13 \\ 1 & \Rightarrow \theta_{NY}^1 = 0.49 \end{cases}
$$

$$
\Rightarrow \theta_{YY}^1 \in (0.49, 1)
$$

<!-- page 4 -->

4/6

$$\underline{\theta_{11}} = \frac{\pi_{YY}}{\pi_{YY} + \pi_{NY}} \underline{\theta_{YY}^1} + \frac{\pi_{NY}}{\pi_{YY} + \pi_{NY}} \underline{\theta_{NY}^1}$$

always on-track students ($\underline{YY}$) more likely to graduate than complier students ($NY$).

1. $$\underline{\theta_{YY}^1} > \underline{\theta_{11}} > \underline{\theta_{NY}^1}$$

2. $$\theta_{NY}^0 > \theta_{00} > \theta_{NN}^0$$

complier students more likely to graduate than always off-track students if $\underline{\text{No SSC offer}}$

<!-- page 5 -->

5/6

$Z = 0 \longrightarrow \text{assigned}$

$A = 1 \longrightarrow \text{received}$

| | | $Z=0$ | |
| :--- | :--- | :---: | :---: |
| | | $A=0$ | $A=1$ |
| **$Z=1$** | $A=0$ | $NT$ | ///// |
| | $A=1$ | $C$ | $AT$ |

$$E(A \mid Z = 1) = P(A = 1 \mid Z = 1) = (C, AT)$$

$$E(A \mid Z = 0) = P(A = 1 \mid Z = 0) = AT$$

$$\text{diff} = \underline{\text{compliers}}$$

<!-- page 6 -->

6/6

$\checkmark$ $\underline{\underline{\text{controls}}}$ $w_i = \frac{1}{1 - e(x_i) \downarrow} \uparrow$

$$
\uparrow
$$

$$
P(A = 1 \mid x) \uparrow
$$
