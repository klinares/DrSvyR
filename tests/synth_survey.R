# A synthetic survey with the shape the app expects: stratified clustered
#   design, near-constant weights, a mixed-format categorical battery, five
#   demographics, and some item nonresponse so the scoring step has partial
#   responders to reach.
suppressMessages({library(dplyr); library(purrr); library(tibble)})

make_survey <- function(seed = 20260830, n_psu = 84L, per_psu = 19L, K = 4L) {
  set.seed(seed)
  n <- n_psu * per_psu
  psu <- rep(seq_len(n_psu), each = per_psu)
  strata <- rep(rep(1:3, times = c(30L, 34L, 20L)), each = per_psu)

  u <- rnorm(n_psu, 0, 0.45)[psu]
  lp <- cbind(0, 0.4 + u, -0.2 + 0.8 * u, 0.1 - 0.6 * u)[, seq_len(K), drop = FALSE]
  seg <- apply(exp(lp) / rowSums(exp(lp)), 1, function(p) sample.int(K, 1, prob = p))

  items <- c("refrigerator", "computer", "home_internet", "ran_out_food",
             "water_worry", "own_finances", "feel_unsafe", "crime_victim",
             "govt_aid", "cash_transfer", "emigrate")
  cats <- c(2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 4)

  rho <- map(cats, function(Cj) {
    m <- matrix(runif(Cj * K, 0.5, 2), Cj, K)
    sweep(m, 2, colSums(m), "/")
  })
  item_dat <- map2(rho, cats, function(r, Cj)
    map_int(seg, function(k) sample.int(Cj, 1, prob = r[, k]))) |>
    set_names(items) |> as_tibble()

  for (j in c(6L, 11L)) item_dat[[j]][sample(n, 40)] <- NA_integer_

  lvl <- function(l) factor(sample(l, n, TRUE), levels = l)
  tibble(id = seq_len(n), strata = strata, psu = psu,
         wt = round(runif(n, 0.92, 1.09), 4)) |>
    bind_cols(item_dat) |>
    mutate(age_cat    = lvl(c("16-29", "30-44", "45-59", "60+")),
           sex        = lvl(c("Male", "Female")),
           education  = lvl(c("Secondary", "Primary", "Tertiary")),
           urban      = lvl(c("Urban", "Rural")),
           employment = lvl(c("Employed", "Unemployed", "Not in labor force")))
}

make_cfg <- function(dat, K_range = 2:5, n_starts = 8L, workers = 1L) {
  items <- setdiff(names(dat),
                   c("id", "strata", "psu", "wt", "age_cat", "sex",
                     "education", "urban", "employment"))
  list(arm = "lca", items = items,
       aux = c("age_cat", "sex", "education", "urban", "employment"),
       strata = "strata", psu = "psu", weight = "wt", id = "id",
       cats = map_int(dat[items], function(x) length(unique(x[!is.na(x)]))),
       min_items = 6L, K_range = K_range, n_starts = n_starts,
       seed = 2026, parallel = FALSE, workers = workers)
}
