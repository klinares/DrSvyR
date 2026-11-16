---
id: "jpsm/fund_comp_data_display_SURV727/code/07_advanced_nlp"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Advanced Natural Language Processing"
original: "fund_comp_data_display_SURV727/code/07_advanced_nlp.Rmd"
pages: 
sha256: "39eaac475d8254818a91132e991733e4e2486d868da24b8a1f360a855070f6c5"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


```r
library(spacyr)
library(tidyverse)
library(quanteda)

```


Beyond the bag of words: advanced NLP with Google Cloud Natural Processing
```r
browseURL("https://cloud.google.com/natural-language/")
```

## package "spacyr"

Installation guide and examples
```r
browseURL("https://spacyr.quanteda.io/index.html")
```

Description of POS tagging
```r
browseURL("https://universaldependencies.org/u/pos/all.html")
```

Description of spacyr annotations
```r
browseURL("https://spacy.io/api/annotation")
```

Original spacy package documentation (Python)
includes online parser.
```r
browseURL("https://spacy.io/usage/linguistic-features#pos-tagging")
```

Installing spacy - need to check console when running this code chunk!
```r
# install.packages("spacyr", repos = "http://cran.us.r-project.org")
# spacy_install() 

```

Initializing spacy
```r
spacy_initialize()
```


## POS tagging on small dataset

Basic parsing. Output is data frame.
```r
titles = c("Macron gives Johnson until end of week to overhaul brexit plan.",
           "Macron’s national debate on immigration plays into the hands of the French far right.",
           "Boris Johnson is still gambling on winning his Brexit blame game.")
spacy_parse(titles, lemma = FALSE)
```

What types of entities are recognized from the text?
Are the POS correctly tagged? Do  you find any parsing errors?
Are the entities correctly tagged? Do you find any parsing errors?

Advanced parsing: include lemmas and dependency scheme.
All additional attributes here: https://spacy.io/api/token#attributes

```r
titles_parsed = spacy_parse(titles,
                            lemma = TRUE, 
                            tag = TRUE,
                            dependency = TRUE,
                            nounphrase = TRUE)
#                           additional_attributes = c("is_punct","is_digit",
#                                                      "like_url","like_email"))
titles_parsed
```

How is lemmatization different from stemming?
Analyze the first sentence. What is the root, subject, Direct object?



### Extract tokens by part of speech.
Piping and dplyr can be used on the parsed data frame to filter for specific keywords
```r
# Extract only verbs
titles_parsed %>% filter(pos == "VERB")
# Extract only nouns and adjectives
titles_parsed %>% filter(pos %in% c("NOUN","PROPN","ADJ"))
# Extract only root and subject
titles_parsed %>% filter(dep_rel %in% c("ROOT","nsubj"))
# Extract only persons
titles_parsed %>% filter(str_detect(entity, "PERSON"))
```

### Count tokens by type

Count by POS. Which type is most frequent?
```r
titles_parsed %>% 
  count(pos) %>%
  arrange(desc(n))
```

Exercise: count by entity
```r

```

### Extract and consolidate entities
```r
entity_extract(titles_parsed)
```

Compound entities into full data frame
```r
entity_consolidate(titles_parsed)
```

### Integrate with Quanteda

```r
titles_tokens = as.tokens(titles_parsed,
                          include_pos = "pos", use_lemma = TRUE) %>%
                tokens_tolower()
titles_tokens
```

Extract only nouns
```r
titles_tokens_nouns = titles_tokens %>% 
                        tokens_select(pattern = c("*/noun|propn")) 
titles_tokens_nouns
```

Transform to DFM
```r
titles_dfm = dfm(titles_tokens_nouns)
topfeatures(titles_dfm)
```




## POS tagging on large dataset

```r
REDDIT_MAY = read_csv("RedditTrollsPraktikum.csv") %>%
                filter(month == "May") %>%
                mutate(doc_id = paste0("text",1:nrow(.)))
REDDIT_MAY
```

Parse text
```r
R_parsed = spacy_parse(REDDIT_MAY$title,
                            lemma = TRUE, 
                            tag = TRUE,
                            nounphrase = TRUE,
                            dependency = TRUE)
R_parsed
```


Consolidate entities and noun phrases.

```r
R_consolidated = R_parsed %>% entity_consolidate()
R_consolidated
```

Count persons

```r
R_entity_count = 
  R_consolidated %>%
    filter(entity_type == "PERSON") %>%
    count(token) %>%
    mutate(token = substr(token, 1, 30)) %>%
    arrange(desc(n))
R_entity_count
```

### Group with metadata

```r
R_with_meta = left_join(R_consolidated, REDDIT_MAY)
R_with_meta
```

Count POS for trolls and others.
```r
table1 = table(R_with_meta$pos, R_with_meta$is_troll)
prop.table(table1, margin  = 2) %>% round(2)
```

### Integration with quanteda

Include POS.

```r
R_tokens = as.tokens(R_consolidated,
                     include_pos = "pos", use_lemma = TRUE)
R_tokens[2:4]
```

Select only nouns, adjectives, verbs and adverbs.
Remove stopwords, lowercase
```r
R_tokens_clean = R_tokens %>%
                    tokens(remove_punct=TRUE) %>%
                    tokens_select(pattern = "*/NOUN|ADJ|ENTITY") %>%
                    tokens_split("/") %>%
                    tokens_remove(c("noun","adj","propn","entity","-", 
                                  stopwords("en"))) %>%
                    tokens_tolower()
R_tokens_clean[2:4]
```

Tokens to DFM

```r
# define dfm, remove tokens that appear in less than 10 documents
R_dfm = dfm(R_tokens_clean) %>%
        dfm_trim(min_docfreq = 10)
# add metadata
docvars(R_dfm) = REDDIT_MAY %>% arrange(doc_id) %>% select(doc_id, subreddit:date, is_troll)
R_dfm
topfeatures(R_dfm)
```


Get top nouns and adjectives by subreddit.
```r
topfeatures(R_dfm, groups = "subreddit", n = 5)
```


When finished with spacyr, can run this to free memory:
```r
spacy_finalize()
```
