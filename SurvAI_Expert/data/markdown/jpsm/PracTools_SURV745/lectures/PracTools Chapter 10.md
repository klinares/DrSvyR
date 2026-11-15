---
id: "jpsm/PracTools_SURV745/lectures/PracTools_Chapter_10"
source: "jpsm"
course: "SURV745"
course_title: "Practical Tools for Study Design and Inference"
doc_type: "lecture"
title: "Practical Tools for Study Design and Inference"
original: "PracTools_SURV745/lectures/PracTools Chapter 10.pdf"
pages: 63
sha256: "b22ee751fc2fd59aed2c402437f042aa9b7d5552056c18c79f7f527f1333798e"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:09"
---

<!-- page 1 -->

# Practical Tools for Study Design and Inference

## Chapter 10: Area Sampling

Sunghee Lee

Sunghee Lee (U of Michigan)

Prac Tools Ch. 10

<!-- page 2 -->

# Outline

1. 1. Census Geographic Areas

2. 2. Examples of Area Samples

3. 3. Composite MOS for Domain Sampling

4. 4. Effects of Population Change
    * 4.1 Options for Accounting for Population Change

5. 5. Address-Based Sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 2 / 63

<!-- page 3 -->

1. Census Geographic Areas

# 1. Census Geographic Areas

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 3 / 63

<!-- page 4 -->

1. Census Geographic Areas

# Introduction

* Geographic areas are used on the way to sampling lower-level elements
  * Math in VDK Ch. 9 applies for estimating variance components ($\delta$!) and finding sample allocations
* Household samples that require personal interviews usually use area sampling in the U.S. (and around the world)
* VDK Ch 10 covers:
  * US Census Bureau geographic areas
  * Data sources for statistics on areas used in sample design
  * New construction
  * Composite measures of size
  * Address-based sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 4 / 63

<!-- page 5 -->

1. Census Geographic Areas

# Figure 10.1: US Geography Hierarchy of Units

**NATION**
* ZIP Code Tabulation Areas
* **REGIONS**
  * **DIVISIONS**
    * **STATES**
      * School Districts
      * Congressional Districts
      * **Counties**
        * Voting Districts
        * Traffic Analysis Zones
        * County Subdivisions
          * Subminor Civil Divisions
        * **Census Tracts**
          * **Block Groups**
            * **Census Blocks**
      * Places
      * Public Use Microdata Areas
      * State Legislative Districts
      * Urban Growth Areas
* Core Based Statistical Areas
* Urban Areas

**AIANNH Areas\***
(American Indian, Alaska Native, Native Hawaiian Areas)

---
Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 10 $\qquad$ 5 / 63

<!-- page 6 -->

1. Census Geographic Areas

# Blocks

* Census blocks are areas bounded on all sides by visible features, such as streets, roads, streams, and railroad tracks, and by invisible boundaries, such as city, town, township, and county limits, property lines, and short, imaginary extensions of streets and roads.
* Blocks are usually small in area; but in sparsely settled areas may contain many square miles of territory.
* All territory in the 50 United States, the District of Columbia, Puerto Rico, and the Island Areas governed by the U.S. has been assigned block numbers.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 6 / 63

<!-- page 7 -->

1. Census Geographic Areas

# Block Groups

* Block group (BG) is a cluster of census blocks. BGs generally contain between 600 and 3,000 people, with a target size of 1,500 people.
* BGs on American Indian reservations, off-reservation trust lands, and special places must contain a minimum of 300 people.
  * Special places include correctional institutions, military installations, college campuses, workers' dormitories, hospitals, nursing homes, and group homes.
  * Special places are also called group quarters.
* Typically three BGs per tract.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 7 / 63

<!-- page 8 -->

1. Census Geographic Areas

# Tracts

- Tracts are statistical subdivisions of a county or equivalent entity. Generally have between 1,500 and 8,000 people, with a desired size of 4,000 people.
- Counties and equivalent entities with fewer than 1,500 people have a single census tract.
- Tracts do not cross state boundaries.
- The first decennial census for which the entire United States was covered by census tracts was in 2000.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 8 / 63

<!-- page 9 -->

1. Census Geographic Areas

# Census GEOID Structure

| Area Type | GEOID Structure | Number of Digits | Example Geographic Area | Example GEOID |
| :--- | :--- | :--- | :--- | :--- |
| State | STATE | 2 | Texas | 48 |
| County | STATE+COUNTY | 2+3=5 | Harris County, TX | 48201 |
| County Subdivision | STATE+COUNTY+COUSUB | 2+3+5=10 | Pasadena CCD, Harris County, TX | 4820192975 |
| Places | STATE+PLACE | 2+5=7 | Houston, TX | 4835000 |
| Census Tract | STATE+COUNTY+TRACT | 2+3+6=11 | Census Tract 2231 in Harris County, TX | 48201223100 |
| Block Group | STATE+COUNTY+TRACT+BLOCK GROUP | 2+3+6+1=12 | Block Group 1 in Census Tract 2231 in Harris County, TX | 482012231001 |
| Block* | STATE+COUNTY+TRACT+BLOCK | 2+3+6+4=15 (Note – some blocks also contain a one character suffix (A, B, C, ect.) | Block 1050 in Census Tract 2231 in Harris County, TX | 482012231001050 |
| Congressional District (113th Congress) | STATE+CD | 2+2=4 | Connecticut District 2 | 0902 |
| State Legislative District (Upper Chamber) | STATE+SLDU | 2+3=5 | Connecticut State Senate District 33 | 09033 |
| State Legislative District (Lower Chamber) | STATE+SLDL | 2+3=5 | Connecticut State House District 147 | 09147 |
| ZCTA ** | ZCTA | 5 | Suitland, MD ZCTA | 20746 |

Source: `https://www.census.gov/programs-surveys/geography/guidance/geo-identifiers.html`

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 9 / 63

<!-- page 10 -->

1. Census Geographic Areas

# Washington DC Area Map

Sunghee Lee (U of Michigan)

Prac Tools Ch. 10

<!-- page 11 -->

1. Census Geographic Areas

# Census Area Tallies

| Geographic Entities | United States | Puerto Rico | Island Areas | Total |
| :--- | ---: | ---: | ---: | ---: |
| American Indian/Alaska Native/Native Hawaiian Areas | 704 | 0 | 0 | 704 |
| Alaska Native Regional Corporations | 12 | 0 | 0 | 12 |
| Tribal Subdivisions | 484 | 0 | 0 | 484 |
| Tribal Tracts | 492 | 0 | 0 | 492 |
| Tribal Block Groups | 934 | 0 | 0 | 934 |
| Block Groups | 239,780 | 2,555 | 412 | 242,747 |
| Census Blocks | 8,132,968 | 41,987 | 5,911 | 8,180,866 |
| Census Tracts | 84,414 | 981 | 133 | 85,528 |
| Counties & Equivalents | 3,143 | 78 | 13 | 3,234 |

Source: `https://www.census.gov/geographies/reference-files/time-series/geo/tallies.html`

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 11 / 63

<!-- page 12 -->

1. Census Geographic Areas

# Decennial US Census Data

* Address-level items
  * Number of persons living at the address on April 1 of the census year
  * Tenure: whether the residence was owned or rented
* Items collected for each person:
  * Age
  * Gender
  * Ethnicity (whether the person is Hispanic, Latino, or Spanish origin)
  * Race (14 choices are listed, plus a person can fill in an unlisted choice)
* Counts of persons for every block in the US are available. Block-level counts are available for all of the characteristics listed above.
* 2020 Decennial data products: `https://www.census.gov/programs-surveys/popest/about/schedule.html`

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 12 / 63

<!-- page 13 -->

1. Census Geographic Areas

# American Community Survey Data - 1

- ACS replaces the "long-form" collected in census 2000 and earlier
- Each year ACS selects about 3 million HU addresses in the U.S. and 36,000 HU addresses in Puerto Rico
- Detailed questions about each person's demographics and socioeconomic status and housing unit characteristics:

| | |
| :--- | :--- |
| Age | Income |
| Birthplace | Language spoken at home |
| Citizenship | Marital status |
| Education | No. of rooms in the housing unit |
| Employment | Presence of indoor plumbing |
| Ethnicity | Race |
| Gender | Time spent commuting to work |
| Housing value | Year housing unit was built |

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 13 / 63

<!-- page 14 -->

1. Census Geographic Areas

# American Community Survey Data - 2

* ACS publishes 1-year and 5-year moving averages since the sample in any single month is small.
* Estimates at all geographic levels in VDK Figure 10.1 down to BGs are published for overlapping 5-year estimates, e.g., 2006-2010, 2007-2011, and so on.
* 1-year estimates are published only for higher levels of geography.
* Importance for sample design: statistics for the small geographic areas that are often used as sampling units will not refer to a particular point in time but instead will be average values over extended periods of time.
  - This may be more up-to-date for areas that change rapidly.

**See Class8Lab.Rmd and Class8Lab.html**

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 14 / 63

<!-- page 15 -->

2. Examples of Area Samples

# 2. Examples of Area Samples

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 15 / 63

<!-- page 16 -->

2. Examples of Area Samples

# PSUs

* Geographic areas that collectively cover the entire area in-scope of a survey.
* PSUs are first stage of sampling in an area probability sample.
  * PSUs are usually stratified by geography to ensure representation of regions or other types of subareas
  * Number of sample PSUs may be based on rough optimality calculations to account for between-PSU variances contributions to simple estimators (like the $\pi$-estimator)
* Sample is usually allocated to strata based on need to make regional estimates

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 16 / 63

<!-- page 17 -->

2. Examples of Area Samples

# Rules for Defining PSUs: Current Population Survey (CPS) - 1

1. PSUs are contained within state boundaries. This facilitates tabulations by state.
2. Each PSU is a county or group of counties, except in the New England states where other equivalent areas used.
3. Metropolitan statistical areas (MSAs) are sometimes defined as separate PSUs. Exceptions made to this rule because some MSAs are too big to be efficient for fieldwork and/or could result in being selected multiple times with some sampling methods.
4. Area of PSU should not exceed some maximum area (e.g., 3,000 square miles or about 7,770 square kilometers in CPS). Helps limit the distance interviewers must travel.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 17 / 63

<!-- page 18 -->

2. Examples of Area Samples

# Rules for Defining PSUs: Current Population Survey (CPS) - 2

* The PSU population must be greater than some minimum (e.g., 7,500 in CPS) as long as Rule 4 is not violated.
  * Idea is to allow sample to be large enough to provide a reasonable workload for interviewers as well controlling weights. For example, a PSU with a small number of sample members might require all to be selected for the survey, introducing unequal weights.
  * Another consideration may be to support a longitudinal survey where persons are in the survey for a set number of waves and are then rotated out and replaced by other sample persons. A PSU that is too small might not permit the desired number of rotations to be made.
* Avoid extreme physical length. Like Rule 4, this is designed to limit travel in surveys done by personal interviews.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 18 / 63

<!-- page 19 -->

2. Examples of Area Samples

# Washington-Baltimore-Arlington Combined Statistical Area (CSA)

Sunghee Lee (U of Michigan)

Prac Tools Ch. 10

<!-- page 20 -->

2. Examples of Area Samples

# SSUs

* Secondary sampling units (SSUs) are units first selected within each sample PSU.
* Also geographic areas but much smaller than the typical PSU.
* SSUs may be tracts, block groups, groups of blocks or ZIP code (postal delivery) areas.
  * ZIP code areas are not often used for household sampling in the U.S., because statistics and maps are readily available for tracts and BGs but not for ZIP codes.
  * ZIP codes can be useful for establishment sampling if they are the smallest areas for which business data are available.
  * Census Bureau ZIP Code Business Patterns data based on the County Business Patterns data collection. Number of establishments by employment-size classes by detailed industry.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 20 / 63

<!-- page 21 -->

2. Examples of Area Samples

# Listing Households in SSUs

* Field personnel list addresses. They usually have maps, recording material (e.g., tablets, GPS, paper forms).
* The list in each sample SSU is used as the frame for 3rd stage sampling.
* Paradata sometimes recorded—whether HU appears to be occupied or not, presence of trash or graffiti, gated areas, locked buildings
* Listers may be provided a starter list (e.g., address list purchased from a vendor) and told to add/delete entries.
  * Listers do tend to ractify what they are given rather than doing much updating (Eckman & Kreuter, POQ 2011).

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 21 / 63

<!-- page 22 -->

2. Examples of Area Samples

# Current Population Survey (CPS) - 1

- Monthly US labor force survey
  - Estimates unemployment rate; once a year collects household income data
- Target population: civilian, noninstitutionalized pop 16+ years old in 50 states and DC
- Produces national and state estimates; substate estimates for CA and NY
- Master Address File (MAF) of Census Bureau used as the frame
- Selection of CPS and several other surveys are coordinated to avoid overlap (American Housing Survey, Consumer Expenditure Survey (Diary & Quarterly), Crime Survey, NHIS, among others.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 22 / 63

<!-- page 23 -->

2. Examples of Area Samples

# Current Population Survey (CPS) - 2

* Total national sample: 72,000 HUs per month (but fluctuates)
* 824 PSUs: MSAs or groups of counties
  446 certainties
  378 non-certainties; 1 PSU selected from each non-certainty stratum
* SSU is a group of 4 adjacent HUs called segments
  – Possible because Census has MAF
  – All 4 HUs in sample
* Further area sampling used in rural areas where MAF address list is incomplete
* Building permit sample used to cover HUs built since MAF updated

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 23 / 63

<!-- page 24 -->

2. Examples of Area Samples

# CPS: PSUs

* PSUs formed by rules on earlier slides
* Based on 2000 census, 2025 PSUs formed for frame from 3141 counties. Redesigned to 1987 PSUs based on 2010 census.
* PSUs do not cross state boundaries; when an MSA crosses state boundaries, it is split into 2 or more PSUs
* PSUs stratified within state. Key variables used for stratification are:
    * Number of males that are unemployed
    * Number of females unemployed
    * Number of families with female head of household
    * Ratio of occupied HUs with three or more people, of all ages, to total occupied housing units.
* Strata created to contain PSUs that are similar to each other on these variables, using a clustering algorithm.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 24 / 63

<!-- page 25 -->

2. Examples of Area Samples

# CPS: Certainty PSUs

* Any PSU that is part of the 151 largest metropolitan areas is a certainty.
* This, in conjunction with the CV requirement for state estimates, leads to nine entire states being certainty PSUs.
  * Geographically small but densely populated: Connecticut,
  * Delaware, Hawaii, Massachusetts, New Hampshire, New Jersey, Rhode Island, Vermont, District of Columbia.
  * These small states are then strata.
* Strata of non-self-representing (non-certainty) PSUs formed to have about the same population size
  * 1 PSU selected with probability proportional to total population

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 25 / 63

<!-- page 26 -->

2. Examples of Area Samples

# CPS: Selection of Ultimate Sampling Units - 1

* Frame for selecting USUs in each PSU has four pieces:
    1. housing unit (HU) address list frame which is the MAF
    2. area frame, used where a census address cannot be used to locate an HU
    3. group quarters (GQ) frame, and
    4. building permit frame.
* Housing units (HUs): group of rooms or a single room occupied as a separate living quarter (or intended to be). 98% of the U.S. population resides in an HU; rest are in group quarters or are homeless.
* Group quarters (GQs): residents share common facilities or receive formally authorized care.
    * Examples: college dormitories, nursing homes, retirement homes, and communes. Since CPS covers only the non-institutionalized population, institutional group quarters like prisons and military facilities are not in-scope.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 26 / 63

<!-- page 27 -->

2. Examples of Area Samples

# CPS: Selection of Ultimate Sampling Units - 2

* Rotating panel design: Sample of HUs is designed to overlap between time periods $4 - 8 - 4$ pattern: in 4 months, out 8 months, in 4 months
(Canada uses 6 and out in its labor force survey)
* Each month of CPS
  * 50% of HH are in the CPS during the same month one year earlier
  * 50% will be in te sameple during the same month ths following year
* Any CPS HHs are interviewed (i.e., in the data collection attempts) 8 times over 16months
* $3/4$ of HUs overlap between consecutive months; $1/2$ of HUs overlap in samples 12 months apart
* HUs are self-weighting within state
* No differential subsampling of domains

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 27 / 63

<!-- page 28 -->

2. Examples of Area Samples

# Fig 10.3. Rotation Plan for PSUs

**National Survey on Drug Use and Health (NSDUH)**

* Survey of 67,500 persons/yr
  * States are strata
  * PSUs are census tracts or groups of tracts
  * PSUs are stratified by regions within state and are rotated each year

| Subsample | Year 1 | 2 | 3 | 4 | 5 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | $\bullet$ | | | | |
| 2 | $\bullet$ | $\bullet$ | | | |
| 3 | | $\bullet$ | $\bullet$ | | |
| 4 | | | $\bullet$ | $\bullet$ | |
| 5 | | | | $\bullet$ | $\bullet$ |
| 6 | | | | | $\bullet$ |

**Fig. 10.3:** Rotation plan for PSUs in the National Survey on Drug Use and Health

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 28 / 63

<!-- page 29 -->

3. Composite MOS for Domain Sampling

# 3. Composite MOS for Domain Sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 29 / 63

<!-- page 30 -->

3. Composite MOS for Domain Sampling

# Composite MOS

* Why?
    * Obtain self-weighting samples from each of several domains
    * Have equal workload in each PSU (i.e., same total sample size in each PSU across all domains)
* Simple case
    * When all elements are sampled at the same rate, calculation to determine within-PSU sampling rates is simple.
    * Suppose that desired overall rate is $f$; selection probability of PSU $i$ is $\pi_i$.
    * Set within-PSU rate so that $\pi_i \pi_{k|i} = f \quad \Rightarrow \pi_{k|i} = f / \pi_i$
    * Within-PSU sampling rate is adjusted, depending on the selection probability of the PSU, but the adjustment does not depend on domain membership.
    * Composite measure of size technique refines this to allow self-weighting samples to be selected within different domains while obtaining the same sample size within each PSU across all domains.

Sunghee Lee (U of Michigan) $\qquad$ Prac Tools Ch. 10 $\qquad$ 30 / 63

<!-- page 31 -->

3. Composite MOS for Domain Sampling

# Designing Sample from Scratch: Notation

$N_d$: number of elementary units (i.e., smallest unit of analysis) in unique domain $d$ in population, e.g., the number of persons in an age group

$N = \sum_{d=1}^D N_d$: total number of elementary units in the population

$n_d$: desired sample size in domain $d$ (values based on precision, power, and budget considerations)

$n = \sum_{d=1}^D n_d$: total sample size across all domains

$f_d = n_d / N_d$: desired sampling rate for units in domain $d$

$N_i(d)$: number of elementary units in domain $d$, PSU $i$ in population; $i \in U$, the universe of PSUs; $\sum_d N_i(d) = N_i$; $\sum_i N_i(d) = N(d) = N_d$

$\bar{n}$: desired sample size in each PSU across all domains (equal workload requirement)

$m$: number of sample PSUs

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 31 / 63

<!-- page 32 -->

3. Composite MOS for Domain Sampling

# Designing Sample from Scratch: Details - 1

* Domains must partition the target population into mutually exclusive groups.

  Age groups used in the 2005 National Survey of Drug Use and Health (NSDUH) composite size measures were 12 to 17, 18 to 25, 26 to 34, 35 to 49, and 50 years or older.

* Composite MOS for PSU i is defined to be:

$$
S_i = \sum_{d=1}^{D} f_d N_i(d) \tag{10.1}
$$

  This is the expected sample size in PSU $i$ if desired overall sampling rates for all domains were used.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 32 / 63

<!-- page 33 -->

3. Composite MOS for Domain Sampling

# Designing Sample from Scratch: Details - 2

- Suppose PSUs are sampled with probabilities proportional to $S_i$ so that $Pr(i \in s) = \pi_i = mS_i / S_+$ where $S_+ = \sum_{i \in U} S_i$, sum of the MOSs across all PSUs.
- The total MOS can be written as
  $$S_+ = \sum_{i \in U} \sum_{d=1}^D f_d N_i(d) = \sum_{d=1}^D f_d N(d)$$
  That is, the sum of the MOSs equals the total desired sample size.
- Set desired sample size in PSU $i$ and domain $d$ to be
  $$n_i^*(d) = \bar{n} \frac{f_d N_i(d)}{S_i} \quad (10.2)$$

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 33 / 63

<!-- page 34 -->

3. Composite MOS for Domain Sampling

# Within PSU Sampling Rates for Domains

* within-PSU sampling rate for units in domain d is required to be
$$\pi_{k|i}(d) = \frac{n_i^*(d)}{N_i(d)} = \frac{\bar{n}}{S_i} f_d$$
$\Rightarrow$ within-PSU rate is a modification of the overall rate.
* This is possible as long as $f_d \le S_i / \bar{n}$ for all PSUs.
* Checking whether any PSU violates this requirement is an important step in quality control (see Ch. 19 for more details on quality checks).
* Check workload. Using $S_i = \sum_d f_d N_i(d)$, the expected total number of sample units in PSU $i$ is
$$\sum_d n_i^*(d) = \frac{\bar{n}}{S_i} \sum_d f_d N_i(d) = \bar{n}$$
$\Rightarrow$ Within-PSU, domain sample sizes sum to the desired workload in each PSU.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 34 / 63

<!-- page 35 -->

3. Composite MOS for Domain Sampling

# Check Whether Domain Sample Is Self-Weighting

- The sample for a domain is also self-weighting in each domain. Assuming that PSUs are picked $pp(S_i)$, the overall selection probability for a unit $k$ in domain $d$ is:

$$\pi_i \pi_{k|i}(d) = m \frac{S_i}{S_+} \frac{n_i^*(d)}{N_i(d)} = m \frac{S_i}{S_+} \frac{\bar{n}}{N_i(d)} f_d = f_d$$

using $m\bar{n} = n = S_+$.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 35 / 63

<!-- page 36 -->

3. Composite MOS for Domain Sampling

# Example 10.1: Composite MOS - 1

**Table 10.1:** Population counts and composite MOSs for Example 10.1

| PSU | $N_i(d)$ Domain $d=1$ | $N_i(d)$ Domain $d=2$ | Total no. of units in PSU | Composite MOS $S_i$ | PSU probability $\pi_i$ | Within-PSU probability, $\pi_{k|i}(d)$ Domain $d=1$ | Within-PSU probability, $\pi_{k|i}(d)$ Domain $d=2$ |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 50 | 50 | 100 | 17.5 | 0.389 | 0.643 | 0.257 |
| 2 | 50 | 30 | 80 | 15.5 | 0.344 | 0.726 | 0.290 |
| 3 | 50 | 90 | 140 | 21.5 | 0.478 | 0.523 | 0.209 |
| 4 | 50 | 40 | 90 | 16.5 | 0.367 | 0.682 | 0.273 |
| 5 | 50 | 25 | 75 | 15.0 | 0.333 | 0.750 | 0.300 |
| 6 | 70 | 40 | 110 | 21.5 | 0.478 | 0.523 | 0.209 |
| 7 | 50 | 80 | 130 | 20.5 | 0.456 | 0.549 | 0.220 |
| 8 | 50 | 65 | 115 | 19.0 | 0.422 | 0.592 | 0.237 |
| 9 | 50 | 30 | 80 | 15.5 | 0.344 | 0.726 | 0.290 |
| 10 | 50 | 50 | 100 | 17.5 | 0.389 | 0.643 | 0.257 |
| | | | | | | | |
| Totals | 520 | 500 | 1,020 | 180 | | | |

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 36 / 63

<!-- page 37 -->

3. Composite MOS for Domain Sampling

# Example 10.1: Composite MOS - 2

We want to sample four PSUs and 45 units per sample PSU for the following desired sampling rates and sample sizes.

**Table 10.2:** Desired sampling rates and sample sizes in Example 10.1

| Domain | Sampling rate, $f_d$ | Desired domain sample size, $n_d$ |
| :--- | :--- | :--- |
| 1 | 0.25 | 130 |
| 2 | 0.10 | 50 |
| Total | | 180 |

**Switch to** `VDK Example 10_1.xlsx`

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 37 / 63

<!-- page 38 -->

3. Composite MOS for Domain Sampling

# More than Two Stages of Sampling

- Composite MOSs can be used for more than 2 stages
- PSUs, SSUs, etc. must be selected with probabilities proportional to the MOS
- Composite MOS with an existing PSU sample–only one of two goals can be met:
  1. Select a self-weighting sample for units in each domain, but have different sampling rates for the domains; or
  2. Obtain a constant workload in each PSU

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 38 / 63

<!-- page 39 -->

4. Effects of Population Change

# 4. Effects of Population Change

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 39 / 63

<!-- page 40 -->

4. Effects of Population Change

# Effects of Population Change - 1

* SSUs (BG's, tracts, etc.) for area samples and multistage designs in general are almost always selected with probabilities proportional to some measure of size (MOS). Examples of MOSs are:
  * Total population
  * Total households
  * A weighted combination of domain population counts (e.g., the composite MOS discussed in the previous sections).
* If MOSs are based on decennial census data, the farther the date of sample selection is from the census, the more out-of-date these counts get.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 40 / 63

<!-- page 41 -->

4. Effects of Population Change

# Effects of Population Change - 2

**Table 10.6:** Change in U.S. population between decennial censuses

| | Population | | Housing units | |
| :--- | :---: | :---: | :---: | :---: |
| Year | Total | Percent change from last census | Total | Percent change from last census |
| 1960 | 179,323,175 | 18.5 | 58,326,357 | 26.4 |
| 1970 | 203,302,031 | 13.4 | 68,704,315 | 17.8 |
| 1980 | 226,542,199 | 11.4 | 88,410,627 | 28.7 |
| 1990 | 248,709,873 | 9.8 | 102,263,678 | 15.7 |
| 2000 | 281,421,906 | 13.2 | 115,904,641 | 13.3 |
| 2010 | 308,745,538 | 9.7 | 131,704,730 | 13.6 |

Sources: U.S. Census Bureau (1991, 2001a,b) and Bell et al. (1999)

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 41 / 63

<!-- page 42 -->

4. Effects of Population Change

# Effects of Population Change - 3

**Table 10.7:** Percentage change in population and housing units, 1990–2000, for selected states

| State | Percent change 1990–2000 | | Percent change 2000–2010 | |
| :--- | :---: | :---: | :---: | :---: |
| | Population | housing units | Population | housing units |
| Nevada | 66.3 | 59.5 | 35.1 | 41.9 |
| Arizona | 40.0 | 31.9 | 24.6 | 29.9 |
| Utah | 29.6 | 28.4 | 23.8 | 27.5 |
| New York | 5.5 | 6.3 | 2.1 | 5.6 |
| Connecticut | 3.6 | 4.9 | 4.9 | 7.4 |
| District of Columbia | $-5.7$ | $-1.3$ | 5.2 | 8.0 |

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 42 / 63

<!-- page 43 -->

4. Effects of Population Change

# Effects of Population: Out-of-Date MOSs - 1

- Small areas may be especially affected by population changes between censuses.
  - Too big MOSs due to demolitions, vacancies, and natural disasters
  - Too small MOS due to new construction.
- Either can lead to some severe inefficiencies in a sample design.
- For example, in 2018 Hurricane Michael destroyed large sections of Mexico Beach, FL.
- Using out-of-date census data on population counts would lead to tracts and BG's being sampled that have virtually no people living in them. This would reduce sample size and lead to expensive and unproductive field work if personnel are sent out to attempt interviews in vacated areas.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 43 / 63

<!-- page 44 -->

4. Effects of Population Change

# Mexico Beach, FL - 1

Before Hurricane Michael, 2018

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 44 / 63

<!-- page 45 -->

4. Effects of Population Change

# Mexico Beach, FL - 2

In 2022

Sunghee Lee (U of Michigan)

Prac Tools Ch. 10

<!-- page 46 -->

4. Effects of Population Change

# Effects of Population: Out-of-Date MOSs - 2

- Construction of new housing will result in the Census counts being far too small. $\Rightarrow$ SSU may be selected with a smaller probability based on out-of-date population counts than it deserves based on its actual size.
- Example: suppose that the design calls for HUs within a sample SSU to be selected at rate $1/4$ and the Census count of HUs (the MOS) is 100.
  - Field staff arrive at the SSU to count and list all HUs contained within the area and discover that a new apartment complex has been built; actual total of HUs is 500.
  - With rate of $1/4$, the expected sample size is $25(= 100 \times 0.25)$. If we use the planned rate, the actual sample size will be $125(= 500 \times 0.25)$.
  - Larger sample size is probably statistically inefficient because intraclass correlation will be high for at least some variables.
  - Likely that neither the budget nor the time schedule can tolerate an extra 100 interviews.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 46 / 63

<!-- page 47 -->

4. Effects of Population Change

# Hanoi, Vietnam - 1

A neighborhood, Hanoi, Vietnam, 2013

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 47 / 63

<!-- page 48 -->

4. Effects of Population Change

# Hanoi, Vietnam - 2

A neighborhood, Hanoi, Vietnam, Sometime after 2018

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 48 / 63

<!-- page 49 -->

4. Effects of Population Change  4.1 Options for Accounting for Population Change

# 4.1 Options for Accounting for Population Change

Sunghee Lee (U of Michigan)  Prac Tools Ch. 10  49 / 63

<!-- page 50 -->

4. Effects of Population Change  4.1 Options for Accounting for Population Change

# What to do?

1. Use initially planned sampling rate–giving more sample cases than desired
   – Could be a budget problem
2. Reduce sampling to select fewer case–leads to cases with different weights
   —Could increase variances
3. Update population counts before sampling
4. Select a sample of new construction

Sunghee Lee (U of Michigan)  Prac Tools Ch. 10  50 / 63

<!-- page 51 -->

4. Effects of Population Change 4.1 Options for Accounting for Population Change

# Option 1: Sample Building Permits

* Local governments in US usually require that building permits be obtained when new construction projects are undertaken.
  * Required to ensure that the planned construction does not violate zoning ordinances.
* Get lists of permits issued by local jurisdictions and sample from those lists.
  * Census Bureau Building Permit Survey is monthly survey of building permit offices. Aggregate stats published for counties and smaller places on number of permits issued, HUs authorized, and valuations.
  * Make a judgment about which sample PSUs will require special, new construction samples.
* Visit local permit offices to obtain addresses for new construction projects.
  * Compile a complete list of permits to use as a sample frame
  * If number of permits is large, an option is to form new construction "segments" defined by local permit issuing office and time period.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 51 / 63

<!-- page 52 -->

4. Effects of Population Change 4.1 Options for Accounting for Population Change

# Option 1: Problems with Sample Building Permits - 1

1. About 5% of new HUs are built in areas that do not require permits.
2. Building permits not required for placement of <u>mobile homes</u>. These are usually in mobile home parks, which are common in some areas, but non-existent in others.
3. The fact that a permit is issued does not mean that an HU was ever built; however, only about 1% are not built.
4. May be a delay between time permit is issued and an HU is actually built.
5. Some permit offices are uncooperative or have poor records $\Rightarrow$ dealing with them can be expensive and unproductive
6. Sample permit cases are not necessarily clustered. This may increase travel costs for interviewing.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 52 / 63

<!-- page 53 -->

4. Effects of Population Change 4.1 Options for Accounting for Population Change

# Option 1: Problems with Sample Building Permits - 2

Handling HUs on both the area and the permit sample properly for weighting.
* Could use rule that an HU on permit frame can only be selected from that frame
  * Must determine whether an HU in the area sample could have been picked through the permit sample.
  * If yes, the unit would be removed from the area sample frame.
  * Matching an address for an area sample HU is usually error prone because of variations of addresses that can be used.
* Alternative is to determine age of HU in field
  * Have field personnel guess whether an HU was built in the period covered by the permit frame. Easier for older than for newer housing.
  * Could ask respondents in area sample when their HU was built; they may not know.
  * Exclude any area sample HUs reported to have been built in period covered by the permit frame.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 53 / 63

<!-- page 54 -->

4. Effects of Population Change 4.1 Options for Accounting for Population Change

# Option 1: Problems with Sample Building Permits - 3

* Another possibility is to allow new construction to be selected in either the area or permit samples. The selection probability could be computed as

$$\begin{aligned}
Pr(&\text{HU selected in area sample}) \\
+&Pr(\text{HU selected in permit sample}) \\
-&Pr(\text{HU selected in both})
\end{aligned}$$

* Does not unambiguously solve the problem either, since we must still identify those units that had a chance of selection from both frames.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 54 / 63

<!-- page 55 -->

4. Effects of Population Change  4.1 Options for Accounting for Population Change

# Option 2: Two-Phase Sampling of Segments - 1

* Simpler procedure is to use a variation of two-phase sampling.
* General idea is to select an extra large sample of area segments or SSUs and update the MOS for each.
* Then, select a subsample of the 1st-phase segment sample using the updated MOSs.

Sunghee Lee (U of Michigan)  Prac Tools Ch. 10  55 / 63

<!-- page 56 -->

4. Effects of Population Change  4.1 Options for Accounting for Population Change

# Option 2: Two-Phase Sampling of Segments - 1

1. Use Census Building Permit Survey (BPS) data to update population counts in individual places in a PSU.
2. Convert the HU counts from the BPS to counts of persons using a conversion factor, e.g., 2.6 persons per HU.
3. Apply place-specific population adjustment to every SSU contained in the place. Gives new set of MOS for the SSUs in the PSU.
4. Select a large sample of SSUs. E.g., the 1st-phase sample 5 to 10 times larger than the number of SSUs desired (Montaquila et al., 1999). The cost of SSUs will determine the 1st-phase SSU sample size.
5. ”Counters”, i.e., experienced field listers travel to 1st-phase SSUs and count the HUs. Satellite pictures may help. Counts do not have to be perfect but should identify areas where HU count has changed substantially since date of frame MOSs.
6. Update the MOS for each SSU based on the field counts.
7. Sample a 2nd-phase SSUs from all 1st-phase SSUs using the new MOSs.

Sunghee Lee (U of Michigan)  Prac Tools Ch. 10  56 / 63

<!-- page 57 -->

4. Effects of Population Change 4.1 Options for Accounting for Population Change

# Option 2: Two-Phase Sampling of Segments - 2

**Advantages:**

* Leads to SSU sample being selected with MOSs that are better reflection of the current population sizes
* Identifies areas where there has been growth and areas where demolitions were common.– Especially relevant where natural disasters have hit
* All SSUs become regular area SSUs. No need to deal with permit offices.
* Travel time reduced for interviewers since all sample HUs are clustered by area SSU.
* Screening question about whether an HU was built in last decade (or some other specified time period) is eliminated.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 57 / 63

<!-- page 58 -->

4. Effects of Population Change 4.1 Options for Accounting for Population Change

# Option 2: Two-Phase Sampling of Segments - 3

**Disadvantages**:

* Main one is that counting of 1st-phase segments is an extra cost–both in calendar time and project funds.
* This added field cost may even be more than for permit sampling.
  * Training materials have to be developed for counters
  * Training conducted
  * Field counting must be done
  * Data processing system is needed to incorporate the updated information on SSUs

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 58 / 63

<!-- page 59 -->

4. Effects of Population Change 4.1 Options for Accounting for Population Change

# Option 3: Half-Open Interval

* Half-Open Interval (HOI) has been used since 1960s
* Attributed to Kish (1965) as a method to improve HU frame coverage in a geographic area already selected for a survey.
* Field staff members are provided with a frame listing for a particular area, sorted in some order.
  * Their task is to identify any HUs not on the frame (e.g., new construction) that exist between the sampled HU and the next HU on the list.
  * Any newly discovered units are automatically included in the sample
* HOI procedure is effective only when field interviewers are trained extensively and technique properly implemented (Eckman 2010, 2011)

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 59 / 63

<!-- page 60 -->

5. Address-Based Sampling

# 5. Address-Based Sampling

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 60 / 63

<!-- page 61 -->

5. Address-Based Sampling

# Address-Based Sampling - 1

* Area household sampling may be impractical for surveys with a limited budget or a small data collection window.
* Development of an HU frame through counting and listing procedures may take months and be cost intensive.
* Iannacchione et al. (2003) introduced address-based sampling (ABS) as way to save time and money.
* All ABS sampling frames in the US built from US Postal Service (USPS) Address Management System (AMS)
  * Information includes: street name and number, mailbox number (if appropriate), city, state, nine-digit ZIP Code, the delivery-sequence number (order that a USPS carrier delivers mail), and address vacancy indicators.
  * Only commercial vendors that apply and qualify for a license may access the USPS-AMS data
  * Nearly complete coverage of the U.S. household population

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 61 / 63

<!-- page 62 -->

5. Address-Based Sampling

# Address-Based Sampling - 2

- Commercial vendors of survey samples sell "enhanced" versions.
- Enhancements can include landline telephone numbers, a name associated with the address, Spanish surname indicator, estimated age of the head of household, as well as some geocoded (i.e., latitude and longitude) and Census tract information.
- Geocoding information is required to map ABS geography to Census geography
  - Quality of info depends on address-telephone number match rate, age of the household contact information, geocoding errors attributed to the approximate mapping of the mailing address to a physical location, and the number of HUs linked to a particular mailing address.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 62 / 63

<!-- page 63 -->

5. Address-Based Sampling

# Address-Based Sampling: Advantages

* Data collection costs reduced either by using the list frame information directly in combination with half-open interval instead of counting-and-listing procedures, or by providing listing personnel with starting information.

  Problems:
  * Varying levels of undercoverage in ABS frames for rural areas of the US
  * Field staff tend to ratify that the starter list is correct rather than checking for omissions.

* Unclustered samples can be selected within a PSU, reducing SE of estimates.
* If accurate, household-level items, like race/ethnicity and age, can improve the efficiency of a sample by enabling the targeting of different groups.
* If contact information is correct, several modes may be used to contact sample members.

Sunghee Lee (U of Michigan) Prac Tools Ch. 10 63 / 63
