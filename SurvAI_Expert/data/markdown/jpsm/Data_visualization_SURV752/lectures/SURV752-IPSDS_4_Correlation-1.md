---
id: "jpsm/Data_visualization_SURV752/lectures/SURV752-IPSDS_4_Correlation-1"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "lecture"
title: "SURV752-IPSDS_4_Correlation-1"
original: "Data_visualization_SURV752/lectures/SURV752-IPSDS_4_Correlation-1.pdf"
pages: 38
sha256: "5284e912febde32629518be4e0c87cab9fb42b4506b7538989b8de20553b9754"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:54"
---

<!-- page 1 -->

Correlation, Correlation

<!-- page 2 -->

# The Scatterplot

“Indeed, among all the forms of statistical graphics, the humble scatterplot may be considered the most versatile, polymorphic, and generally useful invention in the entire history of statistical graphics.“ (Friendly & Denis 2005)

<!-- page 3 -->

Correlation?

Functional Form?

Clusters?

Gaps?

Outliers?

<!-- page 4 -->

# Reducing Overplotting

Decrease symbol size.

```r
cex=.5
```

<!-- page 5 -->

# Reducing Overplotting

Remove fill color.

```r
pch=21
```

<!-- page 6 -->

# Reducing Overplotting

Choose other symbols.

```r
pch=4
```

<!-- page 7 -->

# Reducing Overplotting

Jittering.

Adds random noise to data values.

Doesn't make sense
for continous variables!

```r
points(jitter(daten05$bayern),
       daten05$cdu, pch=19)
```

<!-- page 8 -->

# Reducing Overplotting

Alpha Blending.

Makes plotting symbols transparent.

```r
points(jitter(daten05$bayern),
daten05$cdu, pch=19, col=rgb(00,
00, 00, 50, max=255))
```

<!-- page 9 -->

# Same with „Big Data“ Example

No fill color...

Smaller symbols...

Small symbols + Alpha blending

<!-- page 10 -->

# Sampling

## 262143 Points

## 20% Sample

## 10% Sample

## 5% Sample

<!-- page 11 -->

# Sampling

```r
samp.20 <- sample(length(DATA$Est.z[DATA$variable=="milper"]),
round(length(DATA$Est.z[DATA$variable=="milper"])*.2))


plot(DATA$dev_diff[DATA$variable=="milper"][samp.20],
   DATA$Est.z[DATA$variable=="milper"][samp.20], pch=19, cex=.1,
axes=F,   xlab="Model Fit", ylab="Coefficient Estimate")
axis(1)
axis(2, las=1)
box(bty="l")
```

<!-- page 12 -->

# Enhancing Scatterplots: Rugs

```r
rug(daten05$kath, side=1)
rug(daten05$cdu, side=2)
```

<!-- page 13 -->

# Enhancing Scatterplots: Boxplots

<!-- page 14 -->

# Enhancing Scatterplots: Boxplots

```r
plot(daten05$kath, daten05$cdu, pch=19, axes=F, cex.lab=1, tck=-.01,
    main="", xlab="Share of Catholics %", ylab="Share CDU/CSU %", las=1,
    ylim=c(.1, .55), xlim=c(-.05, .9))
axis(2, at=seq(.10, .60, by=.10), labels=c("10", "20", "30", "40", "50",
    "60"), las=1, col="white")
axis(1, at=seq(.20, .80, by=.20), labels=c("20", "40", "60", "80"),
    las=1, col="white")

boxplot(daten05$kath, at=.1, axes=F, horizontal=T, add=T, boxwex=.05)

boxplot(daten05$cdu, at=-.05, axes=F, horizontal=F, add=T, boxwex=.10)
```

<!-- page 15 -->

# Slicing

<!-- page 16 -->

# Slicing

<!-- page 17 -->

# Slicing

<!-- page 18 -->

# Fitting

“There are two components to visualizing the structure of statistical data - graphing and fitting.

Graphs are needed, of course, because visualization implies a process in which information is encoded on visual displays.

Fitting mathematical functions to data is needed too.

Just graphing raw data, without fitting them and without graphing the fits and residuals, often leaves important aspects of data undiscovered”

(Cleveland 1993).

<!-- page 19 -->

# Parametric Fitting

```r
abline(lm(daten05$cdu~daten05$kath), col=rgb(.47, 00, .47))
text(.55, .20, "y=.26+.19*x", col=rgb(.47, 00, .47), pos=4, cex=.9)
text(.55, .17, "R2=.38", col=rgb(.47, 00, .47), pos=4, cex=.9)
```

<!-- page 20 -->

# Parametric Fitting

Vote Share CDU/CSU %

50

40

30

20

Other State
$y=.27+.12*x$
$R2=.29$

20

40

60

80

Share of Catholics %

<!-- page 21 -->

# Parametric Fitting

Vote Share CDU/CSU %

50

40

30

20

20 40 60 80

Share of Catholics %

| Other State | Bavaria |
| --- | --- |
| $y=.27+.12*x$ | $y=.31+.15*x$ |
| $R2=.29$ | $R2=.26$ |

<!-- page 22 -->

# Parametric Fitting

Other State
$y=.27+.12*x$
$R2=.29$

Bavaria
$y=.31+.15*x$
$R2=.26$

Vote Share CDU/CSU %

Share of Catholics %

<!-- page 23 -->

# Non-Parametric Fitting: Scatter Plot Smoothers

*LOESS*: <u>lo</u>cally weighted regr<u>ess</u>ion

```r
lines(loess.smooth(daten05$kath, daten05$cdu, span=.3, degree=1),
col=rgb(.47, 00, .47), lwd=2)
```

<!-- page 24 -->

# Non-Parametric Fitting: Scatter Plot Smoothers

```r
span=.8
```

```r
span=.5
```

```r
span=.3
```

```r
span=.1
```

<!-- page 25 -->

# Non-Parametric Fitting: Scatter Plot Smoothers

<!-- page 26 -->

*[No text on this page]*

<!-- page 27 -->

### A. Hypothetical Data for Loess Fit.

### B. Window for $v_j=5.5$ and $\alpha=0.6$.

### C. Tricube Neighborhood Weights.

### D. Initial Regression Line and Fitted Value.

<!-- page 28 -->

E. Bisquare Robust Weights.

F. Final Robust Line and Fitted Value.

G. Complete Set of Fitted Values.

H. Loess Curve

<!-- page 29 -->

# Add Confidence Intervals

<!-- page 30 -->

# Add Confidence Intervals

Extract Fitted Values and SEs from loess

```r
l.p <- predict(loess(daten05$cdu ~ daten05$kath, span=.3), se=T)
l.p <- cbind(daten05$kath, l.p$fit, l.p$fit - qt(0.975,
  l.p$df)*l.p$se, l.p$fit + qt(0.975, l.p$df)*l.p$se)
l.p <- l.p[order(l.p[,1]),]
```

Plot as Lines

```r
lines(l.p[,1], l.p[,2], col=rgb(.47, 00, .47))
lines(l.p[,1], l.p[,3], col=rgb(.47, 00, .47), lty=2)
lines(l.p[,1], l.p[,4], col=rgb(.47, 00, .47), lty=2)
```

Plot as Polygon

```r
lines(l.p[,1], l.p[,2], col=rgb(.47, 00, .47))
polygon(c(l.p[,1], rev(l.p[,1])), c(l.p[,3], rev(l.p[,4])),
  col=rgb(.47, 00, .47, .50), border=F)
```

<!-- page 31 -->

# Add Confidence Intervals

## Exract Fitted Values and Confidence Intervals from OLS

```r
ols <- lm(daten05$cdu~daten05$kath)
r.p <- predict(ols, interval="confidence")
r.p <- cbind(daten05$kath, r.p)
r.p <- r.p[order(r.p[,1]),]
```

## Plot as Lines

```r
lines(r.p[,1], r.p[,2], col=rgb(.47, 00, .47))
lines(r.p[,1], r.p[,3], col=rgb(.47, 00, .47), lty=2)
lines(r.p[,1], r.p[,4], col=rgb(.47, 00, .47), lty=2)
```

## Plot as Polygon

```r
lines(r.p[,1], r.p[,2], col=rgb(.47, 00, .47))
polygon(c(r.p[,1], rev(r.p[,1])), c(r.p[,3], rev(r.p[,4])),
  col=rgb(.47, 00, .47, .50), border=F)
```

<!-- page 32 -->

# Aspect Ratio = Height/Width of Data Area

```r
asp=1/1
```

```r
asp=6/1
```

```r
asp=2/5
```

```r
asp=2.7/1
```

<!-- page 33 -->

# Gapminder World Chart 2006

* **Low income countries** | **Middle income countries** | **High income countries**

## Health: Children dying before age 5 per 1000 live births (log)
(Scale: 3, 4, 5, 7, 10, 20, 30, 50, 70, 100, 200, 300)

## Money: Gross National Income per capita - in US dollar by exchange rate (log)
(Scale: 100, 200, 300, 500, 1 000, 2 000, 3 000, 5 000, 10 000, 20 000, 30 000, 50 000)

* **Healthy** (Top) / **Sick** (Bottom)
* **Poor** (Left) / **Rich** (Right)

---

### Population (millions)
* <1, 1, 10, 100, 1 000

### Regions
* Americas
* Arab states
* Asia & Pacific
* Europe & Central Asia
* Sub-Saharan Africa

2006 data for countries & territories from UN Statistics Division, Institute for Health Metrics and Evaluation and others sources as stated in: "Gapminder documentation 2007:1" at: www.gapminder.org/publications.

Free to copy for non-commercial use (CC BY-NC-ND)
E-mail: [email]

**www.gapminder.org**

**GAPMINDER**
Gapminder World Chart 2006 - Ver. January 2008

<!-- page 34 -->

# The Bubble Plot

```r
symbols(daten05$kath, daten05$cdu, circles=daten05$n, inches=0.5,
          bg=rgb(120, 00, 120, 50, max=255), fg=rgb(120, 00, 120,
           max=255), add=T)
```

<!-- page 35 -->

# The Bubble Plot

ATTENTION: you need to size the bubbles proportional to area (not radius)!

$$Area = \pi r^2 \quad \text{and} \quad r = \sqrt{Area/\pi}$$

<!-- page 36 -->

# The Bubble Plot

```r
symbols(daten05$kath, daten05$cdu, circles=sqrt(daten05$n/pi),
inches=0.3, bg=rgb(120, 00, 120, 50, max=255), fg=rgb(120, 00, 120,
max=255), add=T)
```

<!-- page 37 -->

# Adding Text Labels (This looks pretty Rosling-style to me!)

<!-- page 38 -->

```r
text(data$pr_2014, data$cl_2014, data$Country, cex=sqrt((data$pop/pi),
col=rgb(0, 0, 0, 100, max=255), pos=2)
```
