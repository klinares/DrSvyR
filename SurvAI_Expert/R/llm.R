# llm.R: the question-answering logic. plan_question() (one model call), gather() (the store, no
#   model), answer_question() (one model call) and ask(), which runs them with the check and the
#   rendering of R/render.R. The model is called through ellmer only; the key is passed to each call
#   as credentials and never kept. Function definitions and constants only.

LLM_MAX_TOKENS <- c(plan = 4000L, answer = 16000L, judge = 6000L, report = 32000L)   # thinking counts against these
LLM_TIMEOUT_S <- 600
INTENTS <- c("formula", "code", "advice", "concept")
PLAN_LIMITS <- c(tse = 2L, stage = 2L, design = 2L, topic = 3L)
PLAN_QUERIES <- 3L        # per part
PLAN_PARTS <- 4L          # a message with more distinct questions is answered for the first PLAN_PARTS
SEARCH_DEPTH <- 30L      # passages per query before fusion
RRF_K <- 60              # reciprocal rank fusion: score = sum of 1 / (RRF_K + rank)
GATHER_RAW_WEIGHT <- 3        # the question itself, always fused in as one more query, with this weight (at least 1);
                              #   3 chosen on the 100 planned gold questions (hit@5 0.70 with 0, 0.81 with 3)
GATHER_PER_DOC <- 3L
# What gather() keeps, for a message of one part and per part of a message of several.
GATHER_PASSAGES <- c(one = 10L, part = 6L)
GATHER_FORMULAS <- c(one = 5L, part = 3L)            # found by the formula query
GATHER_FORMULA_PASSAGES <- c(one = 5L, part = 3L)    # general formulas inside the top passages are added
GATHER_FORMULAS_MAX <- c(one = 6L, part = 3L)        # formulas kept, one per group
GATHER_CODE <- c(one = 4L, part = 2L)
GATHER_FORMULA_CODE <- 3L                            # code found for a part's formulas, so each formula gets an R example
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
  part = list(type = "object", additionalProperties = FALSE, required = list("question", "queries", "formula_query", "code_query"),
              properties = list(question = list(type = "string"), queries = arr(list(type = "string")),
                                formula_query = list(type = "string"), code_query = list(type = "string")))
  list(type = "object", additionalProperties = FALSE, required = list("intents", "tags", "parts", "more_than_four"),
       properties = list(intents = arr(enum(INTENTS)), tags = tags, parts = arr(part), more_than_four = list(type = "boolean")))
}

# Fields checked in R: unknown intents and tag values are dropped (and listed in $dropped); at most
#   PLAN_PARTS parts. A single part searches with the whole message as its question. $queries,
#   $formula_query and $code_query join the parts', for reports.
clean_plan <- function(p, v, question) {
  tags = imap(PLAN_LIMITS, function(lim, f) unique(as.character(unlist(p$tags[[f]]))))
  ok = imap(tags, function(x, f) head(x[x %in% v$value[v$facet == f]], PLAN_LIMITS[[f]]))
  raw = if (is.data.frame(p$parts)) pmap(p$parts, list) else p$parts %||% list()
  parts = map(raw, function(x) {
    q = str_squish(as.character(x$question %||% ""))
    qs = head(discard(str_squish(as.character(unlist(x$queries))), function(y) !nzchar(y)), PLAN_QUERIES)
    list(question = q, queries = if (length(qs)) qs else q,
         formula_query = str_squish(as.character(x$formula_query %||% "")), code_query = str_squish(as.character(x$code_query %||% "")))
  }) |> discard(function(x) !any(nzchar(c(x$question, x$queries))))
  more = isTRUE(p$more_than_four) || length(parts) > PLAN_PARTS
  parts = head(parts, PLAN_PARTS)
  if (!length(parts)) parts = list(list(question = question, queries = question, formula_query = "", code_query = ""))
  if (length(parts) == 1L) parts[[1]]$question = question
  first = function(x) { x = x[nzchar(x)]; if (length(x)) x[1] else "" }
  list(question = question, intents = intersect(as.character(unlist(p$intents)), INTENTS), tags = ok, parts = parts,
       more_than_four = more, queries = unique(unlist(map(parts, "queries"))),
       formula_query = first(map_chr(parts, "formula_query")), code_query = first(map_chr(parts, "code_query")),
       dropped = unlist(imap(tags, function(x, f) if (length(setdiff(x, ok[[f]]))) paste0(f, ": ", setdiff(x, ok[[f]])))))
}

# No sampling setting is sent: ellmer's params(temperature =) exists, but Claude Sonnet 5.5 refuses a
#   non-default temperature (HTTP 400), and API version 2026-10-21 refuses it on every model.
plan_request <- function(question, context = NULL) {
  v = read_vocab()
  w = v[v$facet %in% names(PLAN_LIMITS), ]
  list(v = v, schema = plan_schema(v), user = paste0(context_text(context), question),
       system = paste0(read_reflex("plan.md"), "\n\nVocabulary (facet: value: definition):\n",
                       paste(w$facet, w$value, w$definition, sep = ": ", collapse = "\n")))
}

plan_from_reply <- function(r, req, question) structure(clean_plan(parse_json_reply(r), req$v, question), usage = attr(r, "usage"))

plan_question <- function(question, profile = MODEL_PROFILE, key = Sys.getenv(KEY_ENV), context = NULL) {
  req = plan_request(question, context)
  plan_from_reply(call_model(profile_model(profile), "plan", req$system, req$user, key, req$schema), req, question)
}

# ---- gather -------------------------------------------------------------------------------------------------

# The parts of a plan; a plan made without parts (an older plan, or a test's) is one part.
plan_parts <- function(plan) plan$parts %||%
  list(list(question = plan$question, queries = plan$queries, formula_query = plan$formula_query %||% "", code_query = plan$code_query %||% ""))

# One part's passages: its queries and its own question (its words find the document it came from
#   best, so it is always searched, with weight raw_weight), fused, at most GATHER_PER_DOC per document.
part_passages <- function(con, part, tags, k, raw_weight) {
  w = c(set_names(rep(1, length(part$queries)), part$queries), set_names(max(1, raw_weight), part$question))
  w = w[nzchar(names(w)) & !duplicated(names(w))]
  runs = imap(w, function(wt, q) search_passages(con, q, tags = tags, k = SEARCH_DEPTH) |> mutate(rank = row_number(), wt = wt))
  bind_rows(runs) |> group_by(passage_id) |> summarise(rrf = sum(wt / (RRF_K + rank)), doc_id = first(doc_id), .groups = "drop") |>
    arrange(desc(rrf), passage_id) |> group_by(doc_id) |> filter(row_number() <= GATHER_PER_DOC) |> ungroup() |>
    arrange(desc(rrf), passage_id) |> head(k)
}

# One part's formulas: those found by its formula query, then the general ones inside its top
#   passages, one per group. With one part the formula query runs when the plan wants a formula
#   (falling back on the queries); with several, for each part that has a formula query.
part_formulas <- function(con, part, P, n, want) {
  q = if (nzchar(part$formula_query)) part$formula_query else paste(part$queries, collapse = " ")
  Fm = bind_rows(if (want) find_formulas(con, q, k = GATHER_FORMULAS[[n]]),
                 formulas_in_passages(con, head(P$passage_id, GATHER_FORMULA_PASSAGES[[n]])))
  if (nrow(Fm)) Fm |> distinct(group_id, .keep_all = TRUE) |> head(GATHER_FORMULAS_MAX[[n]]) else Fm
}

# One part's code: by its code query when it wants code, and, when it wants a formula, by the
#   formula query and the names of the formulas found (GATHER_FORMULA_CODE blocks).
part_code <- function(con, part, n, want, want_f, Fm) {
  q = if (nzchar(part$code_query)) part$code_query else paste(part$queries, collapse = " ")
  fq = paste(c(if (nzchar(part$formula_query)) part$formula_query else paste(part$queries, collapse = " "),
               if (nrow(Fm)) Fm$name), collapse = " ")
  bind_rows(if (want) find_code(con, q, k = GATHER_CODE[[n]]), if (want_f) find_code(con, fq, k = GATHER_FORMULA_CODE))
}

# Each part is searched separately (GATHER_PASSAGES etc. per part), then duplicates are removed.
#   pin: a formula group (a row of find_formulas()) given first, as F1, whatever the search finds.
gather <- function(con, plan, raw_weight = GATHER_RAW_WEIGHT, pin = NULL) {
  parts = plan_parts(plan)
  n = if (length(parts) == 1L) "one" else "part"
  one = n == "one"
  want_f = map_lgl(parts, function(pt) if (one) "formula" %in% plan$intents || !is.null(pin) else nzchar(pt$formula_query))
  Ps = map(parts, function(pt) part_passages(con, pt, plan$tags, GATHER_PASSAGES[[n]], raw_weight))
  P = bind_rows(Ps) |> distinct(passage_id, .keep_all = TRUE)
  Fp = pmap(list(parts, Ps, want_f), function(pt, pp, w) part_formulas(con, pt, pp, n, w))
  Fm = bind_rows(pin, Fp)
  Fm = if (nrow(Fm)) Fm |> distinct(group_id, .keep_all = TRUE) |> mutate(fid = paste0("F", row_number())) else tibble()
  Kc = bind_rows(pmap(list(parts, want_f, Fp), function(pt, w, f)
    part_code(con, pt, n, if (one) "code" %in% plan$intents else nzchar(pt$code_query), w, bind_rows(pin, f))))
  if (nrow(Kc)) Kc = Kc |> distinct(code_id, .keep_all = TRUE) |> mutate(cid = paste0("C", row_number()))
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

# A follow-up: the previous question and answer (the answer cut to CONTEXT_ANSWER_CHARS).
CONTEXT_ANSWER_CHARS <- 1500L
context_text <- function(context) {
  if (is.null(context) || !nzchar(context$question %||% "")) return("")
  paste0("Previous question:\n", context$question, "\n\nPrevious answer:\n", str_trunc(context$answer %||% "", CONTEXT_ANSWER_CHARS),
         "\n\nThe new question follows up on that exchange.\n\nQuestion:\n")
}

# The person's own design variables (My data on the Ask page), for the R code; empty fields left out.
DATA_FIELDS <- c(weight = "Weight variable", strata = "Strata variable", cluster = "Cluster (PSU) variable",
                 fpc = "Population size (finite population correction) variable", replicates = "Replicate weight variables",
                 outcomes = "Outcome variables",
                 design = "About the design")
data_text <- function(my_data) {
  x = keep(my_data %||% list(), function(v) is.character(v) && nzchar(str_squish(v)))
  x = x[intersect(names(DATA_FIELDS), names(x))]
  if (!length(x)) return("")
  paste0("\n\nThe person's data (use these names in any R code):\n", paste0("- ", DATA_FIELDS[names(x)], ": ", str_squish(unlist(x)), collapse = "\n"))
}

# A message of several parts: the parts to answer, each under its own heading.
parts_text <- function(plan) {
  parts = plan_parts(plan)
  more = if (isTRUE(plan$more_than_four)) paste0("\nThe message holds more than ", PLAN_PARTS, " questions. Answer only these ",
                                                 PLAN_PARTS, ", and end with one line asking the person to send the others separately.") else ""
  if (length(parts) < 2L) return(more)
  paste0("\n\nThe message asks ", length(parts), " separate questions. Answer each under its own short heading:\n",
         paste0(seq_along(parts), ". ", map_chr(parts, "question"), collapse = "\n"), more)
}

answer_user <- function(question, gathered, context = NULL, my_data = NULL) {
  no_f = if (!nrow(gathered$formulas)) "\n\nNo formula ids were given with these sources: write no {{F:...}} tokens." else ""
  q = if (nzchar(context_text(context))) paste0(context_text(context), question) else paste0("Question:\n", question)
  paste0(q, parts_text(gathered$plan), data_text(my_data), "\n\nSources:\n\n", sources_text(gathered), no_f)
}

# stream = TRUE returns ellmer's stream generator (chunks of text) with the chat as attribute "chat".
answer_question <- function(question, gathered, profile = MODEL_PROFILE, key = Sys.getenv(KEY_ENV), stream = FALSE,
                            context = NULL, my_data = NULL) {
  m = profile_model(profile)
  user = answer_user(question, gathered, context, my_data)
  if (stream) { chat = model_chat(m, "answer", read_reflex("answer.md"), key); return(structure(chat$stream(user), chat = chat)) }
  call_model(m, "answer", read_reflex("answer.md"), user, key)
}

# pin: a formula group to give first (the Formulas tab's "Show me how in R").
ask <- function(question, profile = MODEL_PROFILE, key = Sys.getenv(KEY_ENV), con = store_con(), plan = NULL,
                context = NULL, my_data = NULL, pin = NULL) {
  t0 = Sys.time()
  plan = plan %||% plan_question(question, profile, key, context)
  t1 = Sys.time()
  g = gather(con, plan, pin = pin)
  t2 = Sys.time()
  a = answer_question(question, g, profile, key, context = context, my_data = my_data)
  ask_result(question, plan, g, a, c(plan = as.numeric(difftime(t1, t0, units = "secs")), search = as.numeric(difftime(t2, t1, units = "secs"))))
}

# What ask() and the app's ask_async() return: the answer checked (against the sources as given),
#   then its sources renumbered in citation order and rendered; $cited lists the cited sources.
ask_result <- function(question, plan, g, a, sec, open_input = NULL) {
  rn = renumber_sources(a, g)
  r = render_answer(rn$answer, rn$gathered, open_input)
  use = compact(list(plan = attr(plan, "usage"), answer = attr(a, "usage")))
  list(question = question, plan = plan, gathered = g, answer = as.character(a), checks = check_answer(a, g),
       html = r$html, cited = rn$cited, sec = c(sec, answer = attr(a, "usage")$sec %||% NA_real_),
       usd = sum(map_dbl(use, "usd")), calls = length(use))
}


# ==== the app's calls ====
# The app's versions of the calls above. Each returns a promise, so a question in one session does
#   not hold up the others (ellmer's chat_async() and stream_async(), driven by later; no extra R process).

call_model_async <- function(m, kind, system, user, key, schema = NULL) {
  chat = model_chat(m, kind, system, key, schema)
  t0 = Sys.time()
  promises::then(chat$chat_async(user),
                 onFulfilled = function(txt) structure(as.character(txt), usage = chat_usage(chat, m, t0)),
                 onRejected = function(e) stop(gsub(key, "[key]", conditionMessage(e), fixed = TRUE), call. = FALSE))
}

plan_question_async <- function(question, profile, key, context = NULL) {
  req = plan_request(question, context)
  promises::then(call_model_async(profile_model(profile), "plan", req$system, req$user, key, req$schema),
                 function(r) plan_from_reply(r, req, question))
}

# The answer as it streams: on_text(text so far) after each chunk; resolves to the whole reply.
answer_stream_async <- function(question, gathered, profile, key, on_text = function(x) NULL, context = NULL, my_data = NULL) {
  m = profile_model(profile)
  chat = model_chat(m, "answer", read_reflex("answer.md"), key)
  t0 = Sys.time()
  gen = chat$stream_async(answer_user(question, gathered, context, my_data))
  acc = new.env()
  acc$text = ""
  pump = function() promises::then(gen(), function(x) {
    if (coro::is_exhausted(x)) return(structure(acc$text, usage = chat_usage(chat, m, t0)))
    acc$text = paste0(acc$text, x)
    on_text(acc$text)
    pump()
  })
  promises::catch(pump(), function(e) stop(gsub(key, "[key]", conditionMessage(e), fixed = TRUE), call. = FALSE))
}

# plan, search, answer; on_stage("plan" | "search" | "answer") as each starts. Resolves to ask_result().
ask_async <- function(question, profile, key, con, context = NULL, my_data = NULL, open_input = NULL,
                      on_stage = function(s) NULL, on_text = function(x) NULL, pin = NULL) {
  t0 = Sys.time()
  on_stage("plan")
  promises::then(plan_question_async(question, profile, key, context), function(plan) {
    t1 = Sys.time()
    on_stage("search")
    g = gather(con, plan, pin = pin)
    t2 = Sys.time()
    on_stage("answer")
    promises::then(answer_stream_async(question, g, profile, key, on_text, context, my_data), function(a)
      ask_result(question, plan, g, a, c(plan = as.numeric(difftime(t1, t0, units = "secs")),
                                         search = as.numeric(difftime(t2, t1, units = "secs"))), open_input))
  })
}
