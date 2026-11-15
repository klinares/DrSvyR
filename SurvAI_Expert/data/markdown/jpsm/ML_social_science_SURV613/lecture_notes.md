---
id: "jpsm/ML_social_science_SURV613/lecture_notes"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "lecture_notes"
original: "ML_social_science_SURV613/lecture_notes.pdf"
pages: 9
sha256: "e5a31213f9c5d769d1f82a1b49e710e13529b475f71dcade3083ed673ec71efb"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:05"
---

<!-- page 1 -->

1/14/2025 Intro

* What is ML? Is when the computer improves at a task with respect to a performance measure as you give it experience.
    * We want it to do better at predictions, or task T, but we need to optimize on some metric P.
        * ex. self driving, task is going from A to B, we give it data by more driving. It has to be optimized on a performance metrics such as getting to a place (speed, and distance) on time and safely (obeys traffic rules).
    * Class is mostly focused on prediction and learning from the data to answer social science questions. Optimizing on prediction.
        * We are not trying to understand the underlying relationship, just make predictions.
    * Intervention in ML studies are usually key to deciding how to build the model, i.e. predict recidivism, risk for adverse events, etc.
    * Goal is to build adaptable (change over time) scalable systems that are effective and easy to maintain, rule based.
* ML process, features are predictors.

Machine Learning task
$\downarrow$
Get and integrate data
$\downarrow$
Explore and pre-process data
$\downarrow$
Features
$\downarrow$
Training and tuning
$\downarrow$
Evaluation
$\downarrow$
Deploy, maintain and update

*   * Unsupervised learning, finding patterns in data and there is no outcome variable so no prediction. Finding clusters in data.
    * Supervised, finding Y as a $f(X) + e$ to make optimal predictions on a new dataset.
        * Representation, describe possible relationship between X and Y.
        * Evaluate, what is the performance measure criterion. MSE, logistic Loss, etc.
        * Computation, how F gets calculated.
    * Generative AI blends both.
    * We will focus on predicting output for new test data.
        * Perform well at making predictions on new data.
    * Bias-variance tradeoff

<!-- page 2 -->

* Loss function means error, think residual.
* Training error is like the MSE, the loss here can be an absolute value. Training error is used to build the model, how we optimize.
* Test error is the prediction error not used to build model.
    * Remember, we want to build models that do the best job in making predictions of new data.

Training error

$$\overline{\text{err}} = \frac{1}{N} \sum_{i=1}^N L(y_i, \hat{f}(x_i))$$

* Prediction error based on **training data**
* with e.g. squared error loss $L$

Test error

$$\text{Err}_{\mathcal{T}} = \text{E}(L(Y, \hat{f}(X)) | \mathcal{T})$$

* Prediction error using **test data** (given training data $\mathcal{T}$)

* Expected test error is a function of bias and variance. This leads to bias-variance trade off. As we reduce bias, variance increases, and vice-a-versa.
    * High variance, different data would need new function, overfitting which fits poorly to new data.
    * High Bias, some points are poorly predicted, results in underfitting. Does not do a good job at predicting specific ranges, and not adapting to the data.
    * Optimal, compromise between bias and variance.
* As our model gets more complex, our training error gets smaller. However, Bias increases, so test error starts to increase with complexity.

Figure: Training error and test error by model complexity

<!-- page 3 -->

* **GOAL of prediction,** minimize test error.

**1/21/25 Introduction to ML**

* Ethical considerations, think about the intervention and its implications as well who benefits and who is affected by it.
* Choosing model, goal is to make prediction; therefore, model is optimized on a performance metric and picks the variables that optimize on this.
  * Choose variables based on what improves prediction on the test set.
* In order to get an unbiased estimate of model performance we have to use unseen data.
* Nested cross validation, get a better idea of model performance.
* In ML, trying to get the best model not an unbiased estimate.
* K-fold is on the training set only, and test set is for calculating performance.
* Performance metric
  * accuracy, good when more than two categories. Think of children lead example.
  * Precision, good for when we need to make sure positive cases are correct as an intervention has a risk associated.
    * Think of add campaigns, we do not want to be wrong as it is expensive.
  * Recall, when intervention is beneficial and being wrong is not high, as in the children lead cases.
  * Precision and recall threshold should be adjusted based on the intervention. We will want to adjust these values. Think about it as scores, not probabilities.
  * F1 score, when imbalance in outcomes. Balance between precision and recall.

**1/28/25 K-NN and performance metrics:**

* in KNN, threshold should be above .80, or below .30 to make a prediction of 0. K is a tuning parameter, try different values. Look at graphs of performance.
  * We use cross validation to determine what the value should be.
  * Features need to be scaled and numerical because of distance measures. Depends on stealing of feature, if there aren’t many neighbors it won’t make good predictions.
    * Ex predict graduation from SAT and GPA, SAT are sparse.
    * Also affected by high dimensional.
  * Categorical variables need to be converted to numerical. Scale along numerical variables.
  * Weighted KNN, weight closer points higher, 1/distance.
  * Distance measures lead to different results.
* Precision vs recall
  * find model that makes best predictions. How to think about performance measures, and how it fits with the overall process.
  * Logistic regression – predicted probability
  * KNN – proportion of positive cases
  * weighted KNN – weighted proportion of positive cases.
    * Think of them as scores, not probabilities.
  * Using top K, doesn’t provide best performance b/c it is a budget constraint b/c we only have x budget to intervene.

<!-- page 4 -->

* One possible way to determine best model for lead poison homes, choose model that maximizes recall with a precision higher than 50%, for every 2 homes intervened, at least 1 is likely to have lead.
* ROC and PR curves
  * As we change the threshold values, how does the relationship between sensitivity and specificity change. The closer to the to left corner, the better the model overall.
    * AUC, a way to compare two models, to see which model has the higher value and performing better.
    * AUC take into account the range of threshold values.
  * And the screeplot we want to see a U shape, think the idea of bias-variance trade-off.
  * Low k is high variance low bias, and flips for high k.

**February 4 2025 regularized regression**

* If there is a tuning parameter, we use some sort of cross validation to optimize on a predictive performance metric.
  * Alpha and lambda for instance gets tuned during the process.
* Lasso (L1) and ridge (L2)
  * L1 regularization penalty term in the loss function, coefficients can shrink towards 0.
  * L2 regularization squared sum coefficient as penalty term in the loss function. Shrinks coefficients evenly, but not to 0.
  * lasso = Least Absolute Shrinkage and Selection Operator
  * there is a shrinkage penalty, a penalty coefficient on the beta coefficient that minimizes RSS.
  * Fit a regression line with a constraint region,
    * square for lasso region, or circle for ridge, the lasso constraint pulls the combination of beta 1 and beta 2 closer to 0.
  * When the regularization parameter "lambda" approaches infinity, all coefficients will shrink towards zero, simple model with minimal predictive power. Set at 0, becomes equivalent to OLS.
* Elastic Net
  * alpha = 0 is ridge, alpha = 1 is lasso.
* Group lasso, some variables when one shot hot coding or using related variable like lat and long, when want to use them in the model as a group of features as long as they are scaled to 0.

**February 11 2025 CART**

* Decision trees, not great at making predictions, easy to interpret. It partitions the outcome space.
  * C-TREE and RP-TREE are extensions of CART.
    * With correlated predictors, we only use a subset of predictors at a time.
    * Surrogate splits – address missing data. Determines split by finding another variable to substitute.
    * CART over fitting (high variance, low bias) how to address.
    *

<!-- page 5 -->

**February 18, 2025 decision trees**

* Over fit, trouble with correlated features. Upside, non-parametric, handles lots of interactions.
* Ensemble methods
  * Goals:
    * Average over these models reduce variance. If we average by many trees, we reduce variance to get closer a better bias-variance trade-off.
    * The idea is to randomize features to reduce correlated features.
  * methods
    * Bagging
      * bootstrapping rows
    * random forest
      * bootstrap rows, randomize columns
    * extra trees
      * randomizes splits plus random forest. Does not do bagging.
    * Generally these methods (averaging) work better than methods on their own.
  * Out of bag error OOB
    * If you have a sample, you have an approximation of the population distribution. If we draw a sample with replacement, we should get a new sample but it is likely to contains about 63% of the original draw when we do this over and over. The rest of the observations are not used and can be considered the test set, or out of bag observations.
    * Calculate error
      * generate predictions for observations not used to train the model
      * average over models to get test error
      * repeat for all cases, average out.

**March 11, 2025 Neural Networks**

* tuning parameters, these determine how fast it learns
  * Drop out rate, parameter set nodes to zero if some proportion of nodes are not used to discourage over fitting.
  * Learning rate, how much weights change with each update, same as XGB
  * there are other parameters, but these are the top ones.
* Activation functions
  * if they are linear we get a complicated OLS.
  * The change in the activation function, adds non-linearity to make predictions for different distributions for non-linear relationship.
    * Based on type of network
      * ReLu for CN is used a lot. Looks like it goes horizontal from a point and goes up.
        * Sets some nodes to 0. Sort of think of it as regularization.
          * It doesn't set some nodes to 0 like elastic net, but it is similar.
      * Sigmoid/Tanh for RNN.
* Types of NN
  * convolutional NN, goes in one direction.
  * RNN, recurrent, uses outputs from previous time steps as inputs for current time step.

<!-- page 6 -->

**March 25, 2025 Interpretable ML methods**

* We use ML to make better predictions.
* Interpreting the model is useful when there is a need to explain how the prediction was achieved.
* After we make predictions, we can interpret and turn it into something actionable.
* Interpretable methods are not to make inferences. It is a way to understand the model better.
* We can use these methods to also inform future experiments. To focus on important features when it is costly to collect data.
* Feature importance, these are just scores to compare between models. Don't compare feature importance across models. We can use these to cut cost for data collection.
* PDP, ICE, ALE plots.
  * Explains how the predictions are made, not the relationship.
* Surrogate models
  * Gives predictions that are almost the same as the complicated model. Used for interpreting the model.
  * Should be interpretable, such as OLS or decision tree without cross validation or tuning.
  * Don't interpret coefficients.
  * Don't evaluate the surrogate model in the same way, just looking at predictions at the local level.
  * The use case is to match locally, since the simple model may not capture the complexities at the global level to explain our predictions.
* LIME (local interpretability model-agnostic explanations), use simple models to explain at local levels.
* At the global level they may not be close, but at the local level they may be close between the complex model and the surrogate model.

**April 8 2025 fairness and bias**

* For imbalance data, don't assume we need to oversample or undersmaple. These are meant to predict positive cases that are rare.
  * Many times they don't work. But we can still come up with better models. Just evaluate with test error.
* Use them when you have issues. When there is train/test split and not enough observations for a particular class.
* SMOTE – synthetic minority oversampling techniques, adding some random nois.
  * Used to highlight the relationships better.
  * Key is to look at up-sample vs hybrid. Looking for synthetic data that came from the same distribution.

<!-- page 7 -->

Figure: Down-sampling, up-sampling, $\text{SMOTE}^1$

* Stacking
  * Combining models, using lower level models's predictions as features.
  * Combines strengths of different models.
  * Interpretation
    * lower level model models that do not do a good job won't contribute much in the end.
* Super learner
  * will perform at least as well as the best single model.
  * CV to train lower level candidate learners, than combine predictions to get final model.
* For both you do a nested CV, both uses level 1 models, not base learners (that is specific to RF, boosting).

<!-- page 8 -->

# Super Learner

Figure: Super Learner$^3$

0. Train each candidate learner on entire dataset
1. Split data into V blocks
2. Train each candidate learner
3. Predict the outcomes in the validation block based on the corresponding training block candidate learner
4. Model selection and fitting for the regression of the observed outcome onto the predicted outcomes from the candidate learners
$$E(Y|Z) = m(z; \beta)$$
5. Evaluate super learner by combining predictions from each candidate learner (step 0) with $m(z; \beta)$ (steps 1-4)

$^3$van der Laan et al. (2007)

April 15 2025 Unsupervised Learning

* Used to generate new information, clusters, topics, or some task. Learning characteristics about the data.
  * Misconception, using a hypothesis to dictate number of clusters that reflect some priori.
  * Better for doing descriptive statistics.
  * We can’t determine if something is correct or not.
  * There is no use of performance metrics in the same way as supervised methods.
  * Outputs of a clustering methods can be used in a supervised model, if you already have the data might as well use features directly.
  * One way to use it is to verify results from something that is time consuming for hand coding.
  * When using interpretable techniques, such as surrogate model, maybe it might be helpful to use in the model to provide explanation that can be more actionable.
* Weights
  * we aren’t really making population inferences, so interpretation is different.
* PCA
  * linear combination, if $P > N$, we may need dimension reduction before regression, PCA can be used.
  * loadings can be interpreted, but not really used in ML.

<!-- page 9 -->

* In NN, preprocessing such as PCA, is not really needed.
* Other methods
  * hierarchical clustering
  * Gaussian mixture models
    * identifies the separation between clusters.
    * The goal is to identify cases into clusters, not just the distributions.
* Generative AI
  * modern uses.
  * Generative adviserial methods, uses unsupervised and supervised methods. Mimics the existing data and evaluates.
    * The task is when the unsupervised method and the supervised cannot be distinguished.


**April 22 2025 Gen-AI**

* Final, make sure to tune the model and think about the performance measures and connect to the project.
* How does it work, what can we expect to get out of it.
* All chatGPT is doing is using unlabelled text to come up with responses based on the data that it was trained with.
* Ethics
  * data collection ethics. Includes data privacy. For instance, art was taken without the consent and AI replicates. Who owns the data.
  * data usage. Using AI to do homework.
* Skynet similar AI, it is not autonomous, still is semi-supervised. It does not think yet.
* The learning rate for the generator and discriminator should be both slow.
