# model.R for DrSvyR
# Configuration, the dimension search, the fitted model, and the names.

# Merged from: 
#   stage_04_config.R
#   stage_05_search.R
#   stage_06_model.R
#   stage_07_labels.R

# ---- stage_04_config ---------------------------------------------------

# Stage 5: assemble the analysis specification and write it out.

#   1. Building the configuration
#   2. Reading it back in plain language
#   3. Writing it to the work folder

# Everything decided so far becomes one object. The app uses it directly; the
#   same object is written to the work folder as an R script so the analysis can
#   be re-run, checked or handed on without the app.

# The model does not write this. It is rendered from decisions the analyst
#   already made, by code, so there is no step at which a plausible-looking
#   wrong value can enter the specification.

# Requires: dplyr, purrr, tibble, glue, fs, yaml


# Section 1 assembles the configuration.
#______________________________________________________________________________

# Fixed rather than exposed: these are properties of the method, and an analyst
#   who is not a modeller has no basis for changing them. Recorded here so that
#   what was fixed is visible rather than buried in a function default.
WISE_FIXED <- list(
  seed = 2026L,

  # Two hundred throughout, search and final fit alike. A weighted mixture
  #   likelihood has local maxima that a smaller start set finds inconsistently,
  #   and a search that ranks sizes on inconsistently located maxima is ranking
  #   the optimiser rather than the models.
  n_starts = 200L,

  # Every one of those two hundred is tried, but not all the way. Most random
  #   starts declare themselves within a few dozen iterations: on this
  #   battery the median run converges in about 145 iterations and the worst
  #   takes 609, and the expensive ones are overwhelmingly the ones heading
  #   somewhere worse. So all n_starts run for n_short iterations, the best
  #   n_keep of them are carried to convergence from where they reached, and
  #   the rest are dropped.

  # This is the design Mplus calls STARTS = 200 20 and it is not a shortcut:
  #   the full start set is still tried at every size, which is the whole of
  #   the argument above. Measured on a 2,400-respondent battery of twelve
  #   four-category items it finds the identical maximum at every size from
  #   two to seven groups, to six decimal places, in about a third of the
  #   time.
  n_short = 30L,
  n_keep = 20L,

  K_range = 2:10,
  parallel = TRUE)

build_cfg <- function(state) {
  fr = state$item_frame

  cfg = list(
      items = fr$items,
      cats = fr$cats,
      aux = names(state$demo_dat),

      # Display names, keyed by the same variable names as aux. Nothing is
      #   computed from these: every estimate, every population share and
      #   every by-formula is built from aux itself. See aux_label() in core.R.
      aux_labels = purrr::map_chr(
        rlang::set_names(names(state$demo_dat)),
        function(v) {
          s = state$demo_specs[[v]]
          as.character(s$label %||% v)
        }),

      strata = "strata", psu = "psu", weight = "wt", id = "id",
      na_codes = state$na_codes,
      complete_cases = all(fr$in_analysis == (fr$n_answered == length(fr$items))),
      seed = WISE_FIXED$seed,
      parallel = WISE_FIXED$parallel,
      # Resolved from the environment rather than from the host's core count,
      #   so the laptop and the Shiny server can differ without either of them
      #   needing a different copy of this file. See wise_workers() in core.R.
      workers = wise_workers(),
      survey_context = state$context %||% "",
      research_question = state$question %||% "",

      # No method level in the path any more. Anything an earlier version
      #   wrote to output/lca/ stays where it is; nothing writes there again.
      out_dir = wise_path("output"),

      K_range = WISE_FIXED$K_range,
      K_force = NULL,
      n_starts = WISE_FIXED$n_starts,
      n_short = WISE_FIXED$n_short,
      n_keep = WISE_FIXED$n_keep,
      min_items = fr$min_items)

  fs::dir_create(cfg$out_dir)
  cfg
}


# Section 2 reads the configuration back to the analyst. One row per decision,
#   in the order the decisions were made, so approving it is a review of the
#   session rather than an inspection of a data structure.
#______________________________________________________________________________

config_summary <- function(state, cfg) {
  fr = state$item_frame
  dm = state$design_map

  row = function(stage, decision, value)
    tibble::tibble(Stage = stage, Decision = decision,
                   Value = as.character(value))

  dplyr::bind_rows(
    row("Project", "Survey file", fs::path_file(state$data_file)),
    row("Project", "Respondents in file", format(nrow(state$raw), big.mark = ",")),
    row("Project", "Work folder", state$work_dir),

    row("Design", "Respondent id", dm[["id"]]),
    row("Design", "Stratum", dm[["strata"]]),
    row("Design", "Primary sampling unit", dm[["psu"]]),
    row("Design", "Weight", dm[["weight"]]),
    row("Design", "Strata / PSUs",
        paste0(dplyr::n_distinct(state$design_dat$strata), " / ",
               dplyr::n_distinct(state$design_dat$psu))),
    row("Design", "Warnings accepted",
        sum(state$design_checks$status == "warn")),

    row("Items", "Battery", paste(fr$items, collapse = ", ")),
    row("Items", "Items", length(fr$items)),
    row("Items", "Treated as missing", paste(cfg$na_codes, collapse = ", ")),
    row("Items", "Fitted on",
        paste0(format(sum(fr$in_analysis), big.mark = ","), " respondents",
               if (cfg$complete_cases) " (answered every item)"
               else paste0(" (answered at least ", fr$min_items, ")"))),

    row("Model", "Range searched",
        paste0(min(cfg$K_range), " to ", max(cfg$K_range), " groups")),

    # The question is on the record here as well as in the report, because the
    #   configuration table is what the analyst approves and what the decision
    #   log keeps. A question written after the results are known is a question
    #   chosen to fit them.
    row("Model", "Research question",
        if (nzchar(cfg$research_question %||% "")) cfg$research_question
        else "not set"),

    # The name the report will use is a decision like any other, so it is on
    #   the sheet the analyst approves rather than discovered in the output.
    purrr::imap(state$demo_specs, function(s, nm)
      row("Domains", paste0(nm, " shown as \u201c", s$label %||% nm, "\u201d"),
          paste0(nlevels(state$demo_dat[[nm]]), " groups, reference ",
                 s$reference %||% "not set"))) |> purrr::list_rbind(),

    row("Fixed", "Random seed", cfg$seed),
    row("Fixed", "Parallel workers", wise_workers_note()),
    row("Fixed", "Starts per model", cfg$n_starts),
    row("Fixed", "Output folder", cfg$out_dir))
}

# A plain-language restatement for the analyst to check the table against. The
#   model is describing decisions it did not make; if the paragraph does not
#   match the table, something is wrong with the configuration and this is the
#   cheapest place to catch it.
prompt_config_readback <- function(summary_tbl, context) {
  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "THE ANALYSIS AS CONFIGURED\n{log_table(summary_tbl)}\n\n",
    "TASK\nRestate this plan in one short paragraph, as you would to a",
    " colleague who will read the results but did not set it up. Say what is",
    " being measured, on whom, how many respondents it rests on, and what will",
    " be compared at the end. Do not evaluate the plan, do not suggest changes,",
    " and do not add anything that is not in the table.\n\n",
    "Return only valid JSON, no prose and no markdown fences:\n",
    '{{"summary": "..."}}')
}


# Section 3 writes it out. The R file is what makes the analysis reproducible
#   without the app; the YAML is the dictionary that travels with the data.
#______________________________________________________________________________

# Deparsed rather than templated. A template would need a branch per field type
#   and would silently mis-render the first field shape it did not anticipate.
write_cfg <- function(cfg, path) {
  fields = purrr::imap_chr(cfg, function(v, nm)
    paste0("  ", nm, " = ", paste(deparse(v), collapse = "\n    ")))

  writeLines(c(
    "# cfg.R -- written by DrSvyR. Do not edit by hand.",
    "# Re-running the analysis from this file reproduces what the app did.",
    paste0("# Written ", format(Sys.time(), "%Y-%m-%d %H:%M")),
    "",
    "cfg <- list(",
    paste(fields, collapse = ",\n"),
    ")"), path)
  invisible(path)
}

write_data_dict <- function(state, cfg, path) {
  fr = state$item_frame

  doc = list(
    name = fs::path_file(state$data_file),
    description = cfg$survey_context,
    tables = list(list(
      name = "survey",
      rows = nrow(state$raw),
      columns = c(
        purrr::map(seq_len(nrow(fr$dictionary)), function(i) list(
          name = fr$dictionary$item[i],
          source = fr$dictionary$variable[i],
          role = "item",
          description = fr$dictionary$question[i],
          values = as.list(fr$dictionary$responses[[i]]))),
        purrr::imap(state$demo_specs, function(s, nm) list(
          name = nm,
          source = s$source,
          role = "domain",
          description = s$label %||% nm,
          reference = s$reference %||% levels(state$demo_dat[[nm]])[1],
          values = as.list(levels(state$demo_dat[[nm]])))),
        purrr::imap(state$design_map, function(v, role) list(
          name = role, source = v, role = "design"))))),
    missing_values = as.list(cfg$na_codes))

  yaml::write_yaml(doc, path)
  invisible(path)
}

# ---- stage_05_search ---------------------------------------------------

# Stage 6: search over the number of groups.

#   1. The search
#   2. What the analyst looks at
#   3. Prompt

# Nothing here selects the number of groups. The search renders the evidence,
#   stops, and waits for a number. That decision is recorded with the evidence that was in front
#   of the analyst when they made it.

# Requires: dplyr, purrr, tibble, ggplot2, tidyr


# Section 1 fits the class model at every candidate size.
#______________________________________________________________________________

# Information criteria rescale the log-likelihood to the sum-to-n scale. Under
#   a design-weighted pseudo-likelihood the weighted log-likelihood is on the
#   scale of the population total, and without the rescaling BIC leans toward
#   too many segments.

# The fits are kept, not just the statistics: the profiles are what the analyst
#   can actually judge, and refitting to draw them would double the wait.
# Parallel over blocks of starting values rather than over K. Splitting by K
#   alone leaves the largest model running alone at the end; splitting the
#   starts balances the load and keeps every worker busy to the finish.

# Determinism is unaffected. Seeds are drawn in this session and passed to the
#   workers as data, so no worker touches the random number generator and the
#   result is identical under any number of workers or a sequential plan.

# The inputs are built once and shared. make_inputs() is not free, and calling
#   it inside every start repeated it a thousand times over.

# Stage one. Every seed, run only far enough to tell a promising basin from a
#   hopeless one. The fits are returned whole rather than as log-likelihoods,
#   because stage two restarts from these parameters rather than from the
#   seed, which is what makes the second stage cheap.
short_starts <- function(inp, cats, w, K, seeds, short, tol = 1e-8) {
  purrr::map(seeds, function(s) {
    set.seed(s)
    em_run(inp$Y, inp$OH, cats, w, K, maxit = short, tol = tol)
  })
}

# Stage two. The survivors, carried to convergence from where stage one left
#   them. No seed is drawn here: the starting parameters come from stage one,
#   so the random number generator is never touched and the result does not
#   depend on how the work was divided.
finish_starts <- function(inp, cats, w, K, inits, maxit = 800L, tol = 1e-8) {
  purrr::map(inits, function(init)
    em_run(inp$Y, inp$OH, cats, w, K, init = init[c("pi", "rho")],
           maxit = maxit, tol = tol))
}

# Which of stage one's fits are worth finishing. Chosen across the whole start
#   set rather than within each worker's block: the best twenty of two hundred
#   is one answer, while the best twenty of each of four blocks of fifty is a
#   different one, and the machine's core count must not decide which model
#   the analyst is shown.
pick_survivors <- function(fits, keep) {
  ll = purrr::map_dbl(fits, "ll")
  fits[order(ll, decreasing = TRUE)[seq_len(min(keep, length(ll)))]]
}

# The two stages run one after the other, each spread across the workers. Two
#   dispatches per size rather than one, which costs a second of serialising
#   the item matrices and saves minutes of fitting.
best_of_starts <- function(inp, cats, w, K, seeds, cfg,
                           maxit = 800L, tol = 1e-8) {
  n_blocks = max(1L, cfg$workers %||% 1L)
  short = cfg$n_short %||% WISE_FIXED$n_short
  keep = cfg$n_keep %||% WISE_FIXED$n_keep

  first = furrr::future_map(
    in_blocks(seeds, n_blocks),
    function(sd) short_starts(inp, cats, w, K, sd, short, tol),
    .options = furrr::furrr_options(seed = NULL)) |>
    purrr::list_flatten()

  live = pick_survivors(first, keep)

  parts = furrr::future_map(
    in_blocks(live, n_blocks),
    function(ii) finish_starts(inp, cats, w, K, ii, maxit, tol),
    .options = furrr::furrr_options(seed = NULL)) |>
    purrr::list_flatten()

  parts[[which.max(purrr::map_dbl(parts, "ll"))]]
}

search_sizes <- function(cfg, dat, tick = NULL) {
  w = dat$wt
  n = nrow(dat)
  scale = n / sum(w)

  init_parallel(cfg)
  inp = make_inputs(dat, cfg$items, cfg$cats)

  # The full start set at every size. A weighted mixture likelihood has local
  #   maxima that a smaller set finds inconsistently, and a search that ranks
  #   sizes on inconsistently located maxima ranks the optimiser rather than
  #   the models.
  # The sizes run one after another rather than all at once, so the progress
  #   bar can say which size is being fitted. Flattening them into a single
  #   dispatch would balance the workers slightly better and cost the analyst
  #   the only indication that a five-minute wait is progressing.
  fits = purrr::map(cfg$K_range, function(K) {
    if (!is.null(tick)) tick(K)
    best_of_starts(inp, cfg$cats, w, K, start_seeds(cfg, K), cfg)
  }) |> rlang::set_names(as.character(cfg$K_range))

  stats = purrr::imap(fits, function(fit, k) {
    K = as.integer(k)
    ll = fit$ll * scale
    df = df_k(K, cfg$cats)
    tibble::tibble(
      K = K,
      loglik = round(ll, 1),
      parameters = df,
      BIC = round(-2 * ll + df * log(n), 1),
      AIC = round(-2 * ll + 2 * df, 1),
      entropy = round(entropy_R2(fit$post, w, K), 3),
      smallest_group = round(min(fit$pi), 3),
      converged = isTRUE(fit$converged))
  }) |>
    purrr::list_rbind() |>
    dplyr::mutate(
      # A model with more parameters than the sample can support will still fit
      #   and still report a BIC. Saying so is cheaper than an analyst choosing
      #   a size the data cannot carry.
      flag = dplyr::case_when(
        !converged ~ "did not converge",
        parameters > n / 10 ~ "more parameters than the sample supports",
        smallest_group < 0.03 ~ "smallest group under 3% of the sample",
        TRUE ~ NA_character_))

  list(stats = stats, fits = fits)
}


# Section 2 is what the analyst looks at: the response profile of each group
#   at each candidate size, on one scale so the shapes can be compared.
#______________________________________________________________________________
profile_frame <- function(fit, items, labels = NULL) {
  K = length(fit$pi)
  purrr::map(seq_len(K), function(k)
    tibble::tibble(
      group = if (is.null(labels)) paste0("Group ", k) else labels[k],
      share = fit$pi[k],
      item = items,
      value = purrr::map_dbl(fit$rho, function(r)
        (sum(seq_len(nrow(r)) * r[, k]) - 1) / (nrow(r) - 1)))) |>
    purrr::list_rbind()
}

plot_profiles <- function(fit, items, title = NULL) {
  d = profile_frame(fit, items) |>
    dplyr::mutate(group = paste0(group, " (", round(100 * share), "%)"))

  ggplot2::ggplot(d, ggplot2::aes(item, value, group = group, colour = group)) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::scale_colour_viridis_d(name = NULL) +
    ggplot2::labs(x = NULL, y = "Position on the item", title = title) +
    wise_theme() + wise_rotate_x()
}

plot_bic <- function(stats) {
  stats |>
    dplyr::select(K, BIC, AIC) |>
    tidyr::pivot_longer(-K, names_to = "criterion", values_to = "value") |>
    ggplot2::ggplot(ggplot2::aes(K, value, colour = criterion)) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 2) +
    ggplot2::scale_x_continuous(breaks = stats$K) +
    ggplot2::scale_colour_viridis_d(name = NULL, end = 0.7) +
    ggplot2::labs(x = "Number of groups", y = NULL,
                  caption = fig_caption(
                    "Lower is better. A flattening curve says the extra",
                    "groups are buying little.")) +
    wise_theme()
}

prompt_search_narration <- function(stats, chosen, context) {
  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "SEARCH EVIDENCE\n{log_table(stats)}\n\n",
    "THE ANALYST HAS CHOSEN\n  {chosen} groups\n\n",
    "TASK\nIn four or five sentences, tell the analyst what this evidence says",
    " about the number they chose. Say where the criteria point, whether they",
    " agree with each other, and what the analyst is trading away if the",
    " evidence points elsewhere. If any row is flagged, say what the flag",
    " means for that number. Do not tell them to change their choice and do not",
    " suggest removing an item.\n\n",
    "Return only valid JSON, no prose and no markdown fences:\n",
    '{{"reading": "...", "agrees_with_choice": true or false}}')
}

# ---- stage_06_model ----------------------------------------------------

# Stage 7: fit at the chosen dimension and diagnose it.

#   1. The model
#   2. Intervals on it
#   3. Prompt

# The search ranked sizes. This fits the one the analyst chose, from the full
#   start set, and reports what the model does not account for. The diagnostics
#   rank items and pairs; none of them is a test, and the model narrating them
#   is forbidden from recommending a removal.

# Requires: dplyr, purrr, tibble, ggplot2, tidyr


# Section 1 fits at the chosen number of groups.
#______________________________________________________________________________

# Not called by the app. The app takes its fit from the search, which already
#   ran this exact call at this exact K -- see the fit step in ui_model.R. This
#   is the entry point for a script working from the written cfg.R, where
#   there is no search object to take a fit out of.
fit_final <- function(cfg, dat, K) {
  init_parallel(cfg)
  inp = make_inputs(dat, cfg$items, cfg$cats)
  w = dat$wt

  best_of_starts(inp, cfg$cats, w, K, start_seeds(cfg, K), cfg)
}

# Response probabilities as the analyst reads them: one row per item and
#   response, one column per group, with the wording attached.
profile_table <- function(fit, cfg, dictionary, labels = NULL) {
  K = length(fit$pi)
  nm = if (is.null(labels)) paste0("Group ", seq_len(K)) else labels

  purrr::map(seq_along(cfg$items), function(j) {
    it = cfg$items[j]
    d = dplyr::filter(dictionary, item == it)
    rho = fit$rho[[j]]
    tibble::tibble(
      item = it,
      question = d$question,
      response = d$responses[[1]],
      as.data.frame(round(rho, 3)) |> rlang::set_names(nm))
  }) |>
    purrr::list_rbind()
}

diagnose_model <- function(fit, cfg, dat, top_pairs = 12L) {
  w = dat$wt
  list(
    entropy = entropy_R2(fit$post, w, length(fit$pi)),
    shares = tibble::tibble(group = seq_along(fit$pi),
                            share = round(fit$pi, 3)),
    discrimination = item_discrimination(fit, cfg$items) |>
      dplyr::mutate(dplyr::across(c(discrimination, range), \(x) round(x, 3))) |>
      dplyr::mutate(flag = dplyr::if_else(
        discrimination < 0.15,
        "separates the groups barely at all", NA_character_)),
    bvr = bvr_pairs(dat, w, cfg$items, fit) |>
      dplyr::mutate(bvr = round(bvr, 3)) |>
      head(top_pairs),
    ratio = level_pattern_ratio(fit, cfg$items) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), \(x) round(x, 2))))
}


# Section 2 puts intervals on everything the analyst reads, from the same
#   replicate design that produces every other standard error here.
#______________________________________________________________________________

# How close to 0 or 1 an estimate has to be before the logit transform stops
#   being worth doing. An estimate at a boundary has no logit-scale standard
#   error at all, and one merely near it has a delta-method interval that is
#   arithmetically correct and useless to a reader: at p = 0.008 with se =
#   0.030 the logit interval is [0.000, 0.937]. Those cells keep a Wald
#   interval, untruncated, and come back flagged so the table can mark them.
BOUNDARY_TOL <- 1e-3

share_ci <- function(p, se, crit, transform = TRUE, truncate = TRUE) {

  # An estimate at or within BOUNDARY_TOL of a boundary has no meaningful
  #   logit-scale standard error, and neither does a missing one.
  edge = !(is.finite(p) & is.finite(se)) |
         p <= BOUNDARY_TOL | p >= 1 - BOUNDARY_TOL
  use = transform & !edge

  # Clamped before the transform so a boundary estimate cannot produce Inf:
  #   ifelse() evaluates both arms whatever the condition says.
  pc = pmin(pmax(p, BOUNDARY_TOL), 1 - BOUNDARY_TOL)
  half = crit * se / (pc * (1 - pc))

  w_lo = if (truncate) pmax(0, p - crit * se) else p - crit * se
  w_hi = if (truncate) pmin(1, p + crit * se) else p + crit * se

  tibble::tibble(
    lo = ifelse(use, stats::plogis(stats::qlogis(pc) - half), w_lo),
    hi = ifelse(use, stats::plogis(stats::qlogis(pc) + half), w_hi),
    boundary = if (transform) edge
               else !is.finite(p) | p < 0 | p > 1)
}


# The model is refitted inside every replicate, warm-started from the
#   full-sample solution and aligned back to it. Warm-starting is what makes
#   this affordable -- one EM run per replicate rather than two hundred -- and
#   the alignment is what makes the parameters comparable across replicates,
#   since group numbering is arbitrary and would otherwise permute.

# Everything the analyst reads is estimated in one pass: the group shares, the
#   response probabilities behind the profile table, and the scaled profile
#   values behind the plot. Deriving an interval for the plot from an interval
#   for the probabilities would need a delta method; computing the plotted
#   quantity inside the replicate function avoids it.

measurement_se <- function(cfg, dat, fit, des, rep_des) {
  init_parallel(cfg)
  inp = make_inputs(dat, cfg$items, cfg$cats)
  K = length(fit$pi)
  ref = fit[c("pi", "rho")]

  # The index grid for the profile quantities is the same in every replicate.
  #   Built here, walked there.
  prof_grid = tidyr::expand_grid(k = seq_len(K), j = seq_along(cfg$items))

  theta = function(w_rep) {
    f = align_to(em_run(inp$Y, inp$OH, cfg$cats, w_rep, K, init = ref,
                        maxit = 500L, tol = 1e-8), fit)
    prof = purrr::map2_dbl(prof_grid$k, prof_grid$j, function(k, j) {
      r = f$rho[[j]]
      (sum(seq_len(nrow(r)) * r[, k]) - 1) / (nrow(r) - 1)
    })
    c(f$pi, unlist(purrr::map(f$rho, as.vector), use.names = FALSE), prof)
  }

  est = theta(weights(des, "sampling"))
  se = sqrt(diag(replicate_variance(rep_des, theta, est)))

  n_pi = K
  n_rho = sum(cfg$cats) * K
  crit = qt(0.975, degf(rep_des))

  shares = tibble::tibble(
    group = seq_len(K),
    share = fit$pi,
    se = se[seq_len(n_pi)])
  shares = dplyr::bind_cols(shares, share_ci(shares$share, shares$se, crit)) |>
    dplyr::mutate(dplyr::across(c(share, se, lo, hi), \(x) round(x, 3)))

  # rho is stored item by item, each a cats x K matrix in column order, so the
  #   offsets have to be walked in the same order they were flattened.
  offs = cumsum(c(0, cfg$cats * K))
  probs = purrr::map(seq_along(cfg$items), function(j) {
    blk = se[n_pi + (offs[j] + 1):(offs[j + 1])]
    m = matrix(blk, nrow = cfg$cats[j], ncol = K)
    tidyr::expand_grid(response = seq_len(cfg$cats[j]), group = seq_len(K)) |>
      dplyr::arrange(group, response) |>
      dplyr::mutate(item = cfg$items[j],
                    prob = as.vector(fit$rho[[j]]),
                    se = as.vector(m))
  }) |>
    purrr::list_rbind()
  probs = dplyr::bind_cols(probs, share_ci(probs$prob, probs$se, crit)) |>
    dplyr::mutate(dplyr::across(c(prob, se, lo, hi), \(x) round(x, 3)))

  profile = tidyr::expand_grid(group = seq_len(K), item = cfg$items) |>
    dplyr::mutate(value = est[(n_pi + n_rho + 1):length(est)],
                  se = se[(n_pi + n_rho + 1):length(se)])
  # The plotted profile value is a rescaled expected response, not a
  #   probability, but it is bounded in [0, 1] by construction and the same
  #   argument applies: a symmetric interval on it can leave the range.
  profile = dplyr::bind_cols(profile,
                             share_ci(profile$value, profile$se, crit))

  list(shares = shares, probs = probs, profile = profile,
       replicates = ncol(weights(rep_des, "analysis")))
}
# Five segment names in one horizontal legend is wider than the page, and
#   ggplot crops such a legend at both ends rather than wrapping it: the report
#   showed three of five entries, the first and last cut off mid-word. The row
#   count is computed from the names actually being drawn.

# The caption went the same way -- one line of text longer than the device,
#   clipped at the right, ending mid-sentence. It is not a caption any more.
#   The report renders the block caption as ordinary text under the image,
#   where it wraps, and the on-screen panel has the same sentence in its help
#   box.
plot_profiles_ci <- function(profile, labels = NULL, title = NULL,
                             width = FIG_WIDTH_IN) {
  d = profile |>
    dplyr::mutate(group = if (is.null(labels)) paste0("Group ", group)
                          else labels[group])

  rows = legend_rows(unique(d$group), width)

  ggplot2::ggplot(d, ggplot2::aes(item, value, group = group, colour = group,
                                  fill = group)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = lo, ymax = hi), alpha = 0.15,
                         colour = NA) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    wise_colour(name = NULL) +
    wise_fill(name = NULL) +
    # Both guides take the same shape or the colour and fill legends refuse to
    #   merge and the figure grows a second copy of itself.
    ggplot2::guides(colour = ggplot2::guide_legend(nrow = rows, byrow = TRUE),
                    fill = ggplot2::guide_legend(nrow = rows, byrow = TRUE)) +
    ggplot2::labs(x = NULL, y = "Position on the item", title = title) +
    wise_theme() + wise_rotate_x()
}

# What the figure needs vertically once the legend is allowed to wrap.
plot_profiles_height <- function(labels, width = FIG_WIDTH_IN) {
  max(4.0, min(7.5, 3.9 + 0.32 * legend_rows(labels, width)))
}

prompt_diagnostics <- function(diag, dimension, context) {
  body = stringr::str_glue(
      "GROUP SIZES\n{log_table(diag$shares)}\n\n",
      "SEPARATION\n  Weighted relative entropy {round(diag$entropy, 3)}. ",
      "This is how cleanly respondents fall into one group rather than ",
      "sitting between several; 1 would be perfect.\n\n",
      "HOW FAR EACH ITEM SEPARATES THE GROUPS\n",
      "{log_table(diag$discrimination)}\n\n",
      "PAIRS THE MODEL ACCOUNTS FOR LEAST WELL\n{log_table(diag$bvr)}\n\n",
      "LEVEL AGAINST PATTERN\n{log_table(diag$ratio)}\n",
      "  Well under 1 means the groups differ mainly in how high they answer ",
      "overall, which one continuum would describe with far fewer numbers. ",
      "Near or above 1 means they reorder the items.")

  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "THE MODEL\n  {dimension} groups, already chosen by the analyst.",
    "\n\n{body}\n\n",
    "TASK\nIn five or six sentences, tell the analyst what these numbers say",
    " about the model they fitted. Cover how cleanly it separates people,",
    " which items are carrying the distinction and which are contributing",
    " little, and where the model accounts least well for how answers go",
    " together.\n\n",
    "Every quantity above ranks items or pairs. None of them is a test, none",
    " has a threshold, and a low-ranking item is not thereby a bad item. Do",
    " not recommend removing anything and do not say the model is good or bad.",
    " Describe what is there and let the analyst judge.\n\n",
    "Return only valid JSON, no prose and no markdown fences:\n",
    '{{"reading": "...", "weakest_items": ["..."]}}')
}

# ---- stage_07_labels ---------------------------------------------------

# Stage 8: draft names for what the model found.

#   1. What the model is shown
#   2. Drafting
#   3. The freeze file

# Names are drafts for the analyst to verify against the profiles they came
#   from. Nothing computed depends on them: a wrong name is a presentation
#   error, and every table is checkable against the numbers above it.

# One call per group. A joint prompt confuses near neighbours, because a forced
#   one-to-one assignment lets a single confusion corrupt two labels. The
#   collision check afterwards is mechanical, and the harmonising call runs only
#   when it fires.

# Requires: dplyr, purrr, tibble, readr, fs, stringr


# Section 1 assembles what the worker sees: the response probabilities or the
#   probabilities, and the question wording. Never a respondent record, never a
#   standard error, never a fit statistic.
#______________________________________________________________________________

# The prompt builders themselves live in engine_05_prompts_label.R and are
#   unchanged from the reports, so a label drafted here and a label drafted
#   there are drafted the same way.

label_targets <- function(state) seq_along(state$model$fit$pi)


# Section 2 drafts one name at a time, writing each as it arrives.
#______________________________________________________________________________

# Written per target rather than once at the end. A run that fails on the last
#   group leaves the earlier drafts on disk, and the next attempt picks up from
#   there instead of paying for them twice.

draft_labels <- function(state, tick = NULL) {
  cfg = state$cfg
  fit = state$model$fit
  dict = state$item_frame$dictionary

  # The part file carries the model key in its name. Without it, a run
  #   abandoned at four groups leaves rows named 1 to 4 that a five-group
  #   model would happily reuse, and group 1 does not mean the same thing in
  #   the two.
  partial = wise_path("output",
                      paste0("labels.partial.", substr(state$model_key, 1, 12),
                             ".csv"))

  done = if (fs::file_exists(partial))
    readr::read_csv(partial, show_col_types = FALSE)
  else tibble::tibble(target = character(), Label = character(),
                      Description = character())

  targets = label_targets(state)

  out = purrr::map(targets, function(k) {
    key = as.character(k)
    if (key %in% done$target) return(dplyr::filter(done, target == key))
    if (!is.null(tick)) tick(key)

    prompt = prompt_segment_label(fit, k, dict, cfg$items,
                                  cfg$survey_context)

    obj = llm_json(prompt, role = "worker", system_prompt = persona_lca,
                   validate = validate_fields(c("label", "description")),
                   seed = cfg$seed)

    row = tibble::tibble(target = key,
                         Label = as.character(obj$label),
                         Description = as.character(obj$description))
    done <<- dplyr::bind_rows(done, row)
    readr::write_csv(done, partial)
    row
  }) |>
    purrr::list_rbind()

  if (fs::file_exists(partial)) fs::file_delete(partial)
  out
}

# Per-target isolation has one blind spot: two neighbours can draft the same
#   name, since neither call saw the other. The check is Jaccard overlap on the
#   words, and the closing call edits only the labels that collide.
resolve_collisions <- function(labels, cfg) {
  if (!labels_collide(labels$Label)) return(list(labels = labels, ran = FALSE))

  lab = labels |>
    dplyr::mutate(K = dplyr::row_number()) |>
    dplyr::select(K, Label, Description)

  arr = llm_json(prompt_harmonize(lab), role = "pm",
                 system_prompt = persona_lca, pattern = "(?s)\\[.*\\]",
                 seed = cfg$seed)

  new = purrr::map(arr, function(x) tibble::tibble(
    K = as.integer(x$class), new = as.character(x$label))) |>
    purrr::list_rbind()

  out = lab |>
    dplyr::left_join(new, by = "K") |>
    dplyr::mutate(Label = dplyr::coalesce(new, Label)) |>
    dplyr::select(-new) |>
    dplyr::mutate(target = labels$target)

  list(labels = dplyr::select(out, target, Label, Description), ran = TRUE)
}


# Section 3 is the freeze file. When it exists it is used and validated;
#   otherwise the model drafts once and writes it. Editing that file is how the
#   analyst takes over naming, and deleting it triggers a redraft.
#______________________________________________________________________________

# Keyed to the specification. A row-count check catches a change in the number
#   of groups and nothing else: drop an item, refit at the same size, and the
#   previous run's names attach silently to groups that are no longer the ones
#   they described.

label_file <- function(cfg) wise_path("output", "labels.csv")

write_labels <- function(labels, cfg, key, edited = FALSE) {
  labels |>
    dplyr::mutate(model_key = key, analyst_edited = edited) |>
    readr::write_csv(label_file(cfg))
  invisible(label_file(cfg))
}

read_labels <- function(cfg, key, n_expected) {
  f = label_file(cfg)
  if (!fs::file_exists(f)) return(NULL)

  lab = readr::read_csv(f, show_col_types = FALSE)
  if (!all(c("target", "Label", "Description", "model_key") %in% names(lab)))
    stop(f, " is missing columns. Delete it to redraft.", call. = FALSE)
  if (nrow(lab) != n_expected)
    stop(f, " has ", nrow(lab), " rows for a model with ", n_expected,
         ". Delete it to redraft.", call. = FALSE)
  if (!identical(unique(lab$model_key), key))
    stop(f, " was drafted for a different specification. The battery or the ",
         "number of groups has changed since these names were written, so ",
         "they no longer describe what they name. Delete it to redraft.",
         call. = FALSE)
  lab
}
