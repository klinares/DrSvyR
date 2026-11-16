---
id: "jpsm/sampling_1_SURV626/assignments/Linares_K_HW8"
source: "jpsm"
course: "SURV626"
course_title: "Sampling I"
doc_type: "assignment"
title: "Homework 8"
original: "sampling_1_SURV626/assignments/Linares_K_HW8.qmd"
pages: 
sha256: "dfe7bf7b0e496397efb874a2568088f0404407e241489face6213feacf208d10"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:17"
---


```r
pacman::p_load(knitr, kableExtra, MESS, tidyverse)

options(scipen=999)

# Set seed for reproducibility
set.seed(909)

repo_path <- "d:/repos/UMD_classes_code/sampling_1_SURV626/"

# _____________ handy functions _________________

# groups blocks into a long string
p <- function(v) {
  Reduce(f=paste, x = v)
 }

```

1.  Download the Excel file attached to HW 7.

```r
dat <- read_csv(str_c(repo_path, 
                           "assignments/HW8_data.csv")) |> 
  # rename columns
  rename(MOS=2, B_a = 3)

```

-   **(a) We are going to elect a PPeS sample using systematic selections. Use the** $MOS_{\alpha}$ **as the estimated measure of size (pretend we do not have** $B_{\alpha}$**). We will select a =30 blocks from the list of A = 4,495 in the Excel file using as measure of size the total number of occupied housing units according to the last census. What is the sampling interval k?**
    -   We calculate the sampling interval of k as 3186.1 which is the spacing between selections in PPes. We divide the total MOS by the number of selections we desire.

```r
dat <- dat |> 
  mutate(cumulative_size = cumsum(MOS), # cumulative MOS
         # lower bound for each unit
         cumulative_min = lag(cumulative_size, default = 0) + 1)

# parameters given
A <- 4495 # total number of blocks in the list
a <- 30 # number of blocks to select
N <- sum(dat$MOS) # total MOS (occupied housing units)

# calculate sampling interval k
k <- N/a

cat(str_c("The sampling interval K = ", k))
```

\newpage

-   **(b) The minimum sufficient size for a block is b\* = 25 occupied housing units. For the sake of replication, select your random start number using the random number table in ‘SURV 626 Random Digits fall 25.pdf’ starting at the upper left corner, row 1, columns 1-5 (first number, 49018). Use a random start with only one decimal place (i.e. first number=4901.8). Specify the random start. Give the block IDs for each of the selected linked clusters, the selection number (i.e. the random start plus intervals – RS, RS+k, RS+2k…), the total number of occupied housing units in the sample clusters, and the first and second sampling rates for each selected block.**

    -   We specify the random start as 4901.8. However, the random number should be between 1 and k, which in this case it is not and the random start exceeds K which we need to scale values by 100 to maintain proportional relationship. The process renders only 29 selected blocks. Instead, we actually have to move the decimal places to two places so our random number is now 490.18. With k this allows us to actually select 30 blocks.

\newpage

```r
#RN <- 490.18*100
RN <- 1225.6*100 # correct RN
k <- N/a * 100

#  Generate selection numbers: RS, RS+k, RS+2k, ..., RS+(a-1)k
RN_sample <- round(seq(RN, N*100, k)/100)

RN_sample |> tibble() |> kable()
```

\

-   Below we print the selected ID blocks and also show that our selection values are within each block's cumulative minimum and cumulative size. We also show the total number of occupied housing units in the sample clusters as 5,651. Finally, we print the $B_a$ for each block along. Below in table 1 we compute the sampling rate of .007, and show the second $f_h$ sampling rate for each block in the table.

```r
b_star <- 25

dat_selected  <- dat |> 
  add_column(RN_sample |> tibble() |> data.table::transpose()) |> 
  # create flag for blocks that are selected
  mutate(selected =
           as.numeric(if_any(starts_with("V"), ~
                               between(.x, cumulative_min,
                                       cumulative_size)))) |> 
  # drop select population elements
select(-starts_with("V"))

```

\newpage

```r
dat_selected |>
  filter(selected == 1) |>
  mutate(selection = RN_sample,
         Total = sum(MOS)) |> 
  select(-selected) |> 
  kable()
```

\newpage

-   **(c) How have you handled oversized units?**
    -   We note that block 1297 with 3,239 is large, and is larger than our sampling interval. The probability of selecting it twice is higher and we would want to consider making it into it’s own strata.

\

-   **(d) How have you handled undersized units? Be specific about the method used to address undersized units.**
    -   The linking is done by first selecting the 30 blocks from the overall list. When the next units on the list do not meet the sufficient size (undersized units) required of housing units occupied of 25, we move forward in the list until the first unit that meets the minimum requirement is achieved. For all the units that did not meet the requirement they are cumulated backwards until a linked unit of minimum sufficient size is created. We do this process for all the blocks initially selected. Overall there were 220 blocks linked into 30 clusters with a total housing units occupied of 5,989.

```r
n <- a # number of blocks to select
min_MOS <- b_star # minimim MOS in cell needed

# we link the selected blocks
dat_linked <- dat_selected |>
  mutate(
    # flag if minimum MOS not met
    min_n_req = ifelse(MOS >= min_MOS, 1 , 0),
    # create links and convert to clusters
    linking = lead(min_n_req, default=1),
    # assign clustering
    cluster = cumsum(lag(linking, default=1))
  )

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
  arrange(desc(ID)) |>
  # sum values and reset when min is achieved
  group_by(blocks =
             cumsumbinning(MOS, min_MOS-1, TRUE) -0) |>
  ungroup() |>
  arrange(ID) |>
  mutate(blocks = abs(blocks - max(blocks)) + 1 )


# create a vector with linkage
block_filter <- dat_clustered |>
  filter(selected==1) |>
  pull(blocks)

# show cluster of blocks selected, total HUs
dat_linked_final <- dat_clustered |>
  filter(blocks %in% block_filter) |>
  select(ID, MOS, blocks) |>
  mutate(ID=as.character(ID)) |>
  group_by(blocks) |>
  reframe(ID= p(ID),
          blocks = cur_group_id(),
          HU_total = sum(MOS)) |>
  # add RN values
  mutate(SN = linkage$Selection) 

```

\newpage

```r
dat_linked_final|>
  rename(HUs=HU_total) |> 
  kable() 
```

\newpage

-   Table: 1: First and Second Sampling Rates for Each Block

```r
f <- a/A ; 

f |> tibble() |> kable()


f_h <- dat_linked_final |>
  mutate( # First stage sampling rate
    f1 = HU_total / (k/100) ,  # PPS selection probability
    # Second stage sampling rate (to maintain epsem)
    f1 = pmin(f1,1),
    f2 = ifelse(f1 >= 1, f, b_star/HU_total)
    ) |> 
  rename(HUs=HU_total)

f_h |> 
  select(blocks:f2) |> 
  kable(format = "latex", escape = FALSE) |> 
  column_spec(2, width = "5cm")
```

\newpage

\

-   **(e) Assume that after the selection of the blocks, a list of the current number of occupied housing units in the selected blocks,** $B_{\alpha}$**, is obtained. Compute the actual sub-sample size,** $x_{\alpha}$**, for each selected block.**

    -   Below we print in the table the actual sub sample size for each block within each cluster. The total current occupied units is 7,946. The total expected sample size is 3,140.

```r
# First, create a proper mapping between clusters and the blocks in dat_linked_final
cluster_subsample <- dat_linked_final |>
  rename(cluster = blocks) |>
  mutate(
    # Extract the individual IDs to calculate B_a totals
    cluster_b_alpha = map_dbl(str_split(ID, " "), function(ids) {
      sum(dat$B_a[as.numeric(ids)])
    })
  ) |>
  rename(cluster_MOS = HU_total    ) |>
  mutate(
    # Calculate f1 and f2 correctly
    f1 = cluster_MOS / N,
    f1 = pmin(f1 * a, 1),  # Cap at 1 for oversized
    f2 = ifelse(f1 >= 1, a/A, b_star / cluster_MOS),
    x_alpha = round(f2 * cluster_b_alpha, 3)
  )

# Display results
cluster_subsample |>
  select(cluster, cluster_MOS, cluster_b_alpha, f1, f2, x_alpha) |>
  kable(digits = 4,
        col.names = c("Cluster", "MOS", "B_α", "f1", "f2", "x_α"))
```

\newpage

-   **Problem 2. A state has approximately1,800, 000N = students at the last head count less than one year ago. These students are enrolled in5, 000A = schools. It is proposed that a sample of approximately18, 000n = students be selected at the rate1 100f = to achieve desired levels of precision. Four sample selection methods for schools, and eight methods for selection of students within schools have been proposed. For each of the combinations a)-d) of school selection methods and i)-viii) of student within selected school selection methods below, list those which result in an epsem selection across two- stages. For each combination that is epsem, write the two stage selection formulas.**

```r
N_students <- 1800000 # Total students in state
A_schools <- 5000 # Total number of schools
n_target <- 18000 # Target sample size
f_overall <- 1/100
```

-   \(a\) Select schools with probabilities proportional to measures of size $Mos_{\alpha}$ that are the count of students in each school at the head count last year.

-   \(b\) Select schools with probabilities proportionate to measures of size $M_{\alpha}$ that are counts of students obtained from a commercial firm that claims to have up-to-date lists of the number of students in each school.

-   \(c\) Select a = 250 schools using simple random sampling.

-   \(d\) Select schools systematically from a geographically ordered list of schools using an interval of k = 20 after a random start from 1 to 20.

Student selection

i\) Select exactly 72 students at random and without replacement from the $B_{\alpha}$ students actually in the school.

ii\) Select students systematically with interval $M_{\alpha}/5$ from the list of $B_{\alpha}$ students actually in the school.

iii\) Select systematically exactly 72 students from $B_{\alpha}$ students actually in the school.

iv\) Select systematically with interval 5 from $B_{\alpha}$ students actually in the school.

v\) List the $C_{\alpha}$ classrooms (roughly 24 students in each classroom) in the school and select classrooms systematically with interval 5 from $C_{\alpha}$ classrooms in the school.

vi\) Select students systematically with interval $M_{\alpha}/5$ from the list of B  students actually in the school.

vii\) List the $C_{\alpha}$ classrooms (roughly 24 students in each classroom) in the school and select classrooms systematically with interval $M_{\alpha}/5$ from $C_{\alpha}$ classrooms in the school.

viii\) List the $C_{\alpha}$ classrooms (roughly 24 students in each classroom) in the school and select exactly three classrooms systematically from $C_{\alpha}$ in the school.

-   For EPSEM, the overall selection probability must be constant for all elements.

```r
# PROBLEM 2 - CORRECTED VERSION (LaTeX-safe)

epsem_combinations <- tibble(
  School = c("(a)", "(b)", "(b)", "(c)", "(c)", "(d)", "(d)"),
  Student = c("(vi)", "(ii)", "(vii)", "(iv)", "(v)", "(iv)", "(v)"),
  `School Method` = c(
    "PPS with MOS_a",
    "PPS with M_a", 
    "PPS with M_a",
    "SRS a=250",
    "SRS a=250",
    "Systematic k=20",
    "Systematic k=20"
  ),
  `Student Method` = c(
    "Syst interval MOS_a/5",
    "Syst interval M_a/5",
    "Syst interval M_a/5 (class)",
    "Syst interval 5",
    "Syst interval 5 (class)",
    "Syst interval 5", 
    "Syst interval 5 (class)"
  ),
  `Stage 1` = c(
    "f1 prop to MOS_a",
    "f1 prop to M_a",
    "f1 prop to M_a",
    "f1 = 1/20",
    "f1 = 1/20",
    "f1 = 1/20",
    "f1 = 1/20"
  ),
  `Stage 2` = c(
    "f2 = 5/MOS_a",
    "f2 = 5/M_a", 
    "f2 = 5/M_a",
    "f2 = 1/5",
    "f2 = 1/5",
    "f2 = 1/5",
    "f2 = 1/5"
  ),
  `Overall` = c(
    "f = constant",
    "f = constant",
    "f = constant",
    "f = 1/100",
    "f = 1/100",
    "f = 1/100",
    "f = 1/100"
  )
)

# Display the table
epsem_combinations |> 
  kable(caption = "EPSEM Combinations for Two-Stage Sampling",
        align = c("c", "c", "l", "l", "l", "l", "l"))
```

\newpage

## Problem 3: Please, in relation to this Homework 8, report:

### (a) Time Spent

-   Approximately 7.5 hours to complete all parts.

### (b) Difficulty Rating

-   **Rating: 9/10** - Getting code to work for the linking involved a lot of searching through google.
