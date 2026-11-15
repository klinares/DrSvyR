---
id: "jpsm/Fund_data_collection_SURV622/lectures/Lecture-ML"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lecture"
title: "Introduction to Machine Learning"
original: "Fund_data_collection_SURV622/lectures/Lecture-ML.pdf"
pages: 89
sha256: "a01f0b312942ec4655ec6899474bb326d3e0d2c914016c927fd9fb257d0c1593"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:02"
---

<!-- page 1 -->

# Introduction to Machine Learning

Machine Learning

<!-- page 2 -->

# What is Machine Learning?

There are many possible definitions.

One definition: **Machine learning** is when a machine (that is, a computer) **improves** on a **task** with respect to some **performance measure**.

Examples:
* Self-driving cars
* Facial recognition
* Targeted Ads

Machine Learning 2 / 75

<!-- page 3 -->

How does Machine Learning work?

# How does Machine Learning work?

Machine Learning

<!-- page 4 -->

How does Machine Learning work?

# Illustrative Example

Suppose a car company wants to decide which cars to buy ad time for in the next Super Bowl. They have a dataset of cars promoted in past Super Bowl ads, and information about the **miles per gallon** (`mpg`) and **horsepower** (`hp`) of each car. In addition, they know which ad campaigns were deemed **"Successful"** or **"Unsuccessful."** Which cars should the company buy ad time for?

Machine Learning 4 / 75

<!-- page 5 -->

How does Machine Learning work?

# Illustrative Example

Suppose a car company wants to decide which cars to buy ad time for in the next Super Bowl. They have a dataset of cars promoted in past Super Bowl ads, and information about the **miles per gallon** (`mpg`) and **horsepower** (`hp`) of each car. In addition, they know which ad campaigns were deemed **"Successful"** or **"Unsuccessful."** Which cars should the company buy ad time for?

At its heart, this is a **prediction** problem. In order to **decide which cars to buy ad time for**, we want to use **data from previous ad campaigns** to make a **prediction** on which cars will have successful ad campaigns.

Machine Learning

<!-- page 6 -->

How does Machine Learning work?

# Machine Learning in Context

Machine learning is when a machine (that is, a computer) **improves** on a **task** with respect to some **performance measure**.

In the case of **supervised learning** for Super Bowl car advertisements, we want to develop a way to **improve** how well we **predict future successful car advertisements**.

Machine Learning

<!-- page 7 -->

How does Machine Learning work?

# Visualizing the Data

Horsepower
* 300
* 200
* 100

Miles per Gallon
* 10
* 15
* 20
* 25
* 30
* 35

Outcome
* Successful
* Unsuccessful

Machine Learning

*[Figure: The figure is an empty coordinate grid with "Miles per Gallon" (ranging from 10 to 35) on the horizontal axis and "Horsepower" (ranging from 100 to 300) on the vertical axis. A legend on the right indicates two outcome groups, "Successful" and "Unsuccessful," though no data points or symbols are currently plotted to show any pattern.]*

<!-- page 8 -->

How does Machine Learning work?

# Prediction

To do this, we'll use **machine learning**. More specifically, this is a subset of machine learning called **supervised learning**.

Two branches of machine learning:

* **Unsupervised Learning** is when you have no **outcome variable** and are trying to create groupings based on the data.
* **Supervised Learning** is when you have an **outcome variable**, and you try to make a prediction about future data points.

Machine Learning

<!-- page 9 -->

How does Machine Learning work?

# General Supervised Learning Framework

In supervised learning, we are focused on finding the relationship between a **label** y and **features** x.

$$y = f(x)$$

**"Learning"** is finding a function $f$ that minimizes **future error** in recovering y.

In our case, we will use **decision trees** to find that function $f$ to minimize future error when trying to determine **success of car advertisement campaigns** (y) based on **MPG and HP** (x)

Machine Learning 8 / 75

<!-- page 10 -->

How does Machine Learning work?

# Linear Regression as Machine Learning?

Think about finding a **least squares regression line** to show the relationship between **two numerical variables** and **predict** values of the **outcome variable**.

$$
y = f(x)
$$

The regression line fits this definition of **machine learning**. The "$f(x)$" in this case takes the form of a linear regression line.

Machine Learning

<!-- page 11 -->

How does Machine Learning work?

# The Model Building Process

* **Explore** the data. (Descriptive statistics, visualizations)
* **Prepare** the data. (Data cleaning, generate features and labels)
* **Split** the data into training and test sets. (cross-validation, holdout samples)
* **Train** the model on the training set. (Logistic Regression, Decision Tree, K-Nearest Neighbors algorithm)
* **Predict** on the test set and **evaluate** based on certain metrics. (precision, recall)
* **Repeat and Conclusions**

Machine Learning 10 / 75

<!-- page 12 -->

Machine Learning Applications

# Machine Learning Applications

Machine Learning

<!-- page 13 -->

Machine Learning Applications

# Machine Learning Applications

**Predictive Modeling for Public Health: Preventing Childhood Lead Poisoning.** *Potash et al. 2015*

* Lead Poisoning is a big issue for children living in old homes with lead paint.
* Blood tests can identify elevated lead levels ... but by then, it’s too late.
* Use Machine Learning to predict risk of a child being poisoned to provide intervention.

Machine Learning

<!-- page 14 -->

# Machine Learning Applications

**Automated Injury Coding.** *Measure 2014*

- Written descriptions of injuries in the workplace.
- Goal: Code injuries from narratives.
- About 85% of primary codes are assigned using ML.

<!-- page 15 -->

Machine Learning Applications

# Machine Learning Applications

**A Longitudinal Framework for Predicting Nonresponse in Panel Surveys.** *Kern et al. 2019*

* Goal: Predict nonresponse in panel surveys to proactively provide incentives.
* Used data from previous responses to predict nonresponse.

Machine Learning 14 / 75

<!-- page 16 -->

Machine Learning Applications

# Other Machine Learning Applications

Machine Learning can also be used to improve data in other ways.

* Record Linkage (e.g., Christen 2008)
* Imputation (e.g., Batista and Monard 2002)
* Unsupervised Learning for Text Analysis (e.g., Latent Dirichlet Allocation)

Machine Learning

<!-- page 17 -->

Machine Learning Applications

# Why Machine Learning?

**Goal**: Build adaptable and scalable systems that are effective and easy to maintain.

**Adaptable**: Relationships may change over time.

**Easy to Maintain**: Rule-based systems may become cumbersome and difficult to update.

Machine Learning

<!-- page 18 -->

Example Using Decision Trees

# Example Using Decision Trees

Machine Learning

<!-- page 19 -->

Example Using Decision Trees

# How it Works

**Rough outline of the tree building algorithm**

- Consider each feature (in this case, horsepower and MPG).
- Order the values in each feature.
- Compute a measure of how well a partition would split the data for each possible break between values.
- Make the split that maximizes this value.
- Repeat until you reach a stopping criteria.

Machine Learning

<!-- page 20 -->

Example Using Decision Trees

# Tree Diagram

* **1**: Successful (.56 .44, 100%)
  * *yes* (**hp >= 137**):
    * **2**: Successful (1.00 .00, 47%)
  * *no* (**hp >= 137**):
    * **3**: Unsuccessful (.18 .82, 53%)
      * **mpg < 21** (left):
        * **6**: Unsuccessful (.40 .60, 16%)
          * **mpg >= 20** (left):
            * **12**: Successful (1.00 .00, 6%)
          * **mpg >= 20** (right):
            * **13**: Unsuccessful (.00 1.00, 9%)
      * **mpg < 21** (right):
        * **7**: Unsuccessful (.08 .92, 38%)

Machine Learning 19 / 75

<!-- page 21 -->

Example Using Decision Trees

# Partitioning

300

200

100

Horsepower

10 15 20 25 30 35

Miles per Gallon

Outcome

Successful

Unsuccessful

Machine Learning 20 / 75

*[Figure: The figure shows a two-dimensional coordinate plot illustrating feature space partitioning, with "Miles per Gallon" (ranging from 10 to 35) on the horizontal axis and "Horsepower" (ranging from 100 to 300) on the vertical axis. Although a legend lists two outcome groups—"Successful" and "Unsuccessful"—no individual data points are plotted, and the main feature is a horizontal dashed line across the plot at approximately 135 Horsepower that divides the space into two regions.]*

<!-- page 22 -->

Example Using Decision Trees

# Partitioning

Horsepower
* 300
* 200
* 100

Miles per Gallon
* 10
* 15
* 20
* 25
* 30
* 35

### Outcome
* Successful
* Unsuccessful

Machine Learning 21 / 75

*[Figure: The figure shows a two-dimensional coordinate grid illustrating decision tree partitioning, with "Miles per Gallon" (ranging from 10 to 35) on the horizontal axis and "Horsepower" (ranging from 100 to 300) on the vertical axis, accompanied by a legend for "Successful" and "Unsuccessful" outcomes. Although no data points are plotted, the feature space is divided into three distinct regions by a horizontal dashed line around 135 Horsepower and a vertical dashed line around 21 Miles per Gallon extending down from the horizontal split.]*

<!-- page 23 -->

Example Using Decision Trees

# Partitioning

300

200

100

Horsepower

10

15

20

25

30

35

Miles per Gallon

Outcome

Successful

Unsuccessful

Machine Learning

*[Figure: The plot shows a coordinate space with "Miles per Gallon" (from 10 to 35) on the horizontal axis and "Horsepower" (from 100 to 300) on the vertical axis, alongside a legend comparing "Successful" and "Unsuccessful" outcome groups. Although no data points are visible, the main pattern illustrates decision tree partitioning using a horizontal dashed line around 135 Horsepower and two vertical dashed lines extending downward from that threshold near 20 and 21.5 Miles per Gallon.]*

<!-- page 24 -->

Example Using Decision Trees

# Tuning a Tree

Note that there are multiple places where we need to make decisions on parameters for building a tree.

- Measure for optimal splitting (Gini impurity, information gain).
- Minimum node size for stopping splits.
- Max depth

How should we determine each of these parameters?

By using a **training** set and a **testing** set.

Machine Learning

<!-- page 25 -->

Splitting into Train/Test Sets

# Splitting into Train/Test Sets

Machine Learning 24 / 75

<!-- page 26 -->

Splitting into Train/Test Sets

# Motivation

Suppose we have a machine learning model (e.g. decision trees). How do we know it can **generalize** to the overall population?

That is, we know that the model fits well on the data we used ... precisely because we fit it on that data. How do we know it will predict **future** data points well?

Machine Learning

<!-- page 27 -->

Splitting into Train/Test Sets

# Example

Horsepower
300
200
100

10 15 20 25 30 35
Miles per Gallon

Outcome
Successful
Unsuccessful

Machine Learning

*[Figure: The figure shows a plot grid with "Miles per Gallon" (from 10 to 35) on the horizontal axis and "Horsepower" (from 100 to 300) on the vertical axis, along with a legend for "Outcome" comparing "Successful" and "Unsuccessful" groups. Although no data points are plotted, the grid is partitioned by dashed black lines indicating decision boundaries: a horizontal line around 135 Horsepower and two vertical lines below it near 20 and 21 Miles per Gallon.]*

<!-- page 28 -->

Splitting into Train/Test Sets

# Overfitting

The main issue is that our model isn't **generalizable** to the overall population because it is fit to be **too specific to our data**. This is called **overfitting**.

Machine Learning 27 / 75

<!-- page 29 -->

Splitting into Train/Test Sets

# Validation

In order to make sure our results are generalizable, we typical **hold out** a portion of our data to **test** the model on. That is, we split our data into two subsets:

* The **training set** is the subset that we use to build the model on.
* The **test set** is the subset that we use to evaluate how well our model is doing.

Machine Learning

<!-- page 30 -->

Splitting into Train/Test Sets

# Train/Test Split Intuition

Another way to think about it: we want to be sure that our model works well if we apply it to new data.

So, we are pretending we only have a portion of the data, and treating a smaller subset of it as the "new data".

Machine Learning

<!-- page 31 -->

Splitting into Train/Test Sets

# Holdout Sample

Probably the simplest method is to do a **holdout sample**. This consists of splitting the dataset into two groups — the **train set** and the **test set** — randomly. The train set is typically smaller than the train set, since we want to use as much of the data as possible on fitting the model.

Machine Learning

<!-- page 32 -->

Splitting into Train/Test Sets

# Example

Suppose we have a dataset of $10,000$ observations about homes in Chicago, and we want to be able to predict which homes will have the highest risk of containing lead poisoning hazards.

How would we approach this?

Machine Learning 31 / 75

<!-- page 33 -->

Splitting into Train/Test Sets

# Example

Suppose we have a dataset of $10,000$ observations about homes in Chicago, and we want to be able to predict which homes will have the highest risk of containing lead poisoning hazards.

How would we approach this?

Our population is Chicago homes. We want to predict homes in Chicago that have the highest risk of lead poisoning. Since we want to be able to predict this *in advance*, we build a model that can generalize to all homes in Chicago. We take a sample of $8,000$ homes from our dataset, build the models on those $8,000$ homes, then test to evaluate how well our models perform on the remaining $2,000$

Machine Learning 31 / 75

<!-- page 34 -->

Splitting into Train/Test Sets

# Selecting the Train/Test Split

The holdout sample gives us a random split of the data, so that a portion of it is reserved for testing.

But what if the test set that we choose just happens to be unusual in some way due to random chance?

Machine Learning

<!-- page 35 -->

Splitting into Train/Test Sets

# Cross-Validation

A popular method is **k-fold cross-validation**. To do k-fold cross validation, you

1. **Split the data** into $k$ equal partitions.
2. Designate one partition as the **test set** and the rest as the **training test**.
3. **Fit the model** using the training set and evaluate on the test set.
4. **Choose another** of the remaining partitions that you haven't set aside as a test set yet.
5. **Repeat** until every single partition has been a test set once.

Machine Learning

<!-- page 36 -->

Splitting into Train/Test Sets

# Example: Three-fold Cross-Validation

To do a **three-fold cross-validation**, you first split the data into three equal parts. Let's call them **A, B, and C**.

| A | B | C |
| :---: | :---: | :---: |

First, you fit the model on **B** and **C**, then test on **A**.

Then, you fit the model on **A** and **C**, then test on **B**.

Finally, you fit the model on **A** and **B**, then test on **C**.

Machine Learning

<!-- page 37 -->

Splitting into Train/Test Sets

# Other Methods

There are many possible ways to validate your results.

* Leave one out cross validation
* Random subsampling
* Temporal holdouts

Machine Learning

<!-- page 38 -->

Machine Learning Evaluation

# Machine Learning Evaluation

Machine Learning

<!-- page 39 -->

Machine Learning Evaluation

# Motivation

Suppose we have a machine learning model (e.g. decision trees) that we fit on a **training set**, and we need to now evaluate it on the **test set**. How should we do this?

Machine Learning 37 / 75

<!-- page 40 -->

# Example

Suppose the following cars were in the test set.

| Horsepower | Miles Per Gallon | Outcome |
| :---: | :---: | :---: |
| 200 | 15 | Success |
| 100 | 15 | Failure |
| 150 | 25 | Success |
| 122 | 31 | Failure |
| 110 | 12 | Failure |
| 304 | 11 | Failure |
| 283 | 15 | Failure |

<!-- page 41 -->

Machine Learning Evaluation

# Example

Using the training set, we built a model, and produced the following predictions

| Horsepower | Miles Per Gallon | Outcome | Prediction |
| :---: | :---: | :---: | :---: |
| 200 | 15 | Success | Success |
| 100 | 15 | Failure | Failure |
| 123 | 25 | Success | Failure |
| 122 | 31 | Failure | Failure |
| 110 | 12 | Failure | Failure |
| 304 | 11 | Failure | Success |
| 283 | 15 | Failure | Success |

Machine Learning

<!-- page 42 -->

Machine Learning Evaluation

# Confusion Matrix

We can express the **predicted** and **actual** outcomes in a two-by-two table instead.

| | Success | Failure |
| :---: | :---: | :---: |
| Predicted Success | 1 | 2 |
| Predicted Failure | 1 | 3 |

Machine Learning

<!-- page 43 -->

Machine Learning Evaluation

# Accuracy

Accuracy is given

$$\text{Accuracy} = \frac{\text{True Positive} + \text{True Negative}}{\text{All Predictions}}$$

Machine Learning

<!-- page 44 -->

Machine Learning Evaluation

# Accuracy

Accuracy is given

$$\text{Accuracy} = \frac{\text{True Positive} + \text{True Negative}}{\text{All Predictions}}$$

Example:

| | Success | Failure |
| :---: | :---: | :---: |
| Predicted Success | 1 | 2 |
| Predicted Failure | 1 | 3 |

Machine Learning

<!-- page 45 -->

Machine Learning Evaluation

# Accuracy

Accuracy is given

$$\text{Accuracy} = \frac{\text{True Positive} + \text{True Negative}}{\text{All Predictions}}$$

Example:

| | Success | Failure |
| :---: | :---: | :---: |
| Predicted Success | 1 | 2 |
| Predicted Failure | 1 | 3 |

$$\text{Accuracy} = \frac{1 + 3}{1 + 2 + 1 + 3} = \frac{4}{7}$$

Machine Learning

<!-- page 46 -->

Machine Learning Evaluation

# Accuracy Can Be Misleading!

Generally, **accuracy** is actually **NOT** a good measure.

Machine Learning

<!-- page 47 -->

Machine Learning Evaluation

# Accuracy Can Be Misleading!

Generally, **accuracy** is actually **NOT** a good measure.

**Example:** Suppose you want to detect credit card fraud to decide which accounts to shut down. It is estimated that 99.9% of accounts are not fraudulent.

Machine Learning

<!-- page 48 -->

Machine Learning Evaluation

# Accuracy Can Be Misleading!

Generally, **accuracy** is actually **NOT** a good measure.

**Example:** Suppose you want to detect credit card fraud to decide which accounts to shut down. It is estimated that 99.9% of accounts are not fraudulent.

Predicting every single account to be not fraudulent gives you a 99.9% accuracy ... but this isn't helpful at all.

Machine Learning

<!-- page 49 -->

Machine Learning Evaluation

# Precision

Precision is given by

$$\text{Precision} = \frac{\text{True Positive}}{\text{All Positive Predictions}}.$$

In words, **precision** is how correct your positive predictions are.

Machine Learning

<!-- page 50 -->

Machine Learning Evaluation

# Precision

Precision is given by

$$\text{Precision} = \frac{\text{True Positive}}{\text{All Positive Predictions}}.$$

In words, **precision** is how correct your positive predictions are.

**Example:**

| | Success | Failure |
| :---: | :---: | :---: |
| Predicted Success | 1 | 2 |
| Predicted Failure | 1 | 3 |

Machine Learning

<!-- page 51 -->

Machine Learning Evaluation

# Precision

Precision is given by

$$\text{Precision} = \frac{\text{True Positive}}{\text{All Positive Predictions}}.$$

In words, **precision** is how correct your positive predictions are.

**Example:**

| | Success | Failure |
|---|---|---|
| Predicted Success | 1 | 2 |
| Predicted Failure | 1 | 3 |

$$\text{Precision} = \frac{1}{1 + 2} = 0.333$$

Machine Learning 43 / 75

<!-- page 52 -->

Machine Learning Evaluation

# Recall

Recall is given by

$$
\text{Recall} = \frac{\text{True Positive}}{\text{All Actual Positives}}.
$$

In words, **recall** is how many **positives** you were able to recover.

Machine Learning

<!-- page 53 -->

Machine Learning Evaluation

# Recall

Recall is given by

$$
\text{Recall} = \frac{\text{True Positive}}{\text{All Actual Positives}}.
$$

In words, **recall** is how many **positives** you were able to recover.

**Example:**

| | Success | Failure |
|---|---|---|
| Predicted Success | 1 | 1 |
| Predicted Failure | 1 | 3 |

Machine Learning

<!-- page 54 -->

Machine Learning Evaluation

# Recall

Recall is given by

$$\text{Recall} = \frac{\text{True Positive}}{\text{All Actual Positives}}.$$

In words, **recall** is how many **positives** you were able to recover.

**Example:**

| | Success | Failure |
|---|---|---|
| Predicted Success | 1 | 1 |
| Predicted Failure | 1 | 3 |

$$\text{Recall} = \frac{1}{1 + 1} = 0.5$$

Machine Learning

<!-- page 55 -->

Machine Learning Evaluation

# What's Good?

In general, there is no standard for what constitutes a "good" **precision** or **recall**. It all depends on your frame of reference.

**Example:** Suppose you want to detect credit card fraud to decide which accounts to shut down. It is estimated that 99.9% of accounts are not fraudulent.

Machine Learning

<!-- page 56 -->

Machine Learning Evaluation

# What's Good?

In general, there is no standard for what constitutes a "good" **precision** or **recall**. It all depends on your frame of reference.

**Example:** Suppose you want to detect credit card fraud to decide which accounts to shut down. It is estimated that 99.9% of accounts are not fraudulent.

If we chose fraudulent accounts **at random**, we'd have a **precision** of about 0.1%. So, a **model with 10% precision** would be excellent, because that means the model gives you a **100x lift** over random chance.

Machine Learning

<!-- page 57 -->

Machine Learning Evaluation

# What's Good?

**Example:** Suppose you want to detect credit card fraud to decide which accounts to shut down. It is estimated that 99.9% of accounts are not fraudulent. Would a model with **10% recall** be considered good?

Machine Learning 46 / 75

<!-- page 58 -->

Machine Learning Evaluation

# What's Good?

**Example:** Suppose you want to detect credit card fraud to decide which accounts to shut down. It is estimated that 99.9% of accounts are not fraudulent. Would a model with **10% recall** be considered good?

If we chose 1% of all accounts **randomly** to flag as fradulent, then our **recall** would be 1%. If our model flags 1% of all counts as fraudulent and our recall is 10%, it is giving us a **10x lift** over random chance.

Machine Learning 46 / 75

<!-- page 59 -->

# What to Use?

Which metric matters more depends on what you care about.

**Recall**: Suppose a car company wants to decide which cars to buy ad time for in the next Super Bowl. They have a dataset of cars promoted in past Super Bowl ads, and information about the **miles per gallon** (`mpg`) and **horsepower** (`hp`) of each car. In addition, they know which ad campaigns were deemed **"Successful"** or **"Unsuccessful."** Which cars should the company buy ad time for?

<!-- page 60 -->

Machine Learning Evaluation

# What to Use?

Which metric matters more depends on what you care about.

**Recall**: Suppose a car company wants to decide which cars to buy ad time for in the next Super Bowl. They have a dataset of cars promoted in past Super Bowl ads, and information about the **miles per gallon** (`mpg`) and **horsepower** (`hp`) of each car. In addition, they know which ad campaigns were deemed **"Successful"** or **"Unsuccessful."** Which cars should the company buy ad time for?

In this case, we might want to use **precision** because Super Bowl ads are expensive.

Machine Learning

<!-- page 61 -->

Machine Learning Overview

# Machine Learning Overview

Machine Learning

<!-- page 62 -->

Machine Learning Overview

# The Model Building Process Revisited

- **Explore** the data. (Descriptive statistics, visualizations)
- **Prepare** the data. (Data cleaning, generate features and labels)
- **Split** the data into training and test sets. (cross-validation, holdout samples)
- **Train** the model on the training set. (Logistic Regression, Decision Tree, K-Nearest Neighbors algorithm)
- **Predict** on the test set and **evaluate** based on certain metrics. (precision, recall)
- **Repeat and Conclusions**

Machine Learning

<!-- page 63 -->

Machine Learning Overview

# The Model Building Process

* **Explore** the data. (Descriptive statistics, visualizations)
* **Prepare** the data. (Data cleaning, generate features and labels)
* **Split** the data into training and test sets. (cross-validation, holdout samples)
* **Train** the model on the training set. (decision tree algorithm)
* **Predict** on the test set and **evaluate** based on certain metrics. (precision, recall)
* **Repeat**

Machine Learning 50 / 75

<!-- page 64 -->

Machine Learning Overview

# Machine Learning

This general structure applies to more than just decision trees — you can use it with any machine learning algorithm, or just anything that outputs a prediction.

Other models/algorithms to try are:
* Logistic Regression
* Support Vector Machines
* Random Forests
* Boosting
* ... and more!

Machine Learning 51 / 75

<!-- page 65 -->

# K-Nearest Neighbors

Machine Learning

<!-- page 66 -->

K-Nearest Neighbors

# Example: Chronic Kidney Disease

Doctors want to know whether their patients are at risk for developing chronic kidney disease (CKD). They have a dataset of many patients with measurements from a blood test, as well as whether the patients developed CKD. We want to develop a model to predict whether a patient will get CKD using just the information from the blood test.

Machine Learning

<!-- page 67 -->

K-Nearest Neighbors

# Intuition

**Intuition behind K-Nearest Neighbors:** When predicting future data, we might want to consider how other similar observations might have performed in the past.

**Example:** When trying to predict whether a patient will develop chronic kidney disease, we might want to think about whether patients with similar blood test results got CKD.

Machine Learning

<!-- page 68 -->

K-Nearest Neighbors

# K-Nearest Neighbors Algorithm

Find the data point that is closest to the one you want to predict.

The predicted class is the class of the nearest data point.

Machine Learning

<!-- page 69 -->

# Data

<!-- page 70 -->

K-Nearest Neighbors

# Prediction using K-Nearest Neighbors

Machine Learning

<!-- page 71 -->

K-Nearest Neighbors

# K-Nearest Neighbors

This shows how we might predict any new data point. We might be more interested in the **overall model**. That is, given any input, what would be our predicted output?

We can describe this model using a **decision boundary**.

Machine Learning

<!-- page 72 -->

K-Nearest Neighbors

# The K-Nearest Neighbors Model

Machine Learning

<!-- page 73 -->

# K-Nearest Neighbors

What we've described is actually 1-Nearest Neighbors. Usually, we choose a number of closest points and use those together to determine predicted class.

For example, we might set $k = 5$ and choose five closest points and predict using a "vote" of those classes.

<!-- page 74 -->

K-Nearest Neighbors

# Another Example

Machine Learning 61 / 75

<!-- page 75 -->

K-Nearest Neighbors

# Considerations

**Choosing K**

* We want to choose K to minimize **overfitting**.
* K is arbitrary! You may want to try multiple values to see which performs best.
* Use an odd number (to avoid ties)

Machine Learning

<!-- page 76 -->

Bias and Fairness in Machine Learning

# Bias and Fairness in Machine Learning

Machine Learning

<!-- page 77 -->

Bias and Fairness in Machine Learning

# Bias and Fairness in ML

**Remember**: Your machine learning models will only be as good as the data you give it!

This is particularly important remember in social science research, where you need be very careful about the possibility of bias and think about issues of fairness when implementing policy/action based on your ML models.

Machine Learning

<!-- page 78 -->

Bias and Fairness in Machine Learning

# Some Myths

**Myth**: Since Machine Learning models are designed to be objective and are based on data — which itself is always true — they will always be fair.

**Myth**: If I don't use race in my analysis, then my analysis can't be racist. (Also applies sex and sexist, etc.)

**Myth**: If I use race in my analysis, then my analysis is always racist. (Also applies sex and sexist, etc.)

Machine Learning

<!-- page 79 -->

Bias and Fairness in Machine Learning

# Bias in ML

The **process** might not necessarily be biased, but the data you provide and the approach to the research question **most definitely can be**.

As researchers, we need to be careful about this. "Unfair" models can come up even when we aren't trying to build them in an unfair way.

Machine Learning

<!-- page 80 -->

Bias and Fairness in Machine Learning

# Example: Chronic Kidney Disease

Doctors want to know whether their patients are at risk for developing chronic kidney disease (CKD). They have a dataset of many patients with measurements from a blood test, as well as whether the patients developed CKD. We want to develop a model to predict whether a patient will get CKD using just the information from the blood test.

Machine Learning 67 / 75

<!-- page 81 -->

Bias and Fairness in Machine Learning

# Considerations

**One extreme example:** Suppose we found out that the study had only enrolled white males. We wouldn't be able to generalize to the overall population, and the study results could only be applied to white males.

But even if we make sure to include a mix of people from different backgrounds, we can be in trouble of building a biased model.

Machine Learning

<!-- page 82 -->

Bias and Fairness in Machine Learning

# CKD Example

Doctors want to know whether their patients are at risk for developing chronic kidney disease (CKD). They enroll patients from a variety of backgrounds randomly chosen to **represent the overall population** and choose the **model with the best precision** (precision = 0.92).

What could go wrong with this scenario?

Machine Learning 69 / 75

<!-- page 83 -->

Bias and Fairness in Machine Learning

# CKD Example

Doctors want to know whether their patients are at risk for developing chronic kidney disease (CKD). They enroll patients from a variety of backgrounds randomly chosen to **represent the overall population** and choose the **model with the best precision** ($\text{precision} = 0.92$).

What could go wrong with this scenario?

What if precision for **white patients** was $0.99$ and precision for **non-white patients** was $0.8$?

Machine Learning 69 / 75

<!-- page 84 -->

Bias and Fairness in Machine Learning

# Interventions

Why is this an issue?

If a **beneficial intervention** is provided to only the **most at-risk people**, then we want to make sure that intervention is **distributed fairly** amongst all people.

Machine Learning

<!-- page 85 -->

Bias and Fairness in Machine Learning

# Myths

**Myth:** Since Machine Learning models are designed to be objective and are based on data — which itself is always true — they will always be fair.

A common saying in data science: **"Garbage in, garbage out."**

If your data are biased in some way, then your results will be biased, no matter how "fair" the model-building process is.

Machine Learning

<!-- page 86 -->

Bias and Fairness in Machine Learning

# Myths

**Myth:** If I don't use race in my analysis, then my analysis can't be racist. (Also applies sex and sexist, etc.)

Even if you don't use certain variables, such as race, your model might end up performing very differently by race.

Machine Learning

<!-- page 87 -->

Bias and Fairness in Machine Learning

# Myths

**Myth:** If I use race in my analysis, then my analysis is always racist. (Also applies sex and sexist, etc.)

You can account for difference in race, and still have a fair model. The key part is that you are fair in how you provide the intervention.

Machine Learning

<!-- page 88 -->

Bias and Fairness in Machine Learning

# What can be done?

One way to combat it: `http://www.datasciencepublicpolicy.org/projects/aequitas/`

Machine Learning

<!-- page 89 -->

Bias and Fairness in Machine Learning

# What can be done?

Questions to ask:
* Where is the data coming from?
* How are the algorithms set?
* Do decision-makers understand what the analysis is doing?
* How is the trade-off between false positives and false negatives set?

Machine Learning
