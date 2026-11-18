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
SPEC_ROW_INCHES <- 0.28      # height of one sideways bar
SPEC_PANEL_INCHES <- 2.2     # height of one row of panels

SPEC_FAMILIES <- c("bar", "dot", "line", "slope", "scatter", "bubble", "histogram", "box", "heatmap")
SPEC_FNS <- c("none", "count", "share", "sum", "mean", "median")
SPEC_OPS <- c("==", "!=", ">", ">=", "<", "<=", "in")
SPEC_SORTS <- c("value_desc", "value_asc", "level_order", "alphabetical")
SPEC_FITS <- c("none", "loess", "linear")
SPEC_FIELDS <- c("family", "x", "y", "color", "size", "facet", "fn", "filter", "top_n", "sort", "log_x", "log_y",
                 "fit", "rug", "bins", "free_y", "highlight", "title", "subtitle", "caption", "x_label", "y_label",
                 "interactive", "rule", "say")
SPEC_COLUMN_FIELDS <- c("x", "y", "color", "size", "facet")
SPEC_TEXT_FIELDS <- c("title", "subtitle", "caption", "x_label", "y_label", "rule", "say")
SPEC_FLAG_FIELDS <- c("log_x", "log_y", "rug", "free_y", "interactive")

# Fields the lint adds; never accepted from outside.
SPEC_LINT_FIELDS <- c(".flip", ".alpha", ".binned")

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

# The defaults of the spec table, and nothing else. The sort of a bar or dot depends on the type
#   of x, so it is decided with the codebook (effective_sort()), not here.
spec_defaults <- function(spec) {
  d = list(fn = default_fn(spec), log_x = FALSE, log_y = FALSE, fit = "none", rug = FALSE, free_y = FALSE,
           interactive = FALSE)
  purrr::reduce(names(d), function(s, k) { if (is.null(s[[k]]) && !is.null(d[[k]])) s[[k]] = d[[k]]; s }, .init = spec)
}

effective_sort <- function(s, cb) {
  if (!s$family %in% c("bar", "dot")) return(NULL)
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

# What a column field may hold, per family: "group", "name", "measure", "time", or NULL (not allowed).
family_roles <- function(family) switch(family,
  bar = , dot = list(x = c("group", "name"), y = "measure", color = "group", size = NULL),
  line = list(x = "time", y = "measure", color = c("group", "name"), size = NULL),
  slope = list(x = c("time", "group"), y = "measure", color = c("group", "name"), size = NULL),
  scatter = list(x = "measure", y = "measure", color = "group", size = NULL),
  bubble = list(x = "measure", y = "measure", color = "group", size = "measure"),
  histogram = list(x = "measure", y = NULL, color = NULL, size = NULL),
  box = list(x = "group", y = "measure", color = NULL, size = NULL),
  heatmap = list(x = c("group", "time"), y = "group", color = "measure", size = NULL))

kind_ok <- function(e, kinds)
  ("group" %in% kinds && is_group_like(e)) || ("name" %in% kinds && is_name_like(e)) ||
    ("measure" %in% kinds && is_measure(e)) || ("time" %in% kinds && is_time(e))

kinds_text <- function(kinds) paste(c(group = "a group (category, ordered, flag, or whole numbers with at most 30 values)",
                                      name = "a name (id or text) with top_n", measure = "a measure (number or integer)",
                                      time = "a time (a date, or role time)")[kinds], collapse = " or ")

# The reasons a spec cannot be drawn, as sentences naming the field and the column; none when it can.
#   Reads only the codebook. Every rule that does not need the data is here.
spec_check <- function(spec, cb) {
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
      if (identical(fam, "slope")) return("facet: a slope chart cannot be split into small multiples.")
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
    if (identical(f, "color") && fam %in% c("scatter", "bubble") && is.null(s$filter) && e$distinct > CHART_MAX_GROUPS)
      return(paste0("color: '", v, "' has ", e$distinct, " values; points can be told apart by at most ", CHART_MAX_GROUPS,
                    " colours. Highlight a few values or use small multiples (facet)."))
    if (identical(f, "x") && identical(fam, "box") && is.null(s$filter) && e$distinct > SPEC_BOX_GROUPS)
      return(paste0("x: '", v, "' has ", e$distinct, " values; a box plot takes at most ", SPEC_BOX_GROUPS, " boxes."))
    NULL
  }))
  required = c(x = TRUE, y = !fam %in% c("bar", "dot", "histogram"), color = identical(fam, "slope"), size = identical(fam, "bubble"))
  missing_cols = purrr::compact(purrr::imap(required, function(need, f)
    if (need && is.null(s[[f]])) paste0(f, ": a ", fam, " chart needs a ", f, " column.")))
  out = c(out, unlist(cols), unlist(missing_cols))
  if (identical(fam, "histogram") && !is.null(s$y)) out = c(out, "y: a histogram counts its x, so it takes no y.")

  # The function.
  fn = s$fn
  fn_msg = if (!is.null(fn) && (!is_text1(fn) || !fn %in% SPEC_FNS))
    paste0("fn must be one of ", paste(SPEC_FNS, collapse = ", "), ".")
  else switch(fam,
    bar = , dot = if (is.null(s$y)) { if (!fn %in% c("count", "share")) paste0("fn: a ", fam, " with no y counts rows, so fn must be count or share.") }
                  else if (is.null(fn)) paste0("fn: a ", fam, " with a y needs a function (sum, mean, median, or none).")
                  else if (fn %in% c("count", "share")) paste0("fn: '", fn, "' counts rows and does not use y; drop y or choose sum, mean, median or none."),
    line = , slope = if (is.null(fn)) paste0("fn: a ", fam, " chart needs a function (sum, mean, median, or none).")
                     else if (fn %in% c("count", "share")) paste0("fn: a ", fam, " chart plots its y, so fn must be sum, mean, median or none."),
    scatter = , bubble = , histogram = , box = if (!identical(fn, "none")) paste0("fn: a ", fam, " draws each row, so fn must be none; it is '", fn, "'."),
    heatmap = if (is.null(s$color)) { if (!identical(fn, "count")) "fn: a heatmap with no color fills each tile with the count, so fn must be count." }
              else if (is.null(fn) || !fn %in% c("sum", "mean", "median")) "fn: a heatmap filled with a color column needs sum, mean or median.")
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
      if (!fam %in% c("bar", "dot", "line", "slope")) paste0("top_n: a ", fam, " chart does not use top_n.")
      else if (!is_whole1(s$top_n) || s$top_n < 1 || s$top_n > SPEC_TOP_MAX)
        paste0("top_n must be a whole number from 1 to ", SPEC_TOP_MAX, "; it is ", paste(values_of(s$top_n), collapse = ", "), ".")
    },
    if (!is.null(s$sort)) {
      if (!fam %in% c("bar", "dot")) paste0("sort: a ", fam, " chart is not sorted; only bar and dot charts are.")
      else if (!is_text1(s$sort) || !s$sort %in% SPEC_SORTS) paste0("sort must be one of ", paste(SPEC_SORTS, collapse = ", "), ".")
    },
    if (!is_text1(s$fit) || !s$fit %in% SPEC_FITS) paste0("fit must be one of ", paste(SPEC_FITS, collapse = ", "), ".")
    else if (!identical(s$fit, "none") && !fam %in% c("scatter", "bubble")) paste0("fit: only a scatter or bubble chart takes a fitted line."),
    if (isTRUE(s$rug) && !identical(fam, "scatter")) "rug: only a scatter chart takes a rug.",
    if (!is.null(s$bins)) {
      if (!identical(fam, "histogram")) paste0("bins: only a histogram takes bins.")
      else if (!is_whole1(s$bins) || s$bins < SPEC_BINS[1] || s$bins > SPEC_BINS[2])
        paste0("bins must be a whole number from ", SPEC_BINS[1], " to ", SPEC_BINS[2], ".")
    },
    if (isTRUE(s$free_y) && is.null(s$facet)) "free_y: only small multiples (facet) can free the y scale.",
    if (isTRUE(s$log_x) && !(is_text1(s$x) && !is.null(cb_entry(cb, s$x)) && is_measure(cb_entry(cb, s$x)) &&
                             fam %in% c("scatter", "bubble", "histogram")))
      paste0("log_x: only a measure on the x axis of a scatter, bubble or histogram can take a log scale."),
    if (isTRUE(s$log_y) && !fam %in% c("bar", "dot", "line", "scatter", "bubble", "box"))
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
  if (!fam %in% c("bar", "dot", "line", "slope", "scatter", "bubble"))
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

# names(sort(tapply(value, column, sum), decreasing = ...)): the column's values ranked by their total.
ranking_call <- function(value, column, decreasing = TRUE)
  call("names", call("sort", call("tapply", sym(value), sym(column), sym("sum")), decreasing = decreasing))

top_call <- function(s) {
  if (is.null(s$top_n)) return(NULL)
  col = ranked_column(s)
  call("filter", call("%in%", sym(col), call("head", ranking_call(value_name(s), col), as.numeric(s$top_n))))
}

level_order_call <- function(e, col) {
  if (identical(e$type, "ordered") && length(e$order)) return(call("factor", sym(col), levels = e$order))
  call("factor", sym(col), levels = call("sort", call("unique", sym(col))))
}

sort_call <- function(s, cb) {
  srt = effective_sort(s, cb)
  if (is.null(srt)) return(NULL)
  x = s$x
  lv = switch(srt,
    value_desc = call("factor", sym(x), levels = ranking_call(value_name(s), x, TRUE)),
    value_asc = call("factor", sym(x), levels = ranking_call(value_name(s), x, FALSE)),
    alphabetical = call("factor", sym(x), levels = call("sort", call("unique", sym(x)))),
    level_order = level_order_call(cb_entry(cb, x), x))
  as.call(c(list(sym("mutate")), stats::setNames(list(lv), x)))
}

# A bar's or dot's rows in the order they are drawn.
arrange_call <- function(s) if (s$family %in% c("bar", "dot")) call("arrange", sym(s$x))

# Columns drawn as discrete groups that would otherwise be read as continuous or in the wrong order:
#   made factors, in order. A colour is always discrete; a box's or slope's x and a heatmap's
#   group axes too; a facet only needs its order.
needs_factor <- function(e) identical(e$type, "ordered") || identical(storage_of(e), "number")

factor_call <- function(s, cb) {
  fam = s$family
  want = c(if (!is.null(s$color) && !identical(fam, "heatmap")) s$color,
           if (!is.null(s$facet) && identical(cb_entry(cb, s$facet)$type, "ordered")) s$facet,
           if (identical(fam, "box")) s$x,
           if (identical(fam, "heatmap")) c(if (is_group_like(cb_entry(cb, s$x))) s$x, s$y))
  need = unique(c(purrr::keep(want, function(col) needs_factor(cb_entry(cb, col))), if (identical(fam, "slope")) s$x))
  if (!length(need)) return(NULL)
  as.call(c(list(sym("mutate")), stats::setNames(purrr::map(need, function(col) level_order_call(cb_entry(cb, col), col)), need)))
}

highlight_call <- function(s, cb) {
  h = s$highlight
  if (is.null(h)) return(NULL)
  as.call(list(sym("mutate"), highlighted = call("%in%", sym(h$column), value_call(cb_entry(cb, h$column), h$values))))
}

# The table's steps, as calls without their data argument, in two parts: `base` (the filter and
#   the rows left out for missing values) and `rest`. The data checks run between the two.
table_steps <- function(s, cb) {
  rest = c(aggregate_calls(s), list(top_call(s), sort_call(s, cb), arrange_call(s), factor_call(s, cb), highlight_call(s, cb)))
  list(base = purrr::compact(list(filter_call(s, cb), as.call(c(sym("drop_na"), purrr::map(spec_columns(s), sym))))),
       rest = purrr::compact(rest))
}

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
  pipeline = purrr::reduce(steps, function(acc, st) as.call(c(list(st[[1]]), list(acc), as.list(st)[-1])), .init = sym("chart_data"))
  eval(pipeline, spec_env(chart_data = data, ...))
}

# The rules that need the data, on the rows left after the filter and the missing values.
data_checks <- function(s, base) {
  fam = s$family
  nd = function(col) length(unique(base[[col]]))
  if (!nrow(base)) spec_fail("No rows are left once the filter is applied and rows with missing values are left out.")
  if (!is.null(s$facet) && nd(s$facet) > SPEC_FACET_MAX)
    spec_fail(paste0("facet: '", s$facet, "' has ", nd(s$facet), " values after the filter, so as many panels; at most ", SPEC_FACET_MAX, "."))
  if (fam %in% c("bar", "dot") && !is.null(s$color) && nd(s$color) > SPEC_BAR_GROUPS)
    spec_fail(paste0("color: '", s$color, "' has ", nd(s$color), " values after the filter; a ", fam, " chart takes at most ", SPEC_BAR_GROUPS, " colours."))
  if (fam %in% c("scatter", "bubble") && !is.null(s$color) && nd(s$color) > CHART_MAX_GROUPS)
    spec_fail(paste0("color: '", s$color, "' has ", nd(s$color), " values after the filter; points can be told apart by at most ",
                     CHART_MAX_GROUPS, " colours."))
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

# The table that is drawn: after the filter, the rows left out for missing values, the
#   aggregation, top_n and the sort. Attributes rows_used, rows_dropped and groups_total.
spec_table <- function(spec, data, cb) {
  s = spec_defaults(spec_public(spec))
  why = spec_check(s, cb)
  if (length(why)) spec_fail(paste(why, collapse = " "))
  s = c(s, spec[intersect(names(spec), SPEC_LINT_FIELDS)])
  st = table_steps(s, cb)
  filtered = if (is.null(s$filter)) data else run_steps(data, st$base[1])
  base = run_steps(data, st$base)
  data_checks(s, base)
  out = if (length(st$rest)) run_steps(base, st$rest) else base
  ranked = if (s$family %in% c("bar", "dot", "line", "slope")) ranked_column(s)
  structure(out, rows_used = nrow(base), rows_dropped = nrow(filtered) - nrow(base),
            groups_total = if (!is.null(ranked)) length(unique(base[[ranked]])) else NA_integer_)
}


# ---- the lint ------------------------------------------------------------------------------------

# The figures the plot needs that depend on the table: the sort a bar or dot falls back on, a
#   histogram's bins when none were given, and "Top n of N" as the subtitle.
spec_settle <- function(s, cb, table) {
  if (s$family %in% c("bar", "dot")) s$sort = effective_sort(s, cb)
  if (identical(s$family, "histogram") && is.null(s$bins)) {
    x = table[[s$x]]
    x = if (isTRUE(s$log_x)) log10(x[x > 0]) else x
    s$bins = as.integer(min(max(grDevices::nclass.FD(x), SPEC_BINS[1]), SPEC_BINS[2]))
  }
  if (!is.null(s$top_n) && is.null(s$subtitle))
    s$subtitle = paste0("Top ", s$top_n, " of ", attr(table, "groups_total"))
  s
}

# How many marks a chart draws: bars, points or boxes are rows of the table; a histogram draws its
#   bins in each panel; a binned scatter its grid.
mark_count <- function(s, table) {
  panels = if (!is.null(s$facet)) length(unique(table[[s$facet]])) else 1L
  if (identical(s$family, "histogram")) return(as.integer(s$bins %||% SPEC_BINS[2]) * panels)
  if (isTRUE(s$.binned)) return(SPEC_BIN_2D^2 * panels)
  nrow(table)
}

# The rules R enforces with no model call (DESIGN.md section 8). Fixes change the spec; notes are
#   sentences for the analyst. Returns list(spec, notes).
spec_lint <- function(spec, cb, table) {
  s = spec_settle(spec, cb, table)
  fam = s$family
  nd = function(col) length(unique(table[[col]]))
  notes = character(0)
  # A bar's value axis starts at zero (the bar layers always include zero), so no log scale.
  if (identical(fam, "bar") && isTRUE(s$log_y)) {
    s$log_y = FALSE
    notes = c(notes, "A bar's length shows its value, so its axis starts at zero; the log scale was removed.")
  }
  # Many bars, dots or boxes, or long labels: drawn sideways.
  if (fam %in% c("bar", "dot", "box")) {
    labels = as.character(unique(table[[s$x]]))
    if (length(labels) > SPEC_FLIP_BARS || any(nchar(labels) > SPEC_FLIP_CHARS)) s$.flip = TRUE
  }
  if (!is.null(s$color) && !identical(fam, "heatmap") && nd(s$color) > SPEC_COLOURS)
    notes = c(notes, paste0(nd(s$color), " colours are hard to tell apart; highlight the few that matter, or use small multiples (facet)."))
  if (identical(fam, "line") && !is.null(s$color) && nd(s$color) > SPEC_LINES && is.null(s$highlight) && is.null(s$facet))
    notes = c(notes, paste0(nd(s$color), " lines overlap; small multiples (facet) or a highlight of the few that matter would read more easily."))
  # Small multiples share their scales unless free_y asks otherwise: facet_wrap()'s scales are
  #   fixed by default, so there is nothing to change.
  if (fam %in% c("scatter", "bubble")) {
    n = nrow(table)
    if (n > SPEC_BIN_N) {
      s$.binned = TRUE
      notes = c(notes, paste0(format_num(n), " points would hide one another, so the chart shows how many fall in each cell of a grid."))
    } else if (n > SPEC_ALPHA_N) {
      s$.alpha = SPEC_ALPHA
      notes = c(notes, paste0(format_num(n), " points are drawn see-through, so that where they pile up shows."))
    }
  }
  if (isTRUE(s$interactive) && mark_count(s, table) > SPEC_WIDGET_N) {
    s$interactive = FALSE
    notes = c(notes, paste0(format_num(mark_count(s, table)), " marks are too many for the interactive version; the chart is static."))
  }
  if (is.null(s$title)) notes = c(notes, "The chart has no title; a title that states the finding tells the reader what to look for.")
  dropped = attr(table, "rows_dropped") %||% 0L
  if (dropped > 0L)
    notes = c(notes, paste0(format_num(dropped), " of ", format_num(dropped + attr(table, "rows_used")), " rows left out: missing values."))
  list(spec = s, notes = notes)
}


# ---- the plot --------------------------------------------------------------------------------------

# How many colours a column needs, from the codebook (and top_n), so the plot and its code can be
#   built without the data.
colour_count <- function(s, cb, col) {
  n = cb_entry(cb, col)$distinct
  if (!is.null(s$top_n) && identical(col, ranked_column(s))) min(n, s$top_n) else n
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

# The value axis of a bar: from zero, a little room at the top only (both ends if there are
#   negative values), percent labels for a share.
value_scale <- function(s, cb, axis, zero) {
  negative = !is.null(s$y) && !s$fn %in% c("count", "share") && isTRUE(cb_entry(cb, s$y)$min < 0)
  args = c(if (zero) list(expand = call("expansion", mult = if (negative) c(0.05, 0.05) else c(0, 0.05))),
           list(labels = call(if (identical(s$fn, "share")) "label_percent" else "label_comma")))
  scale = if (length(args)) as.call(c(list(sym(paste0("scale_", axis, "_continuous"))), args))
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

bar_calls <- function(s, cb) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  main = if (flip) aes_call(x = v, y = s$x, fill = col) else aes_call(x = s$x, y = v, fill = col)
  geom = if (!is.null(s$highlight)) list(call("geom_col", aes_call(fill = "highlighted")),
                                          call("scale_fill_manual", values = highlight_values(), guide = "none"))
    else if (!is.null(col)) list(call("geom_col", position = call("position_dodge", width = 0.8), width = 0.75),
                                 call("scale_fill_manual", values = chart_palette(colour_count(s, cb, col))))
    else list(call("geom_col", fill = CHART_SINGLE))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, cb, if (flip) "x" else "y", TRUE),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))))
}

dot_calls <- function(s, cb) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  main = if (flip) aes_call(x = v, y = s$x, colour = col) else aes_call(x = s$x, y = v, colour = col)
  geom = if (!is.null(s$highlight)) list(call("geom_point", aes_call(colour = "highlighted"), size = 3),
                                          call("scale_colour_manual", values = highlight_values(), guide = "none"))
    else if (!is.null(col)) list(call("geom_point", size = 3),
                                 call("scale_colour_manual", values = chart_palette(colour_count(s, cb, col))))
    else list(call("geom_point", size = 3, colour = CHART_SINGLE))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, cb, if (flip) "x" else "y", FALSE),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))))
}

# A line or slope label at one end: the rows where x is at its last value (per line and panel).
end_rows <- function(s, extra = NULL, first = FALSE) {
  x = sym(s$x)
  at = if (identical(s$family, "slope")) call("==", x, call("[", call("levels", x), if (first) 1 else 2))
       else call("==", x, call("max", x))
  conds = c(extra, list(at))
  by = if (identical(s$family, "line")) list(.by = by_arg(c(s$color, s$facet)))
  as.call(c(list(sym("filter"), sym("chart_table")), conds, by))
}

end_labels <- function(s, rows, colour = NULL)
  as.call(c(list(sym("geom_text"), data = rows, aes_call(label = s$color), hjust = -0.15, size = 3.5, check_overlap = TRUE),
            if (!is.null(colour)) list(colour = colour)))

line_calls <- function(s, cb) {
  v = value_name(s); col = s$color; slope = identical(s$family, "slope")
  k = if (!is.null(col)) colour_count(s, cb, col) else 0
  many = k > CHART_MAX_GROUPS
  points = function(colour = NULL)
    if (slope) list(as.call(c(list(sym("geom_point"), size = 2.5), if (!is.null(colour)) list(colour = colour))))
  layers = if (is.null(col)) {
    c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = v)), call("geom_line", colour = CHART_SINGLE, linewidth = 0.9)),
      points(colour = CHART_SINGLE))
  } else if (!is.null(s$highlight)) {
    c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = v, group = col)),
           call("geom_line", data = data_where(quote(!highlighted)), colour = CHART_GREY, linewidth = 0.7),
           call("geom_line", data = data_where(quote(highlighted)), colour = CHART_HIGHLIGHT, linewidth = 1.1)),
      if (slope) list(call("geom_point", data = data_where(quote(highlighted)), colour = CHART_HIGHLIGHT, size = 2.5)),
      list(end_labels(s, end_rows(s, list(quote(highlighted))), CHART_HIGHLIGHT)))
  } else if (many) {
    c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = v, group = col)), call("geom_line", colour = CHART_SINGLE, linewidth = 0.7)),
      points(colour = CHART_SINGLE), list(end_labels(s, end_rows(s), CHART_SINGLE)))
  } else {
    c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = v, colour = col, group = if (slope) col)),
           call("geom_line", linewidth = 0.9)),
      points(), list(end_labels(s, end_rows(s)), call("scale_colour_manual", values = chart_palette(k)),
                     call("guides", colour = "none")))
  }
  room = !is.null(col)
  xscale = if (slope) call("scale_x_discrete", expand = call("expansion", add = c(0.3, 0.8))) else time_scale(s, cb, room)
  yscale = call(if (isTRUE(s$log_y)) "scale_y_log10" else "scale_y_continuous", labels = call("label_comma"))
  c(layers, purrr::compact(list(xscale)), list(yscale), if (room) list(quote(coord_cartesian(clip = "off"))))
}

scatter_calls <- function(s, cb) {
  col = s$color; bubble = identical(s$family, "bubble")
  alpha = if (!is.null(s$.alpha)) list(alpha = s$.alpha) else if (bubble) list(alpha = 0.5)
  main = aes_call(x = s$x, y = s$y, colour = if (!isTRUE(s$.binned)) col, size = if (bubble) s$size)
  point = function(...) as.call(c(list(sym("geom_point")), list(...), alpha))
  geom = if (isTRUE(s$.binned)) list(call("geom_bin_2d", bins = SPEC_BIN_2D), call("scale_fill_gradientn", colours = CHART_SEQUENTIAL))
    else if (!is.null(s$highlight))
      list(point(data = data_where(quote(!highlighted)), colour = CHART_GREY),
           point(data = data_where(quote(highlighted)), colour = CHART_HIGHLIGHT),
           call("geom_text", data = data_where(quote(highlighted)), aes_call(label = s$highlight$column), vjust = -0.9,
                size = 3.5, colour = CHART_HIGHLIGHT, check_overlap = TRUE))
    else if (!is.null(col)) list(point(), call("scale_colour_manual", values = chart_palette(colour_count(s, cb, col))))
    else list(point(colour = CHART_SINGLE))
  fit = if (!identical(s$fit, "none"))
    list(call("geom_smooth", method = if (identical(s$fit, "linear")) "lm" else "loess", formula = quote(y ~ x), se = FALSE,
              colour = "#4D4D4D", linewidth = 0.8))
  c(list(call("ggplot", sym("chart_table"), main)), geom, fit,
    if (bubble) list(call("scale_size_area", max_size = 8)),
    if (!is.null(s$highlight) && !isTRUE(s$.binned)) list(quote(coord_cartesian(clip = "off"))),
    if (isTRUE(s$rug)) list(call("geom_rug", alpha = 0.2)),
    if (isTRUE(s$log_x)) list(quote(scale_x_log10())), if (isTRUE(s$log_y)) list(quote(scale_y_log10())))
}

histogram_calls <- function(s, cb)
  c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x)),
         call("geom_histogram", bins = as.numeric(s$bins), fill = CHART_SINGLE, colour = "white"),
         call("scale_y_continuous", expand = call("expansion", mult = c(0, 0.05)))),
    if (isTRUE(s$log_x)) list(quote(scale_x_log10())))

box_calls <- function(s, cb) {
  flip = isTRUE(s$.flip)
  main = if (flip) aes_call(x = s$y, y = s$x) else aes_call(x = s$x, y = s$y)
  c(list(call("ggplot", sym("chart_table"), main), call("geom_boxplot", fill = "#F2F2F2", colour = CHART_SINGLE, width = 0.6)),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))),
    if (isTRUE(s$log_y)) list(if (flip) quote(scale_x_log10()) else quote(scale_y_log10())))
}

heatmap_calls <- function(s, cb)
  list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = s$y, fill = value_name(s))),
       call("geom_tile", colour = "white", linewidth = 0.5),
       as.call(c(list(sym("scale_fill_gradientn"), colours = CHART_SEQUENTIAL),
                 if (identical(s$fn, "share")) list(labels = call("label_percent")))))

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
  legend = purrr::compact(list(
    colour = if (!is.null(s$color) && s$family %in% c("dot", "scatter", "bubble") && is.null(s$highlight) && !isTRUE(s$.binned)) cb_label(cb, s$color),
    fill = if (identical(s$family, "heatmap")) value_label(s, cb)
           else if (identical(s$family, "bar") && !is.null(s$color) && is.null(s$highlight)) cb_label(cb, s$color)
           else if (isTRUE(s$.binned)) "Count",
    size = if (identical(s$family, "bubble")) cb_label(cb, s$size)))
  args = c(purrr::compact(list(title = s$title, subtitle = s$subtitle, caption = s$caption)),
           if (flip) list(x = yl, y = xl) else list(x = xl, y = yl), legend)
  as.call(c(list(sym("labs")), args))
}

facet_call <- function(s) {
  if (is.null(s$facet)) return(NULL)
  as.call(c(list(sym("facet_wrap"), call("vars", sym(s$facet))), if (isTRUE(s$free_y)) list(scales = "free_y")))
}

theme_call <- function(s) {
  g = grid_of(s)
  if (identical(g, "y")) quote(chart_theme()) else call("chart_theme", grid = g)
}

# The plot's layers, as calls, from the spec as the lint left it and the codebook.
plot_calls <- function(s, cb) {
  layers = switch(s$family, bar = bar_calls(s, cb), dot = dot_calls(s, cb), line = , slope = line_calls(s, cb),
                  scatter = , bubble = scatter_calls(s, cb), histogram = histogram_calls(s, cb), box = box_calls(s, cb),
                  heatmap = heatmap_calls(s, cb))
  c(layers, purrr::compact(list(facet_call(s), labs_call(s, cb), theme_call(s))))
}

plus_call <- function(calls) purrr::reduce(calls[-1], function(acc, cl) call("+", acc, cl), .init = calls[[1]])

# The ggplot for a spec. Runs the defaults, the check, the table and the lint itself, so one call
#   is enough. Attributes: notes (the lint's sentences), spec (the spec as drawn) and table.
spec_plot <- function(spec, data, cb) {
  s = spec_defaults(spec_public(spec))
  why = spec_check(s, cb)
  if (length(why)) spec_fail(paste(why, collapse = " "))
  table = spec_table(s, data, cb)
  lint = spec_lint(s, cb, table)
  p = eval(plus_call(plot_calls(lint$spec, cb)), spec_env(chart_table = table))
  attr(p, "notes") = lint$notes
  attr(p, "spec") = lint$spec
  attr(p, "table") = table
  p
}
