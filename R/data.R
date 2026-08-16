# data.R for DrSvyR
# Reading the file, confirming the design, choosing the battery, collapsing the domains.

# Merged from: 
#   stage_00_read.R
#   stage_01_design.R
#   stage_02_items.R
#   stage_03_recode.R

# ---- stage_00_read -----------------------------------------------------

# 00_read.R for WISE repo
# Stage 00: read the survey file and describe what is in it.

#   1. Reading
#   2. The codebook
#   3. Nominating design variables

# Unlike reference/survey_data_read.R, nothing here runs on source. Every
#   function takes its inputs as arguments and returns a value, because the app
#   calls these stages in an order the analyst controls and a script that
#   executes on load cannot be re-run with different arguments.

# The codebook is also the boundary for confidentiality: it holds variable
#   names, question wording and response labels, and no respondent data. It is
#   the only object from this stage that is ever put in a prompt.

# Requires: haven, janitor, dplyr, purrr, tibble, stringr, fs


# Section 1 reads the file. SPSS and Stata differ in how they carry
#   nonresponse, so the format is recorded rather than assumed downstream.
#______________________________________________________________________________

# user_na = TRUE keeps the SPSS nonresponse codes as values instead of letting
#   haven convert them to NA on read, so the config can decide whether a "don't
#   know" is a category or a missing value. Stata has no equivalent: its
#   extended missing values arrive as tagged NAs and are already NA to R, so a
#   .dta cannot express that choice and the format is returned for the caller
#   to act on.
read_survey <- function(file) {
  ext = tolower(fs::path_ext(file))

  dat = switch(
    ext,
    sav = haven::read_sav(file, user_na = TRUE),
    zsav = haven::read_sav(file, user_na = TRUE),
    dta = haven::read_dta(file),
    stop("Unsupported file type: .", ext, ". Expected .sav, .zsav or .dta.",
         call. = FALSE))

  structure(janitor::clean_names(dat),
            wise_source = as.character(file),
            wise_format = if (ext == "dta") "stata" else "spss")
}

survey_format <- function(dat) attr(dat, "wise_format", exact = TRUE)


# Section 2 describes every variable once. This is what the analyst browses in
#   the app, what the data dictionary is built from, and what the model reads.
#______________________________________________________________________________

# n_distinct and n_missing are computed on the values as read, before any
#   recode, so a variable whose nonresponse codes dominate is visible as such
#   rather than looking like a well-populated item.

# responses is a list column of named vectors: names are the labels, values are
#   the codes. Kept in code order rather than label order, so it lines up with
#   the fitted category indices later.
build_codebook <- function(dat) {
  tibble::tibble(variable = names(dat)) |>
    dplyr::mutate(
      label = purrr::map_chr(variable, function(v) {
        lab = attr(dat[[v]], "label", exact = TRUE)
        if (is.character(lab) && length(lab) == 1 && nzchar(lab)) lab else NA_character_
      }),
      type = purrr::map_chr(variable, function(v) class(dat[[v]])[1]),
      n_missing = purrr::map_int(variable, function(v) sum(is.na(dat[[v]]))),
      n_distinct = purrr::map_int(variable, function(v)
        dplyr::n_distinct(dat[[v]], na.rm = TRUE)),
      responses = purrr::map(variable, function(v) {
        vl = attr(dat[[v]], "labels", exact = TRUE)
        if (length(vl)) vl[order(unname(vl))] else NULL
      }),
      n_responses = purrr::map_int(responses, length))
}

# A variable with response labels and few distinct values is a candidate item
#   for either arm. This narrows several hundred columns to a few dozen before
#   the analyst or the model looks at anything, and it is a filter rather than
#   a decision: everything it excludes stays available in the full codebook.
candidate_items <- function(codebook, max_categories = 10L) {
  codebook |>
    dplyr::filter(n_responses > 1, n_responses <= max_categories,
                  n_distinct > 1, !is.na(label)) |>
    dplyr::arrange(variable)
}


# Section 3 nominates the design columns. Deterministic, because a regular
#   expression over names and labels resolves the usual cases and costs
#   nothing; where it does not, the analyst chooses from the full codebook and
#   the checks in stage 01 are what confirm the choice either way.
#______________________________________________________________________________

# Patterns cover the English and Spanish conventions in the files this workflow
#   targets. A nomination is a suggestion for a dropdown, never a selection:
#   nothing downstream reads this without the analyst having confirmed it.
DESIGN_PATTERNS <- list(
  weight = "^(wt|weight|peso|pond|w)$|weight|ponderad",
  strata = "^(strata|stratum|estrato)$|strat|estrato",
  psu    = "^(psu|upm|cluster|clust)$|primary sampling|conglomerad",
  id     = "^(id|idnum|caseid|respondent_id|folio)$|case id|identificador")

nominate_design <- function(codebook) {
  purrr::imap(DESIGN_PATTERNS, function(pat, role) {
    hits = codebook |>
      dplyr::filter(stringr::str_detect(variable, stringr::regex(pat, TRUE)) |
                    stringr::str_detect(dplyr::coalesce(label, ""),
                                        stringr::regex(pat, TRUE)))
    tibble::tibble(role = role,
                   variable = if (nrow(hits)) hits$variable else NA_character_,
                   label = if (nrow(hits)) hits$label else NA_character_)
  }) |>
    purrr::list_rbind()
}

# ---- stage_01_design ---------------------------------------------------

# 01_design.R for WISE repo
# Stage 01: build the design frame and confirm the specification.

#   1. The design frame
#   2. Equivalent nominations
#   3. Design checks

# The replicate design itself is built by build_rep_design() in the engine.
#   This stage decides which columns go into it and reports whether that
#   choice holds up, because a design specification that is wrong produces
#   standard errors that are wrong and nothing else looks unusual.

# Requires: dplyr, purrr, tibble, stringr


# Section 1 assembles the four design columns under fixed names, so everything
#   downstream refers to id, strata, psu and wt regardless of what the source
#   file called them.
#______________________________________________________________________________

# map is a named character vector: c(id = , strata = , psu = , weight = ).
#   unclass() strips the labelled class so the values are plain numbers; the
#   labels are kept in the codebook, which is where they belong.
build_design_frame <- function(raw, map) {
  need = c("id", "strata", "psu", "weight")
  missing = setdiff(need, names(map))
  if (length(missing))
    stop("Design map is missing: ", paste(missing, collapse = ", "),
         call. = FALSE)

  absent = setdiff(unname(map[need]), names(raw))
  if (length(absent))
    stop("Named in the design map but not in the data: ",
         paste(absent, collapse = ", "), call. = FALSE)

  tibble::tibble(
    id     = as.numeric(unclass(raw[[map[["id"]]]])),
    strata = as.numeric(unclass(raw[[map[["strata"]]]])),
    psu    = as.numeric(unclass(raw[[map[["psu"]]]])),
    wt     = as.numeric(unclass(raw[[map[["weight"]]]])))
}


# Section 2 collapses nominations that are the same variable twice.
#______________________________________________________________________________

# Two candidates that cut the sample the same way are interchangeable, and
#   asking the analyst to choose between them is asking a question with no
#   answer. This arose on a file whose stratum variable is duplicated under a
#   name carrying a weight's label; the partition settled it where neither the
#   name nor the label could.
partition_identical <- function(raw, a, b) {
  ka = as.integer(factor(as.numeric(unclass(raw[[a]]))))
  kb = as.integer(factor(as.numeric(unclass(raw[[b]]))))
  identical(ka, kb)
}

# Returns the nomination table with an equivalence group per role, so the app
#   can show one row per distinct partition and note the aliases.
group_nominations <- function(raw, nominations) {
  nominations |>
    dplyr::filter(!is.na(variable)) |>
    dplyr::group_by(role) |>
    dplyr::mutate(group = purrr::map_int(variable, function(v)
      purrr::detect_index(variable, function(u)
        partition_identical(raw, u, v)))) |>
    dplyr::ungroup()
}


# Section 3 is the specification check. Every line answers a question an
#   analyst would otherwise have to think to ask, and three of them halt.
#______________________________________________________________________________

# A non-positive or missing weight is silently dropped by some estimators and
#   kept by others, so the same file gives different Ns in different places
#   with no error anywhere. It is checked first because it is the cheapest
#   thing to get wrong.

# A singleton stratum cannot take the n_h / (n_h - 1) replicate scaling.
#   survey.lonely.psu governs linearization rather than replicate construction,
#   so continuing would contribute zero variance from the strata carrying the
#   least information. build_rep_design() stops on this too; reporting it here
#   means the analyst sees it while they can still change the specification.

# The unequal weighting effect is Kish's 1 + CV^2: roughly the factor by which
#   weighting inflates the variance of a mean. Near 1 says the weights are
#   doing nothing in this file, which is worth knowing before reading any
#   comparison between weighted and unweighted estimates.

design_checks <- function(design_dat) {
  n = nrow(design_dat)
  w = design_dat$wt

  psu_per_stratum = design_dat |>
    dplyr::distinct(strata, psu) |>
    dplyr::count(strata, name = "n_psu")

  cv = stats::sd(w, na.rm = TRUE) / mean(w, na.rm = TRUE)

  # value is always character: the column holds counts, ratios and formatted
  #   totals together, and a table the analyst reads has no use for the
  #   distinction. Without this the rows will not bind.
  row = function(check, value, status, note)
    tibble::tibble(check = check, value = as.character(value),
                   status = status, note = stringr::str_squish(note))

  dplyr::bind_rows(
    row("Respondents", format(n, big.mark = ","), "ok", ""),

    row("Missing weights", sum(is.na(w)),
        if (any(is.na(w))) "stop" else "ok",
        "A missing weight is dropped by some estimators and kept by others."),

    row("Non-positive weights", sum(w <= 0, na.rm = TRUE),
        if (any(w <= 0, na.rm = TRUE)) "stop" else "ok",
        "Zero-weight cases are excluded by lavaan and retained by survey."),

    row("Duplicate ids", sum(duplicated(design_dat$id)),
        if (anyDuplicated(design_dat$id)) "warn" else "ok",
        "Scoring joins on id; duplicates would multiply rows."),

    row("Strata", nrow(psu_per_stratum), "ok", ""),

    row("PSUs", dplyr::n_distinct(design_dat$psu), "ok",
        "Replicate count equals the number of PSUs."),

    row("Smallest stratum (PSUs)", min(psu_per_stratum$n_psu),
        if (min(psu_per_stratum$n_psu) < 2) "stop"
        else if (min(psu_per_stratum$n_psu) < 5) "warn" else "ok",
        "A singleton stratum cannot take the replicate scaling and halts the
         design. Under five is thin: domain estimates within it rest on very
         few clusters."),

    row("Mean PSU size", round(n / dplyr::n_distinct(design_dat$psu), 1),
        "ok", ""),

    row("Weight CV", round(cv, 3), "ok",
        "Spread of the weights around their mean."),

    row("Unequal weighting effect", round(1 + cv^2, 3),
        if (1 + cv^2 < 1.05) "warn" else "ok",
        "Kish's 1 + CV^2. Near 1 means weighting is doing almost nothing in
         this file, so weighted and unweighted estimates will barely differ."),

    row("Sum of weights", format(round(sum(w, na.rm = TRUE)), big.mark = ","),
        "ok", "Compare against the population this file claims to represent."))
}

# The app renders the table; this is what a script calls to refuse to continue.
assert_design_ok <- function(checks) {
  bad = dplyr::filter(checks, status == "stop")
  if (nrow(bad))
    stop("Design specification failed:\n",
         paste0("  ", bad$check, ": ", bad$value, collapse = "\n"),
         call. = FALSE)
  invisible(checks)
}

# ---- stage_02_items ----------------------------------------------------

# stage_02_items.R for WISE repo
# Stage 3: nonresponse codes, item selection, and the arm diagnostic.

#   1. Nonresponse codes
#   2. The item frame
#   3. What the analyst looks at
#   4. The arm diagnostic
#   5. Prompts

# Requires: dplyr, purrr, tibble, stringr, ggplot2


# Section 1 finds the nonresponse codes rather than asking for them. They are
#   in the file with labels attached, so typing them is a typo surface with no
#   upside.
#______________________________________________________________________________

# SPSS declares its user-missing values in the file, so they are read rather
#   than guessed. haven exposes them as the na_values attribute when the file is
#   read with user_na = TRUE, which is what read_survey() does.

# The label pattern is a fallback for files that carry no declaration -- Stata
#   in particular, where extended missing values arrive as tagged NAs. Short
#   forms are included because questionnaires use them: this file labels its
#   codes DK, NR and N/A rather than spelling them out.
NA_LABEL_PATTERNS <- paste(
  "^dk$", "^nr$", "^n/a$", "^na$", "^inap$",
  "no sabe", "no responde", "no contesta", "no aplica",
  "don't know", "dont know", "no answer", "no response",
  "refused", "declined", "not applicable", "missing",
  sep = "|")

detect_na_codes <- function(raw, variables) {
  purrr::map(variables, function(v) {
    x = raw[[v]]
    declared = attr(x, "na_values", exact = TRUE)
    lab = attr(x, "labels", exact = TRUE)
    key = if (length(lab)) rlang::set_names(names(lab), as.character(unname(lab)))
          else character(0)

    codes = if (length(declared)) as.numeric(declared) else {
      if (!length(lab)) return(NULL)
      hit = stringr::str_detect(tolower(names(lab)), NA_LABEL_PATTERNS)
      as.numeric(unname(lab[hit]))
    }
    if (!length(codes)) return(NULL)

    ch = as.character(codes)
    tibble::tibble(
      variable = v,
      code = codes,
      response = unname(dplyr::if_else(ch %in% names(key), key[ch], ch)),
      source = if (length(declared)) "declared" else "label")
  }) |>
    purrr::list_rbind() |>
    dplyr::count(code, response, source, name = "n_items") |>
    dplyr::arrange(dplyr::desc(n_items))
}


# Section 2 builds the item frame. Items are recoded to consecutive integers on
#   every row, so the estimation frame and the prediction frame are always on
#   the same coding. Levels come from the rows that will be fitted; a value seen
#   only outside that set becomes NA and drops out of that respondent's product.
#______________________________________________________________________________

# How many people answered each item, and how many answered each pair. The pair
#   counts are what catch a split ballot: two items asked of disjoint subsamples
#   are never answered by the same person, so no model can relate them however
#   well they belong together conceptually.
item_coverage <- function(item_dat) {
  M = !is.na(as.matrix(item_dat))
  joint = crossprod(M)
  diag_j = diag(joint)
  off = joint
  diag(off) = NA_integer_

  tibble::tibble(
    item = colnames(M),
    answered = as.integer(diag_j),
    min_shared = as.integer(apply(off, 1, min, na.rm = TRUE))) |>
    dplyr::mutate(flag = dplyr::if_else(
      min_shared == 0, "never answered alongside another item", NA_character_))
}

# item_map is a named character vector: analysis name = source variable.
build_item_frame <- function(raw, item_map, na_codes, complete_cases = TRUE,
                             min_items = NULL) {
  items = names(item_map)
  if (is.null(min_items)) min_items = ceiling(length(items) / 2)

  item_dat = raw |>
    dplyr::select(dplyr::all_of(item_map)) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), function(x) {
      v = as.numeric(unclass(x))
      dplyr::if_else(v %in% na_codes, NA_real_, v)
    })) |>
    rlang::set_names(items)

  n_answered = rowSums(!is.na(item_dat))
  in_analysis = if (complete_cases) n_answered == length(items)
                else n_answered >= min_items

  # Halting here with the numbers is the difference between an analyst learning
  #   their battery spans a split ballot and an analyst watching the app die.
  if (sum(in_analysis) < 50L) {
    cov = item_coverage(item_dat)
    split = dplyr::filter(cov, min_shared == 0)
    stop(
      "Only ", sum(in_analysis), " respondents qualify for this battery",
      if (complete_cases) " (answered every item)"
        else paste0(" (answered at least ", min_items, " items)"), ".\n",
      "The most any respondent answered is ", max(n_answered), " of ",
      length(items), ".\n",
      if (nrow(split))
        paste0("These items are never answered alongside another item in the ",
               "battery, which usually means a split ballot: ",
               paste(split$item, collapse = ", "), ".\n") else "",
      "Choose items asked of the same respondents, or untick ",
      "'Fit on item-complete cases only'.",
      call. = FALSE)
  }

  item_levels = purrr::map(item_dat[in_analysis, ],
                           function(x) sort(unique(x[!is.na(x)])))
  cats = purrr::map_int(item_levels, length)

  item_dat = item_dat |>
    dplyr::mutate(dplyr::across(dplyr::everything(),
                                function(x) match(x, item_levels[[dplyr::cur_column()]])))

  list(item_dat = item_dat, items = items, cats = cats,
       item_levels = item_levels, n_answered = n_answered,
       in_analysis = in_analysis, min_items = min_items,
       dictionary = build_item_dictionary(raw, item_map, item_levels))
}

# Question wording and response labels in item_levels order, so the response
#   text lines up with the fitted category indices. This is what the labelling
#   prompt reads.
build_item_dictionary <- function(raw, item_map, item_levels) {
  tibble::tibble(item = names(item_map), variable = unname(item_map)) |>
    dplyr::mutate(
      question = purrr::map_chr(variable, function(v) {
        lab = attr(raw[[v]], "label", exact = TRUE)
        if (is.character(lab) && length(lab) == 1 && nzchar(lab)) lab else v
      }),
      responses = purrr::map2(variable, item, function(v, it) {
        vl = attr(raw[[v]], "labels", exact = TRUE)
        key = if (length(vl)) rlang::set_names(names(vl), as.character(unname(vl)))
              else character(0)
        vals = as.character(item_levels[[it]])
        unname(dplyr::if_else(vals %in% names(key), key[vals], vals))
      }))
}


# Section 3 is what the analyst reads before committing to a battery. Variation
#   is the thing to look for: an item everyone answers the same way carries no
#   information about who differs from whom, and it will pass every fit
#   statistic while contributing nothing.
#______________________________________________________________________________

item_summary <- function(frame) {
  cov = item_coverage(frame$item_dat)

  purrr::map(frame$items, function(it) {
    x = frame$item_dat[[it]]
    tab = table(x)
    tibble::tibble(
      item = it,
      categories = frame$cats[[it]],
      answered = sum(!is.na(x)),
      missing_pct = round(100 * mean(is.na(x)), 1),
      # An item nobody answered has no modal category; max() of an empty table
      #   returns -Inf with a warning, which is worse than saying so.
      modal_pct = if (length(tab)) round(100 * max(tab) / sum(tab), 1)
                  else NA_real_)
  }) |>
    purrr::list_rbind() |>
    dplyr::left_join(dplyr::select(cov, item, min_shared), by = "item") |>
    dplyr::mutate(flag = dplyr::case_when(
      is.na(modal_pct) ~ "no valid answers",
      min_shared == 0 ~ "never answered alongside another item",
      modal_pct >= 95 ~ "almost no variation",
      modal_pct >= 85 ~ "little variation",
      missing_pct >= 20 ~ "high item nonresponse",
      TRUE ~ NA_character_)) |>
    dplyr::arrange(dplyr::desc(modal_pct))
}

# The stacked bar of raw responses, missing included. Reuses the engine plot so
#   the app and the report show the same picture.
plot_items <- function(frame, title = "Response distribution") {
  plot_item_stack(frame$item_dat, frame$items, title, show_missing = TRUE)
}


# Section 4 is the arm diagnostic. It answers whether respondents differ in how
#   much or in which, and it runs before either arm is fitted so the choice is
#   informed rather than asserted.
#______________________________________________________________________________

# Two cheap signals from the weighted correlation matrix alone. A dominant first
#   eigenvalue says one continuum, which the factor arm describes with far fewer
#   parameters. Mixed response formats across unrelated domains point the other
#   way: a household can own a computer and still have run short of food, and
#   no single continuum holds that.

# The level-to-pattern ratio is the sharper diagnostic but needs a fitted LCA,
#   so it is a confirmation after the class arm is chosen rather than an input
#   to choosing.
arm_diagnostics <- function(frame, design_dat) {
  keep = frame$in_analysis
  d = frame$item_dat[keep, , drop = FALSE]
  w = design_dat$wt[keep]

  if (nrow(d) < 50L)
    stop("Too few respondents (", nrow(d), ") to describe the battery's ",
         "structure.", call. = FALSE)

  R = wcor(w, frame$items, d)
  ev = eigen(R, only.values = TRUE)$values

  tibble::tibble(
    n_items = length(frame$items),
    n_formats = dplyr::n_distinct(frame$cats),
    min_categories = min(frame$cats),
    max_categories = max(frame$cats),
    eigen_1 = round(ev[1], 2),
    eigen_2 = round(ev[2], 2),
    eigen_ratio = round(ev[1] / ev[2], 2),
    var_explained_1 = round(100 * ev[1] / sum(ev), 1))
}


# Section 5 hands the diagnostics to the model. R computes every number here;
#   the model reads them alongside the analyst's stated goal and argues once.
#   It does not decide, and the analyst's preference stands either way.
#______________________________________________________________________________

persona_pm <- paste(
  "You are a senior survey methodologist advising an analyst who designed the",
  "questionnaire and knows the subject matter, but does not fit latent variable",
  "models. Write plainly and briefly. Explain what a number means for their",
  "decision rather than defining the statistic. Never recommend dropping an",
  "item and never choose a model; those are the analyst's calls.")

prompt_battery_proposal <- function(candidates, context) {
  rows = stringr::str_glue_data(
    candidates, "  {variable} ({n_responses} categories): {label}")
  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "CANDIDATE VARIABLES\n{paste(rows, collapse = '\n')}\n\n",
    "TASK\nGroup these into at most four candidate batteries. A battery is a",
    " set of items that plausibly measure one underlying thing, judged from the",
    " question wording and the response format. Name each battery, list its",
    " variables, and give one sentence on what it appears to measure. Leave out",
    " variables that fit no battery.\n\n",
    "Return only valid JSON, no prose and no markdown fences:\n",
    '{{"batteries": [{{"name": "...", "variables": ["..."], "rationale": "..."}}]}}')
}

prompt_arm_recommendation <- function(diag, summary_tbl, preference, context) {
  flagged = dplyr::filter(summary_tbl, !is.na(flag))
  flag_lines = if (nrow(flagged))
    stringr::str_glue_data(flagged, "  {item}: {flag} (modal category {modal_pct}%)")
    else "  none"

  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "STATED PREFERENCE\n  {preference}\n\n",
    "BATTERY STRUCTURE\n",
    "  {diag$n_items} items, {diag$n_formats} distinct response format(s), ",
    "{diag$min_categories} to {diag$max_categories} categories.\n",
    "  First eigenvalue {diag$eigen_1}, second {diag$eigen_2}, ratio ",
    "{diag$eigen_ratio}. The first component accounts for ",
    "{diag$var_explained_1}% of the variance.\n\n",
    "ITEMS FLAGGED FOR VARIATION OR NONRESPONSE\n{paste(flag_lines, collapse = '\n')}\n\n",
    "TASK\nA latent class model asks which answers a respondent favours and",
    " returns a segment. A factor model asks how much of one thing a respondent",
    " has and returns a position on a continuum. Say which fits this battery,",
    " in three or four sentences, using the numbers above. If the evidence",
    " disagrees with the stated preference, say so plainly and once. Do not",
    " recommend removing any item.\n\n",
    "Return only valid JSON, no prose and no markdown fences:\n",
    '{{"recommendation": "lca" or "cfa", "reasoning": "...", ',
    '"agrees_with_preference": true or false}}')
}

# ---- stage_03_recode ---------------------------------------------------

# stage_03_recode.R for WISE repo
# Stage 4: collapse the demographic and attitudinal domains.

#   1. Candidates and observed levels
#   2. Applying a specification
#   3. The audit
#   4. Prompt

# The demographic recodes are the one place where a mistake is silent: nothing
#   fails, no statistic looks wrong, and every later table is quietly about the
#   wrong people. So an unmatched source label halts, and the audit showing what
#   became what is a table the analyst reads once per dataset rather than an
#   object buried in the session.

# Requires: dplyr, purrr, tibble, stringr, haven


# Section 1 finds what can be collapsed and shows how people actually answered.
#______________________________________________________________________________

# Two kinds of variable arrive here. One carries response labels and is
#   collapsed by mapping labels onto groups. The other is a number -- age is the
#   usual case -- and is collapsed by cutting it into bands. They need different
#   controls, so the kind is decided here rather than in the interface.
demo_candidates <- function(codebook, max_categories = 30L) {
  codebook |>
    dplyr::filter(n_distinct > 1, !is.na(label)) |>
    dplyr::mutate(kind = dplyr::if_else(
      n_responses > 1 & n_responses <= max_categories, "map", "cut")) |>
    dplyr::filter(kind == "map" | n_distinct >= 5) |>
    dplyr::arrange(variable)
}

# Labels with their counts, in code order. The count is the point: a category
#   holding eleven people will produce an estimate no reader should act on, and
#   that is visible here and nowhere later.
observed_levels <- function(raw, variable, na_codes = numeric(0)) {
  x = raw[[variable]]
  v = as.numeric(unclass(x))
  keep = !(v %in% na_codes)

  tibble::tibble(
    code = v[keep],
    source_label = as.character(haven::as_factor(x))[keep]) |>
    dplyr::count(code, source_label, name = "n") |>
    dplyr::arrange(code)
}

# For a numeric variable there are no labels to show, so the distribution is
#   what the analyst reads before choosing cut points.
numeric_summary <- function(raw, variable, na_codes = numeric(0)) {
  v = as.numeric(unclass(raw[[variable]]))
  v = v[!(v %in% na_codes) & !is.na(v)]
  tibble::tibble(n = length(v), min = min(v), q25 = stats::quantile(v, .25),
                 median = stats::median(v), q75 = stats::quantile(v, .75),
                 max = max(v))
}


# Section 2 applies a specification. A spec is one entry per target variable:
#
#   list(source = "q1tc_r", kind = "map",
#        map = c("Hombre/masculino" = "Male", "Mujer/femenino" = "Female",
#                "No se identifica como hombre ni como mujer" = NA))
#
#   list(source = "q2", kind = "cut",
#        breaks = c(15, 29, 44, 59, Inf),
#        labels = c("16-29", "30-44", "45-59", "60+"))
#
# reference names the level that later contrasts are read against; the rest
#   follow in order of size.
#______________________________________________________________________________

apply_map <- function(x, map, na_codes) {
  v = as.numeric(unclass(x))
  src = as.character(haven::as_factor(x))
  src[v %in% na_codes] = NA_character_

  known = src %in% names(map) | is.na(src)
  unmatched = unique(src[!known])
  if (length(unmatched))
    stop("Source labels with no rule: ",
         paste(shQuote(unmatched), collapse = ", "),
         ". Every observed label must be given a group or left blank.",
         call. = FALSE)

  out = rep(NA_character_, length(src))
  hit = !is.na(src)
  out[hit] = unname(map[src[hit]])
  out
}

apply_cut <- function(x, breaks, labels, na_codes) {
  v = as.numeric(unclass(x))
  v[v %in% na_codes] = NA_real_
  as.character(cut(v, breaks = breaks, labels = labels))
}

build_demo_frame <- function(raw, specs, na_codes = numeric(0)) {
  cols = purrr::imap(specs, function(s, nm) {
    val = switch(s$kind,
      map = apply_map(raw[[s$source]], s$map, na_codes),
      cut = apply_cut(raw[[s$source]], s$breaks, s$labels, na_codes),
      stop("Unknown recode kind: ", s$kind, call. = FALSE))

    # Levels in order of size, with the analyst's reference first. Contrasts in
    #   the reports are read against the first level, so this is a decision
    #   rather than a formatting choice.
    lv = names(sort(table(val), decreasing = TRUE))
    if (!is.null(s$reference) && s$reference %in% lv)
      lv = c(s$reference, setdiff(lv, s$reference))
    factor(val, levels = lv)
  })

  tibble::as_tibble(cols)
}


# Section 3 is the audit. Read once per dataset, before anything is fitted.
#______________________________________________________________________________

recode_audit <- function(raw, demo_dat, specs) {
  purrr::imap(specs, function(s, nm) {
    tibble::tibble(
      variable = nm,
      source_label = as.character(haven::as_factor(raw[[s$source]])),
      recoded = as.character(demo_dat[[nm]]))
  }) |>
    purrr::list_rbind() |>
    dplyr::count(variable, source_label, recoded, name = "n") |>
    dplyr::arrange(variable, dplyr::desc(n))
}

# A level too small to estimate within is worth knowing before it appears in a
#   domain table with an interval wide enough to contain everything.
demo_counts <- function(demo_dat, min_n = 30L) {
  purrr::imap(demo_dat, function(x, nm)
    tibble::tibble(variable = nm, level = levels(x)) |>
      dplyr::mutate(n = as.integer(table(x)[level]),
                    missing = sum(is.na(x)))) |>
    purrr::list_rbind() |>
    dplyr::mutate(flag = dplyr::if_else(n < min_n, "too small to report", NA_character_))
}


# Section 4 hands the observed labels to the model. It sees label text and
#   counts, never a respondent record, and it proposes groupings for the
#   analyst to accept or rewrite.
#______________________________________________________________________________

prompt_demo_grouping <- function(variable, label, levels_tbl, context) {
  rows = stringr::str_glue_data(levels_tbl, "  {source_label} (n = {n})")
  stringr::str_glue(
    "ANALYST CONTEXT\n{context}\n\n",
    "VARIABLE\n  {variable}: {label}\n\n",
    "OBSERVED CATEGORIES\n{paste(rows, collapse = '\n')}\n\n",
    "TASK\nPropose a grouping of these categories for use as a demographic",
    " domain in survey estimation. Combine categories that are substantively",
    " similar, and combine any category too small to estimate within -- under",
    " about thirty respondents -- into a larger one where that is defensible.",
    " Give every observed category a group. Use an empty string for a category",
    " that should be treated as missing rather than grouped. Group names should",
    " be short and in English.\n\n",
    "Do not suggest a reference level. Which group later comparisons are read",
    " against is a decision about how the findings will be presented, and it",
    " belongs to the analyst.\n\n",
    "Return only valid JSON, no prose and no markdown fences:\n",
    '{{"groups": [{{"source": "...", "group": "..."}}]}}')
}

