# plots.R for DrSvyR
# Figures and the theme they share.

# Merged from:
#   plots.R

# ---- theme -------------------------------------------------------------

# Every figure is drawn theme-neutral rather than following the app's light or
#   dark mode. Backgrounds are transparent and the ink is a mid grey that reads
#   on both. Two reasons, and the second matters more than the first.

# A figure that follows the app theme has to know which theme is in use, and
#   the only place that was recorded was a process-wide option. On a server one
#   analyst's setting would follow another's plots. Being neutral means there is
#   nothing to know and nothing to leak.

# And the figure in the app is then the same figure that goes into the report,
#   which is drawn on white paper. What the analyst approves on screen is what
#   is saved.

# The honest cost: no single ink is high-contrast on both white and near-black.
#   #767676 clears 4.5:1 on white and about 3:1 on the dark background, which is
#   the threshold for large text and graphical elements -- which is why the base
#   size is 14 rather than 11.

# Requires: ggplot2, dplyr, purrr, tibble, tidyr

WISE_INK   <- "#767676"
WISE_GRID  <- "#88888855"

wise_theme <- function(base_size = 14) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background   = element_rect(fill = NA, colour = NA),
      panel.background  = element_rect(fill = NA, colour = NA),
      legend.background = element_rect(fill = NA, colour = NA),
      legend.key        = element_rect(fill = NA, colour = NA),

      # Both directions by default. Half these figures are horizontal -- the
      #   domain estimates, the loadings, the discrimination plot -- and on
      #   those the x gridlines are the ones you read a value against.
      #   Blanking them removed the reference lines from exactly the plots
      #   that need them. Categorical-x plots blank them in wise_rotate_x().
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = WISE_GRID, linewidth = 0.3),

      text       = element_text(colour = WISE_INK),
      axis.text  = element_text(colour = WISE_INK, size = rel(0.95)),
      axis.title = element_text(colour = WISE_INK, size = rel(0.95)),
      strip.text = element_text(face = "bold", size = rel(1.0),
                                colour = WISE_INK,
                                margin = margin(b = 6, t = 2)),

      plot.title  = element_blank(),
      plot.margin = margin(10, 16, 10, 10),

      legend.position = "bottom",
      legend.text  = element_text(size = rel(0.95)),
      legend.title = element_text(face = "bold", size = rel(0.95)),

      plot.caption = element_text(hjust = 0, size = rel(0.85),
                                  colour = WISE_INK,
                                  margin = margin(t = 10)))
}

# Trimmed away from both ends of the scale. The darkest viridis is lost on a
#   dark background and the lightest on a white one; the middle reads on both.
wise_colour <- function(...) scale_colour_viridis_d(..., begin = 0.15, end = 0.85)
wise_fill   <- function(...) scale_fill_viridis_d(..., begin = 0.15, end = 0.85)

# One accent for single-series figures, from the same trimmed range.
wise_accent <- function() viridis::viridis(1, begin = 0.35)

# Rotated tick labels clip against the panel edge unless the plot is given room
#   for them. Applied wherever the x axis carries item names -- which is also
#   where a vertical gridline per item is clutter rather than a reference.
wise_rotate_x <- function(angle = 45)
  theme(axis.text.x = element_text(angle = angle, hjust = 1, vjust = 1),
        panel.grid.major.x = element_blank(),
        plot.margin = margin(10, 16, 16, 10))




# ---- discrimination -----------------------------------------------------

# Discrimination against range. They answer different questions and a battery
#   of mixed formats needs both: discrimination is sensitive to shape and
#   treats categories as unordered, which is what the model does; range is what
#   an analyst reads off a profile plot.

plot_discrimination <- function(disc) {
  disc |>
    mutate(item = factor(item, levels = rev(item))) |>
    pivot_longer(c(discrimination, range), names_to = "measure",
                 values_to = "value") |>
    mutate(measure = recode(measure,
                            discrimination = "Separates the groups",
                            range = "Spread across the scale")) |>
    ggplot(aes(value, item, colour = measure)) +
    geom_line(aes(group = item), colour = WISE_GRID, linewidth = 0.8) +
    geom_point(size = 3.4) +
    scale_x_continuous(limits = c(0, 1)) +
    wise_colour(name = NULL) +
    labs(x = NULL, y = NULL,
         caption = paste("Both are bounded at 0 and 1. An item low on both is",
                         "carrying little; one high on a single measure is",
                         "worth reading, not dropping.")) +
    wise_theme()
}
