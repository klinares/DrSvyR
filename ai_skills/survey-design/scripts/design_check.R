# design_check.R -- check design variables, build the design object, and
#   summarise it. Plain functions: data frame and specification in, tibbles
#   or a design object out. No printing, no global state, so a Shiny app or a
#   pipeline can call them directly.
#
# Source it:  intern_source_skill("survey-design", "design_check.R")
#
#   spec <- design_spec(ids = "dnum", weights = "pw", fpc = "fpc")
#   check_design_inputs(apiclus1, spec)
#   des <- build_design(apiclus1, spec)
#   design_summary(des)
#
# The checks report counts (how many strata, how many missing weights), never
#   respondents' values.
# Uses survey, dplyr, tibble, purrr, rlang, stats through pkg::fn().

# A design specification: column names as strings. Give either ids/strata/
#   fpc (Taylor linearisation) or repweights with type/scale/rscales from the
#   survey's documentation (replicate weights).
design_spec <- function(weights = NULL, ids = NULL, strata = NULL, fpc = NULL,
                        nest = FALSE, repweights = NULL, type = NULL, scale = NULL,
                        rscales = NULL, rho = NULL, mse = TRUE) {
  spec = list(weights = weights, ids = ids, strata = strata, fpc = fpc, nest = nest,
              repweights = repweights, type = type, scale = scale, rscales = rscales,
              rho = rho, mse = mse)
  structure(purrr::compact(spec), class = "design_spec")
}

check_row <- function(check, status, detail)
  tibble::tibble(check = check, status = status, detail = detail)

rep_columns <- function(data, spec)
  if (is.null(spec$repweights)) character(0) else grep(spec$repweights, names(data), value = TRUE)

check_weights <- function(w) {
  if (!is.numeric(w)) return(check_row("weights", "fail", "the weight column is not numeric"))
  n_na = sum(is.na(w))
  n_bad = sum(w <= 0, na.rm = TRUE)
  cv2 = stats::var(w, na.rm = TRUE) / mean(w, na.rm = TRUE)^2
  dplyr::bind_rows(
    check_row("weights missing", if (n_na) "fail" else "ok", paste(n_na, "missing")),
    check_row("weights positive", if (n_bad) "fail" else "ok",
              paste(n_bad, "zero or negative")),
    check_row("weighting effect", if (cv2 > 1) "warn" else "info",
              sprintf("Kish 1 + CV^2 = %.2f (variance inflation from unequal weights alone)",
                      1 + cv2)))
}

check_strata_psu <- function(data, spec) {
  s = spec$strata
  p = spec$ids[1]
  rows = list(
    if (!is.null(s)) check_row("strata missing", if (any(is.na(data[[s]]))) "fail" else "ok",
                               paste(sum(is.na(data[[s]])), "missing")),
    if (!is.null(p) && p != "1")
      check_row("PSUs missing", if (any(is.na(data[[p]]))) "fail" else "ok",
                paste(sum(is.na(data[[p]])), "missing")))
  if (!is.null(s) && !is.null(p) && p != "1") {
    pairs = dplyr::distinct(data, .s = .data[[s]], .p = .data[[p]])
    reused = pairs |> dplyr::count(.p) |> dplyr::filter(n > 1) |> nrow()
    per_stratum = pairs |> dplyr::count(.s)
    singles = sum(per_stratum$n == 1)
    rows = c(rows, list(
      check_row("PSUs nested in strata",
                if (reused && !isTRUE(spec$nest)) "fail" else "ok",
                if (reused) paste(reused, "PSU codes appear in more than one stratum",
                                  if (!isTRUE(spec$nest)) "-- set nest = TRUE" else "(nest = TRUE)")
                else "each PSU code belongs to one stratum"),
      check_row("strata with one PSU", if (singles) "warn" else "ok",
                paste0(singles, " of ", nrow(per_stratum), " strata",
                       if (singles) "; set options(survey.lonely.psu) or collapse strata, and say which" else ""))))
  }
  dplyr::bind_rows(purrr::compact(rows))
}

check_fpc <- function(data, spec) {
  f = data[[spec$fpc]]
  if (!is.numeric(f)) return(check_row("fpc", "fail", "the fpc column is not numeric"))
  fractions = all(f <= 1, na.rm = TRUE)
  varies = !is.null(spec$strata) &&
    any(dplyr::summarise(data, k = dplyr::n_distinct(.data[[spec$fpc]]),
                         .by = dplyr::all_of(spec$strata))$k > 1)
  dplyr::bind_rows(
    check_row("fpc form", "info", if (fractions) "values <= 1: read as sampling fractions"
              else "values > 1: read as population sizes"),
    if (varies) check_row("fpc constant within strata", "fail",
                          "fpc takes more than one value within a stratum"))
}

check_repweights <- function(data, spec) {
  cols = rep_columns(data, spec)
  dplyr::bind_rows(
    check_row("replicate weights found", if (length(cols)) "ok" else "fail",
              paste(length(cols), "columns match", spec$repweights)),
    if (length(cols)) check_row("replicate weights numeric",
                                if (all(purrr::map_lgl(data[cols], is.numeric))) "ok" else "fail",
                                "all replicate columns numeric"),
    check_row("replicate method", if (is.null(spec$type)) "fail" else "ok",
              if (is.null(spec$type)) "type is missing; take it (and scale, rscales) from the documentation"
              else paste("type", spec$type)))
}

# One row per check: check, status ("ok", "info", "warn", "fail"), detail.
check_design_inputs <- function(data, spec) {
  stopifnot(is.data.frame(data), inherits(spec, "design_spec"))
  named = setdiff(c(spec$weights, spec$ids, spec$strata, spec$fpc), "1")
  absent = setdiff(named, names(data))
  if (length(absent))
    return(check_row("variables present", "fail",
                     paste("not in the data:", paste(absent, collapse = ", "))))
  dplyr::bind_rows(
    check_row("variables present", "ok", paste(named, collapse = ", ")),
    if (!is.null(spec$weights)) check_weights(data[[spec$weights]])
    else check_row("weights", "warn", "no weight variable: estimates treat units as equally weighted"),
    check_strata_psu(data, spec),
    if (!is.null(spec$fpc)) check_fpc(data, spec),
    if (!is.null(spec$repweights)) check_repweights(data, spec))
}

one_sided <- function(vars) if (is.null(vars)) NULL else stats::reformulate(vars)

# A survey.design2 (Taylor linearisation) or svyrep.design from the spec.
build_design <- function(data, spec) {
  stopifnot(inherits(spec, "design_spec"))
  if (!is.null(spec$repweights)) {
    args = purrr::compact(list(data = data, weights = one_sided(spec$weights),
                               repweights = spec$repweights, type = spec$type,
                               scale = spec$scale, rscales = spec$rscales,
                               rho = spec$rho, mse = spec$mse))
    return(do.call(survey::svrepdesign, args))
  }
  args = purrr::compact(list(ids = one_sided(if (is.null(spec$ids)) "1" else spec$ids), strata = one_sided(spec$strata),
                             weights = one_sided(spec$weights), fpc = one_sided(spec$fpc),
                             nest = spec$nest, data = data))
  do.call(survey::svydesign, args)
}

# One row describing the design.
design_summary <- function(des) {
  rep = inherits(des, "svyrep.design")
  w = if (rep) stats::weights(des, "sampling") else stats::weights(des)
  tibble::tibble(
    rows = nrow(des$variables),
    variance = if (rep) paste("replicate weights,", des$type) else "Taylor linearisation",
    strata = if (rep) NA_integer_ else length(unique(des$strata[[1]])),
    psus = if (rep) NA_integer_ else nrow(unique(des$cluster[1])),
    replicates = if (rep) length(des$rscales) else NA_integer_,
    design_df = survey::degf(des),
    sum_weights = sum(w))
}
