# theme.R for chaRt
# The look of every chart: the typeface, the six styles (CHART_STYLES), the ggplot2 theme, the
#   palettes an analyst may choose from, and the colour of a highlight. This is the one file
#   replaced at work with the office theme and palette, so it is self-contained: it uses ggplot2,
#   grDevices, ragg and svglite (when installed: chart_device()), systemfonts (when installed: without it charts
#   draw in the default fonts) and paletteer when it is installed (the app starts without it), and nothing else
#   from the app.
#   R/spec.R reads chart_style(), chart_theme_calls(), chart_style_layers(),
#   chart_font_values(), style_marks(), chart_palette(), chart_sequential(), chart_diverging() and
#   chart_palette_default(); the code a chart comes with carries chart_theme_calls() written out
#   as plain ggplot2 calls. Function definitions and constants only.


# A highlight (Phase 10 Part D): the named values in the style's `accent`, everything else in the style's `slate` (a mid grey
#   that still shows on a projector; the two are at least 3 to 1 apart and each at least 3 to 1 from the background, checked in
#   tests/smoke.R). Emphasis is a statement: R never highlights a mark on its own.

# ---- type ------------------------------------------------------------------------------------------

# The three bundled families (www/fonts/, all under the SIL Open Font License 1.1, each with its
#   licence file). Each is registered with systemfonts under two names: the family itself (regular, and
#   bold for face = "bold") and "<family> SemiBold" (semibold as its plain face), since register_font()
#   takes four faces, not a weight; `fallback` is what a chart draws in when the family is neither
#   registered nor installed. The display family (Barlow Condensed, the Briefing style's headlines) has no regular
#   face: its "regular" is the SemiBold file, and `weights` says that a page declares only its bold face.
CHART_FONT_DIR <- file.path("www", "fonts")
CHART_FONTS <- list(
  sans = list(family = "Inter", fallback = "sans", css = "Inter, sans-serif",
              regular = "Inter-Regular.ttf", semibold = "Inter-SemiBold.ttf", bold = "Inter-Bold.ttf"),
  serif = list(family = "Source Serif 4", fallback = "serif", css = "'Source Serif 4', serif",
               regular = "SourceSerif4-Regular.ttf", semibold = "SourceSerif4-Semibold.ttf", bold = "SourceSerif4-Bold.ttf"),
  display = list(family = "Barlow Condensed", fallback = "sans", css = "'Barlow Condensed', 'Arial Narrow', sans-serif",
                 regular = "BarlowCondensed-SemiBold.ttf", semibold = "BarlowCondensed-SemiBold.ttf", bold = "BarlowCondensed-Bold.ttf",
                 weights = 700))

# The variables the written code and the theme use for a family: sans regular is chart_font, and so on.
CHART_FONT_VARS <- list(chart_font = c("sans", "regular"), chart_font_semibold = c("sans", "semibold"),
                        chart_serif = c("serif", "regular"), chart_serif_semibold = c("serif", "semibold"),
                        chart_display = c("display", "regular"))

# The name a family is registered under, for a weight: "regular" or "semibold".
chart_font_name <- function(role, weight = "regular") {
  f = CHART_FONTS[[role]]$family
  if (identical(weight, "semibold")) paste(f, "SemiBold") else f
}

# Whether systemfonts is installed (find.package(), as for paletteer), and whether a family name is
#   registered with it or installed on the machine.
systemfonts_installed <- function() length(find.package("systemfonts", quiet = TRUE)) > 0L
chart_font_available <- function(name)
  systemfonts_installed() &&
    name %in% c(systemfonts::registry_fonts()$family, systemfonts::system_fonts()$family)

# Registers the bundled families with systemfonts (called once, from app.R, with the folder that holds
#   the files); a family whose files are not all there, or systemfonts missing, is skipped. Returns
#   whether each family (sans, serif) was registered, invisibly.
chart_fonts_register <- function(dir = CHART_FONT_DIR) {
  ok = purrr::map_lgl(CHART_FONTS, function(f) {
    files = file.path(dir, unlist(f[c("regular", "semibold", "bold")]))
    if (!systemfonts_installed() || !all(file.exists(files))) return(FALSE)
    tryCatch({
      systemfonts::register_font(f$family, plain = files[[1]], bold = files[[3]])
      systemfonts::register_font(paste(f$family, "SemiBold"), plain = files[[2]], bold = files[[3]])
      TRUE
    }, error = function(e) FALSE)
  })
  invisible(ok)
}

# The family a chart is drawn in for a role and weight: the bundled one when it is registered or
#   installed, otherwise the default sans (or serif).
chart_font_family <- function(role, weight = "regular") {
  name = chart_font_name(role, weight)
  if (chart_font_available(name)) name else CHART_FONTS[[role]]$fallback
}

# The bundled families that this machine cannot draw in (neither registered nor installed), as their names.
chart_fonts_missing <- function()
  Filter(function(f) !chart_font_available(f), purrr::map_chr(CHART_FONTS, "family"))

# The value of each font variable that a call uses (chart_font, ...): list(chart_font = "Inter", ...).
chart_font_values <- function(calls) {
  used = intersect(names(CHART_FONT_VARS), unlist(purrr::map(calls, all.vars)))
  stats::setNames(purrr::map(used, function(v) chart_font_family(CHART_FONT_VARS[[v]][[1]], CHART_FONT_VARS[[v]][[2]])), used)
}


# ---- the one way to draw -----------------------------------------------------------------------------

# A Linux server with no X11 cannot open base R's default devices (png() with type "Xlib", the device a stray
#   print() or text measurement opens when none is open). So the app opens a device in one place, chart_device(),
#   and every drawing and every text measurement runs inside it. The order: ragg (needs neither X11 nor cairo,
#   and draws in the bundled typefaces through systemfonts); else base R's png(type = "cairo") when R has cairo
#   (it draws, but in the typefaces the operating system has, not the bundled ones); else svglite (an SVG
#   file); else nothing, and CHART_DEVICE_NONE says so. The four switches below are functions so that a test
#   can stand in for a server without ragg, or without cairo.
ragg_installed <- function() length(find.package("ragg", quiet = TRUE)) > 0L
svglite_installed <- function() length(find.package("svglite", quiet = TRUE)) > 0L
cairo_available <- function() isTRUE(unname(capabilities("cairo")))
# shiny has drawn its own plots with ragg, when installed, since 1.7.2 (NEWS: renderPlot() and plotPNG(), option shiny.useragg).
shiny_has_useragg <- function() isTRUE(tryCatch(utils::packageVersion("shiny") >= "1.7.2", error = function(e) FALSE))

# What a server that can draw none of the three is told.
CHART_DEVICE_NONE <- paste("This server cannot draw charts: it has none of the ragg package, R's cairo graphics and the svglite package.",
                           "Ask whoever runs the server to install ragg.")

# The device chart_device() will open: "ragg", "cairo", "svglite" or "none".
chart_device_kind <- function() {
  if (ragg_installed()) "ragg"
  else if (cairo_available()) "cairo"
  else if (svglite_installed()) "svglite"
  else "none"
}

# The file ending and media type of what the device writes: a PNG, except from svglite.
chart_device_ext <- function(kind = chart_device_kind()) if (identical(kind, "svglite")) ".svg" else ".png"
chart_device_type <- function(kind = chart_device_kind()) if (identical(kind, "svglite")) "image/svg+xml" else "image/png"

# Opens the device that writes `file`, `width` by `height` inches at `dpi` pixels per inch (svglite draws vectors,
#   so it takes no dpi), and returns its kind, invisibly. The caller closes it (dev.off()). With none of the
#   three it stops with CHART_DEVICE_NONE, as a sentence and not a failure inside a graphics package. `kind` is the device
#   chart_device_kind() names unless a caller asks for one (the dashboard export asks for svglite to write each chart's SVG).
chart_device <- function(file, width, height, dpi, kind = chart_device_kind()) {
  w = round(width * dpi)
  h = round(height * dpi)
  switch(kind,
         ragg = ragg::agg_png(file, width = w, height = h, units = "px", res = dpi),
         cairo = grDevices::png(file, width = w, height = h, units = "px", res = dpi, type = "cairo"),
         svglite = svglite::svglite(file, width = width, height = height),
         stop(CHART_DEVICE_NONE, call. = FALSE))
  invisible(kind)
}

# Whether the typefaces registered with systemfonts reach the picture: ragg reads them from systemfonts. Base R's cairo device
#   asks the operating system, which does not know the bundled files. svglite measures the text with them but writes only the
#   family name into the SVG, and a browser showing that picture has no such font.
chart_device_uses_bundled_fonts <- function(kind = chart_device_kind()) identical(kind, "ragg")

# The options a stray graphics call needs so that it cannot reach X11: bitmapType "cairo" when R has cairo (the
#   type png() and jpeg() use when none is given, as the charts' own drawing does), and shiny.useragg TRUE when the
#   installed shiny has it. Called once from app.R; returns what it set, invisibly.
chart_device_options <- function() {
  set = list()
  if (cairo_available()) set$bitmapType = "cairo"
  if (shiny_has_useragg()) set$shiny.useragg = TRUE
  if (length(set)) options(set)
  invisible(set)
}


# ---- styles ----------------------------------------------------------------------------------------

# A style is one named set of values; a dashboard has one (Style dialog), the model never names it.
#   label, note             what the Style dialog calls it and says of it
#   background, panel       the plot's and the panel's fill
#   text, text_2, caption   the title and legend text; axis text, axis titles and subtitle; the caption
#   grid, grid_axes, grid_width   the grid's colour, which lines ("value": the value axis only, as the chart
#                           asks; "both"; "none") and its width
#   axis_line, ticks        the colour of the axis lines and of the ticks (NA: none)
#   title_font, title_weight, title_size, subtitle_font   serif or sans; regular, semibold or bold; size
#                           against the base size; the subtitle's family
#   strip                   the weight of a panel's name
#   rule                    the colour of a thin rule under the title block (NA: none)
#   lift                    the value axis labels sit just above their grid line, not beside it (ggplot2 cannot
#                           put them inside the plot: a negative margin is clamped to zero)
#   grey                    the colour behind a highlight
#   fit, outline, box_fill  a fitted curve; the edge of a histogram bar or heatmap cell (the background);
#                           a box's fill
#   swap                    "lighten" on a dark background: a mark colour under CHART_MARK_CONTRAST on it is
#                           replaced by its own lightened version (chart_lighten()); NA: none
#   A series with no colour column is drawn in the chosen qualitative palette's first colour (or the style's `single`).
#   The Phase 7 checks (tests/smoke.R): text, text_2 and caption against the background 4.5 to 1 or more;
#   the grid below text; `grey` visible against the background but weaker than any palette colour.
CHART_MARK_CONTRAST <- 3
CHART_STYLE_DEFAULT <- "clean"
CHART_STYLES <- list(
  clean = list(label = "Clean", note = "White, a light grid along the value axis, a bold title.",
               background = "#FFFFFF", panel = "#FFFFFF", text = "#1A1A1A", text_2 = "#4D4D4D", caption = "#6B6B6B",
               grid = "#E5E5E5", grid_axes = "value", grid_width = 0.4, axis_line = NA, ticks = NA,
               title_font = "sans", title_weight = "bold", title_size = 1.2, subtitle_font = "sans", strip = "bold",
               rule = NA, lift = FALSE, grey = "#C4C4C4", fit = "#4D4D4D", outline = "#FFFFFF", box_fill = "#F2F2F2", swap = NA,
               accent = "#0A4580", slate = "#8A95A3", single = NA, title_case = NA, axis_size = 1, subtitle_size = 1),
  minimal = list(label = "Minimal", note = "No grid and no axis line; ticks only. The least ink that still reads.",
                 background = "#FFFFFF", panel = "#FFFFFF", text = "#262626", text_2 = "#4D4D4D", caption = "#6B6B6B",
                 grid = "#E5E5E5", grid_axes = "none", grid_width = 0.4, axis_line = NA, ticks = "#4D4D4D",
                 title_font = "sans", title_weight = "semibold", title_size = 1.15, subtitle_font = "sans", strip = "semibold",
                 rule = NA, lift = FALSE, grey = "#C4C4C4", fit = "#4D4D4D", outline = "#FFFFFF", box_fill = "#FFFFFF", swap = NA,
                 accent = "#0A4580", slate = "#8A95A3", single = NA, title_case = NA, axis_size = 1, subtitle_size = 1),
  magazine = list(label = "Magazine", note = "A pale tint, a white grid, a heavy title.",
                  background = "#E6EDF2", panel = "#E6EDF2", text = "#14202B", text_2 = "#38464F", caption = "#4F5D66",
                  grid = "#FFFFFF", grid_axes = "value", grid_width = 0.7, axis_line = NA, ticks = NA,
                  title_font = "sans", title_weight = "bold", title_size = 1.5, subtitle_font = "sans", strip = "bold",
                  rule = NA, lift = TRUE, grey = "#B5C0C9", fit = "#2B3A45", outline = "#E6EDF2", box_fill = "#F7FAFC", swap = NA,
                  accent = "#0A3668", slate = "#7A8794", single = NA, title_case = NA, axis_size = 1, subtitle_size = 1),
  desk = list(label = "Data desk", note = "Light grey, a darker grid both ways, a large bold title.",
              background = "#EBEBEB", panel = "#EBEBEB", text = "#111111", text_2 = "#333333", caption = "#4A4A4A",
              grid = "#C2C2C2", grid_axes = "both", grid_width = 0.4, axis_line = NA, ticks = NA,
              title_font = "sans", title_weight = "bold", title_size = 1.6, subtitle_font = "sans", strip = "bold",
              rule = NA, lift = FALSE, grey = "#BDBDBD", fit = "#333333", outline = "#EBEBEB", box_fill = "#F7F7F7", swap = NA,
              accent = "#0A3668", slate = "#7C8590", single = NA, title_case = NA, axis_size = 1, subtitle_size = 1),
  newspaper = list(label = "Newspaper", note = "White, a serif title, a thin black rule under the title block, a hairline grid.",
                   background = "#FFFFFF", panel = "#FFFFFF", text = "#111111", text_2 = "#404040", caption = "#595959",
                   grid = "#D9D9D9", grid_axes = "value", grid_width = 0.2, axis_line = NA, ticks = NA,
                   title_font = "serif", title_weight = "bold", title_size = 1.35, subtitle_font = "serif", strip = "bold",
                   rule = "#000000", lift = FALSE, grey = "#C4C4C4", fit = "#404040", outline = "#FFFFFF", box_fill = "#F2F2F2", swap = NA,
                   accent = "#0A4580", slate = "#8A95A3", single = NA, title_case = NA, axis_size = 1, subtitle_size = 1),
  dark = list(label = "Dark", note = "Near-black, light text, a muted grid.",
              background = "#14171C", panel = "#14171C", text = "#ECEFF2", text_2 = "#B9C0C8", caption = "#9AA3AD",
              grid = "#303640", grid_axes = "value", grid_width = 0.4, axis_line = NA, ticks = NA,
              title_font = "sans", title_weight = "bold", title_size = 1.2, subtitle_font = "sans", strip = "bold",
              rule = NA, lift = FALSE, grey = "#565E68", fit = "#C8CED6", outline = "#14171C", box_fill = "#232932", swap = "lighten",
              accent = "#9ACBFF", slate = "#5F6B79", single = NA, title_case = NA, axis_size = 1, subtitle_size = 1),
  briefing = list(label = "Briefing", note = "Off-white, a hairline grid across the chart, condensed upper-case titles, one deep blue and slate greys.",
                  background = "#F7F6F2", panel = "#F7F6F2", text = "#1C2431", text_2 = "#5B6470", caption = "#656D78",
                  grid = "#D9D8D2", grid_axes = "horizontal", grid_width = 0.25, axis_line = NA, ticks = NA,
                  title_font = "display", title_weight = "bold", title_size = 1.55, subtitle_font = "sans", strip = "bold",
                  rule = NA, lift = FALSE, grey = "#C9CED6", fit = "#3B4656", outline = "#F7F6F2", box_fill = "#FFFFFF", swap = NA,
                  accent = "#173A75", slate = "#7F8A99", single = "#173A75", title_case = "upper", axis_size = 0.9, subtitle_size = 0.85))

# The style of that name; an error for one that is not there.
chart_style <- function(name = CHART_STYLE_DEFAULT) {
  s = CHART_STYLES[[name %||% CHART_STYLE_DEFAULT]]
  if (is.null(s)) stop("There is no style '", name, "'.", call. = FALSE)
  s
}

# Upper case for a title (the style's `title_case`, Phase 10 Part D), by words: the text is cut at its spaces and every word is
#   upper-cased except one that holds a digit ("2024", "34%", "Q3"), one that holds a superscript 2 or 3, a micro sign or a degree sign, a unit from CHART_CASE_UNITS
#   (as written, lower case: "kg", "km/h", "kWh" keeps its capitals) and one with a capital after a lower-case letter inside it
#   ("kWh", "GHz", "iPhone": a unit or a name whose case carries meaning). The stored text is not changed; this is what is drawn.
CHART_CASE_UNITS <- c("kg", "g", "mg", "lb", "lbs", "oz", "km", "m", "cm", "mm", "mi", "ft", "ml", "l", "dl", "mph", "kph", "hz", "khz", "mhz",
                      "ghz", "kb", "mb", "gb", "tb", "kw", "kwh", "mw", "mwh", "gw", "gwh", "kv", "kcal", "km/h", "m/s")

# The pieces of a text, words and the spaces between them, with whether each keeps its case: data frame(text, keep).
chart_case_tokens <- function(text) {
  pieces = regmatches(text, gregexpr("\\S+|\\s+", text))[[1]]
  keeps = function(p) {
    core = gsub("^[^[:alnum:]/]+|[^[:alnum:]/]+$", "", p)
    grepl("[0-9]", p) || grepl(paste0("[", intToUtf8(c(178L, 179L, 181L, 176L)), "]"), p) || core %in% CHART_CASE_UNITS || grepl("[[:lower:]][[:upper:]]", core)
  }
  data.frame(text = pieces, keep = vapply(pieces, function(p) !grepl("^\\s+$", p) && keeps(p), logical(1), USE.NAMES = FALSE) | grepl("^\\s+$", pieces),
             stringsAsFactors = FALSE, row.names = NULL)
}

# A text as a heading shows it (Phase 10b): one trailing full stop is dropped, since a stop reads oddly after a heading, in capitals above all. The
#   stored text is never changed; this is only what is shown (a page's card heading, the canvas heading, the title drawn on a chart). Only a
#   single stop goes: not the last two of an ellipsis ("..."), not an abbreviation (a letter and a stop twice over, "e.g." and "U.S.", or one of
#   CHART_STOP_KEEP: "etc.", "vs."), and a number with a decimal point has no stop at its end to lose. A text that is not one string is returned as it is.
CHART_STOP_KEEP <- c("etc", "vs", "inc", "ltd", "approx", "cf", "al")
chart_heading_text <- function(text) {
  if (!is.character(text) || length(text) != 1L || is.na(text)) return(text)
  t = trimws(text, which = "right")
  if (!grepl("[.]$", t) || grepl("[.][.]$|[.][[:space:]]*[.]$", t) || grepl("(^|[^[:alpha:]])[[:alpha:]][.][[:alpha:]][.]$", t)) return(text)
  last = tolower(sub("^.*[[:space:](]", "", t))
  if (sub("[.]$", "", last) %in% CHART_STOP_KEEP) return(text)
  trimws(sub("[.]$", "", t), which = "right")
}

# A title as a style draws it: upper case where its title_case says "upper" (words that keep their case keep it, see
#   chart_case_tokens()), as written otherwise; a text that is not one string (NULL, NA) is returned as it is.
chart_title_case <- function(text, style = CHART_STYLE_DEFAULT) {
  if (!identical(chart_style(style)$title_case, "upper") || !is.character(text) || length(text) != 1L || is.na(text) || !nzchar(text)) return(text)
  tk = chart_case_tokens(text)
  paste(ifelse(tk$keep, tk$text, toupper(tk$text)), collapse = "")
}

# WCAG contrast ratio of two colours (vectorised over the first), from relative luminance.
chart_contrast <- function(a, b) {
  lum = function(x) {
    v = grDevices::col2rgb(x) / 255
    colSums(c(0.2126, 0.7152, 0.0722) * ifelse(v <= 0.04045, v / 12.92, ((v + 0.055) / 1.055)^2.4))
  }
  la = lum(a); lb = lum(b)
  (pmax(la, lb) + 0.05) / (pmin(la, lb) + 0.05)
}

# A colour made light enough: `col` with its CIELCh lightness raised (hue and chroma kept as far as the sRGB
#   gamut allows, the chroma lowered only when it must be) until its contrast with `background` reaches
#   `target` (farver: decode_colour(to = "lch"), encode_colour(from = "lch"); encode_colour clamps a colour
#   outside the gamut, so one is in the gamut when it decodes to the lightness and chroma it was made from).
#   A colour that already reaches the target is returned as it is.
chart_lighten <- function(col, background, target = CHART_MARK_CONTRAST) {
  if (chart_contrast(col, background) >= target) return(col)
  lch = farver::decode_colour(col, to = "lch")
  grid = expand.grid(l = seq(lch[1, "l"], 100, by = 0.5), k = seq(1, 0, by = -0.05))
  m = cbind(l = grid$l, c = lch[1, "c"] * grid$k, h = lch[1, "h"])
  hex = farver::encode_colour(m, from = "lch")
  back = farver::decode_colour(hex, to = "lch")
  ok = abs(back[, "l"] - m[, "l"]) < 1 & abs(back[, "c"] - m[, "c"]) < 1 & chart_contrast(hex, background) >= target
  if (!any(ok)) return(farver::encode_colour(cbind(l = 100, c = 0, h = 0), from = "lch"))
  hex[[which(ok)[order(grid$l[ok], -grid$k[ok])][1]]]
}

# Mark colours as a style can show them: on a style with a `swap`, each colour whose contrast with the
#   background is under CHART_MARK_CONTRAST (Okabe-Ito's black on Dark) is replaced by its own lightened
#   version (chart_lighten()), so no colour is lost and no two colours become one.
style_marks <- function(cols, style = CHART_STYLE_DEFAULT) {
  st = chart_style(style)
  if (is.na(st$swap)) return(cols)
  vapply(cols, chart_lighten, character(1), background = st$background, USE.NAMES = FALSE)
}

# A colour that cannot be seen is not drawn: a palette colour under CHART_VISIBLE_DE (CIE2000 difference,
#   farver) from a style's background (Stata's #FFFFFF and Moth's #F0F0E4 on white) is skipped, and the
#   palette's usable count for that style drops by one. The rules combine in this order: the swap first (on
#   Dark a colour under 3 to 1 is replaced by its own lightened version, so it is kept, not skipped); then the
#   skip for any colour still under CHART_VISIBLE_DE from the background; then, on a style with a swap, the skip
#   of any colour under CHART_VISIBLE_DE from an earlier colour kept (after the swap two colours may have
#   become nearly one, and two groups must not share one).
CHART_VISIBLE_DE <- 10

# CIE2000 colour difference of each colour in `a` from the colour `b`.
chart_colour_distance <- function(a, b)
  as.numeric(farver::compare_colour(farver::decode_colour(a), farver::decode_colour(b), from_space = "rgb", method = "cie2000"))

# Viridis, written out (viridisLite::viridis(7)) so the default needs no package.
CHART_SEQUENTIAL <- c("#440154", "#443A83", "#31688E", "#21908C", "#35B779", "#8FD744", "#FDE725")

# How many colours a continuous palette is drawn with, sequential and diverging (odd, so a
#   diverging palette has a centre colour).
CHART_CONTINUOUS_N <- c(sequential = 7L, diverging = 11L)

# The palettes an analyst may choose from. Each entry has a label, a source (the select groups by
#   it), a kind (qualitative, sequential or diverging), and either `colours` (hex, needing nothing:
#   an office palette goes here) or `paletteer` (the name as paletteer takes it); a qualitative one
#   also `max`, how many groups it can show. Every paletteer name below is in the installed
#   paletteer's tables (1.7.0); paletteer holds a discrete palette's colours itself, so the source
#   package need not be installed, while a continuous one (viridis, ggthemes' continuous sets) needs
#   its package. Okabe-Ito is the grDevices::palette.colors() set with grey left out (a highlight's
#   background) and yellow last (hard to see on white, used only with eight groups). Blue-red is
#   grDevices::hcl.colors(11, "Blue-Red 2"), the fallback diverging palette without paletteer. The
#   Phase 6b additions pass the colour-vision check (CHART_CVD_MARK) and, for a qualitative palette,
#   serve at least five groups under it.
CHART_PALETTES <- list(
  okabe_ito = list(label = "Okabe-Ito", source = "Built in", kind = "qualitative", max = 8L, single = "#0072B2",
                   colours = c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7", "#000000", "#F0E442")),
  tol_bright = list(label = "Paul Tol bright", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 7L, paletteer = "khroma::bright"),
  tol_muted = list(label = "Paul Tol muted", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 9L, paletteer = "khroma::muted"),
  tol_vibrant = list(label = "Paul Tol vibrant", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 7L, paletteer = "khroma::vibrant"),
  khro_mediumcontrast = list(label = "Paul Tol medium contrast", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 6L, paletteer = "khroma::mediumcontrast"),
  ggth_classic_color_blind = list(label = "Tableau Classic Color Blind", source = "ggthemes", kind = "qualitative", max = 10L, paletteer = "ggthemes::Classic_Color_Blind"),
  ggth_stata_economist = list(label = "Stata blue-grey", source = "ggthemes", kind = "qualitative", max = 15L, paletteer = "ggthemes::stata_economist"),
  ggth_excel_office_theme = list(label = "Excel Office Theme", source = "ggthemes", kind = "qualitative", max = 6L, paletteer = "ggthemes::excel_Office_Theme"),
  metb_archambault = list(label = "Archambault", source = "MetBrewer", kind = "qualitative", max = 7L, paletteer = "MetBrewer::Archambault"),
  metb_veronese = list(label = "Veronese", source = "MetBrewer", kind = "qualitative", max = 7L, paletteer = "MetBrewer::Veronese"),
  metb_johnson = list(label = "Johnson", source = "MetBrewer", kind = "qualitative", max = 5L, paletteer = "MetBrewer::Johnson"),
  metb_isfahan1 = list(label = "Isfahan1", source = "MetBrewer", kind = "qualitative", max = 8L, paletteer = "MetBrewer::Isfahan1"),
  metb_cassatt2 = list(label = "Cassatt2", source = "MetBrewer", kind = "qualitative", max = 10L, paletteer = "MetBrewer::Cassatt2"),
  metb_moreau = list(label = "Moreau", source = "MetBrewer", kind = "qualitative", max = 7L, paletteer = "MetBrewer::Moreau"),
  metb_renoir = list(label = "Renoir", source = "MetBrewer", kind = "qualitative", max = 12L, paletteer = "MetBrewer::Renoir"),
  metb_tsimshian = list(label = "Tsimshian", source = "MetBrewer", kind = "qualitative", max = 7L, paletteer = "MetBrewer::Tsimshian"),
  metb_lakota = list(label = "Lakota", source = "MetBrewer", kind = "qualitative", max = 6L, paletteer = "MetBrewer::Lakota"),
  metb_klimt = list(label = "Klimt", source = "MetBrewer", kind = "qualitative", max = 6L, paletteer = "MetBrewer::Klimt"),
  natp_kingscanyon = list(label = "Kings Canyon", source = "NatParksPalettes", kind = "qualitative", max = 6L, paletteer = "NatParksPalettes::KingsCanyon"),
  natp_deathvalley = list(label = "Death Valley", source = "NatParksPalettes", kind = "qualitative", max = 7L, paletteer = "NatParksPalettes::DeathValley"),
  natp_torres = list(label = "Torres", source = "NatParksPalettes", kind = "qualitative", max = 10L, paletteer = "NatParksPalettes::Torres"),
  nord_algoma_forest = list(label = "Algoma Forest", source = "nord", kind = "qualitative", max = 7L, paletteer = "nord::algoma_forest"),
  nord_moose_pond = list(label = "Moose Pond", source = "nord", kind = "qualitative", max = 8L, paletteer = "nord::moose_pond"),
  pnwc_moth = list(label = "Moth", source = "PNWColors", kind = "qualitative", max = 5L, paletteer = "PNWColors::Moth"),
  pnwc_bay = list(label = "Bay", source = "PNWColors", kind = "qualitative", max = 5L, paletteer = "PNWColors::Bay"),
  rcar_safe = list(label = "Safe", source = "CARTOColors", kind = "qualitative", max = 12L, paletteer = "rcartocolor::Safe"),
  wesa_darjeeling2 = list(label = "Darjeeling 2", source = "wesanderson", kind = "qualitative", max = 5L, paletteer = "wesanderson::Darjeeling2"),
  wesa_isleofdogs1 = list(label = "Isle of Dogs 1", source = "wesanderson", kind = "qualitative", max = 6L, paletteer = "wesanderson::IsleofDogs1"),
  wesa_isleofdogs2 = list(label = "Isle of Dogs 2", source = "wesanderson", kind = "qualitative", max = 5L, paletteer = "wesanderson::IsleofDogs2"),
  viridis = list(label = "Viridis", source = "viridis", kind = "sequential", colours = CHART_SEQUENTIAL),
  magma = list(label = "Magma", source = "viridis", kind = "sequential", paletteer = "viridis::magma"),
  cividis = list(label = "Cividis", source = "viridis", kind = "sequential", paletteer = "viridis::cividis"),
  mako = list(label = "Mako", source = "viridis", kind = "sequential", paletteer = "viridis::mako"),
  blues = list(label = "ColorBrewer Blues", source = "ColorBrewer", kind = "sequential", paletteer = "RColorBrewer::Blues"),
  ylgnbu = list(label = "ColorBrewer YlGnBu", source = "ColorBrewer", kind = "sequential", paletteer = "RColorBrewer::YlGnBu"),
  khro_smoothrainbow = list(label = "Paul Tol smooth rainbow", source = "khroma (Paul Tol, Crameri)", kind = "sequential", paletteer = "khroma::smoothrainbow"),
  khro_oslo = list(label = "Crameri Oslo", source = "khroma (Paul Tol, Crameri)", kind = "sequential", paletteer = "khroma::oslo"),
  khro_grayc = list(label = "Crameri grayC", source = "khroma (Paul Tol, Crameri)", kind = "sequential", paletteer = "khroma::grayC"),
  ggth_classic_blue = list(label = "Tableau Classic Blue", source = "ggthemes", kind = "sequential", paletteer = "ggthemes::Classic Blue"),
  ggth_gray_warm = list(label = "Tableau Gray Warm", source = "ggthemes", kind = "sequential", paletteer = "ggthemes::Gray Warm"),
  ggth_classic_gray = list(label = "Tableau Classic Gray", source = "ggthemes", kind = "sequential", paletteer = "ggthemes::Classic Gray"),
  nord_halifax_harbor = list(label = "Halifax Harbor", source = "nord", kind = "sequential", paletteer = "nord::halifax_harbor"),
  pnwc_lake = list(label = "Lake", source = "PNWColors", kind = "sequential", paletteer = "PNWColors::Lake"),
  pnwc_mushroom = list(label = "Mushroom", source = "PNWColors", kind = "sequential", paletteer = "PNWColors::Mushroom"),
  pnwc_winter = list(label = "Winter", source = "PNWColors", kind = "sequential", paletteer = "PNWColors::Winter"),
  rcar_darkmint = list(label = "DarkMint", source = "CARTOColors", kind = "sequential", paletteer = "rcartocolor::DarkMint"),
  rcar_brwnyl = list(label = "BrwnYl", source = "CARTOColors", kind = "sequential", paletteer = "rcartocolor::BrwnYl"),
  rcar_bluyl = list(label = "BluYl", source = "CARTOColors", kind = "sequential", paletteer = "rcartocolor::BluYl"),
  # MetBrewer records no kind for its palettes (paletteer's table lists all 56 as qualitative). The kind of the
  #   sequential and diverging MetBrewer palettes below is OURS, by the lightness rule (see m7_kind() in
  #   tests/smoke.R): CIELAB lightness of the colours in MetBrewer's stored order moves one way (at most one
  #   step of under 3 units back) for a sequential one; for a diverging one it has a single extreme that is the
  #   middle colour (odd length) or one of the two middle colours (even length), the two end colours within 20
  #   lightness units of each other (so that equal distances from a heatmap's midpoint look equal), and the ends
  #   more than 60 degrees apart in hue; each is offered only if, drawn as a ramp, it reaches the colour-vision
  #   mark. It is not MetBrewer's classification.
  # Every palette, of every source, is judged on the colours as drawn: the CHART_CONTINUOUS_N colours (11 for a
  #   diverging one) that chart_diverging() hands to the chart, not on the longer list a package stores (Crameri's
  #   have 256), because those are what the reader sees. ColorBrewer PuOr is not offered as a diverging palette:
  #   its two ends are 23.7 lightness units apart, over the balanced rule's 20 (a-007).
  metb_hokusai2_seq = list(label = "Hokusai2", source = "MetBrewer", kind = "sequential", paletteer = "MetBrewer::Hokusai2"),
  metb_hokusai3_seq = list(label = "Hokusai3", source = "MetBrewer", kind = "sequential", paletteer = "MetBrewer::Hokusai3"),
  metb_tam_seq = list(label = "Tam", source = "MetBrewer", kind = "sequential", paletteer = "MetBrewer::Tam"),
  metb_vangogh3_seq = list(label = "VanGogh3", source = "MetBrewer", kind = "sequential", paletteer = "MetBrewer::VanGogh3"),
  rdbu = list(label = "ColorBrewer RdBu", source = "ColorBrewer", kind = "diverging", paletteer = "RColorBrewer::RdBu"),
  brbg = list(label = "ColorBrewer BrBG", source = "ColorBrewer", kind = "diverging", paletteer = "RColorBrewer::BrBG"),
  sunset = list(label = "Paul Tol sunset", source = "khroma (Paul Tol, Crameri)", kind = "diverging", paletteer = "khroma::sunset"),
  khro_vanimo = list(label = "Crameri Vanimo", source = "khroma (Paul Tol, Crameri)", kind = "diverging", paletteer = "khroma::vanimo"),
  khro_vik = list(label = "Crameri Vik", source = "khroma (Paul Tol, Crameri)", kind = "diverging", paletteer = "khroma::vik"),
  khro_bam = list(label = "Crameri Bam", source = "khroma (Paul Tol, Crameri)", kind = "diverging", paletteer = "khroma::bam"),
  ggth_red_blue_white = list(label = "Tableau Red-Blue-White", source = "ggthemes", kind = "diverging", paletteer = "ggthemes::Red-Blue-White Diverging"),
  ggth_orange_blue_white = list(label = "Tableau Orange-Blue-White", source = "ggthemes", kind = "diverging", paletteer = "ggthemes::Orange-Blue-White Diverging"),
  ggth_classic_orange_white_blue = list(label = "Tableau Classic Orange-White-Blue", source = "ggthemes", kind = "diverging", paletteer = "ggthemes::Classic Orange-White-Blue"),
  nord_silver_mine = list(label = "Silver Mine", source = "nord", kind = "diverging", paletteer = "nord::silver_mine"),
  pnwc_shuksan2 = list(label = "Shuksan 2", source = "PNWColors", kind = "diverging", paletteer = "PNWColors::Shuksan2"),
  pnwc_anemone = list(label = "Anemone", source = "PNWColors", kind = "diverging", paletteer = "PNWColors::Anemone"),
  rcar_earth = list(label = "Earth", source = "CARTOColors", kind = "diverging", paletteer = "rcartocolor::Earth"),
  rcar_armyrose = list(label = "ArmyRose", source = "CARTOColors", kind = "diverging", paletteer = "rcartocolor::ArmyRose"),
  rcar_geyser = list(label = "Geyser", source = "CARTOColors", kind = "diverging", paletteer = "rcartocolor::Geyser"),
  metb_benedictus_div = list(label = "Benedictus", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Benedictus"),
  metb_cassatt1_div = list(label = "Cassatt1", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Cassatt1"),
  metb_cassatt2_div = list(label = "Cassatt2", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Cassatt2"),
  metb_demuth_div = list(label = "Demuth", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Demuth"),
  metb_ingres_div = list(label = "Ingres", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Ingres"),
  metb_isfahan1_div = list(label = "Isfahan1", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Isfahan1"),
  metb_johnson_div = list(label = "Johnson", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Johnson"),
  metb_juarez_div = list(label = "Juarez", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Juarez"),
  metb_moreau_div = list(label = "Moreau", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Moreau"),
  metb_okeeffe1_div = list(label = "OKeeffe1", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::OKeeffe1"),
  metb_troy_div = list(label = "Troy", source = "MetBrewer", kind = "diverging", paletteer = "MetBrewer::Troy"),
  blue_red = list(label = "Blue-red", source = "Built in", kind = "diverging",
                  colours = c("#4A6FE3", "#7086E1", "#8F9DE1", "#ABB4E2", "#C7CBE3", "#E2E2E2", "#E6C4C9", "#E5A5B1",
                              "#E28699", "#DB6581", "#D33F6A")))

# The colour-vision check (Phase 6b): the smallest CIE2000 difference between any two of a palette's
#   first CHART_CVD_N colours (a sequential or diverging palette: CHART_CVD_N colours spread along
#   it, as charts draw it) after simulating deuteranopia, protanopia and tritanopia, the worst of
#   the three. A palette passes at CHART_CVD_MARK or more: the mark Kevin approved on 2026-11-20, the
#   highest round number that the four palettes chosen first for colour-vision deficiency pass.
CHART_CVD_N <- 5L
CHART_CVD_MARK <- 8

# The check's result for each palette, written out so the app needs neither colorspace nor
#   paletteer to show the marks; tests/smoke.R recomputes every one with palette_cvd().
CHART_PALETTE_CVD <- c(okabe_ito = 12.1, tol_bright = 8.7, tol_muted = 17.7, tol_vibrant = 8.6,
  khro_mediumcontrast = 12.1, ggth_classic_color_blind = 16.9, ggth_stata_economist = 13.7,
  ggth_excel_office_theme = 12.2, metb_archambault = 15.7, metb_veronese = 15.6,
  metb_johnson = 14.6, natp_kingscanyon = 21.7, natp_deathvalley = 15.8, natp_torres = 15.3,
  nord_algoma_forest = 9.4, nord_moose_pond = 8.6, pnwc_moth = 13.2, pnwc_bay = 11.6,
  rcar_safe = 17.7, wesa_darjeeling2 = 13.9, wesa_isleofdogs1 = 12.2, wesa_isleofdogs2 = 8.4,
  viridis = 13.4, magma = 14.2, cividis = 13.0, mako = 13.9, blues = 9.9, ylgnbu = 7.0,
  khro_smoothrainbow = 17.0, khro_oslo = 19.4, khro_grayc = 18.4, ggth_classic_blue = 11.1,
  ggth_gray_warm = 11.0, ggth_classic_gray = 10.5, nord_halifax_harbor = 8.3, pnwc_lake = 13.5,
  pnwc_mushroom = 12.6, pnwc_winter = 11.9, rcar_darkmint = 12.9, rcar_brwnyl = 12.0,
  rcar_bluyl = 11.2, rdbu = 22.9, brbg = 13.7, sunset = 18.7, khro_vanimo = 27.9,
  khro_vik = 28.2, khro_bam = 24.1, ggth_red_blue_white = 25.2, ggth_orange_blue_white = 25.1,
  ggth_classic_orange_white_blue = 23.5, nord_silver_mine = 8.5, pnwc_shuksan2 = 15.0,
  pnwc_anemone = 8.3, rcar_earth = 15.2, rcar_armyrose = 12.5, rcar_geyser = 11.4, blue_red = 13.9,
  metb_isfahan1 = 13.3, metb_cassatt2 = 12.0, metb_moreau = 10.7, metb_renoir = 10.6, metb_tsimshian = 10.0, metb_lakota = 9.9, metb_klimt = 9.7, metb_benedictus_div = 15.8, metb_cassatt1_div = 15.9, metb_cassatt2_div = 18.4, metb_demuth_div = 21.0, metb_hokusai2_seq = 10.5, metb_hokusai3_seq = 9.0, metb_ingres_div = 15.5, metb_isfahan1_div = 19.7, metb_johnson_div = 14.6, metb_juarez_div = 9.1, metb_moreau_div = 17.4, metb_okeeffe1_div = 28.1, metb_tam_seq = 10.8, metb_troy_div = 12.2, metb_vangogh3_seq = 11.9)

# The same check for every number of colours a qualitative palette can show, 2 to its `max`: element
#   n - 1 is the result for the first n colours (read it with palette_cvd_at()). The value at n =
#   CHART_CVD_N is the one in CHART_PALETTE_CVD; tests/smoke.R recomputes every one with palette_cvd().
#   A sequential or diverging palette is drawn with CHART_CONTINUOUS_N colours spread along it and
#   keeps its one result above.
CHART_PALETTE_CVD_N <- list(
  okabe_ito = c(50.6, 12.2, 12.1, 12.1, 11.1, 11.1, 11.1),
  tol_bright = c(24.9, 8.7, 8.7, 8.7, 8.7, 8.7),
  tol_muted = c(33.6, 22.6, 17.7, 17.7, 11.8, 11.8, 11.8, 11.6),
  tol_vibrant = c(50.3, 19.5, 8.6, 8.6, 8.6, 8.6),
  khro_mediumcontrast = c(12.1, 12.1, 12.1, 12.1, 12.1),
  ggth_classic_color_blind = c(52.6, 27.4, 20.9, 16.9, 12.4, 10.8, 10.8, 10.8, 9.4),
  ggth_stata_economist = c(29.0, 13.7, 13.7, 13.7, 9.1, 5.0, 5.0, 5.0, 5.0, 5.0, 4.6, 4.1, 3.2, 3.2),
  ggth_excel_office_theme = c(53.0, 25.6, 12.7, 12.2, 6.2),
  metb_archambault = c(42.2, 15.7, 15.7, 15.7, 7.1, 7.1),
  metb_veronese = c(15.6, 15.6, 15.6, 15.6, 8.0, 8.0),
  metb_johnson = c(14.6, 14.6, 14.6, 14.6),
  natp_kingscanyon = c(22.0, 21.7, 21.7, 21.7, 16.8),
  natp_deathvalley = c(19.7, 18.6, 18.6, 15.8, 15.0, 11.0),
  natp_torres = c(30.0, 30.0, 29.0, 15.3, 9.0, 4.1, 4.1, 4.1, 2.1),
  nord_algoma_forest = c(25.7, 13.8, 11.4, 9.4, 9.4, 7.6),
  nord_moose_pond = c(13.4, 8.6, 8.6, 8.6, 4.3, 4.3, 4.3),
  pnwc_moth = c(13.5, 13.5, 13.5, 13.2),
  pnwc_bay = c(18.5, 18.5, 11.6, 11.6),
  rcar_safe = c(29.2, 22.6, 17.7, 17.7, 11.6, 11.6, 11.6, 11.6, 11.5, 6.0, 5.3),
  wesa_darjeeling2 = c(44.9, 13.9, 13.9, 13.9),
  wesa_isleofdogs1 = c(30.0, 16.5, 16.5, 12.2, 4.5),
  wesa_isleofdogs2 = c(16.9, 10.7, 10.7, 8.4),
  metb_isfahan1 = c(13.3, 13.3, 13.3, 13.3, 12.6, 12.6, 7.9),
  metb_cassatt2 = c(12.8, 12.8, 12.2, 12.0, 12.0, 12.0, 12.0, 11.1, 10.6),
  metb_moreau = c(10.7, 10.7, 10.7, 10.7, 10.7, 9.6),
  metb_renoir = c(10.6, 10.6, 10.6, 10.6, 10.6, 10.6, 10.6, 5.4, 4.4, 2.9, 1.4),
  metb_tsimshian = c(12.4, 12.4, 10.3, 10.0, 8.9, 8.9),
  metb_lakota = c(44.9, 41.3, 13.3, 9.9, 9.9),
  metb_klimt = c(27.4, 11.5, 9.7, 9.7, 2.1))

# The stored check of the first n colours of a qualitative palette; NA when n is outside 2 to its max
#   or the palette has no stored result.
palette_cvd_at <- function(name, n) {
  v = CHART_PALETTE_CVD_N[[name]]
  if (is.null(v) || n < 2L || n > length(v) + 1L) NA_real_ else v[[n - 1L]]
}

# Whether paletteer is installed (find.package(), since R/ loads no namespace at start-up). One
#   function, so a test can stand in for a machine without it.
paletteer_installed <- function() length(find.package("paletteer", quiet = TRUE)) > 0L

# A palette's colours as #RRGGBB: its own, or paletteer's. paletteer holds a discrete palette's
#   colours itself; a continuous one is drawn by its source package (viridisLite for the
#   viridis family), so it is available only when that package is installed.
palette_colours <- function(name, n = NULL) {
  e = CHART_PALETTES[[name]]
  if (is.null(e)) stop("There is no palette '", name, "'.", call. = FALSE)
  if (!is.null(e$colours)) return(e$colours)
  if (!paletteer_installed()) stop("The palette ", e$label, " needs the paletteer package, which is not installed.", call. = FALSE)
  d = paletteer::palettes_d_names
  discrete = e$paletteer %in% paste0(d$package, "::", d$palette)
  cols = if (discrete) paletteer::paletteer_d(e$paletteer)
         else paletteer::paletteer_c(e$paletteer, n %||% CHART_CONTINUOUS_N[[e$kind]])
  cols = toupper(substr(as.character(cols), 1, 7))
  # A long discrete scale (Crameri's have 256 colours) drawn as a continuous one keeps n of them,
  #   evenly spaced, so the written code stays short.
  if (!identical(e$kind, "qualitative") && !is.null(n) && length(cols) > n) cols = cols[unique(round(seq(1, length(cols), length.out = n)))]
  cols
}

palette_available <- function(name) isTRUE(tryCatch(length(palette_colours(name)) > 0L, error = function(e) FALSE))

# The three palettes and the style a report starts with. At work, this is the function to change.
chart_palette_default <- function()
  list(qualitative = "okabe_ito", sequential = "viridis",
       diverging = if (palette_available("rdbu")) "rdbu" else "blue_red", style = CHART_STYLE_DEFAULT)

# The palettes on offer for a kind, as c(name = label), the default first.
chart_palettes <- function(kind) {
  names_k = names(Filter(function(e) identical(e$kind, kind), CHART_PALETTES))
  on_offer = names_k[vapply(names_k, palette_available, logical(1))]
  first = chart_palette_default()[[kind]]
  ordered = c(intersect(first, on_offer), setdiff(on_offer, first))
  stats::setNames(vapply(ordered, function(k) CHART_PALETTES[[k]]$label, character(1)), ordered)
}

# The palettes on offer for a kind, grouped by source for a select: list(source = c(label = name)),
#   the default's group first and the default first in it. A palette that passes the colour-vision
#   check carries the mark CHART_CVD_TICK after its label.
CHART_CVD_TICK <- " \u2713"
palette_passes <- function(name) isTRUE(CHART_PALETTE_CVD[name] >= CHART_CVD_MARK)
chart_palette_groups <- function(kind) {
  on_offer = names(chart_palettes(kind))
  label = function(k) paste0(CHART_PALETTES[[k]]$label, if (palette_passes(k)) CHART_CVD_TICK else "")
  src = vapply(on_offer, function(k) CHART_PALETTES[[k]]$source, character(1))
  groups = split(on_offer, factor(src, levels = unique(src)))
  lapply(groups, function(ks) stats::setNames(ks, vapply(ks, label, character(1))))
}

# The colour-vision check of a set of colours: the smallest CIE2000 difference between two of them
#   under simulated deuteranopia, protanopia and tritanopia (colorspace::deutan(), protan(),
#   tritan(); farver::compare_colour(method = "cie2000")), the worst of the three; NA when
#   colorspace is not installed.
cvd_gap <- function(cols) {
  if (!length(find.package("colorspace", quiet = TRUE)) || length(cols) < 2L) return(NA_real_)
  one = function(x) {
    m = farver::compare_colour(farver::decode_colour(x), from_space = "rgb", method = "cie2000")
    min(m[upper.tri(m)])
  }
  min(one(colorspace::deutan(cols)), one(colorspace::protan(cols)), one(colorspace::tritan(cols)))
}

# The check for a named palette, as charts use it: the first CHART_CVD_N colours of a qualitative
#   palette, CHART_CVD_N spread along a sequential or diverging one. Rounded to one decimal.
palette_cvd <- function(name, n = CHART_CVD_N) {
  e = CHART_PALETTES[[name]]
  cols = palette_colours(name, if (identical(e$kind, "qualitative")) NULL else 11L)
  cols = if (identical(e$kind, "qualitative")) utils::head(cols, n) else grDevices::colorRampPalette(cols)(n)
  round(cvd_gap(cols), 1)
}

# The colours of a qualitative palette that a style shows, in order: the first `max` of them, swapped
#   (style_marks()), without those too near the style's background and, on a style with a swap, without any
#   that is under CHART_VISIBLE_DE from an earlier one kept.
# The colour of a chart with one series (Phase 7b): the palette entry's own `single` when it has one (Okabe-Ito's blue),
#   else its first usable colour; in a style, under the same rule as every colour (style_marks(): lightened on Dark when it is
#   under 3 to 1 on the background).
palette_single <- function(name, style = CHART_STYLE_DEFAULT) {
  # a style that has its own colour for a single series (Briefing: its deep blue) uses it with the default palette; a palette the analyst chose keeps its own
  own_style = chart_style(style)$single
  if (!is.na(own_style) && identical(name, chart_palette_default()$qualitative)) return(own_style)
  own = CHART_PALETTES[[name]]$single
  if (is.null(own)) return(palette_usable(name, style)[[1]])
  style_marks(own, style)[[1]]
}

palette_usable <- function(name, style = CHART_STYLE_DEFAULT) {
  st = chart_style(style)
  own = utils::head(palette_colours(name), chart_palette_max(name))
  cols = style_marks(own, style)
  cols = cols[chart_colour_distance(cols, st$background) >= CHART_VISIBLE_DE]
  if (is.na(st$swap)) return(cols)
  purrr::reduce(cols, function(kept, col)
    if (length(kept) && any(chart_colour_distance(kept, col) < CHART_VISIBLE_DE)) kept else c(kept, col), .init = character(0))
}

# How many groups a qualitative palette can colour in a style: its number of usable colours. With no
#   style (or when the colours cannot be read), its `max`.
palette_usable_max <- function(name, style = NULL) {
  if (is.null(style)) return(chart_palette_max(name))
  tryCatch(length(palette_usable(name, style)), error = function(e) chart_palette_max(name))
}

# The qualitative palette a chart that needs n colours is drawn with: the chosen one, or the
#   default when the chosen one has fewer than n usable colours in the style (it is not stretched), as
#   long as the default has enough.
palette_for_n <- function(n, name = chart_palette_default()$qualitative, style = NULL) {
  def = chart_palette_default()$qualitative
  if (n > palette_usable_max(name, style) && n <= palette_usable_max(def, style)) def else name
}

# The most groups a chart can colour with a report's palettes: the chosen qualitative palette's
#   usable count in its style, or the default's when that is larger (palette_for_n()).
palette_groups_max <- function(palette = chart_palette_default())
  max(palette_usable_max(palette$qualitative, palette$style), palette_usable_max(chart_palette_default()$qualitative, palette$style))

# n colours of a qualitative palette; an error past its max. With a style, the colours that style shows
#   (palette_usable()), and an error past their number.
chart_palette <- function(n, name = chart_palette_default()$qualitative, style = NULL) {
  e = CHART_PALETTES[[name]]
  if (is.null(e) || !identical(e$kind, "qualitative")) stop("'", name, "' is not a qualitative palette.", call. = FALSE)
  most = palette_usable_max(name, style)
  if (n > most) stop("The palette ", e$label, " colours at most ", most, " groups", if (!is.null(style) && most < e$max) " in this style",
                     "; ", n, " were asked for.", call. = FALSE)
  if (is.null(style)) palette_colours(name)[seq_len(n)] else palette_usable(name, style)[seq_len(n)]
}

# The most groups a qualitative palette shows.
chart_palette_max <- function(name = chart_palette_default()$qualitative) CHART_PALETTES[[name]]$max

# The colours of a continuous scale, sequential or diverging.
chart_sequential <- function(name = chart_palette_default()$sequential) palette_colours(name, CHART_CONTINUOUS_N[["sequential"]])
chart_diverging <- function(name = chart_palette_default()$diverging) palette_colours(name, CHART_CONTINUOUS_N[["diverging"]])

# The style's own sequential ramp (Phase 10b), for the fill that counts rows in cells: from a light tint of the style's accent (the accent mixed
#   with the style's panel colour, CHART_RAMP_TINT of it, so the first step shows against the ground in a light style and a dark one) to the
#   accent, CHART_CONTINUOUS_N steps in Lab space. The sequential palette the analyst chose replaces it (spec_palette()).
CHART_RAMP_TINT <- 0.22
chart_style_ramp <- function(style = CHART_STYLE_DEFAULT) {
  st = chart_style(style)
  mix = (1 - CHART_RAMP_TINT) * grDevices::col2rgb(st$panel) + CHART_RAMP_TINT * grDevices::col2rgb(st$accent)
  tint = grDevices::rgb(mix[1], mix[2], mix[3], maxColorValue = 255)
  ramp = toupper(grDevices::colorRampPalette(c(tint, st$accent), space = "Lab")(CHART_CONTINUOUS_N[["sequential"]]))
  ramp[c(1L, length(ramp))] = toupper(c(grDevices::rgb(mix[1], mix[2], mix[3], maxColorValue = 255), st$accent))     # the ends exactly: the tint and the accent
  ramp
}

chart_fill_scale <- function(...) ggplot2::scale_fill_gradientn(colours = chart_sequential(), ...)
chart_colour_scale <- function(...) ggplot2::scale_colour_gradientn(colours = chart_sequential(), ...)

# The theme of a style as ggplot2 calls, in the order to add them: theme_minimal() and one theme(). They are
#   evaluated to draw a chart (chart_theme()) and printed as they are in the code a chart comes with, with
#   every value written in, so that code needs nothing from this app. The fonts are the variables
#   chart_font, chart_font_semibold, chart_serif and chart_serif_semibold (chart_font_values() gives them
#   a value; the written code sets them to the bundled family when it is registered or installed, else to
#   the default sans or serif). grid is the grid the chart asks for ("y", "x", "xy" or "none": which
#   axes a chart of this family gives a grid), and the style's grid_axes decides what is kept; legend is
#   its place ("right" for a line chart whose legend stands in for its labels); lift sets the value axis
#   labels above their grid line, where the style asks for it. A chart whose lines carry their
#   own labels drops the legend with guides(), not here.
chart_theme_calls <- function(style = CHART_STYLE_DEFAULT, grid = "y", legend = "top", lift = FALSE, base_size = 12) {
  st = chart_style(style)
  e = function(fn, ...) as.call(c(list(as.name(fn)), purrr::compact(list(...))))
  blank = quote(element_blank())
  line = function(colour, width) e("element_line", colour = colour, linewidth = width)
  font = function(role, weight) as.name(names(Filter(function(v) identical(v, c(role, if (identical(weight, "semibold")) "semibold" else "regular")),
                                                      CHART_FONT_VARS))[[1]])
  text = function(role, weight, ..., colour) {
    args = list(family = font(role, weight), face = if (identical(weight, "bold")) "bold", colour = colour, ...)
    do.call(e, c(list("element_text"), args), quote = TRUE)
  }
  axes = if (identical(grid, "none") || identical(st$grid_axes, "none")) "none"
         else if (identical(st$grid_axes, "both")) "xy" else if (identical(st$grid_axes, "horizontal")) "y" else grid
  grid_el = function(axis) if (axes %in% c(axis, "xy")) line(st$grid, st$grid_width) else blank
  ticked = !is.na(st$ticks)
  args = list(
    text = e("element_text", colour = st$text),
    plot.background = e("element_rect", fill = st$background, colour = NA),
    panel.background = e("element_rect", fill = st$panel, colour = NA),
    panel.border = blank, panel.grid.minor = blank,
    panel.grid.major.x = grid_el("x"), panel.grid.major.y = grid_el("y"),
    axis.line = if (is.na(st$axis_line)) blank else line(st$axis_line, 0.4),
    axis.ticks = if (ticked) line(st$ticks, 0.4) else blank,
    axis.ticks.length = if (ticked) call("unit", 3, "pt"),
    plot.title = text(st$title_font, st$title_weight, size = call("rel", st$title_size), hjust = 0, colour = st$text),
    plot.title.position = "plot",
    plot.subtitle = text(st$subtitle_font, "regular", hjust = 0, colour = st$text_2, size = if (st$subtitle_size != 1) call("rel", st$subtitle_size)),
    plot.caption = e("element_text", colour = st$caption, hjust = 0),
    plot.caption.position = "plot",
    axis.title = e("element_text", colour = st$text_2, size = if (st$axis_size != 1) call("rel", st$axis_size)),
    axis.text = e("element_text", colour = st$text_2, size = if (st$axis_size != 1) call("rel", round(0.8 * st$axis_size, 3))),
    axis.text.y = if (isTRUE(lift) && isTRUE(st$lift)) e("element_text", colour = st$text_2, hjust = 1, vjust = -0.35, margin = call("margin", r = 4)),
    strip.text = text("sans", st$strip, hjust = 0, colour = st$text),
    legend.position = legend,
    legend.justification = if (identical(legend, "top")) "left" else "top",
    legend.box = "vertical", legend.box.just = "left",
    legend.title = e("element_text", colour = st$text_2),
    legend.text = e("element_text", colour = st$text),
    plot.margin = call("margin", 8, 12, 8, 8),
    axis.line.x.top = if (!is.na(st$rule)) line(st$rule, 0.5),
    axis.text.x.top = if (!is.na(st$rule)) blank,
    axis.ticks.x.top = if (!is.na(st$rule)) blank,
    axis.title.x.top = if (!is.na(st$rule)) blank)
  # a style made from an office's theme adds its text settings last, as a plain theme() call (style_from_theme())
  c(list(e("theme_minimal", base_size = base_size, base_family = quote(chart_font)),
         as.call(c(list(as.name("theme")), purrr::compact(args)))),
    if (!is.null(st$layer)) list(st$layer))
}

# Layers a style adds besides its theme: the thin rule under the title block is the top axis line, so a
#   style that has one asks for a second x axis (guides(x.sec = "axis")), which its theme draws as a line
#   without labels or ticks.
chart_style_layers <- function(style = CHART_STYLE_DEFAULT) {
  if (is.na(chart_style(style)$rule)) return(list())
  list(call("guides", x.sec = "axis"))
}

# The value of a call of chart_theme_calls(), worked out call by call (each function looked up in env and
#   applied with do.call()): the calls hold only ggplot2 functions, numbers, strings and the font variables.
theme_value <- function(x, env) {
  if (is.call(x)) do.call(get(as.character(x[[1]]), envir = env), purrr::map(as.list(x)[-1], theme_value, env = env))
  else if (is.symbol(x)) get(as.character(x), envir = env)
  else x
}

# The ggplot2 theme of a style: the calls of chart_theme_calls(), applied with the fonts it can draw in.
#   A style made from an office's ggplot theme (style_from_theme(), below) gets that theme itself as the last layer, then the
#   legend's place again (a theme function sets its own legend place, and this chart has asked for one).
chart_theme <- function(style = CHART_STYLE_DEFAULT, base_size = 12, grid = "y", legend = "top", lift = FALSE) {
  cls = chart_theme_calls(style, grid, legend, lift, base_size)
  env = list2env(chart_font_values(cls), parent = asNamespace("ggplot2"))
  th = purrr::reduce(purrr::map(cls, theme_value, env = env), `+`)
  tpl = chart_style(style)$template
  if (is.null(tpl)) th else th + tpl + ggplot2::theme(legend.position = legend)
}


# ---- an office's own ggplot theme ----------------------------------------------------------------------

# An office may have a ggplot theme function of its own (a file that never leaves its machine). app.R names the file and the
#   function (APP_THEME_FILE, APP_THEME_FUNCTION); theme_style_load() sources the file into an environment of its own, calls the
#   function and makes a style of what it returns (style_from_theme()), registered under APP_THEME_NAME and made the default. A file
#   that is not there, does not parse, or has no such function leaves the app as it was, with one sentence for Start here.
# How a theme becomes a style: each element is resolved with ggplot2::calc_element(element, theme) on the completed theme
#   (ggplot2::complete_theme()), so what a theme inherits is read too. The table's fields come from it; what a theme cannot say
#   (accent, slate, the colour of a series with no groups) comes from the arguments, by default the Clean style's. The text settings
#   a field does not hold (the title's colour and alignment, the colours of axis, legend and panel names, a family installed here
#   that is not one of the bundled ones) are kept as `layer`: one plain theme() call that chart_theme_calls() adds last, so the
#   code a chart comes with runs without the template. Sizes are carried by the fields (title, subtitle, axis), not by the layer.

# A colour as "#RRGGBB" (NA for none or transparent): calc_element() gives "#EBEBEBFF", "white" or NA.
theme_hex <- function(col) {
  if (is.null(col) || length(col) != 1L || is.na(col) || !nzchar(col)) return(NA_character_)
  v = tryCatch(grDevices::col2rgb(col, alpha = TRUE), error = function(e) NULL)
  if (is.null(v) || v[4, 1] == 0) return(NA_character_)
  grDevices::rgb(v[1, 1], v[2, 1], v[3, 1], maxColorValue = 255)
}

# A colour between two: `share` of the way from a to b.
theme_mix <- function(a, b, share) {
  x = grDevices::col2rgb(a); y = grDevices::col2rgb(b)
  v = round(x + (y - x) * share)
  grDevices::rgb(v[1, 1], v[2, 1], v[3, 1], maxColorValue = 255)
}

# One element of a completed theme, or NULL when it is blank (or cannot be resolved).
theme_element <- function(ct, name) {
  el = tryCatch(ggplot2::calc_element(name, ct), error = function(e) NULL)
  if (is.null(el) || S7::S7_inherits(el, ggplot2::element_blank)) NULL else el
}

# A property of an element (S7, read with @), or `default` when the element is blank or the property empty.
theme_prop <- function(el, prop, default = NULL) {
  if (is.null(el)) return(default)
  v = tryCatch(S7::prop(el, prop), error = function(e) NULL)
  if (is.null(v) || length(v) == 0L || (length(v) == 1L && is.na(v))) default else v
}

# The family names a theme writes in, with no bundled family and no generic name ("", sans, serif, mono) among them: these are
#   the ones that must be installed here for the theme to look as it was made.
theme_families <- function(ct) {
  nm = c("text", "plot.title", "plot.subtitle", "plot.caption", "axis.title", "axis.text", "strip.text", "legend.title", "legend.text")
  fam = unique(unlist(purrr::map(nm, function(n) theme_prop(theme_element(ct, n), "family", ""))))
  setdiff(fam[nzchar(fam)], c("sans", "serif", "mono", purrr::map_chr(CHART_FONTS, "family")))
}

# Which bundled role a family name stands for: a bundled family by its name, "serif" for serif, otherwise sans.
theme_font_role <- function(family) {
  bundled = purrr::map_chr(CHART_FONTS, "family")
  if (family %in% bundled) names(bundled)[bundled == family][[1]] else if (identical(family, "serif")) "serif" else "sans"
}

# A style (a CHART_STYLES entry with every field the other styles have) from a ggplot theme. accent, slate and single are what a
#   theme cannot give; their defaults are the Clean style's. Besides the fields: `layer` (the plain theme() call above), `template`
#   (the theme itself, added last by chart_theme()) and `fonts_missing` (families the theme names that this machine cannot draw in;
#   their text is drawn in the default sans).
style_from_theme <- function(theme, name, accent = CHART_STYLES$clean$accent, slate = CHART_STYLES$clean$slate, single = CHART_STYLES$clean$single) {
  if (!ggplot2::is_theme(theme)) stop("'", name, "' is not a ggplot theme.", call. = FALSE)
  ct = ggplot2::complete_theme(theme)
  el = function(n) theme_element(ct, n)
  col = function(n, default) theme_hex(theme_prop(el(n), "colour")) %|na|% default
  base = theme_prop(el("text"), "size", 11)
  background = theme_hex(theme_prop(el("plot.background"), "fill")) %|na|% "#FFFFFF"
  panel = theme_hex(theme_prop(el("panel.background"), "fill")) %|na|% background
  text = col("text", "#1A1A1A")
  gx = el("panel.grid.major.x"); gy = el("panel.grid.major.y")
  grid_line = gy %||% gx
  weight = function(n) if (grepl("bold", theme_prop(el(n), "face", "plain"))) "bold" else "regular"
  missing = purrr::keep(theme_families(ct), function(f) !chart_font_available(f))
  family = function(n) {
    f = theme_prop(el(n), "family", "")
    if (nzchar(f) && f %in% missing) "sans" else if (nzchar(f)) f else "sans"
  }
  dark = chart_contrast(background, "#000000") < chart_contrast(background, "#FFFFFF")
  size_of = function(n, of) round(theme_prop(el(n), "size", base * of) / base, 2)
  st = list(label = name, note = "Made from your office's ggplot theme.",
            background = background, panel = panel, text = text, text_2 = col("axis.text", theme_mix(text, background, 0.3)),
            caption = col("plot.caption", theme_mix(text, background, 0.4)),
            grid = theme_hex(theme_prop(grid_line, "colour")) %|na|% theme_mix(background, text, 0.12),
            grid_axes = if (!is.null(gx) && !is.null(gy)) "both" else if (!is.null(gy)) "horizontal" else if (!is.null(gx)) "value" else "none",
            grid_width = round(theme_prop(grid_line, "linewidth", 0.4), 2),
            axis_line = theme_hex(theme_prop(el("axis.line.x"), "colour")), ticks = theme_hex(theme_prop(el("axis.ticks.x"), "colour")),
            title_font = theme_font_role(family("plot.title")), title_weight = weight("plot.title"), title_size = size_of("plot.title", 1.2),
            subtitle_font = theme_font_role(family("plot.subtitle")), strip = if (identical(weight("strip.text"), "bold")) "bold" else "semibold",
            rule = NA, lift = FALSE, grey = theme_mix(background, text, 0.25), fit = col("axis.text", theme_mix(text, background, 0.3)),
            outline = background, box_fill = theme_mix(panel, text, 0.05), swap = if (dark) "lighten" else NA,
            accent = accent, slate = slate, single = single, title_case = NA,
            axis_size = round(theme_prop(el("axis.text.x"), "size", base * 0.8) / (0.8 * base), 2), subtitle_size = size_of("plot.subtitle", 1))
  # the layer: the text settings the fields do not hold, as plain element_text() calls
  txt = function(n, hjust = FALSE, face = FALSE) {
    e = el(n)
    if (is.null(e)) return(NULL)
    f = family(n)
    args = purrr::compact(list(family = if (!f %in% c("sans", "serif", purrr::map_chr(CHART_FONTS, "family"))) f,
                               face = if (face) theme_prop(e, "face"), colour = theme_hex(theme_prop(e, "colour")) %|na|% NULL,
                               hjust = if (hjust) theme_prop(e, "hjust")))
    if (length(args)) as.call(c(list(as.name("element_text")), args))
  }
  layer = purrr::compact(list(plot.title = txt("plot.title", hjust = TRUE), plot.subtitle = txt("plot.subtitle", hjust = TRUE),
                              plot.caption = txt("plot.caption", hjust = TRUE), axis.title = txt("axis.title"), axis.text = txt("axis.text"),
                              strip.text = txt("strip.text"), legend.title = txt("legend.title"), legend.text = txt("legend.text")))
  c(st, list(layer = if (length(layer)) as.call(c(list(as.name("theme")), layer)), template = theme, fonts_missing = unname(missing)))
}

# NA-coalescing: b when a is NA (or NULL).
`%|na|%` <- function(a, b) if (is.null(a) || (length(a) == 1L && is.na(a))) b else a

# The contrast checks of a style, as a table: each pair, its ratio, the least it needs and whether it passes. Text against the
#   background needs 4.5 to 1 (the title's own colour too, when the layer gives it one); accent and slate against the background and
#   against each other need CHART_MARK_CONTRAST (the highlight rule of Phase 10 Part D).
style_contrast <- function(st) {
  title = st$layer$plot.title$colour %||% st$text
  pairs = list(c("text", st$text, st$background, 4.5), c("title", title, st$background, 4.5), c("axis text", st$text_2, st$background, 4.5),
               c("caption", st$caption, st$background, 4.5), c("accent", st$accent, st$background, CHART_MARK_CONTRAST),
               c("slate", st$slate, st$background, CHART_MARK_CONTRAST), c("accent against slate", st$accent, st$slate, CHART_MARK_CONTRAST))
  out = purrr::map_dfr(pairs, function(p) tibble::tibble(pair = p[[1]], a = p[[2]], b = p[[3]], ratio = round(chart_contrast(p[[2]], p[[3]]), 2), needs = as.numeric(p[[4]])))
  out$pass = out$ratio >= out$needs
  out
}

# The key a style name is registered under: lower case, letters and digits ("Office" is "office").
theme_style_key <- function(name) gsub("[^a-z0-9]+", "_", tolower(trimws(name)))

# Loads an office's theme: the file sourced into an environment of its own (its parent the global one, so the packages the app has
#   attached are found; nothing it defines lands in the global environment), the function called, the style made. Returns a list:
#   ok, key, style, and notes, the sentences for Start here (none when no file is set; one when it cannot be used; when it is used,
#   one for each font it names that is missing here and one for the contrast pairs that fail). It never stops the app.
theme_style_load <- function(file, fn, name = "Office", accent = CHART_STYLES$clean$accent, slate = CHART_STYLES$clean$slate) {
  fallback = paste0("so charts use the ", chart_style(CHART_STYLE_DEFAULT)$label, " style.")
  no = function(why) list(ok = FALSE, key = NULL, style = NULL, notes = paste0("The office theme ", why, ", ", fallback))
  if (!is_text1(file) || !nzchar(file)) return(list(ok = FALSE, key = NULL, style = NULL, notes = character(0)))
  if (!file.exists(file)) return(no(paste0("file ", basename(file), " is not there")))
  env = new.env(parent = globalenv())
  loaded = tryCatch({ sys.source(file, envir = env); TRUE }, error = function(e) conditionMessage(e))
  if (!isTRUE(loaded)) return(no(paste0("file ", basename(file), " could not be read (", sub("\n.*$", "", loaded), ")")))
  if (!is_text1(fn) || !exists(fn, envir = env, inherits = FALSE) || !is.function(get(fn, envir = env)))
    return(no(paste0("file ", basename(file), " has no function called ", fn)))
  th = tryCatch(get(fn, envir = env)(), error = function(e) e)
  if (inherits(th, "error")) return(no(paste0("function ", fn, " stopped with an error (", sub("\n.*$", "", conditionMessage(th)), ")")))
  if (!ggplot2::is_theme(th)) return(no(paste0("function ", fn, " did not return a ggplot theme")))
  st = tryCatch(style_from_theme(th, name, accent, slate), error = function(e) e)
  if (inherits(st, "error")) return(no(paste0("could not be turned into a style (", conditionMessage(st), ")")))
  ct = style_contrast(st)
  bad = ct[!ct$pass, ]
  notes = c(if (length(st$fonts_missing)) paste0("The office theme names the font", if (length(st$fonts_missing) > 1L) "s ", if (length(st$fonts_missing) == 1L) " ",
                                                 paste(st$fonts_missing, collapse = " and "), ", which this machine does not have, so its text is drawn in the default sans."),
            if (nrow(bad)) paste0("Some colours of the office theme are hard to tell apart: ",
                                  paste0(bad$pair, " ", format(bad$ratio, nsmall = 1), " to 1 (needs ", bad$needs, ")", collapse = "; "), "."))
  list(ok = TRUE, key = theme_style_key(name), style = st, notes = notes)
}

# Puts a loaded style into CHART_STYLES (in the global environment, where R/ lives) and, when default is TRUE, makes it the default.
#   Returns what it replaced (CHART_STYLES and CHART_STYLE_DEFAULT as they were), so a test can put them back.
theme_style_register <- function(loaded, default = TRUE) {
  was = list(styles = CHART_STYLES, default = CHART_STYLE_DEFAULT)
  if (!isTRUE(loaded$ok)) return(invisible(was))
  styles = CHART_STYLES
  styles[[loaded$key]] = loaded$style
  assign("CHART_STYLES", styles, envir = globalenv())
  if (isTRUE(default)) assign("CHART_STYLE_DEFAULT", loaded$key, envir = globalenv())
  invisible(was)
}

# Puts back what theme_style_register() replaced.
theme_style_restore <- function(was) {
  assign("CHART_STYLES", was$styles, envir = globalenv())
  assign("CHART_STYLE_DEFAULT", was$default, envir = globalenv())
  invisible(NULL)
}
