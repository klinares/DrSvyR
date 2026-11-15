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
converted_at: "2026-11-14T21:00:55"
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

<!-- page 7 -->

Principles and guidelines
Principles of graphical integrity

# Things to avoid

Figure: Design Variation

Fundamentals of Computing and Data Display
Data display with ggplot2

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

<!-- page 23 -->

# Global vs. local

Figure: Set data and mappings globally and locally

```r
> ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
>   geom_point(mapping = aes(color = drv)) +
>   geom_smooth(data = filter(mpg, drv == "f"))
```

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
