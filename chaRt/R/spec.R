# spec.R for chaRt
# The plot spec (DESIGN.md section 6, as revised by the Phase 2 prompt): defaults, the check
#   against the codebook, the table that is drawn, the lint, the ggplot, the plotly version, the R
#   code that reproduces the chart, and the figure size. Nothing here calls a model.
#
# One source for three outputs. The table's steps (filter, drop_na, summarise, ...) and the plot's
#   layers are built once, as R calls, from the spec and the codebook. spec_table() and
#   spec_plot() evaluate those calls; spec_code() writes the same calls out as text. So the code a
#   chart comes with draws that chart and builds that table, by construction. The calls name
#   dplyr, tidyr, ggplot2 and scales functions without pkg::, as the written code does; they are
#   evaluated in spec_env(), which holds those packages' exports. Column names and values enter the
#   calls as symbols and constants, never as pasted text. Function definitions and constants only.


# ---- thresholds and vocabulary --------------------------------------------------------------

SPEC_TOP_MAX <- 30L          # top_n at most this; a name-like column at most this many values
SPEC_BAR_GROUPS <- 4L        # colours in a bar or dot chart
SPEC_BOX_GROUPS <- 12L       # boxes in a box plot
SPEC_FACET_MAX <- 16L        # panels in small multiples
SPEC_FLIP_BARS <- 8L         # bars, dots or boxes drawn sideways above this many
SPEC_FLIP_CHARS <- 12L       # ... or when a label is longer than this
SPEC_COLOURS <- 7L           # more colours than this: the lint speaks
SPEC_LINES <- 5L             # more lines than this with no highlight or facet: the lint speaks
SPEC_ALPHA_N <- 2000L        # points above this many are drawn transparent
SPEC_BIN_N <- 20000L         # points above this many are drawn as binned counts
SPEC_WIDGET_N <- 5000L       # marks above this many: no plotly version
SPEC_BINS <- c(5L, 60L)      # a histogram's bins, given or chosen
SPEC_ALPHA <- 0.3            # transparency of crowded points
SPEC_BIN_2D <- 40L           # bins on each axis of a binned scatter
SPEC_SIZE <- c(width = 7, height = 4.5, max_height = 14, max_width = 10)
SPEC_DPI <- 192L             # pixels per inch of every static image; it is shown at its size in inches
SPEC_FIT_TRIM_N <- 100L      # a fitted curve on this many rows or more is drawn only ...
SPEC_FIT_TRIM <- c(0.01, 0.99) # ... between these percentiles of x (it is fitted on every row)
SPEC_FIT_POINTS <- 80L       # points the trimmed curve is drawn at
SPEC_ROW_INCHES <- 0.28      # height of one sideways bar
SPEC_PANEL_INCHES <- 2.2     # height of one row of panels
SPEC_LABEL_GAP <- 0.04       # line-end labels closer than this share of the y range: a legend instead
SPEC_HEAT_LABELS <- 40L      # a heatmap with this many cells or fewer prints each value
SPEC_OVERLAP_SHARE <- 0.5    # more than this share of points on a shared position: points moved slightly
SPEC_JITTER <- 0.4           # ... by at most this share of the smallest gap between values on each axis
SPEC_JITTER_SEED <- 1L       # ... with this seed, so the chart is the same every time
SPEC_BUBBLE_N <- 60L         # more bubbles than this: the lint speaks
SPEC_LEGEND_PER_ROW <- 4L    # a legend at the top takes more rows past this many entries
SPEC_CODE_WIDTH <- 100L      # the written code breaks an argument list only past this many characters

SPEC_FAMILIES <- c("bar", "dot", "line", "slope", "scatter", "bubble", "histogram", "box", "heatmap")
SPEC_FNS <- c("none", "count", "share", "sum", "mean", "median")
SPEC_OPS <- c("==", "!=", ">", ">=", "<", "<=", "in")
SPEC_SORTS <- c("value_desc", "value_asc", "level_order", "alphabetical")
SPEC_FITS <- c("none", "loess", "linear")
SPEC_FIELDS <- c("family", "x", "y", "color", "size", "facet", "fn", "filter", "top_n", "sort", "log_x", "log_y",
                 "fit", "rug", "bins", "free_y", "highlight", "title", "subtitle", "caption", "x_label", "y_label",
                 "interactive", "rule", "say", "midpoint")
SPEC_COLUMN_FIELDS <- c("x", "y", "color", "size", "facet")
SPEC_TEXT_FIELDS <- c("title", "subtitle", "caption", "x_label", "y_label", "rule", "say")
SPEC_FLAG_FIELDS <- c("log_x", "log_y", "rug", "free_y", "interactive")

# Fields the lint adds; never accepted from outside.
SPEC_LINT_FIELDS <- c(".flip", ".alpha", ".binned", ".jitter", ".negative", ".labels", ".legend_order", ".cell_labels", ".top_n",
                      ".fit_range")

# What the plotly tooltip shows: the plotted values.
SPEC_TOOLTIP <- c("x", "y", "colour", "fill", "size")


# ---- small helpers ----------------------------------------------------------------------------

spec_fail <- function(msg) stop(errorCondition(msg, class = "spec_error", call = NULL))

is_text1 <- function(x) is.character(x) && length(x) == 1L && !is.na(x)
is_flag1 <- function(x) is.logical(x) && length(x) == 1L && !is.na(x)
is_whole1 <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x) && x == round(x)

cb_entry <- function(cb, name) purrr::detect(cb$columns, function(e) identical(e$name, name))
cb_label <- function(cb, name) cb_entry(cb, name)$label %||% name

# The kinds of column the spec rules speak of.
is_group_like <- function(e) e$type %in% c("category", "ordered", "flag") ||
  (identical(e$type, "integer") && e$distinct <= CODEBOOK_MAX_LEVELS)
is_name_like <- function(e) e$type %in% c("id", "text")
is_measure <- function(e) e$type %in% c("number", "integer")
is_time <- function(e) identical(e$type, "date") || identical(e$role, "time")

# How a column's values are stored, from what R detected: "number", "date", "datetime", "logical"
#   or "text". Decides how a filter or highlight value is written.
storage_of <- function(e) {
  d = e$detected %||% e$type
  if (d %in% c("integer", "number") || (identical(d, "id") && !is.null(e$quartiles))) return("number")
  if (identical(d, "date")) return(if (grepl(":", e$min %||% "")) "datetime" else "date")
  if (identical(d, "flag") && length(e$values) && all(e$values %in% c("TRUE", "FALSE"))) return("logical")
  if (identical(d, "flag") && length(e$values) && !anyNA(suppressWarnings(as.numeric(e$values)))) return("number")
  "text"
}

# A column's kind in words, with its article: "an integer column with 41 distinct values".
kind_text <- function(e) {
  words = switch(e$type,
    category = , ordered = paste0(e$type, " with ", e$distinct, " levels"),
    integer = , number = paste0(e$type, " column with ", e$distinct, " distinct values"),
    paste(e$type, "column"))
  paste(if (grepl("^[aeiou]", words)) "an" else "a", words)
}

# The spec's own fields, without what the lint added.
spec_public <- function(spec) spec[setdiff(names(spec), SPEC_LINT_FIELDS)]

# A filter's or highlight's values as given (JSON may bring them as a list).
values_of <- function(v) unlist(v, use.names = FALSE)

# The columns a spec uses, in a fixed order.
spec_columns <- function(s)
  unique(c(unlist(s[SPEC_COLUMN_FIELDS], use.names = FALSE), s$highlight$column))

# The column top_n and highlight act on in a bar, dot, line or slope.
ranked_column <- function(s) if (s$family %in% c("bar", "dot")) s$x else s$color


# ---- defaults ----------------------------------------------------------------------------------

default_fn <- function(spec) switch(spec$family %||% "",
  bar = , dot = if (is.null(spec$y)) "count",
  scatter = , bubble = , histogram = , box = "none",
  heatmap = if (is.null(spec$color)) "count",
  NULL)

# The defaults of the spec table, and nothing else. The sort of a bar, dot or box depends on the type
#   of x, so it is decided with the codebook (effective_sort()), not here.
spec_defaults <- function(spec) {
  d = list(fn = default_fn(spec), log_x = FALSE, log_y = FALSE, fit = "none", rug = FALSE, free_y = FALSE,
           interactive = FALSE)
  purrr::reduce(names(d), function(s, k) { if (is.null(s[[k]]) && !is.null(d[[k]])) s[[k]] = d[[k]]; s }, .init = spec)
}

effective_sort <- function(s, cb) {
  if (!s$family %in% c("bar", "dot", "box")) return(NULL)
  s$sort %||% if (identical(cb_entry(cb, s$x)$type, "ordered")) "level_order" else "value_desc"
}


# ---- the check (codebook only) -------------------------------------------------------------------

# A filter value written as it will be compared, or NULL when the value cannot be of the column's type.
typed_value <- function(e, v) {
  v = values_of(v)
  if (!length(v)) return(NULL)
  switch(storage_of(e),
    number = { n = suppressWarnings(as.numeric(v)); if (anyNA(n)) NULL else n },
    date = { d = tryCatch(as.Date(as.character(v), format = "%Y-%m-%d"), error = function(err) NA); if (anyNA(d)) NULL else as.character(v) },
    datetime = { d = suppressWarnings(as.POSIXct(as.character(v), tz = "UTC")); if (anyNA(d)) NULL else as.character(v) },
    logical = { l = as.logical(v); if (anyNA(l)) NULL else l },
    text = if (is.character(v) || is.numeric(v)) as.character(v) else NULL)
}

check_filter <- function(f, cb, i) {
  where = paste0("filter ", i, ": ")
  if (!is.list(f) || !is_text1(f$column) || !is_text1(f$op) || is.null(f$value))
    return(paste0(where, "each condition needs a column, an op and a value."))
  extra = setdiff(names(f), c("column", "op", "value"))
  if (length(extra)) return(paste0(where, "the field '", extra[1], "' is not one a condition has (column, op, value)."))
  e = cb_entry(cb, f$column)
  if (is.null(e)) return(paste0(where, "there is no column '", f$column, "' in the codebook."))
  if (identical(e$role, "ignore")) return(paste0(where, "the column '", f$column, "' has the role ignore, so it cannot be used."))
  if (!f$op %in% SPEC_OPS) return(paste0(where, "op must be one of ", paste(SPEC_OPS, collapse = ", "), "; it is '", f$op, "'."))
  n = length(values_of(f$value))
  if (identical(f$op, "in") && n < 1L) return(paste0(where, "op 'in' needs at least one value."))
  if (!identical(f$op, "in") && n != 1L) return(paste0(where, "op '", f$op, "' needs exactly one value; use 'in' for several."))
  if (f$op %in% c(">", ">=", "<", "<=") && !storage_of(e) %in% c("number", "date", "datetime"))
    return(paste0(where, "op '", f$op, "' compares order, but '", f$column, "' is ", kind_text(e), "; use ==, != or in."))
  if (is.null(typed_value(e, f$value)))
    return(paste0(where, "'", f$column, "' is ", kind_text(e), ", and the value ",
                  paste0("'", values_of(f$value), "'", collapse = ", "), " cannot be one of its values",
                  switch(storage_of(e), number = " (it needs a number).", date = " (it needs a date, YYYY-MM-DD).",
                         datetime = " (it needs a date and time).", logical = " (it needs TRUE or FALSE).", ".")))
  NULL
}

# ---- the rules as tables: read by spec_check() and written out by spec_reference() ----------

# What a column field may hold, per family: "group", "name", "measure", "time"; a field not listed is
#   not used by that family. facet is checked on its own (a group, every family but slope).
SPEC_FAMILY_ROLES <- list(
  bar = list(x = c("group", "name"), y = "measure", color = "group"),
  dot = list(x = c("group", "name"), y = "measure", color = "group"),
  line = list(x = "time", y = "measure", color = c("group", "name")),
  slope = list(x = c("time", "group"), y = "measure", color = c("group", "name")),
  scatter = list(x = "measure", y = "measure", color = "group"),
  bubble = list(x = "measure", y = "measure", color = "group", size = "measure"),
  histogram = list(x = "measure"),
  box = list(x = "group", y = "measure"),
  heatmap = list(x = c("group", "time"), y = "group", color = "measure"))

# The column fields each family must have.
SPEC_REQUIRED <- list(bar = "x", dot = "x", line = c("x", "y"), slope = c("x", "y", "color"), scatter = c("x", "y"),
                      bubble = c("x", "y", "size"), histogram = "x", box = c("x", "y"), heatmap = c("x", "y"))

# The functions each family allows. `on` names the field whose presence decides: `without` when it
#   is absent, `with` when it is given; a family with no `on` allows `with` always.
SPEC_FAMILY_FNS <- list(
  bar = list(on = "y", without = c("count", "share"), with = c("sum", "mean", "median", "none")),
  dot = list(on = "y", without = c("count", "share"), with = c("sum", "mean", "median", "none")),
  line = list(with = c("sum", "mean", "median", "none")),
  slope = list(with = c("sum", "mean", "median", "none")),
  scatter = list(with = "none"), bubble = list(with = "none"), histogram = list(with = "none"), box = list(with = "none"),
  heatmap = list(on = "color", without = "count", with = c("sum", "mean", "median")))

# The families a field is for, when it is not for every family.
SPEC_FIELD_FAMILIES <- list(
  facet = setdiff(SPEC_FAMILIES, "slope"),
  top_n = c("bar", "dot", "line", "slope"),
  sort = c("bar", "dot", "box"),
  fit = c("scatter", "bubble"),
  rug = "scatter",
  bins = "histogram",
  midpoint = "heatmap",
  log_x = c("scatter", "bubble", "histogram"),
  log_y = c("bar", "dot", "line", "scatter", "bubble", "box"),
  highlight = c("bar", "dot", "line", "slope", "scatter", "bubble"))

# The kinds of column, in words.
SPEC_KIND_TEXT <- c(group = paste0("a group (category, ordered, flag, or whole numbers with at most ", CODEBOOK_MAX_LEVELS, " values)"),
                    name = "a name (id or text) with top_n", measure = "a measure (number or integer)",
                    time = "a time (a date, or role time)")

family_roles <- function(family) SPEC_FAMILY_ROLES[[family]]
field_for <- function(field, family) is.null(SPEC_FIELD_FAMILIES[[field]]) || family %in% SPEC_FIELD_FAMILIES[[field]]
fns_for <- function(s) {
  t = SPEC_FAMILY_FNS[[s$family]]
  if (!is.null(t$on) && is.null(s[[t$on]])) t$without else t$with
}
or_list <- function(x) if (length(x) == 1L) x else paste(paste(utils::head(x, -1L), collapse = ", "), "or", utils::tail(x, 1L))

kind_ok <- function(e, kinds)
  ("group" %in% kinds && is_group_like(e)) || ("name" %in% kinds && is_name_like(e)) ||
    ("measure" %in% kinds && is_measure(e)) || ("time" %in% kinds && is_time(e))

kinds_text <- function(kinds) paste(SPEC_KIND_TEXT[kinds], collapse = " or ")

# The reasons a spec cannot be drawn, as sentences naming the field and the column; none when it can.
#   Reads only the codebook. Every rule that does not need the data is here.
spec_check <- function(spec, cb, palette = chart_palette_default()) {
  max_colours = chart_palette_max(palette$qualitative)
  if (!is.list(spec) || is.null(names(spec)) || any(!nzchar(names(spec))))
    return("The spec must be a set of named fields.")
  unknown = setdiff(names(spec), SPEC_FIELDS)
  out = if (length(unknown)) paste0("The spec has a field '", unknown, "', which chaRt does not know.")
  if (!is_text1(spec$family) || !spec$family %in% SPEC_FAMILIES)
    return(c(out, paste0("family must be one of ", paste(SPEC_FAMILIES, collapse = ", "), "; it is ",
                         if (is_text1(spec$family)) paste0("'", spec$family, "'") else "missing", ".")))
  s = spec_defaults(spec)
  fam = s$family
  roles = family_roles(fam)

  # Columns: present, known, not ignored, of a kind the family allows.
  cols = purrr::compact(purrr::map(SPEC_COLUMN_FIELDS, function(f) {
    v = s[[f]]
    if (is.null(v)) return(NULL)
    if (!is_text1(v)) return(paste0(f, ": a column name is needed."))
    e = cb_entry(cb, v)
    if (is.null(e)) return(paste0(f, ": there is no column '", v, "' in the codebook."))
    if (identical(e$role, "ignore")) return(paste0(f, ": the column '", v, "' has the role ignore, so it cannot be used."))
    if (identical(f, "facet")) {
      if (!field_for("facet", fam)) return(paste0("facet: a ", fam, " chart cannot be split into small multiples."))
      if (!is_group_like(e)) return(paste0("facet: '", v, "' is ", kind_text(e), "; small multiples need a group."))
      if (is.null(s$filter) && e$distinct > SPEC_FACET_MAX)
        return(paste0("facet: '", v, "' has ", e$distinct, " values, so ", e$distinct, " panels; at most ", SPEC_FACET_MAX, "."))
      return(NULL)
    }
    kinds = roles[[f]]
    if (is.null(kinds)) return(paste0(f, ": a ", fam, " chart does not use ", f, " (it was given '", v, "')."))
    if (!kind_ok(e, kinds)) return(paste0(f, ": '", v, "' is ", kind_text(e), "; the ", f, " of a ", fam, " must be ", kinds_text(kinds), "."))
    if (is_name_like(e) && !is_group_like(e) && is.null(s$top_n) && is.null(s$filter))
      return(paste0(f, ": '", v, "' is ", kind_text(e), " with ", e$distinct, " values; use top_n (at most ", SPEC_TOP_MAX,
                    ") or a filter that leaves at most ", SPEC_TOP_MAX, "."))
    if (identical(f, "color") && fam %in% c("bar", "dot") && is.null(s$filter) && e$distinct > SPEC_BAR_GROUPS)
      return(paste0("color: '", v, "' has ", e$distinct, " values; a ", fam, " chart takes at most ", SPEC_BAR_GROUPS, " colours."))
    if (identical(f, "color") && fam %in% c("scatter", "bubble") && is.null(s$filter) && e$distinct > max_colours)
      return(paste0("color: '", v, "' has ", e$distinct, " values; the palette colours at most ", max_colours,
                    " groups. Highlight a few values or use small multiples (facet)."))
    if (identical(f, "x") && identical(fam, "box") && is.null(s$filter) && e$distinct > SPEC_BOX_GROUPS)
      return(paste0("x: '", v, "' has ", e$distinct, " values; a box plot takes at most ", SPEC_BOX_GROUPS, " boxes."))
    NULL
  }))
  missing_cols = purrr::compact(purrr::map(SPEC_REQUIRED[[fam]], function(f)
    if (is.null(s[[f]])) paste0(f, ": a ", fam, " chart needs a ", f, " column.")))
  out = c(out, unlist(cols), unlist(missing_cols))
  if (identical(fam, "histogram") && !is.null(s$y)) out = c(out, "y: a histogram counts its x, so it takes no y.")

  # The function.
  fn = s$fn
  allowed = fns_for(s)
  on = SPEC_FAMILY_FNS[[fam]]$on
  case = if (is.null(on)) paste0("a ", fam, " chart") else paste0("a ", fam, " chart ", if (is.null(s[[on]])) "with no " else "with a ", on)
  fn_msg = if (!is.null(fn) && (!is_text1(fn) || !fn %in% SPEC_FNS))
    paste0("fn must be one of ", paste(SPEC_FNS, collapse = ", "), ".")
  else if (is.null(fn)) paste0("fn: ", case, " needs a function (", or_list(allowed), ").")
  else if (!fn %in% allowed) paste0("fn: ", case, " takes ", or_list(allowed), "; it is '", fn, "'.")
  out = c(out, fn_msg)

  # The filter.
  if (!is.null(s$filter)) {
    fl = if (is.list(s$filter) && !is.null(names(s$filter))) list(s$filter) else s$filter
    out = c(out, if (!is.list(fl) || !length(fl)) "filter: a list of conditions is needed."
                 else unlist(purrr::imap(fl, function(f, i) check_filter(f, cb, i))))
  }

  # Everything else, field by field.
  out = c(out,
    unlist(purrr::map(intersect(SPEC_TEXT_FIELDS, names(s)), function(f) if (!is_text1(s[[f]])) paste0(f, ": text is needed."))),
    unlist(purrr::map(intersect(SPEC_FLAG_FIELDS, names(s)), function(f) if (!is_flag1(s[[f]])) paste0(f, ": true or false is needed."))),
    if (!is.null(s$top_n)) {
      if (!field_for("top_n", fam)) paste0("top_n: a ", fam, " chart does not use top_n.")
      else if (!is_whole1(s$top_n) || s$top_n < 1 || s$top_n > SPEC_TOP_MAX)
        paste0("top_n must be a whole number from 1 to ", SPEC_TOP_MAX, "; it is ", paste(values_of(s$top_n), collapse = ", "), ".")
    },
    if (!is.null(s$sort)) {
      if (!field_for("sort", fam)) paste0("sort: a ", fam, " chart is not sorted; only ", or_list(SPEC_FIELD_FAMILIES$sort), " charts are.")
      else if (!is_text1(s$sort) || !s$sort %in% SPEC_SORTS) paste0("sort must be one of ", paste(SPEC_SORTS, collapse = ", "), ".")
    },
    if (!is_text1(s$fit) || !s$fit %in% SPEC_FITS) paste0("fit must be one of ", paste(SPEC_FITS, collapse = ", "), ".")
    else if (!identical(s$fit, "none") && !field_for("fit", fam)) paste0("fit: only a ", or_list(SPEC_FIELD_FAMILIES$fit), " chart takes a fitted line."),
    if (isTRUE(s$rug) && !field_for("rug", fam)) paste0("rug: only a ", or_list(SPEC_FIELD_FAMILIES$rug), " chart takes a rug."),
    if (!is.null(s$bins)) {
      if (!field_for("bins", fam)) paste0("bins: only a ", or_list(SPEC_FIELD_FAMILIES$bins), " takes bins.")
      else if (!is_whole1(s$bins) || s$bins < SPEC_BINS[1] || s$bins > SPEC_BINS[2])
        paste0("bins must be a whole number from ", SPEC_BINS[1], " to ", SPEC_BINS[2], ".")
    },
    if (isTRUE(s$free_y) && is.null(s$facet)) "free_y: only small multiples (facet) can free the y scale.",
    if (!is.null(s$midpoint)) {
      if (!field_for("midpoint", fam)) paste0("midpoint: only a ", or_list(SPEC_FIELD_FAMILIES$midpoint), " takes a midpoint (a ", fam, " chart was given one).")
      else if (!is.numeric(s$midpoint) || length(s$midpoint) != 1L || !is.finite(s$midpoint)) "midpoint must be one number."
    },
    if (isTRUE(s$log_x) && !(is_text1(s$x) && !is.null(cb_entry(cb, s$x)) && is_measure(cb_entry(cb, s$x)) &&
                             field_for("log_x", fam)))
      paste0("log_x: only a measure on the x axis of a ", or_list(SPEC_FIELD_FAMILIES$log_x), " can take a log scale."),
    if (isTRUE(s$log_y) && !field_for("log_y", fam))
      paste0("log_y: a ", fam, " chart has no y scale to log."),
    check_highlight(s, cb))
  unique(out)
}

check_highlight <- function(s, cb) {
  h = s$highlight
  if (is.null(h)) return(NULL)
  if (!is.list(h) || !is_text1(h$column) || !length(values_of(h$values)) || length(setdiff(names(h), c("column", "values"))))
    return("highlight needs a column and a list of values, and nothing else.")
  fam = s$family
  if (fam %in% c("bar", "dot") && !identical(h$column, s$x))
    return(paste0("highlight: in a ", fam, " chart the highlighted values are values of x ('", s$x %||% "", "'), not of '", h$column, "'."))
  if (fam %in% c("line", "slope") && !identical(h$column, s$color))
    return(paste0("highlight: in a ", fam, " chart the highlighted values are values of color ('", s$color %||% "", "'), not of '", h$column, "'."))
  if (!field_for("highlight", fam))
    return(paste0("highlight: a ", fam, " chart does not take a highlight."))
  e = cb_entry(cb, h$column)
  if (is.null(e)) return(paste0("highlight: there is no column '", h$column, "' in the codebook."))
  if (identical(e$role, "ignore")) return(paste0("highlight: the column '", h$column, "' has the role ignore, so it cannot be used."))
  if (fam %in% c("scatter", "bubble")) {
    if (!is_group_like(e) && !is_name_like(e)) return(paste0("highlight: '", h$column, "' is ", kind_text(e), "; highlight a group or a name."))
    if (!is.null(s$color)) return("highlight: a scatter or bubble chart takes a highlight or a color, not both.")
  }
  if (is.null(typed_value(e, h$values)))
    return(paste0("highlight: the values cannot be values of '", h$column, "', ", kind_text(e), "."))
  NULL
}


# ---- the reference a model is given ------------------------------------------------------------

# What a spec may contain, as plain text for the suggest call's system prompt: every field of
#   SPEC_FIELDS with its allowed values, the kinds of column, and for each family the fields it
#   takes. Written from the tables and constants spec_check() reads, so the two cannot disagree; a
#   field with no line here stops it, so a new field cannot be left out. The same text every time.
spec_reference <- function() {
  quals = purrr::keep(CHART_PALETTES, function(e) identical(e$kind, "qualitative"))
  colour_max = range(purrr::map_int(quals, "max"))
  for_text = function(f) if (!is.null(SPEC_FIELD_FAMILIES[[f]])) paste0(" (", paste(SPEC_FIELD_FAMILIES[[f]], collapse = ", "), " only)") else ""
  field_line = function(f) {
    what = if (f %in% SPEC_COLUMN_FIELDS) "a column name exactly as in DATA; its kind per family below"
      else if (f %in% SPEC_FLAG_FIELDS) "true or false"
      else if (identical(f, "rule")) "text: the id of one reflex"
      else if (f %in% SPEC_TEXT_FIELDS) "text"
      else switch(f,
        family = paste0("one of ", paste(SPEC_FAMILIES, collapse = ", ")),
        fn = paste0("one of ", paste(SPEC_FNS, collapse = ", "), "; which ones, per family below"),
        filter = paste0("a list of conditions, all of which a row must meet, each {\"column\": a column name, \"op\": one of ",
                        paste(SPEC_OPS, collapse = " "), ", \"value\": one value, or a list of values for in}; ",
                        "> >= < <= only on numbers and dates (dates as YYYY-MM-DD)"),
        top_n = paste0("a whole number from 1 to ", SPEC_TOP_MAX, ": the groups with the largest values"),
        sort = paste0("one of ", paste(SPEC_SORTS, collapse = ", ")),
        fit = paste0("one of ", paste(SPEC_FITS, collapse = ", ")),
        bins = paste0("a whole number from ", SPEC_BINS[1], " to ", SPEC_BINS[2]),
        highlight = paste0("{\"column\": a column name, \"values\": a list of values}; in a bar or dot the column is x, ",
                           "in a line or slope it is color, in a scatter or bubble a group or name column and no color"),
        midpoint = "one number, the centre of a diverging fill",
        stop("spec_reference() has no line for the field '", f, "'.", call. = FALSE))
    extra = switch(f, log_x = "; a measure on x", free_y = "; only with facet", "")
    paste0("- ", f, ": ", what, for_text(f), extra)
  }
  family_line = function(fam) {
    roles = family_roles(fam)
    cols = purrr::imap_chr(roles, function(kinds, f)
      paste0(f, " ", paste(kinds, collapse = " or "), if (f %in% SPEC_REQUIRED[[fam]]) " (required)" else ""))
    t = SPEC_FAMILY_FNS[[fam]]
    fns = if (is.null(t$on)) paste("fn", paste(t$with, collapse = " or "))
          else paste0("fn ", paste(t$without, collapse = " or "), " with no ", t$on, ", ", paste(t$with, collapse = " or "), " with a ", t$on)
    paste0("- ", fam, ": ", paste(c(cols, if (field_for("facet", fam)) "facet group", fns), collapse = "; "))
  }
  paste(c(
    "A spec is one JSON object. These are its only fields; a spec with any other field is refused.",
    purrr::map_chr(SPEC_FIELDS, field_line),
    "Kinds of column (the type in DATA decides):",
    paste0("- ", names(SPEC_KIND_TEXT), ": ", gsub("^an? [a-z]+ [(]|[)]", "", SPEC_KIND_TEXT)),
    "A column whose role is ignore cannot be used in any field.",
    "Families, with the column fields each takes (a field not named is not used):",
    purrr::map_chr(SPEC_FAMILIES, family_line),
    "Limits:",
    paste0("- a name column (id or text) on an axis or in color needs top_n, or a filter leaving at most ", SPEC_TOP_MAX, " values"),
    paste0("- color in a bar or dot: at most ", SPEC_BAR_GROUPS, " values; in a scatter or bubble: at most as many as the palette ",
           "holds (", colour_max[1], " to ", colour_max[2], ")"),
    paste0("- facet: at most ", SPEC_FACET_MAX, " panels; box: at most ", SPEC_BOX_GROUPS, " boxes"),
    "- when a filter is given, these counts are of the values left after it"),
    collapse = "\n")
}


# ---- the table -----------------------------------------------------------------------------------

sym <- function(name) as.name(name)
by_arg <- function(cols) if (length(cols) == 1L) sym(cols) else as.call(c(sym("c"), purrr::map(cols, sym)))

# A value as written in a call: a number, a quoted string, TRUE/FALSE, or as.Date("...").
value_call <- function(e, v) {
  t = typed_value(e, v)
  switch(storage_of(e), date = call("as.Date", t), datetime = call("as.POSIXct", t, tz = "UTC"), t)
}

filter_call <- function(s, cb) {
  if (is.null(s$filter)) return(NULL)
  fl = if (!is.null(names(s$filter))) list(s$filter) else s$filter
  conds = purrr::map(fl, function(f) {
    v = value_call(cb_entry(cb, f$column), f$value)
    if (identical(f$op, "in")) call("%in%", sym(f$column), v) else call(f$op, sym(f$column), v)
  })
  as.call(c(sym("filter"), conds))
}

# The value column after the aggregation: n, share, or the measure's own name.
value_name <- function(s) switch(s$fn, count = "n", share = "share",
  none = if (identical(s$family, "heatmap")) s$color else s$y,
  if (identical(s$family, "heatmap")) s$color else s$y)

group_columns <- function(s) unique(c(s$x, if (identical(s$family, "heatmap")) s$y else s$color, s$facet))

aggregate_calls <- function(s) {
  fam = s$family
  if (fam %in% c("scatter", "bubble", "histogram", "box") || (identical(s$fn, "none") && !identical(fam, "heatmap")))
    return(list(as.call(c(sym("select"), purrr::map(spec_columns(s), sym)))))
  g = by_arg(group_columns(s))
  switch(s$fn,
    count = list(as.call(list(sym("summarise"), n = quote(n()), .by = g))),
    share = list(as.call(list(sym("summarise"), n = quote(n()), .by = g)),
                 if (is.null(s$facet)) quote(mutate(share = n / sum(n)))
                 else as.call(list(sym("mutate"), share = quote(n / sum(n)), .by = sym(s$facet)))),
    { v = value_name(s)
      agg = as.call(list(sym(s$fn), sym(v)))
      list(as.call(c(list(sym("summarise")), stats::setNames(list(agg), v), list(.by = g)))) })
}

# ---- ranking: top_n and the order of bars, dots and boxes ---------------------------------------

# The helper column that ranks rows when an x (or a line) has several rows: its total (a box: its median).
rank_helper <- function(s) if (identical(s$family, "box")) ".median" else ".total"

mutate_call <- function(name, value, by = NULL)
  as.call(c(list(sym("mutate")), stats::setNames(list(value), name), if (!is.null(by)) list(.by = sym(by))))

# top_n and the sort as dplyr steps. When each x has one row (a bar or dot with no colour or facet),
#   top_n is arrange(desc(value), x) |> slice_head(n = n) and the sort an arrange(); otherwise a
#   helper column holds each x's total (a box: its median) and consecutive_id() keeps the first n.
#   Ties are broken alphabetically. The order is then fixed with factor(). For a line or slope,
#   top_n keeps the lines with the largest totals.
# How many groups top_n keeps: top_n, or more when values tie at the cut and all of them fit
#   (.top_n, set from the table).
top_of <- function(s) s$.top_n %||% s$top_n

rank_calls <- function(s, cb) {
  fam = s$family
  if (fam %in% c("line", "slope")) {
    if (is.null(s$top_n)) return(NULL)
    col = sym(s$color)
    return(list(mutate_call(".total", call("sum", sym(value_name(s))), s$color),
                call("arrange", call("desc", sym(".total")), col),
                call("filter", call("<=", call("consecutive_id", col), as.numeric(top_of(s)))),
                call("select", call("-", sym(".total")))))
  }
  if (!fam %in% c("bar", "dot", "box")) return(NULL)
  srt = effective_sort(s, cb)
  e = cb_entry(cb, s$x)
  x = sym(s$x)
  ordered = identical(srt, "level_order") && identical(e$type, "ordered") && length(e$order) > 0L
  single = fam %in% c("bar", "dot") && is.null(s$color) && is.null(s$facet)
  key = sym(if (single) value_name(s) else rank_helper(s))
  helper = if (!single)
    list(mutate_call(rank_helper(s), call(if (identical(fam, "box")) "median" else "sum", sym(if (identical(fam, "box")) s$y else value_name(s))), s$x))
  top = if (!is.null(s$top_n))
    list(call("arrange", call("desc", key), x),
         if (single) call("slice_head", n = as.numeric(top_of(s))) else call("filter", call("<=", call("consecutive_id", x), as.numeric(top_of(s)))))
  ord = if (ordered) list(mutate_call(s$x, call("factor", x, levels = e$order)), call("arrange", x))
        else switch(srt,
          value_desc = if (is.null(top)) list(call("arrange", call("desc", key), x)),
          value_asc = list(call("arrange", key, x)),
          list(call("arrange", x)))
  fac = if (!ordered) list(mutate_call(s$x, call("factor", x, levels = if (single) x else call("unique", x))))
  drop = if (!single) list(call("select", call("-", sym(rank_helper(s)))))
  c(helper, top, ord, fac, drop)
}

# A column as a factor in its level order: the analyst's order for an ordered column, otherwise
#   factor()'s own (sorted: alphabetical, or numeric for numbers).
level_order_call <- function(e, col) {
  if (identical(e$type, "ordered") && length(e$order)) return(call("factor", sym(col), levels = e$order))
  call("factor", sym(col))
}

# Columns drawn as discrete groups that would otherwise be read as continuous or in the wrong order:
#   made factors, in order. A colour is always discrete; a slope's x and a heatmap's rows too (in
#   level order, alphabetical for an unordered category); a facet only needs its order.
needs_factor <- function(e) identical(e$type, "ordered") || identical(storage_of(e), "number")

factor_call <- function(s, cb) {
  fam = s$family
  want = c(if (!is.null(s$color) && !identical(fam, "heatmap")) s$color,
           if (!is.null(s$facet) && identical(cb_entry(cb, s$facet)$type, "ordered")) s$facet,
           if (identical(fam, "heatmap") && is_group_like(cb_entry(cb, s$x))) s$x)
  need = unique(c(purrr::keep(want, function(col) needs_factor(cb_entry(cb, col))),
                  if (identical(fam, "slope")) s$x, if (identical(fam, "heatmap")) s$y))
  if (!length(need)) return(NULL)
  as.call(c(list(sym("mutate")), stats::setNames(purrr::map(need, function(col) level_order_call(cb_entry(cb, col), col)), need)))
}

highlight_call <- function(s, cb) {
  h = s$highlight
  if (is.null(h)) return(NULL)
  mutate_call("highlighted", call("%in%", sym(h$column), value_call(cb_entry(cb, h$column), h$values)))
}

# The table's steps, as calls without their data argument, in three parts: `base` (the filter and
#   the rows left out for missing values), `agg` (the aggregation) and `post` (top_n, the order,
#   factors, the highlight). The data checks run after `base`; ties are counted after `agg`.
table_steps <- function(s, cb)
  list(base = purrr::compact(list(filter_call(s, cb), as.call(c(sym("drop_na"), purrr::map(spec_columns(s), sym))))),
       agg = aggregate_calls(s),
       post = purrr::compact(c(rank_calls(s, cb), list(factor_call(s, cb), highlight_call(s, cb)))))

# The environment the calls are evaluated in: the exports of dplyr, tidyr, ggplot2 and scales,
#   over the global environment (where chart_theme() and the rest of R/ live).
SPEC_PACKAGES <- c("scales", "ggplot2", "tidyr", "dplyr")
.spec_cache <- new.env(parent = emptyenv())

spec_env <- function(...) {
  if (is.null(.spec_cache$fns))
    .spec_cache$fns = purrr::reduce(SPEC_PACKAGES, function(acc, p) {
      ex = getNamespaceExports(p)
      utils::modifyList(acc, mget(ex, envir = asNamespace(p), inherits = TRUE))
    }, .init = list())
  e = list2env(.spec_cache$fns, envir = new.env(parent = globalenv()))
  list2env(list(...), envir = e)
}

# The steps applied in turn to a data frame: f(data, ...) for each step f(...).
run_steps <- function(data, steps, ...) {
  if (!length(steps)) return(data)
  pipeline = purrr::reduce(steps, function(acc, st) as.call(c(list(st[[1]]), list(acc), as.list(st)[-1])), .init = sym("chart_data"))
  eval(pipeline, spec_env(chart_data = data, ...))
}

# The rules that need the data, on the rows left after the filter and the missing values.
data_checks <- function(s, base, max_colours = chart_palette_max()) {
  fam = s$family
  nd = function(col) length(unique(base[[col]]))
  if (!nrow(base)) spec_fail("No rows are left once the filter is applied and rows with missing values are left out.")
  if (!is.null(s$facet) && nd(s$facet) > SPEC_FACET_MAX)
    spec_fail(paste0("facet: '", s$facet, "' has ", nd(s$facet), " values after the filter, so as many panels; at most ", SPEC_FACET_MAX, "."))
  if (fam %in% c("bar", "dot") && !is.null(s$color) && nd(s$color) > SPEC_BAR_GROUPS)
    spec_fail(paste0("color: '", s$color, "' has ", nd(s$color), " values after the filter; a ", fam, " chart takes at most ", SPEC_BAR_GROUPS, " colours."))
  if (fam %in% c("scatter", "bubble") && !is.null(s$color) && nd(s$color) > max_colours)
    spec_fail(paste0("color: '", s$color, "' has ", nd(s$color), " values after the filter; the palette colours at most ",
                     max_colours, " groups."))
  if (identical(fam, "box") && nd(s$x) > SPEC_BOX_GROUPS)
    spec_fail(paste0("x: '", s$x, "' has ", nd(s$x), " values after the filter; a box plot takes at most ", SPEC_BOX_GROUPS, " boxes."))
  ranked = if (fam %in% c("bar", "dot", "line", "slope")) ranked_column(s)
  if (!is.null(ranked) && is.null(s$top_n) && nd(ranked) > SPEC_TOP_MAX)
    spec_fail(paste0(if (fam %in% c("bar", "dot")) "x" else "color", ": '", ranked, "' has ", nd(ranked),
                     " values after the filter; use top_n (at most ", SPEC_TOP_MAX, ") or a filter that leaves at most ", SPEC_TOP_MAX, "."))
  if (identical(fam, "slope") && nd(s$x) != 2L)
    spec_fail(paste0("x: a slope chart needs exactly two values of '", s$x, "' after the filter; it has ", nd(s$x), "."))
  if (identical(s$fn, "none") && fam %in% c("bar", "dot", "line", "slope")) {
    keys = unique(c(s$x, s$color, s$facet))
    if (anyDuplicated(base[keys]))
      spec_fail(paste0("fn: with fn none each combination of ", paste0("'", keys, "'", collapse = ", "),
                       " must have one row, but some have more; choose a function such as sum, mean or median."))
  }
  h = s$highlight
  if (!is.null(h)) {
    absent = setdiff(as.character(values_of(h$values)), as.character(base[[h$column]]))
    if (length(absent))
      spec_fail(paste0("highlight: ", paste0("'", absent, "'", collapse = ", "), if (length(absent) == 1L) " is not a value" else " are not values",
                       " of '", h$column, "' after the filter."))
  }
  invisible(TRUE)
}

# When values tie across the top_n cut and showing all of them would give at most SPEC_TOP_MAX
#   groups: how many that is. NULL otherwise.
tie_fit <- function(s, agg) {
  if (is.null(s$top_n) || !s$family %in% c("bar", "dot", "line", "slope")) return(NULL)
  totals = tapply(agg[[value_name(s)]], as.character(agg[[ranked_column(s)]]), sum)
  if (length(totals) <= s$top_n) return(NULL)
  last = sort(totals, decreasing = TRUE)[s$top_n]
  m = sum(totals >= last - 1e-9 * max(1, abs(last)))
  if (m > s$top_n && m <= SPEC_TOP_MAX) m else NULL
}

# Values that tie across the top_n cut: how many share the last value kept, and how many of them
#   are shown. NULL when there is no top_n or no tie across the cut.
cut_ties <- function(s, agg, out) {
  if (is.null(s$top_n) || !s$family %in% c("bar", "dot", "line", "slope")) return(NULL)
  col = ranked_column(s)
  totals = tapply(agg[[value_name(s)]], as.character(agg[[col]]), sum)
  if (length(totals) <= s$top_n) return(NULL)
  shown = unique(as.character(out[[col]]))
  last = min(totals[shown])
  same = function(v) abs(v - last) <= 1e-9 * max(1, abs(last))
  tied = sum(same(totals))
  kept = sum(same(totals[shown]))
  if (tied > kept) c(tied = tied, shown = kept) else NULL
}

# The table that is drawn: after the filter, the rows left out for missing values, the
#   aggregation, top_n and the sort. Attributes rows_used, rows_dropped, groups_total, ties, and
#   top (asked and shown) when ties at the cut made top_n show more.
spec_table <- function(spec, data, cb, palette = chart_palette_default()) {
  s = spec_defaults(spec_public(spec))
  why = spec_check(s, cb, palette)
  if (length(why)) spec_fail(paste(why, collapse = " "))
  s = c(s, spec[intersect(names(spec), SPEC_LINT_FIELDS)])
  st = table_steps(s, cb)
  filtered = if (is.null(s$filter)) data else run_steps(data, st$base[1])
  base = run_steps(data, st$base)
  data_checks(s, base, chart_palette_max(palette$qualitative))
  agg = run_steps(base, st$agg)
  if (is.null(s$.top_n)) s$.top_n = tie_fit(s, agg)
  if (!is.null(s$.top_n)) st$post = table_steps(s, cb)$post
  out = run_steps(agg, st$post)
  ranked = if (s$family %in% c("bar", "dot", "line", "slope")) ranked_column(s)
  structure(out, rows_used = nrow(base), rows_dropped = nrow(filtered) - nrow(base),
            groups_total = if (!is.null(ranked)) length(unique(base[[ranked]])) else NA_integer_,
            ties = cut_ties(s, agg, out),
            top = if (!is.null(s$.top_n)) c(asked = s$top_n, shown = s$.top_n))
}


# ---- the lint ------------------------------------------------------------------------------------

# The figures the plot needs that depend on the table: the sort a bar, dot or box falls back on, a
#   histogram's bins when none were given, and "Top n of N" as the subtitle.
spec_settle <- function(s, cb, table) {
  if (s$family %in% c("bar", "dot", "box")) s$sort = effective_sort(s, cb)
  if (identical(s$family, "histogram") && is.null(s$bins)) {
    x = table[[s$x]]
    x = if (isTRUE(s$log_x)) log10(x[x > 0]) else x
    s$bins = as.integer(min(max(grDevices::nclass.FD(x), SPEC_BINS[1]), SPEC_BINS[2]))
  }
  top = attr(table, "top")
  if (!is.null(top)) s$.top_n = unname(top[["shown"]])
  if (!is.null(s$top_n) && is.null(s$subtitle))
    s$subtitle = paste0("Top ", top_of(s), " of ", attr(table, "groups_total"))
  s
}

# Where a fitted curve is drawn. It is fitted on every row of its group (a colour, a panel, or both)
#   and drawn only between SPEC_FIT_TRIM percentiles of x within each group of SPEC_FIT_TRIM_N rows
#   or more. Returns list(groups = list(list(keys, range)), rest), keys naming the group's values
#   (NULL with no groups) and rest TRUE when smaller groups are drawn untrimmed; NULL when no group
#   is trimmed.
fit_ranges <- function(s, table) {
  if (!s$family %in% c("scatter", "bubble") || identical(s$fit, "none")) return(NULL)
  q = function(x) signif(stats::quantile(x, SPEC_FIT_TRIM, names = FALSE), 4)
  keys = unique(c(if (!isTRUE(s$.binned) && is.null(s$highlight)) s$color, s$facet))
  if (!length(keys))
    return(if (nrow(table) >= SPEC_FIT_TRIM_N) list(groups = list(list(keys = NULL, range = q(table[[s$x]]))), rest = FALSE))
  parts = split(as.data.frame(table), lapply(keys, function(k) as.character(table[[k]])), drop = TRUE)
  big = purrr::keep(unname(parts), function(d) nrow(d) >= SPEC_FIT_TRIM_N)
  if (!length(big)) return(NULL)
  list(groups = purrr::map(big, function(d) list(keys = purrr::set_names(purrr::map(keys, function(k) as.character(d[[k]][1])), keys),
                                                 range = q(d[[s$x]]))),
       rest = length(big) < length(parts))
}

# How many marks a chart draws: bars, points or boxes are rows of the table; a histogram draws its
#   bins in each panel; a binned scatter its grid.
mark_count <- function(s, table) {
  panels = if (!is.null(s$facet)) length(unique(table[[s$facet]])) else 1L
  if (identical(s$family, "histogram")) return(as.integer(s$bins %||% SPEC_BINS[2]) * panels)
  if (isTRUE(s$.binned)) return(SPEC_BIN_2D^2 * panels)
  nrow(table)
}

# Whether a line or slope chart's end labels fit: the end values in order, per panel, and whether
#   any two neighbours are closer than SPEC_LABEL_GAP of the y range. With a highlight, only the
#   highlighted lines are labelled. `order` is the lines from the highest end value down.
label_plan <- function(s, table) {
  v = value_name(s)
  rows = if (!is.null(s$highlight)) table[table$highlighted, , drop = FALSE] else table
  panel = if (!is.null(s$facet) && !identical(s$facet, s$color)) s$facet
  ends = if (identical(s$family, "slope")) rows[as.character(rows[[s$x]]) == levels(table[[s$x]])[2], , drop = FALSE]
         else dplyr::filter(rows, .data[[s$x]] == max(.data[[s$x]]), .by = dplyr::all_of(c(s$color, panel)))
  gap = SPEC_LABEL_GAP * diff(range(table[[v]]))
  groups = if (is.null(panel)) list(ends[[v]]) else split(ends[[v]], ends[[panel]])
  close = any(purrr::map_lgl(groups, function(vals) length(vals) > 1L && any(diff(sort(vals)) < gap)))
  list(fits = !close, order = unique(as.character(ends[[s$color]][order(-ends[[v]])])))
}

# The rules R enforces with no model call (DESIGN.md section 8). Fixes change the spec; notes are
#   sentences for the analyst. Returns list(spec, notes).
spec_lint <- function(spec, cb, table, max_colours = chart_palette_max()) {
  s = spec_settle(spec, cb, table)
  fam = s$family
  v = value_name(s)
  nd = function(col) length(unique(table[[col]]))
  notes = character(0)
  # A bar's value axis starts at zero (the bar layers always include zero), so no log scale.
  if (identical(fam, "bar") && isTRUE(s$log_y)) {
    s$log_y = FALSE
    notes = c(notes, "A bar's length shows its value, so its axis starts at zero; the log scale was removed.")
  }
  # Room below zero only when a bar drawn is below zero.
  if (identical(fam, "bar") && any(table[[v]] < 0)) s$.negative = TRUE
  # Ties across the top_n cut, and nothing to compare.
  tie = attr(table, "ties")
  top = attr(table, "top")
  if (!is.null(top))
    notes = c(notes, paste0(top[["asked"]], " was asked for; ", top[["shown"]], " are shown, because values tie at the cut."))
  if (!is.null(tie))
    notes = c(notes, paste0(tie[["tied"]], " values tie at the cut; ",
                            if (tie[["shown"]] == 1L) "the 1 shown is the first alphabetically."
                            else paste0("the ", tie[["shown"]], " shown are the first alphabetically.")))
  if (fam %in% c("bar", "dot") && nrow(table) > 1L && length(unique(table[[v]])) == 1L)
    notes = c(notes, "Every value shown is the same.")
  # Many bars, dots or boxes, or long labels: drawn sideways.
  if (fam %in% c("bar", "dot", "box")) {
    labels = as.character(unique(table[[s$x]]))
    if (length(labels) > SPEC_FLIP_BARS || any(nchar(labels) > SPEC_FLIP_CHARS)) s$.flip = TRUE
  }
  coloured = !is.null(s$color) && !identical(fam, "heatmap") && !identical(s$color, s$facet) && is.null(s$highlight)
  # A slope names its lines at their ends, so it is noted only past the palette's own limit.
  if (coloured && nd(s$color) > (if (identical(fam, "slope")) max_colours else SPEC_COLOURS))
    notes = c(notes, paste0(nd(s$color), " colours are hard to tell apart; highlight the few that matter, or use small multiples (facet)."))
  if (identical(fam, "line") && !is.null(s$color) && nd(s$color) > SPEC_LINES && is.null(s$highlight) && is.null(s$facet))
    notes = c(notes, paste0(nd(s$color), " lines overlap; small multiples (facet) or a highlight of the few that matter would read more easily."))
  # End labels on a line or slope chart only when no two would touch; otherwise a legend, in the
  #   order of the end values.
  if (fam %in% c("line", "slope") && !is.null(s$color) && !identical(s$color, s$facet)) {
    lab = label_plan(s, table)
    s$.labels = lab$fits
    if (!lab$fits) {
      many = is.null(s$highlight) && nd(s$color) > max_colours
      if (many) notes = c(notes, paste0("The ", nd(s$color), " lines end too close together to be labelled and are too many to colour; highlight a few."))
      else s$.legend_order = lab$order
    }
  }
  # A heatmap with few cells prints each value in its cell.
  if (identical(fam, "heatmap") && nrow(table) <= SPEC_HEAT_LABELS) s$.cell_labels = TRUE
  # Small multiples share their scales unless free_y asks otherwise: facet_wrap()'s scales are
  #   fixed by default, so there is nothing to change.
  if (fam %in% c("scatter", "bubble")) {
    n = nrow(table)
    # Points on repeated positions: every row still its own point, moved slightly at random (with a
    #   fixed seed) and drawn see-through, so rows sharing a position can be seen.
    keys = table[c(s$x, s$y, s$color)]
    shared = duplicated(keys) | duplicated(keys, fromLast = TRUE)
    jitter = identical(fam, "scatter") && is.null(s$highlight) && n <= SPEC_BIN_N && n > 0L && mean(shared) > SPEC_OVERLAP_SHARE
    if (n > SPEC_BIN_N) {
      s$.binned = TRUE
      notes = c(notes, paste0(format_num(n), " points would hide one another, so the chart shows how many fall in each cell of a grid."))
    } else if (jitter) {
      s$.jitter = TRUE
      s$.alpha = SPEC_ALPHA
      notes = c(notes, "Points are moved slightly so that rows sharing a position can be seen.")
    } else if (n > SPEC_ALPHA_N) {
      s$.alpha = SPEC_ALPHA
      notes = c(notes, paste0(format_num(n), " points are drawn see-through, so that where they pile up shows."))
    }
    if (identical(fam, "bubble") && n > SPEC_BUBBLE_N)
      notes = c(notes, "A bubble chart with this many points is hard to read; filter, or use a scatter.")
  }
  if (isTRUE(s$interactive) && mark_count(s, table) > SPEC_WIDGET_N) {
    s$interactive = FALSE
    notes = c(notes, paste0(format_num(mark_count(s, table)), " marks are too many for the interactive version; the chart is static."))
  }
  if (is.null(s$title)) notes = c(notes, "The chart has no title; a title that states the finding tells the reader what to look for.")
  dropped = attr(table, "rows_dropped") %||% 0L
  if (dropped > 0L)
    notes = c(notes, paste0(format_num(dropped), " of ", format_num(dropped + attr(table, "rows_used")), " rows left out: missing values."))
  s$.fit_range = fit_ranges(s, table)
  list(spec = s, notes = notes)
}


# ---- the plot --------------------------------------------------------------------------------------

# The colours a chart is drawn with, from the palettes chosen for the report (R/theme.R): qual(n)
#   for groups (at most max), seq for a continuous fill, div for a fill centred on a midpoint.
spec_palette <- function(palette = chart_palette_default())
  list(qual = function(n) chart_palette(n, palette$qualitative), max = chart_palette_max(palette$qualitative),
       seq = chart_sequential(palette$sequential), div = chart_diverging(palette$diverging))

# How many colours a column needs, from the codebook (and top_n), so the plot and its code can be
#   built without the data.
colour_count <- function(s, cb, col) {
  n = cb_entry(cb, col)$distinct
  if (!is.null(s$top_n) && identical(col, ranked_column(s))) min(n, top_of(s)) else n
}

value_label <- function(s, cb) {
  if (identical(s$family, "histogram")) return("Count")
  lab = cb_label(cb, if (identical(s$family, "heatmap")) s$color %||% s$y else s$y %||% s$x)
  switch(s$fn, count = "Count", share = "Share of rows", sum = paste("Total", lab), mean = paste("Mean", lab),
         median = paste("Median", lab), lab)
}

highlight_values <- function() c(`FALSE` = CHART_GREY, `TRUE` = CHART_HIGHLIGHT)

aes_call <- function(...) {
  a = purrr::compact(list(...))
  as.call(c(list(sym("aes")), purrr::map(a, function(v) if (is.character(v)) sym(v) else v)))
}

data_where <- function(cond) call("filter", sym("chart_table"), cond)

# A legend at the top with more entries than fit on one row: several rows. solid = TRUE draws the
#   keys of see-through points without their transparency, so the colours can be told apart.
legend_rows <- function(aesthetic, n, solid = FALSE) {
  rows = n > SPEC_LEGEND_PER_ROW
  if (!rows && !solid) return(NULL)
  args = c(if (solid) list(override.aes = call("list", alpha = 1)), if (rows) list(nrow = ceiling(n / SPEC_LEGEND_PER_ROW)))
  as.call(c(list(sym("guides")), stats::setNames(list(as.call(c(list(sym("guide_legend")), args))), aesthetic)))
}

# The tooltip of the plotly version: each plotted value named with its codebook label.
tooltip_call <- function(s, cb) {
  value = value_name(s)
  part = function(label, col, number) {
    shown = if (identical(col, "share")) call("paste0", call("round", call("*", 100, sym(col)), 1), "%")
            else if (number) call("format", call("round", sym(col), 2), big.mark = ",", trim = TRUE)
            else sym(col)
    list(paste0(label, ": "), shown)
  }
  is_num = function(col) !is.null(cb_entry(cb, col)) && identical(storage_of(cb_entry(cb, col)), "number") &&
    !needs_factor_here(s, col)
  cols = if (s$family %in% c("scatter", "bubble")) list(list(cb_label(cb, s$x), s$x, is_num(s$x)), list(cb_label(cb, s$y), s$y, is_num(s$y)))
         else if (identical(s$family, "heatmap")) list(list(cb_label(cb, s$x), s$x, FALSE), list(cb_label(cb, s$y), s$y, FALSE),
                                                       list(value_label(s, cb), value, TRUE))
         else list(list(cb_label(cb, s$x), s$x, is_num(s$x) && !s$family %in% c("bar", "dot", "slope")), list(value_label(s, cb), value, TRUE))
  extra = purrr::compact(list(
    if (!is.null(s$color) && !identical(s$family, "heatmap")) list(cb_label(cb, s$color), s$color, FALSE),
    if (!is.null(s$size)) list(cb_label(cb, s$size), s$size, is_num(s$size)),
    if (!is.null(s$facet)) list(cb_label(cb, s$facet), s$facet, FALSE),
    if (!is.null(s$highlight) && !s$highlight$column %in% c(s$x, s$color)) list(cb_label(cb, s$highlight$column), s$highlight$column, FALSE)))
  pieces = purrr::imap(c(cols, extra), function(p, i) c(if (i > 1) list("<br>"), part(p[[1]], p[[2]], p[[3]])))
  as.call(c(list(sym("paste0")), unlist(pieces, recursive = FALSE)))
}

# Whether a column is drawn as a factor (so shown as its level, not as a number).
needs_factor_here <- function(s, col) col %in% c(s$color, if (s$family %in% c("bar", "dot", "box", "slope")) s$x,
                                                  if (identical(s$family, "heatmap")) c(s$x, s$y))

# The value axis of a bar: from zero, a little room at the top only (both ends if a bar drawn is
#   below zero), percent labels for a share.
value_scale <- function(s, axis, zero) {
  args = c(if (zero) list(expand = call("expansion", mult = if (isTRUE(s$.negative)) c(0.05, 0.05) else c(0, 0.05))),
           list(labels = call(if (identical(s$fn, "share")) "label_percent" else "label_comma")))
  scale = as.call(c(list(sym(paste0("scale_", axis, "_continuous"))), args))
  limits = if (zero) as.call(c(list(sym("expand_limits")), stats::setNames(list(0), axis)))
  purrr::compact(list(scale, limits))
}

# A time axis: whole years as whole numbers, room on the right for line labels when asked.
time_scale <- function(s, cb, room) {
  e = cb_entry(cb, s$x)
  expand = if (room) call("expansion", mult = c(0.02, 0.18))
  if (identical(e$type, "date")) {
    if (is.null(expand)) return(NULL)
    return(call(if (identical(storage_of(e), "datetime")) "scale_x_datetime" else "scale_x_date", expand = expand))
  }
  as.call(c(list(sym("scale_x_continuous"), breaks = quote(function(x) unique(floor(pretty(x))))),
            if (!is.null(expand)) list(expand = expand)))
}

bar_calls <- function(s, cb, pal, widget) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  text = if (widget) tooltip_call(s, cb)
  main = if (flip) aes_call(x = v, y = s$x, fill = col, text = text) else aes_call(x = s$x, y = v, fill = col, text = text)
  geom = if (!is.null(s$highlight)) list(call("geom_col", aes_call(fill = "highlighted")),
                                          call("scale_fill_manual", values = highlight_values(), guide = "none"))
    else if (!is.null(col)) list(call("geom_col", position = if (flip) call("position_dodge", width = 0.8, reverse = TRUE) else call("position_dodge", width = 0.8),
                                      width = 0.75),
                                 call("scale_fill_manual", values = pal$qual(colour_count(s, cb, col))))
    else list(call("geom_col", fill = CHART_SINGLE))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, if (flip) "x" else "y", TRUE),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))))
}

dot_calls <- function(s, cb, pal, widget) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  text = if (widget) tooltip_call(s, cb)
  main = if (flip) aes_call(x = v, y = s$x, colour = col, text = text) else aes_call(x = s$x, y = v, colour = col, text = text)
  geom = if (!is.null(s$highlight)) list(call("geom_point", aes_call(colour = "highlighted"), size = 3),
                                          call("scale_colour_manual", values = highlight_values(), guide = "none"))
    else if (!is.null(col)) list(call("geom_point", size = 3),
                                 call("scale_colour_manual", values = pal$qual(colour_count(s, cb, col))))
    else list(call("geom_point", size = 3, colour = CHART_SINGLE))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, if (flip) "x" else "y", FALSE),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))))
}

# A line or slope label at one end: the rows where x is at its last value (per line and panel).
end_rows <- function(s, extra = NULL) {
  x = sym(s$x)
  at = if (identical(s$family, "slope")) call("==", x, call("[", call("levels", x), 2)) else call("==", x, call("max", x))
  by = if (identical(s$family, "line")) list(.by = by_arg(unique(c(s$color, s$facet))))
  as.call(c(list(sym("filter"), sym("chart_table")), extra, list(at), by))
}

# End labels: drawn only when the lint found that none would touch, so nothing is dropped.
end_labels <- function(s, rows, colour = NULL)
  as.call(c(list(sym("geom_text"), data = rows, aes_call(label = s$color), hjust = -0.15, size = 3.5),
            if (!is.null(colour)) list(colour = colour)))

line_calls <- function(s, cb, pal, widget) {
  v = value_name(s); col = s$color; slope = identical(s$family, "slope")
  same = !is.null(col) && identical(col, s$facet)
  labelled = isTRUE(s$.labels) && !widget
  legend = !is.null(s$.legend_order)
  k = if (!is.null(col) && !same) colour_count(s, cb, col) else 0
  many = k > pal$max
  text = if (widget) tooltip_call(s, cb)
  group = col %||% if (widget) 1
  points = function(colour = NULL, data = NULL)
    if (slope) list(as.call(c(list(sym("geom_point")), if (!is.null(data)) list(data = data), list(size = 2.5),
                              if (!is.null(colour)) list(colour = colour))))
  base = function(...) call("ggplot", sym("chart_table"), aes_call(x = s$x, y = v, ...))
  layers = if (is.null(col) || same) {
    c(list(base(group = group, text = text), call("geom_line", colour = CHART_SINGLE, linewidth = 0.9)), points(colour = CHART_SINGLE))
  } else if (!is.null(s$highlight)) {
    nh = length(values_of(s$highlight$values))
    lit = if (legend && nh <= pal$max)
      c(list(call("geom_line", data = data_where(quote(highlighted)), aes_call(colour = col), linewidth = 1.1)),
        if (slope) list(call("geom_point", data = data_where(quote(highlighted)), aes_call(colour = col), size = 2.5)),
        list(call("scale_colour_manual", values = pal$qual(nh), breaks = s$.legend_order)))
    else
      c(list(call("geom_line", data = data_where(quote(highlighted)), colour = CHART_HIGHLIGHT, linewidth = 1.1)),
        points(colour = CHART_HIGHLIGHT, data = data_where(quote(highlighted))),
        if (labelled) list(end_labels(s, end_rows(s, list(quote(highlighted))), CHART_HIGHLIGHT)))
    c(list(base(group = col, text = text), call("geom_line", data = data_where(quote(!highlighted)), colour = CHART_GREY, linewidth = 0.7)), lit)
  } else if (many) {
    c(list(base(group = col, text = text), call("geom_line", colour = CHART_SINGLE, linewidth = 0.7)), points(colour = CHART_SINGLE),
      if (labelled) list(end_labels(s, end_rows(s), CHART_SINGLE)))
  } else {
    c(list(base(colour = col, group = col, text = text), call("geom_line", linewidth = 0.9)), points(),
      list(as.call(c(list(sym("scale_colour_manual"), values = pal$qual(k)), if (legend) list(breaks = s$.legend_order)))),
      if (labelled) list(end_labels(s, end_rows(s)), call("guides", colour = "none")))
  }
  room = labelled
  xscale = if (slope) call("scale_x_discrete", expand = call("expansion", add = if (room) c(0.3, 0.8) else c(0.3, 0.3)))
           else time_scale(s, cb, room)
  yscale = call(if (isTRUE(s$log_y)) "scale_y_log10" else "scale_y_continuous", labels = call("label_comma"))
  c(layers, purrr::compact(list(xscale)), list(yscale), if (room) list(quote(coord_cartesian(clip = "off"))))
}

# A highlighted point's label sits to the left of it in the right half of the x range, to the right otherwise.
side_labels <- function(s) {
  x = sym(s$x)
  hjust = call("if_else", call(">", x, call("/", call("+", call("min", x), call("max", x)), 2)), 1.15, -0.15)
  call("geom_text", data = call("filter", call("mutate", sym("chart_table"), label_hjust = hjust), quote(highlighted)),
       aes_call(label = s$highlight$column, hjust = "label_hjust"), size = 3.5, colour = CHART_HIGHLIGHT)
}

# How far a jittered point may move on one axis: SPEC_JITTER of the smallest gap between distinct
#   values (ggplot2::resolution(); zero = FALSE so 0 is not counted as a value), on the log scale
#   when the axis has one, since a position adjustment works on the transformed values.
jitter_amount <- function(col, log) {
  v = call("$", sym("chart_table"), sym(col))
  call("*", SPEC_JITTER, call("resolution", if (log) call("log10", v) else v, zero = FALSE))
}

jitter_call <- function(s)
  call("position_jitter", width = jitter_amount(s$x, isTRUE(s$log_x)), height = jitter_amount(s$y, isTRUE(s$log_y)),
       seed = SPEC_JITTER_SEED)

scatter_calls <- function(s, cb, pal, widget) {
  col = s$color; bubble = identical(s$family, "bubble")
  binned = isTRUE(s$.binned)
  alpha = c(if (!is.null(s$.alpha)) list(alpha = s$.alpha) else if (bubble) list(alpha = 0.5),
            if (isTRUE(s$.jitter)) list(position = jitter_call(s)))
  text = if (widget && !binned) tooltip_call(s, cb)
  main = aes_call(x = s$x, y = s$y, colour = if (!binned) col, size = if (bubble) s$size, text = text)
  point = function(...) as.call(c(list(sym("geom_point")), list(...), alpha))
  colours = if (!is.null(col) && !binned) {
    n = colour_count(s, cb, col)
    purrr::compact(list(call("scale_colour_manual", values = pal$qual(n)), legend_rows("colour", n, solid = length(alpha) > 0L)))
  }
  geom = if (binned) list(call("geom_bin_2d", bins = SPEC_BIN_2D), call("scale_fill_gradientn", colours = pal$seq))
    else if (!is.null(s$highlight))
      c(list(point(data = data_where(quote(!highlighted)), colour = CHART_GREY),
             point(data = data_where(quote(highlighted)), colour = CHART_HIGHLIGHT)),
        if (!widget) list(side_labels(s)))
    else if (!is.null(col)) c(list(point()), colours)
    else list(point(colour = CHART_SINGLE))
  c(list(call("ggplot", sym("chart_table"), main)), geom, fit_calls(s, cb),
    if (bubble) list(call("scale_size_area", max_size = 8)),
    if (isTRUE(s$rug)) list(call("geom_rug", alpha = 0.2)),
    if (isTRUE(s$log_x)) list(quote(scale_x_log10())), if (isTRUE(s$log_y)) list(quote(scale_y_log10())))
}

# Where a trimmed curve is drawn: SPEC_FIT_POINTS values of x between a group's percentiles, on the
#   log scale when x has one (geom_smooth() takes xseq on the scale's transformed values).
fit_xseq <- function(s, r) {
  if (isTRUE(s$log_x)) call("seq", call("log10", r[1]), call("log10", r[2]), length.out = SPEC_FIT_POINTS)
  else call("seq", r[1], r[2], length.out = SPEC_FIT_POINTS)
}

# The fitted curve as geom_smooth() layers. With no trimmed group, one layer. With groups, one layer
#   per trimmed group, on that group's rows only (data = ~ filter(.x, ...)), with its own xseq, and
#   one layer for the smaller groups, untrimmed.
fit_calls <- function(s, cb) {
  if (identical(s$fit, "none")) return(list())
  smooth = function(data = NULL, r = NULL)
    as.call(c(list(sym("geom_smooth")), if (!is.null(data)) list(data = data),
              list(method = if (identical(s$fit, "linear")) "lm" else "loess", formula = quote(y ~ x), se = FALSE),
              if (!is.null(r)) list(xseq = fit_xseq(s, r)), list(colour = "#4D4D4D", linewidth = 0.8)))
  fr = s$.fit_range
  if (is.null(fr)) return(list(smooth()))
  if (is.null(fr$groups[[1]]$keys)) return(list(smooth(r = fr$groups[[1]]$range)))
  rows = function(cond) call("~", call("filter", sym(".x"), cond))
  conds = purrr::map(fr$groups, function(g)
    purrr::reduce(purrr::imap(g$keys, function(v, col) call("==", sym(col), value_call(cb_entry(cb, col), v))), function(a, b) call("&", a, b)))
  c(purrr::map2(fr$groups, conds, function(g, cond) smooth(rows(cond), g$range)),
    if (isTRUE(fr$rest)) list(smooth(rows(call("!", call("(", purrr::reduce(conds, function(a, b) call("|", a, b))))))))
}

histogram_calls <- function(s, cb, pal, widget)
  c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x)),
         call("geom_histogram", bins = as.numeric(s$bins), fill = CHART_SINGLE, colour = "white"),
         call("scale_y_continuous", expand = call("expansion", mult = c(0, 0.05)))),
    if (isTRUE(s$log_x)) list(quote(scale_x_log10())))

box_calls <- function(s, cb, pal, widget) {
  flip = isTRUE(s$.flip)
  main = if (flip) aes_call(x = s$y, y = s$x) else aes_call(x = s$x, y = s$y)
  c(list(call("ggplot", sym("chart_table"), main), call("geom_boxplot", fill = "#F2F2F2", colour = CHART_SINGLE, width = 0.6)),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))),
    if (isTRUE(s$log_y)) list(if (flip) quote(scale_x_log10()) else quote(scale_y_log10())))
}

# How a heatmap cell prints its value.
cell_format <- function(s) switch(s$fn, count = call("label_comma"), share = call("label_percent", accuracy = 1),
                                  sum = call("label_comma"), call("label_comma", accuracy = 0.1))

# A cell's value in black or white, whichever stands out more against the cell's colour (its
#   luminance from the same colour scale the fill uses).
cell_labels <- function(s, colours) {
  v = sym(value_name(s))
  rescaled = if (!is.null(s$midpoint)) call("rescale_mid", v, mid = s$midpoint) else call("rescale", v)
  fill = as.call(list(call("pal_gradient_n", colours), rescaled))
  light = call(">", call("colSums", call("*", call("col2rgb", fill), c(0.299, 0.587, 0.114))), 140)
  list(call("geom_text", data = mutate_call("text_colour", call("if_else", light, "black", "white")) |> insert_data(),
            aes_call(label = as.call(list(cell_format(s), v)), colour = "text_colour"), size = 3.2),
       quote(scale_colour_identity()))
}

# mutate(...) applied to chart_table: mutate(chart_table, ...).
insert_data <- function(cl) as.call(c(list(cl[[1]], sym("chart_table")), as.list(cl)[-1]))

# A heatmap's fill: the sequential palette, or the diverging one centred on the midpoint.
heatmap_calls <- function(s, cb, pal, widget) {
  text = if (widget) tooltip_call(s, cb)
  colours = if (!is.null(s$midpoint)) pal$div else pal$seq
  rescaler = if (!is.null(s$midpoint))
    list(rescaler = call("function", as.pairlist(alist(x = , ... = )), call("rescale_mid", sym("x"), sym("..."), mid = s$midpoint)))
  c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = s$y, fill = value_name(s), text = text)),
         call("geom_tile", colour = "white", linewidth = 0.5),
         as.call(c(list(sym("scale_fill_gradientn"), colours = colours), rescaler,
                   if (identical(s$fn, "share")) list(labels = call("label_percent")))),
         call("scale_y_discrete", limits = sym("rev"))),
    if (isTRUE(s$.cell_labels) && !widget) cell_labels(s, colours))
}

# Which axis carries the light grid: the value axis.
grid_of <- function(s) switch(s$family,
  bar = , dot = , box = if (isTRUE(s$.flip)) "x" else "y",
  scatter = , bubble = if (isTRUE(s$.binned)) "none" else "xy",
  heatmap = "none",
  "y")

labs_call <- function(s, cb) {
  flip = isTRUE(s$.flip)
  xl = s$x_label %||% cb_label(cb, s$x)
  yl = s$y_label %||% if (s$family %in% c("box", "scatter", "bubble", "heatmap")) cb_label(cb, s$y) else value_label(s, cb)
  line_legend = s$family %in% c("line", "slope") && !is.null(s$.legend_order)
  legend = purrr::compact(list(
    colour = if (!is.null(s$color) && ((s$family %in% c("dot", "scatter", "bubble") && is.null(s$highlight) && !isTRUE(s$.binned)) || line_legend))
               cb_label(cb, s$color),
    fill = if (identical(s$family, "heatmap")) value_label(s, cb)
           else if (identical(s$family, "bar") && !is.null(s$color) && is.null(s$highlight)) cb_label(cb, s$color)
           else if (isTRUE(s$.binned)) "Count",
    size = if (identical(s$family, "bubble")) cb_label(cb, s$size)))
  # A sideways bar or dot lists names on its y axis; that axis needs no title unless the spec gives one.
  axes = if (flip && s$family %in% c("bar", "dot")) list(x = yl, y = s$x_label)
         else if (flip) list(x = yl, y = xl) else list(x = xl, y = yl)
  if (is.null(axes$y)) axes = c(axes["x"], list(y = NULL))
  as.call(c(list(sym("labs")), purrr::compact(list(title = s$title, subtitle = s$subtitle, caption = s$caption)), axes, legend))
}

facet_call <- function(s) {
  if (is.null(s$facet)) return(NULL)
  as.call(c(list(sym("facet_wrap"), call("vars", sym(s$facet))), if (isTRUE(s$free_y)) list(scales = "free_y")))
}

theme_call <- function(s) {
  args = c(if (!identical(grid_of(s), "y")) list(grid = grid_of(s)),
           if (s$family %in% c("line", "slope") && !is.null(s$.legend_order)) list(legend = "right"))
  as.call(c(list(sym("chart_theme")), args))
}

# The plot's layers, as calls, from the spec as the lint left it and the codebook. widget = TRUE
#   builds the variant the plotly version is made from: no direct labels (plotly cannot place
#   them), the legend kept, and a tooltip naming each value.
plot_calls <- function(s, cb, pal = spec_palette(), widget = FALSE) {
  build = switch(s$family, bar = bar_calls, dot = dot_calls, line = , slope = line_calls, scatter = , bubble = scatter_calls,
                 histogram = histogram_calls, box = box_calls, heatmap = heatmap_calls)
  c(build(s, cb, pal, widget), purrr::compact(list(facet_call(s), labs_call(s, cb), theme_call(s))))
}

plus_call <- function(calls) purrr::reduce(calls[-1], function(acc, cl) call("+", acc, cl), .init = calls[[1]])

# Whether the widget variant carries its own tooltip text.
widget_has_text <- function(s) s$family %in% c("bar", "dot", "line", "slope", "scatter", "bubble", "heatmap") &&
  !isTRUE(s$.binned)

# The ggplot for a spec. Runs the defaults, the check, the table and the lint itself, so one call
#   is enough. `palette` names the three palettes of the report (chart_palette_default()); the
#   spec never chooses colours. Attributes: notes (the lint's sentences), spec (the spec as drawn),
#   table, widget_plot (the variant spec_widget() converts) and palette.
spec_plot <- function(spec, data, cb, palette = chart_palette_default()) {
  s = spec_defaults(spec_public(spec))
  why = spec_check(s, cb, palette)
  if (length(why)) spec_fail(paste(why, collapse = " "))
  pal = spec_palette(palette)
  table = spec_table(s, data, cb, palette)
  lint = spec_lint(s, cb, table, pal$max)
  env = spec_env(chart_table = table)
  p = eval(plus_call(plot_calls(lint$spec, cb, pal)), env)
  attr(p, "notes") = lint$notes
  attr(p, "spec") = lint$spec
  attr(p, "table") = table
  attr(p, "widget_plot") = eval(plus_call(plot_calls(lint$spec, cb, pal, widget = TRUE)), env)
  attr(p, "widget_text") = widget_has_text(lint$spec)
  attr(p, "palette") = palette
  p
}


# ---- the code ---------------------------------------------------------------------------------------

SPEC_DELIMS <- c(",", ";", "\t", "|", " ", ":")

# The delimiter that splits the file's header into as many columns as the codebook has, and the
#   header's names as readr names them by default (blank and repeated names repaired as ...1,
#   name...3); NULL when the file is not there or no delimiter fits.
file_header <- function(file, n, encoding = "UTF-8") {
  if (!file.exists(file)) return(NULL)
  header = function(d, repair) tryCatch(names(suppressMessages(readr::read_delim(
    file, delim = d, n_max = 0, name_repair = repair, locale = readr::locale(encoding = encoding),
    col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE, progress = FALSE))),
    error = function(e) NULL)
  d = purrr::detect(SPEC_DELIMS, function(d) length(header(d, "minimal")) == n)
  if (is.null(d)) NULL else list(delim = d, names = header(d, "unique"))
}

# A call written out as code: on one line when it fits in SPEC_CODE_WIDTH characters (with its
#   indent and what follows it), otherwise wrapped.
code_text <- function(cl, indent = 0L, suffix = "") {
  one = deparse1(cl, collapse = " ")
  if (indent + nchar(one) + nchar(suffix) <= SPEC_CODE_WIDTH) return(one)
  wrap = function(cutoff) trimws(deparse(cl, width.cutoff = cutoff), "left")
  fits = function(lines) all(nchar(lines) + c(indent, rep(indent + 4L, length(lines) - 1L)) <= SPEC_CODE_WIDTH)
  cutoff = purrr::detect(c(70L, 60L, 50L, 40L, 30L, 20L), function(k) fits(wrap(k))) %||% 20L
  paste(wrap(cutoff), collapse = paste0("\n", strrep(" ", indent + 4L)))
}

# R code that reads the file (by its name, with the codebook's values that mean missing and its
#   encoding), builds the same table with dplyr and tidyr, and draws the same chart with ggplot2,
#   ending with chart_theme(). It is written from the spec as spec_plot() left it
#   (attr(plot, "spec")) and the same palette: every line is one of the calls spec_table() and
#   spec_plot() evaluate, with the palette's colours written in, so the code runs without paletteer.
#   `file` is where the file is now (to read its header); the code names it by cb$file only.
spec_code <- function(spec, cb, file, palette = chart_palette_default()) {
  pub = spec_defaults(spec_public(spec))
  why = spec_check(pub, cb, palette)
  if (length(why)) spec_fail(paste(why, collapse = " "))
  s = spec_defaults(spec)
  names_now = purrr::map_chr(cb$columns, "name")
  enc = cb$encoding %||% "UTF-8"
  h = file_header(file, length(names_now), enc)
  renamed = if (!is.null(h)) which(h$names != names_now) else integer(0)
  read = as.call(c(list(sym("read_delim"), cb$file %||% basename(file)), if (!is.null(h)) list(delim = h$delim),
                   list(na = c(DATA_NA, missing_codes(cb))),
                   if (!enc %in% c("UTF-8", "ASCII")) list(locale = call("locale", encoding = enc)),
                   list(trim_ws = TRUE, guess_max = Inf, show_col_types = FALSE)))
  rename = if (length(renamed)) as.call(c(list(sym("rename")), stats::setNames(purrr::map(h$names[renamed], sym), names_now[renamed])))
  st = table_steps(s, cb)
  steps = c(st$base, st$agg, st$post)
  plot = plot_calls(s, cb, spec_palette(palette))
  plot_text = paste(purrr::imap_chr(plot, function(cl, i) code_text(cl, 2L, if (i < length(plot)) " +" else "")), collapse = " +\n  ")
  step_text = paste(purrr::imap_chr(steps, function(cl, i) code_text(cl, 2L, if (i < length(steps)) " |>" else "")), collapse = " |>\n  ")
  libs = c("readr", "dplyr", "tidyr", "ggplot2", if (grepl("label_|breaks_|pal_gradient_n|rescale", plot_text)) "scales")
  paste0(paste0("library(", libs, ")", collapse = "\n"), "\n\n",
         "# The data, read as chaRt reads it: these values mean missing, and column types are guessed from every row.\n",
         "# Set the working directory to the folder that holds the file (setwd()), or write its full path here.\n",
         "chart_data <- ", code_text(read, 14L, if (!is.null(rename)) " |>" else ""),
         if (!is.null(rename)) paste0(" |>\n  ", code_text(rename, 2L), "  # blank or repeated names in the file, as in the codebook"),
         "\n\n# The table that is drawn.\n",
         "chart_table <- chart_data |>\n  ", step_text, "\n\n",
         "# The chart. chart_theme() is the house theme, in R/theme.R.\n",
         plot_text, "\n")
}


# ---- the plotly version and the figure size -------------------------------------------------------

# Text in the plotly version matches the static chart at the same size: ggplotly() turns the
#   theme's points into pixels at a smaller ratio than a 96 dpi image does.
SPEC_PLOTLY_TEXT <- 96 / 72 / 1.215
SPEC_WRAP_TITLE <- 50L      # plotly's default font is wider than the static chart's
SPEC_WRAP_SUBTITLE <- 70L

# Every font size in a built plotly figure, times f.
scale_fonts <- function(x, f, in_font = FALSE) {
  if (!is.list(x)) return(x)
  keys = names(x) %||% rep("", length(x))
  out = purrr::map2(x, keys, function(el, key) {
    if (in_font && identical(key, "size") && is.numeric(el)) return(el * f)
    scale_fonts(el, f, in_font || key %in% c("font", "tickfont", "titlefont"))
  })
  names(out) = names(x)
  out
}

wrapped <- function(text, width) paste(strwrap(text, width), collapse = "<br>")

# plotly::ggplotly() of a spec_plot()'s widget variant, built (plotly::plotly_build()) so that every
#   warning comes now. The title and subtitle are both shown and wrapped, the caption below the
#   chart, the text scaled to match the static chart, the legend on the right where it does not
#   cover the title, the tooltip naming each value with its codebook label, and the mode bar cut
#   to the download button. Warnings are kept as attr(, "warnings").
#   The palette is the one the plot was drawn with (attr(plot, "palette")); a different one needs a
#   new spec_plot(), since the widget is converted from the plot.
spec_widget <- function(plot, palette = attr(plot, "palette") %||% chart_palette_default()) {
  s = attr(plot, "spec") %||% list()
  wp = attr(plot, "widget_plot") %||% plot
  tip = if (isTRUE(attr(plot, "widget_text"))) "text" else SPEC_TOOLTIP
  said = character(0)
  w = withCallingHandlers(plotly::plotly_build(plotly::ggplotly(wp, tooltip = tip)),
                          warning = function(cond) { said <<- c(said, conditionMessage(cond)); invokeRestart("muffleWarning") })
  w$x$layout = scale_fonts(w$x$layout, SPEC_PLOTLY_TEXT)
  title_lines = c(if (!is.null(s$title)) paste0("<b>", wrapped(s$title, SPEC_WRAP_TITLE), "</b>"),
                  if (!is.null(s$subtitle)) paste0("<span style=\"font-size:0.8em;color:#4D4D4D\">", wrapped(s$subtitle, SPEC_WRAP_SUBTITLE), "</span>"))
  if (length(title_lines)) {
    n_lines = sum(lengths(regmatches(title_lines, gregexpr("<br>", title_lines)))) + length(title_lines)
    w$x$layout$title = utils::modifyList(w$x$layout$title %||% list(),
                                         list(text = paste(title_lines, collapse = "<br>"), x = 0.01, xanchor = "left",
                                              xref = "container"))
    w$x$layout$margin$t = 30 + 22 * n_lines
  }
  if (!is.null(s$caption)) {
    w$x$layout$annotations = c(w$x$layout$annotations,
                               list(list(text = wrapped(s$caption, SPEC_WRAP_SUBTITLE), x = 0, y = 0, xref = "paper", yref = "paper",
                                         xanchor = "left", yanchor = "top", yshift = -45, showarrow = FALSE,
                                         font = list(size = 11, color = "#7F7F7F"))))
    w$x$layout$margin$b = (w$x$layout$margin$b %||% 40) + 30
  }
  w$x$layout$legend = utils::modifyList(w$x$layout$legend %||% list(),
                                        list(x = 1.02, y = 1, xanchor = "left", yanchor = "top", orientation = "v"))
  w = plotly::config(w, displaylogo = FALSE, modeBarButtons = list(list("toImage")))
  attr(w, "warnings") = unique(said)
  w
}

# The static chart as a PNG at SPEC_DPI pixels per inch and its size in inches: ragg when it is
#   installed, the cairo png device otherwise. Returns the size in inches, invisibly.
spec_png <- function(plot, file, size = spec_size(attr(plot, "spec"), attr(plot, "table")), dpi = SPEC_DPI) {
  w = round(size[["width"]] * dpi)
  h = round(size[["height"]] * dpi)
  if (nzchar(find.package("ragg", quiet = TRUE))) ragg::agg_png(file, width = w, height = h, units = "px", res = dpi)
  else grDevices::png(file, width = w, height = h, units = "px", res = dpi, type = "cairo")
  on.exit(grDevices::dev.off())
  print(plot)
  invisible(size)
}

# Width and height in inches for the static figure: 7 by 4.5, taller for sideways bars with many
#   rows and for rows of panels, wider for four or more panels across.
spec_size <- function(spec, table) {
  w = SPEC_SIZE[["width"]]
  h = SPEC_SIZE[["height"]]
  if (isTRUE(spec$.flip) && !is.null(spec$x))
    h = max(h, 1.5 + SPEC_ROW_INCHES * length(unique(table[[spec$x]])))
  if (!is.null(spec$facet)) {
    panels = length(unique(table[[spec$facet]]))
    across = ceiling(sqrt(panels))
    h = max(h, 1.3 + SPEC_PANEL_INCHES * ceiling(panels / across))
    if (across >= 4) w = SPEC_SIZE[["max_width"]]
  }
  c(width = w, height = min(h, SPEC_SIZE[["max_height"]]))
}
