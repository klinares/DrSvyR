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
ok("two profiles, each one model on a pasted key; home is Sonnet 5.5 on Anthropic's API, work is placeholders",
   identical(names(APP_PROFILES), c("home", "work")) &&
     identical(APP_PROFILES$home, list(api = "anthropic", base_url = "https://api.anthropic.com/v1", id = "claude-sonnet-5-5")) &&
     identical(llm_placeholders(APP_PROFILES$work), c("base_url", "id")) &&
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
built <- purrr::map(forms, build_prompt)
raw_text <- purrr::map_chr(file.path(REFLEXES_DIR, REFLEX_FILES), function(p) paste(readLines(p, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
sources <- unlist(purrr::map(rfiles, function(s) purrr::map_chr(unname(s$reflexes), "source")))
sources <- sources[!is.na(sources)]
comments <- trimws(substr(gsub("\\s+", " ", sub("^<!--", "", unlist(regmatches(raw_text, gregexpr("(?s)<!--.*?-->", raw_text, perl = TRUE))))), 1, 50))
everything_sent <- paste(purrr::map_chr(built, function(p) paste(p$system, p$user)), collapse = "\n")
ok("the same form gives the same prompt, character for character, and a changed word changes the hash",
   identical(build_prompt(forms$attitudinal), built$attitudinal) &&
     !identical(build_prompt(utils::modifyList(forms$attitudinal, list(construct = "Trust in the police")))$hash, built$attitudinal$hash))
ok("no Source line, no HTML comment and no field label reaches any prompt",
   length(sources) > 20L && length(comments) > 3L &&
     !any(purrr::map_lgl(sources, function(s) grepl(s, everything_sent, fixed = TRUE))) &&
     !any(purrr::map_lgl(comments, function(s) grepl(s, gsub("\\s+", " ", everything_sent), fixed = TRUE))) &&
     !grepl("**Source:**", everything_sent, fixed = TRUE) && !grepl("**Check:**", everything_sent, fixed = TRUE))
ok("the files used are core, the task's own file and mode; a country is one line of the brief and adds no file",
   identical(built$attitudinal$files, c("core.md", "generate.md", "attitudinal.md", "mode.md")) &&
     identical(built$evaluate$files, c("core.md", "evaluate.md", "mode.md")) &&
     grepl("\nCountry: [country]\n", built$attitudinal$user, fixed = TRUE))
ok("mode.md keeps any_mode, the modes chosen, and mixed_mode only with more than one",
   grepl("- mixed_mode (", built$attitudinal$system, fixed = TRUE) && grepl("- telephone (", built$attitudinal$system, fixed = TRUE) &&
     !grepl("- mixed_mode (", built$behavioral$system, fixed = TRUE) && !grepl("- paper (", built$behavioral$system, fixed = TRUE))
ok("the persona opens the message and not the system prompt; the prohibitions close the system prompt",
   all(purrr::map_lgl(built, function(p) startsWith(p$user, rfiles[["core.md"]]$persona) &&
                        !grepl(rfiles[["core.md"]]$persona, p$system, fixed = TRUE) &&
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


# ---- the flows, on a fake model ------------------------------------------------------

# A fake `ask`: answers by kind of call and records what each call was sent.
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
draft_reply <- function(n) list(items = purrr::map(seq_len(n), function(i)
  list(id = paste0("TR", i), domain = paste("domain", i), stem = paste0("How much do you trust [council] on ", i, "?"),
       options = list("A great deal", "Somewhat", "Not at all"), open_format = "")))
fa <- fake_ask(function(user) draft_reply(3))
dr <- run_draft(forms$attitudinal, APP_MODEL, ask = fa$ask)
ok("a draft is one call to the one model, with the assembled prompt", identical(dr$status, "ok") &&
     length(fa$state$calls) == 1L && identical(fa$state$calls[[1]]$user, built$attitudinal$user) &&
     identical(attr(dr, "prompt")$hash, built$attitudinal$hash))
fa <- fake_ask(function(user) draft_reply(2))
ok("a draft with the wrong number of items is a failure, with the reason",
   grepl("2 items; 3 were asked for", run_draft(forms$attitudinal, APP_MODEL, ask = fa$ask)$error, fixed = TRUE))


# ---- the screens -------------------------------------------------------------------------

test_state <- function() do.call(shiny::reactiveValues, STATE_DEFAULTS)
key_planted <- "sk-planted-0123456789abcdef"
local({
  st = test_state()
  fa = fake_ask(function(user) {
    d = draft_reply(3)
    d$items[[1]]$stem = paste("Leaky", key_planted)
    d
  })
  st$form <- clean_form(forms$attitudinal)
  st$approved <- c(built$attitudinal, list(edited = FALSE, original_hash = built$attitudinal$hash))
  shiny::testServer(mod_results_server, args = list(state = st, make_ask = function(total) fa$ask), {
    session$flushReact()
    st$run_id <- 1L
    session$flushReact()
    h = html_of(output$items_ui)
    ok("the drafted items are drawn in boxes, one card each, each with a Remove button",
       n_in("card mb-2", h) == 3L && n_in("Remove", h) == 3L && grepl("Question 1", h, fixed = TRUE))
    session$setInputs(remove = "2")
    session$flushReact()
    ok("Remove takes an item out", n_in("card mb-2", html_of(output$items_ui)) == 2L)
  })
  shiny::testServer(mod_output_server, args = list(state = st), {
    llm_set_session_key(key_planted)
    session$flushReact()
    log = paste(readLines(output$get_log, encoding = "UTF-8", warn = FALSE), collapse = "\n")
    ok("a key in the session, echoed in a model's reply, is in neither the page nor the run log",
       !grepl(key_planted, html_of(output$view), fixed = TRUE) && !grepl(key_planted, log, fixed = TRUE) &&
         grepl("[key removed]", log, fixed = TRUE))
  })
})
ok("no key is anywhere on the page", !grepl(key_planted, page$html, fixed = TRUE))
