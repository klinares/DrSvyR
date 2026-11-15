---
id: "jpsm/Data_visualization_SURV752/assignments/Linares_k_hw4"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "assignment"
title: "Homework 4: Lab Exercise, Visualizing the Gapminder Data Set"
original: "Data_visualization_SURV752/assignments/Linares_k_hw4.qmd"
pages: 
sha256: "190c1967d0cbf07f97e18ec68f27e2a2ccf4a2720cf3d5976facc1134cfa510c"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:51"
---


```r
#| message: false
#| warning: false
# this is my way of loading packages using the pacman package
pacman::p_load(plotly, patchwork, ggrepel, viridis, gapminder, tidyverse)

theme_set(theme_minimal())

options(scipen=999)

```

## The "gapminder" package in R will give you access to Hans Rosling's Gapminder data set. Use this data set to do the following:

## 1. Reconstruct the iconical Gapminder bubble plot (as seen on the slides) for the year 2007. To do this you may find the symbols() function helpful. Give a brief description of what you find.

```r
#| message: false
#| warning: false

gapminder |> 
  filter(year == 2007) |>  
  mutate(pop = sqrt(pop / 3.14)) |> 
  ggplot(aes(x = gdpPercap, y = lifeExp, color = continent,
             size = pop)) +
  geom_point(alpha=0.7) + 
  scale_x_log10() + 
  scale_size(range = c(.1, 20), name="Population") +
  ylim(30, 85) +
  labs(
    title = "Gapminder World Chart 2007",
     x = "Gross Domestic Production per capita (log)",
     y = "Life Expectancy (years)") +
  scale_color_viridis_d(option = "D") 


```

## 

-   Using the 2007 gapminder data we reconstructed the 2006 visual of all country's relationship between Gross Domestic Production (GDP) per capita and life expectancy in years and a third dimension representing population size in thousands. The population scale was normalized by taking the square root of population divided by $\pi$. Additionally, we add color to represent the 5 continents in the data. Finally, the relationship between these two variables is curvelinear; therefore, we scale GDPon a log scale and can now visualize a linear relationship. As GDP log goes up, so does life expectancy, suggesting that as more resources are available per person within a country the country average expected life span increases. This plot also helps us visualize clustering of countries within continents, which we see that European and Asian countries fare well compared to African countries whom tend to have on average lower GDP and life expectancy values. We removed the country names to reduce the black ink ratio, but call out here that the Asian country clustering with African countries is Afghanistan which tends to be an outlier within Asian countries. Both China and India have siGDPficantly larger populations compared to other countries and although they had high life expectancy, they are not the countries with the highest GDP, the US, Japan, Hong Kong, Singapore tend to have the highest GDP and life expectancy with small to moderate size populations.

## 2. Now construct the same bubble plot for the year 1952 and compare it to 2017. Give a brief description of what you find.

```r
#| message: false
#| warning: false

gapminder |> 
  filter(year == 1952, 
         country != "Kuwait") |>  
  mutate(pop = sqrt(pop / 3.14)) |>  
  ggplot(aes(x = gdpPercap, y = lifeExp, color = continent,
             size = pop)) +
  geom_point(alpha=0.7) + 
  scale_x_log10() + 
  scale_size(range = c(.1, 20), name="Population") +
  labs(
    title = "Gapminder World Chart 1952",
     x = "Gross Domestic Production per capita (log)",
     y = "Life Expectancy (years)") +
  ylim(0, 85) +
  scale_color_viridis_d(option = "D") 
```

\newpage

-   In the 1952 data, Kuwait had a life expectancy of 55.6 years and the highest GDP value of 108,382. To better visualize the rest of the countries Kuwait is dropped for this plot as it makes this plot more comparable to the 2007 plot. We still observe a linear positive relationship between GDP log and life expectancy, but the linear trend is not as steep as what we observed in 2007, suggesting a moderate linear relationship for the 1952 data. Although the countries in this plot with the highest GDP was the US and Switzerland, it is mostly the Scandanavian countries and the Netherlands that lead in life expectancy with high GDP values. We also observe that African countries tend to cluster at lower levels of these variables as we saw in 2007, but they are also joined by Asian countries. China and India are among the most populated countries, but they are also among the lowest GDP countries with low life expectancy compared to their 2007 standing. Our final observation is that European countries seem to be highly populated, yet they are over taken by other countries by 2007.

## 3. Now come up with a visualization strategy that incorporates all years. Justify your design and implement it.

```r
#| message: false
#| warning: false
#| 
gapminder |> 
  mutate(pop = sqrt(pop / 3.14)) |>  
  ggplot(aes(x = gdpPercap, y = lifeExp, color = continent, 
             group=year)) +
  geom_point(alpha=0.7) + 
  geom_smooth(method='lm', se = FALSE, color="black") +
  facet_grid(~year) +
  scale_x_log10() + 
  labs(
    title = "Gapminder World Chart",
     x = "Gross Domestic Production per capita (log)",
     y = "Life Expectancy (years)") +
  ylim(0, 85) +
  scale_color_viridis_d(option = "D") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "top")
```

-   Our first attempt was to put all of the years in one plot, but this did not work well as it was too busy and hard to follow each country. We also remove the population dimension so that the reader can focus on the take away message. We design a small multiple grid plot for each year and note that overtime the world has increased their life expectancy. However, GDP seemed to be strongly correlated with life expectancy in the early years but we can see from the linear trend line that as time progresses the slope decreases, suggesting that other factors are contributing to life expectancy in later years. We still see that European countries over time has fared well regarding life expectancy and GDP, while African countries have always been more likely to be poor and live less years. Asian countries have had the most drastic changes. This plot also allows us to quickly see two time points with drastically low life expectancy and sadly these are due to genocides; Cambodia in 1977 and Rwanda in 1992.

\newpage

## 4. Let's try a fun format - the bubble trail plot. Have a look the handout for examples. What ingredients do you need to construct this type of plot? Implement your own bubble trail plot using the Gapminder data set!

```r
#| message: false
#| warning: false
#| 
 
countries <- c("Cambodia", "Rwanda")

gapminder |> 
  filter(country %in% countries) |> 
  group_by(country) |> 
   mutate(lifeExp_growth = lifeExp - lag(lifeExp, default = first(lifeExp)) ) |> 
  ungroup() |> 
  ggplot(aes(x = pop, y = lifeExp, color = country, label=year, 
             group=country)) +
  geom_point( alpha=0.7) + 
  geom_line(aes(color=country), show.legend = FALSE) +
  geom_text_repel(box.padding = .5, 
    point.padding = 0.2, 
    nudge_x = .15,
    nudge_y = .15,
    segment.linetype = 6,
    segment.curvature = -1e-20,
    arrow = arrow(length = unit(0.015, "npc"))) +
  labs(
    title = "War and Genocide Impact on Population Growth, Life Expectancy",
     x = "Population",
     y = "Life Expectancy (years)") +
    scale_color_viridis_d(option = "C", begin = 0.05, end = 0.75, alpha=.7)  +
  theme(legend.position = "top")

  
```

-   The bubble trail plot is useful for looking at changes over time for two related variables. We examine the relationship of population growth and life expectancy over time for two countries to examine how civil wars and genocides impact these variables. One limitation is that we cannot plot too many clusters since there is so much going on in the plot to begin with.

    -   Rwanda experienced a horrible genocide in 1992 as we see from the plot the extreme decline in life expectancy of about 20 years, and we see the posthoc effects that population size decreases in 1997 because of the genocide. We do not really see population increase until a decade later.

    -   Cambodia experienced a genocide from 1975 through 1979, and while 1977 was the worst year we observe a drastic lose in life expectancy of about 15 years from 1967. Populaiton growth is very slow from 1977 to 1982 and it almost takes a decade for the population and life expectancy to increase by 1987.

\newpage

## 5. Now, just for fun, install the "plotly"-package in R and run the following code. Enjoy!

```r
#| eval: false
base <- gapminder %>%
  plot_ly(x = ~gdpPercap, y = ~lifeExp, size = ~pop, 
          text = ~country, hoverinfo = "text") %>%
  layout(xaxis = list(type = "log"))

base %>%
  add_markers(color = ~continent, frame = ~year, ids = ~country) %>%
  animation_opts(500, easing = "elastic", redraw = FALSE) %>%
  animation_button(
    x = 1, xanchor = "right", y = 0, yanchor = "bottom") %>%
  animation_slider(
    currentvalue = list(prefix = "Year ", font = list(color="red")))
```

![](images/clipboard-1516472990.png)

\

Use of AI Acknowledgment

-   In this assignment I did not use AI for any part of the work. \
