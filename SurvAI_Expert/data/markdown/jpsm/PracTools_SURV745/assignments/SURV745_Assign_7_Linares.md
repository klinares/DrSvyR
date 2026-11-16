---
id: "jpsm/PracTools_SURV745/assignments/SURV745_Assign_7_Linares"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "assignment"
title: "Assignment 7"
original: "PracTools_SURV745/assignments/SURV745_Assign_7_Linares.qmd"
pages: 
sha256: "76fda48bdaa3505cd1db6a2ffccb61046ce619db0a4b7b91b07c7b17b57a9324"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:13"
---


# Create a map of Census tracts in Washington DC and denote **the population counts**. Do the same with **the proportion of non-Hispanic Blacks in the population**. Discuss your observation in relation to **the median income** demonstrated during the class.

-   Load the required packages and register API keys (do not save in script).

    -   The `tidycensus` package pulls ACS 5-year summary file data at the tract level for Washington, DC.

    -   The `ggmap` package fetches Stadia Maps basemap tiles so that the choropleth polygons are overlaid on a real street map giving the reader geographic context (e.g., roads, neighborhoods, the Anacostia River). This works for PDF-friendly format output.

    -   The `sf` package handles spatial geometry.

```r
pacman::p_load(sf, ggmap, viridis, scales, knitr, patchwork, tidycensus, tidyverse)

# load private API keys
api_keys <- read_csv("D:/repos/api-keys.csv", show_col_types = FALSE)

# Census API key
census_key <- api_keys |>
  filter(key_id == "Census_key") |>
  pull(key) 

census_api_key(key = census_key, install = FALSE)

# Stadia Maps API key, required for ggmap tile access
stadia_key <- api_keys |>
  filter(key_id == "stadiamaps_key") |>
  pull(key)

register_stadiamaps(key = stadia_key)
```

# 

-   Once our API keys are set, we can pull in from the Census API ACS 5-year estimates (2019) to obtain tract-level data for Washington, DC. The key variables are:

    -   `B03002_004`: Not Hispanic or Latino Black or African American alone

    -   `B03002_001`: Total population (used as the denominator via `summary_var`)

-   This gives us both the total population count and the non-Hispanic Black count per tract, from which we compute the proportion.

```r
# pull in ACS data
dc_race <- get_acs(
  geography = "tract", # data level
  variables = "B03002_004", # pop count for non-Hispanic Black
  summary_var = "B03002_001", # pop count
  state = "District of Columbia",
  year = 2019,
  geometry = TRUE # shape file
)

# Compute proportion of non-Hispanic Blacks
dc_race <- dc_race |>
  # black / total by tract
  mutate(pct_nh_black = (estimate / summary_est) * 100)

# summary
dc_race |>
  st_drop_geometry() |>
  reframe(
    tracts = n(), # number of tracts
    total_pop = sum(summary_est), # total population
    percent_black = sum(estimate) / total_pop # percent of Black
  ) |> 
  kable()
```

# 

-   We also need to define a bounding box for Washington, DC and load in Stadia Maps `stamen_toner_lite` tile. This provides a clean, muted basemap with street labels that prints elegantly in grayscale analogous to the `CartoDB.Positron` provider used in the `leaflet` maps from the lab notes.

```r
# define DC bounding box 
dc_bbox <- c(
  left = -77.12, # left
  bottom =38.79,# bottom
  right = -76.91, # right
  top = 38.995 # top
)

# pull in basemap tiles
## this will use the api key already registered above
dc_basemap <- get_stadiamap(
  bbox = dc_bbox,
  zoom = 12, # controls projection
  maptype = "stamen_terrain"
)

# pull in median income data
dc_income <- get_acs(
  geography = "tract",
  variables = "B06011_001",
  state = "District of Columbia",
  year = 2019,
  geometry = TRUE
) |>
  st_transform(crs = 4326)

```

-   The `ggmap` basemap uses WGS84 (EPSG:4326) coordinates. We will transform the `dc_race` sf object to match so that `geom_sf()` layers align correctly on the tile raster (i.e., a grid of pixels containing images stored as rows and columns).

```r
# transform to align with raster using the sf::st_transform()
dc_race <- dc_race |>
  st_transform(crs = 4326)
```

\newpage

-   The first choropleth overlays total population counts on the basemap. We use a semi-transparent fill (`alpha = 0.7`) so the underlying street grid and topography or geographic barriers remains visible for reference. The second choropleth displays the percentage of non-Hispanic Black residents per tract. We also display a third map of median income by tract, with light pink spots denoting missing income information.

-   The three maps together reveal stark racial economic disparities across DC. Tracts east of the Anacostia River with highest concentrations of non-Hispanic Black residents often exceeding 70%, and the lowest median incomes frequently below \$40,000. The inverse holds in Northwest DC, where Black population shares drop below 15% and median incomes exceed \$75,000. Population counts vary across the city but tend to be lowest near the National Mall and federal corridors. For survey design, this geographic clustering has direct implications. Measures of homogeneity (e.g., the ICC $\delta$) for race and income are likely to be high at the tract level, meaning that tracts are internally similar but differ substantially from one another. This suggests that sampling a larger number of tracts (PSUs) with fewer units per tract would be a more efficient design strategy for surveys targeting demographic/economic characteristics.

```r
#| echo: false


# shared map theme
map_theme_config <- theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = .5),
    plot.subtitle = element_text(size = 9, hjust = .5, color = "gray40"),
    legend.title = element_text(face = "bold", size = 9),
    legend.text = element_text(size = 8),
    legend.key.height = unit(.8, "cm"),
    legend.key.width = unit(.4, "cm"),
    plot.margin = margin(-5, 4, -5, 4)
  )

# reusable map recipe
dc_map_layers <- function(data, fill_var, palette, legend_name, legend_labels) {
  list(
    geom_sf(
      data = data,
      aes(fill = {{ fill_var }}), color = "lightgray",
      linewidth = .01, alpha = .6, inherit.aes = FALSE
    ),
    scale_fill_viridis_c(
      option = palette, direction = -1,
      name = legend_name, labels = legend_labels
    ),
    map_theme_config
  )
}


dc_map_layers <- function(data, fill_var, palette, legend_name, legend_labels,
                          na_color = "gray90") {
  
  # extract the variable values to compute range
  vals <- data |> st_drop_geometry() |> pull({{ fill_var }})
  val_range <- range(vals, na.rm = TRUE)
  
  list(
    geom_sf(
      data = data,
      aes(fill = {{ fill_var }}), color = "lightgray",
      linewidth = .01, alpha = .6, inherit.aes = FALSE
    ),
    scale_fill_viridis_c(
      option = palette, direction = -1,
      name = legend_name, labels = legend_labels,
      na.value = na_color,
      breaks = c(val_range[1], 
                 median(vals, na.rm = TRUE), 
                 val_range[2]),
      limits = val_range
    ),
    map_theme_config
  )
}
```

```r
#| fig-height: 11
#| fig-width: 8

# total pop
p1 <- ggmap(dc_basemap) +
  dc_map_layers(dc_race, summary_est, "mako", "Total\nPopulation", comma) +
  labs(title = "Total Population")

# percent black
p2 <- ggmap(dc_basemap) +
  dc_map_layers(dc_race, pct_nh_black, "A", "% Non-Hispanic\nBlack",
                ~ str_c(round(.x), "%")) +
  labs(title = "Proportion Non-Hispanic Black")

# median income
p3 <- ggmap(dc_basemap) +
  dc_map_layers(dc_income, estimate, "cividis", "Median\nIncome", dollar,
                na_color = "lightpink") +
  labs(title = "Median Income")

# plot all three maps
(p1 | p2) / p3 +
  # fix the ratios
  plot_layout(heights = c(1, 1))  +
  plot_annotation(
    title = "Washington, DC Census Tracts",
    subtitle = "ACS 5-Year Estimates (2015\u20132019)",
    caption = "Source: U.S. Census Bureau, American Community Survey",
    theme = theme(plot.title    = element_text(
      face = "bold", size = 14, hjust = .5),
      plot.subtitle = element_text(
        size = 10, hjust = .5, color = "gray40"),
      plot.caption  = element_text(
        size = 7, color = "gray50", hjust = 1)) )
```
