# Smoke test for SurvAI_Expert. No API calls and no key: the model calls are stubbed. Not deployed
#   (tests/ is in .rscignore). Run from inside SurvAI_Expert/:  Rscript --no-init-file tests/smoke.R
# Each check prints "ok" or stops the script with "FAIL" and the check's name.

stopifnot("Run from inside SurvAI_Expert/" = file.exists("app.R") && dir.exists("www/reflexes"))

ok <- function(what, cond) {
  if (!isTRUE(cond)) stop("FAIL: ", what, call. = FALSE)
  cat("ok  ", what, "\n", sep = "")
}
html_of <- function(x) paste(as.character(if (is.list(x)) x$html else x), collapse = "")
# Lets promises and the ExtendedTask finish: run later's queue and flush, up to n times (no loop).
settle <- function(session, done, n = 100) {
  later::run_now(0.05)
  session$flushReact()
  if (isTRUE(done()) || n == 0) return(invisible(isTRUE(done())))
  settle(session, done, n - 1)
}

# ---- the app loads, the store opens --------------------------------------------------------------

app <- shiny::shinyAppDir(".")   # loaded the way Connect loads it
ok("app.R loads as a Shiny app directory", inherits(app, "shiny.appobj"))
ok("the settings R/ reads are in the global environment",
   all(c("APP_CLASSIFICATION", "MODEL_PROFILE", "APP_SOURCE_URL", "CALLS_PER_WINDOW", "STORE_PATH") %in% ls(globalenv())))
ok("two profiles; home is Claude Sonnet 5.5; work stops with a plain message until filled in",
   identical(names(MODEL_PROFILES), c("home", "work")) && identical(MODEL_PROFILES$home$id, "claude-sonnet-5-5") &&
     grepl("not filled in", tryCatch(profile_model("work"), error = conditionMessage)))
ok("no file the app runs reads a key from the environment",
   local({ code = unlist(map(c("app.R", list.files("R", full.names = TRUE)), readLines, warn = FALSE))
           all(grepl("SURVAI_PROFILE|KEY_ENV", grep("Sys.getenv(", code, fixed = TRUE, value = TRUE))) }))
con <- store_connect(STORE_PATH)
ok("the store opens read only and has passages, formulas and code", local({
  n = store_counts(con)
  sum(n$Passages) > 1000 && sum(n$Formulas) > 1000 && sum(n$`Code examples`) > 1000 &&
    inherits(tryCatch(dbExecute(con, "CREATE TABLE x (a INTEGER)"), error = function(e) e), "error") }))

# ---- canned question: plan and answer stubbed ------------------------------------------------------

plan <- list(question = "What is the variance of the ratio estimator under simple random sampling?",
             intents = c("formula", "concept"), queries = c("variance ratio estimator simple random sampling"),
             tags = list(tse = "sampling", stage = "variance estimation", design = "SRS", topic = "ratio estimation"),
             formula_query = "variance of the ratio estimator", code_query = "", dropped = NULL)
g <- gather(con, plan)
ok("gather finds passages and formulas for the canned question", nrow(g$sources) >= 10 && nrow(g$formulas) >= 1)
fs <- g$sources$label[g$sources$kind == "formula"][1]   # the formula's own source
canned <- structure(paste0("The ratio estimator's variance is approximated by linearization [S3].\n\n{{F:F1}}\n\n",
                           "Not from the library: this is a large-sample result.\n\nIt is smaller when $y$ and $x$ are correlated. ",
                           "It is used for ratios of totals [S1, S3]."),
                    usage = list(sec = 0, usd = 0, tokens = c(input = 0, output = 0, cached = 0)))
ck <- check_answer(canned, g)
ok("check_answer: citations and tokens valid, one uncited sentence counted",
   ck$cites_valid && ck$tokens_valid && !ck$display_math && ck$uncited == 1L && ck$not_from_library == 1L)
rn <- renumber_sources(canned, g)
ok("sources are renumbered in citation order, the formula's source counted where its token stands, no passage twice",
   identical(rn$cited$passage_id, unique(g$sources$passage_id[match(c("S3", fs, "S1"), g$sources$label)])) &&
     grepl("linearization [S1]", rn$answer, fixed = TRUE) && !anyDuplicated(rn$cited$passage_id) &&
     identical(rn$cited$label, paste0("S", seq_len(nrow(rn$cited)))))
ok("a citation of a source that was not given shows as [?]", grepl("[?]", renumber_sources("A fact [S99].", g)$answer, fixed = TRUE))
r <- render_answer(rn$answer, rn$gathered, "ask-open", show = TRUE)
ok("sources shown: the stored formula as MathML, a numbered link to its source and the dotted-text legend",
   grepl("<math", r$html) && grepl("source \\d", r$html) && !grepl("{{F:", r$html, fixed = TRUE) && grepl("Dotted text", r$html) &&
     grepl(">1</a>]", r$html, fixed = TRUE))
r0 <- render_answer(rn$answer, rn$gathered, "ask-open", show = FALSE)
ok("sources hidden: the formula is shown, with no citation, no source link, no dotted text and no legend",
   grepl("<math", r0$html) && !grepl("[S", r0$html, fixed = TRUE) && !grepl("survai-open", r0$html) && !grepl("source \\d", r0$html) &&
     !grepl("survai-uncited|Dotted text", r0$html) && grepl("linearization.</p>", r0$html, fixed = TRUE))
ok("sources hidden: a Check: sentence no longer names source numbers",
   identical(hide_sources("Check: S2 and S4 give different denominators [S2, S4]."), "Check: the passages give different denominators."))

ok("a formula question also gathers R code, and a pinned formula comes first", local({
  pin = find_formulas(con, "design effect intraclass correlation", k = 1)
  gp = gather(con, plan, pin = pin)
  nrow(g$code) > 0 && identical(gp$formulas$group_id[1], pin$group_id) && gp$formulas$fid[1] == "F1"
}))

# ---- advice mode: plan, gather, the answer's request and its checks (no model) ---------------------------------

plan_a <- structure(clean_plan(list(mode = "advice", decision = "Whether to trim the raked weights", error_sources = c("adjustment", "sampling", "made up"),
  intents = c("advice", "formula"), tags = list(tse = "adjustment", stage = "weighting", design = list(), topic = c("raking", "weight trimming")),
  parts = list(list(question = "variance cost of unequal weights", queries = c("unequal weighting effect design effect weights"),
                    formula_query = "design effect unequal weighting", code_query = ""),
               list(question = "bias from trimming weights", queries = c("weight trimming bias variance trade-off"), formula_query = "", code_query = "")),
  more_than_four = FALSE), read_vocab(), "After raking my weights run from 0.1 to 25. Should I trim them?"), usage = NULL)
ok("an advice plan keeps its mode, decision and known error sources; a plan with no mode is a lookup",
   plan_a$mode == "advice" && nzchar(plan_a$decision) && identical(plan_a$error_sources, c("adjustment", "sampling")) &&
     clean_plan(list(intents = "concept", tags = list(), parts = list()), read_vocab(), "What is raking?")$mode == "lookup" &&
     force_mode(plan_a, "lookup")$mode == "lookup" && force_mode(plan_a, "auto")$mode == "advice" && force_mode(plan_a, NULL)$mode == "advice")
g_a <- gather(con, plan_a)
ok("advice gathers at most 12 passages, at most 2 from one document, across its parts, with a formula",
   local({ P = g_a$sources[g_a$sources$kind == "passage", ]
           nrow(P) >= 6 && nrow(P) <= GATHER_ADVICE_PASSAGES && max(table(P$doc_id)) <= GATHER_PER_DOC && nrow(g_a$formulas) >= 1 }))
my_survey <- list(population = "adults in the country", counts = "5,000 selected, 1,400 answered", weight = "wt", strata = "", cluster = "psu")
ok("the request for advice names the decision, the error sources, the survey and the columns, and does not split into questions",
   local({ u = answer_user(plan_a$question, g_a, NULL, my_survey)
           grepl("The decision the person faces: Whether to trim", u, fixed = TRUE) && grepl("Sources of error at stake: adjustment, sampling", u, fixed = TRUE) &&
             grepl("The person's survey (take it into account):", u, fixed = TRUE) && grepl("Who the survey is about: adults", u, fixed = TRUE) &&
             grepl("The person's data (use these names in any R code):", u, fixed = TRUE) && grepl("Weight variable: wt", u, fixed = TRUE) &&
             !grepl("separate questions", u) && !grepl("Strata variable", u) }))
ok("advice is written from advise.md, a lookup from answer.md; the plan request carries the survey",
   grepl("My assessment", answer_reflex(plan_a), fixed = TRUE) && !grepl("What I would do", answer_reflex(plan), fixed = TRUE) &&
     grepl("Who the survey is about: adults", plan_request("Should I trim?", NULL, my_survey)$user, fixed = TRUE) &&
     all(c("mode", "decision", "error_sources") %in% names(plan_request("x")$schema$properties)))
advice <- structure(paste0("## What I understand\nYou raked and the weights now vary a lot.\n\n## Options\n",
  "- Trim the largest weights. Trimming lowers variance but can add bias [S1].\n- Collapse the cells that produce them [S2].\n\n",
  "## What I would do\nMy assessment: with weights from 0.1 to 25 I would first collapse sparse categories and then re-rake.\n",
  "This statement about methods has no source at all.\n\n## What to check\n- Compare the estimates both ways.\n\n",
  "## To sharpen this\n- How many categories does each raking variable have?"),
  usage = list(sec = 0, usd = 0, tokens = c(input = 0, output = 0, cached = 0)))
ck_a <- check_answer(advice, g_a)
ok("advice checks: the headings are found, the assessment is counted and not flagged, one unsourced statement is",
   !length(ck_a$headings_missing) && ck_a$assessments == 1L && ck_a$uncited == 1L && ck_a$cites_valid &&
     identical(check_answer(sub("## Options", "## Choices", advice), g_a)$headings_missing, "Options") &&
     !length(check_answer(advice, g)$headings_missing))
ok("an advice answer renders, and the result records its mode",
   local({ r = ask_result(plan_a$question, plan_a, g_a, advice, c(plan = 0, search = 0), "ask-open")
           r$mode == "advice" && grepl("What I would do", r$html) && grepl("My assessment", r$html) }))
ok("follow-ups keep the last three exchanges, oldest dropped; the older single exchange still reads",
   local({ cx = reduce(1:4, function(a, i) add_turn(a, paste("q", i), paste("a", i)), .init = NULL)
           length(cx$turns) == CONTEXT_TURNS && cx$turns[[1]]$question == "q 2" && grepl("q 4", context_text(cx), fixed = TRUE) &&
             !grepl("q 1", context_text(cx), fixed = TRUE) && grepl("old q", context_text(list(question = "old q", answer = "old a"))) &&
             context_text(NULL) == "" }))
ok("a refused call says which profile setting to change, and never shows the key",
   local({ e = call_error(simpleError("HTTP 400: 'response_format' is not supported; key sk-123"), "sk-123")
           grepl("json = \"prompt\"", e, fixed = TRUE) && !grepl("sk-123", e) && grepl("stream = FALSE", call_error(simpleError("stream not allowed"), "k")) &&
             identical(call_error(simpleError("timeout"), "k"), "timeout") }))
ok("the work profile is OpenAI-compatible with the settings every endpoint accepts",
   with(MODEL_PROFILES$work, api == "openai" && json == "prompt" && isFALSE(stream) && is.null(effort)))
json_again_check <- function() {
  real = call_model
  on.exit(assign("call_model", real, envir = globalenv()))
  seen = new.env()
  seen$users = character()
  assign("call_model", function(m, kind, system, user, key, schema = NULL) {
    seen$users = c(seen$users, user)
    structure(if (length(seen$users) == 1L) "Here it is: {not json" else "{\"a\": 1}",
              usage = list(tokens = c(input = 1, output = 1, cached = 0), sec = 1, usd = 0.5))
  }, envir = globalenv())
  j = call_json(list(), "judge", "system", "question", "k")
  identical(j$a, 1L) && attr(j, "usage")$usd == 1 && length(seen$users) == 2L && grepl("not one valid JSON", seen$users[2], fixed = TRUE)
}
ok("a reply that is not valid JSON is asked for once more, and both calls are counted", json_again_check())

stub_ask <- function(question, profile, key, con, context, my_data, open_input, on_stage, on_text = function(x) NULL, pin = NULL, mode = NULL) {
  on_stage("plan"); on_stage("search"); on_stage("answer"); on_text("The ratio estimator")
  .stub$my_data = my_data
  .stub$mode = mode
  .stub$pin = pin
  .stub$question = question
  promises::promise_resolve(ask_result(question, plan, g, canned, c(plan = 0, search = 0), open_input))
}
.stub <- new.env()

run_ask <- function(show) {
  SHOW_SOURCES <<- show
  state = reactiveValues(key_version = 0L, calls = 0L)
  shiny::testServer(ask_server, args = list(state = state, con = con, asker = stub_ask), {
    set_session_key("not-a-real-key", session$token)
    session$setInputs(question = plan$question, weight = "wt", strata = "strat", cluster = "psu", fpc = "", replicates = "",
                      outcomes = "", design = "", ask = 1)
    settle(session, function() !is.null(result()))
    h = output$answer$html
    if (show) {
      ok("Ask, sources shown: one collapsed Sources line with only the cited sources, no count of uncited sentences",
         grepl("<math", h) && grepl(sprintf("<summary>Sources (%d)</summary>", nrow(result()$cited)), h, fixed = TRUE) &&
           nrow(result()$cited) < nrow(g$sources) && !grepl("no citation", h))
      ok("Ask: two calls counted for the session", calls_made(session$token) == 2L)
      ok("Ask: the answer is kept for a follow-up", identical(context()$turns[[1]]$question, plan$question))
      ok("Ask: left to the tool, no mode is forced; the mode used is shown under the answer",
         is.null(.stub$mode) && grepl("Quick answer, written from the library", h, fixed = TRUE))
      session$setInputs(answer_mode = "advice", population = "adults", ask = 2)
      settle(session, function() identical(.stub$mode, "advice"))
      ok("Ask: 'Advise me' forces advice, and My survey reaches the question", identical(.stub$mode, "advice") && identical(.stub$my_data$population, "adults"))
      session$setInputs(open = "S1")
      ok("Ask: clicking a source opens its passage in a window", identical(shown(), "S1"))
      session$setInputs(new_topic = 1)
      ok("Ask: New topic clears the follow-up", is.null(context()))
    } else {
      ok("Ask, sources hidden: the answer has its formula but no citations, no Sources line and no dotted text",
         grepl("<math", h) && !grepl("<summary>Sources", h, fixed = TRUE) && !grepl("survai-open|survai-uncited", h) &&
           result()$checks$cites == 2L)
      ok("Ask: My data is shared with the other tabs", identical(state$my_data$cluster, "psu"))
    }
  })
  state
}
invisible(run_ask(TRUE))
my_state <- run_ask(FALSE)

run_formulas <- function(show) {
  SHOW_SOURCES <<- show
  ui = as.character(formulas_ui("formulas"))
  shiny::testServer(formulas_server, args = list(state = my_state, con = con, asker = stub_ask), {
    session$setInputs(query = "variance of the ratio estimator", role = NULL, design = NULL, topic = NULL, course = NULL, general = TRUE)
    session$elapse(500)
    ok(sprintf("Formulas (sources %s): a search lists formula groups", if (show) "shown" else "hidden"),
       nrow(found()) > 0 && grepl("ratio", html_of(output$results), ignore.case = TRUE))
    session$setInputs(pick = found()$group_id[1])
    d = html_of(output$detail)
    ok(sprintf("Formulas (sources %s): a formula shows its MathML, symbols, R examples and the Show me how button", if (show) "shown" else "hidden"),
       grepl("<math", d) && grepl("R examples from the library", d) && grepl("Show me how in R", d) && grepl("2 model calls", d) &&
         (grepl("survai-code", d) || grepl("No example in the library for this formula.", d, fixed = TRUE)))
    if (show) {
      ok("Formulas, sources shown: courses, documents and the places of a formula are listed",
         grepl("Where it occurs", d) && grepl(">Course<", ui) && grepl("text-muted", html_of(output$results)))
      session$setInputs(open = unlist(found()$place_ids[1])[1])
      ok("Formulas: a place opens the source card", grepl("Text file", html_of(output$`card-body`)))
    } else {
      ok("Formulas, sources hidden: no course, document or places", !grepl("Where it occurs", d) && !grepl(">Course<", ui) &&
           !grepl("text-muted", html_of(output$results)))
      set_session_key("not-a-real-key", session$token)
      session$setInputs(how_btn = 1)
      settle(session, function() !is.null(how()))
      ok("Formulas: Show me how in R asks about this formula, pinned first, with My data from the Ask tab",
         identical(.stub$pin$group_id, found()$group_id[1]) && identical(.stub$my_data$weight, "wt") &&
           grepl(found()$name[1], .stub$question, fixed = TRUE) && grepl("<math", html_of(output$how)))
    }
  })
}
run_formulas(TRUE)
run_formulas(FALSE)
ok("formula_examples: code from the formula's passage or its neighbours, at most 3, no output blocks", local({
  f = find_formulas(con, "design effect intraclass correlation", k = 1)
  ex = formula_examples(con, f$place_ids, f$name)
  nrow(ex) <= 3L && !any(dbGetQuery(con, sprintf("SELECT is_output FROM code WHERE code_id IN (%s)",
                                                  paste(dbQuoteString(con, c(ex$code_id, "none")), collapse = ", ")))$is_output)
}))

# A small PDF with text, made here; and a Word file when a zip program is at hand.
pdf_file <- tempfile(fileext = ".pdf")
grDevices::pdf(pdf_file)
plot.new()
walk(1:8, function(i) text(0.5, 1 - i / 10, paste("The base weight is the inverse of the selection probability, line", i)))
invisible(grDevices::dev.off())
rp <- report_text(pdf_file, "report.pdf")
ok("Report: text and pages come out of a PDF", is.null(rp$note) && length(rp$pages) == 1L && grepl("base weight", rp$pages))
ok("Report: one call for a short report, parts plus one for a long one",
   report_calls(report_parts(rp$pages)) == 1L && report_calls(report_parts(rep(strrep("x", 200000), 4))) == 5L)
if (nzchar(Sys.which("zip"))) local({
  d = tempfile(); dir.create(file.path(d, "word"), recursive = TRUE)
  writeLines(paste0('<?xml version="1.0"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">',
                    '<w:body><w:p><w:r><w:t>Variance is estimated with 80 jackknife replicate weights.</w:t></w:r></w:p></w:body></w:document>'),
             file.path(d, "word", "document.xml"))
  f = file.path(d, "r.docx")
  old = setwd(d); utils::zip(f, "word/document.xml", flags = "-q"); setwd(old)
  ok("Report: text comes out of a Word file", grepl("jackknife", report_text(f, "r.docx")$pages[1]))
}) else cat("--   Report: no zip program here, the Word check is skipped\n")

stub_read <- function(rep, profile, key) promises::promise_resolve(list(text = "## 1. Survey at a glance\nnot stated (p. 1)", calls = 1L, usd = 0))
shiny::testServer(report_server, args = list(state = reactiveValues(key_version = 0L, calls = 0L), reader = stub_read), {
  set_session_key("not-a-real-key", session$token)
  session$setInputs(file = data.frame(name = "report.pdf", size = file.size(pdf_file), type = "application/pdf", datapath = pdf_file))
  ok("Report: the page says how many calls it will use", grepl("1 model call", html_of(output$about)))
  session$setInputs(read = 1)
  settle(session, function() grepl("Survey at a glance", tryCatch(html_of(output$summary), error = function(e) "")))
  ok("Report: the stubbed reading is shown", grepl("Survey at a glance", html_of(output$summary)))
})

JARGON_RX <- "JPSM|SURV\\d|DuckDB|RAG|BM25|jpsm|practools|tidysurvey|survey package|srvyr|ellmer|shiny|Claude|store"
ok("Start here: both figures are in www/ and have a title", all(file.exists(file.path("www", START_FIGURES))) &&
     grepl("Total Survey Error", svg_title(START_FIGURES[[1]])) && nzchar(svg_title(START_FIGURES[[2]])))
shiny::testServer(start_server, args = list(state = reactiveValues(key_version = 0L, calls = 0L)), {
  page = paste(html_of(output$text), output$calls)
  ok("Start here: the text with both figures in place (title as alt text), the call line, no jargon",
     grepl("Total\\s+Survey\\s+Error", page) && grepl("How it was built", page) && !grepl("[TSE figure]", page, fixed = TRUE) &&
       all(map_lgl(START_FIGURES, function(f) grepl(sprintf("<img src=\"%s\" alt=\"%s\"", f, svg_title(f)), page, fixed = TRUE))) &&
       grepl("2 model calls", output$calls) && !grepl(JARGON_RX, gsub("<img[^>]*>", "", page)))
  session$setInputs(`key-key` = "not-a-real-key", `key-save` = 1)
  ok("Start here: a pasted key is held for the session", identical(session_key(session$token), "not-a-real-key"))
})
shiny::testServer(methodology_server, args = list(con = con), {
  page = html_of(output$text)
  ok("Methodology: the page, its collapsed panels and the library table in plain words show, with no jargon",
     grepl("<details><summary>More detail</summary>", page, fixed = TRUE) && grepl("Graduate coursework in survey methodology", page) &&
       grepl("Code examples", page) && !grepl("{{LIBRARY_TABLE}}", page, fixed = TRUE) && !grepl(JARGON_RX, page) &&
       grepl("The sources of error", page) && grepl("How it keeps answers accurate", page) && grepl("Not from the library", page) &&
       !grepl("click|dotted", page, ignore.case = TRUE))
})
ok("a plan of several parts searches each part, without duplicates", local({
  p2 = clean_plan(list(intents = list("formula"), tags = list(), more_than_four = FALSE, parts = data.frame(
    question = c("Neyman allocation formula", "design effect for a cluster sample"), formula_query = c("Neyman allocation", "design effect intraclass correlation"),
    code_query = c("", ""), queries = I(list(c("Neyman allocation strata"), c("deff design effect cluster intraclass correlation"))))), read_vocab(), "two questions")
  g2 = gather(con, p2)
  length(p2$parts) == 2L && !anyDuplicated(g2$sources$passage_id[g2$sources$kind == "passage"]) &&
    sum(g2$sources$kind == "passage") <= 12L && nrow(g2$formulas) <= 6L && grepl("2 separate questions", parts_text(p2))
}))
dbDisconnect(con)
cat("All checks passed.\n")
