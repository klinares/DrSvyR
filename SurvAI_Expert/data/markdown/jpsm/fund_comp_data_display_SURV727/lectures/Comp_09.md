---
id: "jpsm/fund_comp_data_display_SURV727/lectures/Comp_09"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "Databases & SQL"
original: "fund_comp_data_display_SURV727/lectures/Comp_09.pdf"
pages: 25
sha256: "5cd2819099b17dd2614a45638e84c78379dfe84a7ce5180cbb177eb15416e01e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:57"
---

<!-- page 1 -->

# Databases & SQL

## Fundamentals of Computing and Data Display

Christoph Kern $\quad$ Ruben Bach

(c.kern, r.bach)@uni-mannheim.de

<!-- page 2 -->

# Outline

1. Introduction
   * Types of databases
2. SQL Basics
   * RDB setup
   * SQL queries
3. SQL & R
   * SQL & d(b)plyr
4. Resources
5. References

Fundamentals of Computing and Data Display | Databases & SQL | 2 / 25

<!-- page 3 -->

# Introduction

Figure: Number of data science jobs for popular software packages$^1$

---
$^1$`http://r4stats.com/articles/popularity/`

*[Figure: This horizontal lollipop plot compares the number of data science jobs on Indeed.com (x-axis, ranging from 0 to over 15,000) across 25 popular data science software packages and programming languages (y-axis). The chart is ordered from most to least in-demand, showing that SQL leads significantly at nearly 18,000 jobs, followed by Python, Java, Hadoop, and R, before steadily tapering off down to Caffe with near-zero listings.]*

<!-- page 4 -->

Introduction

# Introduction

Why using databases?
1. Volume
    * R loads all data (`.Rdata`) into memory
    * Physical limitation: RAM (e.g. 4, 8, 16 gigabytes)
2. Speed
    * Searching, filtering big data inefficient w/o indices
3. Consistency
    * Data might need to be updated, accessed by multiple users
    * Data project might involve transactions between server and client

Fundamentals of Computing and Data Display  
Databases & SQL

<!-- page 5 -->

# Types of databases

A database$^2$
* "...is a structured collection of data about entities and their relationships"

A database management system (DBMS)$^2$
* "...is a software suite designed to safely store and efficiently manage databases, and to assist with the maintenance and discovery of the relationships that database represents"

Types of DBMSs
* Relational DBMSs
    * Store large **tabular** data
    * Organize multiple tables linked by keys
    * Communicate via SQL (Structured Query Language)
* NoSQL DBMSs
    * Store (extra-)large amounts of **unstructured** data

---
$^2$Foster et al. 2017

<!-- page 6 -->

# Types of databases

Figure: Combining different DBMS in a research project$^3$

* PubMed abstracts
* Researcher web pages
* Patent abstracts
* Twitter messages

Big NoSQL database

* Extracted research area $\rightarrow$ Domain-specific relational database
* Extracted collaboration network $\rightarrow$ Graph database

---
$^3$Foster et al. 2017

*[Figure: This diagram illustrates a data workflow that combines three types of database management systems in a research project, moving left-to-right without axes. It shows four groups of raw text sources (PubMed abstracts, researcher web pages, patent abstracts, and Twitter messages) first being collected into a central "Big NoSQL database," from which extracted research area data is routed into a "Domain-specific relational database" (depicted with a table) and extracted collaboration networks are routed into a "Graph database" (depicted with a node-link diagram).]*

<!-- page 7 -->

SQL Basics

# SQL Basics

1. Introduction
   * Types of databases
2. SQL Basics
   * RDB setup
   * SQL queries
3. SQL & R
   * SQL & d(b)plyr
4. Resources
5. References

Fundamentals of Computing and Data Display | Databases & SQL | 7 / 25

<!-- page 8 -->

SQL Basics

# SQL Basics

Standard SQL
* ANSI standard, several versions (starting with SQL-86)

Some implementations (SQL dialects)
* SQLite
  * `https://sqlite.org/`
* MySQL
  * `https://www.mysql.com/`
* PostgreSQL
  * `https://www.postgresql.org/`
* Proprietary RDBMS
  * Microsoft SQL Server, Oracle

Fundamentals of Computing and Data Display | Databases & SQL | 8 / 25

<!-- page 9 -->

SQL Basics RDB setup

# RDB setup

Set up a database

* `CREATE DATABASE dbname;`
* `CREATE TABLE tblname (...);`
  * Requires a list of **definitions**, i.e. name and type per column
  * Allows to specify **constraints** per column
  * Should include the specification of a `PRIMARY KEY` (unique ID)
  * May allow adding indices with `INDEX` or via keys
* `LOAD DATA`, `COPY`, `INSERT`, `UPDATE`
  * Loading to and updating data in a table

```sql
> CREATE TABLE db.example (
> entity_id integer NOT NULL,
> outcome_date date,
> outcome character varying,
> ybirth numeric);
```

Fundamentals of Computing and Data Display Databases & SQL 9 / 25

<!-- page 10 -->

SQL Basics  RDB setup

# RDB setup

List and select database(s), list and describe tables

* `SHOW DATABASES;`
* `USE dbname;`
* `SHOW TABLES;`
* `DESCRIBE tblname;`

Fundamentals of Computing and Data Display  Databases & SQL  10 / 25

<!-- page 11 -->

SQL Basics SQL queries

# SQL queries

### SQL queries

* `SELECT . . . FROM`
  * Necessary clauses in every `SELECT` query
  * Select all columns via \* or list names
  * Modify column names in query result with `AS`
  * Apply functions with statements preceding `AS`

```sql
> --A very simple query;
> SELECT *
> FROM example
> LIMIT 500;
> --Another example;
> SELECT COUNT(*) AS n_rows
> FROM example
```

Fundamentals of Computing and Data Display Databases & SQL 11 / 25

<!-- page 12 -->

SQL Basics SQL queries

# SQL queries

* `WHERE`
    * Filter rows of **original table**
    * Combine conditions with `AND`, `OR`
* `GROUP BY`
    * Aggregate rows by groups
    * Needs aggregation functions after `SELECT`
        * e.g. `COUNT, SUM, MAX, AVG`
* `HAVING`
    * Filter rows of **result set**
    * Same syntax as `WHERE`
* `ORDER BY`
    * Order results based on column(s)

Fundamentals of Computing and Data Display Databases & SQL 12 / 25

<!-- page 13 -->

SQL Basics SQL queries

# SQL queries

* `JOIN`
  * DBMSs store data on different levels in separate tables
  * Relationships formalized with (foreign) keys
  * Types, syntax of joining varies among SQL flavors
* Types of joins (PostgreSQL)
  * `INNER JOIN`
  * `OUTER JOIN`
  * `LEFT JOIN`
  * `RIGHT JOIN`
  * ...

Fundamentals of Computing and Data Display Databases & SQL 13 / 25

<!-- page 14 -->

# SQL queries

## SQL JOINS

```sql
SELECT <select_list>
FROM TableA A
LEFT JOIN TableB B
ON A.Key = B.Key
```

```sql
SELECT <select_list>
FROM TableA A
RIGHT JOIN TableB B
ON A.Key = B.Key
```

```sql
SELECT <select_list>
FROM TableA A
INNER JOIN TableB B
ON A.Key = B.Key
```

```sql
SELECT <select_list>
FROM TableA A
LEFT JOIN TableB B
ON A.Key = B.Key
WHERE B.Key IS NULL
```

```sql
SELECT <select_list>
FROM TableA A
RIGHT JOIN TableB B
ON A.Key = B.Key
WHERE A.Key IS NULL
```

```sql
SELECT <select_list>
FROM TableA A
FULL OUTER JOIN TableB B
ON A.Key = B.Key
```

```sql
SELECT <select_list>
FROM TableA A
FULL OUTER JOIN TableB B
ON A.Key = B.Key
WHERE A.Key IS NULL
OR B.Key IS NULL
```

© C.L. Moffatt, 2008

<!-- page 15 -->

SQL Basics SQL queries

# SQL queries

Subqueries

* (Inner) queries can be nested within a (outer) query
* Allows to “stack” multiple operations
* Result set from inner query is passed to outer query
* Dimension of result must match outer operation
  * e.g., WHERE with an equal condition requires a one cell result

```sql
> --A query within a query;
> SELECT * FROM example
> WHERE ybirth = (SELECT MIN(ybirth)
>                 FROM example
>                );
```

Fundamentals of Computing and Data Display Databases & SQL 15 / 25

<!-- page 16 -->

# SQL queries

Order of clauses in a query

1. `SELECT`
2. `FROM`
3. `JOIN`
4. `WHERE`
5. `GROUP BY`
6. `HAVING`
7. `ORDER BY`
8. `LIMIT`

<!-- page 17 -->

SQL & R

# SQL & R

1. Introduction
   * Types of databases
2. SQL Basics
   * RDB setup
   * SQL queries
3. **SQL & R**
   * **SQL & d(b)plyr**
4. Resources
5. References

Fundamentals of Computing and Data Display | Databases & SQL | 17 / 25

<!-- page 18 -->

SQL & R

# SQL & R

Connecting to a database from within R
- A common DataBase Interface: `DBI`
  - Generic interface (“front-end”) for accessing an arbitrary RDBMS
  - Communication with specific RDBMS provided by drivers (“back-end”)
- (Some) DBI-compliant driver packages
  - `RSQLite`
  - `RMySQL`
  - `RPostgreSQL`
  - `odbc`

Fundamentals of Computing and Data Display | Databases & SQL | 18 / 25

<!-- page 19 -->

SQL & R

# SQL & R

DBI workflow

1. `dbDriver()`
   * Create driver for particular RDBMS
2. `dbConnect()`
   * Connect to RDB by providing name, location, log-in credentials
3. `dbGetQuery()`
   * Execute SQL querys
4. `dbDisconnect()`

* Other (useful) functions
  * Separate send and fetch: `dbSendQuery()` and `dbFetch()`
  * List tables in database: `dbListTables()`

Fundamentals of Computing and Data Display
Databases & SQL

<!-- page 20 -->

# SQL & d(b)plyr

Use `dplyr` on top of a DBI connection: `dbplyr`

1. `dbConnect()`
   - Connect to a RDB
2. `tbl()`
   - Map table in database to object in R
3. `dplyr`
   - Use tables as if they were data frames in R!
   - Pull data to a local tibble: `collect()`

```r
# Pulling a table into R with dbplyr
> exp_sub <- example %>%
> filter(ybirth == 1984) %>%
> collect() %>%
> mutate(outcome_f = as.factor(outcome))
```

<!-- page 21 -->

SQL & R   SQL & d(b)plyr

# SQL & d(b)plyr

Figure: Dependencies of SQL-related R packages$^4$

RMySQL

dplyr $\longrightarrow$ DBI $\longrightarrow$ RPostgreSQL

RSQLite

---
$^4$Baumer et al. 2017

Fundamentals of Computing and Data Display   Databases & SQL   21 / 25

*[Figure: The diagram illustrates the dependencies among five SQL-related R packages without axes. It shows a directed flow starting from "dplyr" pointing to "DBI", which then branches out with arrows pointing to "RMySQL", "RPostgreSQL", and "RSQLite".]*

<!-- page 22 -->

SQL & R SQL & d(b)plyr

# SQL & d(b)plyr

Translating pipelines into SQL
* `show_query()`
  * Shows SQL equivalent of pipeline code
  * Not all R functions supported
* `translate_sql()`
  * Runs translation between R and SQL functions
  * `https://cran.r-project.org/web/packages/dbplyr/vignettes/sql-translation.html`

```r
# Translate basic expressions
> translate_sql(mean(ybirth))
<SQL> avg("ybirth") OVER ()
```

Fundamentals of Computing and Data Display Databases & SQL 22 / 25

<!-- page 23 -->

# SQL & d(b)plyr

Table: Comparison of SQL and dplyr syntax$^5$

| | SQL | R (dplyr) |
| :--- | :--- | :--- |
| Filter by rows & columns | `SELECT col1, col2` | `a %>%` |
| | `FROM a` | `filter(col3 == "x") %>%` |
| | `WHERE col3 = 'x'` | `select(col1, col2)` |
| Aggregate by rows | `SELECT id, sum(col1)` | `a %>%` |
| | `FROM a` | `group_by(id) %>%` |
| | `GROUP BY id` | `summarize(sum(col1))` |
| Combine two tables | `SELECT *` | `a %>%` |
| | `FROM a` | `inner_join(b, by =` |
| | `JOIN b ON a.id = b.id` | `c("id" = "id"))` |

---
$^5$Baumer et al. 2017

<!-- page 24 -->

Resources

# Resources

- Online Learning
  - `https://www.datacamp.com/courses/intro-to-sql-for-data-science`
  - `https://hackr.io/tutorials/learn-sql`
- DBs & Rstudio
  - `https://db.rstudio.com/`
- Cheatsheet
  - `http://files.zeroturnaround.com/pdf/zt_sql_cheat_sheet.pdf`

Fundamentals of Computing and Data Display | Databases & SQL | 24 / 25

<!-- page 25 -->

# References

Baumer, B. S., Kaplan, D. T., Horton, N. J. (2017). *Modern Data Science with R.* Boca Raton, FL: Chapman & Hall/CRC Press.

Foster, I., Ghani, R., Jarmin, R. S., Kreuter, F., and Lane, J. (Eds.). (2017). *Big Data and Social Science: A Practical Guide to Methods and Tools.* Boca Raton, FL: CRC Press Taylor & Francis Group.
