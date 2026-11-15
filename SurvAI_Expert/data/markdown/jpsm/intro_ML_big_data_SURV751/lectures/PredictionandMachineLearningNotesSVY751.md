---
id: "jpsm/intro_ML_big_data_SURV751/lectures/PredictionandMachineLearningNotesSVY751"
source: "jpsm"
course: "SURV751"
course_title: "Introduction to Machine Learning and Big Data"
doc_type: "lecture"
title: "An Intro to Big Data and Machine Learning for Survey Researchers and Social Scientists"
original: "intro_ML_big_data_SURV751/lectures/PredictionandMachineLearningNotesSVY751.pdf"
pages: 56
sha256: "7be208c721974b926640f759ed2d92a0232b1fb05fec70d1bb6d73a697fe233c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:09"
---

<!-- page 1 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# An Intro to Big Data and Machine Learning for Survey Researchers and Social Scientists

**Trent D. Buskirk, Ph.D. (Marketing Systems Group)**

**Frauke Kreuter, Ph.D. (University of Maryland)**

**SVY 751, Notes Part 1**

Marketing Systems Group

UNIVERSITY OF 18 56 MARYLAND

Survey Methodology BE COUNTED

# Analyses of Big Data

**Classical Statistical Approaches versus Statistical Machine Learning**
Model Evaluation/Validation
Popular machine learning techniques
- K-Means Clustering
- K Nearest Neighbors
- CARTS
- Random Forests

Buskirk and Kreuter, SYV 751

1

<!-- page 2 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Analysis in a BIG DATA World

* **Many classical statistical techniques you learned while in Grad School, on the job, or from conferences, courses and in life are aptly suited for smaller and moderately sized data**
* **In the big data paradigm, however, some of these well relied upon techniques may not**
  * Differentiate between significant and non-significant predictors (i.e. every variable, whether meaningful or spurious could be retained in your final models)
    * Every correlation measure is significantly different from zero
  * Provide visually informative displays between relationships (i.e. the over crowded scatterplot)

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# Data Mining Paradigm

* **Data Mining is a process that combines**
  * **Statistical Analysis (Exploratory Data Analysis) with**
  * **Big (and Small) Data with**
  * **Machine Learning and lifting**

$$\text{Statistical Data Mining} = \text{Statistics} + \text{Big (\& Small) Data} + \text{Machine Learning and Lifting}$$

  * **Lifting focuses on the rows of the data table/set (i.e. the respondents or units that are observed)**
  * **Learning focuses on the columns of the data set (i.e. those variables that were observed explicitly (e.g. survey questions) or implicitly (e.g. paradata, appended data) and leverages computational algorithms to find structures among these variables.**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

2

<!-- page 3 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# The Machine Learning Big Data Juggling Act

* **Amount of data**
* **Complexity of Model**
* **Model Error Rate**

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

# Machine Learning/Data Mining versus Statistics

| Methods Aspect | Data Mining/Machine Learning | Statistics |
| :--- | :--- | :--- |
| "Large Data" | 1,000,000 rows, 4000 columns | 1,000 – 5,000 rows, 30-500 columns |
| Data Collection | Administrative, Search Queries, Third Party, Convenient | Surveys, Designed Experiments, Observational Studies, Panels |
| Sample Data? | Sometimes – but "estimates" can be expedited through parallel computing power/cloud computing | Yes – frameworks provide mechanism for computing standard errors |

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

3

<!-- page 4 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Machine Learning/Data Mining versus Statistics

| Methods Aspect | Data Mining/Machine Learning | Statistics |
| :---: | :---: | :---: |
| Modelling | Flexible – few, if any assumptions on underlying distribution | Particular model and error structure specified @ analysis (NP vs. P) |
| Inference | Prediction/Classification usually main focus | Understanding/explaining/ refining underlying theory; confidence intervals, parameter estimates |
| Computational Aspects | Computational efficiency important and considered | Computational efficiency not usually primary focus |
| Variable Selection/ Model fitting | Variable selection and overfitting models can be problematic | Variable and model selection issues must be considered |

# Machine Learning Overview

* **Two Types of “Learning”**
  * **Supervised Learning –**
    * **Dataset has clear set of Predictors (Xs) and Outcomes (Y)**
    * **Goal is to understand the relationship between predictors and outcomes**
    * **End goal is either <u>Inference</u> or <u>Prediction</u>**
  * **Unsupervised Learning –**
    * **Dataset consists of Predictors (Xs) only**
      * Think of Sampling Frame Data – all auxiliary variables – no survey outcome variables (i.e. Ys)
    * **We seek to understand the relationships between the variables/observations in the Dataset**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

4

<!-- page 5 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Supervised Learning and Survey Data

* Smartphone surveys have begun capturing photo data from respondents (Michaud, Buskirk and Saunders and Nielsen, 2012)
* Suppose a survey asked respondents about their "snacking habits" and asked them to snap a photo of the snack they are currently working on
  * Snacks could be classified as edible or drinkable.
  * Coders could mark photos as edible or drinkable and then the photo data captured from surveys could be classified into one of these categories using the machine learning model that was generated from a training/pilot set of images.

Stanford team creates computer vision algorithm that can describe photos (2014)
http://news.stanford.edu/news/2014/november/computer-vision-algorithm-111814.html

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

# Unsupervised Learning and Survey Data: Text Analysis

* Twitter data can be mined from the web using various resources including Python functions and R functions such as TwitteR.
* Text analytics apply unsupervised learning algorithms to group like tweets
  * "similar tweets" could be length, location, content, time, and shared followers, for example.
    * Natural Language Processing
  * sentiment analysis is accomplished by coding a set of tweets and training a machine learning classifer (supervised learning).
    * The trained classifier is then applied to future or new tweets and sentiment is ascribed to these as "predictions" from the trained model.

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

5

<!-- page 6 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Unsupervised Learning Example

* **Survey Researchers can use para-data obtained from a survey panel (probability or non-probability) to understand whether there are groups of panelists that are similar on certain survey attributes including:**
  * **Survey length**
  * **Incentive amount**
  * **Field period length**
  * **Number of Invitations required before response**
  * **Other attributes**
* **The idea would be to determine if there is a group of panelists who consistently take longer surveys, for more money versus those who take shorter surveys for less money, for example.**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Some Ideas for using Machine Learning in Survey Research

* **Imagine wanting to sample villages within a country for which little infrastructure or previous info is available.**
  * You can obtain Route Information from a local courier service there. Generally, the data contain volume of deliveries, frequencies and length of stopover.
  * For a greater fee, you obtain additional information on the type of delivery point for half the records (village, business, school, hospital).
  * Through machine learning algorithms you develop a classification model that groups delivery points into corresponding Structure Types: Villages or otherwise.
  * Based on this model, you can determine which of the remaining delivery points are also villages.
  * The final collection of delivery points identified as villages becomes your sampling frame.

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

6

<!-- page 7 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Data Mining/Machine Learning Resources

* **http://www.dataminingconsultant.com/resources.htm**
* **Data Mining Algorithms Explained Using R (2015)**
  * **http://bit.ly/1yZYHjK**
* **Data Mining for the Social Sciences (2015)**
  * **http://bit.ly/1DpPFC2**
* **An Introduction to Statistical Learning with Applications in R (2013)**
  * **Free PDF Version: http://bit.ly/1iUJso0**
  * **Online Resources for FREE lecture videos and labs in R**
    * **http://bit.ly/1snBMk5**
* **An overview of Machine Learning Functions available in R**
  * **http://cran.r-project.org/web/views/MachineLearning.html**

0100000101000001010100000100111101010010 **SVY 751 Notes** **Big Data**

---

# Analyses of Big Data

* Classical Statistical Approaches versus Statistical Machine Learning
* **Model Evaluation/Validation**
* Popular machine learning techniques
  * K-Means Clustering
  * K Nearest Neighbors
  * CARTS
  * Random Forests

Buskirk and Kreuter, SYV 751

7

<!-- page 8 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Prediction versus Explanation

* **Many applications of classical statistics have focused on explaining how or possibly why certain predictors are related to outcomes we care about**
    * Descriptive statistics quantify the degree of association or relationship.
    * Inferential statistics provide a way to confirm that the relationship goes beyond random error.
    * We evaluate models based on their ***explanatory power*** ($R^2$).
* **Machine learning algorithms can also describe relationships between predictors and outcomes**
    * But many times, this is not the end goal.
    * End goal is to develop well tuned predictive "models" that can be applied to new data.
    * Here models are evaluated based on their ***predictive power***.
* ***An excellent overview of the model building process within the context of prediction is given by Shmueli (2010).***
    * ***See: [http://bit.ly/1F27hGT](http://bit.ly/1F27hGT)***

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Building and Evaluating Models with Machine Learning Algorithms in the Big Data Context

* **Step 1: Determine the Appropriate Model/ML Method for the task at hand/outcome of interest**
    * Beware of the dreaded TYPE III error
        * Providing the right answer to the wrong question or "having correctly solved the wrong problem"
* **Step 2: Determine strategy for training/tuning/calibrating and evaluating models.**
* **Step 3: Estimate model parameters (i.e. train models)**
* **Step 4: Estimate other model "tuning" parameters that can't be directly inferred or computed from the data at hand**
* **Step 5: Evaluate and use the model (apparent performance, internal/ temporal/ external validity)**
    * This step will be related to step 2 above!

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

8

<!-- page 9 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Steps 2/5: Determining a Calibration/Tuning and Evaluation Strategy for ML Models

* **In general, cross-validation methods create resamples of the data**
* **The machine learning method or model is "trained" on one set and then applied to or tested on the other.**
* **Much like replication methods used for understanding the variance of estimators in the survey framework, cross-validation methods seek to understand model predictive performance by sub-sampling from the original data.**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Steps 2/5: Determining a Calibration/Tuning and Evaluation Strategy for ML Models, cont.

* **The most simple method for model validation is a simple split sample (training/testing)**
  * **Training sample should be large enough to handle complexity of the model, but not too large to eclipse the overall distributions of predictor variables in the test sample (Molinaro et al., 2005).**

* **BIG DATA SET**
  * $\rightarrow$ **Training DATA SET**: Data used to estimate the model parameters and tuning/complexity parameters
  * $\rightarrow$ **Testing /Validation DATA SET**: Data used to get an independent (internal validity) assessment of model predictive performance

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

9

<!-- page 10 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Steps 2/5: Determining a Calibration/Tuning and Evaluation Strategy for ML Models, cont.

* **A very common and effective alternative to the split sample validation method used in the machine learning literature and beyond is K-fold cross-validation. (Common value of K is 10).**

* **Cross-validation has been shown to be superior to simple split sample approaches for model validation**
  * **(See Kuhn and Johnson, 2013, pg. 67 for more references).**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# K-Fold Cross Validation

## BIG DATA SET

**Create K Folds**

**A fold is a subset selected at random without replacement from the big data set. In the case of 10-fold validation, a fold represents a 10% subsample.**

| FOLD # 1 | FOLD # 2 | FOLD # 3 | ... | FOLD # K |
| :---: | :---: | :---: | :---: | :---: |

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

10

<!-- page 11 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Working with K-Fold Cross Validation

- If you have ever worked with Delete-A-Group jackknife then the evaluation of performance using K-fold cross validation will be very intuitive.
- K-fold cross validation method proceeds iteratively:
  - the first fold becomes the test sample and the remaining 9 folds are combined to form the training sample. The model/method is fit/applied to the training sample and performance is evaluated on the test sample.
  - the process continues using each fold as the test sample and the remaining K-1 folds as the training sample
  - the K values of model performance obtained from each fold used as the testing set are then averaged together to form an estimate of cross-validated performance. Variability in these performance metrics can also be obtained using the K-values.

0100000101000001010100000100111101010010SVY 751 Notes Big Data

# Predictive Validity within the Big Data Context

- So why do we care about split sample or other validation methods when working with big data?
  - Large sample sizes generally result in most predictors being statistically significant (possible Type I errors)
  - If the models built using the training sample were evaluated for fit using the training sample itself, the overall error rates would be overly optimistic (Kuhn and Johnson, 2013).
  - This type of validity or evaluation is referred to as apparent performance or apparent validity.
    - See Steyerberg and Harrell: http://bit.ly/1K7IIWJ

0100000101000001010100000100111101010010SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

11

<!-- page 12 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Predictive Validity in the Survey Research Context

* **Within the context of survey research, we should think more critically about the level of predictive validity we require for various survey related tasks.**
  * For weighting purposes, internally valid models are most needed – ones that are consistent and accurate for a given sample of respondents and nonrespondents.
  * For tailored and responsive survey designs, predictive models should be internally, temporally, and in some cases, externally valid because their application is intended at some subsequent point in time or possibly to a subsequent sample.
  * Prediction of Respondents to future survey based on survey respondents historical data (panel) or paradata
    * Buskirk, Burks and West, 2013;
    * Wagner and Frost, 2014;
    * Schouten et al., 2013

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

# Unsupervised Learning in the Survey Context

* **Generally, a mix of both unsupervised and supervised machine learning approaches can be used for a given study:**
  * Auxiliary information could be used to form clusters that were optimal (most heterogeneous) and then survey results could be obtained by incorporating the sampling design (Elliot, 2011: http://1.usa.gov/1OUIyJd)
  * Tailored survey design to predict survey response as a function of hundreds of geographic auxiliary data appended to an ABS sample – use Principal Components to “reduce” the variables into a smaller set of independent signals to be used in a logistic regression model (See Buskirk, West and Burks, 2013).
  * Using geographic variables to predict presence of phone number for a sampling frame of addresses – Olson and Buskirk (2015) first applied factor analysis to create smaller set of factors used for prediction (See Olson and Buskirk, 2015).

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

12

<!-- page 13 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Example Big Data, Machine Learning Equation

$+$ $+$ $+$

$=$

Via machine learning, a blending of Twitter Data and sales tracked with loyalty cards and smartphone apps and employee data, IBM found that Starbuck’s best customers were the ones influenced by CHURN in the sales associates. INSIGHTS: “Human Touch matters most to loyal customers”

http://bits.blogs.nytimes.com/2015/03/17/ibm-introduces-twitter-fueled-data-services-for-business/?vh=21194ac2ead6079e9e00176c20937f334d92ea63&ts=1426600932&_r=0

0100000101000001010100000100111101010010SVY 751 Notes Big

*[Figure: The page contains a visual equation diagram at the top—combining icons for Twitter, Starbucks, a mobile app/loyalty card, and a robot—and a dual-axis line plot at the bottom. The line plot compares US per capita consumption of mozzarella cheese (left y-axis, in pounds) with US civil engineering doctorates awarded (right y-axis, in degrees awarded) across the years 2000 to 2009 (x-axis), showing that both series follow a closely matching upward trend over time.]*

<!-- page 14 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Analyses of Big Data

Classical Statistical Approaches versus Statistical Machine Learning

Model Evaluation/Validation

Popular machine learning techniques
- K-Means Clustering
- K Nearest Neighbors
- CARTS
- Random Forests

# Machine Learning Methods/Techniques

- There are many different machine learning methods available
- Many are non-parametric in nature and while a functional form can be specified, it is generally not a natural byproduct of the method
- Wu et al. (2008) provide an overview of ten of the top machine learning algorithms including (see [http://bit.ly/1liWTir](http://bit.ly/1liWTir)) :
  - K-means Clustering
  - PageRank
  - K-nearest neighbors
  - Support Vector Machines
  - Decision Trees and Classification and Regression Trees
  - Apriori Algorithm
  - The EM Algorithm (Expectation-Maximization)
  - Naïve Bayes
  - Ensemble Methods (like AdaBoost and Random Forests).

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

14

<!-- page 15 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Overview of Machine Learning Methods/Outcomes

**Outcomes Generated Will Be:**

| | *Supervised Learning* | *Unsupervised Learning* |
| :--- | :---: | :---: |
| ***Discrete*** | classification or categorization | clustering |
| ***Continuous*** | regression | dimensionality reduction |

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# A Basic Example Applying Machine Learning to Sample Designs

* **Imagine that the MobileMaddness Phone Company wanted to determine the best way to communicate with its customers who have enrolled in its VIP program.**
* **The company believes social network micro messages will be more salient than other avenues. It wants to estimate the average amount of time spent on social networking sites via mobile apps and web for its VIP customers.**

*Vip*

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

15

<!-- page 16 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# A Basic Example Applying Machine Learning to Sample Designs, Cont.

* A data file for VIP members contains email address, past month mobile internet activity, data consumption in past month, text message volume and monthly bill.
* The company believes that the amount of time spent on social networking sites (on mobile devices) may be related to overall mobile internet activity, data consumption and perhaps total bill.
* The data file contains millions of records with information available for the 5 variables mentioned.
* Goal: Efficiently sample records to send a two question survey about total time spent last month using (a) social networking mobile sites and (b) apps.

0100000101000001010100000100111101010010 SVY 751

<!-- page 17 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Cluster Analysis – Not Cluster Sampling

* **Two main types of cluster analysis:**
  * **K-means Clustering**
    * **Seek to partition observations into a pre-specified number of clusters (groupings)**
    * **Number of clusters is known *a priori* (i.e. parameter of the method)**
  * **Hierarchical Clustering**
    * **The number of clusters is not known in advance**
    * **By product of this method is a Dendrogram – a tree like plot that illustrates the formation of all resulting clusters.**

*Unsupervised Learning*
clustering

Cluster Observations Using their Features (Variables) $\rightarrow$ Subgroups among the Observations (Segments)

Cluster Features (Variables) Using all observations $\rightarrow$ Subgroups among the Features (Profiles)

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# Method Overview: K-means Clustering

* **What type of Learner?**
  * **Nonparametric method; Unsupervised Learner**
  * **Method is also known as "data segmentation"**
* **For what problems can you apply this method?**
  * **Aims at finding discrete categories/groupings based on a collection of covariates (no outcome variables used) that are measured on a continuous scale (or at least ordinal).**
* **Does this method have any Tuning Parameters?**
  * **One parameter: k – the number of CLUSTERS (known in advance, or at least a range of clusters).**
  * **And the distance measure used to determine proximity/similarity between cases.**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

17

<!-- page 18 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: K-means Clustering

* **How does this Method Work?**

<u>INITIALIZATION Step:</u> Each case is randomly assigned to one of K clusters (K is known and provided by the user)

<u>ITERATION Step 1:</u> Computation – For each of the K clusters, compute the Cluster Centroid (component-wise means)

<u>ITERATION Step 2:</u> Reclassification – Assign each case to the cluster whose centroid is the closest as measured by squared Euclidean distance (or other distance function).

<u>FINALIZATION Step:</u> The algorithm “converges” when cluster reclassification stop changing

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# Method Overview: K-means Clustering

* **Insights on Parameters for this Method**
  * **Small k $\rightarrow$ possibly more heterogeneous (and larger) clusters;**
  * **Large k $\rightarrow$ smaller clusters, more homogeneous with respect to variables used in determining clusters;**
  * **The squared Euclidean distance is by far the most common distance measure. Specifying the appropriate distance/dissimilarity measure is by far more important than the choice of clustering algorithm.**
  * **Technically, the initial cluster assignments can be a third parameter. Usually, the algorithm is run using different starting seeds (i.e. different initial cluster assignments) for the same value of K. Results are compared to assess stability of the solution/sensitivity to starting assignments.**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

18

<!-- page 19 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: K-means Clustering

- **Caveats/ Considerations for the Method**
  - This method can be sensitive to the scaling of the p-predictors. If all are on different scales/ measured in different units, standardizing variables is recommended.
    - This effectively gives every predictor equal weight in determining “similarity” of cases.
  - This method is not recommended for use with nominal categorical predictors without some additional preparation/transformation of these variables.
    - One alternative is k-mode clustering or providing similarity matrix for each case.

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

# Method Overview: K-means Clustering

- **Implementation of this method in R**
  - kmeans {stats package};
  - cluster.Sim {clusterSim package};
  - knn.reg {cluster package}
  - rattle {rattle package}
  - [http://www.r-bloggers.com/k-means-clustering-from-r-in-action/](http://www.r-bloggers.com/k-means-clustering-from-r-in-action/)
- **Examples of this method in the S.R. Literature**
  - Segmentation of Clients and Client Interests using Survey Data
    - Krantz et al. (2009); [http://bit.ly/1OlrnAd](http://bit.ly/1OlrnAd)
  - Developing a typology of Internet Use based on Survey Data
    - Bae Brandtzæg et al. (2011); [http://bit.ly/1FkyhQr](http://bit.ly/1FkyhQr)
  - Frame improvements–identifying missing subtypes of Farms
    - McCarthy et al. (2009); [http://1.usa.gov/1lcQekK](http://1.usa.gov/1lcQekK)

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

19

<!-- page 20 -->

Notes are for STUDENT USE ONLY. DO NOT
circulate without permission from Instructors.

1/29/2016

# Cluster Analysis Example #1

* **A new poll is desired for the state of Florida regarding income and employment rate disparities in the state’s workforce. The client has specified that comparisons between and distinct estimates from three primary racial/ethnic groups are desired.**
  * **Groups include: Hispanic, Non-Hispanic Black and Non-Hispanic Other (including White, Asian and other races).**
  * **The design is a stratified cluster sample in which counties will be stratified into groups and selected. A random sample of addresses within each selected county will occur at the final sampling stage.**
  * **Auxiliary data for each of the 67 Florida counties include:**
    * **Percentage of Hispanic Population**
    * **Percentage of Non-Hispanic Black Population**
    * **Percentage of Non-Hispanic Other Population**

0100000101000001010100000100111101010010**SVY 751 Notes Big Data**

# Cluster Analysis Example, Cont.

* **Task: Can we use the auxiliary data to form strata that will provide sufficient strata to represent the three race/ethnic targets?**
  * **It would be hard to stratify directly based on race since the sampling occurs in multiple stages**
  * **Certainly, we could append race data for every address in Florida and then stratify,**
    * **but this information is not readily available or cost-feasible**
  * **We could use the auxiliary data to create strata based on cross-tabulating binary “High/Low” race group percentages from each Race/Ethnic Group (or quartiles, etc),**
    * **but this process may result in too many or sparse strata and may be inefficient as it essentially considers each variable separately.**

Elliott, M. R. (2011). A Simple Method to Generate Equal-Sized Homogenous Strata or Clusters for Population-Based Sampling. *Annals of Epidemiology*, 21(4), 290–296.
doi:10.1016/j.annepidem.2010.11.016

0100000101000001010100000100111101010010**SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

20

<!-- page 21 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# A Heuristic for Determining the Number of Clusters

```r
# A "Scree" Type plot for the number
of clusters. Criterion is to have a
solution that occurs at the point
where there is a large drop in Within
Cluster SS.

n=15
FloridaClust=numeric(n)
for (i in 1:n)
{FloridaClust[i] =
kmeans(Florida[,PredVars],i)$tot.withinss}
plot(1:15, FloridaClust,col="darkred",
lwd=3, xlab="Number of Clusters",
type="b", ylab="Total Within Cluster SS",
col.axis="navyblue")
```

0100000101000001010100000100111101010010 SV

*[Figure: The top section features a scree-type line plot with "Number of Clusters" (from 1 to 15) on the x-axis and "Total Within Cluster SS" (from 0.0 to 3.0) on the y-axis, showing a sharp drop in variance up to clusters 2, 3, and 4 (highlighted by blue circles) before leveling off. The bottom section compares two 3D scatter plots with axes for "PCT_Hispanic", "PCT_AllOther", and "PCT_Black", illustrating how a subset of unclustered red points in the left plot (outlined in blue and linked by a large arrow) is separated into a distinct blue group (Cluster 1, 9 cases) alongside the remaining red group (Cluster 2, 58 cases) in the right plot.]*

<!-- page 22 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Three and Four Cluster Solution

**Number of Cases in each Cluster**

| | | |
| :--- | :--- | :--- |
| Cluster | 1 | 17.000 |
| | 2 | 4.000 |
| | 3 | 46.000 |

**Final Cluster Centers**

| | 1.0 | 2.0 | 3.0 |
| :--- | :--- | :--- | :--- |
| **PCT\_AllOther** | **58.7** | **37.0** | **79.8** |
| **PCT\_Hispanic** | **17.7** | **51.9** | **9.0** |
| **PCT\_Black** | **23.6** | **11.1** | **11.2** |

**Number of Cases in each Cluster**

| | | |
| :--- | :--- | :--- |
| Cluster | 1 | 7.000 |
| | 2 | 4.000 |
| | 3 | 42.000 |
| | 4 | 14.000 |

**Final Cluster Centers**

| | 1 | 2 | 3 | 4 |
| :--- | :--- | :--- | :--- | :--- |
| PCT\_AllOther | 57.3% | 37.0% | 80.6% | 63.0% |
| PCT\_Hispanic | 7.4% | 51.9% | 7.9% | 23.5% |
| PCT\_Black | 35.3% | 11.1% | 11.5% | 13.5% |

# Visualizing the Clusters

0100000101000001010100000100111101010010 SVY 751

<!-- page 23 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Visualizing the Clusters

**Cluster of County**
* 1
* 2
* 3

**County**
**Population Percent**
* Black
* Hispanic
* All Other

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

# Visualizing the Clusters

**Cluster of County**
* 1
* 2
* 3
* 4

**County**
**Population Percent**
* Black
* Hispanic
* All Other

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

23

<!-- page 24 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# SPSS Syntax for K-means Clustering

```
DATASET ACTIVATE FloridaData.
QUICK CLUSTER PCT_AllOther PCT_Hispanic PCT_Black
  /MISSING=LISTWISE
  /CRITERIA=CLUSTER(2) MXITER(20) CONVERGE(0)
  /METHOD=KMEANS(NOUPDATE)
  /SAVE CLUSTER DISTANCE
  /PRINT INITIAL ANOVA CLUSTER DISTAN.

GRAPH
  /SCATTERPLOT(XYZ)=PCT_AllOther WITH PCT_Hispanic WITH PCT_Black BY QCL
  /MISSING=LISTWISE.
```

Number of Clusters (User Specified)

Requests that a categorical Variable be created that identifies the clusters (QCL is default name)

SPSS Generated Cluster Variable

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

# R-Code for producing k-means clustering

```r
# Cluster Example
# Identify Variables from the Florida Data set that need to be clustered
PredVars<-names(Florida)[c(15,16,19)]
```

3-Cluster Solution

```r
set.seed(517)
Florida3cluster<-
kmeans(na.omit(Florida[,PredVars]), centers=3)

#Print Number of Cases per Cluster
table(Florida3cluster$cluster)
# 1  2  3
# 4 17 46

#Print Cluster Centers
t(round(100*Florida3cluster$centers,1))
#                1    2    3
#PCT_Hispanic 51.9 17.7  9.0
#PCT_Black    11.1 23.6 11.2
#PCT_AllOther 37.0 58.7 79.8
```

4-Cluster Solution

```r
set.seed(1)
Florida4cluster<-
kmeans(na.omit(Florida[,PredVars]), centers=4)

#Print Number of Cases per Cluster
table(Florida4cluster$cluster)
# 1  2  3  4
#42  4  7 14

#Print Cluster Centers
t(round(100*Florida4cluster$centers,1))
#                1    2    3    4
#PCT_Hispanic  7.9 51.9  7.4 23.5
#PCT_Black    11.5 11.1 35.3 13.5
#PCT_AllOther 80.6 37.0 57.3 63.0
```

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

24

<!-- page 25 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Cluster Analysis Example 2:

* Of interest is to estimate the number of Facebook Users in the U.S. and in general, which states are more digitally social
  * Estimate the number of social media users there are in the U.S. (e.g. facebook, pinterest)
* Auxiliary data are limited. One possible source of auxiliary information pertains to search volumes for each state on specific key words or websites:
  * Facebook search term
  * Pinterest search term
  * Twitter search term
  * Other related search term
* Using historical data on Facebook Users estimated by state, we could determine if the internet search volume data are related to one of our key outcome measures.
* If so, stratification of states on this and related searches might lead to more efficient estimates and sampling designs.

0100000101000001010100000100111101010010SVY 751 Notes **Big Data**

# Cluster Example 2, Cont.

* According to Pew, 2014 Social Media Update, of Online Adults:
  * 71% use Facebook
  * 23% use Twitter
  * 26% use Instagram
  * 28% use Pinterest
  * 28% use LinkedIn

**Search Parameters:**
Search =Google Trends
Search Term=Facebook,
Search Term2=Pinterest;
Time Range: 2014

Google
Search Google Trends
Trends
United States
May 4, 2015

http://www.pewinternet.org/2015/01/09/social-media-update-2014/

0100000101000001010100000100111101010010SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

25

<!-- page 26 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Supervised Learning to Understand the Relationship between Facebook User Percentage Relative to Facebook Search Term Volume

**`FaceBook Penetration (Among Internet Users)`**

30 40 50 60 70

40 50 60 70 80 90 100

**FaceBook Search Term Volume 2014**

**Facebook Internet Search Volume by State:**
Google Trends:
Search Term="Facebook" search term
Time Frame: 2014

**Facebook User Penetration By State Statistics:**

[http://www.internetworldstats.com/stats26.htm#america](http://www.internetworldstats.com/stats26.htm#america)

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# Facebook Users and Internet Usage

* **Modeling Facebook Users (2012) as a function of Search Volume (state by state)**

```r
> RegModel.1 <- lm(FBPenetrationInternet~facebookSearchTermVol14,
data=Facebook)
> summary(RegModel.1)

Call:
lm(formula = FBPenetrationInternet ~ facebookSearchTermVol14,
    data = Facebook)

Residuals:
     Min       1Q   Median       3Q      Max
-19.5452  -3.7702  -0.1259   4.2281  15.2330

Coefficients:
                        Estimate Std. Error t value Pr(>|t|)
(Intercept)              44.28495    4.52906   9.778 5.26e-13 ***
facebookSearchTermVol14   0.14724    0.07794   1.889   0.0649 .
---
Residual standard error: 7.391 on 48 degrees of freedom
Multiple R-squared:  0.0692,	Adjusted R-squared:  0.04981
F-statistic: 3.569 on 1 and 48 DF,  p-value: 0.06493
```

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

26

<!-- page 27 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Cluster Example 2 cont. :
# Social Media Searches

| | Cluster | | | |
| :--- | :---: | :---: | :---: | :---: |
| | 1 | 2 | 3 | 4 |
| Facebook Search Term Volume Index 2014 | 62 | 49 | 43 | 90 |
| Pinterest Search Term Volume Index 2014 | 70.57 | 54.38 | 90.38 | 46.67 |

| | Cluster | | |
| :--- | :---: | :---: | :---: |
| | 1 | 2 | 3 |
| Facebook Search Term Volume Index 2014 | 52 | 49 | 74 |
| Pinterest Search Term Volume Index 2014 | 82.05 | 55.72 | 61.08 |

0100 ... 0

# A Basic Example Applying Machine Learning to Sample Designs

* Imagine that the MobileMaddness Phone Company wanted to determine the best way to communicate with its customers who have enrolled in its VIP program.
* The company believes social network micro messages will be more salient than other avenues. It wants to estimate the average amount of time spent on social networking sites via mobile apps and web for its VIP customers.

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

27

<!-- page 28 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# A Basic Example Applying Machine Learning to Sample Designs, Cont.

* A data file for VIP members contains email address, past month mobile internet activity, data consumption in past month, text message volume and monthly bill.
* The company believes that the amount of time spent on social networking sites (on mobile devices) may be related to overall mobile internet activity, data consumption and perhaps total bill.
* The data file contains millions of records with information available for the 5 variables mentioned.
* Goal: Efficiently sample records to send a two question survey about total time spent last month using (a) social networking mobile sites and (b) apps.

0100000101000001010100000100111101010010SVY 751 Notes **Big Data**

# A Basic Example Applying Machine Learning to Sample Designs, Cont.

* One possible solution:
  * Rather than take a simple random sample of X% of the records, it could be more efficient to first stratify the total VIP Customer frame.
  * But the auxiliary variables that are likely related to the key outcome of interest (time on social media mobile sources) are continuous.
  * We could create categorical versions of each of the three key predictors then cross them to form exhaustive strata
  * A possibly more efficient way could be to cluster the VIP customers using the three variables: total bill, total data consumed and mobile internet activity.
  * The resulting “clusters” become the strata for sampling.

0100000101000001010100000100111101010010SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

28

<!-- page 29 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Analyses of Big Data

* Classical Statistical Approaches versus Statistical Machine Learning
* Model Evaluation/Validation
* Popular machine learning techniques
  * K-Means Clustering
  * **K Nearest Neighbors**
  * CARTS
  * Random Forests

## Method Overview: K-nearest Neighbors

* **What type of Learner?**
  * Nonparametric method; Supervised Learner (if y)
  * Unsupervised learner if no y or don't use it

* **For what problems can you apply this method?**
  * Regression/Prediction for Continuous Outcome Variables
  * Classification for Categorical Outcome Variables (2 or more levels)
  * Method usually applied when predictors are all continuous/ordinal

* **Does this method have any Tuning Parameters?**
  * One parameter: k – the number "neighbors"
    * Here neighbors refer to cases in the data (i.e. rows in the D.S.)

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

29

<!-- page 30 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: KNN

## How does this Method Work?

Step 1: Determine Neighbors for Each Point in the Data Set

Using a distance measure (Euclidean/City), KNN identifies data points that are “close” in p-dimensional space to each case in the test set for which predicted values are desired.

Step 2: Make the Prediction/Estimate

For classification, the predicted value is the modal class of all k-nearest neighbors in the training set;

For regression, the predicted value is the mean/median of the outcome variable among all k-nearest neighbors in the training set.

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

# Example of KNN with 2 predictors and a Binary Outcome with K=5

Tweet Sentiment
* Negative
* Positive

Number of Times Tweet was Retweeted

Number of Characters in Tweet about AAPOR

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

30

<!-- page 31 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: KNN

* **Insights on Parameters for this Method**
  * Small $k \rightarrow$ low bias, but high variance in estimates;
  * Large $k \rightarrow$ higher bias but lower variance;
  * For classification applications, $k$ is usually chosen as an odd number (to avoid ties)
  * Other distance functions can also be used, but most common is Euclidean Distance
* **Caveats/ Considerations for the Method**
  * This method is sensitive to scaling of $p$-predictors.
  * If all predictors are on different scales/measured in different units, standardizing variables is strongly recommended.

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Method Overview: KNN

* **Caveats/ Considerations for the Method**
  * This method can be sensitive to the scaling of the $p$-predictors. If all are on different scales/ measured in different units, standardizing variables is recommended.
    * This effectively gives every predictor equal weight in determining "similarity" of cases.
  * This method is not recommended for use with nominal categorical predictors without some additional preparation/transformation of these variables.
    * One alternative is k-mode clustering or providing similarity matrix for each case.

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

31

<!-- page 32 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: KNN

* **Implementation of this method in R**
  * train{caret package; use method="knn");
  * knn{class package};
  * knn.reg{FNN package}
* **Examples of this method in the S.R. Literature**
  * Multiple Imputation
    * Jonsson and Wohlin (2004); [http://www.wohlin.eu/metrics04.pdf](http://www.wohlin.eu/metrics04.pdf)
  * Image Classification
  * Text Classification
  * Propensity Weighting
  * Binary Prediction from Longitudinal Survey Data
    * Bryant et al. (1996)
    * [http://irp.wisc.edu/publications/dps/pdfs/dp109296.pdf](http://irp.wisc.edu/publications/dps/pdfs/dp109296.pdf)

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

# Example 3: KNN for Classification

* **Imagine a mobile web survey just in time for spring.**
  * The question asks respondents to choose their favorite type of flower from among a list of major types.
  * Iris is one response option.
  * Respondents are asked to capture a picture of their favorite Iris and upload the image via the survey.
  * The goal is to process images to determine which *species* of Iris plant has been captured by the respondent (rather than asking them for the scientific species).

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

32

<!-- page 33 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Example 3: KNN, Cont.

* **Let’s imagine 150 respondents answered Iris and provided photos of one of three common species of Iris plants: Setosa, Versicolor and Virginica.**
* **Using the images, we can generate measures of four continuous variables (all measured in cm):**
  * **Sepal Length; Sepal Width; Petal Length; Petal Width**
  * **Using these measurements we want to classify images into the three species groups.**
  * **Training a machine learning algorithm on respondent images will allow us to classify others in the future.**
  * **The specific dataset we will use here for this demonstration is the famous Fischer’s Iris data (`>data(iris)` in R) http://en.wikipedia.org/wiki/Iris_flower_data_set**

0100000101000001010100000100111101010010 **SVY 751 Notes** **Big Data**

---

# Some Beautiful Flowers...

**Iris setosa** | **Iris versicolor** | **Iris virginica**

**GOAL: Develop a tool/train a machine learning method to classify flower images as Iris virginica or not.**

petal
sepal

0100000101000001010100000100111101010010 **SVY 751 Notes** **Big Data**

Buskirk and Kreuter, SYV 751

33

<!-- page 34 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# The Four Measures for our Flowers

0100000101000001010100

*[Figure: The page shows a parallel coordinates plot titled "The Four Measures for our Flowers," displaying numeric values from 0 to 8 on the vertical axis across four flower attributes (Sepal.Length, Sepal.Width, Petal.Length, and Petal.Width) on the horizontal axis. The plot compares two groups—"Virginica" (teal lines) and "Other" (red lines)—showing that Virginica flowers generally have higher values across the measures, particularly for Petal.Length and Petal.Width, whereas a subset of "Other" flowers has much lower petal measurements.]*

<!-- page 35 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# 5-Fold Cross Validation to Determine the Optimal Number of Neighbors

# of Neighbors

010000010100000101010000010

*[Figure: The top line plot with error bars shows the mean of accuracy (vertical axis, from 0.93 to 0.99) across different odd numbers of neighbors (horizontal axis, from 1 to 31), showing accuracy peaking at 11 neighbors within a high-performing green-boxed group (7 to 17 neighbors) before dropping into a lower red-boxed group (19 to 31 neighbors). The bottom figure is a 2x2 confusion matrix comparing actual classes (vertical axis) against predicted classes (horizontal axis) for "Virginica" and "Other", showing high classification accuracy with 49 and 99 correct predictions on the main diagonal and only 1 error in each off-diagonal cell.]*

<!-- page 36 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Analyses of Big Data

Classical Statistical Approaches versus Statistical Machine Learning
Model Evaluation/Validation
Popular machine learning techniques
* K-Means Clustering
* K Nearest Neighbors
* **CARTS**
* Random Forests

## Method Overview: Classification and Regression Trees (CARTs)

* **What type of Learner?**
  * **Nonparametric method; Supervised Learner (if y)**
  * **Unsupervised learner if no y or don't use it**
  * **CARTs a.k.a. *RECURSIVE Partitioning***
* **For what problems can you apply this method?**
  * **Regression/Prediction for Continuous Outcome Variables**
  * **Classification for Categorical Outcome Variables (2 or more levels)**
  * **Tree methods can handle predictors that are continuous, categorical, skewed and sparse data as well as missing data**
* **Does this method have any Parameters?**
  * **Complexity Parameter (Cp)**
  * **Node Size/Branches/Fraction of Objects**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

36

<!-- page 37 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# How Do CARTs Work?

**Step 1: Root Node Split.** Starting with the entire data set (root node), select a variable (and corresponding range or grouping of levels) that generates two subsequent nodes that are each more “pure” than the root node.

The usual optimization criterion for tree growing is Node Impurity is measured using the SSR (sum of squared residuals/errors) for continuous outcomes and using the Gini Index or Chi Squared/Deviance criterion for categorical outcomes.

**Step 2: Continued Branching.** Within each of the subsequent nodes, additional splits (branching) are determined from all possible predictors; any resulting child nodes are even more homogenous/pure than parent nodes.

**Step 3: Pruning.** After a tree is grown to completion, pruning branches back according to the complexity parameter is sometimes applied. Essentially, nodes and branches are removed from the tree producing a tree that is not as deep and with fewer final nodes.

**Step 4: Prediction.** Within each final node the predicted value is either the modal value/class of the outcome (Classification) or the mean of the outcome variable for observations in the node (Regression)

# CART Overview

Predictor 1 | Predictor 2 | Predictor 3 | Predictor 4 | Predictor 5

ROOT NODE (All Data)

Predictor 1 | Predictor 2 | Predictor 3 | Predictor 4 | Predictor 5

Predictor 2 Satisfies Criterion A | Predictor 2 DOES Not Satisfy Criterion A (3)

Predictor 1 | Predictor 2 | Predictor 3 | Predictor 4 | Predictor 5

Predictor 3 Satisfies Criterion B (1) | Predictor 3 Does Not Satisfy Criterion B (2)

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

37

<!-- page 38 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: CARTs

* **Insights on Parameters for this Method**
  * Small Cp $\rightarrow$ lead to more complex trees (larger, deeper with more final nodes/leaves).
  * Large Cp $\rightarrow$ lead to less complex trees (smaller, more shallow with fewer final nodes/leaves)
* **Caveats/ Considerations for the Method**
  * Trees that are too large or overly complex can result in estimates that perform poorly for new data (low bias but high variance).
  * Conversely, trees that are not complex enough may result in estimates that don't adequately fit (lower variance but possibly larger bias).
  * Missing data are ignored when the tree is being built. However, when used for prediction, tree models can handle missing data by using SURROGATE variables – those related to the splitting variable and for which results are similar.
  * Predictors with large numbers of categories tend to get selected for splitting compared to those with fewer categories.

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Method Overview: CARTs

* **Advantages of this Method**
  * Tree-based models are nonparametric and don't assume a functional form between outcome and predictors
  * Tree-based models naturally detect higher level interactions among the predictors.
  * Tree-based models are easy to visualize and interpret – even if the number of candidate predictors is large
* **Disadvantages of this Method**
  * Single trees are likely to have sub-optimal predictive performance compared to other methods (Kuhn and Johnson, 2013)
    * This is especially true if the relationship between the outcome and predictors is not described well by “rectangular” boundaries
  * The number of different predicted values (for regression trees) is determined by the number of final nodes in the tree.

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

38

<!-- page 39 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: CARTs

* **Implementation of this method in R**
  * rpart{rpart package}
  * tree{tree package};
  * ctree{party package}
  * Rattle {rattle package}
* **Examples of this method in the S.R. Literature**
  * **Response Propensity Estimation and Nonresponse Bias Evaluation**
    * Phipps and Toth, 2012; http://1.usa.gov/1I4fObz
    * McCarthy et al. (2009); http://1.usa.gov/1IcQekK
    * Schouten and de Nooij (2005); http://bit.ly/1zUrPtf
  * **Frame Revision/Trimming**
    * McCarthy et al. (2009); http://1.usa.gov/1IcQekK
  * **Multiple Imputation**
    * Mesa, Tsai and Chambers (2000); http://bit.ly/1DrkSBt
  * **Generating Partially Synthetic Data**
    * Reiter (2005); http://bit.ly/1DY6kvz

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Example 4: Regression Trees

* **A media company specializing in online advertisement and survey recruiting via social media wants to estimate a new metric called *Social Media Response Score*.**
  * **This metric measures how likely a user is to respond to promptings, invitations and solicitations via social media advertising methods.**
  * **Two predictors of this metric being evaluated include:**
    * **The Number of Years active on Facebook (0 – 10);**
    * **The proportion of the day the user has access to internet (0-1).**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

39

<!-- page 40 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# The Overall Data Set (n=50,000)

Percentage of Day with Internet Access

Social Media Response Score

# Years Active on Facebook

0100000101000001010100000100111101010010 SVY

*[Figure: The page displays two figures: a 3D scatter plot on top plotting "Social Media Response Score" (0–100) against "Percentage of Day with Internet Access" (0–1) and "# Years Active on Facebook" (0–10) for 50,000 observations divided into six distinct color-coded clusters, and a decision tree diagram below it. The decision tree splits the data by these internet access and Facebook activity thresholds into six terminal nodes (labeled R1 through R6), each showing a boxplot of the response score on a 0–100 vertical scale where the median score generally increases from Region 1 (~20) to Region 6 (~80).]*

<!-- page 41 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# The Regions for the Tree

* # Years Active on Facebook
* Prop of Day with Internet Access
* R1
* R2
* R3
* R4
* R5
* R6

**Region 1: PDIA <=40% and YAFB<=2**

**Region 2: PDIA<=40% and YAFB >2**

**Region 3: PDIA >40% & <=60% and YAFB >6**

**Region 4: PDIA>40% & <=60% and YAFB<=6**

**Region 5: PDIA>60% and YAFB <8**

**Region 6: PDIA > 60% and YAFB >=8**

tes Big Data

---

# Distribution of Outcome Per Final Node

* Frequency
* Social Media Response Score
* region of Plot: 1, 2, 3, 4, 5, 6

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

---

Buskirk and Kreuter, SYV 751

41

<!-- page 42 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Tree-Based Model Results

**PDIA**
0, 0.2, 0.4, 0.6, 0.8, 1

**SMRS**
80, 70, 60, 50, 40, 30

**YAFB**
10, 8, 6, 4, 2, 0

z

**Regression Tree Model:**
SMRS = Average of SMRS within Regions identified by Tree

**RSS: 1256286**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Multiple Regression Based Results

SMRS
100

PDwithIA
1

YAFB
10

**Multiple Regression Model:**
SMRS = PDIA + YAFB + PDIA\*YAFB + error

**RSS: 4396902**

In this case, the Residual Sums of Squares (i.e. squared error) for the Multiple regression model is nearly **3.5** times that from the Tree-based Model

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

42

<!-- page 43 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# R-code for Example 4: Regression Trees

```r
# TreeExample Data: x1=PDIA; x2=YAFB and y=Social Media Response Score
# region corresponds to one of the 6 regions defined by the specific combinations of x1 and x2
#Plot the surface defined by the three variables x1, x2 and y.
require(rgl)
plot3d(TreeExample$x1, TreeExample$x2, TreeExample$y, col=TreeExample$region, size=2, xlab=" ", ylab=" ", zlab=" ")

# There are many options for creating trees, we choose ctree here from the party package
# primarily because of the default features of it's resulting graphics
require(party)
set.seed(52015)
tree.Example<-ctree(y~x1+x2, data=TreeExample)
# Now evaluate the Residual Sums of Squares from the Predictions
RSStreemodel<-sum((TreeExample$y-predict(tree.Example))^2)
[1] 1256286

# This code allows us to plot the "predicted" surface estimated from the tree
f <- function(x, y) {newdat<-data.frame(x, y)
names(newdat)<-c("x1", "x2")
fout<-predict(tree.Example, newdata=newdat)
fout}

x1dat<-seq(0,1, length.out=20)
x2dat<-seq(0,10, length.out=20)
z<-outer(x1dat, x2dat, f)
persp3d(x=seq(0,1, length.out=nrow(z)), y=seq(0,10, length.out=ncol(z)),z, col=c("pink", "green2"), xlab=" ", ylab=" ")
```

# Some Beautiful Flowers...REDUX

Iris setosa

Iris versicolor

Iris virginica

GOAL: Develop a tool/train a machine learning method to classify flower images as Iris virginica or not.

petal

sepal

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

43

<!-- page 44 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# From Flowers to Trees: Iris Data, Revisited

### Using Rpart in R

### Using ctree in R

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# A Tale of Two Trees...

### Using Rpart in R

### Using ctree in R

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

44

<!-- page 45 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Overall Results of the Tree Model for Iris Data

## TREE Model

```r
# Accuracy : 0.96
# 95% CI : (0.915, 0.9852)
# No Information Rate : 0.6667
# P-Value [Acc > NIR] : <2e-16

# Sensitivity : 0.9000
# Specificity : 0.9900
# Pos Pred Value : 0.9783
# Neg Pred Value : 0.9519

# 'Positive' Class : Virginica
```

## KNN (11) Model

```r
# Accuracy : 0.9867
# 95% CI : (0.9527, 0.9984)
# No Information Rate : 0.6667
# P-Value [Acc > NIR] : <2e-16

# Sensitivity : 0.9800
# Specificity : 0.9900
# Pos Pred Value : 0.9800
# Neg Pred Value : 0.9900

# 'Positive' Class : Virginica
```

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# R-code for Generating Tree Model for Iris Data

```r
require(rpart)
# create simple iris data set with only one binary outcome
# -5 removes 5th column from iris which is the three-level outcome we are not using here.
iristreedat<-iris[,-5]
require(rpart) # rpart is one package for generating trees
set.seed(510)
iristree<-rpart(formula = Species2 ~ ., data = iristreedat, method = "class", parms = list(split =
"information"), control = rpart.control(maxdepth = 10, usesurrogate = 0, maxsurrogate = 0))
#Plot the tree (ON NEXT SLIDE)
fancyRpartPlot(iristree, main="Decision Tree iristreedat $ Species2")

# Now apply the tree to generate the predicted classes for each
iristreepred<-predict(iristree, newdata=iristreedat[,c(1:4)], type="class")
iristreeconfuse<-confusionMatrix(iristreepred, iristreedat$Species2, positive=c("Virginica"))

# Alternative tree [via Party Package] (conditional tree that does not require a cp parameter)
set.seed(510)
iristree2<-ctree(Species2 ~ ., data = iristreedat)
plot(iristree2)
```

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

45

<!-- page 46 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Machine Learning in R via Rattle!

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

# Analyses of Big Data

* Classical Statistical Approaches versus Statistical Machine Learning
* Model Evaluation/Validation
* Popular machine learning techniques
  * K-Means Clustering
  * K Nearest Neighbors
  * CARTS
  * **Random Forests**

Buskirk and Kreuter, SYV 751

46

<!-- page 47 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: Random Forests

* What type of Learner?
  * Nonparametric method; Supervised Learner (if y)
  * Unsupervised learner if no y or don't use it
  * Random Forests fall under a class of learners called "Ensemble Methods"

* For what problems can you apply this method?
  * Regression/Prediction for Continuous Outcome Variables
  * Classification for Categorical Outcome Variables (2 or more levels)

0100000101000001010100000100111101010010SVY 751 Notes Big Data

# Method Overview: Random Forests

* Does this method have any Parameters?
  * Number of Trees (ntree)
  * # Variables to be randomly considered at each node (mtry)
  * Node sizes

* Insights on Parameters for this Method
  * Node size is typically 1 for classification and 5 (or more) for regression.
  * Generally, them more trees in the forest, the less error one has. But after a certain point, diminishing returns on error rate improvements are likely to be found in practice.
  * Larger values of mtry increases the strength of the tree, but also the correlation between the results of one tree from another in the forest.
  * Smaller values of mtry reduces the inter-tree correlation as well as the overall predictive strength of the tree.
    * Default mtry is set as $p/3$ for regression
    * Default mtry is set as $\sqrt{p}$ (rounded down) for classification

0100000101000001010100000100111101010010SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

47

<!-- page 48 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# How Do Random Forests Work?

**Step 1: Establish the Forest.** Generate $\text{n}_{\text{tree}}$ bootstrap samples from the original dataset with replacement and of the same size as the input dataset.

**Step 2: Grow Trees.** For each of the bootstrap samples drawn in Step 1, grow a classification/regression tree to full size (i.e. no pruning). But at **each** node of each of these trees, randomly select mtry of the predictor variables to be used as the basis of branching. Splits/branches are based on the best variable from among the mtry that are selected for a given node.

**Step 3: Prediction.** After all trees in the forest have been grown, form a prediction for new data from each tree in the same way as you would for normal classification or regression trees.

For forests based on regression trees, final predicted values for new data are computed as the mean of these $\text{n}_{\text{tree}}$ predicted values;

For forests based on classification trees, final predicted values for new data are computed as the class with the majority vote across the ntrees (where each tree in the forest contributes one vote for a single outcome class).

---

# Random Forests Illustrated...

* FEMALE?
  * WHITE?
    * EDUC<HS
      * NO
      * YES
    * NO
  * YES

* EDUC < HS?
  * WHITE?
    * YES
    * MALE?
      * NO
      * YES
  * YES

* FEMALE?
  * HISPANIC?
    * NO
    * WHITE?
      * YES
      * NO
  * YES

New Data: White, Hispanic Female with a BS Degree

* Tree 1: YES
* Tree 2: YES
* Tree 3: NO

Forest Uses Majority Rule: Prediction for New Data: YES

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

48

<!-- page 49 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Error Rate Estimation for Random Forests

- **How are error rates assessed for Random Forests?**
  - Unlike other machine learning methods that use some type of external test sample to assess performance, Random Forests generate an internally valid, and in many cases unbiased, assessment of error.
  - The error rate is typically referred to as the Out of Bag Error Rate (OOB Error Rate).

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

# Error Rate Estimation for Random Forests

- **How is the OOB Error Rate Computed?**
  - **Step 1:** Each tree in the forest uses approximately $2/3$ of the original data. For the remaining $1/3$ of cases, (called Out of Bag, OOB), use the given tree to make predictions. Call these "Out of Bag Predictions."
  - **Step 2:** For a given case, aggregate all "Out of Bag Predictions" across the roughly ntree/3 trees for which the case was OOB.
    - Averages for regression applications
    - Majority vote for classification applications.
  - **Step 3:** Compare the aggregated estimate from Step 2 to the actual value of the outcome for each case in the data set
    - Correct/Incorrect for Classification
    - Residual for Regression ($y_i - \text{Step 2 Estimate}$).
  - The OOB Error is the:
    - proportion of "incorrect" values from Step 3 (classification)
    - the average squared residuals from Step 3 (regression)

0100000101000001010100000100111101010010 SVY 751 Notes **Big Data**

Buskirk and Kreuter, SYV 751

49

<!-- page 50 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Random Forest Error Rate Illustrated

Case 1
OOB

Case 1
OOB
Case 1

Case 1
OOB
OOB
Case 1

Case 1
OOB

Case 1
OOB
OOB
Case 1

Case 1 is actually a nonrespondent (NO). The OOB Prediction for Case 1 is YES (2/3). This would be a MISCLASSIFIED/INCORRECT Prediction and would contribute to the numerator of the OOB Error rate.

# Method Overview: Random Forests

## Caveats/ Considerations for the Method

* For situations where the number of predictors is greater than the number of cases (n<<p), mtry values should be increased beyond the defaults.
  * See: https://samos.univ-paris1.fr/IMG/pdf_S1E1-Poggi.pdf
* Random Forests do not produce coefficients or significance tests for predictors. They do produce variable importance measures that can help rank order the utility of the variables in predicting the outcome.
* Random Forests don’t use surrogates like trees, so missing data must be dealt with
* Variable Importance measures can be biased if the predictor variables are either highly correlated or on different scales.
  * Suggest using Conditional Forests instead (Strobl et al., 2007)
  * See: http://www.biomedcentral.com/1471-2105/8/25

0100000101000001010100000100111101010010SVY 751 Notes Big Data

Buskirk and Kreuter, SYV 751

50

<!-- page 51 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Method Overview: Random Forests

* **Advantages of this Method**
  * Like Tree methods, Random Forests can handle predictors that are continuous, categorical, skewed and sparse data as well as missing data.
  * Random forests are also aptly suited for the "large p, small n" scenario (Strobl et al., 2007).
  * Random forests can also be very effective for estimating outcomes that are a complex functions of predictors with many interactions or possibly non-linear functions of the parameters (Mendez et al., 2008).
* **Disadvantages of this Method**
  * Random Forests can be computationally intensive.
  * Unlike Trees, Random Forests are not easily visualized.

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

# Method Overview: Random Forests

* **Implementation of this method in R**
  * `randomforest{randomForest package}`
  * `rfsrc{randomForestSRC + ggRandomForest packages}`
  * `cforest{party package}`
  * `CoreModel{CORElearn package}`
* **Examples of this method in the S.R. Literature**
  * **Response Propensity Weighting and Nonresponse Bias Evaluation**
    * Buskirk and Kolenikov (2015); http://surveyinsights.org/?p=5108
    * Buskirk, West and Burks (2013); http://bit.ly/1JVzgWt
  * **Hybird Ensemble Method for Response Propensity Scores and Nonresponse Bias evaluation for Establishment Surveys**
    * Earp, Mitchell, McCarthy and Kreuter (2014); http://bit.ly/1Pi4GIf
  * **Identifying important predictors of county-level CPO rates**
    * Buskirk, et al. (2014); http://bit.ly/1Jd3TXt

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

Buskirk and Kreuter, SYV 751

51

<!-- page 52 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Example 5: Random Forests for Classification

* **MSG Estimated County-Level CPO Rates for 3,142 Counties 2013 Q1**
  * classified as either CPO-HIGH/CPO-LOW based on whether the estimated county-level CPO rate was below the national average estimate (31.87%)
* **Demographic counts:**
  * Race, Sex, Ethnicity, Age, %HH with Children, Education, etc.
* **Economic Indicators**
  * Annual Median Income, # Vehicles/Household, Families below Poverty
* **Housing/Area Attributes**
  * Counts of Dwelling Units, Group Quarters,Families/Non-Families; Land Size
* **Proportion of residential addresses in the county in:**
  * Urban Clusters, Suburban Rings or Outlying Rural areas.
* **Spatial Correlation Index 2013 (Q1) CPO rates (Moran's I)**
* **Census' Low Response Indicator for the County**
* **Combinations of variables within and across these groups**
  * % AA HHs w/ Female Householder with Children, Single Dwelling Unit
* **More information is contained in Buskirk, et al. (2014): http://bit.ly/1Jd3TXt**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# OOB Performance Results for Random Forest Example

### OOB versus # Trees in the Forest

| Actual | PREDICTED LOW-CPO | PREDICTED HIGH-CPO |
| :--- | :---: | :---: |
| LOW-CPO | 1162 | 447 |
| HIGH-CPO | 416 | 1117 |
| Class Error | 0.2636 | 0.2858 |
| Overall OOB Error Rate = 27.47% | | |

### ROC Curve Based on OOB Predictions

Area Under the Curve (AUC) = 0.814

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

Buskirk and Kreuter, SYV 751

52

<!-- page 53 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Variable Importance for Random Forest Example

### Mean Decrease in Accuracy

* R01_lmiindex
* R01_low_response_score
* division
* R01_hus
* R01_myrhousebit
* R01_mobh
* R01_avaf
* R01_mown
* R01_phams
* R01_landsqm
* R01_mhi2534
* R01_landsqms
* R01_mren
* R01_ahf65p
* R01_abf65p
* R01_nha
* R01_pmams
* R01_ha
* R01_vm
* R01_pop10r

20 30 40 50

### Mean Decrease Gini Index

* R01_low_response_score
* R01_lmiindex
* R01_hus
* R01_avaf
* division
* R01_myrhousebit
* R01_mown
* R01_landsqm
* R01_mhi2534
* R01_mobh
* R01_phams
* R01_landsqms
* R01_pmams
* R01_mren
* R01_pmhihs
* R01_pmrens
* R01_pop10r
* R01_vm
* R01_mhih
* R01_pmhi1524s

0 10 30

0100000101000001010100000

*[Figure: The figure consists of two side-by-side dot plots comparing variable importance in a Random Forest model using "Mean Decrease in Accuracy" (x-axis from 20 to 50) on the left and "Mean Decrease Gini Index" (x-axis from 0 to 30+) on the right, against 20 predictor variables listed on the y-axes in descending order. The main pattern shows that a small group of top variables—highlighted in boxes, specifically `R01_lmiindex`, `R01_low_response_score`, `division`, and `R01_hus`—consistently rank as the most important predictors across both metrics before importance values taper off for the remaining variables.]*

<!-- page 54 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Random Forest Example, Cont.

* **The Moran's I values can be used to generate geospatial clusters including HH, HL, LH and LL**
  * **HH/LL indicates areas in which the county CPO rates are high/low and surrounded by other counties with high/low CPO rates, respectively.**

0100000101000001010100000100111101010010 **SVY 751 Notes Big Data**

---

# Scaled Census Low Response Score by CPO High/Low Status

| Summary Statistic | CPO Status no-low | CPO Status yes-high |
| :---: | :---: | :---: |
| mean | 18.37 | 20.17 |
| sd | 2.53 | 3.09 |
| IQR | 3.12 | 4.19 |
| Median | 17.84 | 19.66 |
| Min | 8.17 | 13.60 |
| Max | 31.33 | 34.19 |
| n | 1578 | 1564 |

```r
# Descriptive Statistics on Rescaled Census Response Score by CPO Status
numSummary(cpo2013[,"R01_low_response_score"], groups=cpo2013$cpohigh,
  statistics=c("mean", "sd", "IQR", "quantiles"), quantiles=c(.5,0,1))
#Look at the Scaled Census Low Response Score by CPO Status
cposhort<-data.frame(cpo2013$cpohigh, cpo2013$R01_low_response_score)
names(cposhort)<-c("cpohigh", "Census_LRS")
ggplot(data=cposhort, aes(x=Census_LRS, group=cpohigh, fill=cpohigh)) + geom_density(alpha=.3)
```

Buskirk and Kreuter, SYV 751

54

<!-- page 55 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# References

* AAPOR (2015). AAPOR Report on Big Data. Available Here: http://www.aapor.org/AAPORKentico/AAPOR_Main/media/Task-Force-Reports/BigDataTaskForceReport_FINAL_2_12_15.pdf
* Breiman, L., Friedman, J.H., Olshen, R.A. and Stone, C.J. (1984). *Classification and Regression Trees*. Pacific Grove: Wadsworth.
* Buskirk, T.D., West, B. T. and Burks, A.T (2013) “Respondents: Who Art Thou? Comparing Internal, Temporal, and External Validity of Survey Response Propensity Models Based on Random Forests and Logistic Regression Models.” Presented at the 2013 Joint Statistical Meetings of the American Statistical Association, Montreal, Canada.
* Buskirk, T.D., Bareham, J.S., Bordy, N. and Dalbey, D. (2014). “Exploring Demographic, Geospatial and Household Correlates of U.S. County-Level Household CPO Rates.” Presented at the 2014 MAPOR Annual Conference, Chicago, IL.
* Buskirk, T. D. & Kolenikov S. (2015). Finding Respondents in the Forest: A Comparison of Logistic Regression and Random Forest Models for Response Propensity Weighting and Stratification. *Survey Insights: Methods from the Field*, Weighting: Practical Issues and ‘How to’ Approach, Retrieved from http://surveyinsights.org/?p=5108
* Earp, M., Mitchell, M., McCarthy, J. and Kreuter, F. (2014). *Modeling Nonresponse in Establishment Surveys: Using an Ensemble Tree Model to Create Nonresponse Propensity Scores and Detect Potential Bias in an Agricultural Survey. Journal of Official Statistics*. Vol. 30(4), 701–719.
* Elliott, M. R. (2011). A Simple Method to Generate Equal-Sized Homogenous Strata or Clusters for Population-Based Sampling. *Annals of Epidemiology*, 21(4), 290–296. doi:10.1016/j.annepidem.2010.11.016
* Krantz, A. Korn, R. and Menninger, M. (2009). Rethinking Museum Visitors: Using K-means Cluster Analysis to Explore a Museum’s Audience. *Curator*. Vol. 52 (4), 363-374.
* Barcaroli, G. (2014). Optimization of sampling strata with the SamplingStrata package, available at: ftp://cran.r-project.org/pub/R/web/packages/SamplingStrata/vignettes/SamplingStrataVignette.pdf , accessed on March 31, 2015.
* McCarthy, J.T., Jacob, T. and Atkinson, D. (2009). Innovative Uses of Data Mining Techniques in the Production of Official Statistics. *Federal Committee on Statistical Methodology Papers*, accessed from https://fcsm.sites.usa.gov/files/2014/05/2009FCSM_McCarthy_X-A.pdf , April 1, 2015
* Mendez, G., Buskirk, T.D., Lohr, S. and Haag, S. (2008) Factors Associated with Persistence in Science and Engineering Majors: An Exploratory Study Using Random Forests. *Journal of Engineering Education*. Vol. 97, No.1, pp. 57-70. See: http://bit.ly/1EULVv4
* Mesa D.M., Tsai P., Chambers R.L. (2000). *Using Tree-Based Models for Missing Data Imputation: an Evaluation Using UK Census Data*. Report, University of Southampton.
* Molinaro AM, Simon R, Pfeiffer RM. (2005). Prediction error estimation: a comparison of resampling methods. *Bioinformatics*, 21(15):3301-7. See: http://bit.ly/1bWRCLG
* Ratner, B. (2012) Statistical and Machine-Learning Data Mining, $2^{\text{nd}}$ Ed. CRC Press, Boca Raton.
* Schouten, B., Calinescu, M. and Luiten, A. (2013). Optimizing quality of response through adaptive survey designs. *Survey Methodology*, 39(1), 29-58.
* Wagner, J. and Hubbard, F. (2014). Producing Unbiased Estimates of Propensity Models During Data Collection. *Journal of Survey Statistics and Methodology*, 2(3), 323-342.

0100000101000001010100000100111101010010 SVY 751 Notes Big Data

# Appendix 2: Variable Description for Final 56 Predictors for Random Forest Example

**Note 1:** Each of the predictors were rescaled to be on the same scale – $[0, 1]$ by subtracting the minimum value of the predictor from each case and dividing this difference by the range of the predictor. In the R dataset cpo2013, the rescaled variables names have the prefix “R01_” to indicate they have been rescaled.

**Note 2:** Variables ending in “M” represent the county mean of the variable computed as the average value of the variable across all the block groups in the county. If the variable name ends in “S” the predictor represents the Standard Deviation of the specified variable computed as the standard deviation of the variable across all block groups in the county.

| Predictor | Variable Name | Label |
| :---: | :--- | :--- |
| 1 | LMiIndex | Moran's I Geospatial Similarity Measure |
| 2 | division | Census Division |
| 3 | MYRHouseBlt | Current Year Median Year, Housing Unit Structure Built |
| 4 | Low_Response_Score | Census Low Response Score |
| 5 | HUS | Current Year Housing Units STD |
| 6 | AVAF | Current Year Average Age, Female |
| 7 | MOWN | Current Year Median Householder Years of Residence, Owner-Occupied Housing Units |
| 8 | MHI2534 | Current Year Median Household Income, Householder Age 25 - 34 |
| 9 | MOBH | Current Year Housing Units, Mobile Home |
| 10 | LANDSQM | Land Area in Square Miles |
| 11 | PMHIHS | Current Year Median Household Income, Hispanic/Latino Householder STD |
| 12 | HA | Current Year Average Household Size |
| 13 | NHA | Current Year Average Household Size, NonFamily Household |
| 14 | PHAMS | Current Year Median Age, Householder STD |
| 15 | LANDSQMS | Land Area in Square Miles STD |

Buskirk and Kreuter, SYV 751

55

<!-- page 56 -->

Notes are for STUDENT USE ONLY. DO NOT circulate without permission from Instructors.

1/29/2016

# Appendix 2 cont. Variable Description for Final 56 Predictors for Random Forest Example

| Predictor | Variable Name | Label |
| :---: | :--- | :--- |
| 16 | PMAMS | Current Year Median Age, Male STD |
| 17 | MREN | Current Year Median Householder Years of Residence, Renter-Occupied Housing Units |
| 18 | POPS | Current Year Population STD |
| 19 | AHF65P | Current Year Population, Hispanic/Latino, Female: Age 65+ |
| 20 | PMHI85PS | Current Year Median Household Income, Householder Age 85+ STD |
| 21 | ABF65P | Current Year Population, Black/African American Alone, Female: Age 65+ |
| 22 | PMHI1524S | Current Year Median Household Income, Householder Age 15 - 24 STD |
| 23 | VM | Current Year Median Value, Owner-Occupied Housing Units |
| 24 | POP10R | Census 2010 Population : Rural (Non-Urban) |
| 25 | MHI1524 | Current Year Median Household Income, Householder Age 15 - 24 |
| 26 | PGQOTHS | Current Year Group Quarters Population, Institutional: Other Facilities STD |
| 27 | PMRENS | Current Year Median Householder Years of Residence, Renter-Occupied Housing Units STD |
| 28 | PMRESS | Current Year Median Householder Years of Residence STD |
| 29 | MHI85P | Current Year Median Household Income, Householder Age 85+ |
| 30 | GQPOPS | Current Year Group Quarters Population STD |
| 31 | PCT_U1 | City Center, Urban |
| 32 | UOTH | Current Year Housing Units, Other Unit Type |
| 33 | GQOTH | Current Year Group Quarters Population, Institutional: Other Facilities |
| 34 | PMHI7584S | Current Year Median Household Income, Householder Age 75 - 84 STD |
| 35 | PCT_S2 | Mid Suburbs |
| 36 | PMHINHS | Current Year Median Household Income, Not Hispanic/Latino Householder STD |
| 37 | PV2040S | Current Year Owner-Occupied Housing Units, Value \$20,000 - \$39,999 STD |

# Appendix 2 cont. Variable Description for Final 56 Predictors for Random Forest Example

| Predictor | Variable Name | Label |
| :---: | :--- | :--- |
| 38 | PVMS | Current Year Median Value, Owner-Occupied Housing Units STD |
| 39 | PCT_R | ALL Rural |
| 40 | V4060 | Current Year Owner-Occupied Housing Units, Value \$40,000 - \$59,999 |
| 41 | V1MP | Current Year Owner-Occupied Housing Units, Value \$1,000,000+ |
| 42 | MHIH | Current Year Median Household Income, Hispanic/Latino Householder |
| 43 | U1A | Current Year Housing Units, 1 Unit Attached |
| 44 | PMYRBS | Current Year Median Year, Housing Unit Structure Built STD |
| 45 | GQCOL | Current Year Group Quarters Population, Noninstitutional: College/University Student Housing |
| 46 | PMHI2534S | Current Year Median Household Income, Householder Age 25 - 34 STD |
| 47 | U2 | Current Year Housing Units, 2 Units |
| 48 | AAF65P | Current Year Population, Asian Alone, Female: Age 65+ |
| 49 | PCT_U2 | ALL Other, Urban |
| 50 | PCT_S1 | Inner Suburbs |
| 51 | POP10UC | Census 2010 Population : Urban : Urban Cluster |
| 52 | WTPT | Current Year Workers, Transportation To Work: Public Transport |
| 53 | WTB | Current Year Workers, Transportation To Work: Bicycle |
| 54 | FAF | Current Year Population 16+, Female: Armed Forces |
| 55 | PCT_S3 | Outer Suburbs |
| 56 | NFFC | Current Year Households, w/ People < 18 Years Old, NonFamily Household, Female Householder |

0100000101000001010100
