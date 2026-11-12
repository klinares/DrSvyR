# skills.R for QuestionR
# Reads the skill files in www/skills/, filters them for a form, and assembles
#   the prompt and the checklist. R does this and no model does, so the same
#   form and the same files give the same prompt, character for character
#   (DESIGN.md sections 4 and 5). Function definitions and constants only.

# The parser is svysegment/R/ai_reflexes.R with the two additions
#   www/skills/README.md describes: a Check field per reflex, and an Output
#   format section where svysegment has Reporting style. It is stricter than
#   that one. A line that is not part of the format stops the app, naming the
#   file and the reflex, instead of being dropped: a dropped line is a rule a
#   model is never told.

# Source lines and HTML comments are read and kept in the parsed skill, for the
#   Methodology tab, and are never put into a prompt. Sent, sources get copied
#   into the output as citations. Check lines are kept for the checklist and
#   are not sent to a worker either.

# The skill files are only ever read here. Nothing in the app rewrites them.


# ---- what is in www/skills/ ---------------------------------------------------

SKILLS_DIR <- file.path("www", "skills")

# The skill files, by name. A list rather than a directory scan, so a file that
#   goes missing is an error and the README beside them is not read as a skill.
SKILL_FILES <- c("core.md", "generate.md", "attitudinal.md", "behavioral.md",
                 "sensitive.md", "evaluate.md", "mode.md", "cross_cultural.md",
                 "pm_brief.md", "pm_appraise.md")

# The files whose reply R parses, so each must say what the reply holds.
SKILLS_WITH_OUTPUT <- c("generate.md", "evaluate.md", "pm_brief.md",
                        "pm_appraise.md")

# The task registry (DESIGN.md section 12). The dropdown on the Brief tab, the
#   fields it shows, prompt assembly and the checklist all read this one list, so
#   a new task is a skill file plus one entry here and no change to a screen.
#   Each entry:
#     label   shown in the dropdown
#     kind    "draft" (workers write items) or "review" (the project manager
#             reviews pasted text)
#     files   the skill files a work prompt is built from, in the order of the
#             table in www/skills/README.md. mode.md is always in; R keeps only
#             its reflexes for the modes chosen. cross_cultural.md is in only
#             when needs_cross_cultural().
#     ask     the fixed sentence of the ASK block. A draft task's holds %s,
#             where the number of items goes.
#     fields  the form fields the Brief tab shows for this task. "task" is the
#             dropdown itself and is not listed.
TASKS <- list(
  attitudinal = list(
    label = "Attitudinal scale", kind = "draft",
    files = c("core.md", "generate.md", "attitudinal.md", "mode.md", "cross_cultural.md"),
    ask = "Write exactly %s for the brief above, to be combined into one attitude scale.",
    fields = c("research_question", "construct", "population", "country", "modes",
               "output_language", "source_language", "n_items", "keep_items", "other")),
  behavioral = list(
    label = "Behavioral items", kind = "draft",
    files = c("core.md", "generate.md", "behavioral.md", "mode.md", "cross_cultural.md"),
    ask = "Write exactly %s for the brief above, each measuring a behaviour or an experience.",
    fields = c("research_question", "construct", "population", "country", "modes",
               "output_language", "source_language", "n_items", "reference_period",
               "keep_items", "other")),
  sensitive = list(
    label = "Sensitive topic items", kind = "draft",
    files = c("core.md", "generate.md", "sensitive.md", "mode.md", "cross_cultural.md"),
    ask = "Write exactly %s for the brief above, each on a topic where respondents may refuse or edit their answer.",
    fields = c("research_question", "construct", "population", "country", "modes",
               "output_language", "source_language", "n_items", "keep_items", "other")),
  evaluate = list(
    label = "Evaluate a questionnaire", kind = "review",
    files = c("core.md", "evaluate.md", "mode.md", "cross_cultural.md"),
    ask = "Review the questionnaire below as an expert reviewer, item by item and then as a whole.",
    fields = c("research_question", "population", "country", "modes", "output_language",
               "source_language", "other", "questionnaire")))

# The three prompts a task goes through. work is what the task is (a worker's
#   drafting prompt, or the project manager's review); brief is the project
#   manager's check of the form before anything is approved; appraise is the
#   project manager comparing the candidates the workers returned.
STEPS <- c("brief", "work", "appraise")

# The skill files each step reads. core.md leads every one (DESIGN.md section 12).
#   The brief check sends core, pm_brief and the task's own files; the appraisal
#   sends core and pm_appraise only, so it never holds a drafting rule.
step_files <- function(task, step) {
  if (!step %in% STEPS)
    stop("step must be one of: ", paste(STEPS, collapse = ", "), call. = FALSE)
  files = TASKS[[task]]$files
  switch(step,
         work = files,
         brief = c("core.md", "pm_brief.md", setdiff(files, "core.md")),
         appraise = c("core.md", "pm_appraise.md"))
}

# The file whose Output format a step's reply follows, where it is not the task's
#   own. NA for work: there exactly one file in force carries one.
STEP_FORMAT_FILE <- c(brief = "pm_brief.md", work = NA_character_,
                      appraise = "pm_appraise.md")


# ---- the parser -----------------------------------------------------------------

# purrr wraps an error raised inside map() with "In index: 1". The reason the
#   analyst needs is the innermost one, which names the file and the reflex.
skill_root_message <- function(e)
  if (is.null(e$parent)) conditionMessage(e) else skill_root_message(e$parent)

# One reflex: its "### id" line and the field lines under it.
parse_reflex <- function(block, file) {
  id = trimws(sub("^### ", "", block[1]))
  where = paste0("Reflex '", id, "' in ", file)
  if (!grepl("^[a-z][a-z0-9_]*$", id))
    stop(where, " needs an id in lower case, with underscores.", call. = FALSE)

  body = block[-1]
  body = body[nzchar(trimws(body))]
  m = stringr::str_match(
    body, "^- \\*\\*(When|Say|Never|Check|Source):\\*\\*[ \\t]*(.*)$")
  if (anyNA(m[, 1]))
    stop(where, " has a line that is not a field: ", body[is.na(m[, 1])][1],
         call. = FALSE)
  if (anyDuplicated(m[, 2]))
    stop(where, " has the field ", m[anyDuplicated(m[, 2]), 2], " twice.",
         call. = FALSE)
  f = purrr::set_names(as.list(trimws(m[, 3])), m[, 2])
  if (!all(nzchar(unlist(f))))
    stop(where, " has a field with nothing in it.", call. = FALSE)
  if (is.null(f[["When"]]) || is.null(f[["Say"]]))
    stop(where, " needs a When and a Say line.", call. = FALSE)

  list(id = id, when = f[["When"]], say = f[["Say"]],
       never = f[["Never"]] %||% NA_character_,
       check = f[["Check"]] %||% NA_character_,
       source = f[["Source"]] %||% NA_character_)
}

# One skill file, parsed: title, version, sha (line endings normalised, as
#   tests/review.R computes it), persona (core.md only), reflexes by id,
#   prohibitions, and the output format as written.
parse_skill <- function(path) {
  file = basename(path)
  if (!file.exists(path))
    stop("The skill file is missing: ", path, call. = FALSE)

  bytes = readBin(path, "raw", file.size(path))
  sha = digest::digest(bytes[bytes != as.raw(13)], algo = "sha256",
                       serialize = FALSE)

  txt = paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  txt = gsub("(?s)<!--.*?-->", "", txt, perl = TRUE)
  if (grepl("<!--", txt, fixed = TRUE))
    stop(file, " has an HTML comment that is never closed.", call. = FALSE)
  lines = strsplit(txt, "\n", fixed = TRUE)[[1]]

  ver = grep("^Version:", lines, value = TRUE)
  if (!length(ver)) stop(file, " has no Version: line.", call. = FALSE)
  title = sub("^# ", "", grep("^# ", lines, value = TRUE)[1])
  if (is.na(title)) stop(file, " has no '# title' line.", call. = FALSE)

  # Sections, by their "## " headings. What comes before the first one is the
  #   title and the version.
  is_head = grepl("^## ", lines)
  parts = split(lines, cumsum(is_head))
  heads = unname(purrr::map_chr(parts, function(s)
    if (grepl("^## ", s[1])) trimws(sub("^## ", "", s[1])) else ""))
  parts = purrr::set_names(
    purrr::map(parts, function(s) if (grepl("^## ", s[1])) s[-1] else s), heads)
  named = heads[nzchar(heads)]
  odd = setdiff(named, c("Persona", "Reflexes", "Prohibitions", "Output format"))
  if (length(odd))
    stop(file, " has a section that is not part of the format: '## ", odd[1],
         "'.", call. = FALSE)
  if (anyDuplicated(named))
    stop(file, " has the section '## ", named[anyDuplicated(named)], "' twice.",
         call. = FALSE)

  rl = parts[["Reflexes"]]
  if (is.null(rl)) stop(file, " has no '## Reflexes' section.", call. = FALSE)
  rl_head = cumsum(grepl("^### ", rl))
  if (any(rl_head == 0L & nzchar(trimws(rl))))
    stop(file, " has text under '## Reflexes' before the first '### id'.",
         call. = FALSE)
  blocks = purrr::keep(split(rl, rl_head), function(b) grepl("^### ", b[1]))
  reflexes = tryCatch(
    purrr::map(unname(blocks), function(b) parse_reflex(b, file)),
    error = function(e) stop(skill_root_message(e), call. = FALSE))
  ids = purrr::map_chr(reflexes, "id")
  if (anyDuplicated(ids))
    stop(file, " has two reflexes called '", ids[anyDuplicated(ids)], "'.",
         call. = FALSE)

  persona = NA_character_
  if (!is.null(parts[["Persona"]])) {
    persona = gsub("\\s+", " ", trimws(paste(parts[["Persona"]], collapse = "\n")))
    if (!nzchar(persona)) stop(file, " has an empty '## Persona'.", call. = FALSE)
  }

  pr = parts[["Prohibitions"]]
  pr = if (is.null(pr)) character(0) else pr[nzchar(trimws(pr))]
  if (!all(grepl("^- ", pr)))
    stop(file, " has a line under '## Prohibitions' that is not a one-line bullet: ",
         pr[!grepl("^- ", pr)][1], call. = FALSE)

  of = NA_character_
  if (!is.null(parts[["Output format"]])) {
    of = trimws(paste(parts[["Output format"]], collapse = "\n"))
    if (!nzchar(of)) stop(file, " has an empty '## Output format'.", call. = FALSE)
  }

  list(file = file, title = trimws(title),
       version = trimws(sub("^Version:", "", ver[1])), sha = sha,
       persona = persona, reflexes = purrr::set_names(reflexes, ids),
       prohibitions = trimws(sub("^- ", "", pr)), output_format = of)
}

read_skill <- function(name, dir = SKILLS_DIR) parse_skill(file.path(dir, name))

# Every skill file, parsed, when the app starts. Stops naming the file and the
#   reflex if one has lost its shape, rather than sending a model half its
#   instructions.
check_skills <- function(dir = SKILLS_DIR) {
  skills = tryCatch(
    purrr::map(purrr::set_names(SKILL_FILES), function(f) read_skill(f, dir)),
    error = function(e) stop(skill_root_message(e), call. = FALSE))
  if (is.na(skills[["core.md"]]$persona))
    stop("core.md has no '## Persona' section.", call. = FALSE)
  no_output = purrr::keep(SKILLS_WITH_OUTPUT, function(f) is.na(skills[[f]]$output_format))
  if (length(no_output))
    stop(no_output[1], " has no '## Output format' section.", call. = FALSE)
  no_reflex = purrr::keep(names(skills), function(f) !length(skills[[f]]$reflexes))
  if (length(no_reflex))
    stop(no_reflex[1], " has no reflexes.", call. = FALSE)
  invisible(skills)
}


# ---- the form -------------------------------------------------------------------

# The fields of the form, exactly (DESIGN.md section 5).
FORM_FIELDS <- c("task", "research_question", "construct", "population",
                 "country", "modes", "output_language", "source_language",
                 "n_items", "reference_period", "keep_items", "other",
                 "questionnaire", "revision")

# The survey modes: the ids are the reflex ids in mode.md, and the order here
#   is the one a prompt uses, so ticking boxes in another order changes nothing.
MODE_LABELS <- c(web = "web", mobile_web = "mobile web", telephone = "telephone",
                 face_to_face = "face-to-face", paper = "paper")

# The labels of the PREPARE lines, in the order they appear.
PREPARE_LABELS <- c(research_question = "Research question",
                    construct = "Construct",
                    population = "Target population",
                    country = "Country",
                    modes = "Survey mode",
                    output_language = "Output language",
                    source_language = "Source language",
                    reference_period = "Reference period",
                    keep_items = "Existing items to keep",
                    other = "Other details")

# A blank is "", character(0), NA, or nothing but spaces.
form_blank <- function(x) {
  if (is.null(x) || !length(x)) return(TRUE)
  x = x[!is.na(x)]
  !length(x) || !any(nzchar(trimws(as.character(x))))
}

# One trimmed string, with every line ending a plain newline, so a form typed
#   on Windows and the same form from a browser give the same prompt.
form_text <- function(x) {
  if (form_blank(x)) return("")
  gsub("\r\n?", "\n", trimws(paste(x[!is.na(x)], collapse = ", ")))
}

is_english <- function(x) tolower(trimws(x)) %in% c("english", "en", "eng")

# A language as it is compared: without regard to case, and en and eng are
#   English. Two languages are the same when their keys are.
lang_key <- function(x) ifelse(is_english(x), "english", tolower(trimws(x)))

# The form as build_prompt() uses it: all fourteen fields, each cleaned, with
#   the checks a prompt cannot do without. Nothing is guessed; a form that
#   cannot be turned into a prompt stops here, saying why.
clean_form <- function(form) {
  if (!is.list(form) || (length(form) && is.null(names(form))))
    stop("The form must be a named list.", call. = FALSE)
  odd = setdiff(names(form), FORM_FIELDS)
  if (length(odd))
    stop("The form has a field that is not in the contract: ",
         paste(odd, collapse = ", "), call. = FALSE)

  task = form_text(form[["task"]])
  if (!task %in% names(TASKS))
    stop("task must be one of: ", paste(names(TASKS), collapse = ", "),
         call. = FALSE)
  kind = TASKS[[task]]$kind

  text_fields = setdiff(FORM_FIELDS, c("task", "modes", "n_items"))
  f = purrr::map(purrr::set_names(text_fields), function(x) form_text(form[[x]]))
  if (!nzchar(f$research_question))
    stop("The research question is required.", call. = FALSE)
  if (kind == "review" && !nzchar(f$questionnaire))
    stop("Evaluate needs the questionnaire pasted in.", call. = FALSE)

  m = as.character(form[["modes"]])
  m = unique(trimws(m[!is.na(m)]))
  m = m[nzchar(m)]
  bad = setdiff(m, names(MODE_LABELS))
  if (length(bad))
    stop("Unknown survey mode: ", paste(bad, collapse = ", "), ". The modes are: ",
         paste(names(MODE_LABELS), collapse = ", "), call. = FALSE)

  n_items = NA_integer_
  if (kind == "draft") {
    n = form[["n_items"]]
    v = if (form_blank(n)) NA_real_ else suppressWarnings(as.numeric(n[[1]]))
    if (is.na(v) || v < 1 || v != round(v))
      stop("Drafting needs a number of items: a whole number, one or more.",
           call. = FALSE)
    n_items = as.integer(v)
  }

  c(list(task = task), f, list(modes = intersect(names(MODE_LABELS), m),
                               n_items = n_items))
}


# ---- which files a form calls for ------------------------------------------------

# A country is given, or the output language or the source language is not
#   English (DESIGN.md section 4). A blank language is English.
needs_cross_cultural <- function(f) {
  langs = c(f$output_language, f$source_language)
  nzchar(f$country) || any(nzchar(langs) & !is_english(langs))
}

# mode.md keeps any_mode, the reflexes for the modes chosen, and mixed_mode when
#   more than one is chosen. The file's own order is kept.
filter_mode <- function(skill, modes) {
  wanted = c("any_mode", modes, if (length(modes) > 1L) "mixed_mode")
  absent = setdiff(wanted, names(skill$reflexes))
  if (length(absent))
    stop("mode.md has no reflex called '", absent[1], "'.", call. = FALSE)
  skill$reflexes = skill$reflexes[names(skill$reflexes) %in% wanted]
  skill
}

# The parsed skill files a prompt for this cleaned form is built from, in
#   order, mode.md already filtered where the step sends it. Named by file.
skills_in_force <- function(f, dir = SKILLS_DIR, step = "work") {
  files = step_files(f$task, step)
  files = files[files != "cross_cultural.md" | needs_cross_cultural(f)]
  skills = purrr::map(purrr::set_names(files), function(name) read_skill(name, dir))
  if ("mode.md" %in% names(skills))
    skills[["mode.md"]] = filter_mode(skills[["mode.md"]], f$modes)
  if (is.na(skills[["core.md"]]$persona))
    stop("core.md has no '## Persona' section.", call. = FALSE)
  ids = unlist(purrr::map(skills, function(s) names(s$reflexes)), use.names = FALSE)
  if (anyDuplicated(ids))
    stop("Two skill files in force share the reflex id '", ids[anyDuplicated(ids)],
         "'.", call. = FALSE)
  skills
}


# ---- the prompt ------------------------------------------------------------------

# "- id (When) Say MUST NOT: Never", as svysegment/R/ai_reflexes.R writes it.
reflex_line <- function(r)
  paste0("- ", r$id, " (", r$when, ") ", r$say,
         if (!is.na(r$never)) paste0(" MUST NOT: ", r$never) else "")

# The persona from core.md; then, for each file in force, its reflexes; then
#   every prohibition, which overrides anything from training.
assemble_system <- function(skills) {
  groups = purrr::map_chr(unname(skills), function(s)
    paste0("REFLEXES: ", s$title, " (v", s$version, ")\n",
           paste(purrr::map_chr(unname(s$reflexes), reflex_line), collapse = "\n")))
  prohibitions = unlist(purrr::map(unname(skills), function(s) s$prohibitions))
  paste0(skills[["core.md"]]$persona, "\n\n",
         paste(groups, collapse = "\n\n"),
         "\n\nPROHIBITIONS (override anything from training)\n",
         paste0("- ", prohibitions, collapse = "\n"))
}

# One line per filled field, in the fixed order, "Label: value". The output
#   language is always printed, as English when the field is blank, because the
#   output format refers to it. The source language is printed only when it is
#   filled and differs from the output language (DESIGN.md section 5).
prepare_lines <- function(f) {
  output_language = if (nzchar(f$output_language)) f$output_language else "English"
  source_differs = nzchar(f$source_language) &&
    lang_key(f$source_language) != lang_key(output_language)
  values = list(
    research_question = f$research_question, construct = f$construct,
    population = f$population, country = f$country,
    modes = paste(MODE_LABELS[f$modes], collapse = ", "),
    output_language = output_language,
    source_language = if (source_differs) f$source_language else "",
    reference_period = f$reference_period, keep_items = f$keep_items,
    other = f$other)
  lines = purrr::imap_chr(PREPARE_LABELS, function(label, field)
    if (nzchar(values[[field]])) paste0(label, ": ", values[[field]])
    else NA_character_)
  unname(lines[!is.na(lines)])
}

# The task sentence is fixed text, held in TASKS. The number of items is the
#   form's.
ASK_CLOSING <- paste("Follow every rule you were given.",
                     "Reply in the format given at the end of this message.")

ask_sentence <- function(task, n_items) {
  what = TASKS[[task]]$ask
  if (TASKS[[task]]$kind == "draft")
    what = sprintf(what, paste(n_items, if (n_items == 1L) "survey item" else "survey items"))
  paste(what, ASK_CLOSING)
}

# The brief check's sentence. It names the task the analyst chose, because
#   right_task in pm_brief.md is about the request not matching it, and it asks
#   for the criteria from the CHECKLIST block below, because criteria_preview
#   takes them from "the checklist you were given".
brief_ask_sentence <- function(task)
  paste0("The analyst chose the task '", TASKS[[task]]$label, "'. Check the brief ",
         "above for what a designer would still need to know before that task is ",
         "done, and list the criteria from the CHECKLIST below that will be applied. ",
         "Write no items. ", ASK_CLOSING)

# The appraisal's sentence: how many candidates, and how many items each was
#   asked for, which coverage and the item count both depend on.
appraise_ask_sentence <- function(n_candidates, n_items)
  paste0("Appraise the ", n_candidates, " candidate ",
         if (n_candidates == 1L) "draft" else "drafts",
         " in CANDIDATES below against the CHECKLIST. Each was asked to write exactly ",
         n_items, if (n_items == 1L) " survey item" else " survey items",
         " for the brief above. ", ASK_CLOSING)

# The Output format a step's reply follows. For brief and appraise it is the
#   project manager file's. For work it is the one file in force that carries
#   one: generate.md for the drafting tasks, evaluate.md for Evaluate. Exactly
#   one does.
output_format_of <- function(skills, step = "work") {
  file = STEP_FORMAT_FILE[[step]]
  if (!is.na(file)) {
    if (is.null(skills[[file]]) || is.na(skills[[file]]$output_format))
      stop(file, " is not in force or has no '## Output format'.", call. = FALSE)
    return(skills[[file]]$output_format)
  }
  with_output = purrr::keep(unname(skills), function(s) !is.na(s$output_format))
  if (length(with_output) != 1L)
    stop("Exactly one skill file in force must have an '## Output format'; ",
         length(with_output), " do.", call. = FALSE)
  with_output[[1]]$output_format
}

# Reflex id to its Check question, for the skills in force: the reflexes a
#   prompt kept, in the order it sends them, that have a Check line. One
#   function, so the CHECKLIST block of a review and build_checklist() cannot
#   differ.
checklist_of <- function(skills) {
  rx = purrr::list_flatten(unname(purrr::map(unname(skills), function(s) unname(s$reflexes))))
  rx = purrr::keep(rx, function(r) !is.na(r$check))
  purrr::set_names(purrr::map_chr(rx, function(r) r$check),
                   purrr::map_chr(rx, function(r) r$id))
}

# PREPARE, ASK, CHARACTERIZE, in Buskirk, Eck and Timbrook's order. For Evaluate
#   two blocks sit between ASK and CHARACTERIZE: QUESTIONNAIRE as pasted, then
#   CHECKLIST, one "id: question" line per Check in force. Workers get the
#   rules and the appraiser gets the questions, so a drafting prompt has none.
assemble_user <- function(f, skills) {
  review = TASKS[[f$task]]$kind == "review"
  checklist = if (review) checklist_of(skills)
  if (review && !length(checklist))
    stop("Evaluate needs a checklist, and no Check line is in force.", call. = FALSE)
  blocks = purrr::compact(list(
    paste(c("PREPARE", prepare_lines(f)), collapse = "\n"),
    paste(c("ASK", ask_sentence(f$task, f$n_items),
            if (nzchar(f$revision)) paste0("REVISION: ", f$revision)),
          collapse = "\n"),
    if (review) paste("QUESTIONNAIRE", f$questionnaire, sep = "\n"),
    if (review) checklist_block(checklist),
    paste("CHARACTERIZE", output_format_of(skills), sep = "\n")))
  paste(unlist(blocks), collapse = "\n\n")
}

# "id: question" lines under a CHECKLIST heading. One function for the review,
#   the brief check and the appraisal, so the three cannot word it differently.
checklist_block <- function(checklist)
  paste(c("CHECKLIST", paste0(names(checklist), ": ", unname(checklist))),
        collapse = "\n")

# What the appraiser sees of an item: what it asks and what it decided. The
#   worker's own notes are left out, since they are where a model is most likely
#   to say who it is. An absent field becomes empty, so the appraiser always sees
#   the same shape.
APPRAISAL_ITEM_DEFAULTS <- list(
  id = "", domain = "", intro = "", stem = "", options = list(), open_format = "",
  parts = list(), programming = "", decisions = list(), source_english = "")

appraisal_item <- function(it) {
  out = purrr::imap(APPRAISAL_ITEM_DEFAULTS, function(d, k) it[[k]] %||% d)
  out[names(out) != "source_english" | nzchar(paste(unlist(out$source_english), collapse = ""))]
}

# CANDIDATES: one JSON object per line, the letter, the domains it left out, and
#   its items. candidates is a list of parsed drafts named by their letter. No
#   model id is passed in, so none can be written.
candidates_block <- function(candidates) {
  lines = purrr::imap_chr(candidates, function(reply, letter)
    as.character(jsonlite::toJSON(
      list(candidate = letter, not_covered = reply$not_covered %||% list(),
           items = purrr::map(unname(reply$items), appraisal_item)),
      auto_unbox = TRUE)))
  paste(c("CANDIDATES", unname(lines)), collapse = "\n")
}

# The user message of the brief check and of the appraisal. Both carry PREPARE,
#   an ASK, a CHECKLIST (the questions the task's own files give, which is what
#   the criteria are taken from and what the appraisal codes against) and
#   CHARACTERIZE; the appraisal also carries CANDIDATES before the CHECKLIST.
assemble_user_step <- function(f, skills, step, checklist, candidates = NULL) {
  ask = switch(step,
    brief = brief_ask_sentence(f$task),
    appraise = appraise_ask_sentence(length(candidates), f$n_items))
  paste(unlist(purrr::compact(list(
    paste(c("PREPARE", prepare_lines(f)), collapse = "\n"),
    paste("ASK", ask, sep = "\n"),
    if (step == "appraise") candidates_block(candidates),
    checklist_block(checklist),
    paste("CHARACTERIZE", output_format_of(skills, step), sep = "\n")))),
    collapse = "\n\n")
}

# sha256 of the system prompt and the user message. The same form and the same
#   files give the same hash, and a change to any word of either changes it.
prompt_hash <- function(system_txt, user_txt)
  digest::digest(enc2utf8(paste0(system_txt, "\n\n", user_txt)), algo = "sha256",
                 serialize = FALSE)


# ---- the contract tests/review.R relies on (DESIGN.md section 5) ------------------

# One assembler for every step (DESIGN.md section 12). step "work": for a drafting
#   task, the worker's prompt; for a review task, the project manager's review.
#   step "brief": the project manager's check of the form. step "appraise": the
#   project manager comparing candidates, which is a list of the workers' parsed
#   drafts named by letter (A, B, C), already relabelled by the caller so that
#   nothing here knows which model wrote which. Returns system and user (one
#   string each), hash, and files: the skill files used, in order.
build_step_prompt <- function(form, step, candidates = NULL) {
  f = clean_form(form)
  if (!step %in% STEPS)
    stop("step must be one of: ", paste(STEPS, collapse = ", "), call. = FALSE)
  if (step == "appraise" && TASKS[[f$task]]$kind != "draft")
    stop("Only a drafting task has candidates to appraise.", call. = FALSE)
  if (step == "appraise" && (!length(candidates) || is.null(names(candidates))))
    stop("The appraisal needs at least one candidate, named by its letter.", call. = FALSE)
  skills = skills_in_force(f, step = step)
  system_txt = assemble_system(skills)
  user_txt = if (step == "work") assemble_user(f, skills)
    else assemble_user_step(f, skills, step, checklist_of(skills_in_force(f)), candidates)
  list(system = system_txt, user = user_txt,
       hash = prompt_hash(system_txt, user_txt), files = names(skills))
}

# The work step, as it was before there were steps. The hashes in REVIEW.md
#   section 6 are this function's, and must not change.
build_prompt <- function(form) build_step_prompt(form, "work")

# Reflex id to its Check question, for the files build_prompt(form) used and
#   only the reflexes it kept. Reflexes with no Check line are not in it.
build_checklist <- function(form) checklist_of(skills_in_force(clean_form(form)))
