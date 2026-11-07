# theme_intern.R -- a high data-ink ggplot2 theme, Okabe-Ito colour scales,
#   and a point-and-interval plot for survey estimates.
#
# Source it into a session:  intern_source_skill("dataviz", "theme_intern.R")
#   or source("<skills_dir>/dataviz/scripts/theme_intern.R").
# Uses ggplot2, rlang and dplyr through pkg::fn(), so nothing needs attaching.

# The Okabe-Ito palette (Okabe & Ito 2008), distinguishable under the common
#   forms of colour-vision deficiency. Yellow is low-contrast on white, so it
#   is moved to the end of the default order; black is for reference marks.
okabe_ito <- c(orange = "#E69F00", sky_blue = "#56B4E9", bluish_green = "#009E73",
               blue = "#0072B2", vermillion = "#D55E00", reddish_purple = "#CC79A7",
               yellow = "#F0E442", black = "#000000")

# grid: which major gridlines to keep -- "x" (vertical lines, for horizontal
#   dot plots and bar charts), "y" (horizontal lines, for vertical bars and
#   time series), "both" or "none". Minor gridlines, ticks, panel borders and
#   backgrounds are always removed.
theme_intern <- function(base_size = 11, base_family = "",
                         grid = c("y", "x", "both", "none")) {
  grid = match.arg(grid)
  line = ggplot2::element_line(colour = "grey88", linewidth = 0.3)
  blank = ggplot2::element_blank()
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.minor = blank,
      panel.grid.major.x = if (grid %in% c("x", "both")) line else blank,
      panel.grid.major.y = if (grid %in% c("y", "both")) line else blank,
      axis.ticks = blank,
      axis.text = ggplot2::element_text(colour = "grey30"),
      axis.title = ggplot2::element_text(colour = "grey30", size = ggplot2::rel(0.9)),
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.15)),
      plot.subtitle = ggplot2::element_text(colour = "grey30",
                                            margin = ggplot2::margin(b = 8)),
      plot.caption.position = "plot",
      plot.caption = ggplot2::element_text(colour = "grey45", hjust = 0,
                                           size = ggplot2::rel(0.8)),
      legend.position = "top",
      legend.justification = "left",
      legend.title = ggplot2::element_text(size = ggplot2::rel(0.9)),
      strip.text = ggplot2::element_text(face = "bold", hjust = 0))
}

okabe_ito_values <- function(order = NULL) {
  v = if (is.null(order)) okabe_ito else okabe_ito[order]
  unname(v)
}

# Discrete scales. `order` picks and orders colours by position or name,
#   e.g. order = c("blue", "vermillion") for a two-group comparison.
scale_colour_okabe_ito <- function(..., order = NULL)
  ggplot2::scale_colour_manual(..., values = okabe_ito_values(order))

scale_fill_okabe_ito <- function(..., order = NULL)
  ggplot2::scale_fill_manual(..., values = okabe_ito_values(order))

scale_color_okabe_ito <- scale_colour_okabe_ito

# Point estimates with interval bars, sorted by the estimate, for the output
#   of srvyr::survey_mean()/survey_prop() or survey::svyby() turned into a
#   data frame. Columns are given unquoted.
#   colour: optional grouping (e.g. weighted vs unweighted), dodged and
#           drawn in Okabe-Ito colours with matching shapes.
#   percent: axis labelled as percentages (for proportions on 0-1).
plot_estimates <- function(data, x, y, lower, upper, colour = NULL,
                           title = NULL, subtitle = NULL, caption = NULL,
                           percent = FALSE, sort = TRUE) {
  grouped = !rlang::quo_is_null(rlang::enquo(colour))
  d = dplyr::mutate(data, .y = factor({{ y }}))
  if (sort) d = dplyr::mutate(d, .y = stats::reorder(.y, {{ x }}, FUN = mean))
  dodge = ggplot2::position_dodge(width = if (grouped) 0.5 else 0)

  p = if (grouped) {
    ggplot2::ggplot(d, ggplot2::aes(x = {{ x }}, y = .y, xmin = {{ lower }},
                                    xmax = {{ upper }}, colour = {{ colour }},
                                    shape = {{ colour }})) +
      ggplot2::geom_pointrange(position = dodge, linewidth = 0.6, size = 0.4) +
      scale_colour_okabe_ito(order = c("blue", "vermillion", "bluish_green",
                                       "reddish_purple", "orange", "sky_blue"))
  } else {
    ggplot2::ggplot(d, ggplot2::aes(x = {{ x }}, y = .y, xmin = {{ lower }},
                                    xmax = {{ upper }})) +
      ggplot2::geom_pointrange(colour = okabe_ito[["blue"]], linewidth = 0.6, size = 0.4)
  }
  p +
    ggplot2::scale_x_continuous(labels = if (percent) scales::label_percent()
                                         else ggplot2::waiver()) +
    ggplot2::labs(x = rlang::as_label(rlang::enquo(x)), y = NULL, colour = NULL,
                  shape = NULL, title = title, subtitle = subtitle, caption = caption) +
    theme_intern(grid = "x")
}
