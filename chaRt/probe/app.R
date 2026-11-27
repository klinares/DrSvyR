# chaRt probe -- a one-page Shiny app to publish once at work, to learn what the server can do.
#   Run:     shiny::runApp("chaRt/probe")
#   Publish: rsconnect::deployApp("chaRt/probe", appName = "chaRt-probe")
# No model calls and no key. Every check is wrapped in tryCatch, so one failure does not hide the
#   others, and its answer is "yes", "no" or the error text. The table is repeated as plain text
#   under "Copy results", to be typed back at home. Needs only shiny, so it starts on a bare server;
#   that is why it uses base lapply() and vapply() rather than purrr (still no loops).
# Three tables: the checks, Graphics (Phase 8: can this server draw without X11) and Motion (Phase 12: how long the frames of an
#   animated chart take to draw here, and what they weigh in a page; chaRt uses no video encoder).

library(shiny)

APP_CLASSIFICATION <- "UNCLASSIFIED"

# The packages chaRt will need, reported with their versions.
PROBE_PACKAGES <- c("ggiraph", "shinychat", "yaml", "quarto", "ragg", "htmltools", "knitr", "rmarkdown",
                    "ggplot2", "readr", "dplyr", "tidyr", "tibble", "paletteer")

# The three-line document rendered from inside the running app (plus the YAML fences).
PROBE_QMD <- c("---",
               "title: chaRt probe",
               "format: {html: {embed-resources: true}}",
               "---",
               "Quarto rendered this page from inside a running Shiny app.")

# The render that matters for the report: one R chunk drawing a small ggplot and printing
#   ggiraph::girafe() of it, so knitr, ggplot2, ggiraph and the embedded JavaScript all run.
PROBE_QMD_R <- c("---",
                 "title: chaRt probe with R",
                 "format: {html: {embed-resources: true}}",
                 "---",
                 "```{r}",
                 "#| echo: false",
                 "p = ggplot2::ggplot(data.frame(x = 1:5, y = c(2, 4, 3, 5, 6)), ggplot2::aes(x, y)) + ggplot2::geom_line()",
                 "ggiraph::girafe(ggobj = p)",
                 "```")

# A Quarto dashboard, the smallest one.
PROBE_QMD_DASHBOARD <- c("---",
                         "title: chaRt probe dashboard",
                         "format: dashboard",
                         "---",
                         "Quarto rendered this dashboard from inside a running Shiny app.")

# The same dashboard asked to embed its resources, as the export must be one file.
PROBE_QMD_DASHBOARD_EMBED <- c("---",
                               "title: chaRt probe dashboard",
                               "format: {dashboard: {embed-resources: true}}",
                               "---",
                               "Quarto rendered this dashboard from inside a running Shiny app.")

# What the R chunk needs; the check does not run without them.
PROBE_QMD_R_NEEDS <- c("knitr", "rmarkdown", "ggplot2", "ggiraph")

# What R chose for bitmapType before anything here set it (a Linux server with no X11 should say "cairo"), then the same
#   switch chaRt makes at start-up: cairo for every png() that names no type, when R has cairo.
PROBE_BITMAP_TYPE_AT_START <- getOption("bitmapType")
if (isTRUE(unname(capabilities("cairo")))) options(bitmapType = "cairo")


# ---- the checks ----------------------------------------------------------------------------

# One check: its answer as text, or the error (or warning) it met.
probe <- function(expr)
  tryCatch(expr, warning = function(w) paste("warning:", conditionMessage(w)),
           error = function(e) paste("error:", conditionMessage(e)))

pkg_version <- function(p)
  if (requireNamespace(p, quietly = TRUE)) paste("yes,", as.character(utils::packageVersion(p))) else "no"

# Where Quarto is. The quarto R package was not installed where this probe was written, so the
#   name of its path function could not be confirmed there: quarto_path() is used only if the
#   installed package exports that name, and the route taken is reported. Otherwise QUARTO_PATH,
#   then the PATH.
quarto_bin <- function() {
  from_pkg = if (requireNamespace("quarto", quietly = TRUE) && "quarto_path" %in% getNamespaceExports("quarto"))
    tryCatch(getExportedValue("quarto", "quarto_path")(), error = function(e) NULL)
  env = Sys.getenv("QUARTO_PATH")
  path = Sys.which("quarto")
  if (length(from_pkg) && nzchar(from_pkg)) list(path = unname(from_pkg), how = "quarto::quarto_path()")
  else if (nzchar(env) && file.exists(env)) list(path = env, how = "QUARTO_PATH")
  else if (nzchar(path)) list(path = unname(path), how = "the PATH")
  else NULL
}

quarto_found <- function() {
  q = quarto_bin()
  if (is.null(q)) return("no (not from the quarto package, QUARTO_PATH or the PATH)")
  paste0("yes, ", q$path, " (found through ", q$how, ")")
}

quarto_version <- function() {
  q = quarto_bin()
  if (is.null(q)) return("no (Quarto not found)")
  out = suppressWarnings(system2(q$path, "--version", stdout = TRUE, stderr = TRUE))
  paste(out, collapse = " ")
}

# Renders a document in a fresh folder under tempdir() with the Quarto command line, and says
#   whether the HTML came out self-contained (no side folder of files) and how long it took.
#   QUARTO_R points Quarto at the R running this app, so an R chunk runs in the same installation.
quarto_render <- function(doc = PROBE_QMD, to = "html") {
  q = quarto_bin()
  if (is.null(q)) return("no (Quarto not found)")
  dir = tempfile("probe_qmd_")
  dir.create(dir)
  qmd = file.path(dir, "probe.qmd")
  writeLines(doc, qmd)
  old_r = Sys.getenv("QUARTO_R", unset = NA)
  Sys.setenv(QUARTO_R = R.home("bin"))
  on.exit(if (is.na(old_r)) Sys.unsetenv("QUARTO_R") else Sys.setenv(QUARTO_R = old_r), add = TRUE)
  started = Sys.time()
  # A failed command also raises a warning; its output says more, so the warning is not kept.
  out = suppressWarnings(system2(q$path, c("render", shQuote(qmd), if (!is.null(to)) c("--to", to), "--quiet"),
                                 stdout = TRUE, stderr = TRUE))
  secs = as.numeric(difftime(Sys.time(), started, units = "secs"))
  status = if (is.null(attr(out, "status"))) 0L else attr(out, "status")
  html = file.path(dir, "probe.html")
  if (status != 0L || !file.exists(html))
    return(paste0("no, after ", sprintf("%.1f", secs), " s (exit status ", status, "): ",
                  substr(paste(out, collapse = " "), 1, 400)))
  side = dir.exists(file.path(dir, "probe_files"))
  paste0("yes, in ", sprintf("%.1f", secs), " s; ", round(file.size(html) / 1024), " KB; ",
         if (side) "NOT self-contained (a probe_files folder was left)" else "self-contained, no _files folder left")
}

# The second render, with R in it; it says which packages are missing instead of running.
quarto_render_r <- function() {
  missing = PROBE_QMD_R_NEEDS[!vapply(PROBE_QMD_R_NEEDS, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) return(paste0("no, not run: ", paste(missing, collapse = ", "), " not installed"))
  quarto_render(PROBE_QMD_R)
}

# A format: dashboard document, rendered with the format the document names.
quarto_render_dashboard <- function() quarto_render(PROBE_QMD_DASHBOARD, to = NULL)

# The same, with embed-resources: true under the dashboard format.
quarto_render_dashboard_embed <- function() quarto_render(PROBE_QMD_DASHBOARD_EMBED, to = NULL)

cairo_png <- function() {
  f = tempfile(fileext = ".png")
  grDevices::png(f, width = 400, height = 300, type = "cairo")
  graphics::plot(1:10, main = "chaRt probe")
  grDevices::dev.off()
  if (file.exists(f) && file.size(f) > 0)
    paste0("yes, ", round(file.size(f) / 1024, 1), " KB (capabilities('cairo') is ", capabilities("cairo"), ")")
  else "no (no file was written)"
}

tempdir_writable <- function() {
  f = tempfile("probe_write_")
  writeLines("chaRt probe", f)
  back = readLines(f)
  unlink(f)
  if (identical(back, "chaRt probe")) paste("yes,", tempdir()) else "no (what was read back differs)"
}

# ---- Graphics: can this server draw a chart without X11? -----------------------------------------------------------------
#   chaRt draws every chart on one device chosen in one place: ragg when it is installed, else base R's png(type = "cairo")
#   when R has cairo, else svglite, else it says the server cannot draw. This section shows which of those this server has,
#   draws one chart with each, and shows the pictures. Written here again, not shared with the app: this folder is published
#   alone. Needs only shiny; the chart needs ggplot2 and falls back to base graphics without it.

PROBE_GRAPHICS_PACKAGES <- c("ragg", "svglite", "Cairo", "systemfonts")
PROBE_FONT_NAME <- "chaRt probe font"

# The most useful parts of Sys.info(): the operating system and the machine. The host name and the user names it also holds
#   are left out, since this table is copied by hand into other places.
sys_info_text <- function() {
  i = Sys.info()
  paste0(i[["sysname"]], " ", i[["release"]], " (", i[["machine"]], "); ", i[["version"]])
}

capability <- function(what) function() as.character(unname(capabilities(what)))

# Whether png(type = "Xlib") opens: what a stray call that names no type gets on a server where R chose Xlib, and
#   what fails on Linux with no X11. A device that opened is closed at once.
xlib_png <- function() {
  f = tempfile(fileext = ".png")
  opened = tryCatch({ grDevices::png(f, width = 200, height = 200, type = "Xlib"); TRUE },
                    warning = function(w) paste("no:", conditionMessage(w)), error = function(e) paste("no:", conditionMessage(e)))
  if (isTRUE(opened)) { grDevices::dev.off(); return("yes (X11 is available)") }
  if (!is.null(grDevices::dev.list())) grDevices::dev.off()
  opened
}

# A font to draw the chart in. The bundled Inter when chaRt's www/fonts is copied beside this app (www/fonts/Inter-Regular.ttf
#   and Inter-Bold.ttf); otherwise the first monospace TrueType file the machine has (a face that is easy to tell from the default
#   sans), else any TrueType file. Registered once with systemfonts under PROBE_FONT_NAME. Returns the family to draw in and what
#   happened, in words; "sans" and the reason when it could not be done.
probe_font_state <- new.env()
probe_font <- function() {
  if (!is.null(probe_font_state$done)) return(probe_font_state$done)
  out = function(family, how, found = FALSE) { probe_font_state$done = list(family = family, how = how, found = found); probe_font_state$done }
  if (!requireNamespace("systemfonts", quietly = TRUE)) return(out("sans", "no, systemfonts is not installed"))
  bundled = file.path("www", "fonts", c("Inter-Regular.ttf", "Inter-Bold.ttf"))
  sys = tryCatch(systemfonts::system_fonts(), error = function(e) NULL)
  flag = function(name) if (!is.null(sys) && name %in% names(sys)) sys[[name]] %in% TRUE else rep(FALSE, length(sys$path))
  ttf = if (is.null(sys) || !all(c("path", "index") %in% names(sys))) NULL else sys[grepl("[.]ttf$", sys$path, ignore.case = TRUE) & sys$index == 0 & !flag("variable"), , drop = FALSE]
  mono = if (is.null(ttf) || !"monospace" %in% names(ttf)) NULL else ttf[ttf$monospace %in% TRUE, , drop = FALSE]
  pick = if (all(file.exists(bundled))) list(plain = bundled[[1]], bold = bundled[[2]], what = "the bundled Inter (www/fonts is beside this app)")
    else if (!is.null(mono) && nrow(mono)) list(plain = mono$path[[1]], bold = mono$path[[1]], what = paste0(mono$family[[1]], " (a monospace file this server has; the bundled files are not in this app)"))
    else if (!is.null(ttf) && nrow(ttf)) list(plain = ttf$path[[1]], bold = ttf$path[[1]], what = paste0(ttf$family[[1]], " (a file this server has; the bundled files are not in this app)"))
    else NULL
  if (is.null(pick)) return(out("sans", "no, found no TrueType file to register"))
  if (!PROBE_FONT_NAME %in% systemfonts::registry_fonts()$family)
    tryCatch(systemfonts::register_font(PROBE_FONT_NAME, plain = pick$plain, bold = pick$bold),
             error = function(e) pick$error <<- conditionMessage(e))
  if (!is.null(pick$error)) return(out("sans", paste("no, register_font() said:", pick$error)))
  matched = tryCatch(systemfonts::match_fonts(PROBE_FONT_NAME)$path, error = function(e) "")
  found = identical(normalizePath(matched, mustWork = FALSE), normalizePath(pick$plain, mustWork = FALSE))
  out(PROBE_FONT_NAME, paste0(if (found) "yes" else "registered, but match_fonts() found another file", ": ", pick$what), found)
}

probe_chart <- function(family) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) return(NULL)
  d = data.frame(region = c("West", "East", "North", "South"), revenue = c(94, 53, 38, 31))
  ggplot2::ggplot(d, ggplot2::aes(x = region, y = revenue)) + ggplot2::geom_col(fill = "#0072B2") +
    ggplot2::labs(title = "Revenue by region", subtitle = paste0("Asked for the font family: ", family), x = NULL, y = NULL) +
    ggplot2::theme_minimal(base_family = family, base_size = 14)
}

# One chart drawn with one device, 7 by 4.5 inches at 192 pixels per inch (the app's size), and what came of it:
#   list(ok, text, file, type). The device is closed, and a device that failed to open is not closed.
probe_draw <- function(kind) {
  f = tempfile(fileext = if (identical(kind, "svglite")) ".svg" else ".png")
  have = switch(kind, ragg = requireNamespace("ragg", quietly = TRUE), svglite = requireNamespace("svglite", quietly = TRUE),
                cairo = isTRUE(unname(capabilities("cairo"))))
  if (!isTRUE(have)) return(list(ok = FALSE, text = switch(kind, cairo = "no (capabilities('cairo') is FALSE)", "no (not installed)")))
  started = Sys.time()
  font = probe_font()
  p = probe_chart(font$family)
  res = tryCatch({
    switch(kind,
           ragg = ragg::agg_png(f, width = 1344, height = 864, units = "px", res = 192),
           cairo = grDevices::png(f, width = 1344, height = 864, units = "px", res = 192, type = "cairo"),
           svglite = svglite::svglite(f, width = 7, height = 4.5))
    drawn = tryCatch({
      if (is.null(p)) graphics::barplot(c(94, 53, 38, 31), names.arg = c("West", "East", "North", "South"), main = "Revenue by region (base graphics)")
      else print(p)
      TRUE
    }, error = function(e) paste("error while drawing:", conditionMessage(e)))
    grDevices::dev.off()
    drawn
  }, error = function(e) paste("error opening the device:", conditionMessage(e)), warning = function(w) paste("warning:", conditionMessage(w)))
  if (!is.null(grDevices::dev.list())) grDevices::dev.off()
  secs = as.numeric(difftime(Sys.time(), started, units = "secs"))
  if (!isTRUE(res) || !file.exists(f) || file.size(f) == 0) return(list(ok = FALSE, text = paste0("no, ", if (is.character(res)) res else "no file was written")))
  list(ok = TRUE, file = f, type = if (identical(kind, "svglite")) "image/svg+xml" else "image/png",
       text = paste0("yes, ", round(file.size(f) / 1024, 1), " KB in ", sprintf("%.1f", secs), " s",
                     if (is.null(p)) "; ggplot2 is not installed, so a base graphics chart" else ""))
}

# The Graphics table: what R and the machine say, then the three drawing paths.
graphics_rows <- function() {
  c(list(list("R version", function() R.version.string),
         list("Operating system (Sys.info(), without host and user names)", sys_info_text),
         list("capabilities(\"X11\")", capability("X11")),
         list("capabilities(\"cairo\")", capability("cairo")),
         list("capabilities(\"png\")", capability("png")),
         list("capabilities(\"jpeg\")", capability("jpeg")),
         list("A display is set (the DISPLAY variable)", function() if (nzchar(Sys.getenv("DISPLAY"))) "yes" else "no"),
         list("options(bitmapType) when this app started", function() if (is.null(PROBE_BITMAP_TYPE_AT_START)) "not set" else PROBE_BITMAP_TYPE_AT_START),
         list("options(bitmapType) now (set to cairo here when R has cairo, as chaRt does)", function() if (is.null(getOption("bitmapType"))) "not set" else as.character(getOption("bitmapType"))),
         list("png(type = \"Xlib\") opens (a stray call's device where there is no X11)", xlib_png)),
    lapply(PROBE_GRAPHICS_PACKAGES, function(p) list(p, function() pkg_version(p))),
    list(list("A font file registers with systemfonts and is found by name", function() probe_font()$how),
         list("A chart draws with ragg", function() probe_draw("ragg")$text),
         list("A chart draws with png(type = \"cairo\")", function() probe_draw("cairo")$text),
         list("A chart draws with svglite", function() probe_draw("svglite")$text)))
}

graphics_table <- function() {
  rows = graphics_rows()
  data.frame(Check = vapply(rows, function(r) r[[1]], character(1)),
             Result = vapply(rows, function(r) as.character(probe(r[[2]]()))[1], character(1)))
}

# The three pictures, to be looked at: the same chart, each drawn by its own device, in the font that was registered. ragg and
#   svglite read systemfonts, so they should show it; the cairo device asks the operating system, so it should show its default
#   face. An SVG shown as an image is drawn by the browser, which has none of this server's fonts.
graphics_pictures <- function() {
  font = probe_font()
  one = function(kind, label) {
    d = probe_draw(kind)
    tags$div(style = "margin-bottom:1.5em;",
             tags$h5(label),
             tags$p(d$text),
             if (isTRUE(d$ok))
               tags$img(src = paste0("data:", d$type, ";base64,", gsub("\\s", "", jsonlite::base64_enc(readBin(d$file, "raw", file.size(d$file))))),
                        alt = label, style = "max-width:100%; border:1px solid #ccc;"))
  }
  tags$div(
    tags$p(paste0("The same chart, drawn by each device that is available. The font asked for: ", font$family, ". Registered: ", font$how, ".")),
    one("ragg", "ragg"), one("cairo", "png(type = \"cairo\")"), one("svglite", "svglite (an SVG, drawn by the browser)"))
}

# ---- Motion: how long the frames of chaRt's Animate button take to draw here --------------------------------------------------
#   chaRt draws 44 frames of a chart as PNG files (12 a second, 3.6 seconds, at a card's width of 1080 pixels), and the browser plays
#   them from the page (Phase 12: no video file, no encoder). This section shows how long 44 frames of 1080 by 760 take to draw on this
#   server and what they weigh, as files and as the base64 the page holds. The chart is a made-up bar chart whose bars rise, drawn the way chaRt draws a frame
#   (the scale fixed at its final limits), with ragg when it is installed, else png(type = "cairo"). Written here again, not shared with
#   the app: this folder is published alone. No model call, no key, no file from the user: every number below is made up here.

PROBE_VIDEO_VALUES <- c(West = 94, East = 53, North = 38, South = 31, Centre = 22)

# A PNG at the given size on the best device this server has (ragg, else cairo), drawn by draw(); the device is closed whatever happens
#   in draw(), and a device that could not be opened is not closed. Errors reach the caller.
probe_png <- function(file, width, height, draw) {
  if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png(file, width = width, height = height, units = "px", res = 144)
  else if (isTRUE(unname(capabilities("cairo")))) grDevices::png(file, width = width, height = height, units = "px", res = 144, type = "cairo")
  else stop("neither ragg nor cairo is available to draw a PNG")
  on.exit(grDevices::dev.off())
  draw()
  invisible(file)
}

# The bars of one frame at progress 0 to 1: the value is the final value times a cubic ease; the scale is the final one in every frame.
probe_frame <- function(progress) {
  eased = if (progress < 0.5) 4 * progress^3 else 1 - (-2 * progress + 2)^3 / 2
  d = data.frame(region = factor(names(PROBE_VIDEO_VALUES), levels = names(PROBE_VIDEO_VALUES)), value = unname(PROBE_VIDEO_VALUES) * eased)
  if (requireNamespace("ggplot2", quietly = TRUE))
    print(ggplot2::ggplot(d, ggplot2::aes(x = region, y = value)) + ggplot2::geom_col(fill = "#0072B2") +
            ggplot2::scale_y_continuous(limits = c(0, 100)) +
            ggplot2::labs(title = "chaRt probe: a frame of an animated chart", x = NULL, y = NULL) + ggplot2::theme_minimal(base_size = 18))
  else graphics::barplot(d$value, names.arg = as.character(d$region), ylim = c(0, 100), main = "chaRt probe: a frame of an animated chart (base graphics)")
  invisible(NULL)
}

# The pixel size a PNG file says it has (width, height), read from its header; NULL when the file is not a PNG.
png_size <- function(file) {
  b = readBin(file, "raw", 24)
  if (length(b) < 24 || !identical(b[1:4], as.raw(c(0x89, 0x50, 0x4e, 0x47)))) return(NULL)
  be = function(x) sum(as.integer(x) * 256^(3:0))
  c(width = be(b[17:20]), height = be(b[21:24]))
}

# n frames at the given size into a new folder, timed. list(ok, files, secs, size, text); a failure is text, not an error.
#   Kept for the session: the weight of the same frames does not draw them again.
probe_video_state <- new.env()
probe_frames <- function(n, width, height) {
  key = paste(n, width, height)
  if (!is.null(probe_video_state[[key]])) return(probe_video_state[[key]])
  dir = tempfile("probe_video_")
  dir.create(dir)
  files = file.path(dir, sprintf("frame%03d.png", seq_len(n)))
  started = Sys.time()
  res = tryCatch({ lapply(seq_len(n), function(i) probe_png(files[i], width, height, function() probe_frame((i - 1) / max(n - 1, 1)))); NULL },
                 error = function(e) conditionMessage(e), warning = function(w) conditionMessage(w))
  secs = as.numeric(difftime(Sys.time(), started, units = "secs"))
  made = file.exists(files) & file.size(files) > 0
  out = if (!is.null(res) || !all(made))
    list(ok = FALSE, files = files[made], secs = secs, text = paste0("no, ", sum(made), " of ", n, " frames were written", if (!is.null(res)) paste0(" (", res, ")") else ""))
  else {
    size = png_size(files[[1]])
    list(ok = TRUE, files = files, secs = secs, size = size, mb = sum(file.size(files)) / 1048576,
         text = paste0("yes, ", n, " frames of ", size[["width"]], " by ", size[["height"]], " in ", sprintf("%.1f", secs), " s (", sprintf("%.2f", secs / n), " s a frame); the PNGs are ",
                       sprintf("%.1f", sum(file.size(files)) / 1048576), " MB"))
  }
  assign(key, out, envir = probe_video_state)
  out
}

PROBE_MOTION_FRAMES <- 44L
PROBE_MOTION_PX <- c(width = 1080, height = 760)

video_frames_draw <- function() probe_frames(PROBE_MOTION_FRAMES, PROBE_MOTION_PX[["width"]], PROBE_MOTION_PX[["height"]])$text

# What the same frames add to a page: their bytes as base64 (four characters for three bytes), the frames that are the same as the one before kept once.
video_frames_weight <- function() {
  f = probe_frames(PROBE_MOTION_FRAMES, PROBE_MOTION_PX[["width"]], PROBE_MOTION_PX[["height"]])
  if (!isTRUE(f$ok)) return(paste0("no, the frames could not be drawn: ", f$text))
  bytes = vapply(f$files, function(x) paste(readBin(x, "raw", file.size(x)), collapse = ""), character(1))
  kept = f$files[c(TRUE, bytes[-1] != bytes[-length(bytes)])]
  paste0("yes, ", length(kept), " of ", length(f$files), " frames kept; ", sprintf("%.2f", sum(4 * ceiling(file.size(kept) / 3)) / 1048576), " MB in the page as base64")
}

# The Motion table: the frames drawn, timed, and their weight.
video_rows <- function() {
  list(list(paste0(PROBE_MOTION_FRAMES, " frames of ", PROBE_MOTION_PX[["width"]], " by ", PROBE_MOTION_PX[["height"]], " draw (the frames of an animated card)"), video_frames_draw),
       list("Their weight in a page", video_frames_weight))
}

video_table <- function() {
  rows = video_rows()
  data.frame(Check = vapply(rows, function(r) r[[1]], character(1)),
             Result = vapply(rows, function(r) as.character(probe(r[[2]]()))[1], character(1)))
}

# Every check, in the order the table shows them.
run_checks <- function() {
  rows = c(
    list(list("R version", function() R.version.string),
         list("shiny", function() pkg_version("shiny")),
         list("ellmer", function() pkg_version("ellmer"))),
    lapply(PROBE_PACKAGES, function(p) list(p, function() pkg_version(p))),
    list(list("Quarto found", quarto_found),
         list("Quarto version", quarto_version),
         list("A .qmd renders to self-contained HTML from the app", quarto_render),
         list("A .qmd with an R chunk (ggplot, then girafe) renders to self-contained HTML", quarto_render_r),
         list("A format: dashboard document renders from the app", quarto_render_dashboard),
         list("The same dashboard with embed-resources: true renders from the app", quarto_render_dashboard_embed),
         list("A PNG draws with type = \"cairo\"", cairo_png),
         list("tempdir() is writable", tempdir_writable)))
  data.frame(Check = vapply(rows, function(r) r[[1]], character(1)),
             Result = vapply(rows, function(r) as.character(probe(r[[2]]()))[1], character(1)))
}

as_text <- function(tab)
  paste(c(paste("chaRt probe,", format(Sys.time(), "%Y-%m-%d %H:%M %Z")),
          paste0(tab$Check, ": ", tab$Result)), collapse = "\n")


# ---- the page ---------------------------------------------------------------------------

ui <- fluidPage(
  title = "chaRt probe",
  tags$div(
    style = paste("background:#b40404; color:#fff; text-align:center;",
                  "font-weight:700; letter-spacing:0.06em;",
                  "padding:5px 0; font-size:13px;"),
    APP_CLASSIFICATION),
  tags$h2("chaRt probe"),
  tags$p("What this server can do for chaRt. Nothing is sent anywhere; no key is needed."),
  tableOutput("checks"),
  tags$h3("Graphics"),
  tags$p("Can this server draw a chart without X11? What R and the machine say, then one chart drawn by each device that is available."),
  tableOutput("graphics"),
  uiOutput("graphics_pictures"),
  tags$h3("Motion"),
  tags$p("How long the frames behind chaRt's Animate button take to draw on this server, and what they weigh in a page. The browser plays them as they are; no video file is made. The chart is made up here."),
  tableOutput("video"),
  tags$h4("Copy results"),
  tags$p("The same table as plain text, to copy or type back at home."),
  uiOutput("copy"))

server <- function(input, output, session) {
  checks <- reactive(withProgress(message = "Running the checks", value = 0.5, run_checks()))
  output$checks <- renderTable(checks(), striped = TRUE, bordered = TRUE)
  graphics <- reactive(withProgress(message = "Drawing a chart with each device", value = 0.5, graphics_table()))
  output$graphics <- renderTable(graphics(), striped = TRUE, bordered = TRUE)
  output$graphics_pictures <- renderUI(tryCatch(graphics_pictures(), error = function(e) tags$p(paste("error:", conditionMessage(e)))))
  video <- reactive(withProgress(message = "Drawing the frames of an animated chart", value = 0.5, video_table()))
  output$video <- renderTable(video(), striped = TRUE, bordered = TRUE)
  output$copy <- renderUI(
    textAreaInput("copy_text", NULL, value = as_text(rbind(checks(), graphics(), video())), width = "100%", rows = nrow(checks()) + nrow(graphics()) + nrow(video()) + 3))
}

shinyApp(ui, server)
