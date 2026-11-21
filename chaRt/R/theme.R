# theme.R for chaRt
# The look of every chart: the ggplot2 theme, the palettes an analyst may choose from, and the two
#   colours of a highlight. This is the one file replaced at work with the office theme and
#   palette, so it is self-contained: it uses ggplot2 and grDevices, and paletteer when it is
#   installed (the app starts without it), and nothing else from the app. R/spec.R reads
#   CHART_SINGLE, CHART_HIGHLIGHT, CHART_GREY, chart_palette(), chart_sequential(),
#   chart_diverging() and chart_palette_default(), and the code a chart comes with ends with
#   chart_theme(). Function definitions and constants only.


# One series with no groups.
CHART_SINGLE <- "#0072B2"

# A highlight: the named values in CHART_HIGHLIGHT, everything else in CHART_GREY.
CHART_HIGHLIGHT <- "#D55E00"
CHART_GREY <- "#BDBDBD"

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
  okabe_ito = list(label = "Okabe-Ito", source = "Built in", kind = "qualitative", max = 8L,
                   colours = c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7", "#000000", "#F0E442")),
  tol_bright = list(label = "Paul Tol bright", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 7L, paletteer = "khroma::bright"),
  tol_muted = list(label = "Paul Tol muted", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 9L, paletteer = "khroma::muted"),
  tol_vibrant = list(label = "Paul Tol vibrant", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 7L, paletteer = "khroma::vibrant"),
  khro_mediumcontrast = list(label = "Paul Tol medium contrast", source = "khroma (Paul Tol, Crameri)", kind = "qualitative", max = 6L, paletteer = "khroma::mediumcontrast"),
  ggth_classic_color_blind = list(label = "Tableau Classic Color Blind", source = "ggthemes", kind = "qualitative", max = 10L, paletteer = "ggthemes::Classic_Color_Blind"),
  ggth_stata_economist = list(label = "Stata Economist", source = "ggthemes", kind = "qualitative", max = 15L, paletteer = "ggthemes::stata_economist"),
  ggth_excel_office_theme = list(label = "Excel Office Theme", source = "ggthemes", kind = "qualitative", max = 6L, paletteer = "ggthemes::excel_Office_Theme"),
  metb_archambault = list(label = "Archambault", source = "MetBrewer", kind = "qualitative", max = 7L, paletteer = "MetBrewer::Archambault"),
  metb_veronese = list(label = "Veronese", source = "MetBrewer", kind = "qualitative", max = 7L, paletteer = "MetBrewer::Veronese"),
  metb_johnson = list(label = "Johnson", source = "MetBrewer", kind = "qualitative", max = 5L, paletteer = "MetBrewer::Johnson"),
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
  rdbu = list(label = "ColorBrewer RdBu", source = "ColorBrewer", kind = "diverging", paletteer = "RColorBrewer::RdBu"),
  puor = list(label = "ColorBrewer PuOr", source = "ColorBrewer", kind = "diverging", paletteer = "RColorBrewer::PuOr"),
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
  rcar_bluyl = 11.2, rdbu = 22.9, puor = 24.7, brbg = 13.7, sunset = 18.7, khro_vanimo = 27.9,
  khro_vik = 28.2, khro_bam = 24.1, ggth_red_blue_white = 25.2, ggth_orange_blue_white = 25.1,
  ggth_classic_orange_white_blue = 23.5, nord_silver_mine = 8.5, pnwc_shuksan2 = 15.0,
  pnwc_anemone = 8.3, rcar_earth = 15.2, rcar_armyrose = 12.5, rcar_geyser = 11.4, blue_red = 13.9)

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
  wesa_isleofdogs2 = c(16.9, 10.7, 10.7, 8.4))

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

# The three palettes a report starts with. At work, this is the function to change.
chart_palette_default <- function()
  list(qualitative = "okabe_ito", sequential = "viridis",
       diverging = if (palette_available("rdbu")) "rdbu" else "blue_red")

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

# The qualitative palette a chart that needs n colours is drawn with: the chosen one, or the
#   default when the chosen one has fewer than n colours (it is not stretched), as long as the
#   default has enough.
palette_for_n <- function(n, name = chart_palette_default()$qualitative) {
  def = chart_palette_default()$qualitative
  if (n > chart_palette_max(name) && n <= chart_palette_max(def)) def else name
}

# The most groups a chart can colour with a report's palettes: the chosen qualitative palette's
#   max, or the default's when that is larger (palette_for_n()).
palette_groups_max <- function(palette = chart_palette_default())
  max(chart_palette_max(palette$qualitative), chart_palette_max(chart_palette_default()$qualitative))

# n colours of a qualitative palette; an error past its max.
chart_palette <- function(n, name = chart_palette_default()$qualitative) {
  e = CHART_PALETTES[[name]]
  if (is.null(e) || !identical(e$kind, "qualitative")) stop("'", name, "' is not a qualitative palette.", call. = FALSE)
  if (n > e$max) stop("The palette ", e$label, " colours at most ", e$max, " groups; ", n, " were asked for.", call. = FALSE)
  palette_colours(name)[seq_len(n)]
}

# The most groups a qualitative palette shows.
chart_palette_max <- function(name = chart_palette_default()$qualitative) CHART_PALETTES[[name]]$max

# The colours of a continuous scale, sequential or diverging.
chart_sequential <- function(name = chart_palette_default()$sequential) palette_colours(name, CHART_CONTINUOUS_N[["sequential"]])
chart_diverging <- function(name = chart_palette_default()$diverging) palette_colours(name, CHART_CONTINUOUS_N[["diverging"]])

chart_fill_scale <- function(...) ggplot2::scale_fill_gradientn(colours = chart_sequential(), ...)
chart_colour_scale <- function(...) ggplot2::scale_colour_gradientn(colours = chart_sequential(), ...)

# A minimal theme with high data-ink: no panel border, no minor grid, a light major grid only along
#   the value axis (grid = "y", "x", "xy" or "none"), the title left-aligned and bold, the legend on
#   top (legend = "right" for a line chart whose legend stands in for its labels), and two legends
#   stacked rather than side by side. A chart whose lines carry their own labels drops the legend
#   with guides(), not here.
chart_theme <- function(base_size = 12, grid = "y", legend = "top") {
  line = ggplot2::element_line(colour = "#E5E5E5", linewidth = 0.4)
  none = ggplot2::element_blank()
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.border = none,
      panel.grid.minor = none,
      panel.grid.major.x = if (grid %in% c("x", "xy")) line else none,
      panel.grid.major.y = if (grid %in% c("y", "xy")) line else none,
      plot.title = ggplot2::element_text(face = "bold", hjust = 0),
      plot.title.position = "plot",
      plot.subtitle = ggplot2::element_text(colour = "#4D4D4D", hjust = 0),
      plot.caption = ggplot2::element_text(colour = "#7F7F7F", hjust = 0),
      plot.caption.position = "plot",
      axis.title = ggplot2::element_text(colour = "#4D4D4D"),
      axis.text = ggplot2::element_text(colour = "#4D4D4D"),
      strip.text = ggplot2::element_text(face = "bold", hjust = 0),
      legend.position = legend,
      legend.justification = if (identical(legend, "top")) "left" else "top",
      legend.box = "vertical",
      legend.box.just = "left",
      legend.title = ggplot2::element_text(colour = "#4D4D4D"))
}
