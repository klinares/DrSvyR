# data.R for chaRt
# The data file and its codebook: read a delimited file, profile every column, build, write, read
#   and check codebook.yaml (DESIGN.md section 5), and the two texts a model will be sent about the
#   columns (section 4). Everything here is deterministic R; nothing calls a model. Function
#   definitions and constants only.


# ---- constants -------------------------------------------------------------------------

# A category with more levels than this is text, and its levels are never kept.
CODEBOOK_MAX_LEVELS <- 30L

# At most this many columns go to the model with their detail in one call. At work the limit is on
#   the number of calls, not on tokens, so it is set high enough that a typical file needs one.
CODEBOOK_MAX_DETAIL <- 60L

# An integer column with this many distinct values or fewer gets CODED_NOTE.
CODED_MAX_DISTINCT <- 10L
CODED_NOTE <- "may be a coded category"

# A whole-number column whose values are all different is an id only when they are an unbroken run
#   or its name looks like an id's (lower-cased); otherwise it is an integer with DISTINCT_NOTE.
ID_NAME_PATTERN <- "(^|_)(id|key|code)($|_)"
DISTINCT_NOTE <- "every value is different; may be an identifier"

# A year column: an integer whose values all lie in this range and whose name contains "year".
YEAR_RANGE <- c(1800, 2100)

CODEBOOK_VERSION <- 1L
CODEBOOK_TYPES <- c("number", "integer", "category", "ordered", "date", "text", "id", "flag")
CODEBOOK_ROLES <- c("measure", "group", "time", "id", "text", "ignore")
LABEL_SOURCES <- c("file", "ai_guess", "user")

# The values always read as missing. The analyst may add others (read_data(missing =)); R never
#   decides that a value means missing, and none is recoded.
DATA_NA <- c("", "NA")

# The roles each type allows; default_role() says which one a column starts with.
ROLE_CHOICES <- list(number = c("measure", "ignore"), integer = c("measure", "time", "ignore"),
                     category = c("group", "ignore"), ordered = c("group", "ignore"), flag = c("group", "ignore"),
                     date = c("time", "ignore"), id = c("id", "ignore"), text = c("text", "ignore"))

# How many row numbers a parsing problem lists.
PROBLEM_ROWS_SHOWN <- 5L

# Numbers in the profile are kept to 6 significant digits and written to YAML with 15, so a
#   codebook written and read back is identical.
FACT_DIGITS <- 6L
YAML_PRECISION <- 15L


# ---- B1. read the file -------------------------------------------------------------------

# One plain sentence for a file that cannot be read.
unreadable <- function(name, e)
  stop("The file ", name, " could not be read as delimited text: ",
       gsub("\\s+", " ", conditionMessage(e)), call. = FALSE)

# Blank names become column_<position>, then duplicates get _1, _2; each change is a sentence.
repair_names <- function(nms) {
  nms = ifelse(is.na(nms), "", nms)
  blank = !nzchar(trimws(nms))
  base = ifelse(blank, paste0("column_", seq_along(nms)), trimws(nms))
  fixed = make.unique(base, sep = "_")
  notes = purrr::compact(purrr::map(seq_along(nms), function(i) {
    if (identical(fixed[i], nms[i])) return(NULL)
    if (blank[i]) return(paste0("Column ", i, " had no name; it is now called ", fixed[i], "."))
    if (!identical(fixed[i], base[i]))
      return(paste0("Column ", i, " had the same name as an earlier column (", base[i], "); it is now called ", fixed[i], "."))
    paste0("Column ", i, " was named '", nms[i], "' with spaces around it; it is now called ", fixed[i], ".")
  }))
  list(names = fixed, notes = unlist(notes))
}

# The words of a column of text whose values are mostly numbers (at least half of its different
#   values read as numbers, not all of them); none for any other column.
mostly_numbers_words <- function(x) {
  if (!is.character(x)) return(character(0))
  obs = unique(x[!is.na(x)])
  num = !is.na(suppressWarnings(as.numeric(obs)))
  if (!length(obs) || mean(num) < 0.5 || all(num)) return(character(0))
  obs[!num]
}

# A numeric code for missing, such as -99 or 999 written in a column of numbers, is read as a number and so is not a
#   word among the numbers. It is offered, never applied, when all of this holds for a value of a numeric column:
#   - it is repeated: at least NUMERIC_CODE_ROWS rows, or NUMERIC_CODE_SHARE of the rows, and never a single row;
#   - it is one of the usual forms: negative while the rest of the column is not, or all nines (99, 999, 9999, ...),
#     with or without a minus sign;
#   - it lies outside the rest of the column (the column without that value) by more than NUMERIC_CODE_IQR times the
#     interquartile range, beyond the quartile on its side. A real maximum of 999 that occurs once, or amid values of
#     that size, fails one of these.
#   Returns the values as the text of the button ("-99"), at most three, the most repeated first.
NUMERIC_CODE_ROWS <- 5L
NUMERIC_CODE_SHARE <- 0.01
NUMERIC_CODE_IQR <- 3
numeric_code_words <- function(x) {
  if (!is.numeric(x)) return(character(0))
  obs = sort(x[is.finite(x)])
  runs = rle(obs)
  repeated = runs$lengths >= 2L & (runs$lengths >= NUMERIC_CODE_ROWS | runs$lengths >= NUMERIC_CODE_SHARE * length(obs))
  as_code = function(v) format(v, scientific = FALSE, trim = TRUE)
  usual = function(v, rest)
    (v < 0 && min(rest) >= 0) || (v == round(v) && grepl("^9{2,}$", as_code(abs(v))))
  outside = function(v, rest) {
    q = stats::quantile(rest, c(0.25, 0.75), names = FALSE)
    v > q[[2]] + NUMERIC_CODE_IQR * (q[[2]] - q[[1]]) || v < q[[1]] - NUMERIC_CODE_IQR * (q[[2]] - q[[1]])
  }
  keep = purrr::map_lgl(which(repeated), function(i) {
    rest = obs[obs != runs$values[[i]]]
    length(rest) >= 4L && usual(runs$values[[i]], rest) && outside(runs$values[[i]], rest)
  })
  idx = which(repeated)[keep]
  utils::head(as_code(runs$values[idx[order(-runs$lengths[idx], runs$values[idx])]]), 3L)
}

# The words that may stand for missing in a file, as the note below names them: the first three of
#   each column that is mostly numbers, then the numeric codes of each numeric column (numeric_code_words()), each word
#   once, in column order.
missing_candidates <- function(data)
  unique(unlist(purrr::map(as.list(data), function(x) c(utils::head(mostly_numbers_words(x), 3L), numeric_code_words(x))), use.names = FALSE)) %||% character(0)

# A column of text whose values are mostly numbers: a missing-value code such as ".." or -99 written
#   as a word keeps it from being read as numbers. Said, not fixed: the code is the analyst's call.
mostly_numbers_note <- function(x, name) {
  words = mostly_numbers_words(x)
  if (!length(words)) return(NULL)
  paste0("Column ", name, " is mostly numbers but also holds ", length(words), if (length(words) == 1L) " other value" else " other values",
         " (", paste0("'", utils::head(words, 3), "'", collapse = ", "), if (length(words) > 3) ", ...",
         "), so it is read as text. If ", if (length(words) == 1L) "it" else "one of them",
         " stands for missing, enter it under 'Values that mean missing' and read the file again.")
}

# Text typed one item per line (values that mean missing, an order of levels): each line trimmed,
#   blank lines dropped.
parse_lines <- function(txt) {
  v = trimws(unlist(strsplit(paste(txt %||% "", collapse = "\n"), "\r?\n")))
  v[nzchar(v)]
}

parse_missing <- function(txt) unique(parse_lines(txt))

# Files saved from Excel on Windows are often not UTF-8. readr::guess_encoding() names the most
#   likely encoding with a confidence; between the Latin encodings its pick is often a near
#   neighbour (a Latin-1 file guessed as ISO-8859-2 turns "Sao" with a tilde into a breve), so a file
#   guessed as any of them is read as windows-1252, which holds every Latin-1 letter. readr may
#   also make no guess at all (a short file in ISO-8859-2, say); then a file whose first lines are
#   not valid UTF-8 is read as windows-1252 too.
LATIN_ENCODINGS <- c("ISO-8859-1", "ISO-8859-2", "ISO-8859-9", "ISO-8859-15", "windows-1250", "windows-1252", "windows-1254")
ENCODING_SURE <- 0.8
ENCODING_LINES <- 10000L     # lines looked at when readr makes no guess

# The encodings the analyst may choose on the Data tab instead of the guess.
DATA_ENCODINGS <- c("UTF-8", "windows-1252", "ISO-8859-2", "ISO-8859-15")

# The encoding a file is read with, and the sentence for the analyst when it is not UTF-8. A
#   Western European file guessed as windows-1252 is right; a Central European one is not, and R
#   cannot tell them apart, so the sentence asks the analyst to check and the Data tab lets them
#   choose. `encoding` given (by the analyst or a codebook) is used as it is.
file_encoding <- function(path, encoding = NULL) {
  if (!is.null(encoding))
    return(list(encoding = encoding,
                note = if (!identical(encoding, "UTF-8")) paste0("The file was read as ", encoding, ", as chosen.")))
  g = tryCatch(readr::guess_encoding(path), error = function(e) NULL)
  check = "check names with accents, and choose the file's encoding if they are wrong."
  if (is.null(g) || !nrow(g)) {
    if (all(validUTF8(readLines(path, n = ENCODING_LINES, warn = FALSE)))) return(list(encoding = "UTF-8", note = NULL))
    return(list(encoding = "windows-1252",
                note = paste0("The file was read as windows-1252. This is a guess (readr could not make one); ", check)))
  }
  if (g$encoding[1] %in% c("UTF-8", "ASCII")) return(list(encoding = "UTF-8", note = NULL))
  top = g$encoding[1]
  sure = g$confidence[1]
  enc = if (top %in% LATIN_ENCODINGS) "windows-1252" else top
  unsure = sure < ENCODING_SURE || !identical(enc, top)
  list(encoding = enc,
       note = paste0("The file was read as ", enc, ".",
                     if (unsure) paste0(" This is a guess (readr's best guess was ", top, ", ", round(100 * sure), "% sure); ", check)))
}

# For a file that is not UTF-8: the delimiter that splits its header into the most columns.
DELIM_CANDIDATES <- c(",", ";", "\t", "|")
latin_delim <- function(path, encoding) {
  widths = purrr::map_int(DELIM_CANDIDATES, function(d) tryCatch(
    ncol(readr::read_delim(path, delim = d, n_max = 0, locale = readr::locale(encoding = encoding), name_repair = "minimal",
                           col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE, progress = FALSE)),
    error = function(e) 0L))
  DELIM_CANDIDATES[which.max(widths)]
}

# readr guesses the delimiter when delim is NULL: readr passes it to vroom, whose help says it
#   then guesses from , tab space | : and ;. A file it cannot guess for (one column, say) is read
#   with a comma. Types are guessed from every row (guess_max = Inf). The values in `missing` are
#   added to DATA_NA; readr's `na` matches a whole cell, after the spaces around it are trimmed
#   (trim_ws), never part of one.
read_data <- function(path, name = basename(path), missing = character(), encoding = NULL) {
  na = unique(c(DATA_NA, parse_missing(missing)))
  enc = file_encoding(path, encoding)
  read = function(delim)
    suppressWarnings(readr::read_delim(path, delim = delim, na = na, guess_max = Inf, trim_ws = TRUE,
                                       locale = readr::locale(encoding = enc$encoding),
                                       name_repair = "minimal", show_col_types = FALSE, progress = FALSE))
  # vroom guesses the delimiter from the raw bytes, which fails on a file that is not UTF-8; then
  #   the delimiter is the candidate that splits the header into the most columns.
  first = if (identical(enc$encoding, "UTF-8")) NULL else latin_delim(path, enc$encoding)
  data = tryCatch(read(first), error = function(e)
    if (grepl("guess the delimiter", conditionMessage(e), fixed = TRUE)) NULL else unreadable(name, e))
  if (is.null(data)) data = tryCatch(read(","), error = function(e) unreadable(name, e))
  bad = readr::problems(data)
  names_fixed = repair_names(names(data))
  data = tibble::as_tibble(stats::setNames(as.list(data), names_fixed$names))
  rows_bad = sort(unique(bad$row))
  parse_note = if (length(rows_bad))
    paste0(length(rows_bad), if (length(rows_bad) == 1L) " row" else " rows", " could not be read as expected (file line ",
           paste(utils::head(rows_bad, PROBLEM_ROWS_SHOWN), collapse = ", "), if (length(rows_bad) > PROBLEM_ROWS_SHOWN) ", ...",
           "); values there may be missing or in the wrong column.")
  empty_cols = names(data)[purrr::map_lgl(data, function(x) nrow(data) > 0L && all(is.na(x)))]
  problems = c(enc$note, names_fixed$notes, parse_note,
               purrr::map_chr(empty_cols, function(nm) paste0("Column ", nm, " is entirely missing.")),
               unlist(purrr::imap(as.list(data), mostly_numbers_note)),
               if (!nrow(data)) "The file has no rows.",
               if (ncol(data) == 1L) "The file has only one column; if it should have more, its delimiter may not be one readr recognises.")
  list(data = data, problems = as.character(problems), encoding = enc$encoding)
}


# ---- B2. profile and type ----------------------------------------------------------------

# Values and their counts, most common first (ties in the order of the values).
level_counts <- function(obs) {
  tab = table(as.character(obs))
  tab = tab[order(-as.integer(tab), names(tab))]
  list(values = names(tab), counts = unname(as.integer(tab)))
}

# A gap in seconds, in the largest whole unit.
gap_text <- function(secs) {
  units = c(day = 86400, hour = 3600, minute = 60, second = 1)
  unit = purrr::detect(names(units), function(u) secs %% units[[u]] == 0) %||% "second"
  n = secs / units[[unit]]
  paste(format(n, scientific = FALSE, trim = TRUE), if (n == 1) unit else paste0(unit, "s"))
}

date_text <- function(x) if (inherits(x, "POSIXt")) format(x, "%Y-%m-%d %H:%M:%S", tz = "UTC") else format(x, "%Y-%m-%d")

is_whole <- function(obs) is.numeric(obs) && length(obs) > 0L && all(is.finite(obs)) && all(obs == round(obs))

# Whether every value of a column is different, in a file long enough for that to mean something.
all_distinct <- function(obs, distinct, rows) distinct == length(obs) && rows > CODEBOOK_MAX_LEVELS

# Whether a whole-number column of distinct values looks like an id: an unbroken run of values, or
#   a name such as order_id, key or zip_code.
whole_id <- function(obs, distinct, name)
  (max(obs) - min(obs) + 1 == distinct) || grepl(ID_NAME_PATTERN, tolower(name))

# R's type for a column. A column readr returns as some other class (a time of day, say) is typed
#   as its text. A whole-number column of distinct values is an id only when whole_id() says so.
detect_type <- function(x, obs, distinct, rows, name = "") {
  if (inherits(x, c("Date", "POSIXt"))) return("date")
  if (is.logical(x) || distinct == 2L) return("flag")
  if (is.numeric(x)) {
    if (!is_whole(obs)) return("number")
    return(if (all_distinct(obs, distinct, rows) && whole_id(obs, distinct, name)) "id" else "integer")
  }
  if (all_distinct(obs, distinct, rows)) return("id")
  if (distinct <= CODEBOOK_MAX_LEVELS) "category" else "text"
}

number_facts <- function(obs) {
  q = stats::quantile(obs, c(0.25, 0.5, 0.75), names = FALSE, type = 7)
  list(min = signif(as.numeric(min(obs)), FACT_DIGITS), max = signif(as.numeric(max(obs)), FACT_DIGITS),
       quartiles = signif(q, FACT_DIGITS))
}

date_facts <- function(obs) {
  u = sort(unique(obs))
  secs = as.numeric(diff(as.numeric(u))) * (if (inherits(obs, "Date")) 86400 else 1)
  gap = if (length(secs)) { tab = table(secs); as.numeric(names(tab)[which.max(tab)]) }
  c(list(min = date_text(min(obs)), max = date_text(max(obs))), if (!is.null(gap)) list(gap = gap_text(gap)))
}

profile_column <- function(x, name) {
  if (is.factor(x)) x = as.character(x)
  if (!is.numeric(x) && !is.logical(x) && !is.character(x) && !inherits(x, c("Date", "POSIXt"))) x = as.character(x)
  rows = length(x)
  obs = x[!is.na(x)]
  distinct = length(unique(obs))
  type = detect_type(x, obs, distinct, rows, name)
  notes = if (identical(type, "integer"))
    c(if (distinct <= CODED_MAX_DISTINCT) CODED_NOTE, if (all_distinct(obs, distinct, rows)) DISTINCT_NOTE)
  detail = switch(type,
    date = date_facts(obs),
    flag = if (distinct) level_counts(obs),
    integer = c(number_facts(obs), if (distinct <= CODEBOOK_MAX_LEVELS) level_counts(obs),
                if (length(notes)) list(note = paste(notes, collapse = "; "))),
    number = number_facts(obs),
    id = if (is_whole(obs)) number_facts(obs),
    category = level_counts(obs),
    NULL)
  c(list(name = name, type = type, missing = if (rows) round(mean(is.na(x)), 2) else 0, distinct = distinct), detail)
}

profile_data <- function(data) unname(purrr::imap(as.list(data), profile_column))

# The roles a column's current type allows.
role_choices <- function(entry) ROLE_CHOICES[[entry$type %||% ""]] %||% "ignore"

# The role a type starts with; an integer year column is time.
default_role <- function(entry, type = entry$type) {
  if (identical(type, "integer") && grepl("year", entry$name, ignore.case = TRUE) && !is.null(entry$min) &&
      entry$min >= YEAR_RANGE[1] && entry$max <= YEAR_RANGE[2]) return("time")
  switch(type, number = , integer = "measure", category = , flag = , ordered = "group", date = "time",
         id = "id", text = "text", "ignore")
}


# ---- B3. the codebook --------------------------------------------------------------------

# The facts of one column, from its profile: everything but the name and R's type, which is
#   kept as `detected` so the types the analyst may choose can be worked out.
profile_facts <- function(p) c(list(missing = p$missing, distinct = p$distinct, detected = p$type),
                                p[setdiff(names(p), c("name", "type", "missing", "distinct"))])

# A label that is a model's guess (label_source ai_guess) keeps `sure`, whether the model said it
#   was sure; it goes when the analyst edits or accepts the label.
codebook_entry <- function(p, label = p$name, label_source = "file", type = p$type, role = default_role(p, type),
                           order = NULL, sure = NULL)
  c(list(name = p$name, label = label, label_source = label_source),
    if (identical(label_source, "ai_guess") && !is.null(sure)) list(sure = isTRUE(sure)),
    list(type = type, role = role),
    profile_facts(p), if (identical(type, "ordered")) list(order = order %||% default_order(p)))

# An ordered column's levels to start with: numbers in numeric order, words alphabetically.
default_order <- function(p) {
  v = p$values %||% character(0)
  num = suppressWarnings(as.numeric(v))
  if (length(v) && !anyNA(num)) v[order(num)] else sort(v)
}

# missing_codes is stored the way YAML gives it back: text when there are codes, an empty list
#   (written []) when there are none. missing_codes() always gives text.
codes_field <- function(codes) if (length(codes)) as.character(codes) else list()

new_codebook <- function(profile, file, rows, missing_codes = character(), encoding = "UTF-8")
  list(chart_codebook = CODEBOOK_VERSION, file = file, rows = as.integer(rows), row_is = "",
       missing_codes = codes_field(parse_missing(missing_codes)), encoding = encoding,
       columns = purrr::map(profile, codebook_entry))

missing_codes <- function(cb) as.character(unlist(cb$missing_codes %||% list()))

# The optional `source` of the file, one of the codebook's file-level fields (beside row_is): where the data come from, as
#   the source line under every chart says it ("Source: <this>."). A blank one is no field at all; the field sits after row_is.
codebook_source <- function(cb, source = NULL) {
  cb$source = NULL
  src = if (is.character(source) && length(source) == 1L && !is.na(source)) trimws(source) else ""
  if (nzchar(src)) cb = append(cb, list(source = src), after = match("row_is", names(cb)))
  cb
}

write_codebook <- function(cb, path) {
  yaml::write_yaml(cb, path, precision = YAML_PRECISION, fileEncoding = "UTF-8")
  invisible(path)
}

# A codebook file read back as written; a file that is not one stops with one plain sentence. A
#   codebook written before Phase 2b has no encoding: it stays NULL, so its file's encoding is guessed.
read_codebook <- function(path) {
  cb = tryCatch(yaml::read_yaml(path, fileEncoding = "UTF-8"), error = function(e)
    stop("This is not a codebook chaRt can read: ", gsub("\\s+", " ", conditionMessage(e)), call. = FALSE))
  if (is.list(cb)) cb$missing_codes = codes_field(parse_missing(as.character(unlist(cb$missing_codes))))
  ok = is.list(cb) && identical(cb$chart_codebook, CODEBOOK_VERSION) && is.list(cb$columns) &&
    all(purrr::map_lgl(cb$columns, function(e) is.list(e) && is.character(e$name) && length(e$name) == 1L))
  if (!ok) stop("This is not a codebook chaRt can read: it needs chart_codebook: 1 and a list of columns, each with a name.",
                call. = FALSE)
  cb
}

codebook_ready <- function(cb) !is.null(cb) && is.character(cb$row_is) && length(cb$row_is) == 1L && nzchar(trimws(cb$row_is))

# The types the analyst may give a column: what R found, and only what the data can be.
type_choices <- function(entry) {
  d = entry$detected %||% entry$type
  switch(d,
    category = c("category", "ordered", "text"),
    integer = c("integer", if (!is.null(entry$values)) c("category", "ordered"), "id"),
    id = c("id", if (!is.null(entry$quartiles)) "integer"),
    d)
}

# Whether an order is exactly the column's levels, each once.
order_ok <- function(order, entry)
  is.character(order) && !anyDuplicated(order) && setequal(order, entry$values %||% character(0)) &&
    length(order) == length(entry$values)

# What stops an uploaded codebook being applied to the file in hand, as plain sentences; none
#   means it can be applied. Nothing is merged or guessed.
check_codebook <- function(cb, profile) {
  in_file = purrr::map_chr(profile, "name")
  in_cb = purrr::map_chr(cb$columns, "name")
  facts = stats::setNames(purrr::map(profile, codebook_entry), in_file)
  per_column = purrr::map(cb$columns, function(e) {
    if (!e$name %in% in_file) return(NULL)
    f = facts[[e$name]]
    type = e$type %||% ""
    c(if (!type %in% type_choices(f))
        paste0("The codebook types ", e$name, " as ", if (nzchar(type)) type else "nothing", ", but its data cannot be that ",
               "(R reads it as ", f$type, "; it may be ", paste(type_choices(f), collapse = ", "), ")."),
      if (type %in% type_choices(f) && !(e$role %||% "") %in% role_choices(list(type = type)))
        paste0("The codebook gives ", e$name, " the role '", e$role %||% "", "', which a column of type ", type,
               " cannot have (it may be ", paste(role_choices(list(type = type)), collapse = ", "), ")."),
      if (!(e$label_source %||% "") %in% LABEL_SOURCES || !is.character(e$label) || length(e$label) != 1L)
        paste0("The codebook's label for ", e$name, " is not a single label marked file, ai_guess or user."),
      if (identical(type, "ordered") && !order_ok(e$order, f))
        paste0("The codebook orders the levels of ", e$name, ", but not exactly the levels it has in the file."))
  })
  c(if (!is.null(cb$source) && !(is.character(cb$source) && length(cb$source) == 1L && !is.na(cb$source))) "The codebook's source is not one line of text.",
    purrr::map_chr(setdiff(in_cb, in_file), function(nm) paste0("The codebook has a column ", nm, " that is not in the file.")),
    purrr::map_chr(setdiff(in_file, in_cb), function(nm) paste0("The file has a column ", nm, " that is not in the codebook.")),
    if (anyDuplicated(in_cb)) "The codebook names a column more than once.",
    unlist(per_column))
}

# The codebook for the file in hand with what an uploaded one decides: label, label_source,
#   type, role, an ordered column's order and row_is. Every fact comes from the profile.
apply_codebook <- function(cb, profile, file, rows, encoding = "UTF-8") {
  why = check_codebook(cb, profile)
  if (length(why)) stop(paste(why, collapse = " "), call. = FALSE)
  up = stats::setNames(cb$columns, purrr::map_chr(cb$columns, "name"))
  out = new_codebook(profile, file, rows, missing_codes(cb), encoding)
  out$row_is = if (is.character(cb$row_is) && length(cb$row_is) == 1L) cb$row_is else ""
  out = codebook_source(out, cb$source)
  out$columns = purrr::map(profile, function(p) {
    e = up[[p$name]]
    codebook_entry(p, label = e$label, label_source = e$label_source, type = e$type, role = e$role, order = e$order,
                   sure = e$sure)
  })
  out
}

# The file read again with the values that mean missing, and the analyst's codebook carried over:
#   for every column whose name is unchanged, its label, label source and role, and its type and
#   order when the data can still be them; and the row sentence. Returns read (data and problems),
#   profile, codebook and notes (a sentence for each type, order or role that had to be dropped).
reread_data <- function(path, name, missing, old = NULL, encoding = NULL) {
  r = read_data(path, name, missing, encoding)
  prof = profile_data(r$data)
  cb = new_codebook(prof, name, nrow(r$data), missing, r$encoding)
  if (is.null(old)) return(list(read = r, profile = prof, codebook = cb, notes = character(0)))
  before = stats::setNames(old$columns, purrr::map_chr(old$columns, "name"))
  carried = purrr::map(cb$columns, function(e) {
    o = before[[e$name]]
    if (is.null(o)) return(list(entry = e, note = NULL))
    out = e
    out$label = o$label
    out$label_source = o$label_source
    out$sure = if (identical(o$label_source, "ai_guess")) o$sure
    # Only what the analyst chose is carried: a type other than R's own, a role other than the
    #   type's default. What R chose before is chosen again from the data now.
    notes = character(0)
    own_type = !identical(o$type, o$detected %||% o$type)
    own_role = !identical(o$role, default_role(o, o$type))
    if (own_type && !identical(o$type, e$type)) {
      if (o$type %in% type_choices(e)) out = edit_entry(out, type = o$type)
      else notes = c(notes, paste0("You made ", e$name, " ", o$type, "; read again it cannot be, so it is ", e$type, "."))
    }
    if (identical(out$type, "ordered") && !is.null(o$order)) {
      if (order_ok(o$order, out)) out$order = o$order
      else notes = c(notes, paste0("The order you gave ", e$name, "'s levels no longer matches its levels, so it starts again."))
    }
    if (own_role) {
      if (o$role %in% role_choices(out)) out$role = o$role
      else notes = c(notes, paste0("You gave ", e$name, " the role ", o$role, ", which a column of type ", out$type,
                                   " cannot have, so it is ", out$role, "."))
    }
    list(entry = out, note = notes)
  })
  cb$columns = purrr::map(carried, "entry")
  cb$row_is = old$row_is %||% ""
  cb = codebook_source(cb, old$source)
  list(read = r, profile = prof, codebook = cb, notes = unlist(purrr::map(carried, "note")))
}

# One column of a codebook changed by the analyst. A new label marks it user; a new type keeps the
#   role if the type allows it, else gives the type's default, and for ordered starts the order.
edit_entry <- function(entry, label = NULL, type = NULL, role = NULL, order = NULL) {
  if (!is.null(label) && !identical(label, entry$label)) { entry$label = label; entry$label_source = "user"; entry$sure = NULL }
  if (!is.null(type) && !identical(type, entry$type) && type %in% type_choices(entry)) {
    entry$type = type
    if (!entry$role %in% role_choices(entry)) entry$role = default_role(entry, type)
    entry$order = if (identical(type, "ordered")) default_order(entry)
  }
  if (!is.null(role) && role %in% role_choices(entry)) entry$role = role
  if (!is.null(order) && identical(entry$type, "ordered") && order_ok(order, entry)) entry$order = order
  entry
}

# An AI guess the analyst accepts as it is: it becomes theirs.
accept_label <- function(entry) {
  if (identical(entry$label_source, "ai_guess")) { entry$label_source = "user"; entry$sure = NULL }
  entry
}

# The facts of a column as one short line for the page.
facts_text <- function(e) {
  range = switch(e$detected,
    date = paste0(e$min, " to ", e$max, if (!is.null(e$gap)) paste0(", usually ", e$gap, " apart")),
    integer = , number = paste0(format_num(e$min), " to ", format_num(e$max)),
    category = , flag = if (length(e$values)) paste(e$values, collapse = ", "),
    NULL)
  paste(c(sprintf("%.0f%% missing", 100 * e$missing), paste(e$distinct, "distinct"), range, e$note), collapse = "; ")
}

format_num <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE, drop0trailing = TRUE)


# ---- B4. what a model will be sent -------------------------------------------------------

# These read only the codebook, never the data, so a row cannot reach a prompt through them.

# One line per column: name, label, type, role, share missing.
codebook_index <- function(cb)
  purrr::map_chr(cb$columns, function(e)
    paste0(e$name, " | ", e$label, " | ", e$type, " | ", e$role, " | ", sprintf("%.2f", e$missing), " missing"))

# The detail of DESIGN.md section 4 for at most CODEBOOK_MAX_DETAIL named columns. An id or text
#   column, or a category with more than CODEBOOK_MAX_LEVELS levels, is a count of distinct values;
#   a number keeps its range and quartiles however many values it has.
codebook_detail <- function(cb, columns) {
  if (length(columns) > CODEBOOK_MAX_DETAIL)
    stop("At most ", CODEBOOK_MAX_DETAIL, " columns can be described at once; ", length(columns), " were asked for.", call. = FALSE)
  by_name = stats::setNames(cb$columns, purrr::map_chr(cb$columns, "name"))
  unknown = setdiff(columns, names(by_name))
  if (length(unknown)) stop("Not columns of this codebook: ", paste(unknown, collapse = ", "), ".", call. = FALSE)
  purrr::map_chr(columns, function(nm) {
    e = by_name[[nm]]
    head = paste0(e$name, " (", e$type, "): ")
    count_only = paste0(head, e$distinct, " distinct values")
    if (e$type %in% c("id", "text")) return(count_only)
    switch(e$type,
      number = , integer = paste0(head, "min ", format_num(e$min), ", max ", format_num(e$max), ", quartiles ",
                                  paste(format_num(e$quartiles), collapse = ", "), "; ", e$distinct, " distinct values"),
      date = paste0(head, "from ", e$min, " to ", e$max, if (!is.null(e$gap)) paste0(", most often ", e$gap, " apart")),
      category = , flag = , ordered = {
        if (is.null(e$values) || e$distinct > CODEBOOK_MAX_LEVELS) return(count_only)
        lv = if (identical(e$type, "ordered") && !is.null(e$order)) e$order else e$values
        n = e$counts[match(lv, e$values)]
        paste0(head, length(lv), " levels", if (identical(e$type, "ordered")) " in order", ": ",
               paste0(lv, " (", n, ")", collapse = ", "))
      },
      count_only)
  })
}
