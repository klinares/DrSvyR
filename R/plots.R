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


# ---- making text fit inside a figure ------------------------------------

# ggplot clips. A facet strip label wider than its panel is cut off mid-word, a
#   horizontal legend wider than the device is cropped at both ends, and a
#   caption longer than the device is cut off at the right. None of the three
#   wraps and none of them shrinks, and all three were happening in the
#   report: segment names truncated above every panel, a five-entry legend
#   showing three entries, a caption ending mid-sentence.

# There is no way to ask ggplot how wide a panel will be before it is drawn, so
#   this predicts it from the width the report renders at. The constants were
#   measured off the rendered PNGs at 150 dpi rather than guessed: an axis
#   label runs about 0.090 inches per character at 11pt, a bold strip label
#   about 0.068 at the reduced size these figures use. They are deliberately
#   generous -- a strip wrapped one word early costs a line, a strip wrapped one
#   word late loses the word.
FIG_WIDTH_IN    <- 6.4    # what the report renders at; the Word copy is 6.0
FIG_Y_CHAR_IN   <- 0.090
FIG_STRIP_CHAR_IN <- 0.068
FIG_KEY_IN      <- 0.35   # one legend key plus the gap after it

# Characters that fit across one facet panel, given what the y axis is
#   spending on its own labels.
panel_wrap <- function(y_labels, ncol, width = FIG_WIDTH_IN) {
  y_in = if (!length(y_labels)) 0 else
    max(nchar(unlist(strsplit(as.character(y_labels), "\n")))) * FIG_Y_CHAR_IN
  # Five per cent held back. Without it the widest case lands within a
  #   thirtieth of an inch of the panel edge, and a strip that wraps one word
  #   early costs a line while one that wraps one word late loses the word.
  usable = 0.95 * max(1.2, width - y_in - 0.60)
  chars = floor((usable / max(1L, as.integer(ncol))) / FIG_STRIP_CHAR_IN)
  as.integer(max(10L, min(40L, chars)))
}

# Rows a horizontal legend needs. One row is what ggplot does and one row is
#   what it clips.
legend_rows <- function(labels, width = FIG_WIDTH_IN) {
  if (!length(labels)) return(1L)
  need = sum(nchar(as.character(labels))) * FIG_Y_CHAR_IN +
         length(labels) * FIG_KEY_IN
  as.integer(max(1L, min(4L, ceiling(need / max(2, width - 0.4)))))
}

# A caption is one text element and ggplot draws it on one line however long it
#   is, so anything past the device edge is simply gone. Every caption in this
#   file and the three others goes through here.
FIG_CAPTION_CHARS <- 78L

fig_caption <- function(...)
  stringr::str_wrap(paste(...), width = FIG_CAPTION_CHARS)

# How many lines a set of labels takes once wrapped, which is what a figure's
#   height has to make room for.
wrap_lines <- function(labels, width) {
  if (!length(labels)) return(1L)
  as.integer(max(vapply(
    strsplit(stringr::str_wrap(as.character(labels), width), "\n"),
    length, integer(1))))
}

wise_theme <- function(base_size = 14) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background   = element_rect(fill = NA, colour = NA),
      panel.background  = element_rect(fill = NA, colour = NA),
      legend.background = element_rect(fill = NA, colour = NA),
      legend.key        = element_rect(fill = NA, colour = NA),

      # Both directions by default. Half these figures are horizontal -- the
      #   domain estimates, the profiles, the discrimination plot -- and on
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
         caption = fig_caption(
           "Both are bounded at 0 and 1. An item low on both is carrying",
           "little; one high on a single measure is worth reading, not",
           "dropping.")) +
    wise_theme()
}
