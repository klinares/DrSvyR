---
id: "jpsm/applied_sampling_SURV625/assignments/HW5"
source: "jpsm"
course: "SURV625"
course_title: "Applied Sampling"
doc_type: "assignment"
title: "Homework 5"
original: "applied_sampling_SURV625/assignments/HW5.qmd"
pages: 
sha256: "6a441d2a172f464dae6aeaf545373912318b2fe8e9c40f321a934e3785ebc6cd"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T14:15:59"
---


```r
knitr::opts_chunk$set(echo=TRUE,cache=TRUE, 
                      autodep=TRUE, cache.comments=FALSE,
                      message=FALSE, warning=FALSE,
                      fig.width=4.5, fig.height=3)

# package mess used for linkage
pacman::p_load(knitr, MESS, tidyverse)


options(scipen=999)

# _____________ handy functions _________________

# groups blocks into a long string
p <- function(v) {
  Reduce(f=paste, x = v)
 }


```

## 1. The following is the distribution of occupied housing units and blocks for two counties in Michigan. A stratified PPeS sample of n = 3000 housing units in a = 100 blocks with minimum sufficient size b per block is to be selected across the counties. The counties and the subdivisions within each county of river and non-river blocks serve as four (4) strata.

a\. **Allocate the sample blocks across the four strata proportionate to occupied housing units. How have you handled rounding of sample blocks?**

-   We start by organizing the data into the four strata. We than build proportionate allocation weights for each strata number of occupied housing units divided by the total. These weights are than used to calculate the allocated sampling blocks based on the number of 100 blocks we were given earlier. We round down and get an equal total of 100 blocks selected across the from strata.

```r
n <- 100 # sample blocks

dat <- tibble(
  county = rep(c("Allegan", "Kalamazoo"), each=2),
  total_county = rep(c(37265, 94523), each=2),
  river = rep(c("yes", "no"), 2),
  occupied_hu = c(8521, NA, 17224, NA)
) |> 
  # get HU counts for county_non_river
  group_by(county) |> 
  mutate(occupied_hu = ifelse(is.na(occupied_hu),
                               total_county - sum(occupied_hu, na.rm = TRUE),
                               occupied_hu)) |> 
  ungroup() |> 
  # add proportionate allocation
  mutate(weight = occupied_hu / sum(occupied_hu),
         weight = round(weight, 3),
         units_selected = round(weight * n))

dat |> kable()
```

\

b.  **Give the overall sampling fraction f across the four strata.**

-   We use the total number of occupied housing units in these two counties as the denominator and as the numerator we use the provided number of housing units to be 3000 to get the following sampling fraction.

```r
sampled_HU <- 3000
pop_hu <- dat |> tally(occupied_hu) |> pull()
f <- sampled_HU/pop_hu ;  f

```

\

c.  **Maintaining epsem, what value of b should be used in each of the four strata?**

-   We define the zone size as:

$$
\frac{\sum _{i \in h} MOS_hi} {n_h}
$$

-   to provide the values for b for each of the four strata

```r
dat |>
  mutate(b = (occupied_hu*f) / units_selected,
         b = round(b,2)) |> 
  kable()
```

\newpage

2.  **Download the Excel file provided with this homework (a geographically sorted list of blocks).**

```r
dat <- readxl::read_xlsx(
  "~/repos/UMD_classes_code/applied_sampling_SURV625/homework/HW_5_data.xlsx") |> 
  janitor::clean_names() |> 
  drop_na() |> 
  # create new column for lower bound of cumulative value
  mutate(cumulative_min = 1 + lag(cumulative_size, default = 0)) 

dat |> 
  head() |>  
  select(-id, -state, -county) |> 
  kable()
```

**a. Select a systematic PPeS sample of a = 20 blocks from the list of A = 4,495 in the Excel file. The minimum sufficient size for a block is 50 occupied housing units. Specify the sampling interval, and the random start. List selected blocks, the selection number (the random start plus interval), and the total number of occupied housing units in the sample blocks. Document how the random start was determined, in a way that would allow someone to replicate your selection process exactly.**

-   First we calculate the sampling interval k as N/n where N is the total population elements and n is the number of clusters to be selected.

```r
n <- 20 # number of sample blocks to select
min_MOS <- 50 # minimim MOS in cell needed

# total housing units
N <- dat |> summarise(sum(housing_units_occupied)) |> pull() 


# sampling interval
k <- N/n; k
```

-   We still need to move the decimals to the right and we can do so by multiplying k by 100 to drop the decimal places.

```r
k <- k * 100 ; k
```

-   We can now select a random start from 1 to k using a random generator. However, since we moved the decimal points, our RN value will be a multiple of 10. After identifying a random start, we select Select population elements: RN, RN+k, RN+2k, …, RN+(n-1)k. We will than divide this vector by 100 to get values in the range of 1 to N housing units in the data,

```r
# random start
set.seed(909) 
RN <- sample(1:k, 1) ; RN

# create vector of selected population elements.
RN_sample <- round(seq(RN, N*100, k)/100)  # will help us pick blocks
```

-   We now select 20 blocks from the list.

```r

dat_selected <- dat |> 
  # add population elements
  add_column(RN_sample |> tibble() |> data.table::transpose()) |> 
  # create flag for blocks that are selected
    mutate(selected = 
             as.numeric(if_any(starts_with("V"), ~ 
                                 between(.x, cumulative_min, 
                                         cumulative_size)))) |> 
  # drop select population elements
  select(-starts_with("V")) 


dat_selected |> 
  filter(selected == 1) |> 
  mutate(selection = RN_sample,
         Total = sum(housing_units_occupied)) |> 
  select(tract , block, cumulative_min, selection, cumulative_size, 
         housing_units_occupied, Total)  |> 
    kable(col.names = c("Tract", "Blk", "HU_min", "SN", "HU_max", "HUs", "Total_HUs") )
  
```

-   Above we show 20 blocks selected using the sampling interval of 467395, or 4673.95, and our random start of 392,268 (multiple of 100). From these two values, we calculate selection numbers shown under the "selection" column, and also print out the minimum cumulative and cumulative total number of housing units occupied to show that the selection number falls within these ranges which is how we determine which blocks to select. Furthermore, We show the number of housing units occupied in each block with a total of 2,128. SN stands for selected number. However, we do see for instance block 1009 (2nd row) does not meet the minimum requirement of 50 housing units, and linking post selection is needed which we do next.
-   The linking is done by first selecting the five blocks from the overall list. When the next units on the list do not meet the sufficient size required of 50 housing units occupied we move forward in the list until the first unit that meets the minimum requirement is achieved. For all the units that did not meet the requirement they are cumulated backwards until a linked unit of minimum sufficient size is created. We do this process for all the blocks initially selected. Overall there were 665 blocks linked within 10 clusters with a total housing units occupied of 9,735.

```r

# we link the selected blocks
dat_linked <- dat_selected |> 
  mutate(
   # flag if minimum MOS not met
    min_n_req = ifelse(housing_units_occupied >= min_MOS, 1 , 0),
    # create links and convert to clusters
    linking = lead(min_n_req, default=1),
    # assign clustering
    cluster = cumsum(lag(linking, default=1))) 

  
# create a vector with linkage
linkage <- dat_linked |> 
  filter(selected == 1) |> 
  select(cluster) |> 
  mutate(Selection = RN_sample)


# show cluster of blocks selected, total HUs
dat_clustered <- dat_linked |> 
  filter(cluster %in% linkage$cluster) |> 
  # now we link blocks within clusters
  group_by(cluster) |> 
  # start clusters at 1
  mutate(cluster = cur_group_id()) |> 
  # start with last id to link backwards
  arrange(desc(id)) |> 
  # sum values and reset when min is achieved
  group_by(blocks = 
               cumsumbinning(housing_units_occupied, min_MOS-1, TRUE) -0) |> 
  ungroup() |> 
  arrange(id) |>
  mutate(blocks = abs(blocks - max(blocks)) + 1 )


# create a vector with linkage
block_filter <- dat_clustered |> 
  filter(selected==1) |> 
  pull(blocks)


# show cluster of blocks selected, total HUs
#dat_linked_final <- 
dat_clustered |> 
  filter(blocks %in% block_filter) |> 
  select(id, housing_units_occupied, blocks) |> 
  mutate(id=as.character(id)) |> 
  group_by(blocks) |> 
  reframe(id= p(id),
          blocks = cur_group_id(),
          HU_total = sum(housing_units_occupied)) |> 
  # add RN values
  mutate(SN = linkage$Selection) |> 
  kable()

```

\

**b. Do you have oversized units? If any, describe how you have handled oversized units**

-   We note that block 2001 with 1,135 is large, yet it is smaller than our sampling interval. If it were larger, the probability of selecting it twice would be higher and we would want to consider making it into it's own strata.

```r
dat |> 
  filter(housing_units_occupied == max(housing_units_occupied)) |> 
  select(id, tract, block, housing_units_occupied) |> 
  kable()
```

\

**c. Suppose the following are the first five blocks selected.**

| ID  | STATE | COUNTY | TRACT  | BLKGRP | BLOCK |
|-----|-------|--------|--------|--------|-------|
| 142 | 26    | 077    | 000201 | 1      | 1064  |
| 349 | 26    | 077    | 000500 | 2      | 2002  |
| 452 | 26    | 077    | 000600 | 4      | 4001  |
| 655 | 26    | 077    | 001000 | 6      | 6013  |
| 789 | 26    | 077    | 001300 | 1      | 1016  |

i\. **Implement the ‘linking after selection’ procedure described in the lecture notes for each of these five selections, and describe the five resulting linked blocks that would be included in the sample.**

-   We use the same linkage procedure as in 2.a. and find that there are 36 linked blocks shown below.

```r
ids <- c(142, 349, 452, 655, 789)

dat_linked <- dat |> 
  mutate(
    # select blocks
    selected = ifelse(id %in% ids, 1, 0),
   # flag if minimum MOS not met
    min_n_req = ifelse(housing_units_occupied >= min_MOS, 1 , 0),
    # create links and convert to clusters
    linking = lead(min_n_req, default=1),
    # assign clustering
    cluster = cumsum(lag(linking, default=1))) 

# create a vector with linkage
linkage <- dat_linked |> 
  filter(selected == 1) |> 
  pull(cluster)


p <- function(v) {
  Reduce(f=paste, x = v)
 }

# show cluster of blocks selected, total HUs
dat_clustered <- dat_linked |> 
  filter(cluster %in% linkage) |> 
  # now we link blocks within clusters
  group_by(cluster) |> 
  # start clusters at 1
  mutate(cluster = cur_group_id()) |> 
  # start with last id to link backwards
  arrange(desc(id)) |> 
  # sum values and reset when min is achieved
  group_by(blocks = 
               cumsumbinning(housing_units_occupied, min_MOS-1, TRUE) -0) |> 
  ungroup() |> 
  arrange(id) |>
  mutate(blocks = abs(blocks - max(blocks)) + 1 )

dat_clustered |> 
  select(id, housing_units_occupied, blocks) |> 
  group_by(blocks) |> 
  reframe(id= p(id),
          HU_total = sum(housing_units_occupied)) |> 
  kable()
```

-   We show next the five selected blocks with linkage with a total housing units of 419.

```r

# create a vector with linkage
block_filter <- dat_clustered |> 
  filter(id %in% ids) |> 
  pull(blocks)


dat_linked_final <- dat_clustered |> 
  filter(blocks %in% block_filter) |> 
  select(id, housing_units_occupied, blocks) |> 
  group_by(blocks) |> 
  reframe(id= p(id),
          blocks = cur_group_id(),
          HU_total = sum(housing_units_occupied)) 

dat_linked_final |> 
  kable()
```

\

**ii. The overall sampling fraction is f = 0.001. What sampling rates should be used within each of the five sets of linked blocks to achieve epsem across the two stages (blocks, then occupied housing units)? (Hint: Remember that the housing units at the second stage will be randomly selected from all units in the set of linked blocks, not just the units in the five original selections above.)**

```r
f <- .001 # overall selection probability

f_h <- dat_linked_final |> 
  mutate(f_h = f * (N / (n * HU_total) ) ) 

f_h |> 
  kable()
```

-   We compute sampling rates for each of the linked block sets for the first 5 selected blocks.

\

**iii. For the first “linked” selection, suppose that field canvassing procedures yield 𝐵! = 90. What two possible values might you see for the achieved subsample size from the first selection?**

-   We now use PPS (probability proportion size), and using the $f_h$ calculated above, we now need to estimate the number elements that will be selected if the housing units are of size 90.

```r

housing_units = 90

expected_hu <- f_h |> 
      # select cluster
  slice(1) |> 
  summarise(
    f_h * housing_units) |> 
  pull()

expected_hu

```

-   The expected number of housing units to be selected is between 5 and 6, which we can calculated the expected probabilities.

```r
# lower estimate
lower <- 5
# upper estimate
upper <- 6

lower_expected <- (lower * expected_hu) + (upper * (1-expected_hu))
upper_expected <- 1 - lower_expected

tibble(expected_values = c(lower, upper),
       expected_prob = c(lower_expected, upper_expected)) |> 
  mutate(expected_prob = round(expected_prob, 2)) |> 
  kable()
```

-   We pick the highest expected probability from the two choices we have, and go with 5 housing units to sample from this set of selected blocks.
