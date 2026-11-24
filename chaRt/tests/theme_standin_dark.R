# A stand-in for an office's ggplot theme (the real one stays on the work machine): a dark theme, with a title in a font no machine
#   here has ("Corporate Sans": the app draws it in the default sans and says so) and a caption colour too dim for its ground (the
#   contrast check reports it as a warning). Used by tests/smoke.R and the style sheet; not deployed (tests/ is in .rscignore).
theme_standin_dark <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#1B1F24", colour = NA),
      panel.background = ggplot2::element_rect(fill = "#1B1F24", colour = NA),
      text = ggplot2::element_text(colour = "#E6E8EB"),
      plot.title = ggplot2::element_text(family = "Corporate Sans", face = "bold", colour = "#FFFFFF", size = ggplot2::rel(1.3)),
      plot.subtitle = ggplot2::element_text(colour = "#B8BEC6"),
      plot.caption = ggplot2::element_text(colour = "#555B63"),
      axis.text = ggplot2::element_text(colour = "#B8BEC6"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "#353B43", linewidth = 0.35),
      strip.text = ggplot2::element_text(colour = "#E6E8EB", face = "bold"))
}
