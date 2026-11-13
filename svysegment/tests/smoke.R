# Smoke test for svysegment. Not deployed (tests/ is in .rscignore).
# Run from inside svysegment/, without the user profile so it is closer to Connect:
#   Rscript --no-init-file tests/smoke.R

app = source("app.R")$value
stopifnot(inherits(app, "shiny.appobj"))
cat("app.R sources and returns a shiny.appobj\n")

path = demo_survey_path()
stopifnot(!is.null(path))
cat("demo data:", basename(path), "\n")

items = c("pol1", "anestg", "soct2", "idio2", "sd2new2", "sd5new2")

dat = haven::read_sav(path) |>
  haven::zap_labels() |>
  dplyr::select(dplyr::all_of(c(items, "wt"))) |>
  tidyr::drop_na()

cats = purrr::map_int(items, function(it) as.integer(max(dat[[it]])))

# make_inputs() indexes by the response value, so codes must run 1..C.
stopifnot(purrr::every(items, function(it) min(dat[[it]]) >= 1))
cat("n complete cases:", nrow(dat), "  cats:", paste(cats, collapse = " "), "\n")

cfg = list(seed = WISE_FIXED$seed, n_starts = 40L, n_short = 30L,
           n_keep = 8L, items = items, cats = cats, K_range = 2:4)

t_small = system.time(res <- search_sizes(cfg, dat))
print(as.data.frame(dplyr::select(res$stats, K, loglik, BIC, AIC)))
cat(sprintf("small search (40 starts, K 2:4): %.1f s\n", t_small[["elapsed"]]))

uri = plot_data_uri(ggplot2::ggplot(dat, ggplot2::aes(x = factor(pol1))) +
                      ggplot2::geom_bar(), width = 4, height = 3)
stopifnot(is.character(uri), startsWith(uri, "data:image/png;base64,"))
cat("plot_data_uri returns a PNG data URI,", nchar(uri), "chars\n")

cfg_full = purrr::list_modify(cfg,
  n_starts = WISE_FIXED$n_starts, n_short = WISE_FIXED$n_short,
  n_keep = WISE_FIXED$n_keep, K_range = WISE_FIXED$K_range)

t_full = system.time(res_full <- search_sizes(cfg_full, dat))
print(as.data.frame(dplyr::select(res_full$stats, K, loglik, BIC, AIC, converged)))
cat(sprintf("FULL search (%d starts, n_short %d, n_keep %d, K %s): %.1f s (%.1f min)\n",
            cfg_full$n_starts, cfg_full$n_short, cfg_full$n_keep,
            paste(range(cfg_full$K_range), collapse = ":"),
            t_full[["elapsed"]], t_full[["elapsed"]] / 60))
