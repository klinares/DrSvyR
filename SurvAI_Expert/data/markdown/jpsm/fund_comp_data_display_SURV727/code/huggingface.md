---
id: "jpsm/fund_comp_data_display_SURV727/code/huggingface"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "Sentiment Analysis with Hugging Face Pre-Built Models"
original: "fund_comp_data_display_SURV727/code/huggingface.qmd"
pages: 
sha256: "a1333fdee9338eed0be80ec44bf89d0e0bcd8d9d93c4cbee076033b7d65bbb4a"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


## Hugging Face

Hugging Face (<https://huggingface.co>) is an online hub that contains lots of pre-built models and other tools for a variety of tasks, including many NLP tasks such as sentiment analysis. These are state-of-the-art models that are built using sophisticated methods such as transformers.

In order to use these in R, we will need to actually use `reticulate` to interface with Python.

```r
library(text)
library(readtext)
library(furrr)
library(parallel)
library(tidytext)
library(tidyverse)
#text::textrpp_install()
textrpp_initialize()

```

```r
file_path <- "data/imdb/train/unsup/"

file_list <- list.files("data/imdb/train/unsup/")

```

```r

plan(multisession, workers = detectCores())

dat <- future_map_dfr(file_list[1:50], function(x){
  readtext(str_c(file_path, x))
}) #|> 
  #mutate(text = str_trunc(text, 513))

```

```r
dat_unnest <- dat |> unnest_sentences(sentence, text)
```

```r
Sys.time()
generated_text <- textClassify(dat_unnest$sentence,
                                 model = "cardiffnlp/twitter-roberta-base-sentiment-latest", 
                               set_seed = 1234,
                               return_incorrect_results = TRUE,
                               #function_to_apply = "softmax",
                               device = "cpu")

generated_text
comment(generated_text)

Sys.time()
```
