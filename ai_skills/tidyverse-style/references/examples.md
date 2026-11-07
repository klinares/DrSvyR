# tidyverse style: good and bad examples

Each pair shows the usual way the rule is broken and the version to write.
All examples use built-in or public data.

## Iterating over columns

Bad -- a loop growing a vector:

```r
means <- c()
for (v in c("bill_length_mm", "bill_depth_mm", "body_mass_g")) {
  means[v] <- mean(penguins[[v]], na.rm = TRUE)
}
```

Good -- one summarise with `across()`:

```r
library(dplyr)
palmerpenguins::penguins |>
  summarise(across(c(bill_length_mm, bill_depth_mm, body_mass_g),
                   \(x) mean(x, na.rm = TRUE)))
```

## Iterating over groups

Bad -- split, loop, rbind:

```r
out <- data.frame()
for (s in unique(penguins$species)) {
  d <- penguins[penguins$species == s, ]
  out <- rbind(out, data.frame(species = s, n = nrow(d)))
}
```

Good -- grouped summary:

```r
palmerpenguins::penguins |>
  summarise(n = n(), mass = mean(body_mass_g, na.rm = TRUE), .by = species)
```

## Iterating over files or models

Bad:

```r
fits <- list()
for (i in seq_along(files)) fits[[i]] <- lm(y ~ x, data = read.csv(files[i]))
```

Good -- `map()` returns the list; name it by the input:

```r
library(purrr)
fits <- files |>
  set_names(basename) |>
  map(\(f) readr::read_csv(f, show_col_types = FALSE)) |>
  map(\(d) lm(y ~ x, data = d))
```

## Running state

Bad -- `while` with a counter:

```r
total <- 0; i <- 1
while (i <= length(x)) { total <- total + x[i]; i <- i + 1 }
```

Good -- vectorised, or `reduce()` / `accumulate()` when the state is not a sum:

```r
total <- sum(x)
running <- purrr::accumulate(x, `+`)
```

## Recoding survey codes

Bad -- nested `ifelse()` that leaves 8 and 9 as numbers:

```r
d$trust2 <- ifelse(d$trust == 1, "High", ifelse(d$trust == 2, "Low", d$trust))
```

Good -- every code handled on purpose, and an unlisted code is an error
rather than a silent `NA` (dplyr >= 1.2; on older dplyr use `case_match()`):

```r
d |>
  mutate(trust2 = recode_values(trust,
                                1 ~ "High",
                                2 ~ "Low",
                                c(8, 9) ~ NA_character_,
                                unmatched = "error"),
         trust2 = factor(trust2, levels = c("High", "Low")))
```

## Joins

Bad -- `merge()` with implicit keys:

```r
merge(a, b)
```

Good -- explicit keys, and check the row count afterwards:

```r
a |>
  left_join(b, by = join_by(hh_id, wave)) |>
  (\(x) { stopifnot(nrow(x) == nrow(a)); x })()
```

## Functions with column arguments

```r
share_by <- function(data, group, var) {
  data |>
    count({{ group }}, {{ var }}) |>
    mutate(share = n / sum(n), .by = {{ group }})
}
share_by(palmerpenguins::penguins, island, species)
```

## Scripts that re-run cleanly

Bad:

```r
rm(list = ls())
setwd("C:/Users/me/project")
dat <- read.csv("C:/Users/me/project/data/raw.csv")
```

Good:

```r
dat <- readr::read_csv(here::here("data", "raw.csv"), show_col_types = FALSE)
```
