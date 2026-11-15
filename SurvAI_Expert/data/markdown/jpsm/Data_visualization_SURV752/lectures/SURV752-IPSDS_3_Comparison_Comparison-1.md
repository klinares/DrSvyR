---
id: "jpsm/Data_visualization_SURV752/lectures/SURV752-IPSDS_3_Comparison_Comparison-1"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "lecture"
title: "Comparison, Comparison, Comparison"
original: "Data_visualization_SURV752/lectures/SURV752-IPSDS_3_Comparison_Comparison-1.pdf"
pages: 14
sha256: "006637a3fc96a13b5e2a77af6579fb85a26cc40c88bee8f716757b6c771c8434"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:54"
---

<!-- page 1 -->

# Comparison, Comparison, Comparison

<!-- page 2 -->

# Comparison, Comparison, Comparison

“The fundamental analytical act in statistical reasoning is to answer the question ´compared to what?´

Whether we are evaluating changes over space or time, searching big data bases, adjusting and controlling for variables, designing experiments, specifying multiple regressions, or doing just about any kind of evidence-based reasoning, the essential point is to make intelligent and appropriate comparisons.

Thus visual displays, if they are to assist thinking, should show comparisons.”
(Tufte 2006: 127)

<!-- page 3 -->

# Some Visual Comparisons

Comparing before and after

Comparing to a standard

Comparing to context

Comparing by subgroups

Comparing to an implicit model (“what do we expect to see?”)

<!-- page 4 -->

# Some Graphical Principles for Comparisons

Should the comparison be made within a single graph or across multiple graphs?

If multiple graphs, make sure to use:

- Common graph size

- Common scales

- Helpful alignment

Colour and shape can be used to compare groups within and across graphs.

<!-- page 5 -->

# Comparing before and after: Slope Graph

What's the probability two random persons belong to a different religion?

| 1910 | 2010 |
| :--- | :--- |
| Asia: 80% | Asia: 88% |
| Africa: 58% | Africa: 62% |
| Eastern Europe: 20% | Western Europe: 51% |
| Latin America: 10% | Northern Europe: 43% |
| Northern America: 7% | Northern America: 38% |
| Southern Europe: 6% | Southern Europe: 33% |
| Northern Europe: 4% | Eastern Europe: 30% |
| Western Europe: 3% | Latin America: 15% |

<!-- page 6 -->

# Comparing to a Standard: Bullet Graph

Bullet graphs compare a quantitative measure to

a) one or more related measures (e.g., a target or the same measure in the past) and

b) relate the measure to defined ranges that declare its qualitative state (e.g. good, satisfactory, and poor).

Background fill colors that encode qualitative ranges like bad, satisfactory, and good

**Revenue 2005 YTD**
(U.S. \$ in thousands)

0 50 100 150 200 250 300

Quantitative Scale

Text Label

Symbol marker that encodes the comparative measure

Bar that encodes the performance measure

<!-- page 7 -->

# Comparing to a Standard: Bullet Graph

## 2005 YTD

**Revenue**
U.S. $ (1,000s)
0 50 100 150 200 250 300

**Profit**
%
0% 5% 10% 15% 20% 25% 30%

**Avg Order Size**
U.S. $
0 100 200 300 400 500 600

**New Customers**
Count
0 500 1,000 1,500 2,000 2,500

**Cust Satisfaction**
Top Rating of 5
0 1 2 3 4 5

<!-- page 8 -->

# Comparing before and after/to context/to a standard: Spark Lines

glucose 6.6

glucose 6.6

glucose 6.6

glucose 6.6 or glucose 6.6

glucose 6.6

respiration 12

temperature 37.1°C

<!-- page 9 -->

# Comparing before and after/to context/to a standard: Spark Lines

| | | 2003.4.28 | 12 months | 2004.4.28 | low | high |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Euro foreign exchange | \$ | 1.1025 | | 1.1907 | 1.0783 | 1.2858 |

| | | 1999.1.1 | 65 months | 2004.4.28 | low | high | | 2003.4.28 | 12 months | 2004.4.28 | low | high |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Euro foreign exchange | \$ | 1.1608 | | 1.1907 | .8252 | 1.2858 | \$ | 1.1025 | | 1.1907 | 1.0783 | 1.2858 |
| Euro foreign exchange | ¥ | 121.32 | | 130.17 | 89.30 | 140.31 | ¥ | 132.54 | | 130.17 | 124.80 | 140.31 |
| Euro foreign exchange | £ | 0.7111 | | 0.6665 | .5711 | 0.7235 | £ | 0.6914 | | 0.6665 | 0.6556 | 0.7235 |

5+ years

1 year

<!-- page 10 -->

# Comparing by Subgroups: Small Multiples

"High-density graphics help us to compare parts of the data by displaying much information within the view of the eye: we look at one page at a time and the more on the page, the more effective and comparative our eye can be." (Tufte 2001: 168).

Data Density = number of entries in data matrix/area of data graphic

Maximize data density and the size of the data matrix, within reason.

Graphics can be shrunk way down.

This yields one of the most powerful visualization formats: The Small Multiple.

<!-- page 11 -->

### The average amount of liquor consumed by a person of drinking age

*Shots per week of any spirit*

| S. Korea | Russia | Philippines | Thailand | Japan | Bulgaria | Ukraine | Slovakia | Brazil |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 10<br>5<br>13.7 | 6.3 | 5.4 | 4.5 | 4.4 | 3.9 | 3.9 | 3.8 | 3.6 |
| **USA** | **Czech Rep.** | **Germany** | **Finland** | **Venezuela** | **France** | **Spain** | **Ireland** | **Canada** |
| 5<br>3.3 | 3.0 | 3.0 | 2.9 | 2.8 | 2.7 | 2.7 | 2.6 | 2.5 |
| **Chile** | **UK** | **Netherlands** | **Austria** | **Belgium** | **S. Africa** | **Greece** | **Norway** | **China** |
| 5<br>2.3 | 2.3 | 1.9 | 1.8 | 1.8 | 1.8 | 1.6 | 1.6 | 1.5 |
| **Colombia** | **Switzerland** | **Mexico** | **Taiwan** | **Sweden** | **India** | **Italy** | **UAE** | **Israel** |
| 5<br>1.4 | 1.4 | 1.4 | 1.3 | 1.3 | 1.2 | 1.2 | 1.2 | 1.1 |
| **Portugal** | **Argentina** | **Turkey** | **Peru** | **Malaysia** | **Vietnam** | **Morocco** | **Egypt** | **Indonesia** |
| 5<br>1.0<br>'00 '05 '10 | 1.0<br>'00 '05 '10 | 0.6<br>'00 '05 '10 | 0.4<br>'00 '05 '10 | 0.3<br>'00 '05 '10 | 0.2<br>'00 '05 '10 | 0.1<br>'00 '05 '10 | 0.0<br>'00 '05 '10 | 0.0<br>'00 '05 '10 |

Quartz | Ritchie King

Data: Euromonitor

<!-- page 12 -->

The United States' once-strong lead in middle class incomes is shrinking.

MEDIAN PER CAPITA INCOME AFTER TAXES

Source: New York Times/Luxembourg Income Study analysis

<!-- page 13 -->

2000: State-level support (orange) or opposition (green) on school vouchers, relative to the national average of 45% support

| | Income under \$20,000 | \$20-40,000 | \$40-75,000 | \$75-150,000 | Over \$150,000 |
| --- | --- | --- | --- | --- | --- |
| All voters | | | | | |
| White Catholics | | | | | |
| White evangelicals | | | | | |
| White non-evang. Protestants | | | | | |
| White other/ no religion | | | | | |
| Blacks | | | | | |
| Hispanics | | | | | |
| Other races | | | | | |

Orange and green colors correspond to states where support for vouchers was greater or less than the national average.
The seven ethnic/religious cagetories are mutually exclusive. "Evangelicals" includes Mormons as well as born-again Protestants.
Where a category represents less than 1% of the voters of a state, the state is left blank.

<!-- page 14 -->

14
