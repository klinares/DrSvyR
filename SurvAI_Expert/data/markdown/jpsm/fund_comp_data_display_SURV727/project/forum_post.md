---
id: "jpsm/fund_comp_data_display_SURV727/project/forum_post"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "assignment"
title: "forum_post"
original: "fund_comp_data_display_SURV727/project/forum_post.pdf"
pages: 1
sha256: "2ddc2b06618696e3428543665914fc299813c67218afa16fc2bf847905efef07"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:55"
---

<!-- page 1 -->

**Text Analysis of the Conflict in Gaza Reveals the Civilian Impact**
**Kevin Linares**
[**Github repository**](#)

**Problem:**
On October 7, 2023, Hamas launched a significant attack on Israel, resulting in numerous casualties. The Israeli Defense Forces responded with airstrikes in Gaza, and currently exceeding 44,000 deaths. Reports indicate that a significant proportion of casualties in Gaza are women and children, though these figures are sourced from the Hamas Ministry of Health and lack verification.

**Opportunity:**
[Airwars](#), a UK-based non-profit organization, tracks civilian casualties from conflicts by analyzing social media and local news reports. To date, Airwars has documented 817 incidents in Gaza, capturing about 9,000 deaths. Each incident record includes date of occurrence, type of attack (drone, artillery, etc.) casualty breakdown by adult and children, and a contextual assessment often including geographic coordinates. **Given the comprehensive nature of Airwars' data, this study aims to explore the potential of open-source information to identify patterns in the targeting of Palestinian civilians in Gaza.**

**Current Project:**
We *scraped* and processed all available incident reports from the Airwars website, and storing in a publicly accessible *SQLite* database. To enrich the dataset, we reversed geocoded incident coordinates to query via the [Nominatim](#) *API* to return the type of location in which the attack took place (i.e., school, mosque, park, etc.). Additionally, to understand the general emotional tone in these assessments we used [*sentiment analysis*](#) to classify text into various emotional states. Finally, we *hierarchically clustered* incidents based on casualties and emotional scores to identify patterns in targeting and geographic associations with children and women casualties in Gaza.
