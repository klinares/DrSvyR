---
id: "jpsm/applied_sampling_SURV625/applied_sampling_notes"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "lecture"
title: "applied_sampling_notes"
original: "applied_sampling_SURV625/applied_sampling_notes.pdf"
pages: 22
sha256: "074674abd6cfd05960e079079ecfb4651f5bcbcbcfffba4def249512fb79441f"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:43"
---

<!-- page 1 -->

1/8/25 Intro

* What is a design?
  * Experimental designs are ideal as there are identical groups, and confounders—which are variables that may affect the intervention assignment and outcome of inference—can be controlled. In practice, this is usually not the case.
  * Most studies are observational, such as survey samples, but we want to achieve causal inference. **Quasi** experiments can be the middle ground, but we have to think whether it is implementable.
  * Design characteristics,
    * realism can it be implemented, randomization can it be randomly assigned, and representation can it apply to a population.
  * In the rock the vote, xbox 2008 voting study, it assumed MNAR, but this is a problem as those not represented in the survey can be different from those observed. Using these data was okay, participating in xbox is assumed to be independent from political ideology.
    * For COVID, is we draw a simple random sample can we conclude the prevalence of COVID? Yes, but getting data from testing labs resulted in sampling from the population that was already likely to be infected.
* Class goals: Implement a design, infer from analysis, project to inform future data collection.
* Inference, from sample to target population.
* Population quantities of interest, population mean, percentiles, coefficients which are statistics in a finite population.
* **Sampling distribution** – which is the distribution of different values of the statistic obtained by the process of taking all possible samples from the population. Draw a target from a population and infer on the population.
  * However, we usually do not observe the full population.
  * Randomization theory – based on sampling distribution assumed that the population is fixed, and if we draw a new sample we should get a different value.
    * The probabilities of selection for units in the samples give the sampling distribution of the statistics, tau_hat.
* Probability review
  * What is a *random variable*? Random variable $Y$ can take on different values in different samples. It is a function that assigns a numerical value to each possible outcome of an experiment.
  * What is a *probability distribution*? The probability distribution of $Y$ depicts all possible values of $y$, the probability of each value ($P(Y=y)$, where $y$ is the realization of $Y$.
  * *Expected* value of the statistic is the weighted average of the possible sample values of the statistic. $E(Y) = \text{sum of } y * P(Y=y)$.
  * What is *variance*? Difference in mean squared sum. It quantifies the spread or dispersion of a set of data points around their mean.
  * What is *covariance* of two random variables $X$ and $Y$? $\text{Cov}(X, Y)$, the correlation. It is a measure of the joint variability of two random variables.
  * *Coefficient of variation* (CV), $\text{CV}(Y) = V(Y) / E(Y)$ or $\sigma/\mu$ for $E(Y)$ not equal to zero, ratio of variance to the mean. It is a measure of relative variability, and thus it is the standard error expressed as a fraction of the mean.
    * This is used frequently.
  * *Joint probability*, the probability of two events occurring $P(X=x, Y=y)$

<!-- page 2 -->

* *Conditional probability*, adjusts the event probability given a related event occurred $P(Y=y \mid X=x) = P(X=x, Y=y) / P(X=x)$.
* *Conditional expectation of Y* given $X = x$ is $E(Y \mid X=x) = \text{sum of } y \text{ times } P(Y=y \mid X=x)$. The following are all related to this.
* *Conditional variance of Y*, is the variance of a random variable given the values of one or more other variables.
* *Successive conditioning* the process of calculating the probability of an event by updating your initial probability based on the occurrence of multiple dependent events, one after another, where each new probability calculation takes into account the information from the previously observed event, essentially "conditioning" your probability estimate as new information becomes available.
* *Total variability* refers to the overall spread or dispersion of possible outcomes within a probability distribution, essentially capturing how much variation exists across all potential results, often measured using the variance or standard deviation of that distribution.
* mean square error **MSE** is a measure of *accuracy* of an estimator, or how close the estimate is to the true value. *Precision*, variance, measures how close estimates from different samples are to each other. Measures the average mean squared difference between predicted values from a model and a the actual observed values, indicating how close a model's predictions are to the true value. Lower MSE indicates better model accuracy.

Thus an estimator $\hat{t}$ of $t$ is **unbiased** if $E(\hat{t}) = t$, **precise** if $V(\hat{t}) = E[(\hat{t} - E[\hat{t}])^2]$ is small, and **accurate** if $\text{MSE}[\hat{t}] = E[(\hat{t} - t)^2]$ is small. A badly biased estimator may be precise but it will not be accurate; accuracy (MSE) is how close the estimate is to the true value, while precision (variance) measures how close estimates from different samples are to each other. Figure 2.3 illustrates these concepts.

Archer A
Archer B
Archer C

**FIGURE 2.3**
Unbiased, precise, and accurate archers. Archer A is unbiased—the average position of all arrows is at the bull's-eye. Archer B is precise but not unbiased—all arrows are close together but systematically away from the bull's-eye. Archer C is accurate—all arrows are close together and near the center of the target.

In summary, the finite population $\mathscr{U}$ consists of units $\{1, 2, \dots, N\}$ whose measured values are $\{y_1, y_2, \dots, y_N\}$. We select a sample $\mathscr{S}$ of $n$ units from $\mathscr{U}$ using the probabilities of selection that define the sampling design. The $y$s are fixed but unknown quantities—unknown unless that unit happens to appear in our sample $\mathscr{S}$. Unless we make additional assumptions, the only information we have about the set of $y$s in the population is in the set $\{y_i : i \in \mathscr{S}\}$.

* Probability theory continued. Think what is the strategy and implementation, the process of each step rather than understanding the formula.
* How does the sampling distribution affect our inference?
* Sample fraction is just the sample proportion $f=n/N$.
  * Finite pop. Coef factor is $\text{fpc} = 1-f$.
* Sampling inference

*[Figure: The figure shows three circular archery targets without axes that illustrate the concepts of bias, precision, and accuracy by comparing the shot placements ('X' marks) of three groups: Archer A, Archer B, and Archer C. The main pattern shows Archer A's shots widely scattered around the center (unbiased but imprecise), Archer B's shots tightly clustered on the outer upper-right edge (precise but biased), and Archer C's shots tightly clustered right in the bull's-eye (both precise and accurate).]*

<!-- page 3 -->

*   *   the expectation of a random sample comes from sampling N times from the same population and calculating t\_s\_hat.
    *   The difference in SE and SD,
        *   The standard deviation (often SD) is a measure of variability. When we calculate the standard deviation of a sample, we are using it as an estimate of the variability of the population from which the sample was drawn.
        *   We can estimate how much sample means will vary from the standard deviation of this sampling distribution, which we call the standard error (SE) of the estimate of the mean. Another way of considering the standard error is as a measure of the precision of the sample mean.
    *   **Bias** the difference between expectation and true value. Not for a sample, but for an average of samples. If 0, it is unbiased. If we are taking about bias we are talking about expectation.
    *   If variance V(t\_hat) of estimator is small, it is precise.
    *   **MSE** is the expectation of the squared differences,. Unbiased if the expectation of a value equals the value, and accurate if MSE is small. If we are taking about MSE, we are talking about accuracy of an estimator.
    *   CI is the coverage probability close to the nominal level.
    *   Statistical inference validity assessment calculates bias, variance, MSE, and CI
*   Simple Random Sample (**SRS**), the sampling probability for each unit is the same. R function in sampling::srswr() w/ replacement.
    *   Every element has an equal chance of selection called epsem, or self-weighting.
    *   Sampling variance estimate var(y\_bar), variation in the sampling mean.
    *   For a proportion, the variance is a function of the mean.
*   Projection, balancing the estimation precision with survey costs, deciding on the amount of sampling error by specifying the tolerable error.
    *   MOE is the error, is one half of the width of a 95% CI. It is the product of the standard error.
    *   Find an equation to achieve the sample size.
*   Design effects ratio of the sampling variance under a complex design and the SRS sampling variance.
*   Sampling frame
    *   frame is a set of materials used to designate a sample of units. This list can be telephone numbers or maps of zip code tracts.
    *   **Noncoverage**, Some population elements are not in frame, zero chance of selection.
        *   Under coverage can be solved by supplementing frames that cover the noncovered elements.
        *   Use noncoverage weighting adjustments (MrP)
    *   **blanks** in list, can reject blanks by adjusting the sampling rate and size, or substitute with the next element in list.
    *   **Duplicates** solutions, down weight them, remove them, if there are many duplicates in the list choose unique listings.
    *   **Clustering**, take number of clusters and adjust by size of cluster, than adjust the size in advance using a ratio estimator.
    *   Objective respondent selection, sampling single element from small clusters, the Kish method creates selection table with eligible household members by age and gender. From one household pick one table based on a probability and select the max subject number.
    *   Many to many matching, more than one population element can be selected by more then one frame element. Solution, combination of weights and subsampling.

<!-- page 4 -->

**1/22/25 Stratified sampling**

* Sampling project
  * Addresses requirement from monitor teenager smoking and drug use. We need to conduct a state wide sample of youth. Use survey data to monitor rates. Think about the proportion estimate as the quantity of smoking. What is the drug use prevalence?
    * We are asked to design a sample of teens.
    * Specify sample size.
    * Multistage sampling, such as between clusters and within.
    * How big is the cluster based on school size.
    * Where are the strata defined, allocate sample. Sample different number of cells from each strata.
      * How do we select the first stage.
  * Deliver 2 page report with an appendix, describe sampling design process, all aspects above.
  * Should we conduct school, social media, household surveys?
  * Consenting from parents and attrition will be issues.
  * Sample schools from MI, than students.
    * Grades 7th-12th.
    * Think about how the school information is flawed in serving as a sample frame.
    * List of students of middle school, use to select students.
    * Sample size will be based on completed interviews.
    * Response rate 30% schools, teenagers 70%.
    * Separate estimates for each of the 9 regions, strata.

* Stratified sampling
  * SRS, we use a sample to approximate the population mean, but it is biased, we estimate variance with finite pop correction factor ignore if lower than 1. We need to estimate the element variance $s^2$ from the sample to calculate the sampling variance.
  * Stratified, collect SRS independently within each strata, and each strata are divided elements of the population into subgroups using auxiliary information. Each strata's element is mutually exclusive and exhaustive, meaning they cannot be in another strata.
    * Within each strata we can do sampling w/ or w/o replacement.
    * We need desired precision for subgroups.
    * Since each strata is independent, convenient to administer and lower survey cost, and often more precise estimates for pop means and totals.
  * Inference
    * Population mean

$$\bar{Y} = \sum_h \frac{N_h}{N} \bar{Y}_h \doteq \sum_h W_h \bar{Y}_h$$

    * weighted sum of the strata.
    * The sample mean, $\text{bar\_y\_w} =$ each stratas sum of weighted mean. Weighted by stratums size.
    * Element-level weighting

<!-- page 5 -->

$$
\bar{y}_w = \frac{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi} y_{hi}}{\sum_{h=1}^H \sum_{i=1}^{n_h} w_{hi}}
$$

  * this is something referred to as inverse probability weighting. Survey weight w_hi, the sampling weight for unit I in stratum h.
  * We do not sample stratas, all included, so total variance depends on within strata variance.
* Proportionate allocation – the sample reflects the pop w/ respect to the stratification. The stratified mean is the same as the pop mean. We want to achieve epsem.
* Equal allocation – same sample size across strata, minimize sampling variance for comparison.
* Neyman allocation – smallest sample variance. Depends on standard deviation of the stratum.
* Optimum allocation – cost related to stratum, involves sampling variance and cost related to stratum.

| | Proportionate | Equal | Neyman | Optimum |
| :--- | :---: | ---: | ---: | ---: |
| Goal | Representative | minimize the sampling variance for comparisons $var(\bar{y}_h - \bar{y}_{h'})$ | Minimize the sampling variance $var(\bar{y}_w)$ | Minimize the sampling variance under total fixed cost |
| $n_h$ | $n W_h$ | $n / H$ | $k W_h S_h$ | $k W_h S_h / \sqrt{C_h}$ |
| epsem? | Yes | No | No | No |
| deff | $< 1$ | unsure | $< 1$ | $< 1$ |
| Multi-purpose | All variables | All variables | Per variable | Per variable |

* 
  * WILL BE TESTED ON ALLOCATION IN MIDTERM. In project we need to choose one.

### Ratio & regression estimation 1/29/25

* Review stratified sampling
  * In projection we calculate the design effects first, than multiply SRS design.
    * In allocation the design effects will be smaller than 1.
    * after getting projection sample size, allocate across strata. What is the allocation plan?
* Randomization theory, design based sampling, sampling design determines how sampling variability is estimated. It's about sampling selection.
* Model based sampling, the model determines how the variability is estimated. It's about the model structure
* there is a discrepancy in how we talk about variance. Sampling variance, average squared deviation of the estimate from expected value, specific to the design. Model variance, same but the average is over all possible samples, specific to model.
* Ratio estimation, improves precision of estimates by incorporating auxiliary information correlated with the variable of interest. Think y is approval, x is region which we known the population distribution.
  * Ratio is defined as the totals for y and x which = Y_bar/X.
  * Ration and regression estimation, calculate R, correlation.
  * Ratio estimator B_hat, when sample size changes we need to use ratio estimation of mean.

<!-- page 6 -->

* But if we don’t know the population sizes than we estimate N\_hat by t\_x/X\_bar
  * if we compare ratio composition, we find that the sample may still deviate from the population which we can than poststratify to correct.
  * ex. Laplace estimation used the number of births as auxiliary variables to estimate the total population.
  * 

**How many students . . .**

point estimate sampling variance

**submit standard error proposal by wed. The sample size n\_h is a random variable.**

* If we can reduce the variability in the sample size, we can reduce the bias in the sampling variance and CV in the ratio estimate.
* MSE – sum of the variance and the squared bias. MSE = variance. MSE approximates the variance.
  * MSE is small is large sample, n/N is large, deviations are small, and R is close to 1.
  * Using the regression model w/o the intercept is how we get residuals.
  * Variance estimator based on regression residuals.

$$var(\hat{B}) = (1 - \frac{n}{N})\frac{s_e^2}{n\bar{x}^2}$$

  * We can use the ratio estimator to estimate the population mean. Than we can predict population total for Y.
  * Ratio estimator works if model fits data, straight line through data, but in practice we have the intercept and slope.
  * If we know pop X\_bar, we can obtain the regression estimator slide 40 lecture 4.
  * In subdomian estimation, the denominator is a random variable.
* Poststratification
  * if sample size is large, we can approximate; however, sample size are variable.
* Summary
  * ratio and regression estimation use auxiliary variable that has high correlation with y
  * ratio estimation useful for cluster sampling.

<!-- page 7 -->

**February 5 2025 cluster sampling, equal sized**
* example on stratified gender.
  * Q. How many students planning to work in academia?
    * Using simple random sample strategy, not stratified.

$$N^2 * var(p) = N^2 * \frac{s^2}{n}$$

  * There is a typo and needs the $1-f$ in between $n\_2$ and other term.
* Cluster sampling
  * 1 stage cluster sampling, select clusters at random, and select all elements within the selected clusters.
    * In stratification some elements are selected across all clusters/strata. Sampling variance is the average within strata. We do not sample strata!. They are fixed by design but we can create them, think gender strata.
    * For cluster, there is between cluster variance.
    * Clusters are large, while strata is small, and naturally occurring. Clusters we cannot create such as states, or counties.

| | Stratified sampling | Cluster sampling |
| :--- | :--- | :--- |
| Meaning | The researcher divides population into a few strata, and then samples are randomly selected within each stratum | Naturally occurring groups called 'clusters' are identified (possibly on a frame), and then clusters are sampled |
| Sample | Individuals selected from all strata | Collectively from randomly selected clusters |
| In order to minimize sampling error | Within-group differences among strata should be minimized, and between-group differences among strata should be maximized | Within-group differences should be consistent with those in the population, and between-group differences among the clusters should be minimized (will minimize roh!) |
| Sampling frame | A sampling frame is needed for the entire target population | In single-stage cluster sampling, a sampling frame is needed only for the clusters. In two-stage and multistage cluster sampling, a sampling frame of individual elements is needed only for the elements in selected clusters |

    * Geographies in stratified are higher level such as states, clustering are smaller like counties.
  * Notation
    * secondary sampling unit is the *i*th in a PSU.
    * $N$ number of clusters
    * $M\_i =$ within cluster count.
    * $J$th is the measurement element in $i$th PSU as $y\_{ij}$.

<!-- page 8 -->

* 
    * 
        * Y_bar sums across both levels clusters $N$ and $M\_i$.
    * Design effect, variation on a metric.
        * When complex survey design, a ratio between the complex variance / SRS to show how much the chosen complex sampling method impacts precision of the metric.
        * $\text{Roh} = \text{rate of homogeneity}$
        * anova table, we are looking at the element variance.
* Two stage clustering
    * SRS of PSUs, from $N$ of PSU
    * SRS of $m$ SSUs from selected PSU of size $m$, selecting at random elements from the cluster.
* Poststratification example, how to estimate number of students?
    * Use sample proportion
        * multiply numerator by 10 directly
            * for instance $84+40 = 124/n = 124 * 10 = 1240$.
* We draw clusters using SRS, 1 stage, another SRS of elements in cluster, $2^{\text{nd}}$ stage.
    * The sizes change but the sampling variance is the same.
* ICC – we are inflating variance b/c clusters are correlated within each other. If ICC is 1, homogeneity.
    * ICC used for **design effect.**
        * A ratio of two variances to compare precision of estimate from a complex design against a simple design (SRS).
            * $1 + (M - 1) * \text{roh}$. Roh is ICC,
                * $M =$ cluster size as in number within clusters
* **HW 3 = slide 60 is needed**
    * slide 65 lecture 5, two stage cluster sampling
    * in 95% make sure I saw, number of sample cluster vs cluster size.
    * Projection
    * slide 66 projection
        * 1. sampling variance for a proportion. $F = n*m / N*M * (p)/\text{total elements}$
            * we do not need variance of $p$, as it is a function of $p$.
        * 2. deff – SRS inflates variance in the estimate by 2.6 times
        * 3 roh = clustering design matters. Always report deff and roh.
        * 4. deff with larger sampling cluster size it improves precision.
        * 5. new srs = since the $m$ size increase, we need to re-estimate SRS sampling variance. Adjust population fraction.
        * 6. update cluster sampling variance. We can plug in new design effect. This gives us projected cluster sampling variance for the new design of 10 elements in each cluster.

**February 19 2025**

* HW2 review

<!-- page 9 -->

* 
    1. SRS sampling variance:
       $$var_{srs}(\bar{y}) = (1 - f) \frac{p(1 - p)}{nm - 1} = (1 - \frac{10 * 5}{400 * 15}) \frac{0.52 * 0.48}{50 - 1} = 0.005051$$
    2. $deff = \frac{var(\bar{y})}{var_{srs}(\bar{y})} = \frac{0.013399}{0.005051} = 2.6525$
    3. $\hat{roh} = \frac{deff - 1}{b - 1} = \frac{2.6525 - 1}{5 - 1} = 0.41313$
    4. A new design with $m_{new} = 10$ and
       $$deff_{new} = 1 + (m_{new} - 1) * \hat{roh} = 1 + 9 * 0.41313 = 4.71817$$
    5. New SRS sampling variance
       $$var_{srs-new}(\bar{y}) = (1 - f_{new}) \frac{p(1 - p)}{nm_{new} - 1} = (1 - \frac{10 * 10}{400 * 15}) \frac{0.52 * 0.48}{100 - 1}$$
    6. New cluster sampling variance
       $$var_{cluster-new}(\bar{y}) = var_{srs-new}(\bar{y}) * deff_{new}$$

* This topic will be in the midterm.
* Projection
    * changing subsamples changes design effects. As m increases, deff increases (roh fixed)
    * precision depends on n and m
    * optimal n and m, by minimize sampling variance for fixed cost
    * C = total budget, C_0 fixed costs subtracted from total budget.
        * Sampling cost C – C_0 slide 68.
            * optimal size depends on cost per cluster, per element, and roh

**February 12 2025 Cluster sampling**

* **HAVE sampling calculations for team work**
    * what are the design procedures, and projection. Allocation across strata. What is the proportion of students in each strata.
* PPS = probability proportionate size sampling.
* Use Taylor Series Linearization to get sampling variance.

week 4 sample sizes
* 1200
* 2267
* 3
based on our judgment to account for finite population or not.

week 5 proportions, rho
* .01
* .02
* .03

<!-- page 10 -->

can we average rhos? No, they are fixed.

* Slide 41, n is the number of clusters which our df is n-1 or 10-1
* the cv of .1114 which is not smaller than .1, but smaller than .2 so it is adequate.
  * If cv=0, the se is 0 and when taking random samples we get the same size.
* Roh .09, new is 20
* When we create strata, we want to use a strata that is correlated with out outcome. We want to maximize between strata heterogeneity, and minimize strata homogeniety.
* If we sample the census, the sampling variance is 0 since we are taking the population.
* Systematic sampling, easy to implement and a proxy for SRS. We use auxiliary information on the population frame to order the list, such as geographic or age.
  * This is a special case of clustering sampling with an implicit stratification.
  * How to select clusters.
    * Calculate sampling interval. N/n, inverse of sampling rate.
    * Pick random start between 1 and sampling interval.
    * Take all elements in order with random start + the sampling interval.
    * Each column is a cluster, each row is a strata.
      * But we only sample one cluster.

**February 26 2025, sampling probability of proportional to size (SPPS)**

* Midterm March 26
  * will cover all topics up to march 12. HW and project type questions. No internet.
* PPS, motivations for controlling sample size.
  * We want to control sample size
  * a ratio mean is bias
  * we want to control survey cost
  * avoid large clusters or they will dominate analysis
    * we want to look at between cluster variation
    * equal size samples from each cluster
* PPS is the solution to achieve epsem as it reduces variance, and equal subsample size at the same time
  * overall selection rate f is the product of the sampling rate of selecting clusters, if I want 2 cluster of 100 than it is 2/100, and the sampling rate of the elements. F = m_o/M_0 which is population information.
    * We select clusters with probabilities proportionate to their size M_i.
    * F = m_0/M_0 number of clusters times the number of elements I want to draw..
    * first stage selection rate

$$
f_i = \frac{m_0 M_i}{M_0 m} = \frac{n * m * M_i}{\sum_i M_i m} = \frac{n M_i}{\sum_i M_i}
$$

    * The second stage

$$
f = f_i f_{j|i} = f_i \frac{m}{M_i} = \frac{m_0}{M_0}
$$

<!-- page 11 -->

*   *   The larger the cluster size, the more likely it is to be selected.
*   PPS is the probability of selecting a particular cluster from a population and is directly proportional to its size, meaning larger clusters have a higher chance of being chosen compared to smaller ones; essentially, the bigger the cluster, the greater its likelihood of being included in the sample
    *   However, every element has the same selection probability.
        *   Larger clusters selected with higher probabilities, elements at a lower rate
        *   smaller cluster selected at lower probabilities, elements at a higher rate
*   In practice we do this by
    *   random sampling with replacement, but we end up with duplicates
    *   systematic sampling w/o replacement

**midterm question**, describe systematic sampling. 3 concepts, (lecture 7, slide 3)

1. Calculate the sampling interval $k = 1/f = N/n$
2. Select a random start RN between 1 and $k$
3. Select population elements: RN, RN+k, RN+2k, ..., RN+(n-1)k

*   Here we need systematic sampling for the PSUs, but first we need to accumulate the sizes of the clusters and each cluster is in a list with an associated cumulative size. We don't need to know every element, just the size.
    *   We will need a variance estimation model, because system sampling is not variable.
    *   Starting values have to fall between the threshold, in this case 1080. Selection probability is $1/k$.
    *   After we select a cluster, we select in this case 10 elements. For cluster 4 of element size 554, starting value between 1 and 554, eg 200, next $200 + 554$ for the second element, than $200+554+554$ . . .to get the 200, 754, until we have 10 elements, but we need to chop off the last digit $55.4 =$
    *   the selection probability is $10/554$ - .0177 because we need 10 elements in a cluster of 554, the inverse of the selection probability is a fraction $1 / (10/554) = 55.4$. If our random start is 200, to select the next element we take $200 + 55$
        *   here we start at id =20 (because we chop off the last digit), second id is 75 ($20 + (54.5)$)V, next is 129 ($20 + (54.5*2)$), iterate up to m_i.
*   Sometimes we don't know the exact count of elements, M_i in ecah cluster N_i
    *   We may know the population measures approximates the number of units in each cluster,
        *   Measure of Size MOS_i
            *   which we use PpeS, probabilities proportionate to estimated sample, we use the approximate error to be the cluster size.
            *   We over sample large clusters relative to small
            *   subsample element rate m\*/MOS_i where m\* is the actual number of second stage units select is unknown which is a target sample size. Ex, if we target 10 elements in a cluster, we may end up with more or less.
*   Stratification of PpeS
    *   independent sampling across strata

<!-- page 12 -->

* we just do what we did before within each strata, but we want the select rate to be the same across strata.
    * When we calculate the zone size for each starta. Do the selection independently
    * how to select elements within each cluster in each strata, think of proportionate allocation. Think of budget. For sampling project, proportionate allocation for how to sample elements within clusters for 9 stratum.
    * Slide 63 lecture 8,
* Oversize units, they make up their own strata
  * self-representing units (SRU), but how do you estimate variance,
  * sampling rate applied within cluster. First stage selection is always 1.
* For undersized clusters, $\text{MOS}_{hi} < m_h^*$ implying sampling within cluster at rate $> 1$.
  * all elements must be selected
    * can link undersized units to form linked units
      * creates clusters with greater heterogeity
      * area sampling, link geographically units if close to each other.
      * We can link before selection or after selection.
        * Identify selected unti, If selected unit and next on list are of sufficient size, stop.
        * If neither are selected, need to do linking
          * cumulate backwards until a linked unit of minimum sample is sufficient.

HW4, what is the goal of the survey and what is the target population? What is the sampling design in detail, what is the element the final participant.
Due March 17 submit in piazza. Write up, concise.

Describe the main study aims of the American Community Survey, target population, sampling design and selection processes of the following surveys.

**Study Aims**
The <u>American Community Survey (ACS)</u> is invaluable to the US statistical infrastructure, designed to provide a continuous and comprehensive view of the nation's socioeconomic landscape. Its primary aim is to equip policymakers, businesses, and community leaders with the data necessary for informed decision-making. The ACS achieves this by collecting detailed information on housing characteristics, economic conditions, health insurance coverage, demographics, education, employment, and poverty, among other crucial social indicators. In essence, it serves as a vital tool for resource allocation, policy formulation, and local planning, filling the information gap between decennial censuses. Currently, funding for the ACS is under attack by the radical DOGE group which could have a negative impact on how resources are distributed in the US.

**Target Population**
The ACS targets the resident population of the United States, sampling approximately 3.5 million addresses annually. This includes not only traditional households but also group quarters like college dormitories, prisons, and military barracks. The survey produces annual and five-year estimates for a wide range of geographic areas, from national and state levels down to cities, counties, census tracts, and even specific group quarters. This granular data allows for detailed community profiling and facilitates comparisons across different geographic regions and over time. However, of note, reliable inferences for small areas are generally limited to those with populations of 65,000 or more.

**Sampling Design and Selection**

<!-- page 13 -->

The Census Bureaus maintains the Master Address File (MAF) of known housing units (HU) and group quarters (GQ) in the US. Since ACS is based on a sample of people, there is sampling error associated which is a function of sample size. This serves as a main list of addresses to produce the sampling frame for the ACS. A two stage approach is used to select using HUs and GQs for each of the 3,143 counties in the US and Puerto Rico. Additionally, there is a random selection process of nonresponse addresses for CAPI. Overall, there are three modes used; internet surveys, mail in surveys, and personal visits to the HUs.

The first phase of the design includes a two-stage approach where in the first stage it assigns new addresses, using a SRS design, to one of five subframes while the second stage selects the sample from the selected subframe. This phase is done twice during the months of September and March of the following year. In the first phase, each block is assigned to one of sixteen stratums known as sampling entities which include, counties, school districts, native and tribal lands, places with active governments, and Census designated places (Hawaii only). There is an adjustment made to compensate for costs to account for the proportion of the sample that is eligible.

The second phase is the CAPI selection, were sampling cases without a complete survey or nonresponse are eligible for the CAPI. The rate of sampling for this stage is equal to the sampling rate divided by .20 to account for unequal distributions of HUs at the county level.

To prepare for midterm,
prepare a table for notes of sampling techniques, implementation, and projections

table should sampling technique, what is the point estimate for the population mean, sampling variance (element variance / sample size),

**March 12, 2025 Sampling with unequal probabilities**

* HW3 review
  * You can carry the mean, element variance, and roh which are portable. Sample size changes.
  * For c, ratio $n/(n-1)$ element variance is $p(1-p)/n-1$ where is $n$ is total sample size.
  * Sampling variance is capturing the sampling error using the same design, analytic vs model based provide different standard errors.

* PPS reduces the variation in clusters.
* Week 10 assignment
  * If you have $m$ $n$, $N$, we have the sampling fraction, $1-f$, which $f$ is $m*n/M*N$.
  * To achieve epsem across stratum, what is the required subsample, using the proportion allocation.
    * How to do the linking process based on enrollment. Be careful about over size and undersize.
  * What is the 2nd stage sampling fraction after linking.

<!-- page 14 -->

* Lecture notes

$$
\psi_i = P(\text{select unit } i \text{ on the first draw}),
$$

$$
\pi_i = P(\text{unit } i \text{ in sample}) = \sum_{S: i \in \mathcal{S}} P(S)
$$

| | | | |
| :--- | :---: | :---: | :--- |
| **SRS** | $\bar{y} = p = \frac{y}{n}$ | $(1 - f) * \frac{s^2}{n}$ | $1$ |
| **Stratified sampling** <br> **Proportionate allocation** | $W_h = \frac{N_h}{N}$ <br> $\sum_h \bar{y}_h W_h$ | $\sum_h W_h^2 (1 - f_h) * \frac{s_h^2}{n_h}$ | $\frac{var(\bar{y}_w)}{var(\bar{y})}$ |
| **Cluster sampling (equal-size)** | $\sum_a \sum_b \frac{y_{i,j}}{ab}$ | $(1 - f) * \frac{s_b^2}{a}$ | $1 + (b - 1) * \text{roh}$ |
| **Cluster sampling (unequal-size)** | $\sum_a \sum_{b_i} \frac{y_{i,j}}{ab}$ <br> RATIO $r = \frac{y}{x}$ | $var(r) \approx \frac{1}{x^2} [var(y) + r^2 var(x) - 2 * r * cov(y, x)]$ | $1 + (\bar{b} - 1) * \text{roh}$ |
| **Stratified cluster sampling (unequal-size)** | $r = \sum_H \sum_{a_h} \sum_{b_i} \frac{w_{hij} y_{h,i,j}}{w_{hij} x_{h,i,j}}$ | $var(r) \approx \frac{1}{x^2} \left[ \sum_h var(y_h) + r^2 \sum var(x_h) - 2 * r \right.$ | $1 + (\bar{b} - 1) * \text{roh}$ |

* Sampling w/o replacement are affected by other units.

### March 19 2025 complex surveys

* complex weight design features.
  * If weights are correlated with outcome, they are informative weights. Weighted estimates will be higher than unweighted.
    * No correlation, no difference in weighted or unweighted estimates. We will see inflation of varinace.
    * If negative correlation, weighted estimate will be lower than non weighted.
  * If everybody has an equal chance of being selected, we do not need to estimate a weighted ratio mean, which is biased but reduces variance.
  * If weights are well constructed, it should give us the population size. Some surveys have weights assigned to population, sample, or something else. The relative representation of weights is useful for the sample mean, but not for the population total.
* R code: mstage() two stratified two stage cluster sample to create weights.

<!-- page 15 -->

* Effective sample size (ESS) – size of an SRS that has the same variance for the estimated mean as the complex sampling design.
    * For convenience samples, example covid, for 1min observations, ESS is size 10. More data, does not mean more information.
* Variance is the same as cluster variances
    * r code: svydesign() pass psu, strata and weights for the data.
    * Use of weights can increase sampling variance of weighted estimate.
    * $1+L$ method, provides potential increase in variance.
        * $L$ loss of precision due to weighting = $\text{CV}^2(\text{weights})$
        $1+L$ = like DEFF, and compute ESS.
        * There is a key exception, this assumes weights are independent, no correlation between weights and variables.
        * However, $1+L$ gives us the upper bound, and $n_{\text{ess}}$ gives us the lower bound.
        * Rob Little advises we should not use the variances, but should use the MSE.
* Multi-stage area sampling

The American Community Survey (ACS) is a crucial tool for understanding the U.S. socioeconomic landscape, and it provides data to inform decision-making across various sectors on topics such as housing characteristics, poverty, health insurance status, and many more.

ACS targets the entire US population (and Puerto Rico) through a sample of approximately 3.5 million addresses annually, including both households and group quarters (prisons, elderly homes, baracks).

The ACS produces detailed yearly and five year estimates for diverse geographic areas. It employs a complex, two-phase sampling design, using the Master Address File (MAF) and incorporating stratification and adjustments to ensure representative data, collected through internet, mail, and in-person surveys.

In the first phase, within counties census blocks are assigned to 1 of 16 strata defined by measures of size and anticipated response.

Sampling fractions are higher for small areas to get a more precise estimates.

In the second phase, CAPI is used for sampling cases without complete surveys or nonresponse.

* Midterm review,
    * Why not SRS, expansive and sometimes no master list available.
    * Cluster sampling reduces cost.
    * How to decide sample size with fixed cost? M opt, sqrt

$$
m_{opt} = \sqrt{\frac{c_n}{c_m} \frac{1 - roh}{roh}}
$$

<!-- page 16 -->

* four allocation plans
  * proportionate, neyman, optimum, equal.
  * Neyman, we need weight and element variances
  * optimum allocation we need
* systematic sampling – if trying to maintain epsem, we get sampling intervals that are not integer. Fractional interval.
* Stratified cluster sampling, PPS/PpeS Final sample size become random variable.
* When evaluating design, use the DEFF to compare.
  * Variance – what is portable, ROH, or proportion is $p(1-p)$ for element variance.
* Frame problems, duplicates, blanks, coverage errors
  * proper use of available good materials
  * no available frames (non-probability)
* Try to minimize variance per unit cost.
* Point estiamates
  * goal, unbiased estimate of the population mean
  * use sample mean if epsem achieved
* Variance estimation, keep in mind finite population correction, ignore if large $N/(n-1)$.
* For clustering sampling we use PSU,
* stratified we don’t sample stratas
* systematic sampling, check of order of list, if ordered use strata. If total sample size, use successive differences.
* Taylor series linerrization, this approximation must be tested using the $\text{CV}(x)$.
* Keep in mind of DF when constructing CI.
* Week 11 group project
  * sort by grade level. On canvas get classroom roster. Use 242 to calculate the sampling rate. If the schools are linked, combine them. Based on this sample, what is the sample size. Get second stage selection rate. Ex. 200 sample size, we need the sampling rate.
  * How to select students from select schools. Provide the selection technique such as random start, and select cases in detail.
  * Our design and sampling process should be finalized.

April 2, 2025

* Midterm exam
  * 2.b. should have been $1$ to $k$
  * 3.b. $N*M*p$ $379000 * p$
  * d. P66 lec 5.
    * 1 function of $m$
    * 2
    * 3 the largest number of clusters more costly
  * e. wrong roh
  * f. about projection, carry roh forward, after DEF, effective sample size 8000 (lec ?) calculate nominal sample size / DEF

<!-- page 17 -->

* g. our nominal sample size is 8000, with m_opt, we can get var_srs , and multiply with var_cluster
* 4. neyman allocation, proportion to the product of the weight with its standard deviation. Estimate of proportion wh*ph aggregate across 4 strata and get SE of strat sampling
* 6. select 2 hospitals, $481/2$ sampling interval $= 240.5$. The random start is incorrect, move $k$ to 2405 and random start 0421 makes sense, move cumulative counts by one digit, so 4 is 40, and undersized instead of 50 is 500. Select hospital 4 and ?
* b. provide sampling fraction for first stage
* c. we need second stage selection rate

no curve

send back corrections by Friday night. Submit in Canvas. Submit correct new file with answers. We cannot get full credit, but based on quality of answer, if full correction, we can get suppose we get 75, and we do correction of the 25, we get $p*(1-p)*$ score median 71,

**PPeS sampling of clusters implementation: P45, P52, P57, P64, Lec8**

**fractional intervals**

**Linking, P89-92, Lec8**

b. Write the first-stage sampling fraction (or, the probability of selection) for the first (possibly linked) unit included in the systematic PPeS sample. [2 points]

* presentation
  * prepare slides by April 16
  * report due on the 23$^{\text{rd}}$.
* Week 13, variance estimation. Develop estimation plan for strategy. Describe the plan and estimation that reflect our design strategies. Develop a sampling error calculation model (SECU). How would we construct CI for the quantities we are interested, be

<!-- page 18 -->

careful with df, depends on design. If design is EPSEM, no weights, if no, use weights. The formula would be weighted estimates.
  * Describe strategies in the oral presentation.

* Variance estimation:
  * In practice, many surveys are stratified multistage sampling with probabilities.
  * Most of the time we are interested beyond means or proportions such as quantiles.
    * With model based estimate, with variance is different with respect to the model rather than sampling.
    * In stratas with a large cluster, there is no variance.
    * Automated cluster, is the result of the random individuals within HUs, within SSU, for a PSU.
  * Sampling error computing units (SECU)
    * we can use taylor series linearization to estimate nonlinear estimators.
    * Variance estimation is based on ultimate clusters,
    * SECU good representation of units, and we form them by collapsing strata and combining them.
      * Collapse – remove boundary,
        * when we ignore the strata design we over estimate the bias. Stratification reduces sampling variance. But if we collapse strata, we bring back strata design and over estimate sampling variance. It is a conservative choice to overestimate sampling variance.
        * In systematic sampling we could not estimate variance, but if we collapse strata to form a pseudo strata we can estimate it.
        * We collapse from neighboring strata.
      * Combining – new pseudo PSU (SECU) combining does not produce sampling bias, but reduces the number of SECU for variance estimation. IF we have cluster and strata, the df is the difference in the number of clusters and strata, the DF will affect the variance estimation. With small Df, variance of the sampling variance increase.
        * For project when we construct pseudo strata, what are the df, are they noisy? This can apply for more than two selections.
      * Random groups method – similar to combining strata. Used to build SECU selected with certainty. For instance, clusters that are over size, we have to treat as own strata. Variance estimates not biased.
      * Taylor series if CV is smaller than .2, it is appropriate.
        * But will break down when estimators are not continously differentiable
        * Will break when estimator cannot be simplified to functions of sample totals.
        * Gives us conservative estimation.
      * When Taylor breaks down, we can use replication methods.
        * Bootstarping allows us to create replications of the data and estimate a variance.
        * JRR Jacknife and other methods draw samples from the original sample with replacement.
          * Jacknife, multipurpose

<!-- page 19 -->

*   *   *   jacknife repeated replication, sort of like LOO, drop one psu, and reweigh. Than you use the remaining data to estimate the variance., need to adjust $n\_h / (n\_h - 1)$ to reflect the leaving one out.
    *   BRR Balance repeated replications, we can form half samples from two PSUs by randomly choosing one of the two.
        *   BRR variance estimator covariance can be canceled because samples are not independent when replicating. This are called orthogonal replicate.
    *   Bootstrap sampling with replacement
        *   Rao and Wu bootstrap. Select $n\_h - 1$, do this for each strata. If 3 PSUs in a strata, sample 2 w/ replacement.
            *   The larger bootstrap replicates more computation.
    *   For each replication method, we need to adjust weights, and handle non-response weighting, and poststratification weighting.
        *   In the end, we may want to readjust non-response in the replication.
*   Summary
    *   Taylor method is computationally cheap, replication methods are computationally expensive.
    *   When choosing which method, balance criteria.
    *   When paired selection, any method can be used.
    *   When more than three clusters, potential variance estimator methods can be use Taylor, not BRR when more than two PSUs. Most SECU models are paired in selection.
    *   SE should reflect complex sampling features. If reporting many estimates, report generalized estimation based on estimate alone.
        *   If we had 100 variance estimates, we model all of them and release the generalized SE, and users can plug in point estimate and can get SE for the estimate.
        *   Generalized DEF, specific to each model, but we still get many of them. We can report the average DEF, and no need to release complex sampling features.
        *   **Note.** We have three quantities of interest in our project, how do we choose design precision for all three, can use the average DEF, and based on cost, can choose optimal.
    *   With complex design, most statistics will be nonlinear functions of the observed data.
    *   Collpase and combine stata to construct SECU
    *   Taylor and replicated methods for variance estimation
        *   Taylor, may not be appropriate
        *   Replication methods: BRR, JRR, Bootstrap.

<!-- page 20 -->

April 9th 2025, nonresponse

* Potential problem for school based frame example.
  * 3rd and 4th grade students may not all be 10. Will the school roster cover the target population. Some kids will be home schooled.
  * Any fancy techniques won't fix that there may not be complete coverage.
  * Key assumption for multistage selections
    * there can be singleton problems, cannot estimate variance.
    * Assume selection is one stage, select all elements within cluster. Clusters are now PSU, ultimate cluster, now we assume cluster with replacement.
* Nonresponse types
  * unit – the case refused or was not selected.
    * Can be due to cluster refusal (school did not want to participate)
      * we address this with weights.
  * Item nonresponse
    * fail to observe a question response
      * failure of the response processes
    * can impute.
* Response rates
  * ratio of units that responded to the number of eligible. Pg 341 of Lohr book
  * RR should be by mode
* sampling weights are pre determined, but they have to adjusted for people that refused. After data collection, the sample is different from the sample we planned to take, weights should be adjusted again, these are called weighted sampling weights. Some favor weighted, others unweighted response weights.
  * Two approaches to nonresponse, deterministic and stochastic (everyone has a probability of being selected). Called response propensity score.
  * The probability of responding is a random variable.
  * Nonresponse bias (those that did not respond are different from respondents) ~ response rates and survey variables.
    * Nonresponse if not adjusted, the estimate is unweighted, raw, unadjusted. We need to adjust to reduce potential non-response bias.
    * Deterministic model, two parts in equation non response rate * difference in means (known as bias) between respondents and non-respondents.
    * Stochastic model, bias estimate for respondents = covariance of response propensity phi and response divided by response propensity phi.
* Missing data mechanism
  * mcar – SRS of full population, can use simple imputation. Strong assumption that it is missing completely at random.
  * Mar – most common, there is a reason that the item is missing based on an auxiliary variable.
  * Mnar – responds depend on other values, skip patterns for instance.
  * Auxiliary variables must be predictive.
* Weighting
  * sample based after collection
    * inverse response rates weights

<!-- page 21 -->

* IPW = inverse propensity weights
  * population based weighting
    * needs information from target populations
      * poststratification, tabular adjustment
      * raking, marginal adjustment
  * in practice, weighting classes (pg 324) are common, grouping by say gender, age, and use auxiliary variables must be predictive for respondents and nonrespondents response propensity.
    * Constructing weighting classes (pg 326)
      * variables to use for weighting class
        * demographics, sometimes not enough.
        * Propensity score models look for predictors, but may not be related to outcome.
        * For multipurpose surveys, there will be many weighting class.
  * Response propensity weighting, like a logistic regression, $P(R\_i = 1)$ The inverse is the weight. The potential problem the probability can be small and inverse can be large meaning more variability. This is also a model, there is a standard error associated.
    * Based on response propensity we can group people.
* Poststratification
  * make full distribution of respondents look like full distribution in the population. The poststrata weight $= w\_hi = (N\_h/N) * (r\_h/r)$, $r\_h$ can be sum of weights in stratum $h$.
  * poststrat reduces bias
* raking – make the marginal distribution of respondents on characteristics look like marginal distribution of characteristics in the population.
  * We can get this from another survey and get marginal, but maybe not joint distribution.
  * Iterative proportional fitting
    * in surveypackage use calibration. There are other packages, rake() from survey
* To construct weights look at lecture 12 slide 19. Final weights will account for unequal probabilities of selection, non-response, post strata
* imputation
  * goal is to recover a potential value not the correct value.

Course summary
* implementation – SRS, cluster, stratified, unequal.
  * How do we select it, analyze it, select future design?
  * DEFF, remember to compute deff, ratio between complex and SRS sampling variances with sample size.
    * Only for clustering can it be simplified, only have to look at roh.
* What number do we need for SRS variance to calculate size.
  * For continues you need mean, element variance
  * if proportion, just $p$
  * need to know desired sample size.

<!-- page 22 -->

- DEFF get it from two ratios. We need to know m, DEF is divided by m-1.
- To get complex sample size, the effective sample size.
