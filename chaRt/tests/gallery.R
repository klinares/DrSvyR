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


# ---- the style sheet -------------------------------------------------------------------------------------------
#   tests/style_sheet.html: static charts only, no model call, no Quarto. How the look is judged without a key: every family in every
#   style with the default palette; one family in every qualitative palette on Clean and on Dark; three charts with labels and
#   annotations; one chart of each family with labels and annotate in Newspaper and Dark; and the MetBrewer palettes on offer.

STYLE_SHEET_OUT <- file.path("tests", "style_sheet.html")
STYLE_SHEET_PX <- 540

# One gold spec for each family (a fragment of its name in tests/gold_specs.yaml): the panel file is made by the tests, the football
#   and Freedom House files are the course's.
STYLE_SHEET_GOLD <- c(bar = "panel, total revenue by region (bar", dot = "football, mean height by position (dot)",
                      line = "panel, revenue in three regions far apart", slope = "panel, mean price first year against last, two highlighted",
                      scatter = "football, height against weight by foot", bubble = "panel, price against units sized by revenue",
                      histogram = "FH, political rights 2014 (histogram)", box = "panel, price by region (box)",
                      heatmap = "panel, mean price by region and year (heatmap)")

# What marks each family takes under `labels = "on"` and `annotate` (a family that cannot mark a point gets labels only).
#   A scatter or bubble writes names on its highlighted points (so the bubble gets a highlight here, the scatter has none and only
#   its highest point is marked); a histogram and a box have no marks to write on and take neither.
STYLE_SHEET_MARKS <- list(bar = list(labels = "on", annotate = list("highest")), dot = list(labels = "on", annotate = list("highest")),
                          line = list(labels = "on", annotate = list("highest", "latest")), slope = list(labels = "on"),
                          scatter = list(annotate = list("highest")),
                          bubble = list(annotate = list("highest"), highlight = list(column = "region", values = list("North", "Islands"))),
                          histogram = list(), box = list(), heatmap = list(labels = "on"))

sheet_gold <- function(fragment, work) {
  en = purrr::detect(gold_entries(), function(e) grepl(fragment, e$name, fixed = TRUE))
  g = if (!is.null(en)) gold_load(en, work)
  if (!is.null(g)) list(spec = en$spec, g = g, name = en$name)
}

sheet_palette <- function(style, qualitative = NULL)
  utils::modifyList(chart_palette_default(), c(list(style = style), if (!is.null(qualitative)) list(qualitative = qualitative)))

# One cell of the sheet: the chart as a PNG (or the error), the caption and the lint's notes.
sheet_cell <- function(caption, spec, g, palette) {
  p = tryCatch(spec_plot(spec, g$data, g$cb, palette), error = function(e) e)
  if (!inherits(p, "ggplot"))
    return(list(ok = FALSE, html = paste0("<figure><figcaption>", htmltools::htmlEscape(caption), "</figcaption><p class=\"bad\">Could not draw this: ",
                                          htmltools::htmlEscape(conditionMessage(p)), "</p></figure>")))
  f = tempfile(fileext = ".png")
  sz = spec_png(p, f)
  notes = attr(p, "notes")
  list(ok = TRUE, html = paste0("<figure><figcaption>", htmltools::htmlEscape(caption), "</figcaption><img loading=\"lazy\" alt=\"", htmltools::htmlEscape(caption),
                                "\" width=\"", STYLE_SHEET_PX, "\" src=\"data:image/png;base64,", jsonlite::base64_enc(readBin(f, "raw", file.size(f))), "\">",
                                if (length(notes)) paste0("<ul>", paste0("<li>", htmltools::htmlEscape(notes), "</li>", collapse = ""), "</ul>"), "</figure>"))
}

sheet_section <- function(heading, intro, cells)
  list(n = sum(purrr::map_lgl(cells, "ok")),
       html = paste0("<section><h2>", htmltools::htmlEscape(heading), "</h2><p class=\"intro\">", htmltools::htmlEscape(intro), "</p><div class=\"grid\">",
                     paste(purrr::map_chr(cells, "html"), collapse = ""), "</div></section>"))

build_style_sheet <- function(out = STYLE_SHEET_OUT) {
  work = tempfile("style_sheet_")
  dir.create(work)
  gold = purrr::map(STYLE_SHEET_GOLD, sheet_gold, work = work)
  panel = sheet_gold("panel, revenue by year and region (line, 8 lines)", work)
  styles = names(CHART_STYLES)
  with_marks = function(spec, fam) utils::modifyList(spec, STYLE_SHEET_MARKS[[fam]] %||% list())
  # A. every family in every style, the default palettes
  a = purrr::compact(purrr::imap(gold, function(x, fam) if (!is.null(x))
    purrr::map(styles, function(s) sheet_cell(paste0(fam, ", ", CHART_STYLES[[s]]$label), x$spec, x$g, sheet_palette(s)))))
  sec_a = sheet_section("Every family in every style", "The default palettes (Okabe-Ito, Viridis, RdBu), one gold spec for each family, exactly as written there.", unlist(a, recursive = FALSE))
  # B. one family in every qualitative palette, on Clean and on Dark: a line chart of four regions
  regions = utils::head(sort(unique(as.character(panel$g$data$region))), 4L)
  line4 = utils::modifyList(panel$spec, list(filter = list(list(column = "region", op = "in", value = as.list(regions)))))
  b = purrr::list_flatten(purrr::map(c("clean", "dark"), function(s)
    purrr::imap(as.list(chart_palettes("qualitative")), function(label, k) {
      sp = line4
      sp$title = label
      sheet_cell(paste0(label, " on ", CHART_STYLES[[s]]$label, " (", palette_usable_max(k, s), " of ", chart_palette_max(k), " colours show)"), sp, panel$g, sheet_palette(s, k))
    })))
  sec_b = sheet_section("Every qualitative palette, on Clean and on Dark", "A line chart of four regions. In brackets: how many of the palette's colours the style shows (a colour that cannot be seen is skipped).", unname(b))
  # C. three charts with labels and annotations, on Clean
  c3 = purrr::compact(purrr::map(c("bar", "line", "scatter"), function(fam) {
    x = if (identical(fam, "scatter")) gold$scatter else if (identical(fam, "line")) panel else gold$bar
    if (is.null(x)) return(NULL)
    sp = x$spec
    sp$title = paste0(sp$title %||% fam, "")
    sp = utils::modifyList(sp, c(if (!identical(fam, "scatter")) list(labels = "on"), list(annotate = if (identical(fam, "line")) list("highest", "latest") else list("highest", "lowest"))))
    sheet_cell(paste0(fam, " with labels and annotations, Clean"), sp, x$g, sheet_palette("clean"))
  }))
  sec_c <- sheet_section("Labels and annotations", "Values on the marks, and the highest, lowest or latest point marked, all written by R.", c3)
  # D. one chart of each family with labels and annotate, Newspaper and Dark
  d = purrr::compact(purrr::imap(gold, function(x, fam) if (!is.null(x))
    purrr::map(c("newspaper", "dark"), function(s) sheet_cell(paste0(fam, if (length(STYLE_SHEET_MARKS[[fam]])) ", labels and annotate, " else ", no labels or annotate for this family, ", CHART_STYLES[[s]]$label), with_marks(x$spec, fam), x$g, sheet_palette(s)))))
  sec_d = sheet_section("Labels and annotate in Newspaper and Dark", "One chart of each family with labels on and annotate where the family takes it (slope, histogram, box and heatmap take labels only).", unlist(d, recursive = FALSE))
  # E. the MetBrewer palettes on offer: qualitative as swatches on a bar chart, sequential and diverging on a heatmap
  met_names = names(purrr::keep(CHART_PALETTES, function(e) identical(e$source, "MetBrewer")))
  met = function(kind) { l = as.list(chart_palettes(kind)); l[names(l) %in% met_names] }
  heat = gold$heatmap
  # the app lets a bar chart colour at most 4 groups, so each qualitative set is shown as a bar chart of its first 4 colours and as a
  #   line chart of all of them (up to 8)
  e_q = purrr::list_flatten(purrr::imap(met("qualitative"), function(label, k) {
    n = min(chart_palette_max(k), 8L)
    pick = function(m) list(list(column = "region", op = "in", value = as.list(utils::head(sort(unique(as.character(panel$g$data$region))), m))))
    bars = list(family = "bar", x = "region", y = "revenue", fn = "sum", color = "region", title = label, labels = "off", filter = pick(min(n, 4L)))
    lines = list(family = "line", x = "year", y = "revenue", fn = "sum", color = "region", title = label, filter = pick(n))
    list(sheet_cell(paste0(label, " (qualitative), bar chart of its first ", min(n, 4L), " colours"), bars, panel$g, sheet_palette("clean", k)),
         sheet_cell(paste0(label, " (qualitative), line chart of its ", n, " colours"), lines, panel$g, sheet_palette("clean", k)))
  }))
  e_c = purrr::list_flatten(purrr::map(c("sequential", "diverging"), function(kind) purrr::imap(met(kind), function(label, k) {
    sp = heat$spec
    sp$title = label
    sp$subtitle = NULL
    if (identical(kind, "diverging")) sp$midpoint = 25
    pal = chart_palette_default()
    pal[[kind]] = k
    sheet_cell(paste0(label, " (", kind, ", offered under our lightness rule, not MetBrewer's)"), sp, heat$g, pal)
  })))
  sec_e = sheet_section("MetBrewer palettes on offer", "Qualitative sets as bars, one colour each; sequential and diverging sets as a heatmap of the mean price, the diverging ones centred on 25.", c(unname(e_q), unname(e_c)))
  secs = list(sec_a, sec_b, sec_c, sec_d, sec_e)
  total = sum(purrr::map_int(secs, "n"))
  html = paste0("<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
                "<title>chaRt style sheet</title><style>body{font-family:system-ui,sans-serif;margin:1.5rem;max-width:1300px;background:#fff;color:#1a1a1a}",
                ".grid{display:flex;flex-wrap:wrap;gap:1.2rem;align-items:flex-start}figure{margin:0;width:", STYLE_SHEET_PX, "px;max-width:100%}",
                "figcaption{font-size:.8rem;color:#555;margin-bottom:.2rem}img{max-width:100%;height:auto;border:1px solid #ddd}ul{font-size:.75rem;color:#555;padding-left:1.1rem}",
                ".intro{color:#555}.bad{color:#b00}section{margin-bottom:2.5rem}</style></head><body><h1>chaRt style sheet</h1>",
                "<p class=\"intro\">", total, " charts drawn by the app's own renderer from the gold specs. No model call. Written by tests/gallery.R.</p>",
                paste(purrr::map_chr(secs, "html"), collapse = ""), "</body></html>")
  writeLines(html, out, useBytes = TRUE)
  cat("Wrote ", out, " (", round(file.size(out) / 1e6, 1), " MB, ", total, " charts in ", length(secs), " sections: ", paste(purrr::map_int(secs, "n"), collapse = ", "), ").\n", sep = "")
  invisible(out)
}

if (sys.nframe() == 0L) {
  invisible(shiny::shinyAppDir("."))
  args = commandArgs(trailingOnly = TRUE)
  if (!identical(args, "style_sheet")) build_gallery()
  build_style_sheet()
}
