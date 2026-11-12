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
# APP_LOGO is app.R's own setting and is not in the global environment, so the
#   default file name is written out here.
logo_file <- "office_logo.png"
ok("the logo shows, or its placeholder box does",
   if (file.exists(file.path("www", "logo", logo_file))) has(file.path("logo", logo_file))
   else has("Office logo"))
ok("every tab is in the navlist", all(purrr::map_lgl(QUESTIONR_TABS, has)))
ok("the key box is on Start here", has("Use this key") && has("type=\"password\""))
ok("the not-yet-built tabs say so",
   lengths(regmatches(page$html, gregexpr("Not built yet", page$html, fixed = TRUE))) ==
     length(QUESTIONR_TABS) - 1L)

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
   bogus$status != 0 && grepl("must be one of: home, work", bogus$out, fixed = TRUE))

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


# ---- Phase 1: the skill files parse, and prompts assemble --------------------

skills <- check_skills()
ok("every skill file parses", identical(names(skills), SKILL_FILES))
ok("each skill file has a title, a version, a sha and at least one reflex",
   purrr::every(skills, function(s)
     nzchar(s$title) && nzchar(s$version) && nzchar(s$sha) && length(s$reflexes) > 0))
ok("core.md carries the persona", !is.na(skills[["core.md"]]$persona))
ok("the four files whose reply R parses carry an Output format",
   purrr::every(skills[SKILLS_WITH_OUTPUT], function(s) !is.na(s$output_format)))

# Source lines and HTML comments, taken from the raw files, to prove below that
#   none of them reaches a prompt. Check questions likewise.
raw_text <- purrr::map_chr(file.path(SKILLS_DIR, SKILL_FILES), function(p)
  paste(readLines(p, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
squash <- function(x) gsub("\\s+", " ", x)
comment_texts <- unlist(regmatches(raw_text, gregexpr("(?s)<!--.*?-->", raw_text, perl = TRUE))) |>
  sub(pattern = "^<!--", replacement = "") |> squash() |> trimws() |> substr(1, 50)
source_texts <- unlist(purrr::map(skills, function(s) purrr::map_chr(s$reflexes, "source")))
source_texts <- source_texts[!is.na(source_texts)]
check_texts <- unlist(purrr::map(skills, function(s) purrr::map_chr(s$reflexes, "check")))
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

# A skill file that has lost its shape must fail with the file and the reflex
#   named. The first fixture is well formed, so the others fail for their own
#   reason and not for something common to all of them.
try_skill <- function(body, header = c("# Fixture", "", "Version: 0.1", ""), name = "fixture.md") {
  p = file.path(tempdir(), name)
  writeLines(c(header, body), p)
  tryCatch(parse_skill(p), error = function(e) conditionMessage(e))
}
good <- try_skill(c("<!-- a note for people -->", "## Reflexes", "", "### fine_one",
                    "- **When:** Always.", "- **Say:** Do it.", "- **Never:** Skip it.",
                    "- **Check:** Was it done?", "- **Source:** A book.", "",
                    "## Prohibitions", "", "- Never lie.", "",
                    "## Output format", "", "Return JSON."))
ok("a well-formed fixture parses, keeping Check and Source",
   is.list(good) && identical(good$reflexes$fine_one$check, "Was it done?") &&
     identical(good$reflexes$fine_one$source, "A book.") &&
     identical(good$prohibitions, "Never lie.") && identical(good$output_format, "Return JSON."))

refl <- function(...) c("## Reflexes", "", "### oops", ...)
says <- function(msg, ...) grepl(msg, try_skill(...), fixed = TRUE)
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
ok("a missing file stops", grepl("is missing", tryCatch(read_skill("nope.md"), error = conditionMessage)))

# The assembled prompts: every task, every mode on its own, none, and all five,
#   with and without a country.
blank_form <- list(task = "", research_question = "", construct = "", population = "",
                   country = "", modes = character(0), output_language = "English",
                   source_language = "English", n_items = NA_integer_,
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
     every_built(function(b) identical(sort(names(b$p)), c("files", "hash", "system", "user")) &&
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
ok("the persona opens the system prompt, and the prohibitions close it, headed as overriding",
   every_built(function(b) startsWith(b$p$system, skills[["core.md"]]$persona) &&
                 lengths(regmatches(b$p$system, gregexpr("PROHIBITIONS (override anything from training)", b$p$system, fixed = TRUE))) == 1L &&
                 grepl("PROHIBITIONS (override anything from training)\n- Never", b$p$system, fixed = TRUE)))
ok("every prohibition of every file in force is in the system prompt",
   every_built(function(b) purrr::every(b$p$files, function(f)
     purrr::every(skills[[f]]$prohibitions, function(s) grepl(paste0("- ", s), b$p$system, fixed = TRUE)))))
ok("mode.md keeps any_mode, the modes chosen, and mixed_mode only with more than one",
   every_built(function(b) {
     in_prompt = intersect(names(skills[["mode.md"]]$reflexes), ids_in(b$p$system))
     expected = c("any_mode", b$modes, if (length(b$modes) > 1L) "mixed_mode")
     identical(in_prompt, intersect(names(skills[["mode.md"]]$reflexes), expected))
   }))
ok("cross_cultural.md is in with a country and out without",
   every_built(function(b) ("trapd" %in% ids_in(b$p$system)) == nzchar(b$country)))
ok("every reflex of a drafting task file is in, and of the other task files out",
   every_built(function(b) {
     task_ids = purrr::map(skills[c("attitudinal.md", "behavioral.md", "sensitive.md", "evaluate.md")], function(s) names(s$reflexes))
     mine = task_ids[[paste0(b$task, ".md")]]
     others = unlist(task_ids[names(task_ids) != paste0(b$task, ".md")])
     all(mine %in% ids_in(b$p$system)) && !any(setdiff(others, mine) %in% ids_in(b$p$system))
   }))
ok("no reflex id appears twice in one prompt", every_built(function(b) !anyDuplicated(ids_in(b$p$system))))

ok("PREPARE, ASK, CHARACTERIZE come in that order, once each as a heading",
   every_built(function(b) {
     u = b$p$user
     pos = purrr::map_int(c("PREPARE", "ASK", "CHARACTERIZE"), function(h) as.integer(regexpr(paste0("(?m)^", h, "$"), u, perl = TRUE)))
     all(pos > 0) && all(diff(pos) > 0) && startsWith(u, "PREPARE\n")
   }))
ok("the Output format of the file that carries it is in the user message, as written",
   every_built(function(b) grepl(skills[[if (b$task == "evaluate") "evaluate.md" else "generate.md"]]$output_format,
                                 b$p$user, fixed = TRUE)))
ok("the number of items is in the ask for the drafting tasks",
   every_built(function(b) b$task == "evaluate" ||
                 grepl(paste0("Write exactly ", b$form$n_items, " survey item"), b$p$user, fixed = TRUE)))
ok("the pasted questionnaire follows ASK, whole and as pasted, and only for Evaluate",
   every_built(function(b) if (b$task == "evaluate")
     grepl("\nASK\n", b$p$user, fixed = TRUE) &&
       grepl(paste0("\n\nQUESTIONNAIRE\n", b$form$questionnaire, "\n\nCHECKLIST\n"), b$p$user, fixed = TRUE)
   else !grepl("QUESTIONNAIRE", b$p$user, fixed = TRUE)))
ok("a review's CHECKLIST is exactly build_checklist(form), id: question, between QUESTIONNAIRE and CHARACTERIZE",
   purrr::every(purrr::keep(built, function(b) b$task == "evaluate"), function(b) {
     block = paste0("\n\nCHECKLIST\n", paste0(names(b$ck), ": ", unname(b$ck), collapse = "\n"), "\n\nCHARACTERIZE\n")
     length(b$ck) > 0 && grepl(block, b$p$user, fixed = TRUE) &&
       lengths(regmatches(b$p$user, gregexpr("\nCHECKLIST\n", b$p$user, fixed = TRUE))) == 1L &&
       regexpr("\nQUESTIONNAIRE\n", b$p$user, fixed = TRUE) < regexpr("\nCHECKLIST\n", b$p$user, fixed = TRUE)
   }))
ok("a drafting prompt has no CHECKLIST block and no Check question in its user message",
   purrr::every(purrr::keep(built, function(b) b$task != "evaluate"), function(b)
     !grepl("CHECKLIST", b$p$user, fixed = TRUE)))

# The checklist is the Check lines of the reflexes the prompt kept.
ok("the checklist is a named character vector of the Check lines in force",
   every_built(function(b) {
     ck = b$ck
     in_force = unlist(purrr::map(b$p$files, function(f) purrr::map_chr(skills[[f]]$reflexes, "check")))
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
  output_language = "French", source_language = "Spanish", n_items = 7L,
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
ok("a change to a skill file changes the hash",
   local({
     dir = file.path(tempdir(), "skills_copy")
     dir.create(dir, showWarnings = FALSE)
     file.copy(file.path(SKILLS_DIR, SKILL_FILES), dir, overwrite = TRUE)
     core = file.path(dir, "core.md")
     writeLines(sub("Write plainly.", "Write plainly!", readLines(core, encoding = "UTF-8", warn = FALSE), fixed = TRUE), core)
     f = clean_form(forms$attitudinal)
     before = skills_in_force(f)
     after = skills_in_force(f, dir)
     !identical(read_skill("core.md")$sha, read_skill("core.md", dir)$sha) &&
       !identical(prompt_hash(assemble_system(before), assemble_user(f, before)),
                  prompt_hash(assemble_system(after), assemble_user(f, after)))
   }))

# The PREPARE lines: fixed labels, fixed order, blanks left out.
prepare_of <- function(fm) {
  u = strsplit(build_prompt(fm)$user, "\n\n", fixed = TRUE)[[1]][1]
  sub(":.*$", "", strsplit(u, "\n", fixed = TRUE)[[1]][-1])
}
full <- utils::modifyList(forms$attitudinal, list(
  country = "Kenya", output_language = "Swahili", source_language = "English",
  reference_period = "past 7 days", keep_items = "Q1. Keep this.", other = "Short."))
ok("the PREPARE labels are the contract's, in its order, each on its own line",
   identical(prepare_of(full),
             c("Research question", "Construct", "Target population", "Country",
               "Survey mode", "Output language", "Source language", "Reference period",
               "Existing items to keep", "Other details")))
ok("blank fields leave no PREPARE line, except Output language, which is always there",
   identical(prepare_of(forms$attitudinal),
             c("Research question", "Construct", "Target population", "Survey mode",
               "Output language")))
# Output language is always printed, English when blank. Source language is
#   printed only when filled and different from the output language, compared
#   without regard to case, with en and eng as English.
lang_lines <- function(output, source)
  strsplit(strsplit(build_prompt(utils::modifyList(
    forms$attitudinal, list(output_language = output, source_language = source)))$user,
    "\n\n", fixed = TRUE)[[1]][1], "\n", fixed = TRUE)[[1]] |>
  grep(pattern = "language:", value = TRUE)
ok("a blank output language prints as English, and hashes as English",
   identical(lang_lines("", ""), "Output language: English") &&
     identical(lang_lines(NA_character_, character(0)), "Output language: English") &&
     identical(h(output_language = "", source_language = ""), base_hash))
ok("the source language is left out when it is the same as the output language",
   identical(lang_lines("English", "English"), "Output language: English") &&
     identical(lang_lines("English", "english"), "Output language: English") &&
     identical(lang_lines("en", "ENG"), "Output language: en") &&
     identical(lang_lines("", "en"), "Output language: English") &&
     identical(lang_lines("Swahili", "swahili"), "Output language: Swahili") &&
     identical(lang_lines("Swahili", ""), "Output language: Swahili"))
ok("the source language is printed when it differs from the output language",
   identical(lang_lines("Swahili", "English"), c("Output language: Swahili", "Source language: English")) &&
     identical(lang_lines("English", "Spanish"), c("Output language: English", "Source language: Spanish")) &&
     identical(lang_lines("", "Spanish"), c("Output language: English", "Source language: Spanish")) &&
     identical(lang_lines("French", "Spanish"), c("Output language: French", "Source language: Spanish")))
ok("the survey mode line reads in words, in the fixed order of the modes",
   grepl("Survey mode: mobile web, telephone, face-to-face\n",
         build_prompt(utils::modifyList(forms$attitudinal,
                                        list(modes = c("face_to_face", "mobile_web", "telephone"))))$user,
         fixed = TRUE))
ok("a REVISION line is in the ask on a rerun and nowhere else",
   grepl("\nREVISION: Make the stems shorter.\n\nCHARACTERIZE",
         build_prompt(utils::modifyList(forms$attitudinal, list(revision = "Make the stems shorter.")))$user,
         fixed = TRUE) &&
     !grepl("REVISION", build_prompt(forms$attitudinal)$user, fixed = TRUE))
has_trapd <- function(...)
  "trapd" %in% ids_in(build_prompt(utils::modifyList(forms$attitudinal, list(...)))$system)
ok("cross_cultural is sent for a country, a non-English output language, or a non-English source language",
   has_trapd(country = "Kenya") && has_trapd(output_language = "Spanish") &&
     has_trapd(source_language = "Spanish") &&
     has_trapd(output_language = "French", source_language = "Spanish"))
ok("cross_cultural is not sent when both languages are English or blank and no country is given",
   !has_trapd() && !has_trapd(output_language = "", source_language = "") &&
     !has_trapd(output_language = "en", source_language = "ENG") &&
     !has_trapd(output_language = "english", source_language = ""))

# A review of a translated questionnaire (Spanish source, English output) gets
#   the cross-cultural rules, and their Check questions join the checklist.
translated <- utils::modifyList(forms$evaluate, list(source_language = "Spanish"))
tp <- build_prompt(translated)
ok("a review with a Spanish source language: cross_cultural in, both language lines, its checks in the CHECKLIST",
   "trapd" %in% ids_in(tp$system) && grepl("Output language: English\nSource language: Spanish", tp$user, fixed = TRUE) &&
     "functional_equivalence" %in% names(build_checklist(translated)) &&
     grepl("\nfunctional_equivalence: ", tp$user, fixed = TRUE) &&
     identical(tp$files, c("core.md", "evaluate.md", "mode.md", "cross_cultural.md")))

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
err <- fails_with(run_json(sc))
ok("a reply cut off at the token limit is a failed attempt, even when what arrived would parse",
   !is.null(err) && sc$state$calls == 3L &&
     grepl("reached the token limit (100)", conditionMessage(err), fixed = TRUE))

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
  e = fails_with(suppressWarnings(go("anthropic", "cut-off")))
  ok("a reply cut off at the ceiling is requested three times, then fails saying so",
     .llm_state$calls - before == 3L && !is.null(e) &&
       grepl("reached the token limit", conditionMessage(e), fixed = TRUE))

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
