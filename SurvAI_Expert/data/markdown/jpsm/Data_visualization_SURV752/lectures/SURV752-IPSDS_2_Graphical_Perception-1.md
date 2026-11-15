---
id: "jpsm/Data_visualization_SURV752/lectures/SURV752-IPSDS_2_Graphical_Perception-1"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "lecture"
title: "Graphical Perception"
original: "Data_visualization_SURV752/lectures/SURV752-IPSDS_2_Graphical_Perception-1.pdf"
pages: 37
sha256: "f30d3e3a5b4d1ab7eff1dd5c2c3ba0db8047077a6c8c070d599f10159b547fae"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:52"
---

<!-- page 1 -->

# Graphical Perception

1

<!-- page 2 -->

# Graphical Perception

“If we can understand how perception works, our knowledge can be translated into rules for displaying information.

Following perception-based rules, we can present our data in such a way that the important and informative patterns stand out.

If we disobey the rules, our data will be incrompehensible or misleading.”

(C. Ware 2004: xxi)

2

<!-- page 3 -->

# How Perception Works

Light passes through the pupil and hits the retina – a thin surface coated with millions of nerves called rods and cones.

Rods and cones translate what they detect into neural signals and pass them on to the brain.

We don't see things with our eyes – we see them with our brains!

3

<!-- page 4 -->

# How Perception Works

Iconic Memory (Visual Sensory Register): Pre-attentive processing (unconscious and automatic) of visual attributes (colors, shapes, etc.)

Short Term or Working Memory: Attentive processing of “chunks” of information

Long Term Memory: Storing and recognizing familiar patterns

4

<!-- page 5 -->

# Attributes of Pre-attentive Processing

756395068473

658663037576

860372658602

846589107830

How many 3s are there?

5

<!-- page 6 -->

# Attributes of Pre-attentive Processing

756395068473

658663037576

860372658602

846589107830

How many 3s are there?

6

<!-- page 7 -->

# Attributes of Pre-attentive Processing

## Form
* Length
* Width
* Orientation
* Size
* Shape
* Curvature
* Enclosure
* Blur

## Color
* Hue
* Intensity

## Position
* 2-D position
* Spatial Grouping

## Motion
* Direction of Motion

7

<!-- page 8 -->

# Attributes of Pre-attentive Processing

We can use attributes of pre-attentive processing to

1. Choose visual encodings of abstract data (choice of graphical formats)

2. Direct audience attention (design choice)

3. Create a visual hierarchy (design choice)

8

<!-- page 9 -->

# Attributes of Pre-attentive Processing

9

<!-- page 10 -->

# Attributes of Pre-attentive Processing

Pre-attentive attributes become less distinct as the variety of distractors increases.

10

<!-- page 11 -->

# Attributes of Pre-attentive Processing

How much bigger is the second circle?

11

<!-- page 12 -->

# Attributes of Pre-attentive Processing

Bring the colors in an order from small to large!

12

<!-- page 13 -->

# Attributes of Pre-attentive Processing

Visual attributes are not all created equal...

| *Attribute* | *Quantitatively Perceived?* |
| :---: | :---: |
| 2-D Position | Yes |
| Length | Yes |
| Width | Limited |
| Size | Limited |
| Color Intensity | Limited |
| Orientation | No |
| Shape | No |
| Enclosure | No |
| Color Hue | No |

13

<!-- page 14 -->

### Cleveland & McGill's Results

T1
T2
T3
T4
T5

1.0 1.5 2.0 2.5 3.0
Log Error

### Crowdsourced Results

T1
T2
T3
T4
T5
T6
T7
T8
T9

1.0 1.5 2.0 2.5 3.0
Log Error

Figure 4: Proportional judgment results (Exp. 1A & B). Top: Cleveland & McGill's [7] lab study. Bottom: MTurk studies. Error bars indicate 95% confidence intervals.

(Heer & Bostock 2010)

14

<!-- page 15 -->

# Now you know why...

Dot Chart/Scatter Plot: 2-D position of visual objects

Line Chart: 2-D position, connected to give shape to a series of values

Bar Chart: Length and 2-D position

15

<!-- page 16 -->

# Trade-Offs and Comparative Advantages

## Bar Chart

## Dot Plot

Source: Junkcharts.

16

<!-- page 17 -->

# Trade-Offs and Comparative Advantages

Combined
Baseline
Search

**Start at 0**

1.0
0.8
0.6
0.4
0.2
0.0
flu music games movies

**Start at 0.4**

1
0.8
0.6
0.4
flu music games movies

17

<!-- page 18 -->

# Trade-Offs and Comparative Advantages

## Bar Chart

## Line Chart

18

<!-- page 19 -->

# Trade-Offs and Comparative Advantages

19

<!-- page 20 -->

# Gestalt Principles of Visual Perception

Visualization works because it abstracts from single data points and leverages the human brain's ability to form these data points into emergent patterns.

This ability has been studied by the Gestalt School of Psychology in the early 1900s.

Understanding this ability allows us to use it strategically in the design of visualizations.

20

<!-- page 21 -->

# Gestalt Principles of Visual Perception

Proximity: Objects that are close together are perceived as a group.

21

<!-- page 22 -->

# Gestalt Principles of Visual Perception

Similarity: Objects that share similar attributes (e.g. color or shape) are perceived as a group.

22

<!-- page 23 -->

# Gestalt Principles of Visual Perception

Enclosure: Objects that have boundary around them are perceived as a group.

23

<!-- page 24 -->

# Gestalt Principles of Visual Perception

Closure: Open structures are perceived as closed, complete, and regular.

24

<!-- page 25 -->

# Gestalt Principles of Visual Perception

Continuity: Objects that are aligned together are perceived as a group.

E

D

C

B

A

25

<!-- page 26 -->

# Gestalt Principles of Visual Perception

Connection: Objects that are connected (e.g. by a line) are perceived as a group.

26

<!-- page 27 -->

# The Zen of Visualization Design

Above else show the data.

Maximize the data-ink ratio.

Erase non-data-ink.

Erase redundant data-ink.

Revise and edit.

27

<!-- page 28 -->

# The Zen of Visualization Design

$$
\begin{aligned}
\text{Data-ink Ratio} &= \frac{\text{data ink}}{\text{total ink used to print the graphic}} \\[2em]
&= \text{proportion of ink devoted to the non-redundant display} \\
&\quad \text{of data-information} \\[2em]
&= 1 - \text{proportion of a graphic that can be erased without loss of} \\
&\quad\qquad \text{data-information}
\end{aligned}
$$

28

<!-- page 29 -->

# (Radical) Tufte Example

29

<!-- page 30 -->

# (Radical) Tufte Example

30

<!-- page 31 -->

# (Radical) Tufte Example

31

<!-- page 32 -->

# Stephen Few's Design Recommendation

## Reduce the Non-Data Pixels

1. Subtract unnecessary non-data pixels.

   Ask yourself: "Would the data suffer any loss of meaning or impact if this were eliminated?"

   If the answer is "no," then get rid of it.

2. De-emphasize and regularize the remaining non-data pixels.

   e.g. use thin lines and light grey for supporting non-data components of the graph (axes, labels, etc.)

32

<!-- page 33 -->

# Stephen Few's Design Recommendation

## Enhance the Data Pixels

1. Subtract unnecessary data pixels

   Not all information is equally important.

2. Emphasize the most important data pixels

   Use attributes of pre-attentive processing (e.g. color, size, width) to emphasize the most important data pixels.

33

<!-- page 34 -->

# Example

34

<!-- page 35 -->

35

<!-- page 36 -->

# Which Is an Act of Terrorism?

### U.S. drone attacks
* 67% YES
* 27% NO
* 6% DON'T KNOW

### The 2008 Mumbai hotel attacks
* 81% YES
* 19% NO

### Execution of the American journalist Daniel Pearl
* 78% YES
* 22% NO

### 2010 U.S. military operation in Kandahar, Afghanistan
* 65% YES
* 23% NO
* 12% DON'T KNOW

# Religion

* **75%** Belief in God is necessary for good moral values
* **49%** Politicians who do not believe in God should not hold office
* **53%** Religious leaders should not influence voting
* **59%** The government should not pass laws that contradict Shariah

# Earthquake Aid

WHY DID THE U.S. GIVE MILLIONS AFTER THE 2005 KASHMIR EARTHQUAKE?

### Sincere desire to help
* **63%** Agree
* **37%** Disagree

### Generate Muslim support
* **53%** Agree
* **47%** Disagree

### Good, whatever the motive
* **72%** Agree
* **28%** Disagree

36

<!-- page 37 -->

**AGE STRUCTURE OF COLLEGE ENROLLMENT**

Percent of total enrollment

72
71
70
69
68
67
66

72.0
70.8
67.2
66.4
67.0

UNDER 25

25 AND OVER

34
33
32
31
30
29
28

28.0
29.2
32.8
33.6
33.0

1972
1973
1974
1975
1976

37
