# A stand-in for an office's ggplot theme (the real one stays on the work machine): a light theme built on theme_minimal(), with
#   its own title colour, a grid across the chart only, and a serif title. Used by tests/smoke.R and the style sheet; not deployed
#   (tests/ is in .rscignore). Point APP_THEME_FILE at this file and APP_THEME_FUNCTION at "theme_standin_light" to try it.
theme_standin_light <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#FBFAF7", colour = NA),
      panel.background = ggplot2::element_rect(fill = "#FBFAF7", colour = NA),
      text = ggplot2::element_text(colour = "#22252A"),
      plot.title = ggplot2::element_text(family = "serif", face = "bold", colour = "#7A1F2B", size = ggplot2::rel(1.45), hjust = 0),
      plot.subtitle = ggplot2::element_text(colour = "#4A4F57", size = ggplot2::rel(0.95)),
      plot.caption = ggplot2::element_text(colour = "#5E636B", hjust = 0),
      axis.text = ggplot2::element_text(colour = "#4A4F57"),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(colour = "#DCDAD3", linewidth = 0.3),
      axis.line.x = ggplot2::element_line(colour = "#22252A", linewidth = 0.4),
      strip.text = ggplot2::element_text(face = "bold", hjust = 0),
      legend.position = "bottom")
}
