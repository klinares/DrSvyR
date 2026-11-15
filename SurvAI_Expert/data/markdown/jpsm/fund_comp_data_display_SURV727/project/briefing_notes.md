---
id: "jpsm/fund_comp_data_display_SURV727/project/briefing_notes"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "assignment"
title: "briefing_notes"
original: "fund_comp_data_display_SURV727/project/briefing_notes.pdf"
pages: 2
sha256: "4da1ef0d72880bd2db7bbd9f986e6742d34c7d5f48f44fd278d08db9b1117ba4"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:55"
---

<!-- page 1 -->

Briefing:

* **Introduction:**
  * Good afternoon, my name is Kevin Linares and today I will be walking you through my project which centers on the Israel-Palestine conflict in Gaza. I will first address the current problem assessing civilian casualties, followed by a summary on relevant found data, and my methodology for analyzing the current problem.
* **Israel-Hamas conflict**
  * The Gaza Strip is a very narrow coastal territory that measures 25 miles long and part of the Palestinian, yet it is one of the most densely populated territories in the world with about 2.3 million inhabitants governed by the militant group, Hamas
    * To give you an idea of how small it is, Gaza is the length between DC and Baltimore, or U of MI and the airport in Detroit.
  * Last October, Hamas initiated a surprise attack on Israel, causing significant loss of life and taking hundreds of civilians hostage. The Israeli Defense Force has retaliated with targeted airstrikes in the Gaza Strip.
  * The Hamas Ministry of Health estimates over 44,000 deaths and claims that children and women are being disproportionately killed; however, these figures cannot be confirmed by external sources as most humanitarian groups have left the region.
  * Therefore, I searched for open-source data to understand the conflict's impact on civilian populations, especially children.
* **Methodology**
  * In my quest for open source data, the only source I found was Airwars, which tracks civilian casualties from conflicts and wars. Airwars scrapes from social media and local news outlets reporting on casualties and determine if these are related to a conflict. If they are, these reports are translated to English, standardized, and archived on their website.
  * Airwars defines each attack as a separate event, called an incident, and I scraped every published web URL resulting in almost 820 Incidents that contain about 9,000 deaths. On the right is an example of a web URL containing information of one incident.
    * I parsed each web URL for information such as the type of attack, casualty count and breakdown by adult and child, and the date of attack. Additionally, as can be seen in this graphic, there is a section called assessment which contains a description of the event written in a journalistic format. Sometimes, these assessments contain geographic coordinates of where the attack occurred.
    * All of this data is loaded into a SQLite database, which is also stored in the github repo.
  * In order to enrich this found data, I used the geographic coordinates to reverse geo-code, meaning that when all you have are coordinates, using the Nominatim API, you can submit a query and bring back information on the location such as the address, and type of location (school, mosque, hospital).
    * I was interested in exploring the types of target spaces so this is the information I recorded into the database.
  * The assessment text also lend itself to exploring the sentiment, or emotional tone, or each event over time. I explore 6 emotion scores using a text classification model from the hugging face repository.
  * The intention of this project is to capture clusters of incidents that may point to patterns of children or women being targeted by the airstrikes. I propose a hierarchical model to cluster incidents by using coordinates and non-spatial parameters such as the number of deaths and injured, and sentiment scores.
* **Results, casualty and sentiment.**

<!-- page 2 -->

* Of the approximately 9,000 deaths reported in this database, about 32% were children and 19% women. This is no surprise considering that 47% of the population are children. Once I adjusted for population size, through poststratifying mortality rates, for children the percent killed climbed to 43% and women dropped to 15%, suggesting that children in Gaza are in deed at risk for becoming a casualty of this conflict.
  * Turning to our sentiment analysis, we see from the graphic that negative emotions are prominent, and given that these assessments are about people dying this did not come as a surprise but it shows that the model is doing what it is suppose to do with these texts.
* **Results clustering**
  * I settled on a 3 cluster solution.
  * On the left are averages of the indicators that went into the clustering model, as well as information I got from the reverse-geocoding which I classified into whether the incident occurred at a school, hospital, mosque, or refugee camp.
  * The spatial overlap of Clusters 2 and 3, suggest that the IDF may not be targeting children and women, but unfortunately these airstrikes have unintended consequences for children given their proportion of the population.
