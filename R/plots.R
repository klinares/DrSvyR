# plots.R for DrSvyR
# Figures and the theme they share.

# Merged from: 
#   plots.R

# ---- plots -------------------------------------------------------------

# plots.R for WISE repo
# App plots and the theme they share.

#   1. Theme
#   2. The factor diagram
#   3. The discrimination plot

# theme_lca() in the engine is written for the printed report and assumes a
#   white page. The app has a dark mode, so plots drawn in it take their colours
#   from here instead.

# The mode is held in an option rather than passed through every call. That is
#   correct for one analyst on one machine and wrong for a shared server, where
#   it would leak one user's setting into another's plots. If this is ever
#   hosted for several people at once, it has to become session state.

# Requires: ggplot2, dplyr, purrr, tibble, tidyr


# Section 1
#______________________________________________________________________________

wise_dark <- function() isTRUE(getOption("wise.dark", FALSE))

wise_theme <- function(base_size = 11) {
  dark = wise_dark()
  fg = if (dark) "#e6e6e6" else "#1a1a1a"
  muted = if (dark) "#9aa0a6" else "grey30"

  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = NA, colour = NA),
      panel.background = ggplot2::element_rect(fill = NA, colour = NA),
      legend.background = ggplot2::element_rect(fill = NA, colour = NA),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(
        colour = if (dark) "#3a3f44" else "grey90"),
      panel.grid.major.x = ggplot2::element_blank(),
      text = ggplot2::element_text(colour = fg),
      axis.text = ggplot2::element_text(colour = fg),
      strip.text = ggplot2::element_text(face = "bold", size = ggplot2::rel(0.85),
                                         colour = fg),
      plot.title = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(face = "bold",
                                           size = ggplot2::rel(0.85)),
      plot.caption = ggplot2::element_text(hjust = 0, size = ggplot2::rel(0.78),
                                           colour = muted))
}


# Section 2 draws the measurement model as a path diagram. Factors on the left,
#   items on the right, one line per loading with its width and opacity carrying
#   the strength.

# Built from the fitted loadings with ggplot rather than a diagram package, so
#   it has no dependency that could fail to install on a locked-down machine,
#   and so the same picture goes into the report.
#______________________________________________________________________________

plot_cfa_diagram <- function(fit, salient = 0.4, correlations = NULL) {
  L = as.data.frame(unclass(lavInspect(fit, "std")$lambda)) |>
    tibble::rownames_to_column("item") |>
    tidyr::pivot_longer(-item, names_to = "factor", values_to = "loading") |>
    dplyr::filter(abs(loading) >= 0.05)

  items = unique(L$item)
  facs = unique(L$factor)

  # Items ordered by the factor they load on most strongly, so the lines do not
  #   cross more than the structure requires.
  home = L |>
    dplyr::group_by(item) |>
    dplyr::slice_max(abs(loading), n = 1) |>
    dplyr::ungroup() |>
    dplyr::arrange(factor, dplyr::desc(abs(loading)))

  item_pos = tibble::tibble(item = home$item,
                            y = seq(0, 1, length.out = nrow(home)))
  fac_pos = tibble::tibble(
    factor = facs,
    y = if (length(facs) == 1) 0.5 else seq(0.15, 0.85, length.out = length(facs)))

  edges = L |>
    dplyr::left_join(item_pos, by = "item") |>
    dplyr::rename(y_item = y) |>
    dplyr::left_join(fac_pos, by = "factor") |>
    dplyr::rename(y_fac = y)

  fg = if (wise_dark()) "#e6e6e6" else "#1a1a1a"

  # The correlation between factors is a parameter of the model and belongs in
  #   the picture of it. Drawn as a curve to the left, the way a path diagram
  #   conventionally shows a covariance rather than a regression.
  psi = unclass(lavInspect(fit, "std")$psi)
  arcs = if (length(facs) > 1) {
    pr = t(utils::combn(facs, 2))
    tibble::tibble(a = pr[, 1], b = pr[, 2],
                   r = purrr::map2_dbl(pr[, 1], pr[, 2], function(x, y) psi[x, y])) |>
      dplyr::left_join(dplyr::rename(fac_pos, a = factor, ya = y), by = "a") |>
      dplyr::left_join(dplyr::rename(fac_pos, b = factor, yb = y), by = "b") |>
      dplyr::mutate(label = if (is.null(correlations)) sprintf("r = %.2f", r)
                    else purrr::map2_chr(a, b, function(x, y) {
                      row = dplyr::filter(correlations, a == x, b == y)
                      if (!nrow(row)) sprintf("r = %.2f", psi[x, y])
                      else sprintf("r = %.2f [%.2f, %.2f]", row$r, row$lo, row$hi)
                    }))
  } else NULL

  ggplot2::ggplot() +
    {if (!is.null(arcs)) list(
      ggplot2::geom_curve(
        data = arcs,
        ggplot2::aes(x = 0.06, xend = 0.06, y = ya, yend = yb),
        curvature = -0.9, linewidth = 0.5, colour = fg,
        arrow = grid::arrow(length = grid::unit(0.10, "cm"), ends = "both")),
      ggplot2::geom_label(
        data = arcs,
        ggplot2::aes(x = -0.06, y = (ya + yb) / 2, label = label),
        size = 3.6, linewidth = 0, fill = NA, colour = fg))} +
    ggplot2::geom_segment(
      data = edges,
      ggplot2::aes(x = 0.15, xend = 0.75, y = y_fac, yend = y_item,
                   linewidth = abs(loading), alpha = abs(loading),
                   colour = factor)) +
    ggplot2::geom_label(
      data = dplyr::filter(edges, abs(loading) >= salient),
      ggplot2::aes(x = 0.45, y = (y_fac + y_item) / 2,
                   label = sprintf("%.2f", loading)),
      size = 3.4, linewidth = 0, fill = NA, colour = fg) +
    ggplot2::geom_label(
      data = fac_pos, ggplot2::aes(x = 0.1, y = y, label = factor),
      size = 4.6, fontface = "bold", linewidth = 0.3, fill = NA, colour = fg) +
    ggplot2::geom_text(
      data = item_pos, ggplot2::aes(x = 0.8, y = y, label = item),
      hjust = 0, size = 4.0, colour = fg) +
    ggplot2::scale_linewidth(range = c(0.2, 2), guide = "none") +
    ggplot2::scale_alpha(range = c(0.15, 0.9), guide = "none") +
    ggplot2::scale_colour_viridis_d(name = NULL, end = 0.8) +
    ggplot2::scale_x_continuous(limits = c(-0.25, 1.35)) +
    ggplot2::labs(
      caption = paste("Line thickness is the standardised loading; values",
                      "shown at or above", salient,
                      ". The curve on the left is the correlation between the",
                      "factors -- how far the two things they measure travel",
                      "together.")) +
    wise_theme() +
    ggplot2::theme(axis.text = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.grid = ggplot2::element_blank())
}


# Section 3 draws item discrimination against range. They answer different
#   questions and a battery of mixed formats needs both: discrimination is
#   sensitive to shape and treats categories as unordered, which is what the
#   model does; range is what an analyst reads off a profile plot.

# An item low on both is carrying little. An item high on one and low on the
#   other is worth looking at rather than dropping.
#______________________________________________________________________________

plot_discrimination <- function(disc) {
  fg = if (wise_dark()) "#e6e6e6" else "#1a1a1a"

  disc |>
    dplyr::mutate(item = factor(item, levels = rev(item))) |>
    tidyr::pivot_longer(c(discrimination, range), names_to = "measure",
                        values_to = "value") |>
    dplyr::mutate(measure = dplyr::recode(
      measure,
      discrimination = "Separates the groups",
      range = "Spread across the scale")) |>
    ggplot2::ggplot(ggplot2::aes(value, item, colour = measure)) +
    ggplot2::geom_line(ggplot2::aes(group = item), colour = "grey60",
                       linewidth = 0.5) +
    ggplot2::geom_point(size = 3) +
    ggplot2::scale_x_continuous(limits = c(0, 1)) +
    ggplot2::scale_colour_viridis_d(name = NULL, end = 0.7) +
    ggplot2::labs(x = NULL, y = NULL,
                  caption = paste("Both are bounded at 0 and 1. An item low on",
                                  "both is carrying little; one high on a",
                                  "single measure is worth reading, not",
                                  "dropping.")) +
    wise_theme()
}

