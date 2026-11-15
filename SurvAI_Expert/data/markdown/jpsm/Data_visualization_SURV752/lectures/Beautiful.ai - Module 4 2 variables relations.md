---
id: "jpsm/Data_visualization_SURV752/lectures/Beautiful.ai_-_Module_4_2_variables_relations"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "lecture"
title: "CORRELATION"
original: "Data_visualization_SURV752/lectures/Beautiful.ai - Module 4 2 variables relations.pdf"
pages: 30
sha256: "c62705665b15338b4c7e4f933ef18bbd4ce65f653b80de1104895fff0e5c486b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:51"
---

<!-- page 1 -->

# CORRELATION

<!-- page 2 -->

Housekeeping

**1. Class Recording Permission**

One of our participants is affected by the current shutdown and cannot attend sessions. To support him, I’d like to record today’s class.
If you prefer not to appear in the video, you’re welcome to turn off your camera.

<!-- page 3 -->

# Housekeeping

**2. Your final assignment is out**

Deadline is on the 29th of October.

An additional data source idea, if you know geographical data and like working with it https://places.foursquare.com/

<!-- page 4 -->

* What did you learn from our last lecture?
* Can you think of an example from your own work or research where you used scatterplots to tell a data story?

<!-- page 5 -->

"Personally, I prefer ordinarily to stick within the range extending from a ratio of 1:1.5 to 1:0.5 and lean toward a ratio of 1:1 as ideal".

at the next five figures and determine which seems to work best:

**1 to 2**
FIGURE 10.13 This is an example of a 1-to-2 ratio of bar width to intervening white space.

COMPONENT-LEVEL GRAPH DESIGN 213

**1 to 1.5**
FIGURE 10.14 This is an example of a 1-to-1.5 ratio of bar width to intervening white space.

**1 to 1**
FIGURE 10.15 This is an example of a 1-to-1 ratio of bar width to intervening white space.

**1 to 0.5**
FIGURE 10.16 This is an example of a 1-to-0.5 ratio of bar width to intervening white space.

**1 to 0**
FIGURE 10.17 This is an example of a 1-to-0 ratio of bar width to intervening white space.

FIGURE 10.18 This graph illustrate when it is appropriate to place bar side by side without white space in between.

FIGURE 10.19 This graph shows th it's unnecessary to insert white spa between bars that are associated with the same categorical item alo the axis.

Few, Stephen (2012). **Show Me the Numbers. Designing Tables and Graphs to Enlighten.** (Second Edition). Analytics Press. ISBN-13 : 978-0970601971

<!-- page 6 -->

# HEATMAP SCATTERPLOTS

**Heat maps show men look straight ahead; women scan periphery**

Female responses

Male responses

An eye-catching new BYU study shows just how different the experience of walking home at night is for women versus men.

https://www.liebertpub.com/doi/full/10.1089/vio.2023.0027

<!-- page 7 -->

# CORRELATIONS
# -
# SCATTERPLOTS

What is a scatterplot?

<!-- page 8 -->

# WHAT IS A SCATTERPLOT?

* A scatterplot is a graph that is used to display the relationship between two quantitative variables and is described by the direction, strength, and form of the relationship, and unusual observations.
  * Direction: A positive direction means that the y-variable tends to increase as the x-variable increases (or an upward trend). A negative direction means that the y-variable tends to decrease as the x-variable increases (or a downward trend). Relationships between quantitative variables are said to have no direction when there is no consistent positive or negative pattern in the scatterplot.
  * Strength: Relationships between two quantitative variables run from strong, if the points fall in a “tight” pattern, to weak, if they are spread out.
  * Form: The form of a relationship is determined by the pattern of the points in the scatterplot. The most common forms are linear and curved. If there is no clear pattern in the scatterplot, the form is sometimes referred to as scattered.
  * Unusual observations: Unusual points that do not fit the general pattern in the scatterplot may be outliers.

https://www.nytimes.com/2021/01/21/learning/whats-going-on-in-this-graph-climate-friendly-cars.html

<!-- page 9 -->

### CORRELATIONS - SCATTERPLOTS

* Decrease symbol size
* Remove fill color
* Try different symbols
* Add random noise (jittering)
* Use alpha parameter
* Use subsamples

What can we do to make our scatterplots more readable?

<!-- page 10 -->

# WHAT CAN WE DO TO MAKE OUR SCATTERPLOTS MORE READABLE?

* Create a density plot

```r
smoothScatter(dat$x, dat$y, xlab = "x", ylab = "y",
main = "2) Density shading (smoothScatter)", xlim =
xlim, ylim = ylim)
```

<!-- page 11 -->

# WHAT CAN WE DO TO MAKE OUR SCATTERPLOTS MORE READABLE?

* Colour by a known group

```r
legend("topleft", fill = pal[c("G1","G2","G3","G4")],
border = NA, legend = c("G1","G2","G3","G4"), cex =
0.8, bty = "n")
```

<!-- page 12 -->

# WHAT CAN WE DO TO MAKE OUR SCATTERPLOTS MORE READABLE?

* Colour by a known group

```r
legend("topleft", fill = pal[c("G1","G2","G3","G4")],
border = NA, legend = c("G1","G2","G3","G4"), cex =
0.8, bty = "n")
```

<!-- page 13 -->

# SCATTERPLOTS

- Scatter plots can encode up to five different parameters:
  - X and Y axes
  - Color Size
  - Shape of markers

- Readers may have difficulty perceiving $> 3$ parameters simultaneously

- Scatter plots are less useful when data are very dispersed. It is better when we can see a trend or some grouping

<!-- page 14 -->

# TREND: CORRELATIONS

### Positive correlation
Variable B on y axis
variable A on x axis

### Negative correlation
Variable B on y axis
variable A on x axis

### No correlation
Variable B on y axis
variable A on x axis

### Stronger correlation
Variable B on y axis
variable A on x axis

### Weaker correlation
Variable B on y axis
variable A on x axis

### Non linear correlation
Variable B on y axis
variable A on x axis

https://www.geogebra.org/m/KE6JfuF9

<!-- page 15 -->

# TREND

(based on the data points)

Berggruen Governance Index (Public Health Sub-Index) & HAQ Index (Healthcare Access and Quality Index)

Healthcare Access and Quality Index (0-100)

100

75

50

25

0

China

South Korea

Italy

United Kingdom

United States

0

25

50

75

100

Public Health Sub-Index (0-100)

Source: Berggruen Governance Index, Healthcare Access and Quality Index (HAQ Index)

<!-- page 16 -->

# TREND

(based on the data points)

Countries that introduced lockdown measures after the 10th death

Countries that introduced lockdown measures before the 10th death

Number of days between a lockdown and the 10th death

Analytical Capacity Sub-Index (0-100)

Source: Berggruen Governance Index; ACAPS #COVID19 Government Measures Dataset

How would you improve this chart?

<!-- page 17 -->

# TREND

based on the axis "equality"

Prozent der Unternehmen, die in der jeweiligen Branche angeben, regelmäßig oder in Einzelfällen mit INGOs zusammenzuarbeiten

* Nur regelmäßig
* 35
* 30
* 25
* 20
* 15
* 10
* 5
* Nur in Einzelfällen
* 5
* 10
* 15
* 20
* Nahrungsmittel-industrie
* Chemie/Pharma
* Gastgewerbe/Einzelhandel
* Finanzen/Versicherung
* Verkehr/Logistik/Transport
* Kunst/Unterhaltung/Erholung
* Maschinenbau
* Land-/Forstwirtschaft
* Bergbau/Metall
* Bauwirtschaft
* % Nur regelmäßig = % Nur in Einzelfällen
* Grundstücks-/Wohnungswesen
* Handel
* Gesundheit/Sozialwesen
* Information/Kommunikation
* Dienstleistungsbranche
* Elektrotechnik
* Energie/Wasser
* Andere Branchen des verarbeitenden Gewerbes
* Fahrzeugbau/Zulieferer

<!-- page 18 -->

# TREND

based on the axis "equality"

earned by a man doing the same job. Economists cite a few reasons: discrimination as well as personal choices within occupations are two major factors, and part of the gap can be attributed to men having more years of experience and logging more hours.

https://archive.nytimes.com/www.nytimes.com/interactive/2009/03/01/business/20090301_WageGap.html?_r=0

<!-- page 19 -->

# GROUPS

Share full article 249

**Average carbon dioxide emissions per mile**

800 grams

Toyota Sequoia

Lexus GX

600

Diesel cars

Traditional gas-powered cars

400

Honda Civic

Hybrid and plug-in hybrid vehicles

Fuel cell

200

Nissan Leaf

Electric cars

0
\$250 \$300 \$350 \$400 \$450 \$500 \$550 \$600 \$650 \$700 \$750 \$800 \$850

**Average cost per month**
Purchase price, maintenance, fuel

<!-- page 20 -->

# WHAT WOULD YOU CHANGE HERE?

**Brazil’s golden oldie blowout**
Latest available

*Government spending on pension benefits, % of GDP*
* 20
* 15
* 10
* 5
* 0

*Population aged 65 years and over, as % of total*
* 0, 5, 10, 15, 20, 25, 30

Labels:
* **Brazil**
* France
* Italy
* Greece
* Poland
* Japan
* United States
* Turkey
* *OECD average*
* China
* Mexico
* South Korea

Sources: OECD; World Bank; Previdência Social

---

**Brazil's golden oldie blowout**
Latest available

Government spending on pension benefits % of GDP
* 20
* 15
* 10
* 5
* 0

Population aged 65 years and over, % of total
* 0, 5, 10, 15, 20, 25, 30

Labels:
* **Brazil**
* France
* Italy
* Greece
* Poland
* Japan
* Turkey
* *OECD average*
* United States
* Mexico
* South Korea

Sources: OECD; World Bank; Previdência Social

<!-- page 21 -->

"In 2016, David Voas and Mark Chaves published an article in the American Journal of Sociology about how rates of religious commitment in the United States are slowly declining. In 2017, Landon Schnabel and Sean Bock published an article in Sociological Science responding to this conclusion, arguing that most of the religious decline was among moderate religious respondents—people with very strong religious commitments seemed to be holding steady. Just recently, both teams of authors have published additional comments about this debate (here and here), analyzing the same data from the General Social Survey.

Figure 1: Intense religiosity by survey year (items used by Schnabel and Bock). Source: General Social Survey

Figure 1: Intense religion by survey year with locally weighted regression lines, General Social Survey

<!-- page 22 -->

## LOESS - WHAT IS IT?
## WHY DO WE NEED IT?
## WHAT IS A "SPAN" PARAMETER?

* The default $\text{span} \approx 0.75$ is a good starting point.
* Larger datasets can support smaller spans (since there's enough data locally for stable estimates).
* Noisy data requires larger spans to smooth over fluctuations.
* The **research purpose** matters: exploratory plots can use smaller spans for flexibility, while confirmatory analysis benefits from smoother, more stable trends.

<!-- page 23 -->

# RUGS

<!-- page 24 -->

Briana: It was mentioned that you can also use box plots similarly but it may be less desirable since there is less of the data encoded. Is there a situation where box plots might be preferable to rugs despite this?

<!-- page 25 -->

Max: To me, they seem like a really helpful tool for data comprehension and analysis, but I wonder **how helpful they would be for communicating this data to someone else...**
 Basically, is it reasonable to assume that a **layperson could intuit the meaning of this rug visual** on their own, or would the presence of such data just add visual noise and possibly confuse the viewer?

I could not find any Financial Times or NYT or Economist dataviz that used rugs :(

<!-- page 26 -->

## State of the Union address decreasing reading level $\rightarrow$

### BUBBLES

Annotations are good

Bubble size: radius scales linearly, but the area scales quadratically

Source: The 2011 State of the Union Address

<!-- page 27 -->

# SCATTERPLOTS

**Medalists in the Summer Games** come from countries with relatively hotter summers and **medalists in the Winter Games** come from countries with relatively colder winters.

**Hottest month's temperature**

$35^\circ\text{C}$

$30$

$25$

$20$

$15$

$10$

$\uparrow$ Hotter summers

**Australia** is the warmest country to have won a winter medal

Iran

India

Cuba

Japan

U.S.

South Africa

China

Russia

France

**Brazil** has produced 334 summer medalists but never yet a winter one

Finland

Germany

U.K.

Canada

Norway

**Austria** is the only country with more winter than summer medalists

$\leftarrow$ Colder winters

**Coldest month's temperature**

$-25 \quad -20 \quad -15 \quad -10 \quad -5 \quad 0 \quad 5 \quad 10 \quad 15 \quad 20 \quad 25^\circ\text{C}$

No country warmer than Australia has ever produced a winter medalist at all — including powerhouses like Brazil with 334 medalists in the summer events.

https://www.datawrapper.de/blog/summer-winter-olympics-temperature

<!-- page 28 -->

# WHAT IF YOU HAVE MORE THAN 2 VARIABLES

## The tweets of some high-profile senators
Each senator's 3,200 most recent tweets, excluding tweets with fewer than 10 replies, likes or retweets, through Oct. 19, 2017

**@BillCassidy**
Retweets
Replies Likes

**@LindseyGrahamSC**

**@RandPaul**

**@SenFranken**

**@SenGillibrand**

**@SenKamalaHarris**

**@SenSanders**

**@SenTedCruz**

**@SenWarren**

<!-- page 29 -->

# ONE MORE INTERESTING CHART UPSET PLOT

## TRACKING SYMPTOMS

On 7 April, around 60% of app users who tested positive for COVID-19 and reported symptoms had lost their sense of smell.

- Anosmia (loss of smell)
- Cough
- Fatigue
- Diarrhoea
- Shortness of breath
- Fever

Number of people reporting each combination of symptoms

140, 57, 179, 259, 69, 28, 11, 54, 10, 22, 26, 17, 11, 1, 5, 18, 23, 8, 7, 7, 43, 64, 41, 50, 17, 31, 12, 17, 12, 46, 198, 281

PHOTO GRAPH: PIER MARCO; DATA SOURCE: COVID SYMPTOM TRACKER TEAM

<!-- page 30 -->

# ONE MORE INTERESTING CHART UPSET PLOT

## Co-Occurence of COVID-19 Symptoms

Symptom Groupings by Frequency. Total pool is 1,764 individuals.

Data: covid.joinzoe.com/us | Graph: @kjhealy
