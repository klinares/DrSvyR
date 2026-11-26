# Phase 12 Part B 7: the weight of animated charts in dashboard.html. No model call. Run from inside chaRt/:
#   Rscript --no-init-file tests/motion_weight_12.R [outdir]
# Builds the five-chart test dashboard (tests/data/orders.csv, the five stand-in charts of smoke.R's 9A) with all five animated, and each chart
#   alone, and prints the size of dashboard.html, the frames kept and the bytes of the dearest frames. The pages are left in `outdir`.
app <- shiny::shinyAppDir(".")
args <- commandArgs(trailingOnly = TRUE)
outdir <- if (length(args)) args[[1]] else file.path(tempdir(), "motion12")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
o <- reread_data(file.path("tests", "data", "orders.csv"), "orders.csv", "-99")
cb <- utils::modifyList(o$codebook, list(row_is = "one order"))
data <- o$read$data
specs <- list(
  bar = list(family = "bar", x = "region", y = "revenue", fn = "sum", sort = "value_desc", title = "Revenue by region"),
  line = list(family = "line", x = "order_month", y = "revenue", fn = "sum", title = "Revenue by month"),
  scatter = list(family = "scatter", x = "units", y = "revenue", title = "Revenue against units", fit = "loess",
                 filter = list(list(column = "units", op = "<=", value = 40L), list(column = "revenue", op = "<=", value = 6000))),
  facet = list(family = "line", x = "year", y = "revenue", fn = "sum", facet = "product_category", title = "Revenue by year in each category"),
  box = list(family = "box", x = "channel", y = "unit_price", title = "Unit price by channel"))
set <- list(title = "Motion weight", subtitle = "", author = "", date = as.Date("2026-11-25"), intro = "", boxes = character(0), keys = character(0))
item <- function(i, sp, mode) { ch <- new_chart(paste0("c", i), sp); list(id = ch$id, chart = ch, story = NULL, mode = mode, stale = NA_character_) }
build <- function(items, name) {
  out <- file.path(outdir, name, "dashboard.zip")
  dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
  t <- system.time(res <- build_dashboard(items, data, cb, chart_palette_default(), set, file.path("tests", "data", "orders.csv"), out, model = "test-model"))
  zip::unzip(out, exdir = dirname(out))
  c(res, list(html = file.path(dirname(out), "dashboard.html"), elapsed = t[["elapsed"]]))
}
mb <- function(b) sprintf("%.2f MB", b / 1024^2)
all5 <- build(purrr::imap(unname(specs), function(sp, i) item(i, sp, "video")), "all5")
pics5 <- build(purrr::imap(unname(specs), function(sp, i) item(i, sp, "picture")), "pictures5")
cat("five charts, all animated: dashboard.html ", mb(file.size(all5$html)), " (built in ", round(all5$elapsed), " s); the same five as pictures: ", mb(file.size(pics5$html)), "\n", sep = "")
purrr::iwalk(specs, function(sp, nm) {
  one <- build(list(item(1, sp, "video")), paste0("one_", nm))
  pic <- build(list(item(1, sp, "picture")), paste0("pic_", nm))
  # the frames of this chart as the page holds them, drawn again here to name the dearest
  mo <- dash_video(new_chart("c1", sp), data, cb, chart_palette_default(), APP_CLASSIFICATION, "wide")
  top <- order(-mo$frame_bytes)[1:3]
  cat(sprintf("  %-8s alone: dashboard.html %s (as a picture %s); frames kept %d of %d (%s), added %s; dearest frames %s\n", nm, mb(file.size(one$html)), mb(file.size(pic$html)),
              mo$kept, mo$drawn, paste(mo$px, collapse = " by "), mb(mo$added), paste0(top, ": ", round(mo$frame_bytes[top] / 1024), " KB", collapse = ", ")))
})
