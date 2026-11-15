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
r <- render_answer(rn$answer, rn$gathered, "ask-open")
ok("render_answer puts the stored formula in as MathML, with a numbered link to its source and the dotted-text legend",
   grepl("<math", r$html) && grepl("source \\d", r$html) && !grepl("{{F:", r$html, fixed = TRUE) && grepl("Dotted text", r$html) &&
     grepl(">1</a>]", r$html, fixed = TRUE))
stub_ask <- function(question, profile, key, con, context, my_data, open_input, on_stage, on_text) {
  on_stage("plan"); on_stage("search"); on_stage("answer"); on_text("The ratio estimator")
  promises::promise_resolve(ask_result(question, plan, g, canned, c(plan = 0, search = 0), open_input))
}

shiny::testServer(ask_server, args = list(state = reactiveValues(key_version = 0L, calls = 0L), con = con, asker = stub_ask), {
  set_session_key("not-a-real-key", session$token)
  session$setInputs(question = plan$question, weight = "wt", strata = "", cluster = "", fpc = "", replicates = "",
                    outcomes = "", design = "", ask = 1)
  settle(session, function() !is.null(result()))
  ok("Ask: the answer shows one collapsed Sources line with only the cited sources, and no count of uncited sentences",
     grepl("<math", output$answer$html) && grepl(sprintf("<summary>Sources (%d)</summary>", nrow(result()$cited)), output$answer$html, fixed = TRUE) &&
       nrow(result()$cited) < nrow(g$sources) && !grepl("no citation", output$answer$html))
  ok("Ask: two calls counted for the session", calls_made(session$token) == 2L)
  ok("Ask: the answer is kept for a follow-up", identical(context()$question, plan$question))
  session$setInputs(open = "S1")
  ok("Ask: clicking a source opens its passage in a window", identical(shown(), "S1"))
  session$setInputs(new_topic = 1)
  ok("Ask: New topic clears the follow-up", is.null(context()))
})

shiny::testServer(formulas_server, args = list(con = con), {
  session$setInputs(query = "variance of the ratio estimator", role = NULL, design = NULL, topic = NULL, course = NULL, general = TRUE)
  session$elapse(500)
  ok("Formulas: a search lists formula groups", nrow(found()) > 0 && grepl("ratio", html_of(output$results), ignore.case = TRUE))
  session$setInputs(pick = found()$group_id[1])
  ok("Formulas: a formula shows its MathML, symbols and places", grepl("<math", html_of(output$detail)) && grepl("Where it occurs", html_of(output$detail)))
  session$setInputs(open = unlist(found()$place_ids[1])[1])
  ok("Formulas: a place opens the source card", grepl("Text file", html_of(output$`card-body`)))
})

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
ok("Start here: the figure is in www/ with its title as alt text", file.exists(file.path("www", START_FIGURE)) &&
     grepl("Total Survey Error", svg_title(START_FIGURE)) && grepl("fw_tse.svg", as.character(start_ui("start"))))
shiny::testServer(start_server, args = list(state = reactiveValues(key_version = 0L, calls = 0L)), {
  page = paste(html_of(output$text), output$calls)
  ok("Start here: the page text and the call line show, with no library table and no jargon",
     grepl("Total\\s+Survey\\s+Error", page) && grepl("Not from the library", page) && !grepl("Code examples", page) &&
       grepl("2 model calls", output$calls) && !grepl(JARGON_RX, page))
  session$setInputs(`key-key` = "not-a-real-key", `key-save` = 1)
  ok("Start here: a pasted key is held for the session", identical(session_key(session$token), "not-a-real-key"))
})
shiny::testServer(methodology_server, args = list(con = con), {
  page = html_of(output$text)
  ok("Methodology: the page, its collapsed panels and the library table in plain words show, with no jargon",
     grepl("<details><summary>More detail</summary>", page, fixed = TRUE) && grepl("Graduate coursework in survey methodology", page) &&
       grepl("Code examples", page) && !grepl("{{LIBRARY_TABLE}}", page, fixed = TRUE) && !grepl(JARGON_RX, page))
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
