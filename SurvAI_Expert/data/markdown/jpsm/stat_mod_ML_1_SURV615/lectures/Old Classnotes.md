---
id: "jpsm/stat_mod_ML_1_SURV615/lectures/Old_Classnotes"
source: "jpsm"
course: "SURV615"
course_title: "Statistical Methods and Machine Learning I"
doc_type: "lecture"
title: "Old Classnotes"
original: "stat_mod_ML_1_SURV615/lectures/Old Classnotes.pdf"
pages: 54
sha256: "a773c4167a1f9c09ab2363c7b5a9568ac475b0ecb8fbd5c8ceb34b12186e5eaa"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:27"
---

<!-- page 1 -->

LECTURE NOTES FOR SURV 615/SURVMETH 685
Statistical Methods I
Class #1 & 2

OVERVIEW: In this class we will introduce reporting rules for statistics in this course. We next discuss two useful plotting techniques which we demonstrate with SAS We will also review basic statistical inference based upon the normal distribution. In addition we give a short review of useful distributional results relating to the normal distribution, and introduce the Delta Method of variance approximation.

### 1. Reporting Rules of Statistical Analyses

It is important to learn good habits of reporting the results of your statistical computations. It is impossible to come up with a universally acceptable set of reporting rules, but we will establish a set of rules for this class. We will reserve the term *standard error* to refer to an estimate of the standard deviation (square root of the variance) of a statistic. With this in mind, we will adopt the following general rule:

**General Reporting Rule.** For any statistic, report its standard error to two significant digits, and report the statistic to the same number of decimals.

This rule is adopted from Wayne A. Fuller (Iowa State University), and has proved very useful. It can be shown that under this rule the maximum percentage error in a confidence interval is approximately five percent. We next give some examples.

**Example 1.** Below we present on the left some output, where the estimate is presented above its standard error which is in parentheses. The reported values using the general reporting rule are presented to the right.

- Notes for Class #1 & 2, page 1 of 54 -

<!-- page 2 -->

| Output | Reported |
| :---: | :---: |
| $190.23546$<br>$(1.23546)$ | $190.2$<br>$(1.2)$ |
| $0.18235$<br>$(2.23546)$ | $0.2$<br>$(2.2)$ |
| $56749.94956$<br>$(234.57689)$ | $56750.$ OR $567.5 \times 10^2$<br>$(230.)$ $\quad$ $(2.3 \times 10^2)$ |

$\blacksquare$

Other special cases should be handled as follows

**$t$ statistics and $F$ statistics** $\quad$ Two decimal places (e.g. $t = 1.96$)

**Means** $\quad$ Decimals to match standard errors
**Regression Coefficients**
**Confidence intervals**

**Standard Errors** $\quad$ Two significant digits

**Covariance Matrix** $\quad$ Five significant digits

In all cases you should retain as many digits in computation as possible, and only use the reporting rules on the final result.

2. Basic Data Displaying Techniques

Assume that we collect a random sample of data $X_1, \dots, X_n$. How do we begin to look at the data? Histograms, and scatter plots (for multivariate data) are well known. We will look at two particular graphical techniques, which are more fully described in **Exploratory Data Analysis** by John Tukey

1) Stem and Leaf Displays
2) Box-and-Whisker Plots (and Schematic Plots)

- Notes for Class #1 & 2, page 2 of 54 -

<!-- page 3 -->

To illustrate these techniques we will use an example. Each month the Bureau of the Census conducts the Current Population Survey for the Bureau of Labor Statistics. This survey is the main source of labor force information for the United States. A particular labor force estimate of interest is the Unemployment Rate. We present unemployment rates for fifty States and the District of Columbia for June 1993 and June 1994. Below we present a SAS program with the data, and code to create the displays we are interested in.

```
data set1;
  input state $13. year unr;
  cards;
Alabama        93  7.6
Alabama        94  5.8
Alaska         93  7.7
Alaska         94  7.8
Arizona        93  6.0
Arizona        94  6.3
Arkansas       93  6.2
Arkansas       94  5.8
Colorado       93  5.1
Colorado       94  4.8
Connecticut    93  6.3
Connecticut    94  5.1
Delaware       93  5.2
Delaware       94  4.8
WashDC         93  8.5
WashDC         94  8.0
Georgia        93  5.7
Georgia        94  5.3
Hawaii         93  4.2
Hawaii         94  5.4
Idaho          93  6.3
Idaho          94  5.2
Indiana        93  5.4
Indiana        94  4.7
Iowa           93  4.0
Iowa           94  3.5
Kansas         93  5.1
Kansas         94  4.9
Kentucky       93  6.3
Kentucky       94  4.8
Louisiana      93  7.2
Louisiana      94  7.6
Maine          93  8.1
Maine          94  6.2
Maryland       93  6.3
Maryland       94  5.2
Minnesota      93  5.2
Minnesota      94  3.6
Mississippi    93  6.2
```

- Notes for Class #1 & 2, page 3 of 54 -

<!-- page 4 -->

```
Mississippi    94  6.5
Missouri       93  6.5
Missouri       94  4.5
Montana        93  6.1
Montana        94  4.1
Nebraska       93  2.6
Nebraska       94  3.1
Nevada         93  7.4
Nevada         94  5.7
NewHampshire   93  6.5
NewHampshire   94  4.7
NewMexico      93  7.8
NewMexico      94  5.0
NorthDakota    93  4.4
NorthDakota    94  3.8
Oklahoma       93  6.1
Oklahoma       94  5.9
Oregon         93  7.3
Oregon         94  5.8
RhodeIsland    93  7.7
RhodeIsland    94  6.5
SouthCarolina  93  7.8
SouthCarolina  94  6.0
SouthDakota    93  3.4
SouthDakota    94  3.1
Tennessee      93  5.8
Tennessee      94  4.6
Utah           93  3.9
Utah           94  3.4
Vermont        93  5.3
Vermont        94  4.0
Virginia       93  5.0
Virginia       94  5.1
Washington     93  7.6
Washington     94  6.5
WestVirginia   93 11.0
WestVirginia   94  9.6
Wisconsin      93  4.8
Wisconsin      94  4.3
Wyoming        93  5.5
Wyoming        94  6.0
California     93  9.2
California     94  8.3
Florida        93  7.0
Florida        94  6.2
Illinois       93  7.8
Illinois       94  4.8
Massachusetts  93  6.4
Massachusetts  94  6.0
Michigan       93  7.2
Michigan       94  5.4
NewJersey      93  7.0
NewJersey      94  7.1
NewYork        93  7.7
```

- Notes for Class #1 & 2, page 4 of 54 -

<!-- page 5 -->

```
NewYork       94  7.0
NorthCarolina 93  5.3
NorthCarolina 94  3.7
Ohio          93  6.1
Ohio          94  5.5
Pennsylvania  93  7.0
Pennsylvania  94  5.9
Texas         93  7.1
Texas         94  6.7
;

proc sort;
  by year;

run;

proc print;
  by year;

run;

proc univariate plot;
  var unr;
  by year;

run;

quit;
```

The output from running this program is given next

```
--------------------------------- YEAR=93 ---------------------------------

                       OBS    STATE             UNR

                         1    Alabama           7.6
                         2    Alaska            7.7
                         3    Arizona           6.0
                         4    Arkansas          6.2
                         5    Colorado          5.1
                         6    Connecticut       6.3
                         7    Delaware          5.2
                         8    WashDC            8.5
                         9    Georgia           5.7
                        10    Hawaii            4.2
                        11    Idaho             6.3
                        12    Indiana           5.4
                        13    Iowa              4.0
                        14    Kansas            5.1
                        15    Kentucky          6.3
                        16    Louisiana         7.2
                        17    Maine             8.1
                        18    Maryland          6.3
```

- Notes for Class #1 & 2, page 5 of 54 -

<!-- page 6 -->

| | | |
| ---: | :--- | ---: |
| 19 | Minnesota | 5.2 |
| 20 | Mississippi | 6.2 |
| 21 | Missouri | 6.5 |
| 22 | Montana | 6.1 |
| 23 | Nebraska | 2.6 |
| 24 | Nevada | 7.4 |
| 25 | NewHampshire | 6.5 |
| 26 | NewMexico | 7.8 |
| 27 | NorthDakota | 4.4 |
| 28 | Oklahoma | 6.1 |
| 29 | Oregon | 7.3 |
| 30 | RhodeIsland | 7.7 |
| 31 | SouthCarolina | 7.8 |
| 32 | SouthDakota | 3.4 |
| 33 | Tennessee | 5.8 |
| 34 | Utah | 3.9 |
| 35 | Vermont | 5.3 |
| 36 | Virginia | 5.0 |
| 37 | Washington | 7.6 |
| 38 | WestVirginia | 11.0 |
| 39 | Wisconsin | 4.8 |
| 40 | Wyoming | 5.5 |
| 41 | California | 9.2 |
| 42 | Florida | 7.0 |
| 43 | Illinois | 7.8 |
| 44 | Massachusetts | 6.4 |
| 45 | Michigan | 7.2 |
| 46 | NewJersey | 7.0 |
| 47 | NewYork | 7.7 |
| 48 | NorthCarolina | 5.3 |
| 49 | Ohio | 6.1 |
| 50 | Pennsylvania | 7.0 |
| 51 | Texas | 7.1 |

--------------------------------- YEAR=94 ---------------------------------

| OBS | STATE | UNR |
| ---: | :--- | ---: |
| 52 | Alabama | 5.8 |
| 53 | Alaska | 7.8 |
| 54 | Arizona | 6.3 |
| 55 | Arkansas | 5.8 |
| 56 | Colorado | 4.8 |
| 57 | Connecticut | 5.1 |
| 58 | Delaware | 4.8 |
| 59 | WashDC | 8.0 |
| 60 | Georgia | 5.3 |
| 61 | Hawaii | 5.4 |
| 62 | Idaho | 5.2 |
| 63 | Indiana | 4.7 |
| 64 | Iowa | 3.5 |
| 65 | Kansas | 4.9 |
| 66 | Kentucky | 4.8 |
| 67 | Louisiana | 7.6 |

- Notes for Class #1 & 2, page 6 of 54 -

<!-- page 7 -->

```r
 68    Maine            6.2
 69    Maryland         5.2
 70    Minnesota        3.6
 71    Mississippi      6.5
 72    Missouri         4.5
 73    Montana          4.1
 74    Nebraska         3.1
 75    Nevada           5.7
 76    NewHampshire     4.7
 77    NewMexico        5.0
 78    NorthDakota      3.8
 79    Oklahoma         5.9
 80    Oregon           5.8
 81    RhodeIsland      6.5
 82    SouthCarolina    6.0
 83    SouthDakota      3.1
 84    Tennessee        4.6
 85    Utah             3.4
 86    Vermont          4.0
 87    Virginia         5.1
 88    Washington       6.5
 89    WestVirginia     9.6
 90    Wisconsin        4.3
 91    Wyoming          6.0
 92    California       8.3
 93    Florida          6.2
 94    Illinois         4.8
 95    Massachusetts    6.0
 96    Michigan         5.4
 97    NewJersey        7.1
 98    NewYork          7.0
 99    NorthCarolina    3.7
100    Ohio             5.5
101    Pennsylvania     5.9
102    Texas            6.7
```

- Notes for Class #1 & 2, page 7 of 54 -

<!-- page 8 -->

---------------------------------- YEAR=93 ----------------------------------

Univariate Procedure

Variable=UNR

Moments

| | | | |
| :--- | ---: | :--- | ---: |
| N | 51 | Sum Wgts | 51 |
| Mean | 6.331373 | Sum | 322.9 |
| Std Dev | 1.518353 | Variance | 2.305396 |
| Skewness | 0.175203 | Kurtosis | 1.035688 |
| USS | 2159.67 | CSS | 115.2698 |
| CV | 23.98142 | Std Mean | 0.212612 |
| T:Mean=0 | 29.779 | Pr>\|T\| | 0.0001 |
| Num ^= 0 | 51 | Num > 0 | 51 |
| M(Sign) | 25.5 | Pr>=\|M\| | 0.0001 |
| Sgn Rank | 663 | Pr>=\|S\| | 0.0001 |

Quantiles(Def=5)

| | | | |
| :--- | ---: | :--- | ---: |
| 100% Max | 11 | 99% | 11 |
| 75% Q3 | 7.4 | 95% | 8.5 |
| 50% Med | 6.3 | 90% | 7.8 |
| 25% Q1 | 5.3 | 10% | 4.4 |
| 0% Min | 2.6 | 5% | 3.9 |
| | | 1% | 2.6 |
| Range | 8.4 | | |
| Q3-Q1 | 2.1 | | |
| Mode | 6.3 | | |

Extremes

| Lowest | Obs | Highest | Obs |
| ---: | ---: | ---: | ---: |
| 2.6( | 23) | 7.8( | 43) |
| 3.4( | 32) | 8.1( | 17) |
| 3.9( | 34) | 8.5( | 8) |
| 4( | 13) | 9.2( | 41) |
| 4.2( | 10) | 11( | 38) |

- Notes for Class #1 & 2, page 8 of 54 -

<!-- page 9 -->

```
--------------------------------- YEAR=93 ---------------------------------

                           Univariate Procedure

Variable=UNR

             Stem Leaf                     #             Boxplot
               11 0                        1                0
               10
               10
                9
                9 2                        1                |
                8 5                        1                |
                8 1                        1                |
                7 66777888                 8                |
                7 00012234                 8             +-----+
                6 55                       2             |     |
                6 01112233334             11             *--+--*
                5 578                      3             |     |
                5 01122334                 8             +-----+
                4 8                        1                |
                4 024                      3                |
                3 9                        1                |
                3 4                        1                |
                2 6                        1                |
                  ----+----+----+----+


                              Normal Probability Plot
          11.25+                                                *
               |
               |                                                  +
               |                                              ++++
               |                                           +*+
               |                                        +*+
               |                                    ++++*
               |                                ***** *
               |                            *****
               |                           *++
               |                      *****
               |                    **+
               |               * ***
               |             +*++
               |          *+**
               |       ++*
               |    ++*
           2.75++++*+
                +----+----+----+----+----+----+----+----+----+----+
                    -2        -1         0        +1        +2
```

- Notes for Class #1 & 2, page 9 of 54 -

<!-- page 10 -->

---------------------------------- YEAR=94 ----------------------------------

Univariate Procedure

Variable=UNR

Moments

| | | | |
| :--- | ---: | :--- | ---: |
| N | 51 | Sum Wgts | 51 |
| Mean | 5.482353 | Sum | 279.6 |
| Std Dev | 1.373857 | Variance | 1.887482 |
| Skewness | 0.577125 | Kurtosis | 0.619569 |
| USS | 1627.24 | CSS | 94.37412 |
| CV | 25.05962 | Std Mean | 0.192378 |
| T:Mean=0 | 28.49775 | Pr>\|T\| | 0.0001 |
| Num ^= 0 | 51 | Num > 0 | 51 |
| M(Sign) | 25.5 | Pr>=\|M\| | 0.0001 |
| Sgn Rank | 663 | Pr>=\|S\| | 0.0001 |

Quantiles(Def=5)

| | | | |
| :--- | ---: | :--- | ---: |
| 100% Max | 9.6 | 99% | 9.6 |
| 75% Q3 | 6.2 | 95% | 8 |
| 50% Med | 5.4 | 90% | 7.1 |
| 25% Q1 | 4.7 | 10% | 3.7 |
| 0% Min | 3.1 | 5% | 3.4 |
| | | 1% | 3.1 |
| Range | 6.5 | | |
| Q3-Q1 | 1.5 | | |
| Mode | 4.8 | | |

Extremes

| Lowest | Obs | Highest | Obs |
| ---: | ---: | ---: | ---: |
| 3.1( | 32) | 7.6( | 16) |
| 3.1( | 23) | 7.8( | 2) |
| 3.4( | 34) | 8( | 8) |
| 3.5( | 13) | 8.3( | 41) |
| 3.6( | 19) | 9.6( | 38) |

- Notes for Class #1 & 2, page 10 of 54 -

<!-- page 11 -->

```text
--------------------------------- YEAR=94 ---------------------------------

                           Univariate Procedure

Variable=UNR

             Stem Leaf                     #             Boxplot
                9 6                        1                0
                9
                8
                8 03                       2                |
                7 68                       2                |
                7 01                       2                |
                6 5557                     4                |
                6 000223                   6             +-----+
                5 5788899                  7             |  +  |
                5 01122344                 8             *-----*
                4 567788889                9             +-----+
                4 013                      3                |
                3 5678                     4                |
                3 114                      3                |
                  ----+----+----+----+


                              Normal Probability Plot
           9.75+                                                *
               |
               |                                               ++++
               |                                         *  *++
               |                                      * *+++
               |                                    **++
               |                                 ***+
               |                             +***
               |                          ***
               |                      ****
               |                 ****+*
               |               **+
               |          *+***
           3.25+  *   *++*+
                +----+----+----+----+----+----+----+----+----+----+
                    -2        -1         0        +1        +2
```

- Notes for Class #1 & 2, page 11 of 54 -

<!-- page 12 -->

```
                           Univariate Procedure
                              Schematic Plots

Variable=UNR

                       |
                    11 +            0
                       |
                       |
                       |
                    10 +
                       |
                       |                        0
                       |            |
                     9 +            |
                       |            |
                       |            |
                       |            |           |
                     8 +            |           |
                       |            |           |
                       |         +-----+        |
                       |         |     |        |
                     7 +         |     |        |
                       |         |     |        |
                       |         |     |        |
                       |         *--+--*     +-----+
                     6 +         |     |     |     |
                       |         |     |     |     |
                       |         |     |     *--+--*
                       |         +-----+     |     |
                     5 +            |        |     |
                       |            |        +-----+
                       |            |           |
                       |            |           |
                     4 +            |           |
                       |            |           |
                       |            |           |
                       |            |           |
                     3 +            |           |
                       |            |
                       |            |
                       |
                     2 +
                        ------------+-----------+-----------
                  YEAR                93          94
```

*Stem and Leaf Displays*

Stem and Leaf Displays are a clever technique which is a modification of the more familiar histogram. The technique is particular useful when needing to produce graphs by hand. The construction of the Stem and Leaf displays is discussed on page 11 of

- Notes for Class #1 & 2, page 12 of 54 -

<!-- page 13 -->

**Statistical Methods**. In this case they are produced in PROC UNIVARIATE of SAS with the PLOT option. The part of the SAS output corresponding to the Stem and Leaf Display is labeled **Stem Leaf** (with bold added). Note that SAS also provides quantitative descriptions of the distribution of the unemployment rate across States with quantiles as well as the sample mean and sample variance.

*Box-and-Whisker Plots and Schematic Plots*

Box-and-Whisker plots and Schematic plots have been developed to visually analyze groups of observations. The plots are constructed based upon five basic summary statistics: the median, the upper and lower quartiles, and the upper and lower extremes. In addition, SAS distinguishes the mean in the Box-and-Whisker plots as well. We begin drawing a Box-and Whisker plot by drawing a Box with the top of the box drawn at the upper quartile, and the bottom of the box drawn at the lower quartile. A horizontal line in the middle of the box indicates the position of the median, and a "+" indicates the position of the mean. A vertical line is drawn from the top of the box to the maximum value, and a vertical line is also drawn from the bottom of the box to the minimum value. These vertical dashed lines are known as the whiskers. The Box-and-Whisker plots are labeled by **Boxplot** (with bold added).

Schematic plots are very similar to the Box-and-Whisker plots. You begin by constructing them with the same box, but the whiskers are slightly altered. We need the following terminology

| | |
| :--- | :--- |
| *Step* | $1.5 \times$ the Inter quartile range |
| *Inner Fences* | 1 Step outside the quartiles |
| *Outer Fences* | 2 Steps outside the quartiles |

The whiskers are drawn out only to the end of the inner fence, with one exception. If all sample values on the one side of the box lie within the inner fence, then the whisker is drawn out only to the most extreme value on that side of the box. Values between the quartiles and the ends of the inner fences are called *adjacent values*. Values within the outer fences but outside the inner fences are called *outside values* and labeled with a "O". Values outside the outer fences are called *far out* and are also labeled. The Schematic plots are labeled by **Schematic Plots** (bold added) in the SAS output, they are plotted side by side because we specified that we do the analysis BY YEAR. Note that in this example West Virginia is an outside value for both years.

- Notes for Class #1 & 2, page 13 of 54 -

<!-- page 14 -->

When we specified the PLOT option in PROC UNIVARIATE we also obtained a normal probability plot, which we will discuss later.

### 3. Data Analysis Assuming Normality

For much of this class we will be analyzing data from continuous distributions, and for such data we will often assume they follow a Normal , or Gaussian, distribution. There are several reasons for this assumption.

1) The normal distribution, with its "Bell Shape Curve" figure, is often a good approximation for many kinds of data.

2) Often, if the data does not look Normally distributed, then the data can be transformed to look normally distributed, by, say, a square-root or log transformation. We will discuss this more later.

3) Mathematical statistics provides us with the Central Limit Theorem, which says (loosely) that the accumulation of lots of "small errors" tend to look Normally distributed. This is why "error terms" are often approximated by the Normal Distribution.

4) Finally, the theory for Normally distributed data is well developed, and elegant.

In the next sections we will review the theory for samples from a Normal distribution.

#### 3.1 Single samples.

Let $X_1, \dots, X_n$ be a sample from a Normal distribution $N(\mu, \sigma^2)$. We will make the following assumptions.

ASSUMPTIONS

A1) The observations $X_1, \dots, X_n$ are stochastically independent (uncorrelated).

- Notes for Class #1 & 2, page 14 of 54 -

<!-- page 15 -->

A2) Every observation has the same variance (Homogeneity of variance).

A3) Every observation has the same mean.

Another way to write this is that

$$
X_i = \mu + e_i \text{ for } i=1, \dots, n
$$

where the error term $e_i$ satisfies A1 - A3 above with mean zero.

It is well known that the sample mean $\overline{X}$, where

$$
\text{(3.1)} \qquad \overline{X} = n^{-1} \sum_{i=1}^{n} X_i
$$

is also distributed as a Normal random variable

$$
\text{(3.2)} \qquad \overline{X} \sim N\left(\mu, n^{-1}\sigma^2\right)
$$

$$
\text{(3.3)} \qquad E\left\{\overline{X}\right\} = \mu
$$

$$
V\left\{\overline{X}\right\} = n^{-1}\sigma^2
$$

These last two moment properties also hold for distributions other than the normal distribution. Also the Central Limit Theorem tells us that (3.2) is approximately true in large samples for distributions other than Normal.

Note that the variance of the sample mean is inversely proportional to the sample size, which says that the variance of the sample mean gets small as the sample size increases. In this situation we say that the sample mean is a *consistent estimator* for $\mu$. This is often written

$$
\text{(3.4)} \qquad \overline{X} \xrightarrow{p} \mu \text{ as } n \to \infty
$$

- Notes for Class #1 & 2, page 15 of 54 -

<!-- page 16 -->

Which says that the sample mean *converges in probability* to the true mean. We are often interested in making inference about the parameter $\mu$. This is often stated as a Hypothesis

$$
(3.5) \qquad H_0: \mu = \mu_0 \quad \text{versus} \quad H_A: \mu \neq \mu_0
$$

If we knew the value of $\sigma^2$, then we can form the usual $Z$-statistic

$$
(3.6) \qquad Z = \frac{\bar{X} - \mu_0}{\sqrt{V(\bar{X})}} = \frac{\bar{X} - \mu_0}{\sqrt{n^{-1}\sigma^2}}
$$

Under the null hypothesis $Z$ is distributed as a standard normal random variable, and we reject the null hypothesis if the absolute value of the observed $Z$ is too large. We use the absolute value of $Z$ since the hypothesis is two-sided. That is we see evidence against the null hypothesis if either the sample mean is much larger than $\mu_0$, or much smaller than $\mu_0$. Remembering that

$$
(3.7) \qquad P\{|Z| \ge 1.96\} = 0.05
$$

we would reject the null hypothesis at the 0.05 level if the observed value of the absolute value of $Z$ was greater than 1.96. Other significance levels can also be chosen.$^1$

Instead of doing a formal test of Hypothesis as we have done it is also common to report a significance value or $p$-value. If we Let $Z$ denote a standard normal random variable, and let $z_{obs}$ denote the observed sample value, then the observed $p$-value is defined as

$$
(3.8) \qquad p\text{-value} = P\{|Z| \ge |z_{obs}|\}
$$

This is reported in nearly all Statistical packages. In words, the $p$-value gives the probability of observing something as extreme (or more extreme) than we actually observed.

In some cases it is of interest to do a one-sided test such as

---

$^1$ One source for statistical tables is http://www.statsoft.com/textbook/sttable.html, which gives tables of quantiles for the normal, $t$, chi square, anf $F$ distributions.

- Notes for Class #1 & 2, page 16 of 54 -

<!-- page 17 -->

$$(3.9) \qquad H_0 : \mu \le \mu_0 \quad \text{versus} \quad H_A : \mu > \mu_0$$

In this case we would reject the null hypothesis only if we saw values of the sample mean which were much larger than $\mu_0$, and the p-value is defined as

$$(3.10) \qquad p\text{-value} = P\{Z \ge z_{obs}\}$$

Likewise we could perform the one-sided test

$$(3.11) \qquad H_0 : \mu \ge \mu_0 \quad \text{versus} \quad H_A : \mu < \mu_0$$

and in this case we would reject the null hypothesis only if we saw values of the sample mean which were much smaller than $\mu_0$, and the $p$-value is defined as

$$(3.12) \qquad p\text{-value} = P\{Z \le z_{obs}\}$$

Instead of reporting the results of testing hypotheses, it is often common to report only Confidence Intervals. Returning to the two sided problem in (3.5), we can write

$$(3.13) \qquad P\{|Z| \ge 1.96\} = 0.05$$

also as

$$P\left\{\bar{X} - 1.96\sqrt{n^{-1}\sigma^2} \le \mu_0 \le \bar{X} + 1.96\sqrt{n^{-1}\sigma^2}\right\} = 0.95$$

which gives us the two-sided 95% confidence interval

$$(3.14) \qquad \left[\bar{X} - 1.96\sqrt{n^{-1}\sigma^2}, \bar{X} + 1.96\sqrt{n^{-1}\sigma^2}\right].$$

The interval is what is random here—not the parameter $\mu$. The interval has 95% coverage of the true mean $\mu$ in the sense that, if we collect many independent samples of $n$ units and calculate an interval of the form (3.14) from each sample, then 95% of the intervals will actually contain $\mu$ and 5% of the intervals will not. The interval from any one sample will either contain the mean $\mu$ or not. The one sided confidence interval for the hypothesis in (3.9) is

- Notes for Class #1 & 2, page 17 of 54 -

<!-- page 18 -->

$$
\left(-\infty, \bar{X} + 1.645\sqrt{n^{-1}\sigma^2}\right] \tag{3.15}
$$

while the confidence interval for the one-sided hypothesis in (3.11) is given by

$$
\left[\bar{X} - 1.645\sqrt{n^{-1}\sigma^2}, \infty\right). \tag{3.16}
$$

In both of these confidence intervals we used the fact that

$$
P\{Z \le 1.645\} = 0.95 \tag{3.17}
$$

We have concentrated on the case where we knew the variance $\sigma^2$, but in practice it is much more likely that we have to estimate it from the data. We will denote the usual sample variance estimator of $\sigma^2$ as

$$
m_{XX} = (n - 1)^{-1} \sum_{i=1}^{n} (X_i - \bar{X})^2 = (n - 1)^{-1} \left[ \sum_{i=1}^{n} X_i^2 - n\bar{X}^2 \right]. \tag{3.18}
$$

It is well known that

$$
E\{m_{XX}\} = \sigma^2, \tag{3.19}
$$

a result that holds for distributions other than Normal distribution as well. In addition, under Normality we have that

$$
(n - 1) \frac{m_{XX}}{\sigma^2} = \frac{1}{\sigma^2} \sum_{i=1}^{n} (X_i - \bar{X})^2 \sim \chi_{n-1}^2 \tag{3.20}
$$

which says that the sample variance, properly scaled, has a Chi-square distribution with $n - 1$ degrees-of-freedom. Since the variance of a Chi-square random variable is twice its degrees-of-freedom we can write the variance of the sample variance as

$$
V\{m_{XX}\} = \frac{2\sigma^4}{n - 1} \tag{3.21}
$$

- Notes for Class #1 & 2, page 18 of 54 -

<!-- page 19 -->

which we can estimate by

$$
\hat{V}\{m_{XX}\} = \frac{2m_{XX}^2}{n - 1} \tag{3.22}
$$

Lets return to the two sided hypothesis in (3.5). With the estimated sample variance we can form the $t$-statistic

$$
t = \frac{\bar{X} - \mu_0}{\sqrt{m_{XX} / n}} \tag{3.23}
$$

and we know from mathematical statistics that this random variable follows a $t$-distribution on $n - 1$ degrees-of-freedom.

The $t$-statistic can be used in exactly the same way that we used the $Z$-statistic to test two-sided and one-sided hypothesis, as well as form confidence intervals. The only difference with the $t$-statistic is that the distribution depends on the sample size whereas the $Z$-statistic did not.

The next figure compares $t$-densities with 5 and 30 degrees-of-freedom with a standard normal density.

- Notes for Class #1 & 2, page 19 of 54 -

<!-- page 20 -->

Normal densities with different variances and
$t$ densities compared with standard normal
(plotted in R)

**Normal densities with variances 1, 2, 3**

**N(0,1) and t densities with df = 5 and 30**
**Normal in circles**

- Notes for Class #1 & 2, page 20 of 54 -

<!-- page 21 -->

We have concentrated on inference about the mean parameter $\mu$, but it is often of interest to make inference about the variance parameter $\sigma^2$. For example the $(1-\alpha) \times 100\%$ Confidence Interval for $\sigma^2$ is given by

$$
(3.24) \qquad \left[ \frac{(n-1)m_{XX}}{\chi_{(n-1), \frac{\alpha}{2}}^2}, \frac{(n-1)m_{XX}}{\chi_{(n-1), 1-\frac{\alpha}{2}}^2} \right]
$$

where, for a $\chi_{n-1}^2$ random variable, $\frac{\alpha}{2}$ percent of the distribution lies to the right of $\chi_{(n-1), \frac{\alpha}{2}}^2$ and $1-\frac{\alpha}{2}$ percent of the distribution lies to the right of $\chi_{(n-1), 1-\frac{\alpha}{2}}^2$. One sided intervals can be constructed by similar methods.

**Example 2.** We will look at data taken from the National Health and Nutrition Examination Survey II. The principle investigator for NHANES is the United States Center for Disease Control and the National Center for Health Statistics. It is a nationally representative multistage probability sample with over sampling of the very young, the very old, and the poor. The entire dataset has over 20,000 individual respondents. For the purposes of illustration we will be analyzing subsets of the data. In particular we will be looking at only those individuals older then 16 years and younger than 70 years, and we will analyze the data using unit weights. Let $X_1, \dots, X_{31}$ be a sample of weights (in kilograms) of a subset of 31 men from the NHANES II dataset between the ages of 16 and 70. We will assume that the data are a random sample from a $N(\mu, \sigma^2)$ distribution. The sample mean and sample variance are

$$
\bar{X} = 72.62323 \qquad m_{XX} = 181.1336
$$

Therefore we can estimate the variance of the sample mean as

$$
\hat{V}\{\bar{X}\} = (31)^{-1}(181.1336) = 5.84302
$$

$$
se(\bar{X}) = 2.417234
$$

So we report the sample mean as

- Notes for Class #1 & 2, page 21 of 54 -

<!-- page 22 -->

$$
\begin{aligned}
\bar{X} = 72.6 \\
(2.4)
\end{aligned}
$$

We can estimate the variance of the sample variance as

$$
\hat{V}\{m_{XX}\} = (30)^{-1}2(181.1336)^2 = 2187.2921
$$

$$
se(m_{XX}) = 46.76849
$$

So we report the sample variance as

$$
\begin{aligned}
m_{XX} = 181. \\
(47.)
\end{aligned}
$$

To form a 95% confidence interval for $\mu$, we use

$$
t_{(30),.025} = 2.042
$$

$$
\bar{X} + (2.042) \times se(\bar{X}) = 77.5592
$$

$$
\bar{X} - (2.042) \times se(\bar{X}) = 67.68724
$$

So we report the 95% confidence interval for the mean $\mu$ as

$$
(67.7, 77.6)
$$

To form a 95% confidence interval for $\sigma^2$, we use

$$
\chi^2_{(30),.975} = 16.79
$$

$$
\chi^2_{(30),.025} = 46.98
$$

$$
\frac{(n - 1)m_{XX}}{\chi^2_{(30),.975}} = \frac{(30)(181.1336)}{16.79} = 323.6455
$$

- Notes for Class #1 & 2, page 22 of 54 -

<!-- page 23 -->

$$\frac{(n-1)m_{XX}}{\chi_{(30),.025}^2} = \frac{(30)(181.1336)}{46.98} = 115.666$$

So we report the 95% confidence interval for the variance $\sigma^2$

$$(116., 324.). \quad \blacksquare$$

The figure on the next page shows chi-square densities for 2, 5, 10, and 30 degrees of freedom. Several $F$-densities, which are covered in section 3.2 are also pictured.

- Notes for Class #1 & 2, page 23 of 54 -

<!-- page 24 -->

Chi Square and $F$ densities with different degrees of freedom

**Chi square densities with df = 2, 5, 10, and 30**

**F densities with df = (2,2), (5,5), (10,10), and (30,30)**

- Notes for Class #1 & 2, page 24 of 54 -

<!-- page 25 -->

3.2 Two Independent Samples.

Let $X_1, \dots, X_{n_1}$ be a sample from a normal distribution $N\left(\mu_1, \sigma_1^2\right)$, and let $Y_1, \dots, Y_{n_2}$ be a second sample from a normal distribution $N\left(\mu_2, \sigma_2^2\right)$. We will assume that the two samples are independent of each other.

This is a common situation, and one in which we wish to test the hypothesis

$$
\text{(3.24)} \qquad H_0: \mu_1 = \mu_2 \quad \text{versus} \quad H_A: \mu_1 \neq \mu_2
$$

Notice that

$$
\text{(3.25)} \qquad \overline{X} \sim N\left(\mu_1, \frac{\sigma_1^2}{n_1}\right), \text{ and } \overline{Y} \sim N\left(\mu_2, \frac{\sigma_2^2}{n_2}\right)
$$

and form the statistic $\overline{X} - \overline{Y}$ where

$$
\text{(3.26)} \qquad \overline{X} - \overline{Y} \sim N\left(\mu_1 - \mu_2, \frac{\sigma_1^2}{n_1} + \frac{\sigma_2^2}{n_2}\right)
$$

If we knew $\sigma_1^2$ and $\sigma_2^2$ then we are back (in theory) to the Z-statistic theory for the previous Section 3.1. Therefore, we will examine two situations

A1) $\sigma_1^2$ and $\sigma_2^2$ unknown, but equal.

A2) $\sigma_1^2$ and $\sigma_2^2$ unknown (assumed unequal).

*A1) $\sigma_1^2$ and $\sigma_2^2$ unknown, but equal.*

Assume that $\sigma_1^2 = \sigma_2^2 = \sigma^2$, where $\sigma^2$ is unknown. Then we can write the distribution of $\overline{X} - \overline{Y}$ as

$$
\text{(3.27)} \qquad \overline{X} - \overline{Y} \sim N\left(\mu_1 - \mu_2, \left(\frac{1}{n_1} + \frac{1}{n_2}\right)\sigma^2\right)
$$

and we can construct the *pooled estimate* of $\sigma^2$ as

- Notes for Class #1 & 2, page 25 of 54 -

<!-- page 26 -->

$$
\text{(3.28)} \qquad \hat{\sigma}_{pooled}^2 = \frac{(n_1 - 1)m_{XX} + (n_2 - 1)m_{YY}}{n_1 + n_2 - 2}
$$

which has *pooled degrees-of-freedom* $n_1 + n_2 - 2$. The pooled estimate of variance is distributed as a multiple of a Chi-square distribution

$$
\text{(3.29)} \qquad (n_1 + n_2 - 2)\frac{\hat{\sigma}_{pooled}^2}{\sigma^2} \sim \chi_{n_1 + n_2 - 2}^2
$$

and

$$
\text{(3.30)} \qquad V\left\{\sigma_{pooled}^2\right\} = \frac{2\sigma^4}{n_1 + n_2 - 2}
$$

This allows us to form the *pooled t-statistic*

$$
\text{(3.31)} \qquad t_{pooled} = \frac{\bar{X} - \bar{Y} - (\mu_1 - \mu_2)}{\sqrt{\left(\frac{1}{n_1} + \frac{1}{n_2}\right)\hat{\sigma}_{pooled}^2}} \sim t_{n_1 + n_2 - 2}
$$

which is distributed as a central *t* random variable with pooled degrees-of-freedom $n_1 + n_2 - 2$ if $H_0$ is true.

**Example 2.** (Continued). We continue the analysis of the NHANES II data begun in the previous section. In addition to the sample of weights for men, assume we also have an independent sample of size 31 of weights for women. Let this sample be denoted by $Y_1, \dots, Y_{31}$ and assume they have a $N\left(\mu_2, \sigma_2^2\right)$ distribution. The sample statistics are

$$
\bar{X} = 72.62323 \qquad m_{XX} = 181.1336
$$

$$
\bar{Y} = 64.16968 \qquad m_{YY} = 141.145
$$

Therefore

- Notes for Class #1 & 2, page 26 of 54 -

<!-- page 27 -->

$$\overline{X} - \overline{Y} = 8.45355$$

$$\hat{\sigma}_{pooled}^2 = \frac{(30)(181.1336) + (30)(141.145)}{60} = 161.1393$$

$$se(\overline{X} - \overline{Y}) = \sqrt{(\tfrac{1}{31} + \tfrac{1}{31})\hat{\sigma}_{pooled}^2} = 3.22429$$

Therefore the 95% confidence interval the difference $\mu_1 - \mu_2$ uses $t_{(60),.025} = 2.000$, and is given by

$$(2.0, 14.9)$$

and the sample estimate is reported as

$$\begin{aligned}
\overline{X} - \overline{Y} &= 8.5 \\
&\quad (3.2) \qquad\qquad\qquad\qquad\qquad\qquad\qquad\qquad\qquad\qquad\qquad\qquad \blacksquare
\end{aligned}$$

Note that there can be overlap in the distribution of men's and women's weights even though the means can be different. Some men will weigh less than some women, for example.

We have been assuming that the variances $\sigma_1^2$ and $\sigma_2^2$ are equal, but in general we rarely know this, and instead need to test this hypothesis. The hypothesis is

$$(3.32) \qquad H_0: \sigma_1^2 = \sigma_2^2 \quad \text{versus} \;\; H_A: \sigma_1^2 \neq \sigma_2^2$$

Under the Normality assumptions for the two independent samples we know that the sample variances from the two samples are distributed as multiples of independent central Chi-square random variables

$$(3.33) \qquad (n_1 - 1)\frac{m_{XX}}{\sigma_1^2} \sim \chi_{n_1-1}^2$$

$$(n_2 - 1)\frac{m_{YY}}{\sigma_2^2} \sim \chi_{n_2-1}^2$$

- Notes for Class #1 & 2, page 27 of 54 -

<!-- page 28 -->

Therefore, if we form the test statistic

$$
(3.34) \quad F = \frac{m_{XX}}{m_{YY}} \sim F_{n_2 - 1}^{n_1 - 1}
$$

it has a central $F$-distribution with numerator degrees-of-freedom $n_1 - 1$ and denominator degrees-of-freedom $n_2 - 1$ when $\sigma_1^2 = \sigma_2^2$. In general, we would reject the hypothesis that $H_0: \sigma_1^2 = \sigma_2^2$ if either $F$ is too small or too large. In practice it is common to construct the $F$ statistic so that it is always greater than 1, by placing the larger sum-of-squares in the numerator and the smaller sum-of-squares in the denominator, and then rejecting the hypothesis $H_0: \sigma_1^2 = \sigma_2^2$ if $F$ is too large. For example if we wanted to test the hypothesis at the $\alpha = 0.05$ level we would compare the resulting $F$ statistics to the point $F_d^n(0.025)$, where $d$ is the degrees-of-freedom of the sum-of-squares in the denominator and $n$ is the degrees-of-freedom of the sum-of-squares in the numerator.

**Example 2.** (Continued). We continue the analysis of the NHANES II data begun in the previous sections. We wish to test the hypothesis that the variances of measured weights for men and women are the same. Therefore, we form the $F$ statistic

$$
F = \frac{(181.1336)}{(141.145)} = 1.283
$$

which is distributed as a central $F_{30}^{30}$ random variable. From the tables for an $F$ distribution we find that

$$
F_{30}^{30}(0.025) = 2.07
$$

Since this is greater than the observed $F$ statistic, we accept the hypothesis that $\sigma_1^2 = \sigma_2^2$ (more accurately, we fail to reject the hypothesis that $\sigma_1^2 = \sigma_2^2$). $\blacksquare$

*A2) $\sigma_1^2$ and $\sigma_2^2$ unknown (assumed unequal).*

Now we assume that $\sigma_1^2 \neq \sigma_2^2$. This could come about from prior knowledge about the samples, or from a formal test of the hypothesis of equality given above. It is natural to want to form the following statistic

- Notes for Class #1 & 2, page 28 of 54 -

<!-- page 29 -->

$$
(3.35) \qquad t' = \frac{\bar{X} - \bar{Y} - (\mu_1 - \mu_2)}{\sqrt{\frac{m_{XX}}{n_1} + \frac{m_{YY}}{n_2}}}
$$

where we have replaced the unknown variances by the sample variance estimates from each of the samples. In large samples, this statistic will be approximately normally distributed even when the variances are not equal. Unfortunately, in small samples this statistic does not have a $t$-distribution even when the input data are normal. Forms of the distribution of $t'$ have been discussed by Behrens and Fisher, and the problem is often referred to as the "Behrens Fisher Problem". Tables exist for the distribution of $t'$, but we will use an approximation due to Satterthwaite which treats $t'$ as distributed as a $t$ random variable with an estimated (or approximate) number of degrees-of-freedom. Define the following notation

$$
(3.36) \qquad v_1 = n_1^{-1} m_{XX}
$$

$$
v_2 = n_2^{-1} m_{YY}
$$

$$
d' = \frac{(v_1 + v_2)^2}{\frac{v_1^2}{(n_1 - 1)} + \frac{v_2^2}{(n_2 - 1)}}
$$

where we round the value of $d'$ down to the nearest integer. We then approximate the distribution of $t'$ as a $t$-distribution with $d'$ degrees-of-freedom.

**Example 2.** (Continued). We continue the analysis of the NHANES II data begun in the previous sections, this time assuming that the variance of observed weight is different for men and women.

$$
\bar{X} = 72.62323 \qquad m_{XX} = 181.1336 \qquad n_1 = 31
$$

$$
\bar{Y} = 64.16968 \qquad m_{YY} = 141.145 \qquad n_2 = 31
$$

We can write

- Notes for Class #1 & 2, page 29 of 54 -

<!-- page 30 -->

$$
t' = \frac{72.62323 - 64.16968}{\sqrt{\frac{181.1336}{31} + \frac{141.145}{31}}} = 2.6218
$$

$$
v_1 = \frac{181.1336}{31} = 5.843019
$$

$$
v_2 = \frac{141.145}{31} = 4.553065
$$

$$
d' = \frac{(5.843019 + 4.553065)^2}{\frac{(5.843019)^2}{31} + \frac{(4.553065)^2}{31}} = 59.09
$$

which we round down to $d' = 59$. Since $t_{(59),.025} \approx 2.001$ we accept the hypothesis that men weigh more than women on average. To form a 95% confidence interval we use

$$
se(\overline{X} - \overline{Y}) = \sqrt{\frac{181.1336}{31} + \frac{141.145}{31}} = 3.22429
$$

$$
\overline{X} - \overline{Y} = 8.45355
$$

so we report the 95% confidence interval as

$$
(2.0, 14.9) \quad \blacksquare
$$

An interesting fact to note is that in the example above we got the same estimate of the standard error for the difference of the sample means $\overline{X} - \overline{Y}$, as we did earlier when we used the pooled estimate of variance. This phenomena will occur whenever the sample sizes for the two sample are equal $n_1 = n_2$, which also has the effect that the $t$ statistic above is algebraically equal to the pooled $t$ statistic. Remember that depending upon whether the sample variances $\sigma_1^2$ and $\sigma_2^2$ are equal or not, we will treat the distribution of the $t$ statistic differently.

### 3.3 Paired Samples.

- Notes for Class #1 & 2, page 30 of 54 -

<!-- page 31 -->

In the previous section we are interested in making inference about two normal distributions $N(\mu_1, \sigma_1^2)$ and $N(\mu_2, \sigma_2^2)$ given independent samples from each distribution. In some situations the assumption of independence between the two samples is violated, since the observations in the two samples are correlated. A common setup is the following. We observe a sample of independent identically distributed pairs of observations $(X_1, Y_1), \dots, (X_n, Y_n)$ each from the same joint distribution with

$$(3.37) \qquad E\left\{\begin{pmatrix} X \\ Y \end{pmatrix}\right\} = \begin{pmatrix} \mu_X \\ \mu_Y \end{pmatrix}$$

$$V\left\{\begin{pmatrix} X \\ Y \end{pmatrix}\right\} = \begin{pmatrix} \sigma_{XX} & \sigma_{XY} \\ \sigma_{YX} & \sigma_{YY} \end{pmatrix}$$

For now we will leave the form of the joint distribution unspecified. In the next section we will introduce a particular joint distribution, the Bivariate Normal distribution. Assume that the key interest is making inference about the difference in the means

$$(3.38) \qquad E\left\{\bar{X} - \bar{Y}\right\} = \mu_X - \mu_Y$$

Notice that under this setup the variance of the difference of the sample means is given by

$$(3.39) \qquad V\left\{\bar{X} - \bar{Y}\right\} = \frac{1}{n} (\sigma_{XX} + \sigma_{YY} - 2\sigma_{XY})$$

which says that the presence of a positive covariance reduces the variance of the difference of the sample means, while a negative correlation increases the variance of the difference. If we form the random variable

$$(3.40) \qquad D_i = X_i - Y_i \text{ for } i = 1, \dots, n$$

then we will make the assumption that $D_1, \dots, D_n$ is a sample of independent identically distributed random variables with mean and variance given by

$$(3.41) \qquad E\{D\} = \mu_X - \mu_Y$$

- Notes for Class #1 & 2, page 31 of 54 -

<!-- page 32 -->

$$
V\{D\} = \sigma_{XX} + \sigma_{YY} - 2\sigma_{XY}.
$$

We can then use the theory for a single sample developed earlier to make inference about the mean and variance given in (3.41).

**Example 3.** We again analyze observations taken from the NHANES II data set described earlier, with observations restricted to the individuals greater than 16 years of age, and younger than 70 years old. In several cases respondents belonged to the same family, so we selected a subsample of 22 pairs of men and women for the same families and recorded their weights in kilograms. The summary statistics are given below.

$$
\begin{pmatrix} \overline{X} \\ \overline{Y} \end{pmatrix} = \begin{pmatrix} 75.82909 \\ 62.81909 \end{pmatrix}
$$

$$
\begin{pmatrix} m_{XX} & m_{XY} \\ m_{XY} & m_{YY} \end{pmatrix} = \begin{pmatrix} 276.46404 & 70.5579563 \\ 70.5579563 & 176.6832563 \end{pmatrix}
$$

where we have used $X$ to denote men and $Y$ to denote women. This implies that

$$
\overline{D} = 13.01
$$

$$
m_{DD} = m_{XX} + m_{YY} - 2m_{XY} = 312.03138
$$

Therefore

$$
se\left(\overline{D}\right) = 3.76606
$$

and we report the difference of the sample means as

$$
\begin{aligned}
\overline{D} &= 13.0 \\
&\quad (3.8)
\end{aligned}
$$

and we report the 95% confidence interval for the mean difference as

$$
(5.2, 20.8)
$$

- Notes for Class #1 & 2, page 32 of 54 -

<!-- page 33 -->

where we used $t_{(21),.025} = 2.080$. $\blacksquare$

### 3.4 Bivariate Normality

In the previous section we examined the case of observing a random sample of pairs of observations. In this section we examine the specific case when the pairs are distributed as Bivariate Normal random variables. We write this as

$$
\begin{pmatrix} X \\ Y \end{pmatrix} \sim N \left( \begin{pmatrix} \mu_X \\ \mu_Y \end{pmatrix}, \begin{pmatrix} \sigma_{XX} & \sigma_{XY} \\ \sigma_{XY} & \sigma_{YY} \end{pmatrix} \right) \tag{3.42}
$$

A convenient fact about the bivariate normal distribution is that any linear combination of the components of a bivariate normal distribution is distributed as a univariate normal distribution. This implies that the two marginal distributions for $X$ and $Y$ are themselves normally distributed

$$
X \sim N(\mu_X, \sigma_{XX}) \tag{3.43}
$$

$$
Y \sim N(\mu_Y, \sigma_{YY})
$$

The bivariate normal distribution is often defined in terms of the correlation coefficient $\rho_{XY}$ instead of the covariance $\sigma_{XY}$

$$
\rho_{XY} = \frac{\sigma_{XY}}{\sqrt{\sigma_{XX}\sigma_{YY}}} \tag{3.44}
$$

The correlation coefficient is always in the range $[-1, 1]$. Pictures of bivariate normal densities are shown below that have correlations of $0$ and $0.75$.

- Notes for Class #1 & 2, page 33 of 54 -

<!-- page 34 -->

**Bivariate normal density, cor = 0**

**Bivariate normal density, cor = 0.75**

A particularly useful feature of the bivariate normal distribution are the conditional distributions which it implies. For instance, if we condition on the event $X = x$ where $X$ refers to the random variable and $x$ refers to a particular realization we get

$$(3.45) \qquad E\{Y | X = x\} \equiv \mu_{Y|x} = \mu_Y + \frac{\sigma_{XY}}{\sigma_{XX}}(x - \mu_X)$$

$$V\{Y | X = x\} \equiv \sigma_{Y|x}^2 = \sigma_{YY} - \frac{\sigma_{XY}^2}{\sigma_{XX}}$$

Which says that

(3.46) 1) The conditional expectation of $Y$ conditional on $X = x$ is linear in $x$.

2) The conditional variance of $Y$ given $X = x$ does not depend on $x$.

A further very important fact is the conditional distribution of $Y$ given $X = x$ is a Normal distribution given by

$$(3.47) \qquad (Y | X = x) \sim N(\mu_{Y|x}, \sigma_{Y|x}^2)$$

These definitions are symmetric in the variables $X$ and $Y$, in the sense that it is also true that

- Notes for Class #1 & 2, page 34 of 54 -

<!-- page 35 -->

$$(X | Y = y) \sim N\left(\mu_{X|y}, \sigma_{X|y}^2\right) \tag{3.48}$$

$$E\{X | Y = y\} \equiv \mu_{X|y} = \mu_X + \frac{\sigma_{XY}}{\sigma_{YY}}(y - \mu_y)$$

$$V\{X | Y = y\} \equiv \sigma_{X|y}^2 = \sigma_{XX} - \frac{\sigma_{XY}^2}{\sigma_{YY}}$$

If we write the conditional variances in terms of the correlation coefficient we get

$$V\{Y | X = x\} = \sigma_{YY}\left(1 - \rho_{XY}^2\right) \tag{3.49}$$

$$V\{X | Y = y\} = \sigma_{XX}\left(1 - \rho_{XY}^2\right)$$

or that

$$\frac{V\{Y | X = x\}}{V\{Y\}} = 1 - \rho_{XY}^2 \tag{3.50}$$

$$\frac{V\{X | Y = y\}}{V\{X\}} = 1 - \rho_{XY}^2$$

so the proportional decrease in variance due to conditioning (compared to the unconditional variance) is the same for both conditional distributions. Note that if $\rho_{XY} = 0$ there is no reduction in variance, while as $\rho_{XY}$ approaches either -1 or 1 then the proportional reduction in variance is substantial. Further, if $\rho_{XY} = 0$ the slope coefficient in (3.45) or (3.47) is zero while if $\rho_{XY} \neq 0$ then the slope coefficient has the same sign as $\rho_{XY}$, which follows from the fact that

$$\frac{\sigma_{XY}}{\sigma_{XX}} = \rho_{XY}\sqrt{\frac{\sigma_{YY}}{\sigma_{XX}}} \tag{3.51}$$

$$\frac{\sigma_{XY}}{\sigma_{YY}} = \rho_{XY}\sqrt{\frac{\sigma_{XX}}{\sigma_{YY}}}$$

- Notes for Class #1 & 2, page 35 of 54 -

<!-- page 36 -->

Because of the relationship in (3.50) $\rho_{XY}$ is often said to measure the strength of the relationship between the variables $Y$ and $X$. Therefore it is of interest to test the hypothesis

$$
\text{(3.52)} \qquad H_0 : \rho_{XY} = \rho_0 \quad \text{versus} \quad H_A : \rho_{XY} \neq \rho_0
$$

for some specified value $\rho_0$.

The sample correlation coefficient is given by

$$
\text{(3.53)} \qquad r_{XY} = \frac{m_{XY}}{\sqrt{m_{XX}m_{YY}}}
$$

and can be used to test hypotheses of the form (3.52) and form confidence intervals for $\rho_{XY}$. Under Normality, the variance of the sample correlation can be estimated by

$$
\text{(3.54)} \qquad \hat{V}\{r_{XY}\} \approx \frac{\left(1 - r_{XY}^2\right)^2}{(n - 3)}
$$

for sample sizes greater than 3. When the true correlation is $\rho_{XY} = 0$ then the distribution of the sample correlation coefficient is known and has been tabled. See Table A10 page 473 of **Statistical Methods**. Unfortunately those tables can not be used to test the hypothesis in (3.52) for $\rho_{XY} \neq 0$.

For the case $\rho_{XY} \neq 0$ Fisher developed a clever method known as Fisher's z-statistic, or z transformation. It is given by

$$
\text{(3.55)} \qquad Z_{XY} = \frac{1}{2} \ln\left\{\frac{1 + r_{XY}}{1 - r_{XY}}\right\}
$$

which implies that

$$
\text{(3.56)} \qquad r_{XY} = \frac{e^{2Z_{XY}} - 1}{e^{2Z_{XY}} + 1}
$$

Fisher worked out the approximate distribution of $Z_{XY}$ for large samples to be

- Notes for Class #1 & 2, page 36 of 54 -

<!-- page 37 -->

$$
(3.57) \qquad Z_{XY} \approx N\left(\frac{1}{2} \ln\left\{\frac{1+\rho_{XY}}{1-\rho_{XY}}\right\}, \frac{1}{n-3}\right)
$$

which says that $Z_{XY}$ is approximately Normally distributed with variance that only depends upon the sample size. There are two important ways to use the Z transform, to test hypotheses for $\rho_{XY} \neq 0$, and confidence intervals for $\rho_{XY}$. To test the hypothesis that $\rho_{XY} = \rho_0$ we form

$$
(3.58) \qquad Z_{XY} = \frac{1}{2} \ln\left\{\frac{1+r_{XY}}{1-r_{XY}}\right\}
$$

$$
z_0 = \frac{1}{2} \ln\left\{\frac{1+\rho_0}{1-\rho_0}\right\}
$$

$$
Test - Statistic = \frac{Z_{XY} - z_0}{\frac{1}{\sqrt{n-3}}} = \sqrt{n-3}(Z_{XY} - z_0)
$$

which is approximately distributed as a standard normal random variable under the null hypothesis that $\rho_{XY} = \rho_0$. Therefore we reject the hypothesis if the observed value of $Z_{XY}$ is large in absolute value.

To form a confidence interval for the correlation $\rho_{XY}$ we do the following. First we form a $(1-\alpha) \times 100\%$ confidence interval on the Z-scale by

$$
(3.59) \qquad Z_{Lower} = Z_{XY} - \frac{z_{\alpha/2}}{\sqrt{n-3}}
$$

$$
Z_{Upper} = Z_{XY} + \frac{z_{z_{\alpha/2}}}{\sqrt{n-3}}
$$

where $z_{\alpha/2}$ is the cutoff value on the standard normal distribution. Note that $z_{.025} = 1.96$. Then we form

$$
(3.60) \qquad \hat{\rho}_{Lower} = \frac{e^{2Z_{Lower}} - 1}{e^{2Z_{Lower}} + 1}
$$

- Notes for Class #1 & 2, page 37 of 54 -

<!-- page 38 -->

$$\hat{\rho}_{Upper} = \frac{e^{2Z_{Upper}} - 1}{e^{2Z_{Upper}} + 1}$$

Tables exist for transforming $r_{XY}$ to $Z_{XY}$, and from $Z_{XY}$ to $r_{XY}$. See Tables A12 and A13 pages 474-475 in **Statistical Methods**.

**Example 4.** In Example 3, we examined 22 pairs of observations of weights for men and women from 22 families. The sample correlation coefficient for this data is given by

$$r_{XY} = 0.31925$$

indicating a positive degree of association between weight measurements between men and women from the same family. In other words, heavier men seem to be paired with heavier women in families, and lighter men occur with lighter women in families. We would report this as

$$\begin{aligned}
r_{XY} &= 0.32 \\
&\phantom{=} (0.21)
\end{aligned}$$

To test whether the actual population correlation coefficient $\rho_{XY}$ is equal to zero (i.e. no association) we can check the significance levels in Table A 10 from Snedecor and Cochran's **Statistical Methods** for the row with 20 degrees-of-freedom and we see that the *p-value* must be greater than 0.10 since the two tailed value at the 10% level is 0.360 and we observed a value smaller than that. When run in the program SAS `proc corr` the *p*-value is given as 0.1476. Therefore we can not reject the hypothesis that there is actually no correlation between men and women's weights within families.

To form a 95% confidence interval for the correlation coefficient we proceed as follows.

$$Z = \frac{1}{2} \ln \left\{ \frac{1 + 0.31925}{1 - 0.31925} \right\} = 0.33081177$$

$$Z_{Lower} = Z - \frac{1.96}{\sqrt{19}} = -0.11884307$$

- Notes for Class #1 & 2, page 38 of 54 -

<!-- page 39 -->

$$
Z_{Lower} = Z + \frac{1.96}{\sqrt{19}} = 0.78046661
$$

$$
\hat{\rho}_{Lower} = -0.11828671
$$

$$
\hat{\rho}_{Upper} = 0.65297444
$$

which we report as

$$
(-0.12, 0.65)
$$

which is the same number of digits reported in Table A 13 of **Statistical Methods**. Note that this confidence interval covers zero which matches the result we got when we performed the specific test above.

We next present another interesting way to use the correlation coefficient test. In Section 3.2 we constructed an $F$ test of whether the variance from two independent samples were equal. We applied it in an example to test whether the variance in women's weights was equal to the variance in men's weights. That same test may be of interest when the data occur in pairs as we have been assuming in the last two sections. Unfortunately, the $F$ test described in (3.34) does not have an $F$ distribution when the data are correlated. We next describe an alternative test using the correlation coefficient techniques we have been discussing, which can be used to test the equality of two variances in the presence of correlated data. First we form the variable

$$
D = X - Y
$$

$$
S = X + Y
$$

Then

$$
E\left\{\begin{pmatrix} D \\ S \end{pmatrix}\right\} = \begin{pmatrix} \mu_X - \mu_Y \\ \mu_X + \mu_Y \end{pmatrix}
$$

$$
V\left\{\begin{pmatrix} D \\ S \end{pmatrix}\right\} = \begin{pmatrix} \sigma_{XX} + \sigma_{YY} - 2\sigma_{XY} & \sigma_{XX} - \sigma_{YY} \\ \sigma_{XX} - \sigma_{YY} & \sigma_{XX} + \sigma_{YY} + 2\sigma_{XY} \end{pmatrix}
$$

- Notes for Class #1 & 2, page 39 of 54 -

<!-- page 40 -->

and the random variable $D$ and $S$ are bivariately normally distributed. Notice that since

$$\sigma_{DS} = \sigma_{XX} - \sigma_{YY} = \rho_{DS}\sqrt{\sigma_{DD}\sigma_{SS}}$$

the correlation coefficient $\rho_{DS}$ will be zero if the two variances, $\sigma_{XX}$ and $\sigma_{YY}$, are equal. For this example

$$\begin{pmatrix} m_{DD} & m_{DS} \\ m_{DS} & m_{SS} \end{pmatrix} = \begin{pmatrix} 312.0313810 & 99.7807810 \\ 99.7807810 & 594.2632061 \end{pmatrix}$$

which gives

$$r_{DS} = 0.23172$$

and from Table A 10 from Snedecor and Cochran's **Statistical Methods** for the row with 20 degrees-of-freedom and we see that the *p-value* must be greater than $0.10$ since the two tailed value at the 10% level is $0.360$ and we observed a value smaller than that. In fact SAS `proc corr` reports a *p*-value of $0.2994$. Therefore we cannot reject the hypothesis that variation in men and women's weights are the same. Note that this is same conclusion that was reached when the $F$ test performed on the two independent samples to test whether the two sampled could be pooled.

$\blacksquare$

### 3.5 Tests of Normality

We have described a number of procedures which require data to have a Normal distribution. Therefore it is important to assess if the normality assumption is appropriate for a particular set of data. In this section we will describe a number of procedures to assess normality.

Perhaps the most useful visual tool of inspecting normality is the *Rankit Plot*, also known as *Q-Q Plots*. Assume we have a random sample $X_1, \dots, X_n$ from an unknown distribution that we want to test against normality. Perform the following steps.

*Step 1* Order the observations $X_{1:n}, X_{2:n}, \dots, X_{n:n}$.

- Notes for Class #1 & 2, page 40 of 54 -

<!-- page 41 -->

*Step 2* Obtain the Rankits $m_{1:n}, m_{2:n}, \dots, m_{n:n}$, which are approximations to the expected order statistics from a sample of size $n$ from a standard normal distribution. (Note that these have mean $0$ and variance $1$.)

*Step 3* Create the $(y, x)$ pairs $(X_{1:n}, m_{1:n}), (X_{2:n}, m_{2:n}), \dots, (X_{n:n}, m_{n:n})$ and plot them.

In general, if the unknown distribution is Normal then the data points in Step 3 should fall roughly on a straight line with positive slope. Deviations from that straight line fit indicate particular departures from normality. We describe some of these next.

*Skewness*

If a random variable $X$ has mean $\mu$ and variance $\sigma^2$, then its standardized skewness is given by

$$
\text{Skewness} = \frac{E\left\{(X - \mu)^3\right\}}{\sigma^3} \tag{3.61}
$$

For symmetric distributions, such as the normal distribution, the skewness is zero. *Positive Skewness* is indicative of distributions which have heavy tails to the right, such as the Chi-square distribution. The graph below shows the Rankit Plot for a positively skewed distribution. The observed values are on the vertical ($y$) axis and he theoretical values are on the horizontal ($x$) axis.

- Notes for Class #1 & 2, page 41 of 54 -

<!-- page 42 -->

*Negatively Skewed* distributions have heavy tails to the left. The graph below shows the Rankit Plot for a negatively skewed distribution.

It should be noted that tests of normality based on estimated skewness exist, and tend to reject the hypothesis of normality when the estimated skewness is much different from 0.

*Kurtosis*

If a random variable $X$ has mean $\mu$ and variance $\sigma^2$, then its standardized kurtosis is given by

$$
(3.62) \qquad \text{Kurtosis} = \frac{E\left\{(X - \mu)^4\right\}}{\sigma^4}
$$

For a normal random variable the kurtosis is 3. Care should be taken when dealing with reported kurtosis values since sometimes people subtract off the value 3 from the definition in (3.62) which would then be a kurtosis relative to the Normal distribution. SAS, for example, subtracts off 3 when it reports a kurtosis. Distributions with a large kurtosis tend to have large tails in both directions, such as the $t$-distribution with low degrees-of-freedom. In the graph below we show a Rankit Plot for a distribution with a large kurtosis.

- Notes for Class #1 & 2, page 42 of 54 -

<!-- page 43 -->

Distributions with a small kurtosis tend to have small tails in both directions, such as uniform distribution on $(-1, 1)$. In the graph below we show a Rankit Plot for a distribution with a small kurtosis.

It should be noted that tests of normality based on estimated kurtosis exist, and tend to reject the hypothesis of normality when the estimated kurtosis is much different from 3.

The next figure shows a histogram and QQ-plot of precipitation data taken from Venables and Ripley (1999), *Modern Applied Statistics with S-Plus*, Third Edition, Springer-Verlag. The skewness of the distribution causes the points in the two tails to be off the diagonal reference line.

- Notes for Class #1 & 2, page 43 of 54 -

<!-- page 44 -->

## Example of a Q-Q plot

### Precipitation [in/yr] for 70 US cities

### Normal Q-Q plot

Precipitation [in/yr] for 70 US cities

- Notes for Class #1 & 2, page 44 of 54 -

*[Figure: The page contains two plots showing precipitation (in/yr) for 70 US cities: the top is a cyan histogram plotting relative density (0.000 to 0.030) on the y-axis against precipitation intervals (0 to 70) on the x-axis, and the bottom is a Normal Q-Q plot comparing the observed precipitation values (10 to 60 on the y-axis) against theoretical normal quantiles (-2 to 2 on the x-axis). The histogram reveals a main peak between 30 and 50 in/yr with a smaller secondary cluster between 10 and 20 in/yr, which corresponds to the Q-Q plot where data points closely follow the diagonal reference line in the middle range (30 to 50) but deviate below it at the lower tail and slightly above it at the upper tail.]*

<!-- page 45 -->

While the Rankit plot is a useful graphical tool in its own right, there is also a very useful test statistic associated with it known as the Shapiro-Wilk Statistic. The Shapiro-Wilk Statistic is given by

$$
W = \left[ \frac{\sum_{i=1}^{n} \left( X_{i:n} - \overline{X} \right) \left( m_{i:n} - \overline{m} \right)}{\sqrt{\sum_{i=1}^{n} \left( X_{i:n} - \overline{X} \right)^2 \sum_{i=1}^{n} \left( m_{i:n} - \overline{m} \right)^2}} \right]^2 \tag{3.63}
$$

which is the same as the square of the sample correlation of the data points in the rankit plot. Since the sample mean of the rankits is always zero, we can also write

$$
W = \frac{\left[ \sum_{i=1}^{n} X_{i:n} m_{i:n} \right]^2}{\sum_{i=1}^{n} \left( X_{i:n} - \overline{X} \right) \sum_{i=1}^{n} m_{i:n}^2} \tag{3.64}
$$

The $W$ statistic always takes on values in $[0,1]$, and values close to 1 tend support the hypothesis of Normality, while very much less than one tend to reject the hypothesis of Normality. The critical values of the distribution of the $W$ statistic have been tabled. SAS computes the $W$ statistic, along with $p$-values, for samples of size less than 50.

There is another class of tests of normality know as *EDF Statistics*, where EDF stands for Empirical Distribution Function. The empirical distribution function is a step function which puts mass $n^{-1}$, where $n$ is the sample size, at each of the observed sample point. The empirical distribution function can be written in terms of the indicator function as

$$
\hat{F}_n(x) = n^{-1} \sum_{i=1}^{n} 1(X_i \le x) \tag{3.65}
$$

where $1(\bullet)$ is the indicator function which takes on the value 1 when the argument is true, and 0 otherwise. This is compared to the normal distribution function

$$
\hat{\Phi}_n(x) = \Phi \left( \frac{x - \overline{X}}{\sqrt{m_{XX}}} \right) \tag{3.66}
$$

- Notes for Class #1 & 2, page 45 of 54 -

<!-- page 46 -->

where $\Phi(\bullet)$ is the standard normal distribution function. We have graphed these two functions below for a random sample of size 11 from a $N(0,1)$ distribution.

The class of EDF statistics rejects the hypothesis of normality when the distance between the empirical distribution function and the normal distribution is large. The many possible ways to measure distance between the two curves gives rise to many different EDF statistics. Perhaps the most popular one, and the one given in SAS for large samples, is the *Kolmogorov-Smirnov Statistic*. This statistic measures distance as the largest absolute difference between the curves. The distribution of the Kolmogorov-Smirnov Statistic has been tabled.

**Example 5.** We illustrate the Rankit plot and Shapiro-Wilk statistic with the NHANES II data for the observations on 31 men analyzed in Example 2. We show the Rankit plot below. Note there appears to be an extreme positive tail to the distribution. The $W$ statistic is given by

$$
W = .852
$$

with a $p$-value of 0.0004. Therefore the assumption of normality seems to be violated. We obtained the test for normality by run a `proc univariate` with the `normal` option.

- Notes for Class #1 & 2, page 46 of 54 -

<!-- page 47 -->

**Rankit plot for Men's Weights**

$\blacksquare$

### 3.6 Power Calculations and Sample Size Determination

(based on S&C, sec. 4.13)

In planning an experiment or designing a sample, one of the key questions is how large should the sample size be? One way of determining sample size when the means of two groups are to be compared is through a power calculation. Roughly speaking, power is a measure of how likely you are to recognize a certain size of difference. A sample size is determined that will allow a certain size of difference to be detected with high probability.

Suppose that an experimenter decides that a difference of $\delta$ between the true means is important to recognize. If the true difference is $\delta$, the experimenter would like the sample size to be large enough so that there is a specified probability of showing a statistically significant difference between the treatment means. Setting the detection probability at 0.80 or 0.90 is common practice.

The size of the budget is critical. If the power calculation leads to an unaffordable sample size, the experiment will have to be scaled back. In some cases, the study may have to be abandoned entirely if meaningful differences cannot be detected with the size of sample that can be afforded.

Three things are needed for the power and sample size calculations:

- Notes for Class #1 & 2, page 47 of 54 -

<!-- page 48 -->

(1) Value of $\delta$;

(2) Desired probability $P'$ of obtaining a significant test result when the true difference is $\delta$; and

(3) Significance level $\alpha$ of the test, which can be either 1-sided or 2-sided.

As an example, consider the paired case covered in section 3.3 where we measure an $X$ and a $Y$ on each unit. We test the hypothesis

$$H_0 : \mu_X \le \mu_Y \text{ versus } H_A : \mu_X > \mu_Y \text{ at level } \alpha$$

using the test statistic

$$Z = \frac{\bar{D}}{\sqrt{V\{\bar{D}\}}}$$

with $\bar{D} = \bar{X} - \bar{Y}$, $V\{\bar{D}\} = V\{D\}/n$, and $V\{D\} = \sigma_{XX} + \sigma_{YY} - 2\sigma_{XY}$ is the variance of $D_i = X_i - Y_i$ as in section 3.3.

The null hypothesis of no difference in the means will be rejected if $Z > z_\alpha$ where $z_\alpha$ is the point on a standard normal distribution with $100\alpha$ % of the area to the right of that point. For example, with an 0.05 level, 1-sided test, $z_\alpha = 1.645$. If the true mean difference is some $\delta > 0$, then the mean of $Z$ is $\delta / \sqrt{V\{\bar{D}\}}$ instead of 0. The probability that $Z$ is in the rejection region is then

$$\begin{aligned}
P\{Z > z_\alpha \mid \mu_D = \delta\} &= P\left\{Z - \frac{\delta}{\sqrt{V\{\bar{D}\}}} > z_\alpha - \frac{\delta}{\sqrt{V\{\bar{D}\}}} \;\middle|\; \mu_D = \delta\right\} \\
&= P\left\{N(0,1) > z_\alpha - \frac{\delta}{\sqrt{V\{\bar{D}\}}}\right\}
\end{aligned}$$

This is the ***power*** of the test against the alternative $\mu_D = \mu_X - \mu_Y = \delta$.

- Notes for Class #1 & 2, page 48 of 54 -

<!-- page 49 -->

Figure 1 illustrates the situation. If $H_0$ is true and $Z$ has mean 0, the test statistic will have a standard normal distribution. The rejection region is marked in yellow and has area $\alpha$, say, 0.05. If the mean of the differences $\delta > 0$, then the mean of $Z$ is $\delta / \sqrt{V\{\bar{D}\}}$ and the distribution of $Z$ is shifted to the right. The probability of being in the rejection region for the shifted distribution is the area to the right of 1.645 (green plus yellow).

Figure 1. Normal densities of test statistics under $H_0$ and $H_A$. $\delta / \sqrt{V\{\bar{D}\}}$ is set equal to 3 in this illustration so that $E\{Z | H_A \text{ is true}\} = 3$. A 2-sided test is conducted at the 0.05 level.

- Notes for Class #1 & 2, page 49 of 54 -

*[Figure: The plot displays two overlapping normal probability density curves (vertical axis ranging from 0.0 to 0.4) plotted against a test statistic $Z$ (horizontal axis ranging from -2 to 6), comparing a null hypothesis distribution ($H_0$, black curve centered at $Z = 0$ with $\mu_D = 0$) and an alternative hypothesis distribution ($H_A$, red curve shifted to the right and centered at $Z = 3$ with $\mu_D = \delta$). It illustrates a hypothesis test rejection region to the right of $Z \approx 1.645$, where the small upper tail area under $H_0$ is shaded in yellow and the much larger area under $H_A$ in the same region is shaded in green (plus the overlapping yellow area).]*

<!-- page 50 -->

Suppose we want the power, i.e., the probability of being to the right of 1.645 to be $\beta$ (e.g., 0.80). Let $z_\beta$ be the point on the standard normal distribution with area $\beta$ to its right. We set $z_\beta$ equal to $z_\alpha - \frac{\delta}{\sqrt{V\{D\}/n}}$ and solve for the sample size $n$ to obtain

$$
n = \left[ \frac{\sqrt{V\{D\}}(z_\alpha - z_\beta)}{\delta} \right]^2
$$

**Example.** Continuing with Example 3 in section 3.3, suppose that we want to have a sample of pairs of men and women that is large enough to detect a difference in mean weights of 5 kg with power 0.80. In that example, we found that the estimate of $V\{D\}$ was $m_{DD} \approx 312$. If a 1-sided 0.05 level test is done, $z_{0.05} = 1.645$. For power of 0.80 we use $z_{0.80} = -0.84$. The required sample size is then (treating 312 as if it were the true variance $V\{D\}$):

$$
\begin{aligned}
n &= \frac{312(1.645 - (0.84))^2}{5^2} \\
&\approx 77
\end{aligned}
$$

On the other hand, if we wanted power of 0.90, then $z_{0.90} = -1.282$ and the sample would be 107.

When you have independent samples, the power and sample size calculations are similar. Some adaptation is needed to fit the situations described in section 3.2.

- Notes for Class #1 & 2, page 50 of 54 -

<!-- page 51 -->

### 3.7 Review Of Distributional Facts Related to the Normal Distribution

In this section we review some important distribution related to the Normal distribution.

*Normal Distribution*

Let $Z \sim N(0,1)$ be a standard normal random variable, then

$$E\{Z^3\} = 0$$

$$E\{Z^4\} = 3$$

$$X = \mu + \sigma Z$$

$$X \sim N(\mu, \sigma^2)$$

*Central Chi-square Distribution*

Let $Z_1, \dots, Z_n$ be iid $N(0,1)$, and define the random variable $\chi^2$

$$\chi^2 = \sum_{i=1}^n Z_i^2$$

Then $\chi^2$ has a Chi-square distribution with $n$ degrees-of-freedom. An interesting fact is that

$$(n - 1)m_{ZZ} = \sum_{i=1}^n (Z_i - \overline{Z})^2$$

has a Chi-square distribution with $(n - 1)$ degrees-of-freedom. Heuristically we say that we lose a degree-of-freedom for estimating the mean by $\overline{Z}$. The mean and variance for a Chi-square random variable with $d$ degrees-of-freedom, $\chi_d^2$, are given by

$$E\{\chi_d^2\} = d$$

- Notes for Class #1 & 2, page 51 of 54 -

<!-- page 52 -->

$$
V\left\{\chi_d^2\right\} = 2d
$$

An interesting fact is that for $d > 2$

$$
E\left\{\frac{1}{\chi_d^2}\right\} = (d - 2)^{-1}
$$

*Central t-Distribution*

Let $Z \sim N(0, 1)$ be a standard normal random variable, and let $\chi_d^2$ denote a Central Chi-square distribution with $d$ degrees-of-freedom, and assume that $Z$ and $\chi_d^2$ are independent. Then define the random $t$

$$
t = \frac{Z}{\sqrt{d^{-1}\chi_d^2}}
$$

has a central $t$-distribution with degrees-of-freedom $d$. The mean and variance for a central $t$-distribution with $d$ degrees-of-freedom are given by

$$
E\{t_d\} = 0 \ \ \text{for} \ \ d > 1
$$

$$
V\{t_d\} = \frac{d}{d - 2} \ \ \text{for} \ \ d > 2
$$

As $d \to \infty$ the central $t$-distribution converges to a standard normal distribution.

*Central F- Distribution*

Let $\chi_n^2$ be a central Chi-square random variable with $n$ degrees-of-freedom, and let $\chi_d^2$ be a central Chi-square random variable with $d$ degrees-of-freedom, and assume that the two random variables are independent. Define the random variable

$$
F = \frac{n^{-1}\chi_n^2}{d^{-1}\chi_d^2}
$$

- Notes for Class #1 & 2, page 52 of 54 -

<!-- page 53 -->

then $F$ has an central $F$-distribution with numerator degrees-of-freedom $n$ and denominator degrees-of-freedom $d$. We will write this as $F_d^n$. The mean and variance of a central $F$-distribution are given by

$$
E\left\{F_d^n\right\} = \frac{d}{d - 2} \quad \text{for } d > 2
$$

$$
V\left\{F_d^n\right\} = \frac{2d^2(n + d - 2)}{n(d - 2)^2(d - 4)} \quad \text{for } d > 4
$$

### 3.8 The Delta Method of Variance Approximation.

In this section we describe a method to approximate the variance of a random variable which is a known function of a random variable for which we can already estimate the variance. In general let $X$ be a random variable with mean $\mu$ and variance $\sigma^2$, where we are not restricting ourselves to normally distributed random variables at this point. Assume that we are interested in a random variable

$$
Y = f(X)
$$

We begin by expanding the function in a first-order Taylor series about the sample mean

$$
f(X) = f(\mu) + f'(\mu)(X - \mu) + \text{\textit{Remainder}}
$$

where we have included all of the higher order terms in the *Remainder* term, and $f'(\mu)$ denotes the first derivative of the function $f$ evaluated at $\mu$. If we ignore the *Remainder* term we can write

$$
Y \approx f(\mu) + f'(\mu)(X - \mu)
$$

$$
V\{Y\} \approx \left[f'(\mu)\right]^2 V\{X\}
$$

where we have used the symbol $\approx$ to denote *approximately equal to*. Therefore if we plug estimates into the expressions above we get

- Notes for Class #1 & 2, page 53 of 54 -

<!-- page 54 -->

$$
\hat{V}\{Y\} = \left[f'(X)\right]^2 \hat{V}\{X\}
$$

$$
se(Y) = \left|f'(X)\right| se(X)
$$

where we have switched to the equality symbol because we are defining these estimators.

We have deliberately been loose in our use of the term *approximate*, since we are trying to describe the general method. In general for the method to be valid, the actual statistic $X$ needs to be close to the mean $\mu$ in a distributional sense, usually with the assumption that the variance of $X$ is small.

**Example 6..** We are interested in estimating the standard error of the standard error of the sample mean from a random sample of size $n$ from a $N(\mu, \sigma^2)$ distribution. Therefore in the notation above

$$
Y = \sqrt{n^{-1} m_{XX}}
$$

$$
X = n^{-1} m_{XX}
$$

$$
f(x) = \sqrt{x}
$$

Using the facts that

$$
f'(x) = \frac{1}{2\sqrt{x}}
$$

$$
\hat{V}\{n^{-1} m_{XX}\} = \frac{2m_{XX}^2}{n^2 (n - 1)}
$$

we can write

$$
\hat{V}\{Y\} = \left[\frac{1}{2\sqrt{n^{-1} m_{XX}}}\right]^2 \frac{2m_{XX}^2}{n^2 (n - 1)} = \frac{m_{XX}}{2n(n - 1)}
$$

$$
se(Y) = \sqrt{\frac{m_{XX}}{2n(n - 1)}} = \frac{se(\bar{X})}{\sqrt{2(n - 1)}}
$$

$\blacksquare$

- Notes for Class #1 & 2, page 54 of 54 -
