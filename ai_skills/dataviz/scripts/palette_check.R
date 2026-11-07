# palette_check.R -- is a set of colours colourblind-safe?
#
# Source it:  intern_source_skill("dataviz", "palette_check.R")
#   palette_check(c("#E69F00", "#56B4E9", "red", "green"))
#
# Two checks, from cheap to thorough:
#   1. Is each colour from Okabe-Ito or a viridis-family palette?
#   2. If colorspace is installed: under simulated deuteranopia, protanopia
#      and tritanopia, how close are the two most similar colours? A minimum
#      CIE Lab distance (Delta E 1976) below about 10 means at least two
#      colours are hard to tell apart for some readers.
# Uses grDevices, purrr, dplyr, tibble, viridisLite; colorspace optionally.

OKABE_ITO_HEX <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2",
                   "#D55E00", "#CC79A7", "#000000")

# Every colour the perceptually uniform viridis options produce at 256 steps,
#   as #RRGGBB. Option "H" (turbo) is left out: it is a rainbow map and is not
#   colourblind-safe.
viridis_family_hex <- function()
  unique(unlist(purrr::map(c("A", "B", "C", "D", "E", "F", "G"), function(o)
    substr(viridisLite::viridis(256, option = o), 1, 7))))

# TRUE where a colour is within `tol` (0-255, per channel) of one in `family`.
#   viridis(5) and viridis(256) sample the same map at different points, so
#   an exact match would miss most real uses.
near_any <- function(hex, family, tol = 3) {
  fam = grDevices::col2rgb(family)
  purrr::map_lgl(hex, function(h)
    any(colSums(abs(fam - as.vector(grDevices::col2rgb(h))) <= tol) == 3))
}

as_hex <- function(cols) {
  rgb = grDevices::col2rgb(cols)
  grDevices::rgb(rgb[1, ], rgb[2, ], rgb[3, ], maxColorValue = 255)
}

min_delta_e <- function(hex) {
  if (length(hex) < 2) return(NA_real_)
  lab = grDevices::convertColor(t(grDevices::col2rgb(hex)) / 255, from = "sRGB", to = "Lab")
  pairs = utils::combn(seq_len(nrow(lab)), 2)
  min(purrr::map_dbl(seq_len(ncol(pairs)), function(j)
    sqrt(sum((lab[pairs[1, j], ] - lab[pairs[2, j], ])^2))))
}

# A tibble: one row per colour with where it comes from, plus attributes
#   `verdict` and `min_delta_e` (under each simulated deficiency).
palette_check <- function(cols, threshold = 10) {
  hex = toupper(as_hex(cols))
  source = dplyr::case_when(
    hex %in% OKABE_ITO_HEX ~ "okabe-ito",
    near_any(hex, viridis_family_hex()) ~ "viridis family",
    TRUE ~ "other")
  sims = if (requireNamespace("colorspace", quietly = TRUE)) c(
    normal = min_delta_e(hex),
    deutan = min_delta_e(as_hex(colorspace::deutan(hex))),
    protan = min_delta_e(as_hex(colorspace::protan(hex))),
    tritan = min_delta_e(as_hex(colorspace::tritan(hex))))
  ok_source = all(source != "other")
  ok_sim = is.null(sims) || all(is.na(sims)) || min(sims, na.rm = TRUE) >= threshold
  verdict = if (ok_source && ok_sim) "safe"
    else if (ok_sim && !is.null(sims)) "not a standard safe palette, but distinguishable in simulation"
    else if (!ok_sim) paste0("unsafe: two colours are within Delta E ", threshold,
                             " under simulated colour-vision deficiency")
    else "unknown: not a standard safe palette and colorspace is not installed"
  out = tibble::tibble(colour = cols, hex = hex, source = source)
  attr(out, "min_delta_e") = sims
  attr(out, "verdict") = verdict
  message("Palette: ", verdict)
  out
}
