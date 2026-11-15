---
id: "jpsm/stat_mod_ML_2_SURV616/lectures/13_Factor_Analysis_slides"
source: "jpsm"
course: "SURV616"
course_title: "Statistical Methods and Machine Learning II"
doc_type: "lecture"
title: "Lecture 13. Factor Analysis"
original: "stat_mod_ML_2_SURV616/lectures/13 Factor Analysis slides.pdf"
pages: 55
sha256: "a9182efe2e47d32eee0706431882997fc9a775931f9580d0b47fc04d2c1c5e55"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:28"
---

<!-- page 1 -->

# Lecture 13. Factor Analysis

Suzer-Gurtekin

April 2025

<!-- page 2 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Overview

1. Linear Algebra Review

2. Principal Components

3. Factor Analysis

2 / 55
Suzer-Gurtekin
Class 13

<!-- page 3 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

## Eigenvalues

Let $\mathbf{A}$ be a $p \times p$ matrix and $\mathbf{I}$ be the $p \times p$ identity matrix. Then the scalar quantities $\lambda_1, \dots, \lambda_p$ satisfying the polynomial equation $|\mathbf{A} - \lambda\mathbf{I}| = 0$ are called the eigenvalues of the matrix $\mathbf{A}$.

3 / 55
Suzer-Gurtekin
Class 13

<!-- page 4 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

## Eigenvectors

Let $\mathbf{A}$ be a $p \times p$ matrix and let $\lambda$ be an eigenvalue of $\mathbf{A}$. If $\mathbf{x}$ is a nonzero $p \times 1$ vector such that $\mathbf{Ax} = \lambda\mathbf{x}$, then $\mathbf{x}$ is said to be an eigenvector of the matrix $\mathbf{A}$ associated with the eigenvalue $\lambda$.

4 / 55

Suzer-Gurtekin

Class 13

<!-- page 5 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

Let's look at a $2 \times 2$ example:

$$
\mathbf{A} = \begin{bmatrix} 2 & 1 \\ 1 & 2 \end{bmatrix}
$$

We need to solve for $\lambda$. The $2 \times 2$ case is simpler:

$$
|\mathbf{A} - \lambda \mathbf{I}| = \mathbf{0}
$$

The left-hand side within the determinant symbol is:

$$
\begin{bmatrix} 2 & 1 \\ 1 & 2 \end{bmatrix} - \begin{bmatrix} \lambda & 0 \\ 0 & \lambda \end{bmatrix} = \begin{bmatrix} 2 - \lambda & 1 \\ 1 & 2 - \lambda \end{bmatrix}
$$

5/55 Suzer-Gurtekin Class 13

<!-- page 6 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

Then, obtaining the determinant:

$$det \begin{bmatrix} 2 - \lambda & 1 \\ 1 & 2 - \lambda \end{bmatrix} = (2 - \lambda)^2 - 1$$

This results in the following polynomial equation:

$$3 - 4\lambda + \lambda^2 = 0$$

Which has two solutions:
$\lambda = 1$ and $\lambda = 3$

6 / 55  Suzer-Gurtekin  Class 13

<!-- page 7 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

$$\mathbf{A} - \mathbf{1}\mathbf{I} = \begin{bmatrix} 2 & 1 \\ 1 & 2 \end{bmatrix} - \begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix} = \begin{bmatrix} 1 & 1 \\ 1 & 1 \end{bmatrix}$$

7 / 55

Suzer-Gurtekin

Class 13

<!-- page 8 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

For $\lambda = 1$:

$$(\mathbf{A} - \mathbf{1}\mathbf{I})\mathbf{v} = \begin{bmatrix} 1 & 1 \\ 1 & 1 \end{bmatrix} \begin{Bmatrix} v_1 \\ v_2 \end{Bmatrix} = \begin{Bmatrix} 0 \\ 0 \end{Bmatrix}$$

$$\mathbf{v} = \begin{Bmatrix} 1 \\ -1 \end{Bmatrix}$$

8 / 55

Suzer-Gurtekin

Class 13

<!-- page 9 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

For $\lambda = 3$:

$$
(\mathbf{A} - 3\mathbf{I})\mathbf{w} = \begin{bmatrix} -1 & 1 \\ 1 & -1 \end{bmatrix} \begin{Bmatrix} w_1 \\ w_2 \end{Bmatrix} = \begin{Bmatrix} 0 \\ 0 \end{Bmatrix}
$$

$$
\mathbf{w} = \begin{Bmatrix} 1 \\ 1 \end{Bmatrix}
$$

The vectors $\mathbf{v}$ and $\mathbf{w}$ are eigenvectors of $\mathbf{A}$ associated with the eigenvalues $\lambda = 1$ and $\lambda = 3$.

9/55 Suzer-Gurtekin Class 13

<!-- page 10 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

## Spectral Decomposition Theorem

Let $\mathbf{A}$ be a $p \times p$ matrix, then $\mathbf{A}$ has $p$ eigenvalues ($\lambda_i$) and associated eigenvectors ($\mathbf{e_i}$) which form pairs $(\lambda_1, \mathbf{e_1}), \dots, (\lambda_p, \mathbf{e_p})$ where $\lambda_1 \ge \lambda_2 \ge \dots \ge \lambda_p$, and the eigenvectors satisfy $\mathbf{e_1}'\mathbf{e_1} = \mathbf{e_2}'\mathbf{e_2} = \dots \mathbf{e_p}'\mathbf{e_p} = \mathbf{1}$ and $\mathbf{e_i}'\mathbf{e_j} = 0$ for $i \neq j$. We can write $\mathbf{A}$ in a spectral decomposition as:

$$A = \sum_{i=1}^{p} \lambda_i \mathbf{e_i} \mathbf{e_i}'$$

10/55

Suzer-Gurtekin

Class 13

<!-- page 11 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Linear Algebra

A couple of other useful things...

The **trace** of a matrix is the sum of its diagonal elements, $tr(\mathbf{A}) = \sum_{i=1}^p Q_{ii}$.

The trace is equal to the sum of the eigenvalues, $tr(\mathbf{A}) = \sum_{i=1}^p \lambda_i$.

A square matrix is said to be **orthogonal** if $\mathbf{Q}\mathbf{Q}' = \mathbf{Q}'\mathbf{Q} = \mathbf{I}$, or $\mathbf{Q}' = \mathbf{Q}^{-1}$.

11 / 55

Suzer-Gurtekin

Class 13

<!-- page 12 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

Principal components is a **data reduction** technique.

The goal is to contain as much of the original information as possible in a smaller number of dimensions.

It may also help us understand the relationships in the data better.

12 / 55

Suzer-Gurtekin

Class 13

<!-- page 13 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

Begin with a random vector $\mathbf{X}' = [X_1, X_2, \dots, X_p]$ that has covariance matrix $\mathbf{\Sigma}$.

Define the following linear combinations:

$$
\begin{aligned}
Y_1 &= \mathbf{a_1}'\mathbf{X} = a_{11}X_1 + a_{12}X_2 + \dots + a_{1p}X_p \\
Y_2 &= \mathbf{a_2}'\mathbf{X} = a_{21}X_1 + a_{22}X_2 + \dots + a_{2p}X_p \\
&\;\;\vdots \\
Y_p &= \mathbf{a_p}'\mathbf{X} = a_{p1}X_1 + a_{p2}X_2 + \dots + a_{pp}X_p
\end{aligned}
$$

Those $\mathbf{a_i}'$ for $i = 1$ to $p$ are constant terms.

13 / 55   Suzer-Gurtekin   Class 13

<!-- page 14 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

$$Var(Y_i) = \mathbf{a}_i'\mathbf{\Sigma}\mathbf{a}_i$$

$$Cov(Y_i, Y_k) = \mathbf{a}_i'\mathbf{\Sigma}\mathbf{a}_k$$

The principal components are the uncorrelated linear combinations $Y_1, Y_2, \dots, Y_p$.

The first principal component is the linear combination $Y_1 = \mathbf{a}_1'\mathbf{X}$ that maximizes $Var(\mathbf{a}_1'\mathbf{X})$. Now, since we could always simply multiple $\mathbf{a}_1$ by a larger number, we also add the restriction that $\mathbf{a}_1'\mathbf{a}_1 = 1$.

The second principal component is the linear combination $Y_2 = \mathbf{a}_2'\mathbf{X}$ that maximizes $Var(\mathbf{a}_2'\mathbf{X})$ subject to the restriction that $\mathbf{a}_2'\mathbf{a}_2 = 1$ and $Cov(\mathbf{a}_1'\mathbf{X}, \mathbf{a}_2'\mathbf{X}) = 0$.

14 / 55
Suzer-Gurtekin
Class 13

<!-- page 15 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

Let $\mathbf{\Sigma}$ be the covariance matrix associated with $\mathbf{X}$.

Let $\mathbf{\Sigma}$ have the eigenvalue-eigenvector pairs $(\lambda_1, \mathbf{e_1}), (\lambda_2, \mathbf{e_2}), \dots, (\lambda_p, \mathbf{e_p})$.

Then the $i^{th}$ principal component is $Y_i = \mathbf{e_i'X}$.

$Var(Y_i) = \mathbf{e_i'\Sigma e_i} = \lambda_i$ and $Cov(Y_i, Y_k) = \mathbf{e_i'\Sigma e_k} = 0$.

Which means that the principal components are uncorrelated and have variances equal to the eigenvalues of $\mathbf{\Sigma}$.

15 / 55  Suzer-Gurtekin  Class 13

<!-- page 16 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

$$\begin{aligned}
\sigma_{11} + \sigma_{22} + \cdots + \sigma_{pp} &= \sum_{i=1}^p Var(X_i) \\
&= \lambda_1 + \lambda_2 + \cdots + \lambda_p \\
&= \sum_{i=1}^p Var(Y_i)
\end{aligned}$$

Since this is true, the proportion of variance accounted for by the $i^{th}$ principal component $Y_i$ is:

$$\frac{\lambda_i}{\lambda_1 + \lambda_2 + \cdots + \lambda_p}$$

16 / 55

Suzer-Gurtekin

Class 13

<!-- page 17 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

It's also true that the components of the $\mathbf{e_i}$ vector has useful interpretations.

The magnitude of each $e_{ik}$ measures the importance of the $k^{th}$ variable to the the $i^{th}$ principal component.

17/55

Suzer-Gurtekin

Class 13

<!-- page 18 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

Let's look at an example (from Johnson and Wichern). Start from the following covariance matrix for $X_1$, $X_2$, and $X_3$:

$$
\mathbf{\Sigma} = \left[ \begin{array}{ccc} 1 & -2 & 0 \\ -2 & 5 & 0 \\ 0 & 0 & 2 \end{array} \right]
$$

18 / 55
Suzer-Gurtekin
Class 13

<!-- page 19 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

The eigenvalues and eigenvectors are:

$$
\begin{aligned}
\lambda_1 &= 5.83 & \boldsymbol{e}_1' &= [0.383, -0.924, 0] \\
\lambda_2 &= 2.00 & \boldsymbol{e}_2' &= [0, 0, 1] \\
\lambda_3 &= 0.17 & \boldsymbol{e}_3' &= [0.924, 0.383, 0]
\end{aligned}
$$

19 / 55

Suzer-Gurtekin

Class 13

<!-- page 20 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

The principal components are:

$$
Y_1 = \mathbf{e_1^{\prime}X} = 0.383X_1 - 0.924X_2 + 0X_3
$$

$$
Y_2 = \mathbf{e_2^{\prime}X} = 0X_1 - 0X_2 + 1X_3
$$

$$
Y_3 = \mathbf{e_3^{\prime}X} = 0.924X_1 - 0.383X_2 + 0X_3
$$

20 / 55

Suzer-Gurtekin

Class 13

<!-- page 21 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

$$\begin{aligned}
\sigma_{11} + \sigma_{22} + \sigma_{33} &= 1 + 5 + 2 &= 8 \\
\lambda_1 + \lambda_2 + \lambda_3 &= 5.83 + 2.00 + 0.17 &= 8
\end{aligned}$$

In this example, the first principal component accounts for 5.83/8=72.9% of the variance.

The first two components account for 7.83/8=97.9% of the variance.

21 / 55 $\qquad$ Suzer-Gurtekin $\qquad$ Class 13

<!-- page 22 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

That's the algebraic approach to principal components.

There is also a geometric view.

Let's look at a bivariate example.

22/55

Suzer-Gurtekin

Class 13

<!-- page 23 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

From Johnson and Wichern.

$x_2$

$x_1$

$y_1 = \mathbf{e}_1'\mathbf{x}$

$y_2 = \mathbf{e}_2'\mathbf{x}$

$\mathbf{x}'\mathbf{\Sigma}^{-1}\mathbf{x} = c^2$

$\theta$

$\boldsymbol{\mu} = \mathbf{0}$
$\rho = .75$

23 / 55

Suzer-Gurtekin

Class 13

<!-- page 24 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

One caution, the principal components are based upon the variances. If the variances are on different scales, this can result in some variables predominating.

It is important to **standardize** the variables before finding principal components.

24 / 55 Suzer-Gurtekin Class 13

<!-- page 25 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Principal Components

This is a useful data reduction technique.

Produces orthogonal variables that explain a large proportion of original variance.

Important to scale the variables before creating components. Otherwise variables with “large” absolute variance will predominate.

25 / 55

Suzer-Gurtekin

Class 13

<!-- page 26 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Examples

R examples:

* First example looks at temperature in a variety of cities in January and July.
* Second example shows what happens when variables are not standardized.

26/55

Suzer-Gurtekin

Class 13

<!-- page 27 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 1

Temperature in January and July in 64 cities. Run the following R code to obtain the principal components:

```r
library(car)
fit <- princomp(temps)
summary(fit) # print variance accounted for
loadings(fit) # pc loadings
plot(fit,type="lines") # scree plot
fit$scores # the principal components
```

27 / 55
Suzer-Gurtekin
Class 13

<!-- page 28 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 1

temps$January
60
50
40
30
20
10

65
70
75
80
85
90
temps$July

28 / 55
Suzer-Gurtekin
Class 13

<!-- page 29 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 1

Extract the eigenvalues:

```r
> eig.val <- get_eigenvalue(fit)
> eig.val
eigenvalue variance.percent
Dim.1  1.7519238         88.98661
Dim.2  0.2168262         11.01339
cumulative.variance.percent
Dim.1                    88.98661
Dim.2                   100.00000
```

29 / 55

Suzer-Gurtekin

Class 13

<!-- page 30 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 1

Extract the eigenvalues:

```r
> loadings(fit) # pc loadings

Loadings:
        Comp.1 Comp.2
January  0.707  0.707
July     0.707 -0.707

               Comp.1 Comp.2
SS loadings    1.0    1.0
Proportion Var 0.5    0.5
Cumulative Var 0.5    1.0
```

$$Y_1 = 0.707 \times \text{January} + 0.707 \times \text{July}$$
$$Y_2 = 0.707 \times \text{January} - 0.707 \times \text{July}$$

30 / 55
Suzer-Gurtekin
Class 13

<!-- page 31 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 1

**Scree plot**

Percentage of explained variances
75
50
25
0

Dimensions
1
2

31 / 55 Suzer-Gurtekin Class 13

<!-- page 32 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 1

32 / 55

Suzer-Gurtekin

Class 13

<!-- page 33 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 1

R code:

```r
library(car)
fit <- princomp(temps)
summary(fit) # print variance accounted for
loadings(fit) # pc loadings
plot(fit,type="lines") # scree plot
fit$scores # the principal components
plot(fit$scores)
```

33 / 55

Suzer-Gurtekin

Class 13

<!-- page 34 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 2

Taken from Everitt and Hothorn. They report on a study that took eight blood chemistry variables. The measurements are from 72 patients in a clinical trial.

Here are the standard deviations:

```r
> blood_sd
rblood  plate wblood   neut  lymph  bilir sodium potass
 0.371 41.253  1.935  0.077  0.071  4.037  2.732  0.297
```

Note that `plate` has a very large SD relative to other variables.

34 / 55 Suzer-Gurtekin Class 13

<!-- page 35 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 2

If I use the covariance matrix as the input for selecting principal components, I get:

```r
> blood_pcacov <- princomp(covmat = blood_cov)
> summary(blood_pcacov, loadings = TRUE)
Importance of components:
                       Comp.1 Comp.2 Comp.3 Comp.4  Comp.5  Comp.6  Comp.7  Comp.8
Standard deviation      41.29 3.8802  2.642 1.6246 3.5e-01 2.6e-01 8.5e-02 2.4e-02
Proportion of Variance   0.99 0.0087  0.004 0.0015 7.2e-05 3.8e-05 4.2e-06 3.3e-07
Cumulative Proportion    0.99 0.9943  0.998 0.9999 1.0e+00 1.0e+00 1.0e+00 1.0e+00

Loadings:
       Comp.1 Comp.2 Comp.3 Comp.4 Comp.5 Comp.6 Comp.7 Comp.8
rblood                             0.943  0.329               
plate  -0.999                                                 
wblood        -0.192        -0.981                            
neut                                              0.758  0.650
lymph                                            -0.649  0.760
bilir          0.961  0.195 -0.191                            
sodium         0.193 -0.979                                   
potass                             0.329 -0.942               
```

35 / 55
Suzer-Gurtekin
Class 13

<!-- page 36 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 2

If I use the correlation matrix as the input for selecting principal components, I get:

```r
> blood_pcacor <- princomp(covmat = blood_corr)
> summary(blood_pcacor, loadings = TRUE)
Importance of components:
                       Comp.1 Comp.2 Comp.3 Comp.4 Comp.5 Comp.6 Comp.7 Comp.8
Standard deviation     1.67   1.24   1.12   0.882  0.788  0.699  0.660  0.320
Proportion of Variance 0.35   0.19   0.16   0.097  0.078  0.061  0.054  0.013
Cumulative Proportion  0.35   0.54   0.70   0.794  0.872  0.933  0.987  1.000

Loadings:
     Comp.1 Comp.2 Comp.3 Comp.4 Comp.5 Comp.6 Comp.7 Comp.8
[1,] -0.194  0.417  0.400  0.652  0.175 -0.363  0.176  0.102
[2,] -0.400  0.154  0.168        -0.848  0.230 -0.110       
[3,] -0.459         0.168 -0.274  0.251  0.403  0.677       
[4,] -0.430 -0.472 -0.171  0.169  0.118        -0.237  0.678
[5,]  0.494  0.360        -0.180 -0.139  0.136  0.157  0.724
[6,]  0.319 -0.320 -0.277  0.633 -0.162  0.384  0.377       
[7,]  0.177 -0.535  0.410 -0.163 -0.299 -0.513  0.367       
[8,]  0.171 -0.245  0.709         0.198  0.469 -0.376       
```

36 / 55 Suzer-Gurtekin Class 13

<!-- page 37 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Example 2

### Scree diagram

Component variance
0.0 0.5 1.0 1.5 2.0 2.5

Component number
1 2 3 4 5 6 7 8

37 / 55 Suzer-Gurtekin Class 13

<!-- page 38 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Uses of Principal Components

One use is to understand the data better.

In regression analysis when prediction is the goal...

* Creating predictors when $p$ is large relative to $n$
* When predictors are highly correlated

38 / 55
Suzer-Gurtekin
Class 13

<!-- page 39 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

Factor analysis is a technique related to principal components.

The goal is to explain relationships among variables in terms of underlying variables known as **factors**.

Group things together that are highly correlated. Assume they are driven by the same underlying factor.

Very common approach in psychology. Take multiple measurements on an assumed underlying characteristic of personality.

39 / 55 Suzer-Gurtekin Class 13

<!-- page 40 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

40 / 55

Suzer-Gurtekin

Class 13

<!-- page 41 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

Notation for the orthogonal factor model.

Observed random vector $\mathbf{X}$ with $p$ components. That is, $p$ variables in my data.

This vector comes from a $N_p(\boldsymbol{\mu}, \boldsymbol{\Sigma})$ distribution.

We also have $m$ factors, $F_1, F_2, \dots, F_m$ and $p$ errors $\epsilon_1, \epsilon_2, \dots, \epsilon_p$.

41 / 55

Suzer-Gurtekin

Class 13

<!-- page 42 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

With this notation we can write the following model:

$$
\begin{aligned}
X_1 - \mu_1 &= \ell_{11}F_1 + \ell_{12}F_2 + \cdots + \ell_{1m}F_m + \epsilon_1 \\
X_2 - \mu_2 &= \ell_{21}F_1 + \ell_{22}F_2 + \cdots + \ell_{2m}F_m + \epsilon_2 \\
&\vdots \\
X_p - \mu_p &= \ell_{p1}F_1 + \ell_{p2}F_2 + \cdots + \ell_{pm}F_m + \epsilon_p
\end{aligned}
$$

Or, in matrix notation:

$$\mathbf{X} - \boldsymbol{\mu} = \mathbf{L}\mathbf{F} + \boldsymbol{\epsilon}$$

42 / 55

Suzer-Gurtekin

Class 13

<!-- page 43 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

We can rearrange the terms:

$$
\mathbf{X} = \boldsymbol{\mu} + \mathbf{LF} + \boldsymbol{\epsilon}
$$

This may look like a regression model, but the only observed quantities are $\mathbf{X}$ and $\boldsymbol{\mu}$.

Need further assumptions to motivate such a model.

43 / 55
Suzer-Gurtekin
Class 13

<!-- page 44 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

Additional assumptions are:

$$
\begin{aligned}
E(\mathbf{F}) &= \mathbf{0} \\
Cov(\mathbf{F}) &= \mathbf{I} \\
E(\mathbf{\epsilon}) &= \mathbf{0} \\
Cov(\mathbf{\epsilon}) &= \mathbf{\Psi} \\
Cov(\mathbf{\epsilon}, \mathbf{F}) &= \mathbf{0}
\end{aligned}
$$

where $\mathbf{\Psi}$ is a diagonal matrix ($\epsilon_i$ terms are not correlated).

44 / 55 $\quad$ Suzer-Gurtekin $\quad$ Class 13

<!-- page 45 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

This model then implies a covariance structure for $\mathbf{X}$.

$$
\begin{aligned}
Cov(\mathbf{X}) &= \mathbf{LL}' + \boldsymbol{\Psi} \\
Var(X_i) &= \ell_{i1}^2 + \cdots + \ell_{im}^2 + \Psi_i \\
Cov(X_i, X_k) &= \ell_{i1}\ell_{k1} + \cdots + \ell_{im}\ell_{km}
\end{aligned}
$$

where $\psi_i = Var(\epsilon_i)$.

45 / 55
Suzer-Gurtekin
Class 13

<!-- page 46 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

Also under this model, it is possible to partition the variance for each $X_i$.

The portion of the variance due to the factors is called the **communality**.

$$\sigma_{ii} = \ell_{i1}^2 + \ell_{i2}^2 + \dots + \ell_{im}^2 + \Psi_i$$

This is sometimes denoted $h_i^2$:

$$h_i^2 = \ell_{i1}^2 + \ell_{i2}^2 + \dots + \ell_{im}^2$$

46 / 55 Suzer-Gurtekin Class 13

<!-- page 47 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

Let's look at an example:

$$
\mathbf{\Sigma} = \begin{bmatrix} 19 & 30 & 2 & 12 \\ 30 & 57 & 5 & 23 \\ 2 & 5 & 38 & 47 \\ 12 & 23 & 47 & 68 \end{bmatrix}
$$

Then we can use the formula $\mathbf{\Sigma} = \mathbf{LL}' + \mathbf{\Psi}$.

47 / 55
Suzer-Gurtekin
Class 13

<!-- page 48 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

$$
\begin{bmatrix}
19 & 30 & 2 & 12 \\
30 & 57 & 5 & 23 \\
2 & 5 & 38 & 47 \\
12 & 23 & 47 & 68
\end{bmatrix} = \begin{bmatrix}
4 & 1 \\
7 & 2 \\
-1 & 6 \\
1 & 8
\end{bmatrix} \begin{bmatrix}
4 & 7 & -1 & 1 \\
1 & 2 & 6 & 8
\end{bmatrix} + \begin{bmatrix}
2 & 0 & 0 & 0 \\
0 & 4 & 0 & 0 \\
0 & 0 & 1 & 0 \\
0 & 0 & 0 & 3
\end{bmatrix}
$$

In this case, $h_1^2 = 4^2 + 1^2 = 17$. And the total variance of $X_1$ is $17 + 2 = 19$.

48 / 55

Suzer-Gurtekin

Class 13

<!-- page 49 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

There is a remaining issue to discuss. The solutions to any factor model aren't unique.

$$\mathbf{X} - \boldsymbol{\mu} = \mathbf{LF} + \boldsymbol{\epsilon} = \mathbf{LTT'}\mathbf{F} + \boldsymbol{\epsilon} = \mathbf{L}^*\mathbf{F}^* + \boldsymbol{\epsilon}$$

The non-uniqueness is apparent in the above equality. This doesn't change the communalities.

The $\mathbf{L}$ matrix is multiplied by some $\mathbf{T}$ that aids in interpretation of the loadings. This is called factor "rotation."

Because of this relationship, the scale of the covariance matrix doesn't matter either. Factor analysis is scale invariant (principal components are not).

49 / 55
Suzer-Gurtekin
Class 13

<!-- page 50 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

Two different *types* of rotation are possible.

- **Orthogonal**. Factors are restricted to be uncorrelated. E.g. Varimax.
- **Oblique**. Factors are allowed to be correlated. E.g. Oblimin

50 / 55

Suzer-Gurtekin

Class 13

<!-- page 51 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

**Orthogonal** rotations are useful for producing factors that are generalizable. Easier to label and interpret.

**Oblique** rotations are useful for obtaining “best fit.”

51 / 55
Suzer-Gurtekin
Class 13

<!-- page 52 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

The number of factors may be chosen in different ways. With ML estimation, a test of whether a specified number of factors that are adequate to account for the observed covariances is available.

The `psych` package in R will use this method to identify the number of factors.

52 / 55

Suzer-Gurtekin

Class 13

<!-- page 53 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

```r
library(psych)
fit2 <- principal(beer, nfactors=2, rotate="varimax")
summary(fit2) # print variance accounted for
loadings(fit2) #  loadings
```

53 / 55

Suzer-Gurtekin

Class 13

<!-- page 54 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis

Here are the factors:

```r
> loadings(fit3)

Loadings:
         RC1    RC2
cost     0.109  0.954
size    -0.201  0.956
alcohol  0.218  0.939
reputat -0.723 -0.204
color    0.900  0.216
aroma    0.930 -0.130
taste    0.950 -0.118
```

54 / 55

Suzer-Gurtekin

Class 13

<!-- page 55 -->

Linear Algebra Review
Principal Components
Factor Analysis

# Factor Analysis vs Principal Components

| Factor Analysis | Principal Components |
| :--- | :--- |
| Explain *covariances* of observed variables. | Explain *variance* of observed variables. |
| Adding factors will change the loadings of all factors. | Adding components will not change previous components. |
| Factor scores requires several decisions by the analyst (rotation, number of factors). | Principal components are straightforward to calculate. Choose number via scree plot. |
| Factor analysis scale invariant. | Principal components may change depending upon use of covariance or correlation matrix. |

55 / 55 $\qquad$ Suzer-Gurtekin $\qquad$ Class 13
