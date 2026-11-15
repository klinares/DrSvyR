---
id: "jpsm/fund_comp_data_display_SURV727/code/05-reddit"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Fundamentals of Computing and Data Display"
original: "fund_comp_data_display_SURV727/code/05-reddit.Rmd"
pages: 
sha256: "3d748d909335b1b31b1ae641b8344d67634901bf55dbf6afbd4dd1fe7f1dd37c"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


## Setup

```r
# install.packages("RedditExtractoR")
# install.packages("tidytext")
```

```r
library(tidytext)
library(RedditExtractoR)
```

## Collecting reddit data

We will use the package `RedditExtractoR` to obtain submission and comment data from reddit. Unfortunately, this package is not ideal for some of the tasks we may be interested in. Since I am not aware of fully functional R packages for obtaining reddit data from R, I have relied mostly on python.

```r
# We search for submissions which contain the word 'biden' to subreddit 'liberal'. From the resulting df, we get the URLs pointing to each submission. 
biden_urls <- find_thread_urls(keywords = "biden",
                                       subreddit = "liberal",
                                       sort_by = "top")

head(biden_urls$url)
```

We next get the comments to the submissions that we pulled above using the URLs of the submissions as reference.
```r
biden_content <- get_thread_content(urls = biden_urls$url[1:5])
```
Using `post_date` (submission) and `comm_date` (comment), we can select submissions and comments based on the time they were posted. Using `link`, we could try to obtain additional information about submission content (e.g., link may post to a news article). `Structure` allows us to obtain an overview of the comment structure. Most interestingly, `comment` gives us the content of the comment.

```r
head(biden_content$comments)
# Seems like there is some cleaning we will have to do!
```
