---
id: "jpsm/fund_comp_data_display_SURV727/assignments/database_sql"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "assignment"
title: "Assignment 4"
original: "fund_comp_data_display_SURV727/assignments/database_sql.qmd"
pages: 
sha256: "2996d95af2cee81027c006492bfeeafcb591d9b8d24ef8888d9f27d614ddd266"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


This is an individual assignment. Turn in this assignment as an HTML or PDF file to ELMS. Make sure to include the R Markdown or Quarto file that was used to generate it. Include the GitHub link for the repository containing these files.

```r
#| include: false 
library(tidyverse)
library(DBI)
library(lubridate)
library(dbplyr)
library(bigrquery)
```

In this notebook we will use Google BigQuery, "Google's fully managed, petabyte scale, low cost analytics data warehouse". Some instruction on how to connect to Google BigQuery can be found here: <https://db.rstudio.com/databases/big-query/>.

You will need to set up a Google account with a project to be able to use this service. We will be using a public dataset that comes with 1 TB/mo of free processing on Google BigQuery. As long as you do not repeat the work in this notebook constantly, you should be fine with just the free tier.

Go to <https://console.cloud.google.com> and make sure you are logged in a non-university Google account. **This may not work on a university G Suite account because of restrictions on those accounts.** Create a new project by navigating to the dropdown menu at the top (it might say "Select a project") and selecting "New Project" in the window that pops up. Name it something useful.

After you have initialized a project, paste your project ID into the following chunk.

```r
project <- "graphic-jet-439415-v4" # use ID
```

We will connect to a public database, the Chicago crime database, which has data on crime in Chicago.

```r
con <- dbConnect(
  bigrquery::bigquery(),
  project = "bigquery-public-data",
  dataset = "chicago_crime",
  billing = project
)
con
```

We can look at the available tables in this database using `dbListTables`.

**Note**: When you run this code, you will be sent to a browser and have to give Google permissions to Tidyverse API Packages. **Make sure you select all to give access or else your code will not run.**

```r
dbListTables(con)
```

Information on the \`crime\` table can be found here:

<https://cloud.google.com/bigquery/public-data/chicago-crime-data>

Write a first query that counts the number of rows of the \`crime\` table in the year 2016. Use code chunks with {sql connection = con} in order to write SQL code within the document.

```sql
SELECT count(primary_type), count(*)
FROM crime
WHERE year = 2016
LIMIT 10
```

Next, count the number of arrests grouped by `primary_type` in 2016. Note that is a somewhat similar task as above, with some adjustments on which rows should be considered. Sort the results, i.e. list the number of arrests in a descending order.

-   It appears that narcotics and battery assault are top reasons for being arrested.

```sql
SELECT primary_type, count(*) AS n
FROM (
  SELECT crime.*
  FROM crime
  WHERE (year = 2016) AND (arrest = TRUE)
) q01
GROUP BY primary_type
ORDER BY n DESC
LIMIT 10
```

We can also use the `date` for grouping. Count the number of arrests grouped by hour of the day in 2016. You can extract the latter information from `date` via `EXTRACT(HOUR FROM date)`. Which time of the day is associated with the most arrests?

-   We can see from the query below that evening hours are responsible for a large proportion, about .26, or a quarter, of crime arrests occurred 6pm to 9pm in 2016.

```sql
SELECT q01.*, n / SUM(n) OVER () AS prop
FROM (
  SELECT Hour, count(*) AS n
  FROM (
    SELECT crime.*, EXTRACT(hour FROM date) AS Hour
    FROM crime
    WHERE (year = 2016) AND (arrest = TRUE)
  ) q01
  GROUP BY Hour
) q01
ORDER BY n DESC
LIMIT 8
```

Focus only on `HOMICIDE` and count the number of arrests for this incident type, grouped by year. List the results in descending order.

-   We can see from the query below that Chicago experienced high homicide arrests in the early 2000s (2001-2004) and during the pandemic (2020-2022).

```sql
SELECT q01.*, 
FROM (
  SELECT year, count(*) AS n
  FROM (
    SELECT crime.*
    FROM crime
    WHERE (primary_type = 'HOMICIDE') AND (arrest = TRUE)
  ) q01
  GROUP BY year
) q01
ORDER BY n DESC
LIMIT 8
```

Find out which districts have the highest numbers of arrests in 2015 and 2016. That is, count the number of arrests in 2015 and 2016, grouped by year and district. List the results in descending order.

-   District 11 tends to have the highest number of arrests for years 2015 and 2016, followed by district 7 and district 15 in 2015.

```sql
SELECT year, district, count(*) AS n
FROM (
  SELECT crime.*
  FROM crime
  WHERE (year IN (2015, 2016)) AND (arrest = TRUE)
) `q01`
GROUP BY year, district
ORDER BY n DESC
LIMIT 8
```

Lets switch to writing queries from within R via the `DBI` package. Create a query object that counts the number of arrests grouped by `primary_type` of district 11 in year 2016. The results should be displayed in descending order.

Execute the query.

-   In 2016 for district 11, narcotics, battery, and prostitution were the three top types of arrests.

```r
dbGetQuery(con,'
 SELECT primary_type, district, count(*) AS n
FROM (
  SELECT crime.*
  FROM crime
  WHERE (arrest = TRUE) AND (district = 11) AND (year = 2016)
) `q01`
GROUP BY primary_type, district
ORDER BY n DESC
LIMIT 8
')
```

Try to write the very same query, now using the `dbplyr` package. For this, you need to first map the `crime` table to a tibble object in R.

```r
crime  <- tbl(con, "crime") 

```

Again, count the number of arrests grouped by `primary_type` of district 11 in year 2016, now using `dplyr` syntax.

```r
crime |> 
  as_tibble() |> 
  filter(arrest==TRUE, district==11, year==2016) |> 
  group_by(primary_type) |> 
  count() |> 
  arrange(desc(n)) |> 
  head(8) |> 
  knitr::kable()

```

Count the number of arrests grouped by `primary_type` and `year`, still only for district 11. Arrange the result by `year`.

```r
crime |> 
  as_tibble() |> 
  filter(arrest==TRUE, district==11) |> 
  group_by(primary_type, year) |>
  count() |> 
  arrange(year) |> 
  head(10) |> 
  knitr::kable()
  
```

Assign the results of the query above to a local R object.

```r
dist_11_arrests <- crime |> 
  as_tibble() |> 
  filter(arrest==TRUE, district==11) |> 
  group_by(primary_type, year) |>
  count()
```

Confirm that you pulled the data to the local environment by displaying the first ten rows of the saved data set.

```r
dist_11_arrests |> 
  head(10) |> 
  knitr::kable()
```

Close the connection.

```r
dbDisconnect(con)
```
