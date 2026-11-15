# llm.R: the question-answering logic. plan_question() (one model call), gather() (the store, no
#   model), answer_question() (one model call) and ask(), which runs them with the check and the
#   rendering of R/render.R. The model is called through ellmer only; the key is passed to each call
#   as credentials and never kept. Function definitions and constants only.

LLM_MAX_TOKENS <- c(plan = 4000L, answer = 16000L, judge = 6000L)   # thinking counts against these
LLM_TIMEOUT_S <- 300
INTENTS <- c("formula", "code", "advice", "concept")
PLAN_LIMITS <- c(tse = 2L, stage = 2L, design = 2L, topic = 3L)
PLAN_QUERIES <- 3L
SEARCH_DEPTH <- 30L      # passages per query before fusion
RRF_K <- 60              # reciprocal rank fusion: score = sum of 1 / (RRF_K + rank)
GATHER_PASSAGES <- 10L
GATHER_PER_DOC <- 3L
GATHER_FORMULAS <- 5L
GATHER_CODE <- 4L
SOURCE_TEXT_CHARS <- 3000L

.store <- new.env(parent = emptyenv())

store_con <- function() {
  if (is.null(.store$con) || !DBI::dbIsValid(.store$con)) .store$con = store_connect(STORE_PATH)
  .store$con
}

# The profile's model; a profile still holding <placeholders> stops with a plain message.
profile_model <- function(profile = MODEL_PROFILE) {
  m = MODEL_PROFILES[[profile]]
  if (is.null(m)) stop("There is no profile '", profile, "' in MODEL_PROFILES (app.R).", call. = FALSE)
  ph = names(keep(m, function(v) is.character(v) && length(v) == 1L && grepl("^<.+>$", v)))
  if (length(ph)) stop("The '", profile, "' profile is not filled in yet: set ", paste(ph, collapse = ", "),
                       " in MODEL_PROFILES in app.R.", call. = FALSE)
  m
}

read_reflex <- function(name) paste(readLines(file.path(REFLEX_DIR, name), warn = FALSE, encoding = "UTF-8"), collapse = "\n")
read_vocab <- function() utils::read.csv(VOCAB_CSV, colClasses = "character", encoding = "UTF-8")

# The ellmer chat for one kind of call. Anthropic structured output goes in output_config: ellmer
#   0.4.2's chat_structured() forces a tool choice, which Claude Sonnet 5.5 refuses (HTTP 400).
model_chat <- function(m, kind, system, key, schema = NULL) {
  if (is.null(key) || !nzchar(key)) stop("No key: set ", KEY_ENV, " or pass key =.", call. = FALSE)
  effort = if (is.na(m$effort[kind] %||% NA)) NULL else unname(m$effort[kind])
  params = ellmer::params(max_tokens = LLM_MAX_TOKENS[[kind]])
  switch(m$api,
    anthropic = {
      oc = compact(list(effort = effort, format = if (!is.null(schema) && m$json == "output_config") list(type = "json_schema", schema = schema)))
      ellmer::chat_anthropic(system_prompt = system, model = m$id, base_url = m$base_url, params = params,
                             api_args = compact(list(output_config = if (length(oc)) oc)), credentials = function() key, echo = "none")
    },
    openai = ellmer::chat_openai_compatible(
      base_url = m$base_url, name = sub("^[a-z]+://([^/]+).*$", "\\1", m$base_url), system_prompt = system,
      credentials = function() key, model = m$id, params = params, echo = "none",
      api_args = compact(list(reasoning_effort = effort,
                              response_format = if (!is.null(schema) && m$json == "response_format")
                                list(type = "json_schema", json_schema = list(name = "reply", schema = schema, strict = TRUE))))),
    stop("The profile's api is '", m$api, "'; it must be 'anthropic' or 'openai'.", call. = FALSE))
}

# Tokens, seconds and an approximate cost of a finished chat.
chat_usage <- function(chat, m, t0) {
  tk = chat$get_tokens()
  tok = c(input = sum(tk$input), output = sum(tk$output), cached = sum(tk$cached_input))
  list(tokens = tok, sec = as.numeric(difftime(Sys.time(), t0, units = "secs")), usd = sum(tok * m$price[names(tok)]) / 1e6)
}

# One call: the reply text with attribute usage.
call_model <- function(m, kind, system, user, key, schema = NULL) {
  chat = model_chat(m, kind, system, key, schema)
  t0 = Sys.time()
  old = options(ellmer_timeout_s = LLM_TIMEOUT_S)
  on.exit(options(old), add = TRUE)
  txt = tryCatch(chat$chat(user), error = function(e) stop(gsub(key, "[key]", conditionMessage(e), fixed = TRUE), call. = FALSE))
  structure(as.character(txt), usage = chat_usage(chat, m, t0))
}

parse_json_reply <- function(txt) {
  j = str_sub(txt, str_locate(txt, fixed("{"))[1], str_locate_all(txt, fixed("}"))[[1]] |> (function(x) x[nrow(x), 1])())
  tryCatch(jsonlite::fromJSON(j, simplifyVector = TRUE), error = function(e) stop("The model's reply is not valid JSON.", call. = FALSE))
}

# ---- plan ---------------------------------------------------------------------------------------------------

plan_schema <- function(v) {
  arr = function(items) list(type = "array", items = items)
  enum = function(x) list(type = "string", enum = as.list(x))
  f = names(PLAN_LIMITS)
  tags = list(type = "object", additionalProperties = FALSE, required = as.list(f),
              properties = set_names(map(f, function(x) arr(enum(v$value[v$facet == x]))), f))
  list(type = "object", additionalProperties = FALSE, required = list("intents", "queries", "tags", "formula_query", "code_query"),
       properties = list(intents = arr(enum(INTENTS)), queries = arr(list(type = "string")), tags = tags,
                         formula_query = list(type = "string"), code_query = list(type = "string")))
}

# Fields checked in R: unknown intents and tag values are dropped (and listed in $dropped).
clean_plan <- function(p, v, question) {
  tags = imap(PLAN_LIMITS, function(lim, f) unique(as.character(unlist(p$tags[[f]]))))
  ok = imap(tags, function(x, f) head(x[x %in% v$value[v$facet == f]], PLAN_LIMITS[[f]]))
  queries = head(discard(str_squish(as.character(unlist(p$queries))), function(q) !nzchar(q)), PLAN_QUERIES)
  list(question = question, intents = intersect(as.character(unlist(p$intents)), INTENTS),
       queries = if (length(queries)) queries else question, tags = ok,
       formula_query = str_squish(as.character(p$formula_query %||% "")), code_query = str_squish(as.character(p$code_query %||% "")),
       dropped = unlist(imap(tags, function(x, f) if (length(setdiff(x, ok[[f]]))) paste0(f, ": ", setdiff(x, ok[[f]])))))
}

plan_question <- function(question, profile = MODEL_PROFILE, key = Sys.getenv(KEY_ENV)) {
  m = profile_model(profile)
  v = read_vocab()
  w = v[v$facet %in% names(PLAN_LIMITS), ]
  system = paste0(read_reflex("plan.md"), "\n\nVocabulary (facet: value: definition):\n",
                  paste(w$facet, w$value, w$definition, sep = ": ", collapse = "\n"))
  r = call_model(m, "plan", system, question, key, plan_schema(v))
  structure(clean_plan(parse_json_reply(r), v, question), usage = attr(r, "usage"))
}

# ---- gather -------------------------------------------------------------------------------------------------

gather <- function(con, plan) {
  runs = map(plan$queries, function(q) search_passages(con, q, tags = plan$tags, k = SEARCH_DEPTH) |> mutate(rank = row_number()))
  P = bind_rows(runs) |> group_by(passage_id) |> summarise(rrf = sum(1 / (RRF_K + rank)), doc_id = first(doc_id), .groups = "drop") |>
    arrange(desc(rrf), passage_id) |> group_by(doc_id) |> filter(row_number() <= GATHER_PER_DOC) |> ungroup() |>
    arrange(desc(rrf), passage_id) |> head(GATHER_PASSAGES)
  q_or = function(x) if (nzchar(x)) x else paste(plan$queries, collapse = " ")
  Fm = if ("formula" %in% plan$intents) find_formulas(con, q_or(plan$formula_query), k = GATHER_FORMULAS) else tibble()
  Kc = if ("code" %in% plan$intents) find_code(con, q_or(plan$code_query), k = GATHER_CODE) else tibble()
  if (nrow(Fm)) Fm = Fm |> mutate(fid = paste0("F", row_number()), passage_id = map_chr(group_id, function(g)
    dbGetQuery(con, "SELECT passage_id FROM formulas WHERE group_id = ? ORDER BY formula_id LIMIT 1", params = list(g))$passage_id))
  if (nrow(Kc)) Kc = Kc |> mutate(cid = paste0("C", row_number()))
  col = function(d, x) if (x %in% names(d)) d[[x]] else character()
  src = bind_rows(tibble(kind = "passage", passage_id = P$passage_id, ref = P$passage_id),
                  tibble(kind = "formula", passage_id = col(Fm, "passage_id"), ref = col(Fm, "fid")),
                  tibble(kind = "code", passage_id = col(Kc, "passage_id"), ref = col(Kc, "cid"))) |>
    mutate(label = paste0("S", row_number()), .before = 1)
  cards = map(src$passage_id, function(p) source_card(con, p) %||% list())
  src = src |> mutate(doc_id = str_remove(passage_id, "#.*$"), title = map_chr(cards, function(x) x$title %||% ""),
                      markdown = map_chr(cards, function(x) x$markdown %||% ""), heading = map_chr(cards, function(x) x$heading_path %||% ""),
                      pages = map_chr(cards, function(x) x$pages %||% ""), description = map_chr(cards, function(x) x$description %||% ""),
                      text = map_chr(cards, function(x) x$text %||% ""))
  list(plan = plan, sources = src, formulas = Fm, code = Kc,
       known_fns = dbGetQuery(con, "SELECT DISTINCT fn FROM code_functions WHERE fn IS NOT NULL")$fn)
}

# The sources as the answering model reads them.
sources_text <- function(g) {
  s = g$sources
  pmap_chr(list(s$label, s$kind, s$ref, s$title, s$heading, s$pages, s$text), function(l, k, r, ti, h, pg, tx) {
    head_line = paste(discard(c(ti, h, pg), function(x) !nzchar(x)), collapse = " | ")
    switch(k,
      passage = paste0("[", l, "] ", head_line, "\n", str_trunc(tx, SOURCE_TEXT_CHARS)),
      formula = with(g$formulas[g$formulas$fid == r, ], paste0(
        "[", l, "] Formula ", r, ": ", name, ". Role: ", role, "; design: ", design, "; general: ", general,
        if (nzchar(coalesce(symbols, ""))) paste0("\nSymbols: ", symbols) else "",
        if (nzchar(coalesce(condition, ""))) paste0("\nCondition: ", condition) else "",
        "\nOccurs in: ", places, "\nLaTeX (for reading only; show it with the token {{F:", r, "}}): ", latex)),
      code = with(g$code[g$code$cid == r, ], paste0("[", l, "] R code ", r, " from ", head_line, ": ", task,
                                                    "\nPackages: ", packages, "\n```r\n", code, "\n```")))
  }) |> paste(collapse = "\n\n")
}

# ---- answer and ask -----------------------------------------------------------------------------------------

# stream = TRUE returns ellmer's stream generator (chunks of text) with the chat as attribute "chat".
answer_question <- function(question, gathered, profile = MODEL_PROFILE, key = Sys.getenv(KEY_ENV), stream = FALSE) {
  m = profile_model(profile)
  user = paste0("Question:\n", question, "\n\nSources:\n\n", sources_text(gathered))
  if (stream) { chat = model_chat(m, "answer", read_reflex("answer.md"), key); return(structure(chat$stream(user), chat = chat)) }
  call_model(m, "answer", read_reflex("answer.md"), user, key)
}

ask <- function(question, profile = MODEL_PROFILE, key = Sys.getenv(KEY_ENV), con = store_con(), plan = NULL) {
  t0 = Sys.time()
  plan = plan %||% plan_question(question, profile, key)
  t1 = Sys.time()
  g = gather(con, plan)
  t2 = Sys.time()
  a = answer_question(question, g, profile, key)
  r = render_answer(a, g)
  use = compact(list(plan = attr(plan, "usage"), answer = attr(a, "usage")))
  list(question = question, plan = plan, gathered = g, answer = as.character(a), checks = check_answer(a, g),
       html = r$html, cards = r$cards, sec = c(plan = as.numeric(difftime(t1, t0, units = "secs")),
                                                search = as.numeric(difftime(t2, t1, units = "secs")), answer = attr(a, "usage")$sec),
       usd = sum(map_dbl(use, "usd")), calls = length(use))
}
