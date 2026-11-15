---
id: "jpsm/Fund_data_collection_SURV622/LLM_demo/R/text_analysis"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lab"
title: "text_analysis"
original: "Fund_data_collection_SURV622/LLM_demo/R/text_analysis.Rmd"
pages: 
sha256: "8e191c9c8d1ea09a324c7a752fe41818754c6ac2cdfe3e2070edb8284d618760"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:01:01"
---


```r
knitr::opts_chunk$set(echo = TRUE)
```

# Bag of Words demo

This is a demo for class SURV 622/SURVMETH 622. It contains two sections: Bag of words model and Word2Vec model for representation learning.

```r
#Load Packages
#install.packages(c('tm','word2vec','udpipe', 'uwot','glmnet';))
library(tm)
library(ggplot2)
library(word2vec)
library(uwot)
library(glmnet)
cos.sim <- function(a,b) 
{

    return( sum(a*b)/sqrt(sum(a^2)*sum(b^2)) )
}   
```

## Read the data

Data are downloaded from Kaggle (https://www.kaggle.com/datasets/kazanova/sentiment140). The tweets have been annotated (0 = negative, 4 = positive) and they can be used to detect sentiment.

```r
tweets = read.csv("training.100000.processed.noemoticon.csv",stringsAsFactors=FALSE, encoding = "UTF-8")
```

## Check the text

The data has been prepossessed. Let's take a look.
```r
head(tweets)
```

### Check missing data
```r
sum(is.na(tweets$target))
sum(is.na(tweets$ids))
sum(is.na(tweets$text))
```
This line is to address some encoding error.
```r
tweets$text = iconv(tweets$text,"WINDOWS-1252","UTF-8") 
```

## Create a document-term matrix
Prepossessing Road map:
1. lower all character
2. remove numbers
3. remove punctuation
4. remove stop words
```r
tweet_corpus = Corpus(VectorSource(tweets$text))
```

```r
tweet_corpus = tm_map(tweet_corpus, content_transformer(tolower))
tweet_corpus = tm_map(tweet_corpus, removeNumbers)
tweet_corpus = tm_map(tweet_corpus, removePunctuation)
tweet_corpus = tm_map(tweet_corpus, removeWords, c("the", "and", stopwords("english")))
tweet_corpus =  tm_map(tweet_corpus, stripWhitespace)
```


### Convert word vector to document-term matrix
```r
tweet_dtm = DocumentTermMatrix(tweet_corpus)
tweet_dtm
```

Take a quick look at first 15 documents and terms.

```r
inspect(tweet_dtm[1:15, 1:15])
```

Drop most of the rare terms to make the matrix dense.
```r
tweet_dtm = removeSparseTerms(tweet_dtm, 0.99)
```

```r
tweet_dtm
```

### Implement Latent Semantic Analysis (LSA)
```r
tweet_svd = svd(tweet_dtm)
```

### Review the latent topic for the first 15 documents.
```r
heatmap(tweet_svd$u[1:15,1:15])
```

# Word2Vec
## Start from the scratch
We will build a Word2Vec by ourselves using CBOW architecture in the context of tweets we have seen. 

## Train the model
```r
set.seed(1015)
model = word2vec(x = tweets$text, type = "cbow", dim = 15, iter = 10)
```

## Visulize the word relation using UMAP
```r
embedding = as.matrix(model)
viz = umap(embedding, n_neighbors = 15, n_threads = 2)
df  = data.frame(word = gsub("//.+", "", rownames(embedding)), 
                  xpos = gsub(".+//", "", rownames(embedding)), 
                  x = viz[, 1], y = viz[, 2], 
                  stringsAsFactors = FALSE)
library(plotly)
plot_ly(df[500:700,], x = ~x, y = ~y, type = "scatter", mode = 'text', text = ~word)
```

## Using pretrained Word2Vec model

```r
model = read.word2vec("18/model.bin", normalize = TRUE)

```

### Select any word and its neighbors (in terms of sematic similarity)
```r
predict(model, newdata = c("fries", "money"), type = "nearest", top_n = 5)
```
### Arithmetic of word vector
```r
wv = predict(model, newdata = c("king", "man", "woman"), type = "embedding")
wv = wv["king", ] - wv["man", ] + wv["woman", ]
predict(model, newdata = wv, type = "nearest", top_n = 3)
```

### Implicit stereotype
Let check the word *nurse* will more similar to *man* or *woman*
```r
wv_woman = predict(model, newdata = c("woman"), type = "embedding")
wv_man = predict(model, newdata = c("man"), type = "embedding")
wv_nurse = predict(model, newdata = c("nurse"), type = "embedding")
cos.sim(wv_woman, wv_nurse)
cos.sim(wv_man, wv_nurse)
```

\


Arithmetic operations on vectors (plus, minus, dot product, etc.)
```r
wv = predict(model, newdata = c("child", "elementary", "woman"), type = "embedding")
wv = wv["woman", ] - wv["elementary", ] + wv["child", ]
predict(model, newdata = wv, type = "nearest", top_n = 3)
```

Calculate the similarity among word pairs you are interested in.
```r
predict(model, newdata = c("elementary", "teacher"), type = "nearest", top_n = 5)

```


\

Discover potential implicit stereotypes in the Word2Vec model.
```r
wv_woman = predict(model, newdata = c("woman"), type = "embedding")
wv_man = predict(model, newdata = c("man"), type = "embedding")
wv_teacher = predict(model, newdata = c("teacher"), type = "embedding")
cos.sim(wv_woman, wv_teacher)
cos.sim(wv_man, wv_teacher)
```





