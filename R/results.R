# results.R for DrSvyR
# Scoring, domain estimation, and everything written out.

#   1. Scoring
#   2. Domain estimation
#   3. The delivered data file and tables
#   4. The report


#   1. The class arm
#   2. The factor arm
#   3. Coverage and assignment quality

# The measurement model is fitted on people who answered every item. Scoring
#   extends past that, because item nonresponse is not random and restricting
#   the domain estimates to complete responders selects on the composition being
#   measured. What that extension costs is reported rather than assumed away.

# Requires: dplyr, purrr, tibble, ggplot2


# Section 1 scores from the fitted class model. A missing answer contributes
#   nothing to that respondent's product, so a partial responder is scored from
#   the items they did answer, gated by how many that was.
#______________________________________________________________________________

score_lca <- function(state) {
  cfg = state$cfg
  fr = state$item_frame

  frame = dplyr::bind_cols(state$design_dat, fr$item_dat, state$demo_dat)
  pred = predict_segments(frame, state$model$fit, cfg$items, cfg$min_items)

  dplyr::bind_cols(frame, pred) |>
    dplyr::mutate(in_analysis = fr$in_analysis)
}


# Section 2 scores from the fitted factor model.
#______________________________________________________________________________

# Closed form rather than lavPredict, because lavPredict deletes any case with
#   a missing indicator and that is the population this stage exists to reach.
#   Subsetting the rows of Lambda and Theta to the items a respondent answered
#   scores them from what they gave.

#   Bartlett:   A = (L' Ti L)^-1 L' Ti
#   Regression: A = Phi L' Si^-1,   Si = L Phi L' + Theta

# Only valid under ML with continuous indicators. Under WLSMV the parameters
#   are on the underlying-response scale with thresholds and no intercepts, so
#   the formula does not apply and scoring falls back to complete responders.
factor_scores <- function(fit, newdata, method = c("Bartlett", "regression")) {
  method = match.arg(method)
  est = lavInspect(fit, "est")
  lam = est$lambda
  th  = est$theta
  phi = est$psi
  nu  = as.numeric(est$nu)
  items = rownames(lam)

  Y = as.matrix(dplyr::mutate(newdata[items],
                              dplyr::across(dplyr::everything(), as.numeric)))
  pat = apply(!is.na(Y), 1, paste, collapse = "")
  out = matrix(NA_real_, nrow(Y), ncol(lam),
               dimnames = list(NULL, colnames(lam)))

  purrr::walk(unique(pat), function(p) {
    rows = which(pat == p)
    obs = which(!is.na(Y[rows[1], ]))
    if (length(obs) < ncol(lam)) return()

    L = lam[obs, , drop = FALSE]
    T_o = th[obs, obs, drop = FALSE]

    A = try({
      if (method == "Bartlett") {
        Ti = solve(T_o)
        solve(t(L) %*% Ti %*% L) %*% t(L) %*% Ti
      } else {
        Si = solve(L %*% phi %*% t(L) + T_o)
        phi %*% t(L) %*% Si
      }
    }, silent = TRUE)
    if (inherits(A, "try-error")) return()

    out[rows, ] <<- sweep(Y[rows, obs, drop = FALSE], 2, nu[obs], "-") %*% t(A)
  })
  out
}

score_cfa <- function(state) {
  cfg = state$cfg
  fr = state$item_frame
  fit = state$model$fit
  frame = dplyr::bind_cols(state$design_dat, fr$item_dat, state$demo_dat)

  ml = identical(cfg$estimator, "ML")

  if (ml) {
    FS  = factor_scores(fit, frame, "Bartlett")
    FSr = factor_scores(fit, frame, "regression")
  } else {
    # Complete responders only. lavPredict returns NA rows for anyone with a
    #   missing indicator, and the closed form is not available on this scale.
    FS  = matrix(NA_real_, nrow(frame), length(state$labels$target),
                 dimnames = list(NULL, state$labels$target))
    FSr = FS
    idx = which(fr$in_analysis)
    p1 = lavPredict(fit, method = "Bartlett")
    p2 = lavPredict(fit, method = "regression")

    # The rows lavaan used and the rows in_analysis marks are assumed to be
    #   the same set, in the same order. They are today. If lavaan ever drops
    #   a case -- a weight it will not take, a stratum it cannot use -- the
    #   assignment below fails with a message about replacement lengths that
    #   names nothing, halfway through a long run. Checked here, where the
    #   message can say what actually disagreed.
    if (nrow(p1) != length(idx) || nrow(p2) != length(idx))
      stop("lavaan returned scores for ", nrow(p1), " cases but ",
           length(idx), " were selected for the measurement model. The ",
           "estimation sample and the item frame disagree, so scores cannot ",
           "be aligned to respondents. Check the design variables on the ",
           "analysis frame before trusting anything downstream.", call. = FALSE)

    FS[idx, ] = as.matrix(p1)
    FSr[idx, ] = as.matrix(p2)
  }

  n_answered = rowSums(!is.na(fr$item_dat))
  keep = complete.cases(FS)

  dplyr::bind_cols(
    frame,
    tibble::as_tibble(FS),
    tibble::as_tibble(FSr) |>
      rlang::set_names(paste0(colnames(FSr), "_reg")),
    tibble::tibble(n_items_answered = n_answered,
                   scored = keep)) |>
    dplyr::mutate(in_analysis = fr$in_analysis)
}


# Section 3 says who was reached and how well. Respondents scored from fewer
#   items carry more classification error: a processing error whose magnitude
#   depends on an item nonresponse error, which is the correlated-error case
#   the total survey error framework flags.
#______________________________________________________________________________

# Two ways to end up without a score, and they mean different things. Too few
#   answers is item nonresponse, which the minimum-items rule governs and which
#   the analyst set. A respondent who was in the measurement model and still
#   came back without a score is one the estimator could not place -- rare, and
#   never a random rare: in the factor arm they sit at the floor or the ceiling
#   of nearly every item, which is to say at the extremes of the thing being
#   measured. Reporting that as an unexplained shortfall in a total understates
#   a small selection on the construct.
score_coverage <- function(scored, arm, n_items) {
  reached = if (identical(arm, "lca")) !is.na(scored$segment) else scored$scored
  in_model = scored$in_analysis

  out = tibble::tibble(
    group = c("In the file",
              "Fitted the measurement model",
              "Scored",
              "Not scored: too few answers",
              "Not scored: the model returned none"),
    n = c(nrow(scored),
          sum(in_model),
          sum(reached),
          sum(!reached & !in_model),
          sum(!reached & in_model))) |>
    dplyr::mutate(percent = round(100 * n / nrow(scored), 1))

  # A reason that did not apply is noise; the three headline rows always stay
  #   so the table has the same shape whether or not anything went wrong.
  dplyr::filter(out, n > 0 | !startsWith(group, "Not scored"))
}

# Assignment quality against how many items a respondent answered. If the mean
#   falls sharply at the low end, the floor is set too low and those scores are
#   carrying more error than the rest.
assignment_quality <- function(scored, arm) {
  if (!identical(arm, "lca")) return(NULL)

  scored |>
    dplyr::filter(!is.na(segment)) |>
    dplyr::group_by(n_items_answered) |>
    dplyr::summarise(n = dplyr::n(),
                     mean_certainty = round(mean(max_posterior), 3),
                     .groups = "drop") |>
    dplyr::arrange(n_items_answered)
}

plot_assignment_quality <- function(q) {
  ggplot2::ggplot(q, ggplot2::aes(n_items_answered, mean_certainty)) +
    ggplot2::geom_line(linewidth = 0.8, colour = viridis::viridis(1)) +
    ggplot2::geom_point(ggplot2::aes(size = n), colour = viridis::viridis(1)) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::scale_size(name = "Respondents") +
    ggplot2::labs(x = "Items answered", y = "Certainty of assignment",
                  caption = paste("A sharp fall at the low end means those",
                                  "respondents are being placed on too little",
                                  "information.")) +
    wise_theme()
}

# Where the groups sit, unweighted and design-weighted. The first thing the
#   analyst sees after scoring, and the first place weighting visibly does
#   something.
group_shares <- function(scored, arm, labels, rep_des) {
  if (!identical(arm, "lca")) return(NULL)

  raw = scored |>
    dplyr::filter(!is.na(segment)) |>
    dplyr::count(segment, name = "n") |>
    dplyr::mutate(unweighted = round(n / sum(n), 3))

  m = survey::svymean(~ factor(segment), rep_des, na.rm = TRUE)

  raw |>
    dplyr::mutate(weighted = round(as.numeric(coef(m)), 3),
                  se = round(as.numeric(survey::SE(m)), 3),
                  group = labels$Label[segment]) |>
    dplyr::select(segment, group, n, unweighted, weighted, se)
}



#   1. Marginals
#   2. The class arm: three estimators
#   3. The factor arm: three estimators
#   4. Which differences the analysis resolves
#   5. Plots

# Each domain quantity is reported three ways so the two corrections can be read
#   separately. Unweighted ignores the design. Design-based applies the weights
#   and takes its variance from the replicates. The third removes the
#   attenuation the assignment step introduces. The gap from the first to the
#   second is what ignoring the design costs; the gap from the second to the
#   third is what the assignment costs.

# Requires: survey, dplyr, purrr, tibble, tidyr, ggplot2


# Section 1
#______________________________________________________________________________

domain_marginals <- function(scored, aux, rep_des) {
  purrr::map(aux, function(v) {
    m = survey::svymean(reformulate(v), rep_des, na.rm = TRUE)
    raw = scored |>
      dplyr::filter(!is.na(.data[[v]])) |>
      dplyr::count(.data[[v]], name = "n") |>
      rlang::set_names(c("level", "n"))
    tibble::tibble(variable = v,
                   level = stringr::str_remove(names(coef(m)), paste0("^", v)),
                   weighted = as.numeric(coef(m)),
                   se = as.numeric(survey::SE(m))) |>
      dplyr::left_join(dplyr::mutate(raw, level = as.character(level)),
                       by = "level")
  }) |>
    purrr::list_rbind()
}


# Section 2 is the class arm. The quantity is the share of each domain level
#   falling in each segment.
#______________________________________________________________________________

# Modal assignment is an error-prone measurement of true segment, and
#   cross-tabbing it against anything pulls the association toward the marginal.
#   BCH replaces each respondent's hard assignment by a row of the inverse
#   classification table.

# Posteriors and modal assignment stay at their full-sample values; the
#   classification table and the correction weights are rebuilt inside every
#   replicate, so the intervals carry the design variance of the classification
#   table and the cross-tab together rather than treating the first as known.

domains_lca <- function(state, tick = NULL) {
  cfg = state$cfg
  scored = dplyr::filter(state$scored, !is.na(segment))
  des = state$score_design$des
  rep_des = state$score_design$rep_des
  K = state$dimension
  crit = qt(0.975, degf(rep_des))
  post_cols = paste0("post_segment", seq_len(K))

  # Unweighted: a plain cross-tab with binomial standard errors, as if the
  #   respondents had been drawn independently.
  naive = purrr::map(cfg$aux, function(v) {
    scored |>
      dplyr::filter(!is.na(.data[[v]])) |>
      dplyr::count(level = as.character(.data[[v]]), segment, name = "n") |>
      tidyr::complete(level, segment = seq_len(K), fill = list(n = 0L)) |>
      dplyr::group_by(level) |>
      dplyr::mutate(nn = sum(n), p = n / nn,
                    se = sqrt(pmax(p * (1 - p), 0) / nn)) |>
      dplyr::ungroup() |>
      dplyr::transmute(variable = v, level, segment, p, se)
  }) |> purrr::list_rbind()

  # 1.96 rather than the design t: this row is a binomial standard error on a
  #   plain cross-tab and carries no design degrees of freedom. The logit
  #   construction is the same one used for every other probability here.
  naive = dplyr::bind_cols(naive, share_ci(naive$p, naive$se, 1.96))

  if (!is.null(tick)) tick("design-based")

  # svyby splits the design by the domain and runs svymean of the segment
  #   factor inside each level. Columns are read by position because svyby's
  #   naming for a factor outcome varies by version.
  design = purrr::map(cfg$aux, function(v) {
    sb = as.data.frame(survey::svyby(~ factor(segment), reformulate(v), rep_des,
                                     survey::svymean, na.rm = TRUE))
    vals = sb[, -1, drop = FALSE]
    stopifnot(ncol(vals) == 2 * K)
    tibble::tibble(variable = v,
                   level = rep(as.character(sb[[1]]), times = K),
                   segment = rep(seq_len(K), each = nrow(sb)),
                   p = as.numeric(as.matrix(vals[, seq_len(K)])),
                   se = as.numeric(as.matrix(vals[, K + seq_len(K)])))
  }) |>
    purrr::list_rbind() |>
    dplyr::filter(!is.na(level))
  design = dplyr::bind_cols(design, share_ci(design$p, design$se, crit))

  if (!is.null(tick)) tick("corrected")

  P_fixed = as.matrix(scored[, post_cols, drop = FALSE])
  modal_fixed = as.integer(scored$segment)

  meta = purrr::map(cfg$aux, function(v)
    tidyr::expand_grid(level = levels(scored[[v]]), segment = seq_len(K)) |>
      dplyr::mutate(variable = v)) |>
    purrr::list_rbind() |>
    dplyr::mutate(idx = dplyr::row_number())

  # The indicator matrix for each domain is a property of the respondents, not
  #   of the replicate weights, so it is built once rather than eighty-four
  #   times. Same matrices, same answer, a fraction of the allocation.
  M_list = purrr::map(cfg$aux, function(v) {
    M = outer(as.character(scored[[v]]), levels(scored[[v]]), "==") + 0
    M[is.na(M)] = 0
    M
  })

  theta = function(w_rep) {
    wU = w_rep * bch_weights(P_fixed, modal_fixed, w_rep)
    unlist(purrr::map(M_list, function(M)
      as.vector(t(crossprod(M, wU) / as.numeric(crossprod(M, w_rep))))),
      use.names = FALSE)
  }

  est = theta(weights(des, "sampling"))
  V = replicate_variance(rep_des, theta, est)
  se = sqrt(diag(V))
  stopifnot(length(est) == nrow(meta))

  # Not truncated. The correction can legitimately place a share outside
  #   [0, 1] and clipping it to the boundary would report a number the
  #   estimator did not produce. Those rows come back flagged and the report
  #   marks them, which is what the reference workflow does.
  corrected = meta |>
    dplyr::mutate(p = as.numeric(est), se = as.numeric(se))
  corrected = dplyr::bind_cols(
    corrected, share_ci(corrected$p, corrected$se, crit,
                        transform = FALSE, truncate = FALSE)) |>
    dplyr::select(variable, level, segment, p, se, lo, hi, boundary)

  # Wald contrasts run on the design-based estimator deliberately. Modal
  #   assignment attenuates differences, so a pair resolved there separates
  #   despite the classification error, and the corrected column can only
  #   widen it.
  # Both the domain indicators and the assignment indicator are fixed across
  #   replicates. Only the weights move.
  Z_fixed = outer(modal_fixed, seq_len(K), "==") + 0

  wald_theta = function(w_rep) {
    unlist(purrr::map(M_list, function(M)
      as.vector(t(crossprod(M, w_rep * Z_fixed) /
                  as.numeric(crossprod(M, w_rep))))),
      use.names = FALSE)
  }
  w_est = wald_theta(weights(des, "sampling"))
  w_V = replicate_variance(rep_des, wald_theta, w_est)

  list(dom = dplyr::bind_rows(
         dplyr::mutate(naive, estimator = "Unweighted"),
         dplyr::mutate(design, estimator = "Design-based"),
         dplyr::mutate(corrected, estimator = "Corrected")) |>
         # The quantity here is a share, so 0 and 1 mean something and a value
         #   outside them is worth marking. In the factor arm it is a mean on a
         #   scale centred at zero, where a negative number is ordinary.
         dplyr::mutate(share = TRUE,
                       estimator = factor(
           estimator, levels = c("Unweighted", "Design-based", "Corrected"))),
       wald = list(est = w_est, V = w_V, meta = meta, df = degf(rep_des)),
       values_header = "Share of each level falling in each segment:")
}


# Section 3 is the factor arm. The quantity is the mean position of each domain
#   level on the factor.
#______________________________________________________________________________

# The correction here is the choice of score rather than a classification
#   table. Regression scores are shrunk toward the grand mean by the factor's
#   reliability, which pulls group means together; Bartlett scores remove that
#   shrinkage at the cost of more error variance. So the third column is the
#   Bartlett mean, and the gap from the second says what the shrinkage cost.

domains_cfa <- function(state, tick = NULL) {
  cfg = state$cfg
  scored = dplyr::filter(state$scored, scored)
  rep_des = state$score_design$rep_des
  facs = state$labels$target
  crit = qt(0.975, degf(rep_des))

  by_est = function(col_of, label, weighted) {
    purrr::map(cfg$aux, function(v) {
      purrr::map(seq_along(facs), function(k) {
        fn = col_of(facs[k])
        if (weighted) {
          sb = as.data.frame(survey::svyby(reformulate(fn), reformulate(v),
                                           rep_des, survey::svymean,
                                           na.rm = TRUE))
          tibble::tibble(variable = v, level = as.character(sb[[1]]),
                         segment = k, p = sb[[2]], se = sb[[3]])
        } else {
          scored |>
            dplyr::filter(!is.na(.data[[v]]), !is.na(.data[[fn]])) |>
            dplyr::group_by(level = as.character(.data[[v]])) |>
            dplyr::summarise(p = mean(.data[[fn]]),
                             se = stats::sd(.data[[fn]]) / sqrt(dplyr::n()),
                             .groups = "drop") |>
            dplyr::mutate(variable = v, segment = k)
        }
      }) |> purrr::list_rbind()
    }) |>
      purrr::list_rbind() |>
      # A factor-score mean is unbounded and centred on the population
      #   average, so a Wald interval is the correct one and there is nothing
      #   to transform. boundary is carried so the two arms share a shape.
      dplyr::mutate(lo = p - crit * se, hi = p + crit * se,
                    boundary = FALSE, estimator = label)
  }

  if (!is.null(tick)) tick("unweighted")
  naive = by_est(function(f) paste0(f, "_reg"), "Unweighted", FALSE)
  if (!is.null(tick)) tick("design-based")
  design = by_est(function(f) paste0(f, "_reg"), "Design-based", TRUE)
  if (!is.null(tick)) tick("corrected")
  corrected = by_est(function(f) f, "Corrected", TRUE)

  meta = purrr::map(cfg$aux, function(v)
    tidyr::expand_grid(level = levels(scored[[v]]),
                       segment = seq_along(facs)) |>
      dplyr::mutate(variable = v)) |>
    purrr::list_rbind() |>
    dplyr::mutate(idx = dplyr::row_number())

  list(dom = dplyr::bind_rows(naive, design, corrected) |>
         dplyr::mutate(share = FALSE,
                       estimator = factor(
           estimator, levels = c("Unweighted", "Design-based", "Corrected"))),
       wald = NULL,
       values_header = "Mean position of each level on the factor:")
}


# Section 4 works out which pairs of levels the analysis actually resolves,
#   here rather than by the model. With the replicate covariance available it
#   is a design-based Wald test on the difference, Holm-adjusted within the
#   domain. Without it, the fallback is intervals that do not overlap, which is
#   more conservative than a test.
#______________________________________________________________________________

resolved_pairs <- function(res, variable, labels, alpha = 0.05) {
  domain_separations(res$dom, variable, labels,
                     est = "Design-based", wald = res$wald, alpha = alpha)
}


# Section 5
#______________________________________________________________________________

# A factor score is centred so that zero is the population average, which means
#   half the group means are negative and none of that is a problem. The axis
#   has to say so: a table of negative numbers with no anchor reads as an error.
plot_domain <- function(dom, variable, labels, arm) {
  d = dom |>
    dplyr::filter(variable == !!variable) |>
    dplyr::mutate(group = labels[segment])

  lca = identical(arm, "lca")

  p = ggplot2::ggplot(d, ggplot2::aes(p, level, colour = estimator))

  if (!lca)
    p = p + ggplot2::geom_vline(xintercept = 0, linetype = 2,
                                colour = "grey55")

  p +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = lo, xmax = hi),
                           orientation = "y", width = 0.3, linewidth = 0.7,
                           position = ggplot2::position_dodge(width = 0.6)) +
    ggplot2::geom_point(size = 2.6,
                        position = ggplot2::position_dodge(width = 0.6)) +
    ggplot2::facet_wrap(~ group, scales = "free_x") +
    ggplot2::scale_colour_viridis_d(name = NULL, end = 0.8) +
    ggplot2::labs(
      x = if (lca) "Share of the level falling in this group"
          else "Position on the factor, relative to the population average",
      y = NULL,
      caption = paste(
        if (lca) "" else
          paste("Zero is the population average, so a negative value means",
                "below average and is not a problem in itself."),
        "Bars are 95% intervals. The unweighted row ignores the survey design",
        "and its interval is not to be believed; it is shown so the",
        "difference is visible.")) +
    wise_theme(base_size = 13) +
    ggplot2::theme(strip.text = ggplot2::element_text(
      face = "bold", size = ggplot2::rel(1.0)))
}



#   1. The delivered data file
#   2. Tables
#   3. The report

# Three kinds of output. A data file the analyst opens in the software they
#   already use, carrying everything the source file had plus what the model
#   found. Tables as CSV, because that is what gets pasted into other work. And
#   a report that is source material for someone writing to policymakers, not a
#   finished argument.

# Requires: haven, readr, dplyr, purrr, officer, flextable, fs


# Section 1 delivers the data.
#______________________________________________________________________________

# Everything from the source file is carried over and the new columns are
#   appended, so the analyst is not asked to join anything.

# The posteriors and the correction weights travel with the assignment, not
#   instead of it. Cross-tabulating a modal assignment on its own reintroduces
#   exactly the attenuation the corrected column removes, and the variable
#   label says so, because that is the one place a reader will look.

export_data <- function(state, format = c("sav", "dta")) {
  format = match.arg(format)
  cfg = state$cfg
  arm = cfg$arm

  new_cols = if (identical(arm, "lca")) {
    state$scored |>
      dplyr::select(id, segment, max_posterior, n_items_answered,
                    dplyr::starts_with("post_segment")) |>
      dplyr::mutate(
        segment = haven::labelled(
          as.integer(segment),
          labels = rlang::set_names(seq_len(nrow(state$labels)),
                                    state$labels$Label),
          label = paste("Segment. Modal assignment: it is an error-prone",
                        "measurement and cross-tabulating it alone",
                        "understates group differences. Use the posterior",
                        "columns for anything beyond description.")),
        max_posterior = haven::labelled(
          max_posterior,
          label = "Certainty of the assignment (0 to 1)"),
        n_items_answered = haven::labelled(
          as.integer(n_items_answered),
          label = "Items answered in the battery"))
  } else {
    facs = state$labels$target
    state$scored |>
      dplyr::select(id, dplyr::all_of(c(facs, paste0(facs, "_reg"))),
                    n_items_answered) |>
      dplyr::rename_with(function(x) paste0("score_", x),
                         dplyr::all_of(facs))
  }

  out = state$raw |>
    dplyr::mutate(.wise_id = as.numeric(unclass(
      state$raw[[state$design_map[["id"]]]]))) |>
    dplyr::left_join(dplyr::rename(new_cols, .wise_id = id), by = ".wise_id") |>
    dplyr::select(-.wise_id)

  path = wise_path("output", arm,
                   paste0(fs::path_ext_remove(fs::path_file(state$data_file)),
                          "_wise.", format))

  # write_sav and write_dta both cap name and label lengths, and a generated
  #   label can exceed them. Failing here after a long run is avoidable.
  # SPSS caps names at 32 characters and two source columns can collide once
  #   truncated. Left alone the second silently overwrites the first in the
  #   delivered file, which is the kind of thing an analyst discovers months
  #   later while wondering why a variable looks wrong.
  nm = substr(names(out), 1, 32)
  if (anyDuplicated(nm)) {
    clash = unique(nm[duplicated(nm)])
    nm = substr(make.unique(nm, sep = "_"), 1, 32)
    warning("Variable names collided after truncation and were made unique: ",
            paste(clash, collapse = ", "), call. = FALSE)
  }
  names(out) = nm
  if (identical(format, "sav")) haven::write_sav(out, path)
  else haven::write_dta(out, path)

  path
}


# Section 2 writes the tables. Excel's CSV reader assumes the system codepage
#   unless there is a byte order mark, so accented response labels arrive as
#   mojibake and the analyst concludes the pipeline is broken.
#______________________________________________________________________________

export_tables <- function(state) {
  d = wise_path("output", state$cfg$arm)
  w = function(x, nm) {
    if (is.null(x) || !nrow(x)) return(NULL)
    p = fs::path(d, paste0(nm, ".csv"))
    readr::write_excel_csv(x, p)
    p
  }

  purrr::compact(list(
    w(state$domains$dom, "domain_estimates"),
    w(state$domains$marg, "domain_marginals"),
    w(state$labels, "labels"),
    w(state$coverage, "scoring_coverage"),
    w(state$shares, "group_shares"),
    w(state$quality, "assignment_quality"),
    w(state$design_checks, "design_checks"),
    w(state$recode_audit, "recode_audit"),
    w(if (identical(state$cfg$arm, "lca")) state$measure$shares
      else state$measure$loadings, "measurement_model"),
    w(if (identical(state$cfg$arm, "lca")) state$measure$probs
      else state$measure$correlations, "measurement_detail")))
}



# Section 3 builds the document.
#______________________________________________________________________________

# One document, two audiences. The main flow reads for a manager: what was
#   asked, what was found, how far to trust it. Technical detail sits in boxes
#   a manager can skip and a survey statistician will want. Everything
#   exhaustive is in the appendices.

# Written once as a list of blocks and rendered twice -- to the screen for
#   review and to Word for keeping. If the two were built separately they would
#   drift, and what was approved would not be what was saved.

# autofit() sizes columns to their content and lets the table run off the page.
#   set_table_properties(width = 1) sizes it to the available width instead,
#   which is what stops the truncation.
wise_table <- function(df, caption = NULL, size = 9) {
  ft = flextable::flextable(df)
  ft = flextable::fontsize(ft, size = size, part = "all")
  ft = flextable::bold(ft, part = "header")
  ft = flextable::theme_booktabs(ft)
  ft = flextable::padding(ft, padding.top = 2, padding.bottom = 2, part = "all")
  ft = flextable::valign(ft, valign = "top", part = "all")
  ft = flextable::set_table_properties(ft, layout = "autofit", width = 1)
  if (!is.null(caption)) ft = flextable::set_caption(ft, caption)
  ft
}

# The three estimators as columns rather than rows. A reader compares them
#   across a row, which is also three times fewer rows on the page.
domain_wide <- function(dom, variable, labels) {
  # Older result objects predate these columns. Absent means nothing to mark,
  #   which is the safe default in both directions.
  if (!"boundary" %in% names(dom)) dom$boundary = FALSE
  if (!"share" %in% names(dom)) dom$share = FALSE

  dom |>
    dplyr::filter(variable == !!variable) |>
    dplyr::mutate(Group = labels[segment],
                  # Only where the quantity is a share. A factor score of
                  #   -0.094 is the population average less 0.094 and there is
                  #   nothing out of range about it; marking those as though
                  #   they had left [0, 1] tells the reader something false.
                  outside = dplyr::coalesce(share, FALSE) &
                            (dplyr::coalesce(boundary, FALSE) |
                             lo < 0 | hi > 1),
                  cell = sprintf("%.3f [%.3f, %.3f]%s", p, lo, hi,
                                 dplyr::if_else(outside, "\u2020", ""))) |>
    dplyr::select(Group, Level = level, estimator, cell) |>
    tidyr::pivot_wider(names_from = estimator, values_from = cell) |>
    dplyr::arrange(Group, Level)
}

# Tables and figures refer to items by their variable name, because that is
#   what the analyst will look up in their own files. Anyone reading the report
#   needs to be able to turn "b4" back into a question without leaving the page.
dictionary_table <- function(state) {
  state$item_frame$dictionary |>
    dplyr::transmute(
      Code = variable,
      Name = item,
      Question = question,
      Answers = purrr::map_chr(responses, function(r)
        paste(seq_along(r), r, sep = " = ", collapse = "; ")))
}

# Two or three concrete things that make this group what it is, taken from the
#   fitted profile rather than from the drafted name. The name is a summary
#   somebody wrote; these are the numbers it is supposed to summarise, and a
#   reader who distrusts the first can check it against the second.
# The variable name in parentheses exists for a battery whose items were
#   renamed on the way in. When they were not, "b21 (b21)" reads as a mistake
#   in a document somebody is about to circulate.
item_label <- function(item, variable) {
  if (identical(as.character(item), as.character(variable)))
    as.character(item)
  else paste0(item, " (", variable, ")")
}

segment_evidence <- function(state, k, n = 3L) {
  lca = identical(state$cfg$arm, "lca")
  dict = state$item_frame$dictionary

  if (lca) {
    prof = if (!is.null(state$measure))
      dplyr::filter(state$measure$profile, group == k)
    else
      dplyr::filter(profile_frame(state$model$fit, state$cfg$items),
                    group == paste0("Group ", k)) |>
        dplyr::rename(item = item, value = value)

    # Distinctiveness, not level: an item where this group sits where everyone
    #   else does says nothing about who they are.
    all_prof = if (!is.null(state$measure)) state$measure$profile
               else profile_frame(state$model$fit, state$cfg$items) |>
                 dplyr::mutate(group = as.integer(gsub("\\D", "", group)))
    avg = all_prof |>
      dplyr::group_by(item) |>
      dplyr::summarise(mid = mean(value), .groups = "drop")

    top = prof |>
      dplyr::left_join(avg, by = "item") |>
      dplyr::mutate(gap = value - mid) |>
      dplyr::arrange(dplyr::desc(abs(gap))) |>
      head(n)

    purrr::map_chr(seq_len(nrow(top)), function(i) {
      d = dplyr::filter(dict, item == top$item[i])
      sprintf("%s — answers %s than average on “%s”",
              item_label(top$item[i], d$variable),
              if (top$gap[i] > 0) "notably higher" else "notably lower",
              d$question)
    })
  } else {
    fn = state$labels$target[k]
    src = if (!is.null(state$measure)) state$measure$loadings
          else state$model$diag$loadings
    top = src |>
      dplyr::filter(factor == fn) |>
      dplyr::arrange(dplyr::desc(abs(loading))) |>
      head(n)

    # Only the first of these is the closest. Saying so about all three reads
    #   as three superlatives that cannot all be true.
    purrr::map_chr(seq_len(nrow(top)), function(i) {
      d = dplyr::filter(dict, item == top$item[i])
      sprintf("%s %s at %.2f — “%s”",
              item_label(top$item[i], d$variable),
              if (i == 1L) "tracks the scale most closely," else "also tracks it,",
              top$loading[i], d$question)
    })
  }
}

# The diagnostics, compressed. An analyst wants the results; a report that says
#   nothing about how well the model worked is not one you can act on either.
#   Generated from the numbers rather than written by a model, so the wording
#   cannot drift and cannot overstate.
# A report is a document somebody publishes from, and "1 contribute little" or
#   "2 round(s)" is the kind of thing a reader notices before the finding.
n_verb <- function(n, singular, plural)
  paste0(n, " ", if (n == 1L) singular else plural)

diagnostic_sentences <- function(state) {
  lca = identical(state$cfg$arm, "lca")
  d = state$model$diag
  out = character(0)

  if (lca) {
    e = d$entropy
    out = c(out, sprintf(
      paste("The %d segments separate respondents %s: on a scale where 1 would",
            "mean everyone falls unambiguously into one group, this model",
            "scores %.2f."),
      state$dimension,
      if (e >= 0.8) "sharply" else if (e >= 0.6) "reasonably well"
      else "only loosely", e))

    weak = d$discrimination$item[!is.na(d$discrimination$flag)]
    out = c(out, if (length(weak))
      paste0("Of the ", length(state$cfg$items), " questions, ",
             n_verb(length(weak), "contributes", "contribute"),
             " little to telling the segments apart (",
             paste(weak, collapse = ", "), ").")
      else paste0("All ", length(state$cfg$items),
                  " questions contribute to telling the segments apart."))
  } else {
    # The reference report prints these and this one did not, which for a
    #   factor model is the first thing a reader looks for. Reported with the
    #   caveat rather than as a verdict: the conventional targets were derived
    #   under simple random sampling and this is a clustered weighted sample.
    fm = d$fit
    if (!is.null(fm) && nrow(fm)) {
      g = function(nm) {
        v = fm$value[fm$measure == nm]
        if (length(v)) v[1] else NA_real_
      }
      four = c(g("cfi.scaled"), g("tli.scaled"), g("rmsea.scaled"), g("srmr"))
      if (all(is.finite(four)))
        out = c(out, sprintf(
          paste("Robust CFI %.3f, TLI %.3f, RMSEA %.3f, SRMR %.3f.",
                "Conventional targets are CFI and TLI above 0.95, RMSEA below",
                "0.06 and SRMR below 0.08, but those were derived under simple",
                "random sampling and RMSEA in particular penalises large",
                "samples, so they are guidance to read alongside the loading",
                "pattern rather than a pass mark."),
          four[1], four[2], four[3], four[4]))
    }

    weak = unique(d$loadings$item[!is.na(d$loadings$flag)])
    out = c(out, if (length(weak))
      paste0("Of the ", length(state$cfg$items), " questions, ",
             n_verb(length(weak), "tracks", "track"),
             " their scale only weakly (", paste(weak, collapse = ", "), ").")
      else paste0("All ", length(state$cfg$items),
                  " questions track their scale strongly."))
  }

  if (!is.null(state$measure$failed) && state$measure$failed > 0)
    out = c(out, sprintf(
      paste("%d of %d replicate refits did not converge and were dropped, so",
            "the margins on the measurement model are a lower bound."),
      state$measure$failed, state$measure$replicates))

  paste(out, collapse = " ")
}

# What was checked, what rests on the literature, what we chose, and what we
#   have not tested. The last column is the one that makes the document
#   trustworthy: a methods paper with no untested claims is either very short
#   or not telling you something.
# Arm-filtered throughout. Unfiltered, the factor report claimed a poLCA check
#   and a three-step classification correction it never ran, and the class
#   report claimed Bartlett scores and a lavPredict agreement that belong to
#   the other arm. A table of what was verified is worth nothing if it lists
#   verifications of something else.
status_table <- function(state) {
  lca = identical(state$cfg$arm, "lca")

  tibble::tribble(
    ~Claim, ~Status, ~Basis,

    "Every standard error comes from the survey design",
    "Verified",
    "One stratified jackknife replicate set drives the measurement model, the domain estimates and the corrections. Recomputed here, not carried over.",

    if (lca) "The unweighted class model reproduces an independent implementation" else NA_character_,
    if (lca) "Verified elsewhere" else NA_character_,
    if (lca) "Checked against poLCA in the reference implementation. Not re-run by this app." else NA_character_,

    if (!lca) "Factor scores for partial responders match lavaan where both are defined" else NA_character_,
    if (!lca) "Verified" else NA_character_,
    if (!lca) "The closed form agrees with lavPredict to machine precision on complete cases." else NA_character_,

    if (lca) "Three-step estimation with a classification-error correction" else NA_character_,
    if (lca) "Established" else NA_character_,
    if (lca) "Bolck, Croon and Hagenaars; Vermunt (2010); Bakk and colleagues." else NA_character_,

    if (!lca) "Bartlett scores where the latent variable is the outcome" else NA_character_,
    if (!lca) "Established" else NA_character_,
    if (!lca) "Skrondal and Laake (2001)." else NA_character_,

    "Replication rather than linearisation for variance",
    "Our choice",
    "A pseudo-likelihood does admit a sandwich variance. Replication propagates to new statistics without rederivation and makes the design specification auditable.",

    "A stratum with one sampling unit halts the analysis",
    "Our choice",
    "It cannot take the replicate scaling. Collapsing strata is a decision for a methodologist, not a default.",

    if (!lca) "Residual covariances are never freed" else NA_character_,
    if (!lca) "Our choice" else NA_character_,
    if (!lca) "Freeing them improves fit and makes the model harder to reproduce elsewhere." else NA_character_,

    "Item removal is capped at one round",
    "Our choice",
    "Diagnostics rank rather than test, and an unbounded loop selects a battery to fit rather than to measure.",

    "Each question works the same way in every group compared",
    "Untested",
    "Measurement invariance is assumed, not tested. A real group difference and a difference in how a question is understood are indistinguishable in these tables.",

    if (lca) "Domain intervals hold the measurement model fixed" else NA_character_,
    if (lca) "Untested here" else NA_character_,
    if (lca) "Standard three-step practice. Propagating step-one uncertainty widens them; the reference implementation measured that at roughly a factor of two on one demographic." else NA_character_,

    # All three cells share one condition. Guarding them separately produced a
    #   row with a claim and a blank status whenever the factor arm ran under
    #   WLSMV, which is the arm where the claim does not apply at all.
    if (!lca && identical(state$cfg$estimator, "ML"))
      "Treating ordered categories as continuous" else NA_character_,
    if (!lca && identical(state$cfg$estimator, "ML"))
      "Untested here" else NA_character_,
    if (!lca && identical(state$cfg$estimator, "ML"))
      "Taken so partial responders could be scored. Whether loadings agree with the ordered treatment on this battery has not been checked." else NA_character_
  ) |>
    dplyr::filter(!is.na(Claim))
}


# The research question sets order and emphasis. It does not set what gets
#   reported: a report organised around a question, by a model that also
#   chooses what to include, is a report that finds the question's answer. So
#   the model is told to lead with what bears on the question and then to say
#   plainly what the analysis does not answer -- which is the section that
#   keeps the framing honest.

prompt_report_summary <- function(state) {
  reads = purrr::imap_chr(state$domain_reads %||% list(),
                          function(r, v) paste0(v, ": ", r$finding))
  q = state$question %||% ""

  # A model asked to summarise findings it was not given will summarise
  #   whatever else it was handed. That is how the coverage table arrived in a
  #   report as "the groups considered" -- not a finding, and not something
  #   anyone can act on. With nothing to summarise, it is asked to say so
  #   rather than to fill the space.
  if (!length(reads))
    return(stringr::str_glue(
      "No domain has been read yet, so there are no findings to summarise.\n\n",
      "Return only this JSON, no prose and no markdown fences:\n",
      '{{"summary": "No domain findings have been written yet, so there is ',
      'nothing to summarise. Read the domains, then rebuild the report.", ',
      '"not_answered": ""}}'))

  stringr::str_glue(
    "ANALYST CONTEXT\n{state$context %||% ''}\n\n",
    "{if (nzchar(q)) paste0('RESEARCH QUESTION\\n  ', q, '\\n\\n') else ''}",
    "WHAT WAS MEASURED\n  {length(state$cfg$items)} items, ",
    "{state$dimension} {if (state$cfg$arm == 'lca') 'segments' else 'factors'}, ",
    "named: {paste(state$labels$Label, collapse = '; ')}\n\n",
    "COVERAGE\n{log_table(state$coverage)}\n\n",
    "FINDINGS ALREADY WRITTEN FOR EACH DOMAIN\n",
    "{paste(reads, collapse = '\n')}\n\n",
    "TASK\nWrite two things for an analyst who will use this to write for",
    " policymakers.\n\n",
    "First, a summary of at most 150 words: what was measured, what the groups",
    " are, and which findings are worth their attention. ",
    "{if (nzchar(q)) 'Lead with whatever bears on the research question. ' else ''}",
    "\n\nSecond, at most three sentences on what this analysis structurally",
    " cannot answer",
    "{if (nzchar(q)) ' -- in particular, which parts of the research question the data do not speak to' else ''}",
    ". Name a comparison across time or place the data do not contain, a",
    " causal claim, or a quantity no model here estimates. Do not name",
    " anything that could be computed from the tables above, and do not give",
    " a general caution.\n\n",
    "Draw only on what is above. Do not add a finding that is not in the list,",
    " do not reorder a finding out of existence, do not use causal language,",
    " and do not describe anything as significant.\n\n",
    "Return only valid JSON, no prose and no markdown fences:\n",
    '{{"summary": "...", "not_answered": "..."}}')
}



# ---- blocks -----------------------------------------------------------------

# type: h1 h2 h3 p bullet tick box table plot
blk <- function(type, value, caption = NULL, height = 4.2)
  list(type = type, value = value, caption = caption, height = height)

report_blocks <- function(state, summary_text = NULL, not_answered = NULL) {
  cfg = state$cfg
  arm = cfg$arm
  lca = identical(arm, "lca")
  labs = state$labels$Label
  b = list()
  add = function(x) b[[length(b) + 1]] <<- x

  add(blk("h1", if (lca) "Segments in the population, and how they differ"
                else "Latent scales in the population, and how they differ"))
  add(blk("p", paste0(
    fs::path_file(state$data_file), " · ",
    format(Sys.Date(), "%d %B %Y"), " · ",
    format(nrow(state$raw), big.mark = ","), " respondents · ",
    "DrSvyR v", WISE_VERSION)))

  if (nzchar(state$question %||% "")) {
    add(blk("h2", "The question this was asked to answer"))
    add(blk("p", state$question))
  }

  if (!is.null(summary_text)) {
    add(blk("h2", "Summary"))
    add(blk("p", summary_text))
  }

  # ---- what was done, in two registers --------------------------------------

  add(blk("h2", "What was done"))
  add(blk("p", paste0(
    "Respondents answered ", length(cfg$items), " related questions. ",
    if (lca) paste0(
      "Rather than read each question separately, the analysis asks whether ",
      "people fall into a small number of recognisable types, each with its ",
      "own way of answering the set. It found ", state$dimension,
      ". Every respondent is placed in the type their answers fit best.")
    else paste0(
      "The analysis asks whether those answers reflect ", state$dimension,
      " underlying thing(s) that people have more or less of, and gives each ",
      "respondent a position on it. Zero is the population average."))))
  add(blk("p", paste0(
    "Respondents were not selected one at a time. They were drawn in clusters ",
    "within ", dplyr::n_distinct(state$design_dat$strata), " strata, from ",
    dplyr::n_distinct(state$design_dat$psu), " sampling units, and weighted so ",
    "the figures describe the population rather than the people who happened ",
    "to answer. Every margin of error here is calculated from that design. ",
    "Software that assumes independent sampling reports margins roughly half ",
    "as wide, so a difference that looks decisive under those defaults may not ",
    "survive.")))

  add(blk("box", paste0(
    "Technical. ",
    if (lca)
      paste0("A latent class model fitted by weighted EM under a ",
             "design-weighted pseudo-likelihood, from ", cfg$n_starts,
             " random starts at each candidate size, best log-likelihood ",
             "retained. Information criteria rescale the log-likelihood to the ",
             "sum-to-n scale. Segment order is aligned across fits by response ",
             "profile, so parameters are comparable across replicates.")
    else
      paste0("A confirmatory factor model fitted by ",
             if (identical(cfg$estimator, "ML"))
               "maximum likelihood with full-information treatment of missing data"
             else "WLSMV on design-weighted polychoric correlations",
             ", with the item-to-factor assignment taken from the exploratory ",
             "solution at the chosen number and shown below. Loadings are ",
             "anchored by the marker method so a sign flip cannot enter the ",
             "variance."),
    " Variance throughout is a stratified jackknife over the ",
    dplyr::n_distinct(state$design_dat$psu),
    " primary sampling units. The measurement model is refitted inside every ",
    "replicate, warm-started from the full-sample solution.")))

  # ---- the questions --------------------------------------------------------

  add(blk("h2", "The questions analysed"))
  add(blk("p", paste(
    "Tables and figures refer to questions by their code. This is where to",
    "look one up.")))
  add(blk("table", dictionary_table(state), NULL))

  # ---- what was found -------------------------------------------------------

  add(blk("h2", if (lca) "The segments" else "The scales"))

  if (!is.null(state$measure)) {
    add(blk("plot",
            if (lca) plot_profiles_ci(state$measure$profile, labs)
            else plot_cfa_diagram(state$model$fit,
                                  correlations = state$measure$correlations),
            if (lca) "Each segment's position on every question, with 95% intervals"
            else "The measurement model",
            if (lca) 4.4 else 5.0))
  }

  purrr::walk(seq_along(labs), function(k) {
    add(blk("h3", labs[k]))

    est = if (lca && !is.null(state$measure))
      sprintf("An estimated %.1f%% of the population [%.1f%% to %.1f%%].",
              100 * state$measure$shares$share[k],
              100 * state$measure$shares$lo[k],
              100 * state$measure$shares$hi[k])
    else if (lca)
      sprintf("An estimated %.0f%% of respondents.",
              100 * state$model$fit$pi[k])
    else ""

    add(blk("p", paste(state$labels$Description[k], est)))
    purrr::walk(segment_evidence(state, k), function(t) add(blk("tick", t)))
  })

  add(blk("box", paste0(
    "Technical. Names are drafts written from the response profiles and the ",
    "question wording, then ",
    if (isTRUE(state$labels_edited)) "edited by the analyst"
    else "accepted by the analyst without editing",
    ". Nothing computed depends on them. The supporting points above are the ",
    if (lca) "questions on which each segment departs furthest from the average across segments"
    else "questions with the largest standardised loadings",
    ", taken from the fitted model rather than from the name.")))

  # ---- domains --------------------------------------------------------------

  add(blk("h2", "How they differ across groups"))
  add(blk("p", paste(
    "Each quantity is reported three ways. Unweighted ignores the survey",
    "design. Design-based accounts for it.",
    if (lca)
      paste("Corrected additionally removes the flattening that placing",
            "people into groups introduces. The gap from the first to the",
            "second is what ignoring the design costs; the gap from the second",
            "to the third is what the placement costs.")
    else
      paste("Corrected reports the Bartlett score rather than the regression",
            "score. Regression scores are shrunk toward the population average",
            "by the scale's reliability, which pulls group means together; the",
            "gap from the second column to the third is what that shrinkage",
            "was costing."))))

  purrr::walk(cfg$aux, function(v) {
    add(blk("h3", v))
    if (!is.null(state$domain_reads[[v]])) {
      add(blk("p", state$domain_reads[[v]]$finding))
      add(blk("p", paste("What accounting for the design changed:",
                         state$domain_reads[[v]]$caution)))
    }
    purrr::walk(strsplit(resolved_pairs(state$domains, v, labs), "\n")[[1]],
                function(t) {
                  t = trimws(t)
                  if (nzchar(t) && !grepl("^Criterion", t)) add(blk("tick", t))
                })
    add(blk("plot", plot_domain(state$domains$dom, v, labs, arm),
            paste0(v, ": three estimators, with 95% intervals"), 4.4))
    add(blk("table", marginal_table(state$domains$marg, v),
            paste0(v, ": composition of the population")))
  })

  add(blk("box", paste(
    "Technical. Pairs are separated by a design-based Wald test on the",
    "difference, using the replicate covariance between the two estimates and",
    "Holm-adjusted within each domain. The tests run on the design-based",
    "column: placement attenuates differences, so a pair resolved there",
    "separates despite the attenuation and the corrected column can only widen",
    "it. The replicate covariance has rank at most the number of replicates, so",
    "a joint test across more dimensions than there are replicates is not",
    "available.")))

  # ---- confidence -----------------------------------------------------------

  add(blk("h2", "How far to trust this"))
  add(blk("p", paste0(
    "The analyst chose ", state$dimension,
    if (lca) " segments" else " factors",
    ", recorded before any interpretation of the evidence was offered, and ",
    "reached over ", n_verb(iteration_count() + 1L, "round", "rounds"),
    " of fitting. ",
    diagnostic_sentences(state))))
  add(blk("table",
          state$coverage |>
            dplyr::transmute(Respondents = group,
                             n = format(n, big.mark = ","), `%` = percent),
          "Who these estimates rest on"))

  if (!is.null(not_answered) && nzchar(not_answered)) {
    add(blk("h2", "What this does not answer"))
    add(blk("p", not_answered))
  }

  add(blk("h2", "What not to overclaim"))
  purrr::walk(report_caveats(state), function(x) add(blk("bullet", x)))

  b
}

marginal_table <- function(marg, variable) {
  marg |>
    dplyr::filter(variable == !!variable) |>
    dplyr::transmute(Level = level,
                     Respondents = format(n, big.mark = ","),
                     `Share of population` = sprintf("%.1f%%", 100 * weighted))
}


# ---- renderers --------------------------------------------------------------

# Word output needs officer and flextable, and flextable needs Rtools to build
#   on a mirror that carries no binary for it. An analyst cannot install
#   Rtools. So the deliverable that always works is a self-contained HTML file:
#   one document, every figure embedded as a data URI, no external stylesheet
#   and no network. Word opens it directly if a .docx is what somebody wants.

# The block list is rendered a third way rather than rebuilt. Anything else
#   would drift from what was reviewed on screen.

REPORT_CSS <- "
:root {
  --bs-secondary-bg: #efefef;
  --bs-border-color: #b0b0b0;
  --bs-secondary-color: #5a5a5a;
}
body { max-width: 46rem; margin: 2.5rem auto; padding: 0 1.25rem;
       font-family: Calibri, Carlito, Helvetica, Arial, sans-serif;
       font-size: 11.5pt; line-height: 1.55; color: #1a1a1a; }
h3 { font-size: 1.45rem; margin: 0 0 0.2rem; }
h4 { font-size: 1.15rem; margin: 1.9rem 0 0.4rem; }
h5 { font-size: 1rem;    margin: 1.3rem 0 0.3rem; }
p  { margin: 0.5rem 0; }
img { max-width: 100%; height: auto; }
table { border-collapse: collapse; width: 100%; font-size: 9.5pt;
        margin: 0.6rem 0 1.1rem; }
th { text-align: left; font-weight: 600; border-bottom: 1.5px solid #444;
     padding: 4px 8px; }
td { border-bottom: 1px solid #ddd; padding: 4px 8px; vertical-align: top; }
hr { border: 0; border-top: 1px solid var(--bs-border-color); margin: 2.4rem 0; }
"

# Bootstrap is not available outside the app, so the variables report_html()
#   styles against are defined above rather than the styles being rewritten.
#   The screen preview and the saved file stay the same document.

html_table <- function(df)
  shiny::HTML(knitr::kable(df, format = "html", table.attr = "class='t'"))

report_appendices <- function(state) {
  lca = identical(state$cfg$arm, "lca")
  labs = state$labels$Label

  shiny::tagList(
    shiny::tags$hr(),
    shiny::tags$h3("Appendix A. Full estimates"),
    shiny::tags$p(paste(
      "Every quantity in the report with its 95 per cent interval.",
      if (lca)
        paste("Intervals on a share are formed on the logit scale, which keeps",
              "them inside 0 to 1 without truncation. A dagger marks a",
              "corrected cell whose estimate or interval falls outside that",
              "range: the correction permits it, and clipping to the boundary",
              "would report a number the estimator did not produce.")
      else
        paste("Positions are on the factor scale, centred so that zero is the",
              "population average. A negative value means below average and is",
              "not a problem in itself."),
      "Diagnostic tables and the record of how the specification was reached",
      "are in the CSV files supplied alongside.")),

    purrr::map(state$cfg$aux, function(v) shiny::tagList(
      shiny::tags$h4(v),
      html_table(domain_wide(state$domains$dom, v, labs)))),

    shiny::tags$hr(),
    shiny::tags$h3("Appendix B. What was tested"),
    shiny::tags$p(paste(
      "What was checked, what rests on the literature, what was a choice, and",
      "what has not been tested. The last of these is the column to read",
      "first.")),
    html_table(status_table(state)))
}

build_report_html <- function(state, summary_text = NULL,
                              not_answered = NULL) {
  doc = shiny::tagList(
    report_html(state, summary_text, not_answered),
    report_appendices(state))

  path = wise_path("output", state$cfg$arm, "report.html")

  writeLines(c(
    "<!doctype html>",
    "<html lang=\"en\"><head>",
    "<meta charset=\"utf-8\">",
    paste0("<title>DrSvyR report -- ",
           fs::path_file(state$data_file), "</title>"),
    "<style>", REPORT_CSS, "</style>",
    "</head><body>",
    as.character(doc),
    "</body></html>"), path, useBytes = TRUE)

  path
}

build_report <- function(state, summary_text = NULL, not_answered = NULL) {
  # Named rather than left to fail inside officer:: with a namespace error an
  #   analyst cannot act on. flextable in particular needs Rtools where the
  #   mirror carries no binary, which is not something an analyst can install.
  missing = c("officer", "flextable")[
    !vapply(c("officer", "flextable"), requireNamespace, logical(1),
            quietly = TRUE)]
  if (length(missing))
    stop("Word output needs ", paste(missing, collapse = " and "),
         ", which ", if (length(missing) > 1) "are" else "is",
         " not installed here. Use the HTML report instead: it carries the ",
         "same content, opens in Word, and needs nothing beyond what the app ",
         "already uses.", call. = FALSE)

  lca = identical(state$cfg$arm, "lca")
  labs = state$labels$Label
  doc = officer::read_docx()

  # Boxes are shaded paragraphs with a rule above and below. Word has no first
  #   class text box that survives a template change, and a shaded block reads
  #   the same and cannot break the flow of the document.
  box_fmt = officer::fp_par(
    shading.color = "#EFEFEF",
    border.top = officer::fp_border(color = "#B0B0B0", width = 1),
    border.bottom = officer::fp_border(color = "#B0B0B0", width = 1),
    padding = 6)

  purrr::walk(report_blocks(state, summary_text, not_answered), function(x) {
    doc <<- switch(
      x$type,
      h1     = officer::body_add_par(doc, x$value, style = "heading 1"),
      h2     = officer::body_add_par(doc, x$value, style = "heading 2"),
      h3     = officer::body_add_par(doc, x$value, style = "heading 3"),
      p      = officer::body_add_par(doc, x$value, style = "Normal"),
      bullet = officer::body_add_par(doc, paste0("• ", x$value),
                                     style = "Normal"),
      tick   = officer::body_add_par(doc, paste0("✓ ", x$value),
                                     style = "Normal"),
      box    = officer::body_add_fpar(
        doc, officer::fpar(officer::ftext(x$value,
                                          officer::fp_text(font.size = 9,
                                                           italic = TRUE)),
                           fp_p = box_fmt)),
      table  = flextable::body_add_flextable(doc, wise_table(x$value, x$caption)),
      plot   = officer::body_add_gg(doc, value = x$value, width = 6.4,
                                    height = x$height, res = 200),
      doc)
    if (identical(x$type, "plot") && !is.null(x$caption))
      doc <<- officer::body_add_par(doc, x$caption, style = "Normal")
  })

  # ---- appendices -----------------------------------------------------------

  doc = officer::body_add_break(doc)
  doc = officer::body_add_par(doc, "Appendix A. Full estimates",
                              style = "heading 1")
  doc = officer::body_add_par(
    doc, paste("Every quantity in the report with its 95 per cent interval.",
               if (lca)
                 paste("Intervals on a share are formed on the logit scale,",
                       "which keeps them inside 0 to 1 without truncation. A",
                       "dagger marks a corrected cell whose estimate or",
                       "interval falls outside that range: the correction",
                       "permits it, and clipping to the boundary would report",
                       "a number the estimator did not produce.")
               else
                 paste("Positions are on the factor scale, centred so that",
                       "zero is the population average. A negative value means",
                       "below average and is not a problem in itself."),
               "Diagnostic tables and the record of how the specification was",
               "reached are in the CSV files supplied alongside."),
    style = "Normal")
  purrr::walk(state$cfg$aux, function(v) {
    doc <<- officer::body_add_par(doc, v, style = "heading 2")
    doc <<- flextable::body_add_flextable(
      doc, wise_table(domain_wide(state$domains$dom, v, labs), NULL, 8))
  })

  doc = officer::body_add_break(doc)
  doc = officer::body_add_par(doc, "Appendix B. What was tested",
                              style = "heading 1")
  doc = officer::body_add_par(
    doc, paste("What was checked, what rests on the literature, what was a",
               "choice, and what has not been tested. The last of these is the",
               "column to read first."),
    style = "Normal")
  doc = flextable::body_add_flextable(doc, wise_table(status_table(state), NULL, 8))

  path = wise_path("output", state$cfg$arm, "report.docx")
  print(doc, target = path)
  path
}

report_html <- function(state, summary_text = NULL, not_answered = NULL) {
  purrr::map(report_blocks(state, summary_text, not_answered), function(x) {
    switch(
      x$type,
      h1     = shiny::tags$h3(x$value),
      h2     = shiny::tags$h4(x$value, style = "margin-top:1.5em;"),
      h3     = shiny::tags$h5(x$value, style = "margin-top:1.1em;"),
      p      = shiny::tags$p(x$value, style = "white-space:pre-line;"),
      bullet = shiny::tags$p(paste0("• ", x$value),
                             style = "margin:0.1em 0 0.1em 1em;"),
      tick   = shiny::tags$p(paste0("✓ ", x$value),
                             style = "margin:0.1em 0 0.1em 1em;"),
      box    = shiny::tags$div(
        style = paste("background: var(--bs-secondary-bg);",
                      "border-top: 1px solid var(--bs-border-color);",
                      "border-bottom: 1px solid var(--bs-border-color);",
                      "padding: 8px 12px; margin: 1em 0;",
                      "font-size: 88%; font-style: italic;"),
        x$value),
      table  = shiny::tagList(
        if (!is.null(x$caption))
          shiny::tags$p(shiny::tags$em(x$caption),
                        style = "margin-bottom:0.2em; font-size:90%;"),
        shiny::HTML(knitr::kable(x$value, format = "html",
                                 table.attr = "class='table table-sm'"))),
      plot   = shiny::tagList(
        shiny::tags$img(src = plot_data_uri(x$value, 6.4, x$height),
                        style = "max-width:100%; margin:0.6em 0;"),
        if (!is.null(x$caption))
          shiny::tags$p(shiny::tags$em(x$caption),
                        style = "font-size:90%; color:var(--bs-secondary-color);")),
      NULL)
  })
}

plot_data_uri <- function(g, width, height, res = 150) {
  f = tempfile(fileext = ".png")
  ggplot2::ggsave(f, g, width = width, height = height, dpi = res, bg = "white")
  paste0("data:image/png;base64,", base64enc::base64encode(f))
}


# Assembled from what actually happened in this run rather than a fixed list,
#   so a caveat that does not apply is absent and one that does is specific.
report_caveats <- function(state) {
  lca = identical(state$cfg$arm, "lca")
  n_round = iteration_count()

  c(
    # iteration_count() counts refits, not removals. Saying "items were
    #   removed" put a claim in the report that a re-run at the same battery
    #   makes false, which is the kind of thing a reader checks first.
    if (n_round > 0)
      paste0("The specification was revised and the model refitted ",
             n_verb(n_round, "time", "times"),
             ". Fit statistics computed after a search over ",
             "specifications are optimistic, because the specification was ",
             "chosen partly on this sample."),

    if (isFALSE(state$labels_edited))
      paste("Every drafted name was accepted without editing. The names are",
            "drafts written from the response patterns; nothing computed",
            "depends on them, but no one verified them against the profiles."),

    if (!is.null(state$measure$failed) && state$measure$failed > 0)
      paste0(state$measure$failed, " replicate refits did not converge and ",
             "were dropped. The intervals on the measurement model are ",
             "narrower than they should be and are a lower bound."),

    if (lca)
      paste("Domain intervals hold the measurement model fixed: uncertainty in",
            "the model itself is not propagated into them. This is standard",
            "three-step practice and it makes those intervals optimistic."),

    if (!lca && identical(state$cfg$estimator, "ML"))
      paste("Answer categories were treated as a continuous scale. This is an",
            "approximation, taken so that respondents who skipped some items",
            "could still be scored."),

    if (!lca && !identical(state$cfg$estimator, "ML"))
      paste("Only respondents who answered every item could be scored. People",
            "who skip items are not a random slice of the sample, so the",
            "domain estimates condition on complete response."),

    # Named rather than left as an arithmetic gap in the coverage table.
    local({
      k = state$coverage$n[startsWith(state$coverage$group,
                                      "Not scored: the model")]
      if (!length(k) || k == 0) NULL else
        paste0(n_verb(k, "respondent", "respondents"),
               " answered every item and still could not be given a score. ",
               "The estimator cannot place a response pattern that sits at ",
               "the extreme of nearly every item, so these are not a random ",
               "few: they are among the most positive or most negative in ",
               "the file, and the estimates rest on a sample with them ",
               "removed.")
    }),

    paste("Where two levels are not reported as separating, the data do not",
          "resolve them. That is not the same as saying they are alike."),

    # Always stated, because it always applies and it is the assumption least
    #   likely to occur to whoever acts on the numbers. A domain difference and
    #   a difference in how a question is understood look identical here.
    paste("Comparing groups assumes each question works the same way in all of",
          "them. That has not been tested. If an item means something",
          "different to one group than another, the difference reported here",
          "may be about the question rather than about what it measures.",
          "Where there is reason to suspect that, a survey methodologist",
          "trained in psychometrics should be consulted before the difference",
          "is treated as substantive.")) |>
    purrr::compact()
}
