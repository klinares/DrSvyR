---
id: "jpsm/fund_comp_data_display_SURV727/code/BigDataTools"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Fundamentals of Computing and Data Display"
original: "fund_comp_data_display_SURV727/code/BigDataTools.Rmd"
pages: 
sha256: "5fdf52bd7d7f7a477465f2d76bd94dc260cbed39556c379c438e73727608bf1b"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


## Setup

```r
library(tidyverse)
library(DBI)
library(tictoc)
library(bigrquery)
library(data.table)
library(dtplyr)
library(parallel)
library(sparklyr)
library(magrittr)
```

## Google BigQuery

In this notebook we -- again -- use Google BigQuery, "Google's fully managed, petabyte scale, low cost analytics data warehouse". Instruction on how to connect to Google BigQuery can be found here:

https://db.rstudio.com/databases/big-query/

After following the steps described on this website and initializing a project, paste your project name into the following chunk.

```r
tic()
project <- "graphic-jet-439415-v4"
```

First, set up the connection to the database. This time we use the Chicago crime database, which is a BigQuery version of the Chicago crime API we used in earlier classes.

```r
con <- dbConnect(
  bigrquery::bigquery(),
  project = "bigquery-public-data",
  dataset = "chicago_crime",
  billing = project
)
con 
```

Show tables that are available.

```r
dbListTables(con)
```

## data.table & dtplyr

We want to query a big piece of this dataset, so we pick rows over multiple years. We may want to adjust the time frame used here if we run into problems later in this notebook.

```r
sql <- "SELECT *
        FROM `crime`
        #WHERE year = 2014"
```

To store the resulting dataset as a `data.table`, we can nest `dbGetQuery()` within `setDT()`. Another option would be to query to a local `.csv` file and then load the data via `fread()`.

```r
df <- setDT(dbGetQuery(con, sql))
```

List size and class of the query result.

```r
size <- object.size(df)
print(size, units = "auto")
class(df)
```

Information about R's memory usage.

```r
gc(verbose = TRUE)
```

Since `df` is a `data.table`, we can use the `data.table` approach to subsetting. This includes "on the fly" variable transformation.

```r
df[year == 2018]
df[year == 2018, .(year, arrest)]
df[year == 2018, .(year, num = as.numeric(arrest))]
```

We can add an additional argument within `[]` to compute statistics by groups. The following example computes the median number of arrests for each year and beat (a small-area geographic unit) combination.

```r
df[,.(arrest_med = median(arrest)), by = .(year, beat)]
```

Lets check the CPU time used by this function call.

```r
system.time(df[,.(arrest_med = median(arrest)), by = .(year, beat)])
```

Show the time needed when using base R for the same task.

```r
system.time(by(df$arrest, df[,c(11,18)], median))
```

We can also use `data.table` in a `dplyr` way via the package `dtplyr` by creating a data table tibble that wraps the original data table `df`.

```r
dftbl <- lazy_dt(df)
dftbl
class(dftbl)
```

This object can be used as if it was a normal `tibble`, e.g. in a `dpylr` pipe. This allows use to try out yet another way of computing the median number of arrests for each year and beat.

```r
df %>%
  group_by(year, beat) %>%
  summarise(median(arrest))
```

Check the CPU time needed using the `dtplyr` approach.

```r
system.time(
dftbl %>%
  group_by(year, beat) %>%
  summarise(median(arrest))
)
```

Close the BigQuery connection.

```r
dbDisconnect(con)
```

## parallel

Image we wanted to run a couple of regressions with the Chicago crime data, grouped by year. For this task, we could write a function that filters the data by year and then calls `glm()` for the resulting data piece.

```r
fit_glm <- function(data, subset) {
  data %>%
    filter(year == subset) %>%
    glm(arrest ~ primary_type, family = "binomial", data = .)
  }
```

Next, we can use this function within `lapply()` to apply `fit_glm` to every year in `df`.

```r
system.time(lapply(min(df$year):max(df$year), fit_glm, data = df))
```

However, this approach runs all regressions in sequence, which might take some time. One way to speed things up is by utilizing parallel computing. With `parallel` and `snow`, some preparation steps are needed to set things up.

```r
numCores <- length(min(df$year):max(df$year))
numCores
```

Initialize a (local) cluster.

```r
cl <- makeCluster(numCores)
cl
```

This essentially creates a set of copies of R sessions, which are "empty" at first, i.e. no data or additional packages are loaded.

```r
clusterEvalQ(cl, sessionInfo())
```

We therefore have to load the packages needed again, now in every node of the cluster. In addition, the data has to be exported to the nodes. 

```r
clusterEvalQ(cl, library(dplyr))
clusterExport(cl, "df")
```

Now, run the regressions in parallel, by using `parLapply` instead of `lapply`. 

```r
system.time(parLapply(cl, min(df$year):max(df$year), fit_glm, data = df))
```

Terminate the cluster.

```r
stopCluster(cl)
```

## sparklyr

Finally, a short example with `sparklyr`.

```r
#spark_install()
# install first https://phoenixnap.com/kb/install-spark-on-ubuntu
```

Initialize a connection with a local Spark cluster.

```r
sc <- spark_connect(master = "local")
sc

```

Next, copy data to the cluster nodes. Here we extract only a subset of our `df` data set for demonstration purposes.

```r
dfspark <-
df %>%
  lazy_dt %>%
  filter(year == 2018) %>%
  copy_to(sc, ., "dfspark", overwrite = TRUE)

```

Check whether the data is loaded in the local Spark cluster.

```r
src_tbls(sc)
class(dfspark)
```

Now we can -- as with `dtplyr` -- use `src_tbls` as if it was a regular `tibble` in R. As an example, we can use piping to run a logistic regression, using a function from the `MLlib` library. 

```r
tic()
dfspark %>%
  ml_generalized_linear_regression(arrest ~ primary_type, family = "binomial") %>%
  summary()
toc()
```
```r
summary(mod)
```

Close Spark connection.

```r
sparkR.session.stop()
#spark_disconnect(sc)
rm(df)
rm(dfspark)
toc()
```

## References

* https://github.com/Rdatatable/data.table/wiki
* https://spark.rstudio.com/
