# Phase 12b: animated test dashboards to open in a browser. No model call. Run from inside chaRt/:
#   Rscript --no-init-file tests/motion_pages_12b.R [which ...] [--out=dir]
# `which` is any of five (the five stand-in charts of smoke.R's 9A, all animated, Clean style, into tests/dashboard_motion/), briefing (the same in the Briefing
#   style, into tests/dashboard_motion_briefing/) and twelve (twelve animated charts, Clean, into tests/dashboard_motion12/); all three when none is named.
#   --out=dir writes the pages under dir instead (dir/five, dir/briefing, dir/twelve); --pictures makes every chart a picture (a page to compare with).
#   Marking UNCLASSIFIED (the app's default). Prints each page's size.
app <- shiny::shinyAppDir(".")
args <- commandArgs(trailingOnly = TRUE)
out_arg <- sub("^--out=", "", grep("^--out=", args, value = TRUE))
mode <- if ("--pictures" %in% args) "picture" else "video"
which <- setdiff(args, c(grep("^--out=", args, value = TRUE), "--pictures"))
if (!length(which)) which <- c("five", "briefing", "twelve")
dirs <- if (length(out_arg)) stats::setNames(file.path(out_arg, c("five", "briefing", "twelve")), c("five", "briefing", "twelve")) else
  c(five = file.path("tests", "dashboard_motion"), briefing = file.path("tests", "dashboard_motion_briefing"), twelve = file.path("tests", "dashboard_motion12"))
o <- reread_data(file.path("tests", "data", "orders.csv"), "orders.csv", "-99")
cb <- utils::modifyList(o$codebook, list(row_is = "one order"))
data <- o$read$data
five <- list(
  list(family = "bar", x = "region", y = "revenue", fn = "sum", sort = "value_desc", title = "Revenue by region"),
  list(family = "line", x = "order_month", y = "revenue", fn = "sum", title = "Revenue by month"),
  list(family = "scatter", x = "units", y = "revenue", title = "Revenue against units", fit = "loess",
       filter = list(list(column = "units", op = "<=", value = 40L), list(column = "revenue", op = "<=", value = 6000))),
  list(family = "line", x = "year", y = "revenue", fn = "sum", facet = "product_category", title = "Revenue by year in each category"),
  list(family = "box", x = "channel", y = "unit_price", title = "Unit price by channel"))
seven <- list(
  list(family = "bar", x = "channel", y = "units", fn = "sum", sort = "value_desc", title = "Units by channel"),
  list(family = "line", x = "order_month", y = "units", fn = "sum", title = "Units by month"),
  list(family = "box", x = "region", y = "revenue", title = "Revenue by region, order by order"),
  list(family = "bar", x = "product_category", y = "revenue", fn = "mean", sort = "value_desc", title = "Mean revenue by category"),
  list(family = "line", x = "year", y = "units", fn = "sum", facet = "region", title = "Units by year in each region"),
  list(family = "box", x = "priority", y = "shipping_days", title = "Shipping days by priority"),
  list(family = "bar", x = "quarter", y = "revenue", fn = "sum", title = "Revenue by quarter"))
item <- function(i, sp) { ch <- new_chart(paste0("c", i), sp); list(id = ch$id, chart = ch, story = NULL, mode = mode, stale = NA_character_) }
make_page <- function(specs, style, title, dir) {
  set <- list(title = title, subtitle = "Every chart animated", author = "", date = as.Date("2026-11-26"), intro = "", boxes = character(0), keys = character(0))
  unlink(dir, recursive = TRUE)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  dir <- normalizePath(dir, winslash = "/")   # the zip is written from another working directory
  out <- file.path(dir, "dashboard.zip")
  t <- system.time(build_dashboard(purrr::imap(specs, function(sp, i) item(i, sp)), data, cb, utils::modifyList(chart_palette_default(), list(style = style)), set,
                                   file.path("tests", "data", "orders.csv"), out, model = "test-model"))
  zip::unzip(out, exdir = dir)
  html <- file.path(dir, "dashboard.html")
  cat(sprintf("%-50s %d charts, %s: %.2f MB, built in %.0f s\n", html, length(specs), style, file.size(html) / 1024^2, t[["elapsed"]]))
}
if ("five" %in% which) make_page(five, "clean", "Five animated charts", dirs[["five"]])
if ("briefing" %in% which) make_page(five, "briefing", "Five animated charts", dirs[["briefing"]])
if ("twelve" %in% which) make_page(c(five, seven), "clean", "Twelve animated charts", dirs[["twelve"]])
