---
id: "jpsm/fund_data_coll_1_SURV621/notes_surv621"
source: "jpsm"
course: "SURV621"
course_title: "Fundamentals of Data Collection I"
doc_type: "lecture"
title: "notes_surv621"
original: "fund_data_coll_1_SURV621/notes_surv621.pdf"
pages: 16
sha256: "70b1627f0c7bb88ee7b550cc2659b7d8dea019162539df3b8413f0fb3a8f7a25"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:01"
---

<!-- page 1 -->

SURV621:
Midterm:

Times, show work, some will be multiple choice. Consult lecture notes. Be organized. Everything before Oct 8<sup>th</sup>. Make a summery of each paper, goal, design, finding.

Module 2
* Total error framework. Representation side, target sampling error. Probability sampling.
* When defining coverage error, they have two components: non-response rate and how different the covered population is to the uncovered population. How different respondents are to non-respondents.
    * Prob surveys every member has a known prob of being selected, and sampling bias is 0.
    * 

Module 3:
* measurement error, comprehension, retrieval, estimation/judgment, and recall.
* Recency effects
* cognitive interviews – pretesting protocol. Particularly important for new tool. Cog interview targets what goes on in people mind when they answer a question.

<!-- page 2 -->

Oct. 7, 2024 Lecture notes Reducing measurement error through questionnaire design.

* Questionnaire development:
  * determine purpose, mode, analysis plan, write and pre-test items, organize questionnaire.
* Cog interview – study how individuals’ mental process when answering a Q.
  * ID problems that emerge from respondents. Phrases, word meaning, recall issues, presuppositions?
  * Issues that can arise fall into the cognitive process.
* In cog interview for class, embed think-aloud probes.
  * During interview do not react to responses whether verbally or non.
  * Training interviewers, the protocol: be flexible when probing.
    * Can help respondent visualize, i.e., think about where you live and count the windows, how are you thinking about this.
  * Probes: concurrent, probe after Q. Proactive probes – researches actively probe but scripted in advance.
  * See slide 21 from week_05_cog_int for examples of probes.
  * Reactive probes: “You look puzzled, what are you thinking.”
  * Think about what was learned through probing and how can we modify the question.
  * Repeating the question is still considered a probe.

* Survey design:
  * measurement error sources, item bias, interview variance, tool/mode.
  * Goal for questionnaire, develop sound measures have construct validity, reliable, standard/comparable, practical to administer.
  * Validity – content validity Q measures what is intended to measure. Criterion validity correlation with other measures. Construct validity – correlation between intended measure and proxy.
  * Reliability - what proportion of observed variance is variation in the true score.
  * Standardization, are responses global, relevant to target pop.
  * Ease of admin. – minimize burden on respondent and interviewer.
* Judgment:
  * asking R to judge an event or attitude
  * behaviors of events breakdown into occurrence (did event happen), frequency, duration, elapsed time (how long ago did it happen), quantities.
  * Attitudes, favorability (bipolar response), strength, certainty, importance (unipolar)
* recognition vs recall
  * recognition (showing list) reduces omission, but probably over estimates.

<!-- page 3 -->

In class exercise:
1. The survey sponsor wants to quantify the economic costs to the public of serving on juries in the state judicial system. Develop questionnaire wording to measure how often respondents have been summoned for state jury duty, how this has affected them financially and the extent to which it is a burden. Decide what reference period makes the most sense for this question (or questions) and write the question(s) accordingly.

Re-write:

In the past 12 months, how many times have you served on a jury in the state of _____?

Number response in categories

In thinking about when you served as a juror in the past 12 months, how often did it impact your finances negatively?
Not at all, very much

When you were summoned for jury duty in the past 12 months, how much of a burden did it create for you?
Not at all, very much

<!-- page 4 -->

2<sup>nd</sup> part of class

2024-10-21

Guest presenter from NORC, slides included.

**Probability based web panel**

* Multipurpose probability panel, similar to longitudinal but is used by multiple customers. More frequent sampling. Various questions,.
    * NORC is creating best practices for this method.
    * Panels are asked to join, not just do a survey, and 2<sup>nd</sup> ask is empanelment/profiling by asking participants to initially do a demographic survey to enter a database.
    * There is also a relationship between the panelist and panels.
    * Panels require several weighting mechanisms, and replenish.
    * Panels age and change over time.
* How to build panels.
    * Maintenance and growth
        * How large is a panel. Typically, the size is overall but there are several non-response called back out (panelist backs out of panel after registering).
            * Active panel is those that have completed a survey in their panelist life-cycle.
            * Effective sample size, those that answer surveys, active in a per-defined time frame. This is the sample size we should be interested in.
        * Sampling options, address based sampling shift, b/c RDD now gets blocked and screened. Also shift to mix-mode.
        * Big data classifier sampler sample stratification, stratify and prioritize hard to reach population using big data models. Gets higher responses from small areas.
    * Non internet coverage, the digital divide is narrowing. Non-internet pop is difficult to fine, and are different from internet pop.
        * Providing device or connection can be a strategy to capture non-internet pop. However, those not on the internet are still unlikely to participate. Another limitation is the cost for device and training those that deliver the equipment.
        * Mixed mode approach (offline mode) potential mode effects.
    * Modality
        * There is also multi-mode recruitment (fliers, email, call, etc). Typically going from cheaper to more expensive contact.
    * Effort
        * ways to attract and maintain panelist. Contacting using recruitment packages with incentives. Various permutations of these approaches. Also include personalization messages.
            * There is a random selection of those that did not initially respond and there is a follow up.
                * NRFU – non response follow up
    * Empanelment requirements
        * Profiling
            * topics varying from health to ownership to be able to recruit from. These profile surveys can be given separately. Not all panelist complete profiling variables.
            * Some of these variables are dynamic, and have shelf life such as health status.
            * This information is also used during weighting.
    * Infrastructure

<!-- page 5 -->

*   
    *   
        *   Larger panels require complex infrastructures. There is also a lot of reaching out and three is a help center. Apps sometimes also have to be built. Or using AI as a help desk.
        *   Always think about how these improvements of communicating are annoying panelists.
    *   Panelist relationship
        *   How to keep them engaged and retain them. Involves communication through welcome packets, mailings, birthday greeting cards. There are also incentives such as bonus points. Mode of contact is important, after recruitment, typically this is through email.
        *   Demographic and profiles need to be refreshed periodically.
*   Response error in panels
    *   Response rate, most of the time only completed survey panelist are reported. Look for cumulative response rate = recruitment rate * profile rate * completion rate.
*   Overall representation – active vs effective panelist are different people. Effective are those in the completion response rate. Active panelist are those in the profile rate. Back out can be in the recruitment rate.
    *   Non-response types: drop outs, non-recruits, attrition
    *   measurement of nonresponse – backouts and attriters.
    *   Panelist honey moon period, last 3-6 months.
    *   NRFU helps to recruit hard to reach segments.
    *   Also important if these additional efforts produce differences in estimates.
    *   Mode measurement effects, while it improves representation, are there measurement effects?
        *   Selectional composition effects should expect when people pick different modes.
*   Panel conditioning, another source of measurement error, the change in a person’s survey responses that is influenced by their panel tenure and panel experiences.
    *   Think repeated exposures to questions leads to some bias.
    *   Changes their knowledge and attitudes, and no longer may represent the general population.
    *   This is not much of an issue for multipurpose panels.
*   Dealing with cheaters.
    *   Fraudulent, professional, or inattentive respondents. Looking into paradata, speeding, or data quality measures to identify them.

[https://www.norc.org/about/departments/center-for-panel-survey-sciences.html](https://www.norc.org/about/departments/center-for-panel-survey-sciences.html)

*   Big data classification is creating a probability estimate for recruitment using auxiliary data.

**Measurement Beyond Survey Responses**

*   Found data cannot answer research questions on their own, but must be repurposed.
*   Grooves 2011 blending survey and organic data framework.
*   AAPOR’s task force on Big data stated that it is useful for qualitative insights and monitoring trends, not accurate quantitative estimates.
*   With social data, there is an imaginary audience so the post reflects this more so than reality.

<!-- page 6 -->

**October 28, 2024 survey modes and effects**

* What sources for measurement error besides mode, the source is **respondent**. **Interviewer** is another source of error, called interviewer effects, and **instrument** effects, and mode **effects**.
  * Think of these four sources.
    * For respondent, think of age in terms of working memory, cognitive ability.
* Combination of medium and agent, how questions are delivered thought an interviewer or platform. Agent is who administers, such as interviewers. Other agents, such as chat bot are included.
* Possible modes, combining interviewer with acasi, mix of modes, not just multi modes.
  * If R is agent, mode is self-administered
  * If Int is agent, mode is int administered
  * If animated int, the R is the agent.
* Considerations for mode
  * mode needed for literacy survey. Consider mode for sensitive questions.
* CAPI is face-to-face.
  * Factors affecting responses, sending flayers before.
* IVR, interactive voice response. Outbound interviewer calls, asks R to volunteer, and switches R to IVR for sensitive question. Inbound, R initials call. Think surveys after a call.
  * There is touchtone and speech.
* Effects of mode on survey error.
  * Think of trade offs in design for coverage.
* ABS area base sampling, expensive and there is a time lag between constructing the list and surveying.
* Using student populations when it comes to questions.
* Mode warrants consideration on all sources of error.
* Surveys suffer from non-response more so in self-administer, but self-admin increases honest responding.
* Groves and Kahn, switch to telephone interviews. Lower response rate, but faster surveying.
* Robust effects, telephone interviews data quality comparable to F-T-F. Self admin increase disclosure to sensitive topics, web also.

<!-- page 7 -->

**November 4, 2024 web surveys**

* Response rate for web surveys 10-11% lower than other modes. These were through email invitation with a paper questionnaire.
* Measurement error, self admin. Computerized distinguishes from paper surveys.
  * Self admin advantage – best for sensitive questions. Can be completed anywhere
  * disadvantage – without interviewer, no clarification or probing, less guarantee R will complete the survey, computing environment out of the researchers’ control, risk for distraction.
* Web surveys are computerized and interactive.
  * Complex routing, skips structures, randomize question or response order, tailor questions for R, out of range values can be detected. Progress indicators can be included, and maybe helpful.
  * How will we leverage new technology to improve survey quality.
* User-centered design
  * focus on design for the user’s needs.
  * Consider efficiency, accuracy, satisfaction.
* Web design, look at slides.
* Grid question, higher reliability in multiple items. Sometimes have to spend time scrolling up.
* Qualtrics:
  * Assignment 3 steps.
    * program prelim version of instrument
    * brieflydescribe each component of your testing appraoch
      * question by question testing – look for issues with response selection and text.
      * scenario testing, imagine respondent scenario, now answer survey if logic works. Construct multiple scenarios of responses, and enter accordingly. Test all skips, include missing values and out of range values.
      * testing on different browser/devices
    * test and record comments in spreadsheet
    * revise instrument
      * (low, medium, high priority – which changes are urgent)

**November 11 2024 Mobile web surveys, and sms**

* App based surveys are costly to program for a one time survey. If the researcher has a multipurpose panel, maybe some respondents would like to take the survey via an app.
  * Optimizing web surveys for mobile devices has been the dominant strategy.
* The share of respondents using mobile devices has been increasing, from 55% to 90%. If the websurvey is not easily use on a mobile device, we might exclude people—coverage error.
  * Using smartphones for completing surveys has increased.
  * Goal design is to accommodate mobile devices.
* web survey is completed by a browser, while mobile survey is internet base through an app. Important to scale survey to screen size. Do not design to scroll side to side.
  * Optimization for mobile. At some point web survey becomes vertical. Worth keeping in mind that for scales, they are not longer on a grid for mobile devices.
  * Response error. Context of use is different for smartphone users, more likely to be around people and multitask than computers. No differences in satisficing or disclosure.
  * Respondents took longer when using a smart phone, the difference was larger between experienced smartphone users and none.
    * If it takes longer, it leads to breakoffs.

<!-- page 8 -->

* Just adapting to mobile is not good enough.
  * Explanation for lower response and breakoffs, cognitive burden and multitasking.
* Touch target size. Focus on target size and spacing. About 6mm for the touch target, the success rates level off. Important to know this so that there is less false positives, selecting the wrong one. Finger size actually matter for selecting targets. Coordination and dexterity also is a factor.
* Drop downs. Conserves screen space on mobile, different in types of mobile OS. Truncates string in IOS. Android pickers require more time and effort, depends on the question “select your state” probably easier than picking “what is the top issue.”
* Reading speed changes by font size at 6point and no more than 14pt because of scrolling, but varies by age.
  * Little difference in reading speed above 6 or 8 point font
  * 14 point or larger causes more scrolling and are not preferred
  * Ideal font size is 8-12pt.
* Voice input, respondent speaks to phone and device captures. Another option is a voice recording.
  * Dictation and voice recording study, item non reponse higher in voice recording, when answers are long, voice recording they give longer answers than text entry or dictation.
  * Increased item nonresponse
  * Longer responses
  * No effect on number of codeable answers
* There isn’t much gain than open text. So there may be more social mobility since mobile surveys are conducted around other people.
* Accordions, sections that expand, as soon as someone responds the next question opens the previous one closes.
* People want survey apps to have other purposes so that they don’t just install it, complete the survey, and delete it.
* Summary

<!-- page 9 -->

* web design must be accommodated for many different devices,
  * mobile optimization help but there are trade offs such as font and target size.
  * Testing is important on different smartphone devices with real users.

* SMS surveys – can either be actual questions but also inviting to a web survey.
  * There are limitations such as character length, except for chat apps. Interview happens a as a threaded conversation.
  * How is it better than voice interviewing? Text message stays on device, respondents they can come back to it where as a call, if respondent is busy they pass over the survey.
  * Less pressure to respond,
  * Good for rapid data collection, invitation maybe seems to be viewed quickly.
  * It's similar to RDD, but automated, RR is less than 1% because it is a cold contact.
  * Coverage error – some mobile owners do not text. To what extant do texters represent the population, or at least mobile users.

### Coverage of those who text among smartphone owners is practically universal* (even in 2014)
#### Smartphone activities by age

| Activity | 18-29 | 30-49 | 50+ |
| :--- | :--- | :--- | :--- |
| Text messaging | 100 | 98 | 92 |
| Internet use | 97 | 90 | 80 |
| Voice/video calls | 93 | 91 | 94 |
| Email | 91 | 87 | 87 |
| SNS | 91 | 77 | 55 |
| Video | 75 | 46 | 31 |
| Music | 64 | 39 | 21 |

*especially among younger people

  * Younger people are texting, and has some good coverage properties. However, they might be different demographically, we can be systematically excluding older adults by about 5.4% for those older than 34. For education, college grads or over represented by about 1.7%.
  * Schober et al 2015 compared 4 modes, 2 used text 1 were automated, the other version text sent by human. 2 versions of voice, IVR and human. 2 human, 2 computer.
    * Response rates were higher when there was a human involved.
    * RR could be due to Persistence of invitation in message list, numerous text messages, and ability to respond when convenient. However, all of the respondents signed up online before hand.
    * In other countries, the RR in African country varies widely, obstacles can include illiteracy (34% literacy rate), users concern with data use, difficulty charging, shared phones, distrust in surveys are all barriers. They are using CADI at geopoll instead of SMS. Still using text as invitation.
  * Obtaining consent can lead to non-response.

<!-- page 10 -->

# Text Messaging as an Interview Mode: Response Rates

* Higher Response Rate* for Text than voice (phone) interview (Schober et al., 2015)

Sample members already agreed to be in experiment but did not know interview mode Higher response rate in text could be due to (1) persistence of invitation in message list, (2) numerous indications that text message has arrived (awareness of invitation), (3) ability to respond when convenient, (4) more time to decide

* Do respondents respond differently in text
  * They are likely to round with voice over text.
  * Straighlining was less in text regardless of human or automated.
  * Asynchrony, text respondents aren’t rushed.

* Disclosure, more in text, and in this case if we removed the interviewer more disclosure. Why did text lead to more disclosure than voice, texting conveys fewer cues, respondents had to say their answer in IVR, maybe it has a feel of a person.

<!-- page 11 -->

* Modular design mode. The West et al 2015, broke survey down by day and texted. More disclosure in text over telephone. Respondents found that breaking survey by 1 question per day was much easier to take. Short sessions for mobile devices shows that evidence is mixed. Response quality is higher, yet probably of breaking off goes up per day.
* Summary:
  * texting, not a widely used method, but could become more useful in some research context. Thinking about data quality frames this method as a feasible method.
  * Measurement properties:
    * coverage error, does well in the US. Almost everyone texts, but there are differences in age and education.
    * Non-response, if per-screened, yields higher RR.
    * Less satisficing, more disclosure, and less time pressure to response, and less social distance.
* For polls, measuring changes in public opinion, feasible method.
* Is texting suitable for brief questionnaires?

**November 18 2024 Mixed Mode Surveys:**

* Mixed mode systems, another terminology,
  * Only surveys does not mean it is cheaper since we still pay for a back end front end development design.
* Mixed mode survey design, combine survey modes to increase RR, coverage, improve data quality. Responses can come from different modes. If data is comparable, they can be combined, ignoring differential model measurement error.
* Hypothesis testing: Hypothesis if more modes provided, more likely to respond.
* Empirical test operationalizes each component; all survey respondents, survey mode, propensity to participate, causal link such as covariation in the sample like demographics.
  * Validity to causal inference, potential inferential problems?
    * Covariation, one value changes as the other values in another variable change. There are also temporal order. Does it involved the theoretical variables? Is the covariation generalizable to other samples, settings and methods.
    * Traditional experimental design, four issues. Statistical conclusion validity, internal, construct, and external validity.
* Mixed-mode systems, goes beyond just combining modes, but also ties it using different methods of representation and measurement.

<!-- page 12 -->

# Contact Phase Mode Change

| Mixed-Mode Survey System | Rationale for Implementation Quality | Effect on Survey |
| :--- | :--- | :--- |
| **Contact Phase Mode Change** | | |
| **Advance notification in different mode than data collection** | • Correct sampling frame<br>• Raise response<br>• Enhance credibility/trust | • Reduce coverage and nonresponse error<br>• No threats to measurement if data collection single-mode |
| **Recruitment/ Screening/ Selection in different mode than data collection** | • Reduce cost<br>• Enhance efficiency<br>• Update/ expand contact information for main code | • Timeliness<br>• If pure screening, no threats to measurement<br>• If screening plus first part data collection in other mode potential mode effects on measurement |

---

# Contact Phase Mode Change

| *Mixed-Mode Survey System* | *Rationale for Implementation Quality* | *Effect on Survey* |
| :--- | :--- | :--- |
| **Recruitment/ Screening/ Selection in different mode than data collection** | • Reduce cost<br>• Enhance efficiency<br>• Update/ expand contact information for main code | • Timeliness<br>• If pure screening, no threats to measurement<br>• If screening plus first part data collection in other mode potential mode effects on measurement |

*   o Go beyond differences in modes, theorize on what mechanism explain the differences and what adjustment to make.
*   o If using 1 mode, no worry about differential measurement error assumption.
*   o Be able to describe which mixed mode is being used.
*   MM design
    *   o pre notification increases RR.
    *   o Notification, inviting to participate.
        *   ▪ Prenotice and invitation increased RR.
            *   • SMS prenotice, email invitation more effective than just email invitation or sms invitation.

<!-- page 13 -->

* For websurveys, responses are dropping, not as much as phone.
  * Before investing in a system, have to think about what is most cost effective with huge gains.
* Concurrent mixed mode design – one sample, cross sectional, some Rs provide responses in different modes.
  * Improves coverage
* Sequential mixed mode: one sample, cross sectional, effective and expensive, modes depending on previous contact attempts not successful. Increases RR.
* Parallel mixed mode: different samples, different modes.
* Pre-paid incentives give high RR.
* Active asking, and conceptualize what the survey is for R, given them options on how they want to be interviewed.
* Mode choice has led to less rounding, less straightlining, fewer breakoffs, greater satisfaction with interview, but leads to lower RR compared to assigned mode.
  * Eliminating alternative explanations for RR.
* Choosing mode can motivate Rs to participate, may help improve data quality if Rs are invited to participate to the survey model they indicated.
* Rs in non-prefered mode invest less effort in task by endorsing fewer options in check all that apply questions, and skipped open format Qs vs Rs in preferred mode.
* Commonly used mixed mode design to improve RR and reduce coverage error.
  * Prenotification and invitation improves RR
  * Mode choice is likely expected by sample members based on survey preference or forced.
* Statistical error model, we decide which observed auxiliary variables to include from a design standpoint.

<!-- page 14 -->

## Statistical Error Model (Lee et al., 2016)

* Let's consider a particular observation under the influence of these errors under a <u>stochastic mechanism</u>. Let $U$ be a population of size $N$, and the study goal be estimation of a mean $\mu$ for a population characteristic. For a unit $j$ in $U$, the measurement process generates an observed value operationalized through $y_j$ as:

$$y_{j,MEA} = m_j \mu_j$$

* Here measurement error, $m_j$, is a function of the measured variable itself ($y_j$) and a vector of parameters, say $\Psi_{MEA}$, in $m_j = f(y_j, \Psi_{MEA})$. $\Psi_{MEA}$ may include observed auxiliary variables, and the function $f(y_j, \Psi_{MEA})$ can take any form (for example, linear or logistic regression model, generalized additive model).

November 25 2024, Refusal Aversion Strategies

* Interviewer variance, how much are we influencing the variance, a stochastic mechanism we are creating. Interviewers at the cluster level are inflating the variance.
* Grooves and Couper A conceptual framework for survey participation.

**Non-controllable influencing factors**

**Company environment**
* Mood in associations
* Region
* Excessive research

**Establishment (and its representative)**
* Cost-benefit considerations
* Company structure/culture
* Characteristics of interviewee

**Controllable influencing factors**

**Study design**
* Subject/ seriousness
* Type of survey
* Length of questionnaire

**Interviewer**
* Socio-demographic characteristics
* Experience
* Change of interviewer

Interaction between establishment representative and interviewer

Decision to participate or to refuse the interview

* When comparing one design with another, think about the survey design, features, and their impact on coverage, sampling, and measurement error.
* Mode of administration. Apply in exam. Which error term when comparing different designs, think of total error framework.
* Gain cooperation, interviewers should stick as close to the script—standardized. If using neutral feedback, create similar probes to provide Rs with the same stimulus. Focus is to

<!-- page 15 -->

minimize measurement error by being flexible, tailored, conversational, dynamic, and minimize risk for nonresponse bias.
* Harmonizing data is a challenge.
* When interviewers express utterances (filler words), cooperation goes down. Overspeech leads to more refusals. Interviewer interruptions led to more scheduled callback.
* Greeting token, Hello vs Hi, agree to take survey was higher for hello. Interviewer identification first, 80% more likely for Rs to agree to the survey. Decline tends to happen during opening intro and study description, vs request to participation.
* For some people it takes seconds for them to decide if they are going to participate or not.
* If Rs asks about interview length, chances of participating goes down, followed by asking at least one question.
* Kish method focuses on random methods for selecting within household.

**December 2 2024 Interviews and interviewers:**

* Formal interviewing tends to have more DK responses vs personal.
* What kind of design features to reduce social desirability? Avoid having interviewer ask questions, and use a different mode.
    * In a regression model, how to treat missing?
* More rapport suppress disclosure of sensitive information b/c Rs favor impression management.
* Interviewers can affect interview through relationship, which can be built upon through nonverbal behaviors.
    * It makes very little difference between formal and informal interview style.
* Experimental treatment bundles together three techniques intended to improve quality of responses, compared to none of these in control group.
* **Bundle treatment:**
    * 1. Commitment
        * Verbal agreement by respondent to give accurate and complete information
    * 2. Instructions
        * Statements read by I for specific Qs: “ For the next few questions, you may need to take time to think carefully before you answer to be the most accurate .”
    * 3. Feedback
        * Both positive (“I see, this is the kind of exact answer we need.”) and negative (“You answered that quickly. Are there any days you might have overlooked?”)
* We get better responses if we target people’s memory with the bundle treatment. The trade off is that it takes longer, and burdens Rs. Increases survey cost.
* Interview effects, can change measurement error. Two types
    * Interviewer behavior, int-variance measured for individual question.
    * Interviewer fixed attributes, demographics, related to attributes of questions for instance gender of interviewer affects gender related Qs.
* Measuring int effects requires random assignment, otherwise difference could reflect truth.
    * We start to loose precision on the survey estimates.
* We need to capture the correlation between interviewers and the answer R elicits to a particular Q.

$$
\rho_{\text{int}} = \frac{\text{between}-\text{interviewer variance}}{\text{between}-\text{interviewer variance} + \text{within}-\text{interviewer variance}}
$$

* Between-interviewer variance is ideally zero
    * But never is!
    * Assumes random assignment of *I’wers* to *Rs*, , i.e., *interpenetrated* design
* Within-interviewer variance is (essentially) range of values for the variable (question) of interest; measures item’s ability to discriminate among *Rs*

<!-- page 16 -->

# Kish's formulation of $\rho_{\text{int}}$

$$
\rho_{int} = \frac{\left(\frac{V_a - V_b}{m}\right)}{\left(\frac{V_a - V_b}{m}\right) + V_b}
$$

* $V_a =$ between subjects mean square error in a one-way ANOVA with interviewers as the subjects
* $V_b =$ within subjects mean square error in ANOVA
* $m =$ total number of interviews conducted by the interviewer

* We can compute a design effect of interviewer. Goal, to keep work load small for interviewers.
* We can also use the square root of the design effect called the design factor: deff.
