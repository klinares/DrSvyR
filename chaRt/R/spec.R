# spec.R for chaRt
# The plot spec (DESIGN.md section 6, as revised by the Phase 2 prompt): defaults, the check
#   against the codebook, the table that is drawn, the lint, the ggplot, the interactive version (ggiraph), the R
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
SPEC_ALPHA_N <- 2000L        # points above this many are drawn transparent (a scatter: under `density` auto, as binned counts instead)
SPEC_BIN_N <- 20000L         # a bubble chart's points above this many are drawn as binned counts
SPEC_WIDGET_N <- 5000L       # marks above this many: no interactive version (each mark is an element of the page with its tooltip)
SPEC_BINS <- c(5L, 60L)      # a histogram's bins, given or chosen
SPEC_ALPHA <- 0.3            # transparency of crowded points
SPEC_BIN_2D <- 30L           # bins across each axis of a binned scatter, on the scale that is drawn (Phase 10b: about 30)
SPEC_VIOLIN_ALPHA <- 0.2      # the fill of a violin: the series colour at this opacity (Phase 10b)
SPEC_BIN_DISTINCT <- 40L     # an axis with at most this many different values is binned at those values, not at an even grid
SPEC_FIT_GAP_BINS <- 2L      # a fitted curve is broken where this many cells in a row hold no row of x
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

SPEC_FAMILIES <- c("bar", "dot", "line", "slope", "scatter", "bubble", "histogram", "box", "heatmap", "dumbbell")
SPEC_FNS <- c("none", "count", "share", "sum", "mean", "median")
SPEC_OPS <- c("==", "!=", ">", ">=", "<", "<=", "in")
SPEC_SORTS <- c("value_desc", "value_asc", "level_order", "alphabetical")
SPEC_FITS <- c("none", "loess", "linear")
SPEC_DENSITY <- c("auto", "off", "on")      # a scatter's crowded points as counts in cells
SPEC_SHAPES <- c("box", "violin")           # a box chart's marks
SPEC_INDEX <- c("none", "first")            # a line chart divided by each series' first value
SPEC_SMOOTH <- c(2L, 24L)                   # a line chart's moving average, in periods ("none" is no average)
SPEC_VIOLIN_MIN <- 30L                      # a group of fewer rows than this is drawn as a plain box under shape violin
SPEC_FIELDS <- c("family", "x", "y", "color", "size", "facet", "fn", "filter", "top_n", "sort", "log_x", "log_y",
                 "fit", "rug", "bins", "free_y", "highlight", "title", "subtitle", "caption", "x_label", "y_label",
                 "interactive", "rule", "say", "midpoint", "labels", "annotate", "density", "shape", "index", "smooth")
SPEC_COLUMN_FIELDS <- c("x", "y", "color", "size", "facet")
SPEC_TEXT_FIELDS <- c("title", "subtitle", "caption", "x_label", "y_label", "rule", "say")
SPEC_FLAG_FIELDS <- c("log_x", "log_y", "rug", "free_y", "interactive")

# Fields the lint adds; never accepted from outside.
SPEC_LINT_FIELDS <- c(".flip", ".alpha", ".binned", ".jitter", ".negative", ".labels", ".legend_order", ".legend_levels", ".colour_levels", ".cell_labels", ".top_n",
                      ".violin", ".plain_box", ".index_unit", ".index_start", ".name_room",
                      ".fit_range", ".bin_breaks", ".hex", ".label_series", ".n_colours", ".annotate", ".value_labels", ".names", ".label_rows", ".repel",
                      ".end_value", ".source", ".end_room", ".x_range", ".value_room", ".value_axis_bare", ".rug_floor",
                      ".fig_width", ".fig_height", ".bare", ".few_breaks", ".facet_cols")


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

# The column top_n and highlight act on in a bar, dot, line, slope or dumbbell.
ranked_column <- function(s) if (s$family %in% c("bar", "dot")) s$x else if (identical(s$family, "dumbbell")) s$y else s$color


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
  if (is_flag1(s$density)) s$density = if (s$density) "on" else "off"
  s
}

# What the four forms of Phase 10 Part C say, read from the spec: `density` (absent is auto), the moving average's periods (NULL for none or
#   absent), and whether a line chart is indexed to its first value.
density_mode <- function(s) s$density %||% "auto"
smooth_k <- function(s) if (is_whole1(s$smooth)) as.integer(s$smooth)
index_first <- function(s) identical(s$index, "first")
violin_shape <- function(s) identical(s$family, "box") && identical(s$shape, "violin")

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
  heatmap = list(x = c("group", "time"), y = "group", color = "measure"),
  dumbbell = list(y = c("group", "name"), x = "measure", color = "group"))

# The column fields each family must have.
SPEC_REQUIRED <- list(bar = "x", dot = "x", line = c("x", "y"), slope = c("x", "y", "color"), scatter = c("x", "y"),
                      bubble = c("x", "y", "size"), histogram = "x", box = c("x", "y"), heatmap = c("x", "y"),
                      dumbbell = c("x", "y", "color"))

# The functions each family allows. `on` names the field whose presence decides: `without` when it
#   is absent, `with` when it is given; a family with no `on` allows `with` always.
SPEC_FAMILY_FNS <- list(
  bar = list(on = "y", without = c("count", "share"), with = c("sum", "mean", "median", "none")),
  dot = list(on = "y", without = c("count", "share"), with = c("sum", "mean", "median", "none")),
  line = list(with = c("sum", "mean", "median", "none")),
  slope = list(with = c("sum", "mean", "median", "none")),
  scatter = list(with = "none"), bubble = list(with = "none"), histogram = list(with = "none"), box = list(with = "none"),
  heatmap = list(on = "color", without = "count", with = c("sum", "mean", "median")),
  dumbbell = list(with = c("sum", "mean", "median", "none")))

# The families a field is for, when it is not for every family.
SPEC_FIELD_FAMILIES <- list(
  facet = setdiff(SPEC_FAMILIES, c("slope", "dumbbell")),
  top_n = c("bar", "dot", "line", "slope", "dumbbell"),
  sort = c("bar", "dot", "box"),
  fit = c("scatter", "bubble"),
  rug = "scatter",
  bins = "histogram",
  midpoint = "heatmap",
  log_x = c("scatter", "bubble", "histogram"),
  log_y = c("bar", "dot", "line", "scatter", "bubble", "box"),
  highlight = c("bar", "dot", "line", "slope", "scatter", "bubble"),
  labels = c("bar", "dot", "line", "slope", "scatter", "bubble", "heatmap"),
  annotate = c("bar", "dot", "line", "scatter", "bubble"),
  density = "scatter",
  shape = "box",
  index = "line",
  smooth = "line")

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
    if (identical(f, "color") && identical(fam, "dumbbell") && is.null(s$filter) && e$distinct != 2L)
      return(paste0("color: '", v, "' has ", e$distinct, " values; a dumbbell compares exactly two. Filter the column to two values, or use lines or small multiples."))
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
    check_highlight(s, cb), check_labels(s), check_annotate(s), check_forms(s))
  unique(out)
}

# The four forms of Phase 10 Part C (density, shape, index, smooth): each takes its words, is for its family only, and a moving average
#   takes no highlight and no annotate (a mark would name a raw value on a smoothed chart).
check_forms <- function(s) {
  fam = s$family
  words = function(f, ok) paste0(f, " must be one of ", paste(ok, collapse = ", "), ".")
  only = function(f, what) paste0(f, ": only a ", or_list(SPEC_FIELD_FAMILIES[[f]]), " chart ", what, " (a ", fam, " chart was given one).")
  c(if (!is.null(s$density)) {
      if (!is_text1(s$density) || !s$density %in% SPEC_DENSITY) words("density", SPEC_DENSITY)
      else if (!field_for("density", fam)) only("density", "counts rows in cells")
      else if (identical(s$density, "on") && !is.null(s$highlight))
        "density: counting rows in cells leaves no single point to highlight; use auto or off, or drop the highlight."
    },
    if (!is.null(s$shape)) {
      if (!is_text1(s$shape) || !s$shape %in% SPEC_SHAPES) words("shape", SPEC_SHAPES)
      else if (!field_for("shape", fam)) only("shape", "has a shape")
    },
    if (!is.null(s$index)) {
      if (!is_text1(s$index) || !s$index %in% SPEC_INDEX) words("index", SPEC_INDEX)
      else if (!field_for("index", fam)) only("index", "can be indexed")
      else if (identical(s$index, "first") && !is.null(s$facet))
        "index puts every series in one panel; remove `facet`, and use `highlight` for the few series the question is about."
    },
    if (!is.null(s$smooth)) {
      if (!(is_text1(s$smooth) && identical(s$smooth, "none")) && !(is_whole1(s$smooth) && s$smooth >= SPEC_SMOOTH[1] && s$smooth <= SPEC_SMOOTH[2]))
        paste0("smooth must be none, or a whole number of periods from ", SPEC_SMOOTH[1], " to ", SPEC_SMOOTH[2], ".")
      else if (!field_for("smooth", fam)) only("smooth", "takes a moving average")
      else if (!is.null(smooth_k(s)) && (!is.null(s$highlight) || length(values_of(s$annotate))))
        "smooth: a chart with a moving average takes no highlight and no annotate; leave them out, or set smooth to none."
    })
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
        density = paste0("one of ", paste(SPEC_DENSITY, collapse = ", "), ": auto counts rows in cells when a scatter has over ", SPEC_ALPHA_N, " points; only when asked"),
        shape = paste0("one of ", paste(SPEC_SHAPES, collapse = ", "), ": violin shows the shape of each group of ", SPEC_VIOLIN_MIN, " rows or more; only when asked"),
        index = paste0("one of ", paste(SPEC_INDEX, collapse = ", "), ": first divides each line by its first value, times 100, all the lines in one panel (no facet)"),
        smooth = paste0("none, or a whole number from ", SPEC_SMOOTH[1], " to ", SPEC_SMOOTH[2], ": a moving average over the raw line; not with highlight or annotate; only when asked"),
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
value_name <- function(s) switch(s$fn, count = "n", share = "share", measure_of(s))

# The column that holds the measure when the table is not counted: a heatmap's colour, a dumbbell's x, otherwise y.
measure_of <- function(s) switch(s$family, heatmap = s$color, dumbbell = s$x, s$y)

group_columns <- function(s) switch(s$family, dumbbell = unique(c(s$y, s$color)),
  unique(c(s$x, if (identical(s$family, "heatmap")) s$y else s$color, s$facet)))

# The column a line's moving average is written to (Phase 10 Part C), and the column the plot draws as the line's value.
SMOOTH_COLUMN <- "moving_average"
plotted_value <- function(s) if (!is.null(smooth_k(s))) SMOOTH_COLUMN else value_name(s)

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
  # A dumbbell is sorted by its later value (the later of its colour's two values, the second level), largest on top; top_n keeps the
  #   first n groups of that order. The colour is made a factor first (its level order, or alphabetical), so that "later" is its larger code.
  if (identical(fam, "dumbbell")) {
    col = sym(s$color); y = sym(s$y); v = sym(value_name(s))
    code = call("as.integer", col)
    return(c(list(mutate_call(s$color, level_order_call(cb_entry(cb, s$color), s$color))),
             list(mutate_call(".later", call("sum", call("if_else", call("==", code, call("max", code)), v, 0)), s$y),
                  call("arrange", call("desc", sym(".later")), y)),
             if (!is.null(s$top_n)) list(call("filter", call("<=", call("consecutive_id", y), as.numeric(top_of(s))))),
             list(mutate_call(s$y, call("factor", y, levels = call("unique", y))), call("select", call("-", sym(".later"))))))
  }
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
  want = c(if (!is.null(s$color) && !fam %in% c("heatmap", "dumbbell")) s$color,
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

# A line chart indexed to its first value (Phase 10 Part C): each series (a colour, a panel, or both) divided by its value at its first x and
#   multiplied by 100. It comes after top_n, which ranks by the amounts.
index_calls <- function(s) {
  if (!index_first(s)) return(NULL)
  v = value_name(s)
  by = unique(c(s$color, s$facet))
  list(as.call(c(list(sym("mutate")),
                 stats::setNames(list(call("/", call("*", 100, sym(v)), call("first", sym(v), order_by = sym(s$x)))), v),
                 if (length(by)) list(.by = by_arg(by)))))
}

# The trailing moving average of the plotted value over `smooth` points of a series, in a column of its own; NA until a series has that many.
#   Rows are put in the order of x first (the average runs along it).
smooth_calls <- function(s) {
  k = smooth_k(s)
  if (is.null(k)) return(NULL)
  by = unique(c(s$color, s$facet))
  avg = call("as.numeric", as.call(list(call("::", sym("stats"), sym("filter")), sym(value_name(s)), call("rep", call("/", 1, as.numeric(k)), as.numeric(k)), sides = 1)))
  list(call("arrange", sym(s$x)),
       as.call(c(list(sym("mutate")), stats::setNames(list(avg), SMOOTH_COLUMN), if (length(by)) list(.by = by_arg(by)))))
}

# The table's steps, as calls without their data argument, in three parts: `base` (the filter and
#   the rows left out for missing values), `agg` (the aggregation) and `post` (top_n, the order,
#   the index and the moving average, factors, the highlight). The data checks run after `base`; ties are counted after `agg`; `ranked` is
#   how many steps of `post` come before the index (the rows the index check reads).
table_steps <- function(s, cb) {
  ranked = rank_calls(s, cb)
  list(base = purrr::compact(list(filter_call(s, cb), as.call(c(sym("drop_na"), purrr::map(spec_columns(s), sym))))),
       agg = aggregate_calls(s),
       post = purrr::compact(c(ranked, index_calls(s), smooth_calls(s), list(factor_call(s, cb), highlight_call(s, cb)))),
       ranked = length(ranked))
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
  list2env(list(chart_number = fact_num, chart_count = fact_count, chart_fixed = fact_fixed, chart_date = fact_date), envir = e)
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
  if (identical(fam, "dumbbell") && nd(s$color) != 2L)
    spec_fail(paste0("color: a dumbbell needs exactly two values of '", s$color, "' after the filter; it has ", nd(s$color), ". Filter the column to two values."))
  if (identical(fam, "dumbbell") && is.null(s$top_n) && nd(s$y) > SPEC_TOP_MAX)
    spec_fail(paste0("y: '", s$y, "' has ", nd(s$y), " values after the filter; use top_n (at most ", SPEC_TOP_MAX, ") or a filter that leaves at most ", SPEC_TOP_MAX, "."))
  if (identical(s$fn, "none") && fam %in% c("bar", "dot", "line", "slope", "dumbbell")) {
    keys = if (identical(fam, "dumbbell")) unique(c(s$y, s$color)) else unique(c(s$x, s$color, s$facet))
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

# The rules that need the aggregated table (Phase 10 Part C). `agg` is the table after the aggregation, `kept` the rows left after top_n
#   (the ones drawn). A dumbbell needs both values of its colour for every group. An index needs every line to start at the chart's first
#   x, with a positive value. A moving average needs every line to have at least that many points. A series is named when its column is
#   a group (an id or text column's values are never put in a sentence).
agg_checks <- function(s, cb, agg, kept) {
  who = function(col, keys) {
    keys = unique(as.character(keys))
    if (is_group_like(cb_entry(cb, col)))
      paste0(if (length(keys) > 3L) paste0(paste0("'", utils::head(keys, 3L), "'", collapse = ", "), " and ", length(keys) - 3L, " more") else paste0("'", keys, "'", collapse = ", "))
    else paste0(length(keys), if (length(keys) == 1L) " value" else " values", " of '", col, "'")
  }
  if (identical(s$family, "dumbbell")) {
    both = tapply(as.character(kept[[s$color]]), as.character(kept[[s$y]]), function(x) length(unique(x)))
    one = sum(both < 2L) == 1L
    if (any(both < 2L))
      spec_fail(paste0("color: ", who(s$y, names(both)[both < 2L]), if (one) " has" else " have", " only one of the two values of '", s$color,
                       "', so no gap can be drawn; filter ", if (one) "it" else "them", " out."))
  }
  if (!identical(s$family, "line") || (!index_first(s) && is.null(smooth_k(s)))) return(invisible(TRUE))
  keys = unique(c(s$color, s$facet))
  series = if (length(keys)) split(seq_len(nrow(kept)), lapply(keys, function(k) as.character(kept[[k]])), drop = TRUE) else list(seq_len(nrow(kept)))
  col = if (length(keys)) keys[[1]]
  name_of = function(ix) if (!is.null(col)) as.character(kept[[col]][ix[[1]]]) else "the line"
  if (index_first(s)) {
    v = value_name(s)
    start = min(kept[[s$x]])
    bad = purrr::keep(series, function(ix) {
      d = kept[ix, , drop = FALSE]
      first = d[[v]][which.min(d[[s$x]])]
      min(d[[s$x]]) != start || !is.finite(first) || first <= 0
    })
    one = length(bad) == 1L
    if (length(bad))
      spec_fail(paste0("index: ", if (!is.null(col)) who(col, purrr::map_chr(bad, name_of)) else "the line", if (one) " has" else " have",
                       " no value above zero at the chart's first ", cb_label(cb, s$x), " (the first value is zero, below zero or missing), so ",
                       if (one) "it" else "they", " cannot be indexed. Leave index out, or filter ", if (one) "it" else "them", " out."))
  }
  k = smooth_k(s)
  if (!is.null(k)) {
    short = purrr::keep(series, function(ix) length(ix) < k)
    one = length(short) == 1L
    if (length(short))
      spec_fail(paste0("smooth: a moving average of ", k, " periods needs ", k, " points in a line, but ",
                       if (!is.null(col)) paste0(who(col, purrr::map_chr(short, name_of)), if (one) " has" else " have", " fewer")
                       else paste0("the line has only ", length(short[[1]])),
                       "; use a smaller smooth, or filter the short lines out."))
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
  if (!is.null(s$.top_n)) st <- table_steps(s, cb)
  if (s$family %in% c("line", "dumbbell")) agg_checks(s, cb, agg, run_steps(agg, st$post[seq_len(st$ranked)]))
  out = run_steps(agg, st$post)
  ranked = if (s$family %in% c("bar", "dot", "line", "slope", "dumbbell")) ranked_column(s)
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
  # The subtitle R writes when the analyst has not: the top_n's, and a moving average's ("<k>-period moving average; raw values in grey").
  auto = c(if (!is.null(s$top_n)) paste0("Top ", top_of(s), " of ", attr(table, "groups_total")),
           if (!is.null(smooth_k(s))) paste0(smooth_k(s), "-period moving average; raw values in grey"))
  if (length(auto) && is.null(s$subtitle)) s$subtitle = paste(auto, collapse = "; ")
  s
}

# The word a line's index title uses for its first period: "month" or "quarter" (a series of dates a month or a quarter apart), "year"
#   (a year apart), otherwise "period".
index_unit <- function(x) {
  x = sort(unique(x))
  p = fact_period(x)
  if (!is.null(p)) return(p)
  if (inherits(x, c("Date", "POSIXt")) && length(x) >= 3L && isTRUE(stats::median(as.numeric(diff(as.Date(x)))) %in% c(365, 366))) return("year")
  "period"
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
  # Over cells (Phase 10b) the curve is drawn only where there are rows: the range is cut at every stretch of SPEC_FIT_GAP_BINS empty cells
  #   along x (fit_runs()), one run of x for each stretch with rows.
  runs_of = function(x, r) if (isTRUE(s$.binned) && !is.null(s$.bin_breaks)) fit_runs(x, r, s$.bin_breaks$x, isTRUE(s$log_x))
  keys = unique(c(if (!isTRUE(s$.binned) && is.null(s$highlight)) s$color, s$facet))
  parts = if (!length(keys)) list(as.data.frame(table))
          else unname(split(as.data.frame(table), lapply(keys, function(k) as.character(table[[k]])), drop = TRUE))
  plan = purrr::map(parts, function(d) {
    range = if (nrow(d) >= SPEC_FIT_TRIM_N) q(d[[s$x]])
    list(keys = if (length(keys)) purrr::set_names(purrr::map(keys, function(k) as.character(d[[k]][1])), keys),
         why = fit_works(s, d[[s$x]], d[[s$y]]), range = range, runs = if (!is.null(range)) runs_of(d[[s$x]], range))
  })
  ok = purrr::keep(plan, function(g) identical(g$why, "ok"))
  trimmed = purrr::keep(ok, function(g) !is.null(g$range))
  skip = purrr::discard(plan, function(g) identical(g$why, "ok"))
  if (!length(trimmed) && !length(skip)) return(NULL)
  list(groups = purrr::map(trimmed, function(g) g[c("keys", "range", "runs")]), skip = purrr::map(skip, function(g) g[c("keys", "why")]),
       rest = length(ok) > length(trimmed))
}

# The stretches of x a curve is drawn over (Phase 10b): the values of `x` inside `range` that fall in a cell of `edges` that holds a row,
#   cut where SPEC_FIT_GAP_BINS cells in a row hold none, as list(c(first x, last x)) for each stretch of rows. A stretch of one value is
#   left out; NULL when nothing is cut (the curve is one piece over `range`).
fit_runs <- function(x, range, edges, log) {
  x = x[is.finite(x) & x >= range[1] & x <= range[2] & (!log | x > 0)]
  cell = findInterval(x, edges, rightmost.closed = TRUE)
  occupied = sort(unique(cell))
  stretch = cumsum(c(1L, diff(occupied) > SPEC_FIT_GAP_BINS))
  if (max(stretch, 1L) < 2L) return(NULL)
  runs = purrr::map(unique(stretch), function(k) range(x[cell %in% occupied[stretch == k]]))
  purrr::keep(runs, function(r) r[2] > r[1])
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
  if (isTRUE(s$.binned)) return((if (!is.null(s$.bin_breaks)) (length(s$.bin_breaks$x) - 1L) * (length(s$.bin_breaks$y) - 1L) else SPEC_BIN_2D^2) * panels)
  nrow(table)
}

# Whether a line or slope chart's end labels fit: the end values in order, per panel, and whether
#   any two neighbours are closer than SPEC_LABEL_GAP of the y range. With a highlight, only the
#   highlighted lines are labelled. `order` is the lines from the highest end value down.
label_plan <- function(s, table) {
  v = plotted_value(s)
  rows = if (!is.null(s$highlight)) table[table$highlighted, , drop = FALSE] else table
  panel = if (!is.null(s$facet) && !identical(s$facet, s$color)) s$facet
  ends = if (identical(s$family, "slope")) rows[as.character(rows[[s$x]]) == levels(table[[s$x]])[2], , drop = FALSE]
         else dplyr::filter(rows, .data[[s$x]] == max(.data[[s$x]]), .by = dplyr::all_of(c(s$color, panel)))
  # a label is as tall in a shorter panel but takes a larger share of it: on a drawing made for a screen the gap grows with it
  #   (SPEC_LABEL_GAP is for the panel of the usual 7 by 4.5, 2.6 inches high)
  grow = if (is.null(s$.fig_width)) 1 else max(1, 2.6 / panel_inches(s, table)[["h"]])
  gap = SPEC_LABEL_GAP * grow * diff(range(table[[v]], na.rm = TRUE))
  groups = if (is.null(panel)) list(ends[[v]]) else split(ends[[v]], ends[[panel]])
  close = any(purrr::map_lgl(groups, function(vals) length(vals) > 1L && any(diff(sort(vals)) < gap)))
  list(fits = !close, order = unique(as.character(ends[[s$color]][order(-ends[[v]])])), ends = ends, gap = gap)
}

# Which of an indexed chart's line ends are named (Phase 10b): `ends` are the values the lines end at, `gap` the least distance two named ends
#   may lie apart. Taken in the order of how far an end is from 100, the start (the lines that grew or fell most first), a name is kept when
#   it lies at least `gap` from every name kept before it. Returns the positions kept, in the order of `ends`.
index_label_keep <- function(ends, gap) {
  order_by = order(-abs(ends - 100))
  sort(purrr::reduce(order_by, function(kept, i) if (all(abs(ends[kept] - ends[i]) >= gap)) c(kept, i) else kept, .init = integer(0)))
}

# The rules R enforces with no model call (DESIGN.md section 8). Fixes change the spec; notes are
#   sentences for the analyst. Returns list(spec, notes).
spec_lint <- function(spec, cb, table, max_colours = chart_palette_max()) {
  s = spec_settle(spec, cb, table)
  fam = s$family
  v = value_name(s)
  nd = function(col) length(unique(table[[col]]))
  notes = character(0)
  # The series of the colour column in the order the colours go to them (their levels): each colour is named by its series in the
  #   picture, the interactive view, the video and the code (series_values()), so no legend order and no view can give a series another colour.
  if (!is.null(s$color) && !identical(fam, "heatmap") && s$color %in% names(table)) s$.colour_levels = levels(droplevels(as.factor(table[[s$color]])))
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
  # An indexed line chart names the period it starts from (Phase 10 Part C); the picture depends on it.
  if (identical(fam, "line") && index_first(s) && nrow(table)) {
    first_x = min(table[[s$x]])
    s$.index_unit = index_unit(table[[s$x]])
    s$.index_start = fact_time(first_x, table[[s$x]])
    notes = c(notes, paste0("Every line is divided by its own value at the first ", s$.index_unit, " (", s$.index_start,
                            ") and multiplied by 100, so each starts at 100; the picture depends on the starting period."))
  }
  if (identical(fam, "line") && !is.null(smooth_k(s)))
    notes = c(notes, paste0("The grey line is the raw values; the line in colour is their moving average over ", smooth_k(s),
                            " periods, which starts at the ", smooth_k(s), "th point of a line, so it is shorter than the grey one."))
  # A dumbbell names its two values above its first row, on either side of its dots, and needs room on the value axis for the names.
  if (identical(fam, "dumbbell")) {
    w = 1.15 * 1.4 * max(nchar(as.character(unique(table[[s$color]])))) * SPEC_LABEL_CHAR_END_IN + 0.1     # bold type, and the label stands off its dot
    s$.name_room = round(max(0.05, 1.02 * w / max(0.5, fig_panel_w(s) - w)), 2)
  }
  # A violin (Phase 10 Part C): a group of at least SPEC_VIOLIN_MIN rows is drawn as a violin with its box inside, a group of fewer rows as
  #   a plain box, because a density drawn from few rows shows a shape that is not there.
  if (violin_shape(s)) {
    sizes = tapply(seq_len(nrow(table)), widget_keys(table, c(s$x, s$facet)), length)
    s$.violin = any(sizes >= SPEC_VIOLIN_MIN)
    s$.plain_box = any(sizes < SPEC_VIOLIN_MIN)
    few = gsub("\r", " / ", names(sizes)[sizes < SPEC_VIOLIN_MIN], fixed = TRUE)
    if (!s$.violin)
      notes = c(notes, paste0("No group has ", SPEC_VIOLIN_MIN, " rows, so every group is drawn as a plain box: a density from so few rows shows a shape that is not there."))
    else if (length(few))
      notes = c(notes, paste0(length(few), if (length(few) == 1L) " group has" else " groups have", " fewer than ", SPEC_VIOLIN_MIN, " rows (",
                              paste(utils::head(few, 3L), collapse = ", "), if (length(few) > 3L) paste0(" and ", length(few) - 3L, " more"),
                              "), so ", if (length(few) == 1L) "it is" else "they are", " drawn as a plain box: a density from so few rows shows a shape that is not there."))
  }
  # Many bars, dots or boxes, or long labels: drawn sideways.
  if (fam %in% c("bar", "dot", "box")) {
    labels = as.character(unique(table[[s$x]]))
    if (length(labels) > SPEC_FLIP_BARS || any(nchar(labels) > SPEC_FLIP_CHARS)) s$.flip = TRUE
    # On a drawing made for a screen the names have to stand side by side in the panel's width (about 0.085 inch a character, and a
    #   little between names), or the chart is drawn sideways, where each name has a line to itself.
    if (!is.null(s$.fig_width) && sum(nchar(labels)) * 0.085 + 0.12 * length(labels) > fig_panel_w(s)) s$.flip = TRUE
  }
  coloured = !is.null(s$color) && !identical(fam, "heatmap") && !identical(s$color, s$facet) && is.null(s$highlight) && !index_first(s)
  # A slope names its lines at their ends, so it is noted only past the palette's own limit.
  if (coloured && nd(s$color) > (if (identical(fam, "slope")) max_colours else SPEC_COLOURS))
    notes = c(notes, paste0(nd(s$color), " colours are hard to tell apart; highlight the few that matter, or use small multiples (facet)."))
  if (identical(fam, "line") && !is.null(s$color) && nd(s$color) > SPEC_LINES && is.null(s$highlight) && is.null(s$facet) && !index_first(s))
    notes = c(notes, paste0(nd(s$color), " lines overlap; small multiples (facet) or a highlight of the few that matter would read more easily."))
  # End labels on a line or slope chart only when no two would touch; otherwise a legend, in the
  #   order of the end values.
  #   `labels` decides first: off writes none, auto writes them for at most SPEC_LABEL_SERIES lines (a line chart), on
  #   whenever they fit. The value joins the name when both fit SPEC_LABEL_CHARS (a marked last point always carries it:
  #   lint_marks() merges the mark into the end label).
  mode = s$labels %||% "auto"
  v = plotted_value(s)     # the value the end labels sit at and write: a line's moving average when it has one
  if (identical(fam, "line") && index_first(s) && !is.null(s$color)) {
    # An indexed line chart (Phase 10b) is one panel of however many series; each line is named at its end where the names do not touch.
    #   The names are kept in the order of how far their lines ended from the start (the lines that grew or fell most first), the
    #   highlighted lines only when there is a highlight; the others are left out, and the notes say which. No legend.
    lab = label_plan(s, table)
    names_at = as.character(lab$ends[[s$color]])
    kept = index_label_keep(lab$ends[[v]], lab$gap)
    s$.labels = !identical(mode, "off") && length(kept) > 0L
    if (isTRUE(s$.labels)) {
      shown = names_at[kept]
      left = names_at[setdiff(seq_along(names_at), kept)]
      if (length(left)) {
        s$.label_series = shown
        notes = c(notes, paste0(length(left), if (length(left) == 1L) " line name is" else " line names are", " left out at the line ends because the ends lie too close together (",
                                paste(utils::head(left, 3L), collapse = ", "), if (length(left) > 3L) paste0(" and ", length(left) - 3L, " more"),
                                "); highlight the few lines that matter to name them."))
      }
      text = paste0(shown, "  ", fact_value_fmt(s)(lab$ends[[v]][kept]))
      s$.end_value = all(nchar(text) <= SPEC_LABEL_CHARS)
      narrow = !is.null(s$.fig_width) && s$.fig_width < SPEC_NARROW_IN
      if (narrow && isTRUE(s$.end_value) && end_room(text, fig_panel_w(s)) > SPEC_END_ROOM_NARROW) s$.end_value = FALSE
      s$.end_room = end_room(if (isTRUE(s$.end_value)) text else shown, fig_panel_w(s))
      if (narrow && s$.end_room > SPEC_END_ROOM_NARROW) {
        s$.labels = FALSE
        s$.label_series = NULL
        s$.end_value = NULL
        s$.end_room = NULL
        notes = c(notes, "The line names are not written at the line ends on a drawing this narrow.")
      }
    }
  } else if (fam %in% c("line", "slope") && !is.null(s$color) && !identical(s$color, s$facet)) {
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
        # the colours go to the series by their levels, as in the picture with end labels (the legend only lists them by last value)
        s$.legend_levels = levels(droplevels(as.factor(if (!is.null(s$highlight)) table[[s$color]][table$highlighted] else table[[s$color]])))
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
    # Density (Phase 10 Part C): a scatter's points become counts of rows in cells of a grid when `density` is on, or when it is auto and
    #   the points would pile up (more than SPEC_ALPHA_N, and no highlight, which names single points); a bubble chart's only past SPEC_BIN_N.
    #   Cells replace the see-through points and the moving of points. They are hexagons (geom_hex(), which needs the hexbin package) when hexbin is
    #   installed and neither axis has few values (hex_fits()), else rectangles (geom_bin_2d()).
    binned = switch(if (identical(fam, "scatter")) density_mode(s) else "bubble",
                    on = TRUE, off = FALSE, auto = n > SPEC_ALPHA_N && is.null(s$highlight), bubble = n > SPEC_BIN_N)
    if (binned) {
      s$.binned = TRUE
      s$.bin_breaks = bin_breaks(s, table)
      if (hex_fits(s, table)) s$.hex = TRUE
      hex = isTRUE(s$.hex)
      notes = c(notes, paste0(if (n > SPEC_ALPHA_N) paste0(format_num(n), " points would hide one another, so the chart counts rows in ", if (hex) "hexagons" else "cells of a grid"),
                              if (n <= SPEC_ALPHA_N) paste0("The chart counts rows in ", if (hex) "hexagons" else "cells of a grid"),
                              ": each ", if (hex) "hexagon" else "cell", " counts rows, and the stronger its colour, the more of them.",
                              if (!is.null(s$color)) paste0(" The colour of '", s$color, "' is not drawn in ", if (hex) "hexagons" else "cells", "; panels (facet) keep its groups apart.")))
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
  if (index_first(s)) return(call("chart_number", sym(col)))
  switch(s$fn %||% "none",
    count = call("chart_count", sym(col)),
    share = call("chart_fixed", call("*", 100, sym(col)), 1L, "%"),
    if (comma) call("chart_number", sym(col)) else call("chart_number", sym(col), comma = FALSE))
}

# The text a line's x gives an annotation, the way the facts write a time (fact_date(), as chart_date() in the written code).
x_text_call <- function(s, kind) switch(kind, text = call("chart_date", sym(s$x), call("$", sym("chart_table"), sym(s$x))),
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
                                         if (identical(fam, "line")) paste0("\n(", fact_time(t[[s$x]][g$row], t[[s$x]]), ")")))
  paste0(toupper(substring(words, 1, 1)), substring(words, 2), ": ", fmt(t[[v]][g$row]),
         if (identical(fam, "line")) paste0(" (", fact_time(t[[s$x]][g$row], t[[s$x]]), ")"), tie)
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
#   .annotate, .value_labels, .label_rows (the rows labelled), .repel and .n_rows. Returns list(spec, notes).
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
      # a call-out is a box: its padding (0.3 of a line each side, and the border) is more room again than its text
      pad = c(rep(2 * 0.3 * SPEC_LABEL_HEIGHT_IN + 0.02, length(ann_rows)), rep(0, length(texts) - length(ann_rows)))
      # upright: a call-out's box stands off its anchor by vjust times the height of its own lines, then is that tall itself
      up_need = (lengths(parts) + 1.2) * SPEC_LABEL_HEIGHT_IN
      up_need[seq_along(ann_rows)] = pmax(up_need[seq_along(ann_rows)], (abs(ann_v) + 1) * lengths(parts)[seq_along(ann_rows)] * SPEC_LABEL_HEIGHT_IN)
      long = if (isTRUE(s$.flip)) purrr::map_dbl(parts, function(l) max(nchar(l))) * SPEC_LABEL_CHAR_IN * bold + 0.08 + pad else up_need + pad
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
       # the fill of counts in cells: the style's own ramp unless the analyst chose a sequential palette (Phase 10b)
       ramp = if (identical(palette$sequential, chart_palette_default()$sequential)) chart_style_ramp(style) else chart_sequential(palette$sequential),
       style = style, single = palette_single(palette_for_n(1L, palette$qualitative, style), style), grey = st$grey, fit = st$fit, outline = st$outline, box_fill = st$box_fill,
       panel = st$panel, slate = st$slate, accent = st$accent,
       rug = st$text_2, label = st$text_2, strong = st$text, fonts = chart_font_values(chart_theme_calls(style)))
}

# The note for a chart whose groups outnumber the chosen qualitative palette's colours, so it is
#   drawn with the default palette instead; NULL otherwise.
palette_note <- function(s, cb, palette = chart_palette_default()) {
  coloured = !is.null(s$color) && is.null(s$highlight) && !s$family %in% c("heatmap", "dumbbell") && !isTRUE(s$.binned) && !index_first(s)
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
  if (index_first(s)) return(paste0("Index (first ", s$.index_unit %||% "period", " = 100)"))
  col = if (identical(s$family, "heatmap")) s$color %||% s$y else if (identical(s$family, "dumbbell")) s$x else s$y %||% s$x
  lab = if (title) col_title(cb, col, capital = FALSE) else cb_label(cb, col)
  switch(s$fn, count = "Count", share = "Share of rows", sum = paste("Total", lab), mean = paste("Mean", lab),
         median = paste("Median", lab), if (title) col_title(cb, col) else lab)
}

highlight_values <- function(pal) c(`FALSE` = pal$slate, `TRUE` = pal$accent)

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

# The names of a sideways bar or dot chart run down its y axis; the axis stands off its first and last row by 0.6 of a row, and by a whole row when a
#   call-out of several lines (a phone's) stands beside the last one, so that its box is inside the panel.
flip_scale <- function(s)
  as.call(c(list(sym("scale_y_discrete"), limits = sym("rev")), if (length(s$.annotate) && annotation_lines(s)) list(expand = call("expansion", add = 1))))

bar_calls <- function(s, cb, pal) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  main = if (flip) aes_call(x = v, y = s$x, fill = col) else aes_call(x = s$x, y = v, fill = col)
  geom = if (!is.null(s$highlight)) list(call("geom_col", aes_call(fill = "highlighted")),
                                          call("scale_fill_manual", values = highlight_values(pal), guide = "none"))
    else if (!is.null(col)) list(call("geom_col", position = if (flip) call("position_dodge", width = 0.8, reverse = TRUE) else call("position_dodge", width = 0.8),
                                      width = 0.75),
                                 call("scale_fill_manual", values = series_values(pal$qual(colour_count(s, cb, col)), s)))
    else list(call("geom_col", fill = pal$single))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, if (flip) "x" else "y", TRUE),
    if (flip) list(flip_scale(s)))
}

dot_calls <- function(s, cb, pal) {
  v = value_name(s); flip = isTRUE(s$.flip); col = s$color
  main = if (flip) aes_call(x = v, y = s$x, colour = col) else aes_call(x = s$x, y = v, colour = col)
  geom = if (!is.null(s$highlight)) list(call("geom_point", aes_call(colour = "highlighted"), size = 3),
                                          call("scale_colour_manual", values = highlight_values(pal), guide = "none"))
    else if (!is.null(col)) list(call("geom_point", size = 3),
                                 call("scale_colour_manual", values = series_values(pal$qual(colour_count(s, cb, col)), s)))
    else list(call("geom_point", size = 3, colour = pal$single))
  c(list(call("ggplot", sym("chart_table"), main)), geom, value_scale(s, if (flip) "x" else "y", FALSE),
    if (flip) list(flip_scale(s)))
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
  named = if (!is.null(s$.label_series)) list(call("%in%", sym(s$color), s$.label_series))
  as.call(c(list(sym("filter"), sym("chart_table")), extra, named, list(at), by))
}

# End labels: drawn only when the lint found that none would touch, so nothing is dropped.
end_labels <- function(s, rows, colour = NULL) {
  name = if (!is.null(s$color) && !identical(s$color, s$facet)) sym(s$color)
  num = value_text_call(s, plotted_value(s))
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

# The colours of a line chart whose legend names the series, named by the series they belong to. scale_colour_manual() with unnamed
#   values and `breaks` gives the colours to the breaks in their order, so a legend listed by last value (.legend_order) would hand a
#   series another series' colour; named by the levels (.legend_levels), each series keeps the colour it has in the picture.
legend_values <- function(cols, s) series_values(cols, s, s$.legend_levels)

# The colours of a colour column, named by the series they go to (`lev`, its levels: s$.colour_levels, set by spec_lint()), so that a
#   colour belongs to its series and not to a place in a list. Unnamed when the levels are not known or outnumber the colours.
series_values <- function(cols, s, lev = s$.colour_levels) {
  if (is.null(lev) || length(lev) > length(cols)) cols else stats::setNames(cols[seq_along(lev)], lev)
}

line_calls <- function(s, cb, pal) {
  v = plotted_value(s); col = s$color; slope = identical(s$family, "slope")
  smooth = !is.null(smooth_k(s))
  same = !is.null(col) && identical(col, s$facet)
  labelled = isTRUE(s$.labels)
  legend = !is.null(s$.legend_order)
  k = if (!is.null(col) && !same) colour_count(s, cb, col) else 0
  many = k > pal$max
  group = col
  points = function(colour = NULL, data = NULL)
    if (slope) list(as.call(c(list(sym("geom_point")), if (!is.null(data)) list(data = data), list(size = 2.5),
                              if (!is.null(colour)) list(colour = colour))))
  base = function(...) call("ggplot", sym("chart_table"), aes_call(x = s$x, y = v, ...))
  layers = if (is.null(col) || same) {
    c(list(base(group = group), call("geom_line", colour = pal$single, linewidth = 0.9)), points(colour = pal$single),
      if (labelled && is.null(col)) list(end_labels(s, end_rows(s), pal$single)))
  } else if (index_first(s)) {
    # an indexed chart (Phase 10b): every series that is not highlighted in the style's slate (all of them when none is), the highlighted in its
    #   accent, the names at the line ends and no legend
    hl = !is.null(s$highlight)
    line = function(data, colour, width) as.call(c(list(sym("geom_line")), if (!is.null(data)) list(data = data), list(colour = colour, linewidth = width)))
    c(list(base(group = col), line(if (hl) data_where(quote(!highlighted)), pal$slate, 0.7)),
      if (hl) list(line(data_where(quote(highlighted)), pal$accent, 1.1)),
      if (labelled) list(end_labels(s, end_rows(s, if (hl) list(quote(highlighted))), if (hl) pal$accent else pal$label)))
  } else if (!is.null(s$highlight)) {
    nh = length(values_of(s$highlight$values))
    lit = if (legend && nh <= pal$max)
      c(list(call("geom_line", data = data_where(quote(highlighted)), aes_call(colour = col), linewidth = 1.1)),
        if (slope) list(call("geom_point", data = data_where(quote(highlighted)), aes_call(colour = col), size = 2.5)),
        list(call("scale_colour_manual", values = legend_values(pal$qual(nh), s), breaks = s$.legend_order)))
    else
      c(list(call("geom_line", data = data_where(quote(highlighted)), colour = pal$accent, linewidth = 1.1)),
        points(colour = pal$accent, data = data_where(quote(highlighted))),
        if (labelled) list(end_labels(s, end_rows(s, list(quote(highlighted))), pal$accent)))
    c(list(base(group = col), call("geom_line", data = data_where(quote(!highlighted)), colour = pal$slate, linewidth = 0.7)), lit)
  } else if (many) {
    c(list(base(group = col), call("geom_line", colour = pal$single, linewidth = 0.7)), points(colour = pal$single),
      if (labelled) list(end_labels(s, end_rows(s), pal$single)))
  } else {
    c(list(base(colour = col, group = col), call("geom_line", linewidth = 0.9)), points(),
      list(as.call(c(list(sym("scale_colour_manual"), values = if (legend) legend_values(pal$qual(k), s) else series_values(pal$qual(k), s)), if (legend) list(breaks = s$.legend_order)))),
      if (labelled) list(end_labels(s, end_rows(s)), call("guides", colour = "none")))
  }
  # A moving average (Phase 10 Part C): the layers above draw the average in the series colour; the raw values are behind them, in the grey.
  if (smooth) {
    raw = call("geom_line", aes_call(y = value_name(s)), colour = pal$grey, linewidth = 0.5)
    layers = purrr::map(layers, function(cl) if (is.call(cl) && identical(cl[[1]], sym("geom_line"))) as.call(c(as.list(cl), list(na.rm = TRUE))) else cl)
    layers = c(layers[1], list(raw), layers[-1])
  }
  # An indexed chart has its rule at 100: where a line is neither above nor below its first period.
  if (index_first(s)) layers = c(layers, list(call("geom_hline", yintercept = 100, colour = pal$rug, linewidth = 0.4, linetype = "dashed")))
  room = labelled
  xscale = if (slope) as.call(c(list(sym("scale_x_discrete")), if (date_column(cb, s$x)) list(labels = TIME_LABELS_DISCRETE),
                                list(expand = call("expansion", add = if (room) c(0.3, 0.8) else c(0.3, 0.3)))))
           else time_scale(s, cb, room)
  yscale = as.call(c(list(sym(if (isTRUE(s$log_y)) "scale_y_log10" else "scale_y_continuous")), list(labels = call("label_comma")),
                     if (length(s$.annotate)) list(expand = call("expansion", mult = 0.12))))
  c(layers, purrr::compact(list(xscale)), list(yscale), if (room) list(quote(coord_cartesian(clip = "off"))))
}

# A highlighted point's label sits to the left of it in the right half of the x range, to the right otherwise.
side_labels <- function(s, pal) {
  rows = s$.label_rows
  if (!isTRUE(s$.names) || (length(rows) == 0L && !is.null(rows))) return(NULL)
  x = sym(s$x)
  hjust = call("if_else", call(">", x, call("/", call("+", call("min", x), call("max", x)), 2)), 1.15, -0.15)
  shown = if (is.null(rows)) quote(highlighted) else call("&", quote(highlighted), call("%in%", quote(row_number()), as.numeric(rows)))
  named = call("filter", call("mutate", sym("chart_table"), label_hjust = hjust), shown)
  if (!shared_repel(s))
    return(list(label_layer(s, named, aes_call(label = s$highlight$column, hjust = "label_hjust"), pal$strong, bold = TRUE)))
  # Names and annotations in one layer moved by ggrepel (Phase 7b): layers do not push one another apart, so a name and an
  #   annotation drawn in two could land on each other. The annotations are call-outs (boxes with a leader, Phase 10 Part C) and the names
  #   are not: each row says its own box fill (none for a name) and its border (none for a name).
  words = purrr::map(s$.annotate, function(g)
    call("mutate", annotation_data(s, g), label_text = annotation_label(s, g), label_hjust = 0.5, box_fill = pal$panel, box_line = CALLOUT_LINE))
  both = as.call(c(list(sym("bind_rows"), call("mutate", named, label_text = call("as.character", sym(s$highlight$column)), label_hjust = 0.5, box_fill = NA_character_, box_line = 0)), words))
  clear = if (!is.null(s$.rug_floor)) list(xlim = c(s$.rug_floor[["x"]], NA), ylim = c(s$.rug_floor[["y"]], NA))
  list(do.call(callout_layer, c(list(s, both, aes_call(label = "label_text", hjust = "label_hjust", fill = "box_fill", linewidth = "box_line"), pal, per_row = TRUE), clear), quote = TRUE),
       quote(scale_fill_identity()), quote(scale_linewidth_identity()))
}

# Whether a scatter's or bubble's names and annotations share one ggrepel layer (ggrepel installed, both drawn).
shared_repel <- function(s) {
  rows = s$.label_rows
  isTRUE(s$.repel) && s$family %in% c("scatter", "bubble") && isTRUE(s$.names) && length(s$.annotate) > 0L &&
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

# The cells of a binned scatter (Phase 10b), on the scale that is drawn: along an axis with at most SPEC_BIN_DISTINCT different values a cell
#   is one value (its edges halfway to the next value, so no strip and no gap the data do not have); along any other SPEC_BIN_2D cells of the
#   same width in the scale's own units (log10 when the axis is log). Edges are in the data's units (ggplot2 transforms them with the scale),
#   written with as few digits as keep every value in a cell of its own; NULL when the axis has no value to bin.
bin_edges <- function(v, log) {
  v = v[is.finite(v) & (!log | v > 0)]
  if (!length(v)) return(NULL)
  u = sort(unique(if (log) log10(v) else v))
  k = length(u)
  edges = if (k <= SPEC_BIN_DISTINCT) {
    mid = (u[-1] + u[-k]) / 2
    if (k == 1L) u + c(-1, 1) * (if (log) 0.05 else max(abs(u), 1) * 0.05)
    else c(u[1] - (mid[1] - u[1]), mid, u[k] + (u[k] - mid[k - 1L]))
  } else {
    pad = 0.005 * diff(range(u))
    seq(u[1] - pad, u[k] + pad, length.out = SPEC_BIN_2D + 1L)
  }
  data_units = if (log) 10^edges else edges
  ok = function(e) !anyNA(e) && all(diff(e) > 0) && e[1] < min(v) && e[length(e)] > max(v) && length(unique(findInterval(unique(v), e))) == k
  at = purrr::detect(c(5L, 7L, 10L, 15L), function(d) ok(signif(data_units, d)))
  signif(data_units, at %||% 15L)
}

# The cells of both axes, or NULL (ggplot2's own bins) when nothing can be binned or each panel draws its own y scale (free_y).
bin_breaks <- function(s, table) {
  b = list(x = bin_edges(table[[s$x]], isTRUE(s$log_x)), y = bin_edges(table[[s$y]], isTRUE(s$log_y)))
  if (is.null(b$x) || is.null(b$y)) NULL else b
}

# Whether hexbin can draw hexagons here: the package is installed (find.package(), as for paletteer: R/ makes no requireNamespace() call, and
#   app.R names hexbin in one, so a deployment asks for it). Read each time a chart is drawn, so the app works where it is missing (rectangles);
#   one function, so a test can stand in for its absence.
density_hex_ok <- function() length(find.package("hexbin", quiet = TRUE)) > 0L

# How many different values an axis of a binned scatter has on the scale that is drawn.
bin_distinct <- function(v, log) length(unique(v[is.finite(v) & (!log | v > 0)]))

# Hexagons (Phase 10b hexagons) when hexbin is installed and each axis has more than SPEC_BIN_DISTINCT different values. An axis of at most that many is
#   binned at its values, and a hexagon cannot sit on a value: its rows of hexagons would be the strips that binning at the values removed. Then rectangles.
hex_fits <- function(s, table)
  !is.null(s$.bin_breaks) && density_hex_ok() &&
    min(bin_distinct(table[[s$x]], isTRUE(s$log_x)), bin_distinct(table[[s$y]], isTRUE(s$log_y))) > SPEC_BIN_DISTINCT

# The layer that counts rows in cells: hexagons, SPEC_BIN_2D across, on the scale that is drawn (geom_hex(bins = ): the stat works on the transformed
#   axes, so a log axis has hexagons of one width in log units), or rectangles on the edges worked out above. Empty cells are not drawn.
bin_call <- function(s) {
  b = s$.bin_breaks
  if (isTRUE(s$.hex)) call("geom_hex", bins = SPEC_BIN_2D)
  else if (is.null(b) || isTRUE(s$free_y)) call("geom_bin_2d", bins = SPEC_BIN_2D)
  else call("geom_bin_2d", breaks = call("list", x = b$x, y = b$y))
}

# The legend's word for what a cell counts: the plural of the dictionary's word for a row when "one <word>" says it ("one order" is
#   "Orders", "one country" "Countries"), else "Rows".
row_word <- function(cb) {
  one = tolower(trimws(sub("[.]+$", "", cb$row_is %||% "")))
  form = "^(one|a|an|1)[[:space:]]+([a-z][a-z-]*)$"
  if (!is_text1(one) || !grepl(form, one)) return("Rows")
  w = sub(form, "\\2", one)
  plural = if (grepl("[^aeiou]y$", w)) sub("y$", "ies", w) else if (grepl("(s|x|z|ch|sh)$", w)) paste0(w, "es") else paste0(w, "s")
  paste0(toupper(substring(plural, 1, 1)), substring(plural, 2))
}

scatter_calls <- function(s, cb, pal) {
  col = s$color; bubble = identical(s$family, "bubble")
  binned = isTRUE(s$.binned)
  alpha = c(if (!is.null(s$.alpha)) list(alpha = s$.alpha) else if (bubble) list(alpha = 0.5),
            if (isTRUE(s$.jitter)) list(position = jitter_call(s)))
  main = aes_call(x = s$x, y = s$y, colour = if (!binned) col, size = if (bubble) s$size)
  point = function(...) as.call(c(list(sym("geom_point")), list(...), alpha))
  colours = if (!is.null(col) && !binned) {
    n = colour_count(s, cb, col)
    purrr::compact(list(call("scale_colour_manual", values = series_values(pal$qual(n), s)), legend_rows("colour", n, solid = length(alpha) > 0L)))
  }
  geom = if (binned) list(bin_call(s),
                          call("scale_fill_gradientn", colours = pal$ramp, breaks = HEAT_BREAKS_FEW, labels = quote(label_comma())),
                          # a colour bar long enough for its labels, as a heatmap's
                          call("guides", fill = call("guide_colourbar", theme = call("theme", legend.key.width = call("unit", if (!is.null(s$.fig_width)) min(2.4, fig_panel_w(s) - 0.4) else 2.4, "in")))))
    else if (!is.null(s$highlight))
      c(list(point(data = data_where(quote(!highlighted)), colour = pal$slate),
             point(data = data_where(quote(highlighted)), colour = pal$accent)),
        side_labels(s, pal))
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
  # a group's curve is one layer, or one for each stretch of x that has rows (fit_runs())
  pieces = function(data, g) purrr::map(g$runs %||% list(g$range), function(r) smooth(data, r))
  if (is.null(c(fr$groups, fr$skip)[[1]]$keys)) return(if (length(fr$skip)) list() else pieces(NULL, fr$groups[[1]]))
  rows = function(cond) call("~", call("filter", sym(".x"), cond))
  cond_of = function(g)
    purrr::reduce(purrr::imap(g$keys, function(v, col) call("==", sym(col), value_call(cb_entry(cb, col), v))), function(a, b) call("&", a, b))
  conds = purrr::map(fr$groups, cond_of)
  others = c(conds, purrr::map(fr$skip, cond_of))
  c(unlist(purrr::map2(fr$groups, conds, function(g, cond) pieces(rows(cond), g)), recursive = FALSE),
    if (isTRUE(fr$rest)) list(smooth(rows(call("!", call("(", purrr::reduce(others, function(a, b) call("|", a, b))))))))
}

histogram_calls <- function(s, cb, pal)
  c(list(call("ggplot", sym("chart_table"), aes_call(x = s$x)),
         call("geom_histogram", bins = as.numeric(s$bins), fill = pal$single, colour = pal$outline),
         call("scale_y_continuous", expand = call("expansion", mult = c(0, 0.05)))),
    if (isTRUE(s$log_x)) list(quote(scale_x_log10())))

box_calls <- function(s, cb, pal) {
  flip = isTRUE(s$.flip)
  main = if (flip) aes_call(x = s$y, y = s$x) else aes_call(x = s$x, y = s$y)
  # shape violin (Phase 10 Part C): a group of at least SPEC_VIOLIN_MIN rows is a violin (trimmed to its data, every violin as wide as the
  #   widest) with a slim box inside that carries the median and quartiles; a group of fewer rows stays the plain box.
  by = by_arg(unique(c(s$x, s$facet)))
  rows_of = function(op) as.call(list(sym("filter"), sym("chart_table"), call(op, quote(n()), as.numeric(SPEC_VIOLIN_MIN)), .by = by))
  plain = call("geom_boxplot", fill = pal$box_fill, colour = pal$single, width = 0.6)
  marks = if (violin_shape(s) && isTRUE(s$.violin))
    # Phase 10b: the violin is filled with the series colour at 20 per cent (one colour for every group: a box chart has no colour column), its box
    #   stays solid, and the rows beyond the whiskers are small dots as in a plain box.
    c(list(call("geom_violin", data = rows_of(">="), fill = pal$single, alpha = SPEC_VIOLIN_ALPHA, colour = pal$single, trim = TRUE, scale = "width", width = 0.9),
           call("geom_boxplot", data = rows_of(">="), fill = pal$single, colour = pal$single, width = 0.12, median.colour = pal$box_fill)),
      if (isTRUE(s$.plain_box)) list(as.call(c(as.list(plain), list(data = rows_of("<"))))))
  else list(plain)
  c(c(list(call("ggplot", sym("chart_table"), main)), marks),
    if (flip) list(call("scale_y_discrete", limits = sym("rev"))),
    if (isTRUE(s$log_y)) list(if (flip) quote(scale_x_log10()) else quote(scale_y_log10())))
}

# A dumbbell (Phase 10 Part C): for each group on y, two dots on the value's one scale joined by a line, one for each of the two values of
#   the colour column. The earlier value (the colour's first level) is the slate, the later the accent; the groups are in the order of the
#   later value (rank_calls()). The legend is replaced by the two names written above the first row, each on the outer side of its dot.
dumbbell_calls <- function(s, cb, pal) {
  v = value_name(s); col = sym(s$color); y = sym(s$y)
  code = call("as.integer", col)
  at = function(op) call("filter", sym("chart_table"), call("==", code, call(op, code)))
  top = call("filter", sym("chart_table"), call("==", y, call("[", call("levels", y), 1L)))
  names_at = call("mutate", top,
                  label_hjust = call("if_else", call("==", call("rank", sym(v), ties.method = "first"), 1L), 1.15, -0.15),
                  text_colour = call("if_else", call("==", code, call("min", code)), pal$slate, pal$accent))
  room = s$.name_room %||% 0.12
  list(call("ggplot", sym("chart_table"), aes_call(x = v, y = s$y)),
       call("geom_line", aes_call(group = s$y), orientation = "y", colour = pal$grey, linewidth = 1.6),
       call("geom_point", data = at("min"), colour = pal$slate, size = 3.5),
       call("geom_point", data = at("max"), colour = pal$accent, size = 3.5),
       call("geom_text", data = names_at, aes_call(label = s$color, hjust = "label_hjust", colour = "text_colour"), vjust = -1.2,
            size = SPEC_LABEL_MM, family = sym("chart_font"), fontface = "bold"),
       quote(scale_colour_identity()),
       # the breaks are inside the data's range (the scale hands its function the range with the room added): a tick at the edge of the room made for
       #   the names would put its label past the picture's edge
       call("scale_x_continuous", labels = quote(label_comma()),
            breaks = substitute(function(x) { r <- range(chart_table$V); b <- breaks_extended()(x); b[b >= r[1] & b <= r[2]] }, list(V = sym(v))),
            expand = call("expansion", mult = c(room, room))),
       call("scale_y_discrete", limits = sym("rev"), expand = call("expansion", add = c(0.6, 1))))
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
# The x labels of a heatmap whose x is a group ("2022 Q1", "2022 Q2", ...): a label is about HEAT_LABEL_IN inches wide with room round it, so when the
#   levels need more than the panel's width the labels stand in two rows or three (guide_axis(n.dodge)) and no two touch (Phase 10 Part D: they touched at
#   narrow widths, in the picture and in the interactive view).
HEAT_LABEL_IN <- 0.62
heat_x_dodge <- function(s, cb) {
  rows = min(3L, ceiling(cb_entry(cb, s$x)$distinct * HEAT_LABEL_IN / fig_panel_w(s)))
  if (rows > 1L) call("scale_x_discrete", guide = call("guide_axis", n.dodge = rows))
}

heatmap_calls <- function(s, cb, pal) {

  colours = if (!is.null(s$midpoint)) pal$div else pal$seq
  rescaler = if (!is.null(s$midpoint))
    list(rescaler = call("function", as.pairlist(alist(x = , ... = )), call("rescale_mid", sym("x"), sym("..."), mid = s$midpoint)))
  c(purrr::compact(list(call("ggplot", sym("chart_table"), aes_call(x = s$x, y = s$y, fill = value_name(s))),
         call("geom_tile", colour = pal$outline, linewidth = 0.5),
         as.call(c(list(sym("scale_fill_gradientn"), colours = colours), rescaler, list(breaks = if (!is.null(s$.fig_width)) HEAT_BREAKS_FEW else HEAT_BREAKS),
                   if (identical(s$fn, "share")) list(labels = call("label_percent")) else if (!is.null(s$.fig_width)) list(labels = call("label_comma")))),
         call("scale_y_discrete", limits = sym("rev")),
         if (!is_group_like(cb_entry(cb, s$x))) date_x_scale(s, cb) else heat_x_dodge(s, cb),
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
  dumbbell = "x",
  bar = , dot = if (isTRUE(s$.value_labels)) "none" else if (isTRUE(s$.flip)) "x" else "y",
  box = if (isTRUE(s$.flip)) "x" else "y",
  scatter = , bubble = if (isTRUE(s$.binned)) "none" else "xy",
  heatmap = "none",
  "y")

labs_call <- function(s, cb, style = CHART_STYLE_DEFAULT) {
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
           else if (isTRUE(s$.binned)) row_word(cb),
    size = if (identical(s$family, "bubble")) col_title(cb, s$size)))
  # A sideways bar or dot lists names on its y axis; that axis needs no title unless the spec gives one (so does a dumbbell's).
  axes = if (identical(s$family, "dumbbell")) list(x = s$x_label %||% value_label(s, cb, title = TRUE), y = s$y_label)
         else if (flip && s$family %in% c("bar", "dot")) list(x = yl, y = s$x_label)
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
  # the title as the style draws it (without one trailing full stop, and in upper case in Briefing, where a number or a unit keeps its case); the spec keeps its own text
  as.call(c(list(sym("labs")), purrr::compact(list(title = chart_title_case(chart_heading_text(s$title), style), subtitle = s$subtitle, caption = caption)), axes, legend))
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
#   place, and the style's own layers (the rule under the title block).
theme_calls <- function(s, pal)
  c(chart_theme_calls(pal$style, grid = grid_of(s),
                      legend = if (s$family %in% c("line", "slope") && !is.null(s$.legend_order)) "right" else "top",
                      lift = lift_axis(s)),
    bare_axis_call(s),
    chart_style_layers(pal$style))

# A bar or dot chart whose every mark carries its value: the value axis's numbers and ticks go (its title stays).
bare_axis_call <- function(s) {
  if (!isTRUE(s$.value_axis_bare)) return(NULL)
  a = if (isTRUE(s$.flip)) "x" else "y"
  list(as.call(c(list(sym("theme")), stats::setNames(list(quote(element_blank()), quote(element_blank())), paste0(c("axis.text.", "axis.ticks."), a)))))
}

# One text layer of the labels R writes: geom_text(), or ggrepel::geom_text_repel() in the static chart when ggrepel was
#   installed at the lint (.repel) and `repel` is wanted (not for the labels of a bar or dot, which R places itself). In the chart's font and the style's text colour.
#   `mapping` is the aes() of the layer; `...` are its constant arguments (hjust, vjust, position).
label_layer <- function(s, data, mapping, colour, bold = FALSE, repel = TRUE, ...) {
  fixed = c(list(data = data, mapping), list(family = sym("chart_font"), size = SPEC_LABEL_MM, colour = colour),
            if (bold) list(fontface = "bold"), list(...))
  if (!repel || !isTRUE(s$.repel)) return(as.call(c(list(sym("geom_text")), fixed)))
  as.call(c(list(quote(ggrepel::geom_text_repel)), fixed,
            list(direction = "both", seed = SPEC_JITTER_SEED, max.overlaps = Inf, box.padding = 0.2, min.segment.length = 0.3,
                 segment.colour = colour, segment.size = 0.3)))
}

# A call-out (Phase 10 Part C): the words of an `annotate` mark in a small box, the style's text colour on its panel colour with a thin
#   border, and, where ggrepel moves the box away from its point (a scatter, a bubble, a line), a thin leader to the point (min.segment.length
#   0, so the leader is always there). A bar's or dot's box stands against the end of its mark, so it needs none; without ggrepel a box
#   stands beside its point by hjust and vjust. `per_row`: the layer's mapping gives each row its own fill and border (the shared layer of names
#   and call-outs, where a name has neither).
CALLOUT_LINE <- 0.25
callout_layer <- function(s, data, mapping, pal, repel = TRUE, per_row = FALSE, ...) {
  box = c(list(data = data, mapping), list(family = sym("chart_font"), size = SPEC_LABEL_MM, colour = pal$strong, fontface = "bold",
                                           label.r = call("unit", 0.15, "lines"), label.padding = call("unit", 0.3, "lines")),
          if (!per_row) list(fill = pal$panel, linewidth = CALLOUT_LINE), list(...))
  if (!repel || !isTRUE(s$.repel)) return(as.call(c(list(sym("geom_label")), box)))
  as.call(c(list(quote(ggrepel::geom_label_repel)), box,
            list(direction = "both", seed = SPEC_JITTER_SEED, max.overlaps = Inf, box.padding = if (per_row) 0.3 else 0.6,
                 point.padding = call("unit", if (per_row) 0.3 else 1.4, "lines"), min.segment.length = if (per_row) 0.3 else 0,
                 segment.colour = pal$strong, segment.size = 0.3)))
}

# A call-out on a line, scatter or bubble: a box and a thin leader to the point. The box stands off the point by a share of each axis's range
#   (CALLOUT_OFFSET: along x away from the nearer edge, along y above or below as the Phase 7b rules say, g$hjust and g$vjust), the leader runs from
#   the point to the box's corner or edge, and the box (fill, then text) is drawn over the leader's end. On a log axis the shift is in log
#   units. The leader, the ring and the box are three layers of the chart; the code that comes with it draws them as they are.
CALLOUT_OFFSET <- c(x = 0.05, y = 0.08)
callout_calls <- function(s, g, data, pal, ring) {
  scatter = s$family %in% c("scatter", "bubble")
  xcol = s$x
  ycol = if (scatter) s$y else value_name(s)
  above = g$vjust < 0
  side = g$hjust
  shift = function(col, frac, log) {
    spread = call("diff", call("range", if (log) call("log10", call("$", sym("chart_table"), sym(col))) else call("$", sym("chart_table"), sym(col))))
    if (log) call("*", sym(col), call("^", 10, call("*", frac, spread))) else call("+", sym(col), call("*", frac, spread))
  }
  moved = call("mutate", data,
               .cx = shift(xcol, if (side == 0) CALLOUT_OFFSET[["x"]] else if (side == 1) -CALLOUT_OFFSET[["x"]] else 0, isTRUE(s$log_x) && scatter),
               .cy = shift(ycol, if (above) CALLOUT_OFFSET[["y"]] else -CALLOUT_OFFSET[["y"]], isTRUE(s$log_y)))
  leader = call("geom_segment", data = moved, aes_call(x = xcol, y = ycol, xend = ".cx", yend = ".cy"), inherit.aes = FALSE,
                colour = pal$strong, linewidth = 0.3)
  c(list(leader), ring, list(callout_layer(s, moved, aes_call(x = ".cx", y = ".cy", label = annotation_label(s, g)), pal, repel = FALSE,
                                           inherit.aes = FALSE, hjust = side, vjust = if (above) 0 else 1)))
}

# The rows of chart_table a label layer draws: all (rows NULL), or those row numbers.
label_data <- function(rows) {
  if (is.null(rows)) return(sym("chart_table"))
  call("filter", sym("chart_table"), call("%in%", quote(row_number()), as.numeric(rows)))
}

# The value labels of a bar or dot chart: the plotted value at the end of each mark, outside it (a negative value below
#   or to the left), in the style's text colour. A grouped bar's label sits over its own bar (the same dodge).
value_label_calls <- function(s, cb, pal) {
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
  list(do.call(label_layer, c(list(s, label_data(rows), mapping, pal$label, repel = FALSE), fixed, position), quote = TRUE))
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

# What an annotate marks (a call-out, Phase 10 Part C): a ring round a point (line, dot, scatter, bubble; a bar has no point, so only its box),
#   and its words in bold in a small box, the style's text colour on its panel colour, with a thin leader to the point (callout_calls()); the
#   side the box stands on is placed by the lint (the Phase 7b rules).
annotation_calls <- function(s, cb, pal) {
  groups = s$.annotate
  if (!length(groups)) return(list())
  unlist(purrr::map(groups, function(g) {
    data = annotation_data(s, g)
    ring = if (!identical(s$family, "bar"))
      list(call("geom_point", data = data, shape = 1, size = 4, stroke = 1, colour = pal$strong))
    # merged into its line's end label (lint_marks()): the ring only
    if (isTRUE(g$merged)) return(ring)
    # drawn with the names, in one layer (side_labels())
    if (shared_repel(s)) return(ring)
    # a bar's or dot's box stands against the end of its mark (the Phase 7b rules: hjust and vjust)
    if (s$family %in% c("bar", "dot"))
      return(c(ring, list(callout_layer(s, data, aes_call(label = annotation_label(s, g)), pal, repel = FALSE, hjust = g$hjust, vjust = g$vjust))))
    c(callout_calls(s, g, data, pal, ring))
  }), recursive = FALSE)
}

# Everything R writes or marks on the chart besides the family's own layers: value labels, annotations.
mark_calls <- function(s, cb, pal) c(value_label_calls(s, cb, pal), annotation_calls(s, cb, pal))

# The plot's layers, as calls, from the spec as the lint left it and the codebook. interactive = TRUE
#   swaps the data layers for their ggiraph twins (widget_calls()); every other layer is the same.
plot_calls <- function(s, cb, pal = spec_palette(), interactive = FALSE) {
  build = switch(s$family, bar = bar_calls, dot = dot_calls, line = , slope = line_calls, scatter = , bubble = scatter_calls,
                 histogram = histogram_calls, box = box_calls, heatmap = heatmap_calls, dumbbell = dumbbell_calls)
  calls = few_breaks_calls(c(build(s, cb, pal), mark_calls(s, cb, pal), purrr::compact(list(facet_call(s), labs_call(s, cb, pal$style))), theme_calls(s, pal)), s)
  if (interactive) widget_calls(calls, s, cb) else calls
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

# The ggplot for a spec. Runs the defaults, the check, the table and the lint itself, so one call
#   is enough. `palette` names the three palettes of the report (chart_palette_default()); the
#   spec never chooses colours. Attributes: notes (the lint's sentences), spec (the spec as drawn),
#   table, widget_plot (a function that makes the interactive variant spec_widget() draws) and palette.
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
  attr(p, "widget_plot") = function() {
    wenv = do.call(spec_env, c(list(chart_table = widget_table(ls, cb, table), chart_bin_tip = widget_bin_tip, chart_cell_tip = widget_cell_tip, chart_hex_tip = widget_hex_tip), pal$fonts))
    eval(plus_call(plot_calls(ls, cb, pal, interactive = TRUE)), wenv)
  }
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
  defs = list(chart_number = fact_num, chart_count = fact_count, chart_fixed = fact_fixed, chart_date = fact_date)
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
         if (isTRUE(s$.hex)) "# The hexagons are drawn by geom_hex(), which needs the hexbin package: install.packages(\"hexbin\") once if it is not installed.\n",
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

# A date named as the axis names it (Phase 10b), by the span of `basis` (the series the date belongs to, the whole axis; by default `x`
#   itself): the year when every date is a 1 January ("2023"), the month and year when every date is a first of a month ("Dec 2023"),
#   otherwise the date in words ("3 Jan 2024"); a time of day, when the dates carry one, after it ("3 Jan 2024 14:30"). Written in base R
#   only: the code a chart comes with carries a copy of it for the words on its marks.
fact_date <- function(x, basis = x) {
  b <- as.Date(basis)
  d <- as.Date(x)
  month <- month.abb[as.integer(format(d, "%m"))]
  year <- format(d, "%Y")
  out <- if (all(format(b, "%m%d") == "0101", na.rm = TRUE)) year
    else if (all(format(b, "%d") == "01", na.rm = TRUE)) paste(month, year)
    else paste(as.integer(format(d, "%d")), month, year)
  if (inherits(x, "POSIXt") && any(format(basis, "%H%M%S") != "000000", na.rm = TRUE)) out <- paste(as.integer(format(d, "%d")), month, year, format(x, "%H:%M"))
  out[is.na(d)] <- NA
  out
}

# A time as its axis shows it: a date as fact_date() writes it, a whole number (a year) without separators.
fact_time <- function(x, basis = x) {
  if (inherits(x, c("Date", "POSIXt"))) return(fact_date(x, basis))
  if (is.factor(x) || is.character(x)) return(as.character(x))
  purrr::map_chr(x, function(v) if (isTRUE(v == round(v))) format(v, scientific = FALSE, trim = TRUE) else fact_num(v, FALSE))
}

# The plotted value as the chart's value axis shows it.
fact_value_fmt <- function(s) {
  comma = s$family %in% c("bar", "dot", "line", "slope", "heatmap", "dumbbell")
  if (index_first(s)) return(function(x) fact_num(x, TRUE))
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
    dumbbell = n(s$y),
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
    dumbbell = paste0(value_label(s, cb), " by ", lab(s$y), ", at the two values of ", lab(s$color)),
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
    if (index_first(s)) paste0("Indexed: every line is divided by its own value at the first ", s$.index_unit %||% "period", " (", fact_time(min(table[[s$x]]), table[[s$x]]),
                               ") and multiplied by 100, so it starts at 100"),
    if (!is.null(smooth_k(s))) paste0("Moving average: ", smooth_k(s), " periods; the facts below are of the raw values, and the average at the end of each line is given"),
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
    n = nrow(d); y = d[[v]]; tm = fact_time(d[[s$x]], t[[s$x]])
    i_hi = which.max(y); i_lo = which.min(y)
    who = if (is.null(s$color)) k else nm(s$color, k)
    # A series of fewer than three points has no highest or lowest worth naming.
    extremes = if (n >= SPEC_FACTS_LINE_POINTS) paste0(", highest ", fmt(y[i_hi]), " (", tm[i_hi], "), lowest ", fmt(y[i_lo]), " (", tm[i_lo], ")")
      else paste0(", only ", fact_count(n), if (n == 1L) " point" else " points", ", so no highest or lowest is given")
    # An indexed line: its index at the end and at its peak (every line starts at 100); the amounts are not in the chart.
    text = if (index_first(s)) paste0(who, ": index ", fmt(y[1]), " at the start (", tm[1], "), ", fmt(y[n]), " at the end (", tm[n], "), ", fmt(y[i_hi]), " at its peak (", tm[i_hi], ")")
      else paste0(who, ": first ", fmt(y[1]), " (", tm[1], "), last ", fmt(y[n]), " (", tm[n], "), change ",
                  fmt(y[n] - y[1]), if (y[1] > 0) paste0(" (", fact_pct(100 * (y[n] - y[1]) / y[1]), ")"),
                  if (y[1] > 0 && y[n] > 0) paste0(", end is ", fact_times(y[n] / y[1]), " times start"),
                  extremes, fact_year_before(d[[s$x]], y, tm, fmt))
    ma = if (!is.null(smooth_k(s))) paste0("Moving average over ", smooth_k(s), " periods, at the end of ", who, " (", tm[n], "): ", fmt(d[[SMOOTH_COLUMN]][n]))
    list(name = who, change = y[n] - y[1], end = y[n], highlighted = isTRUE(any(d$highlighted)), points = n, text = text, ma = ma)
  })
  pts = purrr::map_int(one, "points")
  per_series = paste0("Points per series: ", if (min(pts) == max(pts)) fact_count(min(pts)) else paste0(fact_count(min(pts)), " to ", fact_count(max(pts))))
  chg = purrr::map_dbl(one, "change")
  keep = fact_lines_keep(chg, purrr::map_lgl(one, "highlighted"))
  ends = purrr::map_dbl(one, "end")
  c(per_series,
    if (length(keep) < length(one))
      paste0("Lines described: ", length(keep), " of ", length(one), ", the highlighted ones and those with the largest and smallest change"),
    unname(purrr::map_chr(one[keep], "text")),
    if (index_first(s)) {
      c(if (length(one) > 1L) paste0("Highest index at the end: ", one[[which.max(ends)]]$name, " (", fmt(max(ends)), ")"),
        if (length(one) > 1L) paste0("Lowest index at the end: ", one[[which.min(ends)]]$name, " (", fmt(min(ends)), ")"),
        paste0("Lines above 100 at the end: ", sum(ends > 100), " of ", length(one)))
    } else c(
      if (length(one) > 1L && max(chg) > 0) paste0("Rose most: ", one[[which.max(chg)]]$name, " (", fmt(max(chg)), ")"),
      if (length(one) > 1L && min(chg) < 0) paste0("Fell most: ", one[[which.min(chg)]]$name, " (", fmt(min(chg)), ")")),
    unname(purrr::map_chr(purrr::compact(purrr::map(one[keep], "ma")), identity)))
}

# A dumbbell's facts: for each group (in the chart's order, the largest later value first) its two values and their difference, the second
#   less the first; the largest and the smallest difference; how many groups rose, fell or stayed.
facts_dumbbell <- function(s, cb, t, nm, fmt) {
  v = value_name(s)
  f = t[[s$color]]
  lv = intersect(levels(f), as.character(f))
  groups = unique(as.character(t[[s$y]]))
  at = function(l) { d = t[as.character(f) == l, , drop = FALSE]; stats::setNames(d[[v]], as.character(d[[s$y]]))[groups] }
  a = at(lv[1]); b = at(lv[2]); diff = b - a
  shown = nm(s$y, groups)
  who = function(at) paste(shown[at], collapse = ", ")
  c(paste0("First value: ", lv[1], "; second value: ", lv[2], " (", cb_label(cb, s$color), ")"),
    paste0(shown, ": ", lv[1], " ", fmt(a), ", ", lv[2], " ", fmt(b), ", difference ", fmt(diff), ifelse(a > 0, paste0(" (", fact_pct(100 * diff / a), ")"), "")),
    paste0("Largest difference (second less first): ", who(fact_same(diff, max(diff))), " (", fmt(max(diff)), ")"),
    paste0("Smallest difference (second less first): ", who(fact_same(diff, min(diff))), " (", fmt(min(diff)), ")"),
    paste0("Groups where the second value is higher: ", sum(diff > 0), "; lower: ", sum(diff < 0), if (any(diff == 0)) paste0("; equal: ", sum(diff == 0))))
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
  s$.index_unit = spec$.index_unit
  namer = fact_namer(cb)
  nm = namer$name
  fmt = fact_value_fmt(s)
  head = facts_head(s, cb, table, nm, exploratory)
  base = if (!is.null(data) && identical(s$family, "heatmap")) run_steps(data, table_steps(s, cb)$base)
  body_of = function(t, rows = base) switch(s$family,
    bar = , dot = facts_bars(s, cb, t, nm, fmt),
    line = facts_lines(s, cb, t, nm, fmt),
    slope = facts_slope(s, cb, t, nm, fmt),
    dumbbell = facts_dumbbell(s, cb, t, nm, fmt),
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


# ---- the interactive version (ggiraph, Phase 10 Part B) and the figure size ----------------------------------------------

# The interactive version of a chart is the chart: the same layers as spec_plot() draws, evaluated again with the layers that
#   draw the data (bars, points, lines, tiles, bins, boxes) swapped for their ggiraph twins (geom_col_interactive() and so on) and
#   a tooltip and a hover group given to each mark. Everything else (value labels, end labels, annotations, rings, fitted curves,
#   the rug, scales, title, subtitle, source line, the style's own layers, the typeface and its weights) is the same ggplot2
#   layer, so it is in the picture. ggiraph::girafe() draws the plot on its own SVG device (the typefaces are the ones
#   chart_fonts_register() put in systemfonts, so text is measured as the static chart measures it) and the page shows that SVG.
#   The tooltip of a mark is written by R from the plotted table (widget_table()), never from a column the chart does not plot.
#   The data layers that have a twin:
WIDGET_GEOMS <- c(geom_col = "geom_col_interactive", geom_point = "geom_point_interactive", geom_line = "geom_line_interactive",
                  geom_histogram = "geom_histogram_interactive", geom_boxplot = "geom_boxplot_interactive",
                  geom_tile = "geom_tile_interactive", geom_bin_2d = "geom_bin_2d_interactive", geom_hex = "geom_hex_interactive", geom_violin = "geom_violin_interactive")
WIDGET_TIP <- ".tip"        # the columns widget_table() adds to the plotted table: the tooltip text and the hover group
WIDGET_HOVER <- ".hover"
WIDGET_SERIES <- ".series"  # ... and, for a line, the tooltip of the line itself: its series (a pointer on the line between two points)
WIDGET_HIT_SIZE <- 4.5      # the size of the invisible points that carry a line chart's tooltips (about the gap between the points of a monthly series, so a pointer near a point finds it)

# Text for a tooltip: HTML-escaped (the tooltip is shown as HTML, so a value with a tag in it must come out as text) and on one line.
widget_esc <- function(x) {
  x = as.character(x)
  x[is.na(x)] = "missing"
  htmltools::htmlEscape(gsub("[\r\n]+", " ", x), attribute = TRUE)
}
widget_line <- function(label, text) paste0(widget_esc(label), ": ", widget_esc(text))

# A column's values as a tooltip shows them: a category, a date or a flag as written, a time given as a whole number (a year) in
#   full, any other number to three significant digits as the facts write it.
widget_shown <- function(cb, table, col) {
  x = table[[col]]
  e = cb_entry(cb, col)
  if (!is.numeric(x) || is.factor(x)) as.character(x)
  else if (!is.null(e) && is_time(e)) fact_time(x)
  else fact_num(x, FALSE)
}

# The tooltip of each row of the plotted table: the x (or the group) and the value as the facts write it (fact_value_fmt(), the
#   same rounding as the numbers on the chart), then the colour, size, panel and highlight columns when the chart plots them. A
#   scatter or bubble point is a row: its x and y and the columns it is drawn by, no other. A box chart's tooltip is its group's:
#   the number of rows, the median, the quartiles and the extremes the box and its points reach. A histogram bin and a cell of a
#   binned scatter are written from the statistic ggplot2 computes (widget_calls()).
widget_tips <- function(s, cb, table) {
  fam = s$family
  v = value_name(s)
  n = nrow(table)
  if (identical(fam, "box")) return(widget_box_tips(s, cb, table))
  if (identical(fam, "histogram") || isTRUE(s$.binned)) return(rep(NA_character_, n))
  fmt = fact_value_fmt(s)
  part = function(col) widget_line(cb_label(cb, col), widget_shown(cb, table, col))
  value = widget_line(value_label(s, cb), fmt(table[[v]]))
  # a moving average's tooltip gives the average beside the raw value (NA until a line has that many points)
  average = if (!is.null(smooth_k(s)))
    list(widget_line(paste0("Moving average over ", smooth_k(s), " periods"), ifelse(is.na(table[[SMOOTH_COLUMN]]), "not yet", fmt(table[[SMOOTH_COLUMN]]))))
  main = switch(fam,
    scatter = , bubble = list(part(s$x), part(s$y)),
    heatmap = list(part(s$x), part(s$y), value),
    line = , slope = c(list(widget_line(cb_label(cb, s$x), fact_time(table[[s$x]])), value), average),
    dumbbell = list(part(s$y), value),
    list(part(s$x), value))
  shown = c(s$x, if (fam %in% c("scatter", "bubble")) s$y)
  extra = setdiff(unique(c(if (!identical(fam, "heatmap")) s$color, if (identical(fam, "bubble")) s$size, s$facet,
                           if (!is.null(s$highlight)) s$highlight$column)), shown)
  do.call(paste, c(main, purrr::map(extra, part), sep = "\n"))
}

widget_box_tips <- function(s, cb, table) {
  by = c(s$x, s$facet)
  keys = widget_keys(table, by)
  y = table[[s$y]]
  fmt = fact_value_fmt(s)
  text = purrr::map_chr(split(seq_along(keys), keys), function(i) {
    vals = y[i][!is.na(y[i])]
    q = stats::quantile(vals, c(0.25, 0.5, 0.75), names = FALSE)
    one = purrr::map_chr(by, function(col) widget_line(cb_label(cb, col), as.character(table[[col]][i[1]])))
    paste(c(one, widget_line("Rows", fact_count(length(vals))), widget_line(paste("Median", cb_label(cb, s$y)), fmt(q[2])),
            widget_line("Middle half", paste(fmt(q[1]), "to", fmt(q[3]))),
            widget_line("Lowest to highest", paste(fmt(min(vals)), "to", fmt(max(vals))))), collapse = "\n")
  })
  unname(text[keys])
}

# One key for each combination of the columns `by` (the group of a row).
widget_keys <- function(table, by) do.call(paste, c(purrr::map(by, function(col) as.character(table[[col]])), sep = "\r"))

# The hover group of each row: a line, slope, grouped bar or dot, or coloured scatter point belongs to its colour's series, so the
#   other series dim when one is pointed at; a line chart with no colour is one series; a box chart's group is its box; any other
#   mark is its own. The group is a number we make (s1, m4), never a value of the file, so it can hold no markup.
widget_hover <- function(s, table) {
  n = nrow(table)
  series = function(col) { x = as.character(table[[col]]); paste0("s", match(x, unique(x))) }
  coloured = !is.null(s$color) && !isTRUE(s$.binned)
  keys = widget_keys(table, c(s$x, s$facet))
  switch(s$family,
    line = , slope = if (coloured) series(s$color) else rep("s1", n),
    dumbbell = { y = as.character(table[[s$y]]); paste0("g", match(y, unique(y))) },
    bar = , dot = , scatter = , bubble = if (coloured) series(s$color) else paste0("m", seq_len(n)),
    box = paste0("g", match(keys, unique(keys))),
    paste0("m", seq_len(n)))
}

# The tooltip of a line or a slope itself (not of one of its points): the name of its colour's value, or, with no colour, what the line shows.
widget_series <- function(s, cb, table) {
  if (!s$family %in% c("line", "slope", "dumbbell")) return(rep(NA_character_, nrow(table)))
  # a dumbbell's line is its group's: both values and the difference (the second less the first)
  if (identical(s$family, "dumbbell")) {
    f = table[[s$color]]
    lv = intersect(levels(f), as.character(f))
    v = table[[value_name(s)]]
    fmt = fact_value_fmt(s)
    y = as.character(table[[s$y]])
    text = purrr::map_chr(unique(y), function(k) {
      a = v[y == k & as.character(f) == lv[1]]; b = v[y == k & as.character(f) == lv[2]]
      paste(c(widget_line(cb_label(cb, s$y), k), widget_line(lv[1], fmt(a)), widget_line(lv[2], fmt(b)),
              widget_line("Difference (second less first)", fmt(b - a))), collapse = "\n")
    })
    return(unname(text[match(y, unique(y))]))
  }
  if (!is.null(s$color) && !identical(s$color, s$facet)) widget_line(cb_label(cb, s$color), table[[s$color]])
  else rep(widget_esc(value_label(s, cb)), nrow(table))
}

# The plotted table with the tooltip, the hover group and (for a line) the series of each row added.
widget_table <- function(s, cb, table) {
  table = as.data.frame(table)
  table[[WIDGET_TIP]] = widget_tips(s, cb, table)
  table[[WIDGET_HOVER]] = widget_hover(s, table)
  table[[WIDGET_SERIES]] = widget_series(s, cb, table)
  table
}

# What the statistics of ggplot2 give a tooltip, written with the facts' own formats (these two are in the environment the interactive
#   plot is evaluated in, as chart_bin_tip(), chart_cell_tip() and chart_hex_tip()).
widget_bin_tip <- function(label, lo, hi, count)
  paste0(widget_line(label, paste(fact_num(lo, FALSE), "to", fact_num(hi, FALSE))), "\n", widget_line("Count", fact_count(count)))
widget_cell_tip <- function(label, count) widget_line(paste(label, "in this cell"), fact_count(count))
widget_hex_tip <- function(label, count) widget_line(paste(label, "in this hexagon"), fact_count(count))

# `cl` (a call to a layer) with `extra` (an aes() call) added to its mapping.
widget_with_aes <- function(cl, extra) {
  is_aes = purrr::map_lgl(as.list(cl), function(a) is.call(a) && identical(a[[1]], sym("aes")))
  if (any(is_aes)) {
    i = which(is_aes)[1]
    cl[[i]] = as.call(c(as.list(cl[[i]]), as.list(extra)[-1]))
    cl
  } else as.call(c(as.list(cl)[1], list(mapping = extra), as.list(cl)[-1]))
}

# The layers of a plot (plot_calls()) with each data layer swapped for its interactive twin. A mark carries the tooltip and the
#   hover group of its row; a histogram bin and a cell of a binned scatter, which ggplot2 computes, carry them written from the
#   statistic. A line is one element, so it carries the hover group and the name of its series, and each of its points
#   carries the tooltip of the row in an invisible point of WIDGET_HIT_SIZE (a slope chart's points are drawn, so they carry it). A ring round a marked point (it has
#   a shape) stays a plain layer, as do labels, fitted curves, rugs and every scale and theme.
widget_calls <- function(calls, s, cb) {
  twin = function(cl, f) { cl[[1]] = call("::", sym("ggiraph"), sym(WIDGET_GEOMS[[f]])); cl }
  mark = aes_call(tooltip = sym(WIDGET_TIP), data_id = sym(WIDGET_HOVER))
  stat_tip = if (identical(s$family, "histogram"))
      call("after_stat", call("chart_bin_tip", cb_label(cb, s$x), if (isTRUE(s$log_x)) quote(10^xmin) else quote(xmin),
                              if (isTRUE(s$log_x)) quote(10^xmax) else quote(xmax), quote(count)))
    else call("after_stat", call(if (isTRUE(s$.hex)) "chart_hex_tip" else "chart_cell_tip", row_word(cb), quote(count)))
  # The tooltip and the hover group are discrete, and ggplot2 numbers a mark's group from every discrete aesthetic it has, so a bar of grouped
  #   bars would get a group of its own and be dodged in another order than the picture's. The group is given as the picture's own: the
  #   interaction of the bar's group and its colour (what ggplot2 makes of them: the first varies slowest), its colour only on the bars of a highlight.
  is_group = identical(s$family, "bar") && !is.null(s$color) && is.null(s$highlight)
  group = if (is_group) call("as.integer", call("interaction", sym(s$x), sym(s$color), lex.order = TRUE, drop = TRUE))
  stat_mark = aes_call(tooltip = stat_tip, data_id = call("after_stat", call("paste0", "b", quote(seq_along(count)))))
  # a violin is one shape for each group of its x, and the tooltip and hover group would renumber the groups: it is given the picture's own (the groups of x present in its rows)
  violin = c(as.list(mark), list(group = call("as.integer", call("factor", sym(s$x))))) |> as.call()
  unlist(purrr::map(calls, function(cl) {
    f = if (is.call(cl) && is.symbol(cl[[1]])) as.character(cl[[1]]) else ""
    if (!f %in% names(WIDGET_GEOMS) || (f == "geom_point" && "shape" %in% names(cl))) return(list(cl))
    if (f %in% c("geom_histogram", "geom_bin_2d", "geom_hex")) return(list(twin(widget_with_aes(cl, stat_mark), f)))
    if (identical(f, "geom_violin")) return(list(twin(widget_with_aes(cl, violin), f)))
    if (!identical(f, "geom_line")) return(list(twin(widget_with_aes(cl, if (identical(f, "geom_col") && is_group) c(as.list(mark), list(group = group)) |> as.call() else mark), f)))
    line = twin(widget_with_aes(cl, aes_call(tooltip = sym(WIDGET_SERIES), data_id = sym(WIDGET_HOVER))), f)
    if (s$family %in% c("slope", "dumbbell")) return(list(line))
    hit = widget_with_aes(cl, mark)
    hit$linewidth = NULL
    hit$size = WIDGET_HIT_SIZE
    hit$alpha = 0
    list(line, twin(hit, "geom_point"))
  }), recursive = FALSE)
}

# The typefaces the SVG is drawn and measured in, as girafe() takes them (a gdtools font_set: the sans and serif of the chart, and
#   the sans for mono and symbol). gdtools::font_set() would write each font file into the user's data folder and add it to the
#   widget as a style sheet; the page already carries the bundled faces with @font-face (font_face_css(); the exported page inlines
#   them), under the names the SVG's text uses, so the set names the families and carries no file.
widget_font_set <- function() {
  fam = list(sans = chart_font_family("sans"), serif = chart_font_family("serif"))
  fam = c(fam, list(mono = fam$sans, symbol = fam$sans))
  structure(c(fam, list(dependencies = list(), dsvg_fonts = fam, sources = list())), class = "font_set")
}

# The options of the girafe widget: the SVG scales with its container (so a narrow card scales the whole chart down and nothing is
#   cut), no toolbar (every group of buttons hidden, so no download button and no zoom), no selection by click, and the pointer
#   shows a tooltip in the style's colours and dims every mark that is not in the hovered mark's group.
widget_options <- function(st) {
  edge = paste0("stroke:", st$text, ";stroke-width:1.5px;")
  list(ggiraph::opts_sizing(rescale = TRUE, width = 1),
       ggiraph::opts_toolbar(saveaspng = FALSE, hidden = c("selection", "zoom", "misc")),
       ggiraph::opts_zoom(min = 1, max = 1),
       ggiraph::opts_selection(type = "none"),
       ggiraph::opts_hover(css = ggiraph::girafe_css(css = "opacity:1;", area = edge, point = edge, line = "stroke-width:3.5px;", text = "stroke:none;")),
       ggiraph::opts_hover_inv(css = "opacity:0.25;"),
       ggiraph::opts_tooltip(css = paste0("background:", st$background, ";color:", st$text, ";border:1px solid ", st$text_2, ";border-radius:3px;padding:6px 9px;",
                                          "font-family:", font_css(chart_font_family("sans")), ";font-size:13px;line-height:1.4;text-align:left;box-shadow:0 2px 8px rgba(0,0,0,.25);"),
                             opacity = 1, offx = 12, offy = 12, use_fill = FALSE, use_stroke = FALSE))
}

# The girafe widget of a spec_plot(): its interactive variant (attr(plot, "widget_plot"), a function, so the work is done only for a
#   chart that is made interactive) drawn at the chart's own size in inches (spec_size(): 7 by 4.5 by default, the size of the
#   drawing for a screen when it was asked for one) and given the options above. The plot's own palette and style are in it; a
#   different one needs a new spec_plot(). Warnings of the drawing are kept as attr(, "warnings").
spec_widget <- function(plot, palette = attr(plot, "palette") %||% chart_palette_default()) {
  s = attr(plot, "spec") %||% list()
  wp = attr(plot, "widget_plot")
  size = spec_size(s, attr(plot, "table"))
  said = character(0)
  w = withCallingHandlers(
    ggiraph::girafe(ggobj = if (is.function(wp)) wp() else plot, width_svg = size[["width"]], height_svg = size[["height"]],
                    font_set = widget_font_set(), options = widget_options(chart_style(palette$style))),
    warning = function(cond) { said <<- c(said, conditionMessage(cond)); invokeRestart("muffleWarning") })
  # Where Inter is not there the chart draws in the default "sans", which is not a CSS name (a browser would draw it in its serif font).
  w$x$html = gsub("font-family='sans'", "font-family='sans-serif'", w$x$html, fixed = TRUE)
  attr(w, "warnings") = unique(said)
  w
}

# A font family as a CSS font-family list for the page (the bundled families are declared with @font-face, see CHART_FONT_CSS in
#   R/ui.R): the family, then the generic one it falls back to. The default names "sans" and "serif" that charts fall back to are
#   not CSS names.
font_css <- function(family) {
  bundled = purrr::keep(CHART_FONTS, function(f) startsWith(family, f$family))
  if (length(bundled)) (if (identical(family, bundled[[1]]$family)) bundled[[1]]$css else paste0("'", family, "', ", bundled[[1]]$css))
  else switch(family, sans = "sans-serif", serif = "serif", family)
}

# The static chart at SPEC_DPI pixels per inch and its size in inches, drawn on the device chart_device() opens
#   (ragg, else cairo, else svglite: a PNG, or an SVG on a server that has only svglite; the file's ending and media
#   type are chart_device_ext() and chart_device_type()). Returns the size in inches, invisibly.
spec_png <- function(plot, file, size = spec_size(attr(plot, "spec"), attr(plot, "table")), dpi = SPEC_DPI, kind = chart_device_kind(), marking = NULL) {
  band = if (is.null(marking)) 0 else MARKING_BAND_IN
  chart_device(file, size[["width"]], size[["height"]] + 2 * band, dpi, kind)
  on.exit(grDevices::dev.off())
  if (is.null(marking)) print(plot) else marking_draw(marking, size[["width"]], function() print(plot, newpage = FALSE), kind)
  invisible(size)
}

# ---- the classification marking on a picture or a video (Phase 10 Part A) -----------------------------------------------------
# A file that can be separated from the page carries the marking in its pixels: a band across the top and another across the bottom, white bold
#   type on #b40404 as on the pages (the sans typeface the charts use, bold). The bands are drawn by R on the same device as the chart, with grid:
#   `marking` is the text (marking_clean() has made it one line), the chart itself is drawn unchanged in the rows between the bands, and the
#   file is MARKING_BAND_IN inches taller at the top and again at the bottom than the chart (spec_png() adds them; a video keeps its 16 to 9 frame
#   and draws the chart in what is left). Letters of a bitmap are placed one by one with MARKING_SPACING of an em between them (grid has no
#   letter spacing); svglite writes the whole text as one element, so that the text of an SVG can be found and read, without the spacing. The
#   text is the size MARKING_TEXT_PT points, or smaller when the marking would not fit in the band's width, so a long one is never cut off.
MARKING_MAX <- 80L              # the most characters of a marking (marking_clean() in R/ui.R refuses more)
MARKING_COLOUR <- "#b40404"
MARKING_BAND_IN <- 0.2
MARKING_TEXT_PT <- 9
MARKING_SPACING <- 0.06
MARKING_MARGIN <- 0.04

# One band as a grob for a band `width_in` inches wide (the device must be open: the type is measured).
marking_band <- function(text, width_in, kind = chart_device_kind()) {
  gp = function(size) grid::gpar(fontfamily = chart_font_family("sans"), fontface = "bold", fontsize = size, col = "white")
  spaced = !identical(kind, "svglite")
  parts = if (spaced) strsplit(text, "")[[1]] else text
  base = MARKING_TEXT_PT
  grid::pushViewport(grid::viewport(gp = gp(base)))
  w = grid::convertWidth(grid::stringWidth(parts), "points", valueOnly = TRUE)
  grid::popViewport()
  gap = if (spaced) MARKING_SPACING * base else 0
  total = sum(w) + gap * (length(parts) - 1L)
  k = min(1, width_in * 72 * (1 - 2 * MARKING_MARGIN) / total)
  x = (width_in * 72 - total * k) / 2 + (cumsum(w) - w + gap * (seq_along(w) - 1L)) * k
  grid::gTree(children = grid::gList(
    grid::rectGrob(gp = grid::gpar(fill = MARKING_COLOUR, col = NA)),
    # the baseline sits so that the capitals (about 0.72 of the size) are centred in the band, whatever letters the text has
    grid::textGrob(parts, x = grid::unit(x, "points"), y = grid::unit(0.5, "npc") - grid::unit(0.36 * base * k, "points"), hjust = 0, vjust = 0, gp = gp(base * k))))
}

# Draws `draw()` (which draws the chart in the current viewport) between a band at the top and one at the bottom of the open device, which is
#   `width_in` inches wide. Starts a new page.
marking_draw <- function(marking, width_in, draw, kind = chart_device_kind()) {
  band = grid::unit(MARKING_BAND_IN, "inches")
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(3, 1, heights = grid::unit.c(band, grid::unit(1, "null"), band))))
  grob = marking_band(marking, width_in, kind)
  purrr::walk(c(1L, 3L), function(row) {
    grid::pushViewport(grid::viewport(layout.pos.row = row))
    grid::grid.draw(grob)
    grid::popViewport()
  })
  grid::pushViewport(grid::viewport(layout.pos.row = 2))
  draw()
  grid::popViewport(2)
  invisible(NULL)
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
  if (identical(spec$family, "dumbbell"))
    h = max(h, 1.9 - save + SPEC_ROW_INCHES * length(unique(table[[spec$y]])))
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


# ---- the video (Phase 9 Part B) ---------------------------------------------------------------------------------------------
# A chart that moves: its marks come in over about 3 seconds, its numbers and names fade in over 0.6, and the finished chart is
#   held for 2. The frames are drawn by our own renderer on the device chart_device() opens and encoded to MP4 by the av package
#   (no gganimate). How a frame is made: the finished chart is built once (ggplot2::ggplot_build() of spec_plot()'s plot), so its
#   scales, breaks, axes, legends and panels are the finished chart's and cannot move; a frame is that built object with the
#   data of each layer cut down for the moment (a line drawn up to some x, a bar at some share of its height, the points so far),
#   which is how gganimate draws its frames too. At progress 1 every layer's data is the built data untouched, so the last frame
#   is the static chart. Nothing here calls a model.

# Whether the av package is installed (a function, so that a test can stand in for a server that has not got it).
av_installed <- function() length(find.package("av", quiet = TRUE)) > 0L

# Whether the av package's encoder can write H.264 (libx264), which every browser plays; without it av would choose a codec some browsers cannot play.
av_has_h264 <- function() isTRUE(tryCatch("libx264" %in% av::av_encoders()$name, error = function(e) FALSE))

# Whether this server can make a video: av with an H.264 encoder, and a device that writes pictures a video can be made of (not svglite's SVG).
video_available <- function() av_installed() && av_has_h264() && chart_device_kind() %in% c("ragg", "cairo")

# Why it cannot, in words for Start here; NULL when it can.
video_unavailable_text <- function() {
  if (!av_installed()) return("Videos are unavailable on this server: the av package is not installed, so the Animate button is not shown.")
  if (!av_has_h264()) return("Videos are unavailable on this server: the av package here has no H.264 encoder (libx264), so the Animate button is not shown.")
  if (!chart_device_kind() %in% c("ragg", "cairo"))
    return("Videos are unavailable on this server: charts are drawn here as SVG pictures, which a video cannot be made of, so the Animate button is not shown.")
  NULL
}

SPEC_VIDEO_FPS <- 24L                   # frames a second in the file
SPEC_VIDEO_MOTION_S <- 3                # seconds the marks take to come in
SPEC_VIDEO_LABELS_S <- 0.6              # seconds the labels, annotations and names take to fade in
SPEC_VIDEO_HOLD_S <- 2                  # seconds the finished chart is held (its file repeated in the encoder's input, not drawn again)
SPEC_VIDEO_PX <- list(card = c(width = 1280, height = 720), download = c(width = 1920, height = 1080))
SPEC_VIDEO_WIDTHS <- c(8, 10, 12)       # the widths in inches of the 16 to 9 canvas a chart is drawn on (8 by 4.5, the usual), narrowest first; dots per inch are pixels over this
# The dashboard's video (Phase 10b) is drawn for the width it is shown at, as its pictures are: the pixels of the file are twice the CSS pixels of the
#   card (a sharp picture on a screen of twice the density), and the canvas is the CSS width over 96 inches wide, so its text comes out near 12 CSS
#   pixels. `desk` is a card that shares its row (544 CSS pixels), `wide` one in a full-row card (640).
# A card's video is drawn as the card's picture is (spec_plot() with the picture's `web`, at its size from spec_size()) and the marking bands
#   added above and below it, so it lays out like the picture: the same end labels, legend and breaks. Its width in pixels is the picture's
#   (CSS pixels times DASH_SCALE: 1080 for a card that shares its row, 1280 for one with its row); its height follows from the picture's shape and
#   the bands (spec_video() rounds it to an even number, as H.264 needs). The 1920 by 1080 download keeps its 16 to 9 frame.
SPEC_VIDEO_DASH_PX <- list(desk = c(width = 1080), wide = c(width = 1280))
SPEC_VIDEO_STAGGER <- 0.5               # each bar, dot, box or column starts this much later than the one before, the last by this share of the motion
SPEC_VIDEO_POINTS_SHARE <- 0.7          # a scatter or bubble with a fitted curve: the points take this share of the motion, then the curve is drawn
SPEC_VIDEO_RAMP <- 0.04                 # points growing in at once, as a share of all the points (at least 2)
SPEC_VIDEO_SLOW_S <- 45                 # a video that takes longer than this to draw is drawn at half the frame rate, each frame shown twice

# Progress 0 to 1 over the motion and the labels together, as the share of each that has been done.
video_phases <- function(progress) {
  total = SPEC_VIDEO_MOTION_S + SPEC_VIDEO_LABELS_S
  list(motion = video_clamp(progress * total / SPEC_VIDEO_MOTION_S),
       labels = video_clamp((progress * total - SPEC_VIDEO_MOTION_S) / SPEC_VIDEO_LABELS_S))
}

video_clamp <- function(x) pmin(1, pmax(0, x))

# A cubic ease in and out: slow, fast, slow; 0 at 0 and 1 at 1.
video_ease <- function(t) {
  t = video_clamp(t)
  ifelse(t < 0.5, 4 * t^3, 1 - (-2 * t + 2)^3 / 2)
}

# The frames drawn for a video, with progress at 0, 1 / (n - 1), ... 1; `fps` is the frames drawn each second.
video_frame_count <- function(fps = SPEC_VIDEO_FPS) as.integer(round((SPEC_VIDEO_MOTION_S + SPEC_VIDEO_LABELS_S) * fps)) + 1L

# How far each of a set of marks has got when the motion is at `m`: the marks of a panel start in the order of `key` (the first at once,
#   the last SPEC_VIDEO_STAGGER of the motion later), each eased. Every mark is at 1 when the motion is.
video_staggered <- function(key, panel, m) {
  rk = stats::ave(as.numeric(key), panel, FUN = function(v) rank(v, ties.method = "first"))
  n = stats::ave(as.numeric(key), panel, FUN = length)
  delay = SPEC_VIDEO_STAGGER * (rk - 1) / pmax(1, n - 1)
  video_ease((m - delay) / (1 - SPEC_VIDEO_STAGGER))
}

# What a layer is for the motion, from its geom and its built data: "bars", "dots", "points", "line", "linepoints" (the points of a slope
#   chart), "curve", "box", "tiles", "rug", "label" (text, and the ring round a marked point: they fade in at the end) or "keep".
video_role <- function(layer, d, s) {
  geom = class(layer$geom)[[1]]
  if (geom %in% c("GeomText", "GeomLabel", "GeomTextRepel", "GeomLabelRepel", "GeomSegment")) return("label")
  if (identical(geom, "GeomPoint") && nrow(d) && all(d$shape %in% 1)) return("label")
  switch(geom, GeomCol = , GeomBar = , GeomRect = "bars", GeomLine = "line", GeomSmooth = "curve", GeomBoxplot = "box", GeomViolin = "violin", GeomTile = , GeomBin2d = , GeomHex = "tiles",
         GeomRug = "rug", GeomPoint = if (identical(s$family, "dot")) "dots" else if (identical(s$family, "slope")) "linepoints" else "points",
         "keep")
}

# Bars (and a histogram's bars) rise from the axis: the value end of each is its built value times its share of the way, the bars that
#   have not started are not drawn. Upright bars start left to right, sideways ones from the top.
video_bars <- function(d, m) {
  if (!nrow(d)) return(d)
  flipped = isTRUE(d$flipped_aes[[1]])
  cols = intersect(if (flipped) c("xmin", "xmax", "x") else c("ymin", "ymax", "y"), names(d))
  key = if (flipped) -(d$ymin + d$ymax) / 2 else (d$xmin + d$xmax) / 2
  k = video_staggered(key, d$PANEL, m)
  d[cols] = lapply(d[cols], function(v) v * k)
  d[k > 0, , drop = FALSE]
}

# Dots travel from the value axis (the panel's edge) to their value, fading in as they leave it.
video_dots <- function(d, m, panel_params, flipped) {
  if (!nrow(d)) return(d)
  vcol = if (flipped) "x" else "y"
  edge = purrr::map_dbl(as.integer(d$PANEL), function(i) panel_params[[i]][[paste0(vcol, ".range")]][[1]])
  k = video_staggered(if (flipped) -d$y else d$x, d$PANEL, m)
  d[[vcol]] = edge + (d[[vcol]] - edge) * k
  d$alpha = pmin(ifelse(is.na(d$alpha), 1, d$alpha), video_clamp(4 * k))
  d[k > 0, , drop = FALSE]
}

# A line is drawn up to `at` on x, its newest point interpolated between the data points on either side of it; a line that has not
#   begun is not drawn. Rows are taken line by line (panel and group) in the order of x.
video_cut <- function(d, at) {
  if (!nrow(d)) return(d)
  parts = split(seq_len(nrow(d)), interaction(d$PANEL, d$group, drop = TRUE))
  out = purrr::map(parts, function(ix) {
    r = d[ix, , drop = FALSE]
    r = r[order(r$x), , drop = FALSE]
    keep = r$x <= at
    if (!any(keep)) return(r[0, , drop = FALSE])
    last = max(which(keep))
    if (last == nrow(r) || r$x[[last]] == at) return(r[keep, , drop = FALSE])
    f = (at - r$x[[last]]) / (r$x[[last + 1L]] - r$x[[last]])
    new = r[last, , drop = FALSE]
    new$x = at
    cols = intersect(c("y", "ymin", "ymax"), names(r))
    new[cols] = lapply(r[cols], function(v) v[[last]] + f * (v[[last + 1L]] - v[[last]]))
    rbind(r[keep, , drop = FALSE], new)
  })
  do.call(rbind, unname(out))
}

# Points come in along x: the first `share` of all the points of the chart in the order of x, each growing from nothing over a short
#   run of points. `allx` is the x of every point of every points layer.
video_points <- function(d, share, allx) {
  if (!nrow(d)) return(d)
  n = length(allx)
  ramp = max(2, SPEC_VIDEO_RAMP * n)
  s = video_clamp((share * (n + ramp) - findInterval(d$x, sort(allx)) + 1) / ramp)
  d = d[s > 0, , drop = FALSE]
  g = video_ease(s[s > 0])
  d$size = d$size * g
  d$stroke = d$stroke * g
  d
}

# A rug has the marks of the points that have come in.
video_rug <- function(d, share, allx) {
  if (!nrow(d)) return(d)
  n = length(allx)
  d[findInterval(d$x, sort(allx)) <= share * (n + max(2, SPEC_VIDEO_RAMP * n)), , drop = FALSE]
}

# A violin grows from its middle: its width (the built `violinwidth`, a share of the widest) times the share, a violin that has not
#   started is not drawn.
video_violins <- function(d, m) {
  if (!nrow(d)) return(d)
  flipped = isTRUE(d$flipped_aes[[1]])
  # a violin is many rows (its outline), all with one clock: the clock of its first row
  grp = paste(d$PANEL, d$group)
  first = !duplicated(grp)
  kg = video_staggered(if (flipped) -d$y[first] else d$x[first], d$PANEL[first], m)
  k = kg[match(grp, grp[first])]
  d$violinwidth = d$violinwidth * k
  d[k > 0, , drop = FALSE]
}

# A dumbbell comes in two moves (Phase 10 Part C): the first dots of each row appear, top row first, over the first share of the motion;
#   then each row's line and second dot travel out from the first dot to their places, again top row first. `first` is the built data of
#   the first dots (where each row's line starts).
SPEC_VIDEO_DUMBBELL_FIRST <- 0.3
video_dumbbell <- function(d, m, role, first) {
  if (!nrow(d)) return(d)
  # how far each row has got: the rows of the first dots (one for each group) say the order, so a group's two dots and its line move together
  at = paste(d$PANEL, d$y)
  by_row = function(mm) video_staggered(-first$y, first$PANEL, mm)[match(at, paste(first$PANEL, first$y))]
  if (identical(role, "dumbbell_first")) {
    k = by_row(video_clamp(m / SPEC_VIDEO_DUMBBELL_FIRST))
    d$alpha = pmin(ifelse(is.na(d$alpha), 1, d$alpha), video_clamp(4 * k))
    return(d[k > 0, , drop = FALSE])
  }
  k = by_row(video_clamp((m - SPEC_VIDEO_DUMBBELL_FIRST) / (1 - SPEC_VIDEO_DUMBBELL_FIRST)))
  start = first$x[match(at, paste(first$PANEL, first$y))]
  moves = abs(d$x - start) > 1e-9
  d$x = ifelse(moves, start + (d$x - start) * k, d$x)
  if (identical(role, "dumbbell_second")) d$alpha = pmin(ifelse(is.na(d$alpha), 1, d$alpha), video_clamp(4 * k))
  d[k > 0, , drop = FALSE]
}

# A box opens from its median outward: whiskers, quartiles and notches are the median plus their built distance times the share, a
#   box that has not started is not drawn, and the outlying points come once it is open.
video_boxes <- function(d, m) {
  if (!nrow(d)) return(d)
  flipped = isTRUE(d$flipped_aes[[1]])
  nm = function(x) if (flipped) c(ymin = "xmin", lower = "xlower", middle = "xmiddle", upper = "xupper", ymax = "xmax",
                                  notchupper = "xnotchupper", notchlower = "xnotchlower")[[x]] else x
  k = video_staggered(if (flipped) -d$y else d$x, d$PANEL, m)
  mid = d[[nm("middle")]]
  cols = intersect(purrr::map_chr(c("ymin", "lower", "upper", "ymax", "notchupper", "notchlower"), nm), names(d))
  d[cols] = lapply(d[cols], function(v) mid + (v - mid) * k)
  d$outliers = purrr::map2(d$outliers, k, function(o, kk) if (kk >= 1) o else numeric(0))
  d[k > 0, , drop = FALSE]
}

# Cells fill in, a column of them at a time (a row when x is not ordered), each fading in as its turn comes.
video_tiles <- function(d, m, by_column) {
  if (!nrow(d)) return(d)
  key = if (by_column) d$x else -d$y
  k = video_staggered(match(key, sort(unique(key))), d$PANEL, m)
  d$alpha = ifelse(is.na(d$alpha), 1, d$alpha) * k
  d[k > 0, , drop = FALSE]
}

# The labels fade in: none before their phase, then each at `a` of its colour's strength.
video_labels <- function(d, raw, a) {
  if (raw >= 1) return(d)
  if (raw <= 0 || !nrow(d)) return(d[0, , drop = FALSE])
  d$alpha = ifelse(is.na(d$alpha), a, d$alpha * a)
  d
}

# Everything a video of one chart needs, worked out once: the finished chart's plot and built object, what each layer is for the
#   motion, and how x is ordered. `p` is spec_plot()'s plot, `cb` the codebook.
video_context <- function(p, cb) {
  b = ggplot2::ggplot_build(p)
  s = attr(p, "spec")
  roles = purrr::map_chr(seq_along(p$layers), function(i) video_role(p$layers[[i]], b$data[[i]], s))
  # a dumbbell's layers: its line, its first dots, its second dots (in the order the plot draws them)
  if (identical(s$family, "dumbbell")) {
    dots = which(roles == "dots" | roles == "points")
    roles[roles == "line"] = "dumbbell_line"
    roles[dots[1]] = "dumbbell_first"
    roles[dots[2]] = "dumbbell_second"
  }
  xs = function(role) unlist(purrr::map(b$data[roles == role], function(d) d$x), use.names = FALSE)
  e = if (!is.null(s$x)) cb_entry(cb, s$x)
  list(plot = p, built = b, spec = s, roles = roles, line_x = if (length(c(xs("line"), xs("linepoints")))) range(c(xs("line"), xs("linepoints")), na.rm = TRUE),
       point_x = xs("points"), has_curve = any(roles == "curve"),
       by_column = !is.null(e) && (is_time(e) || e$type %in% c("number", "integer", "ordered")))
}

# The built data of layer i for a progress.
video_layer <- function(ctx, i, ph) {
  d = ctx$built$data[[i]]
  role = ctx$roles[[i]]
  m = ph$motion
  if (identical(role, "label")) return(video_labels(d, ph$labels, video_ease(ph$labels)))
  if (m >= 1) return(d)
  points_share = if (ctx$has_curve) video_ease(m / SPEC_VIDEO_POINTS_SHARE) else video_ease(m)
  switch(role,
         bars = video_bars(d, m),
         dots = video_dots(d, m, ctx$built$layout$panel_params, isTRUE(ctx$spec$.flip)),
         line = , linepoints = {
           at = ctx$line_x[[1]] + video_ease(m) * diff(ctx$line_x)
           if (identical(role, "line")) video_cut(d, at) else d[d$x <= at, , drop = FALSE]
         },
         curve = if (nrow(d) && m > SPEC_VIDEO_POINTS_SHARE) video_cut(d, min(d$x) + video_ease((m - SPEC_VIDEO_POINTS_SHARE) / (1 - SPEC_VIDEO_POINTS_SHARE)) * diff(range(d$x))) else d[0, , drop = FALSE],
         points = video_points(d, points_share, ctx$point_x),
         rug = video_rug(d, points_share, ctx$point_x),
         box = video_boxes(d, m),
         tiles = video_tiles(d, m, ctx$by_column),
         violin = video_violins(d, m),
         dumbbell_first = , dumbbell_second = , dumbbell_line = video_dumbbell(d, m, role, ctx$built$data[[which(ctx$roles == "dumbbell_first")]]),
         d)
}

# One frame: the finished chart's built object with the layers' data for this progress (0 to 1).
video_frame <- function(ctx, progress) {
  ph = video_phases(progress)
  b = ctx$built
  b$data = purrr::map(seq_along(ctx$roles), function(i) video_layer(ctx, i, ph))
  b
}

# The chart as a video draws it: spec_plot() on a 16 to 9 canvas, the narrowest of SPEC_VIDEO_WIDTHS inches wide whose height holds the
#   chart (sideways bars and rows of panels need more than the usual 4.5; past the widest, the chart is drawn as it fits). The wider the
#   canvas, the smaller its text on the screen, which is why the widths are few and the first is the usual one. `bare`: no title, subtitle
#   or source line (the dashboard's page says them). Returns the plot, with the canvas in inches as attribute "canvas".
#   With `web` (a card's video: the `web` its picture is drawn with) the chart is drawn exactly as that picture, at the size spec_size() gives it,
#   and the canvas is that size with `band` inches added above and below for the marking: the picture's shape, not 16 to 9.
video_plot <- function(spec, data, cb, palette = chart_palette_default(), bare = FALSE, widths = SPEC_VIDEO_WIDTHS, band = 0, web = NULL) {
  if (!is.null(web)) {
    p = spec_plot(spec, data, cb, palette, web = web)
    sz = spec_size(attr(p, "spec"), attr(p, "table"))
    attr(p, "canvas") = c(width = sz[["width"]], height = sz[["height"]] + 2 * band)
    attr(p, "chart") = c(width = sz[["width"]], height = sz[["height"]])
    return(p)
  }
  at = function(w) {
    h = w * 9 / 16
    p = spec_plot(spec, data, cb, palette, web = list(width = w, height = h - 2 * band, bare = bare))
    attr(p, "canvas") = c(width = w, height = h)
    attr(p, "chart") = c(width = w, height = h - 2 * band)
    p
  }
  fits = function(p) spec_size(attr(p, "spec"), attr(p, "table"))[["height"]] <= attr(p, "chart")[["height"]] + 1e-9
  purrr::reduce(widths, function(p, w) if (!is.null(p) && fits(p)) p else at(w), .init = NULL)
}

# The frames of a chart's video, for progress 0 to 1 in `n` steps: the built chart for each (a ggplot_built object, which
#   ggplot2::ggplot_gtable() draws). The chart's style is the palette's (palette$style); `style` names another. The plot as the static
#   chart is attribute "plot", the progress of each "progress".
spec_frames <- function(spec, data, cb, palette = chart_palette_default(), style = palette$style, n = video_frame_count(), bare = FALSE, widths = SPEC_VIDEO_WIDTHS, marking = NULL) {
  palette$style = style
  ctx = video_context(video_plot(spec, data, cb, palette, bare, widths, band = if (is.null(marking)) 0 else MARKING_BAND_IN), cb)
  progress = seq(0, 1, length.out = n)
  structure(purrr::map(progress, function(p) video_frame(ctx, p)), plot = ctx$plot, progress = progress)
}

# The pinned things of a frame, to be compared with another's: each panel's range and breaks on both axes, as numbers.
video_scales <- function(frame) {
  purrr::map(frame$layout$panel_params, function(pp)
    list(x_range = unname(pp$x.range), y_range = unname(pp$y.range), x_breaks = unname(pp$x$get_breaks()), y_breaks = unname(pp$y$get_breaks()),
         x_labels = pp$x$get_labels(), y_labels = pp$y$get_labels()))
}

# One frame as a picture file, `width_in` by `height_in` inches at `dpi`, on the device chart_device() opens.
video_draw <- function(frame, file, width_in, height_in, dpi, kind = chart_device_kind(), marking = NULL) {
  chart_device(file, width_in, height_in, dpi, kind)
  on.exit(grDevices::dev.off())
  # after the device is open: building the table measures text, which opens a device when none is. A line not yet begun is a group of one
  #   point, which ggplot2 mentions each time (as a message, in ggplot2 4; as a warning before); that is the motion, not a fault.
  once = function(cnd) grepl("only one observation", conditionMessage(cnd), fixed = TRUE)
  withCallingHandlers({
    gt = ggplot2::ggplot_gtable(frame)
    if (is.null(marking)) {
      grid::grid.newpage()
      grid::grid.draw(gt)
    } else marking_draw(marking, width_in, function() grid::grid.draw(gt), kind)
  }, warning = function(w) if (once(w)) invokeRestart("muffleWarning"), message = function(m) if (once(m)) invokeRestart("muffleMessage"))
  invisible(file)
}

# The encoder's input for a video: each drawn file shown `each` times, then the last file again for the hold (not drawn again).
video_inputs <- function(files, each = 1L, fps = SPEC_VIDEO_FPS) {
  c(rep(files, each = each), rep(files[[length(files)]], round(SPEC_VIDEO_HOLD_S * fps)))
}

# A video of a chart, written to `file` (MP4, H.264, yuv420p, which a browser plays): `size` pixels wide and high (the download's
#   1920 by 1080 unless said; SPEC_VIDEO_PX), and `small`, when given, a second file of the same frames scaled to the card's 1280 by
#   720 by the encoder, so the frames are drawn once. `drawn_fps` is the frames drawn a second (24; 12 draws half as many and shows each
#   twice; NULL: 24, unless one frame of the label phase, the dearest, shows the drawing would take more than SPEC_VIDEO_SLOW_S, and then
#   12). `widths` are the canvases to try (video_plot()). `on_frame(i, n)` is called after each frame is drawn, `poster` names a file
#   that gets the last frame (the finished chart) as a picture, and `keep` names a folder to leave the frame files in. Returns
#   list(file, small, drawn, inputs, canvas, plot, drawn_fps, seconds = c(draw, encode)). Needs av (video_available()). `marking`, when given, draws the band of marking_draw() on every frame: the
#   frame keeps its 16 to 9 shape and the chart is drawn in the rows between the bands (video_plot() `band`), so the last frame is spec_png() of the same
#   plot with the same marking, pixel for pixel.
spec_video <- function(spec, data, cb, palette = chart_palette_default(), file, size = SPEC_VIDEO_PX$download, small = NULL, bare = FALSE,
                       drawn_fps = NULL, widths = SPEC_VIDEO_WIDTHS, on_frame = NULL, poster = NULL, keep = NULL, marking = NULL, web = NULL) {
  if (!video_available()) stop(video_unavailable_text(), call. = FALSE)
  started = proc.time()[["elapsed"]]
  ctx = video_context(video_plot(spec, data, cb, palette, bare, widths, band = if (is.null(marking)) 0 else MARKING_BAND_IN, web = web), cb)
  canvas = attr(ctx$plot, "canvas")
  dpi = size[["width"]] / canvas[["width"]]
  # a card's video (`web`): its height follows from the canvas, rounded to an even number of pixels (H.264 with yuv420p needs both even)
  #   and the canvas made that many pixels high (less than a pixel taller or shorter than the picture and its bands)
  if (!is.null(web)) {
    size = c(width = size[["width"]], height = 2 * round(size[["width"]] * canvas[["height"]] / canvas[["width"]] / 2))
    canvas[["height"]] = size[["height"]] / dpi
  }
  dir = keep %||% tempfile("chart_video_")
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  if (is.null(keep)) on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  draw = function(p, f) video_draw(video_frame(ctx, p), f, canvas[["width"]], canvas[["height"]], dpi, marking = marking)
  if (is.null(drawn_fps)) {
    t = system.time(draw(0.97, file.path(dir, "probe.png")))[["elapsed"]]
    drawn_fps = if (t * video_frame_count(SPEC_VIDEO_FPS) > SPEC_VIDEO_SLOW_S) SPEC_VIDEO_FPS %/% 2L else SPEC_VIDEO_FPS
  }
  n = video_frame_count(drawn_fps)
  files = file.path(dir, sprintf("frame_%04d.png", seq_len(n)))
  purrr::iwalk(seq(0, 1, length.out = n), function(p, i) {
    draw(p, files[[i]])
    if (is.function(on_frame)) on_frame(i, n)
  })
  if (!is.null(poster)) file.copy(files[[n]], poster, overwrite = TRUE)
  drawn_at = proc.time()[["elapsed"]]
  inputs = video_inputs(files, each = as.integer(round(SPEC_VIDEO_FPS / drawn_fps)))
  encode = function(out, filter) av::av_encode_video(inputs, out, framerate = SPEC_VIDEO_FPS, vfilter = filter, codec = "libx264", verbose = FALSE)
  encode(file, "format=yuv420p")
  if (!is.null(small)) encode(small, paste0("scale=", SPEC_VIDEO_PX$card[["width"]], ":", SPEC_VIDEO_PX$card[["height"]], ":flags=lanczos,format=yuv420p"))
  list(file = file, small = small, drawn = n, inputs = length(inputs), canvas = canvas, plot = ctx$plot, drawn_fps = drawn_fps, px = size,
       seconds = c(draw = drawn_at - started, encode = proc.time()[["elapsed"]] - drawn_at))
}


# ---- Phase 11 Part A: the model's drawing code, run under an allow-list ---------------------------------------------------------
# In Phase 11 the model writes the R code that draws a chart from the table R computed. That code is text from outside (a column
#   name or a label may carry instructions), and the app runs on a server. So the code is never trusted:
#     design_guard(code, cols)    reads it as a syntax tree and refuses it unless every call is a function of the toolkit, every symbol is a
#                                 provided object, a toolkit function, a column of d or a variable the code made itself, and it uses none
#                                 of what DESIGN_DENY names;
#     design_run(code, ...)       evaluates the guarded code in a fresh environment whose parent is emptyenv() and which holds only the toolkit
#                                 and the five provided objects, under a time limit, and draws it through chart_device();
#     design_checks(plot, ...)    refuses a drawn design that writes a number R did not give, clips or overlaps text, starts a bar above
#                                 zero, adds a second axis, drops rows, changes an axis' scale type or sets text below 4.5 to 1.
#   This is an allow-list interpreter, not a proven sandbox (STATUS.md, Phase 11 Part A, says what it does not cover).

DESIGN_MAX_CODE <- 6000L      # characters
DESIGN_MAX_LEN <- 1e6         # the longest vector the toolkit's c(), paste(), rep(), seq() and `:` will make
DESIGN_MAX_CHARS <- 1e5       # the most characters in all the strings of one result of c(), paste() or paste0() (a label that long would be drawn as one text)
DESIGN_MAX_NUM <- 1e7         # a number written in the code may not be this large (a width, a length, a count)
DESIGN_MAX_DEPTH <- 60L       # how deeply the syntax tree may nest
DESIGN_TIME_LIMIT <- 20       # seconds of elapsed and of cpu time for evaluating, building and drawing
DESIGN_ROW_EXTRA <- 12L       # a layer of labels, rules or leaders may have this many rows more than d (an annotation, not a mark)
DESIGN_PROVIDED <- c("d", "facts", "txt", "tok", "pal")
DESIGN_CONSTANTS <- list(T = TRUE, F = FALSE, pi = pi, letters = letters, LETTERS = LETTERS, month.name = month.name, month.abb = month.abb)

# What may not be named at all, with the sentence that says why (one sentence is the reason a refusal gives). Everything not in the
#   toolkit is refused anyway; this list is kept for clarity, and so that the reason names the real danger.
DESIGN_DENY <- list(
  code = c("eval", "evalq", "eval.parent", "parse", "str2lang", "str2expression", "deparse", "deparse1", "substitute", "quote", "bquote", "expression",
           "body", "body<-", "formals", "formals<-", "do.call", "match.fun", "match.call", "match.arg", "Recall", "Reduce", "Filter", "Map", "Position", "Find",
           "sapply", "lapply", "vapply", "mapply", "rapply", "apply", "outer", "Vectorize", "local", "with", "within", "as.function", "as.call", "call",
           "delayedAssign", "makeActiveBinding", "on.exit", "trace", "untrace", "reg.finalizer", "get", "get0", "mget", "assign", "exists", "switch",
           "force", "identity", "Negate", ".Internal", ".Call", ".External", ".Primitive", ".C", ".Fortran", "UseMethod", "NextMethod",
           "standardGeneric", "setClass", "setMethod", "attributes<-", "attr<-", "attr", "attributes", "class<-", "oldClass<-", "levels<-", "names<-",
           "dim<-", "dimnames<-", "environment<-", "parent.env<-", "mode<-", "storage.mode<-", "is.na<-", "units<-", "body<-", "substr<-", "regmatches<-"),
  files = c("file", "url", "gzfile", "bzfile", "xzfile", "unz", "pipe", "fifo", "socketConnection", "download.file", "source", "sys.source", "library",
            "require", "requireNamespace", "loadNamespace", "attachNamespace", "readRDS", "saveRDS", "readLines", "writeLines", "readline", "scan", "read.csv",
            "read.table", "read.delim", "write.csv", "write.table", "load", "save", "save.image", "dput", "dget", "dump", "sink", "unlink", "file.remove", "file.create", "file.copy", "file.rename", "file.exists", "file.path", "dir.create", "list.files", "dir",
            "tempfile", "tempdir", "readBin", "writeBin", "readChar", "writeChar", "ggsave", "png", "pdf", "jpeg", "svg", "tiff", "bmp", "dev.off", "dev.new",
            "graphics.off", "write", "textConnection", "rawConnection", "open", "close", "flush"),
  output = c("print", "cat", "message", "warning", "stop", "invisible", "suppressWarnings", "suppressMessages", "tryCatch", "try", "withCallingHandlers", "signalCondition", "simpleError"),
  system = c("system", "system2", "shell", "shell.exec", "Sys.getenv", "Sys.setenv", "Sys.unsetenv", "Sys.setlocale", "Sys.getlocale", "Sys.time",
             "Sys.sleep", "Sys.info", "Sys.getpid", "Sys.chmod", "Sys.umask", "Sys.glob", "options", "getOption", "setwd", "getwd", "quit", "q",
             "proc.time", "date", "browseURL", "install.packages", "remove.packages", "unloadNamespace", "set.seed", "gc", "Rprof", "debug", "browser", "stopifnot",
             "setTimeLimit", "setSessionTimeLimit", "mem.maxVSize", "Cstack_info", "R.home", "commandArgs"),
  environment = c("environment", "globalenv", "emptyenv", "topenv", "baseenv", "parent.frame", "parent.env", "sys.call", "sys.calls", "sys.frame",
                  "sys.frames", "sys.function", "sys.on.exit", "sys.status", "new.env", "as.environment", "list2env", "env2list", "as.list.environment", "environmentName",
                  "lockEnvironment", "lockBinding", "unlockBinding", "search", "searchpaths", "asNamespace", "getNamespace", "getNamespaceExports", "ls", "rm",
                  "nargs", "interactive", "missing", ".env"),
  loops = c("for", "while", "repeat", "break", "next"))

DESIGN_DENY_WHY <- c(code = "runs or builds code that was not checked",
                     files = "reads, writes or opens files, connections or devices",
                     system = "reaches the machine or the session (programs, settings, the clock, the process)",
                     output = "writes to the console or raises or handles conditions",
                     environment = "looks at or changes R's environments or functions",
                     loops = "is a loop, and loops are not available (use the vectorised functions)")

# The ggplot2 names of the toolkit, typed out, so that a new function in a later ggplot2 is not in it until someone reads it. Left out on purpose:
#   sec_axis, dup_axis (a second axis); coord_polar, coord_radial (pies); ggsave and anything that writes a file; geom_sf, geom_sf_label, geom_sf_text,
#   stat_sf, stat_sf_coordinates, coord_sf, layer_sf, geom_map, annotation_map, annotation_borders, coord_map, coord_quickmap, coord_munch (maps and sf);
#   annotation_custom, annotation_raster (a picture is a decoration that could be read as data, and annotation_custom takes any grob);
#   theme_set, theme_update, theme_replace, theme_get and the theme_sub_* helpers (they change or read the session's theme); from_theme (evaluates
#   an expression of its own); labeller, as_labeller, label_parsed, label_bquote (parse or evaluate text); layer, aes_string, aes_, aes_q, qplot,
#   guide_custom, guide_gengrob, guide_geom, guide_merge, guide_train, guide_transform, element_grob, element_render, scale_type and every low-level
#   constructor (continuous_scale, discrete_scale, ggproto and the like).
DESIGN_GGPLOT2 <- c(
  "ggplot", "aes", "after_stat", "after_scale", "stage", "vars", "labs", "xlab", "ylab", "ggtitle", "guides", "annotate", "theme", "rel", "margin",
  "margin_auto", "margin_part", "unit", "arrow", "expansion", "expand_limits", "lims", "xlim", "ylim", "waiver", "alpha", "fill_alpha", "mean_se", "mean_sdl",
  "geom_abline", "geom_area", "geom_bar", "geom_bin_2d", "geom_bin2d", "geom_blank", "geom_boxplot", "geom_col", "geom_contour", "geom_contour_filled",
  "geom_crossbar", "geom_curve", "geom_density", "geom_density_2d", "geom_density_2d_filled", "geom_density2d", "geom_density2d_filled",
  "geom_dotplot", "geom_errorbar", "geom_errorbarh", "geom_freqpoly", "geom_function", "geom_hex", "geom_histogram", "geom_hline", "geom_jitter",
  "geom_label", "geom_line", "geom_linerange", "geom_path", "geom_point", "geom_pointrange", "geom_polygon", "geom_qq", "geom_qq_line", "geom_quantile",
  "geom_raster", "geom_rect", "geom_ribbon", "geom_rug", "geom_segment", "geom_smooth", "geom_spoke", "geom_step", "geom_text", "geom_tile", "geom_violin",
  "geom_vline",
  "stat_align", "stat_bin", "stat_bin_2d", "stat_bin_hex", "stat_bin2d", "stat_binhex", "stat_boxplot", "stat_connect", "stat_contour", "stat_contour_filled",
  "stat_count", "stat_density", "stat_density_2d", "stat_density_2d_filled", "stat_density2d", "stat_density2d_filled", "stat_ecdf", "stat_ellipse",
  "stat_function", "stat_identity", "stat_manual", "stat_qq", "stat_qq_line", "stat_quantile", "stat_smooth", "stat_spoke", "stat_sum", "stat_summary",
  "stat_summary_2d", "stat_summary_bin", "stat_summary_hex", "stat_summary2d", "stat_unique", "stat_ydensity",
  "scale_alpha", "scale_alpha_binned", "scale_alpha_continuous", "scale_alpha_date", "scale_alpha_datetime", "scale_alpha_discrete", "scale_alpha_identity",
  "scale_alpha_manual", "scale_alpha_ordinal", "scale_color_binned", "scale_color_brewer", "scale_color_continuous", "scale_color_date",
  "scale_color_datetime", "scale_color_discrete", "scale_color_distiller", "scale_color_fermenter", "scale_color_gradient", "scale_color_gradient2",
  "scale_color_gradientn", "scale_color_grey", "scale_color_hue", "scale_color_identity", "scale_color_manual", "scale_color_ordinal", "scale_color_steps",
  "scale_color_steps2", "scale_color_stepsn", "scale_color_viridis_b", "scale_color_viridis_c", "scale_color_viridis_d", "scale_colour_binned",
  "scale_colour_brewer", "scale_colour_continuous", "scale_colour_date", "scale_colour_datetime", "scale_colour_discrete", "scale_colour_distiller",
  "scale_colour_fermenter", "scale_colour_gradient", "scale_colour_gradient2", "scale_colour_gradientn", "scale_colour_grey", "scale_colour_hue",
  "scale_colour_identity", "scale_colour_manual", "scale_colour_ordinal", "scale_colour_steps", "scale_colour_steps2", "scale_colour_stepsn",
  "scale_colour_viridis_b", "scale_colour_viridis_c", "scale_colour_viridis_d", "scale_continuous_identity", "scale_discrete_identity",
  "scale_discrete_manual", "scale_fill_binned", "scale_fill_brewer", "scale_fill_continuous", "scale_fill_date", "scale_fill_datetime", "scale_fill_discrete",
  "scale_fill_distiller", "scale_fill_fermenter", "scale_fill_gradient", "scale_fill_gradient2", "scale_fill_gradientn", "scale_fill_grey", "scale_fill_hue",
  "scale_fill_identity", "scale_fill_manual", "scale_fill_ordinal", "scale_fill_steps", "scale_fill_steps2", "scale_fill_stepsn", "scale_fill_viridis_b",
  "scale_fill_viridis_c", "scale_fill_viridis_d", "scale_linetype", "scale_linetype_binned", "scale_linetype_continuous", "scale_linetype_discrete",
  "scale_linetype_identity", "scale_linetype_manual", "scale_linewidth", "scale_linewidth_binned", "scale_linewidth_continuous", "scale_linewidth_date",
  "scale_linewidth_datetime", "scale_linewidth_discrete", "scale_linewidth_identity", "scale_linewidth_manual", "scale_linewidth_ordinal", "scale_radius",
  "scale_shape", "scale_shape_binned", "scale_shape_continuous", "scale_shape_discrete", "scale_shape_identity", "scale_shape_manual", "scale_shape_ordinal",
  "scale_size", "scale_size_area", "scale_size_binned", "scale_size_binned_area", "scale_size_continuous", "scale_size_date", "scale_size_datetime",
  "scale_size_discrete", "scale_size_identity", "scale_size_manual", "scale_size_ordinal", "scale_x_binned", "scale_x_continuous", "scale_x_date",
  "scale_x_datetime", "scale_x_discrete", "scale_x_log10", "scale_x_reverse", "scale_x_sqrt", "scale_x_time", "scale_y_binned", "scale_y_continuous",
  "scale_y_date", "scale_y_datetime", "scale_y_discrete", "scale_y_log10", "scale_y_reverse", "scale_y_sqrt", "scale_y_time",
  "coord_cartesian", "coord_equal", "coord_fixed", "coord_flip", "coord_trans", "coord_transform",
  "facet_grid", "facet_null", "facet_wrap", "label_both", "label_context", "label_value", "label_wrap_gen",
  "position_dodge", "position_dodge2", "position_fill", "position_identity", "position_jitter", "position_jitterdodge", "position_nudge", "position_stack",
  "guide_axis", "guide_axis_logticks", "guide_axis_stack", "guide_axis_theta", "guide_bins", "guide_colorbar", "guide_colorsteps", "guide_colourbar",
  "guide_coloursteps", "guide_legend", "guide_none", "annotation_logticks",
  "draw_key_abline", "draw_key_blank", "draw_key_boxplot", "draw_key_crossbar", "draw_key_dotplot", "draw_key_label", "draw_key_linerange", "draw_key_path",
  "draw_key_point", "draw_key_pointrange", "draw_key_polygon", "draw_key_rect", "draw_key_smooth", "draw_key_text", "draw_key_timeseries", "draw_key_vline",
  "draw_key_vpath",
  "element_blank", "element_geom", "element_line", "element_point", "element_polygon", "element_rect", "element_text",
  "theme_bw", "theme_classic", "theme_dark", "theme_gray", "theme_grey", "theme_light", "theme_linedraw", "theme_minimal", "theme_test", "theme_void")

# scales: the label_*, breaks_* and the few helpers a design needs. Left out: label_glue (glue evaluates the code in its braces), label_math, label_parse
#   (parse text), label_dictionary.
DESIGN_SCALES <- c(
  "label_bytes", "label_comma", "label_currency", "label_date", "label_date_short", "label_dollar", "label_log", "label_number", "label_number_auto",
  "label_number_si", "label_ordinal", "label_percent", "label_pvalue", "label_scientific", "label_time", "label_timespan", "label_wrap",
  "breaks_exp", "breaks_extended", "breaks_log", "breaks_pretty", "breaks_timespan", "breaks_width",
  "alpha", "comma", "percent", "dollar", "rescale", "rescale_mid", "number", "oob_keep", "oob_squish")

# The other packages, each used only when it is installed.
DESIGN_OTHER <- list(
  ggrepel = c("geom_text_repel", "geom_label_repel"),
  ggtext = c("element_markdown", "element_textbox_simple", "geom_richtext"),
  patchwork = c("plot_layout", "plot_annotation", "plot_spacer", "wrap_plots"),
  dplyr = c("mutate", "filter", "arrange", "group_by", "ungroup", "summarise", "slice_max", "slice_min", "slice_head", "desc", "n", "if_else", "case_when",
            "lag", "lead", "row_number", "first", "last"),
  forcats = c("fct_reorder", "fct_rev", "fct_inorder"))

# Base R: the operators and the small fixed list of functions; `|>` is syntax (the parser writes it as an ordinary call) and has no binding.
#   Beyond the list of the phase prompt: ~ (a formula, for facets, case_when and geom_smooth), !, %in%, %%, %/%, &&, ||, : (a range, size-limited),
#   ceiling, floor, pmin, pmax, cumsum, diff, is.numeric, as.integer, nlevels, any, all, which, isTRUE.
DESIGN_BASE <- c("+", "-", "*", "/", "^", "%%", "%/%", "%in%", "==", "!=", "<", ">", "<=", ">=", "&", "|", "!", "&&", "||", "~", ":",
                 "c", "list", "length", "rev", "seq", "seq_len", "seq_along", "rep", "max", "min", "range", "sum", "mean", "round", "signif", "abs", "sqrt",
                 "log", "log10", "exp", "paste", "paste0", "sprintf", "format", "formatC", "nchar", "toupper", "tolower", "substr", "trimws", "ifelse", "is.na",
                 "factor", "levels", "as.character", "as.numeric", "as.Date", "which.max", "which.min", "unique", "sort", "order", "nrow", "ncol",
                 "names", "[", "[[", "$", "(", "{", "<-", "=", "if", "function",
                 "ceiling", "floor", "pmin", "pmax", "cumsum", "diff", "is.numeric", "as.integer", "nlevels", "any", "all", "which", "isTRUE")
# head() and tail() are utils' and median() is stats', not base R's.
DESIGN_UTILS <- c("head", "tail")
DESIGN_STATS <- "median"
# The base names that are syntax of the language, not functions a design may call by name: the guard handles them itself.
DESIGN_SYNTAX <- c("<-", "=", "function", "(", "{", "if", "$", "[", "[[", "~")

# What the replacement forms of assignment need to find in the environment (x$a <- 1 calls `$<-`): there, never callable by name (the guard refuses a call).
DESIGN_REPLACE <- c("$<-", "[<-", "[[<-")

# Arguments that hold a function, and the strings they may be given (a string becomes a function through match.fun() or rlang::as_function(), and in
#   ggplot2's namespace that finds any function of base R).
DESIGN_FUN_ARGS <- c("fun", "fun.data", "fun.y", "fun.x", "fun.min", "fun.max", "fun.ymin", "fun.ymax", "fun.xmin", "fun.xmax", ".fun", "labeller", "key_glyph",
                     "oob", "rescaler", "FUN", "connection")
DESIGN_METHODS <- c("lm", "loess", "glm", "gam", "auto")
DESIGN_TRANSFORMS <- c("identity", "log10", "log", "log2", "sqrt", "reverse", "reciprocal", "exp", "log1p")

# The arguments whose value ggplot2 or forcats may turn into code: a string becomes a function through match.fun() or rlang::as_function(), which look in
#   ggplot2's namespace and find all of base R; a facet given as a string is parsed and evaluated. design_screened() wraps every toolkit function that has one
#   and stops a value that is not a function (or a string naming a toolkit function), a method of the short list, a transformation of the short list, or
#   a facet that is anything but a column name, or a number of bins or points above DESIGN_COUNT_MAX, or a size above DESIGN_MAGNITUDE_MAX: so a string the code builds (paste0("sys", "tem(...)")) is stopped too, not only a literal one.
DESIGN_RISKY <- list(fun = c("fun", "fun.data", "fun.y", "fun.x", "fun.min", "fun.max", "fun.ymin", "fun.ymax", "fun.xmin", "fun.xmax", ".fun", "labeller", "connection", "FUN"),
                     method = "method", transform = c("transform", "trans"), facet = c("facets", "rows", "cols"), count = c("bins", "n", "n.breaks"),
                     magnitude = c("size", "base_size", "linewidth", "stroke", "range"))
DESIGN_COUNT_MAX <- 10000    # the most bins, grid points or breaks a chart is given
DESIGN_MAGNITUDE_MAX <- 300  # the largest size (points, millimetres) of a mark, a line or a text: a glyph or a circle of 100,000 is a bitmap of that many pixels

# The functions that are given text or a number for how much to make, with the largest value each argument may take.
DESIGN_SIZES <- list(format = c(width = 200, nsmall = 20, digits = 22), formatC = c(width = 200, digits = 22))

# The geoms that are marks (they must plot every row of d unless a filter() is in the code) and the stat layers' kin; every other geom is a label, a
#   rule, a leader or a helper and may have DESIGN_ROW_EXTRA rows more than d.
DESIGN_MARK_GEOMS <- c("GeomPoint", "GeomCol", "GeomBar", "GeomLine", "GeomPath", "GeomArea", "GeomRibbon", "GeomTile", "GeomRaster", "GeomBoxplot",
                       "GeomViolin", "GeomPolygon", "GeomStep", "GeomErrorbar", "GeomLinerange", "GeomPointrange", "GeomCrossbar", "GeomSmooth",
                       "GeomDensity", "GeomHex", "GeomBin2d", "GeomDotplot")
DESIGN_TEXT_GEOMS <- c("GeomText", "GeomLabel", "GeomTextRepel", "GeomLabelRepel", "GeomRichtext")
DESIGN_FILL_GEOMS <- c("GeomCol", "GeomBar", "GeomTile", "GeomRect", "GeomArea", "GeomRibbon", "GeomBoxplot", "GeomViolin", "GeomPolygon", "GeomRaster",
                       "GeomHex", "GeomBin2d", "GeomCrossbar")

# Markup the ggtext functions would render: an image or a link reads a file (or a address), a tag can carry a style. A text that has any is refused
#   before the drawing is made, wherever it comes from (a label, a column's value, a scale's labels).
DESIGN_MARKUP <- "(?i)<\\s*/?\\s*(img|a|link|script|iframe|style|svg|object|embed|image|use|foreignObject|base|meta|form|input)\\b|\\bsrc\\s*=|\\bhref\\s*=|url\\s*\\(|!\\[[^]]*\\]\\("

.design_cache <- new.env(parent = emptyenv())

# The functions a design may call, as a named list of functions (built once, from the installed packages): ggplot2's typed list, scales', the other
#   packages' when installed, and base R's. The size-limited versions of c(), paste(), paste0(), rep(), seq(), seq_len(), `:`, format() and formatC()
#   stand in for the base ones. Attribute "package" says where each name came from.
# The functions whose arguments are evaluated in a data mask (ggplot2's aesthetics, dplyr's verbs): a bare name in them is a variable of the data.
DESIGN_MASKED <- c("aes", "after_stat", "after_scale", "stage", "vars", "mutate", "filter", "arrange", "group_by", "summarise", "slice_max", "slice_min")

design_toolkit <- function() {
  if (!is.null(.design_cache$toolkit)) return(.design_cache$toolkit)
  from = function(pkg, names) {
    base = identical(pkg, "base")
    if (!base && !length(find.package(pkg, quiet = TRUE))) return(list())
    ok = if (base) names[purrr::map_lgl(names, exists, envir = baseenv(), inherits = FALSE)] else names[names %in% getNamespaceExports(pkg)]
    stats::setNames(purrr::map(ok, function(n) if (base) get(n, envir = baseenv()) else getExportedValue(pkg, n)), ok)
  }
  sets = c(list(ggplot2 = DESIGN_GGPLOT2, scales = DESIGN_SCALES, base = DESIGN_BASE, utils = DESIGN_UTILS, stats = DESIGN_STATS), DESIGN_OTHER)
  parts = purrr::imap(sets, function(names, pkg) from(pkg, names))
  fns = unlist(unname(parts), recursive = FALSE)
  fns = fns[!duplicated(names(fns))]           # alpha is in ggplot2 and in scales: the first one stays
  pkgs = stats::setNames(rep(names(parts), lengths(parts)), unlist(purrr::map(parts, names)))[names(fns)]
  fns = design_screened(utils::modifyList(fns, design_limited()))
  attr(fns, "package") = pkgs
  .design_cache$toolkit = fns
  fns
}

# The size-limited stand-ins: each refuses (with an error the run turns into a refusal) a result longer than DESIGN_MAX_LEN, or a width past the
#   limits of DESIGN_SIZES. rep(), seq(), seq_len() and `:` work the size out first, since the harm is in making the vector.
design_limited <- function() {
  too_big = function() stop("The code makes a vector longer than ", format(DESIGN_MAX_LEN, big.mark = ",", scientific = FALSE), " or text longer than ",
                            format(DESIGN_MAX_CHARS, big.mark = ",", scientific = FALSE), " characters.", call. = FALSE)
  after = function(f) function(...) {
    r = f(...)
    if (length(r) > DESIGN_MAX_LEN || (is.character(r) && sum(nchar(r, keepNA = FALSE)) > DESIGN_MAX_CHARS)) too_big()
    r
  }
  num = function(x) suppressWarnings(as.numeric(x))
  guard_args = function(f, name) function(...) {
    a = list(...)
    over = purrr::imap_lgl(DESIGN_SIZES[[name]], function(limit, arg) !is.null(a[[arg]]) && isTRUE(any(num(a[[arg]]) > limit)))
    if (any(over)) stop("The code asks ", name, "() for a ", paste(names(over)[over], collapse = " and "), " that is too large.", call. = FALSE)
    f(...)
  }
  list(c = after(base::c), paste = after(base::paste), paste0 = after(base::paste0),
       rep = function(x, ...) {
         a = list(...)
         each = if (!is.null(a$each)) num(a$each) else 1
         times = if (!is.null(a$times)) a$times else if (length(a) && (is.null(names(a)) || !nzchar(names(a)[1]))) a[[1]] else 1
         n = if (!is.null(a$length.out)) num(a$length.out) else length(x) * each * (if (length(times) > 1L) sum(num(times)) / length(x) else num(times))
         if (isTRUE(n > DESIGN_MAX_LEN)) too_big()
         base::rep(x, ...)
       },
       seq = function(...) {
         cl = tryCatch(match.call(base::seq.default, as.call(c(list(quote(seq.default)), list(...)))), error = function(e) NULL)
         a = if (!is.null(cl)) as.list(cl)[-1] else list()
         n = tryCatch(suppressWarnings(
           if (!is.null(a$length.out)) num(a$length.out)
           else if (!is.null(a$from) && !is.null(a$to) && !is.null(a$by)) abs(num(a$to) - num(a$from)) / abs(num(a$by)) + 1
           else if (!is.null(a$from) && !is.null(a$to)) abs(num(a$to) - num(a$from)) + 1
           else if (length(a$from) == 1L && is.null(a$to) && is.numeric(a$from)) a$from
           else 0), error = function(e) 0)
         if (isTRUE(suppressWarnings(max(c(n, 0), na.rm = TRUE)) > DESIGN_MAX_LEN)) too_big()
         base::seq(...)
       },
       seq_len = function(length.out) {
         if (isTRUE(num(length.out) > DESIGN_MAX_LEN)) too_big()
         base::seq_len(length.out)
       },
       `:` = function(from, to) {
         if (isTRUE(abs(num(to) - num(from)) + 1 > DESIGN_MAX_LEN)) too_big()
         base::`:`(from, to)
       },
       format = after(guard_args(base::format, "format")), formatC = after(guard_args(base::formatC, "formatC")))
}

# The replacement forms a design's `x[i] <- v`, `x[[i]] <- v` and `x$a <- v` use: a numeric index past DESIGN_MAX_LEN is refused before R makes the
#   vector that long (`x[9999 * 99999] <- 1` would make 8 GB), and so is a result longer than that. (`x$a <- v` adds at most one element and keeps
#   base R's form.)
design_replace <- function() {
  too_big = function() stop("The code makes a vector longer than ", format(DESIGN_MAX_LEN, big.mark = ",", scientific = FALSE), " or text longer than ",
                            format(DESIGN_MAX_CHARS, big.mark = ",", scientific = FALSE), " characters.", call. = FALSE)
  far = function(i) is.numeric(i) && length(i) && isTRUE(suppressWarnings(max(abs(i), na.rm = TRUE)) > DESIGN_MAX_LEN)
  index = function(...) tryCatch(list(...), error = function(e) list())   # x[] <- v and x[i, ] <- v have empty indices
  done = function(r) if (length(r) > DESIGN_MAX_LEN) too_big() else r
  list(`[<-` = function(x, ..., value) { if (any(purrr::map_lgl(index(...), far))) too_big(); done(base::`[<-`(x, ..., value = value)) },
       `[[<-` = function(x, ..., value) { if (any(purrr::map_lgl(index(...), far))) too_big(); done(base::`[[<-`(x, ..., value = value)) })
}

# ggtext draws markup through gridtext, whose <img> tag reads a picture from a file or a web address. A design's text can be computed while the plot is
#   built (an aesthetic, a scale's labels function), after any check of the plot's strings, so gridtext's image reader is replaced, for the rest of the
#   process, by one that refuses: the app itself draws no pictures in its texts. Called by design_run() before a design is evaluated.
design_block_images <- function() {
  if (isTRUE(.design_cache$images_blocked) || !length(find.package("gridtext", quiet = TRUE))) return(invisible(FALSE))
  utils::assignInNamespace("read_image", function(path, ...) {
    .design_cache$image_hit = TRUE
    stop("A text has HTML or image markup in it; texts on a chart are plain words.", call. = FALSE)
  }, ns = "gridtext")
  .design_cache$images_blocked = TRUE
  invisible(TRUE)
}

# Every toolkit function with an argument of DESIGN_RISKY made to check that argument's value first (matched by name, positional arguments too) and then
#   call the function with the same arguments. coord_trans() and coord_transform() take their transformations as x and y.
design_screened <- function(fns) {
  risky = unlist(DESIGN_RISKY, use.names = FALSE)
  kind = stats::setNames(rep(names(DESIGN_RISKY), lengths(DESIGN_RISKY)), risky)
  callable = names(fns)
  word = function(v) paste0("\"", utils::head(v, 1), "\"")
  screen = function(f, name) {
    force(f)
    function(...) {
      a = list(...)
      cl = tryCatch(match.call(f, as.call(c(list(quote(f)), a))), error = function(e) NULL)
      m = if (!is.null(cl)) as.list(cl)[-1] else a
      coord = name %in% c("coord_trans", "coord_transform")
      kinds = ifelse(names(m) %in% risky, kind[names(m)], ifelse(coord & names(m) %in% c("x", "y"), "transform", NA_character_))
      bad = purrr::map2_chr(m, kinds, function(v, k) {
        if (is.na(k)) return(NA_character_)
        switch(k,
          fun = if (is.null(v) || is.function(v) || (is.character(v) && all(v %in% callable))) NA_character_ else paste0("A string given where a function is expected (", word(v), ") must name a toolkit function; give the function itself."),
          method = if (is.null(v) || is.function(v) || (is.character(v) && all(v %in% DESIGN_METHODS))) NA_character_ else paste0("The method ", word(v), " is not one of ", paste(DESIGN_METHODS, collapse = ", "), "."),
          transform = if (is.null(v) || !is.character(v) || all(v %in% DESIGN_TRANSFORMS)) NA_character_ else paste0("The transformation ", word(v), " is not one of ", paste(DESIGN_TRANSFORMS, collapse = ", "), "."),
          facet = if (!is.character(v) || all(grepl("^[A-Za-z.][A-Za-z0-9._]*$", v))) NA_character_ else paste0("A facet given as a string must be a column name, not ", word(v[!grepl("^[A-Za-z.][A-Za-z0-9._]*$", v)]), "."),
          count = if (!is.numeric(v) || all(v <= DESIGN_COUNT_MAX, na.rm = TRUE)) NA_character_ else paste0("A count of ", format(max(v, na.rm = TRUE), big.mark = ",", scientific = FALSE), " bins or points is more than a chart needs (at most ", format(DESIGN_COUNT_MAX, big.mark = ","), ")."),
          magnitude = if (!is.numeric(v) || inherits(v, "rel") || all(abs(v) <= DESIGN_MAGNITUDE_MAX, na.rm = TRUE)) NA_character_ else paste0("A size of ", format(max(abs(v), na.rm = TRUE), big.mark = ",", scientific = FALSE), " is larger than a chart needs (at most ", DESIGN_MAGNITUDE_MAX, ")."),
          NA_character_)
      })
      if (any(!is.na(bad))) stop(bad[!is.na(bad)][[1]], call. = FALSE)
      do.call(f, a)
    }
  }
  # a layer function takes its statistic's arguments (fun, n, bins) in `...`; the dots of aes(), vars(), mutate() and the like are quoted, not evaluated, and
  #   must be left alone
  # (dplyr's verbs quote their arguments, whatever they are called: slice_max(d, revenue, n = 3) has an `n`, and `revenue` is a column)
  hit = purrr::keep(setdiff(names(fns), DESIGN_OTHER$dplyr), function(n) is.function(fns[[n]]) && !is.primitive(fns[[n]]) &&
                      (any(names(formals(fns[[n]])) %in% risky) || n %in% c("coord_trans", "coord_transform") ||
                         (grepl("^(geom|stat)_", n) && "..." %in% names(formals(fns[[n]])))))
  utils::modifyList(fns, stats::setNames(purrr::map(hit, function(n) screen(fns[[n]], n)), hit))
}

# The toolkit as the model is told it: one line a package, the names in order (the `|>` pipe is syntax and listed with the base names).
design_toolkit_text <- function() {
  tk = design_toolkit()
  pk = attr(tk, "package")
  by = split(names(tk), factor(pk[names(tk)], levels = unique(pk[names(tk)])))
  paste(c(purrr::imap_chr(by, function(n, p) paste0(p, ": ", paste(if (identical(p, "base")) c(n, "|>") else n, collapse = " "))),
          "provided objects: d (the table), facts, txt, tok, and the function pal(n)"), collapse = "\n")
}

# What a name on the deny list is refused for, as one sentence; NULL for a name not on it.
design_deny_reason <- function(name) {
  hit = purrr::detect(names(DESIGN_DENY), function(k) name %in% DESIGN_DENY[[k]])
  if (is.null(hit)) return(NULL)
  paste0("`", name, "` is never allowed in a design: it ", DESIGN_DENY_WHY[[hit]], ".")
}

# ---- the guard ----------------------------------------------------------------------------------------------------------------

# The names the code assigns (with <- or =, to a plain name) and the parameters of its own functions: a list of list(name, fun, formal) over the
#   whole tree; `fun` says the assigned value is a function written in the code.
design_collect <- function(e) {
  if (!is.call(e)) return(list())
  head = if (is.symbol(e[[1]])) as.character(e[[1]]) else ""
  here = if (head %in% c("<-", "=") && length(e) == 3L && is.symbol(e[[2]]))
    list(list(name = as.character(e[[2]]), fun = is.call(e[[3]]) && identical(e[[3]][[1]], as.name("function")), formal = FALSE))
  else if (identical(head, "function") && length(e) >= 2L && !is.null(e[[2]]))
    purrr::map(names(e[[2]]), function(n) list(name = n, fun = FALSE, formal = TRUE))
  else list()
  c(here, unlist(purrr::map(design_args(e, all = TRUE), design_collect), recursive = FALSE))
}

# The elements of a call that are there (an empty argument, as in x[1, ], is not), the function position left out unless `all`. A function's
#   formals are a pairlist: their defaults are in it.
design_args <- function(e, all = FALSE) {
  l = as.list(e)
  idx = seq_along(l)
  if (!all && !is.pairlist(e)) idx = idx[-1]
  keep = idx[!purrr::map_lgl(idx, function(i) identical(l[[i]], quote(expr = )))]
  purrr::map(keep, function(i) l[[i]])
}

# The first problem a syntax tree has, as a sentence, or character(0). `cx`: callable (the toolkit's names and pal), provided, cols, plain (the names
#   the code assigns and its parameters), funs (the names assigned only function literals), dots (a function of the code takes ...).
design_walk <- function(e, cx, depth = 0L) {
  if (depth > DESIGN_MAX_DEPTH) return("The code is nested too deeply.")
  next_ = function(x) design_walk(x, cx, depth + 1L)
  all_of = function(xs) unlist(purrr::map(xs, next_))
  if (is.symbol(e)) return(design_symbol(as.character(e), cx))
  if (!is.call(e)) return(design_constant(e))
  fn = e[[1]]
  if (is.call(fn)) {
    op = if (is.symbol(fn[[1]])) as.character(fn[[1]]) else ""
    why = switch(op,
      `::` = , `:::` = "`::` and `:::` are not allowed: a design uses only the functions of the toolkit, by their plain names.",
      `@` = "`@` is not allowed: a design does not look inside objects.",
      "A function must be called by its plain name: calls such as `(f)()`, `f()()`, `x$f()` and `x[[\"f\"]]()` are not allowed.")
    return(why)
  }
  if (!is.symbol(fn)) return("A function must be called by its plain name.")
  name = as.character(fn)
  deny = design_deny_reason(name)
  if (!is.null(deny)) return(deny)
  rest = design_args(e)
  switch(name,
    `::` = , `:::` = "`::` and `:::` are not allowed: a design uses only the functions of the toolkit, by their plain names.",
    `@` = "`@` is not allowed: a design does not look inside objects.",
    `<<-` = , `->>` = "`<<-` is not allowed: a design assigns only to its own variables, with `<-` or `=`.",
    `function` = design_function(e, cx, depth),
    `<-` = , `=` = design_assign(e, cx, depth),
    `~` = {
      # the symbols of a formula (`y ~ x`, `~ region`, `. ~ g`) are variables of the layer's data or of its aesthetics, found when the plot is built; a call
      #   inside it is checked like any other
      cx_f = utils::modifyList(cx, list(formula = TRUE))
      unlist(purrr::map(rest, function(x) design_walk(x, cx_f, depth + 1L)))
    },
    `$` = if (length(e) != 3L || !(is.symbol(e[[3]]) || is.character(e[[3]]))) "`$` takes a plain name after it." else next_(e[[2]]),
    {
      if (!(name %in% cx$callable || name %in% cx$funs))
        return(paste0("`", name, "` is not in the toolkit, so the code may not call it; use only the functions listed in TOOLKIT."))
      here = design_string_args(e, name, cx)
      if (length(here)) return(here)
      # inside aes(), after_stat() and the like, and in dplyr's verbs, a bare name is a variable of the data (a column mutate() made, a statistic's
      #   `count`), found in a data mask whose parent is the design's own environment, so it is allowed as in a formula unless it is on the deny list
      if (name %in% DESIGN_MASKED) return(unlist(purrr::map(rest, function(x) design_walk(x, utils::modifyList(cx, list(formula = TRUE)), depth + 1L))))
      all_of(rest)
    })
}

# A symbol used as a value: a provided object, a toolkit function, a column of d, or a variable the code made.
design_symbol <- function(name, cx) {
  if (!nzchar(name)) return(character(0))
  # a column of d, or a variable of the code's own, is a value even when its name is also on the deny list (a column called `date`, `source` or `file`);
  #   calling it is another matter (design_walk() refuses a call to a deny-listed name first)
  mine = name %in% c(cx$cols, cx$plain) || (isTRUE(cx$formula) && is.null(design_deny_reason(name)))
  deny = if (!mine) design_deny_reason(name)
  if (!is.null(deny)) return(deny)
  ok = mine || name %in% c(cx$provided, cx$callable, names(DESIGN_CONSTANTS), ".data") || (identical(name, "...") && isTRUE(cx$dots))
  if (ok) character(0) else paste0("`", name, "` is not a column of d, a provided object, a toolkit function or a variable the code made.")
}

design_constant <- function(e) {
  if (is.numeric(e) && any(abs(e) >= DESIGN_MAX_NUM, na.rm = TRUE)) return(paste0("The number ", format(max(abs(e)), scientific = FALSE), " is too large for a design to need."))
  character(0)
}

# `function(...) body`: the defaults and the body are walked like the rest, and a function may not call itself.
design_function <- function(e, cx, depth) {
  defaults = if (length(e) >= 2L && !is.null(e[[2]])) design_args(e[[2]], all = TRUE) else list()
  body = if (length(e) >= 3L) list(e[[3]]) else list()
  unlist(purrr::map(c(defaults, body), function(x) design_walk(x, cx, depth + 1L)))
}

# `target <- value`: the target is a plain name that is not the toolkit's or a provided object, or an element ($, [, [[) of a variable the code made;
#   the value is walked.
design_assign <- function(e, cx, depth) {
  if (length(e) != 3L) return("An assignment needs a name and a value.")
  target = e[[2]]
  value = design_walk(e[[3]], cx, depth + 1L)
  # What may not be assigned to: what is provided, the constants, base R's operators and functions, and any toolkit name that the code would make into a
  #   function of its own (a redefinition of ggplot() or c()). A toolkit name given a plain value (`last <- filter(d, ...)`, a dplyr function and a
  #   natural name) only hides the function from the code itself.
  fn_value = is.call(e[[3]]) && identical(e[[3]][[1]], as.name("function"))
  reserved = c(cx$provided, names(DESIGN_CONSTANTS), DESIGN_BASE, if (fn_value) cx$callable)
  why = if (is.symbol(target)) {
    nm = as.character(target)
    if (nm %in% reserved) paste0("`", nm, "` belongs to the toolkit or to what is provided, so the code may not assign to it; use a name of your own.")
    else design_deny_reason(nm)
  } else if (is.call(target) && is.symbol(target[[1]]) && as.character(target[[1]]) %in% c("$", "[", "[[")) design_assign_element(target, cx, depth)
  else "Only a variable, or an element of a variable the code made (`x$a <- 1`, `x[1] <- 1`), may be assigned to; `names(x) <- ...`, `attr(x, ...) <- ...` and the like are not allowed."
  c(why, value)
}

# `x$a`, `x[i]`, `x[[i]]` as the target of an assignment: x (through any depth of elements) must be a variable the code made, not d, facts, txt, tok.
design_assign_element <- function(target, cx, depth) {
  root = function(t) if (is.call(t) && is.symbol(t[[1]]) && as.character(t[[1]]) %in% c("$", "[", "[[")) root(t[[2]]) else t
  r = root(target)
  if (!is.symbol(r)) return("Only an element of a variable the code made may be assigned to.")
  nm = as.character(r)
  if (nm %in% cx$provided) return(paste0("`", nm, "` is provided to be read: the code may not change it (make a variable of your own, or use mutate())."))
  if (!(nm %in% cx$plain)) return(paste0("`", nm, "` is not a variable the code made, so the code may not assign to an element of it."))
  index = if (identical(as.character(target[[1]]), "$")) character(0) else unlist(purrr::map(design_args(target)[-1], function(x) design_walk(x, cx, depth + 1L)))
  inner = if (is.call(target[[2]])) design_assign_element(target[[2]], cx, depth) else character(0)
  c(index, inner)
}

# A string given where a function is expected is turned into one by match.fun() or as_function(), which look in ggplot2's namespace and so find
#   all of base R: it must name a toolkit function, or for `method` and `transform` one of the short lists. In facet_wrap() and facet_grid() a
#   string is a column name and may be nothing else.
design_string_args <- function(e, name, cx) {
  args = as.list(e)[-1]
  nms = names(args) %||% rep("", length(args))
  present = !purrr::map_lgl(seq_along(args), function(i) identical(args[[i]], quote(expr = )))
  args = args[present]
  nms = nms[present]
  is_chr = purrr::map_lgl(args, function(a) is.character(a) && length(a) == 1L)
  txt = purrr::map_chr(args, function(a) if (is.character(a) && length(a) == 1L) a else NA_character_)
  bad = purrr::pmap_chr(list(nms, txt, is_chr), function(n, s, ok) {
    if (!ok) return(NA_character_)
    if (n %in% DESIGN_FUN_ARGS && !(s %in% cx$callable)) return(paste0("The string \"", s, "\" given as `", n, "` would be turned into a function; give a function of the toolkit, not a string."))
    if (n == "method" && !(s %in% DESIGN_METHODS)) return(paste0("The string \"", s, "\" given as `method` is not one of ", paste(DESIGN_METHODS, collapse = ", "), "."))
    if (n %in% c("transform", "trans") && !(s %in% DESIGN_TRANSFORMS)) return(paste0("The string \"", s, "\" given as `", n, "` is not one of ", paste(DESIGN_TRANSFORMS, collapse = ", "), "."))
    if (name %in% c("facet_wrap", "facet_grid") && !grepl("^[A-Za-z.][A-Za-z0-9._]*$", s)) return(paste0("A string in ", name, "() must be a column name, not \"", s, "\"."))
    NA_character_
  })
  parse_arg = isTRUE(any(nms == "parse" & purrr::map_lgl(args, function(a) !identical(a, FALSE))))
  found = c(bad[!is.na(bad)], if (parse_arg) "`parse` is not allowed: text is drawn as it is, not read as a formula.")
  if (length(found)) found[[1]]
}

# Whether any function of the code that is defined in terms of the others calls back into itself (directly, or through the others).
design_cycle <- function(exprs, funs) {
  defs = unlist(purrr::map(as.list(exprs), function(e) design_defs(e)), recursive = FALSE)
  refs = purrr::map(defs, function(b) intersect(all.names(b), funs))
  reach = purrr::reduce(seq_along(funs), function(acc, i) purrr::map(acc, function(r) unique(c(r, unlist(acc[intersect(r, names(acc))])))), .init = refs)
  hit = purrr::keep(names(reach), function(n) n %in% reach[[n]])
  if (length(hit)) hit[[1]]
}

# The function literals the code assigns to a name, by name: list(f = function(...) body, ...) as expressions.
design_defs <- function(e) {
  if (!is.call(e)) return(list())
  here = if (is.symbol(e[[1]]) && as.character(e[[1]]) %in% c("<-", "=") && length(e) == 3L && is.symbol(e[[2]]) && is.call(e[[3]]) && identical(e[[3]][[1]], as.name("function")))
    stats::setNames(list(e[[3]]), as.character(e[[2]]))
  else list()
  c(here, unlist(purrr::map(design_args(e, all = TRUE), design_defs), recursive = FALSE))
}

# The guard. `code`: the model's text; `cols`: the names of d's columns. Returns list(ok, reason, exprs): reason is one plain sentence when not ok.
design_guard <- function(code, cols = character(0)) {
  fail = function(why) list(ok = FALSE, reason = why, exprs = NULL)
  if (!is.character(code) || length(code) != 1L || is.na(code) || !nzchar(trimws(code))) return(fail("The design has no code."))
  if (nchar(code, type = "chars") > DESIGN_MAX_CODE)
    return(fail(paste0("The code is ", format(nchar(code, type = "chars"), big.mark = ","), " characters; at most ", format(DESIGN_MAX_CODE, big.mark = ","), " are allowed.")))
  exprs = tryCatch(parse(text = code, keep.source = FALSE), error = function(e) e)
  if (inherits(exprs, "error")) return(fail(paste0("The code does not parse: ", trimws(sub("\n.*", "", sub("^<text>:", "line ", conditionMessage(exprs)))), ".")))
  if (!length(exprs)) return(fail("The design has no code."))
  records = unlist(purrr::map(as.list(exprs), design_collect), recursive = FALSE)
  rec_names = purrr::map_chr(records, "name")
  assigned = records[!purrr::map_lgl(records, "formal")]
  funs = unique(purrr::keep(purrr::map_chr(assigned, "name"), function(n) all(purrr::map_lgl(assigned[purrr::map_chr(assigned, "name") == n], "fun"))))
  cx = list(callable = c(names(design_toolkit()), "pal"), provided = DESIGN_PROVIDED, cols = cols, plain = unique(rec_names), funs = funs,
            dots = "..." %in% rec_names)
  why = unlist(purrr::map(as.list(exprs), function(e) design_walk(e, cx)))
  loop = if (!length(why) && length(funs)) design_cycle(exprs, funs)
  if (!length(why) && !is.null(loop)) why = paste0("The function `", loop, "` calls itself (directly or through another function of the code); recursion is not available.")
  if (length(why)) fail(why[[1]]) else list(ok = TRUE, reason = NA_character_, exprs = exprs)
}


# ---- what the design is given: tok, pal, txt and facts -------------------------------------------------------------------------

# The chosen style's values as a plain list: ground (the plot's fill), panel, text, muted (axis text, subtitle), accent, slate, grid, caption (the caption's
#   colour), title_family, body_family (a family the machine can draw: the bundled one when registered, else the default), title_face ("bold" or
#   "plain": a semibold family has its weight in its name) and base_size.
design_tokens <- function(style = CHART_STYLE_DEFAULT) {
  st = if (is.list(style)) style else chart_style(style)
  semi = identical(st$title_weight, "semibold")
  list(ground = st$background, panel = st$panel, text = st$text, muted = st$text_2, accent = st$accent, slate = st$slate, grid = st$grid, caption = st$caption,
       title_family = chart_font_family(st$title_font, if (semi) "semibold" else "regular"), title_face = if (semi) "plain" else st$title_weight %||% "bold",
       body_family = chart_font_family("sans"), base_size = 12)
}

# pal(n): the first n colours of the chosen qualitative palette, as the chart would draw n groups (an error with a sentence past the palette's number).
design_pal <- function(palette = chart_palette_default()) {
  qual = spec_palette(palette)$qual
  function(n) {
    n = suppressWarnings(as.integer(n))
    if (length(n) != 1L || is.na(n) || n < 1L) stop("pal(n) takes a whole number of colours, 1 or more.", call. = FALSE)
    qual(n)
  }
}

# The spec's words after the app's own rules: the title without its trailing full stop and in upper case where the style says so, the subtitle and
#   caption as written, the axis titles the chart would draw (the spec's, else the dictionary's). A missing text is NULL.
design_text <- function(spec, style = CHART_STYLE_DEFAULT, cb = NULL) {
  s = spec_defaults(spec_public(spec))
  fam = s$family
  x = s$x_label %||% if (!is.null(cb) && is_text1(s$x)) col_title(cb, s$x)
  y = s$y_label %||% if (!is.null(cb)) if (fam %in% c("box", "scatter", "bubble", "heatmap") && is_text1(s$y)) col_title(cb, s$y) else value_label(s, cb, title = TRUE)
  list(title = if (is_text1(s$title)) chart_title_case(chart_heading_text(s$title), style), subtitle = if (is_text1(s$subtitle)) s$subtitle,
       caption = if (is_text1(s$caption)) s$caption, x = x, y = y)
}

# The facts of a chart as a named list, one entry for each line of spec_facts()'s text that has a label: list(text = the line as written (the values of id
#   and text columns are tokens, [[N1]]), label = what stands before the first colon, number = the numbers written in the rest of the line, as R
#   values (a numeric vector, empty when there is none)). The name is the label in lower case with its non-letters made underscores, made unique
#   ("highest", "lowest", "west"). A line of a panel's facts is indented in spec_facts(); here it is an entry of its own, with the panel's line before it.
design_facts <- function(spec, table, cb, data = NULL) {
  txt = spec_facts(spec, table, cb, data = data)$text
  lines = trimws(strsplit(txt, "\n", fixed = TRUE)[[1]])
  lines = lines[nzchar(lines)]
  label = sub("^-\\s*", "", sub(":.*$", "", lines))
  value = ifelse(grepl(":", lines, fixed = TRUE), trimws(sub("^[^:]*:", "", lines)), "")
  number = purrr::map(value, function(v) if (nzchar(v)) purrr::map_dbl(text_numbers(v), "value") else numeric(0))
  plain = suppressWarnings(iconv(label, "UTF-8", "ASCII//TRANSLIT", sub = ""))
  key = gsub("^_+|_+$", "", gsub("[^a-z0-9]+", "_", tolower(ifelse(is.na(plain), label, plain))))
  key[!nzchar(key)] = "fact"
  stats::setNames(purrr::pmap(list(lines, label, number), function(t, l, n) list(text = t, label = l, number = n)), make.unique(key, sep = "_"))
}

# Every fact's line as one text (what check_numbers() reads), and the facts as a model is shown them.
design_facts_text <- function(facts) {
  if (is.character(facts)) return(paste(facts, collapse = "\n"))
  paste(purrr::map_chr(facts, function(f) if (is.list(f)) f$text %||% "" else as.character(f)), collapse = "\n")
}

# ---- running the code -----------------------------------------------------------------------------------------------------------

# R's own dispatch of an operator (`+` on a ggplot) evaluates `base::chooseOpsMethod(...)` in the environment of the call, so a design's environment must
#   find `::`. This one finds that single function and nothing else (the guard refuses `::` in a design anyway; this is for the run, if the guard were wrong).
design_ns_get <- function(pkg, name) {
  p = as.character(substitute(pkg))
  n = as.character(substitute(name))
  if (identical(p, "base") && identical(n, "chooseOpsMethod")) base::chooseOpsMethod else stop("`::` is not available in a design.", call. = FALSE)
}

# The environment a design is evaluated in: its parent is emptyenv(), so a name the guard missed does not resolve, and it holds the toolkit, the
#   replacement forms the language needs for `x$a <- 1`, a few constants, a `::` that finds one base function (design_ns_get()), and the five provided
#   objects.
design_env <- function(objects, toolkit = design_toolkit()) {
  e = new.env(parent = emptyenv())
  list2env(toolkit, envir = e)
  list2env(stats::setNames(purrr::map(DESIGN_REPLACE, get, envir = baseenv()), DESIGN_REPLACE), envir = e)
  list2env(design_replace(), envir = e)
  list2env(DESIGN_CONSTANTS, envir = e)
  list2env(list(`::` = design_ns_get), envir = e)
  list2env(objects, envir = e)
  e
}

# One line of an error: no colour codes, no line breaks, at most 220 characters.
design_message <- function(cond) {
  m = gsub("\033\\[[0-9;]*m", "", conditionMessage(cond))
  m = trimws(gsub("\\s+", " ", m))
  if (nchar(m) > 220L) paste0(substr(m, 1, 217L), "...") else m
}

# The strings a plot carries that could be markup (its labels, the character columns of its data and of each layer's, a scale's labels and name):
#   a text with an image, a link or a tag in it is refused before anything is drawn, since ggtext renders HTML (an image tag reads a file).
design_markup_faults <- function(plot) {
  chr = function(x) if (is.character(x)) x else if (is.factor(x)) as.character(x)
  cols = function(df) if (is.data.frame(df)) unlist(purrr::map(df, chr), use.names = FALSE)
  layer_data = purrr::map(plot$layers, function(l) tryCatch(l$layer_data(plot$data), error = function(e) NULL))
  scales = purrr::map(plot$scales$scales, function(s) c(chr(s$name), if (is.character(s$labels)) s$labels))
  strings = unique(unlist(c(purrr::map(plot$labels, chr), list(cols(plot$data)), purrr::map(layer_data, cols), scales), use.names = FALSE))
  strings = strings[!is.na(strings)]
  hit = strings[grepl(DESIGN_MARKUP, strings, perl = TRUE)]
  if (length(hit)) paste0("A text has HTML or image markup in it (\"", substr(hit[[1]], 1, 40), "\"); texts on a chart are plain words.")
}

# Draws a plot to `file` through chart_device() (never png() or pdf()) and closes only the device it opened, whatever happens.
design_draw <- function(plot, file, size, dpi) {
  chart_device(file, size[["width"]], size[["height"]], dpi)
  dev = grDevices::dev.cur()
  on.exit(grDevices::dev.off(dev))
  print(plot)
  invisible(file)
}

# The table as a design is given it: a plain data frame, with only the attributes of one (names, row names, class) and no list columns: what readr
#   and spec_table() hang on it (the column spec, the problems, the counts) is not the design's to read.
design_table <- function(table) {
  t = as.data.frame(table, stringsAsFactors = FALSE)
  attributes(t)[setdiff(names(attributes(t)), c("names", "row.names", "class"))] = NULL
  t
}

# Runs a design. The code is guarded first; it is evaluated in design_env() (the toolkit and d, facts, txt, tok, pal and nothing else) under a time
#   limit that covers evaluating, building and drawing, and reset afterwards whatever happens; the warnings are caught; the result must be a ggplot or a
#   patchwork; and it is drawn once, through chart_device(), at `size` inches (so a fault in drawing is found here, and the picture exists).
#   Returns list(ok, reason, plot, built, warnings, file, seconds): `reason` is one sentence when not ok; `file` is the picture (a path made for this
#   call, removed unless `keep`); `built` is ggplot_build() of the plot.
design_run <- function(code, d, facts, txt, tok, pal, size = SPEC_SIZE[c("width", "height")], limit = DESIGN_TIME_LIMIT, dpi = 120, keep = FALSE) {
  said = character(0)
  out = function(ok, why = NA_character_, plot = NULL, built = NULL, file = NULL)
    list(ok = ok, reason = why, plot = plot, built = built, warnings = unique(said), file = file, seconds = as.numeric(difftime(Sys.time(), t0, units = "secs")))
  t0 = Sys.time()
  d = design_table(d)
  g = design_guard(code, names(d))
  if (!g$ok) return(out(FALSE, g$reason))
  env = design_env(list(d = d, facts = facts, txt = txt, tok = tok, pal = pal))
  design_block_images()
  .design_cache$image_hit = FALSE
  file = tempfile("design_", fileext = chart_device_ext())
  reset = function() setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
  res = tryCatch({
    setTimeLimit(cpu = limit, elapsed = limit, transient = FALSE)
    withCallingHandlers({
      plot = purrr::reduce(as.list(g$exprs), function(acc, e) eval(e, env), .init = NULL)
      if (!ggplot2::is_ggplot(plot)) stop("The last expression is not a ggplot or a patchwork; it must be the finished chart.", call. = FALSE)
      markup = design_markup_faults(plot)
      if (!is.null(markup)) stop(markup, call. = FALSE)
      built = ggplot2::ggplot_build(plot)
      design_draw(plot, file, size, dpi)
      list(plot = plot, built = built)
    }, warning = function(w) { said <<- c(said, design_message(w)); invokeRestart("muffleWarning") },
       message = function(m) { said <<- c(said, design_message(m)); invokeRestart("muffleMessage") })
  }, error = function(e) e, finally = reset())
  if (inherits(res, "error")) {
    unlink(file)
    msg = design_message(res)
    why = if (grepl("time limit", msg, fixed = TRUE)) paste0("The design took longer than ", limit, " seconds to build and draw and was stopped; use fewer layers, panels or labels.")
          else if (grepl("^(The last expression|A text has HTML|The code makes a vector)", msg)) msg
          else if (isTRUE(.design_cache$image_hit)) "A text has HTML or image markup in it; texts on a chart are plain words."
          else paste0("The code stopped with an error: ", msg, if (!grepl("[.]$", msg)) ".")
    return(out(FALSE, why))
  }
  if (!keep) unlink(file)
  out(TRUE, plot = res$plot, built = res$built, file = if (keep) file)
}

# ---- the checks on a drawn design ---------------------------------------------------------------------------------------------

# The plain ggplots a design is made of: the plots of a patchwork and its last one, or the plot itself.
design_parts <- function(plot) {
  patches = tryCatch(plot$patches$plots, error = function(e) NULL)
  c(unname(patches), list(plot))
}

# "geom_col" for a layer.
design_layer_name <- function(layer) paste0("geom_", tolower(gsub("([a-z0-9])([A-Z])", "\\1_\\2", sub("^Geom", "", class(layer$geom)[1]))))

# Rows. Every layer's input is what ggplot2 gives it: its own data, else the plot's (a function applied to it too). A mark (DESIGN_MARK_GEOMS) may not
#   be given more rows than d has, nor fewer unless the code has a filter() call (the one explicit way to leave rows out; head(), slice_*() and
#   summarise() change what is plotted without saying so, and a mark made from fewer rows is a drop). A stat layer (histogram, summary, smooth,
#   density, boxplot) is held to the same on what it is GIVEN, not on what it makes: its output has as many rows as the statistic makes. Any other
#   layer (labels, rules, leaders) may have DESIGN_ROW_EXTRA rows more than d, and as few as it likes.
design_check_rows <- function(parts, d, code) {
  nd = nrow(d)
  filtered = grepl("(^|[^A-Za-z0-9_.])filter\\s*\\(", code)
  unlist(purrr::map(parts, function(p) purrr::map_chr(seq_along(p$layers), function(i) {
    l = p$layers[[i]]
    n = tryCatch(nrow(l$layer_data(p$data)), error = function(e) NA_integer_)
    if (is.na(n) || inherits(l$geom, "GeomBlank")) return(NA_character_)
    mark = inherits(l$geom, DESIGN_MARK_GEOMS)
    nm = design_layer_name(l)
    if (n > nd + if (mark) 0L else DESIGN_ROW_EXTRA)
      return(paste0("Layer ", i, " (", nm, ") is given ", n, " rows but the table d has ", nd, "; a layer may not plot more rows than d."))
    if (mark && n < nd && !filtered)
      return(paste0("Layer ", i, " (", nm, ") plots ", n, " of the ", nd, " rows of d; keep every row, or leave rows out only with an explicit filter() on d."))
    NA_character_
  })))
}

# Bars, columns and areas include zero on the value axis. The value axis is the one the layer's data says (flipped_aes), seen through coord_flip();
#   its range is the panel's, after the scale's limits and the coordinates' (coord_cartesian(ylim = ) too), mapped back through the scale's transformation
#   (a log axis never includes zero).
design_check_zero <- function(parts) {
  unlist(purrr::map(parts, function(p) {
    b = ggplot2::ggplot_build(p)
    flip_coord = inherits(b$plot$coordinates, "CoordFlip")
    purrr::map_chr(seq_along(p$layers), function(i) {
      l = p$layers[[i]]
      if (!inherits(l$geom, c("GeomBar", "GeomArea"))) return(NA_character_)
      data = b$data[[i]]
      flipped = isTRUE(any(data$flipped_aes %in% TRUE))
      axis = if (flipped) "x" else "y"
      display = if (xor(flipped, flip_coord)) "x" else "y"
      sc = b$layout[[paste0("panel_scales_", axis)]][[1]]
      if (is.null(sc) || inherits(sc, "ScaleDiscretePosition")) return(NA_character_)
      rng = b$layout$panel_params[[1]][[paste0(if (inherits(b$plot$coordinates, c("CoordCartesian", "CoordFlip"))) display else axis, ".range")]]
      tr = tryCatch(sc$get_transformation(), error = function(e) NULL)
      lim = range(if (!is.null(tr)) tr$inverse(rng) else rng, na.rm = TRUE)
      if (is.finite(lim[[1]]) && lim[[1]] <= 1e-9 * max(abs(lim)) && lim[[2]] >= -1e-9 * max(abs(lim))) return(NA_character_)
      paste0("Layer ", i, " (", design_layer_name(l), ") is a bar or an area but its value axis runs from ", format(lim[[1]], digits = 4), " to ",
             format(lim[[2]], digits = 4), ", not through zero; bars and areas start at zero (and never on a log axis).")
    })
  }))
}

# No second axis: a scale with a secondary axis (sec.axis, from sec_axis() or dup_axis()).
design_check_second_axis <- function(parts) {
  second = purrr::map_lgl(parts, function(p) {
    b = ggplot2::ggplot_build(p)
    any(purrr::map_lgl(c(b$layout$panel_scales_x[1], b$layout$panel_scales_y[1]), function(sc) inherits(tryCatch(sc$secondary.axis, error = function(e) NULL), "AxisSecondary")))
  })
  if (any(second)) "The chart has a second axis; a design may not add one (it invites reading two scales as one)."
}

# The scale type of one position scale: discrete, date, log, continuous, or the name of its transformation (sqrt, reverse) or "binned".
design_scale_type <- function(sc) {
  if (inherits(sc, "ScaleDiscretePosition")) return("discrete")
  if (inherits(sc, c("ScaleContinuousDate", "ScaleContinuousDatetime"))) return("date")
  if (inherits(sc, "ScaleBinnedPosition")) return("binned")
  tr = tryCatch(sc$get_transformation()$name, error = function(e) "identity")
  if (tr %in% c("hms", "time")) "date" else if (grepl("^log", tr)) "log" else if (identical(tr, "identity")) "continuous" else tr
}

# The scale types the spec asks for, as list(a, b): the types each axis may be (a character vector each; the axes may stand either way round, so a
#   bar chart may be drawn sideways). A Date column is a date axis, text or a factor a discrete one, a number a continuous one (a log one when the
#   spec has log_x or log_y); a whole-number column with at most 40 values (a year, a rank) may be continuous or discrete. A column that is not in d
#   leaves its axis unchecked (NULL).
design_axes <- function(spec, d) {
  s = spec_defaults(spec_public(spec))
  fam = s$family
  ycol = if (fam %in% c("scatter", "bubble", "box", "heatmap", "dumbbell") && is_text1(s$y)) s$y else tryCatch(value_name(s), error = function(e) NULL)
  xcol = s$x
  one = function(col, log) {
    if (!is_text1(col) || !col %in% names(d)) return(NULL)
    x = d[[col]]
    if (inherits(x, c("Date", "POSIXct"))) "date"
    else if (is.numeric(x) && !is.factor(x)) {
      if (isTRUE(log)) "log"
      else if (all(x == round(x), na.rm = TRUE) && length(unique(x)) <= 40L) c("continuous", "discrete") else "continuous"
    } else "discrete"
  }
  list(a = one(xcol, s$log_x), b = one(ycol, s$log_y))
}

# The type of each axis is the spec's: the types of the first panel's x and y scales, either way round, against design_axes()'s.
design_check_scales <- function(p, axes) {
  if (is.null(axes) || is.null(axes$a) || is.null(axes$b)) return(NULL)
  b = ggplot2::ggplot_build(p)
  sx = b$layout$panel_scales_x[[1]]
  sy = b$layout$panel_scales_y[[1]]
  if (is.null(sx) || is.null(sy)) return(NULL)
  tx = design_scale_type(sx)
  ty = design_scale_type(sy)
  ok = (tx %in% axes$a && ty %in% axes$b) || (tx %in% axes$b && ty %in% axes$a)
  if (!ok) paste0("The axes are ", tx, " and ", ty, " but the spec's are ", paste(axes$a, collapse = " or "), " and ", paste(axes$b, collapse = " or "),
                  "; keep each axis' scale type (a log axis only when the spec has log_x or log_y; a date axis stays a date axis).")
}

# Everything d and the facts and the spec's own words allow a text to say, as one text for check_numbers(): the facts, the values and names of d (numbers,
#   shares as percentages, dates, categories), and the words of txt.
design_known_text <- function(d, facts, txt) {
  num_cols = purrr::keep(d, function(x) is.numeric(x) && !is.factor(x))
  nums = purrr::map(num_cols, function(x) {
    u = unique(x[is.finite(x)])
    u = utils::head(u, 20000L)
    c(format(u, digits = 15, scientific = FALSE, trim = TRUE), if (length(u) && all(u >= -1 & u <= 1)) format(u * 100, digits = 15, scientific = FALSE, trim = TRUE))
  })
  dates = purrr::map(purrr::keep(d, function(x) inherits(x, c("Date", "POSIXct"))), function(x) {
    u = utils::head(unique(as.Date(x)), 5000L)
    c(format(u, "%Y-%m-%d"), format(u, "%b %Y"), format(u, "%e %b %Y"), format(u, "%B %Y"))
  })
  cats = purrr::map(purrr::keep(d, function(x) is.character(x) || is.factor(x)), function(x) utils::head(unique(as.character(x)), 2000L))
  paste(c(design_facts_text(facts), names(d), unlist(nums), unlist(dates), unlist(cats), unlist(txt)), collapse = " ")
}

# The strings a design writes on the chart: its labels (title, subtitle, caption, axis and legend titles) and every label its layers draw.
design_drawn_strings <- function(parts, boxes) {
  labs = unlist(purrr::map(parts, function(p) {
    b = ggplot2::ggplot_build(p)
    l = ggplot2::get_labs(b)
    purrr::keep(unlist(l[intersect(names(l), c("title", "subtitle", "caption", "x", "y", "colour", "color", "fill", "size", "alt", "tag"))]), is.character)
  }))
  layer_labels = unlist(purrr::map(parts, function(p) {
    b = ggplot2::ggplot_build(p)
    purrr::map(seq_along(p$layers), function(i)
      if (inherits(p$layers[[i]]$geom, DESIGN_TEXT_GEOMS) && "label" %in% names(b$data[[i]])) as.character(b$data[[i]]$label))
  }))
  unique(c(labs, layer_labels, if (!is.null(boxes) && nrow(boxes)) boxes$label[!is.na(boxes$panel)]))   # the page's texts include the axis' numbers, which the scale writes, not the design
}

# The numbers written on the chart are in the facts or in d (check_numbers()).
design_check_numbers <- function(strings, d, facts, spec, txt) {
  bad = check_numbers(paste(strings[!is.na(strings)], collapse = " | "), design_known_text(d, facts, txt), spec)
  if (length(bad)) paste0("The chart writes ", paste0("\"", utils::head(bad, 4L), "\"", collapse = ", "), " which ", if (length(bad) > 1L) "are numbers that are" else "is a number that is",
                          " not in the facts or in d; write only numbers from facts or from d, formatted with the functions provided.")
}

# The theme of a plot as it is drawn (a complete theme replaces the default; an incomplete one is added to it), with every element worked out.
design_theme <- function(p) ggplot2::complete_theme(if (isTRUE(attr(p$theme, "complete"))) p$theme else ggplot2::get_theme() + p$theme)

# The background text is read against: the plot's fill, else the panel's, else white (the device's).
design_background <- function(th) {
  fill = function(el) {
    e = tryCatch(ggplot2::calc_element(el, th), error = function(e) NULL)
    f = if (!is.null(e) && !inherits(e, c("element_blank", "ggplot2::element_blank"))) e$fill
    if (is.character(f) && length(f) == 1L && !is.na(f) && !identical(f, "transparent")) f
  }
  fill("plot.background") %||% fill("panel.background") %||% "white"
}

# Text against its background at 4.5 to 1: the title, subtitle, caption, axis titles and axis text, the legend's and the strips' text when there are
#   legends or panels, and the colour of each text layer's labels (against the panel's background, or the fill of a bar or tile, or a label's own box).
design_check_contrast <- function(parts) {
  contrast = function(a, b) tryCatch(min(chart_contrast(a, b)), error = function(e) NA_real_)
  unlist(purrr::map(parts, function(p) {
    b = ggplot2::ggplot_build(p)
    th = tryCatch(design_theme(p), error = function(e) NULL)
    if (is.null(th)) return(character(0))
    bg = design_background(th)
    labs = ggplot2::get_labs(b)
    has_label = function(k) is.character(labs[[k]]) && any(nzchar(labs[[k]]))
    nonpos = setdiff(unlist(purrr::map(b$plot$scales$scales, "aesthetics")), c("x", "y", "xmin", "xmax", "ymin", "ymax", "xend", "yend"))
    elements = c(plot.title = has_label("title"), plot.subtitle = has_label("subtitle"), plot.caption = has_label("caption"), axis.title.x = has_label("x"),
                 axis.title.y = has_label("y"), axis.text.x = TRUE, axis.text.y = TRUE, legend.text = length(nonpos) > 0L, legend.title = length(nonpos) > 0L,
                 strip.text = !inherits(p$facet, "FacetNull"))
    from_theme = purrr::imap(elements[elements], function(on, el) {
      e = tryCatch(ggplot2::calc_element(el, th), error = function(e) NULL)
      col = if (!is.null(e) && !inherits(e, c("element_blank", "ggplot2::element_blank"))) e$colour
      if (!is.character(col) || length(col) != 1L || is.na(col) || identical(col, "transparent")) return(NA_character_)
      ratio = contrast(col, bg)
      if (isTRUE(ratio < 4.5)) paste0("The ", sub("[.]", " ", el), " is set in ", col, ", a contrast of ", format(ratio, digits = 2), " to 1 against the background ", bg,
                                       "; text needs at least 4.5 to 1.") else NA_character_
    })
    # what a text stands on: the fill of the bar, tile or box its anchor is inside of (strictly inside: a label just above a bar stands on the panel), a
    #   label's own box, else the plot's background
    rects = do.call(rbind, purrr::map(seq_along(p$layers), function(i) {
      dt = b$data[[i]]
      if (!inherits(p$layers[[i]]$geom, DESIGN_FILL_GEOMS) || !all(c("xmin", "xmax", "ymin", "ymax", "fill") %in% names(dt))) return(NULL)
      dt = utils::head(dt[!is.na(dt$fill) & !dt$fill %in% c("NA", "transparent"), c("xmin", "xmax", "ymin", "ymax", "fill")], 3000L)
      if (nrow(dt)) data.frame(lapply(dt, function(v) if (is.numeric(v)) v else as.character(v)), stringsAsFactors = FALSE)
    }))
    from_layers = purrr::map(seq_along(p$layers), function(i) {
      l = p$layers[[i]]
      if (!inherits(l$geom, DESIGN_TEXT_GEOMS)) return(NA_character_)
      data = utils::head(b$data[[i]], 500L)
      if (!all(c("x", "y", "colour") %in% names(data))) return(NA_character_)
      own = inherits(l$geom, c("GeomLabel", "GeomLabelRepel")) && "fill" %in% names(data)
      stands_on = purrr::map_chr(seq_len(nrow(data)), function(k) {
        if (own && !is.na(data$fill[[k]]) && !data$fill[[k]] %in% c("NA", "transparent")) return(as.character(data$fill[[k]]))
        x = suppressWarnings(as.numeric(data$x[[k]])); y = suppressWarnings(as.numeric(data$y[[k]]))
        inside = if (!is.null(rects) && !is.na(x) && !is.na(y)) which(x > rects$xmin + 1e-9 & x < rects$xmax - 1e-9 & y > rects$ymin + 1e-9 & y < rects$ymax - 1e-9)
        if (length(inside)) rects$fill[[utils::tail(inside, 1L)]] else bg
      })
      col = as.character(data$colour)
      ratio = purrr::map2_dbl(col, stands_on, function(a, bx) if (is.na(a) || a %in% c("NA", "transparent")) NA_real_ else contrast(a, bx))
      if (!any(ratio < 4.5, na.rm = TRUE)) return(NA_character_)
      worst = which.min(ratio)
      paste0("The text of layer ", i, " (", design_layer_name(l), ") is drawn in ", col[[worst]], ", a contrast of ", format(ratio[[worst]], digits = 2), " to 1 against ",
             stands_on[[worst]], " behind it; text needs at least 4.5 to 1.")
    })
    unlist(c(from_theme, from_layers))
  }))
}

# The measures of every text a plot draws, inches from the device's lower left, on a device chart_device() opens (the same measure as
#   drawn_text_boxes() in tests/gallery.R, for any plot, with no spec): one row for each text of a panel (value labels, annotations, ggrepel's after
#   grid.force()) and of the page (titles, axis text, legends), with the box it must stay inside (its panel's when the plot clips to its panels, else the
#   device's) and the panel it is in (NA for the page's). A geom_label's box reaches past its text by its padding.
design_text_boxes <- function(p, size = SPEC_SIZE[c("width", "height")], dpi = 96) {
  f = tempfile(fileext = chart_device_ext())
  chart_device(f, size[["width"]], size[["height"]], dpi)
  dev = grDevices::dev.cur()
  on.exit({ grDevices::dev.off(dev); unlink(f) })
  withCallingHandlers(print(p), warning = function(w) invokeRestart("muffleWarning"), message = function(m) invokeRestart("muffleMessage"))
  grid::grid.force()
  ls = grid::grid.ls(viewports = TRUE, print = FALSE, fullNames = TRUE)
  rows = which(ls$type == "grobListing" & grepl("^text\\[", ls$name))
  dsz = grDevices::dev.size("in")
  clip = !identical(p$coordinates$clip, "off")
  boxes = purrr::map(rows, function(i) tryCatch({
    name = sub("^text\\[(.*)\\]$", "\\1", ls$name[[i]])
    parts = sub("^viewport\\[(.*)\\]$", "\\1", strsplit(sub("^viewport\\[ROOT\\]::", "", ls$vpPath[[i]]), "::")[[1]])
    vp = do.call(grid::vpPath, as.list(parts))
    gp = do.call(grid::gPath, as.list(c(sub("^[A-Za-z]+\\[(.*)\\]$", "\\1", strsplit(ls$gPath[[i]], "::")[[1]]), name)))
    g = grid::grid.get(gp, strict = TRUE)
    lab = as.character(g$label)
    n = length(lab)
    if (!n || !is.character(lab)) return(NULL)
    panel_at = which(startsWith(parts, "panel"))[1]
    pb = if (!is.na(panel_at)) {
      grid::downViewport(do.call(grid::vpPath, as.list(parts[seq_len(panel_at)])))
      on.exit(grid::upViewport(0), add = TRUE)
      grid::deviceLoc(grid::unit(c(0, 1), "npc"), grid::unit(c(0, 1), "npc"))
    }
    grid::upViewport(0)
    grid::downViewport(vp)
    one_gp = function(k) do.call(grid::gpar, purrr::map(unclass(g$gp), function(v) if (length(v) > 1L) v[[(k - 1L) %% length(v) + 1L]] else v))
    xs = rep_len(g$x, n); ys = rep_len(g$y, n)
    loc = purrr::map(seq_len(n), function(k) {
      grid::pushViewport(grid::viewport(gp = one_gp(k)))
      on.exit(grid::popViewport())
      l = grid::deviceLoc(xs[k], ys[k])
      c(x = as.numeric(l$x), y = as.numeric(l$y))
    })
    tg = purrr::map(seq_len(n), function(k) grid::textGrob(lab[[k]], gp = one_gp(k)))
    w = purrr::map_dbl(tg, function(x) grid::convertWidth(grid::grobWidth(x), "in", valueOnly = TRUE))
    h = purrr::map_dbl(tg, function(x) grid::convertHeight(grid::grobHeight(x), "in", valueOnly = TRUE) + grid::convertHeight(grid::grobDescent(x), "in", valueOnly = TRUE))
    grid::upViewport(0)
    hj = rep_len(as.numeric(g$hjust %||% 0.5), n)
    vj = rep_len(as.numeric(g$vjust %||% 0.5), n)
    ax = purrr::map_dbl(loc, "x"); ay = purrr::map_dbl(loc, "y")
    pad = if (grepl("label", ls$gPath[[i]], ignore.case = TRUE)) 0.3 * 1.2 * SPEC_LABEL_MM * 2.845 / 72 + 0.01 else 0
    in_panel = !is.na(panel_at)
    # the box of a text turned by `rot` degrees about its anchor: the bounding box of its four corners
    th = rep_len(as.numeric(g$rot %||% 0), n) * pi / 180
    corner = function(xl, yl) list(x = ax + cos(th) * xl - sin(th) * yl, y = ay + sin(th) * xl + cos(th) * yl)
    cs = list(corner(-hj * w, -vj * h), corner((1 - hj) * w, -vj * h), corner(-hj * w, (1 - vj) * h), corner((1 - hj) * w, (1 - vj) * h))
    lo = function(k) do.call(pmin, purrr::map(cs, k))
    hi = function(k) do.call(pmax, purrr::map(cs, k))
    data.frame(label = lab, x0 = lo("x") - pad, x1 = hi("x") + pad, y0 = lo("y") - pad, y1 = hi("y") + pad,
               px0 = if (in_panel && clip) as.numeric(pb$x[1]) else 0, px1 = if (in_panel && clip) as.numeric(pb$x[2]) else dsz[[1]],
               py0 = if (in_panel && clip) as.numeric(pb$y[1]) else 0, py1 = if (in_panel && clip) as.numeric(pb$y[2]) else dsz[[2]],
               panel = if (in_panel) sub(".*viewport\\[(panel[^]]*)\\].*", "\\1", ls$vpPath[[i]]) else NA_character_,
               inside = if (in_panel && clip) "panel" else "device", stringsAsFactors = FALSE)
  }, error = function(e) { grid::upViewport(0); NULL }))
  out = do.call(rbind, purrr::compact(boxes))
  if (is.null(out)) data.frame(label = character(0)) else out
}

# The faults of the texts as drawn, as sentences: a text that runs past its panel (when the plot clips to its panels) or past the device, and two
#   texts of one panel that overlap (by more than `tol` inches each way). Returns list(faults, boxes).
design_text_faults <- function(p, size = SPEC_SIZE[c("width", "height")], tol = 0.02) {
  b = design_text_boxes(p, size)
  if (!nrow(b)) return(list(faults = character(0), boxes = b))
  outside = purrr::keep(seq_len(nrow(b)), function(i) b$x0[[i]] < b$px0[[i]] - tol || b$x1[[i]] > b$px1[[i]] + tol || b$y0[[i]] < b$py0[[i]] - tol || b$y1[[i]] > b$py1[[i]] + tol)
  pairs = if (nrow(b) > 1L) utils::combn(nrow(b), 2L, simplify = FALSE) else list()
  meet = purrr::keep(pairs, function(ij) {
    i = ij[1]; j = ij[2]
    !is.na(b$panel[[i]]) && identical(b$panel[[i]], b$panel[[j]]) &&
      min(b$x1[[i]], b$x1[[j]]) - max(b$x0[[i]], b$x0[[j]]) > tol && min(b$y1[[i]], b$y1[[j]]) - max(b$y0[[i]], b$y0[[j]]) > tol
  })
  list(faults = c(purrr::map_chr(outside, function(i) paste0("The text '", substr(b$label[[i]], 1, 40), "' runs past the ", b$inside[[i]], " and would be cut off; shorten it or move it.")),
                  purrr::map_chr(meet, function(ij) paste0("The texts '", substr(b$label[[ij[1]]], 1, 30), "' and '", substr(b$label[[ij[2]]], 1, 30), "' overlap; move or drop one."))),
       boxes = b)
}

# Rows removed by the scales or by missing values are rows not drawn.
design_check_warnings <- function(warnings) {
  hit = warnings[grepl("Removed [0-9]+ rows?", warnings)]
  if (length(hit)) paste0("ggplot2 left rows out of the drawing (\"", substr(hit[[1]], 1, 80), "\"); every row of d is plotted, so no scale limit may cut values off.")
}

# The checks. `plot`: what design_run() returned; `d`: the table; `facts`: design_facts()'s list (or text); `spec`: the checked spec; `code`: the design's
#   code (for the filter() rule); `txt`: the provided words; `warnings`: design_run()'s; `axes`: design_axes() (NULL leaves the scale types unchecked);
#   `text`: whether to draw the plot again to measure its texts. Returns list(ok, reasons): one plain sentence for each thing wrong, first the cheapest.
design_checks <- function(plot, d, facts, spec, code = "", txt = NULL, warnings = character(0), axes = design_axes(spec, d), size = SPEC_SIZE[c("width", "height")], text = TRUE) {
  parts = design_parts(plot)
  caught = function(f) tryCatch(f(), error = function(e) paste0("The chart could not be checked: ", design_message(e)))
  faults = c(
    caught(function() design_check_second_axis(parts)),
    caught(function() design_check_rows(parts, d, code)),
    caught(function() design_check_zero(parts)),
    caught(function() design_check_scales(parts[[length(parts)]], axes)),
    caught(function() design_check_warnings(warnings)),
    caught(function() design_check_contrast(parts)))
  tf = if (text) tryCatch(design_text_faults(plot, size), error = function(e) list(faults = paste0("The texts could not be measured: ", design_message(e)), boxes = NULL))
  numbers = caught(function() design_check_numbers(design_drawn_strings(parts, tf$boxes), d, facts, spec, txt))
  reasons = unique(as.character(stats::na.omit(c(faults, numbers, tf$faults))))
  list(ok = !length(reasons), reasons = reasons)
}
