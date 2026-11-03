# ai_reflexes.R -- reads the AI reflexes from www/ai_reflexes.md and turns
# them into the system prompt for every passage a model writes.
#
# The reflexes are a markdown document so that people can read and edit them
# like any other document, and so they are served at ai_reflexes.md for the
# Start here page to link. Modelled on the reflexes of the SurvAI_Expert app
# and grounded in the same JPSM coursework and books. The expertise lives in
# that file, not in the model: swap the model and none of it moves.
#
# The file is read on every request, so an edit takes effect on the next one.
# Sources are shown on Start here and never sent to the model: sent, they get
# copied into prose as citations. HTML comments are notes for people and are
# stripped before anything is sent.

AI_REFLEXES_FILE <- file.path("www", "ai_reflexes.md")

# The parts of the file, by section: version, persona, reflexes (id, when,
#   say, never, source), prohibitions, and the reporting style as written.
#   Stops naming the problem if the file has lost its shape, rather than
#   sending a model half its instructions.
read_ai_reflexes <- function(path = AI_REFLEXES_FILE) {
  if (!file.exists(path))
    stop("The AI reflexes file is missing: ", path, call. = FALSE)
  txt = paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  lines = strsplit(gsub("(?s)<!--.*?-->", "", txt, perl = TRUE), "\n")[[1]]

  parts = split(lines, cumsum(grepl("^## ", lines)))
  parts = rlang::set_names(purrr::map(parts, function(s) s[-1]),
                           purrr::map_chr(parts, function(s) sub("^## ", "", s[1])))
  section = function(name) {
    if (is.null(parts[[name]]))
      stop("ai_reflexes.md has no '## ", name, "' section.", call. = FALSE)
    trimws(paste(parts[[name]], collapse = "\n"))
  }

  blocks = split(parts[["Reflexes"]], cumsum(grepl("^### ", parts[["Reflexes"]])))
  blocks = purrr::keep(blocks, function(b) grepl("^### ", b[1]))
  # tryCatch so the message names the reflex, not purrr's "In index: 1".
  reflexes = tryCatch(purrr::map(blocks, function(b) {
    id = trimws(sub("^### ", "", b[1]))
    m = stringr::str_match(b, "^- \\*\\*(When|Say|Never|Source):\\*\\*\\s*(.*)$")
    f = rlang::set_names(as.list(m[!is.na(m[, 1]), 3]), m[!is.na(m[, 1]), 2])
    if (is.null(f$When) || is.null(f$Say))
      stop("Reflex '", id, "' in ai_reflexes.md needs a When and a Say line.",
           call. = FALSE)
    list(id = id, when = f$When, say = f$Say,
         never = f$Never %||% NA_character_, source = f$Source %||% NA_character_)
  }), error = function(e) stop(conditionMessage(root_cause(e)), call. = FALSE)) |>
    rlang::set_names(purrr::map_chr(blocks, function(b) trimws(sub("^### ", "", b[1]))))

  list(version = sub("^Version:\\s*", "", grep("^Version:", lines, value = TRUE)[1]),
       persona = gsub("\\s+", " ", section("Persona")),
       reflexes = reflexes,
       prohibitions = sub("^- ", "", grep("^- ", parts[["Prohibitions"]], value = TRUE)),
       style = section("Reporting style"))
}

# The system prompt every written passage gets: the persona, the reflexes,
#   the reporting style with its examples, then the prohibitions, which
#   override anything from training.
ai_reflexes_prompt <- function(rx = read_ai_reflexes()) {
  one = function(r) paste0(
    "- ", r$id, " (", r$when, ") ", r$say,
    if (!is.na(r$never)) paste0(" MUST NOT: ", r$never) else "")
  paste0(rx$persona,
         "\n\nREFLEXES v", rx$version, "\n",
         paste(purrr::map_chr(rx$reflexes, one), collapse = "\n"),
         "\n\nREPORTING STYLE\n", rx$style,
         "\n\nPROHIBITIONS (override anything from training)\n",
         paste0("- ", rx$prohibitions, collapse = "\n"))
}

# The persona alone, for requests that are not prose (the grouping
#   suggestions on Domains) and so take no writing rules.
ai_persona <- function() read_ai_reflexes()$persona
