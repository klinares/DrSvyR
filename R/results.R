# results.R for DrSvyR
# Scoring, domain estimation, and everything written out.

#   1. Scoring
#   2. Domain estimation
#   3. The delivered data file and tables
#   4. The report


#   1. Scoring
#   2. Coverage and assignment quality

# The measurement model is fitted on people who answered every item. Scoring
#   extends past that, because item nonresponse is not random and restricting
#   the domain estimates to complete responders selects on the composition being
#   measured. What that extension costs is reported rather than assumed away.

# Requires: dplyr, purrr, tibble, ggplot2


# Section 1 scores from the fitted class model. A missing answer contributes
#   nothing to that respondent's product, so a partial responder is scored from
#   the items they did answer, gated by how many that was.
#______________________________________________________________________________

score_respondents <- function(state) {
  cfg = state$cfg
  fr = state$item_frame

  frame = dplyr::bind_cols(state$design_dat, fr$item_dat, state$demo_dat)
  pred = predict_segments(frame, state$model$fit, cfg$items, cfg$min_items)

  dplyr::bind_cols(frame, pred) |>
    dplyr::mutate(in_analysis = fr$in_analysis)
}


# Section 2 says who was reached and how well.
#______________________________________________________________________________
score_coverage <- function(scored, n_items) {
  reached = !is.na(scored$segment)
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
assignment_quality <- function(scored) {
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
    ggplot2::geom_line(linewidth = 0.9, colour = wise_accent()) +
    ggplot2::geom_point(ggplot2::aes(size = n), colour = wise_accent()) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::scale_size(name = "Respondents") +
    ggplot2::labs(x = "Items answered", y = "Certainty of assignment",
                  caption = fig_caption(
                    "A sharp fall at the low end means those respondents are",
                    "being placed on too little information.")) +
    wise_theme()
}

# A scoring check, and never an estimate.

# What an analyst reports as the size of a segment is the model prevalence:
#   pi_k from the design-weighted pseudo-likelihood, with an interval that
#   comes from refitting in every replicate. That is a population quantity and
#   its interval carries the uncertainty in where the segments are.
# This table is a different thing. It is the share of respondents ASSIGNED to
#   each segment, which treats the boundaries as known and counts people into
#   bins. It used to carry a standard error, printed beside a weighted share,
#   which is indistinguishable on screen from the estimate an analyst should be
#   quoting and is roughly a third as wide. The standard error is gone for that
#   reason: there is no interval here to quote, because this is not the
#   estimand.
# The gap is what the table is for. Modal assignment flattens differences, so
#   the assigned share sits closer to uniform than the model prevalence does,
#   and the size of that gap is the classification error the BCH correction
#   later removes from the domain estimates. Large gaps and low entropy are the
#   same finding seen twice.
group_shares <- function(scored, labels, rep_des, prevalence) {
  raw = scored |>
    dplyr::filter(!is.na(segment)) |>
    dplyr::count(segment, name = "n")

  m = survey::svymean(~ factor(segment), rep_des, na.rm = TRUE)

  raw |>
    dplyr::mutate(
      assigned = round(as.numeric(coef(m)), 3),
      prevalence = round(as.numeric(prevalence), 3),
      gap = round(assigned - prevalence, 3),
      group = labels$Label[segment]) |>
    dplyr::select(segment, group, n, assigned, prevalence, gap)
}



#   1. Marginals
#   2. Three estimators
#   3. Which differences the analysis resolves
#   4. Plots

# Each domain quantity is reported three ways so the two corrections can be read
#   separately. Unweighted ignores the design. Design-based applies the weights
#   and takes its variance from the replicates. The third removes the
#   attenuation the assignment step introduces. The gap from the first to the
#   second is what ignoring the design costs; the gap from the second to the
#   third is what the assignment costs.

# Requires: survey, dplyr, purrr, tibble, tidyr, ggplot2


# Section 1
#______________________________________________________________________________

# The composition of the population, and separately the number of respondents
#   the segment estimates for that level actually rest on.

# These were one number before. weighted came off a design built on scored
#   respondents only, n came off the whole frame, and the report printed the
#   pair as "X in the population". Neither half was what the label said: a
#   composition estimated among the people the model could place is exactly the
#   quantity item nonresponse distorts, and a count over everyone overstates
#   what a domain estimate rests on.
# So weighted is now estimated on the full design -- that is the population
#   composition, and the label is true of it -- and the count is split into n
#   (everyone at that level) and n_scored (those carrying the estimates). The
#   small-cell flag reads n_scored; see format_domain_block().
domain_marginals <- function(dat, aux, rep_des, keep = NULL) {
  if (is.null(keep)) keep = rep(TRUE, nrow(dat))
  purrr::map(aux, function(v) {
    m = survey::svymean(reformulate(v), rep_des, na.rm = TRUE)
    raw = dat |>
      dplyr::filter(!is.na(.data[[v]])) |>
      dplyr::count(.data[[v]], name = "n") |>
      rlang::set_names(c("level", "n"))
    got = dat[keep, , drop = FALSE] |>
      dplyr::filter(!is.na(.data[[v]])) |>
      dplyr::count(.data[[v]], name = "n_scored") |>
      rlang::set_names(c("level", "n_scored"))
    tibble::tibble(variable = v,
                   level = stringr::str_remove(names(coef(m)), paste0("^", v)),
                   weighted = as.numeric(coef(m)),
                   se = as.numeric(survey::SE(m))) |>
      dplyr::left_join(dplyr::mutate(raw, level = as.character(level)),
                       by = "level") |>
      dplyr::left_join(dplyr::mutate(got, level = as.character(level)),
                       by = "level") |>
      dplyr::mutate(n = dplyr::coalesce(n, 0L),
                    n_scored = dplyr::coalesce(n_scored, 0L))
  }) |>
    purrr::list_rbind()
}


# Section 2 estimates the share of each domain level falling in each segment,
#   three ways.
#______________________________________________________________________________

# Modal assignment is an error-prone measurement of true segment, and
#   cross-tabbing it against anything pulls the association toward the marginal.
#   BCH replaces each respondent's hard assignment by a row of the inverse
#   classification table.

# Posteriors and modal assignment stay at their full-sample values; the
#   classification table and the correction weights are rebuilt inside every
#   replicate, so the intervals carry the design variance of the classification
#   table and the cross-tab together rather than treating the first as known.

domain_estimates <- function(state, tick = NULL) {
  cfg = state$cfg
  init_parallel(cfg)

  # rep_des is the replicate set built on the WHOLE frame; keep picks out the
  #   respondents the model could place. Restricting the weights rather than
  #   rebuilding the design on the survivors is the unconditional subpopulation
  #   approach, and it is what makes the degrees of freedom below the degrees
  #   of freedom of the sample that was drawn rather than of whoever happened
  #   to answer enough items.
  rep_des = state$score_design$rep_des
  keep = state$score_design$keep
  scored = state$scored[keep, , drop = FALSE]

  K = state$dimension
  crit = qt(0.975, degf(rep_des))
  post_cols = paste0("post_segment", seq_len(K))

  # Levels are re-dropped here, and this is the second of the two places they
  #   have to be. build_demo_frame() sets them over the whole file; restricting
  #   to the respondents the model could place can empty one, and levels() does
  #   not notice. An empty level then exists in the corrected arm as 0/0, is
  #   omitted by svyby without a word, and is missing from the naive count --
  #   three tables, three level sets, and format_estimator_shift()'s inner join
  #   dropping the difference silently.
  # The universe is what is OBSERVED after the restriction, never what the
  #   source file declares. A category the file remembers and the data does not
  #   have is not a category.
  scored = dplyr::mutate(scored,
                         dplyr::across(dplyr::all_of(cfg$aux), droplevels))

  # levels() is NULL on anything that is not a factor, and outer(x, NULL)
  #   silently yields a matrix with no columns, so the estimate vector comes
  #   back short and the failure surfaces several functions later as a
  #   dimension error naming neither the variable nor the cause. Checked here,
  #   where the message can name it.
  meta = purrr::map(cfg$aux, function(v) {
    lv = levels(scored[[v]])
    check_dims(length(lv) > 0, TRUE, paste0("Domain variable '", v, "'"),
               paste("It is not a factor in the scored frame, so it has no",
                     "levels to estimate over. Re-apply the recodes."))
    tidyr::expand_grid(level = lv, segment = seq_len(K)) |>
      dplyr::mutate(variable = v)
  }) |>
    purrr::list_rbind() |>
    dplyr::mutate(idx = dplyr::row_number())

  # Unweighted: a plain cross-tab with binomial standard errors, as if the
  #   respondents had been drawn independently.
  naive = purrr::map(cfg$aux, function(v) {
    grid = dplyr::filter(meta, variable == v) |>
      dplyr::select(level, segment)
    scored |>
      dplyr::filter(!is.na(.data[[v]])) |>
      dplyr::count(level = as.character(.data[[v]]), segment, name = "n") |>
      dplyr::right_join(grid, by = c("level", "segment")) |>
      dplyr::mutate(n = dplyr::coalesce(n, 0L)) |>
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

  # .segf is built on the design with its levels declared, rather than
  #   ~factor(segment) inside svyby. factor() derives levels from what it is
  #   handed, so a domain level in which only one segment appears produced a
  #   one-level factor and R threw "contrasts can be applied only to factors
  #   with 2 or more levels" from inside survey, naming nothing. Declared here,
  #   the column count is 2K by construction.
  rep_des = update(rep_des, .segf = factor(segment, levels = seq_len(K)))

  # svyby splits the design by the domain and runs svymean of the segment
  #   factor inside each level. Columns are read by position because svyby's
  #   naming for a factor outcome varies by version.
  design = purrr::map(cfg$aux, function(v) {
    lv = levels(scored[[v]])
    sb = as.data.frame(survey::svyby(~ .segf, reformulate(v), rep_des,
                                     survey::svymean, na.rm = TRUE))
    vals = sb[, -1, drop = FALSE]
    check_dims(ncol(vals), 2 * K,
               paste0("svyby output for '", v, "'"),
               paste("Expected one estimate and one standard error per",
                     "segment. A segment with no respondents in this domain,",
                     "or a survey version that names its columns differently,",
                     "would do this."))
    # The row check the column check never covered. svyby omits a level with
    #   no rows left after na.rm and says nothing about it, so a level that
    #   emptied out between the recode and here would reach the report as a
    #   phantom in the other two arms and a gap in this one.
    check_dims(nrow(sb), length(lv),
               paste0("svyby rows for '", v, "'"),
               paste("A level was dropped between the recode and the",
                     "estimate. This usually means every respondent at that",
                     "level went unscored. Check the coverage table."))
    got = tibble::tibble(variable = v,
                   level = rep(as.character(sb[[1]]), times = K),
                   segment = rep(seq_len(K), each = nrow(sb)),
                   p = as.numeric(as.matrix(vals[, seq_len(K)])),
                   se = as.numeric(as.matrix(vals[, K + seq_len(K)]))) |>
      dplyr::filter(!is.na(level))
    # Laid on the shared grid. With the two checks above this join can no
    #   longer fill anything, which is the point: it is a guard that the three
    #   estimators are on one level universe, not a device for papering over
    #   the case where they are not.
    dplyr::filter(meta, variable == v) |>
      dplyr::select(variable, level, segment) |>
      dplyr::left_join(got, by = c("variable", "level", "segment"))
  }) |>
    purrr::list_rbind()
  design = dplyr::bind_cols(design, share_ci(design$p, design$se, crit))

  if (!is.null(tick)) tick("corrected")

  # The posterior columns are named from state$dimension while the frame was
  #   written by whatever model last scored. If those disagree the subset
  #   fails on a name rather than a dimension, which says nothing useful.
  missing_post = setdiff(post_cols, names(scored))
  if (length(missing_post))
    stop("The scored frame has no ", paste(missing_post, collapse = ", "),
         ". It was scored under a different number of groups than the ",
         K, " now selected. Score again before estimating domains.",
         call. = FALSE)

  P_fixed = as.matrix(scored[, post_cols, drop = FALSE])
  modal_fixed = as.integer(scored$segment)

  # The indicator matrix for each domain is a property of the respondents, not
  #   of the replicate weights, so it is built once rather than eighty-four
  #   times. Same matrices, same answer, a fraction of the allocation.
  # levels() is NULL on anything that is not a factor, and outer(x, NULL)
  #   silently yields a matrix with no columns. crossprod() then returns a
  #   0-row result, the estimate vector comes back short, and the failure
  #   surfaces several functions later as a dimension error naming neither the
  #   variable nor the cause. Checked in the meta block above, where the
  #   message can name the variable.
  M_list = purrr::map(cfg$aux, function(v) {
    M = outer(as.character(scored[[v]]), levels(scored[[v]]), "==") + 0
    M[is.na(M)] = 0
    M
  })

  # attr "ok" marks a replicate whose classification table was too close to
  #   singular for its inverse to mean anything. It is counted and kept, not
  #   dropped -- see replicate_variance(). What it means here is not what it
  #   means in measurement_se(), which is why each caller names it.
  theta = function(w_rep) {
    B = bch_weights(P_fixed, modal_fixed, w_rep)
    wU = w_rep * B
    out = unlist(purrr::map(M_list, function(M)
      as.vector(t(crossprod(M, wU) / as.numeric(crossprod(M, w_rep))))),
      use.names = FALSE)
    structure(out, ok = isTRUE(attr(B, "rcond") >= BCH_RCOND_MIN))
  }

  est = theta(scored[[cfg$weight]])
  if (!isTRUE(attr(est, "ok")))
    stop("The classification table is too close to singular to invert on the ",
         "full sample (reciprocal condition number below ", BCH_RCOND_MIN,
         "). That happens when a segment took almost no modal assignments. ",
         "The corrected estimator cannot be computed here; the design-based ",
         "one can.", call. = FALSE)

  check_dims(length(est), nrow(meta),
             "The corrected domain estimates",
             paste("The estimate vector and the label table are not the same",
                   "length, so no cell can be trusted to name its own level."))
  rv = replicate_variance(rep_des, theta, as.numeric(est), keep = keep)
  V = rv$V
  se = sqrt(diag(V))

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

  # Wald contrasts run on the design-based estimator, and the report now says
  #   so beside the list of resolved pairs.
  # The old comment justified this by claiming modal assignment attenuates
  #   differences so the corrected column "can only widen" a resolved pair.
  #   That does not follow. BCH inflates the point difference and inflates the
  #   variance -- the inverse classification table has diagonal entries above
  #   one and off-diagonal entries that are routinely negative -- so the ratio
  #   of the two is not signed in general. Whether the uncorrected test is the
  #   conservative one is an empirical property of this D, not of the method,
  #   and it is not asserted anywhere any more.
  # It stays on the design-based estimator because that estimator's covariance
  #   is the one the analyst can also see the intervals for, so a reader can
  #   check the test against a table in front of them.
  # Both the domain indicators and the assignment indicator are fixed across
  #   replicates. Only the weights move.
  Z_fixed = outer(modal_fixed, seq_len(K), "==") + 0

  if (!is.null(tick)) tick("contrasts")

  wald_theta = function(w_rep) {
    unlist(purrr::map(M_list, function(M)
      as.vector(t(crossprod(M, w_rep * Z_fixed) /
                  as.numeric(crossprod(M, w_rep))))),
      use.names = FALSE)
  }
  w_est = wald_theta(scored[[cfg$weight]])
  w_rv = replicate_variance(rep_des, wald_theta, w_est, keep = keep)
  w_V = w_rv$V

  list(dom = dplyr::bind_rows(
         dplyr::mutate(naive, estimator = "Unweighted"),
         dplyr::mutate(design, estimator = "Design-based"),
         dplyr::mutate(corrected, estimator = "Corrected")) |>
         # The quantity is a share, so 0 and 1 mean something and a value
         #   outside them is worth marking. share is carried rather than
         #   assumed, because the dagger logic in the report reads it.
         dplyr::mutate(share = TRUE,
                       estimator = factor(
           estimator, levels = c("Unweighted", "Design-based", "Corrected"))),
       wald = list(est = w_est, V = w_V, meta = meta, df = degf(rep_des)),
       # unstable is the number of replicates in which the classification table
       #   was too ill-conditioned to invert meaningfully. They are kept in the
       #   variance and disclosed rather than dropped; see replicate_variance().
       unstable = rv$failed,
       travel_ratio = rv$travel_ratio,
       n_wild = rv$n_wild,
       replicates = rv$replicates,
       degf = as.integer(degf(rep_des)),
       tested_on = "Design-based",
       values_header = "Share of each level falling in each segment:")
}


# Section 3 works out which pairs of levels the analysis actually resolves,
#   here rather than by the model.
#______________________________________________________________________________

resolved_pairs <- function(res, variable, labels, alpha = 0.05) {
  domain_separations(res$dom, variable, labels,
                     est = "Design-based", wald = res$wald, alpha = alpha)
}


# Section 5
#______________________________________________________________________________

# Level names run long -- "Terciaria o universitaria o superior incompleta" is
#   forty-seven characters -- and an unwrapped axis label eats the panel it is
#   labelling. With one facet per segment there is only a couple of inches of
#   panel to begin with, so the figure came out truncated in the HTML and worse
#   in Word. Wrapped here rather than by widening the image, because the image
#   width is set by the page.

# level_order is the factor order the analyst declared. Without it ggplot sorts
#   a character column alphabetically, so the figure and the table beneath it
#   disagreed about the order of the same six categories. Reversed, because a
#   discrete y axis builds from the bottom and the table reads from the top.
# Level names run long and segment names run longer. Three things were being
#   clipped here and the axis was only one of them: the y labels, the facet
#   strip above each panel, and the tick labels of adjacent panels colliding
#   with each other. All three are geometry, not style, so all three are
#   computed from the width the figure will actually be drawn at rather than
#   set to a number that happened to work once.

# level_order is the factor order the analyst declared. Without it ggplot sorts
#   a character column alphabetically, so the figure and the table beneath it
#   disagreed about the order of the same six categories. Reversed, because a
#   discrete y axis builds from the bottom and the table reads from the top.
# Eighteen, not twenty-six. Every character the y axis spends comes straight
#   off the panels, and the panels are what the strip label has to fit into: at
#   26 the education labels left 1.3 inches a panel and the segment names
#   wrapped to three lines; at 18 they leave 1.6 and wrap to two. A y label on
#   two short lines costs less than a strip on three.
DOMAIN_Y_WRAP <- 18L

domain_facet_cols <- function(n_groups) min(3L, max(1L, as.integer(n_groups)))

plot_domain <- function(dom, variable, labels, level_order = NULL,
                        width = FIG_WIDTH_IN) {
  d = dom |>
    dplyr::filter(variable == !!variable) |>
    dplyr::mutate(group = labels[segment])

  ord = level_order %||% sort(unique(d$level))
  ord = ord[ord %in% d$level]
  y_lab = stringr::str_wrap(ord, DOMAIN_Y_WRAP)
  d = dplyr::mutate(
    d, level = factor(stringr::str_wrap(level, DOMAIN_Y_WRAP),
                      levels = rev(y_lab)))

  ncol = domain_facet_cols(dplyr::n_distinct(d$group))
  strip = panel_wrap(y_lab, ncol, width)

  ggplot2::ggplot(d, ggplot2::aes(p, level, colour = estimator)) +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = lo, xmax = hi),
                           orientation = "y", width = 0.35, linewidth = 0.8,
                           position = ggplot2::position_dodge(width = 0.65)) +
    ggplot2::geom_point(size = 3.2,
                        position = ggplot2::position_dodge(width = 0.65)) +
    ggplot2::facet_wrap(~ group, scales = "free_x", ncol = ncol,
                        labeller = ggplot2::label_wrap_gen(width = strip)) +
    wise_colour(name = NULL) +
    # Three breaks, not four. With free x scales the last tick of one panel and
    #   the first of the next printed on top of each other -- "0.30|0.18" as one
    #   run of digits. Fewer breaks and a full line of panel spacing.
    ggplot2::scale_x_continuous(n.breaks = 3) +
    ggplot2::guides(
      colour = ggplot2::guide_legend(nrow = legend_rows(
        levels(factor(d$estimator)), width))) +
    ggplot2::labs(x = "Share of the level falling in this group", y = NULL) +
    wise_theme(base_size = 12) +
    ggplot2::theme(
      strip.text = ggplot2::element_text(size = ggplot2::rel(0.78)),
      axis.text.x = ggplot2::element_text(size = ggplot2::rel(0.85)),
      panel.spacing.x = ggplot2::unit(1, "lines"))
}

# The old height was 4.4 inches whatever the figure held, so a domain with two
#   levels wasted half the page and one with six squashed every interval into
#   the same quarter inch. Rows of facets times the space the levels actually
#   need, plus a line for every extra line a wrapped strip label takes, plus
#   whatever the legend needs once it is allowed more than one row.
plot_domain_height <- function(dom, variable, labels, level_order = NULL,
                               width = FIG_WIDTH_IN) {
  lv = unique(dom$level[dom$variable == variable])
  ord = level_order %||% lv
  y_lab = stringr::str_wrap(ord[ord %in% lv], DOMAIN_Y_WRAP)
  n_lv = length(y_lab)

  n_groups = length(labels)
  ncol = domain_facet_cols(n_groups)
  rows = ceiling(n_groups / ncol)
  strip_lines = wrap_lines(labels, panel_wrap(y_lab, ncol, width))

  # A level whose label wrapped to two lines needs the room for both.
  y_lines = wrap_lines(ord[ord %in% lv], DOMAIN_Y_WRAP)

  h = rows * (n_lv * (0.26 + 0.14 * y_lines) + 0.45 + 0.26 * strip_lines) +
      0.5 + 0.30 * legend_rows(c("Unweighted", "Design-based", "Corrected"),
                               width)
  max(3.0, min(9.0, h))
}

#   1. The delivered data file
#   2. Tables
#   3. The report

# Three kinds of output. A data file the analyst opens in the software they
#   already use, carrying everything the source file had plus what the model
#   found. Tables as CSV, because that is what gets pasted into other work. And
#   a report that is source material for someone writing to policymakers, not a
#   finished argument.

# Requires: haven, readr, dplyr, purrr, fs


# Section 1 delivers the data.
#______________________________________________________________________________

# Everything from the source file is carried over and the new columns are
#   appended, so the analyst is not asked to join anything.

# The posteriors and the correction weights travel with the assignment, not
#   instead of it. Cross-tabulating a modal assignment on its own reintroduces
#   exactly the attenuation the corrected column removes, and the variable
#   label says so, because that is the one place a reader will look.

# Identifiers are compared as text throughout. They arrive as labelled doubles,
#   plain integers or character strings depending on the file, and the only
#   thing that has to be true is that the same respondent produces the same key
#   on both sides of a join. format() rather than as.character() because
#   as.character(100000) is "1e+05" on some values and "100000" on others.
id_key <- function(x) {
  x = unclass(x)
  if (is.numeric(x)) format(x, scientific = FALSE, trim = TRUE)
  else as.character(x)
}

export_data <- function(state, format = c("sav", "dta")) {
  format = match.arg(format)
  cfg = state$cfg

  new_cols = {
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
  }

  # The identifier is joined on as text, not coerced to a number. A file whose
  #   id is "xc321" rather than 321 would otherwise become NA on one side of
  #   this join, every row would fail to match, and the delivered file would
  #   come back with empty score columns and no error anywhere.
  out = state$raw |>
    dplyr::mutate(.wise_id = id_key(state$raw[[state$design_map[["id"]]]])) |>
    dplyr::left_join(
      dplyr::mutate(dplyr::rename(new_cols, .wise_id = id),
                    .wise_id = id_key(.wise_id)),
      by = ".wise_id")

  # Checked rather than assumed. A join that matched nothing is the silent
  #   version of this failure, and it looks exactly like a run where nobody
  #   could be scored.
  # Counted from the keys rather than from a column of the joined frame. A
  #   survey file that already has a variable called "segment" makes dplyr
  #   suffix both sides to .x and .y, out[["segment"]] is then NULL, and a
  #   check meant to catch a failed join would have halted a good run.
  matched = sum(id_key(state$raw[[state$design_map[["id"]]]]) %in%
                  id_key(new_cols$id))

  if (matched == 0L && nrow(new_cols) > 0L)
    stop("No respondent in the delivered file matched a scored record. The ",
         "identifier in the survey file and the one carried through scoring ",
         "do not agree, so nothing can be joined back. Check the id variable ",
         "chosen on the Design screen.", call. = FALSE)

  # The same collision affects the delivered columns themselves: if the source
  #   file already carries a name this workflow adds, both survive as .x and
  #   .y. Named rather than silently delivered.
  clash = intersect(setdiff(names(new_cols), "id"), names(state$raw))
  if (length(clash))
    warning("The survey file already has ", paste(clash, collapse = ", "),
            ". Those columns appear twice in the delivered file, suffixed .x ",
            "for yours and .y for the ones added here.", call. = FALSE)

  out = dplyr::select(out, -.wise_id)

  path = wise_path("output",
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

# The three estimators as columns rather than rows. A reader compares them
#   across a row, which is also three times fewer rows on the page.
# level_order is the analyst's declared order. Arranging on the character
#   column sorted it alphabetically, so Appendix A listed an ordinal variable
#   in a different order from the figure and the table in the body.
domain_wide <- function(dom, variable, labels, level_order = NULL) {
  # Older result objects predate these columns. Absent means nothing to mark,
  #   which is the safe default in both directions.
  if (!"boundary" %in% names(dom)) dom$boundary = FALSE
  if (!"share" %in% names(dom)) dom$share = FALSE

  dom |>
    dplyr::filter(variable == !!variable) |>
    dplyr::mutate(Group = labels[segment],
                  # Only where the quantity is a share. A value of
                  #   -0.094 is the population average less 0.094 and there is
                  #   nothing out of range about it; marking those as though
                  #   they had left [0, 1] tells the reader something false.
                  outside = dplyr::coalesce(share, FALSE) &
                            (dplyr::coalesce(boundary, FALSE) |
                             lo < 0 | hi > 1),
                  cell = sprintf("%.3f [%.3f, %.3f]%s", p, lo, hi,
                                 dplyr::if_else(outside, "\u2020", ""))) |>
    dplyr::select(segment, Group, Level = level, estimator, cell) |>
    tidyr::pivot_wider(names_from = estimator, values_from = cell) |>
    dplyr::mutate(Level = factor(
      Level, levels = if (is.null(level_order)) sort(unique(Level))
                      else level_order[level_order %in% Level])) |>
    dplyr::arrange(segment, Level) |>
    dplyr::mutate(Level = as.character(Level)) |>
    dplyr::select(-segment)
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
  dict = state$item_frame$dictionary

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
    sprintf("%s \u2014 answers %s than average on \u201c%s\u201d",
            item_label(top$item[i], d$variable),
            if (top$gap[i] > 0) "notably higher" else "notably lower",
            d$question)
  })
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
  d = state$model$diag
  out = character(0)

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
# Every row is a claim about this analysis and how far it was checked.
#   Nothing here is aspirational: a claim that was not verified says so, and a
#   claim that does not apply is absent rather than blank.
status_table <- function(state) {
  tibble::tribble(
    ~Claim, ~Status, ~Basis,

    "Every standard error comes from the survey design",
    "Verified",
    "One stratified jackknife replicate set drives the measurement model, the domain estimates and the corrections. Built on the whole frame and restricted with an index, so both stages carry the same replicates and the same degrees of freedom.",

    "Replicate refits are warm-started from the full-sample solution",
    "Our choice",
    "Each replicate restarts at the fitted model rather than from fresh random starts. That tracks the mode instead of searching for it, so the interval expresses design variance around this solution and not uncertainty about which solution the likelihood should have found.",

    "The pairs reported as separated were tested on the design-based column",
    "Our choice",
    "The corrected column is the one displayed. Correcting for classification error changes the difference and its standard error together, so neither test is guaranteed to be the conservative one; the design-based column is used because its intervals are printed and the test can be checked against them.",

    "The unweighted model reproduces an independent implementation",
    "Verified elsewhere",
    "Checked against poLCA in the reference implementation. Not re-run by this app.",

    "Three-step estimation with a classification-error correction",
    "Established",
    "Bolck, Croon and Hagenaars; Vermunt (2010); Bakk and colleagues.",

    "Replication rather than linearisation for variance",
    "Our choice",
    "A pseudo-likelihood does admit a sandwich variance. Replication propagates to new statistics without rederivation and makes the design specification auditable.",

    "A stratum with one sampling unit halts the analysis",
    "Our choice",
    "It cannot take the replicate scaling. Collapsing strata is a decision for a methodologist, not a default.",

    "Item removal is capped at one round",
    "Our choice",
    "Diagnostics rank rather than test, and an unbounded loop selects a battery to fit rather than to measure.",

    "Each question works the same way in every group compared",
    "Untested",
    "Measurement invariance is assumed, not tested. A real group difference and a difference in how a question is understood are indistinguishable in these tables.",

    # The posteriors and the modal assignment are held at their full-sample
    #   values. Only the classification table is rebuilt inside each replicate,
    #   so step-one uncertainty does not reach these intervals and they are
    #   optimistic for that reason.
    "Domain intervals hold the measurement model fixed",
    "Untested here",
    "Standard three-step practice. The classification table is recomputed in every replicate, but the posteriors and the modal assignment are not. Propagating step-one uncertainty widens the intervals; the reference implementation measured that at roughly a factor of two on one demographic."
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
  # Keyed on the variable, headed by the label. The summary used to name
  #   variables the report never defines -- "differ by fs2, idio2, edre" -- and
  #   the codebook table covers the battery only, so nothing on the page said
  #   what those were.
  reads = purrr::imap_chr(state$domain_reads %||% list(),
                          function(r, v) paste0(aux_label(state$cfg, v),
                                                ": ", r$finding))
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
    "{state$dimension} segments, ",
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
  labs = state$labels$Label
  b = list()
  add = function(x) b[[length(b) + 1]] <<- x

  add(blk("h1", "Segments in the population, and how they differ"))
  add(blk("p", paste0(
    fs::path_file(state$data_file), " \u00b7 ",
    format(Sys.Date(), "%d %B %Y"), " \u00b7 ",
    format(nrow(state$raw), big.mark = ","), " respondents \u00b7 ",
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
    "Rather than read each question separately, the analysis asks whether ",
    "people fall into a small number of recognisable types, each with its ",
    "own way of answering the set. It found ", state$dimension,
    ". Every respondent is placed in the type their answers fit best.")))
  add(blk("p", paste0(
    "Respondents were not selected one at a time. They were drawn in clusters ",
    "within ", dplyr::n_distinct(state$design_dat$strata), " strata, from ",
    dplyr::n_distinct(state$design_dat$psu), " sampling units, and weighted so ",
    "the figures describe the population rather than the people who happened ",
    "to answer. Every margin of error here is calculated from that design.")))

  # Stated as a measured ratio, and read three ways because all three happen.
  ratio = design_width_ratio(state$domains$dom)
  if (!is.na(ratio))
    add(blk("p", paste(
      "On this survey and these quantities, accounting for the design changed",
      "the width of a typical interval by a factor of",
      paste0(sprintf("%.2f", ratio), "."),
      if (ratio >= 1.15)
        paste("Software assuming independent sampling would report margins",
              "materially narrower than these, and a difference that does not",
              "survive here would look decisive there.")
      else if (ratio <= 0.95)
        paste("The design-based intervals are the narrower ones here, which",
              "stratification can do. The naive column is not a substitute",
              "for them either way: it is not estimating the same quantity.")
      else
        paste("The design is doing little to these particular numbers, which",
              "is a fact about this comparison rather than a general one, and",
              "not a reason to compute them the other way."),
      "This is a ratio of interval widths and not a design effect: the two",
      "columns differ in estimator, in variance method and in critical value",
      "at once.")))

  add(blk("box", paste0(
    "Technical. ",
    "A latent class model fitted by weighted EM under a ",
    "design-weighted pseudo-likelihood, from ", cfg$n_starts,
    " random starts at each candidate size, best log-likelihood ",
    "retained. Information criteria rescale the log-likelihood to the ",
    "sum-to-n scale. Segment order is aligned across fits by response ",
    "profile, so parameters are comparable across replicates.",
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

  add(blk("h2", "The segments"))

  if (!is.null(state$measure)) {
    add(blk("plot", plot_profiles_ci(state$measure$profile, labs),
            paste("Each segment's position on every question. Bands are 95 per",
                  "cent design-based intervals; where two bands overlap, the",
                  "data do not separate those segments on that item."),
            plot_profiles_height(labs)))
  }

  purrr::walk(seq_along(labs), function(k) {
    add(blk("h3", labs[k]))

    est = if (!is.null(state$measure))
      sprintf("An estimated %.1f%% of the population [%.1f%% to %.1f%%].",
              100 * state$measure$shares$share[k],
              100 * state$measure$shares$lo[k],
              100 * state$measure$shares$hi[k])
    else
      sprintf("An estimated %.0f%% of respondents.",
              100 * state$model$fit$pi[k])

    add(blk("p", paste(state$labels$Description[k], est)))
    purrr::walk(segment_evidence(state, k), function(t) add(blk("tick", t)))
  })

  add(blk("box", paste0(
    "Technical. Names are drafts written from the response profiles and the ",
    "question wording, then ",
    if (isTRUE(state$labels_edited)) "edited by the analyst"
    else "accepted by the analyst without editing",
    ". Nothing computed depends on them. The supporting points above are the ",
    "questions on which each segment departs furthest from the average across ",
    "segments, taken from the fitted model rather than from the name.")))

  # ---- domains --------------------------------------------------------------

  add(blk("h2", "How they differ across groups"))
  add(blk("p", paste(
    "Each quantity is reported three ways. Unweighted ignores the survey",
    "design. Design-based accounts for it.",
    "Corrected additionally removes the flattening that placing people into",
    "groups introduces. The gap from the first to the second is what ignoring",
    "the design costs; the gap from the second to the third is what the",
    "placement costs.")))

  # Said once. It used to be the caption inside every domain figure, which on
  #   six domains is the same three lines printed six times and a shorter panel
  #   each time it was printed.
  add(blk("p", paste(
    "In every figure below, bars are 95 per cent intervals and each panel is",
    "one segment. The unweighted row ignores the survey design and its",
    "interval is not to be believed; it is shown so the difference is",
    "visible.")))

  purrr::walk(cfg$aux, function(v) {
    add(blk("h3", aux_heading(cfg, v)))
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

    # The declared factor order, so the figure and the table under it agree.
    ord = aux_levels(state, v) %||%
          unique(state$domains$marg$level[state$domains$marg$variable == v])

    add(blk("plot", plot_domain(state$domains$dom, v, labs, ord),
            aux_label(cfg, v),
            plot_domain_height(state$domains$dom, v, labs, ord)))
    add(blk("table", marginal_table(state$domains$marg, v),
            paste0("Composition of the population: ", aux_label(cfg, v))))
  })

  # domain_separations() uses the replicate covariance where it has one and
  #   falls back to non-overlapping intervals where it does not. Both arms
  #   carry it now, so the first branch is what runs; the second is kept
  #   because the fallback is still reachable and a report that describes a
  #   test which did not run is worse than one that describes a weaker rule.
  add(blk("box", if (!is.null(state$domains$wald)) paste(
    "Technical. Pairs are separated by a design-based Wald test on the",
    "difference, using the replicate covariance between the two estimates and",
    "Holm-adjusted within each domain. The tests run on the design-based",
    "column, whose intervals are printed here, so the test can be checked",
    "against a table the reader has in front of them. It is not a claim that",
    "the design-based test is the conservative one: correcting for",
    "classification error moves the difference and its standard error at once,",
    "and the ratio of the two is not signed in general.",
    "The replicate covariance has rank at most the",
    "number of replicates, so a joint test across more dimensions than there",
    "are replicates is not available.")
    else paste(
    "Technical. Pairs are separated when their 95 percent design-based",
    "intervals do not overlap, read from the design-based column. That is a",
    "stricter rule than a test of the difference: two intervals can overlap",
    "while the difference between them still clears its own interval, so",
    "some real differences are left unlisted. It is used here because the",
    "replicate covariance between the domain estimates was not available for",
    "this run, and a test needs the covariance, not just the two standard",
    "errors.")))

  # ---- confidence -----------------------------------------------------------

  add(blk("h2", "How far to trust this"))
  # "reached over 1 round of fitting" read as "more than one round" and meant
  #   the opposite. Two sentences rather than one template.
  n_fit = iteration_count() + 1L
  add(blk("p", paste0(
    "The analyst chose ", state$dimension, " segments",
    ", recorded before any interpretation of the evidence was offered. ",
    if (n_fit <= 1L) "The battery was fitted once and not revised. "
    else paste0("The specification was arrived at over ",
                n_verb(n_fit, "round", "rounds"), " of fitting. "),
    diagnostic_sentences(state))))
  add(blk("table",
          state$coverage |>
            dplyr::transmute(Respondents = group,
                             n = format(n, big.mark = ","), `%` = percent),
          "Who these estimates rest on"))

  # Scoring more people than were fitted looks like an error and is the point
  #   of the method, so it is said rather than left to be noticed.
  fitted_n = state$coverage$n[state$coverage$group ==
                                "Fitted the measurement model"]
  scored_n = state$coverage$n[state$coverage$group == "Scored"]
  if (length(fitted_n) && length(scored_n) && scored_n > fitted_n)
    add(blk("box", paste(
      "Technical. More respondents are scored than were used to fit. The",
      "measurement model is estimated on those who answered the whole",
      "battery; scoring then reaches anyone who answered enough of it,",
      "because under local independence a skipped item contributes nothing to",
      "that respondent's likelihood rather than disqualifying them. The",
      "difference is", format(scored_n - fitted_n, big.mark = ","),
      "respondents.")))

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
  labs = state$labels$Label

  shiny::tagList(
    shiny::tags$hr(),
    shiny::tags$h3("Appendix A. Full estimates"),
    shiny::tags$p(paste(
      "Every quantity in the report with its 95 per cent interval.",
      paste("Intervals on a share are formed on the logit scale, which keeps",
            "them inside 0 to 1 without truncation. A dagger marks a",
            "corrected cell whose estimate or interval falls outside that",
            "range: the correction permits it, and clipping to the boundary",
            "would report a number the estimator did not produce."),
      "Diagnostic tables and the record of how the specification was reached",
      "are in the CSV files supplied alongside.")),

    purrr::map(state$cfg$aux, function(v) shiny::tagList(
      shiny::tags$h4(aux_heading(state$cfg, v)),
      html_table(domain_wide(state$domains$dom, v, labs,
                             aux_levels(state, v))))),

    shiny::tags$hr(),
    shiny::tags$h3("Appendix B. What was tested"),
    shiny::tags$p(paste(
      "What was checked, what rests on the literature, what was a choice, and",
      "what has not been tested. The last of these is the column to read",
      "first.")),
    html_table(status_table(state)))
}



report_html <- function(state, summary_text = NULL, not_answered = NULL) {
  purrr::map(report_blocks(state, summary_text, not_answered), function(x) {
    switch(
      x$type,
      h1     = shiny::tags$h3(x$value),
      h2     = shiny::tags$h4(x$value, style = "margin-top:1.5em;"),
      h3     = shiny::tags$h5(x$value, style = "margin-top:1.1em;"),
      p      = shiny::tags$p(x$value, style = "white-space:pre-line;"),
      bullet = shiny::tags$p(paste0("\u2022 ", x$value),
                             style = "margin:0.1em 0 0.1em 1em;"),
      tick   = shiny::tags$p(paste0("\u2713 ", x$value),
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


# What the design actually cost, measured on this run rather than asserted.

# The report used to say that software assuming independent sampling reports
#   margins "roughly half as wide". On the reference data that sentence was
#   wrong by a factor of two in its own appendix: the median design-based
#   interval was the same width as the naive one and four cells in ten were
#   narrower. A general claim about survey data is not a finding about this
#   survey, and a reader who checks it and finds it false stops believing the
#   rest.

# It is a ratio of interval widths, not a design effect: the two columns
#   differ in estimator, in variance method and in critical value at the same
#   time. Reported as what it is.
design_width_ratio <- function(dom) {
  if (is.null(dom) || !nrow(dom)) return(NA_real_)
  base = dplyr::transmute(dplyr::filter(dom, estimator == "Unweighted"),
                          variable, level, segment, w0 = hi - lo)
  desg = dplyr::transmute(dplyr::filter(dom, estimator == "Design-based"),
                          variable, level, segment, w1 = hi - lo)
  j = dplyr::inner_join(base, desg, by = c("variable", "level", "segment"))
  r = j$w1 / j$w0
  r = r[is.finite(r) & r > 0]
  if (!length(r)) NA_real_ else stats::median(r)
}


# Assembled from what actually happened in this run rather than a fixed list,
#   so a caveat that does not apply is absent and one that does is specific.
report_caveats <- function(state) {
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

    paste("Domain intervals hold the measurement model fixed: the",
          "classification table is recomputed in every replicate, but the",
          "posteriors and the assignment are not. Uncertainty in the",
          "measurement model itself is not propagated, which is standard",
          "three-step practice and makes these intervals optimistic."),

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
