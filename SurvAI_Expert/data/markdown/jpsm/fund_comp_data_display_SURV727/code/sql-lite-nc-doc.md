---
id: "jpsm/fund_comp_data_display_SURV727/code/sql-lite-nc-doc"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "SQL Lite Example with NC Data"
original: "fund_comp_data_display_SURV727/code/sql-lite-nc-doc.Rmd"
pages: 
sha256: "449ea069938f077424e156a7b0bade7d381dc25e36a01ba7445fc3c4fc8e0eec"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


We will be using the `RSQLite` package in order to interact with the SQLite database. The database exists as a `.db` object and has already been created. You can store your own data or create your own SQLite database relatively easily as it is a lightweight database engine. You can check out how to get started using: https://www.sqlite.org/quickstart.html. To import a CSV file into SQLite, you can follow these instructions: https://www.sqlitetutorial.net/sqlite-import-csv/. Certain GUIs might make this process easier. Here, we assume that an SQLite database already exists.

We will exploring the SQLite database containing data from the North Carolina Department of Corrections. This data was taken from a publicly available database and stored inside an SQLite database. This is the example used in the workbooks used in the Big Data and Social Science textbook, which can be found here: https://workbooks.coleridgeinitiative.org 

More information about this data can be found here: https://webapps.doc.state.nc.us/opi/downloads.do?method=view. 

```r
library(tidyverse)
library(DBI)
library(RSQLite)
library(dbplyr)
```

We first create our connection using `dbConnect`. The database file is `ncdoc.db`, so this is what we will want to connect to.

```r
con <- dbConnect(RSQLite::SQLite(), '~/UMD/classes/fund_comp_data_display_SURV727/code/ncdoc.db')
con
```

We can list the tables in the SQLite database. Note that there are a lot of tables in here that were used for machine learning processes. The important tables we want to focus on here are `inmate` and `sentences`.  

```r
dbListTables(con)
```

Let's first try using SQL chunks to explore our data.

```sql
SELECT count(*)
FROM inmate
LIMIT 10;
```

```r
sql <- "SELECT count(*)
FROM inmate
LIMIT 10;"

dbGetQuery(con, sql)
```


```sql
SELECT count(distinct INMATE_DOC_NUMBER)
FROM inmate
LIMIT 10;
```

There are 461,421 unique individuals in this dataset. 

```sql
SELECT *
FROM inmate
LIMIT 20;
```

```sql
SELECT inmate_doc_number, inmate_last_name, inmate_first_name, inmate_gender_code, inmate_race_code
FROM inmate
LIMIT 20;
```

Each row in the `inmate` table represent a unique person. However, individuals can have multiple sentences.

```sql
SELECT *
FROM sentences
LIMIT 20;
```
Here, we see the doc number repeated multiple times sometimes, which represents the same inmate having multiple different sentences. 

Suppose we wanted to look at counts of inmates by race and gender. We can use SQL to do this.

```sql
SELECT inmate_race_code, inmate_gender_code, count(*)
FROM inmate
GROUP BY inmate_race_code, inmate_gender_code
ORDER BY count(*) DESC
LIMIT 20;
```
What if we wanted to do this using `dbplyr`? We can use the `tbl` function and use `dplyr` code in order to do the same thing.

```r
inmate <- tbl(con, 'inmate')
inmate %>% 
  group_by(INMATE_RACE_CODE, INMATE_GENDER_CODE) %>%
  summarize(count = n()) %>% 
  arrange(desc(count))
```

```sql
SELECT *
FROM offender
LIMIT 10;
```

```sql
SELECT inmate_race_code, inmate_gender_code, count(*)
FROM inmate
JOIN sentences
ON inmate.INMATE_DOC_NUMBER = sentences.INMATE_DOC_NUMBER
GROUP BY inmate_race_code, inmate_gender_code
ORDER BY count(*) DESC
LIMIT 20;

```

```r
dbDisconnect(con)
```
