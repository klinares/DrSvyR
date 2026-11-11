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
ok("no Check question is in any prompt (they are for the appraisal)", none_in_any(squash(check_texts)))
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
     grepl(paste0("\nQUESTIONNAIRE\n", b$form$questionnaire, "\n\nCHARACTERIZE\n"), b$p$user, fixed = TRUE)
   else !grepl("QUESTIONNAIRE", b$p$user, fixed = TRUE)))

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
ok("blank fields leave no PREPARE line, and a blank form field is never guessed",
   identical(prepare_of(forms$attitudinal),
             c("Research question", "Construct", "Target population", "Survey mode")))
ok("both language lines are left out when both are English, and shown when either is not",
   !any(c("Output language", "Source language") %in% prepare_of(forms$attitudinal)) &&
     !any(c("Output language", "Source language") %in%
            prepare_of(utils::modifyList(forms$attitudinal, list(output_language = "english", source_language = "")))) &&
     identical(prepare_of(utils::modifyList(forms$attitudinal, list(output_language = "Swahili")))[5:6],
               c("Output language", "Source language")) &&
     "Source language" %in% prepare_of(utils::modifyList(forms$attitudinal, list(source_language = "Spanish"))))
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
ok("cross_cultural is triggered by the output language, not by the source language alone",
   !"trapd" %in% ids_in(build_prompt(utils::modifyList(forms$attitudinal, list(source_language = "Spanish")))$system) &&
     "trapd" %in% ids_in(build_prompt(utils::modifyList(forms$attitudinal, list(output_language = "Spanish")))$system))

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
