---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_10_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 10"
original: "PracTools_SURV745/assignments/SURV745_Assign_10_Linares.qmd"
pages: 
sha256: "8b917734a29d4e0dde2829be2727c7b95b9cede87449bd8b94b077cfacb6715b"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:07"
---


```r
pacman::p_load(tidyverse, knitr, tidymodels, rpart, rpart.plot, PracTools, survey)
options(scipen = 999)

```

```r
data(nhis)
nhis <- tibble(nhis) |> 
  # resp must be a factor for classification
  mutate(resp = factor(resp, levels = c(0, 1)))
```

### Exercise 13.9. Using the NHIS dataset, fit a classification tree for the response (`resp`) variable using the covariates `age`, `sex`, `hisp`, `race`, `parents`, and `educ`. Require that a minimum of 50 cases be assigned to each node. Describe the composition of each node in words and draw a picture of the tree. Compute the unweighted response rates in each of the nodes that are formed.

-   We fit a classification tree on `resp` response variable with covariates `age`, `sex`, `hisp`, `race`, `parents`, and `educ` . We set `minbucket = 50` so that every terminal node has at least 50 cases, and `cp = 0` to avoid penalizing complexity (VDK p. 355).

```r
set.seed(15097)
# using the tidymodels way as this is the modern approach to CART & ML
# recipe: predict resp from the six specified covariates
tree_recipe <- recipe(
  resp ~ age + sex + hisp + race + parents + educ, 
  data = nhis) |> 
  step_mutate(
    educ = factor(educ),
    hisp = factor(hisp))

# model spec: rpart engine with minbucket = 50, cp = 0
tree_spec <- decision_tree() |>
  set_engine("rpart", 
             # set parameters
             control = rpart.control(minbucket = 50, cp = 0)) |>
  set_mode("classification") # choose between regression or classification

# combine in a workflow
tree_wf <- workflow() |>
  add_model(tree_spec) |>
  add_recipe(tree_recipe)

# fit the model
tree_fit <- tree_wf |>
  fit(data = nhis)

# extract the underlying rpart object
tree_mod <- tree_fit |>
  extract_fit_engine()

print(tree_mod, digits = 4)


```

\newpage

-   The algorithm output lists every node in the tree. Terminal nodes (leaves) are marked with `*`. Each row shows the node number, the splitting rule, the total number of cases (`n`), the number misclassified if the majority class is assigned to all cases (`loss`), the majority class label (`yval`), and the proportion of 0s and 1s (`yprob`).

```r
table(tree_mod$where, useNA = "always")
```

-   The count of cases in each terminal node is obtained above, and we investigate that each has \> 50 cases.

#### Node Descriptions

-   Our classification algorithm produced 9 terminal nodes . The finer granularity of `educ` (9 levels) and `parents` (4 levels) allows the algorithm to discover additional splits. The variables `sex` and `race` were not selected for any split, meaning they do not improve classification beyond what the other covariates already capture. The key advantage of CART is that it automatically discovers interactions without requiring explicit specification.

```r
# compute unweighted response rate in each terminal node for the data
node_rr <- tree_fit |>
  # from broom pacakge
  augment(new_data = nhis) |>
  mutate(node = tree_mod$where,
         resp_num = as.numeric(as.character(resp))) |>
  group_by(node) |>
  reframe(
    n_total = n(),
    n_resp = sum(resp_num), # respondents
    n_nr = n_total - n_resp, # nonrespondents
    unwt_rr = mean(resp_num)) |>
  mutate(class = row_number()) |>
  select(class, node, n_total, n_resp, n_nr, unwt_rr)

node_rr |>
  mutate(unwt_rr = round(unwt_rr, 4)) |>
  kable(col.names = c("Class", "Node", 
                      "Total n", "Respondents", 
                       "Nonrespondents", 
                      "Unwt. Response Rate"))

```

#### Node Descriptions

-   Using the detailed covariates produces a tree with 9 terminal nodes. The variables `sex` and `race` were not selected for any split. The 9 adjustment classes are: The 9 adjustment classes, labeled left-to-right across the terminal nodes of the tree, are:

    1.  Class 1 ($n = 88$, RR = 0.50): Hispanic (`hisp` = 1), aged 56+, lower education (`educ` = 1 or 3).
    2.  Class 2 ($n = 73$, RR = 0.51): Non-Hispanic (`hisp` = 2), aged 82+, lower education (`educ` = 1 or 3).
    3.  **Class 3** ($n = 52$, RR = 0.48): Non-Hispanic, aged 56--61, `educ` = 3 (HS graduate; the `educ >= 2` split within the lower-education branch selects only `educ` = 3 since `educ` = 2 does not exist in the data).
    4.  **Class 4** ($n = 209$, RR = 0.64): Non-Hispanic, aged 61--82, `educ` = 3 (same logic as Class 3).
    5.  Class 5 ($n = 166$, RR = 0.66): Non-Hispanic, aged 56--82, 8th grade or less (`educ` = 1).
    6.  Class 6 ($n = 67$, RR = 0.46): Aged 33--56, lower education (`educ` = 1 or 3), at least one parent present (`parents` \< 3.5). Lowest-responding class.
    7.  Class 7 ($n = 210$, RR = 0.64): Under 33, lower education (`educ` = 1 or 3), at least one parent present.
    8.  Class 8 ($n = 1{,}099$, RR = 0.69): Under 56, lower education (`educ` = 1 or 3), neither parent present (`parents` $\geq$ 3.5).
    9.  Class 9 ($n = 1{,}947$, RR = 0.73): Higher education (`educ` = 5, 6, or 9), regardless of other covariates. Largest class with the highest response rate.

-   The tree identifies a three-way interaction among `educ`, `age`, and `hisp` in the older low-education branch, and a two-way interaction between `parents` and `age` in the younger low-education branch. Response rates range from 0.46 to 0.73 across the nine classes.

\newpage

```r
#| fig-width: 8
#| fig-height: 8

cols <- ifelse(tree_mod$frame$yval == 1, "gray50", "black")

# code is from VDK pg 366
prp(tree_mod, 
    main = "Classification Tree for NR Adjustment Classes",
    extra = 106,
    nn = TRUE,
    fallen.leaves = TRUE,
    branch = 0.5,
    faclen = 0,
    trace = 1,
    shadow.col = "gray",
    branch.lty = 1,
    branch.type = 5,
    split.cex = 1.2,
    split.prefix = "is ",
    split.suffix = "?",
    col = cols, border.col = cols,
    split.box.col = "lightgray",
    split.border.col = "darkgray",
    split.round = 0.5)
```

\newpage

### 13.10. Calculate the unweighted and weighted values of NR weight adjustment (alternatives 3 and 4) shown in Example 13.8 for the classes identified in Exercise 13.9. For the weighted adjustments, use the svywt variable. How do these sets of values compare? Which would you recommend and why?

-   VDK Example 13.8 (p. 345) lists five methods for estimating within-class response propensities. Exercise 13.10 asks for alternatives 3 and 4 only; therefore,
    -   Alternative 3 (unweighted response rate): $\hat{\phi}_c = n_{cR} / n_c$, where $n_{cR}$ is the number of respondents and $n_c$ is the total number of cases in class $c$.
    -   Alternative 4 (weighted response rate): $\hat{\phi}_c = \sum_{i \in s_{c,R}} d_i \big/ \sum_{i \in s_c} d_i$, where $d_i$ is the survey weight (`svywt`).
-   The nonresponse adjustment factor for each class is $a_{2c} = 1 / \hat{\phi}_c$.

```r
# assign each case to its terminal node
nhis_nr <- nhis |>
  mutate(NR_class = tree_mod$where,
         resp_num = as.numeric(as.character(resp)))

# alternative 3: unweighted response rate per class
unwt_rr <- nhis_nr |>
  group_by(NR_class) |>
  reframe(
    n_c = n(),
    n_cR = sum(resp_num),
    phi_unwt = mean(resp_num)) |>
  mutate(class = row_number(),
         a2c_unwt = 1 / phi_unwt)

# alternative 4: weighted response rate per class
wt_rr <- nhis_nr |>
  group_by(NR_class) |>
  reframe(
    sum_wt_all  = sum(svywt),
    sum_wt_resp = sum(svywt * resp_num),
    phi_wt = sum_wt_resp / sum_wt_all) |>
  mutate(a2c_wt = 1 / phi_wt)

# combine into a single summary table
adj_table <- unwt_rr |>
  left_join(
    wt_rr |> select(NR_class, sum_wt_all, sum_wt_resp, phi_wt, a2c_wt),
    by = "NR_class")

# print table
adj_table |>
  select(class, n_c, n_cR, phi_unwt, a2c_unwt, 
         sum_wt_all, sum_wt_resp, phi_wt, a2c_wt) |>
  mutate(across(c(phi_unwt, phi_wt), \(x) round(x, 3)),
         across(c(a2c_unwt, a2c_wt), \(x) round(x, 3)),
         across(c(sum_wt_all, sum_wt_resp), \(x) round(x, 0))) |>
  # the rest is w/ AI to get nicer column names in latex
  kable(col.names = c("Class", "$n_c$", "$n_{cR}$", 
                       "$\\hat{\\phi}_c$ Unwt.", "$a_{2c}$ Unwt.",
                       "$\\sum d_i$", "$\\sum d_i$ (R)",
                       "$\\hat{\\phi}_c$ Wt.", "$a_{2c}$ Wt."),
        escape = FALSE)
```

-   Alternatives 3 and 4 give similar results across most classes. The biggest differences show up in Classes 5 and 8, where the weighted response rates are noticeably higher than the unweighted ones --- meaning cases with larger survey weights in those classes tend to be respondents. In classes like 2 and 6, the pattern reverses slightly. When the survey weights vary within a CART-defined class, the two methods can diverge. Classes where cases with larger weights tend to be nonrespondents will show a lower weighted response rate (higher $a_{2c}$) relative to the unweighted rate.

-   I would recommend Alternative 4 (weighted response rate). The NHIS is not an epsem design, so the survey weights vary across cases. Alt 3 ignores this and treats every case equally, which can introduce bias if heavier-weighted cases respond at different rates than lighter-weighted ones. Alt 4 uses the weights and recovers the full sum of base weights when applied to respondents (as shown in the appendix), which is a desirable property. Little and Vartivarian (2003), cited in VDK p. 346, note that Alt 3 can be more stable when response probabilities are truly constant within each class. However, if the two sets of adjustments are very similar, the choice matters less, and the simpler unweighted version could be preferable.

\newpage

#### Appendix: Applying the NR Adjustment to Create Adjusted Weights

-   For completeness, we compute the nonresponse-adjusted weight $d_{2i} = d_i \times a_{2c}$ for respondents. Following VDK (p. 366), eligible respondents receive the adjustment, while nonrespondents are dropped (weight set to 0).

```r
# merge adjustment factors onto individual records
nhis_final <- nhis_nr |>
  left_join(
    adj_table |> select(NR_class, a2c_unwt, a2c_wt),
    by = "NR_class") |>
  mutate(
    # NR-adjusted weights (respondents only)
    d2_unwt = if_else(resp == 1, svywt * a2c_unwt, 0),
    d2_wt = if_else(resp == 1, svywt * a2c_wt,   0))

# compare sum of base weights vs. NR-adjusted weights for respondents
tibble(
  Weight = c("Base weight (all cases)", 
             "Base weight (respondents only)",
             "NR-adj weight, Alt 3 (respondents)",
             "NR-adj weight, Alt 4 (respondents)"),
  `Sum of Weights` = c(
    sum(nhis_final$svywt),
    sum(nhis_final$svywt[nhis_final$resp == 1]),
    sum(nhis_final$d2_unwt),
    sum(nhis_final$d2_wt))) |>
  mutate(`Sum of Weights` = round(`Sum of Weights`, 2)) |>
  kable()
```

-   The NR-adjusted weights for respondents using Alternative 4 (weighted response rate) recover the full sum of base weights across all cases, because the weighted adjustment redistributes the weight of nonrespondents to respondents within each class proportionally to their survey weights. The Alternative 3 (unweighted) adjustment recovers a sum that is close but not identical because it does not account for weight variation within classes.
