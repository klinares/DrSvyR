---
id: "jpsm/complex_sample_data_SURV701/lecture_notes"
source: "jpsm"
course: "SURV701"
course_title: "Analysis of Complex Sample Survey Data"
doc_type: "lecture"
title: "lecture_notes"
original: "complex_sample_data_SURV701/lecture_notes.pdf"
pages: 7
sha256: "ed660141d25f118bbe573e5c890c5ab83aebb2a52dbc3c38f46f6c45e3d21bed"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:51"
---

<!-- page 1 -->

Analysis of complex sample survey data

1/8/26

* Goal: Understand design-based estimation and inference. What is complex sampling, deviation from simple random sampling.
* Steps in applied survey data
    * define analysis procedure
        * describe target population
        * understand multivariate relationships among variables
    * understand sample design
        * population estimation and inference
    * understand design variables, constructs, missing data
        * key features of design variables -
    * Analyzing data
        * univariate, bivariate, multivariate, GLM, cox proportional hazard, missing data methods
    * interpret and evaluating results
        * inference from the estimate with measures of uncertainty
    * reporting estimates
* Probability samples
    * Probability sample design – each population has a known non zero probability of selection. Properly weighted estimates are unbiased for the population statistic. Variance of sample statistic can be estimated from the sample data.
    * Simple random sample analog to independently and identically distributed.
* Complex sample designs
    * A probability sample developed using sampling procedures such as stratification, clustering and weighting designed to improve statistical efficiency, reduce costs or improve precision for subgroup analyses relative to SRS.
    * Unbiased estimates with measurable sampling error are still possible
    * independently and identically distributed, equal probabilities of selection may no longer hold.
* Where are designs used
    * common designs examples
        * area probability samples of households
        * multi-stage samples of schools, students
        * stratified samples of hospitals
* classification of sample designs

| | **Method of Inference** | |
| :---: | :---: | :---: |
| **Sampling Plan** | **Design-based** | **Model-based** |
| Probability Sample | **A\*\*** | B |
| Model-dependent Sample | C | D |

* sampling plan - framework and method for selecting the observational units

<!-- page 2 -->

* probability sampling from Hansen 1953, Kish 1965
    * Model assisted sampling Sarndal et al., 1992.
  * estimation and inference – model based
    * prediction approach Valiant et al., 2000
* Model based approach
  * If you can correctly estimate the model, you don’t need the random sample.
* Design based inference
  * Inference is based on the expected distribution of sample estimates. Goal is inference on a finite population parameter.
    * Confidence intervals are usually symmetric, but they don’t have to be.
* Concept of the design effect

## Concept of the Design Effect

$$
D^2(\hat{\theta}) = \frac{SE(\hat{\theta})_{complex}^2}{SE(\hat{\theta})_{srs}^2} = \frac{Var(\hat{\theta})_{complex}}{Var(\hat{\theta})_{srs}}
$$

Where:

$D^2(\hat{\theta}) =$ the design effect for the sample estimate, $\hat{\theta}$

$Var(\hat{\theta})_{complex} =$ the complex sample design variance of $\hat{\theta}$;
and
$Var(\hat{\theta})_{srs} =$ the simple random sample variance of $\hat{\theta}$

* Capital D represents true design effect, and lower d is estimated.

## Design Effects for Complex Samples

$$
D^2(\hat{\theta}) \approx 1 + f(G_{strat}, L_{cluster}, L_{weighting}),
$$

where:

$G_{strat} =$ the relative gain in precision from stratified sampling compared to SRS

$L_{cluster} =$ the relative loss of precision due to clustered selection of sample elements

$L_{weighting} =$ the relative loss of precision due to unequal weighting for sample elements

<!-- page 3 -->

* Standard error of the proportion as a result of increase sample size

* Stratification will help reduce the standard error, clustering is the opposite. Same for weighting for selection probabilities, important for non-response, increase variance in standard error.
* Finite population correction FPC – is the proportion of the population that is not sampled, and generally ignored unless stated. It is good to account for if it reduces your variance.
  * $S^2$ is called variance, but this is the element variance, it is a measure of deviations of $Y$ from mean of $Y$. Where $\text{var}(Y)$ is the $E(\bar{y} - \bar{Y})^2$ deviations of sample means from the true parameter estimate, but we do not know this.
  * The square root of $s^2$ is the standard deviation, but the square root of $\text{var}(Y)$ is the standard error.
    * <u>Simple Random Sampling</u>

$$
\text{var}(\bar{y}) = \left(1 - \frac{n}{N}\right)s^2/n = (1 - f)s^2/n
$$

where:
$n$ - sample size
$N$ - population size

<u>Stratified Random Sampling</u>

$$
\text{var}(\bar{y}_{st}) = \sum_{h=1}^{H} (1 - f_h)W_h^2 s_h^2 / n_h
$$

where: $f_h = n_h / N_h$

* It is the $W^2_h$, the strata proportion in the population, is what reduces the variance.
  * $W_h = N_h / N$ will sum to 1.

<!-- page 4 -->

## Stratified Sampling

<u>Procedure</u>
* form strata
* independent selections in each stratum
* estimate for stratum h: $\bar{y}_h$
* overall estimate: $\bar{y}_{st} = \Sigma W_h \bar{y}_h$

$$\text{where} \quad W_h = N_h / N$$

$$s_h^2 = \frac{\sum_{n=1}^{n_h} (y_{hi} - \bar{y}_h)^2}{n_h - 1}$$

* sampling variance: $\Sigma W_h^2 Var(\bar{y}_h)$

$$S_h^2 = \frac{\sum^{N_h} (y_{hi} - \bar{Y}_h)}{N_h - 1}$$

* estimated sample variance: $\Sigma W_h^2 \text{var}(\bar{y}_h)$

31

* If our sampling rate is less than 5%, our standard error will shrink when using FPC, it doesn't hurt to use it but it depends on the audience. Depends on what we are trying to achieve.
* If stratums vary a lot in means, the variance reduction gain is large, but hard in practice.
* Cluster sampling to help reduce cost. Also useful when we know the clusters but not the elements. We assume that clusters are the same size, A is total clusters PSUs, B is cluster size SSUs.

### CLUSTER SAMPLE DESIGN EFFECT

* Suppose that a SRS of $n = 240$ children from the town produced the estimate of the proportion immunized as

$$p_0 = 160 / 240 = 0.667.$$

$$v(\hat{p}) = \frac{\hat{p}(1 - \hat{p})}{n - 1}$$

* Then: $\boxed{v(p_0) = (1 - f) \frac{p_0 q_0}{n - 1} = 0.0009112.}$

* For the cluster sample $v(p_c) = 0.002760$ (quiz).

* The estimated variance of $p$ with the cluster sample is thus larger than the variance of $p$ with a SRS of the same size.

<!-- page 5 -->

* Intraclass correlation, roh, $D^2 - 1 + (B-1)* \text{roh}$. Design effect for the cluster sample depends on B and homogeneity of the elements within the clusters, roh.

$$\hat{\rho} = \frac{d^2(\bar{y}) - 1}{B - 1}.$$

  * This is a measure of how similar elements are within the cluster.

### DESIGN EFFECTS FOR TWO-STAGE SAMPLES

| $a$ | $b$ | $d^2(p_c) = 1 + (b - 1)\hat{\rho}$ | $n_{eff}$ |
| :---: | :---: | :---: | :---: |
| 10 | 24 | $1 + (23 \times 0.091) = 3.03$ | 79 |
| 20 | 12 | $1 + (11 \times 0.091) = 1.97$ | 122 |
| 30 | 8 | $1 + (7 \times 0.091) = 1.62$ | 148 |
| 40 | 6 | $1 + (5 \times 0.091) = 1.44$ | 167 |
| 80 | 3 | $1 + (2 \times 0.091) = 1.18$ | 204 |

* Three elements of design-based inference Cis, we assume there is a true parameter value. A wald CI is symmetric and the quantity is based on the critical student-t statistic. The margin of error is student t x se.
* Weighting is for compensating for unequal probabilities of sampling. Calibration estimates adjust weighted sample distribution to a specific variable. It is used to improve accuracy in estimates.
  * Industry standard:

    1) Weight for unequal probabilities of selection: $\text{w}_{\text{sel}}$;

    2) Weight for sample nonresponse: $\text{w}_{\text{nr}}$;

    3) Poststratification weight for population noncoverage and sampling variance reduction: $\text{w}_{\text{ps}}$.

<!-- page 6 -->

* The overall weight is the product of the sample nonresponse and calibration weight. The base weight or design weight should sum to the population total.
  * The smaller the selection probability, the smaller the weight. Weight of 1 are called certainty selection.

Sampling Procedure: for example, *SRS* design

$\pi_i = n / N$

n

$w_i = \frac{1}{\pi_i}$

Sample

N
Population

$\hat{N}$
Weighted Sample

* Yellow is the sampling frame, purple population. If we sum up w\_i, we should get something close to N.
* EPSEM design – each population unit has the same probability of being selected with or without replacement.
* Non-EPSEM, the selection probability is not equal for every element.
* Weighting for non-response.
  * If we have a sample and some units don't respond. The idea is to group sample using information we know from both respondent and non-respondent units.
  * Non-response perspectives – stochastic and the deterministic. They both make assumptions that people will respond and some will not. Nonresponse error difference in the sample mean and the mean if everyone would have responded.

$$Bias(\bar{Y}_R) = \bar{Y}_R - \bar{Y} = (1 - RR) \times (\bar{Y}_R - \bar{Y}_{NR})$$

* Unequal weighting effect (UWE) is 1 + L loss due to weighting. Used to quantify negative impacts of highly variable analysis points. This can be expressed as relavariance cv = var(w\_i) / w\_bar^2. The denominator is the average weight.

<!-- page 7 -->

**Module 3, Sampling Error Calculation Models**

* This is related to disclosure avoidance. To create a variance estimation model, since you need the original data.
* Combining strata, when there are many strata. SECU = sampling error computation unit. SEST = sampling error stratum.
* Random groups, where there are many PSUs to simplify SECU.

**Module 4 Taylor series linearization**

* TSL, It is a linear combination of data.. This works for nonlinear function of sample quantities.
* Another approach is jacknife repeated replication (JRR), Balanced Repeated replication (BRR), and bootstrapping.

### Weighted mean with no clustering and stratification

$$\bar{y}_w = \frac{\sum_i y_i w_i}{\sum_i w_i} = \frac{x}{z}$$

$$x_i = w_i y_i, \quad x = \sum_i x_i$$

$$z_i = w_i, \quad z = \sum_i z_i$$

$$var(x) = n \cdot s_x^2$$

$$var(z) = n \cdot s_z^2$$

$$cov(x, z) = n \cdot s_{xz}$$

$$s_x^2 = \frac{\sum^n (x_i - \bar{x})^2}{n - 1}$$

$$var(\bar{y}_w) = \frac{1}{z^2} \{ n \cdot s_x^2 + \bar{y}_w^2 \cdot n \cdot s_z^2 - 2\bar{y}_w \cdot n \cdot s_{xz} \}$$

Percentiles, subpopulation analysis and functions of estimates Module 6.
* Avoid jacknife with quantiles.
* conditional analysis, when we subset data to the subpopulation. Can be an issue if we have stratified or cluster samples. For SRS it is fine, but if denominator is not fixed, TSL is necessary. We need to account for the variability of the denominator that can change from one sample to another.
* Unconditionaal analysis, treating subpopulation size as a random variable.
*
