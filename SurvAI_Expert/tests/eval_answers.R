# Evaluation, part 2: planned retrieval, answers, checks and a judge. Makes model calls.
#   Run from SurvAI_Expert/:  Rscript --no-init-file tests/eval.R answers
#   Profile: SURVAI_PROFILE (default home); key: the environment variable KEY_ENV names (app.R).
#   Writes tests/eval_report.md and tests/eval_answers.csv. Sourced by tests/eval.R.

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
           verdict = j$verdict, unsupported_claims = as.integer(j$unsupported_claims), wrongly_said_missing = as.logical(j$wrongly_said_missing),
           reason = j$reason, sec_plan = P[[i]]$sec_plan, sec_search = res$sec[["search"]], sec_answer = res$sec[["answer"]],
           usd_answer = res$usd - P[[i]]$usd, usd_judge = attr(j, "usage")$usd %||% NA_real_)
  }) |> bind_rows()
  utils::write.csv(A, ANSWERS_CSV, row.names = FALSE, na = "", fileEncoding = "UTF-8")

  okA = if ("error" %in% names(A)) A |> filter(is.na(error)) else A
  if ("error" %in% names(A)) walk(A$error[!is.na(A$error)], function(e) message("  answer failed: ", e))
  chk = by_type(okA, function(x) tibble(n = nrow(x), citations_valid = mean(x$cites_valid), formula_tokens_valid = mean(x$tokens_valid),
                                         no_display_math = mean(!x$display_math), with_code = sum(x$code_blocks > 0),
                                         code_parses = mean(x$code_parses), unverified_functions = sum(x$n_unverified)))
  jud = by_type(okA, function(x) tibble(n = nrow(x), correct = sum(x$verdict %in% "correct"), partly = sum(x$verdict %in% "partly correct"),
                                         incorrect = sum(x$verdict %in% "incorrect"), unsupported_claims = sum(x$unsupported_claims, na.rm = TRUE),
                                         wrongly_said_missing = sum(x$wrongly_said_missing %in% TRUE)))
  calls_made = length(ok) + 2L * nrow(okA)
  usd = sum(map_dbl(ok, "usd")) + sum(okA$usd_answer, na.rm = TRUE) + sum(okA$usd_judge, na.rm = TRUE)
  times = tibble(step = c("plan", "search", "answer"), median_seconds = c(median(map_dbl(ok, "sec_plan")), median(map_dbl(ok, "sec_search")), median(okA$sec_answer)))
  worst = okA |> mutate(o = match(verdict, c("incorrect", "partly correct", "correct"))) |>
    arrange(o, desc(unsupported_claims), desc(wrongly_said_missing)) |> head(5)

  rep = c(paste0("# SurvAI_Expert evaluation, ", format(Sys.Date())), "",
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
