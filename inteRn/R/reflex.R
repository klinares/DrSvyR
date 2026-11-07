# reflex.R -- reflexes.md, the running log of lessons learned.
#
# One dated line per lesson, appended at the end and never rewritten, so the
#   file reads well in a git diff and merges cleanly when two people add
#   lines. It lives in the skills folder, so Claude Code and other agents read
#   the same lessons. The most recent entries go into inteRn's system prompt.
#
#   /reflex add <text>    in ask() or the Viewer: append a lesson
#   /reflex list          the latest entries
#   reflex_add("<text>")  the same from code
# Function definitions and constants only.

REFLEX_PATTERN <- "^- [0-9]{4}-[0-9]{2}-[0-9]{2}: "
MAX_REFLEXES_IN_PROMPT <- 40L

REFLEX_HEADER <- c(
  "# Reflexes",
  "",
  "Lessons learned while doing survey and data-science work with AI assistants:",
  "things that went wrong once and should not again, and conventions the team",
  "settled on. inteRn puts the most recent entries in its instructions; other",
  "agents read this file directly.",
  "",
  "<!--",
  "One lesson per line: \"- YYYY-MM-DD: text\". Append at the end; do not edit or",
  "reorder old lines (correct one by adding a newer line). Write each as a rule",
  "someone else can follow, without names, paths, keys or data values.",
  "Add from inteRn with: /reflex add <text>",
  "-->",
  "",
  "## Entries",
  "")

reflex_file <- function() file.path(intern_skills_dir(), "reflexes.md")

reflex_entries <- function(f = reflex_file()) {
  if (!file.exists(f)) return(character(0))
  l = readLines(f, encoding = "UTF-8", warn = FALSE)
  l[grepl(REFLEX_PATTERN, l)]
}

# Exported. Append one lesson, dated today. Credentials, paths and e-mail
#   addresses are scrubbed first: the file is shared through git and sent to
#   the model.
reflex_add <- function(text) {
  text = scrub_text(gsub("\\s+", " ", trimws(paste(text, collapse = " "))))
  if (!nzchar(text)) stop("Nothing to add: reflex_add(\"the lesson\").", call. = FALSE)
  f = reflex_file()
  if (!dir.exists(dirname(f)))
    stop("The skills folder does not exist: set skills_dir in config.R.", call. = FALSE)
  if (!file.exists(f)) writeLines(REFLEX_HEADER, f, useBytes = TRUE)
  # Make sure the new line starts on a line of its own.
  raw = readBin(f, "raw", file.info(f)$size)
  ends_nl = length(raw) && raw[length(raw)] == as.raw(10)
  line = paste0("- ", format(Sys.Date()), ": ", text)
  con = file(f, open = "a", encoding = "UTF-8")
  on.exit(close(con), add = TRUE)
  writeLines(c(if (!ends_nl) "", line), con)
  # The current conversation picks it up too, not only the next one.
  if (!is.null(.state$chat))
    tryCatch(.state$chat$set_system_prompt(intern_system_prompt()), error = function(e) NULL)
  invisible(line)
}

# The part of the system prompt that carries the lessons.
reflexes_prompt <- function() {
  e = utils::tail(reflex_entries(), MAX_REFLEXES_IN_PROMPT)
  if (!length(e)) return("")
  paste0("## Lessons learned (reflexes)\n\nThe team's own lessons from past work. Follow them; ",
         "where one conflicts with a skill, the newer lesson wins.\n\n", paste(e, collapse = "\n"))
}

# Slash commands typed into ask() or the Viewer. Returns the text to show,
#   or NULL when `text` is not a slash command (so it goes to the model).
#   Handled entirely in R: nothing here is sent to the model.
slash_command <- function(text) {
  t = trimws(text)
  if (!startsWith(t, "/")) return(NULL)
  if (grepl("^/reflex\\s+add\\s+", t)) {
    line = reflex_add(sub("^/reflex\\s+add\\s+", "", t))
    return(paste0("Added to reflexes.md:\n", line))
  }
  if (grepl("^/reflex(\\s+list)?\\s*$", t)) {
    e = utils::tail(reflex_entries(), 10)
    return(if (length(e)) paste(c("Latest reflexes:", e), collapse = "\n") else "No reflexes yet.")
  }
  if (grepl("^/(help|\\?)\\s*$", t))
    return(paste("Commands: /reflex add <lesson>, /reflex list, /help.",
                 "Anything else is sent to inteRn."))
  paste0("Unknown command '", strsplit(t, "\\s")[[1]][1], "'. Try /help.")
}
