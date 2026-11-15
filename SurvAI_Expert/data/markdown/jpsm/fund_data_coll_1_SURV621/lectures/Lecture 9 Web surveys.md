---
id: "jpsm/fund_data_coll_1_SURV621/lectures/Lecture_9_Web_surveys"
source: "jpsm"
course: "SURV621"
course_title: "Fundamentals of Data Collection I"
doc_type: "lecture"
title: "SURV 621/SURVMETH 621: WEB SURVEYS"
original: "fund_data_coll_1_SURV621/lectures/Lecture 9 Web surveys.pdf"
pages: 36
sha256: "68cf0afa01a2fc6821b8441b7893d5ac15df50aa0baaaa6017182c964bc14593"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:58"
---

<!-- page 1 -->

# SURV 621/SURVMETH 621: WEB SURVEYS

November 4, 2024

<!-- page 2 -->

# Overview

* TSE Perspective on Web Surveys
* Basic Building Blocks of Web Survey Questionnaires
* Assignment #3 + Qualtrics Demo

2

<!-- page 3 -->

# TSE Perspective on Web Surveys

3

<!-- page 4 -->

# Coverage Error in Web Surveys

* Undercoverage largest concern in Web surveys of general population:
  - Persons without Internet access are, by definition, excluded from sampling frames
* Proportion of US adults who are offline has decreased steadily (Pew)
  - 48% in 2000, 5% in 2023
* Groups who were most likely to be offline in 2000 are still offline, although proportions have declined (Pew)
  - Older: 86% in 2000, 12% in 2023
  - Less educated: 81% in 2000, 10% in 2023

4

<!-- page 5 -->

# Nonresponse Error in Web Surveys

* Nonresponse <u>error</u> is function of nonresponse rate and difference between means for respondents and nonrespondents
* Cannot calculate response rate in opt-in samples
* Instead, participation or completion rate is recommended (Callegaro & Disogra, 2008): % starters who completed
* Response rate can be calculated in probability panels (but can be calculated in different ways)
* Focus typically on response rates in probability samples not nonresponse error

5

<!-- page 6 -->

# Response Rates in Probability Web Surveys

* Lozar Manfreda et al. (2008) meta-analysis of 24 studies shows that Web surveys yield response rate 11% lower than other modes (Phone, Mail, Fax, Email, IVR, TDE)
* Meta-analysis by Shih & Fan (2008) with 39 studies shows on average RR for mail 10% higher than list-based Web

| | Schonlau | Quigley | Griffin | Kennedy | Steiger | Nichols C | Nichols T |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Web** | 7.1 | 10 | 2.2 | 7.8 | 16.1 | 9.3 | 21.4 |
| **Mail** | 13 | 32 | 35.6 | 34.9 | 39.3 | 76.9 | 64.9 |

6

<!-- page 7 -->

# Measurement Error in Web Surveys

* Web implementation of questionnaires may differ from other modes; web surveys are:
  – Self-administered (compared to In-Person and Phone interviews)
  – Computerized/automated and interactive (in contrast to Mail)

7

<!-- page 8 -->

# Web Surveys are Self-administered

* Advantages
  - Reduction of social desirability and other biases associated with presence or behavior of *Iwer*
  - Can be completed at *R*'s convenience
* Disadvantages
  - No one is present to probe, clarify, assist, motivate, etc.
  - Less guarantee that *R* will complete survey than in interviews
  - Computing environment (context) not under researcher's control
  - Web survey *Rs* at risk for distraction by multitasking (online and offline)

8

<!-- page 9 -->

# Web Surveys are Computerized and Interactive

* Complex routing, skips, edits, etc. possible
* Ability to randomize question and response option order
* Ability to tailor questionnaire for *R* by filling in name and previous answers
* Instrument can provide feedback (e.g., error messages, progress indicators)
* Can simulate some features of interviewer behavior (e.g., offering definitions, tailored encouragement, feedback to discourage speeding)
* Can provide include features that help respondent perform task (e.g., definitions on demand)

9

<!-- page 10 -->

# Basic Building Blocks of Web Survey Questionnaires

10

<!-- page 11 -->

# User-Centered Design Perspective

* The primary focus of the design process should be on the users (respondents) and their needs
  - Design process is iterative, often involving an evaluation of the product (web survey questionnaire) with potential users
* Design should facilitate and support the users in their task of completing the survey

Source: Couper (2015)

<!-- page 12 -->

# Goal of Good Design

- The main tasks of the respondent are to read a question, respond to it, and navigate through the instrument
- Apply design features that support these tasks
- Main considerations: efficiency, accuracy, and satisfaction

Source: Couper (2015)

<!-- page 13 -->

# Range of available software for developing computerized survey instruments

* *Blaise*
  - Supports CATI, CAPI, CASI and web surveys
  - Developed by Statistics Netherlands; used by many national statistical offices, including U.S. Census Bureau
* *Qualtrics*
  - Online survey platform
  - Users can create surveys for free (features are restricted) or buy license to use all features
  - Customers include universities and private companies (market research and other applications)
* *LimeSurvey*
  - Open-source software
  - Two software formats: online platform and software for download
  - Users can create surveys for free (restricted to 25 responses/month) or enroll in paid plans
* *Survey Monkey*
  - Online survey platform
  - Users can create online surveys for free; company makes money by selling back-end services

13

<!-- page 14 -->

# Basic Question Types

* Radio buttons and checkboxes
* Drop-boxes (drop-down list)
* Text fields
* Sliders scales
* Grids

<!-- page 15 -->

# Radio Buttons and Check Boxes

* Radio buttons
  * Standard format for single-choice responses
  * When one item in a list is selected, all others are unselected
* Check boxes
  * Appropriate for multiple response, check-all-that apply questions
  * Can toggle several items in list on or off

RADIO BUTTONS

CHECKBOXES

<!-- page 16 -->

# Radio Buttons and Check Boxes Cont’d

* Advantage: used in many applications and so familiar to most users
* Design considerations
  * Use the appropriate tool for the task
  * More appropriate for shorter lists than longer lists
  * Presents a small target which can be difficult to select, especially on smartphones

<!-- page 17 -->

# Drop-Boxes

* Used for single-choice responses
* When box is inactive, it displays a single value. When activated, it displays a list of values.
* Advantage: saves space on screen

What is your job function:

-- Choose one --
* -- Choose one --
* Technical / Research
* Consultant
* Senior management
* Clerical
* Middle management
* Other management

<!-- page 18 -->

# Drop-Boxes Cont’d

* Appropriate when:
  * The list is too long to display on the page
  * The answer is known to the respondent
  * The list is ordered in a meaningful way (e.g., alphabetic)
  * Selecting the response is more efficient than typing
  * The answer is still recognizable when truncated

Adapted from Couper (2015)

<!-- page 19 -->

# Text Fields

* Two formats:
  – Single-line text field for numbers or short text answers
  – Text area for longer, open responses
* Designer can control:
  – Size of visible area (how big the box looks)
  – Maximum input (how much can be entered)
* Design considerations
  – May need to provide guidance on format of information to be entered (e.g., MM/DD/YYYY)
  – Provide sufficient space for input but not too much space

Source: Couper (2015)

<!-- page 20 -->

# Slider Scales

- Used for continuous scales (e.g., 1-100)
- Not appropriate for ordinal response scales (e.g., Likert scale)
  - Evidence of high missing data and longer completion times (Funke 2016)
- Design considerations
  - Answers might be influenced by initial position of slider (Funke 2011)
  - Answers might be influenced by feedback about selected value (Liu & Conrad, 2016)
  - Slider line is relatively short when displayed on smartphones

How would you rate our Survey Anyplace tool?

Worst Best

84

0 10 20 30 40 50 60 70 80 90 100

20

https://help.surveyanyplace.com/

Source: Keusch (2019)

<!-- page 21 -->

# Grids or Matrix Question

* Table displaying set of items sharing the same response options
* Items are presented in rows and response options in columns
* Respondents answer row-by-row

| | **Please rate the following aspects of the motivational seminar that you attended** | | |
| :--- | :---: | :---: | :---: |
| | Highly motivating | Motivating | Not motivating |
| Guest speaker | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Seminar pamphlets | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Motivational CD | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |

www.zarca.com

Source: Couper (2015)

<!-- page 22 -->

# Grids Cont’d

## Advantages
* Faster to complete (Couper et al. 2001; Mavletova & Couper 2015; Rossmann et al. 2018; Toepoel & Dillman 2008; Toepoel et al. 2009; Tourangeau et al. 2004, 2013)
  * Reduce screen orientation time
* Provides more context for related items
  * Higher inter-item correlation when multiple items measure same construct (Tourangeau et al. 2004)

## Disadvantages
* Less *R* satisfaction (Thorndike et al. 2009; Toepoel et al. 2009)
  * Especially for large grids (Couper et al. 2013; Liu & Cernat 2016)
* May encourage straightlining and non-differentiation (Baker et al. 2010; Couper et al. 2013; Rossmann et al. 2018; Zhang & Conrad 2014)
* May increase item missing data (Mavletova & Couper 2015; Rossmann et al. 2018; Peytchev et al. 2006; Toepoel et al. 2009)
* May not fit screen width of smartphone

22 Adapted from Keusch (2019)

<!-- page 23 -->

# Avoid Large Grids

**Wie zufrieden sind Sie mit den folgenden Flug- und Bahngesellschaften in Bezug auf die folgenden Kriterien?**
**Bitte bewerten Sie dies auf einer Skala von "- -" (sehr unzufrieden) bis "++" (sehr zufrieden).**

| | **Austrian** <br> **Austrian Airlines** | | | | | **ÖBB** <br> **ÖBB** | | | | |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| | -- | - | 0 | + | ++ | -- | - | 0 | + | ++ |
| | | | | | | | | | | |
| Anzahl meiner Reiseteilnehmer | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Komfort des Reisens und Wartens | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Sicherheit des Verkehrsmittels | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Kosten (günstiger Preis) | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Schnelligkeit/Zeitdauer | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Beschäftigungsmöglichkeiten während der Reise | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Art und Menge des Gepäcks (Mitnahmemöglichkeit) | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Möglichkeit zu Spontaneität und Flexibilität | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Reisen mit Kunden | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Ökologische Verantwortung | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Einfachheit und Stressfreiheit | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Reise ins Ausland | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| | **Austrian** <br> **Austrian Airlines** | | | | | **ÖBB** <br> **ÖBB** | | | | |
| | -- | - | 0 | + | ++ | -- | - | 0 | + | ++ |
| Betreuung und Unterstützung (während der Reise) | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Selbstbestimmtheit und Unabhängigkeit | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Direktheit (ohne Umsteigen) | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Planbarkeit der Reise und Pünktlichkeit | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Ruhe und Ungestörtheit | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |
| Passende Abfahrts-/ Ankunftszeit | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ | $\bigcirc$ |

Source: Keusch (2019)

23
23

<!-- page 24 -->

# Page layout and design

* Grouping of items
* Navigation
* Designing for mobile devices

<!-- page 25 -->

# Grouping of Items: Scrolling vs. Paging

* Scrolling Web survey
  – Survey questions are presented on one single page
  – *R* can scroll back and forth through instrument
* Paging Web survey
  – Survey questions presented on separate pages
* Alternative: grouping thematically related questions on same page
  – e.g., multi-item scale, sociodemographic *Q*s

Source: Keusch (2019)

<!-- page 26 -->

# Strength of Each Approach

### Scrolling (static)

* Easy to program
* Minimizes page loading time
* *R* can review entire questionnaire
  * Aware of progress / context
  * Can easily review/change previous answers
* Well suited for shorter, simpler Web surveys

### Paging (interactive)

* Complex skips, fills, and other logic possible
* Order of answering controlled
* Less item missing data (Lozar Manfreda et al. 2002; Peytchev et al. 2006)
* All data captured in progress – can be suspended and resumed
* Well suited for complex Web surveys

26

Source: Keusch (2019)

<!-- page 27 -->

# Navigation

* Four actions generally possible in paging surveys:
  - “Next”: Proceed to next page
  - “Back”: Return to previous page
  - Quit, stop, or suspend
  - Launch separate form or page with procedural help, definitions, etc.
* Design tips
  - Clearly label action buttons and place them in a logical and consistent position
  - Permit respondents to back up and review/change answers, but don’t encourage this behavior
  - No need for question numbering (if skips are automated)

Source: Couper (2015)

<!-- page 28 -->

# Assignment #3 + Qualtrics Demo

28

<!-- page 29 -->

# Assignment #3

Collaborate with team members to:

1. Program preliminary version of instrument
2. Briefly describe each component of your testing approach:
   - question-by-question testing
   - scenario testing
   - testing on different browsers/devices
3. Test and record comments (in spreadsheet)
4. Revise instrument accordingly

29

<!-- page 30 -->

# Qualtrics: Getting started

* University of Maryland faculty, staff and students have access to Qualtrics at: https://umdsurvey.umd.edu
* University of Michigan faculty, staff and students have access to Qualtrics at: https://umich.qualtrics.com
* Lots of online help available on Qualtrics website

30

<!-- page 31 -->

# *Qualtrics* Demo: Creating Q’naire; Importing & Exporting QSFs

* New questionnaire
  – “Create new project” -> “Survey” -> “Get Started”-> create a project name
  – Or to import an existing q’naire: select “Import a QSF file” -> select QSF
* Sharing a questionnaire with group members
  – “Tools”-> “Collaborate” -> enter email address
* Export
  – “Tools -> “Import/Export” -> “Export Survey”
* Generating a survey link
  – “Distributions” -> “Anonymous Survey Link”

31

<!-- page 32 -->

# *Qualtrics* Demo Cont’d: Some options for controlling question wording, flow and presentation

* Survey options -> Responses
  – Back button\*
* Survey look and feel
  – Progress bar\*
* Question options
  – Response requirements
  – Page break
  – Skip logic/display logic\*
  – Piped text
* Block options
  – *Loop and merge* used to dynamically repeat a block of questions multiple times for a respondent
  – *Loop and merge fields* used to create dynamic text that is different for each loop
    -> `${lm://Field/1}` `${lm://Field/2}` ...
  – Display logic within loop and merge
  – Randomizer

\*Free version of software provides no access to these features.

32

<!-- page 33 -->

## Download the survey instrument from Canvas (assignment #3)

*What question types are used?*

*Does it use a paging or scrolling design?*

33

<!-- page 34 -->

# Tips for Using Blocks in Assignment #3

* Put first three questions in one block
  – Block 1: Consent; Q1; Q2
* Create three separate blocks with *loop and merge* based on Q2\*
  – Block 2: Q3\_X (relationships)\*\*
  – Block 3: Q4\_1 through Q8\_1 (demographics)
  – Block 4: Q10\_1 through Q16\_1 (Employment)
* Create one block with *randomizer*
  – Block 5: Q17A and Q17B

\*This will require creating a table containing loop and merge text fields. See: [https://rb.gy/ax2lpc](https://rb.gy/ax2lpc)

\*\*Use display logic to hide this question during the first loop

-You may find that the skips are easier to program by adding *display logic* rather than *skip logic*

-Consent can be implemented by using a “multiple choice” question type (allow multiple answers), only displaying 1 response choice, adding a “force choice” requirement

-Some numeric entry question require “validation” (e.g., to restrict values from 0-100)

34

<!-- page 35 -->

# Instrument testing protocol

* Question-by-question testing: Each question or screen in the survey should be tested before moving on to the next.
  – Looking primarily for issues with response selection and text and text fills

* Scenario testing to evaluate display logic and skips: Construct scenarios of responses, then enter accordingly
  – Construct scenarios that test all of the different text fills and skips
  – Include missing values and out-of-range values

* Instrument should be tested on different machines (desktops or laptops, tablets and phones) using different browsers (Chrome, Firefox and Internet Explorer)
  – Looking primarily for formatting issues

35

<!-- page 36 -->

# Tips for Scenario Testing in Assignment #3

* Key factors for fills
  * whether question is asking about respondent themselves or someone else in the household
  * whether question is about someone's main job or secondary job
* Key factors for scenarios
  * household size
  * working or not
  * job identified based on reporting to work last week (Q10) or identified based on having a job from which temporarily absent (Q11)
  * multiple jobs or not
  * whether year of birth is recorded
* Example scenarios:
  * respondent is the only member of their household and has two jobs
  * two people in household, one with job identified based on reporting work last week (Q10) and one with job identified based on having a job from which temporarily absent (Q11)

36
