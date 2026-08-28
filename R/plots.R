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


# ---- the factor diagram -------------------------------------------------

# Factors on the left, items on the right, one line per loading with its width
#   and opacity carrying the strength. Built with ggplot rather than a diagram
#   package, so it has no dependency that could fail to install on a locked-down
#   machine, and so the same picture goes into the report.

plot_cfa_diagram <- function(fit, salient = 0.4, correlations = NULL) {
  L <- as.data.frame(unclass(lavInspect(fit, "std")$lambda)) |>
    tibble::rownames_to_column("item") |>
    pivot_longer(-item, names_to = "factor", values_to = "loading") |>
    filter(abs(loading) >= 0.05)

  facs <- unique(L$factor)

  # Items ordered by the factor they load on most strongly, so the lines do not
  #   cross more than the structure requires.
  home <- L |>
    group_by(item) |>
    slice_max(abs(loading), n = 1) |>
    ungroup() |>
    arrange(factor, desc(abs(loading)))

  item_pos <- tibble(item = home$item,
                     y = seq(0, 1, length.out = nrow(home)))
  fac_pos <- tibble(
    factor = facs,
    y = if (length(facs) == 1) 0.5 else seq(0.15, 0.85, length.out = length(facs)))

  edges <- L |>
    left_join(item_pos, by = "item") |> rename(y_item = y) |>
    left_join(fac_pos, by = "factor") |> rename(y_fac = y)

  # The correlation between factors is a parameter of the model and belongs in
  #   the picture of it. Drawn as a curve to the left, the way a path diagram
  #   conventionally shows a covariance rather than a regression.
  psi <- unclass(lavInspect(fit, "std")$psi)
  arcs <- if (length(facs) > 1) {
    pr <- t(utils::combn(facs, 2))
    tibble(a = pr[, 1], b = pr[, 2],
           r = map2_dbl(pr[, 1], pr[, 2], function(x, y) psi[x, y])) |>
      left_join(rename(fac_pos, a = factor, ya = y), by = "a") |>
      left_join(rename(fac_pos, b = factor, yb = y), by = "b") |>
      mutate(label = if (is.null(correlations)) sprintf("r = %.2f", r)
             else map2_chr(a, b, function(x, y) {
               row <- filter(correlations, a == x, b == y)
               if (!nrow(row)) sprintf("r = %.2f", psi[x, y])
               else sprintf("r = %.2f [%.2f, %.2f]", row$r, row$lo, row$hi)
             }))
  } else NULL

  ggplot() +
    {if (!is.null(arcs)) list(
      geom_curve(data = arcs,
                 aes(x = 0.06, xend = 0.06, y = ya, yend = yb),
                 curvature = -0.9, linewidth = 0.5, colour = WISE_INK,
                 arrow = grid::arrow(length = grid::unit(0.10, "cm"),
                                     ends = "both")),
      geom_label(data = arcs,
                 aes(x = -0.10, y = (ya + yb) / 2, label = label),
                 size = 4.4, linewidth = 0, fill = NA, colour = WISE_INK))} +

    geom_segment(data = edges,
                 aes(x = 0.15, xend = 0.72, y = y_fac, yend = y_item,
                     linewidth = abs(loading), alpha = abs(loading),
                     colour = factor)) +

    # Nudged off the line rather than sitting on it, so the number and the edge
    #   are not fighting for the same pixels.
    geom_label(data = filter(edges, abs(loading) >= salient),
               aes(x = 0.44, y = (y_fac + y_item) / 2 + 0.018,
                   label = sprintf("%.2f", loading)),
               size = 4.2, linewidth = 0, fill = NA, colour = WISE_INK) +

    geom_label(data = fac_pos, aes(x = 0.09, y = y, label = factor),
               size = 5.4, fontface = "bold", linewidth = 0.3,
               fill = NA, colour = WISE_INK) +
    geom_text(data = item_pos, aes(x = 0.78, y = y, label = item),
              hjust = 0, size = 4.8, colour = WISE_INK) +

    scale_linewidth(range = c(0.3, 2.4), guide = "none") +
    scale_alpha(range = c(0.2, 0.9), guide = "none") +
    wise_colour(name = NULL) +
    scale_x_continuous(limits = c(-0.34, 1.62)) +
    scale_y_continuous(expand = expansion(mult = 0.06)) +
    labs(caption = paste("Line thickness is the standardised loading; values",
                         "shown at or above", salient,
                         ". The curve on the left is the correlation between",
                         "the factors -- how far the two things they measure",
                         "travel together.")) +
    wise_theme() +
    theme(axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank())
}


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
