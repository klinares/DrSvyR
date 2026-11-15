# Retrieval evaluation, part 1: no model calls. Run from SurvAI_Expert/ after build/03_store.R:
#   Rscript --no-init-file tests/eval.R          evaluate with the weights in R/retrieve.R
#   Rscript --no-init-file tests/eval.R tune     also tune field weights, k1 and b on a random half
# Writes tests/gold.csv (from the old project's gold.rds, read only) and tests/eval_retrieval.csv.

suppressPackageStartupMessages({ library(tidyverse); library(DBI); library(duckdb) })
source("R/retrieve.R")

GOLD_RDS <- "D:/repos/SurvAI_Expert/eval/gold.rds"
GOLD_CSV <- "tests/gold.csv"
OUT_CSV <- "tests/eval_retrieval.csv"
STORE <- "data/store/survai.duckdb"
DEPTH <- 50L
SEED <- 20261115L
BOOK_ID <- "practools/practical_tools_textbook"   # the old store split the textbook by chapter; here it is one document

# ---- gold ---------------------------------------------------------------------------------------------------

make_gold <- function() {
  man = read_csv("data/catalog/manifest.csv", col_types = cols(.default = col_character()), progress = FALSE)
  g = if (file.exists(GOLD_RDS)) readRDS(GOLD_RDS) else read_csv(GOLD_CSV, col_types = cols(.default = col_character()), progress = FALSE)
  # the source excerpt (text) stays out of git: it repeats the corpus, textbook included; emails are redacted
  g = g |> select(-any_of("text")) |>
    mutate(across(where(is.character), function(v) str_replace_all(v, "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", "[email]"))) |>
    mutate(id = as.character(id), doc_id = coalesce(man$id[match(origin, man$original)],
                                                         if_else(str_detect(origin, "^book/practical-tools/"), BOOK_ID, NA_character_)))
  if (file.exists(GOLD_RDS)) write_csv(g, GOLD_CSV, na = "", eol = "\n")
  bad = g |> filter(is.na(doc_id))
  message(nrow(g), " gold questions; ", nrow(bad), " do not map to a document:")
  walk(unique(bad$origin), function(o) message("  ", o))
  g |> filter(!is.na(doc_id))
}

# ---- search and score ---------------------------------------------------------------------------------------

# Documents a result stands for: its own and the documents of its aliases.
alias_docs <- function(con) dbGetQuery(con, "SELECT passage_id, list(DISTINCT alias_doc_id) AS docs FROM passage_aliases GROUP BY ALL") |>
  as_tibble()

run_queries <- function(con, g, k1 = BM25_K1, b = BM25_B, timed = FALSE) {
  al = alias_docs(con)
  map(seq_len(nrow(g)), function(i) {
    t = Sys.time()
    r = search_passages(con, g$question[i], k = DEPTH, k1 = k1, b = b)
    sec = as.numeric(difftime(Sys.time(), t, units = "secs"))
    docs = map2(r$doc_id, match(r$passage_id, al$passage_id), function(d, j) c(d, if (!is.na(j)) unlist(al$docs[[j]])))
    hit = map_lgl(docs, function(d) g$doc_id[i] %in% d)
    tibble(id = g$id[i], rank = if (any(hit)) which(hit)[1] else NA_integer_, top5 = paste(head(r$doc_id, 5), collapse = ";"),
           first = paste0(r$doc_id[1], " | ", r$heading_path[1]), top5_ids = list(head(r$passage_id, 5)), sec = sec)
  }) |> list_rbind()
}

metrics <- function(res) tibble(n = nrow(res), hit1 = mean(res$rank %in% 1), hit5 = mean(res$rank %in% 1:5),
                                hit10 = mean(res$rank %in% 1:10), mrr = mean(coalesce(1 / res$rank, 0)))

report <- function(res, g, label) {
  x = left_join(res, g |> select(id, kind, doc_id), by = "id") |> mutate(source = str_extract(doc_id, "^[^/]+"))
  message("\n== ", label)
  print(as.data.frame(bind_rows(metrics(x) |> mutate(group = "all", .before = 1),
                                x |> group_by(group = paste("source:", source)) |> group_modify(function(d, k) metrics(d)) |> ungroup(),
                                x |> group_by(group = paste("type:", kind)) |> group_modify(function(d, k) metrics(d)) |> ungroup()) |>
                        mutate(across(hit1:mrr, function(v) round(v, 3)))))
}

# ---- tuning: field weights by coordinate search, then k1 and b, on the tuning half only -------------------

tune <- function(g_tune) {
  tmp = tempfile(fileext = ".duckdb")
  file.copy(STORE, tmp)
  con = store_connect(tmp, read_only = FALSE)
  on.exit({ dbDisconnect(con, shutdown = TRUE); unlink(tmp) }, add = TRUE)
  score = function(w, k1, b) { weigh_terms(con, w); m = metrics(run_queries(con, g_tune, k1, b)); m$mrr + m$hit5 / 100 }
  best = list(w = FIELD_WEIGHTS, k1 = BM25_K1, b = BM25_B)
  best$s = score(best$w, best$k1, best$b)
  message(sprintf("start: MRR+hit5/100 = %.4f", best$s))
  step = function(best, f) reduce(c(0, 0.5, 1, 2, 3, 5), function(bst, v) {
    w = bst$w; w[[f]] = v
    if (identical(w, bst$w)) return(bst)
    s = score(w, bst$k1, bst$b)
    if (s > bst$s + 1e-9) { message(sprintf("  %s = %s: %.4f", f, v, s)); modifyList(bst, list(w = w, s = s)) } else bst
  }, .init = best)
  best = reduce(rep(names(FIELD_WEIGHTS), 2), step, .init = best)
  weigh_terms(con, best$w)
  grid = expand_grid(k1 = c(0.6, 0.9, 1.2, 1.6, 2.0), b = c(0.3, 0.5, 0.75, 0.9))
  gs = map_dbl(seq_len(nrow(grid)), function(i) { m = metrics(run_queries(con, g_tune, grid$k1[i], grid$b[i])); m$mrr + m$hit5 / 100 })
  j = which.max(gs)
  if (gs[j] > best$s + 1e-9) best = modifyList(best, list(k1 = grid$k1[j], b = grid$b[j], s = gs[j]))
  message(sprintf("best: %s; k1 = %s, b = %s; %.4f", paste(names(best$w), best$w, sep = " = ", collapse = ", "), best$k1, best$b, best$s))
  best
}

# Share of questions where the gold document's topics meet the top-5 results' topics ("other" left out).
tag_check <- function(con, res, g) {
  top = res |> select(id, top5_ids) |> unnest(top5_ids)
  duckdb_register(con, "eval_top", top)   # a view of the R data frame; the store is opened read only
  duckdb_register(con, "eval_gold", g |> select(id, doc_id))
  x = dbGetQuery(con, paste(
    "WITH gt AS (SELECT g.id, t.value, count(*) AS n FROM eval_gold g JOIN passages p ON p.doc_id = g.doc_id",
    "  JOIN passage_tags t ON t.passage_id = p.passage_id WHERE t.facet = 'topic' AND t.value <> 'other' GROUP BY ALL),",
    "g3 AS (SELECT id, value FROM (SELECT *, row_number() OVER (PARTITION BY id ORDER BY n DESC, value) AS r FROM gt) WHERE r <= 3),",
    "rt AS (SELECT DISTINCT e.id, t.value FROM eval_top e JOIN passage_tags t ON t.passage_id = e.top5_ids WHERE t.facet = 'topic')",
    "SELECT g.id, EXISTS (SELECT 1 FROM gt JOIN rt USING (id, value) WHERE gt.id = g.id) AS any_topic,",
    "EXISTS (SELECT 1 FROM g3 JOIN rt USING (id, value) WHERE g3.id = g.id) AS top3_topic FROM eval_gold g"))
  message(sprintf("\nTopic overlap of the gold document with the top 5: any of its topics %.3f; its 3 most frequent topics %.3f",
                  mean(x$any_topic), mean(x$top3_topic)))
}

main <- function(mode = "eval") {
  g = make_gold()
  set.seed(SEED)
  g$half = if_else(seq_len(nrow(g)) %in% sample(nrow(g), floor(nrow(g) / 2)), "tune", "held out")
  best = if (mode == "tune") tune(g |> filter(half == "tune")) else list(w = FIELD_WEIGHTS, k1 = BM25_K1, b = BM25_B)
  con = store_connect(STORE)
  on.exit(dbDisconnect(con, shutdown = TRUE), add = TRUE)
  if (mode == "tune" && !(identical(best$w, FIELD_WEIGHTS) && best$k1 == BM25_K1 && best$b == BM25_B)) {
    message("Tuned values differ from R/retrieve.R: set them there and rebuild the store, then run tests/eval.R again.")
    return(invisible(best))
  }
  res = run_queries(con, g, best$k1, best$b, timed = TRUE)
  report(res |> filter(id %in% g$id[g$half == "tune"]), g, "tuning half")
  report(res |> filter(id %in% g$id[g$half == "held out"]), g, "held-out half")
  report(res, g, "all questions")
  tag_check(con, res, g)
  worst = res |> left_join(g |> select(id, doc_id, question), by = "id") |> arrange(desc(coalesce(rank, 999L))) |> head(10)
  message("\n== 10 worst questions (rank of gold, gold document, what ranked first)")
  walk(seq_len(nrow(worst)), function(i) message(sprintf("  [%s] %s\n     gold: %s\n     first: %s", coalesce(as.character(worst$rank[i]), ">50"),
                                                          str_trunc(worst$question[i], 110), worst$doc_id[i], worst$first[i])))
  write_csv(res |> left_join(g |> select(id, half, kind, doc_id), by = "id") |> select(id, half, kind, doc_id, rank, top5),
            OUT_CSV, na = "", eol = "\n")
  message(sprintf("\nSearch time: median %.0f ms, 95th percentile %.0f ms", 1000 * median(res$sec), 1000 * quantile(res$sec, 0.95)))
  invisible(res)
}

if (sys.nframe() == 0L) {
  mode = head(c(commandArgs(trailingOnly = TRUE), "eval"), 1)
  if (mode == "answers") {   # part 2: the app's question answering, in tests/eval_answers.R
    source("app.R")
    source("tests/eval_answers.R")
    main_answers()
  } else main(mode)
}
