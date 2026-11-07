# skills.R -- the shared skills in skills_dir (ai_skills/ by default).
#
# Each skill is a folder with SKILL.md: YAML frontmatter (name, description,
#   when_to_use) and a markdown body, plus optional scripts/ (R the intern can
#   run) and references/ (longer notes it can read). The same folders are read
#   by Claude Code and other agents, so nothing here is inteRn-specific.
#
# Only the index -- each skill's name, description and when_to_use -- goes in
#   the system prompt. The body is loaded when the model asks for it
#   (load_skill), which keeps every turn short.
# Function definitions and constants only.

SKILL_NAME <- "^[a-z0-9][a-z0-9-]*$"
SKILL_FILE_EXT <- c("md", "R", "r", "qmd", "yaml", "yml")

# Frontmatter as a named list of strings. One "key: value" per line, which is
#   all the skills use; quotes around a value are dropped. Read without the
#   yaml package so inteRn does not need it.
read_frontmatter <- function(lines) {
  if (!length(lines) || !identical(trimws(lines[1]), "---")) return(list())
  end = which(trimws(lines) == "---")
  end = end[end > 1][1]
  if (is.na(end)) return(list())
  kv = lines[seq.int(2, length.out = end - 2)]
  kv = kv[grepl("^[A-Za-z_]+:", kv)]
  keys = sub(":.*$", "", kv)
  vals = trimws(sub("^[A-Za-z_]+:", "", kv))
  vals = sub("^([\"'])(.*)\\1$", "\\2", vals)
  rlang::set_names(as.list(vals), keys)
}

skill_body <- function(lines) {
  end = which(trimws(lines) == "---")
  body = if (length(lines) && identical(trimws(lines[1]), "---") && length(end) >= 2)
    lines[-seq_len(end[2])] else lines
  txt = gsub("(?s)<!--.*?-->", "", paste(body, collapse = "\n"), perl = TRUE)
  trimws(gsub("\n{3,}", "\n\n", txt))
}

# One row per skill folder that has a SKILL.md. Folders whose frontmatter has
#   no name or description are skipped with a message, rather than half-listed.
list_skills <- function(dir = intern_skills_dir()) {
  files = Sys.glob(file.path(dir, "*", "SKILL.md"))
  rows = purrr::map(files, function(f) {
    fm = read_frontmatter(readLines(f, encoding = "UTF-8", warn = FALSE))
    if (!is_string(fm$name) || !is_string(fm$description)) {
      message("inteRn: skipping ", basename(dirname(f)), "/SKILL.md (needs name and description).")
      return(NULL)
    }
    list(name = fm$name, folder = basename(dirname(f)), description = fm$description,
         when_to_use = fm$when_to_use %||% "")
  })
  purrr::compact(rows)
}

# The part of the system prompt that lists the skills.
skills_index <- function(skills = list_skills()) {
  if (!length(skills)) return("")
  lines = purrr::map_chr(skills, function(s)
    paste0("- ", s$name, ": ", s$description,
           if (nzchar(s$when_to_use)) paste0(" Use when: ", s$when_to_use) else ""))
  paste0("## Skills\n\nShared skills hold the detailed rules for kinds of work. ",
         "Before doing work that matches one, call load_skill with its name and follow it. ",
         "Load a skill once per conversation.\n\n", paste(lines, collapse = "\n"))
}

skill_folder <- function(name) {
  if (!is_string(name) || !grepl(SKILL_NAME, name)) return(NULL)
  hit = purrr::detect(list_skills(), function(s) identical(s$name, name) || identical(s$folder, name))
  if (is.null(hit)) NULL else file.path(intern_skills_dir(), hit$folder)
}

# load_skill(name): the SKILL.md body and the files the skill offers.
#   load_skill(name, file): one file inside that skill folder, e.g.
#   "references/examples.md". Paths are checked to stay inside the folder.
load_skill_tool <- function(name, file = NULL) {
  dir = skill_folder(name)
  if (is.null(dir))
    return(paste0("There is no skill called '", name, "'. Skills: ",
                  paste(purrr::map_chr(list_skills(), "name"), collapse = ", "), "."))
  if (is.null(file) || !nzchar(file)) {
    extras = list.files(dir, recursive = TRUE)
    extras = extras[extras != "SKILL.md"]
    body = skill_body(readLines(file.path(dir, "SKILL.md"), encoding = "UTF-8", warn = FALSE))
    return(paste0(
      "# Skill: ", name, "\n\n", body,
      if (length(extras)) paste0(
        "\n\n---\nFiles in this skill (read with load_skill(name, file)): ",
        paste(extras, collapse = ", "),
        if (any(startsWith(extras, "scripts/")))
          paste0(". To use a script in the session, run_code with ",
                 "intern_source_skill(\"", name, "\", \"<script file name>\").")
        else ".")
      else ""))
  }
  root = normalizePath(dir, winslash = "/")
  f = normalizePath(file.path(dir, file), winslash = "/", mustWork = FALSE)
  if (!startsWith(f, paste0(root, "/")) || !file.exists(f) ||
      !tools::file_ext(f) %in% SKILL_FILE_EXT)
    return(paste0("The skill '", name, "' has no readable file '", file, "'."))
  paste(readLines(f, encoding = "UTF-8", warn = FALSE), collapse = "\n")
}

# Exported. Source one of a skill's scripts into the global environment, so
#   its functions are available in the session. Used by the intern through
#   run_code, and by people directly:
#   intern_source_skill("dataviz", "theme_intern.R")
intern_source_skill <- function(name, script) {
  dir = skill_folder(name)
  if (is.null(dir)) stop("There is no skill called '", name, "'.", call. = FALSE)
  f = file.path(dir, "scripts", basename(script))
  if (!file.exists(f))
    stop("Skill '", name, "' has no script '", basename(script), "'. It has: ",
         paste(list.files(file.path(dir, "scripts")), collapse = ", "), call. = FALSE)
  # Scripts that need sibling files (the codebook template, the dataviz
  #   theme) find the skills folder here.
  options(ai_skills.dir = intern_skills_dir())
  sys.source(f, envir = globalenv(), keep.source = TRUE)
  invisible(f)
}
