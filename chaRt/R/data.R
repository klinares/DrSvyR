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
#   - it is one of the usual forms: negative while the rest of the column is not, or all nines (99, 999, 9999, ...), or nines
#     ending in 7 or 8 (97, 98, 997, 998: the usual codes for "refused" and "don't know"; night task 02), with or without a minus sign;
#   - it lies outside the rest of the column (the column without that value) by more than NUMERIC_CODE_IQR times the
#     interquartile range, beyond the quartile on its side. A real maximum of 999 that occurs once, or amid values of
#     that size, fails one of these.
#   Returns the values as the text of the button ("-99"), at most three, the most repeated first.
NUMERIC_CODE_ROWS <- 5L
NUMERIC_CODE_SHARE <- 0.01
NUMERIC_CODE_IQR <- 3
NUMERIC_CODE_FORM <- "^9{2,}$|^9+[78]$"
numeric_code_words <- function(x) {
  if (!is.numeric(x)) return(character(0))
  obs = sort(x[is.finite(x)])
  runs = rle(obs)
  repeated = runs$lengths >= 2L & (runs$lengths >= NUMERIC_CODE_ROWS | runs$lengths >= NUMERIC_CODE_SHARE * length(obs))
  as_code = function(v) format(v, scientific = FALSE, trim = TRUE)
  usual = function(v, rest)
    (v < 0 && min(rest) >= 0) || (v == round(v) && grepl(NUMERIC_CODE_FORM, as_code(abs(v))))
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

# The sentences about columns that hold for a delimited file and for a sheet: a column with nothing in it, and a column of text
#   whose values are mostly numbers.
column_problems <- function(data) {
  empty_cols = names(data)[purrr::map_lgl(as.list(data), function(x) nrow(data) > 0L && all(is.na(x)))]
  c(purrr::map_chr(empty_cols, function(nm) paste0("Column ", nm, " is entirely missing.")),
    unlist(purrr::imap(as.list(data), mostly_numbers_note)))
}

# readr guesses the delimiter when delim is NULL: readr passes it to vroom, whose help says it
#   then guesses from , tab space | : and ;. A file it cannot guess for (one column, say) is read
#   with a comma. Types are guessed from every row (guess_max = Inf). The values in `missing` are
#   added to DATA_NA; readr's `na` matches a whole cell, after the spaces around it are trimmed
#   (trim_ws), never part of one.
read_data <- function(path, name = basename(path), missing = character(), encoding = NULL, excel = NULL) {
  if (is_excel(name)) return(read_excel_data(path, name, missing, excel))
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
  problems = c(enc$note, names_fixed$notes, parse_note, column_problems(data),
               if (!nrow(data)) "The file has no rows.",
               if (ncol(data) == 1L) "The file has only one column; if it should have more, its delimiter may not be one readr recognises.")
  list(data = data, problems = as.character(problems), encoding = enc$encoding)
}


# ---- B1b. read an Excel sheet -------------------------------------------------------------------------------------
#   readxl reads the cells; this section decides which cells are the table. Nothing is written to the workbook (it is read,
#   and for .xlsx two of its XML parts are read as text, to find hidden sheets and merged cells). What the analyst may choose
#   is `excel` (read_data(excel =)): sheet (a name), header (a row number as Excel numbers rows), table (which of several on
#   the sheet, 1, 2, ...) and numbers (columns of text to read as numbers). Not given: the first sheet that is not hidden, the
#   header R finds, and, where a sheet holds more than one table, no table (the analyst is asked; R never guesses).

EXCEL_EXTENSIONS <- c("xlsx", "xls")
is_excel <- function(name) tolower(tools::file_ext(name)) %in% EXCEL_EXTENSIONS

# The longest piece of a cell's text shown in a sentence or a label.
EXCEL_SHOWN_CHARS <- 24L

# A number stored as text: digits with an optional sign, thousands commas, decimals and exponent. A value with a leading zero
#   ("007", a code or a zip) is never one.
NUMBER_TEXT <- "^[-+]?([0-9]+|[0-9]{1,3}(,[0-9]{3})+)([.][0-9]+)?([eE][-+]?[0-9]+)?$|^[-+]?[.][0-9]+$"
number_text_ok <- function(x) {
  v = trimws(x[!is.na(x)])
  length(v) > 0L && all(grepl(NUMBER_TEXT, v)) && !any(grepl("^[-+]?0[0-9]", v))
}
# The columns of text that hold only numbers (never applied: the chat offers them), and the numbers they hold.
text_number_columns <- function(data) names(data)[purrr::map_lgl(as.list(data), function(x) is.character(x) && number_text_ok(x))]
number_from_text <- function(x) as.numeric(gsub(",", "", trimws(x), fixed = TRUE))

# Column letters and numbers ("AB" is 28), and a range such as "B2:E10" as c(row1, column1, row2, column2).
excel_col_letter <- function(n)
  purrr::map_chr(n, function(k) if (k <= 26L) LETTERS[k] else paste0(excel_col_letter((k - 1L) %/% 26L), LETTERS[(k - 1L) %% 26L + 1L]))
excel_col_number <- function(txt)
  purrr::map_int(strsplit(toupper(txt), ""), function(ch) as.integer(sum(match(ch, LETTERS) * 26^(rev(seq_along(ch)) - 1))))
excel_ref <- function(ref) {
  p = strsplit(ref, ":", fixed = TRUE)[[1]]
  p = c(p, p)[1:2]
  as.integer(c(gsub("\\D", "", p[1]), excel_col_number(gsub("[^A-Za-z]", "", p[1])),
               gsub("\\D", "", p[2]), excel_col_number(gsub("[^A-Za-z]", "", p[2]))))
}
excel_range_text <- function(r1, c1, r2, c2) paste0(excel_col_letter(c1), r1, ":", excel_col_letter(c2), r2)

# Attributes and tags of an XML text, by pattern (the two parts read are simple and Excel writes them one way).
xml_unescape <- function(x) {
  x = gsub("&lt;", "<", x, fixed = TRUE)
  x = gsub("&gt;", ">", x, fixed = TRUE)
  x = gsub("&quot;", "\"", x, fixed = TRUE)
  x = gsub("&apos;", "'", x, fixed = TRUE)
  gsub("&amp;", "&", x, fixed = TRUE)
}
xml_tags <- function(xml, name) if (is.na(xml)) character(0) else regmatches(xml, gregexpr(paste0("<", name, "\\s[^>]*>"), xml))[[1]]
xml_attr <- function(tags, attr)
  purrr::map_chr(tags, function(tag) {
    m = regmatches(tag, regexec(paste0("\\s", attr, "=\"([^\"]*)\""), tag))[[1]]
    if (length(m) == 2L) xml_unescape(m[2]) else NA_character_
  })

# One part of an .xlsx (a zip) as text, read without unpacking the rest; NA when it is not there.
zip_text <- function(path, part) {
  dir = tempfile("xlpart")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE))
  got = suppressWarnings(tryCatch(utils::unzip(path, files = part, exdir = dir), error = function(e) character(0)))
  if (length(got)) paste(readLines(got[1], warn = FALSE, encoding = "UTF-8"), collapse = "") else NA_character_
}

# The sheets of a workbook in order: name, hidden (TRUE or FALSE; NA for an .xls, which does not say) and the part of the zip
#   that holds the sheet (NA for an .xls). For an .xlsx a sheet is hidden when workbook.xml says state="hidden" (or
#   "veryHidden") for it.
excel_workbook <- function(path) {
  names = readxl::excel_sheets(path)
  plain = data.frame(sheet = names, hidden = NA, part = NA_character_, stringsAsFactors = FALSE)
  if (!identical(readBin(path, "raw", 2L), as.raw(c(0x50, 0x4b)))) return(plain)
  tags = xml_tags(zip_text(path, "xl/workbook.xml"), "sheet")
  if (!identical(xml_attr(tags, "name"), names)) return(plain)
  rels = xml_tags(zip_text(path, "xl/_rels/workbook.xml.rels"), "Relationship")
  target = xml_attr(rels, "Target")[match(xml_attr(tags, "r:id"), xml_attr(rels, "Id"))]
  state = xml_attr(tags, "state")
  data.frame(sheet = names, hidden = !is.na(state) & state %in% c("hidden", "veryHidden"),
             part = ifelse(is.na(target), NA_character_, ifelse(startsWith(target, "/"), substring(target, 2L), paste0("xl/", target))),
             stringsAsFactors = FALSE)
}

# The merged ranges of one sheet of an .xlsx, each c(row1, column1, row2, column2); none for an .xls (readxl does not say).
excel_merges <- function(path, part) {
  if (is.na(part)) return(list())
  refs = xml_attr(xml_tags(zip_text(path, part), "mergeCell"), "ref")
  purrr::map(refs[!is.na(refs)], excel_ref)
}

# A sheet's cells as text from cell A1 (so a row number is the number Excel shows): `label` (the text of each cell, "" where
#   it is blank), the number of rows and columns. Dates come as their serial numbers here; this is only for finding the
#   table, and the table itself is read again with readxl's own types.
excel_grid <- function(path, sheet) {
  g = tryCatch(suppressMessages(readxl::read_excel(path, sheet = sheet, range = readxl::cell_limits(c(1L, 1L), c(NA_integer_, NA_integer_)),
                                                   col_names = FALSE, col_types = "text", .name_repair = "minimal")),
               error = function(e) NULL)
  if (is.null(g) || !nrow(g) || !ncol(g)) return(list(label = matrix("", 0L, 0L), nr = 0L, nc = 0L))
  m = as.matrix(g)
  m[is.na(m)] = ""
  m = matrix(trimws(m), nrow = nrow(m))
  list(label = m, nr = nrow(m), nc = ncol(m))
}

# Runs of TRUE as start and end positions.
true_runs <- function(flags) {
  r = rle(as.logical(flags))
  end = cumsum(r$lengths)
  data.frame(start = (end - r$lengths + 1L)[r$values], end = end[r$values])
}

# The blocks of cells on a sheet, found by blank columns and blank rows: columns first (side by side), then rows within each
#   (stacked). A block of one row (a title, a note, a source line) is not a table; a table has a header and a row. Returns
#   tables and notes, each with r1, c1, r2, c2 (the edges trimmed to cells that are not blank), tables in reading order.
excel_blocks <- function(label) {
  blank = if (length(label)) label == "" else matrix(TRUE, 0L, 0L)
  none = data.frame(r1 = integer(0), c1 = integer(0), r2 = integer(0), c2 = integer(0))
  if (!length(blank) || all(blank)) return(list(tables = none, notes = none))
  cols = true_runs(colSums(!blank) > 0)
  blocks = dplyr::bind_rows(purrr::map(seq_len(nrow(cols)), function(i) {
    part = blank[, cols$start[i]:cols$end[i], drop = FALSE]
    rows = true_runs(rowSums(!part) > 0)
    dplyr::bind_rows(purrr::map(seq_len(nrow(rows)), function(k) {
      cells = !blank[rows$start[k]:rows$end[k], cols$start[i]:cols$end[i], drop = FALSE]
      used = which(colSums(cells) > 0)
      data.frame(r1 = rows$start[k], c1 = cols$start[i] + min(used) - 1L, r2 = rows$end[k], c2 = cols$start[i] + max(used) - 1L)
    }))
  }))
  blocks = blocks[order(blocks$r1, blocks$c1), ]
  one_row = blocks$r1 == blocks$r2
  list(tables = blocks[!one_row, , drop = FALSE], notes = blocks[one_row, , drop = FALSE])
}

# The words shown for the cells of a row in a sentence or a list.
excel_shown <- function(x) {
  x = x[nzchar(x)]
  purrr::map_chr(x, function(v) if (nchar(v) > EXCEL_SHOWN_CHARS) paste0(substr(v, 1L, EXCEL_SHOWN_CHARS), "...") else v)
}

# The sheet list for the picker (names and row counts; hidden ones named as hidden) and the table list for the choice.
rows_word <- function(n) ifelse(n == 1L, " row", " rows")
excel_sheet_choices <- function(sheets)
  stats::setNames(sheets$sheet, paste0(sheets$sheet, " (", format_num(sheets$rows), rows_word(sheets$rows),
                                       if (anyNA(sheets$hidden)) "" else ifelse(sheets$hidden, ", hidden", ""), ")"))
excel_table_choices <- function(tables)
  stats::setNames(as.character(seq_len(nrow(tables))),
                  paste0("Table ", seq_len(nrow(tables)), ": ", tables$range, ", ", format_num(tables$rows), rows_word(tables$rows), ", starting ", tables$starts))

# A column of Excel dates and times: dates when every time is midnight.
excel_dates <- function(x) if (inherits(x, "POSIXct") && all(is.na(x) | format(x, "%H:%M:%S", tz = "UTC") == "00:00:00")) as.Date(x, tz = "UTC") else x

excel_unreadable <- function(name, e)
  stop("The file ", name, " could not be read as an Excel workbook: ", gsub("\\s+", " ", conditionMessage(e)), call. = FALSE)

# An Excel sheet read as read_data() reads a delimited file: list(data, problems, encoding) and `excel`, what was found and chosen
#   (sheets, sheet, tables, table, header, range, ask, hidden_known, numbers and opts, the choices that read the same again).
#   `data` is NULL while the analyst has not said which of several tables on the sheet (excel$ask is "table").
read_excel_data <- function(path, name, missing = character(), excel = NULL) {
  opts = excel %||% list()
  na = unique(c(DATA_NA, parse_missing(missing)))
  wb = tryCatch(excel_workbook(path), error = function(e) excel_unreadable(name, e))
  if (!nrow(wb)) excel_unreadable(name, simpleError("it has no sheets"))
  grids = stats::setNames(purrr::map(wb$sheet, function(s) tryCatch(excel_grid(path, s), error = function(e) excel_unreadable(name, e))), wb$sheet)
  sheets = data.frame(sheet = wb$sheet, hidden = wb$hidden, rows = unname(purrr::map_int(grids, function(g) sum(rowSums(g$label != "") > 0))),
                      stringsAsFactors = FALSE, row.names = NULL)
  visible = wb$sheet[!(wb$hidden %in% TRUE)]
  sheet = if (is_text1(opts$sheet)) opts$sheet else if (length(visible)) visible[1] else wb$sheet[1]
  if (!sheet %in% wb$sheet) stop("The workbook has no sheet called ", sheet, ".", call. = FALSE)
  grid = grids[[sheet]]
  merges = excel_merges(path, wb$part[match(sheet, wb$sheet)])
  blocks = excel_blocks(grid$label)
  tables = blocks$tables
  tables$range = excel_range_text(tables$r1, tables$c1, tables$r2, tables$c2)[seq_len(nrow(tables))]
  tables$rows = tables$r2 - tables$r1 + 1L
  tables$starts = purrr::map_chr(seq_len(nrow(tables)), function(i)
    paste(utils::head(excel_shown(grid$label[tables$r1[i], tables$c1[i]:tables$c2[i]]), 4L), collapse = ", "))
  notes = unname(purrr::map_chr(seq_len(nrow(blocks$notes)), function(i) {
    n = blocks$notes[i, ]
    paste0("Row ", n$r1, " (", if (n$c1 == n$c2) paste0(excel_col_letter(n$c1), n$r1) else excel_range_text(n$r1, n$c1, n$r2, n$c2), ") holds a single line of text outside any table (",
           paste(utils::head(excel_shown(grid$label[n$r1, n$c1:n$c2]), 3L), collapse = ", "), "); it was left out.")
  }))
  info = list(sheets = sheets, sheet = sheet, tables = tables, table = NULL, header = NULL, range = NULL, ask = NULL,
              hidden_known = !anyNA(wb$hidden), numbers = character(0), opts = list(sheet = sheet))
  lead = c(if (isTRUE(wb$hidden[match(sheet, wb$sheet)])) paste0("The sheet ", sheet, " is hidden in the workbook."),
           if (anyNA(wb$hidden) && nrow(wb) > 1L)
             "This is an .xls file, which does not say which sheets are hidden, so the sheet list cannot tell.",
           notes)
  if (!nrow(tables))
    return(list(data = tibble::tibble(), encoding = "UTF-8", excel = info,
                problems = c(lead, paste0("The sheet ", sheet, " holds no table: no block of cells with a header and at least one row."))))
  if (nrow(tables) > 1L && is.null(opts$table)) {
    info$ask = "table"
    return(list(data = NULL, encoding = "UTF-8", excel = info,
                problems = c(lead, paste0("The sheet ", sheet, " holds ", nrow(tables), " tables (blocks of cells set apart by a blank row or column). ",
                                          "Choose one; none is read until you do."))))
  }
  pick = if (is.null(opts$table)) 1L else suppressWarnings(as.integer(opts$table))
  if (is.na(pick) || pick < 1L || pick > nrow(tables))
    stop("The sheet ", sheet, " has no table ", opts$table, " (it has ", nrow(tables), ").", call. = FALSE)
  tb = tables[pick, ]
  info$table = pick
  if (nrow(tables) > 1L) info$opts$table = pick
  # The header: the first row of the table with text in most of its columns, once merged cells are filled across; or the row asked for.
  txt = purrr::reduce(merges, function(t, m) {
    if (m[4] > m[2] && m[1] <= grid$nr && m[2] <= grid$nc) t[m[1], m[2]:min(m[4], grid$nc)] = t[m[1], m[2]]
    t
  }, .init = grid$label)
  word = txt != "" & is.na(suppressWarnings(as.numeric(txt)))
  width = tb$c2 - tb$c1 + 1L
  in_cols = tb$c1:tb$c2
  most = which(2 * rowSums(word[tb$r1:tb$r2, in_cols, drop = FALSE]) > width)
  asked = opts$header
  if (!is.null(asked) && (!is.numeric(asked) || length(asked) != 1L || is.na(asked) || asked != round(asked) || asked < tb$r1 || asked > tb$r2))
    stop("Row ", paste(asked, collapse = " "), " is not a row of the table (rows ", tb$r1, " to ", tb$r2, " of the sheet ", sheet, "). Choose a row inside it.", call. = FALSE)
  hrow = if (!is.null(asked)) as.integer(asked) else if (length(most)) tb$r1 + most[1] - 1L else tb$r1
  info$header = hrow
  if (!is.null(asked)) info$opts$header = hrow
  top = txt[hrow, in_cols]
  below = if (hrow < tb$r2) txt[hrow + 1L, in_cols] else rep("", width)
  merged = any(purrr::map_lgl(merges, function(m) m[1] == hrow && m[4] > m[2] && m[2] <= tb$c2 && m[4] >= tb$c1))
  joined = merged && any(nzchar(below))
  header_names = if (joined) purrr::map2_chr(top, below, function(a, b) paste(unique(c(a, b)[nzchar(c(a, b))]), collapse = " ")) else top
  names_fixed = repair_names(header_names)
  first = hrow + 1L + joined
  info$range = if (first <= tb$r2) excel_range_text(first, tb$c1, tb$r2, tb$c2)
  above = hrow - tb$r1
  header_notes = c(if (is.null(asked) && !length(most))
                     paste0("No row of the table has text in most columns, so row ", hrow, " is read as the header; change it under 'Header is on row'."),
                   if (above > 0L) paste0(if (above == 1L) "Row " else "Rows ", tb$r1, if (above > 1L) paste0(" to ", hrow - 1L), " above the header ",
                                          if (above == 1L) "was" else "were", " left out."),
                   if (joined) paste0("The header joins the merged cells of row ", hrow, " with row ", hrow + 1L,
                                      " (for example ", excel_shown(header_names[nzchar(below)][1]), ")."))
  raw = if (first <= tb$r2)
    tryCatch(suppressWarnings(suppressMessages(readxl::read_excel(path, sheet = sheet, range = readxl::cell_limits(c(first, tb$c1), c(tb$r2, tb$c2)),
                                                                  col_names = FALSE, na = na, trim_ws = TRUE, guess_max = tb$r2 - first + 1L,
                                                                  .name_repair = "minimal"))),
             error = function(e) excel_unreadable(name, e))
  cols = if (is.null(raw)) rep(list(logical(0)), width)
         else c(as.list(raw), rep(list(rep(NA, nrow(raw))), max(0L, width - ncol(raw))))[seq_len(width)]
  data = tibble::as_tibble(stats::setNames(purrr::map(cols, excel_dates), names_fixed$names))
  offered = text_number_columns(data)
  wanted = intersect(as.character(opts$numbers %||% character(0)), offered)
  data[wanted] = purrr::map(as.list(data)[wanted], number_from_text)
  info$numbers = wanted
  if (length(wanted)) info$opts$numbers = wanted
  left = setdiff(offered, wanted)
  text_note = function(nm) paste0("Column ", nm, " holds only numbers, but the sheet stores them as text (for example ",
                                  paste0("'", utils::head(unique(as.list(data)[[nm]]), 2L), "'", collapse = ", "), "), so it is read as text. The chat offers to read it as numbers.")
  problems = c(lead, header_notes, names_fixed$notes,
               purrr::map_chr(left, text_note),
               purrr::map_chr(wanted, function(nm) paste0("Column ", nm, " was read as numbers: the sheet stores them as text.")),
               column_problems(data[setdiff(names(data), left)]),
               if (!nrow(data)) "The table has a header and no rows.",
               if (ncol(data) == 1L) "The table has only one column.")
  list(data = data, problems = as.character(problems), encoding = "UTF-8", excel = info)
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

profile_column <- function(x, name, weight = FALSE, design = FALSE) {
  if (is.factor(x)) x = as.character(x)
  if (!is.numeric(x) && !is.logical(x) && !is.character(x) && !inherits(x, c("Date", "POSIXt"))) x = as.character(x)
  rows = length(x)
  obs = x[!is.na(x)]
  distinct = length(unique(obs))
  type = detect_type(x, obs, distinct, rows, name)
  codes = if (type %in% c("integer", "number")) numeric_code_words(obs) else character(0)
  notes = c(if (identical(type, "integer")) c(if (distinct <= CODED_MAX_DISTINCT) CODED_NOTE, if (all_distinct(obs, distinct, rows)) DISTINCT_NOTE),
            if (length(codes)) codes_note(codes), if (weight) WEIGHT_NOTE, if (design) DESIGN_NOTE)
  detail = switch(type,
    date = date_facts(obs),
    flag = if (distinct) level_counts(obs),
    integer = c(number_facts(obs), if (distinct <= CODEBOOK_MAX_LEVELS) level_counts(obs),
                if (length(notes)) list(note = paste(notes, collapse = "; "))),
    number = c(number_facts(obs), if (length(notes)) list(note = paste(notes, collapse = "; "))),
    id = if (is_whole(obs)) number_facts(obs),
    category = level_counts(obs),
    NULL)
  c(list(name = name, type = type, missing = if (rows) round(mean(is.na(x)), 2) else 0, distinct = distinct), detail)
}

profile_data <- function(data) {
  sv = survey_columns(data)
  unname(purrr::imap(as.list(data), function(x, name) profile_column(x, name, weight = name %in% sv$weights, design = name %in% sv$design)))
}

# Night task 02: what the dictionary and the read message say of numeric codes for missing and of a survey's weight and design. chaRt applies
#   neither a code the analyst has not entered nor a weight: the codes count as numbers and every row counts once, and it says so. The texts
#   are drafts for the manager to approve (manager/task-02.done.md).
# A column of numbers that holds codes (numeric_code_words()), as the dictionary notes it.
codes_note <- function(words) paste0("holds ", paste(words, collapse = ", "), ", which look like codes for missing; they count as numbers until entered under 'Values that mean missing'")
# A survey weight: positive, and named as one ("wt", "pweight", "final_weight" ...); a column called just "weight" (or "weights") is one only
#   beside a design column or when its mean is within SURVEY_WEIGHT_NEAR of 1 (a weight scaled to the sample), so that a body weight in kg is not.
#   A design column: numeric, named as a stratum or a cluster ("stratum", "psu", "cluster", NHANES' "sdmvstra" ...).
SURVEY_WEIGHT_NAME <- "(^|_)(wt|wgt|wts|pwt|pweight|finalwt|fwt|perwt|wtfinal)($|_)|(survey|sampling|design|final)_?weights?"
SURVEY_WEIGHT_PLAIN <- "^weights?$"
SURVEY_WEIGHT_NEAR <- 0.5
SURVEY_DESIGN_NAME <- "(^|_)(stratum|strata|strat|psu|psus|cluster|varstrat|varunit|sdmvstra|sdmvpsu)($|_)"
WEIGHT_NOTE <- "looks like a survey weight; chaRt does not apply weights, so every row counts once"
DESIGN_NOTE <- "looks like a column of the survey's design (a stratum or a cluster); chaRt does not use it"
survey_columns <- function(data) {
  nm = names(data)
  low = tolower(nm)
  obs = purrr::map(as.list(data), function(x) if (is.numeric(x)) x[is.finite(x)] else numeric(0))
  design = nm[purrr::map_lgl(obs, function(o) length(o) > 0L) & grepl(SURVEY_DESIGN_NAME, low)]
  positive = purrr::map_lgl(obs, function(o) length(o) > 0L && all(o > 0))
  near_one = purrr::map_lgl(obs, function(o) length(o) > 0L && abs(mean(o) - 1) < SURVEY_WEIGHT_NEAR)
  weights = nm[positive & (grepl(SURVEY_WEIGHT_NAME, low) | (grepl(SURVEY_WEIGHT_PLAIN, low) & (length(design) > 0L | near_one)))]
  list(weights = weights, design = setdiff(design, weights))
}
# The read message's sentences on both (the chat says them when a file is read), or none.
MISSING_CODES_SAY <- "These columns of numbers hold values that look like codes for missing: "
MISSING_CODES_THEN <- "chaRt counts them as numbers, in every mean, share, histogram and headline, until you enter them under 'Values that mean missing'."
WEIGHTS_THEN <- "chaRt does not apply survey weights or the survey's design: every row counts once, so a chart describes the rows of this file, not a population."
read_cautions <- function(data) {
  codes = unlist(purrr::imap(as.list(data), function(x, nm) { w = numeric_code_words(x); if (length(w)) paste0(nm, " (", paste(w, collapse = ", "), ")") }))
  sv = survey_columns(data)
  named = function(cols, one, many) paste0(if (length(cols) == 1L) one else many, paste(cols, collapse = ", "))
  c(if (length(codes)) paste0(MISSING_CODES_SAY, paste(codes, collapse = "; "), ". ", MISSING_CODES_THEN),
    if (length(sv$weights) || length(sv$design))
      paste0(paste(c(if (length(sv$weights)) paste0(named(sv$weights, "Column ", "Columns "), if (length(sv$weights) == 1L) " looks like a survey weight" else " look like survey weights"),
                     if (length(sv$design)) paste0(named(sv$design, if (length(sv$weights)) "column " else "Column ", if (length(sv$weights)) "columns " else "Columns "),
                                                   " like the survey's design")), collapse = ", and "), ". ", WEIGHTS_THEN))
}

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

# The sheet an Excel file was read from, three more optional file-level fields (after row_is): `sheet`, `range` (the cells of the rows read,
#   such as "B4:F20", so the code of a chart can read just them) and `text_numbers` (the columns of text that were read as numbers). A
#   delimited file has none of them.
codebook_sheet <- function(cb, excel = NULL) {
  cb$sheet = NULL; cb$range = NULL; cb$text_numbers = NULL
  if (is.null(excel) || is.null(excel$sheet)) return(cb)
  append(cb, c(list(sheet = excel$sheet), if (is_text1(excel$range)) list(range = excel$range),
               if (length(excel$numbers)) list(text_numbers = as.list(excel$numbers))), after = match("row_is", names(cb)))
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
apply_codebook <- function(cb, profile, file, rows, encoding = "UTF-8", excel = NULL) {
  why = check_codebook(cb, profile)
  if (length(why)) stop(paste(why, collapse = " "), call. = FALSE)
  up = stats::setNames(cb$columns, purrr::map_chr(cb$columns, "name"))
  out = new_codebook(profile, file, rows, missing_codes(cb), encoding)
  out$row_is = if (is.character(cb$row_is) && length(cb$row_is) == 1L) cb$row_is else ""
  out = codebook_source(out, cb$source)
  out = codebook_sheet(out, excel)
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
reread_data <- function(path, name, missing, old = NULL, encoding = NULL, excel = NULL) {
  r = read_data(path, name, missing, encoding, excel)
  if (is.null(r$data)) return(list(read = r, profile = NULL, codebook = NULL, notes = character(0)))   # an Excel sheet with several tables: none chosen yet
  prof = profile_data(r$data)
  cb = codebook_sheet(new_codebook(prof, name, nrow(r$data), missing, r$encoding), r$excel)
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

# What the codebook page (and nothing else of the dashboard export) says about a column's values, from its dictionary entry
#   only, never from the data: a number's range and quartiles ("range"), a date's first and last day and usual gap ("dates"),
#   the level counts of a group of at most CODEBOOK_MAX_LEVELS levels ("levels"), and for an id, a text, a longer category or an
#   entry that has no summary the count of distinct values alone ("distinct"). No other value of a row is in the result.
column_summary <- function(e) {
  distinct = as.integer(e$distinct %||% NA_integer_)
  only = list(kind = "distinct", distinct = distinct)
  values = as.character(unlist(e$values))
  switch(e$type %||% "text",
    number = , integer = if (!is.null(e$min) && !is.null(e$max) && length(e$quartiles) == 3L)
      list(kind = "range", min = e$min, max = e$max, quartiles = as.numeric(unlist(e$quartiles)), note = e$note) else only,
    date = if (!is.null(e$min) && !is.null(e$max)) list(kind = "dates", min = e$min, max = e$max, gap = e$gap) else only,
    category = , ordered = , flag = if (length(values) && length(values) <= CODEBOOK_MAX_LEVELS && length(e$counts) == length(values)) {
      counts = as.integer(unlist(e$counts))
      order = as.character(unlist(e$order))
      at = if (identical(e$type, "ordered") && length(order) == length(values) && setequal(order, values)) match(order, values) else seq_along(values)
      list(kind = "levels", values = values[at], counts = counts[at])
    } else only,
    only)
}


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


# ---- B5. summary statistics ---------------------------------------------------------------
#   Descriptive statistics of the file, worked out by R from the data in hand and written to the screen, the CSV and the export. Nothing
#   here calls a model, and nothing here is sent to one. summary_table() gives the numbers (a tibble of raw numbers: sortable, and the
#   CSV is made from it); summary_blocks() writes them with the facts' number functions (fact_num(), fact_count(), fact_pct() of
#   R/spec.R) for the screen and the page; summary_csv() writes the CSV. The intervals assume a simple random sample.

# The line under every table that shows an interval, and the shorter one under a table with none (Kevin's wording, kept as it is).
SUMMARY_CI_NOTE <- paste("95% confidence intervals assume a simple random sample of independent rows. No weights or sample design are applied;",
                         "for clustered or weighted data the true intervals are usually wider. If the file is a complete count and not a sample,",
                         "an interval has no sampling meaning.")
SUMMARY_PLAIN_NOTE <- "Descriptive statistics of the rows in this file. No weights or sample design are applied."
SUMMARY_QUARTILE_NOTE <- "Quartiles use R's default rule (type 7: linear interpolation between the ordered values)."
SUMMARY_SCALE_PHRASE <- "treats the steps of the scale as equal"
SUMMARY_CI_HEADER <- "95% CI (SRS)"
SUMMARY_ALL_ROWS <- "All rows"
SUMMARY_SMALL_ROWS <- 5L                  # a group with fewer rows than this is marked
SUMMARY_SMALL_MARK <- "under 5 rows"
SUMMARY_SMALL_WARNING <- paste("A table shows statistics for groups of fewer than 5 rows, which can describe individuals. Nothing is hidden;",
                               "whether to publish them is your decision.")
SUMMARY_LEVELS_SHOWN <- 10L               # the most frequent levels shown for a group-like column that has more than CODEBOOK_MAX_LEVELS
SUMMARY_SCALE_MAX_DISTINCT <- CODED_MAX_DISTINCT   # a whole-number measure with this many different values or fewer is read as a score on a scale
SUMMARY_SCALE_MARK <- "†"            # the dagger after a mean, SD or interval that treats the steps of a scale as equal
SUMMARY_KIND_TITLES <- c(measure = "Numbers", group = "Groups and categories", time = "Dates and times", count = "Other columns")

# What a column is summarised as, from its dictionary entry and the data in hand: "measure" (a number, or a whole number that is not a
#   time), "group" (a category, an ordered category or a flag), "time" (a date or time, or a whole number with the time role, a year) and
#   "count" (an id, free text, anything else, or a column whose data cannot be what its type says): for these only n, missing and the
#   number of different values are written, never a value.
summary_kind <- function(e, x) {
  kind = switch(e$type %||% "text",
    number = "measure", integer = if (identical(e$role, "time")) "time" else "measure",
    date = "time", category = , flag = , ordered = "group", "count")
  ok = switch(kind, measure = is.numeric(x), time = inherits(x, c("Date", "POSIXt")) || is.numeric(x), group = TRUE, TRUE)
  if (ok) kind else "count"
}

# Whether a measure is read as a score on a scale (a rating, a Likert item, a 0 to 10 score): a whole-number column the analyst left as a
#   measure (type integer, role measure) that has at most SUMMARY_SCALE_MAX_DISTINCT different values and lies within a run of that many
#   consecutive whole numbers (1 to 5, 0 to 9), the columns the dictionary itself marks "may be a coded category" that are also an unbroken
#   run of steps. Its mean, SD and interval then carry the note that they treat the steps of the scale as equal. A column of whole numbers
#   with gaps (0, 5, 10, 15, 30 per cent) is a quantity, not a scale, and has no such note. A column typed ordered is shown by its levels
#   and shares, with no mean, so it needs no such note.
summary_scale <- function(e, x) {
  obs = if (is.numeric(x)) x[is.finite(x)] else numeric(0)
  identical(e$type, "integer") && identical(e$role, "measure") && length(obs) > 0L &&
    length(unique(obs)) <= SUMMARY_SCALE_MAX_DISTINCT && max(obs) - min(obs) + 1 <= SUMMARY_SCALE_MAX_DISTINCT
}

# The 95% interval of a mean, t times the standard error either way (a simple random sample, no finite population correction); NA when
#   there are fewer than two values or the standard deviation is 0 or not a number.
summary_t_ci <- function(obs) {
  n = length(obs)
  s = if (n >= 2L) stats::sd(obs) else NA_real_
  if (is.na(s) || s == 0) return(c(NA_real_, NA_real_))
  half = stats::qt(0.975, n - 1) * s / sqrt(n)
  mean(obs) + c(-half, half)
}

# The Wilson score interval of a share, k of n, written out (no continuity correction, so not prop.test): centre
#   (p + z^2 / 2n) / (1 + z^2 / n), half-width z / (1 + z^2 / n) * sqrt(p (1 - p) / n + z^2 / 4n^2), with z = qnorm(0.975).
summary_wilson <- function(k, n) {
  if (!isTRUE(n >= 1L)) return(c(NA_real_, NA_real_))
  z = stats::qnorm(0.975)
  p = k / n
  d = 1 + z^2 / n
  half = z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / d
  centre = (p + z^2 / (2 * n)) / d
  c(max(0, centre - half), min(1, centre + half))
}

# One row of the table's tibble with every field there is, NA (or FALSE) where the row has none.
SUMMARY_FIELDS <- list(column = NA_character_, label = NA_character_, kind = NA_character_, group = NA_character_, level = NA_character_,
                       rows = NA_integer_, n = NA_integer_, missing_n = NA_integer_, missing_share = NA_real_, distinct = NA_integer_,
                       mean = NA_real_, sd = NA_real_, min = NA_real_, q1 = NA_real_, median = NA_real_, q3 = NA_real_, max = NA_real_,
                       mean_ci_low = NA_real_, mean_ci_high = NA_real_,
                       levels = NA_integer_, count = NA_integer_, share = NA_real_, share_ci_low = NA_real_, share_ci_high = NA_real_,
                       first = NA_character_, last = NA_character_, gap = NA_character_, scale = FALSE, small = FALSE)

# The rows (as lists of fields) that one column's values `x` give, for the kind of column it is. `x` is what the group has of the column.
summary_rows <- function(e, x, kind, scale) {
  rows = length(x)
  base = function(n, ...) c(list(rows = rows, n = n, missing_n = rows - n, missing_share = if (rows) (rows - n) / rows else NA_real_), list(...))
  switch(kind,
    measure = {
      obs = x[is.finite(x)]
      n = length(obs)
      q = if (n) stats::quantile(obs, c(0.25, 0.5, 0.75), names = FALSE, type = 7) else rep(NA_real_, 3)
      ci = summary_t_ci(obs)
      list(base(n, distinct = length(unique(obs)), mean = if (n) mean(obs) else NA_real_, sd = if (n >= 2L) stats::sd(obs) else NA_real_,
                min = if (n) min(obs) else NA_real_, q1 = q[[1]], median = q[[2]], q3 = q[[3]], max = if (n) max(obs) else NA_real_,
                mean_ci_low = ci[[1]], mean_ci_high = ci[[2]], scale = scale))
    },
    group = {
      obs = as.character(x[!is.na(x)])
      n = length(obs)
      lv = summary_levels(e, obs)
      shown = if (length(lv$values) > CODEBOOK_MAX_LEVELS) {
        top = order(-lv$counts, seq_along(lv$counts))[seq_len(SUMMARY_LEVELS_SHOWN)]
        rest = setdiff(seq_along(lv$counts), top)
        list(values = c(lv$values[top], paste0("and ", length(rest), " others")), counts = c(lv$counts[top], sum(lv$counts[rest])))
      } else lv
      if (!length(shown$values)) return(list(base(n, distinct = 0L, levels = 0L)))
      purrr::map2(shown$values, shown$counts, function(v, k) {
        ci = summary_wilson(k, n)
        base(n, distinct = length(lv$values), levels = length(lv$values), level = v, count = as.integer(k), share = k / n,
             share_ci_low = ci[[1]], share_ci_high = ci[[2]])
      })
    },
    time = {
      obs = x[!is.na(x)]
      n = length(obs)
      if (!n) return(list(base(0L, distinct = 0L)))
      f = if (inherits(obs, c("Date", "POSIXt"))) date_facts(obs) else {
        u = sort(unique(obs))
        tab = if (length(u) > 1L) table(diff(u))
        c(list(min = format(min(obs), scientific = FALSE, trim = TRUE), max = format(max(obs), scientific = FALSE, trim = TRUE)),
          if (!is.null(tab)) list(gap = names(tab)[which.max(tab)]))
      }
      list(base(n, distinct = length(unique(obs)), first = f$min, last = f$max, gap = f$gap %||% NA_character_))
    },
    list(base(sum(!is.na(x)), distinct = length(unique(x[!is.na(x)])))))
}

# A group-like column's levels and their counts, most frequent first, but an ordered column in its own order (levels the data does not
#   hold are left out; any level the order does not name follows).
summary_levels <- function(e, obs) {
  if (!length(obs)) return(list(values = character(0), counts = integer(0)))
  lc = level_counts(obs)
  if (!identical(e$type, "ordered") || is.null(e$order)) return(lc)
  at = match(as.character(unlist(e$order)), lc$values)
  at = c(at[!is.na(at)], setdiff(seq_along(lc$values), at))
  list(values = lc$values[at], counts = lc$counts[at])
}

# The summary table, as a tibble of raw numbers with a row for each column (for a group-like column each level), the kind of column in
#   `kind`: measure (n, missing, mean, sd, min, q1, median, q3, max, the 95% interval of the mean), group (n, missing, the number of levels, each
#   level with its count, share and the share's 95% interval; more than CODEBOOK_MAX_LEVELS levels: the SUMMARY_LEVELS_SHOWN most
#   frequent and "and k others"), time (n, missing, first, last, the usual gap) and count (n, missing and the number of different values only).
#   Each column uses the rows it has: n differs by column. `measures` names the columns to summarise, in that order (NULL: every column of
#   the data); `by` names one group-like column of at most CODEBOOK_MAX_LEVELS levels, and then each measure has a row for each of its
#   levels and one for "All rows" (a row with no value in `by` is in "All rows" only); the other kinds are written once, as "All rows".
#   A group of fewer than SUMMARY_SMALL_ROWS rows has `small` TRUE. The values of a text, an id or any "count" column are never in it.
summary_table <- function(data, cb, measures = NULL, by = NULL) {
  entries = stats::setNames(cb$columns, purrr::map_chr(cb$columns, "name"))
  entries = entries[names(entries) %in% names(data)]
  chosen = measures %||% names(entries)
  unknown = setdiff(chosen, names(entries))
  if (length(unknown)) stop("Not columns of this file: ", paste(unknown, collapse = ", "), ".", call. = FALSE)
  if (!is.null(by)) {
    if (!is_text1(by) || !by %in% names(entries) || !identical(summary_kind(entries[[by]], data[[by]]), "group"))
      stop("A summary by group needs a column of categories, an ordered category or a flag; ", paste(by, collapse = ", "), " is not one.", call. = FALSE)
    if (length(unique(data[[by]][!is.na(data[[by]])])) > CODEBOOK_MAX_LEVELS)
      stop(by, " has more than ", CODEBOOK_MAX_LEVELS, " levels, too many to summarise by.", call. = FALSE)
  }
  by_x = if (!is.null(by)) as.character(data[[by]])
  groups = if (!is.null(by)) summary_levels(entries[[by]], by_x[!is.na(by_x)])$values
  one = function(name, group, idx) {
    e = entries[[name]]
    x = data[[name]][idx]
    kind = summary_kind(e, x)
    purrr::map(summary_rows(e, x, kind, kind == "measure" && summary_scale(e, data[[name]])), function(r)
      utils::modifyList(SUMMARY_FIELDS, c(list(column = name, label = e$label %||% name, kind = kind, group = group,
                                                small = !is.null(by) && !identical(group, SUMMARY_ALL_ROWS) && length(idx) < SUMMARY_SMALL_ROWS), r)))
  }
  everyone = seq_len(nrow(data))
  rows = unlist(purrr::map(chosen, function(name) {
    kind = summary_kind(entries[[name]], data[[name]])
    if (is.null(by)) return(one(name, NA_character_, everyone))
    if (!identical(kind, "measure")) return(one(name, SUMMARY_ALL_ROWS, everyone))
    c(unlist(purrr::map(groups, function(g) one(name, g, which(by_x == g))), recursive = FALSE), one(name, SUMMARY_ALL_ROWS, everyone))
  }), recursive = FALSE)
  out = dplyr::bind_rows(purrr::map(rows, tibble::as_tibble))
  attr(out, "summary") = list(by = by, by_label = if (!is.null(by)) entries[[by]]$label %||% by, by_missing = if (!is.null(by)) sum(is.na(by_x)) else 0L,
                              rows = nrow(data))
  out
}

# Whether the table shows an interval (and so carries the long note): the switch is on and the table has a measure or a group-like column.
summary_has_interval <- function(tb, ci = TRUE) isTRUE(ci) && any(tb$kind %in% c("measure", "group"))

# The lines under the table: first the note (the long one with the intervals, the short one without), then what applies to this table: the
#   quartile rule, the columns whose mean, SD and interval treat a scale's steps as equal, the groups of fewer than SUMMARY_SMALL_ROWS rows,
#   and the rows with no value in the `by` column.
summary_notes <- function(tb, ci = TRUE) {
  info = attr(tb, "summary") %||% list()
  scaled = unique(tb$label[tb$scale %in% TRUE])
  c(if (summary_has_interval(tb, ci)) SUMMARY_CI_NOTE else SUMMARY_PLAIN_NOTE,
    if (any(tb$kind == "measure")) SUMMARY_QUARTILE_NOTE,
    if (length(scaled)) paste0(SUMMARY_SCALE_MARK, " ", paste(scaled, collapse = ", "), " (mean, SD and interval): ", SUMMARY_SCALE_PHRASE, "."),
    if (any(tb$small %in% TRUE)) paste0("Groups marked '", SUMMARY_SMALL_MARK, "' have fewer than ", SUMMARY_SMALL_ROWS, " rows: ", "their statistics can describe individuals."),
    if (isTRUE(info$by_missing > 0L)) paste0(format_num(info$by_missing), if (info$by_missing == 1L) " row has" else " rows have", " no value for ", info$by_label,
                                              " and ", if (info$by_missing == 1L) "is" else "are", " in '", SUMMARY_ALL_ROWS, "' only."))
}

# How a cell is written, by the facts' functions (R/spec.R): a statistic to three significant digits with thousands separators, a count
#   whole, a share as a percentage to one decimal, text as it is; no value is a dash. `mark` puts the dagger after a statistic that
#   treats the steps of a scale as equal.
SUMMARY_DASH <- "–"
summary_num <- function(v, mark = FALSE) ifelse(is.na(v), SUMMARY_DASH, paste0(fact_num(v, TRUE), ifelse(mark, SUMMARY_SCALE_MARK, "")))
summary_cnt <- function(v) ifelse(is.na(v), SUMMARY_DASH, fact_count(v))
summary_pct <- function(v) ifelse(is.na(v), SUMMARY_DASH, fact_pct(100 * v))
summary_txt <- function(v) ifelse(is.na(v), SUMMARY_DASH, v)

# The table as text, in one block for each kind of column present (SUMMARY_KIND_TITLES): list(kind, title, table, right) where `table` is a
#   tibble of strings under the headers the reader sees and `right` says which columns are numbers (right-aligned). Numbers are written
#   by the facts' functions: a measure to three significant digits, a count whole, a share and a share missing as a percentage to one
#   decimal; a missing cell is a dash. A score on a scale has the dagger after its mean, SD and interval; a small group says so in its group cell.
#   With `ci` FALSE the interval columns are left out.
summary_blocks <- function(tb, ci = TRUE) {
  num = summary_num
  cnt = summary_cnt
  pct = summary_pct
  txt = summary_txt
  dash = SUMMARY_DASH
  missing_cell = function(d) ifelse(is.na(d$missing_n), dash, paste0(fact_count(d$missing_n), " (", ifelse(is.na(d$missing_share), dash, fact_pct(100 * d$missing_share)), ")"))
  who = function(d) ifelse(is.na(d$label) | d$label == d$column, d$column, paste0(d$label, " (", d$column, ")"))
  grouped = !is.null(attr(tb, "summary")$by)
  first_row = function(d) !duplicated(d$column)
  make = function(kind, d) {
    cols = switch(kind,
      measure = c(list(Column = who(d)), if (grouped) list(Group = ifelse(d$small, paste0(d$group, " (", SUMMARY_SMALL_MARK, ")"), d$group)),
                  list(n = cnt(d$n), Missing = missing_cell(d), Mean = num(d$mean, d$scale), SD = num(d$sd, d$scale), Min = num(d$min), Q1 = num(d$q1),
                       Median = num(d$median), Q3 = num(d$q3), Max = num(d$max)),
                  if (ci) stats::setNames(list(num(d$mean_ci_low, d$scale), num(d$mean_ci_high, d$scale)), paste(SUMMARY_CI_HEADER, c("low", "high")))),
      group = {
        f = first_row(d)
        c(list(Column = ifelse(f, who(d), ""), n = ifelse(f, cnt(d$n), ""), Missing = ifelse(f, missing_cell(d), ""), Levels = ifelse(f, cnt(d$levels), ""),
               Level = txt(d$level), Count = cnt(d$count), Share = pct(d$share)),
          if (ci) stats::setNames(list(pct(d$share_ci_low), pct(d$share_ci_high)), paste(SUMMARY_CI_HEADER, c("low", "high"))))
      },
      time = list(Column = who(d), n = cnt(d$n), Missing = missing_cell(d), First = txt(d$first), Last = txt(d$last), `Usual gap` = txt(d$gap)),
      list(Column = who(d), n = cnt(d$n), Missing = missing_cell(d), Distinct = cnt(d$distinct)))
    tab = tibble::as_tibble(cols, .name_repair = "minimal")
    list(kind = kind, title = SUMMARY_KIND_TITLES[[kind]], table = tab,
         right = !names(tab) %in% c("Column", "Group", "Level", "First", "Last", "Usual gap"))
  }
  kinds = intersect(names(SUMMARY_KIND_TITLES), unique(tb$kind))
  purrr::map(kinds, function(k) make(k, tb[tb$kind == k, ]))
}

# A text cell of a CSV that a spreadsheet would run as a formula (it starts with =, @, a tab or a return, or with + or - and is not a
#   number) gets an apostrophe in front, as the usual guard says; nothing else is changed.
csv_safe <- function(x) {
  x = as.character(x)
  risky = !is.na(x) & (grepl("^[=@\t\r]", x) | (grepl("^[-+]", x) & is.na(suppressWarnings(as.numeric(x)))))
  ifelse(risky, paste0("'", x), x)
}

# The table as a CSV that opens in Excel: UTF-8 with a byte-order mark (readr::write_excel_csv), the header on the first row (so a program
#   reads it as a table), raw numbers to six significant digits, an empty cell for none, and the note in a last column on every row (a
#   comment row above the header would make Excel and most readers take the comment for the header). A column header says "95% CI (SRS)".
#   `scale_note` and `small_group` say which rows carry those marks. With `ci` FALSE the interval columns are left out and the note is the short one.
#   `marking` (the export's classification marking, Phase 10) is written as a comment line, "# <marking>", before the header, after the byte-order mark: a reader
#   must skip that one line (readr::read_csv(skip = 1)); Excel shows it in the first cell. Without it (the Data page's download) the header is the first row.
summary_csv <- function(tb, ci = TRUE, file, marking = NULL) {
  keep = function(d, names) d[names]
  notes = summary_notes(tb, ci)
  note = paste(c(notes[1], if (any(tb$kind == "measure")) SUMMARY_QUARTILE_NOTE), collapse = " ")
  r = function(v) signif(v, FACT_DIGITS)
  out = tibble::tibble(column = csv_safe(tb$column), label = csv_safe(tb$label), kind = tb$kind, group = csv_safe(tb$group), level = csv_safe(tb$level),
                       rows = tb$rows, n = tb$n, missing = tb$missing_n, missing_share = r(tb$missing_share), distinct = tb$distinct,
                       mean = r(tb$mean), sd = r(tb$sd), min = r(tb$min), q1 = r(tb$q1), median = r(tb$median), q3 = r(tb$q3), max = r(tb$max),
                       `95% CI (SRS) low` = r(tb$mean_ci_low), `95% CI (SRS) high` = r(tb$mean_ci_high),
                       levels = tb$levels, count = tb$count, share = r(tb$share),
                       `share 95% CI (SRS) low` = r(tb$share_ci_low), `share 95% CI (SRS) high` = r(tb$share_ci_high),
                       first = tb$first, last = tb$last, usual_gap = tb$gap,
                       scale_note = ifelse(tb$scale %in% TRUE, paste("mean, SD and interval:", SUMMARY_SCALE_PHRASE), NA_character_),
                       small_group = ifelse(tb$small %in% TRUE, SUMMARY_SMALL_MARK, NA_character_), note = note)
  if (!isTRUE(ci)) out = out[!grepl("95% CI", names(out), fixed = TRUE)]
  readr::write_excel_csv(out, file, na = "")
  if (!is.null(marking)) marking_prepend(file, marking_comment(marking))
  invisible(file)
}

# One row for each column of a codebook page's summary table: the first row the summary table has for it (a group-like column's first
#   level carries n, missing and the number of levels too).
summary_per_column <- function(tb) tb[!duplicated(tb$column), ]
