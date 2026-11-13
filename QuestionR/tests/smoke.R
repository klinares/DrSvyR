# Smoke test for QuestionR. No API calls. Not deployed (tests/ is in .rscignore).
# Run from inside QuestionR/, without the user profile so it is closer to Connect:
#   Rscript --no-init-file tests/smoke.R
# Each check prints "ok" or stops the script with "FAIL" and the check's name.

stopifnot("Run from inside QuestionR/" = file.exists("DESIGN.md"))

ok <- function(what, cond) {
  if (!isTRUE(cond)) stop("FAIL: ", what, call. = FALSE)
  cat("ok  ", what, "\n", sep = "")
}

# Run R code in a fresh process, with QUESTIONR_PROFILE set inside it, and
#   return what it printed and how it ended. A fresh process because the
#   profile is read once, when app.R is sourced.
rscript <- file.path(R.home("bin"), "Rscript")
in_child <- function(profile, code) {
  f = tempfile(fileext = ".R")
  on.exit(unlink(f))
  writeLines(c(sprintf("Sys.setenv(QUESTIONR_PROFILE = '%s')", profile), code), f)
  out = suppressWarnings(system2(rscript, c("--no-init-file", shQuote(f)),
                                 stdout = TRUE, stderr = TRUE))
  list(out = paste(out, collapse = "\n"), status = attr(out, "status") %||% 0L)
}


# ---- Phase 0: the app loads, and its parts are in place --------------------

# Loaded the way Connect loads it. source("app.R") would hide an object that
#   R/ cannot see, because it evaluates in the global environment.
app <- shiny::shinyAppDir(".")
ok("shinyAppDir() returns a shiny.appobj", inherits(app, "shiny.appobj"))
ok("app.R sources without error", is.function(app$serverFuncSource()))

ok("the settings R/ reads are in the global environment",
   all(c("APP_CLASSIFICATION", "APP_PROFILE", "APP_MODELS", "APP_MAX_PASTE_CHARS") %in%
         ls(globalenv())))
ok("the Cairo bitmap type is set", identical(getOption("bitmapType"), "cairo"))

# The page, as the browser would get it.
page <- local({
  req = list(REQUEST_METHOD = "GET", PATH_INFO = "/", QUERY_STRING = "",
             SCRIPT_NAME = "", SERVER_NAME = "localhost", SERVER_PORT = "80",
             HTTP_HOST = "localhost", HTTP_ACCEPT_ENCODING = "",
             rook.url_scheme = "http")
  resp = app$httpHandler(req)
  list(status = resp$status,
       html = if (is.character(resp$content)) resp$content
              else paste(readLines(resp$content$file, warn = FALSE), collapse = "\n"))
})
has <- function(s) grepl(s, page$html, fixed = TRUE)

ok("the page is served", isTRUE(page$status == 200))
ok("the classification banner shows", has(APP_CLASSIFICATION))
# APP_SOURCE_URL is app.R's own setting too, so its value is written out here.
source_url <- "https://github.com/klinares/drsvyr/tree/main/QuestionR"
source_link <- regmatches(page$html, regexpr("<a[^>]*>Source code</a>", page$html))
ok("a small outline Source code button, first in the header and before the logo, opens the source in a new tab without an opener",
   length(source_link) == 1L && grepl(paste0("href=\"", source_url, "\""), source_link, fixed = TRUE) &&
     grepl("target=\"_blank\"", source_link, fixed = TRUE) && grepl("rel=\"noopener\"", source_link, fixed = TRUE) &&
     grepl("btn btn-outline-secondary btn-sm", source_link, fixed = TRUE) &&
     regexpr("Source code</a>", page$html, fixed = TRUE) < regexpr("Office logo|office_logo", page$html) &&
     regexpr("Source code</a>", page$html, fixed = TRUE) < regexpr("<h2>QuestionR</h2>|QuestionR</h2>", page$html))
# APP_LOGO is app.R's own setting and is not in the global environment, so the
#   default file name is written out here.
logo_file <- "office_logo.png"
ok("the logo shows, or its placeholder box does",
   if (file.exists(file.path("www", "logo", logo_file))) has(file.path("logo", logo_file))
   else has("Office logo"))
ok("every tab is in the navlist", all(purrr::map_lgl(QUESTIONR_TABS, has)))
ok("the key box is on Start here", has("Use this key") && has("type=\"password\""))
ok("the key box says where to get a key in the four sentences the design gives, and no TODO text shows anywhere on the page",
   identical(unname(unlist(KEY_INSTRUCTIONS)), c("Ask the person who manages the AI service for your office for a key.",
     "Use a key issued to you, not one shared by a team, so that use can be traced to the person who made it.",
     "The key must be able to reach every model listed under Settings and connection below. Check connections there before you start.",
     "If a request is refused for quota or cost, stop and ask the person who issued the key; do not borrow someone else's.")) &&
     all(purrr::map_lgl(unname(unlist(KEY_INSTRUCTIONS)), function(x) has(htmltools::htmlEscape(x)))) && !has("TODO"))
# Phase 3 built tabs 1 to 3, 5c the Output tab and 5d the Methodology tab: none is a placeholder now.
ok("no tab is a placeholder any more; Start here and the Methodology tab are their markdown files, and the rules table is not drawn",
   !grepl("Not built yet", page$html, fixed = TRUE) && grepl("What QuestionR is for", page$html, fixed = TRUE) &&
     grepl("How QuestionR works and what stands behind it", page$html, fixed = TRUE) &&
     !grepl("The rules, file by file", page$html, fixed = TRUE) && !grepl("<code>one_thing</code>", page$html, fixed = TRUE))

# The profile block. Each profile in its own process.
home <- in_child("home", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
  "cat('PM=', APP_MODELS$pm$id, ' KEY=', APP_MODELS$pm$key_source,",
  "    ' WORKERS=', length(APP_MODELS$workers), sep = '')"))
ok("home profile: PM on a pasted key, three workers",
   home$status == 0 && grepl("PM=claude-sonnet-5-5 KEY=analyst WORKERS=3", home$out, fixed = TRUE))

work <- in_child("work", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
  "cat('PROFILE=', APP_PROFILE, ' WORKERS=', length(APP_MODELS$workers), sep = '')"))
ok("work profile loads", work$status == 0 && grepl("PROFILE=work WORKERS=1", work$out, fixed = TRUE))

bogus <- in_child("nonsense", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())"))
ok("an unknown profile stops the app and names the choices",
   bogus$status != 0 && grepl("must be one of: home, rehearsal, work", bogus$out, fixed = TRUE))

# The profile switch: with QUESTIONR_PROFILE unset the app runs APP_DEFAULT_PROFILE; the
#   rehearsal profile is the four models through one host in the OpenAI style on one pasted key.
unset <- in_child("", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
  "cat('PROFILE=', APP_PROFILE, sep = '')"))
default_in_app <- sub("^APP_DEFAULT_PROFILE <- \"([a-z]+)\".*$", "\\1",
                      grep("^APP_DEFAULT_PROFILE <-", readLines("app.R", warn = FALSE), value = TRUE))
rehearsal <- in_child("rehearsal", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
  "ms <- purrr::map(llm_models(), 'm')",
  "cat('N=', length(ms), ' PM=', ms[[1]]$id, ' APIS=', paste(unique(purrr::map_chr(ms, 'api')), collapse = ','),",
  "    ' KEYS=', paste(unique(purrr::map_chr(ms, 'key_source')), collapse = ','),",
  "    ' HOSTS=', paste(unique(purrr::map_chr(ms, llm_host)), collapse = ','), sep = '')"))
ok("the profile switch: unset runs APP_DEFAULT_PROFILE; rehearsal is four OpenAI-style models on OpenRouter, all on the pasted key, the project manager anthropic/claude-sonnet-5.5",
   unset$status == 0 && grepl(paste0("PROFILE=", default_in_app), unset$out, fixed = TRUE) && identical(default_in_app, "home") &&
     rehearsal$status == 0 &&
     grepl("N=4 PM=anthropic/claude-sonnet-5.5 APIS=openai KEYS=analyst HOSTS=openrouter.ai", rehearsal$out, fixed = TRUE) &&
     grepl("must be one of: home, rehearsal, work", in_child("nonsense", "shiny::shinyAppDir('.')$serverFuncSource()")$out, fixed = TRUE))

# The key box. A key is held for the session, never put in the environment, and
#   forgotten on request.
key_state <- shiny::reactiveValues(key_version = 0L)
shiny::testServer(mod_key_server, args = list(state = key_state), {
  ok("no key is held before one is pasted", is.null(llm_session_key()))
  session$setInputs(key = "  smoke-test-key  ", save = 1)
  ok("a pasted key is held for the session, trimmed", identical(llm_session_key(), "smoke-test-key"))
  ok("the key is not in the environment", !any(Sys.getenv() == "smoke-test-key"))
  ok("saving the key bumps key_version", shiny::isolate(key_state$key_version) == 1L)
  session$setInputs(clear = 1)
  ok("a forgotten key is gone", is.null(llm_session_key()))
})


# ---- Phase 1: the reflex files parse, and prompts assemble --------------------

rfiles <- check_reflex_files()
ok("every reflex file parses", identical(names(rfiles), REFLEX_FILES))
ok("each reflex file has a title, a version, a sha and at least one reflex",
   purrr::every(rfiles, function(s)
     nzchar(s$title) && nzchar(s$version) && nzchar(s$sha) && length(s$reflexes) > 0))
ok("core.md carries the persona", !is.na(rfiles[["core.md"]]$persona))
ok("the four files whose reply R parses carry an Output format",
   purrr::every(rfiles[REFLEX_FILES_WITH_OUTPUT], function(s) !is.na(s$output_format)))

# Source lines and HTML comments, taken from the raw files, to prove below that
#   none of them reaches a prompt. Check questions likewise.
raw_text <- purrr::map_chr(file.path(REFLEXES_DIR, REFLEX_FILES), function(p)
  paste(readLines(p, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
squash <- function(x) gsub("\\s+", " ", x)
comment_texts <- unlist(regmatches(raw_text, gregexpr("(?s)<!--.*?-->", raw_text, perl = TRUE))) |>
  sub(pattern = "^<!--", replacement = "") |> squash() |> trimws() |> substr(1, 50)
source_texts <- unlist(purrr::map(rfiles, function(s) purrr::map_chr(s$reflexes, "source")))
source_texts <- source_texts[!is.na(source_texts)]
check_texts <- unlist(purrr::map(rfiles, function(s) purrr::map_chr(s$reflexes, "check")))
check_texts <- check_texts[!is.na(check_texts)]
# The parser must have found every Source line, every Check line and every
#   comment that is in the raw files, or the "none in any prompt" checks below
#   would prove nothing. Counted here straight from the text, outside the parser.
n_raw <- function(pattern, txt) sum(lengths(regmatches(txt, gregexpr(pattern, txt, perl = TRUE))))
raw_no_comments <- gsub("(?s)<!--.*?-->", "", raw_text, perl = TRUE)
ok("the parser found every Source line, Check line and comment in the raw files",
   length(source_texts) > 0 && length(check_texts) > 0 && length(comment_texts) > 0 &&
     length(source_texts) == n_raw("(?m)^- \\*\\*Source:\\*\\*", raw_no_comments) &&
     length(check_texts) == n_raw("(?m)^- \\*\\*Check:\\*\\*", raw_no_comments) &&
     length(comment_texts) == n_raw("<!--", raw_text))

# A reflex file that has lost its shape must fail with the file and the reflex
#   named. The first fixture is well formed, so the others fail for their own
#   reason and not for something common to all of them.
try_reflex_file <- function(body, header = c("# Fixture", "", "Version: 0.1", ""), name = "fixture.md") {
  p = file.path(tempdir(), name)
  writeLines(c(header, body), p)
  tryCatch(parse_reflex_file(p), error = function(e) conditionMessage(e))
}
good <- try_reflex_file(c("<!-- a note for people -->", "## Reflexes", "", "### fine_one",
                    "- **When:** Always.", "- **Say:** Do it.", "- **Never:** Skip it.",
                    "- **Check:** Was it done?", "- **Source:** A book.", "",
                    "## Prohibitions", "", "- Never lie.", "",
                    "## Output format", "", "Return JSON."))
ok("a well-formed fixture parses, keeping Check and Source",
   is.list(good) && identical(good$reflexes$fine_one$check, "Was it done?") &&
     identical(good$reflexes$fine_one$source, "A book.") &&
     identical(good$prohibitions, "Never lie.") && identical(good$output_format, "Return JSON."))

refl <- function(...) c("## Reflexes", "", "### oops", ...)
says <- function(msg, ...) grepl(msg, try_reflex_file(...), fixed = TRUE)
ok("a reflex with no Say stops, naming the file and the reflex",
   says("Reflex 'oops' in fixture.md needs a When and a Say line.", refl("- **When:** Always.")))
ok("a misspelt field name stops, naming the reflex",
   says("Reflex 'oops' in fixture.md has a line that is not a field",
        refl("- **When:** Always.", "- **Sey:** Do it.")))
ok("a field wrapped onto a second line stops",
   says("has a line that is not a field",
        refl("- **When:** Always.", "- **Say:** Do it", "  and then continue.")))
ok("a repeated field stops",
   says("has the field Say twice", refl("- **When:** Always.", "- **Say:** A.", "- **Say:** B.")))
ok("an empty field stops",
   says("has a field with nothing in it", refl("- **When:** Always.", "- **Say:**")))
ok("a reflex id with capitals or hyphens stops",
   says("needs an id in lower case",
        c("## Reflexes", "", "### Not-Ok", "- **When:** Always.", "- **Say:** Do it.")))
ok("two reflexes with one id stop",
   says("two reflexes called 'oops'",
        c(refl("- **When:** A.", "- **Say:** B."), "", "### oops", "- **When:** A.", "- **Say:** B.")))
ok("text before the first reflex stops",
   says("before the first '### id'", c("## Reflexes", "stray words", "### oops",
                                        "- **When:** A.", "- **Say:** B.")))
ok("an unknown section stops",
   says("section that is not part of the format: '## Reflex'",
        c("## Reflex", "", "### oops", "- **When:** A.", "- **Say:** B.")))
fine_reflex <- c("## Reflexes", "", "### fine_one", "- **When:** A.", "- **Say:** B.")
ok("a Guidelines section is read: an optional heading line, then one-line bullets; bullets alone are fine",
   local({
     with_head = try_reflex_file(c("## Guidelines", "", "<!-- a note -->", "Guidelines:", "", "- One.", "- Two.", "", fine_reflex))
     bare = try_reflex_file(c("## Guidelines", "", "- Only.", "", fine_reflex))
     is.list(with_head) && identical(with_head$guidelines, list(heading = "Guidelines:", bullets = c("One.", "Two."))) &&
       is.list(bare) && is.na(bare$guidelines$heading) && identical(bare$guidelines$bullets, "Only.") &&
       is.null(good$guidelines)
   }))
ok("a Guidelines section with a second heading line, a wrapped bullet or no bullets stops, naming the file",
   says("has a '## Guidelines' section that is not an optional heading line and then one-line bullets",
        c("## Guidelines", "", "Head", "More head", "- One.", "", fine_reflex)) &&
     says("fixture.md has a '## Guidelines' section that is not", c("## Guidelines", "", "- One", "  wrapped.", "", fine_reflex)) &&
     says("fixture.md has a '## Guidelines' section that is not", c("## Guidelines", "", "Heading only", "", fine_reflex)))
ok("a missing Reflexes section stops",
   says("has no '## Reflexes' section", c("## Prohibitions", "", "- Never lie.")))
ok("a prohibition wrapped onto a second line stops",
   says("not a one-line bullet",
        c(refl("- **When:** A.", "- **Say:** B."), "", "## Prohibitions", "", "- Never", "  lie.")))
ok("an HTML comment that never closes stops",
   says("never closed", c("<!-- no end", refl("- **When:** A.", "- **Say:** B."))))
ok("a missing Version line stops",
   says("has no Version: line", refl("- **When:** A.", "- **Say:** B."),
        header = c("# Fixture", "")))
ok("a missing file stops", grepl("is missing", tryCatch(read_reflex_file("nope.md"), error = conditionMessage)))

# The assembled prompts: every task, every mode on its own, none, and all five,
#   with and without a country.
blank_form <- list(task = "", research_question = "", construct = "", population = "",
                   country = "", modes = character(0), n_items = NA_integer_,
                   reference_period = "", keep_items = "", other = "",
                   questionnaire = "", revision = "")
make_form <- function(...) utils::modifyList(blank_form, list(...))
forms <- list(
  attitudinal = make_form(task = "attitudinal", n_items = 6L,
    research_question = "How much do adults trust the national electoral commission?",
    construct = "Trust in the national electoral commission",
    population = "Adults aged 18 and over", modes = "web"),
  behavioral = make_form(task = "behavioral", n_items = 3L,
    research_question = "How often do adults get news from radio?",
    construct = "Frequency of radio news use",
    population = "Adults aged 18 and over", reference_period = "past 7 days",
    modes = c("telephone", "face_to_face")),
  sensitive = make_form(task = "sensitive", n_items = 2L,
    research_question = "How common is paying a bribe for a public service?",
    population = "Adults aged 18 and over", modes = "face_to_face"),
  evaluate = make_form(task = "evaluate",
    research_question = "Satisfaction with local services",
    population = "Adults aged 18 and over", modes = "paper",
    questionnaire = paste("Q1. How satisfied are you with local recycling? Very / Fairly / Not",
                          "Q2. Taking all things together, how happy are you? 0 to 10", sep = "\n")))

mode_sets <- c(list(character(0)), as.list(names(MODE_LABELS)), list(names(MODE_LABELS)))
combos <- expand.grid(task = names(forms), m = seq_along(mode_sets),
                      country = c("", "Kenya"), stringsAsFactors = FALSE)
built <- purrr::pmap(combos, function(task, m, country) {
  fm = utils::modifyList(forms[[task]], list(modes = mode_sets[[m]], country = country))
  list(task = task, modes = mode_sets[[m]], country = country, form = fm,
       p = build_prompt(fm), again = build_prompt(fm), ck = build_checklist(fm))
})
ok(sprintf("a prompt assembles for each of %d task, mode and country combinations", length(built)),
   length(built) == nrow(combos))

ids_in <- function(txt) {
  hits = regmatches(txt, gregexpr("(?m)^- [a-z][a-z0-9_]* \\(", txt, perl = TRUE))[[1]]
  sub(" \\($", "", sub("^- ", "", hits))
}
both_of <- function(b) paste(b$p$system, b$p$user)
every_built <- function(f) purrr::every(built, f)
none_in_any <- function(strings)
  !any(purrr::map_lgl(built, function(b) {
    txt = squash(both_of(b))
    any(purrr::map_lgl(strings, function(s) grepl(s, txt, fixed = TRUE)))
  }))

ok("the same form twice gives the same prompt and the same hash",
   every_built(function(b) identical(b$p, b$again)))
ok("the contract: build_prompt(form) and build_checklist(form), and what build_prompt returns",
   identical(names(formals(build_prompt)), "form") &&
     identical(names(formals(build_checklist)), "form") &&
     every_built(function(b) identical(sort(names(b$p)), c("files", "hash", "message", "system", "tail", "user")) &&
                   identical(b$p$user, paste0(b$p$message, "\n\n", b$p$tail)) &&
                   is.character(b$p$system) && length(b$p$system) == 1L &&
                   is.character(b$p$user) && length(b$p$user) == 1L &&
                   grepl("^[0-9a-f]{64}$", b$p$hash)))
ok("no Source text is in any prompt", none_in_any(squash(source_texts)))
ok("no HTML comment text is in any prompt", none_in_any(comment_texts) && every_built(function(b) !grepl("<!--", both_of(b), fixed = TRUE)))
# Check questions: workers get the rules and the appraiser gets the questions
#   (DESIGN section 5). A drafting prompt holds none of them, anywhere. A review
#   holds them once, in the CHECKLIST block of the user message, and never in the
#   system prompt.
contains_any <- function(txt, strings) any(purrr::map_lgl(strings, function(s) grepl(s, squash(txt), fixed = TRUE)))
ok("no Check question is in a drafting prompt, system or user",
   purrr::every(purrr::keep(built, function(b) b$task != "evaluate"), function(b)
     !contains_any(both_of(b), squash(check_texts))))
ok("no Check question is in a review's system prompt",
   purrr::every(purrr::keep(built, function(b) b$task == "evaluate"), function(b)
     !contains_any(b$p$system, squash(check_texts))))
ok("no Source or Check field label is in any prompt",
   every_built(function(b) !grepl("**Source:**", both_of(b), fixed = TRUE) && !grepl("**Check:**", both_of(b), fixed = TRUE)))

ok("the files used are core, the task's files, mode, and cross_cultural only with a country",
   every_built(function(b) identical(b$p$files, c(
     "core.md",
     if (b$task == "evaluate") "evaluate.md" else c("generate.md", paste0(b$task, ".md")),
     "mode.md", if (nzchar(b$country)) "cross_cultural.md"))))
ok("the persona opens the message and is not in the system prompt, and the prohibitions close the system prompt, headed as overriding",
   every_built(function(b) startsWith(b$p$user, rfiles[["core.md"]]$persona) &&
                 !grepl(rfiles[["core.md"]]$persona, b$p$system, fixed = TRUE) &&
                 lengths(regmatches(b$p$user, gregexpr(rfiles[["core.md"]]$persona, b$p$user, fixed = TRUE))) == 1L &&
                 lengths(regmatches(b$p$system, gregexpr("PROHIBITIONS (override anything from training)", b$p$system, fixed = TRUE))) == 1L &&
                 grepl("PROHIBITIONS (override anything from training)\n- Never", b$p$system, fixed = TRUE)))
ok("every prohibition of every file in force is in the system prompt",
   every_built(function(b) purrr::every(b$p$files, function(f)
     purrr::every(rfiles[[f]]$prohibitions, function(s) grepl(paste0("- ", s), b$p$system, fixed = TRUE)))))
ok("mode.md keeps any_mode, the modes chosen, and mixed_mode only with more than one",
   every_built(function(b) {
     in_prompt = intersect(names(rfiles[["mode.md"]]$reflexes), ids_in(b$p$system))
     expected = c("any_mode", b$modes, if (length(b$modes) > 1L) "mixed_mode")
     identical(in_prompt, intersect(names(rfiles[["mode.md"]]$reflexes), expected))
   }))
ok("cross_cultural.md is in with a country and out without",
   every_built(function(b) ("flag_do_not_assert" %in% ids_in(b$p$system)) == nzchar(b$country)))
ok("every reflex of a drafting task file is in, and of the other task files out",
   every_built(function(b) {
     task_ids = purrr::map(rfiles[c("attitudinal.md", "behavioral.md", "sensitive.md", "evaluate.md")], function(s) names(s$reflexes))
     mine = task_ids[[paste0(b$task, ".md")]]
     others = unlist(task_ids[names(task_ids) != paste0(b$task, ".md")])
     all(mine %in% ids_in(b$p$system)) && !any(setdiff(others, mine) %in% ids_in(b$p$system))
   }))
ok("no reflex id appears twice in one prompt", every_built(function(b) !anyDuplicated(ids_in(b$p$system))))

ok("the message is the persona, Brief:, Task:, (for Evaluate, Questionnaire:), the guidelines; then R's tail: (for Evaluate, CHECKLIST) and REPLY FORMAT; the old labels are not written",
   every_built(function(b) {
     u = b$p$user
     heads = c("Brief:", "Task:", if (b$task == "evaluate") "Questionnaire:", "Guidelines:",
               if (b$task == "evaluate") "CHECKLIST", "REPLY FORMAT")
     pos = purrr::map_int(heads, function(h) as.integer(regexpr(paste0("(?m)^", h, "$"), u, perl = TRUE)))
     all(pos > 0) && all(diff(pos) > 0) && startsWith(u, paste0(rfiles[["core.md"]]$persona, "\n\nBrief:\n")) &&
       !grepl("(?m)^(PREPARE|ASK|CHARACTERIZE)$", u, perl = TRUE) &&
       startsWith(b$p$tail, if (b$task == "evaluate") "CHECKLIST\n" else "REPLY FORMAT\n")
   }))
ok("a draft's message holds core.md's guidelines and then the task file's; a review's only core.md's; none is in the system prompt",
   every_built(function(b) {
     gl = function(file) paste0("- ", rfiles[[file]]$guidelines$bullets)
     core_in = all(purrr::map_lgl(gl("core.md"), function(l) grepl(paste0("\n", l, "\n"), paste0("\n", b$p$message, "\n"), fixed = TRUE)))
     task_file = paste0(b$task, ".md")
     task_in = if (b$task == "evaluate") !any(grepl("Ask about a specific, clearly defined attitude object.", b$p$message, fixed = TRUE))
       else all(purrr::map_lgl(gl(task_file), function(l) grepl(paste0("\n", l, "\n"), paste0("\n", b$p$message, "\n"), fixed = TRUE))) &&
         regexpr(gl("core.md")[1], b$p$message, fixed = TRUE) < regexpr(gl(task_file)[1], b$p$message, fixed = TRUE)
     core_in && task_in && !grepl("Use simple, familiar words.\n", b$p$system, fixed = TRUE) &&
       !grepl("Guidelines:", b$p$system, fixed = TRUE)
   }))
ok("the Output format of the file that carries it is in the user message, as written",
   every_built(function(b) grepl(rfiles[[if (b$task == "evaluate") "evaluate.md" else "generate.md"]]$output_format,
                                 b$p$user, fixed = TRUE)))
ok("the number of items is in the ask for the drafting tasks",
   every_built(function(b) b$task == "evaluate" ||
                 grepl(paste0("Write exactly ", b$form$n_items, " survey item"), b$p$user, fixed = TRUE)))
ok("the pasted questionnaire follows Task:, whole and as pasted, and only for Evaluate",
   every_built(function(b) if (b$task == "evaluate")
     grepl("\nTask:\n", b$p$user, fixed = TRUE) &&
       grepl(paste0("\n\nQuestionnaire:\n", b$form$questionnaire, "\n\nGuidelines:\n"), b$p$user, fixed = TRUE)
   else !grepl("Questionnaire:", b$p$user, fixed = TRUE)))
ok("a review's CHECKLIST is exactly build_checklist(form), id: question, then REPLY FORMAT, in R's tail after the message",
   purrr::every(purrr::keep(built, function(b) b$task == "evaluate"), function(b) {
     block = paste0("CHECKLIST\n", paste0(names(b$ck), ": ", unname(b$ck), collapse = "\n"), "\n\nREPLY FORMAT\n")
     length(b$ck) > 0 && startsWith(b$p$tail, block) && !grepl("CHECKLIST", b$p$message, fixed = TRUE) &&
       lengths(regmatches(b$p$user, gregexpr("\nCHECKLIST\n", b$p$user, fixed = TRUE))) == 1L &&
       regexpr("\nQuestionnaire:\n", b$p$user, fixed = TRUE) < regexpr("\nCHECKLIST\n", b$p$user, fixed = TRUE)
   }))
ok("a drafting prompt has no CHECKLIST block and no Check question in its user message",
   purrr::every(purrr::keep(built, function(b) b$task != "evaluate"), function(b)
     !grepl("CHECKLIST", b$p$user, fixed = TRUE)))

# The checklist is the Check lines of the reflexes the prompt kept.
ok("the checklist is a named character vector of the Check lines in force",
   every_built(function(b) {
     ck = b$ck
     in_force = unlist(purrr::map(b$p$files, function(f) purrr::map_chr(rfiles[[f]]$reflexes, "check")))
     is.character(ck) && !is.null(names(ck)) && !anyDuplicated(names(ck)) &&
       all(nzchar(ck)) && all(names(ck) %in% ids_in(b$p$system)) &&
       all(names(ck) %in% names(in_force)[!is.na(in_force)]) &&
       length(ck) == sum(!is.na(in_force[names(in_force) %in% ids_in(b$p$system)]))
   }))
web_ck <- build_checklist(forms$attitudinal)
ok("the checklist follows the mode filter: web in, telephone out, one_thing in",
   all(c("web", "one_thing", "attitude_object") %in% names(web_ck)) &&
     !any(c("telephone", "mixed_mode") %in% names(web_ck)) && is.na(web_ck["restraint"]))
ok("a reflex with no Check line is not in the checklist (restraint, in Evaluate)",
   !"restraint" %in% names(build_checklist(forms$evaluate)) &&
     "filters_and_routing" %in% names(build_checklist(forms$evaluate)))

# What changes the hash, and what must not.
h <- function(...) build_prompt(utils::modifyList(forms$attitudinal, list(...)))$hash
base_hash <- h()
changes <- list(
  research_question = "Something else entirely?", construct = "A different construct",
  population = "Adults aged 65 and over", country = "Kenya", modes = "mobile_web",
  n_items = 7L,
  reference_period = "past year", keep_items = "Q1. An item to keep.",
  other = "Keep it short.", revision = "Make the stems shorter.")
ok("a change to any one field of the form changes the hash",
   purrr::every(names(changes), function(nm) !identical(do.call(h, changes[nm]), base_hash)))
ok("a changed questionnaire changes the Evaluate hash",
   !identical(build_prompt(utils::modifyList(forms$evaluate, list(questionnaire = "Q1. Other?")))$hash,
              build_prompt(forms$evaluate)$hash))
ok("a blank is the same blank: empty, character(0), NA, or only spaces",
   purrr::every(list("", character(0), NA_character_, "   "), function(b)
     identical(h(construct = b, other = b, modes = character(0)),
               h(construct = "", other = "", modes = character(0)))) &&
     identical(h(modes = NA_character_), h(modes = character(0))))
ok("the order modes are ticked in does not matter",
   identical(build_prompt(utils::modifyList(forms$behavioral, list(modes = c("telephone", "face_to_face"))))$hash,
             build_prompt(utils::modifyList(forms$behavioral, list(modes = c("face_to_face", "telephone"))))$hash))
ok("a Windows line ending is the same as a newline",
   identical(h(other = "line one\r\nline two"), h(other = "line one\nline two")))
ok("a change to a reflex file changes the hash",
   local({
     dir = file.path(tempdir(), "reflexes_copy")
     dir.create(dir, showWarnings = FALSE)
     file.copy(file.path(REFLEXES_DIR, REFLEX_FILES), dir, overwrite = TRUE)
     core = file.path(dir, "core.md")
     writeLines(sub("Write plainly.", "Write plainly!", readLines(core, encoding = "UTF-8", warn = FALSE), fixed = TRUE), core)
     f = clean_form(forms$attitudinal)
     before = reflexes_in_force(f)
     after = reflexes_in_force(f, dir)
     !identical(read_reflex_file("core.md")$sha, read_reflex_file("core.md", dir)$sha) &&
       !identical(prompt_hash(assemble_system(before), assemble_message(f, before)),
                  prompt_hash(assemble_system(after), assemble_message(f, after)))
   }))

# The PREPARE lines: fixed labels, fixed order, blanks left out.
prepare_of <- function(fm) {
  u = strsplit(build_prompt(fm)$user, "\n\n", fixed = TRUE)[[1]][2]
  sub(":.*$", "", strsplit(u, "\n", fixed = TRUE)[[1]][-1])
}
full <- utils::modifyList(forms$attitudinal, list(
  country = "Kenya",
  reference_period = "past 7 days", keep_items = "Q1. Keep this.", other = "Short."))
ok("the PREPARE labels are the contract's, in its order, each on its own line",
   identical(prepare_of(full),
             c("Research question", "Construct", "Target population", "Country",
               "Survey mode", "Reference period",
               "Existing items to keep", "Other details")))
ok("blank fields leave no PREPARE line",
   identical(prepare_of(forms$attitudinal),
             c("Research question", "Construct", "Target population", "Survey mode")))
ok("a language is not a field of the form: it is refused, and no language line is in any prompt",
   grepl("not in the contract: output_language", tryCatch(build_prompt(c(forms$attitudinal, list(output_language = "French"))), error = conditionMessage), fixed = TRUE) &&
     !any(c("output_language", "source_language") %in% FORM_FIELDS) &&
     every_built(function(b) !grepl("language:", b$p$user, ignore.case = TRUE)))
ok("the form has twelve fields and every task's fields are among them",
   length(FORM_FIELDS) == 12L && purrr::every(TASKS, function(t) all(t$fields %in% FORM_FIELDS)))

ok("the survey mode line reads in words, in the fixed order of the modes",
   grepl("Survey mode: mobile web, telephone, face-to-face\n",
         build_prompt(utils::modifyList(forms$attitudinal,
                                        list(modes = c("face_to_face", "mobile_web", "telephone"))))$user,
         fixed = TRUE))
ok("a REVISION line is in the ask on a rerun and nowhere else",
   grepl("\nTask:\n[^\n]+\nREVISION: Make the stems shorter\\.\n\nGuidelines:",
         build_prompt(utils::modifyList(forms$attitudinal, list(revision = "Make the stems shorter.")))$user,
         perl = TRUE) &&
     !grepl("REVISION", build_prompt(forms$attitudinal)$user, fixed = TRUE))
has_cc <- function(...)
  "flag_do_not_assert" %in% ids_in(build_prompt(utils::modifyList(forms$attitudinal, list(...)))$system)
ok("cross_cultural is sent for a country and for nothing else",
   has_cc(country = "Kenya") && !has_cc() && !has_cc(country = "") && !has_cc(country = "  "))

# A form that cannot make a prompt stops, saying why. It never makes a guess.
fails <- function(msg, ...) grepl(msg, tryCatch({ build_prompt(...); "no error" }, error = conditionMessage), fixed = TRUE)
ok("a form with no research question stops", fails("research question is required", utils::modifyList(forms$attitudinal, list(research_question = " "))))
ok("an unknown task stops", fails("task must be one of", utils::modifyList(forms$attitudinal, list(task = "poem"))))
ok("a drafting task with no number of items stops", fails("number of items", utils::modifyList(forms$attitudinal, list(n_items = NA_integer_))))
ok("a number of items that is not a whole number of one or more stops",
   fails("number of items", utils::modifyList(forms$attitudinal, list(n_items = 2.5))) &&
     fails("number of items", utils::modifyList(forms$attitudinal, list(n_items = 0L))))
ok("Evaluate with no questionnaire stops", fails("questionnaire pasted in", utils::modifyList(forms$evaluate, list(questionnaire = ""))))
ok("a field that is not in the contract stops", fails("not in the contract: populaton", c(forms$attitudinal, list(populaton = "typo"))))
ok("an unknown survey mode stops", fails("Unknown survey mode: radio", utils::modifyList(forms$attitudinal, list(modes = "radio"))))


# ---- Phase 2: the model layer. No model is called: the network is a stand-in ---

stopifnot("webfakes is needed for the mock-server checks (home only): install.packages('webfakes')" =
            requireNamespace("webfakes", quietly = TRUE))

# Environment variables for the length of one expression, then put back as they
#   were. NA means unset.
set_env <- function(vars)
  purrr::iwalk(vars, function(v, nm)
    if (is.na(v)) Sys.unsetenv(nm) else do.call(Sys.setenv, stats::setNames(list(v), nm)))
with_env <- function(vars, code) {
  old = Sys.getenv(names(vars), unset = NA)
  on.exit(set_env(old))
  set_env(vars)
  force(code)
}

m_analyst <- list(api = "anthropic", base_url = "https://api.anthropic.com/v1",
                  id = "claude-x", key_source = "analyst")
m_server <- list(api = "openai", base_url = "https://openrouter.ai/api/v1",
                 id = "vendor/model-x", key_source = "server", key_var = "QUESTIONR_SMOKE_KEY")
fails_with <- function(expr, class = "llm_error") {
  e = tryCatch({ expr; NULL }, error = function(e) e)
  if (inherits(e, class)) e else NULL
}


# The five failures svysegment met in model replies, and the ones no repair can
#   fix. Each goes through clean_model_reply() first, as llm_json() does.
parsed <- function(txt) tryCatch(parse_json_block(clean_model_reply(txt)), error = function(e) e)

r1 <- parsed('{"stem": "Do you "often" read a paper?", "options": ["Yes", "No"]}')
ok("repair: a bare double quote inside a value is escaped, and the rest is kept",
   identical(r1$stem, 'Do you "often" read a paper?') && identical(unlist(r1$options), c("Yes", "No")))
r2 <- parsed('{"id": "A1", "stem": "How often do you read a paper?}')
ok("repair: the quote the model left off the last value is put back",
   identical(r2$stem, "How often do you read a paper?") && identical(r2$id, "A1"))
r3 <- parsed('{"items": [{"id": "A1", "stem": "How often do you read')
ok("repair: a reply cut off inside a value is closed, and what arrived is kept",
   identical(r3$items[[1]]$id, "A1") && identical(r3$items[[1]]$stem, "How often do you read"))
r4 <- parsed('Here is the JSON you asked for:\n```json\n{"a": 1}\n```\nHope this helps.')
ok("repair: JSON inside a code fence and prose is found", identical(r4$a, 1L))
r5 <- parsed('<|start_header_id|>assistant<|end_header_id|>\n\n{"a": "b"}<|eot_id|>')
ok("repair: chat-template tokens and a bare 'assistant' line are stripped before parsing",
   identical(r5$a, "b"))
ok("a reply with no JSON fails, and says so",
   grepl("No JSON found", conditionMessage(parsed("I am unable to help with that.")), fixed = TRUE))
ok("a reply that cannot be repaired fails, carrying the reply",
   grepl("could not be repaired", conditionMessage(parsed('{"a": ')), fixed = TRUE) &&
     grepl("--- reply ---", conditionMessage(parsed('{"a": ')), fixed = TRUE))
ok("the echoed template ({\"stem\": \"...\"}) and an empty object count as no answer",
   is_placeholder_reply(list(stem = "...", options = list("..."))) &&
     is_placeholder_reply(list()) && !is_placeholder_reply(list(stem = "Real question?")))


# llm_json() with a scripted stand-in for the network: the replies in turn (the
#   last repeats), a count of the calls, and what each call was sent.
reply <- function(txt, finish = "success") structure(txt, finish = finish, provider = "mock")
scripted <- function(...) {
  replies = list(...)
  st = new.env()
  st$calls = 0L
  st$seen = list()
  list(state = st, complete = function(m, system_prompt, user, max_tokens, key, timeout = NULL) {
    st$calls = st$calls + 1L
    st$seen[[st$calls]] = list(user = user, key = key, system = system_prompt, max_tokens = max_tokens)
    r = replies[[min(st$calls, length(replies))]]
    if (is.function(r)) r() else r
  })
}
m_fake <- list(api = "openai", base_url = "http://mock.invalid/v1", id = "mock/model",
               key_source = "analyst")
good_json <- '{"stem": "Real question?", "options": ["a", "b"]}'
run_json <- function(sc, ..., fresh = TRUE) {
  if (fresh) llm_clear_counters(llm_session_id())
  llm_json(user = "Question?", m = m_fake, system_prompt = "SYS", max_tokens = 100L,
           key = "k-test", complete = sc$complete, pause_base = 0.01, pause_min = 0.01, ...)
}

sc <- scripted(reply(good_json))
res <- run_json(sc)
ok("a good reply comes back parsed, with the raw text, the message as sent and one attempt",
   identical(res$obj$stem, "Real question?") && identical(res$raw, good_json) &&
     res$attempts == 1L && sc$state$calls == 1L && identical(res$model, "mock/model") &&
     identical(res$finish, "success"))
ok("the message sent is the approved prompt plus the quote rule, and nothing else",
   identical(res$user_sent, paste0("Question?\n\n", JSON_QUOTE_RULE)) &&
     identical(sc$state$seen[[1]]$user, res$user_sent) &&
     identical(sc$state$seen[[1]]$key, "k-test") && identical(sc$state$seen[[1]]$system, "SYS") &&
     identical(sc$state$seen[[1]]$max_tokens, 100L))

sc <- scripted(reply("Sorry, here you go."), reply(good_json))
res <- run_json(sc)
ok("a reply that is not JSON is tried again, and the second one is returned",
   res$attempts == 2L && sc$state$calls == 2L && identical(res$obj$stem, "Real question?"))

sc <- scripted(function() llm_fail("HTTP 503: overloaded"), function() llm_fail("HTTP 503: overloaded"),
               reply(good_json))
res <- run_json(sc)
ok("a transient error (503, a timeout) is tried again, and the third attempt succeeds",
   res$attempts == 3L && identical(res$obj$options, list("a", "b")))

sc <- scripted(reply("not json at all"))
err <- fails_with(run_json(sc))
ok("a reply that never parses fails after exactly three attempts",
   !is.null(err) && !inherits(err, "llm_client_error") && sc$state$calls == 3L)
ok("the failure names the model, the endpoint and why it stopped, and carries the raw reply",
   grepl("[mock/model via mock, finish: success]", conditionMessage(err), fixed = TRUE) &&
     identical(err$raw, "not json at all"))

sc <- scripted(reply(good_json, finish = "max_tokens"))
err <- fails_with(run_json(sc), "llm_truncated")
ok("a reply cut off at the token limit is a failure even when what arrived would parse, and is not tried again",
   !is.null(err) && sc$state$calls == 1L && identical(err$raw, good_json) &&
     grepl("reached the token limit (100)", conditionMessage(err), fixed = TRUE) &&
     !grepl("Ask for fewer items", conditionMessage(err), fixed = TRUE) && llm_retries_used() == 0L)
ok("the ceilings are section 13's (brief 4000, drafting 12000, appraisal 24000) and the timeout 600 s",
   identical(unname(LLM_MAX_TOKENS[c("brief", "draft", "appraisal")]), c(4000L, 12000L, 24000L)) &&
     identical(LLM_TIMEOUT_S, 600))

sc <- scripted(reply('{"stem": "...", "options": ["..."]}'))
err <- fails_with(run_json(sc))
ok("the echoed example object is a failed attempt, retried",
   !is.null(err) && sc$state$calls == 3L && grepl("example template", conditionMessage(err), fixed = TRUE))

need_items <- function(o) if (is.null(o$items)) stop("the reply has no items field") else invisible(o)
sc <- scripted(reply('{"a": "x"}'), reply('{"items": [{"id": "Q1"}]}'))
res <- run_json(sc, validate = need_items)
ok("a reply that fails the validator is tried again; one that passes is returned",
   res$attempts == 2L && identical(res$obj$items[[1]]$id, "Q1"))
sc <- scripted(reply('{"a": "x"}'))
err <- fails_with(run_json(sc, validate = need_items))
ok("a validator's own message reaches the analyst when every attempt fails",
   !is.null(err) && sc$state$calls == 3L &&
     grepl("the reply has no items field", conditionMessage(err), fixed = TRUE))

sc <- scripted(function() llm_fail("The endpoint refused the request (HTTP 401).", class = "llm_client_error"))
err <- fails_with(run_json(sc), "llm_client_error")
ok("a client error (bad key, unknown model) is raised at once and not tried again",
   !is.null(err) && sc$state$calls == 1L && grepl("HTTP 401", conditionMessage(err), fixed = TRUE))

sc <- scripted(reply(good_json))
err <- fails_with(llm_json(user = "Question?", m = m_fake, system_prompt = "SYS", max_tokens = 100L,
                           key = NULL, complete = sc$complete), "llm_client_error")
ok("no key is a client error before any call is made, and says what to do",
   !is.null(err) && sc$state$calls == 0L && grepl("Paste a key", conditionMessage(err), fixed = TRUE))

# The session cap: a prompt that is broken for every attempt must not drain the
#   quota one retry at a time.
llm_clear_counters(llm_session_id())
sc <- scripted(reply("not json"))
err <- fails_with(run_json(sc, session_cap = 2L, fresh = FALSE))
ok("a failed call uses two repeat attempts of the session's allowance",
   !is.null(err) && sc$state$calls == 3L && llm_retries_used() == 2L)
sc <- scripted(reply(good_json))
err <- fails_with(run_json(sc, session_cap = 2L, fresh = FALSE), "llm_client_error")
ok("once the allowance is used the next call fails at once, with the reason, and makes no call",
   !is.null(err) && sc$state$calls == 0L && grepl("retry cap of 2", conditionMessage(err), fixed = TRUE))
llm_clear_counters(llm_session_id())
ok("clearing the counters gives the session its allowance back",
   llm_retries_used() == 0L && run_json(scripted(reply(good_json)), session_cap = 2L, fresh = FALSE)$attempts == 1L)


# Where a key comes from. The environment is read for a server model and for no
#   other.
set_env(c(QUESTIONR_SMOKE_KEY = NA))
ok("a pasted-key model ignores ANTHROPIC_API_KEY, even when it is set",
   with_env(c(ANTHROPIC_API_KEY = "env-key-should-be-ignored"),
            is.null(llm_key_for(m_analyst)) && !llm_key_ready(m_analyst)))
ok("a server model reads the variable named in key_var",
   with_env(c(QUESTIONR_SMOKE_KEY = "server-key"),
            identical(llm_key_for(m_server), "server-key") && llm_key_ready(m_server)))
ok("a server model with the variable unset or empty has no key",
   with_env(c(QUESTIONR_SMOKE_KEY = NA), is.null(llm_key_for(m_server))) &&
     with_env(c(QUESTIONR_SMOKE_KEY = ""), is.null(llm_key_for(m_server))))
ok("each kind of model is told what to do about a missing key",
   grepl("key box", llm_key_hint(m_analyst), fixed = TRUE) &&
     grepl("QUESTIONR_SMOKE_KEY", llm_key_hint(m_server), fixed = TRUE))
ok("a server model with no key_var, or a key_source that is neither, is a client error",
   !is.null(fails_with(llm_key_for(utils::modifyList(m_server, list(key_var = NULL))), "llm_client_error")) &&
     !is.null(fails_with(llm_key_for(utils::modifyList(m_server, list(key_source = "file"))), "llm_client_error")))
ok("at home the project manager takes a pasted key and the workers a server variable",
   identical(llm_models()[[1]]$m$key_source, "analyst") &&
     length(llm_models()) == 1L + length(APP_MODELS$workers) &&
     all(purrr::map_chr(llm_models()[-1], function(x) x$m$key_source) == "server"))

paste_state <- shiny::reactiveValues(key_version = 0L)
shiny::testServer(mod_key_server, args = list(state = paste_state), {
  session$setInputs(key = "pasted-by-analyst", save = 1)
  with_env(c(ANTHROPIC_API_KEY = "env-key-should-be-ignored"),
           ok("a pasted-key model gets the pasted key, not the environment's",
              identical(llm_key_for(m_analyst), "pasted-by-analyst") && llm_key_ready(m_analyst)))
})
shiny::testServer(mod_key_server, args = list(state = paste_state), {
  ok("a key pasted in one session is not visible to another", is.null(llm_key_for(m_analyst)))
})


# The chat objects, built and inspected without a request.
chat_of <- function(m, key = "k-chat", max_tokens = 1500L) llm_chat(m, "SYS", max_tokens, key)
pa <- chat_of(m_analyst)$get_provider()
po <- chat_of(m_server, max_tokens = 4000L)$get_provider()
ok("anthropic: the Anthropic provider, with the model, base URL, ceiling and system prompt given",
   inherits(pa, "ellmer::ProviderAnthropic") && identical(S7::prop(pa, "model"), "claude-x") &&
     identical(S7::prop(pa, "base_url"), m_analyst$base_url) &&
     identical(S7::prop(pa, "params")$max_tokens, 1500L) &&
     identical(chat_of(m_analyst)$get_system_prompt(), "SYS"))
ok("openai: the OpenAI-compatible provider, with the model, base URL and ceiling given",
   inherits(po, "ellmer::ProviderOpenAICompatible") && identical(S7::prop(po, "model"), "vendor/model-x") &&
     identical(S7::prop(po, "base_url"), m_server$base_url) &&
     identical(S7::prop(po, "params")$max_tokens, 4000L))
ok("no temperature is set unless the model's entry sets one",
   is.null(S7::prop(pa, "params")$temperature) && is.null(S7::prop(po, "params")$temperature) &&
     identical(S7::prop(chat_of(utils::modifyList(m_analyst, list(temperature = 0.2)))$get_provider(),
                        "params")$temperature, 0.2))
ok("the key travels in a closure that returns it, and is not in the environment",
   identical(S7::prop(pa, "credentials")(), "k-chat") && identical(S7::prop(po, "credentials")(), "k-chat") &&
     !any(Sys.getenv() == "k-chat"))
ok("a chat with no key, or an api that is neither anthropic nor openai, is a client error",
   !is.null(fails_with(chat_of(m_analyst, key = NULL), "llm_client_error")) &&
     !is.null(fails_with(chat_of(m_analyst, key = ""), "llm_client_error")) &&
     !is.null(fails_with(chat_of(utils::modifyList(m_analyst, list(api = "cohere"))), "llm_client_error")))


# The real call path, ellmer and httr2 and all, against a server on this machine
#   that answers in both API styles and echoes what it was sent. Everything the
#   handlers use is made inside make_mock(), because the handlers run in another
#   process and see none of this one's variables. The model id picks the
#   behaviour: unknown-model is a 404, bad-key a 401, gateway a 502 with no
#   content type, cut-off a reply that stopped at the token limit.
make_mock <- function() {
  mock = webfakes::new_app()
  mock$use(webfakes::mw_json())
  na_if_null = function(x) if (is.null(x)) NA else x
  echo = function(req) {
    b = req$json
    jsonlite::toJSON(list(
      auth = na_if_null(req$get_header("Authorization")),
      xkey = na_if_null(req$get_header("x-api-key")),
      model = b$model, max_tokens = na_if_null(b$max_tokens),
      max_completion_tokens = na_if_null(b$max_completion_tokens),
      has_temperature = "temperature" %in% names(b),
      has_system = grepl("SYS-PROMPT", jsonlite::toJSON(b, auto_unbox = TRUE), fixed = TRUE)),
      auto_unbox = TRUE, na = "null")
  }
  refuse = function(req, res) {
    m = req$json$model
    if (identical(m, "unknown-model"))
      res$set_status(404L)$send_json(list(error = list(message = "model not found")), auto_unbox = TRUE)
    else if (identical(m, "bad-key"))
      res$set_status(401L)$send_json(list(error = list(message = "invalid api key: mock-key-123")), auto_unbox = TRUE)
    else if (identical(m, "gateway"))
      res$set_status(502L)$send("Bad Gateway")
    else return(FALSE)
    TRUE
  }
  mock$post("/v1/chat/completions", function(req, res) {
    if (refuse(req, res)) return()
    res$send_json(list(id = "x", object = "chat.completion", created = 1L, model = req$json$model,
      choices = list(list(index = 0L, message = list(role = "assistant", content = echo(req)),
                          finish_reason = if (identical(req$json$model, "cut-off")) "length" else "stop")),
      usage = list(prompt_tokens = 5L, completion_tokens = 7L, total_tokens = 12L)), auto_unbox = TRUE)
  })
  mock$post("/v1/messages", function(req, res) {
    if (refuse(req, res)) return()
    res$send_json(list(id = "msg_1", type = "message", role = "assistant", model = req$json$model,
      content = list(list(type = "text", text = echo(req))),
      stop_reason = if (identical(req$json$model, "cut-off")) "max_tokens" else "end_turn",
      stop_sequence = NULL, usage = list(input_tokens = 5L, output_tokens = 7L)),
      auto_unbox = TRUE, null = "null")
  })
  mock
}

local({
  px = webfakes::new_app_process(make_mock())
  on.exit(px$stop())
  mm = function(api, id = "mock/model")
    list(api = api, base_url = px$url("/v1"), id = id, key_source = "analyst")
  ask = function(api, id = "mock/model", max_tokens = 1500L, key = "mock-key-123")
    suppressWarnings(llm_complete(mm(api, id), "SYS-PROMPT", "hello", max_tokens, key = key, timeout = 20))

  a = ask("anthropic")
  sa = jsonlite::fromJSON(a)
  ok("anthropic style: the key in x-api-key, the ceiling as max_tokens, the system prompt sent, no temperature",
     identical(sa$xkey, "mock-key-123") && is.null(sa$auth) && identical(sa$max_tokens, 1500L) &&
       isTRUE(sa$has_system) && !isTRUE(sa$has_temperature) && identical(sa$model, "mock/model"))
  o = ask("openai", max_tokens = 4000L)
  so = jsonlite::fromJSON(o)
  ok("openai style: the key as a Bearer token, the ceiling as max_completion_tokens, the system prompt sent, no temperature",
     identical(so$auth, "Bearer mock-key-123") && is.null(so$xkey) &&
       identical(so$max_completion_tokens, 4000L) && is.null(so$max_tokens) &&
       isTRUE(so$has_system) && !isTRUE(so$has_temperature))
  ok("a reply carries why it stopped, the endpoint, the tokens and the seconds",
     identical(attr(a, "finish"), "success") && identical(attr(o, "finish"), "success") &&
       identical(attr(o, "provider"), sub("^http://([^/]+).*$", "\\1", px$url("/v1"))) &&
       identical(unname(attr(o, "tokens")[c("input", "output")]), c(5, 7)) &&
       is.numeric(attr(o, "seconds")))
  ok("a reply that stopped at the token limit says so, in both API styles",
     identical(attr(ask("anthropic", "cut-off"), "finish"), "max_tokens") &&
       identical(attr(ask("openai", "cut-off"), "finish"), "max_tokens"))

  e404 = fails_with(ask("openai", "unknown-model"), "llm_client_error")
  ok("a 404 is a client error and carries the endpoint's own words",
     !is.null(e404) && grepl("HTTP 404", conditionMessage(e404), fixed = TRUE) &&
       grepl("model not found", conditionMessage(e404), fixed = TRUE))
  e401 = fails_with(ask("anthropic", "bad-key"), "llm_client_error")
  ok("a 401 is a client error, and the key the endpoint echoed back is blanked",
     !is.null(e401) && grepl("HTTP 401", conditionMessage(e401), fixed = TRUE) &&
       grepl("[key]", conditionMessage(e401), fixed = TRUE) &&
       !grepl("mock-key-123", conditionMessage(e401), fixed = TRUE))
  e502 = fails_with(ask("openai", "gateway"))
  ok("a 502 with no content type is an error the analyst can read, and is not a client error",
     !is.null(e502) && !inherits(e502, "llm_client_error") &&
       grepl("HTTP 502", conditionMessage(e502), fixed = TRUE))

  go = function(api, id = "mock/model", ...) {
    llm_clear_counters(llm_session_id())
    llm_json("hello", mm(api, id), system_prompt = "SYS-PROMPT", max_tokens = 1500L,
             key = "mock-key-123", pause_base = 0.01, pause_min = 0.01, ...)
  }
  r = suppressWarnings(go("openai"))
  ok("llm_json() through the real path: the echoed object comes back parsed, with the message as sent",
     identical(r$obj$auth, "Bearer mock-key-123") && r$attempts == 1L &&
       endsWith(r$user_sent, JSON_QUOTE_RULE) && identical(r$finish, "success"))
  before = .llm_state$calls
  fails_with(suppressWarnings(go("openai", "unknown-model")), "llm_client_error")
  ok("a 404 through llm_json() makes one request, not three", .llm_state$calls - before == 1L)
  before = .llm_state$calls
  e = fails_with(suppressWarnings(go("anthropic", "cut-off")), "llm_truncated")
  ok("a reply cut off at the ceiling is requested once, then fails saying so",
     .llm_state$calls - before == 1L && !is.null(e) &&
       grepl("reached the token limit", conditionMessage(e), fixed = TRUE))
  before = .llm_state$calls
  e = fails_with(suppressWarnings(go("openai", "cut-off")), "llm_truncated")
  ok("the same on the OpenAI-style call, whose ceiling is max_completion_tokens",
     .llm_state$calls - before == 1L && !is.null(e))

  before = .llm_state$calls
  pa = llm_ping(mm("anthropic"), key = "mock-key-123")
  po = llm_ping(mm("openai"), key = "mock-key-123")
  ok("the connection check's call: ready when the endpoint answers, one request each, the reply kept",
     isTRUE(pa$ok) && isTRUE(po$ok) && .llm_state$calls - before == 2L &&
       grepl("mock-key-123", pa$reply, fixed = TRUE) && identical(po$message, "Ready."))
  bad = llm_ping(mm("openai", "bad-key"), key = "mock-key-123")
  ok("the connection check's call: the endpoint's own words when it refuses, never the key",
     isFALSE(bad$ok) && grepl("HTTP 401", bad$message, fixed = TRUE) &&
       !grepl("mock-key-123", bad$message, fixed = TRUE))
  none = llm_ping(m_analyst)
  ok("the connection check makes no call for a model with no key, and says what to do",
     isFALSE(none$ok) && is.na(none$seconds) && grepl("Waits for a key", none$message, fixed = TRUE))
  ok("no key reached the environment", !any(Sys.getenv() == "mock-key-123"))
})


# The connection check on Start here: who is ready, one small call each, no key shown.
local({
  called = new.env()
  called$ids = character(0)
  fake_ping = function(m, ...) {
    called$ids = c(called$ids, m$id)
    if (identical(m$id, APP_MODELS$workers[[1]]$id))
      list(ok = FALSE, message = "model not found (HTTP 404)", seconds = 0.2)
    else list(ok = TRUE, message = "Ready.", seconds = 0.1)
  }
  html_of = function(x) paste(as.character(x$html), collapse = "")
  n_in = function(pattern, txt) lengths(regmatches(txt, gregexpr(pattern, txt, fixed = TRUE)))
  pm_id = APP_MODELS$pm$id
  conn_state = shiny::reactiveValues(key_version = 0L)

  with_env(c(OPENROUTER_API_KEY = "or-secret-key", ANTHROPIC_API_KEY = "env-key-should-be-ignored"), {
    shiny::testServer(mod_connect_server, args = list(state = conn_state, ping = fake_ping), {
      t0 = html_of(output$models)
      ok("the table lists the project manager and each worker, with the key's source in words",
         n_in("<code>", t0) == 1L + length(APP_MODELS$workers) && grepl(pm_id, t0, fixed = TRUE) &&
           grepl("key pasted below", t0, fixed = TRUE) &&
           grepl("server variable OPENROUTER_API_KEY", t0, fixed = TRUE))
      ok("with no pasted key the project manager waits for one, whatever ANTHROPIC_API_KEY holds; the workers are ready",
         n_in("waits for a key", t0) == 1L && n_in(">ready<", t0) == length(APP_MODELS$workers))

      session$setInputs(check = 1)
      r1 = html_of(output$result)
      ok("Check connections calls each model that has a key and none that has not",
         identical(sort(called$ids), sort(purrr::map_chr(APP_MODELS$workers, "id"))))
      ok("the result shows ready, the endpoint's words for a refusal, and what a keyless model waits for",
         n_in("Ready", r1) == length(APP_MODELS$workers) - 1L &&
           grepl("model not found (HTTP 404)", r1, fixed = TRUE) &&
           grepl("Waits for a key", r1, fixed = TRUE))

      called$ids = character(0)
      llm_set_session_key("pasted-pm-key")
      conn_state$key_version = conn_state$key_version + 1L
      session$flushReact()
      t1 = html_of(output$models)
      ok("pasting a key makes the project manager ready, with no key on the page",
         n_in("waits for a key", t1) == 0L && !grepl("pasted-pm-key", t1, fixed = TRUE))
      session$setInputs(check = 2)
      r2 = html_of(output$result)
      ok("with a key the project manager is called as well, and no key is on the page",
         pm_id %in% called$ids && length(called$ids) == 1L + length(APP_MODELS$workers) &&
           !grepl("pasted-pm-key|or-secret-key|env-key-should-be-ignored", paste(t0, r1, t1, r2)))
    })
  })
})

ok("Start here has the models table and the Check connections button",
   grepl("Check connections", page$html, fixed = TRUE) && grepl("<h4>Models</h4>", page$html, fixed = TRUE))


# ---- Phase 3a: the task registry and one assembler for every step -----------------

inn <- function(txt, s) grepl(s, txt, fixed = TRUE)

ok("TASKS has the four tasks, each with a label, a kind, files, an ask and fields",
   identical(sort(names(TASKS)), c("attitudinal", "behavioral", "evaluate", "sensitive")) &&
     purrr::every(TASKS, function(t) all(c("label", "kind", "files", "ask", "fields") %in% names(t)) &&
                    nzchar(t$label) && length(t$fields) > 0L))
ok("a task's kind is draft or review, and only Evaluate is a review",
   purrr::every(TASKS, function(t) t$kind %in% c("draft", "review")) &&
     identical(names(purrr::keep(TASKS, function(t) t$kind == "review")), "evaluate"))
ok("every file a task names is a reflex file, core.md leads, and mode.md is in",
   purrr::every(TASKS, function(t) all(t$files %in% REFLEX_FILES) && identical(t$files[1], "core.md") &&
                  "mode.md" %in% t$files))
ok("every field a task shows is a field of the form, and none is the task itself",
   purrr::every(TASKS, function(t) all(t$fields %in% FORM_FIELDS) && !"task" %in% t$fields))
ok("a drafting task asks for items and shows the count; a review shows the questionnaire instead",
   purrr::every(TASKS, function(t) if (t$kind == "draft") inn(t$ask, "%s") && "n_items" %in% t$fields
                                   else !inn(t$ask, "%s") && "questionnaire" %in% t$fields &&
                                     !"n_items" %in% t$fields))
ok("a task that is not in the registry stops, naming the choices",
   grepl("task must be one of: attitudinal, behavioral, sensitive, evaluate",
         tryCatch(build_prompt(make_form(task = "poem", research_question = "x")),
                  error = conditionMessage), fixed = TRUE))
ok("TASK_FILES and TASK_ASK are gone: the registry is the only place",
   !exists("TASK_FILES") && !exists("TASK_ASK"))

ok("build_step_prompt(form, step, candidates, part), and build_prompt(form) is its work step",
   identical(names(formals(build_step_prompt)), c("form", "step", "candidates", "part")) &&
     identical(names(formals(build_prompt)), "form") &&
     every_built(function(b) identical(b$p, build_step_prompt(b$form, "work"))))
ok("an unknown step stops, naming the five",
   grepl("step must be one of: brief, work, appraise, items, instrument",
         tryCatch(build_step_prompt(forms$attitudinal, "polish"), error = conditionMessage), fixed = TRUE))

# The brief check: the project manager, before anything is approved.
brief_built <- purrr::map(forms, function(fm)
  list(form = fm, p = build_step_prompt(fm, "brief"), again = build_step_prompt(fm, "brief"),
       ck = build_checklist(fm)))
ok("the brief check sends core, pm_brief and the task's own files, in that order",
   purrr::every(brief_built, function(b)
     identical(b$p$files, c("core.md", "pm_brief.md",
                            setdiff(TASKS[[b$form$task]]$files, c("core.md", "cross_cultural.md"))))))
ok("the brief check's system prompt holds the brief rules and the task's rules, and no drafting output format",
   purrr::every(brief_built, function(b)
     inn(b$p$system, "- what_a_brief_needs (") && inn(b$p$system, "- criteria_preview (") &&
       inn(b$p$system, if (b$form$task == "evaluate") "- restraint (" else "- declare_defaults (") &&
       !inn(b$p$system, rfiles[["core.md"]]$persona) && startsWith(b$p$user, rfiles[["core.md"]]$persona)))
ok("the brief check's user message is the persona, then PREPARE, ASK, CHECKLIST, CHARACTERIZE, with pm_brief's output format",
   purrr::every(brief_built, function(b) {
     u = b$p$user
     pos = purrr::map_int(c("PREPARE", "ASK", "CHECKLIST", "CHARACTERIZE"), function(h)
       as.integer(regexpr(paste0("(?m)^", h, "$"), u, perl = TRUE)))
     all(pos > 0) && all(diff(pos) > 0) &&
       startsWith(u, paste0(rfiles[["core.md"]]$persona, "\n\nPREPARE\n")) &&
       inn(u, rfiles[["pm_brief.md"]]$output_format) && inn(u, "\"task_fit\"") &&
       !inn(u, "\"source_english\"") && !inn(u, "\"trapd\"")
   }))
ok("the brief check names the task the analyst chose, and its CHECKLIST is exactly build_checklist(form)",
   purrr::every(brief_built, function(b) {
     block = paste0("\n\nCHECKLIST\n", paste0(names(b$ck), ": ", unname(b$ck), collapse = "\n"), "\n\nCHARACTERIZE\n")
     inn(b$p$user, paste0("chose the task '", TASKS[[b$form$task]]$label, "'")) && inn(b$p$user, block)
   }))
ok("the brief check is deterministic, and holds no Source text, comment or Check field",
   purrr::every(brief_built, function(b) {
     both = squash(paste(b$p$system, b$p$user))
     identical(b$p, b$again) && !any(purrr::map_lgl(squash(source_texts), function(s) inn(both, s))) &&
       !inn(both, "<!--") && !inn(both, "**Check:**") && !inn(both, "**Source:**")
   }))
ok("the brief check's Check questions are in its user message only, never in the system prompt",
   purrr::every(brief_built, function(b) !contains_any(b$p$system, squash(check_texts)) &&
                  contains_any(b$p$user, squash(check_texts))))
ok("the brief check's hash differs from the work prompt's, and a changed field changes it",
   purrr::every(brief_built, function(b) !identical(b$p$hash, build_prompt(b$form)$hash)) &&
     !identical(build_step_prompt(forms$attitudinal, "brief")$hash,
                build_step_prompt(utils::modifyList(forms$attitudinal, list(population = "Adults 65+")), "brief")$hash))

# The appraisal: the project manager comparing candidates it cannot tell apart.
cand_item <- function(i, tag = "")
  list(id = paste0("TR", i), domain = paste("domain", i), intro = "",
       stem = paste0("Stem number ", i, tag, "?"), options = list("None", "Some", "A lot"),
       open_format = "", parts = list(list(when = "before the item", stem = paste0("Filter ", i, "?"),
                                           options = list("Yes", "No"))),
       programming = "Randomize options.", decisions = list("closed; three labelled options"),
       source_english = "", notes = paste0("SECRET-NOTE-", i, " written by model-x"))
cand <- function(tag, n = 2L) list(items = purrr::map(seq_len(n), cand_item, tag = tag),
                                   not_covered = list("domain 9"), missing_from_brief = list())
cands <- list(A = cand(" (A)"), B = cand(" (B)"), C = cand(" (C)"))
ap <- build_step_prompt(forms$attitudinal, "appraise", candidates = cands)
ok("the appraisal sends core and pm_appraise only, and none of the drafting rules",
   identical(ap$files, c("core.md", "pm_appraise.md")) &&
     inn(ap$system, "- check_before_choosing (") && inn(ap$system, "- pick_per_domain (") &&
     !inn(ap$system, "- declare_defaults (") && !inn(ap$system, "- attitude_object (") &&
     !inn(ap$system, rfiles[["core.md"]]$persona))
ok("the appraisal's user message is the persona, then PREPARE, ASK, CANDIDATES, CHECKLIST, CHARACTERIZE, in that order",
   local({
     pos = purrr::map_int(c("PREPARE", "ASK", "CANDIDATES", "CHECKLIST", "CHARACTERIZE"), function(h)
       as.integer(regexpr(paste0("(?m)^", h, "$"), ap$user, perl = TRUE)))
     all(pos > 0) && all(diff(pos) > 0) && inn(ap$user, rfiles[["pm_appraise.md"]]$output_format) &&
       startsWith(ap$user, paste0(rfiles[["core.md"]]$persona, "\n\nPREPARE\n")) &&
       inn(ap$user, "\"selected\"")
   }))
ok("the appraisal's CHECKLIST is exactly what the workers' files give, and their questions are not in the system prompt",
   local({
     ck = build_checklist(forms$attitudinal)
     inn(ap$user, paste0("\n\nCHECKLIST\n", paste0(names(ck), ": ", unname(ck), collapse = "\n"), "\n\nCHARACTERIZE\n")) &&
       !contains_any(ap$system, squash(check_texts))
   }))
ok("the appraisal says how many candidates and how many items each was asked for",
   inn(ap$user, "Appraise the 3 candidate drafts") && inn(ap$user, "exactly 6 survey items"))
ok("each candidate is one JSON line with its letter and its items' ids, domains, stems, options and open format, and nothing else of an item",
   local({
     lines = strsplit(ap$user, "\n", fixed = TRUE)[[1]]
     cl = lines[grepl("^\\{\"candidate\":", lines)]
     parsed = purrr::map(cl, jsonlite::fromJSON, simplifyVector = FALSE)
     length(cl) == 3L && identical(purrr::map_chr(parsed, "candidate"), c("A", "B", "C")) &&
       identical(parsed[[2]]$items[[1]]$stem, "Stem number 1 (B)?") &&
       length(parsed[[1]]$items[[2]]$options) == 3L &&
       identical(sort(names(parsed[[1]]$items[[1]])), c("domain", "id", "open_format", "options", "stem")) &&
       !inn(ap$user, "Filter 1?") && !inn(ap$user, "Randomize options.") && !inn(ap$user, "closed; three labelled options")
   }))
ok("a worker's own notes never reach the appraisal",
   !inn(ap$user, "SECRET-NOTE") && !inn(ap$user, "model-x") && !inn(ap$user, "source_english") &&
     !inn(ap$user, "\"notes\""))
ok("the appraisal is deterministic and its hash follows the candidates",
   identical(ap, build_step_prompt(forms$attitudinal, "appraise", candidates = cands)) &&
     !identical(ap$hash, build_step_prompt(forms$attitudinal, "appraise",
                                           candidates = list(A = cand(" (A)"), B = cand(" (changed)")))$hash))
ok("the appraisal holds no Source text, comment or Check field",
   local({
     both = squash(paste(ap$system, ap$user))
     !any(purrr::map_lgl(squash(source_texts), function(s) inn(both, s))) &&
       !inn(both, "<!--") && !inn(both, "**Check:**") && !inn(both, "**Source:**")
   }))
ok("the appraisal stops for a review task, and for no candidate or an unnamed one",
   grepl("Only a drafting task", tryCatch(build_step_prompt(forms$evaluate, "appraise", candidates = cands),
                                         error = conditionMessage), fixed = TRUE) &&
     grepl("at least one candidate", tryCatch(build_step_prompt(forms$attitudinal, "appraise"),
                                              error = conditionMessage), fixed = TRUE) &&
     grepl("at least one candidate", tryCatch(build_step_prompt(forms$attitudinal, "appraise",
                                                                candidates = list(cand("x"))),
                                              error = conditionMessage), fixed = TRUE))


# ---- Phase 3b: reply schemas, coded defaults, and the flow engine on a fake ask --------

# Canned replies. utils::modifyList() ignores an unnamed list (options, parts,
#   decisions), so a field is replaced by name here, and NULL leaves it null.
with_field <- function(x, ...) {
  over = list(...)
  x[names(over)] = over
  x
}
# A draft item with every field the reflex file asks for.
good_item <- function(i, ...)
  with_field(
    list(id = paste0("Q", i), domain = paste("domain", i), intro = "",
         stem = paste0("How much do you trust institution ", i, "?"),
         options = list("None", "A little", "A lot"), open_format = "", parts = list(),
         programming = "", decisions = list("closed; three points, every point labelled"),
         source_english = "", notes = ""),
    ...)
draft_of <- function(n, ...)
  list(items = purrr::map(seq_len(n), good_item, ...), not_covered = list(), missing_from_brief = list())
problem_of <- function(validate, obj) tryCatch({ validate(obj); NA_character_ }, error = conditionMessage)
says_in <- function(msg, s) !is.na(msg) && grepl(s, msg, fixed = TRUE)

vd <- reply_validator("draft", n_items = 2L)
ok("a draft with the number of items asked for, each closed or open, passes",
   is.na(problem_of(vd, draft_of(2))) &&
     is.na(problem_of(vd, list(items = list(good_item(1), good_item(2, options = NULL, open_format = "a number of days"))))))
ok("a draft with too many or too few items fails, saying how many and how many were asked for",
   says_in(problem_of(vd, draft_of(3)), "holds 3 items; 2 were asked for") &&
     says_in(problem_of(vd, draft_of(1)), "holds 1 item; 2 were asked for") &&
     says_in(problem_of(reply_validator("draft", n_items = 1L), draft_of(2)), "1 was asked for"))
ok("fields a draft is no longer asked for (parts, programming, decisions, notes) are ignored, not refused",
   is.na(problem_of(vd, list(items = list(
     good_item(1, parts = list(list(when = "before the item", stem = "Do you know it?", options = list("Yes", "No")))),
     good_item(2))))))
ok("a reply with no items field, or an item with no stem, id or domain, fails naming the field",
   says_in(problem_of(vd, list(not_covered = list())), "'items' is missing") &&
     says_in(problem_of(vd, list(items = list(good_item(1, stem = NULL), good_item(2)))), "items 1: 'stem' is missing") &&
     says_in(problem_of(vd, list(items = list(good_item(1), good_item(2, id = "")))), "items 2: 'id' must be a non-empty string") &&
     says_in(problem_of(vd, list(items = list(good_item(1, domain = NULL), good_item(2)))), "'domain' is missing"))
ok("an item with neither options nor an open_format fails, naming the item",
   says_in(problem_of(vd, list(items = list(good_item(1, options = list()), good_item(2)))),
           "Item Q1 has neither options nor an open_format"))
ok("a reply that is not an object, or whose items are not a list, fails",
   says_in(problem_of(vd, "just text"), "not a JSON object") &&
     says_in(problem_of(vd, list(items = "three")), "'items' must be a list"))
ok("the draft validator is what llm_json() is given: a fields problem is a readable sentence ending in a full stop",
   grepl("^The reply is not what was asked for: .*\\.$", problem_of(vd, list(items = "x"))))

brief_ok <- list(complete = FALSE, questions = list(list(ask = "Which country?", why = "Wording.", blocking = TRUE)),
                 task_fit = "", criteria = list("One thing per question."))
vb <- reply_validator("brief")
ok("a brief check with its fields passes; one with a string for complete, or a question with no ask, fails",
   is.na(problem_of(vb, brief_ok)) &&
     is.na(problem_of(vb, with_field(brief_ok, questions = list(), complete = TRUE))) &&
     says_in(problem_of(vb, with_field(brief_ok, complete = "yes")), "'complete' must be true or false") &&
     says_in(problem_of(vb, with_field(brief_ok, questions = list(list(why = "x", blocking = TRUE)))),
             "questions 1: 'ask' is missing") &&
     says_in(problem_of(vb, list(complete = TRUE)), "'criteria' is missing"))

appraisal_ok <- list(selected = list(list(domain = "d", candidate = "A", id = "Q1", check_before_use = "")))
sel1 <- function(...) with_field(appraisal_ok$selected[[1]], ...)
sel_with <- function(...) with_field(appraisal_ok, selected = list(sel1(...)))
va <- reply_validator("appraisal")
ok("a recommendation with its one field passes, a line to check before use or not; a missing selected fails; fields it is no longer asked for are ignored",
   is.na(problem_of(va, appraisal_ok)) &&
     is.na(problem_of(va, sel_with(check_before_use = "The term is vague."))) &&
     is.na(problem_of(va, list(selected = list(list(domain = "d", candidate = "A", id = "Q1"))))) &&
     is.na(problem_of(va, with_field(appraisal_ok, not_covered = list("x"), set_notes = list(), test_first = list(), limits = "y"))) &&
     says_in(problem_of(va, appraisal_ok[names(appraisal_ok) != "selected"]), "'selected' is missing"))
ok("a recommended item gives its domain, candidate and id; its line to check before use is a string",
   says_in(problem_of(va, with_field(appraisal_ok, selected = list(with_field(sel1(), domain = NULL)))), "selected 1: 'domain' is missing") &&
     says_in(problem_of(va, with_field(appraisal_ok, selected = list(with_field(sel1(), id = NULL)))), "selected 1: 'id' is missing") &&
     says_in(problem_of(va, sel_with(check_before_use = 5)), "'check_before_use' must be a string"))
vc_cands <- list(A = list(items = list(list(id = "Q1"), list(id = "Q2"))), B = list(items = list(list(id = "Q1"))))
vc <- reply_validator("appraisal", candidates = vc_cands, n_items = 2L)
pick <- function(...) purrr::map(list(...), function(x) sel1(candidate = x[[1]], id = x[[2]]))
ok("R refuses a recommendation that names an id no candidate has, names an item twice, or has more items than were asked for; two candidates may share an id; an id may be a number",
   is.na(problem_of(vc, with_field(appraisal_ok, selected = pick(c("A", "Q1"), c("B", "Q1"))))) &&
     says_in(problem_of(vc, with_field(appraisal_ok, selected = pick(c("A", "Q9")))), "item Q9 of candidate A, which is not among the drafts") &&
     says_in(problem_of(vc, with_field(appraisal_ok, selected = pick(c("C", "Q1")))), "item Q1 of candidate C") &&
     says_in(problem_of(vc, with_field(appraisal_ok, selected = pick(c("A", "Q1"), c("A", "Q1")))),
             "the same item more than once: item Q1 of candidate A") &&
     says_in(problem_of(vc, with_field(appraisal_ok, selected = pick(c("A", "Q1"), c("A", "Q2"), c("B", "Q1")))),
             "recommends 3 items; 2 were asked for") &&
     is.na(problem_of(reply_validator("appraisal", candidates = list(A = list(items = list(list(id = "1")))), n_items = 1L),
                      with_field(appraisal_ok, selected = list(sel1(id = 1))))))
ok("a format that has no schema stops, naming it",
   says_in(tryCatch(reply_validator("poem"), error = conditionMessage), "no reply schema called 'poem'"))
REPLY_SCHEMAS$tiny <- list(fields = c(answer = "text"), each = list(), rules = character(0))
ok("a new output format is one entry: the validator is built from REPLY_SCHEMAS alone",
   is.na(problem_of(reply_validator("tiny"), list(answer = "x"))) &&
     says_in(problem_of(reply_validator("tiny"), list(answer = "")), "'answer' must be a non-empty string"))
REPLY_SCHEMAS$tiny <- NULL


# Checks on the reviewer's recommendation.
ck_cands <- list(A = draft_of(2), B = draft_of(1))
ck_reply <- list(
  selected = list(
    list(domain = "d1", candidate = "A", id = "Q2", check_before_use = "The term trust is vague. Say whose trust you mean, and in what."),
    list(domain = "d2", candidate = "B", id = "Q1", check_before_use = "")),
  not_covered = list("domain 9"), set_notes = list(list(check = "keying", severity = 6, why = "All keyed one way.")),
  test_first = list(), limits = "x")
ca <- check_appraisal(ck_reply, ck_cands)
ok("each recommended item is found in its draft by letter and id, in the order given, with its position, domain and line to check; nothing else of the reply is read",
   length(ca$selected) == 2L && identical(purrr::map_chr(ca$selected, "candidate"), c("A", "B")) &&
     identical(purrr::map_chr(ca$selected, "id"), c("Q2", "Q1")) && identical(purrr::map_int(ca$selected, "position"), c(2L, 1L)) &&
     identical(ca$selected[[1]]$domain, "d1") && identical(names(ca), "selected") &&
     identical(sort(names(ca$selected[[1]])), c("candidate", "check", "domain", "id", "position")))
ok("the line to check before use is held to one sentence of 20 words or fewer, and is empty when the reviewer gave none",
   identical(ca$selected[[1]]$check, "The term trust is vague.") && identical(ca$selected[[2]]$check, "") &&
     identical(check_appraisal(list(selected = list(list(domain = "d", candidate = "A", id = "Q1",
                                                          check_before_use = "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty twenty-one twenty-two"))),
                               ck_cands)$selected[[1]]$check,
               paste0("one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty", "…")))
ok("an item that cannot be found in its draft is left out, not guessed at; a reply with nothing recommended has none",
   length(check_appraisal(list(selected = list(list(domain = "d", candidate = "A", id = "Q9"),
                                               list(domain = "d", candidate = "C", id = "Q1"))), ck_cands)$selected) == 0L &&
     !length(check_appraisal(list(selected = list()), ck_cands)$selected))
# The flow engine on a fake ask. The fake has exactly the five arguments the seam
#   names, so a flow that passed it anything else (a key, say) would fail here.
fl_form <- make_form(task = "attitudinal", n_items = 2L, modes = "web", population = "Adults",
                     research_question = "How much do adults trust the electoral commission?",
                     construct = "Trust in the electoral commission")
fl_models <- function(ids) purrr::map(ids, function(id)
  list(api = "openai", base_url = "https://example.invalid/v1", id = id, key_source = "analyst"))
fl_workers <- fl_models(c("vendor-a/model-one", "vendor-b/model-two", "vendor-c/model-three"))
fl_pm <- fl_models("vendor-p/pm-model")[[1]]
fl_ids <- purrr::map_chr(fl_workers, "id")
worker_no <- function(m) match(m$id, fl_ids)

# reply_for(m, system_prompt) decides what each model says; the fake then validates
#   it the way llm_json() would, so a bad reply is an error.
rec_ask <- function(reply_for) {
  st = new.env()
  st$calls = list()
  list(st = st, ask = function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    st$calls[[length(st$calls) + 1L]] = list(id = m$id, user = user, system = system_prompt, max_tokens = max_tokens)
    obj = reply_for(m, system_prompt)
    if (!is.null(validate)) validate(obj)
    obj
  })
}
is_brief <- function(system_prompt) grepl("- what_a_brief_needs (", system_prompt, fixed = TRUE)
tagged_draft <- function(m, n = 2L) draft_of(n, stem = paste0("Question from worker ", worker_no(m), "?"))
reply_ok <- function(m, sys) {
  if (identical(m$id, fl_pm$id)) { if (is_brief(sys)) brief_ok else appraisal_ok }
  else tagged_draft(m)
}

fa <- rec_ask(reply_ok)
fl_brief <- run_brief(fl_form, fl_pm, ask = fa$ask)
fl_drafts <- run_drafts(fl_form, fl_workers, ask = fa$ask)
fl_ap <- run_appraisal(fl_form, fl_drafts, fl_pm, ask = fa$ask, seed = 11L)

ok("each result has exactly the fields the design names",
   identical(sort(names(fl_brief)), sort(c("status", "error", "system", "user", "hash", "reply"))) &&
     identical(sort(names(fl_ap)), sort(c("status", "error", "labels", "system", "user", "hash", "reply"))) &&
     purrr::every(fl_drafts, function(d) identical(sort(names(d)), sort(c("model", "status", "error", "reply", "seconds")))) &&
     is.null(names(fl_drafts)) && length(fl_drafts) == 3L)
ok("the flow makes one brief call, one call per worker in the workers' order, and one appraisal call",
   identical(purrr::map_chr(fa$st$calls, "id"), c(fl_pm$id, fl_ids, fl_pm$id)))
ok("each call gets its step's ceiling, and the brief and appraisal hold no worker's name",
   identical(purrr::map_int(fa$st$calls, "max_tokens"),
             unname(LLM_MAX_TOKENS[c("brief", "draft", "draft", "draft", "appraisal")])))
ok("every worker gets the same approved prompt, which is the list's 'prompt' attribute",
   local({
     pr = attr(fl_drafts, "prompt")
     identical(pr, build_prompt(fl_form)) &&
       identical(unique(purrr::map_chr(fa$st$calls[2:4], "user")), pr$user) &&
       identical(unique(purrr::map_chr(fa$st$calls[2:4], "system")), pr$system)
   }))
ok("the brief check's prompt is the brief step's, and its reply is kept",
   identical(fl_brief$status, "ok") && is.na(fl_brief$error) &&
     identical(fl_brief$hash, build_step_prompt(fl_form, "brief")$hash) && identical(fl_brief$reply, brief_ok))
ok("an ok draft keeps its parsed reply and a time; the model is the id the endpoint is called by",
   identical(fl_drafts[[2]]$reply, tagged_draft(fl_workers[[2]])) && is.na(fl_drafts[[2]]$error) &&
     identical(fl_drafts[[2]]$model, "vendor-b/model-two") &&
     is.numeric(fl_drafts[[2]]$seconds) && fl_drafts[[2]]$seconds >= 0)

ok("the labels are A, B, C over the three models, the same for the same seed, and not the workers' order for every seed",
   identical(names(fl_ap$labels), c("A", "B", "C")) && setequal(fl_ap$labels, fl_ids) &&
     identical(fl_ap$labels, labels_of(fl_drafts, 11L)) &&
     length(unique(purrr::map_chr(1:40, function(s) paste(labels_of(fl_drafts, s), collapse = ",")))) > 1L &&
     purrr::every(1:40, function(s) setequal(labels_of(fl_drafts, s), fl_ids)))
ok("candidate A is the draft of the model labelled A, whatever the seed",
   purrr::every(c(1L, 7L, 11L, 23L), function(s) {
     lab = labels_of(fl_drafts, s)
     cd = candidates_of(fl_drafts, s)
     identical(names(cd), names(lab)) &&
       identical(cd$A$items[[1]]$stem, paste0("Question from worker ", match(lab[["A"]], fl_ids), "?")) &&
       identical(cd$C$items[[1]]$stem, paste0("Question from worker ", match(lab[["C"]], fl_ids), "?"))
   }))
ok("shuffling by seed leaves the random number generator alone",
   local({
     set.seed(5); a = stats::runif(1)
     set.seed(5); invisible(labels_of(fl_drafts, 99L)); b = stats::runif(1)
     identical(a, b)
   }))
ok("the appraisal prompt shows each letter with the draft of the model that letter stands for, and no model name anywhere",
   local({
     ap_call = fa$st$calls[[5]]
     both = paste(ap_call$system, ap_call$user)
     lab = labels_of(fl_drafts, 11L)
     lines = strsplit(ap_call$user, "\n", fixed = TRUE)[[1]]
     cl = lines[grepl("^\\{\"candidate\":", lines)]
     line_for = function(letter) cl[startsWith(cl, paste0("{\"candidate\":\"", letter, "\""))]
     identical(ap_call$user, fl_ap$user) && length(cl) == 3L &&
       all(purrr::map_lgl(names(lab), function(L)
         grepl(paste0("Question from worker ", match(lab[[L]], fl_ids), "?"), line_for(L), fixed = TRUE))) &&
       !any(purrr::map_lgl(c(fl_ids, fl_pm$id, "vendor-", "example.invalid", "model-one"), function(s) grepl(s, both, fixed = TRUE)))
   }))
ok("the appraisal's status, hash and reply are kept, and its error is empty",
   identical(fl_ap$status, "ok") && is.na(fl_ap$error) && identical(fl_ap$reply, appraisal_ok) &&
     grepl("^[0-9a-f]{64}$", fl_ap$hash))

# A worker that fails, a wrong number of items, and the run goes on.
fb <- rec_ask(function(m, sys) {
  if (identical(m$id, "vendor-b/model-two")) stop("canned endpoint error", call. = FALSE)
  if (identical(m$id, "vendor-c/model-three")) return(tagged_draft(m, 3L))
  reply_ok(m, sys)
})
fl_bad <- run_drafts(fl_form, fl_workers, ask = fb$ask)
ok("a worker that errors, and one that returns the wrong number of items, are failed with their reasons; the first still arrives",
   identical(purrr::map_chr(fl_bad, "status"), c("ok", "failed", "failed")) &&
     identical(fl_bad[[2]]$error, "canned endpoint error") &&
     grepl("holds 3 items; 2 were asked for", fl_bad[[3]]$error, fixed = TRUE) &&
     is.null(fl_bad[[2]]$reply) && is.null(fl_bad[[3]]$reply) && !is.null(fl_bad[[1]]$reply) &&
     length(fb$st$calls) == 3L)
fl_bad_ap <- run_appraisal(fl_form, fl_bad, fl_pm, ask = fb$ask, seed = 11L)
ok("the appraisal covers only the drafts that arrived: one candidate, A, over the one model that answered",
   identical(fl_bad_ap$status, "ok") && identical(names(fl_bad_ap$labels), "A") &&
     identical(unname(fl_bad_ap$labels), "vendor-a/model-one") &&
     grepl("Appraise the 1 candidate draft ", fl_bad_ap$user, fixed = TRUE))

# A failed appraisal is reported, with the labels kept so the candidates can still be read.
fc <- rec_ask(function(m, sys) if (identical(m$id, fl_pm$id)) stop("the appraiser is down", call. = FALSE) else reply_ok(m, sys))
fl_dead <- run_appraisal(fl_form, fl_drafts, fl_pm, ask = fc$ask, seed = 11L)
ok("a failed appraisal is recorded with its reason and the labels, and nothing is raised",
   identical(fl_dead$status, "failed") && identical(fl_dead$error, "the appraiser is down") &&
     identical(fl_dead$labels, fl_ap$labels) && is.null(fl_dead$reply) && grepl("^[0-9a-f]{64}$", fl_dead$hash))
fd <- rec_ask(reply_ok)
fl_none <- run_appraisal(fl_form, run_drafts(fl_form, fl_workers, ask = rec_ask(function(m, sys) stop("down", call. = FALSE))$ask),
                         fl_pm, ask = fd$ask, seed = 11L)
ok("with no draft there is nothing to appraise, and the project manager is not called",
   identical(fl_none$status, "failed") && grepl("No draft arrived", fl_none$error, fixed = TRUE) &&
     length(fl_none$labels) == 0L && length(fd$st$calls) == 0L)
fe <- rec_ask(reply_ok)
fl_brief_dead <- run_brief(fl_form, fl_pm, ask = rec_ask(function(m, sys) stop("brief endpoint down", call. = FALSE))$ask)
fl_brief_bad <- run_brief(utils::modifyList(fl_form, list(research_question = "")), fl_pm, ask = fe$ask)
ok("a brief check that errors, or whose form cannot become a prompt, is failed with a plain reason and is not raised",
   identical(fl_brief_dead$status, "failed") && identical(fl_brief_dead$error, "brief endpoint down") &&
     identical(fl_brief_bad$status, "failed") && grepl("research question is required", fl_brief_bad$error, fixed = TRUE) &&
     length(fe$st$calls) == 0L)
ok("a reply the brief validator refuses is a failed brief check",
   identical(run_brief(fl_form, fl_pm, ask = rec_ask(function(m, sys) list(complete = TRUE))$ask)$status, "failed"))

# The appraisal stays blind: a draft that names its own model is not sent on.
fg <- rec_ask(function(m, sys) {
  if (identical(m$id, fl_pm$id)) return(reply_ok(m, sys))
  if (identical(m$id, "vendor-a/model-one"))
    return(draft_of(2, stem = "As model-one I ask: how much do you trust institution 1?"))
  tagged_draft(m)
})
fl_leaky <- run_drafts(fl_form, fl_workers, ask = fg$ask)
before_calls <- length(fg$st$calls)
fl_leak_ap <- run_appraisal(fl_form, fl_leaky, fl_pm, ask = fg$ask, seed = 11L)
ok("a model's name in a draft stops the appraisal before it is sent, saying why, and the call is not made",
   identical(fl_leak_ap$status, "failed") && grepl("model-one", fl_leak_ap$error, fixed = TRUE) &&
     grepl("was not sent", fl_leak_ap$error, fixed = TRUE) && length(fg$st$calls) == before_calls)

# What the analyst edited is what the workers get.
edited <- with_field(build_prompt(fl_form), user = "EDITED PROMPT TEXT", edited = TRUE)
fh <- rec_ask(reply_ok)
fl_ed <- run_drafts(fl_form, fl_workers, ask = fh$ask, prompt = edited)
ok("an edited prompt is the one sent to every worker, and is kept as the list's attribute",
   identical(unique(purrr::map_chr(fh$st$calls, "user")), "EDITED PROMPT TEXT") &&
     identical(attr(fl_ed, "prompt")$edited, TRUE) && identical(attr(fl_ed, "prompt")$hash, build_prompt(fl_form)$hash))
ok("run_drafts needs a task that drafts, a prompt that is a prompt, and run_appraisal a seed",
   grepl("Only a drafting task", tryCatch(run_drafts(forms$evaluate, fl_workers, ask = fh$ask, prompt = edited), error = conditionMessage), fixed = TRUE) &&
     grepl("system and a user", tryCatch(run_drafts(fl_form, fl_workers, ask = fh$ask, prompt = list(user = "x")), error = conditionMessage), fixed = TRUE) &&
     grepl("needs a seed", tryCatch(run_appraisal(fl_form, fl_drafts, fl_pm, ask = fh$ask), error = conditionMessage), fixed = TRUE))
ok("the engine reaches a model only through ask, and never looks up a key: no flow function calls Sys.getenv or llm_key_for",
   !any(c("Sys.getenv", "llm_key_for", "llm_session_key", "llm_json", "llm_complete") %in%
          all.names(c(body(run_brief), body(run_drafts), body(run_appraisal), body(call_model)))))

# Through the real llm_json(), with the network stood in for: the validator retries
#   a draft with the wrong count, and the log keeps the call's cost and no key.
rj_state <- new.env()
rj_state$n = 0L
rj_state$wrong_once = FALSE
rj_complete <- function(m, system_prompt, user, max_tokens, key, timeout = NULL) {
  rj_state$n = rj_state$n + 1L
  obj = if (identical(m$id, "vendor-b/model-two") && !rj_state$wrong_once) {
    rj_state$wrong_once = TRUE
    tagged_draft(m, 3L)
  } else reply_ok(m, system_prompt)
  structure(as.character(jsonlite::toJSON(obj, auto_unbox = TRUE)), provider = "example.invalid",
            finish = "success", tokens = c(input = 100, output = 50, cached_input = 0), seconds = 0.01)
}
rj_ask <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
  llm_json(user, m, system_prompt = system_prompt, max_tokens = max_tokens, validate = validate,
           key = "SECRET-KEY-XYZ", complete = rj_complete, pause_base = 0.01, pause_min = 0.01)
llm_clear_counters(llm_session_id())
rj_brief <- run_brief(fl_form, fl_pm, ask = rj_ask)
rj_drafts <- run_drafts(fl_form, fl_workers, ask = rj_ask)
rj_ap <- run_appraisal(fl_form, rj_drafts, fl_pm, ask = rj_ask, seed = 11L)
ok("through llm_json(): a draft with the wrong number of items is retried until it is right, and the whole flow is ok",
   identical(purrr::map_chr(rj_drafts, "status"), c("ok", "ok", "ok")) &&
     identical(rj_brief$status, "ok") && identical(rj_ap$status, "ok") &&
     attr(rj_drafts[[2]], "call")$attempts == 2L && rj_state$n == 6L)
ok("the call record keeps the reply as sent, why it stopped, the tokens and the attempts",
   local({
     cl = attr(rj_drafts[[1]], "call")
     identical(cl$finish, "success") && identical(cl$tokens$input, 100) && identical(cl$tokens$output, 50) &&
       cl$attempts == 1L && grepl("\"items\"", cl$raw, fixed = TRUE) && is.numeric(cl$seconds)
   }))
rj_round <- flow_round(fl_form, fl_pm, rj_brief, rj_drafts, rj_ap, seed = 11L)
rj_json <- as.character(flow_log_json(rj_round))
rj_back <- jsonlite::fromJSON(rj_json, simplifyVector = FALSE)
ok("the round is the log: schema 1, the time and a summary first, then the form, seed, prompts and replies, as valid JSON",
   identical(names(rj_back)[1:3], c("schema", "time", "summary")) && identical(rj_back$schema, 1L) &&
     length(rj_back$summary) == 5L && identical(rj_back$seed, 11L) &&
     identical(rj_back$form$research_question, fl_form$research_question) &&
     identical(rj_back$prompt$hash, build_prompt(fl_form)$hash) && length(rj_back$drafts) == 3L &&
     identical(rj_back$appraisal$labels, as.list(fl_ap$labels)) && identical(rj_back$appraisal$hash, rj_ap$hash))
ok("the summary has one row per call with the step, model, status, seconds, tokens and attempts",
   identical(purrr::map_chr(rj_back$summary, "step"), c("brief check", "draft", "draft", "draft", "appraisal")) &&
     identical(purrr::map_chr(rj_back$summary, "model"), c(fl_pm$id, fl_ids, fl_pm$id)) &&
     identical(purrr::map_dbl(rj_back$summary, "tokens_in"), rep(100, 5L)) &&
     identical(purrr::map_int(rj_back$summary, "attempts"), c(1L, 1L, 2L, 1L, 1L)))
ok("no key is in the log, though the call that made it was given one",
   !grepl("SECRET-KEY-XYZ", rj_json, fixed = TRUE) && !any(grepl("key", names(rj_back$form), fixed = TRUE)) &&
     !any(Sys.getenv() == "SECRET-KEY-XYZ"))
ok("a round with only the form is a valid log too",
   identical(jsonlite::fromJSON(as.character(flow_log_json(flow_round(fl_form))), simplifyVector = FALSE)$schema, 1L))


# ---- Phase 3c: the screens, each module driven with a fake ask ---------------------------

html_of3 <- function(x) paste(as.character(x$html), collapse = "")
n_in3 <- function(pattern, txt) lengths(regmatches(txt, gregexpr(pattern, txt, fixed = TRUE)))
test_state <- function() do.call(shiny::reactiveValues, STATE_DEFAULTS)
nav_rec <- function() {
  e = new.env()
  e$tabs = character(0)
  list(env = e, go = function(tab) e$tabs = c(e$tabs, tab))
}
worker_ids <- purrr::map_chr(APP_MODELS$workers, "id")
brief_inputs <- list(task = "attitudinal", research_question = "How much do adults trust the electoral commission?",
                     construct = "Trust in the commission", population = "Adults", modes = "web",
                     n_items = 2,
                     workers = worker_ids)
set_inputs <- function(session, base, ...) do.call(session$setInputs, utils::modifyList(base, list(...)))

ok("the state object is made from STATE_DEFAULTS, and every field a module uses is in it",
   identical(sort(names(STATE_DEFAULTS)),
             sort(c("key_version", "form", "workers", "brief", "approved", "run_id", "round",
                    "drafts", "appraisal", "review", "seed", "set", "edits", "revision", "rounds"))))
ok("every field any task lists has a widget spec, so a new task that reuses fields needs no screen change",
   all(unlist(purrr::map(TASKS, "fields")) %in% names(FIELD_SPECS)))
ok("the registry's progress_ask announces the model on the page before it makes each call",
   local({
     nm = all.names(body(progress_ask))
     match("setProgress", nm) < match("llm_json", nm)
   }))


# Tab 1, Brief.
local({
  nav = nav_rec()
  fa = rec_ask(function(m, sys) brief_ok)
  st = test_state()
  shiny::testServer(mod_brief_server,
                    args = list(state = st, go = nav$go, make_ask = function(total) fa$ask), {
    set_inputs(session, brief_inputs, build = 1)
    ok("Build the instructions carries the cleaned form and the ticked workers on, marks the brief unchecked, and moves to the prompt",
       identical(st$form$task, "attitudinal") && identical(st$form$n_items, 2L) &&
         identical(st$form$modes, "web") && length(st$workers) == length(worker_ids) &&
         identical(st$brief$status, "skipped") && identical(nav$env$tabs, QUESTIONR_TABS[3]) &&
         length(fa$st$calls) == 0L)

    nav$env$tabs = character(0)
    st$form = NULL
    set_inputs(session, brief_inputs, research_question = "", build = 2)
    ok("a form that cannot be a prompt says why on the page, and goes nowhere",
       grepl("research question is required", html_of3(output$message), fixed = TRUE) &&
         is.null(st$form) && !length(nav$env$tabs))
    set_inputs(session, brief_inputs, workers = character(0), build = 3)
    ok("no worker ticked says so, and goes nowhere",
       grepl("Tick at least one worker", html_of3(output$message), fixed = TRUE) && is.null(st$form))
    set_inputs(session, brief_inputs, n_items = NA, build = 4)
    ok("no number of items says so, and goes nowhere",
       grepl("number of items", html_of3(output$message), fixed = TRUE) && is.null(st$form))

    set_inputs(session, brief_inputs, check = 1)
    ok("the brief check without the project manager's key says what to do and makes no call",
       grepl("needs the project manager", html_of3(output$message), fixed = TRUE) &&
         grepl("Paste a key", html_of3(output$message), fixed = TRUE) && length(fa$st$calls) == 0L)

    llm_set_session_key("pm-test-key")
    set_inputs(session, brief_inputs, check = 2)
    r = html_of3(output$result)
    ok("with a key the brief check makes one call to the project manager and shows its questions and criteria",
       length(fa$st$calls) == 1L && identical(fa$st$calls[[1]]$id, APP_MODELS$pm$id) &&
         identical(st$brief$status, "ok") && grepl("Blocking: ", r, fixed = TRUE) &&
         grepl("Which country?", r, fixed = TRUE) && grepl("One thing per question.", r, fixed = TRUE) &&
         grepl("Continue to the prompt", r, fixed = TRUE) && grepl("found gaps that block", r, fixed = TRUE))
    ok("the brief check's prompt is the brief step's, and no key is on the page",
       identical(fa$st$calls[[1]]$max_tokens, LLM_MAX_TOKENS[["brief"]]) &&
         !grepl("pm-test-key", paste(r, html_of3(output$message)), fixed = TRUE))

    nav$env$tabs = character(0)
    set_inputs(session, brief_inputs, continue = 1)
    ok("Continue after a check keeps the check and moves to the prompt",
       identical(st$brief$status, "ok") && identical(nav$env$tabs, QUESTIONR_TABS[3]) && !is.null(st$form))
    llm_clear_session_key(session$token)
  })
})

local({
  dead = rec_ask(function(m, sys) stop("the project manager is down", call. = FALSE))
  st = test_state()
  shiny::testServer(mod_brief_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) dead$ask), {
    llm_set_session_key("pm-test-key")
    set_inputs(session, brief_inputs, check = 1)
    r = html_of3(output$result)
    ok("a brief check that fails is said on the page in words, with the reason, and offers to build the instructions without it",
       identical(st$brief$status, "failed") && grepl("did not come back", r, fixed = TRUE) &&
         grepl("the project manager is down", r, fixed = TRUE) && grepl("without it", r, fixed = TRUE))
    llm_clear_session_key(session$token)
  })
})

local({
  st = test_state()
  shiny::testServer(mod_brief_server, args = list(state = st, go = function(tab) NULL), {
    set_inputs(session, brief_inputs, questionnaire = "LEAKED QUESTIONNAIRE", reference_period = "LEAKED PERIOD",
               build = 1)
    ok("a field the chosen task does not show is blank in the form, whatever was typed there before",
       identical(st$form$questionnaire, "") && identical(st$form$reference_period, ""))
    set_inputs(session, brief_inputs, task = "behavioral", reference_period = "past 7 days", build = 2)
    ok("a field the task does show is carried (the reference period, for behavioral items)",
       identical(st$form$reference_period, "past 7 days") && identical(st$form$task, "behavioral"))
    set_inputs(session, brief_inputs, task = "evaluate", questionnaire = "Q1. How are you? Fine / Not fine",
               build = 3)
    ok("Evaluate carries its questionnaire, no item count and no workers, and says to leave a blank line between questions, how long one call is and what the limit is",
       identical(st$form$task, "evaluate") && grepl("Q1. How are you?", st$form$questionnaire, fixed = TRUE) &&
         is.na(st$form$n_items) && length(st$workers) == 0L &&
         grepl("Leave a blank line between questions", html_of3(output$task_note), fixed = TRUE) &&
         grepl("reviewed one call each", html_of3(output$task_note), fixed = TRUE) &&
         grepl(format(APP_BATCH_CHARS, big.mark = ","), html_of3(output$task_note), fixed = TRUE) &&
         grepl(format(APP_MAX_PASTE_CHARS, big.mark = ","), html_of3(output$task_note), fixed = TRUE) &&
         !grepl("Phase 4", html_of3(output$task_note), fixed = TRUE))
    set_inputs(session, brief_inputs, task = "evaluate", questionnaire = strrep("a", APP_MAX_PASTE_CHARS + 1L), build = 5)
    ok("a questionnaire over the cap is refused on the Brief tab with its length and the limit, and nothing moves on",
       grepl("Paste it in parts", html_of3(output$message), fixed = TRUE) && identical(st$form$task, "evaluate") &&
         nchar(st$form$questionnaire) < APP_MAX_PASTE_CHARS)
    set_inputs(session, brief_inputs, task = "evaluate", questionnaire = paste0("Q1. ", strrep("x", APP_BATCH_CHARS + 50L)), build = 6)
    ok("a single block too long for one call is refused on the Brief tab, quoting where it starts, and nothing moves on",
       grepl("Block 1 of the questionnaire", html_of3(output$message), fixed = TRUE) &&
         grepl("Leave a blank line between questions", html_of3(output$message), fixed = TRUE) &&
         grepl("It starts: ", html_of3(output$message), fixed = TRUE) && nchar(st$form$questionnaire) < APP_BATCH_CHARS)
    st$revision = "Make the stems shorter."
    session$flushReact()
    ok("a requested change is shown on the Brief tab with the round it belongs to, and can be dropped",
       grepl("REVISION", html_of3(output$revision_note), fixed = TRUE) &&
         grepl("Make the stems shorter.", html_of3(output$revision_note), fixed = TRUE) &&
         grepl("Round 1", html_of3(output$revision_note), fixed = TRUE))
    set_inputs(session, brief_inputs, build = 4)
    ok("the change goes into the form as its revision, and so into the prompt as a REVISION block",
       identical(st$form$revision, "Make the stems shorter.") &&
         grepl("\nREVISION: Make the stems shorter.", build_prompt(st$form)$user, fixed = TRUE))
    session$setInputs(drop_revision = 1)
    ok("dropping the change clears it", identical(st$revision, ""))
  })
})

# The form is the registry's, not the screen's.
brief_page <- paste(as.character(mod_brief_ui("brief")), collapse = "")
ok("the Brief tab has the dropdown, the form, a box per worker, one main button, Build the instructions, and a smaller Check my brief first (the brief check is off by default)",
   n_in3("brief-task", brief_page) >= 1L && grepl("Check my brief first", brief_page, fixed = TRUE) &&
     grepl("Build the instructions", brief_page, fixed = TRUE) && !grepl("Skip the brief check", brief_page, fixed = TRUE) &&
     regexpr("Build the instructions", brief_page, fixed = TRUE) < regexpr("Check my brief first", brief_page, fixed = TRUE) &&
     grepl("btn-primary\"[^>]*>(<span[^>]*>)?Build the instructions", brief_page) &&
     grepl("btn-sm[^>]*>(<span[^>]*>)?Check my brief first", brief_page) &&
     all(purrr::map_lgl(worker_ids, function(id) grepl(id, brief_page, fixed = TRUE))) &&
     all(purrr::map_lgl(purrr::map_chr(TASKS, "label"), function(l) grepl(l, brief_page, fixed = TRUE))))
ok("each field is shown for exactly the tasks that list it, and the worker boxes for the drafting tasks",
   identical(tasks_condition(c("attitudinal", "behavioral")), "[\"attitudinal\",\"behavioral\"].indexOf(input.task) >= 0") &&
     n_in3("data-display-if", brief_page) == length(intersect(FORM_FIELDS, names(FIELD_SPECS))) + 1L &&
     grepl("indexOf(input.task)", brief_page, fixed = TRUE))

# A new task is a registry entry; a new worker is a model entry. Neither touches a screen.
TASKS$knowledge <- utils::modifyList(TASKS$attitudinal, list(label = "Knowledge items"))
APP_MODELS$workers <- c(APP_MODELS$workers, list(list(api = "openai", base_url = "https://example.invalid/v1",
                                                      id = "vendor-z/extra-worker", key_source = "analyst")))
extended <- paste(as.character(mod_brief_ui("brief")), collapse = "")
ok("a task added to TASKS is in the dropdown, its fields are shown for it, and it assembles a prompt",
   grepl("Knowledge items", extended, fixed = TRUE) && grepl("knowledge", extended, fixed = TRUE) &&
     "knowledge" %in% task_choices() &&
     startsWith(build_prompt(utils::modifyList(forms$attitudinal, list(task = "knowledge")))$user, rfiles[["core.md"]]$persona) &&
     length(build_step_prompt(utils::modifyList(forms$attitudinal, list(task = "knowledge")), "brief")$files) == 5L)
ok("a worker added to the model list gets its own box, and nothing else changes",
   grepl("vendor-z/extra-worker", extended, fixed = TRUE) && !grepl("vendor-z/extra-worker", brief_page, fixed = TRUE))
TASKS$knowledge <- NULL
APP_MODELS$workers <- APP_MODELS$workers[-length(APP_MODELS$workers)]
ok("the registry and the model list are back as they were",
   !"knowledge" %in% names(TASKS) && length(APP_MODELS$workers) == length(worker_ids))


# Tab 2, Prompt.
flow_state <- function(form = fl_form, workers = fl_workers) {
  st = test_state()
  st$form = clean_form(form)
  st$workers = workers
  st
}
local({
  nav = nav_rec()
  st = test_state()
  shiny::testServer(mod_prompt_server, args = list(state = st, go = nav$go), {
    ok("with no form the Prompt tab asks for the Brief first",
       grepl("Fill in the Brief tab", html_of3(output$body), fixed = TRUE))
    st$form = clean_form(fl_form)
    st$workers = fl_workers
    session$flushReact()
    a = build_prompt(st$form)
    b = html_of3(output$body)
    ok("the assembled prompt is shown whole and editable, with the reflex files used",
       grepl("senior survey methodologist", b, fixed = TRUE) && grepl("Write exactly 2 survey items", b, fixed = TRUE) &&
         grepl("textarea", b, fixed = TRUE) && grepl("core.md, generate.md", b, fixed = TRUE) &&
         grepl("Approve and run", b, fixed = TRUE) && !grepl("disabled", b, fixed = TRUE) &&
         grepl("3 workers", b, fixed = TRUE) && grepl("4 model calls", b, fixed = TRUE))
    ok("the Prompt tab shows one box, labelled as editable, and one line saying the rules are sent and cannot be edited here",
       lengths(regmatches(b, gregexpr("<textarea", b, fixed = TRUE))) == 1L &&
         grepl("The prompt (you can edit this)", b, fixed = TRUE) &&
         grepl("The survey design rules are sent with this prompt every time and cannot be edited here. You can read them on the Methodology tab.",
               gsub("\\s+", " ", b), fixed = TRUE))
    reflex_says <- unlist(purrr::map(rfiles[["core.md"]]$reflexes, function(r) c(r$say, r$never)), use.names = FALSE)
    ok("the Prompt tab has no \"System prompt\", none of core.md's Reflexes or Prohibitions, and no input named system",
       !grepl("System prompt", paste(b, html_of3(output$status)), ignore.case = TRUE) &&
         !any(purrr::map_lgl(c(reflex_says[!is.na(reflex_says)], rfiles[["core.md"]]$prohibitions), function(s)
           grepl(squash(s), squash(paste(b, html_of3(output$status))), fixed = TRUE))) &&
         !grepl("REFLEXES:", b, fixed = TRUE) && !grepl("PROHIBITIONS", b, fixed = TRUE) &&
         !grepl("id=\"[^\"]*-system\"", b))

    session$setInputs(user = a$message)
    ok("an untouched prompt is shown as assembled, with its hash",
       grepl("As assembled", html_of3(output$status), fixed = TRUE) &&
         grepl(substr(a$hash, 1, 16), html_of3(output$status), fixed = TRUE))
    session$setInputs(approve = 1)
    ok("approving it as it is records it unedited, with one hash, starts a run and moves to Results",
       identical(st$approved$edited, FALSE) && identical(st$approved$hash, a$hash) &&
         identical(st$approved$original_hash, a$hash) && identical(st$approved$user, a$user) &&
         identical(st$approved$system, a$system) && st$run_id == 1L && identical(nav$env$tabs, QUESTIONR_TABS[4]))

    ed_msg = paste0(a$message, "\nPlease keep every stem under 15 words.")
    ed_user = sent_user(ed_msg, a$tail)
    session$setInputs(user = ed_msg)
    s = html_of3(output$status)
    ok("an edited prompt is marked edited, showing both hashes",
       grepl("Edited", s, fixed = TRUE) && grepl(substr(a$hash, 1, 16), s, fixed = TRUE) &&
         grepl(substr(prompt_hash(a$system, ed_user), 1, 16), s, fixed = TRUE))
    session$setInputs(approve = 2)
    ok("approving an edited prompt sends the edited text, marks it edited, and keeps both hashes",
       identical(st$approved$edited, TRUE) && identical(st$approved$user, ed_user) &&
         identical(st$approved$hash, prompt_hash(a$system, ed_user)) && identical(st$approved$original_hash, a$hash) &&
         st$run_id == 2L)
    session$setInputs(user = gsub("\n", "\r\n", a$message, fixed = TRUE),
                      approve = 3)
    ok("a browser's line endings are not an edit",
       identical(st$approved$edited, FALSE) && identical(st$approved$hash, a$hash))
    session$setInputs(user = "   ", approve = 4)
    ok("an empty prompt is refused on the page, and no run starts",
       grepl("prompt is empty", html_of3(output$message), fixed = TRUE) && st$run_id == 3L)
  })
})
local({
  st = test_state()
  shiny::testServer(mod_prompt_server, args = list(state = st, go = function(tab) NULL), {
    st$form = clean_form(forms$evaluate)
    session$flushReact()
    b = html_of3(output$body)
    ok("Evaluate's prompt can be read and approved: the button is on and the page says it makes one call",
       !grepl("disabled", b, fixed = TRUE) && grepl("Questionnaire:", b, fixed = TRUE) &&
         grepl("one model call", b, fixed = TRUE) && !grepl("Phase 4", b, fixed = TRUE))
    ok("Evaluate's Prompt tab also shows one box, no rules, no checklist and no reply format, and the same line about the rules",
       lengths(regmatches(b, gregexpr("<textarea", b, fixed = TRUE))) == 1L &&
         grepl("The prompt (you can edit this)", b, fixed = TRUE) && !grepl("System prompt", b, ignore.case = TRUE) &&
         !grepl("REFLEXES:", b, fixed = TRUE) && !grepl("CHECKLIST", b, fixed = TRUE) && !grepl("REPLY FORMAT", b, fixed = TRUE) &&
         grepl("cannot be edited here. You can read them on the Methodology tab.", gsub("\\s+", " ", b), fixed = TRUE))
    a = build_prompt(st$form)
    session$setInputs(user = paste0(a$message, "\nAlso say if a question is too long."), approve = 1)
    ok("approving a review prompt, edited or not, starts a run with the edited text and both hashes",
       st$run_id == 1L && identical(st$approved$edited, TRUE) && identical(st$approved$original_hash, a$hash) &&
         grepl("Also say if a question is too long.", st$approved$user, fixed = TRUE))
  })
})


# Tab 3, Results, and Run again.

rich_appraisal <- list(
  selected = list(
    list(domain = "domain 1", candidate = "A", id = "Q1",
         check_before_use = "The term institution is vague. Name the institution.",
         why = "ZZ-WHY-NOT-SHOWN", suggestion = "ZZ-SUGGESTION-NOT-SHOWN",
         concerns = list(list(check = "one_thing", evidence = "ZZ-EVIDENCE-NOT-SHOWN", severity = 7, why = "x"))),
    list(domain = "domain 2", candidate = "B", id = "Q2", check_before_use = "")),
  not_covered = list("ZZ-NOT-COVERED-NOT-SHOWN"),
  set_notes = list(list(check = "keying", severity = 6, why = "ZZ-SET-NOTE-NOT-SHOWN")),
  test_first = list(list(id = "Q1", method = "ZZ-TEST-FIRST-NOT-SHOWN")),
  limits = "ZZ-LIMITS-NOT-SHOWN")
# The screens call the project manager the app is configured with.
pm_id <- APP_MODELS$pm$id
reply_rich <- function(m, sys) {
  if (identical(m$id, pm_id)) rich_appraisal else tagged_draft(m)
}
approve_state <- function(st) {
  st$approved = c(build_prompt(st$form), list(edited = FALSE, original_hash = build_prompt(st$form)$hash))
  st$run_id = st$run_id + 1L
}

local({
  st = flow_state()
  fa = rec_ask(reply_rich)
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) fa$ask), {
    session$flushReact()   # the run observer starts listening at the first flush, as in a session
    ok("before any run the Results tab says nothing has been run",
       grepl("Nothing has been run yet", html_of3(output$results), fixed = TRUE))
    approve_state(st)
    session$flushReact()
    h = html_of3(output$results)
    s = html_of3(output$set_ui)
    d = html_of3(output$drafts_ui)
    ok("a run makes one call per worker and one for the appraisal, records the round, and sets the recommended set from the reviewer's letters and ids",
       identical(purrr::map_chr(fa$st$calls, "id"), c(fl_ids, pm_id)) && st$round == 1L &&
         length(st$drafts) == 3L && identical(st$appraisal$status, "ok") && length(st$rounds) == 1L &&
         identical(st$rounds[[1]]$schema, 1L) && identical(st$rounds[[1]]$seed, st$seed) &&
         identical(purrr::map_chr(st$set, "uid"), c("A_1", "B_2")) && identical(purrr::map_lgl(st$set, "swapped"), c(FALSE, FALSE)) &&
         length(st$edits) == 0L)
    ok("only the recommended questions are shown, under the one sentence: each question and every option in a text box, numbered, with a button to take it out, and no tick boxes",
       grepl("These are drafts. Test them with real respondents before fielding.", s, fixed = TRUE) &&
         grepl("ed_A_1_stem", s, fixed = TRUE) &&
         all(purrr::map_lgl(c("ed_A_1_o1", "ed_A_1_o2", "ed_A_1_o3", "ed_B_2_stem", "ed_B_2_o3"), function(id) grepl(id, s, fixed = TRUE))) &&
         grepl("Question 1", s, fixed = TRUE) && grepl("Question 2", s, fixed = TRUE) &&
         grepl("Question from worker", s, fixed = TRUE) && n_in3("Remove from the set", s) == 2L &&
         !grepl("Keep this item", paste(h, s, d), fixed = TRUE) && !grepl("Candidate", paste(h, s), fixed = TRUE))
    ok("a recommended question has no domain, reason, model, severity, band, suggestion or reflex id on the screen",
       !any(purrr::map_lgl(c("domain 1", "domain 2", "Why this one", "written by", "severity", "Fix before fielding", "Needs your judgment",
                             "A suggested change", "one_thing", "Failing words", fl_ids), function(x) grepl(x, s, fixed = TRUE))))
    ok("the one line to check before use is on the question that has one, cut to its first sentence, and not on the other",
       n_in3("Check before use:", s) == 1L && grepl("The term institution is vague.", s, fixed = TRUE) &&
         !grepl("Name the institution", s, fixed = TRUE) &&
         regexpr("Check before use:", s, fixed = TRUE) < regexpr("ed_B_2_stem", s, fixed = TRUE))
    ok("nothing else of the reviewer's reply is drawn, though the model sent it: no reasons, concerns, notes on the set, domains not covered, test first or limits",
       !grepl("ZZ-", paste(h, s, d), fixed = TRUE) &&
         !grepl("About the set as a whole|What to test first|No draft item was good enough", paste(h, s, d)))
    ok("the other drafts are in a closed panel below, by domain, each with its question and options and a button to use it, except the two already in the set; no model, candidate or coded default",
       grepl("See all drafts", d, fixed = TRUE) && !grepl("<details[^>]* open", d) &&
         n_in3("Use this instead", d) == 4L && grepl("<h6[^>]*>domain 1</h6>", d) &&
         !any(purrr::map_lgl(c(fl_ids, "Candidate", "Coded defaults", "decisions not itemised", "Odd number of points"), function(x) grepl(x, d, fixed = TRUE))))
    ok("the page for the round shows no prompt hash, seed or criteria, and the appraiser was given no model name",
       !grepl("Criteria that were applied|Prompt hash|Labels shuffled|workers returned usable drafts", h) &&
         !grepl(substr(build_prompt(st$form)$hash, 1, 16), paste(h, s, d), fixed = TRUE) &&
         !grepl(as.character(st$seed), paste(h, s, d), fixed = TRUE) &&
         !any(purrr::map_lgl(c(fl_ids, "vendor-"), function(x) grepl(x, fa$st$calls[[4]]$user, fixed = TRUE))))

    # What the analyst does. The drafts are never touched.
    before = st$drafts
    b2_stem = candidates_of(st$drafts, st$seed)$B$items[[2]]$stem
    session$setInputs(ed_A_1_stem = "A better stem?", ed_A_1_o2 = "Somewhat", ed_B_2_o3 = "", ed_B_2_stem = b2_stem)
    session$flushReact()
    final = final_set(st$set, st$edits, st$drafts, st$seed)
    ok("typing in a box is recorded in the session as a change, only for what differs from the draft; the item is the draft's with the change put on it, and the drafts are as the workers wrote them",
       identical(names(st$edits), c("A_1", "B_2")) && identical(st$edits$A_1$stem, "A better stem?") &&
         identical(st$edits$A_1$options[["2"]], "Somewhat") && identical(st$edits$B_2$options[["3"]], "") &&
         is.null(st$edits$B_2$stem) &&
         identical(final[[1]]$item$stem, "A better stem?") && identical(unlist(final[[1]]$item$options), c("None", "Somewhat", "A lot")) &&
         isTRUE(final[[1]]$edited) && length(final[[2]]$item$options) == 2L &&
         identical(st$drafts, before))
    session$setInputs(remove = "B_2")
    session$flushReact()
    s2 = html_of3(output$set_ui)
    ok("taking an item out removes it from the set and the page, and what was typed in the others is put back in the boxes",
       identical(purrr::map_chr(st$set, "uid"), "A_1") && identical(names(st$edits), "A_1") &&
         n_in3("Remove from the set", s2) == 1L && grepl("A better stem?", s2, fixed = TRUE) && grepl("Somewhat", s2, fixed = TRUE) &&
         !grepl("ed_B_2_stem", s2, fixed = TRUE))
    session$setInputs(swap_target = "", swap = "C_1")
    session$flushReact()
    ok("an item from the drafts used with no item chosen goes at the end of the set, marked as swapped in; one already in the set is not put in twice",
       identical(purrr::map_chr(st$set, "uid"), c("A_1", "C_1")) && identical(purrr::map_lgl(st$set, "swapped"), c(FALSE, TRUE)) &&
         identical(st$set[[2]]$candidate, "C") && st$set[[2]]$position == 1L && identical(st$set[[2]]$id, "Q1") &&
         grepl("ed_C_1_stem", html_of3(output$set_ui), fixed = TRUE) &&
         identical(purrr::map_chr(set_swap(st$set, st$set[[2]]), "uid"), c("A_1", "C_1")))
    session$setInputs(swap_target = "A_1", swap = "B_1")
    session$flushReact()
    s3 = html_of3(output$set_ui)
    ok("an item used with an item of the set chosen takes its place, and the replaced item's changes go with it",
       identical(purrr::map_chr(st$set, "uid"), c("B_1", "C_1")) && length(st$edits) == 0L &&
         !grepl("A better stem?", s3, fixed = TRUE) && grepl("ed_B_1_stem", s3, fixed = TRUE) &&
         grepl("Use this instead", html_of3(output$drafts_ui), fixed = TRUE) &&
         identical(st$drafts, before))

    # A browser resets the boxes when the results are drawn again; the test's inputs do not.
    session$setInputs(ed_A_1_stem = NULL, ed_A_1_o2 = NULL, ed_B_2_stem = NULL, ed_B_2_o3 = NULL)
    approve_state(st)
    session$flushReact()
    ok("a second run is a second round in the log, with the set the reviewer recommended and nothing edited",
       st$round == 2L && length(st$rounds) == 2L && identical(purrr::map_chr(st$set, "uid"), c("A_1", "B_2")) &&
         length(st$edits) == 0L)
  })
})

local({
  st = flow_state()
  fb = rec_ask(function(m, sys) {
    if (identical(m$id, "vendor-b/model-two")) stop("canned endpoint error", call. = FALSE)
    reply_rich(m, sys)
  })
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) fb$ask), {
    session$flushReact()
    approve_state(st)
    session$flushReact()
    h = html_of3(output$results)
    d = html_of3(output$drafts_ui)
    ok("a worker that failed is not on the screen when others came back (the record has it); the other two are shown, and the reviewer covers two candidates",
       !grepl("Did not return a usable draft|canned endpoint error|workers returned", paste(h, d)) &&
         n_in3("Use this instead", d) == 2L &&
         any(purrr::map_lgl(st$drafts, function(x) grepl("canned endpoint error", x$error %||% "", fixed = TRUE))) &&
         identical(st$appraisal$status, "ok") && length(st$set) == 2L)
  })
})

local({
  st = flow_state()
  fc <- rec_ask(function(m, sys) if (identical(m$id, pm_id)) stop("the appraiser is down", call. = FALSE) else reply_rich(m, sys))
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) fc$ask), {
    session$flushReact()
    approve_state(st)
    session$flushReact()
    h = html_of3(output$results)
    d = html_of3(output$drafts_ui)
    ok("a reviewer that did not come back is said in words with its reason; there is no recommended set, the drafts are open, and the analyst can build a set from them",
       grepl("The reviewer did not come back", h, fixed = TRUE) && grepl("the appraiser is down", h, fixed = TRUE) &&
         grepl("The set is empty", html_of3(output$set_ui), fixed = TRUE) && length(st$set) == 0L &&
         grepl("See all drafts", d, fixed = TRUE) && grepl("<details[^>]* open", d) && n_in3("Use this instead", d) == 6L)
    session$setInputs(swap_target = "", swap = "A_2")
    session$flushReact()
    ok("using an item from the drafts then gives a set of one, marked as swapped in",
       identical(purrr::map_chr(st$set, "uid"), "A_2") && isTRUE(st$set[[1]]$swapped) &&
         grepl("ed_A_2_stem", html_of3(output$set_ui), fixed = TRUE))
  })
})

local({
  st = test_state()
  fd = rec_ask(reply_rich)
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) fd$ask), {
    session$flushReact()
    st$workers = fl_workers
    st$approved = list(system = "s", user = "u", hash = "h", edited = FALSE, original_hash = "h")
    st$run_id = 1L
    session$flushReact()
    ok("a run that cannot start (no form) stops with a plain sentence on the page, not an error",
       grepl("The run stopped", html_of3(output$results), fixed = TRUE) && length(fd$st$calls) == 0L && st$round == 0L)
  })
})

local({
  nav = nav_rec()
  st = test_state()
  shiny::testServer(mod_again_server, args = list(state = st, go = nav$go), {
    ok("Run again is not offered before there is a round to run again",
       is.null(output$panel$html) || !nzchar(html_of3(output$panel)))
    st$round = 1L
    session$flushReact()
    ok("after a round, Run again offers a box for what to change",
       grepl("What to change", html_of3(output$panel), fixed = TRUE) && grepl("REVISION", html_of3(output$panel), fixed = TRUE))
    session$setInputs(change = "  Use plainer words.\r\nKeep it short.  ", again = 1)
    ok("what is typed becomes the revision, trimmed, and the Brief tab opens with the form as it was",
       identical(st$revision, "Use plainer words.\nKeep it short.") && identical(nav$env$tabs, QUESTIONR_TABS[2]))
    session$setInputs(change = "   ", again = 2)
    ok("a blank box clears the revision and still goes back to the brief", identical(st$revision, ""))
  })
})

# The whole page, as the browser gets it.
ok("the page has the Generate tabs' controls, and no tab is a placeholder",
   grepl("Check my brief first", page$html, fixed = TRUE) && grepl("Build the instructions", page$html, fixed = TRUE) &&
     grepl("Research question (required)", page$html, fixed = TRUE) && !grepl("Not built yet", page$html, fixed = TRUE))
ok("no key is anywhere on the page", !grepl("pm-test-key|SECRET-KEY|or-secret-key", page$html))


# ---- From the first live run of the engine (2026-11-11) ------------------------------------

# The brief check's and the appraisal's call records reach the log, as the drafts' do.
ok("the log keeps the brief check's and the appraisal's own call records: raw reply, tokens, attempts",
   identical(rj_back$brief$call$tokens$input, 100L) && identical(rj_back$appraisal$call$tokens$output, 50L) &&
     grepl("criteria", rj_back$brief$call$raw, fixed = TRUE) && grepl("selected", rj_back$appraisal$call$raw, fixed = TRUE) &&
     identical(rj_back$brief$call$attempts, 1L))

# ---- Phase 4a: section 13's rulings ------------------------------------------------------

# A cut-off reply says what to do about it, for the step it was.
cut_off <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
  llm_fail("[x via y, finish: max_tokens] The reply reached the token limit (1) without finishing, so it was cut off.",
           class = "llm_truncated")
ok("a cut-off brief check says to try again or skip; a cut-off draft to ask for fewer items; a cut-off appraisal to ask for fewer items",
   grepl("try the brief check again, or skip it", tolower(run_brief(fl_form, fl_pm, ask = cut_off)$error), fixed = TRUE) &&
     all(purrr::map_lgl(run_drafts(fl_form, fl_workers, ask = cut_off), function(d)
       grepl("Ask for fewer items and run again.", d$error, fixed = TRUE))) &&
     grepl("Ask for fewer items, and run again.", run_appraisal(fl_form, fl_drafts, fl_pm, ask = cut_off, seed = 1L)$error,
           fixed = TRUE) &&
     identical(unname(LLM_CUTOFF_ADVICE[["evaluate"]]), "Paste fewer questions and run again."))
ok("an error that is not a cut-off gets no cut-off advice",
   !grepl("fewer items", run_brief(fl_form, fl_pm, ask = function(...) stop("endpoint down", call. = FALSE))$error, fixed = TRUE))

# At most 10 items a run, and the pasted questionnaire has a cap that is enforced.
ok("a run drafts at most 10 items: 10 is accepted, 11 is refused saying so, and the form's box stops at 10",
   identical(clean_form(utils::modifyList(forms$attitudinal, list(n_items = 10L)))$n_items, 10L) &&
     grepl("at most 10 items; 11 were asked for", tryCatch(clean_form(utils::modifyList(forms$attitudinal, list(n_items = 11L))),
                                                          error = conditionMessage), fixed = TRUE) &&
     grepl("max=\"10\"", paste(as.character(mod_brief_ui("brief")), collapse = ""), fixed = TRUE))
ok("a pasted questionnaire over the cap is refused, saying how long it is and what the limit is; at the cap it is accepted",
   local({
     long = function(n) utils::modifyList(forms$evaluate, list(questionnaire = strrep("a", n)))
     e = tryCatch(clean_form(long(APP_MAX_PASTE_CHARS + 1L)), error = conditionMessage)
     is.character(e) && grepl("Paste it in parts", e, fixed = TRUE) &&
       grepl(format(APP_MAX_PASTE_CHARS, big.mark = ","), e, fixed = TRUE) &&
       identical(nchar(clean_form(long(APP_MAX_PASTE_CHARS))$questionnaire), as.integer(APP_MAX_PASTE_CHARS)) &&
       grepl("Paste it in parts", tryCatch(build_prompt(long(APP_MAX_PASTE_CHARS + 1L)), error = conditionMessage), fixed = TRUE)
   }))
ok("Luna is the last of the workers (decision 15)",
   identical(APP_MODELS$workers[[length(APP_MODELS$workers)]]$id, "openai/gpt-6-luna"))

# reasoning_effort, in ellmer 0.4.2, against a server on this machine that echoes what it is sent.
make_body_mock <- function() {
  mock = webfakes::new_app()
  mock$use(webfakes::mw_json())
  body_of = function(req)
    jsonlite::toJSON(req$json[setdiff(names(req$json), c("messages", "system"))], auto_unbox = TRUE, null = "null")
  mock$post("/v1/chat/completions", function(req, res) {
    res$send_json(list(id = "x", object = "chat.completion", created = 1L, model = req$json$model,
      choices = list(list(index = 0L, message = list(role = "assistant", content = body_of(req)), finish_reason = "stop")),
      usage = list(prompt_tokens = 5L, completion_tokens = 7L, total_tokens = 12L)), auto_unbox = TRUE)
  })
  mock$post("/v1/messages", function(req, res) {
    res$send_json(list(id = "msg_1", type = "message", role = "assistant", model = req$json$model,
      content = list(list(type = "text", text = body_of(req))), stop_reason = "end_turn", stop_sequence = NULL,
      usage = list(input_tokens = 5L, output_tokens = 7L)), auto_unbox = TRUE, null = "null")
  })
  mock
}
local({
  px = webfakes::new_app_process(make_body_mock())
  on.exit(px$stop())
  sent = function(api, effort = NULL, name = NULL) {
    m = list(api = api, base_url = px$url("/v1"), id = "mock/model", key_source = "analyst")
    if (!is.null(effort)) m$reasoning_effort = effort
    if (!is.null(name)) m$max_tokens_name = name
    jsonlite::fromJSON(suppressWarnings(llm_complete(m, "SYS", "hi", 1000L, key = "k", timeout = 20)))
  }
  ok("a model entry's reasoning_effort reaches the Anthropic-style call as adaptive thinking with that effort; unset sends neither",
     identical(sent("anthropic", "low")$output_config$effort, "low") &&
       identical(sent("anthropic", "low")$thinking$type, "adaptive") &&
       is.null(sent("anthropic")$thinking) && is.null(sent("anthropic")$output_config))
  ok("on the OpenAI-style call reasoning_effort and the name of the token limit reach the wire through api_args, only when the entry sets them; the Anthropic style keeps max_tokens; no profile entry sets either",
     identical(sent("openai", "low")$reasoning_effort, "low") && is.null(sent("openai")$reasoning_effort) &&
       isTRUE(sent("openai")$max_completion_tokens == 1000) && is.null(sent("openai")$max_tokens) &&
       isTRUE(sent("openai", name = "max_tokens")$max_tokens == 1000) &&
       is.null(sent("openai", name = "max_tokens")$max_completion_tokens) &&
       isTRUE(sent("anthropic", name = "max_tokens")$max_tokens == 1000) &&
       grepl("must be 'max_completion_tokens' or 'max_tokens'",
             tryCatch(sent("openai", name = "max_tokens_please"), error = conditionMessage), fixed = TRUE) &&
       !any(grepl("^[^#]*\\b(reasoning_effort|max_tokens_name) *=", readLines("app.R", warn = FALSE))))
})


# ---- Phase 4b: the review flow and its checks --------------------------------------------

# A review as the model sends it, with more than the analyst is shown: a third problem, a fourth
#   point about the whole, and fields it is no longer asked for.
rv_reply <- list(
  items = list(
    list(id = "Q1", verdict = "Revise", problems = list(
      list(problem = "Two services are asked about in one question. Split it in two.", rewrite = "How satisfied are you with local recycling?"),
      list(problem = "Street cleaning could mean sweeping or litter bins.", rewrite = "How satisfied are you with street sweeping?"),
      list(problem = "ZZ-THIRD-PROBLEM-NOT-SHOWN", rewrite = "ZZ-THIRD-REWRITE-NOT-SHOWN"))),
    list(id = "Q2", verdict = "Keep", problems = list())),
  instrument = list("Questions 1 and 2 use different scales. Use one scale throughout.", "Point two.", "Point three.",
                    "ZZ-FOURTH-POINT-NOT-SHOWN"),
  test_first = list("ZZ-TEST-FIRST-NOT-SHOWN"), not_assessed = "ZZ-NOT-ASSESSED-NOT-SHOWN")

vr <- reply_validator("review")
ok("a review with its two fields passes: a verdict and problems for each question, and points about the whole; fields it is no longer asked for are ignored",
   is.na(problem_of(vr, rv_reply)) &&
     is.na(problem_of(vr, list(items = list(list(id = "Q1", verdict = "Keep")), instrument = list()))) &&
     is.na(problem_of(vr, with_field(rv_reply, items = list(list(id = "Q1", verdict = "keep", problems = list()))))))
ok("a question's id may be a label or a number; a missing id, a missing field or a verdict that is not Keep or Revise fails",
   is.na(problem_of(vr, with_field(rv_reply, items = list(list(id = 1, verdict = "Keep"), list(id = "Q2a", verdict = "Keep"))))) &&
     says_in(problem_of(vr, with_field(rv_reply, items = list(list(verdict = "Keep")))), "'id' is missing") &&
     says_in(problem_of(vr, rv_reply[names(rv_reply) != "instrument"]), "'instrument' is missing") &&
     says_in(problem_of(vr, with_field(rv_reply, items = list(list(id = "Q1", verdict = "Maybe")))), "must be \"Keep\" or \"Revise\"") &&
     says_in(problem_of(vr, with_field(rv_reply, items = list(list(id = "Q1")))), "'verdict' is missing"))
ok("a Revise with no problem fails, asking for the problem or a Keep; a point about the whole must be a sentence",
   says_in(problem_of(vr, with_field(rv_reply, items = list(list(id = "Q1", verdict = "Revise", problems = list())))),
           "gives no problem") &&
     says_in(problem_of(vr, with_field(rv_reply, items = list(list(id = "Q1", verdict = "Revise", problems = list(list(rewrite = "x")))))),
             "gives no problem") &&
     says_in(problem_of(vr, with_field(rv_reply, instrument = list(""))), "one sentence of text"))

rv_form <- forms$evaluate
rv_ask <- function(reply = rv_reply, st = new.env()) {
  st$calls = list()
  list(st = st, ask = function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    st$calls[[length(st$calls) + 1L]] = list(id = m$id, user = user, system = system_prompt, max_tokens = max_tokens)
    if (!is.null(validate)) validate(reply)
    reply
  })
}
ra <- rv_ask()
rv <- run_review(rv_form, fl_pm, ask = ra$ask)
ok("run_review has the fields of run_brief and batches (one entry here), uses build_prompt()'s prompt, and makes one call at the evaluation ceiling",
   identical(sort(names(rv)), sort(c("status", "error", "system", "user", "hash", "reply", "batches"))) &&
     length(rv$batches) == 1L && identical(rv$batches[[1]]$kind, "all") && identical(rv$batches[[1]]$status, "ok") &&
     identical(rv$status, "ok") && is.na(rv$error) && identical(rv$hash, build_prompt(rv_form)$hash) &&
     identical(rv$system, build_prompt(rv_form)$system) && identical(rv$reply, rv_reply) &&
     length(ra$st$calls) == 1L && identical(ra$st$calls[[1]]$max_tokens, LLM_MAX_TOKENS[["evaluate"]]) &&
     identical(ra$st$calls[[1]]$user, build_prompt(rv_form)$user) && !is.null(attr(rv, "call")$seconds))
ok("a review that errors, is cut off, or fails the schema is failed with a plain reason and is not raised",
   identical(run_review(rv_form, fl_pm, ask = function(...) stop("endpoint down", call. = FALSE))$error, "endpoint down") &&
     grepl("Paste fewer questions and run again.", run_review(rv_form, fl_pm, ask = cut_off)$error, fixed = TRUE) &&
     identical(run_review(rv_form, fl_pm, ask = rv_ask(list(items = list()))$ask)$status, "failed"))
rb <- rv_ask()
ok("a form that is not a review, or has no questionnaire, or is over the cap, is failed without a call",
   identical(run_review(fl_form, fl_pm, ask = rb$ask)$status, "failed") &&
     grepl("Only a review task", run_review(fl_form, fl_pm, ask = rb$ask)$error, fixed = TRUE) &&
     grepl("pasted in", run_review(with_field(rv_form, questionnaire = ""), fl_pm, ask = rb$ask)$error, fixed = TRUE) &&
     grepl("Paste it in parts", run_review(with_field(rv_form, questionnaire = strrep("a", APP_MAX_PASTE_CHARS + 1L)),
                                          fl_pm, ask = rb$ask)$error, fixed = TRUE) &&
     length(rb$st$calls) == 0L)
ok("run_review never looks up a key and reaches no model but through ask",
   !any(c("Sys.getenv", "llm_key_for", "llm_session_key", "llm_json", "llm_complete") %in% all.names(body(run_review))))

# What the analyst is shown of a review, and the limits R holds it to (DESIGN.md section 18).
sh <- shape_review(rv_reply, rv_form$questionnaire)
ok("shape_review gives, per question, its id, its text as pasted, a verdict and at most two problems with their rewrites; and the ids kept, and at most three points about the whole",
   identical(names(sh), c("questions", "keep", "instrument")) && length(sh$questions) == 2L &&
     identical(purrr::map_chr(sh$questions, "id"), c("Q1", "Q2")) &&
     identical(purrr::map_chr(sh$questions, "verdict"), c("Revise", "Keep")) &&
     grepl("^Q1\\. How satisfied are you with local recycling\\? Very", sh$questions[[1]]$text) && grepl("^Q2\\. Taking all things together", sh$questions[[2]]$text) &&
     length(sh$questions[[1]]$problems) == 2L && length(sh$questions[[2]]$problems) == 0L &&
     identical(sh$questions[[1]]$problems[[2]]$rewrite, "How satisfied are you with street sweeping?") &&
     identical(sh$keep, "Q2") && length(sh$instrument) == 3L)
ok("a third problem and a fourth point are dropped, whatever the model sent; so are test first and what was not assessed",
   !grepl("ZZ-", paste(unlist(sh), collapse = " "), fixed = TRUE))
ok("a problem is held to one sentence of 20 words or fewer, and a point about the whole to one sentence",
   identical(sh$questions[[1]]$problems[[1]]$problem, "Two services are asked about in one question.") &&
     identical(sh$instrument[[1]], "Questions 1 and 2 use different scales.") &&
     identical(shape_review(list(items = list(list(id = "Q1", verdict = "Revise", problems = list(list(
       problem = "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty twenty-one",
       rewrite = "r")))), instrument = list()), "Q1. A question?")$questions[[1]]$problems[[1]]$problem,
       paste0("one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty", "…")))
ok("a Revise with no problem to show is a Keep, and a verdict in any case is read",
   local({
     s1 = shape_review(list(items = list(list(id = "Q1", verdict = "Revise", problems = list(list(problem = "", rewrite = "x"))),
                                         list(id = "Q2", verdict = "REVISE", problems = list(list(problem = "Bad.", rewrite = "Better?")))),
                           instrument = list()), "Q1. A?\n\nQ2. B?")
     identical(purrr::map_chr(s1$questions, "verdict"), c("Keep", "Revise")) && identical(s1$keep, "Q1")
   }))
ok("the question as pasted is found by blocks when the blank lines make as many as the ids, and by the line that begins with its id when they do not; one that is not found is empty",
   identical(pasted_questions("Q1. First?\nYes / No\n\nQ2. Second?\nA / B", c("a", "b")), c("Q1. First?\nYes / No", "Q2. Second?\nA / B")) &&
     identical(pasted_questions("Q1. First?\nYes / No\nQ2. Second?\nA / B\nQ10. Tenth?", c("Q1", "Q2", "Q10")),
               c("Q1. First?\nYes / No", "Q2. Second?\nA / B", "Q10. Tenth?")) &&
     identical(pasted_questions("Q1. First?\nQ2. Second?", c("Q1", "Q9")), c("Q1. First?\nQ2. Second?", "")) &&
     identical(pasted_questions("1. First?\n1 Yes\n2 No\n2. Second?", c("1", "2")), c("1. First?\n1 Yes\n2 No", "2. Second?")))
ok("the review's checks need the CHECKLIST that was sent",
   all(c("one_thing", "response_scale") %in% names(build_checklist(rv_form))) &&
     !"declare_defaults" %in% names(build_checklist(rv_form)))

rr <- flow_round(rv_form, fl_pm, review = rv)
rr_back <- jsonlite::fromJSON(as.character(flow_log_json(rr)), simplifyVector = FALSE)
ok("a review round is a log too: the summary row, the review with its prompt hash and its call record, and the whole reply as the model sent it",
   identical(purrr::map_chr(rr_back$summary, "step"), "review") && identical(rr_back$review$hash, rv$hash) &&
     !is.null(rr_back$review$call$seconds) && identical(rr_back$schema, 1L) && is.null(rr_back$appraisal) &&
     grepl("ZZ-THIRD-PROBLEM-NOT-SHOWN", as.character(flow_log_json(rr)), fixed = TRUE))


# ---- Phase 4c: the Evaluate screens ---------------------------------------------------------

review_state <- function(form = forms$evaluate) {
  st = test_state()
  st$form = clean_form(form)
  st$workers = list()
  st
}
approve_review <- function(st, edited = FALSE) {
  a = build_prompt(st$form)
  st$approved = c(a, list(edited = edited, original_hash = a$hash))
  st$run_id = st$run_id + 1L
}

local({
  st = review_state()
  ra = rv_ask()
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) ra$ask), {
    session$flushReact()
    approve_review(st, edited = TRUE)
    session$flushReact()
    h = html_of3(output$results)
    ok("a review run makes one call to the project manager at the evaluation ceiling, and records the round, with no candidates",
       length(ra$st$calls) == 1L && identical(ra$st$calls[[1]]$id, APP_MODELS$pm$id) &&
         identical(ra$st$calls[[1]]$max_tokens, LLM_MAX_TOKENS[["evaluate"]]) &&
         st$round == 1L && identical(st$review$status, "ok") && is.null(st$drafts) && is.null(st$appraisal) &&
         is.null(st$seed) && length(st$rounds) == 1L &&
         identical(purrr::map_chr(st$rounds[[1]]$summary, "step"), "review") &&
         identical(st$rounds[[1]]$prompt$edited, TRUE))
    ok("the review is shown under the one sentence: a question marked Revise with the question as pasted, the verdict, two problems and a suggested rewrite each",
       grepl("These are drafts. Test them with real respondents before fielding.", h, fixed = TRUE) &&
         grepl("Question Q1", h, fixed = TRUE) && grepl("Q1. How satisfied are you with local recycling? Very / Fairly / Not", h, fixed = TRUE) &&
         grepl("<strong>Revise</strong>", h, fixed = TRUE) &&
         n_in3("Problem: ", h) == 2L && grepl("Two services are asked about in one question.", h, fixed = TRUE) &&
         grepl("Suggested rewrite: How satisfied are you with local recycling?", h, fixed = TRUE) &&
         n_in3("Suggested rewrite: ", h) == 2L && !grepl("Split it in two", h, fixed = TRUE))
    ok("the questions marked Keep are one line, not cards; the questionnaire as a whole has three points and no more",
       grepl("Question Q2: keep as written", h, fixed = TRUE) && !grepl("Question Q2</h6>", h, fixed = TRUE) &&
         grepl("The questionnaire as a whole", h, fixed = TRUE) && n_in3("Point two.", h) == 1L && n_in3("Point three.", h) == 1L &&
         grepl("Questions 1 and 2 use different scales.", h, fixed = TRUE) && !grepl("Use one scale throughout", h, fixed = TRUE))
    ok("nothing else of the reply is on the screen: no third problem, fourth point, test first, what was not assessed, severity, check, quote, prompt hash, round or criteria",
       !grepl("ZZ-", h, fixed = TRUE) &&
         !grepl("severity|Fix before fielding|Needs your judgment|What to test first|could not judge|Criteria that were applied|One review by the project manager|nothing here is validated|Quote:",
                h) &&
         !grepl(substr(build_prompt(st$form)$hash, 1, 16), h, fixed = TRUE) && !grepl("one_thing", h, fixed = TRUE))
  })
})

local({
  st = review_state()
  dead = rv_ask()
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL,
                                make_ask = function(total) function(...) stop("the project manager is down", call. = FALSE)), {
    session$flushReact()
    approve_review(st)
    session$flushReact()
    h = html_of3(output$results)
    ok("a review that fails is said on the page in words, with its reason, and the round is still recorded",
       grepl("The review did not come back", h, fixed = TRUE) && grepl("the project manager is down", h, fixed = TRUE) &&
         identical(st$review$status, "failed") && st$round == 1L && !grepl("keep as written", h, fixed = TRUE))
  })
})
local({
  st = review_state()
  ra = rv_ask(list(items = list(list(id = "Q1", verdict = "Keep", problems = list()),
                                list(id = "Q2", verdict = "Keep", problems = list())), instrument = list()))
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) ra$ask), {
    session$flushReact()
    approve_review(st)
    session$flushReact()
    h = html_of3(output$results)
    ok("a review that keeps every question says so in one line and has no cards and no points about the whole",
       grepl("Questions Q1, Q2: keep as written", h, fixed = TRUE) && !grepl("<h6", h, fixed = TRUE) &&
         !grepl("The questionnaire as a whole", h, fixed = TRUE) && !grepl("Revise", h, fixed = TRUE))
  })
})

# The review's hash is what the review.R and the log record, and edited prompts are what is sent.
local({
  ra = rv_ask()
  base_prompt = build_prompt(rv_form)
  ed = with_field(base_prompt, user = "EDITED REVIEW PROMPT",
                  hash = prompt_hash(base_prompt$system, "EDITED REVIEW PROMPT"), edited = TRUE)
  rv_ed = run_review(rv_form, fl_pm, ask = ra$ask, prompt = ed)
  ok("run_review sends an edited prompt when given one, and keeps it as the result's prompt with its own hash",
     identical(ra$st$calls[[1]]$user, "EDITED REVIEW PROMPT") && identical(rv_ed$user, "EDITED REVIEW PROMPT") &&
       identical(rv_ed$hash, prompt_hash(ed$system, "EDITED REVIEW PROMPT")) && identical(attr(rv_ed, "prompt")$edited, TRUE) &&
       identical(flow_round(rv_form, fl_pm, review = rv_ed)$prompt$edited, TRUE) &&
       grepl("system and a user", tryCatch(run_review(rv_form, fl_pm, ask = ra$ask, prompt = list(user = "x")),
                                           error = conditionMessage), fixed = TRUE))
})

# ---- Phase 5b: a long questionnaire is reviewed in parts -----------------------------------------

long_blocks <- purrr::map_chr(1:30, function(i)
  paste0("Q", i, ". Canned question number ", i, " ", strrep("word ", 50), "?\nYes / No"))
long_text <- paste(long_blocks, collapse = "\n\n")
long_parts <- split_questionnaire(long_text, 4000L)

ok("split_questionnaire: more than one part, none over the limit, whole blocks in order, joined by a blank line they give the text back",
   length(long_parts) == 3L && all(nchar(long_parts) <= 4000L) &&
     identical(paste(long_parts, collapse = "\n\n"), long_text) &&
     identical(unname(attr(long_parts, "first_block")), c(1L, 14L, 27L)) &&
     all(purrr::map_lgl(strsplit(long_parts, "\n\n", fixed = TRUE), function(b) all(grepl("^Q[0-9]+\\. ", b)))))
ok("split_questionnaire: a short text is one part; runs of blank lines and CRLF line endings count as one separator",
   identical(as.character(split_questionnaire("Q1. a\nYes / No\n\nQ2. b", 4000L)), "Q1. a\nYes / No\n\nQ2. b") &&
     identical(as.character(split_questionnaire("Q1. a\r\n\r\n\r\n   \r\nQ2. b", 10L)), c("Q1. a", "Q2. b")) &&
     identical(unname(attr(split_questionnaire("Q1. a\r\n\r\n\r\nQ2. b", 10L), "first_block")), c(1L, 2L)))
ok("split_questionnaire: a block over the limit stops, saying which block, how long, and quoting its first words",
   local({
     e = tryCatch(split_questionnaire(paste("Q1. short", paste0("Q2. This is the long block ", strrep("y", 4100)), sep = "\n\n"), 4000L),
                  error = conditionMessage)
     grepl("Block 2 of the questionnaire is 4,127 characters", e, fixed = TRUE) && grepl("never cut", e, fixed = TRUE) &&
       grepl("Leave a blank line between questions", e, fixed = TRUE) && grepl("It starts: \"Q2. This is the long block", e, fixed = TRUE)
   }))
ok("APP_BATCH_CHARS is 4000 and APP_MAX_PASTE_CHARS is 40000, and both are in the global environment for R/ to read",
   identical(APP_BATCH_CHARS, 4000) && identical(APP_MAX_PASTE_CHARS, 40000) &&
     all(c("APP_BATCH_CHARS", "APP_MAX_PASTE_CHARS") %in% ls(globalenv())))

long_form <- with_field(forms$evaluate, questionnaire = long_text)
plan <- review_plan(long_text, 4000L)
ok("review_plan: one call of kind all for a short text; an items call per part then an instrument call for a long one",
   identical(purrr::map_chr(review_plan(forms$evaluate$questionnaire, 4000L), "kind"), "all") &&
     identical(purrr::map_chr(plan, "kind"), c("items", "items", "items", "instrument")) &&
     identical(purrr::map_int(plan, "first_block"), c(1L, 14L, 27L, 1L)) && identical(plan[[4]]$text, long_text))

ip1 <- build_step_prompt(long_form, "items", part = plan[[2]])
ip_inst <- build_step_prompt(long_form, "instrument", part = plan[[4]])
inst_ids <- TASKS$evaluate$instrument_checks
ck_lines <- function(u) { l = strsplit(u, "\n", fixed = TRUE)[[1]]; sub(":.*$", "", l[(match("CHECKLIST", l) + 1L):(match("REPLY FORMAT", l) - 2L)]) }
ok("an item call has only its part of the text, the part sentence with its numbers, and every check but the four instrument ones",
   grepl("Review part 2 of 3 of a questionnaire", ip1$user, fixed = TRUE) &&
     grepl("block number 14 of the whole questionnaire", ip1$user, fixed = TRUE) &&
     grepl("Fill only \"items\"", ip1$user, fixed = TRUE) && grepl(plan[[2]]$text, ip1$user, fixed = TRUE) &&
     !grepl("Q1. Canned", ip1$user, fixed = TRUE) && !grepl("Q27. Canned", ip1$user, fixed = TRUE) &&
     !any(inst_ids %in% ck_lines(ip1$user)) && "one_thing" %in% ck_lines(ip1$user) &&
     identical(sort(c(ck_lines(ip1$user), inst_ids)), sort(names(build_checklist(long_form)))))
ok("the instrument call has the whole questionnaire, only the four instrument checks, and the sentence that fills the other fields",
   grepl(long_text, ip_inst$user, fixed = TRUE) && identical(ck_lines(ip_inst$user), inst_ids) &&
     grepl("Review the questionnaire below as a whole", ip_inst$user, fixed = TRUE) &&
     grepl("Fill only \"instrument\" in your reply", ip_inst$user, fixed = TRUE) &&
     !grepl("\none_thing: ", ip_inst$user, fixed = TRUE))
ok("the part sentences are fixed text from the registry, so the same part gives the same prompt and hash; the system prompt is the work step's",
   identical(ip1$hash, build_step_prompt(long_form, "items", part = plan[[2]])$hash) &&
     !identical(ip1$hash, build_step_prompt(long_form, "items", part = plan[[1]])$hash) &&
     identical(ip1$system, build_prompt(long_form)$system) && identical(ip_inst$system, ip1$system) &&
     grepl(sprintf(TASKS$evaluate$ask_items, 2L, 3L, 14L), ip1$user, fixed = TRUE) &&
     grepl(TASKS$evaluate$ask_instrument, ip_inst$user, fixed = TRUE) &&
     !grepl("\nQ[0-9]+\\. ", paste(sprintf(TASKS$evaluate$ask_items, 2L, 3L, 14L), TASKS$evaluate$ask_instrument)))
ok("a part prompt needs a review task and a part of its own kind; a part sentence needs a task that has one",
   grepl("Only a review task", tryCatch(build_step_prompt(forms$attitudinal, "items", part = plan[[1]]), error = conditionMessage), fixed = TRUE) &&
     grepl("needs a part of kind 'items'", tryCatch(build_step_prompt(long_form, "items", part = plan[[4]]), error = conditionMessage), fixed = TRUE) &&
     grepl("needs k, n, first_block and text", tryCatch(build_step_prompt(long_form, "items", part = list(kind = "items")), error = conditionMessage), fixed = TRUE) &&
     grepl("not reviewed in parts", tryCatch(part_ask_sentence("attitudinal", plan[[1]]), error = conditionMessage), fixed = TRUE))
ok("a one-part questionnaire's prompt is the work prompt, as before (same hash), and the registry gives it no part sentence",
   identical(run_review(forms$evaluate, fl_pm, ask = rv_ask()$ask)$hash, build_prompt(forms$evaluate)$hash) &&
     !grepl("part 1 of", build_prompt(forms$evaluate)$user, fixed = TRUE))

# A fake project manager for the parts: item calls answer for the questions in their text, the instrument call
#   for the whole. `fail_at` makes that call (by number) stop with an error.
parts_ask <- function(fail_at = 0L, st = new.env()) {
  st$n = 0L; st$users = character(0); st$max = integer(0); st$fail_at = fail_at
  list(st = st, ask = function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL) {
    st$n = st$n + 1L; st$users = c(st$users, user); st$max = c(st$max, max_tokens)
    if (st$n == st$fail_at) stop("canned endpoint error", call. = FALSE)
    ids = regmatches(user, gregexpr("(?m)^Q[0-9]+(?=\\. )", user, perl = TRUE))[[1]]
    instrument = !grepl("\none_thing: ", user, fixed = TRUE)
    obj = list(items = if (instrument) list() else purrr::map(ids, function(i) list(id = i, verdict = "Revise", problems = list(
                 list(problem = "A canned problem.", rewrite = "A canned rewrite?")))),
               instrument = if (instrument) list("Canned point about the whole.") else list())
    if (!is.null(validate)) validate(obj)
    list(obj = obj, raw = "{}", finish = "stop", tokens = c(input = 1000, output = 500, cached_input = 0), attempts = 1L)
  })
}
pa <- parts_ask()
said <- character(0)
rvl <- run_review(long_form, fl_pm, ask = pa$ask, progress = function(msg) said <<- c(said, msg))
ok("a long review makes one call per part and one for the instrument, each at the evaluation ceiling, and says before each which it is",
   pa$st$n == 4L && all(pa$st$max == LLM_MAX_TOKENS[["evaluate"]]) &&
     identical(said, c("Reviewing parts 1 to 3 of 3 together", "Reviewing the questionnaire as a whole")) &&
     identical(pa$st$users[1:3], purrr::map_chr(plan[1:3], function(s) build_step_prompt(long_form, "items", part = s)$user)))
ok("a long review's result has run_review's fields and batches: one per call, in order, each with kind, part, status, hash, seconds and its reply",
   identical(sort(names(rvl)), sort(c("status", "error", "system", "user", "hash", "reply", "batches"))) &&
     identical(rvl$status, "ok") && is.na(rvl$error) && length(rvl$batches) == 4L &&
     identical(purrr::map_chr(rvl$batches, "kind"), c("items", "items", "items", "instrument")) &&
     all(purrr::map_lgl(rvl$batches, function(b) all(c("status", "hash", "seconds", "part", "first_block", "reply", "user", "error") %in% names(b)))) &&
     identical(rvl$hash, rvl$batches[[1]]$hash) && !any(duplicated(purrr::map_chr(rvl$batches, "hash"))))
ok("the reply holds all 30 questions in the order pasted, and the points about the whole from the instrument call only",
   identical(purrr::map_chr(rvl$reply$items, "id"), paste0("Q", 1:30)) &&
     identical(names(rvl$reply), c("items", "instrument")) && length(rvl$reply$instrument) == 1L &&
     local({
       sh = shape_review(rvl$reply, long_form$questionnaire)
       length(sh$questions) == 30L && length(sh$instrument) == 1L &&
         grepl("^Q30\\. Canned question number 30", sh$questions[[30]]$text)
     }))
ok("the call record of a long review adds up its calls: seconds, and tokens in and out",
   identical(attr(rvl, "call")$tokens, list(input = 4000, output = 2000)) && attr(rvl, "call")$attempts == 4L &&
     is.numeric(attr(rvl, "call")$seconds))

pf <- parts_ask(fail_at = 2L)
rvp <- run_review(long_form, fl_pm, ask = pf$ask)
ok("a part that fails gives status partial naming it, keeps the questions of the other parts in order, and the instrument call still runs",
   identical(rvp$status, "partial") && grepl("Part 2 of 3 did not come back: canned endpoint error", rvp$error, fixed = TRUE) &&
     pf$st$n == 4L && identical(purrr::map_chr(rvp$batches, "status"), c("ok", "failed", "ok", "ok")) &&
     identical(purrr::map_chr(rvp$reply$items, "id"), paste0("Q", c(1:13, 27:30))) &&
     length(rvp$reply$instrument) == 1L)
ok("the instrument call failing leaves the questions and an empty instrument; every call failing is failed with no reply",
   local({
     r1 = run_review(long_form, fl_pm, ask = parts_ask(fail_at = 4L)$ask)
     r0 = run_review(long_form, fl_pm, ask = function(...) stop("endpoint down", call. = FALSE))
     identical(r1$status, "partial") && length(r1$reply$items) == 30L && length(r1$reply$instrument) == 0L &&
       grepl("The instrument as a whole did not come back", r1$error, fixed = TRUE) &&
       identical(r0$status, "failed") && is.null(r0$reply) && length(r0$batches) == 4L && grepl("Part 1 of 3", r0$error, fixed = TRUE)
   }))
pr <- parts_ask()
rvr <- rerun_review_part(long_form, fl_pm, rvp, 2L, ask = pr$ask)
ok("running a failed part again makes one call for it, keeps the other calls as they were, and gives status ok with all 30 questions",
   pr$st$n == 1L && identical(pr$st$users, build_step_prompt(long_form, "items", part = plan[[2]])$user) &&
     identical(rvr$status, "ok") && identical(purrr::map_chr(rvr$reply$items, "id"), paste0("Q", 1:30)) &&
     isTRUE(rvr$batches[[2]]$rerun) && is.null(rvr$batches[[1]]$rerun) &&
     identical(rvr$batches[[1]]$hash, rvp$batches[[1]]$hash) && identical(rvr$batches[[4]]$reply, rvp$batches[[4]]$reply) &&
     grepl("There is no part 9", tryCatch(rerun_review_part(long_form, fl_pm, rvp, 9L, ask = pr$ask), error = conditionMessage), fixed = TRUE) &&
     grepl("There is no part 1", tryCatch(rerun_review_part(forms$evaluate, fl_pm, rv, 1L, ask = pr$ask), error = conditionMessage), fixed = TRUE))
ok("an edited prompt cannot be sent in a long review (it is several prompts); a questionnaire with a block too long fails without a call",
   grepl("only when the questionnaire is reviewed in one call", tryCatch(
     run_review(long_form, fl_pm, ask = parts_ask()$ask, prompt = with_field(build_prompt(long_form), edited = TRUE)),
     error = conditionMessage), fixed = TRUE) &&
     local({
       pz = parts_ask()
       r = run_review(with_field(forms$evaluate, questionnaire = paste0("Q1. ", strrep("x", 4100))), fl_pm, ask = pz$ask)
       identical(r$status, "failed") && grepl("Block 1 of the questionnaire", r$error, fixed = TRUE) && pz$st$n == 0L
     }))
ok("run_review reaches no model and no Shiny function but through ask and progress",
   !any(c("Sys.getenv", "llm_key_for", "llm_session_key", "llm_json", "llm_complete", "setProgress", "withProgress",
          "reactive", "observe") %in% all.names(body(run_review))) &&
     !any(c("setProgress", "withProgress", "llm_json") %in% all.names(body(review_call))) &&
     identical(names(formals(run_review)), c("form", "pm", "ask", "prompt", "progress", "ask_all")))

sm <- flow_summary(review = rvl, pm = fl_pm)
ok("a long review's log summary has one row per call, naming the part; a one-call review keeps its one row",
   identical(purrr::map_chr(sm, "step"), c("review part 1 of 3", "review part 2 of 3", "review part 3 of 3", "review instrument")) &&
     identical(purrr::map_chr(flow_summary(review = rv, pm = fl_pm), "step"), "review") &&
     all(purrr::map_dbl(sm, "tokens_in") == 1000) && all(purrr::map_dbl(sm, "tokens_out") == 500))
rl_back <- jsonlite::fromJSON(as.character(flow_log_json(flow_round(long_form, fl_pm, review = rvl))), simplifyVector = FALSE)
ok("the run log of a long review holds every call: its hash, its prompt, its reply and its call record",
   length(rl_back$review$batches) == 4L && identical(rl_back$review$batches[[2]]$hash, rvl$batches[[2]]$hash) &&
     grepl("part 2 of 3", rl_back$review$batches[[2]]$user, fixed = TRUE) && !is.null(rl_back$review$batches[[2]]$reply$items) &&
     abs(rl_back$review$batches[[1]]$seconds - rvl$batches[[1]]$seconds) < 0.001 &&
     identical(purrr::map_chr(rl_back$summary, "step")[4], "review instrument"))

# The screens: the Prompt tab, the run, the page for a part that failed, and running that part again.
local({
  st = review_state(long_form)
  shiny::testServer(mod_prompt_server, args = list(state = st, go = function(tab) NULL), {
    session$flushReact()
    h = html_of3(output$body)
    ok("the Prompt tab for a long review says it is several calls, shows the first part's prompt, and offers no editing",
       grepl("reviewed in 3 parts", h, fixed = TRUE) && grepl("4 calls", h, fixed = TRUE) &&
         grepl("Review part 1 of 3", h, fixed = TRUE) && grepl("cannot be edited here", h, fixed = TRUE) &&
         grepl(substr(build_step_prompt(long_form, "items", part = plan[[1]])$hash, 1, 16), h, fixed = TRUE) &&
         !grepl("<textarea", h, fixed = TRUE) && grepl("Approve and run", h, fixed = TRUE))
    session$setInputs(approve = 1)
    session$flushReact()
    ok("approving it records the first part's prompt as assembled, not edited, with its hash, and starts the run",
       identical(st$approved$edited, FALSE) && identical(st$approved$hash, build_step_prompt(long_form, "items", part = plan[[1]])$hash) &&
         st$run_id == 1L && is.null(output$status))
  })
})
local({
  st = review_state(long_form)
  pa = parts_ask(fail_at = 2L)
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) { pa$st$total = total; pa$ask }), {
    session$flushReact()
    approve_review(st)
    session$flushReact()
    h = html_of3(output$results)
    ok("a run of a long review asks for one progress step per call, records one round with the summary rows, and shows the part that failed",
       pa$st$total == 4L && pa$st$n == 4L && st$round == 1L && identical(st$review$status, "partial") &&
         length(st$rounds) == 1L && length(st$rounds[[1]]$summary) == 4L &&
         grepl("Part of the review did not come back", h, fixed = TRUE) &&
         grepl("Part 2 of 3, from block 14", h, fixed = TRUE) && grepl("canned endpoint error", h, fixed = TRUE) &&
         grepl("not clear of problems", h, fixed = TRUE) && n_in3("Run this part again", h) == 1L &&
         grepl("Shiny.setInputValue(&#39;", h, fixed = TRUE) && grepl("-rerun&#39;, 2, ", h, fixed = TRUE))
    ok("the page for a long review shows the questions that came back and the points about the whole, and no prompt hash or call count",
       grepl("The questionnaire as a whole", h, fixed = TRUE) && grepl("Canned point about the whole.", h, fixed = TRUE) &&
         grepl("Question Q1", h, fixed = TRUE) && grepl("Question Q30", h, fixed = TRUE) && !grepl("Question Q20", h, fixed = TRUE) &&
         !grepl("Prompt hashes, one per call|in 3 parts and one call", h))
    pa$st$fail_at = 0L
    pa$st$n = 0L
    session$setInputs(rerun = 2L)
    session$flushReact()
    h2 = html_of3(output$results)
    ok("the button's input runs that part again, and the page, the review and the round in the log are replaced by one with nothing missing",
       pa$st$n == 1L && pa$st$total == 1L && identical(st$review$status, "ok") && isTRUE(st$review$batches[[2]]$rerun) &&
         length(st$rounds) == 1L && all(purrr::map_chr(st$rounds[[1]]$summary, "status") == "ok") &&
         !grepl("Part of the review did not come back", h2, fixed = TRUE) && grepl("Question Q20", h2, fixed = TRUE) &&
         !grepl("Run this part again", h2, fixed = TRUE))
  })
})


# ---- Phase 5c: the output, built without a browser -----------------------------------------------

out_time <- as.POSIXct("2026-11-12 09:30:00", tz = "UTC")
out_models <- list(pm = fl_pm, workers = fl_workers)
plain_of <- function(x) gsub("\\s+", " ", gsub("<[^>]+>", " ", paste(as.character(x), collapse = " ")))

# A drafting run with the kind of items a model really writes: more than it is asked for (an
#   introduction, parts, programming notes, decisions, notes), which the screen and the copy never show.
rich_item <- function(n, who) list(
  id = paste0("CONF", n), domain = "Trust in the commission",
  intro = if (n == 1L) "ZZ-INTRO-NOT-SHOWN" else "",
  stem = paste0("How much do you trust the national electoral commission? (model ", who, ")"),
  options = list("A lot", "Somewhat", "A little", "Not at all"), open_format = "",
  parts = if (n == 2L) list(list(when = "if the answer is A little or Not at all", stem = "ZZ-PART-NOT-SHOWN", options = list())) else list(),
  programming = if (n == 1L) "ZZ-PROGRAMMING-NOT-SHOWN" else "",
  decisions = list("ZZ-DECISION-NOT-SHOWN"),
  notes = "ZZ-NOTES-NOT-SHOWN")
rich_draft <- function(m) list(items = list(rich_item(1L, worker_no(m)), rich_item(2L, worker_no(m))),
                               not_covered = list(), missing_from_brief = list())
fr_form <- clean_form(with_field(fl_form, country = "Kenya"))
fr_appraisal <- list(
  selected = list(list(domain = "trust", candidate = "A", id = "CONF1", check_before_use = "The word trust may mean different things. Say whose trust."),
                  list(domain = "trust again", candidate = "C", id = "CONF2", check_before_use = "")),
  limits = "ZZ-LIMITS-NOT-SHOWN")
fr_ask <- rec_ask(function(m, sys) if (identical(m$id, fl_pm$id)) { if (is_brief(sys)) brief_ok else fr_appraisal } else rich_draft(m))
fr_brief <- run_brief(fr_form, fl_pm, ask = fr_ask$ask)
fr_drafts <- run_drafts(fr_form, fl_workers, ask = fr_ask$ask)
fr_ap <- run_appraisal(fr_form, fr_drafts, fl_pm, ask = fr_ask$ask, seed = 11L)
fr_labels <- labels_of(fr_drafts, 11L)
fr_set <- initial_set(check_appraisal(fr_ap$reply, candidates_of(fr_drafts, 11L)))
fr_approved <- c(attr(fr_drafts, "prompt"), list(edited = FALSE, original_hash = attr(fr_drafts, "prompt")$hash))
fr_chosen <- final_set(fr_set, list(), fr_drafts, 11L)
fr_out <- build_output(fr_form, drafts = fr_drafts, seed = 11L, set = fr_set, time = out_time)
fr_txt <- fr_out$text
fr_html <- paste(as.character(fr_out$html), collapse = "")
fr_footer <- doc_text(output_footer(out_time))

ok("a drafting output has the questions of the set in its order, each with its number, the question and its numbered options, and the one line to check on the first",
   identical(fr_out$kind, "draft") && fr_out$n_items == 2L &&
     regexpr("Question 1\n", fr_txt, fixed = TRUE) < regexpr("Question 2\n", fr_txt, fixed = TRUE) &&
     grepl("\n1. A lot\n2. Somewhat\n3. A little\n4. Not at all", fr_txt, fixed = TRUE) &&
     grepl(paste0("(model ", match(fr_labels[["A"]], fl_ids), ")"), fr_txt, fixed = TRUE) &&
     grepl(paste0("(model ", match(fr_labels[["C"]], fl_ids), ")"), fr_txt, fixed = TRUE) &&
     !grepl(paste0("(model ", match(fr_labels[["B"]], fl_ids), ")"), fr_txt, fixed = TRUE) &&
     n_in3("Check before use: ", fr_txt) == 1L && grepl("Check before use: The word trust may mean different things.", fr_txt, fixed = TRUE) &&
     !grepl("Say whose trust", fr_txt, fixed = TRUE) &&
     regexpr("Check before use", fr_txt, fixed = TRUE) < regexpr("Question 2\n", fr_txt, fixed = TRUE))
ok("nothing else of a question or of the reply is in the output: no id, domain, introduction, filter question, programming, decision, note, reason, limits, model, hash or disclosure",
   !grepl("ZZ-|CONF1|CONF2|Trust in the commission|Disclosure|vendor-|Profile|reflex|Reflex|Prompt|hash", fr_txt))
ok("the output opens with the one sentence and ends with the three lines: the date, who drafted and who reviewed, and the version of the tool; and the copy is exactly the screen's text and those lines",
   startsWith(fr_txt, "These are drafts. Test them with real respondents before fielding.") &&
     endsWith(fr_txt, "Date: 2026-11-12\n\nDrafted with QuestionR, an AI tool; reviewed by [analyst to complete]\n\nQuestionR version 0.9") &&
     identical(fr_txt, paste(fr_out$screen_text, fr_footer, sep = "\n\n")) &&
     !grepl("Date:|Drafted with QuestionR|QuestionR version", fr_out$screen_text) &&
     identical(QUESTIONR_VERSION, "0.9"))
ok("the HTML is plain: headings, paragraphs, an ordered list of options that Word keeps numbered, emphasis for the line to check",
   grepl("<ol>", fr_html, fixed = TRUE) && grepl("<li>A lot</li>", fr_html, fixed = TRUE) &&
     grepl("<em>Check before use:", fr_html, fixed = TRUE) && !grepl("<blockquote>", fr_html, fixed = TRUE) &&
     !grepl("<script|<style|style=|class=", fr_html) && !grepl("<table", fr_html, fixed = TRUE))
ok("the HTML and the plain text say the same: every line of the text is in the HTML's text, in the same order",
   local({
     lines = trimws(strsplit(fr_txt, "\n", fixed = TRUE)[[1]])
     lines = sub("^([0-9]+\\. |- )", "", lines[nzchar(lines) & !grepl("^(=+|-+)$", lines)])
     h = plain_of(fr_html)
     # each line is looked for after the end of the one before it
     end = purrr::reduce(lines, function(at, l) {
       if (is.na(at)) return(NA_integer_)
       l = gsub("\\s+", " ", l)
       p = regexpr(l, substring(h, at + 1L), fixed = TRUE)[[1]]
       if (p < 0L) NA_integer_ else at + p - 1L + nchar(l)
     }, .init = 0L)
     !is.na(end) && length(lines) > 10L
   }))

# The record: what is not on the screen, in one file (DESIGN.md section 18).
reflex_versions <- function(files) purrr::map_chr(files, function(x) paste0(x, " ", read_reflex_file(x)$version))
disc <- function(chosen = fr_chosen, approved = fr_approved, brief = fr_brief, drafts = fr_drafts, form = fr_form)
  doc_text(disclosure_blocks(form, chosen, drafts, fr_ap, NULL, brief, approved, models = out_models, time = out_time))
fr_disc <- disc()
ok("the disclosure, which now goes in the record, names the date, the profile, the project manager and each worker model by its id, and which models were asked but did not draft",
   grepl("Date: 2026-11-12 09:30", fr_disc, fixed = TRUE) && grepl(paste0("Profile: ", APP_PROFILE), fr_disc, fixed = TRUE) &&
     grepl("Project manager model: vendor-p/pm-model (example.invalid)", fr_disc, fixed = TRUE) &&
     all(purrr::map_lgl(fl_ids, function(id) grepl(id, fr_disc, fixed = TRUE))) &&
     !grepl("asked that returned no usable draft", fr_disc, fixed = TRUE) &&
     grepl("returned no usable draft: vendor-b/model-two, vendor-c/model-three", {
       bad = run_drafts(fr_form, fl_workers, ask = rec_ask(function(m, sys) if (identical(m$id, "vendor-a/model-one")) rich_draft(m) else stop("down", call. = FALSE))$ask)
       disc(chosen = final_set(list(set_entry("A", 1L, "CONF1")), list(), bad, 11L), drafts = bad)
     }, fixed = TRUE))
ok("the disclosure gives the version of each reflex file used, and pm_brief.md only when the brief was checked",
   grepl(paste0("Reflex files and versions: ", paste(reflex_versions(c("core.md", "generate.md", "attitudinal.md", "mode.md", "cross_cultural.md", "pm_appraise.md", "pm_brief.md")), collapse = "; ")),
         fr_disc, fixed = TRUE) &&
     !grepl("pm_brief.md", disc(brief = NULL), fixed = TRUE) &&
     !grepl("cross_cultural.md", disc(form = clean_form(fl_form)), fixed = TRUE))
ok("the disclosure gives each prompt's hash in full, says the drafting prompt was not edited, and says it was when it was",
   grepl(paste0("Brief check prompt: ", fr_brief$hash), fr_disc, fixed = TRUE) &&
     grepl(paste0("Drafting prompt (not edited): ", fr_approved$hash), fr_disc, fixed = TRUE) &&
     grepl(paste0("Appraisal prompt: ", fr_ap$hash), fr_disc, fixed = TRUE) &&
     local({
       ed = c(with_field(fr_approved, user = "EDITED", hash = prompt_hash(fr_approved$system, "EDITED")), list())
       ed$edited = TRUE
       t = disc(approved = ed)
       grepl(paste0("Drafting prompt as sent (edited by the analyst): ", ed$hash), t, fixed = TRUE) &&
         grepl(paste0("Drafting prompt as assembled: ", fr_approved$original_hash), t, fixed = TRUE)
     }))
ok("the disclosure says which candidate each item of the set came from and the model behind it, and ends with the fixed line",
   grepl(paste0("Item 1 (CONF1): candidate A, written by ", fr_labels[["A"]]), fr_disc, fixed = TRUE) &&
     grepl(paste0("Item 2 (CONF2): candidate C, written by ", fr_labels[["C"]]), fr_disc, fixed = TRUE) &&
     endsWith(fr_disc, "Expert-review appraisal and first drafts by language models. Not a pretest. Test with real respondents before fielding.") &&
     identical(DISCLOSURE_LINE, "Expert-review appraisal and first drafts by language models. Not a pretest. Test with real respondents before fielding."))
ok("the output takes the set as the analyst left it: an edited question has its new wording, and the record says which items were edited and which were swapped in",
   local({
     st_set = c(fr_set[1], list(set_entry("B", 1L, "CONF1", "x", swapped = TRUE)))
     ed = list(A_1 = list(stem = "An edited stem?", options = list(`2` = "Moderately")))
     o = build_output(fr_form, drafts = fr_drafts, seed = 11L, set = st_set, edits = ed, time = out_time)$text
     plain = build_output(fr_form, drafts = fr_drafts, seed = 11L, set = st_set, time = out_time)$text
     rec = disc(chosen = final_set(st_set, ed, fr_drafts, 11L))
     grepl("An edited stem?", o, fixed = TRUE) && grepl("\n2. Moderately\n", o, fixed = TRUE) && n_in3("Somewhat", o) == 1L &&
       !grepl("edited by the analyst|swapped in", o) && !grepl("An edited stem?", plain, fixed = TRUE) &&
       grepl("Item 1 (CONF1): candidate A, written by", rec, fixed = TRUE) && grepl("; edited by the analyst", rec, fixed = TRUE) &&
       grepl("Item 2 (CONF1): candidate B, written by", rec, fixed = TRUE) &&
       grepl("; swapped in by the analyst, not the reviewer's choice", rec, fixed = TRUE) &&
       n_in3("edited by the analyst", rec) == 1L
   }))
ok("with nothing in the set, or an entry that points at nothing, the output says so and has no three lines",
   local({
     none = build_output(fr_form, drafts = fr_drafts, seed = 11L, set = list(), time = out_time)
     stale = build_output(fr_form, drafts = fr_drafts, seed = 11L,
                          set = list(set_entry("Z", 1L, "x"), set_entry("A", 99L, "y")), time = out_time)
     grepl("There is no item in the set yet", none$text, fixed = TRUE) && none$n_items == 0L &&
       !grepl("Drafted with QuestionR", none$text, fixed = TRUE) && identical(stale$n_items, 0L) &&
       !grepl("There is no item in the set", build_output(fr_form, drafts = fr_drafts, seed = 11L, set = fr_set)$text, fixed = TRUE)
   }))

# A review: three questions, two to revise and one to keep, and a point about the whole.
ex_q <- paste("Q1. How satisfied are you with the recycling services and street cleaning provided by your council?",
              "Very satisfied / Fairly satisfied / Fairly dissatisfied / Very dissatisfied", "",
              "Q2. Do you agree that the council should spend more on libraries?", "Yes / No", "",
              "Q3. How often did you visit a library in the past 12 months?", "Never / Once or twice / Often", sep = "\n")
ex_form <- clean_form(with_field(forms$evaluate, questionnaire = ex_q))
ex_reply <- list(
  items = list(
    list(id = "Q1", verdict = "Revise", problems = list(
      list(problem = "Two services in one question.", rewrite = "How satisfied are you with the recycling services?"),
      list(problem = "Street cleaning could mean sweeping or litter bins.", rewrite = "How satisfied are you with street sweeping?"))),
    list(id = "Q2", verdict = "Revise", problems = list(
      list(problem = "The wording invites agreement.", rewrite = "Should the council spend more, the same or less on libraries?"))),
    list(id = "Q3", verdict = "Keep", problems = list())),
  instrument = list("Question 3 applies only to library users. Add a filter."))
ex_ask <- rv_ask(ex_reply)
ex_rv <- run_review(ex_form, fl_pm, ask = ex_ask$ask)
ex_approved <- c(build_prompt(ex_form), list(edited = FALSE, original_hash = build_prompt(ex_form)$hash))
ex_out <- build_output(ex_form, review = ex_rv, time = out_time)
ex_txt <- ex_out$text

ok("a review's output is the one sentence, then each question to revise with the question as pasted, the verdict, its problems and suggested rewrites, in the order pasted",
   identical(ex_out$kind, "review") && startsWith(ex_txt, "These are drafts. Test them with real respondents before fielding.") &&
     regexpr("Question Q1", ex_txt, fixed = TRUE) < regexpr("Question Q2", ex_txt, fixed = TRUE) &&
     grepl("Q1. How satisfied are you with the recycling services and street cleaning provided by your council?\nVery satisfied / Fairly satisfied",
           ex_txt, fixed = TRUE) &&
     n_in3("\n\nRevise\n", ex_txt) == 2L &&
     grepl("Problem: Two services in one question.\n\nSuggested rewrite: How satisfied are you with the recycling services?", ex_txt, fixed = TRUE) &&
     grepl("Problem: Street cleaning could mean sweeping or litter bins.", ex_txt, fixed = TRUE) &&
     n_in3("Problem: ", ex_txt) == 3L && n_in3("Suggested rewrite: ", ex_txt) == 3L)
ok("the question marked Keep is one line, the questionnaire as a whole follows, then the three lines; no severity, check, quote, band, test first, hash or disclosure",
   grepl("Question Q3: keep as written", ex_txt, fixed = TRUE) && !grepl("Question Q3\n", ex_txt, fixed = TRUE) &&
     regexpr("keep as written", ex_txt, fixed = TRUE) < regexpr("The questionnaire as a whole", ex_txt, fixed = TRUE) &&
     grepl("The questionnaire as a whole\n===", ex_txt, fixed = TRUE) && grepl("- Question 3 applies only to library users.", ex_txt, fixed = TRUE) &&
     !grepl("Add a filter", ex_txt, fixed = TRUE) &&
     endsWith(ex_txt, fr_footer) &&
     !grepl("severity|one_thing|Fix before fielding|Needs your judgment|Minor|test first|Disclosure|hash|worker", ex_txt, ignore.case = TRUE))
ok("a review in parts with a part missing says so at the top; no review gives a plain message",
   local({
     pa = parts_ask(fail_at = 2L)
     part_rv = run_review(long_form, fl_pm, ask = pa$ask)
     o = build_output(clean_form(long_form), review = part_rv, time = out_time)$text
     grepl("PART OF THE REVIEW IS MISSING: Part 2 of 3 did not come back", o, fixed = TRUE) &&
       regexpr("PART OF THE REVIEW IS MISSING", o, fixed = TRUE) < regexpr("Question Q1", o, fixed = TRUE) &&
       grepl("There is no review to show", build_output(ex_form, review = NULL)$text, fixed = TRUE)
   }))

# The record's disclosure for a review, with each prompt's hash.
ok("the record's disclosure for a review in parts lists a prompt hash for each call",
   local({
     pa = parts_ask()
     part_rv = run_review(long_form, fl_pm, ask = pa$ask)
     t = doc_text(disclosure_blocks(clean_form(long_form), list(), NULL, NULL, part_rv, NULL, NULL, models = out_models, time = out_time))
     all(purrr::map_lgl(part_rv$batches, function(b) grepl(b$hash, t, fixed = TRUE))) &&
       grepl("Review prompt, part 1 of 3: ", t, fixed = TRUE) && grepl("Review prompt, instrument as a whole: ", t, fixed = TRUE)
   }))

# The full record: schema, no key. A planted key string is scrubbed from the output and from the record.
key_planted <- "sk-planted-KEY-0123456789abcdef"
leaky_rounds <- list(flow_round(fr_form, fl_pm, brief = fr_brief, drafts = fr_drafts, appraisal = fr_ap, seed = 11L,
                                analyst = list(set = fr_set, edits = list(), final = final_set(fr_set, list(), fr_drafts, 11L))),
                     flow_round(ex_form, fl_pm, review = with_field(ex_rv, error = paste("echoed", key_planted))))
leaky_rounds[[1]]$drafts[[1]]$call$raw <- paste0("{\"echo\": \"", key_planted, "\"}")
log_txt <- run_log_json(leaky_rounds, profile = "home", time = out_time, secrets = c(key_planted, "short"),
                        disclosure = strsplit(fr_disc, "\n", fixed = TRUE)[[1]])
log_back <- jsonlite::fromJSON(log_txt, simplifyVector = FALSE)
ok("the full record is one JSON file with a schema, the version, the profile, the time, the disclosure and every round; what the analyst did with the set is in it",
   identical(log_back$schema, 1L) && identical(log_back$profile, "home") && length(log_back$rounds) == 2L &&
     identical(log_back$version, QUESTIONR_VERSION) &&
     grepl("^2026-11-12T", log_back$written) && identical(log_back$rounds[[1]]$schema, 1L) &&
     identical(purrr::map_chr(purrr::map(log_back$rounds[[1]]$analyst$final, "item"), "id"), c("CONF1", "CONF2")) &&
     !is.null(log_back$rounds[[1]]$drafts[[1]]$reply) && !is.null(log_back$rounds[[2]]$review$hash) &&
     any(grepl("Disclosure of the use of language models", unlist(log_back$disclosure), fixed = TRUE)) &&
     any(grepl(fr_ap$hash, unlist(log_back$disclosure), fixed = TRUE)))
ok("the record holds what the screen does not: every draft with its notes and decisions, and the reviewer's whole reply",
   grepl("ZZ-NOTES-NOT-SHOWN", log_txt, fixed = TRUE) && grepl("ZZ-DECISION-NOT-SHOWN", log_txt, fixed = TRUE) &&
     grepl("ZZ-LIMITS-NOT-SHOWN", log_txt, fixed = TRUE) && grepl("ZZ-PROGRAMMING-NOT-SHOWN", log_txt, fixed = TRUE))
ok("a planted key is absent from the record, which says where it was taken out, and a string too short to be a key is left alone",
   !grepl(key_planted, log_txt, fixed = TRUE) && grepl("[key removed]", log_txt, fixed = TRUE) &&
     identical(scrub_secrets("a short word", "short"), "a short word") &&
     identical(scrub_secrets(paste("x", key_planted, "y", key_planted), key_planted), "x [key removed] y [key removed]") &&
     identical(scrub_secrets("nothing here", character(0)), "nothing here"))
ok("no output text or HTML carries a planted key: it is not in the run's data, and scrub_secrets takes it out of anything that is",
   local({
     leak = ex_reply
     leak$items[[1]]$problems[[1]]$problem = paste("Echoed key", key_planted)
     lr = run_review(ex_form, fl_pm, ask = rv_ask(leak)$ask)
     o = build_output(ex_form, review = lr, time = out_time)
     grepl(key_planted, o$text, fixed = TRUE) &&
       !grepl(key_planted, scrub_secrets(o$text, key_planted), fixed = TRUE) &&
       !grepl(key_planted, scrub_secrets(paste(as.character(o$html), collapse = ""), key_planted), fixed = TRUE) &&
       !grepl(key_planted, fr_txt, fixed = TRUE) && !grepl(key_planted, fr_html, fixed = TRUE)
   }))
ok("known_keys gives the analyst's pasted key and a server key, none when there is none; the output and record functions never read a key themselves",
   local({
     st = test_state()
     got = NULL
     shiny::testServer(mod_key_server, args = list(state = st), {
       llm_set_session_key(key_planted)
       got <<- known_keys(list(pm = list(id = "p", api = "openai", base_url = "https://x.invalid/v1", key_source = "analyst"),
                               workers = list()))
     })
     identical(got, key_planted) && identical(known_keys(list(pm = list(id = "p", api = "openai", base_url = "https://x.invalid/v1",
                                                                         key_source = "analyst"), workers = list())), character(0)) &&
       !any(c("Sys.getenv", "llm_json", "llm_complete") %in% all.names(body(build_output))) &&
       !any(c("Sys.getenv", "llm_key_for") %in% all.names(body(run_log_json)))
   }))

# The two samples the Claude project reads, written by this test from the canned runs above.
writeLines(c(fr_txt, ""), file.path("tests", "output_generate.txt"), useBytes = TRUE)
writeLines(c(ex_txt, ""), file.path("tests", "output_review.txt"), useBytes = TRUE)
ok("the two sample outputs are saved as tests/output_generate.txt and tests/output_review.txt",
   file.exists(file.path("tests", "output_generate.txt")) && file.exists(file.path("tests", "output_review.txt")) &&
     grepl("Check before use:", paste(readLines(file.path("tests", "output_generate.txt"), encoding = "UTF-8"), collapse = "\n"), fixed = TRUE))


# The Output tab, over canned runs.
local({
  st = test_state()
  shiny::testServer(mod_output_server, args = list(state = st), {
    session$flushReact()
    ok("before anything has run, the Output tab says there is nothing to show and offers no download",
       grepl("Nothing to show yet", html_of3(output$view), fixed = TRUE) && is.null(output$downloads))
    llm_set_session_key(key_planted)
    st$form <- fr_form; st$drafts <- fr_drafts; st$appraisal <- fr_ap; st$seed <- 11L; st$brief <- fr_brief
    st$approved <- fr_approved; st$set <- list(); st$round <- 1L
    st$rounds <- list(leaky_rounds[[1]])
    session$flushReact()
    h0 = html_of3(output$view)
    ok("a drafting round with nothing in the set says there is no item in it",
       grepl("There is no item in the set yet", h0, fixed = TRUE) && !grepl("Drafted with QuestionR", h0, fixed = TRUE))
    st$set <- fr_set
    session$flushReact()
    h = html_of3(output$view)
    ok("the questions of the set are on the Output tab in HTML for Word, followed by the three lines, with one button and no plain text box",
       grepl("Question 1", h, fixed = TRUE) && grepl("<ol>", h, fixed = TRUE) &&
         grepl("These are drafts. Test them with real respondents before fielding.", h, fixed = TRUE) &&
         grepl("Drafted with QuestionR, an AI tool; reviewed by [analyst to complete]", h, fixed = TRUE) &&
         grepl("QuestionR version 0.9", h, fixed = TRUE) && grepl("Date: ", h, fixed = TRUE) &&
         !grepl("<textarea", h, fixed = TRUE) && !grepl("Disclosure of the use", h, fixed = TRUE) && !grepl(fr_ap$hash, h, fixed = TRUE) &&
         n_in3("Copy for Word", h) == 1L && !grepl("Copy plain text", h, fixed = TRUE) && grepl("execCommand", h, fixed = TRUE))
    ok("every line of what build_output() gives (the screen's text and the three lines) is on the Output tab, in order",
       local({
         want = trimws(strsplit(sub("Date: [0-9-]+", "Date: D", build_output(fr_form, drafts = fr_drafts, seed = 11L, set = fr_set)$text),
                                "\n", fixed = TRUE)[[1]])
         want = sub("^([0-9]+\\. |- )", "", want[nzchar(want) & !grepl("^(=+|-+)$", want)])
         page_txt = gsub("\\s+", " ", sub("Date: [0-9-]+", "Date: D", plain_of(h)))
         end = purrr::reduce(want, function(at, l) {
           if (is.na(at)) return(NA_integer_)
           l = gsub("\\s+", " ", l)
           p = regexpr(l, substring(page_txt, at + 1L), fixed = TRUE)[[1]]
           if (p < 0L) NA_integer_ else at + p - 1L + nchar(l)
         }, .init = 0L)
         !is.na(end) && length(want) > 10L
       }))
    st$set <- fr_set[1]
    session$flushReact()
    ok("taking a question out of the set takes it off the Output tab",
       !grepl("Question 2", html_of3(output$view), fixed = TRUE) && grepl("Question 1", html_of3(output$view), fixed = TRUE))
    st$set <- fr_set
    session$flushReact()
    ok("the one download is the full record, in one small button, and the page says what is in it",
       n_in3("Download the full record", html_of3(output$downloads)) == 1L && grepl("btn-sm", html_of3(output$downloads), fixed = TRUE) &&
         !grepl("plain text|run log", html_of3(output$downloads), ignore.case = TRUE) &&
         grepl("Prompts, models, hashes, every draft and the full reply", html_of3(output$downloads), fixed = TRUE))
    log_file = output$get_log
    log = jsonlite::fromJSON(paste(readLines(log_file, encoding = "UTF-8", warn = FALSE), collapse = "\n"), simplifyVector = FALSE)
    ok("the record download is JSON with a schema, the round, the disclosure with each prompt's hash, and the analyst's final items",
       identical(log$schema, 1L) && length(log$rounds) == 1L &&
         identical(purrr::map_chr(purrr::map(log$rounds[[1]]$analyst$final, "item"), "id"), c("CONF1", "CONF2")) &&
         any(grepl("Disclosure of the use of language models", unlist(log$disclosure), fixed = TRUE)) &&
         any(grepl(fr_ap$hash, unlist(log$disclosure), fixed = TRUE)) && any(grepl("Item 1 (CONF1)", unlist(log$disclosure), fixed = TRUE)))
    ok("a key in the session, and echoed in a model's reply, is in neither the page nor the record download",
       key_planted %in% known_keys() &&
         grepl(key_planted, leaky_rounds[[1]]$drafts[[1]]$call$raw, fixed = TRUE) &&
         !grepl(key_planted, h, fixed = TRUE) &&
         !grepl(key_planted, paste(readLines(log_file, encoding = "UTF-8", warn = FALSE), collapse = "\n"), fixed = TRUE) &&
         grepl("[key removed]", paste(readLines(log_file, encoding = "UTF-8", warn = FALSE), collapse = "\n"), fixed = TRUE))
  })
})
local({
  st = test_state()
  st$form <- ex_form; st$review <- ex_rv; st$approved <- ex_approved; st$round <- 1L
  st$rounds <- list(flow_round(ex_form, fl_pm, review = ex_rv))
  shiny::testServer(mod_output_server, args = list(state = st), {
    session$flushReact()
    h = html_of3(output$view)
    ok("a review's Output tab shows the questions to revise with their problems and rewrites, the Keep line and the three lines, and no bands or disclosure",
       grepl("Question Q1", h, fixed = TRUE) && grepl("Problem: Two services in one question.", h, fixed = TRUE) &&
         grepl("Question Q3: keep as written", h, fixed = TRUE) && grepl("QuestionR version 0.9", h, fixed = TRUE) &&
         !grepl("Fix before fielding|Needs your judgment|Minor|Disclosure of the use of language models|Keep this item", h))
    log = jsonlite::fromJSON(paste(readLines(output$get_log, encoding = "UTF-8", warn = FALSE), collapse = "\n"), simplifyVector = FALSE)
    ok("the review's record has its round, its prompt hash, its call record and its disclosure",
       identical(log$rounds[[1]]$review$hash, ex_rv$hash) && !is.null(log$rounds[[1]]$review$call$seconds) &&
         identical(purrr::map_chr(log$rounds[[1]]$summary, "step"), "review") &&
         any(grepl(paste0("Review prompt (not edited): ", ex_rv$hash), unlist(log$disclosure), fixed = TRUE)))
  })
})
ok("the page has the Output tab's boxes in place of its placeholder, and no key is anywhere on it",
   grepl("output-view", page$html, fixed = TRUE) && grepl("output-downloads", page$html, fixed = TRUE) &&
     !grepl(key_planted, page$html, fixed = TRUE))

# ---- Phase 7c: Start here and Methodology are their files ------------------------------------------

# Every heading of a markdown file, as the page draws it.
md_headings <- function(path) {
  l = readLines(path, encoding = "UTF-8", warn = FALSE)
  trimws(sub("^#+ ", "", l[grepl("^#+ ", l)]))
}
md_has_headings <- function(path, html) all(purrr::map_lgl(md_headings(path), function(h)
  grepl(paste0(">", gsub("[()]", "", h)), gsub("[()]", "", html), fixed = TRUE)))
start_html <- paste(as.character(start_ui()), collapse = "\n")
ok("Start here is www/start.md as it is, then the key box, then a closed Settings and connection panel that holds the profile, the models table with the connection check, and the pilot notice",
   md_has_headings(START_FILE, start_html) && grepl("<ol>", start_html, fixed = TRUE) &&
     grepl("<strong>Describe what you need.</strong>", start_html, fixed = TRUE) &&
     grepl("Paste your API key below.", start_html, fixed = TRUE) &&
     regexpr("What QuestionR is for", start_html, fixed = TRUE) < regexpr("Paste your API key below.", start_html, fixed = TRUE) &&
     regexpr("Paste your API key below.", start_html, fixed = TRUE) < regexpr("Use this key", start_html, fixed = TRUE) &&
     regexpr("Use this key", start_html, fixed = TRUE) < regexpr("<summary>\\s*<strong>Settings and connection", start_html) &&
     regexpr("<summary>\\s*<strong>Settings and connection", start_html) < regexpr("This is a pilot", start_html, fixed = TRUE) &&
     regexpr("This is a pilot", start_html, fixed = TRUE) < regexpr("id=\"connect-check\"", start_html, fixed = TRUE) &&
     grepl("<details[^>]*>\\s*<summary>\\s*<strong>Settings and connection", start_html) &&
     !grepl("<details[^>]*open[^>]*>\\s*<summary>\\s*<strong>Settings and connection", start_html) &&
     grepl("id=\"connect-models\"", start_html, fixed = TRUE) &&
     grepl("OpenAI-style API at https://openrouter.ai/api/v1", paste(as.character(model_label(APP_MODELS$workers[[1]])), collapse = ""), fixed = TRUE) &&
     grepl(paste0("<td>", APP_PROFILE, "</td>"), start_html, fixed = TRUE) &&
     grepl("It found 36 of the 48 faults (75 percent)", gsub("\\s+", " ", start_html), fixed = TRUE) &&
     grepl("so treat it as a guide, not a guarantee", gsub("\\s+", " ", start_html), fixed = TRUE) &&
     grepl("Settings and connection", page$html, fixed = TRUE) && grepl("What QuestionR is for", page$html, fixed = TRUE))
ok("a profile with placeholders opens the Settings and connection panel by itself",
   local({
     work_open = in_child("work", c("app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
                                    "cat(paste(as.character(start_ui()), collapse = ''))"))
     work_open$status == 0 && grepl("<details[^>]*open[^>]*>\\s*<summary>\\s*<strong>Settings and connection", work_open$out)
   }))
meth_html <- paste(as.character(md_page(METHODOLOGY_FILE)), collapse = "\n")
ok("the Methodology tab is www/methodology.md as it is: its headings and its table, and nothing else; reflexes_table() stays, because tests/review.R reads it",
   md_has_headings(METHODOLOGY_FILE, meth_html) && grepl("<table", meth_html, fixed = TRUE) &&
     grepl("36 of the 48 planted faults|It found 36 of the 48 faults", meth_html) && !grepl("<code>", meth_html, fixed = TRUE) &&
     !grepl("The rules, file by file", meth_html, fixed = TRUE) && grepl("Methodology", page$html, fixed = TRUE) &&
     grepl("How QuestionR works and what stands behind it", page$html, fixed = TRUE) &&
     is.data.frame(reflexes_table()) && nrow(reflexes_table()) > 80L && !"reflexes_html" %in% ls(globalenv()) &&
     grepl("could not be shown", paste(as.character(md_page(file.path("www", "no_such_page.md"))), collapse = ""), fixed = TRUE))

# ---- Phase 9d and 9e: Total Survey Error first, the worked example, the shortened note ------------

meth_lines <- readLines(METHODOLOGY_FILE, encoding = "UTF-8", warn = FALSE)
meth_heads <- sub("^## ", "", grep("^## ", meth_lines, value = TRUE))
meth_sections <- function(heading) {
  at = which(meth_lines == paste0("## ", heading))
  end = min(c(which(grepl("^## ", meth_lines) & seq_along(meth_lines) > at), length(meth_lines) + 1L))
  meth_lines[(at + 1L):(end - 1L)]
}
n_sentences <- function(txt) length(strsplit(gsub("\\s+", " ", trimws(txt)), "(?<=[.?!])\\s+", perl = TRUE)[[1]])
ok("the note opens with Total Survey Error (fw_tse.svg), directly before 'What it is built on'; it names the errors QuestionR works on and those it does not",
   identical(meth_heads[1:2], c("Total Survey Error", "What it is built on")) &&
     identical(meth_lines[1], "# How QuestionR works and what stands behind it") &&
     grepl("\\(fw_tse\\.svg\\)$", meth_sections("Total Survey Error")[2]) &&
     grepl("QuestionR works on validity and measurement error", gsub("\\s+", " ", paste(meth_sections("Total Survey Error"), collapse = " "))) &&
     grepl("does not work on coverage, sampling or nonresponse", gsub("\\s+", " ", paste(meth_sections("Total Survey Error"), collapse = " "))))
ok("the note keeps its sections, in this order, and 'How it was tested' is one section with that exact heading",
   identical(meth_heads, c("Total Survey Error", "What it is built on", "From construct to question",
                           "One question, three ways to go wrong", "The response model",
                           "Testing questions, and where AI fits", "What it cannot do", "How it was tested",
                           "The AI reflexes behind every answer")))
ok("each framework section is a diagram, then a short summary, then an italic line of references; the worked example is three sentences and cites the slide",
   local({
     fw = purrr::keep(meth_heads, function(h) any(grepl("^!\\[", meth_sections(h))))
     ex = meth_sections("One question, three ways to go wrong")
     ex = ex[nzchar(trimws(ex))]
     purrr::every(fw, function(h) {
       s = meth_sections(h)
       body = s[nzchar(trimws(s))]
       summary_txt = paste(body[-c(1, length(body))], collapse = " ")
       grepl("^!\\[.+\\]\\(fw_[a-z]+\\.svg\\)$", body[1]) && grepl("^\\*[^*]+\\*$", body[length(body)]) &&
         n_sentences(summary_txt) >= 2L && n_sentences(summary_txt) <= 5L
     }) && length(fw) == 5L &&
       n_sentences(paste(ex[-c(1, length(ex))], collapse = " ")) == 3L &&
       grepl("(fw_example.svg)", ex[1], fixed = TRUE) &&
       identical(ex[length(ex)], "*Ting Yan, Fundamentals of Questionnaire Design, IASS/WSS Webinar Session 1*")
   }))
ok("the note is under 600 words outside the reflex table and the panels (image descriptions not counted)",
   local({
     txt = meth_lines[!grepl("^\\|", meth_lines)]
     txt = gsub("!\\[[^]]*\\]\\([^)]*\\)", "", txt)
     length(strsplit(paste(txt, collapse = " "), "\\s+")[[1]]) < 600L
   }))
ok("the worked example's diagram has the slide's question word for word, its three parts marked, and the three errors and validity named; the Sensitive and TRAPD diagrams are gone",
   local({
     d = paste(readLines(file.path("www", "fw_example.svg"), encoding = "UTF-8", warn = FALSE), collapse = "\n")
     grepl("Last week,", d, fixed = TRUE) &&
       grepl("did you work full-time, part-time, or did you not work at all?", d, fixed = TRUE) &&
       all(purrr::map_lgl(c("reference period", "the concept", "answer options", "specification error", "operationalization error", "response error", "Validity"),
                          function(p) grepl(p, d, fixed = TRUE))) &&
       !file.exists(file.path("www", "fw_sensitive.svg")) && !file.exists(file.path("www", "fw_trapd.svg"))
   }))

ok("every .svg in www/ is well-formed XML with a title and a description, and no script",
   local({
     svgs = list.files("www", pattern = "\\.svg$", full.names = TRUE)
     length(svgs) >= 6L && purrr::every(svgs, function(p) {
       d = tryCatch(xml2::read_xml(p), error = function(e) NULL)
       !is.null(d) && identical(xml2::xml_name(d), "svg") &&
         length(xml2::xml_find_all(d, "//*[local-name()='title']")) == 1L &&
         length(xml2::xml_find_all(d, "//*[local-name()='desc']")) == 1L &&
         length(xml2::xml_find_all(d, "//*[local-name()='script']")) == 0L
     })
   }))
ok("every image named in start.md and methodology.md exists in www/",
   local({
     imgs = unlist(purrr::map(c(START_FILE, METHODOLOGY_FILE), function(p) {
       txt = paste(readLines(p, encoding = "UTF-8", warn = FALSE), collapse = "\n")
       sub("\\)$", "", sub("^!\\[[^]]*\\]\\(", "", regmatches(txt, gregexpr("!\\[[^]]*\\]\\([^)]+\\)", txt))[[1]]))
     }))
     length(imgs) >= 6L && all(file.exists(file.path("www", imgs)))
   }))

# The Frameworks column of the reflex table: which of the five frameworks a reflex file's Source lines
#   name, by the rule below; none of them is "Session guidelines".
fw_rules <- c("Total Survey Error" = "Groves|Total Survey Error",
              "Response model" = "Tourangeau, Rips and Rasinski|response-process|response process|four-stage",
              "Construct and decomposition" = "specification and operationalization error|Fig\\. 1\\.1",
              "Testing methods" = "testing methods|cognitive interviews")
fw_of <- function(file) {
  src = sub("^- \\*\\*Source:\\*\\*[ \\t]*", "", grep("^- \\*\\*Source:\\*\\*", readLines(file.path("www", "reflexes", file), encoding = "UTF-8", warn = FALSE), value = TRUE))
  hit = names(fw_rules)[vapply(fw_rules, function(p) any(grepl(p, src)), NA)]
  if (length(hit)) paste(hit, collapse = "; ") else "Session guidelines"
}
ok("the Frameworks column of the reflex table is what each file's Source lines name, in the order of the panels",
   local({
     rows = grep("^\\| ", meth_lines, value = TRUE)
     rows = rows[-1]   # the header
     cells = purrr::map_chr(rows, function(r) trimws(utils::tail(strsplit(r, "|", fixed = TRUE)[[1]], 1)))
     length(cells) == length(REFLEX_PANEL_ORDER) &&
       identical(cells, unname(purrr::map_chr(REFLEX_PANEL_ORDER, fw_of)))
   }))

meth_panels <- paste(as.character(reflex_panels()), collapse = "\n")
ok("under the Methodology page, one closed panel for each reflex file, in the order of the table, titled with the file's heading and version, holding the file as markdown without its comments, and not the README",
   local({
     heads = gsub("\\s+", " ", regmatches(meth_panels, gregexpr("<summary>\\s*<strong>[^<]+</strong>\\s*</summary>", meth_panels))[[1]])
     want = purrr::map_chr(REFLEX_PANEL_ORDER, function(f) { s = read_reflex_file(f); paste0("<summary> <strong>", s$title, ", version ", s$version, "</strong> </summary>") })
     comments = unlist(purrr::map(REFLEX_PANEL_ORDER, function(f) regmatches(paste(readLines(file.path(REFLEXES_DIR, f), encoding = "UTF-8", warn = FALSE), collapse = "\n"),
                                                                           gregexpr("(?s)<!--.*?-->", paste(readLines(file.path(REFLEXES_DIR, f), encoding = "UTF-8", warn = FALSE), collapse = "\n"), perl = TRUE))[[1]]))
     identical(heads, want) && length(gregexpr("<details", meth_panels, fixed = TRUE)[[1]]) == 10L &&
       !grepl("<details[^>]*open", meth_panels) && !grepl("<!--", meth_panels, fixed = TRUE) &&
       grepl("construct_first", meth_panels, fixed = TRUE) && grepl("You are a senior survey methodologist", meth_panels, fixed = TRUE) &&
       !any(purrr::map_lgl(trimws(gsub("<!--|-->", "", comments)), function(cm) grepl(substr(gsub("\\s+", " ", cm), 1, 60), gsub("\\s+", " ", meth_panels), fixed = TRUE))) &&
       !grepl("QuestionR reflexes", meth_panels, fixed = TRUE) &&
       grepl("could not be shown", paste(as.character(reflex_panels(file.path("www", "no_such_dir"))), collapse = ""), fixed = TRUE) &&
       any(grepl("reflex_panels()", readLines("app.R", warn = FALSE), fixed = TRUE))
   }))


# ---- Phase 6c: Start here says what is in force; the notices ---------------------------------

ok("a profile that still holds placeholders says which entries to fill in, the connection check does not call it, and the work profile's page builds; a filled profile says nothing",
   local({
     ms = list(list(role = "Project manager", m = list(api = "anthropic", base_url = "<work base url>", id = "<pm id at work>",
                                                      key_source = "analyst")),
               list(role = "Worker 1", m = list(api = "openai", base_url = "<work base url>", id = "<worker id at work>",
                                                key_source = "analyst")))
     h = paste(as.character(placeholder_notice(ms)), collapse = "")
     ping = llm_ping(ms[[1]]$m, key = "a-key", complete = function(...) stop("the call must not be made"))
     work_page = in_child("work", c("app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
                                    "cat(paste(as.character(start_ui()), collapse = ''))"))
     grepl("profile still has placeholders to fill in", h, fixed = TRUE) &&
       grepl("Project manager (&lt;pm id at work&gt;): base_url, id", h, fixed = TRUE) &&
       grepl("Worker 1 (&lt;worker id at work&gt;): base_url, id", h, fixed = TRUE) &&
       identical(llm_placeholders(ms[[2]]$m), c("base_url", "id")) &&
       isFALSE(ping$ok) && grepl("Not set up: base_url, id", ping$message, fixed = TRUE) &&
       work_page$status == 0 && grepl("still has placeholders", work_page$out, fixed = TRUE) &&
       is.null(placeholder_notice(llm_models())) && !grepl("placeholders to fill in", paste(as.character(start_ui()), collapse = ""), fixed = TRUE)
   }))


# ---- Phase 7b: calls go out together ------------------------------------------------------------

# The workers' drafts are asked for in one batch; one failure does not lose the others.
local({
  batches = list()
  asked_alone = 0L
  all_fake = function(requests) {
    batches[[length(batches) + 1L]] <<- requests
    purrr::imap(requests, function(r, i)
      if (i == 2L) simpleError("canned worker failure")
      else list(obj = tagged_draft(r$m), raw = "{}", finish = "stop", tokens = c(input = 10, output = 20, cached_input = 0),
                attempts = 1L, seconds = 5 + i))
  }
  d = run_drafts(fl_form, fl_workers, ask = function(...) { asked_alone <<- asked_alone + 1L; stop("not by ask") }, ask_all = all_fake)
  ok("the workers' drafts are requested in one batch, each request the arguments ask takes, in the workers' order, and ask is not used",
     length(batches) == 1L && length(batches[[1]]) == 3L && asked_alone == 0L &&
       identical(purrr::map_chr(batches[[1]], function(r) r$m$id), fl_ids) &&
       all(purrr::map_lgl(batches[[1]], function(r) setequal(names(r), c("user", "m", "system_prompt", "max_tokens", "validate")))) &&
       all(purrr::map_int(batches[[1]], "max_tokens") == LLM_MAX_TOKENS[["draft"]]) &&
       identical(batches[[1]][[1]]$user, build_prompt(fl_form)$user))
  ok("one worker failing is recorded with its reason and the other two are kept; a call's own seconds are used when the reply gives them",
     identical(purrr::map_chr(d, "status"), c("ok", "failed", "ok")) && identical(d[[2]]$error, "canned worker failure") &&
       is.null(d[[2]]$reply) && identical(d[[1]]$reply, tagged_draft(fl_workers[[1]])) &&
       identical(d[[3]]$reply, tagged_draft(fl_workers[[3]])) &&
       identical(c(d[[1]]$seconds, d[[3]]$seconds), c(6, 8)) && isTRUE(attr(d[[1]], "call")$tokens$output == 20))
  ok("an ask_all that fails as a whole fails every worker and nothing else; with only ask given, the requests are answered one after the other through it",
     identical(purrr::map_chr(run_drafts(fl_form, fl_workers, ask = llm_json, ask_all = function(r) stop("batch down")), "status"),
               rep("failed", 3)) &&
       local({
         fa2 = rec_ask(function(m, sys) tagged_draft(m))
         d2 = run_drafts(fl_form, fl_workers, ask = fa2$ask)
         identical(purrr::map_chr(fa2$st$calls, "id"), fl_ids) && all(purrr::map_chr(d2, "status") == "ok")
       }) && identical(ask_all_for(llm_json), llm_json_all))
})

# The parts of a long review go out together, at most four at a time, then the instrument call.
local({
  small = 700
  old = get("APP_BATCH_CHARS", globalenv())
  assign("APP_BATCH_CHARS", small, globalenv())
  on.exit(assign("APP_BATCH_CHARS", old, globalenv()), add = TRUE)
  n_parts = length(split_questionnaire(long_text, small))
  run = function(fail_at = 0L) {
    pa = parts_ask(fail_at = fail_at)
    sizes = integer(0)
    said = character(0)
    rv = run_review(long_form, fl_pm, ask = function(...) { sizes <<- c(sizes, 1L); pa$ask(...) },
                    ask_all = function(requests) {
                      sizes <<- c(sizes, length(requests))
                      purrr::map(requests, function(r) tryCatch(do.call(pa$ask, r), error = function(e) e))
                    }, progress = function(msg) said <<- c(said, msg))
    list(rv = rv, sizes = sizes, said = said, pa = pa)
  }
  r = run()
  ok("the parts are requested in batches of at most four, in order, then one instrument call by ask; the review is as ordered as before",
     n_parts == 15L && identical(r$sizes, c(4L, 4L, 4L, 3L, 1L)) && r$pa$st$n == 16L &&
       identical(r$rv$status, "ok") && identical(purrr::map_chr(r$rv$reply$items, "id"), paste0("Q", 1:30)) &&
       identical(purrr::map_chr(r$rv$batches, "kind"), c(rep("items", 15), "instrument")) &&
       identical(unname(purrr::map_int(r$rv$batches, "part")[1:15]), 1:15) && length(r$rv$reply$instrument) == 1L)
  ok("the page is told before each batch: parts 1 to 4 of 15 together, and so on to the instrument call",
     identical(r$said, c("Reviewing parts 1 to 4 of 15 together", "Reviewing parts 5 to 8 of 15 together",
                         "Reviewing parts 9 to 12 of 15 together", "Reviewing parts 13 to 15 of 15 together",
                         "Reviewing the questionnaire as a whole")))
  f = run(fail_at = 2L)
  ok("a part that fails in a batch is recorded and named, the other parts and the instrument call are kept, and it can be run again",
     identical(f$rv$status, "partial") && identical(purrr::map_chr(f$rv$batches, "status")[1:4], c("ok", "failed", "ok", "ok")) &&
       grepl("Part 2 of 15 did not come back", f$rv$error, fixed = TRUE) && f$pa$st$n == 16L && length(f$rv$reply$instrument) == 1L &&
       length(f$rv$reply$items) == 28L &&
       identical(rerun_review_part(long_form, fl_pm, f$rv, 2L, ask = parts_ask()$ask)$status, "ok"))
})

# A fake server that keeps each reply two seconds: requests sent together take about one wait, not their sum.
make_slow_mock <- function() {
  mock = webfakes::new_app()
  mock$use(webfakes::mw_json())
  mock$post("/v1/chat/completions", function(req, res) {
    if (is.null(res$locals$waited)) { res$locals$waited = TRUE; res$delay(2); return(invisible()) }
    if (identical(req$json$model, "m-missing"))
      return(res$set_status(404L)$send_json(list(error = list(message = "model not found")), auto_unbox = TRUE))
    res$send_json(list(id = "x", object = "chat.completion", created = 1L, model = req$json$model,
      choices = list(list(index = 0L, message = list(role = "assistant",
                                                     content = paste0("{\"answer\": \"from ", req$json$model, "\"}")),
                          finish_reason = "stop")),
      usage = list(prompt_tokens = 5L, completion_tokens = 7L, total_tokens = 12L)), auto_unbox = TRUE)
  })
  mock
}
local({
  px = webfakes::new_app_process(make_slow_mock(), opts = webfakes::server_opts(num_threads = 6))
  on.exit(px$stop())
  req = function(id, key = "k")
    list(user = "hi", m = list(api = "openai", base_url = px$url("/v1"), id = id, key_source = "analyst"), system_prompt = "S",
         max_tokens = 100L, validate = NULL, key = key)
  started = Sys.time()
  out = llm_json_all(list(req("m-one"), req("m-missing"), req("m-three"), req("m-nokey", key = NULL)))
  together = as.numeric(difftime(Sys.time(), started, units = "secs"))
  one = Sys.time()
  invisible(llm_json(req("m-one")$user, req("m-one")$m, system_prompt = "S", max_tokens = 100L, key = "k"))
  alone = as.numeric(difftime(Sys.time(), one, units = "secs"))
  ok("requests sent together through ellmer's chat_async and later::run_now take about one wait, not their sum, in the same R process",
     together < 2 * alone && together > 1.8 && alone > 1.8)
  ok("each answer comes back in the order sent, parsed, with its own seconds; a model the endpoint refuses and a request with no key are errors in their place and the others are kept",
     length(out) == 4L && identical(out[[1]]$obj$answer, "from m-one") && identical(out[[3]]$obj$answer, "from m-three") &&
       inherits(out[[2]], "llm_client_error") &&
       grepl("refused the request for m-missing (HTTP 404): model not found", conditionMessage(out[[2]]), fixed = TRUE) &&
       inherits(out[[4]], "llm_client_error") && grepl("There is no key for m-nokey", conditionMessage(out[[4]]), fixed = TRUE) &&
       out[[1]]$attempts == 1L && out[[1]]$seconds > 1.8 && out[[1]]$finish == "success")
  ok("the sending code uses only what ellmer and later document, never a package that starts other processes",
     !any(c("future", "furrr", "mirai", "parallel", "parallel_chat", "makeCluster") %in%
            all.names(c(body(llm_complete_all), body(llm_json_all)))) &&
       "chat_async" %in% all.names(body(llm_complete_all)) && "run_now" %in% all.names(body(llm_complete_all)))
})


# ---- Phase 9g: what the analyst can see, and what they cannot --------------------------------------

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
AI_SKILL_SENTENCE <- "QuestionR is an AI skill. It works from written AI reflexes: short rules of survey design that every model is given."

ok("the word skill is on no page except in its one sentence, once on Start here and once on the Methodology page",
   local({
     p = gsub("\\s+", " ", see_text(page$html))
     n_sentence = lengths(regmatches(p, gregexpr(AI_SKILL_SENTENCE, p, fixed = TRUE)))
     n_sentence == 2L && !grepl("skill", gsub(AI_SKILL_SENTENCE, "", p, fixed = TRUE), ignore.case = TRUE) &&
       lengths(regmatches(see_text(start_ui()), gregexpr(AI_SKILL_SENTENCE, see_text(start_ui()), fixed = TRUE))) == 1L &&
       lengths(regmatches(see_text(md_page(METHODOLOGY_FILE)), gregexpr(AI_SKILL_SENTENCE, see_text(md_page(METHODOLOGY_FILE)), fixed = TRUE))) == 1L
   }))

# Reflex files whose own words still name translation or an output language: not ours to edit in this
#   phase (evaluate.md and pm_brief.md; cross_cultural.md in its Source lines). Everything else is held
#   to none, and the count here cannot grow.
KNOWN_TRANSLATION_LEFTOVERS <- c(cross_cultural.md = 2L, evaluate.md = 4L, pm_brief.md = 1L)
translation_pattern <- "TRAPD|translat|output language|output_language|back-translat"
panel_html <- function(html, f) {
  sf = read_reflex_file(f)
  a = regexpr(paste0(sf$title, ", version ", sf$version), html, fixed = TRUE)[[1]]
  if (a < 0L) return("")
  from = max(gregexpr("<details", substr(html, 1L, a), fixed = TRUE)[[1]])
  to = a + regexpr("</details>", substring(html, a), fixed = TRUE)[[1]] + 8L
  substr(html, from, to)
}
ok("no page of the app names TRAPD, translation or an output language, and no form field is a language; the reflex files that still do are the three known ones, with a count that cannot grow",
   local({
     html = paste(page$html, collapse = " ")
     known = purrr::map_chr(names(KNOWN_TRANSLATION_LEFTOVERS), function(f) panel_html(html, f))
     rest = Reduce(function(h, k) if (nzchar(k)) sub(k, " ", h, fixed = TRUE) else h, known, html)
     others = purrr::map_chr(setdiff(REFLEX_PANEL_ORDER, names(KNOWN_TRANSLATION_LEFTOVERS)), function(f) panel_html(html, f))
     left = purrr::map_int(names(KNOWN_TRANSLATION_LEFTOVERS), function(f)
       sum(grepl(translation_pattern, readLines(file.path(REFLEXES_DIR, f), encoding = "UTF-8", warn = FALSE), ignore.case = TRUE)))
     names(left) = names(KNOWN_TRANSLATION_LEFTOVERS)
     all(nzchar(known)) && all(nzchar(others)) && length(others) == 7L &&
       !grepl(translation_pattern, see_text(rest), ignore.case = TRUE) &&
       !any(purrr::map_lgl(others, function(o) grepl(translation_pattern, see_text(o), ignore.case = TRUE))) &&
       !grepl("id=\"[^\"]*lang[^\"]*\"", html, ignore.case = TRUE) &&
       !any(grepl("lang", names(clean_form(forms$attitudinal)), ignore.case = TRUE)) &&
       all(left <= KNOWN_TRANSLATION_LEFTOVERS)
   }))

# A drafted question as the analyst sees it, and the Word copy of it.
local({
  st = flow_state()
  fa = rec_ask(reply_rich)
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) fa$ask), {
    session$flushReact()
    approve_state(st)
    session$flushReact()
    s = html_of3(output$set_ui)
    cards = regmatches(s, gregexpr("(?s)<div class=\"card mb-2\">.*?</div>\\s*</div>", s, perl = TRUE))[[1]]
    parts_of <- function(card) {
      t = gsub("(?s)<button.*?</button>", "", card, perl = TRUE)
      t = gsub("<input[^>]*>", "[box]", t)
      t = gsub("<[^>]+>", "\n", t)
      l = trimws(strsplit(t, "\n", fixed = TRUE)[[1]])
      l[nzchar(l)]
    }
    allowed <- function(l) grepl("^Question [0-9]+$", l) || identical(l, "[box]") || identical(l, CHECK_LABEL) ||
      grepl("^\\[Open question", l)
    ok("a drafted question on the screen has the question, its answer options, and at most one line to check before use, and nothing else; every one is checked, and there are cards to check",
       length(cards) >= 2L && all(purrr::map_lgl(cards, function(cd) {
         l = parts_of(cd)
         check_sentence = l[which(l == CHECK_LABEL) + 1L]
         extra = l[!purrr::map_lgl(l, allowed)]
         sum(l == CHECK_LABEL) <= 1L && length(setdiff(extra, check_sentence)) == 0L &&
           (!length(check_sentence) || length(strsplit(check_sentence, "\\s+")[[1]]) <= CHECK_WORDS)
       })))
    o = build_output(isolate(st$form), drafts = isolate(st$drafts), seed = isolate(st$seed), set = isolate(st$set), edits = isolate(st$edits))
    tail_lines = trimws(strsplit(substring(o$text, nchar(o$screen_text) + 1L), "\n", fixed = TRUE)[[1]])
    tail_lines = tail_lines[nzchar(tail_lines)]
    ok("the Word copy of drafted questions is what is on the screen, word for word, and then exactly three lines: the date, who drafted and who reviews, and the tool version",
       identical(words_of(see_text(s)), words_of(gsub("(?m)^[0-9]+[.] ", "", o$screen_text, perl = TRUE))) && startsWith(o$text, o$screen_text) &&
         length(tail_lines) == 3L && grepl("^Date: [0-9]{4}-[0-9]{2}-[0-9]{2}$", tail_lines[1]) &&
         identical(tail_lines[2], "Drafted with QuestionR, an AI tool; reviewed by [analyst to complete]") &&
         identical(tail_lines[3], paste0("QuestionR version ", QUESTIONR_VERSION)))
    h = paste(html_of3(output$results), s, html_of3(output$drafts_ui))
    ok("on the drafting screens, nowhere: TRAPD, translation, the word skill, a language field",
       !grepl(translation_pattern, see_text(h), ignore.case = TRUE) && !grepl("skill", see_text(h), ignore.case = TRUE) &&
         !grepl("lang", paste(regmatches(h, gregexpr("id=\"[^\"]*\"", h))[[1]], collapse = " "), ignore.case = TRUE))
  })
})

# A review as the analyst sees it, when the stand-in model sends more than is allowed, and its Word copy.
local({
  st = review_state()
  ra = rv_ask()
  shiny::testServer(mod_results_server,
                    args = list(state = st, go = function(tab) NULL, make_ask = function(total) ra$ask), {
    session$flushReact()
    approve_review(st)
    session$flushReact()
    h = html_of3(output$results)
    sent_problems = purrr::map_int(rv_reply$items, function(i) length(i$problems))
    sent_points = length(rv_reply$instrument)
    cards = regmatches(h, gregexpr("(?s)<h6[^>]*>Question [^<]*</h6>.*?(?=<h6|The questionnaire as a whole|$)", h, perl = TRUE))[[1]]
    ok("the stand-in sent more than two problems for a question and more than three points about the whole; the screen shows at most two for each question and at most three points",
       max(sent_problems) > 2L && sent_points > 3L && length(cards) >= 1L &&
         all(purrr::map_int(cards, function(cd) n_in3("Problem: ", cd)) <= 2L) &&
         n_in3("Problem: ", h) == sum(pmin(sent_problems, 2L)) &&
         local({
           at = regexpr("The questionnaire as a whole", h, fixed = TRUE)
           at > 0 && n_in3("<li", substring(h, at)) <= 3L
         }))
    o = build_output(isolate(st$form), review = isolate(st$review))
    tail_lines = trimws(strsplit(substring(o$text, nchar(o$screen_text) + 1L), "\n", fixed = TRUE)[[1]])
    tail_lines = tail_lines[nzchar(tail_lines)]
    ok("the Word copy of a review is what is on the screen, word for word, and then exactly the same three lines",
       identical(words_of(see_text(h)), words_of(o$screen_text)) && startsWith(o$text, o$screen_text) &&
         length(tail_lines) == 3L && grepl("^Date: [0-9]{4}-[0-9]{2}-[0-9]{2}$", tail_lines[1]) &&
         identical(tail_lines[2], "Drafted with QuestionR, an AI tool; reviewed by [analyst to complete]") &&
         identical(tail_lines[3], paste0("QuestionR version ", QUESTIONR_VERSION)))
    ok("on the review screen, nowhere: TRAPD, translation, the word skill, a language field",
       !grepl(translation_pattern, see_text(h), ignore.case = TRUE) && !grepl("skill", see_text(h), ignore.case = TRUE) &&
         !grepl("lang", paste(regmatches(h, gregexpr("id=\"[^\"]*\"", h))[[1]], collapse = " "), ignore.case = TRUE))
  })
})
