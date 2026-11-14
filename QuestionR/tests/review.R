# review.R -- writes REVIEW.md, the evidence Kevin takes back to the Claude
#   project after each phase. Written by the Claude project, not by the
#   builder. Everything in REVIEW.md is produced by this script from the files
#   and from running the code; none of it is typed by a person or a model.
#
# Run from inside QuestionR/ (PowerShell):
#   & "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" --no-init-file tests/review.R 1
# The argument is the phase just finished (0, 1, 2, ...). Home only: tests/
#   is deleted at work.
#
# Builder: do not change what this script checks. If it has a bug, fix only
#   the bug and say so in STATUS.md with the diff.
#
# Needs: shiny, purrr, dplyr, tibble, stringr, digest.

PHASE <- as.integer(c(commandArgs(trailingOnly = TRUE), "0")[1])
CODE_BUDGET <- 12L

# sha256 of each reflex file with line endings normalised, as drafted in the
#   Claude project. Updated there, and only there, when a reflex file changes.
REFLEX_SHA <- c(
  "README.md" = "661506b1e796079b84092555165e860dcd08eabf478c45c8819a0518b63fc8ce",
  "attitudinal.md" = "02a273b6ffe0428629b2b6c358a40977c11cb40adeb256fe09e3a4f03eba26e4",
  "behavioral.md" = "f41c9ee7abf5111010d65a0aad5885d2f9f90549edc081a18d72cbd9600bb142",
  "core.md" = "d687e2688a6efc55a15d5c3709805e9e30ced3a1ee20a150cc5476e09b4d81f9",
  "cross_cultural.md" = "915d46090cf22e858cbe431bbcc54091c599df18c17efd2e5bfa97662f805f80",
  "evaluate.md" = "12859aecda0cd0b9d841879cd8ff1f22d3e6a67936a1f89b25ee12ba7374fea0",
  "generate.md" = "f7410389ee03de9fa3bf911d7410fa182f93169d0d40b57e96c3d0fb368ab687",
  "mode.md" = "98d2c27cd11711f142e9903a85efd65c902bef4cfa7f4d615df6b0d3df3f60e0",
  "pm_appraise.md" = "1bebaba53a961493eed2d1b4fa7d058d0dab53dd05d3b6113d606364ac6f4211",
  "pm_brief.md" = "daea3b19c360b24817e5b6104a3e798c1444ff7e53b06929614f48584e3e1655",
  "sensitive.md" = "4d8b50d65e768c62143287b3f7400ff7d66695b4905b3d4e0849cc313b81a2eb")

stopifnot("Run from inside QuestionR/" = file.exists("DESIGN.md"))


# ---- helpers ------------------------------------------------------------------

fence <- function(x) c("~~~~", x, "~~~~")
verdict <- function(ok) ifelse(ok, "PASS", "FAIL")
md_table <- function(d) {
  if (!nrow(d)) return("(none)")
  rows = purrr::pmap_chr(d, function(...) paste0("| ", paste(c(...), collapse = " | "), " |"))
  c(paste0("| ", paste(names(d), collapse = " | "), " |"),
    paste0("|", paste(rep("---", ncol(d)), collapse = "|"), "|"), rows)
}
run <- function(cmd, args) {
  out = tryCatch(suppressWarnings(system2(cmd, args, stdout = TRUE, stderr = TRUE)),
                 error = function(e) paste("could not run:", conditionMessage(e)))
  c(out, paste("exit status:", attr(out, "status") %||% 0L))
}
`%||%` <- function(a, b) if (is.null(a)) b else a

# Terminal tokens of one file, from R's own parser, so a loop inside a string
#   or a comment is not counted and a real one cannot hide.
tokens <- function(f) {
  pd = utils::getParseData(parse(f, keep.source = TRUE))
  if (is.null(pd) || !nrow(pd))
    return(tibble::tibble(file = character(), line = integer(), token = character(),
                          text = character(), next2 = character()))
  tibble::as_tibble(pd) |>
    dplyr::filter(terminal) |>
    dplyr::transmute(file = f, line = line1, token, text,
                     next2 = dplyr::lead(text, 2))
}

app_files <- c("app.R", sort(list.files("R", pattern = "[.]R$", full.names = TRUE)))
test_files <- sort(list.files("tests", pattern = "[.]R$", full.names = TRUE))
r_files <- setdiff(list.files("R", pattern = "[.]R$", full.names = TRUE),
                   file.path("R", "_disable_autoload.R"))


# ---- 1. git ---------------------------------------------------------------------

sec_git <- c(
  "## 1. Git", "",
  "Branch:", fence(run("git", c("rev-parse", "--abbrev-ref", "HEAD"))),
  "Last commits:", fence(run("git", c("log", "--oneline", "-15"))),
  "Uncommitted:", fence(run("git", c("status", "--short", "."))),
  "Changed against main (outside QuestionR/ expect only the root README.md and CLAUDE.md):",
  fence(run("git", c("diff", "--stat", "main...HEAD"))))


# ---- 2. files and budget ----------------------------------------------------------

code_files <- setdiff(c(app_files, test_files),
                      c(file.path("R", "_disable_autoload.R"),
                        file.path("tests", "openrouter_check.R")))
file_tbl <- tibble::tibble(
  file = c(app_files, test_files),
  lines = purrr::map_int(file, function(f) length(readLines(f, warn = FALSE))))
autoload <- file.path("R", "_disable_autoload.R")
autoload_ok <- file.exists(autoload) && !length(parse(autoload))

sec_files <- c(
  "## 2. Files and budget", "", md_table(file_tbl), "",
  paste0("Code files counted: ", length(code_files), " of ", CODE_BUDGET,
         " allowed: ", verdict(length(code_files) <= CODE_BUDGET)),
  paste0("R/_disable_autoload.R present and empty of code: ", verdict(autoload_ok)))


# ---- 3. hard rules, from the parse tree -----------------------------------------

tok <- purrr::map(c(app_files, test_files), tokens) |> purrr::list_rbind()
in_app <- tok$file %in% app_files
in_r <- tok$file %in% r_files

hits <- function(keep) {
  d = tok[keep, ]
  if (!nrow(d)) "none" else paste(unique(paste0(d$file, ":", d$line, " ", d$text)), collapse = "; ")
}
rules <- tibble::tribble(
  ~rule, ~found,
  "for / while / repeat, anywhere",
    hits(tok$token %in% c("FOR", "WHILE", "REPEAT")),
  "magrittr pipe %>%, anywhere",
    hits(tok$token == "SPECIAL" & tok$text == "%>%"),
  "library() or require() inside R/",
    hits(in_r & tok$token == "SYMBOL_FUNCTION_CALL" & tok$text %in% c("library", "require")),
  "Sys.setenv() in the app",
    hits(in_app & tok$token == "SYMBOL_FUNCTION_CALL" & tok$text == "Sys.setenv"),
  "addResourcePath() or system.file() in the app",
    hits(in_app & tok$token == "SYMBOL_FUNCTION_CALL" & tok$text %in% c("addResourcePath", "system.file")),
  "parallelism (future, furrr, mirai, parallel, parallel_chat*)",
    hits((tok$token == "SYMBOL_PACKAGE" & tok$text %in% c("future", "furrr", "mirai", "parallel")) |
           (tok$token == "SYMBOL_FUNCTION_CALL" & grepl("^parallel_chat", tok$text))),
  "key read from the environment for a pasted-key model (Sys.getenv in R/, listed for reading)",
    hits(in_r & tok$token == "SYMBOL_FUNCTION_CALL" & tok$text == "Sys.getenv"))
rules$result <- ifelse(rules$found == "none", "PASS", "FAIL")
rules$result[nrow(rules)] <- "READ"

# R/ holds assignments only, and no name is defined twice.
top_level <- purrr::map(r_files, function(f) {
  purrr::map(as.list(parse(f)), function(e) {
    is_assign = is.call(e) &&
      (identical(e[[1]], as.name("<-")) || identical(e[[1]], as.name("=")))
    tibble::tibble(file = f, assign = is_assign,
                   name = if (is_assign) paste(deparse(e[[2]]), collapse = "") else NA_character_,
                   what = substr(paste(deparse(e), collapse = " "), 1, 70))
  }) |> purrr::list_rbind()
}) |> purrr::list_rbind()
if (!nrow(top_level))
  top_level <- tibble::tibble(file = character(), assign = logical(),
                              name = character(), what = character())
not_assign <- dplyr::filter(top_level, !assign)
dup_names <- top_level |>
  dplyr::filter(assign) |>
  dplyr::count(name) |>
  dplyr::filter(n > 1)

# Every pkg::fn in the app names a function that package really exports.
ns_calls <- tok |>
  dplyr::filter(file %in% app_files, token == "SYMBOL_PACKAGE") |>
  dplyr::distinct(pkg = text, fn = next2)
ns_calls$exists <- purrr::map2_lgl(ns_calls$pkg, ns_calls$fn, function(p, f)
  requireNamespace(p, quietly = TRUE) && f %in% getNamespaceExports(p))
bad_calls <- dplyr::filter(ns_calls, !exists)

sec_rules <- c(
  "## 3. Hard rules", "", md_table(rules), "",
  paste0("Top-level expressions in R/ that are not assignments: ",
         verdict(!nrow(not_assign))),
  if (nrow(not_assign)) fence(paste0(not_assign$file, ": ", not_assign$what)),
  paste0("Names defined more than once across R/: ", verdict(!nrow(dup_names))),
  if (nrow(dup_names)) fence(dup_names$name),
  paste0("pkg::fn calls checked: ", nrow(ns_calls), ". Not exported by the installed package: ",
         verdict(!nrow(bad_calls))),
  if (nrow(bad_calls)) fence(paste0(bad_calls$pkg, "::", bad_calls$fn)))


# ---- 4. reflex files untouched --------------------------------------------------

reflex_sha <- function(f) {
  bytes = readBin(f, "raw", file.size(f))
  digest::digest(bytes[bytes != as.raw(13)], algo = "sha256", serialize = FALSE)
}
reflex_tbl <- tibble::tibble(file = names(REFLEX_SHA)) |>
  dplyr::mutate(
    path = file.path("www", "reflexes", file),
    present = file.exists(path),
    sha = purrr::map2_chr(path, present, function(p, ok) if (ok) reflex_sha(p) else NA_character_),
    result = verdict(present & !is.na(sha) & sha == unname(REFLEX_SHA[file])))
extra_reflex_files <- setdiff(list.files(file.path("www", "reflexes")), names(REFLEX_SHA))

sec_reflex_files <- c(
  "## 4. Reflex files", "",
  "PASS means the file is byte for byte what the Claude project drafted (line endings aside).",
  "", md_table(dplyr::select(reflex_tbl, file, result, sha)), "",
  paste0("Files in www/reflexes not on the list: ",
         if (length(extra_reflex_files)) paste(extra_reflex_files, collapse = ", ") else "none"))


# ---- 5. smoke test ---------------------------------------------------------------

rscript <- file.path(R.home("bin"), "Rscript")
sec_smoke <- c(
  "## 5. Smoke test output, verbatim", "",
  if (file.exists(file.path("tests", "smoke.R")))
    fence(run(rscript, c("--no-init-file", file.path("tests", "smoke.R"))))
  else "tests/smoke.R does not exist yet.")


# ---- 6. prompt assembly (Phase 1 on) ----------------------------------------------

# Four fixed forms. The field names are the contract in DESIGN.md section 5.
blank_form <- list(
  task = "", research_question = "", construct = "", population = "",
  country = "", modes = character(0), n_items = NA_integer_, reference_period = "",
  keep_items = "", other = "", questionnaire = "", revision = "")
forms <- list(
  attitudinal = utils::modifyList(blank_form, list(
    task = "attitudinal",
    research_question = "How much do adults trust the national electoral commission?",
    construct = "Trust in the national electoral commission",
    population = "Adults aged 18 and over", modes = "web", n_items = 6L)),
  behavioral = utils::modifyList(blank_form, list(
    task = "behavioral",
    research_question = "How often do adults get news from radio?",
    construct = "Frequency of radio news use",
    population = "Adults aged 18 and over", country = "Kenya",
    modes = c("telephone", "face_to_face"),
    n_items = 3L, reference_period = "past 7 days")),
  sensitive = utils::modifyList(blank_form, list(
    task = "sensitive",
    research_question = "How common is paying a bribe for a public service?",
    construct = "Paying a bribe to a public official in the past 12 months",
    population = "Adults aged 18 and over", country = "Mali",
    modes = "face_to_face", n_items = 2L)),
  evaluate = utils::modifyList(blank_form, list(
    task = "evaluate",
    research_question = "Satisfaction with local services",
    population = "Adults aged 18 and over", modes = "paper",
    questionnaire = paste(
      "Q1. How satisfied or dissatisfied are you with the recycling services and street cleaning provided by your local council? Very satisfied / Fairly satisfied / Neither / Fairly dissatisfied / Very dissatisfied",
      "Q2. Taking all things together, how happy would you say you are? 0 Extremely unhappy ... 10 Extremely happy",
      sep = "\n"))))

has <- function(txt, s) grepl(s, txt, fixed = TRUE)
expect <- function(what, ok) tibble::tibble(check = what, result = verdict(isTRUE(ok)))

prompt_checks <- function(name, p, again, changed) {
  sys = p$system; usr = p$user; both = paste(sys, usr)
  common = dplyr::bind_rows(
    expect("system and user are single strings", is.character(sys) && length(sys) == 1 && is.character(usr) && length(usr) == 1),
    expect("same form twice gives the same hash", identical(p$hash, again$hash)),
    expect("a changed research question changes the hash", !identical(p$hash, changed$hash)),
    expect("persona opens the message, once, and is not in the system prompt",
           startsWith(usr, "You are a senior survey methodologist") && !has(sys, "senior survey methodologist")),
    expect("Brief:, Task:, REPLY FORMAT in that order",
           all(diff(c(regexpr("\nBrief:\n", usr, fixed = TRUE), regexpr("\nTask:\n", usr, fixed = TRUE),
                      regexpr("\nREPLY FORMAT\n", usr, fixed = TRUE))) > 0) && has(usr, "\nBrief:\n")),
    expect("no source text sent (IASS/WSS, SURV632, Sturgis, Tourangeau)",
           !any(purrr::map_lgl(c("IASS/WSS", "SURV632", "Sturgis", "Tourangeau"), function(s) has(both, s)))),
    expect("no HTML comment or Source or Check field sent",
           !has(both, "<!--") && !has(both, "**Source:**") && !has(both, "**Check:**")),
    expect("core reflex one_thing present", has(sys, "- one_thing (")),
    expect("any_mode present", has(sys, "- any_mode (")),
    expect("prohibitions headed as overriding", has(sys, "PROHIBITIONS (override anything from training)")),
    expect("reworded prohibition in force (reflex files 0.2)", has(sys, "Use a rule's id only in a JSON field that asks for one.")))
  is_review = name == "evaluate"
  common = dplyr::bind_rows(common,
    expect("existing_items_first only in drafting prompts", has(sys, "- existing_items_first (") != is_review),
    expect("CHECKLIST block only in a review, after Questionnaire: and before REPLY FORMAT",
           if (is_review) all(diff(c(regexpr("\nQuestionnaire:\n", usr, fixed = TRUE),
                                     regexpr("\nCHECKLIST\n", usr, fixed = TRUE),
                                     regexpr("\nREPLY FORMAT\n", usr, fixed = TRUE))) > 0) &&
                            has(usr, "\nCHECKLIST\n")
           else !has(usr, "CHECKLIST")),
    expect("the drafting output format (open_format) only in drafting prompts", has(usr, "\"open_format\"") != is_review))
  specific = switch(name,
    attitudinal = dplyr::bind_rows(
      expect("task file sent (attitude_object)", has(sys, "- attitude_object (")),
      expect("generate.md sent (declare_defaults)", has(sys, "- declare_defaults (")),
      expect("other task files not sent (reference_period, forgiving_intro)",
             !has(sys, "- reference_period (") && !has(sys, "- forgiving_intro (")),
      expect("web kept; telephone, mobile_web, mixed_mode dropped",
             has(sys, "- web (") && !has(sys, "- telephone (") && !has(sys, "- mobile_web (") && !has(sys, "- mixed_mode (")),
      expect("cross_cultural not sent (no country)", !has(sys, "- flag_do_not_assert (")),
      expect("blank fields left out (no Country, no Reference period line)",
             !has(usr, "Country:") && !has(usr, "Reference period:")),
      expect("number of items in the ask", has(usr, "6"))),
    behavioral = dplyr::bind_rows(
      expect("task file sent (how_many_or_how_often)", has(sys, "- how_many_or_how_often (")),
      expect("telephone, face_to_face, mixed_mode kept; web dropped",
             has(sys, "- telephone (") && has(sys, "- face_to_face (") && has(sys, "- mixed_mode (") && !has(sys, "- web (")),
      expect("cross_cultural sent (flag_do_not_assert, context_and_face)", has(sys, "- flag_do_not_assert (") && has(sys, "- context_and_face (")),
      expect("no translation or language reflex sent (trapd, output_language, write_for_translation)",
             !has(sys, "- trapd (") && !has(sys, "- output_language (") && !has(sys, "- write_for_translation (")),
      expect("form values present (Kenya, past 7 days)", has(usr, "Kenya") && has(usr, "past 7 days"))),
    sensitive = dplyr::bind_rows(
      expect("task file sent (forgiving_intro, respondent_safety)",
             has(sys, "- forgiving_intro (") && has(sys, "- respondent_safety (")),
      expect("face_to_face kept; mixed_mode dropped", has(sys, "- face_to_face (") && !has(sys, "- mixed_mode (")),
      expect("cross_cultural sent", has(sys, "- flag_do_not_assert ("))),
    evaluate = dplyr::bind_rows(
      expect("evaluate.md sent (restraint), and no translation reflex in it",
             has(sys, "- restraint (") && !has(sys, "- translation_readiness (")),
      expect("generate.md and task drafting files not sent",
             !has(sys, "- declare_defaults (") && !has(sys, "- attitude_object (")),
      expect("questionnaire pasted under Questionnaire:, complete",
             has(usr, "Questionnaire:") && has(usr, "street cleaning provided by your local council") && has(usr, "10 Extremely happy")),
      expect("output format asks for a verdict per question and points about the whole", has(usr, "\"verdict\"") && has(usr, "\"instrument\"")),
      expect("checklist lines are id: question, for the reflexes in force (one_thing, paper, agree_disagree_and_grids)",
             has(usr, "\none_thing: Does the question ask about exactly one thing") &&
               has(usr, "\npaper: ") && has(usr, "\nagree_disagree_and_grids: ")),
      expect("checklist has no line for a mode not chosen", !has(usr, "\ntelephone: ")),
      expect("cross_cultural not sent (no country)", !has(sys, "- flag_do_not_assert ("))))
  dplyr::bind_rows(common, specific)
}

sec_prompts <- if (PHASE < 1L) {
  c("## 6. Prompt assembly", "", "Not due until Phase 1.")
} else {
  loaded = tryCatch({
    app = shiny::shinyAppDir(".")
    invisible(app$serverFuncSource())
    exists("build_prompt", mode = "function") && exists("build_checklist", mode = "function")
  }, error = function(e) conditionMessage(e))
  if (!isTRUE(loaded)) {
    c("## 6. Prompt assembly", "",
      paste("FAIL: the app did not load, or build_prompt() / build_checklist() are missing:", loaded))
  } else {
    per_form = purrr::imap(forms, function(form, name) {
      out = tryCatch({
        p = build_prompt(form)
        again = build_prompt(form)
        changed = build_prompt(utils::modifyList(form, list(research_question = "Something else entirely?")))
        checklist = build_checklist(form)
        list(p = p, checks = prompt_checks(name, p, again, changed), checklist = checklist)
      }, error = function(e) conditionMessage(e))
      if (is.character(out))
        return(c(paste0("### ", name), "", paste("FAIL: build_prompt() stopped:", out), ""))
      c(paste0("### ", name), "", md_table(out$checks), "",
        paste0("hash: ", out$p$hash), paste0("files: ", paste(out$p$files, collapse = ", ")),
        paste0("characters: system ", nchar(out$p$system), ", user ", nchar(out$p$user)), "",
        "Checklist (id: question):",
        fence(paste0(names(out$checklist), ": ", unname(out$checklist))),
        "System prompt:", fence(out$p$system), "User message:", fence(out$p$user), "")
    })
    c("## 6. Prompt assembly", "", unlist(per_form, use.names = FALSE))
  }
}


# ---- 7. model layer (Phase 2 on) ------------------------------------------------

sec_llm <- if (PHASE < 2L) {
  c("## 7. Model layer", "", "Not due until Phase 2.")
} else {
  ellmer_fns = ns_calls$fn[ns_calls$pkg == "ellmer" & ns_calls$exists]
  sigs = purrr::map_chr(ellmer_fns, function(f)
    paste0("ellmer::", f, "(", paste(names(formals(get(f, asNamespace("ellmer")))), collapse = ", "), ")"))
  llm_path = file.path("R", "llm.R")
  llm_lines = if (file.exists(llm_path)) readLines(llm_path, warn = FALSE) else character(0)
  keep = grep("ellmer::|credentials|base_url|key_source|key_var|max_tokens|temperature", llm_lines)
  out_path = file.path("tests", "llm_check.out")
  c("## 7. Model layer", "",
    paste0("ellmer version: ", as.character(utils::packageVersion("ellmer"))),
    "Arguments the installed ellmer functions accept:", fence(sigs),
    "Lines in R/llm.R that build calls or handle keys:",
    fence(paste0(keep, ": ", llm_lines[keep])),
    "Live check output (tests/llm_check.out), verbatim:",
    if (file.exists(out_path)) fence(readLines(out_path, warn = FALSE))
    else "tests/llm_check.out does not exist: run tests/llm_check.R first.")
}


# ---- 8. registry and flow engine (Phase 3 on) -------------------------------------

# A fake model: the flow functions reach a model only through ask (DESIGN.md
#   section 12), so the whole flow runs here with canned replies and no call.
fake_item <- function(i) list(
  id = paste0("TR", i), domain = paste("domain", i), intro = "",
  stem = paste0("Canned stem number ", i, "?"),
  options = list("None", "A little", "A lot"), open_format = "", parts = list(),
  programming = "", decisions = list("closed; three labelled options"),
  notes = "")
fake_draft <- function(n) list(items = purrr::map(seq_len(n), fake_item),
                               not_covered = list(), missing_from_brief = list())
fake_pick <- function(i) list(domain = paste("domain", i), candidate = "A", id = paste0("TR", i),
                              check_before_use = "")
fake_appraisal <- list(selected = list(fake_pick(1), fake_pick(2)))
fake_brief <- list(complete = TRUE, questions = list(), task_fit = "",
                   criteria = list("Canned criterion."))
fake_model <- function(id) list(api = "openai", base_url = "https://example.invalid/v1",
                                id = id, key_source = "analyst")
fake_pm <- fake_model("vendor-p/pm-model")
fake_workers <- purrr::map(c("vendor-a/model-one", "vendor-b/model-two",
                             "vendor-c/model-three"), fake_model)

# good: every worker returns the 2 items asked for. bad: the second worker
#   errors and the third returns 3 items, which validate must refuse.
make_ask <- function(bad = FALSE) function(user, m, system_prompt = NULL,
                                           max_tokens = NULL, validate = NULL, ...) {
  if (bad && identical(m$id, "vendor-b/model-two")) stop("canned endpoint error")
  obj = if (identical(m$id, fake_pm$id)) {
    if (grepl("- what_a_brief_needs (", system_prompt, fixed = TRUE)) fake_brief
    else fake_appraisal
  } else fake_draft(if (bad && identical(m$id, "vendor-c/model-three")) 3L else 2L)
  if (!is.null(validate)) validate(obj)
  obj
}

flow_checks <- function() {
  form = utils::modifyList(forms$attitudinal, list(n_items = 2L))
  ids = purrr::map_chr(fake_workers, "id")

  reg = get("TASKS")
  brief = run_brief(form, fake_pm, ask = make_ask())
  good = run_drafts(form, fake_workers, ask = make_ask())
  bad = run_drafts(form, fake_workers, ask = make_ask(bad = TRUE))
  ap = run_appraisal(form, good, fake_pm, ask = make_ask(), seed = 11L)
  ap_same = run_appraisal(form, good, fake_pm, ask = make_ask(), seed = 11L)
  ap_bad = run_appraisal(form, bad, fake_pm, ask = make_ask(), seed = 11L)
  step = build_step_prompt(form, "work")
  status = function(d) purrr::map_chr(unname(d[seq_along(fake_workers)]), "status")
  both = paste(ap$system, ap$user)

  dplyr::bind_rows(
    expect("TASKS has the four tasks, each with label, kind, files, ask, fields",
           all(c("attitudinal", "behavioral", "sensitive", "evaluate") %in% names(reg)) &&
             all(purrr::map_lgl(reg, function(t) all(c("label", "kind", "files", "ask", "fields") %in% names(t))))),
    expect("task kinds are draft or review, evaluate is review",
           all(purrr::map_chr(reg, "kind") %in% c("draft", "review")) && identical(reg$evaluate$kind, "review")),
    expect("build_step_prompt(form, 'work') equals build_prompt(form)",
           identical(step$hash, build_prompt(form)$hash)),
    expect("brief check: status ok, reply has questions and criteria",
           identical(brief$status, "ok") && all(c("questions", "criteria") %in% names(brief$reply))),
    expect("brief check prompt: persona (in the message), pm_brief and the task's rules; no drafting output format",
           startsWith(brief$user, "You are a senior survey methodologist") && has(brief$system, "- what_a_brief_needs (") &&
             has(brief$system, "- attitude_object (") && !has(brief$user, "\"source_english\"")),
    expect("drafts: one entry per worker, in order, all ok",
           identical(purrr::map_chr(unname(good[seq_along(fake_workers)]), "model"), ids) &&
             all(status(good) == "ok")),
    expect("each ok draft keeps the parsed reply with 2 items",
           all(purrr::map_int(unname(good[seq_along(fake_workers)]), function(d) length(d$reply$items)) == 2L)),
    expect("a worker error and a wrong item count are recorded as failed, with a reason, and the run goes on",
           identical(status(bad), c("ok", "failed", "failed")) &&
             all(nzchar(purrr::map_chr(unname(bad[2:3]), function(d) paste(d$error, collapse = " "))))),
    expect("appraisal: status ok, labels A, B, C map onto the three model ids",
           identical(ap$status, "ok") && identical(sort(names(ap$labels)), c("A", "B", "C")) &&
             setequal(unname(ap$labels), ids)),
    expect("same seed gives the same labels", identical(ap$labels, ap_same$labels)),
    expect("only drafts that are ok become candidates",
           identical(names(ap_bad$labels), "A") && identical(unname(ap_bad$labels), ids[1])),
    expect("no model id, vendor or endpoint reaches the appraisal prompt",
           !any(purrr::map_lgl(c(ids, fake_pm$id, "vendor-", "example.invalid"), function(s) has(both, s)))),
    expect("appraisal prompt: CANDIDATES then CHECKLIST then CHARACTERIZE, with the stems and the check questions",
           all(diff(c(regexpr("\nCANDIDATES\n", ap$user, fixed = TRUE),
                      regexpr("\nCHECKLIST\n", ap$user, fixed = TRUE),
                      regexpr("\nCHARACTERIZE\n", ap$user, fixed = TRUE))) > 0) &&
             has(ap$user, "\nCANDIDATES\n") && has(ap$user, "Canned stem number 1?") &&
             has(ap$user, "\none_thing: ") && has(ap$user, "\"selected\"") && has(ap$user, "\"check_before_use\"")),
    expect("documentation checks are not in the appraisal checklist (reflex files 0.3)",
           !has(ap$user, "\ndeclare_defaults: ") && !has(ap$user, "\nmidpoint_and_dont_know: ")),
    expect("appraisal prompt: persona (in the message), pm_appraise rules in the system prompt, not the drafting rules",
           startsWith(ap$user, "You are a senior survey methodologist") && has(ap$system, "- pick_per_domain (") &&
             !has(ap$system, "- declare_defaults (")),
    expect("flow.R has no Shiny in it",
           !any(tok$file == file.path("R", "flow.R") &
                  ((tok$token == "SYMBOL_PACKAGE" & tok$text == "shiny") |
                     (tok$token == "SYMBOL_FUNCTION_CALL" &
                        tok$text %in% c("reactive", "reactiveVal", "observeEvent", "moduleServer",
                                        "showNotification", "withProgress", "getDefaultReactiveDomain"))))),
    expect("flow.R never looks up a key",
           !any(tok$file == file.path("R", "flow.R") & tok$token == "SYMBOL_FUNCTION_CALL" &
                  tok$text %in% c("Sys.getenv", "llm_key_for", "llm_session_key"))))
}

sec_flow <- if (PHASE < 3L) {
  c("## 8. Registry and flow engine", "", "Not due until Phase 3.")
} else {
  out = tryCatch({
    if (!exists("build_prompt", mode = "function")) {
      app = shiny::shinyAppDir(".")
      invisible(app$serverFuncSource())
    }
    flow_checks()
  }, error = function(e) conditionMessage(e))
  log_path = file.path("tests", "run_generate.json")
  c("## 8. Registry and flow engine", "",
    if (is.character(out)) paste("FAIL: the engine checks stopped:", out) else md_table(out), "",
    "Live run log (tests/run_generate.json), first 60 lines:",
    if (file.exists(log_path)) fence(utils::head(readLines(log_path, warn = FALSE), 60))
    else "tests/run_generate.json does not exist yet.")
}


# ---- 9. review flow and gold test (Phase 4 on) -------------------------------------

fake_review <- list(
  items = list(
    list(id = "Q1", verdict = "Revise", problems = list(
      list(problem = "Two services.", rewrite = "x"),
      list(problem = "Street cleaning is unclear.", rewrite = "y"),
      list(problem = "A third problem that is not shown.", rewrite = "z"))),
    list(id = "Q2", verdict = "Keep", problems = list())),
  instrument = list())

review_checks <- function() {
  form = forms$evaluate
  ask = function(user, m, system_prompt = NULL, max_tokens = NULL, validate = NULL, ...) {
    if (!is.null(validate)) validate(fake_review)
    fake_review
  }
  rv = run_review(form, fake_pm, ask = ask)
  shown = shape_review(rv$reply, form$questionnaire)
  bad_ask = function(...) stop("canned endpoint error")
  failed = run_review(form, fake_pm, ask = bad_ask)
  dplyr::bind_rows(
    expect("run_review: status ok, with system, user, hash and the parsed reply",
           identical(rv$status, "ok") && all(c("system", "user", "hash", "reply") %in% names(rv)) &&
             length(rv$reply$items) == 2L),
    expect("run_review uses the prompt build_prompt() gives", identical(rv$hash, build_prompt(form)$hash)),
    expect("a failed call is status failed with a reason, not an R error",
           identical(failed$status, "failed") && nzchar(paste(failed$error, collapse = " "))),
    expect("shape_review gives the question as pasted, a verdict, at most two problems, and the questions to keep",
           identical(purrr::map_chr(shown$questions, "verdict"), c("Revise", "Keep")) &&
             length(shown$questions[[1]]$problems) == 2L && identical(shown$keep, "Q2") &&
             grepl("^Q1\\.", shown$questions[[1]]$text)),
    expect("a third problem is dropped, and no other field of the reply is read",
           !any(grepl("third problem", unlist(shown), fixed = TRUE)) && identical(names(shown), c("questions", "keep", "instrument"))))
}

sec_review <- if (PHASE < 4L) {
  c("## 9. Review flow and gold test", "", "Not due until Phase 4.")
} else {
  out = tryCatch({
    if (!exists("build_prompt", mode = "function")) {
      app = shiny::shinyAppDir(".")
      invisible(app$serverFuncSource())
    }
    review_checks()
  }, error = function(e) conditionMessage(e))
  show_file = function(path, n) {
    if (file.exists(path)) fence(utils::head(readLines(path, warn = FALSE), n))
    else paste(path, "does not exist yet.")
  }
  gold_path = file.path("tests", "gold_items.csv")
  c("## 9. Review flow and gold test", "",
    if (is.character(out)) paste("FAIL: the review checks stopped:", out) else md_table(out), "",
    paste0("tests/gold_items.csv rows: ",
           if (file.exists(gold_path)) length(readLines(gold_path, warn = FALSE)) - 1L else "file missing"),
    "", "Token measurement (tests/review_tokens.md), verbatim:",
    show_file(file.path("tests", "review_tokens.md"), 60), "",
    "Gold test matches (tests/gold_matches.csv), verbatim:",
    show_file(file.path("tests", "gold_matches.csv"), 400), "",
    "Gold test summary (tests/gold_summary.md), verbatim:",
    show_file(file.path("tests", "gold_summary.md"), 80))
}


# ---- 10. long questionnaires, output and methodology (Phase 5 on) ------------------

long_checks <- function() {
  blocks = purrr::map_chr(1:30, function(i)
    paste0("Q", i, ". Canned question number ", i, " ", strrep("word ", 50), "?\nYes / No"))
  text = paste(blocks, collapse = "\n\n")
  parts = split_questionnaire(text, max_chars = 4000)
  joined = paste(parts, collapse = "\n\n")
  too_big = tryCatch({ split_questionnaire(strrep("x", 5000), max_chars = 4000); "no error" },
                     error = function(e) conditionMessage(e))

  form = utils::modifyList(forms$evaluate, list(questionnaire = text))
  calls = new.env()
  calls$n = 0L
  calls$users = character(0)
  canned = function(user) {
    ids = regmatches(user, gregexpr("(?m)^Q[0-9]+(?=\\. )", user, perl = TRUE))[[1]]
    instrument = !grepl("\none_thing: ", user, fixed = TRUE)
    list(items = if (instrument) list() else purrr::map(ids, function(i) list(id = i, verdict = "Keep", problems = list())),
         instrument = if (instrument) list("Canned point about the whole.") else list())
  }
  make = function(fail_at = 0L) function(user, m, system_prompt = NULL, max_tokens = NULL,
                                         validate = NULL, ...) {
    calls$n = calls$n + 1L
    calls$users = c(calls$users, user)
    if (calls$n == fail_at) stop("canned endpoint error")
    obj = canned(user)
    if (!is.null(validate)) validate(obj)
    obj
  }
  rv = run_review(form, fake_pm, ask = make())
  n_ok = calls$n
  users_ok = calls$users
  calls$n = 0L
  calls$users = character(0)
  part = run_review(form, fake_pm, ask = make(fail_at = 2L))
  short = run_review(forms$evaluate, fake_pm, ask = make())
  tab = reflexes_table()

  dplyr::bind_rows(
    expect("split: more than one part, none over the limit", length(parts) > 1L && all(nchar(parts) <= 4000)),
    expect("split: every block kept whole, once, in order", identical(joined, text)),
    expect("split: a single block over the limit stops with a message", !identical(too_big, "no error")),
    expect("long review: one call per part and one for the instrument",
           n_ok == length(parts) + 1L),
    expect("long review: item calls carry no instrument checks, the instrument call carries no item checks",
           sum(grepl("\nscale_consistency: ", users_ok, fixed = TRUE)) == 1L &&
             sum(grepl("\none_thing: ", users_ok, fixed = TRUE)) == length(parts)),
    expect("long review: status ok, all 30 items in pasted order, the points about the whole kept",
           identical(rv$status, "ok") &&
             identical(purrr::map_chr(rv$reply$items, "id"), paste0("Q", 1:30)) &&
             length(rv$reply$instrument) == 1L),
    expect("long review: batches recorded, one per call, each with status and hash",
           length(rv$batches) == length(parts) + 1L &&
             all(purrr::map_lgl(rv$batches, function(b) all(c("status", "hash") %in% names(b))))),
    expect("a failed part gives status partial, names the part, and keeps the rest",
           identical(part$status, "partial") && length(part$reply$items) > 0L &&
             length(part$reply$items) < 30L &&
             sum(purrr::map_chr(part$batches, "status") == "failed") == 1L),
    expect("a short questionnaire is still one call with the Phase 4 prompt",
           identical(short$hash, build_prompt(forms$evaluate)$hash) && length(short$batches) == 1L),
    expect("reflexes_table: one row per reflex with file, id, when, source",
           is.data.frame(tab) && all(c("file", "id", "when", "source") %in% names(tab)) && nrow(tab) > 80L),
    expect("www/methodology.md present", file.exists(file.path("www", "methodology.md"))))
}

sec_long <- if (PHASE < 5L) {
  c("## 10. Long questionnaires, output and methodology", "", "Not due until Phase 5.")
} else {
  out = tryCatch({
    if (!exists("build_prompt", mode = "function")) {
      app = shiny::shinyAppDir(".")
      invisible(app$serverFuncSource())
    }
    long_checks()
  }, error = function(e) conditionMessage(e))
  show_file = function(path, n) {
    if (file.exists(path)) fence(utils::head(readLines(path, warn = FALSE), n))
    else paste(path, "does not exist yet.")
  }
  c("## 10. Long questionnaires, output and methodology", "",
    if (is.character(out)) paste("FAIL: the checks stopped:", out) else md_table(out), "",
    "Long live review (tests/review_long.md), verbatim:",
    show_file(file.path("tests", "review_long.md"), 80), "",
    "Sample output for Word, drafting (tests/output_generate.txt), verbatim:",
    show_file(file.path("tests", "output_generate.txt"), 120), "",
    "Sample output for Word, review (tests/output_review.txt), verbatim:",
    show_file(file.path("tests", "output_review.txt"), 120))
}


# ---- write ----------------------------------------------------------------------

pkgs <- c("shiny", "bslib", "ellmer", "purrr", "dplyr", "stringr", "jsonlite", "digest")
versions <- purrr::map_chr(pkgs, function(p)
  tryCatch(as.character(utils::packageVersion(p)), error = function(e) "not installed"))

writeLines(c(
  paste0("# QuestionR review evidence, Phase ", PHASE), "",
  "From Phase 9, \"skills\" are called \"reflexes\". This file keeps the old word where it records earlier work.", "",
  paste0("Generated ", format(Sys.time(), "%Y-%m-%d %H:%M"), " by tests/review.R on ",
         R.version.string, "."),
  paste0("Packages: ", paste0(pkgs, " ", versions, collapse = ", ")), "",
  sec_git, "", sec_files, "", sec_rules, "", sec_reflex_files, "", sec_smoke, "",
  sec_prompts, "", sec_llm, "", sec_flow, "", sec_review, "", sec_long), "REVIEW.md", useBytes = TRUE)

cat("Wrote REVIEW.md for Phase", PHASE, "\n")
