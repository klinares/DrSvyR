---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_6"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 6.pdf"
pages: 12
sha256: "62e3b982754ea5e74f32c5c9634c9f44429377602d6deba9e4e45b430d0cc80f"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:29:16"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference
## Chapter 6: Outcome Rates

Sunghee Lee

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 1 / 12

<!-- page 2 -->

# Use of Outcome Rates

* Outcome rates, such as the percent of sample units refusing to participate in a survey, generally have three uses.
  1. Measure study performance. e.g., what proportion of the sample that resulted in a completed interview.
  2. Inflate a calculated sample size for loss of sample units. For example, a survey statistician determines the number of sample units needed to detect a three percentage point difference in the estimates for males and females for a specified size and power of a test.
  3. Can be incorporated into the design weights as adjustment factors to create final analysis weights.

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 2 / 12

<!-- page 3 -->

# Disposition Codes

- Numeric codes that describe current or final data collection status of each sample unit
- AAPOR has a list of recommended disposition codes; however, codes are generally specific to each data collection agency.
- AAPOR Standard Definition: `https://aapor.org/wp-content/uploads/2024/03/Standards-Definitions-10th-edition.pdf`

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 6 $\quad$ 3 / 12

<!-- page 4 -->

# Disposition Codes: CDC’s BRFSS - 1

2020 Behavioral Risk Factor Surveillance System (BRFSS) Outcome Rates:
`https://www.cdc.gov/brfss/annual_data/2020/pdf/2020-sdqr-508.pdf`

**Table 2.**
2020 Disposition Codes for Landline Telephones and Cellular Telephones

| Category | Code | Description |
| :--- | :---: | :---: |
| Interviewed (1000-level codes) | 1100 | Completed interview |
| | 1200 | Partially completed interview |
| **Eligible, Non-Interview (2000 level codes)** | 2111 | Household level refusal (used for landline only) |
| | 2112 | Selected respondent refusal |
| | 2120 | Break off/termination within questionnaire |
| | 2210 | Selected respondent never available |
| | 2320 | Selected respondent physically or mentally unable to complete interview |
| | 2330 | Language barrier of selected respondent |

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 4 / 12

<!-- page 5 -->

# Disposition Codes: CDC’s BRFSS - 2

Behavioral Risk Factor Surveillance System (BRFSS) Outcome Rates:
https://www.cdc.gov/brfss/annual_data/2020/pdf/2020-sdqr-508.pdf

**Table 2.**
2020 Disposition Codes for Landline Telephones and Cellular Telephones

| Category | Code | Description |
| :--- | :---: | :--- |
| **Unknown Eligibility** | 3100 | Unknown if housing unit |
| | 3130 | No answer |
| | 3140 | Answering device, unknown whether eligible |
| | 3150 | Telecommunication barrier (i.e. call blocking) |
| | 3200 | Household, not known if respondent eligible |
| | 3322 | Physical or mental impairment (household level) |
| | 3330 | Language barrier (household level) |
| | 3700 | On never-call list |
| **Not Eligible** | 4100 | Out of sample |
| | 4200 | Fax/data/modem |
| | 4300 | Nonworking/disconnected number |
| | 4400 | Technological barrier<br>(i.e., fast busy, phone circuit barriers) |
| | 4430 | Call forwarding/pager |
| | 4460 | Landline telephone number<br>(used for cellular telephone only) |
| | 4500 | Non-residence/business |
| | 4900 | Miscellaneous, non-eligible |

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 5 / 12

<!-- page 6 -->

# Study Rates

There are several rates defined by AAPOR.

* Location
* Contact
* Eligibility
* Cooperation
* Response

Formulas in VDK Chapter 6.2

* $RR1 = \frac{I}{I + P + R + NC + O + U}$
* $RR2 = \frac{I + P}{I + P + R + NC + O + U}$

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 6 / 12

<!-- page 7 -->

# Study Rates & Eligibility

**Table 6.2:** Disposition code categories used in performance rate calculation

| Symbol in study rates | Category | Study eligibility |
| :--- | :--- | :--- |
| $I$ | Complete interview | *Eligible* |
| $P$ | Partially complete interview | *Eligible* |
| $R$ | Refusal/break-off | *Eligible* |
| $NC$ | Noncontact | *Eligible* |
| $U$ | Unknown study eligibility | *Unknown* |
| $NE$ | Not eligible | *Ineligible* |
| $O$ | Other | *Eligible* |

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 7 / 12

<!-- page 8 -->

# Use Rates to Adjust Initial Sample Sizes

- Decide on desired final sample size of respondents
- Make your best guesstimates about loss rates at different stages of data collection
  Having best-case and worst-case scenarios is advisable
- Set up a spreadsheet that will calculate the required initial sample size and show how much the sample is reduced for each kind of loss

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 8 / 12

<!-- page 9 -->

# Inflating Sample Sizes for Losses

**Table 6.6:** Example of inflating target interviews for sample loss

| | |
| :--- | :--- |
| **Target interviews** | **200** |
| *Cooperation rate* | *0.7–0.75* |
| **Number of eligibles** | **267–286** |
| *Eligibility rate* | *0.8–0.85* |
| **Number screened** | **314–357** |
| *Screening rate* | *0.7–0.82* |
| **Number contacted** | **383–510** |
| *Contact rate* | *0.92–0.95* |
| **Occupied HUs** | **403–555** |
| *Occupied HU rate* | *0.95–0.97* |
| **Sample addresses** | **415–584** |

Set up a spreadsheet with anticipated outcome rates. Plug in Target Interviews for automatic computation of initial sample size.

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 9 / 12

<!-- page 10 -->

# Replicates - 1

* Randomly subdivide the full sample into data collection subsamples (under a "worst case scenario") called replicates
* Release only the number of replicates necessary to meet the study goals
* Easy example
  * *srswor* of 500 members of a professional association is selected with the goal being to obtain 100 completed questionnaires (completes).
  * Divide the 500 randomly into 10 replicates of size 50.
  * Initially, release first three replicates
  * If necessary, additional replicates are released to obtain the desired 100 completes.
* Replicates do not need to contain same number of cases. However, having equal-sized replicates is convenient and makes accounting easier.

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 10 / 12

<!-- page 11 -->

# Replicates - 2

- If replicates are randomly constructed, deciding to withhold any replicate does not negate the randomness of the sample; weights are adjusted to reflect only released replicates.
- However, once a replicate has been released, all cases in that replicate must be worked and be given a disposition code. Alternatively, the cases could be worked in a random order. Here, data collection could be stopped partway through a replicate, but this is impractical.
- Creating replicates in advance is much easier than selecting an initial sample and then attempting to add to it later, depending on the sample design.
  - Adding to a simple random sample by selecting another *srs* from the initial non-sample units is legitimate.
  - But, if the initial sample is selected with probabilities proportional to size (*pps*), selecting a supplemental sample in such a way that the overall sample is *pps* is not straightforward.

Sunghee Lee (U of Michigan) Prac Tools Ch. 6 11 / 12

<!-- page 12 -->

# Rules of Thumb for Costs

* Having some rules-of-thumb for time required for different tasks is useful when estimating costs
* Estimate hours for tasks then convert to \$
* Telephone survey example
  * Interviewers spend time on non-interview tasks (training, filling out timesheets, unproductive calls, etc.)
  * Total interviewer hours = (no. of intvs) $\times$ (time to do intv) $\times$ (factor to account for administrative time)
  * No. of staff needed = (total no. of intv hours) / (weeks in data collection period) / (average no. of hours intvrs work per week)
  * Supervisory hours = 15 or 20% of interviewer hours
  * Management and facilities costs
  * Overhead (indirect) costs: cost of staff benefits; organizations usually use a percentage of direct costs

Sunghee Lee (U of Michigan) $\quad$ Prac Tools Ch. 6 $\quad$ 12 / 12
