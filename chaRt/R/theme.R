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

# The palettes an analyst may choose from: a short list of palettes made or flagged for colour-
#   vision deficiency (tests/smoke.R prints how far apart their colours stay under simulated
#   deficiency). Each entry has a label, a kind (qualitative, sequential or diverging), and either
#   `colours` (hex, needing nothing: an office palette goes here) or `paletteer` (the name as
#   paletteer takes it); a qualitative one also `max`, how many groups it can show. All the
#   paletteer names below are in the installed paletteer's tables (1.7.0). Okabe-Ito is the
#   grDevices::palette.colors() set with grey left out (a highlight's background) and yellow last
#   (hard to see on white, used only with eight groups). Blue-red is grDevices::hcl.colors(11,
#   "Blue-Red 2"), the fallback diverging palette when paletteer is not installed.
CHART_PALETTES <- list(
  okabe_ito = list(label = "Okabe-Ito", kind = "qualitative", max = 8L,
                   colours = c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7", "#000000", "#F0E442")),
  tol_bright = list(label = "Paul Tol bright", kind = "qualitative", max = 7L, paletteer = "khroma::bright"),
  tol_muted = list(label = "Paul Tol muted", kind = "qualitative", max = 9L, paletteer = "khroma::muted"),
  tol_vibrant = list(label = "Paul Tol vibrant", kind = "qualitative", max = 7L, paletteer = "khroma::vibrant"),
  viridis = list(label = "Viridis", kind = "sequential", colours = CHART_SEQUENTIAL),
  magma = list(label = "Magma", kind = "sequential", paletteer = "viridis::magma"),
  cividis = list(label = "Cividis", kind = "sequential", paletteer = "viridis::cividis"),
  mako = list(label = "Mako", kind = "sequential", paletteer = "viridis::mako"),
  blues = list(label = "ColorBrewer Blues", kind = "sequential", paletteer = "RColorBrewer::Blues"),
  ylgnbu = list(label = "ColorBrewer YlGnBu", kind = "sequential", paletteer = "RColorBrewer::YlGnBu"),
  rdbu = list(label = "ColorBrewer RdBu", kind = "diverging", paletteer = "RColorBrewer::RdBu"),
  puor = list(label = "ColorBrewer PuOr", kind = "diverging", paletteer = "RColorBrewer::PuOr"),
  brbg = list(label = "ColorBrewer BrBG", kind = "diverging", paletteer = "RColorBrewer::BrBG"),
  sunset = list(label = "Paul Tol sunset", kind = "diverging", paletteer = "khroma::sunset"),
  blue_red = list(label = "Blue-red (built in)", kind = "diverging",
                  colours = c("#4A6FE3", "#7086E1", "#8F9DE1", "#ABB4E2", "#C7CBE3", "#E2E2E2", "#E6C4C9", "#E5A5B1",
                              "#E28699", "#DB6581", "#D33F6A")))

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
  toupper(substr(as.character(cols), 1, 7))
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
