---
id: "jpsm/fund_comp_data_display_SURV727/lectures/Text_Analysis"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "Text Analysis"
original: "fund_comp_data_display_SURV727/lectures/Text Analysis.pdf"
pages: 8
sha256: "f2cd08cf11556e10937243b7d3b07b502837ebce3e2885f5db4a176672412985"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:55"
---

<!-- page 1 -->

# Text Analysis

Fundamentals of Computing and Data Display

10/9/2024

<!-- page 2 -->

# Text Data

* Usually extracted using APIs (e.g., NYT API) or web scraping (e.g., Wikipedia for Assignment 3).
* Many techniques require cleaning ... but some more sophisticated techniques do not.
* Lots of different goals with text data – make sure you are using the appropriate one!

<!-- page 3 -->

# Topic Modeling

* **Idea**: We want to understand the topics within the documents of a large corpus of text. We could read them all ... or we can use topic modeling to identify groups of documents based on most frequent words.

* A form of **unsupervised machine learning**, similar to **clustering**.

<!-- page 4 -->

# Traditional Sentiment Analysis

* Dictionary-based, with words containing a certain sentiment.
* Accounts for negation.
* Can suffer from changing ways in which words are used.
* Might not work as well with sarcasm or when in reference to other things (like images).

<!-- page 5 -->

# Slang and Context

* Methods discussed won't really catch slang or context very well.
* Bigrams and n-grams can help this a little bit
  * "supreme court" or "commander in chief"
* Usually, individual units, or tokens, are individual words, but this doesn't have to be the case
  * May also include emojis as individual tokens

<!-- page 6 -->

# Limitations

* Traditional methods are a bit limited ... But they can still be useful!
* Topic modeling won't tell you the exact topics, but they can give you a good idea of what is going in within the whole corpus.
* Just cleaning text and looking at frequent words can also be extremely useful.

<!-- page 7 -->

# More Sophisticated Methods

* Neural networks such as transformers can capture more of the context and meaning within text, and these can provide more sophisticated forms of doing things like sentiment analysis.
* Benefits of model-based approach to sentiment analysis
  * Can be built with current data to better reflect modern sayings
  * More flexible in assigning sentiment
  * Includes more context rather than word by word
* **Note**: this does not require the same preprocessing!

<!-- page 8 -->

# Resources

- For handling text data: https://www.tidytextmining.com
- Hugging Face: https://huggingface.co
