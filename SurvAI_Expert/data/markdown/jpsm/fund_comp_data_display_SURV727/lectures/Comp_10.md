---
id: "jpsm/fund_comp_data_display_SURV727/lectures/Comp_10"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "Data display with"
original: "fund_comp_data_display_SURV727/lectures/Comp_10.pdf"
pages: 30
sha256: "eae7d0366d085a50b4f72ab69274aff4acdc5c9e1be2d80c523cdc6b4f132bad"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:57"
---

<!-- page 1 -->

# Data display with `ggplot2`
## Fundamentals of Computing and Data Display

Christoph Kern$^1$ Ruben Bach

[email]

---

$^1$Slides draw on Grolemund, G (2018). Master the Tidyverse: An Introduction to R for Data Science. `https://github.com/rstudio/master-the-tidyverse`

<!-- page 2 -->

# Outline

1. Introduction
2. Principles and guidelines
    - Principles of graphical integrity
    - Principles for graphical excellence
3. `ggplot2`
4. Resources
5. References

Fundamentals of Computing and Data Display | Data display with `ggplot2` | 2 / 30

<!-- page 3 -->

# Introduction

Some goals and types of data visualizations

- Info-graphics
  - Present results, monitor processes e.g. via dashboards
- Interactive exploratory analysis
  - (Web) tools for graphically exploring data
- Data analysis graphs
  - Display distributions, associations, outliers and test assumptions

$\rightarrow$ *"Visualization tools can organize data in a meaningful way that lowers the cognitive and analytical effort required to make sense of the data and make data-driven decisions"* (Yalçın and Plaisant 2017)

<!-- page 4 -->

# Introduction

Figure: Anscombe's quartet

Fundamentals of Computing and Data Display | Data display with `ggplot2` | 4 / 30

*[Figure: This figure presents a 2x2 grid of scatterplots with fitted linear regression lines comparing the four datasets of "Anscombe's quartet" (Anscombe Sets 1 to 4), with *x* on the horizontal axis (ranging from roughly 4 to 19) and *y* on the vertical axis (from 3 to 13). The main pattern shows that while all four datasets produce the exact same upward-sloping linear trend line, their underlying distributions vary drastically—displaying a noisy linear relationship in Set 1, a curved parabola in Set 2, a strict linear line with one high outlier in Set 3, and a vertical cluster at *x* = 8 with one extreme right outlier in Set 4.]*

<!-- page 5 -->

Principles and guidelines | Principles of graphical integrity

# Principles of graphical integrity

Tufte's (1983) **six principles of graphical integrity**

1. The representation of numbers, as physically measured on the surface of the graphic itself, should be directly proportional to the numerical quantities measured.
   * $\text{Lie Factor} = \frac{\text{size of effect shown in graphic}}{\text{size of effect in data}}$
2. Clear, detailed, and thorough labeling should be used to defeat graphical distortion and ambiguity. Write out explanations of the data on the graphic itself. Label important events in the data.
3. Show data variation, not design variation
4. In time-series displays of money, deflated and standardized units of monetary measurement are nearly always better than nominal units.
5. The number of information-carrying (variable) dimensions depicted should not exceed the number of dimensions in the data
6. Graphics must not quote data out of context

Fundamentals of Computing and Data Display | Data display with `ggplot2` | 5 / 30

<!-- page 6 -->

Principles and guidelines Principles of graphical integrity

# Things to avoid

Figure: The Lie Factor

This line, representing 18 miles per gallon in 1978, is 0.6 inches long.

**Fuel Economy Standards for Autos**
Set by Congress and supplemented by the Transportation Department. In miles per gallon.

1978: 18
'79: 19
'80: 20
'81: 22
'82: 24
'83: 26
'84: 27
'85: $27\frac{1}{2}$

This line, representing 27.5 miles per gallon in 1985, is 5.3 inches long.

Fundamentals of Computing and Data Display Data display with `ggplot2` 6 / 30

*[Figure: The figure is a perspective diagram shaped like a receding road that illustrates "The Lie Factor" by showing U.S. auto fuel economy standards in miles per gallon across the years 1978 to 1985. Years are listed along the left edge and corresponding miles-per-gallon values (rising from 18 to 27½) along the right edge, with the horizontal lines disproportionately lengthening from 0.6 inches in 1978 to 5.3 inches in 1985 to visually exaggerate the modest increase in fuel economy.]*

<!-- page 7 -->

Principles and guidelines
Principles of graphical integrity

# Things to avoid

Figure: Design Variation

Fundamentals of Computing and Data Display
Data display with ggplot2

*[Figure: This distorted bar chart shows OPEC oil prices in dollars per barrel on the vertical axis over time on the horizontal axis, comparing yearly averages from 1973 to 1978 against quarterly intervals in 1979. The figure illustrates a steady upward trend in prices, though the 1979 quarterly bars are drawn disproportionately wider and on an exaggerated vertical scale compared to the earlier yearly bars, visually inflating the recent price increases.]*

<!-- page 8 -->

Principles and guidelines Principles for graphical excellence

# Principles for graphical excellence

Tufte’s (1983) **principles for graphical excellence**

1. Above all else show the data
2. Maximize the data-ink ratio
   - Data ink ratio $= \frac{\text{data ink}}{\text{total ink used in the graphic}}$
3. Erase non-data ink
4. Erase redundant data ink
5. Revise and edit

Fundamentals of Computing and Data Display Data display with ggplot2 8 / 30

<!-- page 9 -->

Principles and guidelines Principles for graphical excellence

# Chartjunk

Figure: Self-promoting graphics – taken over by decorative forms

Fundamentals of Computing and Data Display Data display with ggplot2 9 / 30

*[Figure: The figure is a 3D ribbon-style area chart titled "AGE STRUCTURE OF COLLEGE ENROLLMENT" that plots the "Percent of total enrollment" on a broken vertical axis (ranging from 28–34% at the bottom and 66–72% at the top) against years from 1972 to 1976 on the horizontal axis. It compares two age groups—"UNDER 25" (in yellow and green) and "25 AND OVER" (in red and blue)—showing a complementary pattern where enrollment for students under 25 drops from 72.0% to 67.0% while enrollment for those 25 and over rises correspondingly from 28.0% to 33.0%.]*

<!-- page 10 -->

# ggplot2

1. Introduction
2. Principles and guidelines
   - Principles of graphical integrity
   - Principles for graphical excellence
3. **ggplot2**
4. Resources
5. References

<!-- page 11 -->

`ggplot2`

# `ggplot2`

*"**ggplot2** is a system for declaratively creating graphics, based on The Grammar of Graphics."*

- Flexible: Compose a set of graphical components
- Interactive: Build plots by adding layers
- Extendable: Create new graphs based on a common theory

`https://ggplot2.tidyverse.org/`

Fundamentals of Computing and Data Display $\quad$ Data display with `ggplot2` $\quad$ 11 / 30

<!-- page 12 -->

`ggplot2`

# `ggplot2`

Wilkinson's (2005) **Grammar of Graphics**

* *"A statistical graphic is a mapping from data to aesthetic attributes (colour, shape, size) of geometric objects (points, lines, bars)"* (Wickham 2016)

1. Data: Information to be visualized
2. Aesthetics: Description of how variables are mapped to aesthetic attributes
3. Geoms: (Layers of) Geometric objects that represent the data
4. Scales: Provide an inverse mapping of aesthetic space back to data space
5. Coordinate system: Defines the plane of the graphic
6. Facets: Describe how to split and display data subsets
7. Theme: Controls display settings

$\rightarrow$ A layered Grammar of Graphics (Wickham 2010)

Fundamentals of Computing and Data Display
Data display with `ggplot2`

<!-- page 13 -->

`ggplot2`

# `ggplot2`

Key components

* **Data**
    * Can be set globally when initializing the plot
* A set of **aesthetic mappings**
    * Specified with mapping argument of geom\_function
* At least one layer of **geom**etric objects
    * Specified with choice of geom\_function

```r
> # A code template
> ggplot(data = <DATA>) +
>   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))
```

Fundamentals of Computing and Data Display
Data display with `ggplot2`

<!-- page 14 -->

`ggplot2`

# `ggplot2`

Figure: A minimalistic example

```r
> ggplot(data = mpg) +
>   geom_point(mapping = aes(x = displ, y = hwy))
```

Fundamentals of Computing and Data Display
Data display with `ggplot2`

*[Figure: The figure is a scatter plot showing the relationship between `displ` on the horizontal axis (ranging from about 1.6 to 7) and `hwy` on the vertical axis (ranging from about 12 to 44). It displays a single ungrouped set of black points on a grey gridded background, revealing a clear negative correlation where `hwy` generally decreases as `displ` increases.]*

<!-- page 15 -->

ggplot2

# Aesthetics

Figure: Set aesthetic to a value

```r
> ggplot(data = mpg) +
>   geom_point(mapping = aes(x = displ, y = hwy), color = "blue")
```

Fundamentals of Computing and Data Display  
Data display with ggplot2

*[Figure: The figure shows an empty ggplot2 coordinate grid with "displ" on the horizontal axis (ranging from 2 to 7) and "hwy" on the vertical axis (with tick marks at 20, 30, and 40). Because no data points are rendered on the grey background grid, no groups are compared and no pattern is visible.]*

<!-- page 16 -->

`ggplot2`

# Aesthetics

Figure: Map aesthetic to a variable with `color`, `size`, `shape` or `alpha`

```r
> ggplot(data = mpg) +
>   geom_point(mapping = aes(x = displ, y = hwy, color = class))
```

Fundamentals of Computing and Data Display
Data display with `ggplot2`

*[Figure: The figure shows an empty ggplot2 coordinate grid with "displ" on the horizontal axis (ranging from 2 to 7) and "hwy" on the vertical axis (ranging from 20 to 40), accompanied by a legend for seven vehicle "class" groups (2seater, compact, midsize, minivan, pickup, subcompact, and suv). Because no data points or symbols are rendered in the plot area or the legend boxes, no data pattern is visible.]*

<!-- page 17 -->

`ggplot2`

# Aesthetics

| | Discrete | Continuous |
|---|---|---|
| Color | | |
| Size | | |
| Shape | | |

Fundamentals of Computing and Data Display  
Data display with `ggplot2`

<!-- page 18 -->

ggplot2

# Geoms

Figure: Specify geometrical representation with geom_functions

```r
> ggplot(data = mpg) +
>   geom_boxplot(mapping = aes(x = class, y = hwy))
```

Fundamentals of Computing and Data Display
Data display with `ggplot2`

*[Figure: The image shows a box plot comparing highway fuel efficiency ("hwy" on the y-axis, ranging from below 20 to over 40) across seven vehicle classes ("class" on the x-axis: 2seater, compact, midsize, minivan, pickup, subcompact, and suv). Compact, midsize, and subcompact cars have the highest median "hwy" values (around 26–27, with subcompact showing the widest spread), while pickup trucks and SUVs have the lowest median values (under 20).]*

<!-- page 19 -->

`ggplot2`

# Geoms

Figure: Geoms and aesthetics

```r
> ggplot(data = mpg) +
>   geom_density(mapping = aes(x = hwy, color = class))
```

Fundamentals of Computing and Data Display  
Data display with `ggplot2`

*[Figure: The figure is a multi-line density plot showing "density" on the vertical axis (ranging from 0.0 to above 0.2) against "hwy" on the horizontal axis (spanning roughly 12 to 44), comparing seven color-coded vehicle classes: 2seater, compact, midsize, minivan, pickup, subcompact, and suv. The main pattern shows that pickups and SUVs have sharp density peaks at lower highway values around 17, minivans, 2seaters, and midsize vehicles peak sharply in the mid-20s, and compact and subcompact cars have broader distributions that extend above 40.]*

<!-- page 20 -->

`ggplot2`

# Geoms

Figure: Layers of geoms

```r
> ggplot(data = mpg) +
>   geom_point(mapping = aes(x = displ, y = hwy)) +
>   geom_smooth(mapping = aes(x = displ, y = hwy))
```

Fundamentals of Computing and Data Display
Data display with `ggplot2`

*[Figure: The plot shows a single smoothed trend line (blue curve with a gray confidence interval band) representing the relationship between `displ` on the horizontal axis (ranging from 2 to 7) and `hwy` on the vertical axis (ranging from 20 to 40), without comparing distinct groups. The main pattern shows `hwy` decreasing steadily from above 30 to just below 20 as `displ` increases from under 2 to around 5, before curving back upward toward 25 at a `displ` of 7.]*

<!-- page 21 -->

`ggplot2`

# Global vs. local

Figure: Set data and mappings globally

```r
> ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
>   geom_point() +
>   geom_smooth()
```

Fundamentals of Computing and Data Display | Data display with `ggplot2` | 21 / 30

*[Figure: The plot shows a single smoothed trend line with a gray confidence interval band representing the relationship between `displ` on the x-axis (ranging from 2 to 7) and `hwy` on the y-axis (ranging from 20 to 40), without comparing distinct groups. The main pattern shows `hwy` decreasing steadily as `displ` increases from under 2 to about 5.2, after which the curve turns upward toward `displ` 7 with a widening confidence interval.]*

<!-- page 22 -->

`ggplot2`

# Global vs. local

Figure: Set mappings globally and locally

```r
> ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
>   geom_point(mapping = aes(color = drv)) +
>   geom_smooth()
```

Fundamentals of Computing and Data Display
Data display with `ggplot2`

*[Figure: The figure is a `ggplot2` chart plotting a blue smoothed trend line with a gray confidence band for highway mileage (`hwy`) on the y-axis against engine displacement (`displ`) on the x-axis. Although a legend on the right lists three drivetrain groups (`drv`: `4`, `f`, `r`), no individual data points are visible, and the overall trend shows `hwy` decreasing from above 30 to below 20 as `displ` increases from 2 to 5, before rising again toward 25 at a `displ` of 7.]*

<!-- page 23 -->

# Global vs. local

Figure: Set data and mappings globally and locally

```r
> ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
>   geom_point(mapping = aes(color = drv)) +
>   geom_smooth(data = filter(mpg, drv == "f"))
```

*[Figure: The plot displays a blue smoothed trend line with a gray confidence interval band, plotting `hwy` on the y-axis (from 20 to 40) against `displ` on the x-axis (from 2 to 7), accompanied by a legend for `drv` groups (`4`, `f`, and `r`) although no data points are visible. The trend line shows `hwy` decreasing from above 30 to around 25 as `displ` increases from under 2 to 3, after which it remains flat at approximately 25 up to a `displ` of 5.3 with a widening confidence interval.]*

<!-- page 24 -->

`ggplot2`

# Grammar of Graphics

Make any plot with `ggplot`

```r
> ggplot(data = <DATA>) +
>   <GEOM_FUNCTION> (
>     mapping = aes(<MAPPINGS>),
>     stat = <STAT>,
>     position = <POSITION>
>   ) +
>   <COORDINATE_FUNCTION> +
>   <FACET_FUNCTION> +
>   <SCALE_FUNCTION> +
>   <THEME_FUNCTION>
```

Fundamentals of Computing and Data Display $\quad$ Data display with `ggplot2` $\quad$ 24 / 30

<!-- page 25 -->

ggplot2

# Grammar of Graphics

## Figure: Build a plot form scratch I

1. Begin with the **diamonds** data set
2. Compute counts for each cut value with **stat_count()**.

| carat | cut | color | clarity | depth | table | price | x | y | z |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0.23 | Ideal | E | SI2 | 61.5 | 55 | 326 | 3.95 | 3.98 | 2.43 |
| 0.21 | Premium | E | SI1 | 59.8 | 61 | 326 | 3.89 | 3.84 | 2.31 |
| 0.23 | Good | E | VS1 | 56.9 | 65 | 327 | 4.05 | 4.07 | 2.31 |
| 0.29 | Premium | I | VS2 | 62.4 | 58 | 334 | 4.20 | 4.23 | 2.63 |
| 0.31 | Good | J | SI2 | 63.3 | 58 | 335 | 4.34 | 4.35 | 2.75 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

stat_count()

| cut | count | prop |
| :---: | :---: | :---: |
| Fair | 1610 | 1 |
| Good | 4906 | 1 |
| Very Good | 12082 | 1 |
| Premium | 13791 | 1 |
| Ideal | 21551 | 1 |

Fundamentals of Computing and Data Display
Data display with ggplot2

*[Figure: The diagram illustrates a two-step data transformation process where a raw dataset table (`diamonds`, with columns `carat`, `cut`, `color`, `clarity`, `depth`, `table`, `price`, `x`, `y`, `z`) is summarized via an arrow labeled `stat_count()` into a smaller table of counts and proportions. This resulting summary table compares five diamond `cut` categories (`Fair`, `Good`, `Very Good`, `Premium`, and `Ideal`), showing that `count` values progressively increase from `Fair` (1,610) to `Ideal` (21,551) while `prop` remains 1.]*

<!-- page 26 -->

`ggplot2`

# Grammar of Graphics

### Figure: Build a plot form scratch II

3. Represent each observation with a bar.
4. Map the **fill** of each bar to the `..count..` variable.

| carat | cut | color | clarity | depth | table | price | x | y | z |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0.23 | Ideal | E | SI2 | 61.5 | 55 | 326 | 3.95 | 3.98 | 2.43 |
| 0.21 | Premium | E | SI1 | 59.8 | 61 | 326 | 3.89 | 3.84 | 2.31 |
| 0.23 | Good | E | VS1 | 56.9 | 65 | 327 | 4.05 | 4.07 | 2.31 |
| 0.29 | Premium | I | VS2 | 62.4 | 58 | 334 | 4.20 | 4.23 | 2.63 |
| 0.31 | Good | J | SI2 | 63.3 | 58 | 335 | 4.34 | 4.35 | 2.75 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

`stat_count()`

| cut | count | prop |
| :---: | :---: | :---: |
| Fair | 1610 | 1 |
| Good | 4906 | 1 |
| Very Good | 12082 | 1 |
| Premium | 13791 | 1 |
| Ideal | 21551 | 1 |

---

Fundamentals of Computing and Data Display $\quad$ Data display with `ggplot2` $\quad$ 26 / 30

*[Figure: The diagram illustrates the data transformation and aesthetic mapping steps in `ggplot2`, showing how a raw diamonds dataset table on the left is aggregated via an arrow labeled `stat_count()` into a summary table on the right comparing five `cut` categories (Fair, Good, Very Good, Premium, and Ideal) by their `count` and `prop`. In the summary table, which has no plot axes, the `count` column increases steadily from Fair (1,610) to Ideal (21,551) and is mapped by a curved arrow to five distinct colored square icons representing the `fill` aesthetic for each row's bar.]*

<!-- page 27 -->

`ggplot2`

# Grammar of Graphics

Figure: Build a plot form scratch III

5. Place geoms in a cartesian coordinate system.
6. Map the y values to `..count..` and the x values to **cut**.

| carat | cut | color | clarity | depth | table | price | x | y | z |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0.23 | Ideal | E | SI2 | 61.5 | 55 | 326 | 3.95 | 3.98 | 2.43 |
| 0.21 | Premium | E | SI1 | 59.8 | 61 | 326 | 3.89 | 3.84 | 2.31 |
| 0.23 | Good | E | VS1 | 56.9 | 65 | 327 | 4.05 | 4.07 | 2.31 |
| 0.29 | Premium | I | VS2 | 62.4 | 58 | 334 | 4.20 | 4.23 | 2.63 |
| 0.31 | Good | J | SI2 | 63.3 | 58 | 335 | 4.34 | 4.35 | 2.75 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

`stat_count()`

| cut | count | prop |
| :---: | :---: | :---: |
| Fair | 1610 | 1 |
| Good | 4906 | 1 |
| Very Good | 12082 | 1 |
| Premium | 13791 | 1 |
| Ideal | 21551 | 1 |

Fundamentals of Computing and Data Display
Data display with `ggplot2`

*[Figure: This diagram illustrates how a raw dataset (left) is transformed via `stat_count()` into a summary table (middle) and then mapped to a colored bar chart (right). The bar chart plots "count" (ranging from 0 to over 20,000) on the y-axis against five diamond "cut" categories (Fair, Good, Very Good, Premium, Ideal) on the x-axis, showing a steady increase in frequency from Fair to Ideal.]*

<!-- page 28 -->

`ggplot2`

# Plotting Big Data

Some solutions for big(ger) data

* Try different geoms
* Add structure with size, transparency
* Plot summary statistics, densities, model results instead of raw data
* Subsetting
* Faceting
* Sampling

Fundamentals of Computing and Data Display
Data display with `ggplot2`

<!-- page 29 -->

# Resources

- Textbook
  - Wickham, H. (2016). *ggplot2: Elegant Graphics for Data Analysis.* New York, NY: Springer.
- Galleries
  - `https://www.r-graph-gallery.com`
  - `http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html`
- Cheatsheet
  - `https://github.com/rstudio/cheatsheets/raw/master/data-visualization-2.1.pdf`
- `ggmap`
  - `https://github.com/dkahle/ggmap`

<!-- page 30 -->

# References

Tufte, E. R. (1983). *The Visual Display of Quantitative Information.* Cheshire, CT: Graphics Press.

Wickham, H. (2010). A layered grammar of graphics. *Journal of Computational and Graphical Statistics* *19*(1): 3–28.

Wilkinson, L. (2005). *The grammar of graphics. Statistics and computing.* New York, NY: Springer.

Yalçın, M. A. and Plaisant, C. (2017). Information Visualization. In Foster, I., Ghani, R., Jarmin, R. S., Kreuter, F., and Lane, J. (Eds.) *Big Data and Social Science: A Practical Guide to Methods and Tools.* Boca Raton, FL: CRC Press Taylor & Francis Group.
