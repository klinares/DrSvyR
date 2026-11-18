# The gold specs, drawn: helpers shared with tests/smoke.R, and (when run as a script) the gallery.
#   Run from inside chaRt/, from PowerShell or the RStudio terminal:
#     Rscript --no-init-file tests/gallery.R
#   It writes tests/gallery.html (git-ignored): one section per gold spec with its lint notes, the
#   static chart, the plotly version, the first rows of the table and the code. tests/smoke.R
#   sources this file for the helpers only; the gallery is built only when it is run as a script.

GOLD_COURSE_DIR <- "D:/repos/UMD_JPSM_coursework/Data_visualization_SURV752/assignments"
GOLD_SPECS_FILE <- file.path("tests", "gold_specs.yaml")

gold_entries <- function(path = GOLD_SPECS_FILE) yaml::read_yaml(path, fileEncoding = "UTF-8")

# panel.csv: 8 regions by 10 years, with units, price and revenue, from a fixed seed.
make_panel <- function(path) {
  set.seed(2025)
  regions = c("North", "South", "East", "West", "Central", "Coast", "Highlands", "Islands")
  grid = expand.grid(year = 2015:2024, region = regions, stringsAsFactors = FALSE)
  n = nrow(grid)
  r = match(grid$region, regions)
  base_units = seq(40, 180, length.out = 8)[r]
  growth = c(0.02, -0.01, 0.03, 0.00, 0.01, 0.07, -0.02, 0.06)[r]
  units = round(10 * base_units * (1 + growth)^(grid$year - 2015) * stats::runif(n, 0.92, 1.08))
  price = round(c(22, 18, 25, 15, 20, 28, 12, 26)[r] * (1 + c(0.05, 0.01, 0.02, 0.02, 0.02, 0.02, 0.01, 0.04)[r])^(grid$year - 2015) *
                  stats::runif(n, 0.97, 1.03), 2)
  data = data.frame(region = grid$region, year = grid$year, units = units, price = price, revenue = round(units * price, 2))
  readr::write_csv(data, path)
  path
}

# Where an entry's file is: a course file, or panel.csv made in work_dir. NULL when it is absent.
gold_path <- function(entry, work_dir) {
  if (identical(entry$file, "panel.csv")) {
    p = file.path(work_dir, "panel.csv")
    if (!file.exists(p)) make_panel(p)
    return(p)
  }
  p = file.path(GOLD_COURSE_DIR, entry$file)
  if (file.exists(p)) p else NULL
}

# The data and the codebook for an entry, as the app would have them.
gold_load <- function(entry, work_dir) {
  path = gold_path(entry, work_dir)
  if (is.null(path)) return(NULL)
  missing = as.character(unlist(entry$missing))
  r = read_data(path, entry$file, missing)
  cb = new_codebook(profile_data(r$data), entry$file, nrow(r$data), missing)
  cb$row_is = entry$row_is
  list(path = path, data = r$data, cb = cb)
}

# Everything drawn for one entry, each piece or the error it met.
gold_run <- function(entry, work_dir) {
  g = gold_load(entry, work_dir)
  if (is.null(g)) return(NULL)
  caught = function(expr) tryCatch(expr, error = function(e) e)
  check = spec_check(entry$spec, g$cb)
  table = caught(spec_table(entry$spec, g$data, g$cb))
  plot = caught(spec_plot(entry$spec, g$data, g$cb))
  ok = !inherits(plot, "error")
  list(entry = entry, load = g, check = check, table = table, plot = plot,
       notes = if (ok) attr(plot, "notes"),
       widget = if (ok) caught(spec_widget(plot)),
       code = if (ok) caught(spec_code(attr(plot, "spec"), g$cb, g$path)),
       size = if (ok) spec_size(attr(plot, "spec"), attr(plot, "table")))
}
