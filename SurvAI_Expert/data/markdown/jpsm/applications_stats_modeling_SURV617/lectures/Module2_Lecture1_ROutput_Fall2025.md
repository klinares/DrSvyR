---
id: "jpsm/applications_stats_modeling_SURV617/lectures/Module2_Lecture1_ROutput_Fall2025"
source: "jpsm"
course: "SURV617"
course_title: "Applications of Statistical Modeling"
doc_type: "lecture"
title: "Module2_Lecture1_ROutput_Fall2025"
original: "applications_stats_modeling_SURV617/lectures/Module2_Lecture1_ROutput_Fall2025.pdf"
pages: 8
sha256: "479e588b48b907e8345084f312bca9359b91503769f63a9e425826523eb79f3e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:42"
---

<!-- page 1 -->

**SURVMETH 687/SURV 617**

**October 28, 2025**

### 1. lavaan() SEM example using Wheaton et al. Data

```r
> model <- ' # CRITICAL: NOTE SINGLE QUOTES
+ # measurement model
+   ses66 =~ educ66 + occstat66
+   alien67 =~ anomia67 + pwless67
+   alien71 =~ anomia71 + pwless71
+ # structural model
+   # direct effect
+     alien71 ~ c*ses66
+   # mediator
+     alien67 ~ a*ses66
+     alien71 ~ b*alien67
+   # indirect effect (a*b)
+     ab := a*b
+   # total effect
+     total := c + (a*b)
+ ' # END SINGLE QUOTES

> fit <- sem(model, data=wheaton) # fit model

> summary(fit) # examine fit
lavaan (0.5-22) converged normally after  59 iterations

  Number of observations                           932

  Estimator                                         ML
```

<!-- page 2 -->

```r
  Minimum Function Test Statistic               76.184
  Degrees of freedom                                 6
  P-value (Chi-square)                           0.000

Parameter Estimates:

  Information                                 Expected
  Standard Errors                             Standard

Latent Variables:
                   Estimate  Std.Err  z-value  P(>|z|)
  ses66 =~
    educ66            1.000
    occstat66         0.592    0.043   13.699    0.000
  alien67 =~
    anomia67          1.000
    pwless67          0.823    0.038   21.735    0.000
  alien71 =~
    anomia71          1.000
    pwless71          0.825    0.039   21.307    0.000

Regressions:
                   Estimate  Std.Err  z-value  P(>|z|)
  alien71 ~
    ses66     (c)    -0.172    0.064   -2.689    0.007
  alien67 ~
    ses66     (a)    -0.759    0.062  -12.239    0.000
  alien71 ~
    alien67   (b)     0.710    0.056   12.607    0.000
```

<!-- page 3 -->

```r
Variances:

                   Estimate  Std.Err  z-value  P(>|z|)
   .educ66            3.679    0.416    8.843    0.000
   .occstat66         2.345    0.172   13.650    0.000
   .anomia67          4.301    0.364   11.808    0.000
   .pwless67          3.422    0.260   13.150    0.000
   .anomia71          3.636    0.369    9.848    0.000
   .pwless71          3.951    0.289   13.681    0.000
    ses66             5.857    0.557   10.517    0.000
   .alien67           5.200    0.495   10.514    0.000
   .alien71           3.352    0.382    8.782    0.000


Defined Parameters:

                   Estimate  Std.Err  z-value  P(>|z|)
    ab               -0.539    0.057   -9.381    0.000
    total            -0.711    0.061  -11.641    0.000
```

## 2. MGA Example in R

### <u>Unconstrained Model</u>

```r
lavaan (0.5-22) converged normally after  42 iterations

  Number of observations per group
  1                                                793
  0                                                881

  Estimator                                         ML
  Minimum Function Test Statistic                0.000
  Degrees of freedom                                 0
  Minimum Function Value               0.0000000000000
```

<!-- page 4 -->

```r
Chi-square for each group:

  1                                              0.000
  0                                              0.000

Parameter Estimates:

  Information                                 Expected
  Standard Errors                             Standard


Group 1 [1]:

Latent Variables:
                   Estimate  Std.Err  z-value  P(>|z|)
  trstlead =~
    trstplt           1.000
    trstprt           0.979    0.031   31.657    0.000
    trstprl           0.707    0.033   21.352    0.000

Intercepts:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           3.916    0.076   51.203    0.000
   .trstprt           3.845    0.077   50.235    0.000
   .trstprl           4.649    0.077   60.609    0.000
    trstlead          0.000

Variances:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           0.591    0.104    5.707    0.000
   .trstprt           0.764    0.103    7.444    0.000
   .trstprl           2.644    0.142   18.653    0.000
    trstlead          4.046    0.251   16.094    0.000
```

<!-- page 5 -->

```r
Group 2 [0]:

Latent Variables:
                   Estimate  Std.Err  z-value  P(>|z|)
  trstlead =~
    trstplt           1.000
    trstprt           0.959    0.027   34.891    0.000
    trstprl           0.837    0.031   26.904    0.000

Intercepts:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           3.831    0.074   51.735    0.000
   .trstprt           3.879    0.073   53.017    0.000
   .trstprl           4.289    0.078   55.268    0.000
    trstlead          0.000

Variances:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           0.677    0.090    7.481    0.000
   .trstprt           0.894    0.089   10.081    0.000
   .trstprl           2.396    0.129   18.630    0.000
    trstlead          4.154    0.243   17.089    0.000
```

**Note: A saturated model for comparison purposes...**

**<u>Model with Loadings Constrained to be Equal</u>**

```r
lavaan (0.5-22) converged normally after  40 iterations

  Number of observations per group
  1                                                793
  0                                                881
```

<!-- page 6 -->

```r
  Estimator                                         ML
  Minimum Function Test Statistic               10.846
  Degrees of freedom                                 2
  P-value (Chi-square)                           0.004

Chi-square for each group:

  1                                              5.861
  0                                              4.985

Parameter Estimates:

  Information                                 Expected
  Standard Errors                             Standard


Group 1 [1]:

Latent Variables:
                   Estimate  Std.Err  z-value  P(>|z|)
  trstlead =~                                         
    trstplt           1.000                           
    trstprt (.p2.)    0.968    0.020   47.318    0.000
    trstprl (.p3.)    0.777    0.023   34.240    0.000

Intercepts:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           3.916    0.076   51.351    0.000
   .trstprt           3.845    0.076   50.685    0.000
   .trstprl           4.649    0.080   58.199    0.000
    trstlead          0.000                           
```

<!-- page 7 -->

```r
Variances:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           0.584    0.085    6.904    0.000
   .trstprt           0.788    0.084    9.337    0.000
   .trstprl           2.628    0.143   18.437    0.000
    trstlead          4.027    0.233   17.280    0.000


Group 2 [0]:

Latent Variables:
                   Estimate  Std.Err  z-value  P(>|z|)
  trstlead =~
    trstplt           1.000
    trstprt (.p2.)    0.968    0.020   47.318    0.000
    trstprl (.p3.)    0.777    0.023   34.240    0.000

Intercepts:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           3.831    0.074   51.586    0.000
   .trstprt           3.879    0.074   52.560    0.000
   .trstprl           4.289    0.075   57.076    0.000
    trstlead          0.000

Variances:
                   Estimate  Std.Err  z-value  P(>|z|)
   .trstplt           0.676    0.086    7.868    0.000
   .trstprt           0.876    0.086   10.224    0.000
   .trstprl           2.449    0.128   19.107    0.000
    trstlead          4.183    0.233   17.969    0.000
```

<!-- page 8 -->

Comparing the Chi-square statistic for this constrained model to the saturated model (with two parameters differing between the models), we would reject the null hypothesis that the two groups have equal loadings! We do not have measurement invariance, even in the “weak” sense. The correlation appears to be weaker in the group with response rates higher than 50%! Perhaps this group struggles with measurement (gets through interviews quicker?).
