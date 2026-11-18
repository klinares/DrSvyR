# theme.R for chaRt
# The look of every chart: the ggplot2 theme, the colours for groups, the continuous scale and the
#   two colours of a highlight. This is the one file replaced at work with the office theme and
#   palette, so it is self-contained: it uses ggplot2 and grDevices and nothing else from the app.
#   R/spec.R reads CHART_SINGLE, CHART_HIGHLIGHT, CHART_GREY, CHART_SEQUENTIAL and chart_palette(),
#   and the code a chart comes with ends with chart_theme(). Function definitions and constants only.


# One series with no groups.
CHART_SINGLE <- "#0072B2"

# A highlight: the named values in CHART_HIGHLIGHT, everything else in CHART_GREY.
CHART_HIGHLIGHT <- "#D55E00"
CHART_GREY <- "#BDBDBD"

# A continuous fill or colour: viridis (viridisLite::viridis(7), written out so nothing else is needed).
CHART_SEQUENTIAL <- c("#440154", "#443A83", "#31688E", "#21908C", "#35B779", "#8FD744", "#FDE725")

# The most groups chart_palette() colours.
CHART_MAX_GROUPS <- 8L

# The Okabe-Ito colours for up to 8 groups, from grDevices::palette.colors(palette = "Okabe-Ito"),
#   which gives 9: black, orange, sky blue, bluish green, yellow, blue, vermillion, reddish purple,
#   grey. Grey is left out, since it is what a highlight puts everything else in; yellow, hard to
#   see on white, comes last and is used only when there are eight groups.
chart_palette <- function(n) {
  if (n > CHART_MAX_GROUPS)
    stop("chart_palette() colours at most ", CHART_MAX_GROUPS, " groups; ", n, " were asked for.", call. = FALSE)
  oi = unname(grDevices::palette.colors(palette = "Okabe-Ito"))
  oi[c(2, 3, 4, 6, 7, 8, 1, 5)][seq_len(n)]
}

chart_fill_scale <- function(...) ggplot2::scale_fill_gradientn(colours = CHART_SEQUENTIAL, ...)
chart_colour_scale <- function(...) ggplot2::scale_colour_gradientn(colours = CHART_SEQUENTIAL, ...)

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
