# metadata.R -- what the model may know about the R session.
#
# Two levels, and nothing beyond them reaches the API:
#   describe_*  structure only: names, classes, dimensions, column types,
#               variable labels, factor levels and value labels. No values.
#   profile_*   aggregates: counts, shares, means and quartiles, as plain
#               text, with every count below suppress_n shown as "<n" and
#               one more cell suppressed so the small one cannot be worked
#               out from the total. Minimum and maximum are never shown:
#               each is one respondent's value.
# Everything returned passes through scrub_text().
# Function definitions and constants only.

MAX_LEVELS <- 25L    # levels or labels listed per variable
MAX_COLS   <- 300L   # columns described or profiled per data frame
MAX_ITEMS  <- 50L    # elements listed for a list

# ---- small pieces ------------------------------------------------------

dims_text <- function(x)
  if (!is.null(dim(x))) paste(dim(x), collapse = " x ") else paste("length", length(x))

type_of <- function(col) {
  if (inherits(col, "haven_labelled")) return(paste("labelled", typeof(unclass(col))))
  if (is.ordered(col)) return("ordered factor")
  if (is.factor(col)) return("factor")
  class(col)[1]
}

listed <- function(x, sep = " | ") {
  shown = utils::head(x, MAX_LEVELS)
  paste0(paste(shown, collapse = sep),
         if (length(x) > MAX_LEVELS) paste0(sep, "... (", length(x) - MAX_LEVELS, " more)"))
}

var_label <- function(col) {
  lab = attr(col, "label", exact = TRUE)
  if (is_string(lab)) lab else NULL
}

capped <- function(x, label) {
  if (ncol(x) <= MAX_COLS) return(list(x = x, note = NULL))
  list(x = x[seq_len(MAX_COLS)],
       note = paste0("(only the first ", MAX_COLS, " of ", ncol(x), " columns of `",
                     label, "` are listed)"))
}

# ---- describe: structure only ------------------------------------------

describe_column <- function(col, name) {
  labs = attr(col, "labels", exact = TRUE)
  paste(c(
    sprintf("- %s <%s>", name, type_of(col)),
    if (!is.null(var_label(col))) sprintf("label \"%s\"", var_label(col)),
    if (is.factor(col)) paste0(nlevels(col), " levels: ", listed(levels(col))),
    if (length(labs)) paste0("value labels: ",
                             listed(paste0(unname(labs), "=", names(labs)), sep = ", "))),
    collapse = "; ")
}

describe_df <- function(x, label) {
  cp = capped(x, label)
  groups = if (inherits(x, "grouped_df"))
    setdiff(names(attr(x, "groups")), ".rows")
  c(sprintf("`%s`: %s, %s rows x %s columns%s", label, paste(class(x), collapse = "/"),
            nrow(x), ncol(x),
            if (length(groups)) paste0(", grouped by ", paste(groups, collapse = ", ")) else ""),
    unname(purrr::imap_chr(cp$x, describe_column)),
    cp$note)
}

# Strata and PSU counts are properties of the design, not of anyone in it,
#   and a stratum with one PSU is the first thing a variance estimate needs
#   to know about.
describe_design <- function(x, label) {
  head_line = sprintf("`%s`: survey design (%s), %s rows",
                      label, paste(class(x), collapse = "/"), nrow(x$variables))
  call_line = if (!is.null(x$call))
    paste("created by:", paste(deparse(x$call, width.cutoff = 200L), collapse = " "))
  design_lines = if (inherits(x, "svyrep.design")) {
    c(paste0("replicate weights: type ", x$type %||% "unknown", ", ",
             length(x$rscales), " replicates", if (isTRUE(x$mse)) ", mse = TRUE"))
  } else if (!is.null(x$strata) && !is.null(x$cluster)) {
    psu = tapply(x$cluster[[1]], x$strata[[1]], function(v) length(unique(v)))
    c(paste0(length(psu), " strata, ", sum(psu), " PSUs at stage 1"),
      if (any(psu == 1L)) paste0(sum(psu == 1L), " strata have a single PSU ",
                                 "(see options(survey.lonely.psu))"))
  }
  c(head_line, call_line, design_lines,
    "its variables:", describe_df(x$variables, "variables")[-1])
}

describe_list <- function(x, label) {
  nm = names(x) %||% rep("", length(x))
  items = purrr::map2_chr(utils::head(x, MAX_ITEMS), utils::head(nm, MAX_ITEMS),
                          function(el, n) sprintf("  $%s <%s, %s>",
                                                  if (nzchar(n)) n else "?",
                                                  class(el)[1], dims_text(el)))
  fml = tryCatch(paste(deparse(stats::formula(x)), collapse = " "), error = function(e) NULL)
  c(sprintf("`%s`: %s, %s", label, paste(class(x), collapse = "/"), dims_text(x)),
    if (!is.null(fml)) paste("formula:", fml),
    items,
    if (length(x) > MAX_ITEMS) paste0("  ... (", length(x) - MAX_ITEMS, " more)"))
}

describe_atomic <- function(x, label)
  paste(c(sprintf("`%s`: %s, %s", label, type_of(x), dims_text(x)),
          if (!is.null(var_label(x))) sprintf("label \"%s\"", var_label(x)),
          if (is.factor(x)) paste0("levels: ", listed(levels(x)))),
        collapse = "; ")

# Any value, described by structure. `label` is how the model will refer to it.
describe_value <- function(x, label) {
  out = if (inherits(x, c("survey.design", "svyrep.design"))) describe_design(x, label)
    else if (is.data.frame(x)) describe_df(x, label)
    else if (is.function(x)) sprintf("`%s`: function(%s)", label,
                                     paste(names(formals(x)), collapse = ", "))
    else if (is.atomic(x) || is.null(x)) describe_atomic(x, label)
    else if (is.list(x)) describe_list(x, label)
    else sprintf("`%s`: %s", label, paste(class(x), collapse = "/"))
  scrub_text(out)
}

# An object by name: from the workspace, or one %ask% was given as an
#   expression (palmerpenguins::penguins, a pipeline), pinned under its label
#   for this conversation. NULL when there is none.
find_object <- function(name, env = globalenv()) {
  if (!is_string(name)) return(NULL)
  if (exists(name, envir = env, inherits = FALSE))
    return(list(value = get(name, envir = env, inherits = FALSE)))
  if (name %in% names(.state$pinned)) return(list(value = .state$pinned[[name]]))
  NULL
}

describe_object <- function(name, env = globalenv()) {
  obj = find_object(name, env)
  if (is.null(obj))
    return(paste0("There is no object called `", name, "` in the workspace. ",
                  "Call env_summary to see what there is."))
  describe_value(obj$value, name)
}

# One line per object in the workspace.
env_summary <- function(env = globalenv()) {
  nms = ls(env)
  if (!length(nms)) return("The workspace is empty.")
  lines = purrr::map_chr(nms, function(n) {
    x = get(n, envir = env, inherits = FALSE)
    sprintf("- %s <%s> %s", n, paste(class(x), collapse = "/"), dims_text(x))
  })
  scrub_text(c(paste0("Workspace objects (", length(nms), "):"), lines))
}

# ---- profile: suppressed aggregates ------------------------------------

# Counts as text. Cells from 1 to k-1 become "<k". When exactly one cell in a
#   variable is that small, the next-smallest nonzero cell is hidden too, so
#   the small one cannot be recovered by subtraction from the total. That
#   second cell is marked "suppressed", not "<k": it may be large, and saying
#   "<k" would be false (a model read it literally in testing).
suppress_counts <- function(n, k) {
  small = n > 0 & n < k
  others = which(!small & n > 0)
  extra = rep(FALSE, length(n))
  if (sum(small) == 1L && length(others))
    extra[others[which.min(n[others])]] = TRUE
  out = format(n, big.mark = ",", trim = TRUE)
  out[extra] = "suppressed"
  out[small] = paste0("<", k)
  out
}

is_hidden <- function(shown) startsWith(shown, "<") | shown == "suppressed"

fmt_num <- function(x) format(signif(x, 4), big.mark = ",", scientific = FALSE, trim = TRUE)

# A labelled column as a factor of its value labels, without needing haven.
#   Values with no label are grouped as "(unlabelled value)".
labelled_as_factor <- function(col) {
  labs = attr(col, "labels", exact = TRUE)
  v = unclass(col)
  out = names(labs)[match(v, labs)]
  out[is.na(out) & !is.na(v)] = "(unlabelled value)"
  factor(out, levels = unique(c(names(labs), if (any(out == "(unlabelled value)", na.rm = TRUE))
    "(unlabelled value)")))
}

# A frequency table. For character columns the text of a suppressed value is
#   hidden as well as its count: a value seen fewer than k times may be a
#   name or a free-text answer.
profile_categorical <- function(values, n_valid, k, hide_rare_text) {
  tab = table(values, useNA = "no")
  n = as.integer(tab)
  shown = suppress_counts(n, k)
  sup = is_hidden(shown)
  cells = ifelse(sup, paste0(names(tab), " ", shown),
                 sprintf("%s %s (%.0f%%)", names(tab), shown, 100 * n / n_valid))
  if (hide_rare_text && any(sup))
    cells = c(cells[!sup], paste0(sum(sup), " other values, hidden (rare, or hidden to protect a rare one)"))
  listed(cells, sep = "; ")
}

profile_numeric <- function(v, k) {
  q = stats::quantile(v, c(0.25, 0.5, 0.75), names = FALSE)
  sprintf("mean %s, sd %s, quartiles %s / %s / %s (min and max withheld)",
          fmt_num(mean(v)), fmt_num(stats::sd(v)), fmt_num(q[1]), fmt_num(q[2]), fmt_num(q[3]))
}

profile_column <- function(col, name, k) {
  n_miss = sum(is.na(col))
  n_valid = length(col) - n_miss
  head_txt = sprintf("- %s <%s>%s: ", name, type_of(col),
                     if (!is.null(var_label(col))) sprintf(" \"%s\"", var_label(col)) else "")
  miss_txt = if (n_miss > 0 && n_miss < k) paste0("missing <", k)
             else paste0(format(n_valid, big.mark = ","), " valid, ",
                         format(n_miss, big.mark = ","), " missing")
  if (n_valid < k)
    return(paste0(head_txt, "fewer than ", k, " valid values; nothing more shown."))

  v = col[!is.na(col)]
  body = if (inherits(col, "haven_labelled")) {
    profile_categorical(labelled_as_factor(v), n_valid, k, hide_rare_text = FALSE)
  } else if (is.factor(col) || is.logical(col)) {
    profile_categorical(v, n_valid, k, hide_rare_text = FALSE)
  } else if (is.numeric(col) && length(unique(v)) <= 10L) {
    paste0(profile_categorical(v, n_valid, k, hide_rare_text = FALSE),
           "; mean ", fmt_num(mean(v)))
  } else if (is.numeric(col)) {
    profile_numeric(as.numeric(v), k)
  } else if (inherits(col, c("Date", "POSIXt"))) {
    q = stats::quantile(as.numeric(v), c(0.05, 0.95), names = FALSE)
    o = if (inherits(col, "Date")) as.Date(q) else as.POSIXct(q, origin = "1970-01-01")
    paste0("middle 90% from ", format(o[1], "%Y-%m"), " to ", format(o[2], "%Y-%m"))
  } else if (is.character(col) && length(unique(v)) <= MAX_LEVELS) {
    profile_categorical(v, n_valid, k, hide_rare_text = TRUE)
  } else if (is.character(col)) {
    paste0(format(length(unique(v)), big.mark = ","), " distinct values (not listed)")
  } else {
    "no summary for this type"
  }
  paste0(head_txt, miss_txt, ". ", body)
}

# A data frame (or the variables of a survey design) as suppressed,
#   unweighted aggregates in plain text.
profile_value <- function(x, label, k = INTERN_LLM$suppress_n) {
  design = inherits(x, c("survey.design", "svyrep.design"))
  df = if (design) x$variables else x
  if (!is.data.frame(df))
    return(paste0("`", label, "` is not a data frame or survey design, so there is ",
                  "nothing to profile. describe_object shows its structure."))
  cp = capped(df, label)
  out = c(sprintf(paste0("Profile of `%s`: %s rows x %s columns. Counts are unweighted%s. ",
                         "Counts below %s are shown as <%s. A count shown as \"suppressed\" is hidden only so ",
                         "a small one cannot be worked out; it may be large. Minimum and maximum are never shown."),
                  label, nrow(df), ncol(df),
                  if (design) " (respondents, not population estimates)" else "", k, k),
          unname(purrr::imap_chr(cp$x, profile_column, k = k)),
          cp$note)
  scrub_text(out)
}

profile_object <- function(name, env = globalenv()) {
  obj = find_object(name, env)
  if (is.null(obj)) return(paste0("There is no object called `", name, "` in the workspace."))
  profile_value(obj$value, name)
}
