---
id: "jpsm/fund_comp_data_display_SURV727/code/Topic_models"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Text Mining - Topic Models"
original: "fund_comp_data_display_SURV727/code/Topic models.Rmd"
pages: 
sha256: "2c745f8e74ac046d3ae02ca2a12702eeee333f63f9d5498dc51c62763f2b6059"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


```r
knitr::opts_chunk$set(echo = TRUE)
```

## Load data and packages

About 230 “State of the Union” speeches. Availale at http://stateoftheunion.onetwothree.net

```r
options(stringsAsFactors = FALSE)
if(!require(quanteda)) install.packages("quanteda")
if(!require(topicmodels)) install.packages("topicmodels")
library(quanteda)
library(topicmodels)
library(tidyverse)
```

Docs are pretty long and length will certainly influence topic modelings. For very long texts or very short texts, it may make sense to split them up or combine them. Here, we split speeches up in paragraphs.

```r
textdata <- read.csv("sotu.csv", 
                     header = TRUE, 
                     sep = ";", 
                     encoding = "UTF-8")

colnames(textdata)


textdata %>%
  select(president) %>%
  table()

```


We use the textdata object with texts split up in paragraphs.

```r
textdata <- read.csv("sotu_paragraphs.csv", 
                     sep = ";", 
                     encoding = "UTF-8", as.is = T)

glimpse(textdata)

# create a corpus (text with metadata information)
corpus_sotu_orig <- corpus(textdata, 
                                     docid_field = "doc_id",
                                     text_field = "text")


# Tokenization
corpus_sotu_proc <- tokens(corpus_sotu_orig, 
                           remove_punct = TRUE, # remove punctuation
                           remove_numbers = TRUE, # remove numbers
                           remove_symbols = TRUE) %>% # remove symbols (for social media data, could remove everything except letters)
                        tokens_tolower() # remove capitalization
# Lemmatization #
lemmaData <- read.csv2("baseform_en.tsv", # downloaded from https://github.com/tm4ss/tm4ss.github.io/tree/master/resources
                       sep="\t", 
                       header=FALSE, 
                       encoding = "UTF-8", 
                       stringsAsFactors = F)

corpus_sotu_proc <-  tokens_replace(corpus_sotu_proc, # "Substitute token types based on vectorized one-to-one matching"
                                    lemmaData$V1, 
                                    lemmaData$V2,
                                    valuetype = "fixed") 

corpus_sotu_proc <- corpus_sotu_proc %>%
                             tokens_remove(stopwords("english")) %>%
                             tokens_ngrams(1) 
```

Two Corpi: Original and the processed one. We keep the original one for comparison purposes. Next, create dtm and do some trimming.

```r


#  Create dtm
DTM <- dfm(corpus_sotu_proc)

# Minimum
minimumFrequency <- 10
DTM <- dfm_trim(DTM, 
                min_docfreq = minimumFrequency,
                max_docfreq = Inf)

# keep only letters... brute force
DTM  <- dfm_select(DTM, 
                   pattern = "[a-z]", 
                   valuetype = "regex", 
                   selection = 'keep')
colnames(DTM) <- stringi::stri_replace_all_regex(colnames(DTM), 
                                                 "[^_a-z]","")

DTM <- dfm_compress(DTM, "features")

# We have several rows which do not have any content left. Drop them.

sel_idx <- rowSums(DTM) > 0
DTM <- DTM[sel_idx, ]
textdata <- textdata[sel_idx, ]
```

Topic models are a method particularly suited for explorative data analysis. We can compute what topics a document consists of. We often need to finetune with a few parameters.

We rely on an LDA model. Here, k is the most important parameter. The choice of k depends on the data. If k is too small, the corpus will be split up in a few vague topcis that we can't really interpret. If k is too large, topics may overlap and will be difficult to distinguish between them.

We will start with 20
```r
K <- 20
# Set seed to make results reproducible
set.seed(9161)
topicModel <- LDA(DTM, 
                  K, 
                  method="Gibbs", 
                  control=list(iter = 500, 
                               verbose = 25))

 
```


We get two important posterior distributions: theta over K themes in each doc and distribution beta over V terms in each theme. V represents the number of terms in each topic.

```r
tmResult <- posterior(topicModel)


# Topics are distributions over the entire vocabulary

beta <- tmResult$terms
glimpse(beta)            

# Each doc has a distribution over k topics

theta <- tmResult$topics
glimpse(theta)               

terms(topicModel, 10)

# Top terms per topic. Use top 5 to interpret topics
top5termsPerTopic <- terms(topicModel, 
                           5)
# For the next steps, we want to give the topics more descriptive names than just numbers. Therefore, we simply concatenate the five most likely terms of each topic to a string that represents a pseudo-name for each topic.
topicNames <- apply(top5termsPerTopic, 
                    2, 
                    paste, 
                    collapse=" ")
```

What are the most common themes?
```r

topicProportions <- colSums(theta) / nrow(DTM)  # average probability over all paragraphs
names(topicProportions) <- topicNames     # Topic Names
sort(topicProportions, decreasing = TRUE) # sort
```

Right now, each document has a nonzero probability for each topic. We can adjust that using the alpha paramter (automatically set in the previous example). However, sometimes we may assume that each doc should load on one or a few topics only (e.g. political news shouldn't load on sports news). Small alpha will result in a small number of topics where we allow nonzero probability, larger values allow probabilities on more topics.

```r
# What was the value in the previous model?
attr(topicModel, "alpha") 

# Re-estimate model with alpha set by us
topicModel2 <- LDA(DTM, 
                   K, 
                   method="Gibbs", 
                   control=list(iter = 500, 
                                verbose = 25, 
                                alpha = 0.2))
tmResult <- posterior(topicModel2)
theta <- tmResult$topics
beta <- tmResult$terms


topicProportions <- colSums(theta) / nrow(DTM)  # average probability over all paragraphs
names(topicProportions) <- topicNames     # Topic Names 
sort(topicProportions, decreasing = TRUE) # sort

topicNames <- apply(terms(topicModel2, 5), 2, paste, collapse = " ")  # top five terms per topic 
```


## Visualization of topic

```r
if(!require(reshape2)) install.packages("reshape2")
if(!require(ggplot2)) install.packages("ggplot2")
library("reshape2")
library("ggplot2")



# Topic distributions of example docs
exampleIds <- c(2, 100, 200)
N <- length(exampleIds)

topicProportionExamples <- as.tibble(theta) %>%
                              slice(exampleIds)
colnames(topicProportionExamples) <- topicNames

vizDataFrame <- melt(cbind(data.frame(topicProportionExamples), 
                           document = factor(1:N)), 
                     variable.name = "topic", 
                     id.vars = "document")  

ggplot(data = vizDataFrame, 
       aes(topic, value, 
           fill = document), 
       ylab = "proportion") + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, 
                                   hjust = 1)) +  
  coord_flip() +
  facet_wrap(~ document, 
             ncol = N)
```

Distribution of topics over years

```r
# Add decade
textdata$decade <- paste0(substr(textdata$date, 
                                 0, 
                                 3), "0")

# Average theme proportions by decade
topic_proportion_per_decade <- aggregate(theta, 
                                         by = list(decade = textdata$decade), 
                                         mean)
# set names
colnames(topic_proportion_per_decade)[2:(K+1)] <- topicNames

# Reshape for visualizatib
vizDataFrame <- melt(topic_proportion_per_decade, 
                     id.vars = "decade")

# Plot
if(!require(pals)) install.packages("pals")
library(pals)
ggplot(vizDataFrame, 
       aes(x=decade, 
           y=value, 
           fill=variable)) + 
  geom_bar(stat = "identity")+
  ylab("proportion") + 
  scale_fill_manual(values = paste0(alphabet(20), "FF"), name = "decade") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
```

Adapted from: 2017, Andreas Niekler and Gregor Wiedemann. GPLv3. tm4ss.github.io
