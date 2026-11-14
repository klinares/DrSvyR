# reflexes.R for QuestionR
# Reads the reflex files in www/reflexes/, keeps the reflexes a form calls for, and assembles every
#   prompt. R does this and no model does, so the same form gives the same prompt, character for
#   character. The parser is svysegment's, stricter: a line that is not part of the format (see
#   www/reflexes/README.md) stops the app, naming the file and the reflex, since a dropped line is a
#   rule a model is never told. Source and Label lines and HTML comments are never sent.
#   Function definitions and constants only.


# ---- what is in www/reflexes/ ------------------------------------------------------

REFLEXES_DIR <- file.path("www", "reflexes")

# The reflex files, by name, so a missing one is an error and the README is not read as one.
REFLEX_FILES <- c("core.md", "generate.md", "attitudinal.md", "behavioral.md", "sensitive.md",
                  "evaluate.md", "mode.md", "refine.md")

# The files whose reply R parses, so each must give a reply format.
REFLEX_FILES_WITH_OUTPUT <- c("generate.md", "evaluate.md", "refine.md")

# The kinds of question a reflex can apply to (its Applies line). A reflex with no Applies line
#   applies to the kind its file is about, and a reflex of any other file to any question.
KINDS <- c("attitudinal", "behavioral", "sensitive")
KIND_FILES <- c(attitudinal = "attitudinal.md", behavioral = "behavioral.md", sensitive = "sensitive.md")

# The tasks. Each entry: label (what the page calls it); kind ("draft" or "review"); ask (the task
#   sentence; a draft's holds %s, where the number of items goes); fields (what its form shows).
TASKS <- list(
  attitudinal = list(
    label = "Attitudinal", kind = "draft",
    ask = "Write exactly %s for the brief, to be combined into one attitude scale.",
    fields = c("research_question", "construct", "population", "country", "modes", "n_items")),
  behavioral = list(
    label = "Behavioral", kind = "draft",
    ask = "Write exactly %s for the brief, each measuring a behaviour or an experience.",
    fields = c("research_question", "construct", "population", "country", "modes", "n_items", "reference_period")),
  sensitive = list(
    label = "Sensitive", kind = "draft",
    ask = "Write exactly %s for the brief, each on a topic where respondents may refuse or edit their answer.",
    fields = c("research_question", "construct", "population", "country", "modes", "n_items")),
  evaluate = list(
    label = "Evaluate questions", kind = "review",
    ask = "Review the questionnaire as an expert reviewer, question by question.",
    fields = c("research_question", "population", "country", "modes", "kinds", "questionnaire")))

# The most items one drafting run is asked for.
MAX_ITEMS_PER_RUN <- 10L

# The calls: draft (Write questions, call 1, the drafter); refine (call 2, the main model edits the
#   draft into the final questions); items and instrument (a review's part, and the whole).
STEPS <- c("draft", "refine", "items", "instrument")

# The refine call's task sentence; %s is the number of items.
REFINE_ASK <- "Edit the draft below into the final %s for the brief, repairing every failure against the CHECKLIST."

# The reflex files a step reads, in order: core.md first, mode.md last.
step_files <- function(f, step) {
  if (!step %in% STEPS) stop("step must be one of: ", paste(STEPS, collapse = ", "), call. = FALSE)
  switch(step,
         draft = c("core.md", "generate.md", KIND_FILES[[f$task]], "mode.md"),
         refine = c("core.md", "refine.md", KIND_FILES[[f$task]], "mode.md"),
         c("core.md", "evaluate.md", unname(KIND_FILES[f$kinds]), "mode.md"))
}


# ---- the parser ----------------------------------------------------------------------

# purrr wraps an error raised inside map(); the innermost one names the file and the reflex.
reflex_root_message <- function(e)
  if (is.null(e$parent)) conditionMessage(e) else reflex_root_message(e$parent)

REFLEX_FIELDS <- c("When", "Say", "Never", "Check", "Label", "Applies", "Source")

# One reflex: its "### id" line and the field lines under it. instrument marks a reflex of the
#   "## Instrument checks" group.
parse_reflex <- function(block, file, instrument = FALSE) {
  id = trimws(sub("^### ", "", block[1]))
  where = paste0("Reflex '", id, "' in ", file)
  if (!grepl("^[a-z][a-z0-9_]*$", id))
    stop(where, " needs an id in lower case, with underscores.", call. = FALSE)
  body = block[-1]
  body = body[nzchar(trimws(body))]
  m = stringr::str_match(body, paste0("^- \\*\\*(", paste(REFLEX_FIELDS, collapse = "|"), "):\\*\\*[ \\t]*(.*)$"))
  if (anyNA(m[, 1]))
    stop(where, " has a line that is not a field: ", body[is.na(m[, 1])][1], call. = FALSE)
  if (anyDuplicated(m[, 2]))
    stop(where, " has the field ", m[anyDuplicated(m[, 2]), 2], " twice.", call. = FALSE)
  f = purrr::set_names(as.list(trimws(m[, 3])), m[, 2])
  if (!all(nzchar(unlist(f)))) stop(where, " has a field with nothing in it.", call. = FALSE)
  if (is.null(f[["When"]]) || is.null(f[["Say"]])) stop(where, " needs a When and a Say line.", call. = FALSE)
  if (!is.null(f[["Label"]]) && length(strsplit(f[["Label"]], "\\s+")[[1]]) > 6L)
    stop(where, " has a Label of more than 6 words.", call. = FALSE)
  applies = if (is.null(f[["Applies"]])) NA_character_ else trimws(strsplit(f[["Applies"]], ",")[[1]])
  if (!all(is.na(applies)) && !all(applies %in% c(KINDS, "any")))
    stop(where, " has an Applies line that is not a comma list of ", paste(c(KINDS, "any"), collapse = ", "), ".", call. = FALSE)
  list(id = id, when = f[["When"]], say = f[["Say"]], never = f[["Never"]] %||% NA_character_,
       check = f[["Check"]] %||% NA_character_, label = f[["Label"]] %||% NA_character_,
       applies = applies, source = f[["Source"]] %||% NA_character_, instrument = instrument)
}

# The reflexes under one "## " heading.
parse_reflex_group <- function(lines, file, heading, instrument) {
  head = cumsum(grepl("^### ", lines))
  if (any(head == 0L & nzchar(trimws(lines))))
    stop(file, " has text under '## ", heading, "' before the first '### id'.", call. = FALSE)
  blocks = purrr::keep(split(lines, head), function(b) grepl("^### ", b[1]))
  purrr::map(unname(blocks), function(b) parse_reflex(b, file, instrument))
}

# One reflex file, parsed: title, version, sha (line endings normalised), persona (core.md only),
#   guidelines (heading and bullets, or NULL), reflexes by id, prohibitions, and the output format.
parse_reflex_file <- function(path) {
  file = basename(path)
  if (!file.exists(path)) stop("The reflex file is missing: ", path, call. = FALSE)
  bytes = readBin(path, "raw", file.size(path))
  sha = digest::digest(bytes[bytes != as.raw(13)], algo = "sha256", serialize = FALSE)
  txt = paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  txt = gsub("(?s)<!--.*?-->", "", txt, perl = TRUE)
  if (grepl("<!--", txt, fixed = TRUE)) stop(file, " has an HTML comment that is never closed.", call. = FALSE)
  lines = strsplit(txt, "\n", fixed = TRUE)[[1]]

  ver = grep("^Version:", lines, value = TRUE)
  if (!length(ver)) stop(file, " has no Version: line.", call. = FALSE)
  title = sub("^# ", "", grep("^# ", lines, value = TRUE)[1])
  if (is.na(title)) stop(file, " has no '# title' line.", call. = FALSE)

  is_head = grepl("^## ", lines)
  parts = split(lines, cumsum(is_head))
  heads = unname(purrr::map_chr(parts, function(s) if (grepl("^## ", s[1])) trimws(sub("^## ", "", s[1])) else ""))
  parts = purrr::set_names(purrr::map(parts, function(s) if (grepl("^## ", s[1])) s[-1] else s), heads)
  named = heads[nzchar(heads)]
  odd = setdiff(named, c("Persona", "Guidelines", "Reflexes", "Instrument checks", "Prohibitions", "Output format"))
  if (length(odd)) stop(file, " has a section that is not part of the format: '## ", odd[1], "'.", call. = FALSE)
  if (anyDuplicated(named)) stop(file, " has the section '## ", named[anyDuplicated(named)], "' twice.", call. = FALSE)
  if (is.null(parts[["Reflexes"]])) stop(file, " has no '## Reflexes' section.", call. = FALSE)

  reflexes = tryCatch(
    c(parse_reflex_group(parts[["Reflexes"]], file, "Reflexes", FALSE),
      if (!is.null(parts[["Instrument checks"]])) parse_reflex_group(parts[["Instrument checks"]], file, "Instrument checks", TRUE)),
    error = function(e) stop(reflex_root_message(e), call. = FALSE))
  ids = purrr::map_chr(reflexes, "id")
  if (anyDuplicated(ids)) stop(file, " has two reflexes called '", ids[anyDuplicated(ids)], "'.", call. = FALSE)

  persona = NA_character_
  if (!is.null(parts[["Persona"]])) {
    persona = gsub("\\s+", " ", trimws(paste(parts[["Persona"]], collapse = "\n")))
    if (!nzchar(persona)) stop(file, " has an empty '## Persona'.", call. = FALSE)
  }

  # Guidelines: one optional heading line, then one-line bullets. They go into the message the
  #   analyst can edit, never into the system prompt (the Reflexes are the rules).
  guidelines = NULL
  if (!is.null(parts[["Guidelines"]])) {
    g = trimws(parts[["Guidelines"]])
    g = g[nzchar(g)]
    heading = if (length(g) && !grepl("^- ", g[1])) g[1]
    rest = if (is.null(heading)) g else g[-1]
    if (!length(rest) || !all(grepl("^- ", rest)))
      stop(file, " has a '## Guidelines' section that is not an optional heading line and then one-line bullets.", call. = FALSE)
    guidelines = list(heading = heading %||% NA_character_, bullets = trimws(sub("^- ", "", rest)))
  }

  pr = parts[["Prohibitions"]]
  pr = if (is.null(pr)) character(0) else pr[nzchar(trimws(pr))]
  if (!all(grepl("^- ", pr)))
    stop(file, " has a line under '## Prohibitions' that is not a one-line bullet: ", pr[!grepl("^- ", pr)][1], call. = FALSE)

  of = NA_character_
  if (!is.null(parts[["Output format"]])) {
    of = trimws(paste(parts[["Output format"]], collapse = "\n"))
    if (!nzchar(of)) stop(file, " has an empty '## Output format'.", call. = FALSE)
  }

  list(file = file, title = trimws(title), version = trimws(sub("^Version:", "", ver[1])), sha = sha,
       persona = persona, guidelines = guidelines, reflexes = purrr::set_names(reflexes, ids),
       prohibitions = trimws(sub("^- ", "", pr)), output_format = of)
}

read_reflex_file <- function(name, dir = REFLEXES_DIR) parse_reflex_file(file.path(dir, name))

# Every reflex file, parsed when the app starts, so one that has lost its shape stops it there.
check_reflex_files <- function(dir = REFLEXES_DIR) {
  rfiles = tryCatch(purrr::map(purrr::set_names(REFLEX_FILES), function(f) read_reflex_file(f, dir)),
                    error = function(e) stop(reflex_root_message(e), call. = FALSE))
  if (is.na(rfiles[["core.md"]]$persona)) stop("core.md has no '## Persona' section.", call. = FALSE)
  if (is.null(rfiles[["core.md"]]$guidelines)) stop("core.md has no '## Guidelines' section.", call. = FALSE)
  no_output = purrr::keep(REFLEX_FILES_WITH_OUTPUT, function(f) is.na(rfiles[[f]]$output_format))
  if (length(no_output)) stop(no_output[1], " has no '## Output format' section.", call. = FALSE)
  ids = unlist(purrr::map(unname(rfiles), function(s) names(s$reflexes)))
  if (anyDuplicated(ids)) stop("Two reflex files share the reflex id '", ids[anyDuplicated(ids)], "'.", call. = FALSE)
  invisible(rfiles)
}

# Reflex id to its Label, for every reflex that has one. What the analyst reads; never sent.
check_labels <- function(dir = REFLEXES_DIR) {
  rx = unlist(purrr::map(REFLEX_FILES, function(f) unname(read_reflex_file(f, dir)$reflexes)), recursive = FALSE)
  rx = purrr::keep(rx, function(r) !is.na(r$label))
  purrr::set_names(purrr::map_chr(rx, "label"), purrr::map_chr(rx, "id"))
}


# ---- the form ------------------------------------------------------------------------

FORM_FIELDS <- c("task", "research_question", "construct", "population", "country", "modes",
                 "n_items", "reference_period", "kinds", "questionnaire")

# The survey modes: ids are reflex ids in mode.md, in the order a prompt uses.
MODE_LABELS <- c(web = "web", mobile_web = "mobile web", telephone = "telephone",
                 face_to_face = "face-to-face", paper = "paper")

# The labels of the brief's lines, in the order they appear.
BRIEF_LABELS <- c(research_question = "Research question", construct = "Construct",
                  population = "Target population", country = "Country", modes = "Survey mode",
                  reference_period = "Reference period")

form_blank <- function(x) {
  if (is.null(x) || !length(x)) return(TRUE)
  x = x[!is.na(x)]
  !length(x) || !any(nzchar(trimws(as.character(x))))
}

# One trimmed string with plain newlines, so Windows and a browser give the same prompt.
form_text <- function(x) {
  if (form_blank(x)) return("")
  gsub("\r\n?", "\n", trimws(paste(x[!is.na(x)], collapse = ", ")))
}

# A set of ids chosen from a fixed list, in the list's order.
form_choice <- function(x, allowed, what) {
  x = unique(trimws(as.character(x %||% character(0))))
  x = x[!is.na(x) & nzchar(x)]
  bad = setdiff(x, allowed)
  if (length(bad)) stop("Unknown ", what, ": ", paste(bad, collapse = ", "), ". They are: ", paste(allowed, collapse = ", "), call. = FALSE)
  intersect(allowed, x)
}

# The form as the prompts use it, cleaned. Nothing is guessed; a form that cannot make a prompt
#   stops, saying why.
clean_form <- function(form) {
  if (!is.list(form) || (length(form) && is.null(names(form)))) stop("The form must be a named list.", call. = FALSE)
  odd = setdiff(names(form), FORM_FIELDS)
  if (length(odd)) stop("The form has a field that is not in the contract: ", paste(odd, collapse = ", "), call. = FALSE)
  task = form_text(form[["task"]])
  if (!task %in% names(TASKS)) stop("task must be one of: ", paste(names(TASKS), collapse = ", "), call. = FALSE)
  kind = TASKS[[task]]$kind
  text_fields = c("research_question", "construct", "population", "country", "reference_period", "questionnaire")
  f = purrr::map(purrr::set_names(text_fields), function(x) form_text(form[[x]]))
  if (!nzchar(f$research_question)) stop("The research question is required.", call. = FALSE)
  if (kind == "review" && !nzchar(f$questionnaire)) stop("Evaluate needs the questionnaire pasted in.", call. = FALSE)
  if (kind == "review" && nchar(f$questionnaire) > APP_MAX_PASTE_CHARS)
    stop("The pasted questionnaire is ", format(nchar(f$questionnaire), big.mark = ","), " characters and the limit is ",
         format(APP_MAX_PASTE_CHARS, big.mark = ","), ". Paste it in parts, one review each.", call. = FALSE)
  n_items = NA_integer_
  if (kind == "draft") {
    n = form[["n_items"]]
    v = if (form_blank(n)) NA_real_ else suppressWarnings(as.numeric(n[[1]]))
    if (is.na(v) || v < 1 || v > MAX_ITEMS_PER_RUN || v != round(v))
      stop("Drafting needs a number of items from 1 to ", MAX_ITEMS_PER_RUN, ".", call. = FALSE)
    n_items = as.integer(v)
  }
  # The kinds of question a review looks for: what the analyst ticked, all three when none is.
  kinds = if (kind == "review") form_choice(form[["kinds"]], KINDS, "kind of question") else task
  if (kind == "review" && !length(kinds)) kinds = KINDS
  c(list(task = task), f, list(modes = form_choice(form[["modes"]], names(MODE_LABELS), "survey mode"),
                               n_items = n_items, kinds = kinds))
}


# ---- which reflexes a form calls for ---------------------------------------------------

# The kinds a reflex applies to: its Applies line, else its file's kind, else any.
reflex_applies <- function(r, file) {
  if (!all(is.na(r$applies))) return(r$applies)
  k = names(KIND_FILES)[KIND_FILES == file]
  if (length(k)) k else "any"
}

# The parsed reflex files a step is built from, in order. mode.md keeps any_mode, the modes chosen
#   and mixed_mode with more than one; a reflex whose Applies misses the form's kinds is left out;
#   in a review the kind files bring only their checks, not their drafting rules.
reflexes_in_force <- function(f, step, dir = REFLEXES_DIR) {
  review = step %in% c("items", "instrument")
  rfiles = purrr::map(purrr::set_names(step_files(f, step)), function(name) {
    s = read_reflex_file(name, dir)
    keep = purrr::map_lgl(s$reflexes, function(r)
      any(reflex_applies(r, name) %in% c("any", f$kinds)) && !(review && name %in% KIND_FILES && is.na(r$check)))
    if (name == "mode.md") {
      wanted = c("any_mode", f$modes, if (length(f$modes) > 1L) "mixed_mode")
      absent = setdiff(wanted, names(s$reflexes))
      if (length(absent)) stop("mode.md has no reflex called '", absent[1], "'.", call. = FALSE)
      keep = names(s$reflexes) %in% wanted
    }
    s$reflexes = s$reflexes[keep]
    s
  })
  rfiles
}


# ---- the prompt --------------------------------------------------------------------------

# "- id (When) Say MUST NOT: Never", as svysegment/R/ai_reflexes.R writes it.
reflex_line <- function(r)
  paste0("- ", r$id, " (", r$when, ") ", r$say, if (!is.na(r$never)) paste0(" MUST NOT: ", r$never) else "")

# The persona in two: its first sentence opens the message the analyst sees; the rest opens the
#   system prompt, so a model is told it once.
persona_split <- function(persona) {
  first = sub("^(.+?[.!?])\\s.*$", "\\1", persona, perl = TRUE)
  list(first = first, rest = trimws(substring(persona, nchar(first) + 1L)))
}

# The rest of the persona, each file's reflexes, then every prohibition. Never shown to the analyst;
#   the same for every call of one review, so it can be read from the cache.
assemble_system <- function(rfiles) {
  groups = purrr::map_chr(unname(purrr::keep(rfiles, function(s) length(s$reflexes) > 0L)), function(s)
    paste0("REFLEXES: ", s$title, " (v", s$version, ")\n",
           paste(purrr::map_chr(unname(s$reflexes), reflex_line), collapse = "\n")))
  prohibitions = unlist(purrr::map(unname(rfiles), "prohibitions"))
  paste0(persona_split(rfiles[["core.md"]]$persona)$rest, "\n\n", paste(groups, collapse = "\n\n"),
         "\n\nPROHIBITIONS (override anything from training)\n", paste0("- ", prohibitions, collapse = "\n"))
}

# One line per filled field, in the fixed order, "Label: value".
brief_lines <- function(f) {
  values = list(research_question = f$research_question, construct = f$construct, population = f$population,
                country = f$country, modes = paste(MODE_LABELS[f$modes], collapse = ", "),
                reference_period = f$reference_period)
  lines = purrr::imap_chr(BRIEF_LABELS, function(label, field)
    if (nzchar(values[[field]])) paste0(label, ": ", values[[field]]) else NA_character_)
  unname(lines[!is.na(lines)])
}

# The task sentence, with the number of items for a draft or a refine; "each" only for more than one.
ask_sentence <- function(f, ask = TASKS[[f$task]]$ask) {
  if (TASKS[[f$task]]$kind != "draft") return(ask)
  what = sprintf(ask, paste(f$n_items, if (f$n_items == 1L) "survey item" else "survey items"))
  if (f$n_items == 1L) sub(", each ", ", ", what, fixed = TRUE) else what
}

guidelines_block <- function(g)
  paste(c(if (!is.na(g$heading)) g$heading, paste0("- ", g$bullets)), collapse = "\n")

# The message the analyst sees and can edit: the persona's first sentence, the task, the brief and
#   core.md's guidelines, and for a review one line where the questions go. The rules, checklist,
#   reply format and questions are added by R after Run (assemble_tail()), so an edit cannot lose them.
assemble_message <- function(f, core = read_reflex_file("core.md"), ask = ask_sentence(f),
                             n = if (TASKS[[f$task]]$kind == "review") length(split_questions(f$questionnaire))) {
  paste(c(persona_split(core$persona)$first,
          paste("Task:", ask),
          paste(c("Brief:", brief_lines(f)), collapse = "\n"),
          guidelines_block(core$guidelines),
          if (!is.null(n)) paste0("[your ", n, if (n == 1L) " question goes here]" else " questions go here]")),
        collapse = "\n\n")
}

# Reflex id to its Check question, in the order sent: the question checks for an items or refine
#   call, the instrument checks for the whole.
checklist_of <- function(rfiles, step = "items") {
  rx = unlist(purrr::map(unname(rfiles), function(s) unname(s$reflexes)), recursive = FALSE)
  rx = purrr::keep(rx, function(r) !is.na(r$check) && r$instrument == (step == "instrument"))
  purrr::set_names(purrr::map_chr(rx, "check"), purrr::map_chr(rx, "id"))
}

checklist_block <- function(checklist)
  paste(c("CHECKLIST", paste0(names(checklist), ": ", unname(checklist))), collapse = "\n")

# The Output format of the one file in force that has one.
output_format_of <- function(rfiles) {
  with_output = purrr::keep(unname(rfiles), function(s) !is.na(s$output_format))
  if (length(with_output) != 1L)
    stop("Exactly one reflex file in force must have an '## Output format'; ", length(with_output), " do.", call. = FALSE)
  with_output[[1]]$output_format
}

ASK_CLOSING <- "Follow every rule you were given. Reply in the format given at the end of this message."

# What one call of a review is told about its part: part is an entry of review_plan().
part_sentence <- function(part) {
  if (identical(part$kind, "instrument"))
    return(paste("Now review the questionnaire below as a whole: only what the CHECKLIST asks about order, routing",
                 "and consistency. Reply with the \"instrument\" object only."))
  paste0("Now review the ", length(part$questions), if (length(part$questions) == 1L) " question" else " questions",
              " below, each on its own", if (part$n > 1L) paste0(" (part ", part$k, " of ", part$n, " of the questionnaire)"),
              ". Reply with the \"items\" object only, one entry per question, in the order given.")
}

# What R puts after the message: for a draft, the kind file's guidelines and the reply format; for a
#   refine, the draft as JSON, the CHECKLIST of the drafting files (core, generate, the kind's file,
#   the modes) and the format; for a call of a review, what it is to do, the questions, the
#   CHECKLIST and the format.
assemble_tail <- function(f, rfiles, step, part = NULL, draft = NULL) {
  if (step == "draft") {
    g = rfiles[[KIND_FILES[[f$task]]]]$guidelines
    return(paste(c(if (!is.null(g)) guidelines_block(g), ASK_CLOSING,
                   paste("REPLY FORMAT", output_format_of(rfiles), sep = "\n")), collapse = "\n\n"))
  }
  if (step == "refine")
    return(paste(c(paste("DRAFT", jsonlite::toJSON(list(items = draft$items), auto_unbox = TRUE, pretty = TRUE), sep = "\n"),
                   checklist_block(checklist_of(reflexes_in_force(f, "draft"))), ASK_CLOSING,
                   paste("REPLY FORMAT", output_format_of(rfiles), sep = "\n")), collapse = "\n\n"))
  checklist = checklist_of(rfiles, step)
  if (!length(checklist)) stop("A ", step, " call would carry no checks.", call. = FALSE)
  paste(c(part_sentence(part), paste("QUESTIONNAIRE", part$text, sep = "\n"), checklist_block(checklist),
          ASK_CLOSING, paste("REPLY FORMAT", output_format_of(rfiles), sep = "\n")), collapse = "\n\n")
}

sent_user <- function(message, tail) paste0(message, "\n\n", tail)

# sha256 of the system prompt and the user message. A change to any word of either changes it.
prompt_hash <- function(system_txt, user_txt)
  digest::digest(enc2utf8(paste0(system_txt, "\n\n", user_txt)), algo = "sha256", serialize = FALSE)

# One assembler for every call. message is the analyst's text (a draft or a review); part an entry of
#   review_plan(); draft the parsed draft a refine edits. A refine's message is assembled, never the
#   analyst's: it asks for an edit, not a draft. Returns system, user, message (as assembled), tail,
#   hash, files, and checks (the CHECKLIST ids sent).
build_step_prompt <- function(form, step, part = NULL, message = NULL, draft = NULL) {
  f = clean_form(form)
  if (!step %in% STEPS) stop("step must be one of: ", paste(STEPS, collapse = ", "), call. = FALSE)
  if ((step %in% c("draft", "refine")) != (TASKS[[f$task]]$kind == "draft"))
    stop("The ", step, " step is not for the task ", f$task, ".", call. = FALSE)
  if (step %in% c("items", "instrument") && is.null(part)) stop("A ", step, " call needs a part.", call. = FALSE)
  if (step == "refine" && is.null(draft)) stop("A refine call needs the draft.", call. = FALSE)
  rfiles = reflexes_in_force(f, step)
  system_txt = assemble_system(rfiles)
  assembled = if (step == "refine") assemble_message(f, rfiles[["core.md"]], ask_sentence(f, REFINE_ASK))
              else assemble_message(f, rfiles[["core.md"]])
  tail_txt = assemble_tail(f, rfiles, step, part, draft)
  user_txt = sent_user(if (step == "refine") assembled else message %||% assembled, tail_txt)
  checks = switch(step, draft = character(0), refine = names(checklist_of(reflexes_in_force(f, "draft"))),
                  names(checklist_of(rfiles, step)))
  list(system = system_txt, user = user_txt, message = assembled, tail = tail_txt,
       hash = prompt_hash(system_txt, user_txt), files = names(rfiles), checks = checks)
}

# A draft's prompt.
build_prompt <- function(form) build_step_prompt(form, "draft")


# ---- the reflex table on the Methodology page -------------------------------------------

# One row per reflex: the file's title, its Label (its id in words when it has none), and its Source
#   line ("" when there is none), read from the files as the prompts are, so it cannot drift from them.
reflexes_table <- function(dir = REFLEXES_DIR) {
  rows = unlist(purrr::map(REFLEX_FILES, function(f) {
    s = read_reflex_file(f, dir)
    purrr::map(unname(s$reflexes), function(r)
      list(file = s$title, label = if (is.na(r$label)) gsub("_", " ", r$id) else r$label,
           source = if (is.na(r$source)) "" else r$source))
  }), recursive = FALSE)
  data.frame(file = purrr::map_chr(rows, "file"), label = purrr::map_chr(rows, "label"),
             source = purrr::map_chr(rows, "source"), stringsAsFactors = FALSE)
}
