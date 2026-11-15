---
id: "jpsm/fund_comp_data_display_SURV727/code/Comp_13"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Interactive Graphs"
original: "fund_comp_data_display_SURV727/code/Comp_13.Rmd"
pages: 
sha256: "845b38cdab300a6ff98564838943b918a7707857ea02588b9fe42a9e4463881f"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


```r
library(tidyverse)
library(plotly)
library(DT)
library(ggvis)
library(shiny)
library(gapminder)
```

## Introduction | Why do we need interactive graphs?

- Explore data
- Display heterogeneity
- Present research results
- Develop apps that allow to interact with data w/o programming

## Introduction | What are interactive graphs?

https://www.gapminder.org/tools

https://www.gapminder.org/answers/how-does-income-relate-to-life-expectancy/

## Interactive graphs with R

* Work in interactive webpages (html), not static documents
* Often based on http://www.htmlwidgets.org/
* May be viewed in
    + RStudio Viewer
    + Web browser
* May be saved
    + as a standalone web page
    + or hosted on a server

## Interactive graphs with R

- plotly
- shiny
- ggvis
- ...

# plotly 

## plotly 

- Easy to use
- Translate ggplot2 graphics to an interactive web-based version
- Build interactive graph from scratch with plot_ly()
- Website offers a chart studio to customize graphs, but needs data upload

## plotly - Example

Using ggplotly() as a wrapper for a ggplot graph

```r
library(plotly)

graph <- ggplot(economics, aes(x = date, y = unemploy)) +
	geom_point()

ggplotly(graph)
```

## plotly - Example

Using ggplotly() as a wrapper for a ggplot graph

```r
library(plotly)

graph <- ggplot(economics, aes(x = date, y = unemploy)) +
	geom_point()

ggplotly(graph)
```

## plotly - Links

Getting started:
https://plot.ly/r/getting-started/

Plotly library:
https://plot.ly/r/

Plotly ggplot2 Library:
https://plot.ly/ggplot2/

Plotly cookbook:
https://plotly-book.cpsievert.me/index.html

## DataTables

DT package provides a similar approach for displaying data

```r
library(DT)

datatable(economics, options = list(pageLength = 5))
```

## DataTables {.smaller}

```r
library(DT)

datatable(economics, options = list(pageLength = 5))
```

# shiny

## shiny

* Framework for building a web application
* Combines R, HTML, JavaScript and CSS
* Allows to build web apps without knowledge of web programming languages
* Can include multiple interactive components on a web page
    + Components can be build with ggplot2, ggvis, plotly, ...

http://shiny.rstudio.com/tutorial/

## shiny - Structure of a shiny app

User interface controls the layout and appearance of app

```r
ui <- fluidPage()
```

Server function contains instructions needed to build app

```r
server <- function(input, output) {}
```

shinyApp() creates the Shiny app object

```r
shinyApp(ui = ui, server = server)
```

## shiny - Example

see shiny.R

## shiny - Deployment

How to share Shiny apps:

https://shiny.rstudio.com/tutorial/written-tutorial/lesson7/

https://www.shinyapps.io/

# ggvis

## ggvis

* Build interactive graphs with ggplot2-like syntax
    + layer, geom -> layer function
    + stat -> compute function
    + aes() -> props()
    + ggplot() -> ggvis()
    + "+" -> %>%

Drawbacks:
<br>

- has not as many features as ggplot (yet)
- cannot produce maps, facets

## ggvis - Basics

```r
data %>%
ggvis(x = ~var_x, y = ~var_y, fill = ...) %>%
layer_function() 
```

Example:
```r
economics %>%
ggvis(x = ~date, y = ~unemploy) %>%
layer_points()
```

## ggvis - Basics

```r
economics %>%
ggvis(x = ~date, y = ~unemploy) %>%
layer_points()
```

## ggvis - Functions for interactivity

- **input_select()**
- input_numeric()
- input_text()
- input_slider()
- input_checkbox()
- input_checkboxgroup()
- input_radiobuttons()
- add_tooltip()

## input_select()

```r
economics %>%
  ### <b>
  ggvis(x = input_select(label = "Choose x variable:", 
                        choices = names(economics), 
                        map = as.name), 
        y = input_select(label = "Choose y variable:", 
                        choices = names(economics), 
                        map = as.name,
                        selected = "unemploy")) %>%
  ### </b>
  layer_points()
```

## input_select()

```r
economics %>%
  ### <b>
  ggvis(x = input_select(label = "Choose x variable:", 
                        choices = names(economics), 
                        map = as.name), 
        y = input_select(label = "Choose y variable:", 
                        choices = names(economics), 
                        map = as.name,
                        selected = "unemploy")) %>%
  ### </b>
  layer_points()
```

## input_select()

```r
economics %>%
  ### <b>
  mutate(unemploy_corrected_by_pop = unemploy/pop) %>%
  ### </b>
  ggvis(x = input_select(label = "Choose x variable:", 
                         choices = c(names(economics)),
                         map = as.name), 
        y = input_select(label = "Choose y variable:",
  ### <b>
                         choices = c(names(economics), "unemploy_corrected_by_pop"),
  ### </b>
                         map = as.name,
                         selected = "unemploy")) %>%
  layer_points()
```

## input_select()

```r
economics %>%
  ### <b>
  mutate(unemploy_corrected_by_pop = unemploy/pop) %>%
  ### </b>
  ggvis(x = input_select(label = "Choose x variable:", 
                        choices = c(names(economics)),
                        map = as.name), 
        y = input_select(label = "Choose y variable:",
                        ### <b>
                        choices = c(names(economics), "unemploy_corrected_by_pop"), 
                        ### </b>
                        map = as.name,
                        selected = "unemploy")) %>%
  layer_points()
```

## ggvis - Functions for interactivity

- input_select()
- **input_numeric()**
- input_text()
- input_slider()
- input_checkbox()
- input_checkboxgroup()
- input_radiobuttons()
- add_tooltip()

## input_numeric()

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  ### <b>
  layer_points(size := input_numeric(5 , label = "Point size"))
  ### </b>
```

## input_numeric() 

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  ### <b>
  layer_points(size := input_numeric(5 , label = "Point size"))
  ### </b>
```

## ggvis - Functions for interactivity

- input_select()
- input_numeric()
- **input_text()**
- input_slider()
- input_checkbox()
- input_checkboxgroup()
- input_radiobuttons()
- add_tooltip()

## input_text()

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  layer_lines(stroke := input_text(
    label = "choose a color", 
    value = "red"))
  ### </b>
```

## input_text()

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  layer_lines(stroke := input_text(
    label = "choose a color", 
    value = "red"))
  ### </b>
```

## ggvis - Functions for interactivity

- input_select()
- input_numeric()
- input_text()
- **input_slider()**
- input_checkbox()
- input_checkboxgroup()
- input_radiobuttons()
- add_tooltip()

## input_slider()

```r
economics %>%
  ggvis(x = ~date, 
        y = ~unemploy,
        ### <b>
        opacity := input_slider(0, 1, label = "Opacity"),
        size := input_slider(1, 200, value = 30, step = 10, 
                             label = "Point Size")) %>%
        ### </b>
  layer_points()
```

## input_slider()

```r
economics %>%
  ggvis(x = ~date, 
        y = ~unemploy,
        ### <b>
        opacity := input_slider(0, 1, label = "Opacity"),
        size := input_slider(1,200, value = 30, step = 10, 
                             label = "Point Size")) %>%
        ### </b>
  layer_points()
```

## Adding slider to adjust axes {.smaller}

```r
### <b>
x_axis <- input_slider(min = min(economics$date), max(economics$date), 
                       value = c(min(economics$date), max(economics$date)))
y_axis <- input_slider(min = min(economics$unemploy), max = max(economics$unemploy), 
                       value = c(min(economics$unemploy), max(economics$unemploy)), step = 1000)
### </b>

economics %>%
  ggvis(x = ~date, 
        y = ~unemploy) %>%
  ### <b>
  scale_numeric("x", domain = x_axis, clamp = F) %>%
  scale_numeric("y", domain = y_axis, clamp = T) %>%
  ### </b>
  layer_lines()
```

## Adding slider to adjust axes

```r
### <b>
x_axis <- input_slider(min = min(economics$date), max(economics$date), 
                       value = c(min(economics$date), max(economics$date)))
y_axis <- input_slider(min = min(economics$unemploy), max = max(economics$unemploy), 
                       value = c(min(economics$unemploy), max(economics$unemploy)), step = 1000)
### </b>

economics %>%
  ggvis(x = ~date, 
        y = ~unemploy) %>%
  ### <b>
  scale_numeric("x", domain = x_axis, clamp = F) %>%
  scale_numeric("y", domain = y_axis, clamp = T) %>%
  ### </b>
  layer_lines()
```

## ggvis - Functions for interactivity

- input_select()
- input_numeric()
- input_text()
- input_slider()
- **input_checkbox()**
- input_checkboxgroup()
- input_radiobuttons()
- add_tooltip()

## input_checkbox()

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  layer_lines(stroke := input_checkbox(
    label = "red instead of blue", 
    map = function(val) if(val) "red" else "blue"))
  ### </b>
```

## input_checkbox()

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  layer_lines(stroke := input_checkbox(
    label = "red instead of blue", 
    map = function(val) if(val) "red" else "blue"))
```

## ggvis - Functions for interactivity

- input_select()
- input_numeric()
- input_text()
- input_slider()
- input_checkbox()
- **input_checkboxgroup()**
- input_radiobuttons()
- add_tooltip()

## input_checkboxgroup()

```r
cocaine %>% 
  ggvis(~potency, ~price) %>%
  ### <b>
  filter(state %in% 
           eval(input_checkboxgroup(c("Iowa" = "IA",
                                    "Minnesota" = "MN",
                                    "Wisconsin" = "WI"),
                                    label = "Select states",
                                    selected = "WI"))) %>% 
  layer_points(fill = ~state, size := 50, opacity := 0.5) 
  ### </b>
```

## input_checkboxgroup() {.smaller}

```r
cocaine %>% 
  ggvis(~potency, ~price) %>%
  filter(state %in% 
           eval(input_checkboxgroup(c("Iowa" = "IA", 
                                      "Minnesota" = "MN", 
                                      "Wisconsin" = "WI"),
                                    label = "Select states",
                                    selected = "WI"))) %>% 
  layer_points(fill = ~state, size := 50, opacity := 0.5) 
```

## ggvis - Functions for interactivity

- input_select()
- input_numeric()
- input_text()
- input_slider()
- input_checkbox()
- input_checkboxgroup()
- **input_radiobuttons()**
- add_tooltip()

## input_radiobuttons()

```r
economics %>%
  ggvis(x = ~date, 
        y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  layer_model_predictions(model = input_radiobuttons(
    choices = c("Linear" = "lm", "LOESS" = "loess"),
    selected = "loess",
    label = "Model type"))
  ### </b>
```

## input_radiobuttons()

```r
economics %>%
  ggvis(x = ~date, 
        y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  layer_model_predictions(model = input_radiobuttons(
    choices = c("Linear" = "lm", "LOESS" = "loess"),
    selected = "loess",
    label = "Model type"))
  ### </b>
```

## ggvis - Functions for interactivity

- input_select()
- input_numeric()
- input_text()
- input_slider()
- input_checkbox()
- input_checkboxgroup()
- input_radiobuttons()
- **add_tooltip()**

## add_tooltip()

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  add_tooltip(function(data){paste0(
    "Number of unemployed: ", data$unemploy)})
  ### </b>
```

## add_tooltip() {.smaller}

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  add_tooltip(function(data){paste0(
    "Number of unemployed: ", data$unemploy)})
  ### </b>
```

## Adding click text

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
 
  add_tooltip(function(data){paste0(
  ### <b>
    "Number of unemployed: ", data$unemploy)}, on = "click")
  ### </b>
```

## Adding click text {.smaller}

```r
economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
 
  add_tooltip(function(data){paste0(
  ### <b>
    "Number of unemployed: ", data$unemploy)}, on = "click")
  ### </b>
```

## Date variables

```r
  economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  add_tooltip(function(data){paste0(
    ### <b>
    "Date: ", data$date, "<br>",
     ### </b>
    "Number of unemployed: ", data$unemploy)})
```

```r
class(economics$date)
```

## Date variables {.smaller}

```r
  economics %>%
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  add_tooltip(function(data){paste0(
    "Date: ", data$date, "<br>",
    "Number of unemployed: ", data$unemploy)})
```

## Date variables

```r
  economics %>%
  ### <b>
  mutate(date2 = as.character(date)) %>%
  ### </b>
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  layer_points(fill = ~date2, opacity = 0) %>%
  hide_legend("fill") %>%
  add_tooltip(function(data){paste0(
    "Date: ", data$date2, "<br>",
    "Number of unemployed: ", data$unemploy)})
  ### </b>
```

## Date variables {.smaller}

```r
  economics %>%
  ### <b>
  mutate(date2 = as.character(date)) %>%
  ### </b>
  ggvis(x = ~date, y = ~unemploy) %>%
  layer_points() %>%
  ### <b>
  layer_points(fill = ~date2, opacity = 0) %>%
  hide_legend("fill") %>%
  add_tooltip(function(data){paste0(
    "Date: ", data$date2, "<br>",
    "Number of unemployed: ", data$unemploy)})
  ### </b>
```

## Resources

- http://ggvis.rstudio.com/
- https://shiny.rstudio.com/
- https://mastering-shiny.org/
- https://www.datacamp.com/courses/building-web-applications-in-r-with-shiny
- https://github.com/rstudio/cheatsheets/raw/master/shiny.pdf
