---
id: "jpsm/fund_comp_data_display_SURV727/code/03-RMarkdown"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "R Markdown Tutorial"
original: "fund_comp_data_display_SURV727/code/03-RMarkdown.Rmd"
pages: 
sha256: "a47bf08a1fa38cdc2a62cb86a3e62b7bf941f06de5c938f2f6d619bb92e1b9ec"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


```r
knitr::opts_chunk$set(echo = TRUE)
# install.packages(c("rmarkdown", "knitr", "kableExtra","stargazer", "plotly", "knitr","bookdown"), repos = "http://cran.us.r-project.org")
```

# R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

```r
summary(cars)
```

Same Code, but results only.

```r
summary(cars)
```

Still same code but this time code only and no results!

```r
summary(cars)
```

Data tables can be formatted in different styles.

```r
cars[1:5, ]
```

## Including Plots

You can also embed plots, for example:

```r
plot(pressure)
```

For headers, use #, ##, ###, ####, #####, \###### t

## A large header

### A slightly smaller header with a **bold** word (two asterisks)

For *italic* font use one asterisk. We can also ~~cross out~~ words!\
Two begin a new line, add two spaces to the end of a line.\
A new line starts!

# Citations

Seminal work on propensity score [@rosenbaum1983central].\
Year cited without author [-@rosenbaum1983central].\
@rosenbaum1983central cited in line.

# Installing scripts

## Installing packages

We often need to include the repository from where a package should be installed. Also, it is good practice to check whether a required package is already installed and then install it only if it isn't.

```r
if (!require('MASS')) install.packages('MASS', repos = "http://cran.us.r-project.org")
library('MASS') 
if (!require('ggplot2')) install.packages('ggplot2', repos = "http://cran.us.r-project.org")
library('ggplot2') 
if (!require('dplyr')) install.packages('dplyr', repos = "http://cran.us.r-project.org")
library('dplyr') 
```

# Example analysis

We estimate a linear regression model explaining the price of a diamond by its clarity, cut, and carat. By the way, the mean of c(1:5) is `r mean(c(1:5))`.

```r
regmod.1 <- lm(price ~ clarity + cut + carat, data = diamonds)
summary(regmod.1) 
```

# Parameters

```r
print(paste("The years is ", params$year))
regmod.2 <- lm(mpg ~ cyl + disp, data = params$data)
summary(regmod.2) 
```

For a nicer look of the regression output, we can use the stargazer package

```r
library(stargazer)
stargazer(regmod.1,
          title = "Regression table with stargazer",
          label="tab1", 
          model.numbers = FALSE,
          type="latex")
```

Simply include a references heading at the end. References will be added automatically.

# References
