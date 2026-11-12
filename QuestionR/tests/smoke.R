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
# Phase 3 built tabs 1 to 3, so two are left: Output and Methodology.
ok("the not-yet-built tabs say so",
   lengths(regmatches(page$html, gregexpr("Not built yet", page$html, fixed = TRUE))) == 2L &&
     grepl("Phase 5", page$html, fixed = TRUE))

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
ok("every file a task names is a skill file, core.md leads, and mode.md is in",
   purrr::every(TASKS, function(t) all(t$files %in% SKILL_FILES) && identical(t$files[1], "core.md") &&
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

ok("build_step_prompt(form, step, candidates), and build_prompt(form) is its work step",
   identical(names(formals(build_step_prompt)), c("form", "step", "candidates")) &&
     identical(names(formals(build_prompt)), "form") &&
     every_built(function(b) identical(b$p, build_step_prompt(b$form, "work"))))
ok("an unknown step stops, naming the three",
   grepl("step must be one of: brief, work, appraise",
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
       startsWith(b$p$system, skills[["core.md"]]$persona)))
ok("the brief check's user message is PREPARE, ASK, CHECKLIST, CHARACTERIZE, with pm_brief's output format",
   purrr::every(brief_built, function(b) {
     u = b$p$user
     pos = purrr::map_int(c("PREPARE", "ASK", "CHECKLIST", "CHARACTERIZE"), function(h)
       as.integer(regexpr(paste0("(?m)^", h, "$"), u, perl = TRUE)))
     all(pos > 0) && all(diff(pos) > 0) && startsWith(u, "PREPARE\n") &&
       inn(u, skills[["pm_brief.md"]]$output_format) && inn(u, "\"task_fit\"") &&
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
     inn(ap$system, "- code_every_check (") && inn(ap$system, "- compare_do_not_rank (") &&
     !inn(ap$system, "- declare_defaults (") && !inn(ap$system, "- attitude_object (") &&
     startsWith(ap$system, skills[["core.md"]]$persona))
ok("the appraisal's user message is PREPARE, ASK, CANDIDATES, CHECKLIST, CHARACTERIZE, in that order",
   local({
     pos = purrr::map_int(c("PREPARE", "ASK", "CANDIDATES", "CHECKLIST", "CHARACTERIZE"), function(h)
       as.integer(regexpr(paste0("(?m)^", h, "$"), ap$user, perl = TRUE)))
     all(pos > 0) && all(diff(pos) > 0) && inn(ap$user, skills[["pm_appraise.md"]]$output_format) &&
       inn(ap$user, "\"fails\"")
   }))
ok("the appraisal's CHECKLIST is exactly what the workers' files give, and their questions are not in the system prompt",
   local({
     ck = build_checklist(forms$attitudinal)
     inn(ap$user, paste0("\n\nCHECKLIST\n", paste0(names(ck), ": ", unname(ck), collapse = "\n"), "\n\nCHARACTERIZE\n")) &&
       !contains_any(ap$system, squash(check_texts))
   }))
ok("the appraisal says how many candidates and how many items each was asked for",
   inn(ap$user, "Appraise the 3 candidate drafts") && inn(ap$user, "exactly 6 survey items"))
ok("each candidate is one JSON line with its letter, its stems, its options, its parts and its decisions",
   local({
     lines = strsplit(ap$user, "\n", fixed = TRUE)[[1]]
     cl = lines[grepl("^\\{\"candidate\":", lines)]
     parsed = purrr::map(cl, jsonlite::fromJSON, simplifyVector = FALSE)
     length(cl) == 3L && identical(purrr::map_chr(parsed, "candidate"), c("A", "B", "C")) &&
       identical(parsed[[2]]$items[[1]]$stem, "Stem number 1 (B)?") &&
       length(parsed[[1]]$items[[2]]$options) == 3L &&
       identical(parsed[[3]]$items[[1]]$parts[[1]]$stem, "Filter 1?") &&
       length(parsed[[1]]$items[[1]]$decisions) == 1L && identical(parsed[[1]]$not_covered[[1]], "domain 9")
   }))
ok("a worker's own notes never reach the appraisal, and an empty source_english is left out",
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
# A draft item with every field the skill asks for.
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
ok("questions in an item's parts are not counted as items",
   is.na(problem_of(vd, list(items = list(
     good_item(1, parts = list(list(when = "before the item", stem = "Do you know it?", options = list("Yes", "No")),
                               list(when = "if yes", stem = "How well?", options = list("A", "B")))),
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

appraisal_ok <- list(appraisal = list(list(candidate = "A", id = "Q1", domain = "d", fails = list())),
                     set_fails = list(), coverage = list(), differences = list(), merged = list(),
                     test_first = list(), limits = "An expert review by a language model.")
va <- reply_validator("appraisal")
ok("an appraisal with its seven fields passes, empty lists included; a missing limits or set_fails fails",
   is.na(problem_of(va, appraisal_ok)) &&
     says_in(problem_of(va, appraisal_ok[names(appraisal_ok) != "limits"]), "'limits' is missing") &&
     says_in(problem_of(va, appraisal_ok[names(appraisal_ok) != "set_fails"]), "'set_fails' is missing"))
ok("a fail must name its check and give a severity from 1 to 10, one about the set too",
   says_in(problem_of(va, with_field(appraisal_ok, appraisal = list(list(
     candidate = "A", id = "Q1", fails = list(list(evidence = "x", severity = 6)))))), "does not name its check") &&
     says_in(problem_of(va, with_field(appraisal_ok, appraisal = list(list(
       candidate = "A", id = "Q1", fails = list(list(check = "one_thing", evidence = "x")))))), "severity from 1 to 10") &&
     says_in(problem_of(va, with_field(appraisal_ok, appraisal = list(list(
       candidate = "A", id = "Q1", fails = list(list(check = "one_thing", severity = 11)))))), "severity from 1 to 10") &&
     is.na(problem_of(va, with_field(appraisal_ok, appraisal = list(list(
       candidate = "A", id = "Q1", fails = list(list(check = "one_thing", severity = 4))))))) &&
     says_in(problem_of(va, with_field(appraisal_ok, set_fails = list(list(candidate = "A", check = "keying")))),
             "set_fails 1: 'severity' is missing") &&
     says_in(problem_of(va, with_field(appraisal_ok, set_fails = list(list(candidate = "A", check = "keying", severity = 0)))),
             "set_fails 1: 'severity' must be a number from 1 to 10") &&
     is.na(problem_of(va, with_field(appraisal_ok, set_fails = list(list(candidate = "A", check = "keying", severity = 5, items = list("Q1", "Q2")))))))
ok("a format that has no schema stops, naming it",
   says_in(tryCatch(reply_validator("poem"), error = conditionMessage), "no reply schema called 'poem'"))
REPLY_SCHEMAS$tiny <- list(fields = c(answer = "text"), each = list(), rules = character(0))
ok("a new output format is one entry: the validator is built from REPLY_SCHEMAS alone",
   is.na(problem_of(reply_validator("tiny"), list(answer = "x"))) &&
     says_in(problem_of(reply_validator("tiny"), list(answer = "")), "'answer' must be a non-empty string"))
REPLY_SCHEMAS$tiny <- NULL


# Coded defaults, against a fixture coded by hand.
fx <- list(
  list(what = "five labelled points and a don't know",
       item = good_item(1, options = list("Strongly agree", "Agree", "Neither", "Disagree", "Strongly disagree", "Don't know"),
                        decisions = list("closed", "five points, every point labelled with words")),
       lang = "English",
       want = list(format = "closed", n_options = 6L, n_points = 5L, points_odd = TRUE,
                   midpoint_stated = "not stated", dont_know = TRUE,
                   ref_period = FALSE, labels = "yes", decisions = "itemised")),
  list(what = "four points, end labels only, a reference period, no don't know",
       item = good_item(2, stem = "In the past 7 days, how often did you listen to the radio?",
                        options = list("Never", "Once or twice", "Most days", "Every day"),
                        decisions = list("closed", "four points, endpoint labels only")),
       lang = "English",
       want = list(format = "closed", n_options = 4L, n_points = 4L, points_odd = FALSE,
                   midpoint_stated = "not stated", dont_know = FALSE,
                   ref_period = TRUE, labels = "no", decisions = "itemised")),
  list(what = "an open item",
       item = good_item(3, stem = "How many days did you vote?", options = list(), open_format = "a number of days",
                        decisions = list("open, numeric")),
       lang = "English",
       want = list(format = "open", n_options = 0L, n_points = NA_integer_, points_odd = NA,
                   midpoint_stated = "not stated", dont_know = NA,
                   ref_period = FALSE, labels = "not stated", decisions = "not itemised")),
  list(what = "a curly apostrophe and a not-applicable option",
       item = good_item(4, options = list("Yes", "No", "Not applicable", "I don’t know"), decisions = list()),
       lang = "English",
       want = list(format = "closed", n_options = 4L, n_points = 2L, points_odd = FALSE,
                   midpoint_stated = "not stated", dont_know = TRUE,
                   ref_period = FALSE, labels = "not stated", decisions = "none")),
  list(what = "French: points, don't know and period are not coded",
       item = good_item(5, stem = "Au cours des 7 derniers jours, avez-vous écouté la radio ?",
                        options = list("Jamais", "Parfois", "Souvent", "Je ne sais pas"),
                        decisions = list("closed", "every point labelled")),
       lang = "French",
       want = list(format = "closed", n_options = 4L, n_points = NA_integer_, points_odd = NA,
                   midpoint_stated = "not stated", dont_know = NA,
                   ref_period = NA, labels = "yes", decisions = "itemised")),
  list(what = "an item with only a stem and options",
       item = list(stem = "Do you vote?", options = list("Yes", "No")),
       lang = "",
       want = list(format = "closed", n_options = 2L, n_points = 2L, points_odd = FALSE,
                   midpoint_stated = "not stated", dont_know = FALSE,
                   ref_period = FALSE, labels = "not stated", decisions = "none")))
purrr::walk(fx, function(x)
  ok(paste("coded defaults match the hand-coded fixture:", x$what),
     identical(code_defaults(x$item, x$lang), x$want)))
ok("the coded defaults read as words for a table, with not coded where it is",
   identical(unname(defaults_labels(code_defaults(fx[[5]]$item, "French"))[c(
     "Scale points (no-answer options not counted)", "Odd number of points", "Don't know / no opinion", "Reference period")]),
             rep("not coded", 4L)) &&
     identical(unname(defaults_labels(code_defaults(fx[[1]]$item))[c("Format", "Odd number of points")]), c("closed", "yes")))

# R does not call an odd count a midpoint (DESIGN.md section 13): it reports the
#   count, whether it is odd, and what the item itself says about a midpoint.
ok("a five-point scale whose decisions say there is no midpoint is odd and stated as no midpoint, and R does not say 'midpoint' for the count",
   local({
     d = code_defaults(good_item(1, options = list("Not at all", "A little", "Somewhat", "Quite", "Very"),
                                 decisions = list("Closed; five points", "No midpoint because the construct has no middle")))
     identical(d$points_odd, TRUE) && identical(d$midpoint_stated, "no") &&
       !any(grepl("^Midpoint \\(odd", names(defaults_labels(d))))
   }))
ok("what an item says about a midpoint is read as yes, no or not stated, in the phrasings the models used",
   identical(code_defaults(good_item(1, decisions = list("Include a midpoint: A moderate amount represents a middle level.")))$midpoint_stated, "yes") &&
     identical(code_defaults(good_item(1, decisions = list("Closed; 5 options; no midpoint; unipolar")))$midpoint_stated, "no") &&
     identical(code_defaults(good_item(1, decisions = list("Midpoint: no.")))$midpoint_stated, "no") &&
     identical(code_defaults(good_item(1, decisions = list("Closed; five options.")))$midpoint_stated, "not stated"))
ok("decisions written as one string or one entry are flagged not itemised, two or more are itemised, none is none",
   identical(code_defaults(good_item(1, decisions = "Closed; 5 options; no midpoint; no reasons"))$decisions, "not itemised") &&
     identical(code_defaults(good_item(1, decisions = list("one long entry; with everything")))$decisions, "not itemised") &&
     identical(code_defaults(good_item(1, decisions = list("a", "b")))$decisions, "itemised") &&
     identical(code_defaults(good_item(1, decisions = list()))$decisions, "none"))


# Checks on an appraisal.
ck_cands <- list(A = draft_of(2), B = draft_of(1))
ck_ids <- names(build_checklist(forms$attitudinal))
ck_reply <- list(
  appraisal = list(
    list(candidate = "A", id = "Q1", domain = "d1", fails = list(
      list(check = ck_ids[1], evidence = "trust", stage = "comprehension", severity = 7, why = "Vague."),
      list(check = "made_up_check", evidence = "x", stage = "judgment", severity = 3, why = "Odd."))),
    list(candidate = "A", id = "Q2", domain = "d2", fails = list(
      list(check = ck_ids[2], evidence = "a little", stage = "reporting", severity = 2, why = "Minor."))),
    list(candidate = "C", id = "Q9", domain = "d9", fails = list())),
  set_fails = list(list(candidate = "A", check = ck_ids[3], items = list("Q1", "Q2"), severity = 6, why = "All keyed one way."),
                   list(candidate = "B", check = "invented_set_check", items = list("Q1"), severity = 4, why = "Odd.")),
  merged = list(list(domain = "d1", candidate = "A", id = "Q1"), list(domain = "d2", candidate = "A", id = "Q2"),
                list(domain = "d3", candidate = "B", id = "Q7"), list(domain = "d4", candidate = "", id = "")))
ca <- check_appraisal(ck_reply, ck_cands, build_checklist(forms$attitudinal))
ok("an appraisal's fails are read with whether each check is an id that was sent",
   length(ca$fails) == 3L && isTRUE(ca$fails[[1]]$known) && isFALSE(ca$fails[[2]]$known) &&
     identical(ca$fails[[1]]$evidence, "trust") &&
     identical(sort(ca$unknown_checks), c("invented_set_check", "made_up_check")))
ok("a fail is shown at severity 5 or above and folded below it; one with no severity is shown",
   identical(purrr::map_lgl(ca$fails, "shown"), c(TRUE, FALSE, FALSE)) &&
     identical(purrr::map_dbl(ca$fails, "severity"), c(7, 3, 2)) &&
     isTRUE(check_appraisal(list(appraisal = list(list(candidate = "A", id = "Q1", fails = list(list(check = ck_ids[1]))))),
                            ck_cands, build_checklist(forms$attitudinal))$fails[[1]]$shown))
ok("the fails about a candidate's whole set are kept apart, with the items they name, and count against no item",
   length(ca$set_fails) == 2L && identical(ca$set_fails[[1]]$candidate, "A") && identical(ca$set_fails[[1]]$items, "Q1, Q2") &&
     isTRUE(ca$set_fails[[1]]$shown) && isFALSE(ca$set_fails[[2]]$shown) && isFALSE(ca$set_fails[[2]]$known))
ok("an item the appraiser gave no entry is not appraised, not a pass; an entry for no item is flagged",
   identical(ca$not_appraised, "B|Q1") && identical(ca$unknown_items, "C|Q9"))
ok("a merged item that does not exist, or has a fail rated 5 or above, is a problem; one with only a low fail is not; an empty domain is not",
   length(ca$merged_problems) == 2L && any(grepl("A Q1 has a fail rated 5 or above", ca$merged_problems, fixed = TRUE)) &&
     any(grepl("B Q7 is not in any candidate", ca$merged_problems, fixed = TRUE)) &&
     !any(grepl("A Q2", ca$merged_problems, fixed = TRUE)))
ok("an appraisal with nothing wrong has no flags",
   local({
     c0 = check_appraisal(list(appraisal = list(
       list(candidate = "A", id = "Q1", fails = list()), list(candidate = "A", id = "Q2", fails = list()),
       list(candidate = "B", id = "Q1", fails = list()))), ck_cands, build_checklist(forms$attitudinal))
     !length(c0$fails) && !length(c0$unknown_checks) && !length(c0$not_appraised) &&
       !length(c0$unknown_items) && !length(c0$merged_problems)
   }))


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
                     output_language = "English", source_language = "English", n_items = 2,
                     workers = worker_ids)
set_inputs <- function(session, base, ...) do.call(session$setInputs, utils::modifyList(base, list(...)))

ok("the state object is made from STATE_DEFAULTS, and every field a module uses is in it",
   identical(sort(names(STATE_DEFAULTS)),
             sort(c("key_version", "form", "workers", "brief", "approved", "run_id", "round",
                    "drafts", "appraisal", "seed", "kept", "revision", "rounds"))))
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
    set_inputs(session, brief_inputs, skip = 1)
    ok("Skip carries the cleaned form and the ticked workers on, marks the brief skipped, and moves to the prompt",
       identical(st$form$task, "attitudinal") && identical(st$form$n_items, 2L) &&
         identical(st$form$modes, "web") && length(st$workers) == length(worker_ids) &&
         identical(st$brief$status, "skipped") && identical(nav$env$tabs, QUESTIONR_TABS[3]) &&
         length(fa$st$calls) == 0L)

    nav$env$tabs = character(0)
    st$form = NULL
    set_inputs(session, brief_inputs, research_question = "", skip = 2)
    ok("a form that cannot be a prompt says why on the page, and goes nowhere",
       grepl("research question is required", html_of3(output$message), fixed = TRUE) &&
         is.null(st$form) && !length(nav$env$tabs))
    set_inputs(session, brief_inputs, workers = character(0), skip = 3)
    ok("no worker ticked says so, and goes nowhere",
       grepl("Tick at least one worker", html_of3(output$message), fixed = TRUE) && is.null(st$form))
    set_inputs(session, brief_inputs, n_items = NA, skip = 4)
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
    ok("a brief check that fails is said on the page in words, with the reason, and offers to skip",
       identical(st$brief$status, "failed") && grepl("did not come back", r, fixed = TRUE) &&
         grepl("the project manager is down", r, fixed = TRUE) && grepl("skip it", r, fixed = TRUE))
    llm_clear_session_key(session$token)
  })
})

local({
  st = test_state()
  shiny::testServer(mod_brief_server, args = list(state = st, go = function(tab) NULL), {
    set_inputs(session, brief_inputs, questionnaire = "LEAKED QUESTIONNAIRE", reference_period = "LEAKED PERIOD",
               skip = 1)
    ok("a field the chosen task does not show is blank in the form, whatever was typed there before",
       identical(st$form$questionnaire, "") && identical(st$form$reference_period, ""))
    set_inputs(session, brief_inputs, task = "behavioral", reference_period = "past 7 days", skip = 2)
    ok("a field the task does show is carried (the reference period, for behavioral items)",
       identical(st$form$reference_period, "past 7 days") && identical(st$form$task, "behavioral"))
    set_inputs(session, brief_inputs, task = "evaluate", questionnaire = "Q1. How are you? Fine / Not fine",
               skip = 3)
    ok("Evaluate carries its questionnaire, no item count and no workers, and says it is built in Phase 4",
       identical(st$form$task, "evaluate") && grepl("Q1. How are you?", st$form$questionnaire, fixed = TRUE) &&
         is.na(st$form$n_items) && length(st$workers) == 0L &&
         grepl("Phase 4", html_of3(output$task_note), fixed = TRUE))
    st$revision = "Make the stems shorter."
    session$flushReact()
    ok("a requested change is shown on the Brief tab with the round it belongs to, and can be dropped",
       grepl("REVISION", html_of3(output$revision_note), fixed = TRUE) &&
         grepl("Make the stems shorter.", html_of3(output$revision_note), fixed = TRUE) &&
         grepl("Round 1", html_of3(output$revision_note), fixed = TRUE))
    set_inputs(session, brief_inputs, skip = 4)
    ok("the change goes into the form as its revision, and so into the prompt as a REVISION block",
       identical(st$form$revision, "Make the stems shorter.") &&
         grepl("\nREVISION: Make the stems shorter.", build_prompt(st$form)$user, fixed = TRUE))
    session$setInputs(drop_revision = 1)
    ok("dropping the change clears it", identical(st$revision, ""))
  })
})

# The form is the registry's, not the screen's.
brief_page <- paste(as.character(mod_brief_ui("brief")), collapse = "")
ok("the Brief tab has the dropdown, the form, a box per worker, the check and the skip button",
   n_in3("brief-task", brief_page) >= 1L && grepl("Check the brief", brief_page, fixed = TRUE) &&
     grepl("Skip the brief check", brief_page, fixed = TRUE) &&
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
     grepl("^PREPARE", build_prompt(utils::modifyList(forms$attitudinal, list(task = "knowledge")))$user) &&
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
    ok("the assembled prompt is shown whole and editable, with the skill files used",
       grepl("senior survey methodologist", b, fixed = TRUE) && grepl("Write exactly 2 survey items", b, fixed = TRUE) &&
         grepl("textarea", b, fixed = TRUE) && grepl("core.md, generate.md", b, fixed = TRUE) &&
         grepl("Approve and run", b, fixed = TRUE) && !grepl("disabled", b, fixed = TRUE) &&
         grepl("3 workers", b, fixed = TRUE) && grepl("4 model calls", b, fixed = TRUE))

    session$setInputs(system = a$system, user = a$user)
    ok("an untouched prompt is shown as assembled, with its hash",
       grepl("As assembled", html_of3(output$status), fixed = TRUE) &&
         grepl(substr(a$hash, 1, 16), html_of3(output$status), fixed = TRUE))
    session$setInputs(approve = 1)
    ok("approving it as it is records it unedited, with one hash, starts a run and moves to Results",
       identical(st$approved$edited, FALSE) && identical(st$approved$hash, a$hash) &&
         identical(st$approved$original_hash, a$hash) && identical(st$approved$user, a$user) &&
         identical(st$approved$system, a$system) && st$run_id == 1L && identical(nav$env$tabs, QUESTIONR_TABS[4]))

    ed_user = paste0(a$user, "\nPlease keep every stem under 15 words.")
    session$setInputs(system = a$system, user = ed_user)
    s = html_of3(output$status)
    ok("an edited prompt is marked edited, showing both hashes",
       grepl("Edited", s, fixed = TRUE) && grepl(substr(a$hash, 1, 16), s, fixed = TRUE) &&
         grepl(substr(prompt_hash(a$system, ed_user), 1, 16), s, fixed = TRUE))
    session$setInputs(approve = 2)
    ok("approving an edited prompt sends the edited text, marks it edited, and keeps both hashes",
       identical(st$approved$edited, TRUE) && identical(st$approved$user, ed_user) &&
         identical(st$approved$hash, prompt_hash(a$system, ed_user)) && identical(st$approved$original_hash, a$hash) &&
         st$run_id == 2L)
    session$setInputs(system = gsub("\n", "\r\n", a$system, fixed = TRUE), user = gsub("\n", "\r\n", a$user, fixed = TRUE),
                      approve = 3)
    ok("a browser's line endings are not an edit",
       identical(st$approved$edited, FALSE) && identical(st$approved$hash, a$hash))
    session$setInputs(system = a$system, user = "   ", approve = 4)
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
    ok("Evaluate's prompt can be read but not run: the button is off and the page says why",
       grepl("disabled", b, fixed = TRUE) && grepl("Phase 4", b, fixed = TRUE) && grepl("QUESTIONNAIRE", b, fixed = TRUE))
    session$setInputs(approve = 1)
    ok("pressing it anyway starts nothing, and says so",
       st$run_id == 0L && is.null(st$approved) && grepl("cannot be run yet", html_of3(output$message), fixed = TRUE))
  })
})


# Tab 3, Results, and Run again.
checklist_ids <- names(build_checklist(clean_form(fl_form)))
rich_appraisal <- list(
  appraisal = list(
    list(candidate = "A", id = "Q1", domain = "domain 1", fails = list(
      list(check = checklist_ids[1], evidence = "institution 1", stage = "comprehension", severity = 7,
           why = "The term is vague."),
      list(check = "invented_check", evidence = "trust", stage = "judgment", severity = 3, why = "Odd."))),
    list(candidate = "A", id = "Q2", domain = "domain 2", fails = list(
      list(check = checklist_ids[2], evidence = "a little", stage = "reporting", severity = 2, why = "Minor.")))),
  set_fails = list(
    list(candidate = "A", check = checklist_ids[3], items = list("Q1", "Q2"), severity = 6, why = "Both keyed one way."),
    list(candidate = "B", check = checklist_ids[3], items = list("Q1"), severity = 4, why = "Slightly one way.")),
  coverage = list(list(domain = "domain 1", covered_by = list("A", "B", "C"), clean_items = list(list(candidate = "A", id = "Q2")))),
  differences = list("Candidate A uses three points; the others use five."),
  merged = list(list(domain = "domain 1", candidate = "A", id = "Q2"), list(domain = "domain 2", candidate = "", id = "")),
  test_first = list(list(candidate = "A", id = "Q1", method = "a cognitive interview")),
  limits = "An expert review by a language model, not a pretest.")
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
    ok("a run makes one call per worker and one for the appraisal, and records the round in the state and the log",
       identical(purrr::map_chr(fa$st$calls, "id"), c(fl_ids, pm_id)) && st$round == 1L &&
         length(st$drafts) == 3L && identical(st$appraisal$status, "ok") && length(st$rounds) == 1L &&
         identical(st$rounds[[1]]$schema, 1L) && identical(st$rounds[[1]]$seed, st$seed))
    ok("each candidate is shown by letter with its items, options and the model that wrote it",
       all(purrr::map_lgl(c("Candidate A", "Candidate B", "Candidate C"), function(l) grepl(l, h, fixed = TRUE))) &&
         all(purrr::map_lgl(fl_ids, function(id) grepl(id, h, fixed = TRUE))) &&
         grepl("Question from worker", h, fixed = TRUE) && grepl("<ol", h, fixed = TRUE) &&
         grepl("A little", h, fixed = TRUE))
    ok("each item shows the coded defaults and has a tick box to keep it",
       n_in3("Coded defaults", h) == 6L && n_in3("Keep this item", h) == 6L &&
         grepl("Odd number of points", h, fixed = TRUE) &&
         grepl("Midpoint, as the item states it (self-reported)", h, fixed = TRUE) &&
         grepl("Every point labelled (self-reported)", h, fixed = TRUE) && !grepl("Midpoint (odd count)", h, fixed = TRUE))
    ok("a failed check is shown with the appraiser's failing words and the check's question; one that was not sent is flagged",
       grepl("Failing words:", h, fixed = TRUE) && grepl("institution 1", h, fixed = TRUE) &&
         grepl(checklist_ids[1], h, fixed = TRUE) &&
         grepl(build_checklist(st$form)[[checklist_ids[1]]], h, fixed = TRUE) &&
         grepl("not a check that was sent", h, fixed = TRUE))
    ok("an item the appraiser gave no entry is not shown as passed",
       n_in3("Not appraised: the appraiser gave this item no entry", h) == 4L &&
         n_in3("No failed check rated 5 or above.", h) == 1L)
    ok("fails below severity 5 are folded away, not listed, and a candidate's set-level fails are shown once under it",
       n_in3("rated below 5", h) == 3L && n_in3("severity 7", h) == 1L && n_in3("severity 6", h) == 1L &&
         n_in3("whole set", h) == 2L && grepl("(items Q1, Q2)", h, fixed = TRUE) &&
         grepl("No set-level fail rated 5 or above.", h, fixed = TRUE))
    ok("an item whose design decisions are one entry, not several, is flagged on the page (every canned item here)",
       n_in3("decisions not itemised", h) == 6L)
    ok("below the candidates: coverage, differences, the merged option labelled untested, what to test first, the limits",
       grepl("Coverage by domain", h, fixed = TRUE) && grepl("Candidate A uses three points", h, fixed = TRUE) &&
         grepl("Merged option", h, fixed = TRUE) && grepl("A fourth option, untested like the others", h, fixed = TRUE) &&
         grepl("copied word for word", h, fixed = TRUE) &&
         grepl("no candidate item is free of a fail rated 5 or above", h, fixed = TRUE) &&
         grepl("What to test first", h, fixed = TRUE) && grepl("a cognitive interview", h, fixed = TRUE) &&
         grepl("not a pretest", h, fixed = TRUE) && grepl("does not choose, and nothing here is validated", h, fixed = TRUE))
    ok("R's checks on the appraisal are shown: the check that was not sent, and the items given no entry",
       grepl("checks on the appraisal found", h, fixed = TRUE) && grepl("invented_check", h, fixed = TRUE))
    ok("the criteria applied are listed, and the prompt hash and seed are shown, with no model name given to the appraiser",
       grepl("Criteria that were applied", h, fixed = TRUE) && grepl(substr(build_prompt(st$form)$hash, 1, 16), h, fixed = TRUE) &&
         grepl(as.character(st$seed), h, fixed = TRUE) && !any(purrr::map_lgl(c(fl_ids, "vendor-"), function(s) grepl(s, fa$st$calls[[4]]$user, fixed = TRUE))))

    session$setInputs(keep_A_1 = TRUE, keep_B_2 = TRUE, keep_C_1 = FALSE)
    session$flushReact()
    ok("ticking items records them by candidate letter, position and id, and unticking removes them",
       length(st$kept) == 2L && identical(st$kept[[1]]$candidate, "A") && st$kept[[1]]$position == 1L &&
         identical(st$kept[[1]]$id, "Q1") && identical(st$kept[[2]]$candidate, "B") && st$kept[[2]]$position == 2L)
    session$setInputs(keep_A_1 = FALSE)
    session$flushReact()
    ok("an item unticked is no longer kept", length(st$kept) == 1L && identical(st$kept[[1]]$candidate, "B"))

    # A browser resets the boxes when the results are drawn again; the test's inputs do not.
    session$setInputs(keep_B_2 = FALSE)
    approve_state(st)
    session$flushReact()
    ok("a second run is a second round in the log, with nothing kept",
       st$round == 2L && length(st$rounds) == 2L && length(st$kept) == 0L)
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
    ok("a worker that failed is listed with its reason, the other two are shown, and the appraisal covers two candidates",
       grepl("Did not return a usable draft", h, fixed = TRUE) && grepl("canned endpoint error", h, fixed = TRUE) &&
         grepl("2 of 3", h, fixed = TRUE) && n_in3("Coded defaults", h) == 4L &&
         !grepl("Candidate C", h, fixed = TRUE) && identical(st$appraisal$status, "ok"))
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
    ok("a failed appraisal is said in words with its reason; the candidates are still shown, none marked appraised",
       grepl("The appraisal did not come back", h, fixed = TRUE) && grepl("the appraiser is down", h, fixed = TRUE) &&
         grepl("Candidate A", h, fixed = TRUE) && n_in3("Not appraised: the appraisal did not come back", h) == 6L &&
         !grepl("The appraisal, across the candidates", h, fixed = TRUE))
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
ok("the page has the Generate tabs' controls, and the later tabs are still placeholders",
   grepl("Check the brief", page$html, fixed = TRUE) && grepl("Skip the brief check", page$html, fixed = TRUE) &&
     grepl("Research question (required)", page$html, fixed = TRUE) && n_in3("Not built yet", page$html) == 2L)
ok("no key is anywhere on the page", !grepl("pm-test-key|SECRET-KEY|or-secret-key", page$html))


# ---- From the first live run of the engine (2026-11-11) ------------------------------------

# The brief check's and the appraisal's call records reach the log, as the drafts' do.
ok("the log keeps the brief check's and the appraisal's own call records: raw reply, tokens, attempts",
   identical(rj_back$brief$call$tokens$input, 100L) && identical(rj_back$appraisal$call$tokens$output, 50L) &&
     grepl("criteria", rj_back$brief$call$raw, fixed = TRUE) && grepl("limits", rj_back$appraisal$call$raw, fixed = TRUE) &&
     identical(rj_back$brief$call$attempts, 1L))

# How three real models wrote that every point is labelled, and two ways of saying it is not.
label_of <- function(...) code_defaults(good_item(1, decisions = list(...)))$labels
ok("a model's own words for labelling every point are read as yes, in the phrasings the live run produced",
   identical(label_of("Closed; 5 options; all labels present; no midpoint; unipolar direction (none to a lot)"), "yes") &&
     identical(label_of("Label every option; labels make each response visible and distinct on the web form."), "yes") &&
     identical(label_of("Every option has a verbal label to avoid confusion."), "yes"))
ok("labels said to be partial or absent are read as no, and a silence is not stated",
   identical(label_of("Label only the end points of the scale."), "no") &&
     identical(label_of("Endpoint labels only."), "no") && identical(label_of("No labels present."), "no") &&
     identical(label_of("Closed; five options; direction low to high."), "not stated"))


# ---- Phase 4a: section 13's rulings ------------------------------------------------------

# A cut-off reply says what to do about it, for the step it was.
cut_off <- function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL)
  llm_fail("[x via y, finish: max_tokens] The reply reached the token limit (1) without finishing, so it was cut off.",
           class = "llm_truncated")
ok("a cut-off brief check says to try again or skip; a cut-off draft to ask for fewer items; a cut-off appraisal to untick a worker",
   grepl("try the brief check again, or skip it", tolower(run_brief(fl_form, fl_pm, ask = cut_off)$error), fixed = TRUE) &&
     all(purrr::map_lgl(run_drafts(fl_form, fl_workers, ask = cut_off), function(d)
       grepl("Ask for fewer items and run again.", d$error, fixed = TRUE))) &&
     grepl("Untick a worker or ask for fewer items", run_appraisal(fl_form, fl_drafts, fl_pm, ask = cut_off, seed = 1L)$error,
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
     grepl("Paste it in parts", e, fixed = TRUE) && grepl(format(APP_MAX_PASTE_CHARS, big.mark = ","), e, fixed = TRUE) &&
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
  sent = function(api, effort = NULL) {
    m = list(api = api, base_url = px$url("/v1"), id = "mock/model", key_source = "analyst")
    if (!is.null(effort)) m$reasoning_effort = effort
    jsonlite::fromJSON(suppressWarnings(llm_complete(m, "SYS", "hi", 1000L, key = "k", timeout = 20)))
  }
  ok("a model entry's reasoning_effort reaches the Anthropic-style call as adaptive thinking with that effort; unset sends neither",
     identical(sent("anthropic", "low")$output_config$effort, "low") &&
       identical(sent("anthropic", "low")$thinking$type, "adaptive") &&
       is.null(sent("anthropic")$thinking) && is.null(sent("anthropic")$output_config))
  ok("ellmer 0.4.2 does not send reasoning_effort on the OpenAI-style call (so it is left unset), and no entry sets it",
     is.null(sent("openai", "low")$reasoning_effort) && is.null(sent("openai")$reasoning_effort) &&
       !any(purrr::map_lgl(c(list(APP_MODELS$pm), APP_MODELS$workers), function(m) "reasoning_effort" %in% names(m))))
})
