---
id: "jpsm/fund_comp_data_display_SURV727/lectures/Comp_12_Big_data_processing-1"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "Big data processing"
original: "fund_comp_data_display_SURV727/lectures/Comp_12_Big data processing-1.pdf"
pages: 24
sha256: "18498700964da6c01bceafed2c98d1a37ccffe578c0a74284bb8981a1b387a6b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:58"
---

<!-- page 1 -->

# Big data processing
## Fundamentals of Computing and Data Display

Christoph Kern &emsp; Ruben Bach

(c.kern, r.bach)@uni-mannheim.de

<!-- page 2 -->

# Outline

1. Introduction
2. MapReduce
   * Hadoop and Spark
3. AWS
4. Tools for R
   * data.table
   * (do)parallel
   * sparklyr
5. Resources
6. References

Fundamentals of Computing and Data Display | Big data processing | 2 / 24

<!-- page 3 -->

# Introduction

Approaches to programming with big data

* Utilize local machine better (multiple cores)
  * Various R packages for parallelization available
* Use better remote machine
  * e.g. AWS
* Use multiple remote machines (cluster)
  * Hadoop
  * Spark

Things to care about/ bottlenecks

* Processing capacity
* Disk, memory storage
* Transfer speed

<!-- page 4 -->

MapReduce

# MapReduce

A programming paradigm for parallel computing
1. Map
   * Input: A list of key-value pairs
   * Apply a (user-specified) map function (utilize multiple mappers)
2. Shuffle
   * Sorts and groups map output by keys
3. Reduce
   * Apply a reduce function on the grouped data
   * Output: List of values

Fundamentals of Computing and Data Display Big data processing 4 / 24

<!-- page 5 -->

# MapReduce

Figure: MapReduce example$^1$

---
$^1$https://www.geeksforgeeks.org/mapreduce-understanding-with-real-life-example/

*[Figure: This flow diagram illustrates a MapReduce process divided vertically into three stages: the Map Phase, Shuffle Phase, and Reduce Phase. It shows how key-value pairs from six initial input splits (representing two devices each for Rajasthan, Asam, and Gujrat) are processed by mappers, routed via directional arrows, and aggregated into final summed results by two reducers ("Headquarter Dev1" and "Headquarter Dev2").]*

<!-- page 6 -->

MapReduce | Hadoop and Spark

# Hadoop

A MapReduce implementation

* Hadoop Distributed File System (HDFS)
  * Input is split into blocks and stored on different nodes
  * Blocks are also replicated across nodes
* Bringing compute to the data
  * Combining computing and storage at each node
  * Enables fast data access (data locality)

Figure: Traditional (a) and Hadoop's (b) computing approach$^3$

---
$^3$Foster et al. 2017

Fundamentals of Computing and Data Display | Big data processing | 6 / 24

*[Figure: The two-part conceptual diagram compares a traditional computing approach (a) with Hadoop's approach (b), without any coordinate axes. It illustrates how the traditional method moves centralized data cylinders to separate processing tasks (Task 0 through Task 5), whereas Hadoop places the tasks directly onto individual distributed data cylinders, bringing computation to the data.]*

<!-- page 7 -->

MapReduce Hadoop and Spark

# Hadoop

Figure: MapReduce process in Hadoop$^4$

Data on HDFS
Input Partition
Map Map Map Map
Shuffling
Sort in Parallel
Reduce Reduce
Output Partition
Data on HDFS

---
$^4$Foster et al. 2017

Fundamentals of Computing and Data Display Big data processing 7 / 24

*[Figure: The diagram is a vertical flowchart illustrating the stages of the MapReduce process in Hadoop, progressing from top to bottom without coordinate axes. It shows how data on HDFS is divided into input partitions, processed in parallel by "Map" nodes into four distinct colored categories (blue, red, orange, green), shuffled and sorted to group matching colors together, and finally combined by "Reduce" nodes into output partitions written back to HDFS.]*

<!-- page 8 -->

MapReduce   Hadoop and Spark

# Spark

A beyond-MapReduce cluster-computing framework
- Iterative processes in MapReduce typically require writing data to storage system
  - Slow data sharing, many read-write operations
- Spark builds on resilient distributed datasets (RDD)
  - Distributed collections of objects that may be computed on different nodes
  - RDDs can be kept loaded in memory for fast access

Fundamentals of Computing and Data Display   Big data processing   8 / 24

<!-- page 9 -->

AWS

# AWS

1. Introduction
2. MapReduce
   - Hadoop and Spark
3. **AWS**
4. Tools for R
   - data.table
   - (do)parallel
   - sparklyr
5. Resources
6. References

Fundamentals of Computing and Data Display | Big data processing | 9 / 24

<!-- page 10 -->

# AWS

Amazon Web Services (AWS)

* Amazon Elastic Compute Cloud (EC2)
* Amazon Simple Storage Service (Amazon S3)
* ...many more

EC2 instances

* `https://aws.amazon.com/ec2/instance-types/`
* Optimized for different tasks
  * General purpose, compute, memory, storage, ...
* 0.5 GB up to 3904 GB of memory
* 1 core up to 96 cores
* Free tier `t2.micro` instance

<!-- page 11 -->

# AWS

Amazon Machine Image (AMI)

* Pre-packed system for usage on own server
* Operating system + (potentially) software
* Pre-configured **RStudio Server AMIs** available!
  * `http://www.louisaslett.com/RStudio_AMI/`

---

Fundamentals of Computing and Data Display | Big data processing | 11 / 24

<!-- page 12 -->

AWS

# AWS

Setup process

1. Create AWS account and sign in
2. Choose an (RStudio Server) AMI
3. Choose an instance type
4. Edit the security group settings and open ports
    * 22 for SSH
    * 80 for HTTP
    * 443 for HTTPS
    * 8787 for RStudio Server
5. Create (or choose) a key pair and download file
6. Launch Instance
7. Open the public DNS in your favorite browser
8. Login to Rstudio Server
    * Your Username: rstudio
    * Your Password: `<Your Instance ID>`

Fundamentals of Computing and Data Display Big data processing 12 / 24

<!-- page 13 -->

# Tools for R

1. Introduction
2. MapReduce
   - Hadoop and Spark
3. AWS
4. Tools for R
   - data.table
   - (do)parallel
   - sparklyr
5. Resources
6. References

<!-- page 14 -->

# Tools for R

Selected tools for big(ger) data processing in R

- Import and transform data with enhanced data frames
  - `data.table`
- Speed up processing by parallelizing code
  - `parallel`, `doparallel`
- Utilize Spark cluster
  - `sparklyr`

<!-- page 15 -->

Tools for R | data.table

# data.table

Table: Data import in R

| | **data.table**<br>`data.table` | **Base R**<br>`data.frame` | **readr**$^5$<br>`tibble` | **foreign**<br>`data.frame` | **haven**<br>`tibble` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Generic / Text Files | `fread()` | `read.table()` | `read_delim()` | | |
| Comma-Separated | `fread()` | `read.csv()`<br>`read.csv2()` | `read_csv()`<br>`read_csv2()` | | |
| Tab-Separated | `fread()` | `read.delim()`<br>`read.delim2()` | `read_tsv()`<br>`read_tsv2()` | | |
| SPSS files | | | | `read.spss()` | `read_sav()` |
| Stata files | | | | `read.dta()` | `read_dta()` |
| SAS files | | | | `read.ssd()` | `read_sas()` |

---
$^5$Up to 10x faster than Base R, 1.2-2x slower than data.table (`https://readr.tidyverse.org/`).

Fundamentals of Computing and Data Display | Big data processing | 15 / 24

<!-- page 16 -->

Tools for R $\quad$ data.table

# data.table

What is a `data.table`?

- Enhanced data frame
- Recommended for large datasets
- Comes with its own (SQL-inspired) syntax
  - `DT[i, j, by]`
  - WHERE (i), SELECT or UPDATE (j), GROUP BY (by)
- (Or) can be used as a `dplyr` backend
  - `https://cran.r-project.org/web/packages/dtplyr/`

---

Fundamentals of Computing and Data Display $\quad$ Big data processing $\quad$ 16 / 24

<!-- page 17 -->

# data.table

Table: Working with `data.table`

(a) Selecting rows

| Action | `data.table` |
| :--- | :--- |
| Select specific rows | `DT[c(1,2,5:10)]` |
| Select last row | `DT[.N]` |
| Filter by condition | `DT[a==15]` |
| Select first k rows | `head(DT, k), DT[1:k]` |
| Select last k rows | `tail(DT, k)` |

(b) Selecting columns

| Action | `data.table` |
| :--- | :--- |
| Select by col. num. | `DT[ , c(1,3:5)]` |
| Select by name | `DT[ , .(A,B,C)]` |
| Modify column | `DT[ , .(A,round(B))]` |
| Create new column | `DT[ , .(A, M = B+C)]` |

<!-- page 18 -->

# data.table

Table: Working with `data.table`

(a) Adding and Updating Columns

| Action | `data.table` |
| :--- | :--- |
| Update / Create new var. | `DT[, X := k]` |
| Update / Create multiple vars | `DT[, c("M","N") := list(A,B/2)]` |
| Remove a column | `DT[, A := NULL]` |
| Replacing missing val. | `DT[is.na(A), A := k]` |

(b) Aggregating

| Action | `data.table` |
| :--- | :--- |
| By one group | `DT[,.(agg = f(X)), by=A]` |
| By multiple groups | `DT[,.(agg = f(X)), by=.(A,B)]` |
| Multiple vars, same function | `DT[,.(agg1 = f(X), agg2=f(Y)), by=.(A,B)]` |
| Multiple vars, different functions | `DT[,.(agg1 = f(X), agg2=g(Y,Z),by=.(A,B,N=f(C))]` |

<!-- page 19 -->

Tools for R (do)parallel

# (do)parallel

When to parallelize?

- Perfectly (“embarrassingly”) parallel vs. inherently serial problems
  - Is function 2 independent or dependent on the output of function 1?
- Overhead
  - Copying data/ code when initializing parallelization reduces theoretical gains

Figure: Amdahl's law$^6$

---
$^7$`https://nceas.github.io/oss-lessons/parallel-computing-in-r/parallel-computing-in-r.html`

Fundamentals of Computing and Data Display Big data processing 19 / 24

*[Figure: The line plot, titled "Figure: Amdahl's law," displays "speedup" (from 0 to 20) on the vertical axis against a logarithmic "cpus" scale (marked at 8, 128, 2048, and 32768) on the horizontal axis. It compares five parallelizable proportion groups ("prop": p50, p75, p85, p90, and p95), showing that speedup increases with more CPUs before leveling off at higher asymptotes for higher proportions (up to a speedup of 20 for p95).]*

<!-- page 20 -->

Tools for R (do)parallel

# (do)parallel

Two approaches to parallel processing in R

- `apply`-like iterations: `parallel`
  - `multicore`
    - Fork/ copy process to multiple processors on one machine (excludes Windows)
  - `snow`
    - Spawn new process on local or remote machine (cluster of computers)
  - `vignette("parallel")`
- For loops: `doparallel`
  - `parallel`
  - `foreach`
  - `vignette("gettingstartedParallel")`

Fundamentals of Computing and Data Display Big data processing 20 / 24

<!-- page 21 -->

Tools for R   sparklyr

# sparklyr

An R interface to Spark

* Provides a `dplyr` backend to communicate with data in a Spark cluster
* Integrated into RStudio IDE
* Connect to a local Spark cluster from within R
  1. Install Spark locally: `spark_install()`
  2. Connect: `spark_connect(master = "local")`
  3. Experiment with Spark
  4. Disconnect: `spark_disconnect()`
* Connect to a remote Spark cluster

Fundamentals of Computing and Data Display   Big data processing   21 / 24

<!-- page 22 -->

Tools for R | sparklyr

# sparklyr

Example workflow

1. Connect to Spark
2. Copy data from R, file system, database to Spark
3. Communicate with data in Spark
   * Using `dplyr` language
   * Using SQL with `DBI` and `dbGetQuery()`
4. Run analysis within Spark (`MLlib`)
5. Extract results, create plots in R

Figure: Moving data from/to Spark

Fundamentals of Computing and Data Display | Big data processing | 22 / 24

*[Figure: The diagram titled "Figure: Moving data from/to Spark" illustrates the specific R functions used to transfer data between a central Apache Spark block and three external systems: R (on the left), Apache Hive (top right), and a File System (bottom right). It has no coordinate axes, instead using directional arrows to show bidirectional data movement with R (`sdf_copy_to`/`dplyr::copy_to`/`DBI::dbWriteTable` vs. `sdf_collect`/`dplyr::collect`/`sdf_read_column`) and the File System (`spark_read_<fmt>` vs. `spark_write_<fmt>`), alongside unidirectional import from Hive (`tbl_cache`/`dplyr::tbl`).]*

<!-- page 23 -->

Resources

# Resources

- Spark for Social Science
  - `https://urbaninstitute.github.io/spark-social-science-manual/`
- R Task View
  - `https://cran.r-project.org/web/views/HighPerformanceComputing.html`
- R Tools
  - `https://github.com/Rdatatable/data.table/wiki`
  - `http://spark.rstudio.com/`
- Cheatsheets
  - `https://github.com/rstudio/cheatsheets/raw/master/datatable.pdf`
  - `https://github.com/rstudio/cheatsheets/raw/master/sparklyr.pdf`

Fundamentals of Computing and Data Display Big data processing 23 / 24

<!-- page 24 -->

References

# References

Foster, I., Ghani, R., Jarmin, R. S., Kreuter, F., and Lane, J. (Eds.). (2017). *Big Data and Social Science: A Practical Guide to Methods and Tools.* Boca Raton, FL: CRC Press Taylor & Francis Group.

White, T. (2015). Hadoop: The Definitive Guide. Sebastopol, CA: O’Reilly Media.

Fundamentals of Computing and Data Display | Big data processing | 24 / 24
