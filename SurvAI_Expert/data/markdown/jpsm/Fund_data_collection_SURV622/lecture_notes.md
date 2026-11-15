---
id: "jpsm/Fund_data_collection_SURV622/lecture_notes"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lecture"
title: "lecture_notes"
original: "Fund_data_collection_SURV622/lecture_notes.pdf"
pages: 7
sha256: "22b33b326862dc604c2863d3f2de94db651cad055c8c1b475b1b7b635b9a2cd3"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:01"
---

<!-- page 1 -->

1/13/25 Intro

* Paradata – data about the process by which the survey data were collected, on individual interviewer, or case level. Collected as a by-product such as what key strokes are clicked, which are the artifacts or product of the process of completing a survey.
* Often captured by software through web surveys. Or software that tracks calls, mails, emails.
  * Interviewers can also record data, such as no answer when contact is attempted.
* Types of paradata
  * In CAT/PI interviewer characteristics can be paradata.
    * Records of letters and emails sent can be recorded. This are called contact records.
  * Audit trails, characteristics of interview such as length time of day, comments entered.
  * Audio recordings can be used to measure quality of interview. Measure external distractions and assess vocal properties of interviewers.
  * Interviewer observations about the interview, examples such as “was there a bathroom in the neighborhood” this would be filled out by interviewer.
    * During elections, were people with political signs more likely to participate.
  * Interviewer observations to help set the neighborhood context such as upkeep of yards, presence of graffiti, single family home, presence of children, non-English speakers.
  * Examples in web surveys, type of device used to take survey. Response time, navigation, OS.
* Uses for paradata
  * improving response rates – contact rates by time of day to optimize contact
  * inform response design strategies, paying attention to which cases are underrepresented.
  * Improving nonresponse adjustments, may provide information about who did not respond.
  * Reducing representation error, driving contact methods or design of instrument.
* Paradata for nonresponse adjustment, nr=non responders
  * Nonresponse bias depends on two things:
    * Level of nonresponse
    * Differences between respondents and nonrespondents:

$$B(\bar{y}_r) = \bar{y}_r - \bar{y}_t = \left(\frac{n_{nr}}{n}\right)(\bar{y}_r - \bar{y}_{nr})$$

  * variables are known for both groups, and probability of response is correlated and correlated with the variable of interest. Has to have a relationship with the response variable and the mean response rate.
* Limitations of paradata
  * hard to find observations in paradata that are related to the response of interest. Think about what paradata can be observed that are related to survey.

* Paradata measurement error (ME)
  * Response times related to ME, short responses can be linked to acquiescence where respondent are agreeable, weak satisficing.
    * Can also indicate fluency
  * Long response time, can indicate uncertainty, ambivalence, self-editing. Also associated with DK responses.
    * Can also be thoughtful responding.

<!-- page 2 -->

* Response time might be possible to flag items, or interviewers that are slower or faster than the expectation.
* Respondent speech, para linguistic responses like utterances, can identify difficult response tasks such as self-rated health. The interaction between interviewer and respondent can be informative. Problematic speech indicated complicated health circumstances.
* Visual behaviors predicting reliability of answers
    * facial expression, head movement, gaze aversion which can indicate cognitive thinking.
        * Verbal information, disfluencies are behavioral indicators of a respondent's response process, speech disfluencies include hesitations or repetitions,
        * respondents produced more disfluencies on the phone than FTF, b/c respondent cannot see interviewer's expressions but only hear them.
            * More disfluencies in conversational interviews than structured interviews.
            * More likely to change answer, suggest disfluencies reflect response difficulty.
        * Visual
            * averted gaze, more in conversational interview perhaps to prompt help.
            * Gaze aversion reflects comprehension difficulty.
        * Gaze aversion works like disfluencies.
* Inactivity can indicate difficulty and trigger help, and when respondents volunteers clarification after being inactive improved response accuracy.
    * Makes more of a difference for complicated (ambiguous) questions than straightforward.
* Cyberparada: Mouse movements can indicate that Rs are struggling. Horowitz studied mouse hoovering along with vertical tracking which is when the cursor follows the eye from top to bottom.
    * Mouse movement predicted difficulty in response task. Hoover, marker (anchoring cursor), regressive (moving back and forth from choices) predicted difficulty. These approximated eye movements.
    * Multitasking and web surveys – leaving the browser (focus out of events) or timing out the browser.
        * Found that multitasking was prevalent, focus out related to item non-response. Not related to straightlining.
    * Using response time to slow down speeders, alerting Rs to being monitored stopped speeding.

**1/27/25 Passive and situated data collection**

* Retrospective survey, asking about the past. Insitu is about asking in the present.
* Limits of self-report
    * people forget, measurement error, and not informative about the moment.
        * Recall error – lag between occurrence of event and administration of Q.
            * Reducing reference period helps. Time diaries for instance as it eliminates lag. Event these are not questions in the moment, because people report their typical behaviors, routines.
    * Context, question order affects, order affects. Little is known about R's internal state and social context at the time of measurement and how it impacts their response.
    * Granularity of measurement – relevant events can occur between measurement occasion/waves.

<!-- page 3 -->

* **Ecological Momentary Assessment** (EMA) also AKA experience sampling method (ESM) direct questions about current state from Rs.
    * Ecological, data is collected in real world environment.
    * Momentary - current subjective state (stress, emotion)
        * to avoid or reduce ME
    * assessment – repeated measures
        * measurement frequency adequately represents states or events of interest.
    * Depending on what is being monitored, measure frequency is based on what is needed to observe enough times a behavior of interest.
    * Time based, for blood pressure, maybe 4 measures per day.
        * Intervals can be fixed (every 4 hours), random,
        * event based, when Rs maybe enters a geofence
            * limitation, Rs may not answer questions right away because they are in the process of a behavior, and when they do report on a behavior it could be later and there is measurement error.
    * Quality of EMA data
        * there is usual discrepancy between in the moment assessment and accurate recall. For longer events (think protests) people may enter different subjective states, and Rs can re-classify their responses, or they are fluid over a long event. Non-compliance leads to unit non-response.
    * EMA shown to predict theoretically related outcome better than global recall measure.
        * Recall is better predictor of subsequent behavior than EMA.
    * Do EMA report about the moment, or in general?
        * They can do better if Rs are trained to do this.
    * Reactivity, refers to change in behavior as a result of its being measured, studies show this does not necessarily change their behaviors.
* Passive measurement
    * Sensor measurement think phone gps, accelerometer, that are passive or indirect. To complement EMS.
        * Data are primitive that need to be aggregated and requires processing and matching to events or states. They are also not made to be used for making inferences from, initially.
    * Passive measurement, best practices is unknown as this is new. Studies showing social measurement are primarily showing feasibility.
        * Indirect measures still such as heart rate for a proxy to stress. Or presidential approval not measurable with sensors.
        * Phones assumed to belong to one owner.
    * Coverage error, no smartphone, no participation. Consent is difficult to get for reasons of intrusiveness, privacy, ability of features.
    * Measurement error
        * if sensor picks up quietness and darkness it could be that the phone was left somewhere in a bag, rather than the Rs is sleeping.
            * Phones could be left somewhere else to hide undesirable behaviors. Non-compliance, turning off phone.
        * Cost, passive data can be expensive due to app development, it infrastructure, data preparation and analytics.
        * Implications of privacy, continuous monitoring or high frequency measurement seems intrusive.
            * Steps to minimize risk, perhaps not collecting the context of conversation, but only the tone gets recorded.

<!-- page 4 -->

* We don’t know exactly what time we slept, and there might be a discrepancy between passive measures and self-report. This goes down when people are aware that they are being monitored. Weekdays were more accurate when people stick closer to schedules.
* Bring your own device, vs distribute. The former needs an app or share data (I.e, fitbit). But to standardize, the device should be distributed but is cost dependent.
* People are willing to share their phone paradata.
* Case study, operational aspects.
  * RQ to research design, and how is it implemented?
    * How will data be link,
    * ethical concerns
    * data security
    * how data will be monitored
    * storing data
    * equipment needed
    * resources needed (developers, data scientist)
  * daily experience and well being study
    * Hyp, increased social engagement $\rightarrow$ higher physical activity and better health/cognitive status.
    * Sample: Older adults.
    * There are research based devices, respondent can’t modify like consumer grade device.
    * Behavior change is higher when device is provided.
      * All of us study.
  * Think about user centered designs.

[https://www.ukbiobank.ac.uk/](https://www.ukbiobank.ac.uk/)

-Who is the study population? UK Biobank recruited 500,000 people aged between 40-69 years registered with the NHS, and invited to participate.

They have undergone a wide range of physical measures, provided information on their lifestyle and medical history, donated blood, urine and saliva samples for future analysis and agreed to have their health followed up through linkage to their health-related records.

– How is/was the wearable data obtained? Wrist worn activity monitor for collecting physical activity.

– How is consent obtained? Through a consent form by mail

– What are some potential sources of error? Coverage error in terms of people that do not wish to participate are likely to opt out, and those that want to participate are more likely to volunteer to participate in this study. Missingness, incorrect values, or duplicates.

– What data are released? UK biobank data: Genome sequence for the sample, protein data, brain imaging, questionnaire data on well being and mental health, record linkage such as vaccine history, inpatient data, and physical activity from accelerometers. Data release in different years.

– What role might there be for EMA? UK BioBank: EMA can play a significant role in real-time measures of health behaviors. For instance, capturing daily fluctuation in mood and stress related to sleep quality or physical activity. It may also provide contextual information about environmental factors or social interactions of specific events.

<!-- page 5 -->

– What is a research question that can be answered using the wearable data that cannot be answered using only self-reported data?

UK BioBank: What is the association between objectively measured sleep duration and the risk of developing cardiovascular disease? But like we discussed, there can be issues with the observed measure as well.

**February 3 2025 Record Linkage**

* Applications for linkage, sample development, estimate under-coverage or augment survey data for validation purposes.
  * Impute missingness, correct information from records, add auxiliary variables.
  * Building sample frames
    * area probability sample samples divided land.
    * Capture recapture estimates, sort of like hidden population.
  * Using admin data to augment survey data
* Pre-processing
  * First critical step.
* Types of record linkage
  * deterministic matching.
    * names are not good at matching deterministic.
      * Deterministic works when there is a identifier, like an id.
  * Probabilistic match increases false positive, most common approach and needs multiple identifiers.
  * Statistical matching, data fusion, if data 1 connects on x and y, and data 2 on x and z, we can join through overlap. We can impute values of z on data 1.
* Probabilistic matching
  * Fellegi – sunter linkage model (see slide 44 lecture 3)

February 10 2025
* HW 3:
  * 1 a and b
    * we don’t know what proportion of the population is represented by each group (case and controls) so we can’t combine the estimate from the two groups.
  * 1c false, $E\{a/a+b\}$ not equal to $A/A+B$
  * 1.d false, same $E\{c/c+d\} \ne C/C+d$
  * 1.e false, if the data in both group was small it could be true but it is not and the RR is not close to the OR.
  * 1f

* logistic regression
  * coefficients are called log odds. They are odds once exponentiation.
    * Beta interpretation, 1 unit increase in $x_{ij}$ with all other Xs constant increase the log odds of the success in the outcome.

<!-- page 6 -->

* Odds, in crease in the odds ratio resulting from a $1$ unit increase in $x_{ij}$ with all other constants.
    * Reference vs effect/sum coding
        * having a reference group.
        * Sum/effect coding, uses contrast for comparison. The coefficients must sum to $0$.

**February 10 2025 Record linkage**

* Record Linkage
    * conceptual framework

# Addressing Bias

* Possible steps to take:
    * Consider how the pre-processing is done. Can we address issues before they arise?
    * Check accuracy/precision/metric of choice for different subgroups. What is the match rate?
    * Check match rate according to blocking variable. Does the match rate differ significantly? If so, why? You don't expect them all to e the same, but make sure there isn't a systematic issue.
* Note: We are not necessarily checking for universally good match rates.

* Privacy and confidentiality
    * Most data collected by companies, not government.
        * So who owns our data?
        * How do we share the collected information?
            * Challenge, data is collected for one purpose and used for another.
                * Data is also out of date as soon as packaged and deployed.
    * Define privacy, the rights that individuals have to keep information about themselves private.
    * Confidentiality, duty of those that have collected information about others to protest it.
        * Threats: data security and inferential disclosure.
            * Data security – statistical agencies limit data access, authorize access, maintain logs, view data in secured systems, require passwords, require annual training.
    * Disclosure
        * identity – when individual can be ID from the leaked data
        * attribute – when confidential information is revealed and can be used to ID individual.
        * Residual – released info can be used to combined obtain confidential data.
    * Suppress values, adding noise, top coding values, rounding, data shuffling.
    * Risk assessment -
        * determine if variables put respondents at risk. Determine which variables put respondents at risk, such as those with small samples.

<!-- page 7 -->

**April 14, 2025 causal inferences, experiments**

* Logic of causal inference
  * Hyp: a prediction about the relationship between a predictor and an outcome. This is predetermined.


**April 21, 2025 Evaluating Measurement Quality**
* True value is usually unknown.
* 

The MIT article provided me with not only the context into Gen-AI, but also led me to consider plausible risks associated with GANs. The question I am grappling with is; how does the intrinsic adversarial mechanism of GANs, designed to produce realistic content, directly enable the creation of convincing deepfakes potent enough to drive disinformation campaigns threatening national intelligence and societal stability? Grappling with this issue underscores the profound ethical responsibility that accompanies understanding Gen-AI.
