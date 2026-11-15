---
id: "jpsm/fund_comp_data_display_SURV727/lectures/Comp_11"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "Data exploration"
original: "fund_comp_data_display_SURV727/lectures/Comp_11.pdf"
pages: 35
sha256: "9bccb57e5749c4e855c45b5ef8a37dea17b0e4116fcc0ea5657379ee29a88b4e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:58"
---

<!-- page 1 -->

# Data exploration
## Fundamentals of Computing and Data Display

Christoph Kern$^1$ Ruben Bach

(c.kern, r.bach)@uni-mannheim.de

---
$^1$Thanks to Sebastian Sternberg!

<!-- page 2 -->

# Outline

1. Introduction
2. Clustering
   - K-Means
   - Hierarchical Clustering
3. Principal Component Analysis
4. References

---

Fundamentals of Computing and Data Display | Data exploration | 2 / 35

<!-- page 3 -->

# Introduction

**Unsupervised Learning**

* Tools for finding patterns in (unlabeled) data
* In the unsupervised learning setting, we only observe features $X_1, X_2, X_p$; no outcome
* The goal is to discover interesting things about the measurements
  * Is there an informative way to visualize the data?
  * Are there subgroups among the variables and/or the observations?
* Unsupervised learning is also called **exploratory data analysis** or knowledge discovery
* Common objective is dimensionality reduction

<!-- page 4 -->

Introduction

# Introduction

- **Clustering**
  - Clustering refers to a very broad set of techniques for finding subgroups (clusters) in a data set
  - A cluster can be defined as a group of *similar* objects (cases, members, customers, locations etc.)
- **Factor Analysis**
  - Summarize many (correlated) features into a few, uncorrelated dimensions
  - Here we focus on Principal Component Analysis (PCA), which is – strictly speaking – only related to factor analysis

**PCA** aims at clustering ***features***, whereas **cluster methods** aim at clustering ***objects***

Fundamentals of Computing and Data Display $\quad$ Data exploration $\quad$ 4 / 35

<!-- page 5 -->

# Clustering

1. Introduction
2. Clustering
   - K-Means
   - Hierarchical Clustering
3. Principal Component Analysis
4. References

<!-- page 6 -->

# Clustering

Cluster methods

- In **K-Means clustering**, we seek to partition the observations into a pre-specified number of clusters
- In **hierarchical clustering**, we do not know in advance how many clusters we want
  - We end up with a tree-like visual representation of the observations that allows us to view at once the clusterings obtained for each possible number of clusters, from 1 to $n$
- Expectation-maximization clustering, Mean shift clustering, Spectral clustering, $\dots$

<!-- page 7 -->

# K-Means

* K-Means is the simplest and the most common cluster algorithm
* K-Means algorithm is fast and easy to use; it is thus a good solution in the Big Data context
* General idea: Iteratively re-assign observations to the nearest cluster center
* May be used as a preprocessing step for other algorithms
* K-Means also has some drawbacks which should be kept in mind

<!-- page 8 -->

Clustering K-Means

# K-Means

**Objective**: Find cluster solution with smallest within-cluster variation $W(C_k)$:

$$
\underset{C_1, \dots, C_K}{\text{minimize}} \left\{ \sum_{k=1}^K W(C_k) \right\}
$$

Within-cluster variation may be defined as the sum of pairwise squared **Euclidean distances** between the observations in a cluster (over all $p$ features):

$$
W(C_k) = \frac{1}{|C_k|} \sum_{i, i' \in C_k} \sum_{j=1}^p (x_{ij} - x_{i'j})^2
$$

Fundamentals of Computing and Data Display Data exploration 8 / 35

<!-- page 9 -->

Clustering K-Means

# K-Means

---
**Algorithm 1:** K-Means Clustering

---
**Parameter :** Number of cluster $K$
**Initialization:** Randomly choose $K$ data points (seeds) to be the initial centroids, cluster centers

1 **repeat**
2 $\quad$ Assign each data point to the closest centroid;
3 $\quad$ Re-compute the cluster centroids (vector of $p$ feature means) using the current cluster memberships;
4 **until** *no reclassification is necessary*;

---

Fundamentals of Computing and Data Display Data exploration 9 / 35

<!-- page 10 -->

Clustering K-Means

# K-Means example, Step 1

Figure: K-Means: Step 1$^2$

Pick 3 initial cluster centers (randomly)

Y

X

$k_1$

$k_2$

$k_3$

---

$^2$Ghani and Schierholz (2017)

Fundamentals of Computing and Data Display Data exploration 10 / 35

*[Figure: The scatter plot on axes X and Y illustrates the first step of the K-Means clustering algorithm, comparing unclustered data points (represented as red diamonds) with three randomly placed initial cluster centers (represented as blue circles labeled $k_1$, $k_2$, and $k_3$). The red diamonds are loosely grouped into three main areas across the plot (bottom-left, bottom-right, and top-right), while the three blue centroids are dispersed among them at various positions.]*

<!-- page 11 -->

Clustering K-Means

# K-Means example, Step 2

Figure: K-Means: Step 2$^3$

Assign each point to the closest cluster center

$k_1$

$k_2$

$k_3$

Y

X

---

$^3$Ghani and Schierholz (2017)

Fundamentals of Computing and Data Display Data exploration 11 / 35

*[Figure: The scatter plot illustrates the second step of the K-Means clustering algorithm along horizontal axis X and vertical axis Y. It compares three color-coded groups—green ($k_1$), red ($k_2$), and blue ($k_3$)—demonstrating the pattern where diamond-shaped data points are assigned to the group of their nearest circular cluster center, dividing the space into upper, lower-left, and lower-right regions.]*

<!-- page 12 -->

Clustering K-Means

# K-Means example, Step 3

Figure: K-Means: Step 3$^4$

Y

Move
each cluster
center
to the mean
of each cluster

$k_1$

$k_1$

$k_2$

$k_2$

$k_3$

$k_3$

X

---
$^4$Ghani and Schierholz (2017)

Fundamentals of Computing and Data Display Data exploration 12 / 35

*[Figure: The figure is a two-dimensional scatter plot with axes labeled X and Y, illustrating the third step of the K-Means clustering algorithm across three color-coded groups (green, red, and blue). It shows diamond-shaped data points and circular cluster centers ($k_1$, $k_2$, and $k_3$), with black arrows indicating the movement of each cluster center from its previous position to the geometric mean of its respective colored cluster.]*

<!-- page 13 -->

Clustering K-Means

# K-Means example, Step 4

Figure: K-Means: Step 4$^5$

Reassign points closest to a different new cluster center

Y

$k_1$

$k_2$

$k_3$

X

---
$^5$Ghani and Schierholz (2017)

Fundamentals of Computing and Data Display Data exploration 13 / 35

*[Figure: The figure is a 2D scatter plot with horizontal axis X and vertical axis Y, illustrating Step 4 of a K-Means clustering algorithm where data points are reassigned to the nearest cluster center. It compares three color-coded groups of diamond-shaped data points (green, red, and blue) clustered spatially around their respective circular centroids ($k_1$ in the upper right, $k_2$ in the lower left, and $k_3$ in the lower right), with one outlying green point in the upper left.]*

<!-- page 14 -->

Clustering K-Means

# K-Means example, Step 4...

Figure: K-Means: Step 4...$^6$

Reassigned Data points

Y

X

$k_1$

$k_2$

$k_3$

---
$^6$Ghani and Schierholz (2017)

Fundamentals of Computing and Data Display Data exploration 14 / 35

*[Figure: The scatter plot illustrates a step in the K-Means clustering algorithm along horizontal axis X and vertical axis Y, comparing three color-coded clusters (green, red, and blue) of diamond-shaped data points grouped around circular centroids labeled $k_1$, $k_2$, and $k_3$. The main pattern shows three spatially distinct clusters in the upper-right, lower-left, and lower-right regions, with arrows specifically highlighting four "Reassigned Data points" (two red and two blue) located near the boundaries between the groups.]*

<!-- page 15 -->

Clustering K-Means

# K-Means example, Step 4b

Figure: K-Means: Step 4b$^7$

re-compute cluster means

Y

$k_1$

$k_2$

$k_3$

X

---
$^7$Ghani and Schierholz (2017)

Fundamentals of Computing and Data Display Data exploration 15 / 35

*[Figure: The figure is a two-dimensional scatter plot with axes labeled X and Y illustrating the step of re-computing cluster means in K-Means clustering. It compares three groups of diamond-shaped data points (colored green, red, and blue) located in different quadrants of the plot, showing their corresponding circular centroids ($k_1$, $k_2$, and $k_3$) shifting via black arrows toward the center of their respective clusters.]*

<!-- page 16 -->

Clustering K-Means

# K-Means example, Step 5

Figure: K-Means: Step 5$^8$

Y

$k_1$

$k_2$

$k_3$

move cluster
centers to
cluster means

X

---
$^8$Ghani and Schierholz (2017)

Fundamentals of Computing and Data Display Data exploration 16 / 35

*[Figure: The figure is a two-dimensional scatter plot with horizontal axis $X$ and vertical axis $Y$ illustrating Step 5 of the K-Means clustering algorithm, where cluster centers are moved to the cluster means. It compares three spatially distinct groups of diamond-shaped data points—colored green (upper right), red (left, with one high outlier), and blue (lower right)—each positioned around its respective circular centroid labeled $k_1$, $k_2$, and $k_3$.]*

<!-- page 17 -->

# Drawbacks

* Choosing the number of cluster $K$
  * Run $K$-Means with different values of $K$
  * Graphical diagnostic checks such as the elbow-method (plot $K$ against explained variance)
  * Does the same $K$ yield to good solutions for different subsets of the original data?
* Choosing starting values
  * Run $K$-Means several times with different starting values, and take the best solution

<!-- page 18 -->

Clustering Hierarchical Clustering

# Hierarchical Clustering

1. Introduction
2. Clustering
    * K-Means
    * Hierarchical Clustering
3. Principal Component Analysis
4. References

Fundamentals of Computing and Data Display Data exploration 18 / 35

<!-- page 19 -->

Clustering Hierarchical Clustering

# Hierarchical Clustering

* K-means clustering requires us to pre-specify the number of clusters $K$
* Hierarchical clustering does not require that we commit to a particular choice of $K$
* Here we focus on **bottom-up** or **agglomerative** clustering
* Tree-based representation (dendrogram) is built starting from the leaves and combining clusters up to the trunk

**Dendrogram**

Fundamentals of Computing and Data Display Data exploration 19 / 35

<!-- page 20 -->

Clustering Hierarchical Clustering

# Hierarchical Clustering

---
**Algorithm 2:** Hierarchical Clustering

---
**Parameter :** Dissimilarity measures w.r.t. observations and clusters
**Initialization:** Start with each observation as its own cluster

1 **for** $i = n, n - 1, \dots, 2$ **do**
2 | Identify the closest two clusters given all pairwise inter-cluster dissimilarities;
3 | Merge these two clusters;
4 | Compute the new pairwise inter-cluster dissimilarities among the remaining clusters;
5 **end**

---

Fundamentals of Computing and Data Display Data exploration 20 / 35

<!-- page 21 -->

Clustering Hierarchical Clustering

# Distances

Computing the dissimilarities between observations; the **distance matrix**

Euclidean Distance: $||\boldsymbol{x}_a - \boldsymbol{x}_b||_2$

$$
\sqrt{\sum_{j=1}^P (x_{aj} - x_{bj})^2}
$$

Minkowski Distance:

$$
\left( \sum_{j=1}^P |x_{aj} - x_{bj}|^q \right)^{\frac{1}{q}}
$$

Manhattan Distance: $||\boldsymbol{x}_a - \boldsymbol{x}_b||_1$

Other metrics available: Mahalanobis, Chebyshev...

Fundamentals of Computing and Data Display Data exploration 21 / 35

<!-- page 22 -->

Clustering Hierarchical Clustering

# Linkage

Computing the dissimilarities between clusters; types of **linkages**
- Complete linkage
  - Maximal inter-cluster dissimilarity. Record the *largest* of the dissimilarities between observations in cluster $A$ and $B$
- Average linkage
  - Mean inter-cluster dissimilarity. Record the *average* of the dissimilarities between observations in cluster $A$ and $B$
- Single linkage
  - Minimal inter-cluster dissimilarity. Record the *smallest* of the dissimilarities between observations in cluster $A$ and $B$
- Ward linkage
  - Fuse cluster $A$ and $B$ that result in the smallest increase in the *within-cluster variation* of the new cluster

Fundamentals of Computing and Data Display Data exploration 22 / 35

<!-- page 23 -->

Clustering Hierarchical Clustering

# Dendrograms

Figure: Dendrogram example$^9$

- Each leaf represents one observation
- Moving up the tree, some similar leaves begin to fuse into branches
- As we move higher up the tree, branches themselves fuse
- Observations fusing at the bottom are quite similar to each other, whereas observations fusing close to the top will tend to be quite different (indicated by height)

---

$^9$James et al. (2013)

Fundamentals of Computing and Data Display Data exploration 23 / 35

*[Figure: The figure shows a hierarchical clustering dendrogram with a vertical axis scaled from 0 to 10 indicating fusion height and an unlabeled horizontal arrangement of individual observation leaves (shown as green vertical lines at the bottom). The tree structure demonstrates how numerous similar individual leaves fuse at low heights (below 4) into three main sub-clusters, two of which merge around a height of 7 before finally joining the leftmost branch near the top at a height above 10.]*

<!-- page 24 -->

Clustering Hierarchical Clustering

# Dendrograms

Figure: Different cuts result in different clusters$^{10}$

---
$^{10}$James et al. (2013)

Fundamentals of Computing and Data Display Data exploration 24 / 35

*[Figure: The figure displays three side-by-side hierarchical clustering dendrograms with vertical height axes ranging from 0 to 10. It compares the resulting cluster groupings (indicated by colored leaf branches) across different horizontal cut heights: the left dendrogram has no cut (one green cluster), the middle has a dashed cut line at height 9 (yielding two purple and green clusters), and the right has a lower dashed cut line at height 5 (yielding three purple, yellow, and green clusters), illustrating that cutting the tree at lower heights increases the number of distinct clusters.]*

<!-- page 25 -->

Clustering Hierarchical Clustering

# Practical issues

- Should the observations or features first be standardized in some way?
- What dissimilarity measure should be used?
- What type of linkage should be used?
- Did cluster algorithm really found true subgroups, or are the obtained clusters a result of clustering the noise?
- Outliers can heavily distort clusters, because they belong to no group but are forced into one
- Clustering methods are not very robust to perturbations to the data

Clustering should be performed with different choices of parameters, and for different subsets of the data.

Fundamentals of Computing and Data Display Data exploration 25 / 35

<!-- page 26 -->

Principal Component Analysis

# Principal Component Analysis

1. Introduction
2. Clustering
   - K-Means
   - Hierarchical Clustering
3. **Principal Component Analysis**
4. References

Fundamentals of Computing and Data Display | Data exploration | 26 / 35

<!-- page 27 -->

Principal Component Analysis

# Principal Component Analysis

Given a set of data on $n$ dimensions, PCA aims to find a linear subspace of dimension $d$ lower than $n$ such that the data points lie mainly on this subspace

- Combine a correlated group of variables into a new characteristic (component)
- Aim is to find characteristics which strongly differ across different groups of variables, but are good in "reconstructing" the original variables
- We therefore "throw away" information by combining variables to a factor
- The better the components are in explaining the variance of all variables, the better job it did in summarizing the variables

Fundamentals of Computing and Data Display  
Data exploration

<!-- page 28 -->

Principal Component Analysis

# Principal Component Analysis

- First principal component is the best linear approximation for the data in the direction with the **maximum variance**
- This results in a line which minimizes the sum of squared distance between a data point and the line

Figure: PCA Example

(a) First principle component (b) Second principle component

Fundamentals of Computing and Data Display Data exploration 28 / 35

*[Figure: The figure presents two side-by-side scatter plots titled "PCA Example," showing "Physics Grades" on the y-axis against "Math Grades" on the x-axis (both ranging from -20 to 20) for six individuals labeled Person1 through Person6. The main pattern shows two distinct clusters of grades (Person1 and Person2 with high positive values; Person3–6 with negative values), with plot (a) fitting a solid red line of positive slope along the direction of maximum variance for the first principal component, and plot (b) adding an orthogonal dotted blue line of negative slope for the second principal component.]*

<!-- page 29 -->

Principal Component Analysis

# Loadings and scores

- Suppose we have a $n \times p$ data set $X$ where each of the variables in $X$ has been centered to have mean zero
- The first principal component of a set of features $x_1, x_2, \ldots, x_p$ is the normalized ($\sum_{j=1}^p \phi_{j1}^2 = 1$) linear combination of the features

$$z_{i1} = \phi_{11}x_{i1} + \phi_{21}x_{i2} + \ldots + \phi_{p1}x_{ip}$$

that has the largest variance.
- $\phi_{11}, \ldots, \phi_{p1}$ is referred to as the loadings of the first principle component; they make up the principle component loading vector

$$\phi_1 = (\phi_{11} \ \phi_{21} \ \ldots \ \phi_{p1})^T$$

Fundamentals of Computing and Data Display $\qquad$ Data exploration $\qquad$ 29 / 35

<!-- page 30 -->

Principal Component Analysis

# Loadings and scores

* The second principal component is the linear combination of $x_1, \dots, x_p$ that has maximal variance among all linear combinations that are *uncorrelated* with $z_1$
* The second principal component scores $z_{12}, z_{22}, \dots, z_{n2}$ take the form

$$z_{i2} = \phi_{12}x_{i1} + \phi_{22}x_{i2} + \dots + \phi_{p2}x_{ip}$$

where $\phi_2$ is the second principal component loading vector with elements $\phi_{12}, \dots, \phi_{p2}$.
* Constraining $z_2$ to be uncorrelated with $z_1$ is equivalent to constraining the direction $\phi_2$ to be orthogonal to the direction $\phi_1$

Fundamentals of Computing and Data Display | Data exploration | 30 / 35

<!-- page 31 -->

Principal Component Analysis

# Computation of Principle Components

## Extract Principle Components

1. Standardize the variables
2. Calculate covariance matrix $X'X$
3. Perform eigen-decomposition to find eigenvectors ($q_j$) and eigenvalues ($\lambda_j$) of the covariance matrix

$$X'X = Q\Lambda Q'$$

   - The eigenvector with the highest eigenvalue is the first principal component
4. Reorient the data by multiplying the original data with the eigenvectors to compute the scores

$$F = XQ$$

Fundamentals of Computing and Data Display | Data exploration | 31 / 35

<!-- page 32 -->

Principal Component Analysis

# How many components are needed?

* How much of the information is lost by projecting the observations onto the first few principal components?
  * Proportion of variance explained by component $m$: $\frac{\sum_{i=1}^n \left(\sum_{j=1}^p \phi_{jm} x_{ij}\right)^2}{\sum_{j=1}^p \sum_{i=1}^n x_{ij}^2}$
* If we use PCA to summarize our data, how many components are sufficient?
  * Decision may be based on “eyeballing” the scree plot and looking for the “elbow”

Figure: Screeplot example

Fundamentals of Computing and Data Display | Data exploration | 32 / 35

*[Figure: The line plot (labeled as a screeplot example) shows the "Proportion of variance explained" on the vertical axis (ranging from 0.0 to 1.0) against the "Principal Component" number (1 through 4) on the horizontal axis. The single plotted line shows a decreasing trend across the components, dropping steeply from just over 0.6 at component 1 to about 0.25 at component 2, and then leveling off below 0.1 for components 3 and 4.]*

<!-- page 33 -->

Principal Component Analysis

# Biplots

* Biplots are often used to visualize the PCA results using the first two PCs
* Is named biplot because it displays both the PC *scores* and the PC *loadings* in one figure
* The red arrows indicate the first two principle component *loading vectors*
* The black names represent the *scores* for the first two principle components

Fundamentals of Computing and Data Display | Data exploration | 33 / 35

*[Figure: The figure is a PCA biplot plotting the "First Principal Component" on the horizontal axis against the "Second Principal Component" on the vertical axis (ranging from -3 to 3 for scores on the bottom/left and -0.5 to 0.5 for loadings on the top/right). It compares U.S. states (black text labels) against four red loading vectors ("UrbanPop", "Rape", "Assault", and "Murder"), showing that the three crime vectors all point right along the first principal component while "UrbanPop" points predominantly upward along the second principal component.]*

<!-- page 34 -->

Principal Component Analysis

# Summary

PCA is a useful tool in big data context: **dimension reduction** and **data inspection**

Direct usage
- Summarize many (correlated) features into a few, uncorrelated dimensions
- Detecting interesting patterns in data for a deeper investigation

Indirect usage
- PCA as data pre-processing: only use first few principle components instead of all features

Fundamentals of Computing and Data Display | Data exploration | 34 / 35

<!-- page 35 -->

# References

Ghani, R., Schierholz, M. (2017). Machine Learning. In: Foster, I., Ghani, R., Jarmin, R. S., Kreuter, F., Lane, J. (Eds.). (2017). *Big Data and Social Science: A Practical Guide to Methods and Tools*. Boca Raton, FL: CRC Press Taylor & Francis Group.

James, G., Witten, D., Hastie, T., Tibshirani, R. (2013). *An Introduction to Statistical Learning*. New York, NY: Springer.
