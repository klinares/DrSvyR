---
id: "jpsm/fund_comp_data_display_SURV727/project/gaze_incident_proposal"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "assignment"
title: "gaze_incident_proposal"
original: "fund_comp_data_display_SURV727/project/gaze_incident_proposal.pdf"
pages: 1
sha256: "4d0df87aa1db93c4d3f2795f06da84e80cfab76c337e79228ea2cda6b1159752"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:55"
---

<!-- page 1 -->

**Social Media Analysis of Conflict in Gaza Reveals Crumbling Infrastructure, High Death Toll**

***The ongoing Gaza-Israel conflict is likely to persist in 2025 threatening to destabilize the region—while affecting the well being of children and women—and the strategic utilization of open-source data can empower policymakers to mitigate humanitarian challenges in the region.***
Gaza’s death toll estimates at over 43,000, with children and women representing a sizable proportion, as reported by the Hamas’ Ministry of Health (MoH), yet it cannot be corroborated by outside organizations. Airwars, an NGO, has scrapped social media platforms since October 2023 from users posting details about the death of friends, family, and neighbors. We aim to use the Airwars’ Gaza conflict tracker to assess to what extent can open-source data be used to identify patterns in the targeting of civilian infrastructure as well as approximate official casualty estimates?

* Our methodology consists of scrapping incident reports from the Airwars website containing information about civilian casualties. We intend to derive from this data a casualty rate for children and women to explore how it approximates official MoH estimates.
* Airwars data also contain summaries describing in detail the incidents. We leverage huggingface to examine changes in the emotional tone of these summaries and couple them with the children and women casualty rate to provide more context into these estimates.
* Coordinates of incidents are sometimes provided, and we use this information to submit queries to the openstreetmap api to return additional information about what these locations were (i.e., schools, mosques, government buildings, etc). This information will allow us to explore what parts of Gaza’s infrastructure has endured the most destruction, through static map plots or interactive map visuals with the ability to filter through the types of locations.
* We enrich the Airwars database by joining the MoH casualty daily counts, which we plot with our casualty estimate to explore the discrepancy. We also join to the Airwars database the Armed Conflict Location and Event Data (ACLED) containing characteristics of Israel’s operations to explore if the incidents in Airwars correspond with the Israeli operations in Gaza reported in ACLED, and this will be used as as a validation check of our data.

**Appendix. Details on the data used for this project.**
Since the beginning of the war in October $7^{\text{th}}$, 2023, <u>Airwars</u> has monitored open source civilian harm incidents in Gaza. Incident is defined as an explosive weapon or ground battle operation that produced civilian casualties or harm. Civilian status of victims is assumed unless there is information determining their militant status. Data is derived from tweets or Facebook postings, translated from Arabic-to-English and when names are provided they are counted as a casualty. These names are corroborated with the Hamas MoH when they are released. All data is presented on their website, and each incident has its own web-page.

* The scrapped data resulted in almost 800 unique events stored across four tables in a SQLite database. The first table contains incident metadata (e.g., unique id, incident date, web-page URL). The second table stores the specific incident information such as the number of deaths, breakdown of deaths (children, adults), type of attack, and cause of death. The third table includes incident coordinates and results from OSM, while the last table stores incident summaries and sentiment scores for seven emotional states. These tables relate to each other through the unique incident identification numbers provided by Airwars.
* <u>Palestine Dataset</u> published daily Gaza casualty counts in a downloadable .csv file that they take from the Hamas MoH; however, they do not make a distinction whether a casualty was a civilian or militant so their numbers should be higher than what we derive from Airwars.
  * Note. Confidence is low to moderate since the data comes from the Hamas MoH.
* <u>ACLED</u> tracks conflict events around the world, and here we use the Israel Defense Force airstrikes and ground operations in Gaza since October 2023. The data is provided in a downloadable .csv containing date and type of conflict and the actors involved.
* Both of these external data source and the Airwars incidents are aggregated at the daily level so that we can join them together.
