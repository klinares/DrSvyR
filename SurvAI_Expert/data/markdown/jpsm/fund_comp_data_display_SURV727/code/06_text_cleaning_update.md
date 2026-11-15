---
id: "jpsm/fund_comp_data_display_SURV727/code/06_text_cleaning_update"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "text-cleaning"
original: "fund_comp_data_display_SURV727/code/06_text_cleaning_update.Rmd"
pages: 
sha256: "28fd9c3dd93f473d9b83a005ce434e4cee2e33797012bdb6aa12f2ed972df429"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


```r
library(quanteda)
###
library(tidyverse)
library(lubridate)
#library(RTextTools)
```


# Quanteda
We will be using the package "quanteda" to clean up text data.
```r
#Installation and first steps:
browseURL("https://quanteda.io/")
#Official Quanteda tutorial:
browseURL("https://tutorials.quanteda.io/basic-operations/tokens/tokens_ngrams/")
```


# Reddit Russian trolls dataset

This is a dataset of reddit submissions from 2016.
Some of the users (is_troll == "TROLL") have been excluded
by the Reddit moderators for suspicion of being members of 
Russia's "troll farm" (Internet Research Agency).

First, let us explore the dataset.

```r
REDDIT <- read_csv("RedditTrollsPraktikum.csv")
REDDIT
```

Task: which are the subreddits where the trolls posted more?
```r
table(REDDIT$subreddit)
```

Task: select only trolls, plot the number of posts / month. 
```r
REDDIT %>%
  filter(is_troll == "TROLL") %>%
  count(subreddit) %>%
  arrange(desc(n))
```

Calculate number of characters in each text and sort dataset.

```r
REDDIT %>%
  mutate(n_char = nchar(title)) %>%
  group_by(is_troll) %>%
  summarise(median(n_char))
```

Plot number of posts / month
```r
REDDIT %>% count(month) %>% 
  ggplot(aes(x = month, y = n, group = 100)) + 
  geom_line()
```

Let us only keep the two months with the most number of posts.

```r
DFR <- REDDIT %>% filter(month %in% c("May","Aug"))
DFR
```



# Computational Text Analysis

Three steps:
1) creating a corpus: corpus()
2) tokenizing and cleaning: tokens(corpus), tokens_tolower(), tokens_remove
3) creating a document-feature-matrix: dfm(tokens), dfm_trim, dfm_tfidf

## 1. Creating a corpus

Let us start with a simple dataset of today's headlines.

```r
titles <- c("Macron gives Johnson until end of week. To overhaul brexit plan.",
           "Macron's national debate on immigration plays into the hands of the French far right.",
           "Boris Johnson is still gambling on winning his Brexit blame game.")
```

With the corpus() function we define a corpus on the set of 3 documents.
See help(corpus) for more information.
```r
T_corpus <- corpus(titles)
T_corpus
```


## 2. Tokenization

```r
tokens(T_corpus, what = c("sentence"))
tokens(T_corpus, what = c("word"))
tokens(T_corpus, what = c("character"))
```

Lowercasing, removing punctuation

```r
?tokens
T_tokens <- tokens(T_corpus, what = c("word"))
T_tokens_cleaned <- T_tokens %>%
                    tokens_tolower() %>%
                    tokens(remove_punct = TRUE)
T_tokens_cleaned
```

Removing stopwords

```r
print("English stopwords:"); 
stopwords("en")
##3
print("German stopwords");
stopwords("de")
```


Removing stopwords and stemming
```r
T_tokens_cleaned <- T_tokens %>%
                    tokens_tolower() %>%
                    tokens(remove_punct = TRUE) %>%
                    tokens_remove(stopwords("en")) %>%
                    tokens_wordstem(language = "en")
T_tokens
T_tokens_cleaned                    
```

```r
cat("\nType of variable:\n")
class(T_tokens_cleaned)
mode(T_tokens_cleaned)
cat("\nNumber of elements\n")
length(T_tokens_cleaned)
cat("\nNumber of tokens")
sapply(T_tokens_cleaned, length) %>% table
```


### Ngrams

```r
unigrams <- T_tokens_cleaned; 
    cat("\nUnigrams :"); print(T_tokens_cleaned)
bigrams <- unigrams %>% tokens_ngrams(n=2); 
    cat("\nBigrams :"); print(bigrams)
trigrams <- unigrams %>% tokens_ngrams(n=3); 
    cat("\nTrigrams :"); print(trigrams)
skipgrams1 <- unigrams %>% tokens_ngrams(n=3, skip = c(0,1))
    cat("\nTrigrams(including 1-skip) :"); print(skipgrams1)
```

Add n-grams to tokens
```r
print("- keeping onegrams")
T_tokens_cleaned %>% tokens_compound(phrase("bori johnson"))
```

## 3. Create document-feature matrix
```r
T_DFM <- dfm(T_tokens_cleaned) 
cat("\nInitial sparsity: \n")
dim(T_DFM)
```

Working with DFM
```r
cat("Feature names:\n")
  featnames(T_DFM)
  length(featnames(T_DFM))
```

Weight DFM
```r
T_DFM_prop <- T_DFM %>% dfm_weight("prop")
T_DFM_TFIDF <- T_DFM %>% dfm_tfidf(scheme_tf = "count")
T_DFM_TFIDF_prop <- T_DFM %>% dfm_tfidf(scheme_tf="prop")
###
T_DFM %>% convert("data.frame")
T_DFM_prop %>% convert("data.frame")
T_DFM_TFIDF %>% convert("data.frame")
T_DFM_TFIDF_prop %>% convert("data.frame")
```



# Reddit dataset
Now, let us define the corpus for the reddit dataset, including the metadata.
Because we are feeding it a data frame (DFR), we need to specify
which variable is the text field (the title, in our case),
and which variable contains the document id.

1. Build corpus

```r
R_corpus <- corpus(DFR, 
                  docid_field="id", 
                  text_field="title")
R_corpus
```

2. Tokenize

```r
R_tokens <- tokens(R_corpus, what = c("word"))
R_tokens[1:5]
print("Token lengths: "); cat("\n\n")
print(sapply(R_tokens[1:5], length))
```


Clean tokens

```r
R_tokens_cleaned <- R_tokens %>%
                   tokens_tolower() %>%
                   tokens(R_tokens, remove_numbers = TRUE, 
                        remove_punct = TRUE, 
                        remove_symbols = TRUE, 
                        remove_separators = TRUE,
                        remove_hyphens = FALSE) %>%
                   tokens_remove(stopwords("en")) %>%
                   tokens_wordstem(language = "en")

R_tokens[2:4]                 
R_tokens_cleaned[2:4]
```

3. Document - Feature Matrix (DFM) building

```r
R_DFM <- dfm(R_tokens_cleaned) 
R_DFM
```

Trim DFM.

```r
### Trim options
dfm_trim(R_DFM, min_termfreq =  10)
dfm_trim(R_DFM, min_termfreq = 100)
dfm_trim(R_DFM, min_docfreq =   10)
dfm_trim(R_DFM, min_docfreq =  100)

###
cat("\nFinal sparsity: \n")
R_DFM_trim <- dfm_trim(R_DFM, min_docfreq = 0.005,
                             max_docfreq = 0.900,
                             docfreq_type = "prop")
R_DFM_trim
```

Working with DFM
```r
print("First ten document names:")
  docnames(R_DFM_trim)[1:10]
print("First ten feature names:")
  featnames(R_DFM_trim)[1:10]
print("Names of features in metadata:")
  names(docvars(R_DFM_trim))
```

# Exploratory analysis

## Inspecting context

```r
kwic(R_corpus, "Russia")
```


## Calculating word frequencies

topfeatures() function outputs the words used most frequently
```r
topfeatures(T_DFM)
topfeatures(R_DFM_trim)
```


Explore dfm by group.
We can use variables from the metadata to split the dataset
in 2 or more groups and calculate word frequencies per group

```r
topfeatures(R_DFM_trim, 
            groups = "is_troll", 
            n = 20)
```

Exercise: get most common words by subreddit
```r
topfeatures(R_DFM_trim, 
            groups = "subreddit", 
            n = 20)
```


## Finding similar texts

Functions textstat_simil() and textstat_dist() from quanteda.
Compute similarity matrix
```r
?textstat_simil
titles
t1 <- textstat_simil(T_DFM, 
               margin = "documents",
               method = "jaccard")
```

Documents 1 and 3 are most similar.



# Class exercise - Text cleaning a corpus of NY Times headlines from 1996 to 2006.

```r
library(tidyverse)
library(lubridate)
library(quanteda)
NYTimes <- read_csv("NYTimes.csv")
```


Transforming the dataset, adding new variables for subsetting later (year, weekend).
```r
library(lubridate)
NYTimes <- read_csv("NYTimes.csv")
NYTimes <- NYTimes %>% 
            mutate_if(is.factor, as.character) %>%
            mutate(Date = dmy(Date),
                   year = year(Date),
                   weekday = wday(Date, week_start=1),
                   weekend = weekday %in% c(6,7))
NYTimes
```


1. Create corpus
```r
NYTcorpus <- corpus(NYTimes, 
                   docid_field = "Article_ID",
                   text_field = "Title")
NYTcorpus
```

2. Tokenize, clean and show tokens from first 5 documents
```r
NYTtokens <- NYTcorpus %>% 
              tokens(remove_punct = TRUE,
                     remove_numbers = TRUE,
                     remove_separators = TRUE) %>%
            tokens_tolower() %>%
            tokens_remove( stopwords("en") ) %>%
            tokens_wordstem(language = "en")
#NYTtokens <- tokens(NYTcorpus)
NYTtokens[1:5]
```

3. Transform to DFM
Keep only tokens that appear in at least 1% of documents.
```r
NYTdfm <- dfm(NYTtokens) %>%
          dfm_trim(min_docfreq = 0.01, 
                   docfreq_type = "prop")
NYTdfm
```

TF-IDF weighting to reduce the influence of very common words.
```r
NYTdfm_tfidf <- NYTdfm %>% dfm_tfidf() 
NYTdfm_tfidf[1:10,1:10]
```


What are the most common words in the corpus, by year?
```r
topfeatures(NYTdfm, 30)
```

What about in the TF-IDF DFM? Any differences?
```r
topfeatures(NYTdfm_tfidf, 30)
```

Count the top features for each year. How do the topics shift?
```r
topfeatures(NYTdfm, groups  = "year", 30)
```

What are the most common words in the corpus used in the weekend ?
```r
topfeatures(NYTdfm, groups = "weekend")
```

Pick one of the common words and find the context in which it was used.
```r
kwic(NYTcorpus, "bush")
```

Pick one headline and find the most similar headlines, using Jaccard similarity.
Are they from the same period?
```r
simil <- textstat_simil(NYTdfm, 
                       margin = "documents",
                       method = "jaccard")
```

E.g. we pick article with id = 41367.
Then we extract from the similarity matrix entry with rowname 41367.
We sort it and extract the names of the documents with the
highest Jaccard similarity scores.

```r
top10 <- names(rev(sort(simil[rownames(simil) == 41367,])))[1:10]
top10
```

Now we filter the dataset to include only the top 10 most similar.
```r
NYTimes %>% filter(Article_ID %in% top10) %>% select(Article_ID, Title)
```

