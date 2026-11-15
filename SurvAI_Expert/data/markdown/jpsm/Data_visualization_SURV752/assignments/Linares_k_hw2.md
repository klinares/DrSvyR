---
id: "jpsm/Data_visualization_SURV752/assignments/Linares_k_hw2"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "assignment"
title: "Homework 2: Lab Exercise, Comparing Simple Plots"
original: "Data_visualization_SURV752/assignments/Linares_k_hw2.qmd"
pages: 
sha256: "b10a4fe6979935d6c6ce5e03dabb7d6ab9a452431c58aa31ccff704ac0f7e1f4"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:00:51"
---


# Let's Create Fake Polling Data

```r
#| message: false
#| warning: false
# this is my way of loading packages using the pacman package
pacman::p_load(ggthemes, knitr, patchwork, viridis, tidyverse)

theme_set(theme_minimal())
# path to data
repo_path <- "d:/repos/UMD_classes_code/Data_visualization_SURV752/"
```

The numbers are percentages of respondents who see a party as being competent in three policy areas. In addition, we create a variable for which party respondents support.

```r
#| message: false

# Create polling data in tidy format
poll_data <- tibble(
  party = c("Conservative", "Liberal", "Green", "Socialist"),
  economy = c(.65, .40, .52, .28),
  social = c(.36, .38, .08, .73),
  foreign = c(.40, .35, .10, .05),
  support = c(.38, .35, .12, .15)
)

# Display data table
poll_data |>
  kable()
```

\

Using this polling data, compare the perceived policy competence of the four political parties:

-   Start out by comparing economic and social policy.

    -   Perceived social policies seem to vary by political party for the exception of the liberal party.

```r
#| fig-width: 7
#| fig-height: 5
#| 
x_title <- "Political Party"
y_title <- "Percent of Respondents"
main_title <- "Perceived Policy Competence"
legend_title <- "Policy Area"

# restructure the data so that it is easier to plot
poll_data_long <- poll_data |> 
  pivot_longer(-party, 
               names_to = "policy", 
               values_to = "rating") 

# issues 0f interest
policies <- c("economy", "social")


# barpplot
p_1 <- poll_data_long |>
  # filter issues of interest
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, fill = policy)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title, fill = legend_title) +
  scale_fill_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.7) +
  theme(legend.position = "top")

# dotplot
p_2 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, color = policy)) +
  geom_jitter(position = position_dodge(width = 0.7), size=4) +      
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title, fill = legend_title) +
  scale_color_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.8) +
  theme(legend.position = "top")

p_1 / p_2

```

-   Compare different versions of barcharts and dotplots. Summarize and discuss what you see in each plot type. Which is better and why?

    -   In flipping the previous graphs in a horizontal orientation, readability of party names makes it easier to compare exact values using the x-axis grid lines. This is probably the case because it reduces eye movement distance, allows longer text labels without rotation, and aligns with natural left to right reading at least in the West. The dotplot is not easy to read, as my eyes went directly to the first left dot (Green party, Social policy). For this dotplot we would want to consider which party shows up at the top, and which social issue is first. The dotplots do show the larger gaps for conservative and socialist on the two issues without asking the reader to provide more cognitive effort.

```r
#| message: false
#| fig-width: 7
#| fig-height: 5
#| 
# barpplot
p_1 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, fill = policy)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title, fill = legend_title) +
  scale_fill_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.7) +
  theme(legend.position = "right") + 
  coord_flip()

# dotplot
p_2 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, color = policy)) +
  geom_jitter(position = position_dodge(width = 0), size=4) +      
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title, fill = legend_title) +
  scale_color_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.8) +
  theme(legend.position = "right") +
  coord_flip()

p_1 / p_2 
```

-   Now plot the same data using line charts. Again, summarize and discuss: which plot type is the best and why?

    -   The line chart highlights how each party's perceived competence shifts between policy areas. Note the dramatic crossover patterns, particularly for the Socialists party, which shift from low (economy) to high (social). We also plot switch out on the x axis policy for party to show a different perspective and find it easier to take in the visual. For instance, we see that economic policies are important to conservatives, and less so for socialist. We do have to be careful since line charts imply continuity, yet these are discrete variables and percentages.

```r
#| message: false
#| fig-width: 7
#| fig-height: 6
#| 
# barpplot
p_1 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = policy, y = rating, group=party, color = party)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  ylim(0, 1) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = "Policies", y = y_title) +
  scale_color_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.7) +
  theme(legend.position = "top")

p_2 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, group=policy, color = policy)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  ylim(0, 1) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title) +
  scale_color_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.7) +
  theme(legend.position = "top")

p_1 / p_2

```

-   Add foreign policy and repeat.

    -   We keep the line chart with party on the xaxis and add foreign policy. We can quickly see that foreign and social policies seem to be similar across parties except for the socialist.

```r
#| message: false
#| fig-width: 7
#| fig-height: 8
#| 
policies <- c("economy", "social", "foreign")

# barpplot
p_1 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, fill = policy)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title, fill = legend_title) +
  scale_fill_viridis_d(option = "D", begin = 0.2, end = 0.85, alpha=.7) +
  theme(legend.position = "top")

# dotplot
p_2 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, color = policy)) +
  geom_jitter(position = position_dodge(width = 0.7), size=4) +      
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title, fill = legend_title) +
  scale_color_viridis_d(option = "D", begin = 0.2, end = 0.85, alpha=.8) +
  theme(legend.position = "top")

p_3 <- poll_data_long |>
  filter(policy %in% policies) |> 
  ggplot(aes(x = party, y = rating, group=policy, color = policy)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  ylim(0, 1) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = main_title, x = x_title, y = y_title) +
  scale_color_viridis_d(option = "D", begin = 0.2, end = 0.85, alpha=.7) +
  theme(legend.position = "top")

p_1 / p_2 / p_3
```

-   **Best visualization approach:** Horizontal dot plots provide the clearest and most efficient comparison of policy competence ratings. They minimize visual clutter and scale well when adding additional policy categories. Bar charts are acceptable but use more ink without adding information. Line charts were easier to glance at and understand quickly what the data is telling me.

\newpage

# Lab Exercise B: Graph Redesign

Use the following freedom house disaggregated dataset 2003-2014 which provides "political rights ratings" (pr_20XX) and "civil liberties ratings" (cl_20XX) for all countries across the globe. Note that the dataset is in "wide" format.

-   We read in the freedom house data and keep countries plus political rights ratings filtered from 2003-2014. We select 30 countries at random

```r
#| warning: false

# Load and prepare Freedom House data
data <- data.table::fread(str_c(repo_path,
                         "assignments/FH_disaggregated.csv"),
              encoding="Latin-1") |> 
  mutate(across(pr_2003:cl_2014, as.numeric))

# Define start and end years for graphs
start_year <- 2003
end_year <- 2014

# Sample 30 countries for visualization
set.seed(909)
sampled_countries <- data |>
  sample_n(30)

# Prepare long format for political rights
## this format will help me with creatings visuals
pr_long <- sampled_countries |>
  select(Country, starts_with("pr_")) |>
  pivot_longer(-Country, # keep cols that start with "pr"
               names_to = "year",
               values_to = "pr_score") |>
  # create a year variable
  mutate(year = as.numeric(str_remove(year, "pr_")))

# take a glimpse at the data
pr_long |> glimpse()
```

-   We show all 30 randomly picked countries below.

```r
# Display sampled countries
sampled_countries |>
  select(Country) |>
  kable()
```

### Using these data, mimic four of the six (more or less) famous graphic designs \# you find on the handout. Use the political rights variable to do this.

-   The first plot is Tukey, which is very plain and has very little black inc while highlighting one country, in this case "Laos."

```r
#| warning: false
#| fig-width: 6
#| fig-height: 5


# Highlight first country on list
highlight_country <- "Laos"

pr_long |>
  ggplot(aes(x = year, y = pr_score, group = Country)) +
  geom_point(size=.5) +
  # line for non selected first country
  geom_line(data = pr_long |> filter(Country != highlight_country),
            color = "grey70", linewidth = .5) +
  # line for selected country
  geom_line(data = pr_long |> filter(Country == highlight_country),
            color = "black", linewidth = 1.5) +
  scale_x_continuous(breaks = seq(start_year, end_year, 2)) +
  labs(title = "Political Rights Score for 30 Countries",
       subtitle = paste("Highlighted Country,", highlight_country),
       x = "",
       y = "Political Rights") +
  theme_classic() 
```

\

-   The ggthemes package, which I am familiar with, contains a fivethirtyeight theme that we use below to apply the aesthetic controls.

```r
#| warning: false
#| fig-width: 6
#| fig-height: 5
#| 
pr_long |>
  ggplot(aes(x = year, y = pr_score, group = Country)) +
  geom_line(data = pr_long |> filter(Country != highlight_country),
            alpha=.25) +
  geom_line(data = pr_long |> filter(Country == highlight_country),
            color = "dodgerblue", size=1.5) +
  scale_x_continuous(breaks = seq(start_year, end_year, 2)) +
  labs(title = "Political Rights Score for 30 Countries",
       subtitle = paste("Highlighted Country,", highlight_country),
       x = "",
       y = "Political Rights") +
  ggthemes::theme_fivethirtyeight()
```

-   Again, we use the ggthemes package which has a built in economist theme that we use below to apply the aesthetic controls. The default colors were actually white, but to mimic the handout we choose turquoise and note that it blends with the background color.

```r
#| warning: false
#| fig-width: 6
#| fig-height: 5
#| 
pr_long |>
  ggplot(aes(x = year, y = pr_score, group = Country)) +
  geom_line(data = pr_long |> filter(Country != highlight_country),
            alpha=.95, color="turquoise") +
  geom_line(data = pr_long |> filter(Country == highlight_country),
            color = "black", size=1.5) +
  scale_x_continuous(breaks = seq(start_year, end_year, 2)) +
  labs(title = "Political Rights Score for 30 Countries",
       subtitle = paste("Highlighted Country,", highlight_country),
       x = "",
       y = "Political Rights") +
  ggthemes::theme_economist()
```

-   We use the ggdark package as it already has a built in theme that is similar to the Old School Console. The dark background is suprisingly not too harsh on the eyes when studying the graphic.

```r
#| warning: false
#| fig-width: 6
#| fig-height: 5
#| 
pr_long |>
  ggplot(aes(x = year, y = pr_score, group = Country)) +
  geom_line(data = pr_long |> filter(Country != highlight_country),
            alpha=.55, color="purple") +
  geom_line(data = pr_long |> filter(Country == highlight_country),
            color = "limegreen", size=1.5) +
  scale_x_continuous(breaks = seq(start_year, end_year, 2)) +
  labs(title = "Political Rights Score for 30 Countries",
       subtitle = paste("Highlighted Country,", highlight_country),
       x = "",
       y = "Political Rights") +
  ggdark::dark_mode()
```

\newpage

## Now, come up with your own re-design according to the principles we have discussed in the course.

-   Based on visualization principles covered in the lecture videos and readings, the following is an enhanced version that prioritizes clarity and insight. Our rational is that the redesign focuses on storytelling by automatically identifying and highlighting countries with the most significant changes in political rights scores. It maintains clarity through selective use of color that is colorblind friendly and reduces visual clutter while preserving context. How we selected countries to highlight is by taking their 2014 political ratings score subtracted by their 2003 score to select the top countries with the largest change. We minimized data black inc by focusing on change from 2003 to 2014 as reflected in the xaxis label. We also tried to minimized text to bring the focus back to the data. The theme we choose is minimal and non-intrusive meaning that it does not add too much black inc and gets in the way of what story the graphic is trying to tell. The story here is that there are four countries that have almost double their political rights ratings, yet they were at low levels in 2003, under 10. Finally, we still show other countries trends lines but in a light gray to minimize data pixel and allow the reader to use less cognitive effort when taking in the visual.

```r
#| warning: false

# Select interesting countries to highlight
top_4 <- sampled_countries |>
  slice_max(abs(pr_2014 - pr_2003), n = 3) |>
  pull(Country)


# Create colors for the 4 countries
highlight_colors <- viridis(4, option = "plasma", begin = .2, 
                            alpha=.8, end = .8)
names(highlight_colors) <- top_4

# Plot
pr_long |>
  ggplot(aes(x = year, y = pr_score, group = Country)) +
  # Background lines, all countries in gray
  geom_line(color = "grey80", linewidth = .5, alpha = .4) +
  # Highlighted lines for top countries
  geom_line(
    data = pr_long |> filter(Country %in% top_4),
    aes(color = Country),
    linewidth = 1.5
  ) +
  scale_color_manual(values = highlight_colors) +
  scale_x_continuous(breaks = seq(start_year, end_year, 11)) +
  labs(title = "Countries with Largest Political Rights Changes",
    x = "",
    y = "Political Rights Score",
    color = "Country") +
  theme(legend.position = "top")
```

\newpage

# Appendix

Use of AI Acknowledgment

-   In earlier iterations of this assignment I attempted to use the gt package which is new to me to generate tables that are aesthetically pleasing. Several times I used the google AI overview when searching for the gt arguments that I needed to make my code work. An example of these types of searches can be found below. In the end, I went back to using knitr::kable() because the "\`" in Cote d'ivoire gave me LaTex issues when rendering the file to a PDF as I learned that the gt functions works best for rendering in HTML. However, I still acknowledge here my use of AI for this reason. All other code is my own that I have built through other projects from classes and my own work over the years. Overall, the google AI search function worked well for helping me identify the argumetns and how to use them for this package.

\
![](images/clipboard-3828203242.png)
