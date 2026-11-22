# theme.R for chaRt
# The look of every chart: the typeface, the six styles (CHART_STYLES), the ggplot2 theme, the
#   palettes an analyst may choose from, and the colour of a highlight. This is the one file
#   replaced at work with the office theme and palette, so it is self-contained: it uses ggplot2,
#   grDevices, ragg and svglite (when installed: chart_device()), systemfonts (when installed: without it charts
#   draw in the default fonts) and paletteer when it is installed (the app starts without it), and nothing else
#   from the app.
#   R/spec.R reads CHART_HIGHLIGHT, chart_style(), chart_theme_calls(), chart_style_layers(),
#   chart_font_values(), style_marks(), chart_palette(), chart_sequential(), chart_diverging() and
#   chart_palette_default(); the code a chart comes with carries chart_theme_calls() written out
#   as plain ggplot2 calls. Function definitions and constants only.


# A highlight: the named values in CHART_HIGHLIGHT, everything else in the style's `grey`.
CHART_HIGHLIGHT <- "#D55E00"

# ---- type ------------------------------------------------------------------------------------------

# The two bundled families (www/fonts/, both under the SIL Open Font License 1.1, each with its
#   licence file). Each is registered with systemfonts under two names: the family itself (regular, and
#   bold for face = "bold") and "<family> SemiBold" (semibold as its plain face), since register_font()
#   takes four faces, not a weight; `fallback` is what a chart draws in when the family is neither
#   registered nor installed.
CHART_FONT_DIR <- file.path("www", "fonts")
CHART_FONTS <- list(
  sans = list(family = "Inter", fallback = "sans", css = "Inter, sans-serif",
              regular = "Inter-Regular.ttf", semibold = "Inter-SemiBold.ttf", bold = "Inter-Bold.ttf"),
  serif = list(family = "Source Serif 4", fallback = "serif", css = "'Source Serif 4', serif",
               regular = "SourceSerif4-Regular.ttf", semibold = "SourceSerif4-Semibold.ttf", bold = "SourceSerif4-Bold.ttf"))

# The variables the written code and the theme use for a family: sans regular is chart_font, and so on.
CHART_FONT_VARS <- list(chart_font = c("sans", "regular"), chart_font_semibold = c("sans", "semibold"),
                        chart_serif = c("serif", "regular"), chart_serif_semibold = c("serif", "semibold"))

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
#   three it stops with CHART_DEVICE_NONE, as a sentence and not a failure inside a graphics package.
chart_device <- function(file, width, height, dpi) {
  kind = chart_device_kind()
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
#   type png() and jpeg() use when none is given, as plotly's own conversion does), and shiny.useragg TRUE when the
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
#   A series with no colour column is drawn in the chosen qualitative palette's first colour in every style.
#   The Phase 7 checks (tests/smoke.R): text, text_2 and caption against the background 4.5 to 1 or more;
#   the grid below text; `grey` visible against the background but weaker than any palette colour.
CHART_MARK_CONTRAST <- 3
CHART_STYLE_DEFAULT <- "clean"
CHART_STYLES <- list(
  clean = list(label = "Clean", note = "White, a light grid along the value axis, a bold title.",
               background = "#FFFFFF", panel = "#FFFFFF", text = "#1A1A1A", text_2 = "#4D4D4D", caption = "#6B6B6B",
               grid = "#E5E5E5", grid_axes = "value", grid_width = 0.4, axis_line = NA, ticks = NA,
               title_font = "sans", title_weight = "bold", title_size = 1.2, subtitle_font = "sans", strip = "bold",
               rule = NA, lift = FALSE, grey = "#C4C4C4", fit = "#4D4D4D", outline = "#FFFFFF", box_fill = "#F2F2F2", swap = NA),
  minimal = list(label = "Minimal", note = "No grid and no axis line; ticks only. The least ink that still reads.",
                 background = "#FFFFFF", panel = "#FFFFFF", text = "#262626", text_2 = "#4D4D4D", caption = "#6B6B6B",
                 grid = "#E5E5E5", grid_axes = "none", grid_width = 0.4, axis_line = NA, ticks = "#4D4D4D",
                 title_font = "sans", title_weight = "semibold", title_size = 1.15, subtitle_font = "sans", strip = "semibold",
                 rule = NA, lift = FALSE, grey = "#C4C4C4", fit = "#4D4D4D", outline = "#FFFFFF", box_fill = "#FFFFFF", swap = NA),
  magazine = list(label = "Magazine", note = "A pale tint, a white grid, a heavy title.",
                  background = "#E6EDF2", panel = "#E6EDF2", text = "#14202B", text_2 = "#38464F", caption = "#4F5D66",
                  grid = "#FFFFFF", grid_axes = "value", grid_width = 0.7, axis_line = NA, ticks = NA,
                  title_font = "sans", title_weight = "bold", title_size = 1.5, subtitle_font = "sans", strip = "bold",
                  rule = NA, lift = TRUE, grey = "#B5C0C9", fit = "#2B3A45", outline = "#E6EDF2", box_fill = "#F7FAFC", swap = NA),
  desk = list(label = "Data desk", note = "Light grey, a darker grid both ways, a large bold title.",
              background = "#EBEBEB", panel = "#EBEBEB", text = "#111111", text_2 = "#333333", caption = "#4A4A4A",
              grid = "#C2C2C2", grid_axes = "both", grid_width = 0.4, axis_line = NA, ticks = NA,
              title_font = "sans", title_weight = "bold", title_size = 1.6, subtitle_font = "sans", strip = "bold",
              rule = NA, lift = FALSE, grey = "#BDBDBD", fit = "#333333", outline = "#EBEBEB", box_fill = "#F7F7F7", swap = NA),
  newspaper = list(label = "Newspaper", note = "White, a serif title, a thin black rule under the title block, a hairline grid.",
                   background = "#FFFFFF", panel = "#FFFFFF", text = "#111111", text_2 = "#404040", caption = "#595959",
                   grid = "#D9D9D9", grid_axes = "value", grid_width = 0.2, axis_line = NA, ticks = NA,
                   title_font = "serif", title_weight = "bold", title_size = 1.35, subtitle_font = "serif", strip = "bold",
                   rule = "#000000", lift = FALSE, grey = "#C4C4C4", fit = "#404040", outline = "#FFFFFF", box_fill = "#F2F2F2", swap = NA),
  dark = list(label = "Dark", note = "Near-black, light text, a muted grid.",
              background = "#14171C", panel = "#14171C", text = "#ECEFF2", text_2 = "#B9C0C8", caption = "#9AA3AD",
              grid = "#303640", grid_axes = "value", grid_width = 0.4, axis_line = NA, ticks = NA,
              title_font = "sans", title_weight = "bold", title_size = 1.2, subtitle_font = "sans", strip = "bold",
              rule = NA, lift = FALSE, grey = "#565E68", fit = "#C8CED6", outline = "#14171C", box_fill = "#232932", swap = "lighten"))

# The style of that name; an error for one that is not there.
chart_style <- function(name = CHART_STYLE_DEFAULT) {
  s = CHART_STYLES[[name %||% CHART_STYLE_DEFAULT]]
  if (is.null(s)) stop("There is no style '", name, "'.", call. = FALSE)
  s
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
         else if (identical(st$grid_axes, "both")) "xy" else grid
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
    plot.subtitle = text(st$subtitle_font, "regular", hjust = 0, colour = st$text_2),
    plot.caption = e("element_text", colour = st$caption, hjust = 0),
    plot.caption.position = "plot",
    axis.title = e("element_text", colour = st$text_2),
    axis.text = e("element_text", colour = st$text_2),
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
  list(e("theme_minimal", base_size = base_size, base_family = quote(chart_font)),
       as.call(c(list(as.name("theme")), purrr::compact(args))))
}

# Layers a style adds besides its theme: the thin rule under the title block is the top axis line, so a
#   style that has one asks for a second x axis (guides(x.sec = "axis")), which its theme draws as a line
#   without labels or ticks. The plotly version leaves it out.
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
chart_theme <- function(style = CHART_STYLE_DEFAULT, base_size = 12, grid = "y", legend = "top", lift = FALSE) {
  cls = chart_theme_calls(style, grid, legend, lift, base_size)
  env = list2env(chart_font_values(cls), parent = asNamespace("ggplot2"))
  purrr::reduce(purrr::map(cls, theme_value, env = env), `+`)
}
