---
id: "jpsm/fund_data_coll_1_SURV621/lectures/Lecture_10_Mobile_Web_and_Text_(SMS)_surveys"
source: "jpsm"
course: "SURV621"
course_title: "Fundamentals of Data Collection I"
doc_type: "lecture"
title: "Mobile Web and Text Message Surveys"
original: "fund_data_coll_1_SURV621/lectures/Lecture 10 Mobile Web and Text (SMS) surveys.pdf"
pages: 42
sha256: "7d06a93dd24872398354896962819bd1f306270eac60f59daa94296d028c6e9b"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:56"
---

<!-- page 1 -->

# Mobile Web and Text Message Surveys

*SurvMeth/Surv 621*
November 11, 2024

*Chris Antoun* \*

\*adapted from slides developed by *Frederick Conrad*

<!-- page 2 -->

# Outline

* Web Surveys on a Mobile Device
  * How does the computing device on which web surveys are completed affect error?
* Text Message Surveys
  * Survey invitations via text messages
  * Asking survey questions and capturing responses via text messages

2

<!-- page 3 -->

# Importance of Studying Smartphone Data Collection

### *% of U.S. adults who use smartphones*

| Year | % |
| --- | --- |
| 2014 | 55% |
| 2015 | |
| 2016 | |
| 2017 | |
| 2018 | |
| 2019 | |
| 2020 | |
| 2021 | |
| 2022 | |
| 2023 | 90% |

+35%

### *% of U.S. adults who are “smartphone-only” users, by race and ethnicity (2023)*

| Race and ethnicity | % |
| --- | --- |
| White | 12% |
| Black | 21% |
| Hispanic | 20% |
| Asian | 14% |

3

Source: Pew Research Center Surveys of U.S. adults conducted 2014-2023.

<!-- page 4 -->

# Smartphones Commonly Used for Web Surveys

### ***% of participants who responded to web survey on their phones (unofficial)***

| | |
| :--- | :--- |
| American National Election Survey* (Internet sample, 2016) | 13% |
| National Survey of College Graduates (Internet sample, 2019) | 15% |
| American Community Survey (Internet sample, Dec 2019) | 19% |
| German Internet Panel (Sept 2020) | 35% |
| KnowledgePanel® (general population sample, 2020) | 40% |
| Understanding America Study Panel (2020) | 45% |

0% 5% 10% 15% 20% 25% 30% 35% 40% 45% 50%

Sources: Personal communications with Rachel Horwitz, Arie Kapteyn; Ulrich Kreiger; and Randall Thomas.
Neufelder et al. 2020; ANES 2016 User Guide Codebook *Post-election survey

<!-- page 5 -->

# Web Surveys Conducted on a Mobile Device

* Mobile Web Surveys = Online surveys administered on an internet-enabled mobile, device in browser or survey app
  * Devices include smartphones and tablets
  * Apps generally must be downloaded
  * Questionnaires mostly visual (like conventional web surveys) with touch input
* Mobile Web Surveys $\neq$ voice interviews over mobile phone
* Design and implementation like conventional Web survey but
  * different hardware – and maybe software – on *R* side
  * designed for mobile administration (“optimized for mobile”)

5

<!-- page 6 -->

# Example of Outdated Design

The parent preference survey closes Dec. 3. Your response will play a critical part in our return to school planning: [https://bit.ly/3lJGXbW](https://bit.ly/3lJGXbW)

Txt STOP to cancel

AT&T 9:16 AM 97%
parentsurvey.mcpsmd.org/i...

Maryland's Largest School District
**MONTGOMERY COUNTY PUBLIC SCHOOLS**

Welcome to the 2020 Parent/Guardian Virtual Learning Preference Survey

You will need to enter the MCPS student ID for your child(ren) to access the survey. You can find this information in ParentVue. Your answers are confidential. **Complete the survey for the child whose information you enter below. Please complete a survey for each child in your household.**

Change to different language.

You can find your child's MCPS student ID in ParentVue or on their report cards. You can also ask your child for their MCPS ID number.

Enter your child's 6-digit or 8-digit MCPS student ID:

What is this student's grade level:
PreK Kindergarten
1 2 3 4 5 6 7
8 9 10 11 12

Submit survey for which school? (clear school entry)

Access Survey

* Web page is the same regardless respondent's device
  - Small buttons and fonts require zooming
  - Zoomed view requires both vertical <u>and</u> horizontal scrolling

6

<!-- page 7 -->

# Mobile Optimization

* Web page adjusts to respondent's device, often using Responsive Web Design
* Mobile respondents see:
  - an adjusted layout <u>and</u>
  - content that is wrapped and re-sized to fit the width of their screen
* Adjustments to layout may include:
  - removing logos
  - collapsing menu into hamburger icon

Source: https://bit.ly/3nte9on

<!-- page 8 -->

# Mobile Optimization – Example

Break-point

Break-point

*Layout A*
Screen width>1024 px or 10.7”

*Layout B*
768-1024 px
8-10.7”

*Layout C*
<768 px or 8”

* Survey may appear differently to different respondents
* Way that software makes adjustments may be unknown to the designer

*px = design pixels

8

<!-- page 9 -->

# Response Errors

* **Antoun et al. 2017:** Do respondents provide lower quality responses when using smartphones than when using computers (desktops and laptops)?
* **Methods:**
  - Two-wave crossover design in probability web panel representing Dutch population
  - Sensitive questions to measure socially desirable responding
  - Cognitively burdensome questions to measure survey satisficing
  - Debriefing questions to measure respondents' context of use
  - Paradata to measure response times

recruitment  
$n = 1,390$

smartphone  
computer

smartphone  
computer

one month | one month | one month

9

<!-- page 10 -->

# Response Errors Cont'd

* **Findings:**
  1. **Context of use was different.** Smartphone users were:
     * More likely to be around other people (37% compared to 30% on computers)
     * More likely to multitask (54% compared to 44% on computers)
  2. **Response quality was not different:**
     * No significant differences in disclosure of sensitive information by device
     * No significant differences in satisficing by device
  3. Respondents took **1.4 times longer** when using smartphones
     * Larger differences for some question formats (sliders) and subgroups (those with low levels of familiarity using smartphones)

10

<!-- page 11 -->

# Completing an “Optimized” Survey on Smartphone is *Still* Harder than on a Desktop/Laptop

* Longer completion times

| Study | Ratio | Notes |
| --- | --- | --- |
| * Burkirk & Andrus '14 | 0.67 | iPhone App-based |
| * Wells et al. '14 | 0.95 | |
| * Toepoel & Lugtig '15 | 1.02 | |
| McGeeney & Marlar '13 | 1.15 | |
| Peterson et al. '12 | 1.27 | |
| * De Bruijne & Wijnant '13 | 1.6 | |
| Wells et al. '14 | 1.68 | |
| * Antoun '15 | 1.78 | |

0.5 0.7 0.9 1.1 1.3 1.5 1.7 1.9

Ratio of completion times in mobile vs. PC Web

Source: Couper & Peterson (2015)

* Increased likelihood of breakoff

| Study | Ratio |
| --- | --- |
| Buskirk & Andrus (2014) | 1.1 |
| Baker-Prewitt (2013) | 2.6 |
| McGeeney & Marlar (2013) | 3.3 |
| Barlas et al. (2015) | 3.7 |
| Wells et al. (2013) | 4.0 |
| Mavletova & Couper (2013) | 4.7 |
| Mavletova (2013) | 8.8 |

0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0

Ratio of breakoff rates in mobile vs. PC Web

Adapted from Couper, Antoun, & Mavletova (2017)

All surveys shown above were optimized for mobile.

11

<!-- page 12 -->

# Breakoffs Cont'd

* Breakoffs seem to be driven by same mechanisms as in conventional Web surveys (e.g., cognitive burden, multitasking)
* Possible explanation for lower response rate and higher break-off rates in mobile than conventional Web surveys
  - Time – mobile takes longer, likely increasing burden
  - Survey experience less satisfying, interface harder to use

<!-- page 13 -->

# Touch Target Size

* Olmsted-Hawala et al. 2018: How do various mobile questionnaire design features affect usability?
  * *Five experiments focused on size and formatting of text and input tools. I focus on one: How does touch target size and spacing affect usability?*
* **Methods:**
  * Two-factor within-subjects design – target size, target spacing. Custom research app captured touch location to measure **accuracy** and touch time to measure **efficiency**.
  * Sample of older adults (n=52) recruited in-person at senior centers (mean age = 69)

75 combinations
per person

<!-- page 14 -->

# Touch Target Size Cont'd

* **Findings:**
  1. As target size $\uparrow$, touch time $\downarrow$
  2. As target size $\uparrow$, success rate $\uparrow$
     * Change point at 6mm: Up to that point, each 1mm increase in target size yields a 17% increase in the success rate on average. After that point, each 1mm increase yields a 3% increase in success rate.
  3. No significant effects of target spacing nor of the interaction between target size and target spacing.

| Target Size (mm) | Target-touch Success Rate (%) |
| :---: | :---: |
| 2 | 18.5 |
| 3 | 35.9 |
| 4 | 53.9 |
| 5 | 75.0 |
| 6 | 86.8 |
| 7 | 90.4 |
| 8 | 92.7 |
| 9 | 94.6 |
| 10 | 97.7 |
| 11 | 99.6 |

<!-- page 15 -->

# Drop-Downs (or Drop Boxes)

* Advantage: saves space on screen
* Are rendered differently in different mobile browsers
  - iPhone *picker* wheel:
    * typically displayed at bottom of the screen
    * few items are displayed at once; many items may be initially hidden
    * one-line of text per item; text gets truncated (*“Neither agree nor dis . . . ”*)
  - Android *spinner*:
    * typically displayed as popover
    * items appear in list

iPhone picker

Android spinner

Source: Nichols et al. (2017)

<!-- page 16 -->

# Drop-Downs Cont’d

- Pickers require more time... $\qquad \qquad$ ... and effort

| | Radio button/text entry | Spinner List | Picker Wheel |
| :--- | :---: | :---: | :---: |
| **Completion Time per Question (Seconds)** (0–25) | 13 | 15 | 21 |
| **Screen Touches Per Question** (0–7) | 2.6 | 3.5 | 6.5 |

Participants: adults age 59+

Source: Olmsted-Hawala et al. (2018)

<!-- page 17 -->

# Font Size

* Small text is hard to read
* As font size increases:
  - the number of characters per line decreases
  - the number of characters per screen decreases
* On the positive side: smaller text may be easier to read on smartphones than desktops/laptops because of shorter viewing distance

67 mm

Font Size 4
Font Size 6
Font Size 8
Font Size 10
Font Size 12
Font Size 14
Font Size 16

138 mm

Approximate screen dimensions of iPhone SE

<!-- page 18 -->

# Font Size Cont’d

* Little difference in reading speed above 6 or 8 point font
* 14 point or larger causes more scrolling and are not preferred

Source: Darroch et al. (2005)

<!-- page 19 -->

# Open Items – Voice Input

* Smartphones have microphones that can be use for voice input
  – Dictation – input converted to text in real-time for respondent to view/edit
  – Voice Recording – audio file converted to text after the survey

Now we will ask you some open-ended questions. Please use the voice button (like this one) to answer them all. Thus, instead of writing, you just have to talk, and your response will be saved as a voice message.

Push this voice button to start recording your answer.

While you are recording, you will see red circles appearing around the button.

Source: Revilla et al. (2020)

<!-- page 20 -->

# Use of Voice Input: Faces Challenges but Shows Some Promise

* Increased item nonresponse
* Longer responses
* No effect on number of codeable answers

* Text Entry (Android)
* Dictation (Android)
* Voice Recording (iOS)

Source: Revilla et al. (2020)

\*among *Rs* who answered all six *Qs*

<!-- page 21 -->

# Accordions

* Stacked list of items. Each one expands in place and pushes other content down. After answering, item contracts again.
  * Thomas & Barlas (2016): no effect on answers
* Advantages:
  * Compact, so little scrolling is required
  * Does provide context for related items (enables *Rs* to see full group of items and individual items)
* Disadvantages: May be disorienting - *More research is needed.*

<!-- page 22 -->

# What Features Do Respondents Want?

* Smartphone app features suggested by participants in "co-design" sessions

| Ease and Convenience | Usefulness | Accessibility |
| :--- | :--- | :--- |
| Speech-to-text transcription for open-ended questions | Customizable reminders and notifications | Ability to change the font size |
| Includes information about each module (name and length) | App should be multipurpose (e.g., packaged with other useful features), not for one-time use | Text-to-speech functionality (i.e., the app can read out the questions and instructions) |
| Supports easy navigation between questions and modules | Personalized results (e.g., how your responses have changed over time or compare to other respondents) | Ability to seek user guidance and provide feedback |
| Access to data privacy information | Provides indicator of progress for full survey and individual modules | |

Source: Antoun et al. (2024)

<!-- page 23 -->

# Mobile Web Summary and Conclusions

* Web design would be simpler if all respondents used the same type of device (*but they don’t*)
  * Or if they web surveys designed for desktops/laptops delivered a good experience for mobile users (*but they often don’t*)
* Mobile optimization can help, but doesn’t necessarily optimize user experience
* In mobile design, there seems to be a common trade-off between
  * Sufficient size of design elements
  * Sufficient information on screen (to reduce scrolling)
* Testing is extremely important, on different smartphones, with real users if possible

23

<!-- page 24 -->

# Text Messages in Conducting Surveys

* Text message communication widespread in most parts of the world
* The technology on which it relies is not new
  - Developed in 1980s; first commercial text message service in 1990s
* But it’s still new in the survey enterprise
* It is used both for <u>inviting</u> sample members to web (or text message) surveys and <u>collecting data</u>, i.e., as an interview mode
  - As an invitation mode, generally contains a link to web survey
  - As an interview mode, interviewing agent is either human or automated system; agent texts questions to respondents who text their answers

<!-- page 25 -->

# What Do We Mean By “Texting?”

* Sending and receiving character-based messages
  - Limited to 160 characters in SMS*, unlimited in internet-based apps.
    * iMessages, WeChat, Whatsapp, etc.
  - Created via onscreen (alphabetic or numeric) keypads or via physical (alphanumeric) keypad on older cell phones
  - Exchange of messages displayed as thread on smartphones; individually on older devices
  - User alerted when messages arrive via tone or visual notification or vibration
  - Text communication may require sender and recipient to subscribe to same service (e.g., WhatsApp, WeChat)?

*Short Message Service

<!-- page 26 -->

# Text Message Communication

* Persistence
  * Text messages (unlike spoken turns) survive until deleted and are reviewable
* Noticeability
  * Users likely to be aware of receiving text message
  * Notification: auditory, visual, haptic (vibration)
* Asynchrony
  * Users reply when safe and convenient but no pressure to respond immediately (as in voice communication)

26

<!-- page 27 -->

# Texting an Invitation to a Web Survey

* Requires mobile phone numbers for sample members
* Existing, rich sampling frames include mobile phone numbers
  - USPS Delivery Sequence file with appended mobile phone number(s) for HH
  - Census Bureau’s Master Address File (MAF):
    * Childs, et al. (2021) report that MAF contains at least one mobile phone # for > 80 million households and at least one email address for > 130 million households
* Possible to collect mobile phone number in earlier wave of study for which contact made in another mode

27

<!-- page 28 -->

# Texted vs. Emailed Invitations

* More web surveys completed with texted than emailed invitations in Household Pulse Survey (Childs, et al. 2021)

Source: Data from Household Pulse Survey (April 23, 2020-March 29, 2021)

<!-- page 29 -->

# SMS invitation leads to fast completion of web survey

* Spiegelman and Zotti (2023) obtained mobile phone numbers from principals in National Teacher and Principal Survey in earlier paper questionnaire
* invited *R*s via SMS, email, or mail to complete short web q'aire
* RR: SMS > email > mail (all diffs significant)
* SMS invitations led to very fast completion: median days = 0 for SMS vs. 13 for email vs. 26 for paper
* ~33% of SMS completers completed in 5 minutes of receiving invitation and an additional 40% within 1 hour

<!-- page 30 -->

# Texting an Invitation to a Mobile Web Survey: Mobile RDD

* Possible in principle to randomly generate mobile phone numbers and text an invitation to complete mobile web survey
  * Not possible (or at least not practical) to randomly generate email addresses
* Bucher & Sand (2021) demonstrated feasibility of approach:
  * Invitations contained link (TINY URL); low response rates (~1%), including high proportion of breakoffs on first page of web survey, but not lower than in current telephone surveys using RDD
  * Feasible technically but RR needs to be improved to be viable

<!-- page 31 -->

# Text Messaging as an Interview Mode

77039 >

Text Message
Today 15:25

How often do you now smoke cigarettes?

A. Every day
B. Some days
C. Not at all

C

Have you smoked at least 100 cigarettes in your entire life? Y or N

N

During the past 30 days, on how many days did you drink one or more drinks of an alcoholic beverage?

4

Text Message

Pay

<!-- page 32 -->

# Text Interviews: Coverage Error

* If some mobile phone owners do not text, and so cannot be reached for a text interview, estimates derived from these interviews may be biased
* Unknown to what extent texters represent all mobile users including those who do not text

<!-- page 33 -->

# Coverage of those who text among smartphone owners is practically universal* (even in 2014)

## Smartphone activities by age

| | 18-29 | 30-49 | 50+ |
| :--- | :--- | :--- | :--- |
| Text messaging | 100 | 98 | 92 |
| Internet use | 97 | 90 | 80 |
| Voice/video calls | 93 | 91 | 94 |
| Email | 91 | 87 | 87 |
| SNS | 91 | 77 | 55 |
| Video | 75 | 46 | 31 |
| Music | 64 | 39 | 21 |

*especially among younger people

Pew Research Center American Trends Panel experience sampling survey, November 10-16 2014.

33

<!-- page 34 -->

# Texting and Coverage Error (2)

| | Full sample of mobile owners ($n = 1127$) A | Mobile owners who text ($n = 962$) B | Coverage deviation $|A-B|$ |
| :--- | :---: | :---: | :---: |
| | *% (SE)* | *% (SE)* | *Est.(SE)* |
| **Age (>34 years old)** | 62.4% (1.4) | 57.0% (1.6) | 5.4%* (0.4) |
| **Sex (=Male)** | 56.2% (1.5) | 55.3% (1.6) | 0.9% (0.6) |
| **Education (=College grad)** | 36.4% (1.4) | 38.0% (1.6) | 1.7%* (0.6) |
| **Race (=White)** | 70.5% (1.4) | 70.1% (1.6) | 0.5% (0.5) |
| **Ethnicity (=Hispanic)** | 16.1% (1.1) | 16.4% (1.2) | 0.4% (0.4) |
| **Income (=\$30K or more)** | 71.8% (1.3) | 72.9% (1.4) | 1.1% (0.6) |

Analysis of Pew’s Spring Tracking Survey conducted from April-May 2013, reported in Conrad et al. (2017)

These are relatively small coverage effects, albeit significant

*$p < 0.05$

<!-- page 35 -->

# Text Messaging as an Interview Mode: Response Rates

* Higher Response Rate* for Text than voice (phone) interview (Schober et al., 2015)

* Sample members already agreed to be in experiment but did not know interview mode
* Higher response rate in text could be due to (1) persistence of invitation in message list, (2) numerous indications that text message has arrived (awareness of invitation), (3) ability to respond when convenient, (4) more time to decide

*AAPOR RR1: # complete interviews / # invitations

<!-- page 36 -->

# Text Message Interviews: Response Rates in Low-Income Countries

* Lau et al. (2019) report highly variable RRs by country:

| Ghana | Kenya | Nigeria | Uganda |
| :---: | :---: | :---: | :---: |
| 12.1 | 0.62 | 0.28 | 14.19 |

* Participation obstacles arising from
  - Illiteracy$^1$ (~34% sub-Saharan Africa in 2018)
  - Users’ concern about data costs
  - Difficulty recharging devices (unreliable electricity)
  - Shared phones (common in Africa)
  - Distrust of surveys

$^1$[https://data.worldbank.org/indicator/SE.ADT.LITR.ZS?end=2018&locations=ZG-1W-Z4-8S-Z7-ZJ&start=2018&view=bar](https://data.worldbank.org/indicator/SE.ADT.LITR.ZS?end=2018&locations=ZG-1W-Z4-8S-Z7-ZJ&start=2018&view=bar)

36

<!-- page 37 -->

# Text Message Interviews: Nonresponse Bias
## Hastings, 2017

* Participants in Gallup Daily Tracking poll, conducted by phone, asked if willing to receive survey questions by SMS from Gallup in the future
* Could refuse to authorize being sent text messages: *Nonconsent*
* Could consent to be texted and then refuse to participate in SMS survey when invited by text: *Noncooperation*
* Both non-consenters and non-cooperators differed from respondents in answers to several SMS questions
  * e.g., "yes" to registered to vote? Consent-nonconsent $\Delta = -6.61\%$; Cooperation-noncooperation $\Delta = 14.07\%$
* Take-away: obtaining consent imposes extra decision on sample members that can lead to non-response (over and above completion)

37

<!-- page 38 -->

# Text Interviews: Measurement Error (Satisficing)

**A: Rounding**
Numerical answers ending in 0 or 5

**B: Straightlining**
Respondents selecting same response option for at least 6 of 7 questions

* Asynchrony of texting allows Rs to carefully consider answers which can reduce satisficing

Source: Schober et al., 2015

<!-- page 39 -->

# Text Interviews: Measurement Error (Disclosure)

**C: Disclosure**
Number of most extreme (socially undesirable) answers

* Texting conveys few social cues, even when interviewer-administered; could increase disclosure

Source: Schober et al., 2015

<!-- page 40 -->

# Text Message Interviews: Disclosure of Sensitive Info and Modular Design

* West, et al. (2015) assigned *Rs* (in Nepal) to
1. Telephone interview
2. One session text message interview
3. Modular text design: one question per day
* More disclosure (marijuana use and depression) in text than voice but no overall difference between the two text modes
* However, *Rs* in modular (one *Q* per day) design found it “easier” than single, continuous session

<!-- page 41 -->

# Text Messaging as an Invitation and Interview Mode: Summary and Conclusions

* Texting an invitation to a web survey has so far produced higher response rates than an email invitation and fast completion of q'aire
* Texting as an Interview Mode:
  - Coverage Error: No difference between texters and non-texting mobile users on most demographic variables, but texters were younger and more educated than non-texting smartphone owners (in 2013)
  - Nonresponse: Response rate higher in text than voice at least when participants are pre-screened (Schober et al., 2015); some evidence of nonresponse bias due to consent to be texted

<!-- page 42 -->

# Text Messaging as an Invitation and Interview Mode: Summary and Conclusions (2)

* Texting as an Interview Mode (continued):
  - Measurement Error: Texting leads to less satisficing and more disclosure of sensitive information than voice interviews
  - Attributed to reduced time pressure (asynchrony) and increased social distance of *R* from interviewing agent
  - Fast completion of field work – seems to be due to very quick recruitment compared to voice (which can take days or weeks); may suggest well suited to measuring public's reaction to recent public events
* Is texting as an interview mode suitable for only brief q'aires?
