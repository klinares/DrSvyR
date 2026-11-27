# Phase 12 Part A 4: the app with the av package hidden. No model call. Run by tests/smoke.R (12A-1) in a new R process whose user library is a folder of
#   links to every installed package but av (R_LIBS_USER), so that av is not installed as far as this process can tell; loading av would also stop with an
#   error here (a hook on its load), in case another library holds it. From inside chaRt/:
#     Rscript --no-init-file tests/hide_av_12.R [file of R code to source after the app, for a mutation]
# It loads the app as Connect does, draws a chart's frames, builds a dashboard with one animated chart, and prints one line "P12AV <json>".
setHook(packageEvent("av", "onLoad"), function(...) stop("av is hidden by this test"))
out <- list(av_found = length(find.package("av", quiet = TRUE)) > 0L)
app <- tryCatch(shiny::shinyAppDir("."), error = function(e) e)
out$loads <- inherits(app, "shiny.appobj")
extra <- commandArgs(trailingOnly = TRUE)
if (length(extra) && file.exists(extra[[1]])) sys.source(extra[[1]], envir = globalenv(), keep.source = FALSE)
if (out$loads) {
  out$available <- isTRUE(video_available())
  o <- reread_data(file.path("tests", "data", "orders.csv"), "orders.csv", "-99")
  cb <- utils::modifyList(o$codebook, list(row_is = "one order"))
  spec <- list(family = "bar", x = "region", y = "revenue", fn = "sum", sort = "value_desc", title = "Revenue by region")
  r <- tryCatch(spec_video(spec, o$read$data, cb, chart_palette_default(), width = 320), error = function(e) conditionMessage(e))
  out$drawn <- if (is.list(r)) r$drawn else r
  zip <- file.path(tempfile("p12av_"), "d.zip")
  dir.create(dirname(zip))
  ch <- new_chart("c1", spec)
  set <- list(title = "T", subtitle = "", author = "", date = as.Date("2026-11-25"), intro = "", boxes = character(0), keys = character(0))
  b <- tryCatch(build_dashboard(list(list(id = "c1", chart = ch, story = NULL, mode = "video", stale = NA_character_)), o$read$data, cb, chart_palette_default(), set,
                                file.path("tests", "data", "orders.csv"), zip, model = "test-model"), error = function(e) conditionMessage(e))
  out$built <- is.list(b) && identical(unname(b$modes), "video")
  if (is.list(b)) {
    d <- tempfile("p12av_unz_"); dir.create(d); zip::unzip(b$zip, exdir = d)
    h <- paste(readLines(file.path(d, "dashboard.html"), warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    out$motion <- grepl("class=\"motion-frames\"", h, fixed = TRUE)
    out$mp4 <- any(grepl("[.]mp4$", list.files(d, recursive = TRUE)))
  }
}
out$av_loaded <- "av" %in% loadedNamespaces()
cat("P12AV ", jsonlite::toJSON(out, auto_unbox = TRUE), "\n", sep = "")
