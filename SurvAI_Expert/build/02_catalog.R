# 02_catalog.R -- HOME ONLY (.rscignore keeps build/ off Connect). Step 2 of the SurvAI_Expert
#   build: the converted markdown (data/markdown/, from 01_convert.R) is cut into passages, and its
#   display equations and code blocks are listed; then a model labels them. Run from SurvAI_Expert/:
#
#     Rscript --no-init-file build/02_catalog.R parse   # B-D on every document, no model call;
#                                                       #   labels already in the cache are kept
#     Rscript --no-init-file build/02_catalog.R label   # B-D, then E (labels) on LABEL_SCOPE
#
#   B passages  data/catalog/passages.csv   line ranges into the markdown, no text copied
#     furniture data/catalog/furniture.csv  recurring lines and setup chunks left out of passages
#   C formulas  data/catalog/formulas.csv   every $$...$$ that renders with katex
#   D code      data/catalog/code.csv       every fenced block, R parsed for packages and functions
#   E labels    columns of the three files, from BUILD_MODEL; every reply cached by prompt hash
#   Rows of PRIVATE_SOURCES go to data/catalog/<source>/ instead (git-ignored).
#   Helpers shared with step 1 (katex check, maths patterns, reply facts) are read from
#   01_convert.R, which is not run.

suppressPackageStartupMessages({
  library(dplyr)
  library(purrr)
  library(stringr)
  library(tibble)
  library(tidyr)
})


# ---- 1. settings ----------------------------------------------------------------------------------

BUILD_MODEL <- list(api = "openai", base_url = "https://openrouter.ai/api/v1", id = "google/gemma-4-31b-it")
BUILD_KEY_VAR <- "OPENROUTER_API_KEY"
# Formula labels: one call per formula group, a stronger model (the one of step 1).
FORMULA_MODEL <- list(api = "openai", base_url = "https://openrouter.ai/api/v1", id = "google/gemini-4-argon")
MODELS <- list(BUILD_MODEL, FORMULA_MODEL) |> (function(m) set_names(m, map_chr(m, "id")))()
BUILD_TEMPERATURE <- 0
BUILD_MAX_TOKENS <- 4096L

# The whole of step 2: these labels plus the figure lines of 01_convert.R (data/build/figures/).
COST_CAP_USD <- 15.5
EST_USD_CALL <- 0.002        # until 10 calls have been paid
FORMULA_EST_USD <- 0.007     # the same for formula calls (FORMULA_MODEL)
# FORMULA_MODEL labels the groups with the most members first, until the cap less this reserve;
#   BUILD_MODEL labels the groups left over (about 0.0003 USD a call).
FORMULA_RESERVE_USD <- 1.25
FORMULA_OUT_TOKENS <- 250    # for the estimate
IN_FLIGHT <- 8L
CALL_TIMEOUT_S <- 180
PASSAGES_PER_CALL <- 10L
CODE_PER_CALL <- 10L
PROMPT_TEXT_CHARS <- 4000L   # longest passage text sent
PROMPT_CODE_CHARS <- 2500L
PROMPT_CONTEXT_CHARS <- 1500L # each of the two passages before a formula's passage

# What "label" labels: "pilot" (LABEL_PILOT below) or "all"; and which kinds of label it asks for
#   (a kind left out keeps whatever labels the cache already holds).
LABEL_SCOPE <- "all"
LABEL_KINDS <- c("passage", "code", "formula")
LABEL_PILOT <- list(
  function(p) str_starts(p$doc_id, "jpsm/applied_sampling_SURV625/"),
  function(p) str_starts(p$doc_id, "jpsm/total_survey_error_SURV720/lectures/"),
  function(p) p$doc_id == "practools/practical_tools_textbook" & p$page_from >= 30 & p$page_to <= 70,
  function(p) str_starts(p$doc_id, "tidysurvey/10-"))

# Passages: a slide is one passage, consecutive slides with one title merge up to SLIDE_MERGE_CHARS;
#   other documents split at headings, MIN_CHARS to MAX_CHARS.
SLIDE_MERGE_CHARS <- 1800
MIN_CHARS <- 800
MAX_CHARS <- 2000
# Furniture: a line on FURNITURE_SHARE or more of a PDF's pages (digits ignored), PDFs of at least
#   FURNITURE_MIN_PAGES pages.
FURNITURE_SHARE <- 0.30
FURNITURE_MIN_PAGES <- 4L
NO_TEXT_LINE <- "*[No text on this page]*"

PRIVATE_SOURCES <- "practools"
MANIFEST_CSV <- "data/catalog/manifest.csv"
VOCAB_CSV <- "data/catalog/vocabulary.csv"
CAT_DIR <- "data/catalog"
CACHE_DIR <- "data/build/catalog_cache"
PROBLEMS_CSV <- "data/build/catalog_problems.csv"
FORMULA_PROBLEMS_CSV <- "data/build/formula_problems.csv"
CONVERT_R <- "build/01_convert.R"

cv <- new.env()
sys.source(CONVERT_R, envir = cv)   # definitions only: its main() runs only from Rscript


# ---- 2. reading a document ------------------------------------------------------------------------

unquote <- function(v) str_replace_all(str_replace_all(str_remove_all(v, '^"|"$'), fixed('\\"'), '"'), fixed("\\\\"), "\\")

# Header fields and the body lines (numbered as in the file) of one markdown file.
read_md <- function(path) {
  l = readLines(path, warn = FALSE, encoding = "UTF-8")
  end = which(l == "---")[2]
  m = str_match(l[2:(end - 1)], "^([a-z_]+):\\s?(.*)$")
  list(header = set_names(as.list(unquote(m[, 3])), m[, 2]),
       lines = tibble(n = seq_along(l), text = l) |> filter(n > end))
}

FENCE_RX <- "^\\s*(?:[-*+]\\s+|\\d+[.)]\\s+)?`{3,}"
OUTPUT_LANGS <- c("", "text", "output", "console", "plaintext", "txt")

# Per line: page, code block, display block, heading, table; then units (a paragraph, a heading,
#   a table, a display equation, a code block, a page marker), each with its lines.
classify <- function(lines) {
  n = nrow(lines)
  txt = lines$text
  fence = str_detect(txt, FENCE_RX)
  code_open = accumulate(fence, function(open, f) if (f) !open else open, .init = FALSE)[seq_len(n)]
  in_code = fence | code_open
  code_start = fence & !code_open
  marker = !in_code & str_detect(txt, "^<!-- page \\d+ -->$")
  dd = if_else(in_code, 0L, str_count(txt, fixed("$$")))
  disp_open = accumulate(dd %% 2L == 1L, function(open, odd) if (odd) !open else open, .init = FALSE)[seq_len(n)]
  in_disp = !in_code & (disp_open | str_detect(str_trim(txt), "^\\$\\$"))
  heading = !in_code & !in_disp & str_detect(txt, "^#{1,6}\\s+\\S")
  table = !in_code & !in_disp & !heading & str_detect(txt, "^\\s*\\|")
  blank = !in_code & !in_disp & str_trim(txt) == ""
  kind = case_when(in_code ~ "code", in_disp ~ "display", marker ~ "marker", heading ~ "heading",
                   table ~ "table", blank ~ "blank", .default = "para")
  block = case_when(kind == "code" ~ paste0("c", cumsum(code_start)),
                    kind == "display" ~ paste0("d", cumsum(in_disp & !disp_open)),
                    kind %in% c("marker", "heading", "para") ~ paste0(kind, lines$n),   # a prose line may be split from the next
                    kind == "blank" ~ "", .default = kind)
  unit = cumsum(block != lag(block, default = "") | block == "")
  lines |>
    mutate(page = if_else(marker, as.integer(str_match(txt, "^<!-- page (\\d+) -->$")[, 2]), NA_integer_),
           kind = kind, unit = unit, level = if_else(heading, str_length(str_extract(txt, "^#+")), NA_integer_)) |>
    fill(page, .direction = "down") |>
    filter(kind != "blank")
}

# Units with their facts; code units get language and is_output.
make_units <- function(cl) {
  u = cl |> group_by(unit) |>
    summarise(kind = first(kind), line_from = min(n), line_to = max(n), page = first(page),
              level = first(level), text = paste(text, collapse = "\n"), .groups = "drop") |>
    arrange(line_from)
  lang = if_else(u$kind == "code", tolower(coalesce(str_match(u$text, "^\\s*(?:[-*+]\\s+|\\d+[.)]\\s+)?`{3,}\\s*\\{?\\s*([A-Za-z0-9_+.-]*)")[, 2], "")), NA_character_)
  body = map_chr(u$text, function(t) paste(str_subset(strsplit(t, "\n", fixed = TRUE)[[1]], FENCE_RX, negate = TRUE), collapse = "\n"))
  hashed = map_lgl(body, function(b) { l = str_subset(strsplit(b, "\n", fixed = TRUE)[[1]], "\\S"); length(l) > 0 && all(str_detect(l, "^\\s*(##|\\[\\d+\\])")) })
  prev_r = lag(u$kind == "code" & lang %in% c("r"), default = FALSE)
  u |> mutate(lang = lang, body = body,
              is_output = kind == "code" & (hashed | (lang %in% OUTPUT_LANGS & prev_r)),
              heading = if_else(kind == "heading", str_squish(str_remove(str_remove(text, "^#+\\s*"), "\\s*\\{[^}]*\\}\\s*$")), NA_character_))
}

# Heading path in effect at each unit: a stack of six levels.
heading_paths <- function(u) {
  st = accumulate(seq_len(nrow(u)), function(s, i) {
    if (u$kind[i] != "heading") return(s)
    L = u$level[i]
    s[L] = u$heading[i]
    if (L < 6) s[(L + 1):6] = ""
    s
  }, .init = rep("", 6))[-1]
  map_chr(st, function(s) paste(str_trunc(s[nzchar(s)], 80), collapse = " > "))
}


# ---- 3. furniture and setup chunks -----------------------------------------------------------------

norm_line <- function(x) str_squish(tolower(str_replace_all(str_remove_all(x, "[*_`]"), "\\d+", "#")))

# Lines that recur on FURNITURE_SHARE of a PDF's pages. Headings (slide titles, the sections of an
#   R manual), code and maths are never furniture.
find_furniture <- function(cl, doc_id, n_pages) {
  if (is.na(n_pages) || n_pages < FURNITURE_MIN_PAGES) return(tibble())
  cand = cl |> filter(kind %in% c("para", "table"), !is.na(page)) |>
    mutate(norm = norm_line(text)) |> filter(nzchar(norm), str_length(norm) <= 120)
  if (!nrow(cand)) return(tibble())
  hot = cand |> group_by(norm) |> summarise(pages_with = n_distinct(page), .groups = "drop") |>
    filter(pages_with / n_pages >= FURNITURE_SHARE)
  cand |> semi_join(hot, by = "norm") |> group_by(norm) |>
    summarise(text = first(str_squish(text)), pages_with = n_distinct(page), lines = paste(n, collapse = ";"), .groups = "drop") |>
    transmute(doc_id = doc_id, kind = "furniture", text, norm, pages_with, pages_total = n_pages,
              share = round(pages_with / n_pages, 3), lines)
}

SETUP_HEADS <- c("library", "require", "p_load", "pacman::p_load", "knitr::opts_chunk$set", "opts_chunk$set")

# An R chunk whose every call is library()/require()/p_load() or knitr::opts_chunk$set() (possibly
#   inside suppressPackageStartupMessages() or suppressMessages()).
is_setup_chunk <- function(code) {
  ex = tryCatch(parse(text = code, keep.source = FALSE), error = function(e) NULL)
  if (is.null(ex) || !length(ex)) return(FALSE)
  ok = function(e) {
    if (!is.call(e)) return(FALSE)
    h = paste(deparse(e[[1]]), collapse = "")
    if (h %in% SETUP_HEADS) return(TRUE)
    h %in% c("suppressPackageStartupMessages", "suppressMessages", "invisible") && length(e) == 2 && ok(e[[2]])
  }
  all(map_lgl(as.list(ex), ok))
}


# ---- 4. passages ----------------------------------------------------------------------------------

# Greedy grouping of items in order. A new group starts at a hard break, at a soft break (a heading)
#   once the current group has min_c, or before an item that would carry it past max_c; never right
#   after a heading.
pack <- function(chars, hard, soft, after_heading, min_c, max_c) {
  st = accumulate(seq_along(chars), function(s, i) {
    new = s$cur > 0 && !after_heading[i] && (hard[i] || (soft[i] && s$cur >= min_c) || s$cur + chars[i] > max_c)
    if (new) list(g = s$g + 1L, cur = chars[i]) else list(g = s$g, cur = s$cur + chars[i])
  }, .init = list(g = 1L, cur = 0))[-1]
  map_int(st, "g")
}

# A group under TINY_CHARS (a lone title, a one-line section) joins the group after it when the two
#   fit in MAX_CHARS.
TINY_CHARS <- 200
merge_tiny <- function(g, chars) {
  gc = tapply(chars, g, sum)
  ids = as.integer(names(gc))
  target = accumulate(rev(seq_along(ids)), function(nxt, i) {
    if (i < length(ids) && gc[i] < TINY_CHARS && gc[i] + gc[[as.character(nxt)]] <= MAX_CHARS) nxt else ids[i]
  }, .init = NA_integer_)[-1] |> rev()
  target[match(g, ids)]
}

title_key <- function(t) str_squish(str_remove(tolower(coalesce(t, "")),
  "\\s*(\\(?\\s*(cont(inued|'d|d)?\\.?|\\d+)\\s*\\)?|[-:]\\s*\\d+|\\.\\.\\.|…)\\s*$"))

# Units of one document grouped into passages (one row per passage, with its line range).
make_passages <- function(u, slides) {
  u = u |> mutate(atom = accumulate(seq_len(n()), function(a, i) if (i > 1 && is_output[i] && kind[i - 1] == "code") a else i))
  atoms = u |> group_by(atom) |>
    summarise(line_from = min(line_from[chars > 0], Inf), line_to = max(line_to[chars > 0], -Inf),
              page_from = suppressWarnings(min(page[chars > 0], na.rm = TRUE)), page_to = suppressWarnings(max(page[chars > 0], na.rm = TRUE)),
              page = first(page), chars = sum(chars), kind = first(kind), level = first(level), heading = first(heading),
              path = first(path), only_no_text = all(str_trim(text[chars > 0]) == NO_TEXT_LINE), .groups = "drop")
  atoms$group = if (slides) {
    pages = atoms |> group_by(page) |> summarise(chars = sum(chars), title = first(na.omit(heading)), .groups = "drop")
    pk = accumulate(seq_len(nrow(pages)), function(s, i) {
      same = i > 1 && nzchar(title_key(pages$title[i])) && title_key(pages$title[i]) == s$key
      if (same && s$cur + pages$chars[i] <= SLIDE_MERGE_CHARS) list(g = s$g, cur = s$cur + pages$chars[i], key = s$key)
      else list(g = s$g + (i > 1), cur = pages$chars[i], key = title_key(pages$title[i]))
    }, .init = list(g = 1L, cur = 0, key = ""))[-1]
    map_int(pk, "g")[match(atoms$page, pages$page)]
  } else {
    top = suppressWarnings(min(atoms$level, na.rm = TRUE))
    # A group closes at a heading once it has MIN_CHARS (always at a top-level heading), or
    #   before an atom that would take it past MAX_CHARS; a heading stays with what follows it.
    pack(atoms$chars, hard = atoms$kind == "heading" & atoms$level %in% top, soft = atoms$kind == "heading",
         after_heading = lag(atoms$kind == "heading" & atoms$chars > 0, default = FALSE),
         min_c = MIN_CHARS, max_c = MAX_CHARS) |>
      merge_tiny(atoms$chars)
  }
  atoms |> filter(chars > 0) |> group_by(group) |>
    summarise(heading_path = first(path), page_from = suppressWarnings(min(page_from)), page_to = suppressWarnings(max(page_to)),
              line_from = min(line_from), line_to = max(line_to), chars = sum(chars), no_text = all(only_no_text), .groups = "drop") |>
    filter(!no_text) |>
    mutate(page_from = suppressWarnings(as.integer(if_else(is.finite(page_from), page_from, NA_real_))),
           page_to = suppressWarnings(as.integer(if_else(is.finite(page_to), page_to, NA_real_)))) |>
    select(-group, -no_text)
}


# ---- 5. formulas and code ----------------------------------------------------------------------------

EQN_RX <- "\\((\\d+(?:\\.\\d+)*[a-z]?)\\)"

formulas_of <- function(u, doc_id) {
  cand = u |> filter(kind %in% c("display", "para"), str_detect(text, fixed("$$")))
  if (!nrow(cand)) return(tibble())
  pmap(list(cand$text, cand$line_from, cand$line_to, cand$page), function(t, lf, lt, pg) {
    loc = str_locate_all(t, cv$DISPLAY_RX)[[1]]
    if (!nrow(loc)) return(NULL)
    tibble(raw = str_sub(t, loc[, 1], loc[, 2]),
           before = map_chr(loc[, 1], function(s) str_extract(str_sub(t, 1, s - 1), "[^\n]*$")),
           after = map_chr(loc[, 2], function(e) str_extract(str_sub(t, e + 1), "^[^\n]*")),
           line_from = lf, line_to = lt, page = pg)
  }) |> list_rbind() |>
    mutate(latex = str_trim(str_sub(raw, 3, -3)),
           eq_number = coalesce(str_match(latex, "\\\\tag\\*?\\{([^}]*)\\}")[, 2],
                                str_match(latex, paste0("^", EQN_RX))[, 2],
                                str_match(latex, paste0("(?:\\\\q?quad)?\\s*", EQN_RX, "\\s*$"))[, 2],
                                str_match(after, paste0("^\\s*", EQN_RX))[, 2],
                                str_match(before, paste0(EQN_RX, "\\s*$"))[, 2]),
           latex_norm = latex |> str_remove_all("\\\\tag\\*?\\{[^}]*\\}") |>
             str_remove(paste0("^\\s*", EQN_RX)) |> str_remove(paste0("(?:\\\\q?quad)?\\s*", EQN_RX, "\\s*$")) |>
             str_remove_all("\\\\(left|right)(?![A-Za-z])") |> str_remove_all("\\s+"),
           renders = !is.na(map_chr(latex, cv$kx, display = TRUE)),
           doc_id = doc_id) |>
    select(doc_id, page, line_from, line_to, latex, eq_number, latex_norm, renders)
}

# Every call in an expression tree.
calls_in <- function(x) {
  if (rlang::is_missing(x)) return(list())
  if (is.expression(x)) return(unlist(map(as.list(x), calls_in), recursive = FALSE))
  if (!is.call(x)) return(list())
  c(list(x), unlist(map(as.list(x)[-1], function(a) if (rlang::is_missing(a)) list() else calls_in(a)), recursive = FALSE))
}

# Packages named by library()/require()/p_load() calls.
loaded_packages <- function(ex) {
  cl = calls_in(ex)
  unlist(map(cl, function(e) {
    h = paste(deparse(e[[1]]), collapse = "")
    args = as.list(e)[-1]
    nm = names(args) %||% rep("", length(args))
    pick = function(a) if (is.symbol(a)) as.character(a) else if (is.character(a)) a else NULL
    if (h %in% c("library", "require", "requireNamespace", "loadNamespace") && length(args)) {
      if (isTRUE(args$character.only)) return(NULL)
      pick(args[[1]])
    } else if (h %in% c("p_load", "pacman::p_load")) {
      unlist(map(args[!nzchar(nm)], pick))
    } else NULL
  }))
}

R_KEYWORDS <- c("if", "for", "while", "function", "repeat", "switch", "return", "else")

r_names <- function(code) {
  ex = tryCatch(parse(text = code, keep.source = TRUE), error = function(e) NULL)
  if (!is.null(ex)) {
    pd = utils::getParseData(ex)
    pkgs = unique(c(pd$text[pd$token == "SYMBOL_PACKAGE"], loaded_packages(ex)))
    fns = unique(pd$text[pd$token == "SYMBOL_FUNCTION_CALL"])
    return(list(parses = TRUE, packages = pkgs, functions = fns))
  }
  pkgs = unique(c(str_match_all(code, "([A-Za-z][A-Za-z0-9.]*):::?")[[1]][, 2],
                  str_match_all(code, "(?:library|require)\\(\\s*['\"]?([A-Za-z][A-Za-z0-9.]*)")[[1]][, 2],
                  unlist(map(str_match_all(code, "p_load\\(([^)]*)\\)")[[1]][, 2], function(a) str_trim(str_remove_all(strsplit(a, ",")[[1]], "['\"]"))))))
  fns = setdiff(unique(str_match_all(code, "(?<![\\w.$@:])([A-Za-z.][A-Za-z0-9._]*)\\s*\\(")[[1]][, 2]), R_KEYWORDS)
  list(parses = FALSE, packages = pkgs[nzchar(pkgs)], functions = fns)
}

code_of <- function(u, doc_id) {
  cu = u |> filter(kind == "code")
  if (!nrow(cu)) return(tibble())
  nm = map2(cu$body, cu$lang %in% "r" & !cu$is_output, function(b, isr) if (isr) r_names(b) else list(parses = NA, packages = character(), functions = character()))
  tibble(doc_id = doc_id, language = if_else(nzchar(cu$lang), cu$lang, "none"), line_from = cu$line_from, line_to = cu$line_to,
         page = cu$page, is_output = cu$is_output, parses = map_lgl(nm, "parses"),
         packages = map_chr(nm, function(x) paste(x$packages, collapse = ";")),
         functions = map_chr(nm, function(x) paste(x$functions, collapse = ";")), body = cu$body)
}


# ---- 6. one document, then the corpus -----------------------------------------------------------------

pdf_is_slides <- function(d, page_chars) {
  root = cv$SOURCES[[d$source]]$root
  f = file.path(root, d$original)
  sz = if (file.exists(f)) tryCatch(pdftools::pdf_pagesize(f), error = function(e) NULL) else NULL
  if (!is.null(sz) && nrow(sz)) return(stats::median(sz$width) > stats::median(sz$height))
  stats::median(page_chars) < 900
}

catalog_doc <- function(d) {
  md = read_md(d$markdown)
  cl = classify(md$lines)
  is_pdf = str_detect(tolower(d$original), "[.]pdf$")
  is_qmd = str_detect(tolower(d$original), "[.](qmd|rmd)$")
  n_pages = if (is_pdf) as.integer(d$pages) else NA_integer_
  fur = find_furniture(cl, d$id, n_pages)
  fur_lines = if (nrow(fur)) as.integer(unlist(strsplit(fur$lines, ";"))) else integer()
  u = make_units(cl)
  setup = if (is_qmd) u |> filter(kind == "code", lang %in% "r", !is_output) |> filter(map_lgl(body, is_setup_chunk)) else u[0, ]
  setup_rows = if (nrow(setup)) tibble(doc_id = d$id, kind = "setup chunk", text = str_trunc(str_squish(setup$body), 120), norm = NA_character_,
                                       pages_with = NA_integer_, pages_total = NA_integer_, share = NA_real_,
                                       lines = map2_chr(setup$line_from, setup$line_to, function(a, b) paste(a:b, collapse = ";"))) else tibble()
  excl = c(fur_lines, unlist(map2(setup$line_from, setup$line_to, seq)))
  line_chars = cl |> mutate(ch = if_else(n %in% excl | kind == "marker", 0L, str_length(str_trim(text)))) |>
    group_by(unit) |> summarise(chars = sum(ch), .groups = "drop")
  u = u |> left_join(line_chars, by = "unit") |> mutate(path = heading_paths(u))
  slides = is_pdf && pdf_is_slides(d, u |> filter(!is.na(page)) |> group_by(page) |> summarise(c = sum(chars)) |> pull(c))
  p = make_passages(u, slides)
  p = p |> mutate(passage_id = sprintf("%s#p%04d", d$id, row_number()), doc_id = d$id, source = d$source, course = d$course,
                  doc_type = d$doc_type, .before = 1) |>
    select(passage_id, doc_id, source, course, doc_type, heading_path, page_from, page_to, line_from, line_to, chars)
  in_passage = function(lf) map_chr(lf, function(x) { k = which(p$line_from <= x & p$line_to >= x); if (length(k)) p$passage_id[k[1]] else NA_character_ })
  f = formulas_of(u, d$id)
  if (nrow(f)) f = f |> mutate(formula_id = sprintf("%s#f%03d", d$id, row_number()), passage_id = in_passage(line_from), .before = 1)
  k = code_of(u, d$id)
  if (nrow(k)) k = k |> mutate(code_id = sprintf("%s#c%03d", d$id, row_number()), passage_id = in_passage(line_from), .before = 1)
  list(passages = p, formulas = f, code = k, furniture = bind_rows(fur, setup_rows),
       slides = slides, title = md$header$title %||% "", course_title = md$header$course_title %||% "",
       lines = cl |> mutate(excluded = n %in% excl | kind == "marker") |> select(n, text, excluded))
}

catalog_all <- function(docs) {
  t0 = Sys.time()
  out = map(seq_len(nrow(docs)), function(i) {
    r = tryCatch(catalog_doc(docs[i, ]), error = function(e) { message("  failed: ", docs$id[i], ": ", conditionMessage(e)); NULL })
    if (i %% 50 == 0) message(sprintf("  %d/%d documents, %.1f min", i, nrow(docs), as.numeric(difftime(Sys.time(), t0, units = "mins"))))
    r
  }) |> set_names(docs$id) |> compact()
  list(passages = list_rbind(map(out, "passages")),
       formulas = list_rbind(map(out, "formulas")),
       code = list_rbind(map(out, "code")),
       furniture = list_rbind(map(out, "furniture")),
       docs = tibble(doc_id = names(out), slides = map_lgl(out, "slides"), title = map_chr(out, "title"),
                     course_title = map_chr(out, "course_title")),
       lines = map(out, "lines"))
}


# ---- 7. the model --------------------------------------------------------------------------------------

model_key <- function() {
  k = Sys.getenv(BUILD_KEY_VAR)
  if (!nzchar(k)) stop("Set the environment variable ", BUILD_KEY_VAR, " (in .Renviron) first.", call. = FALSE)
  k
}

model_chat <- function(system, key, m = BUILD_MODEL) {
  if (!identical(m$api, "openai")) stop("The model's api must be 'openai' (an OpenAI-style endpoint).", call. = FALSE)
  ellmer::chat_openai_compatible(
    base_url = m$base_url, name = sub("^[a-z]+://([^/]+).*$", "\\1", m$base_url), system_prompt = system,
    credentials = function() key, model = m$id, params = ellmer::params(temperature = BUILD_TEMPERATURE),
    echo = "none", api_args = list(max_tokens = BUILD_MAX_TOKENS, usage = list(include = TRUE)))
}

prompt_hash <- function(system, user, model_id = BUILD_MODEL$id) digest::digest(paste(model_id, system, user, sep = "\n\u0001\n"), algo = "sha256", serialize = FALSE)
cache_file <- function(h) file.path(CACHE_DIR, substr(h, 1, 2), paste0(h, ".json"))
cached <- function(h) { f = cache_file(h); if (file.exists(f)) jsonlite::read_json(f) else NULL }

spent_so_far <- function() {
  f = list.files(CACHE_DIR, pattern = "[.]json$", recursive = TRUE, full.names = TRUE)
  sum(map_dbl(f, function(x) as.numeric(jsonlite::read_json(x)$usd %||% 0))) + cv$figures_spent()
}

# Replies for jobs (system, user, hash), from the cache or from BUILD_MODEL, IN_FLIGHT at a time in
#   this one R process (chat_async, later::run_now), until COST_CAP_USD. Returns the reply text per
#   job (NA when not available) and keeps a tally in run.
get_replies <- function(jobs, key, run, est = EST_USD_CALL) {
  if (is.null(jobs$model_id)) jobs$model_id = BUILD_MODEL$id
  have = map(jobs$hash, cached)
  todo = which(map_lgl(have, is.null))
  if (length(todo) && is.null(key)) return(map_chr(have, function(x) x$text %||% NA_character_))
  groups = split(todo, ceiling(seq_along(todo) / IN_FLIGHT))
  loc = new.env()   # this batch's own cost per call: the models' prices differ
  loc$usd = 0
  loc$n = 0L
  walk(groups, function(ix) {
    per_call = if (loc$n >= 10) loc$usd / loc$n else est
    cap = run$cap %||% COST_CAP_USD
    if (isTRUE(run$stopped) || run$spent + length(ix) * per_call > cap) {
      if (!isTRUE(run$stopped)) message(sprintf("Stopped: the next calls would pass %.2f USD (%.3f spent).", cap, run$spent))
      run$stopped = TRUE
      return(invisible())
    }
    old = options(ellmer_timeout_s = CALL_TIMEOUT_S)
    on.exit(options(old), add = TRUE)
    state = new.env()
    state$out = vector("list", length(ix))
    state$done = rep(FALSE, length(ix))
    settle = function(i, v) { state$out[[i]] = v; state$done[[i]] = TRUE }
    iwalk(ix, function(j, i) {
      chat = model_chat(jobs$system[j], key, MODELS[[jobs$model_id[j]]])
      started = Sys.time()
      tryCatch(promises::then(chat$chat_async(jobs$user[j]),
                              onFulfilled = function(v) settle(i, tryCatch(cv$reply_facts(chat, v, started), error = function(e) list(error = cv$root_message(e, key)))),
                              onRejected = function(e) settle(i, list(error = cv$root_message(e, key)))),
               error = function(e) settle(i, list(error = cv$root_message(e, key))))
    })
    detect(seq_len(ceiling(2 * (CALL_TIMEOUT_S + 60))), function(k) { later::run_now(timeoutSecs = 0.5); all(state$done) })
    walk2(ix, state$out, function(j, r) {
      r = r %||% list(error = "no answer came back in time")
      run$calls = run$calls + 1L
      if (!is.null(r$error)) { run$errors = run$errors + 1L; message("  call failed: ", str_trunc(r$error, 150)); return(invisible()) }
      run$usd = run$usd + r$usd
      run$spent = run$spent + r$usd
      run$paid = run$paid + 1L
      loc$usd = loc$usd + r$usd
      loc$n = loc$n + 1L
      f = cache_file(jobs$hash[j])
      dir.create(dirname(f), recursive = TRUE, showWarnings = FALSE)
      jsonlite::write_json(list(kind = jobs$kind[j], text = r$text, usd = r$usd, tokens_in = r$tokens_in, tokens_out = r$tokens_out,
                                usd_reported = r$usd_reported, finish = r$finish, model = jobs$model_id[j],
                                at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S")), f, auto_unbox = TRUE, digits = NA)
      have[[j]] <<- list(text = r$text)
    })
    message(sprintf("  %d calls paid, %.3f USD this run (%.2f in step 2)", run$paid, run$usd, run$spent))
  })
  map_chr(have, function(x) x$text %||% NA_character_)
}


# ---- 8. labels -------------------------------------------------------------------------------------------

read_vocab <- function() utils::read.csv(VOCAB_CSV, stringsAsFactors = FALSE, encoding = "UTF-8")

vocab_block <- function(v, facets) paste(map_chr(facets, function(f) {
  r = v |> filter(facet == f)
  paste0(f, ":\n", paste0("  - ", r$value, ": ", r$definition, collapse = "\n"))
}), collapse = "\n")

SYSTEM_LABEL <- paste(
  "You label passages of survey methodology course materials for a searchable catalog.",
  "Use only the tag values listed, spelled exactly as listed. Reply with JSON only, no prose and no code fences.")

passage_text <- function(lines, lf, lt, limit = PROMPT_TEXT_CHARS) {
  t = lines |> filter(n >= lf, n <= lt, !excluded) |> pull(text) |> paste(collapse = "\n")
  str_trunc(str_replace_all(t, "\n{3,}", "\n\n"), limit)
}

passage_user <- function(v, items) paste0(
  "Tag vocabulary (facet: value: definition):\n", vocab_block(v, c("tse", "stage", "design", "kind", "topic")), "\n\n",
  "For each passage below return one JSON object with these fields:\n",
  "  id: the passage id as given\n",
  "  description: one sentence, at most 25 words, saying what the passage lets a survey researcher do or know\n",
  "  tse: up to 2 values from tse\n  stage: up to 2 values from stage\n  design: up to 2 values from design\n",
  "  kind: 1 to 3 values from kind\n",
  "  topic: 1 to 3 values from topic (\"other\" only when nothing fits)\n",
  "  topic_free: up to 3 short noun phrases in your own words\n",
  "Rules: a table or example that carries out a selection is stage \"sample selection\". A passage about computing an ",
  "estimate has tse \"none\" unless it discusses an error source. A reference list, bibliography or dataset ",
  "documentation is kind \"administrative\" and topic \"other\". Never exceed the number of values allowed for a field.\n",
  "Return a JSON array with one object per passage, in the order given.\n\nPassages:\n",
  jsonlite::toJSON(items, auto_unbox = TRUE, pretty = FALSE))

SYSTEM_FORMULA <- paste(
  "You label displayed equations from survey methodology course materials for a searchable catalog.",
  "Use only the tag values listed, spelled exactly as listed. Never rewrite the equation.",
  "Reply with one JSON object only, no prose and no code fences.")

formula_user <- function(v, course, doc, before, text, latex) paste0(
  "Tag vocabulary (facet: value: definition):\n", vocab_block(v, c("role", "design", "tse")), "\n\n",
  "Course: ", course, "\nDocument: ", doc, "\n\n",
  if (nzchar(before)) paste0("Text before the passage:\n", before, "\n\n") else "",
  "Passage:\n", text, "\n\nEquation (id f1):\n$$", latex, "$$\n\n",
  "Return one JSON object with these fields:\n",
  "  id: \"f1\"\n",
  "  name: a specific name, at most 10 words (e.g. \"Variance of the ratio estimator under SRS\")\n",
  "  role: one value from role\n  f_design: up to 2 values from design\n  f_tse: up to 2 values from tse\n",
  "  general: true when the equation is a symbolic statement that holds beyond one example; false when it is a ",
  "numeric worked instance or a step specific to one exercise\n",
  "  symbols: an array of {\"symbol\": ..., \"meaning\": ...}, ONLY for symbols whose meaning is stated in the text given; omit any other symbol\n",
  "  condition: when the equation applies, only if the text states it, else \"\"\n")

code_user <- function(items) paste0(
  "For each R code block below return one JSON object: id (as given) and task (one sentence: what the code does for a survey researcher).\n",
  "Return a JSON array with one object per block.\n\nBlocks:\n", jsonlite::toJSON(items, auto_unbox = TRUE, pretty = FALSE))

# A reply as a list of objects, or a string saying why not.
parse_reply <- function(txt) {
  if (is.na(txt)) return("no reply")
  t = str_trim(str_remove_all(txt, "^```(?:json)?\\s*|\\s*```$"))
  t = str_sub(t, str_locate(t, "[\\[{]")[1] %|% 1L, nchar(t))   # an array, or one object
  x = tryCatch(jsonlite::fromJSON(t, simplifyVector = FALSE), error = function(e) NULL)
  if (is.null(x) || !is.list(x)) return("not valid JSON")
  if (!is.null(names(x)) && !is.null(x$id)) x = list(x)
  x
}
`%|%` <- function(a, b) if (is.na(a)) b else a

as_tags <- function(x) unique(as.character(unlist(x %||% list())))

# Problems in one parsed reply: ids, tags in the vocabulary, counts.
check_reply <- function(x, ids, v, fields) {
  if (is.character(x)) return(x)
  got = map_chr(x, function(o) as.character(o$id %||% NA))
  if (!setequal(got, ids) || length(got) != length(ids)) return(sprintf("ids do not match (got %s)", paste(got, collapse = ",")))
  bad = unlist(map(x, obj_problems, v = v, fields = fields))
  if (length(bad)) paste(unique(bad), collapse = "; ") else character(0)
}

# Problems of one object, each naming the object and the limit broken. A field's spec is c(min, max)
#   values, or "logical" (true or false). f_design and f_tse take the design and tse vocabulary.
obj_problems <- function(o, v, fields) {
  id = as.character(o$id %||% "?")
  unlist(imap(fields, function(lim, f) {
    if (identical(lim, "logical")) return(if (!(isTRUE(o[[f]]) || isFALSE(o[[f]]))) sprintf("%s: %s must be true or false", id, f))
    t = as_tags(o[[f]])
    facet = sub("^f_", "", f)
    limit = if (lim[1] == lim[2]) sprintf("exactly %d", lim[1]) else if (lim[1] > 0) sprintf("%d to %d", lim[1], lim[2]) else sprintf("at most %d", lim[2])
    c(if (length(t) < lim[1] || length(t) > lim[2]) sprintf("%s: %s has %d values, %s allowed", id, f, length(t), limit),
      if (facet %in% v$facet) { out = setdiff(t, v$value[v$facet == facet]); if (length(out)) sprintf("%s: %s not in the vocabulary: %s", id, f, paste(out, collapse = ", ")) })
  }))
}

# After the retry: the objects of a reply that are valid on their own (known id, tags in the
#   vocabulary, counts within limits) are kept; the rest are recorded as problems.
salvage <- function(x, ids, v, fields) {
  if (is.character(x)) return(list(keep = NULL, why = x, lost = ids))
  ok = map_lgl(x, function(o) as.character(o$id %||% NA) %in% ids && !length(obj_problems(o, v, fields)))
  got = map_chr(x[ok], function(o) as.character(o$id))
  ok = ok & !duplicated(map_chr(x, function(o) as.character(o$id %||% NA)))
  list(keep = x[ok], lost = setdiff(ids, got),
       why = paste(unique(unlist(map(x[!ok], obj_problems, v = v, fields = fields))), collapse = "; "))
}

retry_user <- function(user, why) paste0(user, "\n\nYour previous reply was not valid: ", why, ". Reply again with JSON only, following the format and the limits exactly.")

# Jobs -> replies -> one retry for invalid replies -> parsed objects per job (the valid ones only
#   when the retry is still invalid).
run_jobs <- function(jobs, key, run, v, est = EST_USD_CALL) {
  if (!nrow(jobs)) return(list())
  if (is.null(jobs$model_id)) jobs$model_id = BUILD_MODEL$id
  jobs$hash = pmap_chr(list(jobs$system, jobs$user, jobs$model_id), prompt_hash)
  r1 = get_replies(jobs, key, run, est)
  p1 = map(r1, parse_reply)
  why1 = pmap(list(p1, jobs$ids, jobs$fields), function(x, ids, f) check_reply(x, ids, v, f))
  bad = which(map_lgl(why1, function(w) length(w) > 0) & !is.na(r1))
  out = map2(p1, why1, function(x, w) if (length(w)) NULL else x)
  if (length(bad)) {
    j2 = jobs[bad, ] |> mutate(user = map2_chr(user, why1[bad], retry_user))
    j2$hash = pmap_chr(list(j2$system, j2$user, j2$model_id), prompt_hash)
    r2 = get_replies(j2, key, run, est)
    p2 = map(r2, parse_reply)
    why2 = pmap(list(p2, j2$ids, j2$fields), function(x, ids, f) check_reply(x, ids, v, f))
    sv = pmap(list(p2, j2$ids, j2$fields), function(x, ids, f) salvage(x, ids, v, f))
    out[bad] = pmap(list(p2, why2, sv), function(x, w, s) if (!length(w)) x else s$keep)
    run$invalid1 = run$invalid1 + length(bad)
    still = which(map_lgl(why2, function(w) length(w) > 0) & !is.na(r2))
    if (length(still)) run$problems = bind_rows(run$problems, tibble(
      kind = jobs$kind[bad[still]], ids = map2_chr(sv[still], jobs$real[bad[still]], function(s, r) paste(r[as.integer(str_remove(s$lost, "^[a-z]"))], collapse = ";")),
      kept = map_int(sv[still], function(s) length(s$keep)),
      reason = map_chr(still, function(i) if (nzchar(sv[[i]]$why)) sv[[i]]$why else paste(why2[[i]], collapse = "; ")),
      reply = str_trunc(str_squish(r2[still]), 300)))
  }
  run$unanswered = run$unanswered + sum(is.na(r1))
  out
}

flat <- function(x) paste(as_tags(x), collapse = ";")

# Label columns, empty, so the joins work when nothing is labelled yet.
EMPTY_LP <- tibble(passage_id = character(), description = character(), tse = character(), stage = character(),
                   design = character(), kind = character(), topic = character(), topic_free = character())
EMPTY_LF <- tibble(group_id = character(), f_model = character(), name = character(), role = character(), f_design = character(),
                   f_tse = character(), general = logical(), symbols = character(), condition = character())
EMPTY_LC <- tibble(code_id = character(), task = character())

label_passages <- function(P, cat, key, run, v) {
  if (!nrow(P)) return(EMPTY_LP)
  docs = cat$docs
  items = pmap(list(P$passage_id, P$doc_id, P$heading_path, P$line_from, P$line_to), function(pid, did, hp, lf, lt) {
    d = docs[docs$doc_id == did, ]
    list(id = pid, course = d$course_title, document = d$title, heading = hp, text = passage_text(cat$lines[[did]], lf, lt))
  })
  batches = split(seq_along(items), ceiling(seq_along(items) / PASSAGES_PER_CALL))
  jobs = tibble(kind = "passage", system = SYSTEM_LABEL,
                user = map_chr(batches, function(b) passage_user(v, map(seq_along(b), function(i) modifyList(items[[b[i]]], list(id = paste0("p", i)))))),
                ids = map(batches, function(b) paste0("p", seq_along(b))), real = map(batches, function(b) P$passage_id[b]),
                fields = list(list(tse = c(0, 2), stage = c(0, 2), design = c(0, 2), kind = c(1, 3), topic = c(1, 3), topic_free = c(0, 3))))
  res = run_jobs(jobs, key, run, v)
  map2(batches, res, function(b, x) {
    if (is.null(x) || is.character(x)) return(NULL)
    map_dfr(x, function(o) tibble(passage_id = P$passage_id[b[as.integer(str_remove(o$id, "^p"))]],
                                  description = str_squish(as.character(o$description %||% "")), tse = flat(o$tse), stage = flat(o$stage),
                                  design = flat(o$design), kind = flat(o$kind), topic = flat(o$topic), topic_free = flat(o$topic_free)))
  }) |> list_rbind() |> (function(x) bind_rows(EMPTY_LP, x))()
}

# One instance per formula group: the member whose passage is longest. Its prompt carries that
#   passage, the two passages before it in the same document, the document title and course.
formula_jobs <- function(F, Pall, cat, v) {
  pidx = Pall |> group_by(doc_id) |> mutate(k = row_number()) |> ungroup() |> select(passage_id, doc_id, k, chars, line_from, line_to)
  members = F |> count(group_id, name = "members")
  inst = F |> left_join(select(pidx, passage_id, pchars = chars), by = "passage_id") |>
    arrange(group_id, desc(coalesce(pchars, -1L)), formula_id) |> distinct(group_id, .keep_all = TRUE) |>
    left_join(members, by = "group_id") |> arrange(desc(members), group_id)
  docs = cat$docs
  tibble(kind = "formula", system = SYSTEM_FORMULA, model_id = FORMULA_MODEL$id, group_id = inst$group_id,
         user = pmap_chr(list(inst$doc_id, inst$passage_id, inst$latex), function(did, pid, latex) {
           d = docs[docs$doc_id == did, ]
           lines = cat$lines[[did]]
           p = pidx[pidx$passage_id %in% pid, ]
           text = if (nrow(p)) passage_text(lines, p$line_from, p$line_to) else ""
           prev = if (nrow(p)) pidx |> filter(doc_id == did, k %in% (p$k - 2:1)) |> arrange(k) else pidx[0, ]
           before = paste(map2_chr(prev$line_from, prev$line_to, function(a, b) passage_text(lines, a, b, PROMPT_CONTEXT_CHARS)), collapse = "\n\n")
           formula_user(v, d$course_title, d$title, before, text, latex)
         }),
         ids = list("f1"), real = map(inst$group_id, function(g) g),
         fields = list(list(role = c(1, 1), f_design = c(0, 2), f_tse = c(0, 2), general = "logical")))
}

# FORMULA_MODEL first, in order of group size, up to COST_CAP_USD - FORMULA_RESERVE_USD; every
#   group it did not label (not reached, or still invalid after the retry) goes to BUILD_MODEL with
#   the same prompt. On a rerun each group takes the FORMULA_MODEL reply from the cache if there is one.
label_formulas <- function(F, Pall, cat, key, run, v) {
  if (!nrow(F)) return(EMPTY_LF)
  jobs = formula_jobs(F, Pall, cat, v)
  run$cap = COST_CAP_USD - FORMULA_RESERVE_USD
  res = run_jobs(jobs, key, run, v, est = FORMULA_EST_USD)
  run$cap = NULL
  run$stopped = FALSE
  done = map_lgl(res, function(x) !is.null(x) && !is.character(x) && length(x) > 0)
  if (any(!done)) {
    rest = jobs[!done, ] |> mutate(model_id = BUILD_MODEL$id)
    res[!done] = run_jobs(rest, key, run, v)
  }
  by = if_else(done, FORMULA_MODEL$id, BUILD_MODEL$id)
  pmap(list(jobs$group_id, res, by), function(g, x, m) {
    if (is.null(x) || is.character(x) || !length(x)) return(NULL)
    o = x[[1]]
    sy = keep(o$symbols %||% list(), is.list)
    tibble(group_id = g, f_model = m, name = str_squish(as.character(o$name %||% "")),
           role = flat(o$role), f_design = flat(o$f_design), f_tse = flat(o$f_tse), general = isTRUE(o$general),
           symbols = paste(map_chr(sy, function(s) paste0(s$symbol %||% "", " = ", s$meaning %||% "")), collapse = "; "),
           condition = str_squish(as.character(o$condition %||% "")))
  }) |> list_rbind() |> (function(x) bind_rows(EMPTY_LF, x))()
}

label_code <- function(K, P, key, run, v) {
  K = K |> filter(passage_id %in% P$passage_id, !is_output, language %in% "r")
  if (!nrow(K)) return(EMPTY_LC)
  batches = split(seq_len(nrow(K)), ceiling(seq_len(nrow(K)) / CODE_PER_CALL))
  jobs = tibble(kind = "code", system = SYSTEM_LABEL,
                user = map_chr(batches, function(b) code_user(map(seq_along(b), function(i) list(id = paste0("c", i), code = str_trunc(K$body[b[i]], PROMPT_CODE_CHARS))))),
                ids = map(batches, function(b) paste0("c", seq_along(b))), real = map(batches, function(b) K$code_id[b]),
                fields = list(list()))
  res = run_jobs(jobs, key, run, v)
  map2(batches, res, function(b, x) {
    if (is.null(x) || is.character(x)) return(NULL)
    map_dfr(x, function(o) tibble(code_id = K$code_id[b[as.integer(str_remove(o$id, "^c"))]], task = str_squish(as.character(o$task %||% ""))))
  }) |> list_rbind() |> (function(x) bind_rows(EMPTY_LC, x))()
}

# Calls not yet in the cache and their cost: formulas from prompt length at FORMULA_MODEL's price,
#   passages and code from the mean cost per call of that kind in the cache. No call is made.
estimate_calls <- function(scope, Fs, P, K, cat, v) {
  C = map_dfr(list.files(CACHE_DIR, pattern = "[.]json$", recursive = TRUE, full.names = TRUE), function(f) {
    j = jsonlite::read_json(f); tibble(kind = j$kind %||% NA, usd = as.numeric(j$usd %||% 0), model = j$model %||% NA) })
  per = C |> filter(model %in% BUILD_MODEL$id) |> group_by(kind) |> summarise(u = mean(usd), .groups = "drop")
  fj = formula_jobs(Fs, P, cat, v)
  fj$hash = pmap_chr(list(fj$system, fj$user, fj$model_id), prompt_hash)
  new_f = !file.exists(map_chr(fj$hash, cache_file))
  tokens_in = (nchar(fj$system) + nchar(fj$user))[new_f] / 3.6
  usd_f = sum(tokens_in * cv$PRICE_PER_M[["input"]] + FORMULA_OUT_TOKENS * cv$PRICE_PER_M[["output"]]) / 1e6
  n_p = ceiling(nrow(scope) / PASSAGES_PER_CALL)
  n_c = ceiling(sum(K$passage_id %in% scope$passage_id & !K$is_output & K$language %in% "r") / CODE_PER_CALL)
  est = tibble(kind = c("passage", "code", "formula"), calls = c(n_p, n_c, sum(new_f)),
               usd = c(n_p * per$u[per$kind == "passage"] * 1.3, n_c * per$u[per$kind == "code"], usd_f))
  print(as.data.frame(est))
  message(sprintf("Formula prompts: %.0f input tokens on average; %.2f USD spent in step 2, cap %.0f.", mean(tokens_in), spent_so_far(), COST_CAP_USD))
  est
}

in_scope <- function(p) {
  if (LABEL_SCOPE == "all") return(rep(TRUE, nrow(p)))
  reduce(map(LABEL_PILOT, function(f) coalesce(f(p), FALSE)), `|`)
}


# ---- 9. writing ------------------------------------------------------------------------------------------

write_split <- function(x, name) {
  priv = x$source %in% PRIVATE_SOURCES
  utils::write.csv(x[!priv, ], file.path(CAT_DIR, name), row.names = FALSE, na = "", fileEncoding = "UTF-8")
  walk(intersect(PRIVATE_SOURCES, unique(x$source)), function(s) {
    dir.create(file.path(CAT_DIR, s), showWarnings = FALSE)
    utils::write.csv(x[x$source == s, ], file.path(CAT_DIR, s, name), row.names = FALSE, na = "", fileEncoding = "UTF-8")
  })
}

read_split <- function(name) {
  f = c(file.path(CAT_DIR, name), file.path(CAT_DIR, PRIVATE_SOURCES, name))
  map(f[file.exists(f)], function(x) utils::read.csv(x, colClasses = "character", na.strings = NULL, encoding = "UTF-8")) |> list_rbind()
}

src_of <- function(id) str_extract(id, "^[^/]+")

main <- function(mode = "parse") {
  mode = match.arg(mode, c("parse", "label", "estimate", "relabel"))
  t0 = Sys.time()
  docs = utils::read.csv(MANIFEST_CSV, stringsAsFactors = FALSE, colClasses = "character") |> filter(file.exists(markdown))
  message(nrow(docs), " documents in the manifest with markdown.")
  cat = catalog_all(docs)
  bad_f = cat$formulas |> filter(!renders)
  utils::write.csv(bad_f, FORMULA_PROBLEMS_CSV, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  F = cat$formulas |> filter(renders) |> select(-renders) |>
    mutate(group_id = substr(map_chr(latex_norm, digest::digest, algo = "md5", serialize = FALSE), 1, 10))
  P = cat$passages
  K = cat$code
  message(sprintf("B-D done in %.1f min: %d passages, %d formulas (%d do not render), %d code blocks.",
                  as.numeric(difftime(Sys.time(), t0, units = "mins")), nrow(P), nrow(F), nrow(bad_f), nrow(K)))

  v = read_vocab()
  run = new.env()
  run$spent = spent_so_far(); run$usd = 0; run$calls = 0L; run$paid = 0L; run$errors = 0L
  run$invalid1 = 0L; run$unanswered = 0L; run$problems = tibble()
  key = if (mode %in% c("label", "relabel")) model_key() else NULL   # parse, estimate: labels from the cache only
  scope = P[in_scope(P), ]
  Fs = if (LABEL_SCOPE == "all") F else F |> filter(passage_id %in% scope$passage_id)
  if (mode == "estimate") return(invisible(estimate_calls(scope, Fs, P, K, cat, v)))
  kinds = if (mode == "relabel") "passage" else LABEL_KINDS
  key_for = function(kind) if (kind %in% kinds) key else NULL
  # relabel: only passages whose topic is "other" go to the model; every other passage keeps its label
  old = if (mode == "relabel") read_split("passages.csv") |> select(all_of(names(EMPTY_LP))) else EMPTY_LP
  if (mode == "relabel") scope = P |> filter(passage_id %in% old$passage_id[str_detect(old$topic, "(^|;)other(;|$)")])
  lp = label_passages(scope, cat, key_for("passage"), run, v)
  lp = bind_rows(lp, old |> filter(!passage_id %in% lp$passage_id))
  lc = label_code(K, P, key_for("code"), run, v)
  lf = label_formulas(Fs, P, cat, key_for("formula"), run, v)   # last: the dearest calls
  utils::write.csv(bind_rows(tibble(kind = character(), ids = character(), kept = integer(), reason = character(), reply = character()),
                             run$problems), PROBLEMS_CSV, row.names = FALSE, na = "", fileEncoding = "UTF-8")

  P = P |> left_join(lp, by = "passage_id")
  F = F |> left_join(lf, by = "group_id") |> mutate(source = src_of(doc_id), .after = doc_id)
  K = K |> select(-body) |> left_join(lc, by = "code_id") |> mutate(source = src_of(doc_id), .after = doc_id)
  fur = cat$furniture |> mutate(source = src_of(doc_id), .after = doc_id)
  write_split(P, "passages.csv")
  write_split(F, "formulas.csv")
  write_split(K, "code.csv")
  write_split(fur, "furniture.csv")
  message(sprintf("Labels: %d passages, %d formulas, %d code blocks in scope (%s); %d calls paid, %.3f USD this run, %.2f USD in step 2; %d replies invalid at first, %d still invalid, %d unanswered.",
                  nrow(scope), sum(F$passage_id %in% scope$passage_id), sum(K$passage_id %in% scope$passage_id & !K$is_output & K$language %in% "r"),
                  LABEL_SCOPE, run$paid, run$usd, run$spent, run$invalid1, nrow(run$problems), run$unanswered))
  message(sprintf("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
  invisible(list(P = P, F = F, K = K, furniture = fur, run = run))
}

if (sys.nframe() == 0L) main(head(c(commandArgs(trailingOnly = TRUE), "parse"), 1))
