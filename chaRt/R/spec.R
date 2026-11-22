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
SPEC_PANEL_MIN_IN <- 1.55    # a drawing made for a screen (spec_plot's `web`) gives a panel of small multiples at least this much width
SPEC_BARE_INCHES <- 0.8      # what a drawing with no title, subtitle or source line needs less height than one with them
SPEC_NARROW_IN <- 4.5        # a drawing made for a screen narrower than this puts an annotation's words on lines of their own
SPEC_FEW_BREAKS <- 3L        # the breaks a narrow drawing asks of a continuous x axis
SPEC_FIT_TRIM_N <- 100L      # a fitted curve on this many rows or more is drawn only ...
SPEC_FIT_TRIM <- c(0.01, 0.99) # ... between these percentiles of x (it is fitted on every row)
SPEC_FIT_POINTS <- 80L       # points the trimmed curve is drawn at
SPEC_FIT_MIN_DISTINCT <- 10L # a group whose x has fewer different values than this gets no curve
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
SPEC_LABELS <- c("auto", "on", "off")
SPEC_ANNOTATE <- c("highest", "lowest", "first", "latest")
SPEC_ANNOTATE_PANELS <- 6L   # a line chart in more panels than this marks no point (one mark in each panel would crowd it)
SPEC_ANNOTATE_MAX <- 2L      # kinds an annotate may hold
SPEC_LABEL_MARKS <- 12L      # labels auto: values on the marks of a bar or dot chart of at most this many marks, with no panels
SPEC_LABEL_SERIES <- 7L      # ... names (and values) at the ends of a line chart of at most this many series
SPEC_LABEL_NAMES <- 8L       # ... names on the highlighted points of a scatter or bubble, when the highlight names at most this many
SPEC_LABEL_MM <- 3.5         # the size of every label R writes, in mm
SPEC_LABEL_CHARS <- 24L      # an end label carries its value when its name and value take at most this many characters
SPEC_CAPTION_WIDTH <- 95L    # the source line breaks past this many characters
SPEC_OPS_WORDS <- c("==" = "is", "!=" = "is not", ">" = "is more than", ">=" = "is at least", "<" = "is less than", "<=" = "is at most",
                    "in" = "is one of")

SPEC_FAMILIES <- c("bar", "dot", "line", "slope", "scatter", "bubble", "histogram", "box", "heatmap")
SPEC_FNS <- c("none", "count", "share", "sum", "mean", "median")
SPEC_OPS <- c("==", "!=", ">", ">=", "<", "<=", "in")
SPEC_SORTS <- c("value_desc", "value_asc", "level_order", "alphabetical")
SPEC_FITS <- c("none", "loess", "linear")
SPEC_FIELDS <- c("family", "x", "y", "color", "size", "facet", "fn", "filter", "top_n", "sort", "log_x", "log_y",
                 "fit", "rug", "bins", "free_y", "highlight", "title", "subtitle", "caption", "x_label", "y_label",
                 "interactive", "rule", "say", "midpoint", "labels", "annotate")
SPEC_COLUMN_FIELDS <- c("x", "y", "color", "size", "facet")
SPEC_TEXT_FIELDS <- c("title", "subtitle", "caption", "x_label", "y_label", "rule", "say")
SPEC_FLAG_FIELDS <- c("log_x", "log_y", "rug", "free_y", "interactive")

# Fields the lint adds; never accepted from outside.
SPEC_LINT_FIELDS <- c(".flip", ".alpha", ".binned", ".jitter", ".negative", ".labels", ".legend_order", ".cell_labels", ".top_n",
                      ".fit_range", ".n_colours", ".annotate", ".value_labels", ".names", ".label_rows", ".widget_rows", ".repel",
                      ".end_value", ".source", ".widget_left_out", ".end_room", ".x_range", ".value_room", ".value_axis_bare", ".rug_floor",
                      ".fig_width", ".fig_height", ".bare", ".few_breaks", ".facet_cols")

# What the plotly tooltip shows: the plotted values.
SPEC_TOOLTIP <- c("x", "y", "colour", "fill", "size")


# ---- small helpers ----------------------------------------------------------------------------

spec_fail <- function(msg) stop(errorCondition(msg, class = "spec_error", call = NULL))

is_text1 <- function(x) is.character(x) && length(x) == 1L && !is.na(x)
is_flag1 <- function(x) is.logical(x) && length(x) == 1L && !is.na(x)
is_whole1 <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x) && x == round(x)

cb_entry <- function(cb, name) purrr::detect(cb$columns, function(e) identical(e$name, name))
cb_label <- function(cb, name) cb_entry(cb, name)$label %||% name

# A column's name as a title on the chart (Phase 7b): its label in the data dictionary; where it has none (the label is still the
#   column name), the name with underscores as spaces and a capital first letter ("unit_price" as "Unit price"). `capital =
#   FALSE` for a name inside a phrase ("Total unit price").
col_title <- function(cb, name, capital = TRUE) {
  l = cb_label(cb, name)
  if (!identical(l, name) || !is.character(l)) return(l)
  l = gsub("_", " ", l, fixed = TRUE)
  if (capital) paste0(toupper(substring(l, 1, 1)), substring(l, 2)) else l
}

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
  s = purrr::reduce(names(d), function(s, k) { if (is.null(s[[k]]) && !is.null(d[[k]])) s[[k]] = d[[k]]; s }, .init = spec)
  # YAML 1.1, which the yaml package follows, reads a bare on or off as TRUE or FALSE: for `labels` they mean on and off.
  if (is_flag1(s$labels)) s$labels = if (s$labels) "on" else "off"
  s
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
  highlight = c("bar", "dot", "line", "slope", "scatter", "bubble"),
  labels = c("bar", "dot", "line", "slope", "scatter", "bubble", "heatmap"),
  annotate = c("bar", "dot", "line", "scatter", "bubble"))

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
  max_colours = palette_groups_max(palette)
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
    check_highlight(s, cb), check_labels(s), check_annotate(s))
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
        labels = paste0("one of ", paste(SPEC_LABELS, collapse = ", "), ": whether R writes values on the marks. auto: on a bar or dot chart of at most ",
                        SPEC_LABEL_MARKS, " marks with no panels, at the end of each line of a line chart of at most ", SPEC_LABEL_SERIES,
                        " lines, and the names of the highlighted points of a scatter or bubble when at most ", SPEC_LABEL_NAMES,
                        "; on: whenever the chart can; off: none"),
        annotate = paste0("a list of at most ", SPEC_ANNOTATE_MAX, " of ", paste(SPEC_ANNOTATE, collapse = ", "),
                          ": R finds the point, marks it and writes its value; bar and dot take highest or lowest, scatter and bubble the highest or ",
                          "lowest y, line any of them (for several lines, the highlighted one, else the one with the highest value); never write the text"),
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
  list2env(list(chart_number = fact_num, chart_count = fact_count, chart_fixed = fact_fixed), envir = e)
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
  data_checks(s, base, palette_groups_max(palette))
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

# Whether a curve can be fitted to one group's rows as geom_smooth() fits it, on the scales' own
#   values: "few" when x has fewer than SPEC_FIT_MIN_DISTINCT different values, "failed" when the
#   fit or its prediction raises a warning or an error, otherwise "ok".
fit_works <- function(s, x, y) {
  keep = (!isTRUE(s$log_x) | x > 0) & (!isTRUE(s$log_y) | y > 0)
  x = if (isTRUE(s$log_x)) log10(x[keep]) else x[keep]
  y = if (isTRUE(s$log_y)) log10(y[keep]) else y[keep]
  if (length(unique(x)) < SPEC_FIT_MIN_DISTINCT) return("few")
  d = data.frame(x = x, y = y)
  ok = tryCatch({
    f = if (identical(s$fit, "linear")) stats::lm(y ~ x, d) else stats::loess(y ~ x, d)
    all(is.finite(stats::predict(f, data.frame(x = seq(min(x), max(x), length.out = SPEC_FIT_POINTS)))))
  }, warning = function(w) FALSE, error = function(e) FALSE)
  if (isTRUE(ok)) "ok" else "failed"
}

# Where a fitted curve is drawn. It is fitted on every row of its group (a colour, a panel, or both)
#   and drawn only between SPEC_FIT_TRIM percentiles of x within each group of SPEC_FIT_TRIM_N rows
#   or more; a group that cannot be fitted (fit_works()) gets no curve. Returns list(groups =
#   list(list(keys, range)), skip = list(list(keys, why)), rest), keys naming the group's values
#   (NULL with no groups), skip the groups with no curve and rest TRUE when other groups are drawn
#   untrimmed in one layer; NULL when no group is trimmed or left out.
fit_ranges <- function(s, table) {
  if (!s$family %in% c("scatter", "bubble") || identical(s$fit, "none")) return(NULL)
  q = function(x) signif(stats::quantile(x, SPEC_FIT_TRIM, names = FALSE), 4)
  keys = unique(c(if (!isTRUE(s$.binned) && is.null(s$highlight)) s$color, s$facet))
  parts = if (!length(keys)) list(as.data.frame(table))
          else unname(split(as.data.frame(table), lapply(keys, function(k) as.character(table[[k]])), drop = TRUE))
  plan = purrr::map(parts, function(d)
    list(keys = if (length(keys)) purrr::set_names(purrr::map(keys, function(k) as.character(d[[k]][1])), keys),
         why = fit_works(s, d[[s$x]], d[[s$y]]),
         range = if (nrow(d) >= SPEC_FIT_TRIM_N) q(d[[s$x]])))
  ok = purrr::keep(plan, function(g) identical(g$why, "ok"))
  trimmed = purrr::keep(ok, function(g) !is.null(g$range))
  skip = purrr::discard(plan, function(g) identical(g$why, "ok"))
  if (!length(trimmed) && !length(skip)) return(NULL)
  list(groups = purrr::map(trimmed, function(g) g[c("keys", "range")]), skip = purrr::map(skip, function(g) g[c("keys", "why")]),
       rest = length(ok) > length(trimmed))
}

# The note for each group with no curve.
fit_notes <- function(s, cb) {
  xl = s$x_label %||% cb_label(cb, s$x)
  purrr::map_chr(s$.fit_range$skip, function(g)
    paste0("No curve", if (length(g$keys)) paste0(" for ", paste(unlist(g$keys), collapse = ", ")), ": ",
           if (identical(g$why, "few")) paste0("too few different values of ", xl, ".") else "the curve could not be fitted."))
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
  # a label is as tall in a shorter panel but takes a larger share of it: on a drawing made for a screen the gap grows with it
  #   (SPEC_LABEL_GAP is for the panel of the usual 7 by 4.5, 2.6 inches high)
  grow = if (is.null(s$.fig_width)) 1 else max(1, 2.6 / panel_inches(s, table)[["h"]])
  gap = SPEC_LABEL_GAP * grow * diff(range(table[[v]]))
  groups = if (is.null(panel)) list(ends[[v]]) else split(ends[[v]], ends[[panel]])
  close = any(purrr::map_lgl(groups, function(vals) length(vals) > 1L && any(diff(sort(vals)) < gap)))
  list(fits = !close, order = unique(as.character(ends[[s$color]][order(-ends[[v]])])), ends = ends)
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
    # On a drawing made for a screen the names have to stand side by side in the panel's width (about 0.085 inch a character, and a
    #   little between names), or the chart is drawn sideways, where each name has a line to itself.
    if (!is.null(s$.fig_width) && sum(nchar(labels)) * 0.085 + 0.12 * length(labels) > fig_panel_w(s)) s$.flip = TRUE
  }
  coloured = !is.null(s$color) && !identical(fam, "heatmap") && !identical(s$color, s$facet) && is.null(s$highlight)
  # A slope names its lines at their ends, so it is noted only past the palette's own limit.
  if (coloured && nd(s$color) > (if (identical(fam, "slope")) max_colours else SPEC_COLOURS))
    notes = c(notes, paste0(nd(s$color), " colours are hard to tell apart; highlight the few that matter, or use small multiples (facet)."))
  if (identical(fam, "line") && !is.null(s$color) && nd(s$color) > SPEC_LINES && is.null(s$highlight) && is.null(s$facet))
    notes = c(notes, paste0(nd(s$color), " lines overlap; small multiples (facet) or a highlight of the few that matter would read more easily."))
  # End labels on a line or slope chart only when no two would touch; otherwise a legend, in the
  #   order of the end values.
  #   `labels` decides first: off writes none, auto writes them for at most SPEC_LABEL_SERIES lines (a line chart), on
  #   whenever they fit. The value joins the name when both fit SPEC_LABEL_CHARS (a marked last point always carries it:
  #   lint_marks() merges the mark into the end label).
  mode = s$labels %||% "auto"
  if (fam %in% c("line", "slope") && !is.null(s$color) && !identical(s$color, s$facet)) {
    lab = label_plan(s, table)
    n_lab = if (!is.null(s$highlight)) length(unique(as.character(table[[s$color]][table$highlighted]))) else nd(s$color)
    wanted = !identical(mode, "off") && (identical(mode, "on") || !identical(fam, "line") || n_lab <= SPEC_LABEL_SERIES)
    s$.labels = wanted && lab$fits
    if (isTRUE(s$.labels) && narrow_end_labels(s, lab$ends, v)) s$.labels = FALSE
    if (!s$.labels) {
      many = is.null(s$highlight) && nd(s$color) > max_colours
      if (many) notes = c(notes, if (identical(mode, "off")) paste0("Labels are off and the ", nd(s$color), " lines are too many to colour; highlight a few.")
                                 else if (!wanted) paste0("The ", nd(s$color), " lines are too many to label at their ends and to colour; highlight a few.")
                                 else paste0("The ", nd(s$color), " lines end too close together to be labelled and are too many to colour; highlight a few."))
      else {
        s$.legend_order = lab$order
        if (!wanted && !identical(mode, "off"))
          notes = c(notes, paste0(n_lab, " lines are too many to label at their ends; a legend names them (labels: on writes the names at the line ends)."))
      }
    } else {
      text = paste0(as.character(lab$ends[[s$color]]), "  ", fact_value_fmt(s)(lab$ends[[v]]))
      s$.end_value = all(nchar(text) <= SPEC_LABEL_CHARS)
      s$.end_room = end_room(if (isTRUE(s$.end_value)) text else as.character(lab$ends[[s$color]]), fig_panel_w(s))
    }
  }
  # A line chart's first and last x, so its time axis prints no tick past the data (time_scale()). Dates as text.
  if (identical(fam, "line") && !is.null(s$x) && nrow(table)) {
    xr = range(table[[s$x]], na.rm = TRUE)
    s$.x_range = if (inherits(xr, "Date")) format(xr) else if (is.numeric(xr)) as.numeric(xr)
  }
  # A line chart of one series, in no panels, writes its last value at the end.
  if (identical(fam, "line") && is.null(s$color) && is.null(s$facet)) {
    s$.labels = !identical(mode, "off")
    s$.end_value = TRUE
    s$.end_room = end_room(fact_value_fmt(s)(table[[v]][which.max(as.numeric(table[[s$x]]))]), fig_panel_w(s))
    if (isTRUE(s$.labels) && !is.null(s$.fig_width) && s$.end_room > SPEC_END_ROOM_NARROW && s$.fig_width < SPEC_NARROW_IN) {
      s$.labels = FALSE
      s$.end_value = NULL
      s$.end_room = NULL
    }
  }
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
  notes = c(notes, fit_notes(s, cb))
  # How many colours the drawn table needs (after the filter and top_n), so a palette is chosen for
  #   what is shown, not for every value the codebook lists.
  if (!is.null(s$color) && !identical(fam, "heatmap")) s$.n_colours = nd(s$color)
  # What is written on the marks (labels, annotate), and the source line under the chart unless the analyst wrote a caption.
  m = lint_marks(s, cb, table)
  s = m$spec
  notes = c(notes, m$notes)
  if (is.null(s$caption)) {
    s$caption = source_line(s, cb, table)
    s$.source = TRUE
  } else notes = c(notes, "Your caption replaces the source line.")
  list(spec = s, notes = notes)
}


# ---- values and marks written by R (Phase 7 Part C) -------------------------------------------------

# The words on a chart that are numbers or names of the data are written by R from the plotted table, never by a
#   model, and in the same way as the facts write them (fact_num(), fact_count(), fact_fixed()): a label and a
#   headline cannot disagree. `labels` (auto, on, off) says whether values are written on the marks; `annotate`
#   (up to two of highest, lowest, first, latest) marks a point and writes its value.

# Whether ggrepel is installed (find.package(), as for paletteer). One function, so a test can stand in for a
#   machine without it. With it, labels that would collide are moved apart; without it, the ones that would
#   collide are left out and the notes say so.
ggrepel_installed <- function() length(find.package("ggrepel", quiet = TRUE)) > 0L

# The kinds of annotation a family can take: a bar or dot marks its highest or lowest value, a scatter or bubble
#   its highest or lowest y, a line any of the four (it has an order); nothing else marks a point.
annotate_kinds <- function(fam) switch(fam, bar = , dot = , scatter = , bubble = c("highest", "lowest"), line = SPEC_ANNOTATE, character(0))

check_labels <- function(s) {
  if (is.null(s$labels)) return(NULL)
  if (!is_text1(s$labels) || !s$labels %in% SPEC_LABELS) return(paste0("labels must be one of ", paste(SPEC_LABELS, collapse = ", "), "."))
  if (!identical(s$labels, "on")) return(NULL)
  if (s$family %in% c("histogram", "box")) return(paste0("labels: a ", s$family, " chart has no marks to write values on; use auto or off."))
  if (s$family %in% c("scatter", "bubble") && is.null(s$highlight))
    return("labels: a scatter or bubble writes names only on highlighted points; give a highlight, or use auto or off.")
  NULL
}

check_annotate <- function(s) {
  a = s$annotate
  if (is.null(a)) return(NULL)
  v = values_of(a)
  kinds = paste(SPEC_ANNOTATE, collapse = ", ")
  if (!length(v)) return(NULL)      # an empty list marks nothing
  if (!is.character(v) || !length(v) || anyNA(v))
    return(paste0("annotate must be a list of at most ", SPEC_ANNOTATE_MAX, " of ", kinds, "."))
  bad = setdiff(v, SPEC_ANNOTATE)
  if (length(bad))
    return(paste0("annotate: ", paste0("'", bad, "'", collapse = ", "), if (length(bad) == 1L) " is not a kind" else " are not kinds",
                  "; use at most ", SPEC_ANNOTATE_MAX, " of ", kinds, "."))
  if (anyDuplicated(v) || length(v) > SPEC_ANNOTATE_MAX)
    return(paste0("annotate takes at most ", SPEC_ANNOTATE_MAX, " different kinds of ", kinds, "."))
  allowed = annotate_kinds(s$family)
  no = setdiff(v, allowed)
  if (!length(no)) return(NULL)
  if (!length(allowed)) return(paste0("annotate: a ", s$family, " chart cannot mark a highest, lowest, first or latest value."))
  paste0("annotate: a ", s$family, " chart can mark its ", or_list(allowed), " value, not its ", or_list(no), " one",
         if (s$family %in% c("scatter", "bubble")) " (highest and lowest refer to y; a scatter has no order)"
         else " (first and latest need a line chart, which has an order)", ".")
}

# A number as a call, the way the facts write the plotted value of the spec (fact_value_fmt()): a count whole, a
#   share as a percentage, anything else to three significant digits, with thousands separators where the
#   facts have them. The functions are chart_count(), chart_fixed() and chart_number() (spec_env() binds them to the
#   facts' own; the written code carries a copy).
value_text_call <- function(s, col) {
  comma = s$family %in% c("bar", "dot", "line", "slope", "heatmap")
  switch(s$fn %||% "none",
    count = call("chart_count", sym(col)),
    share = call("chart_fixed", call("*", 100, sym(col)), 1L, "%"),
    if (comma) call("chart_number", sym(col)) else call("chart_number", sym(col), comma = FALSE))
}

# The text a line's x gives an annotation, the way the facts write a time (fact_time()).
x_text_call <- function(s, kind) switch(kind, text = call("as.character", sym(s$x)),
                                        whole = call("format", sym(s$x), scientific = FALSE, trim = TRUE),
                                        call("chart_number", sym(s$x), comma = FALSE))

# Which lines of a line chart the facts describe (fact_lines_keep()), and so which one an annotation may name:
#   the highlighted series, or without a highlight the series with the highest value among those described.
annotation_series <- function(s, t) {
  v = value_name(s)
  series = fact_split(t, s$color)
  chg = purrr::map_dbl(series, function(d) { d = d[order(d[[s$x]]), , drop = FALSE]; d[[v]][nrow(d)] - d[[v]][1] })
  hl = purrr::map_lgl(series, function(d) isTRUE(any(d$highlighted)))
  keep = fact_lines_keep(chg, hl)
  pool = if (any(hl)) which(hl) else keep
  names(series)[pool][which.max(purrr::map_dbl(series[pool], function(d) max(d[[v]])))]
}

# The annotations of a chart, resolved against the table: one entry for each point marked (two kinds that fall on the
#   same point share one entry), with the row of the table, the series it is in (a line with colours), how its text
#   sits against the point (hjust, vjust) and how its x is written. NULL when there is none.
#   A line chart in panels (Phase 7b) marks the point in each panel, from that panel's rows, when there are at most
#   SPEC_ANNOTATE_PANELS panels (each entry then carries its panel); with more, none (lint_marks() says why).
annotation_groups <- function(s, cb, t, whole = t) {
  fam = s$family
  kinds = as.character(values_of(s$annotate))
  if (!length(kinds) || !length(annotate_kinds(fam))) return(NULL)
  if (identical(fam, "line") && !is.null(s$facet)) {
    panels = unique(as.character(t[[s$facet]]))
    if (length(panels) > SPEC_ANNOTATE_PANELS) return(NULL)
    inner = s
    inner$facet = NULL
    if (identical(s$color, s$facet)) inner$color = NULL     # one line in each panel
    return(unlist(purrr::map(panels, function(k) {
      at = which(as.character(t[[s$facet]]) == k)
      purrr::map(annotation_groups(inner, cb, t[at, , drop = FALSE], whole = t), function(g) { g$row = at[[g$row]]; g$panel = k; g })
    }), recursive = FALSE))
  }
  v = if (fam %in% c("scatter", "bubble")) s$y else value_name(s)
  series = if (identical(fam, "line") && !is.null(s$color) && !identical(s$color, s$facet)) annotation_series(s, t)
  d = t
  d$.row = seq_len(nrow(t))
  if (!is.null(series)) d = d[as.character(d[[s$color]]) == series, , drop = FALSE]
  if (identical(fam, "line")) d = d[order(d[[s$x]]), , drop = FALSE]
  at = function(k) switch(k, highest = which.max(d[[v]]), lowest = which.min(d[[v]]), first = 1L, latest = nrow(d))
  rows = purrr::map_int(kinds, at)
  flip = isTRUE(s$.flip)
  # where a point stands in its panel, against the scales of the whole chart (panels share them)
  xs = if (!is.null(s$x) && fam %in% c("line", "scatter", "bubble")) as.numeric(whole[[s$x]])
  ylog = isTRUE(s$log_y) && fam %in% c("line", "scatter", "bubble")
  ys = if (ylog) log10(whole[[v]]) else as.numeric(whole[[v]])
  x_text = if (identical(fam, "line")) { x = t[[s$x]]; if (inherits(x, c("Date", "POSIXt"))) "text" else if (all(x == round(x))) "whole" else "number" }
  # Where the text goes (Phase 7b): wholly inside the panel. Across the panel it runs away from the nearer edge: from a
  #   point (or bar) in the left third it runs right (hjust 0), in the right third left (hjust 1), in the middle it is
  #   centred. Up and down: a point near the top of the panel has its text below it, one near the bottom above it (clear of
  #   the bottom edge and of a rug), others above for a highest and below for a lowest. A bar's text sits past the bar's end.
  lev = if (fam %in% c("bar", "dot")) nlevels(t[[s$x]]) %||% length(unique(t[[s$x]]))
  purrr::map(unname(split(seq_along(kinds), factor(rows, levels = unique(rows)))), function(i) {
    r = rows[[i[[1]]]]
    val = d[[v]][r]
    # a bar's or dot's words sit past its end (below or left only for a negative value); a point's lowest sits below it
    low = if (fam %in% c("bar", "dot")) val < 0 else identical(kinds[[i[[1]]]], "lowest")
    across = if (fam %in% c("bar", "dot")) (as.integer(factor(d[[s$x]], levels = levels(factor(t[[s$x]]))))[r] - 0.5) / max(1L, lev)
             else if (!is.null(xs) && diff(range(xs)) > 0) (as.numeric(d[[s$x]][r]) - min(xs)) / diff(range(xs)) else 0.5
    up = if (diff(range(ys, na.rm = TRUE)) > 0) ((if (ylog) log10(val) else val) - min(ys, na.rm = TRUE)) / diff(range(ys, na.rm = TRUE)) else 0.5
    side = if (across < 1 / 3) 0 else if (across > 2 / 3) 1 else 0.5
    # A tie: the point marked is one of several with the same highest or lowest value (in the same series).
    tied = if (kinds[[i[[1]]]] %in% c("highest", "lowest")) sum(d[[v]] == val, na.rm = TRUE) else 1L
    # an upright bar or dot has its words centred over it, on lines of their own (annotation_lines()), so they never run over
    #   a neighbour
    hj = if (fam %in% c("bar", "dot")) (if (flip) (if (low) 1.15 else -0.15) else 0.5) else side
    vj = if (fam %in% c("bar", "dot")) (if (flip) 0.5 else if (low) (if (identical(fam, "bar")) 1.4 else 2.2) else (if (identical(fam, "dot")) -1.2 else -0.4))
         else if (up > 0.85) 2.2 else if (up < 0.15) -1.2 else if (low) 2.2 else -1.2
    list(kinds = kinds[i], row = d$.row[[r]], series = series, x_text = x_text, tied = tied,
         unit = switch(fam, bar = "bars", dot = "dots", "points"), hjust = hj, vjust = vj)
  })
}

# ---- a rough layout, to find the labels that would run into one another ----------------------------------------

# Without ggrepel R cannot move a label, so it leaves out the ones that would collide. It judges from a rough
#   layout of the panel in inches: the room the axes and titles leave, the scales as ggplot2 expands them, and the
#   width of a label from its number of characters. An annotation is always kept; any other label is left out when
#   it would meet a label kept before it (the larger values first) or a mark other than its own. The layout is an
#   estimate, so labels that only touch may stay.
SPEC_LABEL_CHAR_IN <- 0.6 * SPEC_LABEL_MM * 2.845 / 72     # one character of a label, in inches
SPEC_LABEL_HEIGHT_IN <- 1.2 * SPEC_LABEL_MM * 2.845 / 72   # one line of a label
SPEC_LABEL_PAD_IN <- 0.03
# One character of an end label for the room it is given (end_room()): the bundled sans at the label's size measures about
#   0.063 inches a character (Phase 7b, from drawn charts), so this is a little over; the estimate above, for collisions, is wider.
SPEC_LABEL_CHAR_END_IN <- 0.5 * SPEC_LABEL_MM * 2.845 / 72

label_box <- function(ax, ay, text, hjust, vjust) {
  lines = strsplit(as.character(text), "\n", fixed = TRUE)
  w = purrr::map_dbl(lines, function(l) max(nchar(l), 0L)) * SPEC_LABEL_CHAR_IN
  h = pmax(1L, lengths(lines)) * SPEC_LABEL_HEIGHT_IN
  x0 = ax - hjust * w
  y0 = ay - vjust * h
  data.frame(x0 = x0, x1 = x0 + w, y0 = y0, y1 = y0 + h)
}

boxes_meet <- function(a, b)
  a$x0 < b$x1 + SPEC_LABEL_PAD_IN && b$x0 < a$x1 + SPEC_LABEL_PAD_IN && a$y0 < b$y1 + SPEC_LABEL_PAD_IN && b$y0 < a$y1 + SPEC_LABEL_PAD_IN

# The rows (owners) of the boxes that are kept and are not fixed. `boxes`: x0 x1 y0 y1, owner (the row of the table the label
#   belongs to) and fixed, in order of importance; `marks`: x0 x1 y0 y1 and owner. `panel` is the panel of each row of the
#   table; boxes of different panels never meet.
label_keep <- function(boxes, marks, panel) {
  one = function(b, m) {
    kept = purrr::reduce(seq_len(nrow(b)), function(kept, i) {
      if (isTRUE(b$fixed[[i]])) return(c(kept, i))
      over_label = any(purrr::map_lgl(kept, function(j) boxes_meet(b[i, , drop = FALSE], b[j, , drop = FALSE])))
      over_mark = any(purrr::map_lgl(seq_len(nrow(m)), function(k) !identical(m$owner[[k]], b$owner[[i]]) && boxes_meet(b[i, , drop = FALSE], m[k, , drop = FALSE])))
      if (over_label || over_mark) kept else c(kept, i)
    }, .init = integer(0))
    b$owner[intersect(kept, which(!b$fixed))]
  }
  sort(unlist(purrr::map(unique(panel), function(p) {
    inside = function(d) d[panel[d$owner] == p, , drop = FALSE]
    b = inside(boxes)
    if (nrow(b)) one(b, inside(marks)) else integer(0)
  }), use.names = FALSE))
}

# The size of one panel in inches, from the figure's size and what the axes, titles and legend take.
panel_inches <- function(s, t) {
  size = spec_size(s, t)
  panels = if (!is.null(s$facet)) length(unique(t[[s$facet]])) else 1L
  across = fig_across(s, panels)
  rows = ceiling(panels / across)
  left = if (isTRUE(s$.flip) && !is.null(s$x)) 0.5 + 0.075 * max(nchar(as.character(t[[s$x]]))) else 0.9
  c(w = max(0.5, (size[["width"]] - left - 0.2) / across), h = max(0.5, (size[["height"]] - (if (isTRUE(s$.bare)) 1.9 - SPEC_BARE_INCHES else 1.9)) / rows))
}

# Which panel each row of the table is in.
row_panels <- function(s, t) if (!is.null(s$facet)) as.character(t[[s$facet]]) else rep("all", nrow(t))

# The rows of a bar or dot chart whose value label fits. `rows` take a value label; `fixed` are the rows with an
#   annotation (text `ann_text`, placed by `hjust` and `vjust`), which are always kept and keep other labels off them.
fit_value_labels <- function(s, t, rows, fixed, ann_text, hjust, vjust) {
  fam = s$family; v = value_name(s); flip = isTRUE(s$.flip)
  fmt = fact_value_fmt(s)
  vals = t[[v]]
  size = panel_inches(s, t)
  lev = nlevels(t[[s$x]])
  k = if (identical(fam, "bar") && !is.null(s$color)) length(unique(t[[s$color]])) else 1L
  j = if (k > 1L) as.integer(factor(t[[s$color]])) else 1L
  pos = as.integer(t[[s$x]]) + (j - (k + 1) / 2) * 0.8 / k
  lo = min(0, vals); hi = max(0, vals)
  span = if (hi > lo) hi - lo else 1
  lim = if (identical(fam, "bar")) c(lo - if (lo < 0) 0.12 * span else 0, hi + 0.12 * span)
        else { sp = if (max(vals) > min(vals)) max(vals) - min(vals) else 1; c(min(vals) - 0.05 * sp, max(vals) + 0.12 * sp) }
  along = if (flip) size[["w"]] else size[["h"]]
  across = if (flip) size[["h"]] else size[["w"]]
  end = (vals - lim[1]) / diff(lim) * along
  mid = (pos - 0.4) / (lev + 0.2) * across
  zero = (0 - lim[1]) / diff(lim) * along
  ax = if (flip) end else mid
  ay = if (flip) mid else end
  half = if (identical(fam, "bar")) 0.75 / k / 2 / (lev + 0.2) * across else 0.06
  marks = if (identical(fam, "dot")) data.frame(x0 = ax - 0.06, x1 = ax + 0.06, y0 = ay - 0.06, y1 = ay + 0.06, owner = seq_len(nrow(t)))
          else data.frame(x0 = if (flip) pmin(zero, end) else mid - half, x1 = if (flip) pmax(zero, end) else mid + half,
                          y0 = if (flip) mid - half else pmin(zero, end), y1 = if (flip) mid + half else pmax(zero, end), owner = seq_len(nrow(t)))
  owner = c(fixed, rows)
  boxes = cbind(label_box(ax[owner], ay[owner], c(ann_text, fmt(vals[rows])), c(hjust, rep(if (flip) -0.15 else 0.5, length(rows))),
                          c(vjust, rep(if (flip) 0.5 else if (identical(fam, "dot")) -1.2 else -0.4, length(rows)))),
                owner = owner, fixed = c(rep(TRUE, length(fixed)), rep(FALSE, length(rows))))
  boxes = boxes[order(!boxes$fixed, -abs(vals[boxes$owner])), , drop = FALSE]
  label_keep(boxes, marks, row_panels(s, t))
}

# The highlighted rows (`named`) of a scatter or bubble whose name fits, with the annotated rows (`fixed`, text `ann_text`)
#   always kept.
fit_point_labels <- function(s, t, named, fixed, ann_text, hjust, vjust) {
  size = panel_inches(s, t)
  tx = function(x, log) if (isTRUE(log)) log10(x) else x
  x = tx(t[[s$x]], s$log_x); y = tx(t[[s$y]], s$log_y)
  grow = function(r, up) { d = if (diff(r) > 0) diff(r) else 1; c(min(r) - 0.05 * d, max(r) + (if (up) 0.12 else 0.05) * d) }
  xl = grow(range(x), FALSE); yl = grow(range(y), length(fixed) > 0L)
  ax = (x - xl[1]) / diff(xl) * size[["w"]]
  ay = (y - yl[1]) / diff(yl) * size[["h"]]
  marks = data.frame(x0 = ax - 0.05, x1 = ax + 0.05, y0 = ay - 0.05, y1 = ay + 0.05, owner = seq_len(nrow(t)))
  owner = c(fixed, named)
  boxes = cbind(label_box(ax[owner], ay[owner], c(ann_text, as.character(t[[s$highlight$column]][named])),
                          c(hjust, ifelse(x[named] > mean(range(x)), 1.15, -0.15)), c(vjust, rep(0.5, length(named)))),
                owner = owner, fixed = c(rep(TRUE, length(fixed)), rep(FALSE, length(named))))
  label_keep(boxes, marks, row_panels(s, t))
}

# The text of an annotation as a string, for the layout: the same words and numbers the written code makes.
annotation_text <- function(g, s, t) {
  fam = s$family
  v = if (fam %in% c("scatter", "bubble")) s$y else value_name(s)
  fmt = fact_value_fmt(s)
  words = paste(g$kinds, collapse = " and ")
  tie = annotation_tie(g)
  if (annotation_lines(s)) return(paste0(toupper(substring(words, 1, 1)), substring(words, 2), "\n", fmt(t[[v]][g$row]), if (nzchar(tie)) paste0("\n", sub("^, ", "", tie)),
                                         if (identical(fam, "line")) paste0("\n(", fact_time(t[[s$x]][g$row]), ")")))
  paste0(toupper(substring(words, 1, 1)), substring(words, 2), ": ", fmt(t[[v]][g$row]),
         if (identical(fam, "line")) paste0(" (", fact_time(t[[s$x]][g$row]), ")"), tie)
}

# Whether an annotation's words go on lines of their own (the kind, the value, a tie): over an upright bar or dot, where one
#   line would be wider than the mark and run over its neighbours.
annotation_lines <- function(s) (s$family %in% c("bar", "dot") && !isTRUE(s$.flip)) || (!is.null(s$.fig_width) && s$.fig_width < SPEC_NARROW_IN)

# The words a marked point adds to its line's end label: the kinds other than latest (the end is the latest), and a tie.
end_words <- function(g) {
  k = setdiff(g$kinds, "latest")
  paste0(if (length(k)) paste0(", ", paste(k, collapse = " and ")), annotation_tie(g))
}

# The words that say a marked point is one of several tied at the highest or lowest value: ", one of 2 points".
annotation_tie <- function(g) if ((g$tied %||% 1L) > 1L) paste0(", one of ", g$tied, " ", g$unit %||% "points") else ""

# What a chart writes on its marks, decided from the table (Part C): the annotations, the value labels of a bar or
#   dot, the names on a scatter's or bubble's highlighted points, and the cell values of a heatmap; the lint fields
#   .annotate, .value_labels, .label_rows (the rows labelled in the static chart), .widget_rows (the ones the
#   interactive version labels: no ggrepel there), .repel and .n_rows. Returns list(spec, notes).
lint_marks <- function(s, cb, table) {
  fam = s$family
  mode = s$labels %||% "auto"
  t = as.data.frame(table)
  n = nrow(t)
  notes = character(0)
  s$.repel = ggrepel_installed()
  s$.annotate = annotation_groups(s, cb, t)
  # A line chart in panels: one mark in each panel when there are at most SPEC_ANNOTATE_PANELS, each only if its number is in the
  #   chart's facts (which describe each panel's lines); with more panels, none.
  if (identical(fam, "line") && !is.null(s$facet) && length(values_of(s$annotate))) {
    np = length(unique(as.character(t[[s$facet]])))
    if (np > SPEC_ANNOTATE_PANELS)
      notes = c(notes, paste0("No point is marked: the chart has ", np, " panels, and a mark is drawn in each panel only when there are at most ",
                              SPEC_ANNOTATE_PANELS, "."))
    else if (length(s$.annotate)) {
      facts = spec_facts(s, table, cb)$text
      fmt = fact_value_fmt(s)
      found = purrr::map_lgl(s$.annotate, function(g) grepl(fmt(t[[value_name(s)]][g$row]), facts, fixed = TRUE))
      if (!all(found))
        notes = c(notes, paste0("The mark in ", or_list(paste0("the ", purrr::map_chr(s$.annotate[!found], "panel"), " panel")),
                                " was not drawn: its value is not among the chart's facts."))
      s$.annotate = s$.annotate[found]
    }
  }
  # A marked point that is the last point of a line with an end label: the end label carries the words ("Islands  116,000,
  #   highest") and no second text is drawn; the ring stays (Phase 7b).
  if (identical(fam, "line") && isTRUE(s$.labels) && length(s$.annotate)) {
    named = !is.null(s$color) && !identical(s$color, s$facet)
    last_of = function(r) {
      same = if (named) as.character(t[[s$color]]) == as.character(t[[s$color]][r]) else rep(TRUE, n)
      if (!is.null(s$facet)) same = same & as.character(t[[s$facet]]) == as.character(t[[s$facet]][r])
      as.numeric(t[[s$x]][r]) == max(as.numeric(t[[s$x]][same]))
    }
    labelled = function(r) is.null(s$highlight) || isTRUE(t$highlighted[r])
    s$.annotate = purrr::map(s$.annotate, function(g) {
      g$merged = last_of(g$row) && labelled(g$row)
      if (g$merged) g$at = list(color = if (named) as.character(t[[s$color]][g$row]), facet = if (!is.null(s$facet)) as.character(t[[s$facet]][g$row]))
      g
    })
    if (any(purrr::map_lgl(s$.annotate, "merged"))) {
      ends = purrr::keep(seq_len(n), function(r) last_of(r) && labelled(r))
      txt = purrr::map_chr(ends, function(r) {
        g = purrr::detect(s$.annotate, function(g) isTRUE(g$merged) && g$row == r)
        paste0(if (named) paste0(as.character(t[[s$color]][r]), "  "), if (isTRUE(s$.end_value) || !is.null(g)) fact_value_fmt(s)(t[[value_name(s)]][r]),
               if (!is.null(g)) end_words(g))
      })
      s$.end_room = end_room(txt, fig_panel_w(s))
    }
  }
  # A rug draws ticks along the bottom and left edges, 3% of the panel deep; a label moved by ggrepel is kept above and right
  #   of a band twice that deep (the axes' expansion: 0.12 on y with an annotation, 0.05 on x). Not on a log axis.
  if (fam %in% c("scatter", "bubble") && isTRUE(s$rug) && length(s$.annotate) && !isTRUE(s$log_x) && !isTRUE(s$log_y)) {
    edge = function(v, mult) { r = range(v, na.rm = TRUE); d = if (diff(r) > 0) diff(r) else 1; r[1] - mult * d + 0.06 * (1 + 2 * mult) * d }
    s$.rug_floor = c(x = signif(edge(t[[s$x]], 0.05), 4), y = signif(edge(t[[s$y]], 0.12), 4))
  }
  ann_rows = purrr::map_int(s$.annotate %||% list(), "row")
  ann_text = purrr::map_chr(s$.annotate %||% list(), function(g) annotation_text(g, s, t))
  ann_h = purrr::map_dbl(s$.annotate %||% list(), "hjust")
  ann_v = purrr::map_dbl(s$.annotate %||% list(), "vjust")
  left_out = function(all, fit) length(setdiff(all, fit))
  # The rows a label layer draws: NULL when it is all of `universe` (every row of the table; for names, every highlighted
  #   row), so the written code needs no row numbers.
  restrict = function(rows, universe) if (setequal(rows, universe)) NULL else as.integer(rows)
  say_left_out = function(k, what, repel_helps)
    paste0(k, if (k == 1L) paste0(" ", what, " was") else paste0(" ", what, "s were"), " left out because ",
           if (k == 1L) "it would" else "they would", " run into another label or a mark",
           if (repel_helps) "; ggrepel, which moves labels apart, is not installed.")
  if (fam %in% c("bar", "dot")) {
    show = identical(mode, "on") || (identical(mode, "auto") && n <= SPEC_LABEL_MARKS && is.null(s$facet))
    if (any(t[[value_name(s)]] < 0)) s$.negative = TRUE
    # Room past the marks' ends for what is written there (Phase 7b): the share of the value axis the longest text standing
    #   past its mark needs (its width on a sideways chart, its height on an upright one), at least the 0.12 always given.
    vals = t[[value_name(s)]]
    if (length(ann_rows) || show) {
      size = panel_inches(s, t)
      along = if (isTRUE(s$.flip)) size[["w"]] else size[["h"]]
      lo = min(0, vals); hi = max(0, vals); span = if (hi > lo) hi - lo else 1
      texts = c(ann_text, if (show) fact_value_fmt(s)(vals[setdiff(seq_len(n), ann_rows)]))
      at = c(vals[ann_rows], if (show) vals[setdiff(seq_len(n), ann_rows)])
      bold = c(rep(1.12, length(ann_rows)), rep(1, length(texts) - length(ann_rows)))
      parts = strsplit(texts, "\n", fixed = TRUE)
      long = if (isTRUE(s$.flip)) purrr::map_dbl(parts, function(l) max(nchar(l))) * SPEC_LABEL_CHAR_IN * bold + 0.08
             else (lengths(parts) + 1.2) * SPEC_LABEL_HEIGHT_IN
      # A text whose mark ends at share a of the value range needs a / (1 + r) + long / P <= 1 of the panel P, with r the room
      #   (expansion is a share of the data's range): r >= a / (1 - long / P) - 1.
      a = abs(at - (if (all(at >= 0)) lo else 0)) / span
      need = if (length(texts)) max(a / pmax(0.2, 1 - long / along) - 1) else 0
      s$.value_room = round(min(2, max(0.12, need + 0.04)), 2)
    }
    cand = setdiff(seq_len(n), ann_rows)
    if (show && n > 0L) {
      fit = fit_value_labels(s, t, cand, ann_rows, ann_text, ann_h, ann_v)
      # ggrepel cannot place a label against a bar (it knows the label's anchor, not the bar), so the value labels of a bar or
      #   dot chart are placed by R, at the end of the mark, with or without it; those that would collide are left out.
      #   Under `auto` a chart that would label some marks and not others reads as if the labelled ones matter more, so
      #   if any label would be left out none is written (and the value axis keeps its grid). Under `on` those that fit are
      #   written and the count is in the notes.
      if (identical(mode, "auto") && left_out(cand, fit)) {
        notes = c(notes, "Values are not written on the marks because some would overlap.")
      } else {
        s$.value_labels = TRUE
        s$.label_rows = restrict(fit, seq_len(n))
        if (left_out(cand, fit)) notes = c(notes, say_left_out(left_out(cand, fit), "value label", FALSE))
        # Every mark carries its value (a value label or an annotation): the value axis keeps its title and loses its
        #   numbers and ticks, which would only repeat them. When any is missing the axis stays whole.
        s$.value_axis_bare = setequal(union(fit, ann_rows), seq_len(n))
      }
    }
  }
  if (fam %in% c("scatter", "bubble") && !is.null(s$highlight)) {
    nh = length(values_of(s$highlight$values))
    named = which(t$highlighted)
    show = identical(mode, "on") || (identical(mode, "auto") && nh <= SPEC_LABEL_NAMES)
    if (identical(mode, "auto") && !show)
      notes = c(notes, paste0("The highlight names ", nh, " values; names are written on the points only for ", SPEC_LABEL_NAMES, " or fewer."))
    if (show && length(named)) {
      fit = fit_point_labels(s, t, named, ann_rows, ann_text, ann_h, ann_v)
      s$.names = TRUE
      if (s$.repel && left_out(named, fit)) s$.widget_left_out = left_out(named, fit)
      s$.widget_rows = restrict(fit, named)
      s$.label_rows = restrict(if (s$.repel) named else fit, named)
      if (!s$.repel && left_out(named, fit)) notes = c(notes, say_left_out(left_out(named, fit), "name", TRUE))
    }
  }
  if (identical(fam, "heatmap")) {
    cells = n <= SPEC_HEAT_LABELS
    if (!identical(mode, "off") && cells) s$.cell_labels = TRUE
    if (identical(mode, "on") && !cells)
      notes = c(notes, paste0("Values are not written in the cells: the chart has ", n, " cells, and at most ", SPEC_HEAT_LABELS, " are labelled."))
  }
  list(spec = s, notes = notes)
}

# The source line R writes into the caption when the analyst has not written one: "Source: <the dictionary's source,
#   else the file name>. <n> rows<; the filter in words><; m left out for missing values>."
source_line <- function(s, cb, table) {
  src = trimws(cb$source %||% "")
  src = if (nzchar(src)) sub("[.]+$", "", src) else cb$file %||% "the data file"
  n = attr(table, "rows_used") %||% nrow(table)
  dropped = attr(table, "rows_dropped") %||% 0L
  parts = c(paste0(fact_count(n), if (n == 1L) " row" else " rows"), filter_phrases(s, cb),
            if (dropped > 0L) paste0(fact_count(dropped), " left out for missing values"))
  paste0("Source: ", src, ". ", paste(parts, collapse = "; "), ".")
}


# ---- the plot --------------------------------------------------------------------------------------

# The colours a chart is drawn with, from the palettes chosen for the report (R/theme.R): qual(n)
#   for groups (at most max; the default palette when the chosen one has fewer than n colours, see
#   palette_for_n(); in a style, a colour too dark to see is swapped for a light one and a colour too near the
#   background is skipped, see palette_usable() in R/theme.R), seq for a
#   continuous fill, div for a fill centred on a midpoint, and the style's own values: single (a series
#   with no groups: the chosen palette's first colour), grey (behind a highlight), fit, outline, box_fill,
#   rug and the values of the font variables its theme uses.
spec_palette <- function(palette = chart_palette_default()) {
  style = palette$style %||% CHART_STYLE_DEFAULT
  st = chart_style(style)
  qual = function(n) chart_palette(n, palette_for_n(n, palette$qualitative, style), style)
  list(qual = qual, max = palette_groups_max(palette),
       seq = chart_sequential(palette$sequential), div = chart_diverging(palette$diverging),
       style = style, single = palette_single(palette_for_n(1L, palette$qualitative, style), style), grey = st$grey, fit = st$fit, outline = st$outline, box_fill = st$box_fill,
       rug = st$text_2, label = st$text_2, strong = st$text, fonts = chart_font_values(chart_theme_calls(style)))
}

# The note for a chart whose groups outnumber the chosen qualitative palette's colours, so it is
#   drawn with the default palette instead; NULL otherwise.
palette_note <- function(s, cb, palette = chart_palette_default()) {
  coloured = !is.null(s$color) && is.null(s$highlight) && !identical(s$family, "heatmap") && !isTRUE(s$.binned)
  if (!coloured) return(NULL)
  n = colour_count(s, cb, s$color)
  q = palette$qualitative
  style = palette$style %||% CHART_STYLE_DEFAULT
  used = palette_for_n(n, q, style)
  usable = palette_usable_max(q, style)
  c(if (!identical(used, q))
      paste0("The palette ", CHART_PALETTES[[q]]$label, " has ", usable, if (usable == 1L) " colour" else " colours",
             if (usable < chart_palette_max(q)) " that show against this style's background" else "", " and this chart needs ", n,
             ", so it is drawn with ", CHART_PALETTES[[used]]$label, "."),
    # The colour-vision check at the number of colours drawn, on the colours actually used (swapped and
    #   skipped ones included), for the palette actually used.
    if (n <= palette_usable_max(used, style) && isTRUE(palette_cvd_used(used, n, style) < CHART_CVD_MARK))
      paste0("Some of these ", n, " colours are hard to tell apart for readers with colour-vision differences."))
}

# The colour-vision result of the first n colours of a qualitative palette as a style draws them: the stored
#   result (palette_cvd_at()) when they are the palette's own first n colours, otherwise computed on the colours
#   used (cvd_gap(); NA without colorspace).
palette_cvd_used <- function(name, n, style = CHART_STYLE_DEFAULT) {
  used = chart_palette(n, name, style)
  own = utils::head(palette_colours(name), n)
  if (identical(toupper(used), toupper(own))) palette_cvd_at(name, n) else round(cvd_gap(used), 1)
}

# How many colours a column needs, from the codebook (and top_n), so the plot and its code can be
#   built without the data.
colour_count <- function(s, cb, col) {
  if (!is.null(s$.n_colours) && identical(col, s$color)) return(s$.n_colours)
  n = cb_entry(cb, col)$distinct
  if (!is.null(s$top_n) && identical(col, ranked_column(s))) min(n, top_of(s)) else n
}

#   `title = TRUE` for a title on the chart: a column with no label is written as col_title() writes it ("Total unit price"); the
#   facts and the tooltip keep the dictionary's label as it is (title = FALSE), so their words do not change.
value_label <- function(s, cb, title = FALSE) {
  if (identical(s$family, "histogram")) return("Count")
  col = if (identical(s$family, "heatmap")) s$color %||% s$y else s$y %||% s$x
  lab = if (title) col_title(cb, col, capital = FALSE) else cb_label(cb, col)
  switch(s$fn, count = "Count", share = "Share of rows", sum = paste("Total", lab), mean = paste("Mean", lab),
         median = paste("Median", lab), if (title) col_title(cb, col) else lab)
}

highlight_values <- function(pal) c(`FALSE` = pal$grey, `TRUE` = CHART_HIGHLIGHT)

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
  # room on the value axis for the labels and annotations that stand past a mark's end
  written = isTRUE(s$.value_labels) || length(s$.annotate) > 0L
  room = s$.value_room %||% 0.12
  args = c(if (zero) list(expand = call("expansion", mult = if (isTRUE(s$.negative)) c(0.05, 0.05) else c(0, 0.05)))
           else if (written) list(expand = call("expansion", mult = c(0.05, room))),
           list(labels = call(if (identical(s$fn, "share")) "label_percent" else "label_comma")))
  if (written && zero) args$expand = call("expansion", mult = c(if (isTRUE(s$.negative)) room else 0, room))
  scale = as.call(c(list(sym(paste0("scale_", axis, "_continuous"))), args))
  limits = if (zero) as.call(c(list(sym("expand_limits")), stats::setNames(list(0), axis)))
  purrr::compact(list(scale, limits))
}

# How a time axis writes its dates (Phase 9): by the span the breaks cover, not as "2022-01-01". The breaks come from pretty(), which
#   steps by years, months, weeks or days as the span needs, so the labels follow what the breaks are: all on 1 January, the years
#   ("2022"); all on the 1st of a month, "Jan 2022"; otherwise the day and the month, "3 Jan"; and clock times ("14:00") when the
#   breaks are not at midnight. The month names are month.abb, so a server's locale does not change them. The scale hands the
#   function its breaks with NA for one outside the limits.
TIME_LABELS <- quote(function(x) {
  month <- month.abb[as.integer(format(x, "%m"))]
  out <- if (any(format(x, "%H%M%S") != "000000", na.rm = TRUE)) format(x, "%H:%M")
    else if (all(format(x, "%m%d") == "0101", na.rm = TRUE)) format(x, "%Y")
    else if (all(format(x, "%d") == "01", na.rm = TRUE)) paste(month, format(x, "%Y"))
    else paste(as.integer(format(x, "%d")), month)
  out[is.na(x)] <- NA
  out
})

# TIME_LABELS as the function it describes (the one place the app evaluates it, apart from the plot's own calls).
time_labels <- function() eval(TIME_LABELS, baseenv())

# The same for a discrete axis whose levels are dates (a slope chart's two dates): the level text is read back as a date.
TIME_LABELS_DISCRETE <- quote(function(x) {
  d <- as.Date(x)
  month <- month.abb[as.integer(format(d, "%m"))]
  out <- if (all(format(d, "%m%d") == "0101", na.rm = TRUE)) format(d, "%Y")
    else if (all(format(d, "%d") == "01", na.rm = TRUE)) paste(month, format(d, "%Y"))
    else paste(as.integer(format(d, "%d")), month)
  out[is.na(d)] <- x[is.na(d)]
  out
})

# Whether a column's values are dates held as a Date (not a datetime, not text), and whether it is drawn as a continuous axis.
date_column <- function(cb, col) !is.null(col) && identical(cb_entry(cb, col)$type, "date") && identical(storage_of(cb_entry(cb, col)), "date")

# The scale of a date x that is drawn on a continuous axis (a heatmap's): its labels by span.
date_x_scale <- function(s, cb) {
  e = cb_entry(cb, s$x)
  if (is.null(e) || !identical(e$type, "date")) return(NULL)
  if (identical(storage_of(e), "datetime")) call("scale_x_datetime", labels = TIME_LABELS)
  else call("scale_x_date", labels = TIME_LABELS)
}

# A time axis: whole years as whole numbers, room on the right for line labels when asked.
#   The breaks stay within the data's first and last x (Phase 7b): the room for end labels comes from the expansion, and a
#   tick past the data (a year with no value) is not printed.
time_scale <- function(s, cb, room) {
  e = cb_entry(cb, s$x)
  expand = if (room) call("expansion", mult = c(0.02, s$.end_room %||% 0.18))
           else if (!is.null(s$.fig_width) && !is.null(s$facet)) call("expansion", mult = 0.12)
  r = s$.x_range
  pretty_of = function(x) call("pretty", x)
  # pretty() of the data's own range (not of the widened limits), kept within it; on a drawing made for a screen every k-th break only, so
  #   that no more than the width has an inch for are left (a label such as "Jan 2022" is about 0.75 inch wide; in small multiples the
  #   width of one panel): the breaks stay the round ones pretty() chose
  within = function(b, lo, hi) {
    inside = call("<-", sym("b"), call("[", sym("b"), call("&", call(">=", sym("b"), lo), call("<=", sym("b"), hi))))
    thin = if (!is.null(s$.fig_width)) {
      m = max(2L, floor(fig_panel_w(s) / (s$.facet_cols %||% 1L)))
      list(call("<-", sym("k"), call("max", 1, call("ceiling", call("/", call("length", sym("b")), m)))),
           call("[", sym("b"), call("==", call("%%", call("-", call("seq_along", sym("b")), 1), sym("k")), 0)))
    } else list(sym("b"))
    as.call(c(list(sym("{"), call("<-", sym("b"), b), inside), thin))
  }
  if (identical(e$type, "date")) {
    if (identical(storage_of(e), "datetime")) return(as.call(c(list(sym("scale_x_datetime")), list(labels = TIME_LABELS), if (!is.null(expand)) list(expand = expand))))
    breaks = if (!is.null(r)) {
      lo = call("as.Date", r[[1]]); hi = call("as.Date", r[[2]])
      call("function", as.pairlist(alist(x = )), within(pretty_of(call("c", lo, hi)), lo, hi))
    }
    return(as.call(c(list(sym("scale_x_date")), if (!is.null(breaks)) list(breaks = breaks), list(labels = TIME_LABELS), if (!is.null(expand)) list(expand = expand))))
  }
  breaks = if (!is.null(r)) call("function", as.pairlist(alist(x = )), within(call("unique", call("floor", pretty_of(call("c", r[[1]], r[[2]])))), r[[1]], r[[2]]))
           else quote(function(x) unique(floor(pretty(x))))
  as.call(c(list(sym("scale_x_continuous"), breaks = breaks), if (!is.null(expand)) list(expand = expand)))
}

bar_calls <- function(s, cb, pal, widget) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  text = if (widget) tooltip_call(s, cb)
  main = if (flip) aes_call(x = v, y = s$x, fill = col, text = text) else aes_call(x = s$x, y = v, fill = col, text = text)
  geom = if (!is.null(s$highlight)) list(call("geom_col", aes_call(fill = "highlighted")),
                                          call("scale_fill_manual", values = highlight_values(pal), guide = "none"))
    else if (!is.null(col)) list(call("geom_col", position = if (flip) call("position_dodge", width = 0.8, reverse = TRUE) else call("position_dodge", width = 0.8),
                                      width = 0.75),
                                 call("scale_fill_manual", values = pal$qual(colour_count(s, cb, col))))
    else list(call("geom_col", fill = pal$single))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, if (flip) "x" else "y", TRUE),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))))
}

dot_calls <- function(s, cb, pal, widget) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  text = if (widget) tooltip_call(s, cb)
  main = if (flip) aes_call(x = v, y = s$x, colour = col, text = text) else aes_call(x = s$x, y = v, colour = col, text = text)
  geom = if (!is.null(s$highlight)) list(call("geom_point", aes_call(colour = "highlighted"), size = 3),
                                          call("scale_colour_manual", values = highlight_values(pal), guide = "none"))
    else if (!is.null(col)) list(call("geom_point", size = 3),
                                 call("scale_colour_manual", values = pal$qual(colour_count(s, cb, col))))
    else list(call("geom_point", size = 3, colour = pal$single))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, if (flip) "x" else "y", FALSE),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))))
}

# How much room a time axis leaves on its right for end labels, as a share of the axis: the longest label (characters, at
#   the label's size) over a panel about 5.8 inches wide, and at least the 0.18 an end label of a name has always had.
#   ggplot2's expansion is a share of the data's range, not of the panel: room r on the right of a panel P inches wide
#   gives r * P / (1.02 + r) inches, so the label's width w (with the 0.15 of it the label stands off its point) needs
#   r = 1.02 * w / (P - w) (Phase 7b; the earlier share of the panel left long labels running past it).
# On a drawing narrower than SPEC_NARROW_IN the names and values at the ends of the lines may take at most this share of the axis;
#   past it they give way to a legend (the lines' names) and the value is on the line's last point only when it is asked for.
SPEC_END_ROOM_NARROW <- 0.45
narrow_end_labels <- function(s, ends, v) {
  if (is.null(s$.fig_width) || s$.fig_width >= SPEC_NARROW_IN) return(FALSE)
  text = paste0(as.character(ends[[s$color]]), "  ", fact_value_fmt(s)(ends[[v]]))
  end_room(text, fig_panel_w(s)) > SPEC_END_ROOM_NARROW
}

end_room <- function(text, panel = 5.8) {
  w = 1.15 * max(nchar(text)) * SPEC_LABEL_CHAR_END_IN + 0.05
  round(min(1.5, max(0.18, 1.02 * w / max(0.5, panel - w))), 2)
}

# The width in inches of a panel's plotting area that end_room() reckons with: the figure less what the axis and the margins take
#   (5.8 of the usual 7).
fig_panel_w <- function(s) (s$.fig_width %||% SPEC_SIZE[["width"]]) - 1.2

# A line or slope label at one end: the rows where x is at its last value (per line and panel).
end_rows <- function(s, extra = NULL) {
  x = sym(s$x)
  at = if (identical(s$family, "slope")) call("==", x, call("[", call("levels", x), 2)) else call("==", x, call("max", x))
  by = if (identical(s$family, "line")) list(.by = by_arg(unique(c(s$color, s$facet))))
  as.call(c(list(sym("filter"), sym("chart_table")), extra, list(at), by))
}

# End labels: drawn only when the lint found that none would touch, so nothing is dropped.
end_labels <- function(s, rows, colour = NULL) {
  name = if (!is.null(s$color) && !identical(s$color, s$facet)) sym(s$color)
  num = value_text_call(s, value_name(s))
  value = if (isTRUE(s$.end_value)) num
  # A marked last point: its words join its line's end label (and its value, if the end labels carry none).
  merged = purrr::keep(s$.annotate %||% list(), function(g) isTRUE(g$merged))
  extra = purrr::reduce(merged, function(prev, g) {
    words = if (is.null(value)) call("paste0", "  ", num, end_words(g)) else end_words(g)
    conds = c(if (!is.null(name)) list(call("==", name, g$at$color)),
              if (!is.null(s$facet) && !identical(s$facet, s$color)) list(call("==", sym(s$facet), g$at$facet)))
    if (!length(conds)) return(words)
    call("if_else", purrr::reduce(conds, function(a, b) call("&", a, b)), words, prev)
  }, .init = "")
  label = if (!is.null(name) && !is.null(value)) call("paste0", name, "  ", value) else name %||% value
  if (length(merged)) label = call("paste0", label, extra)
  as.call(c(list(sym("geom_text"), data = rows, aes_call(label = label), hjust = -0.15, size = SPEC_LABEL_MM, family = sym("chart_font")),
            if (!is.null(colour)) list(colour = colour)))
}

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
    c(list(base(group = group, text = text), call("geom_line", colour = pal$single, linewidth = 0.9)), points(colour = pal$single),
      if (labelled && is.null(col)) list(end_labels(s, end_rows(s), pal$single)))
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
    c(list(base(group = col, text = text), call("geom_line", data = data_where(quote(!highlighted)), colour = pal$grey, linewidth = 0.7)), lit)
  } else if (many) {
    c(list(base(group = col, text = text), call("geom_line", colour = pal$single, linewidth = 0.7)), points(colour = pal$single),
      if (labelled) list(end_labels(s, end_rows(s), pal$single)))
  } else {
    c(list(base(colour = col, group = col, text = text), call("geom_line", linewidth = 0.9)), points(),
      list(as.call(c(list(sym("scale_colour_manual"), values = pal$qual(k)), if (legend) list(breaks = s$.legend_order)))),
      if (labelled) list(end_labels(s, end_rows(s)), call("guides", colour = "none")))
  }
  room = labelled
  xscale = if (slope) as.call(c(list(sym("scale_x_discrete")), if (date_column(cb, s$x)) list(labels = TIME_LABELS_DISCRETE),
                                list(expand = call("expansion", add = if (room) c(0.3, 0.8) else c(0.3, 0.3)))))
           else time_scale(s, cb, room)
  yscale = as.call(c(list(sym(if (isTRUE(s$log_y)) "scale_y_log10" else "scale_y_continuous")), list(labels = call("label_comma")),
                     if (length(s$.annotate)) list(expand = call("expansion", mult = 0.12))))
  c(layers, purrr::compact(list(xscale)), list(yscale), if (room) list(quote(coord_cartesian(clip = "off"))))
}

# A highlighted point's label sits to the left of it in the right half of the x range, to the right otherwise.
side_labels <- function(s, pal, widget) {
  rows = if (widget) s$.widget_rows else s$.label_rows
  if (!isTRUE(s$.names) || (length(rows) == 0L && !is.null(rows))) return(NULL)
  x = sym(s$x)
  hjust = call("if_else", call(">", x, call("/", call("+", call("min", x), call("max", x)), 2)), 1.15, -0.15)
  shown = if (is.null(rows)) quote(highlighted) else call("&", quote(highlighted), call("%in%", quote(row_number()), as.numeric(rows)))
  named = call("filter", call("mutate", sym("chart_table"), label_hjust = hjust), shown)
  if (!shared_repel(s, widget))
    return(label_layer(s, widget, named, aes_call(label = s$highlight$column, hjust = "label_hjust"), pal$strong, bold = TRUE))
  # Names and annotations in one layer moved by ggrepel (Phase 7b): layers do not push one another apart, so a name and an
  #   annotation drawn in two could land on each other.
  words = purrr::map(s$.annotate, function(g)
    call("mutate", annotation_data(s, g), label_text = annotation_label(s, g), label_hjust = g$hjust))
  both = as.call(c(list(sym("bind_rows"), call("mutate", named, label_text = call("as.character", sym(s$highlight$column)))), words))
  clear = if (!is.null(s$.rug_floor)) list(xlim = c(s$.rug_floor[["x"]], NA), ylim = c(s$.rug_floor[["y"]], NA))
  do.call(label_layer, c(list(s, widget, both, aes_call(label = "label_text", hjust = "label_hjust"), pal$strong, bold = TRUE), clear), quote = TRUE)
}

# Whether a scatter's or bubble's names and annotations share one ggrepel layer (static chart, ggrepel installed, both drawn).
shared_repel <- function(s, widget) {
  rows = s$.label_rows
  !widget && isTRUE(s$.repel) && s$family %in% c("scatter", "bubble") && isTRUE(s$.names) && length(s$.annotate) > 0L &&
    !(length(rows) == 0L && !is.null(rows))
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
      c(list(point(data = data_where(quote(!highlighted)), colour = pal$grey),
             point(data = data_where(quote(highlighted)), colour = CHART_HIGHLIGHT)),
        purrr::compact(list(side_labels(s, pal, widget))))
    else if (!is.null(col)) c(list(point()), colours)
    else list(point(colour = pal$single))
  c(list(call("ggplot", sym("chart_table"), main)), geom, fit_calls(s, cb, pal),
    if (bubble) list(call("scale_size_area", max_size = 8)),
    if (isTRUE(s$rug)) list(call("geom_rug", colour = pal$rug, alpha = 0.2)),
    if (isTRUE(s$log_x)) list(quote(scale_x_log10())),
    if (length(s$.annotate)) list(call(if (isTRUE(s$log_y)) "scale_y_log10" else "scale_y_continuous", expand = call("expansion", mult = 0.12)))
    else if (isTRUE(s$log_y)) list(quote(scale_y_log10())))
}

# Where a trimmed curve is drawn: SPEC_FIT_POINTS values of x between a group's percentiles, on the
#   log scale when x has one (geom_smooth() takes xseq on the scale's transformed values).
fit_xseq <- function(s, r) {
  if (isTRUE(s$log_x)) call("seq", call("log10", r[1]), call("log10", r[2]), length.out = SPEC_FIT_POINTS)
  else call("seq", r[1], r[2], length.out = SPEC_FIT_POINTS)
}

# The fitted curve as geom_smooth() layers. With no trimmed group, one layer. With groups, one layer
#   per trimmed group, on that group's rows only (data = ~ filter(.x, ...)), with its own xseq, and
#   one layer for the other groups, untrimmed. A group that cannot be fitted is in no layer.
fit_calls <- function(s, cb, pal) {
  if (identical(s$fit, "none")) return(list())
  smooth = function(data = NULL, r = NULL)
    as.call(c(list(sym("geom_smooth")), if (!is.null(data)) list(data = data),
              list(method = if (identical(s$fit, "linear")) "lm" else "loess", formula = quote(y ~ x), se = FALSE),
              if (!is.null(r)) list(xseq = fit_xseq(s, r)), list(colour = pal$fit, linewidth = 0.8)))
  fr = s$.fit_range
  if (is.null(fr)) return(list(smooth()))
  if (is.null(c(fr$groups, fr$skip)[[1]]$keys)) return(if (length(fr$skip)) list() else list(smooth(r = fr$groups[[1]]$range)))
  rows = function(cond) call("~", call("filter", sym(".x"), cond))
  cond_of = function(g)
    purrr::reduce(purrr::imap(g$keys, function(v, col) call("==", sym(col), value_call(cb_entry(cb, col), v))), function(a, b) call("&", a, b))
  conds = purrr::map(fr$groups, cond_of)
  others = c(conds, purrr::map(fr$skip, cond_of))
  c(purrr::map2(fr$groups, conds, function(g, cond) smooth(rows(cond), g$range)),
    if (isTRUE(fr$rest)) list(smooth(rows(call("!", call("(", purrr::reduce(others, function(a, b) call("|", a, b))))))))
}

histogram_calls <- function(s, cb, pal, widget)
  c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x)),
         call("geom_histogram", bins = as.numeric(s$bins), fill = pal$single, colour = pal$outline),
         call("scale_y_continuous", expand = call("expansion", mult = c(0, 0.05)))),
    if (isTRUE(s$log_x)) list(quote(scale_x_log10())))

box_calls <- function(s, cb, pal, widget) {
  flip = isTRUE(s$.flip)
  main = if (flip) aes_call(x = s$y, y = s$x) else aes_call(x = s$x, y = s$y)
  c(list(call("ggplot", sym("chart_table"), main), call("geom_boxplot", fill = pal$box_fill, colour = pal$single, width = 0.6)),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))),
    if (isTRUE(s$log_y)) list(if (flip) quote(scale_x_log10()) else quote(scale_y_log10())))
}

# A cell's value in black or white, whichever stands out more against the cell's colour (its
#   luminance from the same colour scale the fill uses).
cell_labels <- function(s, colours) {
  v = sym(value_name(s))
  rescaled = if (!is.null(s$midpoint)) call("rescale_mid", v, mid = s$midpoint) else call("rescale", v)
  fill = as.call(list(call("pal_gradient_n", colours), rescaled))
  light = call(">", call("colSums", call("*", call("col2rgb", fill), c(0.299, 0.587, 0.114))), 140)
  list(call("geom_text", data = mutate_call("text_colour", call("if_else", light, "black", "white")) |> insert_data(),
            aes_call(label = value_text_call(s, value_name(s)), colour = "text_colour"), size = 3.2, family = sym("chart_font")),
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
  c(purrr::compact(list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = s$y, fill = value_name(s), text = text)),
         call("geom_tile", colour = pal$outline, linewidth = 0.5),
         as.call(c(list(sym("scale_fill_gradientn"), colours = colours), rescaler, list(breaks = if (!is.null(s$.fig_width)) HEAT_BREAKS_FEW else HEAT_BREAKS),
                   if (identical(s$fn, "share")) list(labels = call("label_percent")) else if (!is.null(s$.fig_width)) list(labels = call("label_comma")))),
         call("scale_y_discrete", limits = sym("rev")),
         if (!is_group_like(cb_entry(cb, s$x))) date_x_scale(s, cb),
         # a colour bar long enough for its labels (the guide's own theme, so the style's theme does not undo it)
         call("guides", fill = call("guide_colourbar", theme = call("theme", legend.key.width = call("unit", if (!is.null(s$.fig_width)) min(2.4, fig_panel_w(s) - 0.4) else 2.4, "in")))))),
    if (isTRUE(s$.cell_labels)) cell_labels(s, colours))
}

# A heatmap legend's breaks (Phase 7b): four to six round values inside the colour scale's range (pretty() asked for six; for
#   ten when fewer than four fall inside), where the default gave two. Base R only, so the printed code runs as it is.
HEAT_BREAKS <- quote(function(x) {
  inside = function(b) b[b >= x[1] & b <= x[2]]
  b = inside(pretty(x, n = 6))
  if (length(b) < 4) b = inside(pretty(x, n = 10))
  utils::head(b, 6)
})

# The same for a narrow drawing (about three round values, each inside the scale's range), on a shorter colour bar.
HEAT_BREAKS_FEW <- quote(function(x) {
  inside = function(b) b[b >= x[1] & b <= x[2]]
  b = inside(pretty(x, n = 2))
  if (length(b) < 2) b = inside(pretty(x, n = 4))
  utils::head(b, 3)
})

# Which axis carries the light grid: the value axis.
grid_of <- function(s) switch(s$family,
  bar = , dot = if (isTRUE(s$.value_labels)) "none" else if (isTRUE(s$.flip)) "x" else "y",
  box = if (isTRUE(s$.flip)) "x" else "y",
  scatter = , bubble = if (isTRUE(s$.binned)) "none" else "xy",
  heatmap = "none",
  "y")

labs_call <- function(s, cb) {
  flip = isTRUE(s$.flip)
  # Titles from the data dictionary's labels (col_title()), unless the model or analyst gave one.
  xl = s$x_label %||% if (!is.null(s$x)) col_title(cb, s$x)
  yl = s$y_label %||% if (s$family %in% c("box", "scatter", "bubble", "heatmap")) col_title(cb, s$y) else value_label(s, cb, title = TRUE)
  line_legend = s$family %in% c("line", "slope") && !is.null(s$.legend_order)
  legend = purrr::compact(list(
    colour = if (!is.null(s$color) && ((s$family %in% c("dot", "scatter", "bubble") && is.null(s$highlight) && !isTRUE(s$.binned)) || line_legend))
               col_title(cb, s$color),
    fill = if (identical(s$family, "heatmap")) value_label(s, cb, title = TRUE)
           else if (identical(s$family, "bar") && !is.null(s$color) && is.null(s$highlight)) col_title(cb, s$color)
           else if (isTRUE(s$.binned)) "Count",
    size = if (identical(s$family, "bubble")) col_title(cb, s$size)))
  # A sideways bar or dot lists names on its y axis; that axis needs no title unless the spec gives one.
  axes = if (flip && s$family %in% c("bar", "dot")) list(x = yl, y = s$x_label)
         else if (flip) list(x = yl, y = xl) else list(x = xl, y = yl)
  if (is.null(axes$y)) axes = c(axes["x"], list(y = NULL))
  # on a drawing made for a screen an axis title that is wider than its axis is broken into lines (the x title over the panel's
  #   width, the y title over its height)
  if (!is.null(s$.fig_width)) {
    wrap = function(text, inches) if (is_text1(text)) paste(strwrap(text, max(10L, floor(inches / 0.09))), collapse = "\n") else text
    if (is_text1(axes$x)) axes$x = wrap(axes$x, fig_panel_w(s))
    if (is_text1(axes$y)) axes$y = wrap(axes$y, max(1.5, (s$.fig_height %||% SPEC_SIZE[["height"]]) - 1.2))
  }
  caption = if (isTRUE(s$.source)) paste(strwrap(s$caption, SPEC_CAPTION_WIDTH), collapse = "\n") else s$caption
  as.call(c(list(sym("labs")), purrr::compact(list(title = s$title, subtitle = s$subtitle, caption = caption)), axes, legend))
}

facet_call <- function(s) {
  if (is.null(s$facet)) return(NULL)
  as.call(c(list(sym("facet_wrap"), call("vars", sym(s$facet))), if (isTRUE(s$free_y)) list(scales = "free_y"),
            if (!is.null(s$.facet_cols)) list(ncol = s$.facet_cols)))
}

# Whether the value axis labels can sit above their grid line (a style that asks for it): an upright
#   chart with its value axis on the left and no panels.
lift_axis <- function(s) s$family %in% c("bar", "dot", "line", "histogram", "box") && !isTRUE(s$.flip) && is.null(s$facet) &&
  !isTRUE(s$.value_labels)

# The style's theme as ggplot2 calls (R/theme.R), written from the spec: the grid its family gets, the legend's
#   place, and the style's own layers (the rule under the title block; not in the plotly version, which
#   drops a second axis, so spec_widget() draws the rule itself).
theme_calls <- function(s, pal, widget = FALSE)
  c(chart_theme_calls(pal$style, grid = grid_of(s),
                      legend = if (s$family %in% c("line", "slope") && !is.null(s$.legend_order)) "right" else "top",
                      lift = lift_axis(s)),
    bare_axis_call(s),
    if (!widget) chart_style_layers(pal$style))

# A bar or dot chart whose every mark carries its value: the value axis's numbers and ticks go (its title stays).
bare_axis_call <- function(s) {
  if (!isTRUE(s$.value_axis_bare)) return(NULL)
  a = if (isTRUE(s$.flip)) "x" else "y"
  list(as.call(c(list(sym("theme")), stats::setNames(list(quote(element_blank()), quote(element_blank())), paste0(c("axis.text.", "axis.ticks."), a)))))
}

# One text layer of the labels R writes: geom_text(), or ggrepel::geom_text_repel() in the static chart when ggrepel was
#   installed at the lint (.repel) and `repel` is wanted (not for the labels of a bar or dot, which R places itself); the
#   plotly version has no repel. In the chart's font and the style's text colour.
#   `mapping` is the aes() of the layer; `...` are its constant arguments (hjust, vjust, position).
label_layer <- function(s, widget, data, mapping, colour, bold = FALSE, repel = TRUE, ...) {
  fixed = c(list(data = data, mapping), list(family = sym("chart_font"), size = SPEC_LABEL_MM, colour = colour),
            if (bold) list(fontface = "bold"), list(...))
  if (widget || !repel || !isTRUE(s$.repel)) return(as.call(c(list(sym("geom_text")), fixed)))
  as.call(c(list(quote(ggrepel::geom_text_repel)), fixed,
            list(direction = "both", seed = SPEC_JITTER_SEED, max.overlaps = Inf, box.padding = 0.2, min.segment.length = 0.3,
                 segment.colour = colour, segment.size = 0.3)))
}

# The rows of chart_table a label layer draws: all (rows NULL), or those row numbers.
label_data <- function(rows) {
  if (is.null(rows)) return(sym("chart_table"))
  call("filter", sym("chart_table"), call("%in%", quote(row_number()), as.numeric(rows)))
}

# The value labels of a bar or dot chart: the plotted value at the end of each mark, outside it (a negative value below
#   or to the left), in the style's text colour. A grouped bar's label sits over its own bar (the same dodge).
value_label_calls <- function(s, cb, pal, widget) {
  rows = s$.label_rows
  if (!isTRUE(s$.value_labels) || (length(rows) == 0L && !is.null(rows))) return(list())
  v = value_name(s); flip = isTRUE(s$.flip); bar = identical(s$family, "bar")
  out = c(if (bar) -0.4 else -1.2, if (bar) 1.4 else 2.2)
  side = if (flip) c(if (bar) -0.15 else -0.35, if (bar) 1.15 else 1.35) else out
  by_sign = isTRUE(s$.negative)
  just = function(w) if (by_sign) call("if_else", call(">=", sym(v), 0), side[1], side[2]) else side[1]
  mapping = if (by_sign) aes_call(label = value_text_call(s, v), hjust = if (flip) just() else NULL, vjust = if (!flip) just() else NULL)
            else aes_call(label = value_text_call(s, v))
  position = if (bar && !is.null(s$color))
    list(position = if (flip) call("position_dodge", width = 0.8, reverse = TRUE) else call("position_dodge", width = 0.8))
  fixed = if (by_sign) list() else if (flip) list(hjust = side[1]) else list(vjust = side[1])
  list(do.call(label_layer, c(list(s, widget, label_data(rows), mapping, pal$label, repel = FALSE), fixed, position), quote = TRUE))
}

# The row an annotation marks, as a call: the first row of the series (a line with colours) at its highest or lowest value,
#   or its first or latest x; the table's own highest or lowest for a bar, dot, scatter or bubble.
annotation_data <- function(s, g) {
  v = if (s$family %in% c("scatter", "bubble")) s$y else value_name(s)
  conds = c(if (!is.null(g$series)) list(call("==", sym(s$color), g$series)),
            if (!is.null(g$panel)) list(call("==", sym(s$facet), g$panel)))
  base = if (length(conds)) call("filter", sym("chart_table"), purrr::reduce(conds, function(a, b) call("&", a, b))) else sym("chart_table")
  if (identical(s$family, "line")) base = call("arrange", base, sym(s$x))
  switch(g$kinds[[1]],
    highest = call("slice_max", base, sym(v), n = 1, with_ties = FALSE),
    lowest = call("slice_min", base, sym(v), n = 1, with_ties = FALSE),
    first = call("slice_min", base, sym(s$x), n = 1, with_ties = FALSE),
    latest = call("slice_max", base, sym(s$x), n = 1, with_ties = FALSE))
}

# The words of an annotation as a call: "Highest: 1,230" (and "(2024-03-01)" after it on a line chart), "Highest and latest: ..." when
#   two kinds fall on one point. The number is written as the facts write it.
annotation_label <- function(s, g) {
  v = if (s$family %in% c("scatter", "bubble")) s$y else value_name(s)
  words = paste(g$kinds, collapse = " and ")
  tie = annotation_tie(g)
  if (annotation_lines(s))
    return(as.call(c(list(sym("paste0"), paste0(toupper(substring(words, 1, 1)), substring(words, 2), "\n"), value_text_call(s, v)),
                     if (nzchar(tie)) list(paste0("\n", sub("^, ", "", tie))),
                     if (identical(s$family, "line")) list("\n(", x_text_call(s, g$x_text), ")"))))
  as.call(c(list(sym("paste0"), paste0(toupper(substring(words, 1, 1)), substring(words, 2), ": "), value_text_call(s, v)),
            if (identical(s$family, "line")) list(" (", x_text_call(s, g$x_text), ")"), if (nzchar(tie)) list(tie)))
}

# What an annotate marks: a ring round a point (line, dot, scatter, bubble; a bar has no point, so only its words),
#   and its words in bold in the style's text colour, placed by the lint.
annotation_calls <- function(s, cb, pal, widget) {
  groups = s$.annotate
  if (!length(groups)) return(list())
  unlist(purrr::map(groups, function(g) {
    data = annotation_data(s, g)
    ring = if (!identical(s$family, "bar"))
      list(call("geom_point", data = data, shape = 1, size = 4, stroke = 1, colour = CHART_HIGHLIGHT))
    # merged into its line's end label (lint_marks()): the ring only, in the static chart; the plotly version has no end labels
    if (isTRUE(g$merged) && !widget) return(ring)
    # drawn with the names, in one layer (side_labels())
    if (shared_repel(s, widget)) return(ring)
    # a label moved by ggrepel keeps clear of a rug's band (xlim, ylim in the data's units, worked out by the lint)
    clear = if (!widget && isTRUE(s$.repel) && !is.null(s$.rug_floor)) list(xlim = c(s$.rug_floor[["x"]], NA), ylim = c(s$.rug_floor[["y"]], NA))
    c(ring, list(do.call(label_layer, c(list(s, widget, data, aes_call(label = annotation_label(s, g)), pal$strong, bold = TRUE,
                                             repel = !s$family %in% c("bar", "dot"), hjust = g$hjust, vjust = g$vjust), clear), quote = TRUE)))
  }), recursive = FALSE)
}

# Everything R writes or marks on the chart besides the family's own layers: value labels, annotations.
mark_calls <- function(s, cb, pal, widget) c(value_label_calls(s, cb, pal, widget), annotation_calls(s, cb, pal, widget))

# The plot's layers, as calls, from the spec as the lint left it and the codebook. widget = TRUE
#   builds the variant the plotly version is made from: no direct labels (plotly cannot place
#   them), the legend kept, and a tooltip naming each value.
plot_calls <- function(s, cb, pal = spec_palette(), widget = FALSE) {
  build = switch(s$family, bar = bar_calls, dot = dot_calls, line = , slope = line_calls, scatter = , bubble = scatter_calls,
                 histogram = histogram_calls, box = box_calls, heatmap = heatmap_calls)
  few_breaks_calls(c(build(s, cb, pal, widget), mark_calls(s, cb, pal, widget), purrr::compact(list(facet_call(s), labs_call(s, cb))), theme_calls(s, pal, widget)), s)
}

# A narrow drawing (.few_breaks) asks a continuous x axis for fewer breaks: n.breaks on its scale, or a scale made for it when the
#   chart has none. The axes of a line chart (time_scale()) and the discrete ones take care of themselves.
few_breaks_calls <- function(calls, s) {
  if (!is.null(s$.fig_width) && !is.null(s$facet))
    calls = c(calls, list(call("theme", panel.spacing.x = call("unit", 0.3, "in"))))
  continuous = (s$family %in% c("bar", "dot", "box") && isTRUE(s$.flip)) || s$family %in% c("scatter", "bubble", "histogram")
  if (!isTRUE(s$.few_breaks) || !continuous) return(calls)
  is_x = function(cl) is.call(cl) && is.symbol(cl[[1]]) && as.character(cl[[1]]) %in% c("scale_x_continuous", "scale_x_log10")
  at = which(purrr::map_lgl(calls, is_x))
  if (!length(at)) return(append(calls, list(call("scale_x_continuous", n.breaks = SPEC_FEW_BREAKS)), after = 1L))
  cl = calls[[at[1]]]
  cl$n.breaks = SPEC_FEW_BREAKS
  calls[[at[1]]] = cl
  calls
}

plus_call <- function(calls) purrr::reduce(calls[-1], function(acc, cl) call("+", acc, cl), .init = calls[[1]])

# Whether the widget variant carries its own tooltip text.
widget_has_text <- function(s) s$family %in% c("bar", "dot", "line", "slope", "scatter", "bubble", "heatmap") &&
  !isTRUE(s$.binned)

# The ggplot for a spec. Runs the defaults, the check, the table and the lint itself, so one call
#   is enough. `palette` names the three palettes of the report (chart_palette_default()); the
#   spec never chooses colours. Attributes: notes (the lint's sentences), spec (the spec as drawn),
#   table, widget_plot (the variant spec_widget() converts) and palette.
spec_plot <- function(spec, data, cb, palette = chart_palette_default(), web = NULL) {
  s = spec_defaults(spec_public(spec))
  why = spec_check(s, cb, palette)
  if (length(why)) spec_fail(paste(why, collapse = " "))
  pal = spec_palette(palette)
  table = spec_table(s, data, cb, palette)
  # A drawing made for a screen (the exported dashboard): `web` is list(width, height, bare, few_breaks), the size in inches it is
  #   shown at, whether it carries no title, subtitle or source line (the page says them), and whether its x axis asks for fewer breaks.
  #   The lint reckons with that size, so a label that does not fit it is left out or moved, as at the usual 7 by 4.5.
  if (!is.null(web)) {
    s$.fig_width = web$width
    s$.fig_height = web$height %||% round(web$width * 0.64, 2)
    s$.bare = isTRUE(web$bare)
    s$.few_breaks = isTRUE(web$few_breaks)
  }
  lint = spec_lint(s, cb, table, pal$max)
  ls = lint$spec
  if (!is.null(web)) {
    if (!is.null(ls$facet)) ls$.facet_cols = fig_across(ls, length(unique(table[[ls$facet]])))
    if (isTRUE(ls$.bare)) {
      ls$title = NULL
      ls$subtitle = NULL
      ls$caption = NULL
      ls$.source = NULL
    }
  }
  env = do.call(spec_env, c(list(chart_table = table), pal$fonts))
  p = eval(plus_call(plot_calls(ls, cb, pal)), env)
  attr(p, "notes") = c(palette_note(ls, cb, palette), lint$notes)
  attr(p, "spec") = ls
  attr(p, "table") = table
  attr(p, "widget_plot") = eval(plus_call(plot_calls(ls, cb, pal, widget = TRUE)), env)
  attr(p, "widget_text") = widget_has_text(ls)
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

# The lines that give the typeface variables their value in the written code: the bundled family when
#   systemfonts knows it (registered or installed), else the default sans or serif. "" when the theme
#   uses none.
font_lines <- function(vars) {
  if (!length(vars)) return("")
  one = function(v) {
    f = CHART_FONT_VARS[[v]]
    name = chart_font_name(f[[1]], f[[2]])
    paste0(v, " <- if (has_font(\"", name, "\")) \"", name, "\" else \"", CHART_FONTS[[f[[1]]]]$fallback, "\"")
  }
  paste0("# The typeface: ", paste(unique(purrr::map_chr(CHART_FONT_VARS[vars], function(f) CHART_FONTS[[f[[1]]]]$family)), collapse = " and "),
         " when systemfonts knows it (registered or installed), else the default fonts.\n",
         "has_font <- function(f) requireNamespace(\"systemfonts\", quietly = TRUE) &&\n",
         "  f %in% c(systemfonts::registry_fonts()$family, systemfonts::system_fonts()$family)\n",
         paste(purrr::map_chr(vars, one), collapse = "\n"), "\n\n")
}

# The number formats the chart's labels use, written out for the code: chaRt's own functions (the ones that write the facts'
#   numbers), made of base R only, named chart_number(), chart_count() and chart_fixed(); "" when the chart uses none.
label_helpers <- function(plot) {
  defs = list(chart_number = fact_num, chart_count = fact_count, chart_fixed = fact_fixed)
  used = intersect(names(defs), unlist(purrr::map(plot, all.names)))
  if (!length(used)) return("")
  paste0("# How the chart writes a number on its marks: the same way chaRt writes the numbers of the facts.\n",
         paste(purrr::map_chr(used, function(u) {
           text = paste(deparse(defs[[u]], width.cutoff = 40L), collapse = "\n  ")
           paste0(u, " <- ", sub("^function \\(", "function(", sub(" \n  ", " ", text)))
         }), collapse = "\n"), "\n\n")
}

# R code that reads the file (by its name, with the codebook's values that mean missing and its
#   encoding), builds the same table with dplyr and tidyr, and draws the same chart with ggplot2,
#   ending with the style's theme as plain theme_minimal() and theme() calls (chart_theme_calls()), with the
#   typeface set to the bundled family when it is registered or installed and to the default sans (or
#   serif) when it is not. It is written from the spec as spec_plot() left it
#   (attr(plot, "spec")) and the same palette and style: every line is one of the calls spec_table() and
#   spec_plot() evaluate, with the palette's colours written in, so the code runs without paletteer or
#   anything else from this app.
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
  pal = spec_palette(palette)
  plot = plot_calls(s, cb, pal)
  plot_text = paste(purrr::imap_chr(plot, function(cl, i) code_text(cl, 2L, if (i < length(plot)) " +" else "")), collapse = " +\n  ")
  step_text = paste(purrr::imap_chr(steps, function(cl, i) code_text(cl, 2L, if (i < length(steps)) " |>" else "")), collapse = " |>\n  ")
  libs = c("readr", "dplyr", "tidyr", "ggplot2", if (grepl("label_|breaks_|pal_gradient_n|rescale", plot_text)) "scales")
  helpers = label_helpers(plot)
  paste0(paste0("library(", libs, ")", collapse = "\n"), "\n\n",
         "# The data, read as chaRt reads it: these values mean missing, and column types are guessed from every row.\n",
         "# Set the working directory to the folder that holds the file (setwd()), or write its full path here.\n",
         "chart_data <- ", code_text(read, 14L, if (!is.null(rename)) " |>" else ""),
         if (!is.null(rename)) paste0(" |>\n  ", code_text(rename, 2L), "  # blank or repeated names in the file, as in the codebook"),
         "\n\n# The table that is drawn.\n",
         "chart_table <- chart_data |>\n  ", step_text, "\n\n",
         font_lines(names(pal$fonts)), helpers,
         "# The chart. The theme is the style chosen in chaRt, written out.\n",
         plot_text, "\n")
}


# ---- the facts a summary may use ------------------------------------------------------------------

SPEC_FACTS_SERIES <- 8L        # a line chart with more series than this: facts for the highlighted ones and ...
SPEC_FACTS_EXTREMES <- 3L      # ... this many with the largest and the smallest change
SPEC_FACTS_CELLS <- 5L         # a heatmap with more than SPEC_HEAT_LABELS cells: this many highest and lowest
SPEC_FACTS_LINE_POINTS <- 3L   # a line with fewer points than this gets no highest or lowest
SPEC_FACTS_GROUP_N <- 10L     # a correlation within a group of at least this many rows
SPEC_FACTS_FIT_AT <- c(0.1, 0.3, 0.5, 0.7, 0.9) # the fitted y at these percentiles of x

# How a number is written in the facts, always the same way for the same value: a measure to 3
#   significant digits, with thousands separators when its axis shows them; a count whole, with
#   separators; a percentage to one decimal; a correlation to two.
#   These three are written in base R only (vapply, not purrr): the code a chart comes with carries a copy of the ones its
#   labels use, so a label on the chart and a number in the facts are written by the same function.
fact_num <- function(x, comma = TRUE) vapply(x, function(v) {
  if (is.na(v)) return("not defined")
  v = signif(v, 3)
  format(if (v == 0) 0 else v, big.mark = if (comma) "," else "", scientific = FALSE, trim = TRUE, digits = 15)
}, character(1))
fact_count <- function(x) vapply(x, function(v) format(round(v), big.mark = ",", scientific = FALSE, trim = TRUE), character(1))
fact_fixed <- function(x, digits, suffix = "") vapply(x, function(v) {
  if (is.na(v)) return("not defined")
  r = round(v, digits)
  paste0(formatC(if (abs(r) < 10^-digits / 2) 0 else r, format = "f", digits = digits, big.mark = ","), suffix)
}, character(1))
fact_pct <- function(x) fact_fixed(x, 1L, "%")
fact_r <- function(x) fact_fixed(x, 2L)

# A time as its axis shows it: a date as written, a whole number (a year) without separators.
fact_time <- function(x) {
  if (inherits(x, c("Date", "POSIXt")) || is.factor(x) || is.character(x)) return(as.character(x))
  purrr::map_chr(x, function(v) if (isTRUE(v == round(v))) format(v, scientific = FALSE, trim = TRUE) else fact_num(v, FALSE))
}

# The plotted value as the chart's value axis shows it.
fact_value_fmt <- function(s) {
  comma = s$family %in% c("bar", "dot", "line", "slope", "heatmap")
  switch(s$fn, count = fact_count, share = function(x) fact_pct(100 * x), function(x) fact_num(x, comma))
}

# Names of id and text columns become tokens, [[N1]], [[N2]], in order of first appearance; other
#   values are written as they are. Returns list(name = function(column, values), map = function()),
#   map giving token = name.
fact_namer <- function(cb) {
  env = new.env(parent = emptyenv())
  env$map = character(0)
  name = function(col, v) {
    v = as.character(v)
    e = cb_entry(cb, col)
    if (is.null(e) || !is_name_like(e)) return(v)
    purrr::map_chr(v, function(x) {
      hit = names(env$map)[env$map == x]
      if (length(hit)) return(hit[1])
      tok = paste0("[[N", length(env$map) + 1L, "]]")
      env$map = c(env$map, stats::setNames(x, tok))
      tok
    })
  }
  list(name = name, map = function() env$map)
}

# A table's rows split by a column, in the order the chart shows them (a factor's levels, otherwise
#   first appearance).
fact_split <- function(t, col) {
  v = t[[col]]
  keys = if (is.factor(v)) intersect(levels(v), as.character(v)) else unique(as.character(v))
  purrr::set_names(purrr::map(keys, function(k) t[as.character(v) == k, , drop = FALSE]), keys)
}

fact_same <- function(a, b) abs(a - b) <= 1e-9 * max(1, abs(b))

# A multiple (end over start) to two significant digits, always the same way for the same value.
fact_times <- function(x) purrr::map_chr(x, function(v) format(signif(v, 2), scientific = FALSE, trim = TRUE, digits = 15))

# How many groups the chart shows, in words, or NULL when it has none: the values of x for a bar,
#   dot and box, the lines of a line or slope with a colour, rows and columns of a heatmap, the
#   groups of a colour or panel for a scatter, bubble and histogram.
facts_groups <- function(s, t) {
  t = as.data.frame(t)
  n = function(cols) fact_count(nrow(unique(t[cols])))
  switch(s$family,
    bar = , dot = , box = n(s$x),
    line = , slope = if (!is.null(s$color)) n(s$color),
    heatmap = paste0(n(s$y), " rows and ", n(s$x), " columns"),
    histogram = if (!is.null(s$facet)) n(s$facet),
    if (length(unique(c(s$color, s$facet)))) n(unique(c(s$color, s$facet))))
}

# The conditions of a spec's filter in words, one for each ("Region is one of North, South"): in the facts, and in the
#   source line under the chart. `nm` writes the values of a column (the facts tokenise the names of id and text columns).
filter_phrases <- function(s, cb, nm = function(col, v) as.character(v)) {
  fl = s$filter
  fl = if (!is.null(names(fl))) list(fl) else fl
  purrr::map_chr(fl, function(f)
    paste0(cb_label(cb, f$column), " ", SPEC_OPS_WORDS[[f$op]], " ", paste(nm(f$column, values_of(f$value)), collapse = ", ")))
}

# Which lines the facts describe when a line chart has many: the highlighted ones and those with the largest and the
#   smallest change (`chg`: each line's last value less its first; `highlighted`: a flag for each line). Their indices.
fact_lines_keep <- function(chg, highlighted) {
  if (length(chg) > SPEC_FACTS_SERIES)
    sort(unique(c(which(highlighted), utils::head(order(-chg), SPEC_FACTS_EXTREMES), utils::head(order(chg), SPEC_FACTS_EXTREMES))))
  else seq_along(chg)
}

# What is plotted, in words, and the rows behind it.
facts_head <- function(s, cb, table, nm, exploratory) {
  lab = function(col) cb_label(cb, col)
  fam = s$family
  what = switch(fam,
    scatter = , bubble = paste0(lab(s$y), " against ", lab(s$x), if (identical(fam, "bubble")) paste0(", sized by ", lab(s$size))),
    histogram = paste0("Count of rows by ", lab(s$x)),
    box = paste0(lab(s$y), " by ", lab(s$x)),
    heatmap = paste0(value_label(s, cb), " by ", lab(s$x), " (columns) and ", lab(s$y), " (rows)"),
    line = , slope = paste0(value_label(s, cb), " by ", lab(s$x), if (!is.null(s$color)) paste0(", one line for each ", lab(s$color))),
    paste0(value_label(s, cb), " by ", lab(s$x)))
  colour = if (!is.null(s$color) && fam %in% c("bar", "dot", "scatter", "bubble")) paste0(", coloured by ", lab(s$color))
  facet = if (!is.null(s$facet)) paste0(", in panels by ", lab(s$facet))
  phrases = filter_phrases(s, cb, nm)
  filters = if (length(phrases)) paste0("Filter: ", phrases)
  shown = if (!is.null(s$top_n))
    paste0("Shown: the top ", top_of(s), " of ", fact_count(attr(table, "groups_total")), " values of ", lab(ranked_column(s)))
  h = s$highlight
  dropped = attr(table, "rows_dropped") %||% 0L
  groups = facts_groups(s, table)
  c(paste0("Plotted: ", what, colour, facet),
    filters, shown,
    if (!is.null(h)) paste0("Highlighted: ", paste(nm(h$column, values_of(h$values)), collapse = ", "), " (", lab(h$column), ")"),
    if (!identical(s$fit, "none") && fam %in% c("scatter", "bubble")) paste0("Fitted curve: ", if (identical(s$fit, "linear")) "a straight line" else "loess"),
    paste0("Rows used: ", fact_count(attr(table, "rows_used"))),
    paste0("Rows after the filter: ", fact_count(attr(table, "rows_used") + dropped)),
    if (!is.null(groups)) paste0("Groups shown: ", groups),
    if (dropped > 0L) paste0("Rows left out for missing values: ", fact_count(dropped)),
    paste0("Exploratory: ", if (isTRUE(exploratory)) "yes" else "no"))
}

# Highest, lowest, ties, the multiple and, for a count or sum, the total and the top three shares,
#   of values `vals` named `labs`.
facts_extremes <- function(s, vals, labs, fmt) {
  hi = max(vals); lo = min(vals)
  at_hi = labs[fact_same(vals, hi)]; at_lo = labs[fact_same(vals, lo)]
  tot = sum(vals)
  top = utils::head(order(-vals), 3L)
  same = length(vals) > 1L && all(fact_same(vals, hi))
  c(if (same) paste0("Every value shown: ", fmt(hi)),
    paste0("Highest: ", paste(at_hi, collapse = ", "), " (", fmt(hi), ")"),
    paste0("Groups at the highest value: ", length(at_hi)),
    if (!same) c(paste0("Lowest: ", paste(at_lo, collapse = ", "), " (", fmt(lo), ")"),
                 if (hi > 0 && lo > 0) paste0("Highest as a multiple of the lowest: ", fact_num(hi / lo, FALSE))),
    if (s$fn %in% c("count", "sum") && tot > 0) {
      of = if (!is.null(s$top_n)) " of the values shown" else ""
      c(paste0("Total", of, ": ", fmt(tot)),
        paste0("Share of the total", of, ": ", paste0(labs[top], " ", fact_pct(100 * vals[top] / tot), collapse = "; ")))
    })
}

facts_bars <- function(s, cb, t, nm, fmt) {
  v = value_name(s)
  xs = nm(s$x, t[[s$x]])
  if (is.null(s$color))
    return(c("Values:", paste0("- ", xs, ": ", fmt(t[[v]])), facts_extremes(s, t[[v]], xs, fmt)))
  cs = nm(s$color, t[[s$color]])
  within = purrr::imap(fact_split(t, s$x), function(d, k)
    c(paste0("Within ", nm(s$x, k), ":"), paste0("  ", facts_extremes(s, d[[v]], nm(s$color, d[[s$color]]), fmt))))
  c("Values:", paste0("- ", xs, ", ", cs, ": ", fmt(t[[v]])), facts_extremes(s, t[[v]], paste0(xs, ", ", cs), fmt), unlist(within))
}

# The step between a series' dates when the series is monthly or quarterly ("month", "quarter"),
#   judged by the median gap between its dates; NULL for anything else, a number (a year) included.
fact_period <- function(x) {
  if (!inherits(x, c("Date", "POSIXt")) || length(x) < 3L) return(NULL)
  gap = stats::median(as.numeric(diff(as.Date(x))))
  if (isTRUE(gap >= 28 && gap <= 31)) "month" else if (isTRUE(gap >= 89 && gap <= 92)) "quarter"
}

# For a monthly or quarterly series that covers more than one year: the last value against the point
#   exactly a year before it, as text to append to the series' line ("" otherwise). `x` is the
#   series' sorted dates, `y` its values and `tm` the dates as written. A series that covers the year
#   but has no point on that date says so.
fact_year_before <- function(x, y, tm, fmt) {
  if (is.null(fact_period(x))) return("")
  d = as.Date(x)
  n = length(d)
  before = seq(d[n], by = "-1 year", length.out = 2L)[2]
  if (before < d[1]) return("")
  j = match(before, d)
  if (is.na(j)) return(", no point a year before the last one")
  paste0(", a year before the last point (", tm[j], ") it was ", fmt(y[j]), ", change over the year ", fmt(y[n] - y[j]),
         if (y[j] > 0) paste0(" (", fact_pct(100 * (y[n] - y[j]) / y[j]), ")"))
}

facts_lines <- function(s, cb, t, nm, fmt) {
  v = value_name(s)
  series = if (is.null(s$color)) list(`The line` = t) else fact_split(t, s$color)
  one = purrr::imap(series, function(d, k) {
    d = d[order(d[[s$x]]), , drop = FALSE]
    n = nrow(d); y = d[[v]]; tm = fact_time(d[[s$x]])
    i_hi = which.max(y); i_lo = which.min(y)
    who = if (is.null(s$color)) k else nm(s$color, k)
    # A series of fewer than three points has no highest or lowest worth naming.
    extremes = if (n >= SPEC_FACTS_LINE_POINTS) paste0(", highest ", fmt(y[i_hi]), " (", tm[i_hi], "), lowest ", fmt(y[i_lo]), " (", tm[i_lo], ")")
      else paste0(", only ", fact_count(n), if (n == 1L) " point" else " points", ", so no highest or lowest is given")
    list(name = who, change = y[n] - y[1], highlighted = isTRUE(any(d$highlighted)), points = n,
         text = paste0(who, ": first ", fmt(y[1]), " (", tm[1], "), last ", fmt(y[n]), " (", tm[n], "), change ",
                       fmt(y[n] - y[1]), if (y[1] > 0) paste0(" (", fact_pct(100 * (y[n] - y[1]) / y[1]), ")"),
                       if (y[1] > 0 && y[n] > 0) paste0(", end is ", fact_times(y[n] / y[1]), " times start"),
                       extremes, fact_year_before(d[[s$x]], y, tm, fmt)))
  })
  pts = purrr::map_int(one, "points")
  per_series = paste0("Points per series: ", if (min(pts) == max(pts)) fact_count(min(pts)) else paste0(fact_count(min(pts)), " to ", fact_count(max(pts))))
  chg = purrr::map_dbl(one, "change")
  keep = fact_lines_keep(chg, purrr::map_lgl(one, "highlighted"))
  c(per_series,
    if (length(keep) < length(one))
      paste0("Lines described: ", length(keep), " of ", length(one), ", the highlighted ones and those with the largest and smallest change"),
    unname(purrr::map_chr(one[keep], "text")),
    if (length(one) > 1L && max(chg) > 0) paste0("Rose most: ", one[[which.max(chg)]]$name, " (", fmt(max(chg)), ")"),
    if (length(one) > 1L && min(chg) < 0) paste0("Fell most: ", one[[which.min(chg)]]$name, " (", fmt(min(chg)), ")"))
}

facts_slope <- function(s, cb, t, nm, fmt) {
  v = value_name(s)
  lv = intersect(levels(t[[s$x]]), as.character(t[[s$x]]))
  at = function(l) { d = t[as.character(t[[s$x]]) == l, , drop = FALSE]; stats::setNames(d[[v]], as.character(d[[s$color]])) }
  a = at(lv[1]); b = at(lv[2])
  ids = intersect(names(a), names(b))
  a = a[ids]; b = b[ids]; chg = b - a
  rank_of = function(x) rank(-x, ties.method = "min")
  ra = rank_of(a); rb = rank_of(b)
  shown = nm(s$color, ids)
  c(paste0("Start: ", lv[1], "; end: ", lv[2]),
    paste0(shown, ": start ", fmt(a), ", end ", fmt(b), ", change ", fmt(chg),
           ifelse(a > 0, paste0(" (", fact_pct(100 * chg / a), ")"), ""),
           ifelse(a > 0 & b > 0, paste0(", end is ", fact_times(b / a), " times start"), ""), ", rank ", ra, " of ", length(ids), " at start and ", rb, " at end"),
    if (max(chg) > 0) paste0("Largest rise: ", shown[which.max(chg)], " (", fmt(max(chg)), ")"),
    if (min(chg) < 0) paste0("Largest fall: ", shown[which.min(chg)], " (", fmt(min(chg)), ")"),
    paste0("Lines that rose: ", sum(chg > 0), "; lines that fell: ", sum(chg < 0), if (any(chg == 0)) paste0("; unchanged: ", sum(chg == 0))))
}

# The groups of a scatter's rows for a set of columns, each with its name in the facts.
fact_groups <- function(t, keys, nm) {
  if (!length(keys)) return(list(list(d = t, who = NULL)))
  parts = unname(split(t, lapply(keys, function(k) if (is.factor(t[[k]])) t[[k]] else factor(t[[k]])), drop = TRUE))
  purrr::map(parts, function(d) list(d = d, who = paste(purrr::map_chr(keys, function(col) nm(col, d[[col]][1])), collapse = ", ")))
}

facts_scatter <- function(s, cb, t, nm) {
  lab = function(col) cb_label(cb, col)
  num = function(x) fact_num(x, FALSE)
  x = t[[s$x]]; y = t[[s$y]]
  # Pearson is computed on the scale the chart draws: log10 of an axis that is logged (rows with a
  #   value of zero or less are not drawn there); Spearman uses ranks, so the scale does not matter.
  logged = isTRUE(s$log_x) || isTRUE(s$log_y)
  shown = function(a, b, method) {
    if (!identical(method, "pearson") || !logged) return(list(a = a, b = b))
    ok = (!isTRUE(s$log_x) | a > 0) & (!isTRUE(s$log_y) | b > 0)
    list(a = if (isTRUE(s$log_x)) log10(a[ok]) else a[ok], b = if (isTRUE(s$log_y)) log10(b[ok]) else b[ok])
  }
  cor_of = function(a, b, method) {
    p = shown(a, b, method)
    if (length(p$a) < 3L || stats::sd(p$a) == 0 || stats::sd(p$b) == 0) NA_real_ else stats::cor(p$a, p$b, method = method)
  }
  pearson_word = if (logged) "Pearson correlation on the log scale shown" else "Pearson correlation"
  keys = unique(c(s$color, s$facet))
  grp = if (length(keys))
    unlist(purrr::map(purrr::keep(fact_groups(t, keys, nm), function(g) nrow(g$d) >= SPEC_FACTS_GROUP_N), function(g)
      paste0(pearson_word, " for ", g$who, " (", fact_count(nrow(g$d)), " rows): ", fact_r(cor_of(g$d[[s$x]], g$d[[s$y]], "pearson")))))
  fit = if (!identical(s$fit, "none")) {
    fkeys = unique(c(if (!isTRUE(s$.binned) && is.null(s$highlight)) s$color, s$facet))
    unlist(purrr::map(fact_groups(t, fkeys, nm), function(g) {
      d = g$d
      who = if (!is.null(g$who)) paste0(" for ", g$who) else ""
      if (!identical(fit_works(s, d[[s$x]], d[[s$y]]), "ok")) return(paste0("Fitted curve", who, ": none drawn"))
      tx = function(v) if (isTRUE(s$log_x)) log10(v) else v
      ty = function(v) if (isTRUE(s$log_y)) log10(v) else v
      keep = (!isTRUE(s$log_x) | d[[s$x]] > 0) & (!isTRUE(s$log_y) | d[[s$y]] > 0)
      dd = data.frame(x = tx(d[[s$x]][keep]), y = ty(d[[s$y]][keep]))
      f = if (identical(s$fit, "linear")) stats::lm(y ~ x, dd) else stats::loess(y ~ x, dd)
      xq = stats::quantile(d[[s$x]][keep], SPEC_FACTS_FIT_AT, names = FALSE)
      yq = stats::predict(f, data.frame(x = tx(xq)))
      yq = if (isTRUE(s$log_y)) 10^yq else yq
      paste0("Fitted ", lab(s$y), who, " at the 10th, 30th, 50th, 70th and 90th percentiles of ", lab(s$x), " (", paste(num(xq), collapse = ", "),
             "): ", paste(num(yq), collapse = ", "))
    }))
  }
  hl = if (!is.null(s$highlight)) {
    d = t[t$highlighted, , drop = FALSE]
    paste0("Highlighted point ", nm(s$highlight$column, d[[s$highlight$column]]), ": ", lab(s$x), " = ", num(d[[s$x]]), "; ", lab(s$y), " = ", num(d[[s$y]]))
  }
  pearson = cor_of(x, y, "pearson"); spearman = cor_of(x, y, "spearman")
  c(paste0("Points: ", fact_count(nrow(t))),
    paste0("Range of ", lab(s$x), ": ", num(min(x)), " to ", num(max(x))),
    paste0("Range of ", lab(s$y), ": ", num(min(y)), " to ", num(max(y))),
    if (identical(s$family, "bubble")) paste0("Range of ", lab(s$size), ": ", num(min(t[[s$size]])), " to ", num(max(t[[s$size]]))),
    paste0(pearson_word, ": ", fact_r(pearson)),
    if (isTRUE(abs(spearman - pearson) > 0.1))
      c(paste0("Spearman correlation: ", fact_r(spearman)),
        paste0("The two differ, so the relationship is not a straight line", if (logged) " on the log scale shown", ".")),
    grp, fit, hl)
}

# A histogram's facts; its bins are the ones ggplot2 draws (the same breaks in every panel).
facts_histogram <- function(s, cb, t, nm) {
  num = function(x) fact_num(x, FALSE)
  p = ggplot2::ggplot(t, ggplot2::aes(x = .data[[s$x]])) + ggplot2::geom_histogram(bins = as.numeric(s$bins)) +
    if (isTRUE(s$log_x)) ggplot2::scale_x_log10()
  if (!is.null(s$facet)) p = p + ggplot2::facet_wrap(ggplot2::vars(.data[[s$facet]]))
  built = ggplot2::ggplot_build(p)
  bins = built$data[[1]]
  back = function(v) if (isTRUE(s$log_x)) 10^v else v
  panels = if (is.null(s$facet)) list(list(d = t, b = bins, head = NULL))
    else {
      lay = built$layout$layout
      purrr::map(seq_len(nrow(lay)), function(i) {
        k = as.character(lay[[s$facet]][i])
        list(d = t[as.character(t[[s$facet]]) == k, , drop = FALSE], b = bins[bins$PANEL == lay$PANEL[i], , drop = FALSE],
             head = paste0("Panel ", cb_label(cb, s$facet), " = ", nm(s$facet, k), ":"))
      })
    }
  unlist(purrr::map(panels, function(pn) {
    x = pn$d[[s$x]]
    q = stats::quantile(x, c(0.25, 0.5, 0.75), names = FALSE)
    top = pn$b[which.max(pn$b$count), ]
    body = c(paste0("Rows: ", fact_count(length(x))), paste0("Minimum: ", num(min(x))), paste0("Lower quartile: ", num(q[1])),
             paste0("Median: ", num(q[2])), paste0("Upper quartile: ", num(q[3])), paste0("Maximum: ", num(max(x))), paste0("Mean: ", num(mean(x))),
             paste0("Bin with the most rows: ", num(max(back(top$xmin), min(x))), " to ", num(min(back(top$xmax), max(x))), ", ", fact_count(top$count), " rows"))
    c(pn$head, if (is.null(pn$head)) body else paste0("  ", body))
  }))
}

facts_box <- function(s, cb, t, nm) {
  num = function(x) fact_num(x, FALSE)
  groups = fact_split(t, s$x)
  med = purrr::map_dbl(groups, function(d) stats::median(d[[s$y]]))
  shown = nm(s$x, names(groups))
  c(unname(purrr::map2_chr(groups, shown, function(d, k) {
      y = d[[s$y]]; q = stats::quantile(y, c(0.25, 0.5, 0.75), names = FALSE)
      paste0(k, ": rows ", fact_count(length(y)), ", median ", num(q[2]), ", quartiles ", num(q[1]), " and ", num(q[3]),
             ", minimum ", num(min(y)), ", maximum ", num(max(y)))
    })),
    paste0("Highest median: ", paste(shown[fact_same(med, max(med))], collapse = ", "), " (", num(max(med)), ")"),
    paste0("Lowest median: ", paste(shown[fact_same(med, min(med))], collapse = ", "), " (", num(min(med)), ")"))
}

# `rows` are the rows of the data behind the chart (after the filter and the rows left out for
#   missing values); a row's and a column's value is the spec's own function of all of its rows, not
#   a mean of cells. Without `rows` the facts give the cells only.
facts_heatmap <- function(s, cb, t, nm, fmt, rows = NULL) {
  v = value_name(s)
  lab = function(col) cb_label(cb, col)
  cell = paste0(nm(s$y, t[[s$y]]), ", ", nm(s$x, t[[s$x]]), ": ", fmt(t[[v]]))
  cells = if (nrow(t) <= SPEC_HEAT_LABELS) c("Cells (row, column: value):", paste0("- ", cell))
    else {
      o = order(-t[[v]])
      c(paste0("Highest ", SPEC_FACTS_CELLS, " cells (row, column: value):"), paste0("- ", cell[utils::head(o, SPEC_FACTS_CELLS)]),
        paste0("Lowest ", SPEC_FACTS_CELLS, " cells (row, column: value):"), paste0("- ", cell[utils::head(rev(o), SPEC_FACTS_CELLS)]))
    }
  how = switch(s$fn, count = "count", sum = "total", median = "median", "mean")
  of = function(d) switch(s$fn, count = nrow(d), sum = sum(d[[v]]), median = stats::median(d[[v]]), mean(d[[v]]))
  by = function(col, word) {
    keys = names(fact_split(t, col))
    r = as.character(rows[[col]])
    a = purrr::map_dbl(keys, function(k) of(rows[r == k, , drop = FALSE]))
    k = nm(col, keys)
    who = function(at) paste0("All rows in ", paste(k[at], collapse = " and "), ": ", how, " ", fmt(max(a[at])), if (sum(at) > 1L) " each")
    c(paste0(word, " (", lab(col), ") with the highest value: ", who(fact_same(a, max(a)))),
      paste0(word, " (", lab(col), ") with the lowest value: ", who(fact_same(a, min(a)))))
  }
  c(cells, if (!is.null(rows)) c(by(s$y, "Row"), by(s$x, "Column")))
}

# The facts a headline and summary may use, computed by R from the plotted table (spec_table()) and
#   the spec, never by a model: plain text, one fact per line, each number written as R wants it
#   quoted. The values of id and text columns are tokens ([[N1]], ...). With facet, families other
#   than scatter, bubble and histogram give their facts within each panel. `exploratory` is the
#   chart's, which the spec does not hold. `data` is the file's data (before the filter), optional:
#   a heatmap needs it for the value of each row and column, which is computed from the rows of the
#   data; without it those lines are left out. Returns list(text, names), names giving token = name.
spec_facts <- function(spec, table, cb, exploratory = FALSE, data = NULL) {
  s = spec_settle(spec_defaults(spec_public(spec)), cb, table)
  s$.binned = spec$.binned
  namer = fact_namer(cb)
  nm = namer$name
  fmt = fact_value_fmt(s)
  head = facts_head(s, cb, table, nm, exploratory)
  base = if (!is.null(data) && identical(s$family, "heatmap")) run_steps(data, table_steps(s, cb)$base)
  body_of = function(t, rows = base) switch(s$family,
    bar = , dot = facts_bars(s, cb, t, nm, fmt),
    line = facts_lines(s, cb, t, nm, fmt),
    slope = facts_slope(s, cb, t, nm, fmt),
    box = facts_box(s, cb, t, nm),
    heatmap = facts_heatmap(s, cb, t, nm, fmt, rows))
  t = as.data.frame(table)
  body = if (s$family %in% c("scatter", "bubble")) facts_scatter(s, cb, t, nm)
    else if (identical(s$family, "histogram")) facts_histogram(s, cb, t, nm)
    else if (!is.null(s$facet) && !identical(s$facet, s$color))
      unlist(purrr::imap(utils::head(fact_split(t, s$facet), SPEC_FACET_MAX), function(d, k)
        c(paste0("Panel ", cb_label(cb, s$facet), " = ", nm(s$facet, k), ":"),
          paste0("  ", body_of(d, if (!is.null(base)) base[as.character(base[[s$facet]]) == k, , drop = FALSE])))))
    else body_of(t)
  list(text = paste(c(head, body), collapse = "\n"), names = namer$map())
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

# A font family as a CSS font-family list for the page (the bundled families are declared with @font-face,
#   see CHART_FONT_CSS in R/ui.R): the family, then the generic one it falls back to. The default names
#   "sans" and "serif" that charts fall back to are not CSS names.
font_css <- function(family) {
  bundled = purrr::keep(CHART_FONTS, function(f) startsWith(family, f$family))
  if (length(bundled)) (if (identical(family, bundled[[1]]$family)) bundled[[1]]$css else paste0("'", family, "', ", bundled[[1]]$css))
  else switch(family, sans = "sans-serif", serif = "serif", family)
}

# Every font family in a built plotly figure, as a CSS list.
font_stacks <- function(x, in_font = FALSE) {
  if (!is.list(x)) return(x)
  keys = names(x) %||% rep("", length(x))
  out = purrr::map2(x, keys, function(el, key) {
    if (in_font && identical(key, "family") && is.character(el)) return(font_css(el))
    # a blank axis text (a value axis with every value written on its marks) comes back from ggplotly() with no family: the chart's sans
    if (in_font && identical(key, "family") && length(el) == 1L && is.na(el)) return(font_css(chart_font_family("sans")))
    font_stacks(el, in_font || key %in% c("font", "tickfont", "titlefont"))
  })
  names(out) = names(x)
  out
}

wrapped <- function(text, width) paste(strwrap(text, width), collapse = "<br>")

# Where plotly puts the text of a label relative to its point: above it, to the right of a sideways bar or dot, on the point
#   for a heatmap cell. plotly takes no justification from the chart's hjust and vjust.
widget_text_position <- function(s) {
  if (identical(s$family, "heatmap")) "middle center"
  else if (s$family %in% c("bar", "dot") && isTRUE(s$.flip)) "middle right"
  else "top center"
}

# What the interactive version does not carry over from the static chart of a spec as the lint left it (labels and
#   annotations; nothing is dropped without a sentence): the line-end labels (it has a legend instead), the positions
#   (each label sits against its mark in one way), and the labels that would run into one another, which the static
#   chart moves apart with ggrepel and plotly cannot.
widget_notes <- function(s) {
  fam = s$family
  c(if (isTRUE(s$.labels) && fam %in% c("line", "slope"))
      "The names and values at the line ends are not drawn in the interactive version: it has a legend, and a value shows when you point at a line.",
    if (isTRUE(s$.value_labels) || isTRUE(s$.names) || length(s$.annotate))
      paste0("In the interactive version a label is not bold and sits ", if (s$family %in% c("bar", "dot") && isTRUE(s$.flip)) "to the right of its mark" else "above its mark",
             ", wherever the static chart puts it; ggrepel does not move it.")
    else NULL,
    if (length(s$.widget_left_out))
      paste0(s$.widget_left_out, if (s$.widget_left_out == 1L) " label that the static chart moves apart is" else " labels that the static chart moves apart are",
             " left out of the interactive version because they would run into another label or a mark."))
}

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
  w$x$layout = font_stacks(scale_fonts(w$x$layout, SPEC_PLOTLY_TEXT))
  # A label is a text trace; plotly puts its text on the point unless told where.
  w$x$data = purrr::map(w$x$data, function(tr) {
    if (identical(tr$mode, "text")) {
      tr$textposition = widget_text_position(s)
      tr$textfont$family = font_css(chart_font_family("sans"))
    }
    tr
  })
  st = chart_style(palette$style)
  sub_css = font_css(chart_font_family(st$subtitle_font))
  title_lines = c(if (!is.null(s$title)) paste0("<b>", wrapped(s$title, SPEC_WRAP_TITLE), "</b>"),
                  if (!is.null(s$subtitle)) paste0("<span style=\"font-size:0.8em;font-weight:normal;color:", st$text_2, ";font-family:", sub_css, "\">",
                                                   wrapped(s$subtitle, SPEC_WRAP_SUBTITLE), "</span>"))
  if (length(title_lines)) {
    n_lines = sum(lengths(regmatches(title_lines, gregexpr("<br>", title_lines)))) + length(title_lines)
    w$x$layout$title = utils::modifyList(w$x$layout$title %||% list(),
                                         list(text = paste(title_lines, collapse = "<br>"), x = 0.01, xanchor = "left",
                                              xref = "container",
                                              font = list(family = font_css(chart_font_family(st$title_font)), color = st$text)))
    w$x$layout$margin$t = 30 + 22 * n_lines
  }
  if (!is.null(s$caption)) {
    w$x$layout$annotations = c(w$x$layout$annotations,
                               list(list(text = wrapped(s$caption, SPEC_WRAP_SUBTITLE), x = 0, y = 0, xref = "paper", yref = "paper",
                                         xanchor = "left", yanchor = "top", yshift = -45, showarrow = FALSE,
                                         font = list(size = 11, color = st$caption, family = font_css(chart_font_family("sans"))))))
    w$x$layout$margin$b = (w$x$layout$margin$b %||% 40) + 30
  }
  w$x$layout$legend = utils::modifyList(w$x$layout$legend %||% list(),
                                        list(x = 1.02, y = 1, xanchor = "left", yanchor = "top", orientation = "v"))
  # A style's thin rule under the title block: the static chart draws it as a second axis line, which plotly drops
  #   without a word, so the figure gets it as a line across the top of its plot area.
  if (!is.na(st$rule))
    w$x$layout$shapes = c(w$x$layout$shapes, list(list(type = "line", xref = "paper", yref = "paper", x0 = 0, x1 = 1, y0 = 1, y1 = 1,
                                                       line = list(color = st$rule, width = 1))))
  w = plotly::config(w, displaylogo = FALSE, modeBarButtons = list(list("toImage")))
  attr(w, "warnings") = unique(said)
  attr(w, "notes") = widget_notes(s)
  w
}

# The static chart at SPEC_DPI pixels per inch and its size in inches, drawn on the device chart_device() opens
#   (ragg, else cairo, else svglite: a PNG, or an SVG on a server that has only svglite; the file's ending and media
#   type are chart_device_ext() and chart_device_type()). Returns the size in inches, invisibly.
spec_png <- function(plot, file, size = spec_size(attr(plot, "spec"), attr(plot, "table")), dpi = SPEC_DPI, kind = chart_device_kind()) {
  chart_device(file, size[["width"]], size[["height"]], dpi, kind)
  on.exit(grDevices::dev.off())
  print(plot)
  invisible(size)
}

# Width and height in inches for the static figure: 7 by 4.5, taller for sideways bars with many
#   rows and for rows of panels, wider for four or more panels across.
spec_size <- function(spec, table) {
  web = !is.null(spec$.fig_width)
  w = spec$.fig_width %||% SPEC_SIZE[["width"]]
  h = spec$.fig_height %||% SPEC_SIZE[["height"]]
  save = if (isTRUE(spec$.bare)) SPEC_BARE_INCHES else 0
  if (isTRUE(spec$.flip) && !is.null(spec$x))
    h = max(h, 1.5 - save + SPEC_ROW_INCHES * length(unique(table[[spec$x]])))
  if (!is.null(spec$facet)) {
    panels = length(unique(table[[spec$facet]]))
    across = fig_across(spec, panels)
    h = max(h, 1.3 - save + SPEC_PANEL_INCHES * ceiling(panels / across))
    if (!web && across >= 4) w = SPEC_SIZE[["max_width"]]
  }
  c(width = w, height = min(h, SPEC_SIZE[["max_height"]]))
}

# How many panels of small multiples stand side by side: the squarest grid, and for a drawing made for a screen (a width given) no
#   more than leave each panel SPEC_PANEL_MIN_IN of width.
fig_across <- function(s, panels) {
  across = ceiling(sqrt(panels))
  if (is.null(s$.fig_width)) across else min(across, max(1L, floor((s$.fig_width - 0.3) / SPEC_PANEL_MIN_IN)))
}
