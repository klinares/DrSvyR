---
id: "jpsm/fund_comp_data_display_SURV727/lecture_notes"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "lecture_notes"
original: "fund_comp_data_display_SURV727/lecture_notes.pdf"
pages: 3
sha256: "3c1b4dd2d0244ab12df559ea2e8d17e5b3bdf3dd9b22d31a7520e05a4eed29cd"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:54"
---

<!-- page 1 -->

SURV_727_notes

Class 7 Text mining

Reading

TMR ch 6 https://www.tidytextmining.com/topicmodeling

topic modeling
* Method for unsupervised classification.
  * LDA method: treats documents as a mixture of documents. Allows docs to overlap with each other, rather than separate out.
    * Think of it as the document is being assigned into a probable topic (class).
    * Every topic (class) is a mixture of words (items).
    * The number of latent topics (class) gets pre-assigned.
    * To examine difference magnitudes in the conditional probs, take the log ratio of the two classes as $\log_2(\text{beta\_2}/\text{beta\_1})$ were beta is the probs of a word being in a topic.
    * Per-doc-per-topic probs are called gammas, think of it as the class assignment probs, or thetas.
    * Text gets assigned to a topic, the probability that a word was generated from a topic.
    * Document (individual) gets classified into a topic (class).
    * LDA in the mallet package tokenizes words on its own.
* Tidy() from the broom package tidies up model fit objects.
* slice_max(var, n=n) brings back the n highest scores.
* In ggplot, scale_y_reordered() https://juliasilge.github.io/tidytext/reference/reorder_within.html

Big Data and Social Science ch 8
https://textbook.coleridgeinitiative.org/https://textbook.coleridgeinitiative.org/

text analysis
* What can we do with text data:
  * search, find relevant content.
  * Topic detection, types of phrases and words
  * classification, classify text into one or more predefined categories
  * sentiment analysis, detection of opinions on a topic
  * word clustering, groups of similar words
  * named entity, tagging of people, locations from text
  * general extraction, filtering on tags and extracting specific text
  * visualization, text data such as networks
  * summarization, common phrases words
  * translation, automated
* A pipeline for clustering and classifying of text
  * Initial processing: clean text by removing redundant or dirty html or metedata, or removing stopwords.
    * Helpful to also remove words that occur very infrequently, such as names or misspellings.
    * Caution, some stopwords “of” are needed for phrases such as “system ‘of’ a down” and are called n-grams requiring statistical patterns of discovery, they are called collocations.

<!-- page 2 -->

* Text normalization, example a system also has pluralities such as systems or systematically and are similar. A lemma, such as go, went, and goes, all have the lemma “go,” so the stem is a central part of each word.
* Adding linguistic features: augment raw words with speech tags, or use parse trees to do this.
    * Part of speech tagging as an example where we have words on one column, and grammatical function on another column, we can discover patterns to distinguish things like “I ‘hit’ the car” versus “my website got 20 ‘hits’.”
        * two methods, hidden markov chain, conditional random fields.
    * Stopwords should not be conducted until performing n-gram indexing. A stemmer should not be used where data is complex.
* Converting the enriched text to a matrix: Split text into sentences, words, organize in a structured way consistent with the method applied. Define rows and columns.
    * Weighting words, how often they show up in documents, frequency-inverse document frequency (TFIDF) is a weighting scheme to balance words by prioritizing meaningful words taking into account frequency of word, and document frequency.
* Analysis: apply the method.
    * Finding similarities in papers/documents
        * common metrics, cosine similarity and Kullback-Leibler divergence.
        * Topic modeling, describes topics as themes in a text corpus. Topics or concepts are distributions over words.

**Pre-Processing** $\rightarrow$ Clean Text $\rightarrow$ Tokenize $\rightarrow$ Stemming $\rightarrow$ Remove Stopwords $\rightarrow$ Remove rare words

$\downarrow$

**Add Linguistic Features (Optional)** $\rightarrow$ Part of Speech Tags $\rightarrow$ Chunking $\rightarrow$ Parsing

$\downarrow$

**Convert to a Matrix** $\rightarrow$ Determine row $\rightarrow$ Determine Column(s) $\rightarrow$ Determine what value goes in a cell

$\downarrow$

**Analysis** $\rightarrow$ Clustering $\rightarrow$ Classification

Modern Data Science with R Ch 19 [https://mdsr-book.github.io/mdsr2e/](https://mdsr-book.github.io/mdsr2e/)

Text as data
* `str_subset()` using “.” a metacharacter such as `str_subset(“mac.”)` or `str_subset(“mac\\.”)` brings back “machine”, macbeth”, “macho,” or “macro.”
* anchors at beginning of string, `str_subset”^ macro.”)` or end use `$`
* `get_stopwords` from stopwords package.

<!-- page 3 -->

Class notes 10/9/24

* Topic modeling:
  * cluster documents into topic typologies using shared text.
  * Limitation: topics are theoretical.
* Sentiment Analysis:
  * does not work well with sarcasm or emojis.
  * Context is important, diagrams or biograms.
* Neural networks
  * transformers can capture more context than sentiment analysis.

Class notes 10/23/24 – Databases

* Why SQL database, big data can be large, the bottleneck in r is reading data in memory.
  * SQL organizes and stores data into relational tables called database normalization.
  * Transactions, calls do not break the database.
  * Limitations
    * large datasets can be slow to query
      * can speed by by indexing, sorting values before hand.
  * DbWriteTable writes sql table.
    * Developer has to store data efficiently. Reduce repeated information.
* Sqlite
  * saves data in .db file.

**October 30, 2024 ggplot2 visualization**

* two goals of building visuals, for exploratory and for a customer.
* Strike balance between visually interesting and useful.
* For polar coordinates, bar chart for alternatives, sometimes it is okay to use if the focus on on comparison between individual and group.

November 06, 2024
* Assignment 5 – due in 3 weeks.

**November 13 2024 PCA clustering**
* Do not go over presentation time.
* Format of final paper, just keep it consistent.
* Unsupervised learning are more exploratory techniques, no test or significance.
* Sentiment, those are being classified into known classes.

**November 20 2024 Big data processing**
*
