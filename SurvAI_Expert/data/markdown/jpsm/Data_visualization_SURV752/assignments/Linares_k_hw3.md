---
id: "jpsm/Data_visualization_SURV752/assignments/Linares_k_hw3"
source: "jpsm"
course: "SURV752"
course_title: "Introduction to Data Visualization"
doc_type: "assignment"
title: "Homework 3: Lab Exercise, Explore Football Data"
original: "Data_visualization_SURV752/assignments/Linares_k_hw3.qmd"
pages: 
sha256: "fe2c38ac31d649ed0e17be5cc836e7eabca70a189d242f80f00f356962c9c6d4"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:28:54"
---


### This dataset containts soccer (or as Europeans prefer: football) player skill ratings(at the time of September 2011). The skill ratings are from the PES Stats Database (PSD), a community-based approach to create a database with accurate statistics and skill ratings for soccer players (originally for the video game "Pro Evolution Soccer" by Konami). It contains no less than 43 variables on 1851 players from 4 European Leagues (Bundesliga, La Liga, Premier League, Serie A).

```r
#| message: false
#| warning: false
# this is my way of loading packages using the pacman package
pacman::p_load(ggthemes, knitr, patchwork, viridis, 
               ggspark, bulletchartr, CGPfunctions, tidyverse)

theme_set(theme_minimal())
# path to data
repo_path <- "d:/repos/UMD_classes_code/Data_visualization_SURV752/"


```

1.  Visually explore the offensive (Attack) and defensive (Defence) skills of soccer players. But before going straight to the code, take a few minutes, think and take notes:

    1.  What a priori expectations about the data and possible patterns do you have?

        1.  I would hypothesize that players in a defense position would show higher ratings of defense, and conversely strikers would have higher attack values. We may be able to see these patterns in a scatterplot. We are also expecting that midfielders will have a more balanced attack and defense. To some extant, we expect at the league level to shows some variation in attacks and defense, with perhaps different distributions.

    2.  What general exploration strategy would be appropriate?

        1.  We plan to begin a comparison between leagues to establish differences or similarities in the distribution, or spread of central tendancy, of attacks and defense skill ratings, this can be done through boxplots or histograms. Next we plan to move to subgroup comparisons by position for attacks and defense, as well as context comparison such as within team variability relative to league and position. Finally, we will compare relationships between attacks and defense skills by position types.

    3.  Which comparisons are possible and interesting?

        1.  Given our prior expectations about the data, we will explore comparisons for attack vs defense by positions. Another interesting comparison will be to show skills in a plot and highlight outliers. Finally, league comparisons would be possible with these data and interesting to establish whether we need to account for league effects when exploring player and team comparisons.

    4.  Which graphical formats would be useful to make these comparisons?

        1.  For the relationship between skills we can design a scatterplot and perhaps color code it by position. Density plots for the league distributions should work well in showing the distributions of attacks or defense. Moreover, bullet graphics to compare leagues on the mean of skill ratings can be useful. Small multiples may work great to show team skills statistics.

-   We begin by reading in the football data and explore how many teams are captured in this data as well as how many players across all four leagues. We noticed that there are 40 players with missing birthdays or age, but we keep them since we are mainly interested in the attack and defense skill ratings by League and positions. Below we print the total number of players and teams for each of the four leagues.

```r
#| message: false

football <- read_csv(str_c(repo_path, "assignments/footballdata-1.csv")) |> 
  select(-1)

football |> 
  group_by(League) |> 
  reframe(Teams = n_distinct(Team), Players = n()) |> 
  pivot_longer(-League, names_to = "Type", values_to="Total") |> 
  ggplot(aes(x=League, y=Total)) +
  geom_col(aes(fill=League)) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  facet_wrap(~Type, scales = "free") +
  labs(title = "Total Count of Players and Teams by League", 
       x = "", y = "Total Count", fill = "League") +
  scale_fill_viridis_d(option = "B", begin = 0.1, end = 0.8, alpha=.7) +
  theme(legend.position = "top")
```

-   We consider droping goal keepers as these are specialized positions in a team. To show this effect, we print a table with attack and defense means by position and note that goalkeepers have the lowest means for attack, and the highest for defense.

```r

# print means for attack and defense by position
football |> 
  group_by(Position) |> 
  reframe(Attack = mean(Attack), Defense = mean(Defence)) |> 
  pivot_longer(-Position, names_to = "Skill", values_to = "Average") |> 
  ggplot(aes(x=Position, y=Average, fill=Position)) +
  geom_col(position = "dodge") +
  facet_grid(~Skill) +
  labs(title = "Skills Rating Averages by Position", 
       x = "", y = "", fill = "Position") +
  scale_fill_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.7) +
  theme(legend.position = "top")
```

-   In the below scatterplot we see a negative relationship, but it is hard to see because there are two defender outliers as well as the goalkeeper positions. Defender Raul Rodriguez from RCD Espanyol has a defence and attack rating of 0, and Dominik Reinhardt from FC Augsburg has a defense score of 73, and attack score of 6. These two players are outliers, but their scores may also have incorrectly been entered.

```r
football |>  
  ggplot(aes(x=Attack, y=Defence, color=Position)) +
  geom_point(aes(shape=Position), size=1, alpha=.80) +
  labs(title = "Association between Attack and Defense by Position", 
       x = "Attack", y = "Defense", fill = "") +
  scale_color_viridis_d(option = "D", begin = 0.3, end = 0.7, alpha=.7) +
  theme(legend.position = "top")
```

-   We drop goalkeepers and the two defender outliers and replot the scatterplot. We can now see a negative relationship, as defense ratings goes up, attack ratings go down. However, we can see clustering by position in the plot, suggesting that defenders have higher defense ratings but lower attack ratings, while forward players have higher attack ratings, but lower defense ratings. We plot the attack and defense average ratings represented in the dashed black lines, for instance the average defense rating was about 63 and 73 for attack. This helps us visualize how midfielders have a balance between defense and attack.

```r
# drop rows
football <- football |> 
  filter(Position != "Goalkeeper", !Name %in% c(
    "Raul Rodriguez", "Dominik Reinhardt"))
```

\newpage

### 2. Make sure you experiment with

### a) at least three graphical formats as well as

### b) with comparisons *within a single* plot and comparisons *across multiple* plots!

-   We drop goalkeepers and the two defender outliers and replot the scatterplot. We can now see a negative relationship, as defense ratings goes up, attack ratings go down. However, we can see clustering by position in the plot, suggesting that defenders have higher defense ratings but lower attack ratings, while forward players have higher attack ratings, but lower defense ratings. For each position we plot their mean intersection for attack and defense to highlight the centroid point of these data by group.

```r

# compute skill means by position to use in plot

# Calculate position means
position_means <- football |>
  group_by(Position) |>
  reframe(
    Attack = mean(Attack),
    Defence = mean(Defence)
  )


football |>  
  ggplot(aes(x=Attack, y=Defence, color=Position)) +
  geom_point(aes(shape=Position), size=1) +
  # add group means
  geom_point(data = position_means, 
             aes(x = Attack, y = Defence, color = Position),
             size = 6, shape = 17) +
  labs(title = "Figure 1: Association between Attack and Defense by Position", 
       x = "Attack", y = "Defense", fill = "") +
  scale_color_viridis_d(option = "D", begin = 0.3, end = 0.8, alpha=.8) +
  theme(legend.position = "top")
```

-   Following Tufte's principle of 'compared to what?', we compare attack and defence distributions across leagues (subgroup comparison). We use both density plots and boxplots because they facilitate different comparisons: density plots reveal distribution shape differences, while boxplots enable precise comparison of medians and spread using common scales (a key principle for small multiples, per the lecture slides).

```r
#| fig-height: 8
#| 
# Prepare data for density plots
density_data <- football |>
  select(League, Attack, Defence) |>
  pivot_longer(cols = c(Attack, Defence), 
               names_to = "Skill", 
               values_to = "Rating")

# Create density plots
p1 <- density_data |> 
  ggplot(aes(x = Rating, fill = League)) +
  geom_density() +
  facet_wrap(~ Skill, scales = "free") +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  labs(title = "Figure 2. Skill Distributions Across Leagues",
    subtitle = "Comparing Attack and Defence rating distributions",
    x = "Rating", y = "Density", fill = "League") +
  scale_fill_viridis_d(option ="B",begin =0.1, end =0.8, alpha=.2) +
  theme(legend.position = "top")

# Box plots for direct comparison
p2 <- density_data |> 
  ggplot(aes(x = League, y = Rating, fill = League)) +
  geom_boxplot(show.legend = FALSE) +
  facet_wrap(~ Skill) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  labs(title = "Central Tendency and Spread by League",
    x = "", y = "Rating", fill = "League") +
  scale_fill_viridis_d(option ="B",begin =0.1,end =0.8, alpha=.7) 

p1 / p2
```

-   All teams had higher average attack ratings compared to defense since the primary goal of football is to score, and defending comes second. For each team we took the ratio between average attack and defense ratings and convert them into percent difference. For instance, team Swansea City had an average attack rating of 73 and an average defence rating of 55.6, the difference $(73/55.6) - 1$ gives us a 31% difference in team attack ratings versus defense. We compute these ratio differences in attack vs defense to the top 20 and bottom 20 teams to explore which teams prioritize attack versus which team are prioritize balance between attack and defense. The vertical dashed blue line represents the global average ratio converted to percent difference of 18.8%. This allows us to examine which teams are over the overall mean and which are under.

```r
#| message: false
#| fig-width: 7
#| fig-height: 9

team_means <- football |>
  group_by(Team) |>
  reframe(
    Attack = mean(Attack),
    Defence = mean(Defence)) |> 
  # bring back league information
  right_join(football |> distinct(Team, League)) |> 
  # sort by largest gap difference
  mutate(Ratio = Attack/Defence - 1,
    Team = fct_reorder(Team, Ratio, .desc = FALSE)) |> 
  # keep top 20 and bottom 20
  slice(1:20, 60:80)

# Small multiples by team
team_means |> 
  ggplot(aes( y = Ratio, x = Team)) +
  geom_col() +
  geom_hline(yintercept = mean(team_means$Ratio), 
            color = "dodgerblue", linetype = "dashed", size=1.25) +
  coord_flip() +
  #scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(title = "Figure 3. Team Difference in Attack vs Defense\n For Top and Bottom 20",
    x = "", y = "Perent Difference") +
  scale_fill_viridis_d(option ="B",begin =0.01, end =0.9, alpha=.6) +
  theme(legend.position = "top",
        # text size for x axis
        axis.text.x = element_text(size = 10))
```

\newpage

### 3. Finally, try to construct a “bullet graph” as invented by Stephen Few \# as well as a “slope graph” and "sparklines" as invented by Edward Tufte. \# (For these latter two graphical formats it's best to use data with a time \# component - so you may want to go back to the freedom house data.) \# For this exercise you my find the lines(), segments() and rect() plotting \# functions helpful.

```r
#| warning: false
#| message: false

# Load and prepare Freedom House data
data <- data.table::fread(str_c(repo_path,
                         "assignments/FH_disaggregated.csv"),
              encoding="Latin-1") |> 
  mutate(across(pr_2003:cl_2014, as.numeric))

# Prepare long format for political rights
## this format will help me with creatings visuals
pr_long <- data |>
  select(Country, starts_with("pr_")) |>
  pivot_longer(-Country, # keep cols that start with "pr"
               names_to = "year",
               values_to = "pr_score") |>
  # create a year variable
  mutate(year = as.numeric(str_remove(year, "pr_"))) 
```

-   We use the bulletchartr package to design a bullet chart to visualize political rights ratings for 6 randomly selected countries. We first stacked yearly pr scores for each country and calculated metrics used for the visual such as the lowest, middle, and highest pr ratings. The current pr rating is for the year 2014. Additionally, our target metric is the overall grand pr rating median of 27 (shown in red). From these bullet graphs we can see that Turkey's current pr ratings falls short of the global median rating, although their medium and high ratings in the past have surpassed it. The rest of the countries shown in this plot have current pr ratings that surpass the global median, ranging from 30 to 40. Malta's current pr rating also happens to be their highest rating. Bullet charts provide us with an opportunity to compare values within countries to examine where they fall currently with respect to their previous pr ratings as well as how they compare globally. The limitation to this type of graph within this package is that is unable to handle several groups when rendering into a pdf, an HTML file would be fine. In our case, picking the target as the global median seemed arbitrary as some countries may have their own thresholds and goals.

```r
#| warning: false
#| message: false
#| fig-width: 7
#| fig-height: 10

pr_med <- pr_long |> 
  summarise(median(pr_score, na.rm=TRUE)) |> 
  pull()

set.seed(909) # for random selection of countries

bullet_data <- pr_long |> 
  group_by(Country) |> 
  reframe(current = ifelse(max(year), pr_score, pr_score),
          low = min(pr_score),
          medium = median(pr_score),
          high = max(pr_score)) |> 
  mutate(info = "Political Rights",
         target = pr_med) |> 
  select(Country, info, target, current, low, medium, high) |> 
  drop_na() |> 
  filter(target <= high) |> 
  slice_sample(n=6)

bullet_chart(dataframe=bullet_data, indicator_name = "Country") 


```

-   The CGPfunctions package allows us to generate a slope graph to visualize from our data changes in political rights from 2003 to 2014 for a random set of 20 countries (for less crowded graph). From this graphic we are able to quickly view which countries have increased, decreased, or remained stable. For instance, Bhutan went from 7 in 2003 to 26 in 2014, while Laos went from 3 to 1 which is also the lowest rating. Algeria remained at a stable 11 with no change in these two years. We can also see that Austria had the highest rating in 2003 of 40, and Chile the highest of 39 in 2014. We find that slope graphs excel at showing the before and after comparisons by reducing timeseries to a start and end point.

```r
#| warning: false
#| message: false
#| fig-width: 7
#| fig-height: 8
#| 
set.seed(909)
random_countries <- sample(197, 20) # randomly pick 20 numbers from 1-197

pr_long |> 
  filter(year == 2003 | year == 2014) |> 
  mutate(year = as.character(year)) |> 
  group_by(Country) |> 
  mutate(group_id = cur_group_id()) |> 
  ungroup() |> 
  filter(group_id %in% random_countries) |> 
  newggslopegraph(Times = year, Measurement = pr_score, Grouping = Country,
                  Title = "Political Rights Rating Evolution",
                  SubTitle = "2003 and 2014",
                  Caption="") +
  scale_color_viridis_d() 
  
```

\newpage

-   We use the ggspark package to generate spark lines for political rights for ratings between 2003 through 2014 across 12 randomly selected countries. We note that these plots are useful at helping the reader glance at the figure and determine when each country had to lowest or highest rating to compare to a country's current rating or across countries. The gray shaded region is the interquartile range, and we find that this is useful for data that has more frequency time points than yearly estimates, such as daily or even monthly for several years. In the case of these data, we do not have many time points so the IQR is large and does not provide much visually here. Furthermore, the lines are jagged rather than smooth because of this same issue of very few time points. Nonetheless, we find spark lines to be useful for timeseries data particularly for comparing within and across groups.

```r
#| warning: false
#| message: false
#| fig-width: 7
#| fig-height: 9

set.seed(909)
random_countries <- sample(197, 12) # randomly pick 10 numbers from 1-197

pr_long |> 
  group_by(Country) |> 
  mutate(group_id = cur_group_id(), 
         year = as.character(year)) |> 
  filter(!any(is.na(pr_score))) |> 
  ungroup() |> 
  filter(group_id %in% random_countries) |> 
  drop_na() |> 
  ggplot(aes(x=year, y=pr_score, group=Country)) +
  stat_interquartilerange(geom = "ribbon", show.legend = FALSE) +
  geom_line() +
  stat_sparklabels(geom = "label", label_fun = \(x) round(x, 0),
                   show.legend = FALSE) +
  scale_x_discrete(breaks = c("2003", "2009", "2014")) + 
  facet_wrap(Country~., scales="free") +
  labs(title = "Political Rights Rating Evolution",
    x = "", y = "Political Rights Rating") +
  theme_few()
```

\newpage

# Appendix

Use of AI Acknowledgment

-   This assignment allowed me to learn about three packages for plotting bullet, slope, and spark graphs. However, these packages are less used and googling how to use them beyond the readme documents renders scant information. For the slope graphs using the CGPfunctions packages I spent more time trying to use a dark theme, just like in the slides, but failed short. I used the claude to help me troubleshoot why ggdark::dark_mode() was the only theme that worked from this package, and it turns out that the text labels on this graph are sensitive to themes. Claude allowed me to troubleshoot theme application to the newggslopegraph() and ultimately I went back to using the default theme. It did however provide useful themes from the hrbrthemes package that I was unfamiliar with.

\
