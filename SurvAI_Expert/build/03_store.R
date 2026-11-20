# Step 3: data/store/survai.duckdb from data/markdown/ and data/catalog/ (and data/catalog/practools/
#   when present). No model, no network, no DuckDB extension. Runs at home and at work.
# Run from SurvAI_Expert/:  Rscript --no-init-file build/03_store.R
# Writes data/catalog/receipt.csv (rows and an md5 checksum per source and table) and compares it
#   with the receipt already there.

suppressPackageStartupMessages({ library(tidyverse); library(DBI); library(duckdb) })
source("R/retrieve.R")

CAT_DIR <- "data/catalog"
PRIVATE_SOURCES <- "practools"
STORE <- "data/store/survai.duckdb"
RECEIPT_CSV <- file.path(CAT_DIR, "receipt.csv")
MARKER_RX <- "^<!-- page \\d+ -->$"
FENCE_RX <- "^\\s*(?:[-*+]\\s+|\\d+[.)]\\s+)?`{3,}"
CODE_WEIGHTS <- c(task = 2, functions = 2, packages = 1, code = 1)
FORMULA_WEIGHTS <- c(name = 2, symbols = 1)

# ---- reading: UTF-8, every \r stripped, so a CRLF checkout builds the same store ----------------------------

read_cat <- function(name) {
  f = c(file.path(CAT_DIR, name), file.path(CAT_DIR, PRIVATE_SOURCES, name))
  map(f[file.exists(f)], function(x) read_csv(x, col_types = cols(.default = col_character()), na = character(),
                                              locale = locale(encoding = "UTF-8"), progress = FALSE)) |>
    list_rbind() |> mutate(across(everything(), function(v) str_remove_all(v, "\r")))
}

read_md <- function(path) str_remove(readLines(path, warn = FALSE, encoding = "UTF-8"), "\r$")

header_field <- function(l, field) {
  end = which(l == "---")[2]
  v = str_match(l[seq_len(coalesce(end, 1L))], sprintf("^%s:\\s?\"?(.*?)\"?$", field))[, 2]
  str_replace_all(coalesce(v[!is.na(v)][1], ""), fixed('\\"'), '"')
}

split_semi <- function(x) map(x, function(v) if (nzchar(v)) str_trim(str_split_1(v, ";")) else character())

# ---- tables ------------------------------------------------------------------------------------------------

slice_text <- function(l, a, b, drop) {
  n = seq.int(a, b)
  keep = !(n %in% drop) & !str_detect(l[n], MARKER_RX)
  str_trim(str_replace_all(paste(l[n][keep], collapse = "\n"), "\n{3,}", "\n\n"))
}

code_text <- function(l, a, b) {
  x = l[seq.int(a, b)]
  paste(x[!str_detect(x, FENCE_RX)], collapse = "\n")
}

pages_label <- function(a, b) case_when(is.na(a) ~ "", a == b ~ paste0("p. ", a), .default = paste0("pp. ", a, "-", b))

# Long term table (id, field, term) to (term, id, field, tf).
field_terms <- function(id, text, field) tibble(id = id, field = field, term = tokenize(text)) |> unnest(term) |> count(term, id, field, name = "tf")

weighted_terms <- function(ft, w, key) ft |> mutate(weight = tf * unname(w[field])) |> group_by(term, id) |>
  summarise(weight = sum(weight), .groups = "drop") |> arrange(term, id) |> rename(!!key := id)

build <- function(con) {
  man = read_cat("manifest.csv")
  present = file.exists(man$markdown)
  if (any(!present)) {
    message("Missing on disk, skipped: ", nrow(man) - sum(present), " documents")
    walk(sort(unique(man$source[!present])), function(s) message("  ", s, ": ", sum(man$source[!present] == s)))
  }
  man = man[present, ]
  lines = map(set_names(man$markdown, man$id), read_md)
  docs = man |> mutate(title = map_chr(lines, header_field, "title"), course_title = map_chr(lines, header_field, "course_title"),
                       across(c(pages, characters, equations, code_blocks, problems), as.integer), usd = as.numeric(usd))
  fur = read_cat("furniture.csv") |> filter(doc_id %in% docs$id)
  drop = fur |> transmute(doc_id, n = split_semi(lines)) |> unnest(n) |> mutate(n = as.integer(n))
  drop = split(drop$n, drop$doc_id)

  P = read_cat("passages.csv") |> filter(doc_id %in% docs$id) |>
    mutate(across(c(page_from, page_to, line_from, line_to, chars), as.integer), pages = pages_label(page_from, page_to))
  P$text = pmap_chr(list(P$doc_id, P$line_from, P$line_to), function(d, a, b) slice_text(lines[[d]], a, b, drop[[d]]))
  # duplicates: one row per text (spacing ignored, case kept: R is case-sensitive), a public source's passage kept before a private one's
  P = P |> arrange(source %in% PRIVATE_SOURCES, passage_id) |> mutate(key = str_squish(text), dup = duplicated(key) & nzchar(key))
  kept = P |> filter(!dup) |> select(-dup, -key)
  aliases = P |> filter(dup) |> select(alias_id = passage_id, alias_doc_id = doc_id, key) |>
    left_join(P |> filter(!dup) |> select(passage_id, key), by = "key") |> select(alias_id, passage_id, alias_doc_id) |> arrange(alias_id)
  kept = kept |> arrange(passage_id)

  Fm = read_cat("formulas.csv") |> filter(doc_id %in% docs$id) |>
    mutate(across(c(page, line_from, line_to), as.integer), general = as.logical(na_if(general, ""))) |> arrange(formula_id)
  K = read_cat("code.csv") |> filter(doc_id %in% docs$id) |>
    mutate(across(c(line_from, line_to, page), as.integer), across(c(is_output, parses), as.logical)) |> arrange(code_id)
  K$code = pmap_chr(list(K$doc_id, K$line_from, K$line_to), function(d, a, b) code_text(lines[[d]], a, b))
  # duplicates: one row per code text, a public source's block kept before a private one's. Output blocks
  #   (is_output) stay as they are: short outputs repeat by chance and the code index never looks at them.
  #   Kall keeps every block for the passage-level function terms below.
  Kall = K
  K = K |> arrange(source %in% PRIVATE_SOURCES, code_id) |>
    mutate(key = if_else(is_output, NA_character_, code), dup = !is.na(key) & nzchar(key) & duplicated(key))
  code_aliases = K |> filter(dup) |> select(alias_id = code_id, alias_doc_id = doc_id, key) |>
    left_join(K |> filter(!dup) |> select(code_id, key), by = "key") |> select(alias_id, code_id, alias_doc_id) |> arrange(alias_id)
  K = K |> filter(!dup) |> select(-dup, -key) |> arrange(code_id)
  # labels and functions of an alias's passage count for the passage it duplicates
  canon = function(pid) coalesce(aliases$passage_id[match(pid, aliases$alias_id)], pid)

  sym = Fm |> transmute(formula_id, s = split_semi(symbols)) |> unnest(s) |>
    transmute(formula_id, symbol = str_trim(str_extract(s, "^[^=]+")), meaning = str_trim(str_remove(s, "^[^=]+=\\s*"))) |>
    filter(nzchar(symbol))
  fns = K |> transmute(code_id, fn = split_semi(functions)) |> unnest(fn) |>
    transmute(code_id, package = str_match(fn, "^([A-Za-z0-9.]+):::?")[, 2], fn = str_remove(fn, "^[A-Za-z0-9.]+:::?"))
  tags = kept |> select(passage_id, tse, stage, design, kind, topic) |> pivot_longer(-passage_id, names_to = "facet") |>
    mutate(value = split_semi(value)) |> unnest(value) |> arrange(passage_id, facet, value)

  # keyword index: passages by field (weights applied in SQL, so tests can retune them), formula groups, code
  fname = Fm |> mutate(pid = canon(passage_id)) |> group_by(pid) |> summarise(x = paste(unique(name), collapse = " "))
  fnk = Kall |> mutate(pid = canon(passage_id)) |> group_by(pid) |> summarise(x = str_replace_all(paste(functions, collapse = " "), ";", " "))
  tf = list(field_terms(kept$passage_id, kept$heading_path, "heading"), field_terms(kept$passage_id, kept$description, "description"),
            field_terms(kept$passage_id, str_replace_all(paste(kept$topic, kept$topic_free), ";", " "), "topic"),
            field_terms(fname$pid, fname$x, "formula"), field_terms(fnk$pid, fnk$x, "fn"),
            field_terms(kept$passage_id, kept$text, "text")) |>
    list_rbind() |> filter(id %in% kept$passage_id) |> rename(passage_id = id) |> arrange(term, passage_id, field)
  G = Fm |> filter(nzchar(name)) |> distinct(group_id, .keep_all = TRUE)
  fterms = bind_rows(field_terms(G$group_id, G$name, "name"),
                     field_terms(sym$formula_id, sym$meaning, "symbols") |> mutate(id = Fm$group_id[match(id, Fm$formula_id)])) |>
    weighted_terms(FORMULA_WEIGHTS, "group_id")
  Kc = K |> filter(!is_output)
  cterms = bind_rows(field_terms(Kc$code_id, Kc$task, "task"), field_terms(Kc$code_id, str_replace_all(Kc$functions, ";", " "), "functions"),
                     field_terms(Kc$code_id, str_replace_all(Kc$packages, ";", " "), "packages"), field_terms(Kc$code_id, Kc$code, "code")) |>
    weighted_terms(CODE_WEIGHTS, "code_id")

  out = list(docs = docs, passages = kept |> mutate(text_hash = NA_character_), passage_aliases = aliases, code_aliases = code_aliases, passage_tags = tags,
             formulas = Fm, formula_symbols = sym, code = K, code_functions = fns, term_fields = tf,
             formula_terms = fterms, code_terms = cterms, vocabulary = read_cat("vocabulary.csv"), furniture = fur)
  iwalk(out, function(x, nm) dbWriteTable(con, nm, as.data.frame(x), overwrite = TRUE))
  dbExecute(con, "UPDATE passages SET text_hash = md5(text)")
  weigh_terms(con, FIELD_WEIGHTS)
  walk(INDEX[c("formula", "code")], function(ix) index_stats(con, ix))
  invisible(out)
}

# ---- receipt ------------------------------------------------------------------------------------------------

SOURCE_OF <- c(docs = "source", passages = "source", formulas = "source", code = "source", furniture = "source",
               passage_aliases = "split_part(alias_id, '/', 1)", code_aliases = "split_part(alias_id, '/', 1)", passage_tags = "split_part(passage_id, '/', 1)",
               formula_symbols = "split_part(formula_id, '/', 1)", code_functions = "split_part(code_id, '/', 1)",
               term_fields = "split_part(passage_id, '/', 1)", terms = "split_part(passage_id, '/', 1)",
               passage_len = "split_part(passage_id, '/', 1)", code_terms = "split_part(code_id, '/', 1)",
               code_len = "split_part(code_id, '/', 1)", term_stats = "'all'", formula_terms = "'all'", formula_len = "'all'",
               formula_term_stats = "'all'", code_term_stats = "'all'", field_weights = "'all'", vocabulary = "'all'")

receipt <- function(con) imap(SOURCE_OF, function(src, tbl) dbGetQuery(con, sprintf(paste(
  "SELECT '%s' AS tbl, src AS source, count(*) AS rows, md5(string_agg(h, '' ORDER BY h)) AS checksum",
  "FROM (SELECT %s AS src, md5(CAST(x AS VARCHAR)) AS h FROM %s x) GROUP BY src"), tbl, src, tbl))) |>
  list_rbind() |> mutate(rows = as.integer(rows)) |> arrange(source, tbl)

compare_receipt <- function(new) {
  if (!file.exists(RECEIPT_CSV)) return(message("No earlier receipt to compare with."))
  old = read_csv(RECEIPT_CSV, col_types = "ccic", locale = locale(encoding = "UTF-8"), progress = FALSE) |>
    mutate(across(where(is.character), function(v) str_remove_all(v, "\r")))
  d = full_join(old, new, by = c("tbl", "source"), suffix = c("_old", "_new")) |>
    filter(is.na(checksum_old) | is.na(checksum_new) | checksum_old != checksum_new | rows_old != rows_new)
  if (!nrow(d)) return(message("Receipt: identical"))
  message("Receipt: ", nrow(d), " table(s) differ:")
  walk(seq_len(nrow(d)), function(i) message(sprintf("  %s / %s: rows %s -> %s", d$source[i], d$tbl[i], d$rows_old[i], d$rows_new[i])))
}

main <- function() {
  t0 = Sys.time()
  dir.create(dirname(STORE), showWarnings = FALSE, recursive = TRUE)
  unlink(c(STORE, paste0(STORE, ".wal")))
  con = store_connect(STORE, read_only = FALSE)
  on.exit(dbDisconnect(con, shutdown = TRUE), add = TRUE)
  build(con)
  r = receipt(con)
  dbExecute(con, "CHECKPOINT")
  compare_receipt(r)
  write_csv(r, RECEIPT_CSV, eol = "\n")
  counts = r |> filter(tbl %in% c("docs", "passages", "passage_aliases", "formulas", "code", "code_aliases", "terms")) |>
    select(tbl, source, rows) |> pivot_wider(names_from = tbl, values_from = rows, values_fill = 0L)
  print(as.data.frame(counts))
  message(sprintf("Built in %.1f s; %s is %.1f MB.", as.numeric(difftime(Sys.time(), t0, units = "secs")), STORE, file.size(STORE) / 2^20))
}

if (sys.nframe() == 0L) main()
