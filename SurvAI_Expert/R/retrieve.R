# Keyword retrieval over data/store/survai.duckdb: BM25 in SQL, tags boost and never filter.
# Function definitions and constants only. Used by build/03_store.R, the app and tests/eval.R.
# Needs dplyr, purrr, stringr, DBI and duckdb attached by the caller.

# Tuned by tests/eval.R tune on half of the gold questions (start: heading 3, description 3, topic 2,
#   formula 2, fn 2, text 1; k1 1.2, b 0.75). Weights stay multiples of 0.5 so sums are exact.
FIELD_WEIGHTS <- c(heading = 0.5, description = 0.5, topic = 5, formula = 1, fn = 0, text = 0.5)
TAG_BOOST <- 0.15      # not tuned: the gold questions carry no tags
BM25_K1 <- 1.2
BM25_B <- 0.3
PARENT_WEIGHT <- 0.5   # share of the parent passage's score in find_formulas and find_code

# No DuckDB extension is ever installed or loaded, and nothing is written to the shared ~/.duckdb.
store_connect <- function(path, read_only = TRUE) dbConnect(duckdb(path, read_only = read_only, allow_extensions = FALSE, shared_home = FALSE))

STOP_WORDS <- c(
  "a", "about", "above", "after", "again", "all", "also", "am", "an", "and", "any", "are", "as", "at", "be",
  "because", "been", "before", "being", "below", "between", "both", "but", "by", "can", "could", "did", "do",
  "does", "doing", "down", "during", "each", "eg", "e.g", "etc", "few", "for", "from", "further", "get", "given",
  "had", "has", "have", "having", "he", "her", "here", "hers", "him", "his", "how", "i", "ie", "i.e", "if", "in",
  "into", "is", "it", "its", "itself", "just", "let", "may", "me", "might", "more", "most", "much", "must", "my",
  "no", "nor", "not", "now", "of", "off", "on", "once", "one", "only", "or", "other", "our", "ours", "out",
  "over", "own", "same", "shall", "she", "should", "so", "some", "such", "than", "that", "the", "their",
  "theirs", "them", "then", "there", "these", "they", "this", "those", "through", "to", "too", "under",
  "until", "up", "us", "use", "used", "using", "very", "via", "was", "we", "were", "what", "when", "where",
  "which", "while", "who", "whom", "why", "will", "with", "within", "would", "you", "your", "yours")

# Lower-case tokens; R names stay whole (as_survey_design, svydesign, poststratify); LaTeX commands,
#   numbers, single letters and stop words dropped; a plain plural "s" is removed.
tokenize <- function(x) {
  x = str_replace_all(coalesce(x, ""), "\\\\[A-Za-z]+", " ")
  map(str_extract_all(x, "[A-Za-z][A-Za-z0-9._]*[A-Za-z0-9]"), function(w) {
    w = tolower(w)
    str_replace(w[!w %in% STOP_WORDS], "(?<=[a-z]{3}[^siu])s$", "")
  })
}

# The three tables of an index: <terms>(term, id, weight), <len>(id, len), <stats>(term, df, idf).
INDEX <- list(passage = c(terms = "terms", stats = "term_stats", len = "passage_len", id = "passage_id"),
              formula = c(terms = "formula_terms", stats = "formula_term_stats", len = "formula_len", id = "group_id"),
              code = c(terms = "code_terms", stats = "code_term_stats", len = "code_len", id = "code_id"))

index_stats <- function(con, ix) {
  dbExecute(con, sprintf("CREATE OR REPLACE TABLE %s AS SELECT %s, sum(weight) AS len FROM %s GROUP BY ALL ORDER BY 1", ix[["len"]], ix[["id"]], ix[["terms"]]))
  dbExecute(con, sprintf(paste("CREATE OR REPLACE TABLE %s AS SELECT term, count(*) AS df,",
                               "ln(1 + ((SELECT count(*) FROM %s) - count(*) + 0.5) / (count(*) + 0.5)) AS idf FROM %s GROUP BY term ORDER BY term"),
                         ix[["stats"]], ix[["len"]], ix[["terms"]]))
}

# Passage term weights from term_fields(term, passage_id, field, tf) and the field weights.
weigh_terms <- function(con, w = FIELD_WEIGHTS) {
  dbWriteTable(con, "field_weights", tibble(field = names(w), w = unname(as.numeric(w))), overwrite = TRUE)
  dbExecute(con, paste("CREATE OR REPLACE TABLE terms AS SELECT term, passage_id, sum(tf * w) AS weight",
                       "FROM term_fields JOIN field_weights USING (field) GROUP BY ALL ORDER BY term, passage_id"))
  index_stats(con, INDEX$passage)
}

q_values <- function(con, q) paste0("(VALUES ", paste0("(", dbQuoteString(con, q), ")", collapse = ", "), ") AS q(term)")
q_list <- function(con, x) paste0("[", paste(dbQuoteString(con, x), collapse = ", "), "]")

# SQL for (id, bm25) over one index.
bm25_sql <- function(con, ix, q, k1 = BM25_K1, b = BM25_B) sprintf(paste(
  "SELECT t.%2$s, sum(s.idf * t.weight * (%4$f + 1) / (t.weight + %4$f * (1 - %5$f + %5$f * l.len / a.avgdl))) AS bm25",
  "FROM %1$s t JOIN %3$s ON t.term = q.term JOIN %6$s s ON s.term = t.term JOIN %7$s l ON l.%2$s = t.%2$s,",
  "(SELECT avg(len) AS avgdl FROM %7$s) a GROUP BY t.%2$s"),
  ix[["terms"]], ix[["id"]], q_values(con, q), k1, b, ix[["stats"]], ix[["len"]])

query_terms <- function(query) unique(unlist(tokenize(query)))

tag_where <- function(con, tags) {
  tags = keep(tags, function(v) length(v) > 0)
  if (!length(tags)) return("FALSE")
  paste(imap_chr(tags, function(v, f) sprintf("(facet = %s AND value IN (%s))", dbQuoteString(con, f), paste(dbQuoteString(con, v), collapse = ", "))),
        collapse = " OR ")
}

search_passages <- function(con, query, tags = list(), k = 12, k1 = BM25_K1, b = BM25_B, boost = TAG_BOOST) {
  q = query_terms(query)
  if (!length(q)) q = "\u0001"
  dbGetQuery(con, sprintf(paste(
    "WITH s AS (%s), g AS (SELECT passage_id, count(*) AS ntag FROM passage_tags WHERE %s GROUP BY passage_id)",
    "SELECT p.passage_id, p.doc_id, p.course, p.heading_path, p.pages, p.description,",
    "s.bm25 * (1 + %f * coalesce(g.ntag, 0)) AS score, p.text",
    "FROM s JOIN passages p USING (passage_id) LEFT JOIN g USING (passage_id) ORDER BY score DESC, p.passage_id LIMIT %d"),
    bm25_sql(con, INDEX$passage, q, k1, b), tag_where(con, tags), boost, as.integer(k))) |> as_tibble()
}

# The columns of one formula group (labels are the same on every member): every place it occurs.
FORMULA_GROUP_SQL <- paste(
  "f.group_id, first(f.name ORDER BY f.formula_id) AS name, first(f.role ORDER BY f.formula_id) AS role,",
  "first(f.f_design ORDER BY f.formula_id) AS design, first(f.general ORDER BY f.formula_id) AS general,",
  "first(f.latex ORDER BY f.formula_id) AS latex, first(f.symbols ORDER BY f.formula_id) AS symbols,",
  "first(f.condition ORDER BY f.formula_id) AS condition, first(f.passage_id ORDER BY f.formula_id) AS passage_id,",
  "first(d.course ORDER BY f.formula_id) AS course, first(d.title ORDER BY f.formula_id) AS title, count(*) AS places_n,",
  "string_agg(f.doc_id || coalesce(' p. ' || f.page, ' line ' || f.line_from), '; ' ORDER BY f.formula_id) AS places,",
  "list(f.passage_id ORDER BY f.formula_id) AS place_ids")

# One row per formula group: name, symbols and the parent passages all count. Filters: role, design
#   (any of), topic (of a parent passage), course, general. An empty query lists by number of places.
find_formulas <- function(con, query, role = NULL, design = NULL, general = TRUE, k = 8, topic = NULL, course = NULL) {
  q = query_terms(query)
  any_q = length(q) > 0
  if (!any_q) q = "\u0001"
  qs = function(x) paste(dbQuoteString(con, x), collapse = ", ")
  where = c(if (length(role)) sprintf("f.role IN (%s)", qs(role)),
            if (length(design)) sprintf("list_has_any(string_split(f.f_design, ';'), %s)", q_list(con, design)),
            if (!is.null(general)) sprintf("f.general = %s", if (isTRUE(general)) "TRUE" else "FALSE"),
            if (length(course)) sprintf("d.course IN (%s)", qs(course)),
            if (length(topic)) sprintf(paste("f.group_id IN (SELECT f2.group_id FROM formulas f2 JOIN passage_tags t ON t.passage_id =",
                                             "coalesce((SELECT a.passage_id FROM passage_aliases a WHERE a.alias_id = f2.passage_id), f2.passage_id)",
                                             "WHERE t.facet = 'topic' AND t.value IN (%s))"), qs(topic)))
  sc = if (any_q) sprintf(paste("WITH fs AS (%s), ps AS (%s),",
    "pg AS (SELECT f.group_id, max(ps.bm25) AS pb FROM formulas f JOIN ps USING (passage_id) GROUP BY ALL),",
    "sc AS (SELECT group_id, coalesce(fs.bm25, 0) + %f * coalesce(pg.pb, 0) AS score FROM fs FULL JOIN pg USING (group_id))"),
    bm25_sql(con, INDEX$formula, q), bm25_sql(con, INDEX$passage, q), PARENT_WEIGHT) else
    "WITH sc AS (SELECT group_id, count(*) * 1.0 AS score FROM formulas WHERE name <> '' GROUP BY group_id)"
  dbGetQuery(con, sprintf("%s SELECT %s, sc.score FROM sc JOIN formulas f USING (group_id) JOIN docs d ON d.id = f.doc_id %s
                          GROUP BY f.group_id, sc.score ORDER BY sc.score DESC, f.group_id LIMIT %d",
                          sc, FORMULA_GROUP_SQL, if (length(where)) paste("WHERE", paste(where, collapse = " AND ")) else "",
                          as.integer(k))) |> as_tibble()
}

# The formula groups with a member inside the given passages (or a passage they stand for), in the
#   order of the passages; general ones only by default.
formulas_in_passages <- function(con, passage_ids, general = TRUE) {
  if (!length(passage_ids)) return(tibble())
  ids = paste(dbQuoteString(con, passage_ids), collapse = ", ")
  r = dbGetQuery(con, sprintf(paste(
    "WITH m AS (SELECT DISTINCT f.group_id, coalesce(a.passage_id, f.passage_id) AS at FROM formulas f",
    "LEFT JOIN passage_aliases a ON a.alias_id = f.passage_id WHERE coalesce(a.passage_id, f.passage_id) IN (%s)%s)",
    "SELECT %s, list(DISTINCT m.at) AS ats, 0.0 AS score FROM m JOIN formulas f USING (group_id) JOIN docs d ON d.id = f.doc_id GROUP BY f.group_id"),
    ids, if (isTRUE(general)) " AND f.general" else "", FORMULA_GROUP_SQL)) |> as_tibble()
  r |> mutate(at = map_int(ats, function(a) min(match(unlist(a), passage_ids)))) |> arrange(at, group_id) |> select(-at, -ats)
}

find_code <- function(con, query, packages = NULL, functions = NULL, k = 8) {
  q = query_terms(query)
  if (!length(q)) q = "\u0001"
  where = c(if (length(packages)) sprintf("list_has_any(string_split(c.packages, ';'), %s)", q_list(con, packages)),
            if (length(functions)) sprintf("list_has_any(string_split(c.functions, ';'), %s)", q_list(con, functions)))
  dbGetQuery(con, sprintf(paste(
    "WITH cs AS (%s), ps AS (%s),",
    "sc AS (SELECT c.code_id, coalesce(cs.bm25, 0) + %f * coalesce(ps.bm25, 0) AS score FROM code c",
    "LEFT JOIN cs USING (code_id) LEFT JOIN ps USING (passage_id) WHERE NOT c.is_output AND (cs.bm25 IS NOT NULL OR ps.bm25 IS NOT NULL))",
    "SELECT c.code_id, c.doc_id, c.passage_id, c.task, c.packages, c.functions, sc.score, c.code",
    "FROM sc JOIN code c USING (code_id) %s ORDER BY sc.score DESC, c.code_id LIMIT %d"),
    bm25_sql(con, INDEX$code, q), bm25_sql(con, INDEX$passage, q), PARENT_WEIGHT,
    if (length(where)) paste("WHERE", paste(where, collapse = " AND ")) else "", as.integer(k))) |> as_tibble()
}

# What the app's source window shows. An alias id is shown as the passage it duplicates.
source_card <- function(con, passage_id) {
  r = dbGetQuery(con, paste(
    "SELECT p.passage_id, d.markdown, d.title, p.heading_path, p.pages, p.line_from, p.line_to, p.description, p.text",
    "FROM passages p JOIN docs d ON d.id = p.doc_id",
    "WHERE p.passage_id = coalesce((SELECT a.passage_id FROM passage_aliases a WHERE a.alias_id = ?), ?)"),
    params = list(passage_id, passage_id))
  if (!nrow(r)) return(NULL)
  as.list(r[1, ])
}
