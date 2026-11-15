---
id: "jpsm/ML_social_science_SURV613/lectures/07-01-IntroductionEnsemble"
source: "jpsm"
course: "SURV613"
course_title: "Machine Learning for Social Science"
doc_type: "lecture"
title: "Bagging, Random Forests, Extra Trees"
original: "ML_social_science_SURV613/lectures/07-01-IntroductionEnsemble.pdf"
pages: 4
sha256: "c77fcfbb067a85484b528e629b53f34020e4bc4dc6589e11b3d3edbb3f829cbd"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:06"
---

<!-- page 1 -->

# Bagging, Random Forests, Extra Trees

## Introduction to Ensemble Methods

<!-- page 2 -->

# Introduction

---

**Algorithm 1:** Tree growing process

---

**1** Define stopping criteria;  
**2** Assign training data to root node;  
**3** **if** *stopping criterion is reached* **then**  
**4** $\quad \vert \quad$ end splitting;  
**5** **else**  
**6** $\quad \vert \quad$ find the optimal split point;  
**7** $\quad \vert \quad$ split node into two subnodes at this split point;  
**8** $\quad \vert \quad$ **for** *each node of the current tree* **do**  
**9** $\quad \vert \quad \quad \vert \quad$ continue tree growing process;  
**10** $\quad \vert \quad$ **end**  
**11** **end**  

---

<!-- page 3 -->

Introduction

# Ensembles

Some limitations of (single) trees
- Difficulties in modeling additive structures
- Lack of smoothness of prediction surface
- High variance / **instability** due to hierarchical splitting process

$\rightarrow$ **Ensemble methods**
- Address instability via combining multiple prediction models
- Combine diverse models into a more robust ensemble

Machine Learning for Social Science
Bagging, Random Forests, Extra Trees

<!-- page 4 -->

Introduction

# Ensembles

How to construct ensembles?

- Apply one method with different tuning parameter settings
- Combine models with different features
- Use one method with different subsets of the data
  - **Bagging**: Can be applied to different **base learners** (e.g. CART)
- Combine models based on different methods
  - Stacking: Build a meta-model that uses (multiple) predictions as input

Machine Learning for Social Science
Bagging, Random Forests, Extra Trees
