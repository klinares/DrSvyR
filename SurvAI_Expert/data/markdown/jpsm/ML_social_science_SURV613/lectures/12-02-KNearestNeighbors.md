---
id: "jpsm/ML_social_science_SURV613/lectures/12-02-KNearestNeighbors"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "K-Nearest Neighbors"
original: "ML_social_science_SURV613/lectures/12-02-KNearestNeighbors.pdf"
pages: 11
sha256: "45b070df23f17a17938f6ab3d52eedbc77d2e7d7e6069b9cee5cf356200c176d"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:12"
---

<!-- page 1 -->

# K-Nearest Neighbors

Brian Kim

Brian Kim

K-NN

<!-- page 2 -->

# Example: Chronic Kidney Disease

Doctors want to know whether their patients are at risk for developing chronic kidney disease (CKD). They have a dataset of many patients with measurements from a blood test, as well as whether the patients developed CKD. We want to develop a model to predict whether a patient will get CKD using just the information from the blood test.

Brian Kim | K-NN | 2 / 11

<!-- page 3 -->

# Intuition

**Intuition behind K-Nearest Neighbors:** When predicting future data, we might want to consider how other similar observations might have performed in the past.

**Example:** When trying to predict whether a patient will develop chronic kidney disease, we might want to think about whether patients with similar blood test results got CKD.

Brian Kim

K-NN

<!-- page 4 -->

# K-Nearest Neighbors Algorithm

Find the data point that is closest to the one you want to predict.

The predicted class is the class of the nearest data point.

---

Brian Kim $\qquad$ K-NN $\qquad$ 4 / 11

<!-- page 5 -->

# Data

Brian Kim

K-NN

<!-- page 6 -->

# Prediction using K-Nearest Neighbors

Brian Kim

K-NN

<!-- page 7 -->

# K-Nearest Neighbors

This shows how we might predict any new data point. We might be more interested in the **overall model**. That is, given any input, what would be our predicted output?

We can describe this model using a **decision boundary**.

Brian Kim

K-NN

<!-- page 8 -->

# The K-Nearest Neighbors Model

Brian Kim
K-NN

<!-- page 9 -->

# K-Nearest Neighbors

What we've described is actually 1-Nearest Neighbors. Usually, we choose a number of closest points and use those together to determine predicted class.

For example, we might set $k = 5$ and choose five closest points and predict using a "vote" of those classes.

Brian Kim

K-NN

<!-- page 10 -->

# Another Example

Brian Kim

K-NN

<!-- page 11 -->

# Considerations

**Choosing K**

* We want to choose K to minimize **overfitting**.
* K is arbitrary! You may want to try multiple values to see which performs best.
* Use an odd number (to avoid ties)

Brian Kim | K-NN | 11 / 11
