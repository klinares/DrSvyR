---
id: "jpsm/Data_visualization_SURV752/lectures/Comparisons"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "lecture"
title: "Comparisons"
original: "Data_visualization_SURV752/lectures/Comparisons.pdf"
pages: 23
sha256: "a3b4eb91e021279cf9a44fe03ae744f11e0c82a01a46ae3148289a4cbf8bc50c"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:28:54"
---

<!-- page 1 -->

# Comparisons

<!-- page 2 -->

Housekeeping

### 1. Class Recording Permission

One of our participants is affected by the current shutdown and cannot attend sessions. To support him, I'd like to record today's class.
If you prefer not to appear in the video, you're welcome to turn off your camera.

<!-- page 3 -->

Housekeeping

**2. Speaking During Class**

Just like last time, since there are many of us and slides take up my screen space, I might not see everyone.
If you'd like to contribute or ask a question, please feel free to unmute yourself and start speaking.

<!-- page 4 -->

# How People Process Information from Charts and Tables

https://filwd.substack.com/p/titles-in-data-visualization-empirical

<!-- page 5 -->

# How People Process Information from Charts and Tables

**Headlines capture attention.**
They perfectly illustrate the “layered cake” scanning pattern: people fixate on titles first when viewing information.

**People remember visualizations by their titles.**
That’s one more reason not to label a chart with something generic like “Chart” or “Figure 1.”

**Key insights are recalled through the title.**
If the headline conveys the main idea of the visualization, people remember it easily; if it’s too vague, the idea fades.

**People rarely notice bias in titles.**
Even when a headline contradicts the visualization, most viewers don't notice the inconsistency

<!-- page 6 -->

* Why does Tufte call “**compared to what?**” the fundamental analytical act?

* Can you think of an example from your own work or research where forgetting to ask “compared to what?” led to misleading conclusions? or just suboptimal conclusions?

<!-- page 7 -->

## Think about the pie charts you see: do they help tell the story of the data, or not really?

### LABOUR FORCE PARTICIPATION RATES OF WOMEN AND MEN (AGED 25 TO 54), BY REGION AND HOUSEHOLD TYPE (PERCENTAGE)

| Region | Overall labour force participation rate, by sex | Lone-person household | Couple-only household | Couple household with child under 6 | Extended-family household with child under 6 |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Global** | 94.0 (Male)<br>51.6 (Female) | 90.0<br>82.4 | 94.2<br>64.3 | 97.2<br>46.7 | 93.3<br>41.1 |
| **Central and Southern Asia** | 96.8<br>29.4 | 91.6<br>67.0 | 96.5<br>34.2 | 98.8<br>24.3 | 95.7<br>23.8 |
| **Latin America and the Caribbean** | 94.1<br>64.5 | 92.6<br>84.4 | 94.2<br>68.6 | 97.1<br>53.5 | 92.9<br>60.4 |
| **Europe and Northern America** | 92.1<br>77.5 | 87.3<br>85.0 | 92.4<br>82.8 | 96.0<br>67.9 | 89.0<br>65.2 |
| **Oceania, excluding Australia and New Zealand** | 58.7<br>54.9 | 66.6<br>51.2 | 66.2<br>56.1 | 57.5<br>52.3 | 56.3<br>55.0 |
| **South-Eastern Asia** | 94.5<br>72.0 | 94.1<br>89.3 | 97.0<br>79.7 | 97.0<br>58.6 | 93.1<br>69.0 |
| **Sub-Saharan Africa** | 92.1<br>77.1 | 93.9<br>91.8 | 95.2<br>77.0 | 96.1<br>79.4 | 84.6<br>72.7 |
| **Northern Africa and Western Asia** | 92.5<br>29.2 | 88.2<br>48.2 | 90.4<br>35.5 | 97.0<br>24.8 | 91.1<br>26.7 |

Source: ILO and UN Women calculations from ILOSTAT database.
Note: Oceania excludes Australia and New Zealand. For the SDG region of Eastern and South-Eastern Asia, data are shown only for the subregion of South-Eastern Asia due to insufficient country coverage.

* Male
* Female

<!-- page 8 -->

**Figure 9:** Breakdown of granular conversation topic shares within the coarse mapping defined in Table 3. The underlying classifier prompt is available in Appendix A. Each bin reports a percentage of the total population. Shares are calculated from a sample of approximately 1.1 million sampled conversations from May 15, 2024 through June 26, 2025. Observations are reweighted to reflect total message volumes on a given day. Sampling details available in Section 3.

Comparing to what?

*[Figure: The figure is a stacked bar chart (specifically a Marimekko chart where column widths reflect category shares) showing the percentage breakdown of granular conversation topics within seven broad categories along the horizontal axis: Multimedia, Other/Unknown, Practical Guidance, Seeking Information, Self-Expression, Technical Help, and Writing. The main pattern reveals that "Practical Guidance" (28.3%), "Writing" (28.1%), and "Seeking Information" (21.3%) dominate total conversation volume, with "Specific Info" (18.3%), "Edit Or Critique Provided Text" (10.6%), and "Tutoring Or Teaching" (10.2%) representing the largest individual subtopics.]*

<!-- page 9 -->

Outcome (higher is better)
105
104
103
102
101
100
99
2 SEs
Control
Treatment
Standard error (SE) bars show uncertainty in estimating the mean

Outcome (higher is better)
130
120
110
100
90
80
70
2 SDs
Control
Treatment
Standard deviation (SD) bars show variation in outcomes around the mean

How Visualizing Inferential Uncertainty Can Mislead Readers About Treatment Effects in Scientific Results

<!-- page 10 -->

Raw gender pay gaps using hourly wages

**MEAN GENDER PAY GAP**

**MEDIAN GENDER PAY GAP**

Source: ILO, WHO estimates based on survey data provided by national sources (see Annex 1).

Figure 2: Raw gender pay gaps using hourly wages

This graph shows both mean and median gender pay gap for health industry vs other industries

*[Figure: The figure consists of two four-panel bar and dot charts displaying the mean (top four panels) and median (bottom four panels) raw gender pay gap percentages using hourly wages across four geographic regions: Africa and Eastern Mediterranean, Americas, Europe, and South-East Asia and Western Pacific. In each panel, the y-axis shows the gender pay gap (%) and the x-axis lists countries grouped by income level, comparing the health sector (blue and purple bars) against other sectors (red dots), revealing that the gender pay gap is positive in almost all countries and is frequently wider in the health sector than in other sectors.]*

<!-- page 11 -->

- What chart type can we use to compare before and after
- Have you ever used it, and if yes for what?

<!-- page 12 -->

# Slopes

## Basics of a slope

Slope charts are made up of **axes and lines** which represent the different **series**. The **thickness** of the lines can be linked to **values**. The **direction** of the line and the **steepness** of the slope convey the main meaning.

* **Axis** (2010, 2015)
* **Start point**
* **End point**
* **Steepness**

## What are slopes good for?

* Identifying and **showing change or variance** in a simplified manner
* Quickly **spotting general trends**
* **Comparing** the data between two years

## Three modes

### Scores
Show absolute values

### Ranks
Organize your series

### Percent change
Compare your series' change

## Slope vs. Line charts

These are sister charts, but have different use cases.

* **Slope chart**
* **Line chart**

### Similarities

* Both can represent time series.
* Every line is a series.
* Time is on X axis and values on Y axis.

### Differences

* Slopes work better with less series than line charts.
* Slopes can show percentage change and ranks.
* Slopes don't need a zero base.

<!-- page 13 -->

* What chart type can we use to compare to a standard (explicit or implicit)

* Should we make out implicit standard explicit?

<!-- page 14 -->

* Sparklines: who wants to explain?

**28 day summary** with change over previous period

| Tweets | Tweet impressions | Profile visits | Mentions | Followers |
| :--- | :--- | :--- | :--- | :--- |
| **66** $\downarrow 21.4\%$ | **1.4M** $\uparrow 5.1\%$ | **21.9K** $\downarrow 9.1\%$ | **447** $\downarrow 9.3\%$ | **56.8K** $\uparrow 1,143$ |

**October 2015** • 3 days so far...

<!-- page 15 -->

# When you should use a sparkline

Like the line chart, a sparkline is great for showing how values change over time. The sparkline can serve as a useful alternative to the line chart when multiple lines need to be plotted.

On one extreme, the sparkline is a good choice when there is a lot of overlap between lines that cause them to be difficult to distinguish from one another.

At the other extreme, sparklines are a good choice when there is no overlap between lines due to them covering broadly different ranges. This often pops up when you have multiple metrics that you want to track at the same time. Plotting all of the lines on a

https://chartio.com/blog/new-chart-type-sparklines/

<!-- page 16 -->

* Small multiples

# EU election overview

Change in vote share of main parties in EU elections

2019 2024
EPP (Christian conservative)
S&D (Democratic socialist)
Others
Renew (Liberals)
ECR (Anti-federalist)
ID (Nationalist)
Greens
The Left

**Finland** saw growth in both conservative and left-wing parties

**Hungary** – the ruling Fidesz party left the EPP group in 2021, joining the unaligned bloc

Source: European Union (2024)

<!-- page 17 -->

# How much is too much?

## Confidence Around the World

developments of households' consumption and saving. An indicator above 100 signals a boost in the consumers' confidence towards the future economic situation. Values below 100 indicate a pessimistic attitude towards future developments in the economy, possibly resulting in a tendency to save more and consume less. During 2022, the consumer confidence indicators have declined in many major economies around the world.

**USA**
100
97

**China**
92

**Japan**
97

**Germany**
100
96

**UK**
92

**France**
96

**Italy**
100
97
19 20 21 22

**South Korea**
98
19 20 21 22

**Australia**
98
19 20 21 22

---

**YORK** | **The New York Times** | **PLAY THE**

* **Ever tried vaping**
* **Ever tried cigarettes**
  1999 2009 2019

* **Recently drank alcohol**
* **Ever used marijuana**
* **Ever used cocaine**

* **Ever had sex**
* **Last sex was unprotected**

* **Watch television at least 3 hours a day**
* **Get at least 8 hours of sleep**

* **Use a smartphone, tablet, computer or game console at least 3 hours a day, not including school work**
  MALE
  FEMALE
  '89 '99 '09 '19

* **Persistently felt sad or hopeless**
  FEMALE
  MALE
  1999 2009 2019

* **Seriously considered suicide**
  FEMALE
  MALE

* **Made a suicide plan**
  FEMALE
  MALE

* **Attempted suicide**
  FEMALE
  MALE

* **Injured in a suicide attempt and needed medical treatment**
  MALE FEMALE
  '89 '99 '09 '19

ters for Disease Control and Prevention High School Youth Risk Behavior Survey

<!-- page 18 -->

# How much is too much?

Adjusted US Unemployment Rate 2000-2016

Year

<!-- page 19 -->

# How much is too much?

<!-- page 20 -->

# Some ideas regarding when to use small multiples

* when the number of groups is large ($>5$) for which traditional visualizations like bar charts and line charts may look messy and the storytelling is ineffective.

* Use small multiple line charts to untangle overlapping lines

* Normal line charts are better if you want readers to compare lines with each other at specific points in time

* You can make individual cells very small, our eye can spot trends

<!-- page 21 -->

# Different scales?

GOOD

ALSO GOOD

https://www.datawrapper.de/blog/what-to-consider-when-creating-small-multiple-line-charts

<!-- page 22 -->

# How to sort

* Alphabetically
  (Often used as the default sorting method, useful when users know what they're looking for, does **not** help reveal patterns or insights)
  You can always default to it when there is no obvious logic in your data

* Numerical Value
  (select 1 value, the first one, the last one, overall change of positions etc)

* Aggregated Value
  (Can sort by average, maximum, or minimum values)

* Pattern/Structure
  (could be geographical, could be pattern in the data etc)

<!-- page 23 -->

# Finding patterns

similar high levels of Quality of Democracy, Quality of Government and Quality of Life

Australia, Canada, Germany, Netherlands, Norway

similar low levels of Quality of Democracy, Quality of Government and Quality of Life

Argentina, Egypt, Georgia, Nigeria, Philippines

Quality of Life is better than Quality of Democracy and Quality of Government

China, Kazakhstan, Russian Federation

Quality of Life is less than Quality of Democracy and Quality of Government

Brazil, Colombia, India, Italy

Quality of Government and Quality of Life is better than Quality of Democracy

Japan, Korea
