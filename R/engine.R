# engine.R for DrSvyR
# The estimation engine. Never edited per dataset; everything arrives as an
#   argument, and nothing here reads the analyst's configuration directly.

#   1. The parallel plan and the raw-data plot
#   2. The weighted EM, label alignment, and the fit diagnostics
#   3. The replicate design and variance from it
#   4. Scoring respondents from a fitted model
#   5. Prompts for naming the segments
#   6. Turning the domain table into a short read

# The tool fits one model: a latent class analysis on complex survey data,
#   weighted, with every standard error coming from the survey's own replicate
#   design. The factor-analytic arm that used to sit alongside this has been
#   removed -- along with lavaan, which nothing here now needs.

`%||%` <- function(x, y) if (is.null(x)) y else x


# ---- engine_01_tables_plots --------------------------------------------

# Section 1 holds the parallel plan and the raw-data plot.
#______________________________________________________________________________

# theme_lca(), wrap_text(), fit_widths() and lca_table() were removed. The
#   three table helpers served the Quarto reports and reached kableExtra,
#   which needs Rtools to install and so cannot be assumed on a locked-down
#   mirror; the app writes HTML through build_report_html() instead and calls
#   none of them. theme_lca() went because plot_item_stack() below was the one
#   plot in the project still using it, at base_size 11 against wise_theme()'s
#   14, and with plot.title blanked -- so the title this function is handed
#   was never drawn. One theme, applied everywhere, is the point.

# multisession on both platforms, deliberately. multicore forks, which is far
#   cheaper than starting a fresh R process, and it is tempting on the Linux
#   server for exactly that reason -- but forking out of a Shiny process is
#   unsafe: the child inherits the parent's connections and reactive context,
#   and future refuses to do it in several contexts for that reason. Windows
#   cannot fork at all. One plan that behaves the same on the laptop and on
#   the server is worth more here than the startup cost it saves.

# future::plan() sets the plan for the whole R process, and on a server one
#   process serves several analysts. Calling it on every fit tore the worker
#   pool down and rebuilt it underneath whoever was already running. Because
#   every session now resolves the same number from the same environment
#   variable, the plan they all want is identical, and this becomes a no-op
#   after the first call rather than a fight.
# Splitting a start set across workers. split(x, cut(seq_along(x), b)) is the
#   obvious way to write this and is wrong twice over: cut(x, 1) stops with
#   "invalid number of intervals", so DRSVYR_WORKERS=1 -- the documented way
#   to run without parallelism -- crashed the search before it began; and
#   cutting three items into four intervals yields an empty block and an
#   unbalanced one, which is the ordinary case once the survivors of a first
#   pass are being divided.

# This returns exactly min(blocks, length(x)) pieces, none empty, sizes
#   differing by at most one.
in_blocks <- function(x, blocks) {
  b = max(1L, min(as.integer(blocks), length(x)))
  if (b <= 1L) return(list(x))
  unname(split(x, ceiling(seq_along(x) / (length(x) / b))))
}

init_parallel <- function(cfg) {
  want = if (isTRUE(cfg$parallel)) max(1L, as.integer(cfg$workers %||% 1L)) else 1L

  if (identical(.wise$plan_workers, want)) return(invisible(want))

  if (want <= 1L) future::plan(future::sequential)
  else future::plan(future::multisession, workers = want)

  .wise$plan_workers <- want
  invisible(want)
}

plot_item_stack <- function(df, items, title, show_missing = TRUE) {
  long = df |>
    select(all_of(items)) |>
    mutate(across(everything(), as.numeric)) |>
    pivot_longer(everything(), names_to = "item", values_to = "value")
  if (!show_missing) long = filter(long, !is.na(value))
  lev = as.character(sort(unique(long$value[!is.na(long$value)])))
  long |>
    mutate(value = factor(if_else(is.na(value), "Missing", as.character(value)),
                          levels = c(lev, if (show_missing) "Missing"))) |>
    count(item, value) |>
    ggplot(aes(item, n, fill = value)) +
    geom_col(position = "fill") +
    scale_fill_manual(name = "Response",
                      values = c(set_names(viridis(length(lev)), lev),
                                 Missing = "grey75")) +
    labs(x = NULL, y = "Proportion", title = title,
         # Wrapped inline rather than through the app's fig_caption(), which
         #   lives in plots.R -- this file is shared by copy with the reference
         #   workflow and must not depend on anything the app adds.
         caption = str_wrap(paste(
           "Unweighted: this is the achieved sample, not the population. The",
           "weighted picture is the one every estimate later in the workflow",
           "reports."), 78)) +
    wise_theme() +
    wise_rotate_x()
}


# ---- engine_02_lca_em --------------------------------------------------

# Section 2 is the LCA measurement model: 
# weighted EM, label alignment across fits, and the two fit diagnostics. 
# LCA only
#______________________________________________________________________________

rand_init <- function(cats, K) { # pass K size and categories
  list(pi = {x = runif(K); x / sum(x)},
       rho = map(cats, function(Cj) {
         m = matrix(runif(Cj * K) + 0.1, Cj, K)
         sweep(m, 2, colSums(m), "/")
       }))
}

# One EM run as a fold. Y is a list of integer item vectors, 
# OH a list of one-hot category matrices. 
# A missing answer contributes 0 on the log scale, so it drops
#   out of the within-segment product

#__________ AI Assistance w/ this section, careful to not modify _______
em_run <- function(Y, OH, cats, w, K, init = NULL, maxit = 800L, tol = 1e-8) {
  nn = length(Y[[1]])
  st0 = c(init %||% rand_init(cats, K),
           list(post = NULL, ll = -Inf, iter = 0L, done = FALSE))

  step = function(state, .iter) {
    if (isTRUE(state$done)) return(state)
    log_terms = map2(state$rho, Y, function(rho_j, y) {
      lp = log(rho_j)[y, , drop = FALSE]
      lp[is.na(lp)] = 0
      lp
    })
    
    logdens = reduce(log_terms, `+`) + matrix(log(state$pi), nn, K, byrow = TRUE)
    lse = matrixStats::rowLogSumExps(logdens)
    post = exp(logdens - lse)
    ll = sum(w * lse)
    wp = w * post
    den = colSums(wp)
    rho_n = map(OH, function(oh) {
      num = pmax(crossprod(oh, wp), 1e-12)
      sweep(num, 2, colSums(num), "/")
    })
    list(pi = den / sum(den), rho = rho_n, post = post, ll = ll,
         iter = state$iter + 1L,
         done = abs(ll - state$ll) < tol * (abs(state$ll) + 1))
  }

  out = reduce(seq_len(maxit), step, .init = st0)
  out$converged = out$done

  # step() computes post and ll from the parameters it was HANDED and returns
  #   them beside the parameters it produced, so out$post was one M-step behind
  #   out$pi and out$rho. At convergence the gap is below tol and nothing
  #   noticed; on a run that stopped at maxit it is a posterior that is not the
  #   E-step of the model being reported, and entropy, the bivariate residuals
  #   and the BCH classification table are all read off it. One more E-step
  #   settles it.
  # out$ll is deliberately left where it was. It is what pick_survivors() ranks
  #   the short starts on and what BIC is formed from, and moving it by an
  #   epsilon would change which twenty of two hundred starts are finished --
  #   which could change the reported maximum and break parity with the
  #   reference reports for no methodological gain. The lag it carries is
  #   smaller than the convergence tolerance wherever the number is used.
  out$post = posterior_of(out$pi, out$rho, Y)
  out
}

make_inputs <- function(df, items, cats) {
  Y = map(items, function(it) as.integer(df[[it]]))
  OH = map2(items, cats, function(it, Cj) {
    oh = outer(as.integer(df[[it]]), seq_len(Cj), `==`) + 0
    oh[is.na(oh)] = 0
    oh
  })
  list(Y = Y, OH = OH)
}

# E-step under fixed parameters.
posterior_of <- function(pi, rho, Y) {
  nn = length(Y[[1]])
  K = length(pi)
  log_terms = map2(rho, Y, function(rho_j, y) {
    lp = log(rho_j)[y, , drop = FALSE]
    lp[is.na(lp)] = 0
    lp
  })
  logdens = reduce(log_terms, `+`) + matrix(log(pi), nn, K, byrow = TRUE)
  exp(logdens - matrixStats::rowLogSumExps(logdens))
}

# Segment labels are arbitrary. 
# Match any fit to a reference by response profile so segments are 
#   comparable across starts, fits, and replicates
profiles_of <- function(rho) do.call(cbind, map(rho, t))

align_to <- function(fit, ref) {
  K = length(fit$pi)
  Pf = profiles_of(fit$rho)
  Pr = profiles_of(ref$rho)
  cost = outer(seq_len(K), seq_len(K),
                Vectorize(function(a, b) sum((Pf[a, ] - Pr[b, ])^2)))
  inv = integer(K)
  inv[as.integer(clue::solve_LSAP(cost))] = seq_len(K)
  list(pi = fit$pi[inv],
       rho = map(fit$rho, function(m) m[, inv, drop = FALSE]),
       post = if (!is.null(fit$post)) fit$post[, inv, drop = FALSE] else NULL,
       ll = fit$ll,
       converged = fit$converged %||% NA)
}

# Seeds are passed as data rather than drawn inside the worker, 
#   so sequential and parallel plans return identical results
start_seeds <- function(cfg, K) as.integer(cfg$seed + 1000L * K + seq_len(cfg$n_starts))

# fit_lca() ran the whole start set in one sequential fold and rebuilt the
#   inputs on every call. model.R's best_of_starts() runs the identical EM on
#   the identical seeds, splits the starts across workers, and shares one set
#   of inputs; taking the best of the block maxima is the same fit as taking
#   the best of the starts. Two functions that fit the model is one too many
#   to keep in agreement, so this one went and the parallel one stayed.

df_k <- function(K, cats) (K - 1) + K * sum(cats - 1)

# Relative entropy on the weighted scale, so it describes the population model
#   rather than the achieved sample.
entropy_R2 <- function(post, w, K) {
  if (K == 1) return(NA_real_)
  1 + sum(w * rowSums(post * log(pmax(post, 1e-12)))) / (sum(w) * log(K))
}

# Two views of how much an item separates the segments, because they answer
#   different questions and a battery of mixed formats needs both.

# discrimination is the mean over segment pairs of the total variation 
#   distance between their response distributions. 
# It is bounded in [0, 1] for any number of categories and it is sensitive to 
#   shape: a segment that avoids the middle of a scale registers here even 
# if its mean sits where everyone else's does. 
# That suits a model which treats categories as unordered, which is what 
#   this one does.

# Range is how far the expected response travels across segments, as 
#   a share of the scale. 
# It assumes the categories are ordered, which the model does not, but
#   it is the quantity an analyst reads off a profile plot and it puts a 
#   binary item and a seven-point item on the same footing.

# An item can score high on one and low on the other. Where they disagree the
#   item is worth looking at rather than dropping.
item_discrimination <- function(fit, items) {
  pairs = combn(length(fit$pi), 2, simplify = FALSE)
  tibble(item = items,
         discrimination = map_dbl(fit$rho, function(rho_j) {
           mean(map_dbl(pairs,
                        function(p) 0.5 * sum(abs(rho_j[, p[1]] - rho_j[, p[2]]))))
         }),
         range = map_dbl(fit$rho, function(rho_j) {
           ev = as.numeric(seq_len(nrow(rho_j)) %*% rho_j)
           (max(ev) - min(ev)) / (nrow(rho_j) - 1)
         })) |>
    arrange(desc(discrimination))
}

# How much of the difference between segments is level and how much is pattern.
# Each item's expected response is scaled to run from 0 to 1 so that a binary
#   item and a four-category item contribute the same amount of possible spread;
#   without that the ratio is an artifact of the response formats. 
# A value well under 1 says the segments differ mainly in how high they 
#   answer overall, which is a continuum a factor model would describe 
#   with far fewer parameters. 
# Near or above 1 says they reorder the items, which is structure no single 
#   factor can hold.

# Both dispersions are weighted by segment size and computed about a weighted
#   centre. Unweighted, sd_level is the spread of K numbers in which a segment
#   holding four per cent of the population counts as much as one holding
#   forty, so the ratio moved with the size of the smallest segment rather than
#   with the shape of the battery. Weighting also puts the two halves on one
#   convention: both are now population quantities rather than one population
#   and one sample statistic.
# The ratio is descriptive and comparable within a battery, not across
#   batteries: the pattern residuals are constrained to sum to zero within a
#   segment, so their spread depends on the number of items. Nothing selects on
#   it and no threshold is attached to it.
level_pattern_ratio <- function(fit, items) {
  K = length(fit$pi)
  pi_k = fit$pi
  d = map(seq_len(K), function(k)
    tibble(segment = k, share = pi_k[k], item = items,
           m = map_dbl(fit$rho, function(r)
             (sum(seq_len(nrow(r)) * r[, k]) - 1) / (nrow(r) - 1)))) |>
    list_rbind() |>
    group_by(segment) |>
    mutate(level = mean(m)) |>
    ungroup()

  wsd = function(x, wt) {
    wt = wt / sum(wt)
    sqrt(sum(wt * (x - sum(wt * x))^2))
  }

  lev = distinct(d, segment, share, level)
  tibble(sd_level = wsd(lev$level, lev$share),
         sd_pattern = wsd(d$m - d$level, d$share)) |>
    mutate(ratio = sd_pattern / sd_level)
}

# Bivariate residual: total variation distance between the weighted observed
#   two-way table and the model-implied one. Bounded in [0, 1], zero under 
#  exact local independence. No reference distribution applies under a 
#  design-weighted pseudo-likelihood, so this ranks rather than tests.
bvr_pairs <- function(df, w, items, fit) {
  pr = t(combn(seq_along(items), 2L))
  map(seq_len(nrow(pr)), function(i) {
    a = pr[i, 1]
    b = pr[i, 2]
    # xtabs drops a row with a missing answer on either item, so the divisor 
    # has to be the weight of the pairwise-complete rows and not the whole 
    # sample.
    # With item-complete estimation the two coincide; with partial responders
    # they do not, and using sum(w) would leave the observed table short of 
    # one and inflate every residual.
    ok = !is.na(df[[items[a]]]) & !is.na(df[[items[b]]])
    obs = as.matrix(xtabs(w ~ factor(df[[items[a]]], seq_len(nrow(fit$rho[[a]]))) +
                             factor(df[[items[b]]], seq_len(nrow(fit$rho[[b]]))))) / sum(w[ok])

    # The same conditioning has to be applied to the other side of the
    #   comparison, and until now it was not. obs is the distribution among the
    #   respondents who answered BOTH items; fit$pi is the segment distribution
    #   in the whole analysis frame. Subtracting one from the other charges the
    #   pair for who answered it, and reports item nonresponse as local
    #   dependence. The mixing proportions are therefore re-estimated on the
    #   pairwise-complete rows from the posteriors already in hand.
    # Under item-complete fitting ok is every row and this reduces exactly to
    #   fit$pi, because the EM sets pi = colSums(w * post) / sum(w). So nothing
    #   moves on a complete-case run and the reference reports still match.
    pi_ok = if (all(ok)) fit$pi
            else colSums(w[ok] * fit$post[ok, , drop = FALSE]) / sum(w[ok])

    exp_p = fit$rho[[a]] %*% (pi_ok * t(fit$rho[[b]]))
    tibble(item_a = items[a], item_b = items[b],
           bvr = 0.5 * sum(abs(obs - exp_p)))
  }) |>
    list_rbind() |>
    arrange(desc(bvr))
}


# ---- engine_03_design_variance -----------------------------------------

# Section 3 builds the replicate design and computes variance from it.
# One design, and every standard error in the workflow comes off it.
#______________________________________________________________________________

# Stratified jackknife design. 
# Singleton strata are a hard stop: they cannot take the n_h / (n_h - 1) 
#   replicate scaling, and survey.lonely.psu governs linearization rather 
#   than replicate construction, so continuing would  understate variance 
#   in the strata with least information.

# This is built on the WHOLE analysis frame, never on a case-excluded subset.
#   Physically subsetting the data and rebuilding is the conditional
#   subpopulation approach: it drops PSUs, changes n_h and therefore the
#   n_h / (n_h - 1) scaling, and changes the degrees of freedom, so the
#   interval is no longer the design variance of a domain in the sample that
#   was actually drawn. SURV701 states the rule directly -- subset the design,
#   not the data -- and names dropped PSUs and singleton SECUs as the failure
#   mode. Every consumer here takes the full design and passes a `keep` index;
#   see replicate_variance() and subset() for the two ways that is done.

# mse = TRUE, explicitly. survey's default is getOption("survey.replicates.mse"),
#   which is FALSE, and svrVar() then centres the replicate spread on the mean
#   of the replicates. replicate_variance() below centres on the full-sample
#   estimate, which is the JRR formula in SURV701. Left at the default the two
#   halves of this workflow would report standard errors from two different
#   estimators and the report would compare their widths as though they were
#   one.
build_rep_design <- function(dat, cfg) {
  lonely = dat |>
    distinct(.data[[cfg$strata]], .data[[cfg$psu]]) |>
    count(.data[[cfg$strata]], name = "n_psu") |>
    filter(n_psu < 2)

  if (nrow(lonely) > 0) {
    print(lonely)
    stop(nrow(lonely), " stratum/strata contain a single PSU in the analysis ",
         "frame. Collapse them in the method config before continuing.")
  }

  des = svydesign(ids = reformulate(cfg$psu), strata = reformulate(cfg$strata),
                   weights = reformulate(cfg$weight), data = dat, nest = TRUE)
  list(des = des, rep_des = as.svrepdesign(des, type = "JKn", mse = TRUE))
}


# V = scale * sum_r rscale_r (theta_r - theta_hat)(theta_r - theta_hat)', the
#   delete-one JRR form in SURV701, centred on the full-sample estimate. That
#   is survey::withReplicates only when the design carries mse = TRUE, which is
#   why build_rep_design() sets it rather than leaving it at survey's default.
#   The expensive part (one refit per replicate) is mapped, not looped.

# keep is a logical index into the rows of the FULL design. Restricting the
#   replicate weights to those rows, rather than rebuilding the design on those
#   rows, is the unconditional subpopulation approach: the replicate structure,
#   the n_h / (n_h - 1) scaling and the degrees of freedom all stay those of
#   the sample that was drawn. For a ratio estimator, and for the weighted EM,
#   a zero-weight row and an absent row contribute identically, so restricting
#   the rows here and carrying zeros are the same computation at lower cost.

# theta_fun may mark a replicate by setting attr(x, "ok") to FALSE. Such a
#   replicate is COUNTED AND KEPT, not dropped: dropping a deviation can only
#   narrow the spread, whereas keeping it leaves the variance biased in an
#   unsigned direction and the count says so. The caller names what "not ok"
#   meant, because it is not the same thing in every use.
replicate_variance <- function(rep_des, theta_fun, theta_hat, keep = NULL) {
  Wm = weights(rep_des, type = "analysis")

  if (!is.null(keep)) {
    if (length(keep) != nrow(Wm))
      stop("The keep index has ", length(keep), " entries but the replicate ",
           "weights have ", nrow(Wm), " rows. It must index the full design ",
           "the replicate set was built on, not an already-subset frame.",
           call. = FALSE)
    Wm = Wm[keep, , drop = FALSE]
  }

  reps = future_map(seq_len(ncol(Wm)), function(r) theta_fun(Wm[, r]),
                    .options = furrr_options(seed = NULL))

  bad = sum(map_lgl(reps, function(x) isFALSE(attr(x, "ok"))))
  Theta = do.call(rbind, map(reps, as.numeric))

  d = sweep(Theta, 2, theta_hat, "-")
  travel = sqrt(rowSums(d^2))

  list(V = rep_des$scale * crossprod(d * sqrt(rep_des$rscales)),
       replicates = ncol(Wm),
       failed = bad,
       # Two numbers, not a function and a table. A replicate can sit far
       #   from the full-sample estimate for two reasons that call for
       #   opposite responses: the parameter is genuinely weakly identified,
       #   which small segments and modest separation both do, or one refit
       #   landed in a different configuration and align_to() matched it
       #   anyway. A heavy right tail says the second. Nothing is ever dropped
       #   on the strength of this; it is reported so a wide interval can be
       #   attributed rather than guessed at.
       travel_ratio = max(travel) / stats::median(travel),
       n_wild = sum(travel > 5 * stats::median(travel)))
}


# Modal assignment is an error-prone measurement of true segment, and cross
#    tabbing it against anything pulls the association toward the marginal. 
# D holds the design-weighted classification error rates, 
#   P(assigned s | truly k), and each respondent's hard assignment is 
#   replaced by row W of its inverse. 
# Entries can come out negative, which is a property of the correction rather 
# than a fault, and rows still sum to one because D's rows do.

# How well conditioned D has to be before its inverse is worth anything. An
#   exactly singular table stops the run because solve() refuses it; a
#   near-singular one -- a segment that took very few assignments -- does not,
#   and the correction it produces is unstable rather than wrong-looking. The
#   reciprocal condition number is attached to every call so the caller can
#   count the replicates where it fell through this floor and disclose them,
#   which is the only honest treatment available: there is nothing to repair.
BCH_RCOND_MIN <- 1e-8

bch_weights <- function(post, modal, w) {
  K = ncol(post)
  num = crossprod(w * post, outer(modal, seq_len(K), `==`) + 0)
  D = sweep(num, 1, rowSums(num), "/")
  structure(solve(D)[modal, , drop = FALSE], rcond = rcond(D))
}


# ---- engine_04_lca_predict ---------------------------------------------

# Section 4 scores respondents from a fitted model, including those who
#   skipped items. Local independence is what makes that possible: a missing
#   answer drops out of the product rather than disqualifying the respondent.
#______________________________________________________________________________

# Posterior segment membership for any respondents carrying the item columns.
# Items arrive already recoded by the method config, so the fitted and the
#   predicted frames are on the same coding by construction.
predict_segments <- function(df, fit, items, min_items) {
  K = length(fit$pi)
  Y = map(items, function(it) as.integer(df[[it]]))
  post = posterior_of(fit$pi, fit$rho, Y)
  answered = reduce(Y, function(a, y) a + as.integer(!is.na(y)),
                     .init = integer(nrow(df)))

  seg = max.col(post, ties.method = "first")
  seg[answered < min_items] = NA_integer_

  colnames(post) = paste0("post_segment", seq_len(K))
  bind_cols(
    tibble(segment = seg,
           max_posterior = if_else(is.na(seg), NA_real_, matrixStats::rowMaxs(post)),
           n_items_answered = answered),
    as_tibble(post))
}


# ---- engine_05_prompts_label -------------------------------------------

# Section 5 drafts names for whatever the latent variable turned out to be.
# The prompt takes a parameter table, so it reads whatever the fit produced.
#______________________________________________________________________________
# One call per segment. 
# A joint prompt confuses near-neighbor segments, because a forced one-to-one 
#   assignment lets one confusion corrupt two labels. 
# Labels are drafts for the analyst to verify against the response profiles; 
#   they never feed back into estimation. The JSON keys stay 
#   label/description/class for stability.

# Personas and rules are plain strings. 
# They never take an argument and the certification harness diffs them 
#   between runs, so a function would only get in the way.

persona_lca <- paste(
  "You are a senior survey methodologist who reads latent class analysis",
  "(LCA) measurement models. In this work each latent class is called a",
  "SEGMENT; that is a word-choice preference and the statistical object is",
  "unchanged. Each segment is described only by its item-response",
  "probabilities: for every survey item, the probability that a member of",
  "that segment gives each answer. A segment leans toward the answers with",
  "high probability. You interpret a segment strictly from these",
  "probabilities and the item wording, never from outside assumptions.")
rules_label <- paste(
  "RULES:",
  "1. Use only the numbers and item wording shown. Survey context only",
  "   clarifies what the items refer to; attribute nothing that the numbers",
  "   do not show.",
  "2. Quote a probability exactly as it is printed, for one response category",
  "   at a time. Never add probabilities across categories and never describe a",
  "   combined or total probability. If two adjacent answers both matter, name",
  "   them separately with their own numbers.",
  "3. Anchor every statement to the items that stand out most.",
  "4. If nothing stands out, say the profile is diffuse rather than inventing",
  "   a theme.",
  "5. Return only valid JSON: no prose before or after, no markdown fences.",
  sep = "\n")

# Domain rules are stricter because the reader will act on them. 
# The analyst has already decided which differences clear the interval; 
#   the model is told the answer and only translates it. 
# It never sees a standard error and never decides significance for itself.
rules_domain <- paste(
  "RULES:",
  "1. Describe a difference only where it appears in the list above. For any",
  "   pair not listed, say the data do not separate the groups.",
  "   overlap. Where they overlap, say the data do not separate the groups.",
  "2. Do not rank levels whose intervals overlap.",
  "3. Never use causal language. Groups differ in composition; being in a",
  "   group does not cause membership.",
  "4. Say nothing about a level flagged as too small.",
  "5. Report at most the four clearest differences. The point is to tell the",
  "   analyst where to look, not to narrate every cell.",
  "6. When the design changes an estimate or an interval, say so plainly and use",
  "   the numbers given. Do not treat a narrower interval as better or a wider",
  "   one as worse; the design-based figure is the honest one either way.",
  "7. Return only valid JSON: no prose before or after, no markdown fences.",
  "8. Each estimate is followed by a 95 percent confidence interval, which",
  "   expresses sampling uncertainty. Where the analysis did not resolve a",
  "   pair, say the data do not separate them; do not say they are equal or",
  "   similar, since an unresolved pair may differ by more than this sample",
  "   can detect.",
  "9. The differences listed were tested on the estimator named beside them,",
  "   which is not always the estimator whose numbers are printed. Do not",
  "   claim a tested difference is larger or smaller under the other one, and",
  "   do not describe either as the conservative reading; whether correcting",
  "   for classification error strengthens or weakens a contrast depends on",
  "   the correction, and neither direction is guaranteed.",
  sep = "\n")

# dictionary supplies the question wording and the response labels, in the 
#   same order as the fitted category indices.
format_segment_block <- function(fit, k, dictionary, items) {
  lines = map_chr(seq_along(items), function(j) {
    d = filter(dictionary, item == items[j])
    probs = paste(sprintf("P(%s)=%.2f", d$responses[[1]], fit$rho[[j]][, k]),
                   collapse = ", ")
    str_glue('  {items[j]} "{d$question}"\n      {probs}')
  })
  str_glue("SEGMENT {k} (estimated prevalence {round(100 * fit$pi[k])}%):\n",
           paste(lines, collapse = "\n"))
}

prompt_segment_label <- function(fit, k, dictionary, items, context = NULL) {
  ctx = if (!is.null(context) && nzchar(context))
    str_glue("SURVEY CONTEXT\n{context}\n\n") else ""
  str_glue(
    "{ctx}",
    "ONE SEGMENT FROM A LATENT CLASS ANALYSIS (LCA) MEASUREMENT MODEL\n",
    "{format_segment_block(fit, k, dictionary, items)}\n\n",
    "TASK\n",
    "Read this single segment and return: a short DRAFT label (2 to 5 words) ",
    "for an analyst to refine, and a one or two sentence factual description ",
    "anchored to its high-probability answers. Each probability above belongs ",
    "to one response category; they are not yours to add together.\n\n",
    "{rules_label}\n",
    'JSON (one object): {{"label": "...", "description": "..."}}')
}

# The chat object, the JSON reader and the per-segment labelling loop used to
#   live here. They now live in llm.R, and the copies here were removed rather
#   than left in place for three reasons.

# The first is a key. This file's chat builder wrote the analyst's key into the
#   R process with Sys.setenv(OPENAI_API_KEY = ...). On a laptop that is
#   untidy; on a Connect server it is a disclosure, because the process is
#   shared and the variable outlives the session that set it. llm.R holds the
#   key in a session-scoped registry that is discarded when the browser tab
#   closes, and that is the only place a key should ever be.

# The second is a name. parse_json_block() was defined here and again in
#   llm.R. R sourced both, the second silently replaced the first, and which
#   one ran depended on the alphabet. Two definitions of one name is a
#   coin-flip dressed as code.

# The third is that nothing called any of it. The app labels segments through
#   model.R, which calls llm_json(). Dead code that looks live is what an
#   auditor reads by mistake.

# Per-segment isolation has one blind spot: two neighbors can draft the same
#   label, since neither call saw the other. 
# One closing call edits only the labels  that collide, and runs only when 
#   this mechanical check fires.
labels_collide <- function(labels) {
  # One name has nothing to collide with, and combn() will not enumerate the
  #   pairs of a single element -- it stops with "n < m". Because t() is an S4
  #   generic once Matrix is loaded, that surfaces as "error in evaluating the
  #   argument 'x' in selecting a method for function 't'", which names neither
  #   this function nor the cause. K is always at least two here, so the guard
  #   is insurance rather than a live path.
  if (length(labels) < 2L) return(FALSE)

  ws = map(str_squish(tolower(labels)), function(s) unique(strsplit(s, " ")[[1]]))
  pr = t(combn(length(labels), 2L))
  any(map_dbl(seq_len(nrow(pr)), function(i) {
    a = ws[[pr[i, 1]]]
    b = ws[[pr[i, 2]]]
    length(intersect(a, b)) / length(union(a, b))
  }) >= 0.5)
}

prompt_harmonize <- function(lab) {
  rows = str_glue_data(lab, "SEGMENT {K}: LABEL \"{Label}\" | DESCRIPTION: {Description}")
  str_glue(
    "DRAFT LABELS FOR THE SEGMENTS OF ONE LATENT CLASS ANALYSIS (LCA) MODEL\n",
    "{paste(rows, collapse = '\n')}\n\n",
    "TASK\n",
    "Some labels are too similar to tell apart. Edit ONLY the labels that ",
    "overlap, as little as possible, so every label is distinct; anchor each ",
    "edit to that segment's own description. Keep every non-overlapping label ",
    "verbatim. Do not change any description. Labels stay 2 to 5 words.\n\n",
    "{rules_label}\n",
    'JSON (one array, all segments): [{{"class": 1, "label": "..."}}, ...]')
}
pick_estimator <- function(dom, est) {
  if(!"estimator" %in% names(dom))
    stop("dom has no estimator column. Pass the full three-estimator domain ",
         "frame from the domains chunk, not a filtered copy.")
  if(!est %in% dom$estimator)
    stop("estimator '", est, "' is not present in dom. Levels found: ",
         paste(unique(dom$estimator), collapse = ", "))
  filter(dom, estimator == !!est)
}

# Lays one demographic out segment by segment, because that is the way the
#   result gets read and written up. Levels under min_n are marked rather than
#   dropped so the model can see they exist and still be told to leave them
#   alone. values_header names what the numbers are. est names the estimator
#   whose rows are shown, rather than taking one by position.
# var_label is what the variable is called in prose; it defaults to the
#   variable name, so an older caller is unaffected. Only the wording changes:
#   every row is still selected on `variable`.
format_domain_block <- function(
    dom, marg, variable, labels = NULL, min_n = 30,
    values_header = "Share of each level falling in each segment:",
    est = "Design-based", var_label = NULL) {
  var_label = var_label %||% variable
  d = pick_estimator(dom, est) |> filter(variable == !!variable)
  m = filter(marg, variable == !!variable)
  # n_scored is what domain_marginals() supplies now. The fallback keeps an
  #   older marginal frame -- a cached one, or one built by a script off cfg.R
  #   -- working rather than failing on a column name.
  n_basis = if("n_scored" %in% names(m)) m$n_scored else m$n
  segs = sort(unique(d$segment))
  lines = map_chr(segs, function(k) {
    nm = if(is.null(labels)) paste0("Segment ", k) else labels[k]
    dd = filter(d, segment == k)
    cells = map_chr(seq_len(nrow(dd)), function(i) {
      # The count a small-cell flag has to be read against is the number of
      #   respondents the estimate rests on, which is the scored count, not
      #   everyone in the file at that level. Where the two differ it is item
      #   nonresponse that separates them, and flagging on the larger of the
      #   two says a cell is adequate on the strength of respondents who
      #   contributed nothing to it.
      n_lv = n_basis[m$level == dd$level[i]]
      flag = if(length(n_lv) && !is.na(n_lv) && n_lv < min_n) " [too small]" else ""
      sprintf("%s %.2f [%.2f, %.2f]%s", dd$level[i], dd$p[i], dd$lo[i],
              dd$hi[i], flag)
    })
    str_glue("  {nm}\n      {paste(cells, collapse = ', ')}")
  })
  shares = map_chr(seq_len(nrow(m)), function(i)
    sprintf("%s %d%% (scored n = %d)", m$level[i], round(100 * m$weighted[i]),
            n_basis[i]))
  # "In the population" is now true of this line: the marginal is a weighted
  #   estimate over the whole design, not over the respondents the model could
  #   place. The count beside it is the scored count, and it is labelled as
  #   such, because the two answer different questions and running them
  #   together is what let a composition estimated on scored respondents be
  #   read as the composition of the population.
  str_glue("{var_label} in the population: {paste(shares, collapse = ', ')}\n",
           "{values_header}\n",
           paste(lines, collapse = "\n"))
}

# What changes when the design is taken into account: how far the point
#   estimate moves and whether the interval widens or narrows. The comparison 
#   is unweighted against design-based by name, so reordering the estimator 
#   levels cannot silently change what is compared.
format_estimator_shift <- function(dom, variable, labels = NULL) {
  base = pick_estimator(dom, "Unweighted") |> filter(variable == !!variable)
  desg = pick_estimator(dom, "Design-based") |> filter(variable == !!variable)
  w = inner_join(
    transmute(base, level, segment, p0 = p, w0 = hi - lo),
    transmute(desg, level, segment, p1 = p, w1 = hi - lo),
    by = c("level", "segment"))
  lines = map_chr(seq_len(nrow(w)), function(i) {
    nm = if(is.null(labels)) paste0("Segment ", w$segment[i]) else labels[w$segment[i]]
    str_glue("  {nm}, {w$level[i]}: design moves the estimate by ",
             "{sprintf('%+.3f', w$p1[i] - w$p0[i])} and makes the interval ",
             "{sprintf('%.2f', w$w1[i] / w$w0[i])} times as wide")
  })
  paste(lines, collapse = "\n")
}

# Which level pairs actually separate, worked out here rather than by the model.
#   With wald supplied, a pair counts as apart when the design-based test
#   on its difference clears alpha after Holm adjustment within the 
#   demographic, using the replicate covariance between the two estimates. 
# Without it, the old rule applies: intervals that miss each other, which is 
# more conservative than a test and is kept as the fallback.
domain_separations <- function(dom, variable, labels = NULL,
                               est = "Design-based", wald = NULL,
                               alpha = 0.05) {
  seg_name = function(k) if(is.null(labels)) paste0("Segment ", k) else labels[k]
  if(is.null(wald)) {
    d = pick_estimator(dom, est) |> filter(variable == !!variable)
    hits = crossing(a = unique(d$level), b = unique(d$level),
                    segment = unique(d$segment)) |>
      filter(a < b) |>
      left_join(select(d, level, segment, lo_a = lo, hi_a = hi),
                by = c("a" = "level", "segment")) |>
      left_join(select(d, level, segment, lo_b = lo, hi_b = hi),
                by = c("b" = "level", "segment")) |>
      filter(lo_a > hi_b | lo_b > hi_a) |>
      arrange(segment)
    crit_line = "  Criterion: 95 percent intervals that do not overlap."
  } else {
    m = filter(wald$meta, variable == !!variable)
    v_diag = diag(wald$V)
    hits = crossing(a = unique(m$level), b = unique(m$level),
                    segment = unique(m$segment)) |>
      filter(a < b) |>
      left_join(select(m, level, segment, idx_a = idx),
                by = c("a" = "level", "segment")) |>
      left_join(select(m, level, segment, idx_b = idx),
                by = c("b" = "level", "segment")) |>
      mutate(delta = wald$est[idx_a] - wald$est[idx_b],
             se = sqrt(pmax(v_diag[idx_a] + v_diag[idx_b]
                            - 2 * wald$V[cbind(idx_a, idx_b)], 0)),
             p = if_else(se > 0, 2 * pt(-abs(delta / se), wald$df),
                         if_else(abs(delta) > 0, 0, 1)),
             p_adj = p.adjust(p, "holm")) |>
      filter(p_adj < alpha) |>
      arrange(segment, p_adj)
    crit_line = paste0("  Criterion: pairwise design-based tests on the ",
                       "replicate covariance of the ", est, " estimator, ",
                       "Holm-adjusted within this demographic. The estimates ",
                       "printed above may come from a different estimator; ",
                       "where they do, this line says which was tested.")
  }
  if(nrow(hits) == 0)
    return(paste(crit_line, "  None: no pair of levels is resolved.", sep = "\n"))
  paste(c(crit_line,
          map_chr(seq_len(nrow(hits)), function(i)
            str_glue("  {seg_name(hits$segment[i])}: {hits$a[i]} differs from {hits$b[i]}"))),
        collapse = "\n")
}
prompt_domain_read <- function(
    dom, marg, variable, labels = NULL, context = NULL, min_n = 30,
    values_header = "Share of each level falling in each segment:",
    est = "Design-based", wald = NULL, var_label = NULL) {
  var_label = var_label %||% variable
  ctx = if(!is.null(context) && nzchar(context)) str_glue("SURVEY CONTEXT\n{context}\n\n") else ""
  str_glue(
    "{ctx}",
    "COMPOSITION OF THE POPULATION AND OF EACH GROUP\n",
    "{format_domain_block(dom, marg, variable, labels, min_n, values_header, est, var_label)}\n\n",
    "DIFFERENCES THE ANALYSIS RESOLVED\n",
    "{domain_separations(dom, variable, labels, est, wald)}\n\n",
    "WHAT THE SURVEY DESIGN CHANGES\n",
    "{format_estimator_shift(dom, variable, labels)}\n\n",
    "TASK\n",
    "Write two or three sentences telling an analyst what this variable shows ",
    "and where to look. Call it \"{var_label}\" and never use a variable code. ",
    "Name only the differences listed above. In the caution ",
    "field, say what accounting for the survey design changed: whether it moved ",
    "any estimate enough to matter and whether it made the intervals wider or ",
    "narrower.\n\n",
    "{rules_domain}\n",
    'JSON (one object): {{"finding": "...", "caution": "..."}}')
}

