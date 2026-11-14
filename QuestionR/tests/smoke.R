# Smoke test for QuestionR. No API calls. Not deployed (tests/ is in .rscignore).
# Run from inside QuestionR/, without the user profile so it is closer to Connect:
#   Rscript --no-init-file tests/smoke.R
# Each check prints "ok" or stops the script with "FAIL" and the check's name.

stopifnot("Run from inside QuestionR/" = file.exists("app.R") && dir.exists("www/reflexes"))

ok <- function(what, cond) {
  if (!isTRUE(cond)) stop("FAIL: ", what, call. = FALSE)
  cat("ok  ", what, "\n", sep = "")
}
n_in <- function(pattern, txt) lengths(regmatches(txt, gregexpr(pattern, txt, fixed = TRUE)))
html_of <- function(x) if (is.list(x) && !is.null(x$html)) as.character(x$html) else paste(as.character(x), collapse = "")
# The words on a page: tags gone, a text box shown by its value, buttons and scripts left out.
see_text <- function(h) {
  h = gsub("(?s)<script.*?</script>", " ", paste(h, collapse = " "), perl = TRUE)
  h = gsub("(?s)<button.*?</button>", " ", h, perl = TRUE)
  h = gsub("<input[^>]*value=\"([^\"]*)\"[^>]*>", " \\1 ", h)
  h = gsub("<[^>]+>", " ", h)
  h = gsub("&amp;", "&", gsub("&lt;", "<", gsub("&gt;", ">", gsub("&#39;", "'", gsub("&quot;", "\"", h)))))
  gsub("\\s+", " ", trimws(h))
}
words_of <- function(x) tolower(unlist(regmatches(x, gregexpr("[[:alnum:]]+", x))))
fails_with <- function(expr, class = "llm_error") {
  e = tryCatch({ expr; NULL }, error = function(e) e)
  if (inherits(e, class)) e else NULL
}


# ---- the app loads ---------------------------------------------------------------

# Loaded the way Connect loads it. source("app.R") would hide an object that R/ cannot see.
app <- shiny::shinyAppDir(".")
ok("app.R loads as a Shiny app directory", inherits(app, "shiny.appobj") && is.function(app$serverFuncSource()))
ok("the settings R/ reads are in the global environment",
   all(c("APP_CLASSIFICATION", "APP_PROFILE", "APP_MODEL", "APP_MAX_PASTE_CHARS") %in% ls(globalenv())))
ok("the Cairo bitmap type is set", identical(getOption("bitmapType"), "cairo"))
ok("two profiles, each a main model and a drafter on one pasted key; home is Sonnet 5.5 with a Sonnet 4.5 drafter, work is placeholders",
   identical(names(APP_PROFILES), c("home", "work")) &&
     identical(APP_PROFILES$home$id, "claude-sonnet-5-5") && identical(APP_PROFILES$home$drafter$id, "claude-sonnet-4-5") &&
     identical(app_models(APP_PROFILES$home)$Drafter$api, "anthropic") &&
     identical(purrr::map(app_models(APP_PROFILES$work), llm_placeholders), list(`Main model` = c("base_url", "id"), Drafter = c("base_url", "id"))) &&
     identical(names(app_models(APP_PROFILES$home["id"])), "Main model") &&
     !any(grepl("key_source|key_var|openrouter", deparse(APP_PROFILES), ignore.case = TRUE)))
ok("no file the app runs reads the environment except for the profile's name",
   local({
     code = unlist(purrr::map(c("app.R", list.files("R", full.names = TRUE)), readLines, warn = FALSE))
     calls = grep("Sys.getenv(", code, fixed = TRUE, value = TRUE)
     length(calls) == 1L && grepl("QUESTIONR_PROFILE", calls)
   }))

page <- local({
  req = list(REQUEST_METHOD = "GET", PATH_INFO = "/", QUERY_STRING = "", SCRIPT_NAME = "",
             SERVER_NAME = "localhost", SERVER_PORT = "80", HTTP_HOST = "localhost",
             HTTP_ACCEPT_ENCODING = "", rook.url_scheme = "http")
  resp = app$httpHandler(req)
  list(status = resp$status,
       html = if (is.character(resp$content)) resp$content
              else paste(readLines(resp$content$file, warn = FALSE), collapse = "\n"))
})
ok("the page is served with the classification banner", isTRUE(page$status == 200) && grepl(APP_CLASSIFICATION, page$html, fixed = TRUE))


# ---- the reflex files, and prompts R assembles -------------------------------------------

rfiles <- check_reflex_files()
ok("every reflex file parses, core.md has the persona, the files R reads a reply for have an Output format",
   identical(names(rfiles), REFLEX_FILES) && !is.na(rfiles[["core.md"]]$persona) &&
     all(purrr::map_lgl(rfiles[REFLEX_FILES_WITH_OUTPUT], function(s) !is.na(s$output_format))))

try_reflex_file <- function(body, name = "fixture.md") {
  p = file.path(tempdir(), name)
  writeLines(c("# Fixture", "", "Version: 0.1", "", body), p)
  tryCatch(parse_reflex_file(p), error = function(e) conditionMessage(e))
}
good <- try_reflex_file(c("<!-- a note -->", "## Reflexes", "", "### fine_one", "- **When:** Always.",
                          "- **Say:** Do it.", "- **Check:** Was it done?", "- **Source:** A book.", "",
                          "## Prohibitions", "", "- Never lie.", "", "## Output format", "", "Return JSON."))
ok("a well-formed fixture parses, keeping Check and Source",
   is.list(good) && identical(good$reflexes$fine_one$check, "Was it done?") &&
     identical(good$reflexes$fine_one$source, "A book.") && identical(good$output_format, "Return JSON."))
refl <- function(...) c("## Reflexes", "", "### oops", ...)
says <- function(msg, ...) grepl(msg, try_reflex_file(...), fixed = TRUE)
ok("the parser refuses, naming the file and the reflex: no Say, a misspelt field, a wrapped line, a repeated or empty field",
   says("Reflex 'oops' in fixture.md needs a When and a Say line.", refl("- **When:** Always.")) &&
     says("Reflex 'oops' in fixture.md has a line that is not a field", refl("- **When:** A.", "- **Sey:** B.")) &&
     says("has a line that is not a field", refl("- **When:** A.", "- **Say:** B", "  and more.")) &&
     says("has the field Say twice", refl("- **When:** A.", "- **Say:** B.", "- **Say:** C.")) &&
     says("has a field with nothing in it", refl("- **When:** A.", "- **Say:**")))
ok("the parser refuses a bad id, a repeated id, text before the first reflex, an unknown section, an open comment",
   says("needs an id in lower case", c("## Reflexes", "", "### Not-Ok", "- **When:** A.", "- **Say:** B.")) &&
     says("two reflexes called 'oops'", c(refl("- **When:** A.", "- **Say:** B."), "### oops", "- **When:** A.", "- **Say:** B.")) &&
     says("before the first '### id'", c("## Reflexes", "stray", "### oops", "- **When:** A.", "- **Say:** B.")) &&
     says("not part of the format: '## Reflex'", c("## Reflex", "### oops", "- **When:** A.", "- **Say:** B.")) &&
     says("never closed", c("<!-- open", refl("- **When:** A.", "- **Say:** B."))))

ok("a Label of more than six words, and an Applies line outside attitudinal, behavioral, sensitive and any, are refused",
   says("Label of more than 6 words", refl("- **When:** A.", "- **Say:** B.", "- **Label:** one two three four five six seven")) &&
     says("Applies line that is not", refl("- **When:** A.", "- **Say:** B.", "- **Applies:** factual")) &&
     identical(try_reflex_file(refl("- **When:** A.", "- **Say:** B.", "- **Applies:** behavioral, any"))$reflexes$oops$applies, c("behavioral", "any")))
ok("every reflex with a Check line has a Label",
   all(purrr::map_lgl(unlist(purrr::map(rfiles, function(s) unname(s$reflexes)), recursive = FALSE), function(r) is.na(r$check) || !is.na(r$label))))

# The reflex files are edited only in the Claude project; a change here must be deliberate. When one
#   is, the new sums go here (tests/smoke.R prints them when they differ).
REFLEX_SHA <- c(
  `core.md` = "5341dacfd7ac50eaa56f5b1111cf0bfec03f1103b744e7aca0df7a5670b1e91d",
  `generate.md` = "82597d181d064f2d44591746cee2c3294a7e50de646ec536b57c57ac4a03f4b1",
  `attitudinal.md` = "6b5ac03131037228dfa36efabc90ac25def227aecd4a7fc71ecd14e85bf31217",
  `behavioral.md` = "2225e8f6ea521938ddc3a3529dbd6475814396205d22120fdb0d44761ce71830",
  `sensitive.md` = "f079dca7fce7782f9616944d55487eb8784c10f8e715759e8d8a760a0d47eac2",
  `evaluate.md` = "1ab3a224876db451ed93cde5941f2faa4085e4258390db997279019431ece128",
  `mode.md` = "5a8271c5b6116040085f23d325d05446a9e66a0a9106cc327feb76c52c001026",
  `refine.md` = "059748adccf547e710efefc9b25f209f893bcd8823709d98ad09b263afa83ec0")
sha_now <- purrr::map_chr(rfiles, "sha")
if (!identical(sha_now, REFLEX_SHA)) print(sha_now)
ok("the reflex files are the ones checksummed here", identical(sha_now, REFLEX_SHA))

forms <- list(
  attitudinal = list(task = "attitudinal", research_question = "Trust in local services",
                     construct = "Trust in the town council", population = "Adults in [town]",
                     country = "[country]", modes = c("web", "telephone"), n_items = 3L),
  behavioral = list(task = "behavioral", research_question = "Use of buses", construct = "Bus use",
                    population = "Adults", modes = "web", n_items = 2L, reference_period = "the past 7 days"),
  sensitive = list(task = "sensitive", research_question = "Gambling", construct = "Gambling frequency",
                   population = "Adults", modes = "face_to_face", n_items = 2L),
  evaluate = list(task = "evaluate", research_question = "Satisfaction with services", population = "Adults",
                  modes = "web", questionnaire = "Q1. How satisfied are you with the bus and the train?\n1 Very\n2 Not\n\nQ2. Do you own a car?\n1 Yes\n2 No"))
prompt_of <- function(fm) if (fm$task == "evaluate") build_step_prompt(fm, "items", part = review_plan(fm$questionnaire)[[1]]) else build_prompt(fm)
built <- purrr::map(forms, prompt_of)
persona <- persona_split(rfiles[["core.md"]]$persona)
raw_text <- purrr::map_chr(file.path(REFLEXES_DIR, REFLEX_FILES), function(p) paste(readLines(p, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
sources <- unlist(purrr::map(rfiles, function(s) purrr::map_chr(unname(s$reflexes), "source")))
sources <- sources[!is.na(sources)]
comments <- trimws(substr(gsub("\\s+", " ", sub("^<!--", "", unlist(regmatches(raw_text, gregexpr("(?s)<!--.*?-->", raw_text, perl = TRUE))))), 1, 50))
everything_sent <- paste(purrr::map_chr(built, function(p) paste(p$system, p$user)), collapse = "\n")
ok("the same form gives the same prompt, character for character, and a changed word changes the hash",
   identical(prompt_of(forms$attitudinal), built$attitudinal) && identical(prompt_of(forms$evaluate), built$evaluate) &&
     !identical(build_prompt(utils::modifyList(forms$attitudinal, list(construct = "Trust in the police")))$hash, built$attitudinal$hash))
ok("no Source line, no Label, no HTML comment and no field label reaches any prompt",
   length(sources) > 20L && length(comments) > 3L &&
     !any(purrr::map_lgl(check_labels(), function(l) grepl(l, everything_sent, fixed = TRUE))) &&
     !any(purrr::map_lgl(sources, function(s) grepl(s, everything_sent, fixed = TRUE))) &&
     !any(purrr::map_lgl(comments, function(s) grepl(s, gsub("\\s+", " ", everything_sent), fixed = TRUE))) &&
     !grepl("**Source:**", everything_sent, fixed = TRUE) && !grepl("**Check:**", everything_sent, fixed = TRUE))
ok("the files used are core, the task's own file and mode (Evaluate: the files of the kinds ticked, all three by default); a country is one line of the brief and adds no file",
   identical(built$attitudinal$files, c("core.md", "generate.md", "attitudinal.md", "mode.md")) &&
     identical(built$evaluate$files, c("core.md", "evaluate.md", "attitudinal.md", "behavioral.md", "sensitive.md", "mode.md")) &&
     identical(prompt_of(c(forms$evaluate, list(kinds = "behavioral")))$files, c("core.md", "evaluate.md", "behavioral.md", "mode.md")) &&
     grepl("\nCountry: [country]\n", built$attitudinal$user, fixed = TRUE))
ok("mode.md keeps any_mode, the modes chosen, and mixed_mode only with more than one",
   grepl("- mixed_mode (", built$attitudinal$system, fixed = TRUE) && grepl("- telephone (", built$attitudinal$system, fixed = TRUE) &&
     !grepl("- mixed_mode (", built$behavioral$system, fixed = TRUE) && !grepl("- paper (", built$behavioral$system, fixed = TRUE))
ok("the persona's first sentence opens the message and the rest opens the system prompt; the prohibitions close it",
   all(purrr::map_lgl(built, function(p) startsWith(p$user, persona$first) && startsWith(p$system, persona$rest) &&
                        !grepl(persona$first, p$system, fixed = TRUE) && nchar(persona$rest) > 100L &&
                        grepl("PROHIBITIONS (override anything from training)\n- Never", p$system, fixed = TRUE))))
fails <- function(msg, form) grepl(msg, tryCatch({ build_prompt(form); "no error" }, error = conditionMessage), fixed = TRUE)
ok("a form that cannot make a prompt stops, saying why: no research question, no questionnaire, a bad field, mode or count",
   fails("research question is required", utils::modifyList(forms$attitudinal, list(research_question = " "))) &&
     fails("questionnaire pasted in", utils::modifyList(forms$evaluate, list(questionnaire = ""))) &&
     fails("not in the contract: populaton", c(forms$attitudinal, list(populaton = "x"))) &&
     fails("Unknown survey mode: radio", utils::modifyList(forms$attitudinal, list(modes = "radio"))) &&
     fails("number of items", utils::modifyList(forms$attitudinal, list(n_items = 2.5))))


# ---- the model layer, with the network stood in for -----------------------------------

parsed <- function(txt) tryCatch(parse_json_block(clean_model_reply(txt)), error = function(e) e)
ok("repair: a bare quote inside a value, a missing closing quote, a reply cut off inside a value, a fence, template tokens",
   identical(parsed('{"stem": "Do you "often" read?", "o": ["Y"]}')$stem, 'Do you "often" read?') &&
     identical(parsed('{"id": "A1", "stem": "How often?}')$stem, "How often?") &&
     identical(parsed('{"items": [{"id": "A1", "stem": "How often do')$items[[1]]$stem, "How often do") &&
     identical(parsed('Here:\n```json\n{"a": 1}\n```')$a, 1L) &&
     identical(parsed('<|start_header_id|>assistant<|end_header_id|>\n{"a": "b"}<|eot_id|>')$a, "b"))
ok("no JSON, or JSON past repair, fails and says so; the echoed template is no answer",
   grepl("No JSON found", conditionMessage(parsed("I cannot help.")), fixed = TRUE) &&
     grepl("could not be repaired", conditionMessage(parsed('{"a": ')), fixed = TRUE) &&
     is_placeholder_reply(list(stem = "...")) && !is_placeholder_reply(list(stem = "Real?")))

reply <- function(txt, finish = "success") structure(txt, finish = finish, provider = "mock")
scripted <- function(...) {
  replies = list(...)
  st = new.env()
  st$calls = 0L
  st$seen = list()
  list(state = st, complete = function(m, system_prompt, user, max_tokens, key, timeout = NULL) {
    st$calls = st$calls + 1L
    st$seen[[st$calls]] = list(user = user, key = key, system = system_prompt)
    r = replies[[min(st$calls, length(replies))]]
    if (is.function(r)) r() else r
  })
}
m_fake <- list(api = "openai", base_url = "http://mock.invalid/v1", id = "mock/model")
good_json <- '{"stem": "Real question?", "options": ["a", "b"]}'
run_json <- function(sc, ..., fresh = TRUE) {
  if (fresh) llm_clear_counters(llm_session_id())
  llm_json(user = "Question?", m = m_fake, system_prompt = "SYS", max_tokens = 100L, key = "k-test",
           complete = sc$complete, pause_base = 0.01, pause_min = 0.01, ...)
}
sc <- scripted(reply(good_json))
res <- run_json(sc)
ok("a good reply comes back parsed with the raw text and one attempt; what is sent is the prompt and the quote rule",
   identical(res$obj$stem, "Real question?") && res$attempts == 1L &&
     identical(sc$state$seen[[1]]$user, paste0("Question?\n\n", JSON_QUOTE_RULE)) && identical(sc$state$seen[[1]]$system, "SYS"))
sc <- scripted(reply("Sorry."), function() llm_fail("HTTP 503"), reply(good_json))
ok("a reply that is not JSON and a transient error are tried again; the third attempt is returned",
   run_json(sc)$attempts == 3L)
sc <- scripted(reply("not json"))
err <- fails_with(run_json(sc))
ok("a reply that never parses fails after three attempts, naming the model and carrying the raw reply",
   !is.null(err) && sc$state$calls == 3L && grepl("[mock/model via mock", conditionMessage(err), fixed = TRUE) &&
     identical(err$raw, "not json"))
sc <- scripted(reply(good_json, finish = "max_tokens"))
ok("a reply cut off at the ceiling fails at once and is not tried again",
   !is.null(fails_with(run_json(sc), "llm_truncated")) && sc$state$calls == 1L)
sc <- scripted(function() llm_fail("HTTP 401", class = "llm_client_error"))
ok("a client error is raised at once and not tried again", !is.null(fails_with(run_json(sc), "llm_client_error")) && sc$state$calls == 1L)
need_items <- function(o) if (is.null(o$items)) stop("the reply has no items field") else invisible(o)
sc <- scripted(reply('{"a": "x"}'))
err <- fails_with(run_json(sc, validate = need_items))
ok("a reply that fails the validator is retried, and the validator's words reach the analyst",
   !is.null(err) && sc$state$calls == 3L && grepl("the reply has no items field", conditionMessage(err), fixed = TRUE))
llm_clear_counters(llm_session_id())
invisible(fails_with(run_json(scripted(reply("x")), session_cap = 2L, fresh = FALSE)))
sc <- scripted(reply(good_json))
ok("once the session's retry allowance is used the next call fails at once and makes no call",
   grepl("retry cap of 2", conditionMessage(fails_with(run_json(sc, session_cap = 2L, fresh = FALSE))), fixed = TRUE) &&
     sc$state$calls == 0L)
llm_clear_counters(llm_session_id())
sc <- scripted(reply(good_json))
ok("no key is a client error before any call, and says to paste one",
   grepl("Paste a key", conditionMessage(fails_with(llm_json("Q?", m_fake, "S", 100L, key = NULL, complete = sc$complete), "llm_client_error")), fixed = TRUE) &&
     sc$state$calls == 0L)

Sys.setenv(ANTHROPIC_API_KEY = "env-key-should-be-ignored")
ok("the environment is never read for the key", is.null(llm_key_for()) && !llm_key_ready())
key_state <- shiny::reactiveValues(key_version = 0L)
shiny::testServer(mod_key_server, args = list(state = key_state), {
  session$setInputs(key = "pasted-by-analyst", save = 1)
  ok("the pasted key is the key, for this session", identical(llm_key_for(), "pasted-by-analyst"))
})
shiny::testServer(mod_key_server, args = list(state = key_state), {
  ok("a key pasted in one session is not visible to another", is.null(llm_key_for()))
})
Sys.unsetenv("ANTHROPIC_API_KEY")

pa <- llm_chat(APP_PROFILES$home, "SYS", 1500L, "k")$get_provider()
po <- llm_chat(m_fake, "SYS", 1500L, "k")$get_provider()
ok("anthropic: the Anthropic provider with the model, ceiling and a five-minute cache; openai: the OpenAI-style provider",
   inherits(pa, "ellmer::ProviderAnthropic") && identical(S7::prop(pa, "model"), "claude-sonnet-5-5") &&
     identical(S7::prop(pa, "params")$max_tokens, 1500L) && identical(S7::prop(pa, "cache"), "5m") &&
     inherits(po, "ellmer::ProviderOpenAICompatible") && identical(S7::prop(po, "base_url"), "http://mock.invalid/v1"))
ok("the connection check names the placeholders of an unfilled profile and does not call it",
   grepl("Not set up: base_url, id", llm_ping(APP_PROFILES$work, key = "k")$message, fixed = TRUE))


# ---- a pasted questionnaire, split and packed ---------------------------------------------

long_q <- paste(readLines(file.path("tests", "review_long_questionnaire.txt"), warn = FALSE), collapse = "\n")
plan30 <- review_plan(long_q)
ok("the 30-question file is four parts (8, 8, 8, 6) and one call on the whole, ids taken from the labels",
   length(plan30) == 5L && identical(purrr::map_chr(plan30, "kind"), c(rep("items", 4), "instrument")) &&
     identical(purrr::map_int(plan30[1:4], function(p) length(p$questions)), c(8L, 8L, 8L, 6L)) &&
     identical(plan30[[1]]$ids[1:2], c("Q1", "Q2")) && identical(plan30[[2]]$first, 9L) &&
     identical(paste(purrr::map_chr(plan30[1:4], "text"), collapse = "\n\n"), trimws(gsub("\r\n?", "\n", long_q))))
no_blank <- "Q1. Do you drive?\n1 Yes\n2 No\nQ2. Do you cycle?\n1 Yes\n2 No\nQ3) Do you walk?"
ok("with no blank lines, questions are split on the lines that start with a label; one question is one part and no instrument call",
   identical(split_questions(no_blank), c("Q1. Do you drive?\n1 Yes\n2 No", "Q2. Do you cycle?\n1 Yes\n2 No", "Q3) Do you walk?")) &&
     identical(split_questions("1. A?\nYes / No\n2. B?\nYes / No"), c("1. A?\nYes / No", "2. B?\nYes / No")) &&
     length(review_plan("How old are you?")) == 1L && identical(review_plan("How old are you?")[[1]]$ids, "1"))
ok("parts hold at most 8 questions and 8,000 characters; a question over 8,000 characters stops, quoting its start",
   local({
     many = paste(sprintf("Q%d. Question number %d?\nYes / No", 1:40, 1:40), collapse = "\n\n")
     big = paste(rep(paste(rep("word", 300), collapse = " "), 9), collapse = "\n\n")
     p = review_plan(many)
     identical(purrr::map_int(purrr::keep(p, function(x) x$kind == "items"), function(x) length(x$questions)), c(rep(8L, 5))) &&
       all(purrr::map_int(review_plan(big), function(x) nchar(x$text)) <= 8000L | purrr::map_chr(review_plan(big), "kind") == "instrument") &&
       grepl("never cut", tryCatch(review_plan(strrep("x", 8001)), error = conditionMessage), fixed = TRUE)
   }))


# ---- a review, on a fake model ---------------------------------------------------------------

# A fake `ask`: answers from the message and records what each call was sent.
fake_ask <- function(answer) {
  st = new.env()
  st$calls = list()
  list(state = st, ask = function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    st$calls[[length(st$calls) + 1L]] = list(user = user, system = system_prompt, max_tokens = max_tokens)
    out = answer(user)
    if (!is.null(validate)) validate(out)
    out
  })
}

# The fake reviewer: for each question of a part, a flag on Q11's leading words (fix), on Q12's two
#   questions (fix), a consider flag on Q13, and a flag whose quote is not in the text on Q14; and
#   two points about the whole.
fake_item <- function(id) {
  fl = function(check, stage, level, quote, why) list(check = check, stage = stage, level = level, quote = quote, why = why)
  flags = switch(id,
    Q11 = list(fl("neutral_wording", "comprehension", "fix", "greedy energy companies", "The premise is stated as fact, so disagreeing means rejecting the question.")),
    Q12 = list(fl("one_thing", "comprehension", "fix", "and did these changes lower your bills", "Two questions at once; a yes to one and no to the other has no answer."),
               fl("retrieval_and_judgment", "retrieval", "consider", "lower your bills", "Bills change for many reasons, so lower bills are hard to attribute.")),
    Q13 = list(fl("no_presupposition", "comprehension", "consider", "Please answer even if you rent", "Renters may not be able to install panels.")),
    Q14 = list(fl("specific_concrete", "comprehension", "fix", "a typical week", "A normal week is not defined for shift workers.")),
    list())
  list(id = id, flags = flags, rewrite = if (any(purrr::map_chr(flags, "level") == "fix")) paste("Rewrite of", id) else "")
}
review_answer <- function(user) {
  if (grepl("Reply with the \"instrument\" object only", user, fixed = TRUE))
    return(list(instrument = list(list(check = "scale_consistency", stage = "reporting", level = "consider",
                                       questions = list("Q5", "Q17"), why = "Q5 runs satisfied to dissatisfied and Q17 the other way."))))
  part = strsplit(strsplit(user, "QUESTIONNAIRE\n", fixed = TRUE)[[1]][2], "\n\nCHECKLIST", fixed = TRUE)[[1]][1]
  q = regmatches(part, gregexpr("(?m)^Q[0-9]+(?=\\.)", part, perl = TRUE))[[1]]
  list(items = purrr::map(q, fake_item))
}
fa <- fake_ask(review_answer)
rv <- run_review(utils::modifyList(forms$evaluate, list(questionnaire = long_q)), APP_MODEL, ask = fa$ask)
sh <- shape_review(rv)
calls_users <- purrr::map_chr(fa$state$calls, "user")
ok("a 30-question review is five calls, every one sending the same message and its own questions, checks and ceiling",
   identical(rv$status, "ok") && length(fa$state$calls) == 5L &&
     all(startsWith(calls_users, assemble_message(clean_form(utils::modifyList(forms$evaluate, list(questionnaire = long_q)))))) &&
     grepl("Q8.", calls_users[1], fixed = TRUE) && !grepl("Q9.", calls_users[1], fixed = TRUE) &&
     identical(purrr::map_int(fa$state$calls, "max_tokens"), unname(LLM_MAX_TOKENS[c(rep("items", 4), "instrument")])) &&
     length(unique(purrr::map_chr(fa$state$calls, "system"))) == 1L)
ok("an item call carries the question checks and not the instrument checks; the instrument call only those",
   grepl("\none_thing: ", calls_users[1], fixed = TRUE) && !grepl("\ncontext_and_order: ", calls_users[1], fixed = TRUE) &&
     grepl("\ncontext_and_order: ", calls_users[5], fixed = TRUE) && !grepl("\none_thing: ", calls_users[5], fixed = TRUE))
ok("the shaped review has 30 questions in order, with their text as pasted and their flags",
   length(sh$questions) == 30L && identical(sh$questions[[11]]$id, "Q11") && startsWith(sh$questions[[11]]$text, "Q11. Obviously") &&
     length(sh$questions[[12]]$flags) == 2L && length(sh$instrument) == 1L)
ok("the quote check: a quote in the question is found; one that is not is kept and marked, not dropped",
   isTRUE(sh$questions[[11]]$flags[[1]]$found) && identical(sh$questions[[14]]$flags[[1]]$found, FALSE) &&
     quote_found("“greedy  energy”", "Obviously, high energy bills are caused by \"greedy energy companies\"") &&
     !quote_found("", "anything"))
ok("the bottom line is built from the flags: counts, the main stage with its checks, and one line on the whole",
   identical(bottom_line(sh), c(
     "3 of 30 questions have a problem likely to change answers, and 1 more has a point to consider.",
     paste0("All are comprehension problems (3): ", count_phrase(unname(check_label(c("neutral_wording", "one_thing", "specific_concrete")))), "."),
     paste0("The questionnaire as a whole: ", lc1(check_label("scale_consistency")), " (Q5, Q17)."))))
ok("the bottom line says Most are only for more than half, else The largest group is; the whole-questionnaire ids follow the pasted order",
   local({
     q = function(id, stage) list(id = id, text = id, reviewed = TRUE, rewrite = "",
                                  flags = list(list(check = "one_thing", label = "Asks two things at once", stage = stage, level = "fix", why = "w")))
     two = list(questions = list(q("Q1", "comprehension"), q("Q2", "comprehension"), q("Q3", "retrieval"), q("Q4", "judgment")), instrument = list())
     three = list(questions = list(q("Q1", "comprehension"), q("Q2", "comprehension"), q("Q3", "retrieval")),
                  instrument = list(list(label = "Scales or periods inconsistent", questions = c("Q3", "Q1"))))
     startsWith(bottom_line(two)[2], "The largest group is comprehension problems (2)") &&
       startsWith(bottom_line(three)[2], "Most are comprehension problems (2)") &&
       grepl("(Q1, Q3)", bottom_line(three)[3], fixed = TRUE)
   }))
ok("the bottom line names at most the three most common faults, ties in pasted order, then how many other kinds",
   identical(count_phrase(c("A", "B", "C", "D", "B", "E")), "b (2), a (1), c (1), and 2 other kinds") &&
     identical(count_phrase(c("A", "B", "C", "D")), "a (1), b (1), c (1), and 1 other kind") &&
     identical(count_phrase(c("A", "B", "A")), "a (2), b (1)"))
ok("a rewrite is drawn with the question on one line and each option on its own; a rewrite that does not split that way is one paragraph",
   local({
     one = rewrite_blocks("Do you think the government is doing enough, or not? Yes, definitely / Yes, probably / No / Don't know")
     two = rewrite_blocks("Think about the past 7 days.\nHow many days did you drive?\n0 / 1 to 3 / 4 or more")
     long = rewrite_blocks("How much did you spend? Look at a bill (or tick: None / Don't know if you cannot find one at all today).")
     identical(one[[1]]$text, "Rewrite: Do you think the government is doing enough, or not?") &&
       identical(one[[2]]$items, c("Yes, definitely", "Yes, probably", "No", "Don't know")) &&
       identical(two[[1]]$text, "Rewrite: Think about the past 7 days. How many days did you drive?") && identical(length(two[[2]]$items), 3L) &&
       length(long) == 1L
   }))
ok("what to fix first: the questions with a fix flag, most fix flags first then in order, at most five",
   identical(purrr::map_chr(fix_first(sh), "id"), c("Q11", "Q12", "Q14")) &&
     length(fix_first(list(questions = rep(sh$questions[11], 9)))) == 5L)

v_items <- function(obj, checks = c("one_thing", "plain_words"), n = 1L) tryCatch({ reply_validator("items", checks = checks, n_questions = n)(obj); "ok" }, error = conditionMessage)
flag1 <- list(check = "one_thing", stage = "comprehension", level = "fix", quote = "and", why = "Two things.")
ok("the validator passes a good reply and refuses: more than 8 flags, a why over 30 words, a check not sent, no quote, a bad stage or level, a question missing",
   identical(v_items(list(items = list(list(id = "Q1", flags = list(flag1), rewrite = "x")))), "ok") &&
     grepl("9 flags; the limit is 8", v_items(list(items = list(list(id = "Q1", flags = rep(list(flag1), 9), rewrite = "x"))))) &&
     grepl("why of 31 words", v_items(list(items = list(list(id = 1, flags = list(utils::modifyList(flag1, list(why = paste(rep("w", 31), collapse = " ")))), rewrite = ""))))) &&
     grepl("not in the CHECKLIST", v_items(list(items = list(list(id = 1, flags = list(utils::modifyList(flag1, list(check = "made_up"))), rewrite = ""))))) &&
     grepl("has no quote", v_items(list(items = list(list(id = 1, flags = list(utils::modifyList(flag1, list(quote = ""))), rewrite = ""))))) &&
     grepl("stage", v_items(list(items = list(list(id = 1, flags = list(utils::modifyList(flag1, list(stage = "memory"))), rewrite = ""))))) &&
     grepl("fix or consider", v_items(list(items = list(list(id = 1, flags = list(utils::modifyList(flag1, list(level = "minor"))), rewrite = ""))))) &&
     grepl("this part has 2", v_items(list(items = list(list(id = 1, flags = list(), rewrite = ""))), n = 2L)))
ok("the instrument validator refuses more than three points and a point with no question",
   local({
     p = list(check = "scale_consistency", stage = "reporting", level = "fix", questions = list("Q1"), why = "x")
     v = function(o) tryCatch({ reply_validator("instrument", checks = "scale_consistency")(o); "ok" }, error = conditionMessage)
     identical(v(list(instrument = list(p))), "ok") && grepl("limit is 3", v(list(instrument = rep(list(p), 4)))) &&
       grepl("names no question", v(list(instrument = list(replace(p, "questions", list(list()))))))
   }))

fa2 <- fake_ask(function(user) if (grepl("part 1 of 4", user, fixed = TRUE)) stop("HTTP 500") else review_answer(user))
rv2 <- run_review(utils::modifyList(forms$evaluate, list(questionnaire = long_q)), APP_MODEL, ask = fa2$ask)
ok("a part that fails leaves its questions not reviewed, never clear; the rest is kept; it can be run again",
   identical(rv2$status, "partial") && !sh$questions[[1]]$reviewed == FALSE &&
     !shape_review(rv2)$questions[[1]]$reviewed && shape_review(rv2)$questions[[16]]$reviewed &&
     identical(rerun_review_part(utils::modifyList(forms$evaluate, list(questionnaire = long_q)), APP_MODEL, rv2, 1L, ask = fa$ask)$status, "ok"))


# ---- a draft, on a fake model ---------------------------------------------------------------

draft_reply <- function(n) list(
  items = purrr::map(seq_len(n), function(i)
    list(id = paste0("TR", i), domain = paste("domain", i), intro = "", stem = paste0("How much do you trust [council] on ", i, "?"),
         options = list("A great deal", "Somewhat", "Not at all"), open_format = "", parts = list(), programming = "",
         why = paste("Why", i))),
  not_covered = list("trust in officers"), needs_from_analyst = list("The council's name"))
# The fake editor: the same items with the second one repaired, a part on the first, and its changes.
refine_reply <- function(n = 3L) {
  d = draft_reply(n)
  d$items = purrr::imap(d$items, function(it, i) {
    it$why = NULL
    it$changes = if (i == 2L) "Named both sides of trust." else ""
    if (i == 2L) { it$stem = "How much do you trust or distrust [council] on 2?"; it$options = list("Trust a lot", "Neither", "Distrust a lot") }
    if (i == 1L) it$parts = list(list(when = "if a great deal", stem = "Why do you trust it?", options = list(), open_format = "a few words"),
                                 list(when = "Before the item", stem = "Have you heard of [council]?", options = list("Yes", "No"), open_format = ""))
    it
  })
  d$needs_from_analyst = list("The council's name")
  d
}
write_answer <- function(user) if (grepl("\nDRAFT\n", user, fixed = TRUE)) refine_reply() else draft_reply(3)
fake_drafter <- list(api = "anthropic", base_url = "http://mock.invalid/v1", id = "mock/drafter")
fa <- fake_ask(function(user) draft_reply(3))
dr <- write_call(forms$attitudinal, "draft", APP_MODEL, fa$ask)
ok("a draft is one call, with the assembled prompt",
   identical(dr$status, "ok") && length(fa$state$calls) == 1L && identical(dr$hash, built$attitudinal$hash))
fa <- fake_ask(function(user) draft_reply(2))
ok("a draft with the wrong number of items is a failure, with the reason",
   grepl("2 items; 3 were asked for", write_call(forms$attitudinal, "draft", APP_MODEL, fa$ask)$error, fixed = TRUE))
ok("the draft validator refuses more than three requests of the analyst and a why over 30 words",
   local({
     v = function(o) tryCatch({ reply_validator("draft", n_items = 3L)(o); "ok" }, error = conditionMessage)
     d = draft_reply(3)
     identical(v(d), "ok") && grepl("limit is 3", v(replace(d, "needs_from_analyst", list(as.list(letters[1:4]))))) &&
       grepl("why of 31 words", v(local({ d$items[[1]]$why = paste(rep("w", 31), collapse = " "); d })))
   }))
ok("the refine validator: the number asked for, a stem and options or an open format, every part with a stem, changes at most 20 words",
   local({
     v = function(o) tryCatch({ reply_validator("refine", n_items = 3L)(o); "ok" }, error = conditionMessage)
     r = refine_reply()
     identical(v(r), "ok") && grepl("asked for", v(replace(r, "items", list(r$items[1:2])))) &&
       grepl("part 1 has no stem", v(local({ r$items[[1]]$parts[[1]]$stem = ""; r }))) &&
       grepl("changes of 21 words", v(local({ r$items[[2]]$changes = paste(rep("w", 21), collapse = " "); r }))) &&
       grepl("neither options nor an open_format", v(local({ r$items[[3]]$options = list(); r })))
   }))
calls_to <- character(0)
fa <- fake_ask(write_answer)
ask_seen <- function(user, m, ...) { calls_to <<- c(calls_to, m$id); fa$ask(user, m, ...) }
wr <- run_write(forms$attitudinal, c(APP_MODEL[names(APP_MODEL) != "drafter"], list(drafter = fake_drafter)), ask = ask_seen)
rf_user <- fa$state$calls[[2]]$user
ok("Write questions is two calls: the drafter drafts, then the main model edits in a fresh chat with the draft as JSON",
   identical(calls_to, c("mock/drafter", "claude-sonnet-5-5")) && identical(wr$refine$status, "ok") &&
     grepl("\nDRAFT\n{", rf_user, fixed = TRUE) && grepl("\"stem\": \"How much do you trust [council] on 1?\"", rf_user, fixed = TRUE) &&
     grepl("Task: Edit the draft below into the final 3 survey items", rf_user, fixed = TRUE) &&
     grepl("- check_then_finish (", fa$state$calls[[2]]$system, fixed = TRUE) && !grepl("- declare_defaults (", fa$state$calls[[2]]$system, fixed = TRUE) &&
     identical(run_write(forms$attitudinal, APP_MODEL[names(APP_MODEL) != "drafter"], ask = fake_ask(write_answer)$ask)$draft$model, "claude-sonnet-5-5"))
ok("the refine CHECKLIST is the Check lines of core, generate, the kind's file and the modes, and its reply format is refine.md's",
   local({
     sent = sub(":.*$", "", grep("^[a-z_]+: ", strsplit(strsplit(rf_user, "CHECKLIST\n", fixed = TRUE)[[1]][2], "\n\n", fixed = TRUE)[[1]][1] |>
                                   strsplit("\n", fixed = TRUE) |> unlist(), value = TRUE))
     checks_of = function(file) names(purrr::keep(rfiles[[file]]$reflexes, function(r) !is.na(r$check)))
     setequal(sent, c(checks_of("core.md"), checks_of("generate.md"), checks_of("attitudinal.md"), "any_mode", "web", "telephone", "mixed_mode")) &&
       identical(wr$refine$checks, sent) && grepl(rfiles[["refine.md"]]$output_format, rf_user, fixed = TRUE)
   }))
ok("the task sentence for one item has no 'each'; the item limit is 10",
   grepl("Task: Write exactly 1 survey item for the brief, measuring a behaviour or an experience.",
         assemble_message(clean_form(utils::modifyList(forms$behavioral, list(n_items = 1L)))), fixed = TRUE) &&
     identical(clean_form(utils::modifyList(forms$attitudinal, list(n_items = 10L)))$n_items, 10L) &&
     grepl("1 to 10", tryCatch(clean_form(utils::modifyList(forms$attitudinal, list(n_items = 11L))), error = conditionMessage), fixed = TRUE))
fa_fail <- fake_ask(function(user) if (grepl("\nDRAFT\n", user, fixed = TRUE)) stop("HTTP 500") else draft_reply(3))
wf <- run_write(forms$attitudinal, APP_MODEL, ask = fa_fail$ask)
ok("when the refine fails outright, the page shows the draft",
   identical(wf$refine$status, "failed") && identical(final_reply(wf), wf$draft$reply))

# ---- the screens -------------------------------------------------------------------------

ok("four tabs: Start here, Evaluate questions, Write questions, Methodology",
   identical(QUESTIONR_TABS, c("Start here", "Evaluate questions", "Write questions", "Methodology")) &&
     all(purrr::map_lgl(QUESTIONR_TABS, function(t) grepl(paste0("data-value=\"", t, "\""), page$html, fixed = TRUE))))

# The short box: a standard form of each task gives at most 150 words, and the box never holds the
#   system prompt, the checklist, the reply format or the pasted questions.
box_words <- purrr::map_int(c(forms, list(long = utils::modifyList(forms$evaluate, list(questionnaire = long_q)))), function(fm)
  n_words(assemble_message(clean_form(fm))))
ok("the box a standard form gives is at most 150 words for every task (the brief's target is 120)",
   all(box_words <= 150L) && all(box_words > 60L))
long_box <- assemble_message(clean_form(utils::modifyList(forms$evaluate, list(questionnaire = long_q))))
ok("the box holds the persona's first sentence, the task, the brief, the guidelines and one line for the questions, and nothing else",
   startsWith(long_box, persona$first) && grepl("[your 30 questions go here]", long_box, fixed = TRUE) &&
     !grepl("Obviously, high energy bills", long_box, fixed = TRUE) && !grepl("CHECKLIST", long_box, fixed = TRUE) &&
     !grepl("REPLY FORMAT", long_box, fixed = TRUE) && !grepl("REFLEXES", long_box, fixed = TRUE) &&
     !grepl(persona$rest, long_box, fixed = TRUE) &&
     all(purrr::map_lgl(rfiles[["core.md"]]$guidelines$bullets, function(b) grepl(b, long_box, fixed = TRUE))))

key_planted <- "sk-planted-0123456789abcdef"
app_state <- shiny::reactiveValues(key_version = 0L)
local({
  fa = fake_ask(function(user) {
    out = review_answer(user)
    if (!is.null(out$items)) out$items[[1]]$flags = list(list(check = "plain_words", stage = "comprehension", level = "consider",
                                                              quote = "Are you", why = paste("Leaky", key_planted)))
    out
  })
  shiny::testServer(mod_task_server, args = list(kind = "review", app = app_state, make_ask = function(total) fa$ask), {
    llm_set_session_key(key_planted)
    session$setInputs(research_question = "Energy use", population = "Adults", modes = "web", questionnaire = long_q, prepare = 1)
    box = html_of(output$box)
    ok("pressing the button shows, on the same page, the number of questions found, the short box and Run",
       grepl("Found 30 questions.", box, fixed = TRUE) && grepl("Run", box, fixed = TRUE) && grepl("<textarea", box, fixed = TRUE) &&
         is.null(state$review))
    session$setInputs(user = paste(assemble_message(state$form), "Be extra careful with Q11."), run = 1)
    st = state
    h = html_of(output$results)
    b = html_of(output$bottom)
    ok("the review page is the bottom line, what to fix first, all questions, and a closed panel on how it was produced",
       all(purrr::map_int(c("Bottom line", "What to fix first", "All questions"), function(x) regexpr(x, h, fixed = TRUE)) > 0L) &&
         regexpr("Bottom line", h, fixed = TRUE) < regexpr("What to fix first", h, fixed = TRUE) &&
         regexpr("What to fix first", h, fixed = TRUE) < regexpr("All questions", h, fixed = TRUE) &&
         grepl("How this was produced", b, fixed = TRUE) && grepl("Calls: 5", b, fixed = TRUE) &&
         n_in("<details class=\"border-bottom", h) == 30L && grepl("<mark>greedy energy companies</mark>", h, fixed = TRUE) &&
         grepl("None found by this review.", h, fixed = TRUE) && !grepl("[0-9a-f]{64}", paste(h, b)))
    words_page = words_of(see_text(paste(sub("(?s)<h4>All questions</h4>.*$", "", h, perl = TRUE))))
    words_word = words_of(doc_text(review_blocks(shape_review(st$review))[seq_len(which(purrr::map_chr(review_blocks(shape_review(st$review)), function(x) x$text %||% "") == "All questions") - 1L)]))
    ok("Copy for Word holds the bottom line and the cards word for word as the page shows them, and the table of all questions",
       identical(words_page, words_word) && grepl("Copy for Word", b, fixed = TRUE) && grepl("<table", b, fixed = TRUE) &&
         grepl("Q30", b, fixed = TRUE))
    log = paste(readLines(output$get_log, encoding = "UTF-8", warn = FALSE), collapse = "\n")
    ok("a key in the session, echoed in a model's reply, is in neither the page, the Word copy nor the run log",
       !grepl(key_planted, paste(h, b), fixed = TRUE) && !grepl(key_planted, log, fixed = TRUE) &&
         grepl("[key removed]", log, fixed = TRUE))
    ok("the run log has every call with its prompt hash and tokens, and the message as assembled and as sent; an edit is there and not on the page",
       grepl("\"message_sent\"", log, fixed = TRUE) && n_in("\"hash\"", log) == 5L && grepl("\"tokens_in\"", log, fixed = TRUE) &&
         grepl("\"edited\": true", log, fixed = TRUE) && grepl("Be extra careful with Q11.", log, fixed = TRUE) &&
         all(purrr::map_lgl(fa$state$calls, function(x) grepl("Be extra careful with Q11.", x$user, fixed = TRUE))) &&
         !grepl("edited", see_text(paste(h, b)), ignore.case = TRUE))
  })
})

local({
  fa = fake_ask(write_answer)
  shiny::testServer(mod_task_server, args = list(kind = "draft", app = app_state, make_ask = function(total) fa$ask), {
    fm = forms$attitudinal
    session$setInputs(task = "attitudinal", research_question = fm$research_question, construct = fm$construct,
                      population = fm$population, country = fm$country, modes = fm$modes, n_items = 3, prepare = 1)
    session$setInputs(user = assemble_message(state$form), run = 1)
    st = state
    h = html_of(output$items_ui)
    r = html_of(output$results)
    before = sub("(?s)<details.*$", "", h, perl = TRUE)
    ok("Write questions: the one sentence, the final items as cards with their part and nothing about how they were reached, Before you field these, and a closed How these were written",
       grepl(WRITE_NOTICE, r, fixed = TRUE) && n_in("card mb-2", h) == 3L && n_in("Remove", h) == 3L &&
         grepl("Why do you trust it?", h, fixed = TRUE) && grepl("Answer: a few words", h, fixed = TRUE) &&
         regexpr("Have you heard of [council]?", h, fixed = TRUE) < regexpr("How much do you trust [council] on 1?", h, fixed = TRUE) &&
         regexpr("How much do you trust [council] on 1?", h, fixed = TRUE) < regexpr("Why do you trust it?", h, fixed = TRUE) &&
         grepl("<em>domain 1</em>", h, fixed = TRUE) &&
         grepl("<h5>Before you field these</h5>", h, fixed = TRUE) && grepl("The council", before, fixed = TRUE) &&
         !grepl("Named both sides|trust in officers|Why 1|Revised|Open question|check", before, ignore.case = TRUE) &&
         grepl("<summary>How these were written</summary>", h, fixed = TRUE) && !grepl("<details[^>]*open", h) &&
         grepl("Question 2: Named both sides of trust.", h, fixed = TRUE) && grepl("Not covered: trust in officers", h, fixed = TRUE) &&
         grepl("edited by claude-sonnet-5-5", h, fixed = TRUE) && grepl("Checks applied:", h, fixed = TRUE))
    word = see_text(sub("(?s)^.*?<div id=\"[^\"]*word\"[^>]*>(.*?)</div>\\s*<p class=\"mt-4\".*$", "\\1", html_of(output$bottom), perl = TRUE))
    ok("the Word copy is the one sentence, the items as laid out on the page, and Before you field these",
       identical(words_of(word), words_of(see_text(paste(r, before)))) &&
         identical(words_of(word), words_of(doc_text(draft_blocks(final_items(st$items, st$edits), list("The council's name"))))) &&
         grepl("Distrust a lot", word, fixed = TRUE))
    session$setInputs(ed_1_p2_stem = "Have you ever heard of [council]?", ed_1_p1_o1 = "unused", ed_1_p2_o2 = "Not sure")
    session$flushReact()
    wb = html_of(output$bottom)
    ok("a filter part is drawn above the stem in Copy for Word too, and a part's stem and options are edited like the item's",
       regexpr("Have you ever heard of [council]?", wb, fixed = TRUE) > 0L &&
         regexpr("Have you ever heard of [council]?", wb, fixed = TRUE) < regexpr("How much do you trust [council] on 1?", wb, fixed = TRUE) &&
         grepl("Not sure", wb, fixed = TRUE) && !grepl("unused", wb, fixed = TRUE) &&
         grepl("If a great deal: Why do you trust it?", wb, fixed = TRUE) &&
         identical(final_items(st$items, st$edits)[[1]]$parts[[2]]$options, list("Yes", "Not sure")))
    session$setInputs(remove = "2")
    session$flushReact()
    ok("Remove takes an item out, and out of the Word copy", n_in("card mb-2", html_of(output$items_ui)) == 2L &&
         !grepl("on 2?", html_of(output$bottom), fixed = TRUE) && grepl("on 3?", html_of(output$bottom), fixed = TRUE))
  })
})
ok("no key is anywhere on the page", !grepl(key_planted, page$html, fixed = TRUE))


# ---- Start here and Methodology ---------------------------------------------------------------

start_html <- html_of(start_ui())
at <- function(x, h = start_html) regexpr(x, h, fixed = TRUE)[[1]]
ok("Start here is www/start.md as written (its table and block quotes drawn), then the key box, then the closed settings; no worked-example card",
   local({
     md = html_of(md_page(START_FILE))
     grepl("<table>", md, fixed = TRUE) && n_in("<blockquote>", md) == 2L && grepl("fw_tse.svg", md, fixed = TRUE) &&
       grepl("how_it_works.svg", md, fixed = TRUE) && at("An example") > 0L && at("An example") < at("Your API key") &&
       at("Your API key") < at("Settings and connection") && !grepl("<details[^>]*open", start_html) &&
       !exists("example_ui") && !file.exists(file.path("www", "start_example.json"))
   }))
ok("the figures are in www/ and the old ones are gone; the slide example is on the Methodology page",
   all(file.exists(file.path("www", c("fw_tse.svg", "start_example.svg", "how_it_works.svg", "fw_construct.svg", "fw_response.svg", "fw_sensitive.svg")))) &&
     !any(file.exists(file.path("www", c("fw_testing.svg", "fw_trapd.svg", "fw_example.svg")))) &&
     grepl("start_example.svg", html_of(md_page(METHODOLOGY_FILE)), fixed = TRUE))
meth_html <- html_of(methodology_ui())
heads <- regmatches(meth_html, gregexpr("<h2>[^<]+</h2>", meth_html))[[1]]
ok("the Methodology page has its sections in order, and no TRAPD or testing-methods section",
   identical(gsub("</?h2>", "", heads), c("Measurement error", "From construct to question", "The response process",
                                          "Sensitive questions", "How the AI reviewer is kept in check", "How it was tested",
                                          "What it cannot do", "The AI reflexes")) &&
     !grepl("TRAPD|testing methods", html_of(md_page(METHODOLOGY_FILE)), ignore.case = TRUE))
ok("the reflex table is read from the reflex files and comes last: one row per reflex, its Label, and its Source line as written",
   local({
     t = reflexes_table()
     n = sum(purrr::map_int(rfiles, function(s) length(s$reflexes)))
     nrow(t) == n && n_in("<tr>", meth_html) == n + 1L && regexpr("<table", meth_html) > regexpr("The AI reflexes", meth_html) &&
       all(purrr::map_lgl(t$source[nzchar(t$source)], function(s) grepl(htmltools::htmlEscape(s), meth_html, fixed = TRUE)))
   }))
