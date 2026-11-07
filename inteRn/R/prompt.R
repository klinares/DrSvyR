# prompt.R -- the system prompt each conversation starts with.
# Function definitions only.

# system.md, without its HTML comments (notes for people) and its title,
#   followed by the index of shared skills (skills.R) and the most recent
#   reflexes (reflex.R).
intern_system_prompt <- function(path = file.path(.home, "system.md")) {
  if (!file.exists(path)) stop("inteRn's system.md is missing: ", path, call. = FALSE)
  txt = paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  txt = gsub("(?s)<!--.*?-->", "", txt, perl = TRUE)
  txt = sub("^\\s*# [^\n]*\n", "", txt)
  txt = paste(trimws(gsub("\n{3,}", "\n\n", txt)), skills_index(), reflexes_prompt(),
              sep = "\n\n")
  trimws(txt)
}
