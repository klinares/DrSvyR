---
id: "jpsm/PracTools_SURV745/labs/Class10Lab"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 10"
original: "PracTools_SURV745/labs/Class10Lab.pdf"
pages: 11
sha256: "2b87d61c3cdb96b5d40dd45d9c5ec88aebcca6df55ac47110bb170e3e46d476c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:13"
---

<!-- page 1 -->

# PracTools Class 10

Sunghee Lee

4/6/2026

## Extension of VDK Example 13.6. Identifying Classification and Regression Trees (CART) for `resp` in `nhis`

* Nonresponse in the 2003 National Health Interview Survey (NHIS) data, (`nhis`)

A data frame with 3,911 observations on the following 16 variables.

`ID` Identification variable

`stratum` Sample design stratum

`psu` Primary sampling unit, numbered within each stratum (1,2)

`svywt` survey weight

`sex` Gender (1 = male; 2 = female)

`age` Age, continuous

`age_r` Recoded age (3 = 18-24 years; 4 = 25-44 years; 5 = 45-64 years; 6 = 65-69 years; 7 = 70-74 years; 8 = 75 years and older)

`hisp` Hispanic ethnicity (1 = Hispanic; 2 = Non-Hispanic)

`marital` Marital status (1 = Separated; 2 = Divorced; 3 = Married; 4 = Single/never married; 5 = Widowed; 9 = Unknown marital status)

`parents` Parent(s) of sample person present in the family (1 = Mother, no father; 2 = Father, no mother; 3 = Mother and father; 4 = Neither mother nor father)

`parents_r` Parent(s) of sample person present in the family recode (1 = Yes; 2 = No)

`educ` Education (1 = 8th grade or less; 2 = 9-12th grade, no high school diploma; 3 = High school graduate; 4 = General education development (GED) degree recipient; 5 = Some college, no degree; 6 = Associate's degree, technical or vocational; 7 = Associate's degree, academic program; 8 = Bachelor's degree (BA, BS, AB, BBA); 9 = Master's, professional, or doctoral degree)

`educ_r` Education recode (1 = High school, general education development degree (GED), or less; 2 = Some college; 3 = Bachelor's or associate's degree; 4 = Master's degree & higher)

`race` Race (1 = White; 2 = Black; 3 = Other)

`resp` Respondent (0 = nonrespondent; 1 = respondent)

1

<!-- page 2 -->

```r
data(nhis)
dim(nhis)
```

```
## [1] 3911   15
```

```r
names(nhis)
```

```
##  [1] "ID"        "stratum"   "psu"       "svywt"     "sex"       "age"      
##  [7] "age_r"     "hisp"      "marital"   "parents"   "parents_r" "educ"     
## [13] "educ_r"    "race"      "resp"
```

```r
tabyl(nhis$resp)
```

```
##  nhis$resp    n  percent
##          0 1212 0.3098952
##          1 2699 0.6901048
```

* As done in Ex. 13.6, we use the following covariates:
  - `age`
  - `educ_r`
  - `hisp`
  - `parents_r`
  - `race`
* Why? Because we believe they are related to NR/R patterns and available for both respondents and nonrespondents:

```r
nhis%>%
  group_by(resp)%>%
  summarise(m_age=mean(age),
            m_hisp=mean((hisp-2)*-1),
            m_parents=mean((parents_r-2)*-1))
```

```
## # A tibble: 2 x 4
##    resp m_age m_hisp m_parents
##   <int> <dbl>  <dbl>     <dbl>
## 1     0  46.7  0.236     0.153
## 2     1  44.4  0.190     0.113
```

<!-- page 3 -->

```r
nhis %>%
  tabyl(resp, educ_r)%>%
  adorn_percentages("row") %>%
  adorn_pct_formatting(digits = 2) %>%
  adorn_ns()
```

```
##  resp              1            2            3           4
##     0 56.85%   (689) 16.50% (200) 19.97% (242) 6.68%  (81)
##     1 47.24% (1,275) 19.23% (519) 25.60% (691) 7.93% (214)
```

```r
nhis %>%
  tabyl(resp, race)%>%
  adorn_percentages("row") %>%
  adorn_pct_formatting(digits = 2) %>%
  adorn_ns()
```

```
##  resp              1            2           3
##     0 78.47%   (951) 16.09% (195) 5.45%  (66)
##     1 80.73% (2,179) 14.93% (403) 4.33% (117)
```

3

<!-- page 4 -->

# A. Use `rpart` package

### Usage

```r
rpart(formula, data, weights, subset, na.action = na.rpart, method,
      model = FALSE, x = FALSE, y = TRUE, parms, control, cost, ...)
```

### Arguments

| | |
| :--- | :--- |
| `formula` | a formula, with a response but no interaction terms. If this is a data frame, it is taken as the model frame (see `model.frame`). |
| `data` | an optional data frame in which to interpret the variables named in the formula. |
| `weights` | optional case weights. |
| `subset` | optional expression saying that only a subset of the rows of the data should be used in the fit. |
| `na.action` | the default action deletes all observations for which `y` is missing, but keeps those in which one or more predictors are missing. |
| `method` | one of `"anova"`, `"poisson"`, `"class"` or `"exp"`. If `method` is missing then the routine tries to make an intelligent guess. If `y` is a survival object, then `method = "exp"` is assumed, if `y` has 2 columns then `method = "poisson"` is assumed, if `y` is a factor then `method = "class"` is assumed, otherwise `method = "anova"` is assumed. It is wisest to specify the method directly, especially as more criteria may added to the function in future.<br>Alternatively, `method` can be a list of functions named `init`, `split` and `eval`. Examples are given in the file ‘`tests/usersplits.R`’ in the sources, and in the vignettes ‘User Written Split Functions’. |
| `model` | if logical: keep a copy of the model frame in the result? If the input value for `model` is a model frame (likely from an earlier call to the `rpart` function), then this frame is used rather than constructing new data. |
| `x` | keep a copy of the `x` matrix in the result. |
| `y` | keep a copy of the dependent variable in the result. If missing and `model` is supplied this defaults to `FALSE`. |
| `parms` | optional parameters for the splitting function.<br>Anova splitting has no parameters.<br>Poisson splitting has a single parameter, the coefficient of variation of the prior distribution on the rates. The default value is 1.<br>Exponential splitting has the same parameter as Poisson.<br>For classification splitting, the list can contain any of: the vector of prior probabilities (component `prior`), the loss matrix (component `loss`) or the splitting index (component `split`). The priors must be positive and sum to 1. The loss matrix must have zeros on the diagonal and positive off-diagonal elements. The splitting index can be `gini` or `information`. The default priors are proportional to the data counts, the losses default to 1, and the split defaults to `gini`. |
| `control` | a list of options that control details of the `rpart` algorithm. See `rpart.control`. |
| `cost` | a vector of non-negative costs, one for each variable in the model. Defaults to one for all variables. These are scalings to be applied when considering splits, so the improvement on splitting on a variable is divided by its cost in deciding which split to choose. |
| `...` | arguments to `rpart.control` may also be specified in the call to `rpart`. They are checked against the list of valid arguments. |

4

<!-- page 5 -->

```r
set.seed(15097)
nhis <- data.frame(nhis)
t1 <- rpart(resp ~ age + hisp + race + parents_r + educ_r,
            method = "class",
            control = rpart.control(minbucket = 50, cp=0),
            data = nhis)
```

```r
print(t1, digits=4)
```

```
## n= 3911
##
## node), split, n, loss, yval, (yprob)
##       * denotes terminal node
##
##  1) root 3911 1212 1 (0.3099 0.6901)
##    2) educ_r< 1.5 1964  689 1 (0.3508 0.6492)
##      4) age>=55.5 588  239 1 (0.4065 0.5935) *
##      5) age< 55.5 1376  450 1 (0.3270 0.6730)
##       10) parents_r< 1.5 277  111 1 (0.4007 0.5993)
##         20) age>=32.5 67   31 0 (0.5373 0.4627) *
##         21) age< 32.5 210   75 1 (0.3571 0.6429) *
##       11) parents_r>=1.5 1099  339 1 (0.3085 0.6915) *
##    3) educ_r>=1.5 1947  523 1 (0.2686 0.7314) *
```

```r
table(t1$where)
```

```
##
##    3    6    7    8    9
##  588   67  210 1099 1947
```

**B. Visualizing CART with prp in `rpart.plot` package**

* For more information, refer to https://cran.r-project.org/web/packages/rpart.plot/rpart.plot.pdf

```r
cols <- ifelse(t1$frame$yval == 1, "gray50", "black")
cols
```

```
## [1] "black"  "black"  "black"  "black"  "black"  "gray50" "black"  "black"
## [9] "black"
```

5

<!-- page 6 -->

```r
prp(t1, main="Tree for NR adjustment classes in NHIS",
    extra=106, # display prob of survival and percent of obs
    nn=TRUE, # display node numbers
    fallen.leaves=TRUE, # put leaves on the bottom of page
    branch=.5, # change angle of branch lines
    faclen=0, # do not abbreviate factor levels
    trace=1, # print automatically calculated cex
    shadow.col="gray", # shadows under the leaves
    branch.lty=1, # draw branches using solid lines
    branch.type=5, # branch lines width = weight(frame$wt),
                   # no. of cases here
    split.cex=1.2, # make split text larger than node text
    split.prefix="is ", # put "is " before split text
    split.suffix="?", # put "?" after split text
    col=cols, border.col=cols, # cols[2] if survived
    split.box.col="lightgray", # lightgray split boxes (white default)
    split.border.col="darkgray", # darkgray border on split boxes
    split.round=0.5) # round the split box corners a tad
```

```
## cex 1   xlim c(0, 1)   ylim c(0, 1)
```

### Tree for NR adjustment classes in NHIS

6

<!-- page 7 -->

### C. Nonresponse Adjustment Factor and Nonresponse Adjusted Weights

* We can consider (1) the inverse of unweighted response rate or (2) the inverse of weighted response rate within each terminal node, $c$, as follows:

1. Unweigthed response rates

* $a_{2c} = \frac{1}{\hat{\phi}_c} = \frac{n_c}{n_{cR}}$

```r
unwt.rr <- by(as.numeric(nhis[, "resp"]), t1$where, mean)
```

2. Weighted response rates

* $a_{2c} = \frac{1}{\hat{\phi}_c} = \frac{\sum_{i \in s_c} d_i}{\sum_{i \in s_{cR}} d_i}$

```r
wt.rr <- by(data = data.frame(resp = as.numeric(nhis[,"resp"]),
                              wt = nhis[,"svywt"]),
            t1$where,
            function(x) {weighted.mean(x$resp, x$wt)} )
```

```r
nhis.NR <- cbind(nhis, NR.class=t1$where)
tmp1 <- cbind(NR.class=as.numeric(names(wt.rr)), unwt.rr, wt.rr)
nhis.NR <- merge(nhis.NR, data.frame(tmp1), by="NR.class")
nhis.NR <- nhis.NR[order(nhis.NR$ID),]
nhis.NR%>%
  group_by(NR.class)%>%
  summarise(ur=mean(unwt.rr),
            wr=mean(wt.rr))
```

```
## # A tibble: 5 x 3
##   NR.class    ur    wr
##      <int> <dbl> <dbl>
## 1        3 0.594 0.609
## 2        6 0.463 0.453
## 3        7 0.643 0.645
## 4        8 0.692 0.703
## 5        9 0.731 0.747
```

* What would NR adjusted weight be?

7

<!-- page 8 -->

## VDK Example 13.9. Random Forests with `nhis`

### A. Use `cforest` in `party` package

**Usage**

```r
cforest(formula, data = list(), subset = NULL, weights = NULL,
        controls = cforest_unbiased(),
        xtrafo = ptrafo, ytrafo = ptrafo, scores = NULL)
proximity(object, newdata = NULL)
```

**Arguments**

| | |
| :--- | :--- |
| `formula` | a symbolic description of the model to be fit. Note that symbols like `:` and `-` will not work and the tree will make use of all variables listed on the rhs of `formula`. |
| `data` | an data frame containing the variables in the model. |
| `subset` | an optional vector specifying a subset of observations to be used in the fitting process. |
| `weights` | an optional vector of weights to be used in the fitting process. Non-negative integer valued weights are allowed as well as non-negative real weights. Observations are sampled (with or without replacement) according to probabilities `weights / sum(weights)`. The fraction of observations to be sampled (without replacement) is computed based on the sum of the weights if all weights are integer-valued and based on the number of weights greater zero else. Alternatively, `weights` can be a double matrix defining case weights for all `ncol(weights)` trees in the forest directly. This requires more storage but gives the user more control. |
| `controls` | an object of class `ForestControl-class`, which can be obtained using `cforest_control` (and its convenience interfaces `cforest_unbiased` and `cforest_classical`). |
| `xtrafo` | a function to be applied to all input variables. By default, the `ptrafo` function is applied. |
| `ytrafo` | a function to be applied to all response variables. By default, the `ptrafo` function is applied. |
| `scores` | an optional named list of scores to be attached to ordered factors. |
| `object` | an object as returned by `cforest`. |
| `newdata` | an optional data frame containing test data. |

```r
crf.nhis <- cforest(as.factor(resp) ~ age + as.factor(hisp) +
                      as.factor(race) +
                      as.factor(parents_r) + as.factor(educ_r),
                    controls = cforest_control(ntree = 500,
                    mincriterion = qnorm(0.8), trace = TRUE),
                    data=nhis)
```

8

<!-- page 9 -->

```r
## 
## [>                                                  ]   0% completed[=>
```

```r
crf.nhis
```

```r
## 
##   Random Forest using Conditional Inference Trees
## 
## Number of trees:  500 
## 
## Response:  as.factor(resp) 
## Inputs:  age, as.factor(hisp), as.factor(race), as.factor(parents_r), as.factor(educ_
## Number of observations:  3911
```

```r
crf.nhis.prob <- predict(crf.nhis,newdata=nhis,type="prob")
dim(crf.nhis.prob)
```

```r
## NULL
```

```r
head(crf.nhis.prob)
```

```r
## $`1`
##      as.factor.resp..0 as.factor.resp..1
## [1,]          0.3949481          0.6050519
## 
## $`2`
##      as.factor.resp..0 as.factor.resp..1
## [1,]          0.2368417          0.7631583
## 
## $`3`
##      as.factor.resp..0 as.factor.resp..1
## [1,]          0.3018738          0.6981262
## 
## $`4`
##      as.factor.resp..0 as.factor.resp..1
## [1,]          0.3326704          0.6673296
## 
## $`5`
##      as.factor.resp..0 as.factor.resp..1
## [1,]          0.2976027          0.7023973
## 
## $`6`
##      as.factor.resp..0 as.factor.resp..1
## [1,]           0.291263           0.708737
```

9

<!-- page 10 -->

```r
crf.prob <- matrix(unlist(crf.nhis.prob), ncol=2, byrow=TRUE)
head(crf.prob)
```

```
##           [,1]      [,2]
## [1,] 0.3949481 0.6050519
## [2,] 0.2368417 0.7631583
## [3,] 0.3018738 0.6981262
## [4,] 0.3326704 0.6673296
## [5,] 0.2976027 0.7023973
## [6,] 0.2912630 0.7087370
```

```r
apply(crf.prob,2,mean)
```

```
## [1] 0.3099596 0.6900404
```

### B. Comparing estimated propensities from CART and random forests

```r
rpart.prob <- predict(t1,newdata=nhis,type="prob")
head(rpart.prob)
```

```
##           0         1
## 1 0.3571429 0.6428571
## 2 0.3084622 0.6915378
## 3 0.2686184 0.7313816
## 4 0.2686184 0.7313816
## 5 0.3084622 0.6915378
## 6 0.2686184 0.7313816
```

```r
out<-data.frame(cbind(rpart=rpart.prob[,2],
                      cforest=crf.prob[,2],
                      class=t1$where))
names(out)
```

```
## [1] "rpart"   "cforest" "class"
```

```r
out%>%
  group_by(class)%>%
  summarise(rpart=mean(rpart),
            cforest=mean(cforest))
```

10

<!-- page 11 -->

```
## # A tibble: 5 x 3
##   class rpart cforest
##   <dbl> <dbl>   <dbl>
## 1     3 0.594   0.597
## 2     6 0.463   0.488
## 3     7 0.643   0.633
## 4     8 0.692   0.689
## 5     9 0.731   0.732
```

```r
ggplot(out, aes(x=rpart, y=cforest)) + geom_point()
```

11
