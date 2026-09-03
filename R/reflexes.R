# reflexes.R for DrSvyR
# The survey-methodology reflexes the project manager is allowed to have.

#   1. The action vocabulary
#   2. The reflexes
#   3. The prohibitions
#   4. Assembling the system prompt
#   5. The protocol: validating a proposal before the analyst sees it
#   6. Reading the evidence out of state

# The point of this file is that the expertise is captured here rather than
#   assumed of the model. Every threshold has a source, every reflex names the
#   field the app itself computes, and a proposal that cites a number the app
#   did not compute is rejected before it reaches the screen. Swap the model
#   and the methodology does not move.

# Stamped in the report the way WISE_VERSION is. Bump it when a threshold,
#   a source, or a prohibition changes -- those change what the tool advises.
SURV_REFLEXES_VERSION <- "1.0"

# Requires: tibble, dplyr, purrr, stringr


# Section 1. What the project manager is allowed to propose.
#______________________________________________________________________________

# A closed vocabulary, deliberately. Free-text advice cannot be validated,
#   cannot be staged for confirmation, and cannot be logged in a form anyone
#   can audit later. Every proposal is an instance of one of these or it is
#   not a proposal, it is conversation.

# Adding and removing items is not here and will not be. Item content is a
#   questionnaire-design decision the analyst owns, and "drop it, the modal
#   share is 91 per cent" is the exact move by which measurement validity gets
#   traded for fit without anyone noticing. The reflexes below flag such items
#   and say what their low variation costs; what to do about it is not the
#   model's to suggest.

SURV_ACTIONS <- c(
  flag_for_report   = "Record this in the report's limitations or status table.",
  revisit_design    = "Re-examine the design specification before continuing.",
  change_k          = "Consider a different number of segments or factors.",
  merge_levels      = "Consider collapsing categories of a domain variable.",
  suppress_estimate = "Consider marking a cell as too imprecise to report.",
  none              = "Say it and stop. No action follows.")

# A sensitivity refit is deliberately absent. Every sensitivity worth running
#   here means refitting without an item, which is the item decision under
#   another name.


# Section 2. The reflexes.
#______________________________________________________________________________

# Fields:
#   stage      where in the workflow it can fire
#   arm        kept for the rule table's shape; every rule here is "both"
#   evidence   the exact names the app computes; a proposal may cite no others
#   threshold  the number, or NA where there deliberately is none
#   sourced    TRUE where the threshold comes from the reference material,
#              FALSE where it is a convention this project has yet to set
#   source     author/year, lecture, or the project document it comes from
#   actions    which of SURV_ACTIONS this reflex may propose
#   claim      what the model is permitted to assert
#   caution    the thing a capable general model would get wrong here

rfx <- function(id, stage, arm, evidence, threshold, sourced, source,
                actions, claim, caution = NA_character_) {
  list(id = id, stage = stage, arm = arm, evidence = evidence,
       threshold = threshold, sourced = sourced, source = source,
       actions = actions, claim = claim, caution = caution)
}

SURV_REFLEXES <- list(

  # ---- design ---------------------------------------------------------------

  rfx("design_singleton_stratum", "design", "both",
      evidence = "Smallest stratum (PSUs)",
      threshold = 2, sourced = TRUE,
      source = "SURV626 glossary, measurability: a design must have at least two selections per variance unit to estimate its own sampling variance.",
      actions = c("revisit_design"),
      claim = "A stratum with one PSU cannot take the replicate scaling. The design cannot estimate its own variance and the workflow halts rather than reporting a standard error that does not exist.",
      caution = "Collapsing strata to get past this changes the variance estimator and is the analyst's decision, not a repair the tool performs."),

  rfx("design_thin_stratum", "design", "both",
      evidence = "Smallest stratum (PSUs)",
      threshold = 5, sourced = FALSE,
      source = "Convention set in design_checks(); not drawn from the reference material.",
      actions = c("flag_for_report"),
      claim = "Under five PSUs in a stratum is thin. Domain estimates falling inside it rest on very few clusters and their intervals should be read with that in mind.",
      caution = "This is a house convention. Say so rather than presenting five as a standard."),

  rfx("design_weighting_inert", "design", "both",
      evidence = "Unequal weighting effect",
      threshold = 1.05, sourced = TRUE,
      source = "Kish's 1 + CV^2; SURV701 design-effect decomposition, L_weighting term.",
      actions = c("flag_for_report"),
      claim = "The unequal weighting effect is near one, so the weights are doing almost nothing in this file. Weighted and unweighted estimates will barely differ, and the design-based standard errors will be driven by clustering rather than by weighting.",
      caution = "Near-inert weights are not a licence to drop the design. Clustering and stratification still govern the variance."),

  rfx("design_duplicate_ids", "design", "both",
      evidence = "Duplicate ids",
      threshold = 0, sourced = TRUE,
      source = "Scoring joins on id; duplicates multiply rows. Property of this workflow.",
      actions = c("revisit_design"),
      claim = "Duplicate identifiers will multiply rows when scores are joined back, inflating the apparent sample and distorting every domain estimate downstream.",
      caution = NA_character_),

  # ---- items ----------------------------------------------------------------

  rfx("item_split_ballot", "items", "both",
      evidence = "min_shared",
      threshold = 0, sourced = TRUE,
      source = "Property of the estimator: a pair never answered together contributes no information to their joint distribution.",
      actions = c("revisit_design"),
      claim = "Two items were never answered by the same respondent. This is a split ballot: no model can estimate their relationship, because the data contain no case where both were observed.",
      caution = "This is not missingness to be imputed. There is no overlap to borrow from."),

  rfx("item_no_variation", "items", "both",
      evidence = "modal_pct",
      threshold = 95, sourced = FALSE,
      source = "Convention set in item_summary(); the underlying point is in the LCA report's discrimination section, where an item all segments answer alike carries no information about who differs.",
      actions = c("flag_for_report"),
      claim = "Almost everyone gave the same answer to this item. It will pass every fit statistic and carry almost no information about who differs from whom.",
      caution = "Do not propose removing it. Whether an item with little variation belongs in the battery is a content decision."),

  rfx("item_little_variation", "items", "both",
      evidence = "modal_pct",
      threshold = 85, sourced = FALSE,
      source = "Convention set in item_summary().",
      actions = c("flag_for_report"),
      claim = "Most respondents gave the same answer to this item, so it contributes little to separating them.",
      caution = "Do not propose removing it."),

  rfx("item_high_nonresponse", "items", "both",
      evidence = "missing_pct",
      threshold = 20, sourced = FALSE,
      source = "Convention set in item_summary(). The consequence is a nonresponse-error question, not a fit question.",
      actions = c("flag_for_report"),
      claim = "One in five or more did not answer this item. Under item-complete fitting it removes those respondents from the model entirely, and who is removed is unlikely to be random.",
      caution = "The relevant question is whether the item-complete sample still represents the population, not whether the model fits better without the item."),

  # ---- model -----------------------------------------------------

  rfx("lca_entropy_low", "model", "lca",
      evidence = "entropy",
      threshold = 0.8, sourced = TRUE,
      source = "Module2 Lecture 2: entropy near 1 indicates good classification, 0.8 conventionally read as good. Same convention stated in the LCA report.",
      actions = c("flag_for_report"),
      claim = "Relative entropy below about 0.8 means many respondents do not sit clearly in one segment. Segment membership is being assigned with real uncertainty, which is precisely what the BCH correction exists to carry into the domain estimates.",
      caution = "Entropy is not a fit statistic and must never be used to choose K. A model can classify sharply and still be the wrong number of segments."),

  rfx("lca_item_no_discrimination", "model", "lca",
      evidence = "discrimination",
      threshold = 0.15, sourced = FALSE,
      source = "Convention set in diagnose_lca(). The quantity is defined in the LCA report as a distance between segment-conditional distributions, bounded in [0, 1].",
      actions = c("flag_for_report"),
      claim = "This item barely separates the segments: every segment answers it about the same way. It is contributing to the likelihood without contributing to what distinguishes the groups.",
      caution = "The LCA report calls such an item a candidate for a sensitivity refit. Refitting without it is the analyst's call and is not proposed here."),

  rfx("lca_local_dependence", "model", "lca",
      evidence = "bvr",
      threshold = NA_real_, sourced = TRUE,
      source = "LCA report, following Oberski, van Kollenburg and Vermunt (2013): the Pearson bivariate residual has no valid null distribution even for unweighted binary data, and none at all under a design-weighted pseudo-likelihood on a clustered sample. Reported as a bounded effect size and ranked.",
      actions = c("flag_for_report"),
      claim = "These two items depart most from what the model implies if they were independent given segment. Read it as a ranking of where the conditional-independence assumption strains, on a scale from 0 to 1.",
      caution = "There is no threshold and no test. Never call a bivariate residual significant, never quote the Mplus convention of 3, and never propose a Rao-Scott adjustment as a fix -- it repairs the design component of a statistic whose null was already wrong."),

  rfx("lca_small_segment", "model", "lca",
      evidence = c("share", "share_lo"),
      threshold = 0.05, sourced = FALSE,
      source = "Set by the analyst for this project. Not drawn from the reference material and not a standard; state it as this project's rule.",
      actions = c("flag_for_report"),
      claim = "A segment holding less than five per cent of the population is below the floor set for this analysis. Domain estimates within it rest on few respondents and their intervals will be wide.",
      caution = "Read the rule against the lower end of the replicate interval, not the point estimate: a share of 0.06 whose interval reaches 0.03 has not cleared five per cent, it has failed to be measured precisely enough to say. The binding constraint is usually not the segment itself but the segment crossed with a domain level, which is smaller again."),

  rfx("replicates_failed", "model", "both",
      evidence = c("replicates_failed", "replicates"),
      threshold = 0, sourced = TRUE,
      source = "measurement_se(): every replicate is a fresh weighted EM refit. One that hits maxit without meeting the tolerance is counted and KEPT in the variance, never dropped -- dropping a deviation could only narrow the spread, whereas keeping it leaves the interval biased in a direction nobody can sign, which is the thing to state rather than hide.",
      actions = c("flag_for_report"),
      claim = "Some replicate refits did not converge and were dropped. The intervals on the measurement model are narrower than they should be and are a lower bound.",
      caution = "Dropping a replicate removes a deviation from the spread, which can only narrow the interval. Never present these margins as correct."),

  # ---- domains --------------------------------------------------------------

  rfx("domain_small_cell", "domains", "both",
      evidence = "n",
      threshold = 30, sourced = FALSE,
      source = "Convention set in demo_counts(). SURV745 notes that domain estimation and rare subgroups need explicit attention to which precision target governs.",
      actions = c("merge_levels", "suppress_estimate", "flag_for_report"),
      claim = "This domain level holds too few respondents to support a reportable estimate on its own.",
      caution = "Collapsing levels changes what is being compared. Propose the merge; the analyst decides whether the merged category still means something."),

  rfx("domain_imprecise", "domains", "both",
      evidence = c("p", "se"),
      threshold = NA_real_, sourced = FALSE,
      source = "No suppression rule is set in this project. SURV745: a fixed CV target requires very large samples for small proportions, so which precision target governs must be chosen deliberately.",
      actions = c("suppress_estimate", "flag_for_report"),
      claim = "The standard error is large relative to the estimate, so this cell does not resolve the quantity it is reporting.",
      caution = "This project has not set a relative-standard-error cutoff. Report the ratio and say no rule has been adopted rather than importing one."),

  rfx("domain_design_effect_visible", "domains", "both",
      evidence = "se_ratio",
      threshold = NA_real_, sourced = TRUE,
      source = "SURV701: deff is the ratio of complex to SRS variance, n_eff = n / deff. The workflow reports the design-based and unweighted standard errors side by side.",
      actions = c("flag_for_report"),
      claim = "The design-based standard error is materially wider than the one that ignores the design. That difference is what the clustering and weighting cost in precision, and it is the reason the replicate machinery is here.",
      caution = "The ratio of standard errors is the square root of a design effect, not the design effect. Do not report one as the other."),

  # ---- report ---------------------------------------------------------------

  rfx("invariance_untested", "report", "both",
      evidence = c("aux"),
      threshold = NA_real_, sourced = TRUE,
      source = "SURV632 develops this for factor models, where metric invariance equalises loadings and scalar invariance additionally equalises intercepts. The analogue for a latent class model is homogeneity of the item-response probabilities across groups, and the BCH correction needs the stronger form of it: the classification error rates have to be the same in every domain, since one pooled table is inverted for all of them. Neither is tested in this workflow.",
      actions = c("flag_for_report"),
      claim = "Comparing a latent quantity across groups assumes the battery measures the same thing the same way in each. Scalar invariance is the level that assumption requires and it has not been tested here, so a difference between groups may reflect measurement rather than the construct.",
      caution = "This applies to every domain comparison in the report, not only to the ones that look interesting. It is a standing limitation, not a finding."),

  rfx("specification_searched", "report", "both",
      evidence = "iterations",
      threshold = 0, sourced = TRUE,
      source = "report_caveats(): fit statistics after a specification search are optimistic. status_table() records that item removal is capped at one round because an unbounded loop selects a battery to fit rather than to measure.",
      actions = c("flag_for_report"),
      claim = "The battery was changed and the model refitted. Fit statistics computed afterwards are optimistic, because the specification was chosen partly on this sample.",
      caution = "Do not propose a further round. The cap of one round is a design decision, not an oversight."),

  rfx("bch_holds_measurement_fixed", "report", "lca",
      evidence = "estimator",
      threshold = NA_real_, sourced = TRUE,
      source = "Property of the three-step correction as implemented: the classification-error matrix is recomputed inside every replicate, but the measurement model itself is held at the full-sample solution.",
      actions = c("flag_for_report"),
      claim = "The corrected estimates carry classification uncertainty but hold the measurement model fixed, so their intervals are somewhat optimistic relative to one that also propagated uncertainty in the segments themselves.",
      caution = "Say which uncertainty is carried and which is not. Do not describe the correction as accounting for all measurement error.")
)

names(SURV_REFLEXES) <- purrr::map_chr(SURV_REFLEXES, "id")


# Section 3. What the project manager must refuse to propose.
#______________________________________________________________________________

# The negative half, and the half that makes this "captured" rather than
#   "assumed". Every entry below is a place where a capable general model will
#   give confident, conventional, widely-published advice that this project has
#   examined and rejected on methodological grounds. Without them the model
#   defaults to the literature it was trained on and quietly overrides
#   decisions that were made deliberately.

SURV_PROHIBITIONS <- list(
  list(id = "no_item_changes",
       rule = "Never propose adding or removing an item from the battery.",
       why  = "Item content is a questionnaire-design decision the analyst owns. Removing items on statistical grounds trades measurement validity for fit."),

  list(id = "no_dimension_choice",
       rule = "Never choose the number of segments or factors.",
       why  = "The analyst fixes K before the model comments, so the choice is not anchored on what the model said."),

  list(id = "no_modification_indices",
       rule = "Never propose freeing a covariance or any other parameter on the strength of a modification index.",
       why  = "Module2 Lecture 1: modification indices should not be used for exploratory analysis, only for slight tweaks to a theoretically supported model. This project does not free covariances."),

  list(id = "no_blrt",
       rule = "Never propose a bootstrap likelihood ratio test for class enumeration.",
       why  = "Its parametric bootstrap draws independent observations from the fitted model, which is not the process that generated a stratified clustered sample. Omitted by design; Mplus disables it under complex-design analysis for the same reason."),

  list(id = "no_bvr_test",
       rule = "Never attach a p-value, a significance claim, or a fixed cutoff to a bivariate residual, and never propose a Rao-Scott adjustment to rescue one.",
       why  = "Oberski et al. (2013): the Pearson form's null is not chi-square even for unweighted binary data, and under a design-weighted pseudo-likelihood on a clustered sample there is no valid reference distribution. A design adjustment repairs the design component of a statistic that was already without a null."),

  list(id = "no_reference_level",
       rule = "Never choose the reference level for a domain variable.",
       why  = "Which level the findings are read against is a presentation decision belonging to the analyst."),

  list(id = "no_uncited_statistic",
       rule = "Never cite a number that is not in the summary you were given.",
       why  = "A remembered or reconstructed statistic cannot be checked. Every proposal must name a field the app computed."),

  list(id = "no_borrowed_threshold",
       rule = "Where a reflex is marked as having no threshold, do not supply one from the wider literature.",
       why  = "An unset threshold is a decision this project has not yet made. Filling it in silently converts the analyst's open question into the model's settled answer.")
)


# Section 4. Assembling the system prompt.
#______________________________________________________________________________

# Built from this file at run time rather than written into a prompt string,
#   so the catalogue is the single place any of it changes and the report can
#   stamp the version that was in force.

reflex_catalogue <- function() {
  purrr::map(SURV_REFLEXES, function(r) tibble::tibble(
    id = r$id, stage = r$stage, arm = r$arm,
    evidence = paste(r$evidence, collapse = ", "),
    threshold = if (is.na(r$threshold)) "none set" else as.character(r$threshold),
    sourced = r$sourced,
    actions = paste(r$actions, collapse = ", "),
    source = r$source,
    claim = r$claim,
    caution = r$caution)) |>
    purrr::list_rbind()
}

reflex_prompt <- function(stage = NULL, arm = NULL) {
  keep = purrr::keep(SURV_REFLEXES, function(r)
    (is.null(stage) || identical(r$stage, stage)) &&
    (is.null(arm) || r$arm %in% c(arm, "both")))

  one = function(r) paste0(
    "- ", r$id, " [", r$stage, "] evidence: ", paste(r$evidence, collapse = ", "),
    "; threshold: ", if (is.na(r$threshold)) "NONE SET -- do not supply one"
                     else as.character(r$threshold),
    if (!r$sourced) " (house convention, say so)" else "",
    "\n    may propose: ", paste(r$actions, collapse = ", "),
    "\n    may say: ", r$claim,
    if (!is.na(r$caution)) paste0("\n    must not: ", r$caution) else "")

  paste0(
    "REFLEX CATALOGUE v", SURV_REFLEXES_VERSION, "\n",
    "You may propose an action only as an instance of one of these reflexes, ",
    "citing the named evidence field and the value you were given.\n\n",
    paste(purrr::map_chr(keep, one), collapse = "\n\n"),
    "\n\nPROHIBITIONS. These override anything you believe from training:\n",
    paste(purrr::map_chr(SURV_PROHIBITIONS, function(p)
      paste0("- ", p$rule, " (", p$why, ")")), collapse = "\n"))
}


# Section 5. The protocol.
#______________________________________________________________________________

# Reflexes are fast and fallible; this is what the code enforces regardless of
#   what the model said. A proposal that names an unknown reflex, an action
#   that reflex may not take, or a statistic the app did not compute never
#   reaches the analyst.

# What it cannot do is check the inference. It confirms the model quoted
#   min_shared = 43 correctly. It cannot confirm that 43 warrants the action.
#   That is why nothing executes without the analyst confirming, and why the
#   accept-and-override rate is worth watching: an analyst accepting every
#   proposal has stopped applying the protocol the code cannot apply for them.

validate_proposal <- function(obj, observed, tol = 1e-8) {
  need = c("reflex_id", "action", "evidence", "claim")
  missing = setdiff(need, names(obj))
  if (length(missing))
    stop("Proposal is missing: ", paste(missing, collapse = ", "), call. = FALSE)

  r = SURV_REFLEXES[[obj$reflex_id]]
  if (is.null(r))
    stop("Unknown reflex: ", obj$reflex_id, ". A proposal must be an instance ",
         "of a reflex in the catalogue.", call. = FALSE)

  if (!obj$action %in% r$actions)
    stop("Reflex ", r$id, " may not propose '", obj$action, "'. Permitted: ",
         paste(r$actions, collapse = ", "), call. = FALSE)

  cited = purrr::map_chr(obj$evidence, function(e) as.character(e$field %||% ""))
  stray = setdiff(cited, r$evidence)
  if (length(stray))
    stop("Reflex ", r$id, " cited evidence it is not entitled to: ",
         paste(stray, collapse = ", "), ". Permitted: ",
         paste(r$evidence, collapse = ", "), call. = FALSE)

  # The check that matters. A cited value must match what the app computed,
  #   so a plausible-sounding number cannot be produced from nowhere.
  purrr::walk(obj$evidence, function(e) {
    f = as.character(e$field)
    if (!f %in% names(observed))
      stop("Field '", f, "' was not supplied to the model, so it cannot be ",
           "cited.", call. = FALSE)
    got = suppressWarnings(as.numeric(e$value))
    want = suppressWarnings(as.numeric(observed[[f]]))
    # any(), not isTRUE(). Most of what reflex_evidence() supplies is a vector
    #   -- one discrimination per item, one share per segment, one estimate per
    #   cell -- and pm_evidence_block() shows the model that whole list and
    #   asks it to cite one number out of it. isTRUE() on a length-n logical is
    #   FALSE whatever the values are, so every proposal citing an item-level,
    #   segment-level or cell-level figure was rejected as fabricated and only
    #   the handful of scalar fields could pass. That left the panel inert at
    #   the Items, Model and Domains stages, which is most of it.
    # The citation now has to match SOME number this tool computed for that
    #   field. That is weaker than matching a named cell, and the honest next
    #   step is to supply these fields named and require field plus key -- a
    #   change to the prompt contract, not a bug fix.
    same = if (all(is.na(got)) || all(is.na(want)))
      any(as.character(e$value) == as.character(observed[[f]]), na.rm = TRUE)
    else any(abs(got - want) < tol, na.rm = TRUE)
    if (!same)
      stop("Cited ", f, " = ", e$value, " but no value computed here for that ",
           "field matches it. Computed: ",
           paste(utils::head(observed[[f]], 10), collapse = ", "), ".",
           call. = FALSE)
  })

  invisible(TRUE)
}


# Section 6. Reading the evidence out of state.
#______________________________________________________________________________

# The named list handed to the model and handed again to the validator, so the
#   two cannot disagree about what the numbers were. Only fields listed by some
#   reflex are extracted; nothing else is sent.

# NOTE: the domain and BCH entries are wired against field names not yet
#   confirmed against results.R. Marked rather than guessed -- check before
#   relying on them.

reflex_evidence <- function(state, stage) {

  # design_checks$value is character by construction -- the column carries
  #   counts, ratios and formatted totals together -- so it is coerced here and
  #   the thousands separator stripped before it becomes a number again.
  chk = function(name) {
    d = state$design_checks
    if (is.null(d)) return(NULL)
    v = d$value[d$check == name]
    if (!length(v)) NULL else suppressWarnings(as.numeric(gsub(",", "", v)))
  }

  col = function(tbl, nm)
    if (is.null(tbl) || !nm %in% names(tbl)) NULL else tbl[[nm]]

  # fitMeasures() is requested in a fixed order, but read back by name rather
  #   than by position so that changing that call cannot silently relabel the
  #   values a proposal is then validated against.

  # The population share of each segment with its replicate interval. That is
  #   the quantity a minimum-share rule should be read against; the model's own
  #   pi is a fallback for before the replicate run has happened.
  shares = state$measure$shares

  # No ratio is stored anywhere, so it is computed from the estimate table on
  #   the (variable, level, segment) keys rather than assumed to line up row by
  #   row -- the three estimators are stacked, not aligned.
  se_ratio = function() {
    d = state$domains$dom
    if (is.null(d)) return(NULL)
    j = dplyr::inner_join(
      dplyr::select(dplyr::filter(d, estimator == "Design-based"),
                    variable, level, segment, se_d = se),
      dplyr::select(dplyr::filter(d, estimator == "Unweighted"),
                    variable, level, segment, se_u = se),
      by = c("variable", "level", "segment"))
    r = j$se_d / j$se_u
    r = r[is.finite(r)]
    if (!length(r)) NULL else round(stats::median(r), 3)
  }

  out = switch(
    stage,

    design = list(
      `Smallest stratum (PSUs)`  = chk("Smallest stratum (PSUs)"),
      `Unequal weighting effect` = chk("Unequal weighting effect"),
      `Duplicate ids`            = chk("Duplicate ids")),

    items = list(
      min_shared  = col(state$item_summary, "min_shared"),
      modal_pct   = col(state$item_summary, "modal_pct"),
      missing_pct = col(state$item_summary, "missing_pct")),


    model = list(
      entropy           = state$model$diag$entropy,
      share             = col(shares, "share") %||%
                            col(state$model$diag$shares, "share"),
      share_lo          = col(shares, "lo"),
      discrimination    = col(state$model$diag$discrimination, "discrimination"),
      bvr               = col(state$model$diag$bvr, "bvr"),
      replicates_failed = state$measure$failed,
      replicates        = state$measure$replicates),

    # n is the count at recode time, which is where merging levels is still
    #   actionable. p and se come from the estimate table itself.
    domains = list(
      n        = col(state$demo_counts, "n"),
      p        = col(state$domains$dom, "p"),
      se       = col(state$domains$dom, "se"),
      se_ratio = se_ratio()),

    report = list(
      aux        = state$cfg$aux,
      iterations = iteration_count()),

    list())

  purrr::keep(out, function(x) !is.null(x) && length(x) > 0)
}
