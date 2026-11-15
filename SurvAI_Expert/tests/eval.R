# The evaluation. Run from SurvAI_Expert/ after build/03_store.R:
#   Rscript --no-init-file tests/eval.R          part 1, retrieval, no model calls
#   Rscript --no-init-file tests/eval.R tune     part 1, also tuning field weights, k1 and b on a random half
#   Rscript --no-init-file tests/eval.R answers  part 2, planned retrieval, answers, checks and a judge (model
#                                                calls; profile SURVAI_PROFILE, key from the variable KEY_ENV names)
# Writes tests/gold.csv (from the old project's gold.rds, read only), tests/eval_retrieval.csv, and for
#   part 2 tests/eval_report.md and tests/eval_answers.csv.

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


# ==== part 2: planned retrieval, answers, checks and a judge (model calls) ====

N_PLAN <- 100L
N_ANSWER <- 40L
ANSWER_SEED <- 20261116L
CALL_BUDGET <- 250L
NON_QUESTIONS <- c("2637", "8797")   # gold rows that are not questions ("What is the provided text about?", "I'm sorry, ...")
REPORT_MD <- "tests/eval_report.md"
ANSWERS_CSV <- "tests/eval_answers.csv"

JUDGE_SYSTEM <- paste(
  "You grade answers to survey methodology questions. You are given the question, the answer, the numbered",
  "sources the answer was given, and a passage from the course document the question was written from.",
  "Judge correctness against the course passage and sound survey statistics: 'correct' when the answer is right",
  "and answers the question, 'partly correct' when it is right in part or misses part of the question,",
  "'incorrect' when it is wrong or does not answer. Count the claims of fact in the answer that no given source",
  "supports (claims labelled 'not from the store' do not count). Say whether the answer wrongly said the",
  "sources lack material that is in fact in them. Give a one-sentence reason. Reply with JSON only.")

JUDGE_SCHEMA <- list(type = "object", additionalProperties = FALSE,
  required = list("verdict", "unsupported_claims", "wrongly_said_missing", "reason"),
  properties = list(verdict = list(type = "string", enum = list("correct", "partly correct", "incorrect")),
                    unsupported_claims = list(type = "integer"), wrongly_said_missing = list(type = "boolean"),
                    reason = list(type = "string")))

gold_passages <- function(con, q, doc) {
  hit = search_passages(con, q, k = 200) |> filter(doc_id == doc) |> head(2)
  t = if (nrow(hit)) hit$text else dbGetQuery(con, "SELECT text FROM passages WHERE doc_id = ? ORDER BY passage_id LIMIT 2", params = list(doc))$text
  paste(str_trunc(t, 3000), collapse = "\n\n")
}

judge <- function(m, key, con, row, res) {
  user = paste0("Question:\n", row$question, "\n\nAnswer:\n", res$answer, "\n\nSources given to the answer:\n\n",
                sources_text(res$gathered), "\n\nPassage from the course document (", row$doc_id, "):\n",
                gold_passages(con, row$question, row$doc_id))
  r = call_model(m, "judge", JUDGE_SYSTEM, user, key, JUDGE_SCHEMA)
  structure(parse_json_reply(r), usage = attr(r, "usage"))
}

# Rank of the gold document among the gathered passages (or NA); formulas: one from the gold
#   document, or in the same group as one, among those found.
planned_hits <- function(con, g, doc, al) {
  P = g$sources |> filter(kind == "passage")
  docs = map2(P$doc_id, match(P$passage_id, al$passage_id), function(d, j) c(d, if (!is.na(j)) unlist(al$docs[[j]])))
  hit = which(map_lgl(docs, function(d) doc %in% d))
  f_hit = nrow(g$formulas) > 0 && nrow(dbGetQuery(con, sprintf("SELECT 1 FROM formulas WHERE doc_id = ? AND group_id IN (%s) LIMIT 1",
                                                             paste(dbQuoteString(con, g$formulas$group_id), collapse = ", ")), params = list(doc))) > 0
  list(rank = if (length(hit)) hit[1] else NA_integer_, formula_hit = f_hit)
}

md_table <- function(d) {
  d = mutate(d, across(where(is.double), function(v) format(round(v, 3), nsmall = 0)))
  paste(c(paste("|", paste(names(d), collapse = " | "), "|"), paste("|", paste(rep("---", ncol(d)), collapse = " | "), "|"),
          pmap_chr(d, function(...) paste("|", paste(c(...), collapse = " | "), "|"))), collapse = "\n")
}

by_type <- function(d, f) bind_rows(f(d) |> mutate(type = "all", .before = 1),
                                    d |> group_by(type = kind) |> group_modify(function(x, k) f(x)) |> ungroup())

# The report's opening lines, for readers who are not statisticians.
report_summary <- function(n_gold, n_plan, okA, ret) {
  pct = function(x) sprintf("%.0f%%", 100 * x)
  cor = sum(okA$verdict %in% "correct")
  c("## In short", "",
    sprintf("- The tool was tested on %d questions written from the course materials: %d were searched and %d answered in full.", n_gold, n_plan, nrow(okA)),
    sprintf("- %d of the %d answers (%s) were judged correct; %s.", cor, nrow(okA), pct(cor / nrow(okA)),
            if (!any(okA$verdict %in% "incorrect")) "none was judged incorrect" else paste(sum(okA$verdict %in% "incorrect"), "were judged incorrect")),
    sprintf("- %s pointed to a real source, and %s came from the store rather than being typed by the model.",
            if (all(okA$cites_valid)) "Every citation" else sprintf("Citations in %s of answers", pct(mean(okA$cites_valid))),
            if (all(okA$tokens_valid & !okA$display_math)) "every formula shown" else sprintf("formulas in %s of answers", pct(mean(okA$tokens_valid & !okA$display_math)))),
    sprintf("- For %s of the questions, the document the question was written from was among the first 10 sources found.", pct(mean(ret$rank %in% 1:10))),
    "- The search figures vary by a few points from run to run, because the model plans each search afresh.")
}

HOW_TO_READ <- c("## How to read this", "",
  "- **hit@5, hit@10**: the share of questions whose source document is among the first 5 (or 10) passages found.",
  "- **judge**: the same model, asked to grade each answer against the course passage the question came from: correct, partly correct or incorrect.",
  "- **unsupported claim**: a statement of fact in an answer that none of the sources given to it supports, as counted by the judge.")

receipt_status <- function(con) {
  e = new.env()
  sys.source("build/03_store.R", envir = e)
  old = utils::read.csv(e$RECEIPT_CSV, colClasses = c("character", "character", "integer", "character"))
  new = e$receipt(con)
  d = full_join(old, new, by = c("tbl", "source")) |> filter(is.na(checksum.x) | is.na(checksum.y) | checksum.x != checksum.y)
  if (!nrow(d)) "identical to data/catalog/receipt.csv" else paste(nrow(d), "table(s) differ from data/catalog/receipt.csv")
}

main_answers <- function() {
  m = profile_model(MODEL_PROFILE)
  key = Sys.getenv(KEY_ENV)
  g_all = make_gold()
  g = g_all |> filter(!id %in% NON_QUESTIONS) |> mutate(question = as.character(question))
  set.seed(ANSWER_SEED)
  g_plan = g[sort(sample(nrow(g), min(N_PLAN, nrow(g)))), ]
  kinds = sort(table(g_plan$kind), decreasing = TRUE)
  per = floor(N_ANSWER / length(kinds)) + (seq_along(kinds) <= N_ANSWER %% length(kinds))
  ans_ids = unlist(map2(names(kinds), per, function(k, n) { x = g_plan$id[g_plan$kind == k]; x[sort(sample(length(x), min(n, length(x))))] }))
  n_calls = nrow(g_plan) + 2L * length(ans_ids)   # a plan per question; an answer and a judge per answered one
  message(sprintf("Profile %s (%s). Gold: %d rows, %d unmapped and %d non-questions dropped, %d left.",
                  MODEL_PROFILE, m$id, 108L, 108L - nrow(g_all), length(NON_QUESTIONS), nrow(g)))
  message(sprintf("This run makes %d model calls: %d plans, %d answers, %d judgements (CALL_BUDGET %d).",
                  n_calls, nrow(g_plan), length(ans_ids), length(ans_ids), CALL_BUDGET))
  if (n_calls > CALL_BUDGET) stop("That is more than CALL_BUDGET; lower N_PLAN or N_ANSWER.", call. = FALSE)
  con = store_con()
  receipt = receipt_status(con)
  al = alias_docs(con)
  raw = run_queries(con, g_plan) |> select(id, raw_rank = rank)

  P = map(seq_len(nrow(g_plan)), function(i) {
    t0 = Sys.time()
    p = tryCatch(plan_question(g_plan$question[i], MODEL_PROFILE, key), error = function(e) e)
    if (inherits(p, "error")) { message("  plan failed: ", conditionMessage(p)); return(list(id = g_plan$id[i], error = conditionMessage(p))) }
    t1 = Sys.time()
    gg = gather(con, p)
    h = planned_hits(con, gg, g_plan$doc_id[i], al)
    if (i %% 10 == 0) message(sprintf("  %d/%d planned", i, nrow(g_plan)))
    list(id = g_plan$id[i], plan = p, gathered = gg, rank = h$rank, formula_hit = h$formula_hit, usd = attr(p, "usage")$usd,
         sec_plan = as.numeric(difftime(t1, t0, units = "secs")), sec_search = as.numeric(difftime(Sys.time(), t1, units = "secs")))
  }) |> set_names(g_plan$id)
  ok = keep(P, function(x) is.null(x$error))
  ret = g_plan |> select(id, kind) |> left_join(raw, by = "id") |>
    left_join(tibble(id = names(ok), rank = map_int(ok, "rank"), formula_hit = map_lgl(ok, "formula_hit")), by = "id")
  ret_tab = by_type(ret, function(x) tibble(n = nrow(x), raw_hit5 = mean(x$raw_rank %in% 1:5), raw_hit10 = mean(x$raw_rank %in% 1:10),
                                             planned_hit5 = mean(x$rank %in% 1:5), planned_hit10 = mean(x$rank %in% 1:10)))
  eq = ret |> filter(kind == "equation")

  A = map(ans_ids, function(i) {
    row = g_plan[g_plan$id == i, ]
    if (is.null(P[[i]]$plan)) return(tibble(id = i, error = "no plan"))
    res = tryCatch(ask(row$question, MODEL_PROFILE, key, con, plan = P[[i]]$plan), error = function(e) e)
    if (inherits(res, "error")) return(tibble(id = i, error = conditionMessage(res)))
    j = tryCatch(judge(m, key, con, row, res), error = function(e) e)
    if (inherits(j, "error")) j = list(verdict = NA_character_, unsupported_claims = NA_integer_, wrongly_said_missing = NA, reason = conditionMessage(j))
    message(sprintf("  answered %s (%s): %s", i, row$kind, j$verdict))
    ck = res$checks
    tibble(id = i, kind = row$kind, doc_id = row$doc_id, question = row$question, answer = res$answer,
           cites = ck$cites, cites_valid = ck$cites_valid, tokens = ck$tokens, tokens_valid = ck$tokens_valid,
           display_math = ck$display_math, code_blocks = ck$code_blocks, code_parses = ck$code_parses,
           unverified = paste(ck$unverified, collapse = ";"), n_unverified = length(ck$unverified),
           uncited = ck$uncited, not_from_library = ck$not_from_library, words = ck$words, formulas_given = nrow(res$gathered$formulas),
           verdict = j$verdict, unsupported_claims = as.integer(j$unsupported_claims), wrongly_said_missing = as.logical(j$wrongly_said_missing),
           reason = j$reason, sec_plan = P[[i]]$sec_plan, sec_search = res$sec[["search"]], sec_answer = res$sec[["answer"]],
           usd_answer = res$usd - P[[i]]$usd, usd_judge = attr(j, "usage")$usd %||% NA_real_)
  }) |> bind_rows()
  utils::write.csv(A, ANSWERS_CSV, row.names = FALSE, na = "", fileEncoding = "UTF-8")

  okA = if ("error" %in% names(A)) A |> filter(is.na(error)) else A
  if ("error" %in% names(A)) walk(A$error[!is.na(A$error)], function(e) message("  answer failed: ", e))
  chk = by_type(okA, function(x) tibble(n = nrow(x), citations_valid = mean(x$cites_valid), formula_tokens_valid = mean(x$tokens_valid),
                                         no_display_math = mean(!x$display_math), with_code = sum(x$code_blocks > 0),
                                         code_parses = mean(x$code_parses), unverified_functions = sum(x$n_unverified),
                                         uncited_per_answer = mean(x$uncited), median_words = median(x$words)))
  jud = by_type(okA, function(x) tibble(n = nrow(x), correct = sum(x$verdict %in% "correct"), partly = sum(x$verdict %in% "partly correct"),
                                         incorrect = sum(x$verdict %in% "incorrect"), unsupported_claims = sum(x$unsupported_claims, na.rm = TRUE),
                                         wrongly_said_missing = sum(x$wrongly_said_missing %in% TRUE)))
  calls_made = length(ok) + 2L * nrow(okA)
  usd = sum(map_dbl(ok, "usd")) + sum(okA$usd_answer, na.rm = TRUE) + sum(okA$usd_judge, na.rm = TRUE)
  times = tibble(step = c("plan", "search", "answer"), median_seconds = c(median(map_dbl(ok, "sec_plan")), median(map_dbl(ok, "sec_search")), median(okA$sec_answer)))
  worst = okA |> mutate(o = match(verdict, c("incorrect", "partly correct", "correct"))) |>
    arrange(o, desc(unsupported_claims), desc(wrongly_said_missing)) |> head(5)

  rep = c(paste0("# SurvAI_Expert evaluation, ", format(Sys.Date())), "",
          report_summary(nrow(g), nrow(g_plan), okA, ret), "", HOW_TO_READ, "",
          sprintf("Profile **%s**, model `%s`. Store receipt: %s.", MODEL_PROFILE, m$id, receipt), "",
          sprintf("Gold: 108 questions; %d unmapped (R scripts not in the store) and %d that are not questions were dropped, leaving %d. %d were planned and %d answered (stratified by type).",
                  108L - nrow(g_all), length(NON_QUESTIONS), nrow(g), nrow(g_plan), nrow(okA)), "",
          "## Retrieval: raw question vs planned search", "",
          "Hit@k: the gold document is among the first k passages. Raw = the question text alone (part 1); planned = the model's plan, fused, at most 3 passages per document.", "",
          md_table(ret_tab), "",
          sprintf("Equation questions: a formula from the gold document (or its formula group) was among those found for %d of %d.", sum(eq$formula_hit %in% TRUE), nrow(eq)), "",
          "## Answer checks (no model)", "", md_table(chk), "",
          "## Judge (the same model)", "", md_table(jud), "",
          "## Cost and time", "",
          sprintf("%d model calls, about $%.2f (from token counts at the profile's prices).", calls_made, usd), "", md_table(times), "",
          "## Five worst answers", "",
          pmap_chr(list(worst$question, worst$verdict, worst$reason, worst$unsupported_claims), function(q, v, r, u)
            sprintf("- **%s** (%s, %s unsupported claims): %s", str_trunc(str_squish(q), 140), v, u, r)))
  writeLines(rep, REPORT_MD, useBytes = TRUE)
  message("Wrote ", REPORT_MD, " and ", ANSWERS_CSV, "; ", calls_made, " calls, about $", round(usd, 2))
  invisible(list(ret = ret, answers = A))
}

if (sys.nframe() == 0L) {
  mode = head(c(commandArgs(trailingOnly = TRUE), "eval"), 1)
  if (mode == "answers") {   # part 2 uses the app's question answering
    source("app.R")
    main_answers()
  } else main(mode)
}
