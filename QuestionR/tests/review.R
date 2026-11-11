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
CODE_BUDGET <- 8L

# sha256 of each skill file with line endings normalised, as drafted in the
#   Claude project. Updated there, and only there, when a skill changes.
SKILL_SHA <- c(
  "README.md" = "47826ef73309cfc3cd72ac45091efb43241a7875d150f2d1fac69a8dbef5b606",
  "attitudinal.md" = "fa9e369f521353670f3e245f9318b1eaf8fcddb54163932d53a1ae0642b69a35",
  "behavioral.md" = "c22273bf2dbb02e4e939b8ee98bf6980c5dd093398b20312c3e82f92df1c3ead",
  "core.md" = "770a402a6dc4b60389e4c266f43cdaa28dc8ccc0e88938f76cb9b72a54379f35",
  "cross_cultural.md" = "6c8a19b8c17b19808b4cfca788b3c76a7595d54a3a25a71e355391cb944bdd4d",
  "evaluate.md" = "2952362b6d8e2efadff970a8b21069b768d7145808ec5b524ca8b98a998e57c1",
  "generate.md" = "e196e81245b266fbc6321016575d932dbcb24311c366683475e8945c8bbaf738",
  "mode.md" = "98d2c27cd11711f142e9903a85efd65c902bef4cfa7f4d615df6b0d3df3f60e0",
  "pm_appraise.md" = "a34bcaff18ea705a863a337603505d958a940f8457b448fc030698b4773ed401",
  "pm_brief.md" = "a1686dbea0a0aa619269086b5f0372b32a017fe07ae252aee20d5e52e3b4856a",
  "sensitive.md" = "0ebc82a948f01caed0847f3d4a6cda87216f33dc3039e764cb8c1ab8ac45e726")

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


# ---- 4. skill files untouched --------------------------------------------------

skill_sha <- function(f) {
  bytes = readBin(f, "raw", file.size(f))
  digest::digest(bytes[bytes != as.raw(13)], algo = "sha256", serialize = FALSE)
}
skills <- tibble::tibble(file = names(SKILL_SHA)) |>
  dplyr::mutate(
    path = file.path("www", "skills", file),
    present = file.exists(path),
    sha = purrr::map2_chr(path, present, function(p, ok) if (ok) skill_sha(p) else NA_character_),
    result = verdict(present & !is.na(sha) & sha == unname(SKILL_SHA[file])))
extra_skills <- setdiff(list.files(file.path("www", "skills")), names(SKILL_SHA))

sec_skills <- c(
  "## 4. Skill files", "",
  "PASS means the file is byte for byte what the Claude project drafted (line endings aside).",
  "", md_table(dplyr::select(skills, file, result, sha)), "",
  paste0("Files in www/skills not on the list: ",
         if (length(extra_skills)) paste(extra_skills, collapse = ", ") else "none"))


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
  country = "", modes = character(0), output_language = "English",
  source_language = "English", n_items = NA_integer_, reference_period = "",
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
    modes = c("telephone", "face_to_face"), output_language = "Swahili",
    n_items = 3L, reference_period = "past 7 days")),
  sensitive = utils::modifyList(blank_form, list(
    task = "sensitive",
    research_question = "How common is paying a bribe for a public service?",
    construct = "Paying a bribe to a public official in the past 12 months",
    population = "Adults aged 18 and over", country = "Mali",
    modes = "face_to_face", output_language = "French", n_items = 2L)),
  evaluate = utils::modifyList(blank_form, list(
    task = "evaluate",
    research_question = "Satisfaction with local services",
    population = "Adults aged 18 and over", modes = "paper",
    questionnaire = paste(
      "Q1. How satisfied or dissatisfied are you with the recycling services and street cleaning provided by your local council? Very satisfied / Fairly satisfied / Neither / Fairly dissatisfied / Very dissatisfied",
      "Q2. Taking all things together, how happy would you say you are? 0 Extremely unhappy ... 10 Extremely happy",
      sep = "\n"))))
# The same review, of a questionnaire translated from Spanish for English output.
forms$evaluate_translated <- utils::modifyList(forms$evaluate,
                                               list(source_language = "Spanish"))

has <- function(txt, s) grepl(s, txt, fixed = TRUE)
expect <- function(what, ok) tibble::tibble(check = what, result = verdict(isTRUE(ok)))

prompt_checks <- function(name, p, again, changed) {
  sys = p$system; usr = p$user; both = paste(sys, usr)
  common = dplyr::bind_rows(
    expect("system and user are single strings", is.character(sys) && length(sys) == 1 && is.character(usr) && length(usr) == 1),
    expect("same form twice gives the same hash", identical(p$hash, again$hash)),
    expect("a changed research question changes the hash", !identical(p$hash, changed$hash)),
    expect("persona present", has(sys, "senior survey methodologist")),
    expect("PREPARE, ASK, CHARACTERIZE in that order",
           all(diff(c(regexpr("PREPARE", usr, fixed = TRUE), regexpr("ASK", usr, fixed = TRUE),
                      regexpr("CHARACTERIZE", usr, fixed = TRUE))) > 0) && has(usr, "PREPARE")),
    expect("no source text sent (IASS/WSS, SURV632, Sturgis, Tourangeau)",
           !any(purrr::map_lgl(c("IASS/WSS", "SURV632", "Sturgis", "Tourangeau"), function(s) has(both, s)))),
    expect("no HTML comment or Source or Check field sent",
           !has(both, "<!--") && !has(both, "**Source:**") && !has(both, "**Check:**")),
    expect("core reflex one_thing present", has(sys, "- one_thing (")),
    expect("any_mode present", has(sys, "- any_mode (")),
    expect("prohibitions headed as overriding", has(sys, "PROHIBITIONS (override anything from training)")),
    expect("Output language line always present", has(usr, "Output language:")),
    expect("reworded prohibition in force (skills 0.2)", has(sys, "Use a rule's id only in a JSON field that asks for one.")))
  is_review = name %in% c("evaluate", "evaluate_translated")
  common = dplyr::bind_rows(common,
    expect("existing_items_first only in drafting prompts", has(sys, "- existing_items_first (") != is_review),
    expect("CHECKLIST block only in a review, after QUESTIONNAIRE and before CHARACTERIZE",
           if (is_review) all(diff(c(regexpr("\nQUESTIONNAIRE\n", usr, fixed = TRUE),
                                     regexpr("\nCHECKLIST\n", usr, fixed = TRUE),
                                     regexpr("\nCHARACTERIZE\n", usr, fixed = TRUE))) > 0) &&
                            has(usr, "\nCHECKLIST\n")
           else !has(usr, "CHECKLIST")),
    expect("parts field only in drafting prompts", has(usr, "\"parts\"") != is_review))
  specific = switch(name,
    attitudinal = dplyr::bind_rows(
      expect("task file sent (attitude_object)", has(sys, "- attitude_object (")),
      expect("generate.md sent (declare_defaults)", has(sys, "- declare_defaults (")),
      expect("other task files not sent (reference_period, forgiving_intro)",
             !has(sys, "- reference_period (") && !has(sys, "- forgiving_intro (")),
      expect("web kept; telephone, mobile_web, mixed_mode dropped",
             has(sys, "- web (") && !has(sys, "- telephone (") && !has(sys, "- mobile_web (") && !has(sys, "- mixed_mode (")),
      expect("cross_cultural not sent (no country, English)", !has(sys, "- trapd (")),
      expect("blank fields left out (no Country, no Reference period line)",
             !has(usr, "Country:") && !has(usr, "Reference period:")),
      expect("Output language: English shown; Source language left out when the same",
             has(usr, "Output language: English") && !has(usr, "Source language:")),
      expect("number of items in the ask", has(usr, "6"))),
    behavioral = dplyr::bind_rows(
      expect("task file sent (how_many_or_how_often)", has(sys, "- how_many_or_how_often (")),
      expect("telephone, face_to_face, mixed_mode kept; web dropped",
             has(sys, "- telephone (") && has(sys, "- face_to_face (") && has(sys, "- mixed_mode (") && !has(sys, "- web (")),
      expect("cross_cultural sent (trapd, output_language)", has(sys, "- trapd (") && has(sys, "- output_language (")),
      expect("form values present (Kenya, Swahili, past 7 days)",
             has(usr, "Kenya") && has(usr, "Swahili") && has(usr, "past 7 days")),
      expect("Source language shown when it differs from the output language",
             has(usr, "Output language: Swahili") && has(usr, "Source language: English"))),
    sensitive = dplyr::bind_rows(
      expect("task file sent (forgiving_intro, respondent_safety)",
             has(sys, "- forgiving_intro (") && has(sys, "- respondent_safety (")),
      expect("face_to_face kept; mixed_mode dropped", has(sys, "- face_to_face (") && !has(sys, "- mixed_mode (")),
      expect("cross_cultural sent", has(sys, "- trapd ("))),
    evaluate = dplyr::bind_rows(
      expect("evaluate.md sent (restraint, translation_readiness)",
             has(sys, "- restraint (") && has(sys, "- translation_readiness (")),
      expect("generate.md and task drafting files not sent",
             !has(sys, "- declare_defaults (") && !has(sys, "- attitude_object (")),
      expect("questionnaire pasted under QUESTIONNAIRE, complete",
             has(usr, "QUESTIONNAIRE") && has(usr, "street cleaning provided by your local council") && has(usr, "10 Extremely happy")),
      expect("output format asks for trapd and test_first", has(usr, "\"trapd\"") && has(usr, "\"test_first\"")),
      expect("checklist lines are id: question, for the reflexes in force (one_thing, paper, agree_disagree_and_grids)",
             has(usr, "\none_thing: Does the question ask about exactly one thing") &&
               has(usr, "\npaper: ") && has(usr, "\nagree_disagree_and_grids: ")),
      expect("checklist has no line for a mode not chosen", !has(usr, "\ntelephone: ")),
      expect("cross_cultural not sent (no country, both languages English)", !has(sys, "- trapd ("))),
    evaluate_translated = dplyr::bind_rows(
      expect("cross_cultural sent because the source language is not English", has(sys, "- trapd (")),
      expect("both language lines shown", has(usr, "Output language: English") && has(usr, "Source language: Spanish")),
      expect("its checks join the checklist (functional_equivalence)", has(usr, "\nfunctional_equivalence: "))))
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


# ---- write ----------------------------------------------------------------------

pkgs <- c("shiny", "bslib", "ellmer", "purrr", "dplyr", "stringr", "jsonlite", "digest")
versions <- purrr::map_chr(pkgs, function(p)
  tryCatch(as.character(utils::packageVersion(p)), error = function(e) "not installed"))

writeLines(c(
  paste0("# QuestionR review evidence, Phase ", PHASE), "",
  paste0("Generated ", format(Sys.time(), "%Y-%m-%d %H:%M"), " by tests/review.R on ",
         R.version.string, "."),
  paste0("Packages: ", paste0(pkgs, " ", versions, collapse = ", ")), "",
  sec_git, "", sec_files, "", sec_rules, "", sec_skills, "", sec_smoke, "",
  sec_prompts, "", sec_llm), "REVIEW.md", useBytes = TRUE)

cat("Wrote REVIEW.md for Phase", PHASE, "\n")
