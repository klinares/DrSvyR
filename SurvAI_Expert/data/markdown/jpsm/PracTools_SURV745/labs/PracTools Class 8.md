---
id: "jpsm/PracTools_SURV745/labs/PracTools_Class_8"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lab"
title: "PracTools Class 8"
original: "PracTools_SURV745/labs/PracTools Class 8.pdf"
pages: 8
sha256: "2d9c4d2e800ebdde8960c6c9369d0b4d14d3dec7fb743a39a95318ea75a108d0"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:14"
---

<!-- page 1 -->

# PracTools Class 8

Sunghee Lee

3/9/2026

## Example 1: To create a map of Washington DC tracts, block groups and blocks

* Need: tigris and leaflet packages

### 1.1) To get DC tract map shapefile

```r
dc_trt <- tracts("District of Columbia", year=2020)
dc_trt_trans <- st_transform(dc_trt,
                             "+proj=longlat +datum=WGS84")
```

```r
dc_trt[1:2,]
```

| | STATEFP<br>`<chr>` | COUNTYFP<br>`<chr>` | TRACTCE<br>`<chr>` | GEOID<br>`<chr>` | NAME<br>`<chr>` | NAMELSAD<br>`<chr>` | MTF...<br>`<chr>` | FUNCSTAT<br>`<chr>` | ALAND<br>`<dbl>` |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | ---: |
| 1 | 11 | 001 | 004001 | 11001004001 | 40.01 | Census Tract 40.01 | G5020 | S | 271037 |
| 2 | 11 | 001 | 004002 | 11001004002 | 40.02 | Census Tract 40.02 | G5020 | S | 194755 |

2 rows | 1-10 of 14 columns

```r
dc_trt_trans[1:2,]
```

| | STATEFP<br>`<chr>` | COUNTYFP<br>`<chr>` | TRACTCE<br>`<chr>` | GEOID<br>`<chr>` | NAME<br>`<chr>` | NAMELSAD<br>`<chr>` | MTF...<br>`<chr>` | FUNCSTAT<br>`<chr>` | ALAND<br>`<dbl>` |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | ---: |
| 1 | 11 | 001 | 004001 | 11001004001 | 40.01 | Census Tract 40.01 | G5020 | S | 271037 |
| 2 | 11 | 001 | 004002 | 11001004002 | 40.02 | Census Tract 40.02 | G5020 | S | 194755 |

2 rows | 1-10 of 14 columns

### 1.2) To create DC tract map

```r
leaflet() %>%
  addTiles() %>%
  addPolygons(data=dc_trt_trans,
              popup = ~NAME)
```

<!-- page 2 -->

### 1.3) To get blockgroup & block map shapefile

```r
dc_bg <- block_groups("District of Columbia", year=2020)
dc_bg_trans <- st_transform(dc_bg, "+proj=longlat +datum=WGS84")
```

```r
dc_blk <- blocks("District of Columbia", year=2020)
dc_blk_trans <- st_transform(dc_blk, "+proj=longlat +datum=WGS84")
```

### 1.4) To create DC blockgroup map layered with tracts

```r
leaflet() %>%
  addTiles() %>%
  addPolygons(data=dc_trt_trans,
              popup = ~NAME) %>%
  addPolygons(data=dc_bg_trans,
              popup = ~GEOID,
              color = "red",
              weight = 1,
              opacity= 1,
              smoothFactor = 1,
              fillOpacity = 0,
              fillColor= "#BDBDC3"
              )
```

<!-- page 3 -->

1.5) To create DC block map layered with block groups and tracts

```r
leaflet() %>%
  addTiles() %>%
  addPolygons(data=dc_trt_trans,
              popup = ~NAME,
              fillOpacity = 0,
              fillColor= "snow") %>%
  addPolygons(data=dc_bg_trans,
              popup = ~GEOID,
              color = "red",
              weight = 2,
              opacity= 0.8,
              smoothFactor = 1,
              fillOpacity = 0,
              fillColor= "snow") %>%
  addPolygons(data=dc_blk_trans,
              popup = ~GEOID20,
              color = "green",
              weight = 0.7,
              opacity= 2,
              smoothFactor = 1,
              fillOpacity = 0,
              fillColor= "snow")
```

1.6) What if I am interested in only a few blockgroups and want to note them?

<!-- page 4 -->

```r
dc_bg_select<-dc_bg_trans [31:40,]

leaflet() %>%
  addTiles() %>%
  addPolygons(data=dc_trt_trans,
              popup = ~NAME) %>%
  addPolygons(data=dc_bg_select,
              color = "red",
              weight = 1,
              popup = ~GEOID)
```

# Example 2: To create a map of Washington DC tracts with ACS 2019 summary file data with

1) Median income

2) Population size

3) Population proportion of Blacks

* Need tidycensus to pull ACS data (Note: Income data is not collected in Decennial Census.)

```r
api_key <-"YOUR KEY"
# Request at https://api.census.gov/data/key_signup.html

census_api_key(key=api_key, install=T)
# "install=T" stores your api_key
# If stored, checking api_key as follows:
#    readRenviron("~/.Renviron")
#    Sys.getenv("CENSUS_API_KEY")
```

* What variables are available from tidycensus?

<!-- page 5 -->

```r
View(load_variables(2019, "acs5", cache = TRUE))
```

* More information about ACS SF Tables: https://www.census.gov/programs-surveys/acs/technical-documentation/table-shells.2019.html (https://www.census.gov/programs-surveys/acs/technical-documentation/table-shells.2019.html)

### 2.1) Map with median income

* From the View() above (and also from the ACS SF Table shells information), we know B06011_001 is the median income.

#### 2.1)A. To get the income data from ACS

```r
DC_INCOME <- get_acs(geography = "tract",
                    variables = "B06011_001",
                    state = "District of Columbia",
                    geometry = TRUE)
```

```r
head(DC_INCOME)
```

| | GEOID<br>\<chr\> | NAME<br>\<chr\> | variable<br>\<chr\> | estimate<br>\<dbl\> |
| :--- | :--- | :--- | :--- | ---: |
| 1 | 11001009509 | Census Tract 95.09, District of Columbia, District of Columbia | B06011_001 | 45954 |
| 2 | 11001010100 | Census Tract 101, District of Columbia, District of Columbia | B06011_001 | 77407 |
| 3 | 11001008301 | Census Tract 83.01, District of Columbia, District of Columbia | B06011_001 | 77747 |
| 4 | 11001002101 | Census Tract 21.01, District of Columbia, District of Columbia | B06011_001 | 37281 |
| 5 | 11001004100 | Census Tract 41, District of Columbia, District of Columbia | B06011_001 | 92230 |
| 6 | 11001008001 | Census Tract 80.01, District of Columbia, District of Columbia | B06011_001 | 82074 |

6 rows | 1-5 of 7 columns

#### 2.1)B. How I want to note the income differences on the map

```r
palette <- colorBin(palette = "Blues",
                domain = DC_INCOME$estimate, bins=10)
```

* More information about palette color options: http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3 (http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3)

#### 2.1)C. To create the income map

<!-- page 6 -->

```r
DC_INCOME %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(popup = ~GEOID,
              color = "black",
              weight = 1)%>%
  addPolygons(popup = ~ str_extract(NAME, "^([^,]*)"),
              stroke = FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color = ~ palette(estimate)) %>%
  addLegend("bottomleft",
            pal = palette,
            values = ~ estimate,
            title = "Median income - Tract",
            labFormat = labelFormat(prefix = "$"),
            opacity = 1)
```

### 2.2) Map with population counts

#### 2.2)A. From the variable list, we know B01001_00 is the total population count and B01001B_001 is the count of Blacks

```r
DC_BLACK <- get_acs(geography = "tract",
                    variables = "B01001B_001",
                    state = "District of Columbia",
                    geometry = TRUE,
                    summary_var="B01001_001")
```

- estimate is the counts of Blacks (B01001B_001) and summary_est is the count of populaiton (B01001_001)

#### 2.2)B. Map of total population counts

<!-- page 7 -->

```r
pal1 <- colorBin(palette = "Greys",
                 domain = DC_BLACK$summary_est, bins=10)

DC_BLACK %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(popup = ~GEOID,
              color = "black",
              weight = 1)%>%
  addPolygons(popup = ~ str_extract(NAME, "^([^,]*)"),
              stroke = FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color = ~ pal1(summary_est)) %>%
  addLegend("bottomleft",
            pal = pal1,
            values = ~ summary_est,
            title = "Total population - Tract",
            opacity = 1)
```

2.3) Map with population proportion of Blacks

<!-- page 8 -->

```r
pal2 <- colorBin(palette = "BuGn",
                 domain = DC_BLACK$estimate/DC_BLACK$summary_est*100,
                 bins=10)

DC_BLACK %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(popup = ~GEOID,
              color = "black",
              weight = 1)%>%
  addPolygons(popup = ~ str_extract(NAME, "^([^,]*)"),
              stroke = FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color = ~ pal2(estimate/summary_est*100)) %>%
  addLegend("bottomleft",
            pal = pal2,
            values = ~ estimate/summary_est*100,
            title = "Proportion of Blacks - Tract",
            labFormat = labelFormat(suffix="%"),
            opacity = 1)
```
