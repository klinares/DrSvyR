---
id: "jpsm/Fund_data_collection_SURV622/reading_notes"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lecture"
title: "reading_notes"
original: "Fund_data_collection_SURV622/reading_notes.pdf"
pages: 9
sha256: "515ea53c2cb7aeaf47b1759c39d6b91a0f9737b0655be8eeae31598dc1f9cc1a"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:01"
---

<!-- page 1 -->

1/13/25

**Kristin Olson. 2013. “Paradata for nonresponse adjustment,” Annals of the American Academy of Political and Social Science, 645(1): 142-170.**

This research article discusses the potential of paradata (data collected during the survey process) for nonresponse adjustment in surveys.

Key takeaways:

* Paradata can improve survey accuracy: By understanding why people don't participate in surveys, researchers can adjust their data to better represent the target population.
* Challenges in using paradata:
  * Data collection: Requires changes to existing systems, potentially increasing costs.
  * Data types: Feasible and useful types of paradata are still being explored.
  * Data analysis:
    * Concerns about how to best aggregate and analyze paradata.
    * Lack of standardized methods for using paradata in nonresponse adjustment models.
  * Data access: Limited public access to paradata hinders research and development of new adjustment techniques.
* Opportunities:
  * Innovation in paradata development: Exploring new types of paradata that can predict key survey variables.
  * Improved sample management systems: Capturing information systematically that was previously recorded informally.
  * Developing and testing new nonresponse adjustment models: Addressing the limitations of current methods.
  * Increased public access to paradata: Enabling broader research and user-driven weight creation.

In essence, the article highlights the promise of paradata in improving survey accuracy but emphasizes the need for further research and development to fully realize this potential.

<!-- page 2 -->

**Kristin Olson and Bryan Parkhurst. 2013. “Chapter 3: Collecting paradata for measurement error evaluations,” in Frauke Kreuter, ed., Improving Surveys with Paradata, John Wiley and Sons: Hoboken, NJ, 43-72.**

This chapter describes how to collect paradata for survey research. Here are the key steps involved:

* Identify the CAPI or CATI software you will use for your study and determine its built-in capacity to collect paradata (timing, keystroke, mouse movement).
    * If the software doesn't have this capacity, consider adding ad hoc programs or writing new ones.
    * Identify where and how the paradata files will be recorded for each respondent.
    * Develop procedures to export and store the files with unique file names.
* Decide whether to collect audio recordings for behavior coding and/or vocal characteristic analysis.
    * If so, identify if your CAPI or CATI software can record the interview. If not, you will need to purchase alternative software or a separate recording device.
    * Test the recording devices to ensure they have sufficient mic levels.
    * Identify where and how the audio files will be recorded for each respondent.
    * Develop procedures to export and store the files with unique file names.
    * If you plan to code the recordings, you will need to develop a coding scheme, hire and train coders, assess coding reliability, and reconcile inconsistencies.
    * If you plan to analyze vocal characteristics, you will need to identify software for conducting vocal analysis and split the audio files into appropriate units.
* Decide whether to collect interviewer evaluations.
    * Identify the constructs you want to evaluate and find existing questionnaires for interviewer evaluation.
    * Program the CAPI or CATI instrument to include questions for interviewers to answer at the end of relevant sections or the entire survey.
    * Export the interviewer evaluations and merge them with the main data set using masked interviewer IDs.

For web surveys, instead of interviewer evaluations, you can collect respondent-generated paradata through mouse clicks and keystrokes. Here are the steps to collect paradata for a web survey:

1. Identify the web survey software you will use and determine its built-in capacity to collect paradata (server-side or client-side).
2. If the software collects server-side paradata, identify where and how the files will be recorded and develop procedures to export and store the files with unique file names.
3. If you want to collect client-side paradata and the software doesn't have this capability, consider adding JavaScript. You may need to hire a programmer to do this.
4. Identify where and how the client-side paradata files will be recorded and develop procedures to export and store the files with unique file names.

<!-- page 3 -->

Once you have collected paradata, you will need to convert it into a usable format for analysis. This can be a challenging task, especially for paradata collected from web surveys. Here are some general steps involved in turning paradata into datasets:

1. Identify variable names, delimiters, and actions in the paradata text files.
2. Use statistical software or programming languages to create analytic variables based on the information you identified in step 1.
3. Parse the actions from the time at which the action occurred, the time it took for the action to occur, or the time between actions.

Overall, collecting and using paradata can be a complex process that requires careful planning and consideration of resources. However, paradata can be a valuable tool for survey researchers, as it can provide insights into how respondents answer questions and how interviewers administer surveys.

<!-- page 4 -->

**Keusch, F., & Conrad, F. G. (2022). Using Smartphones to capture and combine self-reports and passively measured behavior in social research. Journal of Survey Statistics and Methodology, 10(4), 863-885.**

* **Ecological Momentary Assessment** (EMA)
* Combining self-reported data and passively measured data collected via smartphones can be a valuable approach for social and behavioral research. There are five reasons why researchers might choose to combine these two types of data: verification, building composite measures, contextualizing, quantifying relationships, and triggering measurement. However, there are also challenges associated with this approach, such as nonparticipation, measurement error, and privacy concerns.
* Smartphones make it possible for researchers to collect self-reports as well as to passively measure behaviors and states with native sensors and the smartphone's operating system, both on a single device that accompanies many people throughout the day. This research synthesis brings structure to the rapidly expanding body of literature on the combined collection of self-reports and passive measurement using smartphones, pointing out how and why researchers have combined these two types of data and where more work is needed.
* We distinguish between five reasons why researchers might want to integrate the two data sources and how this has been helpful: (1) verification, for example, confirming start and end of passively detected trips, (2) contextualization, for example, asking about the purpose of a passively detected trip, (3) quantifying relation- ships, for example, quantifying the association between self-reported stress and passively measured sleep duration, (4) building composite measures, for example, measuring components of stress that participants are aware of through self-reports and those they are not through passively measured speech attributes, and (5) triggering measurement, for example, asking survey questions contingent on certain passively measured events or participant locations.
* Sources of error: (1) sensors are not perfectly accurate, (2) interpretation of sensor data requires inference beyond the actual measures, and (3) smartphone users may not comply with protocol when engaging in a study.

<!-- page 5 -->

**Stone, A. A., Schneider, S., & Smyth, J. M. (2023). Evaluation of pressing issues in ecological momentary assessment. Annual Review of Clinical Psychology, 19(1), 107-131.**

* EMA, key feature, short duration of reporting periods.
* The first perspective is the accessibility model of emotion articulated by Robinson & Clore (2002) that is often cited in support of using momentary reporting (e.g., Conner & Barrett 2012) to avoid recall bias. The model posits that when people have low accessibility to information in memory, they tend to use semantic memory or beliefs in formulating their recollection. Therefore, self-reports with relatively long recall periods and low accessibility will tend to be based on beliefs and implicit theories.
* Theories of survey responses (Tourangeau et al. 2000) argue that respondents sometimes misinterpret even well-formulated questions and that participants may “help” researchers by providing the answers they believe are being sought by the question.
* The main concern is that participants may report their judgments about experiences rather than providing information about the experiences in their natural states (thus distorting the information). Hurlburt and colleagues have developed the complex and lengthy Descriptive Experience Sampling interview, which comprises procedures intended to overcome this challenge.

<!-- page 6 -->

**Robert Groves and Brian Harris-Kojetin, eds. 2017. “Chapter 2: Statistical methods for combining multiple data sources,” in Federal Statistics, Multiple Data Sources and Privacy Protections, Next Steps, National Academies Press: Washington, DC, 15-44.**

This text discusses the use of multiple data sources to improve federal statistics.

* Improving Data Quality: The text outlines several ways combining data sources can enhance survey data, including evaluating data quality, adjusting for coverage errors, supplementing sampling frames, adding information, improving models, and even replacing survey questions with administrative data.
* Shifting Paradigm: The document argues for a new approach to statistical design and analysis that leverages these new data sources to improve timeliness, detail, efficiency, and cost-effectiveness.
* Record Linkage: A core method discussed is record linkage, which involves connecting records from different sources that belong to the same entity. This is done using common variables like Social Security number, name, address, date of birth, race, sex, etc. Record linkage can be deterministic (exact matches) or probabilistic (based on probabilities).
* Benefits of Record Linkage: The text provides several examples of how record linkage can be beneficial:
  * Enriching data by adding variables from other sources (e.g., linking health survey data with Medicare records).
  * Reducing survey length and respondent burden.
  * Increasing the number of records available for analysis (e.g., merging tumor registry data).
  * Validating survey responses and filling in missing data.
  * Improving sampling frames.
* Examples of Data Combination: The text mentions specific instances where data combination has been used, such as the Census Bureau exploring the use of tax information to replace income questions in the American Community Survey, and the National Center for Health Statistics replacing surveys with administrative data from the Centers for Medicare & Medicaid Services. It also mentions using commercial lists to improve sampling frames for teacher surveys.
* Imputation Challenges: Combining data through imputation (filling in missing values) is complex. It requires expertise and faces challenges like different respondent types, interview modes, survey context, question wording, and incomparability between sources (e.g., surveys vs. administrative records). Model assumptions about missing data mechanisms and predictive models must be thoroughly checked. Despite challenges, imputation offers advantages like complete datasets, leveraging variable relationships, and inferring beyond individual data sources.
* Modeling Techniques: Beyond record linkage and imputation, other modeling techniques exist. Small-area estimation combines survey statistics with administrative data. Bayesian hierarchical models can be used for small-area estimates, incorporating error structures and covariates. These models can combine survey and non-survey estimates, like crop yield estimation using farm surveys and satellite imagery. A coordinated approach to small-area estimation across agencies could be more efficient. Hierarchical models can also combine aggregated and individual-level data.
* Model Reliance and Validation: Combining data often relies heavily on models. Model misspecification is a risk. Therefore, transparency is crucial, including documentation of assumptions, model checking, and sensitivity analysis. The focus should be on using useful models, not necessarily perfect ones.

<!-- page 7 -->

* Research Needs: Several research areas are highlighted:
  * Record linkage quality and uncertainty propagation.
  * Identifying and addressing biases in different data sources.
  * Dealing with missing data from multiple sources.
  * Integrating data collected at different time frames (especially "big data").
  * Developing and applying machine learning methods.
  * Designing new data collection systems that leverage multiple sources from the start.
  * Ensuring the robustness of statistical systems against manipulation.
  * Addressing the challenges of using "big data" sources.
* Implementation Structure: The text calls for better communication and coordination of research projects related to combining data sources. A central entity is proposed to summarize and disseminate information about these projects. Access to data sources and partnerships between agencies, academia, and businesses are essential. Training for statistical staff in new skills (record linkage, machine learning, etc.) is also crucial. Development of algorithms and user-friendly software is needed. A multidisciplinary approach is recommended. Federal agencies should document their processes for combining and analyzing data and make that documentation publicly available.

<!-- page 8 -->

**Robert Groves and Brian Harris-Kojetin. 2017. “Chapter 5: Preserving privacy using technology from computer science, statistical methods, and administrative procedures,” in Federal Statistics, Multiple Data Sources and Privacy Protections, Next Steps, National Academies Press: Washington, DC, 79-107.**

This text discusses the challenges of protecting privacy when releasing statistical data from multiple sources. It explains that data analysts, even with good intentions, can inadvertently reveal private information through their queries and analyses. The text introduces the concept of a "query-answering mechanism" that adds noise to responses or alters data to protect privacy. It emphasizes the importance of using publicly known randomization techniques so that statisticians can account for the introduced errors.

The text then details two types of privacy attacks:

*   Reconstruction attacks: These aim to uncover sensitive information (like a genetic predisposition) for nearly everyone in a dataset by using multiple queries. The "fundamental law of information recovery" states that too many accurate queries can lead to a successful reconstruction attack.
*   Tracing attacks: These attempt to determine if a specific individual is part of a dataset. The text cites an example of genomic research where tracing attacks were used to identify individuals in studies.

The text reviews several inference control techniques used by statistical agencies:

*   Statistical disclosure limitation: This includes methods like aggregation, top/bottom coding, data swapping, adding noise, and creating synthetic data. However, these methods have weaknesses and can still be vulnerable.
*   De-identification: This involves modifying or removing identifying information, but it's not foolproof, as demonstrated by the re-identification of the governor of Massachusetts' medical records. The text mentions k-anonymity and other related concepts but notes that these syntactic conditions don't fully address the semantic problem of privacy.
*   Synthetic data: This involves creating artificial datasets based on models of the real data. While seemingly protective, the model parameters themselves can leak information, and the synthetic data's utility is limited by the model's scope.
*   Tiered access: This approach restricts data access based on sensitivity and potential harm. It involves procedural, technical, educational, economic, and legal controls throughout the data lifecycle. Different tiers have different requirements, from public use to restricted access with formal applications and data use agreements.

The overall message is that protecting privacy in statistical data release is complex. Traditional methods have limitations, and more sophisticated approaches like differential privacy are needed to balance data utility with individual privacy.

<!-- page 9 -->

**Alessandro Acquisti, Laura Brandimarte, and George Loewenstein. 2015. “Privacy and Human Behavior in the Age of Information,” Science 347(6221): 509-514.**

This article discusses the challenges of privacy in the information age. It argues that while data sharing can bring benefits, the potential for abuse is significant, threatening individual autonomy. The authors explore whether people can effectively manage their privacy in this complex landscape, reviewing research from social and behavioral sciences.

Three key themes emerge:

1. Uncertainty: People are often unsure about the trade-offs involved in sharing personal information. They may not know what data is collected, how it's used, or the potential consequences. This uncertainty is compounded by the fact that some privacy harms are intangible, and privacy itself often involves trade-offs (e.g., personalized offers vs. price discrimination). Even when aware of the consequences, people may be uncertain about their own privacy preferences, leading to the "privacy paradox" where stated concerns don't always align with behavior. The authors discuss explicit (direct questioning) vs. implicit (inferring from behavior) methods of assessing privacy valuation, noting the difficulty in accurately measuring how much people value privacy. They also highlight the countervailing motivation of self-disclosure and the desire to be public, which can be just as strong as the need for privacy.
2. Context-Dependence: Privacy preferences are highly context-dependent. The same person might be very concerned about privacy in one situation but not in another. This is because the boundaries between public and private are often unclear and depend on various factors like culture, relationships, and the specific situation. People look for cues in their environment to guide their behavior, but these cues can be misleading. For example, the presence of government regulation might increase trust, even if the actual level of protection is minimal. Other factors influencing privacy concerns include the design of websites, the behavior of others (e.g., through social norms or reciprocity), and past experiences. The authors also discuss how online environments blur the lines between public and private, making privacy management even more challenging.
3. Malleability: Privacy preferences can be influenced by external factors, often manipulated by entities that benefit from information disclosure. These entities understand the psychology of privacy and exploit it to encourage sharing. Examples include default settings (people tend to stick with them), confusing website designs, and creating a false sense of security. Trust is another factor that can be manipulated; simply having a privacy policy, even if unread, can create a feeling of protection. Control, paradoxically, can also lessen privacy concerns. The authors suggest that because individuals are often unaware of the influences on their privacy concerns, those who want information from them have a distinct advantage.

In summary, the article highlights the complexity of privacy in the digital age. People are often uncertain about privacy trade-offs, their preferences are highly context-dependent, and those preferences are malleable and subject to manipulation. This creates a challenging environment for individuals trying to protect their privacy.
