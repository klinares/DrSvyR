---
id: "jpsm/fund_comp_data_display_SURV727/code/huggingface_original"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Sentiment Analysis with Hugging Face Pre-Built Models"
original: "fund_comp_data_display_SURV727/code/huggingface_original.qmd"
pages: 
sha256: "7e32d8a97d35a436b18726de6e668aa4bbe9e39cf81fc1cd193ebdedcae89563"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


## Hugging Face

Hugging Face (<https://huggingface.co>) is an online hub that contains lots of pre-built models and other tools for a variety of tasks, including many NLP tasks such as sentiment analysis. These are state-of-the-art models that are built using sophisticated methods such as transformers.

In order to use these in R, we will need to actually use `reticulate` to interface with Python.

```r
if(!require('reticulate')) install.packages("reticulate")
library(reticulate)

# If miniconda is not installed yet.
# install_miniconda()
```

We can then install the `huggingfaceR` package from GitHub using `install_github`.

```r
if(!require('devtools')) install.packages("devtools")
if(!require('huggingfaceR')) devtools::install_github("farach/huggingfaceR")

library(huggingfaceR)
library(tidyverse)
```

## Loading a Model and Finding Sentiment

We can load models using the `hf_load_pipeline` function. Here, we bring in a Hugging Face model for sentiment.

```r

distilBERT <- hf_load_pipeline(
  model_id = "distilbert-base-uncased-finetuned-sst-2-english", 
  task = "text-classification"
  )
```

Let's try using it to get the sentiment of a simple sentence.

```r
distilBERT("I like you. I love you")
```

We can also see what happens with things like misspellings.

```r
distilBERT("This is terible")
```

Let's take a look at a dataset. This is loaded using `hf_load_dataset` and is an existing dataset provided by Hugging Face.

```r

imdb_train <- hf_load_dataset('imdb', 
                              split = "train", 
                              label_conversion = 'int2str')

distilBERT(imdb_train$text[1:5])
```

Let's try a different model that does sentiment with emotions rather than just negative or positive.

```r

emotion_distilroBERTa <- hf_load_pipeline(
  model_id = "j-hartmann/emotion-english-distilroberta-base", 
  task = "text-classification"
  )

```

Now, let's try applying it.

```r
emotion_distilroBERTa('I love this.')
```

LEIA (Linguistic Embeddings for the Identification of Affect)

```r
LEIA <- hf_load_pipeline(
    model_id = "LEIA/LEIA-base", 
    task = "text-classification"
    )

LEIA("I am so angry right now.")
```
