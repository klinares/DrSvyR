# model.R for DrSvyR
# Configuration, the dimension search, the fitted model, and the names.

# Merged from: 
#   stage_04_config.R
#   stage_05_search.R
#   stage_06_model.R
#   stage_07_labels.R

# ---- stage_04_config ---------------------------------------------------

# stage_04_config.R for WISE repo
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
  K_range = 2:10,
  k_range = 1:4,
  n_pa = 100L,
  parallel = TRUE)

# state$model and state$measure are arm-shaped and share no columns. The class
#   arm's fit is a plain list of pi and rho, its diagnostics carry
#   discrimination and bivariate residuals, and its measure carries shares and
#   profiles. The factor arm's fit is a lavaan object, its diagnostics carry
#   loadings and modification indices, and its measure carries loadings and
#   factor correlations.

# Rendering one against the other does not degrade into a blank panel. It
#   errors -- lavInspect on a list, mutate on NULL -- and Shiny renders every
#   output that is in the DOM whether the analyst is looking at that panel or
#   not, so both arms' outputs run on every change.

# The arm is stamped on the object and read back from it, rather than read from
#   state$cfg. Two reasons. The configuration is cleared when the analyst drops
#   an item, and a gate written as !identical(state$cfg$arm, "lca") is TRUE
#   against a NULL configuration -- it opens when it does not know, which is
#   the opposite of what a guard is for. And the configuration can be changed
#   to the other arm while a fitted model from the first one is still sitting
#   in state, which is the sequence that produced the errors this exists to
#   stop: fit the class model, run its variance, switch to the factor arm,
#   approve, and every factor output renders against a class model.
arm_is <- function(x, arm) identical(x[["arm"]], arm)

build_cfg <- function(state) {
  fr = state$item_frame
  arm = state$arm

  cfg = c(
    list(
      arm = arm,
      items = fr$items,
      cats = fr$cats,
      aux = names(state$demo_dat),
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
      out_dir = wise_path("output", arm)),

    if (identical(arm, "lca"))
      list(K_range = WISE_FIXED$K_range,
           K_force = NULL,
           n_starts = WISE_FIXED$n_starts,
           min_items = fr$min_items)
    else
      list(k_range = WISE_FIXED$k_range,
           n_pa = WISE_FIXED$n_pa,
           n_factors = NULL,
           cfa_factors = NULL,
           estimator = state$estimator %||% "WLSMV"))

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

    row("Model", "Arm", if (identical(cfg$arm, "lca"))
          "Latent class -- distinct groups" else "Factor -- one continuum"),
    row("Model", "Advice followed",
        if (is.null(state$arm_advice)) "not asked"
        else if (identical(state$arm_advice$recommendation, cfg$arm)) "yes"
        else "no -- analyst chose otherwise"),
    row("Model", "Range searched",
        if (identical(cfg$arm, "lca"))
          paste0(min(cfg$K_range), " to ", max(cfg$K_range), " groups")
        else paste0(min(cfg$k_range), " to ", max(cfg$k_range), " factors")),
    if (identical(cfg$arm, "cfa"))
      row("Model", "Answer scales treated as",
          if (identical(cfg$estimator, "ML"))
            "continuous — partial responders scored"
          else "ordered categories — complete responders only") else NULL,

    purrr::imap(state$demo_specs, function(s, nm)
      row("Domains", nm,
          paste0(nlevels(state$demo_dat[[nm]]), " groups, reference ",
                 levels(state$demo_dat[[nm]])[1]))) |> purrr::list_rbind(),

    row("Fixed", "Random seed", cfg$seed),
    row("Fixed", "Parallel workers", wise_workers_note()),
    if (identical(cfg$arm, "lca"))
      row("Fixed", "Starts per model", cfg$n_starts) else NULL,
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
    "# cfg.R -- written by WISE. Do not edit by hand.",
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
          reference = levels(state$demo_dat[[nm]])[1],
          values = as.list(levels(state$demo_dat[[nm]])))),
        purrr::imap(state$design_map, function(v, role) list(
          name = role, source = v, role = "design"))))),
    missing_values = as.list(cfg$na_codes))

  yaml::write_yaml(doc, path)
  invisible(path)
}

# ---- stage_05_search ---------------------------------------------------

# stage_05_search.R for WISE repo
# Stage 6: search over the number of groups or factors.

#   1. The class search
#   2. The factor search
#   3. What the analyst looks at
#   4. Prompt

# Neither arm selects the dimension. Each renders the evidence, stops, and waits
#   for a number. That decision is recorded with the evidence that was in front
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

best_of_starts <- function(inp, cats, w, K, seeds, maxit = 800L, tol = 1e-8) {
  cands = purrr::map(seeds, function(s) {
    set.seed(s)
    em_run(inp$Y, inp$OH, cats, w, K, maxit = maxit, tol = tol)
  })
  cands[[which.max(purrr::map_dbl(cands, "ll"))]]
}

search_lca <- function(cfg, dat, tick = NULL) {
  w = dat$wt
  n = nrow(dat)
  scale = n / sum(w)

  init_parallel(cfg)
  inp = make_inputs(dat, cfg$items, cfg$cats)

  # The full start set at every size. A weighted mixture likelihood has local
  #   maxima that a smaller set finds inconsistently, and a search that ranks
  #   sizes on inconsistently located maxima ranks the optimiser rather than
  #   the models.
  n_blocks = max(1L, cfg$workers)

  fits = purrr::map(cfg$K_range, function(K) {
    if (!is.null(tick)) tick(K)
    seeds = start_seeds(cfg, K)
    blocks = split(seeds, cut(seq_along(seeds), n_blocks, labels = FALSE))
    parts = furrr::future_map(
      blocks, function(sd) best_of_starts(inp, cfg$cats, w, K, sd),
      .options = furrr::furrr_options(seed = NULL))
    parts[[which.max(purrr::map_dbl(parts, "ll"))]]
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


# Section 2 is the factor search: how many dimensions the correlation matrix
#   will carry, and whether the structure reproduces.
#______________________________________________________________________________

# Parallel analysis compares each observed eigenvalue against the distribution
#   obtained from data with the same dimensions and no structure. Retaining
#   components above that reference is a ranking rule, not a test.
search_cfa <- function(cfg, dat, tick = NULL) {
  init_parallel(cfg)
  w = dat$wt
  n = nrow(dat)
  p = length(cfg$items)

  R = wcor(w, cfg$items, dat)
  obs = eigen(R, only.values = TRUE)$values

  set.seed(cfg$seed)
  sim = purrr::map(seq_len(cfg$n_pa), function(i) {
    X = matrix(stats::rnorm(n * p), n, p)
    eigen(stats::cor(X), only.values = TRUE)$values
  })
  ref = apply(do.call(rbind, sim), 2, stats::quantile, 0.95)

  eig = tibble::tibble(
    component = seq_len(p),
    eigenvalue = round(obs, 3),
    reference = round(ref, 3),
    retain = obs > ref)

  fits = purrr::map(cfg$k_range, function(k) {
    if (!is.null(tick)) tick(k)
    fit_efa(k, w, cfg$items, dat)
  }) |> rlang::set_names(as.character(cfg$k_range))

  stats = purrr::imap(fits, function(f, k) {
    fit = as_fit(f)
    if (inherits(fit, "try-error"))
      return(tibble::tibble(factors = as.integer(k), flag = "did not converge"))
    m = try(lavaan::fitMeasures(fit,
              c("cfi.scaled", "tli.scaled", "rmsea.scaled", "srmr")),
            silent = TRUE)
    if (inherits(m, "try-error"))
      return(tibble::tibble(factors = as.integer(k), flag = "no fit measures"))
    L = efa_loadings(f)
    tibble::tibble(
      factors = as.integer(k),
      CFI = round(unname(m[["cfi.scaled"]]), 3),
      TLI = round(unname(m[["tli.scaled"]]), 3),
      RMSEA = round(unname(m[["rmsea.scaled"]]), 3),
      SRMR = round(unname(m[["srmr"]]), 3),
      problem_items = sum(!is.na(L$flag[!duplicated(L$item)])),
      flag = NA_character_)
  }) |>
    purrr::list_rbind()

  list(stats = stats, eigen = eig, fits = fits,
       suggested = sum(eig$retain))
}


# Section 3 is what the analyst reads. The statistics support the reading; the
#   profiles are the reading. An analyst who designed the questionnaire can
#   judge whether two groups describe the same people, and that is the judgement
#   the dimension choice actually turns on.
#______________________________________________________________________________

# Expected response per item, rescaled so a binary and a seven-point item span
#   the same range. Without that the picture is dominated by response format
#   rather than by how the groups differ.
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
                  caption = "Lower is better. A flattening curve says the extra groups are buying little.") +
    wise_theme()
}

plot_scree <- function(eig) {
  eig |>
    tidyr::pivot_longer(c(eigenvalue, reference), names_to = "series",
                        values_to = "value") |>
    ggplot2::ggplot(ggplot2::aes(component, value, colour = series)) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 2) +
    ggplot2::scale_x_continuous(breaks = eig$component) +
    ggplot2::scale_colour_viridis_d(name = NULL, end = 0.7,
      labels = c(eigenvalue = "Observed", reference = "No structure")) +
    ggplot2::labs(x = "Component", y = "Eigenvalue",
                  caption = "Components above the reference line carry more than noise would.") +
    wise_theme()
}


# Section 4 hands the evidence to the model -- after the analyst has committed
#   to a number. Shown first, the model's reading becomes the analyst's: an
#   anchor is not undone by a warning that it is one.
#______________________________________________________________________________

prompt_search_narration <- function(stats, chosen, arm, context) {
  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "SEARCH EVIDENCE\n{log_table(stats)}\n\n",
    "THE ANALYST HAS CHOSEN\n  {chosen} ",
    "{if (arm == 'lca') 'groups' else 'factors'}\n\n",
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

# stage_06_model.R for WISE repo
# Stage 7: fit at the chosen dimension and diagnose it.

#   1. The class model
#   2. The factor model
#   3. Prompt

# The search ranked sizes. This fits the one the analyst chose, from the full
#   start set, and reports what the model does not account for. The diagnostics
#   rank items and pairs; none of them is a test, and the model narrating them
#   is forbidden from recommending a removal.

# Requires: dplyr, purrr, tibble, ggplot2, tidyr


# Section 1 is the class arm.
#______________________________________________________________________________

fit_final_lca <- function(cfg, dat, K) {
  init_parallel(cfg)
  inp = make_inputs(dat, cfg$items, cfg$cats)
  w = dat$wt

  seeds = start_seeds(cfg, K)
  blocks = split(seeds, cut(seq_along(seeds), max(1L, cfg$workers),
                            labels = FALSE))
  parts = furrr::future_map(
    blocks, function(sd) best_of_starts(inp, cfg$cats, w, K, sd),
    .options = furrr::furrr_options(seed = NULL))

  parts[[which.max(purrr::map_dbl(parts, "ll"))]]
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

diagnose_lca <- function(fit, cfg, dat, top_pairs = 12L) {
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


# Section 2 is the factor arm. The item-to-factor assignment comes from the
#   exploratory fit at the chosen number: each item goes to the factor it loads
#   on most strongly. Shown to the analyst rather than applied silently, since
#   an item that belongs nowhere in particular is a finding.
#______________________________________________________________________________

assign_factors <- function(efa_fit, items) {
  L = unclass(lavInspect(as_fit(efa_fit), "std")$lambda)
  best = colnames(L)[apply(abs(L), 1, which.max)]
  split(rownames(L), best)[unique(best)]
}

fit_final_cfa <- function(cfg, dat, factors) {
  check_factors(factors, cfg$items)
  fit_cfa(dat$wt, cfg$items, dat, factors, free = NULL,
          ordered = identical(cfg$estimator %||% "WLSMV", "WLSMV"))
}

# Whether the fit can be believed at all, checked before anything is read off
#   it. A model that did not converge, or whose information matrix will not
#   invert, has parameters that are not a unique solution: the numbers print,
#   the plots draw, and nothing about them is trustworthy. lavaan says so in a
#   console warning that an analyst will not see.
cfa_health <- function(fit) {
  converged = isTRUE(try(lavInspect(fit, "converged"), silent = TRUE))
  se_ok = !inherits(try(suppressWarnings(lavInspect(fit, "se")), silent = TRUE),
                    "try-error")
  se_finite = if (se_ok) {
    s = suppressWarnings(lavInspect(fit, "se"))
    all(is.finite(unlist(s)))
  } else FALSE

  # A standardised loading outside [-1, 1] is not a strong loading; it is a
  #   sign the solution is inadmissible.
  lam = try(unclass(lavInspect(fit, "std")$lambda), silent = TRUE)
  admissible = !inherits(lam, "try-error") && all(abs(lam) <= 1.001, na.rm = TRUE)

  problems = c(
    if (!converged) "the optimiser did not find a solution",
    if (!se_finite) paste("standard errors could not be computed -- the",
                          "information matrix would not invert, which usually",
                          "means the model is not identified"),
    if (!admissible) "at least one standardised loading is outside -1 to 1")

  list(ok = length(problems) == 0, problems = problems)
}

diagnose_cfa <- function(fit, cfg, top_mi = 12L) {
  L = as_tibble(unclass(lavInspect(fit, "std")$lambda), rownames = "item") |>
    tidyr::pivot_longer(-item, names_to = "factor", values_to = "loading") |>
    dplyr::group_by(item) |>
    dplyr::mutate(h2 = sum(loading^2)) |>
    dplyr::ungroup() |>
    dplyr::filter(abs(loading) > 0.05) |>
    dplyr::mutate(dplyr::across(c(loading, h2), \(x) round(x, 3))) |>
    dplyr::mutate(flag = dplyr::case_when(
      abs(loading) < 0.4 ~ "loads weakly",
      h2 < 0.3 ~ "shares little with the battery",
      TRUE ~ NA_character_))

  mi = try(lavaan::modificationIndices(fit, sort. = TRUE, maximum.number = top_mi),
           silent = TRUE)
  measures = try(lavaan::fitMeasures(
    fit, c("cfi.scaled", "tli.scaled", "rmsea.scaled", "srmr")), silent = TRUE)

  list(
    loadings = L,
    mi = if (inherits(mi, "try-error")) NULL else
      tibble::as_tibble(mi) |>
        dplyr::transmute(lhs, op, rhs, mi = round(mi, 1), epc = round(epc, 3)),
    fit = if (inherits(measures, "try-error")) NULL else
      tibble::tibble(measure = names(measures),
                     value = round(unname(measures), 3)))
}


# Section 2b is the point of the workflow: design-based uncertainty on the
#   measurement model itself, from the same replicates that drive every other
#   standard error.
#______________________________________________________________________________

# Intervals for a probability are formed on the logit scale by the delta
#   method rather than as p +/- t se. Since d logit(p)/dp = 1/{p(1-p)},
#
#     se_logit(p) = se(p) / {p(1-p)},   CI = logit^-1( logit(p) +/- t se_logit )
#
#   which keeps the interval inside (0, 1) without truncation and improves
#   coverage near the boundary. A Wald interval on a proportion is symmetric by
#   construction, and the sampling distribution of a proportion is not: near 0
#   or 1 it under-covers and can run outside the range the quantity is even
#   defined on. This is what the reference workflow does and what the app now
#   matches.
#
# Two cases must not be transformed. An estimate within BOUNDARY_TOL of 0 or 1
#   has no meaningful logit-scale standard error. And a BCH-corrected share can
#   legitimately sit outside [0, 1] -- the correction permits it and truncating
#   would misstate it -- so those keep a Wald interval, untruncated, and are
#   returned flagged rather than silently mixed in with the rest.

# Intervals on a share are formed on the logit scale by the delta method
#   rather than as p +/- t se. Since d logit(p)/dp = 1/{p(1-p)},
#
#     se_logit(p) = se(p) / {p(1-p)},   CI = logit^-1( logit(p) +/- t se_logit )
#
#   which keeps the interval inside (0, 1) without truncation and improves
#   coverage near the boundary. A Wald interval on a proportion is symmetric by
#   construction and the sampling distribution of a proportion is not: near 0
#   or 1 it under-covers and can run outside the range the quantity is defined
#   on. This is what the reference workflow does, and matching it is why the
#   two now agree on more than the point estimates.

# transform = FALSE is not a convenience. Two quantities here must not be
#   transformed. A BCH-corrected share can legitimately sit outside [0, 1] --
#   the correction permits it and clipping would misstate it -- and where such
#   a share is small with a large standard error the delta method degenerates:
#   at p = 0.008 with se = 0.030 the logit interval is [0.000, 0.937], which is
#   arithmetically correct and useless to a reader. The reference reports those
#   cells as an estimate and a standard error for exactly that reason. They
#   keep a Wald interval, untruncated, and come back flagged so the table can
#   mark them.

BOUNDARY_TOL <- 1e-3

share_ci <- function(p, se, crit, transform = TRUE, truncate = TRUE) {

  # An estimate at or within BOUNDARY_TOL of a boundary has no meaningful
  #   logit-scale standard error, and neither does a missing one.
  edge = !(is.finite(p) & is.finite(se)) |
         p <= BOUNDARY_TOL | p >= 1 - BOUNDARY_TOL
  use = transform & !edge

  # Clamped before the transform so the unused arm cannot produce Inf:
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

measurement_se_lca <- function(cfg, dat, fit, des, rep_des) {
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

# The factor arm refits lavaan inside every replicate. Sign is anchored by the
#   marker method rather than std.lv, because lavaan starts cold on each refit
#   and a flipped sign would land in the variance as an enormous fake deviation.
measurement_se_cfa <- function(cfg, dat, fit, factors, des, rep_des) {
  init_parallel(cfg)
  ordered = identical(cfg$estimator %||% "WLSMV", "WLSMV")
  ref = unclass(lavInspect(fit, "std")$lambda)

  # The correlation between factors is estimated in the same pass. It is a
  #   parameter of the model and usually the first one anybody asks about, and
  #   under a complex design its interval is wider than default software says
  #   for the same reason every other interval here is.
  facs = colnames(ref)
  pairs = if (length(facs) > 1) t(utils::combn(facs, 2)) else NULL
  psi_of = function(m) if (is.null(pairs)) numeric(0)
    else purrr::map2_dbl(pairs[, 1], pairs[, 2], function(a, b) m[a, b])

  psi_ref = unclass(lavInspect(fit, "std")$psi)
  n_lam = length(ref)

  n_out = n_lam + (if (is.null(pairs)) 0L else nrow(pairs))

  # A replicate that did not converge still returns a fitted object, and its
  #   parameters are NaN rather than absent. Left alone they propagate into the
  #   variance and every interval comes back NA. Convergence is checked, and a
  #   result carrying any NaN is discarded whether lavaan admitted the failure
  #   or not.
  theta = function(w_rep) {
    f = suppressWarnings(try(
      fit_cfa(w_rep, cfg$items, dat, factors, free = NULL, ordered = ordered),
      silent = TRUE))
    if (inherits(f, "try-error")) return(rep(NA_real_, n_out))
    ok = isTRUE(try(lavInspect(f, "converged"), silent = TRUE))
    if (!ok) return(rep(NA_real_, n_out))
    s = lavInspect(f, "std")
    v = c(as.vector(unclass(s$lambda)), psi_of(unclass(s$psi)))
    if (anyNA(v)) rep(NA_real_, n_out) else v
  }

  est = c(as.vector(ref), psi_of(psi_ref))

  # The replicate loop is written out here rather than handed to
  #   replicate_variance(), so the number of failures is visible. It matters:
  #   the scale factor assumes every replicate contributed, so dropping some
  #   understates the variance rather than merely widening it.
  Wm = weights(rep_des, type = "analysis")
  Theta = do.call(rbind, furrr::future_map(
    seq_len(ncol(Wm)), function(r) theta(Wm[, r]),
    .options = furrr::furrr_options(seed = NULL)))

  ok = complete.cases(Theta)
  n_failed = sum(!ok)
  if (n_failed >= ncol(Wm))
    stop("The model did not converge in any replicate. No design-based ",
         "intervals can be produced for this specification.", call. = FALSE)

  d = sweep(Theta[ok, , drop = FALSE], 2, est, "-")
  V = rep_des$scale * crossprod(d * sqrt(rep_des$rscales[ok]))
  se = sqrt(diag(V))
  crit = qt(0.975, degf(rep_des))

  loadings = tidyr::expand_grid(factor = facs, item = rownames(ref)) |>
    dplyr::arrange(factor, item) |>
    dplyr::mutate(loading = as.vector(ref), se = se[seq_len(n_lam)]) |>
    dplyr::filter(abs(loading) > 0.05) |>
    dplyr::mutate(lo = loading - crit * se, hi = loading + crit * se,
                  dplyr::across(c(loading, se, lo, hi), \(x) round(x, 3)))

  correlations = if (is.null(pairs)) NULL else
    tibble::tibble(a = pairs[, 1], b = pairs[, 2],
                   r = psi_of(psi_ref),
                   se = se[n_lam + seq_len(nrow(pairs))]) |>
      dplyr::mutate(lo = pmax(-1, r - crit * se), hi = pmin(1, r + crit * se),
                    dplyr::across(c(r, se, lo, hi), \(x) round(x, 3)))

  list(loadings = loadings, correlations = correlations,
       replicates = ncol(Wm), failed = n_failed)
}

# The profile plot with its intervals. Without them the picture invites an
#   analyst to read a separation the data may not carry, which is exactly the
#   error the workflow exists to prevent.
plot_profiles_ci <- function(profile, labels = NULL, title = NULL) {
  d = profile |>
    dplyr::mutate(group = if (is.null(labels)) paste0("Group ", group)
                          else labels[group])

  ggplot2::ggplot(d, ggplot2::aes(item, value, group = group, colour = group,
                                  fill = group)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = lo, ymax = hi), alpha = 0.15,
                         colour = NA) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    wise_colour(name = NULL) +
    wise_fill(name = NULL) +
    ggplot2::labs(x = NULL, y = "Position on the item", title = title,
                  caption = paste("Bands are 95% design-based intervals.",
                                  "Where they overlap, the groups are not",
                                  "separated on that item.")) +
    wise_theme() + wise_rotate_x()
}

plot_loadings_ci <- function(load) {
  load |>
    dplyr::mutate(item = factor(item, levels = rev(unique(item)))) |>
    ggplot2::ggplot(ggplot2::aes(loading, item, colour = factor)) +
    ggplot2::geom_vline(xintercept = 0.4, linetype = 2, colour = "grey60") +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = lo, xmax = hi),
                           orientation = "y", width = 0.25, linewidth = 0.7) +
    ggplot2::geom_point(size = 3.2) +
    wise_colour(name = NULL) +
    ggplot2::labs(x = "Standardised loading", y = NULL,
                  caption = paste("Bars are 95% design-based intervals.",
                                  "The dashed line is the conventional 0.40,",
                                  "which is a convention and not a test.")) +
    wise_theme()
}


# Section 3 hands the diagnostics over. Every one of them ranks rather than
#   tests, and the model is told so: a ranking read as a test is how an item
#   gets dropped for being merely last.
#______________________________________________________________________________

prompt_diagnostics <- function(diag, arm, dimension, context) {
  body = if (identical(arm, "lca"))
    stringr::str_glue(
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
  else
    stringr::str_glue(
      "LOADINGS\n{log_table(diag$loadings)}\n\n",
      "{if (!is.null(diag$fit)) paste0('FIT\\n', log_table(diag$fit), '\\n\\n') else ''}",
      "{if (!is.null(diag$mi)) paste0('PAIRS THE MODEL ACCOUNTS FOR LEAST WELL\\n', log_table(diag$mi)) else ''}")

  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "THE MODEL\n  {dimension} ",
    "{if (arm == 'lca') 'groups' else 'factors'}, already chosen by the ",
    "analyst.\n\n{body}\n\n",
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

# stage_07_labels.R for WISE repo
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
#   loadings, and the question wording. Never a respondent record, never a
#   standard error, never a fit statistic.
#______________________________________________________________________________

# The prompt builders themselves live in engine_05_prompts_label.R and are
#   unchanged from the reports, so a label drafted here and a label drafted
#   there are drafted the same way.

label_targets <- function(state) {
  if (identical(state$cfg$arm, "lca")) seq_along(state$model$fit$pi)
  else colnames(unclass(lavInspect(state$model$fit, "std")$lambda))
}


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
  #   abandoned under a two-factor model leaves rows named f1 and f2 that a
  #   three-factor model would happily reuse, and f1 does not mean the same
  #   thing in the two.
  partial = wise_path("output", cfg$arm,
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

    prompt = if (identical(cfg$arm, "lca"))
      prompt_segment_label(fit, k, dict, cfg$items, cfg$survey_context)
    else
      prompt_factor_label(fit, dict, k, scale_desc = NULL,
                          context = cfg$survey_context)

    persona = if (identical(cfg$arm, "lca")) persona_lca else persona_cfa

    obj = llm_json(prompt, role = "worker", system_prompt = persona,
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

label_file <- function(cfg) wise_path("output", cfg$arm, "labels.csv")

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
