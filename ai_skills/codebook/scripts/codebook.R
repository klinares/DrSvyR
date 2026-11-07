# codebook.R -- from a data frame to a validated data-dict.yaml and a Quarto
#   codebook, with no microdata sent to a language model.
#
# Source it:  intern_source_skill("codebook", "codebook.R")
#
#   dir  <- codebook_draft(palmerpenguins::penguins, "codebook", table = "penguins",
#                          describe = intern_complete)      # (a)-(c)
#   # review and edit codebook/data-dict.yaml, then
#   dd_validate("codebook")                                  # (d)
#   codebook_render("codebook", title = "Palmer penguins")   # (e)
#
# The steps, and what leaves the session:
#   (a) codebook_profile(): profile every column locally.
#   (b) profile_text(): the profile as plain-language aggregates, every count
#       below suppress_n shown as "<n", min and max never shown. This text,
#       the column names, labels and the redacted draft below are all a model
#       ever sees.
#   (c) dd_draft() runs `data-dict draft` locally; redact_dictionary() strips
#       its `examples` and `range` (real values) and `source`; the model's
#       proposal (labels, descriptions, enum values, todos) is merged back
#       locally by merge_dictionary(), which checks enum values against the
#       data. The person reviews the YAML.
#   (d) dd_validate(): `data-dict validate-data`.
#   (e) codebook_render(): a Quarto report following the dataviz skill.
#
# Needs: dplyr, purrr, tibble, yaml, jsonlite, nanoparquet, and the data-dict
#   CLI (pak::pak("tidyverse/data-dict/r"); datadict::dd_install()). Quarto for
#   rendering. All calls are pkg::fn(); no loops; functions only.

# ---- (a) profile, locally ------------------------------------------------------

cb_label <- function(col) {
  lab = attr(col, "label", exact = TRUE)
  if (is.character(lab) && length(lab) == 1L && nzchar(lab)) lab else NA_character_
}

cb_type <- function(col) {
  if (inherits(col, "haven_labelled")) return("labelled")
  if (is.factor(col)) return("factor")
  if (inherits(col, "Date")) return("date")
  if (inherits(col, "POSIXt")) return("datetime")
  if (is.logical(col)) return("logical")
  if (is.numeric(col)) return("numeric")
  if (is.character(col)) return("character")
  class(col)[1]
}

# A labelled column as its value labels (unlabelled codes kept as text).
cb_as_categories <- function(col) {
  if (!inherits(col, "haven_labelled")) return(col)
  labs = attr(col, "labels", exact = TRUE)
  v = unclass(col)
  out = names(labs)[match(v, labs)]
  out[is.na(out) & !is.na(v)] = as.character(v[is.na(out) & !is.na(v)])
  factor(out, levels = unique(c(names(labs), sort(unique(out[!out %in% names(labs)])))))
}

# Counts as text: 1..k-1 become "<k"; when exactly one cell is that small the
#   next-smallest nonzero cell is hidden too, so it cannot be recovered from
#   the total. That second cell is marked "suppressed", not "<k": it may be
#   large, and "<k" would be false.
suppress_counts <- function(n, k) {
  small = n > 0 & n < k
  others = which(!small & n > 0)
  extra = rep(FALSE, length(n))
  if (sum(small) == 1L && length(others)) extra[others[which.min(n[others])]] = TRUE
  out = format(n, big.mark = ",", trim = TRUE)
  out[extra] = "suppressed"
  out[small] = paste0("<", k)
  out
}

cb_num <- function(x) format(signif(x, 4), big.mark = ",", scientific = FALSE, trim = TRUE)

# Frequency table of a categorical column: level, n, shown (suppressed text),
#   share of valid values (NA where suppressed).
cb_freq <- function(col, k) {
  v = cb_as_categories(col)
  tab = table(v, useNA = "no")
  n = as.integer(tab)
  shown = suppress_counts(n, k)
  sup = startsWith(shown, "<") | shown == "suppressed"
  tibble::tibble(level = names(tab), n = n, shown = shown,
                 share = ifelse(sup, NA_real_, n / sum(n)), suppressed = sup)
}

is_categorical <- function(col, max_levels = 25L)
  is.factor(col) || inherits(col, "haven_labelled") || is.logical(col) ||
  (is.character(col) && dplyr::n_distinct(col, na.rm = TRUE) <= max_levels)

# One row per column, computed locally. `freq` holds frequency tables for
#   categorical columns; numeric summaries exclude min and max.
codebook_profile <- function(data, suppress_n = 10) {
  stopifnot(is.data.frame(data))
  rows = purrr::imap(data, function(col, name) {
    n_miss = sum(is.na(col))
    v = col[!is.na(col)]
    num = is.numeric(col) && !inherits(col, "haven_labelled")
    q = if (num && length(v) >= suppress_n)
      stats::quantile(as.numeric(v), c(0.25, 0.5, 0.75), names = FALSE)
    else rep(NA_real_, 3)
    tibble::tibble(
      column = name, type = cb_type(col), label = cb_label(col),
      n_valid = length(v), n_missing = n_miss,
      n_distinct = dplyr::n_distinct(v),
      mean = if (num && length(v) >= suppress_n) mean(as.numeric(v)) else NA_real_,
      sd = if (num && length(v) >= suppress_n) stats::sd(as.numeric(v)) else NA_real_,
      q25 = q[1], median = q[2], q75 = q[3],
      freq = list(if (is_categorical(col)) cb_freq(col, suppress_n) else NULL))
  })
  out = dplyr::bind_rows(rows)
  attr(out, "suppress_n") = suppress_n
  attr(out, "n_rows") = nrow(data)
  out
}

# ---- (b) aggregates as plain language -------------------------------------------

cb_column_text <- function(p, k) {
  head_txt = paste0("- ", p$column, " (", p$type,
                    if (!is.na(p$label)) paste0(", labelled \"", p$label, "\"") else "", "): ")
  if (p$n_valid < k) return(paste0(head_txt, "fewer than ", k, " valid values; nothing more shown."))
  miss = if (p$n_missing > 0 && p$n_missing < k) paste0("fewer than ", k, " missing")
         else paste0(format(p$n_missing, big.mark = ","), " missing")
  f = p$freq[[1]]
  body = if (!is.null(f)) {
    hide = p$type == "character"       # rare free-text values are hidden entirely
    shown = f[!(hide & f$suppressed), ]
    cells = ifelse(shown$suppressed, paste(shown$level, shown$shown),
                   sprintf("%s %s (%.0f%%)", shown$level, shown$shown, 100 * shown$share))
    paste0(p$n_distinct, " categories: ", paste(cells, collapse = "; "),
           if (hide && any(f$suppressed))
             paste0("; plus ", sum(f$suppressed), " values hidden (rare, or hidden to protect a rare one)")
           else "")
  } else if (!is.na(p$mean)) {
    sprintf("%s distinct values; mean %s, sd %s, quartiles %s / %s / %s",
            format(p$n_distinct, big.mark = ","), cb_num(p$mean), cb_num(p$sd),
            cb_num(p$q25), cb_num(p$median), cb_num(p$q75))
  } else {
    paste0(format(p$n_distinct, big.mark = ","), " distinct values (not listed)")
  }
  paste0(head_txt, miss, "; ", body, ".")
}

# The whole profile as text. Safe to send: aggregates only, suppressed.
profile_text <- function(profile, label = "the data") {
  k = attr(profile, "suppress_n")
  rows = purrr::map_chr(seq_len(nrow(profile)), function(i) cb_column_text(profile[i, ], k))
  paste(c(sprintf(paste0("Profile of %s: %s rows, %s columns. Counts are unweighted. Counts ",
                         "below %s are shown as <%s. A count shown as \"suppressed\" is hidden ",
                         "only so a small one cannot be worked out; it may be large. Minimum and ",
                         "maximum are never shown."),
                  label, format(attr(profile, "n_rows"), big.mark = ","), nrow(profile), k, k),
          rows), collapse = "\n")
}

# ---- the data-dict CLI ------------------------------------------------------------

dd_cli <- function() {
  p = if (requireNamespace("datadict", quietly = TRUE))
    tryCatch(datadict::dd_path(), error = function(e) "") else ""
  if (!nzchar(p)) p = unname(Sys.which("data-dict"))
  if (!nzchar(p) || !file.exists(p))
    stop("The data-dict CLI is not installed. In R: pak::pak(\"tidyverse/data-dict/r\"); ",
         "datadict::dd_install()", call. = FALSE)
  p
}

# Runs the CLI in `dir` (it resolves the dictionary's `source` paths from
#   there). Returns stdout lines with the exit status as an attribute.
dd_run_in <- function(dir, args, stderr = TRUE) {
  old = setwd(dir)
  on.exit(setwd(old), add = TRUE)
  out = suppressWarnings(system2(dd_cli(), args, stdout = TRUE, stderr = stderr))
  attr(out, "status") = attr(out, "status") %||% 0L
  out
}

`%||%` <- function(x, y) if (is.null(x)) y else x

# Columns as the CLI should see them: labelled codes and factors as their
#   labels (text), so the dictionary documents what a reader sees.
prepare_for_parquet <- function(data)
  dplyr::mutate(data, dplyr::across(dplyr::everything(), function(col) {
    if (inherits(col, "haven_labelled")) col = cb_as_categories(col)
    if (is.factor(col)) col = as.character(col)
    attributes(col)[setdiff(names(attributes(col)), c("class", "tzone", "levels"))] = NULL
    col
  }))

# Writes <table>.parquet and a fresh data-dict.yaml (via `data-dict draft`) in
#   `dir`. Everything stays on this machine.
dd_draft <- function(data, dir, table = "data", overwrite = FALSE) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  dict = file.path(dir, "data-dict.yaml")
  if (file.exists(dict)) {
    if (!overwrite) stop(dict, " exists; use overwrite = TRUE to start again.", call. = FALSE)
    unlink(dict)
  }
  nanoparquet::write_parquet(prepare_for_parquet(data), file.path(dir, paste0(table, ".parquet")))
  out = dd_run_in(dir, c("draft", paste0(table, ".parquet")))
  if (attr(out, "status") != 0) stop("data-dict draft failed:\n", paste(out, collapse = "\n"),
                                     call. = FALSE)
  dict
}

# ---- (c) the model's part -----------------------------------------------------------

# The dictionary without anything taken from the values: examples, ranges and
#   source paths are removed. This is the only form a model sees.
redact_dictionary <- function(dict) {
  dict$tables = purrr::map(dict$tables, function(t) {
    t$source = NULL
    t$columns = purrr::map(t$columns, function(col) {
      col[c("examples", "range", "values")] = NULL
      col
    })
    t
  })
  dict
}

DICT_SYSTEM <- paste(
  "You are a survey methodologist helping document a dataset as a data-dict.yaml",
  "(https://data-dict.tidyverse.org/spec.html). You never see the data, only column",
  "names, labels and suppressed aggregates. A description you invent is worse than a",
  "question you ask: when you are not sure what a column means, its units or its codes,",
  "write a todo question for the analyst instead of guessing. Never write examples or",
  "ranges, and never write a number that is not in what you were given.")

dictionary_prompt <- function(redacted_yaml, profile, context = NULL) paste0(
  if (!is.null(context)) paste0("What the analyst says about the data:\n", context, "\n\n") else "",
  profile, "\n\n",
  "The draft dictionary (made by `data-dict draft`, values removed):\n\n```yaml\n",
  redacted_yaml, "\n```\n\n",
  "Return one ```yaml block and nothing else, in this shape:\n\n",
  "```yaml\n",
  "dataset:\n  label: <short title>\n  description: <what one row is, the population, the source>\n",
  "columns:\n",
  "  - name: <exact column name>\n",
  "    label: <short human label>\n",
  "    description: <one or two sentences, only from the evidence>\n",
  "    type: <only to change it: enum, number(id), number(ordinal), number(quantity), ",
  "string, boolean, date, datetime>\n",
  "    values: [<for enum only: the category names exactly as listed in the profile>]\n",
  "    units: <for number(quantity) only, e.g. mm, g, USD>\n",
  "    display: restricted   # only if the column could identify or contact a person\n",
  "    todo: <questions for the analyst, one per line; omit if none>\n",
  "```\n\n",
  "Include every column. Use enum only when the profile lists every category. ",
  "Make number(ordinal) or number(quantity) only when the meaning is clear. ",
  "Keep the draft's todo items you cannot resolve from the evidence.")

# The yaml block in a reply, parsed.
parse_proposal <- function(reply) {
  m = regmatches(reply, regexpr("(?s)```ya?ml\\s*\\n.*?```", reply, perl = TRUE))
  txt = if (length(m)) sub("(?s)^```ya?ml\\s*\\n(.*)```$", "\\1", m, perl = TRUE) else reply
  out = tryCatch(yaml::yaml.load(txt), error = function(e)
    stop("The model's reply is not valid YAML: ", conditionMessage(e), call. = FALSE))
  if (!is.list(out) || !is.list(out$columns))
    stop("The model's reply has no `columns` list.", call. = FALSE)
  out
}

REQUIRES_RANGE <- c("number(ordinal)", "number(quantity)", "date", "datetime")

# A placeholder for a restricted column: never a real value.
fake_examples <- function(type) {
  if (startsWith(type %||% "string", "number")) list(1, 2, 3)
  else list("REDACTED-1", "REDACTED-2", "REDACTED-3")
}

todo_text <- function(...) {
  parts = unlist(list(...))
  parts = parts[!is.na(parts) & nzchar(trimws(parts))]
  if (length(parts)) paste(trimws(parts), collapse = "\n") else NULL
}

# One draft column with the model's proposal applied. `observed` are the
#   column's distinct non-missing values, as text, checked locally.
merge_column <- function(col, prop, observed) {
  if (is.null(prop)) return(col)
  notes = character(0)
  out = list(name = col$name, label = prop$label, description = prop$description,
             type = col$type)
  want = prop$type %||% col$type
  if (identical(want, "enum")) {
    vals = as.character(unlist(prop$values))
    if (length(vals) && setequal(vals, observed)) {
      out$type = "enum"
      out$values = as.list(vals)
    } else {
      out$type = col$type
      notes = c(notes, "The model proposed an enum whose values do not match the data; check the categories.")
    }
  } else if (!is.null(prop$type)) {
    out$type = want
  }
  if (!identical(out$type, "enum")) {
    out$range = col$range
    out$examples = col$examples
    if (out$type %in% REQUIRES_RANGE && is.null(out$range))
      notes = c(notes, paste0("`", out$type, "` needs a range."))
  }
  if (identical(out$type, "number(quantity)") && !is.null(prop$units)) out$units = prop$units
  if (identical(prop$display, "restricted")) {
    out$display = "restricted"
    if (!is.null(out$examples)) out$examples = fake_examples(out$type)
    if (!out$type %in% REQUIRES_RANGE) out$range = NULL
    else notes = c(notes, "Restricted column: coarsen or remove the observed range before sharing.")
    notes = c(notes, "Examples replaced with placeholders because the column may identify people.")
  }
  if (is.null(prop$description)) notes = c(notes, "Add a `description`.")
  out$todo = todo_text(prop$todo, notes)
  purrr::compact(out)
}

# The draft with the proposal merged in, values checked against `data`.
merge_dictionary <- function(dict, proposal, data) {
  props = rlang::set_names(proposal$columns, purrr::map_chr(proposal$columns, "name"))
  ds = proposal$dataset %||% list()
  # A single-table dictionary carries its label and description at the top
  #   level only (data-dict warning S16).
  single = length(dict$tables) == 1L
  dict$tables = purrr::map(dict$tables, function(t) {
    if (!single) {
      t$label = ds$label %||% t$label
      t$description = ds$description %||% t$description
    }
    t$columns = purrr::map(t$columns, function(col) {
      src = data[[col$name]]
      obs = if (is.null(src)) character(0)
            else unique(as.character(cb_as_categories(src)[!is.na(src)]))
      merge_column(col, props[[col$name]], obs)
    })
    t[c("name", "label", "description", "source", "todo", "columns")] |> purrr::compact()
  })
  if (!is.null(ds$description)) {
    dict$name = dict$name %||% dict$tables[[1]]$name
    dict$label = ds$label
    dict$description = ds$description
    dict$todo = NULL
  }
  dict[c("$version", "$learn_more", "name", "label", "description", "todo", "tables")] |>
    purrr::compact()
}

# (a)-(c) in one call. `describe` is any function(prompt, system) returning
#   the model's text (inteRn: intern_complete); NULL stops after the local
#   draft. Returns the dictionary path; the person reviews the file next.
codebook_draft <- function(data, dir, table = "data", describe = NULL, context = NULL,
                           suppress_n = 10, overwrite = FALSE) {
  dict_path = dd_draft(data, dir, table, overwrite = overwrite)
  prof = codebook_profile(data, suppress_n)
  writeLines(profile_text(prof, table), file.path(dir, "profile.txt"))
  if (is.null(describe)) return(invisible(dict_path))
  dict = yaml::read_yaml(dict_path)
  sent = dictionary_prompt(yaml::as.yaml(redact_dictionary(dict)), profile_text(prof, table),
                           context)
  # What was sent is kept beside the dictionary, so anyone can audit it.
  writeLines(sent, file.path(dir, "sent_to_model.txt"))
  proposal = parse_proposal(describe(sent, DICT_SYSTEM))
  merged = merge_dictionary(dict, proposal, data)
  yaml::write_yaml(merged, dict_path)
  invisible(dict_path)
}

# ---- (d) validate -----------------------------------------------------------------

# Runs `data-dict validate-<level>` and returns a list: status ("pass",
#   "warning", "error"), problems (a tibble), and the raw report.
dd_validate <- function(dir, level = c("data", "meta", "spec")) {
  level = match.arg(level)
  out = dd_run_in(dir, c(paste0("validate-", level), "data-dict.yaml", "--json"), stderr = FALSE)
  rep = tryCatch(jsonlite::fromJSON(paste(out, collapse = "\n"), simplifyVector = FALSE),
                 error = function(e) stop("data-dict gave no JSON report:\n",
                                          paste(out, collapse = "\n"), call. = FALSE))
  probs = purrr::map(rep$problems %||% list(), function(p) tibble::tibble(
    code = p$code %||% NA_character_, severity = p$severity %||% NA_character_,
    message = p$message %||% NA_character_, expected = p$expected %||% NA_character_,
    line = p$location$start_line %||% NA_integer_))
  list(status = rep$status %||% "unknown",
       problems = dplyr::bind_rows(tibble::tibble(code = character(), severity = character(),
                                                  message = character(), expected = character(),
                                                  line = integer()), probs),
       report = rep)
}

# ---- (e) render -------------------------------------------------------------------

# Copies the template (and the dataviz theme) next to the dictionary and
#   renders it with Quarto. skills_dir: the ai_skills folder (inteRn sets
#   option ai_skills.dir when it sources a skill).
codebook_render <- function(dir, title = "Codebook", suppress_n = 10,
                            skills_dir = getOption("ai_skills.dir"), open = FALSE) {
  if (is.null(skills_dir) || !dir.exists(skills_dir))
    stop("Give skills_dir, the ai_skills folder.", call. = FALSE)
  if (!nzchar(Sys.which("quarto"))) stop("Quarto is not installed (quarto.org).", call. = FALSE)
  file.copy(file.path(skills_dir, "codebook", "templates", "codebook.qmd"),
            file.path(dir, "codebook.qmd"), overwrite = TRUE)
  file.copy(file.path(skills_dir, "dataviz", "scripts", "theme_intern.R"),
            file.path(dir, "theme_intern.R"), overwrite = TRUE)
  old = setwd(dir)
  on.exit(setwd(old), add = TRUE)
  out = suppressWarnings(system2("quarto", c("render", "codebook.qmd",
                                             "-P", shQuote(paste0("title:", title)),
                                             "-P", paste0("suppress_n:", suppress_n)),
                                 stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(out, "status")) && attr(out, "status") != 0)
    stop("Quarto failed:\n", paste(utils::tail(out, 30), collapse = "\n"), call. = FALSE)
  html = normalizePath(file.path(dir, "codebook.html"), winslash = "/")
  if (open) utils::browseURL(html)
  html
}
