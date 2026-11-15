---
id: "jpsm/Fund_data_collection_SURV622/lectures/Lecture_6__Web_scraping_and_APIs"
source: "jpsm"
course: "SURV622"
course_title: "Fundamentals of Data Collection II"
doc_type: "lecture"
title: "SURV 622/SURVMETH 622: WEB SCRAPING AND APIs"
original: "Fund_data_collection_SURV622/lectures/Lecture 6_ Web scraping and APIs.pdf"
pages: 18
sha256: "c8315ad7c1878bc3b9c4b871bd292c873a01fcc29e141ffdebc3d531f72e8d7f"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:01:01"
---

<!-- page 1 -->

# SURV 622/SURVMETH 622: WEB SCRAPING AND APIs

February 24, 2025

<!-- page 2 -->

# What are web scraping and APIs?

* **Web scraping** involves using a program to download and process web pages directly, transforming unstructured data into structured data that can be stored and analyzed
* **Application Programming Interfaces (APIs)** are tools provided by the owners of a website that enable scripted access to the data they hold
  - APIs are increasingly common
  - Using an API generally will be easier than scraping the same information
* Goal for today to help you understand what these tools can do
  - Will walk through an example of each in some detail, but are not trying to make you expert web scrapers or API programmers

<!-- page 3 -->

# Web-scraping to obtain data

<!-- page 4 -->

# Examples of data that might be scraped for statistical purposes

* Information on product prices and characteristics
  - [Billion Prices Project (BPP)]() scrapes data to produce price indexes for 20 countries
  - Bureau of Labor Statistics scrapes data on prices and product characteristics to use in hedonic models for quality adjustment
* Lists of and information about businesses or organizations
  - Energy Information Administration has tested web-scraping to develop a survey frame of local governments that use alternative fuel vehicles
* Lists of and information about people in certain professions
  - State registries (for example, click [here]()) or health insurance company lists of associated providers (for example, click [here]()) could be scraped to develop survey sampling frames of medical service providers
  - A Maryland Economics graduate student recently scraped information for a project from the Maine registry of Certified Nursing Assistants (CNAs) (click [here]())

<!-- page 5 -->

# Web-scraping basics

* Identify website that contains data or information of interest
* Look at the web page to determine how the information is stored on the page
  - Right click and select inspect or enter <ctrl> U in browser to see the HTML code for a page
* Write code to extract the data of interest
* Once data obtained, configure them for analysis
* Challenges to obtaining web scraped data
  - Because each web page is unique, query will differ from page to page (must be customized)
  - Query must be modified if page format changes
  - Web pages often designed in ways that make scraping difficult
  - Website owner may impose restrictions on use

<!-- page 6 -->

# General Workflow

* Go to the website and check HTML.
* Figure out where the information is.
* Use R (or your web scraping tool of choice) to read the HTML.
* Use the tags that you found from inspection to isolate the data you want.
* Put data into a usable format (e.g. a dataframe).

<!-- page 7 -->

# XPath

* Selector Gadget: https://selectorgadget.com

<!-- page 8 -->

# Terms of service restrictions on web-scraping

* Many web sites include restrictions on scraping in their posted terms of service
  - Example: “**7. Prohibited Conduct**… (Y)ou may not…engage in unauthorized “scraping” or spidering, or harvesting of personal information, or use any unauthorized automated means to compile information.” (Washington Post website)
  - Example: “Macy’s grants you a limited, non-exclusive, non-transferable license to access and make non-commercial use of this website. This license does not include… (e) any use of data mining, robots or similar data gathering and extraction tools.” (Macy’s website)
* Reasons owners may seek to limit web scraping include
  - Desire to preserve the commercial value of a company’s data, information or other online resources
  - In cases where information consists of entries by users of the website, desire to ensure that it is not used in ways the users had not anticipated
  - Concern that scraping will interfere with website functionality

<!-- page 9 -->

# Terms of service restrictions on web-scraping (continued)

* Courts have ruled that terms of service are enforceable against competitors using data in ways courts view as improper, but have not always found for the plaintiff
  - Recent case decided by the Ninth Circuit (Oracle USA, Inc. v. Rimini Street, Inc.) involved scraping of the Oracle website
  - Primary statute at issue the California Computer Data Access and Fraud Act (CDAFA), which prohibits unauthorized taking of data from a computer, computer system, or computer network
  - Court ruling stated “We hold that taking data using a *method* prohibited by the applicable terms of use, when the taking itself generally is permitted, does not violate the CDAFA.”
* Website owners could make breach of contract claims, but questionable that provisions contained in a clickwrap agreement presented to all users prior to download are enforceable (Neuburger 2018)
* Website owner can take steps to restrict access from IP addresses that appear to be violating terms of service, for example
  - Deny access to IP addresses that make too many requests
  - Deny access to IP addresses that end up on “honeypot” pages
* Polite to comply with restrictions contained in terms of service

<!-- page 10 -->

# Restrictions on web-scraping in robots.txt files

* Many websites contain a robots.txt file accessible from the root directory that specifies limits on content that users are permitted to access
* This code tells all robots they can visit all files:
  User-agent: *
  Disallow:
* This code tells all robots to stay out of the website:
  User-agent: *
  Disallow: /
* This code tells two robots to stay out of a specific file:
  User-agent: Googlebot
  User-agent: Badbot
  Disallow: /private/

<!-- page 11 -->

# Restrictions on web-scraping in robots.txt files (contd)

* This code tells robots to slow down the rate at which they access a site. Can be interpreted either to mean number of seconds between successive visits or size of the time window during which the site can be visited once.
  User-agent: *
  Crawl-delay: 3
* Some examples of robots.txt files
  [www.bls.gov/robots.txt](http://www.bls.gov/robots.txt)
  [www.census.gov/robots.txt](http://www.census.gov/robots.txt)
* Although adhering to restrictions stated in robots.txt is voluntary, website owner may take steps to restrict access from IP addresses that appear to be behaving inappropriately
* Polite to comply with restrictions contained in robots.txt files

<!-- page 12 -->

# Using APIs to obtain and provide data

<!-- page 13 -->

# API basics

* An API is a tool designed to facilitate communication with users of a service
    - APIs we will talk about today are RESTful services, a type of API that works directly over the web to transfer data
* Operation of an API similar to a function call in a programming language
    - Call a specific URL
    - Pass in some inputs (e.g., specifying desired variable)
    - Get back an output (e.g., JSON code that contains desired information for processing)
* Website owner will provide information to programmers about what resources are available through the API and limitations on accessing them
    - Information on available data elements and associated codes
    - Limitations on uses of information extracted via the API
    - Rate limits (e.g., number of requests per period of time, total number of records extracted)

<!-- page 14 -->

# API basics (continued)

* Programmers may write code in PHP, Python, Ruby, R, Java, Perl or some other language to access the API
  - Developer page for a website's API often will provide sample code
* For many APIs, there are convenient "wrappers" that makes the process of requesting and receiving information easier
  - May be able to call a routine in another program that generates the relevant HTTP code rather than having to write it directly

<!-- page 15 -->

# Census API

* See available APIs at https://www.census.gov/data/developers/data-sets.html
  - American Community Survey (ACS)
  - Decennial Census
  - More
* Need an API key, but it is easy to get and use.
* Request API key here: https://api.census.gov/data/key_signup.html
* Can use censusapi R package
  - See https://github.com/hrecht/censusapi for info on usage.

<!-- page 16 -->

# Examples of websites with APIs

* Formerly public Twitter APIs
  - Search API searches for recent tweets (approximately past week)
  - Stream API collects tweets as they happen
  - Both have filtering capability
  - Both return only public tweets and have rate limits
* Several different LinkedIn APIs
  - APIs tap into information from LinkedIn member profiles; domains include people, organizations, and jobs
  - Potential applications include apps for adding particular credentials to LinkedIn profiles, facilitating contacts among LinkedIn members, and managing companies’ social media presence on LinkedIn
  - Prohibits use for applications that compete with LinkedIn services, storage of information about individual members obtained using the APIs without their consent
* Indeed.com API
  - Indeed aggregates job listings from “thousands of company websites and job boards”
  - API accesses information contained in those listings

<!-- page 17 -->

# Examples of websites with APIs (cont’d)

* Bureau of Labor Statistics API
  - Allows user to request single or multiple series, specify desired years. Selected sample R code:

```r
+#' ## Single Series request
+#' response <- blsAPI('LAUCN040010000000005')
+#' json <- fromJSON(response)

+#' ## Multiple Series
+#' payload <- list('seriesid'=c('LAUCN040010000000005', 'LAUCN040010000000006'))
+#' response <- blsAPI(payload)
+#' json <- fromJSON(response)

+#' ## One or More Series, Specifying Years
+#' payload <- list('seriesid'=c('LAUCN040010000000005', 'LAUCN040010000000006'), 'startyear'='2010', endyear'='2012')
+#' response <- blsAPI(payload)
+#' json <- fromJSON(response)
```

  - See here for examples of output from this type of call
  - Compare to existing BLS data access interface here

<!-- page 18 -->

# Other Examples of APIs

COVIDcast: [https://cmu-delphi.github.io/delphi-epidata/api/covidcast.html](https://cmu-delphi.github.io/delphi-epidata/api/covidcast.html)

Global COVID-19 Trends and Impact Survey (CTIS):
[https://gisumd.github.io/COVID-19-API-Documentation/](https://gisumd.github.io/COVID-19-API-Documentation/)
