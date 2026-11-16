---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module3_Lecture2_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "Applications of Statistical Modeling:"
original: "applications_stats_modeling_SURV617/lectures/Module3_Lecture2_Fall2025.pdf"
pages: 46
sha256: "c63fc00d570be5b62d73165f461efc5f0c565712fc106d8685f01feac5e1c741"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:43"
---

<!-- page 1 -->

# Applications of Statistical Modeling:
## Module #3, Lecture #2

### Case Study: Prediction of Wave 2 Response Propensity in the NESARC

Instructor: Brady T. West

Email: [email]

1

<!-- page 2 -->

# Lecture Overview

- Today, we will review the basic concepts, advantages and disadvantages of tree-based methods
- Then we will consider an in-depth analysis of the NESARC data, using a variety of methods to predict response in Wave 2, or “failure to drop out” (conditional on response in Wave 1)
- Finally, we will introduce some applications of tree-based methods in survey research

2

<!-- page 3 -->

# Review: Creating a decision tree from training data

| | **categorical** | **categorical** | **continuous** | **class** |
| :--- | :--- | :--- | :--- | :--- |
| ***Tid*** | **Refund** | **Marital Status** | **Taxable Income** | **Cheat** |
| 1 | Yes | Single | 125K | **No** |
| 2 | No | Married | 100K | **No** |
| 3 | No | Single | 70K | **No** |
| 4 | Yes | Married | 120K | **No** |
| 5 | No | Divorced | 95K | **Yes** |
| 6 | No | Married | 60K | **No** |
| 7 | Yes | Divorced | 220K | **No** |
| 8 | No | Single | 85K | **Yes** |
| 9 | No | Married | 75K | **No** |
| 10 | No | Single | 90K | **Yes** |

**Training Data**

***Splitting Attributes***

* **Refund**
  * Yes $\rightarrow$ **NO**
  * No $\rightarrow$ **MarSt**
    * Single, Divorced $\rightarrow$ **TaxInc**
      * < 80K $\rightarrow$ **NO**
      * \> 80K $\rightarrow$ **YES**
    * Married $\rightarrow$ **NO**

**Model: Decision Tree**

<!-- page 4 -->

# Review: Applying the model to test data

### Test Data

| Refund | Marital Status | Taxable Income | Cheat |
| :--- | :--- | :--- | :--- |
| No | Married | 80K | **?** |

* **Refund**
  * Yes $\rightarrow$ **NO**
  * No $\rightarrow$ **MarSt**
    * Single, Divorced $\rightarrow$ **TaxInc**
      * $< 80\text{K} \rightarrow$ **NO**
      * $> 80\text{K} \rightarrow$ **YES**
    * Married $\rightarrow$ **NO**

<!-- page 5 -->

# Decisions and Performance

* Determine how to construct a given tree
  * Choose the next best split: impurity / deviance measures
    * Classification trees: deviance/entropy, Gini index, misclassification error
    * Regression trees: Mean Squared Errors
  * Minimize the error rate: apparent/true error rate
* Cross validation to choose control parameters
  * Repeatedly hold out one group for testing and the rest (training) to construct the tree

5

<!-- page 6 -->

# Performance: Confusion matrix

| $n=150$ | Predicted: No | Predicted: Yes |
| :--- | :--- | :--- |
| Actual: No | $TN=25$ | $FP=15$ |
| Actual: Yes | $FN=10$ | $TP=100$ |

Accuracy: $(100+25)/150= 83\%$

Misclassification rate: $(15+10)/150=17\%$

True Positive (TP) rate/Sensitivity: $100/110=91\%$

False Positive (FP) rate: $15/40=38\%$

Specificity ($1-\text{FP rate}$): $25/40=63\%$

Precision: $100/115=87\%$

Prevalence: $110/150=73\%$

6

<!-- page 7 -->

# Performance: Receiver Operating Characteristic (ROC) curve

100%

C
B
A

p(True Positives are found)
or
***Sensitivity***

0
100%

p(False Positives are found)
or
**1-*Specificity***

7

<!-- page 8 -->

# Advantages of Tree-Based Methods

* Inexpensive to construct
* Extremely fast at classifying unknown records
* Easy to interpret for small-sized trees
* Easily handles mixed data
* Scalable
* Accuracy is comparable to other classification techniques for many simple data sets

8

<!-- page 9 -->

# Disadvantages of Tree-Based Methods

* Variance in prediction
* **Overfitting** results in decision trees that are more complex than necessary and highly sensitive to noise in the training set
* Variable selection is biased in favor of variables with certain characteristics, even if these variables are no more informative than their competitors. For example, variables with many categories and numeric variables or, even more unintuitively, variables with many missing values are artificially preferred

9

<!-- page 10 -->

# Random Forests

* Random Forests with an explicit dependent variable are often referred to as supervised learning methodologies
* Random Forests correct a decision tree’s habit of overfitting
* As discussed in **Lecture #1**, Random Forests fall under a class of learners called “Ensemble Methods”
* For what problems can you apply this method?
  - Regression
  - Classification
  - Survival

10

<!-- page 11 -->

# Random Forests: Advantages and Disadvantages

* Advantages:
  - Can handle predictors that are continuous, categorical, skewed and sparse data
  - Aptly suited for the “large p, small n” scenario
  - Very effective for estimating outcomes that are a complex functions of predictors with many interactions or possibly non-linear functions of the parameters

* Disadvantages
  - Random Forests can be **extremely computationally intensive**

11

<!-- page 12 -->

# Random Forests: Additional Issues (1)

* For situations where the number of predictors is greater than the number of cases ($n \ll p$), *mtry* values should be increased beyond the defaults
* Random Forests don’t use **surrogates** like trees (for each split, observations where the split variable is missing are split based on the best correlate, or **surrogate variable**), so missing data must be dealt with:
  – Unique categories of categorical variables
  – Use imputed data sets

12

<!-- page 13 -->

# Random Forests: Additional Issues (2)

* All classification techniques may suffer from severe class imbalance
  – Positive class < 5 or 1%
  – Example: Rare disease
* Common techniques to approach the issue include over (under) sampling the rare (prominent) class
  – Even Random sampling can improve performance
* Others may involve simulated/synthetic data
* Such techniques have ties to survey weighting

13

<!-- page 14 -->

# Summary

* Machine learning techniques generally shift to a more predictive focus than traditional statistical methods:
  - Possible sacrifice in interpretation
  - Might be better suited to larger data
* Many techniques may be viable for a particular problem, with great potential but also caution
* Very active research with recent developments on boosting and additive trees, regularized regression models (e.g., LASSO), neural networks, support vector machines, and deep learning algorithms
* Lots of reading and computational resources
* Tools like this are very useful to have in your research toolbox!

14

<!-- page 15 -->

# Case Study: Response Propensity Prediction in the NESARC

* Today, we consider an in-depth analysis of the NESARC data, using a variety of methods to predict response in Wave 2, or “failure to drop out” (conditional on response in Wave 1)
* Begin with initial examinations of relationships
* Proceed with classification trees and random forests

15

<!-- page 16 -->

# NESARC Data Set: W1RESP (1)

* Available in SAS and Stata formats on Canvas
* Number of cases from Wave 1: 43,093
* Dependent variable: W2RESP (indicator of responding in Wave 2)
* 80.41% unweighted response rate in Wave 2 (not a lot of attrition...but is there bias?)
* Key Wave 2 outcome: Any drug use disorder in the past year (PY_ANYDUDA)

16

<!-- page 17 -->

# NESARC Data Set: W1RESP (2)

* We have a variety of auxiliary information from Wave 1 that we can use to predict response in Wave 2
* **NOTE:** We don’t have any paradata, which have been shown repeatedly to be the best predictors of response in these settings, because we are working with the <u>public-use</u> data file
* We also have the final Wave 1 weights, accounting for unequal probability of selection, nonresponse, and post-stratification at Wave 1 (WEIGHT)

17

<!-- page 18 -->

# NESARC Data Set: W1RESP (3)

* See the Wave 1 codebook on Canvas for all value labels!
* Wave 1 Socio-Demographics:
  – Race/Ethnicity (ETHRACE2A)
  – Region of U.S. (REGION)
  – Age (AGE)
  – Sex (SEX; 1 = Male, 2 = Female)

18

<!-- page 19 -->

# NESARC Data Set: W1RESP (4)

* Survey variables from Wave 1:
  - Current drug use status (1 = user, 2 = ex-user, 3 = never-user); DGSTATUS
  - Ever had major depressive episode in lifetime (MAJORDEPLIFE)
  - Any past-year nonmedical use of prescription drugs (ANYSEDY – ANYNMPDY)
  - Alcohol abuse, alcohol dependence, and heavy drinking in past year (ALC_ABUSE – HD)

19

<!-- page 20 -->

# Modeling Objective

* Can we develop a strong predictive model of response in Wave 2, using the available Wave 1 variables, with the purpose of adjusting the Wave 1 weights for attrition in mind?

20

<!-- page 21 -->

# Preliminary Analysis (1)

* With this objective in mind for binary outcomes, it's always a good idea to start with a simple logistic regression model
* In R (could also be done in SAS, Stata, etc.):

```r
library(rms)
lrm(w2resp ~ ethrace2a_num + region + sex + age +
  weight + dgstatu + majordeplife + anysedy + ... +
  hd, data = w1resp) # could also use glm()
```

* Important: all categorical predictors were defined as factor variables first!

21

<!-- page 22 -->

# Preliminary Analysis (2)

* Significant predictors of response ($p \le 0.001$):
  – ETHRACE2A ($1 > 3 > 2 > 5 > 4$)
  – REGION ($2 > 4 > 3 > 1$)
  – SEX ($\text{F} > \text{M}$)
  – AGE ($\text{OLDER} < \text{YOUNGER}$)
  – WEIGHT ($\text{HIGHER} > \text{LOWER}$)
  – DGSTATUS ($2 > 3 > 1$)
  – MAJORDEPLIFE ($\text{Y} > \text{N}$)
  – ALC_DEPEND ($\text{Y} < \text{N}$)

22

<!-- page 23 -->

# Preliminary Analysis (3)

* Are the large number of significant predictors simply due to the large sample size?
* How large are the predictive effects?
* Model pseudo R-squared: **only 0.024**!
* We therefore have some initial concern about the ability of these predictors to predict response propensity in Wave 2 (80.4% RR!)
* Odds ratios are not substantial...
* Any interactions?

23

<!-- page 24 -->

# Preliminary Analysis (4)

* This preliminary examination of the relationships of auxiliary variables with response propensity, either through full models or bivariate associations, is important
* We can gain an initial understanding of why some classification trees may not be effective (or why some tree solutions may seem trivial, with only one node!)
* We also get a sense of important predictors

24

<!-- page 25 -->

# Building a Classification Tree (1)

* We start by building a single conditional inference tree
* Here is the R code to first import the data set from Stata, and then construct the tree:

```r
library(foreign) # could also use haven
library(partykit)
w1resp <- read.dta("X:\\..\\w1resp.dta") # one option...
resp.tree <- ctree(factor(w2resp) ~ weight + age +
  factor(ethrace2a) + factor(region) + factor(sex) +
  factor(dgstatus) + majordeplife + anysedy + anytrqy +
  anyopiy + anystmy + alc_abuse + alc_depend + hd, data =
  w1resp) # NOTE: no control argument
print(resp.tree)
```

25

<!-- page 26 -->

# A Large Tree!

* We see a huge tree (26 terminal nodes!):

```r
Fitted party:
[1] root
|   [2] factor(ethrace2a) in 1, 2, 3
|   |   [3] age <= 75
|   |   |   [4] factor(sex) in 1
|   |   |   |   [5] factor(ethrace2a) in 1
|   |   |   |   |   [6] weight <= 5215.84863: 1 (n = 3615, err = 20.7%)
|   |   |   |   |   [7] weight > 5215.84863
|   |   |   |   |   |   [8] factor(dgstatus) in 1, 3
|   |   |   |   |   |   |   [9] factor(region) in 1, 2, 4: 1 (n = 3309, err = 14.3%)
|   |   |   |   |   |   |   [10] factor(region) in 3: 1 (n = 1649, err = 18.4%)
|   |   |   |   |   |   [11] factor(dgstatus) in 2: 1 (n = 1372, err = 10.9%)
|   |   |   |   [12] factor(ethrace2a) in 2, 3
|   |   |   |   |   [13] factor(dgstatus) in 1, 3
|   |   |   |   |   |   [14] age <= 29: 1 (n = 574, err = 29.4%)
|   |   |   |   |   |   [15] age > 29: 1 (n = 2015, err = 22.1%)
|   |   |   |   |   [16] factor(dgstatus) in 2: 1 (n = 591, err = 17.8%)
|   |   |   [17] factor(sex) in 2
|   |   |   |   [18] factor(dgstatus) in 1, 3
|   |   |   |   |   [19] factor(region) in 1, 3, 4
|   |   |   |   |   |   [20] majordeplife <= 0: 1 (n = 8660, err = 17.3%)
|   |   |   |   |   |   [21] majordeplife > 0
|   |   |   |   |   |   |   [22] factor(ethrace2a) in 1, 3
|   |   |   |   |   |   |   |   [23] weight <= 4019.71387: 1 (n = 802, err = 15.1%)
```

26

<!-- page 27 -->

# A Large Tree! (cont'd)

```r
| | [32] age > 75
| | | [33] age <= 86
| | | | [34] age <= 79: 1 (n = 1199, err = 28.2%)
| | | | [35] age > 79: 1 (n = 1414, err = 35.8%)
| | | [36] age > 86
| | | | [37] age <= 91: 0 (n = 434, err = 49.5%)
| | | | [38] age > 91: 0 (n = 134, err = 27.6%)
| [39] factor(ethrace2a) in 4, 5
| | [40] factor(sex) in 1
| | | [41] factor(region) in 1, 3
| | | | [42] age <= 36: 1 (n = 980, err = 36.9%)
| | | | [43] age > 36: 1 (n = 1131, err = 24.8%)
| | | [44] factor(region) in 2, 4: 1 (n = 2207, err = 24.1%)
| | [45] factor(sex) in 2
| | | [46] factor(region) in 1, 2, 3
| | | | [47] weight <= 3694.14209
| | | | | [48] factor(ethrace2a) in 4: 1 (n = 86, err = 36.0%)
| | | | | [49] factor(ethrace2a) in 5: 1 (n = 2284, err = 19.9%)
| | | | [50] weight > 3694.14209: 1 (n = 815, err = 31.8%)
| | | [51] factor(region) in 4: 1 (n = 2137, err = 18.7%)

Number of inner nodes:   25
Number of terminal nodes: 26
```

27

<!-- page 28 -->

# Building a Classification Tree (2)

* We define a new set of control values, with 100 cases required in a node for a split to happen, and a minimum 100 cases per terminal node

```r
n.control <- ctree_control(minsplit=100, minbucket=100)

resp.tree <- ctree(factor(w2resp) ~ weight + age +
   factor(ethrace2a) + factor(region) + factor(sex) +
   factor(dgstatus) + majordeplife + anysedy + anytrqy + anyopiy +
   anystmy + alc_abuse + alc_depend + hd, data = w1resp, control =
   n.control)
```

**We still end up with 25 terminal nodes! There definitely appear to be some powerful interactions in predicting response propensity. We therefore stick with the first tree that we constructed (using the defaults).**

28

<!-- page 29 -->

# Building a Classification Tree (3)

* We examine the solution, and plot the tree. Note that in many interactions, the survey weight matters!

```r
print(resp.tree)
plot(resp.tree)
```

29

<!-- page 30 -->

# Building a Classification Tree (4)

* Let’s try and get an estimate of the **true error rate**. How does this tree perform given training (80%) and test (20%) data?

```r
set.seed(41279)
smp_size = floor(0.8 * nrow(w1resp))
train_ind = sample(seq_len(nrow(w1resp)), size = smp_size)
train = w1resp[train_ind, ]
val = w1resp[-train_ind, -c(17,18,19)] # drop W2 vars w/NA for NR
val = val[complete.cases(val), ]

ttree <- ctree(factor(w2resp) ~ weight + age + factor(ethrace2a) +
   factor(region) + factor(sex) + factor(dgstatus) + majordeplife
   + anysedy + anytrqy + anyopiy + anystmy + alc_abuse +
   alc_depend + hd, data = train)
```

**`NOTE: Still 26 terminal nodes! We see essentially the same evidence based on an 80% random subsample.`**

30

<!-- page 31 -->

# Building a Classification Tree (5)

* We now compute predictions in the test data set:

```r
library(crossval)
val$pred <- predict(ttree, val[,-17]) # take out DV
cm <- confusionMatrix(factor(val$w2resp), factor(val$pred), negative="0")
# nonresponse is a negative

cm
  FP   TP   TN   FN 
1597 6867   58   57 

diagnosticErrors(cm)
 acc       sens       spec        ppv        npv        lor 
0.80720364 0.99176776 0.03504532 0.81131853 0.50434783 1.47599220 
```

**Everything looks great...except specificity. The ability to correctly predict nonresponse [TN / (FP + TN)] is poor. Still, 80% accuracy, but is this significantly better than just predicting 1 for everyone?**

31

<!-- page 32 -->

# Building Random Forests

* We now build a random forest with 20 trees and subsets of 5 vars
* Here is the R code using *randomForest (note that w2resp needs to be declared as a categorical factor variable first!)*:

```r
library(randomForest)
rfexample <- randomForest(
  w2resp ~  ETHRACE2A + REGION + SEX +
  AGE + WEIGHT + DGSTATUS + MAJORDEPLIFE + anysedy +
  anytrqy + anyopiy + anystmy +
  anynmpdy + alc_abuse + alc_depend + hd,
  data = w1resp,
  ntree = 20,
  mtry = 5,
  importance = TRUE,
  na.action = na.omit,
  replace = FALSE
)
```

32

<!-- page 33 -->

# OOB Performance Results

```r
plot(x = c(1:20),y = rfexample$err.rate[, 1],  xlab = "Number of Trees",
ylab = "Error") # Note 80% prediction accuracy...similar to tree!
lines(x = c(1:20), y = rfexample$err.rate[, 1], xlab = "Number of Trees",
ylab = "Error", col = 2, lty = 1,lwd = 2)
```

33

<!-- page 34 -->

# Variable Importance

**Variable Importance Random Forest**

AGE
ETHRACE2A
WEIGHT
REGION
SEX
DGSTATUS
hd
anynmpdy
alc_depend
MAJORDEPLIFE
anystmy
anytrqy
alc_abuse
anyopiy
anysedy

0 5 10 15 20 25

MeanDecreaseAccuracy

```r
varImpPlot(rfexample, type = 1, col = 4, sort = TRUE, n.var = 15, cex = 1.5, pch = 16)
```

**Similar to the variables that we saw in the tree on slide 29!**

34

<!-- page 35 -->

# Take-away Points

* In this case study, we identified strong predictors of Wave 2 response propensity in the NESARC
* For effective nonresponse adjustments, we need strong auxiliary correlates of key survey variables and response propensity; are the demographics predictive of key variables?
* The conditional inference tree picked up several interesting interactions, but our ability to predict **nonresponse** was still poor...and did we really do better than just predicting 1?
* Random forests had similar prediction accuracy (the single tree and the largest random forest had about 80% accuracy...worth the computation?)

35

<!-- page 36 -->

# Applications of Tree-based Methods in Survey Research

* The dependent variable could be the indicator variable for sample selection/response/inclusion, or the survey outcome variable
* Currently active research area, including aspects on:
  - Nonresponse adjustment/weighting
  - Accounting for complex sampling features
  - Selection of auxiliary variables
  - Missing data imputation
  - Informing responsive and adaptive designs

36

<!-- page 37 -->

# Accounting for Complex Sampling

* The contributed **rpms** package in R fits **regression trees** (not classification trees) to complex sample survey data, and can either:
  * Predict the mean in each terminal node, or
  * Fit a linear model in each terminal node

37

<!-- page 38 -->

# Selection of Post-strata Using a Regression Tree Estimator

* Auxiliary information related to the survey variable can potentially reduce estimate variability and increase estimation efficiency
* The auxiliary data often include categorical variables, often with a large number of categories and complex interactions
* McConville and Toth (2018) propose a post-stratification estimator where the post-strata are automatically selected by the regression tree

38

<!-- page 39 -->

# Missing Predictor Values in Trees

1. Listwise deletion
2. Impute missing values: median/mode plugin
3. For categorical predictors, make a new category for missing values
4. Construct **surrogate variables**
   * Use observed values to choose the primary predictor and primary split point
   * The surrogate is the predictor and corresponding split point that best mimics the split achieved by the primary split

39

<!-- page 40 -->

# Tree-based Multiple Imputation

* Recursive partitioning techniques are implemented in the multiple imputation by chained equations framework, e.g., Doove et al (2013) and Burgette and Reiter (2010)
* Tree-based imputation engines have the potential to handle complex modeling, including interactions and non-linear relationships, complex distributions without parametric assumptions or data transformations
* Combine with bootstrap or Bayesian bootstrap to propagate missing data uncertainty

40

<!-- page 41 -->

# Bayesian Additive Regression Trees

* A Bayesian approach to an ensemble of trees sums the contribution of sequential weak learners and uses a regularization prior (BART, Chipman et al. 2010)
* The Bayesian framework has a built-in complexity penalty, which means we no longer have to make empirical choices about regularization, maximum tree-depth and the plethora of other options we normally tune via cross-validation
* Use Bayesian Backfitting to do MCMC sampling from a general additive model's posterior distribution
* The approach provides an "out-of-the-box" set of defaults that are statistically robust, give best-in-class performance, and are resilient to changes in hyper-parameter choice
* BART outperforms all the others that were compared, on the 42 different data sets evaluated

41

<!-- page 42 -->

# Machine Learning Methods for Responsive and Adaptive Design

* In responsive survey designs, it is often useful to have an accurate classification of which sampled units are likely to respond to a survey and which are not.
* Within an online survey panel context, it might also be useful to know which respondents are likely to leave an item missing on a questionnaire and which respondents are not.
* Armed with these predicted classifications, researchers and practitioners can tailor the survey experience in an attempt to mitigate the negative consequences of nonresponse or item missingness.
* The prediction of nonresponse is desired in real time throughout the field period, and the predictors may include auxiliary variables known for all sampling units or paradata that are collected on all sampled units during an initial field period

42

<!-- page 43 -->

# References (1)

Burgette, L.F., Reiter, K.P. (2010). Multiple imputation for missing data via sequential regression trees. Amer. J. Epidemiol. 172, 1070–1076.

Buskirk, T. D. and Kolenikov, S. (2015). Finding respondents in the forest: A comparison of logistic regression and random forest models for response propensity weighting and stratification. Survey Methods: Insights from the Field. https://surveyinsights.org/?p=5108.

Judkins, D., Hao, H., Barrett, B., and Adhikari, P. (2005). Modeling and polishing of nonresponse propensity. Technical report, JSM Proceedings, Survey Research Methods Section. Alexandria, VA: American Statistical Association. 3159–3166

43

<!-- page 44 -->

# References (2)

Lohr, S., Hsu, V., and Montaquila, J. (2015). Using classification and regression trees to model survey nonresponse. JSM Proceedings, Survey Research Methods Section. Alexandria, VA: American Statistical Association. 2071–2085.

Phipps, P. and Toth, D. (2012). Analyzing establishment nonresponse using an interpretable regression tree model with linked administrative data. The Annals of Applied Statistics, 6(2):772–794

Chipman, H., George, E. and McCulloch, R. (2010). BART: Bayesian additive regression trees. Ann. Appl. Stat. 4, 266-298

44

<!-- page 45 -->

# References (3)

Schouten, B., de Nooij, G. (2005). Nonresponse adjustment using classification trees, Statistics Netherlands.

Toth, D. and Phipps, P. (2014). Regression tree models for analyzing survey response. JSM Proceedings, Government Statistics Section. Alexandria, VA: American Statistical Association. 339–351

Doove, L. L., Buuren, S. V. and E. Dusseldorp, E. (2013). Recursive partitioning for missing data imputation in the presence of interaction effects. Computational Statistics and Data Analysis, 72, 92-104

McConville, K. and Toth, D. (2018). Automated selection of post-strata using a model-assisted regression tree estimator, Scandinavian Journal of Statistics

45

<!-- page 46 -->

# References (4)

Rizzo, L., Kalton, G., and Brick, M. (1996). A comparison of some weighting adjustment methods for panel nonresponse. Survey Methodology, 22:43–53

Buskirk, T., Kirchner, A., Eck, A. and Signorina, E. (2018). An Introduction to Machine Learning Methods for Survey Researchers. Survey Practice, 11, 1-12

46
