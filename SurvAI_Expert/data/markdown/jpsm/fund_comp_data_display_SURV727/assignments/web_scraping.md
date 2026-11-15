---
id: "jpsm/fund_comp_data_display_SURV727/assignments/web_scraping"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "assignment"
title: "Assignment 3"
original: "fund_comp_data_display_SURV727/assignments/web_scraping.qmd"
pages: 
sha256: "e72a13b24708694ad5b4fee25ba1daa36ac274f8099f1402e38015615e184350"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:56"
---


\
\

You may work in pairs or individually for this assignment. Make sure you join a group in Canvas if you are working in pairs. Turn in this assignment as an HTML or PDF file to ELMS. Make sure to include the R Markdown or Quarto file that was used to generate it. Include the GitHub link for the repository containing these files.

```r
pacman::p_load(rvest, knitr, robotstxt, viridis, tidytext, tidyverse)
```

\

## Web Scraping

In this assignment, your task is to scrape some information from Wikipedia. We start with the following page about Grand Boulevard, a Chicago Community Area.

<https://en.wikipedia.org/wiki/Grand_Boulevard,_Chicago>

The ultimate goal is to gather the table "Historical population" and convert it to a `data.frame`.

As a first step, read in the html page as an R object. Extract the tables from this object (using the `rvest` package) and save the result as a new object. Follow the instructions if there is an error. Use `str()` on this new object -- it should be a list. Try to find the position of the "Historical population" in this list since we need it in the next step.

-   [We find that we can use the `rvest::html_table()` function to extract information from the "Historical Population" table. We find that the node we are looking for is under the CSS \*"table"\* and that the 2nd element contains the information we seek.]{style="color:dodgerblue;"}
    1.  [Build the URL.]{style="color:dodgerblue;"}
    2.  [Read the web html into a list object in r using `rvest::read_html()`.]{style="color:dodgerblue;"}
    3.  [select the HTML tags using CSS selectors (or xpath expressions) to extract using the `rvest::html_nodes()`.]{style="color:dodgerblue;"}[^1]

[^1]:
    -   [Note. I tried getting the xpath using selectorgadget, resulting in the following: \_xpath = '//\*[contains(concat( " ", @class, " " ), concat( " ", "us-census-pop-left", " " ))]'\_, but for some pages the historical is on the "right", and sometimes on the "left." This means that the xpath above has to reflect the position, thus making it dynamic.]{style="color:dodgerblue;"}

```r
# build the URL needed by pasting the base URL with the city location
base_url <- "https://en.wikipedia.org/wiki/"
chicago_city <- "Grand_Boulevard,_Chicago"

# read the web htmnl
url <- read_html(str_c(base_url, chicago_city))      

# extract the necessary node/tag
nds <-  html_nodes(url, "table") 
```

\

Extract the "Historical population" table from the list and save it as another object. You can use subsetting via `[[…]]` to extract pieces from a list. Print the result.

You will see that the table needs some additional formatting. We only want rows and columns with actual values (I called the table object `pop`).

-   [We build a helper function `html_table_fun()` that extracts the node for the data we need and clean the data as needed. This function will be used to scrap more tables later in this document.]{style="color:dodgerblue;"}

```r
# create a function to extract 'table' from html
## keep what is needed and rename new columns into a data frame
html_table_fun <- function(nds_html, chi_city) {
  
  # we require the 2nd element in this list
  html_table(nds_html)[[2]] |> 
    
  # remove last row since it does not contain relevant information
  filter(row_number() <= n()-1) |> 
    
  # remove empty column
  select(-3) |> 
    
  # give last column a descriptive name
  rename(percent_change = 3) |> 
    
  # clean numeric values
    mutate(Census = as.numeric(Census),
      Pop. = str_remove(Pop., ","),
           Pop. = as.numeric(Pop.),
           percent_change = str_remove(percent_change, "\\%"),
      percent_change = na_if(percent_change, "—"),
      percent_change = str_replace(percent_change, "−", "-"),
      percent_change = as.numeric(percent_change),
      # add city
      city = str_replace_all(chi_city, "_", " ")
    )
} 

```

-   [Here we print out the post processed table after identifying the Grand Boulevard, Chicago population table. To get this table, we used the `html_table_fun()` helper function to extract and clean text from the wiki page.]{style="color:dodgerblue;"}

```r
pop <- html_table_fun(nds, chicago_city) 
  
pop |> kable()
```

## 

## Expanding to More Pages

That's it for this page. However, we may want to repeat this process for other community areas. The Wikipedia page https://en.wikipedia.org/wiki/Grand_Boulevard,\_Chicago has a section on "Places adjacent to Grand Boulevard, Chicago" at the bottom. Can you find the corresponding table in the list of tables that you created earlier? Extract this table as a new object.

**Figure 1: Adjacent places East of Grand Boulevard, Chicago**

![](images/clipboard-1815302503.png)

Then, grab the community areas east of Grand Boulevard and save them as a character vector. Print the result.

We want to use this list to create a loop that extracts the population tables from the Wikipedia pages of these places. To make this work and build valid urls, we need to replace empty spaces in the character vector with underscores. This can be done with `gsub()`, or by hand. The resulting vector should look like this: "Oakland,\_Chicago" "Kenwood,\_Chicago" "Hyde_Park,\_Chicago"

To prepare the loop, we also want to copy our `pop` table and rename it as `pops`. In the loop, we append this table by adding columns from the other community areas.

-   [Below we present adjacent neighborhoods East of Grand Boulevard, Chicago. These are highlighted in yellow in Figure 1. We will use these city names to loop over and scrap historical population tables for each location to add to our current pop table.]{style="color:dodgerblue;"}

```r
# the table we are looking for is in element 4
# strip only the name to the right
places_adjacent <-  html_table(nds[[4]]) |> 
  select(3) |> 
  rename(cities = 1) |> 
  filter(str_detect(cities, "Chicago")) 

kable(places_adjacent)
```

Build a small loop to test whether you can build valid urls using the vector of places and pasting each element of it after `https://en.wikipedia.org/wiki/` in a for loop. Calling `url` shows the last url of this loop, which should be `https://en.wikipedia.org/wiki/Hyde_Park,_Chicago`.

Finally, extend the loop and add the code that is needed to grab the population tables from each page. Add columns to the original table `pops` using `cbind()`.

-   [We loop through each neighborhood to build a relevant URL, scrap the necessary historical population data from Wikipedia, and join all tables into a data frame. Below we print out a random set of rows.]{style="color:dodgerblue;"}
    1.  [confirm that URL is valid.]{style="color:dodgerblue;"}
    2.  [scrap the webpage.]{style="color:dodgerblue;"}
    3.  [clean data and combine.]{style="color:dodgerblue;"}

```r
# loop through each city name
pops <- map_dfr(places_adjacent$cities, function(x) {
  
  # build the URL
  chi_city = str_replace_all(x, " ", "_")
  print(str_c("Is URL ", str_c(base_url, chi_city), 
              " is valid? . . . ",
              paths_allowed(str_c(base_url, chi_city))
              ))
  
  # read in each webpage
  url = read_html(str_c(base_url, chi_city))              
  nds =  html_nodes(url, "table") 
  
  # extract table needed
  dat = html_table_fun(nds, chi_city) 
  
  return(dat)
  
}) |> 
  # add Grand Boulevard
  full_join(pop)

pops |> 
  DT::datatable()
```

-   Now that we have all of the historical population counts for each city, we can visualize them.

```r
pops |> 
  ggplot(aes(x=Census, y=Pop., color=city)) +
  geom_line() +
  ggthemes::theme_hc() +
  scale_color_viridis_d()
```

## Scraping and Analyzing Text Data

Suppose we wanted to take the actual text from the Wikipedia pages instead of just the information in the table. Our goal in this section is to extract the text from the body of the pages, then do some basic text cleaning and analysis.

First, scrape just the text without any of the information in the margins or headers. For example, for "Grand Boulevard", the text should start with, "**Grand Boulevard** on the [South Side](https://en.wikipedia.org/wiki/South_Side,_Chicago "South Side, Chicago") of [Chicago](https://en.wikipedia.org/wiki/Chicago "Chicago"), [Illinois](https://en.wikipedia.org/wiki/Illinois "Illinois"), is one of the ...". Make sure all of the text is in one block by using something like the code below (I called my object `description`).

-   [Again we read in the previous URL, but this time we can use SelectGadget to find the xpath we need to scrap description text only.]{style="color:dodgerblue;"}
    -   [We need to use the `rvest::html_text2()` to read the text we need, and do a little bit of cleaning.]{style="color:dodgerblue;"}
    -   [We print out the first 350 characters after combining text together.]{style="color:dodgerblue;"}

```r
url <- read_html(str_c(base_url, chicago_city))      
nds <- html_nodes(url, xpath= '//p')

description <- nds |>  
  html_text2() |> 
  paste(collapse = " ") |> 
  str_trim()

str_extract(description,"^.{343}") |> kable(col.names = "Description")
```

\

Using a similar loop as in the last section, grab the descriptions of the various communities areas. Make a tibble with two columns: the name of the location and the text describing the location.

-   [Again, we iterate over the Chicago neighborhoods of interest to scrap the web URLs and parse descriptive texts to save into a tibble. Below we print the first 300 characters of each neighborhood's text descriptions after post processing.]{style="color:dodgerblue;"}

```r
descriptions <- 
  # combine all Chicago neighborhoods together
  places_adjacent |> 
  add_row(cities = str_replace_all(chicago_city, "_", " ")) |> 
  # create URLS, 
  mutate(url = str_c(base_url,  str_replace_all(cities, " ", "_"))) |> 

  #scrap data, and parse description text
  mutate(description = 
           map(url, function(x){
             
             # extract node from html 
             nds = html_nodes(
               read_html(
                 x),
               xpath= '//p' # this grabs all text in the body
               )  
             
             # parse description text
             dat = nds |>  
               html_text2() |> 
               paste(collapse = " ") |> # removes unnecessary special characters
               str_trim() # trims white space before and after string
             }) |> 
           as.character()
  )

str_extract(descriptions$description,"^.{300}") |> 
  kable(col.names = "Description of Text")


```

\

Let's clean the data using `tidytext`. If you have trouble with this section, see the example shown in <https://www.tidytextmining.com/tidytext.html>

Create tokens using `unnest_tokens`. Make sure the data is in one-token-per-row format. Remove any stop words within the data. What are the most common words used overall?

-   [We see that we have almost $4,800$ tokenized words before removing stopwords.]{style="color:dodgerblue;"}

```r
descriptions_token <- descriptions |> 
  # tokenize, one row per word
  unnest_tokens(words, description)

descriptions_token |> nrow() |> kable(col.names = "Total Tokens")


descriptions_token |> 
  select(-url) |> 
  head() |> 
  kable()
```

-   [We use the stopwords package to remove stopwords and are left with less rows than before. However, we also add the city names to the stopwords list as well as any numerical digits since we do not need to see these. After removing stopwords we are left with around $2,500$ tokenized words.]{style="color:dodgerblue;"}

```r
descriptions_token <- descriptions_token |> 
  anti_join(get_stopwords() |> rename(words=word)) |> 
  # remove city names as well
  filter(!words %in%
    c("chicago", "boulevard", "hyde", "park", "kenwood", "oakland"),
    # also remove numbers
    !str_detect(words,  "\\d+")
  )

descriptions_token |> nrow() |> kable(col.names = "Total Tokens")


```

-   [Below we report the most commonly found words (in proportion to all of the text in the corpus) regardless of city for words that appear at least $1\%$ of the time.]{style="color:dodgerblue;"}

```r
# top most common words regardless of city
descriptions_token |> 
  select(-url) |> 
  group_by(words) |> 
  count() |> 
  ungroup() |> 
  mutate(prop = round(n/sum(n), 3 )) |> 
  filter(prop >= .01) |> 
  arrange(desc(prop)) |> 
  kable()
```

\

Plot the most common words within each location. What are some of the similarities between the locations? What are some of the differences?

-   [We plot words within each city that represent at least $1\%$ of all text within the specific city. We see that the word]{style="color: dodgerblue"} ["**street**"]{style="color: forestgreen"} [appears in 3 of the 4 cities. The word]{style="color: dodgerblue"} ["**neighborhood**"]{style="color: forestgreen"} [appears in the Hyde Park and Grand Boulevard locations, while the word]{style="color: dodgerblue"} ["**community**"]{style="color: forestgreen"} [appears in Kenwood and Oakland. Within Hyde Park, the word]{style="color: dodgerblue"} ["**university**"]{style="color: purple"} [is one of the top words, leading us to think that there might be a university in this location (we confirmed that the University of Chicago is in Hyde Park). We also assumed that since the word]{style="color: dodgerblue"} ["**lake**"]{style="color: darkred"} [appeared a lot in Oakland, we would find a popular lake. We assumed wrong as what this analysis is picking up is "*Lake Shore Dr*", a popular street in Chicago. We learn here that this method of tokenizing and counting word popularity leads to some useful descriptions of the data, but there is a risk of making mistakes as we are lacking context.]{style="color: dodgerblue"}

```r
#| column: screen
#| out-width: 70%
#| fig-format: svg
#| 
# create a table with the most common words for each city
descriptions_token |> 
  group_by(cities, words) |> 
  count() |> 
  group_by(cities) |> 
  mutate(prop = n/sum(n)) |> 
  filter(prop >= .01) |> 
  ungroup() |> 
  mutate(words = reorder_within(words, prop, cities)) |> 
  ggplot(aes(x=prop, y=words, fill=factor(cities))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~cities, scales = "free") +
  scale_y_reordered() +
  ggthemes::theme_hc() +
  scale_fill_viridis_d()
```
