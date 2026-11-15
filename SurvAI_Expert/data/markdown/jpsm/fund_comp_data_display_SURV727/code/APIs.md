---
id: "jpsm/fund_comp_data_display_SURV727/code/APIs"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lab"
title: "APIs"
original: "fund_comp_data_display_SURV727/code/APIs.qmd"
pages: 
sha256: "8e5831497497d2aef122e27ad19ff3f7c1bf9ee3b8072c0ef9019922d46864e0"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:53"
---


APIs (application programming interfaces) are hosted on web servers. When you type www.google.com in your browser's address bar, your computer is actually asking the www.google.com server for a webpage, which it then returns to your browser. APIs work much the same way, except instead of your web browser asking for a webpage, your program asks for data. This data is usually returned in JSON format. To retrieve data, we make a request to a webserver. The server then replies with our data.

## Packages

We'll use the `httr` package to make the requests and `jsonlite` to convert from a JSON file to a data frame.

```r
# Packages
if (!requireNamespace("httr", quietly = TRUE)) {
  install.packages("httr")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}

library('httr')
library('jsonlite')
library(tidyverse)
```

## Example: Covid API

The Global COVID-19 Trends and Impacts Survey was a survey administered through Facebook during the COVID-19 pandemic. It asked questions about topics such as flu or covid symptoms, social distancing behavior, vaccine acceptance, and mental health. These surveys were collected daily, and Facebook provided weights to adjust for nonresponse and coverage bias. The data were designed to be used as a real-time measure of trends as the pandemic was ongoing. More information about this can be found at <https://covidmap.umd.edu>.

The documentation for the API can be found at <https://gisumd.github.io/COVID-19-API-Documentation/>.

### Step 1: Use the URL to get a response

Using the documentation, we can construct a URL that we use with the `GET` function to get a response.

```r
base_url <- 'https://covidmap.umd.edu/apiv2/resources'

request <- GET(base_url, query = list(indicator = 'mask',
                                      type = 'daily',
                                      country = 'Finland',
                                      daterange = '20201201-20201204'))
```

Note that we used the `query` argument to construct the URL in a more readable manner. You can see the final URL by using `request$url`.

```r
request$url
```

Before you can do anything with a website or URL, it’s a good idea to check the current status code of said portal.

The following are some useful response codes to keep in mind:

`200` - the query parameters are all valid; the results will be in the body of the response

`400` - the query parameters are not valid, typically either because they are not in valid JSON format, or a specified field or value is not valid; the “status reason” in the header will contain the error message

`500` - there is an internal error with the processing of the query; the “status reason” in the header will contain the error message

Let's check the status of our response.

```r
request$status_code
```

Next, we need to extract the content from the response and convert the data into a data frame format. We can do this

```r
response <- content(request, as = "text", encoding = "UTF-8")
# response
```

```r
coviddata <- fromJSON(response, flatten = TRUE)$data 
coviddata %>% head()
```

## API Keys

Many times, data providers don't want to provide access to their APIs to just anybody. In order to make sure that they control access and track usage of the API, they might require the use of an **API key**. An API key is basically like a password that is uniquely associated with your account that you use every time you want to use that API. Many of the most interesting APIs, including the Census API and the New York Times API require a key to use.

## New York Times API

One example of an API that requires a key is the **New York Times API**. We'll show an example of using the New York Times API to make the API call. We start by navigating the NYT API site so that we can look up instructions on how to access their API.

We need to get an API key from the New York Times first before we can access the API. We can go to their Dev Portal to sign up and get access: <https://developer.nytimes.com/apis>. You'll need to make an account, then log in. After you have an account, you can access your Apps by clicking on your username at the top right and create an app. Enable the APIs that you want to have access to, and get the key.

After you get the key, create a new text file (I called mine `nyt-key.txt`) and paste the key into that text file. We want to avoid writing out the key in any documents we share with others, so we're going to keep the key separate and simply read in the key into R and use it to call the API.

```r
nyt_key <- read_file('~/UMD/classes/fund_comp_data_display_SURV727/code/ny_times_key.txt')
```

> linarek**WARNING: DO NOT INCLUDE THE `nyt-key.txt` FILE TO BE TRACKED BY GITHUB. YOU DO NOT WANT TO SHARE YOUR API KEYS PUBLICLY.**

## NYT Archives

After you do this, you can poke around on the API site a bit to get an idea of what data is available and how you might access that data. We'll start with the Archives API, for which the documentation can be found here: <https://developer.nytimes.com/docs/archive-product/1/overview>. The Archives API can be used to access article metadata (such as headline, byline, article URL, and so on) for a given month. Let's try getting the content for January 2019.

Following the instructions given on their site, we start with the base URL.

```r
base_url <- 'https://api.nytimes.com/svc/archive/v1/2019/1.json'
request <- GET(base_url, query = list('api-key' = nyt_key))
request$status_code
```

Note that the format of the response we get from the NYT API is slightly different. Let's take a look at what we get when we convert the JSON.

```r
response <- content(request, as = "text", encoding = "UTF-8")
nytdata <- fromJSON(response, flatten = TRUE) 
glimpse(nytdata)
```

The information we really want from this list is in `docs` under `response`. There's other stuff like copyright that we don't want to grab.

```r
nytdf <- nytdata$response$docs
head(nytdf)
```

We can then use this data frame to do analyses with. For example, we can get counts of how many articles there were by different categories.

```r
nytdf %>% group_by(news_desk) %>% summarize(count = n()) %>% arrange(desc(count)) %>% head()
```

```r
nytdf %>% group_by(section_name) %>% summarize(count = n()) %>% arrange(desc(count)) %>% head()
```

## Census API

One extremely useful API in social science research is the **Census API**. This API provides access to a wide variety of data sources on demographics and characteristics of people in the US. It contains data from the Decennial Census, but also from many other sources, such as the American Community Survey (ACS). Information about the Census API can be found at: <https://www.census.gov/data/developers/data-sets.html>.

As with the New York Times API, you will need to request an API key in order to access it. You can request an API key here: <https://api.census.gov/data/key_signup.html>. You will need to provide your email address and organization, and you should get an email with your census key shortly after that. 

After you get your Census API key, save it in a text file like before (I put mine in a file called `census-key.txt`), then read it in.

```r
cs_key <- read_file("~/UMD/classes/fund_comp_data_display_SURV727/assignments/census-key.txt")
```

Even within just one data source like the ACS, there are lots of different variables and groupings that you can pull data about. We'll start with the 1-year ACS estimates. Information about this data can be found by navigating to the American Community Survey 1-Year Data page (<https://www.census.gov/data/developers/data-sets/acs-1year.html>). 

The webpage documentation shows how to access their data as well example code and a list of variables. For example, if you scroll down to the Detailed Tables section, you can find a link to the detailed tables variables (<https://api.census.gov/data/2022/acs/acs1/variables.html>). The Examples and Supported Geographies page (<https://api.census.gov/data/2022/acs/acs1.html>) can also be helpful in identifying the data that you want.

To start, let's find something basic: the total number of people in each state. Looking at the variables table, we can see that this is called `B01001_001E` (not very intuitive, I know). Since we want this for every state, we use `state:*` as our `for` parameter. We include `NAME` as a variable we want to get since we want to know what the state names are for each of the counts. Finally, we make sure to include our key.

```r
base_url <- 'https://api.census.gov/data/2022/acs/acs1'
request <- GET(base_url, query = list('get' = 'NAME,B01001_001E',
                                      'for' = 'state:*',
                                      'key' = cs_key))
request$status_code
```

```r
response <- content(request, as = "text", encoding = "UTF-8")
censusdata <- fromJSON(response, flatten = TRUE) 
head(censusdata)
```

It looks like we need to do some cleaning with this data.

```r
censusdf <- censusdata[-1,] %>% data.frame() 
names(censusdf) <- censusdata[1,]
head(censusdf)
```

## Census API Package

We have gone over how to pull from the API manually. However, there is also a Census API package that does a lot of the hard work for us without needing to pull manually.

```r
library(censusapi)
```

To use the `censusapi` package, we use the `getCensus` function with many of the same parameters that we would provide to the census API under `query`. Below, we pull some demographic information from the 5-year ACS. Note that you still need a Census key in order to use this API.

```r
acs_il <- getCensus(name = "acs/acs5",
                    vintage = 2020, 
                    vars = c("NAME", 
                             "B01001_001E", 
                             "B06002_001E", 
                             "B19013_001E", 
                             "B19301_001E"), 
                    region = "place:*", 
                    regionin = "state:*",
                    key = cs_key)
head(acs_il)
```
