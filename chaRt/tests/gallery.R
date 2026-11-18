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

# latin1.csv: country names with accents, saved in Latin-1 (as Excel on Windows often saves).
make_latin1 <- function(path) {
  rows = c("country,score", "Côte d'Ivoire,3", "São Tomé,5", "Peru,4", "Chile,6", "Canada,7", "Ghana,2")
  writeLines(iconv(rows, from = "UTF-8", to = "latin1"), path, useBytes = TRUE)
  path
}

# Where an entry's file is: a course file, or panel.csv or latin1.csv made in work_dir. NULL when
#   it is absent.
gold_path <- function(entry, work_dir) {
  makers = list(panel.csv = make_panel, latin1.csv = make_latin1)
  if (entry$file %in% names(makers)) {
    p = file.path(work_dir, entry$file)
    if (!file.exists(p)) makers[[entry$file]](p)
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
  cb = new_codebook(profile_data(r$data), entry$file, nrow(r$data), missing, r$encoding)
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


# ---- the gallery page ---------------------------------------------------------------------------

GALLERY_OUT <- file.path("tests", "gallery.html")

# Both versions of a chart are shown at the same size in pixels: its inches at this many CSS pixels
#   per inch. The static image is drawn at SPEC_DPI, with ragg when it is installed, so it is sharper.
GALLERY_DPI <- 96
GALLERY_DEV <- if (nzchar(find.package("ragg", quiet = TRUE))) 'dev: "ragg_png"' else 'dev: "png"'

# What the page needs from one run, without the data.
gallery_item <- function(run) {
  ok = inherits(run$plot, "ggplot")
  tab = if (!inherits(run$table, "error")) run$table
  list(name = run$entry$name, file = run$entry$file, spec = run$entry$spec,
       error = if (!ok) conditionMessage(run$plot), notes = run$notes, plot = if (ok) run$plot,
       widget = if (inherits(run$widget, "htmlwidget")) run$widget,
       widget_error = if (inherits(run$widget, "error")) conditionMessage(run$widget),
       warnings = if (inherits(run$widget, "htmlwidget")) attr(run$widget, "warnings"),
       head = if (!is.null(tab)) as.data.frame(utils::head(tab, 10)),
       rows = if (!is.null(tab)) c(used = attr(tab, "rows_used"), dropped = attr(tab, "rows_dropped"), shown = nrow(tab)),
       code = if (is.character(run$code)) run$code else if (inherits(run$code, "error")) paste("# spec_code() failed:", conditionMessage(run$code)),
       size = run$size)
}

# A fenced block of text that may itself hold backticks.
fenced <- function(text, lang = "") paste0("````", lang, "\n", text, "\n````")

gallery_section <- function(item, i) {
  r = function(opts, body) paste0("```{r}\n", paste0("#| ", opts, collapse = "\n"), "\n", body, "\n```")
  px = if (!is.null(item$size)) round(item$size[["width"]] * GALLERY_DPI)
  size_opts = if (!is.null(item$size)) c(paste("fig-width:", item$size[["width"]]), paste("fig-height:", item$size[["height"]]),
                                         paste("fig-dpi:", SPEC_DPI), GALLERY_DEV, paste0('out-width: "', px, 'px"'))
  box = paste0("::: {style=\"width:", px, "px\"}\n")
  notes = if (length(item$notes)) paste0("- ", item$notes, collapse = "\n") else "*No notes.*"
  if (!is.null(item$error))
    return(paste0("## ", i, ". ", item$name, "\n\n**Could not draw this:** ", item$error, "\n"))
  paste0(
    "## ", i, ". ", item$name, "\n\n",
    "`", item$file, "`, drawn at ", item$size[["width"]], " by ", item$size[["height"]], " inches.\n\n",
    "**Lint notes**\n\n", notes, "\n\n",
    ":::: {style=\"display:flex; flex-wrap:wrap; gap:2rem; align-items:flex-start\"}\n", box, "**Static (ggplot2)**\n\n",
    r(size_opts, sprintf("print(gallery[[%d]]$plot)", i)), "\n:::\n",
    box, "**Interactive (plotly)**",
    if (length(item$warnings)) paste0(" - ggplotly() warned: ", paste(item$warnings, collapse = "; ")) else "", "\n\n",
    if (!is.null(item$widget)) r(size_opts, sprintf("gallery[[%d]]$widget", i)) else paste("*No widget:*", item$widget_error),
    "\n:::\n::::\n\n",
    "**The table** (", item$rows[["shown"]], " rows drawn from ", item$rows[["used"]], " used; ", item$rows[["dropped"]],
    " left out for missing values; the first 10 shown)\n\n",
    r("echo: false", sprintf("knitr::kable(gallery[[%d]]$head, digits = 2)", i)), "\n\n",
    "<details><summary>The spec</summary>\n\n", fenced(yaml::as.yaml(item$spec), "yaml"), "\n\n</details>\n\n",
    "**The code**\n\n", fenced(item$code, "r"), "\n")
}

gallery_qmd <- function(items, rds, palettes = list(), palettes_rds = NULL) paste0(
  "---\ntitle: chaRt gallery\nsubtitle: Every gold spec, static and interactive\n",
  "format:\n  html:\n    embed-resources: true\n    page-layout: full\n    toc: true\n    toc-depth: 2\n",
  "execute:\n  echo: false\n  warning: true\n  message: true\n---\n\n",
  "Each section shows one gold spec from `tests/gold_specs.yaml`: the lint's notes, the static chart beside its plotly ",
  "version at the same size, the first rows of the table that is drawn, and the R code that reproduces the chart.\n\n",
  "```{r}\n#| include: false\nlibrary(ggplot2)\nlibrary(plotly)\ngallery <- readRDS(", deparse(rds), ")\n",
  if (!is.null(palettes_rds)) paste0("palettes <- readRDS(", deparse(palettes_rds), ")\n"), "```\n\n",
  paste(purrr::imap_chr(items, gallery_section), collapse = "\n\n"),
  if (length(palettes)) paste0("\n\n", palette_section(palettes)))

# The palette section: four charts, each drawn under every palette of the matching kind on offer,
#   titled with the palette's label.
PALETTE_CHARTS <- list(
  list(kind = "qualitative", gold = "height against weight by foot", heading = "Football: height against weight, by foot"),
  list(kind = "qualitative", gold = "revenue by year and region (line, 8 lines)", heading = "Panel: revenue by year, 8 regions"),
  list(kind = "sequential", gold = "mean price by region and year (heatmap)", heading = "Panel: mean price by region and year"),
  list(kind = "diverging", gold = "mean price by region and year (heatmap)", midpoint = 25,
       heading = "Panel: mean price by region and year, centred on 25"))
PALETTE_SIZE <- c(width = 6, height = 3.8)

palette_items <- function(work_dir) {
  ents = gold_entries()
  purrr::compact(purrr::map(PALETTE_CHARTS, function(pc) {
    en = purrr::detect(ents, function(e) grepl(pc$gold, e$name, fixed = TRUE))
    g = if (!is.null(en)) gold_load(en, work_dir)
    if (is.null(g)) return(NULL)
    plots = purrr::imap(as.list(chart_palettes(pc$kind)), function(label, name) {
      palette = chart_palette_default()
      palette[[pc$kind]] = name
      spec = en$spec
      spec$title = label
      spec$subtitle = NULL
      if (!is.null(pc$midpoint)) spec$midpoint = pc$midpoint
      p = tryCatch(spec_plot(spec, g$data, g$cb, palette = palette), error = function(e) e)
      list(label = label, plot = if (inherits(p, "ggplot")) p, error = if (inherits(p, "error")) conditionMessage(p),
           notes = if (inherits(p, "ggplot")) attr(p, "notes"))
    })
    list(heading = pc$heading, kind = pc$kind, plots = unname(plots))
  }))
}

palette_section <- function(sections) {
  px = round(PALETTE_SIZE[["width"]] * GALLERY_DPI)
  opts = c(paste("fig-width:", PALETTE_SIZE[["width"]]), paste("fig-height:", PALETTE_SIZE[["height"]]),
           paste("fig-dpi:", SPEC_DPI), GALLERY_DEV, paste0('out-width: "', px, 'px"'))
  chunk = function(i, j) paste0("```{r}\n", paste0("#| ", opts, collapse = "\n"), "\n", sprintf("print(palettes[[%d]]$plots[[%d]]$plot)", i, j), "\n```")
  paste0("# Palettes\n\nEach chart below is drawn under every palette of its kind that this installation offers ",
         "(`chart_palettes()`), titled with the palette's label. The report uses one palette of each kind throughout.\n\n",
         paste(purrr::imap_chr(sections, function(sec, i) paste0(
           "## ", sec$heading, " (", sec$kind, ")\n\n",
           ":::: {style=\"display:flex; flex-wrap:wrap; gap:1.5rem; align-items:flex-start\"}\n",
           paste(purrr::imap_chr(sec$plots, function(pl, j) paste0(
             "::: {style=\"width:", px, "px\"}\n",
             if (!is.null(pl$plot)) chunk(i, j) else paste0("**", pl$label, ":** could not draw this: ", pl$error),
             if (length(pl$notes)) paste0("\n\n", paste0("- ", pl$notes, collapse = "\n")) else "",
             "\n:::\n")), collapse = ""),
           "::::\n")), collapse = "\n"))
}

# Quarto, as probe/app.R finds it: QUARTO_PATH, then the PATH.
quarto_bin <- function() {
  env = Sys.getenv("QUARTO_PATH")
  if (nzchar(env) && file.exists(env)) return(env)
  p = Sys.which("quarto")
  if (nzchar(p)) unname(p) else stop("Quarto was not found (QUARTO_PATH or the PATH).", call. = FALSE)
}

build_gallery <- function(out = GALLERY_OUT) {
  work = tempfile("gallery_")
  dir.create(work)
  runs = purrr::compact(purrr::map(gold_entries(), gold_run, work_dir = work))
  items = purrr::map(runs, gallery_item)
  rds = normalizePath(file.path(work, "gallery.rds"), winslash = "/", mustWork = FALSE)
  saveRDS(items, rds)
  palettes = palette_items(work)
  palettes_rds = normalizePath(file.path(work, "palettes.rds"), winslash = "/", mustWork = FALSE)
  saveRDS(palettes, palettes_rds)
  qmd = file.path(work, "gallery.qmd")
  writeLines(gallery_qmd(items, rds, palettes, palettes_rds), qmd, useBytes = TRUE)
  Sys.setenv(QUARTO_R = R.home("bin"))
  started = Sys.time()
  said = suppressWarnings(system2(quarto_bin(), c("render", shQuote(qmd), "--to", "html", "--quiet"), stdout = TRUE, stderr = TRUE))
  html = file.path(work, "gallery.html")
  if (!file.exists(html)) stop("Quarto did not write the gallery:\n", paste(utils::tail(said, 30), collapse = "\n"), call. = FALSE)
  file.copy(html, out, overwrite = TRUE)
  cat("Wrote ", out, " (", round(file.size(out) / 1e6, 1), " MB, ", length(items), " specs, ",
      round(as.numeric(difftime(Sys.time(), started, units = "secs"))), " s to render).\n", sep = "")
  invisible(out)
}

if (sys.nframe() == 0L) {
  invisible(shiny::shinyAppDir("."))
  build_gallery()
}
